--------------------------------------------------------
--  DDL for Package Body EDW_GL_ACCT_M_T
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_GL_ACCT_M_T" AS
/* $Header: EDWVBHCB.pls 120.0 2005/06/01 17:56:30 appldev noship $ */

---add global variable to control num of output we need
---for diamond values and standalone values
G_DEBUG               Boolean:=false;
g_diamond_output      number;
g_rootsetup_error     number;
g_standalone          number;
g_err_cum_timestamp   number;
g_rows_updated        number;
g_err_smp_size        number;
g_rows_inserted       number;
g_not_classified_type varchar2(100);
g_na_edw varchar2(100);
g_na_err varchar2(100);
g_all varchar2(100);


  TYPE t_value_desc_pair_rec IS RECORD (
    value           edw_gl_acct1_m.l1_pk%TYPE,
    name            edw_gl_acct1_m.l1_name%TYPE,
    type            edw_gl_acct1_m.l1_type%TYPE,
    description     edw_gl_acct1_m.l1_description%TYPE);

  TYPE t_vbh_level_table IS TABLE OF t_value_desc_pair_rec
    INDEX BY BINARY_INTEGER;
  g_vbh_level_table t_vbh_level_table;


PROCEDURE INITDEBUG IS
BEGIN
   IF (fnd_profile.value('EDW_DEBUG') = 'Y') THEN
     g_debug := true;
     edw_log.put_line('debug mode true');
   ELSE
     g_debug := false;
     edw_log.put_line('debug mode false');
   END IF;
END INITDEBUG;

PROCEDURE VBHDEBUG(
  p_log varchar2)
IS
BEGIN
  if( g_debug) then
    -- calling put_line directly,
    -- as the edw_log.put_names was never called in EDW_OWB_COLLECTION_UTIL, the debug_line won't work.
    edw_log.put_line(p_log);
  end if;
END VBHDEBUG ;

/**
    Added for bug 4124723, retunrs schema name for a product
 **/
Function get_bis_schema_name return varchar2 is
l_dummy1 varchar2(2000);
l_dummy2 varchar2(2000);
l_schema varchar2(400);
l_prod_no VARCHAR2(30);
Begin
  l_prod_no :='BIS';
  if FND_INSTALLATION.GET_APP_INFO(l_prod_no,l_dummy1, l_dummy2,l_schema) = false then
    edw_log.put_line('FND_INSTALLATION.GET_APP_INFO returned with error');
    return null;
  end if;
  return l_schema;
Exception when others then
  edw_log.put_line('Error in get_schema_name '||sqlerrm);
  return null;
End;

-- -----------------------------------------------------------------------
-- Procedure: check_precedence
-- Description: This function checks the precedence to see if p_acct_name1 is
-- the child of p_acct_name2. p_result returns true if p_acct_name1 is
-- the child of p_acct_name2, otherwise it returns false.
-- ----------------------------------------------------------------------
procedure check_precedence(p_acct_name1 in varchar2,
                           p_acct_name2 in varchar2,
                           p_result out nocopy boolean)  is
     l_cursor_id          integer;
     l_select_stmt        varchar2(500);
     l_rows_selected      integer;
     l_rows_fetched       integer;
     l_count              number;
  begin

     l_select_stmt:= 'select count(*) from '|| g_vbh_temp_table_name||'
                      where child=:m1
                      and child in (
                           SELECT  child
                           FROM '||g_vbh_temp_table_name||'
                           where child is not null
                           START WITH parent =:m2
                           CONNECT BY parent=PRIOR child)';
     l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.parse(l_cursor_id,l_select_stmt,DBMS_SQL.V7);
     DBMS_SQL.bind_variable(l_cursor_id,':m1',p_acct_name1);
     DBMS_SQL.bind_variable(l_cursor_id,':m2',p_acct_name2);
     DBMS_SQL.define_column(l_cursor_id,1,l_count);
     l_rows_selected:=DBMS_SQL.execute(l_cursor_id);
     l_rows_fetched:=DBMS_SQL.fetch_rows(l_cursor_id);
     DBMS_SQL.column_value (l_cursor_id,1,l_count);
     DBMS_SQL.close_cursor(l_cursor_id);

     if l_count=0 then
       p_result:=false;
     else
       p_result:=true;
     end if ;
  exception
     when others then
        p_result:=false;
        DBMS_SQL.close_cursor(l_cursor_id);

	if(sqlcode = -1436) then
                edw_log.put_line('Error :'||
                'When checking precedence between ' || p_acct_name1 || ' and ' ||
                p_acct_name2 || ' in '|| g_vbh_temp_table_name
                ||'. '||sqlcode||' : '||sqlerrm);
        else
        	edw_log.put_line('Error :'||
        	'When updating the TYPE for '|| g_vbh_temp_table_name
        	||'. '||sqlcode||' : '||sqlerrm);
	end if;

        raise;
  end check_precedence;

-- -----------------------------------------------------------------------
-- Procedure: load_type_table
-- Description: This procedure reads in table "edw_segment_classes" and
-- stores it to a pl/sql table "g_acct_type_root1".
-- -----------------------------------------------------------------------
procedure load_type_table is
     l_table_counter integer :=0;
     l_loop_counter integer:=0;
     type t_edw_account_class_cur is ref cursor;
     cur_edw_account_class t_edw_account_class_cur;

  begin
     open cur_edw_account_class for
       select t1.value||'-'||t2.set_of_books_id||'-'||t2.instance,
              t1.type
       from edw_segment_classes t1, edw_set_of_books t2
       where t1.edw_set_of_books_id = t2.edw_set_of_books_id
       and (t1.segment_name,t2.chart_of_accounts_id,lower(t2.instance)) in
           (select segment_name,structure_num,lower(instance_code)
            FROM   EDW_FLEX_SEG_MAPPINGS_V
            WHERE  DIMENSION_SHORT_NAME=g_dimension_name);
     loop
       l_table_counter :=l_table_counter +1;
       fetch   cur_edw_account_class
              into g_acct_type_root1(l_table_counter );
       exit when cur_edw_account_class%NOTFOUND;
     end loop; --for cur_edw_account_class
     close  cur_edw_account_class ;
   exception
     when others then
        edw_log.put_line('Error:'||
         'When reading in table edw_segment_classes for '
          ||g_dimension_name ||'. '||sqlcode||' : '||sqlerrm);
        raise;
  end load_type_table;

-- -----------------------------------------------------------------------
-- Procedure: reorder_type_table
-- Description: This procedure sorts the "g_acct_type_root1" pl/sql
-- table based on hierarchical relationship of elements in "edw_vbh_temp"
-- table. It stores the sorted result to "g_acct_type_root2" pl/sql table.
-- ----------------------------------------------------------------------
procedure reorder_type_table is
     l_loop_counter integer;
     l_outer_loop_counter   integer;
     l_inner_loop_counter   integer;
     l_table_length_counter integer;
     l_result_table_counter integer:=0;
     l_result               boolean:=false;
     l_table_orig_length      integer:=g_acct_type_root1.count;

  begin
    while g_acct_type_root1.count >0 loop
       for l_outer_loop_counter in 1..l_table_orig_length loop
       if g_acct_type_root1.exists(l_outer_loop_counter) then
         l_result :=false;  --reset the l_result value
         for l_inner_loop_counter in 1..l_table_orig_length
           loop
           if l_inner_loop_counter <> l_outer_loop_counter and
              g_acct_type_root1.exists(l_inner_loop_counter) then
              check_precedence(
                        g_acct_type_root1(l_inner_loop_counter).name,
                        g_acct_type_root1(l_outer_loop_counter).name,
                        l_result);
              if(l_result) then exit;
              end if;--for check_precedence
           end if ;
         end loop;  --for inner loop
         if(l_result=false) then
           l_result_table_counter:=l_result_table_counter+1;
           g_acct_type_root2(l_result_table_counter):=
                     g_acct_type_root1(l_outer_loop_counter);
           g_acct_type_root1.delete(l_outer_loop_counter);
         end if;
       end if ;--for outer loop counter exist
    end loop;  --for outer loop
  end loop;--for while loop

  exception
     when others then
       edw_log.put_line(
      'Error: When reordering edw_segment_classes table for '|| g_dimension_name||'. '||sqlcode||' : '||sqlerrm);
      raise;
end reorder_type_table;


