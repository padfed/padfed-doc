# Block-Consumer

Aplicación que consume bloques desde un channel de una red de Blockchain [Hyperledger Fabric 1.4](https://hyperledger-fabric.readthedocs.io/en/release-1.4/index.html), procesa su contenido y lo persiste en una base de datos relacional Oracle, PostgreSQL o SQL Server. 

Los bloques son consumidos en orden ascendente desde el bloque 0(cero) o Genesis Block hasta el bloque mas reciente. 

Una organización, autorizada a acceder a la Blockchain que no corre nodos de la red, puede conectar el Block-Consumer mediante internet a cualquier peer de la red. 

![](images/deploy-accediendo-a-nodos-remotos.png)

Una organización que corre nodos de la Blockchain, puede conectar el Block-Consumer a sus peers locales para lograr mejor performance de procesamiento. 

![](images/deploy-accediendo-a-nodos-locales.png)

---

## Requisitos para la instalación

1. Equipo con 2 GB de RAM
1. DOCKER 18.09 o superior
1. DOCKER-COMPOSE 1.23.1 o superior
1. [Archivos de configuración](conf/README.md) 
2. Instancia de base de datos `Oracle`, `PostgreSQL` o `SQL Server`
3. Espacio en base de datos para Padrón Federal: 100 GB
4. Reglas de firewall: acceso a por lo menos un peer de la red puerto 7051, no requiere acceder al orderer
5. Base de datos Oracle:
   - Schema de base de datos `HLF` creado
   - Usuario de aplicacion `BC_APP` creado con acceso a las tablas del schema `HLF`
6. Material criptográfico Fabric:
   - Certificado y clave privada para `MSP` (`OU=client`) emitido para la aplicación
   - Certificado y clave privada para `TLS` (`Extended Key Usage TLS Web Client Authentication`) emitido para la aplicación
   - Certificado de la Root CA o intermedia de `TLS` de las organizaciones dueñas de los peers a los que se conecta

## Instrucciones de instalación

### 1- Crea la estructura de directorios para el runtime

``` txt
blockconsumer
  └── conf
      └── crypto
          ├── client
          └── tlscas
```

### 2- Obtené los certificados y las claves privadas para `MSP` y para `TLS`

En caso que para obtener los certiticados se utilizó `padfed-network-setup` los nombres de los archivos son los siguientes: 

- `blockconsumer@blockchain-tributaria.xxxx.gob.ar-msp-client.key`
- `blockconsumer@blockchain-tributaria.xxxx.gob.ar-msp-client.crt`
- `blockconsumer@blockchain-tributaria.xxxx.gob.ar-tls-client.key`
- `blockconsumer@blockchain-tributaria.xxxx.gob.ar-tls-client.crt`

NOTA: podes ponerles otros nombres cualesquiera y en el `application.conf` indicar cuales son.

### 3- Obtené los certificados de las Roots CA o intermedias de `TLS` de las organizaciones dueñas de los peers a los cuales se intente conectar

Ej:

- `tlsica.blockchain-tributaria.xxxx.gob.ar-tls.crt`

### 4- Ubicá las los certificados y las claves en la estructura de directorios de runtime

Tenes que ubicar los 2 pares key/crt obtenidos en el paso 2 y el crt obtenido en el paso 3 en la estructura de directorio para runtime.

Ejemplo: condiguración de `blockconsumer` para conectarse a peers de AFIP y de ARBA

``` txt
blockconsumer
  └── conf
      └── crypto
          ├── client
          │   ├── blockconsumer@blockchain-tributaria.xxxx.gob.ar-msp-client.key
          │   ├── blockconsumer@blockchain-tributaria.xxxx.gob.ar-msp-client.crt
          │   ├── blockconsumer@blockchain-tributaria.xxxx.gob.ar-tls-client.key
          │   └── blockconsumer@blockchain-tributaria.xxxx.gob.ar-tls-client.crt
          └── tlscas
              ├── tlsica.blockchain-tributaria.afip.gob.ar-tls.crt
              └── tlsica.blockchain-tributaria.arba.gob.ar-tls.crt
```

### 5- Creá el application.conf

En el directorio `blockconsumer/conf` tenes que crear un `application.conf`.

El `application.conf` contiene los parámetros de conexión a la base de datos, la ubicación del `client.yaml`, la ubicación de las
credenciales de la aplicación, ...

Podes copiar el siguiente contenido, reemplazando las properties correspondientes:

```conf
# DB
# Oracle
# url      => jdbc:oracle:thin:@//<host>:<port>/<service_name>
db.hlf.url = "jdbc:oracle:thin:@xxx.xxx.xxx.xxx:1521:SID"
# Postgres
# db.hlf.url = "jdbc:postgresql://localhost:5432/hlf_db"
# SQLServer
# db.hlf.url = "jdbc:jtds:sqlserver://host:1433:hlf_db"

# Usuario con que se conecta la aplicacion
db.hlf.user = bc_app
db.hlf.password = ????

# hikari https://github.com/brettwooldridge/HikariCP
db.hlf.hikari.maximumPoolSize = 1
db.hlf.hikari.connectionTimeout = 60000

# Nombre del schema donde estan creadas las tablas (owner)
db_hlf.schema = hlf

# Nombre de la package que recibe las invocaciones desde la aplicacion. 
# Para Postgres debe quedar seteado con "".
db_hlf.package = bc_pkg
#db_hlf.package = ""

# Puerto para monitoreo
application.port = 8084

# FABRIC conf
# Nombre del peer preferido
fabric.preferred.peer = peer0.xxx.com

# Regexp para filtrar nombres de peers alternativos al preferido
# Cuando el preferido no responde o esta mas atrasado que fabric.switch.blocks.threshold
# Block-Consumer swithea a algun peer alternativo cuyo nombre 
# matchee con esta regexp
fabric.switch.peers.regexp = ".*"
fabric.switch.blocks.threshold = 10

# Nombre del channel 
fabric.channel = padfedchannel

# Archivo de configuracion con la descripcion de la Blockchain 
fabric.yaml.conf = /conf/client.yaml

# fabric.auth.type = fs: indica que block-consumer se va a autenticar con un certificado y una pk de MSP residente en el file system.
# El certificado debe ser emitido por la CA para MSP de la organizacion indicada en el archivo de configuracion ${fabric.yaml.conf} en client: organization:
fabric.auth.type = fs

fabric.channel=padfedchannel
fabric.yaml.conf=/conf/client.yaml

fabric.auth.type=fs
fabric.auth.appuser.name=User1
fabric.auth.appuser.keystore.path=/conf/crypto/client/blockconsumer"@"blockchain-tributaria.afip.gob.ar-msp.key
fabric.auth.appuser.certsign.path=/conf/crypto/client/blockconsumer"@"blockchain-tributaria.afip.gob.ar-msp.crt
fabric.tls.auth.appuser.keystore.path=/conf/crypto/client/blockconsumer"@"blockchain-tributaria.afip.gob.ar-tls-client.key
fabric.tls.auth.appuser.certsign.path=/conf/crypto/client/blockconsumer"@"blockchain-tributaria.afip.gob.ar-tls-client.crt

certificate.check.restrict=false

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

  ###############################################################################################
  # sqlserver
  # url => jdbc:jtds:sqlserver://host:port/database
  ###############################################################################################
  jtds {
    driverClassName = net.sourceforge.jtds.jdbc.Driver
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

### 6- Creá el client.yaml

En el directorio `blockconsumer/conf` tenes que crear un `client.yaml`.

El `client.yaml` es un archivo de configuración estándar de Fabric que sirve para describir la red de nodos a una aplicación.

En futuras versiones de la aplicación esta descripción no será necesaria, porque la aplicación tendrá la capacidad de descubrir la red.

Podes copiar el siguiente contenido:

```yaml
name: "Network"
version: "1.0"
x-loggingLevel: trace

client:
  # MSPID de la organización cuya CA emitio el certificado de MSP que utiliza la aplicación para conectarse a la red: XXX | YYY | ZZZ | MORGS
  organization: XXX
  logging:
    level: info

channels:
  padfedchannel:
    # Block-Consumer accede a los peers que tengan habilitado el rol ledgerQuery
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

peers:
  peer0.xxx.com:
    url: grpcs://peer0.xxx.com:7051
    tlsCACerts:
      path: conf/tlscas/tlsica.blockchain-tributaria.xxx.gob.ar-tls.crt

  peer1.xxx.com:
    url: grpcs://peer1.xxx.com:7051
    tlsCACerts:
      path: conf/tlscas/tlsica.blockchain-tributaria.xxx.gob.ar-tls.crt

  peer0.yyy.com:
    url: grpcs://peer0.yyy.com:7051
    tlsCACerts:
      path: conf/tlscas/tlsica.blockchain-tributaria.yyy.gob.ar-tls.crt

  peer1.yyy.com:
    url: grpcs://peer1.yyy.com:7051
    tlsCACerts:
      path: conf/tlscas/tlsica.blockchain-tributaria.yyy.gob.ar-tls.crt

  peer0.zzz.com:
    url: grpcs://peer0.zzz.com:7051
    tlsCACerts:
      path: conf/tlscas/tlsica.blockchain-tributaria.zzz.gob.ar-tls.crt

  peer1.zzz.com:
    url: grpcs://peer1.zzz.com:7051
   tlsCACerts:
      path: conf/tlscas/tlsica.blockchain-tributaria.zzz.gob.ar-tls.crt
```

### 7- Obtené la imagen docker de la aplicaciónv padfed/block-consumer:1.4.1

### 8- Creá un script bash para correr el contenedor

En el directorio `blockconsumer` crea un script `blockconsumer.run.sh` con el siguiente contenido:

```sh
#!/bin/bash

docker run --log-opt max-size=10m \
           --log-opt max-file=10 \
           --rm \
           --name blockconsumer \
           --tmpfs /tmp:exec \
           -v ${PWD}/conf:/conf \
           -e TZ=America/Argentina/Buenos_Aires \
           -p 8084:8084 \
           -d padfed/block-consumer:1.4.1
```

Verificá que el puerto mappeado en el comando coincida con el configurado en el `application.conf`.

Podes crear otro script para detener el contenedor `blockconsumer.stop.sh` con el siguiente contenido:

```sh
#!/bin/bash

docker stop blockconsumer
```
Alternativamente podes ejecutar la aplicacion con `docker-compose` creando un el siguiente `docker-compose.yaml`:

```yaml
version: "2"

services:
  block-consumer:
    image: padfed/block-consumer:1.4.1
    container_name: block-consumer
    environment:
      TZ=America/Argentina/Buenos_Aires
    read_only: true
    tmpfs: /tmp:exec
    working_dir: /
    volumes:
      - "./conf:/conf"
    ports:
      - "8084:8084"
    mem_limit: 512m

Logging overwrite
    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "10"
```

## Base de Datos

### Modelo de Datos

![](images/diagrama-de-entidad-relaciones.png)

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
    
### Queries sobre la base de datos que carga el Block-Consumer 

#### Queries de negocio

Si bien, Block-Consumer es una aplicación totalmente agnóstica al negocio (se puede utilizar para procesar bloques de cualquier Blockchain HLF), esta sección del doc contiene ejemplos de queries aplicables al modelo de datos del Padrón Federal. 

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
`per` | persona           | `per:20123456780#per`
`act` | actividades       | `per:20123456780#act:1.883-123456`
`imp` | impuestos         | `per:20123456780#per:20`
`dom` | domicilios        | `per:20123456780#per:1.1.1`
`dor` | domiroles   | `per:20123456780#per:1.1.1.1`
`tel` | telefonos         | `per:20123456780#per:1`
`jur` | jurisdicciones    | `per:20123456780#per:900`
`ema` | emails            | `per:20123456780#per:1`
`arc` | archivos          | :soon:
`cat` | categorias        | `per:20123456780#cat:20.12`
`eti` | etiquetas         | `per:20123456780#eti:329`
`con` | contribmunis    | `per:20123456780#con:5244.21`
`rel` | relaciones        | `per:20123456780#rel:20077799975.3.15`
`cms` | cmsedes           | `per:20123456780#cms:3`
`wit` | testigo (witness) | `per:20123456780#wit`

#### Versiones vigentes de las keys 

Para una misma key se guarda un registro cada vez que su value es modificado. 
Para recuperar la versión vigente de cada key las queries utilizan la función analítica `ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) as persona_id_row_number` seleccionado las filas cuando `persona_id_row_number = 1`.

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
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number
from hlf.bc_valid_tx_write_set i
where key like 'per:20000021629#%'
and   key not like '%#wit' -- descarta el testigo
) x
where persona_id_row_number = 1 and is_delete is null
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
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number,
is_delete
from hlf.bc_valid_tx_write_set
where key like 'per:___________#___%'
) x
where persona_id_row_number = 1
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
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number,
is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#per'
) x
where persona_id_row_number = 1 and is_delete is null
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
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#imp:%'
) x
where persona_id_row_number = 1 and is_delete is null
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
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#act:_.%'
or    key like 'per:___________#act:883-%' /* registros guardados en la testnet con versiones del chaincode anteriores a 0.5.x */   
) x
where persona_id_row_number = 1 and is_delete is null
```

``` sql
-- Domicilios jurisdiccionales (orgs entre 900 y 924)
--
select 
count(*)
from 
(
select key,  
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:9%'
) x
where persona_id_row_number = 1 and is_delete is null
```

``` sql
-- Domicilios jurisdiccionales informados por COMARB (org 900)
--
select 
count(*)
from 
(
select key,  
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number, is_delete 
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:900.%'
) x
where persona_id_row_number = 1 and is_delete is null
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
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number, is_delete
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:%' 
) x
where persona_id_row_number = 1 and is_delete is null
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
ROW_NUMBER() OVER(PARTITION BY KEY ORDER BY block desc, txseq desc) AS persona_id_row_number, 
is_delete
from hlf.bc_valid_tx_write_set
where key like 'per:___________#dom:_.%'
and   regexp_like(value, '^\{.{0,}"provincia":3(,.{1,}|\})$')
) x
where persona_id_row_number = 1 and is_delete is null
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

1.4.0
* Se permite definir un límite de memoria a la JVM utilizada dentro de la imagen docker. Se incluyen ejemplos de inicio
* Soporte de SQL Server para persistir modelo de datos. Se incorporan scripts de creación del modelo de datos para dicho motor
* Se reapunta endpoint para metricas de monitoreo desde el endpoint "/metrics" a "/blockconsumer/metrics"

1.3.1

* Conexiones jdbc: asegurar cierre de conexión cuando se producen errores en las invocaciones sql
* Fix error violates check constraint "check_valid_tx_value" en bloques que cotienen txs con deletes

1.3.0

* Script para resetear la base de datos Oracle sin necesidad de recrear los objetos
* Permite configurar tamaño máximo de bloque a consumir
* Entrypoint de monitoreo `/metrics` compatible con [Prometheus](https://prometheus.io/)
