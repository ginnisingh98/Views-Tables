--------------------------------------------------------
--  DDL for Package Body CSM_BUS_PROCESS_TXNS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_BUS_PROCESS_TXNS_EVENT_PKG" AS
/* $Header: csmebptb.pls 120.1 2005/07/22 08:34:50 trajasek noship $ */

-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

g_all_palm_res_list asg_download.user_list;


/**
  Refreshes the CSM_BUS_PROCESS_TXNS_ACC table by comparing with the
  backend table for deletes, updates and inserts.
  Refreshes for all the users
  Also adds corresponding entries in to SDQ
*/
PROCEDURE Refresh_Acc(p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2) AS
PRAGMA AUTONOMOUS_TRANSACTION;

l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_pub_item varchar2(30) := 'CSF_M_TXN_BUS_PROCESSES';
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(2000);

CURSOR l_last_run_date_csr(p_pub_item IN varchar2)
IS
SELECT nvl(last_run_date, (sysdate - 365*50) )
FROM jtm_con_request_data
WHERE package_name = 'CSM_BUS_PROCESS_TXNS_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

CURSOR l_deletes_cur
IS
    SELECT acc.access_id
       FROM CSM_BUS_PROCESS_TXNS_ACC acc
       WHERE NOT EXISTS
         (SELECT bpt.BUSINESS_PROCESS_ID
          FROM CS_BUS_PROCESS_TXNS bpt,
               CS_BUSINESS_PROCESSES bpr
          WHERE bpt.transaction_type_id = acc.transaction_type_id
            AND bpt.business_process_id = acc.business_process_id
            AND bpr.business_process_id = bpt.business_process_id
            AND bpr.field_service_flag = 'Y');

CURSOR l_access_id_csr IS
select csm_bus_processes_acc_s.nextval  FROM dual;


l_mark_dirty boolean;
l_bpr_last_update_date CS_BUSINESS_PROCESSES.LAST_UPDATE_DATE%TYPE;
l_bpt_last_update_date CS_BUS_PROCESS_TXNS.LAST_UPDATE_DATE%TYPE;
l_max_update_date CSM_BUS_PROCESS_TXNS_ACC.LAST_UPDATE_DATE%TYPE;

l_access_id CSM_BUS_PROCESS_TXNS_ACC.ACCESS_ID%TYPE;
l_business_process_id CS_BUS_PROCESS_TXNS.BUSINESS_PROCESS_ID%TYPE;
l_transaction_type_id CS_BUS_PROCESS_TXNS.TRANSACTION_TYPE_ID%TYPE;
l_run_date DATE;

BEGIN
  -- get last conc program update date
  OPEN l_last_run_date_csr(l_pub_item);
  FETCH l_last_run_date_csr INTO l_prog_update_date;
  CLOSE l_last_run_date_csr;

  -- conc program run date
  l_run_date := SYSDATE;

  --get all the OMFS Palm users
  g_all_palm_res_list := CSM_UTIL_PKG.get_all_omfs_palm_res_list;

  /****** DELETES  **********/
  --Process deletes only if particular access_id is passed
  --open the cursor
   open l_deletes_cur;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_deletes_cur INTO l_access_id;
     EXIT WHEN l_deletes_cur%NOTFOUND;

     --mark dirty the SDQ for all users
     FOR i IN 1 .. g_all_palm_res_list.COUNT LOOP
       l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_TXN_BUS_PROCESSES',
                                                          l_access_id,
                                                          g_all_palm_res_list(i),
                                                          ASG_DOWNLOAD.DEL,
                                                          SYSDATE);
     END LOOP;

     --remove from ACC
     DELETE FROM CSM_BUS_PROCESS_TXNS_ACC
       WHERE ACCESS_ID = l_access_id;

   END LOOP;

   --close the cursor
   close l_deletes_cur;

  /******* UPDATES **********/
  --generate sql for updates
  l_dsql :=
    'SELECT acc.access_id, bpt.last_update_date, bpr.last_update_date
       FROM CS_BUS_PROCESS_TXNS bpt,
            CS_BUSINESS_PROCESSES bpr,
            CSM_BUS_PROCESS_TXNS_ACC acc
       WHERE bpr.business_process_id = bpt.business_process_id
         AND bpt.transaction_type_id = acc.transaction_type_id
         AND bpt.business_process_id = acc.business_process_id
         AND (bpt.last_update_date > :1
             or bpr.last_update_date > :2
           )';

