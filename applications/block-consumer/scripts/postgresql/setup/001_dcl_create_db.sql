--------------------------------------------------------
-- create db
--------------------------------------------------------

CREATE USER hlf_db_owner;

ALTER ROLE hlf_db_owner CREATEROLE;

CREATE DATABASE hlf_db OWNER hlf_db_owner;

GRANT ALL ON DATABASE hlf_db TO hlf_db_owner;
