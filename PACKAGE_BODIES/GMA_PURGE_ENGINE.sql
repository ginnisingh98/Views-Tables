--------------------------------------------------------
--  DDL for Package Body GMA_PURGE_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMA_PURGE_ENGINE" AS
/* $Header: GMAPRGEB.pls 120.1.12010000.1 2008/07/30 06:17:23 appldev ship $ */

  FUNCTION archivecleanup
            (p_purge_id                     sy_purg_mst.purge_id%TYPE,
             p_tablenames_tab               GMA_PURGE_DDL.g_tablename_tab_type,
             p_tableactions_tab             GMA_PURGE_DDL.g_tableaction_tab_type,
             p_tablecount                   INTEGER,
             p_indexes_tab                  GMA_PURGE_DDL.g_statement_tab_type,
             p_indexcount                   INTEGER,
             p_idx_tablespaces_tab   IN OUT NOCOPY GMA_PURGE_DDL.g_tablespace_name_tab_type,
             p_idx_tablespaces_count IN OUT NOCOPY INTEGER,
             p_owner                        user_users.username%TYPE,
             p_appl_short_name              fnd_application.application_short_name%TYPE,
             p_disable_constraints          BOOLEAN,
             p_debug_flag                   BOOLEAN)
             RETURN                         BOOLEAN;

  PROCEDURE report_exit (p_purge_id         sy_purg_mst.purge_id%TYPE,
                         p_status           INTEGER);

  FUNCTION initarchive
            (p_purge_id                     sy_purg_mst.purge_id%TYPE,
             p_purge_type                   sy_purg_def.purge_type%TYPE,
             p_owner                        user_users.username%TYPE,
             p_appl_short_name              fnd_application.application_short_name%TYPE,
             p_arctablename                 user_tables.table_name%TYPE,
             p_arctables_tab         IN OUT NOCOPY GMA_PURGE_DDL.g_tablename_tab_type,
             p_arcactions_tab        IN OUT NOCOPY GMA_PURGE_DDL.g_tableaction_tab_type,
             p_tablecount            IN OUT NOCOPY INTEGER,
             p_indexes_tab           IN OUT NOCOPY GMA_PURGE_DDL.g_statement_tab_type,
             p_indexcount            IN OUT NOCOPY INTEGER,
             p_idx_tablespaces_tab   IN OUT NOCOPY GMA_PURGE_DDL.g_tablespace_name_tab_type,
             p_idx_tablespaces_count IN OUT NOCOPY INTEGER,
             p_disable_constraints          BOOLEAN,
             p_sizing_flag                  BOOLEAN,
             p_debug_flag                   BOOLEAN)
             RETURN                         BOOLEAN;

  PROCEDURE doarchive
                 (p_purge_id                sy_purg_mst.purge_id%TYPE,
                  p_purge_type              sy_purg_def.purge_type%TYPE,
                  p_owner                   user_users.username%TYPE,
                  p_appl_short_name         fnd_application.application_short_name%TYPE,
                  p_user                    NUMBER,
                  p_arcrowtable             user_tables.table_name%TYPE,
                  p_arctables_tab    IN OUT NOCOPY GMA_PURGE_DDL.g_tablename_tab_type,
                  p_arcactions_tab   IN OUT NOCOPY GMA_PURGE_DDL.g_tableaction_tab_type,
                  p_tablecount       IN OUT NOCOPY INTEGER,
                  p_totarchiverows   IN OUT NOCOPY INTEGER,
                  p_totdeleterows    IN OUT NOCOPY INTEGER,
                  p_sizing                  BOOLEAN,
                  p_commitfrequency         INTEGER,
                  p_disable_constraints     BOOLEAN,
                  p_debug_flag              BOOLEAN);

  PROCEDURE getrows
                 (p_purge_id               sy_purg_mst.purge_id%TYPE,
                  p_owner                  user_users.username%TYPE,
                  p_appl_short_name         fnd_application.application_short_name%TYPE,
                  p_sqlstatement           sy_purg_def.sqlstatement%TYPE,
                  p_tablespace             user_tablespaces.tablespace_name%TYPE,
                  p_arcrowtable            user_tables.table_name%TYPE,
                  p_debug_flag             BOOLEAN);

  PROCEDURE logresults
                 (p_purge_id               sy_purg_mst.purge_id%TYPE,
                  p_user                   NUMBER,
                  p_arctables_tab          GMA_PURGE_DDL.g_tablename_tab_type,
                  p_arcactions_tab         GMA_PURGE_DDL.g_tableaction_tab_type,
                  p_tablecount             INTEGER,
                  p_totarchiverows  IN OUT NOCOPY INTEGER,
                  p_totdeleterows   IN OUT NOCOPY INTEGER);

  PROCEDURE archive(p_purge_id             sy_purg_mst.purge_id%TYPE,
                    p_purge_type             sy_purg_def.purge_type%TYPE,
                    p_owner                  user_users.username%TYPE,
                    p_appl_short_name        fnd_application.application_short_name%TYPE,
                    p_user                   NUMBER,
                    p_sqlstatement           sy_purg_def.sqlstatement%TYPE,
                    p_arcrowbasename         user_tables.table_name%TYPE,
                    p_arctablespace          user_tablespaces.tablespace_name%TYPE,
                    p_arctables_tab   IN OUT NOCOPY GMA_PURGE_DDL.g_tablename_tab_type,
                    p_arcactions_tab  IN OUT NOCOPY GMA_PURGE_DDL.g_tableaction_tab_type,
                    p_totarchiverows  IN OUT NOCOPY INTEGER,
                    p_totdeleterows   IN OUT NOCOPY INTEGER,
                    p_sizing                 BOOLEAN,
                    p_commitfrequency        INTEGER,
                    p_inittime        IN OUT NOCOPY DATE,
                    p_starttime       IN OUT NOCOPY DATE,
                    p_disable_constraints    BOOLEAN,
                    p_debug_flag             BOOLEAN);

  PROCEDURE purge(p_purge_id               sy_purg_mst.purge_id%TYPE,
                  p_purge_type             sy_purg_def.purge_type%TYPE,
                  p_owner                  user_users.username%TYPE,
                  p_appl_short_name        fnd_application.application_short_name%TYPE,
                  p_debug_flag             BOOLEAN);

/* These four GLPOSTED functions is added to check for unposted transactions in purge types,
    The main purpose of this is not to delete any transaction which have unposted rows in it. */

/* added new  TEMP TABLE logic */
  FUNCTION  GLPOSTED_OPSO
            (P_Purge_id    in sy_purg_mst.purge_id%TYPE,
             p_purge_type     sy_purg_def.purge_type%TYPE,
             p_owner          user_users.username%TYPE,
             p_debug_flag     BOOLEAN)
             RETURN LONG;

/* added new  TEMP TABLE logic */
  FUNCTION  GLPOSTED_JRNL
            (P_Purge_id    in sy_purg_mst.purge_id%TYPE,
             p_purge_type     sy_purg_def.purge_type%TYPE,
             p_owner          user_users.username%TYPE,
             p_debug_flag     BOOLEAN)
       RETURN LONG;

/* added new  TEMP TABLE logic */
  FUNCTION  GLPOSTED_PORD
            (P_Purge_id    in sy_purg_mst.purge_id%TYPE,
             p_purge_type     sy_purg_def.purge_type%TYPE,
             p_owner          user_users.username%TYPE,
             p_debug_flag     BOOLEAN)
             RETURN LONG;

