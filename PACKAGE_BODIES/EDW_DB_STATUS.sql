--------------------------------------------------------
--  DDL for Package Body EDW_DB_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DB_STATUS" as
/* $Header: EDWDBSTB.pls 115.11 2003/09/16 13:59:57 smulye ship $ */

/*===========================================================================*/

/*
 Name      :  check_db_status_all

 Purpose   :  Sees is all the source dbs are up and running
              It returns a concatenated string containing the
              instance_codes for all the source systems that
	      are down. Also, if any of the source systems are
              down, it returns a flag of FALSE. If all the source
              DBs are up, it returns true and an empty string in the
              OUT variable.

Arguments

Input
  Type IN  : NONE

  Type OUT : x_instance_code
             This contains the instance codes for all the source systems
	     that are down. It is a concatenated string
             Ex : if source systems "source1" and "source5" are down,
             x_instance_code is "source1 source5"
             If all systems are up, x_instance_code is an empty
             string as "".

Ouput
    l_status  : FALSE if any of the source systems are down
                TRUE if all the source systems are up.
                Data Type : BOOLEAN
*/

/*
 Name      :  check_db_status_site

 Purpose   :  Sees is the specified source db  is up and running
              Returns TRUE if the DB is up, false if the DB is
              down.
Arguments

Input
  Type IN  : p_instance_code
              This is the instance code of the DB that is being
              checked to see if up or down.

  Type OUT : NONE

Ouput
    l_status  : FALSE if any of the source systems are down
                TRUE if all the source systems are up.
                Data Type : BOOLEAN

*/

/*Name     :    check_repository_status

Purpose    :    checks for two things
                1. Is the repository DB up and running.
                2. If yes, then is the meta data frozen.

		If the rep DB is up and running and the meta data is
                not frozen, returns a status of 'N'.
                If the DB is not up, returns 'D'.
                If the rep DB is up but the meta data is frozen,
                it writes an error message.

NOTE       :    This function assumes that the Warehouse to the
                Repository DB link is EDW_WH_TO_REP

Arguments
Input :
  Type IN   :  NONE
  Type OUT  :  NONE

Output      :  l_status_flag
               Returns a flag of 'N' if the REP DB is up and the meta data
               is not frozen.
               If the REP DB is not up, returns a flag of 'Y'
               Data Type : VARCHAR2(1)

*/


/*
Name      :   replicate_tbl_all_site

Purpose   :   This function replicates a given table in the WH to all
              source systems defined in the table EDW_SOURCE_INSTANCES
              in the WH.

Arguments :
Input :
  Type IN   :  p_table_name
               This is the name of the table to be replicated.
               Data Type VARCHAR2

  Type OUT  :  NONE

Output :
   l_status  :  If this function is able to replicate the table at all
                the source sites, it returns a concat string of all
                source system where table replication failed.
                Ex : if source systems "source1" and "source5" have failed
                     to replicate the table,
                l_status is "source1 source5"
                If replication is successfull at all the sites, l_status
                is an empty string.
                Data Type : VARCHAR2(200)
*/


/*

Name      :   replicate_tbl_to_site

Purpose   :   This function replicates a given table in the WH to the
              source system passed as the input argument

Arguments :
Input :
  Type IN   :  p_instance_code
               This is the name of the source system where the table
               needs to be replicated.
               Data Type VARCHAR2

            :  p_table_name
               This is the name of the table to be replicated.
               Data Type VARCHAR2

  Type OUT  :  NONE

Output :
   l_status  :  'TRUE' if replication is successfull
                'FALSE' if the replication is unsuccessfull
                Data Type : VARCHAR2(200)
*/


FUNCTION check_db_status_all(x_instance_code OUT NOCOPY VARCHAR2)  return boolean IS

l_status	BOOLEAN := TRUE;
l_instance_code	VARCHAR2(30);
l_db_link	VARCHAR2(30);
l_progress	VARCHAR2(3):= '000';
l_dummy		VARCHAR2(30);
l_dummy_int     NUMBER;
cid		NUMBER;

l_temp	number := 0;

CURSOR instances IS
SELECT instance_code, warehouse_to_instance_link
FROM   edw_source_instances_vl
WHERE  enabled_flag = 'Y';

BEGIN

        x_instance_code:='';
	l_progress := '010';
	edw_misc_util.globalNamesOff;

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

	EXCEPTION when others then
		x_instance_code := null;
		raise;

END check_db_status_all;


FUNCTION check_db_status_site(p_instance_code IN VARCHAR2)  return boolean IS

l_status	BOOLEAN := TRUE;
l_db_link	VARCHAR2(30);
l_instance_code VARCHAR2(30);
l_progress	VARCHAR2(3):= '000';
l_dummy		VARCHAR2(30);
l_dummy_int     NUMBER;
cid		NUMBER;

