--------------------------------------------------------
--  DDL for Package Body CSM_MTL_SEC_LOCATORS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_SEC_LOCATORS_EVENT_PKG" AS
/* $Header: csmemslb.pls 120.1 2005/07/25 00:13:47 trajasek noship $*/
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

g_table_name1            CONSTANT VARCHAR2(30) := 'CSM_MTL_SECONDARY_LOCATORS';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_MTL_SECONDARY_LOCATORS_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_MTL_SEC_LOCATORS_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_MTL_SECONDARY_LOCATORS');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_pk2_name1              CONSTANT VARCHAR2(30) := 'SECONDARY_LOCATOR';
g_pk3_name1              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSM_MTL_SECONDARY_LOCATORS';

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_pub_item VARCHAR2(30) := 'CSM_MTL_SECONDARY_LOCATORS';
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_access_id jtm_fnd_lookups_acc.access_id%TYPE;
l_mark_dirty boolean;
l_all_omfs_palm_resource_list asg_download.user_list;
l_null_resource_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;
l_run_date date;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_MTL_SEC_LOCATORS_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

-- process inserts
CURSOR l_mtl_sec_loc_ins_csr
IS
SELECT msi_acc.user_id, msl.inventory_item_id,
      msl.organization_id, msl.secondary_locator
FROM csm_mtl_system_items_acc msi_acc,
     csm_mtl_item_locations_acc mil_acc,
     mtl_secondary_locators msl
WHERE msl.inventory_item_id = msi_acc.inventory_item_id
AND msl.organization_id = msi_acc.organization_id
AND msl.secondary_locator = mil_acc.inventory_location_id
AND msl.organization_id = mil_acc.organization_id
AND msi_acc.user_id = mil_acc.user_id
AND NOT EXISTS
(SELECT 1
 FROM csm_mtl_secondary_locators_acc acc
 WHERE acc.user_id = msi_acc.user_id
 AND acc.inventory_item_id = msi_acc.inventory_item_id
 AND acc.organization_id = msi_acc.organization_id
 AND acc.secondary_locator = msl.secondary_locator
);

-- process updates
CURSOR l_mtl_sec_loc_upd_csr(p_last_upd_date DATE)
IS
SELECT acc.access_id, acc.secondary_locator, acc.organization_id,
       acc.inventory_item_id, acc.user_id
FROM csm_mtl_secondary_locators_acc acc,
     mtl_secondary_locators msl
WHERE msl.secondary_locator = acc.secondary_locator
AND msl.organization_id = acc.organization_id
AND msl.inventory_item_id = acc.inventory_item_id
AND msl.last_update_date >= p_last_upd_date;

-- process deletes
CURSOR l_mtl_sec_loc_del_csr
IS
SELECT acc.user_id, acc.secondary_locator, acc.organization_id, acc.inventory_item_id
FROM csm_mtl_secondary_locators_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM csm_mtl_system_items_acc msi_acc,
      csm_mtl_item_locations_acc mil_acc,
      mtl_secondary_locators msl
 WHERE msl.inventory_item_id = msi_acc.inventory_item_id
 AND msl.organization_id = msi_acc.organization_id
 AND msl.secondary_locator = mil_acc.inventory_location_id
 AND msl.organization_id = mil_acc.organization_id
 AND msi_acc.user_id = mil_acc.user_id
 AND acc.secondary_locator = msl.secondary_locator
 AND acc.organization_id = msl.organization_id
 AND acc.inventory_item_id = msl.inventory_item_id
 AND acc.user_id = msi_acc.user_id
 );

BEGIN
 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 -- process deletes
 FOR r_mtl_sec_loc_del_rec IN l_mtl_sec_loc_del_csr LOOP
   CSM_ACC_PKG.Delete_acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => r_mtl_sec_loc_del_rec.inventory_item_id
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => r_mtl_sec_loc_del_rec.secondary_locator
      ,P_PK3_NAME               => g_pk3_name1
      ,P_PK3_NUM_VALUE          => r_mtl_sec_loc_del_rec.organization_id
      ,P_USER_ID                => r_mtl_sec_loc_del_rec.user_id
      );
 END LOOP;

-- process updates
 FOR r_mtl_sec_loc_upd_rec IN l_mtl_sec_loc_upd_csr(l_prog_update_date) LOOP
   CSM_ACC_PKG.Update_acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_ACCESS_ID              => r_mtl_sec_loc_upd_rec.access_id
      ,P_USER_ID                 => r_mtl_sec_loc_upd_rec.user_id
      );
 END LOOP;

 -- process inserts
 FOR r_mtl_sec_loc_ins_rec IN l_mtl_sec_loc_ins_csr LOOP
     CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => r_mtl_sec_loc_ins_rec.inventory_item_id
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => r_mtl_sec_loc_ins_rec.secondary_locator
      ,P_PK3_NAME               => g_pk3_name1
      ,P_PK3_NUM_VALUE          => r_mtl_sec_loc_ins_rec.organization_id
      ,P_USER_ID                => r_mtl_sec_loc_ins_rec.user_id
     );
 END LOOP;

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_run_date
  WHERE package_name = 'CSM_MTL_SEC_LOCATORS_EVENT_PKG'
    AND procedure_name = 'REFRESH_ACC';

 COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_MTL_SEC_LOCATORS_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_MTL_SEC_LOCATORS_EVENT_PKG.Refresh_Acc:' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('CSM_MTL_SEC_LOCATORS_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg, 'CSM_MTL_SEC_LOCATORS_EVENT_PKG.Refresh_acc',FND_LOG.LEVEL_EXCEPTION);
END Refresh_Acc;

END CSM_MTL_SEC_LOCATORS_EVENT_PKG;

/