/* added new  TEMP TABLE logic */
  FUNCTION  GLPOSTED_PROD
            (P_Purge_id in    sy_purg_mst.purge_id%TYPE,
             p_purge_type     sy_purg_def.purge_type%TYPE,
             p_owner          user_users.username%TYPE,
             p_debug_flag     BOOLEAN)
       RETURN LONG;


  -- Create temporary table for PROD and APRD     KH
  FUNCTION Tempcreate(p_purge_id      sy_purg_mst.purge_id%TYPE,
                      p_purge_type    sy_purg_def.purge_type%TYPE,
                      p_owner         user_users.username%TYPE,
                      p_debug_flag    BOOLEAN)
             RETURN CHAR;

  -- Insert rows in temporary table for PROD and APRD     KH
  PROCEDURE Tempinsert(p_purge_id    sy_purg_mst.purge_id%TYPE,
                       p_purge_type  sy_purg_def.purge_type%TYPE,
                       p_all_ids     number,
                       p_debug_flag  BOOLEAN);

  -- Drop the temporary table for PROD and APRD     KH
  PROCEDURE Tempdrop(p_purge_id    sy_purg_mst.purge_id%TYPE,
                     p_purge_type  sy_purg_def.purge_type%TYPE,
                     p_debug_flag  BOOLEAN);

  -- Drop the temporary table for PROD and APRD     KH
  PROCEDURE ResetTestPurge(p_purge_id    sy_purg_mst.purge_id%TYPE,
                           p_purge_type  sy_purg_def.purge_type%TYPE,
                           p_debug_flag varchar2);

  -- Created a FUNCTION for GSCC standard fix bug 3871659
  --Standard: File.Sql.6 - Do NOT include any references to hardcoded schema
  FUNCTION Get_GmaSchemaName
  RETURN VARCHAR2;


  /***********************************************************/

  PROCEDURE doarchive(p_purge_id              sy_purg_mst.purge_id%TYPE,
                      p_purge_type            sy_purg_def.purge_type%TYPE,
                      p_owner                 user_users.username%TYPE,
                      p_appl_short_name        fnd_application.application_short_name%TYPE,
                      p_user                  NUMBER,
                      p_arcrowtable           user_tables.table_name%TYPE,
                      p_arctables_tab  IN OUT NOCOPY GMA_PURGE_DDL.g_tablename_tab_type,
                      p_arcactions_tab IN OUT NOCOPY GMA_PURGE_DDL.g_tableaction_tab_type,
                      p_tablecount     IN OUT NOCOPY INTEGER,
                      p_totarchiverows IN OUT NOCOPY INTEGER,
                      p_totdeleterows  IN OUT NOCOPY INTEGER,
                      p_sizing                BOOLEAN,
                      p_commitfrequency       INTEGER,
                      p_disable_constraints   BOOLEAN,
                      p_debug_flag            BOOLEAN) IS

    l_indexes_tab           GMA_PURGE_DDL.g_statement_tab_type;
    l_idx_tablespaces_tab   GMA_PURGE_DDL.g_tablespace_name_tab_type;
    l_idx_tablespaces_count INTEGER;

    l_indexcount     BINARY_INTEGER;

    l_badpurge       EXCEPTION;       -- purge did not complete
    l_badsetup       EXCEPTION;       -- initialization failed
    l_noacttable     EXCEPTION;       -- arc action table does not exist
    l_noarctable     EXCEPTION;       -- arc master table does not exist
    l_badcleanup     EXCEPTION;       -- archive cleanup did not complete

    l_initstarttime    DATE;            -- time PA init started
    l_copystarttime    DATE;            -- time actual copying started
    l_cleanupstarttime DATE;            -- time cleanup started

    l_continue         BOOLEAN;
  BEGIN


    -- make sure archive master table exists
    IF (GMA_PURGE_VALIDATE.is_table(p_purge_id,p_arcrowtable) <> TRUE) THEN
      RAISE l_noarctable;
    END IF;

    -- get set up for archive; create target archive tables, disable constraints
    l_initstarttime := sysdate;
    IF (GMA_PURGE_ENGINE.initarchive(p_purge_id,
                                p_purge_type,
                                p_owner,
                                p_appl_short_name,
                                p_arcrowtable,
                                p_arctables_tab,
                                p_arcactions_tab,
                                p_tablecount,
                                l_indexes_tab,
                                l_indexcount,
                                l_idx_tablespaces_tab,
                                l_idx_tablespaces_count,
                                p_disable_constraints,
                                p_sizing,
                                p_debug_flag) = FALSE) THEN
      RAISE l_badsetup;
    END IF;
 --   GMA_PURGE_UTILITIES.printlong(p_purge_id,'Archive initialization completed in ' ||
    GMA_PURGE_UTILITIES.printlong(p_purge_id,GMA_PURGE_ENGINE.PA_OPTION_NAME|| ' initialization completed in ' ||
            to_char(trunc((sysdate - l_initstarttime) * 86400)) ||
            ' seconds - ' ||
            GMA_PURGE_UTILITIES.chartime);

    -- well, we're ready...  Do the purge
    l_copystarttime := sysdate;
    IF (GMA_PURGE_COPY.archiveengine(p_purge_id,
                                  p_owner,
                                  p_appl_short_name,
                                  p_user,
                                  p_arcrowtable,
                                  p_tablecount,
                                  p_arctables_tab,
                                  p_arcactions_tab,
                                  p_debug_flag,
                                  p_commitfrequency) <> TRUE) THEN
      RAISE l_badpurge;
    END IF;

    -- log copy time to master record for statistics
    UPDATE sy_purg_mst
      SET archive_table_count = (p_tablecount + 1)
      ,   copy_elapsed_time   =
                        trunc(((sysdate - l_copystarttime) * 86400),2)
      ,   last_update_date    = sysdate
      ,   last_updated_by     = p_user
      WHERE purge_id = p_purge_id;

    COMMIT;

 --   GMA_PURGE_UTILITIES.printlong(p_purge_id,'Archive copy function completed in ' ||
    GMA_PURGE_UTILITIES.printlong(p_purge_id,GMA_PURGE_ENGINE.PA_OPTION_NAME||' copy function completed in ' ||
            to_char(trunc((sysdate - l_copystarttime) * 86400)) ||
            ' seconds - ' ||
            GMA_PURGE_UTILITIES.chartime);

    -- clean up a few things
    l_cleanupstarttime := SYSDATE;
    IF (GMA_PURGE_ENGINE.archivecleanup(p_purge_id,
                                   p_arctables_tab,
                                   p_arcactions_tab,
                                   p_tablecount,
                                   l_indexes_tab,
                                   l_indexcount,
                                   l_idx_tablespaces_tab,
                                   l_idx_tablespaces_count,
                                   p_owner,
                                   p_appl_short_name,
                                   p_disable_constraints,
                                   p_debug_flag) <> TRUE) THEN
      RAISE l_badcleanup;
    END IF;
  --  GMA_PURGE_UTILITIES.printlong(p_purge_id,'Cleanup function completed in ' ||
    GMA_PURGE_UTILITIES.printlong(p_purge_id,GMA_PURGE_ENGINE.PA_OPTION_NAME||' Cleanup function completed in ' ||
        to_char(trunc((sysdate - l_cleanupstarttime) * 86400)) ||
        ' seconds - ' ||
        GMA_PURGE_UTILITIES.chartime);

    -- Cool!  We're done.
  --  GMA_PURGE_UTILITIES.printlong(p_purge_id,'Archive function completed in ' ||
    GMA_PURGE_UTILITIES.printlong(p_purge_id,GMA_PURGE_ENGINE.PA_OPTION_NAME||' function completed in ' ||
        to_char(trunc((sysdate - l_initstarttime) * 86400)) ||
        ' seconds - ' ||
        GMA_PURGE_UTILITIES.chartime);

  EXCEPTION

    WHEN l_noacttable THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Serious problem - no archive action table');
      RAISE;

    WHEN l_noarctable THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Serious problem - no archive master table');
      RAISE;

    WHEN l_badpurge THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Serious problem - purge did not complete.');
      -- try to fix DB state
       l_continue := GMA_PURGE_ENGINE.archivecleanup(p_purge_id,
                                              p_arctables_tab,
                                              p_arcactions_tab,
                                              p_tablecount,
                                              l_indexes_tab,
                                              l_indexcount,
                                              l_idx_tablespaces_tab,
                                              l_idx_tablespaces_count,
                                              p_owner,
                                              p_appl_short_name,
                                              p_disable_constraints,
                                              p_debug_flag);

    WHEN l_badsetup THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Serious problem - archive master table setup');
      -- try to fix DB state
       l_continue := GMA_PURGE_ENGINE.archivecleanup(p_purge_id,
                                              p_arctables_tab,
                                              p_arcactions_tab,
                                              p_tablecount,
                                              l_indexes_tab,
                                              l_indexcount,
                                              l_idx_tablespaces_tab,
                                              l_idx_tablespaces_count,
                                              p_owner,
                                              p_appl_short_name,
                                              p_disable_constraints,
                                              p_debug_flag);
      RAISE;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Problem raised in GMA_PURGE_ENGINE.doarchive.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                           'Unhandled EXCEPTION - ' || sqlerrm);
      -- try to fix DB state
       l_continue := GMA_PURGE_ENGINE.archivecleanup(p_purge_id,
                                              p_arctables_tab,
                                              p_arcactions_tab,
                                              p_tablecount,
                                              l_indexes_tab,
                                              l_indexcount,
                                              l_idx_tablespaces_tab,
                                              l_idx_tablespaces_count,
                                              p_owner,
                                              p_appl_short_name,
                                              p_disable_constraints,
                                              p_debug_flag);
      RAISE;

  END doarchive;

  /***********************************************************/

  FUNCTION archivecleanup
            (p_purge_id                     sy_purg_mst.purge_id%TYPE,
             p_tablenames_tab               GMA_PURGE_DDL.g_tablename_tab_type,
             p_tableactions_tab             GMA_PURGE_DDL.g_tableaction_tab_type,
             p_tablecount                   INTEGER,
             p_indexes_tab                  GMA_PURGE_DDL.g_statement_tab_type,
             p_indexcount                   INTEGER,
             p_idx_tablespaces_tab   IN OUT NOCOPY GMA_PURGE_DDL.g_tablespace_name_tab_type,
             p_idx_tablespaces_count IN OUT NOCOPY INTEGER,
             p_owner                        user_users.username%TYPE,
             p_appl_short_name              fnd_application.application_short_name%TYPE,
             p_disable_constraints          BOOLEAN,
             p_debug_flag                   BOOLEAN)
             RETURN                         BOOLEAN IS
  BEGIN

    -- Re-enable the constraints if we're supposed to.
    IF (p_disable_constraints = TRUE) THEN
      GMA_PURGE_DDL.enableindexes(p_purge_id,
                                  p_indexes_tab,
                                  p_indexcount,
                                  p_idx_tablespaces_tab,
                                  p_idx_tablespaces_count,
                                  p_owner,
                                  p_appl_short_name,
                                  p_debug_flag);
      GMA_PURGE_DDL.alterconstraints(p_purge_id,
                                     p_tablenames_tab,
                                     p_tableactions_tab,
                                     p_tablecount,
                                     p_idx_tablespaces_tab,
                                     p_idx_tablespaces_count,
                                     p_owner,
                                     p_appl_short_name,
                                     'ENABLE',
                                     p_debug_flag);
    END IF;

    RETURN TRUE;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.archivecleanup.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END;

  /***********************************************************/

  FUNCTION initarchive
            (p_purge_id                     sy_purg_mst.purge_id%TYPE,
             p_purge_type                   sy_purg_def.purge_type%TYPE,
             p_owner                        user_users.username%TYPE,
             p_appl_short_name              fnd_application.application_short_name%TYPE,
             p_arctablename                 user_tables.table_name%TYPE,
             p_arctables_tab         IN OUT NOCOPY GMA_PURGE_DDL.g_tablename_tab_type,
             p_arcactions_tab        IN OUT NOCOPY GMA_PURGE_DDL.g_tableaction_tab_type,
             p_tablecount            IN OUT NOCOPY INTEGER,
             p_indexes_tab           IN OUT NOCOPY GMA_PURGE_DDL.g_statement_tab_type,
             p_indexcount            IN OUT NOCOPY INTEGER,
             p_idx_tablespaces_tab   IN OUT NOCOPY GMA_PURGE_DDL.g_tablespace_name_tab_type,
             p_idx_tablespaces_count IN OUT NOCOPY INTEGER,
             p_disable_constraints          BOOLEAN,
             p_sizing_flag                  BOOLEAN,
             p_debug_flag                   BOOLEAN)
             RETURN                         BOOLEAN IS
  -- Check archive row table to make sure all columns are real
  -- tables with the right row type (rowid).  Put all table names
  -- in p_arctablestab, with master table first.

    CURSOR l_tablename_rows_cur (c_purge_type   sy_purg_def.purge_type%TYPE,
                                 c_arctablename user_tables.table_name%TYPE,
                                 c_schema_name VARCHAR2) IS
      SELECT UC.column_name                                 arctable
      ,      UC.data_type                                   drowtype
      ,      decode(nvl(SD.archive_action,'K'),'D','D','K') arcaction
      ,      UU.default_tablespace                          arctablespace
      FROM   all_tab_columns                                UC
      ,      dba_users                                      UU
      ,      sy_purg_def_act                                SD
      ,      sy_purg_def                                    SP
      WHERE  UC.owner = c_schema_name
      AND    UU.USERNAME='GMA'
      AND    SD.purge_type = SP.purge_type
      AND    SD.table_name = UC.column_name
      AND    SP.purge_type = c_purge_type
      AND    UC.table_name = c_arctablename
      ORDER  BY UC.column_id;
/*
      SELECT UC.column_name                                 arctable
      ,      UC.data_type                                   drowtype
      ,      decode(nvl(SD.archive_action,'K'),'D','D','K') arcaction
      ,      nvl(SD.target_tablespace,
                nvl(SP.default_target_tablespace,
                    UU.default_tablespace
                   )
                )                                           arctablespace
      FROM   user_users                                     UU
      ,      sy_purg_def_act                                SD
      ,      sy_purg_def                                    SP
      ,      all_tab_columns                                UC
      WHERE  UC.owner='GMA'
      AND    SD.purge_type = SP.purge_type
      AND    SD.table_name = UC.column_name
      AND    SP.purge_type = c_purge_type
      AND    UC.table_name = c_arctablename
      ORDER  BY UC.column_id;
*/

      -- Changed by Khaja      user_tab_columns TO all_tab_columns
    l_badrowtype  EXCEPTION;
    l_tablecount  INTEGER;
    l_schema_name VARCHAR2(30); /* Bug 4344986 */

  BEGIN

    l_tablecount := -1;

    l_schema_name := Get_GmaSchemaName; /* Bug 4344986 */

    -- do setup for each table
    FOR l_tablename_row IN l_tablename_rows_cur(p_purge_type,
                                                p_arctablename,
                                                l_schema_name) LOOP
      l_tablecount := l_tablecount + 1; -- start table index at zero

      -- make sure the column has the correct datatype, namely rowid
      IF (l_tablename_row.drowtype <> 'ROWID') THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
          'Problem with ' || p_arctablename || ' - ' ||
          l_tablename_row.arctable || 'of type ' || l_tablename_row.drowtype);
        RAISE l_badrowtype;
      END IF;

      -- make sure the table exists
      IF (GMA_PURGE_VALIDATE.is_table(p_purge_id,l_tablename_row.arctable) <> TRUE) THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
          'Problem with ' || p_arctablename || ' - ' ||
          l_tablename_row.arctable || ' does not exist in ALL_TABLES.');
        RETURN FALSE;
      END IF;

      -- create archive table
      IF (GMA_PURGE_DDL.createarctable(p_purge_id,
                                     l_tablename_row.arctable,
                                     l_tablename_row.arctablespace,
                                     p_owner,
                                     p_appl_short_name,
                                     p_sizing_flag,
                                     p_arctablename,
                                     p_debug_flag) <> TRUE) THEN
        RETURN FALSE;
      END IF;

      -- Add the table to the array
      p_arctables_tab(l_tablecount) := l_tablename_row.arctable;

     -- added by khaja for TEST archive
        IF PA_OPTION=3 THEN
               l_tablename_row.arcaction:='K';
        END IF;
      -- get the archive action and add that to the action table
        p_arcactions_tab(l_tablecount) := l_tablename_row.arcaction;

      p_tablecount := l_tablecount;

    END LOOP; -- each table

    -- disable constraints if we're supposed to.
    IF (p_disable_constraints = TRUE) THEN
      GMA_PURGE_DDL.alterconstraints(p_purge_id,
                                     p_arctables_tab,
                                     p_arcactions_tab,
                                     l_tablecount,
                                     p_idx_tablespaces_tab,
                                     p_idx_tablespaces_count,
                                     p_owner,
                                     p_appl_short_name,
                                     'DISABLE',
                                     p_debug_flag);
      GMA_PURGE_DDL.disableindexes(p_purge_id,
                                   p_arctables_tab,
                                   p_arcactions_tab,
                                   l_tablecount,
                                   p_indexes_tab,
                                   p_indexcount,
                                   p_owner,
                                   p_appl_short_name,
                                   p_debug_flag);
    END IF;

    RETURN TRUE;

  EXCEPTION

    WHEN l_badrowtype THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Serious problem - archive master table setup');
      RAISE;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.initarchive.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END initarchive;

  /***********************************************************/

  PROCEDURE main(errbuf                OUT NOCOPY VARCHAR2,
                 retcode               OUT NOCOPY VARCHAR2,
                 p_purge_id            IN sy_purg_mst.purge_id%TYPE,
                 p_appl_short_name     IN fnd_application.application_short_name%TYPE,
                 p_job_run             IN NUMBER,
                 p_job_name            IN VARCHAR2) IS


-- JKB Removed default above per GSCC.

  -- main function for archive function

    l_debug_flag_f          CHAR(1);
    l_disable_constraints_f CHAR(1);
    l_sizing_f              CHAR(1);
    l_debug_flag            BOOLEAN;
    l_disable_constraints   BOOLEAN;
    l_sizing                BOOLEAN;
    l_commitfrequency       INTEGER;
    l_owner                 user_users.username%TYPE;
    l_owner_verify          user_users.username%TYPE;
    l_aol_status            BOOLEAN;

    l_status         sy_purg_mst.purge_status%TYPE;
    l_testarcstatus  sy_purg_mst.status%TYPE;
                           -- You know it.
    l_orastatus sy_purg_mst.ora_status%TYPE;
                           -- Not that we're expecting trouble or anything.

    -- dummy variables.
    l_app_status            VARCHAR2(50);
    l_app_industry          VARCHAR2(50);

    -- funky little cheats
    CURSOR l_arccursor_cur(c_purge_id sy_purg_mst.purge_id%TYPE) IS
      SELECT SM.purge_type                          purgetype
      ,      SD.sqlstatement                        arcsqlstatement
 --     ,      NVL(SD.work_tablespace,
      ,           UU.default_tablespace             arctablespace
      ,      SM.purge_status                        arcstatus
      ,      SM.status                              testarcstatus
      ,      nvl(SM.debug_flag,'F')                 debug_flag
      ,      nvl(SM.disable_constraints_flag,'F')   disable_constraints
      ,      nvl(SM.calculate_storage_flag,'F')     storage_flag
      ,      nvl(SM.commit_frequency,750)           commit_frequency
      ,      nvl(SM.object_owner,'<NULL>')          object_owner
      FROM   dba_users                              UU
      ,      sy_purg_mst                            SM
      ,      sy_purg_def                            SD
      WHERE  SD.purge_type (+) = SM.purge_type
      AND    UU.username = 'GMA'
      AND    SM.purge_id = c_purge_id;

   --  Made BY KHAJA FROM   user_users  UU
    CURSOR l_critcursor_cur(c_purge_id   sy_purg_mst.purge_id%TYPE) IS

      SELECT DC.crit_tag                                  crit_tag
      ,      REPLACE(NVL(DC.value_mask,'{X}'),
                     '{X}',
                     NVL(MC.crit_value,DC.default_value)) value
      FROM   sy_purg_mst_crit                             MC
      ,      sy_purg_def_crit                             DC
      ,      sy_purg_mst                                  MS
      WHERE  MC.crit_tag   = DC.crit_tag
      AND    MC.purge_id   = MS.purge_id
      AND    DC.purge_type = MS.purge_type
      AND    MS.purge_id   = c_purge_id;

    CURSOR l_schema_cursor(c_schema_name all_users.username%TYPE) IS
      SELECT username
      FROM   all_users
      WHERE  username = c_schema_name;

      l_starttime DATE;
      l_inittime  DATE;

      l_user         NUMBER;
      l_sqlstatement sy_purg_def.sqlstatement%TYPE;
      l_purge_type   sy_purg_def.purge_type%TYPE;
      l_tablespace   user_tablespaces.tablespace_name%TYPE;

      l_tablenames_tab   GMA_PURGE_DDL.g_tablename_tab_type;
      l_tableactions_tab GMA_PURGE_DDL.g_tableaction_tab_type;

      l_totarchiverows INTEGER;
      l_totdeleterows  INTEGER;

      l_elapsed        NUMBER;

      l_badstatement EXCEPTION;
      glposted_badstatement EXCEPTION;
      get_all_ids  long;
      gl_posted_flag  varchar2(10);
      pa_initiate_time  varchar2(50);

      l_temptable       varchar2(2000);


  BEGIN

-- fnd_file.put_line(FND_FILE.LOG,NVL(SUBSTR(p_appl_short_name,1,80),' '));

    -- Let the rubes know what's shakin'...
    GMA_PURGE_UTILITIES.printline(p_purge_id);

    pa_initiate_time:=GMA_PURGE_UTILITIES.chartime;

    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                  --      'PA initializing for process id ' ||
                          P_job_name||'  initializing for process id ' ||
                          p_purge_id ||
                          ' - '||pa_initiate_time);
                  --        GMA_PURGE_UTILITIES.chartime);
     pa_initiate_time:=to_char(sysdate,'DD-MM-YYYY')||' '||pa_initiate_time;

    -- get process id, sql statement, user name
    OPEN  l_arccursor_cur(p_purge_id);
    FETCH l_arccursor_cur INTO l_purge_type,l_sqlstatement,l_tablespace,l_status,l_testarcstatus,
                               l_debug_flag_f,l_disable_constraints_f,
                               l_sizing_f,l_commitfrequency,l_owner;

         if l_debug_flag_f='Y' then
                  l_debug_flag_f:='T';
         elsif l_debug_flag_f='N' then
                  l_debug_flag_f:='F';
         end if;

         if l_disable_constraints_f='Y' then
                  l_disable_constraints_f:='T';
         elsif l_disable_constraints_f='N' then
                  l_disable_constraints_f:='F';
         end if;

         if l_sizing_f='Y' then
                  l_sizing_f:='T';
         elsif l_sizing_f='N' then
                  l_sizing_f:='F';
         end if;

    CLOSE l_arccursor_cur;

    -- get lost if purge ID isn't good
    IF NVL(l_purge_type,'<><>') = '<><>' THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Purge id ' || p_purge_id || ' does not exist.');
      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);
      return;
    END IF;

    -- get lost if purge type isn't good
    IF NVL(l_sqlstatement,'<><>') = '<><>' THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Purge type ' || l_purge_type || ' does not exist.');
      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);
      return;
    END IF;
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Purge type is ' ||
                          l_purge_type || '.');

    -- make sure we have a good schema name
    l_aol_status := FND_INSTALLATION.get_app_info(p_appl_short_name,
                                                  l_app_status,
                                                  l_app_industry,
                                                  l_owner);
    IF (l_aol_status = false) THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Purge owner ' || l_owner || ' can''''t be determined. (FND_INSTALLATION.get_app_info');
      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);
      RETURN;
    END IF;
    BEGIN
      OPEN l_schema_cursor(l_owner);
      FETCH l_schema_cursor INTO l_owner_verify;
      CLOSE l_schema_cursor;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Purge owner ' || l_owner || ' can''''t be determined. (select schemaname)');
      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);
      RETURN;
    END;

    -- get user ID
    l_user := TO_NUMBER(FND_PROFILE.VALUE('USER_ID'));

    PA_OPTION:=P_JOB_RUN;
    PA_OPTION_NAME:=P_JOB_NAME;
    if P_JOB_RUN in (1,2) then
       l_status:=l_status;
    elsif P_JOB_RUN in(3,4,5) then
       l_status:=l_testarcstatus;
    end if;


    -- status checking, updating here
    IF (l_status <> 0 AND l_status <> 2) THEN
      IF (l_status = 1 OR l_status = 3) THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Purge ID in process with status - '
                              || to_char(l_status) ||
                              ' - exiting.');
      ELSIF (l_status = 4) THEN
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'This purge is complete (status 4) - exiting.');
      ELSIF (l_status < 0) THEN
              if P_JOB_RUN in(3,4,5) then
                       GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Cleaning Error purge status - ' || to_char(l_status)||'.');
                       ResetTestPurge(p_purge_id,
                                      l_purge_type,
                                      l_debug_flag_f);

                        --l_status:=l_testarcstatus;
                        l_status:=0;
              else
                      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Error purge status - ' || to_char(l_status) ||
                              ' - exiting.');
              end if;
      ELSE
        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Unknown purge status - ' || to_char(l_status) ||
                              ' - exiting.');
      END IF;

      IF l_status<>0 THEN   --added by Khaja
      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);
      RETURN;
      END IF;

    END IF;

    IF (l_status = 0) THEN
      l_status := 1;
    ELSIF (l_status = 2) THEN
      if PA_OPTION in(2,5) then
         l_status := 3;
      end if;
    END IF;

  if P_JOB_RUN in (1,2) then

    UPDATE sy_purg_mst
      SET purge_status = l_status
      ,   last_update_date = sysdate
      ,   last_updated_by   = l_user
      ,   archive_start_time = decode(l_status,1,sysdate,archive_start_time)
      ,   purge_start_time   = decode(l_status,3,sysdate,purge_start_time)
      WHERE purge_id = p_purge_id;
