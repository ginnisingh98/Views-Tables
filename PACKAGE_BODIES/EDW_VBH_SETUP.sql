--------------------------------------------------------
--  DDL for Package Body EDW_VBH_SETUP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_VBH_SETUP" as
/* $Header: EDWVBHSB.pls 120.2 2006/02/27 03:34:12 rkumar noship $ */
procedure LOOKUP_DB_LINK(P_INSTANCE IN VARCHAR2,
                         p_status out nocopy boolean,
                         p_errMsg out nocopy varchar2,
                         p_db_link out nocopy varchar2)  IS

  begin
    select warehouse_to_instance_link
    into p_db_link
    from edw_source_instances
    where instance_code=p_instance
    and warehouse_to_instance_link is not null
    and enabled_flag='Y';
    p_status:=true;
  exception
    when others then
      p_db_link := null;
      p_status:=false;
      p_errMsg:=sqlcode||':'||sqlerrm;
end lookup_db_link;

PROCEDURE INSERT_INTO_EDW_SET_OF_BOOKS(
    p_status out nocopy boolean,
    p_errMsg out nocopy varchar2) AS
    l_instance_code edw_source_instances.instance_code%TYPE;
    l_instance_link edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
    l_insert_stmt     varchar2(20000);
    l_cursor_id       integer;
    l_rows_inserted   integer:=0;
    l_stmt varchar2(100);
    cursor l_source_instances_cur is
    select INSTANCE_CODE,WAREHOUSE_TO_INSTANCE_LINK
    from edw_source_instances
    where WAREHOUSE_TO_INSTANCE_LINK is not null
    and enabled_flag ='Y'
    order by instance_code;
  begin
    l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;
    delete from edw_set_of_books;
    delete from edw_cons_set_of_books;
    delete from edw_equi_set_of_books;
    delete from edw_vbh_roots;
    delete from edw_segment_classes;
    open l_source_instances_cur;
    loop
    fetch l_source_instances_cur into l_instance_code,l_instance_link;
    exit when l_source_instances_cur%NOTFOUND;

     l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     l_insert_stmt:= 'insert into edw_set_of_books(EDW_SET_OF_BOOKS_ID,
        instance,
        SET_OF_BOOKS_ID,
        SET_OF_BOOKS_NAME ,
        CHART_OF_ACCOUNTS_ID,
        description,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY ,
        LAST_UPDATE_LOGIN
     )
      select EDW_SET_OF_BOOKS_S.nextval,'''||l_instance_code||''',set_of_books_id,
      name,CHART_OF_ACCOUNTS_ID,description,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id
      from gl_sets_of_books@'||l_instance_link
     ||' where CHART_OF_ACCOUNTS_ID in (select distinct STRUCTURE_NUM  from edw_flex_seg_mappings_v where instance_code=:b_instance_code)';
      DBMS_SQL.parse(l_cursor_id,l_insert_stmt,DBMS_SQL.V7);
      DBMS_SQL.bind_variable(l_cursor_id,':b_instance_code',l_instance_code);
      l_rows_inserted:=DBMS_SQL.execute(l_cursor_id);
      DBMS_SQL.close_cursor(l_cursor_id);
   commit;
   end loop;
   close l_source_instances_cur;
   exception
   when others then
     p_status :=false;
     p_errMsg:=sqlcode||':'||sqlerrm;

end insert_into_edw_set_of_books;

