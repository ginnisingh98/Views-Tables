--------------------------------------------------------
--  DDL for Package Body BIL_BI_PURGE_OBJ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_PURGE_OBJ_PKG" AS
/*$Header: bilbprgb.pls 120.3 2005/10/10 04:42:47 vchahal noship $*/


-- Declaring Global variables

  g_retcode             VARCHAR2(20);
  g_debug               BOOLEAN;
  g_errbuf              VARCHAR2(1000);
  g_row_num             NUMBER;
  g_status              BOOLEAN;
  g_end_date            DATE;
  g_end_date_timeid     NUMBER;
  g_pkg                 VARCHAR2(100);
  g_setup_valid_error   EXCEPTION;

-- ---------------------------------------------------------------
-- Private procedures and Functions Prototypes;
-- ---------------------------------------------------------------

   PROCEDURE opdtl_f_purge;

   PROCEDURE fst_dtl_f_purge;

   PROCEDURE pipeline_f_purge;

   PROCEDURE init(p_obj_name IN VARCHAR2);

   PROCEDURE clean_up;

-- **********************************************************************
--  PROCEDURE Trunc_Obj
--
--  Purpose:
--  To Truncate the data from the BIL database object
--    This main procedure is called from the Concurrent Program
--   'Delete Complete Data from Sales Intelligence Object'
--
-- **********************************************************************

  PROCEDURE trunc_obj
  (
     errbuf      IN OUT NOCOPY VARCHAR2,
     retcode        IN OUT  NOCOPY VARCHAR2,
     p_obj_name      IN VARCHAR2
  ) IS
  l_proc   VARCHAR2(100);

  BEGIN
    g_pkg := 'bil.patch.115.sql.BIL_BI_PURGE_OBJ_PKG.';
    l_proc :=  'TRUNC_OBJ.';

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_PROCEDURE,
        p_module     => g_pkg || l_proc || 'begin',
        p_msg     => 'Start of Procedure '|| l_proc
      );
     END IF;
  errbuf := NULL;
  retcode := 0;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT)  THEN
    bil_bi_util_collection_pkg.writeLog
    (p_log_level => fnd_log.LEVEL_STATEMENT,
    p_module => g_pkg || l_proc || 'End',
    p_msg => 'p_obj_name =>'||p_obj_name);
  END IF;

  CASE p_obj_name
    WHEN 'OPDTL_F' THEN
         -- Truncate Opportunity Detail Summary Objects
          bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_OPDTL_F');
          bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_OPDTL_STG');
          bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_CURRENCY_RATE');

         -- Delete references from BIS_REFRESH_LOG table
         BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_' || p_obj_name );

    WHEN 'FST_DTL_F' THEN

         -- Truncate Forecast Summary Objects
         bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_FST_DTL_F');
         bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_FST_DTL_STG');
         bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_NEW_FST_ID');
         bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PROCESSED_FST_ID');
         bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_CURRENCY_RATE');

        -- Delete references from BIS_REFRESH_LOG table
        BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_' || p_obj_name );

    WHEN 'CURRENCY' THEN
         bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_CURRENCY_RATE');

    WHEN 'PIPELINE_F' THEN
        -- Truncate Pipeline Summary Objects
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PIPELINE_F');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PIPELINE_STG');
        -- asolaiy added for 8.0.
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PIPEC_F');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_OPDTL_DENLOG_TMP');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_DENLOG_STG');

        -- Delete references from BIS_REFRESH_LOG table
        BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_PIPELINE_F');
        -- asolaiy added for 8.0. New current fact table.
        BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_PIPEC_F');

    WHEN 'ALL' THEN

        -- Truncate Opportunity Detail Summary Objects
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_OPDTL_F');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_OPDTL_STG');
        -- Delete references from BIS_REFRESH_LOG table
        BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_' || 'OPDTL_F');

        -- Truncate Forecast Summary Objects
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_FST_DTL_F');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_FST_DTL_STG');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_NEW_FST_ID');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PROCESSED_FST_ID');

        -- Delete references from BIS_REFRESH_LOG table
        BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_' || 'FST_DTL_F');

        -- Truncate Pipeline Summary Objects
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PIPELINE_F');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PIPELINE_STG');
        -- asolaiy added for 8.0.
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_PIPEC_F');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_OPDTL_DENLOG_TMP');
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_DENLOG_STG');

        -- Delete references from BIS_REFRESH_LOG table
        BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_PIPELINE_F');
        -- asolaiy added for 8.0. New current fact table.
        BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_PIPEC_F');

        -- Truncate Currency Table
        bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_CURRENCY_RATE');


    ELSE
        NULL;
  END CASE;
  COMMIT;

       retcode := 0;
       errbuf := 'Truncated ' || p_obj_name ||
        ' Object(s) successfully' ;

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
                             p_module => g_pkg || l_proc || 'End',
                                p_msg => 'End of Procedure '||l_proc
                                  );
       END IF;
   EXCEPTION
      WHEN OTHERS THEN
       g_retcode := -2;
   fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
       fnd_message.set_token('Error is : ' ,SQLCODE);
   fnd_message.set_token('Reason is : ', SQLERRM);
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
             p_module => g_pkg || l_proc || 'proc_error',
             p_msg => fnd_message.get,
            p_force_log => TRUE
            );
     END IF;
    g_errbuf := sqlerrm;
    retcode := g_retcode;
    errbuf := g_errbuf ;
   END trunc_obj;


