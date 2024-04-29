--------------------------------------------------------
--  DDL for Package Body CSM_STATE_TRANSITION_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_STATE_TRANSITION_EVENT_PKG" AS
/* $Header: csmestrb.pls 120.7 2008/02/07 06:52:55 anaraman ship $ */

l_no_status_transition_resp EXCEPTION;

procedure Refresh_Acc_Del (p_user_id asg_user.user_id%TYPE,
    p_user_name asg_user.user_name%TYPE,
    p_resp_id jtf_state_responsibilities.responsibility_id%TYPE)
IS

l_mark_dirty boolean;

l_responsibility_id jtf_state_responsibilities.responsibility_id%TYPE;
l_state_transition_id JTF_STATE_TRANSITIONS.state_transition_id%TYPE;
l_pkvalueslist asg_download.pk_list;
l_null_pkvalueslist asg_download.pk_list;
l_access_id  CSM_STATE_TRANSITIONS_ACC.ACCESS_ID%TYPE;

CURSOR l_deletes_cur(p_user_id asg_user.user_id%TYPE,
    p_responsibility_id jtf_state_responsibilities.responsibility_id%TYPE)
IS
    SELECT STATE_TRANSITION_ID, ACCESS_ID
       FROM CSM_STATE_TRANSITIONS_ACC acc
       WHERE acc.USER_ID = p_user_id
         AND STATE_TRANSITION_ID not in
           (SELECT STATE_TRANSITION_ID
            FROM JTF_STATE_TRANSITIONS trn
            WHERE RULE_ID IN
               (SELECT sresp.RULE_ID
                FROM JTF_STATE_RESPONSIBILITIES sresp, JTF_STATE_RULES_B srule
                WHERE RESPONSIBILITY_ID = p_responsibility_id
                  AND sresp.RULE_ID = srule.RULE_ID
                  AND srule.STATE_TYPE = 'TASK_STATUS' -- IN ('TASK_STATUS', 'SR_STATUS') AND APPLICATION_ID IN (513, 170)
                )
           );

BEGIN
   -- get the user responsibility id
   l_responsibility_id := p_resp_id;

   --open the cursor
   open l_deletes_cur (p_user_id, l_responsibility_id);
   --loop over cursor entries, and delete from acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_deletes_cur INTO l_state_transition_id, l_access_id;
     EXIT WHEN l_deletes_cur%NOTFOUND;

     l_pkvalueslist := l_null_pkvalueslist;
     l_pkvalueslist(1) := l_state_transition_id;

     --mark dirty the SDQ
     l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForUser('CSF_M_STATE_TRANSITIONS',
--         l_access_id, p_user_id, ASG_DOWNLOAD.DEL, SYSDATE, l_pkvalueslist);
--         Since access_id's are sequence based, we do not need to pass pk values for delete
           l_access_id, p_user_id, ASG_DOWNLOAD.DEL, SYSDATE);

     --delete from ACC
     DELETE FROM CSM_STATE_TRANSITIONS_ACC
       WHERE USER_ID = p_user_id
         AND STATE_TRANSITION_ID = l_state_transition_id;

   END LOOP;

   --close the cursor
   close l_deletes_cur;

END Refresh_Acc_Del;


/**
  Updates the records updated in the backend, in the ACC,
  for the passed user
  Also adds corresponding entries in to SDQ

  Arguments:
    p_user_id User_ID of the user for whom to refresh
    p_access_id: The access_id to be refreshed. If null, then whole ACC table
  is refreshed
*/
procedure Refresh_Acc_Upd (p_user_id asg_user.user_id%TYPE,
    p_access_id CSM_STATE_TRANSITIONS_ACC.state_transition_id%TYPE)
IS

l_mark_dirty boolean;

l_state_transition_id JTF_STATE_TRANSITIONS.state_transition_id%TYPE;
l_last_update_date JTF_STATE_TRANSITIONS.LAST_UPDATE_DATE%TYPE;
l_access_id   CSM_STATE_TRANSITIONS_ACC.ACCESS_ID%TYPE;
l_updates_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_bind_count NUMBER :=1;

BEGIN

  l_dsql :=
      'SELECT trn.state_transition_id, trn.last_update_date, acc.ACCESS_ID
       FROM JTF_STATE_TRANSITIONS trn,
            CSM_STATE_TRANSITIONS_ACC acc
       WHERE trn.state_transition_id = acc.state_transition_id
         AND acc.user_id = :1 AND trn.LAST_UPDATE_DATE > acc.LAST_UPDATE_DATE';

  IF p_access_id IS NOT NULL THEN
    l_dsql := l_dsql || ' AND acc.STATE_TRANSITION_ID = :2';
    l_bind_count := l_bind_count + 1;
  END IF;

   --open the cursor
   IF (l_bind_count =1) THEN
     open l_updates_cur for l_dsql
     using p_user_id;
   ELSIF (l_bind_count =2) THEN
     open l_updates_cur for l_dsql
     using p_user_id, p_access_id;
   END IF;

   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_updates_cur INTO l_state_transition_id, l_last_update_date, l_access_id;
     EXIT WHEN l_updates_cur%NOTFOUND;

     --mark dirty the SDQ
     l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForUser('CSF_M_STATE_TRANSITIONS',
         l_access_id, p_user_id,
         ASG_DOWNLOAD.UPD, sysdate);

     --update ACC
     UPDATE CSM_STATE_TRANSITIONS_ACC
        SET LAST_UPDATE_DATE = l_last_update_date
      WHERE ACCESS_ID = l_access_id
        AND USER_ID = p_user_id;

   END LOOP;

   --close the cursor
   close l_updates_cur;

