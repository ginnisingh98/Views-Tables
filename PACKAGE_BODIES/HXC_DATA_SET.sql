--------------------------------------------------------
--  DDL for Package Body HXC_DATA_SET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_DATA_SET" AS
  /* $Header: hxcdataset.pkb 120.4.12010000.4 2008/09/26 10:54:27 asrajago ship $ */

----------------------------------------------------------------------------
-- Function Name : validate_data_set_range
-- Description : This is called during Define Data Set to check if
--               1)any data set exists with the same name
--               2)if the data set range overlaps with some other
--                 data set range
-- Returns true if everything is fine with the name and range;
-- else returns false
----------------------------------------------------------------------------
FUNCTION validate_data_set_range
		(p_data_set_name 	IN VARCHAR2,
		 p_start_date 		IN DATE,
		 p_stop_date 		IN DATE)
RETURN BOOLEAN
IS

CURSOR c_check_range_exists(p_start_date date, p_end_date date)
IS
SELECT 1
FROM hxc_data_sets
WHERE start_date < p_end_date
AND end_date > p_start_date;

CURSOR c_check_name_exists(p_data_set_name varchar2)
IS
SELECT 1
FROM hxc_data_sets
WHERE data_set_name = p_data_set_name;


l_dummy pls_integer;

BEGIN

  -- check the date first
  IF  p_start_date >= p_stop_date THEN
fnd_file.put_line(fnd_file.LOG,'--- >The Start Date of the Data Set cannot be greater than the End Date ');
   RETURN FALSE;
  END IF;



  --check for date range
  OPEN c_check_range_exists(p_start_date,p_stop_date);
  FETCH c_check_range_exists INTO l_dummy;
  IF c_check_range_exists%found THEN

    CLOSE c_check_range_exists;
fnd_file.put_line(fnd_file.LOG,'--- >There is an existing Data Set whose range overlaps with the '
		                              ||'period specified');
    RETURN FALSE;

  END IF;
  CLOSE c_check_range_exists;

  fnd_file.put_line(fnd_file.LOG,'--- >After checking the valid Data Set range');

  OPEN c_check_name_exists(p_data_set_name);
  FETCH c_check_name_exists INTO l_dummy;
  IF c_check_name_exists%found THEN

    close c_check_name_exists;
fnd_file.put_line(fnd_file.LOG,'--- >Data Set name is already used');
    RETURN FALSE;

  END IF;
  CLOSE c_check_name_exists;

  fnd_file.put_line(fnd_file.LOG,'--- >After checking the unique name');

  RETURN TRUE;
END validate_data_set_range;


--------------------------------------------------------------------------------------------------
-- Procedure Name : show_data_set
-- Description    : This procedure show in the log file the data set already definied.
--------------------------------------------------------------------------------------------------

PROCEDURE show_data_set is

cursor c_data_sets is
select DATA_SET_ID,DATA_SET_NAME,DESCRIPTION,START_DATE,END_DATE,DATA_SET_MODE,
decode(STATUS,'BACKUP_IN_PROGRESS','ARCHIVE_IN_PROGRESS',STATUS) status,
CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,VALIDATION_STATUS
from hxc_data_sets
where status <> 'MARKING_IN_PROGRESS';


BEGIN

