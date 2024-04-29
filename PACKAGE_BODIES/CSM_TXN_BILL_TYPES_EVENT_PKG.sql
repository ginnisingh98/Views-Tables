--------------------------------------------------------
--  DDL for Package Body CSM_TXN_BILL_TYPES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_TXN_BILL_TYPES_EVENT_PKG" AS
/* $Header: csmetbtb.pls 120.1 2005/07/25 00:26:50 trajasek noship $ */
g_all_palm_res_list asg_download.user_list;

/**
  Refreshes the CSM_BUS_PROCESS_TXNS_ACC table by comparing with the
  backend table for deletes, updates and inserts.
  Refreshes for all the users
  Also adds corresponding entries in to SDQ

  MODIFICATION HOSTORY:
  10/06/02 ANURAG added check before inserting into csm_txn_billing_types_acc
      for already existing primary key value
*/

procedure Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_pub_item varchar2(30) := 'CSF_M_TXN_BILLING_TYPES';
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_mark_dirty boolean;
l_access_id  CSM_BUS_PROCESS_TXNS_ACC.ACCESS_ID%TYPE;
l_language cs_transaction_types_tl.language%TYPE;
l_business_process_id CS_BUS_PROCESS_TXNS.BUSINESS_PROCESS_ID%TYPE;
l_txn_billing_type_id cs_txn_billing_types.txn_billing_type_id%TYPE;
l_transaction_type_id cs_txn_billing_types.transaction_type_id%TYPE;
l_tl_omfs_palm_resource_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;
l_null_resource_list asg_download.user_list;
l_run_date DATE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_TXN_BILL_TYPES_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

CURSOR l_deletes_cur
IS
SELECT acc.access_id
FROM CSM_TXN_BILLING_TYPES_ACC acc
WHERE NOT EXISTS
     (select tbt.TXN_BILLING_TYPE_ID
        from cs_txn_billing_types tbt,
             cs_transaction_types_b ttb,
             cs_business_processes bpr,
             cs_bus_process_txns bpt,
             CS_BILLING_TYPE_CATEGORIES cbtc
       where acc.txn_billing_type_id = tbt.txn_billing_type_id
         AND acc.business_process_id = bpt.business_process_id
         AND tbt.transaction_type_id = ttb.transaction_type_id
         AND SYSDATE BETWEEN nvl(tbt.start_date_active, SYSDATE) AND nvl(tbt.end_date_active, SYSDATE)
         AND SYSDATE BETWEEN nvl(ttb.start_date_active, SYSDATE) AND nvl(ttb.end_date_active, SYSDATE)
         AND SYSDATE BETWEEN nvl(bpr.start_date_active, SYSDATE) AND nvl(bpr.end_date_active, SYSDATE)
         AND SYSDATE BETWEEN nvl(bpt.start_date_active, SYSDATE) AND nvl(bpt.end_date_active, SYSDATE)
         AND tbt.billing_type = cbtc.billing_type
         AND cbtc.billing_category IN ( 'L', 'E', 'M' )
         AND SYSDATE BETWEEN nvl(cbtc.start_date_active, SYSDATE) AND nvl(cbtc.end_date_active, SYSDATE)
         AND bpt.transaction_type_id = tbt.transaction_type_id
         AND bpr.business_process_id = bpt.business_process_id
         AND bpr.field_service_flag = 'Y'
      );

 l_temp_date date;

CURSOR l_txn_types_tl_cur (p_transaction_type_id IN cs_transaction_types_b.transaction_type_id%TYPE)
IS
SELECT tt_tl.LANGUAGE
FROM cs_transaction_types_tl tt_tl
WHERE tt_tl.transaction_type_id = p_transaction_type_id;

cursor record_exists_csr( p_txn_billing_type_id csm_txn_billing_types_acc.txn_billing_type_id%TYPE,
                          p_business_process_id csm_txn_billing_types_acc.business_process_id%TYPE)