END Refresh_Acc_Upd;



/**
  Inserts the records inserted in the backend to the ACC,
  for the passed user
  Also adds corresponding entries in to SDQ

  Arguments:
    p_user_id User_ID of the user for whom to refresh
    p_user_name Name of the user for whom to refresh
    p_access_id: The access_id to be refreshed. If null, then whole ACC table
  is refreshed
*/
procedure Refresh_Acc_Ins (
    p_user_id asg_user.user_id%TYPE,
    p_user_name asg_user.user_name%TYPE,
    p_access_id CSM_STATE_TRANSITIONS_ACC.state_transition_id%TYPE,
    p_resp_id jtf_state_responsibilities.responsibility_id%TYPE)
IS

l_mark_dirty boolean;

l_state_transition_id JTF_STATE_TRANSITIONS.state_transition_id%TYPE;
l_last_update_date JTF_STATE_TRANSITIONS.LAST_UPDATE_DATE%TYPE;
l_responsibility_id jtf_state_responsibilities.responsibility_id%TYPE;
l_access_id    CSM_STATE_TRANSITIONS_ACC.ACCESS_ID%TYPE;
l_inserts_cur CSM_UTIL_PKG.Changed_Records_Cur_Type;
l_dsql varchar2(2048);
l_bind_count NUMBER :=2;
BEGIN
   -- get the user responsibility id
   l_responsibility_id := p_resp_id;

   IF l_responsibility_id IS NULL THEN
     RAISE l_no_status_transition_resp;
   END IF;
   l_dsql :=
      'SELECT trn.state_transition_id, trn.last_update_date
       FROM JTF_STATE_TRANSITIONS trn
       WHERE trn.RULE_ID IN
            (SELECT sresp.RULE_ID
             FROM JTF_STATE_RESPONSIBILITIES sresp, JTF_STATE_RULES_B srule
             WHERE sresp.RULE_ID = srule.RULE_ID
             AND srule.STATE_TYPE = ''TASK_STATUS''
             AND RESPONSIBILITY_ID = :1 ) '
     || ' AND trn.state_transition_id not in
            (SELECT state_transition_id
             FROM CSM_STATE_TRANSITIONS_ACC acc
             WHERE user_id = :2)';

  IF p_access_id IS NOT NULL THEN
    l_dsql := l_dsql || ' AND trn.STATE_TRANSITION_ID = :3';
    l_bind_count := l_bind_count + 1;
  END IF;

   --open the cursor
   IF (l_bind_count =2) THEN
     open l_inserts_cur for l_dsql
     using l_responsibility_id, p_user_id;
   ELSIF (l_bind_count =3) THEN
     open l_inserts_cur for l_dsql
     using l_responsibility_id, p_user_id, p_access_id;
   END IF;
   --loop over cursor entries, and update in the acc table, as well as mark dirty the SDQ
   LOOP
     FETCH l_inserts_cur INTO l_state_transition_id, l_last_update_date;
     EXIT WHEN l_inserts_cur%NOTFOUND;

     IF p_access_id IS NULL THEN
       SELECT CSM.CSM_STATE_TRANSITIONS_ACC_S.NEXTVAL INTO l_access_id FROM DUAL;
     ELSE
       l_access_id := p_access_id;
     END IF;

     --mark dirty the SDQ
     l_mark_dirty := CSM_UTIL_PKG.MakeDirtyForUser('CSF_M_STATE_TRANSITIONS',
         l_access_id, p_user_id,
         ASG_DOWNLOAD.INS, sysdate);

     --insert into ACC
     INSERT INTO CSM_STATE_TRANSITIONS_ACC(access_id,
       STATE_TRANSITION_ID, USER_ID, CREATED_BY,
       CREATION_DATE, LAST_UPDATED_BY, LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN)
     VALUES (l_access_id, l_state_transition_id, p_user_id, fnd_global.user_id,
       sysdate, fnd_global.user_id, l_last_update_date,
       fnd_global.user_id);

   END LOOP;

   --close the cursor
   close l_inserts_cur;

END Refresh_Acc_Ins;


/**
  Refreshes the CSM_STATE_TRANSITIONS_ACC table by comparing with the
  backend table for deletes, updates and inserts.
  Also adds corresponding entries in to SDQ

  Arguments:
  p_user_id: The user for whom to refresh the table. If null, then refreshes
  for all the users
  p_access_id: The access_id to be refreshed. If null, then whole ACC table
  is refreshed
*/
procedure Refresh_Acc (p_user_id asg_user.user_id%TYPE,
    p_user_name asg_user.user_name%TYPE,
    p_access_id CSM_STATE_TRANSITIONS_ACC.state_transition_id%TYPE,
    p_respid jtf_state_responsibilities.responsibility_id%TYPE)
