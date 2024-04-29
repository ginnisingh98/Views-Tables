--------------------------------------------------------
--  DDL for Package Body CSM_RESCODE_MAPPING_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_RESCODE_MAPPING_EVENT_PKG" AS
/* $Header: csmercmb.pls 120.0 2005/11/14 09:11:21 trajasek noship $*/
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



PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                      p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
--variable declarations
TYPE res_map_id_tbl_typ IS TABLE OF CS_SR_RES_CODE_MAPPING_DETAIL.resolution_map_detail_id%TYPE INDEX BY BINARY_INTEGER;
l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);
l_mark_dirty 	boolean;
l_pub_item 		varchar2(30) := 'CSM_RESCODE_MAPPING';
l_map_access_list				asg_download.access_list;
l_all_omfs_resource_list 		asg_download.user_list;
l_null_omfs_resource_list		asg_download.user_list;
l_prog_update_date 				jtm_con_request_data.last_run_date%TYPE;
l_resol_map_id_tbl  			res_map_id_tbl_typ;

--Cursor Declarations
--Insert Cursor
CURSOR csr_rescode_map_ins
IS
SELECT 	csm_rescode_mapping_acc_s.nextval,
		b.resolution_map_detail_id
FROM 	CS_SR_RES_CODE_MAPPING_DETAIL b
WHERE 	NOT EXISTS
    	(
		SELECT	1
     	FROM 	CSM_RESCODE_MAPPING_ACC acc
     	WHERE 	acc.resolution_map_detail_id = b.resolution_map_detail_id
    	);
--update cursor
CURSOR csr_rescode_map_upd(p_lastrundate IN date)
IS
SELECT 	access_id
FROM	CSM_RESCODE_MAPPING_ACC acc,
		CS_SR_RES_CODE_MAPPING_DETAIL b
WHERE 	b.resolution_map_detail_id 	=  acc.resolution_map_detail_id
AND		b.last_update_Date			>= p_lastrundate;
--Delete cursor
CURSOR csr_rescode_map_del
IS
SELECT 	access_id
FROM	CSM_RESCODE_MAPPING_ACC acc
WHERE	NOT EXISTS
		(SELECT 1
		  FROM	CS_SR_RES_CODE_MAPPING_DETAIL b
		  WHERE b.resolution_map_detail_id 	=  acc.resolution_map_detail_id
		 );
--Cursor to get last run date
CURSOR	l_last_run_date_csr
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50))
FROM 	jtm_con_request_data
WHERE 	package_name   = 'CSM_RESCODE_MAPPING_EVENT_PKG'
AND 	procedure_name = 'REFRESH_ACC';

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC ',
                         'CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC', FND_LOG.LEVEL_PROCEDURE);

 -- get last conc program update date
 OPEN 	l_last_run_date_csr;
 FETCH 	l_last_run_date_csr INTO l_prog_update_date;
 CLOSE 	l_last_run_date_csr;

 IF l_map_access_list.count > 0 THEN
    l_map_access_list.delete;
 END IF;

  -- get resource list of all omfs  users
 l_all_omfs_resource_list := l_null_omfs_resource_list;
 l_all_omfs_resource_list := csm_util_pkg.get_all_omfs_palm_res_list;

 CSM_UTIL_PKG.LOG('Entering delete ', 'CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_STATEMENT);

 -- process all deletes
 OPEN 	csr_rescode_map_del;
 FETCH 	csr_rescode_map_del BULK COLLECT INTO l_map_access_list;
 CLOSE 	csr_rescode_map_del;

--mark dirty for delete
 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
     FOR j IN 1..l_all_omfs_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(l_pub_item,
                                                       l_map_access_list(i),
                                                       l_all_omfs_resource_list(j),
                                                       asg_download.del,
                                                       sysdate);

     END LOOP;
   END LOOP;

   -- bulk delete from acc table
   FORALL i IN 1..l_map_access_list.count
     DELETE FROM csm_rescode_mapping_acc WHERE access_id = l_map_access_list(i);

   l_map_access_list.delete;
 END IF; -- end of process deletes

 CSM_UTIL_PKG.LOG('Leaving deletes and entering updates', 'CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);


 -- process all updates
 OPEN	csr_rescode_map_upd(l_prog_update_date);
 FETCH  csr_rescode_map_upd BULK COLLECT INTO l_map_access_list;
 CLOSE  csr_rescode_map_upd;

 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
     FOR j IN 1..l_all_omfs_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(l_pub_item,
                                                       l_map_access_list(i),
                                                       l_all_omfs_resource_list(j),
                                                       asg_download.upd,
                                                       sysdate);

     END LOOP;
   END LOOP;

   l_map_access_list.delete;
 END IF; -- end of process updates

 IF l_resol_map_id_tbl.count > 0 THEN
    l_resol_map_id_tbl.delete;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving updates and entering inserts', 'CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 --process all inserts
 OPEN  csr_rescode_map_ins;
 FETCH csr_rescode_map_ins BULK COLLECT INTO l_map_access_list, l_resol_map_id_tbl;
 CLOSE csr_rescode_map_ins;

 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
     FOR j IN 1..l_all_omfs_resource_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForResource(l_pub_item,
                                                       l_map_access_list(i),
                                                       l_all_omfs_resource_list(j),
                                                       asg_download.ins,
                                                       sysdate);

     END LOOP;
   END LOOP;

   FORALL i IN 1..l_map_access_list.count
     INSERT INTO	CSM_RESCODE_MAPPING_ACC
	 				(access_id,
	 				resolution_map_detail_id,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login)
            VALUES (l_map_access_list(i),
					l_resol_map_id_tbl(i),
					fnd_global.user_id,
					sysdate,
					fnd_global.user_id,
					sysdate,
					fnd_global.login_id);

   l_map_access_list.delete;
 END IF; -- end of process inserts

  -- update last_run_date
 UPDATE	jtm_con_request_data
 SET 	last_run_date = sysdate
 WHERE 	package_name  = 'CSM_RESCODE_MAPPING_EVENT_PKG'
 AND 	procedure_name= 'REFRESH_ACC';

 COMMIT;

  p_status  := 'FINE';
  p_message :=  'CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC Executed successfully';

  CSM_UTIL_PKG.LOG('Leaving CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC ',
                         'CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status    := 'Error';
     p_message   := 'Error in CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_RESCODE_MAPPING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
END REFRESH_ACC;

END CSM_RESCODE_MAPPING_EVENT_PKG;

/
