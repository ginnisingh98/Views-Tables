--------------------------------------------------------
--  DDL for Package Body EDW_FLEX_PUSH_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_FLEX_PUSH_C" AS
/* $Header: EDWFLXGB.pls 115.7 2002/12/05 23:05:17 arsantha ship $ */
 G_DIMENSION			VARCHAR2(100);
 G_INDEX			NUMBER := 0;
 G_PUSH_DATE_RANGE1         Date:=Null;
 G_PUSH_DATE_RANGE2         Date:=Null;
 g_row_count         Number:=0;
 g_exception_msg     varchar2(2000):=Null;
 newline varchar2(10):='
 ';

 Procedure Push(Errbuf       in out NOCOPY Varchar2,
                Retcode      in out NOCOPY Varchar2,
		p_dimension  IN   VARCHAR2,
                p_from_date  IN   VARCHAR2,
                p_to_date    IN   VARCHAR2) IS
 l_temp_date                Date:=Null;
 l_rows_inserted            Number:=0;
 l_duration                 Number:=0;
 l_exception_msg            Varchar2(2000):=Null;
cid number;
stmt            varchar2(4000);
l_dummy         NUMBER;
l_source_link		VARCHAR2(128);
l_target_link		VARCHAR2(128);

   -- -------------------------------------------
   -- Put any additional developer variables here
   -- -------------------------------------------