-- Bug #2599273 (JKB) Changed statuses above to match IF above that.

    COMMIT;

  elsif P_JOB_RUN in (3,4,5) then
   -- added by KH for test type
    UPDATE sy_purg_mst
      SET status = l_status
      ,   last_update_date = sysdate
      ,   last_updated_by   = l_user
      ,   archive_start_time = decode(l_status,1,sysdate,archive_start_time)
      ,   purge_start_time   = decode(l_status,3,sysdate,purge_start_time)
      WHERE purge_id = p_purge_id;
     commit;
  end if;


    -- grab a few things before we get started...
    l_starttime := SYSDATE;

    -- check the flags
    IF (l_debug_flag_f = 'T') THEN
      l_debug_flag := TRUE;
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Debugging is on.');
    ELSE
      l_debug_flag := FALSE;
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Debugging is off.');
    END IF;

    -- are we going to size the tables before copying?
    IF (l_sizing_f = 'T') THEN
      l_sizing := TRUE;
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Table sizing is on.');
    ELSE
      l_sizing := FALSE;
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Table sizing is off.');
    END IF;

    -- are we going to disable constraints if deleting?
    IF (l_disable_constraints_f = 'T') THEN
      l_disable_constraints := TRUE;
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Constraint disabling is on.');
    ELSE
      l_disable_constraints := FALSE;
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Constraint disabling is off.');
    END IF;

    -- Tell 'em the news.
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Commit Frequency is set to ' ||
                         to_char(l_commitfrequency) ||
                         '.');
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Object owner is ' ||
                          l_owner || '.');

    IF (l_status = 1) THEN


      -- get purge criteria
      FOR l_crit_row IN l_critcursor_cur(p_purge_id) LOOP
        l_sqlstatement := replace(l_sqlstatement,
                                   '<' || l_crit_row.crit_tag || '>',
                                   l_crit_row.value);
      END LOOP;

     -- check the GL_POSTED_IND for OPSO
      if upper(l_purge_type) in('OPSO','AOPS') then
           get_all_ids:=GLPOSTED_OPSO(p_purge_id,
                                      l_purge_type,
                                      l_owner,
                                      l_debug_flag);
           gl_posted_flag:=substr(get_all_ids,1,1);
           get_all_ids:=substr(get_all_ids,3);

          if gl_posted_flag='F' then
             RAISE glposted_badstatement;
          else
          --l_sqlstatement := replace(l_sqlstatement,'<GLPOSTED>',get_all_ids);
            l_sqlstatement := replace(l_sqlstatement,'<TEMPTABLE>',get_all_ids);

          end if;
      end if;

     -- check the GL_POSTED_IND for JRNL
      if upper(l_purge_type) in ('JRNL','AJNL') then
           get_all_ids:=GLPOSTED_JRNL(p_purge_id,
                                      l_purge_type,
                                      l_owner,
                                      l_debug_flag);
           gl_posted_flag:=substr(get_all_ids,1,1);
           get_all_ids:=substr(get_all_ids,3);

          if gl_posted_flag='F' then
             RAISE glposted_badstatement;
          else
          --  l_sqlstatement := replace(l_sqlstatement,'<GLPOSTED>',get_all_ids);
            l_sqlstatement := replace(l_sqlstatement,'<TEMPTABLE>',get_all_ids);

          end if;
      end if;

    -- check the GL_POSTED_IND for PROD  added by KH
      if upper(l_purge_type) in('PROD','APRD') then

           -- Get Posted flag and temp table name from GLPOSTED_PROD
           get_all_ids:=GMA_PURGE_ENGINE.glposted_prod(p_purge_id,
                                                       l_purge_type,
                                                       l_owner,
                                                       l_debug_flag);
           -- Take the Posted flag
           gl_posted_flag:=substr(get_all_ids,1,1);
           -- Take the Temp table name
           l_temptable:=substr(get_all_ids,3);

           -- Prepare the temptable with owner
           get_all_ids:=substr(get_all_ids,3);

          if gl_posted_flag='F' then
             RAISE glposted_badstatement;
          else
            -- Replace the TEMPTABLE tag in main SQL for PROD and APRD
            l_sqlstatement := replace(l_sqlstatement,'<TEMPTABLE>',get_all_ids);

          end if;
      end if;


     -- check the GL_POSTED_IND for PORD
      if upper(l_purge_type) in ('PORD','APOR') then
           get_all_ids:=GLPOSTED_PORD(p_purge_id,
                                      l_purge_type,
                                      l_owner,
                                      l_debug_flag);
           gl_posted_flag:=substr(get_all_ids,1,1);
           get_all_ids:=substr(get_all_ids,3);

          if gl_posted_flag='F' then
             RAISE glposted_badstatement;
          else
            --l_sqlstatement := replace(l_sqlstatement,'<GLPOSTED>',get_all_ids);
            l_sqlstatement := replace(l_sqlstatement,'<TEMPTABLE>',get_all_ids);

          end if;
      end if;

     -- do it up.
      GMA_PURGE_ENGINE.archive(p_purge_id,
                               l_purge_type,
                               l_owner,
                               p_appl_short_name,
                               l_user,
                               l_sqlstatement,
                               'ARCHIVEROWS',
                               l_tablespace,
                               l_tablenames_tab,
                               l_tableactions_tab,
                               l_totarchiverows,
                               l_totdeleterows,
                               l_sizing,
                               l_commitfrequency,
                               l_inittime,
                               l_starttime,
                               l_disable_constraints,
                               l_debug_flag);

      l_elapsed := trunc(((SYSDATE - l_starttime) * 86400),2);

      -- bug 3216740 ARCHIVE AND PURGE (DIVISOR IS EQUAL TO ZERO FIX (khaja)
      if l_elapsed<=0 then
         l_elapsed:=1;
      end if;

  if P_JOB_RUN in (1,2) then

      UPDATE sy_purg_mst
--      SET rows_archived = decode(l_status,1,l_totarchiverows, rows_archived)
        SET   rows_deleted  = decode(l_status,1,l_totdeleterows,
                                               rows_deleted)
        ,   archive_elapsed_time  =
                decode(l_status,1,l_elapsed,archive_elapsed_time)
        ,   rows_per_second = trunc((l_totarchiverows/
                                     decode(l_elapsed,
                                              0,1,
                                              l_elapsed))
                                     ,2)
        ,   copy_rows_per_second = trunc((l_totarchiverows/
                                     decode(copy_elapsed_time,
                                              0,1,
                                              copy_elapsed_time))
                                     ,2)
        ,   last_update_date = sysdate
        ,   last_updated_by   = l_user
        WHERE purge_id = p_purge_id;
  elsif P_JOB_RUN in (3,4,5) then
      UPDATE sy_purg_mst
         SET rows_archived = decode(l_status,1,l_totarchiverows,
                                              rows_archived)
     --   ,   rows_deleted  = decode(l_status,1,l_totdeleterows,
     --                                         rows_deleted)
        ,   archive_elapsed_time  =
                decode(l_status,1,l_elapsed,archive_elapsed_time)
        ,   rows_per_second = trunc((l_totarchiverows/
                                     decode(l_elapsed,
                                              0,1,
                                              l_elapsed))
                                     ,2)
        ,   copy_rows_per_second = trunc((l_totarchiverows/
                                     decode(copy_elapsed_time,
                                              0,1,
                                              copy_elapsed_time))
                                     ,2)
        ,   last_update_date = sysdate
        ,   last_updated_by   = l_user
        WHERE purge_id = p_purge_id;
    end if;


    ELSE
      if PA_OPTION in(2,5) then
      GMA_PURGE_ENGINE.purge(p_purge_id,l_purge_type,l_owner,p_appl_short_name,l_debug_flag);
      end if;

      l_elapsed := trunc(((SYSDATE - l_starttime) * 86400),2);

      -- bug 3216740 ARCHIVE AND PURGE (DIVISOR IS EQUAL TO ZERO FIX (khaja)
      if l_elapsed<=0 then
         l_elapsed:=1;
      end if;


      UPDATE sy_purg_mst
        SET purge_elapsed_time    =
                decode(l_status,3,l_elapsed,purge_elapsed_time)
        ,   last_update_date = sysdate
        ,   last_updated_by   = l_user
        WHERE purge_id = p_purge_id;

    END IF;

    COMMIT;

    -- status checking, updating here
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                       --   'PA completed in ' || TO_CHAR(l_elapsed)
                          P_JOB_NAME||' completed in ' || TO_CHAR(l_elapsed)
                          || ' seconds - '||
                          GMA_PURGE_UTILITIES.chartime);
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                   'R/S ' || TO_CHAR(trunc((l_totarchiverows/l_elapsed),2)));

    IF (l_status = 3) THEN
      l_status := 4;
    ELSIF (l_status = 1) THEN
      l_status := 2;
    END IF;

  if P_JOB_RUN in (1,2) then

     -- Added by Khaja to place the actual Archive time
    UPDATE sy_purg_mst
      SET purge_status = l_status
      ,   archive_start_time=to_date(pa_initiate_time,'DD-MM-YYYY HH24:MI:SS')
      ,   last_update_date = sysdate
      ,   last_updated_by   = l_user
      WHERE purge_id = p_purge_id;

    COMMIT;
  elsif P_JOB_RUN in(3,4,5) then
    UPDATE sy_purg_mst
      SET status = l_status
      ,   archive_start_time=to_date(pa_initiate_time,'DD-MM-YYYY HH24:MI:SS')
      ,   last_update_date = sysdate
      ,   last_updated_by   = l_user
      WHERE purge_id = p_purge_id;
    commit;
  end if;

    GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);

    -- DBMS_SQL.CLOSE_CURSOR(NULL);
    RETURN; -- Exit program.

  EXCEPTION

    WHEN l_badstatement THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'There is a problem with the purge definition.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            l_sqlstatement);
      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);
    WHEN glposted_badstatement THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Not Purging, No posted Rows found.');
        if P_JOB_RUN in (1,2) then

              UPDATE sy_purg_mst
              SET purge_status = 0
	     	,   last_update_date = sysdate
   		,   last_updated_by   = l_user
   	   	,   archive_start_time = decode(l_status,1,sysdate,archive_start_time)
   	   	,   purge_start_time   = decode(l_status,3,sysdate,purge_start_time)
     	      WHERE purge_id = p_purge_id;

              COMMIT;

	elsif P_JOB_RUN in (3,4,5) then
               -- added by KH for test type
               UPDATE sy_purg_mst
  	       SET status = 0
  	       ,   last_update_date = sysdate
   	       ,   last_updated_by   = l_user
 	       ,   archive_start_time = decode(l_status,1,sysdate,archive_start_time)
  	       ,   purge_start_time   = decode(l_status,3,sysdate,purge_start_time)
  	       WHERE purge_id = p_purge_id;
      	      commit;
 	 end if;
                 l_status:=0;

      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);
    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.main.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            '## ' || sqlerrm);
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Exiting.');
      GMA_PURGE_ENGINE.report_exit(p_purge_id,l_status);

      l_orastatus := sqlcode;

  if P_JOB_RUN in (1,2) then
      UPDATE sy_purg_mst SY
        SET   SY.purge_status = (SY.purge_status - (SY.purge_status * 2))
        ,     SY.ora_status = l_orastatus
        WHERE SY.purge_id =  p_purge_id;
  elsif P_JOB_RUN in(3,4,5) then
      UPDATE sy_purg_mst SY
        SET   SY.status = (SY.status - (SY.status * 2))
        ,     SY.ora_status = l_orastatus
        WHERE SY.purge_id =  p_purge_id;
  end if;

      COMMIT;

      -- DBMS_SQL.CLOSE_CURSOR(NULL);

  END main;

  /***********************************************************/

  PROCEDURE getrows(p_purge_id        sy_purg_mst.purge_id%TYPE,
                    p_owner           user_users.username%TYPE,
                    p_appl_short_name fnd_application.application_short_name%TYPE,
                    p_sqlstatement    sy_purg_def.sqlstatement%TYPE,
                    p_tablespace      user_tablespaces.tablespace_name%TYPE,
                    p_arcrowtable     user_tables.table_name%TYPE,
                    p_debug_flag      BOOLEAN) IS

  -- create master rows table for archive

    l_result INTEGER;
    l_rows   INTEGER;
    l_cursor INTEGER;
    l_badstatement EXCEPTION;
    l_sqlstatement sy_purg_def.sqlstatement%TYPE;

  BEGIN

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    l_sqlstatement := 'CREATE TABLE ' || p_owner || '.' ||
                          p_arcrowtable  || ' TABLESPACE ' ||
                          p_tablespace || ' nologging AS ' ||
                          p_sqlstatement;

    IF (p_debug_flag = TRUE) THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);
    END IF;
