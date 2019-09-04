# PADFED - MATERIAL CRIPTOGRAFICO - ESPECIFICACION

## Requisitos generales

- Infraestructura de claves publicas x509
- Certificates Authorities: Una CA raíz para cada servicio (`MSP`, `TLS`, `OPERATIONS`) o una única CA raíz con una intermedia para cada servicio. El servicio `OPERATIONS` es opcional.
- Formato de archivos `PEM`.
- Algoritmo de firmas para los certificados de las CAs: `RSA` o `ECC` (Curvas Elípticas).
- Algoritmo de firmas para los certificados de nodos, admin, aplicaciones y clientes de monitoreo: `ECC` (`RSA` no esta soportado).

## Certificados de MSP  

**Subjects**: peers, orderers, admin y aplicaciones.

Atributo | Descripción
--- | ---
`Issuer` | CA raíz o intermedia de `MSP` de la organización
`Subject.O` | Preferiblemente `DOMAIN` (ej: `blockchain-tributaria.arba.gob.ar`)
`Subject.CN` | nombre del nodo (ej: `peer0-blockchain-tributaria.arba.gob.ar`), del admin (`admin@blockchain-tributaria.arba.gob.ar`) o de la aplicación  (`blockconsumer@blockchain-tributaria.arba.gob.ar`)
`Subject.OU` | Un solo `OU` con valor `peer`, `orderer`, `admin` o `client`
`Key Usage` | `critical, Digital Signature, Key Encipherment`

## Certificados de TLS client 

**Subjects**: peers, orderers, admin y aplicaciones.

Requerido 

Atributo | Descripción
--- | ---
`Issuer` | CA raíz o intermedia de `TLS` de la organización
`Subject.O` | Preferiblemente `DOMAIN` 
`Subject.CN` | nombre del nodo, del admin, o de la aplicación 
`Key Usage` | `critical, Digital Signature, Key Encipherment`
`Extended Key Usage` | `TLS Web Client Authentication`

## Certificados de TLS server

**Subjects**: peers y orderers

Atributo | Descripción
--- | ---
`Issuer` | CA raíz o intermedia de `TLS` de la organización
`Subject.O` | Preferiblemente `DOMAIN`
`Subject.CN` | nombre del nodo
`Key Usage` | `critical, Digital Signature, Key Encipherment`
`Extended Key Usage` | `TLS Web Server Authentication`
`Subject Alternative Name` | `DNS:<nombre del nodo>` (ej: `DNS:peer0-blockchain-tributaria.arba.gob.ar`)

## Certificados de OPERATIONS para clientes de monitoreo (opcional)

**Subjects**: clientes de monitoreo

Atributo | Descripción
--- | ---
`Issuer` | CA raíz o intermedia de `TLS` de la organización
`Subject.O` | Preferiblemente `DOMAIN`
`Subject.CN` | nombre del operador (ej: `oper1@blockchain-tributaria.arba.gob.ar`)
`Key Usage` | `critical, Digital Signature, Key Encipherment`
`Extended Key Usage` | `TLS Web Client Authentication`

## Certificados de OPERATIONS para servidores

**Subjects**: peers y orderers

Atributo | Descripción
--- | ---
`Issuer` | CA raíz o intermedia de `TLS` de la organización
`Subject.O` | Preferiblemente `DOMAIN`
`Subject.CN` | nombre del nodo
`Key Usage` | `critical, Digital Signature, Key Encipherment`
`Extended Key Usage` | `TLS Web Server Authentication`
`Subject Alternative Name` | `DNS:<nombre del nodo>`

## Emisión de requests CSR con openssl

