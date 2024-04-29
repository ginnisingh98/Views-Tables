--------------------------------------------------------
--  DDL for Package Body HXC_ARCHIVE_RESTORE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ARCHIVE_RESTORE_UTILS" AS
/* $Header: hxcarcresutl.pkb 120.6 2005/11/22 16:18:11 jdupont noship $ */
----------------------------------------------------------------------------
-- Function Name : check_max_errors
-- Description : This function is called during Validate Data Set process to
--               check if the error count has exceeded the maximum specified
--               value
-- Returns true if maximum errors exceeded; else false
----------------------------------------------------------------------------
FUNCTION check_max_errors(p_error_count IN NUMBER)
RETURN BOOLEAN
IS
BEGIN

  IF g_error_count is null THEN
    g_error_count := nvl(fnd_profile.value('HXC_VALIDATE_DATA_SET_MAX_ERRORS'),25);
  END IF;

  IF p_error_count >= g_error_count THEN
  --fnd_file.put_line(fnd_file.LOG,'Error count exceeded '||g_error_count);
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END check_max_errors;


----------------------------------------------------------------------------
-- Function Name : check_data_corruption
-- Description : This function checks for any data corruptions.
--               It is before called at the start of Archive process.
-- Returns true in case of data corruption; else false
----------------------------------------------------------------------------
FUNCTION check_data_corruption(p_data_set_id IN NUMBER)
RETURN BOOLEAN
IS

CURSOR c_timecard_template(p_data_set_id NUMBER) IS
SELECT DISTINCT temp.time_building_block_id
FROM hxc_time_building_blocks temp, hxc_data_sets d
WHERE temp.scope = 'TIMECARD_TEMPLATE'
AND EXISTS (SELECT 1 FROM hxc_time_building_blocks tc
	    WHERE tc.scope = 'TIMECARD'
	      AND tc.time_building_block_id = temp.time_building_block_id
	      )
AND temp.stop_time BETWEEN d.start_date AND d.end_date
AND d.data_set_id = p_data_set_id;

l_data_corruption BOOLEAN;
l_dummy 	  NUMBER;

begin

  l_data_corruption := FALSE;

  --1. check if any timecard and template share the same time building block id
  OPEN c_timecard_template(p_data_set_id);
  FETCH c_timecard_template INTO l_dummy;
  IF c_timecard_template%found
  THEN

  fnd_file.put_line(fnd_file.LOG, 'The following timecards and templates share the same time building block id');
    l_data_corruption := TRUE;
    CLOSE c_timecard_template;

    FOR l_rec IN c_timecard_template(p_data_set_id) LOOP
    fnd_file.put_line(fnd_file.LOG,'Common id is:' ||l_rec.time_building_block_id);
    END LOOP;

  ELSE
    CLOSE c_timecard_template;
  END IF;

fnd_file.put_line(fnd_file.LOG, 'Before returning for check_data_corruption function');

  RETURN l_data_corruption;

END check_data_corruption;


----------------------------------------------------------------------------
-- Procedure Name : core_table_count_snapshott
-- Description : This procedure will give a snapshot of the core tables
----------------------------------------------------------------------------
PROCEDURE core_table_count_snapshot
				(p_tbb_count	OUT NOCOPY NUMBER,
				 p_tau_count	OUT NOCOPY NUMBER,
				 p_ta_count	OUT NOCOPY NUMBER,
				 p_td_count	OUT NOCOPY NUMBER,
				 p_trans_count	OUT NOCOPY NUMBER,
				 p_tal_count	OUT NOCOPY NUMBER,
				 p_aps_count	OUT NOCOPY NUMBER,
				 p_adl_count	OUT NOCOPY NUMBER,
				 p_ld_count	OUT NOCOPY NUMBER,
				 p_ts_count	OUT NOCOPY NUMBER)

IS

