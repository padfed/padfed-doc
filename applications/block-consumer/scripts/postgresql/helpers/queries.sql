-- Queries exclusivos para Postgresql

-- Tiempo (en segundos) del procesamiento de los primeros 1000 bloques

SELECT max(block),
       max(consuming_time),
       min(consuming_time),
       EXTRACT(EPOCH FROM max(consuming_time)) -
       EXTRACT(EPOCH FROM min(consuming_time)) as seconds
FROM hlf.BC_BLOCK
WHERE block <= 1000