-- **********************************************************************
--  PROCEDURE Purge_Obj
--
--  Purpose:
--  To Purge the data from the BIL database object
--    This main procedure is called from the Concurrent Program
--   'Delete Partial Data from Sales Intelligence Object'
-- **********************************************************************

   PROCEDURE purge_obj
   (
      errbuf        IN OUT NOCOPY VARCHAR2,
      retcode       IN OUT  NOCOPY VARCHAR2,
      p_obj_name    IN VARCHAR2,
      p_end_date    IN VARCHAR2
   ) IS

   l_stmt   VARCHAR2(400);
   l_proc  VARCHAR2(100) ;

   BEGIN
    g_pkg := 'bil.patch.115.sql.BIL_BI_PURGE_OBJ_PKG.';
    l_proc := 'PURGE_OBJ.';
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module     => g_pkg || l_proc || 'begin',
              p_msg     => 'Start of Procedure '|| l_proc
              );
   END IF;

   errbuf := NULL;
   retcode := 0;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
           p_module => g_pkg || l_proc ,
           p_msg => 'p_obj_name =>'||p_obj_name||' p_end_date => '||p_end_date);
   END IF;

   g_end_date := TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS');

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
           p_module => g_pkg || l_proc ,
            p_msg => ' g_end_date => '||g_end_date);
   END IF;

   g_end_date_timeid := TO_NUMBER(TO_CHAR(TRUNC(TO_DATE(p_end_date, 'YYYY/MM/DD HH24:MI:SS')),'J'));

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
           p_module => g_pkg || l_proc ,
            p_msg => ' g_end_date_timid => '||g_end_date_timeid);
       END IF;

     CASE p_obj_name

       WHEN 'OPDTL_F' THEN
        -- Purge Opportunity Detail Summary Objects
        opdtl_f_purge;
       WHEN 'FST_DTL_F' THEN
        -- Purge Forecast Summary Objects
        fst_dtl_f_purge;
       WHEN 'PIPELINE_F' THEN
        -- Purge Pipeline Summary Objects
        pipeline_f_purge;
       WHEN 'ALL' THEN
        -- Purge Opportunity Detail Summary Objects
        opdtl_f_purge;
        -- Purge Forecast Summary Objects
        fst_dtl_f_purge;
        -- Purge Pipeline Summary Objects
        pipeline_f_purge;
       ELSE
    NULL;
     END CASE;

     COMMIT;

     g_retcode := 0;
     g_status := TRUE;
     errbuf := 'Purged ' || p_obj_name ||
               ' Object(s) successfully upto date ' || g_end_date;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
                             p_module => g_pkg || l_proc || 'End',
                                p_msg => 'End of Procedure '||l_proc
                                  );
    END IF;

  EXCEPTION
      WHEN OTHERS THEN
   ROLLBACK;
       g_retcode := -2;
   g_errbuf := sqlerrm;
    clean_up;
   retcode := g_retcode;
   errbuf  := g_errbuf;
   fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
       fnd_message.set_token('Error is : ' ,SQLCODE);
   fnd_message.set_token('Reason is : ', SQLERRM);
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
               p_module => g_pkg || l_proc || 'proc_error',
               p_msg => fnd_message.get,
            p_force_log => TRUE
              );
   END IF;
  END purge_obj;

