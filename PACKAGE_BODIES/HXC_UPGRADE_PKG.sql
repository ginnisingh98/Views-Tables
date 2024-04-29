--------------------------------------------------------
--  DDL for Package Body HXC_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_UPGRADE_PKG" 
/* $Header: hxcupgpkg.pkb 120.0.12010000.8 2010/05/03 11:56:14 amakrish noship $ */
AS

PROCEDURE upgrade( errbuff         OUT NOCOPY VARCHAR2,
                   retcode         OUT NOCOPY NUMBER,
                   p_type          IN VARCHAR2,
                   p_stop_after    IN NUMBER DEFAULT -999,
                   p_num_workers   IN NUMBER DEFAULT -1)
IS

   l_request_id   NUMBER;

   CURSOR get_status (c_upg_type varchar2)
       IS SELECT status
          FROM hxc_upgrade_definitions
         WHERE upg_type = c_upg_type;

   CURSOR get_id
       IS SELECT /*+ FIRST_ROWS */
                 time_building_block_id
            FROM hxc_latest_details
           WHERE org_id IS NULL
           ORDER BY 1;

-- Start

   CURSOR get_dep_txn_id
       IS SELECT transaction_id
            FROM hxc_transactions
           WHERE type = 'DEPOSIT'
           ORDER BY 1 asc;
-- End


   -- Bug 9394446
   -- Added application Set condition

   -- Cursor to pick up Payroll's details which are not there in hxc_pay_latest_details.
   CURSOR get_pay_detail_ids(p_retr_id   IN   NUMBER)
       IS SELECT hld.time_building_block_id
            FROM hxc_latest_details hld
           WHERE NOT EXISTS ( SELECT 1
                                FROM hxc_transaction_details htd,
                                     hxc_transactions ht
                               WHERE hld.time_building_block_id = htd.time_building_block_id
                                 AND hld.object_version_number  = htd.time_building_block_ovn
                                 AND htd.status = 'SUCCESS'
                                 AND htd.transaction_id = ht.transaction_id
                                 AND ht.type = 'RETRIEVAL'
                                 AND ht.status = 'SUCCESS'
                                 AND ht.transaction_process_id IN (p_retr_id, -1))
             AND NOT EXISTS ( SELECT 1
                                FROM hxc_pay_latest_details hpl
                               WHERE hpl.time_building_block_id = hld.time_building_block_id
                                 AND hpl.object_version_number  = hld.object_version_number)
             AND hld.application_set_id IN ( SELECT application_set_id
  	                                       FROM hxc_application_set_comps_v
					      WHERE time_recipient_name = 'Payroll')
          ORDER BY hld.time_building_block_id                  ;

   -- Bug 9394446
   -- Added application Set condition
   CURSOR get_pa_detail_ids(p_retr_id   IN   NUMBER)
       IS SELECT hld.time_building_block_id
            FROM hxc_latest_details hld
           WHERE NOT EXISTS ( SELECT 1
                                FROM hxc_transaction_details htd,
                                     hxc_transactions ht
                               WHERE hld.time_building_block_id = htd.time_building_block_id
                                 AND hld.object_version_number  = htd.time_building_block_ovn
                                 AND htd.status = 'SUCCESS'
                                 AND htd.transaction_id = ht.transaction_id
                                 AND ht.type = 'RETRIEVAL'
                                 AND ht.status = 'SUCCESS'
                                 AND ht.transaction_process_id = p_retr_id)
            AND NOT EXISTS ( SELECT 1
                                FROM hxc_pa_latest_details hpl
                               WHERE hpl.time_building_block_id = hld.time_building_block_id
                                 AND hpl.object_version_number  = hld.object_version_number)
            AND hld.application_set_id IN ( SELECT application_set_id
                                              FROM hxc_application_set_comps_v
     				             WHERE time_recipient_name = 'Projects')
         ORDER BY hld.time_building_block_id                        ;





   l_min_id   NUMBER;
   l_max_id   NUMBER;
   l_batch_size  NUMBER;

   TYPE NUMBERTABLE IS TABLE OF NUMBER;
   l_id_tab NUMBERTABLE;

   TYPE REQREC IS RECORD
     ( REQUEST_ID    NUMBER,
       start_id      NUMBER,
       end_id        NUMBER);

   TYPE REQTAB IS TABLE OF REQREC INDEX BY BINARY_INTEGER;
   l_reqtab  REQTAB;
   l_ind     BINARY_INTEGER := 0;
   l_count   NUMBER := 0;
   l_req_complete  BOOLEAN := FALSE;

   l_call_status  BOOLEAN ;
   l_interval     NUMBER := 30;
   l_phase        VARCHAR2(30);
   l_status       VARCHAR2(30);
   l_dev_phase    VARCHAR2(30);
   l_dev_status   VARCHAR2(30);
   l_message      VARCHAR2(30);

   l_req          BOOLEAN  := FALSE;
   l_exists       NUMBER := 0;

   l_chunk_size   NUMBER ;
   l_work_limit   BOOLEAN := FALSE;
   l_start_time   DATE;
   l_stop_after   NUMBER;

   l_process_id   NUMBER;

