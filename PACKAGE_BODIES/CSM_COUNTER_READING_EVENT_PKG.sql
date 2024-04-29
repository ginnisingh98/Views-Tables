--------------------------------------------------------
--  DDL for Package Body CSM_COUNTER_READING_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_COUNTER_READING_EVENT_PKG" AS
/* $Header: csmecrdb.pls 120.0 2006/06/30 12:41:57 trajasek noship $*/
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
TYPE counter_value_tbl_typ IS TABLE OF CSI_COUNTER_READINGS.counter_value_id%TYPE INDEX BY BINARY_INTEGER;
TYPE counter_tbl_typ 	   IS TABLE OF CSI_COUNTER_READINGS.counter_id%TYPE INDEX BY BINARY_INTEGER;

l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);
l_mark_dirty 	boolean;
l_pub_item 		varchar2(30) := 'CSF_M_COUNTER_VALUES';
l_access_list				 	asg_download.access_list;
l_user_list 					asg_download.user_list;
l_all_omfs_resource_list 		asg_download.user_list;
l_null_omfs_resource_list		asg_download.user_list;
l_prog_update_date 				jtm_con_request_data.last_run_date%TYPE;
l_counter_value_id_tbl  		counter_value_tbl_typ;
l_counter_id_tbl				counter_tbl_typ;

--Cursor Declarations
--Insert Cursor
CURSOR csr_ctr_reading_ins
IS
SELECT CSM_COUNTER_VALUES_ACC_S.NEXTVAL,
	   cnt_rd.counter_value_id,
	   cnt_acc.counter_id,
   	   cnt_acc.user_id
FROM   CSI_COUNTER_READINGS cnt_rd,
       csm_counters_acc cnt_acc
where  cnt_rd.counter_id=cnt_acc.counter_id
AND	   NOT EXISTS
	   (SELECT 1 FROM csm_counter_values_acc val_acc
	    WHERE VAL_acc.counter_value_id =cnt_rd.counter_value_id);


--update cursor
CURSOR csr_ctr_reading_upd(p_lastrundate IN date)
IS
SELECT val_acc.access_id,
	   val_acc.user_id
FROM   CSI_COUNTER_READINGS cnt_rd,
	   csm_counter_values_acc val_acc
where  cnt_rd.counter_id = val_acc.counter_id
AND	   cnt_rd.last_update_date 	>= p_lastrundate;

--Delete cursor
CURSOR csr_ctr_reading_del
IS
SELECT val_acc.access_id,
	   val_acc.user_id
FROM   CSI_COUNTER_READINGS cnt_rd,
	   csm_counter_values_acc val_acc
where  cnt_rd.counter_id = val_acc.counter_id
AND    NOT EXISTS
	   (SELECT 1 FROM csm_counters_acc cnt_acc
	    WHERE cnt_acc.counter_id =val_acc.counter_id
		AND	  cnt_acc.user_id =val_acc.user_id);


