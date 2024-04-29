--------------------------------------------------------
--  DDL for Package Body CSM_MTL_PARAMETERS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MTL_PARAMETERS_EVENT_PKG" AS
/* $Header: csmemtpb.pls 120.1 2005/07/25 00:14:32 trajasek noship $*/
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

g_table_name1            CONSTANT VARCHAR2(30) := 'MTL_PARAMETERS';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_MTL_PARAMETERS_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_MTL_PARAMETERS_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSM_MTL_PARAMETERS');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'ORGANIZATION_ID';
g_pub_item               CONSTANT VARCHAR2(30) := 'CSM_MTL_PARAMETERS';

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_pub_item VARCHAR2(30) := 'CSM_MTL_PARAMETERS';
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
WHERE package_name = 'CSM_MTL_PARAMETERS_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

-- inserts cur
CURSOR l_mtl_parameters_ins_csr
IS
SELECT mtlp.organization_id
FROM mtl_parameters mtlp
WHERE  NOT EXISTS
(SELECT 1
 FROM csm_mtl_parameters_acc acc
 WHERE acc.organization_id = mtlp.organization_id
 );

 -- updates cur
CURSOR l_mtl_parameters_upd_csr(p_last_upd_date date)
IS
SELECT acc.access_id, mtlp.organization_id
FROM mtl_parameters mtlp,
     csm_mtl_parameters_acc acc
WHERE (mtlp.creation_date < p_last_upd_date AND mtlp.last_update_date > p_last_upd_date)
AND acc.organization_id = mtlp.organization_id;

-- deletes cur
CURSOR l_mtl_parameters_del_csr
IS
SELECT acc.access_id, acc.organization_id
FROM csm_mtl_parameters_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM mtl_parameters mtlp
 WHERE mtlp.organization_id = acc.organization_id
 );

BEGIN
 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr;
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

  -- process all deletes
  FOR r_mtl_parameters_del_rec IN l_mtl_parameters_del_csr LOOP

     --get the users with this language
     l_all_omfs_palm_resource_list := l_null_resource_list;
     l_all_omfs_palm_resource_list := csm_util_pkg.get_all_omfs_palm_res_list;

     l_access_id := r_mtl_parameters_del_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_all_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSM_MTL_PARAMETERS',
          l_single_access_id_list, l_all_omfs_palm_resource_list,
          ASG_DOWNLOAD.DEL, sysdate);
     END IF;

     -- delete from acc table
     DELETE FROM csm_mtl_parameters_acc WHERE access_id = l_access_id;
  END LOOP;

  -- process all updates
  FOR r_mtl_parameters_upd_rec IN l_mtl_parameters_upd_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_all_omfs_palm_resource_list := l_null_resource_list;
     l_all_omfs_palm_resource_list := csm_util_pkg.get_all_omfs_palm_res_list;

     l_access_id := r_mtl_parameters_upd_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_all_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSM_MTL_PARAMETERS',
          l_single_access_id_list, l_all_omfs_palm_resource_list,
          ASG_DOWNLOAD.UPD, sysdate);
     END IF;

  END LOOP;

  -- process all inserts
  FOR r_mtl_parameters_ins_rec IN l_mtl_parameters_ins_csr LOOP

     --get the users with this language
     l_all_omfs_palm_resource_list := l_null_resource_list;
     l_all_omfs_palm_resource_list := csm_util_pkg.get_all_omfs_palm_res_list;

     SELECT csm_mtl_parameters_acc_s.nextval
     INTO l_access_id
     FROM dual;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_all_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
     l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSM_MTL_PARAMETERS',
          l_single_access_id_list, l_all_omfs_palm_resource_list,
          ASG_DOWNLOAD.INS, sysdate);
     END IF;

     INSERT INTO csm_mtl_parameters_acc (access_id,
                                  organization_id,
                                  counter,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login
                                  )
                          VALUES (l_access_id,
                                  r_mtl_parameters_ins_rec.organization_id,
                                  1,
                                  fnd_global.user_id,
                                  l_run_date,
                                  fnd_global.user_id,
                                  l_run_date,
                                  fnd_global.login_id
                                  );

  END LOOP;

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET last_run_date = l_run_date
  WHERE package_name = 'CSM_MTL_PARAMETERS_EVENT_PKG'
    AND procedure_name = 'REFRESH_ACC';

 COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_MTL_PARAMETERS_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_MTL_PARAMETERS_EVENT_PKG.Refresh_Acc: ' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     fnd_file.put_line(fnd_file.log, 'CSM_MTL_PARAMETERS_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);
END Refresh_Acc;

END CSM_MTL_PARAMETERS_EVENT_PKG;

/
