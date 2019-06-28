
1.  Conocer toda la información obrante en blockchain
   
    Modelo de datos y estimación de volumne disponible en
    https://github.com/padfed/padfed-doc/tree/master/model

1.  Ventajas de obtener la información a través de la blockchain 
    ( Y no usar el mecanismo actual de archivo XML de padrón web ): más información, velocidad de acceso, etc.

    - Acceso a todo el Padrón Federal (15.5 millones de contribuyentes)

    - Disponibilidad de información en casi tiempo real.

    - Existe un único repositorio al que todos tienen acceso.
  
        - Elimina de la necesidad de generar procesos periódicos o eventuales de conciliación o de reenvíos de información para resolver problemas de pérdida o errores de procesamiento de datos.

        - Consenso entre los participantes sobre cuál es el contenido histórico y el estado actual de la información compartida.

    - El repositorio está replicado. Mejora la disponibilidad de la información. Disminuye la dependencia de los sistemas informáticos de las agencias de recaudación provinciales con el sistema de AFIP.

1.  Posibilidad de ir bajando información parcializada de blockchain

    Pendiente: Entender mejor el requerimiento.

1.  Tecnología o lenguaje que usaron y recomiendan usar para la lectura de la información obrante en blockchain

    Opciones:

    - Utilizando las aplicaciones de integración que ofrece AFIP.
      - **Block-Consumer**: copia el Ledger en una base de datos relacional. Se puede leer con cualquier lengueja de programación.
      - **HLF-Proxy**: para efectuar consultas puntuales o transaccionar contra la Blockchain mediante una interfaz REST. Se puede utilizar cualquier lenguaje de programación.
  
    - Desarrollando aplicaciones propias utilizando los SDK que ofrece Fabric para Java, Go, JavaScript.
      - AFIP ofrece el codigo fuente de sus aplicaciones Block-Consumer y HLF-Proxy y de una tool desarrollada en Go.

1.  Repaso de la Estructura de archivos y set de datos, contribuyentes locales, monotributistas y convenio.

    Modelo de datos y estimación de volumne disponible en https://github.com/padfed/padfed-doc/tree/master/model

1.  Demo  de información y circuitos por parte de AFIP y CA , con el acceso a la Blockchain de prueba (Testnet) funcionando con nodos en AFIP, ARBA y COMARB.

1.  Plazos en que dispondrá de la información en blockchain y de los tramites por xml
   
    - En la Blockchain los cambios que se producen desde el sistema de AFIP se propagan en casi tiempo real.
    - Para la carga inicial se prevee un setup de entre 12 y 24 hs.

1.  Conocer experiencia CA en desarrollo y de obtener información de blockchain

1.  Respecto a ser nodo los siguientes puntos:
    1. Beneficios y perjuicios sobre disponibilidad de un nodo local.

       Beneficios:
       - Mejor tiempo de respuesta en lecturas, consumo de bloques.
       - Posibilidad de crear canales privados con otras organizaciones que tambien corren nodos.

        Perjuicios:

        NOTA: Lo interperamos como "costos" 

       - Dedicar equipos (por lo menos uno para Testnet y recomenadado dos para Producción) expuestos a internet.
       - Gestión de certificados: Disponer de Root CA para MSP y para TLS, para Testnet v2 y para Producción
       - Ancho de banda.
       - Tareas de operaciones: Upgrade de chaincode, actualización de material criptográfico. 
       - Monitoreo de equipo: espacio disponible, consumo de RAM, consumo de CPU. 

    2. Supuestos y restricciones de ser miembro de la red como nodo. 

        
     

    3. Capacidades esperadas ( si difieren de las mínimas ) físicas de los equipos.

        No difieren de las espcificadas en https://github.com/padfed/padfed-doc/tree/master/overview#configuación-equipos-peers. 

    1. Conectividad dedicada comprometida.

        7 x 24

        La red es resiliente, los equipos momentaneamente puede quedar fuera de línea. Cuando se reinician se sincronizan con el resto de los peers. Las aplicaciones debiera estar preparadas para conectarse a cualquiera de los peers disponibles.

    2. Modalidades y alcance del soporte brindado por AFIP.

        Inicialmente el soporte lo brinda el Equipo de Blockchain de AFIP.

        La idea es que las organizaciones que corren peers se capaciten en Fabric puedan colaborar con el soporte.
