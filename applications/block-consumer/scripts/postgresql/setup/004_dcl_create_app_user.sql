--------------------------------------------------------
-- creater app user
--------------------------------------------------------

\c hlf_db;

CREATE USER bc_app LOGIN PASSWORD 'bc_app';

GRANT CONNECT ON DATABASE hlf_db TO bc_app;

GRANT USAGE   ON                  SCHEMA hlf TO bc_app;

GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA hlf TO bc_app;

GRANT SELECT  ON ALL TABLES    IN SCHEMA hlf TO bc_app;

GRANT INSERT  ON ALL TABLES    IN SCHEMA hlf TO bc_app;
