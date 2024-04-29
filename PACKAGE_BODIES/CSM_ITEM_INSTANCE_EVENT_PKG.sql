--------------------------------------------------------
--  DDL for Package Body CSM_ITEM_INSTANCE_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_ITEM_INSTANCE_EVENT_PKG" AS
/* $Header: csmeibb.pls 120.11 2008/06/20 08:02:58 trajasek ship $ */

-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

g_table_name1            CONSTANT VARCHAR2(30) := 'CSI_ITEM_INSTANCES';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_ITEM_INSTANCES_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_ITEM_INSTANCES_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_ITEM_INSTANCES');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'INSTANCE_ID';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSF_M_ITEM_INSTANCES';

g_table_name2            CONSTANT VARCHAR2(30) := 'CSI_II_RELATIONSHIPS';
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'CSM_II_RELATIONSHIPS_ACC';
g_acc_sequence_name2     CONSTANT VARCHAR2(30) := 'CSM_II_RELATIONSHIPS_ACC_S';
g_publication_item_name2 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_II_RELATIONSHIPS');
g_pk1_name2              CONSTANT VARCHAR2(30) := 'RELATIONSHIP_ID';
g_pub_item2               CONSTANT VARCHAR2(30) := 'CSF_M_II_RELATIONSHIPS';

PROCEDURE ITEM_INSTANCE_MDIRTY_U_ECHUSER(p_instance_id IN NUMBER,
                                         p_error_msg     OUT NOCOPY    VARCHAR2,
                                         x_return_status IN OUT NOCOPY VARCHAR2)
IS
cursor l_instance_users_csr (p_instance_id csm_item_instances_acc.instance_id%TYPE) is
SELECT access_id, user_id
FROM csm_item_instances_acc
WHERE instance_id = p_instance_id;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCE_MDIRTY_U_ECHUSER ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCE_MDIRTY_U_ECHUSER',FND_LOG.LEVEL_PROCEDURE);

 -- get users who have access to this instance_ID
 FOR r_instance_users_rec in l_instance_users_csr(p_instance_id) LOOP
      CSM_ACC_PKG.Update_Acc
         ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
          ,P_ACC_TABLE_NAME         => g_acc_table_name1
          ,P_ACCESS_ID              => r_instance_users_rec.access_id
          ,P_USER_ID                => r_instance_users_rec.user_id
         );
 END LOOP;

 p_error_msg := 'SUCCESS';
 CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCE_MDIRTY_U_ECHUSER ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCE_MDIRTY_U_ECHUSER',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_msg := 'FAILED ITEM_INSTANCE_MDIRTY_U_ECHUSER InstanceId:' || p_instance_id;
       CSM_UTIL_PKG.LOG(p_error_msg,'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCE_MDIRTY_U_ECHUSER',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END ITEM_INSTANCE_MDIRTY_U_ECHUSER;

PROCEDURE II_RELATIONSHIPS_ACC_I(p_relationship_id IN NUMBER,
                                 p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_I ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_I',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
      ,P_ACC_TABLE_NAME         => g_acc_table_name2
      ,P_SEQ_NAME               => g_acc_sequence_name2
      ,P_PK1_NAME               => g_pk1_name2
      ,P_PK1_NUM_VALUE          => p_relationship_id
      ,P_USER_ID                => p_user_id
     );

  p_error_msg := 'SUCCESS';
  CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_I ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_I', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  	    p_error_msg := ' FAILED II_RELATIONSHIPS_ACC_I RELATIONSHIP_ID: ' || to_char(p_relationship_id);
       CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_I',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END II_RELATIONSHIPS_ACC_I;

PROCEDURE ITEM_INSTANCES_ACC_PROCESSOR(p_instance_id IN NUMBER,
                                       p_user_id IN NUMBER,
                                       p_flowtype IN VARCHAR2,
                                       p_error_msg     OUT NOCOPY    VARCHAR2,
                                       x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_inv_item_id     NUMBER;
l_lst_vld_org_id  NUMBER;
l_label           VARCHAR(30);
l_parent_ins      NUMBER;

CURSOR c_ins_label(c_instance_id NUMBER)
IS
SELECT   civ.version_label
FROM     csi_i_version_labels civ
WHERE    (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(civ.active_start_date,SYSDATE))
AND      TRUNC(NVL(civ.active_end_date,SYSDATE)))
AND      civ.instance_id =  c_instance_id;

CURSOR c_parent_instance(c_instance_id NUMBER)
IS
SELECT CIR.OBJECT_ID
FROM   CSI_II_RELATIONSHIPS CIR
WHERE  CIR.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
AND    CIR.SUBJECT_ID = c_instance_id;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_PROCESSOR ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);

 IF p_instance_id IS NOT NULL AND p_user_id IS NOT NULL THEN
   CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => p_instance_id
      ,P_USER_ID                => p_user_id
     );

   --Bug 6594511 : Insert the corresponding item into acc table
      SELECT  cii.inventory_item_id,NVL(cii.LAST_VLD_ORGANIZATION_ID,cii.inv_master_organization_id)
      INTO    l_inv_item_id,l_lst_vld_org_id
      FROM    csi_item_instances cii
      WHERE   cii.instance_id = p_instance_id;

       csm_mtl_system_items_event_pkg.MTL_SYSTEM_ITEMS_ACC_I(l_inv_item_id,
                                                             l_lst_vld_org_id,
                                                             p_user_id,
                                                             p_error_msg,
                                                             x_return_status);

    --12.1
    OPEN  c_ins_label(p_instance_id);
    FETCH c_ins_label INTO l_label;
    CLOSE c_ins_label;

    OPEN  c_parent_instance(p_instance_id );
    FETCH c_parent_instance INTO l_parent_ins;
    CLOSE c_parent_instance;

      UPDATE csm_item_instances_acc
      SET    PARENT_INSTANCE_ID = l_parent_ins,
             VERSION_LABEL      = l_label
      WHERE  USER_ID     = p_user_id
      AND    INSTANCE_ID = p_instance_id;

   -- increment count of item instances downloaded
   -- this is used to determine how many IB instances are downloaded at a location
   IF p_flowtype IS NULL OR p_flowtype <> 'HISTORY' THEN
      csm_sr_event_pkg.g_ib_count := NVL(csm_sr_event_pkg.g_ib_count,0) + 1;
   END IF;
 END IF;

 p_error_msg := 'SUCCESS';
 CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_PROCESSOR ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN others THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       p_error_msg := ' FAILED ITEM_INSTANCES_ACC_PROCESSOR INSTANCE_ID: ' || to_char(p_instance_id);
       CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_PROCESSOR',FND_LOG.LEVEL_EXCEPTION);
       RAISE;
