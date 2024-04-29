--------------------------------------------------------
--  DDL for Package Body EDW_COLLECTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_COLLECTION_UTIL" AS
/* $Header: EDWSRCTB.pls 120.0 2005/06/01 15:01:47 appldev noship $  */
   version          CONSTANT CHAR (80)
            := '$Header: EDWSRCTB.pls 120.0 2005/06/01 15:01:47 appldev noship $';
   g_source_link             fnd_profile_option_values.profile_option_value%TYPE;
   g_target_link             fnd_profile_option_values.profile_option_value%TYPE;
   g_source_same_as_target   BOOLEAN;
   g_debug                   BOOLEAN;
   g_parallel                PLS_INTEGER;
   g_staging_table           user_tables.table_name%TYPE;
   g_rbs                     user_segments.segment_name%TYPE;
   g_op_tablespace           user_tablespaces.tablespace_name%TYPE;
   g_bis_schema              user_users.username%TYPE;
   tab_stglist               tablist_type;
   g_transport_data          BOOLEAN;


-- ------------------------------------------------------------------
-- Name: Setup
-- Desc: Initial function called to setup log file and push program.
--       p_object_name
-- ------------------------------------------------------------------
  FUNCTION setup (p_object_name IN VARCHAR2) RETURN BOOLEAN IS
  Begin
     if setup(p_object_name,null,null,TRUE)=false then
       return false;
     end if;
     return true;
   EXCEPTION
      WHEN OTHERS
      THEN
         edw_log.put_line (' Setup of '|| p_object_name|| ' failed. Error '||sqlerrm,FND_LOG.LEVEL_ERROR);
         RETURN (FALSE);
   END setup;

   FUNCTION setup (
      p_object_name        IN   VARCHAR2,
      p_pk_view            IN   VARCHAR2,
      p_missing_key_view   IN   VARCHAR2,
      p_transport_data     IN   BOOLEAN
   )
      RETURN BOOLEAN
   IS
      l_dir            VARCHAR2 (400);
      l_option_value   VARCHAR2 (60);
      l_status         BOOLEAN;
      l_ap_status      VARCHAR2 (30);
      l_industry       VARCHAR2 (30);
   BEGIN
      put_debug_msg ('********** Start Setup Function');

      IF (fnd_installation.get_app_info (
             'BIS',
             l_ap_status,
             l_industry,
             g_bis_schema
          )
         )
      THEN
         IF (is_instance_enabled)
         THEN
            COMMIT;
            l_status := TRUE;
            put_debug_msg ('Reading Object Settings.');

            IF edw_source_option.get_source_option (
                  p_object_name,
                  NULL,
                  'TRACE_SR',
                  l_option_value
               )
            THEN
               IF l_option_value = 'Y'
               THEN
                  null;
               END IF;
            ELSE
               l_status := FALSE;
            END IF;

            IF edw_source_option.get_source_option (
                  p_object_name,
                  NULL,
                  'DEBUG_SR',
                  l_option_value
               )
            THEN
               IF l_option_value = 'Y'
               THEN
                  g_debug := TRUE;
               ELSE
                  g_debug := FALSE;
               END IF;
            ELSE
               l_status := FALSE;
            END IF;

            IF edw_source_option.get_source_option (
                  p_object_name,
                  NULL,
                  'PARALLELISM_SR',
                  l_option_value
               )
            THEN
               g_parallel := NVL (l_option_value, 0);
            ELSE
               l_status := FALSE;
            END IF;

            IF edw_source_option.get_source_option (
                  p_object_name,
                  NULL,
                  'COMMITSIZE_SR',
                  l_option_value
               )
            THEN
               g_push_size := NVL (l_option_value, 0);
            ELSE
               l_status := FALSE;
            END IF;

            IF edw_source_option.get_source_option (
                  p_object_name,
                  NULL,
                  'ROLLBACK_SR',
                  l_option_value
               )
            THEN
               g_rbs := l_option_value;
            ELSE
               l_status := FALSE;
            END IF;

            IF edw_source_option.get_source_option (
                  p_object_name,
                  NULL,
                  'OPTABLESPACE_SR',
                  l_option_value
               )
            THEN
               g_op_tablespace := l_option_value;
            ELSE
               l_status := FALSE;
            END IF;
         ELSE
            l_status := FALSE;
         END IF;


-- End reading source options
         IF l_status
         THEN
            edw_log.put_line (
                  'Object Settings: Degree of Parallelism  : '
               || g_parallel,FND_LOG.LEVEL_STATEMENT
            );
            edw_log.put_line (
                  'Object Settings: Commit Size            : '
               || g_push_size,FND_LOG.LEVEL_STATEMENT
            );
            edw_log.put_line (
                  'Object Settings: Operational Tablespace : '
               || g_op_tablespace,FND_LOG.LEVEL_STATEMENT
            );
            edw_log.put_line (
                  'Object Settings: Rollback Segment       : '
               || g_rbs,FND_LOG.LEVEL_STATEMENT
            );

	    /*l_dir := fnd_profile.VALUE ('EDW_LOGFILE_DIR');

            IF l_dir IS NULL
            THEN
               l_dir := '/sqlcom/log';
            END IF;
	    */
		l_dir := fnd_profile.value('UTL_FILE_LOG');
		  if l_dir is  null  then
			l_dir := fnd_profile.value('EDW_LOGFILE_DIR');
			 if l_dir is  null  then
			    l_dir:='/sqlcom/log';
			end if;
		  end if;

            g_transport_data := p_transport_data;
            g_start_time := SYSDATE;

            IF g_transport_data
            THEN
               put_debug_msg ('Transportation mode is set to TRUE');
            ELSE
               put_debug_msg ('Transportation mode is set to FALSE');
            END IF;

            edw_log.put_names (
                  p_object_name
               || '.log',
                  p_object_name
               || '.out',
               l_dir
            );
            edw_log.put_line (
                  'Starting the collection program for object '
               || p_object_name,FND_LOG.LEVEL_PROCEDURE
            );
            edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);
            edw_log.put_line (
                  'System time at the start of the process is :'
               || fnd_date.date_to_displaydt (g_start_time),FND_LOG.LEVEL_PROCEDURE
            );
            edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);


-- Get DB Link Names

            BEGIN
               get_dblink_names (g_source_link, g_target_link);
            EXCEPTION
               WHEN OTHERS
               THEN
                  RETURN (FALSE);
            END;

-- Determine object type
  	edw_log.put_line('Calling get_object_type to determine if dimension or fact',FND_LOG.LEVEL_PROCEDURE);
  	if get_object_type(p_object_name) = true then
    	edw_log.put_line('The object name and type are '||p_object_name||', '||g_object_type,FND_LOG.LEVEL_PROCEDURE);
  	end if;
  	edw_log.put_line( ' ',FND_LOG.LEVEL_PROCEDURE);

-- ---------------------------------------------------------------------------
-- Cache global values
-- ---------------------------------------------------------------------------

            g_object_name := p_object_name;

            SELECT edw_mapping_seq.NEXTVAL
              INTO g_request_id
              FROM DUAL;

            g_source_same_as_target := source_same_as_target;


-- CLEAN UP Temporary Tables
-- Get List of Staging tables for EDW object

            IF g_staging_table IS NULL
            THEN
               get_stg_table_names (g_object_name, tab_stglist);
            ELSE

-- not registrated owb object
               g_object_type := edw_fact;
               tab_stglist (0).tbl_name := g_staging_table;
               tab_stglist (0).tbl_owner := get_syn_info (g_staging_table);
               g_staging_table := NULL;
            END IF;

            IF g_source_same_as_target = FALSE
            THEN
               clean_up (tab_stglist, '_SK');
               clean_up (tab_stglist, '_SL');

               -- clean up local staging tables
               IF is_object_for_local_load (UPPER (g_object_name)) = FALSE
               THEN
                  put_debug_msg ('Truncating the interface tables');
                  truncate_stg (tab_stglist);
               ELSE
                  put_debug_msg (
                     'NOT Truncating the interface tables because this object is for local load'
                  );
               END IF;
            END IF; -- source_same_as_target

            edw_collection_util.get_push_globals (
               p_staging_table_name=> p_object_name
            );

            -- call auto dangling recovery for dimensions
            -- check object type
            -- check if single instance is implemented

            IF g_object_type = edw_dim
            THEN
               put_debug_msg ('Running Auto Dangling Recovery Function');

               IF g_source_same_as_target
               THEN
                  l_status :=
                        edw_src_dang_recovery.get_dangling_keys (
                           p_object_name,
                           NULL,
                           p_pk_view,
                           p_missing_key_view
                        );
               ELSE
                  l_status :=
                        edw_src_dang_recovery.get_dangling_keys (
                           p_object_name,
                           g_target_link,
                           p_pk_view,
                           p_missing_key_view
                        );
               END IF;

               IF l_status = FALSE
               THEN
                  edw_log.put_line (' ',FND_LOG.LEVEL_ERROR);
                  edw_log.put_line ('Auto Dangling Recovery Error.',FND_LOG.LEVEL_ERROR);
                  edw_log.put_line (edw_src_dang_recovery.g_status_message,FND_LOG.LEVEL_ERROR);
               END IF;
            END IF; -- end if for checking EDW Object Type
         END IF; -- l_status = TRUE (options read completed).
      ELSE
         edw_log.put_line ('Error: Installation of BIS Product not found.',FND_LOG.LEVEL_ERROR);
         edw_log.put_line (' ',FND_LOG.LEVEL_ERROR);
         l_status := FALSE;
      END IF;

      put_debug_msg ('********** End Setup Function');
      RETURN l_status;
   EXCEPTION
      WHEN OTHERS
      THEN
         edw_log.put_line (
               ' Setup of '
            || p_object_name
            || ' tables failed. Error.',FND_LOG.LEVEL_ERROR
         );
         RETURN (FALSE);
   END setup;