fnd_file.put_line(fnd_file.LOG,'------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'----------- EXISTING DATA SETS       -----------');
fnd_file.put_line(fnd_file.LOG,'------------------------------------------------');

  FOR crs_data_sets in c_data_sets LOOP

fnd_file.put_line(fnd_file.LOG,' --> Data Set Id: '||crs_data_sets.data_set_id);
fnd_file.put_line(fnd_file.LOG,' --> Data Set Name: '||crs_data_sets.data_set_name);
fnd_file.put_line(fnd_file.LOG,' --> Description: '||crs_data_sets.description);
fnd_file.put_line(fnd_file.LOG,' --> Data Set Status: '||crs_data_sets.status);
fnd_file.put_line(fnd_file.LOG,' --> Date From: '||crs_data_sets.start_date);
fnd_file.put_line(fnd_file.LOG,' --> Date To: '||crs_data_sets.end_date);
fnd_file.put_line(fnd_file.LOG,' --> Validation Status: '||crs_data_sets.validation_status);
fnd_file.put_line(fnd_file.LOG,' ---------');



  END LOOP;

fnd_file.put_line(fnd_file.LOG,'------------------------------------------------');


END show_data_set;



--------------------------------------------------------------------------------------------------
--Procedure Name : insert_into_data_set
--Description    : This procedure inserts the record into hxc_data_sets table corresponding to new
--                 Data set.
--------------------------------------------------------------------------------------------------

PROCEDURE insert_into_data_set(p_data_set_id   OUT NOCOPY NUMBER,
			       p_data_set_name IN VARCHAR2,
			       p_description   IN VARCHAR2,
                               p_start_date    IN DATE,
                               p_stop_date     IN DATE,
                               p_status	       IN VARCHAR2) is

BEGIN

  --get the sequence from hxc_data_sets_s
  select hxc_data_sets_s.nextval into p_data_set_id from dual;

  insert into hxc_data_sets
	(data_set_id,
	 data_set_name,
	 description,
	 start_date,
	 end_date,
	 data_set_mode,
	 status)
  values
	(p_data_set_id,
	 p_data_set_name,
	 p_description,
	 p_start_date,
	 p_stop_date,
	 'B',
         p_status);

  commit;

END insert_into_data_set;

--------------------------------------------------------------------------------------------------
--Procedure Name : mark_tables_with_data_set
--Description    :
--------------------------------------------------------------------------------------------------
PROCEDURE mark_tables_with_data_set(p_data_set_id in number,
				    p_start_date in DATE,
                                    p_stop_date in DATE)
IS

CURSOR c_tbb_id(p_data_set_id number) is
SELECT /*+ INDEX( hxc hxc_time_building_blocks_n1) */
distinct time_building_block_id
FROM  hxc_time_building_blocks hxc
WHERE scope ='TIMECARD'
AND (data_set_id <> p_data_set_id OR data_set_id IS NULL)
AND  stop_time BETWEEN p_start_date AND p_stop_date;

l_tbb_id_tab hxc_archive_restore_utils.t_tbb_id;

l_fnd_logging	varchar2(10);
l_chunk_size	number;

BEGIN


-- Bug 7358756
-- Archive/Restore process re-architecture.
--   HXC_TEMP_TIMECARD_CHUNKS is a global temporary table now
--   No need to update any other table except HXC_TIME_BUILDING_BLOCKS ( scope : timecard )
--   since the Archive/Restore process drives it from there.
--   Removed all unwanted logging, and comments.


  hr_general.g_data_migrator_mode := 'Y';

  l_fnd_logging	:= nvl(fnd_profile.value('AFLOG_ENABLED'),'N');
  l_chunk_size	:= nvl(fnd_profile.value('HXC_ARCHIVE_RESTORE_CHUNK_SIZE'),50);

  OPEN c_tbb_id(p_data_set_id);

  LOOP
    -- we take 100 timecard ids within the given range per iteration
    -- and mark the corresponding records in the base tables
    FETCH c_tbb_id bulk collect INTO l_tbb_id_tab limit l_chunk_size;

fnd_file.put_line(fnd_file.LOG,'================================================================');
fnd_file.put_line(fnd_file.LOG,'Entering in a new chunk l_tbb_id_tab.count '||l_tbb_id_tab.count);
fnd_file.put_line(fnd_file.LOG,'================================================================');

    IF l_tbb_id_tab.count = 0 THEN
      CLOSE c_tbb_id;
      EXIT;
    END IF;


/* Removed the following since this is a GTT henceforth
    -- before starting let's DELETE all the data of the data_set_id in the
    -- temporary table

    DELETE FROM hxc_temp_timecard_chunks
    WHERE data_set_id = p_data_set_id;
*/



    FORALL x IN l_tbb_id_tab.first..l_tbb_id_tab.last

      ---------------------------------
      -- TIMECARD SCOPE BUILDING BLOCK
      ---------------------------------
      -- first get the chunk of timecard
      -- to work on in the temp chunk table
      INSERT INTO hxc_temp_timecard_chunks
      (data_set_id,id, scope)
      VALUES
      (p_data_set_id,l_tbb_id_tab(x),'TIMECARD');

fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'--- >Count of TIMECARD INSERT INTO TEMP table for this chunk: '||sql%rowcount);

      -- after just DELETE the bulk table
      l_tbb_id_tab.DELETE;

      UPDATE hxc_time_building_blocks tbb
      SET    data_set_id = p_data_set_id
      WHERE  scope ='TIMECARD'
      AND    time_building_block_id in
             (SELECT temp.id
              FROM   hxc_temp_timecard_chunks temp
              WHERE  temp.data_set_id = p_data_set_id
              AND    temp.scope = 'TIMECARD');

fnd_file.put_line(fnd_file.LOG,'--- >Count of TIMECARD UPDATE for this chunk: '||sql%rowcount);

-- Bug 7358756
-- The following lines of code commented out, we no longer need it.

