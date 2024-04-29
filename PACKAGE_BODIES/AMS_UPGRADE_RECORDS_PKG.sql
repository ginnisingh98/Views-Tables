--------------------------------------------------------
--  DDL for Package Body AMS_UPGRADE_RECORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_UPGRADE_RECORDS_PKG" AS
-- $Header: amsvupdb.pls 120.0 2006/06/29 06:21:22 batoleti noship $


PROCEDURE AMS_UPG_METRIC_HST_RECS_MGR (
                    X_errbuf     out NOCOPY varchar2,
                    X_retcode    out NOCOPY varchar2,
                    X_batch_size  in number,
                    X_Num_Workers in number
                   ) IS

 BEGIN
	  --
	  -- Manager processing.
	  -- using dynamic sql, manager(submit_subrequests) calls the worker process(AMSUPGHISTORYRECSWKR).
	  --
	  AD_CONC_UTILS_PKG.submit_subrequests(
		 X_errbuf=>X_errbuf,
		 X_retcode=>X_retcode,
		 X_WorkerConc_app_shortname=>'AMS',
		 X_WorkerConc_progname=>'AMSUPGHISTORYRECSWKR',
		 X_batch_size=>X_batch_size,
		 X_Num_Workers=>X_Num_Workers);

   END AMS_UPG_METRIC_HST_RECS_MGR;



PROCEDURE AMS_UPG_METRIC_HST_RECS_WKR (
                  X_errbuf     out NOCOPY varchar2,
                  X_retcode    out NOCOPY varchar2,
                  l_batch_size  in number,
                  l_Worker_Id   in number,
                  l_Num_Workers in number
                ) IS





-- specify the table name and col name.
  l_table_name          varchar2(30) := 'AMS_ACT_METRIC_HST';
  l_column_name         varchar2(30) := 'ACTIVITY_METRIC_ID';


-- The following variables are required to check for the existinace of DBschema and table.

  l_product             varchar2(30) := 'AMS';
  l_status              varchar2(30);
  l_industry            varchar2(30);
  l_retstatus           boolean;
  l_table_owner         varchar2(30);

  --
  -- the APIs use a combination of TABLE_NAME and UPDATE_NAME to track an
  -- update. The update should be a no-op on a rerun, provided the TABLE_NAME
  -- and UPDATE_NAME do not change.
  --
  -- If you have modified the script and you want the
  -- script to reprocess the data, you must modify UPDATE_NAME to reflect
  -- the change.
  -- Now the ver# 120.9 so keeping the update_name as 'sqlscriptname_8.sql'.
  --

  l_update_name     varchar2(500) := 'amsupamh_9.sql';

  l_start_id            number;
  l_end_id              number;
  l_rows_processed      number := 0;
  l_any_rows_to_process boolean;
  l_row_counts          number := 0;



