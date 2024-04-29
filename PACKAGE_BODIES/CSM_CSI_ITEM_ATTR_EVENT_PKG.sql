--------------------------------------------------------
--  DDL for Package Body CSM_CSI_ITEM_ATTR_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CSI_ITEM_ATTR_EVENT_PKG" AS
/* $Header: csmeiatb.pls 120.1 2005/07/25 00:08:13 trajasek noship $*/
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

g_table_name1            CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_CSI_ITEM_ATTR');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'ATTRIBUTE_VALUE_ID';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR';

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_pub_item VARCHAR2(30) := 'CSM_CSI_ITEM_ATTR';
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
WHERE package_name = 'CSM_CSI_ITEM_ATTR_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

-- process inserts
CURSOR l_csi_iea_values_ins_csr
IS
SELECT attrval.attribute_value_id,
      ii_acc.instance_id,
      ii_acc.user_id
FROM csm_item_instances_acc ii_acc,
     csi_item_instances cii,
     csi_iea_values attrval,
     csi_i_extended_attribs attr
WHERE ii_acc.instance_id = cii.instance_id
AND cii.location_type_code <> 'INVENTORY'
AND attrval.instance_id = cii.instance_id
AND attrval.attribute_id = attr.attribute_id
AND SYSDATE BETWEEN NVL(attrval.active_start_date, SYSDATE) AND NVL(attrval.active_end_date, SYSDATE)
AND SYSDATE BETWEEN NVL(attr.active_start_date, SYSDATE) AND NVL(attr.active_end_date, SYSDATE)
AND NOT EXISTS
(SELECT 1
 FROM CSM_CSI_ITEM_ATTR_ACC acc
 WHERE acc.user_id = ii_acc.user_id
 AND acc.attribute_value_id = attrval.attribute_value_id
 );

--process updates
CURSOR l_csi_iea_values_upd_csr(p_last_upd_date DATE)
IS
SELECT acc.access_id,
       acc.user_id
FROM csm_csi_item_attr_acc acc,
     csi_iea_values attrval,
     csi_i_extended_attribs attr
WHERE acc.attribute_value_id = attrval.attribute_value_id
AND attrval.attribute_id = attr.attribute_id
AND SYSDATE BETWEEN NVL(attrval.active_start_date, SYSDATE) AND NVL(attrval.active_end_date, SYSDATE)
AND SYSDATE BETWEEN NVL(attr.active_start_date, SYSDATE) AND NVL(attr.active_end_date, SYSDATE)
AND attrval.last_update_date > p_last_upd_date;

--process deletes
CURSOR l_csi_iea_values_del_csr
IS
SELECT acc.access_id,
       acc.attribute_value_id,
       acc.user_id
FROM csm_csi_item_attr_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM csm_item_instances_acc ii_acc,
     csi_item_instances cii,
     csi_iea_values attrval,
     csi_i_extended_attribs attr
WHERE ii_acc.instance_id = cii.instance_id
AND cii.location_type_code <> 'INVENTORY'
AND attrval.instance_id = cii.instance_id
AND attrval.attribute_id = attr.attribute_id
AND SYSDATE BETWEEN NVL(attrval.active_start_date, SYSDATE) AND NVL(attrval.active_end_date, SYSDATE)
AND SYSDATE BETWEEN NVL(attr.active_start_date, SYSDATE) AND NVL(attr.active_end_date, SYSDATE)
);

BEGIN
 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

 -- process deletes
 FOR r_csi_iea_values_del_rec IN l_csi_iea_values_del_csr LOOP
   CSM_ACC_PKG.Delete_acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => r_csi_iea_values_del_rec.attribute_value_id
      ,P_USER_ID                => r_csi_iea_values_del_rec.user_id
      );
 END LOOP;

 -- process updates
 FOR r_csi_iea_values_upd_rec IN l_csi_iea_values_upd_csr(l_prog_update_date) LOOP
   CSM_ACC_PKG.Update_acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_ACCESS_ID              => r_csi_iea_values_upd_rec.access_id
      ,P_USER_ID                => r_csi_iea_values_upd_rec.user_id
      );
 END LOOP;

 -- process inserts
 FOR r_csi_iea_values_ins_rec IN l_csi_iea_values_ins_csr LOOP
     CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
      ,P_ACC_TABLE_NAME         => g_acc_table_name1
      ,P_SEQ_NAME               => g_acc_sequence_name1
      ,P_PK1_NAME               => g_pk1_name1
      ,P_PK1_NUM_VALUE          => r_csi_iea_values_ins_rec.attribute_value_id
      ,P_USER_ID                => r_csi_iea_values_ins_rec.user_id
     );
 END LOOP;

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_run_date
  WHERE package_name = 'CSM_CSI_ITEM_ATTR_EVENT_PKG'
    AND procedure_name = 'REFRESH_ACC';

  COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_CSI_ITEM_ATTR_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_CSI_ITEM_ATTR_EVENT_PKG.Refresh_Acc:' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('CSM_CSI_ITEM_ATTR_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg, 'CSM_CSI_ITEM_ATTR_EVENT_PKG.Refresh_acc',FND_LOG.LEVEL_EXCEPTION);
END Refresh_Acc;

END CSM_CSI_ITEM_ATTR_EVENT_PKG;

/
