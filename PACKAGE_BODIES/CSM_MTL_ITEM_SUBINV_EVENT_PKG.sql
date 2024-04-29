--------------------------------------------------------
--  DDL for Package Body CSM_MTL_ITEM_SUBINV_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_ITEM_SUBINV_EVENT_PKG" AS
/* $Header: csmemisb.pls 120.1 2005/07/25 00:11:58 trajasek noship $*/
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

g_table_name1            CONSTANT VARCHAR2(30) := 'MTL_ITEM_SUB_INVENTORIES';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_MTL_ITEM_SUBINV_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_MTL_ITEM_SUBINV_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_MTL_ITEM_SUBINV');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'INVENTORY_ITEM_ID';
g_pk2_name1              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_pk3_name1              CONSTANT VARCHAR2(30) := 'SECONDARY_INVENTORY';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSM_MTL_ITEM_SUBINV';

PROCEDURE INSERT_MTL_ITEM_SUBINV( p_organization_id IN number
                                 , p_user_id     IN number
		                               , p_last_run_date   IN date)
IS
TYPE inventory_item_tbl_typ  IS TABLE OF mtl_system_items_b.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE organization_tbl_typ   IS TABLE OF mtl_system_items_b.organization_id%TYPE
INDEX BY BINARY_INTEGER;
TYPE secondary_inventory_typ IS TABLE OF mtl_item_sub_inventories.secondary_inventory%TYPE INDEX BY BINARY_INTEGER;
TYPE access_id_tbl_typ IS TABLE OF number INDEX BY binary_integer;
TYPE user_id_tbl_typ IS TABLE OF number INDEX BY binary_integer;

l_inventory_items_tbl inventory_item_tbl_typ;
l_organizations_tbl organization_tbl_typ;
l_sec_inventory_tbl secondary_inventory_typ;
l_access_id_tbl access_id_tbl_typ;
l_mark_dirty boolean;
l_run_date date;
l_sqlerrno             varchar2(20);
l_sqlerrmsg            varchar2(2000);

CURSOR l_ins_mtl_item_subinv_csr(p_organizationid IN number,
                                  p_userid IN number,
                                  p_lastrundate IN date)
IS
SELECT cila_acc.user_id, mis.inventory_item_id, mis.organization_id, mis.secondary_inventory
FROM csm_mtl_system_items_acc msi_acc,
     csm_inv_loc_ass_acc cila_acc,
     csp_inv_loc_assignments cila,
     mtl_item_sub_inventories mis
