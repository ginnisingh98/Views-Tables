--------------------------------------------------------
--  DDL for Package Body CSM_INV_LOC_ASS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_INV_LOC_ASS_EVENT_PKG" 
/* $Header: csmeilab.pls 120.1 2005/07/25 00:09:46 trajasek noship $*/
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

g_pub_item               CONSTANT VARCHAR2(30) := 'CSM_INV_LOC_ASS';

g_table_name1            CONSTANT VARCHAR2(30) := 'CSP_INV_LOC_ASSIGNMENTS';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_INV_LOC_ASS_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_INV_LOC_ASS_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_INV_LOC_ASS');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'CSP_INV_LOC_ASSIGNMENT_ID';

g_pub_item2              CONSTANT VARCHAR2(30) := 'CSM_MTL_SEC_INVENTORIES';
g_table_name2            CONSTANT VARCHAR2(30) := 'MTL_SEC_INVENTORIES';
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'CSM_MTL_SEC_INV_ACC';
g_acc_sequence_name2     CONSTANT VARCHAR2(30) := 'CSM_MTL_SEC_INV_ACC_S';
g_publication_item_name2 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_MTL_SEC_INVENTORIES');
g_pk1_name2              CONSTANT VARCHAR2(30) := 'SECONDARY_INVENTORY_NAME';
g_pk2_name2              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';

g_pub_item3              CONSTANT VARCHAR2(30) := 'CSM_MTL_ITEM_LOCATIONS';
g_table_name3            CONSTANT VARCHAR2(30) := 'MTL_ITEM_LOCATIONS';
g_acc_table_name3        CONSTANT VARCHAR2(30) := 'CSM_MTL_ITEM_LOCATIONS_ACC';
g_acc_sequence_name3     CONSTANT VARCHAR2(30) := 'CSM_MTL_ITEM_LOCATIONS_ACC_S';
g_publication_item_name3 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_MTL_ITEM_LOCATIONS');
g_pk1_name3              CONSTANT VARCHAR2(30) := 'INVENTORY_LOCATION_ID';
g_pk2_name3              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';