--Cursor to get last run date
CURSOR	l_last_run_date_csr
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50))
FROM 	jtm_con_request_data
WHERE 	package_name   = 'CSM_COUNTER_READING_EVENT_PKG'
AND 	procedure_name = 'REFRESH_ACC';

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC ',
                         'CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC', FND_LOG.LEVEL_PROCEDURE);

 -- get last conc program update date
 OPEN 	l_last_run_date_csr;
 FETCH 	l_last_run_date_csr INTO l_prog_update_date;
 CLOSE 	l_last_run_date_csr;

 IF l_access_list.count > 0 THEN
    l_access_list.delete;
 END IF;

  -- get resource list of all omfs  users
 l_all_omfs_resource_list := l_null_omfs_resource_list;
 l_all_omfs_resource_list := csm_util_pkg.get_all_omfs_palm_res_list;

 CSM_UTIL_PKG.LOG('Entering delete ', 'CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_STATEMENT);

 -- process all deletes
 OPEN 	csr_ctr_reading_del;
 FETCH 	csr_ctr_reading_del BULK COLLECT INTO l_access_list,l_user_list;
 CLOSE 	csr_ctr_reading_del;

--mark dirty for delete
 IF l_access_list.count > 0 THEN
   FOR i IN 1..l_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                    l_access_list(i),
                                                    l_user_list(i),
                                                    asg_download.del,
                                                    sysdate);

   END LOOP;

   -- bulk delete from acc table
   FORALL i IN 1..l_access_list.count
     DELETE FROM csm_counter_values_acc WHERE access_id = l_access_list(i);

   l_access_list.delete;
 END IF; -- end of process deletes

 CSM_UTIL_PKG.LOG('Leaving deletes and entering updates', 'CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);


 -- process all updates
 OPEN	csr_ctr_reading_upd(l_prog_update_date);
 FETCH  csr_ctr_reading_upd BULK COLLECT INTO l_access_list,l_user_list;
 CLOSE  csr_ctr_reading_upd;

 IF l_access_list.count > 0 THEN
   FOR i IN 1..l_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                    l_access_list(i),
                                                    l_user_list(i),
                                                    asg_download.upd,
                                                    sysdate);

   END LOOP;

   l_access_list.delete;
 END IF; -- end of process updates

 IF l_counter_value_id_tbl.count > 0 THEN
    l_counter_value_id_tbl.delete;
 END IF;

 IF l_counter_id_tbl.count > 0 THEN
    l_counter_id_tbl.delete;
 END IF;

  IF l_user_list.count > 0 THEN
    l_user_list.delete;
 END IF;

  IF l_access_list.count > 0 THEN
     l_access_list.delete;
 END IF;

 CSM_UTIL_PKG.LOG('Leaving updates and entering inserts', 'CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 --process all inserts
 OPEN  csr_ctr_reading_ins;
 FETCH csr_ctr_reading_ins BULK COLLECT INTO l_access_list, l_counter_value_id_tbl, l_counter_id_tbl, l_user_list;
 CLOSE csr_ctr_reading_ins;

 IF l_access_list.count > 0 THEN
   FOR i IN 1..l_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                       l_access_list(i),
                                                       l_user_list(i),
                                                       asg_download.ins,
                                                       sysdate);

   END LOOP;

   FORALL i IN 1..l_access_list.count
     INSERT INTO	csm_counter_values_acc
	 				(access_id,
	 				counter_value_id,
					counter_id,
					user_id,
					counter,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login)
            VALUES (l_access_list(i),
					l_counter_value_id_tbl(i),
					l_counter_id_tbl(i),
					l_user_list(i),
					1,
					fnd_global.user_id,
					sysdate,
					fnd_global.user_id,
					sysdate,
					fnd_global.login_id);


    l_counter_value_id_tbl.delete;
    l_counter_id_tbl.delete;
    l_user_list.delete;
    l_access_list.delete;

 END IF; -- end of process inserts

  -- update last_run_date
 UPDATE	jtm_con_request_data
 SET 	last_run_date = sysdate
 WHERE 	package_name  = 'CSM_COUNTER_READING_EVENT_PKG'
 AND 	procedure_name= 'REFRESH_ACC';

 COMMIT;

  p_status  := 'FINE';
  p_message :=  'CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC Executed successfully';

  CSM_UTIL_PKG.LOG('Leaving CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC ',
                         'CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status    := 'Error';
     p_message   := 'Error in CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_COUNTER_READING_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
END REFRESH_ACC;

PROCEDURE COUNTER_VALUE_ACC_INS(p_counter_value_id IN NUMBER,
		  						p_counter_id IN NUMBER,
								p_error_msg OUT NOCOPY VARCHAR2,
                                x_return_status IN OUT NOCOPY VARCHAR2)
IS
--variable declarations
TYPE counter_value_tbl_typ IS TABLE OF CSI_COUNTER_READINGS.counter_value_id%TYPE INDEX BY BINARY_INTEGER;
TYPE counter_tbl_typ 	   IS TABLE OF CSI_COUNTER_READINGS.counter_id%TYPE INDEX BY BINARY_INTEGER;

l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);
l_mark_dirty 	boolean;
l_pub_item 		varchar2(30) := 'CSF_M_COUNTER_VALUES';
l_access_list				 	asg_download.access_list;
l_user_list 					asg_download.user_list;
l_counter_value_id_tbl  		counter_value_tbl_typ;
l_counter_id_tbl				counter_tbl_typ;

--Cursor Declarations
--Insert Cursor
CURSOR csr_ctr_reading_ins(c_counter_value_id NUMBER,c_counter_id Number)
IS
SELECT CSM_COUNTER_VALUES_ACC_S.NEXTVAL,
	   cnt_rd.counter_value_id,
	   cnt_acc.counter_id,
   	   cnt_acc.user_id
FROM   CSI_COUNTER_READINGS cnt_rd,
       csm_counters_acc cnt_acc