procedure update_temp_table(p_acct_name in varchar2,
                            p_acct_type in varchar2) is
    l_CursorID             INTEGER;
    l_UpdateStmt           VARCHAR2(500);
    l_RowsUpdated        integer;

  BEGIN
    l_CursorID := DBMS_SQL.OPEN_CURSOR;
    l_UpdateStmt :=
      'UPDATE '||g_vbh_temp_table_name||'
       SET child_type= :b_acct_type
       WHERE child =:b_acct_name';
    DBMS_SQL.PARSE(l_CursorID,l_UpdateStmt,DBMS_SQL.V7);
    DBMS_SQL.BIND_VARIABLE(l_CursorID, ':b_acct_type',p_acct_type);
    DBMS_SQL.BIND_VARIABLE(l_CursorID, ':b_acct_name',p_acct_name);

    l_RowsUpdated := DBMS_SQL.EXECUTE(l_CursorID);
    DBMS_SQL.CLOSE_CURSOR(l_CursorID);
    l_CursorID := DBMS_SQL.OPEN_CURSOR;
    l_UpdateStmt :=
       'UPDATE '|| g_vbh_temp_table_name||'
       SET parent_type= :b_acct_type
       WHERE parent =:b_acct_name';

    DBMS_SQL.PARSE(l_CursorID,l_UpdateStmt,DBMS_SQL.V7);
    DBMS_SQL.BIND_VARIABLE(l_CursorID, ':b_acct_type',p_acct_type);
    DBMS_SQL.BIND_VARIABLE(l_CursorID, ':b_acct_name',p_acct_name);

    l_RowsUpdated:= DBMS_SQL.EXECUTE(l_CursorID);
    DBMS_SQL.CLOSE_CURSOR(l_CursorID);
  exception
   when others then
     DBMS_SQL.close_cursor(l_CursorID);
     edw_log.put_line('Error:'||
      'when updating table '|| g_vbh_temp_table_name||' for '||
       p_acct_name||' '||sqlcode||' : '||sqlerrm);
      raise;
END update_temp_table;

procedure update_class is
     l_loop_counter   integer :=0;
     l_vbh_acct_name  edw_vbh_temp1.parent%TYPE;
     type t_vbh_temp_cur IS REF CURSOR;
     cur_vbh_temp t_vbh_temp_cur;

  begin
     load_type_table;
     reorder_type_table;
     for l_loop_counter in reverse 1..g_acct_type_root2.count
     loop
         -- update type columns in temp table
         -- for g_acct_type_root2(l_loop_counter).name
         update_temp_table(g_acct_type_root2(l_loop_counter).name,
                           g_acct_type_root2(l_loop_counter).type);

         -- update type columns in temp table
         -- for the children of g_acct_type_root2(l_loop_counter).name

   open cur_vbh_temp for
         'select child from '|| g_vbh_temp_table_name||
         '  START WITH parent = :s
         connect by parent=PRIOR child'
         using g_acct_type_root2(l_loop_counter).name;
      loop
         FETCH cur_vbh_temp INTO l_vbh_acct_name;
         exit when cur_vbh_temp%NOTFOUND;

         update_temp_table(l_vbh_acct_name,
                           g_acct_type_root2(l_loop_counter).type);

      end loop;
    close cur_vbh_temp;
    end loop;
  exception
     when others then
      edw_log.put_line(
      'Error : When updating account type in '|| g_dimension_name
     ||' '||sqlcode||' : '||sqlerrm);
      raise;
end;

procedure clean_up_temp_table as
      l_cursor_id       integer;
      l_rows_deleted    integer:=0;
      l_delete_stmt     varchar2(50);
      l_truncate_sql varchar2(200);

begin
   l_truncate_sql:='truncate table '||get_bis_schema_name||'.'||g_vbh_temp_table_name;
   VBHDEBUG('Executing '|| l_truncate_sql);
   execute immediate l_truncate_sql;
   VBHDEBUG('finished truncate '||g_vbh_temp_table_name);
   commit;
 exception
   when others then
      edw_Log.put_line('error happened when truncate '||g_vbh_temp_table_name||' '||sqlcode||':'||sqlerrm);
      raise;
end clean_up_temp_table ;


procedure clean_up_dimension_table as
      l_truncate_sql varchar2(200);
begin
   l_truncate_sql:='truncate table '||get_bis_schema_name||'.'||g_dimension_name;
   VBHDEBUG('Executing '|| l_truncate_sql);
   execute immediate l_truncate_sql;
   VBHDEBUG('finished truncating  '||g_dimension_name);
  exception
    when others then
      edw_log.put_line('Error happened when truncating '||g_dimension_name||' '||sqlcode||':'||sqlerrm);
      raise;
end clean_up_dimension_table ;

procedure clean_up_global_temp_table as
      l_truncate_sql varchar2(200);
begin
    l_truncate_sql:='truncate table '||get_bis_schema_name||'.'||g_global_temp_table;
    VBHDEBUG('Executing '|| l_truncate_sql);
    execute immediate l_truncate_sql;
    VBHDEBUG('finished truncating '||g_global_temp_table);
    commit;
 exception
    when others then
       edw_log.put_line('Error happened when truncating table '||g_global_temp_table||' '||sqlcode||':'||sqlerrm);
       raise;
end clean_up_global_temp_table ;

-- simple timing tools, setTimer and logTime.
-- could be used for performance tuning.
PROCEDURE setTimer(
  p_log_timstamp in out nocopy date)
IS
BEGIN
  p_log_timstamp := sysdate;
END;


PROCEDURE logCumulatedTime(
  p_log_timstamp   date,
  p_cumulated    in out nocopy  number)
IS
  l_duration     number := null;
BEGIN
  l_duration := sysdate - p_log_timstamp;
  p_cumulated := p_cumulated + l_duration;
END;



PROCEDURE logTime(
  p_process        varchar2,
  p_log_timstamp   date)
IS
  l_duration     number := null;
BEGIN
  l_duration := sysdate - p_log_timstamp;
  VBHDEBUG('Process Time for '|| p_process || ' : ' || edw_log.duration(l_duration));
  VBHDEBUG(' ');
END;

procedure insert_default_value(
   p_pk             IN edw_gl_acct1_m.l1_name%TYPE,
   p_pk_key         IN edw_gl_acct1_m.l1_pk_key%TYPE,
   p_name           IN edw_gl_acct1_m.l1_name%TYPE,
   p_desc           IN edw_gl_acct1_m.l1_description%TYPE)  as
l_cursor_id integer;
l_insert_stmt varchar2(5000);
l_rows_inserted integer :=0;

begin
  l_cursor_id:=DBMS_SQL.open_cursor;
  l_insert_stmt:='INSERT INTO '|| g_dimension_name||'(L1_pk ,l1_pk_key,l1_name,l1_description
  ,l1_type,type_pk,type_name,all_name,all_pk,
  H102_pk ,H103_pk ,H104_pk ,H105_pk ,H106_pk ,H107_pk ,H108_pk ,
  H102_name ,H103_name ,H104_name ,H105_name ,H106_name ,H107_name ,H108_name ,
  H102_type ,H103_type ,H104_type ,H105_type ,H106_type ,H107_type ,H108_type ,
  H109_pk ,H110_pk ,H111_pk ,H112_pk ,H113_pk ,H114_pk ,H115_pk ,
  H109_name ,H110_name ,H111_name ,H112_name ,H113_name ,H114_name ,H115_name ,
  H109_type ,H110_type ,H111_type ,H112_type ,H113_type ,H114_type ,H115_type ,
  H202_pk ,H203_pk ,H204_pk ,H205_pk ,H206_pk ,H207_pk ,H208_pk ,
  H202_name ,H203_name ,H204_name ,H205_name ,H206_name ,H207_name ,H208_name ,
  H202_type ,H203_type ,H204_type ,H205_type ,H206_type ,H207_type ,H208_type ,
  H209_pk ,H210_pk ,H211_pk ,H212_pk ,H213_pk ,H214_pk ,H215_pk ,
  H209_name ,H210_name ,H211_name ,H212_name ,H213_name ,H214_name ,H215_name ,
  H209_type ,H210_type ,H211_type ,H212_type ,H213_type ,H214_type ,H215_type ,
  H302_pk ,H303_pk ,H304_pk ,H305_pk ,H306_pk ,H307_pk ,H308_pk ,
  H302_name ,H303_name ,H304_name ,H305_name ,H306_name ,H307_name ,H308_name ,
  H302_type ,H303_type ,H304_type ,H305_type ,H306_type ,H307_type ,H308_type ,
  H309_pk ,H310_pk ,H311_pk ,H312_pk ,H313_pk ,H314_pk ,H315_pk ,
  H309_name ,H310_name ,H311_name ,H312_name ,H313_name ,H314_name ,H315_name ,
  H309_type ,H310_type ,H311_type ,H312_type ,H313_type ,H314_type ,H315_type ,
  H402_pk ,H403_pk ,H404_pk ,H405_pk ,H406_pk ,H407_pk ,H408_pk ,
  H402_name ,H403_name ,H404_name ,H405_name ,H406_name ,H407_name ,H408_name ,
  H402_type ,H403_type ,H404_type ,H405_type ,H406_type ,H407_type ,H408_type ,
  H409_pk ,H410_pk ,H411_pk ,H412_pk ,H413_pk ,H414_pk ,H415_pk ,
  H409_name ,H410_name ,H411_name ,H412_name ,H413_name ,H414_name ,H415_name ,
  H409_type ,H410_type ,H411_type ,H412_type ,H413_type ,H414_type ,H415_type ,creation_date,LAST_UPDATE_DATE)
 values (:b_pk, :b_pk_key,:b_name,:b_desc, '''|| g_na_edw||''', '''|| g_na_edw||''', '''|| g_na_edw||''',
 '''|| g_na_edw||''', ''NA_EDW'',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',sysdate,sysdate)';

  DBMS_SQL.parse(l_cursor_id,l_insert_stmt,DBMS_SQL.V7);
  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':b_pk',p_pk);
  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':b_pk_key' , p_pk_key);
  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':b_name' , p_name);
  DBMS_SQL.BIND_VARIABLE(l_cursor_id, ':b_desc' , p_desc);
  l_rows_inserted :=DBMS_SQL.EXECUTE(l_cursor_id);
  DBMS_SQL.close_cursor(l_cursor_id);
  exception
  when others then
     edw_log.put_line('Error:'||
      'When inserting the default value into '|| g_dimension_name
      ||' '||sqlcode ||' : '||sqlerrm);
     raise;
