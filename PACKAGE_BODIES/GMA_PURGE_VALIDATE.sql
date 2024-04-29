--------------------------------------------------------
--  DDL for Package Body GMA_PURGE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_PURGE_VALIDATE" AS
/* $Header: GMAPRGVB.pls 115.8 2004/02/12 21:30:52 kmoizudd ship $ */

  FUNCTION is_table(p_purge_id  sy_purg_mst.purge_id%TYPE,
                    p_tablename user_tables.table_name%TYPE)
           RETURN BOOLEAN IS
    -- check to make sure given name IS a real table
    -- Added one more cursor parameter owner for UDTF standards by KH 3431801

    CURSOR l_table_cur(c_tablename user_tables.table_name%TYPE,
                       c_schema_owner all_tables.owner%TYPE) IS
      SELECT 1
      FROM   ALL_TABLES
   --MADE by Khaja   added one OWNER on where clause for UDTF bug fix #3431801
   --MADE by Khaja   FROM   user_tables
      WHERE  table_name = upper(c_tablename)
      and    owner=c_schema_owner;

    l_scratch NUMBER(1);

-- Defining these variables for UDTF bug 3431801 to make use of FND_INSTALLATION api  by Khaja
    v_schema varchar2(100);
    v_status varchar2(100);
    v_industry varchar2(100);

    l_schema_owner  varchar2(2000);
    l_tablefound_inschema boolean:=FALSE;

  BEGIN

       -- Fetch all OPM product schema names for UDTF bug 34318001
       -- Make sure to even append in the APPS schema for temporary table validation
       -- added by Khaja

     FOR rec in (SELECT APPLICATION_SHORT_NAME from fnd_application
                 where application_id between 550 and 558
                 UNION
                 -- This query given by Pete from AD for UDTF APPS schema retrieve
                 SELECT oracle_username application_short_name FROM fnd_oracle_userid
                 WHERE  read_only_flag = 'U')
     LOOP

       if rec.application_short_name='APPS' then
          l_schema_owner:=rec.application_short_name;
       else
        if fnd_installation.GET_APP_INFO(rec.application_short_name,v_status,v_industry,v_schema) then
               l_schema_owner:=v_schema;
        end if;
       end if;


    OPEN l_table_cur(p_tablename,l_schema_owner);
    FETCH l_table_cur INTO l_scratch;

    IF (l_table_cur%FOUND) THEN
        l_tablefound_inschema:=TRUE;
        -- exit the LOOP if table is found in any first schema , not to continue further
        EXIT;
    END IF;

    CLOSE l_table_cur;

    END LOOP;

    if not l_tablefound_inschema then
      RAISE NO_DATA_FOUND;
    end if;


    RETURN TRUE; -- table exists


  EXCEPTION

    WHEN NO_DATA_FOUND THEN
          -- removed this CLOSE cursor stmt since CURSOR never gets opened for exception tables
          --  CLOSE l_table_cur;
     if upper(p_tablename) in ('GME_BT_STEP_ACTIVITIES',
                        'GME_BT_STEP_TRANSFERS',
                        'GME_BT_STEP_DEPENDENCS',
                        'GME_BT_STEP_RESOURCES',
                        'GME_BT_ST_RSRC_SUMMARY',
                        'GMD_COMP_SPEC_DISP',
                        'GMD_COMP_RESULTS',
                        'GMD_COMP_RESULT_ASSOC') then
         RETURN TRUE;
      else
      RETURN FALSE; -- Table does not exist
     end if;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Problem raised in GMA_PURGE_VALIDATE.tableexists.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END is_table;

  /***********************************************************/

  FUNCTION is_tablespace
                   (p_purge_id sy_purg_mst.purge_id%TYPE,
                    p_tablespace_name  IN user_tablespaces.tablespace_name%TYPE)
         RETURN BOOLEAN IS
  -- This function takes a name and checks the user_tablespaces
  -- view to make sure the parameter is a valid tablespace name.
  -- Return TRUE if the tablespace exists, FALSE otherwise.

    CURSOR l_validate_tablespace_cur
      (c_tablespace_name IN user_tablespaces.tablespace_name%TYPE) IS
        select 'X'
        from   user_tablespaces
        where  tablespace_name = upper(c_tablespace_name);

    l_tablespace_exists CHAR(1);

  BEGIN

    -- check for the tablespace in the data dictionary
    OPEN l_validate_tablespace_cur(p_tablespace_name);
    FETCH l_validate_tablespace_cur INTO l_tablespace_exists;
    IF l_validate_tablespace_cur%NOTFOUND THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE l_validate_tablespace_cur;

    RETURN TRUE; -- Tablespace exists

  EXCEPTION

    WHEN NO_DATA_FOUND THEN
      CLOSE l_validate_tablespace_cur;
      RETURN FALSE; -- The tablespace does not exist

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Problem raised in GMA_PURGE_VALIDATE.doarchive.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END is_tablespace;

  /***********************************************************/

  PROCEDURE checksql(p_purge_id sy_purg_mst.purge_id%TYPE,
                     p_purge_type sy_purg_def.purge_type%TYPE) IS
  -- used for debugging...  checks sql syntax

    CURSOR l_sql_cur(c_purge_type sy_purg_def.purge_type%TYPE) IS
      SELECT sqlstatement
      FROM   sy_purg_def  SD
      WHERE  SD.purge_type = c_purge_type;

    l_sqlstatement sy_purg_def.sqlstatement%TYPE;
    l_cursor       INTEGER;

  BEGIN

    OPEN  l_sql_cur(p_purge_type);
    FETCH l_sql_cur INTO l_sqlstatement;
    CLOSE l_sql_cur;

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    l_sqlstatement := l_sqlstatement || ' and rownum < 1;';
    GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);

    -- Just parse it, don't run it
    DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Problem raised in GMA_PURGE_VALIDATE.checksql.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END checksql;

END GMA_PURGE_VALIDATE;

/
