--------------------------------------------------------
--  DDL for Package Body CZ_BASE_MGR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_BASE_MGR" as
/*  $Header: czbsmgrb.pls 120.4 2008/02/06 15:43:04 lamrute ship $ */

RECORD_COUNTER INTEGER:=0;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/


PROCEDURE exec_plsql_block
(
p_table_name       IN VARCHAR2,
p_where            IN VARCHAR2,
p_pk_col1_type     IN VARCHAR2 DEFAULT NULL,
p_pk_col2_type     IN VARCHAR2 DEFAULT NULL,
p_pk_col3_type     IN VARCHAR2 DEFAULT NULL,
p_pk_col4_type     IN VARCHAR2 DEFAULT NULL,
p_pk_cols_str      IN VARCHAR2,
p_pk_cols_tbl_str  IN VARCHAR2,
p_update_where_str IN VARCHAR2,
p_delete           IN BOOLEAN DEFAULT NULL
) IS

BEGIN

  IF p_delete IS NULL OR p_delete=FALSE THEN
    EXECUTE IMMEDIATE
'DECLARE ' ||
'  TYPE pk_col1_tbl_type is table of '||p_pk_col1_type||' index by binary_integer; ' ||
'  TYPE pk_col2_tbl_type is table of '||p_pk_col2_type||' index by binary_integer; ' ||
'  TYPE pk_col3_tbl_type is table of '||p_pk_col3_type||' index by binary_integer; ' ||
'  TYPE pk_col4_tbl_type is table of '||p_pk_col4_type||' index by binary_integer; ' ||
'  pk_col1_tbl  pk_col1_tbl_type; ' ||
'  pk_col2_tbl  pk_col2_tbl_type; ' ||
'  pk_col3_tbl  pk_col3_tbl_type; ' ||
'  pk_col4_tbl  pk_col4_tbl_type; ' ||
'  cursor tab_cursor is ' ||
'   select '||p_pk_cols_str||' from '||p_table_name||' '||p_where||'; ' ||
'BEGIN ' ||
'  OPEN tab_cursor; ' ||
'  LOOP ' ||
'    pk_col1_tbl.delete; pk_col2_tbl.delete; pk_col3_tbl.delete; pk_col4_tbl.delete; ' ||
'    fetch tab_cursor bulk collect into '||p_pk_cols_tbl_str||' limit '||TO_CHAR(BATCH_SIZE)||'; ' ||
'    exit when (tab_cursor%NOTFOUND and pk_col1_tbl.COUNT = 0); ' ||
'    FORALL j in pk_col1_tbl.FIRST..pk_col1_tbl.LAST ' ||
'        update '||p_table_name||' set deleted_flag = ''1'' where '||p_update_where_str||'; ' ||
'    COMMIT; ' ||
'  END LOOP; ' ||
'END;';

  ELSE

    EXECUTE IMMEDIATE
'DECLARE ' ||
'  TYPE pk_col1_tbl_type is table of '||p_pk_col1_type||' index by binary_integer; ' ||
'  TYPE pk_col2_tbl_type is table of '||p_pk_col2_type||' index by binary_integer; ' ||
'  TYPE pk_col3_tbl_type is table of '||p_pk_col3_type||' index by binary_integer; ' ||
'  TYPE pk_col4_tbl_type is table of '||p_pk_col4_type||' index by binary_integer; ' ||
'  pk_col1_tbl  pk_col1_tbl_type; ' ||
'  pk_col2_tbl  pk_col2_tbl_type; ' ||
'  pk_col3_tbl  pk_col3_tbl_type; ' ||
'  pk_col4_tbl  pk_col4_tbl_type; ' ||
'  cursor tab_cursor is ' ||
'   select '||p_pk_cols_str||' from '||p_table_name||' '||p_where||'; ' ||
'BEGIN ' ||
'  OPEN tab_cursor; ' ||
'  LOOP ' ||
'    pk_col1_tbl.delete; pk_col2_tbl.delete; pk_col3_tbl.delete; pk_col4_tbl.delete; ' ||
'    fetch tab_cursor bulk collect into '||p_pk_cols_tbl_str||' limit '||TO_CHAR(BATCH_SIZE)||'; ' ||
'    exit when (tab_cursor%NOTFOUND and pk_col1_tbl.COUNT = 0); ' ||
'    FORALL j in pk_col1_tbl.FIRST..pk_col1_tbl.LAST ' ||
'      delete from  '||p_table_name||' where '||p_update_where_str||'; ' ||
'    COMMIT; ' ||
'  END LOOP; ' ||
'END;';

  END IF;

END exec_plsql_block;

PROCEDURE exec_it
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_pk_col2      IN VARCHAR2 DEFAULT NULL,
 p_pk_col3      IN VARCHAR2 DEFAULT NULL,
 p_pk_col4      IN VARCHAR2 DEFAULT NULL,
 p_delete       IN BOOLEAN  DEFAULT NULL) IS

  l_pk_cols_str       VARCHAR2(32000);
  l_pk_cols_tbl_str   VARCHAR2(32000);
  l_update_where_str  VARCHAR2(32000);
  l_pk_col1_type      VARCHAR2(255);
  l_pk_col2_type      VARCHAR2(255);
  l_pk_col3_type      VARCHAR2(255);
  l_pk_col4_type      VARCHAR2(255);

