--------------------------------------------------------
--  DDL for Package Body CSM_MTL_TXN_REASONS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_TXN_REASONS_EVENT_PKG" 
/* $Header: csmemtrb.pls 120.1 2005/07/25 00:15:12 trajasek noship $*/
AS
--
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
g_pub_item varchar2(30) := 'CSM_MTL_TXN_REASONS';

PROCEDURE Refresh_mtl_txn_reasons_acc(p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

l_null_resource_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;
l_all_omfs_palm_resource_list asg_download.user_list;
l_null_palm_omfs_resource_list asg_download.user_list;
l_run_date date;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg varchar2(2000);
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_access_id jtm_fnd_lookups_acc.access_id%TYPE;
l_mark_dirty boolean;

CURSOR l_ins_mtl_txn_reasons_csr(p_lastrundate IN date)
IS
SELECT csm_mtl_txn_reasons_acc_s.nextval, reason_id
FROM mtl_transaction_reasons
WHERE NVL(disable_date, SYSDATE) >= SYSDATE
AND  last_update_date >= nvl(p_lastrundate, last_update_date )
AND ( reason_id ) NOT IN (
      SELECT reason_id
      FROM csm_mtl_txn_reasons_acc
      );

CURSOR l_upd_mtl_txn_reasons_csr( p_lastrundate IN DATE)
IS
SELECT access_id
FROM csm_mtl_txn_reasons_acc acc
,    mtl_transaction_reasons mtr
WHERE mtr.reason_id = acc.reason_id
AND   NVL(disable_date, SYSDATE) >= SYSDATE
AND   mtr.last_update_date  >= p_lastrundate;

CURSOR l_del_mtl_txn_reasons_csr( p_lastrundate IN DATE)
IS
SELECT access_id
FROM csm_mtl_txn_reasons_acc
WHERE reason_id IN
 (SELECT reason_id
  FROM mtl_transaction_reasons
  WHERE last_update_date >= nvl(p_lastrundate, last_update_date)
  AND NVL(disable_date, sysdate) < SYSDATE
  )
UNION
SELECT access_id
FROM csm_mtl_txn_reasons_acc
WHERE reason_id NOT IN
 (SELECT reason_id
  FROM mtl_transaction_reasons
 );

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_MTL_TXN_REASONS_EVENT_PKG'
AND procedure_name = 'REFRESH_MTL_TXN_REASONS_ACC';

TYPE access_id_tbl_typ IS TABLE OF csm_mtl_txn_reasons_acc.access_id%TYPE INDEX BY BINARY_INTEGER;
TYPE reason_id_tbl_typ IS TABLE OF mtl_transaction_reasons.reason_id%TYPE INDEX BY BINARY_INTEGER;

l_access_id_tbl  access_id_tbl_typ;
l_reason_id_tbl  reason_id_tbl_typ;

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_MTL_TXN_REASONS_EVENT_PKG.Refresh_mtl_txn_reasons_acc ',
                         'CSM_MTL_TXN_REASONS_EVENT_PKG.Refresh_mtl_txn_reasons_acc',FND_LOG.LEVEL_PROCEDURE);

 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 IF l_access_id_tbl.count > 0 THEN
   l_access_id_tbl.delete;
 END IF;

  -- get resource list of all omfs palm users
 l_all_omfs_palm_resource_list := l_null_palm_omfs_resource_list;
 l_all_omfs_palm_resource_list := csm_util_pkg.get_all_omfs_palm_res_list;

 CSM_UTIL_PKG.LOG('Entering deletes ', 'CSM_MTL_TXN_REASONS_EVENT_PKG.Refresh_mtl_txn_reasons_acc',FND_LOG.LEVEL_PROCEDURE);

 -- process all deletes
 OPEN l_del_mtl_txn_reasons_csr(l_prog_update_date);
 FETCH l_del_mtl_txn_reasons_csr BULK COLLECT INTO l_access_id_tbl;
 CLOSE l_del_mtl_txn_reasons_csr;

 IF l_access_id_tbl.count > 0 THEN
   FOR i IN 1..l_access_id_tbl.count LOOP
     FOR j IN 1..l_all_omfs_palm_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_access_id_tbl(i),
                                                       l_all_omfs_palm_resource_list(j),
                                                       asg_download.del,
                                                       l_run_date);

     END LOOP;
   END LOOP;

   -- bulk delete from acc table
   FORALL i IN 1..l_access_id_tbl.count
     DELETE FROM csm_mtl_txn_reasons_acc WHERE access_id = l_access_id_tbl(i);

   l_access_id_tbl.delete;
 END IF; -- end of process deletes

 CSM_UTIL_PKG.LOG('Leaving deletes and entering updates', 'CSM_MTL_TXN_REASONS_EVENT_PKG.Refresh_mtl_txn_reasons_acc',FND_LOG.LEVEL_PROCEDURE);

 -- process all updates
 OPEN l_upd_mtl_txn_reasons_csr(l_prog_update_date);
 FETCH l_upd_mtl_txn_reasons_csr BULK COLLECT INTO l_access_id_tbl;
 CLOSE l_upd_mtl_txn_reasons_csr;

 IF l_access_id_tbl.count > 0 THEN
   FOR i IN 1..l_access_id_tbl.count LOOP
     FOR j IN 1..l_all_omfs_palm_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_access_id_tbl(i),
                                                       l_all_omfs_palm_resource_list(j),
                                                       asg_download.upd,
                                                       l_run_date);

     END LOOP;
   END LOOP;

   l_access_id_tbl.delete;
 END IF; -- end of process updates

 IF l_reason_id_tbl.count > 0 THEN
    l_reason_id_tbl.delete;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving updates and entering inserts', 'CSM_MTL_TXN_REASONS_EVENT_PKG.Refresh_mtl_txn_reasons_acc',FND_LOG.LEVEL_PROCEDURE);

 --process all inserts
 OPEN l_ins_mtl_txn_reasons_csr(l_prog_update_date);
 FETCH l_ins_mtl_txn_reasons_csr BULK COLLECT INTO l_access_id_tbl, l_reason_id_tbl;
 CLOSE l_ins_mtl_txn_reasons_csr;

