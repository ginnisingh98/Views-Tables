--------------------------------------------------------
--  DDL for Package Body BIL_BI_PIPELINE_F_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIL_BI_PIPELINE_F_PKG" AS
/*$Header: bilbpipb.pls 120.32.12010000.3 2008/12/02 05:44:53 annsrini ship $*/

 G_global_start_date    DATE;
 G_request_id         NUMBER;
 G_appl_id        NUMBER;
 G_program_id        NUMBER;
 G_user_id        NUMBER;
 G_login_id        NUMBER;
 g_row_num        NUMBER;
 g_prim_currency        VARCHAR2(10);
 g_prim_rate_type       VARCHAR2(15);

 G_sec_Currency         VARCHAR2(10);
 G_sec_Rate_Type        VARCHAR2(15);


 g_credit_type_id       VARCHAR2(10);
 g_pkg       VARCHAR2(100);
 g_setup_error_flag    BOOLEAN;
 g_program_start        DATE;


 G_BIS_SETUP_ERROR  EXCEPTION;
 G_SETUP_VAL_ERROR  EXCEPTION;
 G_INVALID_DIM    EXCEPTION;



 PROCEDURE Summary_Err_Check(p_mode IN varchar2,
 			     x_valid_curr OUT NOCOPY VARCHAR2,
                               x_valid_date OUT NOCOPY VARCHAR2,
                               x_valid_prod OUT NOCOPY VARCHAR2,
                               x_return_warn OUT NOCOPY VARCHAR2
                               );

 PROCEDURE Summary_Err_Check_SmallGap(x_valid_curr OUT NOCOPY VARCHAR2,
                            x_valid_date OUT NOCOPY VARCHAR2,
                            x_valid_prod OUT NOCOPY VARCHAR2,
                            x_return_warn OUT NOCOPY VARCHAR2);

 PROCEDURE Build_BaseLine(p_start_date IN DATE);

 PROCEDURE Build_Denlog(p_start_date IN DATE, p_end_date IN DATE, p_coll_start IN DATE,p_mode IN varchar2);

 PROCEDURE Gap_Fill(p_start_date IN DATE, p_end_date IN DATE, p_curr_coll_start IN DATE
 , p_mode IN VARCHAR2, p_small_gap IN BOOLEAN);

 PROCEDURE Populate_Currency_Rate(p_mode IN varchar2);

 PROCEDURE Populate_Curr_Rate_SmallGap;

 PROCEDURE Report_Missing_Rates;

 PROCEDURE Report_Profile_Error (p_profile_name IN varchar2,
          p_value IN varchar2,
          p_exp_value IN varchar2) ;

 PROCEDURE Report_Missing_Profile (p_profile_name IN varchar2) ;

 PROCEDURE Insert_Into_Summary(p_mode IN varchar2);

 FUNCTION get_first_success_period(p_object_name in varchar2) return varchar2 ;

 FUNCTION get_number_of_runs( p_object_name in varchar2) return number;

FUNCTION get_start_curr_coll return date;

FUNCTION is_date_end_of_prd(p_date IN DATE) return boolean;

PROCEDURE populate_hist_dates(p_start_date IN DATE, p_end_date IN DATE);

PROCEDURE delete_from_curr(p_curr_coll_start IN DATE);

PROCEDURE Insert_Into_Curr_sumry(p_date IN DATE, p_week IN NUMBER, p_period IN NUMBER,
		  						 p_qtr IN NUMBER, p_year IN NUMBER, p_min_date_id IN NUMBER,
								 p_max_date_id IN NUMBER);

PROCEDURE Ins_Into_CurrSum_SmGap(p_date IN DATE, p_week IN NUMBER, p_period IN NUMBER,
		  						 p_qtr IN NUMBER, p_year IN NUMBER, p_min_date_id IN NUMBER,
								 p_max_date_id IN NUMBER);

PROCEDURE get_period_ids(p_date IN DATE,
		  				 x_day OUT NOCOPY NUMBER,
		  			     x_week OUT NOCOPY NUMBER,
						 x_period OUT NOCOPY NUMBER,
						 x_qtr OUT NOCOPY NUMBER,
						 x_year OUT NOCOPY NUMBER,
						 x_min_date_id OUT NOCOPY NUMBER,
						 x_max_date_id OUT NOCOPY NUMBER);


PROCEDURE Insert_Into_Stg_SmallGap(p_start_date IN DATE, p_end_date IN DATE, p_first_fact_run IN DATE);

   PROCEDURE Load
     (
       errbuf              IN OUT NOCOPY VARCHAR2,
       retcode             IN OUT NOCOPY VARCHAR2,
       p_start_date        IN   VARCHAR2,
       p_truncate          IN   VARCHAR2
     );

PROCEDURE Populate_Curr_Rate_SmallGap IS
  l_proc     VARCHAR2(100);
 BEGIN
 l_proc  := 'Populate_Currency_Rate_SmallGap';
 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;


     MERGE INTO BIL_BI_CURRENCY_RATE sumry
     USING
     (
       SELECT
         txn_currency,
         effective_date,
         DECODE(txn_currency,g_prim_currency,1,fii_currency.get_global_rate_primary(txn_currency,
                                                            trunc(least(sysdate,effective_date)))) prate,
         DECODE(g_sec_currency,NULL,NULL,decode(txn_currency,g_sec_currency,1,
           fii_currency.get_global_rate_secondary(txn_currency,trunc(least(sysdate,effective_date))))) srate
       FROM
       (
         SELECT
           DISTINCT txn_currency,
           effective_date
         FROM
           bil_bi_pipeline_stg stg
       )
     ) rates
     ON
     (
       rates.txn_currency = sumry.currency_code
       AND rates.effective_date = sumry.exchange_date
     )
     WHEN MATCHED THEN
       UPDATE SET sumry.exchange_rate = rates.prate,sumry.exchange_rate_s = rates.srate
     WHEN NOT MATCHED THEN
       INSERT
       (
         sumry.currency_code,
         sumry.exchange_date,
         sumry.exchange_rate,
         sumry.exchange_rate_s
       )
       VALUES
       (
         rates.txn_currency,
         rates.effective_date,
         rates.prate,
         rates.srate
       );
  commit;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    p_module => g_pkg || l_proc ,
    p_msg => 'Inserted  '||sql%rowcount||' into bil_bi_currency_rate table');
  END IF;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;
 EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;
 END   Populate_Curr_Rate_SmallGap;


PROCEDURE Summary_Err_Check_SmallGap(x_valid_curr OUT NOCOPY VARCHAR2,
                            x_valid_date OUT NOCOPY VARCHAR2,
                            x_valid_prod OUT NOCOPY VARCHAR2,
                            x_return_warn OUT NOCOPY VARCHAR2) IS

      l_time_cnt          NUMBER;
      l_conv_rate_cnt     NUMBER;
      l_stg_min           NUMBER;
      l_stg_max           NUMBER;
      l_stg_min_txn_dt         DATE;
      l_stg_max_txn_dt         DATE;
      l_stg_min_eff_dt         DATE;
      l_stg_max_eff_dt         DATE;
      l_stg_min_dt         DATE;
      l_stg_max_dt         DATE;
      l_day_min           NUMBER;
      l_day_max           NUMBER;
      l_has_missing_date   BOOLEAN;
      l_count       NUMBER;
      l_lead_num    NUMBER;
      l_eff_date    DATE;
      l_number_of_rows     NUMBER;
      l_int_type       VARCHAR2(100);
      l_prim_code      VARCHAR2(100);
      l_sec_code       VARCHAR2(100);
      l_warn       VARCHAR2(1);

--      l_prim_miss BOOLEAN :=FALSE;
--      l_sec_miss  BOOLEAN :=FALSE;

     cursor c_item_prod is
      SELECT lead_number  FROM bil_bi_pipeline_stg
      WHERE  nvl(product_category_id,-1)=-1;

   l_proc VARCHAR2(100);
BEGIN

        l_time_cnt :=0;
      l_conv_rate_cnt:=0;
      l_has_missing_date := FALSE;
      l_count :=0;
      l_number_of_rows :=0;
      l_proc := 'Summary_Err_Check_SmallGap';

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
  END IF;


      UPDATE  bil_bi_pipeline_stg stg
         SET  (stg.prim_conversion_rate,conversion_rate_s) =
           (
             select
               exchange_rate,exchange_rate_s
             from BIL_BI_CURRENCY_RATE
             where
               currency_code = stg.txn_currency and
               exchange_date = stg.effective_date
           );
-- DOUBT
      /*
       WHERE
       (
         (
           (prim_conversion_rate IS NOT NULL) AND (prim_conversion_rate < 0)
         )
         OR  prim_conversion_rate IS NULL
       );
      */

      -- need this commit for the rollup not to roll back all the currencys, doesn't really matter anyway
      commit;

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    p_module => g_pkg || l_proc ,
    p_msg => 'Updated rates for '|| sql%rowcount || ' rows');
  END IF;

      --IF (g_refresh_flag <> 'Y') THEN

      SELECT count(1)
      INTO   l_conv_rate_cnt
      FROM   BIL_BI_PIPELINE_STG
      WHERE  (prim_conversion_rate < 0  OR  prim_conversion_rate IS NULL)
             OR (g_sec_currency IS NOT NULL and (conversion_rate_s < 0  OR  conversion_rate_s IS NULL)) ;

     IF (l_conv_rate_cnt >0) THEN
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level =>fnd_log.LEVEL_ERROR,
           p_module => g_pkg || l_proc ,
           p_msg => 'Missing currency conversion rates found, program will exit with error status.'||
           'Please fix the missing conversion rates'
         );
       END IF;
       Report_Missing_Rates;
--       l_prim_miss := TRUE;
      x_valid_curr := 'N';
    ELSE
      x_valid_curr := 'Y';
     END IF;


/*also for effective date. need to call the time api*/

      SELECT   MIN(stg.SNAP_DATE), Max(stg.SNAP_DATE)
             ,MIN(stg.Effective_DATE), Max(stg.Effective_DATE)
      INTO   l_stg_min_txn_dt, l_stg_max_txn_dt, l_stg_min_eff_dt, l_stg_max_eff_dt
      FROM   BIL_BI_PIPELINE_STG stg;

      IF (l_stg_min_txn_dt < l_stg_min_eff_dt) THEN
         l_stg_min_dt := l_stg_min_txn_dt;
      ELSE
         l_stg_min_dt := l_stg_min_eff_dt;
      END IF;

      IF (l_stg_max_txn_dt < l_stg_max_eff_dt) THEN
         l_stg_max_dt := l_stg_max_eff_dt;
      ELSE
         l_stg_max_dt := l_stg_max_txn_dt;
      END IF;


      --write_log(p_msg => 'Date range:'||l_stg_min_dt||'  '||l_stg_max_dt, p_log => 'N');
IF l_stg_min_dt IS NOT NULL AND l_stg_max_dt IS NOT NULL THEN
     FII_TIME_API.check_missing_date (l_stg_min_dt,l_stg_max_dt,l_has_missing_date);
END IF;
     l_has_missing_date := FALSE;

	  IF (l_has_missing_date) THEN
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => 'Time Dimension is not fully populated. '||
              ' Please populate Time dimension to cover the date range you are collecting');
        END IF;
         x_valid_date := 'N';
      Else
         x_valid_date := 'Y';
      END IF;

--   ELSE
 --        x_valid_curr := 'Y';
 --     x_valid_date := 'Y';
 --  END IF;        --- incremental mode only

      --- The following check applies both initial and incremental mode

      -- check for oppty close date  => don't need in this case since it is already restricted.

       -- check for bad item/product
  l_number_of_rows := 0;
      OPEN c_item_prod;
        LOOP
           FETCH c_item_prod into
          l_lead_num;
           EXIT WHEN c_item_prod%NOTFOUND ;
     l_number_of_rows :=l_number_of_rows + 1;

      IF(l_number_of_rows=1) THEN
      -- print header

        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => ' Some opportunties had null product category. They have not been collected.'
          );
        END IF;

     fnd_message.set_name('BIL','BIL_BI_ITEM_PROD_WARN_HDR');
     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                          p_msg => fnd_message.get,
                          p_force_log => TRUE);
      END IF;

      -- print detail

     fnd_message.set_name('BIL','BIL_BI_ITEM_PROD_ERR_DTL');
     fnd_message.set_token('OPPNUM', l_lead_num);
     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                          p_msg => fnd_message.get,
                          p_force_log => TRUE);


        END LOOP;
     CLOSE c_item_prod;


  IF ( l_number_of_rows  > 0) THEN
      x_valid_prod := 'N';
      x_return_warn := 'Y';
  ELSE
      x_valid_prod := 'Y';
      x_return_warn := 'N';
  END IF;


     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
     END IF;

EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);
  Raise;

END Summary_Err_Check_SmallGap;




PROCEDURE get_period_ids(p_date IN DATE,
		  				 x_day OUT NOCOPY NUMBER,
		  			     x_week OUT NOCOPY NUMBER,
						 x_period OUT NOCOPY NUMBER,
						 x_qtr OUT NOCOPY NUMBER,
						 x_year OUT NOCOPY NUMBER,
						 x_min_date_id OUT NOCOPY NUMBER,
						 x_max_date_id OUT NOCOPY NUMBER) IS

l_proc VARCHAR2(100);

BEGIN

l_proc := 'get_period_ids';
IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;

				SELECT
				       time.report_date_julian, time.week_id, time.ent_period_id,
				       time.ent_qtr_id, time.ent_year_id,  to_number(to_char(LEAST(time.ent_year_start_date, time1.week_start_date), 'J')),
				       to_number(to_char(GREATEST(time.ent_year_end_date,time2.week_end_date), 'J'))
				 INTO
				       x_day, x_week, x_period, x_qtr, x_year, x_min_date_id, x_max_date_id
				 FROM
				       FII_TIME_DAY time,
				       FII_TIME_DAY time1,
                                       FII_TIME_DAY time2
				 WHERE
				       time.report_date = TRUNC(p_date)
				       AND time1.report_date = time.ent_year_start_date
                                       AND time2.report_date = time.ent_year_end_date ;


 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     	bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   	 END IF;



    Exception
  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;



END get_period_ids;


FUNCTION is_date_end_of_prd(p_date IN DATE) return boolean IS

l_proc VARCHAR2(100);
l_week_end DATE;
l_period_end DATE;
l_quarter_end DATE;
l_year_end DATE;
l_is_eop BOOLEAN;

  begin
         l_proc := 'is_date_end_of_prd';

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;


	 SELECT week_end_date, ent_period_end_date, ent_qtr_end_date, ent_year_end_date
	 INTO  l_week_end, l_period_end , l_quarter_end, l_year_end
	 from fii_time_day
	 where report_date = p_date;

	 IF p_date = l_week_end OR p_date = l_period_end OR p_date = l_quarter_end
	 	OR p_date = l_year_end THEN
		   l_is_eop := TRUE;
     ELSE
	 		l_is_eop := FALSE;
	 END IF;


	 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
     	bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   	 END IF;

	 return l_is_eop;

    Exception
  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;



END is_date_end_of_prd;


PROCEDURE delete_from_curr(p_curr_coll_start IN DATE) IS
  l_proc VARCHAR2(100);


  begin
         l_proc := 'delete_from_curr';

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;


   -- delete the oldest week of data from current pipe fact, but first:
   -- insert into historical pipe fact those rows that
   --we are deleting from current and that are end of period (week, month, etc) rows




	-- by joining to fii_time_day, we ensure that only end of period records
	-- are inserted into hist pipe fact

	INSERT  into bil_bi_pipeline_f f(
   SALES_GROUP_ID,
   SALESREP_ID,
   CREATED_BY ,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   REQUEST_ID,
   PROGRAM_APPLICATION_ID,
   PROGRAM_ID,
   PROGRAM_UPDATE_DATE,
   SNAP_DATE,
   ITEM_ID,
   ITEM_ORGANIZATION_ID,
   WIN_PROBABILITY,
   PRODUCT_CATEGORY_ID,
   PIPELINE_AMT_DAY,
   PIPELINE_AMT_WEEK,
   PIPELINE_AMT_PERIOD,
   PIPELINE_AMT_Quarter,
   PIPELINE_AMT_YEAR,
   OPEN_AMT_DAY,
   OPEN_AMT_WEEK,
   OPEN_AMT_PERIOD,
   OPEN_AMT_Quarter,
   OPEN_AMT_YEAR,
   PIPELINE_AMT_DAY_S,
   PIPELINE_AMT_WEEK_S,
   PIPELINE_AMT_PERIOD_S,
   PIPELINE_AMT_Quarter_S,
   PIPELINE_AMT_YEAR_S,
   OPEN_AMT_DAY_S,
   OPEN_AMT_WEEK_S,
   OPEN_AMT_PERIOD_S,
   OPEN_AMT_Quarter_S,
   OPEN_AMT_YEAR_S
 )
 SELECT
   f.SALES_GROUP_ID,
   f.SALESREP_ID,
   g_user_id,
   sysdate,
   g_user_id,
   sysdate,
   G_Login_Id,
   G_request_id,
   G_appl_id,
   G_program_id,
   sysdate,
   f.snap_date,
   f.ITEM_ID,
   f.ITEM_ORGANIZATION_ID,
   f.WIN_PROBABILITY,
   f.PRODUCT_CATEGORY_ID,
   f.PIPELINE_AMT_DAY,
   f.PIPELINE_AMT_WEEK,
   f.PIPELINE_AMT_PERIOD,
   f.PIPELINE_AMT_Quarter,
   f.PIPELINE_AMT_YEAR,
   f.OPEN_AMT_DAY,
   f.OPEN_AMT_WEEK,
   f.OPEN_AMT_PERIOD,
   f.OPEN_AMT_Quarter,
   f.OPEN_AMT_YEAR,
   f.PIPELINE_AMT_DAY_S,
   f.PIPELINE_AMT_WEEK_S,
   f.PIPELINE_AMT_PERIOD_S,
   f.PIPELINE_AMT_Quarter_S,
   f.PIPELINE_AMT_YEAR_S,
   f.OPEN_AMT_DAY_S,
   f.OPEN_AMT_WEEK_S,
   f.OPEN_AMT_PERIOD_S,
   f.OPEN_AMT_Quarter_S,
   f.OPEN_AMT_YEAR_S
   FROM BIL_BI_PIPEC_F f
   WHERE f.snap_date < p_curr_coll_start
   and f.snap_date IN (
   SELECT report_date from fii_time_day
   	   			   	   where report_date=week_end_date
					   UNION
					   SELECT report_date from fii_time_day
   	   			   	   where report_date = ent_period_end_date
					   UNION
					   SELECT report_date from fii_time_day
   	   			   	   where report_date = ent_qtr_end_date
					   UNION
					   SELECT report_date from fii_time_day
   	   			   	   where report_date =ent_year_end_date
   );

   commit;

    DELETE FROM BIL_BI_PIPEC_F
    where snap_date < p_curr_coll_start;
    commit;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;


    Exception
  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;


END delete_from_curr;



PROCEDURE populate_hist_dates(p_start_date DATE, p_end_date DATE) IS
  l_proc VARCHAR2(100);


  begin
         l_proc := 'populate_hist_dates';

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;

 INSERT INTO BIL_BI_TIME
(select
CASE WHEN week_start_date < ent_period_start_date then ent_period_start_date
WHEN week_start_date < ent_qtr_start_date then ent_qtr_start_date
WHEN week_start_date < ent_year_start_date then ent_year_start_date
ELSE week_start_date
END start_date
,CASE WHEN week_end_date > ent_period_end_date then ent_period_end_date
WHEN week_end_date > ent_qtr_end_date then ent_qtr_end_date
WHEN week_end_date > ent_year_end_date then ent_year_end_date
ELSE week_end_date	END  end_date
from fii_time_day time1
where (time1.report_date between p_start_date and p_end_date
and time1.report_date=time1.week_start_date)
OR
(time1.report_date between p_start_date and p_end_date
and time1.report_date = time1.week_end_date
and (time1.week_start_date < time1.ent_period_start_date OR
time1.week_start_date < time1.ent_qtr_start_date OR
time1.week_start_date < time1.ent_period_start_date))
);
commit;

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;


    Exception
  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;


END populate_hist_dates;


FUNCTION get_start_curr_coll RETURN DATE IS

  l_curr_collect_start DATE;
  l_proc VARCHAR2(100);
  l_last_fact_run DATE;

  begin
         l_proc := 'get_start_curr_coll';

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;

    l_last_fact_run :=
      trunc(fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('BIL_BI_OPDTL_F')));


   	SELECT end_date+1
    INTO l_curr_collect_start
	FROM fii_time_week
    WHERE l_last_fact_run-21 BETWEEN start_date AND end_date;

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;

    return l_curr_collect_start;

    Exception
  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;


END get_start_curr_coll;



PROCEDURE get_last_failure_periods(p_object_name in varchar2,
p_period_from OUT NOCOPY DATE,
p_period_to OUT NOCOPY DATE ) is
l_date   date;
l_date_disp varchar2(100);
l_proc VARCHAR2(100);
l_status VARCHAR2(50);

 cursor last_refresh_date_cursor(p_obj_name varchar2, l_status varchar2) is
    select period_from, period_to
  from bis_refresh_log
  where object_name = p_obj_name and status=l_status
  and last_update_date =( select max(last_update_date)
       from bis_refresh_log
          where object_name= p_obj_name and  status=l_status ) ;


begin
         l_proc := 'get_last_failure_period';
		 l_status := 'FAILURE';
 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;

    open last_refresh_date_cursor(p_object_name, l_status);
    fetch last_refresh_date_cursor into p_period_from, p_period_to;
    if(last_refresh_date_cursor%ROWCOUNT < 1) then
        p_period_from:=null;
        p_period_to:=null;
    end if;
    close last_refresh_date_cursor;

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;

    Exception
         WHEN NO_DATA_FOUND THEN

            p_period_from:=null;
            p_period_to:=null;

  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;
end get_last_failure_periods;


function get_first_success_period(p_object_name in varchar2) return varchar2 is
l_date   date;
l_date_disp varchar2(100);
l_proc VARCHAR2(100);
l_status VARCHAR2(50);

begin
   l_proc  := 'get_first_success_period';
   l_status := 'SUCCESS';

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;


    SELECT MIN(period_from) INTO l_date
    FROM bis_refresh_log
    WHERE   object_name = p_object_name AND
      status=l_status AND
      last_update_date =
    (SELECT MIN(last_update_date)
     FROM bis_refresh_log
     WHERE object_name= p_object_name AND
           status=l_status ) ;

    IF (l_date IS NULL) THEN
  l_date:= to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'), 'mm/dd/yyyy');
    END IF;

    l_date_disp := fnd_date.date_to_displaydt (l_date);

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;

    return l_date_disp;

    Exception
  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;
end get_first_success_period;


FUNCTION get_number_of_runs( p_object_name in varchar2) return number is
	l_num NUMBER;
	l_proc VARCHAR2(100);
	l_status VARCHAR2(100);

