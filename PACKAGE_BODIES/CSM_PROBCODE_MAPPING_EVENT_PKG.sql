--------------------------------------------------------
--  DDL for Package Body CSM_PROBCODE_MAPPING_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_PROBCODE_MAPPING_EVENT_PKG" AS
/* $Header: csmepbcb.pls 120.2 2005/11/14 09:02:44 trajasek noship $*/
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

PROCEDURE Refresh_probcode_mapping_acc(p_status OUT NOCOPY VARCHAR2,
                                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
TYPE problem_map_detail_id_tbl_typ IS TABLE OF cs_sr_prob_code_mapping_detail.problem_map_detail_id%TYPE INDEX BY BINARY_INTEGER;

l_run_date 		date;
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);
l_mark_dirty	boolean;
g_pub_item 		varchar2(30) := 'CSM_PROBCODE_MAPPING';
l_prog_update_date				jtm_con_request_data.last_run_date%TYPE;
l_map_access_list				asg_download.access_list;
l_all_omfs_resource_list 		asg_download.user_list;
l_null_omfs_resource_list		asg_download.user_list;
l_problem_map_detail_id_tbl  	problem_map_detail_id_tbl_typ;



-- Cursor Declaration
CURSOR csr_probcode_map_ins
IS
SELECT 	csm_probcode_mapping_acc_s.nextval,
		b.problem_map_detail_id
FROM 	CS_SR_PROB_CODE_MAPPING_DETAIL b
WHERE 	NOT EXISTS
    	(
		SELECT	1
     	FROM 	CSM_PROBCODE_MAPPING_ACC acc
     	WHERE 	acc.problem_map_detail_id = b.problem_map_detail_id
    	);

--Update Cursor
CURSOR 	csr_probcode_map_upd(p_lastrundate IN date)
IS
SELECT 	access_id
FROM 	CSM_PROBCODE_MAPPING_ACC		acc,
     	CS_SR_PROB_CODE_MAPPING_DETAIL 	b
WHERE 	acc.problem_map_detail_id 		 = b.problem_map_detail_id
AND 	b.last_update_date >= p_lastrundate;

--Delete Cursor
CURSOR 	csr_probcode_map_del
IS
SELECT 	access_id
FROM	CSM_PROBCODE_MAPPING_ACC acc
WHERE	NOT EXISTS
		(SELECT 1
		  FROM	CS_SR_PROB_CODE_MAPPING_DETAIL b
		  WHERE b.problem_map_detail_id 	=  acc.problem_map_detail_id
		 );

CURSOR	l_last_run_date_csr
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50))
FROM 	jtm_con_request_data
WHERE 	package_name 	= 'CSM_PROBCODE_MAPPING_EVENT_PKG'
AND 	procedure_name  = 'REFRESH_PROBCODE_MAPPING_ACC';

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc ',
                         'CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc', FND_LOG.LEVEL_PROCEDURE);

 -- data program is run
 l_run_date := SYSDATE;

 -- get last conc program update date
 OPEN 	l_last_run_date_csr;
 FETCH  l_last_run_date_csr INTO l_prog_update_date;
 CLOSE  l_last_run_date_csr;

 IF l_map_access_list.count > 0 THEN
   l_map_access_list.delete;
 END IF;

  -- get resource list of all omfs palm users
 l_all_omfs_resource_list := l_null_omfs_resource_list;
 l_all_omfs_resource_list := csm_util_pkg.get_all_omfs_palm_res_list;

 CSM_UTIL_PKG.LOG('Entering deletes ', 'CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc',FND_LOG.LEVEL_STATEMENT);

 -- process all deletes
 OPEN 	csr_probcode_map_del;
 FETCH  csr_probcode_map_del BULK COLLECT INTO l_map_access_list;
 CLOSE  csr_probcode_map_del;

 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
     FOR j IN 1..l_all_omfs_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_map_access_list(i),
                                                       l_all_omfs_resource_list(j),
                                                       asg_download.del,
                                                       l_run_date);

     END LOOP;
   END LOOP;

   -- bulk delete from acc table
   FORALL i IN 1..l_map_access_list.count
     DELETE FROM csm_probcode_mapping_acc WHERE access_id = l_map_access_list(i);

   l_map_access_list.delete;
 END IF; -- end of process deletes

 CSM_UTIL_PKG.LOG('Leaving deletes and entering updates', 'CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc',FND_LOG.LEVEL_PROCEDURE);

 -- process all updates
 OPEN 	csr_probcode_map_upd(l_prog_update_date);
 FETCH  csr_probcode_map_upd BULK COLLECT INTO l_map_access_list;
 CLOSE  csr_probcode_map_upd;

 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
     FOR j IN 1..l_all_omfs_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_map_access_list(i),
                                                       l_all_omfs_resource_list(j),
                                                       asg_download.upd,
                                                       l_run_date);

     END LOOP;
   END LOOP;

   l_map_access_list.delete;
 END IF; -- end of process updates

 IF l_problem_map_detail_id_tbl.count > 0 THEN
    l_problem_map_detail_id_tbl.delete;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving updates and entering inserts', 'CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc',FND_LOG.LEVEL_PROCEDURE);

 --process all inserts
 OPEN 	csr_probcode_map_ins;
 FETCH  csr_probcode_map_ins BULK COLLECT INTO l_map_access_list, l_problem_map_detail_id_tbl;
 CLOSE  csr_probcode_map_ins;

 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
     FOR j IN 1..l_all_omfs_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(g_pub_item,
                                                       l_map_access_list(i),
                                                       l_all_omfs_resource_list(j),
                                                       asg_download.ins,
                                                       l_run_date);

     END LOOP;
   END LOOP;

   FORALL i IN 1..l_map_access_list.count
     INSERT INTO csm_probcode_mapping_acc
	 			(access_id,
				 problem_map_detail_id,
				 created_by, creation_date,
				 last_updated_by,
				 last_update_date,
				 last_update_login)
                 VALUES
				 (l_map_access_list(i),
				 l_problem_map_detail_id_tbl(i),
				 fnd_global.user_id,
				 l_run_date,
				 fnd_global.user_id,
				 l_run_date,
				 fnd_global.login_id);

   l_map_access_list.delete;
 END IF; -- end of process inserts

  -- update last_run_date
 UPDATE	jtm_con_request_data
 SET 	last_run_date 	= l_run_date
 WHERE 	package_name 	= 'CSM_PROBCODE_MAPPING_EVENT_PKG'
 AND 	procedure_name 	= 'REFRESH_PROBCODE_MAPPING_ACC';

 COMMIT;

 p_status  := 'FINE';
 p_message :=  'CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc Executed successfully';

 CSM_UTIL_PKG.LOG('Leaving CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc ',
                         'CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status 	 := 'Error';
     p_message 	 := 'Error in CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_PROBCODE_MAPPING_EVENT_PKG.Refresh_probcode_mapping_acc',FND_LOG.LEVEL_EXCEPTION);
END Refresh_probcode_mapping_acc;

END CSM_PROBCODE_MAPPING_EVENT_PKG;

/