`NS` para creación de claves ECC y de requests CSR utiliza los siguientes comandos:

    openssl ecparam -name prime256v1 -genkey -noout -out ./crypto-stage/CBA-peer0/peer0.blockchain-tributaria.homo.cba.gob.ar-msp-server.1

    openssl pkcs8 -topk8 -nocrypt -in ./crypto-stage/CBA-peer0/peer0.blockchain-tributaria.homo.cba.gob.ar-msp-server.1 -out ./crypto-stage/CBA-peer0/peer0.blockchain-tributaria.homo.cba.gob.ar-msp-server.key

    openssl req -new -subj /C=AR/O=blockchain-tributaria.homo.cba.gob.ar/OU=peer/CN=peer0.blockchain-tributaria.homo.cba.gob.ar -key ./crypto-stage/CBA-peer0/peer0.blockchain-tributaria.homo.cba.gob.ar-msp-server.key -out ./crypto-stage/CBA-peer0/peer0.blockchain-tributaria.homo.cba.gob.ar-msp-server.request


## Ejemplos de certificados:

**MSPID**: `AFIP`

**DOMAIN**: `blockchain-tributaria.homo.afip.gob.ar`

**CA_MODE**: `INTERMEDIATECAS` (Una intermedia para cada servicio)

- `MSP`: `CN = mspica.blockchain-tributaria.homo.afip.gob.ar`
- `TLS`: `CN = tlsica.blockchain-tributaria.homo.afip.gob.ar`
- `OPERATIONS`: `CN = opeica.blockchain-tributaria.homo.afip.gob.ar`

### MSP para peer0

```txt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 2 (0x2)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, CN = mspica.blockchain-tributaria.homo.afip.gob.ar
        Validity
            Not Before: Sep  3 14:57:57 2019 GMT
            Not After : Sep  2 14:57:57 2023 GMT
        Subject: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, OU = peer, CN = peer0.blockchain-tributaria.homo.afip.gob.ar
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:5f:f5:69:f3:e9:65:53:9e:71:b9:09:38:72:5d:
                    12:f2:fa:ed:af:15:47:09:e7:9e:f8:21:2e:e4:84:
                    97:90:28:c6:cd:aa:ec:a3:bc:53:e7:9c:24:0d:da:
                    7c:f5:ff:85:81:57:f8:1e:4f:5f:e7:b1:63:d2:cc:
                    bc:ef:e5:09:36
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                8C:6E:DD:48:FB:BE:D1:07:67:8B:45:64:BB:9A:5E:8B:74:2A:3C:16
            X509v3 Authority Key Identifier: 
                keyid:48:55:89:3F:8C:71:58:A2:3C:70:4A:29:1A:72:45:A9:96:36:C2:02

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
    Signature Algorithm: ecdsa-with-SHA256
         30:44:02:20:62:1a:1f:a1:0b:e8:d1:fb:64:b1:1b:e1:39:6b:
         72:54:33:ed:9b:dd:30:c6:69:d6:60:6f:5f:fd:db:09:a9:9a:
         02:20:3b:37:ba:0c:71:ca:22:32:eb:3f:b6:ab:67:14:6f:3b:
         b3:6b:e2:41:a7:57:3a:55:9c:e2:9d:92:ce:51:54:4e
```

### MSP para el admin de la orgnanización

```txt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, CN = mspica.blockchain-tributaria.homo.afip.gob.ar
        Validity
            Not Before: Sep  3 14:56:41 2019 GMT
            Not After : Sep  2 14:56:41 2021 GMT
        Subject: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, OU = admin, CN = admin@blockchain-tributaria.homo.afip.gob.ar
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:34:4f:54:1c:b3:32:46:fa:3b:79:ae:3a:69:68:
                    6e:d6:30:39:9f:bd:61:41:c1:90:ba:0d:1f:66:56:
                    37:a4:f9:2b:ba:c7:ad:00:0c:ff:9d:63:f2:3b:35:
                    9f:f3:83:59:bc:ad:30:5e:b9:02:5e:9b:86:5f:30:
                    3c:d8:3b:0e:15
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                C4:D4:03:20:F9:C6:D6:38:10:09:65:21:3C:C1:60:60:2B:AD:C9:55
            X509v3 Authority Key Identifier: 
                keyid:48:55:89:3F:8C:71:58:A2:3C:70:4A:29:1A:72:45:A9:96:36:C2:02

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
    Signature Algorithm: ecdsa-with-SHA256
         30:45:02:20:42:90:ca:f5:84:2f:b3:67:f6:0c:9d:05:ce:a8:
         6a:7c:78:26:c0:75:b9:e8:93:75:b6:2a:40:9d:03:d8:a0:97:
         02:21:00:d7:89:4e:65:e6:a5:63:43:03:9c:7d:39:cc:0e:0c:
         12:1e:01:1d:57:be:f1:0c:77:58:7c:94:77:1d:cd:25:49
```