/*---------------------------------------------------------------------------
   Function setup is overloaded for backward compatibility.
   If the new de-coupled architecture is used, local and remote
   staging table name should be passed to setup
-----------------------------------------------------------------------------*/
   FUNCTION setup (
      p_object_name            IN       VARCHAR2,
      p_local_staging_table    IN       VARCHAR2,
      p_remote_staging_table   IN       VARCHAR2,
      p_exception_msg          OUT NOCOPY     VARCHAR2
   )
      RETURN BOOLEAN
   IS
   Begin
     if setup(p_object_name,p_local_staging_table,p_remote_staging_table,p_exception_msg,
       null,null,TRUE)=false then
       return false;
     end if;
     return true;
  EXCEPTION
      WHEN OTHERS
      THEN
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         p_exception_msg :=    g_errbuf
                            || ':'
                            || g_retcode;
         RETURN FALSE;
   END setup;
   FUNCTION setup (
      p_object_name            IN       VARCHAR2,
      p_local_staging_table    IN       VARCHAR2,
      p_remote_staging_table   IN       VARCHAR2,
      p_exception_msg          OUT NOCOPY      VARCHAR2,
      p_pk_view                IN       VARCHAR2,
      p_missing_key_view       IN       VARCHAR2,
      p_transport_data         IN       BOOLEAN
   )
      RETURN BOOLEAN
   IS
   BEGIN
      IF p_local_staging_table <> p_remote_staging_table
      THEN
         edw_log.put_line (
            'Local Staging Table Name is Different From Remote Staging Table Name. Error.',FND_LOG.LEVEL_STATEMENT
         );
         edw_log.put_line (' ',FND_LOG.LEVEL_STATEMENT);
         RAISE g_push_remote_failure;
      END IF;

      g_staging_table := p_remote_staging_table;
      RETURN setup (
                p_object_name=> p_object_name,
                p_pk_view=> p_pk_view,
                p_missing_key_view=> p_missing_key_view,
                p_transport_data=> p_transport_data
             );
   EXCEPTION
      WHEN OTHERS
      THEN
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         p_exception_msg :=    g_errbuf
                            || ':'
                            || g_retcode;
         RETURN FALSE;
   END setup;


/*---------------------------------------------------------------------------
   Function to get the object type
-----------------------------------------------------------------------------*/
   FUNCTION get_object_type (p_object IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt          VARCHAR2 (5000);
      l_object_type   VARCHAR2 (30);
      cv              curtyp;
      l_status        BOOLEAN;
   BEGIN
      put_debug_msg (
         '**********  Running EDW_COLLECTION_UTIL.get_object_type'
      );
      put_debug_msg (   'Checking EDW object '
                     || p_object
                     || ' type.');
      l_stmt :=    'select ''DIMENSION'' from EDW_DIMENSIONS_MD_V@'
                || g_target_link
                || ' where dim_name =:d '
                || ' union '
                || ' select ''FACT'' from EDW_FACTS_MD_V@'
                || g_target_link
                || ' where fact_name=:f ';
      OPEN cv FOR l_stmt USING p_object, p_object;
      FETCH cv INTO l_object_type;
      CLOSE cv;

      IF    l_object_type = edw_dim
         OR l_object_type = edw_fact
      THEN
         g_object_type := l_object_type;
         l_status := TRUE;
      ELSE
         l_status := FALSE;
      END IF;

      put_debug_msg (   'EDW Object type is: '
                     || l_object_type);
      put_debug_msg ('**********  End EDW_COLLECTION_UTIL.get_object_type');
      RETURN l_status;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            CLOSE cv;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         g_object_type := edw_fact;
         RETURN TRUE;
      WHEN OTHERS
      THEN
         BEGIN
            CLOSE cv;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;

         RETURN FALSE;
   END get_object_type;


-- ------------------------------------------------------------------
-- Name: Wrapup
-- Desc: Initial function called to setup log file and push program
-- ------------------------------------------------------------------
   PROCEDURE wrapup (
      p_sucessful       IN   BOOLEAN
   ) is
   Begin
     wrapup (p_sucessful,0,null,null,null);
   EXCEPTION
      WHEN OTHERS THEN
         edw_log.put_line (   'Wrapup: '|| SQLERRM,FND_LOG.LEVEL_ERROR);
         RAISE;
   END wrapup;
   PROCEDURE wrapup(
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER
   ) is
   Begin
     wrapup (p_sucessful,p_rows_inserted,null,null,null);
   EXCEPTION
      WHEN OTHERS THEN
         edw_log.put_line (   'Wrapup: '|| SQLERRM,FND_LOG.LEVEL_ERROR);
         RAISE;
   END wrapup;
   /*
   Bug 2875426
   This API is only meant for EDW_UNSPSC_M_C
   This API DOES NOT populate the from and to dates. No collection program must
   call it!
   */
   PROCEDURE wrapup(
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER,
      p_exception_msg   IN   VARCHAR2
   ) is
   Begin
     wrapup (p_sucessful,p_rows_inserted,p_exception_msg,null,null);
   EXCEPTION
      WHEN OTHERS THEN
         edw_log.put_line (   'Wrapup: '|| SQLERRM,FND_LOG.LEVEL_ERROR);
         RAISE;
   END wrapup;
   PROCEDURE wrapup(
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER,
      p_period_start    IN   DATE,
      p_period_end      IN   DATE
   ) is
   Begin
     wrapup (p_sucessful,p_rows_inserted,null,p_period_start,p_period_end);
   EXCEPTION
      WHEN OTHERS THEN
         edw_log.put_line (   'Wrapup: '|| SQLERRM,FND_LOG.LEVEL_ERROR);
         RAISE;
   END wrapup;
   PROCEDURE wrapup (
      p_sucessful       IN   BOOLEAN,
      p_rows_inserted   IN   NUMBER,
      p_exception_msg   IN   VARCHAR2,
      p_period_start    IN   DATE,
      p_period_end      IN   DATE
   )
   IS
      l_rows_inserted   INTEGER := 0;
      l_sucessful       BOOLEAN := TRUE;
   BEGIN
      put_debug_msg ('**********  Starting EDW_COLLECTION_UTIL.wrapup');
      if p_sucessful then
        edw_log.put_line ('Wrapup called with SUCCESS',FND_LOG.LEVEL_STATEMENT);
      else
        edw_log.put_line ('Wrapup called with ERROR and message is '||p_exception_msg,FND_LOG.LEVEL_ERROR);
      end if;
      IF (p_sucessful)
      THEN
           /*
            Possible cases:
            1. Direct insert into remote staging tables
               (row count in local staging tables equal zero)
            2. Data transportation from local staging tables to remote
               staging tables using EDW Generic transportation model

            Running PL/SQL table based push_to_target
            */
-- update function input parameter

         BEGIN
            l_rows_inserted := push_to_target;
            edw_log.put_line (
                  'Rows Inserted into Interface Tables: '
               || p_rows_inserted,FND_LOG.LEVEL_STATEMENT
            );
            edw_log.put_line (' ',FND_LOG.LEVEL_STATEMENT);
            IF l_rows_inserted = -1
            THEN
               l_sucessful := FALSE;
            ELSIF ( l_rows_inserted = 0 ) AND
            (g_source_same_as_target = FALSE)
            AND (p_rows_inserted > 0)
            THEN
               l_rows_inserted := p_rows_inserted;
               l_sucessful := TRUE;
            ELSIF
               ( l_rows_inserted = 0 ) AND
            (g_source_same_as_target = TRUE)
            THEN
               l_rows_inserted := p_rows_inserted;
               l_sucessful := TRUE;
            END IF;

        EXCEPTION
            WHEN OTHERS
            THEN
               edw_log.put_line (' Push Data Failed. Error.',FND_LOG.LEVEL_ERROR);
               l_sucessful := FALSE;
         END;
      END IF; -- end if for p_sucessful

      IF      (g_source_same_as_target = FALSE)
          AND (is_object_for_local_load (UPPER (g_object_name)) = FALSE)
      THEN
         IF NOT g_debug
         THEN
            -- clean up local staging tables in case of decoupled architecture
            truncate_stg (tab_stglist);
         ELSE
            IF tab_stglist.COUNT > 0
            THEN
               put_debug_msg ('Supposed to truncate the interface tables');

               FOR i IN tab_stglist.FIRST .. tab_stglist.LAST
               LOOP
                  edw_log.put_line (tab_stglist (i).tbl_name,FND_LOG.LEVEL_STATEMENT);
               END LOOP;
            END IF;
         END IF; -- g_debug
      ELSE
         put_debug_msg (
            'NOT Truncating the interface tables for this object as its for local load'
         );
      END IF;

      -- clean up temporary tables in case if debug is switched off
      IF  (g_source_same_as_target = FALSE) AND (g_debug = FALSE)
      THEN
         clean_up (tab_stglist, '_SK');
         clean_up (tab_stglist, '_SL');
      END IF;

      IF (l_sucessful AND p_sucessful)
      THEN

-- ---------------------------------------------------------------------------
-- Print ending messages
-- ---------------------------------------------------------------------------
         edw_log.put_line ('System time at the end of data push is :',FND_LOG.LEVEL_PROCEDURE);
         put_timestamp;
         edw_log.put_line ('---------------------------------------------',FND_LOG.LEVEL_PROCEDURE);

-- ---------------------------------------------------------------------------
-- Get the current time from the Warehouse
-- ---------------------------------------------------------------------------
         edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);
         edw_log.put_line (
            'Getting the current push date in warehouse time from warehouse',FND_LOG.LEVEL_PROCEDURE
         );
         edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);
         edw_collection_util.set_push_end_dates;

-- ---------------------------------------------------------------------------
-- Insert a row in collection log table for this collection run
-- ---------------------------------------------------------------------------


         edw_collection_util.staging_log (
            p_exception_message=> NULL,
            p_status=> 'SUCCESS',
            p_no_of_records=> l_rows_inserted,
            p_period_start=> p_period_start,
            p_period_end=> p_period_end
         );
         COMMIT;
      ELSE