procedure insert_source(p_status out nocopy boolean,p_errMsg out nocopy varchar2) is
  l_instance_link edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
  l_instance_code   edw_source_instances.instance_code%TYPE;
  l_insert_stmt     varchar2(20000);
  l_delete_stmt     varchar2(200);
  l_stmt varchar2(1000);

  cursor l_source_instances_cur is
  select warehouse_to_instance_link, INSTANCE_CODE
  from   edw_source_instances
  where  WAREHOUSE_TO_INSTANCE_LINK is not null
  and enabled_flag='Y';

  begin
    l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;

    open l_source_instances_cur;
    loop
    fetch l_source_instances_cur into l_instance_link, l_instance_code;
    exit when l_source_instances_cur%NOTFOUND;

      l_delete_stmt:='delete from EDW_LOCAL_SET_OF_BOOKS@'||l_instance_link;
      execute immediate l_delete_stmt;

     l_insert_stmt:= 'insert into EDW_LOCAL_SET_OF_BOOKS@'||l_instance_link||'
       (EDW_SET_OF_BOOKS_ID,
        instance,
        SET_OF_BOOKS_ID,
        SET_OF_BOOKS_NAME ,
        CHART_OF_ACCOUNTS_ID,
        description,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY ,
        LAST_UPDATE_LOGIN
        )
    select EDW_SET_OF_BOOKS_ID,
           instance,
           SET_OF_BOOKS_ID,
           SET_OF_BOOKS_NAME ,
           CHART_OF_ACCOUNTS_ID,
           description,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY ,
           LAST_UPDATE_LOGIN
       from edw_set_of_books
       WHERE instance = ''' || l_instance_code || '''';

     execute immediate l_insert_stmt;
    end loop;
    COMMIT;
   close  l_source_instances_cur;
   exception
   when others then
   p_status :=false;
   p_errMsg:=sqlcode||':'||sqlerrm;
end insert_source;


procedure insert_cons_to_source(p_status out nocopy boolean,p_errMsg out nocopy varchar2) is
  l_instance_link edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
  l_insert_stmt     varchar2(20000);
  l_delete_stmt     varchar2(200);
  l_delete_cursor_id       integer;
  l_insert_cursor_id       integer;
  l_rows_deleted    integer:=0;
  l_rows_inserted   integer:=0;
  l_stmt varchar2(100);

  cursor l_source_instances_cur is
  select WAREHOUSE_TO_INSTANCE_LINK
  from   edw_source_instances
  where  WAREHOUSE_TO_INSTANCE_LINK is not null
  and    enabled_flag ='Y';

  begin
    l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;

    open l_source_instances_cur;
    loop
    fetch l_source_instances_cur into l_instance_link;
    exit when l_source_instances_cur%NOTFOUND;

      l_delete_cursor_id:=DBMS_SQL.OPEN_CURSOR;
      l_delete_stmt:='delete from EDW_LOCAL_CONS_SET_OF_BOOKS@'||l_instance_link;
      DBMS_SQL.parse(l_delete_cursor_id,l_delete_stmt,DBMS_SQL.V7);
      l_rows_deleted:=DBMS_SQL.execute(l_delete_cursor_id);
      commit;
      DBMS_SQL.close_cursor(l_delete_cursor_id);

     l_insert_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     l_insert_stmt:= 'insert into EDW_LOCAL_CONS_SET_OF_BOOKS@'||l_instance_link||'
       (child_EDW_SET_OF_BOOKS_ID,
        parent_edw_SET_OF_BOOKS_ID,
        consolidation_id,
        consolidation_NAME,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY ,
        LAST_UPDATE_LOGIN
        )
    select child_EDW_SET_OF_BOOKS_ID,
           parent_edw_SET_OF_BOOKS_ID,
           consolidation_id,
           consolidation_NAME,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY ,
           LAST_UPDATE_LOGIN
    from edw_cons_set_of_books';
   DBMS_SQL.parse(l_insert_cursor_id,l_insert_stmt,DBMS_SQL.V7);
   l_rows_inserted:=DBMS_SQL.execute(l_insert_cursor_id);
   commit;
   DBMS_SQL.close_cursor(l_insert_cursor_id);
   end loop;
 close  l_source_instances_cur;

   exception
     when others then
     p_status :=false;
     p_errMsg:=sqlcode||':'||sqlerrm;
   end insert_cons_to_source;