BEGIN
    hr_general.g_data_migrator_mode := 'Y';
    l_start_time := SYSDATE;

    DELETE FROM HXC_UPGRADE_STATUS;

    hr_utility.trace('p_type = '||p_type);

-- Added if -endif

    OPEN get_status(p_type);
    FETCH get_status INTO l_status;

    IF get_status%NOTFOUND
    THEN
	insert_into_upg_defn(p_type);
	l_status := 'INCOMPLETE';
    END IF;

    CLOSE get_status;

    IF l_status = 'COMPLETE'
    THEN
            put_log('++++++++++++++++++++++++++++++++++++++++++++');
            put_log(upgrade_name(p_type)||' is already completed ');
            put_log('++++++++++++++++++++++++++++++++++++++++++++');
            RETURN;
    END IF;

    COMMIT;

    put_log(' ');
    IF p_num_workers <> -1
    THEN
        put_log('----------------------------------------------------------------');
        put_log(' This process would run with '||p_num_workers||' Worker Programs');
        put_log('----------------------------------------------------------------');
    END IF;
    put_log(' ');
    IF p_stop_after <> -999
    THEN
        put_log('----------------------------------------------------------------');
        put_log('This Program would stop processing after '||p_stop_after||' Hours');
        put_log('----------------------------------------------------------------');
    END IF;
    put_log(' ');

    l_chunk_size := NVL(FND_PROFILE.VALUE('HXC_UPGRADE_WORKER_SIZE'),100000);
    put_log('Data Volume size for Worker :'||l_chunk_size);


    IF (p_type = 'LATEST_DETAILS') THEN
      OPEN get_id;
      LOOP
        FETCH get_id
         BULK
         COLLECT INTO l_id_tab
                LIMIT 1000;

        EXIT WHEN l_id_tab.COUNT = 0;

        IF l_count =0
        THEN
           l_ind := l_ind + 1;
           l_reqtab(l_ind).start_id := l_id_tab(l_id_tab.FIRST);
        END IF;

        IF l_id_tab.COUNT < 1000
        THEN
           l_req := TRUE;
        ELSE
           l_req := FALSE;
        END IF;

        l_count := l_count + l_id_tab.COUNT;
        l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);
        IF l_count >= l_chunk_size
        THEN
           l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);

           IF p_stop_after > 0
           THEN
              l_stop_after := GREATEST(p_stop_after - ((SYSDATE-l_start_time)/24),0);
           ELSIF p_stop_after IS NULL
           THEN
              l_stop_after := NULL;
           ELSE
              l_stop_after := 0;
           END IF;

           l_reqtab(l_ind).request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                               ,program     => 'HXCUPGWK'
                                               ,description => NULL
                                               ,sub_request => FALSE
                                               ,argument1   => p_type
                                               ,argument4   => l_stop_after
                                               ,argument2   => l_reqtab(l_ind).start_id ,
                                                argument3   => l_reqtab(l_ind).end_id);
           COMMIT;
           INSERT INTO hxc_upgrade_status
                (parent_id,
                 child_id,
                 child_status)
            VALUES ( FND_GLOBAL.CONC_REQUEST_ID,
                     l_reqtab(l_ind).request_id,
                     'INCOMPLETE');

           COMMIT;
           IF p_num_workers > 0
            AND l_reqtab.COUNT >= p_num_workers
           THEN
              l_work_limit := TRUE;
              EXIT;
           END IF;
           l_count := 0;
        END IF;
      END LOOP;
    END IF;


   IF (p_type = 'RETRIEVAL_PAY')
   THEN

      IF NOT ret_upgrade_completed
      THEN
         put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
         put_log(upgrade_name('LATEST_DETAILS')||' is not completed ');
         put_log(upgrade_name(p_type)||' can be run only after this is complete. ');
         put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
         retcode := 2;
         RETURN;
      END IF;

      l_process_id := get_ret_process_id('BEE Retrieval Process');

      OPEN get_pay_detail_ids(l_process_id);
      LOOP
        FETCH get_pay_detail_ids
         BULK
         COLLECT INTO l_id_tab
                LIMIT 1000;

        EXIT WHEN l_id_tab.COUNT = 0;

        IF l_count =0
        THEN
           l_ind := l_ind + 1;
           l_reqtab(l_ind).start_id := l_id_tab(l_id_tab.FIRST);
        END IF;

        IF l_id_tab.COUNT < 1000
        THEN
           l_req := TRUE;
        ELSE
           l_req := FALSE;
        END IF;

        l_count := l_count + l_id_tab.COUNT;
        l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);
        IF l_count >= l_chunk_size
        THEN
           l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);

           IF p_stop_after > 0
           THEN
              l_stop_after := GREATEST(p_stop_after - ((SYSDATE-l_start_time)/24),0);
           ELSIF p_stop_after IS NULL
           THEN
              l_stop_after := NULL;
           ELSE
              l_stop_after := 0;
           END IF;

           l_reqtab(l_ind).request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                               ,program     => 'HXCUPGWK'
                                               ,description => NULL
                                               ,sub_request => FALSE
                                               ,argument1   => p_type
                                               ,argument4   => l_stop_after
                                               ,argument2   => l_reqtab(l_ind).start_id ,
                                                argument3   => l_reqtab(l_ind).end_id);
           COMMIT;
           INSERT INTO hxc_upgrade_status
                (parent_id,
                 child_id,
                 child_status)
            VALUES ( FND_GLOBAL.CONC_REQUEST_ID,
                     l_reqtab(l_ind).request_id,
                     'INCOMPLETE');

           COMMIT;

           IF p_num_workers > 0
            AND l_reqtab.COUNT >= p_num_workers
           THEN
              l_work_limit := TRUE;
              EXIT;
           END IF;
           l_count := 0;
        END IF;
      END LOOP;
      CLOSE get_pay_detail_ids;
    END IF;


   IF (p_type = 'RETRIEVAL_PA')
   THEN

      IF NOT ret_upgrade_completed
      THEN
         put_log('Generic Upgrade not completed and this upgrade cannot be done now ');
         retcode := 2;
         RETURN;
      END IF;


      l_process_id := get_ret_process_id('Projects Retrieval Process');

      OPEN get_pa_detail_ids(l_process_id);
      LOOP
        FETCH get_pa_detail_ids
         BULK
         COLLECT INTO l_id_tab
                LIMIT 1000;

        EXIT WHEN l_id_tab.COUNT = 0;

        IF l_count =0
        THEN
           l_ind := l_ind + 1;
           l_reqtab(l_ind).start_id := l_id_tab(l_id_tab.FIRST);
        END IF;

        IF l_id_tab.COUNT < 1000
        THEN
           l_req := TRUE;
        ELSE
           l_req := FALSE;
        END IF;

        l_count := l_count + l_id_tab.COUNT;
        l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);
        IF l_count >= l_chunk_size
        THEN
           l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);

           IF p_stop_after > 0
           THEN
              l_stop_after := GREATEST(p_stop_after - ((SYSDATE-l_start_time)/24),0);
           ELSIF p_stop_after IS NULL
           THEN
              l_stop_after := NULL;
           ELSE
              l_stop_after := 0;
           END IF;

           l_reqtab(l_ind).request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                               ,program     => 'HXCUPGWK'
                                               ,description => NULL
                                               ,sub_request => FALSE
                                               ,argument1   => p_type
                                               ,argument4   => l_stop_after
                                               ,argument2   => l_reqtab(l_ind).start_id ,
                                                argument3   => l_reqtab(l_ind).end_id);
           COMMIT;
           INSERT INTO hxc_upgrade_status
                (parent_id,
                 child_id,
                 child_status)
            VALUES ( FND_GLOBAL.CONC_REQUEST_ID,
                     l_reqtab(l_ind).request_id,
                     'INCOMPLETE');

           COMMIT;

           IF p_num_workers > 0
            AND l_reqtab.COUNT >= p_num_workers
           THEN
              l_work_limit := TRUE;
              EXIT;
           END IF;
           l_count := 0;
        END IF;
      END LOOP;
      CLOSE get_pa_detail_ids;
    END IF;


