# PADFED Chaincode 

- Nombre: ``padfedcc``
- Versión: ``0.8.4``
- Lenguaje: Golang

Funciones:

| Nombre | Descripción | 
| --- | --- |
| PutPersona | Actualiza los datos de un persona. Esta función puede ser ejecutada exlusivamente por AFIP. |
| PutPersonaList | Permite actualizar en una misma transacción datos de distintas personas. Esta función fue prevista para el setup de la red, con el objetivo de reducir el tiempo de la carga inicial de datos y el tamaño del ledger. |
| getPersona | Recupera el estado actual de una persona con todos sus componentes representada en un objeto json. |
| queryPersona | Recupera un resultset con los registros que contienen la información de una persona. |
| queryByKey| Recupera el valor que corresponde a una key registrada en el State. |
| queryByKeyRange | Recupera un resultset con un registro para cada componente registrado en el State cuyas key estan comprendidas en el rango. |
| queryHistory | Recupera la historia de cambios de una key. |
| version | Recupera la versión del chaincode.