procedure insert_equi_to_source(p_status out nocopy boolean, p_errMsg out nocopy varchar2) is
  l_instance_link edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
  l_insert_stmt     varchar2(20000);
  l_delete_stmt     varchar2(200);
  l_delete_cursor_id       integer;
  l_insert_cursor_id       integer;
  l_rows_deleted    integer:=0;
  l_rows_inserted   integer:=0;
  l_stmt varchar2(100);

  cursor l_source_instances_cur is
  select WAREHOUSE_TO_INSTANCE_LINK
  from   edw_source_instances
  where  WAREHOUSE_TO_INSTANCE_LINK is not null
  and    enabled_flag='Y';

  begin
    l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;

    open l_source_instances_cur;
    loop
    fetch l_source_instances_cur into l_instance_link;
    exit when l_source_instances_cur%NOTFOUND;

      l_delete_cursor_id:=DBMS_SQL.OPEN_CURSOR;
      l_delete_stmt:='delete from EDW_LOCAL_EQUI_SET_OF_BOOKS@'||l_instance_link;
      DBMS_SQL.parse(l_delete_cursor_id,l_delete_stmt,DBMS_SQL.V7);
      l_rows_deleted:=DBMS_SQL.execute(l_delete_cursor_id);
      commit;
      DBMS_SQL.close_cursor(l_delete_cursor_id);

     l_insert_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     l_insert_stmt:= 'insert into EDW_LOCAL_EQUI_SET_OF_BOOKS@'||l_instance_link||'
       (EDW_SET_OF_BOOKS_ID,
        equi_SET_OF_BOOKS_ID,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY ,
        LAST_UPDATE_LOGIN
        )
    select EDW_SET_OF_BOOKS_ID,
           equi_SET_OF_BOOKS_ID,
           CREATION_DATE,
           CREATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATED_BY ,
           LAST_UPDATE_LOGIN
    from edw_equi_set_of_books';
   DBMS_SQL.parse(l_insert_cursor_id,l_insert_stmt,DBMS_SQL.V7);
   l_rows_inserted:=DBMS_SQL.execute(l_insert_cursor_id);
   commit;
   DBMS_SQL.close_cursor(l_insert_cursor_id);
   end loop;
 close  l_source_instances_cur;

 exception
   when others then
   p_status :=false;
   p_errMsg:=sqlcode||':'||sqlerrm;
 end insert_equi_to_source;

  procedure lookup_sob_coa_id(
    p_db_link in varchar2,
    p_sob_name in varchar2,
    p_sob_id out nocopy number,
    p_coa_id out nocopy number,
    p_description out nocopy varchar2,
    p_status out nocopy boolean,
    p_errMsg out nocopy varchar2) is
    l_select_stmt varchar2(2000);
    l_rows_selected number;
    l_cursor_id number;
    l_sob_id number;
    l_coa_id number;
    l_description varchar2(240);
	l_stmt varchar2(100);

  begin

    l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;

    l_cursor_id:=dbms_sql.open_cursor;
    l_select_stmt :=
      'select set_of_books_id, chart_of_accounts_id, description
       from gl_sets_of_books@'||p_db_link||'
       where name = :b_sob_name';
    dbms_sql.parse(l_cursor_id,l_select_stmt,dbms_sql.v7);
    dbms_sql.bind_variable(l_cursor_id,':b_sob_name',p_sob_name);
    dbms_sql.define_column(l_cursor_id,1,l_sob_id);
    dbms_sql.define_column(l_cursor_id,2,l_coa_id);
    dbms_sql.define_column(l_cursor_id,3,l_description,240);
    l_rows_selected:= dbms_sql.execute(l_cursor_id);
    if(dbms_sql.fetch_rows(l_cursor_id)=0) then
      p_status:=false;
      fnd_message.set_name('BIS','EDW_NODATA_SET_OF_BOOKS');
      fnd_message.set_token('NAME', p_sob_name);
      p_errMsg:=fnd_message.get;
      --p_errMsg:='Cannot find '||p_sob_name||' in gl_sets_of_books';
    else
      dbms_sql.column_value(l_cursor_id,1,l_sob_id);
      dbms_sql.column_value(l_cursor_id,2,l_coa_id);
      dbms_sql.column_value(l_cursor_id,3,l_description);
      p_sob_id:=l_sob_id;
      p_coa_id:=l_coa_id;
      p_description:= l_description;
      p_status:=true;
   end if;
   exception
   when others then
       p_sob_id := null;
       p_coa_id := null;
       p_description := null;
       p_status:=false;
       p_errMsg:=sqlcode||':'||sqlerrm;
  end;


  procedure lookup_wh_dimension_name(
                 p_instance in varchar2,
                 p_segment_name in varchar2,
                 p_coa_id in number,
                 p_wh_dimension_name out nocopy varchar2,
                 p_status out nocopy boolean,
                 p_errMsg out nocopy varchar2) is
  begin

       select dim_long_name
       into  p_wh_dimension_name
       from edw_dimensions_md_v
       where dim_name =(
         select DIMENSION_SHORT_NAME
         from edw_flex_seg_mappings_v
         where lower(instance_code)=lower(p_instance)
         and segment_name =p_segment_name
         and structure_num=p_coa_id);
     p_status:=true;
    exception
      when others then
        p_wh_dimension_name := null;
        p_status :=false;
        p_errMsg:=sqlcode||':'||sqlerrm;
    end lookup_wh_dimension_name;

  FUNCTION check_db_status_all(x_instance_code OUT NOCOPY VARCHAR2)
     return boolean IS

  l_status	BOOLEAN := TRUE;
  l_instance_code	VARCHAR2(30);
  l_db_link     edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
  --l_db_link	VARCHAR2(30);
  l_progress	VARCHAR2(3):= '000';
  l_dummy		VARCHAR2(30);
  l_dummy_int     NUMBER;
  cid		NUMBER;
  l_stmt varchar2(100);
  l_temp	number := 0;

  CURSOR instances IS
    SELECT instance_code, warehouse_to_instance_link
    FROM   edw_source_instances
    WHERE  enabled_flag = 'Y';

  BEGIN

   l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;

    x_instance_code:='';
    l_progress := '010';
    -- Check to make sure that all the enabled OLTP sources are up and running
    cid := DBMS_SQL.open_cursor;
    OPEN instances;
    LOOP
	BEGIN
	   l_progress := '020';

            FETCH instances INTO l_instance_code, l_db_link;
	    EXIT WHEN instances%NOTFOUND;

	    -- Store the instance name in the out parameter to return

	    DBMS_SQL.PARSE(cid, 'SELECT 1 FROM sys.dual@'||l_db_link, dbms_sql.native);
            l_dummy_int := DBMS_SQL.EXECUTE(cid);
	    l_progress := '030';
        EXCEPTION
            when others then
            l_status := FALSE;
            x_instance_code:=x_instance_code||l_instance_code||' ';
            edw_message_s.sql_error('check_db_status',l_progress,sqlcode);
 	END;
    END LOOP;
    CLOSE instances;
    DBMS_SQL.close_cursor(cid);
    return l_status;

    exception
      when others then
	DBMS_SQL.close_cursor(cid);
        x_instance_code := null;
        return false;