-- logm('Insert Count: '  || l_access_id_tbl.count);

 IF l_access_id_tbl.count > 0 THEN
   FOR i IN 1..l_access_id_tbl.count LOOP
     FOR j IN 1..l_all_omfs_palm_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_access_id_tbl(i),
                                                       l_all_omfs_palm_resource_list(j),
                                                       asg_download.ins,
                                                       l_run_date);

     END LOOP;
   END LOOP;

   FORALL i IN 1..l_access_id_tbl.count
     INSERT INTO csm_mtl_txn_reasons_acc (access_id, reason_id, created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                                 VALUES (l_access_id_tbl(i), l_reason_id_tbl(i), fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

   l_access_id_tbl.delete;
 END IF; -- end of process inserts

  -- update last_run_date
 UPDATE jtm_con_request_data
 SET last_run_date = l_run_date
 WHERE package_name = 'CSM_MTL_TXN_REASONS_EVENT_PKG'
 AND procedure_name = 'REFRESH_MTL_TXN_REASONS_ACC';

 COMMIT;

 p_status := 'FINE';
 p_message :=  'CSM_MTL_TXN_REASONS_EVENT_PKG.REFRESH_MTL_TXN_REASONS_ACC Executed successfully';

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_TXN_REASONS_EVENT_PKG.Refresh_mtl_txn_reasons_acc ',
                         'CSM_MTL_TXN_REASONS_EVENT_PKG.Refresh_mtl_txn_reasons_acc',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_MTL_TXN_REASONS_EVENT_PKG.REFRESH_MTL_TXN_REASONS_ACC: '|| l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_TXN_REASONS_EVENT_PKG.REFRESH_MTL_TXN_REASONS_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_TXN_REASONS_EVENT_PKG.REFRESH_MTL_TXN_REASONS_ACC',FND_LOG.LEVEL_EXCEPTION);
END REFRESH_MTL_TXN_REASONS_ACC;

END CSM_MTL_TXN_REASONS_EVENT_PKG;

/