-- Start

    IF (p_type = 'DEPOSIT_TRANSACTIONS') THEN
      OPEN get_dep_txn_id;
      LOOP
        FETCH get_dep_txn_id
         BULK
         COLLECT INTO l_id_tab
                LIMIT 1000;

        EXIT WHEN l_id_tab.COUNT = 0;

        IF l_count =0
        THEN
           l_ind := l_ind + 1;
           l_reqtab(l_ind).start_id := l_id_tab(l_id_tab.FIRST);
        END IF;

        IF l_id_tab.COUNT < 1000
        THEN
           l_req := TRUE;
        ELSE
           l_req := FALSE;
        END IF;

        l_count := l_count + l_id_tab.COUNT;
        l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);
        IF l_count >= l_chunk_size
        THEN
           l_reqtab(l_ind).end_id := l_id_tab(l_id_tab.LAST);

           IF p_stop_after > 0
           THEN
              l_stop_after := GREATEST(p_stop_after - ((SYSDATE-l_start_time)/24),0);
           ELSIF p_stop_after IS NULL
           THEN
              l_stop_after := NULL;
           ELSE
              l_stop_after := 0;
           END IF;

           l_reqtab(l_ind).request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                               ,program     => 'HXCUPGWK'
                                               ,description => NULL
                                               ,sub_request => FALSE
                                               ,argument1   => p_type
                                               ,argument4   => l_stop_after
                                               ,argument2   => l_reqtab(l_ind).start_id ,
                                                argument3   => l_reqtab(l_ind).end_id);
           COMMIT;
           INSERT INTO hxc_upgrade_status
                (parent_id,
                 child_id,
                 child_status)
            VALUES ( FND_GLOBAL.CONC_REQUEST_ID,
                     l_reqtab(l_ind).request_id,
                     'INCOMPLETE');

           COMMIT;
           IF p_num_workers > 0
            AND l_reqtab.COUNT >= p_num_workers
           THEN
              l_work_limit := TRUE;
              EXIT;
           END IF;
           l_count := 0;
        END IF;
      END LOOP;
    END IF;