END ITEM_INSTANCES_ACC_PROCESSOR;

PROCEDURE II_RELATIONSHIPS_ACC_D(p_relationship_id IN NUMBER,
                                 p_user_id IN NUMBER,
                                 p_error_msg     OUT NOCOPY    VARCHAR2,
                                 x_return_status IN OUT NOCOPY VARCHAR2)
IS
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_D ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_D',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name2
           ,P_ACC_TABLE_NAME         => g_acc_table_name2
           ,P_PK1_NAME               => g_pk1_name2
           ,P_PK1_NUM_VALUE          => p_relationship_id
           ,P_USER_ID                => p_user_id
          );

  p_error_msg := 'SUCCESS';
  CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_D',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_D', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN others THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  	    p_error_msg := ' FAILED II_RELATIONSHIPS_ACC_D RELATIONSHIP_ID: ' || to_char(p_relationship_id);
        CSM_UTIL_PKG.LOG(p_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.II_RELATIONSHIPS_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END II_RELATIONSHIPS_ACC_D;

PROCEDURE ITEM_INSTANCES_ACC_D(p_instance_id IN NUMBER,
                               p_user_id IN NUMBER,
                               p_error_msg     OUT NOCOPY    VARCHAR2,
                               x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_ref_exists NUMBER := 0 ;

/** Check if any other SR refers given instance and user*/
CURSOR l_check_instance_ref(l_instance_id csm_item_instances_acc.instance_id%TYPE,
                             l_user_id csm_item_instances_acc.user_id%TYPE)
IS
SELECT 1
  FROM csm_item_instances_acc a,
       cs_incidents_all_b b,
       csm_incidents_all_acc c
 WHERE a.instance_id = l_instance_id
   AND a.user_id = l_user_id
   AND a.counter = 1
   AND a.instance_id = b.customer_product_id
   AND b.incident_id =c.incident_id
   AND c.user_id = l_user_id;

l_inv_item_id     NUMBER;
l_lst_vld_org_id  NUMBER;

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_D ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_D',FND_LOG.LEVEL_PROCEDURE);

  OPEN l_check_instance_ref(p_instance_id, p_user_id) ;
  FETCH l_check_instance_REF INTO l_REF_EXISTS ;
  IF l_check_instance_REF%NOTFOUND THEN
     l_ref_exists := 0 ;
  END IF ;
  CLOSE l_check_instance_ref ;

  IF L_REF_EXISTS <> 1  THEN
    -- delete from csm_item_instances_acc
    CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
           ,P_ACC_TABLE_NAME         => g_acc_table_name1
           ,P_PK1_NAME               => g_pk1_name1
           ,P_PK1_NUM_VALUE          => p_instance_id
           ,P_USER_ID                => p_user_id
          );
    --Bug 6594511 :Delete the corresponding item from the acc table
      SELECT  cii.inventory_item_id,NVL(cii.LAST_VLD_ORGANIZATION_ID,cii.inv_master_organization_id)
      INTO    l_inv_item_id,l_lst_vld_org_id
      FROM    csi_item_instances cii
      WHERE   cii.instance_id = p_instance_id;

     csm_mtl_system_items_event_pkg.MTL_SYSTEM_ITEMS_ACC_D(l_inv_item_id,
                                                          l_lst_vld_org_id,
                                                          p_user_id,
                                                          p_error_msg,
                                                          x_return_status);

  END IF ;

 CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_D ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_D',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  	WHEN others THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     p_error_msg := ' FAILED ITEM_INSTANCES_ACC_D INSTANCE_ID: ' || to_char(p_instance_id);
     CSM_UTIL_PKG.LOG(p_error_msg,'CSM_ITEM_INSTANCE_EVENT_PKG.ITEM_INSTANCES_ACC_D',FND_LOG.LEVEL_EXCEPTION);
     RAISE;
END ITEM_INSTANCES_ACC_D;

PROCEDURE REFRESH_INSTANCES_ACC (p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_last_run_date DATE;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);
l_current_run_date DATE;
g_pub_item1 VARCHAR2(30);
g_pub_item2 VARCHAR2(30);

CURSOR l_last_run_date_csr
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_ITEM_INSTANCE_EVENT_PKG'
AND procedure_name = 'REFRESH_INSTANCES_ACC';

-- get expired instances
--Bug 5184532
CURSOR l_expiredinstances_del_csr
IS
SELECT acc.access_id,
       acc.user_ID
       --acc.INSTANCE_ID
FROM csm_item_instances_acc acc
,    csi_item_instances cii
,    csi_instance_statuses iis
,    asg_user asg
WHERE cii.instance_id = acc.instance_id
AND  cii.location_type_code = 'INVENTORY'
AND  cii.instance_status_id = iis.instance_status_id
AND  asg.user_id = asg.owner_id
AND  asg.user_id = acc.user_id
AND  ( NOT (SYSDATE BETWEEN NVL(cii.active_start_date,SYSDATE)
                             AND NVL(cii.active_end_date,SYSDATE))
        OR   (NVL(iis.terminated_flag,'N') = 'Y')
      );

-- get instances that are not in users subinventory
CURSOR l_instances_del_csr
IS
SELECT acc.access_id,
       acc.user_ID,
       acc.INSTANCE_ID
FROM csm_item_instances_acc acc
,    csi_item_instances cii
,    asg_user asg
WHERE cii.instance_id = acc.instance_id
AND  cii.location_type_code = 'INVENTORY'
AND  asg.user_id = asg.owner_id
AND  asg.user_id = acc.user_id
AND NOT EXISTS
(SELECT 1
 FROM csm_mtl_onhand_qty_acc ohqacc
 WHERE ohqacc.user_id = acc.user_id
 AND  ohqacc.inventory_item_id =  cii.inventory_item_id
 AND  ohqacc.organization_id = cii.inv_organization_id
 AND  ohqacc.subinventory_code =  cii.inv_subinventory_name
 AND ((ohqacc.LOCATOR_ID IS NULL AND cii.INV_LOCATOR_ID IS NULL)
          OR (ohqacc.LOCATOR_ID = cii.INV_LOCATOR_ID))
 AND ((ohqacc.LOT_NUMBER IS NULL AND cii.LOT_NUMBER IS NULL)
          OR (ohqacc.LOT_NUMBER = cii.LOT_NUMBER))
 AND ((ohqacc.REVISION IS NULL AND cii.INVENTORY_REVISION IS NULL)
          OR (ohqacc.REVISION = cii.INVENTORY_REVISION))
 )
  ;
--bug 5184539
CURSOR l_iteminstances_upd_csr(p_last_run_date DATE)
IS
SELECT /* index (acc CSM_ITEM_INSTANCES_ACC_U1) */
	   acc.user_id,
       --acc.instance_id,
       acc.access_id
FROM   csm_item_instances_acc acc,
       csi_item_instances cii,
       asg_user asg
WHERE  cii.instance_id = acc.instance_id
AND    asg.user_id = asg.owner_id
AND    asg.user_id = acc.user_id
AND    asg.ENABLED = 'Y'
AND    cii.last_update_date >= p_last_run_date;

-- get all the trackable items that exists in the csm_mtl_onhand_acc table
CURSOR l_ins_item_instances_csr
IS
SELECT CSM_ITEM_INSTANCES_ACC_S.NEXTVAL as access_id,
       cqa.user_id,
       cii.instance_id,
       cqa.user_id,
       cii.instance_id,
       civ.version_label,
       CIR.OBJECT_ID
FROM   csm_mtl_onhand_qty_acc cqa
,      csi_item_instances cii
,      csi_instance_statuses iis
,      asg_user asg
,      csi_i_version_labels civ
,      CSI_II_RELATIONSHIPS CIR
WHERE  cii.inventory_item_id     = cqa.inventory_item_id
AND    cii.inv_organization_id   = cqa.organization_id
AND    cii.inv_subinventory_name = cqa.subinventory_code
AND    ((cqa.LOCATOR_ID IS NULL AND cii.INV_LOCATOR_ID IS NULL)
         OR (cqa.LOCATOR_ID = cii.INV_LOCATOR_ID))
AND    ((cqa.LOT_NUMBER IS NULL AND cii.LOT_NUMBER IS NULL)
         OR (cqa.LOT_NUMBER = cii.LOT_NUMBER))
AND    ((cqa.REVISION IS NULL AND cii.INVENTORY_REVISION IS NULL)
         OR (cqa.REVISION = cii.INVENTORY_REVISION))
AND    cii.location_type_code    = 'INVENTORY'
AND    SYSDATE BETWEEN NVL(cii.active_start_date, SYSDATE) AND NVL(cii.active_end_date, SYSDATE)
AND    cii.INSTANCE_STATUS_ID    = iis.instance_status_id
AND    NVL(iis.terminated_flag,'N') = 'N'
AND    asg.user_id = asg.owner_id
AND    asg.user_id = cqa.user_id
AND    asg.ENABLED = 'Y'
AND    cii.instance_id = civ.instance_id(+)
AND    (TRUNC(SYSDATE) BETWEEN TRUNC(NVL(civ.active_start_date,SYSDATE))
AND    TRUNC(NVL(civ.active_end_date,SYSDATE)))
AND    CII.INSTANCE_ID = CIR.SUBJECT_ID(+)
AND    CIR.RELATIONSHIP_TYPE_CODE(+) = 'COMPONENT-OF'
AND    NOT EXISTS
  ( SELECT 1
    FROM   csm_item_instances_acc cia
    WHERE  cia.user_id = cqa.user_id
    AND    cia.instance_id = cii.instance_id
  );

-- delete relationships for instances that no longer belong to the user
CURSOR l_itemrelationships_del1_csr
IS
SELECT /*+ index(cii CSI_II_RELATIONSHIPS_U01) */acc.access_id,
       acc.user_id
       --, acc.relationship_id
FROM csm_ii_relationships_acc acc,
     csi_ii_relationships cii
WHERE cii.relationship_id = acc.relationship_id
AND NOT EXISTS
(SELECT 1
 FROM csm_item_instances_acc ins_acc
 WHERE ins_acc.user_id = acc.user_id
 AND (ins_acc.instance_id = cii.object_id OR ins_acc.instance_id = cii.subject_id)
 );

-- delete relationships that are dropped or end-dated from the backend
CURSOR l_itemrelationships_del2_csr
IS
SELECT /*+ index(acc csm_ii_relationships_acc_u1) */acc.access_id,
       acc.user_id
      --,acc.relationship_id
FROM csm_ii_relationships_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM csi_ii_relationships cii
 WHERE cii.relationship_id = acc.relationship_id
 AND SYSDATE BETWEEN NVL(cii.active_start_date, SYSDATE) AND NVL(cii.active_end_date, SYSDATE)
 );

