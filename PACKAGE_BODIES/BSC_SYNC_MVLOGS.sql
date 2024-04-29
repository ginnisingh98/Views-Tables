--------------------------------------------------------
--  DDL for Package Body BSC_SYNC_MVLOGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_SYNC_MVLOGS" AS
/*$Header: BSCMVLGB.pls 120.3 2006/02/09 14:11 arsantha noship $*/

FUNCTION get_apps_schema RETURN VARCHAR2 IS
  l_apps_schema varchar2(30);
  CURSOR c_get_apps_schema is
    SELECT oracle_username
    FROM fnd_oracle_userid
    WHERE oracle_id between 900 and 999;
  /* In 11i on any env this query will always return
     one row */
BEGIN
  IF ( c_get_apps_schema%ISOPEN ) THEN
    CLOSE c_get_apps_schema;
  END IF;
  OPEN  c_get_apps_schema;
  FETCH c_get_apps_schema into l_apps_schema;
  CLOSE c_get_apps_schema;
  return l_apps_schema;
END;

function get_table_owner(p_table varchar2) return varchar2 is
l_owner varchar2(400);
l_stmt  varchar2(4000);
cursor c1(p_table varchar2) is select table_owner from user_synonyms where synonym_name=p_table;
-----------------------------------
Begin
  if instr(p_table,'.')<>0 then
    l_owner:=substr(p_table,1,instr(p_table,'.')-1);
    return l_owner;
  end if;
  open c1(p_table);
  fetch c1 into l_owner;
  close c1;
  if l_owner is null then
    -- owner is apps return apps schema name
    l_owner := get_apps_schema;
  end if;
  return l_owner;
Exception when others then
  return null;
End;

--given a level table with the user_code column size change
--we have to modify all the I tables used by objectives
procedure alter_objective_input_tables(p_level in varchar2, p_owner in varchar2) is
cursor cInputTables(p_level_col varchar2, p_datatype varchar2, p_data_length varchar2 ) is
select cols.table_name
  from all_tab_columns cols
     , bsc_db_tables tbls
 where cols.owner=p_owner
   and cols.table_name=tbls.table_name
   and tbls.table_type=0
   and cols.column_name =p_level_col
   and (cols.data_type<>p_datatype or cols.data_length <>p_data_length)
;

l_level_col varchar2(100);
l_datatype varchar2(100);
l_length   number;

cursor cCol is
select level_pk_col, cols.data_type, cols.data_length
  from bsc_sys_dim_levels_b  lvl
     , all_tab_columns cols
 where lvl.level_table_name=p_level
   and lvl.level_table_name = cols.table_name
   and lvl.level_pk_col = cols.column_name
   and cols.owner = p_owner;

l_datatype_with_length varchar2(100);

begin

  open cCol;
  fetch cCol into l_level_col, l_datatype, l_length;
  close cCol;

  if l_length is not null then
    l_datatype_with_length := l_datatype||'('||l_length||')';
  end if;
  for i in cInputTables(l_level_col, l_datatype, l_length) loop
    execute immediate 'alter table '||p_owner||'.'||i.table_name||' modify '||l_level_col||' '||l_datatype_with_length;
  end loop;
end;


procedure alter_mv_logs(p_level in varchar2, p_owner in varchar2) is

  cursor c_mv_log_name is
  select distinct log_table
    from all_snapshot_logs
    where master = p_level and log_owner = p_owner;

  cursor cCols(p_mv_log varchar2) is
  select cols.column_name, cols.data_type, cols.data_length
    from bsc_sys_dim_levels_b lvl
       , all_tab_columns cols
   where lvl.level_table_name = p_level
     and lvl.level_table_name = cols.table_name
     and cols.owner = p_owner
     and cols.data_type = 'VARCHAR2'
     and (cols.column_name = 'LANGUAGE' or cols.column_name = 'NAME'
          OR cols.column_name in -- code
                 (select column_name
                    from bsc_sys_dim_level_cols lvlcols
                   where lvlcols.dim_level_id=lvl.dim_level_id
                     and column_type='P')
          OR cols.column_name in -- fk code
                 (select relation_col
                    from bsc_Sys_dim_level_rels rels
                   where rels.dim_level_id=lvl.dim_level_id
                     and rels.relation_type=1)
         )
   minus
  select column_name, data_type, data_length
    from all_tab_columns
   where table_name =(select distinct log_table from all_snapshot_logs where log_owner=p_owner and log_table=p_mv_log )
   and owner=p_owner
   and data_type='VARCHAR2';
  l_datatype_with_length varchar2(100);

