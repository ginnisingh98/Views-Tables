--------------------------------------------------------
--  DDL for Package Body EDW_SYSTEM_PARAMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SYSTEM_PARAMS_PKG" as
/* $Header: edwparmb.pls 120.1 2006/03/28 01:46:54 rkumar noship $ */
l_db_link		VARCHAR2(240);

CURSOR instances IS
        SELECT warehouse_to_instance_link
        FROM   edw_source_instances_vl
        WHERE  enabled_flag = 'Y';
CURSOR cols IS
        SELECT  column_name
        FROM all_tab_columns
        WHERE table_name = 'EDW_SYSTEM_PARAMETERS'
	AND owner=edw_owb_collection_util.get_db_user('BIS')
	AND column_name NOT IN ('LAST_UPDATE_DATE', 'CREATION_DATE'); --removed Upper for bug#4905343
CURSOR sources IS
        SELECT instance_code, warehouse_to_instance_link
        FROM   edw_source_instances_vl
        WHERE  enabled_flag = 'Y';

Function isInstanceRunning(p_mode IN NUMBER, p_db_link IN VARCHAR2, p_instance IN VARCHAR2) RETURN BOOLEAN IS
cid                     NUMBER := 0;
bRunning		BOOLEAN := TRUE;
BEGIN


	BEGIN
	edw_misc_util.globalNamesOff;

	cid := DBMS_SQL.open_cursor;

	dbms_sql.parse(cid, 'SELECT 1 FROM dual@'||p_db_link, dbms_sql.native);
	dbms_sql.close_cursor(cid);

	Exception
                        WHEN OTHERS THEN
			bRunning := FALSE;
			dbms_sql.close_cursor(cid);

	END;


	IF (p_mode = 1) THEN
		IF (bRunning = FALSE) THEN
			fnd_message.set_name('BIS', 'EDW_BAD_DBLINK');
                   	fnd_message.set_token('DBLINK', p_instance, FALSE);
                   app_exception.raise_exception;
		END IF;
	END IF;
	RETURN bRunning;
END;

PROCEDURE pushToSource(inst_down OUT NOCOPY varchar2) IS
l_temp		VARCHAR2(200):=NULL;
l_colList	VARCHAR2(2000):=NULL;
l_stmt		VARCHAR2(5000):=NULL;
cid		NUMBER:=0;
l_dummy		NUMBER:=0;
l_progress              varchar2(10);
l_count                 NUMBER := 0;
remote_date	DATE;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
BEGIN

	-- We need to push EDW_SYSTEM_PARAMETERS to source OLTP's for the push programs to use
        SAVEPOINT start_push_to_source;
	l_progress := '010';


	/* Turn Off global names for the session */

	edw_misc_util.globalNamesOff;


	/* IF (cols%ISOPEN) THEN
		CLOSE cols;
	END IF;


	OPEN cols;
	LOOP
		FETCH cols INTO l_temp;
		EXIT WHEN cols%NOTFOUND;
		if (l_count = 0) then
			l_colList := l_colList||l_temp;
			l_count := l_count + 1;
		else
			l_colList := l_colList||', '||l_temp;
		end if;
	END LOOP;
	close cols; */
	l_progress := '015';
	--open instances;

	IF (sources%isopen) THEN
		close sources;
	END IF;
	open sources;
	LOOP
		l_progress := '020';
		--FETCH instances INTO l_db_link;
		fetch sources into l_temp, l_db_link;
		EXIT WHEN sources%NOTFOUND;

		IF isInstanceRunning(0, l_db_link, l_temp) THEN

			-- get sydate from remote db
		cid := DBMS_SQL.open_cursor;
        	DBMS_SQL.PARSE(cid, 'SELECT sysdate FROM dual@'||l_db_link, dbms_sql.native);
        	dbms_sql.define_column(cid, 1, remote_date);
        	l_dummy:=dbms_sql.execute(cid);
        	if dbms_sql.fetch_rows(cid)<>0 then
                	dbms_sql.column_value(cid, 1, remote_date);
        	end if;
        	DBMS_SQL.close_cursor(cid);

		/*
  		l_stmt:='SELECT distinct column_name
        	 FROM all_tab_columns@' ||l_db_link ||
        	 ' WHERE table_name = ''EDW_LOCAL_SYSTEM_PARAMETERS''
        	 AND upper(column_name) not in ( ''LAST_UPDATE_DATE'',''CREATION_DATE'')' ||
		 ' INTERSECT SELECT distinct column_name from all_tab_columns '||
		 ' WHERE table_name = ''EDW_SYSTEM_PARAMETERS''
		 AND upper(column_name) not in ( ''LAST_UPDATE_DATE'',''CREATION_DATE'')' ;
		*/


		l_stmt:= 'SELECT distinct tab.column_name FROM all_tab_columns@'
		||l_db_link || ' tab ,user_synonyms@' ||l_db_link ||
		  ' syn WHERE tab.table_name = ''EDW_LOCAL_SYSTEM_PARAMETERS''' ||
		  ' and syn.table_name = tab.table_name and tab.owner=syn.table_owner ' ||
		   ' AND upper(tab.column_name) not in ( ''LAST_UPDATE_DATE'',''CREATION_DATE'')' ||
                   ' INTERSECT SELECT distinct tab.column_name from all_tab_columns tab ,'||
                   ' user_synonyms syn WHERE tab.table_name = ''EDW_LOCAL_SYSTEM_PARAMETERS'''||
		    ' and syn.table_name =tab.table_name and tab.owner=syn.table_owner '||
        	     'AND upper(tab.column_name) not in ( ''LAST_UPDATE_DATE'',''CREATION_DATE'')';

		l_count := 0;
		l_colList :=NULL;
 		open cv for l_stmt;
  		loop
		  FETCH cv INTO l_temp;
		  EXIT WHEN cv%NOTFOUND;
		  if (l_count = 0) then
			l_colList := l_colList||l_temp;
			l_count := l_count + 1;
		  else
			l_colList := l_colList||', '||l_temp;
		  end if;
  		end loop;

			-- First delete existing date from the source db
			cid := DBMS_SQL.open_cursor;
			l_progress := '030';
				DBMS_SQL.PARSE(cid, 'DELETE EDW_LOCAL_SYSTEM_PARAMETERS@'||l_db_link, dbms_sql.native);
				l_dummy := dbms_sql.execute(cid);
				l_stmt :=  'INSERT INTO EDW_LOCAL_SYSTEM_PARAMETERS@'||l_db_link||' ( last_update_date, creation_date, ';
				l_stmt := l_stmt ||l_colList||') SELECT :x1, :x1, '||l_colList||' FROM EDW_SYSTEM_PARAMETERS';
				-- Now we can insert into these tables
				l_progress := '060';


				DBMS_SQL.PARSE(cid, l_stmt, dbms_sql.native);
				DBMS_SQL.BIND_VARIABLE(cid, ':x1', remote_date);

				l_dummy := dbms_sql.execute(cid);
				l_progress := '070';

		ELSE
			inst_down := inst_down ||l_temp;
                END IF;


	END LOOP;

        DBMS_SQL.close_cursor(cid);

	CLOSE sources;
        COMMIT;

