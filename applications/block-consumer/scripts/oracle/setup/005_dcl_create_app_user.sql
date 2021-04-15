--------------------------------------------------------
-- user for Block-Consumer app
--
--
-- bc_app is the database user that block-consumer will use to connect to the database.
-- bc_app only needs a grant to execute the bc_pck package.
--------------------------------------------------------

create user bc_app identified by bc_app;

grant create session to bc_app;

grant execute on hlf.bc_pkg to bc_app;
