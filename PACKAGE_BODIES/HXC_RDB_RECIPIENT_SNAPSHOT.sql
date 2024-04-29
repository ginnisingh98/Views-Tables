--------------------------------------------------------
--  DDL for Package Body HXC_RDB_RECIPIENT_SNAPSHOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HXC_RDB_RECIPIENT_SNAPSHOT" AS
/* $Header: hxcrdbrecsnp.pkb 120.1.12010000.2 2010/04/03 12:25:17 asrajago noship $ */

  PROCEDURE get_snapshot(errbuff   OUT NOCOPY VARCHAR2,
                         retcode   OUT NOCOPY NUMBER,
                         p_request_id IN NUMBER DEFAULT 0)
  IS

     CURSOR get_retro_exp
         IS SELECT pa.expenditure_item_id,
                   exp.expenditure_group,
                   ROWIDTOCHAR(ret.rowid)
              FROM hxc_ret_pa_latest_details ret,
                   pa_expenditure_items_all pa,
                   pa_expenditures_all exp
             WHERE ret.request_id = p_request_id
               AND pa.transaction_source = 'ORACLE TIME AND LABOR'
               AND pa.orig_transaction_reference = ret.time_building_block_id||':'||ret.object_version_number
               AND pa.net_zero_adjustment_flag = 'Y'
    			     AND pa.expenditure_id = exp.expenditure_id
               AND ret.old_measure IS NOT NULL;

     CURSOR get_new_exp
         IS SELECT pa.expenditure_item_id,
                   exp.expenditure_group,
                   ROWIDTOCHAR(ret.rowid)
              FROM hxc_ret_pa_latest_details ret,
                   pa_expenditure_items_all pa,
                   pa_expenditures_all exp
             WHERE ret.request_id = p_request_id
               AND pa.transaction_source = 'ORACLE TIME AND LABOR'
               AND pa.orig_transaction_reference = ret.time_building_block_id||':'||ret.object_version_number
               AND pa.net_zero_adjustment_flag = 'N'
    			     AND pa.expenditure_id = exp.expenditure_id ;


     eitab  NUMBERTAB;
     ettab  VARCHARTAB;
     rowtab VARCHARTAB;

   l_req_complete  BOOLEAN := FALSE;
   l_request_id    NUMBER;

   l_call_status  BOOLEAN ;
   l_interval     NUMBER := 30;
   l_phase        VARCHAR2(30);
   l_status       VARCHAR2(30);
   l_dev_phase    VARCHAR2(30);
   l_dev_status   VARCHAR2(30);
   l_message      VARCHAR2(30);



  BEGIN

       l_request_id := p_request_id;

       l_call_status := FND_CONCURRENT.get_request_status(l_request_id,
                                                                     '',
                                                                     '',
    			                                                      l_phase,
    			                                                     l_status,
    			                                                  l_dev_phase,
    			                                                 l_dev_status,
                        		                                 l_message);

       IF l_dev_phase <> 'COMPLETE'
       THEN
          l_req_complete := FALSE;
       END IF;

      IF l_call_status = FALSE
      THEN
         l_req_complete := TRUE;
      END IF;

      << WAIT_AND_PICK_TIMECARDS >>
      LOOP

      OPEN get_retro_exp;
      LOOP
         FETCH get_retro_exp
          BULK COLLECT INTO eitab,ettab,
                            rowtab LIMIT 1000;

         EXIT WHEN eitab.COUNT = 0;

         FORALL i IN eitab.FIRST..eitab.LAST
           UPDATE hxc_ret_pa_latest_details
              SET retro_pei_id = eitab(i),
                  retro_exp_group = ettab(i)
            WHERE ROWID = CHARTOROWID(rowtab(i));
         COMMIT;

      END LOOP;
      CLOSE get_retro_exp;

      OPEN get_new_exp;
      LOOP
         FETCH get_new_exp
          BULK COLLECT INTO eitab,ettab,
                            rowtab LIMIT 1000;

         EXIT WHEN eitab.COUNT = 0;

         FORALL i IN eitab.FIRST..eitab.LAST
           UPDATE hxc_ret_pa_latest_details
              SET pei_id = eitab(i),
                  exp_group = ettab(i)
            WHERE ROWID = CHARTOROWID(rowtab(i));
         COMMIT;

      END LOOP;
      CLOSE get_new_exp;


      IF l_req_complete = TRUE
      THEN
         EXIT WAIT_AND_PICK_TIMECARDS ;
      ELSE
         dbms_lock.sleep(10);
         l_call_status := FND_CONCURRENT.get_request_status(l_request_id,
                                                                 '',
                                                                 '',
    			                                         l_phase,
    			                                         l_status,
    			                                         l_dev_phase,
    			                                         l_dev_status,
    	        		                                 l_message);

         IF l_dev_phase <> 'COMPLETE'
         THEN
            l_req_complete := FALSE;
         ELSE
            l_req_complete := TRUE;
         END IF;

         IF l_call_status = FALSE
         THEN
            l_req_complete := TRUE;
         END IF;

      END IF;

      END LOOP WAIT_AND_PICK_TIMECARDS;


      DELETE FROM hxc_rdb_pending_processes
            WHERE request_id = l_request_id;


      COMMIT;



  END get_snapshot;

END HXC_RDB_RECIPIENT_SNAPSHOT;


/