/*    INSERT INTO hxc_temp_timecard_chunks (id,data_set_id,scope)
      SELECT distinct day.time_building_block_id, p_data_set_id,'DAY'
      FROM  hxc_time_building_blocks day
      WHERE day.scope = 'DAY'
      AND   day.parent_building_block_id in
      	    (SELECT temp.id
      	     FROM   hxc_temp_timecard_chunks temp
             WHERE  temp.scope = 'TIMECARD'
             AND    temp.data_set_id = p_data_set_id);
      --AND   day.data_set_id = p_data_set_id;


      UPDATE hxc_time_building_blocks tbb
      SET    data_set_id = p_data_set_id
      WHERE  scope ='DAY'
      AND    time_building_block_id in
             (SELECT temp.id
              FROM   hxc_temp_timecard_chunks temp
              WHERE  temp.data_set_id = p_data_set_id
              AND    temp.scope = 'DAY');


      INSERT INTO hxc_temp_timecard_chunks (id,data_set_id, scope)
      SELECT distinct det.time_building_block_id,p_data_set_id,'DETAIL'
      FROM   hxc_time_building_blocks det
      WHERE  det.scope = 'DETAIL'
      AND    det.parent_building_block_id IN
              (SELECT temp.id
               FROM   hxc_temp_timecard_chunks temp
               WHERE  temp.scope = 'DAY'
               AND    temp.data_set_id = p_data_set_id);
      --AND det.data_set_id = p_data_set_id;


      UPDATE hxc_time_building_blocks tbb
      SET    data_set_id = p_data_set_id
      WHERE  scope ='DETAIL'
      AND    time_building_block_id in
             (SELECT ID
              FROM   hxc_temp_timecard_chunks temp
              WHERE  temp.data_set_id = p_data_set_id
              AND    temp.scope = 'DETAIL');

      UPDATE hxc_time_attribute_usages
      SET    data_set_id = p_data_set_id
      WHERE  time_building_block_id in
        (SELECT  temp.id
         FROM    hxc_temp_timecard_chunks temp
         WHERE   temp.data_set_id = p_data_set_id
         AND     temp.scope in ('TIMECARD','DAY','DETAIL'));



	update hxc_time_attributes
	set data_set_id = l_data_set_id
	where time_attribute_id in
	   (select time_attribute_id from hxc_time_attribute_usages
	    where data_set_id = l_data_set_id)
	    and data_set_id is null
	and nvl(consolidated_flag,'N') <> 'Y';

      UPDATE hxc_transaction_details htd
      SET    htd.data_set_id = p_data_set_id
      where  htd.time_building_block_id in
        (SELECT  temp.id
         FROM    hxc_temp_timecard_chunks temp
         WHERE   temp.data_set_id = p_data_set_id
         AND     temp.scope in ('TIMECARD','DAY','DETAIL'));

      UPDATE hxc_transactions
      SET    data_set_id = p_data_set_id
      WHERE  transaction_id in
             (SELECT distinct transaction_id
	      FROM hxc_transaction_details txnd,
	       	   hxc_temp_timecard_chunks temp
	      WHERE txnd.time_building_block_id = temp.id
	      AND temp.data_set_id = p_data_set_id
	      AND temp.scope in ('TIMECARD','DAY','DETAIL'))
      AND type = 'DEPOSIT';

*/
      -- Set the Summary timecard table
      UPDATE hxc_timecard_summary hts
      SET    data_set_id = p_data_set_id
      where  timecard_id in
         (SELECT  temp.id
          FROM    hxc_temp_timecard_chunks temp
          WHERE   temp.data_set_id = p_data_set_id
          AND     temp.scope = 'TIMECARD');

fnd_file.put_line(fnd_file.LOG,'----------------------------------------------------');
fnd_file.put_line(fnd_file.LOG,'--- >Count of TIMECARD SUMMARY for this chunk: '||sql%rowcount);


      COMMIT;

  END LOOP;

  IF c_tbb_id%ISOPEN THEN
    CLOSE c_tbb_id;
  END IF;

--final commit;
COMMIT;

END mark_tables_with_data_set;

--------------------------------------------------------------------------------------------------
--Procedure Name : get_data_set_info
--Description    :
--------------------------------------------------------------------------------------------------
PROCEDURE get_data_set_info(p_data_set_id 	IN NUMBER,
			    p_data_set_name 	OUT NOCOPY VARCHAR2,
			    p_description 	OUT NOCOPY VARCHAR2,
                            p_start_date 	OUT NOCOPY DATE,
                            p_stop_date 	OUT NOCOPY DATE,
                            p_data_set_mode	OUT NOCOPY VARCHAR2,
                            p_status		OUT NOCOPY VARCHAR2,
                            p_validation_status	OUT NOCOPY VARCHAR2,
                            p_found_data_set	OUT NOCOPY BOOLEAN)
IS

CURSOR c_get_data_set_status is
SELECT data_set_name, description, start_date, end_date,
       data_set_mode, status, validation_status
FROM   hxc_data_sets
WHERE  data_set_id = p_data_set_id;

BEGIN

  p_found_data_set := FALSE;

  OPEN c_get_data_set_status;
  FETCH c_get_data_set_status INTO p_data_set_name, p_description, p_start_date, p_stop_date,
                                   p_data_set_mode, p_status, p_validation_status;
  IF c_get_data_set_status%FOUND
  THEN

    p_found_data_set := TRUE;

  END IF;
  CLOSE c_get_data_set_status;

END get_data_set_info;


----------------------------------------------------------------------------
-- Procedure Name : undo_define_table
-- Description : This procedure is called during Undo Define Data Set process.
--               For a given table and data set, it updates the data set
--               id to null in chunks of 100 records
----------------------------------------------------------------------------
PROCEDURE undo_define_table (p_table_name  VARCHAR2,
			     p_data_set_id NUMBER,
			     p_chunk_size  NUMBER)
