--------------------------------------------------------
-- upgrade from v1 to v2
--------------------------------------------------------

--------------------------------------------------------
-- BC_BLOCK
--------------------------------------------------------
alter table hlf.bc_block add timestamp timestamp;

alter table hlf.bc_block modify valid_system_txs null;

alter table hlf.bc_block modify invalid_system_txs null;

alter table hlf.bc_block modify valid_user_txs null;

alter table hlf.bc_block modify invalid_user_txs null;

alter table hlf.bc_block add constraint check_block_timestamp check
(
timestamp < consuming_time
)
enable novalidate;

--------------------------------------------------------
-- BC_VALID_TX
--------------------------------------------------------
alter table hlf.bc_valid_tx modify txid null;

alter table hlf.bc_valid_tx modify chaincode null;

-- alter table hlf.bc_valid_tx modify function null;

alter table hlf.bc_valid_tx add excluded_write_keys number(5);

--------------------------------------------------------
-- BC_INVALID_TX
--------------------------------------------------------
alter table hlf.bc_invalid_tx modify txid null;

alter table hlf.bc_invalid_tx modify chaincode null;

-- alter table hlf.bc_invalid_tx modify function null;

alter table hlf.bc_invalid_tx add excluded_read_keys number(5);

alter table hlf.bc_invalid_tx add excluded_write_keys number(5);

--------------------------------------------------------
-- BC_VALID_TX_WRITE_SET
--------------------------------------------------------
alter table hlf.bc_valid_tx_write_set add big_value clob;

--------------------------------------------------------
-- BC_INVALID_TX_SET
--------------------------------------------------------
alter table hlf.bc_invalid_tx_set add big_value clob;

create index hlf.bc_invalid_key on hlf.bc_invalid_tx_set(key)
-- TABLESPACE DAT_B01
storage(initial 10M next 10M pctincrease 0);

--------------------------------------------------------
-- BC_VALID|INVALID_TX.FUNCTION NULLEABLE
--
-- alter table hlf.bc_invalid_tx modify function null;
-- da error: ORA-00911: invalid character
--
-- se procede a eliminar las constraints recuperandolas
-- desde el diccionario de datos.
--
-- Dado que la columna SEARCH_CONDITION es LONG
-- se transforma a VARCHAR2 mediante la asginacion
-- a una variable de ese tipo
--
--------------------------------------------------------
DECLARE
    --
    v_search_condition varchar2(4000);
    v_alter_table varchar2(100);
    --
BEGIN
	dbms_output.put_line('begin');
	FOR r1 IN (
        SELECT CONSTRAINT_name, search_condition, table_name
        FROM   ALL_CONSTRAINTS
        WHERE  TABLE_NAME IN ('BC_VALID_TX', 'BC_INVALID_TX')
        AND    OWNER = 'HLF'
        AND    CONSTRAINT_TYPE = 'C')
    LOOP
        v_search_condition := r1.search_condition;
        IF  v_search_condition = '"FUNCTION" IS NOT NULL' then
            dbms_output.put_line(r1.CONSTRAINT_name || ': ' || v_search_condition);
            v_alter_table := 'ALTER TABLE HLF.' || r1.TABLE_NAME || ' DROP CONSTRAINT ' || r1.constraint_name;
            dbms_output.put_line('About to EXECUTE IMMEDIATE ' || v_alter_table);
            EXECUTE IMMEDIATE v_alter_table;
        END IF;
    END LOOP;
	dbms_output.put_line('end');
END;
/