begin
   l_proc  := 'get_number_of_runs';
   l_status := 'SUCCESS';

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;


    SELECT count(*) INTO l_num
    FROM bis_refresh_log
    WHERE   object_name = p_object_name
    and status=l_status ;


   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;

    return l_num;

    Exception
  WHEN OTHERS THEN
   /*Generic Exception Handling block.*/
         fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON', SQLERRM);
      fnd_message.set_token('ROUTINE', l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;
END get_number_of_runs;

   PROCEDURE incr_load
     (
       errbuf              IN OUT NOCOPY VARCHAR2,
       retcode             IN OUT NOCOPY VARCHAR2
     ) IS
    BEGIN
      load(errbuf, retcode, TO_CHAR(SYSDATE,'YYYY/MM/DD HH24:MI:SS'),'N');
    END incr_load;

   PROCEDURE init_load (errbuf         IN OUT NOCOPY VARCHAR2,
                   retcode             IN OUT NOCOPY VARCHAR2,
		   p_start_date        IN   VARCHAR2 ,
                   p_truncate          IN   VARCHAR2)
    IS
    BEGIN
      load(errbuf,retcode,p_start_date,p_truncate);
    END init_load;




 /*PROCEDURE Load
      (
	   errbuf              IN OUT NOCOPY VARCHAR2,
	   retcode             IN OUT NOCOPY VARCHAR2,
	   p_truncate          IN      VARCHAR2
						         ) IS
BEGIN
       load(errbuf, retcode, '2004/12/23 0:0:0', p_truncate);
END LOAD;
*/
 PROCEDURE Load
     (
       errbuf              IN OUT NOCOPY VARCHAR2,
       retcode             IN OUT NOCOPY VARCHAR2,
       p_start_date        IN   VARCHAR2,
       p_truncate          IN   VARCHAR2
     ) IS
   l_proc                          VARCHAR2(100);
   l_day                           NUMBER;
   l_week                          NUMBER;
   l_period                        NUMBER;
   l_qtr                           NUMBER;
   l_year                          NUMBER;
   l_date                          DATE;
   l_last_run                      DATE;
   l_last_fact_run                 DATE;
   l_first_fact_run                DATE;
   l_min_date_id                   NUMBER;
   l_max_date_id                   NUMBER;
   l_valid_setup                   BOOLEAN ;
   l_int_date_format               VARCHAR2(21);
   l_int_date_format1              VARCHAR2(21);
   l_count                         NUMBER;
   l_resume_flag                   VARCHAR2(1);
   l_failure_from                  DATE;
   l_failure_to                    DATE;
   l_number_of_runs		   NUMBER;
   l_list                          DBMS_SQL.VARCHAR2_TABLE;
   l_val                           DBMS_SQL.VARCHAR2_TABLE;
   l_stg_count                     NUMBER;
   l_opty_cnt                      NUMBER;
   l_valid_curr                    VARCHAR2(1);
   l_valid_date                    VARCHAR2(1);
   l_valid_prod                    VARCHAR2(1);
   l_return_warn                   VARCHAR2(1);
   l_return_warn_resume            VARCHAR2(1);
   l_asn_implemented              VARCHAR2(1);

   l_mode 			   VARCHAR2(30);
   l_start_date                    DATE;
   l_date_format      		   VARCHAR2(21);
   l_sysdate		           DATE;

       l_sd_lyr                         DATE; --same date last year
    l_sd_lper                        DATE; --same date last period
    l_sd_lqtr                        DATE; -- same date last quarter
    l_sd_lwk                         DATE; --same date last week

    l_sd_lyr_end                         DATE; --same date last year (end of the year/qtr/period/week)
    l_sd_lper_end                        DATE; --same date last period (end of the year/qtr/period/week)
    l_sd_lqtr_end                       DATE; -- same date last quarter (end of the year/qtr/period/week)
    l_sd_lwk_end                         DATE; --same date last week (end of the year/qtr/period/week)

    l_dynamic_sql VARCHAR2(2000);
    l_curr_coll_start DATE;
    l_min_curr_date DATE;

    l_period_from                VARCHAR2(240); -- By TR to store this info in pipec_f
    l_period_to                  VARCHAR2(240); -- By TR to store this info in pipec_f

    l_min_lead_date DATE;
	l_min_line_date DATE;
	l_min_credit_date DATE;
	l_min_log_date DATE;
	l_small_gap BOOLEAN;

   BEGIN

 G_request_id  := 0;
 G_appl_id     := 0;
 G_program_id  := 0;
 G_user_id     := 0;
 G_login_id    := 0;
 g_row_num     := 0;
 g_pkg         := 'bil.patch.115.sql.bil_bi_pipeline_f_pkg.';

     G_request_id  := 0;
 G_appl_id     := 0;
 G_program_id  := 0;
 G_user_id     := 0;
 G_login_id    := 0;
 g_row_num     := 0;
 g_pkg         := 'bil.patch.115.sql.bil_bi_pipeline_f_pkg.';

      G_request_id := FND_GLOBAL.CONC_REQUEST_ID();
     G_appl_id    := FND_GLOBAL.PROG_APPL_ID();
     G_program_id := FND_GLOBAL.CONC_PROGRAM_ID();
     G_user_id    := FND_GLOBAL.USER_ID();
     G_login_id   := FND_GLOBAL.CONC_LOGIN_ID();

     g_setup_error_flag:= FALSE;
     g_row_num := 0;
     g_program_start:= sysdate;

   l_proc:= 'Load';
   l_int_date_format:='DD/MM/YYYY HH24:MI:SS';
   l_int_date_format1:='MM/DD/YYYY HH24:MI:SS';
   l_resume_flag:= 'N';
   l_sysdate := sysdate;

   l_valid_setup := BIS_COLLECTION_UTILITIES.SETUP('BIL_BI_PIPELINE_F');





   IF (not l_valid_setup) THEN
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_EVENT,
          p_module => g_pkg || l_proc ,
          p_msg => 'BIS_COLLECTION_UTILITIES.SETUP failed'
        );
     END IF;
    RAISE G_BIS_SETUP_ERROR;
  END IF;


   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
   END IF;



        -- get profiles

       l_list(1) := 'BIS_GLOBAL_START_DATE';
       l_list(2) := 'AS_OPP_ENABLE_LOG';
       l_list(3) := 'AS_OPP_LINE_ENABLE_LOG';
       l_list(4) := 'AS_OPP_SC_ENABLE_LOG';
       l_list(5) := 'AS_OPP_LOG_TIMEFRAME';
       --l_list(6) := 'BIL_BI_ASN_IMPLEMENTED';

       -- 'ASN_FRCST_CREDIT_TYPE_ID'
       -- 'AS_FORECAST_CREDIT_TYPE_ID';

       l_list(6) := 'BIS_PRIMARY_CURRENCY_CODE';
       l_list(7) := 'BIS_PRIMARY_RATE_TYPE';




       IF (bis_common_parameters.check_global_parameters(l_list)) THEN
         bis_common_parameters.get_global_parameters(l_list, l_val);
         g_global_start_date := TO_DATE(l_val(1), l_int_date_format1);
         IF (l_val(2) <> 'Y' or l_val(3) <> 'Y' or l_val(4) <> 'Y') THEN
           FOR i IN 2..4  LOOP
             Report_Profile_Error(l_list(i), l_val(i), 'Y');
           END LOOP;
         END IF;
           IF (l_val(5) <> 'DAY' AND l_val(5) <> 'HOUR' AND l_val(5) <> 'MIN' AND l_val(5) <> 'NONE') THEN
		 Report_Profile_Error(l_list(5), l_val(5), 'DAY or HOUR or MINUTE or NONE');
         END IF;

           g_credit_type_id:=fnd_profile.value('ASN_FRCST_CREDIT_TYPE_ID');
           IF(g_credit_type_id is null) THEN
             Report_Missing_Profile('ASN_FRCST_CREDIT_TYPE_ID');
           END IF;

       ELSE
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
            (
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg => 'Missing profiles' );
        END IF;
        bis_common_parameters.get_global_parameters(l_list, l_val);
        FOR v_counter IN 1..7 LOOP
          IF (l_val(v_counter) IS  NULL) THEN
            Report_Missing_Profile(l_list(v_counter));
          END IF;
        END LOOP;
      END IF;

     --g_prim_currency := bis_common_parameters.get_currency_code;
     --g_prim_rate_type := bis_common_parameters.get_rate_type;
     g_prim_currency := l_val(6);
     g_prim_rate_type := l_val(7);

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_STATEMENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'prim curr : rate type = '||g_prim_currency||' : '||g_prim_rate_type
      );
    END IF;


     l_list(8) := 'BIS_SECONDARY_CURRENCY_CODE';
     l_list(9) := 'BIS_SECONDARY_RATE_TYPE';
     l_val(8) := bis_common_parameters.get_secondary_currency_code;
     l_val(9) := bis_common_parameters.get_secondary_rate_type;

    -- don't reget all values with the 2 new profiles!!
    --bis_common_parameters.get_global_parameters(l_list, l_val);


-- sec curr not set up at all
     IF (l_val(8) IS NULL) THEN
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (p_log_level => fnd_log.LEVEL_STATEMENT,p_module => g_pkg || l_proc ,
           p_msg => ' Secondary curency not set up '
         );
       END IF;
     END IF;

-- sec curr set up but rate type not set up : ERROR
     IF (l_val(8) IS NOT NULL AND l_val(9) IS NULL ) THEN
      Report_Missing_Profile(l_list(9));
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (p_log_level => fnd_log.LEVEL_STATEMENT,p_module => g_pkg || l_proc ,
           p_msg => ' Secondary curency set up but rate type not set up: ERROR '
         );
       END IF;
     END IF;

-- sec curr and rate type properly set up
     IF (l_val(8) IS NOT NULL AND l_val(9) IS NOT NULL ) THEN

       g_sec_currency := bis_common_parameters.get_secondary_currency_code;
       g_sec_rate_type := bis_common_parameters.get_secondary_rate_type;

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
           p_log_level => fnd_log.LEVEL_STATEMENT,
           p_module => g_pkg || l_proc ,
           p_msg => 'sec curr : rate type = '||g_sec_currency||' : '||g_sec_rate_type
         );
       END IF;
     END IF;





    IF p_start_date IS NULL THEN
       l_Start_Date :=    G_global_start_date;
    ELSIF (TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS') > l_sysdate) THEN
      fnd_message.set_name('BIL','BIL_BI_DATE_PARAM_RESET');
      fnd_message.set_token('RESET_DATE',
                  TO_CHAR(SYSDATE, 'YYYY/MM/DD HH24:MI:SS'));
      bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_ERROR,
          p_module => g_pkg || l_proc ,
          p_msg => fnd_message.get,
          p_force_log => TRUE
        );
        l_start_date := TRUNC(l_sysdate);
        l_return_warn := 'Y';

    ELSE
        l_Start_Date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
    END IF;




 /*  IF (TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS') < l_min_lead_date) THEN
	    l_start_date := TRUNC(l_min_lead_date);
   ELSE l_start_date := TO_DATE(p_start_date, 'YYYY/MM/DD HH24:MI:SS');
   END IF;
*/
  -- l_date_format:= 'YYYY/MM/DD HH24:MI:SS';
  --l_Start_date := TO_DATE(p_start_date, l_date_format);

-------------------------------------------------------------
        -- CHECK FOR OPTY LOGS.
--------------------------------------------------------------

      SELECT SUM(cnt)  into l_opty_cnt FROM
      (
        SELECT /*+ index_ffs(as_leads_log) parallel_index(as_leads_log) */ count(*) cnt
        FROM as_leads_log
        UNION ALL
        SELECT -cnt FROM
          (SELECT /*+ index_ffs(as_leads_all) parallel_index(as_leads_all) */ count(*) cnt FROM as_leads_all)
      );

  IF (l_opty_cnt < 0 ) THEN
    -- log table has not been populated.
    IF (g_setup_error_flag = FALSE) THEN
      g_setup_error_flag := TRUE;
      fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_ERROR,
        p_module => g_pkg || l_proc || ' proc_error',
        p_msg => fnd_message.get,
        p_force_log => TRUE
      );
    END IF;
    fnd_message.set_name('BIL','BIL_BI_OPTY_LOG_MISSING');
    bil_bi_util_collection_pkg.writeLog
    (
      p_log_level => fnd_log.LEVEL_ERROR,
      p_module => g_pkg || l_proc || ' proc_error',
      p_msg => fnd_message.get,
      p_force_log => TRUE
    );
  END IF;

  IF (g_setup_error_flag) THEN
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'Setup Validition failed'
      );
    END IF;
    RAISE G_SETUP_VAL_ERROR;
  END IF;


    l_curr_coll_start := get_start_curr_coll;


   l_first_fact_run := fnd_date.displaydt_to_date(get_first_success_period('BIL_BI_OPDTL_F'));


 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'p_truncate is ' || p_truncate
      );
    END IF;



  IF (p_truncate = 'Y') THEN
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'Truncating'
      );
    END IF;
    BIS_COLLECTION_UTILITIES.deleteLogForObject ('BIL_BI_PIPELINE_F');
	BIS_COLLECTION_UTILITIES.deleteLogForObject ('BIL_BI_PIPEC_F');
    bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPELINE_STG');
    bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPELINE_F');
    bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPEC_F');
    bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_DENLOG_STG');
	bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_TIME');
    bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_DENLOG_TMP');
  ELSE
           ----------------------------------------------------
                -- CHECK FOR RESUME
           ----------------------------------------------------
    SELECT sum(cnt) INTO l_count FROM (select count(1) cnt from bil_bi_pipeline_stg
     union all select count(1) cnt from BIL_BI_DENLOG_STG)
    ;
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'No. of Rows in Staging are :'||l_count
      );
    END IF;

    IF (l_count > 0) THEN
      get_last_failure_periods('BIL_BI_PIPELINE_F', l_failure_from, l_failure_to);
      l_number_of_runs := get_number_of_runs('BIL_BI_PIPELINE_F');

      IF(l_number_of_runs <=1 ) then
         l_mode := 'INIT';
      ELSE
      	 l_mode := 'INCR';
      END IF;

       Populate_Currency_Rate(l_mode);

	bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_TIME');

       populate_hist_dates(l_failure_from+1, l_failure_to);

	   get_period_ids(l_failure_from, x_day=>l_day,
		x_week => l_week, x_period => l_period, x_qtr => l_qtr,
		  x_year => l_year, x_min_date_id => l_min_date_id, x_max_date_id => l_max_date_id);



      -- rebuild baseline since stage table can be in any state

      bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPELINE_STG');

   --if gap is lessthan 3 days, we don't need to rebuild baseline
   -- since we will use 7.0.1 approach to insert into staging

   IF (l_failure_to - l_failure_from)  > 3 THEN

	l_small_gap := FALSE;

	  Build_Baseline(l_failure_from);


      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
            bil_bi_util_collection_pkg.writeLog
            (
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg =>'Gap Is' || l_failure_to - l_failure_from
            );
        END IF;




       /*Update the staging with new conversion rates.*/
      Summary_Err_Check(l_mode,
      			 x_valid_curr => l_valid_curr,
                          x_valid_date => l_valid_date,
                          x_valid_prod => l_valid_prod,
                          x_return_warn => l_return_warn_resume);
      IF ((l_valid_curr = 'Y') AND (l_valid_date = 'Y')) THEN
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
            bil_bi_util_collection_pkg.writeLog
            (
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg =>'Summary Error Check Successful!'
            );
        END IF;

        bil_bi_util_collection_pkg.analyze_table('BIL_BI_PIPELINE_STG',TRUE, 10, 'GLOBAL');
        bil_bi_util_collection_pkg.analyze_table('BIL_BI_DENLOG_STG',TRUE, 10, 'GLOBAL');
        bil_bi_util_collection_pkg.analyze_table('BIL_BI_OPDTL_DENLOG_TMP',TRUE, 10, 'GLOBAL');



		-- this will insert the first day record
       -- if l_last_run+1 < curr collection start, insert into hist. otherwise curr and


	   IF l_failure_from < l_curr_coll_start THEN
        Insert_Into_Summary(l_mode);

	   ELSE
	      Insert_Into_Curr_Sumry(l_failure_from,  l_week, l_period, l_qtr,
		  l_year, l_min_date_id, l_max_date_id);
	   END IF;




	ELSE
        RAISE G_INVALID_DIM;
      END IF;


	ELSE --Gap less or equal to 3 days

	l_small_gap := TRUE;

	 Insert_Into_Stg_SmallGap(l_failure_from, l_failure_to, l_first_fact_run);


	 Populate_Curr_Rate_SmallGap;


	 select count(1)
	 into l_stg_count
	 from bil_bi_pipeline_stg;


	IF l_stg_count > 0 THEN
     Summary_Err_Check_SmallGap(x_valid_curr => l_valid_curr,
                        x_valid_date => l_valid_date,
                        x_valid_prod => l_valid_prod,
                        x_return_warn => l_return_warn);
	END IF;



	IF ((l_valid_curr = 'Y') AND (l_valid_date = 'Y')) THEN
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
            bil_bi_util_collection_pkg.writeLog
            (
              p_log_level => fnd_log.LEVEL_EVENT,
              p_module => g_pkg || l_proc ,
              p_msg =>'Summary Error Check Successful!'
            );
        END IF;

        bil_bi_util_collection_pkg.analyze_table('BIL_BI_PIPELINE_STG',TRUE, 10, 'GLOBAL');


	--Insert the first day of the gap, since gap_fill will only insert from 2nd day on
	 Ins_Into_CurrSum_SmGap(l_failure_from,  l_week, l_period, l_qtr,
		  l_year, l_min_date_id, l_max_date_id);

	ELSE
        RAISE G_INVALID_DIM;
      END IF;



	END IF; -- gap less then 3 days



Gap_Fill(l_failure_from+1, l_failure_to, l_curr_coll_start, l_mode, l_small_gap);


        l_resume_flag := 'Y';
        bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPELINE_STG');
         bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_DENLOG_STG');
         --execute immediate 'Truncate table BIL_BI_DENLOG_STG';
         bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_DENLOG_TMP');

       -- Added by TR (to populate the correct period_to and period_from dates in Attribute
       --  columns of bis_refresh_log)
       SELECT TO_CHAR(MIN(snap_date),'DD-MM-YYYY')
	    INTO l_period_from
         FROM bil_bi_pipec_f;

		SELECT TO_CHAR(MAX(snap_date),'DD-MM-YYYY')
	    INTO l_period_to
         FROM bil_bi_pipec_f;



	 IF l_curr_coll_start between l_failure_from+1 and l_failure_to THEN

	    INSERT INTO bis_refresh_log
        (
          Request_id,
          Concurrent_id,
          Object_name,
          Status,
          Start_date,
          Period_from,
          Period_to,
          Number_processed_record,
          Exception_message,
          Creation_date,
          Created_by,
          Last_update_date,
          Last_update_login,
          Last_updated_by
        )
        VALUES
        (
          g_request_id,
          g_program_id,
          'BIL_BI_PIPELINE_F',
          'SUCCESS',
          g_program_start,
          l_failure_from,
          l_curr_coll_start-1,
          g_row_num,
          'Successful resumed from last gap fill',
          sysdate,
          g_user_id,
          sysdate,
          g_login_id,
          g_user_id
        );
		   INSERT INTO bis_refresh_log
        (
          Request_id,
          Concurrent_id,
          Object_name,
          Status,
          Start_date,
          Period_from,
          Period_to,
          Number_processed_record,
          Exception_message,
          Creation_date,
          Created_by,
          Last_update_date,
          Last_update_login,
          Last_updated_by,
          Attribute1,
          Attribute2
        )
        VALUES
        (
          g_request_id,
          g_program_id,
          'BIL_BI_PIPEC_F',
          'SUCCESS',
          g_program_start,
          l_curr_coll_start,
          l_failure_to,
          g_row_num,
          'Successful resumed from last gap fill',
          sysdate,
          g_user_id,
          sysdate,
          g_login_id,
          g_user_id,
          l_period_from,
          l_period_to
        );

	ELSE
		  INSERT INTO bis_refresh_log
        (
          Request_id,
          Concurrent_id,
          Object_name,
          Status,
          Start_date,
          Period_from,
          Period_to,
          Number_processed_record,
          Exception_message,
          Creation_date,
          Created_by,
          Last_update_date,
          Last_update_login,
          Last_updated_by,
          Attribute1,
          Attribute2
        )
        VALUES
        (
          g_request_id,
          g_program_id,
          'BIL_BI_PIPEC_F',
          'SUCCESS',
          g_program_start,
          l_failure_from,
          l_failure_to,
          g_row_num,
          'Successful resumed from last gap fill',
          sysdate,
          g_user_id,
          sysdate,
          g_login_id,
          g_user_id,
          l_period_from,
          l_period_to
        );
	END IF;

      commit;
    END IF; -- count > 0
  END IF; -- if not purge then resume


       -- disabled this logic
       /*
       IF sysdate < (trunc(sysdate) + 18/24) THEN
           -- if before 6pm , count as last day
           l_date := trunc(sysdate) - 1;
       ELSE
           l_date =trunc(sysdate) ;
       END IF;
       */


    -- resume during gap fill is handled by reading l_last_run after resume

    l_last_run :=
      trunc(fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('BIL_BI_PIPEC_F')));
    l_last_fact_run :=
      trunc(fnd_date.displaydt_to_date(BIS_COLLECTION_UTILITIES.get_last_refresh_period('BIL_BI_OPDTL_F')));

    l_date := l_last_fact_run; -- fact could be run on previous day or the same day


--------------------------------------------------------------
    -- IF FACT HASN'T BEEN RUN, CAN'T RUN PIPELINE EITHER.
--------------------------------------------------------------

   IF (l_last_fact_run = G_global_start_date) THEN

       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_ERROR) THEN
        -- This error message is an unusual case of standalone run of CP in incremental mode
        -- hence it doesn't use a translated msg string
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level =>fnd_log.LEVEL_ERROR,
           p_module => g_pkg || l_proc ,
           p_msg => 'Load Sales Opportunity Base Summary program must be run before this program.'
         );
       END IF;

      BIS_COLLECTION_UTILITIES.wrapup(FALSE,
           g_row_num,
           'Load Sales Opportunity Base Summary program not run.',
           l_date,
           l_date
           );
     retcode := -1;
     return;

   END IF;

--------------------------------------------------------------
-- DETECT GAPS AND FILL THEM. (Treat initial as a big gap)
--------------------------------------------------------------

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level =>fnd_log.LEVEL_ERROR,
           p_module => g_pkg || l_proc ,
           p_msg => 'l_date is ' || l_date || ' l_last_run is ' || l_last_run || ' g_global is' || g_global_start_date
         );
       END IF;


--we want to make sure that there is data in as_leads_log
--for the day that we want to build the baseline on
--this is true in any case, not only wher p_start_date the MIN date in as_leads_log
--for this purpose, we replace l_start_date with
--the closest date in as_leads_log from l_start_date,
--that is in the range we are collecting for
--if there is data for l_start_date itself, we will build baseline on l_start_date


--get the earliest dates in the as log tables
BEGIN

SELECT MIN(last_update_date)
into l_min_lead_date
from as_leads_log
WHERE last_update_date between l_start_date and l_date;


EXCEPTION
		 WHEN NO_DATA_FOUND THEN

    null;
END;

l_start_date := NVL(TRUNC(l_min_lead_date), l_start_date);

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level =>fnd_log.LEVEL_ERROR,
           p_module => g_pkg || l_proc ,
           p_msg => 'l_min_lead_date is ' || l_min_lead_date || ' l_start_date is ' || l_start_date || ' g_global is' || g_global_start_date
         );
END IF;


   IF (l_last_run < l_date - 1) THEN
    IF (l_last_run =  G_global_start_date) THEN
      -- initial load (gap from global_start_date to l_date-1)

     -- truncate table here since there is a possibibility the build base line was
     -- successful on the 1st run and the rest failed.

     bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPELINE_F');
     bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPEC_F');


      -- setup baseline on the global start date
      Build_Baseline(l_start_date);

	  bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_TIME');

	  l_small_gap := FALSE;

        populate_hist_dates(l_start_date+1, l_date);


      -- build up the denlog_tmp table for the gap range
      -- l_date instead of l_date -1 is because denlog will check for time < l_date
      Build_Denlog(l_start_date+1, l_date, l_curr_coll_start, 'INIT');

      bil_bi_util_collection_pkg.analyze_table('BIL_BI_PIPELINE_STG',TRUE, 10, 'GLOBAL');
      bil_bi_util_collection_pkg.analyze_table('BIL_BI_DENLOG_STG',TRUE, 10, 'GLOBAL');
      bil_bi_util_collection_pkg.analyze_table('BIL_BI_OPDTL_DENLOG_TMP',TRUE, 10, 'GLOBAL');

      Populate_Currency_Rate('INIT');

      l_failure_from := g_global_start_date;
      l_failure_to   := l_date-1;

      Summary_Err_Check('INIT',
      			x_valid_curr => l_valid_curr,
                        x_valid_date => l_valid_date,
                        x_valid_prod => l_valid_prod,
                        x_return_warn => l_return_warn);

     IF ((l_valid_curr = 'Y') AND (l_valid_date = 'Y') ) THEN
      -- this will insert the 1st day record.
      Insert_Into_Summary('INIT');

      -- incrementally build up the rest of the days
	  Gap_Fill(l_start_date+1, l_date-1, l_curr_coll_start, 'INIT', l_small_gap) ;
      bil_bi_util_collection_pkg.analyze_table('BIL_BI_PIPELINE_F',TRUE, 10, 'GLOBAL');
     Else
       RAISE G_INVALID_DIM;
     END IF; -- errcheck ok


    ELSE

	  bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_TIME');

      populate_hist_dates(l_last_run+2, l_date);


	-- incr   load
    -- Delete data from current pipe fact if it is older than 3 weeks (from beggining of period
    -- when we start to collect daily)

      -- get the first day in the current pipeline table to see if we need to delete
   SELECT MIN(snap_date)
   into l_min_curr_date
   FROM bil_bi_pipec_f;

   IF l_min_curr_date < l_curr_coll_start THEN
    DELETE_FROM_CURR(l_curr_coll_start);
   END IF;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'Incr gap fill: l_min_curr_date is :' ||l_min_curr_date || ' l_curr_coll_start is : ' ||l_curr_coll_start);

    END IF;


     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'snapshot gap found: gcredit_typeid is ' || g_credit_type_id ||
           ' global date is '|| g_global_start_date
       );
     END IF;

      -- gap exists

   DELETE FROM bil_bi_pipeline_f WHERE snap_date between l_last_run+1 and l_date-1;
   commit;

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'Deleted  '|| sql%rowcount ||' from BIL_BI_PIPELINE_F table for gap between' || (l_last_run+1) ||
         ' and ' || (l_date-1));
   END IF;

   DELETE FROM bil_bi_pipec_f WHERE snap_date between l_last_run+1 and l_date-1;
   commit;

      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'Deleted  '|| sql%rowcount ||' from BIL_BI_PIPEC_F table for gap between' || (l_last_run+1) ||
         ' and ' || (l_date-1));
   END IF;


       get_period_ids(l_last_run+1, x_day => l_day,
	   				  x_week => l_week, x_period => l_period, x_qtr => l_qtr,
		  			  x_year => l_year, x_min_date_id => l_min_date_id, x_max_date_id => l_max_date_id);

	  --if gap is lessthan 3 days, we don't need to build baseline
   -- since we will use 7.0.1 approach to insert into staging

   IF l_date - (l_last_run+1)>  3 THEN

    l_small_gap := FALSE;

	--we want to make sure that there is data in as_leads_log
--for the day that we want to build the baseline on
--this is true in any case, not only wher p_start_date the MIN date in as_leads_log
--for this purpose, we replace l_start_date with
--the closest date in as_leads_log from l_start_date,
--that is in the range we are collecting for
--if there is data for l_start_date itself, we will build baseline on l_start_date


--get the earliest dates in the as log tables
BEGIN

SELECT MIN(last_update_date)
into l_min_lead_date
from as_leads_log
WHERE last_update_date between l_last_run+1 and l_date;


EXCEPTION
		 WHEN NO_DATA_FOUND THEN

    null;
END;



IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level =>fnd_log.LEVEL_ERROR,
           p_module => g_pkg || l_proc ,
           p_msg => 'l_min_lead_date is ' || l_min_lead_date || ' l_last_run+1 is ' || l_start_date || ' g_global is' || g_global_start_date
         );