IS

l_sql VARCHAR2(2000);

BEGIN

  l_sql := 'update '||p_table_name||
 	   ' set data_set_id = null where data_set_id = '||p_data_set_id||
	   ' and rownum <= '||p_chunk_size;

  LOOP

    EXECUTE IMMEDIATE l_sql;
    IF sql%notfound  THEN
	return;
    END IF;

    COMMIT;

  END LOOP;
/*
EXCEPTION
  WHEN OTHERS THEN

  fnd_file.put_line(fnd_file.LOG,'Error during undo data set: '||sqlerrm);
  ROLLBACK;
  p_retcode:=2;

  IF  (nvl(fnd_profile.value('AFLOG_ENABLED'),'N')='Y') THEN

    hxc_archive_restore_debug.print_table_record(p_table_name,
   					         p_data_set_id,
					         p_column1,
					         p_column2);
  END IF;
*/

END undo_define_table;


--------------------------------------------------------------------------------------------------
--Procedure Name : undo_define_data_set
--Description    :
--------------------------------------------------------------------------------------------------

PROCEDURE undo_define_data_set(p_data_set_id 	IN NUMBER)
IS

l_chunk_size 	NUMBER;
l_fnd_logging	VARCHAR2(10);

BEGIN

  hr_general.g_data_migrator_mode := 'Y';

  l_fnd_logging	:= nvl(fnd_profile.value('AFLOG_ENABLED'),'N');
  l_chunk_size	:= nvl(fnd_profile.value('HXC_ARCHIVE_RESTORE_CHUNK_SIZE'),25);

  undo_define_table(p_table_name        => 'HXC_TIME_BUILDING_BLOCKS',
                    p_data_set_id	=> p_data_set_id,
                    p_chunk_size	=> l_chunk_size);

  undo_define_table(p_table_name        => 'HXC_TIME_ATTRIBUTE_USAGES',
                    p_data_set_id	=> p_data_set_id,
                    p_chunk_size	=> l_chunk_size);

  undo_define_table(p_table_name        => 'HXC_TIME_ATTRIBUTES',
                    p_data_set_id	=> p_data_set_id,
                    p_chunk_size	=> l_chunk_size);

  undo_define_table(p_table_name        => 'HXC_TRANSACTION_DETAILS',
                    p_data_set_id	=> p_data_set_id,
                    p_chunk_size	=> l_chunk_size);

  undo_define_table(p_table_name        => 'HXC_TRANSACTIONS',
                    p_data_set_id	=> p_data_set_id,
                    p_chunk_size	=> l_chunk_size);

  undo_define_table(p_table_name        => 'HXC_TIMECARD_SUMMARY',
                    p_data_set_id	=> p_data_set_id,
                    p_chunk_size	=> l_chunk_size);

  DELETE FROM hxc_data_sets
  WHERE data_set_id = p_data_set_id;

  COMMIT;

END undo_define_data_set;


----------------------------------------------------------------------------
-- Procedure Name : validate_data_set
-- Description : This is the starting point of the concurrent program
--               'Validate Data Set'
----------------------------------------------------------------------------
PROCEDURE validate_data_set (p_data_set_id in  number,
                             p_error_count out NOCOPY number,
                             p_all_errors  in  boolean default FALSE)
IS

--Cursor to fetch all the non-errord status unreterived Timecards.


-- Bug 6744917
-- Added condition to compare det.date_to to hr_general.end_of_time.
-- The query just pulled out all timecards which has details without
-- transaction details of type RETRIEVAL.
-- For a detail which is overwritten or deleted and where the original
-- entry was never retrieved, there neednt be retrieval happening
-- ever. The condition added is as follows.
-- * If the detail record is not end dated, pull it up anyways
--   as a warning, because this has to be retrieved and cant be archived.
-- * If the detail record is end dated, check if there was a previous
--   OVN of this retrieved. In that case, you have to retrieve this
--   also to make adjustments, so pull this record to show in warnings.
--   If there is no previous OVN retrieved, and the detail is end dated
--   it means this detail is never going to be retrieved at all, and there
--   is no point in stopping it from getting archived.


