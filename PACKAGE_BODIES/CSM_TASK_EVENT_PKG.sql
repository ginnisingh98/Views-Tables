--------------------------------------------------------
--  DDL for Package Body CSM_TASK_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_TASK_EVENT_PKG" AS
/* $Header: csmetskb.pls 120.2 2006/09/15 13:00:57 trajasek noship $ */

   l_markdirty_failed EXCEPTION;

/*** Globals ***/
g_tasks_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_TASKS_ACC';
g_tasks_table_name            CONSTANT VARCHAR2(30) := 'JTF_TASKS_B';
g_tasks_seq_name              CONSTANT VARCHAR2(30) := 'CSM_TASKS_ACC_S';
g_tasks_pk1_name              CONSTANT VARCHAR2(30) := 'TASK_ID';
g_tasks_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSM_TASKS');

/** to be called from csm_task_assignment_event_pkg.task_assignments_acc_processor **/
PROCEDURE ACC_INSERT (p_user_id in fnd_user.user_id%TYPE,
                      p_task_id jtf_tasks_b.task_id%TYPE)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering ACC_INSERT for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.ACC_INSERT',FND_LOG.LEVEL_PROCEDURE);

      CSM_ACC_PKG.Insert_Acc
      ( P_PUBLICATION_ITEM_NAMES => g_tasks_pubi_name
       ,P_ACC_TABLE_NAME         => g_tasks_acc_table_name
       ,P_SEQ_NAME               => g_tasks_seq_name
       ,P_PK1_NAME               => g_tasks_pk1_name
       ,P_PK1_NUM_VALUE          => p_task_id
       ,P_USER_ID                => p_user_id
      );

   CSM_UTIL_PKG.LOG('Leaving ACC_INSERT for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.ACC_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  ACC_INSERT for task_id:'
                       || to_char(p_task_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_EVENT_PKG.ACC_INSERT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END ACC_INSERT;


/** to be called from csm_task_assignment_event_pkg.task_assignments_acc_d **/
PROCEDURE ACC_DELETE (p_user_id in fnd_user.user_id%TYPE,
                      p_task_id jtf_tasks_b.task_id%TYPE)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering ACC_DELETE for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.ACC_DELETE',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Delete_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_tasks_pubi_name
     ,P_ACC_TABLE_NAME         => g_tasks_acc_table_name
     ,P_PK1_NAME               => g_tasks_pk1_name
     ,P_PK1_NUM_VALUE          => p_task_id
     ,P_USER_ID                => p_user_id
    );

   CSM_UTIL_PKG.LOG('Leaving ACC_DELETE for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.ACC_DELETE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
  WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  ACC_DELETE for task_id:'
                       || to_char(p_task_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_EVENT_PKG.ACC_DELETE',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END ACC_DELETE;

/**
** Conc program called every midnight to purge tasks created_by mobile user, depending on the
** history profile of the user
**/
PROCEDURE PURGE_TASKS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_task_id jtf_tasks_b.task_id%TYPE;
l_user_id  csm_tasks_acc.USER_ID%TYPE;
l_last_run_date date;
l_dummy NUMBER;

CURSOR l_purge_tasks_csr
IS
SELECT acc.task_id,
       acc.USER_ID,
       acc.COUNTER,
   	   jt.source_object_type_code
FROM   csm_tasks_acc acc,
       jtf_tasks_b jt
WHERE  jt.task_id = acc.task_id
  AND  jt.created_by = acc.user_id  -- task is created by the user
  AND  jt.creation_date
       < (SYSDATE - csm_profile_pkg.get_task_history_days(acc.user_id))
;
-- check if the task and user pair exist in csm_task_assignments_acc
CURSOR l_task_assignment_csr (b_task_id NUMBER, b_user_id NUMBER)
IS
SELECT acc.counter
FROM   CSM_TASK_ASSIGNMENTS_ACC acc,
       JTF_TASK_ASSIGNMENTS jta
WHERE  acc.TASK_ASSIGNMENT_ID = jta.TASK_ASSIGNMENT_ID
AND    jta.TASK_ID = b_task_id
AND    acc.USER_ID = b_user_id;

CURSOR l_upd_last_run_date_csr
IS
SELECT 1
FROM jtm_con_request_data
WHERE product_code = 'CSM'
AND package_name = 'CSM_TASK_EVENT_PKG'
AND procedure_name = 'PURGE_TASKS_CONC'
FOR UPDATE OF last_run_date NOWAIT
;

TYPE l_task_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_task_tbl    l_task_tbl_type;
TYPE l_userid_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_userid_tbl  l_userid_tbl_type;
TYPE l_counter_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_counter_tbl l_counter_tbl_type;
TYPE l_task_src_type_tbl_type   IS TABLE OF jtf_tasks_b.source_object_type_code%TYPE INDEX BY BINARY_INTEGER;
l_task_src_type_tbl l_task_src_type_tbl_type;

l_tsk_counter NUMBER;
l_tas_counter NUMBER;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  l_last_run_date := SYSDATE;
  l_tsk_counter := 0;
  l_tas_counter := 0;

  OPEN l_purge_tasks_csr;
  LOOP
    IF l_task_tbl.COUNT > 0 THEN
       l_task_tbl.DELETE;
    END IF;
    IF l_userid_tbl.COUNT > 0 THEN
       l_userid_tbl.DELETE;
    END IF;
    IF l_counter_tbl.COUNT > 0 THEN
       l_counter_tbl.DELETE;
    END IF;

  FETCH l_purge_tasks_csr BULK COLLECT INTO l_task_tbl, l_userid_tbl, l_counter_tbl,l_task_src_type_tbl LIMIT 50;
  EXIT WHEN l_task_tbl.COUNT = 0;

    IF l_task_tbl.COUNT > 0 THEN
      CSM_UTIL_PKG.LOG(TO_CHAR(l_task_tbl.COUNT) || ' task records sent for purge', 'CSM_SR_EVENT_PKG.PURGE_INCIDENTS_CONC',FND_LOG.LEVEL_EVENT);
      FOR i IN l_task_tbl.FIRST..l_task_tbl.LAST LOOP
        l_task_id := l_task_tbl(i);
        l_user_id := l_userid_tbl(i);
        l_tsk_counter := l_counter_tbl(i);


		OPEN l_task_assignment_csr(l_task_id, l_user_id);
        FETCH l_task_assignment_csr INTO l_tas_counter;
        IF l_task_assignment_csr%NOTFOUND THEN
          l_tas_counter := 0;
        END IF;
        CLOSE l_task_assignment_csr;

        -- do task delete only for those not to be handled by task_assignment_purge
        IF l_tsk_counter > l_tas_counter THEN

				IF l_task_src_type_tbl(i) ='SR' AND CSM_SR_EVENT_PKG.IS_SR_OPEN(l_task_id) = FALSE THEN
   				   --Delete the taskonly if the SR is closed
          		    csm_task_event_pkg.task_del_init(p_task_id=>l_task_id);

				ELSIF l_task_src_type_tbl(i) ='TASK' THEN
					--Delete simply,as there are no SR attached for a personal task
					csm_task_event_pkg.task_del_init(p_task_id=>l_task_id);

				END IF;

		END IF; -- if counter > 1

      END LOOP;
    END IF;

    -- commit after every 50 records
    COMMIT;

  END LOOP;
  CLOSE l_purge_tasks_csr;

   -- update last_run_date
  UPDATE jtm_con_request_data
  SET 	 last_run_date  = l_last_run_date
  WHERE  product_code 	= 'CSM'
  AND 	 package_name 	= 'CSM_TASK_EVENT_PKG'
  AND 	 procedure_name = 'PURGE_TASKS_CONC';


  COMMIT;

  p_status := 'SUCCESS';
  p_message :=  'CSM_TASK_EVENT_PKG.PURGE_TASKS_CONC Executed successfully';

EXCEPTION
  WHEN OTHERS THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
      ROLLBACK;
      l_error_msg := ' Exception in  PURGE_TASKS_CONC for task_id:' || to_char(l_task_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
      p_status := 'ERROR';
      p_message := 'Error in CSM_TASK_EVENT_PKG.PURGE_TASKS_CONC: ' || l_error_msg;
      CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_EVENT_PKG.PURGE_TASKS_CONC',FND_LOG.LEVEL_EVENT);
END PURGE_TASKS_CONC;

/**
** Conc program called every midnight to purge tasks created_by mobile user, depending on the
** history profile of the user
**/
PROCEDURE CHECK_ESCALATION_TASKS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

CURSOR c_check_esc_tasks (b_last_run_date DATE)
IS
SELECT acc.TASK_ID
FROM jtf_task_references_b ref, CSM_TASKS_ACC acc, JTF_TASKS_B esc
WHERE ref.OBJECT_ID = acc.TASK_ID
AND ref.object_type_code = 'TASK'
AND ref.reference_code = 'ESC'
AND ref.task_id = esc.task_id
AND esc.source_object_type_code = 'ESC'
AND ref.LAST_UPDATE_DATE >= b_last_run_date;

CURSOR l_upd_last_run_date_csr
IS
SELECT last_run_date
FROM jtm_con_request_data
WHERE product_code = 'CSM'
AND package_name = 'CSM_TASK_EVENT_PKG'
AND procedure_name = 'CHECK_ESCALATION_TASKS_CONC'
FOR UPDATE OF last_run_date NOWAIT;

l_upd_last_run_date DATE;
l_last_run_date  DATE;
l_task_id  JTF_TASKS_B.TASK_ID%TYPE;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
  l_last_run_date := SYSDATE;

  OPEN l_upd_last_run_date_csr;
  FETCH l_upd_last_run_date_csr INTO l_upd_last_run_date;
  IF l_upd_last_run_date_csr%FOUND THEN
    -- for all the users check for cancelled tasks and history days
    FOR l_check_esc_task_rec IN c_check_esc_tasks(l_upd_last_run_date) LOOP

     l_task_id := l_check_esc_task_rec.task_id;
     -- CSM_UTIL_PKG.pvt_log('Task ' || l_task_id || ' is escalated' );
      CSM_UTIL_PKG.log('Task ID ' ||  l_task_id || ' is escalated ' ,
                    'CSM_TASK_EVENT_PKG.CHECK_ESCALATION_TASKS_CONC',
                    FND_LOG.LEVEL_STATEMENT);

      csm_task_event_pkg.TASK_MAKE_DIRTY_U_FOREACHUSER(p_task_id=>l_task_id,
                                                       p_error_msg=>l_error_msg,
                                                       x_return_status=>l_return_status);
    END LOOP;

   -- update last_run_date
     UPDATE jtm_con_request_data
     SET last_run_date = l_last_run_date
     WHERE CURRENT OF l_upd_last_run_date_csr;
  END IF;
  CLOSE l_upd_last_run_date_csr;

  COMMIT;

  p_status := 'SUCCESS';
  p_message := 'CSM_TASK_EVENT_PKG.CHECK_ESCALATION_TASKS_CONC Executed successfully';

EXCEPTION
  WHEN OTHERS THEN
      l_sqlerrno := to_char(SQLCODE);
      l_sqlerrmsg := substr(SQLERRM, 1,2000);
      l_error_msg := ' Exception in  CHECK_ESCALATION_TASKS_CONC for task_id:' || to_char(l_task_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
      p_status := 'ERROR';
      p_message := 'Error in CSM_TASK_EVENT_PKG.CHECK_ESCALATION_TASKS_CONC: ' || l_error_msg;
      CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_EVENT_PKG.CHECK_ESCALATION_TASKS_CONC',FND_LOG.LEVEL_EXCEPTION);
      ROLLBACK;
END CHECK_ESCALATION_TASKS_CONC;

PROCEDURE TASK_MAKE_DIRTY_U_FOREACHUSER(p_task_id IN NUMBER,
                           p_error_msg     OUT NOCOPY    VARCHAR2,
                           x_return_status IN OUT NOCOPY VARCHAR2)
IS
l_err_msg VARCHAR2(4000);
l_user_id NUMBER;
l_markdirty	BOOLEAN;
l_dmllist asg_download.dml_list;
l_dml varchar2(1);
l_timestamp DATE;
l_accesslist asg_download.access_list;
l_resourcelist asg_download.user_list;
l_publicationitemname VARCHAR2(50);
l_access_count NUMBER;
l_task_id jtf_tasks_b.task_id%TYPE;
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_upd_task_foreachuser_csr (p_task_id jtf_tasks_b.task_id%TYPE)
IS
SELECT acc.user_id, acc.access_id
FROM csm_tasks_acc acc
WHERE acc.task_id = p_task_id;

CURSOR l_del_task_foreachuser_csr(p_task_id jtf_tasks_b.task_id%TYPE)
IS
SELECT acc.user_id, jta.task_assignment_id
FROM jtf_tasks_b jt,
     csm_tasks_acc acc,
     jtf_task_statuses_b jts,
     jtf_task_assignments jta
WHERE acc.task_id = p_task_id
AND jt.task_id = acc.task_id
AND jta.task_id = acc.task_id
AND jts.task_status_id = jt.task_status_id
AND ((CSM_UTIL_PKG.GetLocalTime(jt.scheduled_start_date, acc.user_id) <
               (SYSDATE - NVL(csm_profile_pkg.get_task_history_days(asg_base.get_user_id),100))
      )
      AND
     (jts.cancelled_flag = 'Y' OR jts.closed_flag = 'Y' OR jts.completed_flag = 'Y' OR jts.rejected_flag = 'Y')
    );

CURSOR l_next_seq_value
IS
SELECT CSM_ACTIVITY_SEQ.nextval FROM dual;

BEGIN
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      l_err_msg := 'Entering CSM_TASK_EVENT_PKG.TASK_MAKE_DIRTY_U_FOREACHUSER' || ' for task_id ' || to_char(p_task_id);
      CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_TASK_EVENT_PKG.TASK_MAKE_DIRTY_U_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

      --get the activity attributes
      l_task_id := p_task_id;

      --get dml
      l_dml  := 'U';

      --change the DML value to one of the ASG constants for compatability
      --purposes (in case ASG internally changes these values in future)
      l_dml := CSM_UTIL_PKG.GetAsgDmlConstant(l_dml);

      l_publicationitemname := 'CSM_TASKS';

      --get the current date to be passed to make dirty api
      l_timestamp := SYSDATE;

      l_access_count := 0;
      IF l_accesslist.COUNT > 0 THEN
          l_accesslist.DELETE;
          l_resourcelist.DELETE;
          l_dmllist.DELETE;
      END IF;

     for l_upd_task_foreachuser_rec in l_upd_task_foreachuser_csr(l_task_id) loop
    	     l_access_count := l_access_count + 1;
		     l_accesslist(l_access_count) := l_upd_task_foreachuser_rec.access_id;
		     l_resourcelist(l_access_count) := l_upd_task_foreachuser_rec.user_id;
		     l_dmllist(l_access_count) :=  l_dml;
     end loop;

      if l_accesslist.count > 0 then
  		    l_markdirty := csm_util_pkg.MakeDirtyForUser (l_publicationitemname,
                                                          l_accesslist,
                   									      l_resourcelist,
     												      l_dmllist,
   												          l_timestamp);

      		if not l_markdirty then
	         		RAISE l_markdirty_failed;
  		    end if;
      END IF;

      -- get all tasks to be deleted for the user if the scheduled_start_dates have been updated
      FOR l_del_task_foreachuser_rec IN l_del_task_foreachuser_csr(l_task_id) LOOP

        csm_task_assignment_event_pkg.TASK_ASSIGNMENT_PURGE_INIT
                                    (p_task_assignment_id=>l_del_task_foreachuser_rec.task_assignment_id,
                                     p_error_msg=>l_error_msg,
                                     x_return_status=>l_return_status);
      END LOOP;

      l_err_msg := 'Leaving CSM_TASK_EVENT_PKG.TASK_MAKE_DIRTY_U_FOREACHUSER' || ' for task_id ' || to_char(p_task_id);
      CSM_UTIL_PKG.LOG( l_err_msg, 'CSM_TASK_EVENT_PKG.TASK_MAKE_DIRTY_U_FOREACHUSER', FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
      WHEN l_markdirty_failed THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
	     p_error_msg := ' FAILED TASK_MAKE_DIRTY_U_FOREACHUSER:' || to_char(l_task_id);
         CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_TASK_EVENT_PKG.TASK_MAKE_DIRTY_U_FOREACHUSER', FND_LOG.LEVEL_ERROR);
    	RAISE;

  	WHEN others THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         p_error_msg := ' FAILED TASK_MAKE_DIRTY_U_FOREACHUSER:' || to_char(l_task_id);
         CSM_UTIL_PKG.LOG( p_error_msg, 'CSM_TASK_EVENT_PKG.TASK_MAKE_DIRTY_U_FOREACHUSER', FND_LOG.LEVEL_ERROR);
         RAISE;
END TASK_MAKE_DIRTY_U_FOREACHUSER;

PROCEDURE TASK_INS_INIT(p_task_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_task_csr (b_task_id NUMBER) IS
SELECT jt.CREATED_BY, jtt.private_flag, jt.source_object_type_code  -- 22 means Escalation task
FROM JTF_TASKS_B jt,
     jtf_task_types_b jtt
WHERE jt.TASK_ID = b_task_id
AND jtt.task_type_id = jt.task_type_id;

l_task_rec l_task_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering TASK_INS_INIT for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.TASK_INS_INIT',FND_LOG.LEVEL_PROCEDURE);

   OPEN l_task_csr(p_task_id);
   FETCH l_task_csr INTO l_task_rec;
   IF l_task_csr%NOTFOUND THEN
     CLOSE l_task_csr;
     RETURN;
   END IF;
   CLOSE l_task_csr;

   -- check if task is created by a mobile user
   IF CSM_UTIL_PKG.IS_PALM_USER(l_task_rec.CREATED_BY)
         AND ( l_task_rec.SOURCE_OBJECT_TYPE_CODE IN ('SR', 'TASK') OR l_task_rec.private_flag = 'Y') THEN

        -- get task notes
        csm_notes_event_pkg.notes_make_dirty_i_grp(p_sourceobjectcode=>'TASK',
                                              p_sourceobjectid=>p_task_id,
                                              p_userid=>l_task_rec.CREATED_BY,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);

        -- insert into csm_tasks_acc
        csm_task_event_pkg.acc_insert(p_task_id=>p_task_id,
                                      p_user_id=>l_task_rec.CREATED_BY);
   END IF;

   CSM_UTIL_PKG.LOG('Leaving TASK_INS_INIT for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.TASK_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  TASK_INS_INIT for task_id:'
                       || to_char(p_task_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_EVENT_PKG.TASK_INS_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_INS_INIT;

PROCEDURE TASK_DEL_INIT(p_task_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

CURSOR l_task_csr (b_task_id NUMBER) IS
SELECT jt.CREATED_BY
FROM JTF_TASKS_B jt
WHERE jt.TASK_ID = b_task_id
AND EXISTS
(SELECT 1
 FROM csm_tasks_acc acc
 WHERE acc.user_id = jt.created_by
 AND acc.task_id = jt.task_id);

l_task_rec l_task_csr%ROWTYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering TASK_DEL_INIT for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.TASK_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);

   OPEN l_task_csr(p_task_id);
   FETCH l_task_csr INTO l_task_rec;
   IF l_task_csr%NOTFOUND THEN
     CLOSE l_task_csr;
     RETURN;
   END IF;
   CLOSE l_task_csr;

   -- delete task notes
   csm_notes_event_pkg.notes_make_dirty_d_grp(p_sourceobjectcode=>'TASK',
                                              p_sourceobjectid=>p_task_id,
                                              p_userid=>l_task_rec.CREATED_BY,
                                              p_error_msg=>l_error_msg,
                                              x_return_status=>l_return_status);

   -- delete from csm_tasks_acc
   csm_task_event_pkg.acc_delete(p_task_id=>p_task_id,
                                 p_user_id=>l_task_rec.CREATED_BY);

   CSM_UTIL_PKG.LOG('Leaving TASK_DEL_INIT for task_id: ' || p_task_id,
                                   'CSM_TASK_EVENT_PKG.TASK_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  TASK_DEL_INIT for task_id:'
                       || to_char(p_task_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_TASK_EVENT_PKG.TASK_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END TASK_DEL_INIT;

END CSM_TASK_EVENT_PKG;

/