-- **********************************************************************
--  PROCEDURE opdtl_f_purge
--
--  Purpose:
--  To purge data from the Opportunity Detail Summary Objects
--  for dates less than End date
--
-- **********************************************************************

   PROCEDURE opdtl_f_purge IS

  l_proc           VARCHAR2(100);
      l_cnt              NUMBER;

   BEGIN
    l_proc := 'OPDTL_F_PURGE.';
    l_cnt := 0;
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module     => g_pkg || l_proc || 'begin',
              p_msg     => 'Start of Procedure '|| l_proc
              );
   END IF;
  -- Initialize the Global Variables
  init(p_obj_name => 'OPDTL_F');

  -- Delete records from Staging Table where Eff Dt/Cre Dt/Cnv Dt less than End Date

      SELECT COUNT(1)
    INTO l_cnt
        FROM bil_bi_opdtl_stg;

      IF l_cnt > 0 THEN
     DELETE FROM bil_bi_opdtl_stg
    WHERE opty_creation_date <= g_end_date
      AND effective_date <= g_end_date
      AND (opty_ld_conversion_date <= g_end_date
          OR opty_ld_conversion_date IS NULL)
      AND close_date <= g_end_date; -- added asolaiy after forecast date changes.
      END IF;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
        p_module => g_pkg || l_proc ,
                p_msg => ' Opdtl Stg Tbl records Deleted :'||SQL%ROWCOUNT);
      END IF;


  -- Delete records from Sumry Table where Eff Dt/Cre Dt/Cnv Dt less than End Date

   DELETE FROM bil_bi_opdtl_f
  WHERE opty_creation_time_id <= g_end_date_timeid
    AND opty_close_time_id <= g_end_date_timeid
    AND (opty_ld_conversion_time_id <= g_end_date_timeid
        OR opty_ld_conversion_time_id IS NULL)
    AND opty_effective_time_id <= g_end_date_timeid; -- added asolaiy for forecast date changes.

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
        p_module => g_pkg || l_proc ,
                p_msg => ' Opdtl_f Summary Tbl records Deleted :'||SQL%ROWCOUNT);
      END IF;

  g_row_num := SQL%ROWCOUNT;

  COMMIT;

   -- Analyze the Tables
  bil_bi_util_collection_pkg.analyze_table(p_tbl_name => 'BIL_BI_OPDTL_F',
                     p_cascade => TRUE,
                              p_est_pct => 10 ,
                              p_granularity => 'GLOBAL');
  g_status := TRUE;
  g_retcode := 0;
  -- Call BIS wrap up and clean up
         clean_up;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
                             p_module => g_pkg || l_proc || 'End',
                             p_msg => 'End of Procedure '||l_proc
                                    );
  END IF;
   EXCEPTION
      WHEN OTHERS THEN
     ROLLBACK;
         g_retcode := -2;
     g_status := FALSE;
     g_errbuf := sqlerrm ;
     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
         fnd_message.set_token('Error is : ' ,SQLCODE);
     fnd_message.set_token('Reason is : ', SQLERRM);
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
               p_module => g_pkg || l_proc || 'proc_error',
               p_msg => fnd_message.get,
            p_force_log => TRUE
              );
     END IF;
   END opdtl_f_purge;