CURSOR c_get_unretrieved_tcs(p_data_set_id number,l_bee_retrieval number)
IS
	SELECT /*+ NO_INDEX(day HXC_TIME_BUILDING_BLOCKS_N2) NO_INDEX(det HXC_TIME_BUILDING_BLOCKS_N2) */
	  DISTINCT
	    tsum.resource_id,
	    tsum.start_time,
	    tsum.stop_time,
	    tsum.approval_status,
	    nvl(per.employee_number,'Employee Number Unkown') employee_number,
	    nvl(per.full_name,'Full Name Unknown') full_name
	FROM
	    hxc_time_building_blocks day,
	    hxc_time_building_blocks det,
	    hxc_latest_details hld,
	    hxc_data_sets hds,
	    hxc_timecard_summary tsum,
	    hxc_application_sets_v has,
	    hxc_application_set_comps_v hasv,
            per_all_people_f per
	WHERE
	NOT EXISTS
	    (SELECT 1
	     FROM   hxc_transaction_details txnd,
	            hxc_transactions txn,
	            hxc_retrieval_processes rp
	    WHERE  txn.type = 'RETRIEVAL'
	    AND    txn.status = 'SUCCESS'
	    AND    txnd.status = 'SUCCESS'
	    AND    txnd.time_building_block_id = hld.time_building_block_id
	    AND    txnd.time_building_block_ovn = hld.object_version_number
	    AND    txnd.transaction_id = txn.transaction_id
	    AND    decode(txn.transaction_process_id,-1,l_bee_retrieval,txn.transaction_process_id) = rp.retrieval_process_id
	    AND    rp.time_recipient_id = hasv.time_recipient_id
	    )
   	    AND per.person_id = tsum.resource_id
	    AND sysdate between per.effective_start_date and per.effective_end_date
	    AND hds.data_set_id =p_data_set_id
	    AND has.application_set_id = hasv.application_set_id
	    AND has.application_set_id = hld.application_set_id
	    AND hld.time_building_block_id = det.time_building_block_id
	    AND hld.object_version_number = det.object_version_number
	    AND det.parent_building_block_id = day.time_building_block_id
	    AND det.parent_building_block_ovn = day.object_version_number
            AND (    (    det.date_to = hr_general.end_of_time
                     )
                  OR (     det.date_to <> hr_general.end_of_time
                       AND EXISTS  (SELECT 1
	    			    FROM   hxc_transaction_details txnd1,
	    			           hxc_transactions txn1,
	    			           hxc_retrieval_processes rp1
	    			   WHERE  txn1.type = 'RETRIEVAL'
	    			   AND    txn1.status = 'SUCCESS'
	    			   AND    txnd1.status = 'SUCCESS'
	    			   AND    txnd1.time_building_block_id = hld.time_building_block_id
	    			   AND    txnd1.time_building_block_ovn < hld.object_version_number
	    			   AND    txnd1.transaction_id = txn1.transaction_id
	    			   AND    decode(txn1.transaction_process_id,-1,
	    			                                            l_bee_retrieval,
	    			                                            txn1.transaction_process_id) = rp1.retrieval_process_id
	    			   AND    rp1.time_recipient_id = hasv.time_recipient_id
	    			   )
	    	      )
	    	 )
	    AND day.parent_building_block_id = tsum.timecard_id
	    AND day.parent_building_block_ovn = tsum.timecard_ovn
	    --AND det.data_set_id = hds.data_set_id
	    --AND day.data_set_id = det.data_set_id
	    --AND tsum.data_set_id = day.data_set_id
	    AND det.scope = 'DETAIL'
	    AND day.scope = 'DAY'
	    AND tsum.stop_time BETWEEN hds.start_date AND hds.end_date
	    AND tsum.approval_status<>'ERROR'
	    ORDER BY tsum.approval_status,tsum.start_time,tsum.resource_id;




--Cursor to fetch all the errored status Timecard.

CURSOR c_chk_err_tcs(p_data_set_id number)
IS
	SELECT  tsum.resource_id,
		tsum.start_time,
		tsum.stop_time,
		nvl(per.employee_number,'Employee Number Unkown') employee_number,
	        nvl(per.full_name,'Full Name Unknown') full_name
	   FROM hxc_timecard_summary tsum,
    	        hxc_data_sets d,
		per_all_people_f per
		WHERE tsum.approval_status ='ERROR'
		AND per.person_id = tsum.resource_id
		AND sysdate between per.effective_start_date and per.effective_end_date
		AND tsum.stop_time BETWEEN d.start_date AND d.end_date
		AND d.data_set_id = p_data_set_id
	ORDER BY tsum.start_time,tsum.resource_id;


--Cursor to fetch all the Timecards for which notifications are pending.

cursor c_timecard_notifications(p_data_set_id number) is
SELECT
       tsum.resource_id,
       tsum.start_time,
       tsum.stop_time,
       nvl(per.employee_number,'Employee Number Unkown') employee_number,
       nvl(per.full_name,'Full Name Unknown') full_name
  FROM hxc_timecard_summary tsum,
       hxc_app_period_summary apsum,
       hxc_tc_ap_links tap,
       wf_notifications wfn,
       wf_item_activity_statuses wias,
       wf_item_attribute_values wiav,
       per_all_people_f per
 WHERE tsum.approval_status = 'SUBMITTED'
   AND per.person_id = tsum.resource_id
   AND sysdate between per.effective_start_date and per.effective_end_date
   AND tsum.data_set_id =p_data_set_id
   AND apsum.application_period_id = tap.application_period_id
   AND tsum.timecard_id = tap.timecard_id
   AND apsum.approval_item_key is null
   AND wias.item_key = wiav.item_key
   AND tap.application_period_id=wiav.number_value
   AND wias.notification_id=wfn.notification_id
   AND wias.item_key=wiav.item_key
   AND wfn.status='OPEN'
   AND wias.item_type='HXCEMP'
   AND wiav.item_type = 'HXCEMP'
   AND wiav.name = 'APP_BB_ID'
   AND apsum.notification_status = 'NOTIFIED'
   AND apsum.approval_status = 'SUBMITTED'
   AND wfn.message_name in('TIMECARD_APPROVAL_INLINE','TIMECARD_APPROVAL')
   AND wfn.message_type='HXCEMP'