-- ---------------------------------------------------------------------------
-- Print ending messages
-- ---------------------------------------------------------------------------
         edw_log.put_line ('System time at the time of exception is :',FND_LOG.LEVEL_ERROR);
         put_timestamp;
         edw_log.put_line ('---------------------------------------------',FND_LOG.LEVEL_ERROR);

-- ---------------------------------------------------------------------------
-- Insert a row in collection log table for this collection run
-- with a status of ERROR
-- ---------------------------------------------------------------------------
         edw_log.put_line ('Exception Handling: Following error encountered',FND_LOG.LEVEL_ERROR);
         edw_log.put_line (p_exception_msg,FND_LOG.LEVEL_ERROR);
         edw_collection_util.staging_log (
            p_exception_message=> p_exception_msg,
            p_status=> 'ERROR',
            p_no_of_records=> 0,
            p_period_start=> p_period_start,
            p_period_end=> p_period_end
         );
         edw_log.put_line (
            'Inserted error message into the edw_push_detail_log',FND_LOG.LEVEL_ERROR
         );
         COMMIT;


--replacing l_sucessful1 with l_sucessful (bug 2350968)
         IF (NOT l_sucessful)
         THEN
            RAISE g_push_remote_failure;
         END IF;
      END IF;

      edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);
      edw_log.put_line ('System time at the end of the process is :',FND_LOG.LEVEL_PROCEDURE);
      put_timestamp;
      edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);
      edw_log.put_line (
            'Total elapsed time: '
         || edw_log.duration (  SYSDATE
                              - g_start_time),FND_LOG.LEVEL_PROCEDURE
      );

      IF (fnd_profile.VALUE ('EDW_TRACE') = 'Y')
      THEN
         null;
      END IF;

      put_debug_msg ('**********  End EDW_COLLECTION_UTIL.wrapup');
   EXCEPTION
      WHEN g_push_remote_failure
      THEN
         edw_log.put_line (   'error  '
                           || g_retcode
                           || ':'
                           || g_errbuf,FND_LOG.LEVEL_ERROR);
         edw_log.put_line (
            'Data migration from local to remote staging have failed',FND_LOG.LEVEL_ERROR
         );
         RAISE;
      WHEN OTHERS
      THEN
         edw_log.put_line (   'Wrapup: '
                           || SQLERRM,FND_LOG.LEVEL_ERROR);
         RAISE;
   END wrapup;

   FUNCTION get_wh_language
      RETURN VARCHAR2
   IS
      l_lang   VARCHAR2 (240);
   BEGIN
      put_debug_msg (
         '**********  Starting EDW_COLLECTION_UTIL.get_wh_language'
      );

      SELECT edw_language_code
        INTO l_lang
        FROM edw_local_system_parameters;

      put_debug_msg ('**********  End EDW_COLLECTION_UTIL.get_wh_language');
      RETURN l_lang;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'US';
   END get_wh_language;