PROCEDURE INV_LOC_ASSIGNMENT_INS_INIT (p_csp_inv_loc_assignment_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_invLocAsgn_csr(p_csp_inv_loc_assg_id IN NUMBER)
IS
SELECT au.user_id AS user_id,
       invloc.resource_id AS resource_id,
       invLoc.organization_id AS organization_id,
       invLoc.subinventory_code AS subinventory_code
FROM   csp_inv_loc_assignments invLoc,
       asg_user au
WHERE  invloc.csp_inv_loc_assignment_id = p_csp_inv_loc_assg_id
AND    au.resource_id = invloc.resource_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering INV_LOC_ASSIGNMENT_INS_INIT for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_INS_INIT',FND_LOG.LEVEL_PROCEDURE);

   FOR r_invLocAsgn_rec IN l_invLocAsgn_csr(p_csp_inv_loc_assignment_id) LOOP
     -- download subinventory and locator info
     CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_I(p_csp_inv_loc_assignment_id=>p_csp_inv_loc_assignment_id,
                                                 p_user_id=>r_invLocAsgn_rec.user_id);

     -- not being used as there we are not supporting it right now
     -- download serial numbers for the subinv
     CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_I(p_csp_inv_loc_assignment_id=>p_csp_inv_loc_assignment_id,
                                                               p_user_id => r_invLocAsgn_rec.user_id);

     -- for inventory download....JTM Master conc program for INV needs to be run
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving INV_LOC_ASSIGNMENT_INS_INIT for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INV_LOC_ASSIGNMENT_INS_INIT for csp_inv_loc_assignment_id:'
                       || to_char(p_csp_inv_loc_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_INS_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INV_LOC_ASSIGNMENT_INS_INIT;

PROCEDURE INV_LOC_ASS_ACC_I(p_csp_inv_loc_assignment_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_subinventory_code csp_inv_loc_assignments.subinventory_code%TYPE;
l_organization_id csp_inv_loc_assignments.organization_id%TYPE;
l_inv_location_id mtl_item_locations.inventory_location_id%TYPE;
l_locator_org_id mtl_item_locations.organization_id%TYPE;

-- get subinventory/organization to insert into csm_mtl_sec_inv
CURSOR l_inv_loc_ass_csr(p_inv_loc_ass_id IN NUMBER)
IS
SELECT subinventory_code,
       organization_id
FROM  csp_inv_loc_assignments
WHERE csp_inv_loc_assignment_id = p_inv_loc_ass_id;

-- get inventory_location_id/organization_id to insert into csm_mtl_item_locations
CURSOR l_inv_location_csr(p_subinv_code IN VARCHAR2, p_organization_id IN NUMBER)
IS
SELECT mil.inventory_location_id, mil.organization_id
FROM mtl_item_locations mil
WHERE mil.subinventory_code = p_subinv_code
AND mil.organization_id = p_organization_id;

BEGIN
  CSM_UTIL_PKG.LOG('Entering INV_LOC_ASS_ACC_I for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_I',FND_LOG.LEVEL_PROCEDURE);

     OPEN l_inv_loc_ass_csr(p_csp_inv_loc_assignment_id);
     FETCH l_inv_loc_ass_csr INTO l_subinventory_code, l_organization_id;
     IF l_inv_loc_ass_csr%FOUND THEN
       CSM_ACC_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
        ,P_ACC_TABLE_NAME         => g_acc_table_name1
        ,P_SEQ_NAME               => g_acc_sequence_name1
        ,P_PK1_NAME               => g_pk1_name1
        ,P_PK1_NUM_VALUE          => p_csp_inv_loc_assignment_id
        ,P_USER_ID                => p_user_id
       );

       -- insert into csm_mtl_sec_inventories_acc
       CSM_ACC_PKG.Insert_Acc
      ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
       ,P_ACC_TABLE_NAME         => g_acc_table_name2
       ,P_SEQ_NAME               => g_acc_sequence_name2
       ,P_PK1_NAME               => g_pk1_name2
       ,P_PK1_CHAR_VALUE         => l_subinventory_code
       ,P_PK2_NAME               => g_pk2_name2
       ,P_PK2_NUM_VALUE          => l_organization_id
       ,P_USER_ID                => p_user_id
      );
     END IF;
     CLOSE l_inv_loc_ass_csr;

     OPEN l_inv_location_csr(l_subinventory_code, l_organization_id);
     LOOP
     FETCH l_inv_location_csr INTO l_inv_location_id, l_locator_org_id;
     IF l_inv_location_csr%NOTFOUND THEN
        EXIT;
     END IF;
       -- insert into csm_mtl_item_locations_acc
       CSM_ACC_PKG.Insert_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
        ,P_ACC_TABLE_NAME         => g_acc_table_name3
        ,P_SEQ_NAME               => g_acc_sequence_name3
        ,P_PK1_NAME               => g_pk1_name3
        ,P_PK1_NUM_VALUE         => l_inv_location_id
        ,P_PK2_NAME               => g_pk2_name3
        ,P_PK2_NUM_VALUE          => l_locator_org_id
        ,P_USER_ID                => p_user_id
       );

     END LOOP;
     CLOSE l_inv_location_csr;

   CSM_UTIL_PKG.LOG('Leaving INV_LOC_ASS_ACC_I for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_I',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INV_LOC_ASS_ACC_I for csp_inv_loc_assignment_id:'
                       || to_char(p_csp_inv_loc_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INV_LOC_ASS_ACC_I;

PROCEDURE INV_LOC_ASSIGNMENT_DEL_INIT(p_csp_inv_loc_assignment_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_cila_post_del_csr(p_csp_inv_loc_assignment_id IN NUMBER)
IS
SELECT cila.organization_id,
       cila.subinventory_code,
       cila.resource_id,
       au.user_id
FROM   csp_inv_loc_assignments cila,
       asg_user au
WHERE  cila.csp_inv_loc_assignment_id = p_csp_inv_loc_assignment_id
AND    au.resource_id = cila.resource_id;

BEGIN
   CSM_UTIL_PKG.LOG('Entering INV_LOC_ASSIGNMENT_DEL_INIT for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);

   FOR r_cila_post_del_rec IN l_cila_post_del_csr(p_csp_inv_loc_assignment_id) LOOP
     -- delete downloaded subinventory and locator info
     CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_D(p_csp_inv_loc_assignment_id=>p_csp_inv_loc_assignment_id,
                                                 p_user_id=>r_cila_post_del_rec.user_id);

     -- not being used as there we are not supporting it right now
     -- delete downloaded serial numbers for the subinv
     CSM_SERIAL_NUMBERS_EVENT_PKG.INV_LOC_ASS_MSN_MAKE_DIRTY_D(p_csp_inv_loc_assignment_id=>p_csp_inv_loc_assignment_id,
                                                               p_user_id => r_cila_post_del_rec.user_id);

     -- for inventory data to be deleted....JTM Master conc program for INV needs to be run
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving INV_LOC_ASSIGNMENT_DEL_INIT for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INV_LOC_ASSIGNMENT_DEL_INIT for csp_inv_loc_assignment_id:'
                       || to_char(p_csp_inv_loc_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INV_LOC_ASSIGNMENT_DEL_INIT;

PROCEDURE INV_LOC_ASS_ACC_D(p_csp_inv_loc_assignment_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_subinventory_code csp_inv_loc_assignments.subinventory_code%TYPE;
l_organization_id csp_inv_loc_assignments.organization_id%TYPE;
l_inv_location_id mtl_item_locations.inventory_location_id%TYPE;
l_locator_org_id mtl_item_locations.organization_id%TYPE;

-- get subinventory/organization to delete from csm_mtl_sec_inv
CURSOR l_inv_loc_ass_csr(p_inv_loc_ass_id IN NUMBER)
IS
SELECT subinventory_code,
       organization_id
FROM  csp_inv_loc_assignments
WHERE csp_inv_loc_assignment_id = p_inv_loc_ass_id;

-- get inventory_location_id/organization_id to delete from csm_mtl_item_locations
CURSOR l_inv_location_csr(p_subinv_code IN VARCHAR2, p_organization_id IN NUMBER)
IS
SELECT mil.inventory_location_id, mil.organization_id
FROM mtl_item_locations mil
WHERE mil.subinventory_code = p_subinv_code
AND mil.organization_id = p_organization_id;

BEGIN
  CSM_UTIL_PKG.LOG('Entering INV_LOC_ASS_ACC_D for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_D',FND_LOG.LEVEL_PROCEDURE);

     OPEN l_inv_loc_ass_csr(p_csp_inv_loc_assignment_id);
     FETCH l_inv_loc_ass_csr INTO l_subinventory_code, l_organization_id;
     IF l_inv_loc_ass_csr%FOUND THEN
        -- delete from csm_inv_loc_ass_acc
        CSM_ACC_PKG.Delete_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
         ,P_ACC_TABLE_NAME         => g_acc_table_name1
         ,P_PK1_NAME               => g_pk1_name1
         ,P_PK1_NUM_VALUE          => p_csp_inv_loc_assignment_id
         ,P_USER_ID                => p_user_id
        );

        -- delete from csm_mtl_sec_inventories_acc
        CSM_ACC_PKG.Delete_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
         ,P_ACC_TABLE_NAME         => g_acc_table_name2
         ,P_PK1_NAME               => g_pk1_name2
         ,P_PK1_CHAR_VALUE         => l_subinventory_code
         ,P_PK2_NAME               => g_pk2_name2
         ,P_PK2_NUM_VALUE          => l_organization_id
         ,P_USER_ID                => p_user_id
        );

     END IF;
     CLOSE l_inv_loc_ass_csr;

     OPEN l_inv_location_csr(l_subinventory_code, l_organization_id);
     LOOP
     FETCH l_inv_location_csr INTO l_inv_location_id, l_locator_org_id;
     IF l_inv_location_csr%NOTFOUND THEN
        EXIT;
     END IF;

       -- delete from csm_mtl_item_locations_acc
       CSM_ACC_PKG.Delete_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name3
        ,P_ACC_TABLE_NAME         => g_acc_table_name3
        ,P_PK1_NAME               => g_pk1_name3
        ,P_PK1_NUM_VALUE         => l_inv_location_id
        ,P_PK2_NAME               => g_pk2_name3
        ,P_PK2_NUM_VALUE          => l_locator_org_id
        ,P_USER_ID                => p_user_id
       );

     END LOOP;
     CLOSE l_inv_location_csr;

  CSM_UTIL_PKG.LOG('Leaving INV_LOC_ASS_ACC_D for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_D',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INV_LOC_ASS_ACC_D for csp_inv_loc_assignment_id:'
                       || to_char(p_csp_inv_loc_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASS_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INV_LOC_ASS_ACC_D;

PROCEDURE INV_LOC_ASSIGNMENT_UPD_INIT(p_csp_inv_loc_assignment_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_invLocAsgn_csr(p_csp_inv_loc_assg_id IN NUMBER)
IS
SELECT acc.access_id,
       acc.user_id
FROM   csm_inv_loc_ass_acc acc,
       csp_inv_loc_assignments cila
WHERE  acc.csp_inv_loc_assignment_id = p_csp_inv_loc_assg_id
AND    cila.csp_inv_loc_assignment_id = acc.csp_inv_loc_assignment_id;

l_invLocAsgn_rec l_invLocAsgn_csr%ROWTYPE;

BEGIN
  CSM_UTIL_PKG.LOG('Entering INV_LOC_ASSIGNMENT_UPD_INIT for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_UPD_INIT',FND_LOG.LEVEL_PROCEDURE);

  OPEN l_invLocAsgn_csr(p_csp_inv_loc_assignment_id);
  FETCH l_invLocAsgn_csr INTO l_invLocAsgn_rec;
  IF l_invLocAsgn_csr%FOUND THEN
     -- call the mark dirty for update
     CSM_ACC_PKG.Update_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
        ,P_ACC_TABLE_NAME         => g_acc_table_name1
        ,P_USER_ID                => l_invLocAsgn_rec.user_id
        ,P_ACCESS_ID              => l_invLocAsgn_rec.access_id
       );

  END IF;
  CLOSE l_invLocAsgn_csr;

  CSM_UTIL_PKG.LOG('Leaving INV_LOC_ASSIGNMENT_UPD_INIT for csp_inv_loc_assignment_id: ' || p_csp_inv_loc_assignment_id,
                                   'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_UPD_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  INV_LOC_ASSIGNMENT_UPD_INIT for csp_inv_loc_assignment_id:'
                       || to_char(p_csp_inv_loc_assignment_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_INV_LOC_ASS_EVENT_PKG.INV_LOC_ASSIGNMENT_UPD_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END INV_LOC_ASSIGNMENT_UPD_INIT;

END CSM_INV_LOC_ASS_EVENT_PKG;

/