-- Stop


    IF l_req = TRUE
    THEN
           IF p_stop_after > 0
           THEN
              l_stop_after := GREATEST(p_stop_after - ((SYSDATE-l_start_time)/24),0);
           ELSIF p_stop_after IS NULL
           THEN
              l_stop_after := NULL;
           ELSE
              l_stop_after := 0;
           END IF;


        l_reqtab(l_reqtab.LAST).request_id := FND_REQUEST.SUBMIT_REQUEST(application => 'HXC'
                                               ,program     => 'HXCUPGWK'
                                               ,description => NULL
                                               ,sub_request => FALSE
                                               ,argument1   => p_type
                                               ,argument4   => l_stop_after
                                               ,argument2   => l_reqtab(l_reqtab.LAST).start_id ,
                                                argument3   => l_reqtab(l_reqtab.LAST).end_id);

           COMMIT;
           l_ind := l_reqtab.LAST;
           INSERT INTO hxc_upgrade_status
                (parent_id,
                 child_id,
                 child_status)
            VALUES ( FND_GLOBAL.CONC_REQUEST_ID,
                     l_reqtab(l_ind).request_id,
                     'INCOMPLETE');


       COMMIT;
    END IF;

    WHILE l_req_complete <> TRUE
    LOOP
        l_req_complete := TRUE;
        IF l_reqtab.COUNT > 0
        THEN
           FOR i IN l_reqtab.FIRST..l_reqtab.LAST
           LOOP
              l_call_status := FND_CONCURRENT.get_request_status(l_reqtab(i).request_id,
                                                                 '',
                                                                 '',
    			                                         l_phase,
    			                                         l_status,
    			                                         l_dev_phase,
    			                                         l_dev_status,
    	        		                                 l_message);

              IF l_call_status = FALSE
              THEN
                 put_log(i||'th request failed');
              END IF;
              IF l_dev_phase <> 'COMPLETE'
              THEN
                 l_req_complete := FALSE;
              END IF;
           END LOOP;
           IF l_req_complete <> TRUE
           THEN
               dbms_lock.sleep(10);
           END IF;
        END IF;
    END LOOP;

    IF l_work_limit = TRUE
    THEN
        put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
        put_log(p_num_workers||' Worker Processes did not complete the Upgrade process');
        put_log('The Program may be resumed later to complete the Upgrade Process');
        put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
        RETURN;
    END IF;

    BEGIN
        SELECT 1
          INTO l_exists
          FROM hxc_upgrade_status
         WHERE child_status = 'INCOMPLETE'
           AND ROWNUM < 2 ;

        IF l_exists =1
        THEN
           put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
           put_log('This Upgrade Program did not complete processing in the specified time.');
           put_log('The Program may be resumed later to complete the Upgrade Process');
           put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
        END IF;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
           l_exists := 0;
    END;

    IF l_exists = 0
    THEN
        UPDATE hxc_upgrade_definitions
           SET status = 'COMPLETE',
               last_update_date = SYSDATE,
               last_updated_by = FND_GLOBAL.user_id
         WHERE upg_type = p_type;

        put_log('++++++++++++++++++++++++++++++++++++++++++++++++');
        put_log(upgrade_name(p_type)||' is Complete ');
        put_log('++++++++++++++++++++++++++++++++++++++++++++++++');
    END IF;

    COMMIT;

END upgrade;

PROCEDURE upgrade_wk( errbuff      OUT NOCOPY VARCHAR2,
                      retcode      OUT NOCOPY VARCHAR2,
                      p_type       IN VARCHAR2,
                      p_start      IN NUMBER,
                      p_stop       IN NUMBER,
                      p_stop_after IN NUMBER DEFAULT -999)
