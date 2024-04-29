--------------------------------------------------------
--  DDL for Package Body CSM_MESSAGES_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_MESSAGES_EVENT_PKG" AS
/* $Header: csmemsgb.pls 120.1 2005/07/25 00:12:41 trajasek noship $ */

-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
   -- Enter procedure, function bodies as shown below

PROCEDURE Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_pub_item varchar2(30) := 'CSF_M_MESSAGES';
l_prog_update_date jtm_con_request_data.last_run_date%TYPE;
l_access_id jtm_fnd_lookups_acc.access_id%TYPE;
l_mark_dirty boolean;
l_tl_omfs_palm_resource_list asg_download.user_list;
l_null_resource_list asg_download.user_list;
l_single_access_id_list asg_download.access_list;
--a null list
l_null_access_list asg_download.access_list;
l_run_date date;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);

CURSOR l_last_run_date_csr(p_pub_item IN varchar2)
IS
SELECT nvl(last_run_date, (sysdate - 365*50))
FROM jtm_con_request_data
WHERE package_name = 'CSM_MESSAGES_EVENT_PKG'
AND procedure_name = 'REFRESH_ACC';

-- inserts cur
CURSOR l_messages_ins_csr(p_last_upd_date date)
IS
SELECT msg.application_id, msg.message_name, msg.language_code
FROM fnd_new_messages msg
WHERE
((msg.application_id = 513 -- CSF application
  AND 	msg.message_name like 'CSF_M_%')
  OR msg.application_id = 883) -- CSM application
AND NOT EXISTS
(SELECT 1
 FROM csm_messages_acc acc
 WHERE acc.application_id = msg.application_id
 AND acc.message_name = msg.message_name
 AND acc.language_code = msg.language_code
 );

 -- updates cur
CURSOR l_messages_upd_csr(p_last_upd_date date)
IS
SELECT acc.access_id, msg.application_id, msg.message_name, msg.language_code
FROM fnd_new_messages msg,
     csm_messages_acc acc
WHERE (msg.creation_date < p_last_upd_date AND msg.last_update_date > p_last_upd_date)

AND ((msg.application_id = 513 -- CSF application
  AND 	msg.message_name like 'CSF_M_%')
  OR msg.application_id = 883) -- CSM application
AND acc.application_id = msg.application_id
AND acc.message_name = msg.message_name
AND acc.language_code = msg.language_code;

-- deletes cur
CURSOR l_messages_del_csr
IS
SELECT acc.access_id, acc.language_code
FROM csm_messages_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM fnd_new_messages msg
 WHERE ((msg.application_id = 513 -- CSF application
  AND 	msg.message_name like 'CSF_M_%')
  OR msg.application_id = 883) -- CSM application
 AND acc.application_id = msg.application_id
 AND acc.message_name = msg.message_name
 AND acc.language_code = msg.language_code
 );

BEGIN
 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr(l_pub_item);
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

  -- process all deletes
  FOR r_messages_del_rec IN l_messages_del_csr LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_messages_del_rec.language_code);

     l_access_id := r_messages_del_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_MESSAGES',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.DEL, sysdate);
     END IF;

     -- delete from acc table
     DELETE FROM csm_messages_acc WHERE access_id = l_access_id;
  END LOOP;

  -- process all updates
  FOR r_messages_upd_rec IN l_messages_upd_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_messages_upd_rec.language_code);

     l_access_id := r_messages_upd_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_MESSAGES',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.UPD, sysdate);
     END IF;

  END LOOP;

  -- process all inserts
  FOR r_messages_ins_rec IN l_messages_ins_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_messages_ins_rec.language_code);

     SELECT csm_messages_acc_s.nextval
     INTO l_access_id
     FROM dual;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
     l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_MESSAGES',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.INS, sysdate);
     END IF;

     INSERT INTO csm_messages_acc (access_id,
                                  application_id,
                                  message_name,
                                  language_code,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login
                                  )
                          VALUES (l_access_id,
                                  r_messages_ins_rec.application_id,
                                  r_messages_ins_rec.message_name,
                                  r_messages_ins_rec.language_code,
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
  WHERE package_name = 'CSM_MESSAGES_EVENT_PKG'
    AND procedure_name = 'REFRESH_ACC';

 COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_MESSAGES_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status := 'ERROR';
     p_message :=  'Error in CSM_MESSAGES_EVENT_PKG.Refresh_Acc : ' || l_sqlerrno || ':' || l_sqlerrmsg;
     fnd_file.put_line(fnd_file.log, p_message);
     ROLLBACK;
END Refresh_Acc;
END CSM_MESSAGES_EVENT_PKG;

/