UNION
   SELECT
       tsum.resource_id,
       tsum.start_time,
       tsum.stop_time,
       nvl(per.employee_number,'Employee Number Unkown') employee_number,
       nvl(per.full_name,'Full Name Unknown') full_name
  FROM hxc_timecard_summary tsum,
       hxc_app_period_summary apsum,
       hxc_tc_ap_links tap,
       wf_notifications wfn,
       wf_item_activity_statuses wias,
       per_all_people_f per
 WHERE tsum.approval_status = 'SUBMITTED'
   AND per.person_id = tsum.resource_id
   AND sysdate between per.effective_start_date and per.effective_end_date
   AND tsum.data_set_id =p_data_set_id
   AND apsum.application_period_id = tap.application_period_id
   AND tsum.timecard_id = tap.timecard_id
   AND apsum.approval_item_key is not null
   AND wias.item_key = apsum.approval_item_key
   AND wias.notification_id=wfn.notification_id
   AND wfn.status='OPEN'
   AND wias.item_type='HXCEMP'
   AND apsum.notification_status = 'NOTIFIED'
   AND apsum.approval_status = 'SUBMITTED'
   AND wfn.message_name = 'TIMECARD_APPROVAL_INLINE'
   AND wfn.message_type='HXCEMP'
ORDER BY 2,1;

CURSOR c_get_bee_retrieval
IS
SELECT retrieval_process_id
FROM hxc_retrieval_processes
WHERE name = 'BEE Retrieval Process';

l_unretrieved_tc 	 c_get_unretrieved_tcs%rowtype;

-- Bug 6744917
-- Created the below Nested Table to Bulk Collect the
-- unretrieved timecards.
TYPE tab_unretrieved_tc  IS TABLE OF c_get_unretrieved_tcs%ROWTYPE;
l_unretrieved_tctab  tab_unretrieved_tc;

l_err_tc 		 c_chk_err_tcs%rowtype;
l_timecard_notifications c_timecard_notifications%rowtype;

-- Bug 6744917
-- Created the below Nested Table to Bulk Collect the
-- open timecard notifications.
TYPE tab_timecard_notifications  IS TABLE OF c_timecard_notifications%ROWTYPE;
l_timecard_notifications_tab tab_timecard_notifications;

l_validation_status      varchar2(1);
l_max_errors_reached     boolean;
l_count                  number:=0;
l_approved_count         number:=0;
l_rejected_count         number:=0;
l_submitted_count        number:=0;
l_working_count          number:=0;