IS

    CURSOR c_get_details( p_start  NUMBER,
                          p_end    NUMBER)
        IS SELECT /*+ LEADING(hld)
                      ORDERED
                      INDEX(hta hxc_time_attributes_pk) */
                  attribute1,
                  attribute2,
                  rowidtochar(hld.rowid)
             FROM hxc_latest_details hld,
                  hxc_time_attribute_usages hau,
                  hxc_time_attributes hta
            WHERE hld.time_building_block_id BETWEEN p_start
                                                 AND p_end
              AND hld.org_id  IS NULL
              AND hau.time_building_block_id = hld.time_building_block_id
              AND hau.time_building_block_ovn = hld.object_version_number
              AND hta.time_attribute_id = hau.time_attribute_id
              AND hta.attribute_category = 'SECURITY';

-- start
    CURSOR c_get_txns( p_start  NUMBER,
                       p_end    NUMBER)
        IS SELECT transaction_id
             FROM hxc_transactions
            WHERE transaction_id BETWEEN p_start
                                     AND p_end
              AND type = 'DEPOSIT'
            ORDER BY 1 asc;


     -- Bug 9394446
     -- Added the condition for Application Set
     CURSOR c_get_pay_details( p_start   NUMBER,
                               p_end     NUMBER,
                               p_ret_id  NUMBER )
         IS SELECT hld.business_group_id,
                   hld.org_id,
                   hld.resource_id,
                   hld.time_building_block_id,
                   hld.object_version_number,
                   hld.approval_status,
                   hld.start_time,
                   hld.stop_time,
                   hld.application_set_id,
                   hld.last_update_date,
                   hld.resource_type,
                   hld.comment_text,
                   tc.time_building_block_id
              FROM hxc_latest_details hld,
                   hxc_time_building_blocks det,
                   hxc_time_building_blocks day,
                   hxc_time_building_blocks tc
             WHERE hld.time_building_block_id BETWEEN p_start
                                                  AND p_end
               AND hld.time_building_block_id = det.time_building_block_id
               AND hld.object_version_number  = det.object_version_number
               AND day.time_building_block_id = det.parent_building_block_id
               AND day.object_version_number  = det.parent_building_block_ovn
               AND tc.time_building_block_id  = day.parent_building_block_id
               AND tc.object_version_number   = day.parent_building_block_ovn
               AND NOT EXISTS ( SELECT 1
                                  FROM hxc_transaction_details htd,
                                       hxc_transactions ht
                                 WHERE htd.time_building_block_id  = hld.time_building_block_id
                                   AND htd.time_building_block_ovn = hld.object_version_number
                                   AND htd.transaction_id          = ht.transaction_id
                                   AND htd.status = 'SUCCESS'
                                   AND ht.type = 'RETRIEVAL'
                                   AND ht.status = 'SUCCESS'
                                   AND ht.transaction_process_id IN (p_ret_id,-1))
              AND NOT EXISTS ( SELECT 1
                                 FROM hxc_pay_latest_details hpd
                                WHERE hpd.time_building_block_id = hld.time_building_block_id
                                  AND hpd.object_version_number  = hld.object_version_number)
              AND hld.application_set_id IN ( SELECT application_set_id
			                        FROM hxc_application_set_comps_v
					       WHERE time_recipient_name = 'Payroll')
              ;


     -- Bug 9394446
     -- Added the condition for Application Set
     CURSOR c_get_pa_details( p_start   NUMBER,
                               p_end     NUMBER,
                               p_ret_id  NUMBER )
         IS SELECT hld.business_group_id,
                   hld.org_id,
                   hld.resource_id,
                   hld.time_building_block_id,
                   hld.object_version_number,
                   hld.approval_status,
                   hld.start_time,
                   hld.stop_time,
                   hld.application_set_id,
                   hld.last_update_date,
                   hld.resource_type,
                   hld.comment_text,
                   tc.time_building_block_id
              FROM hxc_latest_details hld,
                   hxc_time_building_blocks det,
                   hxc_time_building_blocks day,
                   hxc_time_building_blocks tc
             WHERE hld.time_building_block_id BETWEEN p_start
                                                  AND p_end
               AND hld.time_building_block_id = det.time_building_block_id
               AND hld.object_version_number  = det.object_version_number
               AND day.time_building_block_id = det.parent_building_block_id
               AND day.object_version_number  = det.parent_building_block_ovn
               AND tc.time_building_block_id  = day.parent_building_block_id
               AND tc.object_version_number   = day.parent_building_block_ovn
               AND NOT EXISTS ( SELECT 1
                                  FROM hxc_transaction_details htd,
                                       hxc_transactions ht
                                 WHERE htd.time_building_block_id  = hld.time_building_block_id
                                   AND htd.time_building_block_ovn = hld.object_version_number
                                   AND htd.transaction_id          = ht.transaction_id
                                   AND htd.status = 'SUCCESS'
                                   AND ht.type = 'RETRIEVAL'
                                   AND ht.status = 'SUCCESS'
                                   AND ht.transaction_process_id = p_ret_id )
              AND NOT EXISTS ( SELECT 1
                                 FROM hxc_pa_latest_details hpd
                                WHERE hpd.time_building_block_id = hld.time_building_block_id
                                  AND hpd.object_version_number  = hld.object_version_number)
              AND hld.application_set_id IN ( SELECT application_set_id
			                        FROM hxc_application_set_comps_v
					       WHERE time_recipient_name = 'Projects')
                                  ;




    txnidtab      NUMTABLE;