BEGIN

  -- Building Blocks table
  select /*+ index_ffs (t HXC_TIME_BUILDING_BLOCKS_PK ) parallel (t,4)*/ count(time_building_block_id)
  into p_tbb_count from hxc_time_building_blocks t;

  -- Attributes Usages
  select/*+ index_ffs (t HXC_TIME_ATTRIBUTE_USAGES_PK ) parallel (t,4)*/ count(time_attribute_usage_id)
  into p_tau_count from hxc_time_attribute_usages t;

  -- Attributes
  select /*+ index_ffs (t HXC_TIME_ATTRIBUTES_PK ) parallel (t,4)*/ count(time_attribute_id)
  into p_ta_count from hxc_time_attributes t;

  -- Transaction Details
  select /*+ index_ffs (t HXC_TRANSACTION_DETAILS_PK ) parallel (t,4)*/ count(transaction_detail_id)
  into p_td_count from hxc_transaction_details t;

  -- Transactions
  select /*+ index_ffs (t HXC_TRANSACTIONS_PK ) parallel (t,4)*/ count(transaction_id)
  into p_trans_count from hxc_transactions t;

  -- Timecard Approver Links
  select /*+ index_ffs (t HXC_TC_AP_LINKS_PK ) parallel (t,4)*/ count(timecard_id)
  into p_tal_count from hxc_tc_ap_links t;

  -- Application Period Summary
  select /*+ index_ffs (t HXC_APP_PERIOD_SUMMARY_PK ) parallel (t,4)*/ count(application_period_id)
  into p_aps_count from hxc_app_period_summary t;

  -- Approval Detail Links
  select /*+ index_ffs (t HXC_AP_DETAIL_LINKS_PK ) parallel (t,4)*/ count(application_period_id)
  into p_adl_count from hxc_ap_detail_links t;

  -- Latest Details
  select /*+ index_ffs (t HXC_LATEST_DETAILS_FK ) parallel (t,4)*/ count(time_building_block_id)
  into p_ld_count from hxc_latest_details t;

  -- Timecard Summary
  select /*+ index_ffs (t HXC_TIMECARD_SUMMARY_PK ) parallel (t,4)*/ count(timecard_id)
  into p_ts_count from hxc_timecard_summary t;

  -- Create the report