### MSP para la aplicación blockconsumer

```txt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 4 (0x4)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, CN = mspica.blockchain-tributaria.homo.afip.gob.ar
        Validity
            Not Before: Sep  3 15:13:28 2019 GMT
            Not After : Sep  2 15:13:28 2021 GMT
        Subject: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, OU = client, CN = blockconsumer@blockchain-tributaria.homo.afip.gob.ar
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:a5:f6:89:15:9d:74:f7:a7:40:21:c0:2c:8d:89:
                    10:a0:fa:52:7d:71:a0:56:ea:5d:33:12:e9:64:14:
                    1d:2b:e7:f8:d6:0e:5e:75:c9:07:c2:35:ae:fc:0d:
                    46:99:54:fd:f1:86:0f:f8:49:e1:a1:aa:6a:2c:6d:
                    e3:bb:0e:51:59
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                9D:81:3B:3E:BE:37:11:9B:8B:01:3D:82:39:27:50:4F:33:3A:74:0A
            X509v3 Authority Key Identifier: 
                keyid:48:55:89:3F:8C:71:58:A2:3C:70:4A:29:1A:72:45:A9:96:36:C2:02

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
    Signature Algorithm: ecdsa-with-SHA256
         30:44:02:1f:27:ac:27:10:04:2f:e6:a4:9e:52:47:f2:58:14:
         db:fd:96:cf:fd:0d:1a:75:49:8c:1e:a9:da:2d:cb:63:fb:02:
         21:00:c7:61:48:74:07:1f:f9:b1:fd:29:8f:7e:73:f6:b1:b0:
         f5:24:09:9e:9a:9c:d1:00:c2:4b:b3:67:c5:21:3b:3f
```

### TLS client para peer0

```txt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 3 (0x3)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, CN = tlsica.blockchain-tributaria.homo.afip.gob.ar
        Validity
            Not Before: Sep  3 14:57:57 2019 GMT
            Not After : Sep  2 14:57:57 2021 GMT
        Subject: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, OU = peer, CN = peer0.blockchain-tributaria.homo.afip.gob.ar
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:5c:00:f4:6b:7f:23:a6:94:66:50:f8:f9:75:e3:
                    39:a2:62:e5:c4:c8:00:14:12:51:f9:a9:78:02:45:
                    7d:32:0f:54:51:21:91:cd:c3:67:15:05:b1:ea:21:
                    b9:aa:e0:8d:3b:cb:23:9a:71:2d:a5:40:29:69:33:
                    a7:a8:9a:87:c0
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                1D:39:BA:61:89:93:2B:9E:29:C4:2E:E1:20:E5:14:7B:EC:DF:51:16
            X509v3 Authority Key Identifier: 
                keyid:88:FE:4F:41:C7:CA:94:73:40:05:3D:D1:0B:01:27:DF:2F:79:30:A9

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
    Signature Algorithm: ecdsa-with-SHA256
         30:46:02:21:00:87:18:3b:2f:65:3d:a8:bd:bd:ed:6d:e7:89:
         51:98:3f:de:b7:03:8d:df:66:99:b6:55:55:4e:f7:05:41:19:
         45:02:21:00:84:7e:9a:fc:ce:22:23:d4:10:73:40:8d:a8:d4:
         1a:e9:9f:5c:e6:23:d6:5e:20:87:6b:42:21:6d:23:2d:f2:0c
```

### TLS server para peer0

