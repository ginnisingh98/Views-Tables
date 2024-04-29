--------------------------------------------------------
--  DDL for Package Body CSM_NOTIFICATION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_NOTIFICATION_EVENT_PKG" AS
/* $Header: csmentfb.pls 120.8.12010000.14 2010/03/11 07:16:47 saradhak ship $ */

-- To modify this template, edit file PKGBODY.TXT in TEMPLATE
-- directory of SQL Navigator
--
-- Purpose: Briefly explain the functionality of the package body
--
-- MODIFICATION HISTORY
-- Person      Date    Comments
-- ---------   ------  ------------------------------------------
-- Enter procedure, function bodies as shown below
g_notification_acc_table_name        CONSTANT VARCHAR2(30) := 'CSM_NOTIFICATIONS_ACC';
g_notification_table_name            CONSTANT VARCHAR2(30) := 'WF_NOTIFICATIONS';
g_notification_seq_name              CONSTANT VARCHAR2(30) := 'CSM_NOTIFICATIONS_ACC_S';
g_notification_pk1_name              CONSTANT VARCHAR2(30) := 'NOTIFICATION_ID';
g_notification_pubi_name             CONSTANT CSM_ACC_PKG.t_publication_item_list :=
  CSM_ACC_PKG.t_publication_item_list('CSF_M_MAIL_MESSAGES', 'CSF_M_MAIL_RECIPIENTS');
g_switch_optimize_off BOOLEAN:=TRUE;
g_ItemType	Varchar2(10) := 'CSM_MSGS';

FUNCTION check_if_notification_exists(p_notification_id IN number, p_user_id IN number)
RETURN boolean
IS
l_dummy number;

CURSOR l_csm_notifications_csr(b_notificationid IN number, p_userid IN number)
IS
SELECT 1
FROM csm_notifications_acc
WHERE notification_id = b_notificationid
AND user_id = p_userid;

BEGIN
  OPEN l_csm_notifications_csr(p_notification_id, p_user_id);
  FETCH l_csm_notifications_csr INTO l_dummy;
  IF l_csm_notifications_csr%FOUND THEN
     CLOSE l_csm_notifications_csr;
     RETURN TRUE;
  ELSE
     CLOSE l_csm_notifications_csr;
     RETURN FALSE;
  END IF;

END check_if_notification_exists;

--Bug 5337816
PROCEDURE INSERT_NOTIFICATIONS_ACC (p_notification_id wf_notifications.notification_id%TYPE,
                                    p_user_id	fnd_user.user_id%TYPE)
IS
  l_sysdate 	DATE;
  l_count NUMBER;
BEGIN
    CSM_ACC_PKG.Insert_Acc
    ( P_PUBLICATION_ITEM_NAMES => g_notification_pubi_name
     ,P_ACC_TABLE_NAME         => g_notification_acc_table_name
     ,P_SEQ_NAME               => g_notification_seq_name
     ,P_PK1_NAME               => g_notification_pk1_name
     ,P_PK1_NUM_VALUE          => p_notification_id
     ,P_USER_ID                => p_user_id
    );
EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.LOG( 'Exception occurred in CSM_NOTIFICATION_EVENT_PKG.INSERT_NOTIFICATIONS_ACC: '
      || sqlerrm|| ' for PK ' || to_char(p_notification_id),
      'CSM_NOTIFICATION_EVENT_PKG.INSERT_NOTIFICATIONS_ACC',FND_LOG.LEVEL_EXCEPTION);
  RAISE;
END INSERT_NOTIFICATIONS_ACC;-- end INSERT_NOTIFICATIONS_ACC

--Bug 5337816
PROCEDURE NOTIFICATIONS_ACC_PROCESSOR(p_user_id IN NUMBER)
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

-- get all notifications in which user is a recipient
CURSOR c_notf(b_user_id fnd_user.user_id%TYPE) IS
 SELECT DISTINCT wfn.notification_id
 FROM   wf_notifications wfn,
        asg_user au
 WHERE  au.user_id=b_user_id
 AND    au.user_name IN (FROM_ROLE,RECIPIENT_ROLE)
 AND    (nvl(wfn.begin_date, sysdate) between
	               (sysdate - csm_profile_pkg.get_task_history_days(b_user_id))and sysdate)
 AND  NOT EXISTS(SELECT 1
                 FROM CSM_NOTIFICATIONS_ACC ACC
				 WHERE ACC.NOTIFICATION_ID = WFN.NOTIFICATION_ID
				 AND   ACC.USER_ID = AU.USER_ID);

--12.1
CURSOR c_broadcast_notf(b_user_id fnd_user.user_id%TYPE) IS
 SELECT DISTINCT wfn.notification_id
 FROM  WF_NOTIFICATIONS wfn,
       ASG_USER au
 WHERE au.user_id=b_user_id
 AND   RECIPIENT_ROLE LIKE 'JRES_GRP:%'
 AND   au.user_id =CSM_UTIL_PKG.get_group_owner(substr(WFN.RECIPIENT_ROLE,instr(WFN.RECIPIENT_ROLE,':')+1))
 AND   au.enabled='Y'
 AND  (nvl(wfn.begin_date, sysdate) between
	              (sysdate - csm_profile_pkg.get_task_history_days(b_user_id))and sysdate)
 AND  NOT EXISTS(SELECT 1
                 FROM CSM_NOTIFICATIONS_ACC ACC
				 WHERE ACC.NOTIFICATION_ID = WFN.NOTIFICATION_ID
				 AND   ACC.USER_ID = AU.USER_ID);