END check_db_status_all;

--changed to_set_of_books_id to to_ledger_id for bug#4583057
--changed from_set_of_books_id to from_ledger_id for bug#4583057
procedure check_valid_consolidation
(p_instance in varchar2,p_from_ledger_id in number,
 p_to_ledger_id in number,p_result out nocopy boolean,
 p_status out nocopy boolean,p_error_mesg out nocopy varchar2)AS
l_instance_link edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
l_select_stmt     varchar2(20000);
l_cursor_id       integer;
l_rows_selected   integer:=0;
l_count number;
l_status boolean;
l_errMsg varchar2(80);
l_stmt varchar2(100);

begin

    l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;


   lookup_db_link(p_instance,l_status,l_errMsg,l_instance_link);
   if(l_status) then
     l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
     l_select_stmt:=
     'select count(*)
      into :b_count
      from gl_consolidation@'||l_instance_link||'
      where from_ledger_id =:b_from_ledger_id
      and   to_ledger_id=:b_to_ledger_id';
     DBMS_SQL.parse(l_cursor_id,l_select_stmt,DBMS_SQL.V7);
     DBMS_SQL.BIND_VARIABLE(l_cursor_id,':b_from_ledger_id',
                            p_from_ledger_id);
     DBMS_SQL.BIND_VARIABLE(l_cursor_id,':b_to_ledger_id',
                            p_to_ledger_id);
     DBMS_SQL.define_column(l_cursor_id,1,l_count);
     l_rows_selected:=DBMS_SQL.execute(l_cursor_id);

     if(DBMS_SQL.fetch_rows(l_cursor_id)=0) then
         p_status:=false;
         p_result:=false;
         return;
     end if;

     DBMS_SQL.column_value(l_cursor_id,1,l_count);
     DBMS_SQL.close_cursor(l_cursor_id);
     if l_count=0 then
         p_status:=true;
         p_result:=false;
     elsif  l_count>0 then
         p_status:=true;
         p_result:=true;
     end if;

  else
      p_status:=false;
      p_result:=false;
      p_error_mesg:=l_errMsg;
  end if;
  exception
    when others then
      p_status:=false;
      p_result:=false;
      p_error_mesg:=sqlcode||':'||sqlerrm;