-- MADE BY KHAJA
--    IF (GMA_PURGE_ENGINE.use_ad_ddl = TRUE) THEN
--    AD_DDL.DO_DDL(p_owner,p_appl_short_name,AD_DDL.CREATE_TABLE,
--                    l_sqlstatement,p_arcrowtable);
--    ELSE
      DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
      l_result := DBMS_SQL.EXECUTE(l_cursor);
--    END IF;

    IF l_result <> 0 THEN
      RAISE l_badstatement;
    END IF;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    RETURN;

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.getrows.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END getrows;

  /***********************************************************/

  PROCEDURE logresults(p_purge_id              sy_purg_mst.purge_id%TYPE,
                       p_user                  NUMBER,
                       p_arctables_tab         GMA_PURGE_DDL.g_tablename_tab_type,
                       p_arcactions_tab         GMA_PURGE_DDL.g_tableaction_tab_type,
                       p_tablecount            INTEGER,
                       p_totarchiverows IN OUT NOCOPY INTEGER,
                       p_totdeleterows  IN OUT NOCOPY INTEGER) IS
  -- distill results into log format

    l_result        INTEGER;
    l_archiverows   INTEGER;     -- number of rows archived from this table
    l_deleterows    INTEGER;     -- number of rows deleted from this table
    l_sqlstatement  sy_purg_def.sqlstatement%TYPE;
    l_cursor        INTEGER;
    l_tableno       INTEGER;

  BEGIN

    -- init some values
    l_archiverows := 0;
    l_deleterows := 0;
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          '');
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          '  ' || rpad('Table Name',32) || ' ' ||
                          lpad('Total Rows',10) ||' ');
         --               lpad('Archived',10) || ' ' || moved to next
         --                 lpad('Deleted',10)); --commented
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          '');

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    FOR l_tableno IN 0 .. p_tablecount LOOP


     -- Created a FUNCTION for GSCC standard fix bug 3871659
     -- Standard: File.Sql.6 - Do NOT include any references to hardcoded schema

      -- l_sqlstatement := 'SELECT COUNT(*) FROM '
      l_sqlstatement := 'SELECT COUNT(*) FROM ' ||Get_GmaSchemaName||'.'||
                            GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                 p_arctables_tab(l_tableno));

      DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
      DBMS_SQL.DEFINE_COLUMN(l_cursor,1,l_archiverows);
      l_result := DBMS_SQL.EXECUTE_AND_FETCH(l_cursor);
      DBMS_SQL.COLUMN_VALUE(l_cursor,1,l_archiverows);

        -- did we delete any rows?
      IF p_arcactions_tab(l_tableno) = 'D' THEN
        l_deleterows := l_archiverows;
      ELSE
        l_deleterows := 0;
      END IF;

  if PA_OPTION<>3 then

      INSERT INTO sy_purg_log
      ( purge_id
      , table_name
      , rows_archived
      , rows_deleted
      , creation_date
      , created_by
      , last_update_login
      , last_update_date
      , last_updated_by)
      VALUES
      ( p_purge_id
      , p_arctables_tab(l_tableno)
      , l_archiverows
      , l_deleterows
      , sysdate
      , p_user
      ,1
      ,sysdate
      ,1);
  end if;

      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            '  ' || rpad(p_arctables_tab(l_tableno),32) || ' ' ||
                            lpad(to_char(l_archiverows),10) || ' ');
                         --   lpad(to_char(l_deleterows),10)); -- commented

      p_totarchiverows := p_totarchiverows + l_archiverows;
      p_totdeleterows  := p_totdeleterows  + l_deleterows;

    END LOOP;

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.logresults.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END logresults;

  /***********************************************************/

  PROCEDURE archive(p_purge_id               sy_purg_mst.purge_id%TYPE,
                    p_purge_type             sy_purg_def.purge_type%TYPE,
                    p_owner                  user_users.username%TYPE,
                    p_appl_short_name        fnd_application.application_short_name%TYPE,
                    p_user                   NUMBER,
                    p_sqlstatement           sy_purg_def.sqlstatement%TYPE,
                    p_arcrowbasename         user_tables.table_name%TYPE,
                    p_arctablespace          user_tablespaces.tablespace_name%TYPE,
                    p_arctables_tab   IN OUT NOCOPY GMA_PURGE_DDL.g_tablename_tab_type,
                    p_arcactions_tab  IN OUT NOCOPY GMA_PURGE_DDL.g_tableaction_tab_type,
                    p_totarchiverows  IN OUT NOCOPY INTEGER,
                    p_totdeleterows   IN OUT NOCOPY INTEGER,
                    p_sizing                 BOOLEAN,
                    p_commitfrequency        INTEGER,
                    p_inittime        IN OUT NOCOPY DATE,
                    p_starttime       IN OUT NOCOPY DATE,
                    p_disable_constraints    BOOLEAN,
                    p_debug_flag             BOOLEAN) IS

    l_arcrowtable user_tables.table_name%TYPE;
    l_tablecount  INTEGER;

  BEGIN

    p_totarchiverows := 0;
    p_totdeleterows := 0;

    -- Figure out important process table names
    l_arcrowtable := GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                             p_arcrowbasename);

    -- get archive set, do actual archive
    GMA_PURGE_ENGINE.getrows(p_purge_id,
                             p_owner,
                             p_appl_short_name,
                             p_sqlstatement,
                             p_arctablespace,
                             l_arcrowtable,
                             p_debug_flag);

    -- get incremental stats
    p_inittime := SYSDATE;
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          GMA_PURGE_ENGINE.PA_OPTION_NAME||' rows determined in ' ||
      TO_CHAR(trunc((p_inittime - p_starttime) * 86400)) || ' seconds.');

    UPDATE sy_purg_mst
      SET selection_elapsed_time =
                trunc((p_inittime - p_starttime) * 86400)
      ,   last_update_date = sysdate
      ,   last_updated_by   = p_user
      WHERE purge_id = p_purge_id;

    COMMIT;

    GMA_PURGE_ENGINE.doarchive(p_purge_id,
                               p_purge_type,
                               p_owner,
                               p_appl_short_name,
                               p_user,
                               GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                               p_arcrowbasename),
                               p_arctables_tab,
                               p_arcactions_tab,
                               l_tablecount,
                               p_totarchiverows,
                               p_totdeleterows,
                               p_sizing,
                               p_commitfrequency,
                               p_disable_constraints,
                               p_debug_flag);

    -- get incremental stats
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
           --                     'PA selection/archive completed in ' ||
                                  GMA_PURGE_ENGINE.PA_OPTION_NAME||' selection completed in ' ||
                                  to_char(trunc((SYSDATE - p_inittime) * 86400))
                                  || ' seconds.');

    -- create log entries here
    GMA_PURGE_ENGINE.logresults(p_purge_id,
                                p_user,
                                p_arctables_tab,
                                p_arcactions_tab,
                                l_tablecount,
                                p_totarchiverows,
                                p_totdeleterows);

    -- drop archive row table, archive journal tables
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          '');
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          '  ' || rpad('TOTAL',32) || ' ' ||
                         lpad(to_char(p_totarchiverows),10) || ' ');
                   --      lpad(to_char(p_totdeleterows),10)); commented
    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          '');
    GMA_PURGE_DDL.createarcviews(p_purge_id,p_purge_type,p_owner,p_appl_short_name,p_debug_flag);

    GMA_PURGE_DDL.droparctable(p_purge_id,p_owner,p_appl_short_name,'ARCHIVEROWS');

   -- Drops the temporary table for GME only.   KH
    IF upper(p_purge_type) in('PROD','APRD','AJNL','JRNL','OPSO','AOPS','PORD','APOR') Then
         GMA_PURGE_ENGINE.Tempdrop(p_purge_id,p_purge_type,p_debug_flag);
    END IF;


  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.archive.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END archive;

  /***********************************************************/

  PROCEDURE purge(p_purge_id        sy_purg_mst.purge_id%TYPE,
                  p_purge_type      sy_purg_def.purge_type%TYPE,
                  p_owner           user_users.username%TYPE,
                  p_appl_short_name fnd_application.application_short_name%TYPE,
                  p_debug_flag      BOOLEAN) IS
    -- drop archive tables, reset views

    CURSOR l_viewtables_cur(c_purge_type sy_purg_mst.purge_type%TYPE) IS
      SELECT table_name
      FROM   sy_purg_def_act
      WHERE  purge_type = c_purge_type;

  BEGIN

    FOR l_viewtable_row IN l_viewtables_cur(p_purge_type) LOOP
      GMA_PURGE_DDL.droparctable(p_purge_id,p_owner,p_appl_short_name,l_viewtable_row.table_name);
    END LOOP;

    GMA_PURGE_DDL.createarcviews(p_purge_id,p_purge_type,p_owner,p_appl_short_name,p_debug_flag);

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.purge.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END purge;

  /***********************************************************/

  PROCEDURE report_exit (p_purge_id  sy_purg_mst.purge_id%TYPE,
                         p_status    INTEGER) IS
  BEGIN

    GMA_PURGE_UTILITIES.printlong(p_purge_id,
                          'Ending status is ' || to_char(p_status) || '.');
    GMA_PURGE_UTILITIES.printline(p_purge_id);

  EXCEPTION

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE. report_exit.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END report_exit;