END IF;

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
   	    bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'Inside gap more than 3 days');
	 END IF;

    -- setup baseline on the global start date
      Build_Baseline(NVL(l_min_lead_date, l_last_run+1));


      Build_Denlog(l_last_run+2, l_date, l_curr_coll_start, 'INCR');

	  bil_bi_util_collection_pkg.analyze_table('BIL_BI_PIPELINE_STG',TRUE, 10, 'GLOBAL');
      bil_bi_util_collection_pkg.analyze_table('BIL_BI_DENLOG_STG',TRUE, 10, 'GLOBAL');
      bil_bi_util_collection_pkg.analyze_table('BIL_BI_OPDTL_DENLOG_TMP',TRUE, 10, 'GLOBAL');



     Populate_Currency_Rate('INCR');
     l_failure_from := l_last_run+1;
     l_failure_to   := l_date-1;

      --- if time and currency, stop
      --- if product information , warning and skip

     Summary_Err_Check('INCR',
     			x_valid_curr => l_valid_curr,
                        x_valid_date => l_valid_date,
                        x_valid_prod => l_valid_prod,
                        x_return_warn => l_return_warn);

     IF ((l_valid_curr = 'Y') AND (l_valid_date = 'Y') ) THEN
       -- this will insert the firs day record
       -- if l_last_run+1 < curr collection start, insert into hist. otherwise curr and
       -- if end of period, hist. as well


	   IF l_last_run+1 < l_curr_coll_start THEN
              Insert_Into_Summary('INCR');

	   ELSE
	      Insert_Into_Curr_Sumry(l_last_run+1, l_week, l_period, l_qtr,
		  l_year, l_min_date_id, l_max_date_id);
	   END IF;



     Else
       RAISE G_INVALID_DIM;
     END IF; -- errcheck ok



   	ELSE --Gap less than 3 days


	l_small_gap := TRUE;

	      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
	    bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'Inside gap less than 3 days');
         END IF;

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'Dates: l_last_run+1' || (l_last_run+1) ||
         ' and l_date-1' || (l_date-1)  ||
         ' and l_first_fact_run' || (l_first_fact_run) );
   END IF;


	 Insert_Into_Stg_SmallGap(l_last_run+1, l_date-1, l_first_fact_run);



	 Populate_Curr_Rate_SmallGap;
     l_failure_from := l_last_run+1;
     l_failure_to   := l_date-1;


     Summary_Err_Check_SmallGap(x_valid_curr => l_valid_curr,
                        x_valid_date => l_valid_date,
                        x_valid_prod => l_valid_prod,
                        x_return_warn => l_return_warn);





	 IF ((l_valid_curr = 'Y') AND (l_valid_date = 'Y') ) THEN

	 --Insert the first day of the gap, since gap_fill will only insert from 2nd day on
	 Ins_Into_CurrSum_SmGap(l_last_run+1,  l_week, l_period, l_qtr,
		  l_year, l_min_date_id, l_max_date_id);

	 ELSE
	 	 RAISE G_INVALID_DIM;
	END IF;


	END IF; --gap more or less than 3 days


       -- this will loop through the rest
       Gap_Fill(l_last_run+2, l_date-1, l_curr_coll_start, 'INCR', l_small_gap) ;



 END IF; -- initial/incr gap

       -- Added by TR (to populate the correct period_to and period_from dates in Attribute
       --  columns of bis_refresh_log)
       SELECT TO_CHAR(MIN(snap_date),'DD-MM-YYYY')
         INTO l_period_from
         FROM bil_bi_pipec_f;

		  SELECT TO_CHAR(MAX(snap_date),'DD-MM-YYYY')
         INTO  l_period_to
         FROM bil_bi_pipec_f;

 IF l_curr_coll_start BETWEEN l_last_run+2 and l_date-1 THEN
--Insert into bis_refresh_log for both tables: bil_bi_pipeline_f and bil_bi_pipec_f


     INSERT INTO bis_refresh_log
     (
       Request_id,
       Concurrent_id,
       Object_name,
       Status,
       Start_date,
       Period_from,
       Period_to,
       Number_processed_record,
       Exception_message,
       Creation_date,
       Created_by,
       Last_update_date,
       Last_update_login,
       Last_updated_by
     )
     VALUES
     (
       g_request_id,
       g_program_id,
       'BIL_BI_PIPELINE_F',
       'SUCCESS',
       g_program_start,
       l_last_run+1,
       l_curr_coll_start-1,
       g_row_num,
       'Successful gap fill',
       sysdate,
       g_user_id,
       sysdate,
       g_login_id,
       g_user_id
     );
     commit;


     INSERT INTO bis_refresh_log
     (
       Request_id,
       Concurrent_id,
       Object_name,
       Status,
       Start_date,
       Period_from,
       Period_to,
       Number_processed_record,
       Exception_message,
       Creation_date,
       Created_by,
       Last_update_date,
       Last_update_login,
       Last_updated_by,
       Attribute1,
       Attribute2
     )
     VALUES
     (
       g_request_id,
       g_program_id,
       'BIL_BI_PIPEC_F',
       'SUCCESS',
       g_program_start,
       l_curr_coll_start,
       l_date-1,
       g_row_num,
       'Successful gap fill',
       sysdate,
       g_user_id,
       sysdate,
       g_login_id,
       g_user_id,
       l_period_from,
       l_period_to
     );
     commit;

ELSE
-- l_coll_start is before the beggining of the gap
-- so innsert only in the current pipeline table
--this is the only other possible case, since we are always
--collecting up to sysdate (or opty base sumry last run)
     INSERT INTO bis_refresh_log
     (
       Request_id,
       Concurrent_id,
       Object_name,
       Status,
       Start_date,
       Period_from,
       Period_to,
       Number_processed_record,
       Exception_message,
       Creation_date,
       Created_by,
       Last_update_date,
       Last_update_login,
       Last_updated_by,
       Attribute1,
       Attribute2
     )
     VALUES
     (
       g_request_id,
       g_program_id,
       'BIL_BI_PIPEC_F',
       'SUCCESS',
       g_program_start,
       l_last_run+1,
       l_date-1,
       g_row_num,
       'Successful gap fill',
       sysdate,
       g_user_id,
       sysdate,
       g_login_id,
       g_user_id,
       l_period_from,
       l_period_to
     );
     commit;


END IF;



END IF; -- gap exists


    -- clean up

     bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPELINE_STG');
     bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_DENLOG_STG');
     --execute immediate 'Truncate table BIL_BI_DENLOG_STG';
     bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_DENLOG_TMP');
   -- regular snapshot

   -- delete the existing snapshot, since could be multiple runs anyway in the same day

    DELETE FROM bil_bi_pipec_f WHERE snap_date = l_date;
    commit;


	   -- get the first day in the current pipeline table to see if we need to delete
   SELECT MIN(snap_date)
   into l_min_curr_date
   FROM bil_bi_pipec_f;

   --delete from current pipeline table if data is older than 3 weeks
      IF l_min_curr_date < l_curr_coll_start THEN
    DELETE_FROM_CURR(l_curr_coll_start);
   END IF;

    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'l_min_curr_date is :' ||l_min_curr_date || ' l_curr_coll_start is : ' ||l_curr_coll_start);

    END IF;



    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc ,
        p_msg => 'Deleted  '|| sql%rowcount ||' rows from  BIL_BI_PIPEC_F for '||l_date
      );
    END IF;



     --- directly insert from opdtl_f into the pipec_f table

   	get_period_ids(l_date, x_day => l_day,
		x_week => l_week, x_period => l_period, x_qtr => l_qtr,
		  x_year => l_year, x_min_date_id => l_min_date_id, x_max_date_id => l_max_date_id);


		 BEGIN
                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.sd_pwk(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lwk, IN l_date;

                 SELECT week_end_date
                 INTO l_sd_lwk_end
                 from fii_time_day
                 where report_date=l_sd_lwk;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_pper_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lper, IN l_date;

                 SELECT LEAST(week_end_date, ent_period_end_date)
                 INTO l_sd_lper_end
                 from fii_time_day
                 where report_date=l_sd_lper;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_pqtr_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lqtr, IN l_date;

                 SELECT LEAST(week_end_date, ent_qtr_end_date)
                 INTO l_sd_lqtr_end
                 from fii_time_day
                 where report_date=l_sd_lqtr;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_lyr_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lyr, IN l_date;

                  SELECT LEAST(week_end_date, ent_year_end_date)
                 INTO l_sd_lyr_end
                 from fii_time_day
                 where report_date=l_sd_lyr;

EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
END;


       --also insert prior amounts from bil_bi_pipeline_f
--since we may not have data for the same day last week/quarter/period/year in the hist. table
--we need to get the end of the week/quarter ...
--if the same day last year is closer to the end of a certain week/quarter/period
--than to the end of te year, get the closest date
-- this can be achieved by using the bil_bi_time table:

			 INSERT /*+ append parallel(f) */INTO bil_bi_pipec_f f
			      (
			        sales_group_id,
			        salesrep_id,
			        created_by ,
			        creation_date,
			        last_updated_by,
			        last_update_date,
			        last_update_login,
			        request_id,
			        program_application_id,
			        program_id,
			        program_update_date,
			        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
			        pipeline_amt_day,
			        pipeline_amt_week,
			        pipeline_amt_period,
			        pipeline_amt_quarter,
			        pipeline_amt_year,
			        open_amt_day,
			        open_amt_week,
			        open_amt_period,
			        open_amt_quarter,
			        open_amt_year,
			        pipeline_amt_day_s,
			        pipeline_amt_week_s,
			        pipeline_amt_period_s,
			        pipeline_amt_quarter_s,
			        pipeline_amt_year_s,
			        open_amt_day_s,
			        open_amt_week_s,
			        open_amt_period_s,
			        open_amt_quarter_s,
			        open_amt_year_s,

                    prvprd_pipe_amt_wk  ,
                    prvprd_pipe_amt_PRD ,
                    prvprd_pipe_amt_qtr ,
                    prvprd_pipe_amt_yr  ,
                    prvprd_open_amt_wk  ,
                    prvprd_open_amt_PRD ,
                    prvprd_open_amt_qtr ,
                    prvprd_open_amt_yr  ,
                    prvprd_pipe_amt_wk_s,
                    prvprd_pipe_amt_PRD_s,
                    prvprd_pipe_amt_qtr_s,
                    prvprd_pipe_amt_yr_s,
                    prvprd_open_amt_wk_s,
                    prvprd_open_amt_PRD_s,
                    prvprd_open_amt_qtr_s,
                    prvprd_open_amt_yr_s,

                    prvyr_pipe_amt_wk   ,
                    prvyr_pipe_amt_PRD  ,
                    prvyr_pipe_amt_qtr  ,
                    prvyr_pipe_amt_yr   ,
                                        prvyr_open_amt_wk   ,
                    prvyr_open_amt_PRD  ,
                    prvyr_open_amt_qtr  ,
                    prvyr_open_amt_yr   ,
                    prvyr_pipe_amt_wk_s ,
                    prvyr_pipe_amt_PRD_s,
                    prvyr_pipe_amt_qtr_s,
                    prvyr_pipe_amt_yr_s ,
                    prvyr_open_amt_wk_s ,
                    prvyr_open_amt_PRD_s,
                    prvyr_open_amt_qtr_s,
                    prvyr_open_amt_yr_s
                      )

                            SELECT sales_group_id,
			        salesrep_id,
		            g_user_id created_by,
			        SYSDATE creation_date,
			        g_user_id last_updated_by,
			        SYSDATE last_update_date,
			        G_Login_Id last_update_login,
        			G_request_id request_id,
        			G_appl_id program_application_id,
        			G_program_id program_id,
			        SYSDATE program_update_date,	        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    SUM(pipeline_amt_day) pipeline_amt_day,
                    SUM(pipeline_amt_week) pipeline_amt_week,
                    SUM(pipeline_amt_period) pipeline_amt_period,
                    SUM(pipeline_amt_quarter) pipeline_amt_quarter,
                    SUM(pipeline_amt_year) pipeline_amt_year,
                    SUM(open_amt_day)  open_amt_day   ,
                    SUM(open_amt_week)  open_amt_week  ,
                    SUM(open_amt_period) open_amt_period ,
                    SUM(open_amt_quarter) open_amt_quarter,
                    SUM(open_amt_year) open_amt_year   ,
                    SUM(pipeline_amt_day_s) pipeline_amt_day_s,
                    SUM(pipeline_amt_week_s) pipeline_amt_week_s,
                    SUM(pipeline_amt_period_s) pipeline_amt_period_s,
                    SUM(pipeline_amt_quarter_s) pipeline_amt_quarter_s,
                    SUM(pipeline_amt_year_s) pipeline_amt_year_s,
                    SUM(open_amt_day_s) open_amt_day_s  ,
                    SUM(open_amt_week_s) open_amt_week_s ,
                    SUM(open_amt_period_s) open_amt_period_s,
                    SUM(open_amt_quarter_s) open_amt_quarter_s,
                    SUM(open_amt_year_s) open_amt_year_s ,
                                SUM(prvprd_pipe_amt_wk)  prvprd_pipe_amt_wk,
                SUM(prvprd_pipe_amt_PRD) prvprd_pipe_amt_PRD,
                SUM(prvprd_pipe_amt_qtr) prvprd_pipe_amt_qtr,
                SUM(prvprd_pipe_amt_yr) prvprd_pipe_amt_yr ,
                SUM(prvprd_open_amt_wk) prvprd_open_amt_wk ,
                SUM(prvprd_open_amt_PRD) prvprd_open_amt_PRD,
                SUM(prvprd_open_amt_qtr) prvprd_open_amt_qtr,
                SUM(prvprd_open_amt_yr)  prvprd_open_amt_yr,
                SUM(prvprd_pipe_amt_wk_s)  prvprd_pipe_amt_wk_s,
                SUM(prvprd_pipe_amt_PRD_s) prvprd_pipe_amt_PRD_s,
                SUM(prvprd_pipe_amt_qtr_s) prvprd_pipe_amt_qtr_s,
                SUM(prvprd_pipe_amt_yr_s) prvprd_pipe_amt_yr_s ,
                SUM(prvprd_open_amt_wk_s) prvprd_open_amt_wk_s ,
                SUM(prvprd_open_amt_PRD_s) prvprd_open_amt_PRD_s,
                SUM(prvprd_open_amt_qtr_s) prvprd_open_amt_qtr_s,
                SUM(prvprd_open_amt_yr_s) prvprd_open_amt_yr_s,
                SUM(prvyr_pipe_amt_wk)  prvyr_pipe_amt_wk ,
                SUM(prvyr_pipe_amt_PRD)  prvyr_pipe_amt_PRD,
                SUM(prvyr_pipe_amt_qtr)  prvyr_pipe_amt_qtr,
                SUM(prvyr_pipe_amt_yr) prvyr_pipe_amt_yr  ,
                SUM(prvyr_open_amt_wk) prvyr_open_amt_wk   ,
                SUM(prvyr_open_amt_PRD) prvyr_open_amt_PRD ,
                SUM(prvyr_open_amt_qtr) prvyr_open_amt_qtr ,
                SUM(prvyr_open_amt_yr) prvyr_open_amt_yr  ,
                SUM(prvyr_pipe_amt_wk_s)  prvyr_pipe_amt_wk_s ,
                SUM(prvyr_pipe_amt_PRD_s) prvyr_pipe_amt_PRD_s ,
                SUM(prvyr_pipe_amt_qtr_s) prvyr_pipe_amt_qtr_s ,
                SUM(prvyr_pipe_amt_yr_s)   prvyr_pipe_amt_yr_s,
                SUM(prvyr_open_amt_wk_s) prvyr_open_amt_wk_s  ,
                SUM(prvyr_open_amt_PRD_s) prvyr_open_amt_PRD_s ,
                SUM(prvyr_open_amt_qtr_s) prvyr_open_amt_qtr_s ,
                SUM(prvyr_open_amt_yr_s) prvyr_open_amt_yr_s
                  FROM (
			      SELECT /*+ no_merge parallel(FACT) parallel(TIME) */
			        SALES_GROUP_ID,
			        SALESREP_ID,
			        l_date snap_date,
			        ITEM_ID,
			        ITEM_ORGANIZATION_ID,
			        decode(fact.win_loss_indicator, 'W', 100, fact.WIN_PROBABILITY) win_probability,
			        PRODUCT_CATEGORY_ID,

        SUM(CASE
            WHEN time.report_date = l_date
            THEN fact.sales_credit_amt ELSE NULL END
        ) pipeline_amt_day,
        SUM(CASE
            WHEN time.week_id = l_week
            THEN fact.sales_credit_amt ELSE NULL END
        ) pipeline_amt_week,
        SUM(CASE
            WHEN time.ent_period_id = l_period
            THEN fact.sales_credit_amt ELSE NULL END ) pipeline_amt_period,
        SUM(CASE
            WHEN time.ent_qtr_id = l_qtr
            THEN fact.sales_credit_amt ELSE NULL END ) pipeline_amt_quarter,
        SUM(CASE
            WHEN time.ent_year_id = l_year
            THEN fact.sales_credit_amt ELSE NULL END ) pipeline_amt_year,
         SUM( CASE
            WHEN time.report_date = l_date  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt ELSE NULL END) open_amt_day,
        SUM( CASE
            WHEN time.week_id = l_week and open_status_flag = 'Y'
            THEN fact.sales_credit_amt ELSE NULL END) open_amt_week,
        SUM(CASE
            WHEN time.ent_period_id = l_period  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt ELSE NULL END ) open_amt_period,
        SUM(CASE
            WHEN time.ent_qtr_id = l_qtr  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt ELSE NULL END ) open_amt_quarter,
        SUM(CASE
            WHEN time.ent_year_id = l_year  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt ELSE NULL END ) open_amt_year,
        SUM(CASE
            WHEN time.report_date = l_date
            THEN fact.sales_credit_amt_s ELSE NULL END
        ) pipeline_amt_day_s,
        SUM(CASE
            WHEN time.week_id = l_week
            THEN fact.sales_credit_amt_s ELSE NULL END
        ) pipeline_amt_week_s,
        SUM(CASE
            WHEN time.ent_period_id = l_period
            THEN fact.sales_credit_amt_s ELSE NULL END ) pipeline_amt_period_s,
        SUM(CASE
            WHEN time.ent_qtr_id = l_qtr
            THEN fact.sales_credit_amt_s ELSE NULL END ) pipeline_amt_quarter_s,
        SUM(CASE
            WHEN time.ent_year_id = l_year
            THEN fact.sales_credit_amt_s ELSE NULL END ) pipeline_amt_year_s,
         SUM( CASE
            WHEN time.report_date = l_date and open_status_flag = 'Y'
            THEN fact.sales_credit_amt_s ELSE NULL END) open_amt_day_s,
        SUM( CASE
            WHEN time.week_id = l_week  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt_s ELSE NULL END) open_amt_week_s,
        SUM(CASE
            WHEN time.ent_period_id = l_period  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt_s ELSE NULL END ) open_amt_period_s,
        SUM(CASE
            WHEN time.ent_qtr_id = l_qtr  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt_s ELSE NULL END ) open_amt_quarter_s,
        SUM(CASE
            WHEN time.ent_year_id = l_year  and open_status_flag = 'Y'
            THEN fact.sales_credit_amt_s ELSE NULL END ) open_amt_year_s,
                null prvprd_pipe_amt_wk  ,
                null prvprd_pipe_amt_PRD ,
                null prvprd_pipe_amt_qtr ,
                null prvprd_pipe_amt_yr  ,
                null prvprd_open_amt_wk  ,
                null prvprd_open_amt_PRD ,
                null prvprd_open_amt_qtr ,
                null prvprd_open_amt_yr  ,
                null prvprd_pipe_amt_wk_s,
                null prvprd_pipe_amt_PRD_s,
                null prvprd_pipe_amt_qtr_s,
                null prvprd_pipe_amt_yr_s,
                null prvprd_open_amt_wk_s,
                null prvprd_open_amt_PRD_s,
                null prvprd_open_amt_qtr_s,
                null prvprd_open_amt_yr_s,
                null prvyr_pipe_amt_wk   ,
                null prvyr_pipe_amt_PRD  ,
                null prvyr_pipe_amt_qtr  ,
                null prvyr_pipe_amt_yr   ,
                null prvyr_open_amt_wk   ,
                null prvyr_open_amt_PRD  ,
                null prvyr_open_amt_qtr  ,
                null prvyr_open_amt_yr   ,
                null prvyr_pipe_amt_wk_s ,
                null prvyr_pipe_amt_PRD_s,
                null prvyr_pipe_amt_qtr_s,
                null prvyr_pipe_amt_yr_s ,
                null prvyr_open_amt_wk_s ,
                null prvyr_open_amt_PRD_s,
                null prvyr_open_amt_qtr_s,
                null prvyr_open_amt_yr_s

		        FROM
        bil_bi_opdtl_f fact,
        fii_time_day time
      WHERE
        fact.OPTY_CLOSE_TIME_ID =  time.report_date_julian
        and forecast_rollup_flag = 'Y'
        and fact.OPTY_CLOSE_TIME_ID between l_min_date_id and l_max_date_id
      GROUP BY
        sales_group_id,
        salesrep_id,
        item_id,
        item_organization_id,
        decode(fact.win_loss_indicator, 'W', 100, fact.WIN_PROBABILITY),
        product_category_id
      HAVING
        SUM(CASE
            WHEN time.week_id = l_week
            THEN fact.sales_credit_amt ELSE NULL END
        ) is not null or
        SUM(CASE
            WHEN time.ent_year_id = l_year
            THEN fact.sales_credit_amt ELSE NULL END ) is not null
     UNION ALL
                      SELECT /*+ parallel(f) */ sales_group_id,
			        salesrep_id,
			        l_date snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    null pipeline_amt_day ,
                    null pipeline_amt_week,
                    null pipeline_amt_period,
                    null pipeline_amt_quarter,
                    null pipeline_amt_year,
                    null open_amt_day     ,
                    null open_amt_week    ,
                    null open_amt_period  ,
                    null open_amt_quarter ,
                    null open_amt_year    ,
                    null pipeline_amt_day_s ,
                    null pipeline_amt_week_s,
                    null pipeline_amt_period_s ,
                    null pipeline_amt_quarter_s,
                    null pipeline_amt_year_s,
                    null open_amt_day_s   ,
                    null open_amt_week_s  ,
                    null open_amt_period_s,
                    null open_amt_quarter_s,
                    null open_amt_year_s,
				decode(f.snap_date, l_sd_lwk_end, pipeline_amt_week, null) prvprd_pipe_amt_wk  ,
                decode(f.snap_date, l_sd_lper_end, pipeline_amt_period, null) prvprd_pipe_amt_PRD ,
                decode(f.snap_date, l_sd_lqtr_end, pipeline_amt_quarter, null) prvprd_pipe_amt_qtr ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year, null) prvprd_pipe_amt_yr  ,
                decode(f.snap_date, l_sd_lwk_end, open_amt_week, null) prvprd_open_amt_wk  ,
                decode(f.snap_date, l_sd_lper_end, open_amt_period, null) prvprd_open_amt_PRD ,
                decode(f.snap_date, l_sd_lqtr_end, open_amt_quarter, null) prvprd_open_amt_qtr ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvprd_open_amt_yr  ,
                decode(f.snap_date, l_sd_lwk_end, pipeline_amt_week_s, null) prvprd_pipe_amt_wk_s  ,
                decode(f.snap_date, l_sd_lper_end, pipeline_amt_period_s, null) prvprd_pipe_amt_PRD_s ,
                decode(f.snap_date, l_sd_lqtr_end, pipeline_amt_quarter_s, null) prvprd_pipe_amt_qtr_s ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year_s, null) prvprd_pipe_amt_yr_s  ,
                decode(f.snap_date, l_sd_lwk_end, open_amt_week_s, null) prvprd_open_amt_wk_s  ,
                decode(f.snap_date, l_sd_lper_end, open_amt_period_s, null) prvprd_open_amt_PRD_s ,
                decode(f.snap_date, l_sd_lqtr_end, open_amt_quarter_s, null) prvprd_open_amt_qtr_s ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year_s, null) prvprd_open_amt_yr_s,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_week, null) prvyr_pipe_amt_wk   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_period, null) prvyr_pipe_amt_PRD  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_quarter, null) prvyr_pipe_amt_qtr  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year, null) prvyr_pipe_amt_yr   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_week, null) prvyr_open_amt_wk   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_period, null) prvyr_open_amt_PRD  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_quarter, null) prvyr_open_amt_qtr  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvyr_open_amt_yr   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_week_s, null) prvyr_pipe_amt_wk_s   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_period_s, null) prvyr_pipe_amt_PRD_s  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_quarter_s, null) prvyr_pipe_amt_qtr_s  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year_s, null) prvyr_pipe_amt_yr_s   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_week_s, null) prvyr_open_amt_wk_s   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_period, null) prvyr_open_amt_PRD_s  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_quarter, null) prvyr_open_amt_qtr_s  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvyr_open_amt_yr_s
                    FROM BIL_BI_PIPELINE_F f
                    where snap_date in (l_sd_lwk_end, l_sd_lper_end
                    ,l_sd_lqtr_end, l_sd_lyr_end)
					UNION ALL
                      SELECT  sales_group_id,
			        salesrep_id,
			        l_date snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    null pipeline_amt_day ,
                    null pipeline_amt_week,
                    null pipeline_amt_period,
                    null pipeline_amt_quarter,
                    null pipeline_amt_year,
                    null open_amt_day     ,
                    null open_amt_week    ,
                    null open_amt_period  ,
                    null open_amt_quarter ,
                    null open_amt_year    ,
                    null pipeline_amt_day_s ,
                    null pipeline_amt_week_s,
                    null pipeline_amt_period_s ,
                    null pipeline_amt_quarter_s,
                    null pipeline_amt_year_s,
                    null open_amt_day_s   ,
                    null open_amt_week_s  ,
                    null open_amt_period_s,
                    null open_amt_quarter_s,
                    null open_amt_year_s  ,
                pipeline_amt_week prvprd_pipe_amt_wk  ,
                null prvprd_pipe_amt_PRD ,
                null prvprd_pipe_amt_qtr ,
                null prvprd_pipe_amt_yr  ,
                open_amt_week prvprd_open_amt_wk  ,
                null prvprd_open_amt_PRD ,
                null prvprd_open_amt_qtr ,
                null prvprd_open_amt_yr  ,
                pipeline_amt_week_s prvprd_pipe_amt_wk_s  ,
                null prvprd_pipe_amt_PRD_s ,
                null prvprd_pipe_amt_qtr_s ,
                null prvprd_pipe_amt_yr_s  ,
                open_amt_week_s prvprd_open_amt_wk_s  ,
                null prvprd_open_amt_PRD_s ,
                null prvprd_open_amt_qtr_s ,
                null prvprd_open_amt_yr_s,
                null prvyr_pipe_amt_wk   ,
                null prvyr_pipe_amt_PRD  ,
                null prvyr_pipe_amt_qtr  ,
                null prvyr_pipe_amt_yr   ,
                null prvyr_open_amt_wk   ,
                null prvyr_open_amt_PRD  ,
                null prvyr_open_amt_qtr  ,
                null prvyr_open_amt_yr   ,
                null prvyr_pipe_amt_wk_s   ,
                null prvyr_pipe_amt_PRD_s  ,
                null prvyr_pipe_amt_qtr_s  ,
                null prvyr_pipe_amt_yr_s   ,
                null prvyr_open_amt_wk_s   ,
                null prvyr_open_amt_PRD_s  ,
                null prvyr_open_amt_qtr_s  ,
                null prvyr_open_amt_yr_s
                    FROM BIL_BI_PIPEC_F f
                    where snap_date = l_sd_lwk
                     )
                    GROUP BY
                       sales_group_id,
			        salesrep_id,
			        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id

                    ;






     g_row_num:= sql%rowcount;
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
       bil_bi_util_collection_pkg.writeLog
       (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'Inserted  '|| g_row_num ||' into BIL_BI_PIPEC_F table from BIL_BI_OPDTL_F for date'
           || l_date
       );
     END IF;

  commit;
