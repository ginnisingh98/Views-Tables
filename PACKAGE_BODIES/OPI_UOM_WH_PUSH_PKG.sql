--------------------------------------------------------
--  DDL for Package Body OPI_UOM_WH_PUSH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OPI_UOM_WH_PUSH_PKG" as
/* $Header: OPIUOMPB.pls 115.9 2002/04/29 15:24:15 pkm ship     $ */
l_db_link		VARCHAR2(240);

CURSOR sources IS
        SELECT instance_code, warehouse_to_instance_link
        FROM   edw_source_instances_vl
        WHERE  enabled_flag = 'Y';

Function isInstanceRunning(p_mode IN NUMBER, p_db_link IN VARCHAR2, p_instance IN VARCHAR2) RETURN BOOLEAN IS
cid                     NUMBER := 0;
bRunning		BOOLEAN := TRUE;
BEGIN
	edw_misc_util.globalNamesOff;
	cid := DBMS_SQL.open_cursor;
	BEGIN
	dbms_sql.parse(cid, 'SELECT 1 FROM dual@'||p_db_link, dbms_sql.native);
	Exception
                        WHEN OTHERS THEN

			bRunning := FALSE;
                	edw_owb_collection_util.write_to_log_file('Instance not running: '|| p_db_link || ' : '||SQLERRM);
	END;

		dbms_sql.close_cursor(cid);

	IF (p_mode = 1) THEN
		IF (bRunning = FALSE) THEN
			fnd_message.set_name('BIS', 'EDW_BAD_DBLINK');
                   	fnd_message.set_token('DBLINK', p_instance, FALSE);
                   app_exception.raise_exception;
		END IF;
	END IF;
	RETURN bRunning;
END;

PROCEDURE pushToSource(p_object_name IN varchar2) IS

l_temp		VARCHAR2(200):=NULL;
l_inst_down	VARCHAR2(2000):=NULL;
l_stmt		VARCHAR2(5000):=NULL;
cid		NUMBER:=0;
l_dummy		NUMBER:=0;
l_progress              varchar2(10);
l_count                 NUMBER := 0;
BEGIN
	edw_misc_util.globalNamesOff;
 	SAVEPOINT start_push_to_source;

	l_progress := '010';
        cid := DBMS_SQL.open_cursor;
	--open instances;
	open sources;
	LOOP
		l_progress := '020';
		--FETCH instances INTO l_db_link;
		fetch sources into l_temp, l_db_link;
		EXIT WHEN sources%NOTFOUND;

		IF isInstanceRunning(0, l_db_link, l_temp) THEN
			null;
		ELSE
			l_inst_down := l_inst_down ||l_temp||' ';
		END IF;
		-- Check to see if the link points to itself, is so skip for this instance
		/* ***** 1922031 Bug Fix : Removed conditions to check if the
		db link points to itself. The ODF file containing the Misc
		Block for target will contain two local tables for
		UOM Dimension and UOM Conversion Fact.
		This will ensure that the post-load goes through successfully
		even if the target's source flag is turned on for POA DUNS
		dimension.******  */
		IF ( isInstanceRunning(0, l_db_link, l_temp)) THEN

		   	IF p_object_name = 'EDW_MTL_UOM_M' then

				l_progress := '030';
				DBMS_SQL.PARSE(cid, 'DELETE EDW_MTL_LOCAL_UOM_M@'||l_db_link, dbms_sql.native);
				l_dummy := dbms_sql.execute(cid);
				l_progress := '040';
				l_stmt :=  'INSERT INTO EDW_MTL_LOCAL_UOM_M@'||l_db_link||' (UOM_EDW_UOM_PK, UOM_GLOBAL_FLAG,UOM_EDW_BASE_UOM, UOM_CONVERSION_RATE, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN)';
				l_stmt := l_stmt || ' SELECT UOM_EDW_UOM_PK, UOM_GLOBAL_FLAG, UOM_EDW_BASE_UOM, UOM_CONVERSION_RATE, SYSDATE, -1, SYSDATE, -1, -1 FROM EDW_MTL_UOM_M';
				l_progress := '050';
				DBMS_SQL.PARSE(cid, l_stmt, dbms_sql.native);
				l_dummy := dbms_sql.execute(cid);
				l_progress := '060';

			ELSIF p_object_name = 'OPI_EDW_UOM_CONV_F' then

				l_progress := '070';
				DBMS_SQL.PARSE(cid, 'DELETE OPI_EDW_LOCAL_UOM_CONV_F@'||l_db_link, dbms_sql.native);
				l_dummy := dbms_sql.execute(cid);

				l_progress := '080';

				l_stmt :=  'INSERT INTO OPI_EDW_LOCAL_UOM_CONV_F@'||l_db_link||' (UOM_CONV_PK, EDW_BASE_UOM_FK, EDW_UOM_FK, EDW_CONVERSION_RATE,CLASS_CONVERSION_FLAG,  LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, LAST_UPDATE_LOGIN)';
				l_stmt := l_stmt || ' SELECT UOM_CONV_PK, EDW_BASE_UOM_FK, EDW_UOM_FK, EDW_CONVERSION_RATE,  CLASS_CONVERSION_FLAG, SYSDATE, -1, SYSDATE, -1, -1 FROM OPI_EDW_UOM_CONV_F';
				l_progress := '090';

				DBMS_SQL.PARSE(cid, l_stmt, dbms_sql.native);
				l_dummy := dbms_sql.execute(cid);
				l_progress := '100';
			END IF;
		END IF;

	END LOOP;

        DBMS_SQL.close_cursor(cid);

	close sources;
        COMMIT;

EXCEPTION
	when others then

	 	ROLLBACK TO start_push_to_source;
		close sources;
                DBMS_SQL.close_cursor(cid);
                edw_owb_collection_util.write_to_log_file('push_to_source: '||l_progress|| ' : '||SQLERRM);
		raise;

END pushToSource;

End OPI_UOM_WH_PUSH_PKG;

/
