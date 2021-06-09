CREATE OR REPLACE PACKAGE hlf.bc_pkg is
--
procedure add_block(
  p_channel            varchar2,
  p_block              integer,
  p_peer               varchar2,
  p_timestamp          varchar2,
  p_consuming_time     varchar2,
  p_valid_system_txs   integer,
  p_invalid_system_txs integer,
  p_valid_user_txs     integer,
  p_invalid_user_txs   integer
);
--
procedure add_tx(
  p_block      integer,
  p_txseq      integer,
  p_txid       varchar2,
  p_type       varchar2,
  p_org_name   varchar2,
  p_timestamp  varchar2,
  p_chaincode  varchar2,
  p_function   varchar2,
  p_status     varchar2,
  p_error      varchar2,
  p_excluded_read_keys  integer,
  p_excluded_write_keys integer,
  p_set_type   varchar2,
  p_item       integer,
  p_key        varchar2,
  p_version    varchar2,
  p_value      varchar2,
  p_deleted    varchar2
  );
--
procedure add_tx_big_value(
  p_block      integer,
  p_txseq      integer,
  p_txid       varchar2,
  p_type       varchar2,
  p_org_name   varchar2,
  p_timestamp  varchar2,
  p_chaincode  varchar2,
  p_function   varchar2,
  p_status     varchar2,
  p_error      varchar2,
  p_excluded_read_keys  integer,
  p_excluded_write_keys integer,
  p_set_type   varchar2,
  p_item       integer,
  p_key        varchar2,
  p_version    varchar2,
  p_big_value  clob,
  p_deleted    varchar2
  );
--
function block_height RETURN NUMBER;
--
procedure verify(p_block integer);
--
TS_FORMAT CONSTANT varchar2(21) := 'YYYY-MM-DD HH24:MI:SS';
--
END bc_pkg;
