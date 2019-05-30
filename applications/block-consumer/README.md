# Block-Consumer

## Queries sobre la base de datos que carga el Block-Consumer 

### Queries de negocio

Las queries propuestas utilizan condiciones con `LIKE` (o `REGEXP_LIKE` o `REGEXP_REPLACE` cuando requieren mayor precisión) aplicadas sobre las `KEY` y/o los `VALUE` registrados en la tabla `HLF.BC_VALID_TX_WRITE_SET`.

#### Estructura de las keys

Para aplicar condiciones sobre `HLF.BC_VALID_TX_WRITE_SET.KEY` es importante entender el patrón con el que se construyen las key: 

    per:{persona-id}#{tag}[:{item-id}]

donde:

- {persona-id} es la CUIT, CUIL o CDI, clave que identifica a la persona, formato NUMBER(11) 
- {tag} identifica al tipo de componente, formato STRING(3) 
- {item-id} identifica al ítem dentro del tipo de componente, compuesto por valores de las propiedades que conforman la clave primaria del ítem separados por punto.

{tag} | entidad         | ejemplo
--- | ---               | ---
`per` | Persona           | `per:20123456780#per`
`act` | Actividades       | `per:20123456780#act:1.883-123456`
`imp` | Impuestos         | `per:20123456780#per:20`
`dom` | Domicilios        | `per:20123456780#per:1.1.1`
`dor` | DomiciliosRoles   | `per:20123456780#per:1.1.1.1`
`tel` | Telefonos         | `per:20123456780#per:1`
`jur` | Jurisdicciones    | `per:20123456780#per:900`
`ema` | Emails            | `per:20123456780#per:1`
`arc` | Archivos          | :soon:
`cat` | Categorias        | `per:20123456780#cat:20.12`
`eti` | Etiquetas         | `per:20123456780#eti:329`
`con` | Contribuciones    | `per:20123456780#con:5244.21`
`rel` | Relaciones        | `per:20123456780#rel:20077799975.3.15`
`cms` | CMSedes           | `per:20123456780#cms:3`
`wit` | Testigo (witness) | `per:20123456780#wit`

#### Versiones vigentes de las keys 

Para una misma key se guarda un registro cada vez que su value es modificado. 
Para recuperar la versión vigente de una key las queries utilizan la función analítica `MAX(block*100000+txseq) OVER(partition by key)` seleccionado el registro que tenga el mayor `block*100000+txseq`.

#### Keys eliminadas 

Las keys eliminadas quedan marcadas con `HLF.BC_VALID_TX_WRITE_SET.IS_DELETE='T'`. 
Las queries, una vez que recuperan la versión vigente de una key, verifican que no haya sido eliminada mediante la condición `IS_DELETE IS NULL`.

#### Ejemplos

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
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#___%'
)
where bt = max_bt 
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
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#per'
)
where bt = max_bt and is_delete is null
```

``` sql
-- Impuestos: 
-- + cantidad de personas inscriptas en el impuesto
-- + cantidad de inscripciones en el impuestos
--
-- + para extraer la cuit/cuil desde la key: substr(key, 5, 11)
-- + para extrear el impuesto desde el value se utiliza una regexp 
--
select
impuesto, 
count(distinct substr(key, 5, 11)) as personas,
count(*) as personas_impuestos
from 
(
select key,
to_number(regexp_replace(value, '^(\{.{0,})("impuesto":)([0-9]{1,4})(,.{1,}|\})$', '\3')) as impuesto,
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#imp:%'
)
where bt = max_bt and is_delete is null
group by impuesto
order by impuesto
```

Los componentes de tipo `domicilio` y `actividad` puede tener ítems nacionales (org 1) o jurisdiccionales (org entre 900 y 924). Para discriminar entre ítem nacionales o jurisdiccionales se introduce el id del org en el patrón del `LIKE`.

``` sql
-- Actividades nacionales (org 1)
--
select 
count(*)
from 
(
select key, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#act:_.%'
or    key like 'per:___________#act:883-%' /* registros guardados en la testnet con versiones del chaincode anteriores a 0.5.x */   
)
where bt = max_bt and is_delete is null
```

``` sql
-- Domicilios jurisdiccionales (orgs entre 900 y 924)
--
select 
count(*)
from 
(
select key,  
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:9%'
)
where bt = max_bt and is_delete is null
```

``` sql
-- Domicilios jurisdiccionales informados por COMARB (org 900)
--
select 
count(*)
from 
(
select key,  
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:900.%'
)
where bt = max_bt and is_delete is null
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
case when provincia between '0' and '24' then to_number(provincia) else -1 end as provincia
from
(
select key, 
substr(key, 5, 11) as persona,
regexp_replace(value, '^(\{.{0,})("provincia":)([0-9]{1,2})(,.{1,}|\})$', '\3') as provincia,
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:%' 
)
where bt = max_bt and is_delete is null
)
group by provincia
order by provincia
```

``` sql
-- Domicilios nacionales ubicados en Cordoba (provincia 3)
--
select 
count(*)
from 
(
select key,  
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, 
is_delete
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:_.%'
and   regexp_like(value, '^\{.{0,}"provincia":3(,.{1,}|\})$')
)
where bt = max_bt and is_delete is null
```

``` sql
-- Estado actual completo de una persona
--
select *
from
(
select i.*, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt
from hlf.bc_valid_tx_write_set i
where key like 'per:20000021629#%'
and   key not like '%#wit' -- descarta el testigo
)
where bt = max_bt and is_delete is null
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
order by block desc, txseq desc
```
---

### Queries para monitoreo

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