where  cnt_rd.counter_id=cnt_acc.counter_id
AND	   cnt_rd.counter_value_id = c_counter_value_id
AND	   cnt_acc.counter_id = c_counter_id
AND	   NOT EXISTS
	   (SELECT 1 FROM csm_counter_values_acc val_acc
	    WHERE val_acc.counter_value_id =cnt_rd.counter_value_id
		AND   val_acc.user_id =cnt_acc.user_id);

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS ',
                         'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS', FND_LOG.LEVEL_PROCEDURE);

 IF l_access_list.count > 0 THEN
    l_access_list.delete;
    l_counter_value_id_tbl.delete;
    l_counter_id_tbl.delete;
    l_user_list.delete;
 END IF;


 CSM_UTIL_PKG.LOG('Entering Insert ', 'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS',FND_LOG.LEVEL_STATEMENT);

 --process all inserts
 OPEN  csr_ctr_reading_ins(p_counter_value_id,p_counter_id);
 FETCH csr_ctr_reading_ins BULK COLLECT INTO l_access_list, l_counter_value_id_tbl, l_counter_id_tbl, l_user_list;
 CLOSE csr_ctr_reading_ins;

 IF l_access_list.count > 0 THEN
   FOR i IN 1..l_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                       l_access_list(i),
                                                       l_user_list(i),
                                                       asg_download.ins,
                                                       sysdate);

   END LOOP;

   FORALL i IN 1..l_access_list.count
     INSERT INTO	csm_counter_values_acc
	 				(access_id,
	 				counter_value_id,
					counter_id,
					user_id,
					counter,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login)
            VALUES (l_access_list(i),
					l_counter_value_id_tbl(i),
					l_counter_id_tbl(i),
					l_user_list(i),
					1,
					fnd_global.user_id,
					sysdate,
					fnd_global.user_id,
					sysdate,
					fnd_global.login_id);


    l_counter_value_id_tbl.delete;
    l_counter_id_tbl.delete;
    l_user_list.delete;
    l_access_list.delete;

 END IF; -- end of process insert

 CSM_UTIL_PKG.LOG('Leaving CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS ',
                         'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS',FND_LOG.LEVEL_PROCEDURE);
 x_return_status := FND_API.G_RET_STS_SUCCESS;


 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_error_msg   := 'Error in CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS :' || l_sqlerrno || ':' || l_sqlerrmsg;
	 x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE;
     CSM_UTIL_PKG.LOG('Exception in CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_INS',FND_LOG.LEVEL_EXCEPTION);
END COUNTER_VALUE_ACC_INS;





PROCEDURE COUNTER_VALUE_ACC_UPD(p_counter_value_id IN NUMBER,
		  						p_counter_id IN NUMBER,
								p_error_msg OUT NOCOPY VARCHAR2,
                                x_return_status IN OUT NOCOPY VARCHAR2)
IS
--variable declarations

l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);
l_mark_dirty 	boolean;
l_pub_item 		varchar2(30) := 'CSF_M_COUNTER_VALUES';
l_access_list				 	asg_download.access_list;
l_user_list 					asg_download.user_list;

--Cursor Declarations
--Update  Cursor
CURSOR csr_ctr_reading_upd(c_counter_value_id NUMBER)
IS
SELECT val_acc.access_id,
   	   val_acc.user_id
FROM   csm_counter_values_acc val_acc
WHERE  val_acc.counter_value_id =c_counter_value_id;

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD ',
                         'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD', FND_LOG.LEVEL_PROCEDURE);

 IF l_access_list.count > 0 THEN
    l_access_list.delete;
    l_user_list.delete;
 END IF;


 CSM_UTIL_PKG.LOG('Entering Update Counter Value id ', 'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD',FND_LOG.LEVEL_STATEMENT);

 --process all inserts
 OPEN  csr_ctr_reading_upd(p_counter_value_id);
 FETCH csr_ctr_reading_upd BULK COLLECT INTO l_access_list,l_user_list;
 CLOSE csr_ctr_reading_upd;

 IF l_access_list.count > 0 THEN
   FOR i IN 1..l_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                       l_access_list(i),
                                                       l_user_list(i),
                                                       asg_download.ins,
                                                       sysdate);

   END LOOP;
   l_user_list.delete;
   l_access_list.delete;

 END IF; -- end of process insert

 CSM_UTIL_PKG.LOG('Leaving CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD ',
                         'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD',FND_LOG.LEVEL_PROCEDURE);
 x_return_status := FND_API.G_RET_STS_SUCCESS;


 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_error_msg   := 'Error in CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD :' || l_sqlerrno || ':' || l_sqlerrmsg;
	 x_return_status := FND_API.G_RET_STS_ERROR;
     RAISE;
     CSM_UTIL_PKG.LOG('Exception in CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_COUNTER_READING_EVENT_PKG.COUNTER_VALUE_ACC_UPD',FND_LOG.LEVEL_EXCEPTION);
END COUNTER_VALUE_ACC_UPD;

END CSM_COUNTER_READING_EVENT_PKG;

/