```txt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 4 (0x4)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, CN = tlsica.blockchain-tributaria.homo.afip.gob.ar
        Validity
            Not Before: Sep  3 14:57:57 2019 GMT
            Not After : Sep  2 14:57:57 2023 GMT
        Subject: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, OU = peer, CN = peer0.blockchain-tributaria.homo.afip.gob.ar
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:b6:14:bc:40:51:3f:38:1b:dd:9b:98:37:30:ae:
                    8a:21:61:39:8f:11:d5:cf:3e:13:48:5e:5d:69:b8:
                    dc:84:ab:cf:8c:09:dc:49:e5:b6:45:1f:4f:15:82:
                    25:3d:b7:77:7f:96:50:bc:9f:79:44:c7:5c:18:da:
                    9d:4c:24:f5:ae
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                8F:20:02:15:60:B0:A3:A8:D3:5F:BE:01:97:57:C8:F9:49:6C:2B:BF
            X509v3 Authority Key Identifier: 
                keyid:88:FE:4F:41:C7:CA:94:73:40:05:3D:D1:0B:01:27:DF:2F:79:30:A9

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Subject Alternative Name: 
                DNS:peer0.blockchain-tributaria.homo.afip.gob.ar
    Signature Algorithm: ecdsa-with-SHA256
         30:44:02:20:03:31:3c:22:97:28:43:ff:1f:7d:99:8a:7b:fb:
         31:9f:b9:09:5e:3c:7f:b7:92:70:af:ca:53:a4:1e:3f:4e:be:
         02:20:45:3e:d3:f3:ab:f5:f1:87:d6:d0:41:ef:8c:98:77:51:
         7b:62:da:5f:30:3f:2e:0f:41:ab:9f:00:d1:41:10:81
```

# OPERATIONS para cliente de monitoreo oper1

```txt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 4 (0x4)
        Signature Algorithm: ecdsa-with-SHA256
        Issuer: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, CN = opeica.blockchain-tributaria.homo.afip.gob.ar
        Validity
            Not Before: Sep  3 15:13:27 2019 GMT
            Not After : Sep  2 15:13:27 2021 GMT
        Subject: C = AR, O = blockchain-tributaria.homo.afip.gob.ar, OU = oper, CN = oper1@blockchain-tributaria.homo.afip.gob.ar
        Subject Public Key Info:
            Public Key Algorithm: id-ecPublicKey
                Public-Key: (256 bit)
                pub:
                    04:b8:e8:76:11:38:56:a3:c5:a2:57:53:de:fb:89:
                    c6:16:58:43:89:ad:c5:22:67:33:90:33:18:5b:4d:
                    f9:03:26:4c:de:ce:62:66:6b:6e:96:cf:88:14:d6:
                    97:ac:5b:63:7e:b8:f7:dd:c4:2c:32:b5:72:74:18:
                    38:41:3b:6c:e6
                ASN1 OID: prime256v1
                NIST CURVE: P-256
        X509v3 extensions:
            X509v3 Basic Constraints: critical
                CA:FALSE
            X509v3 Subject Key Identifier: 
                9F:03:E7:F2:53:E2:3C:A2:06:F5:EB:DA:B8:F8:BC:26:60:A1:E9:AB
            X509v3 Authority Key Identifier: 
                keyid:14:70:99:05:37:DD:1B:FA:A6:95:CC:84:6C:A9:BC:7B:02:80:D4:94

            X509v3 Key Usage: critical
                Digital Signature, Key Encipherment
            X509v3 Extended Key Usage: 
                TLS Web Client Authentication
    Signature Algorithm: ecdsa-with-SHA256
         30:46:02:21:00:a4:24:6a:4d:56:65:8b:8c:4b:2b:e5:9f:88:
         0c:88:42:96:ba:1d:ae:10:c3:12:9a:b6:9d:b5:1c:85:4a:70:
         91:02:21:00:d2:77:88:e3:6a:27:6e:bb:ef:36:19:26:0f:2f:
         cf:60:c2:88:b3:43:83:19:a3:c7:49:ad:5d:fe:9b:e7:39:b6
```
