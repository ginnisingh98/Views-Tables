--------------------------------------------------------
--  DDL for Package Body CSM_MTL_SEC_INV_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_SEC_INV_EVENT_PKG" 
/* $Header: csmemsb.pls 120.1 2005/07/25 00:12:26 trajasek noship $*/
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

g_table_name1            CONSTANT VARCHAR2(30) := 'MTL_SEC_INVENTORIES';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_MTL_SEC_INV_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_MTL_SEC_INV_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_MTL_SEC_INVENTORIES');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'SECONDARY_INVENTORY_NAME';
g_pk2_name1              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSM_MTL_SEC_INVENTORIES';

PROCEDURE insert_mtl_sec_inventory( p_user_id       NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id   NUMBER)
IS
l_sqlerrno         varchar2(20);
l_sqlerrmsg        varchar2(2000);

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SEC_INV_EVENT_PKG.insert_mtl_sec_inventory ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.insert_mtl_sec_inventory',FND_LOG.LEVEL_PROCEDURE);

 CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_CHAR_VALUE          => p_subinventory_code
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => p_organization_id
      ,P_USER_ID                => p_user_id
     );

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SEC_INV_EVENT_PKG.insert_mtl_sec_inventory ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.insert_mtl_sec_inventory',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_SEC_INV_EVENT_PKG.insert_mtl_sec_inventory: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_SEC_INV_EVENT_PKG.insert_mtl_sec_inventory', FND_LOG.LEVEL_EXCEPTION);

END insert_mtl_sec_inventory;

PROCEDURE update_mtl_sec_inventory( p_user_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER)
IS
l_sqlerrno         varchar2(20);
l_sqlerrmsg        varchar2(2000);
l_access_id         number;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SEC_INV_EVENT_PKG.update_mtl_sec_inventory ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.update_mtl_sec_inventory',FND_LOG.LEVEL_PROCEDURE);

 l_access_id := CSM_ACC_PKG.Get_Acc_Id
                            ( P_ACC_TABLE_NAME         => g_acc_table_name1
                             ,P_PK1_NAME               => g_pk1_name1
                             ,P_PK1_CHAR_VALUE          => p_subinventory_code
                             ,P_PK2_NAME               => g_pk2_name1
                             ,P_PK2_NUM_VALUE          => p_organization_id
                             ,P_USER_ID                => p_user_id
                             );

 CSM_ACC_PKG.Update_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
        ,P_ACC_TABLE_NAME         => g_acc_table_name1
        ,P_ACCESS_ID              => l_access_id
        ,P_USER_ID                => p_user_id
        );

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SEC_INV_EVENT_PKG.update_mtl_sec_inventory ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.update_mtl_sec_inventory',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_SEC_INV_EVENT_PKG.update_mtl_sec_inventory: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_SEC_INV_EVENT_PKG.update_mtl_sec_inventory', FND_LOG.LEVEL_EXCEPTION);

END update_mtl_sec_inventory;

PROCEDURE delete_mtl_sec_inventory( p_user_id   NUMBER
                                  , p_subinventory_code VARCHAR2
                                  , p_organization_id NUMBER)
IS
l_sqlerrno         varchar2(20);
l_sqlerrmsg        varchar2(2000);

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SEC_INV_EVENT_PKG.delete_mtl_sec_inventory ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.delete_mtl_sec_inventory',FND_LOG.LEVEL_PROCEDURE);

 CSM_ACC_PKG.Delete_Acc
         ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
          ,P_ACC_TABLE_NAME         => g_acc_table_name1
          ,P_PK1_NAME               => g_pk1_name1
          ,P_PK1_CHAR_VALUE          => p_subinventory_code
          ,P_PK2_NAME               => g_pk2_name1
          ,P_PK2_NUM_VALUE          => p_organization_id
          ,P_USER_ID                => p_user_id
         );

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SEC_INV_EVENT_PKG.delete_mtl_sec_inventory ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.delete_mtl_sec_inventory',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_SEC_INV_EVENT_PKG.delete_mtl_sec_inventory: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_SEC_INV_EVENT_PKG.delete_mtl_sec_inventory', FND_LOG.LEVEL_EXCEPTION);

END delete_mtl_sec_inventory;

PROCEDURE refresh_acc(p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_sqlerrno             varchar2(20);
l_sqlerrmsg            varchar2(2000);
l_mark_dirty           boolean;
l_prog_update_date     jtm_con_request_data.last_run_date%TYPE;
l_run_date             date;

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_MTL_SEC_INV_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

CURSOR l_upd_mtl_sec_inv_csr(p_last_upd_date IN date)
IS
SELECT acc.access_id, acc.user_id
FROM  mtl_secondary_inventories msi,
      csm_mtl_sec_inv_acc acc
WHERE msi.secondary_inventory_name = acc.secondary_inventory_name
AND   msi.organization_id = acc.organization_id
AND   msi.last_update_date >= p_last_upd_date;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_SEC_INV_EVENT_PKG.refresh_acc ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.refresh_acc',FND_LOG.LEVEL_PROCEDURE);

 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 -- get all updated records from the backend table and post them to olite
 FOR r_upd_mtl_sec_inv_rec IN l_upd_mtl_sec_inv_csr(l_prog_update_date) LOOP
    l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForUser(g_pub_item,
                                                  r_upd_mtl_sec_inv_rec.access_id,
                                                  r_upd_mtl_sec_inv_rec.user_id,
                                                  ASG_DOWNLOAD.UPD,
                                                  l_run_date);
 END LOOP;

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_run_date
  WHERE package_name = 'CSM_MTL_SEC_INV_EVENT_PKG'
    AND procedure_name = 'REFRESH_ACC';

 COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_MTL_SEC_INV_EVENT_PKG.Refresh_Acc Executed successfully';

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_SEC_INV_EVENT_PKG.refresh_acc ',
                         'CSM_MTL_SEC_INV_EVENT_PKG.refresh_acc',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_MTL_SEC_INV_EVENT_PKG.Refresh_Acc:' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_SEC_INV_EVENT_PKG.refresh_acc: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_SEC_INV_EVENT_PKG.refresh_acc',FND_LOG.LEVEL_EXCEPTION);
END refresh_acc;

END CSM_MTL_SEC_INV_EVENT_PKG;

/