-- **********************************************************************
--  PROCEDURE pipeline_f_purge
--
--  Purpose:
--  To purge data from the Pipeline Summary Objects
--  for dates less than End date
--
-- **********************************************************************

   PROCEDURE pipeline_f_purge IS

  l_proc           VARCHAR2(100);
  l_cnt            NUMBER;

   BEGIN
     l_proc           := 'PIPELINE_F_PURGE.';
     l_cnt            := 0;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_PROCEDURE,
        p_module     => g_pkg || l_proc || 'begin',
        p_msg     => 'Start of Procedure '|| l_proc
      );
    END IF;

    -- Initialize the Global Variables
    init(p_obj_name => 'PIPELINE_F');

    -- asolaiy added for 8.0
    init(p_obj_name => 'PIPEC_F');


    -- Delete records from Staging Table where Snap Dt less than End Date
    SELECT COUNT(1)
    INTO l_cnt
    FROM bil_bi_pipeline_stg;

    IF l_cnt > 0 THEN
      DELETE FROM bil_bi_pipeline_stg
      WHERE snap_date <= g_end_date;
    END IF;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
        p_module => g_pkg || l_proc ,
        p_msg => ' Pipeline Stg Tbl records Deleted :'||SQL%ROWCOUNT);
    END IF;

    -- Delete records from Sumry Table where Snap Dt less than End Date

    DELETE FROM bil_bi_pipeline_f
    WHERE snap_date <= g_end_date;


    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
        p_module => g_pkg || l_proc ,
        p_msg => ' Pipeline_f Summary Tbl records Deleted :'||SQL%ROWCOUNT);
    END IF;

    g_row_num := SQL%ROWCOUNT;

    -- asolaiy added for 8.0
    DELETE FROM bil_bi_pipec_f
    WHERE snap_date <= g_end_date;


    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
        p_module => g_pkg || l_proc ,
        p_msg => ' Pipec_f Summary Tbl records Deleted :'||SQL%ROWCOUNT);
    END IF;

    g_row_num := g_row_num+SQL%ROWCOUNT;


    COMMIT;

    -- Analyze the Tables
   bil_bi_util_collection_pkg.analyze_table
   (
     p_tbl_name => 'BIL_BI_PIPELINE_F',
     p_cascade => TRUE,
     p_est_pct => 10 ,
     p_granularity => 'GLOBAL'
   );

    -- asolaiy added for 8.0. Analyze the Table
   bil_bi_util_collection_pkg.analyze_table
   (
     p_tbl_name => 'BIL_BI_PIPEC_F',
     p_cascade => TRUE,
     p_est_pct => 10 ,
     p_granularity => 'GLOBAL'
   );

   g_status := TRUE;
   g_retcode := 0;

   -- Call BIS wrap up and clean up
   clean_up;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
                              p_module => g_pkg || l_proc || 'End',
                              p_msg => 'End of Procedure '||l_proc
                                     );
   END IF;

 EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        g_retcode := -2;
        g_status := FALSE;
        g_errbuf := sqlerrm ;
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
        fnd_message.set_token('Error is : ' ,SQLCODE);
        fnd_message.set_token('Reason is : ', SQLERRM);
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
          bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
               p_module => g_pkg || l_proc || 'proc_error',
               p_msg => fnd_message.get,
            p_force_log => TRUE);
        END IF;

END pipeline_f_purge;


