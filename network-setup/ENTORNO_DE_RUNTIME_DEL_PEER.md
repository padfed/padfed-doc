# PADFED - ENTORNO DE RUNTIME DEL PEER

`NS` mediante el comando

    ./setup init peerX 

crea un directorio `$FABRIC_INSTANCE_PATH/$MSPID-peerX` conteniendo en entorno de runtime del peerX.

Para correr el peer, la sesión puede posicionarse en ese directorio y ejecutar

    docker-compose up -d

El `docker-compose` corre el peer y el cli para adminstración del peer especificados en el `docker-compose.yaml`.

El directorio `$MSPID-peerX` contiene:

| subdir                            | contenido                                                                                                                                                                                    |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`crypto-config`](#crypto-config) | [estructuras `MSP`](https://hyperledger-fabric.readthedocs.io/en/release-1.4/msp.html#msp-setup-on-the-peer-orderer-side) y material criptográfico necesario para el peer y para el admin |
| `gopath`                          | estructura para el deploy del chaincode                                                                                                                                                      |
| `.env`                            | variables de entorno referenciadas en el `docker-compose.yaml` y en los scripts de administración                                                                                            |
| `docker-compose.yaml`             | docker compose para el peer y para el cli del admin                                                                                                                                               |
| [`*.sh`](#scripts-para-administración-del-peer)                            | scripts para administración del peer                                                                                                                                                         |

## crypto-config

El subdir `crypto-config` contiene:

| subdir        | contenido                                                                                                                                                                                    |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `admin/msp`   | estructura `MSP` del admin                                                                                                                                                                     |
| `admin/tls`   | ca, key y crt para `TLS` del admin                                                                                                                                                             |
| `msp`         | estructura `MSP` del peer                                                                                                                                                                      |
| `operations`  | ca, keys y crts del peer para `OPERATIONS` como client y como server. Las credenciales como client se utilizan exclusivamente para probar localmente la correcta configuración del servicio. |
| `tls`         | ca, keys y crts del peer para `TLS` como client y como server.                                                                                                                               |
| `orderer/tls` | ca de `TLS` de la organización que corre el orderer0.                                                                                                                                          |

Ejemplo del contenido de un `fabric-instance/CBA-peer0`:

```txt
fabric-instance
└── CBA-peer0
    ├── crypto-config
    │   ├── admin
    │   │   ├── msp
    │   │   │   ├── admincerts
    │   │   │   │   └── admin@blockchain-tributaria.homo.cba.gob.ar-msp-client.crt
    │   │   │   ├── cacerts
    │   │   │   │   └── rootca.crt
    │   │   │   ├── intermediatecerts
    │   │   │   │   └── mspica.blockchain-tributaria.homo.cba.gob.ar-msp.crt
    │   │   │   ├── keystore
    │   │   │   │   └── admin@blockchain-tributaria.homo.cba.gob.ar-msp-client.key
    │   │   │   ├── signcerts
    │   │   │   │   └── admin@blockchain-tributaria.homo.cba.gob.ar-msp-client.crt
    │   │   │   ├── tlscacerts
    │   │   │   │   └── rootca.crt
    │   │   │   └── tlsintermediatecerts
    │   │   │       └── tlsica.blockchain-tributaria.homo.cba.gob.ar-tls.crt
    │   │   └── tls
    │   │       ├── ca-chain.crt
    │   │       ├── ca.crt
    │   │       ├── client.crt
    │   │       └── client.key
    │   ├── msp
    │   │   ├── admincerts
    │   │   │   └── admin@blockchain-tributaria.homo.cba.gob.ar-msp-client.crt
    │   │   ├── cacerts
    │   │   │   └── rootca.crt
    │   │   ├── config.yaml
    │   │   ├── intermediatecerts
    │   │   │   └── mspica.blockchain-tributaria.homo.cba.gob.ar-msp.crt
    │   │   ├── keystore
    │   │   │   └── peer0.blockchain-tributaria.homo.cba.gob.ar-msp-server.key
    │   │   ├── signcerts
    │   │   │   └── peer0.blockchain-tributaria.homo.cba.gob.ar-msp-server.crt
    │   │   ├── tlscacerts
    │   │   │   └── rootca.crt
    │   │   └── tlsintermediatecerts
    │   │       └── tlsica.blockchain-tributaria.homo.cba.gob.ar-tls.crt
    │   ├── operations
    │   │   ├── ca-chain.crt
    │   │   ├── ca.crt
    │   │   ├── peer-ope-client.crt
    │   │   ├── peer-ope-client.key
    │   │   ├── peer-ope-server.crt
    │   │   └── peer-ope-server.key
    │   ├── orderer
    │   │   └── tls
    │   │       └── mspica.blockchain-tributaria.afip.gob.ar-msp.crt
    │   └── tls
    │       ├── ca-chain.crt
    │       ├── ca.crt
    │       ├── peer-tls-client.crt
    │       ├── peer-tls-client.key
    │       ├── peer-tls-server.crt
    │       └── peer-tls-server.key
    ├── gopath
    │   ├── deploy
    │   ├── download
    │   └── src
    │       └── github.com
    │           └── hyperledger
    │               └── fabric
    │                   └── peer
    ├── cc.install.sh
    ├── cc.query.sh
    ├── ch.anchor.peer.update.sh
    ├── ch.fetch.block.sh
    ├── ch.join.sh
    ├── crypto.admin.export.sh
    ├── docker-compose.yaml
    └── .env
```

## scripts para administración del peer

| script                   | descripción |
| ------------------------ | ----------- |
| cc.install.sh            | instalación del chaincode
| cc.query.sh              | ejecuación del chaincode en modo query
| ch.anchor.peer.update.sh | actualización del channel para agregar el anchor peer
| ch.fetch.block.sh        | obtención de un block
| ch.join.sh               | join de un un peer al channel
| crypto.admin.export.sh   | genera un directorio `$MSPID-peerX-crypto-admin` conteniendo el material criptográfico del peer