fnd_file.put_line(fnd_file.LOG,'--------------------------------------');
fnd_file.put_line(fnd_file.LOG,' Core Table Count Snapshot');
fnd_file.put_line(fnd_file.LOG,'--------------------------------------');
fnd_file.put_line(fnd_file.LOG,'-> hxc_time_building_blocks '||p_tbb_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_time_attribute_usages '||p_tau_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_time_attributes '||p_ta_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_tansaction_details '||p_td_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_transactions '||p_trans_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_tc_ap_links '||p_tal_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_app_period_summary '||p_aps_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_ap_detail_links '||p_adl_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_latest_details '||p_ld_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_timecard_summary '||p_ts_count);


END core_table_count_snapshot;

----------------------------------------------------------------------------
-- Procedure Name : bkup_table_count_snapshot
-- Description : This procedure will give a snapshot of the bkup tables
----------------------------------------------------------------------------
PROCEDURE bkup_table_count_snapshot
				(p_tbb_ar_count	OUT NOCOPY NUMBER,
				 p_tau_ar_count	OUT NOCOPY NUMBER,
				 p_ta_ar_count	OUT NOCOPY NUMBER,
				 p_td_ar_count	OUT NOCOPY NUMBER,
				 p_trans_ar_count	OUT NOCOPY NUMBER,
				 p_tal_ar_count	OUT NOCOPY NUMBER,
				 p_adl_ar_count	OUT NOCOPY NUMBER,
				 p_aps_ar_count	OUT NOCOPY NUMBER)

IS

BEGIN

  -- Building Blocks table
  select /*+ index_ffs (t HXC_TIME_BUILDING_BLOCKS_AR_PK ) parallel (t,4)*/ count(time_building_block_id)
  into p_tbb_ar_count from hxc_time_building_blocks_ar t;

  -- Attributes Usages
  select/*+ index_ffs (t HXC_TIME_ATTR_USAGES_AR_PK ) parallel (t,4)*/ count(time_attribute_usage_id)
  into p_tau_ar_count from hxc_time_attribute_usages_ar t;

  -- Attributes
  select /*+ index_ffs (t HXC_TIME_ATTRIBUTES_AR_PK ) parallel (t,4)*/ count(time_attribute_id)
  into p_ta_ar_count from hxc_time_attributes_ar t;

  -- Transaction Details
  select /*+ index_ffs (t HXC_TRANS_DETAILS_AR_PK ) parallel (t,4)*/ count(transaction_detail_id)
  into p_td_ar_count from hxc_transaction_details_ar t;

  -- Transactions
  select /*+ index_ffs (t HXC_TRANSACTIONS_AR_PK ) parallel (t,4)*/ count(transaction_id)
  into p_trans_ar_count from hxc_transactions_ar t;

  -- Timecard Approver Links
  select /*+ index_ffs (t HXC_TC_AP_LINKS_AR_PK ) parallel (t,4)*/ count(timecard_id)
  into p_tal_ar_count from hxc_tc_ap_links_ar t;

  -- Application Period Detail links
  select /*+ index_ffs (t HXC_AP_DETAIL_LINKS_AR_PK ) parallel (t,4)*/ count(application_period_id)
  into p_adl_ar_count from hxc_ap_detail_links_ar t;

  -- Application Period Summary
  select /*+ index_ffs (t HXC_APP_PERIOD_SUMMARY_AR_PK ) parallel (t,4)*/ count(application_period_id)
  into p_aps_ar_count from hxc_app_period_summary_ar t;


  -- Create the report
fnd_file.put_line(fnd_file.LOG,'--------------------------------------');
fnd_file.put_line(fnd_file.LOG,' Archive Table Count Snapshot');
fnd_file.put_line(fnd_file.LOG,'--------------------------------------');
fnd_file.put_line(fnd_file.LOG,'-> hxc_time_building_blocks_ar '||p_tbb_ar_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_time_attribute_usages_ar '||p_tau_ar_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_time_attributes_ar '||p_ta_ar_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_tansaction_details_ar '||p_td_ar_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_transactions_ar '||p_trans_ar_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_tc_ap_links_ar '||p_tal_ar_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_ap_detail_links_ar '||p_adl_ar_count);
fnd_file.put_line(fnd_file.LOG,'-> hxc_app_period_summary_ar '||p_aps_ar_count);


END bkup_table_count_snapshot;


----------------------------------------------------------------------------
-- Procedure Name : count_chunk_check
-- Description : This procedure will give a snapshot of the bkup tables
----------------------------------------------------------------------------
PROCEDURE count_chunk_check
                          (p_tc_ar_count		IN NUMBER,
			   p_day_ar_count		IN NUMBER,
			   p_detail_ar_count		IN NUMBER,
			   p_app_period_ar_count	IN NUMBER,
			   p_tau_ar_count		IN NUMBER,
			   p_td_ar_count		IN NUMBER,
			   p_trans_ar_count		IN NUMBER,
			   p_tal_ar_count		IN NUMBER,
			   p_adl_ar_count		IN NUMBER,
			   p_app_period_sum_ar_count	IN NUMBER,
			   p_tbb_count			IN NUMBER,
			   p_app_period_count		IN NUMBER,
			   p_tau_count			IN NUMBER,
			   p_td_count			IN NUMBER,
			   p_trans_count		IN NUMBER,
			   p_tal_count			IN NUMBER,
			   p_adl_count			IN NUMBER,
			   p_app_period_sum_count	IN NUMBER)
			   IS



BEGIN

fnd_file.put_line(fnd_file.LOG,' ================================= ');
fnd_file.put_line(fnd_file.LOG,' ====== Chunk count ============== ');
fnd_file.put_line(fnd_file.LOG,' ================================= ');
fnd_file.put_line(fnd_file.LOG,' --- > p_tc_ar_count :'||p_tc_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_day_ar_count :'||p_day_ar_count );
fnd_file.put_line(fnd_file.LOG,' --- > p_detail_ar_count :'||p_detail_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_app_period_ar_count :'||p_app_period_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_tau_ar_count :'||p_tau_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_td_ar_count :'||p_td_ar_count);
--fnd_file.put_line(fnd_file.LOG,' --- > p_trans_ar_count :'||p_trans_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_tal_ar_count :'||p_tal_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_adl_ar_count :'||p_adl_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_app_period_sum_ar_count :'||p_app_period_sum_ar_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_tbb_count :'||p_tbb_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_app_period_count :'||p_app_period_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_tau_count :'||p_tau_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_td_count :'||p_td_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_trans_count :'||p_trans_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_tal_count :'||p_tal_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_adl_count :'||p_adl_count);
fnd_file.put_line(fnd_file.LOG,' --- > p_app_period_sum_count :'||p_app_period_sum_count);


  IF (p_tc_ar_count + p_day_ar_count + p_detail_ar_count) <> p_tbb_count THEN
fnd_file.put_line(fnd_file.LOG,'==> THE TIMECARD, DAY , DETAIL COUNT FAILED ');
    RAISE hxc_archive_restore_process.e_chunk_count;
  END IF;

  IF p_app_period_ar_count <> p_app_period_count THEN
fnd_file.put_line(fnd_file.LOG,'==> THE APPLICATION PERIOD COUNT FAILED');
    RAISE hxc_archive_restore_process.e_chunk_count;
  END IF;

  IF p_tau_ar_count <> p_tau_count THEN
fnd_file.put_line(fnd_file.LOG,'==> THE TIME ATTRIBUTE USAGES COUNT FAILED');
    RAISE hxc_archive_restore_process.e_chunk_count;
  END IF;

  IF p_td_ar_count <> p_td_count THEN
fnd_file.put_line(fnd_file.LOG,'==> THE TRANSACTION DETAILS COUNT FAILED');
    RAISE hxc_archive_restore_process.e_chunk_count;
  END IF;

--  IF p_trans_ar_count <> p_trans_count THEN
--fnd_file.put_line(fnd_file.LOG,' The Transaction count failed ');
--    RAISE hxc_archive_restore_process.e_chunk_count;
--  END IF;

  IF p_tal_ar_count <> p_tal_count THEN
fnd_file.put_line(fnd_file.LOG,'==> THE TIMECARD APPLICATION PERIODS COUNT FAILED');
    RAISE hxc_archive_restore_process.e_chunk_count;
  END IF;

  IF p_adl_ar_count <> p_adl_count THEN
fnd_file.put_line(fnd_file.LOG,'==> THE APPLICATION PERIODS - DETAILS BB COUNT FAILED');
    RAISE hxc_archive_restore_process.e_chunk_count;
  END IF;

  IF p_app_period_sum_ar_count <> p_app_period_sum_count THEN
fnd_file.put_line(fnd_file.LOG,'==> THE APPLICATION PERIOD SUMMARY COUNT FAILED');
    RAISE hxc_archive_restore_process.e_chunk_count;
  END IF;

END count_chunk_check;


----------------------------------------------------------------------------
-- Procedure Name : count_snapshot_check
-- Description : This procedure will give a snapshot of the bkup tables
----------------------------------------------------------------------------

PROCEDURE count_snapshot_check	(p_tbb_count_1		IN  NUMBER,
				 p_tau_count_1		IN NUMBER,
				 p_ta_count_1		IN NUMBER,
				 p_td_count_1		IN NUMBER,
				 p_trans_count_1	IN NUMBER,
				 p_tal_count_1		IN NUMBER,
				 p_aps_count_1		IN NUMBER,
				 p_adl_count_1		IN NUMBER,
				 p_ld_count_1		IN NUMBER,
				 p_ts_count_1		IN NUMBER,
				 p_tbb_ar_count_1	IN NUMBER,
				 p_tau_ar_count_1	IN NUMBER,
				 p_ta_ar_count_1	IN NUMBER,
				 p_td_ar_count_1	IN NUMBER,
				 p_trans_ar_count_1	IN NUMBER,
				 p_tal_ar_count_1	IN NUMBER,
				 p_adl_ar_count_1	IN NUMBER,
				 p_aps_ar_count_1	IN NUMBER,
				 p_tbb_count_2		IN NUMBER,
				 p_tau_count_2		IN NUMBER,
				 p_ta_count_2		IN NUMBER,
				 p_td_count_2		IN NUMBER,
				 p_trans_count_2	IN NUMBER,
				 p_tal_count_2		IN NUMBER,
				 p_aps_count_2		IN NUMBER,
				 p_adl_count_2		IN NUMBER,
				 p_ld_count_2		IN NUMBER,
				 p_ts_count_2		IN NUMBER,
				 p_tbb_ar_count_2	IN NUMBER,
				 p_tau_ar_count_2	IN NUMBER,
				 p_ta_ar_count_2	IN NUMBER,
				 p_td_ar_count_2	IN NUMBER,
				 p_trans_ar_count_2	IN NUMBER,
				 p_tal_ar_count_2	IN NUMBER,
				 p_adl_ar_count_2	IN NUMBER,
				 p_aps_ar_count_2	IN NUMBER,
				 retcode		OUT NOCOPY NUMBER)
IS

l_dummy			VARCHAR2(1);
l_att_diff_check	NUMBER;

BEGIN

fnd_file.put_line(fnd_file.LOG,'----------------------------------------');
fnd_file.put_line(fnd_file.LOG,'------ COUNT CHECK ON SNAPSHOT  --------');
fnd_file.put_line(fnd_file.LOG,'----------------------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Building Blocks Table Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_tbb_count_1  '||p_tbb_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_tbb_count_2 '|| p_tbb_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_tbb_ar_count_1 '||p_tbb_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_tbb_ar_count_2 '||p_tbb_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_tbb_count_1 - p_tbb_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_tbb_ar_count_2 - p_tbb_ar_count_1));

  -- we can check that all the time building block have been transfered
  IF (p_tbb_count_1 - p_tbb_count_2) <> (p_tbb_ar_count_2 - p_tbb_ar_count_1)
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'=== > COPY FAILED ON THE TIME BUILDING BLOCK');
    retcode := 2;
    --RETURN;
  END IF;

fnd_file.put_line(fnd_file.LOG,'-----------------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Attribute Usages Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_tau_count_1 '||p_tau_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_tau_count_2 '||p_tau_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_tau_ar_count_1  '||p_tau_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_tau_ar_count_2  '||p_tau_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_tau_count_1 - p_tau_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_tau_ar_count_2 - p_tau_ar_count_1));

  -- we can check that all the attributes usages have been transfered
  IF (p_tau_count_1 - p_tau_count_2) <> (p_tau_ar_count_2 - p_tau_ar_count_1)
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'=== > COPY FAILED ON THE ATTRIBUTE USAGES BLOCK');
    retcode := 2;
    --RETURN;
  END IF;

fnd_file.put_line(fnd_file.LOG,'-----------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Attribute  Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_ta_count_1 '||p_ta_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_ta_count_2 '||p_ta_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_ta_ar_count_1  '||p_ta_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_ta_ar_count_2  '||p_ta_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_ta_count_1 - p_ta_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_ta_ar_count_2 - p_ta_ar_count_1));

  -- for the attributes we need to check more if the attributes count is different
  -- since we can copy consolidated attributes without deleting them from the core
  -- table
  IF (p_ta_count_1 - p_ta_count_2) <> (p_ta_ar_count_2 - p_ta_ar_count_1)
  THEN
    -- warning
    fnd_file.put_line(fnd_file.LOG,'=== > SOME ATTRIBUTES WERE SHARED ');
    retcode := 1;

    SELECT /*+ index_ffs (t HXC_TIME_ATTRIBUTES_PK ) parallel (4)*/ count(ta.time_attribute_id)
    INTO l_att_diff_check
    FROM hxc_time_attributes ta, hxc_time_attributes_ar tabkup
    WHERE ta.time_attribute_id = tabkup.time_attribute_id
    AND EXISTS
    (SELECT 1 FROM hxc_time_attribute_usages tau
     WHERE tau.time_attribute_id = ta.time_attribute_id);

    --l_att_diff_check := sql%rowcount;

fnd_file.put_line(fnd_file.LOG,'--- > Difference core - backup '||((p_ta_count_1 - p_ta_count_2) - (p_ta_ar_count_2 - p_ta_ar_count_1)));
fnd_file.put_line(fnd_file.LOG,'--- > l_att_diff_check '||l_att_diff_check);

    IF (abs((p_ta_ar_count_2 - p_ta_ar_count_1)-(p_ta_count_1 - p_ta_count_2)) <> abs(l_att_diff_check))
    THEN
      fnd_file.put_line(fnd_file.LOG,'===> > IF THE PROCESS IS ARCHIVE THEN BAD TRANSFER OF ATTRIBUTES');

    -- we need to add another check to see if the difference is legitimate.
    /****************** SET TO 2 *****************************/
      retcode := 1;
    END IF;


  END IF;


fnd_file.put_line(fnd_file.LOG,'---------------------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Transaction Details  Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_td_count_1 '||p_td_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_td_count_2 '||p_td_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_td_ar_count_1  '||p_td_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_td_ar_count_2  '||p_td_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_td_count_1 - p_td_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_td_ar_count_2 - p_td_ar_count_1));

  -- we can check that all the transaction details have been transfered
  IF (p_td_count_1 - p_td_count_2) <> (p_td_ar_count_2 - p_td_ar_count_1)
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'=== > COPY FAILED ON THE TRANSACTION DETAILS');
    retcode := 2;
    --RETURN;
  END IF;

fnd_file.put_line(fnd_file.LOG,'------------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Transaction Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_trans_count_1 '||p_trans_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_trans_count_2 '||p_trans_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_trans_ar_count_1  '||p_trans_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_trans_ar_count_2  '||p_trans_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_trans_count_1 - p_trans_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_trans_ar_count_2 - p_trans_ar_count_1));

  -- we can check that all the transactions have been transfered
  IF (p_trans_count_1 - p_trans_count_2) <> (p_trans_ar_count_2 - p_trans_ar_count_1)
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'=== > COPY TRANSACTIONS WERE SHARED');
    retcode := 1;
    --RETURN;
  END IF;

fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Timecard Application Period Links Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_tal_count_1 '||p_tal_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_tal_count_2 '||p_tal_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_tal_ar_count_1  '||p_tal_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_tal_ar_count_2  '||p_tal_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_tal_count_1 - p_tal_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_tal_ar_count_2 - p_tal_ar_count_1));

  -- we can check that all the timecard application links have been transfered
  IF (p_tal_count_1 - p_tal_count_2) <> (p_tal_ar_count_2 - p_tal_ar_count_1)
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'=== > COPY FAILED ON THE TIMECARD APPLICATION PERIOD LINKS');
    retcode := 2;
    --RETURN;
  END IF;


fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Application Period Detail BB Links Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_adl_count_1 '||p_adl_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_adl_count_2 '||p_adl_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_adl_ar_count_1  '||p_adl_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_adl_ar_count_2  '||p_adl_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_adl_count_1 - p_adl_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_adl_ar_count_2 - p_adl_ar_count_1));

  -- we can check that all the timecard application links have been transfered
  IF (p_adl_count_1 - p_adl_count_2) <> (p_adl_ar_count_2 - p_adl_ar_count_1)
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'=== > COPY FAILED ON THE APPLICATION PERIOD DETAIL BB LINKS');
    retcode := 2;
    --RETURN;
  END IF;