l_temp	number := 0;

CURSOR instances IS
SELECT instance_code, warehouse_to_instance_link
FROM   edw_source_instances_vl
WHERE  enabled_flag = 'Y'
AND instance_code=p_instance_code;

BEGIN

	l_progress := '010';

	edw_misc_util.globalNamesOff;
	-- Check to make sure that all the enabled OLTP sources are up and running

	cid := DBMS_SQL.open_cursor;

	OPEN instances;

	l_progress := '020';

	FETCH instances INTO l_instance_code, l_db_link;

	-- Store the instance name in the out parameter to return

	DBMS_SQL.PARSE(cid, 'SELECT 1 FROM sys.dual@'||l_db_link, dbms_sql.native);
        l_dummy_int:=DBMS_SQL.EXECUTE(cid);


	l_progress := '030';

	CLOSE instances;

	DBMS_SQL.close_cursor(cid);

	return l_status;

	EXCEPTION
          when others then
          DBMS_SQL.close_cursor(cid);
          l_status := FALSE;
      	  edw_message_s.sql_error('check_db_status',l_progress,sqlcode);

END check_db_status_site;

FUNCTION check_repository_status RETURN VARCHAR2 IS

l_sql_stmt	VARCHAR2(400);
l_sql_stmt1	VARCHAR2(400);
l_status_flag   VARCHAR2(1) := 'N';
l_inst_mod_id	NUMBER;
l_progress	VARCHAR2(3) := '000';
l_dummy		VARCHAR2(30);
l_dummy_int     NUMBER;
cid		NUMBER;
cid1		NUMBER;
cid2		NUMBER;
l_repchk	NUMBER;
l_num		NUMBER := 0;

BEGIN

	-- Make sure that the repository is up and running
	-- ASSUMPTION : That the db link from runtime to rep is fixed and is edw_wh_to_rep

	l_progress := '010';
	edw_misc_util.globalNamesOff;

        cid := DBMS_SQL.open_cursor;
        cid1 := DBMS_SQL.open_cursor;
        cid2 := DBMS_SQL.open_cursor;


	BEGIN

		l_sql_stmt := ' SELECT 1 FROM  dual@edw_wh_to_rep';
		DBMS_SQL.PARSE(cid, l_sql_stmt ,dbms_sql.V7);

		l_dummy_int :=DBMS_SQL.EXECUTE(cid);

		l_progress := '015';

	EXCEPTION
		when others then
			l_status_flag := 'D';
			fnd_message.set_name('BIS', 'EDW_REPOSITORY_DOWN');
			return l_status_flag;
	END;

	l_progress := '020';

        -- Check Whether the Meta Data is Frozen
	-- The repository can not be frozen for Flex Wizard to continue

	/*

        SELECT	inst_mod_id
	INTO	l_inst_mod_id
        FROM	wh_inst_mods_v@EDW_WH_TO_REP
        WHERE	sw_mod_type_code = 'DTWH';

	*/

	l_sql_stmt := 'SELECT	inst_mod_id FROM wh_inst_mods_v@edw_wh_to_rep 	WHERE sw_mod_type_code = ''DTWH''';

	DBMS_SQL.PARSE(cid1, l_sql_stmt ,dbms_sql.V7);
	DBMS_SQL.DEFINE_COLUMN(cid1, 1, l_inst_mod_id);
	l_dummy_int :=DBMS_SQL.EXECUTE(cid1);

	l_num := DBMS_SQL.FETCH_ROWS(cid1);
 	DBMS_SQL.COLUMN_VALUE(cid1, 1, l_inst_mod_id);


--	l_status_flag := wh_inst_mods_pkg.freeze_check@EDW_WH_TO_REP(l_inst_mod_id);

	l_sql_stmt1 := 'declare x  VARCHAR2(1);' ||
			'begin x := wh_inst_mods_pkg.freeze_check@EDW_WH_TO_REP('||l_inst_mod_id||');' ||
			':l_status_flag := x;'||
			'end;';


	dbms_sql.parse(cid2, l_sql_stmt1,dbms_sql.native);
	dbms_sql.bind_variable(cid2, 'l_status_flag', l_status_flag, 1) ;
	l_dummy_int := dbms_sql.execute(cid2);
	dbms_sql.variable_value(cid2, 'l_status_flag', l_status_flag) ;


        IF (l_status_flag = 'Y') THEN
		fnd_message.set_name('BIS', 'EDW_REP_META_FROZEN');
        END IF;

        DBMS_SQL.close_cursor(cid);
        DBMS_SQL.close_cursor(cid1);
        DBMS_SQL.close_cursor(cid2);

	return l_status_flag;

EXCEPTION
	when others then

        DBMS_SQL.close_cursor(cid);
        DBMS_SQL.close_cursor(cid1);
        DBMS_SQL.close_cursor(cid2);

    	edw_message_s.sql_error('check_repository_status',l_progress,sqlcode);


