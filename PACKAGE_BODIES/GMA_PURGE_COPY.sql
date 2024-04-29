--------------------------------------------------------
--  DDL for Package Body GMA_PURGE_COPY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_PURGE_COPY" AS
/* $Header: GMAPRGCB.pls 120.2.12010000.2 2008/11/11 20:55:18 srpuri ship $ */

  g_copycursor      INTEGER;

  FUNCTION archiveengine(p_purge_id        sy_purg_mst.purge_id%TYPE,
                         p_owner           user_users.username%TYPE,
                         p_appl_short_name fnd_application.application_short_name%TYPE,
                         p_user            NUMBER,
                         p_arcrowtablename user_tables.table_name%TYPE,
                         p_tablecount      INTEGER,
                         p_tablename_tab   GMA_PURGE_DDL.g_tablename_tab_type,
                         p_tableaction_tab GMA_PURGE_DDL.g_tableaction_tab_type,
                         p_debug_flag      BOOLEAN,
                         p_commitfrequency INTEGER)
                 RETURN BOOLEAN IS
  -- This FUNCTION logs, copies, deletes, commits.  You name it.

    l_arctablename    user_tables.table_name%TYPE;
                                       -- name of current archive targe table
    l_detailcursor    INTEGER;         -- cursor for detail row statement

    l_detailrowid     ROWID;           -- current detail row rowid

    l_return          INTEGER;         -- holds number of rows returned

    l_sourcetable     user_tables.table_name%TYPE;

    l_sqlstatement    sy_purg_def.sqlstatement%TYPE;

    l_transcount      PLS_INTEGER;         -- transaction commit counter

    t_arctables_tab         GMA_PURGE_DDL.g_tablename_tab_type;
    t_arcactions_tab        GMA_PURGE_DDL.g_tableaction_tab_type;
    t_tablecount            INTEGER;
    t_idx_tablespaces_tab   GMA_PURGE_DDL.g_tablespace_name_tab_type;
    t_idx_tablespaces_count INTEGER;

    pm_matl_dtl_flag boolean :=false;

  BEGIN

    l_transcount := 0; -- Nothin's happened yet.

    -- we will be reusing these...
    l_detailcursor := DBMS_SQL.OPEN_CURSOR;
    g_copycursor   := DBMS_SQL.OPEN_CURSOR;

    -- deal with the tables, starting with the most detail and moving towards
    -- the document master table

    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Starting copy... ' ||
                          GMA_PURGE_UTILITIES.chartime);

    -- do each table
    FOR l_arctableno IN REVERSE 0 .. p_tablecount LOOP

      l_sourcetable := p_tablename_tab(l_arctableno);
      l_arctablename := GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                p_tablename_tab(l_arctableno));

      -- create and open cursor for detail table rowids
      --  Made by Khaja

      -- No literals to change to bind variables as per coding standard,
      -- because none of the variables are entered by user.

      l_sqlstatement := 'SELECT UNIQUE rowidtochar(' ||
                         l_sourcetable ||
                         ') FROM ' ||
                         p_owner||'.'||p_arcrowtablename ||  --Bug#6681753
                         ' WHERE ' ||
                         l_sourcetable ||
                         ' != CHARTOROWID(' ||
                         '''' ||
                         '0' ||
                         '''' ||
                         ')';

      GMA_PURGE_UTILITIES.printdebug(p_purge_id,l_sqlstatement,p_debug_flag);

      DBMS_SQL.PARSE(l_detailcursor,l_sqlstatement,DBMS_SQL.NATIVE);
      DBMS_SQL.DEFINE_COLUMN_ROWID(l_detailcursor,1,l_detailrowid);
      l_return := DBMS_SQL.EXECUTE(l_detailcursor);

      -- The following is long and hard to follow, but runs faster
      -- than breaking it out into functions.  Sorry.

      -- do we want to delete rows?
      IF p_tableaction_tab(l_arctableno) = 'D' THEN

           -- This disables the constriant for only PM_MATL_DTL
          if upper(l_sourcetable)='PM_MATL_DTL' then
             GMA_PURGE_DDL.alterconstraints(p_purge_id,
                                     t_arctables_tab,
                                     t_arcactions_tab,
                                     t_tablecount,
                                     t_idx_tablespaces_tab,
                                     t_idx_tablespaces_count,
                                     p_owner,
                                     'KHG',
                                     'DISABLE',
                                     p_debug_flag);
                     pm_matl_dtl_flag:=true;
           end if;

        -- repeat the following for each unique detail row in each detail table
        LOOP

          -- get the next value or exit loop if there isn't one
          IF DBMS_SQL.FETCH_ROWS(l_detailcursor) <= 0 THEN
            exit;
          END IF;
          DBMS_SQL.COLUMN_VALUE(l_detailcursor,1,l_detailrowid);

          -- do copy
          -- Changing literals to bind variables as per coding standard.
          l_sqlstatement := 'INSERT INTO '|| p_owner || '.' || l_arctablename --Bug#6681753
                             || ' SELECT * FROM ' ||
                             l_sourcetable || ' WHERE ROWID = :b_detailrowid ';
                       --      l_sourcetable || ' WHERE ROWID = ' || '''' ||
                        --     ':b_detailrowid '|| '''';
          DBMS_SQL.PARSE(g_copycursor,l_sqlstatement,DBMS_SQL.NATIVE);

          -- Using bind variable, added by Khaja
          dbms_sql.bind_variable(g_copycursor, 'b_detailrowid',l_detailrowid);

          l_return := DBMS_SQL.EXECUTE(g_copycursor);

          -- do delete
          -- Changing literals to bind variables as per coding standard.
          l_sqlstatement := 'DELETE FROM ' ||l_sourcetable ||
                            ' WHERE ROWID = :b_detailrowid ';
          DBMS_SQL.PARSE(g_copycursor,l_sqlstatement,DBMS_SQL.NATIVE);

          -- Using bind variable, added by Khaja
          dbms_sql.bind_variable(g_copycursor, 'b_detailrowid',l_detailrowid);

          l_return := DBMS_SQL.EXECUTE(g_copycursor);

          -- check to see if we need to do commit
          l_transcount := l_transcount + 1;
          IF (l_transcount >= p_commitfrequency) THEN
            GMA_PURGE_COPY.docommit(p_purge_id,l_transcount);
          END IF;

        END LOOP; -- detail rows


      ELSE
        -- repeat the following for each unique detail row in each detail table
        LOOP

          -- get the next value or exit loop if there isn't one
          IF DBMS_SQL.FETCH_ROWS(l_detailcursor) <= 0 THEN
            exit;
          END IF;
          DBMS_SQL.COLUMN_VALUE(l_detailcursor,1,l_detailrowid);

          -- do copy
          -- Changing literals to bind variables as per coding standard.
          l_sqlstatement := 'INSERT INTO ' || p_owner || '.' || l_arctablename || --Bug#6681753
                             ' SELECT * FROM ' ||
                             l_sourcetable || ' WHERE ROWID =:b_detailrowid ';
          DBMS_SQL.PARSE(g_copycursor,l_sqlstatement,DBMS_SQL.NATIVE);

          -- Using bind variable, added by Khaja
          dbms_sql.bind_variable(g_copycursor, 'b_detailrowid',l_detailrowid);

          l_return := DBMS_SQL.EXECUTE(g_copycursor);

          -- check to see if we need to do commit
          l_transcount := l_transcount + 1;
          IF (l_transcount >= p_commitfrequency) THEN
            GMA_PURGE_COPY.docommit(p_purge_id,l_transcount);
          END IF;

        END LOOP; -- detail rows

      END IF;

      -- logical unit of work commit
      GMA_PURGE_COPY.docommit(p_purge_id,l_transcount);

    END LOOP; -- table loop

    -- close 'em up, turn off the lights
    DBMS_SQL.CLOSE_CURSOR(l_detailcursor);
    DBMS_SQL.CLOSE_CURSOR(g_copycursor);

           -- This enables the constriant for only PM_MATL_DTL
        --  if upper(l_sourcetable)='PM_MATL_DTL' then
           if pm_matl_dtl_flag then
             GMA_PURGE_DDL.alterconstraints(p_purge_id,
                                     t_arctables_tab,
                                     t_arcactions_tab,
                                     t_tablecount,
                                     t_idx_tablespaces_tab,
                                     t_idx_tablespaces_count,
                                     p_owner,
                                     'KHG',
                                     'ENABLE',
                                     p_debug_flag);
           end if;
    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_COPY.archiveengine.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END archiveengine;

  /***********************************************************/

  PROCEDURE docommit(p_purge_id          sy_purg_mst.purge_id%TYPE,
                     p_transcount IN OUT NOCOPY INTEGER) IS
  -- commit changes to database, restart commit counter
  BEGIN

    COMMIT;

    p_transcount := 0;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_COPY.docommit.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END docommit;

END GMA_PURGE_COPY;

/
