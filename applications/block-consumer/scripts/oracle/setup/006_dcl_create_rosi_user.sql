--------------------------------------------------------
-- user for ROSi app
--------------------------------------------------------

create user bc_rosi_app identified by bc_rosi_app;

grant create session to bc_rosi_app;

grant select on hlf.bc_block              to bc_rosi_app;
grant select on hlf.bc_valid_tx           to bc_rosi_app;
grant select on hlf.bc_invalid_tx         to bc_rosi_app;
grant select on hlf.bc_valid_tx_write_set to bc_rosi_app;
grant select on hlf.bc_invalid_tx_set     to bc_rosi_app;
