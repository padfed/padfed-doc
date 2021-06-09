
SELECT pg_terminate_backend(pid)
FROM   pg_stat_activity
WHERE  datname = 'hlf_db';

DROP DATABASE IF EXISTS hlf_db;

DROP USER IF EXISTS hlf_db_owner;

REVOKE ALL PRIVILEGES ON DATABASE hlf_db             FROM bc_app;

REVOKE ALL PRIVILEGES ON ALL TABLES    IN SCHEMA hlf FROM bc_app;

REVOKE ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA hlf FROM bc_app;

REVOKE ALL PRIVILEGES                  ON SCHEMA hlf FROM bc_app;

DROP USER IF EXISTS bc_app;