l_bee_retrieval          number:=-1;
BEGIN

  l_max_errors_reached := FALSE;
  l_validation_status := 'V';
  p_error_count := 0;

  --Start all the validations
  --for each validation error we need to add that to the log file

  fnd_message.set_name('HXC', 'HXC_VALIDATION_WARNINGS');
  fnd_file.put_line(fnd_file.LOG,fnd_message.get);
  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');

  OPEN c_get_bee_retrieval;
  FETCH c_get_bee_retrieval INTO l_bee_retrieval;
  CLOSE c_get_bee_retrieval;



  --1.Display all Non-Retrieved and all status TC except Errored Timecards.
  OPEN c_get_unretrieved_tcs(p_data_set_id,l_bee_retrieval);
      LOOP
        -- Bug 6744917
        -- Made change in fetching records to improve performance.
        -- Instead of picking them one by one, and writing them one by one,
        -- BULK COLLECT 100 and loop thru and write them on to the log file.

        FETCH c_get_unretrieved_tcs
        BULK COLLECT
        INTO l_unretrieved_tctab LIMIT 100;
        EXIT WHEN l_unretrieved_tctab.COUNT = 0 ;
        FOR i IN l_unretrieved_tctab.FIRST..l_unretrieved_tctab.LAST
        LOOP
                    l_unretrieved_tc := l_unretrieved_tctab(i);
                    l_validation_status := 'E';

	            if(l_unretrieved_tc.approval_status='APPROVED') then
	               l_approved_count:=l_approved_count+1;
	            end if;

	            if(l_unretrieved_tc.approval_status='REJECTED') then
	            l_rejected_count:=l_rejected_count+1;
	            end if;

	            if(l_unretrieved_tc.approval_status='SUBMITTED') then
	            l_submitted_count:=l_submitted_count+1;
	            end if;

	            if(l_unretrieved_tc.approval_status='WORKING') then
	            l_working_count :=l_working_count+1;
	            end if;


	            if(l_approved_count=1 and l_unretrieved_tc.approval_status='APPROVED') then

	              fnd_file.put_line(fnd_file.LOG,'                                                                ');
		  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
		  fnd_message.set_name('HXC', 'HXC_UNRETRIEVED_APPROVED_TC');
		  fnd_file.put_line(fnd_file.LOG,'          '||fnd_message.get);
		  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
		  fnd_message.set_name('HXC', 'HXC_LISTING_HEADER_LINE');
	              fnd_file.put_line(fnd_file.LOG,fnd_message.get);
	            end if;

	            if(l_rejected_count=1 and l_unretrieved_tc.approval_status='REJECTED') then

		          fnd_file.put_line(fnd_file.LOG,'                                                                ');
			  fnd_file.put_line(fnd_file.LOG,'                                                                ');
			  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
			  fnd_message.set_name('HXC', 'HXC_UNRETRIEVED_REJECTED_TC');
			  fnd_file.put_line(fnd_file.LOG,'          '||fnd_message.get);
			  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
			  fnd_message.set_name('HXC', 'HXC_LISTING_HEADER_LINE');
		          fnd_file.put_line(fnd_file.LOG,fnd_message.get);
	            end if;


	            if(l_submitted_count=1 and l_unretrieved_tc.approval_status='SUBMITTED') then

		          fnd_file.put_line(fnd_file.LOG,'                                                                ');
			  fnd_file.put_line(fnd_file.LOG,'                                                                ');
			  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
			  fnd_message.set_name('HXC', 'HXC_UNRETRIEVED_SUBMITTED_TC');
			  fnd_file.put_line(fnd_file.LOG,'          '||fnd_message.get);
			  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
			  fnd_message.set_name('HXC', 'HXC_LISTING_HEADER_LINE');
		          fnd_file.put_line(fnd_file.LOG,fnd_message.get);
	            end if;

	            if(l_working_count=1 and l_unretrieved_tc.approval_status='WORKING') then

		          fnd_file.put_line(fnd_file.LOG,'                                                                ');
			  fnd_file.put_line(fnd_file.LOG,'                                                                ');
			  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
			  fnd_message.set_name('HXC', 'HXC_UNRETRIEVED_WORKING_TC');
			  fnd_file.put_line(fnd_file.LOG,'          '||fnd_message.get);
			  fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
			  fnd_message.set_name('HXC', 'HXC_LISTING_HEADER_LINE');
		          fnd_file.put_line(fnd_file.LOG,fnd_message.get);
	            end if;



	      	fnd_file.put_line(fnd_file.LOG,l_unretrieved_tc.start_time||'-'||l_unretrieved_tc.stop_time||'   '||l_unretrieved_tc.resource_id||' - '||l_unretrieved_tc.employee_number||' - '||l_unretrieved_tc.full_name);

	            p_error_count := p_error_count + 1;

	            IF (hxc_archive_restore_utils.check_max_errors(p_error_count) and p_all_errors=false )
	            THEN
	      	 l_max_errors_reached := TRUE;
	      	 EXIT;
	            END IF;
        END LOOP;
	l_unretrieved_tctab.DELETE;
       END LOOP;
    CLOSE c_get_unretrieved_tcs;


      -- 2. Validation to check if there are any errored timecards in the range
    l_count:=0;
    IF NOT l_max_errors_reached THEN

    OPEN c_chk_err_tcs(p_data_set_id);
    LOOP
      FETCH c_chk_err_tcs INTO  l_err_tc;
      EXIT WHEN c_chk_err_tcs%NOTFOUND;

      l_validation_status := 'E';
      l_count:=l_count+1;

      if(l_count=1) then
            fnd_file.put_line(fnd_file.LOG,'                                                                ');
            fnd_file.put_line(fnd_file.LOG,'                                                                ');
            fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
            fnd_message.set_name('HXC', 'HXC_LIST_ERROR_TC');
            fnd_file.put_line(fnd_file.LOG,'          '||fnd_message.get);
            fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
            fnd_message.set_name('HXC', 'HXC_LISTING_HEADER_LINE');
            fnd_file.put_line(fnd_file.LOG,fnd_message.get);
      end if;


      fnd_file.put_line(fnd_file.LOG,l_err_tc.start_time||'-'||l_err_tc.stop_time||'   '||l_err_tc.resource_id||' - '||l_err_tc.employee_number||' - '||l_err_tc.full_name);

      p_error_count := p_error_count + 1;

      IF (hxc_archive_restore_utils.check_max_errors(p_error_count) and p_all_errors=false )
      THEN
	l_max_errors_reached := TRUE;
	exit;
      END IF;

    END LOOP;
    CLOSE c_chk_err_tcs;
  END IF;


 -- 3. Validation to check whether there are any un-notified timecards
    l_count:=0;
    IF NOT l_max_errors_reached THEN

    OPEN c_timecard_notifications(p_data_set_id);
      LOOP

        -- Bug 6744917
        -- Made change in fetching records to improve performance.
        -- Instead of picking them one by one, and writing them one by one,
        -- BULK COLLECT 100 and loop thru and write them on to the log file.

        FETCH c_timecard_notifications
        BULK COLLECT
        INTO l_timecard_notifications_tab LIMIT 100;
        EXIT WHEN l_timecard_notifications_tab.COUNT = 0 ;

        FOR i IN l_timecard_notifications_tab.FIRST..l_timecard_notifications_tab.LAST
        LOOP
            l_timecard_notifications := l_timecard_notifications_tab(i);
            l_validation_status := 'E';
            l_count:=l_count+1;

            if(l_count=1)
            then
	       fnd_file.put_line(fnd_file.LOG,'                                                                ');
               fnd_file.put_line(fnd_file.LOG,'                                                                ');
	       fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
	       fnd_message.set_name('HXC', 'HXC_LIST_NOT_NOTIFIED_TC');
	       fnd_file.put_line(fnd_file.LOG,'          '||fnd_message.get);
	       fnd_file.put_line(fnd_file.LOG,'-------------------------------------------------------------- ');
	       fnd_message.set_name('HXC', 'HXC_LISTING_HEADER_LINE');
	       fnd_file.put_line(fnd_file.LOG,fnd_message.get);
            end if;

    	    fnd_file.put_line(fnd_file.LOG,
                              l_timecard_notifications.start_time||'-'||l_timecard_notifications.stop_time||'   '||l_timecard_notifications.resource_id||' - '||l_timecard_notifications.employee_number||' - '||l_timecard_notifications.full_name);
            p_error_count := p_error_count + 1;

            IF (hxc_archive_restore_utils.check_max_errors(p_error_count) and p_all_errors=false)
            THEN
    	    l_max_errors_reached := true;
    	    exit;
            END IF;
        END LOOP;
        l_timecard_notifications_tab.DELETE;
      END LOOP;
   CLOSE c_timecard_notifications;
   END If;


  --finally set the validation status
  UPDATE hxc_data_sets
  SET    validation_status = l_validation_status
  WHERE data_set_id = p_data_set_id;


