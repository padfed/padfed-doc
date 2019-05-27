# Block-Consumer

## Queries de monitoreo

with last_blocks as 
(
select max(block)-50 as desde, max(block) as hasta from hlf.bc_block
) 
select block,
       max(txseq) as txs,
       count(*) as items
from   hlf.bc_valid_tx_write_set, last_blocks
where  block between last_blocks.desde and last_blocks.hasta
group by block
order by block desc


## Queries de negocio

Por lo general las queries propuestas utilizan condiciones con `LIKE` (o `REGEXP_LIKE` si se requiere mayor precisión) aplicadas sobre las `KEY` y/o los `VALUE` registrados en la tabla `HLF.BC_VALID_TX_WRITE_SET`.

Asimismo, dado que una key es registrada en la base de datos cada vez que su valor es modificado, para contar ítems sin repeticion las queries utilizan la función `COUNT(DISTINCT KEY)`.

#### Estructura de las keys

Para aplicar condiciones sobre `HLF.BC_VALID_TX_WRITE_SET.KEY` es importante entender el patrón con el que se construyen las key: 

    per:{persona-id}#{tag}\[:{item-id}\]

donde:

- {persona-id} es una clave que identifica a la persona, formato NUMBER(11), por lo general es una CUIT 
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

### Ejemplos

``` sql
-- Cantidad de personas
--
select count(distinct key) 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#per'
```

``` sql
-- Impuestos
--
select 
count(distinct substr(key, 1, 15)) as personas,
count(distinct key) as personas_impuestos
from hlf.bc_valid_tx_write_set
where key like 'per:___________#imp:%'
```

Los componentes de tipo `domicilio` y `actividad` puede tener ítems nacionales (org:1) o jurisdiccionales (org entre 900 y 924). Para discriminar entre ítem nacionales o jurisdiccionales se introduce el id del org en el patrón del `LIKE`.

``` sql
-- Actividades nacionales (org 1)
--
select count(distinct key) 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#act:1.%'
```

``` sql
-- Domicilios jurisdiccionales (orgs entre 900 y 924)
--
select count(distinct key) 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:9__.%'
```

``` sql
-- Domicilios jurisdiccionales informados COMARB (org 900)
--
select count(distinct key) 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:900.%'
```

``` sql
-- Domicilios agrupados por jurisdiccion
--
-- per:___________#dom:901.%
-- 123456789012345678901234`
-- 1.......10........20....`
--
select 
case substr(org, 1, 1) when '1' then '1' else to_char(org) end as org
from
(
select 
substr(key, 21, 3) as org,
count(distinct substr(key, 1, 15)) as personas, 
count(distinct key) as personas_domicilios
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:%'
group by substr(key, 21, 3)
)
```

``` sql
-- Domicilios nacionales ubicados en Cordoba (provincia 3)
--
select count(distinct key) 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:1.%'
and   regexp_like(value, '^\{.{0,}"provincia":3(,.{1,}|\})$')
```

Para obtener la versión mas reciente de todos los componentes de una persona se puede utilizar la función analítica `MAX(BLOCK*100000+TXSEQ) OVER(PERTITION BY KEY)`.

``` sql
-- Estado actual completo de una persona
--
select *
from
(
select i.*, max(block*100000+txseq) over(partition by key) as max_block_dot_txseq
from hlf.bc_valid_tx_write_set i
where key like 'per:20000021629#%'
and   key not like '%#wit' -- descarta el testigo
)
where (block*100000+txseq) = max_block_dot_txseq
order by length(key), key
```
Para obtener la historia de una key se puede joinear `HLF.BC_VALID_TX` y `HLF.BC_VALID_TX_WRITE_SET` 

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