-- **********************************************************************
--  PROCEDURE fst_dtl_f_purge
--
--  Purpose:
--  To purge data from the Forecast Summary Objects
--  for dates less than End date
--
-- **********************************************************************

    PROCEDURE fst_dtl_f_purge IS

      l_stmt      VARCHAR2(3000);
      l_end_dt_ent_year_id    NUMBER;
      l_end_dt_ent_qtr_id    NUMBER;
      l_end_dt_ent_per_id    NUMBER;
      l_end_dt_week_id    NUMBER;
      l_list              DBMS_SQL.VARCHAR2_TABLE;
      l_val              DBMS_SQL.VARCHAR2_TABLE;
      l_proc       VARCHAR2(100);

  BEGIN
        l_proc        := 'FST_DTL_F_PURGE.';
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
              p_module     => g_pkg || l_proc || 'begin',
              p_msg     => 'Start of Procedure '|| l_proc
              );
  END IF;

  -- Initialize the WHO Variables
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
       p_module => g_pkg || l_proc ,
           p_msg => ' Initialize the WHO Variables ');
     END IF;

  init(p_obj_name => 'FST_DTL_F');

     -- List of Profile for setup check
       l_list(1) := 'BIL_BI_MAP_ENT_FST_PERIOD_TYPE';
  l_list(2) := 'BIL_BI_FST_ROLLUP';
  --l_list(3) := 'BIL_BI_ASN_IMPLEMENTED';

    l_list(3) := 'ASN_FRCST_FORECAST_CALENDAR';


    IF (NOT bis_common_parameters.check_global_parameters(l_list)) THEN  -- Check Parameters
        bis_common_parameters.get_global_parameters(l_list, l_val);
        fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
            p_module => g_pkg || l_proc || 'proc_error',
            p_msg => fnd_message.get,
            p_force_log => TRUE);
   FOR v_counter IN 1..3 LOOP
        IF (l_val(v_counter) IS  NULL) THEN
      fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
      fnd_message.set_token('PROFILE_USER_NAME' ,
            bil_bi_util_collection_pkg.get_user_profile_name(l_list(v_counter)));
      fnd_message.set_token('PROFILE_INTERNAL_NAME' ,l_list(v_counter));
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
              p_module => g_pkg || l_proc || 'proc_error',
              p_msg => fnd_message.get,
              p_force_log => TRUE);
      END IF;
   END LOOP;
   RAISE G_SETUP_VALID_ERROR;
    ELSE
       bis_common_parameters.get_global_parameters(l_list, l_val);
    END IF; -- Check Parameters Ends Here

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
       p_module => g_pkg || l_proc ,
               p_msg => 'l_val(1) = ' || l_val(1) || ' l_val(2)= ' || l_val(2) ||
            ' l_val(3)= ' || l_val(3));
     END IF;



   BEGIN

     IF UPPER(l_val(2)) NOT IN ('YES','Y') THEN
  CASE l_val(1)
    WHEN 'FII_TIME_ENT_YEAR' THEN
      SELECT ent_year_id
        INTO l_end_dt_ent_year_id
        FROM fii_time_ent_year
        WHERE start_date <= g_end_date
             AND end_date >= g_end_date;

           DELETE bil_bi_fst_dtl_f sumry
            WHERE forecast_time_id <= l_end_dt_ent_year_id
              AND forecast_period_type_id = 128;

    WHEN 'FII_TIME_ENT_QTR' THEN
      SELECT ent_qtr_id
          INTO l_end_dt_ent_qtr_id
          FROM fii_time_ent_qtr
        WHERE start_date <= g_end_date
             AND end_date >= g_end_date;

           DELETE bil_bi_fst_dtl_f sumry
            WHERE forecast_time_id <= l_end_dt_ent_qtr_id
              AND forecast_period_type_id = 64;

    WHEN 'FII_TIME_ENT_PERIOD' THEN

      SELECT ent_period_id
          INTO l_end_dt_ent_per_id
          FROM fii_time_ent_period
        WHERE start_date <= g_end_date
            AND end_date >= g_end_date;

           DELETE bil_bi_fst_dtl_f sumry
            WHERE  forecast_time_id <= l_end_dt_ent_per_id
              AND forecast_period_type_id = 32;

    WHEN 'FII_TIME_WEEK' THEN
      SELECT week_id
          INTO l_end_dt_week_id
          FROM fii_time_week
        WHERE start_date <= g_end_date
            AND end_date >= g_end_date;

           DELETE bil_bi_fst_dtl_f sumry
            WHERE  forecast_time_id <= l_end_dt_week_id
              AND forecast_period_type_id = 16;
        ELSE
       NULL;
  END CASE;
     ELSE  -- Fst Rollup is 'Yes'
   -- Get the Time Dimension ID for the End Date (Year)
    SELECT ent_year_id
      INTO l_end_dt_ent_year_id
        FROM fii_time_ent_year
     WHERE start_date <= g_end_date
       AND end_date >= g_end_date;
    -- Get the Time Dimension ID for the End Date (Quarter)
    SELECT ent_qtr_id
      INTO l_end_dt_ent_qtr_id
      FROM fii_time_ent_qtr
     WHERE start_date <= g_end_date
       AND end_date >= g_end_date;
    -- Get the Time Dimension ID for the End Date (Period)
    SELECT ent_period_id
      INTO l_end_dt_ent_per_id
      FROM fii_time_ent_period
     WHERE start_date <= g_end_date
       AND end_date >= g_end_date;
    -- Get the Time Dimension ID for the End Date (Week)
    SELECT week_id
      INTO l_end_dt_week_id
      FROM fii_time_week
     WHERE start_date <= g_end_date
       AND end_date >= g_end_date;

     l_stmt := ' l_end_dt_ent_year_id =>'||l_end_dt_ent_year_id||' '||
     ' l_end_dt_ent_qtr_id =>'||l_end_dt_ent_qtr_id||' '||
     ' l_end_dt_ent_period_id =>'||l_end_dt_ent_per_id||' '||
     ' l_end_dt_ent_week_id =>'||l_end_dt_week_id  ;

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
                    p_module => g_pkg || l_proc ,
                               p_msg => 'Parameters '||l_stmt);
         END IF;

       -- Delete records from Summary Table where Forecast Dt less than
       -- input End Date
        DELETE bil_bi_fst_dtl_f sumry
         WHERE  ((forecast_time_id <= l_end_dt_week_id
                  AND forecast_period_type_id = 16)
            OR  (forecast_time_id <= l_end_dt_ent_per_id
                 AND forecast_period_type_id = 32)
        OR  (forecast_time_id <= l_end_dt_ent_qtr_id
                 AND forecast_period_type_id = 64)
            OR  (forecast_time_id <= l_end_dt_ent_year_id
                AND forecast_period_type_id = 128));

        l_stmt := ' Summary Tbl records Eff Dt < End Dt Deleted';
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
                                         p_module => g_pkg || l_proc ,
                    p_msg => l_stmt|| ' '||SQL%ROWCOUNT);
        END IF;

     END IF; -- IF l_val(2) <> 'Yes' THEN

    EXCEPTION

       WHEN OTHERS THEN
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('Error is : ' ,SQLCODE);
      fnd_message.set_token('Reason is : ', SQLERRM);
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
                         p_module => g_pkg || l_proc || 'proc_error',
                  p_msg    => fnd_message.get,
                  p_force_log => TRUE);
      END IF;
    END;

  g_row_num := SQL%ROWCOUNT;

  DELETE FROM bil_bi_processed_fst_id
  WHERE forecast_id in ( SELECT intrnl.forecast_id f
                         FROM as_internal_forecasts intrnl,
                    gl_periods gl
               WHERE gl.period_name = intrnl.period_name
               AND gl.period_set_name = l_val(3)
                 AND gl.end_date <= g_end_date
             );
      l_stmt := ' Rows deleted from processed_fst_id table ';
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_STATEMENT,
                                         p_module => g_pkg || l_proc ,
                    p_msg => l_stmt|| ''||SQL%ROWCOUNT);
      END IF;
      bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_CURRENCY_RATE');
      bil_bi_util_collection_pkg.truncate_table(p_table_name => 'BIL_BI_FST_DTL_STG');
    -- Analyze the Tables
  bil_bi_util_collection_pkg.analyze_table(p_tbl_name => 'BIL_BI_FST_DTL_F',
                     p_cascade => TRUE,
                              p_est_pct => 10 ,
                              p_granularity => 'GLOBAL');
  bil_bi_util_collection_pkg.analyze_table(p_tbl_name => 'BIL_BI_FST_DTL_STG',
                     p_cascade => TRUE,
                              p_est_pct => 10 ,
                              p_granularity => 'GLOBAL');
    g_status := TRUE;
    g_retcode := 0;
    -- Call BIS wrap up and clean up
    clean_up;
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || 'End',
            p_msg => 'End of Procedure '||l_proc
                                   );
    END IF;
  EXCEPTION

     WHEN G_SETUP_VALID_ERROR THEN
         g_retcode := -1;
     g_status := FALSE;
     ROLLBACK;
     WHEN OTHERS THEN
       ROLLBACK;
       g_retcode := -2;
       g_status := FALSE;
       g_errbuf := sqlerrm ;
       fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
       fnd_message.set_token('Error is : ' ,SQLCODE);
       fnd_message.set_token('Reason is : ', SQLERRM);
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
               p_module    => g_pkg || l_proc || 'proc_error',
               p_msg       => fnd_message.get,
            p_force_log => TRUE
              );
       END IF;
  END fst_dtl_f_purge;