FUNCTION  GLPOSTED_OPSO(P_Purge_id in sy_purg_mst.purge_id%TYPE,
                        p_purge_type     sy_purg_def.purge_type%TYPE,
                        p_owner          user_users.username%TYPE,
                        p_debug_flag     BOOLEAN)
          RETURN LONG
is
cursor purge_crit is
select crit_tag,crit_value
from sy_purg_mst_crit
where purge_id=P_Purge_id;

cursor c1(P_MINORDER op_ordr_hdr.order_no%type,
          P_MAXORDER op_ordr_hdr.order_no%type,
          P_MINORGN  op_ordr_hdr.orgn_code%type,
          P_MAXORGN  op_ordr_hdr.orgn_code%type,
          P_MINMDATE op_ordr_hdr.last_update_date%type,
	  P_MAXMDATE op_ordr_hdr.last_update_date%type,
	  P_MINCDATE op_ordr_hdr.creation_date%type,
	  P_MAXCDATE op_ordr_hdr.creation_date%type,
	  P_OSTATUS  op_ordr_hdr.order_status%type)
is
select distinct order_id
FROM   op_ordr_hdr       OH1
WHERE  order_no      >= P_MINORDER
AND    order_no      <= P_MAXORDER
AND    orgn_code     >= P_MINORGN
AND    orgn_code     <= P_MAXORGN
AND    last_update_date >= P_MINMDATE
AND    last_update_date <= P_MAXMDATE
AND    creation_date    >= P_MINCDATE
AND    creation_date    <= P_MAXCDATE
AND    order_status  = P_OSTATUS
AND    (order_status = -1 or order_status = 25) ;