END validate_data_set;

----------------------------------------------------------------------------
-- Procedure Name : lock_data_set
-- Description :
----------------------------------------------------------------------------
PROCEDURE lock_data_set (p_data_set_id 		in  number,
			 p_start_date  		in  date,
			 p_stop_date   		in  date,
			 p_data_set_lock	out NOCOPY BOOLEAN)
IS

CURSOR c_lock_resource is
SELECT distinct resource_id
FROM hxc_time_building_blocks
WHERE data_set_id = p_data_set_id
AND scope = 'TIMECARD';

l_row_lock_id	ROWID;
l_messages	HXC_MESSAGE_TABLE_TYPE;
l_lock_success	BOOLEAN;
l_released_success	BOOLEAN;

BEGIN

p_data_set_lock	:= FALSE;

FOR crs_lock_resource IN c_lock_resource LOOP

  l_row_lock_id := NULL;
  l_lock_success := FALSE;

  hxc_lock_api.request_lock (
            p_process_locker_type 	=> hxc_lock_util.c_plsql_ar_action,
            p_resource_id 		=> crs_lock_resource.resource_id,
            p_start_time 		=> p_start_date,
            p_stop_time 		=> p_stop_date,
            p_time_building_block_id 	=> NULL,
            p_time_building_block_ovn 	=> NULL,
            p_transaction_lock_id 	=> p_data_set_id,
            p_expiration_time		=> 60,
            p_messages 			=> l_messages,
            p_row_lock_id 		=> l_row_lock_id,
            p_locked_success 		=> l_lock_success
           );

--fnd_file.put_line(fnd_file.LOG,l_messages(l_messages.first).message_name);

  IF not(l_lock_success) THEN

    -- before returning let's unlock all the timecards that were locked
    hxc_lock_api.release_lock (
       p_row_lock_id 		=> null,
       p_process_locker_type 	=> hxc_lock_util.c_plsql_ar_action,
       p_transaction_lock_id 	=> p_data_set_id,
       p_released_success 	=> l_released_success
       );

fnd_file.put_line(fnd_file.LOG,'========== PROCESS STOPPED ================' );
fnd_file.put_line(fnd_file.LOG,'========== TIMECARD LOCKED ================' );
fnd_file.put_line(fnd_file.LOG,'==> The resource id '||crs_lock_resource.resource_id||' has timecards locked for ');
fnd_file.put_line(fnd_file.LOG,'==> the period from '||p_start_date||' to '||p_stop_date);

    RETURN;

  END IF;

END LOOP;

p_data_set_lock	:= TRUE;

END lock_data_set;

----------------------------------------------------------------------------
-- Procedure Name : release_lock_data_set
-- Description :
----------------------------------------------------------------------------

PROCEDURE release_lock_data_set(p_data_set_id in number)
IS

l_released_success	BOOLEAN;

BEGIN

   hxc_lock_api.release_lock (
       p_row_lock_id 		=> null,
       p_process_locker_type 	=> hxc_lock_util.c_plsql_ar_action,
       p_transaction_lock_id 	=> p_data_set_id,
       p_released_success 	=> l_released_success
       );

END release_lock_data_set;

END hxc_data_set;

/