end;

--changed from_set_of_books_id to from_ledger_id for bug#4583057
procedure get_consolidation_id
(p_instance in varchar2,
 p_from_ledger_id in number,
 p_to_ledger_id in number,
 p_consolidation_name in varchar2,
 p_consolidation_id out nocopy number,
 p_status out nocopy boolean,
 p_error_mesg out nocopy varchar2)AS
l_instance_link edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
l_select_stmt     varchar2(20000);
l_cursor_id       integer;
l_rows_selected   integer:=0;
l_count number;
l_stmt varchar2(100);

begin

   l_stmt:='alter session set global_names = FALSE';
    execute immediate l_stmt;

   lookup_db_link(p_instance,p_status, p_error_mesg,l_instance_link );
   if(p_status) then
       l_cursor_id:=DBMS_SQL.OPEN_CURSOR;
       l_select_stmt:=
             'select consolidation_id
              into :b_consolidation_id
              from gl_consolidation@'||l_instance_link||'
              where from_ledger_id =:b_from_ledger_id
              and   to_ledger_id=:b_to_ledger_id
              and name =:b_consolidation_name';
       DBMS_SQL.parse(l_cursor_id,l_select_stmt,DBMS_SQL.V7);
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':b_from_ledger_id',
                              p_from_ledger_id);
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':b_to_ledger_id',
                              p_to_ledger_id);
       DBMS_SQL.BIND_VARIABLE(l_cursor_id,':b_consolidation_name',
                              p_consolidation_name);
       DBMS_SQL.define_column(l_cursor_id,1,p_consolidation_id);
       l_rows_selected:=DBMS_SQL.execute(l_cursor_id);

       if(DBMS_SQL.fetch_rows(l_cursor_id)>0) then
          p_status:=true;
          DBMS_SQL.column_value(l_cursor_id,1,p_consolidation_id);
       else
           p_status:=false;
       end if;
           DBMS_SQL.close_cursor(l_cursor_id);
       end if;
  exception
      when others then
      p_status:=false;
      p_consolidation_id := null;
      p_error_mesg := sqlcode||':'||sqlerrm;
end;

