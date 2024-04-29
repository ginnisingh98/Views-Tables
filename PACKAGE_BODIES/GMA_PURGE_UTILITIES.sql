--------------------------------------------------------
--  DDL for Package Body GMA_PURGE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_PURGE_UTILITIES" AS
/* $Header: GMAPRGUB.pls 115.9 2003/10/27 07:48:22 kmoizudd ship $ */

  -- output text in dated format to log
  PROCEDURE logprint(p_purge_id sy_purg_mst.purge_id%TYPE,p_text VARCHAR2);

  /***/

  PROCEDURE logprint(p_purge_id sy_purg_mst.purge_id%TYPE,p_text VARCHAR2) IS

  BEGIN

    -- Log the message to the DB
    INSERT INTO sy_purg_err
      ( purge_id
      , line_no
      , creation_date
      , created_by
      , last_updated_by
      , last_update_date
      , text)
      VALUES
      ( NVL(p_purge_id,0)
      , sy_purg_err_line_seq.nextval
      , sysdate
      , NVL(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),0)
      , NVL(TO_NUMBER(FND_PROFILE.VALUE('USER_ID')),0)
      , sysdate
      , NVL(SUBSTR(p_text,1,80),' ')
      );

    -- Added by Khaja for Concurrent Report
    fnd_file.put_line(FND_FILE.LOG,NVL(SUBSTR(p_text,1,80),' '));
    fnd_file.put_line(FND_FILE.OUTPUT,NVL(SUBSTR(p_text,1,80),' '));

    COMMIT;

  EXCEPTION

    WHEN OTHERS THEN

      -- GMA_PURGE_UTILITIES.logprint('Problem raised in GMA_PURGE_UTILITIES.logprint.');
      -- GMA_PURGE_UTILITIES.logprint('Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;
  END logprint;

  /***********************************************************/

  PROCEDURE printdebug(p_purge_id   sy_purg_mst.purge_id%TYPE,
                       p_text       sy_purg_def.sqlstatement%TYPE,
                       p_debug_flag BOOLEAN) IS
  -- print a line of stars before output, show length of string
  BEGIN

    IF (p_debug_flag = TRUE) THEN
      GMA_PURGE_UTILITIES.printline(p_purge_id);
      GMA_PURGE_UTILITIES.logprint(p_purge_id,'Length is ' || TO_CHAR(LENGTH(p_text)));
      GMA_PURGE_UTILITIES.printlong(p_purge_id,p_text);
    END IF;

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Problem raised in GMA_PURGE_UTILITIES.printdebug.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END;

  /***********************************************************/

  PROCEDURE printlong(p_purge_id sy_purg_mst.purge_id%TYPE,
                      p_text sy_purg_def.sqlstatement%TYPE) IS
  -- prints long text string broken at 80 columns

    l_counter   INTEGER;
    l_o_counter INTEGER;
    l_frag      sy_purg_err.text%TYPE;
    l_text      sy_purg_def.sqlstatement%TYPE;

  BEGIN

    -- replace CR with space
    l_text := TRANSLATE(p_text,FND_GLOBAL.LOCAL_CHR(10),' ');

    l_counter := LENGTH(l_text);
    l_o_counter := l_counter + 1;

    WHILE (l_counter > 0) LOOP
      l_frag := SUBSTR(l_text,l_o_counter - l_counter,80);
      l_counter := l_counter - 80;
      GMA_PURGE_UTILITIES.logprint(p_purge_id,l_frag);
    END LOOP;

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.logprint(p_purge_id,
                           'Problem raised in GMA_PURGE_UTILITIES.printlong.');
      GMA_PURGE_UTILITIES.logprint(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END printlong;

  /***********************************************************/

  PROCEDURE debugtime(p_purge_id sy_purg_mst.purge_id%TYPE,
                      p_debug_flag BOOLEAN) IS
  -- prints timestamp if debug flag is TRUE

  BEGIN

    IF (p_debug_flag = TRUE) THEN
      GMA_PURGE_UTILITIES.logprint(p_purge_id,TO_CHAR(SYSDATE,'DD-MON-YYYY HH24:MI:SS'));
    END IF;

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.logprint(p_purge_id,
                           'Problem raised in GMA_PURGE_UTILITIES.debugtime.');
      GMA_PURGE_UTILITIES.logprint(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END debugtime;

  /***********************************************************/

  FUNCTION makearcname(p_purge_id      sy_purg_mst.purge_id%TYPE,
                       p_sourcetable   user_tables.table_name%TYPE)
               RETURN user_tables.table_name%TYPE
   IS

  -- create standard-type archive target table name
  -- if no archive_action is found in sy_pug_def_act then default it to 'A'

  P_ActionTag varchar2(3):='A';

  BEGIN

   IF GMA_PURGE_ENGINE.PA_OPTION in(1,2) THEN
         P_actiontag:='A';
   ELSIF GMA_PURGE_ENGINE.PA_OPTION in(3,4,5) THEN
         P_actiontag:='T';
   end if;

  -- NEW stmt created by Khaja
    RETURN P_ActionTag|| LPAD(TO_CHAR(p_purge_id),5,'0') || '_' || p_sourcetable;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Problem raised in GMA_PURGE_UTILITIES.makearcname.'||p_purge_id||' '||p_sourcetable);
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END makearcname;

  /***********************************************************/

  PROCEDURE printline(p_purge_id sy_purg_mst.purge_id%TYPE) IS
  BEGIN
    GMA_PURGE_UTILITIES.logprint(p_purge_id,
                         '****************************************' ||
                         '****************************************');
  END printline;

  /***********************************************************/

  FUNCTION chartime RETURN     VARCHAR2 IS
  BEGIN

    RETURN TO_CHAR(sysdate,'HH24:MI:SS');

  EXCEPTION

    WHEN OTHERS THEN
      RAISE;

  END chartime;

END GMA_PURGE_UTILITIES;

/