-- stop

    orgtab      VARCHARTABLE;
    bgtab   	VARCHARTABLE;
    rowtab  	VARCHARTABLE;




    business_group_tab          NUMTABLE;
    org_tab 		        NUMTABLE;
    resource_tab 		NUMTABLE;
    time_building_block_tab     NUMTABLE;
    ovn_tab			NUMTABLE;
    approval_status_tab 	VARCHARTABLE;
    start_time_tab 		DATETABLE;
    stop_time_tab 		DATETABLE;
    application_set_tab 	NUMTABLE;
    last_update_date_tab 	DATETABLE;
    resource_type_tab 	        VARCHARTABLE;
    comment_text_tab 	        VARCHARTABLE;
    timecard_tab		NUMTABLE;
    l_process_id                NUMBER;


    l_complete  BOOLEAN  := TRUE;
    l_stop_time DATE;
    l_count     NUMBER := 0;


 BEGIN

     IF p_stop_after > 0
     THEN
        l_stop_time := SYSDATE + (p_stop_after/(24));
     ELSIF p_stop_after IS NULL
     THEN
        l_stop_time := NULL;
     ELSE
        put_log('This Worker Program could not start processing the Upgrade');
        RETURN;
     END IF;

     hr_general.g_data_migrator_mode := 'Y';

     IF (p_type ='LATEST_DETAILS')
     THEN
         OPEN c_get_details(p_start,
                            p_stop);
         LOOP
            FETCH c_get_details BULK COLLECT INTO orgtab,
                                                  bgtab,
                                                  rowtab LIMIT 500;
            EXIT WHEN orgtab.COUNT = 0;
            l_count := l_count + orgtab.COUNT;

            IF l_stop_time IS NOT NULL
              AND SYSDATE >= l_stop_time
            THEN
               l_complete := FALSE;
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               put_log('Processing crossed over '||p_stop_after||' minutes. Stopping...');
               put_log('Total Number of details processed : '||l_count);
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               EXIT;
            END IF;


            FORALL i IN orgtab.FIRST..orgtab.LAST
              UPDATE hxc_latest_details
                 SET org_id = orgtab(i),
                     business_group_id = bgtab(i)
                WHERE rowid = CHARTOROWID(rowtab(i));


             COMMIT;
          END LOOP;

         CLOSE c_get_details;


         IF l_complete = TRUE
     	 THEN
     	    UPDATE hxc_upgrade_status
     	       SET child_status = 'COMPLETE'
     	     WHERE child_id     = FND_GLOBAL.CONC_REQUEST_ID;

     	    COMMIT;

     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');
     	    put_log('Process completed successfully');
     	    put_log('Total Number of details processed :'||l_count);
     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');

     	 END IF;

     END IF;


     IF (p_type ='RETRIEVAL_PAY')
     THEN
         l_process_id  := get_ret_process_id('BEE Retrieval Process');


         OPEN c_get_pay_details(p_start,
                            p_stop,
                            l_process_id );
         LOOP
            FETCH c_get_pay_details
             BULK COLLECT INTO business_group_tab,
                               org_tab,
                               resource_tab,
                               time_building_block_tab,
                               ovn_tab,
                               approval_status_tab,
                               start_time_tab,
                               stop_time_tab,
                               application_set_tab,
                               last_update_date_tab,
                               resource_type_tab,
                               comment_text_tab,
                               timecard_tab		  LIMIT 500;
            EXIT WHEN org_tab.COUNT = 0;
            l_count := l_count + org_tab.COUNT;

            IF l_stop_time IS NOT NULL
              AND SYSDATE >= l_stop_time
            THEN
               l_complete := FALSE;
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               put_log('Processing crossed over '||p_stop_after||' minutes. Stopping...');
               put_log('Total Number of details processed : '||l_count);
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               EXIT;
            END IF;


            FORALL i IN org_tab.FIRST..org_tab.LAST
             INSERT INTO hxc_pay_latest_details
                   (business_group_id,
                    org_id,
                    resource_id,
                    time_building_block_id,
                    object_version_number,
                    approval_status,
                    start_time,
                    stop_time,
                    application_set_id,
                    last_update_date,
                    resource_type,
                    comment_text,
                   timecard_id)
                VALUES (business_group_tab(i),
                        org_tab(i),
                        resource_tab(i),
                        time_building_block_tab(i),
                        ovn_tab(i),
                        approval_status_tab(i),
                        start_time_tab(i),
                        stop_time_tab(i),
                        application_set_tab(i),
                        last_update_date_tab(i),
                        resource_type_tab(i),
                        comment_text_tab(i),
                        timecard_tab(i));

             COMMIT;
          END LOOP;

         CLOSE c_get_pay_details;


         IF l_complete = TRUE
     	 THEN
     	    UPDATE hxc_upgrade_status
     	       SET child_status = 'COMPLETE'
     	     WHERE child_id     = FND_GLOBAL.CONC_REQUEST_ID;

     	    COMMIT;

     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');
     	    put_log('Process completed successfully');
     	    put_log('Total Number of details processed :'||l_count);
     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');

     	 END IF;

     END IF;


     IF (p_type ='RETRIEVAL_PA')
     THEN
         l_process_id  := get_ret_process_id('Projects Retrieval Process');


         OPEN c_get_pa_details(p_start,
                            p_stop,
                            l_process_id );
         LOOP
            FETCH c_get_pa_details
             BULK COLLECT INTO business_group_tab,
                               org_tab,
                               resource_tab,
                               time_building_block_tab,
                               ovn_tab,
                               approval_status_tab,
                               start_time_tab,
                               stop_time_tab,
                               application_set_tab,
                               last_update_date_tab,
                               resource_type_tab,
                               comment_text_tab,
                               timecard_tab		  LIMIT 500;
            EXIT WHEN org_tab.COUNT = 0;
            l_count := l_count + org_tab.COUNT;

            IF l_stop_time IS NOT NULL
              AND SYSDATE >= l_stop_time
            THEN
               l_complete := FALSE;
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               put_log('Processing crossed over '||p_stop_after||' minutes. Stopping...');
               put_log('Total Number of details processed : '||l_count);
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               EXIT;
            END IF;


            FORALL i IN org_tab.FIRST..org_tab.LAST
             INSERT INTO hxc_pa_latest_details
                   (business_group_id,
                    org_id,
                    resource_id,
                    time_building_block_id,
                    object_version_number,
                    approval_status,
                    start_time,
                    stop_time,
                    application_set_id,
                    last_update_date,
                    resource_type,
                    comment_text,
                   timecard_id)
                VALUES (business_group_tab(i),
                        org_tab(i),
                        resource_tab(i),
                        time_building_block_tab(i),
                        ovn_tab(i),
                        approval_status_tab(i),
                        start_time_tab(i),
                        stop_time_tab(i),
                        application_set_tab(i),
                        last_update_date_tab(i),
                        resource_type_tab(i),
                        comment_text_tab(i),
                        timecard_tab(i));

             COMMIT;
          END LOOP;

         CLOSE c_get_pa_details;


         IF l_complete = TRUE
     	 THEN
     	    UPDATE hxc_upgrade_status
     	       SET child_status = 'COMPLETE'
     	     WHERE child_id     = FND_GLOBAL.CONC_REQUEST_ID;

     	    COMMIT;

     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');
     	    put_log('Process completed successfully');
     	    put_log('Total Number of details processed :'||l_count);
     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');

     	 END IF;

     END IF;