procedure check_root_all (p_status out nocopy boolean,
                          p_problem_sob_id out nocopy integer,
                          p_problem_sob_id2 out nocopy integer,
                          p_hierarchy_no out nocopy integer,
                          p_segment_name out nocopy varchar2) as
   l_edw_sob_id number(15);
   l_segment_name varchar2(30);
   l_root_value1 varchar2(240);
   l_root_value2 varchar2(240);
   l_root_value3 varchar2(240);
   l_root_value4 varchar2(240);
   l_instance    varchar2(30);

   cursor l_cur_edw_vbh_roots is
     select edw_set_of_books_id,segment_name,
            root_value1,root_value2,root_value3,root_value4
     from edw_vbh_roots;
   begin
     open l_cur_edw_vbh_roots;
     loop
        fetch l_cur_edw_vbh_roots into l_edw_sob_id,l_segment_name,
        l_root_value1,l_root_value2,l_root_value3,l_root_value4;
        exit when l_cur_edw_vbh_roots%NOTFOUND;
        select instance into l_instance
        from edw_set_of_books
        where edw_set_of_books_id= l_edw_sob_id;
        p_problem_sob_id2:=l_edw_sob_id;
        p_segment_name := l_segment_name;

        if l_root_value1 IS NOT NULL THEN
           check_vbh_root_setup (l_edw_sob_id, l_segment_name, l_instance,1,
           p_status, p_problem_sob_id);
           p_hierarchy_no:=1;
           if p_status = false then return;
           end if;
        end if;

        if l_root_value2 IS NOT NULL THEN
           check_vbh_root_setup (l_edw_sob_id, l_segment_name, l_instance,2,
           p_status, p_problem_sob_id);
           p_hierarchy_no:=2;
           if p_status = false then return;
           end if;
        end if;

        if l_root_value3 IS NOT NULL THEN
           check_vbh_root_setup (l_edw_sob_id, l_segment_name, l_instance,3,
           p_status, p_problem_sob_id);
           p_hierarchy_no:=3;
           if p_status = false then return;
           end if;
        end if;

        if l_root_value4 IS NOT NULL THEN
           check_vbh_root_setup (l_edw_sob_id, l_segment_name, l_instance,4,
           p_status, p_problem_sob_id);
           p_hierarchy_no:=4;
           if p_status = false then return;
           end if;
        end if;
   p_status:=true;
  end loop;
  close l_cur_edw_vbh_roots;

  exception
    when others then
      close l_cur_edw_vbh_roots;
      p_status:=false;
      p_problem_sob_id := null;
      p_problem_sob_id2 := null;
      p_hierarchy_no := null;
      p_segment_name := null;

end;



procedure check_vbh_root_setup (
  p_edw_sob_id in integer
, p_segment_name in varchar2
, p_instance in varchar2
, p_hierarchy_no in number
, p_status out nocopy boolean
, p_problem_sob_id out nocopy integer) as

  type t_cur_edw_cons is ref cursor;
  l_cur_edw_cons t_cur_edw_cons;
  l_parent_edw_sob_id number;
  l_child_edw_sob_id number;
  l_consolidation_id number;
  l_status boolean;
  l_err_msg varchar2(100);
  --l_db_link varchar2(30);
  l_db_link edw_source_instances.WAREHOUSE_TO_INSTANCE_LINK%TYPE;
  l_from_value_set_id number;
  l_to_value_set_id number;
  l_select_stmt varchar2(200);
  l_cursor_id number;
  l_result number;
  l_dummy number;