BEGIN

  l_pk_cols_str := p_pk_col1;
  l_pk_cols_tbl_str := 'pk_col1_tbl';
  l_update_where_str := ' '||p_pk_col1||'=pk_col1_tbl(j) ';

  l_pk_col1_type := p_table_name||'.'||p_pk_col1||'%TYPE';
  l_pk_col2_type := 'NUMBER';
  l_pk_col3_type := 'NUMBER';
  l_pk_col4_type := 'NUMBER';

  IF p_pk_col2 IS NOT NULL THEN
      l_pk_cols_str := l_pk_cols_str||','||p_pk_col2;
      l_pk_cols_tbl_str := 'pk_col1_tbl,pk_col2_tbl';
      l_update_where_str := l_update_where_str||' and '||p_pk_col2||'=pk_col2_tbl(j) ';
      l_pk_col2_type := p_table_name||'.'||p_pk_col2||'%TYPE';
  END IF;

  IF p_pk_col3 IS NOT NULL THEN
     l_pk_cols_str := l_pk_cols_str||','||p_pk_col3;
     l_pk_cols_tbl_str := 'pk_col1_tbl,pk_col2_tbl,pk_col3_tbl';
     l_update_where_str := l_update_where_str||' and '||p_pk_col3||'=pk_col3_tbl(j) ';
     l_pk_col3_type := p_table_name||'.'||p_pk_col3||'%TYPE';
  END IF;

  IF p_pk_col4 IS NOT NULL THEN
     l_pk_cols_str := l_pk_cols_str||','||p_pk_col4;
     l_pk_cols_tbl_str := 'pk_col1_tbl,pk_col2_tbl,pk_col3_tbl,pk_col4_tbl';
     l_update_where_str := l_update_where_str||' and '||p_pk_col4||'=pk_col4_tbl(j) ';
     l_pk_col4_type := p_table_name||'.'||p_pk_col4||'%TYPE';
  END IF;

  exec_plsql_block
  (
  p_table_name       => p_table_name,
  p_where            => p_where,
  p_pk_col1_type     => l_pk_col1_type,
  p_pk_col2_type     => l_pk_col2_type,
  p_pk_col3_type     => l_pk_col3_type,
  p_pk_col4_type     => l_pk_col4_type,
  p_pk_cols_str      => l_pk_cols_str,
  p_pk_cols_tbl_str  => l_pk_cols_tbl_str,
  p_update_where_str => l_update_where_str,
  p_delete           => p_delete
  );

EXCEPTION
  WHEN OTHERS THEN
    insert into cz_db_logs (caller, message, logtime) values ('cz_base_mgr', 'exec_it failure: '|| p_table_name, sysdate);
    raise;
END exec_it;

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_pk_col2      IN VARCHAR2,
 p_pk_col3      IN VARCHAR2,
 p_pk_col4      IN VARCHAR2,
 p_delete       IN BOOLEAN) IS

BEGIN
  exec_it(
   p_table_name   => p_table_name,
   p_where        => p_where,
   p_pk_col1      => p_pk_col1,
   p_pk_col2      => p_pk_col2,
   p_pk_col3      => p_pk_col3,
   p_pk_col4      => p_pk_col4,
   p_delete       => p_delete);
END exec;

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_pk_col2      IN VARCHAR2,
 p_pk_col3      IN VARCHAR2,
 p_delete       IN BOOLEAN) IS

BEGIN
  exec_it(
   p_table_name   => p_table_name,
   p_where        => p_where,
   p_pk_col1      => p_pk_col1,
   p_pk_col2      => p_pk_col2,
   p_pk_col3      => p_pk_col3,
   p_delete       => p_delete);
END exec;

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_pk_col2      IN VARCHAR2,
 p_delete       IN BOOLEAN) IS

BEGIN
  exec_it(
   p_table_name   => p_table_name,
   p_where        => p_where,
   p_pk_col1      => p_pk_col1,
   p_pk_col2      => p_pk_col2,
   p_delete       => p_delete);
END exec;

PROCEDURE exec
(
 p_table_name   IN VARCHAR2,
 p_where        IN VARCHAR2,
 p_pk_col1      IN VARCHAR2,
 p_delete       IN BOOLEAN  ) IS

BEGIN
  exec_it(
   p_table_name   => p_table_name,
   p_where        => p_where,
   p_pk_col1      => p_pk_col1,
   p_delete       => p_delete);
END exec;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

function canCreate_Sequence return boolean is
ret boolean:=FALSE;
begin

dsql('create sequence CZ.tmp_$ start with 1000 increment by 10 nocache');
if DSQL_ERROR=1 then
   ret:=FALSE;
else
   dsql('drop sequence CZ.tmp_$');
   ret:=TRUE;
end if;
return  ret;
exception
    when OTHERS then
         return  ret;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

function Redo_StartValue
(Table_Name in Table_Record) return integer is
cur       integer;
TableName varchar2(30);
PKeyName  varchar2(30);
var_key   integer:=-1;
var_row   integer;
sqlText   varchar2(90);
begin
    begin
    TableName:=Table_Name.name;
    PKeyName:=Table_Name.pk_name;
    if PKeyName is not null then
       cur:=dbms_sql.open_cursor;
       if TableName = 'CZ_RP_ENTRIES' then
          sqlText := 'select max(' ||PKeyName|| ') from ' || TableName || ' where object_type = ''FLD''';
       else
          sqlText := 'select max(' ||PKeyName|| ') from ' || TableName ;
       end if;
       dbms_sql.parse(cur,sqlText,dbms_sql.native);
       dbms_sql.define_column(cur,1,var_key);
       var_row:=dbms_sql.execute(cur);
       if dbms_sql.fetch_rows(cur)>0 then
          dbms_sql.column_value(cur,1,var_key);
       end if;
       dbms_sql.close_cursor(cur);
    end if;
    exception
    when OTHERS then
         LOG_REPORT('<MGR>.Redo_StartValue',SQLERRM);
    end;
    --
    -- As sequence CZ_XFR_RUN_INFOS_S is used by both CZ_XFR_RUN_INFOS or DB_LOGS_RUN_ID
    -- tables, derive the MAX from both the tables and return the greater of them
    --
    if (TableName = 'CZ_XFR_RUN_INFOS') then
      declare
        db_logs_run_id integer;
      begin
        select nvl(max(run_id), 0) into db_logs_run_id from cz_db_logs;
        if (db_logs_run_id > var_key) then
          var_key := db_logs_run_id;
        end if;
      end;
    end if;
    --
    return var_key;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_STATISTICS(Subschema_Name in varchar2) is