/*
FUNCTION get_level_dp(p_lookup_code in varchar2) return VARCHAR2 IS
l_meaning VARCHAR2(100);
l_lang      VARCHAR2(240);
BEGIN

   l_lang := get_wh_language;

  SELECT
    meaning
  INTO
    l_meaning
  FROM fnd_lookup_values_vl@edw_apps_to_wh
  WHERE lookup_code= p_lookup_code
    AND lookup_type= 'EDW_LEVEL_LOOKUP';

 return l_meaning;

 EXCEPTION WHEN OTHERS THEN
   return 'NOT FOUND';
END;
*/


   FUNCTION get_lookup_value (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_meaning   VARCHAR2 (100);
      l_lang      VARCHAR2 (240);
      l_stmt      VARCHAR2 (1000);
      cv          curtyp;
   BEGIN
      put_debug_msg ('************* Running get_lookup_value function');

      IF    (g_source_link IS NULL)
         OR (g_target_link IS NULL)
      THEN
         get_dblink_names (g_source_link, g_target_link);
      END IF;

      l_lang := get_wh_language;
      put_debug_msg ('Executing:');
      l_stmt :=
               'SELECT
    meaning
  FROM fnd_lookup_values_vl@'
            || g_target_link
            || '
  WHERE upper(lookup_type)= upper(:s1)
  AND upper(lookup_code)= upper(:s2) ';
      put_debug_msg (l_stmt);
      OPEN cv FOR l_stmt USING p_lookup_type, p_lookup_code;
      FETCH cv INTO l_meaning;
      CLOSE cv;
      put_debug_msg ('************* End of get_lookup_value');
      RETURN l_meaning;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END get_lookup_value;

   FUNCTION get_wh_lookup_value (
      p_lookup_type   IN   VARCHAR2,
      p_lookup_code   IN   VARCHAR2
   )
      RETURN VARCHAR2
   IS
      l_meaning   VARCHAR2 (100);
      l_lang      VARCHAR2 (240);
      l_stmt      VARCHAR2 (1000);
      cv          curtyp;
   BEGIN
      put_debug_msg ('************* Running get_wh_lookup_value');
      l_lang := get_wh_language;
      put_debug_msg ('Executing: ');
      l_stmt :=
               'SELECT
    meaning
  FROM fnd_lookup_values_vl@'
            || g_target_link
            || '
  WHERE upper(lookup_type)= upper(:s1)
  AND upper(lookup_code)= upper(:s2) ';
      put_debug_msg (l_stmt);
      OPEN cv FOR l_stmt USING p_lookup_type, p_lookup_code;
      FETCH cv INTO l_meaning;
      CLOSE cv;
      RETURN l_meaning;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 'EDW_NOT_FOUND';
   END get_wh_lookup_value;

   PROCEDURE sendnote (
      name_of_conc_program   IN   VARCHAR2,
      TYPE                   IN   VARCHAR2,
      status                 IN   VARCHAR2,
      message                IN   VARCHAR2
   )
   IS
      l_date        VARCHAR2 (30);
      l_username    VARCHAR2 (30);
      c_item_type   VARCHAR2 (30);
      c_item_key    VARCHAR2 (50);
      c_process     VARCHAR2 (30);
   BEGIN
      put_debug_msg ('************* Running sendnote procedure');
      l_date := fnd_date.date_to_displaydt (SYSDATE);
      l_username := NVL (fnd_profile.VALUE ('EDW_WF_ROLE'), 'MFG');
      c_item_type := 'EDW_NOTE';
      c_item_key :=    NVL (name_of_conc_program, '1')
                    || NVL (TYPE, '1')
                    || NVL (status, '1')
                    || l_username;
      c_process := 'EDW_SENDPROC';
      wf_purge.total (c_item_type, c_item_key, SYSDATE);
      wf_engine.createprocess (
         itemtype=> c_item_type,
         itemkey=> c_item_key,
         process=> c_process
      );
      wf_engine.setitemattrtext (
         itemtype=> c_item_type,
         itemkey=> c_item_key,
         aname => 'DATE',
         avalue=> l_date
      );
      wf_engine.setitemattrtext (
         itemtype=> c_item_type,
         itemkey=> c_item_key,
         aname => 'USERNAME',
         avalue=> l_username
      );
      wf_engine.setitemattrtext (
         itemtype=> c_item_type,
         itemkey=> c_item_key,
         aname => 'NAME_OF_CONC_PROGRAM',
         avalue=> name_of_conc_program
      );
      wf_engine.setitemattrtext (
         itemtype=> c_item_type,
         itemkey=> c_item_key,
         aname => 'TYPE',
         avalue=> TYPE
      );
      wf_engine.setitemattrtext (
         itemtype=> c_item_type,
         itemkey=> c_item_key,
         aname => 'STATUS',
         avalue=> status
      );
      wf_engine.setitemattrtext (
         itemtype=> c_item_type,
         itemkey=> c_item_key,
         aname => 'MESSAGE',
         avalue=> message
      );
      wf_engine.startprocess (itemtype => c_item_type, itemkey => c_item_key);
      put_debug_msg ('************* End of sendnote procedure');
   END sendnote;


-- ------------------------------------------------------------------
-- Name: Get_Push_Globals
-- Desc:
-- ------------------------------------------------------------------
   PROCEDURE get_push_globals (p_staging_table_name IN VARCHAR2)
   IS
      l_stmt     VARCHAR2 (2000);
      l_cursor   INTEGER;
      l_dummy    INTEGER;
   BEGIN
      put_debug_msg (
            '********** Running Procedure : Get_push_globals for EDW Object '
         || p_staging_table_name
      );
      -- Clear all the globals
      g_instance_code := NULL;
      g_user_id := 0;
      g_login_id := 0;
      g_default_rate_type := NULL;
      g_global_currency := NULL;
      g_wh_curr_push_start_date := NULL;
      g_wh_curr_push_end_date := NULL;
      g_local_curr_push_start_date := NULL;
      g_local_curr_push_end_date := NULL;
      g_local_last_push_start_date := NULL;


-- ----------------------------------------------------------------------------
-- Get Instance Code
-- ----------------------------------------------------------------------------
      BEGIN
         SELECT instance_code
           INTO g_instance_code
           FROM edw_local_instance;
      EXCEPTION
         WHEN OTHERS
         THEN
            edw_log.put_line (' Instance code not found. Error.',FND_LOG.LEVEL_ERROR);
      END;


-- ----------------------------------------------------------------------------
-- Get the current time in local clock
-- ----------------------------------------------------------------------------
      g_local_curr_push_start_date := SYSDATE;

-- -----------------------------------------------------------------------------
-- Get the current time from the Warehouse
-- ----------------------------------------------------------------------------

      l_cursor := DBMS_SQL.open_cursor;
      /* see if the end period for the previous push exists */





      l_stmt :=    'select sysdate
      from dual@'
                || g_target_link;
      DBMS_SQL.parse (l_cursor, l_stmt, DBMS_SQL.native);
      DBMS_SQL.define_column (l_cursor, 1, g_wh_curr_push_start_date);
      l_dummy := DBMS_SQL.EXECUTE (l_cursor);

      IF DBMS_SQL.fetch_rows (l_cursor) <> 0
      THEN
         DBMS_SQL.column_value (l_cursor, 1, g_wh_curr_push_start_date);
      END IF;

      DBMS_SQL.close_cursor (l_cursor);


-- ----------------------------------------------------------------------------
-- get the start date of the last push
-- ----------------------------------------------------------------------------
-- -------------------------------------------------------------------------
-- If this is the first time that the global values are to be retrieved, then
-- there will be no entries in the log table. In that case, we should
-- get the right date from edw_staging_table as the default.
-- currently assigning 01-jan-1950 date as the default. <DEBUG: Need change>
-- ------------------------------------------------------------------------

      BEGIN

-- for bug 2135826
         g_local_last_push_start_date :=
               fnd_date.displaydt_to_date (
                  get_last_push_date (p_staging_table_name)
               );


------


         /* the following logic should be obsoleted once all product teams
            start passing the range parameters to the wrapup routine */

         IF g_local_last_push_start_date IS NULL
         THEN
            put_debug_msg (
               '    There are no entries in the log table for last push start and end date'
            );
            put_debug_msg ('    Assigning default start date as 01/01/1950');
            g_local_last_push_start_date :=
                                          TO_DATE ('01/01/1950', 'MM/DD/YYYY');
         END IF;
      END;


-- ----------------------------------------------------------------------------
-- Get the offset from profile
-- ----------------------------------------------------------------------------
   --g_offset := nvl(fnd_profile.value('EDW_COLLECTION_OFFSET') / 24, 0);
      g_offset := 0;

-- ----------------------------------------------------------------------------
-- Assign user_id and login_id to the local variables
-- ----------------------------------------------------------------------------

      g_user_id := fnd_global.user_id;
      g_login_id := fnd_global.login_id;
      put_debug_msg (
            '     Retrieved the instance code :'
         || g_instance_code
      );
      put_debug_msg ('         Start push time in wh clock IS :');
      put_debug_msg (
         fnd_date.date_to_displaydt (g_local_curr_push_start_date)
      );
      put_debug_msg ('         Last local_push_start_date IS : ');
      put_debug_msg (
         fnd_date.date_to_displaydt (g_local_last_push_start_date)
      );
      put_debug_msg (   'User ID is :'
                     || g_user_id);
      put_debug_msg (   'Login ID is :'
                     || g_login_id);
      put_debug_msg ('********** End Procedure : Get_Push_Globals');
   END get_push_globals;


-- ------------------------------------------------------------------
-- Name: Staging_Log
-- Desc: Logs each push into  EDW_PUSH_DETAIL_LOG
--  Striped by Object Name and Instance
--  A new row is added in the EDW_PUSH_LOG only when the
--  collection_request_id is not null, otherwise only an update .
-- ------------------------------------------------------------------
  PROCEDURE staging_log (
      p_no_of_records       IN   NUMBER,
      p_status              IN   VARCHAR2,
      p_exception_message   IN   VARCHAR2
   ) is
   Begin
     staging_log (p_no_of_records,p_status,p_exception_message,null,null);
   EXCEPTION
      WHEN OTHERS
      THEN
          edw_log.put_line (
                     'Error inserting into local log table '
                  || SQLERRM,FND_LOG.LEVEL_ERROR
               );
         RAISE;
   END staging_log;
   PROCEDURE staging_log (
      p_no_of_records       IN   NUMBER,
      p_status              IN   VARCHAR2,
      p_exception_message   IN   VARCHAR2,
      p_period_start        IN   DATE,
      p_period_end          IN   DATE
   )
   IS
      l_conc_id     INTEGER;
      l_elementid   NUMBER (9);
      l_dummy       INTEGER;
      cid           INTEGER;
      l_stmt        VARCHAR2 (1000);
      cv            curtyp;
   BEGIN
      put_debug_msg ('********** Run Procedure : Staging_Log');
      put_debug_msg (
         'Insert into edw_push_detail_log a row for this collection run'
      );
      put_debug_msg (   'p_period_start is '
                     || p_period_start);
      put_debug_msg (   'p_period_end is '
                     || p_period_end);
      l_stmt :=    'select relation_id from edw_relations_md_v@'
                || g_target_link
                || ' where relation_name=:s';
      put_debug_msg ('Running: ');
      put_debug_msg (l_stmt);
      OPEN cv FOR l_stmt USING g_object_name;
      FETCH cv INTO l_elementid;
      CLOSE cv;
      l_conc_id := fnd_global.conc_request_id;
      cid := DBMS_SQL.open_cursor;
      /* Insert into the Detail  */
      l_stmt :=
               'INSERT INTO EDW_Push_Detail_Log@'
            || g_target_link
            || '(
         INSTANCE_CODE,
         PUSH_STATUS,
         PUSH_START_DATE,
         PUSH_END_DATE,
         WH_PUSH_START_DATE,
         WH_PUSH_END_DATE,
         NO_OF_PUSHED_RECORDS,
         PUSH_EXCEPTION_MESSAGE,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATE_DATE,
         LAST_UPDATE_BY,
         LAST_UPDATE_LOGIN,
    PERIOD_START,
         PERIOD_END,         OBJECT_NAME, OBJECT_ID, OBJECT_TYPE,
    PUSH_CONCURRENT_ID)
   VALUES( :x_instance, :x_status, :x_start, :x_end, :x_whstart, :x_whend,
      :x_no_pushed, :x_message, :x_createdby, :x_creationdate, :x_lastupddate,
      :x_lastupdby, :x_lastupdlogin, :x_period_start, :x_period_end,
      :x_objname, :x_objid, :x_objtype, :x_concid)';
      put_debug_msg ('Running: ');
      put_debug_msg (l_stmt);
      DBMS_SQL.parse (cid, l_stmt, DBMS_SQL.native);
      DBMS_SQL.bind_variable (cid, ':x_instance', g_instance_code);
      DBMS_SQL.bind_variable (cid, ':x_status', p_status);
      DBMS_SQL.bind_variable (cid, ':x_start', g_local_curr_push_start_date);
      DBMS_SQL.bind_variable (cid, ':x_end', g_local_curr_push_end_date);
      DBMS_SQL.bind_variable (cid, ':x_whstart', g_wh_curr_push_start_date);
      DBMS_SQL.bind_variable (cid, ':x_whend', g_wh_curr_push_end_date);
      DBMS_SQL.bind_variable (cid, ':x_no_pushed', p_no_of_records);
      DBMS_SQL.bind_variable (cid, ':x_message', p_exception_message);
      DBMS_SQL.bind_variable (cid, ':x_createdby', g_user_id);
      DBMS_SQL.bind_variable (
         cid,
         ':x_creationdate',
         g_wh_curr_push_start_date
      );
      DBMS_SQL.bind_variable (
         cid,
         ':x_lastupddate',
         g_wh_curr_push_start_date
      );
      DBMS_SQL.bind_variable (cid, ':x_lastupdby', g_user_id);
      DBMS_SQL.bind_variable (cid, ':x_lastupdlogin', g_login_id);
      DBMS_SQL.bind_variable (cid, ':x_period_start', p_period_start);
      DBMS_SQL.bind_variable (cid, ':x_period_end', p_period_end);
      DBMS_SQL.bind_variable (cid, ':x_objname', g_object_name);
      DBMS_SQL.bind_variable (cid, ':x_objid', l_elementid);
      DBMS_SQL.bind_variable (cid, ':x_objtype', g_object_type);
      DBMS_SQL.bind_variable (cid, ':x_concid', l_conc_id);
      l_dummy := DBMS_SQL.EXECUTE (cid);
      DBMS_SQL.close_cursor (cid);

      put_debug_msg ('********** End Procedure : Staging_Log');
   EXCEPTION
      WHEN OTHERS
      THEN
          edw_log.put_line (
                     'Error inserting into local log table '
                  || SQLERRM,FND_LOG.LEVEL_ERROR
               );
         RAISE;
   END staging_log;


-- ------------------------------------------------------------------
-- Name: Set_Push_End_dates
-- Desc:
-- ------------------------------------------------------------------
   PROCEDURE set_push_end_dates
   IS
      l_stmt     VARCHAR2 (1000);
      l_cursor   INTEGER;
      l_dummy    INTEGER;
   BEGIN
      put_debug_msg ('********** Start Procedure : Set_Push_End_dates');
      put_debug_msg (
            '   Get current time in wh clock in '
         || g_wh_curr_push_end_date
      );
      l_cursor := DBMS_SQL.open_cursor;
      /* see if the end period for the previous push exists */


      l_stmt :=    'select sysdate
      from dual@'
                || g_target_link;
      DBMS_SQL.parse (l_cursor, l_stmt, DBMS_SQL.native);
      DBMS_SQL.define_column (l_cursor, 1, g_wh_curr_push_end_date);
      l_dummy := DBMS_SQL.EXECUTE (l_cursor);

      IF DBMS_SQL.fetch_rows (l_cursor) <> 0
      THEN
         DBMS_SQL.column_value (l_cursor, 1, g_wh_curr_push_end_date);
      END IF;

      DBMS_SQL.close_cursor (l_cursor);
      g_local_curr_push_end_date := SYSDATE;
      put_debug_msg ('       G_wh_curr_push_end_date IS :');
      put_debug_msg (fnd_date.date_to_displaydt (g_wh_curr_push_end_date));
      put_debug_msg ('********** End Procedure : Set_Push_End_Dates');
   END set_push_end_dates;


