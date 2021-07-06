--------------------------------------------------------
-- upgrade from v1 to v2
--------------------------------------------------------

\c hlf_db;

SET SEARCH_PATH TO hlf;

--------------------------------------------------------
-- BC_BLOCK
--------------------------------------------------------
alter table bc_block add   column timestamp timestamp;

alter table bc_block alter column valid_system_txs   drop not null;

alter table bc_block alter column invalid_system_txs drop not null;

alter table bc_block alter column valid_user_txs     drop not null;

alter table bc_block alter column invalid_user_txs   drop not null;

alter table bc_block add constraint check_block_timestamp check
(
timestamp is null or timestamp < consuming_time
);

--------------------------------------------------------
-- BC_VALID_TX
--------------------------------------------------------
alter table bc_valid_tx alter column txid      drop not null;

alter table bc_valid_tx alter column chaincode drop not null;

alter table bc_valid_tx alter column function  drop not null;

alter table bc_valid_tx add   column excluded_write_keys numeric(5);

--------------------------------------------------------
-- BC_INVALID_TX
--------------------------------------------------------
alter table bc_invalid_tx alter column txid      drop not null;

alter table bc_invalid_tx alter column chaincode drop not null;

alter table bc_invalid_tx alter column function  drop not null;

alter table bc_invalid_tx add   column excluded_read_keys  numeric(5);

alter table bc_invalid_tx add   column excluded_write_keys numeric(5);

create index bc_invalid_key_idx on bc_invalid_tx_set(key);
