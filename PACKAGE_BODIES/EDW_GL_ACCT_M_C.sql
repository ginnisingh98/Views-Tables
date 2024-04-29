--------------------------------------------------------
--  DDL for Package Body EDW_GL_ACCT_M_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_GL_ACCT_M_C" AS
/* $Header: EDWVBHPB.pls 120.4 2006/03/10 03:34:08 rkumar noship $ */
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 G_DEBUG                    Boolean:=false;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 g_hie_temp_table_name varchar2(50);
 g_value_temp_table varchar2(50);
 g_value_set_temp_table varchar2(50);
 g_value_orp_dup_table varchar2(50);
 g_value_con_dup_table varchar2(50);
 g_sob_vset_lookup_table varchar2(50);
 g_dimension_name varchar2(30);
 g_parallel_level varchar2(10);



PROCEDURE INITDEBUG IS
BEGIN
   IF (fnd_profile.value('EDW_DEBUG') = 'Y') THEN
     g_debug := true;
   ELSE
     g_debug := false;
   END IF;
END INITDEBUG;

PROCEDURE VBHDEBUG(
  p_log varchar2)
IS
BEGIN
  if( g_debug) then
    edw_log.debug_line(p_log);
  end if;
END VBHDEBUG ;

-- simple timing tools, setTimer and logTime.
-- could be used for performance tuning.
PROCEDURE setTimer(
  p_log_timstamp in out NOCOPY date)
IS
BEGIN
  p_log_timstamp := sysdate;
END;


PROCEDURE logTime(
  p_process        varchar2,
  p_log_timstamp   date)
IS
  l_duration     number := null;
BEGIN
  l_duration := sysdate - p_log_timstamp;
  edw_log.put_line('Process Time for '|| p_process || ' : ' || edw_log.duration(l_duration));
  edw_log.put_line('');
END;

procedure lookup_value_set_id(
   p_set_of_books_id IN number
 , p_instance_code IN VARCHAR2
 , p_value_set_id OUT NOCOPY number)
AS
   l_set_of_books_name varchar2(100);
   l_select_stmt     varchar2(2000);
   l_cursor_id       integer;
   l_rows_inserted   integer:=0;
BEGIN

   l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
   l_select_stmt:=
    'SELECT value_set_id
     FROM   EDW_FLEX_SEG_MAPPINGS_V@' || G_TARGET_LINK ||
   ' WHERE  DIMENSION_SHORT_NAME= :g_dimension_name
     AND   lower(INSTANCE_CODE)= lower(:p_instance_code)
     AND    structure_num=(SELECT chart_of_accounts_id FROM GL_SETS_OF_BOOKS WHERE set_of_books_id= :p_set_of_books_id)';

   DBMS_SQL.parse(l_cursor_id,l_select_stmt,DBMS_SQL.NATIVE);

   DBMS_SQL.bind_variable(l_cursor_id,'g_dimension_name',g_dimension_name);
   DBMS_SQL.bind_variable(l_cursor_id,'p_instance_code',p_instance_code);
   DBMS_SQL.bind_variable(l_cursor_id,'p_set_of_books_id',p_set_of_books_id);

   DBMS_SQL.define_column(l_cursor_id,1,p_value_set_id);

   l_rows_inserted:=DBMS_SQL.execute(l_cursor_id);

   IF DBMS_SQL.fetch_rows(l_cursor_id) > 0 THEN
     DBMS_SQL.column_value(l_cursor_id,1,p_value_set_id);
   ELSE
     select set_of_books_name into l_set_of_books_name
       from edw_local_set_of_books
       where lower(p_instance_code)=lower(instance)
       and set_of_books_id=p_set_of_books_id;
       VBHDEBUG('No Segment mapped to '|| g_dimension_name||' for '|| l_set_of_books_name);
   END IF;

   DBMS_SQL.close_cursor(l_cursor_id);

EXCEPTION
    when others then
      p_value_set_id := null;
      VBHDEBUG('Error: when looking up the value_set_id for  '
          ||p_set_of_books_id||' in dimension '|| g_dimension_name);
      raise;
END lookup_value_set_id;

function is_multiple_target
return integer as
    l_impl     integer := 0;
    l_dummy     integer := 0;
    l_stmt     varchar2(200):=0 ;
    l_cursor_id       integer;