end insert_default_value;


procedure insert_non_active_values
as
l_rows_inserted integer :=0;
l_value_stmt varchar2(32767) := NULL;
l_log_timestamp        Date := NULL;

begin
   setTimer(l_log_timestamp); -- for errors only
   l_value_stmt:= 'INSERT INTO '|| g_dimension_name ||
   '( L1_pk ,l1_pk_key,l1_name,l1_description' ||
   '  ,l1_type,type_pk,type_name,all_name,all_pk,' ||
   '  H102_pk ,H103_pk ,H104_pk ,H105_pk ,H106_pk ,H107_pk ,H108_pk ,' ||
   '  H102_name ,H103_name ,H104_name ,H105_name ,H106_name ,H107_name ,H108_name ,' ||
   '  H102_type ,H103_type ,H104_type ,H105_type ,H106_type ,H107_type ,H108_type ,' ||
   '  H109_pk ,H110_pk ,H111_pk ,H112_pk ,H113_pk ,H114_pk ,H115_pk ,' ||
   '  H109_name ,H110_name ,H111_name ,H112_name ,H113_name ,H114_name ,H115_name ,' ||
   '  H109_type ,H110_type ,H111_type ,H112_type ,H113_type ,H114_type ,H115_type ,' ||
   '  H202_pk ,H203_pk ,H204_pk ,H205_pk ,H206_pk ,H207_pk ,H208_pk ,' ||
   '  H202_name ,H203_name ,H204_name ,H205_name ,H206_name ,H207_name ,H208_name ,' ||
   '  H202_type ,H203_type ,H204_type ,H205_type ,H206_type ,H207_type ,H208_type ,' ||
   '  H209_pk ,H210_pk ,H211_pk ,H212_pk ,H213_pk ,H214_pk ,H215_pk ,' ||
   '  H209_name ,H210_name ,H211_name ,H212_name ,H213_name ,H214_name ,H215_name ,' ||
   '  H209_type ,H210_type ,H211_type ,H212_type ,H213_type ,H214_type ,H215_type ,' ||
   '  H302_pk ,H303_pk ,H304_pk ,H305_pk ,H306_pk ,H307_pk ,H308_pk ,' ||
   '  H302_name ,H303_name ,H304_name ,H305_name ,H306_name ,H307_name ,H308_name ,' ||
   '  H302_type ,H303_type ,H304_type ,H305_type ,H306_type ,H307_type ,H308_type ,' ||
   '  H309_pk ,H310_pk ,H311_pk ,H312_pk ,H313_pk ,H314_pk ,H315_pk ,' ||
   '  H309_name ,H310_name ,H311_name ,H312_name ,H313_name ,H314_name ,H315_name ,' ||
   '  H309_type ,H310_type ,H311_type ,H312_type ,H313_type ,H314_type ,H315_type ,' ||
   '  H402_pk ,H403_pk ,H404_pk ,H405_pk ,H406_pk ,H407_pk ,H408_pk ,' ||
   '  H402_name ,H403_name ,H404_name ,H405_name ,H406_name ,H407_name ,H408_name ,' ||
   '  H402_type ,H403_type ,H404_type ,H405_type ,H406_type ,H407_type ,H408_type ,' ||
   '  H409_pk ,H410_pk ,H411_pk ,H412_pk ,H413_pk ,H414_pk ,H415_pk ,' ||
   '  H409_name ,H410_name ,H411_name ,H412_name ,H413_name ,H414_name ,H415_name ,' ||
   '  H409_type ,H410_type ,H411_type ,H412_type ,H413_type ,H414_type ,H415_type ,' ||
   '  creation_date, last_update_date) ' ||
   ' select a.l1_pk,a.l1_pk_key,a.l1_name,a.l1_description , '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',''NA_EDW'',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',sysdate,sysdate ' ||
   ' from '|| g_global_temp_table||' a where not exists ('||
   ' select b.l1_pk from '|| g_dimension_name||' b where a.l1_pk=b.l1_pk )';
   VBHDEBUG('Executing statement : ' || l_value_stmt);
   execute immediate l_value_stmt;
   l_rows_inserted := sql%rowcount;
   VBHDEBUG('Number of non-active rows inserted : ' || l_rows_inserted);
  exception
  when others then
     edw_log.put_line('Error:'|| 'When inserting non-active default value into '|| g_dimension_name ||' '||sqlcode ||' : '||sqlerrm);
     logTime('Error of non-active default values insertions to dimension star table', l_log_timestamp);
     raise;

end insert_non_active_values;

procedure insert_default_values(
  p_seq_name  in varchar2
) as
l_defaultrows_inserted integer :=0;
l_value_stmt varchar2(32767) := NULL;
l_log_timestamp        Date := NULL;

begin
   setTimer(l_log_timestamp); -- for errors only
   l_value_stmt:=
              'INSERT INTO '|| g_dimension_name ||
   '( L1_pk ,l1_pk_key,l1_name,l1_description' ||
   '  ,l1_type,type_pk,type_name,all_name,all_pk,' ||
   '  H102_pk ,H103_pk ,H104_pk ,H105_pk ,H106_pk ,H107_pk ,H108_pk ,' ||
   '  H102_name ,H103_name ,H104_name ,H105_name ,H106_name ,H107_name ,H108_name ,' ||
   '  H102_type ,H103_type ,H104_type ,H105_type ,H106_type ,H107_type ,H108_type ,' ||
   '  H109_pk ,H110_pk ,H111_pk ,H112_pk ,H113_pk ,H114_pk ,H115_pk ,' ||
   '  H109_name ,H110_name ,H111_name ,H112_name ,H113_name ,H114_name ,H115_name ,' ||
   '  H109_type ,H110_type ,H111_type ,H112_type ,H113_type ,H114_type ,H115_type ,' ||
   '  H202_pk ,H203_pk ,H204_pk ,H205_pk ,H206_pk ,H207_pk ,H208_pk ,' ||
   '  H202_name ,H203_name ,H204_name ,H205_name ,H206_name ,H207_name ,H208_name ,' ||
   '  H202_type ,H203_type ,H204_type ,H205_type ,H206_type ,H207_type ,H208_type ,' ||
   '  H209_pk ,H210_pk ,H211_pk ,H212_pk ,H213_pk ,H214_pk ,H215_pk ,' ||
   '  H209_name ,H210_name ,H211_name ,H212_name ,H213_name ,H214_name ,H215_name ,' ||
   '  H209_type ,H210_type ,H211_type ,H212_type ,H213_type ,H214_type ,H215_type ,' ||
   '  H302_pk ,H303_pk ,H304_pk ,H305_pk ,H306_pk ,H307_pk ,H308_pk ,' ||
   '  H302_name ,H303_name ,H304_name ,H305_name ,H306_name ,H307_name ,H308_name ,' ||
   '  H302_type ,H303_type ,H304_type ,H305_type ,H306_type ,H307_type ,H308_type ,' ||
   '  H309_pk ,H310_pk ,H311_pk ,H312_pk ,H313_pk ,H314_pk ,H315_pk ,' ||
   '  H309_name ,H310_name ,H311_name ,H312_name ,H313_name ,H314_name ,H315_name ,' ||
   '  H309_type ,H310_type ,H311_type ,H312_type ,H313_type ,H314_type ,H315_type ,' ||
   '  H402_pk ,H403_pk ,H404_pk ,H405_pk ,H406_pk ,H407_pk ,H408_pk ,' ||
   '  H402_name ,H403_name ,H404_name ,H405_name ,H406_name ,H407_name ,H408_name ,' ||
   '  H402_type ,H403_type ,H404_type ,H405_type ,H406_type ,H407_type ,H408_type ,' ||
   '  H409_pk ,H410_pk ,H411_pk ,H412_pk ,H413_pk ,H414_pk ,H415_pk ,' ||
   '  H409_name ,H410_name ,H411_name ,H412_name ,H413_name ,H414_name ,H415_name ,' ||
   '  H409_type ,H410_type ,H411_type ,H412_type ,H413_type ,H414_type ,H415_type ,' ||
   '  creation_date, last_update_date) ' ||
   ' select dim.pk, decode(temp.l1_pk,null,'||p_seq_name||'.nextval ,temp.l1_pk_key), dim.name,dim.description,
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',''NA_EDW'',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
 ''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',''NA_EDW'',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',
   '''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''','''|| g_na_edw||''',sysdate, sysdate'
                  ||' from '|| g_global_temp_table
                  ||' temp, (select distinct child pk,child_name name,child_desc description from '
                  || g_vbh_temp_table_name||' where child is not null union '
                  || ' select distinct parent pk,parent_name name,parent_desc description from '
                  || g_vbh_temp_table_name||') dim where temp.l1_pk(+)=dim.pk';

   VBHDEBUG(l_value_stmt);
   execute immediate l_value_stmt;
   l_defaultrows_inserted:= sql%rowcount;
   VBHDEBUG('Default rows inserted: ' || l_defaultrows_inserted);
  exception
  when others then
    edw_log.put_line('Error:'|| 'When inserting active default value into '|| g_dimension_name ||' '||sqlcode ||' : '||sqlerrm);
     logTime('Error of active default values insertions to dimension star table', l_log_timestamp);
     raise;