Proc_Name varchar2(50);
Tables    Table_List;

begin
get_TABLE_NAMES(Subschema_Name,Tables);
Proc_Name:='CZ_'||Subschema_Name||'_MGR.REDO_STATISTICS';

for i in Tables.First..Tables.Last loop
    FND_STATS.GATHER_TABLE_STATS(CZ_SCHEMA,Tables(i).name);
end loop;
exception
when OTHERS then
     LOG_REPORT(Proc_Name,SQLERRM);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure TRIGGERS_ENABLED
(Subschema_Name in varchar2,Switch in varchar2) is

currUser     varchar2(30);
var_do       varchar2(10);
Flag         boolean;
Trigger_Name varchar2(30);
WRONG_SWITCH exception;
Proc_Name    varchar2(50);
Tables       Table_List;

begin
get_TABLE_NAMES(Subschema_Name,Tables);
Proc_Name:='CZ_'||Subschema_Name||'_MGR.TRIGGERS_ENABLED';

Flag:=TRUE;
if upper(Switch)='ON' or Switch='1' or upper(Switch)='Y' or upper(Switch)='YES' or upper(Switch)='TRUE' then
   var_do:='enable';
elsif upper(Switch)='OFF' or Switch='0' or upper(Switch)='N' or upper(Switch)='NO' or upper(Switch)='FALSE' then
   var_do:='disable';
else
   raise WRONG_SWITCH;
end if;
for i in Tables.First..Tables.Last loop
    begin
    Trigger_Name:=Tables(i).name||'_T1';
    dsql('alter trigger '||Trigger_Name||' '||var_do);
    exception
        when OTHERS then
        LOG_REPORT(Proc_Name,SQLERRM||' : Error for trigger '||Trigger_Name||' ( table '||Tables(i).name||' )');
        Flag:=FALSE;
    end;
end loop;
if Flag=TRUE and var_do='disable' then
   LOG_REPORT(Proc_Name,'All triggers were disabled ...');
elsif Flag=TRUE and var_do='enable' then
   LOG_REPORT(Proc_Name,'All triggers were enabled ...');
elsif Flag=FALSE and var_do='disable' then
   LOG_REPORT(Proc_Name,'Error. Triggers were disabled with errors ...');
elsif Flag=FALSE and var_do='enable' then
   LOG_REPORT(Proc_Name,'Error. Triggers were enabled with errors ...');
end if;
exception
when WRONG_SWITCH then
     LOG_REPORT(Proc_Name,'Error. You should use On/Off ; 1/0 ; Y/N ; Yes/No; True/False as a parameter.');
when OTHERS then
     LOG_REPORT(Proc_Name,SQLERRM);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure CONSTRAINTS_ENABLED
(Subschema_Name in varchar2,
 Switch in varchar2) is

currUser     varchar2(30);
var_do       varchar2(10);
Flag         boolean;
WRONG_SWITCH exception;
Tables       Table_List;
cursor c1(par_name varchar2) is
select  *  from  user_constraints
where CONSTRAINT_TYPE='R' and table_name=par_name;
var1         c1%rowtype;
Proc_Name    varchar2(50);

begin
get_TABLE_NAMES(Subschema_Name,Tables);
Proc_Name:='CZ_'||Subschema_Name||'_MGR.CONSTRAINTS_ENABLED';

Flag:=TRUE;
if upper(Switch)='ON' or Switch='1' or upper(Switch)='Y' or upper(Switch)='YES' or upper(Switch)='TRUE' then
   var_do:='enable';
elsif upper(Switch)='OFF' or Switch='0' or upper(Switch)='N' or upper(Switch)='NO' or upper(Switch)='FALSE' then
   var_do:='disable';
else
   raise WRONG_SWITCH;
end if;

for i in Tables.First..Tables.Last loop
    open c1(Tables(i).name);
    loop
       fetch c1 into var1;
       exit when c1%notfound;
       begin
       dsql('alter table '||CZ_SCHEMA||'.'||var1.table_name||' '||var_do||' constraint '||var1.constraint_name);
       exception
               when OTHERS then
               LOG_REPORT('CZ_'||Subschema_Name||'_MGR.Constraints_Enabled','Error for constraint '||var1.constraint_name||' ( table '||var1.table_name);
               Flag:=FALSE;
       end;
    end loop;
    close c1;
end loop;

if Flag=TRUE and var_do='disable' then
   LOG_REPORT(Proc_Name,'All FK constraints were disabled ...');
elsif Flag=TRUE and var_do='enable' then
   LOG_REPORT(Proc_Name,'All FK constraints were enabled ...');
elsif Flag=FALSE and var_do='disable' then
   LOG_REPORT(Proc_Name,'FK constraints were disabled with errors ...');