EXCEPTION
	when others then

	 	ROLLBACK TO start_push_to_source;
		CLOSE instances;
                DBMS_SQL.close_cursor(cid);
    		edw_message_s.sql_error('push_to_source',l_progress,SQLCODE);
		inst_down:=null;
		raise;

END pushToSource;

function  count_item_flex_segments(l_db_link varchar2) return number is
l_stmt          varchar2(1000);
result          number;
Type CurTyp is Ref Cursor;
cv              CurTyp;
begin
   edw_misc_util.globalnamesoff;
   l_stmt:='select count(*) from fnd_id_flex_segments@'||l_db_link ||
	' where application_id=''401'' '||
	' and id_flex_code= ''MCAT'' '||
	' and enabled_flag=''Y'' '||
	' and id_flex_num= ' ||
	' ( select structure_id '||
	' from mtl_category_sets_b@'|| l_db_link ||
	' where category_set_id=''1000000006'' )';

    open cv for l_stmt;
    fetch cv into result;
    close cv;
    return result;
end  count_item_flex_segments;

function is_vbh_available (l_db_link varchar2) return varchar2 is
l_stmt          varchar2(1000);
result          varchar2(5):=null;
Type CurTyp is Ref Cursor;
cv              CurTyp;
begin
   edw_misc_util.globalnamesoff;

   l_stmt:='select ''YES'' VBH_INSTALLED from mtl_category_sets_b@'||l_db_link ||
	' where  category_set_id = ''1000000006'' ';
    open cv for l_stmt;
    fetch cv into result;
    close cv;
    return result;
end is_vbh_available;

function is_eni_pkg_exist (l_db_link varchar2) return varchar2
is
  l_child_supported varchar2(10);
  e_not_supported exception;
  PRAGMA exception_init(e_not_supported, -904);
  l_stmt varchar2(1000);

begin
      l_stmt := 'SELECT ENI_EDW_UTILS.IS_CHILD_ORG_SUPPORTED FROM DUAL@' ||l_db_link;
      EXECUTE IMMEDIATE l_stmt INTO l_child_supported;
      If upper(l_child_supported) = 'TRUE' then
	RETURN 'TRUE';
      else
        RETURN 'FALSE';
      end if;

EXCEPTION
    WHEN e_not_supported THEN
	RETURN 'FALSE';
    WHEN OTHERS THEN
       Raise;
end is_eni_pkg_exist;

End EDW_SYSTEM_PARAMS_PKG;


/