--  **********************************************************************
--  PROCEDURE init
--
--  Purpose:
--  To Initialize the Global Variables
--
--  **********************************************************************

PROCEDURE init(p_obj_name IN VARCHAR2) IS
  l_valid_setup BOOLEAN;
  l_stmt        VARCHAR2(3000);
        l_proc        VARCHAR2(100);
BEGIN
    l_valid_setup  := FALSE;
    l_proc         := 'INIT.';
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || 'begin',
            p_msg => 'Start of Procedure '||l_proc
                                   );
    END IF;

    g_errbuf := NULL;
    g_retcode := 0;
    g_debug := NVL(BIS_COLLECTION_UTILITIES.g_debug,FALSE);
    g_row_num    := 0;
    g_status    := FALSE;
    --g_obj_name   := p_obj_name;

    -- Delete references from BIS_REFRESH_LOG table
    BIS_COLLECTION_UTILITIES.deleteLogForObject(p_object_name => 'BIL_BI_' || p_obj_name || '_PURGE');

    -- Call generic Setup procedure
    l_valid_setup := BIS_COLLECTION_UTILITIES.SETUP(p_object_name => 'BIL_BI_'|| p_obj_name ||'_PURGE');

    IF l_valid_setup THEN
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_STATEMENT,
          p_module => g_pkg || l_proc  ||' BIS Setup ',
          p_msg => 'BIS Setup successful'
        );
      END IF;
    ELSE
      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_STATEMENT,
          p_module => g_pkg || l_proc  ||' BIS Setup ',
          p_msg => 'BIS Setup Failed'
        );
      END IF;
      g_retcode := 2;
      RETURN;
    END IF;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
                       p_module => g_pkg || l_proc || 'End',
                   p_msg => 'End of Procedure '||l_proc);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       g_retcode := -1;
       g_errbuf := sqlerrm ;
       fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
       fnd_message.set_token('Error is : ' ,SQLCODE);
       fnd_message.set_token('Reason is : ', SQLERRM);
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level => fnd_log.LEVEL_UNEXPECTED,
           p_module    => g_pkg || l_proc || 'proc_error',
           p_msg       => fnd_message.get,
           p_force_log => TRUE
         );
       END IF;

