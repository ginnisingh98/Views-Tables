--------------------------------------------------------
--  DDL for Package Body CSM_LOOKUP_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_LOOKUP_EVENT_PKG" AS
/* $Header: csmelkub.pls 120.15.12010000.4 2009/09/15 07:13:00 trajasek ship $ */

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

/**
Refreshes the CSM_LOOKUP_TYPES_ACC table, and marks dirty for users accordingly
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- Anurag     09/23/02 Added conditions for CS_CREDIT_CARD_TYPES in the cursor
                       where clauses
*/
procedure Refresh_Acc (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
--variable Declarations
l_prog_update_date 			  jtm_con_request_data.last_run_date%TYPE;
l_access_id 				  jtm_fnd_lookups_acc.access_id%TYPE;
l_mark_dirty 				  boolean;
l_run_date 					  date;
l_sqlerrno 					  VARCHAR2(20);
l_sqlerrmsg 				  varchar2(2000);
l_pub_item 					  varchar2(30) := 'CSF_M_LOOKUPS';
l_tl_omfs_palm_resource_list  asg_download.user_list;
l_null_resource_list 		  asg_download.user_list;
l_single_access_id_list 	  asg_download.access_list;
--a null list
l_null_access_list 			  asg_download.access_list;

CURSOR  l_last_run_date_csr(p_pub_item IN varchar2)
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50))
FROM 	jtm_con_request_data
WHERE 	package_name   = 'CSM_LOOKUP_EVENT_PKG'
AND 	procedure_name = 'REFRESH_ACC';

-- inserts cursor
CURSOR 	l_lookups_ins_csr(p_last_upd_date date)
IS
SELECT 	val.lookup_type,
		val.view_application_id,
		val.lookup_code,
       	val.security_group_id,
		val.language,
		val.last_update_date
FROM 	fnd_lookup_values val
WHERE 	enabled_flag = 'Y'
AND (
    (val.view_application_id = 0   AND val.lookup_type  = 'JTF_RS_RESOURCE_TYPES' AND val.lookup_code IN ('RS_EMPLOYEE','RS_GROUP'))
OR
    (val.view_application_id = 0   AND val.lookup_type  = 'JTF_NOTE_STATUS')
OR  (val.view_application_id = 0   AND val.lookup_type  = 'JTF_NOTE_TYPE' AND
     (val.lookup_code in (select object_id
                          from jtf_object_mappings
                          where object_code like 'JTF_NOTE_TYPE%' and
                          source_object_code in ('SR', 'TASK', 'PARTY', 'CP', 'SD', 'OKS_COV_NOTE')) OR
        NOT EXISTS ( SELECT 1
                     FROM jtf_object_mappings
                     WHERE object_id = val.lookup_code)))
OR  (val.view_application_id = 170 AND val.lookup_type	 = 'REQUEST_PROBLEM_CODE')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSF_MATERIAL_REASON')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSF_EXPENSE_REASON')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSF_LABOR_REASON')
OR  (val.view_application_id = 0   AND val.lookup_type   = 'CSP_RECOVERED_PART_DISP_CODE')
OR  (val.view_application_id = 170 AND val.lookup_type   = 'REQUEST_RESOLUTION_CODE')
OR 	(val.view_application_id = 170 AND val.lookup_type   = 'CS_CTR_MISC_READING_TYPE')
OR 	(val.view_application_id = 690 AND val.lookup_type	 = 'JTF_TASK_ESC_LEVEL')
OR 	(val.view_application_id = 222 AND val.lookup_type 	 = 'CREDIT_MEMO_REASON')
OR 	(val.view_application_id = 542 AND val.lookup_type 	 = 'CSI_ACCOUNTING_CLASS_CODE')
OR  (val.view_application_id = 542 AND val.lookup_type 	 = 'CSI_INST_TYPE_CODE')
OR  (val.view_application_id = 542 AND val.lookup_type 	 = 'CSI_COUNTER_DIRECTION_TYPE')
OR  (val.view_application_id = 542 AND val.lookup_type 	 = 'CSI_CTR_READING_RESET_TYPE')
OR  (val.view_application_id = 0   AND val.lookup_type   = 'ATCHMT_DOCUMENT_TYPE')
OR 	(val.view_application_id = 170 AND val.lookup_type	 = 'CS_SR_CONTACT_TYPE')
OR  (val.view_application_id = 542 AND val.lookup_type 	 = 'CSI_CTR_PROPERTY_LOV_TYPE')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'YES_NO')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSM_CLIENT_QUERY_TYPES')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSM_QUERY_STATUSES')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSM_QUERY_TYPE')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSM_EXECUTION_MODE')
OR  (val.view_application_id = 0   AND val.lookup_type 	 = 'CSM_OUTPUT_FORMAT')
OR  (val.view_application_id = 3   AND val.lookup_type   = 'PER_US_COUNTRY_CODE')
	  )
