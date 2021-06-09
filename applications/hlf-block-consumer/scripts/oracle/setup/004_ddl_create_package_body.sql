CREATE OR REPLACE PACKAGE BODY hlf.bc_pkg is
--
v_db_channel varchar2(100);
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
) is
begin
  --
  if    v_db_channel is null then
        v_db_channel := p_channel;
  elsif v_db_channel != p_channel then
        raise_application_error(-20001, 'DB Channel [' || v_db_channel || '] arg Channel [' || p_channel || '] !!!!');
  end if;
  --
  insert into bc_block
  (
  channel,
  block,
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
  p_channel,
  p_block,
  p_peer,
  to_date(p_timestamp, TS_FORMAT),
  to_date(p_consuming_time, TS_FORMAT),
  nullif(p_valid_system_txs, 0),
  nullif(p_invalid_system_txs, 0),
  nullif(p_valid_user_txs, 0),
  nullif(p_invalid_user_txs, 0)
  );
end add_block;
--
procedure add_tx_2(
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
  p_big_value  varchar2,
  p_deleted    varchar2
) is
--
v_is_valid constant boolean := case when upper(substr(p_status, 1, 1)) = 'V' then true else false end;
v_statement varchar2(100);
--
begin
--
if p_item > 0 and coalesce(p_txid, p_type, p_org_name, p_timestamp, p_chaincode, p_function, p_excluded_read_keys, p_excluded_write_keys) is not null then
   raise_application_error(-20002, 'p_item [' || p_item || '] > 0' ||
                              ' and (p_txid [' || p_txid ||
                              '] or p_type [' || p_type ||
                              '] or p_org_name [' || p_org_name ||
                              '] or p_timestamp [' || p_timestamp ||
                              '] or p_chaincode [' || p_chaincode ||
                              '] or p_function [' || p_function ||
                              '] or p_excluded_read_keys [' || p_excluded_read_keys ||
                              '] or p_excluded_write_keys [' || p_excluded_write_keys || ']) is not null');
end if;
--
if p_item = 0 then
   --
   if  p_type = 'U' then
       if  p_txid is null then
           raise_application_error(-20003, 'p_type U(user) must have p_txid');
       end if;
       --
       if  p_chaincode is null then
           raise_application_error(-20004, 'p_type U(user) must have p_chaincode');
       end if;
       --
       if  p_function is null then
           raise_application_error(-20005, 'p_type U(user) must have p_function');
       end if;
       --
   elsif nvl(p_type, 'x') != 'S' then
         raise_application_error(-20006, 'p_type [' || p_type || '] must be U(user)|S(system)');
   end if;
   --
   if v_is_valid then
      --
      v_statement :=
     'insert into bc_valid_tx';
      insert into bc_valid_tx
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
      p_txid,
      p_org_name,
      to_date(p_timestamp, TS_FORMAT),
      p_chaincode,
      p_function,
      nullif(p_excluded_write_keys, 0)
      );
   else
      v_statement :=
     'insert into bc_invalid_tx';
      insert into bc_invalid_tx
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
      p_txid,
      p_org_name,
      to_date(p_timestamp, TS_FORMAT),
      p_chaincode,
      p_function,
      nullif(p_excluded_read_keys, 0),
      nullif(p_excluded_write_keys, 0),
      p_error
      );
   end if;
end if;
--
if p_key is null then
   --
   -- Txs sin keys
   -- - todas las keys fueron eliminadas por los filtros configurados
   -- - un query fue enviado al orderer
   -- No queda ninguna key para guardar en bc_valid_tx_write_set|bc_invalid_tx_set
   --
   return;
end if;
--
if v_is_valid then
   --
   v_statement :=
  'insert into bc_valid_tx_write_set';
   insert into bc_valid_tx_write_set
   (
   block,
   txseq,
   item,
   key,
   value,
   big_value,
   is_delete
   )
   values
   (
   p_block,
   p_txseq,
   p_item,
   p_key,
   p_value,
   p_big_value,
   p_deleted
   );
else
   v_statement :=
  'insert into bc_invalid_tx_set';
   insert into bc_invalid_tx_set
   (
   block,
   txseq,
   type,
   item,
   key,
   version,
   value,
   big_value,
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
   p_big_value,
   p_deleted
   );
end if;
--
exception when others THEN
    raise_application_error(-20007,
       'Error en [' || v_statement || '] tx [' || nvl(p_txid, p_txseq) || '] type [' || p_type ||
       '] item [' || p_item ||'] p_status [' || p_status ||']: '|| SQLERRM, true);
end add_tx_2;
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
) is
begin
add_tx_2(
  p_block,
  p_txseq,
  p_txid,
  p_type,
  p_org_name,
  p_timestamp,
  p_chaincode,
  p_function,
  p_status,
  p_error,
  p_excluded_read_keys,
  p_excluded_write_keys,
  p_set_type,
  p_item,
  p_key,
  p_version,
  p_value,
  null, -- p_big_value
  p_deleted);
  --
end add_tx;
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
) is
begin
add_tx_2(
  p_block,
  p_txseq,
  p_txid,
  p_type,
  p_org_name,
  p_timestamp,
  p_chaincode,
  p_function,
  p_status,
  p_error,
  p_excluded_read_keys,
  p_excluded_write_keys,
  p_set_type,
  p_item,
  p_key,
  p_version,
  null, -- p_value
  p_big_value,
  p_deleted);
  --
end add_tx_big_value;
--
function block_height RETURN number
is
begin
--
for r1 in (SELECT NVL(max(block), -1) as height FROM bc_block) loop
    --
    return r1.height;