BEGIN


     --
     -- get schema name of the table for ID range processing
     --
     l_retstatus := fnd_installation.get_app_info(
                        l_product, l_status, l_industry, l_table_owner);

     IF ((l_retstatus = FALSE)
         OR
         (l_table_owner is null))
     THEN
        raise_application_error(-20001,
           'Cannot get schema name for product : '||l_product);
     END IF;

     --
     -- Worker processing
     --

      ad_parallel_updates_pkg.initialize_id_range(
            ad_parallel_updates_pkg.ID_RANGE,
            l_table_owner,
            l_table_name,
            l_update_name,
	    l_column_name,
            l_worker_id,
            l_num_workers,
            l_batch_size, 0);

   ad_parallel_updates_pkg.get_id_range(
            l_start_id,
            l_end_id,
            l_any_rows_to_process,
            l_batch_size,
            TRUE);

   WHILE (l_any_rows_to_process = TRUE)
   LOOP

       -- Update all first history records to have delta := value.
       -- This update is to avoid 'N/A' in BIM DBI reports.

       UPDATE ams_act_metric_hst
       SET FUNC_FORECASTED_DELTA = nvl(FUNC_FORECASTED_VALUE,0),
           FUNC_ACTUAL_DELTA = nvl(FUNC_ACTUAL_VALUE,0)
       WHERE (ACTIVITY_METRIC_ID, last_update_date) IN
             (SELECT ACTIVITY_METRIC_ID, MIN(last_update_date)
              FROM ams_act_metric_hst
              GROUP BY ACTIVITY_METRIC_ID)
        AND(NVL(FUNC_FORECASTED_DELTA,0) <> NVL(FUNC_FORECASTED_VALUE,0)
             OR NVL(FUNC_ACTUAL_DELTA,0) <> NVL(FUNC_ACTUAL_VALUE,0))
        AND  ACTIVITY_METRIC_ID BETWEEN l_start_id AND l_end_id;


       -- delete where duplicate last_update_dates and not in activity table.
       -- delete the duplicate records for a given last_update_date.


      DELETE
      FROM ams_act_metric_hst  hst
      WHERE (activity_metric_id, last_update_date) IN (SELECT activity_metric_id,last_update_date
                                                       FROM ams_act_metric_hst A
                                                       WHERE ROWID < (SELECT MAX(ROWID)
                                                                      FROM ams_act_metric_hst B
                                                                      WHERE A.activity_metric_id = B.activity_metric_id
	 		                                               AND TRUNC(a.last_update_date)= TRUNC(b.last_update_date)
                                                                      )
                                                       )
      AND NOT EXISTS (SELECT 1
                      FROM ams_act_metrics_all c
                      WHERE hst.activity_metric_id = c.activity_metric_id)
      AND hst.activity_metric_id BETWEEN l_start_id AND l_end_id;




      -- if the record was deleted but the history does not show zero for the last
      -- entry then insert a history record one day after the last entry.

         INSERT INTO ams_act_metric_hst
 		   (ACT_MET_HST_ID,
 		    ACTIVITY_METRIC_ID,
 		    LAST_UPDATE_DATE,
 		    LAST_UPDATED_BY,
 		    CREATION_DATE,
 		    CREATED_BY,
 		    LAST_UPDATE_LOGIN,
 		    OBJECT_VERSION_NUMBER,
 		    ACT_METRIC_USED_BY_ID,
 		    ARC_ACT_METRIC_USED_BY,
 		    APPLICATION_ID,
 		    METRIC_ID,
 		    TRANSACTION_CURRENCY_CODE,
 		    TRANS_FORECASTED_VALUE,
 		    TRANS_COMMITTED_VALUE,
 		    TRANS_ACTUAL_VALUE,
 		    FUNCTIONAL_CURRENCY_CODE,
 		    FUNC_FORECASTED_VALUE,
 		    FUNC_COMMITTED_VALUE,
 		    DIRTY_FLAG,
 		    FUNC_ACTUAL_VALUE,
 		    LAST_CALCULATED_DATE,
		    VARIABLE_VALUE,
		    COMPUTED_USING_FUNCTION_VALUE,
		    METRIC_UOM_CODE,
		    ORG_ID,
		    DIFFERENCE_SINCE_LAST_CALC,
		    ACTIVITY_METRIC_ORIGIN_ID,
		    ARC_ACTIVITY_METRIC_ORIGIN,
		    DAYS_SINCE_LAST_REFRESH,
		    SUMMARIZE_TO_METRIC,
		    ROLLUP_TO_METRIC,
		    SCENARIO_ID,
		    ATTRIBUTE_CATEGORY,
		    ATTRIBUTE1,
		    ATTRIBUTE2,
		    ATTRIBUTE3,
		    ATTRIBUTE4,
		    ATTRIBUTE5,
		    ATTRIBUTE6,
		    ATTRIBUTE7,
		    ATTRIBUTE8,
		    ATTRIBUTE9,
		    ATTRIBUTE10,
		    ATTRIBUTE11,
		    ATTRIBUTE12,
		    ATTRIBUTE13,
		    ATTRIBUTE14,
		    ATTRIBUTE15,
		    SECURITY_GROUP_ID,
		    FUNC_FORECASTED_DELTA,
		    FUNC_ACTUAL_DELTA,
		    DESCRIPTION,
		    ACT_METRIC_DATE,
		    ARC_FUNCTION_USED_BY,
		    FUNCTION_USED_BY_ID,
		    PURCHASE_REQ_RAISED_FLAG,
		    SENSITIVE_DATA_FLAG,
		    BUDGET_ID,
		    FORECASTED_VARIABLE_VALUE,
		    HIERARCHY_ID,
		    PUBLISHED_FLAG,
		    PRE_FUNCTION_NAME,
		    POST_FUNCTION_NAME,
		    START_NODE,
		    FROM_LEVEL,
		    TO_LEVEL,
		    FROM_DATE,
		    TO_DATE,
		    AMOUNT1,
		    AMOUNT2,
		    AMOUNT3,
		    PERCENT1,
		    PERCENT2,
		    PERCENT3,
		    STATUS_CODE,
		    ACTION_CODE,
		    METHOD_CODE,
		    BASIS_YEAR,
		    EX_START_NODE,
		    HIERARCHY_TYPE,
		    DEPEND_ACT_METRIC)
	    SELECT AMS_ACT_METRIC_HST_S.NEXTVAL,
			    a.ACTIVITY_METRIC_ID,
			    a.LAST_UPDATE_DATE + 1 AS LAST_UPDATE_DATE,
			    a.LAST_UPDATED_BY,
			    a.CREATION_DATE,
			    a.CREATED_BY,
			    a.LAST_UPDATE_LOGIN,
			    a.OBJECT_VERSION_NUMBER,
			    a.ACT_METRIC_USED_BY_ID,
			    a.ARC_ACT_METRIC_USED_BY,
			    a.APPLICATION_ID,
			    a.METRIC_ID,
			    a.TRANSACTION_CURRENCY_CODE,
			    0 AS TRANS_FORECASTED_VALUE,
			    0 AS TRANS_COMMITTED_VALUE,
			    0 AS TRANS_ACTUAL_VALUE,
			    a.FUNCTIONAL_CURRENCY_CODE,
			    0 AS FUNC_FORECASTED_VALUE,
			    0 AS FUNC_COMMITTED_VALUE,
			    a.DIRTY_FLAG,
			    0 AS FUNC_ACTUAL_VALUE,
			    a.LAST_CALCULATED_DATE,
			    NULL AS VARIABLE_VALUE,
			    a.COMPUTED_USING_FUNCTION_VALUE,
			    a.METRIC_UOM_CODE,
			    a.ORG_ID,
			    a.DIFFERENCE_SINCE_LAST_CALC,
			    a.ACTIVITY_METRIC_ORIGIN_ID,
			    a.ARC_ACTIVITY_METRIC_ORIGIN,
			    a.DAYS_SINCE_LAST_REFRESH,
			    a.SUMMARIZE_TO_METRIC,
			    a.ROLLUP_TO_METRIC,
			    a.SCENARIO_ID,
			    a.ATTRIBUTE_CATEGORY,
			    a.ATTRIBUTE1,
			    a.ATTRIBUTE2,
			    a.ATTRIBUTE3,
			    a.ATTRIBUTE4,
			    a.ATTRIBUTE5,
			    a.ATTRIBUTE6,
			    a.ATTRIBUTE7,
			    a.ATTRIBUTE8,
			    a.ATTRIBUTE9,
			    a.ATTRIBUTE10,
			    a.ATTRIBUTE11,
			    a.ATTRIBUTE12,
			    a.ATTRIBUTE13,
			    a.ATTRIBUTE14,
			    a.ATTRIBUTE15,
			    a.SECURITY_GROUP_ID,
			    -NVL(a.FUNC_FORECASTED_VALUE,0) AS FUNC_FORECASTED_DELTA,
			    -NVL(a.FUNC_ACTUAL_VALUE,0) AS FUNC_ACTUAL_DELTA,
			    a.DESCRIPTION,
			    a.ACT_METRIC_DATE,
			    a.ARC_FUNCTION_USED_BY,
			    a.FUNCTION_USED_BY_ID,
			    a.PURCHASE_REQ_RAISED_FLAG,
			    a.SENSITIVE_DATA_FLAG,
			    a.BUDGET_ID,
			    NULL AS FORECASTED_VARIABLE_VALUE,
			    a.HIERARCHY_ID,
			    a.PUBLISHED_FLAG,
			    a.PRE_FUNCTION_NAME,
			    a.POST_FUNCTION_NAME,
			    a.START_NODE,
			    a.FROM_LEVEL,
			    a.TO_LEVEL,
			    a.FROM_DATE,
			    a.TO_DATE,
			    a.AMOUNT1,
			    a.AMOUNT2,
			    a.AMOUNT3,
			    a.PERCENT1,
			    a.PERCENT2,
			    a.PERCENT3,
			    a.STATUS_CODE,
			    a.ACTION_CODE,
			    a.METHOD_CODE,
			    a.BASIS_YEAR,
			    a.EX_START_NODE,
			    a.HIERARCHY_TYPE,
			    a.DEPEND_ACT_METRIC
          FROM ams_act_metric_hst a
         WHERE NOT EXISTS (SELECT 'x' FROM ams_act_metrics_all b
                            WHERE a.activity_metric_id = b.activity_metric_id)
            AND last_update_date =
                (SELECT MAX(c.last_update_date)
                 FROM ams_act_metric_hst c
                 WHERE c.activity_metric_id = a.activity_metric_id)
            AND (NVL(func_actual_value,0) <> 0 OR NVL(func_forecasted_value,0) <> 0)
	    AND  a.activity_metric_id BETWEEN l_start_id AND l_end_id;


    l_rows_processed := SQL%ROWCOUNT;

    ad_parallel_updates_pkg.processed_id_range(
                         l_rows_processed,
                         l_end_id);


    --
    -- commit transaction here
    --

        commit;

   --
   -- Get the next id range
   --

   ad_parallel_updates_pkg.get_id_range(
                        l_start_id,
                        l_end_id,
                        l_any_rows_to_process,
                        l_batch_size,
                        FALSE);

  END LOOP;/*For WHILE loop */


 --
 -- commit transaction here
 --

   COMMIT;

   X_retcode := AD_CONC_UTILS_PKG.CONC_SUCCESS;

 EXCEPTION
     WHEN OTHERS THEN
        X_retcode := AD_CONC_UTILS_PKG.CONC_FAIL;
        raise;

END AMS_UPG_METRIC_HST_RECS_WKR;

END;

/
