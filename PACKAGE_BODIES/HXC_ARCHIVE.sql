--------------------------------------------------------
--  DDL for Package Body HXC_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_ARCHIVE" AS
  /* $Header: hxcarchive.pkb 120.3.12010000.9 2010/01/20 07:21:29 asrajago ship $ */


----------------------------------------------------------------------------
-- Procedure Name : archive_process
-- Description : This procedure is called during Archive Data Set process.
--               For a given data set, it copies the records FROM
--               base tables to archive tables AND DELETEs the records in base
--               table. It removes the links FROM hxc_tc_ap_links AND
--               hxc_ap_detail_links. It cancels open notifications. This
--               process is done in chunks.
----------------------------------------------------------------------------
PROCEDURE archive_process(p_data_set_id 	NUMBER,
              		  p_data_set_start_date DATE,
              		  p_data_set_end_date   DATE)
IS

-- For the given data set id, pick up all the timecard scope records
-- to be dumped into the temp table for processing.

CURSOR get_timecards( p_data_set_id   IN NUMBER)
    IS SELECT /*+ INDEX (HXC HXC_TIME_BUILDING_BLOCKS_N2)*/
              TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,UNIT_OF_MEASURE,
              START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,PARENT_BUILDING_BLOCK_OVN,
              SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
              LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,RESOURCE_TYPE,
              APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,APPLICATION_SET_ID,DATA_SET_ID,
              TRANSLATION_DISPLAY_KEY
         FROM hxc_time_building_blocks hxc
        WHERE data_set_id = p_data_set_id
          AND scope = 'TIMECARD'
         ORDER BY time_building_block_id;

-- To pick up the details of the timecards processed, grouped by threads- chunks.

CURSOR get_log_details
    IS SELECT temp1.resource_id,
              temp1.start_time,
              temp1.time_building_block_id tc_id,
              temp2.thread_id||'('||temp2.chunk_number||')' detail
        FROM hxc_ar_detail_log temp2,
             hxc_ar_tc_ids_temp temp1
       WHERE temp1.time_building_block_id = temp2.time_building_block_id
         AND temp1.object_version_number = temp2.object_version_number
         AND temp2.process_type NOT LIKE '%INCOMPLETE%'
	ORDER BY temp2.thread_id,
                 temp2.chunk_number,
                 temp1.start_time,
                 temp1.resource_id     ;

-- To pick up the details of the timecards that failed, grouped by threads - chunks.
CURSOR get_log_details_failed
    IS SELECT temp1.resource_id,
              temp1.start_time,
              temp1.time_building_block_id tc_id,
              temp2.thread_id||'('||temp2.chunk_number||')' detail
        FROM hxc_ar_detail_log temp2,
             hxc_ar_tc_ids_temp temp1
       WHERE temp1.time_building_block_id = temp2.time_building_block_id
         AND temp1.object_version_number = temp2.object_version_number
         AND temp2.process_type LIKE '%INCOMPLETE%'
	ORDER BY temp2.thread_id,
                 temp2.chunk_number,
                 temp1.start_time,
                 temp1.resource_id     ;


TYPE tc_tab  IS TABLE OF get_timecards%ROWTYPE;

l_tc_tab   tc_tab;

l_tc_cnt  NUMBER;
l_tc_count  NUMBER;

l_chunk_size number;


TYPE NUMTABLE IS TABLE OF hxc_time_building_blocks_ar.time_building_block_id%TYPE;
TYPE VARCHARTABLE IS TABLE OF VARCHAR2(4000);


TYPE NUMBERTABLE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
bb_id_tab   NUMBERTABLE;

l_index BINARY_INTEGER;
--	l_item_key wf_item_attribute_values.item_key%type;

l_min_start_time	DATE;
l_bb_ctr                BINARY_INTEGER ;

l_tc_chunk     NUMBER;
l_start        NUMBER;
l_stop         NUMBER;
id_start       NUMBER;
id_stop        NUMBER;
l_req_id_tab   NUMBERTABLE ;

l_call_status  BOOLEAN ;
l_interval     NUMBER := 30;
l_phase        VARCHAR2(30);
l_status       VARCHAR2(30);
l_dev_phase    VARCHAR2(30);
l_dev_status   VARCHAR2(30);
l_message      VARCHAR2(30);
iloop          NUMBER;

all_threads_complete      BOOLEAN := FALSE;

trans_count    NUMBER := 0;
l_debug_info   VARCHAR2(50);
l_thread_success  BOOLEAN := TRUE;


BEGIN

  hr_general.g_data_migrator_mode := 'Y';

  l_chunk_size := nvl(fnd_profile.value('HXC_ARCHIVE_RESTORE_CHUNK_SIZE'),50);