-- update existing relationships
CURSOR l_itemrelationships_upd_csr(p_last_run_date DATE)
IS
SELECT /* index (acc CSM_II_RELATIONSHIPS_ACC_U1) */
       acc.user_id,
       acc.access_id,
       ii.subject_id,
       ii.object_id
FROM   csm_ii_relationships_acc acc,
       csi_ii_relationships ii
WHERE  ii.relationship_id = acc.relationship_id
AND    ii.last_update_date >= p_last_run_date;

-- get new relationships for instances that the user has access to
--Bug 5184522
CURSOR l_itemrelationships_ins_csr(b_instance_id  NUMBER,b_user_id NUMBER)
IS
SELECT DISTINCT cii.relationship_id
FROM   csi_ii_relationships cii
WHERE  cii.relationship_type_code = 'COMPONENT-OF'
AND   (cii.object_id = b_instance_id OR cii.subject_id = b_instance_id)
AND    SYSDATE BETWEEN NVL(cii.active_start_date, SYSDATE) AND NVL(cii.active_end_date, SYSDATE)
AND    NOT EXISTS (SELECT 1 FROM CSM_II_RELATIONSHIPS_ACC ACC
                   WHERE ACC.user_id = b_useR_id
				   AND   ACC.relationship_id = cii.relationship_id);