elsif Flag=FALSE and var_do='enable' then
   LOG_REPORT(Proc_Name,'FK constraints were enabled with errors ...');
end if;
exception
when WRONG_SWITCH then
     LOG_REPORT(Proc_Name,'You should use On/Off ; 1/0 ; Y/N ; Yes/No ; True/False as a parameter.');
when OTHERS then
     LOG_REPORT(Proc_Name,SQLERRM);
end;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_SEQUENCE
(SequenceTable  in  Table_Record,
 RedoStart_Flag in  varchar2,
 var_incr       in  varchar2,
 Status_flag    OUT NOCOPY varchar2,
 Proc_Name      in  varchar2) is

Sequence_Name varchar2(30);
new_pkey      integer;

begin
    Sequence_Name:=SequenceTable.name||'_S';
    if RedoStart_Flag='1' then
        begin
        new_pkey:=Redo_StartValue(SequenceTable);
        if new_pkey <> -1 then
           begin
           if canCreate_Sequence then
              dsql('drop sequence '||CZ_SCHEMA||'.'||Sequence_Name);
              dsql('create sequence '||CZ_SCHEMA||'.'||Sequence_Name||' start with '||
              to_char(new_pkey+var_incr)||' increment by '||var_incr||' nocache');
           end if;
           end;
        end if;
        end;
    else
         dsql('alter sequence '||CZ_SCHEMA||'.'||Sequence_Name||' increment by '||var_incr);
    end if;
    Status_flag:='0';

 exception
        when OTHERS then
        LOG_REPORT(Proc_Name,SQLERRM||' : Error for sequence '||Sequence_Name);
        Status_flag:='1';
 end REDO_SEQUENCE;


/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure REDO_SEQUENCES
(Subschema_Name in varchar2,
 RedoStart_Flag in varchar2,
 incr           in integer default null) is

cursor c0 is
select value from CZ_DB_SETTINGS
where  setting_id='OracleSequenceIncr' and section_name='SCHEMA';
var_value integer;
var_incr      varchar2(10);
Flag          varchar2(1);
Sequence_Name varchar2(30);
Proc_Name     varchar2(50);
Tables        Table_List;
new_pkey      integer;
WRONG_INCR    exception;

begin

Tables.Delete;
get_TABLE_NAMES(Subschema_Name,Tables);
Proc_Name:='CZ_'||Subschema_Name||'_MGR.REDO_SEQUENCES';

dsql('drop sequence CZ.tmp_$');

Flag:='0';
if incr is null then
   open c0;
   fetch c0 into var_value;
   if c0%notfound then
      close c0;
      raise WRONG_INCR;
   else
      var_incr:=to_char(var_value);
      close c0;
   end if;
end if;
if incr is not null then
   var_incr:=to_char(incr);
end if;

for i in Tables.First..Tables.Last loop
    REDO_SEQUENCE(Tables(i), RedoStart_Flag, var_incr, Flag, Proc_Name);
end loop;

if Flag='0'  then
   LOG_REPORT(Proc_Name,'<'||Subschema_Name||'> sequences have increment '||var_incr);
else
   LOG_REPORT(Proc_Name,'New increment is '||var_incr||'. But <'||Subschema_Name||'> sequences were altered with the errors.');
end if;


exception
when WRONG_INCR then
     LOG_REPORT(Proc_Name,'Wrong value OracleSequenceIncr in CZ_DB_SETTINGS. ');
when OTHERS then
     LOG_REPORT(Proc_Name,SQLERRM);
end REDO_SEQUENCES;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure CheckSize
(num_rec in integer) is
begin

RECORD_COUNTER:=RECORD_COUNTER+num_rec;

if RECORD_COUNTER>=BATCH_SIZE then
   commit;
   RECORD_COUNTER:=0;
end if;

end CheckSize;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure PURGE
(Subschema_Name in varchar2) is

TYPE col_name_tbl_type is table of varchar2(30) index by binary_integer;

var_deleted_records integer;
cur                 integer;
Tables              Table_List;
Proc_Name           varchar2(50);
SKIP_IT             exception;

l_where              VARCHAR2(2000) := ' WHERE DELETED_FLAG=''1'' ';
l_pk_col_tbl        col_name_tbl_type;

  PROCEDURE get_tab_pks (p_table_name       IN VARCHAR2,
                         p_pk_col_tbl      OUT NOCOPY col_name_tbl_type)

  IS

  CURSOR c1 IS
  SELECT column_name
  FROM dba_cons_columns
  WHERE table_name = p_table_name
  AND owner='CZ'
  AND constraint_name LIKE '%PK'
  ORDER BY position;

  CURSOR c2 IS
  SELECT column_name
  FROM dba_ind_columns
  WHERE table_name = p_table_name
  AND table_owner='CZ'
  AND index_name LIKE '%PK'
  ORDER BY column_position;

  BEGIN

    OPEN c1;
    FETCH c1 BULK COLLECT INTO p_pk_col_tbl;
    CLOSE c1;

    IF p_pk_col_tbl.COUNT=0 THEN
      OPEN c2;
      FETCH c2 BULK COLLECT INTO p_pk_col_tbl;
      CLOSE c2;
    END IF;

  END get_tab_pks;


