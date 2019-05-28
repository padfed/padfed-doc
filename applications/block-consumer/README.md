# Block-Consumer

## Queries sobre la base de datos que carga el Block-Consumer 

### Queries de monitoreo

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
-- Txs de inválidas
--
select * from 
hlf.bc_invalid_tx tx
order by block desc, txseq desc
``` 
### Queries de negocio

Por lo general las queries propuestas utilizan condiciones con `LIKE` (o `REGEXP_LIKE` si requieren mayor precisión) aplicadas sobre las `KEY` y/o los `VALUE` registrados en la tabla `HLF.BC_VALID_TX_WRITE_SET`.

#### Estructura de las keys

Para aplicar condiciones sobre `HLF.BC_VALID_TX_WRITE_SET.KEY` es importante entender el patrón con el que se construyen las key: 

    per:{persona-id}#{tag}\[:{item-id}\]

donde:

- {persona-id} es la CUIT, CUIL o CDI, clave que identifica a la persona, formato NUMBER(11) 
- {tag} identifica al tipo de componente, formato STRING(3) 
- {item-id} identifica al ítem dentro del tipo de componente, compuesto por valores de las propiedades que conforman la clave primaria del ítem separados por punto.

{tag} | entidad
--- | ---
per | Persona
act | Actividades
imp | Impuestos
dom | Domicilios
dor | DomiciliosRoles
tel | Telefonos
jur | Jurisdicciones
ema | Emails
arc | Archivos
cat | Categorias
eti | Etiquetas
con | Contribuciones
rel | Relaciones
cms | CMSedes
wit | Testigo (witness)

#### Versiones vigentes de las keys 

Para una misma key existe un registro por cada vez que su value es modificado. Para recuperar la versión vigente de una key las queries utilizan la función analítica `MAX(block*100000+txseq) OVER(partition by key)`.

#### Keys eliminadas 

Las keys eliminadas quedan marcadas con `HLF.BC_VALID_TX_WRITE_SET.IS_DELETE='T'`. Las queries una vez que recuperan la versión vigente de la key verifican que la key no este eliminada mediante la condicion `IS_DELETE IS NULL`.

#### Ejemplos

``` sql
-- Cantidad de personas
--
select count(*)
from
(
select key, is_delete, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#per'
)
where bt = max_bt and is_delete is null
```

``` sql
-- Impuestos: 
-- + cantidad de personas inscriptas en algun impuesto
-- + cantidad de inscripciones en impuestos
--
select 
count(distinct substr(key, 5, 15)) as personas,
count(*) as personas_impuestos
from 
(
select key, is_delete, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#imp:%'
)
where bt = max_bt and is_delete is null
```

Los componentes de tipo `domicilio` y `actividad` puede tener ítems nacionales (org:1) o jurisdiccionales (org entre 900 y 924). Para discriminar entre ítem nacionales o jurisdiccionales se introduce el id del org en el patrón del `LIKE`.

``` sql
-- Actividades nacionales (org 1)
--
select 
count(*)
from 
(
select key, is_delete, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#act:_.%'
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
select key, is_delete, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt 
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
select key, is_delete, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:900.%'
)
where bt = max_bt and is_delete is null
```

``` sql
-- Domicilios agrupados por jurisdiccion
--
-- per:___________#dom:901.%
-- 123456789012345678901234`
-- 1.......10........20....`
--
select 
case substr(key, 21, 1) when '9' then substr(key, 21, 3) else '1' end as org,
count(distinct substr(key, 5, 15)) as personas, 
count(distinct key) as personas_domicilios
from 
(
select key, is_delete, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:%'
)
where bt = max_bt and is_delete is null
group by 
case substr(key, 21, 1) when '9' then substr(key, 21, 3) else '1' end
```

``` sql
-- Domicilios nacionales ubicados en Cordoba (provincia 3)
--
select 
count(*)
from 
(
select key, is_delete, 
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:900.%'
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