--   BIS_COLLECTION_UTILITIES.wrapup(TRUE,
  --         g_row_num,
    --       'Snapshot taken for ' || l_date,
      --     l_date,
        --   l_date );

       SELECT TO_CHAR(MIN(snap_date),'DD-MM-YYYY')
         INTO l_period_from
         FROM bil_bi_pipec_f;


		        SELECT
              TO_CHAR(MAX(snap_date),'DD-MM-YYYY')
         INTO
              l_period_to
         FROM bil_bi_pipec_f;


		INSERT INTO bis_refresh_log
     (
       Request_id,
       Concurrent_id,
       Object_name,
       Status,
       Start_date,
       Period_from,
       Period_to,
       Number_processed_record,
       Exception_message,
       Creation_date,
       Created_by,
       Last_update_date,
       Last_update_login,
       Last_updated_by,
       Attribute1,
       Attribute2
     )
     VALUES
     (
       g_request_id,
       g_program_id,
       'BIL_BI_PIPEC_F',
       'SUCCESS',
       g_program_start,
       l_date,
       l_date,
       g_row_num,
       'Snapshot taken for ' || l_date,
       sysdate,
       g_user_id,
       sysdate,
       g_login_id,
       g_user_id,
       l_period_from,
       l_period_to
     );

    commit;

     IF (l_return_warn = 'Y' or l_return_warn_resume= 'Y') THEN
        retcode := 1;
        ELSE
        retcode := 0;
     END IF;


/*
  A generic line in the log file that requests the user to see the o/p file for
  further info.
*/
    IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
      bil_bi_util_collection_pkg.writeLog
      (
        p_log_level => fnd_log.LEVEL_EVENT,
        p_module => g_pkg || l_proc,
        p_msg =>
          ' If there have been errors, Please refer to the Concurrent program output file for more information '
      );
    END IF;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
   END IF;

   EXCEPTION
   WHEN G_BIS_SETUP_ERROR THEN
     ROLLBACK;
     -- no point calling wrapup if setup is not successful
     retcode :=  -1;

   WHEN G_SETUP_VAL_ERROR THEN
     ROLLBACK;
     BIS_COLLECTION_UTILITIES.wrapup(FALSE,
           g_row_num,
           'Setup issues detected.',
           l_date,
           l_date
           );
     retcode := -1;

  WHEN G_INVALID_DIM THEN
     -- no need to rollback or truncate, resume will take care this
     commit;


     BIS_COLLECTION_UTILITIES.wrapup(FALSE,
           g_row_num,
           'Time/Currency dimension not setup.',
           l_failure_from,
           l_failure_to
           );
     retcode := -1;
   WHEN OTHERS Then


      bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_PIPELINE_STG');
      bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_DENLOG_STG');
      --execute immediate 'Truncate table BIL_BI_DENLOG_STG';
     bil_bi_util_collection_pkg.Truncate_Table('BIL_BI_OPDTL_DENLOG_TMP');

  commit;
  BIS_COLLECTION_UTILITIES.wrapup(FALSE,
           g_row_num,
           SQLERRM,
           l_date,
           l_date
           );

       fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
       fnd_message.set_token('ERRNO' ,SQLCODE);
       fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
       bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);
  retcode := -1;
   END;


PROCEDURE Populate_Currency_Rate(p_mode IN varchar2) IS
  l_proc     VARCHAR2(100);
 BEGIN
 l_proc  := 'Populate_Currency_Rate';

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;

   IF (p_mode = 'INIT') THEN
     MERGE /*+ parallel(sumry) */ INTO BIL_BI_CURRENCY_RATE sumry
     USING
     (
       SELECT
         txn_currency,
         effective_date,
                DECODE(txn_currency,g_prim_currency,1,fii_currency.get_global_rate_primary(txn_currency,
                                                            trunc(least(sysdate,effective_date))))  prate,
         DECODE(g_sec_currency,NULL,NULL,decode(txn_currency,g_sec_currency,1,
           fii_currency.get_global_rate_secondary(txn_currency,trunc(least(sysdate,effective_date))))) srate

       FROM
       (
         SELECT
           DISTINCT txn_currency,
           effective_date
         FROM
         (
           select /*+ parallel(stg) */ txn_currency, effective_date
           from bil_bi_pipeline_stg stg
         where effective_date >= g_global_start_date
           UNION ALL
           select /*+ parallel(stg) */ currency_code, decision_date
           from BIL_BI_DENLOG_STG stg
           where decision_date >= g_global_start_date
         )
       )
     ) rates
     ON
     (
       rates.txn_currency = sumry.currency_code
       AND rates.effective_date = sumry.exchange_date
     )
     WHEN MATCHED THEN
       UPDATE SET sumry.exchange_rate = rates.prate,sumry.exchange_rate_s = rates.srate
     WHEN NOT MATCHED THEN
       INSERT
       (
         sumry.currency_code,
         sumry.exchange_date,
         sumry.exchange_rate,
         sumry.exchange_rate_s
       )
       VALUES
       (
         rates.txn_currency,
         rates.effective_date,
         rates.prate,
         rates.srate
       );

	   	--gather stats on bil_bi_currency_rate during initial load
	bil_bi_util_collection_pkg.analyze_table('BIL_BI_CURRENCY_RATE',TRUE, 10, 'GLOBAL');

    ELSE
      MERGE INTO BIL_BI_CURRENCY_RATE sumry
     USING
     (
       SELECT
         txn_currency,
         effective_date,
        DECODE(txn_currency,g_prim_currency,1,fii_currency.get_global_rate_primary(txn_currency,
                                                            trunc(least(sysdate,effective_date))))  prate,
         DECODE(g_sec_currency,NULL,NULL,decode(txn_currency,g_sec_currency,1,
           fii_currency.get_global_rate_secondary(txn_currency,trunc(least(sysdate,effective_date)))))  srate

       FROM
       (
         SELECT
           DISTINCT txn_currency,
           effective_date
         FROM
         (
           select txn_currency, effective_date
           from bil_bi_pipeline_stg stg
           where effective_date >= g_global_start_date
           UNION ALL
           select currency_code, decision_date
           from BIL_BI_DENLOG_STG stg
           where decision_date >= g_global_start_date
         )
       )
     ) rates
     ON
     (
       rates.txn_currency = sumry.currency_code
       AND rates.effective_date = sumry.exchange_date
     )
     WHEN MATCHED THEN
       UPDATE SET sumry.exchange_rate = rates.prate,sumry.exchange_rate_s = rates.srate
     WHEN NOT MATCHED THEN
       INSERT
       (
         sumry.currency_code,
         sumry.exchange_date,
         sumry.exchange_rate,
         sumry.exchange_rate_s
       )
       VALUES
       (
         rates.txn_currency,
         rates.effective_date,
         rates.prate,
         rates.srate
       );
    END IF;

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    p_module => g_pkg || l_proc ,
    p_msg => 'Inserted  '||sql%rowcount||' into bil_bi_currency_rate table');
  END IF;
  commit;
  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;
 EXCEPTION
   WHEN OTHERS THEN
      fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  RAISE;
 END   Populate_Currency_Rate;


PROCEDURE Summary_Err_Check(p_mode IN Varchar2,
			    x_valid_curr OUT NOCOPY VARCHAR2,
                            x_valid_date OUT NOCOPY VARCHAR2,
                            x_valid_prod OUT NOCOPY VARCHAR2,
                            x_return_warn OUT NOCOPY VARCHAR2
                            ) IS

      l_time_cnt          NUMBER;
      l_conv_rate_cnt     NUMBER;
      l_stg_min           NUMBER;
      l_stg_max           NUMBER;
      l_stg_min_txn_dt         DATE;
      l_stg_max_txn_dt         DATE;
      l_stg_min_eff_dt         DATE;
      l_stg_max_eff_dt         DATE;
      l_stg_min_dt         DATE;
      l_stg_max_dt         DATE;
      l_day_min           NUMBER;
      l_day_max           NUMBER;
      l_has_missing_date   BOOLEAN;
      l_count       NUMBER;
      l_lead_num    NUMBER;
      l_eff_date    DATE;
      l_number_of_rows     NUMBER;
      l_int_type       VARCHAR2(100);
      l_prim_code      VARCHAR2(100);
      l_sec_code       VARCHAR2(100);
      l_warn       VARCHAR2(1);

--      l_prim_miss BOOLEAN :=FALSE;
--      l_sec_miss  BOOLEAN :=FALSE;

     cursor c_item_prod is
      SELECT lead_number  FROM bil_bi_pipeline_stg
      WHERE  nvl(product_category_id,-1)=-1
      and effective_date >= g_global_start_date
      union all
      SELECT lead_number  FROM BIL_BI_DENLOG_STG
      WHERE  nvl(product_category_id,-1)=-1
      and decision_date >= g_global_start_date;


   l_proc VARCHAR2(100);
BEGIN

      l_time_cnt :=0;
      l_conv_rate_cnt:=0;
      l_has_missing_date := FALSE;
      l_count :=0;
      l_number_of_rows :=0;
      l_proc := 'Summary_Err_Check';

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
   bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
  END IF;

IF(p_mode = 'INIT') THEN
      UPDATE /*+ parallel(stg) */ bil_bi_pipeline_stg stg
         SET  (stg.prim_conversion_rate,conversion_rate_s) =
           (
             select
               exchange_rate,exchange_rate_s
             from BIL_BI_CURRENCY_RATE
             where
               currency_code = stg.txn_currency and
               exchange_date = stg.effective_date
           );


       MERGE /*+ PARALLEL(stg) */ INTO bil_bi_denlog_stg stg
USING
  (SELECT /*+ PARALLEL(rates) */
    exchange_rate,
    exchange_rate_s,
    exchange_date,
    currency_code
  FROM
    bil_bi_currency_rate rates) curr_rate
ON (curr_rate.EXCHANGE_DATE = stg.decision_date AND curr_rate.currency_code = stg.currency_code)
WHEN MATCHED THEN
  UPDATE SET
    stg.prim_conversion_rate = curr_rate.exchange_rate,
    stg.conversion_rate_s = curr_rate.exchange_rate_s;

ELSE
     UPDATE  bil_bi_pipeline_stg stg
         SET  (stg.prim_conversion_rate,conversion_rate_s) =
           (
             select
               exchange_rate,exchange_rate_s
             from BIL_BI_CURRENCY_RATE
             where
               currency_code = stg.txn_currency and
               exchange_date = stg.effective_date
           );


      UPDATE BIL_BI_DENLOG_STG stg
         SET  (stg.prim_conversion_rate,conversion_rate_s) =
           (
             select
               exchange_rate,exchange_rate_s
             from BIL_BI_CURRENCY_RATE
             where
               currency_code = stg.currency_code and
               exchange_date = stg.decision_date
                );

END IF;


      IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    p_module => g_pkg || l_proc ,
    p_msg => 'Updated rates for '|| sql%rowcount || ' rows');
  END IF;

 -- need this commit for the rollup not to roll back all the currencys, doesn't really matter anyway
      commit;



IF(p_mode = 'INIT') THEN
      SELECT sum(cnt)
      INTO   l_conv_rate_cnt
      FROM   (
               select /*+ parallel(stg) */ count(1) cnt from BIL_BI_PIPELINE_STG stg
             WHERE  ((prim_conversion_rate < 0  OR  prim_conversion_rate IS NULL)
             OR (g_sec_currency IS NOT NULL and (conversion_rate_s < 0  OR  conversion_rate_s IS NULL)))
             and effective_date >= g_global_start_date
              union all
              select /*+ parallel(stg) */ count(1) cnt from BIL_BI_DENLOG_STG stg
             WHERE  ((prim_conversion_rate < 0  OR  prim_conversion_rate IS NULL)
             OR (g_sec_currency IS NOT NULL and (conversion_rate_s < 0  OR  conversion_rate_s IS NULL)))
             and decision_date >= g_global_start_date
             );
ELSE
     SELECT sum(cnt)
      INTO   l_conv_rate_cnt
      FROM   (
               select count(1) cnt from BIL_BI_PIPELINE_STG
             WHERE  ((prim_conversion_rate < 0  OR  prim_conversion_rate IS NULL)
             OR (g_sec_currency IS NOT NULL and (conversion_rate_s < 0  OR  conversion_rate_s IS NULL)))
             and effective_date >= g_global_start_date
              union all
              select count(1) cnt from BIL_BI_DENLOG_STG
             WHERE  ((prim_conversion_rate < 0  OR  prim_conversion_rate IS NULL)
             OR (g_sec_currency IS NOT NULL and (conversion_rate_s < 0  OR  conversion_rate_s IS NULL)))
             and decision_date >= g_global_start_date
             );

END IF;

     IF (l_conv_rate_cnt >0) THEN
       IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
         bil_bi_util_collection_pkg.writeLog
         (
           p_log_level =>fnd_log.LEVEL_ERROR,
           p_module => g_pkg || l_proc ,
           p_msg => 'Missing currency conversion rates found, program will exit with error status.'||
           'Please fix the missing conversion rates'
         );
       END IF;
       Report_Missing_Rates;
--       l_prim_miss := TRUE;
      x_valid_curr := 'N';
    ELSE
      x_valid_curr := 'Y';
     END IF;


/*also for effective date. need to call the time api*/

IF(p_mode = 'INIT') THEN
     SELECT   MIN(stg.SNAP_DATE), Max(stg.SNAP_DATE)
             ,MIN(stg.Effective_DATE), Max(stg.Effective_DATE)
      INTO   l_stg_min_txn_dt, l_stg_max_txn_dt, l_stg_min_eff_dt, l_stg_max_eff_dt
      FROM   (select /*+ parallel(stg) stg*/ snap_date , effective_date from BIL_BI_PIPELINE_STG stg
              where effective_date >= g_global_start_date
              union all
              select /*+ parallel(stg) stg*/last_update_date snap_date,  decision_date effective_date from BIL_BI_DENLOG_STG stg
              where decision_date >= g_global_start_date) stg;
ELSE
     SELECT   MIN(stg.SNAP_DATE), Max(stg.SNAP_DATE)
             ,MIN(stg.Effective_DATE), Max(stg.Effective_DATE)
      INTO   l_stg_min_txn_dt, l_stg_max_txn_dt, l_stg_min_eff_dt, l_stg_max_eff_dt
      FROM   (select snap_date , effective_date from BIL_BI_PIPELINE_STG
              where effective_date >= g_global_start_date
              union all
              select last_update_date snap_date,  decision_date effective_date from BIL_BI_DENLOG_STG
              where decision_date >= g_global_start_date) stg;
END IF;

      IF (l_stg_min_txn_dt < l_stg_min_eff_dt) THEN
         l_stg_min_dt := l_stg_min_txn_dt;
      ELSE
         l_stg_min_dt := l_stg_min_eff_dt;
      END IF;

      IF (l_stg_max_txn_dt < l_stg_max_eff_dt) THEN
         l_stg_max_dt := l_stg_max_eff_dt;
      ELSE
         l_stg_max_dt := l_stg_max_txn_dt;
      END IF;


      --write_log(p_msg => 'Date range:'||l_stg_min_dt||'  '||l_stg_max_dt, p_log => 'N');
IF l_stg_min_dt IS NOT NULL AND l_stg_max_dt IS NOT NULL THEN
      FII_TIME_API.check_missing_date (l_stg_min_dt,l_stg_max_dt,l_has_missing_date);

END IF;
      IF (l_has_missing_date) THEN
        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => 'Time Dimension is not fully populated. '||
              ' Please populate Time dimension to cover the date range you are collecting');
        END IF;
         x_valid_date := 'N';
      Else
         x_valid_date := 'Y';
      END IF;

--   ELSE
 --        x_valid_curr := 'Y';
 --     x_valid_date := 'Y';
 --  END IF;        --- incremental mode only

      --- The following check applies both initial and incremental mode

      -- check for oppty close date  => don't need in this case since it is already restricted.

       -- check for bad item/product
  l_number_of_rows := 0;
      OPEN c_item_prod;
        LOOP
           FETCH c_item_prod into
          l_lead_num;
           EXIT WHEN c_item_prod%NOTFOUND ;
     l_number_of_rows :=l_number_of_rows + 1;

      IF(l_number_of_rows=1) THEN
      -- print header

        IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
          (
            p_log_level => fnd_log.LEVEL_EVENT,
            p_module => g_pkg || l_proc ,
            p_msg => ' Some opportunties had null product category. They have not been collected.'
          );
        END IF;

     fnd_message.set_name('BIL','BIL_BI_ITEM_PROD_WARN_HDR');
     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                          p_msg => fnd_message.get,
                          p_force_log => TRUE);
      END IF;

      -- print detail

     fnd_message.set_name('BIL','BIL_BI_ITEM_PROD_ERR_DTL');
     fnd_message.set_token('OPPNUM', l_lead_num);
     bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                            p_module => g_pkg || l_proc || ' proc_error',
                          p_msg => fnd_message.get,
                          p_force_log => TRUE);


        END LOOP;
     CLOSE c_item_prod;


  IF ( l_number_of_rows  > 0) THEN
      x_valid_prod := 'N';
      x_return_warn := 'Y';
  ELSE
      x_valid_prod := 'Y';
      x_return_warn := 'N';
  END IF;


     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
     END IF;

EXCEPTION
      WHEN OTHERS THEN
        fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
      fnd_message.set_token('ERRNO' ,SQLCODE);
      fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
      bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);
  Raise;

END Summary_Err_Check;


PROCEDURE Report_Profile_Error(p_profile_name IN varchar2,
                               p_value IN varchar2,
                               p_exp_value IN varchar2) IS
l_proc       VARCHAR2(100);
BEGIN

 l_proc     := 'Report_Profile_Error';
IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;

      IF (g_setup_error_flag = FALSE) THEN

        g_setup_error_flag := TRUE;

        fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');
     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_ERROR) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                      p_module => g_pkg || l_proc || ' proc_error',
                    p_msg => fnd_message.get,
                    p_force_log => TRUE);

          END IF;

      END IF;
                      IF (p_value <> p_exp_value) THEN
      fnd_message.set_name('BIL','BIL_BI_PROFILE_WRONG_VALUE');
        fnd_message.set_token('PROFILE_USER_NAME' ,bil_bi_util_collection_pkg.get_user_profile_name(p_profile_name));
        fnd_message.set_token('PROFILE_INTERNAL_NAME' ,p_profile_name);
        fnd_message.set_token('PROFILE_VALUE' , p_exp_value);

     IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_ERROR) THEN
        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                           p_module => g_pkg || l_proc || ' proc_error',
                   p_msg => fnd_message.get,
                   p_force_log => TRUE);

      END IF;
     END IF;

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;

END  Report_Profile_Error;

PROCEDURE Report_Missing_Profile (p_profile_name IN varchar2) IS
  l_proc       VARCHAR2(100);
BEGIN
  l_proc  := 'Report_Missing_Profile';


  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog
    (
      p_log_level => fnd_log.LEVEL_PROCEDURE,
      p_module => g_pkg || l_proc || ' begin',
      p_msg => 'Start of Procedure '|| l_proc
    );
  END IF;

 -- print the header
      IF (g_setup_error_flag = FALSE) THEN
        g_setup_error_flag := TRUE;
        fnd_message.set_name('BIL','BIL_BI_SETUP_INCOMPLETE');
        bil_bi_util_collection_pkg.writeLog
        (
          p_log_level => fnd_log.LEVEL_ERROR,
          p_module => g_pkg || l_proc || ' proc_error',
          p_msg => fnd_message.get,
          p_force_log => TRUE
        );
      END IF;

        fnd_message.set_name('BIL','BIL_BI_PROFILE_MISSING');
      fnd_message.set_token('PROFILE_USER_NAME' ,bil_bi_util_collection_pkg.get_user_profile_name(p_profile_name));
      fnd_message.set_token('PROFILE_INTERNAL_NAME' ,p_profile_name);


        bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_ERROR,
                     p_module => g_pkg || l_proc || ' proc_error',
                   p_msg => fnd_message.get,
                   p_force_log => TRUE);

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;


END Report_Missing_Profile;


PROCEDURE Report_Missing_Rates IS

  l_stmt  VARCHAR2(500);
  l_count  NUMBER;

  cursor MissingRate_p is
    SELECT
      DISTINCT stg.txn_currency txn_currency,
      trunc( decode(stg.prim_conversion_rate,-3,to_date('01/01/1999','MM/DD/RRRR'),
            least(sysdate, stg.effective_date)) ) txn_date,
       decode(sign(nvl(stg.prim_conversion_rate,-1)),-1,'P') prim_curr_type,
       decode(sign(nvl(stg.CONVERSION_RATE_S,-1)),-1,'S')    sec_curr_type
    FROM  ( select txn_currency , effective_date, prim_conversion_rate, CONVERSION_RATE_S
            from  BIL_BI_PIPELINE_STG
            WHERE
            ((prim_conversion_rate < 0 OR prim_conversion_rate IS NULL )
            OR (g_sec_currency IS NOT NULL and (conversion_rate_s < 0  OR  conversion_rate_s IS NULL)))
            and effective_date >= g_global_start_date
            union all
            select currency_code , decision_date, prim_conversion_rate, CONVERSION_RATE_S
            from  BIL_BI_DENLOG_STG
            WHERE
            ((prim_conversion_rate < 0 OR prim_conversion_rate IS NULL )
            OR (g_sec_currency IS NOT NULL and (conversion_rate_s < 0  OR  conversion_rate_s IS NULL)))
            and decision_date >= g_global_start_date
      ) stg;

l_proc VARCHAR2(100);

BEGIN

l_proc := 'Report_Missing_Rates';

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;

   BIS_COLLECTION_UTILITIES.WriteMissingRateHeader;

IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_STATEMENT,
             p_module => g_pkg || l_proc,
             p_msg => 'Missing conversions');
 END IF;

  FOR rate_record in MissingRate_p  LOOP

     IF rate_record.prim_curr_type = 'P' THEN

    BIS_COLLECTION_UTILITIES.writemissingrate(
          g_prim_rate_type,
          rate_record.txn_currency,
          g_prim_currency,
          rate_record.txn_date);

 END IF;

     IF rate_record.sec_curr_type = 'S' THEN

       BIS_COLLECTION_UTILITIES.writemissingrate(
          g_sec_rate_type,
          rate_record.txn_currency,
          G_sec_Currency,
          rate_record.txn_date);

     END IF;

  END LOOP;


IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;

END Report_Missing_Rates;

PROCEDURE Insert_Into_Curr_sumry(p_date IN DATE,  p_week IN NUMBER, p_period IN NUMBER,
		  						 p_qtr IN NUMBER, p_year IN NUMBER, p_min_date_id IN NUMBER,
								 p_max_date_id IN NUMBER) IS

l_sd_lwk_end DATE;
l_sd_lper_end DATE;
l_sd_lqtr_end DATE;
l_sd_lyr_end DATE;
l_sd_lwk DATE;
l_sd_lper DATE;
l_sd_lqtr DATE;
l_sd_lyr DATE;
l_proc VARCHAR2(100);
l_dynamic_sql VARCHAR2(1000);

BEGIN

l_proc := 'Insert_Into_Curr_sumry';

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;

BEGIN
                              l_dynamic_sql := 'BEGIN :1 := fii_time_api.sd_pwk(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lwk, IN p_date;

                 SELECT week_end_date
                 INTO l_sd_lwk_end
                 from fii_time_day
                 where report_date=l_sd_lwk;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_pper_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lper, IN p_date;

                 SELECT LEAST(week_end_date, ent_period_end_date)
                 INTO l_sd_lper_end
                 from fii_time_day
                 where report_date=l_sd_lper;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_pqtr_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lqtr, IN p_date;

                 SELECT LEAST(week_end_date, ent_qtr_end_date)
                 INTO l_sd_lqtr_end
                 from fii_time_day
                 where report_date=l_sd_lqtr;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_lyr_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lyr, IN p_date;

                  SELECT LEAST(week_end_date, ent_year_end_date)
                 INTO l_sd_lyr_end
                 from fii_time_day
                 where report_date=l_sd_lyr;

EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
END;


       --also insert prior amounts from bil_bi_pipeline_f
