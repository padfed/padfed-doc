#!/bin/bash

echo "Executing SQL scripts ... $0"

psql -U postgres -f 001_dcl_create_db.sql

psql -d hlf_db -U hlf_db_owner -f 002_ddl_create_schema.sql

psql -d hlf_db -U hlf_db_owner -f 003_ddl_functions.sql

psql -d hlf_db -U hlf_db_owner -f 004_dcl_create_app_user.sql

# psql -d hlf_db -U hlf_db_owner -f 005_ddl_upgrade_to_v2.sql