Begin
  Errbuf :=NULL;
   Retcode:=0;
  g_dimension := p_dimension;

	/* should ideally change the value set to pass short names  */
	-- get databaselink
	EDW_COLLECTION_UTIL.get_dblink_names(l_source_link, l_target_link);

	stmt:= 'SELECT dim_name from edw_dimensions_md_v@'|| l_target_link ||
		' where dim_long_name = :longname';

        cid := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
        DBMS_SQL.BIND_VARIABLE(cid, ':longname', p_dimension);
        DBMS_SQL.DEFINE_COLUMN(cid, 1, g_dimension, 100);
        l_dummy := DBMS_SQL.EXECUTE_AND_FETCH(cid);
        DBMS_SQL.COLUMN_VALUE(cid, 1, g_dimension);
        DBMS_SQL.close_cursor(cid);


  g_index := substr(g_dimension, 13 , instr(g_dimension, '_M') - 13 );

  IF (Not EDW_COLLECTION_UTIL.setup(g_dimension)) THEN
  	errbuf := fnd_message.get;
    	Return;
  END IF;

  IF (p_from_date IS NULL) THEN
	g_push_date_range1 :=  EDW_COLLECTION_UTIL.G_local_last_push_start_date -
		EDW_COLLECTION_UTIL.g_offset;
  ELSE
	g_push_date_range1 := to_date(p_from_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

  IF (p_to_date IS NULL) THEN
	g_push_date_range2 := EDW_COLLECTION_UTIL.G_local_curr_push_start_date;
  ELSE
	g_push_date_range2 := to_date(p_to_date, 'YYYY/MM/DD HH24:MI:SS');
  END IF;

   edw_log.put_line( 'Push for User Defined dimension : '||p_dimension);
   edw_log.put_line( 'The push range is from '||
        to_char(EDW_FLEX_PUSH_C.g_push_date_range1,'MM/DD/YYYY HH24:MI:SS')||' to '||
        to_char(EDW_FLEX_PUSH_C.g_push_date_range2,'MM/DD/YYYY HH24:MI:SS'));
   edw_log.put_line(' ');

-- -----------------------------------------------------------------------------
-- Start of Collection , Developer Customizable Section
-- -----------------------------------------------------------------------------

   edw_log.put_line(' ');
   l_temp_date := sysdate;

-- -----------------------------------------------------------------------------
-- Call Push_Levels to push the two levels.
-- -----------------------------------------------------------------------------

   Push_Levels(g_push_date_range1, g_push_date_range2);

   l_duration := sysdate - l_temp_date;

   EDW_COLLECTION_UTIL.wrapup(TRUE, g_row_count, null, g_push_date_range1, g_push_date_range2);

   edw_log.put_line('Total rows inserted for '||g_dimension||' : '||g_row_count);
   edw_log.put_line('Process Time: '||edw_log.duration(l_duration));
   edw_log.put_line(' ');

commit;

 Exception When others then
      Errbuf:=sqlerrm;
      Retcode:=sqlcode;
   l_exception_msg  := Retcode || ':' || Errbuf;
   EDW_FLEX_PUSH_C.g_exception_msg  := l_exception_msg;
   rollback;
   EDW_COLLECTION_UTIL.wrapup(FALSE, 0, EDW_FLEX_PUSH_C.g_exception_msg,
		g_push_date_range1, g_push_date_range2);

commit;
End;

-- -----------------------------------------------------------------------------
-- Push One Level will Insert into the staging table for Level with index
-- p_level. This procedure should check for existence of LAST_UPDATE_DATE,
-- CREATION_DATE, and DESCRIPTION in the view before inserting
-- -----------------------------------------------------------------------------

Procedure Push_One_Level(p_from_date IN date, p_to_date IN DATE, p_level IN NUMBER) IS
    insertStmt varchar2(3000) := null;
    cid NUMBER := 0;
    l_dummy NUMBER := 0;

stmt Varchar2(4000);
l_count number;
l_column varchar2(40);
l_source_link		VARCHAR2(128);
l_target_link		VARCHAR2(128);

BEGIN

	edw_log.put_line('Starting Push For EDW_FLEX_DIM'||g_index||'_L'||p_level||'_LSTG');

	-- get databaselink
	EDW_COLLECTION_UTIL.get_dblink_names(l_source_link, l_target_link);

	stmt := 'Insert Into EDW_FLEX_DIM'||
   		g_index||'_L'||p_level||'_LSTG@' || l_target_link || '(
    		 NAME,  INSTANCE, '||
    		' L'||p_level||'_FK, L'||p_level||'_PK, '||
            ' LAST_UPDATE_DATE, CREATION_DATE, DESCRIPTION, OPERATION_CODE, COLLECTION_STATUS)
   		select ACTUAL_VALUE, INSTANCE,
    		NVL(L'||p_level||'_FK, ''NA_EDW'') L'||p_level||'_fk, L'||p_level||'_PK, ';
        stmt := stmt || '  last_update_date, ';
        stmt := stmt || '  creation_date, ';
        stmt := stmt || '  description, ';
        stmt := stmt||' NULL, ''READY'' from EDW_FLEX_DIM' ||g_index||'_L'||p_level||'_LCV@' || l_source_link;
        /* if null then set to from_date + 0.1 seconds */
    	stmt := stmt ||' where NVL(last_update_date, to_date('''||
         to_char(p_from_date,'MM/DD/YYYY HH24:MI:SS')||''','''|| 'MM/DD/YYYY HH24:MI:SS'||''''||')+1/864000)  between :p_from_date and :p_to_date';

	edw_log.put_line('Insert statement is : '|| stmt);

	cid := DBMS_SQL.open_cursor;
	DBMS_SQL.PARSE(cid, stmt, dbms_sql.native);
	edw_log.put_line('Parsed stmt');


	DBMS_SQL.BIND_VARIABLE(cid, ':p_from_date', p_from_date);
	DBMS_SQL.BIND_VARIABLE(cid, ':p_to_date', p_to_date);
	l_dummy := DBMS_SQL.EXECUTE(cid);
	DBMS_SQL.close_cursor(cid);
	commit;
	g_row_count := g_row_count +  l_dummy;
	edw_log.put_line('Inserted '||l_dummy||  ' rows into the staging table');
	edw_log.put_line('Commiting records for EDW_FLEX_DIM'||g_index||'_L'||p_level||'_LSTG');

	commit;

	edw_log.put_line('Completed Push_EDW_FLEX_DIM'||g_index||'_L'||p_level||'_LSTG'||newline||newline);

	Exception When others then
   	raise;
commit;
END;


Procedure Push_Levels(p_from_date IN date, p_to_date IN DATE) IS
BEGIN
    Push_One_Level(p_from_date, p_to_date, 2); /* Lower level push */
    Push_One_Level(p_from_date, p_to_date, 1); /* Higher level push */
END;


End EDW_FLEX_PUSH_C;

/