--since we may not have data for the same day last week/quarter/period/year in the hist. table
--we need to get the end of the week/quarter ...
--if the same day last year is closer to the end of a certain week/quarter/period
--than to the end of te year, get the closest date
-- this can be achieved by using the bil_bi_time table:

	 INSERT /*+ append parallel(f) */INTO bil_bi_pipec_f f
			      (
			        sales_group_id,
			        salesrep_id,
			        created_by ,
			        creation_date,
			        last_updated_by,
			        last_update_date,
			        last_update_login,
			        request_id,
			        program_application_id,
			        program_id,
			        program_update_date,
			        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
			        pipeline_amt_day,
			        pipeline_amt_week,
			        pipeline_amt_period,
			        pipeline_amt_quarter,
			        pipeline_amt_year,
			        open_amt_day,
			        open_amt_week,
			        open_amt_period,
			        open_amt_quarter,
			        open_amt_year,
			        pipeline_amt_day_s,
			        pipeline_amt_week_s,
			        pipeline_amt_period_s,
			        pipeline_amt_quarter_s,
			        pipeline_amt_year_s,
			        open_amt_day_s,
			        open_amt_week_s,
			        open_amt_period_s,
			        open_amt_quarter_s,
			        open_amt_year_s,

                    prvprd_pipe_amt_wk  ,
                    prvprd_pipe_amt_PRD ,
                    prvprd_pipe_amt_qtr ,
                    prvprd_pipe_amt_yr  ,
                    prvprd_open_amt_wk  ,
                    prvprd_open_amt_PRD ,
                    prvprd_open_amt_qtr ,
                    prvprd_open_amt_yr  ,
                    prvprd_pipe_amt_wk_s,
                    prvprd_pipe_amt_PRD_s,
                    prvprd_pipe_amt_qtr_s,
                    prvprd_pipe_amt_yr_s,
                    prvprd_open_amt_wk_s,
                    prvprd_open_amt_PRD_s,
                    prvprd_open_amt_qtr_s,
                    prvprd_open_amt_yr_s,

                    prvyr_pipe_amt_wk   ,
                    prvyr_pipe_amt_PRD  ,
                    prvyr_pipe_amt_qtr  ,
                    prvyr_pipe_amt_yr   ,
                                        prvyr_open_amt_wk   ,
                    prvyr_open_amt_PRD  ,
                    prvyr_open_amt_qtr  ,
                    prvyr_open_amt_yr   ,
                    prvyr_pipe_amt_wk_s ,
                    prvyr_pipe_amt_PRD_s,
                    prvyr_pipe_amt_qtr_s,
                    prvyr_pipe_amt_yr_s ,
                    prvyr_open_amt_wk_s ,
                    prvyr_open_amt_PRD_s,
                    prvyr_open_amt_qtr_s,
                    prvyr_open_amt_yr_s
                      )

                            SELECT /*+ parallel(fc) */ sales_group_id,
			        salesrep_id,
		            g_user_id created_by,
			        SYSDATE creation_date,
			        g_user_id last_updated_by,
			        SYSDATE last_update_date,
			        G_Login_Id last_update_login,
        			G_request_id request_id,
        			G_appl_id program_application_id,
        			G_program_id program_id,
			        SYSDATE program_update_date,	        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    SUM(pipeline_amt_day) pipeline_amt_day,
                    SUM(pipeline_amt_week) pipeline_amt_week,
                    SUM(pipeline_amt_period) pipeline_amt_period,
                    SUM(pipeline_amt_quarter) pipeline_amt_quarter,
                    SUM(pipeline_amt_year) pipeline_amt_year,
                    SUM(open_amt_day)  open_amt_day   ,
                    SUM(open_amt_week)  open_amt_week  ,
                    SUM(open_amt_period) open_amt_period ,
                    SUM(open_amt_quarter) open_amt_quarter,
                    SUM(open_amt_year) open_amt_year   ,
                    SUM(pipeline_amt_day_s) pipeline_amt_day_s,
                    SUM(pipeline_amt_week_s) pipeline_amt_week_s,
                    SUM(pipeline_amt_period_s) pipeline_amt_period_s,
                    SUM(pipeline_amt_quarter_s) pipeline_amt_quarter_s,
                    SUM(pipeline_amt_year_s) pipeline_amt_year_s,
                    SUM(open_amt_day_s) open_amt_day_s  ,
                    SUM(open_amt_week_s) open_amt_week_s ,
                    SUM(open_amt_period_s) open_amt_period_s,
                    SUM(open_amt_quarter_s) open_amt_quarter_s,
                    SUM(open_amt_year_s) open_amt_year_s ,
                                SUM(prvprd_pipe_amt_wk)  prvprd_pipe_amt_wk,
                SUM(prvprd_pipe_amt_PRD) prvprd_pipe_amt_PRD,
                SUM(prvprd_pipe_amt_qtr) prvprd_pipe_amt_qtr,
                SUM(prvprd_pipe_amt_yr) prvprd_pipe_amt_yr ,
                SUM(prvprd_open_amt_wk) prvprd_open_amt_wk ,
                SUM(prvprd_open_amt_PRD) prvprd_open_amt_PRD,
                SUM(prvprd_open_amt_qtr) prvprd_open_amt_qtr,
                SUM(prvprd_open_amt_yr)  prvprd_open_amt_yr,
                SUM(prvprd_pipe_amt_wk_s)  prvprd_pipe_amt_wk_s,
                SUM(prvprd_pipe_amt_PRD_s) prvprd_pipe_amt_PRD_s,
                SUM(prvprd_pipe_amt_qtr_s) prvprd_pipe_amt_qtr_s,
                SUM(prvprd_pipe_amt_yr_s) prvprd_pipe_amt_yr_s ,
                SUM(prvprd_open_amt_wk_s) prvprd_open_amt_wk_s ,
                SUM(prvprd_open_amt_PRD_s) prvprd_open_amt_PRD_s,
                SUM(prvprd_open_amt_qtr_s) prvprd_open_amt_qtr_s,
                SUM(prvprd_open_amt_yr_s) prvprd_open_amt_yr_s,
                SUM(prvyr_pipe_amt_wk)  prvyr_pipe_amt_wk ,
                SUM(prvyr_pipe_amt_PRD)  prvyr_pipe_amt_PRD,
                SUM(prvyr_pipe_amt_qtr)  prvyr_pipe_amt_qtr,
                SUM(prvyr_pipe_amt_yr) prvyr_pipe_amt_yr  ,
                SUM(prvyr_open_amt_wk) prvyr_open_amt_wk   ,
                SUM(prvyr_open_amt_PRD) prvyr_open_amt_PRD ,
                SUM(prvyr_open_amt_qtr) prvyr_open_amt_qtr ,
                SUM(prvyr_open_amt_yr) prvyr_open_amt_yr  ,
                SUM(prvyr_pipe_amt_wk_s)  prvyr_pipe_amt_wk_s ,
                SUM(prvyr_pipe_amt_PRD_s) prvyr_pipe_amt_PRD_s ,
                SUM(prvyr_pipe_amt_qtr_s) prvyr_pipe_amt_qtr_s ,
                SUM(prvyr_pipe_amt_yr_s)   prvyr_pipe_amt_yr_s,
                SUM(prvyr_open_amt_wk_s) prvyr_open_amt_wk_s  ,
                SUM(prvyr_open_amt_PRD_s) prvyr_open_amt_PRD_s ,
                SUM(prvyr_open_amt_qtr_s) prvyr_open_amt_qtr_s ,
                SUM(prvyr_open_amt_yr_s) prvyr_open_amt_yr_s
                  FROM (
			      SELECT /*+ parallel(stg) USE_MERGE(time) */
			        SALES_GROUP_ID,
			        SALESREP_ID,
			        p_date snap_date,
			        ITEM_ID,
			        ITEM_ORGANIZATION_ID,
			        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY) win_probability,
			        PRODUCT_CATEGORY_ID,
			        SUM(CASE
			            WHEN TIME.report_date = p_date
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        ) pipeline_amt_day,
			        SUM(CASE
			            WHEN TIME.week_id = p_week
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        ) pipeline_amt_week,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )pipeline_amt_period,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) pipeline_amt_quarter,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) pipeline_amt_year,
			         SUM( CASE
			            WHEN TIME.report_date = p_date  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END) open_amt_day,
			        SUM( CASE
			            WHEN TIME.week_id = p_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END) open_amt_week,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) open_amt_period,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) open_amt_quarter,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) open_amt_year,
			        SUM(CASE
			            WHEN TIME.report_date = p_date
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        ) pipeline_amt_day_s,
			        SUM(CASE
			            WHEN TIME.week_id = p_week
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END
			        ) pipeline_amt_week_s,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) pipeline_amt_period_s,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) pipeline_amt_quarter_s,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) pipeline_amt_year_s,
			         SUM( CASE
			            WHEN TIME.report_date = p_date  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) open_amt_day_s,
			        SUM( CASE
			            WHEN TIME.week_id = p_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) open_amt_week_s,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) open_amt_period_s,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) open_amt_quarter_s,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) open_amt_year_s,
                null prvprd_pipe_amt_wk  ,
                null prvprd_pipe_amt_PRD ,
                null prvprd_pipe_amt_qtr ,
                null prvprd_pipe_amt_yr  ,
                null prvprd_open_amt_wk  ,
                null prvprd_open_amt_PRD ,
                null prvprd_open_amt_qtr ,
                null prvprd_open_amt_yr  ,
                null prvprd_pipe_amt_wk_s,
                null prvprd_pipe_amt_PRD_s,
                null prvprd_pipe_amt_qtr_s,
                null prvprd_pipe_amt_yr_s,
                null prvprd_open_amt_wk_s,
                null prvprd_open_amt_PRD_s,
                null prvprd_open_amt_qtr_s,
                null prvprd_open_amt_yr_s,
                null prvyr_pipe_amt_wk   ,
                null prvyr_pipe_amt_PRD  ,
                null prvyr_pipe_amt_qtr  ,
                null prvyr_pipe_amt_yr   ,
                null prvyr_open_amt_wk   ,
                null prvyr_open_amt_PRD  ,
                null prvyr_open_amt_qtr  ,
                null prvyr_open_amt_yr   ,
                null prvyr_pipe_amt_wk_s ,
                null prvyr_pipe_amt_PRD_s,
                null prvyr_pipe_amt_qtr_s,
                null prvyr_pipe_amt_yr_s ,
                null prvyr_open_amt_wk_s ,
                null prvyr_open_amt_PRD_s,
                null prvyr_open_amt_qtr_s,
                null prvyr_open_amt_yr_s

                  FROM
			        bil_bi_pipeline_stg stg,
			        fii_time_day time
			      WHERE stg.effective_date =  TIME.report_date
			        AND forecast_rollup_flag = 'Y'
			        AND TIME.report_date_julian >= p_min_date_id AND TIME.report_date_julian+0 <= p_max_date_id
			      GROUP BY
			        sales_group_id,
			        salesrep_id,
			        item_id,
			        item_organization_id,
			        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY),
			        product_category_id
			      HAVING
			        SUM(CASE
			            WHEN TIME.week_id = p_week
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        )IS NOT NULL OR
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )
			         IS NOT NULL
     UNION ALL
                      SELECT /*+ parallel(f) */ sales_group_id,
			        salesrep_id,
			        p_date snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    null pipeline_amt_day ,
                    null pipeline_amt_week,
                    null pipeline_amt_period,
                    null pipeline_amt_quarter,
                    null pipeline_amt_year,
                    null open_amt_day     ,
                    null open_amt_week    ,
                    null open_amt_period  ,
                    null open_amt_quarter ,
                    null open_amt_year    ,
                    null pipeline_amt_day_s ,
                    null pipeline_amt_week_s,
                    null pipeline_amt_period_s ,
                    null pipeline_amt_quarter_s,
                    null pipeline_amt_year_s,
                    null open_amt_day_s   ,
                    null open_amt_week_s  ,
                    null open_amt_period_s,
                    null open_amt_quarter_s,
                    null open_amt_year_s,
				decode(f.snap_date, l_sd_lwk_end, pipeline_amt_week, null) prvprd_pipe_amt_wk  ,
                decode(f.snap_date, l_sd_lper_end, pipeline_amt_period, null) prvprd_pipe_amt_PRD ,
                decode(f.snap_date, l_sd_lqtr_end, pipeline_amt_quarter, null) prvprd_pipe_amt_qtr ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year, null) prvprd_pipe_amt_yr  ,
                decode(f.snap_date, l_sd_lwk_end, open_amt_week, null) prvprd_open_amt_wk  ,
                decode(f.snap_date, l_sd_lper_end, open_amt_period, null) prvprd_open_amt_PRD ,
                decode(f.snap_date, l_sd_lqtr_end, open_amt_quarter, null) prvprd_open_amt_qtr ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvprd_open_amt_yr  ,
                decode(f.snap_date, l_sd_lwk_end, pipeline_amt_week_s, null) prvprd_pipe_amt_wk_s  ,
                decode(f.snap_date, l_sd_lper_end, pipeline_amt_period_s, null) prvprd_pipe_amt_PRD_s ,
                decode(f.snap_date, l_sd_lqtr_end, pipeline_amt_quarter_s, null) prvprd_pipe_amt_qtr_s ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year_s, null) prvprd_pipe_amt_yr_s  ,
                decode(f.snap_date, l_sd_lwk_end, open_amt_week_s, null) prvprd_open_amt_wk_s  ,
                decode(f.snap_date, l_sd_lper_end, open_amt_period_s, null) prvprd_open_amt_PRD_s ,
                decode(f.snap_date, l_sd_lqtr_end, open_amt_quarter_s, null) prvprd_open_amt_qtr_s ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year_s, null) prvprd_open_amt_yr_s,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_week, null) prvyr_pipe_amt_wk   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_period, null) prvyr_pipe_amt_PRD  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_quarter, null) prvyr_pipe_amt_qtr  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year, null) prvyr_pipe_amt_yr   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_week, null) prvyr_open_amt_wk   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_period, null) prvyr_open_amt_PRD  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_quarter, null) prvyr_open_amt_qtr  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvyr_open_amt_yr   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_week_s, null) prvyr_pipe_amt_wk_s   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_period_s, null) prvyr_pipe_amt_PRD_s  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_quarter_s, null) prvyr_pipe_amt_qtr_s  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year_s, null) prvyr_pipe_amt_yr_s   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_week_s, null) prvyr_open_amt_wk_s   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_period, null) prvyr_open_amt_PRD_s  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_quarter, null) prvyr_open_amt_qtr_s  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvyr_open_amt_yr_s
                    FROM BIL_BI_PIPELINE_F f
                    where snap_date in (l_sd_lwk_end, l_sd_lper_end
                    ,l_sd_lqtr_end, l_sd_lyr_end)
					UNION ALL
                      SELECT  sales_group_id,
			        salesrep_id,
			        p_date snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    null pipeline_amt_day ,
                    null pipeline_amt_week,
                    null pipeline_amt_period,
                    null pipeline_amt_quarter,
                    null pipeline_amt_year,
                    null open_amt_day     ,
                    null open_amt_week    ,
                    null open_amt_period  ,
                    null open_amt_quarter ,
                    null open_amt_year    ,
                    null pipeline_amt_day_s ,
                    null pipeline_amt_week_s,
                    null pipeline_amt_period_s ,
                    null pipeline_amt_quarter_s,
                    null pipeline_amt_year_s,
                    null open_amt_day_s   ,
                    null open_amt_week_s  ,
                    null open_amt_period_s,
                    null open_amt_quarter_s,
                    null open_amt_year_s  ,
                pipeline_amt_week prvprd_pipe_amt_wk  ,
                null prvprd_pipe_amt_PRD ,
                null prvprd_pipe_amt_qtr ,
                null prvprd_pipe_amt_yr  ,
                open_amt_week prvprd_open_amt_wk  ,
                null prvprd_open_amt_PRD ,
                null prvprd_open_amt_qtr ,
                null prvprd_open_amt_yr  ,
                pipeline_amt_week_s prvprd_pipe_amt_wk_s  ,
                null prvprd_pipe_amt_PRD_s ,
                null prvprd_pipe_amt_qtr_s ,
                null prvprd_pipe_amt_yr_s  ,
                open_amt_week_s prvprd_open_amt_wk_s  ,
                null prvprd_open_amt_PRD_s ,
                null prvprd_open_amt_qtr_s ,
                null prvprd_open_amt_yr_s,
                null prvyr_pipe_amt_wk   ,
                null prvyr_pipe_amt_PRD  ,
                null prvyr_pipe_amt_qtr  ,
                null prvyr_pipe_amt_yr   ,
                null prvyr_open_amt_wk   ,
                null prvyr_open_amt_PRD  ,
                null prvyr_open_amt_qtr  ,
                null prvyr_open_amt_yr   ,
                null prvyr_pipe_amt_wk_s   ,
                null prvyr_pipe_amt_PRD_s  ,
                null prvyr_pipe_amt_qtr_s  ,
                null prvyr_pipe_amt_yr_s   ,
                null prvyr_open_amt_wk_s   ,
                null prvyr_open_amt_PRD_s  ,
                null prvyr_open_amt_qtr_s  ,
                null prvyr_open_amt_yr_s
                    FROM BIL_BI_PIPEC_F f
                    where snap_date = l_sd_lwk
                     )
                    GROUP BY
                       sales_group_id,
			        salesrep_id,
			        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id
                    ;
               commit;

	  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

 EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;


END Insert_Into_curr_sumry;


PROCEDURE Insert_Into_Summary (p_mode IN varchar2) IS
 l_proc VARCHAR2(100);
BEGIN

 l_proc:= 'Insert_Into_Summary';


IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;