BEGIN
   CSM_UTIL_PKG.LOG('Entering NOTIFICATIONS_ACC_PROCESSOR for user_id: ' || p_user_id,
                                   'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATIONS_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);


  -- get all notifications in which user is a recipient
  FOR l_notf_rec IN c_notf(p_user_id)
  LOOP
   INSERT_NOTIFICATIONS_ACC (l_notf_rec.notification_id, p_user_id);
  END LOOP;

--12.1
  FOR l_notf_rec IN c_broadcast_notf(p_user_id)
  LOOP
   INSERT_NOTIFICATIONS_ACC (l_notf_rec.notification_id, p_user_id);
  END LOOP;

    CSM_UTIL_PKG.LOG('Leaving NOTIFICATIONS_ACC_PROCESSOR for user_id: ' || p_user_id,
                                   'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATIONS_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  NOTIFICATIONS_ACC_PROCESSOR for for user_id: ' || p_user_id
                       || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATIONS_ACC_PROCESSOR',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END NOTIFICATIONS_ACC_PROCESSOR;

--Bug 5337816
PROCEDURE DOWNLOAD_NOTIFICATION(p_notification_id IN NUMBER ,x_return_status OUT NOCOPY VARCHAR2)
IS
CURSOR c_users(b_nid NUMBER)  IS
 SELECT DISTINCT au.user_id
 FROM  WF_NOTIFICATIONS wfn,
       ASG_USER au
 WHERE wfn.NOTIFICATION_ID=b_nid
 AND   au.user_name IN (WFN.FROM_ROLE,WFN.RECIPIENT_ROLE)
 AND   au.enabled='Y'
 AND  (nvl(wfn.begin_date, sysdate) between
	              (sysdate - csm_profile_pkg.get_task_history_days(au.user_id))and sysdate)
 AND  NOT EXISTS(SELECT 1
                 FROM CSM_NOTIFICATIONS_ACC ACC
				 WHERE ACC.NOTIFICATION_ID = WFN.NOTIFICATION_ID
				 AND   ACC.USER_ID = AU.USER_ID);

--12.1
CURSOR c_broadcast_users(b_nid NUMBER) IS
 SELECT DISTINCT au.user_id
 FROM  WF_NOTIFICATIONS wfn,
       ASG_USER au
 WHERE wfn.NOTIFICATION_ID=b_nid
 AND   RECIPIENT_ROLE LIKE 'JRES_GRP:%'
 AND   au.user_id =CSM_UTIL_PKG.get_group_owner(substr(WFN.RECIPIENT_ROLE,instr(WFN.RECIPIENT_ROLE,':')+1))
 AND   au.enabled='Y'
 AND  (nvl(wfn.begin_date, sysdate) between
	              (sysdate - csm_profile_pkg.get_task_history_days(au.user_id))and sysdate)
 AND  NOT EXISTS(SELECT 1
                 FROM CSM_NOTIFICATIONS_ACC ACC
				 WHERE ACC.NOTIFICATION_ID = WFN.NOTIFICATION_ID
				 AND   ACC.USER_ID = AU.USER_ID);

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
BEGIN

  CSM_UTIL_PKG.LOG('Entering DOWNLOAD_NOTIFICATION for notification_id: ' || p_notification_id,
                                   'CSM_NOTIFICATION_EVENT_PKG.DOWNLOAD_NOTIFICATION',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
       x_return_status :='SUCCESS';
       RETURN;
   END IF;

  FOR r_rec IN c_users(p_notification_id)
  LOOP
    INSERT_NOTIFICATIONS_ACC (p_notification_id, r_rec.user_id);
  END LOOP;

--12.1
  FOR r_rec IN c_broadcast_users(p_notification_id)
  LOOP
    INSERT_NOTIFICATIONS_ACC (p_notification_id, r_rec.user_id);
  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving DOWNLOAD_NOTIFICATION for notification_id: ' || p_notification_id,
                                  'CSM_NOTIFICATION_EVENT_PKG.DOWNLOAD_NOTIFICATION',FND_LOG.LEVEL_PROCEDURE);
  x_return_status :='SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  DOWNLOAD_NOTIFICATION for notification_id:' || to_char(p_notification_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_NOTIFICATION_EVENT_PKG.DOWNLOAD_NOTIFICATION',FND_LOG.LEVEL_EXCEPTION);
        x_return_status :='ERROR';
END DOWNLOAD_NOTIFICATION;


--Bug 5337816
-- subscription to the NOTIFICATION_ATTR_INS_RECEIVE WF event
FUNCTION NOTIFICATION_ATTR_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(80);

l_notification_id wf_notifications.notification_id%TYPE;

BEGIN
   CSM_UTIL_PKG.LOG('Entering NOTIFICATION_ATTR_WF_EVENT_SUB',
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_ATTR_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
      RETURN 'SUCCESS';
   END IF;

   l_notification_id := p_event.GetValueForParameter('NOTIFICATION_ID');

   DOWNLOAD_NOTIFICATION(l_notification_id,l_return_status);

   CSM_UTIL_PKG.LOG('Leaving NOTIFICATION_ATTR_WF_EVENT_SUB for notification_id: ' || TO_CHAR(l_notification_id),
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_ATTR_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   RETURN l_return_status;
EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  NOTIFICATION_ATTR_WF_EVENT_SUB for notification_id:' || to_char(l_notification_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_ATTR_WF_EVENT_SUB',FND_LOG.LEVEL_EXCEPTION);
        RETURN 'ERROR';
END NOTIFICATION_ATTR_WF_EVENT_SUB;

--Bug 5337816
FUNCTION NOTIFICATION_DEL_WF_EVENT_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_notification_id wf_notifications.notification_id%TYPE;

-- get sender/recipient for this notification
CURSOR c_users(b_nid NUMBER)  IS
 SELECT  acc.user_id
 FROM   CSM_NOTIFICATIONS_ACC acc
 WHERE  acc.NOTIFICATION_ID=b_nid;


BEGIN
   CSM_UTIL_PKG.LOG('Entering NOTIFICATION_DEL_WF_EVENT_SUB',
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_DEL_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   IF NOT CSM_UTIL_PKG.IS_FIELD_SERVICE_PALM_ENABLED THEN
      RETURN 'SUCCESS';
   END IF;

   l_notification_id := p_event.GetValueForParameter('NOTIFICATION_ID');

   FOR r_notification_rec IN c_users(l_notification_id) LOOP
        CSM_ACC_PKG.Delete_Acc
        ( P_PUBLICATION_ITEM_NAMES => g_notification_pubi_name
         ,P_ACC_TABLE_NAME         => g_notification_acc_table_name
         ,P_PK1_NAME               => g_notification_pk1_name
         ,P_PK1_NUM_VALUE          => l_notification_id
         ,P_USER_ID                => r_notification_rec.user_id
        );
   END LOOP;

   CSM_UTIL_PKG.LOG('Leaving NOTIFICATION_DEL_WF_EVENT_SUB for notification_id: ' || TO_CHAR(l_notification_id),
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_DEL_WF_EVENT_SUB',FND_LOG.LEVEL_PROCEDURE);

   RETURN 'SUCCESS';
EXCEPTION
 WHEN OTHERS THEN
        l_sqlerrno := TO_CHAR(SQLCODE);
        l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  NOTIFICATION_DEL_WF_EVENT_SUB for notification_id:' || to_char(l_notification_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_DEL_WF_EVENT_SUB',FND_LOG.LEVEL_EXCEPTION);
        RETURN 'ERROR';
END NOTIFICATION_DEL_WF_EVENT_SUB;

PROCEDURE PURGE_NOTIFICATION_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_last_run_date DATE;

CURSOR l_purge_notifications_csr
IS
SELECT /*+ INDEX(acc CSM_NOTIFICATIONS_ACC_U1) */
      acc.user_id,
      acc.notification_id
FROM csm_notifications_acc acc,
     wf_notifications wfn
WHERE acc.notification_id = wfn.notification_id
AND (NVL(wfn.begin_date, SYSDATE)
      < (SYSDATE - csm_profile_pkg.get_task_history_days(acc.user_id)));

TYPE l_purge_notf_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_purge_notf_tbl l_purge_notf_tbl_type;
TYPE l_purge_userid_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_purge_userid_tbl l_purge_userid_tbl_type;
l_notification_id NUMBER;
l_user_id NUMBER;
l_dummy NUMBER;

CURSOR l_upd_last_run_date_csr
IS
SELECT 1
FROM jtm_con_request_data
WHERE product_code = 'CSM'
AND package_name = 'CSM_NOTIFICATION_EVENT_PKG'
AND procedure_name = 'PURGE_NOTIFICATION_CONC'
FOR UPDATE OF last_run_date NOWAIT
;

CURSOR c_purge_days IS
select profile_option_value from fnd_profile_option_values where profile_option_id in
(select profile_option_id from fnd_profile_options where profile_option_name='CSM_PURGE_INTERVAL')
and level_id=10001;

l_days NUMBER;

BEGIN
  l_last_run_date := SYSDATE;

  OPEN l_purge_notifications_csr;
  LOOP
    IF l_purge_notf_tbl.COUNT > 0 THEN
       l_purge_notf_tbl.DELETE;
    END IF;

    IF l_purge_userid_tbl.COUNT > 0 THEN
       l_purge_userid_tbl.DELETE;
    END IF;

  FETCH l_purge_notifications_csr BULK COLLECT INTO l_purge_userid_tbl, l_purge_notf_tbl LIMIT 50;
  EXIT WHEN l_purge_notf_tbl.COUNT = 0;

  IF l_purge_notf_tbl.COUNT > 0 THEN
    CSM_UTIL_PKG.LOG(TO_CHAR(l_purge_notf_tbl.COUNT) || ' records sent for purge', 'CSM_NOTIFICATION_EVENT_PKG.PURGE_NOTIFICATION_CONC',FND_LOG.LEVEL_EVENT);
    FOR i IN l_purge_notf_tbl.FIRST..l_purge_notf_tbl.LAST LOOP
      l_notification_id := l_purge_notf_tbl(i);
      l_user_id := l_purge_userid_tbl(i);

      CSM_ACC_PKG.Delete_Acc
       ( P_PUBLICATION_ITEM_NAMES => g_notification_pubi_name
        ,P_ACC_TABLE_NAME         => g_notification_acc_table_name
        ,P_PK1_NAME               => g_notification_pk1_name
        ,P_PK1_NUM_VALUE          => l_notification_id
        ,P_USER_ID                => l_user_id
       );
    END LOOP;
  END IF;
  -- commit after every 50 records
  COMMIT;
  END LOOP;
  CLOSE l_purge_notifications_csr;

/*12.1.2 PURGE INACTIVE CSM WF ROLES*/
  DELETE FROM WF_LOCAL_ROLES B WHERE NAME LIKE 'CSM%ROLE'
  AND NOT EXISTS( SELECT 1 FROM FND_USER U
                  WHERE USER_NAME=substr(B.NAME,5,length(B.NAME)-9)
				  AND sysdate between nvl(start_date,sysdate-1) and nvl(end_date,sysdate+1));


/*12.1.2 PURGE AUTO SYNC Notifications
  Step-1 : Purge all CSM_AUTO_SYNC_NFN/CLIENT notifications that are created earlier than
           purge interval
  Step-2 : Close unresponded notifications that are older than purge interval
           These records will get purged from WF Notifications table
		   after another purge interval has elapsed
  Step-3 : Purge all WF notifications that are responded/closed
		   with end_date earlier than purge interval
*/
  OPEN c_purge_days;
  FETCH c_purge_days INTO l_days;
  IF c_purge_days%FOUND AND l_days IS NOT NULL AND l_days>0 THEN

    --STEP-1

    FOR nfn_rec IN (SELECT NOTIFICATION_ID,USER_ID FROM csm_auto_sync_nfn
                    WHERE CREATION_DATE < SYSDATE-l_days)
    LOOP
      CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_AUTO_SYNC_NFN')
          ,P_ACC_TABLE_NAME         => 'CSM_AUTO_SYNC_NFN_ACC'
          ,P_PK1_NAME               => 'NOTIFICATION_ID'
          ,P_PK1_NUM_VALUE          => nfn_rec.NOTIFICATION_ID
          ,P_USER_ID                => nfn_rec.USER_ID
          );
    END LOOP;

    DELETE FROM csm_auto_sync_nfn WHERE CREATION_DATE < SYSDATE-l_days;

    FOR nfn_rec IN (SELECT NOTIFICATION_ID,USER_ID FROM csm_client_nfn_log_acc acc
                    WHERE NOT EXISTS (SELECT 1 FROM csm_auto_sync_nfn b
					                  WHERE b.NOTIFICATION_ID=acc.NOTIFICATION_ID))
    LOOP
      CSM_ACC_PKG.Delete_Acc
          ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_CLIENT_NFN_LOG')
          ,P_ACC_TABLE_NAME         => 'CSM_CLIENT_NFN_LOG_ACC'
          ,P_PK1_NAME               => 'NOTIFICATION_ID'
          ,P_PK1_NUM_VALUE          => nfn_rec.NOTIFICATION_ID
          ,P_USER_ID                => nfn_rec.USER_ID
          );
    END LOOP;

    DELETE FROM csm_client_nfn_log cl
	  WHERE NOT EXISTS (SELECT 1 FROM csm_auto_sync_nfn b WHERE b.NOTIFICATION_ID=cl.NOTIFICATION_ID);

	COMMIT;

   --STEP-2
    FOR ntf_rec IN (SELECT NOTIFICATION_ID FROM WF_NOTIFICATIONS
                    WHERE MESSAGE_TYPE='CSM_MSGS'
                    AND (STATUS='OPEN' OR END_DATE IS NULL)
		  		    AND BEGIN_DATE < SYSDATE-l_days)
    LOOP
      wf_notification.respond(ntf_rec.NOTIFICATION_ID);
    END LOOP;


   --STEP-3
    wf_purge.Notifications('CSM_MSGS',sysdate-l_days-1);
  END IF;
  CLOSE c_purge_days;


  -- update last_run_date
  OPEN l_upd_last_run_date_csr;
  FETCH l_upd_last_run_date_csr INTO l_dummy;
  IF l_upd_last_run_date_csr%FOUND THEN
     UPDATE jtm_con_request_data
     SET last_run_date = l_last_run_date
     WHERE CURRENT OF l_upd_last_run_date_csr;
  END IF;
  CLOSE l_upd_last_run_date_csr;
  COMMIT;

  p_status := 'SUCCESS';
  p_message :=  'CSM_NOTIFICATION_EVENT_PKG.PURGE_NOTIFICATION_CONC Executed successfully';

EXCEPTION
  WHEN OTHERS THEN
      l_sqlerrno := TO_CHAR(SQLCODE);
      l_sqlerrmsg := SUBSTR(SQLERRM, 1,2000);
      ROLLBACK;
      l_error_msg := ' Exception in  PURGE_NOTIFICATION_CONC for notification:' || to_char(l_notification_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
      CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_NOTIFICATION_EVENT_PKG.PURGE_NOTIFICATION_CONC',FND_LOG.LEVEL_EVENT);
      p_status := 'ERROR';
      p_message := 'Error in CSM_NOTIFICATION_EVENT_PKG.PURGE_NOTIFICATION_CONC: ' || l_error_msg;
END PURGE_NOTIFICATION_CONC;

--Bug 9435049
FUNCTION get_Mailer_EmailId return VARCHAR2
IS
l_email_id VARCHAR2(500):=NULL;
l_status VARCHAR2(200);
l_dummy NUMBER;
l_comp_name VARCHAR2(1000);

CURSOR c_mailer_email IS
 select a.component_name,parameter_value,component_status,
 decode(component_status, 'RUNNING',0,'STARTING',1,'DEACTIVATED_SYSTEM',2,'STOPPED_ERROR',2)  status
 from fnd_svc_components a, FND_SVC_COMP_PARAM_VALS_V b
 where component_type='WF_MAILER'
 and a.component_id=b.component_id
 and b.parameter_name='REPLYTO'
 and b.parameter_value IS NOT NULL
 order by status;

CURSOR c_seeded_mailer IS
  select parameter_value
  from FND_SVC_COMP_PARAM_VALS_V
  where component_id=10006
  and parameter_name='REPLYTO';

BEGIN

OPEN c_mailer_email;
FETCH c_mailer_email  INTO l_comp_name,l_email_id,l_status,l_dummy;
CLOSE c_mailer_email;

CSM_UTIL_PKG.LOG('Mailer by name: '||l_comp_name || ' ,with email id: '||l_email_id ||' and status: '
                  || l_status, 'CSM_NOTIFICATION_EVENT_PKG.get_Mailer_EmailId',FND_LOG.LEVEL_PROCEDURE);

IF l_email_id IS NULL OR l_email_id ='' THEN
 OPEN c_seeded_mailer;
 FETCH c_seeded_mailer INTO l_email_id;
 CLOSE c_seeded_mailer;

CSM_UTIL_PKG.LOG('Email Id of running mailer is null so trying with seeded Mailer''s email address ='||l_email_id,
                  'CSM_NOTIFICATION_EVENT_PKG.get_Mailer_EmailId',FND_LOG.LEVEL_PROCEDURE);

END IF;

RETURN l_email_id;

END get_Mailer_EmailId;

--Bug 9435049
FUNCTION invoke_WF_NotifyProcess (p_recipient_role IN VARCHAR2, p_wf_param IN wf_event_t) return NUMBER
IS

l_item_key      WF_ITEMS.ITEM_KEY%TYPE;
l_item_owner        WF_USERS.NAME%TYPE := 'SYSADMIN';
l_processName  VARCHAR2(200);
l_template        Varchar2(100);
l_subject VARCHAR2(200);
l_body VARCHAR2(4000);
l_tran_id NUMBER;
l_seq NUMBER;
l_client_id VARCHAR2(100);
l_dev_type VARCHAR2(100);
l_disp_name VARCHAR2(500);
l_pub_name VARCHAR2(100);
l_pk_name VARCHAR2(100);
l_pk_value VARCHAR2(100);
l_err_msg VARCHAR2(2000);
l_tran_date VARCHAR2(100);
l_session_id NUMBER;
l_dev_name VARCHAR2(240);
l_sync_date VARCHAR2(100);

l_nid NUMBER;
l_status VARCHAR2(200);
l_result VARCHAR2(2000);
BEGIN

  l_template := p_wf_param.getValueForParameter('TEMPLATE');   --wf_msg_name

  l_item_key := l_template||'<->'||to_char(systimestamp)||'<->'||p_recipient_role;

  CSM_UTIL_PKG.LOG('Creating WF Process for recipient :'||p_recipient_role||' with item key:'||l_item_key,
                 'CSM_NOTIFICATION_EVENT_PKG.invoke_WF_NotifyProcess',FND_LOG.LEVEL_PROCEDURE);

  IF l_template <> 'DOWNLOAD_INIT_MSG' THEN
   l_processName := 'CSM_NFN_PROCESS';
  ELSE
   l_processName := 'CSM_AS_NFN_PROCESS';
  END IF;

        wf_engine.CreateProcess(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           process   => l_processName);

        wf_engine.SetItemUserKey(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           userkey   => l_item_key);

        wf_engine.SetItemOwner(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           owner     => l_item_owner);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'MESSAGE',
           avalue    =>  l_template);

      if l_template = 'DOWNLOAD_INIT_MSG'
	  then

	    l_subject := p_wf_param.getValueForParameter('SUBJECT');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'SUBJECT',
           avalue    => l_subject);

	    l_body := p_wf_param.getValueForParameter('MESSAGE_BODY');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'MESSAGE_BODY',
           avalue    => l_body);

	  elsif l_template = 'DEFERRED_ERROR_REPORT'
      then

	    l_client_id := p_wf_param.getValueForParameter('USER_NAME');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'USER_NAME',
           avalue    => l_client_id);

	    l_tran_id := to_number(p_wf_param.getValueForParameter('TRAN_ID'));
        wf_engine.SetItemAttrNumber(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'TRAN_ID',
           avalue    => l_tran_id);

	    l_seq := to_number(p_wf_param.getValueForParameter('SEQUENCE'));
        wf_engine.SetItemAttrNumber(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'SEQUENCE',
           avalue    => l_seq);

	    l_dev_type := p_wf_param.getValueForParameter('DEVICE_TYPE');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'DEVICE_TYPE',
           avalue    => l_dev_type);

	    l_disp_name := p_wf_param.getValueForParameter('EMP_NAME');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'EMP_NAME',
           avalue    => l_disp_name);

	    l_pub_name := p_wf_param.getValueForParameter('PUB_ITEM');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'PUB_ITEM',
           avalue    => l_pub_name);

	    l_pk_name := p_wf_param.getValueForParameter('PK_COLUMN');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'PK_COLUMN',
           avalue    => l_pk_name);

	    l_pk_value := p_wf_param.getValueForParameter('PK_VALUE');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'PK_VALUE',
           avalue    => l_pk_value);

	    l_err_msg := p_wf_param.getValueForParameter('ERR_MSG');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'ERR_MSG',
           avalue    => l_err_msg);

	    l_tran_date := p_wf_param.getValueForParameter('TRAN_DATE');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'TRAN_DATE',
           avalue    => l_tran_date);

	  elsif l_template = 'SYNC_ERROR_REPORT'
      then

	    l_session_id := to_number(p_wf_param.getValueForParameter('SESSION_ID'));
        wf_engine.SetItemAttrNumber(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'SESSION_ID',
           avalue    => l_session_id);

	    l_tran_id := to_number(p_wf_param.getValueForParameter('TRAN_ID'));
        wf_engine.SetItemAttrNumber(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'TRAN_ID',
           avalue    => l_tran_id);

 	    l_client_id := p_wf_param.getValueForParameter('USER_NAME');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'USER_NAME',
           avalue    => l_client_id);

	    l_dev_type := p_wf_param.getValueForParameter('DEVICE_TYPE');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'DEVICE_TYPE',
           avalue    => l_dev_type);

	    l_dev_name := p_wf_param.getValueForParameter('DEVICE_NAME');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'DEVICE_NAME',
           avalue    => l_dev_name);

	    l_err_msg := p_wf_param.getValueForParameter('ERROR_MSG');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'ERROR_MSG',
           avalue    => l_err_msg);

	    l_sync_date := p_wf_param.getValueForParameter('SYNC_DATE');
        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'SYNC_DATE',
           avalue    => l_sync_date);

      end if;

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'RECIPIENT',
           avalue    => upper(p_recipient_role));

        wf_engine.StartProcess(
           itemtype  => g_ItemType,
           itemkey   => l_item_key);


	  BEGIN
       SELECT NOTIFICATION_ID
	   INTO l_nid
	   FROM WF_NOTIFICATIONS
	   WHERE MESSAGE_TYPE='CSM_MSGS'
	   AND MESSAGE_NAME=l_template
	   AND RECIPIENT_ROLE=p_recipient_role
	   AND ITEM_KEY = l_item_key;
	  EXCEPTION
	  WHEN OTHERS THEN
	    wf_engine.itemStatus(g_ItemType,l_item_key,l_status,l_result);
        CSM_UTIL_PKG.LOG('Error in WF Process with item key:'||l_item_key ||' . Failed with status '||l_status
		                  ||' , and result: '||l_result,'CSM_NOTIFICATION_EVENT_PKG.invoke_WF_NotifyProcess',FND_LOG.LEVEL_PROCEDURE);
        return -1;
      END;

	return l_nid;