WHERE msi_acc.inventory_item_id = mis.inventory_item_id
AND msi_acc.organization_id = mis.organization_id
AND cila.csp_inv_loc_assignment_id = cila_acc.csp_inv_loc_assignment_id
AND cila.subinventory_code = mis.secondary_inventory
AND cila_acc.user_id = msi_acc.user_id
AND NOT EXISTS
    (SELECT 1
     FROM csm_mtl_item_subinv_acc acc
     WHERE acc.user_id = msi_acc.user_id
     AND acc.inventory_item_id = mis.inventory_item_id
     AND acc.organization_id = mis.organization_id
     AND acc.secondary_inventory = mis.secondary_inventory
     );

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_ITEM_SUBINV_EVENT_PKG.INSERT_MTL_ITEM_SUBINV ',
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.INSERT_MTL_ITEM_SUBINV',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

 -- process inserts
 OPEN l_ins_mtl_item_subinv_csr(p_organization_id, p_user_id, p_last_run_date);
 FETCH l_ins_mtl_item_subinv_csr BULK COLLECT INTO  l_access_id_tbl, l_inventory_items_tbl, l_organizations_tbl, l_sec_inventory_tbl;
 CLOSE l_ins_mtl_item_subinv_csr;

 IF l_access_id_tbl.count > 0 THEN
   FORALL i IN 1..l_access_id_tbl.count
      INSERT INTO csm_mtl_item_subinv_acc(access_id, user_id, inventory_item_id, organization_id, secondary_inventory, counter,
                                           created_by, creation_date, last_updated_by, last_update_date, last_update_login)
                                    VALUES (l_access_id_tbl(i), p_user_id, l_inventory_items_tbl(i), l_organizations_tbl(i),l_sec_inventory_tbl(i), 1,
                                            fnd_global.user_id, l_run_date, fnd_global.user_id, l_run_date, fnd_global.login_id);

   CSM_UTIL_PKG.LOG('Bulk inserted ' || l_access_id_tbl.count || ' records into csm_mtl_item_subinv_acc for user ' || p_user_id ,
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.INSERT_MTL_ITEM_SUBINV',FND_LOG.LEVEL_STATEMENT);

   -- make dirty calls
   FOR i IN 1..l_access_id_tbl.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(g_pub_item,
                                                    l_access_id_tbl(i),
                                                    p_user_id,
                                                    asg_download.ins,
                                                    l_run_date);
   END LOOP;

   l_access_id_tbl.delete;

 END IF;

/* --insert into acc
 FOR i IN 1..l_inventory_items_tbl.count LOOP
   CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => l_inventory_items_tbl(i)
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => l_organizations_tbl(i)
      ,P_PK3_NAME               => g_pk3_name1
      ,P_PK3_CHAR_VALUE         => l_sec_inventory_tbl(i)
      ,P_USER_ID                => p_user_id
     );
 END LOOP;
*/

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_ITEM_SUBINV_EVENT_PKG.INSERT_MTL_ITEM_SUBINV ',
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.INSERT_MTL_ITEM_SUBINV',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
--     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_ITEM_SUBINV_EVENT_PKG.INSERT_MTL_ITEM_SUBINV: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.INSERT_MTL_ITEM_SUBINV',FND_LOG.LEVEL_EXCEPTION);
END INSERT_MTL_ITEM_SUBINV;


PROCEDURE UPDATE_MTL_ITEM_SUBINV( p_organization_id IN number
                                 , p_user_id     IN number
		                               , p_last_run_date   IN date)
IS
TYPE access_id_tbl_typ  IS TABLE OF csm_mtl_system_items_acc.access_id%TYPE INDEX BY BINARY_INTEGER;
l_access_id_tbl  access_id_tbl_typ;
l_mark_dirty boolean;
l_run_date date;
l_sqlerrno  varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_upd_mtl_item_subinv_csr( p_organizationid IN number
                                 , p_lastrundate IN DATE
                                 , p_userid IN NUMBER) IS
SELECT access_id
FROM csm_mtl_item_subinv_acc acc
,    mtl_item_sub_inventories mis
WHERE mis.inventory_item_id = acc.inventory_item_id
AND   mis.organization_id = acc.organization_id
AND   mis.secondary_inventory = acc.secondary_inventory
AND   mis.last_update_date  >= p_last_run_date
AND   acc.organization_id = p_organizationid
AND   acc.user_id = p_userid;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_ITEM_SUBINV_EVENT_PKG.UPDATE_MTL_ITEM_SUBINV ',
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.UPDATE_MTL_ITEM_SUBINV',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

 IF l_access_id_tbl.count > 0 THEN
    l_access_id_tbl.DELETE;
 END IF;

 OPEN l_upd_mtl_item_subinv_csr(p_organization_id, p_last_run_date, p_user_id);
 FETCH l_upd_mtl_item_subinv_csr BULK COLLECT INTO l_access_id_tbl;
 CLOSE l_upd_mtl_item_subinv_csr;

 IF l_access_id_tbl.count > 0 THEN
   -- make dirty calls
   FOR i IN 1..l_access_id_tbl.count LOOP
         CSM_ACC_PKG.Update_Acc
               ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                ,P_ACC_TABLE_NAME         => g_acc_table_name1
                ,P_ACCESS_ID              => l_access_id_tbl(i)
                ,P_USER_ID                => p_user_id
               );
   END LOOP;

   l_access_id_tbl.DELETE;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_ITEM_SUBINV_EVENT_PKG.UPDATE_MTL_ITEM_SUBINV ',
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.UPDATE_MTL_ITEM_SUBINV',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_ITEM_SUBINV_EVENT_PKG.UPDATE_MTL_ITEM_SUBINV: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.UPDATE_MTL_ITEM_SUBINV',FND_LOG.LEVEL_EXCEPTION);
END UPDATE_MTL_ITEM_SUBINV;


PROCEDURE DELETE_MTL_ITEM_SUBINV( p_organization_id IN number
                                 , p_user_id     IN number
		                               , p_last_run_date   IN date)