end insert_default_values;


procedure insert_pk_key_into_table as
	l_cursor_id integer;
	l_insert_stmt varchar2(3000);
	l_rows_inserted integer :=0;
begin
	l_insert_stmt :='insert into '|| g_global_temp_table|| ' (l1_pk,l1_pk_key,l1_name,l1_description) ' ||
                    ' select l1_pk, l1_pk_key, l1_name, l1_description from '||g_dimension_name ||
                    ' a where not exists ' ||
                    ' (select b.l1_pk from ' || g_global_temp_table || ' b where a.l1_pk = b.l1_pk)';
    VBHDEBUG('Executing ' || l_insert_stmt);
	l_cursor_id:=DBMS_SQL.open_cursor;
	DBMS_SQL.parse(l_cursor_id,l_insert_stmt,DBMS_SQL.V7);
	l_rows_inserted :=DBMS_SQL.EXECUTE(l_cursor_id);
  	DBMS_SQL.close_cursor(l_cursor_id);
    -- issue commit safely, after the backup is done.
    commit;
    VBHDEBUG('Inserted ' || l_rows_inserted || ' rows');
  exception
    when no_data_found then
	null;
    when others then
	raise;
end insert_pk_key_into_table;



-- ------------------------------------------------------------------------
-- Procedure: update_dimension
-- Description: This function updates the "EDW_GL_ACCTx_M" table if it
-- doesn't find either root setup error or diamond shape error.
-- When it needs to update a row whose "hx02_name" to "hx15_name" columns
-- are not all 'NA_EDW', there could be a dimond shape error or a root setup
-- error and it will not overwrite the original hierarchy.
-- To check the errors, if "p_level15" is the original root, there are
-- multiple paths to the root in this particular hierarchy and a dimond
-- shape error exists. If "p_level15" is not the same as the orginal root,
-- the are multiple roots specified for this hierarchy and a root setup
-- error exists.
---------------------------------------------------------------------------
PROCEDURE update_dimension(
  p_CursorID        IN integer,
  p_hierachy_no     IN number,
  p_pk              IN edw_gl_acct1_m.l1_pk%TYPE,
  p_type            IN edw_gl_acct1_m.l1_type%TYPE,
  p_level2          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level2_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level2_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level2_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level3          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level3_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level3_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level3_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level4          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level4_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level4_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level4_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level5          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level5_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level5_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level5_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level6          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level6_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level6_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level6_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level7          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level7_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level7_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level7_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level8          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level8_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level8_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level8_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level9          IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level9_name     IN edw_gl_acct1_m.l1_name%TYPE,
  p_level9_type     IN edw_gl_acct1_m.l1_type%TYPE,
  p_level9_desc     IN edw_gl_acct1_m.l1_description%TYPE,
  p_level10         IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level10_name    IN edw_gl_acct1_m.l1_name%TYPE,
  p_level10_type    IN edw_gl_acct1_m.l1_type%TYPE,
  p_level10_desc    IN edw_gl_acct1_m.l1_description%TYPE,
  p_level11         IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level11_name    IN edw_gl_acct1_m.l1_name%TYPE,
  p_level11_type    IN edw_gl_acct1_m.l1_type%TYPE,
  p_level11_desc    IN edw_gl_acct1_m.l1_description%TYPE,
  p_level12         IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level12_name    IN edw_gl_acct1_m.l1_name%TYPE,
  p_level12_type    IN edw_gl_acct1_m.l1_type%TYPE,
  p_level12_desc    IN edw_gl_acct1_m.l1_description%TYPE,
  p_level13         IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level13_name    IN edw_gl_acct1_m.l1_name%TYPE,
  p_level13_type    IN edw_gl_acct1_m.l1_type%TYPE,
  p_level13_desc    IN edw_gl_acct1_m.l1_description%TYPE,
  p_level14         IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level14_name    IN edw_gl_acct1_m.l1_name%TYPE,
  p_level14_type    IN edw_gl_acct1_m.l1_type%TYPE,
  p_level14_desc    IN edw_gl_acct1_m.l1_description%TYPE,
  p_level15         IN edw_gl_acct1_m.l1_pk%TYPE,
  p_level15_name    IN edw_gl_acct1_m.l1_name%TYPE,
  p_level15_type    IN edw_gl_acct1_m.l1_type%TYPE,
  p_level15_desc    IN edw_gl_acct1_m.l1_description%TYPE,
  p_all_name        in edw_gl_acct1_m.all_name%TYPE,
  p_RowsUpdated     IN OUT NOCOPY INTEGER
 ) AS

l_CursorID             INTEGER;
l_UpdateStmt           VARCHAR2(4000);
l_root_name            varchar2(240);
l_dimond_error         EXCEPTION;
l_root_setup_error     exception;
l_error_timestamp      Date:= null;