TYPE instance_idTab   IS TABLE OF csm_item_instances_acc.instance_id%TYPE INDEX BY BINARY_INTEGER;
TYPE rel_idTab   IS TABLE OF csm_ii_relationships_acc.relationship_id%TYPE INDEX BY BINARY_INTEGER;
TYPE ver_lab_Tab IS TABLE OF csi_i_version_labels.version_label%TYPE INDEX BY BINARY_INTEGER;
l_rel_id_lst     rel_idTab;
l_user_id_lst    asg_download.user_list;
l_acc_id_lst     asg_download.access_list;
l_instance_id_lst  instance_idTab;
l_inst_id_lst_bkp  instance_idTab;
l_user_id_lst_bkp  asg_download.user_list;
l_dummy  BOOLEAN;
l_ver_label_lst  ver_lab_Tab;
l_parent_inst_id_lst  instance_idTab;
BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.REFRESH_INSTANCES_ACC',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.REFRESH_INSTANCES_ACC',FND_LOG.LEVEL_PROCEDURE);

  l_current_run_date := SYSDATE;
  g_pub_item1 := 'CSF_M_ITEM_INSTANCES';
  g_pub_item2 := 'CSF_M_II_RELATIONSHIPS';

  -- get last conc program update date
  OPEN l_last_run_date_csr;
  FETCH l_last_run_date_csr INTO l_last_run_date;
  CLOSE l_last_run_date_csr;

  -- delete item instances that are expired
  IF l_acc_id_lst.COUNT > 0 THEN
    l_acc_id_lst.DELETE;
  END IF;
  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;

  OPEN l_expiredinstances_del_csr;
  LOOP
  FETCH l_expiredinstances_del_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst LIMIT 500;
  EXIT WHEN l_acc_id_lst.COUNT = 0;
    -- post deletes to olite
    -- do bulk makedirty
      l_dummy := asg_download.mark_dirty(
              P_PUB_ITEM         => g_pub_item1
            , p_accessList       => l_acc_id_lst
            , p_userid_list      => l_user_id_lst
            , p_dml_type         => 'D'
            , P_TIMESTAMP        => l_current_run_date
            );

       -- do a bulk delete
       FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
          DELETE FROM CSM_ITEM_INSTANCES_ACC WHERE ACCESS_ID = l_acc_id_lst(i);

    COMMIT;--IB Deletes are commited

    IF l_acc_id_lst.COUNT > 0 THEN
      l_acc_id_lst.DELETE;
    END IF;
    IF l_user_id_lst.COUNT > 0 THEN
      l_user_id_lst.DELETE;
    END IF;
  END LOOP;
  CLOSE l_expiredinstances_del_csr;

  -- delete item instances that are not in the user's subinventory
 /* IF l_acc_id_lst.COUNT > 0 THEN
    l_acc_id_lst.DELETE;
  END IF;
  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;
  IF l_instance_id_lst.COUNT > 0 THEN
    l_instance_id_lst.DELETE;
  END IF;

  OPEN l_instances_del_csr;
  FETCH l_instances_del_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst, l_instance_id_lst;
  CLOSE l_instances_del_csr;

  -- post deletes to olite
  IF l_acc_id_lst.COUNT > 0 THEN
    -- do bulk makedirty
    l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item1
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'D'
          , P_TIMESTAMP        => l_current_run_date
          );

     -- do a bulk delete
     FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
        DELETE CSM_ITEM_INSTANCES_ACC WHERE ACCESS_ID = l_acc_id_lst(i);
  END IF;
*/

  -- get the updates to item instances


  OPEN l_iteminstances_upd_csr(l_last_run_date);
  LOOP
  FETCH l_iteminstances_upd_csr BULK COLLECT INTO l_user_id_lst,  l_acc_id_lst LIMIT 1000;
  EXIT WHEN l_acc_id_lst.COUNT = 0 ;
  -- post updates to olite
        -- do bulk makedirty
    l_dummy := asg_download.mark_dirty(
              P_PUB_ITEM         => g_pub_item1
            , p_accessList       => l_acc_id_lst
            , p_userid_list      => l_user_id_lst
            , p_dml_type         => 'U'
            , P_TIMESTAMP        => l_current_run_date
            );
    COMMIT;--IB Updates are commited
    IF l_acc_id_lst.COUNT > 0 THEN
      l_acc_id_lst.DELETE;
    END IF;
    IF l_user_id_lst.COUNT > 0 THEN
      l_user_id_lst.DELETE;
    END IF;

  END LOOP;
  CLOSE l_iteminstances_upd_csr;

  -- process inserts
  IF l_acc_id_lst.COUNT > 0 THEN
    l_acc_id_lst.DELETE;
  END IF;
  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;
  IF l_instance_id_lst.COUNT > 0 THEN
    l_instance_id_lst.DELETE;
  END IF;
--Bug 5184522
  IF l_inst_id_lst_bkp.COUNT > 0 THEN
    l_inst_id_lst_bkp.DELETE;
  END IF;
  IF l_user_id_lst_bkp.COUNT > 0 THEN
    l_user_id_lst_bkp.DELETE;
  END IF;

  IF l_ver_label_lst.COUNT > 0 THEN
    l_ver_label_lst.DELETE;
  END IF;

  IF l_parent_inst_id_lst.COUNT > 0 THEN
    l_parent_inst_id_lst.DELETE;
  END IF;
  --Inserting  instances for the user
  OPEN l_ins_item_instances_csr;
  FETCH l_ins_item_instances_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst, l_instance_id_lst, l_user_id_lst_bkp, l_inst_id_lst_bkp, l_ver_label_lst, l_parent_inst_id_lst;
  CLOSE l_ins_item_instances_csr;

  IF l_acc_id_lst.COUNT > 0 THEN
     FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
          INSERT INTO CSM_ITEM_INSTANCES_ACC (ACCESS_ID, USER_ID, INSTANCE_ID,
          COUNTER,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN,VERSION_LABEL, PARENT_INSTANCE_ID)
          VALUES (l_acc_id_lst(i), l_user_id_lst(i), l_instance_id_lst(i),
          1, 1, l_current_run_date,1,l_current_run_date,
          1,l_ver_label_lst(i), l_parent_inst_id_lst(i));

    -- do bulk makedirty
     l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item1
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'I'
          , P_TIMESTAMP        => l_current_run_date
          );