begin

  for i in c_mv_log_name loop
    for j in cCols(i.log_table) loop
      if j.data_length is not null then
        l_datatype_with_length := j.data_type||'('||j.data_length||')';
      else
        l_datatype_with_length := j.data_type;
      end if;
      begin
      execute immediate 'alter materialized view log on '||p_owner||'.'||p_level||' modify '||j.column_name||' '||l_datatype_with_length;
      exception when others then
        if sqlcode = -904 then -- column doesnt exist, so add it
          -- dont add NAME
          if j.column_name<>'NAME' then
            execute immediate 'alter materialized view log on '||p_owner||'.'||p_level||' add '||j.column_name||' '||l_datatype_with_length;
          end if;
        end if;
      end;
    end loop;
   end loop;

end;

--Fix bug#4180632: new function to syncronize the mv log structure with the
-- structure of the dimension table
-- It was decided on April 05, 2005 after a conference call between
-- Ling, Arun, Vladimir and Venu that we should not drop the columns of
-- the MV log as it is not supported.
-- This sync api is called only for structural changes and all affected KPIs
-- are marked as 3 by PMD. so it safe to drop the MV log at this point
-- The GDB process will recreate the MV log only on the REQUIRED columns
-- for that KPI. If the MV log exists and the reqd column is not there
-- we can add the column to the MV log.

-- Nov 14, 2005, changing MV log behavior after discussion of bug 4630892 between
-- Patricia, Venu, Ling, and Arun.

function sync_dim_table_mv_log(
  p_dim_table_name in varchar2,
  p_error_message out nocopy varchar2
) return boolean is
  l_table_owner varchar2(80);
  l_sql VARCHAR2(1000);
  l_mv_log_name VARCHAR2(1000);
Begin
  l_table_owner := null;
  -- get dimension table mv log name
  l_table_owner := get_table_owner(p_dim_table_name);

  -- if the user_code column has changed in length, these must be
  -- propagated to the Input tables also (BSC_I tables)

  alter_objective_input_tables(p_dim_table_name, l_table_owner);

  -- alter the mv logs to increase column size or include new columns if required
  --not required for now as name is removed in the upgrade script
  --and mv logs on dims have only code and fk_code both of which are numbers
  alter_mv_logs(p_dim_table_name, l_table_owner);


  return true;
  Exception
  when others then
    p_error_message := sqlerrm;
    return false;
End;


-- drop mv log, only called from upgrade

function drop_dim_table_mv_log(
  p_dim_table_name in varchar2,
  p_error_message out nocopy varchar2
) return boolean is
  ------------------------------------------
  cursor c_mv_log_name (p_table_name varchar2, p_table_owner varchar2) is
    select log_table
    from all_snapshot_logs
    where master = p_table_name and log_owner = p_table_owner;
  ------------------------------------------
  l_table_owner varchar2(80);
  l_sql VARCHAR2(1000);
  l_mv_log_name VARCHAR2(1000);
Begin
  l_table_owner := null;
  -- get dimension table mv log name
  l_table_owner := get_table_owner(p_dim_table_name);

  ------------------------------------------
  open c_mv_log_name(p_dim_table_name, l_table_owner);
  fetch c_mv_log_name into l_mv_log_name;
  if c_mv_log_name%notfound then
    -- no mv log created for this dimension
    close c_mv_log_name;
    return true;
  end if;
  ------------------------------------------

  l_sql := 'drop materialized view log on ';
  if (l_table_owner is not null) then
    l_sql := l_sql||l_table_owner||'.';
  end if;
  l_sql := l_sql||p_dim_table_name;
  execute immediate l_sql;
  return true;
  Exception
  when others then
    p_error_message := sqlerrm;
    return false;
End;


END BSC_SYNC_MVLOGS;

/