-- ------------------------------------------------------------------
-- Name: set_wh_language
-- Desc:
-- ------------------------------------------------------------------
   FUNCTION set_wh_language
      RETURN BOOLEAN
   IS
      l_lang_code      VARCHAR2 (240);
      l_nls_language   VARCHAR2 (240);
      cid              INTEGER;
      l_dummy_int      INTEGER;
   BEGIN
      put_debug_msg ('********** Start Procedure : set_wh_language');

      SELECT edw_language_code
        INTO l_lang_code
        FROM edw_local_system_parameters;

      SELECT nls_language
        INTO l_nls_language
        FROM fnd_languages
       WHERE language_code = l_lang_code;

      cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (
         cid,
            'ALTER SESSION SET NLS_LANGUAGE = '
         || l_nls_language,
         DBMS_SQL.native
      );
      l_dummy_int := DBMS_SQL.EXECUTE (cid);
      put_debug_msg (   'Set NLS language to '
                     || l_nls_language);
      put_debug_msg ('********** End Procedure : set_wh_language');
      RETURN TRUE;
   EXCEPTION
      WHEN OTHERS
      THEN
         fnd_message.set_name ('BIS', 'EDW_NLS_LANG_SETUP');
         fnd_message.set_token ('VALUE', l_lang_code);
         edw_log.put_line (
               'Unable to set the language context to the warehouse language '
            || l_lang_code,FND_LOG.LEVEL_ERROR
         );
         RETURN FALSE;
   END set_wh_language;

   FUNCTION is_instance_enabled
      RETURN BOOLEAN
   IS
      l_flag     VARCHAR2 (10);
      l_stmt     VARCHAR2 (1000);
      cv         curtyp;
      l_status   BOOLEAN;
   BEGIN
      put_debug_msg ('********** Start Function : is_instance_enabled');

      IF    (g_source_link IS NULL)
         OR (g_target_link IS NULL)
      THEN
         get_dblink_names (g_source_link, g_target_link);
      END IF;

      l_stmt :=
               'SELECT enabled_flag
   FROM   edw_source_instances_vl@'
            || g_target_link
            || '
   WHERE  instance_code= (  SELECT instance_code
                FROM   edw_local_instance)';
      put_debug_msg (
         'Checking whether instance is enabled in target database'
      );
      put_debug_msg ('Going to execute: ');
      put_debug_msg (l_stmt);
      OPEN cv FOR l_stmt;
      FETCH cv INTO l_flag;
      CLOSE cv;

      IF (l_flag = 'Y')
      THEN
         l_status := TRUE;
      ELSE
         l_status := FALSE;
      END IF;

      put_debug_msg ('********** End Function : is_instance_enabled');
      RETURN l_status;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         edw_log.put_line ('Error while checking whether source is enabled',FND_LOG.LEVEL_ERROR);
         edw_log.put_line (   g_errbuf
                           || ':'
                           || g_retcode,FND_LOG.LEVEL_ERROR);
         RETURN FALSE;
   END is_instance_enabled;

   FUNCTION source_same_as_target
      RETURN BOOLEAN
   IS
      l_instance1   VARCHAR2 (200);
      l_instance2   VARCHAR2 (200);
      l_stmt        VARCHAR2 (1000);
      cv            curtyp;
      l_status      BOOLEAN;
   BEGIN
      put_debug_msg (
         '********** Start Function : source_same_as_target to check EDW Installation'
      );

      IF    (g_source_link IS NULL)
         OR (g_target_link IS NULL)
      THEN
         get_dblink_names (g_source_link, g_target_link);
      END IF;

      SELECT instance_code
        INTO l_instance1
        FROM edw_local_instance;

      l_stmt :=    'SELECT instance_code
         FROM   edw_local_instance@'
                || g_target_link;
      put_debug_msg ('Running: ');
      put_debug_msg (l_stmt);
      OPEN cv FOR l_stmt;
      FETCH cv INTO l_instance2;
      CLOSE cv;

      IF (l_instance1 = l_instance2)
      THEN
         put_debug_msg ('Single Instance is implemented.');
         l_status := TRUE;
      ELSE
         put_debug_msg (
               'Decoupled Architecture is implemented. Source Instance: '
            || l_instance1
            || '. Warehouse Instance: '
            || l_instance2
         );
         l_status := FALSE;
      END IF;

      put_debug_msg (
         '********** End Function : source_same_as_target to check EDW Installation'
      );
      RETURN l_status;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN FALSE;
      WHEN OTHERS
      THEN
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         edw_log.put_line (
            'Error while checking whether source same as target',FND_LOG.LEVEL_ERROR
         );
         edw_log.put_line (   g_errbuf
                           || ':'
                           || g_retcode,FND_LOG.LEVEL_ERROR);
         RAISE;
   END source_same_as_target;

   PROCEDURE truncate_stg (p_tab_list IN tablist_type)
   IS
      l_stmt   VARCHAR2 (1000);
   BEGIN
      put_debug_msg ('********** Start Procedure : truncate_stg');

      IF p_tab_list.COUNT > 0
      THEN
         FOR i IN p_tab_list.FIRST .. p_tab_list.LAST
         LOOP
            l_stmt :=    'TRUNCATE TABLE '
                      || p_tab_list (i).tbl_owner
                      || '.'
                      || p_tab_list (i).tbl_name;
            put_debug_msg (
                  'Truncate local staging table '
               || p_tab_list (i).tbl_owner
               || '.'
               || p_tab_list (i).tbl_name
            );
            EXECUTE IMMEDIATE l_stmt;
         END LOOP;
      END IF;

      put_debug_msg ('********** End Procedure : truncate_stg');
   EXCEPTION
      WHEN OTHERS
      THEN
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         edw_log.put_line (
               'error while truncating local staging table '
            || g_errbuf
            || ':'
            || g_retcode,FND_LOG.LEVEL_ERROR
         );
         RAISE;
   END truncate_stg;

   FUNCTION set_status_ready (p_tab_list IN tablist_type)
      RETURN NUMBER
   IS
      l_stmt          VARCHAR2 (1000);
      l_count         PLS_INTEGER                   := 0;
      l_num           PLS_INTEGER                   := 0;
      l_rowcount      PLS_INTEGER                   := 0;
      cv              curtyp;
      l_stgtbl_name   user_tables.table_name%TYPE;
      l_total_rows    PLS_INTEGER                   := 0;
   BEGIN
      put_debug_msg ('********** Start Function : set_status_ready');

      <<stgtbl_loop>>
      FOR i IN p_tab_list.FIRST .. p_tab_list.LAST
      LOOP
         l_stgtbl_name := p_tab_list (i).tbl_name;
         OPEN cv FOR    'select count(1) from '
                     || l_stgtbl_name
                     || ' where COLLECTION_STATUS = ''LOCAL READY'' ';
         FETCH cv INTO l_count;
         CLOSE cv;

         IF l_count > 0
         THEN
            IF  l_count > g_push_size AND g_push_size > 0
            THEN
               l_num := g_push_size;
            ELSE
               l_num := l_count;
            END IF;

            l_stmt :=
                     'UPDATE  '
                  || l_stgtbl_name
                  || '  SET    COLLECTION_STATUS = ''READY''
    WHERE  COLLECTION_STATUS = ''LOCAL READY'' AND ROWNUM <= '
                  || l_num;
            put_debug_msg ('Running: ');
            put_debug_msg (l_stmt);
            l_rowcount := 0;

            <<update_loop>>
            FOR i IN 1 .. CEIL (l_count / l_num)
            LOOP
               EXECUTE IMMEDIATE l_stmt;
               l_rowcount :=   l_rowcount
                             + SQL%ROWCOUNT;
               COMMIT;
            END LOOP update_loop;

            edw_log.put_line (
                  l_rowcount
               || ' rows for table '
               || l_stgtbl_name
               || ' proceeded.',FND_LOG.LEVEL_STATEMENT
            );
         END IF; -- l_count>0

         l_total_rows :=   l_total_rows
                         + l_rowcount;
      END LOOP stgtbl_loop;

      put_debug_msg ('********** End Function : set_status_ready');
      RETURN (l_total_rows);
   EXCEPTION
      WHEN OTHERS
      THEN
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         edw_log.put_line (   'set status failed'
                           || g_errbuf
                           || g_retcode,FND_LOG.LEVEL_ERROR);
         RETURN (-1);
   END set_status_ready;

   FUNCTION get_last_push_date_logical (p_object_logical_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_obj_short_name   VARCHAR2 (200);
      stmt               VARCHAR2 (1000);
      cid                INTEGER        := 0;
      l_dummy            INTEGER;
      l_date             VARCHAR2 (30);
   BEGIN
      put_debug_msg (
         '********** Start Function : get_last_push_date_logical'
      );

      /* bug 3256880*/
      IF    (g_source_link IS NULL)  OR (g_target_link IS NULL) THEN
        get_dblink_names (g_source_link, g_target_link);
      END IF;

      IF (p_object_logical_name IS NOT NULL)
      THEN
         stmt :=    'SELECT relation_name from edw_relations_md_v@'
                 || g_target_link
                 || ' where relation_long_name = :longname';
         put_debug_msg ('Running: ');
         put_debug_msg (stmt);
         cid := DBMS_SQL.open_cursor;
         DBMS_SQL.parse (cid, stmt, DBMS_SQL.native);
         DBMS_SQL.bind_variable (cid, ':longname', p_object_logical_name);
         DBMS_SQL.define_column (cid, 1, l_obj_short_name, 100);
         l_dummy := DBMS_SQL.execute_and_fetch (cid);
         DBMS_SQL.column_value (cid, 1, l_obj_short_name);
         DBMS_SQL.close_cursor (cid);
         l_date := get_last_push_date (l_obj_short_name);
      ELSE
         l_date := NULL;
      END IF;

      put_debug_msg ('********** End Function : get_last_push_date_logical');
      RETURN l_date;
   END get_last_push_date_logical;

   FUNCTION get_last_push_date (p_object IN VARCHAR2)
      RETURN VARCHAR2
   IS
      l_date     DATE;
      l_datedt   VARCHAR2 (100);
      l_cid      INTEGER;
      l_stmt     VARCHAR2 (1000);
      l_dummy    INTEGER;
   BEGIN
      put_debug_msg ('********** Start Function : get_last_push_date');


/*        l_stmt := ' ALTER SESSION SET global_names = false';
        l_cid := DBMS_SQL.OPEN_CURSOR;
        DBMS_SQL.PARSE(l_cid, l_stmt, DBMS_SQL.NATIVE);
        l_dummy := DBMS_SQL.EXECUTE(l_cid);
        DBMS_SQL.CLOSE_CURSOR(l_cid); */
        --edw_misc_util.globalnamesoff;

      IF    (g_source_link IS NULL)
         OR (g_target_link IS NULL)
      THEN
         get_dblink_names (g_source_link, g_target_link);
      END IF;

      l_stmt :=
               ' select nvl(period_end, to_date(''01/01/1950'',''MM/DD/YYYY'')) '
            || ' from edw_push_detail_log@'
            || g_target_link
            || ' where object_name= :s and push_status=''SUCCESS'' and '
            || ' instance_code=(select instance_code from edw_local_instance)'
            || ' and last_update_date= ( select max(last_update_date)
           from edw_push_detail_log@'
            || g_target_link
            || ' where object_name=:s and  push_status=''SUCCESS'' and '
            || ' instance_code=(select instance_code from edw_local_instance))';
      put_debug_msg ('Running: ');
      put_debug_msg (l_stmt);
      l_cid := DBMS_SQL.open_cursor;
      DBMS_SQL.parse (l_cid, l_stmt, DBMS_SQL.native);
      DBMS_SQL.bind_variable (l_cid, ':s', p_object);
      DBMS_SQL.define_column (l_cid, 1, l_date);
      l_dummy := DBMS_SQL.EXECUTE (l_cid);

      IF DBMS_SQL.fetch_rows (l_cid) <> 0
      THEN
         DBMS_SQL.column_value (l_cid, 1, l_date);
      END IF;

      DBMS_SQL.close_cursor (l_cid);
      l_date := NVL (l_date, TO_DATE ('01/01/1950', 'MM/DD/YYYY'));
      l_datedt := fnd_date.date_to_displaydt (l_date);
      put_debug_msg ('********** End Function : get_last_push_date');
      RETURN l_datedt;
   END get_last_push_date;

   PROCEDURE get_dblink_names (
      x_source_link   OUT NOCOPY  VARCHAR2,
      x_target_link   OUT NOCOPY  VARCHAR2
   )
   IS
      CURSOR c_global_names_opt
      IS
         SELECT param.VALUE
           FROM v$parameter param
          WHERE param.NAME = 'global_names';

      CURSOR c_global_names_val
      IS
         SELECT GLOBAL_NAME val
           FROM GLOBAL_NAME;

      l_gname_set     v$parameter.VALUE%TYPE;
      l_gname_val     GLOBAL_NAME.GLOBAL_NAME%TYPE;
      l_source_link   VARCHAR2 (128);
      l_target_link   VARCHAR2 (128);
   BEGIN
      put_debug_msg ('********** Start Procedure : get_dblink_names');
      put_debug_msg ('Profile Options EDW_APPS_TO_APPS and EDW_APPS_TO_WH');
      OPEN c_global_names_opt;
      FETCH c_global_names_opt INTO l_gname_set;
      CLOSE c_global_names_opt;
      l_source_link := fnd_profile.VALUE ('EDW_APPS_TO_APPS');
      l_target_link := fnd_profile.VALUE ('EDW_APPS_TO_WH');

      IF l_gname_set = 'TRUE'
      THEN
         OPEN c_global_names_val;
         FETCH c_global_names_val INTO l_gname_val;
         CLOSE c_global_names_val;
         put_debug_msg ('l_source_link='||l_source_link);
         put_debug_msg ('l_target_link='||l_target_link);
         put_debug_msg ('l_gname_val='||l_gname_val);
         --bug 3358820
         --IF    (l_source_link IS NULL)
           -- OR (l_source_link <> l_gname_val)
            --OR (l_target_link IS NULL)
        if (l_source_link IS NULL) or (l_target_link IS NULL) THEN
          RAISE g_push_remote_failure;
        elsif instr(l_source_link,'@')>0 then
          if upper(substr(l_source_link,1,instr(l_source_link,'@')-1))<>upper(l_gname_val) then
            RAISE g_push_remote_failure;
          end if;
        else
          if upper(l_source_link)<>upper(l_gname_val) then
            RAISE g_push_remote_failure;
          end if;
        end if;
      ELSIF      l_gname_set = 'FALSE'
             AND (   l_source_link IS NULL
                  OR l_target_link IS NULL
                 )
      THEN
         l_source_link := 'APPS_TO_APPS';
         l_target_link := 'EDW_APPS_TO_WH';
      END IF;

      put_debug_msg (   'Loop back link is '
                     || l_source_link);
      put_debug_msg (   'Warehouse link is '
                     || l_target_link);
      put_debug_msg ('********** End Procedure : get_dblink_names');
      x_source_link := l_source_link;
      x_target_link := l_target_link;
   EXCEPTION
      WHEN g_push_remote_failure
      THEN
         g_errbuf :=
                  'GLOBAL NAMES option is enabled.
 Database Link Names are not set corretly in Application Profile Option.
 EDW: Loop back link name is'
               || l_source_link
               || '. '
               || 'EDW: Runtime link name is '
               || l_target_link
               || '. Database Global Name is '
               || l_gname_val;
         g_retcode := 'EDW: ';
         edw_log.put_line (   'error  '
                           || g_retcode
                           || ':'
                           || g_errbuf,FND_LOG.LEVEL_ERROR);
         edw_log.put_line (
            'Data migration from local to remote staging have failed',FND_LOG.LEVEL_ERROR
         );
         RAISE;
      WHEN OTHERS
      THEN
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         edw_log.put_line (   'error  '
                           || g_retcode
                           || ':'
                           || g_errbuf,FND_LOG.LEVEL_ERROR);
         edw_log.put_line (
            'Data migration from local to remote staging have failed',FND_LOG.LEVEL_ERROR
         );
         RAISE;
   END get_dblink_names;

   PROCEDURE clean_up (p_tab_list IN tablist_type, suffix IN VARCHAR2)
   IS
      dummy              PLS_INTEGER;
      l_tmp_table_name   user_tables.table_name%TYPE;
      l_suffix_length    VARCHAR2 (20);

      CURSOR c_check_tbl (p_tbl_name IN VARCHAR2)
      IS
         SELECT 1
           FROM dba_tables
          WHERE table_name = p_tbl_name AND owner = g_bis_schema;
   BEGIN
      put_debug_msg ('********** Start Procedure : clean_up');

      IF tab_stglist.COUNT > 0
      THEN
         put_debug_msg (
            'Calling  edw_collection_util.clean_up to drop temporary tables:'
         );
         l_suffix_length := LENGTH (suffix);

         FOR i IN tab_stglist.FIRST .. tab_stglist.LAST
         LOOP
            put_debug_msg (
                  g_bis_schema
               || '.'
               || SUBSTR (
                     tab_stglist (i).tbl_name,
                     0,
                       30
                     - l_suffix_length
                  )
               || suffix
            );
         END LOOP;

         FOR i IN tab_stglist.FIRST .. tab_stglist.LAST
         LOOP
            l_tmp_table_name :=    SUBSTR (
                                      tab_stglist (i).tbl_name,
                                      0,
                                        30
                                      - l_suffix_length
                                   )
                                || suffix;
            OPEN c_check_tbl (l_tmp_table_name);
            FETCH c_check_tbl INTO dummy;

            IF c_check_tbl%FOUND
            THEN
               EXECUTE IMMEDIATE    'drop table '
                                 || g_bis_schema
                                 || '.'
                                 || l_tmp_table_name;
            END IF;

            CLOSE c_check_tbl;
         END LOOP;
      END IF; -- count >0

      put_debug_msg ('********** End Procedure : clean_up');
   EXCEPTION
      WHEN OTHERS
      THEN
         RAISE;
   END clean_up;

   PROCEDURE get_stg_table_names (
      p_object_name   IN       VARCHAR2,
      tablist         OUT   NOCOPY   tablist_type
   )
   IS
      l_smt         VARCHAR2 (2000);
      l_len         PLS_INTEGER     := 0;
      cv            curtyp;
      empty_table   tablist_type;
   BEGIN
      put_debug_msg (
            '********** Calling  Get_stg_table_names to get the list of staging tables for object '
         || p_object_name
      );

      IF g_transport_data
      THEN
         IF get_object_type (p_object_name)
         THEN
            -- assign to global variables, add log
            tab_stglist := empty_table;

            IF g_object_type = edw_dim
            THEN
               l_smt :=
                        'SELECT stg.relation_name FROM edw_levels_md_v@'
                     || g_target_link
                     || ' ltc, edw_relationmapping_md_v@'
                     || g_target_link
                     || ' map, edw_relations_md_v@'
                     || g_target_link
                     || ' stg WHERE ltc.dim_name = :a'
                     || ' AND map.targetdataentity = ltc.level_table_id'
                     || ' AND map.sourcedataentity = stg.relation_id'
                     || ' AND ltc.level_table_name = ltc.level_name||''_LTC''';
            ELSIF g_object_type = edw_fact
            THEN
               l_smt :=    'SELECT stg.relation_name FROM edw_relations_md_v@'
                        || g_target_link
                        || ' stg, edw_relationmapping_md_v@'
                        || g_target_link
                        || ' map, edw_facts_md_v@'
                        || g_target_link
                        || ' fact WHERE fact.fact_name = :a'
                        || ' AND map.targetdataentity = fact.fact_id'
                        || ' AND stg.relation_id = map.sourcedataentity';
            END IF;

            put_debug_msg ('Running: ');
            put_debug_msg (l_smt);
            OPEN cv FOR l_smt USING p_object_name;

            LOOP
               FETCH cv INTO tablist (l_len).tbl_name;
               EXIT WHEN cv%NOTFOUND;
               tablist (l_len).tbl_owner :=
                                      get_syn_info (tablist (l_len).tbl_name);
               l_len :=   l_len
                        + 1;
            END LOOP;

            CLOSE cv;
            put_debug_msg (
                  'Staging Tables List for EDW object: '
               || p_object_name
            );
            put_debug_msg ('------------------------------');

            IF tablist.COUNT > 0
            THEN
               FOR i IN tablist.FIRST .. tablist.LAST
               LOOP
                  put_debug_msg (tablist (i).tbl_name);
               END LOOP;
            END IF;
         ELSE
            NULL;
         --  RAISE g_push_remote_failure;
         END IF;
      END IF; -- g_transport_data

      put_debug_msg ('********** End Procedure : get_stg_table_names'); -- get_object_type
   EXCEPTION
      WHEN OTHERS
      THEN
         tablist.delete;
         RAISE;
   END get_stg_table_names;

   FUNCTION push_to_target
      RETURN NUMBER
   IS
      cv                     curtyp;
      l_stmt                 VARCHAR2 (30000);
      l_column               all_tab_columns.column_name%TYPE;
      l_collist              VARCHAR2 (10000);
      l_scollist             VARCHAR2 (10000);
      l_edw_extent           PLS_INTEGER                        := 0;
      row_count              PLS_INTEGER                        := 0;
      l_rowcount             INTEGER                            := 0;
      l_count                INTEGER                            := 0;
      l_colcount             PLS_INTEGER                        := 0;
      l_pushcount            PLS_INTEGER                        := 0;
      l_tmptbl_name          user_tables.table_name%TYPE;
      l_stgtbl_name          user_tables.table_name%TYPE;
      l_optbl_name           user_tables.table_name%TYPE;
      l_stg_owner            user_users.username%TYPE;
      l_stg_initial_extent   PLS_INTEGER                        := 0;
      l_stg_next_extent      PLS_INTEGER                        := 0;
      l_partitioned_table    user_tables.partitioned%TYPE; -- added for bug 4300166
   BEGIN
      put_debug_msg ('********** Start Procedure : push_to_target');
      put_timestamp;

      IF tab_stglist.COUNT > 0
      THEN
         IF g_source_same_as_target = TRUE
         THEN
            put_debug_msg ('Source Instance the same as Target.');

-- Single Instance Case
-----------------------
              -- Update Local Staging Table in case of single instance

            l_count := set_status_ready (tab_stglist);

            IF (l_count = -1)
            THEN
               edw_log.put_line (
                     'Update of table'
                  || l_stgtbl_name
                  || ' failed',FND_LOG.LEVEL_ERROR
               );
            ELSE
               edw_log.put_line (   l_count
                                 || ' total rows  proceeded.',FND_LOG.LEVEL_STATEMENT);
               edw_log.put_line (' ',FND_LOG.LEVEL_STATEMENT);
            END IF;
         ELSE

-- Decoupled Architecture Case
------------------------------
            put_debug_msg ('Source different from Target. Push to remote.');

            IF g_op_tablespace IS NULL
            THEN
               OPEN cv FOR 'select default_tablespace from dba_users where username=:u'
                  USING g_bis_schema;
               FETCH cv INTO g_op_tablespace;
               CLOSE cv;
            END IF;

            IF l_edw_extent = 0
            THEN
               OPEN cv FOR 'select initial_extent from dba_tablespaces where tablespace_name= :t'
                  USING g_op_tablespace;
               FETCH cv INTO l_edw_extent;
               CLOSE cv;
            END IF;

            put_debug_msg (   'Operational Tablespace: '
                           || g_op_tablespace);
            put_debug_msg (   'Temporary Table extent size: '
                           || l_edw_extent);


-- Start Loop for EDW Object Staging Tables
            <<stgtbl_loop>>
            FOR i IN tab_stglist.FIRST .. tab_stglist.LAST
            LOOP
               l_count := 0;
               l_stgtbl_name := tab_stglist (i).tbl_name;
               l_stg_owner := tab_stglist (i).tbl_owner;
               l_tmptbl_name :=
                               SUBSTR (tab_stglist (i).tbl_name, 0, 27)
                            || '_SK';
               l_optbl_name :=
                               SUBSTR (tab_stglist (i).tbl_name, 0, 27)
                            || '_SL';

-- Check data availability in Local Staging Table
               OPEN cv FOR    'select count(1) from '
                           || l_stgtbl_name
                           || ' where collection_status in (''READY'',''LOCAL READY'')';
               FETCH cv INTO row_count;
               CLOSE cv;
               put_debug_msg (
                     'Check data for data in table '
                  || l_stgtbl_name
                  || ' Row Count: '
                  || row_count
               );


-- If there is data in Local Staging table then run transportation process
               IF row_count > 0
               THEN

-- Get list of columns
                  l_colcount := 0;
                  l_stmt :=
                           'SELECT column_name FROM all_tab_columns WHERE table_name =:t AND column_name not in ( ''COLLECTION_STATUS'',''REQUEST_ID'')'
                        || ' AND owner = :o';
                  put_debug_msg (   'Running for '
                                 || l_stgtbl_name);
                  put_debug_msg (l_stmt);
                  l_collist := NULL;
                  l_scollist := NULL;
                  OPEN cv FOR l_stmt USING l_stgtbl_name, l_stg_owner;

                  <<table_column_loop>>
                  LOOP
                     FETCH cv INTO l_column;
                     EXIT table_column_loop WHEN cv%NOTFOUND;
                     put_debug_msg (l_column);

                     IF (l_colcount = 0)
                     THEN
                        l_collist :=    l_collist
                                     || l_column;
                        l_scollist :=    l_scollist
                                      || 's.'
                                      || l_column;
                        l_colcount :=   l_colcount
                                      + 1;
                     ELSE
                        l_collist :=    l_collist
                                     || ', '
                                     || l_column;
                        l_scollist :=    l_scollist
                                      || ', '
                                      || 's.'
                                      || l_column;
                     END IF;
                  END LOOP table_column_loop;

                  CLOSE cv;


-- End of fetching table columns


                  IF  row_count > g_push_size AND g_push_size > 0
                  THEN
                     put_debug_msg (
                        'Starting Data Transportation Process using Temporary Tables '
                     );
                     put_timestamp;
                      --partitioned column added for bug 4300166
                     OPEN cv FOR 'select initial_extent, next_extent, partitioned from dba_tables where table_name= :t and owner =:o'
                        USING l_stgtbl_name, l_stg_owner;
                     FETCH cv INTO l_stg_initial_extent, l_stg_next_extent,l_partitioned_table;
                     CLOSE cv;

		     --code added for bug fix 4300166
		     ----case 1 partitioned table, both intial and next extent are null in dba tables
                     IF((l_stg_initial_extent is null and l_stg_next_extent is null)
		        and l_partitioned_table = 'YES') THEN
                       l_stg_initial_extent := l_edw_extent;
		       l_stg_next_extent := l_edw_extent;
		     ELSE IF(l_stg_initial_extent is not null and l_stg_next_extent is null) THEN
			     ---case 2 locally managed tablespaces, next extent can be null in dba_tables
        	            l_stg_next_extent := l_stg_initial_extent;
                          END IF;
                     END IF;

                     put_debug_msg (
                           'Storage Parameters for OP Table: '
                        || l_optbl_name
                     );
                     put_debug_msg (
                           'INITIAL Extent: '
                        || l_stg_initial_extent
                     );
                     put_debug_msg (   'NEXT Extent: '
                                    || l_stg_next_extent);
                     l_pushcount := 1;
                     -- multiple iterations case
                     -- create table for temporary data

                     set_transaction_rbs (g_rbs);
                     l_stmt :=
                              'create table '
                           || g_bis_schema
                           || '.'
                           || l_tmptbl_name
                           || ' tablespace '
                           || g_op_tablespace
                           || ' storage ( initial '
                           || l_edw_extent
                           || ' next '
                           || l_edw_extent
                           || ' PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645) '
                           || ' as select /*+PARALLEL('
                           || l_stgtbl_name
                           || ', '
                           || g_parallel
                           || ') */ rowid row_id, 0 status from '
                           || l_stgtbl_name
                           || ' where collection_status in (''READY'', ''LOCAL READY'') ';
                     put_timestamp;
                     put_debug_msg (
                           'Level STAGING Table: '
                        || l_stgtbl_name
                     );
                     put_debug_msg ('Running: ');
                     put_debug_msg (l_stmt);
                     EXECUTE IMMEDIATE l_stmt;

                     /* move data from local interface table into remote interface
                        table across db link using tables with temporary data  */

                     <<bach_insert_loop>>
                     WHILE l_pushcount <= CEIL (row_count / g_push_size)
                     LOOP
                        set_transaction_rbs (g_rbs);
                        l_stmt :=
                                 'update '
                              || g_bis_schema
                              || '.'
                              || l_tmptbl_name
                              || ' set status =1 where status = 0 and rownum <='
                              || g_push_size;
                        put_timestamp;
                        put_debug_msg ('Running: ');
                        put_debug_msg (l_stmt);
                        EXECUTE IMMEDIATE l_stmt;
                        COMMIT;
                        put_timestamp;
                        set_transaction_rbs (g_rbs);
                        l_stmt :=
                                 'create table '
                              || g_bis_schema
                              || '.'
                              || l_optbl_name
                              || ' tablespace '
                              || g_op_tablespace
                              || ' storage ( initial '
                              || l_stg_initial_extent
                              || ' next '
                              || l_stg_next_extent
                              || ' PCTINCREASE 0 MINEXTENTS 1 MAXEXTENTS 2147483645) '
                              || ' as select /*+ORDERED PARALLEL('
                              || l_stgtbl_name
                              || ', '
                              || g_parallel
                              || ') PARALLEL('
                              || g_bis_schema
                              || '.'
                              || l_tmptbl_name
                              || ', '
                              || g_parallel
                              || ') '
                              || '*/ ''READY'' COLLECTION_STATUS, '
                              || g_request_id
                              || ' REQUEST_ID, '
                              || l_scollist
                              || ' from '
                              || g_bis_schema
                              || '.'
                              || l_tmptbl_name
                              || ' t, '
                              || l_stgtbl_name
                              || ' s where t.row_id = s.rowid and t.status = 1 ';
                        put_timestamp;
                        put_debug_msg (
                              'Level STAGING Table: '
                           || l_stgtbl_name
                        );
                        put_debug_msg ('Running: ');
                        put_debug_msg (l_stmt);
                        EXECUTE IMMEDIATE l_stmt;
                        put_timestamp;
                        -- Insert data accross db link

                        set_transaction_rbs (g_rbs);
                        l_stmt :=    'insert /*+APPEND PARALLEL('
                                  || l_stgtbl_name
                                  || '@'
                                  || g_target_link
                                  || ', '
                                  || g_parallel
                                  || ') '
                                  || '*/ into '
                                  || l_stgtbl_name
                                  || '@'
                                  || g_target_link
                                  || ' (COLLECTION_STATUS, REQUEST_ID, '
                                  || l_collist
                                  || ') '
                                  || ' select /*+PARALLEL('
                                  || g_bis_schema
                                  || '.'
                                  || l_optbl_name
                                  || ', '
                                  || g_parallel
                                  || ')*/'
                                  || ' COLLECTION_STATUS, REQUEST_ID, '
                                  || l_collist
                                  || ' FROM '
                                  || g_bis_schema
                                  || '.'
                                  || l_optbl_name;
                        put_debug_msg ('Running: ');
                        put_debug_msg (l_stmt);
                        EXECUTE IMMEDIATE l_stmt;
                        put_timestamp;
                        l_count :=   l_count
                                   + SQL%ROWCOUNT;
                        COMMIT;

-- drop second OP table

                        set_transaction_rbs (g_rbs);
                        l_stmt :=    'drop table '
                                  || g_bis_schema
                                  || '.'
                                  || l_optbl_name;
                        put_debug_msg ('Running: ');
                        put_debug_msg (l_stmt);
                        EXECUTE IMMEDIATE l_stmt;
                        put_timestamp;

-- Update first OP table
                        set_transaction_rbs (g_rbs);
                        l_stmt :=    'update '
                                  || g_bis_schema
                                  || '.'
                                  || l_tmptbl_name
                                  || ' set status =2 where status = 1';
                        put_debug_msg ('Running: ');
                        put_debug_msg (l_stmt);
                        EXECUTE IMMEDIATE l_stmt;
                        COMMIT;
                        put_timestamp;
                        put_debug_msg (
                              'Iteration  '
                           || l_pushcount
                           || ' Completed'
                        );
                        l_pushcount :=   l_pushcount
                                       + 1;
                     END LOOP bach_insert_loop;

                     put_timestamp;

-- One Iteration Case
                  ELSIF    (row_count <= g_push_size AND g_push_size > 0)
                        OR (g_push_size = 0)
                        OR (g_push_size IS NULL)
                  THEN
                     -- insert data into remote interface table

                     put_debug_msg (
                        'Direct insert into Remote Staging Tables. '
                     );
                     put_timestamp;
                     set_transaction_rbs (g_rbs);
                     l_stmt :=
                              'insert into '
                           || l_stgtbl_name
                           || '@'
                           || g_target_link
                           || ' (COLLECTION_STATUS, REQUEST_ID, '
                           || l_collist
                           || ') /*+APPEND PARALLEL('
                           || l_stgtbl_name
                           || '@'
                           || g_target_link
                           || ', '
                           || g_parallel
                           || ')*/ '
                           || ' select /*+PARALLEL('
                           || l_stgtbl_name
                           || ', '
                           || g_parallel
                           || ')*/ ''READY'','
                           || g_request_id
                           || ','
                           || l_scollist
                           || ' FROM '
                           || l_stgtbl_name
                           || ' s '
                           || ' where s.COLLECTION_STATUS in (''READY'',''LOCAL READY'')';
                     put_debug_msg ('Running: ');
                     put_debug_msg (l_stmt);
                     EXECUTE IMMEDIATE l_stmt;
                     COMMIT;
                     put_timestamp;
                     l_count := SQL%ROWCOUNT;
                  END IF; -- end iteration cases
               END IF; -- row_count>0 There is data in LSTG tables

               edw_log.put_line (
                     l_count
                  || ' rows for table '
                  || l_stgtbl_name
                  || ' proceeded.',FND_LOG.LEVEL_STATEMENT
               );
               edw_log.put_line (' ',FND_LOG.LEVEL_STATEMENT);
               l_rowcount :=   l_rowcount
                             + l_count;
            END LOOP stgtbl_loop; -- end loop for table list
         END IF;
      -- end check of EDW Architecture: single instance or decoupled implementation
      END IF; -- check number of stg tables

      IF g_source_same_as_target = FALSE
      THEN
         edw_log.put_line (   'Total rows proceeded.'
                           || l_rowcount,FND_LOG.LEVEL_STATEMENT);
         edw_log.put_line (' ',FND_LOG.LEVEL_STATEMENT);
      ELSIF  l_rowcount = 0 AND g_source_same_as_target = TRUE
      THEN
         edw_log.put_line (
               'Data for Object'
            || g_object_name
            || 'collected. ',FND_LOG.LEVEL_PROCEDURE
         );
         edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);
      ELSIF  l_rowcount > 0 AND g_source_same_as_target = TRUE
      THEN
         edw_log.put_line (
               'Data for Object'
            || g_object_name
            || 'collected. ',FND_LOG.LEVEL_PROCEDURE
         );
         edw_log.put_line (   l_rowcount
                           || ' rows are updated',FND_LOG.LEVEL_PROCEDURE);
         edw_log.put_line (' ',FND_LOG.LEVEL_PROCEDURE);
      END IF;

      put_debug_msg ('********** End Procedure : push_to_target');
      put_timestamp;
      RETURN (l_rowcount);
   EXCEPTION
      WHEN OTHERS
      THEN
         ROLLBACK;
         g_errbuf := SQLERRM;
         g_retcode := SQLCODE;
         edw_log.put_line (
            'EDW_COLLECTION_UTIL.push_to_target error while pushing to target',FND_LOG.LEVEL_ERROR
         );
         edw_log.put_line (   g_retcode
                           || ' : '
                           || g_errbuf,FND_LOG.LEVEL_ERROR);
         RETURN (-1);
   END push_to_target;

   FUNCTION get_syn_info (syn_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
      TYPE cv_type IS REF CURSOR;

      c_get_tbl_owner   cv_type;
      l_tbl_owner       user_users.username%TYPE;
   BEGIN
      put_debug_msg ('********** Start Function : get_syn_info');
      -- bug 4300166 underscore added to supress GSCC error
      put_debug_msg (   'Reading synonym _APPS_.'
                     || syn_name
                     || ' information');
      OPEN c_get_tbl_owner FOR    '
    select table_owner from user_synonyms where synonym_name = :s'
       USING syn_name;

      FETCH c_get_tbl_owner INTO l_tbl_owner;

      IF c_get_tbl_owner%NOTFOUND
      THEN
      -- bug 4300166 underscore added to supress GSCC error
         edw_log.put_line (
               'Error. Synonym _APPS_.'
            || syn_name
            || ' is invalid.',FND_LOG.LEVEL_ERROR
         );
         edw_log.put_line (' ');
         RAISE g_push_remote_failure;
      END IF;

      CLOSE c_get_tbl_owner;
      put_debug_msg ('********** End Function : get_syn_info');
      RETURN l_tbl_owner;
   END get_syn_info;

   PROCEDURE put_timestamp
   IS
   BEGIN
      IF g_debug
      THEN
         edw_log.put_line (fnd_date.date_to_displaydt (SYSDATE),FND_LOG.LEVEL_STATEMENT);
         edw_log.put_line (' ',FND_LOG.LEVEL_STATEMENT);
      END IF;
   END put_timestamp;

   PROCEDURE put_debug_msg (p_message IN VARCHAR2)
   IS
   BEGIN
      IF g_debug
      THEN
         edw_log.put_line (p_message,FND_LOG.LEVEL_STATEMENT);
         edw_log.put_line (' ',FND_LOG.LEVEL_STATEMENT);
      END IF;
   END put_debug_msg;

   FUNCTION is_object_for_local_load (p_object_name IN VARCHAR2)
      RETURN BOOLEAN
   IS
      l_stmt     VARCHAR2 (2000);
      l_res      INTEGER;
      l_status   BOOLEAN;

      TYPE curtyp IS REF CURSOR;

      cv         curtyp;
   BEGIN
      l_stmt :=
            'select 1 from FND_COMMON_LOOKUPS where lookup_type=:a and lookup_code=:b';
      OPEN cv FOR l_stmt USING 'EDW_OBJECTS_TO_LOAD', p_object_name;
      FETCH cv INTO l_res;
      CLOSE cv;

      IF l_res = 1
      THEN
         l_status := TRUE;
      ELSE
         l_status := FALSE;
      END IF;

      RETURN l_status;
   EXCEPTION
      WHEN OTHERS
      THEN
         edw_log.put_line (SQLERRM,FND_LOG.LEVEL_ERROR);
         RAISE;
   END is_object_for_local_load;

   PROCEDURE set_transaction_rbs (p_rbs IN VARCHAR2)
   IS
      l_stmt   VARCHAR2 (1000);
   BEGIN
      IF p_rbs IS NOT NULL
      THEN
         l_stmt :=    'set transaction  use  rollback segment '
                   || p_rbs;
         EXECUTE IMMEDIATE l_stmt;
      END IF;
   END set_transaction_rbs;
END edw_collection_util;


/