IF(p_mode = 'INIT') THEN
 INSERT /*+ append parallel(f) */ into bil_bi_pipeline_f f(
   SALES_GROUP_ID,
   SALESREP_ID,
   CREATED_BY ,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   REQUEST_ID,
   PROGRAM_APPLICATION_ID,
   PROGRAM_ID,
   PROGRAM_UPDATE_DATE,
   SNAP_DATE,
   ITEM_ID,
   ITEM_ORGANIZATION_ID,
   WIN_PROBABILITY,
   PRODUCT_CATEGORY_ID,
   PIPELINE_AMT_DAY,
   PIPELINE_AMT_WEEK,
   PIPELINE_AMT_PERIOD,
   PIPELINE_AMT_Quarter,
   PIPELINE_AMT_YEAR,
   OPEN_AMT_DAY,
   OPEN_AMT_WEEK,
   OPEN_AMT_PERIOD,
   OPEN_AMT_Quarter,
   OPEN_AMT_YEAR,
   PIPELINE_AMT_DAY_S,
   PIPELINE_AMT_WEEK_S,
   PIPELINE_AMT_PERIOD_S,
   PIPELINE_AMT_Quarter_S,
   PIPELINE_AMT_YEAR_S,
   OPEN_AMT_DAY_S,
   OPEN_AMT_WEEK_S,
   OPEN_AMT_PERIOD_S,
   OPEN_AMT_Quarter_S,
   OPEN_AMT_YEAR_S
 )
 SELECT /*+ parallel(stg) use_merge(time1) */
   SALES_GROUP_ID,
   SALESREP_ID,
   g_user_id,
   sysdate,
   g_user_id,
   sysdate,
   G_Login_Id,
   G_request_id,
   G_appl_id,
   G_program_id,
   sysdate,
   stg.snap_date,
   ITEM_ID,
   ITEM_ORGANIZATION_ID,
   WIN_PROBABILITY,
   PRODUCT_CATEGORY_ID,
   SUM(CASE
       WHEN time.report_date = time1.report_date
       THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.week_id = time1.week_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_year_id =time1.ent_year_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
   SUM( CASE
        WHEN time.report_date =time1.report_date  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM( CASE
        WHEN time.week_id =  time1.week_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id   and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_year_id = time1.ent_year_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
       WHEN time.report_date = time1.report_date
       THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
         stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.week_id = time1.week_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_year_id =time1.ent_year_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
   SUM( CASE
        WHEN time.report_date =time1.report_date  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM( CASE
        WHEN time.week_id =  time1.week_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id   and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_year_id = time1.ent_year_id and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END)
 FROM
   bil_bi_pipeline_stg stg,
   fii_time_day time,
   fii_time_day time1
 WHERE
   stg.snap_date = time1.report_date
   and stg.PRIM_CONVERSION_RATE > 0
   and stg.conversion_rate_s>0
   and stg.product_category_id is not null
   and stg.effective_date =  time.report_date
   and stg.effective_date <= GREATEST(time.ent_year_end_date,time.week_end_date)
 GROUP BY
   SALES_GROUP_ID,
   SALESREP_ID,
   ITEM_ID,
   ITEM_ORGANIZATION_ID,
   WIN_PROBABILITY,
   PRODUCT_CATEGORY_ID,
   stg.snap_date
 HAVING
  SUM(CASE
      WHEN time.week_id = time1.week_id
      THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL, stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
  ) is not null or
  SUM(CASE
      WHEN time.ent_year_id =time1.ent_year_id
      THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL, stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )
      is not null ;

  ELSE
  INSERT into bil_bi_pipeline_f f(
   SALES_GROUP_ID,
   SALESREP_ID,
   CREATED_BY ,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   REQUEST_ID,
   PROGRAM_APPLICATION_ID,
   PROGRAM_ID,
   PROGRAM_UPDATE_DATE,
   SNAP_DATE,
   ITEM_ID,
   ITEM_ORGANIZATION_ID,
   WIN_PROBABILITY,
   PRODUCT_CATEGORY_ID,
   PIPELINE_AMT_DAY,
   PIPELINE_AMT_WEEK,
   PIPELINE_AMT_PERIOD,
   PIPELINE_AMT_Quarter,
   PIPELINE_AMT_YEAR,
   OPEN_AMT_DAY,
   OPEN_AMT_WEEK,
   OPEN_AMT_PERIOD,
   OPEN_AMT_Quarter,
   OPEN_AMT_YEAR,
   PIPELINE_AMT_DAY_S,
   PIPELINE_AMT_WEEK_S,
   PIPELINE_AMT_PERIOD_S,
   PIPELINE_AMT_Quarter_S,
   PIPELINE_AMT_YEAR_S,
   OPEN_AMT_DAY_S,
   OPEN_AMT_WEEK_S,
   OPEN_AMT_PERIOD_S,
   OPEN_AMT_Quarter_S,
   OPEN_AMT_YEAR_S
 )
 SELECT
   SALES_GROUP_ID,
   SALESREP_ID,
   g_user_id,
   sysdate,
   g_user_id,
   sysdate,
   G_Login_Id,
   G_request_id,
   G_appl_id,
   G_program_id,
   sysdate,
   stg.snap_date,
   ITEM_ID,
   ITEM_ORGANIZATION_ID,
   WIN_PROBABILITY,
   PRODUCT_CATEGORY_ID,
   SUM(CASE
       WHEN time.report_date = time1.report_date
       THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.week_id = time1.week_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_year_id =time1.ent_year_id
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
   SUM( CASE
        WHEN time.report_date =time1.report_date  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM( CASE
        WHEN time.week_id =  time1.week_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id   and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_year_id = time1.ent_year_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
          stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
   SUM(CASE
       WHEN time.report_date = time1.report_date
       THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
         stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.week_id = time1.week_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_year_id =time1.ent_year_id
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
   SUM( CASE
        WHEN time.report_date =time1.report_date  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM( CASE
        WHEN time.week_id =  time1.week_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_period_id = time1.ent_period_id   and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
   SUM(CASE
        WHEN time.ent_qtr_id = time1.ent_qtr_id  and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
   SUM(CASE
        WHEN time.ent_year_id = time1.ent_year_id and opp_open_status_flag = 'Y'
        THEN decode(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END)
 FROM
   bil_bi_pipeline_stg stg,
   fii_time_day time,
   fii_time_day time1
 WHERE
   stg.snap_date = time1.report_date
   and stg.PRIM_CONVERSION_RATE > 0
   and stg.conversion_rate_s>0
   and stg.product_category_id is not null
   and stg.effective_date =  time.report_date
 GROUP BY
   SALES_GROUP_ID,
   SALESREP_ID,
   ITEM_ID,
   ITEM_ORGANIZATION_ID,
   WIN_PROBABILITY,
   PRODUCT_CATEGORY_ID,
   stg.snap_date
 HAVING
  SUM(CASE
      WHEN time.week_id = time1.week_id
      THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL, stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
  ) is not null or
  SUM(CASE
      WHEN time.ent_year_id =time1.ent_year_id
      THEN decode(stg.sales_credit_amount*prim_conversion_rate, 0, NULL, stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )
      is not null ;

  END IF;


    g_row_num:= sql%rowcount;
    commit;

   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
        bil_bi_util_collection_pkg.writeLog(
                p_log_level => fnd_log.LEVEL_EVENT,
    p_module => g_pkg || l_proc ,
    p_msg => 'Inserted  '|| g_row_num||' into BIL_BI_PIPELINE_F table from BIL_BI_PIPELINE_STG ');
   END IF;



IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;


END Insert_Into_Summary;



PROCEDURE Build_BaseLine(p_start_date IN DATE) IS
l_proc VARCHAR2(100);
l_max_decision_end DATE;
l_report_date DATE;
l_report_start DATE;
l_report_end DATE;
l_limit_date DATE; --added by annsrini --fix for bug 5953589


BEGIN

l_proc := 'Build_BaseLine';
l_limit_date := add_months(trunc(g_program_start),24); --added by annsrini --fix for bug 5953589


IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;



   IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_STATEMENT) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_STATEMENT,
             p_module => g_pkg || l_proc ,
             p_msg => 'p_start_date is '|| p_start_date);

	 END IF;


select greatest(week_end_date, ent_year_end_date)
into l_max_decision_end
from fii_time_day
where end_date = p_start_date;
   --- base line query , note  can't just produce baseline for x and x year, but for x on forward

SELECT report_date,
LEAST(ent_year_start_date, week_start_date) start_date,
GREATEST(ent_year_end_date,week_end_date) end_date
into l_report_date, l_report_start, l_report_end
FROM
fii_time_day
WHERE report_date = trunc(p_start_date);



    INSERT /*+ APPEND PARALLEL(stg) */  INTO bil_bi_pipeline_stg stg(
	line_id,
	credit_id,
	SALES_GROUP_ID,
   	SALESREP_ID,
	LEAD_ID,
	WIN_PROBABILITY,
	TXN_CURRENCY,
	WIN_LOSS_INDICATOR,
	FORECAST_ROLLUP_FLAG,
	ITEM_ID,
	ITEM_ORGANIZATION_ID,
	LEAD_NUMBER,
	PRODUCT_CATEGORY_ID,
	OPP_OPEN_STATUS_FLAG,
	SALES_CREDIT_AMOUNT,
	SNAP_DATE,
	EFFECTIVE_DATE
   )
   SELECT  /*+ parallel(linelog) parallel(creditlog) parallel(leads)
           pq_distribute(leads,hash,hash) pq_distribute(linelog,hash,hash) pq_distribute(creditlog,hash,hash)
           full(linelog) full(creditlog) full(leads) */
  linelog.lead_line_id,
  creditlog.sales_credit_id,
 creditlog.salesgroup_id
 ,creditlog.salesforce_id
 ,maxlog.lead_id
 ,decode(maxlog.win_loss_indicator,'W', 100,  maxlog.WIN_PROBABILITY)
 ,maxlog.currency_code
 ,maxlog.win_loss_indicator  win_loss_indicator
 ,maxlog.FORECAST_ROLLUP_FLAG forecast_rollup_flag
        ,nvl(linelog.inventory_item_id, -1)
        , decode(linelog.Inventory_item_id, null, -99,
nvl(linelog.organization_id, -99))
        ,leads.lead_number
        , linelog.product_category_id
        , maxlog.opp_open_status_flag open_status_flag
        , sum(creditlog.credit_amount)
        , maxlog.report_date
        , nvl(linelog.forecast_date, maxlog.decision_date)
   FROM  as_leads_all leads
       , as_lead_lines_log linelog
       , as_sales_credits_log creditlog
       , (-- alias maxlog
 SELECT  /*+ parallel(linelog1) parallel(creditlog1) full(linelog1) full(creditlog1)
               pq_distribute(creditlog1,hash,hash) pq_distribute(linelog1,hash,hash) no_merge */
             leadlog2.lead_id     lead_id
           , MAX(leadlog2.max_id)      lead_log_id
           , linelog1.lead_line_id    lead_line_id
           , MAX(linelog1.log_id) lead_line_log_id
           , creditlog1.sales_credit_id sales_credit_id
           , MAX(creditlog1.log_id) sales_credit_log_id
           , leadlog2.report_date report_date
           , leadlog2.currency_code
           , leadlog2.FORECAST_ROLLUP_FLAG
           , leadlog2.win_loss_indicator
           , leadlog2.opp_open_status_flag
           , leadlog2.win_probability
           , leadlog2.decision_date
          FROM
             as_sales_credits_log creditlog1,
             as_lead_lines_log linelog1,
            ( -- alias leadlog2
             SELECT /*+ full(llog) parallel(llog) pq_distribute(STATUS1,none,broadcast) swap_join_inputs(STATUS1) no_merge */
			  maxlead.report_date, maxlead.start_date,maxlead.lead_id, maxlead.max_id,
              llog.decision_date, llog.win_probability, status1.FORECAST_ROLLUP_FLAG,
              status1.win_loss_indicator, status1.opp_open_status_flag,
              llog.currency_code
              FROM
              ( -- alias maxlead
                SELECT /*+ parallel(leadlog1) full(leadlog1) NO_MERGE */
				--gapdays.report_date,
				--gapdays.start_date,
				--gapdays.end_date
				l_report_date report_date,
				l_report_start start_date,
				l_report_end end_date
				,leadlog1.lead_id, max(leadlog1.log_id) max_id
                 FROM as_leads_log leadlog1
                    -- ( -- alias gapdays
                    --  SELECT report_date,
                     --        LEAST(ent_year_start_date, week_start_date) start_date,
                      --       GREATEST(ent_year_end_date,week_end_date) end_date
                      --   FROM
                      --        fii_time_day
                      --   WHERE report_date = trunc(p_start_date)
                     --) gapdays
                WHERE leadlog1.last_update_date < l_report_date+1
		    GROUP BY lead_id, --gapdays.report_date, gapdays.start_date, gapdays.end_date
				l_report_date, l_report_start, l_report_end
              ) maxlead,
              as_leads_log llog,
              as_statuses_b status1
              WHERE maxlead.max_id = llog.log_id
                and status1.status_Code = llog.status_Code
                and llog.decision_date >= g_global_start_date
                AND llog.decision_date >= maxlead.start_date
		    AND llog.decision_date <= l_limit_date --added by annsrini --fix for bug 5953589
                AND status1.FORECAST_ROLLUP_FLAG = 'Y'
            ) leadlog2
        WHERE linelog1.lead_id=leadlog2.lead_id
          AND creditlog1.lead_line_id=linelog1.lead_line_id
          AND creditlog1.lead_id = leadlog2.lead_id
          AND linelog1.lead_id = creditlog1.lead_id
          AND linelog1.last_update_date < leadlog2.report_date+1
          AND creditlog1.last_update_date < leadlog2.report_date+1
          AND nvl(linelog1.forecast_date,leadlog2.decision_date) >= G_Global_Start_Date  --addedby annsrini --fix for bug 5953589
          AND nvl(linelog1.forecast_date,leadlog2.decision_date) >= leadlog2.start_date
	    AND nvl(linelog1.forecast_date,leadlog2.decision_date) <= l_limit_date
          AND ((creditlog1.log_mode in ('U', 'I')
               AND creditlog1.salesgroup_id IS NOT NULL
               AND creditlog1.CREDIT_TYPE_ID = g_credit_type_id)
               OR
               (creditlog1.log_mode='D'))
         GROUP BY
           creditlog1.sales_credit_id
         , leadlog2.lead_id
         , linelog1.lead_line_id
         , leadlog2.report_date
         , leadlog2.currency_code
           , leadlog2.FORECAST_ROLLUP_FLAG
           , leadlog2.win_loss_indicator
           , leadlog2.opp_open_status_flag
           , leadlog2.win_probability
           , leadlog2.decision_date
          ) maxlog
   WHERE maxlog.lead_line_log_id = linelog.log_id
     AND maxlog.sales_credit_log_id = creditlog.log_id
     AND creditlog.salesgroup_id is not null
     AND leads.lead_id = maxlog.lead_id
	 AND NVL(linelog.forecast_date, maxlog.decision_date) <= l_max_decision_end
   GROUP BY linelog.lead_line_id
           ,creditlog.sales_credit_id
	   ,creditlog.salesgroup_id
           ,creditlog.salesforce_id
           ,maxlog.lead_id
           ,maxlog.WIN_PROBABILITY
           ,maxlog.currency_code
           ,maxlog.win_loss_indicator
           ,maxlog.FORECAST_ROLLUP_FLAG
           ,nvl(linelog.inventory_item_id, -1)
           ,decode(linelog.Inventory_item_id, null, -99, nvl(linelog.organization_id, -99))
           ,leads.lead_number
           ,linelog.product_category_id
           ,maxlog.opp_open_status_flag
           ,maxlog.report_date
           ,NVL(linelog.forecast_date, maxlog.decision_date);

commit;




IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;


EXCEPTION

WHEN NO_DATA_FOUND THEN
NULL;

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;

END Build_BaseLine;

PROCEDURE Build_Denlog(p_start_date IN DATE, p_end_Date IN DATE, p_coll_start IN DATE, p_mode IN varchar2) IS
l_proc VARCHAR2(100);
l_min_decision_start DATE;
l_max_decision_end DATE;
l_rank NUMBER;
l_limit_date  DATE ; --added by annsrini --fix for bug 5953589

BEGIN

l_proc := 'Build_Denlog';
l_rank := 1;
l_limit_date := add_months(trunc(g_program_start),24); --added by annsrini --fix for bug 5953589


IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
 END IF;

BEGIN
select least(week_start_date, ent_year_start_date)
into l_min_decision_start
from fii_time_day
where start_date = p_start_date;

select greatest(week_end_date, ent_year_end_date)
into l_max_decision_end
from fii_time_day
where end_date = p_end_date;

EXCEPTION
WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' ERROR while getting the dates',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;
END;

IF (p_mode = 'INIT') THEN


BEGIN

INSERT /*+ append parallel(tmp) */ INTO bil_bi_opdtl_denlog_tmp tmp
(lead_id,
lead_log_id,
lead_line_id,
lead_line_log_id,
sales_credit_id,
sales_credit_log_id,
last_update_date,
rev_flag)
SELECT lead_id,
					 lead_log_id,
					 lead_line_id,
					 lead_line_log_id,
					 sales_credit_id,
					 sales_credit_log_id,
					 last_update_date,
					 rev_flag FROM
(

SELECT   /*+  leading(linelog) use_hash(creditlog leadlog) parallel(creditlog) parallel(linelog) */
  leadlog.lead_id     lead_id
, leadlog.log_id      lead_log_id
, linelog.lead_line_id    lead_line_id
, MAX(linelog.log_id) lead_line_log_id
, creditlog.sales_credit_id sales_credit_id
, MAX(creditlog.log_id) sales_credit_log_id
, TRUNC(leadlog.last_update_date)  last_update_date
, DECODE(creditlog.log_mode,'D','D','N') rev_flag
FROM as_sales_credits_log creditlog
, as_lead_lines_log linelog
, (SELECT
log_mode,
last_update_date,
decision_date,
log_id,
lead_id
FROM
(
SELECT  /*+ parallel(LLOG) use_hash(LLOG)*/
log_mode,
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date) last_update_date,
decision_date,
llog.log_id,
lead_id,
RANK() OVER(PARTITION BY
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date)
,llog.lead_id ORDER BY llog.log_id desc) log_id_rank
FROM
as_leads_log llog,
bil_bi_time time
WHERE
llog.last_update_date >= p_start_date AND llog.last_update_date+0 < p_end_date
AND(llog.last_update_date >= time.start_date and llog.last_update_date  < time.end_date+1)
AND llog.endday_log_flag = 'Y'
) maxlog
WHERE
log_id_rank = 1)
leadlog
WHERE  linelog.lead_id=leadlog.lead_id

AND (
(creditlog.log_mode IN ('U', 'I')
AND creditlog.salesgroup_id IS NOT NULL
AND creditlog.CREDIT_TYPE_ID = g_credit_type_id)
OR
(creditlog.log_mode='D'))
AND creditlog.lead_line_id=linelog.lead_line_id
AND linelog.lead_id = creditlog.lead_id
AND TRUNC(linelog.last_update_date) <= TRUNC(leadlog.last_update_date)
AND TRUNC(creditlog.last_update_date) <= TRUNC(leadlog.last_update_date)
AND linelog.endday_log_flag = 'Y'
AND creditlog.endday_log_flag = 'Y'
GROUP BY
leadlog.log_id
, leadlog.lead_id
, linelog.lead_line_id
, creditlog.sales_credit_id
, TRUNC(leadlog.last_update_date)
,  DECODE(creditlog.log_mode,'D','D','N')
UNION
SELECT /*+  leading(leadlog) use_hash(creditlog,linelog) parallel(leadlog) parallel(creditlog) */
 leadlog.lead_id      lead_id
, MAX(leadlog.log_id)  lead_log_id
, linelog.lead_line_id lead_line_id
, linelog.log_id		  lead_line_log_id
, creditlog.sales_credit_id sales_credit_id
, MAX(creditlog.log_id) sales_credit_log_id
, TRUNC(linelog.last_update_date)  last_update_date
, DECODE(creditlog.log_mode, 'D','D', 'N') rev_flag
FROM as_sales_credits_log creditlog
, (
select log_mode, last_update_date, forecast_date,
log_id, lead_Line_id, lead_id from
( SELECT /*+ parallel(LLOG) use_hash(LLOG) */
log_mode,
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date) last_update_date,
forecast_date,
llog.log_id,
lead_id,
lead_line_id,
RANK() OVER(PARTITION BY
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date)
,llog.lead_line_id ORDER BY llog.log_id desc) log_id_rank
FROM as_lead_lines_log llog, bil_bi_time time
WHERE
(llog.last_update_date >= p_start_date AND llog.last_update_date+0 < p_end_date)
AND(llog.last_update_date >= time.start_date and llog.last_update_date  < time.end_date+1)
AND llog.endday_log_flag = 'Y'
) maxlog
where log_id_rank = 1

) linelog
, as_leads_log leadlog
WHERE  linelog.lead_id=leadlog.lead_id
AND creditlog.lead_line_id=linelog.lead_line_id
AND linelog.lead_id = creditlog.lead_id

AND (
(creditlog.log_mode IN ('U', 'I')
AND creditlog.salesgroup_id IS NOT NULL
AND creditlog.CREDIT_TYPE_ID = g_credit_type_id)
OR
(creditlog.log_mode='D'))
AND TRUNC(leadlog.last_update_date) <= TRUNC(linelog.last_update_date)
AND TRUNC(creditlog.last_update_date) <= TRUNC(linelog.last_update_date)
AND leadlog.endday_log_flag = 'Y'
AND creditlog.endday_log_flag = 'Y'
GROUP BY
leadlog.lead_id
, linelog.lead_line_id
, linelog.log_id
, creditlog.sales_credit_id
, TRUNC(linelog.last_update_date)
,DECODE(creditlog.log_mode, 'D','D','N')
UNION
SELECT /*+ leading(leadlog) use_hash(linelog,creditlog) parallel(linelog) parallel(leadlog) */
  leadlog.lead_id      lead_id
, MAX(leadlog.log_id)  lead_log_id
, linelog.lead_line_id lead_line_id
, MAX(linelog.log_id)  lead_line_log_id
, creditlog.sales_credit_id sales_credit_id
, creditlog.log_id sales_credit_log_id
, TRUNC(creditlog.last_update_date) last_update_date
,DECODE(creditlog.log_mode,'D','D','N')
FROM (
select log_mode, salesgroup_id, last_update_date, credit_type_id,
log_id, sales_credit_id, lead_Line_id, lead_id
from (
select  /*+  parallel(CLOG) use_hash(CLOG)*/
log_mode, salesgroup_id, DECODE(GREATEST(TRUNC(clog.last_update_date), p_coll_start),TRUNC(clog.last_update_date),
TRUNC(clog.last_update_date),time.end_date) last_update_date, credit_type_id,
clog.log_id, sales_credit_id, lead_Line_id, lead_id,
RANK() OVER(PARTITION BY
DECODE(GREATEST(TRUNC(clog.last_update_date), p_coll_start),TRUNC(clog.last_update_date),
TRUNC(clog.last_update_date),time.end_date)
,clog.sales_credit_id ORDER BY clog.log_id desc) log_id_rank
 from
as_sales_credits_log clog, bil_bi_time time
WHERE (clog.last_update_date >= p_start_date AND clog.last_update_date+0 < p_end_date)
AND (clog.last_update_date >= time.start_date and
clog.last_update_date  < time.end_date+1)
AND clog.endday_log_flag = 'Y'
) maxlog
where log_id_rank = l_rank

)  creditlog
, as_lead_lines_log linelog
, as_leads_log leadlog
WHERE  linelog.lead_id=leadlog.lead_id
AND creditlog.lead_line_id=linelog.lead_line_id
AND linelog.lead_id = creditlog.lead_id

AND (
(creditlog.log_mode IN ('U', 'I')
AND creditlog.salesgroup_id IS NOT NULL
AND creditlog.CREDIT_TYPE_ID = g_credit_type_id)
OR
(creditlog.log_mode='D'))
AND TRUNC(leadlog.last_update_date) <= TRUNC(creditlog.last_update_date)
AND TRUNC(linelog.last_update_date) <= TRUNC(creditlog.last_update_date)
GROUP BY
leadlog.lead_id
, linelog.lead_line_id
, creditlog.sales_credit_id
, creditlog.log_id
, TRUNC(creditlog.last_update_date)
,DECODE(creditlog.log_mode,'D','D','N')
)
;
commit;

EXCEPTION WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' ERROR while inserting into denlog_tmp',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;

	END;

	 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
 	  bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'inserted ' || sql%rowcount || 'into denlog_tmp from leadlog');
    END IF;



                -- we don't need to delete any more since we get
                --latest update for the day with endday_log_flag
--					delete /*+ parallel(tmp1) */ from BIL_BI_OPDTL_DENLOG_TMP tmp1
	/*					where exists (select 1 from BIL_BI_OPDTL_DENLOG_TMP tmp2
						where tmp1.lead_id = tmp2.lead_id
						and tmp1.lead_line_id = tmp2.lead_line_id
						and tmp1.sales_credit_id = tmp2.sales_credit_id
						and tmp1.last_update_date = tmp2.last_update_date
						and tmp2.rev_flag = 'D')
						and rev_flag <> 'D'; */


					commit;


		--- ok to filter stuff out here since checking is using denlog_tmp table not denlog_stg
BEGIN
					INSERT /*+ append parallel(denlog_stg) */ INTO BIL_BI_DENLOG_STG  denlog_stg
					(

					LEAD_LINE_ID ,
  					SALES_CREDIT_ID       ,
  					SALESGROUP_ID         ,
 				        SALESFORCE_ID         ,
  					LEAD_ID               ,
  					WIN_PROBABILITY       ,
  					CURRENCY_CODE         ,
  					WIN_LOSS_INDICATOR    ,
  					FORECAST_ROLLUP_FLAG  ,
  					ITEM_ID               ,
  					ITEM_ORGANIZATION_ID  ,
  					LEAD_NUMBER           ,
  					PRODUCT_CATEGORY_ID   ,
  					OPEN_STATUS_FLAG      ,
  					CREDIT_AMOUNT         ,
  					LAST_UPDATE_DATE      ,
  					DECISION_DATE
					)
					SELECT /*+ parallel(tmp) parallel(creditlog) parallel(linelog) parallel(leadlog) parallel(lead) full(tmp) full(creditlog) full(linelog) full(leadlog) full(lead)*/
   					 tmp.lead_line_id
   					 ,tmp.sales_credit_id
  					 ,creditlog.salesgroup_id
 					 ,creditlog.salesforce_id
					 ,leadlog.lead_id
					 ,decode(status.win_loss_indicator,'W', 100,  leadlog.WIN_PROBABILITY)
					 ,leadlog.currency_code
					 ,status.win_loss_indicator  win_loss_indicator
					 ,status.FORECAST_ROLLUP_FLAG forecast_rollup_flag
					 ,NVL(linelog.inventory_item_id, -1) item_id
					 , DECODE(linelog.Inventory_item_id, NULL, -99,
						  NVL(linelog.organization_id, -99)) ITEM_ORGANIZATION_ID
				        ,lead.lead_number
				        , linelog.product_category_id
				        , status.opp_open_status_flag open_status_flag
				        , creditlog.credit_amount
				        , tmp.last_update_date
				        , NVL(linelog.forecast_date, leadlog.decision_date)
				     FROM BIL_BI_OPDTL_DENLOG_TMP  tmp
					   ,as_sales_credits_log creditlog
					   , as_lead_lines_log linelog
					   , as_leads_log leadlog
					   , as_statuses_b status
					  , as_leads_all lead
			             WHERE tmp.rev_flag = 'N'
					   and tmp.lead_log_id = leadlog.log_id
					   AND tmp.lead_line_log_id = linelog.log_id
					   AND tmp.sales_credit_log_id = creditlog.log_id
					   AND creditlog.salesgroup_id IS NOT NULL
					   AND lead.lead_id = tmp.lead_id
					   AND status.status_Code = leadlog.status_Code
					   AND status.FORECAST_ROLLUP_FLAG = 'Y'
					   AND NVL(linelog.forecast_date, leadlog.decision_date) >= G_Global_Start_Date
					   AND NVL(linelog.forecast_date, leadlog.decision_date) BETWEEN l_min_decision_start AND l_max_decision_end
					   AND tmp.last_update_date >= G_Global_Start_Date  --added by annsrini --fix for bug 5953589
					   AND tmp.last_update_date <= l_limit_date
					   AND NVL(linelog.forecast_date, leadlog.decision_date) <=l_limit_date
					   AND lead.decision_date >= G_Global_Start_Date
					   AND lead.decision_date <= l_limit_date;

	commit;

	EXCEPTION WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' ERROR while inserting into denlog_stg',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;

	END;
		                  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
 	  bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'inserted ' || sql%rowcount || 'into denlog_tmp_stg');
    END IF;


ELSE

INSERT  INTO bil_bi_opdtl_denlog_tmp tmp
(lead_id,
lead_log_id,
lead_line_id,
lead_line_log_id,
sales_credit_id,
sales_credit_log_id,
last_update_date,
rev_flag)
SELECT lead_id,
					 lead_log_id,
					 lead_line_id,
					 lead_line_log_id,
					 sales_credit_id,
					 sales_credit_log_id,
					 last_update_date,
					 rev_flag FROM
(

SELECT   /*+  full(linelog) full(creditlog) */
--SELECT
leadlog.lead_id     lead_id
, leadlog.log_id      lead_log_id
, linelog.lead_line_id    lead_line_id
, MAX(linelog.log_id) lead_line_log_id
, creditlog.sales_credit_id sales_credit_id
, MAX(creditlog.log_id) sales_credit_log_id
, TRUNC(leadlog.last_update_date)  last_update_date
, DECODE(creditlog.log_mode,'D','D','N') rev_flag
FROM as_sales_credits_log creditlog
, as_lead_lines_log linelog
, (SELECT
log_mode,
last_update_date,
decision_date,
log_id,
lead_id
FROM
(
SELECT
log_mode,
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date) last_update_date,
decision_date,
llog.log_id,
lead_id,
RANK() OVER(PARTITION BY
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date)
,llog.lead_id ORDER BY llog.log_id desc) log_id_rank
FROM
as_leads_log llog,
bil_bi_time time
WHERE
llog.last_update_date >= p_start_date AND llog.last_update_date < p_end_date
AND(llog.last_update_date >= time.start_date and llog.last_update_date  < time.end_date+1)
AND llog.endday_log_flag = 'Y'
) maxlog
WHERE
log_id_rank = 1)
leadlog
WHERE  linelog.lead_id=leadlog.lead_id

AND (
(creditlog.log_mode IN ('U', 'I')
AND creditlog.salesgroup_id IS NOT NULL
AND creditlog.CREDIT_TYPE_ID = g_credit_type_id)
OR
(creditlog.log_mode='D'))
AND creditlog.lead_line_id=linelog.lead_line_id
AND linelog.lead_id = creditlog.lead_id
AND TRUNC(linelog.last_update_date) <= TRUNC(leadlog.last_update_date)
AND TRUNC(creditlog.last_update_date) <= TRUNC(leadlog.last_update_date)
AND linelog.endday_log_flag = 'Y'
AND creditlog.endday_log_flag = 'Y'
GROUP BY
leadlog.log_id
, leadlog.lead_id
, linelog.lead_line_id
, creditlog.sales_credit_id
, TRUNC(leadlog.last_update_date)
,  DECODE(creditlog.log_mode,'D','D','N')
UNION
SELECT /*+  full(leadlog) full(creditlog)  */
--SELECT
leadlog.lead_id      lead_id
, MAX(leadlog.log_id)  lead_log_id
, linelog.lead_line_id lead_line_id
, linelog.log_id		  lead_line_log_id
, creditlog.sales_credit_id sales_credit_id
, MAX(creditlog.log_id) sales_credit_log_id
, TRUNC(linelog.last_update_date)  last_update_date
, DECODE(creditlog.log_mode, 'D','D', 'N') rev_flag
FROM as_sales_credits_log creditlog
, (

select log_mode, last_update_date, forecast_date,
log_id, lead_Line_id, lead_id from
( SELECT
log_mode,
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date) last_update_date,
forecast_date,
llog.log_id,
lead_id,
lead_line_id,
RANK() OVER(PARTITION BY
DECODE(GREATEST(TRUNC(llog.last_update_date), p_coll_start),TRUNC(llog.last_update_date),
TRUNC(llog.last_update_date),time.end_date)
,llog.lead_line_id ORDER BY llog.log_id desc) log_id_rank
FROM as_lead_lines_log llog, bil_bi_time time
WHERE
(llog.last_update_date >= p_start_date AND llog.last_update_date < p_end_date)
AND(llog.last_update_date >= time.start_date and llog.last_update_date  < time.end_date+1)
AND llog.endday_log_flag = 'Y'
) maxlog
where log_id_rank = 1

) linelog
, as_leads_log leadlog
WHERE  linelog.lead_id=leadlog.lead_id
AND creditlog.lead_line_id=linelog.lead_line_id
AND linelog.lead_id = creditlog.lead_id

AND (
(creditlog.log_mode IN ('U', 'I')
AND creditlog.salesgroup_id IS NOT NULL
AND creditlog.CREDIT_TYPE_ID = g_credit_type_id)
OR
(creditlog.log_mode='D'))
AND TRUNC(leadlog.last_update_date) <= TRUNC(linelog.last_update_date)
AND TRUNC(creditlog.last_update_date) <= TRUNC(linelog.last_update_date)
AND leadlog.endday_log_flag = 'Y'
AND creditlog.endday_log_flag = 'Y'
GROUP BY
leadlog.lead_id
, linelog.lead_line_id
, linelog.log_id
, creditlog.sales_credit_id
, TRUNC(linelog.last_update_date)
,DECODE(creditlog.log_mode, 'D','D','N')
UNION
SELECT /*+  full(leadlog) full(linelog) */
--SELECT
leadlog.lead_id      lead_id
, MAX(leadlog.log_id)  lead_log_id
, linelog.lead_line_id lead_line_id
, MAX(linelog.log_id)  lead_line_log_id
, creditlog.sales_credit_id sales_credit_id
, creditlog.log_id sales_credit_log_id
, TRUNC(creditlog.last_update_date) last_update_date
,DECODE(creditlog.log_mode,'D','D','N')
FROM (
select log_mode, salesgroup_id, last_update_date, credit_type_id,
log_id, sales_credit_id, lead_Line_id, lead_id
from (
select /* leading(TIME) use_merge(CLOG) parallel(TIME) parallel(CLOG) */
--SELECT
log_mode, salesgroup_id, DECODE(GREATEST(TRUNC(clog.last_update_date), p_coll_start),TRUNC(clog.last_update_date),
TRUNC(clog.last_update_date),time.end_date) last_update_date, credit_type_id,
clog.log_id, sales_credit_id, lead_Line_id, lead_id,
RANK() OVER(PARTITION BY
DECODE(GREATEST(TRUNC(clog.last_update_date), p_coll_start),TRUNC(clog.last_update_date),
TRUNC(clog.last_update_date),time.end_date)
,clog.sales_credit_id ORDER BY clog.log_id desc) log_id_rank
 from
as_sales_credits_log clog, bil_bi_time time
WHERE (clog.last_update_date >= p_start_date AND clog.last_update_date < p_end_date)
AND (clog.last_update_date >= time.start_date and
clog.last_update_date  < time.end_date+1)
AND clog.endday_log_flag = 'Y'
) maxlog
where log_id_rank = l_rank

)  creditlog
, as_lead_lines_log linelog
, as_leads_log leadlog
WHERE  linelog.lead_id=leadlog.lead_id
AND creditlog.lead_line_id=linelog.lead_line_id
AND linelog.lead_id = creditlog.lead_id

AND (
(creditlog.log_mode IN ('U', 'I')
AND creditlog.salesgroup_id IS NOT NULL
AND creditlog.CREDIT_TYPE_ID = g_credit_type_id)
OR
(creditlog.log_mode='D'))
AND TRUNC(leadlog.last_update_date) <= TRUNC(creditlog.last_update_date)
AND TRUNC(linelog.last_update_date) <= TRUNC(creditlog.last_update_date)
GROUP BY
leadlog.lead_id
, linelog.lead_line_id
, creditlog.sales_credit_id
, creditlog.log_id
, TRUNC(creditlog.last_update_date)
,DECODE(creditlog.log_mode,'D','D','N')
);
commit;


	IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
 	  bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'inserted ' || sql%rowcount || 'into denlog_tmp');
    END IF;

					/*delete  from BIL_BI_OPDTL_DENLOG_TMP tmp1
						where exists (select 1 from BIL_BI_OPDTL_DENLOG_TMP tmp2
						where tmp1.lead_id = tmp2.lead_id
						and tmp1.lead_line_id = tmp2.lead_line_id
						and tmp1.sales_credit_id = tmp2.sales_credit_id
						and tmp1.last_update_date = tmp2.last_update_date
						and tmp2.rev_flag = 'D')
						and rev_flag <> 'D'; */


					 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
 	  bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'deleted ' || sql%rowcount || 'from denlog_tmp for same day update ');
    END IF;

					INSERT  INTO BIL_BI_DENLOG_STG  denlog_stg
					(

					LEAD_LINE_ID ,
  					SALES_CREDIT_ID       ,
  					SALESGROUP_ID         ,
 				        SALESFORCE_ID         ,
  					LEAD_ID               ,
  					WIN_PROBABILITY       ,
  					CURRENCY_CODE         ,
  					WIN_LOSS_INDICATOR    ,
  					FORECAST_ROLLUP_FLAG  ,
  					ITEM_ID               ,
  					ITEM_ORGANIZATION_ID  ,
  					LEAD_NUMBER           ,
  					PRODUCT_CATEGORY_ID   ,
  					OPEN_STATUS_FLAG      ,
  					CREDIT_AMOUNT         ,
  					LAST_UPDATE_DATE      ,
  					DECISION_DATE
					)
					SELECT
   					 tmp.lead_line_id
   					 ,tmp.sales_credit_id
  					 ,creditlog.salesgroup_id
 					 ,creditlog.salesforce_id
					 ,leadlog.lead_id
					,decode(status.win_loss_indicator,'W', 100,  leadlog.WIN_PROBABILITY)
					 ,leadlog.currency_code
					 ,status.win_loss_indicator  win_loss_indicator
					 ,status.FORECAST_ROLLUP_FLAG forecast_rollup_flag
					 ,NVL(linelog.inventory_item_id, -1) item_id
					 , DECODE(linelog.Inventory_item_id, NULL, -99,
						  NVL(linelog.organization_id, -99)) ITEM_ORGANIZATION_ID
				        ,lead.lead_number
				        , linelog.product_category_id
				        , status.opp_open_status_flag open_status_flag
				        , creditlog.credit_amount
				        , tmp.last_update_date
				        , NVL(linelog.forecast_date, leadlog.decision_date)
				     FROM BIL_BI_OPDTL_DENLOG_TMP  tmp
					   ,as_sales_credits_log creditlog
					   , as_lead_lines_log linelog
					   , as_leads_log leadlog
					   , as_statuses_b status
					  , as_leads_all lead
			             WHERE tmp.rev_flag = 'N'
					   and tmp.lead_log_id = leadlog.log_id
					   AND tmp.lead_line_log_id = linelog.log_id
					   AND tmp.sales_credit_log_id = creditlog.log_id
					   AND creditlog.salesgroup_id IS NOT NULL
					   AND lead.lead_id = tmp.lead_id
					   AND status.status_Code = leadlog.status_Code
					   AND status.FORECAST_ROLLUP_FLAG = 'Y'
					   AND NVL(linelog.forecast_date, leadlog.decision_date) >=G_Global_Start_Date
					   AND NVL(linelog.forecast_date, leadlog.decision_date) between l_min_decision_start AND l_max_decision_end
					   AND tmp.last_update_date >= G_Global_Start_Date  --added by annsrini --fix for bug 5953589
					   AND tmp.last_update_date <= l_limit_date
					   AND NVL(linelog.forecast_date, leadlog.decision_date) <=l_limit_date
					   AND lead.decision_date >= G_Global_Start_Date
					   AND lead.decision_date <= l_limit_date;

		 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
 	  bil_bi_util_collection_pkg.writeLog
     (
       p_log_level => fnd_log.LEVEL_EVENT,
       p_module => g_pkg || l_proc ,
       p_msg => 'inserted ' || sql%rowcount || 'into denlog_stg');
    END IF;

		 commit;
		END IF;


IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;

 END Build_Denlog;

PROCEDURE Gap_Fill(p_start_date IN DATE, p_end_date IN DATE, p_curr_coll_start IN DATE, p_mode IN VARCHAR2, p_small_gap IN BOOLEAN) IS

   l_proc VARCHAR2(100);

    l_cur_date DATE;
   l_pre_date DATE;
   l_year_start_date DATE;

   l_year_end_date DATE;


   l_day   NUMBER;
   l_week    NUMBER;
   l_period    NUMBER;
   l_qtr   NUMBER;
   l_year    NUMBER;

    l_min_date_id   NUMBER;
   l_max_date_id   NUMBER;


   l_prev_year_end   NUMBER;


  l_dynamic_sql   VARCHAR2(2000);

  l_sd_lyr   DATE; --same date last year
  l_sd_lper    DATE; --same date last period
  l_sd_lqtr    DATE; -- same date last quarter
  l_sd_lwk   DATE; --same date last week


  l_sd_lyr_end   DATE; --same date last year (end of the year/qtr/period/week)
  l_sd_lper_end    DATE; --same date last period (end of the year/qtr/period/week)
  l_sd_lqtr_end   DATE; -- same date last quarter (end of the year/qtr/period/week)
  l_sd_lwk_end   DATE; --same date last week (end of the year/qtr/period/week)
  l_pipe_tbl_type  VARCHAR2(10);

  -- This cursor will return every day in the current collection time range: tbl='CURR'
  -- and every week/period end date for historical and **current tbl**='HST' - we need
  -- **current tbl**
  --also because we insert into hist pipe tbl dta for end of weeks/periods in the current
  --time range as well, to help FE queries performance


    CURSOR c1(p_curr_coll_start DATE, p_start_date DATE, p_end_date DATE) IS
 select report_date, tbl FROM
 (SELECT report_date, 'CURR' tbl
 FROM fii_time_day day
 WHERE  report_date BETWEEN decode(greatest(p_start_date, p_curr_coll_start), p_start_date,
     p_start_date, p_curr_coll_start)
      AND p_end_date
 UNION ALL
 SELECT end_date report_date, 'HIST' tbl
 FROM BIL_BI_TIME time

 -- WHERE end_date <= p_end_date  -- Commented by TR bcos we dont want overlap of HIST and CURR data
 WHERE end_date < p_curr_coll_start
 )
 order by report_date;

 BEGIN

  l_proc := 'Gap_Fill';

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(

   p_log_level => fnd_log.LEVEL_PROCEDURE,
   p_module => g_pkg || l_proc || ' begin',
   p_msg => 'Start of Procedure '|| l_proc);
  END IF;



      OPEN c1(p_curr_coll_start, p_start_date, p_end_date);
      LOOP
       FETCH c1 INTO
        l_cur_date, l_pipe_tbl_type;

       EXIT WHEN c1%NOTFOUND ;



IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
 bil_bi_util_collection_pkg.writeLog
 (
 p_log_level => fnd_log.LEVEL_EVENT,
 p_module => g_pkg || l_proc ,
 p_msg => 'working on ' || l_cur_date || 'l_type: ' || l_pipe_tbl_type);
  END IF;


        SELECT
         time.report_date_julian, time.week_id, time.ent_period_id,
         time.ent_qtr_id, time.ent_year_id,  to_number(to_char(LEAST(time.ent_year_start_date, time1.week_start_date), 'J')),
         to_number(to_char(GREATEST(time.ent_year_end_date,time2.week_end_date), 'J'))
         INTO
         l_day, l_week, l_period, l_qtr, l_year, l_min_date_id, l_max_date_id
         FROM
         FII_TIME_DAY time,
         FII_TIME_DAY time1,
     FII_TIME_DAY time2

         WHERE
         time.report_date = l_cur_date
         AND time1.report_date = time.ent_year_start_date
     AND time2.report_date = time.ent_year_end_date ;





IF (p_mode = 'INIT') THEN

IF (p_small_gap = FALSE) THEN
      -- if gap bigger than 3 days, delet  and  insert into staging for current date
          DELETE /*+  parallel(stg1) */ FROM bil_bi_pipeline_stg stg1
         WHERE EXISTS (SELECT /*+ parallel(tmp) */ 1 FROM bil_bi_opdtl_denlog_tmp tmp
         WHERE tmp.lead_id = stg1.lead_id
         AND tmp.lead_line_id = stg1.line_id
         AND tmp.sales_credit_id = stg1.credit_id
         AND last_update_date = l_cur_date);

          IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
           bil_bi_util_collection_pkg.writeLog

         (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'deleted ' || sql%rowcount || 'from stg');
          END IF;

        commit;


/*
         IF(l_prev_year_end is NULL) THEN

          l_prev_year_end := l_max_date_id;
         END IF;

         IF(l_day > l_prev_year_end) THEN
          -- delete most of last year's data */
           --  DELETE /*+parallel(stg) */FROM bil_bi_pipeline_stg stg
         /*  WHERE to_number(to_char(EFFECTIVE_DATE, 'J'))  < l_min_date_id;


          IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
           bil_bi_util_collection_pkg.writeLog

         (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'deleted ' || sql%rowcount || 'from stg for last year ');
          END IF;
          commit;

          -- update l_prev_year_end
          l_prev_year_end := l_max_date_id;

         END IF;


*/

-- if gap bigger than 3 days, delete and insert into staging for current date

          INSERT /*+ append */ INTO bil_bi_pipeline_stg stg(
          line_id,
          credit_id,
          SALES_GROUP_ID,
         SALESREP_ID,
          LEAD_ID,

          WIN_PROBABILITY,
          TXN_CURRENCY,
          WIN_LOSS_INDICATOR,
          FORECAST_ROLLUP_FLAG,
          ITEM_ID,
          ITEM_ORGANIZATION_ID,
          LEAD_NUMBER,
          PRODUCT_CATEGORY_ID,
          OPP_OPEN_STATUS_FLAG,
          SALES_CREDIT_AMOUNT,
          snap_date,

          EFFECTIVE_DATE,
          PRIM_CONVERSION_RATE,
          CONVERSION_RATE_S
         ) SELECT /*+ parallel(tmp) */
         lead_line_id,
         sales_credit_id
          ,salesgroup_id
          ,salesforce_id
          ,lead_id
          ,WIN_PROBABILITY
          ,currency_code

          ,win_loss_indicator
          ,forecast_rollup_flag
          ,item_id
          ,item_organization_id
          ,lead_number
          ,product_category_id
          ,open_status_flag
          ,credit_amount
          , last_update_date
          , decision_date
          , prim_conversion_rate

          , conversion_rate_s
        FROM BIL_BI_DENLOG_STG tmp
        WHERE tmp.last_update_date = l_cur_date
        AND product_category_id is not null;



  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog
 (
 p_log_level => fnd_log.LEVEL_EVENT,

 p_module => g_pkg || l_proc ,
 p_msg => 'inserted' || sql%rowcount || 'into stg');
  END IF;

  commit;

