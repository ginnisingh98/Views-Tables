--------------------------------------------------------
--  DDL for Package Body CSM_SR_TYPE_MAP_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_SR_TYPE_MAP_EVENT_PKG" AS
/* $Header: csmeitmb.pls 120.2 2008/02/07 07:45:35 anaraman ship $*/
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
TYPE incident_type_id_tbl_typ  IS TABLE OF CS_SR_TYPE_MAPPING.incident_type_id%TYPE  INDEX BY BINARY_INTEGER;
TYPE responsibility_id_tbl_typ IS TABLE OF CS_SR_TYPE_MAPPING.responsibility_id%TYPE INDEX BY BINARY_INTEGER;

l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);
l_mark_dirty 	boolean;
l_pub_item 		varchar2(30) := 'CSM_SR_TYPE_MAPPING';
l_map_access_list				asg_download.access_list;
l_all_omfs_resource_list 		asg_download.user_list;
l_null_omfs_resource_list		asg_download.user_list;
l_prog_update_date 				jtm_con_request_data.last_run_date%TYPE;
l_sr_type_id_tbl  				incident_type_id_tbl_typ;
l_responsibility_id_tbl  		responsibility_id_tbl_typ;
l_user_list 					asg_download.user_list;

--Cursor Declarations
--Insert Cursor
CURSOR  csr_sr_type_map_ins
IS
SELECT 	CSM_SR_TYPE_MAPPING_ACC_S.nextval,
		usr.user_id,
		b.incident_type_id,
		b.responsibility_id
FROM 	CS_SR_TYPE_MAPPING b,
		ASG_USER           usr
WHERE	usr.responsibility_id = b.responsibility_id
AND     usr.user_id           = usr.owner_id
AND NOT EXISTS
    	(
		SELECT	1
     	FROM 	CSM_SR_TYPE_MAPPING_ACC acc
     	WHERE 	acc.incident_type_id 	= b.incident_type_id
     	AND		acc.responsibility_id	= b.responsibility_id
		AND		acc.user_id				= usr.user_id
    	);
--update cursor
CURSOR  csr_sr_type_map_upd(p_lastrundate IN date)
IS
SELECT 	access_id,user_id
FROM	CSM_SR_TYPE_MAPPING_ACC acc,
		CS_SR_TYPE_MAPPING b
WHERE 	acc.incident_type_id 	= b.incident_type_id
AND		acc.responsibility_id	= b.responsibility_id
AND		b.last_update_Date	   >= p_lastrundate;

--Delete cursor
CURSOR  csr_sr_type_map_del
IS
SELECT 	access_id,user_id
FROM	CSM_SR_TYPE_MAPPING_ACC acc
WHERE	NOT EXISTS
		(SELECT 1
		  FROM	CS_SR_TYPE_MAPPING b
		  WHERE b.incident_type_id 	= acc.incident_type_id
		  AND	b.responsibility_id	= acc.responsibility_id
		 );
--Cursor to get last run dateR12 change
CURSOR	l_last_run_date_csr
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50))
FROM 	jtm_con_request_data
WHERE 	package_name   = 'CSM_SR_TYPE_MAP_EVENT_PKG'
AND 	procedure_name = 'REFRESH_ACC';

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC ',
                         'CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC', FND_LOG.LEVEL_PROCEDURE);

 -- get last conc program update date
 OPEN 	l_last_run_date_csr;
 FETCH 	l_last_run_date_csr INTO l_prog_update_date;
 CLOSE 	l_last_run_date_csr;

 IF l_map_access_list.count > 0 THEN
    l_map_access_list.delete;
 END IF;

  -- get resource list of all omfs  users R12 change
 l_user_list			  := l_null_omfs_resource_list;

 CSM_UTIL_PKG.LOG('Entering delete ', 'CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_STATEMENT);

 -- process all deletes
 OPEN 	csr_sr_type_map_del;
 FETCH 	csr_sr_type_map_del BULK COLLECT INTO l_map_access_list,l_user_list;
 CLOSE 	csr_sr_type_map_del;

--mark dirty for delete
 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser (l_pub_item,
                                                     l_map_access_list(i),
                                                     l_user_list(i),
                                                     asg_download.del,
                                                     sysdate);

   END LOOP;

   -- bulk delete from acc table
   FORALL i IN 1..l_map_access_list.count
     DELETE FROM CSM_SR_TYPE_MAPPING_ACC WHERE access_id = l_map_access_list(i) AND user_id = l_user_list(i) ;

   l_map_access_list.delete;
   l_user_list.delete;
 END IF; -- end of process deletes

 CSM_UTIL_PKG.LOG('Leaving deletes and entering updates', 'CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);


 -- process all updates
 OPEN	csr_sr_type_map_upd(l_prog_update_date);
 FETCH  csr_sr_type_map_upd BULK COLLECT INTO l_map_access_list,l_user_list;
 CLOSE  csr_sr_type_map_upd;

 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                    l_map_access_list(i),
                                                    l_user_list(i),
                                                    asg_download.upd,
                                                    sysdate);

   END LOOP;

   l_map_access_list.delete;
   l_user_list.delete;
 END IF; -- end of process updates

 IF l_sr_type_id_tbl.count > 0 THEN
    l_sr_type_id_tbl.delete;
 END IF;

 IF l_responsibility_id_tbl.count > 0 THEN
    l_responsibility_id_tbl.delete;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving updates and entering inserts', 'CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 --process all inserts
 OPEN  csr_sr_type_map_ins;
 FETCH csr_sr_type_map_ins BULK COLLECT INTO l_map_access_list,l_user_list, l_sr_type_id_tbl, l_responsibility_id_tbl;
 CLOSE csr_sr_type_map_ins;

 IF l_map_access_list.count > 0 THEN
   FOR i IN 1..l_map_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                    l_map_access_list(i),
                                                    l_user_list(i),
                                                    asg_download.ins,
                                                    sysdate);

   END LOOP;

   FORALL i IN 1..l_map_access_list.count
     INSERT INTO	CSM_SR_TYPE_MAPPING_ACC
	 				(access_id,
					user_id,
	 				incident_type_id,
					responsibility_id,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login)
            VALUES (l_map_access_list(i),
				    l_user_list(i),
					l_sr_type_id_tbl(i),
					l_responsibility_id_tbl(i),
					fnd_global.user_id,
					sysdate,
					fnd_global.user_id,
					sysdate,
					fnd_global.login_id);

   l_map_access_list.delete;
   l_user_list.delete;
 END IF; -- end of process inserts

  -- update last_run_date
 UPDATE	jtm_con_request_data
 SET 	last_run_date = sysdate
 WHERE 	package_name  = 'CSM_SR_TYPE_MAP_EVENT_PKG'
 AND 	procedure_name= 'REFRESH_ACC';

 COMMIT;

  p_status  := 'FINE';
  p_message :=  'CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC Executed successfully';

  CSM_UTIL_PKG.LOG('Leaving CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC ',
                         'CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status    := 'Error';
     p_message   := 'Error in CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_SR_TYPE_MAP_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
END REFRESH_ACC;

END CSM_SR_TYPE_MAP_EVENT_PKG;

/