IS
TYPE inventory_item_tbl_typ  IS TABLE OF mtl_system_items_b.inventory_item_id%TYPE INDEX BY BINARY_INTEGER;
TYPE organization_tbl_typ   IS TABLE OF mtl_system_items_b.organization_id%TYPE INDEX BY BINARY_INTEGER;
TYPE secondary_inventory_typ IS TABLE OF mtl_item_sub_inventories.secondary_inventory%TYPE INDEX BY BINARY_INTEGER;
l_inventory_items_tbl inventory_item_tbl_typ;
l_organizations_tbl organization_tbl_typ;
l_sec_inventory_tbl secondary_inventory_typ;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_del_mtl_item_subinv_csr( p_organizationid IN number
                                , p_userid IN NUMBER)
IS
SELECT acc.inventory_item_id, acc.organization_id, acc.secondary_inventory
FROM  csm_mtl_item_subinv_acc acc
WHERE acc.user_id = p_userid
AND   acc.organization_id = p_organizationid
AND   NOT EXISTS
     (SELECT 1
      FROM mtl_item_sub_inventories mis
      WHERE mis.inventory_item_id = acc.inventory_item_id
      AND mis.organization_id = acc.organization_id
      AND mis.secondary_inventory = acc.secondary_inventory
      );

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_ITEM_SUBINV_EVENT_PKG.DELETE_MTL_ITEM_SUBINV ',
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.DELETE_MTL_ITEM_SUBINV',FND_LOG.LEVEL_PROCEDURE);

 IF l_inventory_items_tbl.count > 0 THEN
    l_inventory_items_tbl.delete;
 END IF;

 IF l_organizations_tbl.count > 0 THEN
    l_organizations_tbl.delete;
 END IF;

 IF l_sec_inventory_tbl.count > 0 THEN
    l_sec_inventory_tbl.delete;
 END IF;

 -- process deletes
 OPEN l_del_mtl_item_subinv_csr(p_organization_id, p_user_id);
 FETCH l_del_mtl_item_subinv_csr BULK COLLECT INTO  l_inventory_items_tbl, l_organizations_tbl, l_sec_inventory_tbl;
 CLOSE l_del_mtl_item_subinv_csr;

 IF l_inventory_items_tbl.count > 0 THEN
   -- make dirty calls
   FOR i IN 1..l_inventory_items_tbl.count LOOP
    CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => l_inventory_items_tbl(i)
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => l_organizations_tbl(i)
      ,P_PK3_NAME               => g_pk3_name1
      ,P_PK3_CHAR_VALUE         => l_sec_inventory_tbl(i)
      ,P_USER_ID                => p_user_id
     );
   END LOOP;

 END IF;

 CSM_UTIL_PKG.LOG('Leaving CSM_MTL_ITEM_SUBINV_EVENT_PKG.DELETE_MTL_ITEM_SUBINV ',
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.DELETE_MTL_ITEM_SUBINV',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_ITEM_SUBINV_EVENT_PKG.DELETE_MTL_ITEM_SUBINV: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.DELETE_MTL_ITEM_SUBINV',FND_LOG.LEVEL_EXCEPTION);
END DELETE_MTL_ITEM_SUBINV;


PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_access_id jtm_fnd_lookups_acc.access_id%TYPE;
l_all_omfs_palm_resource_list asg_download.user_list;
l_valid_omfs_resource_list asg_download.user_list;
l_null_palm_omfs_resource_list asg_download.user_list;
l_user_id fnd_user.user_id%TYPE;
l_user_palm_organization_id mtl_system_items.organization_id%TYPE;
l_user_language mtl_system_items_tl.language%TYPE;
l_run_date date;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_MTL_ITEM_SUBINV_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

--process inserts
CURSOR l_ins_mtl_item_subinv_csr
IS
SELECT cila_acc.user_id, mis.inventory_item_id, mis.organization_id, mis.secondary_inventory
FROM csm_mtl_system_items_acc msi_acc,
     csm_inv_loc_ass_acc cila_acc,
     csp_inv_loc_assignments cila,
     mtl_item_sub_inventories mis
WHERE msi_acc.inventory_item_id = mis.inventory_item_id
AND msi_acc.organization_id = mis.organization_id
AND cila.csp_inv_loc_assignment_id = cila_acc.csp_inv_loc_assignment_id
AND cila.subinventory_code = mis.secondary_inventory
AND cila_acc.user_id = msi_acc.user_id
AND NOT EXISTS
    (SELECT 1
     FROM csm_mtl_item_subinv_acc acc
     WHERE acc.user_id = msi_acc.user_id
     AND acc.inventory_item_id = mis.inventory_item_id
     AND acc.organization_id = mis.organization_id
     AND acc.secondary_inventory = mis.secondary_inventory
     );