begin
  edw_vbh_setup.LOOKUP_DB_LINK(p_instance,l_status,l_err_msg,l_db_link);
  open l_cur_edw_cons for
    select parent_edw_set_of_books_id, child_edw_set_of_books_id,
           consolidation_id
    from edw_cons_set_of_books
    where child_edw_set_of_books_id
          in (select edw_set_of_books_id from edw_vbh_roots where segment_name=p_segment_name)
    and parent_edw_set_of_books_id=p_edw_sob_id;

  loop
    fetch l_cur_edw_cons into l_parent_edw_sob_id,l_child_edw_sob_id,l_consolidation_id;
    exit when l_cur_edw_cons%NOTFOUND;

    select from_f.value_set_id
    into l_from_value_set_id
    from edw_flex_seg_mappings_v from_f,edw_set_of_books from_b
    where from_b.edw_set_of_books_id=l_child_edw_sob_id
      and from_b.chart_of_accounts_id=from_f.structure_num
      and from_f.instance_code=p_instance
      and from_f.segment_name=p_segment_name;

    select to_f.value_set_id
    into l_to_value_set_id
    from edw_flex_seg_mappings_v to_f,edw_set_of_books to_b
    where to_b.edw_set_of_books_id=l_parent_edw_sob_id
      and to_b.chart_of_accounts_id=to_f.structure_num
      and to_f.instance_code=p_instance
      and to_f.segment_name=p_segment_name;

   l_cursor_id:=dbms_sql.open_cursor;
    l_select_stmt:='select count(*) from edw_cons_mapping_v@'||l_db_link||
                   ' where FROM_VALUE_SET_ID=:b_from_value_set_id and to_value_set_id=:b_to_value_set_id and consolidation_id=:b_consolidation_id';
      dbms_sql.parse(l_cursor_id, l_select_stmt,dbms_sql.v7);

      dbms_sql.bind_variable(l_cursor_id,':b_from_value_set_id',l_from_value_set_id);
      dbms_sql.bind_variable(l_cursor_id,':b_to_value_set_id',l_to_value_set_id);
      dbms_sql.bind_variable(l_cursor_id,':b_consolidation_id',l_consolidation_id);
      dbms_sql.define_column(l_cursor_id,1,l_result);
      l_dummy:=dbms_sql.execute(l_cursor_id);
      if dbms_sql.fetch_rows(l_cursor_id)=0 then exit;
      end if;
      dbms_sql.column_value(l_cursor_id,1,l_result);
      dbms_sql.close_cursor(l_cursor_id);

      if l_result<>0 then
        l_cursor_id:=dbms_sql.open_cursor;
        l_select_stmt:='select count(*) from edw_vbh_roots where edw_set_of_books_id=:b_problem_sob_id and root_value'||p_hierarchy_no||' is not null and segment_name =:b_segment_name';

      dbms_sql.parse(l_cursor_id, l_select_stmt,dbms_sql.v7);
      dbms_sql.bind_variable(l_cursor_id,':b_problem_sob_id',l_child_edw_sob_id);
      dbms_sql.bind_variable(l_cursor_id,':b_segment_name',p_segment_name);

      dbms_sql.define_column(l_cursor_id,1,l_result);
      l_dummy:=dbms_sql.execute(l_cursor_id);
      if dbms_sql.fetch_rows(l_cursor_id)=0 then exit;
      end if;
      dbms_sql.column_value(l_cursor_id,1,l_result);
      dbms_sql.close_cursor(l_cursor_id);
        if l_result <> 0 then
          p_status:=false;
          p_problem_sob_id:=l_child_edw_sob_id;
          return;
        end if;
      end if;
 end loop;
 close l_cur_edw_cons;

 open l_cur_edw_cons for
    select parent_edw_set_of_books_id,child_edw_set_of_books_id,consolidation_id
    from edw_cons_set_of_books
    where parent_edw_set_of_books_id in (select edw_set_of_books_id from edw_vbh_roots where segment_name=p_segment_name)
    and child_edw_set_of_books_id =p_edw_sob_id;
 loop
    fetch l_cur_edw_cons into l_parent_edw_sob_id,l_child_edw_sob_id,l_consolidation_id;
    exit when l_cur_edw_cons%NOTFOUND;
    select from_f.value_set_id
    into l_from_value_set_id
    from edw_flex_seg_mappings_v from_f,edw_set_of_books from_b
    where from_b.edw_set_of_books_id=l_child_edw_sob_id
      and from_b.chart_of_accounts_id=from_f.structure_num
      and from_f.instance_code=p_instance
      and from_f.segment_name=p_segment_name;

    select to_f.value_set_id
    into l_to_value_set_id
    from edw_flex_seg_mappings_v to_f,edw_set_of_books to_b
    where to_b.edw_set_of_books_id=l_parent_edw_sob_id
      and to_b.chart_of_accounts_id=to_f.structure_num
      and to_f.instance_code=p_instance
      and to_f.segment_name=p_segment_name;

    l_cursor_id:=dbms_sql.open_cursor;
    l_select_stmt:='select count(*) from edw_cons_mapping_v@'||l_db_link||
                   ' where FROM_VALUE_SET_ID=:b_from_value_set_id and to_value_set_id=:b_to_value_set_id and consolidation_id=:b_consolidation_id';

      dbms_sql.parse(l_cursor_id, l_select_stmt,dbms_sql.v7);
      dbms_sql.bind_variable(l_cursor_id,':b_from_value_set_id',l_from_value_set_id);
      dbms_sql.bind_variable(l_cursor_id,':b_to_value_set_id',l_to_value_set_id);
      dbms_sql.bind_variable(l_cursor_id,':b_consolidation_id',l_consolidation_id);
      dbms_sql.define_column(l_cursor_id,1,l_result);
      l_dummy:=dbms_sql.execute(l_cursor_id);
      if dbms_sql.fetch_rows(l_cursor_id)=0 then exit;
      end if;
      dbms_sql.column_value(l_cursor_id,1,l_result);
      dbms_sql.close_cursor(l_cursor_id);
      if l_result<>0 then

        l_cursor_id:=dbms_sql.open_cursor;
        l_select_stmt:='select count(*) from edw_vbh_roots where edw_set_of_books_id=:b_problem_sob_id and root_value'||p_hierarchy_no||' is not null and segment_name=:b_segment_name';

      dbms_sql.parse(l_cursor_id, l_select_stmt,dbms_sql.v7);
      dbms_sql.bind_variable(l_cursor_id,':b_problem_sob_id',l_parent_edw_sob_id);
      dbms_sql.bind_variable(l_cursor_id,':b_segment_name',p_segment_name);

      dbms_sql.define_column(l_cursor_id,1,l_result);
      l_dummy:=dbms_sql.execute(l_cursor_id);
      if dbms_sql.fetch_rows(l_cursor_id)=0 then exit;
      end if;
      dbms_sql.column_value(l_cursor_id,1,l_result);
      dbms_sql.close_cursor(l_cursor_id);
        if l_result <> 0 then
          p_status:=false;
          p_problem_sob_id:=l_parent_edw_sob_id;
          return;
        end if;
      end if;
   end loop;
   close l_cur_edw_cons;
   p_status:=true;

   exception
    when others then
      p_status:=false;
      p_problem_sob_id := null;