--Bug 5184522
   /* FOR I IN 1..l_instance_id_lst.COUNT
    LOOP
     l_inst_id_lst_bkp(I) :=l_instance_id_lst(I);
     l_user_id_lst_bkp(I) :=l_user_id_lst(I);
    END LOOP;*/
  END IF;
  COMMIT;--IB Inserts are commited

  -- post deletes to relationships for instances that no longer belong to the user
  IF l_acc_id_lst.COUNT > 0 THEN
    l_acc_id_lst.DELETE;
  END IF;
  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;
  IF l_rel_id_lst.COUNT > 0 THEN
    l_rel_id_lst.DELETE;
  END IF;

  IF l_ver_label_lst.COUNT > 0 THEN
    l_ver_label_lst.DELETE;
  END IF;

  IF l_parent_inst_id_lst.COUNT > 0 THEN
    l_parent_inst_id_lst.DELETE;
  END IF;

  OPEN l_itemrelationships_del1_csr;
  FETCH l_itemrelationships_del1_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst;
  CLOSE l_itemrelationships_del1_csr;

  -- post deletes to olite
  IF l_acc_id_lst.COUNT > 0 THEN
      -- do bulk makedirty
      l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item2
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'D'
          , P_TIMESTAMP        => l_current_run_date
          );

     -- do a bulk delete
     FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
        DELETE CSM_II_RELATIONSHIPS_ACC WHERE ACCESS_ID = l_acc_id_lst(i);

  END IF;

  COMMIT;--IB Relation Deletes are commited

-- post delete for relationships that are dropped or end-dated from the backend
  IF l_acc_id_lst.COUNT > 0 THEN
    l_acc_id_lst.DELETE;
  END IF;
  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;

  OPEN l_itemrelationships_del2_csr;
  FETCH l_itemrelationships_del2_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst;
  CLOSE l_itemrelationships_del2_csr;

  -- post deletes to olite
  IF l_acc_id_lst.COUNT > 0 THEN
      -- do bulk makedirty
      l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item2
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'D'
          , P_TIMESTAMP        => l_current_run_date
          );

     -- do a bulk delete
     FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
        DELETE CSM_II_RELATIONSHIPS_ACC WHERE ACCESS_ID = l_acc_id_lst(i);

  END IF;
  COMMIT;--IB Relation Deletes are commited

  -- post updated to relationships
  IF l_acc_id_lst.COUNT > 0 THEN
    l_acc_id_lst.DELETE;
  END IF;
  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;
  IF l_instance_id_lst.COUNT > 0 THEN
    l_instance_id_lst.DELETE;
  END IF;
   IF l_parent_inst_id_lst.COUNT > 0 THEN
    l_parent_inst_id_lst.DELETE;
  END IF;
  OPEN l_itemrelationships_upd_csr(l_last_run_date);
  FETCH l_itemrelationships_upd_csr BULK COLLECT INTO l_user_id_lst, l_acc_id_lst, l_instance_id_lst, l_parent_inst_id_lst;
  CLOSE l_itemrelationships_upd_csr;

  -- post updates to olite
  IF l_acc_id_lst.COUNT > 0 THEN
      -- do bulk makedirty for relationship change
      l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item2
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'U'
          , P_TIMESTAMP        => l_current_run_date
          );

      IF l_acc_id_lst.COUNT > 0 THEN
          l_acc_id_lst.DELETE;
      END IF;

    --If the relationship are updated then the instance should be updated with the correct parent
      FORALL i in l_parent_inst_id_lst.FIRST..l_parent_inst_id_lst.LAST
        UPDATE csm_item_instances_acc
        SET    PARENT_INSTANCE_ID = l_parent_inst_id_lst(i)
        WHERE  USER_ID     = l_user_id_lst(i)
        AND    INSTANCE_ID = l_instance_id_lst(i)
        RETURNING access_id  BULK COLLECT INTO l_acc_id_lst ;

          -- do bulk makedirty for  Instances
      l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => g_pub_item1
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'U'
          , P_TIMESTAMP        => l_current_run_date
          );
  END IF;

  COMMIT;--IB Relation Updates are commited

  IF l_instance_id_lst.COUNT > 0 THEN
    l_instance_id_lst.DELETE;
  END IF;
   IF l_parent_inst_id_lst.COUNT > 0 THEN
    l_parent_inst_id_lst.DELETE;
  END IF;

