# block-consumer - changelog

## 2.0.0

Abril 2021

* Exclusión de keys
* Registra el timestamp del bloque en BC_BLOCK.TIMESTAMP
* Modo preview, generación de CSV
* Permite configurar [options] para el comando java de openjdk:8
* Permite configurar la invocación a una función sql para verificar integridad (no recomendado para ambiente de Producción)
* Soporta values con tamaños mayores de 4 KB (no necesario para Padrón Federal)

## 1.4.1

Septiembre 2019

* bugfix: #65730 - PostgreSQL: Error al intentar insertar caracter null (0x00)

## 1.4.0

Julio 2019

* Permite definir un límite de memoria a la JVM utilizada dentro de la imagen docker.
* Soporte de SQL Server
* El endpoint para metricas de monitoreo cambia desde "/metrics" a "/blockconsumer/metrics"

## 1.3.1

Junio 2019

* Conexiones jdbc: cierra conexión cuando se produce error en invocaciones sql
* Fix error violates check constraint "check_valid_tx_value" en bloques que cotienen txs con deletes

## 1.3.0

Junio 2019

* Permite configurar tamaño máximo de bloque a consumir
* Entrypoint de monitoreo `/metrics` compatible con [`Prometheus`](https://prometheus.io/)
