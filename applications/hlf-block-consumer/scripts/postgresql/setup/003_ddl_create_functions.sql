\c hlf_db;

--------------------------------------------------------
-- ADD_BLOCK
--------------------------------------------------------
create or replace function hlf.add_block(
  p_channel            varchar,
  p_block              integer,
  p_peer               varchar,
  p_timestamp          varchar,
  p_consuming_time     varchar,
  p_valid_system_txs   integer,
  p_invalid_system_txs integer,
  p_valid_user_txs     integer,
  p_invalid_user_txs   integer
) returns void as $$
declare
  --
  TS_FORMAT constant varchar(21) := 'YYYY-MM-DD HH24:MI:SS';
  --
begin
  --
  insert into hlf.bc_block
  (
  block,
  channel,
  peer,
  timestamp,
  consuming_time,
  valid_system_txs,
  invalid_system_txs,
  valid_user_txs,
  invalid_user_txs
  )
  values
  (
  p_block,
  p_channel,
  p_peer,
  to_timestamp(p_timestamp, TS_FORMAT),
  to_timestamp(p_consuming_time, TS_FORMAT),
  nullif(p_valid_system_txs, 0),
  nullif(p_invalid_system_txs, 0),
  nullif(p_valid_user_txs, 0),
  nullif(p_invalid_user_txs, 0)
  );
end;
$$ language plpgsql
   SECURITY INVOKER;

--------------------------------------------------------
-- ADD_TX
--------------------------------------------------------
create or replace function hlf.add_tx(
  p_block      integer,
  p_txseq      integer,
  p_txid       varchar,
  p_type       varchar,
  p_org_name   varchar,
  p_timestamp  varchar,
  p_chaincode  varchar,
  p_function   varchar,
  p_status     varchar,
  p_error      varchar,
  p_excluded_read_keys  integer,
  p_excluded_write_keys integer,
  p_set_type   varchar,
  p_item       integer,
  p_key        varchar,
  p_version    varchar,
  p_value      varchar,
  p_is_deleted varchar
) returns void as $$
declare
  --
  TS_FORMAT constant varchar(21) := 'YYYY-MM-DD HH24:MI:SS';
  --
v_is_valid constant boolean := case when upper(substr(p_status, 1, 1)) = 'V' then true else false end;
--
begin
--
if p_item = 0 then
   --
   if v_is_valid then
      --
      insert into hlf.bc_valid_tx
      (
      block,
      txseq,
      txid,
      org_name,
      timestamp,
      chaincode,
      function,
      excluded_write_keys
      )
      values
      (
      p_block,
      p_txseq,
      nullif(p_txid, ''),
      p_org_name,
      TO_TIMESTAMP(p_timestamp, TS_FORMAT),
      p_chaincode,
      p_function,
      nullif(p_excluded_write_keys, 0)
      );
   else
      insert into hlf.bc_invalid_tx
      (
	   block,
	   txseq,
      txid,
      org_name,
      timestamp,
      chaincode,
      function,
      excluded_read_keys,
      excluded_write_keys,
      error
      )
      values
      (
      p_block,
      p_txseq,
      nullif(p_txid, ''),
      p_org_name,
      TO_TIMESTAMP(p_timestamp, TS_FORMAT),
      p_chaincode,
      p_function,
      nullif(p_excluded_read_keys, 0),
      nullif(p_excluded_write_keys, 0),
      p_error
      );
   end if;
end if;
--
if  p_key is null then
    return;
end if;
--
if v_is_valid then
   --
   insert into hlf.bc_valid_tx_write_set
   (
   block,
	txseq,
   item,
   key,
   value,
   is_delete
   )
   values
   (
   p_block,
   p_txseq,
   p_item,
   p_key,
   p_value,
   p_is_deleted
   );
else
   insert into  hlf.bc_invalid_tx_set
   (
   block,
	txseq,
   type,
   item,
   key,
   version,
   value,
   is_delete
   )
   values
   (
   p_block,
   p_txseq,
   p_set_type,
   p_item,
   p_key,
   p_version,
   p_value,
   p_is_deleted
   );
end if;
--
end;
$$ language plpgsql
   SECURITY INVOKER;

--------------------------------------------------------
-- BLOCK_HEIGHT
--------------------------------------------------------
create or replace function hlf.block_height()
returns integer as $$
declare
   --
   blockHeight integer;
   --
begin
   select coalesce(max(block),-1)
   into blockHeight
   from hlf.bc_block;
   --
   return blockHeight;
   --
exception
   when others then
        raise exception 'select max(block) - % %', SQLSTATE, SQLERRM;
end;
$$ language plpgsql
   SECURITY INVOKER;