-- start

     IF (p_type ='DEPOSIT_TRANSACTIONS')
     THEN

         OPEN c_get_txns(p_start,
                         p_stop);
         LOOP
            FETCH c_get_txns BULK COLLECT INTO txnidtab
            					LIMIT 300;
            EXIT WHEN txnidtab.COUNT = 0;

            l_count := l_count + txnidtab.COUNT;

            IF l_stop_time IS NOT NULL
              AND SYSDATE >= l_stop_time
            THEN
               l_complete := FALSE;
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               put_log('Processing crossed over '||p_stop_after||' minutes. Stopping...');
               put_log('Total Number of DEPOSIT transactions processed  :  '||l_count);
               put_log('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
               EXIT;
            END IF;

	   -- Insert into new table HXC_DEP_TRANSACTIONS
            FORALL i IN txnidtab.FIRST..txnidtab.LAST
    		INSERT
      		  INTO hxc_dep_transactions
                 (SELECT * FROM hxc_transactions
                   WHERE transaction_id = txnidtab(i)
                     AND type = 'DEPOSIT') ;

    	    put_log('Migrated data to HXC_DEP_TRANSACTIONS');

            -- Delete DEPOSIT transaction records from HXC_TRANSACTIONS
            FORALL i IN txnidtab.FIRST..txnidtab.LAST
    		DELETE
      		  FROM hxc_transactions
                 WHERE transaction_id = txnidtab(i) ;

    	    put_log('Deleted migrated records from HXC_TRANSACTIONS');

	   -- Insert into new table HXC_DEP_TRANSACTION_DETAILS
            FORALL i IN txnidtab.FIRST..txnidtab.LAST
    		INSERT INTO hxc_dep_transaction_details
                 (SELECT * FROM hxc_transaction_details
                   WHERE transaction_id = txnidtab(i)) ;

    	    put_log('Migrated data to HXC_DEP_TRANSACTION_DETAILS');

            -- Delete DEPOSIT transaction detail records from HXC_TRANSACTION_DETAILS
            FORALL i IN txnidtab.FIRST..txnidtab.LAST
    		DELETE
      		  FROM hxc_transaction_details
                 WHERE transaction_id = txnidtab(i) ;

    	    put_log('Deleted migrated records from HXC_TRANSACTION_DETAILS');

            COMMIT;
          END LOOP;

         CLOSE c_get_txns;

         put_log('Upgrade Worker Process Completed');

         IF l_complete = TRUE
     	 THEN
     	    UPDATE hxc_upgrade_status
     	       SET child_status = 'COMPLETE'
     	     WHERE child_id     = FND_GLOBAL.CONC_REQUEST_ID;

     	    COMMIT;

     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');
     	    put_log('Process completed successfully');
     	    put_log('Total Number of details processed :'||l_count);
     	    put_log('++++++++++++++++++++++++++++++++++++++++++++++++++++');

     	 END IF;

     END IF;
-- stop

END upgrade_wk;


PROCEDURE put_log(p_text   IN VARCHAR2)
IS

  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN
     FND_FILE.PUT_LINE(FND_FILE.LOG,p_text);
END put_log;

FUNCTION ret_upgrade_completed
RETURN BOOLEAN

IS

l_upgrade   NUMBER;

BEGIN

    SELECT 1
      INTO l_upgrade
      FROM hxc_upgrade_definitions
     WHERE upg_type = 'LATEST_DETAILS'
       AND status = 'COMPLETE';

   IF l_upgrade = 1
   THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        RETURN FALSE;
END ret_upgrade_completed;


-- start
FUNCTION txn_upgrade_completed
RETURN BOOLEAN

IS

l_upgrade   NUMBER;

BEGIN

    SELECT 1
      INTO l_upgrade
      FROM hxc_upgrade_definitions
     WHERE upg_type = 'DEPOSIT_TRANSACTIONS'
       AND status = 'COMPLETE';

   IF l_upgrade = 1
   THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        RETURN FALSE;
END txn_upgrade_completed;


PROCEDURE insert_into_upg_defn(p_upg_type IN VARCHAR2)
IS

BEGIN

             INSERT INTO HXC_UPGRADE_DEFINITIONS
                ( UPG_TYPE,
                  STATUS,
                  last_updated_by,
                  last_update_date)
              VALUES
                ( p_upg_type,
                 'INCOMPLETE',
                  FND_GLOBAL.user_id,
                  SYSDATE);

END insert_into_upg_defn;
-- stop


FUNCTION get_ret_process_id (p_process  IN VARCHAR2)
RETURN NUMBER
IS

   CURSOR get_process_id(p_process_name  IN VARCHAR2)
       IS SELECT retrieval_process_id
            FROM hxc_retrieval_processes
           WHERE name = p_process_name;

 l_process_id   NUMBER:= 0;

BEGIN
    OPEN get_process_id(p_process);
    FETCH get_process_id INTO l_process_id;
    CLOSE get_process_id;
    RETURN l_process_id;

END get_ret_process_id;

FUNCTION upgrade_name(p_lookup_code  IN VARCHAR2)
RETURN VARCHAR2
IS

  CURSOR get_upg_name(p_lookup_code  IN VARCHAR2)
      IS SELECT meaning
           FROM fnd_lookup_values
          WHERE lookup_type = 'HXC_UPGRADE_DEFINITIONS'
            AND lookup_code = p_lookup_code
            AND language = USERENV('LANG');

     l_lookup_name   VARCHAR2(100);

BEGIN

     IF g_upg_name.EXISTS(p_lookup_code)
     THEN
        RETURN g_upg_name(p_lookup_code);
     ELSE
        OPEN get_upg_name(p_lookup_code);
        FETCH get_upg_name INTO l_lookup_name;
        CLOSE get_upg_name;

        g_upg_name(p_lookup_code) := l_lookup_name;
        RETURN g_upg_name(p_lookup_code);
     END IF;

END upgrade_name;


FUNCTION performance_upgrade_complete(p_upg_type  IN VARCHAR2)
RETURN BOOLEAN
IS

l_upgrade   NUMBER;

BEGIN

    SELECT 1
      INTO l_upgrade
      FROM hxc_upgrade_definitions
     WHERE upg_type = p_upg_type
       AND status = 'COMPLETE';

   IF l_upgrade = 1
   THEN
      RETURN TRUE;
   ELSE
      RETURN FALSE;
   END IF;

  EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
        RETURN FALSE;
END performance_upgrade_complete;



END HXC_UPGRADE_PKG;

/
