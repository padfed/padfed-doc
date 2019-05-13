# PADFED Chaincode 

- Nombre: ``padfedcc``
- Versión: ``0.4.3``
- Lenguaje: Golang

Funciones:

| Nombre | Descripción | 
| --- | --- |
| putPersona | Actualiza los datos de un persona física o jurídica. Esta función puede ser ejecutada exlusivamente por AFIP. |
| putPersonas | Permite actualizar en una misma transacción datos de distintas personas. Esta función fue prevista para el setup de la red, con el objetivo de reducir el tiempo de la carga inicial de datos. |
| getPersona | Recupera el estado actual de una persona con todos sus componentes representada en un objeto json. |
| queryPersona | Recupera un resultset con un registro para cada componentes de una persona. |
| queryByKey| Recupera el valor que corresponde a una key registrada en el State |
| queryByKeyRange | Recupera un resultset con un registro para cada componentes registrado en el State cuyas key estan comprendidas en el rango |
| queryHistory | Recupera la historia de cambios de una key |
| version | Recuperala versión del chaincode