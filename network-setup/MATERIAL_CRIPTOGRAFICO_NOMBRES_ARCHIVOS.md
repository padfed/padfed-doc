# PADFED - MATERIAL CRIPTOGRAFICO - CONVENCION DE NOMBRES DE ARCHIVOS

`NS` para configurar un peer requiere que el material cryptográfico esta copiado en el directorio `$CRYPTO_STAGE_PATH/$MSPID-peer0` y que respete determinados patrones de nombres descriptos a continuación.

Opcionalmente se puede utilizar nombres arbitrarios, indicándolos en el archivo [`$CRYPTO_STAGE_PATH/$MSPID-peer0/index.conf`](#index.conf)

El comando `setup.sh init peerX` de `NS` utiliza el `index.conf` para buscar el material criptográfico y copiarlo al [entorno de runtime del peer](ENTORNO_DE_RUNTIME_DEL_PEER.md).

## Certificados de las CAs

Opción: Una CA raíz para cada servicio:

- `tlsca.[DOMAIN]-tls.crt`
- `mspca.[DOMAIN]-msp.crt`
- `opeca.[DOMAIN]-ope.crt`

Opción: Una única CA raiz con intermedias para cada servicio:

- `rootca.[crt]`
- `tlsica.[DOMAIN]-tls.crt`
- `mspica.[DOMAIN]-msp.crt`
- `opeica.[DOMAIN]-ope.crt`

## Material criptográfico para nodos, admin, aplicaciones y clientes de monitoreo

`[Subject.CN]-[msp|tls|ope]-[server|client].[key|crt]`

## Ejemplos

### Material del peer0

```txt
peer0.blockchain-tributaria.homo.afip.gob.ar-msp-server.key
peer0.blockchain-tributaria.homo.afip.gob.ar-msp-server.crt
peer0.blockchain-tributaria.homo.afip.gob.ar-tls-server.key
peer0.blockchain-tributaria.homo.afip.gob.ar-tls-server.crt
peer0.blockchain-tributaria.homo.afip.gob.ar-tls-client.key
peer0.blockchain-tributaria.homo.afip.gob.ar-tls-client.crt
peer0.blockchain-tributaria.homo.afip.gob.ar-ope-server.key
peer0.blockchain-tributaria.homo.afip.gob.ar-ope-client.crt
```

### Material del admin de la organización

```txt
admin@blockchain-tributaria.afip.homo.gob.ar-msp-client.key
admin@blockchain-tributaria.afip.homo.gob.ar-msp-client.crt
admin@blockchain-tributaria.afip.homo.gob.ar-tls-client.key
admin@blockchain-tributaria.afip.homo.gob.ar-tls-client.crt
```

### Material de una aplicación

```txt
blockconsumer@blockchain-tributaria.homo.afip.gob.ar-msp-client.key
blockconsumer@blockchain-tributaria.homo.afip.gob.ar-msp-client.crt
blockconsumer@blockchain-tributaria.homo.afip.gob.ar-tls-client.key
blockconsumer@blockchain-tributaria.homo.afip.gob.ar-tls-client.crt
```

### Material de un cliente de monitoreo

```txt
ope1@blockchain-tributaria.afip.homo.gob.ar-ope-client.key
ope1@blockchain-tributaria.afip.homo.gob.ar-ope-client.crt
```

## index.conf

`index.conf` es un archivo de configuración generado atomaticamente por `NS`.

Contiene pares `nombre=path` para cada material cryptográfico requerido por el nodo.

- elementos de las CAs

    `[MSP|TLS|OPE]_[CA|ICA]_[KEY|CRT]`

- elementos del admin de la organización

    `ADMIN_[MSP|TLS]_[KEY|CRT]`

- elementos del nodo

    `NODE_[MSP|TLS|TLS_CLIENT|OPE|OPE_CLIENT]_[KEY|CRT]`

En caso que el material criptográfico no respete los patrones de nombres especificados en este doc, el usuario instalador puede crear `index.conf` y configurar los nombres de archivos.

Una vez editado el `index.conf` se puede procesar a ejecutar:

    ./setup init peer0

Este comando al detectar que ya existe un `index.conf` va a utilizarlo. En caso que no exista lo va generarlo para lo cual requiere que los archivos en respeten el patrón de nombres establecido.

Ejemplo de `index.conf`:

```conf
#########################################################
# Archivo generado por node.crypto.index.sh

# Certificados raices de las CAs de la propia Org
MSP_CA_CRT=./crypto-stage/AFIP-peer0/cacerts/rootca.crt
TLS_CA_CRT=./crypto-stage/AFIP-peer0/cacerts/rootca.crt
OPE_CA_CRT=./crypto-stage/AFIP-peer0/cacerts/rootca.crt
MSP_ICA_CRT=./crypto-stage/AFIP-peer0/cacerts/mspica.blockchain-tributaria.homo.afip.gob.ar-msp.crt
TLS_ICA_CRT=./crypto-stage/AFIP-peer0/cacerts/tlsica.blockchain-tributaria.homo.afip.gob.ar-tls.crt
OPE_ICA_CRT=./crypto-stage/AFIP-peer0/cacerts/opeica.blockchain-tributaria.homo.afip.gob.ar-ope.crt

# Material criptografico del Admin de la Org
ADMIN_MSP_KEY=./crypto-stage/AFIP-peer0/admin@blockchain-tributaria.homo.afip.gob.ar-msp-client.key
ADMIN_MSP_CRT=./crypto-stage/AFIP-peer0/admin@blockchain-tributaria.homo.afip.gob.ar-msp-client.crt
ADMIN_TLS_KEY=./crypto-stage/AFIP-peer0/admin@blockchain-tributaria.homo.afip.gob.ar-tls-client.key
ADMIN_TLS_CRT=./crypto-stage/AFIP-peer0/admin@blockchain-tributaria.homo.afip.gob.ar-tls-client.crt

# Material criptografico del Node
NODE_MSP_KEY=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-msp-server.key
NODE_MSP_CRT=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-msp-server.crt
NODE_TLS_KEY=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-tls-server.key
NODE_TLS_CRT=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-tls-server.crt
NODE_TLS_CLIENT_KEY=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-tls-client.key
NODE_TLS_CLIENT_CRT=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-tls-client.crt
NODE_OPE_KEY=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-ope-server.key
NODE_OPE_CRT=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-ope-server.crt
NODE_OPE_CLIENT_KEY=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-ope-client.key
NODE_OPE_CLIENT_CRT=./crypto-stage/AFIP-peer0/peer0.blockchain-tributaria.homo.afip.gob.ar-ope-client.crt
```