begin
    RECORD_COUNTER:=0;

    begin
        select TO_NUMBER(VALUE) into CZ_BASE_MGR.BATCH_SIZE from CZ_DB_SETTINGS
        where upper(setting_id)='BATCHSIZE';
    exception
        when no_data_found then
             null;
    end;

    get_TABLE_NAMES(Subschema_Name,Tables);
    Proc_Name:='CZ_'||Subschema_Name||'_MGR.PURGE';
    for i in Tables.First..Tables.Last loop
        begin

        if Tables(i).name IN ( 'CZ_ATP_REQUESTS'
                              ,'CZ_DB_LOGS'
                              ,'CZ_DB_SETTINGS'
                              ,'CZ_DB_SIZES'
                              ,'CZ_DES_CHART_COLUMNS'
                              ,'CZ_EXP_TMP_LINES'
                              ,'CZ_LCE_TEXTS'
                              ,'CZ_MODEL_USAGES'
                              ,'CZ_PB_CLIENT_APPS'
                              ,'CZ_PB_LANGUAGES'
                              ,'CZ_PB_MODEL_EXPORTS'
                              ,'CZ_PB_TEMP_IDS'
                              ,'CZ_PRICING_STRUCTURES'
                              ,'CZ_PUBLICATION_USAGES'
                              ,'CZ_SERVERS'
                              ,'CZ_TERMINATE_MSGS'
                              ,'CZ_XFR_FIELDS'
                              ,'CZ_XFR_FIELD_REQUIRES'
                              ,'CZ_XFR_RUN_INFOS'
                              ,'CZ_XFR_RUN_RESULTS'
                              ,'CZ_XFR_STATUS_CODES'
                              ,'CZ_XFR_TABLES'
                              ,'CZ_COMBO_FEATURES'
                              ,'CZ_GRID_DEFS'
                              ,'CZ_GRID_COLS'
                              ,'CZ_GRID_CELLS') then
           raise SKIP_IT;
        end if;
        if Tables(i).name='CZ_PS_NODES' then
           --Resolve problems with logically deleted ps nodes

           -- NOTES:
           -- 1. This change relies on ps_nodes to be done after devl_projects
           -- 2. With this change ps_nodes will only be deleted if they belong to
           --    deleted projects.  Other logically deleted ps_nodes will be left around.
           exec('cz_ps_nodes', 'where deleted_flag = ''1'' and not exists (select 1 from '||
                'cz_devl_projects where '||
                'devl_project_id = cz_ps_nodes.devl_project_id and deleted_flag = ''0'')',
                'ps_node_id', TRUE);

           /*
           exec('delete from cz_ps_nodes a where a.deleted_flag = ''1'' and not exists (select NULL from cz_expression_nodes b where a.ps_node_id = b.ps_node_id '||
                'and b.deleted_flag = ''0'') and a.deleted_flag = ''1'' and '||
                ' ps_node_id not in'||
                '(select distinct ps_node_id from '||
                ' (select PRIMARY_OPT_ID as ps_node_id from CZ_DES_CHART_CELLS '||
                ' where deleted_flag=''0'' '||
                ' UNION '||
                ' select SECONDARY_OPT_ID as ps_node_id from CZ_DES_CHART_CELLS '||
                ' where deleted_flag=''0'' '||
                ' UNION '||
                ' select SECONDARY_FEAT_EXPL_ID as ps_node_id from CZ_DES_CHART_CELLS '||
                ' where deleted_flag=''0'' '||
                ' UNION '||
                ' select FEATURE_ID as ps_node_id from CZ_DES_CHART_FEATURES '||
                ' where deleted_flag=''0'' '||
                ' UNION '||
                ' select PS_NODE_ID as ps_node_id from CZ_GRID_CELLS '||
                ' where deleted_flag=''0''))');

           for k in (select ps_node_id from CZ_EXPRESSION_NODES where deleted_flag='0') loop
               update cz_ps_nodes set parent_id=0 where ps_node_id=k.ps_node_id and deleted_flag='1';
               CheckSize(SQL%ROWCOUNT);
           end loop; */

        else

           get_tab_pks(Tables(i).name, l_pk_col_tbl);

           If l_pk_col_tbl.count = 0 AND Tables(i).name <> 'CZ_PSNODE_PROPCOMPAT_GENS' THEN
             RAISE_APPLICATION_ERROR (-20001,'Table '||Tables(i).name||' has no PK defined.');
           elsif l_pk_col_tbl.count = 1 THEN
             exec(
               p_table_name   => Tables(i).name,
               p_where        => l_where,
               p_pk_col1      => l_pk_col_tbl(1),
               p_delete       => TRUE);

           elsif l_pk_col_tbl.count = 2 THEN
             exec(
               p_table_name   => Tables(i).name,
               p_where        => l_where,
               p_pk_col1      => l_pk_col_tbl(1),
               p_pk_col2      => l_pk_col_tbl(2),
               p_delete       => TRUE);

           elsif l_pk_col_tbl.count = 3 THEN
             exec(
               p_table_name   => Tables(i).name,
               p_where        => l_where,
               p_pk_col1      => l_pk_col_tbl(1),
               p_pk_col2      => l_pk_col_tbl(2),
               p_pk_col3      => l_pk_col_tbl(3),
               p_delete       => TRUE);

           elsif l_pk_col_tbl.count = 4 THEN
             exec(
               p_table_name   => Tables(i).name,
               p_where        => l_where,
               p_pk_col1      => l_pk_col_tbl(1),
               p_pk_col2      => l_pk_col_tbl(2),
               p_pk_col3      => l_pk_col_tbl(3),
               p_pk_col4      => l_pk_col_tbl(4),
               p_delete       => TRUE);

           end if;

        end if;
    exception
        when SKIP_IT then
             null;
    end;
    commit;
