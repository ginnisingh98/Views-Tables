--------------------------------------------------------
--  DDL for Package Body AD_MV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AD_MV" as
/* $Header: admvb.pls 120.4 2006/06/01 19:18:16 vlim noship $*/

   gs_package_name_c               CONSTANT VARCHAR2(30) := 'ad_mv';

   gn_timeout_c                    CONSTANT INTEGER := dbms_lock.maxwait;
   gs_lockhandle_name_c            CONSTANT VARCHAR2(12) := 'AD_MV_CREATE';

   ga_stmt                         dbms_sql.varchar2s;

   check_tspace_exist              varchar2(100);

   mv_exists                       EXCEPTION;
   PRAGMA EXCEPTION_INIT(mv_exists, -12006);

   -- Bug 3562360: sallamse
   -- Removed the set_sess_parm_if_required procedure
   -- global constants for package body
   -- everything between 8.1.7 and 9.0.0
   gn_limit_min_c                 CONSTANT PLS_INTEGER := 817;
   gn_limit_max_c                 CONSTANT PLS_INTEGER := 900;

   ls_version                     VARCHAR2(20);
   ls_compatibility               VARCHAR2(20);

   --
   -- This procedure should not be called directly from an
   -- external program when the statement is really long
   -- and dbms_sql.parse() is expected to be used, i.e.
   -- ab_long_stmt_i=TRUE. In these cases, the call should
   -- be made to do_mv_ddl().
   --
   PROCEDURE create_mv (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_long_stmt_i                BOOLEAN DEFAULT FALSE
   )
   IS
     ls_name_c                     CONSTANT VARCHAR2(30) := gs_package_name_c || '.' || 'create_mv';
     ls_dummy                      VARCHAR2(1);
     ln_resource_status            INTEGER;
     ls_lockhandle                 VARCHAR2(128);
     l_db_version                  VARCHAR2(30);
     l_statement                   VARCHAR2(500);
     ln_cursor                     INTEGER;
     ln_dummy                      INTEGER;
   BEGIN
     dbms_lock.allocate_unique (
       lockname    => gs_lockhandle_name_c
     , lockhandle  => ls_lockhandle
     );

     -- requesting lock
     ln_resource_status := dbms_lock.request (
                             lockhandle        => ls_lockhandle
                           , lockmode          => dbms_lock.x_mode
                           , timeout           => gn_timeout_c
                           , release_on_commit => FALSE
     );
     -- 0 - success
     -- 1 - timeout
     -- 2 - deadlock
     -- 3 - parameter error
     -- 4 - already own lock specified by 'id' or 'lockhandle'
     -- 5 - illegal lockhandle
     -- Everything except 'success' is bad
     IF (ln_resource_status <> 0)
     THEN
       RAISE_APPLICATION_ERROR(-20001, ls_name_c || ': could not get the lock: ' || ln_resource_status);
     END IF;

     -- Is the mview 'partially' created? If so, it has to be dropped
     -- IF (as_mview_name_i IS NOT NULL)
     -- THEN
     BEGIN
       SELECT 'x'
         INTO ls_dummy
         FROM user_tables
            , user_mviews
        WHERE table_name = mview_name
          AND mview_name = create_mv.as_mview_name_i
          AND NOT EXISTS (
                SELECT null
                  FROM user_objects
                 WHERE object_type = 'MATERIALIZED VIEW'
                   AND object_name = table_name
                   AND object_name = create_mv.as_mview_name_i
              )
       ;
       EXECUTE IMMEDIATE 'DROP MATERIALIZED VIEW ' || as_mview_name_i;
     EXCEPTION
       WHEN NO_DATA_FOUND
       THEN null;
     END;
     -- END IF;

     BEGIN

       BEGIN
         l_statement := 'select version from v$instance';
         execute immediate l_statement into l_db_version;
       EXCEPTION
         when others then
  	     raise_application_error(-20000,
	      'Unable to get the DB Version.');
       END;

       -- Bug 3562360: sallamse
       -- Moved  setting "_mv_refresh_selections" session parameter
       -- to init section of the package body

       IF (ab_long_stmt_i)
       THEN
         ln_cursor := dbms_sql.open_cursor;
         dbms_sql.parse(c => ln_cursor, statement => ga_stmt
                       , lb => 1, ub => ga_stmt.COUNT
                       , lfflg => FALSE, language_flag => dbms_sql.native
         );
         ln_dummy := dbms_sql.execute(ln_cursor);
         dbms_sql.close_cursor(ln_cursor);
         ga_stmt.DELETE;
       ELSE
         EXECUTE IMMEDIATE as_stmt_i;
       END IF;
     EXCEPTION
       WHEN mv_exists
       THEN null;
       WHEN OTHERS
       THEN ln_resource_status := dbms_lock.release(lockhandle => ls_lockhandle);
            ga_stmt.DELETE;
            RAISE;
     END;

     ln_resource_status := dbms_lock.release(lockhandle => ls_lockhandle);
     IF (ln_resource_status <> 0)
     THEN
       RAISE_APPLICATION_ERROR(-20002, ls_name_c || ': could not release the lock: ' || ln_resource_status);
     END IF;
   END create_mv;

   -- Bug 3562360: sallamse
   -- Created wraper procedure as Java JDBC driver does not support
   -- passing boolean parameters in PL/SQL Stored Procedures.
   --
   -- This procedure should not be called directly from an
   -- external program when the statement is really long
   -- and dbms_sql.parse() is expected to be used, i.e.
   -- ab_long_stmt_i=1.  In these cases, the call should
   -- be made to do_mv_ddl2().
   --
   PROCEDURE create_mv2 (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_long_stmt_i                INTEGER DEFAULT 0
   )
   IS
   BEGIN
     IF (ab_long_stmt_i=1) THEN
       create_mv(as_mview_name_i, as_stmt_i, TRUE);
     ELSE
       create_mv(as_mview_name_i, as_stmt_i, FALSE);
     END IF;
   END create_mv2;

   --
   -- This procedure should not be called directly from an
   -- external program when the statement is really long
   -- and dbms_sql.parse() is expected to be used, i.e.
   -- ab_long_stmt_i=TRUE. In these cases, the call should
   -- be made to do_mv_ddl().
   --
   PROCEDURE mv_ddl (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_long_stmt_i                BOOLEAN DEFAULT FALSE
   )
   IS
     ls_name_c                     CONSTANT VARCHAR2(30) := gs_package_name_c || '.' || 'mv_ddl';
     ls_dummy                      VARCHAR2(1);
     ln_resource_status            INTEGER;
     ls_lockhandle                 VARCHAR2(128);
     ln_cursor                     INTEGER;
     ln_dummy                      INTEGER;
   BEGIN
     dbms_lock.allocate_unique (
       lockname    => gs_lockhandle_name_c
     , lockhandle  => ls_lockhandle
     );

     -- requesting lock
     ln_resource_status := dbms_lock.request (
                             lockhandle        => ls_lockhandle
                           , lockmode          => dbms_lock.x_mode
                           , timeout           => gn_timeout_c
                           , release_on_commit => FALSE
     );
     IF (ln_resource_status <> 0)
     THEN
       RAISE_APPLICATION_ERROR(-20001, ls_name_c || ': could not get the lock: ' || ln_resource_status);
     END IF;

     BEGIN
       IF (ab_long_stmt_i)
       THEN
         ln_cursor := dbms_sql.open_cursor;
         dbms_sql.parse(c => ln_cursor, statement => ga_stmt
                       , lb => 1, ub => ga_stmt.COUNT
                       , lfflg => FALSE, language_flag => dbms_sql.native
         );
         ln_dummy := dbms_sql.execute(ln_cursor);
         dbms_sql.close_cursor(ln_cursor);
         ga_stmt.DELETE;
       ELSE
         EXECUTE IMMEDIATE as_stmt_i;
       END IF;
     EXCEPTION
       WHEN OTHERS
       THEN
            ln_resource_status := dbms_lock.release(lockhandle => ls_lockhandle);
            ga_stmt.DELETE;
            RAISE;
     END;

     ln_resource_status := dbms_lock.release(lockhandle => ls_lockhandle);
     IF (ln_resource_status <> 0)
     THEN
       RAISE_APPLICATION_ERROR(-20002, ls_name_c || ': could not release the lock: ' || ln_resource_status);
     END IF;
   END mv_ddl;

   PROCEDURE alter_mv (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   )
   IS
   BEGIN
     mv_ddl(as_mview_name_i, as_stmt_i);
   END alter_mv;

   PROCEDURE drop_mv (
     as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   )
   IS
   BEGIN
     mv_ddl(as_mview_name_i, as_stmt_i);
   END drop_mv;

   --
   -- This procedure allows really long statements to be
   -- executed by preparing ga_stmt before dbms_sql.parse()
   -- is called in other procedures.
   --
   -- If the calling program needs to call this procedure
   -- several times to pass a single statement, make sure
   -- that ab_execute_i is set to FALSE for all calls except
   -- for the last one where it should be set to TRUE.
   --
   PROCEDURE do_mv_ddl (
     an_operation_i                PLS_INTEGER
   , as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_execute_i                  BOOLEAN DEFAULT NULL
   )
   IS
     l_chunk                       VARCHAR2(256);
     l_index                       INTEGER := 1;
     l_pointer                     INTEGER;
   BEGIN
     IF (an_operation_i NOT IN (ad_mv.mv_create, ad_mv.mv_alter, ad_mv.mv_drop))
     THEN
       RAISE_APPLICATION_ERROR(-20003, 'do_mv_ddl: unsupported operation');
     END IF;
     IF (ab_execute_i IS NOT NULL)
     THEN
       l_pointer := NVL(ga_stmt.COUNT + 1, 1);
       LOOP
         l_chunk := SUBSTR(as_stmt_i, l_index, 256);
         EXIT WHEN l_chunk IS NULL;
         ga_stmt(l_pointer) := l_chunk;
         l_pointer := l_pointer + 1;
         l_index := l_index + 256;
       END LOOP;
     END IF;
     IF (ab_execute_i IS NULL OR ab_execute_i)
     THEN
       IF (an_operation_i = ad_mv.mv_create)
       THEN
         create_mv(as_mview_name_i, as_stmt_i, ab_execute_i);
       ELSIF (an_operation_i IN (ad_mv.mv_alter, ad_mv.mv_drop))
       THEN
         mv_ddl(as_mview_name_i, as_stmt_i, ab_execute_i);
       END IF;
     END IF;
   END do_mv_ddl;

   -- Bug 3562360: sallamse
   -- Created wraper procedure as Java JDBC driver does not support
   -- passing boolean parameters in PL/SQL Stored Procedures.
   --
   -- If the calling program needs to call this procedure
   -- several times to pass a single statement, make sure
   -- that ab_execute_i is set to 0 for all calls except
   -- for the last one where it should be set to 1.
   --
   PROCEDURE do_mv_ddl2 (
     an_operation_i                PLS_INTEGER
   , as_mview_name_i               VARCHAR2
   , as_stmt_i                     VARCHAR2
   , ab_execute_i                  INTEGER DEFAULT NULL
   )
   IS
   BEGIN
     IF (ab_execute_i IS NULL)
     THEN
       do_mv_ddl(an_operation_i, as_mview_name_i, as_stmt_i);
     ELSIF (ab_execute_i=1) THEN
       do_mv_ddl(an_operation_i, as_mview_name_i, as_stmt_i, TRUE);
     ELSE
       do_mv_ddl(an_operation_i, as_mview_name_i, as_stmt_i, FALSE);
     END IF;
   END do_mv_ddl2;

BEGIN
  dbms_utility.db_version(ls_version, ls_compatibility);
  IF (TO_NUMBER(TRANSLATE(SUBSTR(ls_version, 1, 5), '@.', '@')) BETWEEN
    gn_limit_min_c AND gn_limit_max_c)
  THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET "_mv_refresh_selections"=TRUE';
  END IF;
  ad_tspace_util.get_tablespace_name('BIS','SUMMARY','Y',check_tspace_exist,g_mv_data_tablespace);
  g_mv_index_tablespace := g_mv_data_tablespace;
END ad_mv;

/
