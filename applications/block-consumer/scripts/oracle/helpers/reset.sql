begin
--
-- Para vaciar las tablas primero se necesita deshabiltar las Forgein Keys
--
for r1 in (
  select 'alter table '||a.owner||'.'||a.table_name||' disable constraint '||a.constraint_name as c1
  from all_constraints a, all_constraints b
  where a.constraint_type = 'R'
  and   a.r_constraint_name = b.constraint_name
  and   a.r_owner = b.owner
  and   a.table_name in ('BC_VALID_TX_WRITE_SET', 'BC_VALID_TX', 'BC_INVALID_TX', 'BC_INVALID_TX_SET')
  ) loop
    --
    dbms_output.put_line(r1.c1);
    EXECUTE IMMEDIATE r1.c1;
    --
end loop;
--
-- TRUNCATES
--
dbms_output.put_line('TRUNCATES');
EXECUTE IMMEDIATE 'TRUNCATE TABLE BC_VALID_TX_WRITE_SET';
EXECUTE IMMEDIATE 'TRUNCATE TABLE BC_VALID_TX';
EXECUTE IMMEDIATE 'TRUNCATE TABLE BC_INVALID_TX_SET';
EXECUTE IMMEDIATE 'TRUNCATE TABLE BC_INVALID_TX';
EXECUTE IMMEDIATE 'TRUNCATE TABLE BC_BLOCK';
--
-- Habilitacion de FKs
--
for r1 in (
  --
  select 'alter table '||a.owner||'.'||a.table_name||' enable constraint '||a.constraint_name as c1
  from all_constraints a, all_constraints b
  where a.constraint_type = 'R'
    and a.r_constraint_name = b.constraint_name
    and a.r_owner = b.owner
    and a.table_name in ('BC_VALID_TX_WRITE_SET', 'BC_VALID_TX', 'BC_INVALID_TX', 'BC_INVALID_TX_SET')
  ) loop
    --
    dbms_output.put_line(r1.c1);
    EXECUTE IMMEDIATE r1.c1;
    --
end loop;
end;