END check_repository_status;

FUNCTION replicate_tbl_all_site(
p_table_name in varchar2) return varchar2  IS

CURSOR instances IS
	SELECT instance_code, warehouse_to_instance_link
	FROM   edw_source_instances_vl
	WHERE  enabled_flag = 'Y';

l_progress		VARCHAR2(3) := '000';
l_db_link		VARCHAR2(30);
l_instance_code         VARCHAR2(30);
l_sql_stmt              VARCHAR2(2000);
cid             	NUMBER;
l_dummy 		integer;
l_status                VARCHAR2(200):='';

BEGIN
	l_progress := '010';
	edw_misc_util.globalNamesOff;
        cid := DBMS_SQL.open_cursor;

	OPEN instances;

	LOOP
                BEGIN
		l_progress := '020';

		FETCH instances INTO l_instance_code, l_db_link;

		IF( instances%NOTFOUND ) THEN
			exit;
		END IF;

		/* First delete existing date from the source db */

		-- Check to see if the link points to itself


		IF ( edw_db_status.is_dblink_to_itself(l_db_link) = FALSE ) THEN

			l_progress := '030';

	                l_sql_stmt:=' DELETE '||p_table_name||'@'||l_db_link;

			DBMS_SQL.PARSE(cid, l_sql_stmt, dbms_sql.native);

			l_dummy := dbms_sql.execute(cid);

			l_progress := '040';

	          	l_sql_stmt:=' INSERT INTO  '||p_table_name||'@'||l_db_link||' SELECT * FROM '||p_table_name;
			DBMS_SQL.PARSE(cid,l_sql_stmt, dbms_sql.native);

			l_dummy := dbms_sql.execute(cid);

		END IF;

                EXCEPTION
                   when others then
                   edw_message_s.sql_error('replicate_table_to_all_site',l_progress,sqlcode);
                   l_status:=l_status||' '||l_instance_code||' ';
                END;

	END LOOP;

        DBMS_SQL.close_cursor(cid);

	CLOSE instances;

        return l_status;

END replicate_tbl_all_site;

FUNCTION replicate_tbl_to_site(
p_instance_code in varchar2,
p_table_name in varchar2) return VARCHAR2 IS

CURSOR instances IS
	SELECT warehouse_to_instance_link
	FROM   edw_source_instances_vl
	WHERE  enabled_flag = 'Y'
        AND instance_code=p_instance_code;

l_progress		VARCHAR2(3) := '000';
l_db_link		VARCHAR2(30);
l_sql_stmt              VARCHAR2(2000);
cid             	NUMBER;
l_dummy 		integer;
l_status                VARCHAR2(200):='TRUE';

BEGIN

	l_progress := '010';

        cid := DBMS_SQL.open_cursor;

	edw_misc_util.globalNamesOff;
	OPEN instances;

	l_progress := '020';

	FETCH instances INTO l_db_link;

	-- Check to see if the link points to itself

	IF ( edw_db_status.is_dblink_to_itself(l_db_link) = FALSE ) THEN
	        l_progress := '020';

	        l_sql_stmt:=' DELETE '||p_table_name||'@'||l_db_link;

		DBMS_SQL.PARSE(cid, l_sql_stmt, dbms_sql.native);
		l_dummy := dbms_sql.execute(cid);

		l_progress := '040';

	 	l_sql_stmt:=' INSERT INTO  '||p_table_name||'@'||l_db_link
                             ||' SELECT * FROM '||p_table_name;

		DBMS_SQL.PARSE(cid,l_sql_stmt, dbms_sql.native);

		l_dummy := dbms_sql.execute(cid);

	        DBMS_SQL.close_cursor(cid);

	END IF;

	CLOSE instances;

        return l_status;


 EXCEPTION
	    when others then
            DBMS_SQL.close_cursor(cid);
            edw_message_s.sql_error('replicate_table_to_all_site1',l_progress,sqlcode);
            l_status:='FALSE';
            return l_status;

END replicate_tbl_to_site;


FUNCTION is_dblink_to_itself(p_dblink IN VARCHAR2) RETURN BOOLEAN

IS
l_host		VARCHAR2(2000);
l_db_name	VARCHAR2(2000);
l_stmt 		varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
BEGIN

	edw_misc_util.globalNamesOff;

	l_stmt:='select upper(db.name) from v$database@'||p_dblink ||' db';
 	open cv for l_stmt ;
 	fetch cv into l_host;
 	close cv;

	SELECT upper(db.name)
	INTO   l_db_name
	FROM v$database db;

	IF (l_host = l_db_name) THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;

EXCEPTION
	when others then
		RETURN FALSE;

END is_dblink_to_itself;


END EDW_DB_STATUS;

/