END init;


--  ***********************************************************************
--  PROCEDURE clean_up
--
--  Purpose:
--   To Wrap Up and Clean Up
--
--  ***********************************************************************

PROCEDURE clean_up IS
 l_proc  VARCHAR2(100);
BEGIN
    l_proc   := 'CLEAN_UP.';
   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
            p_module => g_pkg || l_proc || 'begin',
            p_msg => 'Start of Procedure '||l_proc
                                   );
    END IF;
    -- Wrap up the BIS set up
    IF g_status THEN
       BIS_COLLECTION_UTILITIES.wrapup(p_status => TRUE,
                p_count => g_row_num,
                    p_message => NULL,
          p_period_from => NULL,
            p_period_to => g_end_date);
     ELSE
        BIS_COLLECTION_UTILITIES.wrapup(p_status => FALSE,
           p_count => 0,
               p_message => NULL,
           p_period_from => NULL,
             p_period_to => g_end_date);
     END IF;
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE)  THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_PROCEDURE,
                                         p_module => g_pkg || l_proc || 'End',
                    p_msg => 'End of Procedure '||l_proc);
     END IF;
EXCEPTION
  WHEN OTHERS THEN
     g_retcode := -1;
     g_errbuf := sqlerrm;
     fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
         fnd_message.set_token('Error is : ' ,SQLCODE);
     fnd_message.set_token('Reason is : ', SQLERRM);
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_UNEXPECTED) THEN
         bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
               p_module => g_pkg || l_proc || 'proc_error',
               p_msg => fnd_message.get,
            p_force_log => TRUE
              );
     END IF;
END clean_up;


END bil_bi_purge_obj_pkg;

/