is
select 1
from csm_txn_billing_types_acc
where txn_billing_type_id = p_txn_billing_type_id
and business_process_id = p_business_process_id;
l_dummy number;

BEGIN
  -- get last conc program update date
  OPEN l_last_run_date_csr;
  FETCH l_last_run_date_csr INTO l_prog_update_date;
  CLOSE l_last_run_date_csr;

  -- conc program run date
  l_run_date := SYSDATE;

  --get all the OMFS Palm users
  g_all_palm_res_list := CSM_UTIL_PKG.get_all_omfs_palm_res_list;

  /****** DELETES  **********/
  --open the cursor
   open l_deletes_cur;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_deletes_cur INTO l_access_id;
     EXIT WHEN l_deletes_cur%NOTFOUND;

     --mark dirty the SDQ for all users
     FOR i IN 1 .. g_all_palm_res_list.COUNT LOOP
       l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
                                                         l_access_id,
                                                         g_all_palm_res_list(i),
                                                         ASG_DOWNLOAD.DEL,
                                                         SYSDATE);
     END LOOP;

     --remove from ACC
     DELETE FROM CSM_TXN_BILLING_TYPES_ACC
       WHERE ACCESS_ID = l_access_id;

   END LOOP;
   --close the cursor
   close l_deletes_cur;

  /******* UPDATES **********/
  --generate sql for updates
  l_dsql := 'select acc.access_id, tt_tl.language
             from csm_txn_billing_types_acc acc,
                  cs_txn_billing_types tbt,
                  cs_transaction_types_b ttb,
                  cs_transaction_types_tl tt_tl,
                  cs_business_processes bpr,
                  cs_bus_process_txns bpt,
                  CS_BILLING_TYPE_CATEGORIES cbtc
            where acc.txn_billing_type_id = tbt.txn_billing_type_id
              AND acc.business_process_id = bpt.business_process_id
              AND tbt.transaction_type_id = ttb.transaction_type_id
              AND tbt.billing_type = cbtc.billing_type
              AND cbtc.billing_category IN ( ''L'', ''E'', ''M'' )
              AND tt_tl.transaction_type_id = tbt.transaction_type_id
              AND bpt.transaction_type_id = tbt.transaction_type_id
              AND SYSDATE BETWEEN nvl(bpt.start_date_active, SYSDATE) AND nvl(bpt.end_date_active, SYSDATE)
              AND bpr.business_process_id = bpt.business_process_id
              AND SYSDATE BETWEEN nvl(bpr.start_date_active, SYSDATE) AND nvl(bpr.end_date_active, SYSDATE)
              AND bpr.field_service_flag = ''Y''
              AND (tbt.last_update_date > :1
                 or ttb.last_update_date > :2
                 or tt_tl.last_update_date > :3
                 or bpr.last_update_date > :4
                 or bpt.last_update_date > :5
                 or cbtc.last_update_date > :6
               )';


  --open the cursor
   open l_updates_cur for l_dsql USING l_prog_update_date, l_prog_update_date, l_prog_update_date, l_prog_update_date, l_prog_update_date, l_prog_update_date;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_updates_cur INTO l_access_id, l_language;
     EXIT WHEN l_updates_cur%NOTFOUND;

     --get the users with this language
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(l_language);

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 then
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource(l_pub_item,
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.UPD, sysdate);
     END IF;

     --update ACC
     UPDATE csm_txn_billing_types_acc
       SET LAST_UPDATE_DATE = l_run_date
       WHERE ACCESS_ID = l_access_id;

   END LOOP;

   --close the cursor
   close l_updates_cur;

  /****** INSERTS  **********/
  --generate sql for inserts
  l_dsql := 'select tbt.TXN_BILLING_TYPE_ID, bpt.business_process_id, tbt.transaction_type_id
        from cs_txn_billing_types tbt,
             cs_transaction_types_b ttb,
             cs_business_processes bpr,
             cs_bus_process_txns bpt,
             CS_BILLING_TYPE_CATEGORIES cbtc
       where tbt.transaction_type_id = ttb.transaction_type_id
         AND SYSDATE BETWEEN nvl(tbt.start_date_active, SYSDATE) AND nvl(tbt.end_date_active, SYSDATE)
         AND SYSDATE BETWEEN nvl(ttb.start_date_active, SYSDATE) AND nvl(ttb.end_date_active, SYSDATE)
         AND SYSDATE BETWEEN nvl(bpr.start_date_active, SYSDATE) AND nvl(bpr.end_date_active, SYSDATE)
         AND SYSDATE BETWEEN nvl(bpt.start_date_active, SYSDATE) AND nvl(bpt.end_date_active, SYSDATE)
         AND tbt.billing_type = cbtc.billing_type
         AND cbtc.billing_category IN ( ''L'', ''E'', ''M'' )
         AND SYSDATE BETWEEN nvl(cbtc.start_date_active, SYSDATE) AND nvl(cbtc.end_date_active, SYSDATE)
         AND bpt.transaction_type_id = tbt.transaction_type_id
         AND bpr.business_process_id = bpt.business_process_id
         AND bpr.field_service_flag = ''Y''
         AND NOT EXISTS
         (select 1
          from csm_txn_billing_types_acc acc
          where acc.txn_billing_type_id = tbt.txn_billing_type_id
          and   acc.business_process_id = bpt.business_process_id
         )';

  --open the cursor
   open l_inserts_cur for l_dsql;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_inserts_cur INTO l_txn_billing_type_id, l_business_process_id, l_transaction_type_id;
     EXIT WHEN l_inserts_cur%NOTFOUND;

     --generate access_id
     select csm_txn_billing_types_acc_s.NEXTVAL into l_access_id from dual;

     FOR r_txn_types_tl_cur IN l_txn_types_tl_cur(l_transaction_type_id) LOOP
       --get the users with this language
       l_tl_omfs_palm_resource_list := l_null_resource_list;
       l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_txn_types_tl_cur.language);

       --nullify the access list
       l_single_access_id_list := l_null_access_list;
       FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
           l_single_access_id_list(i) := l_access_id;
       END LOOP;

       --mark dirty the SDQ for all users
       IF l_single_access_id_list.count > 0 THEN
         l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_TXN_BILLING_TYPES',
            l_single_access_id_list, l_tl_omfs_palm_resource_list,
            ASG_DOWNLOAD.INS, sysdate);
       END IF;

       --insert into
       --check if the record exists
       open record_exists_csr (l_txn_billing_type_id, l_business_process_id);
       fetch record_exists_csr into l_dummy;

       if record_exists_csr%notfound then
         --insert if the value does not already exists
          INSERT INTO csm_txn_billing_types_acc(access_id, txn_billing_type_id, business_process_id, CREATED_BY,
                       CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
          VALUES (l_access_id,l_txn_billing_type_id, l_business_process_id, fnd_global.user_id, l_run_date,
                fnd_global.user_id, l_run_date, fnd_global.login_id);

       end if;
       close record_exists_csr;
     END LOOP;
   END LOOP;
   --close the cursor
   close l_inserts_cur;

   -- set the program update date in jtm_con_request_data to sysdate
   UPDATE jtm_con_request_data
   SET last_run_date = l_run_date
   WHERE package_name = 'CSM_TXN_BILL_TYPES_EVENT_PKG'
     AND procedure_name = 'REFRESH_ACC';

  COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_TXN_BILL_TYPES_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     if record_exists_csr%isopen then
  	close record_exists_csr;
     end if;
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_TXN_BILL_TYPES_EVENT_PKG.Refresh_Acc :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     fnd_file.put_line(fnd_file.log, p_message);
END Refresh_Acc;
END CSM_TXN_BILL_TYPES_EVENT_PKG;

/