-- post inserts to olite
--Bug 5184522
  FOR I in 1..l_inst_id_lst_bkp.COUNT
  LOOP
    l_acc_id_lst.delete;
    l_rel_id_lst.DELETE;
    l_user_id_lst.DELETE;

    OPEN l_itemrelationships_ins_csr(l_inst_id_lst_bkp(I),l_user_id_lst_bkp(I));
    FETCH l_itemrelationships_ins_csr BULK COLLECT INTO l_rel_id_lst;
    CLOSE l_itemrelationships_ins_csr;

    IF l_rel_id_lst.COUNT >0 THEN

     FOR J IN 1..l_rel_id_lst.COUNT
      LOOP
       SELECT CSM_II_RELATIONSHIPS_ACC_S.NEXTVAL
       INTO l_acc_id_lst(J)
       FROM dual;
       l_user_id_lst(J):=l_user_id_lst_bkp(I);
      END LOOP;

     FORALL j IN 1..l_rel_id_lst.COUNT
      INSERT INTO CSM_II_RELATIONSHIPS_ACC (ACCESS_ID, USER_ID, RELATIONSHIP_ID,
                COUNTER,CREATED_BY, CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE, LAST_UPDATE_LOGIN)
      VALUES (l_acc_id_lst(j), l_user_id_lst_bkp(I), l_rel_id_lst(j), 1, 1, l_current_run_date,1,l_current_run_date,1);

         -- do bulk makedirty
      l_dummy := asg_download.mark_dirty(
             P_PUB_ITEM         => g_pub_item2
           , p_accessList       => l_acc_id_lst
           , p_userid_list      => l_user_id_lst
           , p_dml_type         => 'I'
           , P_TIMESTAMP        => l_current_run_date
           );
    END IF;
  END LOOP;


  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_current_run_date
  WHERE product_code = 'CSM'
    AND package_name = 'CSM_ITEM_INSTANCE_EVENT_PKG'
    AND procedure_name = 'REFRESH_INSTANCES_ACC';

  COMMIT;

  CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.REFRESH_INSTANCES_ACC',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.REFRESH_INSTANCES_ACC',FND_LOG.LEVEL_PROCEDURE);

  p_status := 'FINE';
  p_message :=  'CSM_ITEM_INSTANCE_EVENT_PKG.REFRESH_INSTANCES_ACC Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message := 'Error in CSM_ITEM_INSTANCE_EVENT_PKG.REFRESH_INSTANCES_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     csm_util_pkg.log('CSM_ITEM_INSTANCE_EVENT_PKG.REFRESH_INSTANCES_ACC ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END REFRESH_INSTANCES_ACC;

PROCEDURE GET_IB_AT_LOCATION(p_instance_id IN NUMBER, p_party_site_id IN NUMBER, p_party_id IN NUMBER,
                             p_location_id IN NUMBER, p_user_id IN NUMBER, p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_parent_instance_id csi_item_instances.instance_id%TYPE;
l_max_ib_at_location NUMBER;

CURSOR c_ib_parent_csr(p_instance_id IN number)
IS
SELECT object_id AS instance_id
FROM   CSI_II_RELATIONSHIPS
WHERE  RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
AND    SUBJECT_ID = p_instance_id
AND    SYSDATE BETWEEN nvl(active_start_date, SYSDATE)
   	           	 AND nvl(active_end_date, SYSDATE)
;

CURSOR c_existing_ib_at_location_csr (
           p_user_id IN  NUMBER,
           p_party_site_id NUMBER,
           p_location_id   NUMBER,
           p_party_id      NUMBER,
           p_instance_id   NUMBER,
           p_parent_instance_id NUMBER  )
IS
SELECT acc.instance_id
FROM CSM_ITEM_INSTANCES_ACC acc, CSI_ITEM_INSTANCES cii
WHERE acc.instance_id = cii.instance_id
AND acc.user_id = p_user_id
AND owner_party_id = p_party_id
AND ( ( cii.location_id = p_party_site_id
             AND cii.location_type_code = 'HZ_PARTY_SITES'
      ) OR
                ( cii.location_id = p_location_id
                  AND  cii.location_type_code = 'HZ_LOCATIONS'
                )
    )
     AND acc.instance_id NOT IN
          (
              SELECT acc.instance_id
              FROM CSM_ITEM_INSTANCES_ACC acc
              WHERE acc.user_id = p_user_id
              AND   acc.instance_id IN (p_instance_id, p_parent_instance_id)
              UNION
              SELECT acc.instance_id
              FROM CSM_ITEM_INSTANCES_ACC acc
              WHERE acc.user_id = p_user_id
              AND   acc.instance_id IN
                 (
                     SELECT subject_id
                     FROM CSI_II_RELATIONSHIPS
                     START WITH object_id = p_instance_id
                     AND RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
                     AND SYSDATE BETWEEN NVL(active_start_date, SYSDATE)
                                      AND NVL(active_end_date, SYSDATE)
                     CONNECT BY object_id = PRIOR subject_id
                 )
         ) ;

CURSOR c_new_ib_at_location_csr (
           p_user_id   NUMBER,
           p_party_site_id NUMBER,
           p_location_id   NUMBER,
           p_party_id      NUMBER  )
IS
SELECT cii.instance_id
FROM CSI_ITEM_INSTANCES cii, MTL_SYSTEM_ITEMS_B si
WHERE si.inventory_item_id = cii.inventory_item_id
AND si.organization_id = NVL( cii.inv_organization_id,
                                          cii.inv_master_organization_id )
AND cii.instance_id NOT IN
             ( SELECT acc.instance_id FROM CSM_ITEM_INSTANCES_ACC acc
               WHERE acc.user_id = p_user_id
             )
AND owner_party_id = p_party_id
AND ( ( cii.location_id = p_party_site_id
        AND cii.location_type_code = 'HZ_PARTY_SITES'
      ) OR
      ( cii.location_id = p_location_id
        AND  cii.location_type_code = 'HZ_LOCATIONS'
      )
    )
-- AND si.service_item_flag = 'N'
AND  nvl(si.enabled_flag,'Y') = 'Y'
AND si.serv_req_enabled_code = 'E'
AND si.contract_item_type_code IS NULL
;

BEGIN
   CSM_UTIL_PKG.LOG('Entering GET_IB_AT_LOCATION for instance_id: ' || p_instance_id ||
                    ' and party_site_id: ' || p_party_site_id,'CSM_ITEM_INSTANCE_EVENT_PKG.GET_IB_AT_LOCATION',FND_LOG.LEVEL_PROCEDURE);

    IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
      l_max_ib_at_location := NVL(csm_profile_pkg.get_max_ib_at_location(p_user_id),0);

      -- get parent instance_id if exists
      OPEN c_ib_parent_csr(p_instance_id);
      FETCH c_ib_parent_csr INTO l_parent_instance_id;
      CLOSE c_ib_parent_csr;

      -- Increment counter for existing IB's
      FOR c_exist_ib_items IN c_existing_ib_at_location_csr (
                              p_user_id,
                              p_party_site_id,
                              p_location_id,
                              p_party_id,
                              p_instance_id,
                              l_parent_instance_id )
      LOOP
          CSM_ACC_PKG.Insert_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
           ,P_ACC_TABLE_NAME         => g_acc_table_name1
           ,P_SEQ_NAME               => g_acc_sequence_name1
           ,P_PK1_NAME               => g_pk1_name1
           ,P_PK1_NUM_VALUE          => c_exist_ib_items.instance_id
           ,P_USER_ID                => p_user_id
          );

         csm_sr_event_pkg.g_ib_count := csm_sr_event_pkg.g_ib_count + 1;
      END LOOP;

      -- Greater than check for Profile IB count was reset to a lower value
      IF csm_sr_event_pkg.g_ib_count >=  l_max_ib_at_location THEN
         RETURN;
      ELSE
        /** Insert For other IB's at location */
        FOR c_ib_items IN c_new_ib_at_location_csr (
               p_user_id, p_party_site_id , p_location_id, p_party_id )
        LOOP

          IF csm_sr_event_pkg.g_ib_count < l_max_ib_at_location
          THEN
            CSM_ACC_PKG.Insert_Acc
            ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
             ,P_ACC_TABLE_NAME         => g_acc_table_name1
             ,P_SEQ_NAME               => g_acc_sequence_name1
             ,P_PK1_NAME               => g_pk1_name1
             ,P_PK1_NUM_VALUE          => c_ib_items.instance_id
             ,P_USER_ID                => p_user_id
            );

           csm_sr_event_pkg.g_ib_count := csm_sr_event_pkg.g_ib_count + 1;
         ELSE
           EXIT;
         END IF;

       END LOOP;
     END IF;

   END IF;

   CSM_UTIL_PKG.LOG('Leaving GET_IB_AT_LOCATION for instance_id: ' || p_instance_id ||
                    ' and party_site_id: ' || p_party_site_id,'CSM_ITEM_INSTANCE_EVENT_PKG.GET_IB_AT_LOCATION',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  GET_IB_AT_LOCATION for instance_id: ' || p_instance_id || ' and party_site_id:'
                       || to_char(p_party_site_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.GET_IB_AT_LOCATION',FND_LOG.LEVEL_EXCEPTION);
END GET_IB_AT_LOCATION;

PROCEDURE SPAWN_COUNTERS_INS (p_instance_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_counter_id_csr ( p_instance_id NUMBER, p_user_id NUMBER)
IS
SELECT cntrs.counter_id
FROM   CS_CSI_COUNTER_GROUPS 	  cntr_grps,
       CSI_COUNTERS_B       	  cntrs,
	   CSI_COUNTER_ASSOCIATIONS   cas
WHERE  cntrs.counter_id 		  = cas.counter_id
AND	   cas.source_object_code 	  = 'CP'
AND    cntrs.counter_type 	  	  = 'REGULAR'
AND    cntr_grps.counter_group_id(+) = cntrs.group_id
AND    cas.source_object_id 	  = p_instance_id
   -- get only records for the instance belonging to the user
AND EXISTS (SELECT 1
            FROM  csm_item_instances_acc acc
			WHERE acc.user_id = p_user_id
            AND   acc.instance_id = cas.source_object_id) ;

BEGIN
   CSM_UTIL_PKG.LOG('Entering SPAWN_COUNTERS_INS for instance_id: ' || p_instance_id,
                     'CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_INS',FND_LOG.LEVEL_PROCEDURE);

   	FOR r_counter_id_rec in l_counter_id_csr(p_instance_id, p_user_id) LOOP
   	  --- get the counter
      csm_counter_event_pkg.COUNTER_MDIRTY_I(r_counter_id_rec.counter_id, p_user_id, l_error_msg, l_return_status);

      -- get the counter readings
      csm_counter_event_pkg.COUNTER_VALS_MAKE_DIRTY_I_GRP(r_counter_id_rec.counter_id, p_instance_id, p_user_id, l_error_msg, l_return_status);

   	END LOOP;

   CSM_UTIL_PKG.LOG('Leaving SPAWN_COUNTERS_INS for instance_id: ' || p_instance_id,
                     'CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_INS',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := l_error_msg || '- Exception in  SPAWN_COUNTERS_INS for instance_id: ' || p_instance_id
                          || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_INS',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_COUNTERS_INS;

PROCEDURE DELETE_IB_AT_LOCATION(p_incident_id IN NUMBER, p_instance_id IN NUMBER, p_party_site_id IN NUMBER, p_party_id IN NUMBER,
                             p_location_id IN NUMBER, p_user_id IN NUMBER, p_flow_type IN VARCHAR2)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_parent_instance_id csi_item_instances.instance_id%TYPE;

-- the below query prevents deletion of the configuration of the current IB item
-- however it needs further validation to correctly delete IB at location.
CURSOR c_ib_at_location_csr (
         p_user_id   NUMBER,
         p_party_site_id NUMBER,
         p_location_id   NUMBER,
         p_party_id      NUMBER,
         p_incident_id NUMBER ) IS
SELECT acc.instance_id
FROM CSM_ITEM_INSTANCES_ACC acc, CSI_ITEM_INSTANCES cii,
     csm_incidents_all_acc iacc, cs_incidents_all_b cia
WHERE acc.instance_id = cii.instance_id
AND acc.user_id = p_user_id
AND acc.counter <> 1 -- do not delete if there is just 1 instance of the IB item
AND acc.instance_id <> p_instance_id
AND owner_party_id = p_party_id
AND ( ( cii.location_id = p_party_site_id
        AND cii.location_type_code = 'HZ_PARTY_SITES' )
             OR ( cii.location_id = p_location_id
        AND  cii.location_type_code = 'HZ_LOCATIONS') )
AND iacc.user_id = acc.user_id
AND iacc.incident_id <> p_incident_id
AND iacc.incident_id = cia.incident_id
AND cia.customer_product_id <> acc.instance_id
AND NOT EXISTS
(SELECT 1
FROM (SELECT * FROM CSI_II_RELATIONSHIPS CIRo
          START WITH CIRo.OBJECT_ID = p_instance_id
          AND CIRo.RELATIONSHIP_TYPE_CODE = 'COMPONENT-OF'
          AND SYSDATE BETWEEN NVL(CIRo.active_start_date, SYSDATE)
                                      AND NVL(CIRo.active_end_date, SYSDATE)
          CONNECT BY CIRo.OBJECT_ID = PRIOR CIRo.SUBJECT_ID
     ) CIR,
     CSI_ITEM_INSTANCES CII
WHERE  CII.INSTANCE_ID = CIR.SUBJECT_ID
AND cii.instance_id = acc.instance_id
AND SYSDATE BETWEEN NVL ( CII.ACTIVE_START_DATE , SYSDATE )
                           AND NVL ( CII.ACTIVE_END_DATE , SYSDATE)
);

BEGIN
   CSM_UTIL_PKG.LOG('Entering DELETE_IB_AT_LOCATION for instance_id: ' || p_instance_id ||
                    ' and party_site_id: ' || p_party_site_id,'CSM_ITEM_INSTANCE_EVENT_PKG.GET_IB_AT_LOCATION',FND_LOG.LEVEL_PROCEDURE);

   IF p_flow_type IS NULL OR p_flow_type <> 'HISTORY' THEN
     FOR c_ib_items IN c_ib_at_location_csr (
            p_user_id, p_party_site_id, p_location_id, p_party_id, p_incident_id )
     LOOP
       CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
           ,P_ACC_TABLE_NAME         => g_acc_table_name1
           ,P_PK1_NAME               => g_pk1_name1
           ,P_PK1_NUM_VALUE          => c_ib_items.instance_id
           ,P_USER_ID                => p_user_id
          );
     END LOOP;
   END IF;

   CSM_UTIL_PKG.LOG('Leaving DELETE_IB_AT_LOCATION for instance_id: ' || p_instance_id ||
                    ' and party_site_id: ' || p_party_site_id,'CSM_ITEM_INSTANCE_EVENT_PKG.GET_IB_AT_LOCATION',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DELETE_IB_AT_LOCATION for instance_id: ' || p_instance_id || ' and party_site_id:'
                       || to_char(p_party_site_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.DELETE_IB_AT_LOCATION',FND_LOG.LEVEL_EXCEPTION);
END DELETE_IB_AT_LOCATION;

PROCEDURE SPAWN_COUNTERS_DEL (p_instance_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_counter_id_csr ( p_instance_id number,
						                    p_user_id number )
IS
SELECT cntrs.counter_id
FROM   CS_CSI_COUNTER_GROUPS 	  cntr_grps,
       CSI_COUNTERS_B       	  cntrs,
	   CSI_COUNTER_ASSOCIATIONS   cas
WHERE  cntrs.counter_id 		  = cas.counter_id
AND	   cas.source_object_code 	  = 'CP'
AND    cntrs.counter_type 	  	  = 'REGULAR'
AND    cntr_grps.counter_group_id(+) = cntrs.group_id
AND    cas.source_object_id 	  = p_instance_id
AND EXISTS (SELECT 1
		    FROM CSM_COUNTERS_ACC acc
			WHERE acc.user_id    = p_user_id
			AND	  acc.counter_id = cntrs.counter_id);

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_DEL ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_DEL',FND_LOG.LEVEL_PROCEDURE);

   	-- get all the counters for the instance
   	FOR r_counter_id_rec in l_counter_id_csr(p_instance_id, p_user_id) LOOP
   	  --- drop the counter
      csm_counter_event_pkg.COUNTER_MDIRTY_D(r_counter_id_rec.counter_id, p_user_id, l_error_msg, l_return_status);

      -- drop the counter readings
      csm_counter_event_pkg.COUNTER_VALS_MAKE_DIRTY_D_GRP(r_counter_id_rec.counter_id, p_instance_id, p_user_id, l_error_msg, l_return_status);

   	END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_DEL ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_DEL',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := l_error_msg || '- Exception in  SPAWN_COUNTERS_DEL for instance_id: ' || p_instance_id
                          || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.SPAWN_COUNTERS_DEL',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END SPAWN_COUNTERS_DEL;

PROCEDURE DELETE_IB_NOTIN_INV (p_inv_item_id IN NUMBER, p_org_id IN NUMBER, p_user_id IN NUMBER)
IS
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	VARCHAR2(4000);
l_error_msg 	VARCHAR2(4000);
l_dummy  		BOOLEAN;

TYPE instance_idTab   IS TABLE OF csm_item_instances_acc.instance_id%TYPE INDEX BY BINARY_INTEGER;
l_instance_id_lst  instance_idTab;
l_user_id_lst      asg_download.user_list;
l_acc_id_lst       asg_download.access_list;


CURSOR l_instances_del_csr
IS
SELECT acc.access_id,
       acc.user_ID,
       acc.INSTANCE_ID
FROM   csm_item_instances_acc acc
,      csi_item_instances cii
WHERE  cii.instance_id 	  	   = acc.instance_id
AND    cii.location_type_code  = 'INVENTORY'
AND    cii.inventory_item_id   = p_inv_item_id
AND    cii.inv_organization_id = p_org_id
AND    acc.user_id  		   = p_user_id;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_ITEM_INSTANCE_EVENT_PKG.DELETE_IB_NOTIN_INV ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.DELETE_IB_NOTIN_INV',FND_LOG.LEVEL_PROCEDURE);

  -- delete item instances that are not in the user's subinventory
  IF l_acc_id_lst.COUNT > 0 THEN
    l_acc_id_lst.DELETE;
  END IF;
  IF l_user_id_lst.COUNT > 0 THEN
    l_user_id_lst.DELETE;
  END IF;
  IF l_instance_id_lst.COUNT > 0 THEN
    l_instance_id_lst.DELETE;
  END IF;

  OPEN l_instances_del_csr;
  FETCH l_instances_del_csr BULK COLLECT INTO l_acc_id_lst, l_user_id_lst, l_instance_id_lst;
  CLOSE l_instances_del_csr;

  -- post deletes to olite
  IF l_acc_id_lst.COUNT > 0 THEN
    -- do bulk makedirty
    l_dummy := asg_download.mark_dirty(
            P_PUB_ITEM         => 'CSF_M_ITEM_INSTANCES'
          , p_accessList       => l_acc_id_lst
          , p_userid_list      => l_user_id_lst
          , p_dml_type         => 'D'
          , P_TIMESTAMP        => sysdate
          );

     -- do a bulk delete
     FORALL i IN l_acc_id_lst.FIRST..l_acc_id_lst.LAST
        DELETE CSM_ITEM_INSTANCES_ACC WHERE ACCESS_ID = l_acc_id_lst(i);
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_ITEM_INSTANCE_EVENT_PKG.DELETE_IB_NOTIN_INV ',
                         'CSM_ITEM_INSTANCE_EVENT_PKG.DELETE_IB_NOTIN_INV',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno  := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := l_error_msg || '- Exception in  DELETE_IB_NOTIN_INV ' || ':'
					|| l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_ITEM_INSTANCE_EVENT_PKG.DELETE_IB_NOTIN_INV',FND_LOG.LEVEL_EXCEPTION);
        RAISE;

END DELETE_IB_NOTIN_INV;

END CSM_ITEM_INSTANCE_EVENT_PKG;

/