IS

BEGIN

  /*** DELETES ***/
  --Delete only if refresh is not asked for a particular access_id
  IF p_access_id IS NULL THEN
    refresh_acc_del(p_user_id, p_user_name, p_respid);
  END IF;
  /******* UPDATES **********/
  refresh_acc_upd(p_user_id, p_access_id);
  /*** INSERTS ***/
  refresh_acc_ins(p_user_id, p_user_name, p_access_id, p_respid);

END;


/**
  Refreshes the CSM_STATE_TRANSITIONS_ACC table by comparing with the
  backend table for deletes, updates and inserts.
  Also adds corresponding entries in to SDQ

  Arguments:
  p_user_id: The user for whom to refresh the table. If null, then refreshes
  for all the users
  p_access_id: The access_id to be refreshed. If null, then whole ACC table
  is refreshed
*/
procedure Refresh_ACC (p_status OUT NOCOPY VARCHAR2,
                       p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;
l_sqlerrno varchar2(20);
l_sqlerrmsg varchar2(2000);
l_responsibility_id jtf_state_responsibilities.responsibility_id%TYPE;
l_run_date DATE;
l_user_id NUMBER;

CURSOR l_omfs_palm_resources_csr is
--R12 For multiple responsibility
   select usr.user_id, usr.user_name
   FROM  asg_user_pub_resps		pubresp
   ,     asg_user               usr
   WHERE usr.enabled = 'Y'
   AND   pubresp.user_name = usr.user_name
   AND   usr.user_id=usr.owner_id
   AND	 pubresp.pub_name ='SERVICEP';


BEGIN
  l_run_date := SYSDATE;

  --if user id is passed, refresh for only that user.
  --else refresh for all the users
/*  IF p_user_id IS NOT NULL THEN
    l_responsibility_id := CSM_UTIL_PKG.get_responsibility_id(p_user_id);

    IF l_responsibility_id IS NULL THEN
        RAISE l_no_status_transition_resp;
    END IF;

    refresh_acc( p_user_id => p_user_id,
                 p_user_name => CSM_UTIL_PKG.get_user_name( p_user_id),
                 p_access_id => p_access_id,
                 p_respid => l_responsibility_id);
  ELSE
*/
    --refresh for all the users
    FOR l_omfs_palm_resources_rec IN l_omfs_palm_resources_csr LOOP
     BEGIN
         l_user_id := l_omfs_palm_resources_rec.user_id;
         l_responsibility_id := CSM_UTIL_PKG.get_responsibility_id(l_omfs_palm_resources_rec.user_id);

         IF l_responsibility_id IS NULL THEN
            RAISE l_no_status_transition_resp;
         END IF;

         refresh_acc( p_user_id  => l_omfs_palm_resources_rec.user_id,
                      p_user_name => l_omfs_palm_resources_rec.user_name,
                      p_access_id => NULL,
                      p_respid => l_responsibility_id);
       EXCEPTION
        WHEN l_no_status_transition_resp THEN
            csm_util_pkg.log('No Status Transition responsibility defined for user: ' || l_omfs_palm_resources_rec.user_name);
     END;
    END LOOP;
--  END IF;

  UPDATE jtm_con_request_data
     SET last_run_date = l_run_date
   WHERE package_name = 'CSM_STATE_TRANSITION_EVENT_PKG'
     AND procedure_name = 'REFRESH_ACC';

  COMMIT;

  p_status := 'FINE';
  p_message :=  'CSM_STATE_TRANSITION_EVENT_PKG.Refresh_Acc Executed successfully';

 EXCEPTION
  WHEN l_no_status_transition_resp THEN
    csm_util_pkg.log('No Status Transition responsibility defined for user: ' || l_user_id);
    p_status := 'ERROR';
    p_message :=  'Error in CSM_STATE_TRANSITION_EVENT_PKG.Refresh_Acc';

  WHEN others THEN
     l_sqlerrno := to_char(SQLCODE);
     l_sqlerrmsg := substr(SQLERRM, 1,300);
     csm_util_pkg.log('State Tansition Error:' || l_sqlerrno || ':' || l_sqlerrmsg, 'CSM_STATE_TRANISITION_EVENT_PKG.Refresh_Acc');
     p_status := 'ERROR';
     p_message :=  'Error in CSM_STATE_TRANSITION_EVENT_PKG.Refresh_Acc :' ||l_sqlerrno || ':' || l_sqlerrmsg;
     ROLLBACK;
--     logm('State Transition Error:' || l_sqlerrno || ':' || substr(l_sqlerrmsg,1,200));
--     fnd_file.put_line(fnd_file.log, 'CSM_STATE_TRANSITION_EVENT_PKG ERROR : ' || l_sqlerrno || ':' || l_sqlerrmsg);

END Refresh_ACC;
END CSM_STATE_TRANSITION_EVENT_PKG;

/