-- COMPLETED_IND Completed indicator. 0=Pending transaction, 1=Completed transaction.
-- GL_POSTED_IND GL posted indicator. 0=Not posted to GL, 1=Posted to GL.
-- DELETE_MARK    Standard: 0=Active record (default); 1=Marked for (logical) deletion.
-- TRANS_ID (PK) Unique key for the transaction.

--(in 1,2) and    TRANS_ID not in (SELECT TRANS_ID from ic_tran_pnd where doc_id=pdoc_id and doc_type='OPSO' and delete_mark=1)

cursor c2 (pdoc_id ic_tran_pnd.doc_id%type)
IS
select count(*) COUNT_GL_POSTED_IND, 0 COUNT_COMPLETED_IND
from   ic_tran_pnd
where  doc_id =pdoc_id
and    doc_type = 'OPSO'
and    delete_mark=0
and    gl_posted_ind <>1
UNION ALL
select 0,count(*)
from   ic_tran_pnd
where  doc_id = pdoc_id
and    doc_type = 'OPSO'
and    delete_mark=0
and    completed_ind =0;

MINORDER op_ordr_hdr.order_no%type;
MAXORDER op_ordr_hdr.order_no%type;
MINORGN  op_ordr_hdr.orgn_code%type;
MAXORGN  op_ordr_hdr.orgn_code%type;
MINMDATE op_ordr_hdr.last_update_date%type;
MAXMDATE op_ordr_hdr.last_update_date%type;
MINCDATE op_ordr_hdr.creation_date%type;
MAXCDATE op_ordr_hdr.creation_date%type;
OSTATUS  op_ordr_hdr.order_status%type;

no_of_unposted_rec number(10):=0;
posted     varchar2(10):='F';

TYPE id_tab_type IS TABLE OF number INDEX BY BINARY_INTEGER;
order_id  id_tab_type;
all_order_id  varchar2(30000):=-9999;

l_temptable Varchar2(2000);
l_TempFlag  varchar2(1):='T';

Begin

  FOR pcritRec in purge_crit LOOP
      if (pcritRec.crit_tag='MINORDER') then
           MINORDER:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXORDER') then
           MAXORDER:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINORGN') then
           MINORGN:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXORGN') then
           MAXORGN:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINMDATE') then
           MINMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXMDATE') then
           MAXMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MINCDATE') then
           MINCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXCDATE') then
           MAXCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='OSTATUS') then
           OSTATUS:=pcritRec.crit_value;
      end if;
  END LOOP;

  FOR c1Rec in c1(MINORDER,MAXORDER,MINORGN,MAXORGN,MINMDATE,MAXMDATE,MINCDATE,MAXCDATE,OSTATUS)
  LOOP
       for c2Rec in c2(c1Rec.order_id) loop

         if c2Rec.COUNT_GL_POSTED_IND>0 then
              no_of_unposted_rec:=c2Rec.COUNT_GL_POSTED_IND;
         end if;

         if c2Rec.COUNT_COMPLETED_IND>0 then
              no_of_unposted_rec:=c2Rec.COUNT_COMPLETED_IND;
         end if;

       end loop;

  IF (no_of_unposted_rec > 0) THEN
      order_id(c1%rowcount):=c1Rec.order_id;
      --all_order_id:=all_order_id||','||order_id(c1%rowcount);
  ELSE
       posted:='T,';

     if l_TempFlag='T' then
          -- proceede with Temporary table stuff,Create the Temp table
          l_temptable:=GMA_PURGE_ENGINE.Tempcreate(P_purge_id,
                                                   p_purge_type,
                                                   p_owner,
                                                   p_debug_flag);
          l_TempFlag:='F';
      end if;


                       --Now start inserting all_ids to Temp table
       GMA_PURGE_ENGINE.Tempinsert(P_purge_id,
                                   p_purge_type,
                                   c1Rec.order_id,
                                   p_debug_flag);

  END IF;
    no_of_unposted_rec := 0;
-- Bug #3872548 (JKB) Added =0 line above.
  END LOOP;

  -- all_order_id:=posted||all_order_id;
   all_order_id:=posted||l_temptable;
  return all_order_id;

  EXCEPTION WHEN OTHERS THEN
               if sqlcode=-1858 then
      			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.GLPOSTED_OPSO.');
                        GMA_PURGE_UTILITIES.printlong(p_purge_id,'Wrong data given for Purge and Archive');
    			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
               end if;
 END GLPOSTED_OPSO;

FUNCTION  GLPOSTED_JRNL(P_Purge_id   in  sy_purg_mst.purge_id%TYPE,
                        p_purge_type     sy_purg_def.purge_type%TYPE,
                        p_owner          user_users.username%TYPE,
                        p_debug_flag     BOOLEAN)
                        RETURN LONG
is
cursor purge_crit is
select crit_tag,crit_value
from sy_purg_mst_crit
where purge_id=P_Purge_id;

cursor c1(P_MINJRNL ic_jrnl_mst.journal_no%type,
	   P_MAXJRNL ic_jrnl_mst.journal_no%type,
	   P_MINORGN  ic_jrnl_mst.orgn_code%type,
	   P_MAXORGN  ic_jrnl_mst.orgn_code%type,
	   P_MINMDATE ic_jrnl_mst.last_update_date%type,
	   P_MAXMDATE ic_jrnl_mst.last_update_date%type,
	   P_MINCDATE ic_jrnl_mst.creation_date%type,
	   P_MAXCDATE ic_jrnl_mst.creation_date%type)

is
select distinct IA1.doc_id
FROM   ic_adjs_jnl       IA1,
       ic_jrnl_mst       IJ1
  WHERE  IA1.journal_id     = IJ1.journal_id
  AND    IJ1.posted_ind     = 1
  AND    IA1.completed_ind  = 1
  AND    IJ1.journal_no   >= P_MINJRNL
  AND    IJ1.journal_no   <= P_MAXJRNL
  AND    IJ1.orgn_code    >= P_MINORGN
  AND    IJ1.orgn_code    <= P_MAXORGN
  AND    IJ1.last_update_date >= P_MINMDATE
  AND    IJ1.last_update_date <= P_MAXMDATE
  AND    IJ1.creation_date    >= P_MINCDATE
  AND    IJ1.creation_date    <= P_MAXCDATE;

-- Status and grade Journal type GMI transactions are not posted to the subledger and gl_posted_ind in
-- ic_tran_cmp will never be set to 1. Ignoring the gl_posted_ind validation for these types GRDI GRDR STSI STSR

cursor c2 (pdoc_id ic_tran_cmp.doc_id%type) is
select count(*)
from   ic_tran_cmp
where  doc_id = pdoc_id
and    doc_type in ('CREI','CRER','ADJI','ADJR','TRNI','TRNR')
--excludes ('GRDI','GRDR','STSI','STSR') types per bug 2441842
-- Bug #2602036 (JKB) Removed 'upper' and 'not in' above.
and    gl_posted_ind <> 1;

MINJRNL ic_jrnl_mst.journal_no%type;
MAXJRNL ic_jrnl_mst.journal_no%type;
MINORGN  ic_jrnl_mst.orgn_code%type;
MAXORGN  ic_jrnl_mst.orgn_code%type;
MINMDATE ic_jrnl_mst.last_update_date%type;
MAXMDATE ic_jrnl_mst.last_update_date%type;
MINCDATE ic_jrnl_mst.creation_date%type;
MAXCDATE ic_jrnl_mst.creation_date%type;

no_of_unposted_rec number(10);
posted     varchar2(10):='F';

TYPE id_tab_type IS TABLE OF number INDEX BY BINARY_INTEGER;
doc_id  id_tab_type;
all_doc_id  varchar2(30000):=-9999;

l_temptable Varchar2(2000);
l_TempFlag  varchar2(1):='T';

Begin

  FOR pcritRec in purge_crit LOOP
      if (pcritRec.crit_tag='MINJRNL') then
           MINJRNL:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXJRNL') then
           MAXJRNL:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINORGN') then
           MINORGN:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXORGN') then
           MAXORGN:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINMDATE') then
           MINMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXMDATE') then
           MAXMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MINCDATE') then
           MINCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXCDATE') then
           MAXCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      end if;
  END LOOP;


  FOR c1Rec in c1(MINJRNL,MAXJRNL,MINORGN,MAXORGN,MINMDATE,MAXMDATE,MINCDATE,MAXCDATE)
  LOOP
       OPEN  c2 (c1Rec.doc_id);
       FETCH c2 into no_of_unposted_rec;
       CLOSE c2;

  IF (no_of_unposted_rec > 0) THEN
        doc_id(c1%rowcount):=c1Rec.doc_id;
--      all_doc_id:=all_doc_id||','||doc_id(c1%rowcount);
  ELSE
       posted:='T,';

      if l_TempFlag='T' then
          -- proceede with Temporary table stuff,Create the Temp table
          l_temptable:=GMA_PURGE_ENGINE.Tempcreate(P_purge_id,
                                                   p_purge_type,
                                                   p_owner,
                                                   p_debug_flag);
          l_TempFlag:='F';
      end if;


                       --Now start inserting all_ids to Temp table
       GMA_PURGE_ENGINE.Tempinsert(P_purge_id,
                                   p_purge_type,
                                   c1Rec.doc_id,
                                   p_debug_flag);
   END IF;
  END LOOP;

 -- all_doc_id:=posted||all_doc_id;
  all_doc_id:=posted||l_temptable;

  return all_doc_id;

  EXCEPTION WHEN OTHERS THEN
               if sqlcode=-1858 then
      			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.GLPOSTED_JRNL.');
                        GMA_PURGE_UTILITIES.printlong(p_purge_id,'Wrong data given for Purge and Archive');
    			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
               end if;
 END GLPOSTED_JRNL;

FUNCTION  GLPOSTED_PROD
            (P_Purge_id       sy_purg_mst.purge_id%TYPE,
             p_purge_type     sy_purg_def.purge_type%TYPE,
             p_owner          user_users.username%TYPE,
             p_debug_flag     BOOLEAN)
             RETURN LONG
IS

--Purge all rows for BATCH_STATUS -1(cancelled) or -3(Converted FPO) because some rows never get posted in db.
--Check GL_POSTED_IND only for BATCH_STATUS 4(Closed) and purge.
--Ignore GL_POSTED_IND for UPDATE_INVENTORY_IND flag is set to off 'Y' and purge.