-- process updates
CURSOR l_upd_mtl_item_subinv_csr(p_last_upd_date DATE)
IS
SELECT acc.access_id, acc.secondary_inventory, acc.organization_id,
       acc.inventory_item_id, acc.user_id
FROM csm_mtl_item_subinv_acc acc,
     mtl_item_sub_inventories mis
WHERE mis.inventory_item_id = acc.inventory_item_id
AND mis.secondary_inventory = acc.secondary_inventory
AND mis.organization_id = acc.organization_id
AND mis.last_update_date >= p_last_upd_date;

-- process deletes
CURSOR l_del_mtl_item_subinv_csr
IS
SELECT acc.access_id, acc.secondary_inventory, acc.organization_id,
       acc.inventory_item_id, acc.user_id
FROM csm_mtl_item_subinv_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM csm_mtl_system_items_acc msi_acc,
     csm_inv_loc_ass_acc cila_acc,
     csp_inv_loc_assignments cila,
     mtl_item_sub_inventories mis
 WHERE msi_acc.inventory_item_id = mis.inventory_item_id
 AND msi_acc.organization_id = mis.organization_id
 AND cila.csp_inv_loc_assignment_id = cila_acc.csp_inv_loc_assignment_id
 AND cila.subinventory_code = mis.secondary_inventory
 AND cila_acc.user_id = msi_acc.user_id
 AND msi_acc.user_id = acc.user_id
 AND msi_acc.inventory_item_id = acc.inventory_item_id
 AND msi_acc.organization_id = acc.organization_id
 AND acc.secondary_inventory = cila.subinventory_code
 );

CURSOR l_user_id_csr (p_resourceid IN number)
IS
SELECT user_id
FROM asg_user
WHERE resource_id = p_resourceid;

BEGIN
 CSM_UTIL_PKG.LOG('Entering CSM_MTL_ITEM_SUBINV_EVENT_PKG.Refresh_acc ',
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.Refresh_acc',FND_LOG.LEVEL_PROCEDURE);

 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 -- process deletes
 FOR r_del_mtl_item_subinv_rec IN l_del_mtl_item_subinv_csr LOOP
   CSM_ACC_PKG.Delete_acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => r_del_mtl_item_subinv_rec.inventory_item_id
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => r_del_mtl_item_subinv_rec.organization_id
      ,P_PK3_NAME               => g_pk3_name1
      ,P_PK3_CHAR_VALUE         => r_del_mtl_item_subinv_rec.secondary_inventory
      ,P_USER_ID                => r_del_mtl_item_subinv_rec.user_id
      );
 END LOOP;

-- process updates
 FOR r_upd_mtl_item_subinv_rec IN l_upd_mtl_item_subinv_csr(l_prog_update_date) LOOP
   CSM_ACC_PKG.Update_acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_ACCESS_ID              => r_upd_mtl_item_subinv_rec.access_id
      ,P_USER_ID                => r_upd_mtl_item_subinv_rec.user_id
      );
 END LOOP;

 -- process inserts
 FOR r_ins_mtl_item_subinv_rec IN l_ins_mtl_item_subinv_csr LOOP
     CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => r_ins_mtl_item_subinv_rec.inventory_item_id
      ,P_PK2_NAME               => g_pk2_name1
      ,P_PK2_NUM_VALUE          => r_ins_mtl_item_subinv_rec.organization_id
      ,P_PK3_NAME               => g_pk3_name1
      ,P_PK3_CHAR_VALUE         => r_ins_mtl_item_subinv_rec.secondary_inventory
      ,P_USER_ID                => r_ins_mtl_item_subinv_rec.user_id
     );
 END LOOP;

 -- update last_run_date
 UPDATE jtm_con_request_data
 SET last_run_date = l_run_date
 WHERE package_name = 'CSM_MTL_ITEM_SUBINV_EVENT_PKG'
 AND procedure_name = 'REFRESH_ACC';

 COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_MTL_ITEM_SUBINV_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_MTL_ITEM_SUBINV_EVENT_PKG.Refresh_Acc: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_MTL_ITEM_SUBINV_EVENT_PKG.refresh_acc: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_MTL_ITEM_SUBINV_EVENT_PKG.refresh_acc',FND_LOG.LEVEL_EXCEPTION);
END Refresh_acc;

END CSM_MTL_ITEM_SUBINV_EVENT_PKG;

/