end loop;
commit;
exception
when NO_DATA_FOUND then
     LOG_REPORT(Proc_Name,SQLERRM);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure RESET_CLEAR
(Subschema_Name in varchar2) is

i         integer;
Tables    Table_List;
Proc_Name varchar2(50);

begin
get_TABLE_NAMES(Subschema_Name,Tables);
Proc_Name:='CZ_'||Subschema_Name||'_MGR.RESET_CLEAR';
delete from CZ_PS_NODES where ps_node_id>0;
delete from CZ_DEVL_PROJECTS where devl_project_id>0;
i:=1;
loop
    if Tables(i).name not in ('CZ_PS_NODES','CZ_DEVL_PROJECTS') then
       dsql('DELETE FROM '||Tables(i).name);
    end if;
    i:=i+1;
    if i>Tables.Last then
       exit;
    end if;
end loop;
commit;
exception
when NO_DATA_FOUND then
     LOG_REPORT(Proc_Name,SQLERRM);
when OTHERs then
     LOG_REPORT(Proc_Name,SQLERRM);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure MODIFIED
(Subschema_Name in varchar2,
 AS_OF IN OUT NOCOPY date) is

cur       integer;
var_date  date;
var_row   integer;
max_date  date;
Proc_Name varchar2(50);
Tables    Table_List;

begin
get_TABLE_NAMES(Subschema_Name,Tables);
Proc_Name:='CZ_'||Subschema_Name||'_MGR.MODIFIED';
for i in Tables.First..Tables.Last loop
     begin
    cur:=dbms_sql.open_cursor;
    dbms_sql.parse(cur,'select max(LAST_UPDATE_DATE) from '||Tables(i).name,dbms_sql.native);
    dbms_sql.define_column(cur,1,var_date);
    var_row:=dbms_sql.execute(cur);
    if dbms_sql.fetch_rows(cur)>0 then
       dbms_sql.column_value(cur,1,var_date);
    end if;
    dbms_sql.close_cursor(cur);
    if var_date>max_date then
       max_date:=var_date;
    end if;
    exception
    when OTHERS then
         if dbms_sql.is_open(cur) then
            dbms_sql.close_cursor(cur);
         end if;
    end;
end loop;
AS_OF:=max_date;
exception
when NO_DATA_FOUND then
     LOG_REPORT(Proc_Name,SQLERRM);
when OTHERs then
     LOG_REPORT(Proc_Name,SQLERRM);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure dsql
(stmt in varchar2) is
cur     integer;
var_tempo integer;
begin
cur:=dbms_sql.open_cursor;
dbms_sql.parse(cur,stmt,dbms_sql.native);
var_tempo:=dbms_sql.execute(cur);
DSQL_ERROR:=0;
dbms_sql.close_cursor(cur);
exception
when OTHERS then
     LOG_REPORT('<MGR>.dsql',SQLERRM);
     DSQL_ERROR:=1;
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure exec
(stmt in varchar2) is
cur       integer;
var_tempo integer;
var_stmt  varchar2(10000);
begin
var_stmt:=stmt||' AND rownum<'||to_char(BATCH_SIZE);
cur:=dbms_sql.open_cursor;
dbms_sql.parse(cur,var_stmt,dbms_sql.native);

loop
   var_tempo:=dbms_sql.execute(cur);
   if var_tempo>0 then
      commit;
   else
      exit;
   end if;
end loop;
dbms_sql.close_cursor(cur);
exception
when OTHERS then
     LOG_REPORT('CZ_BASE_MGR.exec','Error : '||SQLERRM||' : statement : "'||var_stmt||'"');
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure LOG_REPORT
(err in varchar2,
 str  in varchar2) is
begin
  -- ret:=CZ_UTILS.REPORT(str,1,err,11276);
  cz_utils.log_report(err, null, null, str, fnd_log.LEVEL_ERROR);
end;

/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/

procedure get_TABLE_NAMES
(SubSchema      in varchar2,
 Tables         IN OUT NOCOPY Table_List) is

begin