fnd_file.put_line(fnd_file.LOG,'--- > Chunk Size is: '||l_chunk_size);

  -- Update hxc_data_sets as BACKUP_IN_PROGRESS because the process is going to take some time.

  UPDATE hxc_data_sets
  SET status = 'BACKUP_IN_PROGRESS'
  WHERE data_set_id = p_data_set_id;

  -- Delete from the temp tables,  if there is any left over data.

  DELETE FROM hxc_ar_detail_log ;
  DELETE FROM hxc_ar_tc_ids_temp;
  DELETE FROM hxc_ar_trans_temp;
  DELETE FROM hxc_data_set_details;

  l_bb_ctr  := 0;

  -- Get timecards in this data set.
  OPEN get_timecards(p_data_set_id);
  LOOP
     -- Fetch 500 timecard scope records ( one record is one tbb_id- ovn combination )
     FETCH get_timecards
      BULK COLLECT INTO l_tc_tab  LIMIT 500;

     EXIT WHEN l_tc_tab.COUNT = 0;

     -- Insert these 500 records into hxc_ar_tc_ids_temp
     FORALL i IN l_tc_tab.FIRST..l_tc_tab.LAST
       INSERT INTO hxc_ar_tc_ids_temp
       --(TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
       --SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,
       --APPROVAL_STATUS,RESOURCE_ID,RESOURCE_TYPE,APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,
       --PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,DATA_SET_ID,TRANSLATION_DISPLAY_KEY)
         VALUES l_tc_tab(i) ;

    -- Loop thru the timecard records fetched
    -- and record the time_building_block_ids
    -- coming in positions which are multiples of 10.
    -- Eg. For 500 timecards, pick 0th, 10th, 20th, 30th ids etc.

    iloop := l_tc_tab.FIRST;
    WHILE iloop < l_tc_tab.last
    LOOP
         l_bb_ctr := l_bb_ctr + 1;
         -- Copy the ids in 10s positions to this table.
         bb_id_tab(l_bb_ctr) := l_tc_tab(iloop).time_building_block_id;
         iloop := iloop + 10;
         -- If there are only less than 10 records left,
         -- make the last record as the next one.
         IF iloop >= l_tc_tab.last
         THEN
            iloop := l_tc_tab.last;
            l_bb_ctr := l_bb_ctr + 1;
            bb_id_tab(l_bb_ctr) := l_tc_tab(iloop).time_building_block_id;
         END IF;
     END LOOP;

  END LOOP;


  COMMIT;

  -- Check how many are there in the plsql table,
  -- which has timecard ids at an offset of 10.
  l_tc_count := bb_id_tab.COUNT;

  -- We would process the below construct of launching the
  -- multithreaded structure only if there are 10 entries above.
  -- Meaning 10 * 10, 100 timecards in all to be archived.

  IF l_tc_count > 10
  THEN
     -- There are five threads in all anyways.
     -- This variable decides how many timecards go to each thread.
     l_tc_chunk := ceil(l_tc_count/5);

     l_start := 1;
     l_stop  := l_tc_chunk ;
     id_stop := bb_id_tab(l_start);

     fnd_file.put_line(fnd_file.log,'Following are the bb id ranges for the threads ');
     fnd_file.put_line(fnd_file.log,'==============================================');
     FOR i IN 1..4
     LOOP
        -- Calculate the start and stop ids and launch the threads.
        -- ( 1- 4 threads get launched in this loop
        id_start := id_stop;
        id_stop  := bb_id_tab(l_stop);

        l_req_id_tab(i) := FND_REQUEST.SUBMIT_REQUEST( application => 'HXC',
                                                       program      => 'HXCARCCHILD',
                                                       description => NULL,
                                                       sub_request => FALSE,
                                                       argument1   => id_start,
                                                       argument2   => id_stop,
                                                       argument3   => p_data_set_id,
                                                       argument4   => i );
        fnd_file.put_line(fnd_file.log,id_start||' -> '||id_stop);
        COMMIT;
        l_stop  := l_stop  + l_tc_chunk ;
        IF l_stop > l_tc_count
        THEN
           EXIT;
        END IF;
     END LOOP;

     -- Calculate the last tc id range and launch the fifth thread.

     id_start  := id_stop;
     id_stop   := bb_id_tab(bb_id_tab.LAST)+1;

     fnd_file.put_line(fnd_file.log,id_start||' -> '||id_stop);

     l_req_id_tab(5) := FND_REQUEST.SUBMIT_REQUEST( application => 'HXC',
                                                     program      => 'HXCARCCHILD',
                                                     description => NULL,
                                                     sub_request => FALSE,
                                                     argument1   =>   id_start,
                                                     argument2    =>  id_stop,
                                                     argument3    =>  p_data_set_id,
                                                     argument4    =>  5 );

      COMMIT;

  ELSE
     -- This is in case the total number of timecards is less than 100.
     -- Pretty pointless, having timecards Archived in threads if there are
     -- only 100.  Launch just one thread, and let it take care of all
     -- records.
     id_start  := bb_id_tab(bb_id_tab.FIRST);
     id_stop   := bb_id_tab(bb_id_tab.LAST)+1;

     fnd_file.put_line(fnd_file.log,id_start||' -> '||id_stop);

     l_req_id_tab(5) := FND_REQUEST.SUBMIT_REQUEST( application => 'HXC',
                                                     program      => 'HXCARCCHILD',
                                                     description => NULL,
                                                     sub_request => FALSE,
                                                     argument1   =>   id_start,
                                                     argument2    =>  id_stop,
                                                     argument3    =>  p_data_set_id,
                                                     argument4    =>  5 );
     COMMIT;
  END IF;

   -- Keep watching the threads until they are completed.
  WHILE all_threads_complete <> TRUE
  LOOP

      all_threads_complete := TRUE;

      FOR i IN l_req_id_tab.FIRST..l_req_id_tab.LAST
      LOOP
          IF l_req_id_tab.EXISTS(i)
	  THEN
             l_call_status := FND_CONCURRENT.get_request_status(l_req_id_tab(i), '', '',
      			                                     l_phase,
      			                                     l_status,
      			                                     l_dev_phase,
      			                                     l_dev_status,
      	     		                                     l_message);

             IF l_call_status = FALSE
             THEN
                fnd_file.put_line(fnd_file.LOG,i||'th request failed');
                l_thread_success := FALSE;
             END IF;
             IF l_dev_phase <> 'COMPLETE'
             THEN
                all_threads_complete := FALSE;
             END IF   ;
          END IF;
      END LOOP;

      -- Check if hxc_ar_trans_temp table has records.
      -- ( Rownum condition put so that no FTS is issued by the DB.
      --   We dont want the total count, just wanna know if it has atleast
      --   one record )
      SELECT COUNT(1)
        INTO trans_count
        FROM hxc_ar_trans_temp
       WHERE rownum < 2;

      -- If it has records, it means that the thread processes would have
      -- created RETRIEVAL transaction records in the table. Process them.
      IF trans_count >= 1
      THEN
         -- Update all threads to zero, to ensure we seal them from the threads.
         UPDATE hxc_ar_trans_temp
            SET thread_id = 0 ;

         -- Not much processing left, just insert the records from hxc_transacitons
         -- to hxc_transactions_ar if they are not present already.

         INSERT INTO hxc_transactions_ar
                     (DATA_SET_ID,TRANSACTION_ID,TRANSACTION_PROCESS_ID,TRANSACTION_DATE,TYPE,
                      STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
                      LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TRANSACTION_CODE)
              SELECT  /*+ INDEX(bkuptxn hxc_transactions_pk) */
                      p_data_set_id,bkuptxn.TRANSACTION_ID,TRANSACTION_PROCESS_ID,
	              TRANSACTION_DATE,TYPE,STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,
                      CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,
	              TRANSACTION_CODE
                FROM hxc_transactions bkuptxn
               WHERE bkuptxn.transaction_id IN ( SELECT temp.transaction_id
                                                   FROM hxc_ar_trans_temp temp
                                                  WHERE thread_id = 0 )
                 AND bkuptxn.transaction_id NOT IN ( SELECT transaction_id
                                                       FROM hxc_transactions_ar hxc
                                                      WHERE bkuptxn.transaction_id = hxc.transaction_id)
                  ;

         -- Delete those records from hxc_transactions.

         DELETE FROM hxc_transactions
               WHERE ROWID IN ( SELECT CHARTOROWID(trans_rowid)
                                  FROM hxc_ar_trans_temp
                                 WHERE thread_id = 0 );


         -- Clear all the records, which are processed.

         DELETE FROM hxc_ar_trans_temp
               WHERE thread_id = 0 ;

         COMMIT;

      ELSE

         -- There are no records still in the temp table for transactions.
         -- Sleep for 10 seconds and try again.
         dbms_lock.sleep(10);

      END IF;

  END LOOP;

  COMMIT;



  -- Check if hxc_data_set_details table has records.
  -- ( Rownum condition put so that no FTS is issued by the DB.
  --   We dont want the total count, just wanna know if it has atleast
  --   one record )

  trans_count := 0;
  SELECT COUNT(1)
    INTO trans_count
    FROM hxc_data_set_details;

  -- Done with the processing, update the data set status to OFFLINE.
  IF l_thread_success AND trans_count = 0
  THEN
     -- If all threads finished successfully and there is no data left in
     -- hxc_data_set_details, then mark the data set as OFF_LINE.
     UPDATE hxc_data_sets
        SET status = 'OFF_LINE', validation_status = ' '
      WHERE data_set_id = p_data_set_id;

  ELSE
     fnd_file.put_line(fnd_file.LOG,' There were some issues with the process');
     fnd_file.put_line(fnd_file.LOG,' Either one of the threads failed or there is a data issue ');
     fnd_file.put_line(fnd_file.LOG,' Please run the process again to reprocess the failed timecards ');
     fnd_file.put_line(fnd_file.LOG,' ');

  END IF;


  COMMIT;

  l_debug_info := ' ';
  -- Check if the profile is set for detailed logging.
  IF fnd_profile.value('HXC_AR_ENABLE_LOG') = 'Y'
  THEN
     -- Print out the log.
     fnd_file.put_line(fnd_file.LOG,' ');
     fnd_file.put_line(fnd_file.LOG,'Following are the timecards processed ');
     fnd_file.put_line(fnd_file.LOG,'======================================');
     fnd_file.put_line(fnd_file.LOG,' ');
     fnd_file.put_line(fnd_file.LOG,'Person id - Timecard start time [TC ID - Debug information]');
     fnd_file.put_line(fnd_file.LOG,' ');
     FOR log_rec IN get_log_details
     LOOP
        IF l_debug_info <> log_rec.detail
        THEN
           fnd_file.put_line(fnd_file.log,'   ----    ');
           l_debug_info := log_rec.detail;
        END IF;
        hr_utility.trace(log_rec.resource_id||' - '||log_rec.start_time||
             '  ['||log_rec.tc_id||'-'||log_rec.detail||']');
        fnd_file.put_line(fnd_file.log,log_rec.resource_id||' - '||log_rec.start_time||
             '  ['||log_rec.tc_id||'-'||log_rec.detail||']');
     END LOOP;

     l_debug_info := ' ';
     fnd_file.put_line(fnd_file.LOG,' ');
     fnd_file.put_line(fnd_file.LOG,'Following are the timecards not processed ');
     fnd_file.put_line(fnd_file.LOG,'==========================================');
     fnd_file.put_line(fnd_file.LOG,' ');
     fnd_file.put_line(fnd_file.LOG,'Person id - Timecard start time [TC ID - Debug information]');
     fnd_file.put_line(fnd_file.LOG,' ');
     FOR log_rec IN get_log_details_failed
     LOOP
        IF l_debug_info <> log_rec.detail
        THEN
           fnd_file.put_line(fnd_file.log,'   ----    ');
           l_debug_info := log_rec.detail;
        END IF;
        hr_utility.trace(log_rec.resource_id||' - '||log_rec.start_time||
             '  ['||log_rec.tc_id||'-'||log_rec.detail||']');
        fnd_file.put_line(fnd_file.log,log_rec.resource_id||' - '||log_rec.start_time||
             '  ['||log_rec.tc_id||'-'||log_rec.detail||']');
     END LOOP;
  END IF;

  -- COMMIT and come out of the process.
  COMMIT;

END archive_process;




-- Public Procedure child_archive_process
-- Added as part of re-architecture to multithread the process.
-- Would be called from the Worker process for Archive Data Set.


PROCEDURE child_archive_process ( errbuf         OUT  NOCOPY VARCHAR2,
                                  retcode        OUT  NOCOPY NUMBER,
                                  p_from_id      IN   NUMBER,
                                  p_to_id        IN   NUMBER,
                                  p_data_set_id  IN   NUMBER,
                                  p_thread_id    IN   NUMBER )
IS


CURSOR get_tcs
    IS SELECT time_building_block_id,
              object_version_number
         FROM hxc_ar_tc_ids_temp
        WHERE time_building_block_id >= p_from_id
          AND time_building_block_id < p_to_id   ;

CURSOR get_transactions
    IS SELECT /*+ LEADING(temp) */
              transaction_detail_id,
              transaction_id,
              ROWIDTOCHAR(ar.ROWID)
         FROM hxc_temp_timecard_chunks temp,
              hxc_transaction_details ar
        WHERE ar.time_building_block_id = temp.id
          AND ar.time_building_block_ovn = temp.ref_ovn
          AND thread_id = p_thread_id ;

-- Bug 8888813
-- Added this new cursor to pick up from the table for
-- DEPOSIT transactions.
CURSOR get_dep_transactions
    IS SELECT /*+ LEADING(temp) */
              transaction_detail_id,
              transaction_id,
              ROWIDTOCHAR(ar.ROWID)
         FROM hxc_temp_timecard_chunks temp,
              hxc_dep_transaction_details ar
        WHERE ar.time_building_block_id = temp.id
          AND ar.time_building_block_ovn = temp.ref_ovn
          AND thread_id = p_thread_id ;


CURSOR get_attributes
    IS SELECT /*+ LEADING(temp) */
              DISTINCT
              time_attribute_usage_id,
              time_attribute_id,
              ROWIDTOCHAR(ar.ROWID)
         FROM hxc_temp_timecard_chunks temp,
              hxc_time_attribute_usages ar
        WHERE ar.time_building_block_id = temp.id
          AND thread_id = p_thread_id ;

CURSOR get_tbb_rowid (p_scope  VARCHAR2)
    IS SELECT ref_rowid
         FROM hxc_temp_timecard_chunks
        WHERE scope = p_scope
          AND thread_id = p_thread_id ;

CURSOR get_dup_trans
    IS SELECT master_id,
              MAX(ROWID)
         FROM hxc_archive_temp
        WHERE thread_id = p_thread_id
        GROUP BY master_id ;


CURSOR get_latest_details
    IS SELECT det.time_building_block_id,
              ROWIDTOCHAR(det.ROWID)
         FROM hxc_temp_timecard_chunks temp,
              hxc_latest_details det
        WHERE temp.scope = 'DETAIL'
          AND temp.id  = det.time_building_block_id ;


CURSOR get_max_ovn
    IS SELECT id,
              max(ref_ovn)
         FROM hxc_temp_timecard_chunks temp
        WHERE scope = 'DETAIL'
          AND thread_id = p_thread_id
        GROUP by id ;


l_chunk_size number;

TYPE NUMTABLE     IS TABLE OF hxc_time_building_blocks_ar.time_building_block_id%TYPE;
TYPE VARCHARTABLE IS TABLE OF VARCHAR2(4000);

tc_id_tab            NUMTABLE;
tc_ovn_tab  	     NUMTABLE;
tc_rowid_tab         VARCHARTABLE;
rowid_tab            VARCHARTABLE;
td_rowid_tab 	     VARCHARTABLE;
trans_detail_tab     NUMTABLE;
trans_tab            NUMTABLE;
usage_tab   	     NUMTABLE;
attribute_tab        NUMTABLE;
usage_rowid_tab      VARCHARTABLE;
uniq_rowid_tab       VARCHARTABLE;
trans_id_tab         NUMTABLE;

latest_id_tab        NUMTABLE;
latest_ovn_Tab       NUMTABLE;
latest_rowid_tab     VARCHARTABLE;

l_tc_count		NUMBER := 0;
l_day_count		NUMBER := 0;
l_detail_count		NUMBER := 0;
l_det_count		NUMBER := 0;
l_app_period_count	NUMBER := 0;
l_tau_count		NUMBER := 0;
l_td_count		NUMBER := 0;
l_trans_count		NUMBER := 0;
l_tal_count		NUMBER := 0;
l_adl_count		NUMBER := 0;
l_app_period_sum_count	NUMBER := 0;
l_ta_count              NUMBER := 0;

l_tc_del_count         NUMBER := 0;
l_tal_del_count        NUMBER := 0;
l_day_del_count        NUMBER := 0;
l_det_del_count        NUMBER := 0;
l_app_del_count        NUMBER := 0;
l_app_sum_del_count    NUMBER := 0;
l_tau_del_count        NUMBER := 0;
l_ta_del_count         NUMBER := 0;
l_td_del_count         NUMBER := 0;
l_trans_del_count      NUMBER := 0;
l_adl_del_count        NUMBER := 0;



l_data_set_end_date     DATE;
l_data_set_start_date   DATE;

data_mismatch           BOOLEAN  := FALSE;
iloop                   NUMBER := 0;
l_chunk_no              NUMBER := 0;

DEADLOCK_DETECTED EXCEPTION;
PRAGMA EXCEPTION_INIT(DEADLOCK_DETECTED,-60);


   PROCEDURE  write_data_mismatch(p_scope     IN VARCHAR2)
   IS

   BEGIN
       FORALL i IN tc_id_tab.FIRST..tc_id_tab.LAST
       	  INSERT INTO hxc_ar_detail_log
       	    	              (time_building_block_id,
       	    	    	       object_version_number,
       	    	    	       process_type,
            	    	       thread_id,
            	    	       chunk_number)
       	    	       VALUES (tc_id_tab(i),
       	    	               tc_ovn_tab(i),
       	    	               'ARCHIVE-INCOMPLETE',
       	    	               p_thread_id,
       	    	               l_chunk_no);
         INSERT INTO hxc_data_set_details
                      (data_set_id,
                       scope,
                       table_name,
                       row_count)
              VALUES (p_data_set_id,
                      p_scope,
                      p_thread_id,
                      l_chunk_no );

       COMMIT;
       retcode := 2;

   END;



BEGIN


  -- Bug 7358756
  -- REWRITTEN ARCHIVE PROCESS

  -- This procedure is rewritten in line with the changed Archive process
  -- The process is now multithreaded, and each thread processes independant
  --  of others.  Detailed algorithm/approach as below.

  -- HXC_AR_TC_IDS_TEMP table populated by the parent process holds all the timecard
  -- scope records that are to be archived.  The process parameters are as below.
  -- p_from_id          -- Starting time_building_block_id for this thread.
  -- p_to_id		-- Ending time_building_block_id for this thread
  -- p_data_set_id	-- Data set id to be populated in the tables.
  -- p_thread_id	-- Thread number for this thread.
  --
  -- Following are the steps.
  --
  -- * Pick up the timecards(id-ovn) from hxc_ar_tc_ids_temp table, limited by
  --   chunk size profile option.
  -- * Insert the above id-ovn combination into hxc_temp_timecard_chunks table.
  -- * Pick up all records from hxc_time_building_blocks for these combinations
  --   and insert into hxc_time_building_blocks_ar
  -- * For the timecard records in hxc_temp_timecard_chunks, pick up all records
  --    from hxc_tc_ap_links, and insert into itself with application_period scope.
  -- * Join hxc_temp_timecard_chunks with hxc_tc_ap_links and insert into hxc_tc_ap_links_ar
  --    table.
  -- * Delete these records from hxc_tc_ap_links table.
  -- * For all the application_period records in hxc_temp_timecard_chunks table, select from
  --    hxc_time_building_blocks and insert into hxc_time_building_blocks_ar.
  -- * Delete from hxc_time_building_blocks these records.
  -- * Pick up all records for the application_period from hxc_app_period_summary
  --    table and insert into hxc_app_period_summary_ar table.
  -- * Delete from hxc_app_period_summary table, the corresponding records.
  -- * Join hxc_temp_timecard_chunks with hxc_time_building_blocks, DAY scope and pick up
  --    all DAY records for these timecards, insert them into hxc_temp_timecard_chunks.
  --     ( id, ovn, ROWID )
  -- * Insert into hxc_time_building_blocks_ar these records, joining them by ROWID.
  -- * Delete the above records from hxc_time_building_blocks.
  -- * Join hxc_temp_timecard_chunks with hxc_time_building_blocks, DETAIL scope and pick up
  --    all DETAIL records for these timecards, insert them into hxc_temp_timecard_chunks.
  --     ( id, ovn, ROWID )
  -- * Insert into hxc_time_building_blocks_ar these records, joining them by ROWID.
  -- * Delete the above records from hxc_time_building_blocks.
  -- * Loop to process transaction records.
  --      Pick up transaction detail records for the records in hxc_temp_timecard_chunks
  --        as of now. ( detail_id, transaction_id, detail_rowid ), and insert into
  --        hxc_archive_temp.
  --      Using the rowids, insert the transaction detail records into
  --        hxc_transaction_details_ar.
  --      Delete the records from hxc_transaction_details_ar using the ROWID.
  --      Delete duplicate transaction ids from hxc_archive_temp.
  --      Select all deposit transaction records from hxc_transactions table and
  --        insert into hxc_transactions_ar table.
  --      Select all retrieval transaction ids and insert into hxc_ar_trans_temp
  --        table for the parent thread to process.
  --      Delete all transaction records from hxc_transactions table, if the transaction
  --        id is present in hxc_archive_temp.
  --      Delete from hxc_archive temp for the the next iteration of this loop.
  -- * Loop to process attribute records.
  --      Pick up attribute usage records for the records in hxc_temp_timecard_chunks
  --        as of now. ( usage_id, attribute_id, usage_rowid ), and insert into
  --        hxc_archive_temp.
  --      Using the rowids, insert the attribute usage records into
  --        hxc_attribute_usages_ar.
  --      Delete the records from hxc_transaction_details_ar using the ROWID.
  --      Delete all records from hxc_archive_temp if attribute_id is
  --        present in hxc_time_attributes_ar
  --      Select all attribute records from hxc_time_attributes table and
  --        insert into hxc_time_attributes_ar table.
  --      Delete all attribute records from hxc_time_attributes table, if the attribute
  --        id is present in hxc_archive_temp.
  --      Delete from hxc_archive temp for the the next iteration of this loop.
  -- * Delete all other scopes except DETAIL from hxc_temp_timecard_chunks.
  -- * Select from hxc_ap_detail_links table, the records corresponding to the
  --     details and insert into hxc_ap_detail_links_ar table.
  -- * Delete from hxc_ap_detail_links table the above records.
  -- * Delete from hxc_temp_timecard_chunks all records except the latest ovns.
  -- * Insert these records into hxc_latest_details.
  -- * COMMIT and pick up the next chunk.
  --
  -- Technical points to look for.
  -- 1. Simulated Continue with each chunk check.
  --        Each insert into AR - Delete from core action has to be followed
  --        by a count check to see if total inserted and total deleted is the same.
  --        If no, we have to rollback that chunk and proceed with the rest of the
  --        chunks.  That also means that we need to have a 'continue' to next chunk
  --        after all errored count checks.  To enable this, there is an inner loop
  --        << TO_CONTINUE_TO_NEXT_CHUNK >>.  For a normal chunk, this will iterate
  --        once and exit out ( look at the WHILE condition.) -- meaning there is
  --        no functional addition here.  To continue to next chunk at any point, the
  --        code will EXIT from this loop.  That will bring it to the end of the code inside
  --        the original loop and would function like a continue.  This handles count checks
  --        after moving data from each set of tables.
  -- 2. Avoiding issues of resource contention.
  --        Since we are dealing with multiple sessions doing the same thing, there are issues
  --        of resource contention.  The threads are working in different sets of timecards, but
  --        still there could be some records shared between the threads.  For eg, a retrieval
  --        transaction id can be shared across two versions of the timecard, and it might
  --        be possible that they fall in different thread. ( All timecards of the same
  --        building block id fall in the same thread, but in case of a template overwrite,
  --        the building block ids are different and might fall in different threads. ).
  --        Hence the retrieval transactions are all moved to the parent thread for processing, so
  --        there is no issue of resource contention here.
  --        Apart from this, there are application period records which are shared.  For example,
  --        by weekly timecards having monthly approval, four timecards can share a single application
  --        period record, and this might cause a resource contention.  But we cannot afford to
  --        move this also to parent process, because in that case, the application attributes also
  --        need to be moved out, meaning we lose too much of the multithreaded advantage.
  --        To work this around, the whole processing is put inside a BEGIN-END block. In case
  --        of a resource contention ( you would have dup_val_on_index error on the _AR ) tables,
  --        the process will come to exception block, and wait sleep there for a minute.  This would
  --        let the thread which committed the record earlier to finish.  The thread would continue
  --        after a minute iterating again in the inner while loop as mentioned above.
  --
  --   The Worker Process for Restore Data set follows the same logic, except that the
  --   source and destination tables interchange.
  --

  hr_general.g_data_migrator_mode := 'Y';

  l_chunk_size := nvl(fnd_profile.value('HXC_ARCHIVE_RESTORE_CHUNK_SIZE'),50);

  fnd_file.put_line(fnd_file.LOG,'--- > Chunk Size is: '||l_chunk_size);

  -- firs let's get the min start time of
  -- the timecard for this data set

  SELECT start_date,
         end_date
    INTO l_data_set_start_date,
         l_data_set_end_date
    FROM hxc_data_sets
   WHERE data_set_id = p_data_set_id;

    OPEN get_tcs ;
    LOOP

       FETCH get_tcs
        BULK COLLECT
        INTO tc_id_tab,
             tc_ovn_tab  LIMIT l_chunk_size ;

        EXIT WHEN tc_id_tab.COUNT = 0;

        l_td_count := 0;
        l_trans_count := 0;
        l_tau_count := 0;
        l_ta_count  := 0;
        data_mismatch := FALSE;
        iloop := 1;
        l_chunk_no := l_chunk_no + 1;

        fnd_file.put_line(fnd_file.log,'                                                   ');
        fnd_file.put_line(fnd_file.log,'*****************************************************************');
        fnd_file.put_line(fnd_file.log,'=================================================================');
        fnd_file.put_line(fnd_file.log,'Entering in a new chunk ');
        fnd_file.put_line(fnd_file.log,'==================================================================');

        <<TO_CONTINUE_TO_NEXT_CHUNK >>
        WHILE iloop = 1
        LOOP
            iloop := 0;

            BEGIN

                FORALL i IN tc_id_tab.FIRST..tc_id_tab.LAST
            	   INSERT INTO hxc_temp_timecard_chunks
            	               ( id,
            	                 ref_ovn,
            	                 scope,
            	                 thread_id )
            	        VALUES ( tc_id_tab(i),
            	                 tc_ovn_tab(i),
            	                 'TIMECARD',
            	                 p_thread_id );


            	INSERT INTO hxc_time_building_blocks_ar
            	              (DATA_SET_ID,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
            	              UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
            	              SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
		              LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,
		   	      RESOURCE_TYPE,APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,
		   	      PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,
		   	      TRANSLATION_DISPLAY_KEY)
            	SELECT /*+ INDEX(bkup HXC_TIME_BUILDING_BLOCKS_PK) */
            	       bkup.DATA_SET_ID,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
	    	       UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
	    	       bkup.SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	    	       LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,RESOURCE_TYPE,
	    	       APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,
	    	       TRANSLATION_DISPLAY_KEY
	    	  FROM hxc_temp_timecard_chunks temp,
	    	       hxc_time_building_blocks bkup
	    	 WHERE bkup.scope = 'TIMECARD'
            	   AND bkup.time_building_block_id = temp.id
            	   AND bkup.object_version_number = temp.ref_ovn
	    	   AND bkup.data_set_id = p_data_set_id
	    	   AND thread_id = p_thread_id ;

            	l_tc_count := sql%rowcount;

            	FORALL i IN tc_id_tab.FIRST..tc_id_tab.LAST
            	     DELETE
            	       FROM hxc_time_building_blocks
            	      WHERE time_building_block_id = tc_id_tab(i)
            	        AND object_version_number = tc_ovn_tab(i) ;

            	l_tc_del_count := sql%rowcount;

            	hxc_archive.log_data_mismatch(p_scope => 'Timecard',
            	                              p_insert => l_tc_count,
            	                              p_delete => l_tc_del_count,
            	                              p_mismatch  => data_mismatch
            	                              );
            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Timecard');
                   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	FORALL i IN tc_id_tab.FIRST..tc_id_tab.LAST
       	    	  INSERT INTO hxc_ar_detail_log
       	    	              (time_building_block_id,
       	    	    	       object_version_number,
       	    	    	       process_type,
            	    	       thread_id,
            	    	       chunk_number)
       	    	       VALUES (tc_id_tab(i),
       	    	               tc_ovn_tab(i),
       	    	               'ARCHIVE',
       	    	               p_thread_id,
       	    	               l_chunk_no);


            	INSERT INTO hxc_temp_timecard_chunks
            	      ( id,
            	        scope,
            	        ref_rowid,
            	        thread_id )
            	SELECT /*+ ORDERED */
            	      DISTINCT talbkup.application_period_id,
            	               'APPLICATION_PERIOD',
            	               ROWIDTOCHAR(talbkup.ROWID),
            	               thread_id
	    	  FROM hxc_temp_timecard_chunks temp,
	    	       hxc_tc_ap_links talbkup
	    	 WHERE temp.id = talbkup.timecard_id
	    	   AND temp.scope IN ('TIMECARD')
	    	   AND thread_id = p_thread_id ;


	    	INSERT INTO hxc_tc_ap_links_ar
	    	     ( timecard_id,
	    	       application_period_id)
	    	SELECT timecard_id,
	    	       application_period_id
	    	  FROM hxc_temp_timecard_chunks temp,
	    	       hxc_tc_ap_links talbkup
	    	 WHERE temp.ref_rowid = talbkup.ROWID
	    	   AND temp.scope = ('APPLICATION_PERIOD')
	    	   AND thread_id = p_thread_id ;


	    	l_tal_count := SQL%ROWCOUNT;


   	    	DELETE FROM hxc_tc_ap_links
	    	      WHERE ROWID IN ( SELECT CHARTOROWID(ref_rowid)
	    	                         FROM hxc_temp_timecard_chunks
	    	                        WHERE scope = 'APPLICATION_PERIOD'
	    	                          AND thread_id = p_thread_id );

            	l_tal_del_count := SQL%ROWCOUNT;

            	hxc_archive.log_data_mismatch(p_scope => 'TC App LINKs ',
            	                              p_insert => l_tal_count,
            	                              p_delete => l_tal_del_count,
            	                              p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	   write_data_mismatch('TC App LINKs ');
                   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	INSERT INTO hxc_time_building_blocks_ar
	    	      (DATA_SET_ID,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
	    	       UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
	 	       SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	 	       LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,
	 	       RESOURCE_TYPE,APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,
	 	       PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,TRANSLATION_DISPLAY_KEY)
	    	SELECT /*+ ORDERED */
	    	       p_data_set_id,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
	    	       UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
	    	       appbkup.SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	    	       LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,RESOURCE_TYPE,
	    	       APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,PARENT_BUILDING_BLOCK_OVN,
	    	       APPLICATION_SET_ID,TRANSLATION_DISPLAY_KEY
	    	  FROM hxc_time_building_blocks appbkup
	    	 WHERE appbkup.scope = 'APPLICATION_PERIOD'
	 	   AND appbkup.time_building_block_id IN ( SELECT id
            	                                             FROM hxc_temp_timecard_chunks temp
            	                                            WHERE temp.scope IN
            	                                                       ('APPLICATION_PERIOD')
            	                                              AND thread_id = p_thread_id ) ;

	    	l_app_period_count := SQL%ROWCOUNT;

	    	DELETE FROM hxc_time_building_blocks
	    	      WHERE time_building_block_id IN ( SELECT id
	    	                                          FROM hxc_temp_timecard_chunks
	    	                                         WHERE scope IN
            	                                                      ('APPLICATION_PERIOD')
            	                                           AND thread_id = p_thread_id );

            	l_app_del_count := SQL%ROWCOUNT;

            	hxc_archive.log_data_mismatch( p_scope => 'Application Period ',
            	                               p_insert => l_app_period_count,
            	                               p_delete => l_app_del_count,
            	                               p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	    write_data_mismatch('Application Period ');
            	    EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	INSERT INTO hxc_app_period_summary_ar
            	           (APPLICATION_PERIOD_ID,APPLICATION_PERIOD_OVN,APPROVAL_STATUS,TIME_RECIPIENT_ID,
            	            TIME_CATEGORY_ID,START_TIME,STOP_TIME,RESOURCE_ID,RECIPIENT_SEQUENCE,
            	            CATEGORY_SEQUENCE,CREATION_DATE,NOTIFICATION_STATUS,APPROVER_ID,APPROVAL_COMP_ID,
            	            APPROVAL_ITEM_TYPE,APPROVAL_PROCESS_NAME,APPROVAL_ITEM_KEY,DATA_SET_ID)
	    	     SELECT APPLICATION_PERIOD_ID,APPLICATION_PERIOD_OVN,APPROVAL_STATUS,
	    	            TIME_RECIPIENT_ID,TIME_CATEGORY_ID,START_TIME,STOP_TIME,RESOURCE_ID,
	    	            RECIPIENT_SEQUENCE,CATEGORY_SEQUENCE,CREATION_DATE,NOTIFICATION_STATUS,
	    	            APPROVER_ID,APPROVAL_COMP_ID,APPROVAL_ITEM_TYPE,APPROVAL_PROCESS_NAME,
	    	            APPROVAL_ITEM_KEY,p_data_set_id
	    	       FROM hxc_app_period_summary apsbkup
	    	      WHERE application_period_id IN (SELECT id
	    	                                        FROM hxc_temp_timecard_chunks
	    	                                       WHERE scope = 'APPLICATION_PERIOD'
	    	                                         AND thread_id = p_thread_id );

            	l_app_period_sum_count := SQL%ROWCOUNT;


            	DELETE FROM hxc_app_period_summary
            	      WHERE application_period_id IN (SELECT id
            	                                        FROM hxc_temp_timecard_chunks
            	     	                               WHERE scope = 'APPLICATION_PERIOD'
            	    	                                 AND thread_id = p_thread_id );

            	l_app_sum_del_count := SQL%ROWCOUNT;

            	hxc_archive.log_data_mismatch( p_scope => 'App Period Summary ',
            	                               p_insert => l_app_period_sum_count,
            	                               p_delete => l_app_sum_del_count,
            	                               p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	    write_data_mismatch('App Period Summary ');
            	    EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	INSERT INTO hxc_temp_timecard_chunks
            	             ( id,
            	               ref_ovn,
            	               scope,
            	               ref_rowid,
            	               day_start_time,
            	               day_stop_time,
            	               thread_id )
            	     SELECT /*+ LEADING(TEMP) INDEX(AR HXC_TIME_BUILDING_BLOCKS_FK3) */
            	               time_building_block_id,
            	               object_version_number,
            	               'DAY',
            	               ROWIDTOCHAR(ar.ROWID),
            	               ar.start_time,
            	               ar.stop_time,
            	               thread_id
            	          FROM hxc_temp_timecard_chunks temp,
            	               hxc_time_building_blocks ar
            	         WHERE parent_building_block_id = temp.id
            	           AND parent_building_block_ovn = temp.ref_ovn
            	           AND temp.scope = 'TIMECARD'
            	           AND thread_id = p_thread_id ;


            	INSERT INTO hxc_time_building_blocks_ar
            	           (DATA_SET_ID,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
	 		    UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
	 		    SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	 		    LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,
	 		    RESOURCE_TYPE,APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,
	 		    PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,TRANSLATION_DISPLAY_KEY)
	    	     SELECT /*+ LEADING(temp) NO_INDEX(bkupday)*/
	    	            p_data_set_id,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
	    	            UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
	 		    bkupday.SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	 		    LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,RESOURCE_TYPE,
	 		    APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,
	 		    TRANSLATION_DISPLAY_KEY
	    	       FROM hxc_temp_timecard_chunks temp,
	    	            hxc_time_building_blocks bkupday
	    	      WHERE bkupday.ROWID = CHARTOROWID(temp.ref_rowid)
	    	        AND temp.scope = 'DAY'
	    	        AND thread_id = p_thread_id;


            	l_day_count := sql%rowcount;

            	l_day_del_count := 0;
            	OPEN get_tbb_rowid('DAY');
	    	LOOP
            	    FETCH get_tbb_rowid
	    	     BULK COLLECT INTO
	    	               rowid_tab  LIMIT 501;

	    	    EXIT WHEN rowid_tab.COUNT = 0;

	    	    FORALL i IN rowid_tab.FIRST..rowid_tab.LAST
	    	       DELETE FROM hxc_time_building_blocks
	    	             WHERE ROWID = CHARTOROWID(rowid_tab(i));

            	     l_day_del_count := l_day_del_count + SQL%ROWCOUNT;
            	     rowid_tab.DELETE;
            	END LOOP;
            	CLOSE get_tbb_rowid;

            	hxc_archive.log_data_mismatch( p_scope => 'Day ',
            	                               p_insert => l_day_count,
            	                               p_delete => l_day_del_count,
            	                               p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Day ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	INSERT INTO hxc_temp_timecard_chunks
            	               ( id,
            	                 ref_ovn,
            	                 scope,
            	                 day_start_time,
            	                 day_stop_time,
            	                 ref_rowid,
            	                 thread_id )
            	      SELECT /*+ LEADING(TEMP) INDEX(AR HXC_TIME_BUILDING_BLOCKS_FK3) */
            	             time_building_block_id,
            	             object_version_number,
            	             'DETAIL',
            	             nvl(day_start_time,ar.start_time),
            	             nvl(day_stop_time,ar.stop_time),
            	             ROWIDTOCHAR(ar.ROWID),
            	             thread_id
            	        FROM hxc_temp_timecard_chunks temp,
            	             hxc_time_building_blocks ar
            	       WHERE parent_building_block_id = temp.id
            	         AND parent_building_block_ovn = temp.ref_ovn
            	         AND temp.scope = 'DAY'
            	         AND thread_id = p_thread_id ;


            	INSERT INTO hxc_time_building_blocks_ar
            	           (DATA_SET_ID,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
	 		    UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
	 		    SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	 		    LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,
	 		    RESOURCE_TYPE,APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,
	 		    PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,TRANSLATION_DISPLAY_KEY)
	    	     SELECT /*+ LEADING(temp) NO_INDEX(bkupday)*/
	    	            p_data_set_id,TIME_BUILDING_BLOCK_ID,TYPE,MEASURE,
	    	            UNIT_OF_MEASURE,START_TIME,STOP_TIME,PARENT_BUILDING_BLOCK_ID,
	 		    bkupday.SCOPE,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,
	 		    LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,APPROVAL_STATUS,RESOURCE_ID,RESOURCE_TYPE,
	 		    APPROVAL_STYLE_ID,DATE_FROM,DATE_TO,COMMENT_TEXT,PARENT_BUILDING_BLOCK_OVN,APPLICATION_SET_ID,
	 		    TRANSLATION_DISPLAY_KEY
	    	       FROM hxc_temp_timecard_chunks temp,
	    	            hxc_time_building_blocks bkupday
	    	      WHERE bkupday.ROWID = CHARTOROWID(temp.ref_rowid)
	    	        AND temp.scope = 'DETAIL'
	    	        AND thread_id = p_thread_id ;

            	l_det_count := sql%rowcount;

            	l_det_del_count := 0;
            	OPEN get_tbb_rowid('DETAIL');
            	LOOP
	    	   FETCH get_tbb_rowid
	  		  BULK COLLECT INTO
	  		        rowid_tab LIMIT 501;

	  		 EXIT WHEN rowid_tab.COUNT = 0;

	  		 FORALL i IN rowid_tab.FIRST..rowid_tab.LAST
	  		     DELETE FROM hxc_time_building_blocks
	  		           WHERE ROWID = CHARTOROWID(rowid_tab(i));

            	   l_det_del_count := l_det_del_count + SQL%ROWCOUNT;
          		 rowid_tab.DELETE;
            	END LOOP;
            	CLOSE get_tbb_rowid;

            	hxc_archive.log_data_mismatch( p_scope => 'Detail ',
            	                              p_insert => l_det_count,
            	                              p_delete => l_det_del_count,
            	                              p_mismatch => data_mismatch );
            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Detail ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	l_td_count        := 0;
            	l_td_del_count    := 0;
            	l_trans_count     := 0;
            	l_trans_del_count := 0;

                IF get_transactions%ISOPEN
                THEN
                   CLOSE get_transactions;
                END IF;
            	OPEN get_transactions ;
            	LOOP
            	    FETCH get_transactions
            	     BULK COLLECT INTO trans_detail_tab,
            	                       trans_tab,
            	                       td_rowid_tab LIMIT 250;

            	    EXIT WHEN trans_detail_tab.COUNT = 0 ;

            	    FORALL i IN trans_detail_tab.FIRST..trans_detail_tab.LAST
            	       INSERT INTO hxc_archive_temp
            	                 ( detail_id,
            	                   master_id,
            	                   ref_rowid,
            	                   thread_id )
            	           VALUES ( trans_detail_tab(i),
            	                    trans_tab(i),
            	                    td_rowid_tab(i),
            	                    p_thread_id );

            	    INSERT INTO hxc_transaction_details_ar
            	               (DATA_SET_ID,TRANSACTION_DETAIL_ID,TIME_BUILDING_BLOCK_ID,TRANSACTION_ID,
            		        STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
            		        LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_BUILDING_BLOCK_OVN)
            	         SELECT /*+ LEADING(temp) USE_NL(bkuptxnd) */
            	                p_data_set_id,TRANSACTION_DETAIL_ID,TIME_BUILDING_BLOCK_ID,TRANSACTION_ID,
            		   	STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
            		   	LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_BUILDING_BLOCK_OVN
            	           FROM hxc_archive_temp temp,
            	                hxc_transaction_details bkuptxnd
            	          WHERE CHARTOROWID(temp.ref_rowid) = bkuptxnd.ROWID
            	            AND thread_id  = p_thread_id ;

            	    l_td_count := l_td_count + SQL%ROWCOUNT;

            	    FORALL i IN td_rowid_tab.FIRST..td_rowid_tab.LAST
            	       DELETE FROM hxc_transaction_details
            	             WHERE ROWID = CHARTOROWID(td_rowid_tab(i));

            	    l_td_del_count := l_td_del_count + SQL%ROWCOUNT;

            	    trans_detail_tab.DELETE;
            	    trans_tab.DELETE;
            	    td_rowid_tab.DELETE;

            	    OPEN get_dup_trans;
            	    LOOP
            	       FETCH get_dup_trans
            	        BULK COLLECT INTO trans_id_tab,
            	                          uniq_rowid_tab LIMIT 500;

            	       EXIT WHEN trans_id_tab.COUNT = 0;

            	       FORALL i IN trans_id_tab.FIRST..trans_id_tab.LAST
            	           DELETE FROM hxc_archive_temp
            	                 WHERE master_id = trans_id_tab(i)
            	                   AND ROWID <> uniq_rowid_tab(i)
            	                   AND thread_id = p_thread_id ;
            	    END LOOP;
            	    CLOSE get_dup_trans;

            	    DELETE FROM hxc_archive_temp
            	          WHERE EXISTS ( SELECT 1
            	                           FROM hxc_transactions_ar
            	                          WHERE transaction_id = master_id )
            	            AND thread_id = p_thread_id ;

                  -- Bug 8888813
                  -- If the upgrade for Deposit Transaction is not completed,
                  -- ( Bug 8888811 ), hxc_transactions and hxc_transaction_details
                  -- might still contain DEPOSIT transactions. Process them.
                  IF NOT hxc_upgrade_pkg.txn_upgrade_completed
                  THEN

            	        INSERT INTO hxc_transactions_ar
            	                  (DATA_SET_ID,TRANSACTION_ID,TRANSACTION_PROCESS_ID,TRANSACTION_DATE,TYPE,
            	                   STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
                	               LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TRANSACTION_CODE)
                	        SELECT /*+ LEADING(temp) USE_NL(bkuptxn) */
                	               p_data_set_id,TRANSACTION_ID,TRANSACTION_PROCESS_ID,
                	  	       TRANSACTION_DATE,TYPE,STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,
            	      	       CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,
            	  	           TRANSACTION_CODE
                	         FROM hxc_transactions bkuptxn,
                	              hxc_archive_temp temp
                	        WHERE transaction_id = master_id
                	          AND thread_id = p_thread_id
            	              AND transaction_id NOT IN ( SELECT transaction_id
            	                                            FROM hxc_transactions_ar hxc
            	                                           WHERE bkuptxn.transaction_id = hxc.transaction_id)
                	          AND type <> 'RETRIEVAL'
                	          ;

                	    l_trans_count := l_trans_count + SQL%ROWCOUNT;

                	    DELETE /*+ LEADING(temp) USE_NL(bkuptxn) */
                	           FROM hxc_transactions  bkuptxn
                	          WHERE transaction_id IN ( SELECT master_id
            	                                          FROM hxc_archive_temp temp
            	                                         WHERE thread_id = p_thread_id)
            	                AND type <> 'RETRIEVAL';

                	    l_trans_del_count := l_trans_del_count + SQL%ROWCOUNT;

                  END IF;

            	    INSERT INTO hxc_ar_trans_temp
            	                ( transaction_id, data_set_id, thread_id, trans_rowid )
            	         SELECT bkuptxn.transaction_id,
            	                p_data_set_id,
            	                p_thread_id,
            	                ROWIDTOCHAR(bkuptxn.ROWID)
            	           FROM hxc_transactions bkuptxn,
            	                hxc_archive_temp temp
            	          WHERE transaction_id = master_id
            	            AND thread_id = p_thread_id
            	            AND type = 'RETRIEVAL';

            	    DELETE FROM hxc_archive_temp
            	          WHERE thread_id = p_thread_id ;

            	END LOOP;
            	CLOSE get_transactions;

            	hxc_archive.log_data_mismatch( p_scope => 'Transaction Detail ',
            	                               p_insert => l_td_count,
            	                               p_delete => l_td_del_count,
            	                               p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Transaction Detail ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

              -- Bug 8888813
              -- Need to report Transactions here only if Txn upgrade is not completed.
              -- If it is completed, Deposit transactions are moved later, and RETRIEVAL
              -- transactions are moved in the PARENT process -- No transactions to move here
              -- so dont report anything unless required.
              IF NOT hxc_upgrade_pkg.txn_upgrade_completed
               AND  (  l_trans_count <> 0
                    OR l_trans_del_count <> 0 )
              THEN

            	   hxc_archive.log_data_mismatch( p_scope => 'Transaction ',
            	                                  p_insert => l_trans_count,
            	                                  p_delete => l_trans_del_count,
            	                                  p_mismatch => data_mismatch );

            	   IF data_mismatch
            	   THEN
            	      write_data_mismatch('Transaction ');
            	      EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	   END IF;

            	END IF;

            	l_td_count        := 0;
            	l_td_del_count    := 0;
            	l_trans_count     := 0;
            	l_trans_del_count := 0;


                -- Bug 8888813
                -- Open the deposit transaction tables to move DEPOSIT transactions.
                -- Process the Details and Master
                -- Log the data capture.
                IF get_dep_transactions%ISOPEN
                THEN
                   CLOSE get_dep_transactions;
                END IF;
            	OPEN get_dep_transactions ;
            	LOOP
            	    FETCH get_dep_transactions
            	     BULK COLLECT INTO trans_detail_tab,
            	                       trans_tab,
            	                       td_rowid_tab LIMIT 250;

            	    EXIT WHEN trans_detail_tab.COUNT = 0 ;

            	    FORALL i IN trans_detail_tab.FIRST..trans_detail_tab.LAST
            	       INSERT INTO hxc_archive_temp
            	                 ( detail_id,
            	                   master_id,
            	                   ref_rowid,
            	                   thread_id )
            	           VALUES ( trans_detail_tab(i),
            	                    trans_tab(i),
            	                    td_rowid_tab(i),
            	                    p_thread_id );

            	    INSERT INTO hxc_dep_txn_details_ar
            	               (DATA_SET_ID,TRANSACTION_DETAIL_ID,TIME_BUILDING_BLOCK_ID,TRANSACTION_ID,
            		        STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
            		        LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_BUILDING_BLOCK_OVN)
            	         SELECT /*+ LEADING(temp) USE_NL(bkuptxnd) */
            	                p_data_set_id,TRANSACTION_DETAIL_ID,TIME_BUILDING_BLOCK_ID,TRANSACTION_ID,
            		   	STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
            		   	LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TIME_BUILDING_BLOCK_OVN
            	           FROM hxc_archive_temp temp,
            	                hxc_dep_transaction_details bkuptxnd
            	          WHERE CHARTOROWID(temp.ref_rowid) = bkuptxnd.ROWID
            	            AND thread_id  = p_thread_id ;

            	    l_td_count := l_td_count + SQL%ROWCOUNT;

            	    FORALL i IN td_rowid_tab.FIRST..td_rowid_tab.LAST
            	       DELETE FROM hxc_dep_transaction_details
            	             WHERE ROWID = CHARTOROWID(td_rowid_tab(i));

            	    l_td_del_count := l_td_del_count + SQL%ROWCOUNT;

            	    trans_detail_tab.DELETE;
            	    trans_tab.DELETE;
            	    td_rowid_tab.DELETE;

            	    OPEN get_dup_trans;
            	    LOOP
            	       FETCH get_dup_trans
            	        BULK COLLECT INTO trans_id_tab,
            	                          uniq_rowid_tab LIMIT 500;

            	       EXIT WHEN trans_id_tab.COUNT = 0;

            	       FORALL i IN trans_id_tab.FIRST..trans_id_tab.LAST
            	           DELETE FROM hxc_archive_temp
            	                 WHERE master_id = trans_id_tab(i)
            	                   AND ROWID <> uniq_rowid_tab(i)
            	                   AND thread_id = p_thread_id ;
            	    END LOOP;
            	    CLOSE get_dup_trans;

            	    DELETE FROM hxc_archive_temp
            	          WHERE EXISTS ( SELECT 1
            	                           FROM hxc_dep_transactions_ar
            	                          WHERE transaction_id = master_id )
            	            AND thread_id = p_thread_id ;

            	    INSERT INTO hxc_dep_transactions_ar
            	              (DATA_SET_ID,TRANSACTION_ID,TRANSACTION_PROCESS_ID,TRANSACTION_DATE,TYPE,
            	               STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,CREATED_BY,CREATION_DATE,
            	               LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,TRANSACTION_CODE)
            	        SELECT /*+ LEADING(temp) USE_NL(bkuptxn) */
            	               p_data_set_id,TRANSACTION_ID,TRANSACTION_PROCESS_ID,
            	  	       TRANSACTION_DATE,TYPE,STATUS,EXCEPTION_DESCRIPTION,OBJECT_VERSION_NUMBER,
            	  	       CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,
            	  	       TRANSACTION_CODE
            	         FROM hxc_dep_transactions bkuptxn,
            	              hxc_archive_temp temp
            	        WHERE transaction_id = master_id
            	          AND thread_id = p_thread_id
            	          AND transaction_id NOT IN ( SELECT transaction_id
            	                                        FROM hxc_dep_transactions_ar hxc
            	                                       WHERE bkuptxn.transaction_id = hxc.transaction_id)
            	          ;

            	    l_trans_count := l_trans_count + SQL%ROWCOUNT;

            	    DELETE /*+ LEADING(temp) USE_NL(bkuptxn) */
            	           FROM hxc_dep_transactions  bkuptxn
            	          WHERE transaction_id IN ( SELECT master_id
            	                                      FROM hxc_archive_temp temp
            	                                     WHERE thread_id = p_thread_id) ;

            	    l_trans_del_count := l_trans_del_count + SQL%ROWCOUNT;

            	    DELETE FROM hxc_archive_temp
            	          WHERE thread_id = p_thread_id ;

            	END LOOP;
            	CLOSE get_dep_transactions;

            	hxc_archive.log_data_mismatch( p_scope => 'Deposit Transaction Detail ',
            	                               p_insert => l_td_count,
            	                               p_delete => l_td_del_count,
            	                               p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Deposit Transaction Detail ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	hxc_archive.log_data_mismatch( p_scope => 'Deposit Transaction ',
            	                               p_insert => l_trans_count,
            	                               p_delete => l_trans_del_count,
            	                               p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Deposit Transaction ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;









            	l_tau_count := 0;
            	l_tau_del_count := 0;
            	l_ta_count := 0;
            	l_ta_del_count := 0;
            	IF get_attributes%ISOPEN
                THEN
                   CLOSE get_attributes;
                END IF;
            	OPEN get_attributes;
            	LOOP
            	    FETCH get_attributes
            	     BULK COLLECT INTO usage_tab,
            	                      attribute_tab,
            	                      usage_rowid_tab LIMIT 250;

            	    EXIT WHEN usage_tab.COUNT = 0;


            	    FORALL i IN usage_tab.FIRST..usage_tab.LAST
            	      INSERT INTO hxc_archive_temp
            	               ( detail_id,
            	                 master_id,
            	                 ref_rowid,
            	                 thread_id)
            	         VALUES ( usage_tab(i),
            	                  attribute_tab(i),
            	                  usage_rowid_tab(i),
            	                  p_thread_id );


            	    INSERT INTO hxc_time_attribute_usages_ar
            	              (DATA_SET_ID,TIME_ATTRIBUTE_USAGE_ID,TIME_ATTRIBUTE_ID,TIME_BUILDING_BLOCK_ID,
	    	               CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,
	    	               OBJECT_VERSION_NUMBER,TIME_BUILDING_BLOCK_OVN)
            	          SELECT /*+ LEADING(temp) USE_NL(bkuptau) */
            	                 p_data_set_id,TIME_ATTRIBUTE_USAGE_ID,TIME_ATTRIBUTE_ID,TIME_BUILDING_BLOCK_ID,
	    	                 CREATED_BY,CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,LAST_UPDATE_LOGIN,
	    	                 OBJECT_VERSION_NUMBER,TIME_BUILDING_BLOCK_OVN
	    	            FROM hxc_archive_temp temp,
            	                 hxc_time_attribute_usages bkuptau
            	           WHERE bkuptau.ROWID = CHARTOROWID(temp.ref_rowid)
            	             AND thread_id   = p_thread_id ;

            	    l_tau_count := l_tau_count + SQL%ROWCOUNT;

            	    FORALL i IN usage_rowid_tab.FIRST..usage_rowid_tab.LAST
            	        DELETE FROM hxc_time_attribute_usages
            	              WHERE ROWID = CHARTOROWID(usage_rowid_tab(i)) ;

            	    l_tau_del_count := l_tau_del_count + SQL%ROWCOUNT;

            	    DELETE FROM hxc_archive_temp
            	          WHERE EXISTS ( SELECT 1
            	                           FROM hxc_time_attributes_ar
            	                          WHERE time_attribute_id = master_id )
            	            AND thread_id = p_thread_id ;

            	    INSERT INTO hxc_time_attributes_ar
            	             (ATTRIBUTE15,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,ATTRIBUTE21,
            	 	      ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25,ATTRIBUTE26,ATTRIBUTE27,ATTRIBUTE28,
            	 	      ATTRIBUTE29,ATTRIBUTE30,BLD_BLK_INFO_TYPE_ID,OBJECT_VERSION_NUMBER,TIME_ATTRIBUTE_ID,
            	 	      ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,
            	 	      ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,
            	 	      ATTRIBUTE14,CONSOLIDATED_FLAG,DATA_SET_ID)
            	        SELECT /*+ LEADING(temp) USE_NL(bkupta) */
            	               ATTRIBUTE15,ATTRIBUTE16,ATTRIBUTE17,ATTRIBUTE18,ATTRIBUTE19,ATTRIBUTE20,ATTRIBUTE21,
            	               ATTRIBUTE22,ATTRIBUTE23,ATTRIBUTE24,ATTRIBUTE25,ATTRIBUTE26,ATTRIBUTE27,ATTRIBUTE28,
            	 	       ATTRIBUTE29,ATTRIBUTE30,BLD_BLK_INFO_TYPE_ID,OBJECT_VERSION_NUMBER,TIME_ATTRIBUTE_ID,
            	 	       ATTRIBUTE_CATEGORY,ATTRIBUTE1,ATTRIBUTE2,ATTRIBUTE3,ATTRIBUTE4,ATTRIBUTE5,ATTRIBUTE6,
            	 	       ATTRIBUTE7,ATTRIBUTE8,ATTRIBUTE9,ATTRIBUTE10,ATTRIBUTE11,ATTRIBUTE12,ATTRIBUTE13,
            	 	       ATTRIBUTE14,null,p_data_set_id
            	          FROM hxc_time_attributes bkupta
            	         WHERE bkupta.time_attribute_id in ( SELECT /*+ NO_INDEX(temp) */
            	                                                    master_id
            	                                               FROM hxc_archive_temp temp
            	                                              WHERE thread_id = p_thread_id );

            	    l_ta_count := l_ta_count + SQL%ROWCOUNT;

            	    DELETE /*+ LEADING(temp) USE_NL(bkupta) */
            	           FROM hxc_time_attributes bkupta
            	          WHERE time_attribute_id IN ( SELECT /*+ NO_INDEX(temp) */
            	                                              master_id
            	                                         FROM hxc_archive_temp temp
            	                                        WHERE thread_id = p_thread_id ) ;

            	    l_ta_del_count := l_ta_del_count + SQL%ROWCOUNT;

            	    usage_tab.DELETE;
            	    attribute_tab.DELETE;
            	    usage_rowid_tab.DELETE;

            	    DELETE FROM hxc_archive_temp
            	          WHERE thread_id = p_thread_id ;

            	END LOOP ;
            	CLOSE get_attributes;

            	hxc_archive.log_data_mismatch( p_scope => 'Attribute Usages ',
            	                               p_insert => l_tau_count,
            	                               p_delete => l_tau_del_count,
            	                               p_mismatch => data_mismatch );
            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Attribute Usages ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	hxc_archive.log_data_mismatch( p_scope => 'Attributes ',
            	                               p_insert => l_ta_count,
            	                               p_delete => l_ta_del_count,
            	                               p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	   write_data_mismatch('Attributes ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	DELETE FROM hxc_temp_timecard_chunks
            	      WHERE scope IN ( 'TIMECARD', 'DAY','APPLICATION_PERIOD')
            	        AND thread_id = p_thread_id ;


            	INSERT INTO hxc_ap_detail_links_ar
            	            (application_period_id,
            	             time_building_block_id,
            	             time_building_block_ovn)
            	     SELECT application_period_id, time_building_block_id, time_building_block_ovn
            	       FROM hxc_temp_timecard_chunks temp,
            	            hxc_ap_detail_links adlbkup
	    	      WHERE temp.id = adlbkup.time_building_block_id
            	        AND temp.ref_ovn = adlbkup.time_building_block_ovn
		    AND temp.scope = ('DETAIL')
		    AND thread_id = p_thread_id ;

            	l_adl_count := SQL%ROWCOUNT;


            	DELETE FROM hxc_ap_detail_links
            	      WHERE (time_building_block_id,time_building_block_ovn)
            	                                    IN ( SELECT id,
            	                                                ref_ovn
            	                                           FROM hxc_temp_timecard_chunks
            	                                          WHERE scope = 'DETAIL'
            	                                            AND thread_id = p_thread_id );

            	l_adl_del_count := SQL%ROWCOUNT;

            	hxc_archive.log_data_mismatch( p_scope => 'App Detail LINKs ',
            	                                p_insert => l_adl_count,
            	                                p_delete => l_adl_del_count,
            	                                p_mismatch => data_mismatch );

            	IF data_mismatch
            	THEN
            	   write_data_mismatch('App Detail LINKs ');
            	   EXIT TO_CONTINUE_TO_NEXT_CHUNK ;
            	END IF;

            	OPEN get_latest_details;
            	LOOP
            	   FETCH get_latest_details
            	    BULK COLLECT INTO latest_id_tab,
            	                      latest_rowid_tab LIMIT 500;
            	   EXIT WHEN latest_id_tab.COUNT = 0;
            	   FORALL i IN latest_id_Tab.FIRST..latest_id_Tab.last
            	      DELETE FROM hxc_latest_details
            	           WHERE ROWID = CHARTOROWID(latest_rowid_tab(i)) ;

            	   latest_rowid_tab.DELETE;
            	   latest_id_tab.DELETE;
            	END LOOP;
            	CLOSE get_latest_details;


            	fnd_file.put_line(fnd_file.log,' ');
       	    	fnd_file.put_line(fnd_file.log,' ');
       	    	fnd_file.put_line(fnd_file.log,'========================================================== ');
       	    	fnd_file.put_line(fnd_file.log,' ');
       	    	fnd_file.put_line(fnd_file.log,' ');
            	COMMIT;
            	tc_id_tab.DELETE;
            	tc_ovn_tab.DELETE;
            	iloop:= 0;
            	EXCEPTION
            	  WHEN DUP_VAL_ON_INDEX THEN
            	     ROLLBACK;
            	     iloop := 1;
            	     fnd_file.put_line(fnd_file.LOG,'This chunk found a resource contention, will sleep for a minute ');
   	             fnd_file.put_line(fnd_file.log,'=================================================================');
	             fnd_file.put_line(fnd_file.log,'Reprocessing this chunk ');
	             fnd_file.put_line(fnd_file.log,'==================================================================');
            	     l_td_count := 0;
            	     l_trans_count := 0;
            	     l_tau_count := 0;
            	     l_ta_count  := 0;
            	     data_mismatch := FALSE;
            	     dbms_lock.sleep(60);
                  WHEN DEADLOCK_DETECTED THEN
                     ROLLBACK;
                     iloop := 1;
                     fnd_file.put_line(fnd_file.LOG,'This chunk found a resource contention(deadlock), will sleep for a minute ');
   	             fnd_file.put_line(fnd_file.log,'=================================================================');
	             fnd_file.put_line(fnd_file.log,'Reprocessing this chunk ');
	             fnd_file.put_line(fnd_file.log,'==================================================================');
                     l_td_count := 0;
                     l_trans_count := 0;
                     l_tau_count := 0;
                     l_ta_count  := 0;
                     data_mismatch := FALSE;
                     dbms_lock.sleep(60);
            END ;
        END LOOP TO_CONTINUE_TO_NEXT_CHUNK ;

    END LOOP;

END child_archive_process;



PROCEDURE log_data_mismatch( p_scope      IN VARCHAR2,
                             p_insert     IN NUMBER,
                             p_delete     IN NUMBER,
                             p_mismatch   IN OUT NOCOPY BOOLEAN)
IS

BEGIN
    IF p_insert = p_delete
    THEN
       fnd_file.put_line(fnd_file.log,' ');
       fnd_file.put_line(fnd_file.log,' '||p_scope||' records moved : '||p_insert);
    ELSE
       fnd_file.put_line(fnd_file.log,' ');
       fnd_file.put_line(fnd_file.log,'==========================================================================');
       fnd_file.put_line(fnd_file.log,'  An error occured while processing '||p_scope||' records');
       fnd_file.put_line(fnd_file.log,'==========================================================================');
       fnd_file.put_line(fnd_file.log, p_insert||' records were inserted into offline table ');
       fnd_file.put_line(fnd_file.log, p_delete||' records were deleted from online table ');
       fnd_file.put_line(fnd_file.log,'This chunk is rolled back, pls check up data. ');
       p_mismatch := TRUE;
       ROLLBACK;
    END IF;

    RETURN;
END log_data_mismatch ;


END hxc_archive;

/
