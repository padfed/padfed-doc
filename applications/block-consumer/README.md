# Block-Consumer

Aplicación (imagen docker) que lee bloques desde un channel de una red de Blockchain [Hyperledger Fabric 1.4 LTS](https://hyperledger-fabric.readthedocs.io/en/release-1.4/index.html), procesa su contenido y lo persiste en una base de datos relacional Oracle, PostgreSQL o SQL Server.

Los bloques son leidos en orden ascendente desde el bloque 0(cero) o Genesis Block, hasta el bloque mas reciente.

Una organización, autorizada a acceder a la Blockchain que no corre nodos de la red, puede conectar el `block-Consumer` a cualquier peer de la red mediante internet.

![deploy-accediendo-a-nodos-remotos](images/deploy-accediendo-a-nodos-remotos.png)

Una organización que corre nodos de la Blockchain, puede conectar el `block-Consumer` a sus peers locales para lograr mejor performance de procesamiento.

![deploy-accediendo-a-nodos-locales](images/deploy-accediendo-a-nodos-locales.png)

---

## Requisitos

1. Equipo con 2 GB de RAM
1. `DOCKER 18.09` o superior
1. Reglas de proxy: acceso a por lo menos un peer de la red en internet, protocolo [gRPCs](https://grpc.io/) y puerto `7051`
1. Material criptográfico `x509` en formato `PEM`
1. Base de datos (`Oracle`, `PostgreSQL` o `SQL Server`): Espacio 100 GB

---

## Instrucciones de instalación

### 1) Material criptográfico propio del block-consumer

Son dos pares de clave-privada/certificado para:

- Servicio de Membresia [MSP](https://hyperledger-fabric.readthedocs.io/en/release-1.4/membership/membership.html)
- Seguridad en la capa de transporte [TLS](https://hyperledger-fabric.readthedocs.io/en/release-1.4/enable_tls.html)

Este material lo debe generar tu organización.

Los certificados deben estar emitido por las CAs de tu organización, cuyos certificados deben estar registrados en la Blockchain.

Características del certificado para `MSP`:

- algoritmo: `prime256v1`
- en el `DN` debe contener `OU=<MSPID-de-tu-organizacion>` y `OU=client`.

Características del certificado para `TLS`:

- algoritmo: `RSA:2048`
- debe contener la extensión `Extended Key Usage TLS Web Client Authentication`.

Si para obtener este material criptográfico se utilizó `padfed-network-setup` los nombres de los archivos son los siguientes:

- `blockconsumer@blockchain-tributaria.xxx.gob.ar-msp-client.key`
- `blockconsumer@blockchain-tributaria.xxx.gob.ar-msp-client.crt`
- `blockconsumer@blockchain-tributaria.xxx.gob.ar-tls-client.key`
- `blockconsumer@blockchain-tributaria.xxx.gob.ar-tls-client.crt`

NOTA: podes asignarles nombres cualesquiera indicándolos en el `application.conf`.

### 2) Certificados de las CAs emisoras de certificados de `TLS` de los peers

Tenes que solicitarle a AFIP los certficados de las CAs que emitieron los certifcados de TLS de los peers a los cuales el `block-consumer` se va a conectar.

Ejemplo:

- `tlsica.blockchain-tributaria.afip.gob.ar-tls.crt`
- `tlsica.blockchain-tributaria.comarb.gob.ar-tls.crt`

### 3) application.conf

El `application.conf` contiene:

- parámetros de conexión a la base de datos
- ubicación del `client.yaml`
- ubicación del material criptográfico propio del `block-consumer`
- (opcional) filtros de keys

Ejemplo: [application.conf](application.conf)

### 4) client.yaml

El `client.yaml` es un archivo de configuración estándar de Fabric que describe la red.

Ejemplo: [client.yaml](client.yaml)

### 5) Estructura de directorios de deploy

En un equipo donde tengas instalado `docker` crea la siguiente estructura de directorios.

En `conf/crypto/client` ubicas el material criptografico propio del `block-consumer`.

En `conf/crypto/tlscas` ubicas los certificados de las CAs emisoras de los certificados de `TLS` de los peers a los que l `block-consumer` se va a conectat. Con la estructura de ejemplo, `block-consumer` se puede conectar a los peers de AFIP y de COMARB.

``` txt
block-consumer
  └── conf
      ├── application.conf
      ├── client.yaml
      └── crypto
          ├── client
          │   ├── blockconsumer@blockchain-tributaria.xxx.gob.ar-msp-client.key
          │   ├── blockconsumer@blockchain-tributaria.xxx.gob.ar-msp-client.crt
          │   ├── blockconsumer@blockchain-tributaria.xxx.gob.ar-tls-client.key
          │   └── blockconsumer@blockchain-tributaria.xxx.gob.ar-tls-client.crt
          └── tlscas
              ├── tlsica.blockchain-tributaria.afip.gob.ar-tls.crt
              └── tlsica.blockchain-tributaria.comarb.gob.ar-tls.crt
```

### 6) script para correr el contenedor

En el directorio `block-consumer` crea un script `docker-run.sh` con el siguiente contenido:

```sh
#!/bin/bash

docker run --log-opt max-size=10m \
           --log-opt max-file=10 \
           --rm \
           --name block-consumer \
           --tmpfs /tmp:exec \
           -v "${PWD}/conf:/conf" \
           -e TZ=America/Argentina/Buenos_Aires \
           -p 8084:8084 \
           -d padfed/block-consumer:2.0.0
```

### 7) Base de Datos

En una base de datos Oracle, PostgreSQL o SQL Server necesitas crear:

- un schema con tablas e índices
- una package o funciones intermediarias que son invocadas desde `block-consumer` para insertar filas
- un usuario de base de datos para que `block-consumer` pueda ejecutar la package o las funciones

---

## Funcionamiento de block-consumer

Cuando arranca `block-consumer` invoca a la función de base de datos `block_height()` para obtener el máximo número de bloque registrado en la tabla `BC_BLOCK`.

A continuación se conecta a la Blockchain y comienza a leer secuencialmente los bloques desde el número obtenido con  `block_height()` + 1.

Por cada bloque leido:

- invoca a la función de base de datos `add_block()` que inserta una fila en `BC_BLOCK`
- por cada tx contenida en el bloque
  - invoca a la función `add_tx()` que inserta una fila en `BC_VALID_TX` con la info de la tx y otra en `BC_VALID_TX_WRITE_SET` con la info de la primera key actualizada por la tx
  - por cada key actualizada por la tx (exceptuando la primera)
    - invoca a la función `add_tx()` que insert una fila en  `BC_VALID_TX_WRITE_SET`

En caso que la tx fue invalidada (no logró actualizar el state del Blockchain) la info de la tx y de las keys que leyó y las que intentó actualizar se registran respectivamente en  `BC_INVALID_TX` y en  `BC_INVALID_TX_SET`.

777777777777777777777777777777777777777777777777777777777

### Modelo de Datos

![diagrama-de-entidad-relaciones](images/diagrama-de-entidad-relaciones.png)

TABLE | Descripción | PRIMARY KEY | INDEX
--- | --- | --- | ---
`BC_BLOCK` | Bloque consumido. | `BLOCK`
`BC_VALID_TX` | Transacción válida contenida en un bloque consumido. | `BLOCK, TXSEQ` | `TXID`
`BC_VALID_TX_WRITE_SET` | Ítem del WRITE_SET de transacciones válidas. Cada ítem corresponde a la creación o actualización de un registro del Padrón Federal en la Blockchain. Una actualización puede corresponder a la eliminación del registro (`IS_DELETE='T'`). | `BLOCK, TXSEQ, ITEM` | `KEY`
`BC_INVALID_TX` | Transacción inválida contenida en un bloque consumido. | `BLOCK, TXSEQ` | `TXID`
`BC_INVALID_TX_SET` | Ítem del READ_SET o WRITE_SET de transacciones inválidas. | `BLOCK, TXSEQ, TYPE, ITEM` | `KEY`

Usuario | Desc
--- | ---
??? | Admin de la instancia.
`HLF` | Dueño del schema.
`BC_APP` | Usuario que utiliza la aplicación para conectarse a la base de datos. Debe tener permisos para ejecutar la package `HLF.BC_PKG`.
`BC_ROSI` | (Opcional) Usuario para el datasource de la app ROSi. Tiene permisos para leer todas las tablas de `HLF`.

### Creación del Esquema HLF y de los usuarios de base de datos

Para crear el esquema `HLF` y se pueden ejecutar los scripts correspondientes a Oracle (`sql-oracle`) o a Postgres (`sql-postgresql`).

Script | Tipo | Descripción
--- | --- | ---
`inc/001_dcl_create_user_hlf.sql` | dcl | crea el usuario dueño del schema `HLF`
`inc/002_ddl_create_schema_hlf.sql` | ddl | crea tablas, índices y restricciones en el schema `HLF`
`inc/003_ddl_create_pkg.sql` | ddl | invoca al script `../rep/bc_pkg.sql`
`inc/004_dcl_create_apps_user.sql` | dcl | crea usuarios `BC_APP` y (opcional) `ROSI_APP`
`rep/bc_pkg.sql` | ddl | create de la package `HLF.BC_PKG` que utiliza Block-Consumer leer y actualizar las tablas del schema `HLF`

NOTA: Para Postgres asegurarse de ejecutar `su - postgres` y a continuación los scripts antes mencionados. Otra forma es ejecutando el script automatizado `helpers\createdb-hlf.sh`.

### Queries sobre la base de datos que carga Block-Consumer

#### Queries de negocio

Si bien, Block-Consumer es una aplicación totalmente agnóstica al negocio (se puede utilizar para procesar bloques de cualquier Blockchain HLF), esta sección contiene ejemplos de queries aplicables al modelo de datos del Padrón Federal.

Las queries propuestas utilizan condiciones de búsqueda con `LIKE`, `REGEXP_LIKE` y `REGEXP_REPLACE` aplicadas sobro los atributos `KEY` y/o `VALUE` registrados en la tabla `HLF.BC_VALID_TX_WRITE_SET`.

La estructura de las keys y los values están especificados en [Model](/model/README.md)

#### Versiones vigentes de las keys

Para una misma key se guarda un registro cada vez que su value es modificado. Un mismo bloque no puede contener mas de una modificacion sobre la misma key.

Para recuperar la versión vigente de cada key las queries utilizan la función analítica `MAX(BLOCK) OVER(PARTITION BY KEY)` con el filtro `BLOCK = MAX_BLOCK`.

#### Keys eliminadas

Las keys eliminadas quedan marcadas con `HLF.BC_VALID_TX_WRITE_SET.IS_DELETE='T'`.
Las queries, una vez que recuperan la versión vigente de una key, verifican que no haya sido eliminada mediante la condición `IS_DELETE IS NULL`.

#### Ejemplos

``` sql
-- Estado actual completo de una persona
--
select *
from
(
select i.*,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK
from hlf.bc_valid_tx_write_set i
where key like 'per:20000021629#%'
and   key not like '%#wit' -- descarta el testigo
) x
where BLOCK = MAX_BLOCK and IS_DELETE is null
order by length(key), key
```

Para obtener la historia de una key se puede joinear `HLF.BC_VALID_TX` y `HLF.BC_VALID_TX_WRITE_SET`.

``` sql
-- Historia de una key
--
select block, txseq, t.timestamp, i.key, i.value, i.is_delete
from hlf.bc_valid_tx_write_set i
left join hlf.bc_valid_tx t
using (block, txseq)
where i.key like 'per:20000021629#per'
order by block desc
```

``` sql
-- Cantidad de keys agrupadas por tag
--
select tag,
sum(case is_delete when 'T' then 0 else 1 end) as count_no_deleted,
sum(case is_delete when 'T' then 1 else 0 end) as count_deleted
from
(
select key,
substr(key, 17, 3) as tag,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#___%'
) x
where BLOCK = MAX_BLOCK
group by tag
order by tag
```

``` sql
-- Cantidad de personas
--
select count(*)
from
(
select key,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#per'
) x
where BLOCK = MAX_BLOCK and is_delete is null
```

``` sql
-- Impuestos:
-- + cantidad de personas inscriptas en el impuesto
-- + cantidad de inscripciones en el impuestos
--
-- + para extraer la cuit/cuil desde la key: substr(key, 5, 11)
-- + para extrear el impuesto desde la key se utiliza una regexp
--
select
impuesto,
count(distinct substr(key, 5, 11)) as personas,
count(*) as personas_impuestos
from
(
select key,
to_number(regexp_replace(key, '^per:\d{11}#imp:(\d+)$', '\1')) as impuesto,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#imp:%'
) x
where BLOCK = MAX_BLOCK and is_delete is null
group by impuesto
order by impuesto
```

``` sql
-- Actividades del nomenclador 883
--
select
count(*)
from
(
select key,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#act:1.883-%'
or    key like 'per:___________#act:883-%' /* actividades en la Testnet registradas con versiones del chaincode anteriores a 0.5.x */
) x
where BLOCK = MAX_BLOCK and is_delete is null
```

``` sql
-- Domicilios "no consolidados"
--
select
count(*)
from
(
select key,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:9__.%'
) x
where BLOCK = MAX_BLOCK and is_delete is null
```

``` sql
-- Domicilios "no consolidados" informados por COMARB (org 900)
--
select
count(*)
from
(
select key,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:900.%'
) x
where BLOCK = MAX_BLOCK and is_delete is null
```

``` sql
-- Domicilios agrupados por provincia
--
select
provincia,
count(distinct persona) as personas,
count(*) as domicilios
from
(
select key, persona,
case provincia
when '0'  then 'CABA'
when '1'  then 'BUENOS AIRES'
when '2'  then 'CATAMARCA'
when '3'  then 'CORDOBA'
when '4'  then 'CORRIENTES'
when '5'  then 'ENTRE RIOS'
when '6'  then 'JUJUY'
when '7'  then 'MENDOZA'
when '8'  then 'LA RIOJA'
when '9'  then 'SALTA'
when '10' then 'SAN JUAN'
when '11' then 'SAN LUIS'
when '13' then 'SANTIAGO DEL ESTERO'
when '12' then 'SANTA FE'
when '14' then 'TUCUMAN'
when '16' then 'CHACO'
when '17' then 'CHUBUT'
when '18' then 'FORMOSA'
when '19' then 'MISIONES'
when '20' then 'NEUQUEN'
when '21' then 'LA PAMPA'
when '22' then 'RIO NEGRO'
when '23' then 'SANTA CRUZ'
when '24' then 'TIERRA DEL FUEGO'
else '#sin provincia'
end as provincia
from
(
select key,
substr(key, 5, 11) as persona,
regexp_replace(value, '^\{.*"provincia":(\d+).*\}$', '\1') as provincia,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:%'
) x
where BLOCK = MAX_BLOCK and is_delete is null
) x2
group by provincia
order by personas DESC
```

``` sql
-- Domicilios ubicados en Cordoba (provincia 3)
--
select
count(*)
from
(
select key, value,
MAX(BLOCK) OVER(PARTITION BY KEY) as MAX_BLOCK, BLOCK, IS_DELETE
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:%'
) x
where BLOCK = MAX_BLOCK and is_delete is null
and   regexp_like(value, '^\{.*"provincia":3(,".+\}|\})$')
```

---

#### Queries para monitoreo

``` sql
-- Ultimos 50 bloques procesados
--
with max_block as
(
select max(block) as mb from hlf.bc_block
)
select *
from   hlf.bc_block, max_block
where  block between max_block.mb-50 and max_block.mb
order by block desc
```

``` sql
-- Txs de deploy de chaincode
--
select * from
hlf.bc_valid_tx tx
where chaincode='lscc'
order by block desc, txseq desc
```

``` sql
-- Txs inválidas
--
select * from
hlf.bc_invalid_tx tx
order by block desc, txseq desc
```

### Changelog

---
1.4.1

- bugfix: #65730 - PostgreSQL: Error al intentar insertar caracter null (0x00)

1.4.0

- Se permite definir un límite de memoria a la JVM utilizada dentro de la imagen docker. Se incluyen ejemplos de inicio
- Soporte de SQL Server para persistir modelo de datos. Se incorporan scripts de creación del modelo de datos para dicho motor
- Se reapunta endpoint para metricas de monitoreo desde el endpoint "/metrics" a "/blockconsumer/metrics"

1.3.1

- Conexiones jdbc: asegurar cierre de conexión cuando se producen errores en las invocaciones sql
- Fix error violates check constraint "check_valid_tx_value" en bloques que cotienen txs con deletes

1.3.0

- Script para resetear la base de datos Oracle sin necesidad de recrear los objetos
- Permite configurar tamaño máximo de bloque a consumir
- Entrypoint de monitoreo `/metrics` compatible con [`Prometheus`](https://prometheus.io/)