if upper(SubSchema)='PS' then
   Tables(1).name:='CZ_DEVL_PROJECTS';              Tables(1).pk_name:='DEVL_PROJECT_ID';
   Tables(2).name:='CZ_DEVL_PRJ_USER_GROUPS';       Tables(2).pk_name:=NULL;
   Tables(3).name:='CZ_FUNC_COMP_SPECS';            Tables(3).pk_name:='FUNC_COMP_ID';
   Tables(4).name:='CZ_FUNC_COMP_REFS';             Tables(4).pk_name:=NULL;
   Tables(5).name:='CZ_PS_PROP_VALS';               Tables(5).pk_name:=NULL;
   Tables(6).name:='CZ_PSNODE_PROPCOMPAT_GENS';     Tables(6).pk_name:='COMPAT_RUN';
   Tables(7).name:='CZ_INTL_TEXTS';                 Tables(7).pk_name:='INTL_TEXT_ID';
   Tables(8).name:='CZ_LOCALIZED_TEXTS';            Tables(8).pk_name:='INTL_TEXT_ID';
   Tables(9).name:='CZ_LOCALES';                    Tables(9).pk_name:='LOCALE_ID';
   Tables(10).name:='CZ_RULES';                     Tables(10).pk_name:='RULE_ID';
   Tables(11).name:='CZ_POPULATORS';                Tables(11).pk_name:='POPULATOR_ID';
   Tables(12).name:='CZ_FILTER_SETS';               Tables(12).pk_name:='FILTER_SET_ID';
   Tables(13).name:='CZ_EXPRESSIONS';               Tables(13).pk_name:='EXPRESS_ID';
   Tables(14).name:='CZ_EXPRESSION_NODES';          Tables(14).pk_name:='EXPR_NODE_ID';
   Tables(15).name:='CZ_COMBO_FEATURES';            Tables(15).pk_name:='FEATURE_ID';
   Tables(16).name:='CZ_GRID_DEFS';                 Tables(16).pk_name:='GRID_ID';
   Tables(17).name:='CZ_GRID_COLS';                 Tables(17).pk_name:='GRID_COL_ID';
   Tables(18).name:='CZ_GRID_CELLS';                Tables(18).pk_name:='GRID_CELL_ID';
   Tables(19).name:='CZ_SUB_CON_SETS';              Tables(19).pk_name:='SUB_CONS_ID';
   Tables(20).name:='CZ_POPULATOR_MAPS';            Tables(20).pk_name:='POP_MAP_ID';
   Tables(21).name:='CZ_RULE_FOLDERS';              Tables(21).pk_name:='RULE_FOLDER_ID';
   Tables(22).name:='CZ_DES_CHART_CELLS';           Tables(22).pk_name:=NULL;
   Tables(23).name:='CZ_DES_CHART_FEATURES';        Tables(23).pk_name:=NULL;
   Tables(24).name:='CZ_PS_NODES';                  Tables(24).pk_name:='PS_NODE_ID';
   Tables(25).name:='CZ_MODEL_REF_EXPLS';           Tables(25).pk_name:='MODEL_REF_EXPL_ID';
   Tables(26).name:='CZ_ARCHIVES';                  Tables(26).pk_name:=NULL;
   Tables(27).name:='CZ_ARCHIVE_REFS';              Tables(27).pk_name:=NULL;
   Tables(28).name:='CZ_RP_ENTRIES';                Tables(28).pk_name:=NULL;
  end if;

if upper(SubSchema)='PB' then
   Tables(1).name:='CZ_MODEL_PUBLICATIONS';         Tables(1).pk_name:='PUBLICATION_ID';
   Tables(2).name:='CZ_PB_CLIENT_APPS';             Tables(2).pk_name:=NULL;
   Tables(3).name:='CZ_PUBLICATION_USAGES';         Tables(3).pk_name:=NULL;
   Tables(4).name:='CZ_SERVERS';                    Tables(4).pk_name:='SERVER_LOCAL_ID';
   Tables(5).name:='CZ_PB_MODEL_EXPORTS';           Tables(5).pk_name:='EXPORT_ID';
   Tables(6).name:='CZ_EFFECTIVITY_SETS';           Tables(6).pk_name:='EFFECTIVITY_SET_ID';
   Tables(7).name:='CZ_MODEL_USAGES';               Tables(7).pk_name:='MODEL_USAGE_ID';
end if;

if upper(SubSchema)='GN' then
   Tables(1).name:='CZ_DB_LOGS';Tables(1).pk_name:=null;
   Tables(2).name:='CZ_DB_SETTINGS';Tables(2).pk_name:=null;
end if;

if upper(SubSchema)='XF' then
   --Tables(1).name:='CZ_XFR_PROJECT_BILLS';        Tables(1).pk_name:=null;
   -- Tables(1).name:='CZ_XFR_PRICE_LISTS';         Tables(1).pk_name:=null;
   Tables(1).name:='CZ_XFR_TABLES';                 Tables(1).pk_name:=null;
   Tables(2).name:='CZ_XFR_FIELDS';                 Tables(2).pk_name:=null;
   Tables(3).name:='CZ_XFR_RUN_INFOS';              Tables(3).pk_name:='RUN_ID';
   Tables(4).name:='CZ_XFR_RUN_RESULTS';            Tables(4).pk_name:=null;
   Tables(5).name:='CZ_XFR_STATUS_CODES';           Tables(5).pk_name:=null;
   Tables(6).name:='CZ_XFR_FIELD_REQUIRES';         Tables(6).pk_name:=null;
end if;
if upper(SubSchema)='PR' then
   Tables(1).name:='CZ_PRICE_GROUPS';               Tables(1).pk_name:='PRICE_GROUP_ID';
   Tables(2).name:='CZ_PRICES';                     Tables(2).pk_name:='PRICE_GROUP_ID';
end if;
if upper(SubSchema)='OM' then
   Tables(1).name:='CZ_OPPORTUNITY_HDRS';           Tables(1).pk_name:='OPPORTUNITY_HDR_ID';
   Tables(2).name:='CZ_OPP_HDR_CONTACTS';           Tables(2).pk_name:=NULL;
   Tables(3).name:='CZ_CONTACTS';                   Tables(3).pk_name:='CONTACT_ID';
   Tables(4).name:='CZ_CUSTOMERS';                  Tables(4).pk_name:='CUSTOMER_ID';
   Tables(5).name:='CZ_ADDRESSES';                  Tables(5).pk_name:='ADDRESS_ID';
   Tables(6).name:='CZ_ADDRESS_USES';               Tables(6).pk_name:='ADDRESS_USE_ID';
   Tables(7).name:='CZ_CUSTOMER_END_USERS';         Tables(7).pk_name:=NULL;
   Tables(8).name:='CZ_END_USERS';                  Tables(8).pk_name:='END_USER_ID';
   Tables(9).name:='CZ_END_USER_GROUPS';            Tables(9).pk_name:=NULL;
   Tables(10).name:='CZ_USER_GROUPS';               Tables(10).pk_name:='USER_GROUP_ID';