end loop;
--
EXCEPTION WHEN OTHERS THEN
    raise_application_error(-20008, 'Error intentando obtener ultimo bloque disponible: '|| SQLERRM, true);
END block_height;
--
procedure verify(p_block integer) is
   --
   v_valid_tx_count_over integer := 0;
   v_valid_tx_write_set_count integer := 0;
   v_valid_tx_write_set_min_item integer := 0;
   v_valid_tx_write_set_max_item integer := 0;
   --
   v_invalid_tx_count_over integer := 0;
   v_invalid_tx_set_count integer := 0;
   v_invalid_tx_set_min_item integer := 0;
   v_invalid_tx_set_max_item integer := 0;
   --
begin
   --
   for r1 in (select * from bc_block where block = p_block)
   loop
      --
      v_valid_tx_count_over := 0;
      v_invalid_tx_count_over := 0;
      --
      for r2 in (
         select 1 as valid, txid, txseq, 0 as excluded_read_keys, excluded_write_keys, count(*) over() as count_over
         from bc_valid_tx
         where block = p_block
         union all
         select 0 as valid, txid, txseq, excluded_read_keys, excluded_write_keys, count(*) over() as count_over
         from bc_invalid_tx
         where block = p_block
      )
      loop
         --
         select count(*), min(item), max(item)
         into   v_valid_tx_write_set_count,
                v_valid_tx_write_set_min_item,
                v_valid_tx_write_set_max_item
         from   bc_valid_tx_write_set
         where  block = p_block
         and    txseq = r2.txseq;
         --
         select count(*), min(item), max(item)
         into   v_invalid_tx_set_count,
                v_invalid_tx_set_min_item,
                v_invalid_tx_set_max_item
         from   bc_invalid_tx_set
         where  block = p_block
         and    txseq = r2.txseq;
         --
         if r2.valid = 1 then
            --
            v_valid_tx_count_over := r2.count_over;
            --
            if v_invalid_tx_set_count > 0 then
               raise_application_error(-20009,
                   'block [' || p_block || '] tx [' || nvl(r2.txid, r2.txseq) || ']: is valid but has [' || v_invalid_tx_set_count || '] rows in BC_INVALID_TX_SET');
            end if;
            --
            if v_valid_tx_write_set_count > 0 then
               --
               if v_valid_tx_write_set_min_item != 0 then
                  raise_application_error(-20010,
                      'block [' || p_block || '] tx [' || nvl(r2.txid, r2.txseq) || ']: valid min(item) [' || v_valid_tx_write_set_min_item || '] must be zero');
               end if;
               --
               if v_valid_tx_write_set_max_item != v_valid_tx_write_set_count - 1 then
                  raise_application_error(-20011,
                      'block [' || p_block || '] tx [' || nvl(r2.txid, r2.txseq) || ']: valid max(item) [' || v_valid_tx_write_set_max_item ||
                      '] must be count(*) [' || v_valid_tx_write_set_count || '] - 1');
               end if;
            end if;
            --
         else /* INVALID_TX */
            --
            v_invalid_tx_count_over := r2.count_over;
            --
            if v_valid_tx_write_set_count > 0 then
               raise_application_error(-20012,
                   'block [' || p_block || '] tx [' || nvl(r2.txid, r2.txseq) || ']: is invalid but has [' || v_valid_tx_write_set_count || '] rows in BC_VALID_TX_SET');
            end if;
            --
            if v_invalid_tx_set_count > 0 then
               --
               if nvl(v_invalid_tx_set_min_item, 0) != 0 then
                  raise_application_error(-20013,
                      'block [' || p_block || '] tx [' || nvl(r2.txid, r2.txseq) || ']: invalid min(item) [' || v_invalid_tx_set_min_item || '] must be zero');
               end if;
               --
               if v_invalid_tx_set_max_item != v_invalid_tx_set_count - 1 then
                  raise_application_error(-20014,
                      'block [' || p_block || '] tx [' || nvl(r2.txid, r2.txseq) || ']: invalid max(item) [' || v_invalid_tx_set_max_item ||
                      '] must be count(*) [' || v_invalid_tx_set_count || '] - 1');
               end if;
            end if;
         end if;
      end loop;
      --
      if  nvl(r1.valid_user_txs, 0) + nvl(r1.valid_system_txs, 0) != nvl(v_valid_tx_count_over, 0) then
          raise_application_error(-20015,
             'block [' || p_block || ']: ' ||
             '( valid_usr_tx [' || r1.valid_user_txs || '] + ' ||
             'valid_system_tx [' || r1.valid_system_txs || '] ) <> ' ||
             'count(*) from BC_VALID_TX [' || v_valid_tx_count_over || ']');
      end if;
      --
      if  nvl(r1.invalid_user_txs, 0) + nvl(r1.invalid_system_txs, 0) != nvl(v_invalid_tx_count_over, 0) then
          raise_application_error(-20016,
             'block [' || p_block || ']: ' ||
             '( invalid_usr_tx [' || r1.invalid_user_txs || '] + ' ||
             'invalid_system_tx [' || r1.invalid_system_txs || '] ) <> ' ||
             'count(*) from BC_INVALID_TX [' || v_invalid_tx_count_over || ']');
      end if;
      --
      return; /* OK */
      --
   end loop;
   --
   raise_application_error(-20017, 'block [' || p_block || '] does not exist');
   --
end verify;
--
begin
--
for r1 in (select channel from bc_block) loop
    v_db_channel := r1.channel;
    exit;
end loop;
--
end bc_pkg;