AND NOT EXISTS
 (SELECT 1
  FROM  csm_lookups_acc acc
  WHERE acc.lookup_type    	    = val.lookup_type
  AND 	acc.language 	   	    = val.language
  AND 	acc.lookup_code    	    = val.lookup_code
  AND 	acc.security_group_id   = val.security_group_id
  AND 	acc.view_application_id = val.view_application_id
  )
;

--updates cur
CURSOR l_lookups_upd_csr(p_last_upd_date date)
IS
SELECT acc.access_id, val.lookup_type,
	   val.view_application_id,
	   val.lookup_code,
       val.security_group_id,
	   val.language,
	   val.last_update_date
FROM   fnd_lookup_values val,
       csm_lookups_acc acc
WHERE  acc.lookup_type 	        = val.lookup_type
AND    acc.language 	  	    = val.language
AND    acc.lookup_code 	  	    = val.lookup_code
AND    acc.security_group_id    = val.security_group_id
AND    acc.view_application_id  = val.view_application_id
AND    val.last_update_date     >= p_last_upd_date
AND    enabled_flag    		    = 'Y';

-- deletes cur
CURSOR l_lookups_del_csr(p_last_upd_date date)
IS
SELECT acc.access_id,
	   acc.lookup_type,
	   acc.view_application_id,
	   acc.lookup_code,
	   acc.security_group_id,
	   acc.language,
	   acc.last_update_date
FROM   csm_lookups_acc acc
WHERE NOT EXISTS
(SELECT 1
 FROM  fnd_lookup_values val
 WHERE acc.lookup_type          = val.lookup_type
 AND   acc.language 		    = val.language
 AND   acc.lookup_code 		    = val.lookup_code
 AND   acc.security_group_id    = val.security_group_id
 AND   acc.view_application_id  = val.view_application_id
 AND   val.enabled_flag = 'Y'
);

BEGIN
 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN l_last_run_date_csr(l_pub_item);
 FETCH l_last_run_date_csr INTO l_prog_update_date;
 CLOSE l_last_run_date_csr;

  -- process all deletes
  FOR r_lookups_del_rec IN l_lookups_del_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_lookups_del_rec.language);

      l_access_id := r_lookups_del_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_LOOKUPS',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.DEL, sysdate);
     END IF;

     -- delete from acc table
     DELETE FROM csm_lookups_acc WHERE access_id = l_access_id;
  END LOOP;

  -- process all updates
  FOR r_lookups_upd_rec IN l_lookups_upd_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_lookups_upd_rec.language);

     l_access_id := r_lookups_upd_rec.access_id;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 then
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_LOOKUPS',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.UPD, sysdate);
     END IF;

  END LOOP;

  -- process all inserts
  FOR r_lookups_ins_rec IN l_lookups_ins_csr(l_prog_update_date) LOOP

     --get the users with this language
     l_tl_omfs_palm_resource_list := l_null_resource_list;
     l_tl_omfs_palm_resource_list := csm_util_pkg.get_tl_omfs_palm_resources(r_lookups_ins_rec.language);

     SELECT csm_lookups_acc_s.nextval
     INTO l_access_id
     FROM dual;

     --nullify the access list
     l_single_access_id_list := l_null_access_list;
     FOR i in 1 .. l_tl_omfs_palm_resource_list.COUNT LOOP
         l_single_access_id_list(i) := l_access_id;
     END LOOP;

     --mark dirty the SDQ for all users
     IF l_single_access_id_list.count > 0 THEN
      l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForResource('CSF_M_LOOKUPS',
          l_single_access_id_list, l_tl_omfs_palm_resource_list,
          ASG_DOWNLOAD.INS, sysdate);
     END IF;

     INSERT INTO csm_lookups_acc (access_id,
                                  lookup_type,
                                  language,
                                  lookup_code,
                                  security_group_id,
                                  view_application_id,
                                  created_by,
                                  creation_date,
                                  last_updated_by,
                                  last_update_date,
                                  last_update_login
                                  )
                          VALUES (l_access_id,
                                  r_lookups_ins_rec.lookup_type,
                                  r_lookups_ins_rec.language,
                                  r_lookups_ins_rec.lookup_code,
                                  r_lookups_ins_rec.security_group_id,
                                  r_lookups_ins_rec.view_application_id,
                                  fnd_global.user_id,
                                  l_run_date,
                                  fnd_global.user_id,
                                  l_run_date,
                                  fnd_global.login_id
                                  );

  END LOOP;

  -- set the program update date in jtm_con_request_data to sysdate
  UPDATE jtm_con_request_data
  SET 	 last_run_date  = l_run_date
  WHERE  package_name   = 'CSM_LOOKUP_EVENT_PKG'
    AND  procedure_name = 'REFRESH_ACC';

 COMMIT;

 p_status  := 'FINE';
 p_message :=  'CSM_LOOKUP_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN others THEN
     l_sqlerrno  := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status 	 := 'Error';
     p_message 	 := 'Error in CSM_LOOKUP_EVENT_PKG.Refresh_Acc : ' || l_sqlerrno || ':' || l_sqlerrmsg;
     fnd_file.put_line(fnd_file.log, p_message);
END Refresh_Acc;
END CSM_LOOKUP_EVENT_PKG;

/