end if;
if upper(SubSchema)='LC' then
   Tables(1).name:='CZ_LCE_HEADERS';                Tables(1).pk_name:='LCE_HEADER_ID';
   Tables(2).name:='CZ_LCE_LOAD_SPECS';             Tables(2).pk_name:= null;
   Tables(3).name:='CZ_LCE_LINES';                  Tables(3).pk_name:='LCE_LINE_ID';
   Tables(4).name:='CZ_LCE_OPERANDS';               Tables(4).pk_name:='OPERAND_SEQ';
   Tables(5).name:='CZ_LCE_TEXTS';                  Tables(5).pk_name:='LCE_HEADER_ID';
end if;
if upper(SubSchema)='UI' then
   Tables(1).name:='CZ_UI_DEFS';                    Tables(1).pk_name:='UI_DEF_ID';
   Tables(2).name:='CZ_UI_NODES';                   Tables(2).pk_name:='UI_NODE_ID';
   Tables(3).name:='CZ_UI_PROPERTIES';              Tables(3).pk_name:=null;
   Tables(4).name:='CZ_UI_NODE_PROPS';              Tables(4).pk_name:=null;
   Tables(5).name:='CZ_UI_PAGES';                   Tables(5).pk_name:=null;
   Tables(6).name:='CZ_UI_PAGE_REFS';               Tables(6).pk_name:=null;
   Tables(7).name:='CZ_UI_PAGE_SETS';               Tables(7).pk_name:=null;
   Tables(8).name:='CZ_UI_PAGE_ELEMENTS';           Tables(8).pk_name:=null;
   Tables(9).name:='CZ_UI_REFS';                    Tables(9).pk_name:=null;
   Tables(10).name:='CZ_UI_ACTIONS';                Tables(10).pk_name:=null;
   Tables(11).name:='CZ_UI_TEMPLATES';              Tables(11).pk_name:=null;
   Tables(12).name:='CZ_UI_REF_TEMPLATES';          Tables(12).pk_name:=null;
   Tables(13).name:='CZ_UI_IMAGES';                 Tables(13).pk_name:=null;
   Tables(14).name:='CZ_UI_CONT_TYPE_TEMPLS';       Tables(14).pk_name:=null;
end if;
if upper(SubSchema)='QC' then
   Tables(1).name:='CZ_PROPOSAL_HDRS';              Tables(1).pk_name:='PROPOSAL_HDR_ID';
   Tables(2).name:='CZ_PROP_QUOTE_HDRS';            Tables(2).pk_name:=NULL;
   Tables(3).name:='CZ_QUOTE_HDRS';                 Tables(3).pk_name:='QUOTE_HDR_ID';
   Tables(4).name:='CZ_QUOTE_ORDERS';               Tables(4).pk_name:=NULL;
   Tables(5).name:='CZ_QUOTE_MAIN_ITEMS';           Tables(5).pk_name:=NULL;
   Tables(6).name:='CZ_QUOTE_SPARES';               Tables(6).pk_name:='SEQ_NUMBER';
   Tables(7).name:='CZ_QUOTE_SPECIAL_ITEMS';        Tables(7).pk_name:='SEQ_NUMBER';
   Tables(8).name:='CZ_SPARES_SPECIALS';            Tables(8).pk_name:='PACKAGE_SEQ';
   Tables(9).name:='CZ_DRILL_DOWN_ITEMS';           Tables(9).pk_name:='DD_SEQ_NBR';
   Tables(10).name:='CZ_CONFIG_HDRS';               Tables(10).pk_name:='CONFIG_HDR_ID';
   Tables(11).name:='CZ_CONFIG_INPUTS';             Tables(11).pk_name:='CONFIG_INPUT_ID';
   Tables(12).name:='CZ_CONFIG_ITEMS';              Tables(12).pk_name:='CONFIG_ITEM_ID';
   Tables(13).name:='CZ_CONFIG_MESSAGES';           Tables(13).pk_name:='NULL';
   Tables(14).name:='CZ_CONFIG_ATTRIBUTES';         Tables(14).pk_name:='NULL';
   Tables(15).name:='CZ_CONFIG_EXT_ATTRIBUTES';     Tables(15).pk_name:='NULL';
end if;
if upper(SubSchema)='IM' then
   Tables(1).name:='CZ_ITEM_MASTERS';               Tables(1).pk_name:='ITEM_ID';
   Tables(2).name:='CZ_ITEM_TYPES';                 Tables(2).pk_name:='ITEM_TYPE_ID';
   Tables(3).name:='CZ_PROPERTIES';                 Tables(3).pk_name:='PROPERTY_ID';
   Tables(4).name:='CZ_ITEM_TYPE_PROPERTIES';       Tables(4).pk_name:=NULL;
   Tables(5).name:='CZ_ITEM_PROPERTY_VALUES';       Tables(5).pk_name:=NULL;
   Tables(6).name:='CZ_REL_TYPES';                  Tables(6).pk_name:='REL_TYPE_ID';
   Tables(7).name:='CZ_ITEM_PARENTS';               Tables(7).pk_name:='PARENT_ITEM_ID';
end if;

end;
/*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<*/
begin
    select TABLE_OWNER into CZ_SCHEMA from user_synonyms
    where SYNONYM_NAME='CZ_DEVL_PROJECTS';
exception
    when NO_DATA_FOUND then
         CZ_SCHEMA:=USER;
    when OTHERS then
         LOG_REPORT('<MGR>',SQLERRM);
end;

/
