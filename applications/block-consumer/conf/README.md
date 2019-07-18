# Block-Consumer - Archivos de Configuración

Este README.md describe los archivos de configuración el material criptográfico requerido por la aplicación para conectarse a la red de Blockchain.

La disposición y los nombres de los archivos pueden modificarse mediante los archivos de configuración.

El único nombre que no se puede modificar es el del `application.conf`.

A manera de ejemplo se propone la siguiente diposición y nombres:

```
conf
|___ application.conf
|___ fabric.client.yaml
|___ store
|    |___ msp
|    |    |___ userN.orgX.msp-pk.pem
|    |    |___ userN.orgX.msp-cert.pem
|    |___ tls
|         |___ userN.orgX.tls-pk.pem
|         |___ userN.orgX.tls-cert.pem
|___ tls-root-cas
     |___ orgX.tls-root-ca.pem
     |___ orgY.tls-root-ca.pem
     |___ orgZ.tls-root-ca.pem
```

### Archivos de configuración

- **application.conf**: Es el principal archivo de configuración. Entre otras properties contiene el usuario y la password para conectarse a la base de datos, la ubicación de las credenciales de MSP para conectarse a la red de Blockchain, la ubicación y el nombre del `fabric.client.yaml`. 

    [ver archivo](application.conf)

- **fabric.client.yaml**: Es un yaml con una estructura establecida por Fabric para describir los nodos de una red de Blockchain a los que puede acceder una aplicación cliente. En el yaml a cada peer se le asignan roles. Block-Consumer accede exclusivamente a los peers que tengan habilitado el rol `ledgerQuery`. Contiene la ubicación de los certificados raíces de las CA para TLS de las organizaciones que corren peers.

    [ver archivo](fabric.client.yaml)    

### Material criptográfico

- **/conf/store/msp**: Directorio donde se ubican los archivos .pem que corresponden al par certificado/clave privada para MSP que identifica a la aplicación. El certificado debe ser emitido por la CA raiz para MSP de la organización que corre la aplicación. La organizaciones que no corren peers utilizan certificados emitidos por la organización ficticia MORGS.

- **/conf/store/tls**: Directorio donde se ubican los archivos .pem que corresponden al par certificado/clave privada para TLS que identifica a la aplicación. El certificado debe ser emitido por la CA raiz para TLS de la organización que corre la aplicación. La organizaciones que no corren peers utilizan certificados emitidos por la organización ficticia MORGS.

- **/conf/tls-root-cas**: Directorio donde se ubican los archivos .pem que corresponden a los certificados raíces de las CA para TLS de las organizaciones que corren peers.
