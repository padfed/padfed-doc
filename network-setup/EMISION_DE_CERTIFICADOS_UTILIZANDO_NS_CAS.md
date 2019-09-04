# EMISION DE CERTIFICADOS UTILIZANDO NS CAS

## Creación de CAs utilizando NS

`NS` utiliza el comando [`openssl ca`](https://www.openssl.org/docs/man1.0.2/man1/ca.html).

Se puede utilizar `NS` para crear CAs de prueba o para Producción con los recaudos indicados en la documentación de `openssl`.

Para crear las CAs, `NS` utiliza las opciones de configuración disponibles en `setup.conf`:

| opción               | descripción                                                                  |
| -------------------- | ---------------------------------------------------------------------------- |
| `CAS_INSTANCES_PATH` | Directorio donde se crearán las bases de las CAs. Default: `./cas-instances` |
| `ROOTCA_CN`          | CN de la root CA en caso que `CA_MODE` se establezca en `INTERMEDIATECAS`.   |
| `CA_CRT_DAYS`        | Días de vigencia de los certificados de las CAs.                             |
| `SERVER_CRT_DAYS`    | Días de vigencia de los certificados de los servers.                         |
| `CLIENT_CRT_DAYS`    | Días de vigencia de los certificados de los clients.  

Para crear las CAs se puede copiar el proyecto `prod` en un equipo linux con `openssl` y ejecutar:

    ./setup.sh cas

Con `CA_MODE=ROOTCAS` el comando crea 3 CAs raíces.

```
$CAS_INSTANCES_PATH
└── CBA
    ├── msp
    ├── ope
    └── tls
```

Con `CA_MODE=ROOTCAS` crea una CA raíz y 3 intermedias.

```
$CAS_INSTANCES_PATH
└── CBA
    ├── msp
    ├── ope
    ├── root
    └── tls
```

Si las CAs ya se encuentran creadas `NS` va a advertilo.

## Emisión de certificados

Para emitir certificado se puede copiar desde el peer el directorio `$MSPID-peerX-crypto-requests` generado mediante el comando:

    ./setup.sh make_requests

El el equipo donde se crearon las CAs ejecutar:

    ./setup.sh process_requests <path al directorio donde están los requests>

El comando busca requests en el directorio que recibe como argumento y emite sus correspondientes certificados y los copia en un directorio `$MSPID-peerX-crypto-requests-crt`.

Una vez emitidos los certificados se puede copiar el directorio `$MSPID-peerX-crypto-requests-crt` al peer que generó los requests para continuar con la instalación mediante el comando:

    ./setup.sh init peerX

`setup.sh` esta preparado para trabajar con material cryptográfico que cumpla con la convención de nombres de archivos especificada en [MATERIAL_CRIPTOGRAFICO_NOMBRES_ARCHIVOS](MATERIAL_CRIPTOGRAFICO_NOMBRES_ARCHIVOS.md).