end;


FUNCTION check_sob_exist(p_status out nocopy	 BOOLEAN,
			 p_errMsg out nocopy	 VARCHAR2,
			 p_set_of_books_id IN  NUMBER )  return boolean IS
   l_status	BOOLEAN := TRUE;
   TYPE curType IS REF CURSOR;
   cv curType;
   set_of_book_id_dup number;
   l_stmt varchar2(1000);
BEGIN
	l_stmt := 'select SET_OF_BOOKS_ID from edw_set_of_books where SET_OF_BOOKS_ID = '|| p_set_of_books_id;
	open cv for l_stmt;
	loop
	  fetch cv into set_of_book_id_dup ;
          EXIT WHEN cv%NOTFOUND;
	end loop;
	if set_of_book_id_dup is not null then
        	return true;
	else
		return false;
	end if;
EXCEPTION
      when others then
	close cv;
	p_status :=false;
        p_errMsg:=sqlcode||':'||sqlerrm;
END check_sob_exist;



 procedure insert_set_of_books(
			p_status out nocopy	 BOOLEAN,
			p_errMsg out nocopy	 VARCHAR2,
			p_edw_set_of_books_id	 NUMBER,
			p_instance		 VARCHAR2,
		        p_set_of_books_id	 NUMBER,
			p_set_of_books_name	 VARCHAR2,
			p_chart_of_accounts_id	 NUMBER,
			p_description		 VARCHAR2,
			p_creation_date		 DATE,
			p_created_by		 NUMBER,
			p_last_update_date	 DATE,
			p_last_updated_by	 NUMBER ,
			p_last_update_login	 NUMBER) as

    l_insert_stmt     varchar2(20000);


begin
	l_insert_stmt:= 'insert into edw_set_of_books(EDW_SET_OF_BOOKS_ID,instance,
        SET_OF_BOOKS_ID,
        SET_OF_BOOKS_NAME ,
        CHART_OF_ACCOUNTS_ID,
        description,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATED_BY ,
        LAST_UPDATE_LOGIN
        )values('||p_edw_set_of_books_id ||','''|| p_instance||''','
		 ||p_set_of_books_id||','''||p_set_of_books_name||''','
		||p_chart_of_accounts_id||','''
		||p_description||''' ,'''
		||p_creation_date||''','
		||p_created_by||','''
		||p_last_update_date||''','
		||p_last_updated_by||','
		||p_last_update_login||')';

      execute immediate l_insert_stmt;
       commit;

EXCEPTION
	when others then
	p_status :=false;
        p_errMsg:=sqlcode||':'||sqlerrm;

end insert_set_of_books;

end;

/