END invoke_WF_NotifyProcess;

FUNCTION createMobileWFUser(b_user_name IN VARCHAR2) RETURN BOOLEAN
IS
role_name VARCHAR2(30);
role_display_name VARCHAR2(1000);
l_fnd_email VARCHAR2(200);
l_wf_email VARCHAR2(200);
l_pref  VARCHAR2(200);
l_stmt  VARCHAR2(1000);
l_err_msg VARCHAR2(2000);
l_upd BOOLEAN:=false;
BEGIN
 BEGIN
  SELECT wf.name,wf.email_address,wf.notification_preference INTO role_name,l_wf_email ,l_pref
  FROM WF_LOCAL_ROLES wf, ASG_USER au
  WHERE wf.name ='CSM_'||b_user_name||'_ROLE'
  AND au.user_name=b_user_name
  AND au.enabled='Y';

  SELECT email_address INTO l_fnd_email
  FROM FND_USER WHERE USER_NAME=b_user_name
  AND sysdate between nvl(start_date,sysdate-1) and nvl(end_date,sysdate+1);

  IF(l_fnd_email is NULL) THEN
     CSM_UTIL_PKG.LOG('No FND Email found for user CSM_'||b_user_name||'_ROLE in createMobileWFUser',
                         'CSM_NOTIFICATION_EVENT_PKG.createMobileWFUser',FND_LOG.LEVEL_PROCEDURE);
	 RETURN FALSE;
  END IF;

  l_stmt:= 'UPDATE WF_LOCAL_ROLES SET DESCRIPTION=DESCRIPTION ';


  IF l_pref<> 'MAILTEXT' THEN
    l_stmt := l_stmt||' , notification_preference=''MAILTEXT''';
    l_upd:=TRUE;
  END IF;

  IF(l_wf_email IS NULL OR l_wf_email <> l_fnd_email) THEN
    l_stmt := l_stmt||' , EMAIL_ADDRESS='''||l_fnd_email||'''';
    l_upd:=TRUE;
  END IF;

  IF l_upd THEN
    l_stmt := l_stmt||' WHERE NAME=:1';
    EXECUTE IMMEDIATE l_stmt USING role_name;
  END IF;

 EXCEPTION
  WHEN no_data_found THEN
   SELECT 'CSM_'||fu.user_name||'_ROLE',wf.display_name,fu.email_address
   INTO role_name,role_display_name,l_fnd_email
   FROM FND_USER fu, Asg_user au ,wf_local_roles wf
   WHERE fu.user_name=b_user_name
   AND sysdate between nvl(fu.start_date,sysdate-1) and nvl(fu.end_date,sysdate+1)
   AND wf.name=fu.USER_NAME  AND au.USER_NAME=fu.USER_NAME  AND au.ENABLED='Y' ;

    IF(l_fnd_email is NULL) THEN
     CSM_UTIL_PKG.LOG('No FND Email found for user '||b_user_name||' in createMobileWFUser.',
                         'CSM_NOTIFICATION_EVENT_PKG.createMobileWFUser',FND_LOG.LEVEL_PROCEDURE);
	 RETURN FALSE;
    END IF;

   wf_directory.CreateAdHocUser(name => role_name, display_name =>role_display_name,
   notification_preference => 'MAILTEXT', email_address =>l_fnd_email);
 END;

 RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
   l_err_msg := TO_CHAR(SQLCODE)|| ':'||SUBSTR(SQLERRM, 1,2000);
   CSM_UTIL_PKG.LOG('Exception in createMobileWFUser for user'||b_user_name||': '||l_err_msg,
                         'CSM_NOTIFICATION_EVENT_PKG.createMobileWFUser',FND_LOG.LEVEL_PROCEDURE);
   CSM_UTIL_PKG.LOG('If SQL DATA NOT FOUND error, then reason is that User '||b_user_name||' is not an active FND nor a mobile enabled user.',
                         'CSM_NOTIFICATION_EVENT_PKG.createMobileWFUser',FND_LOG.LEVEL_PROCEDURE);
   RETURN FALSE;
END createMobileWFUser;

FUNCTION send_email(b_user_name IN VARCHAR2, subject VARCHAR2, message_body VARCHAR2) return NUMBER
IS
role_name VARCHAR2(30);
l_err_msg VARCHAR2(2000);
l_wf_param wf_event_t;
BEGIN

 IF CSM_UTIL_PKG.is_new_mmu_user(b_user_name) THEN
    CSM_UTIL_PKG.LOG(b_user_name||' is a new or not a mobile user, so skip sending notification.','CSM_NOTIFICATION_EVENT_PKG.SEND_EMAIL',FND_LOG.LEVEL_PROCEDURE);
    RETURN -1;
 END IF;

 IF NOT createMobileWFUser(b_user_name) THEN
   RETURN -1;
 ELSE
   role_name := 'CSM_'||b_user_name||'_ROLE';
 END IF;

 wf_event_t.initialize(l_wf_param);
 l_wf_param.AddParameterToList('TEMPLATE','DOWNLOAD_INIT_MSG');
 l_wf_param.AddParameterToList('SUBJECT',subject);
 l_wf_param.AddParameterToList('MESSAGE_BODY',message_body);

return  invoke_WF_NotifyProcess(role_name,l_wf_param);

EXCEPTION
WHEN OTHERS THEN
   l_err_msg := TO_CHAR(SQLCODE)|| ':'||SUBSTR(SQLERRM, 1,2000);
   CSM_UTIL_PKG.LOG('Exception in send_email while sending notification for user'||b_user_name||': '||l_err_msg,
                         'CSM_NOTIFICATION_EVENT_PKG.SEND_EMAIL',FND_LOG.LEVEL_PROCEDURE);
   return -1;
END send_email;

FUNCTION GET_LOCATION(p_loc_id NUMBER) RETURN VARCHAR2
IS

l_location VARCHAR2(2000) := '';

CURSOR c_location (b_loc_id number)
IS
  select ADDRESS1 || NVL2(ADDRESS2,', '||ADDRESS2,'')
  || NVL2(ADDRESS3,', '||ADDRESS3,'') || NVL2(ADDRESS4,', '||ADDRESS4,'')
  || NVL2(CITY,', '||CITY,'') ||  NVL2(STATE,', '||STATE,'') || NVL2(COUNTRY,', '||COUNTRY,'')
  || NVL2(POSTAL_CODE,' '||POSTAL_CODE,'') ADDRESS from hz_locations where location_id= b_loc_id;

BEGIN
 open c_location(p_loc_id);
 fetch c_location INTO l_location;
 close c_location;

 return l_location;
END;

PROCEDURE NOTIFY_USER(entity varchar2, pk_value varchar2,p_mode varchar2)
IS
   l_wf_param wf_event_t;
BEGIN
            wf_event_t.initialize(l_wf_param);
            l_wf_param.AddParameterToList('ENTITY',entity);
            l_wf_param.AddParameterToList('PK_VALUE',pk_value);
			l_wf_param.AddParameterToList('MODE',p_mode);
            csm_notification_event_pkg.notify_user(l_wf_param);
END NOTIFY_USER;

FUNCTION email_optimization(p_user_id NUMBER,p_entity VARCHAR2,p_pk VARCHAR2) RETURN BOOLEAN
IS

CURSOR c_sr(b_sr_id NUMBER,b_user_id NUMBER)
IS
SELECT 1
FROM jtf_task_assignments asg, csm_auto_sync_nfn nfn,
     asg_system_dirty_queue sdq,csm_auto_sync_nfn_acc acc,
	 jtf_tasks_b tsk
where tsk.source_object_id=b_sr_id
and tsk.source_object_type_code='SR'
and tsk.task_id=asg.task_id
and (
   (nfn.object_name='SERVICE_REQUEST' and nfn.object_id=tsk.source_object_id)
    OR
   (nfn.object_name='TASK' and nfn.object_id=asg.task_id)
	OR
   (nfn.object_name='TASK_ASSIGNMENT' and nfn.object_id=task_assignment_id )
   )
and nfn.response IS NULL
and nvl(nfn.reminders_sent,0) < 3
and nfn.user_id=b_user_id
and acc.notification_id=nfn.notification_id
and acc.user_id=nfn.user_id
and sdq.access_id=acc.access_id
and sdq.transaction_id is NULL
and sdq.PUB_ITEM ='CSM_AUTO_SYNC_NFN'
and rownum < 2;

CURSOR c_task(b_task_id NUMBER,b_user_id NUMBER) IS
SELECT 1
FROM jtf_task_assignments asg, csm_auto_sync_nfn nfn,
     asg_system_dirty_queue sdq,csm_auto_sync_nfn_acc acc
where task_id=b_task_id
and (
    (nfn.object_name='TASK' and nfn.object_id=task_id)
	OR
    (nfn.object_name='TASK_ASSIGNMENT' and nfn.object_id=task_assignment_id )
    )
and nfn.user_id=b_user_id
and nfn.response IS NULL
and nvl(nfn.reminders_sent,0) < 3
and acc.notification_id=nfn.notification_id
and acc.user_id=nfn.user_id
and sdq.access_id=acc.access_id
and sdq.transaction_id is NULL
and sdq.PUB_ITEM ='CSM_AUTO_SYNC_NFN'
and rownum < 2;


CURSOR c_task_asg(b_task_ass_id NUMBER,b_user_id NUMBER) IS
SELECT 1
FROM jtf_task_assignments asg, csm_auto_sync_nfn nfn,
     asg_system_dirty_queue sdq,csm_auto_sync_nfn_acc acc,
	 jtf_tasks_b tsk
where task_assignment_id=b_task_ass_id
and tsk.task_id=asg.task_id
and nfn.object_name='TASK_ASSIGNMENT' and nfn.object_id=task_assignment_id
and nfn.response IS NULL
and nvl(nfn.reminders_sent,0) < 3
and nfn.user_id=b_user_id
and acc.notification_id=nfn.notification_id
and acc.user_id=nfn.user_id
and sdq.access_id=acc.access_id
and sdq.transaction_id is NULL
and sdq.PUB_ITEM ='CSM_AUTO_SYNC_NFN'
and rownum < 2;

l_result NUMBER :=0;
BEGIN

/*IF g_switch_optimize_off THEN  RETURN FALSE; END IF; */

IF(p_entity='CSM_TASKS') THEN
 open c_task(to_number(p_pk),p_user_id);
 fetch c_task into l_result;
 close c_task;
ELSIF (p_entity='CSM_INCIDENTS_ALL') THEN
 open c_sr(to_number(p_pk),p_user_id);
 fetch c_sr into l_result;
 close c_sr;
ELSIF (p_entity='CSM_TASK_ASSIGNMENTS') THEN
 open c_task_asg(to_number(p_pk),p_user_id);
 fetch c_task_asg into l_result;
 close c_task_asg;
END IF;

IF l_result=1 THEN
 CSM_UTIL_PKG.LOG('Email Optimized for '||p_entity||'-'||p_pk||'-'||p_user_id,
                         'CSM_NOTIFICATION_EVENT_PKG.email_optimization',FND_LOG.LEVEL_PROCEDURE);
 RETURN TRUE;
END IF;

RETURN FALSE;

END email_optimization;

PROCEDURE NOTIFY_USER(p_wf_param wf_event_t)
IS

  CURSOR c_user_task_assigned(b_task_ass_id NUMBER)
  IS
  SELECT usr.USER_ID,usr.USER_NAME,usr.email_address, b.TASK_ID,TASK_NAME,TASK_NUMBER,
         INCIDENT_NUMBER, INC_TL.SUMMARY,hp.party_name ,
         decode(nvl(inc.incident_location_type,'HZ_PARTY_SITE'), 'HZ_PARTY_SITE',
         (select location_id from hz_party_sites where party_site_id = NVL(inc.incident_location_id, inc.install_site_id)),
         'HZ_LOCATION',
         (select location_id from hz_locations where location_id = NVL(inc.incident_location_id, inc.install_site_id))
         ) location_id
  FROM ASG_USER AU, JTF_TASK_ASSIGNMENTS b,CSM_TASK_ASSIGNMENTS_ACC ACC,
       JTF_TASKS_B tsk,JTF_TASKS_TL tsk_tl,cs_incidents_all_b INC,
	   cs_incidents_all_tl INC_TL, HZ_PARTIES hp, fnd_user usr
  WHERE au.RESOURCE_ID=b.RESOURCE_ID
  AND b.TASK_ASSIGNMENT_ID=b_task_ass_id
  AND b.TASK_ID=tsk.TASK_ID
  AND acc.TASK_ASSIGNMENT_ID=b.TASK_ASSIGNMENT_ID
  AND au.USER_ID=acc.USER_ID
  AND b.TASK_ID=tsk_tl.TASK_ID
  AND INC.incident_id=tsk.SOURCE_OBJECT_ID
  AND INC.incident_id=INC_TL.incident_id
  AND tsk_tl.Language=AU.Language
  AND inc_tl.Language=AU.Language
  AND hp.party_id=inc.customer_id
  AND usr.USER_ID=AU.user_id
  AND AU.user_id <> b.last_updated_by;

  CURSOR c_user_task(b_task_id NUMBER)
  IS
  SELECT usr.USER_ID,usr.USER_NAME,usr.email_address, acc.TASK_ID,TASK_NAME,TASK_NUMBER,
         INCIDENT_NUMBER, INC_TL.SUMMARY,hp.party_name ,
         decode(nvl(inc.incident_location_type,'HZ_PARTY_SITE'), 'HZ_PARTY_SITE',
         (select location_id from hz_party_sites where party_site_id = NVL(inc.incident_location_id, inc.install_site_id)),
          'HZ_LOCATION',
        (select location_id from hz_locations where location_id = NVL(inc.incident_location_id, inc.install_site_id))
         ) location_id
  FROM ASG_USER AU, CSM_TASKS_ACC ACC,
       JTF_TASKS_B tsk,JTF_TASKS_TL tsk_tl,cs_incidents_all_b INC,
	   cs_incidents_all_tl INC_TL, HZ_PARTIES hp, fnd_user usr
  WHERE acc.TASK_ID=b_task_id
  AND acc.TASK_ID=tsk.TASK_ID
  AND au.USER_ID=acc.USER_ID
  AND tsk.TASK_ID=tsk_tl.TASK_ID
  AND INC.incident_id=tsk.SOURCE_OBJECT_ID
  AND INC.incident_id=INC_TL.incident_id
  AND tsk_tl.Language=AU.Language
  AND inc_tl.Language=AU.Language
  AND hp.party_id=inc.customer_id
  AND usr.USER_ID=AU.user_id
  AND AU.user_id <> tsk.last_updated_by;

   CURSOR c_user_sr(b_inc_id NUMBER)
  IS
  SELECT usr.USER_ID,usr.USER_NAME,usr.email_address,acc.INCIDENT_ID,INCIDENT_NUMBER, INC_TL.SUMMARY,hp.party_name,
decode(nvl(inc.incident_location_type,'HZ_PARTY_SITE'), 'HZ_PARTY_SITE',
      (select location_id from hz_party_sites where party_site_id = NVL(inc.incident_location_id, inc.install_site_id)),
       'HZ_LOCATION',
      (select location_id from hz_locations where location_id = NVL(inc.incident_location_id, inc.install_site_id))
       ) location_id
  FROM ASG_USER AU, CSM_INCIDENTS_ALL_ACC ACC,cs_incidents_all_b INC,
	   cs_incidents_all_tl INC_TL, HZ_PARTIES hp, fnd_user usr
  WHERE acc.incident_id=b_inc_id
  AND au.USER_ID=acc.USER_ID
  AND INC.incident_id=acc.incident_id
  AND INC.incident_id=INC_TL.incident_id
  AND inc_tl.Language=AU.Language
  AND hp.party_id=inc.customer_id
  AND usr.user_id=au.user_id
  AND AU.user_id <> INC.last_updated_by;

 CURSOR c_query(b_inst number)
 IS
 SELECT acc.USER_ID,usr.USER_NAME,usr.email_address,
        qry.QUERY_NAME,acc.INSTANCE_NAME
 FROM csm_query_b qry,csm_query_instances_acc acc,
      FND_USER usr
 WHERE acc.QUERY_ID=qry.QUERY_ID
 AND acc.INSTANCE_ID=b_inst
 AND acc.USER_ID=usr.USER_ID;

 CURSOR c_parts(b_acc_id NUMBER)
 IS
  SELECT acc.USER_ID,usr.USER_NAME,usr.email_address,
         b.segment1 "ITEM_NAME",b.description,acc.SUBINVENTORY_CODE,acc.QUANTITY, b.primary_uom_code
  FROM mtl_system_items_b b, CSM_MTL_ONHAND_QTY_ACC acc,FND_USER usr
  WHERE acc.access_id=b_acc_id
  AND b.inventory_item_id=acc.inventory_item_id
  AND b.organization_id=acc.organization_id
  AND acc.user_id=usr.USER_ID;

CURSOR c_req_lines(b_acc_id NUMBER)
IS
 SELECT acc.USER_ID,usr.USER_NAME,usr.email_address,
        acc.requirement_line_id,oh.order_number,
        CSP_PICK_UTILS.get_order_status (ol.LINE_ID, ol.FLOW_STATUS_CODE) order_status,
        nvl(ol.actual_arrival_date,ol.schedule_arrival_date) arrival_date
  FROM   csm_req_lines_acc acc
       , CSP_REQ_LINE_DETAILS crld
       , OE_ORDER_LINES_ALL ol, OE_ORDER_HEADERS_ALL oh
       , fnd_user usr
  WHERE  acc.access_id=b_acc_id
  AND    acc.USER_ID = usr.USER_ID
  AND    acc.requirement_line_id = crld.requirement_line_id
  AND    crld.source_id          = ol.line_id
  AND    ol.header_id = oh.header_id;

CURSOR c_req_details(b_req_detail_id NUMBER)
IS
SELECT ACCESS_ID
FROM CSM_REQ_LINES_ACC acc,
     CSP_REQ_LINE_DETAILS dtl
WHERE REQ_LINE_DETAIL_ID = b_req_detail_id
AND acc.requirement_line_id = dtl.requirement_line_id;


CURSOR c_get_resp_id(b_user_id NUMBER) IS
  SELECT APP_ID,RESPONSIBILITY_ID
  FROM ASG_USER
  WHERE USER_ID=b_user_id;

  l_task_id NUMBER;   l_task_number VARCHAR2(100);  l_task_name VARCHAR2(200);
  l_sr_id NUMBER;     l_sr_number  VARCHAR2(100);   l_sr_summary VARCHAR2(200);
  l_customer_name VARCHAR2(200);

  l_user_id NUMBER;   l_user_name VARCHAR2(100);
  l_location_id NUMBER;
  l_query_name VARCHAR2(255);   l_instance_name VARCHAR2(255);
  l_item_name  VARCHAR2(100);   l_item_desc  VARCHAR2(255);
  l_inv_code VARCHAR2(100);
  l_qty NUMBER;   l_uom VARCHAR2(10);

  l_order_number  NUMBER;
  l_arrival_date DATE;
  l_order_status  VARCHAR2(4000);


  l_notification_id NUMBER;
  l_pk_value NUMBER;
  l_entity VARCHAR2(200);
  l_mode varchar2(10);

  l_email_address VARCHAR2(100);
  l_subject VARCHAR2(200);
  l_body VARCHAR2(4000);

  TYPE l_tab_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE l_name_type IS TABLE OF VARCHAR2(100) INDEX BY BINARY_INTEGER;
  l_uname_tab l_name_type;
  l_not_tab l_tab_type;
  l_usr_tab l_tab_type;
  l_cnt NUMBER :=0;
  l_wftimer wf_event_t;
  l_timeout NUMBER;
  l_resp_id NUMBER;
  l_app_id NUMBER;
BEGIN

  	l_entity := p_wf_param.getValueForParameter('ENTITY');

	IF (l_entity IS NULL
	   OR l_entity NOT IN ('CSM_TASKS','CSM_INCIDENTS_ALL','CSM_TASK_ASSIGNMENTS'
	                      ,'CSM_QUERY_RESULTS','CSF_M_INVENTORY','CSM_REQ_LINES','CSM_REQ_LINE_DETAILS')) THEN
	 RETURN ;
	END IF;


	l_pk_value := to_number(p_wf_param.getValueForParameter('PK_VALUE'));
	l_mode := p_wf_param.getValueForParameter('MODE');

    CSM_UTIL_PKG.LOG('Entering NOTIFY USER for NOTIFY '||l_mode||' OF:' || l_entity || ' for PK:'||l_pk_value,
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_USER',FND_LOG.LEVEL_PROCEDURE);

	IF(l_entity= 'CSM_TASKS') THEN  -- Only Update mode (Called from csmewfb.pls)
	  l_entity:='TASK';

	  OPEN c_user_task(l_pk_value);
	  LOOP
	   FETCH c_user_task INTO l_user_id,l_user_name,l_email_address,l_task_id,l_task_name,l_task_number,l_sr_number,
	                          l_sr_summary,l_customer_name,l_location_id;
	   EXIT WHEN c_user_task%NOTFOUND;

	   IF l_email_address IS NOT NULL and NOT email_optimization(l_user_id,'CSM_TASKS',l_pk_value) THEN
        l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE='||l_mode||':OBJECT_NAME=TASK:TASK_ID='||l_task_id;
        l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:TASK_NUMBER='||l_task_number||':TASK_NAME='||replace(l_task_name,':','\:')||':INCIDENT_NUMBER='||l_sr_number
	              ||':INCIDENT_SUMMARY='||replace(l_sr_summary,':','\:')||':CUSTOMER_NAME='||replace(l_customer_name,':','\:')
		 		  ||':LOCATION='||replace(get_location(l_location_id),':','\:')||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';

	    l_notification_id:=send_email(l_user_name,l_subject,l_body);
	    l_cnt:=l_cnt+1;
        l_not_tab(l_cnt) := l_notification_id;
	    l_usr_tab(l_cnt) := l_user_id;
	    l_uname_tab(l_cnt) := l_user_name;
	   END IF;
      END LOOP;
  	  CLOSE c_user_task;

    ELSIF (l_entity= 'CSM_INCIDENTS_ALL') THEN -- Only Update mode (Called from csmewfb.pls)
	  l_entity:='SERVICE_REQUEST';

	  OPEN c_user_sr(l_pk_value);
	  LOOP
	   FETCH c_user_sr INTO l_user_id,l_user_name,l_email_address,l_sr_id,l_sr_number,
	                          l_sr_summary,l_customer_name,l_location_id;
	   EXIT WHEN c_user_sr%NOTFOUND;

	    IF l_email_address IS NOT NULL AND NOT email_optimization(l_user_id,'CSM_INCIDENTS_ALL',l_pk_value) THEN
	     l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE='||l_mode||':OBJECT_NAME=SERVICE_REQUEST:INCIDENT_ID='||l_sr_id;
         l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:INCIDENT_NUMBER='||l_sr_number||':INCIDENT_SUMMARY='||
		       	    replace(l_sr_summary,':','\:')||':CUSTOMER_NAME='||replace(l_customer_name,':','\:') ||':LOCATION='||
		  		    replace(get_location(l_location_id),':','\:')||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';

	     l_notification_id:=send_email(l_user_name,l_subject,l_body);
	     l_cnt:=l_cnt+1;
         l_not_tab(l_cnt) := l_notification_id;
	     l_usr_tab(l_cnt) := l_user_id;
	     l_uname_tab(l_cnt) := l_user_name;
	    END IF;
      END LOOP;
  	  CLOSE c_user_sr;

    ELSIF (l_entity= 'CSM_TASK_ASSIGNMENTS') THEN	-- Both Insert and Update mode (called from csmewfb.pls & csmeaccb.pls)
	  l_entity:='TASK_ASSIGNMENT';

	  OPEN c_user_task_assigned(l_pk_value);
	  FETCH c_user_task_assigned INTO l_user_id,l_user_name,l_email_address,l_task_id,l_task_name,l_task_number,l_sr_number,
	                          l_sr_summary,l_customer_name,l_location_id;
  	  CLOSE c_user_task_assigned;

	  IF l_email_address IS NULL THEN

        CSM_UTIL_PKG.LOG('Leaving NOTIFY_USER as there is no email found for user - '||l_user_id,
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_USER',FND_LOG.LEVEL_PROCEDURE);
	    RETURN;
	  END IF;

	  IF  l_mode='UPDATE' and email_optimization(l_user_id,'CSM_TASK_ASSIGNMENTS',l_pk_value) THEN
	    RETURN;
	  END IF;

      l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE='||l_mode||':OBJECT_NAME=TASK_ASSIGNMENT:TASK_ASSIGNMENT_ID='||l_pk_value;
      l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:TASK_ID='||l_task_id||':TASK_NUMBER='||l_task_number
                  ||':TASK_NAME='||replace(l_task_name,':','\:')||':INCIDENT_NUMBER='||l_sr_number||':INCIDENT_SUMMARY='||
		       	  replace(l_sr_summary,':','\:')||':CUSTOMER_NAME='||replace(l_customer_name,':','\:') ||':LOCATION='||
				  replace(get_location(l_location_id),':','\:')||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';

	   l_notification_id:=send_email(l_user_name,l_subject,l_body);
	   l_cnt:=l_cnt+1;
       l_not_tab(l_cnt) := l_notification_id;
	   l_usr_tab(l_cnt) := l_user_id;
	   l_uname_tab(l_cnt) := l_user_name;

	ELSIF (l_entity= 'CSM_QUERY_RESULTS') THEN	-- Only Insert mode  (called from csmqryb.pls)
		  l_entity:='QUERY_RESULT';

	    OPEN c_query(l_pk_value);
		LOOP
		 FETCH c_query INTO l_user_id,l_user_name,l_email_address,l_query_name,l_instance_name;
	     EXIT WHEN c_query%NOTFOUND;

	     IF l_email_address IS NOT NULL THEN  --only insert so no optimzation reqd

           l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE=NEW:OBJECT_NAME=QUERY_RESULT:INSTANCE_ID='||l_pk_value;
           l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:INSTANCE_NAME='||replace(l_instance_name,':','\:')
		              ||':QUERY_NAME='||replace(l_query_name,':','\:')||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';

	       l_notification_id:=send_email(l_user_name,l_subject,l_body);
	       l_cnt:=l_cnt+1;
           l_not_tab(l_cnt) := l_notification_id;
	       l_usr_tab(l_cnt) := l_user_id;
	       l_uname_tab(l_cnt) := l_user_name;
	     END IF;
		END LOOP;
		CLOSE c_query;

    ELSIF (l_entity= 'CSF_M_INVENTORY') THEN	-- Both Insert and Update mode (called from csmemsib.pls)
		 l_entity:='INVENTORY';             --Access_id is the PK, so only one record

	    OPEN c_parts(l_pk_value);
  	    FETCH c_parts INTO l_user_id,l_user_name,l_email_address,l_item_name,l_item_desc,l_inv_code,l_qty,l_uom;
	    CLOSE c_parts;

	    IF l_email_address IS NULL THEN
          CSM_UTIL_PKG.LOG('Leaving NOTIFY_USER as there is no email found for user - '||l_user_id,
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_USER',FND_LOG.LEVEL_PROCEDURE);
	      RETURN;
	    END IF;

		IF  l_mode='UPDATE' THEN
	      RETURN;
	    END IF;

        l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE='||l_mode||':OBJECT_NAME=INVENTORY:GEN_PK='||l_pk_value;
        l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:ITEM_NAME='||replace(l_item_name,':','\:')
		           ||':ITEM_DESCRIPTION='||replace(l_item_desc,':','\:')||':SUB_INVENTORY='||replace(l_inv_code,':','\:')
				   ||':QUANTITY='||l_qty||':UOM='||l_uom||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';

	    l_notification_id:=send_email(l_user_name,l_subject,l_body);
	    l_cnt:=l_cnt+1;
        l_not_tab(l_cnt) := l_notification_id;
	    l_usr_tab(l_cnt) := l_user_id;
	    l_uname_tab(l_cnt) := l_user_name;

    ELSIF (l_entity= 'CSM_REQ_LINES') THEN	--Only Update mode (Called from csmerlb.pls)
		 l_entity:='ORDER_STATUS';             --Access_id is the PK, so only one record

	    OPEN c_req_lines(l_pk_value);  --l_pk_value is changed to req line id in FETCH
  	    FETCH c_req_lines INTO l_user_id,l_user_name,l_email_address,l_pk_value,
		                       l_order_number,l_order_status,l_arrival_date;
	    CLOSE c_req_lines;

	    IF l_email_address IS NULL THEN
          CSM_UTIL_PKG.LOG('Leaving NOTIFY_USER as there is no email found for user - '||l_user_id,
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_USER',FND_LOG.LEVEL_PROCEDURE);
	      RETURN;
	    END IF;


        l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE='||l_mode||':OBJECT_NAME=ORDER_STATUS:REQUIREMENT_LINE_ID='||l_pk_value;
        l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:ORDER_NUMBER='||l_order_number
		           ||':STATUS='||replace(l_order_status,':','\:')||':ARRIVAL_DATE='||l_arrival_date||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';

	    l_notification_id:=send_email(l_user_name,l_subject,l_body);
	    l_cnt:=l_cnt+1;
        l_not_tab(l_cnt) := l_notification_id;
	    l_usr_tab(l_cnt) := l_user_id;
	    l_uname_tab(l_cnt) := l_user_name;

    ELSIF (l_entity= 'CSM_REQ_LINE_DETAILS') THEN	--Only Insert mode (Called from csmewfb.pls)
		 l_entity:='ORDER_STATUS';             --l_req_line_detail_id is the PK

	   OPEN c_req_details(l_pk_value);
	   LOOP
		 FETCH c_req_details INTO l_pk_value;   --l_pk_value is now access_id
	     EXIT WHEN c_req_details%NOTFOUND;

	     OPEN c_req_lines(l_pk_value);  --l_pk_value is changed to req line id in FETCH
  	     FETCH c_req_lines INTO l_user_id,l_user_name,l_email_address,l_pk_value,
		                         l_order_number,l_order_status,l_arrival_date;
	     CLOSE c_req_lines;

	     IF l_email_address IS NOT NULL THEN  --only insert so no optimzation reqd

           l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE=NEW:OBJECT_NAME=ORDER_STATUS:REQUIREMENT_LINE_ID='||l_pk_value;
           l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:ORDER_NUMBER='||l_order_number
		             ||':STATUS='||replace(l_order_status,':','\:')||':ARRIVAL_DATE='||l_arrival_date||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';


	       l_notification_id:=send_email(l_user_name,l_subject,l_body);
	       l_cnt:=l_cnt+1;
           l_not_tab(l_cnt) := l_notification_id;
	       l_usr_tab(l_cnt) := l_user_id;
	       l_uname_tab(l_cnt) := l_user_name;
	     END IF;
	  END LOOP;
	  CLOSE c_req_details;

	END IF;


    FOR I in 1..l_cnt
    LOOP
	 IF(l_not_tab(I) <> -1) THEN
       -- insert into auto sync table
       INSERT INTO csm_auto_sync_nfn(USER_ID,NOTIFICATION_ID,OBJECT_NAME,OBJECT_ID,DML,REMINDERS_SENT,CREATION_DATE,CREATED_BY
                                    ,LAST_UPDATE_DATE,LAST_UPDATED_BY)
       VALUES(l_usr_tab(I),l_not_tab(I),l_entity,l_pk_value,l_mode,0,sysdate,1,sysdate,1);

       CSM_ACC_PKG.Insert_Acc
         ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_AUTO_SYNC_NFN')
         ,P_ACC_TABLE_NAME         => 'CSM_AUTO_SYNC_NFN_ACC'
         ,P_SEQ_NAME               => 'CSM_AUTO_SYNC_NFN_ACC_S'
         ,P_PK1_NAME               => 'NOTIFICATION_ID'
         ,P_PK1_NUM_VALUE          => l_not_tab(I)
         ,P_USER_ID                => l_usr_tab(I)
         );

       CSM_UTIL_PKG.LOG('Invoke timer for '||l_not_tab(I),
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_USER',FND_LOG.LEVEL_PROCEDURE);

 	   OPEN c_get_resp_id(l_usr_tab(I));
	   FETCH c_get_resp_id INTO l_app_id,l_resp_id;
	   CLOSE c_get_resp_id;

	   l_timeout := to_number(fnd_profile.value_specific('CSM_ALERT_TIMEOUT_1',l_usr_tab(I),l_resp_id,l_app_id));

       IF l_timeout > 0 THEN
		--timer logic  - Fixed 3 tries + 1 original email
          wf_event_t.initialize(l_wftimer);
          l_wftimer.AddParameterToList('NOTIFICATION_ID',to_char(l_not_tab(I)));
	  	  l_wftimer.AddParameterToList('SENT_TO','CSM_'||l_uname_tab(I)||'_ROLE');
		  l_wftimer.AddParameterToList('TRIES','1');

          wf_event.raise(p_event_name=>'oracle.apps.csm.download.timer',
                         p_event_key=>to_char(l_not_tab(I)),p_parameters=>l_wftimer.getParameterList,
                         p_event_data=>null,p_send_date=>(sysdate+(l_timeout*60*0.000011574)));
	   END IF;
     END IF;
    END LOOP;

IF l_cnt > 0 THEN
   CSM_UTIL_PKG.LOG('Leaving NOTIFY_USER after notifying users to start sync',
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_USER',FND_LOG.LEVEL_PROCEDURE);
ELSE
   CSM_UTIL_PKG.LOG('Leaving NOTIFY_USER. There was no entity found to be notified',
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_USER',FND_LOG.LEVEL_PROCEDURE);
END IF;

END NOTIFY_USER;

--call back api
PROCEDURE NOTIFY_RESPONSE(item_type in varchar2, p_item_key in varchar2,
activity_id in number, command in varchar2, resultout in out NOCOPY varchar2)
IS
 l_text_value VARCHAR2(100);
 l_nid NUMBER;
BEGIN

CSM_UTIL_PKG.LOG( 'In NOTIFY_RESPONSE for command:"'||command||'" with item_key :' || p_item_key
                  ||' and activity_id :'||activity_id,'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_RESPONSE',FND_LOG.LEVEL_PROCEDURE);

IF(item_type='CSM_MSGS' and command = 'RESPOND') THEN

 BEGIN

  select notification_id,text_value INTO l_nid,l_text_value from wf_notification_attributes
  where notification_id = (select notification_id from wf_notifications
  where message_type='CSM_MSGS' and message_name='DOWNLOAD_INIT_MSG'
  and item_key=p_item_key) and name='RESULT';

 EXCEPTION
 WHEN Others THEN
  CSM_UTIL_PKG.LOG( 'Exception occurred in NOTIFY_RESPONSE for item_key :' || p_item_key ||' and activity_id :'
                    ||activity_id|| '->'|| sqlerrm, 'CSM_NOTIFICATION_EVENT_PKG.NOTIFY_RESPONSE',FND_LOG.LEVEL_EXCEPTION);
  RETURN;
 END;


 UPDATE CSM_AUTO_SYNC_NFN
 SET RESPONSE= l_text_value
    ,RESPONDED_ON=SYSDATE
 WHERE NOTIFICATION_ID=l_nid;

-- no need to mark dirty as this info is not downloaded
END IF;

END NOTIFY_RESPONSE;



--Subscription to event "oracle.apps.csm.download.timer"
FUNCTION NOTIFICATION_TIMER_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS
l_nid NUMBER;
l_try NUMBER;
l_wftimer wf_event_t;
CURSOR c_response(b_nid NUMBER) IS
 SELECT 1
 FROM WF_NOTIFICATIONS
 WHERE NOTIFICATION_ID=b_nid
 AND STATUS='CLOSED';

CURSOR c_get_resp_id(b_user_name VARCHAR2) IS
  SELECT APP_ID,RESPONSIBILITY_ID
  FROM ASG_USER
  WHERE USER_NAME=b_user_name;

l_timeout NUMBER;
l_resp_id NUMBER;
l_app_id NUMBER;

l_check NUMBER:=0;
l_role VARCHAR2(120);
l_err_msg VARCHAR2(2000);
l_sql_code NUMBER;
l_count NUMBER;

BEGIN

l_nid := to_number(p_event.GetValueForParameter('NOTIFICATION_ID'));
l_try := to_number(p_event.GetValueForParameter('TRIES'));
l_role := p_event.GetValueForParameter('SENT_TO');

CSM_UTIL_PKG.LOG('TIMER MODULE ENTERED on '|| to_char(sysdate,'DD-MON-YY HH:MI:SS AM') ||' with nid:'||l_nid||' and try:'||l_try,
                         'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_TIMER_SUB',FND_LOG.LEVEL_PROCEDURE);

OPEN c_response(l_nid);
FETCH c_response INTO l_check;
CLOSE c_response;

IF l_check = 1 THEN
  CSM_UTIL_PKG.LOG('Response received in try#'||l_try ||' for nid: '||l_nid,
                   'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_TIMER_SUB',FND_LOG.LEVEL_PROCEDURE);
  RETURN 'SUCCESS';
END IF;


IF l_try <4 THEN
	--timer logic  - only 3 tries

  OPEN c_get_resp_id(substr(l_role,5,length(l_role)-9));
  FETCH c_get_resp_id INTO l_app_id,l_resp_id;
  CLOSE c_get_resp_id;

  if l_try < 3 then
   l_count := l_try + 1;
  else
   l_count := l_try;
  end if;

  l_timeout := to_number(fnd_profile.value_specific('CSM_ALERT_TIMEOUT_'||l_count,
  asg_base.get_user_id(substr(l_role,5,length(l_role)-9)),l_resp_id,l_app_id));

--try sending Email again
     wf_notification.forward(l_nid,l_role);

    UPDATE CSM_AUTO_SYNC_NFN
	SET REMINDERS_SENT = REMINDERS_SENT + 1
	WHERE NOTIFICATION_ID=l_nid;

    l_try := l_try + 1;

    wf_event_t.initialize(l_wftimer);
    l_wftimer.AddParameterToList('NOTIFICATION_ID',to_char(l_nid));
	l_wftimer.AddParameterToList('TRIES',l_try);
	l_wftimer.AddParameterToList('SENT_TO',l_role);
    wf_event.raise(p_event_name=>'oracle.apps.csm.download.timer',
                   p_event_key=>to_char(l_nid),p_parameters=>l_wftimer.getParameterList,
                   p_event_data=>null,p_send_date=>(sysdate+(l_timeout*60*0.000011574)));
ELSE

 CSM_UTIL_PKG.LOG('Email Id '||l_nid||' is not answered by '||substr(l_role,5,length(l_role)-9),
                   'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_TIMER_SUB',FND_LOG.LEVEL_PROCEDURE);

 wf_event_t.initialize(l_wftimer);
 l_wftimer.AddParameterToList('NOTIFICATION_ID',to_char(l_nid));
 l_wftimer.AddParameterToList('RECIPIENT',substr(l_role,5,length(l_role)-9));
 wf_event.raise(p_event_name=>'oracle.apps.csm.download.noResponse',
                p_event_key=>to_char(l_nid),p_parameters=>l_wftimer.getParameterList,
                p_event_data=>null,p_send_date=>null);
END IF;

RETURN 'SUCCESS';
EXCEPTION
WHEN Others THEN
l_sql_code:= SQLCODE;
l_err_msg:= substr(SQLERRM,1,2000);
CSM_UTIL_PKG.LOG('exception while processing '||l_nid||' : '||l_sql_code||':'||l_err_msg,
                   'CSM_NOTIFICATION_EVENT_PKG.NOTIFICATION_TIMER_SUB',FND_LOG.LEVEL_PROCEDURE);

RETURN 'ERROR';
END NOTIFICATION_TIMER_SUB;

FUNCTION getGMTDeviation(p_date IN DATE) RETURN VARCHAR2
IS
l_server_tz NUMBER;
l_dst_begin DATE;
l_dst_end DATE;
l_deviation NUMBER;
l_increment NUMBER;
l_float NUMBER;
l_dev VARCHAR2(10);
BEGIN
 select to_number(profile_option_value) INTO l_server_tz from fnd_profile_option_values where profile_option_id in
 (select profile_option_id from fnd_profile_options where profile_option_name in ('SERVER_TIMEZONE_ID'))
 and level_id=10001;

 select next_day(add_months('1-JAN'||to_char(sysdate,'YYYY'),begin_dst_month-1) + ((begin_dst_week_of_month-1)*7)-1,
 decode(begin_dst_day_of_week, 1,'SUNDAY',2,'MONDAY',3,'TUESDAY',4,'WEDNESDAY',5,'THURSDAY',6,'FRIDAY',7,'SATURDAY')) + (begin_dst_hour/24)  DST_BEGIN_DATE,
 next_day(add_months('1-JAN'||to_char(sysdate,'YYYY'),end_dst_month-1) + ((end_dst_week_of_month-1)*7)-1,
 decode(end_dst_day_of_week, 1,'SUNDAY',2,'MONDAY',3,'TUESDAY',4,'WEDNESDAY',5,'THURSDAY',6,'FRIDAY',7,'SATURDAY')) + (end_dst_hour/24) DST_END_DATE,
 GMT_DEVIATION_HOURS,DST_INCREMENT
 into l_dst_begin,l_dst_end,l_deviation,l_increment
 from jtm_hz_timezones_b where timezone_id=l_server_tz;

 IF(p_date between  l_dst_begin and l_dst_end) THEN
  l_deviation := l_deviation + l_increment;
 END IF;

 IF l_deviation < 0 THEN
  l_dev := to_char(l_deviation);
 ELSE
  l_dev := '+'||to_char(l_deviation);
 END IF;

 IF(instr(l_dev,'.')=0) THEN
  RETURN '[GMT'||l_dev||']';
 ELSE
  l_float:=to_number(substr(l_dev,instr(l_dev,'.'))) * 60 ;
  RETURN '[GMT'||substr(l_dev,1,instr(l_dev,'.')-1)||':'||l_float||']';
 END IF;

EXCEPTION
WHEN Others THEN
 RETURN '';
END getGMTDeviation;

PROCEDURE email_deferred_admin(p_tracking_id IN NUMBER)
IS

CURSOR c_get_deferred_data(b_id NUMBER)
IS
select nfn.deferred_tran_id,nfn.sequence, nfn.client_id, NVL(usr.cookie,'WINCE') as DEVICE_TYPE,
       wfrl.display_name, nfn.object_name, pi.primary_key_column, nfn.object_id, nfn.error_msg,nfn.creation_date
from csm_deferred_nfn_info nfn , asg_pub_item pi, asg_user usr, wf_roles wfrl
where tracking_id=b_id
and wfrl.name=nfn.client_id
and  nfn.object_name=pi.item_id
and  usr.user_name=nfn.client_id;

l_tran_id NUMBER;
l_seq NUMBER;
l_client_id VARCHAR2(100);
l_dev_type VARCHAR2(100);
l_disp_name VARCHAR2(500);
l_pub_name VARCHAR2(100);
l_pk_name VARCHAR2(100);
l_pk_value VARCHAR2(100);
l_err_msg VARCHAR2(2000);
l_tran_date date;

CURSOR c_get_resp_id(b_user_name VARCHAR2) IS
  SELECT APP_ID,RESPONSIBILITY_ID
  FROM ASG_USER
  WHERE USER_NAME=b_user_name;

l_user_string VARCHAR2(4000);
l_user_list asg_download.pk_list;
l_resp_id NUMBER;
l_app_id NUMBER;
l_notification_id	 NUMBER;

l_sql_err_msg VARCHAR2(2000);
l_sql_code NUMBER;
l_wf_param wf_event_t;
BEGIN

  OPEN c_get_deferred_data(p_tracking_id);
  FETCH c_get_deferred_data INTO l_tran_id,l_seq, l_client_id,l_dev_type,l_disp_name,
                                 l_pub_name,l_pk_name,l_pk_value,l_err_msg,l_tran_date;
  CLOSE c_get_deferred_data;

  OPEN c_get_resp_id(l_client_id);
  FETCH c_get_resp_id INTO l_app_id,l_resp_id;
  CLOSE c_get_resp_id;

  SELECT fnd_profile.value_specific('CSM_NOTIFY_DEFERRED',NULL,l_resp_id,l_app_id)
  INTO l_user_string FROM DUAL;

  l_user_list := asg_download.get_listfrom_string(upper(l_user_string));

  wf_event_t.initialize(l_wf_param);
  l_wf_param.AddParameterToList('TEMPLATE','DEFERRED_ERROR_REPORT');

  l_wf_param.AddParameterToList( 'USER_NAME', l_client_id);
  l_wf_param.AddParameterToList( 'TRAN_ID', to_char(l_tran_id));
  l_wf_param.AddParameterToList( 'SEQUENCE', to_char(l_seq));
  l_wf_param.AddParameterToList( 'DEVICE_TYPE', l_dev_type);
  l_wf_param.AddParameterToList( 'EMP_NAME', l_disp_name);
  l_wf_param.AddParameterToList( 'PUB_ITEM', l_pub_name);
  l_wf_param.AddParameterToList( 'PK_COLUMN', l_pk_name);
  l_wf_param.AddParameterToList( 'PK_VALUE', l_pk_value);
  l_wf_param.AddParameterToList( 'ERR_MSG', NVL(l_err_msg,'NULL'));
  l_wf_param.AddParameterToList( 'TRAN_DATE', to_char(l_tran_date,'DD-MON-RRRR HH24:MI:SS')||getGMTDeviation(l_tran_date));


  FOR I IN 1..l_user_list.COUNT
  LOOP
   BEGIN
     CSM_UTIL_PKG.LOG('Sending deferred report email to '||l_user_list(I),
                 'CSM_NOTIFICATION_EVENT_PKG.email_deferred_admin',FND_LOG.LEVEL_PROCEDURE);

     l_notification_id := invoke_WF_NotifyProcess(l_user_list(I),l_wf_param);

    EXCEPTION
    WHEN OTHERS THEN
      l_sql_code:= SQLCODE;
      l_sql_err_msg:= substr(SQLERRM,1,2000);
      CSM_UTIL_PKG.LOG('exception while sending notification to '||l_user_list(I)||' : '||l_sql_code||':'||l_sql_err_msg,
                  'CSM_NOTIFICATION_EVENT_PKG.email_deferred_admin',FND_LOG.LEVEL_EXCEPTION);
   END;
  END LOOP;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
  CSM_UTIL_PKG.LOG('No email is sent to the administrator since the profile CSM_NOTIFY_DEFERRED is NULL',
                 'CSM_NOTIFICATION_EVENT_PKG.email_deferred_admin',FND_LOG.LEVEL_PROCEDURE);
 WHEN Others THEN
  l_sql_code:= SQLCODE;
  l_sql_err_msg:= substr(SQLERRM,1,2000);
  CSM_UTIL_PKG.LOG('exception while emailing admin : '||l_sql_code||':'||l_sql_err_msg,
                  'CSM_NOTIFICATION_EVENT_PKG.email_deferred_admin',FND_LOG.LEVEL_EXCEPTION);

END email_deferred_admin;


FUNCTION get_source_object_code_str(p_parent_pubitem IN VARCHAR2,p_child_pubitem IN VARCHAR2)
return VARCHAR2
IS
 l_code VARCHAR2(100);
BEGIN
/* make an entry here only if more than one parent exists and if the column
   name specifying parent's id is generic */

IF p_child_pubitem ='CSM_TASKS' THEN
     select decode(p_parent_pubitem,'CSM_INCIDENTS_ALL','SR','X')
	 INTO l_code from dual;

     RETURN 'AND SOURCE_OBJECT_TYPE_CODE='''||l_code||'''';
ELSIF p_child_pubitem = 'CSF_M_NOTES' THEN
      select decode(p_parent_pubitem,'CSM_INCIDENTS_ALL','SR','CSM_TASKS','TASK',
      'CSM_DEBRIEF_HEADERS', 'SD','X') INTO l_code from dual;

     RETURN 'AND SOURCE_OBJECT_CODE='''||l_code||'''';
ELSIF p_child_pubitem = 'CSF_M_LOBS' THEN
      select decode(p_parent_pubitem,'CSM_INCIDENTS_ALL','CS_INCIDENTS','CSM_TASKS','JTF_TASKS_B',
	    	        'CSM_DEBRIEF_HEADERS', 'CSF_DEBRIEF_HEADERS','X') INTO l_code from dual;

     RETURN 'AND ENTITY_NAME='''||l_code||'''';
END IF;

RETURN '';
END get_source_object_code_str;

FUNCTION get_source_object_column(p_parent_pubitem IN VARCHAR2,p_child_pubitem IN VARCHAR2)
return VARCHAR2
IS
BEGIN

--if only one parent , directly return column name
--if more than one parent and if not specified here make an entry in get_source_object_code_str

IF p_child_pubitem = 'CSM_TASK_ASSIGNMENTS' THEN
 RETURN 'TASK_ID';
ELSIF p_child_pubitem = 'CSM_DEBRIEF_HEADERS' THEN
 RETURN 'TASK_ASSIGNMENT_ID';
ELSIF p_child_pubitem = 'CSF_M_LOBS' THEN
 RETURN 'PK1_VALUE';
ELSIF p_child_pubitem in ('CSF_M_DEBRIEF_LABOR' ,'CSF_M_DEBRIEF_PARTS','CSF_M_DEBRIEF_EXPENSES')
      and p_parent_pubitem  = 'CSM_DEBRIEF_HEADERS' THEN
 RETURN 'DEBRIEF_HEADER_ID';
ELSIF p_child_pubitem in ('CSF_M_DEBRIEF_LABOR' ,'CSF_M_DEBRIEF_PARTS','CSF_M_DEBRIEF_EXPENSES')
      and p_parent_pubitem  = 'CSM_TASK_ASSIGNMENTS' THEN
 RETURN 'TASK_ASSIGNMENT_ID';
ELSIF p_child_pubitem = 'CSM_REQ_HEADERS' and p_parent_pubitem  = 'CSM_TASK_ASSIGNMENTS' THEN
 RETURN 'TASK_ASSIGNMENT_ID';
ELSIF p_child_pubitem = 'CSM_REQ_HEADERS' and p_parent_pubitem  = 'CSM_TASKS' THEN
 RETURN 'TASK_ID';
ELSIF p_child_pubitem = 'CSM_REQ_LINES' THEN
 RETURN 'REQUIREMENT_HEADER_ID';
ELSIF p_child_pubitem = 'CSM_QUERY_VARIABLE_VALUES' THEN
 RETURN 'INSTANCE_ID';
END IF;

RETURN 'SOURCE_OBJECT_ID';

END get_source_object_column;

--12.1.2
PROCEDURE notify_deferred(p_user_name IN VARCHAR2,
                      p_tranid   IN NUMBER,
                      p_pubitem  IN VARCHAR2,
                      p_sequence  IN NUMBER,
					  p_dml_type  IN VARCHAR2,
					  p_pk IN VARCHAR2,
                      p_error_msg IN VARCHAR2)
IS
CURSOR c_parent(b_child varchar2) IS
SELECT lookup_name
FROM CSM_ERROR_NFN_LOOKUPS
WHERE LOOKUP_TYPE='RELATIONSHIP'
AND LOOKUP_CODE='PARENT_OF'
AND LOOKUP_VALUE=b_child;

CURSOR c_get_resp_id(b_user_name VARCHAR2) IS
  SELECT APP_ID,RESPONSIBILITY_ID
  FROM ASG_USER
  WHERE USER_NAME=b_user_name;

l_wftimer wf_event_t;
l_timeout NUMBER;
l_resp_id NUMBER;
l_app_id NUMBER;

l_parent_pi VARCHAR2(100);
l_subject VARCHAR2(200);
l_body VARCHAR2(4000);
l_mode VARCHAR2(10);
l_sql VARCHAR2(4000);
l_pk_col VARCHAR2(200);
l_pk_value NUMBER;
l_pk_clause VARCHAR2(500);
l_notification_id NUMBER;
l_tracking_id NUMBER :=-1;
l_parent_tracking_id NUMBER;
isRoot BOOLEAN:=TRUE;
l_err_msg VARCHAR2(2000);
l_sql_code NUMBER;
BEGIN

BEGIN
 SELECT tracking_id INTO l_tracking_id
 FROM CSM_DEFERRED_NFN_INFO
 WHERE CLIENT_ID=p_user_name
 AND DEFERRED_TRAN_ID=p_tranid
 AND   DML=p_dml_type
 AND   SEQUENCE=p_sequence;
EXCEPTION
WHEN NO_DATA_FOUND THEN
 NULL;
END;

IF l_tracking_id<>-1 THEN
 l_sql:=p_user_name||' ,'||p_tranid||' ,'||p_sequence;
 CSM_UTIL_PKG.LOG('This deferred record ('||l_sql||') is already being tracked by Id -'||l_tracking_id,
                   'CSM_NOTIFICATION_EVENT_PKG.notify_deferred',FND_LOG.LEVEL_PROCEDURE);
 RETURN;
END IF;


SELECT primary_key_column INTO l_pk_col
 FROM ASG_PUB_ITEM
 WHERE item_id=p_pubitem;

 IF instr(l_pk_col,',')<> 0 THEN
  CSM_UTIL_PKG.LOG('Mulitple Pks in '||p_pubitem||' is not supported in MFS Updatable PIs',
                   'CSM_NOTIFICATION_EVENT_PKG.notify_deferred',FND_LOG.LEVEL_PROCEDURE);
  RETURN;
 END IF;


l_pk_clause :='TRANID$$='||p_tranid ||' AND SEQNO$$='||p_sequence||' AND CLID$$CS='''||p_user_name||'''';

OPEN c_parent(p_pubitem);
LOOP
 FETCH c_parent INTO l_parent_pi;
 EXIT WHEN c_parent%NOTFOUND;
                                 /* IF l_parent_pi IS NOT NULL THEN*/
 BEGIN
     l_sql:= 'SELECT TRACKING_ID FROM CSM_DEFERRED_NFN_INFO WHERE OBJECT_NAME='''||l_parent_pi ||''''
           ||' AND OBJECT_ID=(SELECT '||get_source_object_column(l_parent_pi,p_pubitem)|| ' FROM '
           ||p_pubitem||'_INQ WHERE '||l_pk_clause||' '||get_source_object_code_str(l_parent_pi,p_pubitem) ||') '
           ||' AND DEFERRED_TRAN_ID ='||p_tranid ||' AND CLIENT_ID='''||p_user_name||'''';

    EXECUTE IMMEDIATE l_sql INTO l_parent_tracking_id;
	isROOT:=FALSE;

 EXCEPTION
    WHEN NO_DATA_FOUND THEN
 	 NULL;
 END;

EXIT WHEN isROOT=FALSE; --parent found, so exit
END LOOP;

CLOSE c_parent;

select CSM_DEFERRED_NFN_INFO_S.nextval into l_tracking_id from dual;

 IF isRoot THEN  --notify/email user
  BEGIN -- this email part shdn't disrupt deferred tracking
    IF p_dml_type='I' THEN
      l_mode := 'INSERT';
    ELSIF p_dml_type='U' THEN
      l_mode := 'UPDATE';
    ELSE
      l_mode := 'DELETE';
    END IF;

    l_subject := 'MFS_ALERT:NOTIFICATION_ID=&'||'#NID:MODE=NEW:OBJECT_NAME=DEFERRED_TRANSACTION:TRACKING_ID='||l_tracking_id;
    l_body := 'MFS_ALERT_DETAILS:NOTIFICATION_ID=&'||'#NID:DEFERRED_PI_NAME='||p_pubitem||':'||l_pk_col||'='||p_pk||':DML_TYPE='
	          ||l_mode||':ERROR_MSG='||replace(p_error_msg,':','\:')||':UPLOAD_TRANID='||p_tranid
			  ||':REPLY_TO='||get_mailer_emailId ||':MFS_ALERT_DETAILS';

    l_notification_id:=send_email(p_user_name,l_subject,l_body);

    IF(l_notification_id <> -1) THEN
       -- insert into auto sync table
       INSERT INTO csm_auto_sync_nfn(USER_ID,NOTIFICATION_ID,OBJECT_NAME,OBJECT_ID,DML,REMINDERS_SENT,CREATION_DATE,CREATED_BY
                                    ,LAST_UPDATE_DATE,LAST_UPDATED_BY)
       VALUES(asg_base.get_user_id(p_user_name),l_notification_id,'DEFERRED_TRANSACTION',l_tracking_id,'NEW',0,sysdate,1,sysdate,1);

       CSM_ACC_PKG.Insert_Acc
           ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_AUTO_SYNC_NFN')
           ,P_ACC_TABLE_NAME         => 'CSM_AUTO_SYNC_NFN_ACC'
           ,P_SEQ_NAME               => 'CSM_AUTO_SYNC_NFN_ACC_S'
           ,P_PK1_NAME               => 'NOTIFICATION_ID'
           ,P_PK1_NUM_VALUE          => l_notification_id
           ,P_USER_ID                => asg_base.get_user_id(p_user_name)
           );

       CSM_UTIL_PKG.LOG('Invoke timer for '||l_notification_id,
                         'CSM_NOTIFICATION_EVENT_PKG.notify_deferred',FND_LOG.LEVEL_PROCEDURE);


        OPEN c_get_resp_id(p_user_name);
        FETCH c_get_resp_id INTO l_app_id,l_resp_id;
        CLOSE c_get_resp_id;

        l_timeout := to_number(fnd_profile.value_specific('CSM_ALERT_TIMEOUT_1',asg_base.get_user_id(p_user_name),l_resp_id,l_app_id));

        IF  l_timeout > 0 THEN
		  --timer logic  - Fixed 3 tries + 1 original email
          wf_event_t.initialize(l_wftimer);
          l_wftimer.AddParameterToList('NOTIFICATION_ID',to_char(l_notification_id));
		  l_wftimer.AddParameterToList('SENT_TO','CSM_'||p_user_name||'_ROLE');
		  l_wftimer.AddParameterToList('TRIES','1');

          wf_event.raise(p_event_name=>'oracle.apps.csm.download.timer',
                         p_event_key=>to_char(l_notification_id),p_parameters=>l_wftimer.getParameterList,
                         p_event_data=>null,p_send_date=>(sysdate+(l_timeout*60*0.000011574)));
		END IF;

     END IF;
   EXCEPTION
    WHEN Others THEN
      l_sql_code:= SQLCODE;
      l_err_msg:= substr(SQLERRM,1,2000);
      CSM_UTIL_PKG.LOG('exception while sending/tracking deferred Auto Sync email in NFN table: '||l_sql_code||':'||l_err_msg,
                 'CSM_NOTIFICATION_EVENT_PKG.notify_deferred',FND_LOG.LEVEL_PROCEDURE);
   END;
 END IF; --is ROOT


   --insert into tracking table

 INSERT INTO CSM_DEFERRED_NFN_INFO(TRACKING_ID,CLIENT_ID,NOTIFICATION_ID,OBJECT_NAME , OBJECT_ID,
    DEFERRED_TRAN_ID , SEQUENCE, DML , PARENT_ID , ERROR_MSG ,CREATION_DATE )
 VALUES(l_tracking_id,p_user_name,l_notification_id,p_pubitem,p_pk,p_tranid,p_sequence,
        p_dml_type,l_parent_tracking_id,p_error_msg,sysdate);

 CSM_ACC_PKG.Insert_Acc
        ( P_PUBLICATION_ITEM_NAMES => CSM_ACC_PKG.t_publication_item_list('CSM_DEFERRED_TRANSACTIONS')
         ,P_ACC_TABLE_NAME         => 'CSM_DEFERRED_TRANSACTIONS_ACC'
         ,P_SEQ_NAME               => 'CSM_DEFERRED_TXNS_ACC_S'
         ,P_PK1_NAME               => 'TRACKING_ID'
         ,P_PK1_NUM_VALUE          => l_tracking_id
         ,P_USER_ID                => asg_base.get_user_id(p_user_name)
         );

  --Email Admin about the root error.
  --Email even if l_notification_id is -1
 IF isROOT THEN
   email_deferred_admin(l_tracking_id);
 END IF;

CSM_UTIL_PKG.LOG('Inserted Tracking Id - '||l_tracking_id,'CSM_NOTIFICATION_EVENT_PKG.notify_deferred',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION
WHEN Others THEN
l_sql_code:= SQLCODE;
l_err_msg:= substr(SQLERRM,1,2000);
CSM_UTIL_PKG.LOG('exception while processing '||NVL(l_notification_id,l_tracking_id)||' : '||l_sql_code||':'||l_err_msg,
                 'CSM_NOTIFICATION_EVENT_PKG.notify_deferred',FND_LOG.LEVEL_PROCEDURE);
CSM_UTIL_PKG.LOG('Dynamic SQL query is: '||l_sql,
                   'CSM_NOTIFICATION_EVENT_PKG.notify_deferred',FND_LOG.LEVEL_PROCEDURE);
END NOTIFY_DEFERRED;

--Subscription to event "oracle.apps.asg.sync.failure"
FUNCTION EMAIL_SYNC_ERROR_ADMIN_SUB(p_subscription_guid IN RAW, p_event IN OUT NOCOPY WF_EVENT_T)
RETURN VARCHAR2
IS

l_session_id NUMBER;
l_tran_id NUMBER;
l_client_id VARCHAR2(100);
l_dev_type VARCHAR2(20);
l_dev_name VARCHAR2(240);
l_err_msg VARCHAR2(2000);
l_sync_date DATE;

CURSOR c_get_resp_id(b_user_name VARCHAR2) IS
  SELECT APP_ID,RESPONSIBILITY_ID
  FROM ASG_USER
  WHERE USER_NAME=b_user_name;

l_user_string VARCHAR2(4000);
l_user_list asg_download.pk_list;
l_resp_id NUMBER;
l_app_id NUMBER;
l_notification_id	 NUMBER;

l_sql VARCHAR2(1000);
l_sql_err_msg VARCHAR2(2000);
l_sql_code NUMBER;
l_wf_param wf_event_t;
BEGIN

  l_session_id := to_number(p_event.GetValueForParameter('SESSION_ID'));
  l_tran_id := to_number(p_event.GetValueForParameter('TRAN_ID'));
  l_client_id := p_event.GetValueForParameter('CLIENT_ID');
  l_err_msg := p_event.GetValueForParameter('ERROR_MSG');
  l_sync_date :=to_date(p_event.GetValueForParameter('SYNC_DATE'),'DD-MM-RRRR HH24:MI:SS');
  l_dev_type  := p_event.GetValueForParameter('DEVICE_TYPE');

  BEGIN
   l_sql:= 'select upper(device_name) from (select a.NAME as DEVICE_NAME '
         ||' from '||asg_base.G_OLITE_SCHEMA||'.dm$all_devices a, '||asg_base.G_OLITE_SCHEMA||'.dm$user_device b, '||asg_base.G_OLITE_SCHEMA||'.users c '
	 	 ||' where a.ID=b.DEVICE_ID and  b.USER_ID=c.id and  c.DISPLAY_NAME =:1 order by A.ACCESS_TIME desc ) where rownum < 2';

  EXECUTE IMMEDIATE l_sql INTO l_dev_name USING l_client_id;
  EXCEPTION
   WHEN Others THEN
    l_dev_name := 'NULL';
  END;

  BEGIN
    OPEN c_get_resp_id(l_client_id);
    FETCH c_get_resp_id INTO l_app_id,l_resp_id;
    CLOSE c_get_resp_id;

    SELECT fnd_profile.value_specific('CSM_NFN_SYNC_ERROR',NULL,l_resp_id,l_app_id)
    INTO l_user_string FROM DUAL;

    IF(instr(l_user_string,l_client_id) = 0) THEN
      l_user_string := l_user_string||','||l_client_id;
    END IF;
  EXCEPTION
   WHEN Others THEN
    CSM_UTIL_PKG.LOG('No email is sent to the administrator since the profile CSM_NFN_SYNC_ERROR is NULL.'
	||' Sending email only to Technician '||l_client_id,'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERROR_ADMIN_SUB',FND_LOG.LEVEL_PROCEDURE);

    l_user_string :=l_client_id;
  END;

  l_user_list := asg_download.get_listfrom_string(upper(l_user_string));

  wf_event_t.initialize(l_wf_param);
  l_wf_param.AddParameterToList('TEMPLATE','SYNC_ERROR_REPORT');

  l_wf_param.AddParameterToList('SESSION_ID', l_session_id);
  l_wf_param.AddParameterToList('TRAN_ID', l_tran_id);
  l_wf_param.AddParameterToList('USER_NAME', l_client_id);
  l_wf_param.AddParameterToList('DEVICE_TYPE', l_dev_type);
  l_wf_param.AddParameterToList('DEVICE_NAME', l_dev_name);
  l_wf_param.AddParameterToList('ERROR_MSG', NVL(l_err_msg,'NULL'));
  l_wf_param.AddParameterToList('SYNC_DATE', to_char(l_sync_date,'DD-MON-RRRR HH24:MI:SS')||getGMTDeviation(l_sync_date));

  FOR I IN 1..l_user_list.COUNT
  LOOP
    BEGIN
     CSM_UTIL_PKG.LOG('Sending sync error report email to '||l_user_list(I),
                 'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERROR_ADMIN_SUB',FND_LOG.LEVEL_PROCEDURE);

     l_notification_id := invoke_WF_NotifyProcess(l_user_list(I),l_wf_param);

	 IF  l_notification_id <> -1 THEN
      INSERT INTO CSM_SYNC_ERROR_NFN_INFO(NOTIFICATION_ID,RECIPIENT_NAME, SYNC_SESSION_ID ,CLIENT_ID)
	    VALUES(l_notification_id,l_user_list(I),l_session_id,l_client_id);
	 ELSE
       CSM_UTIL_PKG.LOG('Invoke Wf process returns -1. No notification sent to '||l_user_list(I),
               'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERROR_ADMIN_SUB',FND_LOG.LEVEL_EXCEPTION);
     END IF;
    EXCEPTION
    WHEN OTHERS THEN
      l_sql_code:= SQLCODE;
      l_sql_err_msg:= substr(SQLERRM,1,2000);
      CSM_UTIL_PKG.LOG('exception while sending notification to '||l_user_list(I)||' : '||l_sql_code||':'||l_sql_err_msg,
                  'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERROR_ADMIN_SUB',FND_LOG.LEVEL_EXCEPTION);
    END;
  END LOOP;

  RETURN 'SUCCESS';
EXCEPTION
 WHEN Others THEN
  l_sql_code:= SQLCODE;
  l_sql_err_msg:= substr(SQLERRM,1,2000);
  CSM_UTIL_PKG.LOG('exception while emailing admin : '||l_sql_code||':'||l_sql_err_msg,
                  'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERROR_ADMIN_SUB',FND_LOG.LEVEL_EXCEPTION);
  CSM_UTIL_PKG.LOG('Dynamic SQL query composed is :'||l_sql,
                  'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERROR_ADMIN_SUB',FND_LOG.LEVEL_EXCEPTION);
  RETURN 'ERROR';
END EMAIL_SYNC_ERROR_ADMIN_SUB;

PROCEDURE PURGE_USER(p_user_id IN NUMBER)
IS
BEGIN

 delete from csm_auto_sync_nfn_acc where user_id=p_user_id;

 delete from csm_deferred_transactions_acc where user_id=p_user_id;

 delete from csm_deferred_nfn_info where client_id=csm_util_pkg.get_user_name(p_user_id);

 for rec in (select nfn.notification_id from csm_auto_sync_nfn nfn, wf_notifications wfn
             where nfn.user_id=p_user_id and nfn.notification_id = wfn.notification_id
             and wfn.status='OPEN')
 loop
   wf_notification.respond(rec.notification_id);
 end loop;

 DELETE FROM csm_client_nfn_log cl
	  WHERE EXISTS (SELECT 1 FROM csm_auto_sync_nfn b WHERE b.NOTIFICATION_ID=cl.NOTIFICATION_ID and user_id=p_user_id);

 delete from csm_auto_sync_nfn where user_id=p_user_id;

 delete from CSM_SYNC_ERROR_NFN_INFO where client_id=csm_util_pkg.get_user_name(p_user_id);

END PURGE_USER;

PROCEDURE EMAIL_SYNC_ERRORS_CONC(p_status OUT NOCOPY VARCHAR2, p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_session_id NUMBER;
l_client_id VARCHAR2(100);
l_dev_type VARCHAR2(100);
l_dev_name VARCHAR2(240);
l_err_msg VARCHAR2(4000);
l_sync_date DATE;

CURSOR c_get_resp_id(b_user_name VARCHAR2) IS
  SELECT APP_ID,RESPONSIBILITY_ID
  FROM ASG_USER
  WHERE USER_NAME=b_user_name;

l_user_string VARCHAR2(4000);
l_user_list asg_download.pk_list;
l_resp_id NUMBER;
l_app_id NUMBER;
l_notification_id	 NUMBER;
l_curr_client_id VARCHAR2(100);
l_last_run_date DATE;


l_sql VARCHAR2(1000);
l_sql_err_msg VARCHAR2(2000);
l_sql_code NUMBER;

type t_curs is ref cursor;
cur t_curs;

l_wf_param wf_event_t;
BEGIN

    SELECT NVL(LAST_RUN_DATE,TO_DATE(1,'J')) INTO l_last_run_date
    FROM jtm_con_request_data
    WHERE product_code = 'CSM'
    AND package_name = 'CSM_NOTIFICATION_EVENT_PKG'
    AND procedure_name = 'EMAIL_SYNC_ERRORS_CONC';


    OPEN cur FOR 'SELECT SESSION_ID,client_id,DECODE(DEVICE_PLATFORM,''WCE'',''WINCE'',''LAPTOP'') as DEVICE_TYPE,
                  dbms_lob.substr(message,3990,1)||''...'' as ERROR_MSG, START_TIME AS SYNC_DATE
                  FROM '||asg_base.G_OLITE_SCHEMA||'.c$sync_history  HIST , ASG_USER au
                  WHERE RESULT<>''SUCCESS''
                  AND trim(CLIENT_ID) IS NOT NULL
                  AND CLIENT_ID = AU.USER_NAME
                  AND START_TIME > AU.CREATION_DATE
  				  AND START_TIME > :1
                  AND NOT EXISTS(SELECT 1 FROM CSM_SYNC_ERROR_NFN_INFO
				                 WHERE SYNC_SESSION_ID=HIST.SESSION_ID) ORDER BY CLIENT_ID,SESSION_ID' USING l_last_run_date;

   LOOP
    FETCH cur INTO l_session_id ,l_client_id,l_dev_type,l_err_msg,l_sync_date;
    EXIT WHEN cur%NOTFOUND;


    IF(l_curr_client_id IS NULL OR l_curr_client_id<>l_client_id) THEN

	  CSM_UTIL_PKG.LOG('Processing for user '||l_client_id,
                   'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERRORS_CONC',FND_LOG.LEVEL_PROCEDURE);

	  l_curr_client_id := l_client_id;
      BEGIN
        l_sql:= 'select upper(device_name) from (select a.NAME as DEVICE_NAME '
        ||' from '||asg_base.G_OLITE_SCHEMA||'.dm$all_devices a, '||asg_base.G_OLITE_SCHEMA||'.dm$user_device b, '||asg_base.G_OLITE_SCHEMA||'.users c '
		||' where a.ID=b.DEVICE_ID and  b.USER_ID=c.id and  c.DISPLAY_NAME =:1 order by A.ACCESS_TIME desc ) where rownum < 2';

        EXECUTE IMMEDIATE l_sql INTO l_dev_name USING l_client_id;
	  EXCEPTION
	    WHEN OTHERS THEN
		 l_dev_name := 'NULL';
	  END;

      BEGIN
        OPEN c_get_resp_id(l_client_id);
        FETCH c_get_resp_id INTO l_app_id,l_resp_id;
        CLOSE c_get_resp_id;

        SELECT fnd_profile.value_specific('CSM_NFN_SYNC_ERROR',NULL,l_resp_id,l_app_id)
        INTO l_user_string FROM DUAL;

        IF(instr(l_user_string,l_client_id) = 0) THEN
           l_user_string:=l_user_string||','||l_client_id;
        END IF;
      EXCEPTION
       WHEN Others THEN
        CSM_UTIL_PKG.LOG('No email is sent to the administrator since the profile CSM_NFN_SYNC_ERROR is NULL for technician.'
	     ||' Sending email only to Technician - '|| l_client_id,'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERRORS_CONC',FND_LOG.LEVEL_PROCEDURE);
        l_user_string:= l_client_id;
      END;

	  IF(l_user_list.COUNT>0) THEN
	   l_user_list.DELETE;
	  END IF;

      l_user_list := asg_download.get_listfrom_string(upper(l_user_string));

 	END IF;

	wf_event_t.initialize(l_wf_param);
    l_wf_param.AddParameterToList('TEMPLATE','SYNC_ERROR_REPORT');

    l_wf_param.AddParameterToList('SESSION_ID', to_char(l_session_id));
    l_wf_param.AddParameterToList('USER_NAME', l_client_id);
    l_wf_param.AddParameterToList('DEVICE_TYPE', l_dev_type);
    l_wf_param.AddParameterToList('DEVICE_NAME', l_dev_name);
    l_wf_param.AddParameterToList('ERROR_MSG', NVL(l_err_msg,'NULL'));
    l_wf_param.AddParameterToList('SYNC_DATE', to_char(l_sync_date,'DD-MON-RRRR HH24:MI:SS')||getGMTDeviation(l_sync_date));


    FOR I IN 1..l_user_list.COUNT
    LOOP
     BEGIN
       CSM_UTIL_PKG.LOG('Sending sync error report email on session '||l_session_id||' to '||l_user_list(I),
                   'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERRORS_CONC',FND_LOG.LEVEL_PROCEDURE);

       l_notification_id := invoke_WF_NotifyProcess(l_user_list(I),l_wf_param);

	   IF  l_notification_id <> -1 THEN
         INSERT INTO CSM_SYNC_ERROR_NFN_INFO(NOTIFICATION_ID,RECIPIENT_NAME, SYNC_SESSION_ID ,CLIENT_ID)
	      VALUES(l_notification_id,l_user_list(I),l_session_id,l_client_id);
	   ELSE
         CSM_UTIL_PKG.LOG('Invoke Wf process returns -1. No notification sent to '||l_user_list(I),
               'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERROR_ADMIN_SUB',FND_LOG.LEVEL_EXCEPTION);
       END IF;

     EXCEPTION
     WHEN OTHERS THEN
       l_sql_code:= SQLCODE;
       l_sql_err_msg:= substr(SQLERRM,1,2000);
       CSM_UTIL_PKG.LOG('exception while sending notification on session '||l_session_id||' to '||l_user_list(I)||' : '||l_sql_code||':'||l_sql_err_msg,
                   'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERRORS_CONC',FND_LOG.LEVEL_EXCEPTION);
     END;
    END LOOP;

    COMMIT; -- commit after every session is notified.
   END LOOP;

    UPDATE jtm_con_request_data
	SET LAST_RUN_DATE=sysdate
    WHERE product_code = 'CSM'
    AND package_name = 'CSM_NOTIFICATION_EVENT_PKG'
    AND procedure_name = 'EMAIL_SYNC_ERRORS_CONC';

   p_status := 'SUCCESS';
   p_message :=  'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERRORS_CONC Executed successfully';

COMMIT;

EXCEPTION
 WHEN Others THEN
  l_sql_code:= SQLCODE;
  l_sql_err_msg:= substr(SQLERRM,1,2000);
  CSM_UTIL_PKG.LOG('exception while emailing admin : '||l_sql_code||':'||l_sql_err_msg,
                  'CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERRORS_CONC',FND_LOG.LEVEL_EXCEPTION);
  p_status := 'ERROR';
  p_message := 'Error in CSM_NOTIFICATION_EVENT_PKG.EMAIL_SYNC_ERRORS_CONC: ' ||l_sql_err_msg;
  ROLLBACK;
END EMAIL_SYNC_ERRORS_CONC;

END CSM_NOTIFICATION_EVENT_PKG;

/