END IF;

  IF l_pipe_tbl_type = 'HIST' THEN
      -- parallel hints are disabled since they actually offer less performance in testing
      -- for this query

      INSERT /*+ append */INTO bil_bi_pipeline_f f
        (
        sales_group_id,
        salesrep_id,
        created_by ,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,

        program_id,
        program_update_date,
        snap_date,
        item_id,
        item_organization_id,
        win_probability,
        product_category_id,
        pipeline_amt_day,
        pipeline_amt_week,
        pipeline_amt_period,
        pipeline_amt_quarter,

        pipeline_amt_year,
        open_amt_day,
        open_amt_week,
        open_amt_period,
        open_amt_quarter,
        open_amt_year,
        pipeline_amt_day_s,
        pipeline_amt_week_s,
        pipeline_amt_period_s,
        pipeline_amt_quarter_s,
        pipeline_amt_year_s,

        open_amt_day_s,
        open_amt_week_s,
        open_amt_period_s,
        open_amt_quarter_s,
        open_amt_year_s
        )
        SELECT /*+ parallel(stg) */
        SALES_GROUP_ID,
        SALESREP_ID,
        g_user_id,
        SYSDATE,

        g_user_id,
        SYSDATE,
        G_Login_Id,
        G_request_id,
        G_appl_id,
        G_program_id,
        SYSDATE,
        l_cur_date,
        ITEM_ID,
        ITEM_ORGANIZATION_ID,
        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY) win_probability,

        PRODUCT_CATEGORY_ID,
        SUM(CASE
        WHEN TIME.report_date = l_cur_date
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        ),
        SUM(CASE
        WHEN TIME.week_id = l_week
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        ),

        SUM(CASE
        WHEN TIME.ent_period_id = l_period
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_qtr_id = l_qtr
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,

       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
       SUM( CASE
        WHEN TIME.report_date = l_cur_date  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
        SUM( CASE
        WHEN TIME.week_id = l_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
        SUM(CASE
        WHEN TIME.ent_period_id = l_period  AND OPP_OPEN_STATUS_FLAG = 'Y'

        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_qtr_id = l_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE

        WHEN TIME.report_date = l_cur_date
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        ),
        SUM(CASE
        WHEN TIME.week_id = l_week
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END
        ),
        SUM(CASE
        WHEN TIME.ent_period_id = l_period

        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_qtr_id = l_qtr
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
       SUM( CASE

        WHEN TIME.report_date = l_cur_date  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
        SUM( CASE
        WHEN TIME.week_id = l_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
        SUM(CASE
        WHEN TIME.ent_period_id = l_period  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),

        SUM(CASE
        WHEN TIME.ent_qtr_id = l_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END )
        FROM
        bil_bi_pipeline_stg stg,
        fii_time_day time

        WHERE stg.effective_date =  TIME.report_date
        AND forecast_rollup_flag = 'Y'
        AND TIME.report_date_julian BETWEEN l_min_date_id AND l_max_date_id
        GROUP BY
        sales_group_id,
        salesrep_id,
        item_id,
        item_organization_id,
        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY),
        product_category_id
        HAVING

        SUM(CASE
        WHEN TIME.week_id = l_week
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        )IS NOT NULL OR
        SUM(CASE
        WHEN TIME.ent_year_id = l_year
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )
       IS NOT NULL ;



ELSE
--insert into bil_bi_pipec_f

    Insert_into_curr_sumry(l_cur_date,  l_week, l_period
      , l_qtr, l_year, l_min_date_id, l_max_date_id);


END IF ; --INIT/INCR

       ELSE
	   IF (p_small_gap = FALSE) THEN --gap bigger than 3 days
         DELETE /*+ index(stg1,BIL_BI_PIPELINE_STG_U1)  */ FROM bil_bi_pipeline_stg stg1
         WHERE EXISTS (SELECT  1 FROM bil_bi_opdtl_denlog_tmp tmp
         WHERE tmp.lead_id = stg1.lead_id
         AND tmp.lead_line_id = stg1.line_id

         AND tmp.sales_credit_id = stg1.credit_id
         AND last_update_date = l_cur_date);

          IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
           bil_bi_util_collection_pkg.writeLog
         (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'deleted ' || sql%rowcount || 'from stg');
          END IF;


        commit;
/*
         IF(l_prev_year_end is NULL) THEN
          l_prev_year_end := l_max_date_id;
         END IF;

         IF(l_day > l_prev_year_end) THEN
          -- delete most of last year's data
           DELETE  FROM bil_bi_pipeline_stg stg
         WHERE to_number(to_char(EFFECTIVE_DATE, 'J'))  < l_min_date_id;



          IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
           bil_bi_util_collection_pkg.writeLog
         (
         p_log_level => fnd_log.LEVEL_EVENT,
         p_module => g_pkg || l_proc ,
         p_msg => 'deleted ' || sql%rowcount || 'from stg for last year ');
          END IF;
          commit;

          -- update l_prev_year_end

          l_prev_year_end := l_max_date_id;

         END IF;
*/



          INSERT INTO bil_bi_pipeline_stg stg(
          line_id,
          credit_id,
          SALES_GROUP_ID,

           SALESREP_ID,
          LEAD_ID,
          WIN_PROBABILITY,
          TXN_CURRENCY,
          WIN_LOSS_INDICATOR,
          FORECAST_ROLLUP_FLAG,
          ITEM_ID,
          ITEM_ORGANIZATION_ID,
          LEAD_NUMBER,
          PRODUCT_CATEGORY_ID,
          OPP_OPEN_STATUS_FLAG,

          SALES_CREDIT_AMOUNT,
          snap_date,
          EFFECTIVE_DATE,
          PRIM_CONVERSION_RATE,
          CONVERSION_RATE_S
         ) SELECT
         lead_line_id,
         sales_credit_id
          ,salesgroup_id
          ,salesforce_id
          ,lead_id

          ,WIN_PROBABILITY
          ,currency_code
          ,win_loss_indicator
          ,forecast_rollup_flag
          ,item_id
          ,item_organization_id
          ,lead_number
          ,product_category_id
          ,open_status_flag
          ,credit_amount
          , last_update_date

          , decision_date
          , prim_conversion_rate
          , conversion_rate_s
        FROM BIL_BI_DENLOG_STG tmp
        WHERE tmp.last_update_date = l_cur_date
        AND product_category_id is not null;



IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
          bil_bi_util_collection_pkg.writeLog

 (
 p_log_level => fnd_log.LEVEL_EVENT,
 p_module => g_pkg || l_proc ,
 p_msg => 'inserted' || sql%rowcount || 'into stg');
  END IF;

  commit;

END IF; --gap smaller than 3 days

  IF l_pipe_tbl_type = 'HIST' THEN

      INSERT INTO bil_bi_pipeline_f f

        (
        sales_group_id,
        salesrep_id,
        created_by ,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,

        program_update_date,
        snap_date,
        item_id,
        item_organization_id,
        win_probability,
        product_category_id,
        pipeline_amt_day,
        pipeline_amt_week,
        pipeline_amt_period,
        pipeline_amt_quarter,
        pipeline_amt_year,

        open_amt_day,
        open_amt_week,
        open_amt_period,
        open_amt_quarter,
        open_amt_year,
        pipeline_amt_day_s,
        pipeline_amt_week_s,
        pipeline_amt_period_s,
        pipeline_amt_quarter_s,
        pipeline_amt_year_s,
        open_amt_day_s,

        open_amt_week_s,
        open_amt_period_s,
        open_amt_quarter_s,
        open_amt_year_s
        )
        SELECT
        SALES_GROUP_ID,
        SALESREP_ID,
        g_user_id,
        SYSDATE,
        g_user_id,

        SYSDATE,
        G_Login_Id,
        G_request_id,
        G_appl_id,
        G_program_id,
        SYSDATE,
        l_cur_date,
        ITEM_ID,
        ITEM_ORGANIZATION_ID,
        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY) win_probability,
        PRODUCT_CATEGORY_ID,

        SUM(CASE
        WHEN TIME.report_date = l_cur_date
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        ),
        SUM(CASE
        WHEN TIME.week_id = l_week
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        ),
        SUM(CASE

        WHEN TIME.ent_period_id = l_period
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_qtr_id = l_qtr
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),

       SUM( CASE
        WHEN TIME.report_date = l_cur_date  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
        SUM( CASE
        WHEN TIME.week_id = l_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END),
        SUM(CASE
        WHEN TIME.ent_period_id = l_period  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,

       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_qtr_id = l_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.report_date = l_cur_date

        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        ),
        SUM(CASE
        WHEN TIME.week_id = l_week
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END
        ),
        SUM(CASE
        WHEN TIME.ent_period_id = l_period
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,

        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_qtr_id = l_qtr
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
       SUM( CASE
        WHEN TIME.report_date = l_cur_date  AND OPP_OPEN_STATUS_FLAG = 'Y'

        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
        SUM( CASE
        WHEN TIME.week_id = l_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
        SUM(CASE
        WHEN TIME.ent_period_id = l_period  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ),
        SUM(CASE

        WHEN TIME.ent_qtr_id = l_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END),
        SUM(CASE
        WHEN TIME.ent_year_id = l_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
        THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
        stg.sales_credit_amount*conversion_rate_s) ELSE NULL END )
        FROM
        bil_bi_pipeline_stg stg,
        fii_time_day time
        WHERE stg.effective_date =  TIME.report_date

        AND forecast_rollup_flag = 'Y'
        AND TIME.report_date_julian BETWEEN l_min_date_id AND l_max_date_id
        GROUP BY
        sales_group_id,
        salesrep_id,
        item_id,
        item_organization_id,
        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY),
        product_category_id
        HAVING
        SUM(CASE

        WHEN TIME.week_id = l_week
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
        )IS NOT NULL OR
        SUM(CASE
        WHEN TIME.ent_year_id = l_year
        THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
       stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )
       IS NOT NULL ;



ELSE
--insert into bil_bi_pipec_f

--also insert prior amounts from bil_bi_pipeline_f
--since we may not have data for the same day last week/quarter/period/year in the hist. table
--we need to get the end of the week/quarter ...
--if the same day last year is closer to the end of a certain week/quarter/period
--than to the end of te year, get the closest date
-- this can be acheived by using the bil_bi_time table:

    IF (p_small_gap = FALSE) THEN
    Insert_into_curr_sumry(l_cur_date,  l_week, l_period
      , l_qtr, l_year, l_min_date_id, l_max_date_id);
  ELSE
     Ins_into_CurrSum_SmGap(l_cur_date,  l_week, l_period
      , l_qtr, l_year, l_min_date_id, l_max_date_id);
  END IF;



END IF ; --if pipe_tbl_type='HIST'

END IF;

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
     bil_bi_util_collection_pkg.writeLog
 (
 p_log_level => fnd_log.LEVEL_EVENT,
 p_module => g_pkg || l_proc ,
 p_msg => 'inserted ' || sql%rowcount || 'into fact');
  END IF;


  commit;

        END LOOP;

       CLOSE c1;


 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
   p_log_level => fnd_log.LEVEL_PROCEDURE,

   p_module => g_pkg || l_proc || ' end',
   p_msg => 'End of Procedure '|| l_proc);
 END IF;

 EXCEPTION

WHEN OTHERS THEN
  fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
  fnd_message.set_token('ERRNO' ,SQLCODE);
  fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);

  bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

  raise;

 END Gap_Fill;

PROCEDURE Insert_Into_Stg_SmallGap(p_start_date IN DATE, p_end_date IN DATE, p_first_fact_run IN DATE) IS

l_proc VARCHAR2(100);
l_count NUMBER;
l_limit_date DATE; --added by annsrini --fix for bug 5953589

BEGIN

l_proc := 'Insert_Into_Stg_SmallGap';
l_limit_date := add_months(trunc(g_program_start),24); --added by annsrini --fix for bug 5953589

  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
            bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
  END IF;

--Removed hints for FTS in select -- fix for bug 7595743

INSERT /*+ APPEND PARALLEL(stg) */  INTO bil_bi_pipeline_stg stg(
	SALES_GROUP_ID,
   	SALESREP_ID,
	LEAD_ID,
	WIN_PROBABILITY,
	TXN_CURRENCY,
	WIN_LOSS_INDICATOR,
	FORECAST_ROLLUP_FLAG,
	ITEM_ID,
	ITEM_ORGANIZATION_ID,
	LEAD_NUMBER,
	PRODUCT_CATEGORY_ID,
	OPP_OPEN_STATUS_FLAG,
	SALES_CREDIT_AMOUNT,
	SNAP_DATE,
	EFFECTIVE_DATE
   )
   SELECT
  creditlog.salesgroup_id
 ,creditlog.salesforce_id
 ,maxlog.lead_id
 ,decode(status.win_loss_indicator,'W', 100,  maxlog.WIN_PROBABILITY)
 ,maxlog.currency_code
 ,status.win_loss_indicator  win_loss_indicator
 ,status.FORECAST_ROLLUP_FLAG forecast_rollup_flag
        ,nvl(linelog.inventory_item_id, -1)
        , decode(linelog.Inventory_item_id, null, -99,
nvl(linelog.organization_id, -99))
        ,lead.lead_number
        , linelog.product_category_id
        , status.opp_open_status_flag open_status_flag
        , sum(creditlog.credit_amount)
        , maxlog.report_date
        , maxlog.decision_date
   FROM  as_leads_all lead
       , as_lead_lines_log linelog
       , as_statuses_b status
       , as_sales_credits_log creditlog
       , (-- alias maxlog
 SELECT
             leadlog2.lead_id     lead_id
           , MAX(leadlog2.max_id)      lead_log_id
           , linelog1.lead_line_id    lead_line_id
           , MAX(linelog1.log_id) lead_line_log_id
           , creditlog1.sales_credit_id sales_credit_id
           , MAX(creditlog1.log_id) sales_credit_log_id
           , leadlog2.report_date report_date
           , leadlog2.currency_code
           , leadlog2.status_code
           , leadlog2.win_probability
           ,  NVL(linelog1.forecast_date, leadlog2.decision_date) decision_date
          FROM
             as_sales_credits_log creditlog1,
             as_lead_lines_log linelog1,
            ( -- alias leadlog2
             SELECT  maxlead.report_date, maxlead.start_date,maxlead.end_date,maxlead.lead_id, maxlead.max_id,
              llog.decision_date, llog.win_probability, llog.status_code,
              llog.currency_code
              FROM
              ( -- alias maxlead
                SELECT  gapdays.report_date, gapdays.start_date, gapdays.end_date,
                      leadlog1.lead_id, max(leadlog1.log_id) max_id
                 FROM as_leads_log leadlog1,
                     ( -- alias gapdays
                       SELECT report_date,
                              LEAST(year.start_date, week.start_date) start_date,
                              GREATEST(year.end_date,week.end_date) end_date
                         FROM
                              fii_time_ent_year  year
                            , fii_time_week week
                            , fii_time_day day
                         WHERE report_date between p_start_date and p_end_date
                           AND day.week_id = week.week_id
                           AND day.ent_year_id = year.ent_year_id
                     ) gapdays
                WHERE leadlog1.last_update_date < gapdays.report_date+1
		    GROUP BY lead_id, gapdays.report_date, gapdays.start_date, gapdays.end_date
              ) maxlead,
              as_leads_log llog
              WHERE maxlead.max_id = llog.log_id
                and llog.decision_date >= p_first_fact_run
		    and llog.decision_date <= l_limit_date --added by annsrini  --fix for bug 5953589
                AND llog.decision_date between maxlead.start_date and maxlead.end_date
            ) leadlog2
        WHERE linelog1.lead_id=leadlog2.lead_id
          AND creditlog1.lead_line_id=linelog1.lead_line_id
          AND creditlog1.lead_id = leadlog2.lead_id
          AND linelog1.lead_id = creditlog1.lead_id
          AND linelog1.last_update_date < leadlog2.report_date+1
          AND creditlog1.last_update_date < leadlog2.report_date+1
	    AND nvl(linelog1.forecast_date,leadlog2.decision_date) >= p_first_fact_run  --added by annsrini  --fix for bug 5953589
	    AND nvl(linelog1.forecast_date,leadlog2.decision_date) between leadlog2.start_date and leadlog2.end_date
          AND nvl(linelog1.forecast_date,leadlog2.decision_date) <= l_limit_date
          AND ((creditlog1.log_mode in ('U', 'I')
               AND creditlog1.salesgroup_id IS NOT NULL
               AND creditlog1.CREDIT_TYPE_ID = g_credit_type_id)
               OR
               (creditlog1.log_mode='D'))
         GROUP BY
           creditlog1.sales_credit_id
         , leadlog2.lead_id
         , linelog1.lead_line_id
         , leadlog2.report_date
         , leadlog2.currency_code
           , leadlog2.status_code
           , leadlog2.win_probability
           ,NVL(linelog1.forecast_date, leadlog2.decision_date)
          ) maxlog
   WHERE maxlog.lead_line_log_id = linelog.log_id
     AND maxlog.sales_credit_log_id = creditlog.log_id
     AND creditlog.salesgroup_id is not null
     AND lead.lead_id = maxlog.lead_id
     AND status.status_Code = maxlog.status_Code
   GROUP BY creditlog.salesgroup_id
           ,creditlog.salesforce_id
           ,maxlog.lead_id
           ,maxlog.WIN_PROBABILITY
           ,maxlog.currency_code
           ,status.win_loss_indicator
           ,status.FORECAST_ROLLUP_FLAG
           ,nvl(linelog.inventory_item_id, -1)
           ,decode(linelog.Inventory_item_id, null, -99, nvl(linelog.organization_id, -99))
           ,lead.lead_number
           ,linelog.product_category_id
           ,status.opp_open_status_flag
           ,maxlog.report_date
           ,maxlog.decision_date;
commit;


SELECT COUNT(1) INTO l_count FROM BIL_BI_PIPELINE_STG;


 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_EVENT,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'Inserted into staging from as log tables '|| l_count);
 END IF;

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

 EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;
END Insert_Into_Stg_SmallGap;

PROCEDURE Ins_Into_CurrSum_SmGap(p_date IN DATE,  p_week IN NUMBER, p_period IN NUMBER,
		  						 p_qtr IN NUMBER, p_year IN NUMBER, p_min_date_id IN NUMBER,
								 p_max_date_id IN NUMBER) IS

l_sd_lwk_end DATE;
l_sd_lper_end DATE;
l_sd_lqtr_end DATE;
l_sd_lyr_end DATE;
l_sd_lwk DATE;
l_sd_lper DATE;
l_sd_lqtr DATE;
l_sd_lyr DATE;
l_proc VARCHAR2(100);
l_dynamic_sql VARCHAR2(1000);

BEGIN

l_proc := 'Ins_Into_CurrSum_SmGap';

 IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
    bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' begin',
             p_msg => 'Start of Procedure '|| l_proc);
    END IF;

BEGIN
                              l_dynamic_sql := 'BEGIN :1 := fii_time_api.sd_pwk(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lwk, IN p_date;

                 SELECT week_end_date
                 INTO l_sd_lwk_end
                 from fii_time_day
                 where report_date=l_sd_lwk;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_pper_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lper, IN p_date;

                 SELECT LEAST(week_end_date, ent_period_end_date)
                 INTO l_sd_lper_end
                 from fii_time_day
                 where report_date=l_sd_lper;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_pqtr_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lqtr, IN p_date;

                 SELECT LEAST(week_end_date, ent_qtr_end_date)
                 INTO l_sd_lqtr_end
                 from fii_time_day
                 where report_date=l_sd_lqtr;

                 l_dynamic_sql := 'BEGIN :1 := fii_time_api.ent_sd_lyr_end(:2); END;';
                 EXECUTE IMMEDIATE l_dynamic_sql USING OUT l_sd_lyr, IN p_date;

                  SELECT LEAST(week_end_date, ent_year_end_date)
                 INTO l_sd_lyr_end
                 from fii_time_day
                 where report_date=l_sd_lyr;

EXCEPTION WHEN NO_DATA_FOUND THEN
    NULL;
	IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_EVENT) THEN
 bil_bi_util_collection_pkg.writeLog
 (
 p_log_level => fnd_log.LEVEL_EVENT,
 p_module => g_pkg || l_proc ,
 p_msg => 'inside no_data_found in  insert into curr sumry ');
  END IF;

END;


       --also insert prior amounts from bil_bi_pipeline_f
--since we may not have data for the same day last week/quarter/period/year in the hist. table
--we need to get the end of the week/quarter ...
--if the same day last year is closer to the end of a certain week/quarter/period
--than to the end of te year, get the closest date
-- this can be achieved by using the bil_bi_time table:



						  INSERT /*+ append parallel(f) */INTO bil_bi_pipec_f f
			      (
			        sales_group_id,
			        salesrep_id,
			        created_by ,
			        creation_date,
			        last_updated_by,
			        last_update_date,
			        last_update_login,
			        request_id,
			        program_application_id,
			        program_id,
			        program_update_date,
			        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
			        pipeline_amt_day,
			        pipeline_amt_week,
			        pipeline_amt_period,
			        pipeline_amt_quarter,
			        pipeline_amt_year,
			        open_amt_day,
			        open_amt_week,
			        open_amt_period,
			        open_amt_quarter,
			        open_amt_year,
			        pipeline_amt_day_s,
			        pipeline_amt_week_s,
			        pipeline_amt_period_s,
			        pipeline_amt_quarter_s,
			        pipeline_amt_year_s,
			        open_amt_day_s,
			        open_amt_week_s,
			        open_amt_period_s,
			        open_amt_quarter_s,
			        open_amt_year_s,

                    prvprd_pipe_amt_wk  ,
                    prvprd_pipe_amt_PRD ,
                    prvprd_pipe_amt_qtr ,
                    prvprd_pipe_amt_yr  ,
                    prvprd_open_amt_wk  ,
                    prvprd_open_amt_PRD ,
                    prvprd_open_amt_qtr ,
                    prvprd_open_amt_yr  ,
                    prvprd_pipe_amt_wk_s,
                    prvprd_pipe_amt_PRD_s,
                    prvprd_pipe_amt_qtr_s,
                    prvprd_pipe_amt_yr_s,
                    prvprd_open_amt_wk_s,
                    prvprd_open_amt_PRD_s,
                    prvprd_open_amt_qtr_s,
                    prvprd_open_amt_yr_s,

                    prvyr_pipe_amt_wk   ,
                    prvyr_pipe_amt_PRD  ,
                    prvyr_pipe_amt_qtr  ,
                    prvyr_pipe_amt_yr   ,
                                        prvyr_open_amt_wk   ,
                    prvyr_open_amt_PRD  ,
                    prvyr_open_amt_qtr  ,
                    prvyr_open_amt_yr   ,
                    prvyr_pipe_amt_wk_s ,
                    prvyr_pipe_amt_PRD_s,
                    prvyr_pipe_amt_qtr_s,
                    prvyr_pipe_amt_yr_s ,
                    prvyr_open_amt_wk_s ,
                    prvyr_open_amt_PRD_s,
                    prvyr_open_amt_qtr_s,
                    prvyr_open_amt_yr_s
                      )

                            SELECT sales_group_id,
			        salesrep_id,
		            g_user_id created_by,
			        SYSDATE creation_date,
			        g_user_id last_updated_by,
			        SYSDATE last_update_date,
			        G_Login_Id last_update_login,
        			G_request_id request_id,
        			G_appl_id program_application_id,
        			G_program_id program_id,
			        SYSDATE program_update_date,	        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    SUM(pipeline_amt_day) pipeline_amt_day,
                    SUM(pipeline_amt_week) pipeline_amt_week,
                    SUM(pipeline_amt_period) pipeline_amt_period,
                    SUM(pipeline_amt_quarter) pipeline_amt_quarter,
                    SUM(pipeline_amt_year) pipeline_amt_year,
                    SUM(open_amt_day)  open_amt_day   ,
                    SUM(open_amt_week)  open_amt_week  ,
                    SUM(open_amt_period) open_amt_period ,
                    SUM(open_amt_quarter) open_amt_quarter,
                    SUM(open_amt_year) open_amt_year   ,
                    SUM(pipeline_amt_day_s) pipeline_amt_day_s,
                    SUM(pipeline_amt_week_s) pipeline_amt_week_s,
                    SUM(pipeline_amt_period_s) pipeline_amt_period_s,
                    SUM(pipeline_amt_quarter_s) pipeline_amt_quarter_s,
                    SUM(pipeline_amt_year_s) pipeline_amt_year_s,
                    SUM(open_amt_day_s) open_amt_day_s  ,
                    SUM(open_amt_week_s) open_amt_week_s ,
                    SUM(open_amt_period_s) open_amt_period_s,
                    SUM(open_amt_quarter_s) open_amt_quarter_s,
                    SUM(open_amt_year_s) open_amt_year_s ,
                                SUM(prvprd_pipe_amt_wk)  prvprd_pipe_amt_wk,
                SUM(prvprd_pipe_amt_PRD) prvprd_pipe_amt_PRD,
                SUM(prvprd_pipe_amt_qtr) prvprd_pipe_amt_qtr,
                SUM(prvprd_pipe_amt_yr) prvprd_pipe_amt_yr ,
                SUM(prvprd_open_amt_wk) prvprd_open_amt_wk ,
                SUM(prvprd_open_amt_PRD) prvprd_open_amt_PRD,
                SUM(prvprd_open_amt_qtr) prvprd_open_amt_qtr,
                SUM(prvprd_open_amt_yr)  prvprd_open_amt_yr,
                SUM(prvprd_pipe_amt_wk_s)  prvprd_pipe_amt_wk_s,
                SUM(prvprd_pipe_amt_PRD_s) prvprd_pipe_amt_PRD_s,
                SUM(prvprd_pipe_amt_qtr_s) prvprd_pipe_amt_qtr_s,
                SUM(prvprd_pipe_amt_yr_s) prvprd_pipe_amt_yr_s ,
                SUM(prvprd_open_amt_wk_s) prvprd_open_amt_wk_s ,
                SUM(prvprd_open_amt_PRD_s) prvprd_open_amt_PRD_s,
                SUM(prvprd_open_amt_qtr_s) prvprd_open_amt_qtr_s,
                SUM(prvprd_open_amt_yr_s) prvprd_open_amt_yr_s,
                SUM(prvyr_pipe_amt_wk)  prvyr_pipe_amt_wk ,
                SUM(prvyr_pipe_amt_PRD)  prvyr_pipe_amt_PRD,
                SUM(prvyr_pipe_amt_qtr)  prvyr_pipe_amt_qtr,
                SUM(prvyr_pipe_amt_yr) prvyr_pipe_amt_yr  ,
                SUM(prvyr_open_amt_wk) prvyr_open_amt_wk   ,
                SUM(prvyr_open_amt_PRD) prvyr_open_amt_PRD ,
                SUM(prvyr_open_amt_qtr) prvyr_open_amt_qtr ,
                SUM(prvyr_open_amt_yr) prvyr_open_amt_yr  ,
                SUM(prvyr_pipe_amt_wk_s)  prvyr_pipe_amt_wk_s ,
                SUM(prvyr_pipe_amt_PRD_s) prvyr_pipe_amt_PRD_s ,
                SUM(prvyr_pipe_amt_qtr_s) prvyr_pipe_amt_qtr_s ,
                SUM(prvyr_pipe_amt_yr_s)   prvyr_pipe_amt_yr_s,
                SUM(prvyr_open_amt_wk_s) prvyr_open_amt_wk_s  ,
                SUM(prvyr_open_amt_PRD_s) prvyr_open_amt_PRD_s ,
                SUM(prvyr_open_amt_qtr_s) prvyr_open_amt_qtr_s ,
                SUM(prvyr_open_amt_yr_s) prvyr_open_amt_yr_s
                  FROM (
			      SELECT /*+ parallel(stg) */
			        SALES_GROUP_ID,
			        SALESREP_ID,
			        p_date snap_date,
			        ITEM_ID,
			        ITEM_ORGANIZATION_ID,
			        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY) win_probability,
			        PRODUCT_CATEGORY_ID,
			        SUM(CASE
			            WHEN TIME.report_date = p_date
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        ) pipeline_amt_day,
			        SUM(CASE
			            WHEN TIME.week_id = p_week
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        ) pipeline_amt_week,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )pipeline_amt_period,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) pipeline_amt_quarter,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) pipeline_amt_year,
			         SUM( CASE
			            WHEN TIME.report_date = p_date  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END) open_amt_day,
			        SUM( CASE
			            WHEN TIME.week_id = p_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END) open_amt_week,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) open_amt_period,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) open_amt_quarter,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END ) open_amt_year,
			        SUM(CASE
			            WHEN TIME.report_date = p_date
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        ) pipeline_amt_day_s,
			        SUM(CASE
			            WHEN TIME.week_id = p_week
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END
			        ) pipeline_amt_week_s,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) pipeline_amt_period_s,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) pipeline_amt_quarter_s,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) pipeline_amt_year_s,
			         SUM( CASE
			            WHEN TIME.report_date = p_date  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) open_amt_day_s,
			        SUM( CASE
			            WHEN TIME.week_id = p_week  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) open_amt_week_s,
			        SUM(CASE
			            WHEN TIME.ent_period_id = p_period  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) open_amt_period_s,
			        SUM(CASE
			            WHEN TIME.ent_qtr_id = p_qtr  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END) open_amt_quarter_s,
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year  AND OPP_OPEN_STATUS_FLAG = 'Y'
			            THEN DECODE(stg.sales_credit_amount*conversion_rate_s, 0, NULL,
			          stg.sales_credit_amount*conversion_rate_s) ELSE NULL END ) open_amt_year_s,

                null prvprd_pipe_amt_wk  ,
                null prvprd_pipe_amt_PRD ,
                null prvprd_pipe_amt_qtr ,
                null prvprd_pipe_amt_yr  ,
                null prvprd_open_amt_wk  ,
                null prvprd_open_amt_PRD ,
                null prvprd_open_amt_qtr ,
                null prvprd_open_amt_yr  ,
                null prvprd_pipe_amt_wk_s,
                null prvprd_pipe_amt_PRD_s,
                null prvprd_pipe_amt_qtr_s,
                null prvprd_pipe_amt_yr_s,
                null prvprd_open_amt_wk_s,
                null prvprd_open_amt_PRD_s,
                null prvprd_open_amt_qtr_s,
                null prvprd_open_amt_yr_s,
                null prvyr_pipe_amt_wk   ,
                null prvyr_pipe_amt_PRD  ,
                null prvyr_pipe_amt_qtr  ,
                null prvyr_pipe_amt_yr   ,
                null prvyr_open_amt_wk   ,
                null prvyr_open_amt_PRD  ,
                null prvyr_open_amt_qtr  ,
                null prvyr_open_amt_yr   ,
                null prvyr_pipe_amt_wk_s ,
                null prvyr_pipe_amt_PRD_s,
                null prvyr_pipe_amt_qtr_s,
                null prvyr_pipe_amt_yr_s ,
                null prvyr_open_amt_wk_s ,
                null prvyr_open_amt_PRD_s,
                null prvyr_open_amt_qtr_s,
                null prvyr_open_amt_yr_s

                  FROM
			        bil_bi_pipeline_stg stg,
			        fii_time_day time
			      WHERE stg.effective_date =  TIME.report_date
			        AND forecast_rollup_flag = 'Y'
			        AND TIME.report_date_julian>= p_min_date_id AND TIME.report_date_julian+0<=p_max_date_id
					AND stg.snap_date = p_date
			      GROUP BY
			        sales_group_id,
			        salesrep_id,
			        item_id,
			        item_organization_id,
			        DECODE(stg.win_loss_indicator, 'W', 100, stg.WIN_PROBABILITY),
			        product_category_id
			      HAVING
			        SUM(CASE
			            WHEN TIME.week_id = p_week
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END
			        )IS NOT NULL OR
			        SUM(CASE
			            WHEN TIME.ent_year_id = p_year
			            THEN DECODE(stg.sales_credit_amount*prim_conversion_rate, 0, NULL,
			         stg.sales_credit_amount*prim_conversion_rate) ELSE NULL END )
			         IS NOT NULL
 UNION ALL
                      SELECT /*+ parallel(f) */ sales_group_id,
			        salesrep_id,
			        p_date snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    null pipeline_amt_day ,
                    null pipeline_amt_week,
                    null pipeline_amt_period,
                    null pipeline_amt_quarter,
                    null pipeline_amt_year,
                    null open_amt_day     ,
                    null open_amt_week    ,
                    null open_amt_period  ,
                    null open_amt_quarter ,
                    null open_amt_year    ,
                    null pipeline_amt_day_s ,
                    null pipeline_amt_week_s,
                    null pipeline_amt_period_s ,
                    null pipeline_amt_quarter_s,
                    null pipeline_amt_year_s,
                    null open_amt_day_s   ,
                    null open_amt_week_s  ,
                    null open_amt_period_s,
                    null open_amt_quarter_s,
                    null open_amt_year_s,
				decode(f.snap_date, l_sd_lwk_end, pipeline_amt_week, null) prvprd_pipe_amt_wk  ,
                decode(f.snap_date, l_sd_lper_end, pipeline_amt_period, null) prvprd_pipe_amt_PRD ,
                decode(f.snap_date, l_sd_lqtr_end, pipeline_amt_quarter, null) prvprd_pipe_amt_qtr ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year, null) prvprd_pipe_amt_yr  ,
                decode(f.snap_date, l_sd_lwk_end, open_amt_week, null) prvprd_open_amt_wk  ,
                decode(f.snap_date, l_sd_lper_end, open_amt_period, null) prvprd_open_amt_PRD ,
                decode(f.snap_date, l_sd_lqtr_end, open_amt_quarter, null) prvprd_open_amt_qtr ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvprd_open_amt_yr  ,
                decode(f.snap_date, l_sd_lwk_end, pipeline_amt_week_s, null) prvprd_pipe_amt_wk_s  ,
                decode(f.snap_date, l_sd_lper_end, pipeline_amt_period_s, null) prvprd_pipe_amt_PRD_s ,
                decode(f.snap_date, l_sd_lqtr_end, pipeline_amt_quarter_s, null) prvprd_pipe_amt_qtr_s ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year_s, null) prvprd_pipe_amt_yr_s  ,
                decode(f.snap_date, l_sd_lwk_end, open_amt_week_s, null) prvprd_open_amt_wk_s  ,
                decode(f.snap_date, l_sd_lper_end, open_amt_period_s, null) prvprd_open_amt_PRD_s ,
                decode(f.snap_date, l_sd_lqtr_end, open_amt_quarter_s, null) prvprd_open_amt_qtr_s ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year_s, null) prvprd_open_amt_yr_s,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_week, null) prvyr_pipe_amt_wk   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_period, null) prvyr_pipe_amt_PRD  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_quarter, null) prvyr_pipe_amt_qtr  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year, null) prvyr_pipe_amt_yr   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_week, null) prvyr_open_amt_wk   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_period, null) prvyr_open_amt_PRD  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_quarter, null) prvyr_open_amt_qtr  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvyr_open_amt_yr   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_week_s, null) prvyr_pipe_amt_wk_s   ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_period_s, null) prvyr_pipe_amt_PRD_s  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_quarter_s, null) prvyr_pipe_amt_qtr_s  ,
                decode(f.snap_date, l_sd_lyr_end, pipeline_amt_year_s, null) prvyr_pipe_amt_yr_s   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_week_s, null) prvyr_open_amt_wk_s   ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_period, null) prvyr_open_amt_PRD_s  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_quarter, null) prvyr_open_amt_qtr_s  ,
                decode(f.snap_date, l_sd_lyr_end, open_amt_year, null) prvyr_open_amt_yr_s
                    FROM BIL_BI_PIPELINE_F f
                    where snap_date in (l_sd_lwk_end, l_sd_lper_end
                    ,l_sd_lqtr_end, l_sd_lyr_end)
					UNION ALL
                      SELECT  sales_group_id,
			        salesrep_id,
			        p_date snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id,
                    null pipeline_amt_day ,
                    null pipeline_amt_week,
                    null pipeline_amt_period,
                    null pipeline_amt_quarter,
                    null pipeline_amt_year,
                    null open_amt_day     ,
                    null open_amt_week    ,
                    null open_amt_period  ,
                    null open_amt_quarter ,
                    null open_amt_year    ,
                    null pipeline_amt_day_s ,
                    null pipeline_amt_week_s,
                    null pipeline_amt_period_s ,
                    null pipeline_amt_quarter_s,
                    null pipeline_amt_year_s,
                    null open_amt_day_s   ,
                    null open_amt_week_s  ,
                    null open_amt_period_s,
                    null open_amt_quarter_s,
                    null open_amt_year_s  ,
                pipeline_amt_week prvprd_pipe_amt_wk  ,
                null prvprd_pipe_amt_PRD ,
                null prvprd_pipe_amt_qtr ,
                null prvprd_pipe_amt_yr  ,
                open_amt_week prvprd_open_amt_wk  ,
                null prvprd_open_amt_PRD ,
                null prvprd_open_amt_qtr ,
                null prvprd_open_amt_yr  ,
                pipeline_amt_week_s prvprd_pipe_amt_wk_s  ,
                null prvprd_pipe_amt_PRD_s ,
                null prvprd_pipe_amt_qtr_s ,
                null prvprd_pipe_amt_yr_s  ,
                open_amt_week_s prvprd_open_amt_wk_s  ,
                null prvprd_open_amt_PRD_s ,
                null prvprd_open_amt_qtr_s ,
                null prvprd_open_amt_yr_s,
                null prvyr_pipe_amt_wk   ,
                null prvyr_pipe_amt_PRD  ,
                null prvyr_pipe_amt_qtr  ,
                null prvyr_pipe_amt_yr   ,
                null prvyr_open_amt_wk   ,
                null prvyr_open_amt_PRD  ,
                null prvyr_open_amt_qtr  ,
                null prvyr_open_amt_yr   ,
                null prvyr_pipe_amt_wk_s   ,
                null prvyr_pipe_amt_PRD_s  ,
                null prvyr_pipe_amt_qtr_s  ,
                null prvyr_pipe_amt_yr_s   ,
                null prvyr_open_amt_wk_s   ,
                null prvyr_open_amt_PRD_s  ,
                null prvyr_open_amt_qtr_s  ,
                null prvyr_open_amt_yr_s
                    FROM BIL_BI_PIPEC_F f
                    where snap_date = l_sd_lwk
                     )
                    GROUP BY
                       sales_group_id,
			        salesrep_id,
			        snap_date,
			        item_id,
			        item_organization_id,
			        win_probability,
			        product_category_id


                    ;

               commit;

	  IF bil_bi_util_collection_pkg.chkLogLevel(fnd_log.LEVEL_PROCEDURE) THEN
  bil_bi_util_collection_pkg.writeLog(
             p_log_level => fnd_log.LEVEL_PROCEDURE,
             p_module => g_pkg || l_proc || ' end',
             p_msg => 'End of Procedure '|| l_proc);
 END IF;

 EXCEPTION

WHEN OTHERS THEN
    fnd_message.set_name('FND','SQL_PLSQL_ERROR'); -- Seeded Message
    fnd_message.set_token('ERRNO' ,SQLCODE);
    fnd_message.set_token('REASON' ,SQLERRM);
  fnd_message.set_token('ROUTINE' , l_proc);
    bil_bi_util_collection_pkg.writeLog(p_log_level => fnd_log.LEVEL_UNEXPECTED,
  p_module => g_pkg || l_proc || ' proc_error',
  p_msg => fnd_message.get,
  p_force_log => TRUE);

    raise;


END Ins_Into_CurrSum_SmGap;


END BIL_BI_PIPELINE_F_PKG;

/
