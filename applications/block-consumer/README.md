# Block-Consumer

Aplicación que consume bloques desde un channel de una red de Blockchain [Hyperledger Fabric 1.4](https://hyperledger-fabric.readthedocs.io/en/release-1.4/index.html), procesa su contenido y lo persiste en una base de datos relacional Oracle o PostgreSQL. 

Los bloques son consumidos en orden ascendente desde el bloque 0(cero) o Genesis Block hasta el bloque mas reciente. 

Una organización, autorizada a acceder a la Blockchain que no corre nodos de la red, puede conectar el Block-Consumer mediante internet a cualquier nodo de la red. 

![](images/deploy-accediendo-a-nodos-remotos.png)

Una organización que corre nodos de la Blockchain, puede conectar el Block-Consumer a sus propios nodos peers locales para lograr mejor performance de procesamiento. 

![](images/deploy-accediendo-a-nodos-locales.png)

---

## Requisitos de ambiente:

1. DOCKER 18.09 o superior
1. DOCKER-COMPOSE 1.23.1 o superior
1. Archivos de configuración ubicados en ${PWD}/conf/
1. Instancia de base de datos Oracle o PostgreSQL
1. En la base de datos: esquema HLF y usuario BC_APP 

## Como ejecutarlo:

``` sh
docker run --rm --name block-consumer -d -v ${PWD}/conf:/conf -e TZ=America/Argentina/Buenos_Aires --tmpfs /tmp:exec -p 8084:8084 -d padfed/block-consumer:latest
```
## Archivos de configuración (Ejemplos)

###  application.conf

``` yaml
# DB 
# Oracle
# url      => jdbc:oracle:thin:@//<host>:<port>/<service_name>
db.hlf.url = "jdbc:oracle:thin:@xxx.xxx.xxx.xxx:1521:blchain"
# Postgres
# url        => jdbc:postgresql://host:port/database
# db.hlf.url = "jdbc:postgresql://localhost:5432/hlf_db"

db.hlf.user = bc_app
db.hlf.password = ????

# hikari https://github.com/brettwooldridge/HikariCP
db.hlf.hikari.maximumPoolSize = 1
db.hlf.hikari.connectionTimeout = 60000

# Nombre del schema donde estan creadas las tablas
db_hlf.schema = hlf

# Nombre de la package que recibe las invocaciones desde la aplicacion. 
# Para Postgres debe quedar seteado con "".
db_hlf.package = bc_pkg
#db_hlf.package = ""

# Puerto para monitoreo
application.port = 8084

# FABRIC conf
fabric.preferred.peer = peer0.xxx.com
fabric.switch.peers.regexp = ".*"
fabric.switch.blocks.threshold = 10

fabric.channel = padfedchannel
fabric.yaml.conf = /conf/xxx.client.yaml

# fabric.auth.type=fs: indica que la app se va a autenticar con un certificado y una pk de MSP residente en el file system.
# El certificado debe ser emitido por la CA para MSP de la organizacion indicada en el archivo de configuracion ${fabric.yaml.conf} en client: organization:
fabric.auth.type = fs
fabric.auth.appuser.name = User1
fabric.auth.appuser.keystore.path = /conf/store/local/orgX/UserX.OrgX.msp-pk.pem
fabric.auth.appuser.certsign.path = /conf/store/local/orgX/UserX.OrgX.msp-cert.pem

#fabric.tls.auth.appuser.keystore.path = /conf/store/local/orgX/UserX.OrgX.tls-pk.pem
#fabric.tls.auth.appuser.certsign.path = /conf/store/local/orgX/UserX.OrgX.tls-cert.pem

certificate.check.restrict = false

databases {
  #################################
  # oracle
  #################################
  oracle {
    dataSourceClassName = oracle.jdbc.pool.OracleDataSource
    connectionTestQuery = SELECT 1 FROM DUAL
  }

  #################################
  # postgresql
  #################################
  postgresql {
    dataSourceClassName = org.postgresql.ds.PGSimpleDataSource
    connectionTestQuery = SELECT 1
  }
}

fabric {
  netty {
    grpc {
      //keyAliveTime in Minutes
      NettyChannelBuilderOption.keepAliveTime="5"
      //keepAliveTimeout in Seconds
      NettyChannelBuilderOption.keepAliveTimeout="8"
      NettyChannelBuilderOption.keepAliveWithoutCalls="true"
      //maxInboundMessageSize in bytes
      NettyChannelBuilderOption.maxInboundMessageSize="50000000"
    }
  }

  sdk {
    peer.retry_wait_time = "5000"
  }
}

```
### ${fabric.yaml.conf}

``` yaml
name: "Network"
version: "1.0"
x-loggingLevel: trace

client:
  # organization: XXX | YYY | ZZZ | MULTIORGS
  organization: XXX
  logging:
    level: info
  eventService:
    timeout:
      connection: 5s
      registrationResponse: 5s

channels:
  padfedchannel:
    orderers:
      - orderer0.orderer.xxx.com

    peers:
      peer0.xxx.com:
        endorsingPeer: false
        chaincodeQuery: false
        ledgerQuery: true
        eventSource: false

      peer1.xxx.com:
        endorsingPeer: false
        chaincodeQuery: false
        ledgerQuery: true
        eventSource: false

      peer0.zzz.com:
        endorsingPeer: false
        chaincodeQuery: false
        ledgerQuery: true
        eventSource: false

      peer1.zzz.com:
        endorsingPeer: false
        chaincodeQuery: false
        ledgerQuery: true
        eventSource: false

      peer0.yyy.com:
        endorsingPeer: false
        chaincodeQuery: false
        ledgerQuery: true
        eventSource: false

      peer1.yyy.com:
        endorsingPeer: false
        chaincodeQuery: false
        ledgerQuery: true
        eventSource: false

organizations:
  XXX:
    mspid: XXX
    peers:
      - peer0.xxx.com
      - peer1.xxx.com

  ZZZ:
    mspid: ZZZ
    peers:
      - peer0.zzz.com
      - peer1.zzz.com

  ZZZ:
    mspid: ZZZ
    peers:
      - peer0.yyy.com
      - peer1.yyy.com

orderers:
  orderer0.orderer.xxx.com:
    url: grpcs://orderer0.orderer.xxx.com:7050
    tlsCACerts:
      path: conf/tls/orderer/orderer.tls-root-ca.pem

peers:
  peer0.xxx.com:
    url: grpcs://peer0.xxx.com:7051
    tlsCACerts:
      path: conf/tls/XXX/XXX.tls-root-ca.pem

  peer1.xxx.com:
    url: grpcs://peer1.xxx.com:7051
    tlsCACerts:
      path: conf/tls/XXX/XXX.tls-root-ca.pem

  peer0.zzz.com:
    url: grpcs://peer0.zzz.com:7051
    tlsCACerts:
      path: conf/tls/ZZZ/ZZZ.tls-root-ca.pem

  peer1.zzz.com:
    url: grpcs://peer1.zzz.com:7051
    tlsCACerts:
      path: conf/tls/ZZZ/ZZZ.tls-root-ca.pem

  peer0.yyy.com:
    url: grpcs://peer0.yyy.com:7051
    tlsCACerts:
      path: conf/tls/ZZZ/ZZZ.tls-root-ca.pem

  peer1.yyy.com:
    url: grpcs://peer1.yyy.com:7051
   tlsCACerts:
      path: conf/tls/ZZZ/ZZZ.tls-root-ca.pem
```
---
## Base de Datos

### Modelo de Datos

![](images/diagrama-de-entidad-relaciones.png)

Tabla | Descripcion | PK | Indice
--- | --- | --- | ---
BC_BLOCK | un registro por cada bloque consumido | BLOCK
BC_VALID_TX | un registro por cada tx válida correspondiente a un bloque consumido | BLOCK, TXSEQ | TXID
BC_INVALID_TX | un registro por cada tx inválida correspondiente a un bloque consumido | BLOCK, TXSEQ | TXID
BC_VALID_TX_WRITE_SET | un registro por cada ítem del WRITE_SET de las tx válidas consumidas | BLOCK, TXSEQ, ITEM | KEY
BC_INVALID_TX_SET | un registro por cada ítem del READ_SET o WRITE_SET de las txs inválidas consumidas | BLOCK, TXSEQ, TYPE, ITEM | KEY

Usuario| Desc
--- | --- 
??? | Admin de la instancia
HLF | Dueño del schema
BC_APP | Usuario para el datasource de la app BLOCK-CONSUMER. Tiene permisos para ejecutar HLF.BC_PKG y para leer HLF.BC_BLOCK
BC_ROSI | Usuario para el datasource de la app ROSi. Tiene permisos para leer todas las tablas de HLF. Opcional.

### Creación del Esquema HLF y de los usuarios BC_APP y ROSI_APP

Para crear el esquema HLF y los usuarios se deben ejecutar los scripts incrementales correspondientes a Oracle o a Postgres.

Script | Tipo | Descripcion
--- | --- | ---
inc/001_dcl_create_user_hlf.sql | dcl | crea usuario del schema HLF
inc/002_ddl_create_schema_hlf.sql | ddl | crea tablas, indices y restricciones en el schema HLF
inc/003_ddl_create_pkg.sql | ddl | invoca al script ../rep/bc_pkg.sql 
inc/004_dcl_create_apps_user.sql | dcl | crea usuarios BC_APP y ROSI_APP
rep/bc_pkg.sql | ddl | crea la pkg bc_pkg que permite actualizar las tablas del schema HLF

### Queries sobre la base de datos que carga el Block-Consumer 

#### Queries de negocio

Si bien, Block-Consumer es una aplicación totalmente agnóstica al negocio. Se puede utilizar para procesar bloques de cualquier Blockchain HLF, esta sección del doc contiene ejemplos de queries aplicables al modelo de datos del Padrón Federal. 

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
) x
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
) x
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
) x
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
) x
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
) x
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
) x
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
regexp_replace(value, '^(\{.{0,})("provincia":)([0-9]{1,2})(,.{1,}|\})$', '\3') as provincia,
block*100000+txseq as bt, max(block*100000+txseq) over(partition by key) as max_bt, is_delete
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:%' 
) x
where bt = max_bt and is_delete is null
) x2
group by provincia
order by personas desc
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
) x
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
) x
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

1.3.1

* getHeight: utilizar peer candidato seleccionado con longestBlockchainNode
* longestBlockchainNode al iniciar la app y luego de un fallo
* gestion de conexion jdbc: asegurar cierre de conexion cuando se produce una falla en las invocaciones
* regresion: error "bc_valid_tx_write_set" violates check constraint "chek_valid_tx_value"

1.3.0

* Script para resetear la base de datos Oracle sin necesidad de recrear los objetos
* Permite configurar tamaño máximo permitido para consumir
* Entrypoint de monitoreo `/metrics` compatible con [Prometheus](https://prometheus.io/)