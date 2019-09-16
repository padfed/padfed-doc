# PADFED Monitoreo producción v1

<br/>

## Vision de red Padfed producción v1


#### Perfil del Software a monitorear

| Software | Observaciones | nodo |
| -------- | -------- | ------ |
| RHEL |   |todos|
| docker 18.09.x |   |todos|
| docker-compose 1.21.x |   |todos|
| Hyperledger Fabric 1.4.x |   |todos|
| Certificados x509 | auth,tls  |todos|
| Endpoints GRPCs | client-peer, peer-peer  |todos|
| LevelDB files | Ledger data  |todos|

<br/>


#### Nodos AFIP

orderer0.orderer.blockchain-tributaria.afip.gob.ar:7050

peer0.blockchain-tributaria.afip.gob.ar:7051

peer1.blockchain-tributaria.afip.gob.ar:7051

</br>

### Requerimientos de monitoreo de HLF basicos


| Tipo | Observaciones | nodo |
| -------- | -------- | ------ |
| Resolucion DNS interna/externa |  | todos|
| Puertos activos | placa Interna/Externa | todos|
| Espacio en disco | definido via .env --> ${FABRIC_LEDGER_STORE_PATH} | todos |
| CPU, Memory, IO | Definir umbral de alerta | todos |



<br/>

#### Monitoreo de HLF vía CLI


| Tipo | Ejemplo | nodo |
| -------- | -------- | ------ |
| request ledgerHeight via CLI | docker exec peer0.blockchain-tributaria.testnet.afip.gob.ar.cli peer channel getinfo -c padfedchannel  |todos|
| request chaincodes instantiated via CLI | docker exec peer0.blockchain-tributaria.testnet.afip.gob.ar.cli peer chaincode list --instantiated -C padfedchannel  |peer0, peer1|
| Acceso a nodos externos | Validacion rutas y  puertos accesibles | nodos externos ARBA, COMARB |
| Expiración de certificados | Definir alerta | todos |
| Inspeccion de docker logs | Definir criterio de alerta | todos |


<br/>

### Requerimientos de monitoreo de HLF avanzados


| Tipo | Observaciones | nodo |
| -------- | -------- | ------ |
| **GET /healtz** con respuesta JSON | Requiere TLS cliente, CA independiente, Requiere nueva version de network-setup, Requiere habilitar nuevo puerto  |todos|
| Consumo metricas **Prometheus** | Requiere TLS cliente, CA independiente, Requiere nueva version de network-setup | todos  |
| **docker inspect** ***<container>*** | Requiere acceso local a los nodos | todos|



<br/>

#### Docker inspect <container>

#### Ejemplo

</br>

>docker inspect peer0.blockchain-tributaria.afip.gob.ar | jq ."[0].State"


```json
{
  "Status": "running",
  "Running": true,
  "Paused": false,
  "Restarting": false,
  "OOMKilled": false,
  "Dead": false,
  "Pid": 23994,
  "ExitCode": 0,
  "Error": "",
  "StartedAt": "2019-05-07T13:36:11.371769466Z",
  "FinishedAt": "0001-01-01T00:00:00Z"
}

        
```

<br/> 

#### Docker healthcheck

#### Ejemplo

</br>

> docker inspect peer0.blockchain-tributaria.afip.gob.ar | jq ."[0].State.Health"

```json
{
  "Status": "healthy",
  "FailingStreak": 0,
  "Log": [
    {
      "Start": "2016-09-22T23:56:33.192710692Z",
      "End": "2016-09-22T23:56:33.294607324Z",
      "ExitCode": 0,
      "Output": "{\"cluster_name\":\"elasticsearch\",\"status\":\"green\",\"timed_out\":false,\"number_of_nodes\":1,\"number_of_data_nodes\":1,\"active_primary_shards\":0,\"active_shards\":0,\"relocating_shards\":0,\"initializing_shards\":0,\"unassigned_shards\":0,\"delayed_unassigned_shards\":0,\"number_of_pending_tasks\":0,\"number_of_in_flight_fetch\":0,\"task_max_waiting_in_queue_millis\":0,\"active_shards_percent_as_number\":100.0}"
    }
  ]
}

```

<br/> 


#### Docker stats <container>

#### Ejemplo gestión de memoria del container

</br>

>docker stats --format "table {{.Name}}\t{{.Container}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}\t{{.BlockIO}}" --no-stream NOMBRE_CONTAINER



```json
NAME                                              CONTAINER                                         CPU %               MEM %               NET I/O             BLOCK I/O
peer0.blockchain-tributaria.testnet.afip.gob.ar   peer0.blockchain-tributaria.testnet.afip.gob.ar   3.48%               2.07%               1.9GB / 3.56GB      0B / 0B
        
```

<br/> 



#### Protocolo *GET /healtz*

#### Ok status

```json
{
  "status": "OK",
  "time": "2009-11-10T23:00:00Z"
}
```


#### Error status

```json
{
  "status": "Service Unavailable",
  "time": "2009-11-10T23:00:00Z",
  "failed_checks": [
    {
      "component": "docker",
      "reason": "failed to connect to Docker daemon: invalid endpoint"
    }
  ]
}
```



#### Protocolo *GET /metrics* compatible Prometheus

#### Metricas prioritarias (requiere HLF 1.4.3)

#### Orderer node

| Nombre | Descripción | Ejemplo |
| -------- | -------- | ------ |
| ledger_blockchain_height | Current ledger height|ledger_blockchain_height{channel="padfedchannel"} 23400|

<br/>

#### Peer nodes

| Nombre | Descripción | Ejemplo |
| -------- | -------- | ------ |
| ledger_blockchain_height | Current ledger height|ledger_blockchain_height{channel="padfedchannel"} 23400|
| chaincode_execute_timeouts | The number of chaincode executions (Init or Invoke) that have timed out. ||
| chaincode_launch_failures | The number of chaincode launches that have failed. | |
| endorser_successful_proposals |  The number of successful proposals | |
| endorser_endorsement_failures | The number of failed endorsements. | |
| ledger_transaction_count | ledger_transaction_count | |


#### Referencias

- Lista completa de metricas [metricas](https://hyperledger-fabric.readthedocs.io/en/release-1.4/metrics_reference.html)