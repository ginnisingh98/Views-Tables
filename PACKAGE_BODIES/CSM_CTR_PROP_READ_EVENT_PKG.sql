--------------------------------------------------------
--  DDL for Package Body CSM_CTR_PROP_READ_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_CTR_PROP_READ_EVENT_PKG" AS
/* $Header: csmecprb.pls 120.2 2006/07/26 09:29:07 trajasek noship $ */

--
-- Purpose: USed to downlaod Counter properties for each counter
-- MODIFICATION HISTORY
-- Person      Date    Comments
-----------------------------------------------------------

/*** Globals ***/
g_count_prp_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROP_VALUES_ACC';
g_count_prp_table_name            CONSTANT VARCHAR2(30) := 'CSI_CTR_PROPERTY_READINGS';
g_count_prp_seq_name              CONSTANT VARCHAR2(30) := 'CSM_COUNTER_PROP_VALUES_ACC_S';
g_count_prp_pk1_name              CONSTANT VARCHAR2(30) := 'COUNTER_PROP_VALUE_ID';
g_count_prp_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  								 CSM_ACC_PKG.t_publication_item_list('CSM_COUNTER_PROP_VALUES');


 PROCEDURE CTR_PROPERTY_READ_INS(p_counter_value_id     NUMBER,
                           	     p_user_id 	      NUMBER,
                           		 p_error_msg      OUT NOCOPY VARCHAR2,
                           		 x_return_status  IN OUT NOCOPY VARCHAR2)
IS
--Cursor to insert counter property
--this happens if a counter is inserted
CURSOR c_prop_value_ins(c_counter_value_id NUMBER,c_user_id NUMBER)
IS
SELECT
B.COUNTER_PROP_VALUE_ID
FROM
CSI_CTR_PROPERTY_READINGS B,
csm_counter_values_acc	 VACC
WHERE B.COUNTER_VALUE_ID    = VACC.COUNTER_VALUE_ID
AND   VACC.USER_ID 	  		= c_user_id
AND   VACC.COUNTER_VALUE_ID = c_counter_value_id
AND NOT EXISTS( SELECT 1
				FROM   CSM_COUNTER_PROP_VALUES_ACC PVACC
				WHERE  PVACC.COUNTER_PROP_VALUE_ID = B.COUNTER_PROP_VALUE_ID
				AND	   PVACC.USER_ID = c_user_id);