cursor purge_crit is
select crit_tag,crit_value
from sy_purg_mst_crit
where purge_id=P_Purge_id;

cursor c1(P_MINBATCH gme_batch_header.batch_no%type,
	  P_MAXBATCH gme_batch_header.batch_no%type,
	  P_MINPLANT gme_batch_header.plant_code%type,
	  P_MAXPLANT gme_batch_header.plant_code%type,
	  P_MINMDATE gme_batch_header.last_update_date%type,
	  P_MAXMDATE gme_batch_header.last_update_date%type,
	  P_MINCDATE gme_batch_header.creation_date%type,
	  P_MAXCDATE gme_batch_header.creation_date%type,
	  P_PSTATUS  gme_batch_header.batch_status%type)
is
select distinct BH2.batch_id
  FROM gme_batch_header       BH2
  WHERE  BH2.batch_no     >= P_MINBATCH
  AND    BH2.batch_no     <= P_MAXBATCH
  AND    BH2.plant_code   >= P_MINPLANT
  AND    BH2.plant_code   <= P_MAXPLANT
  AND    BH2.last_update_date >= P_MINMDATE
  AND    BH2.last_update_date <= P_MAXMDATE
  AND    BH2.creation_date    >= P_MINCDATE
  AND    BH2.creation_date    <= P_MAXCDATE
  AND    BH2.batch_status    = P_PSTATUS
  AND    (BH2.batch_status = -1 or BH2.batch_status = -3 or BH2.batch_status = 4);

cursor cur_regular_or_phantom(P_batch_id GME_BATCH_HEADER.batch_id%type) is
    SELECT batch_id,parentline_id
    FROM gme_batch_header
    WHERE batch_id=P_batch_id;

cursor cur_phantoms(p_batch_id GME_BATCH_HEADER.batch_id%type) is
    select batch_id,batch_status,gl_posted_ind,update_inventory_ind
	FROM GME_BATCH_HEADER
	WHERE batch_id IN (SELECT DISTINCT batch_id
	  		   	   FROM gme_material_details
				   START WITH batch_id=P_batch_id
				   CONNECT BY batch_id = PRIOR phantom_id);
--    AND GL_POSTED_IND<>1
--    AND BATCH_STATUS not in( -1,-3);

MINBATCH gme_batch_header.batch_no%type;
MAXBATCH gme_batch_header.batch_no%type;
MINPLANT gme_batch_header.plant_code%type;
MAXPLANT gme_batch_header.plant_code%type;
MINMDATE gme_batch_header.last_update_date%type;
MAXMDATE gme_batch_header.last_update_date%type;
MINCDATE gme_batch_header.creation_date%type;
MAXCDATE gme_batch_header.creation_date%type;
PSTATUS  gme_batch_header.batch_status%type;

tmp_cur_rphantom  cur_regular_or_phantom%rowtype;

no_of_unposted_rec number(10);
posted     varchar2(10):='F,';

TYPE id_tab_type IS TABLE OF number INDEX BY BINARY_INTEGER;
phantom_batch_id  id_tab_type;
all_phantom_batch_id  id_tab_type;
all_batch_id  id_tab_type;

all_phantoms  long:=-9999;

phantom_cnt number:=0;
phantom_unposted_flag    BOOLEAN:=FALSE;
icnt number:=0;

l_temptable varchar2(2000);

Begin

  FOR pcritRec in purge_crit LOOP
      if (pcritRec.crit_tag='MINBATCH') then
           MINBATCH:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXBATCH') then
           MAXBATCH:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINPLANT') then
           MINPLANT:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXPLANT') then
           MAXPLANT:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINMDATE') then
           MINMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXMDATE') then
           MAXMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MINCDATE') then
           MINCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXCDATE') then
           MAXCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='PSTATUS') then
           PSTATUS:=pcritRec.crit_value;
      end if;
  END LOOP;

  FOR c1Rec in c1(MINBATCH,MAXBATCH,MINPLANT,MAXPLANT,MINMDATE,MAXMDATE,MINCDATE,MAXCDATE,PSTATUS)
  LOOP
      OPEN cur_regular_or_phantom(c1Rec.batch_id);
         FETCH cur_regular_or_phantom INTO tmp_cur_rphantom;
      CLOSE cur_regular_or_phantom;

            if(tmp_cur_rphantom.parentline_id >0) then
               -- its a phantom batch so do not purge this batch id
                  no_of_unposted_rec:=1;
            else
               -- its a regular batch and check for all phantom batches ,validate gl_posted_ind
                   phantom_cnt:=0;
                   phantom_unposted_flag:=FALSE;

      	           FOR RecPhantom in cur_phantoms(c1Rec.batch_id) LOOP

                       phantom_cnt:=phantom_cnt+1;
                       phantom_batch_id(phantom_cnt):=RecPhantom.batch_id;

--Purge all rows for BATCH_STATUS -1(cancelled) or -3(Converted FPO) because some rows never get posted in db.
--Check GL_POSTED_IND only for BATCH_STATUS 4(Closed) and purge.

                          if RecPhantom.batch_status NOT IN (-1,-3) then
                             if(RecPhantom.gl_posted_ind<>1 and RecPhantom.update_inventory_ind='Y') then
                                           phantom_unposted_flag:=TRUE;
                                           no_of_unposted_rec:=1;
                                 end if;
                          end if;
                   END LOOP;

                   IF NOT phantom_unposted_flag then
                          --no_of_unposted_rec:=0;
                          posted:='T,';

                          for ci in 1..phantom_cnt loop
                               icnt:=icnt+1;
                               all_phantom_batch_id(icnt):=phantom_batch_id(ci);

                             -- Commented all_phantoms ,no more required    KH
                             -- all_phantoms:=all_phantoms||','||all_phantom_batch_id(icnt);

                          end loop;
                   END IF;

            end if;


  END LOOP;

                -- If posted flag is True then proceede with Temporary table stuff
                IF substr(posted,1,1)='T' Then
                       --Create the Temp table
                       l_temptable:=GMA_PURGE_ENGINE.Tempcreate(P_purge_id,
                                                                p_purge_type,
                                                                p_owner,
                                                                p_debug_flag);
                       --Now start inserting all_ids to Temp table
                       For i in 1..icnt
                       Loop
                            GMA_PURGE_ENGINE.Tempinsert(P_purge_id,
                                                        p_purge_type,
                                                        all_phantom_batch_id(i),
                                                        p_debug_flag);
                       End Loop;

                       GMA_PURGE_UTILITIES.printlong(p_purge_id,
                                   icnt||' rows inserted in '||l_temptable||' table.');
                END IF;

  --all_phantoms:=posted||all_phantoms; commented by KH
  -- Return only Posted flag and Temp table name to Main

  all_phantoms:=posted||l_temptable;
  return all_phantoms;

  EXCEPTION WHEN OTHERS THEN
               if sqlcode=-1858 then
      			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.glposted_prod.');
                        GMA_PURGE_UTILITIES.printlong(p_purge_id,'Wrong data given for Purge and Archive');
    			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
               else
                        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.glposted_prod.');
                        GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);

               end if;


END GLPOSTED_PROD;

FUNCTION  GLPOSTED_PORD(P_Purge_id    in sy_purg_mst.purge_id%TYPE,
                        p_purge_type     sy_purg_def.purge_type%TYPE,
                        p_owner          user_users.username%TYPE,
                        p_debug_flag     BOOLEAN)
                        RETURN LONG

is
cursor purge_crit is
select crit_tag,crit_value
from sy_purg_mst_crit
where purge_id=P_Purge_id;

cursor c1(P_MINPO po_ordr_hdr.po_no%type,
          P_MAXPO po_ordr_hdr.po_no%type,
          P_MINORGN po_ordr_hdr.orgn_code%type,
          P_MAXORGN po_ordr_hdr.orgn_code%type,
          P_MINMDATE po_ordr_hdr.last_update_date%type,
          P_MAXMDATE po_ordr_hdr.last_update_date%type,
          P_MINCDATE po_ordr_hdr.creation_date%type,
          P_MAXCDATE po_ordr_hdr.creation_date%type)
is
select distinct PH2.po_id
  FROM   po_ordr_hdr       PH2
  WHERE  PH2.po_no     >= P_MINPO
  AND    PH2.po_no     <= P_MAXPO
  AND    PH2.orgn_code   >= P_MINORGN
  AND    PH2.orgn_code   <= P_MAXORGN
  AND    PH2.last_update_date >= P_MINMDATE
  AND    PH2.last_update_date <= P_MAXMDATE
  AND    PH2.creation_date    >= P_MINCDATE
  AND    PH2.creation_date    <= P_MAXCDATE
  AND    (PH2.po_status = 20);

/*
RECV_LINE_ID (PK) This column may contain a receipt or a return line number: Recpt: fk to po_recv_dtl; Rtrn: fk to po_rtrn_dtl.
DELETE_MARK  Standard: 0=Active record (default); 1=Marked for (logical) deletion.
*/

cursor c2 (ppo_id po_recv_hst.po_id%type) is
select count(*)
from   po_recv_hst
where  po_id = ppo_id
and    RECV_LINE_ID not in (SELECT RECV_LINE_ID from po_recv_hst where po_id=ppo_id and delete_mark=1)
and    gl_posted_ind <> 1;

MINPO po_ordr_hdr.po_no%type;
MAXPO po_ordr_hdr.po_no%type;
MINORGN po_ordr_hdr.orgn_code%type;
MAXORGN po_ordr_hdr.orgn_code%type;
MINMDATE po_ordr_hdr.last_update_date%type;
MAXMDATE po_ordr_hdr.last_update_date%type;
MINCDATE po_ordr_hdr.creation_date%type;
MAXCDATE po_ordr_hdr.creation_date%type;

no_of_unposted_rec number(10):=0;
posted     varchar2(10):='F';

TYPE id_tab_type IS TABLE OF number INDEX BY BINARY_INTEGER;
po_id  id_tab_type;
all_po_id  varchar2(30000):=-9999;

l_temptable Varchar2(2000);
l_TempFlag  varchar2(1):='T';

Begin

  FOR pcritRec in purge_crit LOOP
      if (pcritRec.crit_tag='MINPO') then
           MINPO:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXPO') then
           MAXPO:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINORGN') then
           MINORGN:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MAXORGN') then
           MAXORGN:=pcritRec.crit_value;
      elsif (pcritRec.crit_tag='MINMDATE') then
           MINMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXMDATE') then
           MAXMDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MINCDATE') then
           MINCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      elsif (pcritRec.crit_tag='MAXCDATE') then
           MAXCDATE:=to_date(pcritRec.crit_value,'DD-MM-YYYY HH24:MI:SS');
      end if;
  END LOOP;

  FOR c1Rec in c1(MINPO,MAXPO,MINORGN,MAXORGN,MINMDATE,MAXMDATE,MINCDATE,MAXCDATE)
  LOOP
       OPEN  c2 (c1Rec.po_id);
       FETCH c2 into no_of_unposted_rec;
       CLOSE c2;

  IF (no_of_unposted_rec > 0) THEN
      po_id(c1%rowcount):=c1Rec.po_id;
   --   all_po_id:=all_po_id||','||po_id(c1%rowcount);
  ELSE
       posted:='T,';
      if l_TempFlag='T' then
          -- proceede with Temporary table stuff,Create the Temp table
          l_temptable:=GMA_PURGE_ENGINE.Tempcreate(P_purge_id,
                                                   p_purge_type,
                                                   p_owner,
                                                   p_debug_flag);
          l_TempFlag:='F';
      end if;


                       --Now start inserting all_ids to Temp table
       GMA_PURGE_ENGINE.Tempinsert(P_purge_id,
                                   p_purge_type,
                                   c1Rec.po_id,
                                   p_debug_flag);

  END IF;
  END LOOP;

 -- all_po_id:=posted||all_po_id;
  all_po_id:=posted||l_temptable;
  return all_po_id;

  EXCEPTION WHEN OTHERS THEN
               if sqlcode=-1858 then
      			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.GLPOSTED_PORD.');
                        GMA_PURGE_UTILITIES.printlong(p_purge_id,'Wrong data given for Purge and Archive');
    			GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
               end if;
 END GLPOSTED_PORD;

