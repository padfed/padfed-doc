# block-consumer: persistencia en la base de datos relacional

* [Introducción](#introducción)
* [Setup de la base de datos](#setup-de-la-base-de-datos)
* [Diagrama de entidad y relaciones](#diagrama-de-entidades-y-relaciones)
* [Diccionario de datos](#diccionario-de-datos)
* [Funciones de base de datos mediadoras](#funciones-de-base-de-datos-mediadoras)
* [Queries de ejemplo](#queries-de-ejemplos)

## Introducción

El modelo de base de datos relacional de **block-consumer** representa el contenido de los bloques de una Blockchain Fabric:

* un bloque contiene un set de transacciones (txs)
* una tx contiene un [read_write_set](https://hyperledger-fabric.readthedocs.io/en/release-1.4/readwrite.html)

![fabric-block](images/fabric-block.png)

La información mas útil es el contenido del `write_set` de la txs válidas que se persiste en la tabla `BC_VALID_TX_WRITE_SET`. Desde esta tabla facilmente se puede recuperar el estado actual (state) y la historia de cambios aplicados sobre el valor de una key.

Los bloques Fabric pueden contener **txs inválidas** (quedaron registradas en el ledger pero no lograron actualizar el state). **block-consumer** separa su contenido y lo persiste en `BC_INVALID_TX` y `BC_INVALID_TX_SET` para facilitar el análisis del error que causó la invalidación. Su contenido no tiene validez para el negocio y se puede depurar periodicamente.

## Setup de la base de datos

Cada organización puede cambiar los nombres de base de datos, esquema y usuarios para adpatarlos a sus estandares.

Para facilitar el tratamiento de errores recomendamos mantener los nombres de tablas, columnas, índices.

Es responsabilidad de cada organización:

* configurar el storage de las tables e índices
* cambiar password de los usuarios

[oracle](scripts/oracle/README.md)

[postgresql](scripts/postgresql/README.md)

[sqlsever](scripts/sqlserver/README.md)

---

## Diagrama de entidades y relaciones

![entity-relationship-diagram](images/entity-relationship-diagram.png)

## Diccionario de datos

#### Table BC_BLOCK

COLUMN | DESC | NOT NULL | PK
--- | --- | --- | ---
`block` | Número de bloque. | X | X
`channel` | Nombre del channel. En Padrón Federal es siempre `padfedchannel`. | X |
`peer` | Nombre del peer desde donde `block-consumer` obtuvo el bloque. | X |
`timestamp` | Timestamp de la primera tx del bloque. | X.
`consuming_time` | Fecha y hora en que el bloque fue procesado por `block-consumer` | X
`valid_system_txs` | Cantidad de txs de config de la blockchain válidas. Ejemplos: creación del channel, join de un peer. |
`invalid_system_txs` | Cantidad de txs de config de la blockchain inválidas. |
`valid_user_txs` | Cantidad de txs de negocio válidas (efectuadas mediante el smart contract o chaincode). |
`invalid_user_txs` | Cantidad de txs de negocio inválidas. |

#### Table BC_VALID_TX

COLUMN | DESC | NOT NULL | PK | UK
--- | --- | --- | --- | ---
`block` | Número de bloque. | X | X
`txseq` | Número secuencial de la tx dentro del bloque, comenzando dede 0(cero). | X | X
`txid` | UUID de la tx. |  | | X
`org_name` | MSPID del cliente que firmó la tx. Hasta ahora en Padrón Federal es siempre `AFIP`. | X |
`timestamp` | Timestamp de la tx. | X |
`chaincode` | Chaincode que procesó la tx. | X
`function` | Function (del chaincode) que procesó la tx y completó su read_write_set. | X
`excluded_write_keys` | Cantidad de keys excluidas por `block-consumer` (no guardadas en `BC_VALID_TX_WRITE_SET`, debido a que matchearon contra alguna de las regexps de exclusión configuradas por el usuario. |

#### Table BC_VALID_TX_WRITE_SET

En esta tabla se guarda el contenido del `write_set`de las txs válidas. El `read_set` (versiones de keys leídas por el chaincode) no se persiste en la base de datos. Con lo cual el contenido de la tabla siempre corresponde a actualizaciones. Dada una key el registro con mayor número de bloque corresponde al de su estado actual (última versión).

COLUMN | DESC | NOT NULL | PK | INDEX
--- | --- | --- | --- | ---
`block` | Número de bloque. | X | X
`txseq` | Número secuencial de la tx dentro del bloque. | X | X
`item` | Número secuencial del ítem del write_set dentro de la tx. | X | X
`key` | Key actualizada por la tx. | X | | X
`value` | Valor de la key actualizada por la tx. Por lo general el valor es un json.|  |
`big_value` | Valor CLOB de la key actualizada. No es necesario en Padrón Federal. |  |
`is_delete` | `T` o null. `T` indica que la tx eliminó la key en el state. |  |

---

## Funciones de base de datos mediadoras

`block-consumer` en vez de impactar directamente sobre el modelo de datos invoca a funciones intermediarias creadas en la base de datos.

Esta estrategia de diseño permite que el usuario de `block-consumer`, modificando estas funciones, pueda alterar el modelo de datos, si lo considera conveniente.

FUNCTION | DESC
--- | ---
`block_height` | Invocada en el arranque para obtener el máximo número de bloque registrado en la base.
`add_block` | Invocada una vez por cada bloque para guardar la info de cabecera del bloque.
`add_tx` | Invocada por lo menos una vez por cada tx para guardar la info de cabecera del bloque y una vez por cada ítem del read_write_set que se persiste.
`add_tx_big_value` | (opcional) invocada como alternativa a `add_tx` si el usuario configura `block-consumer` indicando que requiere persitir values mayores a 4 KB (no necesario en Padrón Federal).
`verify` | (opcional) invocada antes de commitear el contenido completo del bloque. Permite verificar la integridad de la info que se intenta registrar en la base de datos. Uso recomendado unicamente en ambientes de desarrollo/homologación.

---

### Queries de ejemplos

#### Queries de negocio

Si bien `block-consumer` es una aplicación agnóstica al negocio (se puede utilizar para procesar bloques de cualquier Blockchain Fabric), esta sección contiene ejemplos de queries aplicables al modelo de datos del Padrón Federal.

La estructura de las keys y los values del Padrón Federal está especificado en [Model](/model/README.md)

##### Query: Estado actual de una persona

``` sql
select *
from
(
select i.*,
       ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO
from   bc_valid_tx_write_set i
where  key like 'per:20000021629#%'
) x
where  RNO = 1 and is_delete is null
```

* **Versión vigente de una key**

  Para una misma key se guarda un registro cada vez que su value es modificado. Para recuperar la versión vigente de cada key la query utiliza la función analítica `ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO` junto con el filtro `RNO = 1`, seleccionando la fila con mayor `BLOCK` y `TXSEQ`.

* **Keys eliminadas**

  Las keys eliminadas quedan marcadas con `BC_VALID_TX_WRITE_SET.IS_DELETE='T'`.
  El query, una vez que recupera la versión vigente cada key, verifican que no haya sido eliminada aplicando `IS_DELETE IS NULL`. Como alterantiva se obtiene el mismo resultado aplicando `VALUE IS NOT NULL` porque únicamente las keys eliminadas pueden tener su `VALUE` vacio.

##### Query: Historia de una key

``` sql
select block, txseq, t.timestamp, i.key, i.value, i.is_delete
from   hlf.bc_valid_tx_write_set i
left join hlf.bc_valid_tx t
using  (block, txseq)
where  i.key = 'per:20000021629#per'
order by block desc, txseq desc
```

Para obtener el timestamp de cada versión de la key el query joinea `BC_VALID_TX` y `BC_VALID_TX_WRITE_SET`.

##### Query: Cantidad de personas agrupadas por tipo de clave y estado

`(full-scan)`

``` sql
select tipoid, estado, count(*)
from
(
select key,
       regexp_replace(value, '^{.*"tipoid":"([A-Z]{1})".*}', '\1') as tipoid,
       regexp_replace(value, '^{.*"estado":"([A-Z]{1})".*}', '\1') as estado,
       ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO,
       is_delete
from   hlf.bc_valid_tx_write_set
where  key like 'per:___________#per'
) x
where  RNO = 1 and is_delete is null
group by tipoid, estado
order by tipoid, estado
```

##### Query: Cantidad de inscripciones activas en impuestos

`(full-scan)`

```sql
select impuesto, count(*)
from
(
select key,
       value,
       block,
       to_number(regexp_replace(key, '^per:\d{11}#imp:(\d+)$', '\1')) as impuesto,
       ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO
from   hlf.bc_valid_tx_write_set
where  key like 'per:___________#imp:%'
) x
where  RNO = 1
AND    value LIKE '%"estado":"AC"%'
group by impuesto
order by impuesto
```

##### Query: Contribuyentes inscriptos en Convenio Multilateral agrupados por estado

`(full-scan)`

``` sql
select estado, count(*)
from
(
select substr(key, 5, 11) as cuit,
       regexp_replace(value, '^{.*"estado":"([A-Z]{2})".*}', '\1') as estado,
       ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO,
       is_delete
from   hlf.bc_valid_tx_write_set
where  key like 'per:___________#imp:5900'
) x
where  RNO = 1 and is_delete is null
group by estado
order by estado
```

##### Query: Domicilios migrados por COMARB (org 900) pendientes de consolidar

`(full-scan)`

```sql
select count(*)
from
(
select key,
       ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO,
       is_delete
from   hlf.bc_valid_tx_write_set
where  key like 'per:___________#dom:900.%'
) x
where  RNO = 1 and is_delete is null
```

##### Query: Monotributistas (impuesto 20) activos (estado AC) con domicilio fiscal de AFIP en provincia de Buenos Aires (provincia: 1)

`(full-scan)`

```sql
WITH imp20 AS
     (
     SELECT KEY, value
     from
     (
     SELECT KEY, value,
            ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO
     from   hlf.bc_valid_tx_write_set i1
     where  KEY LIKE 'per:___________#imp:20'
     ) x
     where  RNO = 1
     AND    VALUE LIKE '%"estado":"AC"%'
     )
SELECT count(*)
--     substr(x.KEY, 5, 11) AS cuit,
--     imp_value,
--     dom_value
FROM
(
SELECT dom.KEY,
       dom.block,
       dom.value   AS dom_value,
       imp20.VALUE AS imp_value,
       ROW_NUMBER() OVER(PARTITION BY dom.KEY ORDER BY dom.BLOCK DESC, dom.TXSEQ DESC) AS RNO
FROM   hlf.bc_valid_tx_write_set dom
JOIN   imp20 ON dom.KEY = substr(imp20.KEY, 1, 16)||'dom:1.1.1'
) x
where  RNO = 1
AND    regexp_like(dom_value, '^\{.*"provincia":1(,".+\}|\})$')
```

##### Query: Contribuyentes con domicilio fiscal de AFIP en Córdoba (provincia 3)

`(full-scan)`

```sql
select count(*)
from
(
select key, value,
       ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO
from   hlf.bc_valid_tx_write_set
where  key like 'per:___________#dom:1.1.1'
) x
where  RNO = 1
and    regexp_like(value, '^\{.*"provincia":3(,".+\}|\})$')
```

##### Query: Cantidad de keys agrupadas por tag

`(full-scan)`

``` sql
select tag,
       sum(case is_delete when 'T' then 0 else 1 end) as count_no_deleted,
       sum(case is_delete when 'T' then 1 else 0 end) as count_deleted
from
(
select substr(key, 17, 3) as tag,
       ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY BLOCK DESC, TXSEQ DESC) AS RNO,
       is_delete
from   hlf.bc_valid_tx_write_set
where  key like 'per:___________#___%'
) x
where  RNO = 1 and is_delete is null
group by tag
order by tag
```

### Queries para monitoreo

#### Query: Tiempo de procesamiento de los primeros 1000 bloques

`(para PostgreSQL)`

```sql
SELECT max(block),
       min(consuming_time),
       max(consuming_time),
       EXTRACT(EPOCH FROM max(consuming_time)) -
       EXTRACT(EPOCH FROM min(consuming_time)) as seconds
FROM   hlf.BC_BLOCK
WHERE  block <= 1000
```

`(para Oracle)`

```sql
SELECT max(block),
       min(consuming_time),
       max(consuming_time),
       trunc((max(consuming_time) - min(CONSUMING_TIME))*60*60*24)
FROM   hlf.BC_BLOCK
WHERE  block <= 1000
```

#### Query: Últimos 100 bloques procesados

``` sql
with max_block as
(
select max(block) as max_block from bc_block
)
select *
from  hlf.bc_block, max_block
where block between max_block.max_block-100 and max_block.max_block
order by block desc
```

#### Query: Txs que actualizaron el chaincode

`(full-scan)`

``` sql
select *
from  hlf.bc_valid_tx tx
where chaincode = 'lscc'
order by block desc
```

---