--variable declarations
l_err_msg VARCHAR2(4000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_INS' || ' for PK ' || to_char(p_counter_value_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_INS', FND_LOG.LEVEL_PROCEDURE);

  -- Open USER IDs loop
  FOR r_cntr_prp_val_rec IN  c_prop_value_ins(p_counter_value_id,p_user_id) LOOP
      -- Call Insert ACC
      CSM_ACC_PKG.Insert_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_count_prp_pubi_name
              ,P_ACC_TABLE_NAME         => g_count_prp_acc_table_name
              ,P_SEQ_NAME               => g_count_prp_seq_name
              ,P_PK1_NAME               => g_count_prp_pk1_name
              ,P_PK1_NUM_VALUE          => r_cntr_prp_val_rec.counter_prop_value_id
              ,P_USER_ID                => p_user_id
             );
   END LOOP ; --End USER IDs  loop

  l_err_msg := 'Leaving CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_INS' || ' for Counter ' || to_char(p_counter_value_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_INS', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF c_prop_value_ins%ISOPEN  then
        CLOSE c_prop_value_ins;
     END IF;

     p_error_msg := ' FAILED CTR_PROPERTY_READ_INS FOR COUNTER VALUE:' || to_char(p_counter_value_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_INS',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

END CTR_PROPERTY_READ_INS;


 PROCEDURE CTR_PROPERTY_READ_UPD( p_counter_value_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2)
IS
--Cursors to update counter property
--this is called if a counter is updated
CURSOR c_prop_value_upd(c_counter_value_id NUMBER,c_user_id NUMBER)
IS
SELECT
VACC.ACCESS_ID ,
VACC.USER_ID
FROM
CSI_CTR_PROPERTY_READINGS B,
CSM_COUNTER_PROP_VALUES_ACC VACC
WHERE B.COUNTER_PROP_VALUE_ID    = VACC.COUNTER_PROP_VALUE_ID
AND   VACC.USER_ID 	  			 = c_user_id
AND   B.COUNTER_PROP_VALUE_ID 	 = c_counter_value_id;

--variable declarations
l_err_msg VARCHAR2(4000);
l_markdirty BOOLEAN;
l_pub_item_name VARCHAR2(240) := 'CSM_COUNTER_PROP_VALUES';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_UPD' || ' for PK(COUNTER VALUE ID) ' || to_char(p_counter_value_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_UPD', FND_LOG.LEVEL_PROCEDURE);

  -- Open USER IDs loop
  FOR r_cntr_prp_val_rec IN  c_prop_value_upd(p_counter_value_id,p_user_id) LOOP
      -- Call Insert ACC
     l_markdirty := csm_util_pkg.MakeDirtyForUser ( l_pub_item_name
                                				  , r_cntr_prp_val_rec.access_id
                                				  , r_cntr_prp_val_rec.user_id
                                				  , 'U'
                                				  , sysdate);
  END LOOP ; --End USER IDs  loop

  l_err_msg := 'Leaving CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_UPD' || ' for Counter value ' || to_char(p_counter_value_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_UPD', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF c_prop_value_upd%ISOPEN  then
        CLOSE c_prop_value_upd;
     END IF;

     p_error_msg := ' FAILED CTR_PROPERTY_READ_UPD FOR COUNTER VALUE ID : ' || to_char(p_counter_value_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_UPD',FND_LOG.LEVEL_EXCEPTION);
     RAISE;


END CTR_PROPERTY_READ_UPD;

PROCEDURE CTR_PROPERTY_READ_DEL( p_counter_value_id IN NUMBER,
                           	     p_user_id 	 IN NUMBER,
                           		 p_error_msg     OUT NOCOPY VARCHAR2,
                           		 x_return_status IN OUT NOCOPY VARCHAR2)
IS
--Cursor to delete counter property
--this is called if a counter is Deleted for a user
CURSOR c_prop_value_del(c_counter_value_id NUMBER,c_user_id NUMBER)
IS
SELECT
VACC.ACCESS_ID ,
B.COUNTER_PROP_VALUE_ID
FROM
CSI_CTR_PROPERTY_READINGS B,
CSM_COUNTER_PROP_VALUES_ACC VACC
WHERE B.COUNTER_PROP_VALUE_ID    = VACC.COUNTER_PROP_VALUE_ID
AND   VACC.USER_ID 	  			 = c_user_id
AND   B.COUNTER_VALUE_ID 	  	 = c_counter_value_id;

--variable declarations
l_err_msg VARCHAR2(4000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_err_msg := 'Entering CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL' || ' for PK(COUNTER VALUE ID ' || to_char(p_counter_value_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL', FND_LOG.LEVEL_PROCEDURE);

  -- Open counter property id loop
  FOR r_cntr_prp_val_rec IN  c_prop_value_del(p_counter_value_id,p_user_id) LOOP
      -- Call Delete ACC
      CSM_ACC_PKG.Delete_Acc
             ( P_PUBLICATION_ITEM_NAMES => g_count_prp_pubi_name
              ,P_ACC_TABLE_NAME         => g_count_prp_acc_table_name
              ,P_PK1_NAME               => g_count_prp_pk1_name
              ,P_PK1_NUM_VALUE          => r_cntr_prp_val_rec.counter_prop_value_id
              ,P_USER_ID                => p_user_id
             );
   END LOOP ; --End USER IDs  loop

  l_err_msg := 'Leaving CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL' || ' for Counter value' || to_char(p_counter_value_id);
  CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
     IF c_prop_value_del%ISOPEN  then
        CLOSE c_prop_value_del;
     END IF;

     p_error_msg := ' FAILED CTR_PROPERTY_READ_DEL FOR COUNTER VALUE ID : ' || to_char(p_counter_value_id);
     x_return_status := FND_API.G_RET_STS_ERROR;
     CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_CTR_PROP_READ_EVENT_PKG.CTR_PROPERTY_READ_DEL',FND_LOG.LEVEL_EXCEPTION);
     RAISE;

END CTR_PROPERTY_READ_DEL;


PROCEDURE Refresh_acc(p_status OUT NOCOPY VARCHAR2,
                      p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
--variable declarations
TYPE counter_prop_val_tbl_typ IS TABLE OF CSI_CTR_PROPERTY_READINGS.counter_prop_value_id%TYPE INDEX BY BINARY_INTEGER;

l_sqlerrno 		VARCHAR2(20);
l_sqlerrmsg 	varchar2(2000);
l_mark_dirty 	boolean;
l_pub_item 		varchar2(30) := 'CSM_COUNTER_PROP_VALUES';
l_access_list				 	asg_download.access_list;
l_user_list 					asg_download.user_list;
l_all_omfs_resource_list 		asg_download.user_list;
l_null_omfs_resource_list		asg_download.user_list;
l_prog_update_date 				jtm_con_request_data.last_run_date%TYPE;
l_counter_prop_value_id_tbl		counter_prop_val_tbl_typ;

--Cursor Declarations
--Insert Cursor
CURSOR csr_ctr_prop_reading_ins (c_last_run_date DATE)
IS
SELECT CSM_COUNTER_PROP_VALUES_ACC_S.NEXTVAL,
	   prd.counter_prop_value_id,
   	   val_acc.user_id
FROM   CSI_CTR_PROPERTY_READINGS prd,
       csm_counter_values_acc val_acc
where  prd.counter_value_id	    = val_acc.counter_value_id
AND	   val_acc.creation_date    >= c_last_run_date
AND	   NOT EXISTS
	   (SELECT 1 FROM CSM_COUNTER_PROP_VALUES_ACC prop_acc
	    WHERE prop_acc.counter_prop_value_id =prd.counter_prop_value_id
		AND	  prop_acc.user_id    = val_acc.user_id );

--update Not supported for property reading

--Delete cursor
CURSOR csr_ctr_prop_reading_del
IS
SELECT prop_acc.access_id,
	   prop_acc.user_id
FROM   CSI_CTR_PROPERTY_READINGS prd,
	   CSM_COUNTER_PROP_VALUES_ACC prop_acc
where  prd.counter_prop_value_id = prop_acc.counter_prop_value_id
AND    NOT EXISTS
	   (SELECT 1 FROM csm_counter_values_acc val_acc
	    WHERE prd.counter_value_id = val_acc.counter_value_id
		AND	  prop_acc.user_id    = val_acc.user_id);


--Cursor to get last run date
CURSOR	l_last_run_date_csr
IS
SELECT 	nvl(last_run_date, (sysdate - 365*50))
FROM 	jtm_con_request_data
WHERE 	package_name   = 'CSM_CTR_PROP_READ_EVENT_PKG'
AND 	procedure_name = 'REFRESH_ACC';

BEGIN

 CSM_UTIL_PKG.LOG('Entering CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC ',
                         'CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC', FND_LOG.LEVEL_PROCEDURE);

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

 CSM_UTIL_PKG.LOG('Entering delete ', 'CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_STATEMENT);

 -- process all deletes
 OPEN 	csr_ctr_prop_reading_del;
 FETCH 	csr_ctr_prop_reading_del BULK COLLECT INTO l_access_list,l_user_list;
 CLOSE 	csr_ctr_prop_reading_del;

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
     DELETE FROM CSM_COUNTER_PROP_VALUES_ACC WHERE access_id = l_access_list(i);

   l_access_list.delete;
 END IF; -- end of process deletes


 CSM_UTIL_PKG.LOG('Leaving DELETE and entering inserts', 'CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 --process all inserts
 OPEN  csr_ctr_prop_reading_ins (l_prog_update_date);
 FETCH csr_ctr_prop_reading_ins BULK COLLECT INTO l_access_list, l_counter_prop_value_id_tbl,l_user_list;
 CLOSE csr_ctr_prop_reading_ins;

 IF l_access_list.count > 0 THEN
   FOR i IN 1..l_access_list.count LOOP
      l_mark_dirty := csm_util_pkg.MakeDirtyForUser(l_pub_item,
                                                       l_access_list(i),
                                                       l_user_list(i),
                                                       asg_download.ins,
                                                       sysdate);

   END LOOP;

   FORALL i IN 1..l_access_list.count
     INSERT INTO	CSM_COUNTER_PROP_VALUES_ACC
	 				(access_id,
	 				counter_prop_value_id,
					user_id,
					counter,
					created_by,
					creation_date,
					last_updated_by,
					last_update_date,
					last_update_login)
            VALUES (l_access_list(i),
					l_counter_prop_value_id_tbl(i),
					l_user_list(i),
					1,
					fnd_global.user_id,
					sysdate,
					fnd_global.user_id,
					sysdate,
					fnd_global.login_id);


    l_counter_prop_value_id_tbl.delete;
    l_user_list.delete;
    l_access_list.delete;

 END IF; -- end of process inserts

  -- update last_run_date
 UPDATE	jtm_con_request_data
 SET 	last_run_date = sysdate
 WHERE 	package_name  = 'CSM_CTR_PROP_READ_EVENT_PKG'
 AND 	procedure_name= 'REFRESH_ACC';

 COMMIT;

  p_status  := 'FINE';
  p_message :=  'CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC Executed successfully';

  CSM_UTIL_PKG.LOG('Leaving CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC ',
                         'CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_PROCEDURE);

 EXCEPTION
  WHEN others THEN
     l_sqlerrno	 := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,2000);
     p_status    := 'Error';
     p_message   := 'Error in CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC :' || l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
     CSM_UTIL_PKG.LOG('Exception in CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC: ' || l_sqlerrno || ':' || l_sqlerrmsg,
                         'CSM_CTR_PROP_READ_EVENT_PKG.REFRESH_ACC',FND_LOG.LEVEL_EXCEPTION);
END REFRESH_ACC;


END CSM_CTR_PROP_READ_EVENT_PKG; -- Package spec of CSM_CTR_PROP_READ_EVENT_PKG

/