type  t_cur_check_error is ref cursor;
cur_check_error t_cur_check_error;
BEGIN

  IF p_hierachy_no <= 4 THEN
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_type', p_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level2' , p_level2);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level2_name',p_level2_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level2_type',p_level2_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level2_desc',p_level2_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level3' , p_level3);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level3_name',p_level3_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level3_type',p_level3_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level3_desc',p_level3_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level4' , p_level4);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level4_name',p_level4_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level4_type',p_level4_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level4_desc',p_level4_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level5' , p_level5);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level5_name',p_level5_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level5_type',p_level5_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level5_desc',p_level5_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level6' , p_level6);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level6_name',p_level6_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level6_type',p_level6_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level6_desc',p_level6_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level7' , p_level7);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level7_name',p_level7_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level7_type',p_level7_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level7_desc',p_level7_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level8' , p_level8);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level8_name',p_level8_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level8_type',p_level8_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level8_desc',p_level8_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level9' , p_level9);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level9_name',p_level9_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level9_type',p_level9_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level9_desc',p_level9_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level10' , p_level10);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level10_name',p_level10_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level10_type',p_level10_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level10_desc',p_level10_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level11' , p_level11);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level11_name',p_level11_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level11_type',p_level11_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level11_desc',p_level11_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level12' , p_level12);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level12_name',p_level12_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level12_type',p_level12_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level12_desc',p_level12_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level13' , p_level13);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level13_name',p_level13_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level13_type',p_level13_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level13_desc',p_level13_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level14' , p_level14);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level14_name',p_level14_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level14_type',p_level14_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level14_desc',p_level14_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level15' , p_level15);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level15_name',p_level15_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level15_type',p_level15_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_level15_desc',p_level15_desc);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_type_pk',p_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_type_name',p_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_type_desc',p_type);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_all_pk', p_all_name );
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_all_name',p_all_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_all_desc',p_all_name);
    DBMS_SQL.BIND_VARIABLE(p_CursorID, ':b_primarykey'   ,p_pk);

    p_RowsUpdated := DBMS_SQL.EXECUTE(p_CursorID);


  IF p_RowsUpdated=0 THEN
    begin
       setTimer(l_error_timestamp);
       open cur_check_error for
       'SELECT h'||p_hierachy_no||'15_pk
         FROM '|| g_dimension_name||'
         WHERE l1_pk= :s' using p_pk;
         FETCH cur_check_error into l_root_name;

       if cur_check_error%NOTFOUND then
         edw_log.put_line(
          'Warning : '||'Can not find '|| p_pk||' in dimension table.');
           g_completion_status:=1;
           logCumulatedTime( l_error_timestamp, g_err_cum_timestamp);
         return;
       else
          if l_root_name=p_level15 then
             raise l_dimond_error;
          else  raise l_root_setup_error;
          end if;
       end if;
       close cur_check_error;

    exception
      when l_dimond_error then
        g_diamond_output:=g_diamond_output+1;
        if g_diamond_output < g_err_smp_size  then
          edw_log.put_line(
          'Warning : Dimond shape or duplicate rows.
'||p_pk||' rolls up to '
          ||l_root_name||' twice in hierarchy '||p_hierachy_no||'. ');
        end if;
        g_completion_status:=1;
        logCumulatedTime( l_error_timestamp, g_err_cum_timestamp);

     when l_root_setup_error then
       g_rootsetup_error:=g_rootsetup_error+1;
       if g_rootsetup_error< g_err_smp_size then
          edw_log.put_line('Warning : Root setup error for '
          ||p_pk||':'||'.
'||p_pk||' rolls up to '
          ||l_root_name||' and '||p_level15||' in hierarchy '
          ||p_hierachy_no||'.
'||l_root_name||' is collected.');
       end if;
       g_completion_status:=1;
       logCumulatedTime( l_error_timestamp, g_err_cum_timestamp);

   end;
  END IF;  --for p_RowsUpdated=0
END IF;  --for p_hierachy_no <= 4 THEN

EXCEPTION
   WHEN OTHERS THEN
     edw_log.put_line( 'Error: When updating the dimension table. '
    ||sqlcode||' : '||sqlerrm);
     raise;
END update_dimension;

procedure check_stand_alone_value as
l_select_stmt varchar2(300);
l_cursor_id  number;
l_rows_fetched   number;
l_name      varchar2(80);
l_pk        varchar2(240);

  begin
     VBHDEBUG('Checking stand alone values...');
     l_select_stmt:= 'select l1_pk,l1_name from '||g_dimension_name||
                    ' where h115_pk = ''NA_EDW''  and h215_pk = ''NA_EDW''
                      and h315_pk = ''NA_EDW''  and h415_pk = ''NA_EDW''
                      order by l1_name';
     VBHDEBUG('Executing : ' || l_select_stmt);
     l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     DBMS_SQL.parse(l_cursor_id,l_select_stmt,DBMS_SQL.V7);
     DBMS_SQL.define_column(l_cursor_id,1,l_pk,240);
     DBMS_SQL.define_column(l_cursor_id,2,l_name,80);
     g_standalone:=DBMS_SQL.execute(l_cursor_id);
     g_standalone := 0;
     loop
         if DBMS_SQL.fetch_rows(l_cursor_id)=0 then
            exit;
         end if;
         if  g_standalone<= g_err_smp_size then
           DBMS_SQL.column_value (l_cursor_id,1,l_pk);
           DBMS_SQL.column_value (l_cursor_id,2,l_name);
	   VBHDEBUG('Stand alone value : '||'pk:'||l_pk||'  name:'||l_name);
         end if;
         g_standalone := g_standalone + 1;
     end loop;
     DBMS_SQL.close_cursor(l_cursor_id);
   exception
   when others then
      edw_log.put_line( 'Error : When checking stand alone node. '||sqlcode||' : '||sqlerrm);
  raise;
  end;


procedure check_root_set_up as
    l_set_of_books EDW_SET_OF_BOOKS%ROWTYPE;
    l_status_flag  varchar2(1):='Y';

    cursor cur_set_of_books is
    select *
    from edw_set_of_books
    where edw_set_of_books_id not in (
          select edw_set_of_books_id
          from edw_vbh_roots)
    and   edw_set_of_books_id not in (
          select edw_set_of_books_id
          from edw_equi_set_of_books)
    and   edw_set_of_books_id not in (
          select child_edw_set_of_books_id
          from edw_cons_set_of_books) ;
begin
  open cur_set_of_books;
  loop
  fetch cur_set_of_books into l_set_of_books;
  exit when cur_set_of_books%NOTFOUND;

  l_status_flag:='N';
  VBHDEBUG('Warning: No root specified for '
    ||l_set_of_books.instance||' : '||l_set_of_books.set_of_books_name);
  end loop;
  close cur_set_of_books;
  if(l_status_flag='N') then
    g_completion_status:=1;
  end if;
exception
   when others then
      edw_log.put_line( 'Error : When checking stand alone node. '||sqlcode||' : '||sqlerrm);
  raise;
end;

PROCEDURE CLOSE_UPDATE( p_CursorID IN OUT NOCOPY INTEGER) IS
BEGIN
    DBMS_SQL.CLOSE_CURSOR(p_CursorID);
    VBHDEBUG('Closed the update statement cursor');
    VBHDEBUG(' ');
END;


FUNCTION PARSE_UPDATE(p_hierachy_no integer ) return  integer
IS
  l_CursorID    INTEGER;
  l_UpdateStmt   varchar2(4000);
BEGIN
    l_CursorID := DBMS_SQL.OPEN_CURSOR;
    l_UpdateStmt :=
    'UPDATE '|| g_dimension_name||'
     SET LAST_UPDATE_DATE=sysdate,
         l1_type=:b_type,'
         ||' h'||p_hierachy_no||'02_pk=  :b_level2,'
         ||' h'||p_hierachy_no||'02_name=  :b_level2_name,'
         ||' h'||p_hierachy_no||'02_type=  :b_level2_type,'
         ||' h'||p_hierachy_no||'02_description =  :b_level2_desc,'
         ||' h'||p_hierachy_no||'03_pk=  :b_level3,'
         ||' h'||p_hierachy_no||'03_name=  :b_level3_name,'
         ||' h'||p_hierachy_no||'03_type=  :b_level3_type,'
         ||' h'||p_hierachy_no||'03_description =  :b_level3_desc,'
         ||' h'||p_hierachy_no||'04_pk=  :b_level4,'
         ||' h'||p_hierachy_no||'04_name=  :b_level4_name,'
         ||' h'||p_hierachy_no||'04_type=  :b_level4_type,'
         ||' h'||p_hierachy_no||'04_description =  :b_level4_desc,'
         ||' h'||p_hierachy_no||'05_pk=  :b_level5,'
         ||' h'||p_hierachy_no||'05_name=  :b_level5_name,'
         ||' h'||p_hierachy_no||'05_type=  :b_level5_type,'
         ||' h'||p_hierachy_no||'05_description =  :b_level5_desc,'
         ||' h'||p_hierachy_no||'06_pk=  :b_level6,'
         ||' h'||p_hierachy_no||'06_name=  :b_level6_name,'
         ||' h'||p_hierachy_no||'06_type=  :b_level6_type,'
         ||' h'||p_hierachy_no||'06_description =  :b_level6_desc,'
         ||' h'||p_hierachy_no||'07_pk=  :b_level7,'
         ||' h'||p_hierachy_no||'07_name=  :b_level7_name,'
         ||' h'||p_hierachy_no||'07_type=  :b_level7_type,'
         ||' h'||p_hierachy_no||'07_description =  :b_level7_desc,'
         ||' h'||p_hierachy_no||'08_pk=  :b_level8,'
         ||' h'||p_hierachy_no||'08_name=  :b_level8_name,'
         ||' h'||p_hierachy_no||'08_type=  :b_level8_type,'
         ||' h'||p_hierachy_no||'08_description =  :b_level8_desc,'
         ||' h'||p_hierachy_no||'09_pk=  :b_level9,'
         ||' h'||p_hierachy_no||'09_name=  :b_level9_name,'
         ||' h'||p_hierachy_no||'09_type=  :b_level9_type,'
         ||' h'||p_hierachy_no||'09_description =  :b_level9_desc,'
         ||' h'||p_hierachy_no||'10_pk=  :b_level10,'
         ||' h'||p_hierachy_no||'10_name=  :b_level10_name,'
         ||' h'||p_hierachy_no||'10_type=  :b_level10_type,'
         ||' h'||p_hierachy_no||'10_description=  :b_level10_desc,'
         ||' h'||p_hierachy_no||'11_pk=  :b_level11,'
         ||' h'||p_hierachy_no||'11_name=  :b_level11_name,'
         ||' h'||p_hierachy_no||'11_type=  :b_level11_type,'
         ||' h'||p_hierachy_no||'11_description=  :b_level11_desc,'
         ||' h'||p_hierachy_no||'12_pk=  :b_level12,'
         ||' h'||p_hierachy_no||'12_name=  :b_level12_name,'
         ||' h'||p_hierachy_no||'12_type=  :b_level12_type,'
         ||' h'||p_hierachy_no||'12_description=  :b_level12_desc,'
         ||' h'||p_hierachy_no||'13_pk=  :b_level13,'
         ||' h'||p_hierachy_no||'13_name=  :b_level13_name,'
         ||' h'||p_hierachy_no||'13_type=  :b_level13_type,'
         ||' h'||p_hierachy_no||'13_description=  :b_level13_desc,'
         ||' h'||p_hierachy_no||'14_pk=  :b_level14,'
         ||' h'||p_hierachy_no||'14_name=  :b_level14_name,'
         ||' h'||p_hierachy_no||'14_type=  :b_level14_type,'
         ||' h'||p_hierachy_no||'14_description=  :b_level14_desc,'
         ||' h'||p_hierachy_no||'15_pk=  :b_level15,'
         ||' h'||p_hierachy_no||'15_name=  :b_level15_name,'
         ||' h'||p_hierachy_no||'15_type=  :b_level15_type,'
         ||' h'||p_hierachy_no||'15_description=  :b_level15_desc,'
         ||' type_pk    =:b_type_pk,'
         ||' type_name    =:b_type_name,'
         ||' type_description =:b_type_desc,'
         ||' all_pk     =:b_all_pk,'
         ||' all_name     =:b_all_name,'
         ||' all_description  =:b_all_desc'
         ||' WHERE l1_pk= :b_primarykey AND  h'||p_hierachy_no||'02_pk = ''NA_EDW''';

     DBMS_SQL.PARSE(l_CursorID,l_UpdateStmt,DBMS_SQL.V7);
     VBHDEBUG('Parsed the update statement for hierarchy ' || p_hierachy_no );
     return l_CursorID;
END PARSE_UPDATE;

FUNCTION GET_VBH_ROOT ( p_root_sob_id integer, p_root varchar ) RETURN VARCHAR IS
  l_root_value varchar2(200);
BEGIN
  SELECT p_root ||'-'||set_of_books_id||'-'||instance
  INTO l_root_value
  FROM edw_set_of_books
  WHERE edw_set_of_books_id = p_root_sob_id;
  VBHDEBUG('l_root_value: '||l_root_value);

  return l_root_value;

  exception
    when others then
      edw_log.put_line( 'Error : When looking up root set_of_books_id. '
      ||sqlcode||' : '||sqlerrm);
      raise;
END GET_VBH_ROOT;

FUNCTION PROCESS_ROOT (p_root_value varchar, p_hieno integer, p_curid in integer)
RETURN INTEGER IS
  TYPE t_value_desc_pair_rec IS RECORD (
    value           edw_gl_acct1_m.l1_pk%TYPE,
    name            edw_gl_acct1_m.l1_name%TYPE,
    type            edw_gl_acct1_m.l1_type%TYPE,
    description     edw_gl_acct1_m.l1_description%TYPE);

  l_descLookup_timestamp  Date:=Null;

  TYPE t_cur_description IS ref cursor;
  cur_description t_cur_description;
  l_rowsUpdated  integer  := 0;
BEGIN
      --store the value of current root
      g_vbh_level_table(15).value     :=p_root_value;

      --look up the description for current root
      setTimer(l_descLookup_timestamp);
      OPEN cur_description FOR
      'select parent_name,parent_type,parent_desc
      from '|| g_vbh_temp_table_name||'
      WHERE parent=:s
      union all
      select child_name,child_type,child_desc
      from '|| g_vbh_temp_table_name||'
      WHERE child=:s ' using p_root_value,p_root_value;

      FETCH  cur_description INTO
          g_vbh_level_table(15).name,g_vbh_level_table(15).type, g_vbh_level_table(15).description;
      if cur_description%NOTFOUND then
         VBHDEBUG( 'Warning : Can not find '|| p_root_value||' in '
         || g_vbh_temp_table_name);
      end if;
      close cur_description;

      if(g_vbh_level_table(15).type is null) THEN
        g_vbh_level_table(15).type:= g_not_classified_type;
      end if;

     --create a dummy node for the root;
     update_dimension(
                  p_curid,
                  p_hieno,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  'ALL' ,
                  l_rowsUpdated);

  return l_rowsUpdated;
END PROCESS_ROOT;



FUNCTION PROCESS_ROOT_HIR(p_root_value varchar2, p_hie_no integer , p_curid in integer)
RETURN integer
IS
  TYPE t_vbh_temp_rec IS RECORD(
    parent          edw_vbh_temp1.parent%TYPE,
    parent_name     edw_vbh_temp1.parent_name%TYPE,
    parent_type     edw_vbh_temp1.parent_type%TYPE,
    parent_desc     edw_vbh_temp1.parent_desc%TYPE,
    child           edw_vbh_temp1.child%TYPE,
    child_name      edw_vbh_temp1.child_name%TYPE,
    child_type      edw_vbh_temp1.child_type%TYPE,
    child_desc      edw_vbh_temp1.child_desc%TYPE,
    total_level NUMBER);
  TYPE t_cur_vbh_temp_ref IS REF CURSOR;

  l_TreeBiuld_timestamp   Date:=Null;
  cur_vbh_temp t_cur_vbh_temp_ref;
  l_vbh_temp t_vbh_temp_rec;
  l_rowsUpdated    integer := 0;
  l_updates_for_root  integer := 0;
BEGIN

    setTimer(l_TreeBiuld_timestamp);
    OPEN cur_vbh_temp FOR
       'SELECT  parent,parent_name,parent_type,parent_desc,
                child,child_name,child_type,child_desc, level+1 total_level
        FROM '|| g_vbh_temp_table_name||'
        where child is not null
        START WITH parent =:s
        CONNECT BY parent=PRIOR child' using p_root_value;
    LOOP
       FETCH cur_vbh_temp INTO l_vbh_temp;
       EXIT WHEN cur_vbh_temp%NOTFOUND;


       -- WATCH OUT!!
       -- This FOR LOOP won't process levels deeper then 15
       FOR l_table_counter IN 1..(15-l_vbh_temp.total_level+1) LOOP
         g_vbh_level_table(l_table_counter).value:=l_vbh_temp.child;
         g_vbh_level_table(l_table_counter).name:=l_vbh_temp.child_name;

         if l_vbh_temp.child_type is null then
           g_vbh_level_table(l_table_counter).type:= g_not_classified_type;
         else
         g_vbh_level_table(l_table_counter).type:=l_vbh_temp.child_type;
         end if;

         g_vbh_level_table(l_table_counter).description:=l_vbh_temp.child_desc;

       END LOOP;


       -- added to implement the level collapsing when more then 15 levels are
       -- pulled into the EDW_VBH_TEMP# tables.
       -- all the values in levels deeper then 15th, will be merged in to the
       -- 15th( lowest level).

       IF l_vbh_temp.total_level > 15 then
         g_vbh_level_table(1).value:=l_vbh_temp.child;
         g_vbh_level_table(1).name:=l_vbh_temp.child_name;

         if l_vbh_temp.child_type is null then
           g_vbh_level_table(1).type:= g_not_classified_type;
         else
           g_vbh_level_table(1).type:=l_vbh_temp.child_type;
         end if;
         g_vbh_level_table(1).description:=l_vbh_temp.child_desc;
       END IF;

      update_dimension(
                  p_curid,
                  p_hie_no,
                  g_vbh_level_table(1).value,
                  g_vbh_level_table(1).type,
                  g_vbh_level_table(2).value,
                  g_vbh_level_table(2).name,
                  g_vbh_level_table(2).type,
                  g_vbh_level_table(2).description,
                  g_vbh_level_table(3).value,
                  g_vbh_level_table(3).name,
                  g_vbh_level_table(3).type,
                  g_vbh_level_table(3).description,
                  g_vbh_level_table(4).value,
                  g_vbh_level_table(4).name,
                  g_vbh_level_table(4).type,
                  g_vbh_level_table(4).description,
                  g_vbh_level_table(5).value,
                  g_vbh_level_table(5).name,
                  g_vbh_level_table(5).type,
                  g_vbh_level_table(5).description,
                  g_vbh_level_table(6).value,
                  g_vbh_level_table(6).name,
                  g_vbh_level_table(6).type,
                  g_vbh_level_table(6).description,
                  g_vbh_level_table(7).value,
                  g_vbh_level_table(7).name,
                  g_vbh_level_table(7).type,
                  g_vbh_level_table(7).description,
                  g_vbh_level_table(8).value,
                  g_vbh_level_table(8).name,
                  g_vbh_level_table(8).type,
                  g_vbh_level_table(8).description,
                  g_vbh_level_table(9).value,
                  g_vbh_level_table(9).name,
                  g_vbh_level_table(9).type,
                  g_vbh_level_table(9).description,
                  g_vbh_level_table(10).value,
                  g_vbh_level_table(10).name,
                  g_vbh_level_table(10).type,
                  g_vbh_level_table(10).description,
                  g_vbh_level_table(11).value,
                  g_vbh_level_table(11).name,
                  g_vbh_level_table(11).type,
                  g_vbh_level_table(11).description,
                  g_vbh_level_table(12).value,
                  g_vbh_level_table(12).name,
                  g_vbh_level_table(12).type,
                  g_vbh_level_table(12).description,
                  g_vbh_level_table(13).value,
                  g_vbh_level_table(13).name,
                  g_vbh_level_table(13).type,
                  g_vbh_level_table(13).description,
                  g_vbh_level_table(14).value,
                  g_vbh_level_table(14).name,
                  g_vbh_level_table(14).type,
                  g_vbh_level_table(14).description,
                  g_vbh_level_table(15).value,
                  g_vbh_level_table(15).name,
                  g_vbh_level_table(15).type,
                  g_vbh_level_table(15).description,
                  'ALL',
                  l_rowsUpdated);

     l_updates_for_root := l_updates_for_root + l_rowsUpdated;

     END LOOP;
     CLOSE cur_vbh_temp;
     logTime('buliding tree from root '|| p_root_value, l_TreeBiuld_timestamp);
     VBHDEBUG( l_updates_for_root || ' rows updated for root ' || p_root_value);
     return l_updates_for_root;
END PROCESS_ROOT_HIR;


Procedure Collect(Errbuf         out NOCOPY Varchar2,
                  Retcode        out NOCOPY Varchar2,
                  p_dimension_name in varchar2) IS

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
  p_dimension_no  number;
  l_rows_inserted      INTEGER :=0;
  l_table_counter      INTEGER;
  l_hierachy_no        NUMBER;
  l_rowsUpdated        INTEGER;
  l_root_value         edw_vbh_temp1.parent%TYPE;
  l_vbh_value          edw_gl_acct1_m.l1_pk%TYPE;
  l_vbh_name           edw_gl_acct1_m.l1_name%TYPE;
  l_vbh_desc           edw_gl_acct1_m.l1_description%TYPE;
  l_pk_key             edw_gl_acct1_m.l1_pk_key%TYPE;
  l_temp_table_name    varchar2(30);
  l_value_stmt         varchar2(1000);
  l_root_counter       Integer :=0;
  l_check_sob_id       number;
  l_program_status     boolean:=true;
  l_exe_status             boolean;
  l_status boolean;
  l_dir varchar2(400);
  l_seq_name varchar2(30);
  l_element_id number:=0;
  l_progress_seq_id number:=0;
  l_progress_status boolean;


  TYPE t_value_desc_pair_rec IS RECORD (
    value           edw_gl_acct1_m.l1_pk%TYPE,
    name            edw_gl_acct1_m.l1_name%TYPE,
    type            edw_gl_acct1_m.l1_type%TYPE,
    description     edw_gl_acct1_m.l1_description%TYPE);
  l_root_value_desc_pair t_value_desc_pair_rec;

  Type t_vbh_root_table is table of edw_vbh_roots.root_value1%type
    index by binary_integer;
  l_vbh_root_table t_vbh_root_table;


  l_vbh_root_sob_id edw_vbh_roots.edw_set_of_books_id%TYPE ;

  TYPE t_cur_vbh_root_ref IS REF CURSOR;
  cur_vbh_roots t_cur_vbh_root_ref;

  TYPE t_cur_vbh_all_value IS REF CURSOR;
  cur_vbh_all_value t_cur_vbh_all_value;

  l_start_date            date:= null;
  l_log_timestamp         Date:=Null;
  l_roots_timestamp       Date:=Null;
  l_hie_timstamp          Date:=Null;
  l_descLookup_timestamp  Date:=Null;
  --l_dummyroot_timestamp Date:=Null;
  l_CursorID              INTEGER;
  l_updates_for_root      INTEGER;

BEGIN
  -- ian debugging
  -- DBMS_SESSION.set_sql_trace(true);

  INITDEBUG;
  -- initialize global variable
  g_diamond_output :=0;
  g_standalone :=0;
  g_rootsetup_error:=0;
  g_err_cum_timestamp := 0;
  g_rows_updated      := 0;
  g_err_smp_size      := 20;
  g_rows_inserted     := 0;

  -- select sysdate into l_start_date from dual;
  setTimer(l_start_date);


  Errbuf :=NULL;
  Retcode:=0;

  g_conc_program_id  :=FND_GLOBAL.conc_request_id;
  g_conc_program_name:='EDWFVBCB';


  select dim_name into g_dimension_name
  from  edw_dimensions_md_v
  where dim_long_name = p_dimension_name;
  p_dimension_no := substr(g_dimension_name, 12 , instr(g_dimension_name, '_M') - 12 );

  g_vbh_temp_table_name:='EDW_VBH_TEMP'||p_dimension_no;
  g_global_temp_table:=g_dimension_name||'_temp';
  l_seq_name:='EDW_GL_ACCT'|| p_dimension_no||'_S';
  l_exe_status           :=true;
  g_completion_status:=0;
  l_element_id:=edw_owb_collection_util.GET_OBJECT_ID(g_dimension_name);
  edw_owb_collection_util.setup_conc_program_log(g_dimension_name);


  -- FND MESSAGE LOOKUP AREA
  FND_MESSAGE.SET_NAME('BIS', 'EDW_DIMENSION_LEVEL_TYPE');
  g_not_classified_type := FND_MESSAGE.GET;
  edw_log.put_line( 'Not Classfied Type lookup: ' || g_not_classified_type);

  FND_MESSAGE.SET_NAME('BIS', 'EDW_UNASSIGNED');
  g_na_edw := FND_MESSAGE.GET;
  edw_log.put_line( 'NA_EDW lookup: ' || g_na_edw);


  FND_MESSAGE.SET_NAME('BIS', 'EDW_INVALID');
  g_na_err := FND_MESSAGE.GET;
  edw_log.put_line( 'NA_ERR lookup: ' || g_na_err);


  FND_MESSAGE.SET_NAME('BIS', 'EDW_ALL');
  g_all := FND_MESSAGE.GET;
  edw_log.put_line( 'EDW_ALL lookup: ' || g_all);


  select edw_load_s.nextval
  into l_progress_seq_id
  from dual;


  edw_log.put_line( 'VBH Loading program for '|| p_dimension_name||' '||
       to_char(sysdate));

  edw_log.put_line('Dimension number '|| p_dimension_no);
  edw_log.put_line('Dimension physical name : '|| g_dimension_name);
  edw_log.put_line('Error Sample Display Size : '|| g_err_smp_size);

  edw_log.put_line('Collecting data...');
  if p_dimension_no<1 or p_dimension_no>10 then
       edw_log.put_line('Error : Invalid dimension number '
       ||p_dimension_no);
        g_completion_status:=2;
        l_exe_status:=false;
        l_program_status:=
            fnd_concurrent.set_completion_status('ERROR',NULL);
        return;
  end if;


  setTimer(l_log_timestamp);
  check_root_set_up;
  logTime('checking root setup', l_log_timestamp);


  setTimer(l_log_timestamp);
  insert_pk_key_into_table;
  logTime('inserting keys to global temp', l_log_timestamp);

  setTimer(l_log_timestamp);
  clean_up_dimension_table;
  logTime('cleaning up dimension star table', l_log_timestamp);

  --update edw_vbh_temp table to include type info
  edw_owb_collection_util.INSERT_INTO_LOAD_PROGRESS(
  l_progress_seq_id,
  g_dimension_name,
  l_element_id,
  'Updating Account Type Information',
   sysdate,
   null,
   null,
   null,
   100,
   'I',
   l_element_id);

   setTimer(l_log_timestamp);
   update_class;
   logTime('updating class', l_log_timestamp);

   edw_owb_collection_util.INSERT_INTO_LOAD_PROGRESS(
   l_progress_seq_id,
   g_dimension_name,
   l_element_id,
   null,
   null,
   sysdate,
   null,
   null,
   100,
   'U',
   l_element_id);

   edw_owb_collection_util.INSERT_INTO_LOAD_PROGRESS(
   l_progress_seq_id,
   g_dimension_name,
   l_element_id,
   'Insert Lowest Level into Dimension Table',
   sysdate,
   null,
   null,
   null,
   110,
   'I',
   l_element_id);

   --insert default value to dimension tables
   setTimer(l_log_timestamp);
   insert_default_values(l_seq_name);
   logTime('Inserting default values to dimension star table for active values', l_log_timestamp);
   VBHDEBUG(' ');

   setTimer(l_log_timestamp);
   insert_default_value('NA_EDW',0,g_na_edw,g_na_edw);
   logTime('Inserting default value for NA_EDW ', l_log_timestamp);
   VBHDEBUG(' ');

   setTimer(l_log_timestamp);
   insert_default_value('NA_ERR',-1,g_na_err,g_na_err);
   logTime('Inserting default value for NA_ERR ', l_log_timestamp);
   VBHDEBUG(' ');


   setTimer(l_log_timestamp);
   insert_non_active_values;
   logTime('Inserting default values into dimension star table for non-active nodes', l_log_timestamp);
   VBHDEBUG(' ');

   -- add commit here to reduce the rollback segment space requirement a bit!
   COMMIT;

   edw_owb_collection_util.INSERT_INTO_LOAD_PROGRESS(
   l_progress_seq_id,
   g_dimension_name,
   l_element_id,
   null,
   null,
   sysdate,
   null,
   null,
   110,
   'U',
   l_element_id);

   setTimer(l_roots_timestamp);
   OPEN cur_vbh_roots for
     SELECT distinct e1.edw_set_of_books_id,e1.root_value1,e1.root_value2,
                                         e1.root_value3,e1.root_value4
     FROM edw_vbh_roots e1, edw_set_of_books e2
     WHERE e1.edw_set_of_books_id=e2.edw_set_of_books_id
          and e1.segment_name =(
            select segment_name
            FROM   EDW_FLEX_SEG_MAPPINGS_V
            WHERE  DIMENSION_SHORT_NAME=g_dimension_name
            and    structure_num=e2.chart_of_accounts_id
            and    lower(instance_code)=lower(e2.instance));
   LOOP
      FETCH cur_vbh_roots
      INTO  l_vbh_root_sob_id,l_vbh_root_table(1),l_vbh_root_table(2)
                             ,l_vbh_root_table(3),l_vbh_root_table(4);
      EXIT WHEN cur_vbh_roots%NOTFOUND;
      l_hierachy_no:=0;

    for l_root_counter in 1..4 LOOP
       setTimer(l_hie_timstamp);
       l_hierachy_no := l_root_counter;

       -- parse the update statement for each root definition,
       -- not for each row, this will gain some performance back.
       l_CursorID := PARSE_UPDATE(l_hierachy_no);


       edw_owb_collection_util.INSERT_INTO_LOAD_PROGRESS(
         l_progress_seq_id,
         g_dimension_name,
         l_element_id,
         'Build Hierarchy '|| l_hierachy_no,
         sysdate,
         null,
         null,
         null,
         110+ l_hierachy_no,
         'I',
         l_element_id);

       if (l_hierachy_no  <=4 and l_vbh_root_table(l_root_counter) is not null) then
         l_root_value := GET_VBH_ROOT(l_vbh_root_sob_id, l_vbh_root_table(l_root_counter));

         l_rowsUpdated := PROCESS_ROOT(l_root_value,l_hierachy_no, l_CursorID);
         g_rows_updated:=g_rows_updated+l_rowsUpdated;

         l_rowsUpdated := PROCESS_ROOT_HIR(l_root_value,l_hierachy_no, l_CursorID);
         g_rows_updated:=g_rows_updated+l_rowsUpdated;

         -- done with the hierarchy, close the update cursor.
         CLOSE_UPDATE(l_CursorID);

       else
         if l_hierachy_no  >4 then
            edw_log.put_line('Warning : More than 4 roots.');
         end if;
       end if;

       edw_owb_collection_util.INSERT_INTO_LOAD_PROGRESS(
         l_progress_seq_id,
         g_dimension_name,
         l_element_id,
         null,
         null,
         sysdate,
         null,
         null,
         110+ l_hierachy_no,
         'U',
         l_element_id);
        logTime('For hierarchy ' || l_root_counter , l_hie_timstamp);
    END LOOP;--for the for loop of root value
   END LOOP;
   CLOSE cur_vbh_roots;

  edw_log.put_line('Finished collecting data.');

  setTimer(l_log_timestamp);
  check_stand_alone_value;
  logTime('checking stand along values', l_log_timestamp);


  if (g_completion_status=0) then
    l_program_status:=
       fnd_concurrent.set_completion_status('NORMAL', 'NORMAL COMPLETION');
       edw_log.put_line('Normal complete.');
       setTimer(l_log_timestamp);
       clean_up_temp_table;
       logTime('cleaning up vbh temp table', l_log_timestamp);

       setTimer(l_log_timestamp);
       clean_up_global_temp_table;
       logTime('cleaning up global temp table', l_log_timestamp);

       l_status:=edw_owb_collection_util.write_to_collection_log(
       g_dimension_name,
       l_element_id,
       'DIMENSION',
       g_conc_program_id,
       l_start_date,
       sysdate,
       null,
       g_rows_updated,
       g_rows_updated,
       null,
       null,
       null,
       'SUCCESS',
       'SUCCESS', l_progress_seq_id);

  elsif (g_completion_status=1) then
    l_program_status:=
       fnd_concurrent.set_completion_status('WARNING',NULL);
       edw_log.put_line('Complete with warning.');
       setTimer(l_log_timestamp);
       clean_up_temp_table;
       logTime('cleaning up vbh temp table', l_log_timestamp);

       setTimer(l_log_timestamp);
       clean_up_global_temp_table;
       logTime('cleaning up global temp table', l_log_timestamp);

    l_status:=edw_owb_collection_util.write_to_collection_log(
       g_dimension_name,
       l_element_id,
       'DIMENSION',
       g_conc_program_id,
      l_start_date,
      sysdate,null,
      g_rows_updated,
      g_rows_updated,null,null,null,
      'WARNING',
      'WARNING', l_progress_seq_id);

  elsif (g_completion_status=2) then
     l_program_status:=
       fnd_concurrent.set_completion_status('ERROR',NULL);
       edw_log.put_line('Error.');
    l_status:=edw_owb_collection_util.write_to_collection_log(
       g_dimension_name,
       l_element_id,
       'DIMENSION',
       g_conc_program_id,
      l_start_date,
      sysdate,null,
      g_rows_updated,
      g_rows_updated,null,null,null,
      'ERROR',
      'ERROR',l_progress_seq_id);

  end if;
  COMMIT;
 edw_log.put_line('Total number of rows updated: '||g_rows_updated );
 edw_log.put_line('Total number of diamond hits: '||g_diamond_output);
 edw_log.put_line('Total number of standalone nodes: '||g_standalone);
 edw_log.put_line('Total number of root setup errors: '||g_rootsetup_error);
 edw_log.put_line('Total time spent on error handling : '|| edw_log.duration(g_err_cum_timestamp));
 edw_log.put_line('finished loading VBH');
 edw_log.put_line('current time :'||to_char(sysdate,'DD-MON-YYYY HH24:MI:SS'));
 logTime('the whole VBH Loading', l_start_date);

 --added for bug 4124723
 -- Call Function to create level MV's
 create_dim_levels_mv(p_dimension_no);

EXCEPTION
   WHEN OTHERS THEN
     Errbuf :=sqlerrm;
     Retcode:=sqlcode;
     l_exe_status:=false;
     g_completion_status:=2;

 l_status:= edw_owb_collection_util.write_to_collection_log(
    g_dimension_name,
    l_element_id,
    'DIMENSION',
    g_conc_program_id,
    l_start_date,
    sysdate,null,
    0,
    0,null,null,null,
    'Error : '||sqlcode||' : '||sqlerrm ,
    'ERROR',l_progress_seq_id);

     edw_log.put_line( 'Error : '||sqlcode||' : '||sqlerrm);
     l_program_status:=
        fnd_concurrent.set_completion_status('ERROR',NULL);
     rollback;
END; --end collection program

/**
    Added for bug 4124723, retunrs APPS scehma name
 **/
FUNCTION get_apps_schema_name RETURN VARCHAR2 IS

  l_apps_schema_name VARCHAR2(30);

  CURSOR c_apps_schema_name IS
  SELECT oracle_username
  FROM fnd_oracle_userid WHERE oracle_id
  BETWEEN 900 AND 999 AND read_only_flag = 'U';
BEGIN

  OPEN c_apps_schema_name;
  FETCH c_apps_schema_name INTO l_apps_schema_name;
  CLOSE c_apps_schema_name;
  RETURN l_apps_schema_name;

EXCEPTION
     WHEN OTHERS THEN
	RETURN NULL;
END get_apps_schema_name;


/**
    Added for bug 4124723
    This Procedure will create/refresh MV for all the levels in GL dimensions.
    This will called after refreshing Dimension table from Collect.
 **/
Procedure create_dim_levels_mv (p_dim_no IN varchar2) IS

  db_versn        varchar2(100);
  l_mview_name    varchar2(30);
  l_tmp_name      varchar2(30);
  l_stmt_mvcrt    varchar2(1000);
  l_level_counter number;
  l_hierarchy_cnt number;
  l_lvl_num       NUMBER;
  L_schema_name   VARCHAR2(30);
  l_tspace_name   VARCHAR2(30);
  l_stmt          VARCHAR2(1000);

  CURSOR c_mv_exists(p_mv_name varchar2, p_schema_name varchar2 ) IS
  SELECT MVIEW_NAME FROM ALL_MVIEWS WHERE OWNER = p_schema_name
  AND MVIEW_NAME= p_mv_name;

BEGIN

  l_mview_name := NULL;
  l_tmp_name   := NULL;

  --check database version. it should be 9i or above
  --get the version
  select version into db_versn from v$instance;
  edw_log.put_line( 'Database Version:= '||db_versn);
  select replace(substr(version,1,instr(version,'.',1,2)-1),'.') into db_versn from v$instance;

  l_stmt:= 'select tablespace_name from all_tables where table_name='''||g_dimension_name||''' and owner='''||get_bis_schema_name||'''';
  execute immediate l_stmt into l_tspace_name;

  l_schema_name := get_apps_schema_name;
  if(db_versn>=90) then --Database version is 9i or above

    for l_hierarchy_cnt in 1..4 LOOP --- for all four hierarchies
      for l_level_counter in 2..15 LOOP --- for all 15 levels in a hierarchy


        l_lvl_num := l_hierarchy_cnt*100+l_level_counter ;

        l_mview_name:= 'EDW_GLACT'||p_dim_no|| '_H'||l_lvl_num||'_MV';

        edw_log.put_line( 'Checking if MV ' || l_mview_name||' Exists in the Database');

        --check if the MV exists
        OPEN c_mv_exists(l_mview_Name,l_schema_name);
	fetch c_mv_exists into l_tmp_name;
        CLOSE c_mv_exists;

        --- if the mv exists refresh all the levels mv
        if(l_tmp_name is not null) then
          edw_log.put_line( 'Refreshing MV'||l_mview_name);
          dbms_mview.refresh (l_mview_name,'C');
        else  -- if mv does not exist creat MV's
          l_stmt_mvcrt := 'CREATE MATERIALIZED VIEW '|| l_mview_name||' TABLESPACE '||l_tspace_name || ' ENABLE QUERY REWRITE AS SELECT DISTINCT '|| 'H'||l_lvl_num||'_NAME'||' FROM '||g_dimension_name;
          edw_log.put_line(l_stmt_mvcrt);
          execute immediate l_stmt_mvcrt;
        end if;

        --call gather stats for the MV
        dbms_stats.gather_table_stats(l_schema_name,l_mview_name);

        l_tmp_name:=NULL;
      END LOOP;

    END LOOP;
  else
    edw_log.put_line( 'Database Version is lower than 9i dimension levls MVs won''t be created '||db_versn);
  end if;

  edw_log.put_line( 'Create_dim_levelS_Mv completed successfully');

EXCEPTION
  WHEN OTHERS THEN
    edw_log.put_line( 'Error : '||sqlcode||' : '||sqlerrm);
    edw_log.put_line( 'Warning MV Creation for Dimension levels Failed! Ignorable Error');
END create_dim_levels_mv;

END EDW_GL_ACCT_M_T;

/