FUNCTION Tempcreate(p_purge_id    sy_purg_mst.purge_id%TYPE,
                    p_purge_type  sy_purg_def.purge_type%TYPE,
                    p_owner           user_users.username%TYPE,
                    p_debug_flag      BOOLEAN) RETURN CHAR
IS

  -- create master rows table for archive

    l_result INTEGER;
    l_rows   INTEGER;
    l_cursor INTEGER;
    l_badstatement EXCEPTION;
    l_sqlstatement sy_purg_def.sqlstatement%TYPE;

    l_temptable Varchar2(2000);

-- start of khaja code

get_all_ids long;

BEGIN

    -- define temporary table name of ids
--    l_temptable:=p_purge_type||'_'||P_purge_id;
    l_temptable:=GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                 'TEMP');

    l_cursor := DBMS_SQL.OPEN_CURSOR;

    l_sqlstatement := 'CREATE TABLE ' || p_owner || '.' ||
                          l_temptable|| ' (all_ids varchar2(100)) nologging';

                    --      l_temptable|| ' (all_ids number(20))';

    IF (p_debug_flag = TRUE) THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);
    END IF;
-- MADE BY KHAJA

      DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
      l_result := DBMS_SQL.EXECUTE(l_cursor);

      IF l_result=0 then

           l_sqlstatement := 'INSERT INTO '||p_owner ||'.'||l_temptable|| ' values(:V_bindfix)';

     -- Created a FUNCTION for GSCC standard fix bug 3871659
     -- Standard: File.Sql.6 - Do NOT include any references to hardcoded schema

            GMA_PURGE_UTILITIES.printlong(p_purge_id,
                              'Temporary table '||Get_GmaSchemaName||'.'||l_temptable||' created.');
                            --  'Temporary table '||l_temptable||' created.');

            IF (p_debug_flag = TRUE) THEN
                GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);
            END IF;

           DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
           --added by Khaja for SQL BIND VARIABLE project fix see 2935158
           dbms_sql.bind_variable(l_cursor, 'V_bindfix','-9999');
           l_result := DBMS_SQL.EXECUTE(l_cursor);

      END IF;

   /*    IF l_result <> 0 THEN
         RAISE l_badstatement;
       END IF;
   */


    DBMS_SQL.CLOSE_CURSOR(l_cursor);

    RETURN p_owner||'.'||l_temptable;

  EXCEPTION
    WHEN l_badstatement THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.tempcreate.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.tempcreate.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END tempcreate;

PROCEDURE Tempinsert(p_purge_id    sy_purg_mst.purge_id%TYPE,
                     p_purge_type  sy_purg_def.purge_type%TYPE,
                     p_all_ids      number,
                     p_debug_flag   BOOLEAN)
IS

  -- create master rows table for archive

    l_result INTEGER;
    l_rows   INTEGER;
    l_cursor INTEGER;
    l_badstatement EXCEPTION;
    l_sqlstatement sy_purg_def.sqlstatement%TYPE;

    l_temptable Varchar2(2000);

-- start of khaja code

get_all_ids long;

BEGIN

   -- l_temptable:=p_purge_type||'_'||p_purge_id;
    l_temptable:=GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                 'TEMP');

    l_cursor := DBMS_SQL.OPEN_CURSOR;

         --  l_sqlstatement := 'INSERT INTO ' || 'GMA' || '.' ||
     -- Created a FUNCTION for GSCC standard fix bug 3871659
     -- Standard: File.Sql.6 - Do NOT include any references to hardcoded schema

           l_sqlstatement := 'INSERT INTO ' ||Get_GmaSchemaName||'.' ||
                          l_temptable|| ' values(:all_ids)';

        -- do not run this stmt
       /*     IF (p_debug_flag = TRUE) THEN
                GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);
            END IF;
        */

           DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
           dbms_sql.bind_variable(l_cursor, 'all_ids',p_all_ids);
           l_result := DBMS_SQL.EXECUTE(l_cursor);

    /*   IF l_result <> 0 THEN
         RAISE l_badstatement;
       END IF;
 */


    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  EXCEPTION
    WHEN l_badstatement THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.tempinsert.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.tempinsert.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END tempinsert;

PROCEDURE Tempdrop(p_purge_id    sy_purg_mst.purge_id%TYPE,
                   p_purge_type  sy_purg_def.purge_type%TYPE,
                   p_debug_flag   BOOLEAN)
IS

  -- create master rows table for archive

    l_result INTEGER;
    l_rows   INTEGER;
    l_cursor INTEGER;
    l_badstatement EXCEPTION;
    l_sqlstatement sy_purg_def.sqlstatement%TYPE;

    l_temptable Varchar2(2000);

-- start of khaja code

get_all_ids long;

BEGIN

 --   l_temptable:=P_purge_type||'_'||p_purge_id;
    l_temptable:=GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                 'TEMP');

    l_cursor := DBMS_SQL.OPEN_CURSOR;

          -- l_sqlstatement := 'DROP TABLE ' || 'GMA' || '.' ||l_temptable;
     -- Created a FUNCTION for GSCC standard fix bug 3871659
     -- Standard: File.Sql.6 - Do NOT include any references to hardcoded schema

           l_sqlstatement := 'DROP TABLE ' ||Get_GmaSchemaName||'.' ||l_temptable;

            IF (p_debug_flag = TRUE) THEN
                GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);
            END IF;

           DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
           l_result := DBMS_SQL.EXECUTE(l_cursor);

       IF l_result <> 0 THEN
         RAISE l_badstatement;
       END IF;

     -- Created a FUNCTION for GSCC standard fix bug 3871659
     -- Standard: File.Sql.6 - Do NOT include any references to hardcoded schema

      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Temporary table '||Get_GmaSchemaName||'.'||l_temptable||' dropped.');
                         --   'Temporary table '||l_temptable||' dropped.');

    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  EXCEPTION
    WHEN l_badstatement THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.tempdrop.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.tempdrop.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

  END Tempdrop;

PROCEDURE ResetTestPurge(p_purge_id    sy_purg_mst.purge_id%TYPE,
                         p_purge_type  sy_purg_def.purge_type%TYPE,
                         p_debug_flag   varchar2)
IS
--Prepare the SQL to get all table_names which needs to be renamed based on the
--archive_action equal to 'K'
Cursor Cur_dropTbl(ppurge_id sy_purg_mst.purge_id%TYPE,
                  c_schema_name VARCHAR2) is
     SELECT owner,table_name
     FROM all_tables
     WHERE owner = c_schema_name
     AND
     table_name IN(
         SELECT 'T' ||LPAD(TO_CHAR(A.purge_id),5,'0')||'_'||B.table_name
         FROM SY_PURG_MST A,  Sy_purg_def_act B
         WHERE A.purge_type=B.purge_type AND A.purge_id=ppurge_id
         union
         SELECT 'T'||LPAD(TO_CHAR(A.purge_id),5,'0')||'_'||'ARCHIVEROWS'
         FROM SY_PURG_MST A
         WHERE A.purge_id=ppurge_id
         union
         SELECT 'T'||LPAD(TO_CHAR(A.purge_id),5,'0')||'_'||'TEMP'
         FROM SY_PURG_MST A
         WHERE A.purge_id=ppurge_id
         );


  -- create master rows table for archive

    l_result INTEGER;
    l_rows   INTEGER:=0;
    l_cursor INTEGER;
    l_badstatement EXCEPTION;
    l_sqlstatement sy_purg_def.sqlstatement%TYPE;

    l_temptable Varchar2(2000);

-- start of khaja code

get_all_ids long;
l_schema_name VARCHAR2(30); /* Bug 4344986 */

BEGIN

    l_schema_name := Get_GmaSchemaName; /* Bug 4344986 */

 --   l_temptable:=P_purge_type||'_'||p_purge_id;
    l_temptable:=GMA_PURGE_UTILITIES.makearcname(p_purge_id,
                                                 'TEMP');
            GMA_PURGE_UTILITIES.printlong(p_purge_id,
                                          'Reset Process initiated.');

    l_cursor := DBMS_SQL.OPEN_CURSOR;
    FOR rec in Cur_DropTbl(P_purge_id, l_schema_name)
          Loop
              if l_rows=0 then
                 Update sy_purg_mst set status=0 where purge_id=P_purge_id;
                 commit;
                 l_rows:=1;
          end if;

       --Prepare the RENAME table stmt for GMA user
          l_sqlstatement:='DROP TABLE '||rec.owner||'.'||rec.table_name;


            IF (p_debug_flag ='T') THEN
                GMA_PURGE_UTILITIES.printlong(p_purge_id,l_sqlstatement);
            END IF;

          --parse the RENAME stmt if table not found.
           DBMS_SQL.PARSE(l_cursor,l_sqlstatement,DBMS_SQL.NATIVE);
           l_result := DBMS_SQL.EXECUTE(l_cursor);


             IF l_result <> 0 THEN
                 RAISE l_badstatement;
             END IF;

            GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            rec.owner||'.'||rec.table_name||' Table Dropped.');
         End Loop;

            GMA_PURGE_UTILITIES.printlong(p_purge_id,
                                          'Reset Process completed successfully.');

     -- Close the cursor
    DBMS_SQL.CLOSE_CURSOR(l_cursor);

  EXCEPTION
    WHEN l_badstatement THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.ResetTestPurge.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;

    WHEN OTHERS THEN
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Problem raised in GMA_PURGE_ENGINE.ResetTestPurge.');
      GMA_PURGE_UTILITIES.printlong(p_purge_id,
                            'Unhandled EXCEPTION - ' || sqlerrm);
      RAISE;
  END ResetTestPurge;

-- Created a FUNCTION for GSCC standard fix bug 3871659
-- Standard: File.Sql.6 - Do NOT include any references to hardcoded schema

FUNCTION Get_GmaSchemaName
RETURN VARCHAR2
IS
   l_return BOOLEAN;
   l_status VARCHAR2(1);
   l_industry VARCHAR2(1);
   l_schema_name VARCHAR2(30);
BEGIN
   l_return := FND_INSTALLATION.GET_APP_INFO
      ( 'GMA'
      , l_status
      , l_industry
      , l_schema_name
      );

   IF NOT l_return THEN
      RAISE fnd_api.g_exc_unexpected_error;
   END IF;

   RETURN l_schema_name;

END Get_GmaSchemaName;

END GMA_PURGE_ENGINE;

/