--         AND (bpt.last_update_date > ' || '''' || l_prog_update_date || ''''  ||
--           ' or bpr.last_update_date > ' || '''' || l_prog_update_date || '''' ||
--           ')';


  --open the cursor
   open l_updates_cur for l_dsql USING l_prog_update_date, l_prog_update_date;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_updates_cur INTO l_access_id, l_bpt_last_update_date, l_bpr_last_update_date;
     EXIT WHEN l_updates_cur%NOTFOUND;

     --mark dirty the SDQ for all users
     FOR i IN 1 .. g_all_palm_res_list.COUNT LOOP
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_TXN_BUS_PROCESSES',
          l_access_id, g_all_palm_res_list(i),
          ASG_DOWNLOAD.UPD, sysdate);
     END LOOP;


     --get the max update date
     IF (l_bpt_last_update_date > l_bpr_last_update_date) THEN
       l_max_update_date := l_bpt_last_update_date;
     ELSE
       l_max_update_date := l_bpr_last_update_date;
     END IF;

     --update ACC
     UPDATE CSM_BUS_PROCESS_TXNS_ACC
       SET LAST_UPDATE_DATE = l_run_date -- l_max_update_date
       WHERE ACCESS_ID = l_access_id;

   END LOOP;

   --close the cursor
   close l_updates_cur;

  /****** INSERTS  **********/
  --generate sql for inserts
  l_dsql :=
    'SELECT bpt.business_process_id, bpt.transaction_type_id, bpt.last_update_date, bpr.last_update_date
    FROM CS_BUS_PROCESS_TXNS bpt,
         CS_BUSINESS_PROCESSES bpr
    WHERE bpr.business_process_id = bpt.business_process_id
      AND bpr.field_service_flag = ''Y''
      AND NOT EXISTS
          (SELECT access_id
           FROM CSM_BUS_PROCESS_TXNS_ACC acc
           WHERE bpt.transaction_type_id = acc.transaction_type_id
             AND bpt.business_process_id = acc.business_process_id )';


/*  IF p_access_id IS NOT NULL THEN
    l_dsql := l_dsql
      || ' AND CSM_UTIL_PKG.generate_numpk_fromstr(to_char(bpt.business_process_id) || ''.'' || to_char(bpt.transaction_type_id)) = '
      || p_access_id;
   END IF;
*/
  --open the cursor
   open l_inserts_cur for l_dsql;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_inserts_cur INTO l_business_process_id, l_transaction_type_id, l_bpt_last_update_date, l_bpr_last_update_date;
     EXIT WHEN l_inserts_cur%NOTFOUND;

     --generate access_id
--     l_access_id := csm_util_pkg.generate_numpk_fromstr(to_char(l_business_process_id) || '.' || to_char(l_transaction_type_id));
     -- get access_id from seq
      --select csm_bus_processes_acc_s.nextval into l_access_id FROM dual;

     OPEN l_access_id_csr ;
     FETCH l_access_id_csr INTO l_access_id;
     CLOSE l_access_id_csr;

     --mark dirty the SDQ for all users
     FOR i IN 1 .. g_all_palm_res_list.COUNT LOOP
       l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_TXN_BUS_PROCESSES',
          l_access_id, g_all_palm_res_list(i),
          ASG_DOWNLOAD.INS, sysdate);
     END LOOP;

     --get the max update date
     IF (l_bpt_last_update_date > l_bpr_last_update_date) THEN
       l_max_update_date := l_bpt_last_update_date;
     ELSE
       l_max_update_date := l_bpr_last_update_date;
     END IF;

     --insert into
     INSERT INTO CSM_BUS_PROCESS_TXNS_ACC (ACCESS_ID, BUSINESS_PROCESS_ID,
       TRANSACTION_TYPE_ID, CREATED_BY, CREATION_DATE, LAST_UPDATED_BY,
       LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
     VALUES (l_access_id, l_business_process_id,
       l_transaction_type_id, fnd_global.user_id, sysdate, fnd_global.user_id,
       l_run_date, fnd_global.user_id);

   END LOOP;

   --close the cursor
   close l_inserts_cur;

   -- set the program update date in asg_pub_item to sysdate
   UPDATE jtm_con_request_data
   SET last_run_date = l_run_date
   WHERE package_name = 'CSM_BUS_PROCESS_TXNS_EVENT_PKG'
     AND procedure_name = 'REFRESH_ACC';

  commit;

 p_status := 'FINE';
 p_message :=  'CSM_BUS_PROCESS_TXNS_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_BUS_PROCESS_TXNS_EVENT_PKG.Refresh_Acc :' || l_sqlerrno || ':' || l_sqlerrmsg;
     fnd_file.put_line(fnd_file.log, p_message);
     ROLLBACK;
END Refresh_Acc;

END CSM_BUS_PROCESS_TXNS_EVENT_PKG;

/