fnd_file.put_line(fnd_file.LOG,'---------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'---   Application Period Summary Count ------');
fnd_file.put_line(fnd_file.LOG,'--- > p_aps_count_1 '||p_aps_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_aps_count_2 '||p_aps_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > p_aps_ar_count_1  '||p_aps_ar_count_1);
fnd_file.put_line(fnd_file.LOG,'--- > p_aps_ar_count_2  '||p_aps_ar_count_2);
fnd_file.put_line(fnd_file.LOG,'--- > Difference core '||(p_aps_count_1 - p_aps_count_2));
fnd_file.put_line(fnd_file.LOG,'--- > Difference backup '||(p_aps_ar_count_2 - p_aps_ar_count_1));

  -- we can check that all the application period summary have been transfered
  IF (p_aps_count_1 - p_aps_count_2) <> (p_aps_ar_count_2 - p_aps_ar_count_1)
  THEN
    --error
    fnd_file.put_line(fnd_file.LOG,'=== > COPY FAILED ON THE APPLICATION PERIOD SUMMARY');
    retcode := 2;
    --RETURN;
  END IF;


END count_snapshot_check;

----------------------------------------------------------------------------
-- Procedure Name : incompatibility_pg_running
-- Description :
----------------------------------------------------------------------------

FUNCTION incompatibility_pg_running
RETURN BOOLEAN
IS

l_running_id NUMBER;

BEGIN

  BEGIN

    SELECT  cr.request_id into l_running_id
    FROM
         fnd_concurrent_programs cp,
         fnd_concurrent_requests cr
    WHERE cp.concurrent_program_name in ('HXCCATTRB','HXCRESDS','HXCUNDEFDS','HXCDEFDS','HXCARCHDS')
    AND cp.application_id = 809
    AND
      cr.concurrent_program_id = cp.concurrent_program_id AND
      cr.request_id <> fnd_global.conc_request_id and
      cr.status_code = 'R';

  EXCEPTION
    WHEN NO_DATA_FOUND then
     RETURN FALSE;
  END;

RETURN TRUE;

END incompatibility_pg_running;

--updating the wf_notification_attributes with Archival=Yes URL param
--while cancelling the notification via archival.
--Gets called from hxc_find_notify_aprs_pkg.cancel_notifications procedure.

PROCEDURE upd_wf_notif_attributes(p_item_type in varchar2,
                                  p_item_key  in varchar2) is

l_notification_id NUMBER;
l_timecard_url wf_notification_attributes.TEXT_VALUE%TYPE;
l_temp_timecard_url wf_notification_attributes.TEXT_VALUE%TYPE;
l_pos NUMBER;


CURSOR c_notif_id(p_item_key in varchar2,p_item_type in varchar2 ) is
SELECT DISTINCT notification_id
FROM WF_ITEM_ACTIVITY_STATUSES
WHERE ITEM_KEY = p_item_key
AND  ITEM_TYPE = p_item_type;

CURSOR c_timecard_url_value(p_notification_id in varchar2) is
SELECT text_value
FROM wf_notification_attributes
WHERE notification_id = p_notification_id
and name = 'TIMECARD';

BEGIN

OPEN c_notif_id(p_item_key,p_item_type);
FETCH c_notif_id into l_notification_id; --Picking up the Notification Id.
CLOSE c_notif_id;

IF(l_notification_id is not null) THEN
  open c_timecard_url_value(l_notification_id);
  fetch c_timecard_url_value into l_timecard_url;
  close c_timecard_url_value;

  IF(l_timecard_url is not null) THEN
    --Setting the New Parameter.
    -- Just a hack here, because adding the Archived parameter at the last
    -- doesn't seem to work.
    -- So spiliting the timecard url and add the Archived parameter just before the
    -- StartTime param.
    l_pos := Instr(l_timecard_url,'&StartTime',1);

    IF(l_pos > 0) THEN --Only if the param exists(A safe check,though it should always exist)
       l_temp_timecard_url := substr(l_timecard_url,0,(l_pos-1));
       l_timecard_url :=
               l_temp_timecard_url||'&Archived=Yes'||substr(l_timecard_url,(l_pos-1));

       --Updating the Workflow Notification Attributes.
       update wf_notification_attributes set
       text_value = l_timecard_url
       where notification_id = l_notification_id
        and name = 'TIMECARD';

       --Updating the Workflow Item Attributes.
        wf_engine.SetItemAttrText(
                   itemtype => p_item_type,
                   itemkey  => p_item_key,
                   aname    => 'TIMECARD',
                   avalue   => l_timecard_url);
     END IF;

  END IF;
END IF;

EXCEPTION
   WHEN OTHERS THEN
        NULL;

END upd_wf_notif_attributes;


END hxc_archive_restore_utils;

/