begin

    l_cursor_id:= dbms_sql.open_cursor;
    l_stmt := 'select COUNT(*) from FND_LOOKUP_VALUES ' ||
    'where ENABLED_FLAG = ''Y'' and LOOKUP_TYPE = ''EDW_OBJECTS_TO_LOAD''  and LOOKUP_CODE = ''' ||
    g_dimension_name || '''';


    DBMS_SQL.parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
    DBMS_SQL.DEFINE_COLUMN(l_cursor_id, 1, l_impl);
    l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor_id);
    DBMS_SQL.column_value(l_cursor_id,1,l_impl);
    DBMS_SQL.close_cursor(l_cursor_id);

    return l_impl;
end is_multiple_target;


procedure insert_into_temp_table(
    p_temp_table_name IN VARCHAR2,
    p_parent IN varchar2,
    p_parent_name in varchar2,
    p_parent_desc in varchar2,
    p_child in varchar2,
    p_child_name in varchar2,
    p_child_desc in varchar2,
    p_rows_inserted out NOCOPY integer)  as

l_insert_stmt     varchar2(20000);
l_cursor_id       integer;
l_rows_inserted   integer:=0;
begin

   l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
   l_insert_stmt:= 'INSERT INTO ' || p_temp_table_name || '(parent,parent_name,parent_desc,child,child_name,child_desc)
          values(:b_parent,:b_parent_name,:b_parent_desc,:b_child,:b_child_name,:b_child_desc)';
   VBHDEBUG('Going to execute '|| l_insert_stmt);
   DBMS_SQL.parse(l_cursor_id,l_insert_stmt,DBMS_SQL.V7);
   DBMS_SQL.bind_variable(l_cursor_id,':b_parent',p_parent);
   DBMS_SQL.bind_variable(l_cursor_id,':b_parent_name',p_parent_name);
   DBMS_SQL.bind_variable(l_cursor_id,':b_parent_desc',p_parent_desc);
   DBMS_SQL.bind_variable(l_cursor_id,':b_child',p_child);
   DBMS_SQL.bind_variable(l_cursor_id,':b_child_name',p_child_name);
   DBMS_SQL.bind_variable(l_cursor_id,':b_child_desc',p_child_desc);
   l_rows_inserted:=DBMS_SQL.execute(l_cursor_id);
   p_rows_inserted:=l_rows_inserted;
   DBMS_SQL.close_cursor(l_cursor_id);
exception
   when others then
     p_rows_inserted := 0;
     VBHDEBUG('error: when inserting '||p_parent||','||p_child||' into ' || p_temp_table_name );
     DBMS_SQL.close_cursor(l_cursor_id);
end insert_into_temp_table ;

procedure clean_up_temp_table(
   p_temp_table_name in varchar2)
as
   l_cursor_id       integer;
   l_rows_deleted    integer:=0;
   l_temp_value      varchar2(50);
   l_delete_stmt     varchar2(200);
begin
   l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
   l_temp_value:='%'||g_instance_code||'%';
   l_delete_stmt:='delete from ' || p_temp_table_name || ' where child like :b_temp_value or (child is null and parent like :b_temp_value1)';
   DBMS_SQL.parse(l_cursor_id,l_delete_stmt,DBMS_SQL.V7);
   DBMS_SQL.bind_variable(l_cursor_id,':b_temp_value',l_temp_value);
   DBMS_SQL.bind_variable(l_cursor_id,':b_temp_value1',l_temp_value);
   l_rows_deleted:=DBMS_SQL.execute(l_cursor_id);
   commit;
   DBMS_SQL.close_cursor(l_cursor_id);
   VBHDEBUG('Removed ' || l_rows_deleted || ' rows from ' || p_temp_table_name );

exception
   when others then
     VBHDEBUG('error: when cleaning up the temp table');
     DBMS_SQL.close_cursor(l_cursor_id);
     raise;
end clean_up_temp_table ;

function get_db_user(
  p_product varchar2) return varchar2
is
  l_dummy1 varchar2(2000);
  l_dummy2 varchar2(2000);
  l_schema varchar2(400);
Begin
  if FND_INSTALLATION.GET_APP_INFO(p_product,l_dummy1, l_dummy2,l_schema) = false then
    VBHDEBUG('FND_INSTALLATION.GET_APP_INFO returned with error');
    return null;
  end if;
  return l_schema;
Exception when others then
    VBHDEBUG('Error in get_db_user '||sqlerrm);
    return null;
End;

function check_table(
  p_table varchar2 ) return boolean
is
  l_stmt varchar2(10000);
  TYPE CurTyp IS REF CURSOR;
  cv   CurTyp;
Begin
  VBHDEBUG('check_table for '||p_table);

  begin
    l_stmt:='select 1 from '||p_table||' where rownum=1';
    open cv for l_stmt;
    close cv;
    VBHDEBUG('Table found');
    return true;
  exception when others then
      VBHDEBUG('Table NOT found');
    return false;
  end;
Exception when others then
  VBHDEBUG('Exception in  check_table '||sqlerrm);
  return false;
End;


procedure drop_table (
  p_table_name in varchar2)
is
  l_stmt varchar2(400);
Begin
    if check_table( p_table_name) then
    l_stmt:='drop table '|| p_table_name;
    VBHDEBUG('Going to execute '||l_stmt);
    execute immediate l_stmt;
    end if;
Exception when others then
    VBHDEBUG('Error in drop_table '||sqlerrm);
  raise;
End;



-- -----------------------------------------------------------------------------
-- create_vbh_val_set_temp_tbl will get parallel level from profile option.
-- Created to tune up performance for orphans and parent-child pair insertions.
-- It is used by create_vbh_temp_table
-- -----------------------------------------------------------------------------
procedure create_vbh_sob_vset_lookup_tbl is
  l_stmt varchar2(2000);
  l_paral_clause varchar2(100) := null;
  l_owner varchar2(30);
  l_log_timstamp           Date:=Null;
  l_sob_vset_lookup_table  varchar2(100);
begin
  setTimer(l_log_timstamp);
  l_owner:= get_db_user('BIS');
  l_sob_vset_lookup_table := g_sob_vset_lookup_table;
  if l_owner is not null then
    g_sob_vset_lookup_table:= l_owner||'.'|| g_sob_vset_lookup_table;
  end if;

  drop_table(g_sob_vset_lookup_table);

  l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
  execute immediate l_stmt;
  commit;

  if(g_parallel_level is not null) then
    l_paral_clause := 'parallel (degree ' || g_parallel_level || ' )';
  end if;

  l_stmt:= 'create table ' || g_sob_vset_lookup_table  ||
           ' storage (initial 5M next 1M pctincrease 0) '|| l_paral_clause || '
             as select b.edw_set_of_books_id, b.instance, b.set_of_books_id,
                       b.set_of_books_name, b.chart_of_accounts_id,
                       b.description, c.value_set_id
            from
	    (SELECT distinct *
 	     FROM edw_local_set_of_books
	     WHERE instance IN (
   	       select instance_code
   	       from edw_local_instance )
 	     AND edw_set_of_books_id NOT IN(
   		SELECT DISTINCT edw_set_of_books_id
   		FROM edw_local_equi_set_of_books)
	    ) B,
	    EDW_FLEX_SEG_MAPPINGS_V@' || G_TARGET_LINK || ' C
	    where C.DIMENSION_SHORT_NAME = ''' || g_dimension_name|| '''
	    AND lower(C.INSTANCE_CODE)= lower(B.INSTANCE)
	    AND c.structure_num=(SELECT chart_of_accounts_id FROM GL_SETS_OF_BOOKS WHERE set_of_books_id= b.set_of_books_id)';

  VBHDEBUG('executing '|| l_stmt);
  execute immediate l_stmt;
  commit;

   --bug fix 3355535
  DBMS_STATS.GATHER_TABLE_STATS(l_owner,l_sob_vset_lookup_table);

  logTime('Creating SOB-Value_set Lookup Table', l_log_timstamp);

exception
   when others then
        VBHDEBUG('error: recreating the '|| g_sob_vset_lookup_table||' table.');
        raise;

end;




-- -----------------------------------------------------------------------------
-- create_vbh_val_set_temp_tbl will get parallel level from profile option.
-- Created to avoid duplicates and tune up performance. It is used by
-- create_vbh_temp_table
-- -----------------------------------------------------------------------------
procedure create_vbh_val_set_temp_tbl is
  l_stmt varchar2(2000);
  l_paral_clause varchar2(100) := null;
  l_owner varchar2(30);
  l_log_timstamp           Date:=Null;
  l_value_set_temp_table   varchar2(100);

begin

  setTimer(l_log_timstamp);
  l_owner:= get_db_user('BIS');
  l_value_set_temp_table := g_value_set_temp_table;
  if l_owner is not null then
    g_value_set_temp_table:= l_owner||'.'|| g_value_set_temp_table;
  end if;

  drop_table(g_value_set_temp_table);

  l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
  execute immediate l_stmt;
  commit;

  if(g_parallel_level is not null) then
    l_paral_clause := 'parallel (degree ' || g_parallel_level || ' )';
  end if;

  l_stmt:= 'create table '|| g_value_set_temp_table ||' storage (initial 5M next 1M pctincrease 0) '|| l_paral_clause ||
          ' as select distinct value_set_id from edw_flex_seg_mappings_v@' || G_TARGET_LINK ||
          ' where dimension_short_name = '''|| g_dimension_name||'''';


  VBHDEBUG('executing '|| l_stmt);
  execute immediate l_stmt;
  commit;

   --bug fix 3355535
   DBMS_STATS.GATHER_TABLE_STATS(l_owner,l_value_set_temp_table);

  logTime('Creating Value_set Temp table', l_log_timstamp);
exception
   when others then
        VBHDEBUG('error: recreating the '|| g_value_set_temp_table||' table.');
        raise;

end;


-- -----------------------------------------------------------------------------
-- create_vbh_temp_table will get parallel level from profile option for the hierarchy
-- temp table, created for performance.
-- -----------------------------------------------------------------------------
procedure create_vbh_temp_table is
  l_stmt varchar2(2000);
  l_drop_stmt varchar2(200);
  l_cursor_id number;
  l_owner varchar2(30);
  l_result boolean;
  l_paral_clause varchar2(100) := null;
  l_log_timstamp           Date:=Null;
  l_hie_temp_table_name    varchar2(100);


begin
  setTimer(l_log_timstamp);
  l_owner:= get_db_user('BIS');
  l_hie_temp_table_name :=g_hie_temp_table_name;
  if l_owner is not null then
    g_hie_temp_table_name:= l_owner||'.'|| g_hie_temp_table_name;
  end if;
  drop_table(g_hie_temp_table_name);
  commit;
  l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
  execute immediate l_stmt;

  if(g_parallel_level is not null) then
    l_paral_clause := 'parallel (degree ' || g_parallel_level || ' )';
  end if;

/*Added g_value_set_temp_table table to inner query to improve performance bug 3222635 */

  l_stmt:= 'create table '||g_hie_temp_table_name||
           ' storage (initial 5M next 1M pctincrease 0) '|| l_paral_clause || '  as '||
           'select a.flex_value_set_id,a.parent_flex_value, c.description parent_desc,'||
           'a.flex_value,a.description,a.summary_flag from
              ( SELECT v.flex_value_set_id, h.parent_flex_value,
                       v.flex_value, v.description, v.summary_flag
                FROM fnd_flex_values_vl v, fnd_flex_value_norm_hierarchy h,
                     fnd_flex_value_sets s, '||g_value_set_temp_table||' vst
                WHERE   vst.value_set_id = v.flex_value_set_id
		AND h.flex_value_set_id = v.flex_value_set_id
                AND s.flex_value_set_id = v.flex_value_set_id
                AND (((s.format_type NOT IN (''N'',''D'', ''T''))
                AND ( v.flex_value BETWEEN h.child_flex_value_low AND
                                           h.child_flex_value_high)))
                AND ( (v.summary_flag = ''Y'' AND h.range_attribute = ''P'')
                OR (v.summary_flag = ''N'' AND h.range_attribute = ''C''))) a, ' || g_value_set_temp_table || ' b,'
           || g_value_temp_table||' c where a.flex_value_set_id = b.value_set_id '
           || ' and c.flex_value_set_id=a.flex_value_set_id and a.parent_flex_value=c.flex_value';

  VBHDEBUG('Going to execute '|| l_stmt);

  execute immediate l_stmt;
  commit;
  VBHDEBUG('Created table '||g_hie_temp_table_name);


  ----------fix bug 2356452
  l_stmt:='create index  '||g_hie_temp_table_name||'_N1'||' on '||g_hie_temp_table_name||'(flex_value_set_id)';
  VBHDEBUG('Executing statement: '||l_stmt);
  execute immediate l_stmt;
  VBHDEBUG('Created index on '||g_hie_temp_table_name||'(flex_value_set_id)');
  commit;
--bug fix 3355535
  DBMS_STATS.GATHER_TABLE_STATS(l_owner,l_hie_temp_table_name);

  logTime('Creating hierarchy temp table', l_log_timstamp);
exception
   when others then
     VBHDEBUG('error: recreating the '|| g_hie_temp_table_name||' table.');
     raise;
end;

-- -----------------------------------------------------------------------------
-- create_value_temp_table will get parallel level from profile option for the value
-- temp table, created for performance.
-- -----------------------------------------------------------------------------
procedure create_value_temp_table is
  l_stmt varchar2(1000);
  l_drop_stmt varchar2(200);
  l_cursor_id number;
  l_owner varchar2(30);
  l_result boolean;
  l_paral_clause varchar2(100) := null;
  l_log_timstamp           Date:=Null;
  l_value_temp_table   varchar2(100);
begin
  setTimer(l_log_timstamp);
  l_owner:= get_db_user('BIS');
  l_value_temp_table := g_value_temp_table;
  if l_owner is not null then
    g_value_temp_table:= l_owner||'.'|| g_value_temp_table;
  end if;
  drop_table(g_value_temp_table);

  commit;
  l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
  execute immediate l_stmt;
  commit;

  if(g_parallel_level is not null) then
    l_paral_clause := 'parallel (degree ' || g_parallel_level || ' )';
  end if;

 l_stmt:= 'create table '|| g_value_temp_table ||' storage (initial 5M next 1M pctincrease 0) '|| l_paral_clause ||
          ' as select distinct flex_value_set_id,flex_value,description,summary_flag, ENABLED_FLAG '||
          ' from fnd_flex_values_vl where flex_value_set_id in '||
          '(select value_set_id from edw_flex_seg_mappings_v@' ||
 		  G_TARGET_LINK ||
          ' where dimension_short_name = '''|| g_dimension_name||''') '||
          'UNION '||
		  'select flex_value_set_id, value_column_name, meaning_column_name, summary_column_name, ''Y'' '||
		  ' from FND_FLEX_VALIDATION_TABLES '||
          ' WHERE FLEX_VALUE_SET_ID in '||
          ' (select value_set_id from  edw_flex_seg_mappings_v@'||
          G_TARGET_LINK||
          ' where value_set_type=''F'' and  dimension_short_name = '''||g_dimension_name||''')';
   --Added the above UNION for bug 4081205
   VBHDEBUG('Going to execute '|| l_stmt);

  execute immediate l_stmt;
  commit;


  ----------fix bug 2356452
--  Modified to for index reduction project (4542654)
--  l_stmt:='create index  '||g_value_temp_table||'_N1'||' on '||g_value_temp_table||'(flex_value)';
--  VBHDEBUG('Executing statement: '||l_stmt);
--  execute immediate l_stmt;
--  VBHDEBUG('Created index on '||g_value_temp_table||'(flex_value)');


--  l_stmt:='create index  '||g_value_temp_table||'_N2'||' on '||g_value_temp_table||'(flex_value_set_id)';
--  VBHDEBUG('Executing statement: '||l_stmt);
--  execute immediate l_stmt;
--  VBHDEBUG('Created index on '||g_value_temp_table||'(flex_value_set_id)');


--  l_stmt:='create index  '||g_value_temp_table||'_N3'||' on '||g_value_temp_table||'(flex_value, flex_value_set_id)';
--  VBHDEBUG('Executing statement: '||l_stmt);
--  execute immediate l_stmt;
--  VBHDEBUG('Created index on '||g_value_temp_table||'(flex_value, flex_value_set_id)');

  commit;

   --bug fix 3355535
  DBMS_STATS.GATHER_TABLE_STATS(l_owner,l_value_temp_table);

  logTime('Creating value temp table', l_log_timstamp);
exception
   when others then
        VBHDEBUG('error: recreating the '|| g_value_temp_table||' table.');
        raise;
end;

function bulk_push_orphans(
  p_temp_table_name          VARCHAR2
) return number as

 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;

begin
    l_stmt:=  'INSERT INTO '|| p_temp_table_name || '(parent,parent_name,parent_desc,child,child_name,child_desc) '
           || 'select a.flex_value||''-''||b.set_of_books_id||''-''||b.instance, a.flex_value,a.description, NULL, NULL,NULL'
           ||' FROM (select flex_value_set_id, flex_value,description from '|| g_value_temp_table
           ||' minus '||
               '(select flex_value_set_id,flex_value,description from ' || g_hie_temp_table_name
                 || ' union all '
                 || ' select flex_value_set_id, parent_flex_value,parent_desc from ' || g_hie_temp_table_name
                 || ' )) a, '
                 || g_sob_vset_lookup_table || ' b'
 		 || ' WHERE b.value_set_id = a.flex_value_set_id';

    VBHDEBUG('Going to execute '||l_stmt);

    setTimer(l_log_timstamp);
    execute immediate l_stmt;
    l_temp_insert_count:=sql%rowcount;
    VBHDEBUG('inserted '|| l_temp_insert_count||' stand alone nodes into '|| p_temp_table_name );
    logTime('Orphans', l_log_timstamp);
    return l_temp_insert_count;

end bulk_push_orphans;

-- replaced by bulk_push_orphans
function push_orphans(
  p_temp_table_name          VARCHAR2,
  p_set_of_books             edw_local_set_of_books%ROWTYPE,
  p_value_set_id             FND_FLEX_VALUES_VL.FLEX_VALUE_SET_ID%TYPE
) return number as

 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;

begin

    l_stmt:='INSERT INTO '|| p_temp_table_name || '(parent,parent_name,parent_desc,child,child_name,child_desc)
 '|| 'select a.flex_value||''-''||'''
           ||p_set_of_books.set_of_books_id||'''||''-''||'''
           ||p_set_of_books.instance||
            ''',a.flex_value,a.description, NULL, NULL,NULL'
           ||' FROM (select flex_value,description from '|| g_value_temp_table
           ||' where flex_value_set_id= '|| p_value_set_id ||' minus '||
               '(select flex_value,description from '
                 || g_hie_temp_table_name
                 ||' where flex_value_set_id='|| p_value_set_id||' union all '
                 ||' select parent_flex_value,parent_desc from '
                 || g_hie_temp_table_name
                 ||' where flex_value_set_id='|| p_value_set_id ||')) a';

    VBHDEBUG('Going to execute '||l_stmt);

    setTimer(l_log_timstamp);
    execute immediate l_stmt;
    l_temp_insert_count:=sql%rowcount;
    VBHDEBUG('inserted '|| l_temp_insert_count||' stand alone nodes into '|| p_temp_table_name||' from '|| p_set_of_books.set_of_books_name);
    logTime('Orphans', l_log_timstamp);
    return l_temp_insert_count;
end push_orphans;

-- simple tools to get instance code of warehouse and source.
-- used to tell whether the configuration is single instance.
function get_source_instance_code
 return varchar2 as
   l_ins_code     varchar2(100);
begin

   --select instance.instance_name into l_ins_code from V$INSTANCE instance;
   Select instance_code INTO l_ins_code FROM edw_local_instance;--added bug 3973264

   IF l_ins_code is not NULL then
     VBHDEBUG('Source Instance code ' || l_ins_code );
     return l_ins_code;
   ELSE
     VBHDEBUG('No able to get instance code on source' );
     return null;
   END IF;
end get_source_instance_code;

function get_target_instance_code
 return varchar2 as
   l_stmt         varchar2(100);
   l_ins_code     varchar2(100);
   l_cursor_id    integer;
   l_rows_queried   integer:=0;

begin
   l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
   --l_stmt:= 'select instance.instance_name from V$INSTANCE@'|| G_TARGET_LINK ||' instance';
   --added bug 3973264
   l_stmt:= 'select instance.instance_code from edw_local_instance@'|| G_TARGET_LINK ||' instance';
   DBMS_SQL.parse(l_cursor_id,l_stmt,DBMS_SQL.NATIVE);
   DBMS_SQL.define_column(l_cursor_id,1,l_ins_code, 255);
   l_rows_queried := DBMS_SQL.execute(l_cursor_id);

   IF DBMS_SQL.fetch_rows(l_cursor_id) > 0 THEN
     DBMS_SQL.column_value(l_cursor_id,1,l_ins_code);
     VBHDEBUG('Target Instance code ' || l_ins_code );
     return l_ins_code;
   ELSE
     VBHDEBUG('No able to get instance code on ' || G_TARGET_LINK);
       return null;
   END IF;

end get_target_instance_code;

function is_single_instance return boolean as
  l_source_instance       varchar2(100);
  l_target_instance       varchar2(100);
begin
    l_source_instance := get_source_instance_code;
    l_target_instance := get_target_instance_code;

    if ( l_source_instance = l_target_instance) then
       VBHDEBUG('Source and Target on the same instance');
       return TRUE;
    else
       VBHDEBUG('Source and Target on different instance');
       return FALSE;
    end if;
end;


-- since the existence of the edw_vbh_temp# tables depends on the configuration,
-- this procedure is used to create edw_vbh_temp# tables on the fly if necessary.
-- we could consider delivering those staging tables to local source in the future,
-- but this procedure will be forwardly/backwordly compatible.
procedure prepare_source_temp_table(
  p_source_temp_table_name in out NOCOPY varchar2 ,
  p_target_temp_table_name in varchar2
) is
    l_source_instance varchar2(100);
    l_target_instance varchar2(100);
    l_stmt            varchar2(100);
    l_errbuf          varchar2(100);
    l_retcode         number;
    l_owner           varchar2(30);
    l_source_temp_table_name  varchar2(100);
begin
    if is_single_instance then
       return;
    end if;
     l_source_temp_table_name := p_source_temp_table_name;
     l_owner:= get_db_user('BIS');
    p_source_temp_table_name := l_owner||'.' || p_source_temp_table_name;
    if check_table(p_source_temp_table_name) then
      return;
    end if;

    l_stmt := 'create table ' || p_source_temp_table_name || ' as select * from ' || p_target_temp_table_name
			     || ' where 1 = 2 ';
    VBHDEBUG('Source temp being created with statement: ' || l_stmt);
    VBHDEBUG('');
    execute immediate l_stmt;

	--bug fix 3355535
     DBMS_STATS.GATHER_TABLE_STATS(l_owner,l_source_temp_table_name);

    EXCEPTION
     WHEN OTHERS THEN
       l_errbuf :=sqlerrm;
       l_retcode:=sqlcode;
       p_source_temp_table_name := null;
       if( l_retcode <> -955 ) then
         -- should never come here
         VBHDEBUG('error code : ' || sqlcode);
         VBHDEBUG('error message : ' || sqlerrm);
         VBHDEBUG('');
         raise;
       else
         VBHDEBUG(p_source_temp_table_name || ' already exists');
         VBHDEBUG('');
       end if;
end prepare_source_temp_table;

-- this function will push data from source staging table to target.
-- since it is a one time push, it improves the performance.
function rep_from_src_to_target (
  p_source_temp_table_name varchar2,
  p_target_temp_table_name varchar2
) return number as

  l_temp_insert_count     number := 0;
  l_temp_delete_count     number := 0;
  l_log_timstamp          Date:=Null;
  l_stmt                  varchar2(1000);
  l_source_instance       varchar2(100);
  l_target_instance       varchar2(100);

BEGIN

  if is_single_instance then
     return 0;
  else
    /*
    l_stmt := 'delete from '|| p_target_temp_table_name ;
    VBHDEBUG('Going to execute '||l_stmt);
    setTimer(l_log_timstamp);
    execute immediate l_stmt;
    */
    clean_up_temp_table(p_target_temp_table_name);

    l_temp_delete_count:=sql%rowcount;
    logTime('clean up the temp table at target', l_log_timstamp);
    commit;


    l_stmt := 'INSERT INTO '|| p_target_temp_table_name ||
            ' SELECT * from ' || p_source_temp_table_name;

    VBHDEBUG('Going to execute '||l_stmt);
    setTimer(l_log_timstamp);
    execute immediate l_stmt;

    l_temp_insert_count:=sql%rowcount;
    logTime('replicating temp table from source to warehouse', l_log_timstamp);
    commit;
  end if;
  return l_temp_insert_count;

  EXCEPTION
    WHEN OTHERS THEN
       VBHDEBUG('Error: when replicating temp table from source to warehouse');
       return 0;

end rep_from_src_to_target;


function bulk_push_parent_child_pair(
  p_temp_table_name          VARCHAR2
) return number as

 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;

begin
    l_stmt:=     'INSERT INTO '|| p_temp_table_name || '(parent,parent_name,parent_desc,child,child_name,child_desc) '
	      || ' select a.parent_flex_value||''-''||b.set_of_books_id||''-''||b.instance, a.parent_flex_value, a.parent_desc,'
              || ' a.flex_value||''-''||b.set_of_books_id||''-''||b.instance, a.flex_value, a.description FROM '
              || g_hie_temp_table_name || ' A,'
              || g_sob_vset_lookup_table || ' B'
              || ' where a.flex_value_set_id = b.value_set_id ';

    VBHDEBUG('Going to execute '||l_stmt);
    setTimer(l_log_timstamp);
    execute immediate l_stmt;

    l_temp_insert_count:=sql%rowcount;

    VBHDEBUG('inserted '|| l_temp_insert_count||' parent-child pairs into '|| p_temp_table_name);
    logTime('PC pair', l_log_timstamp);
    return l_temp_insert_count;

end bulk_push_parent_child_pair;


-- replaced by bulk_push_parent_child_pair
function push_parent_child_pair(
  p_temp_table_name          VARCHAR2,
  p_set_of_books             edw_local_set_of_books%ROWTYPE,
  p_value_set_id             FND_FLEX_VALUES_VL.FLEX_VALUE_SET_ID%TYPE
) return number as

 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;

begin
    l_stmt:='INSERT INTO '|| p_temp_table_name || '(parent,parent_name,parent_desc,child,child_name,child_desc) '||
            ' select parent_flex_value||''-''||'''
                    ||p_set_of_books.set_of_books_id||'''||''-''||'''
                    ||p_set_of_books.instance||
                ''',parent_flex_value,parent_desc,flex_value||''-''||'''
                    ||p_set_of_books.set_of_books_id||'''||''-''||'''
                    ||p_set_of_books.instance||
                ''',flex_value,description FROM '
              || g_hie_temp_table_name
              ||' where flex_value_set_id = '||p_value_set_id;

    VBHDEBUG('Going to execute '||l_stmt);
    setTimer(l_log_timstamp);
    execute immediate l_stmt;

    l_temp_insert_count:=sql%rowcount;

    VBHDEBUG('inserted '|| l_temp_insert_count||' parent-child pairs into '|| p_temp_table_name ||' from '|| p_set_of_books.set_of_books_name);
    logTime('PC pair', l_log_timstamp);
    return l_temp_insert_count;
end push_parent_child_pair;


-- In the case of dependent value set values got pulled in,
-- duplicates will be intruduced, the following two functions serve as
-- current workaround to cleanup the duplicates. To full support the dependent value set,
-- need enhancement on VBH design and Consolidation API provided by FII.
function remove_dup_from_orphans(
  p_temp_table_name          VARCHAR2,
  p_dups_removed             number
) return number
as
 TYPE curType IS REF CURSOR ;
 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;
 cur_parent_dup          curType;
 l_dups_removed          number := 0;
 l_count                 number := 0;
 l_deleted_count         number := 0;
 l_parent                varchar2(1000);
begin
    l_dups_removed := p_dups_removed;
    VBHDEBUG('') ;
    VBHDEBUG('Get rid of those duplicate parent names among the orphans.') ;
    l_stmt := 'SELECT parent, count(*) count from ' || p_temp_table_name ||
              ' WHERE child IS NULL GROUP BY parent having count(*) > 1';
    VBHDEBUG('Executing ' || l_stmt);
    open cur_parent_dup for l_stmt;
    loop
      FETCH cur_parent_dup INTO l_parent, l_count;
      exit when cur_parent_dup%NOTFOUND;

      l_stmt := 'DELETE FROM ' || p_temp_table_name ||
             ' WHERE parent = '''|| l_parent ||''' AND child IS NULL AND ROWNUM < ' || l_count;
      VBHDEBUG('Executing ' || l_stmt);
      execute immediate l_stmt;
      l_deleted_count:=sql%rowcount;
      VBHDEBUG(l_deleted_count || ' duplicate rows got removed for ' || l_parent );
      l_dups_removed := l_dups_removed + l_deleted_count;
    end loop;
    VBHDEBUG(l_deleted_count  || ' duplicate orphan rows got removed' );
    close cur_parent_dup;
    return l_dups_removed;
    EXCEPTION
      WHEN OTHERS THEN
           close cur_parent_dup;
           VBHDEBUG('Error: when removing the rows with duplicated parent names');

end remove_dup_from_orphans;


procedure create_vbh_orp_dup_tbl(
  p_temp_table_name          VARCHAR2)
is
  l_stmt varchar2(3000);
  l_paral_clause varchar2(100) := null;
  l_owner varchar2(30);
  l_log_timstamp           Date:=Null;
  l_value_orp_dup_table  varchar2(100);

begin

  setTimer(l_log_timstamp);
  l_owner:= get_db_user('BIS');
  l_value_orp_dup_table := g_value_orp_dup_table;
  if l_owner is not null then
    g_value_orp_dup_table:= l_owner||'.'|| g_value_orp_dup_table;
  end if;

  drop_table(g_value_orp_dup_table);
/*
  VBHDEBUG('ALTER SESSION ENABLE PARALLEL DML');
  l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
  execute immediate l_stmt;
  commit;
*/
  if(g_parallel_level is not null) then
    l_paral_clause := 'parallel (degree ' || g_parallel_level || ' )';
  end if;

  VBHDEBUG('executing '|| l_stmt);
  l_stmt:= 'create table '|| g_value_orp_dup_table ||' storage (initial 5M next 1M pctincrease 0) '|| l_paral_clause ||
	' as select a.parent, max(a.rowid) rep , count(*) count
	 from ' || p_temp_table_name || ' a
	 where a.child is null
	 group by a.parent
	 having count(*) > 1 ';
  VBHDEBUG('executing '|| l_stmt);
  execute immediate l_stmt;

  l_stmt:='create index  '||g_value_orp_dup_table||'_N1'||' on '||g_value_orp_dup_table||'(parent)';
  execute immediate l_stmt;

  commit;

  --bug fix 3355535
     DBMS_STATS.GATHER_TABLE_STATS(l_owner,l_value_orp_dup_table);

  logTime('Creating orphan value duplication holder table', l_log_timstamp);
exception
   when others then
        VBHDEBUG('error: recreating the '|| g_value_orp_dup_table ||' table.');
        raise;

end create_vbh_orp_dup_tbl;



function bulk_remove_dup_from_orphans(
  p_temp_table_name          VARCHAR2,
  p_dups_removed             number
) return number
as
 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;
 l_dups_removed          number := 0;
 l_count                 number := 0;
 l_deleted_count         number := 0;
 l_parent                varchar2(1000);
begin
    l_dups_removed := p_dups_removed;

    create_vbh_orp_dup_tbl(p_temp_table_name);

    setTimer(l_log_timstamp);
    VBHDEBUG('') ;
    VBHDEBUG('Get rid of those duplicate parent names among the orphans.') ;
    l_stmt := 'delete from ' || p_temp_table_name || ' a
	      where
	        a.child is null
  	      and exists(
                select 1 from
	     ' || g_value_orp_dup_table || '  b
    	      where a.parent = b.parent
	      and a.rowid <> b.rep )';
    VBHDEBUG('Executing ' || l_stmt);
    execute immediate l_stmt;
    l_deleted_count := sql%rowcount;
    VBHDEBUG(l_deleted_count  || ' duplicate orphan rows got removed' );
    l_dups_removed := l_dups_removed + l_deleted_count;
    logTime('removing dups from orphans', l_log_timstamp);

    return l_dups_removed;
    EXCEPTION
      WHEN OTHERS THEN
           VBHDEBUG('Error: when removing the rows with duplicated parent names');
	   raise;
end bulk_remove_dup_from_orphans;


procedure create_vbh_con_dup_tbl(
  p_temp_table_name          VARCHAR2)
is
  l_stmt varchar2(3000);
  l_paral_clause varchar2(100) := null;
  l_owner varchar2(30);
  l_log_timstamp           Date:=Null;
  l_value_con_dup_table    varchar2(100);

begin

  setTimer(l_log_timstamp);
  l_owner:= get_db_user('BIS');
  l_value_con_dup_table := g_value_con_dup_table;
  if l_owner is not null then
    g_value_con_dup_table:= l_owner||'.'|| g_value_con_dup_table;
  end if;

  drop_table(g_value_con_dup_table);

/*
  VBHDEBUG('ALTER SESSION ENABLE PARALLEL DML');
  l_stmt:='ALTER SESSION ENABLE PARALLEL DML';
  execute immediate l_stmt;
  commit;
*/

  if(g_parallel_level is not null) then
    l_paral_clause := 'parallel (degree ' || g_parallel_level || ' )';
  end if;

  VBHDEBUG('executing '|| l_stmt);
  l_stmt:= 'create table '|| g_value_con_dup_table ||' storage (initial 5M next 1M pctincrease 0) '||
 l_paral_clause ||
        ' as select a.parent, a.child, max(a.rowid) rep , count(*) count
         from ' || p_temp_table_name || ' a
         where a.child is not null
         group by a.parent, a.child
         having count(*) > 1 ';
  VBHDEBUG('executing '|| l_stmt);
  execute immediate l_stmt;

  l_stmt:='create index  '||g_value_con_dup_table||'_N1'||' on '||g_value_con_dup_table||'(parent, child)';
  execute immediate l_stmt;

  commit;

   --bug fix 3355535
     DBMS_STATS.GATHER_TABLE_STATS(l_owner,l_value_con_dup_table);

  logTime('Creating consolidation value duplication holder table', l_log_timstamp);
exception
   when others then
        VBHDEBUG('error: recreating the '|| g_value_con_dup_table ||' table.');
        raise;

end create_vbh_con_dup_tbl;

function bulk_remove_dup_from_cons(
  p_temp_table_name          VARCHAR2,
  p_dups_removed             number
) return number
as
 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;
 l_dups_removed          number := 0;
 l_count                 number := 0;
 l_deleted_count         number := 0;
 l_parent                varchar2(1000);
begin
    l_dups_removed := p_dups_removed;

    create_vbh_con_dup_tbl(p_temp_table_name);

    setTimer(l_log_timstamp);
    VBHDEBUG('') ;
    VBHDEBUG('Get rid of those duplicate parent names among the consolidations.') ;
    l_stmt := 'delete from ' || p_temp_table_name || ' a
              where
                a.child is not null
              and exists(
                select 1 from
             ' || g_value_con_dup_table || '  b
              where a.parent = b.parent
	      and a.child = b.child
              and a.rowid <> b.rep )';
    VBHDEBUG('Executing ' || l_stmt);
    execute immediate l_stmt;
    l_deleted_count := sql%rowcount;
    VBHDEBUG(l_deleted_count  || ' duplicate consolidation rows got removed' );
    l_dups_removed := l_dups_removed + l_deleted_count;
    logTime('removing dups from consolidations', l_log_timstamp);
    return l_dups_removed;
    EXCEPTION
      WHEN OTHERS THEN
           VBHDEBUG('Error: when removing the rows with duplicated parent names');
           raise;
end bulk_remove_dup_from_cons;



function remove_dup_from_consolidations(
  p_temp_table_name          VARCHAR2,
  p_dups_removed             VARCHAR2
) return number
as
 TYPE curType IS REF CURSOR ;
 l_log_timstamp          Date:=Null;
 l_stmt                  varchar2(1000);
 l_temp_insert_count     number := 0;
 cur_parent_dup          curType;
 l_parent                varchar2(1000);
 l_child                 varchar2(1000);
 l_deleted_count         number := 0;
 l_dups_removed          number := 0;
 l_count                 number := 0;

begin
    l_dups_removed := p_dups_removed;
    VBHDEBUG('') ;
    VBHDEBUG('Get rid of those duplicates from consolidation.') ;
    l_stmt :=  'SELECT parent, child, count(*) count from ' || p_temp_table_name || ' GROUP BY parent, child having count(*) > 1';
    VBHDEBUG('Executing ' || l_stmt);
    open cur_parent_dup for l_stmt;
    loop
      FETCH cur_parent_dup INTO l_parent, l_child, l_count;
      exit when cur_parent_dup%NOTFOUND;
      l_stmt := 'DELETE FROM ' || p_temp_table_name ||
             ' WHERE parent = '''|| l_parent ||''' AND child = '''||l_child||''' AND ROWNUM < ' || l_count;
      VBHDEBUG('Executing ' || l_stmt);
      execute immediate l_stmt;
      l_deleted_count:=sql%rowcount;
      VBHDEBUG(l_deleted_count || ' duplicate rows got removed for (' || l_parent ||',' || l_child ||')' );
      l_dups_removed := l_dups_removed + l_deleted_count;
    end loop;
    VBHDEBUG(l_deleted_count  || ' duplicate consolidated rows got removed' );
    close cur_parent_dup;
    return l_dups_removed;
    EXCEPTION
      WHEN OTHERS THEN
           close cur_parent_dup;
           VBHDEBUG('Error: when removing the rows within duplicated consolidated relationships');

end remove_dup_from_consolidations;


PROCEDURE  Push(Errbuf         out NOCOPY Varchar2,
                Retcode        out NOCOPY Varchar2,
                p_from_date    IN   Varchar2,
                p_to_date      IN   Varchar2,
                p_dimension_name IN   varchar2)  IS

--L_PUSH_DATE_RANGE1         Date:=Null;
--L_PUSH_DATE_RANGE2         Date:=Null;
l_row_count                Number:=0;
l_exception_msg            Varchar2(2000):=Null;
l_source_temp_table_name   VARCHAR2(100);
l_target_temp_table_name   VARCHAR2(100);
l_temp_table_name          VARCHAR2(100);
l_temp_date                Date:=Null;
l_duration                 Number:=0;
l_from_date                Date:=Null;
l_to_date                  Date:=Null;
p_dimension_no             INTEGER;
   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
l_value_set_id           FND_FLEX_VALUES_VL.FLEX_VALUE_SET_ID%TYPE;
l_parent_value_set_id    FND_FLEX_VALUES_VL.FLEX_VALUE_SET_ID%TYPE;
l_child_edw_set_of_books_id number;
l_parent_value           FND_FLEX_VALUE_CHILDREN_V.flex_value%TYPE;
l_parent_desc            FND_FLEX_VALUES_VL.description%TYPE;
l_set_of_books           edw_local_set_of_books%ROWTYPE;
l_parent_set_of_books    edw_local_set_of_books%ROWTYPE;
l_edw_equi_sob           edw_local_set_of_books%ROWTYPE;
l_consolidation_id       edw_local_cons_set_of_books.consolidation_id%TYPE;
l_coa_mapping_id	 gl_consolidation.coa_mapping_id%TYPE;
l_resurn_msg            varchar2(150);
l_rows_inserted         Number:=0;
l_dups_removed          Number:=0;
l_rows_replicated       Number:=0;
l_cons_error            exception;
l_insert_count          integer:=0;
l_dimension_name        varchar2(150);
l_log_timstamp          Date:=Null;
l_hie_temp_table_name   varchar2(30);
l_stmt  varchar2(2000);
l_temp_insert_count 	number := 0;
l_cons_status boolean;
l_cursor_id number;
l_dummy_num number;
TYPE curType IS REF CURSOR ;
cur_parent_set_of_books curType;
l_cur_set_of_books      curType;

cur_coa_mapping_id	curType;

TYPE t_edw_equi_sob IS REF CURSOR
    RETURN edw_local_set_of_books%ROWTYPE;
cur_edw_equi_sob t_edw_equi_sob;


TYPE t_fnd_flex_value_pair_rec IS RECORD(
  parent_flex_value   FND_FLEX_VALUES_VL.flex_value%TYPE,
  parent_desc         FND_FLEX_VALUES_VL.description%TYPE,
  child_flex_value    FND_FLEX_VALUES_VL.flex_value%TYPE,
  child_desc          FND_FLEX_VALUES_VL.description%TYPE
);

l_fnd_flex_value_pair t_fnd_flex_value_pair_rec;

CUR_FND_FLEX_VALUE_PAIR curType;
cur_desc curType;

TYPE t_flex_value_desc_rec IS RECORD(
  value               FND_FLEX_VALUES_VL.flex_value%TYPE,
  description         FND_FLEX_VALUES_VL.description%TYPE,
  parent_flag         varchar2(1));
l_flex_value_desc t_flex_value_desc_rec;

TYPE t_flex_value_orp_rec IS RECORD(
  value               FND_FLEX_VALUES_VL.flex_value%TYPE,
  description         FND_FLEX_VALUES_VL.description%TYPE);

l_flex_value_orp t_flex_value_orp_rec;

cur_flex_value_orp 	curType;
cur_flex_value_desc 	curType;

CURSOR cur_set_of_books IS
  SELECT distinct *
  FROM edw_local_set_of_books
  WHERE instance IN (
     select instance_code
     from edw_local_instance
  )
  AND edw_set_of_books_id NOT IN(
   SELECT DISTINCT edw_set_of_books_id
   FROM edw_local_equi_set_of_books
  );

l_temp_stmt varchar2(1000);
l_source_link		VARCHAR2(128);
BEGIN
   Errbuf :=NULL;
   Retcode:=0;


   INITDEBUG;


   -- get databaselink
   EDW_COLLECTION_UTIL.get_dblink_names(l_source_link, g_target_link);

   l_from_date :=fnd_date.canonical_to_date(p_from_date);
   l_to_date   :=fnd_date.canonical_to_date(p_to_date);

   l_cursor_id:= dbms_sql.open_cursor;
   l_temp_stmt:='select dim_name from  edw_dimensions_md_v@' || g_target_link ||
   ' where DIM_LONG_NAME = :b_dimension_name';
   DBMS_SQL.parse(l_cursor_id,l_temp_stmt,DBMS_SQL.V7);
   DBMS_SQL.bind_variable(l_cursor_id,':b_dimension_name',p_dimension_name);
   DBMS_SQL.DEFINE_COLUMN(l_cursor_id,1,g_dimension_name,255);
   l_dummy_num:= DBMS_SQL.EXECUTE_AND_FETCH(l_cursor_id);
   DBMS_SQL.column_value(l_cursor_id,1,g_dimension_name);
   DBMS_SQL.close_cursor(l_cursor_id);

   p_dimension_no := substr(g_dimension_name, 12 , instr(g_dimension_name, '_M') - 12 );

   g_hie_temp_table_name:= g_dimension_name||'_HIE_TEMP';
   g_value_temp_table:= g_dimension_name||'_VAL_TEMP';
   g_value_set_temp_table:= g_dimension_name||'_VAL_SET_TEMP';
   g_sob_vset_lookup_table:= g_dimension_name||'_SOB_VSET_LKUP';
   g_value_orp_dup_table := g_dimension_name || '_ORP_DUP';
   g_value_con_dup_table := g_dimension_name || '_CON_DUP';

   l_source_temp_table_name:='EDW_VBH_TEMP'||p_dimension_no;
   l_target_temp_table_name := l_source_temp_table_name || '@' || g_target_link;


   IF (Not EDW_COLLECTION_UTIL.setup(g_dimension_name)) THEN
     VBHDEBUG('setup failed');
     errbuf := fnd_message.get;
     Return;
   END IF;

   VBHDEBUG('Got g_target_link ' ||  g_target_link );

   IF (p_dimension_no<1) or (p_dimension_no>10) THEN
     edw_log.put_line( 'invalid dimension number '||p_dimension_no);
     Return;
   END IF;
  edw_log.put_line('Collect program for '|| p_dimension_name ||' dimension');
  edw_log.put_line('Dimension number '|| p_dimension_no);
  edw_log.put_line('Dimension physical name : '||g_dimension_name);

  EDW_GL_ACCT_M_C.g_push_date_range1 := nvl(l_from_date,
  EDW_COLLECTION_UTIL.G_local_last_push_start_date - EDW_COLLECTION_UTIL.g_offset);
  EDW_GL_ACCT_M_C.g_push_date_range2 := nvl(l_to_date,EDW_COLLECTION_UTIL.G_local_curr_push_start_date);
  EDW_LOG.PUT_LINE( 'The collection range is from '||to_char(EDW_GL_ACCT_M_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||to_char(EDW_GL_ACCT_M_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
  EDW_LOG.PUT_LINE(' ');

  select FND_PROFILE.VALUE('EDW_PARALLEL_SRC') into g_parallel_level from dual;
  if ( g_parallel_level is not null ) then
    EDW_LOG.PUT_LINE('parallelism is set to ' || g_parallel_level);
  else
    EDW_LOG.PUT_LINE('no parallelism');
  end if;
  EDW_LOG.PUT_LINE(' ');


-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------
   edw_log.put_line(' ');
   edw_log.put_line('Start pushing data');
   l_temp_date := sysdate;

   create_value_temp_table;
   create_vbh_val_set_temp_tbl;
   create_vbh_temp_table;
   create_vbh_sob_vset_lookup_tbl;

   begin
     select instance_code
     into g_instance_code
     from edw_local_instance;
   exception
      when no_data_found then
         edw_log.put_line( 'No data found in EDW_LOCAL_INSTANCE table.');
         return;
      when others then
         edw_log.put_line( 'Error: When looking up instance code in EDW_LOCAL_INSTANCE table.');
         return;
   end;

   prepare_source_temp_table(l_source_temp_table_name, l_target_temp_table_name);
   l_temp_table_name := l_source_temp_table_name;

   edw_log.put_line('');
   edw_log.put_line('Pushing data from '||g_instance_code||'...');
   edw_log.put_line('');
   clean_up_temp_table(l_temp_table_name);


   l_temp_insert_count :=  bulk_push_parent_child_pair( l_temp_table_name);
   g_row_count:= g_row_count+ l_temp_insert_count;


   l_temp_insert_count :=  bulk_push_orphans( l_temp_table_name);
   g_row_count:= g_row_count+ l_temp_insert_count;

   --push the consolidation relationship into temp table
   setTimer(l_log_timstamp);
   l_stmt :=  'SELECT DISTINCT
             con.consolidation_id
           , con.child_edw_set_of_books_id
           , con.parent_edw_set_of_books_id
           , p_sob.instance
           , p_sob.set_of_books_id
           , p_sob.set_of_books_name
           , p_sob.chart_of_accounts_id
           , p_sob.description
           , lookup.value_set_id
           , c_sob.instance
           , c_sob.set_of_books_id
           , c_sob.set_of_books_name
           , c_sob.value_set_id
       FROM  edw_local_cons_set_of_books con,
             edw_local_set_of_books      p_sob,
           ' || g_sob_vset_lookup_table || ' c_sob,
             EDW_FLEX_SEG_MAPPINGS_V@' || G_TARGET_LINK || ' lookup
       WHERE p_sob.edw_set_of_books_id = con.parent_edw_set_of_books_id
       AND   c_sob.edw_set_of_books_id = con.child_edw_set_of_books_id
       AND   lookup.DIMENSION_SHORT_NAME= ''' || g_dimension_name || '''
       AND   lower(lookup.INSTANCE_CODE)= lower(p_sob.instance)
       AND   lookup.structure_num=(
       SELECT chart_of_accounts_id FROM GL_SETS_OF_BOOKS WHERE set_of_books_id= p_sob.set_of_books_id)
      ';

   VBHDEBUG( 'Executing query: ' || l_stmt);
   OPEN cur_parent_set_of_books FOR l_stmt;
   LOOP
       FETCH cur_parent_set_of_books
       INTO l_consolidation_id,
            l_child_edw_set_of_books_id,
            l_parent_set_of_books.edw_set_of_books_id,
            l_parent_set_of_books.instance,
            l_parent_set_of_books.set_of_books_id,
            l_parent_set_of_books.set_of_books_name,
            l_parent_set_of_books.chart_of_accounts_id,
            l_parent_set_of_books.description,
	    l_parent_value_set_id,
	    l_set_of_books.instance,
	    l_set_of_books.set_of_books_id,
	    l_set_of_books.set_of_books_name,
	    l_value_set_id;
       EXIT WHEN cur_parent_set_of_books%NOTFOUND;

       --get the coa_mapping_id for the consolidation_id :Bug#4583057
       OPEN cur_coa_mapping_id FOR
	SELECT coa_mapping_id
	From gl_consolidation
	WHERE consolidation_id=l_consolidation_id;

	FETCH cur_coa_mapping_id INTO l_coa_mapping_id;
       CLOSE cur_coa_mapping_id;

       --look up the equi_set_of_books_id for parent set_of_books
       OPEN cur_edw_equi_sob FOR
       SELECT distinct *
       FROM edw_local_set_of_books
       WHERE
       edw_set_of_books_id=(
         SELECT equi_set_of_books_id
         FROM   edw_local_equi_set_of_books
         WHERE  edw_set_of_books_id=l_parent_set_of_books.edw_set_of_books_id
       );

       FETCH cur_edw_equi_sob INTO l_edw_equi_sob;
       IF cur_edw_equi_sob%FOUND THEN
         l_parent_set_of_books:=l_edw_equi_sob;
       END IF;
       CLOSE cur_edw_equi_sob ;

       -- lookup the l_flex_value_desc and call EDW_GL_CONSOLIDATION
       OPEN cur_flex_value_desc FOR
         'SELECT flex_value,description,summary_flag
          FROM '|| g_value_temp_table||'
          WHERE flex_value_set_id=:s1'
          using l_value_set_id;
       LOOP
       FETCH cur_flex_value_desc INTO l_flex_value_desc;
       EXIT WHEN cur_flex_value_desc%NOTFOUND;
          l_parent_value:=null;
          EDW_GL_CONSOLIDATION.edw_get_cons_flex_value(
          l_coa_mapping_id,l_value_set_id,
          l_parent_value_set_id,l_flex_value_desc.value, l_flex_value_desc.parent_flag,
          l_parent_value,l_resurn_msg, l_cons_status);

          IF l_parent_value IS NOT NULL THEN
          --look up the description for the parent value
          -- clean up before using, the garbage value is causing problem when desc lookup fails.
            l_parent_desc:= null;

            open cur_desc for
            'SELECT description FROM '|| g_value_temp_table||'
             WHERE flex_value_set_id=:s1
             AND flex_value=:s2' using l_parent_value_set_id,l_parent_value;
            fetch cur_desc into l_parent_desc;
            if cur_desc%NOTFOUND then
              edw_log.put_line('Error:'||l_parent_value||
              ' returned by the consolidation funcation is not found in value set '
             ||l_parent_value_set_id);
            end if;
            close cur_desc;

            --push the bridge into temp, only if the parent value/desc lookup succeeeds
            IF l_parent_desc IS NOT NULL THEN
             insert_into_temp_table(l_temp_table_name,
               l_parent_value||'-'||l_parent_set_of_books.set_of_books_id||'-'||
               l_parent_set_of_books.instance,l_parent_value,l_parent_desc,
               l_flex_value_desc.value||'-'||l_set_of_books.set_of_books_id
               ||'-'||l_set_of_books.instance,l_flex_value_desc.value,
               l_flex_value_desc.description,
               l_insert_count);
               l_rows_inserted:=l_rows_inserted + l_insert_count;
            END IF; -- for l_parent_desc is not null
          END IF;--for parent value is not null
        END LOOP;--for cur_cons_from_flex_value
        CLOSE cur_flex_value_desc;
        edw_log.put_line('inserted '|| l_rows_inserted||' consolidation relationships between '||
	        	 l_set_of_books.set_of_books_name||' and '|| l_parent_set_of_books.set_of_books_name||
			 ' into '|| l_temp_table_name);
        edw_log.put_line('');

    END LOOP; --for parent set of books loop
    CLOSE cur_parent_set_of_books;
    logTime('Consolidations', l_log_timstamp);
    g_row_count:= g_row_count+ l_rows_inserted;
    l_rows_inserted := 0;


    setTimer(l_log_timstamp);
    l_dups_removed := bulk_remove_dup_from_orphans(l_temp_table_name, l_dups_removed);
    l_dups_removed := bulk_remove_dup_from_cons(l_temp_table_name, l_dups_removed);
    logTime('duplication removing', l_log_timstamp);
    commit;

    l_rows_replicated := rep_from_src_to_target(l_source_temp_table_name, l_target_temp_table_name);

    l_duration := sysdate - l_temp_date;
    edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
    edw_log.put_line(' ');
    edw_log.put_line(g_row_count||' rows inserted');
    edw_log.put_line(l_dups_removed ||' duplicates removed');
    edw_log.put_line(l_rows_replicated ||' rows replicated from source temp to target');


-- ---------------------------------------------------------------------------
-- END OF Collection , Developer Customizable Section
-- ---------------------------------------------------------------------------
   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count - l_dups_removed ,null,g_push_date_range1, g_push_date_range2);



  Exception
    When others then
        Errbuf:=sqlerrm;
        Retcode:=sqlcode;
        l_exception_msg  := Retcode || ':' || Errbuf;
        EDW_GL_ACCT_M_C.g_exception_msg  := l_exception_msg;
        rollback;
        EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_GL_ACCT_M_C.g_exception_msg,g_push_date_range1, g_push_date_range2);

End push;

END EDW_GL_ACCT_M_C ;

/
