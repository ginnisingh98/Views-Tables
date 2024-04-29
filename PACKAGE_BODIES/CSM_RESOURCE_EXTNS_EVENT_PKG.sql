--------------------------------------------------------
--  DDL for Package Body CSM_RESOURCE_EXTNS_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_RESOURCE_EXTNS_EVENT_PKG" AS
/* $Header: csmeresb.pls 120.7 2008/02/07 10:39:55 anaraman ship $ */

g_table_name1            CONSTANT VARCHAR2(30) := 'JTF_RS_RESOURCE_EXTNS';
g_acc_table_name1        CONSTANT VARCHAR2(30) := 'CSM_RS_RESOURCE_EXTNS_ACC';
g_acc_sequence_name1     CONSTANT VARCHAR2(30) := 'CSM_RS_RESOURCE_EXTNS_ACC_S';
g_publication_item_name1 CONSTANT CSM_ACC_PKG.t_publication_item_list :=
                             CSM_ACC_PKG.t_publication_item_list('CSF_M_EMPLOYEES');
g_pk1_name1              CONSTANT VARCHAR2(30) := 'RESOURCE_ID';

g_pub_item CONSTANT varchar(30) := 'CSF_M_EMPLOYEES';

l_markdirty_failed EXCEPTION;


PROCEDURE RESOURCE_EXTNS_ACC_I (p_resource_id IN NUMBER, p_user_id IN NUMBER )
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering RESOURCE_EXTNS_ACC_I for resource_id: ' || p_resource_id,
                         'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_I',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Insert_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                    , P_ACC_TABLE_NAME         => g_acc_table_name1
                    , P_SEQ_NAME               => g_acc_sequence_name1
                    , P_PK1_NAME               => g_pk1_name1
                    , P_PK1_NUM_VALUE          => p_resource_id
                    , P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving RESOURCE_EXTNS_ACC_I for resource_id: ' || p_resource_id,
                         'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_I',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  RESOURCE_EXTNS_ACC_I for resource_id:' || to_char(p_resource_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_I',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END RESOURCE_EXTNS_ACC_I;

PROCEDURE RESOURCE_EXTNS_ACC_D (p_resource_id IN NUMBER, p_user_id IN NUMBER )
IS
l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering RESOURCE_EXTNS_ACC_D for resource_id: ' || p_resource_id,
                         'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_D',FND_LOG.LEVEL_PROCEDURE);

    CSM_ACC_PKG.Delete_Acc
     ( P_PUBLICATION_ITEM_NAMES => g_publication_item_name1
                    , P_ACC_TABLE_NAME         => g_acc_table_name1
                    , P_PK1_NAME               => g_pk1_name1
                    , P_PK1_NUM_VALUE          => p_resource_id
                    , P_USER_ID                => p_user_id
     );

   CSM_UTIL_PKG.LOG('Leaving RESOURCE_EXTNS_ACC_D for resource_id: ' || p_resource_id,
                         'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_D',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  RESOURCE_EXTNS_ACC_D for resource_id:' || to_char(p_resource_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_D',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END RESOURCE_EXTNS_ACC_D;

--Bug 5236469
PROCEDURE RESOURCE_EXTNS_ACC_CLEANUP (p_user_id IN NUMBER)
IS
Cursor c_res(b_user_id NUMBER) IS
 SELECT resource_id
 FROM ASG_USER
 WHERE useR_id=b_user_id;

Cursor c_delete(b_resource_id NUMBER) IS
 SELECT user_id
 FROM CSM_RS_RESOURCE_EXTNS_ACC
 WHERE resource_id=b_resource_id;

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_resource_id  NUMBER;


BEGIN
   CSM_UTIL_PKG.LOG('Entering RESOURCE_EXTNS_ACC_CLEANUP for resource_id: ' || p_user_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_CLEANUP',FND_LOG.LEVEL_PROCEDURE);

   OPEN c_res(p_user_id);
   FETCH c_res INTO l_resource_id;
   CLOSE c_res;

   FOR rec IN C_DELETE(l_resource_id)
   LOOP
    RESOURCE_EXTNS_ACC_D(l_resource_id,rec.user_id);
   END LOOP;

--to remove old bad data from access table
   DELETE FROM CSM_RS_RESOURCE_EXTNS_ACC WHERE resource_id=l_resource_id;

   CSM_UTIL_PKG.LOG('Leaving RESOURCE_EXTNS_ACC_CLEANUP for resource_id: ' || p_user_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_CLEANUP',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  RESOURCE_EXTNS_ACC_CLEANUP for user_id:' || to_char(p_user_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_CLEANUP',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END RESOURCE_EXTNS_ACC_CLEANUP;

--Bug 5236469
FUNCTION PROFILE_VALUE(p_user_id IN NUMBER) RETURN NUMBER
IS
 CURSOR c_get_resp_id IS
  SELECT APP_ID, RESPONSIBILITY_ID
  FROM ASG_USER
  WHERE USER_ID=p_user_id;

l_resp_id NUMBER;
l_app_id  NUMBER;

BEGIN

 OPEN c_get_resp_id;
 FETCH c_get_resp_id INTO l_app_id,l_resp_id;
 CLOSE c_get_resp_id;

 RETURN fnd_profile.value_specific('CSF_M_RECIPIENTS_BOUNDARY', p_user_id,l_resp_id, l_app_id);

END PROFILE_VALUE;

--Bug 5236469
PROCEDURE PROCESS_USER (p_resource_id IN NUMBER, p_user_id IN NUMBER)
IS

CURSOR c_delete_prof0(p_resource_id  NUMBER,p_user_id NUMBER) IS
 SELECT resource_id
 FROM   CSM_RS_RESOURCE_EXTNS_ACC ACC
 WHERE  user_id=p_user_id
 AND    resource_id <> p_resource_id
 AND    NOT EXISTS (SELECT 1
                    FROM  ASG_USER AU,
                          ASG_USER_PUB_RESPS AUPR
					WHERE AU.RESOURCE_ID=ACC.RESOURCE_ID
					AND   AU.user_name=AUPR.user_name
					AND   AUPR.pub_name='SERVICEP'
					AND   AU.ENABLED='Y');

CURSOR c_insert_prof0(p_user_id NUMBER) IS
 SELECT AU.resource_id
 FROM   ASG_USER AU,
        ASG_USER_PUB_RESPS AUPR
 WHERE  AU.enabled='Y'
 AND    AU.user_name=AUPR.user_name
 AND    AUPR.pub_name='SERVICEP'
 AND    AU.user_id <> p_user_id
 AND    NOT EXISTS(SELECT 1 FROM CSM_RS_RESOURCE_EXTNS_ACC ACC
                   WHERE ACC.USER_ID=p_user_ID
                   AND   ACC.RESOURCE_ID=AU.RESOURCE_ID);

--12.1
CURSOR c_grp_members(p_resource_id NUMBER, p_user_id NUMBER) IS  --insert prof2
 SELECT DISTINCT jtf_rs.user_id,
                 jtf_rs.resource_id
 FROM jtf_rs_group_members jtf_rs_grp,
      jtf_rs_resource_extns jtf_rs
 WHERE EXISTS (SELECT 1
               FROM jtf_rs_group_members
               WHERE group_id = jtf_rs_grp.group_id
			   AND  resource_id = p_resource_id
               AND  delete_flag = 'N')
 AND jtf_rs.resource_id = jtf_rs_grp.resource_id
 AND jtf_rs.resource_id <> p_resource_id
 AND sysdate BETWEEN jtf_rs.start_date_active  AND NVL(jtf_rs.end_date_active,sysdate)
 AND jtf_rs.USER_ID IS NOT NULL
 AND jtf_rs.USER_NAME IS NOT NULL
 AND NOT EXISTS(SELECT 1 FROM  CSM_RS_RESOURCE_EXTNS_ACC ACC
                WHERE USER_ID=p_user_ID
                AND   ACC.RESOURCE_ID=jtf_rs.resource_id);

--12.1
CURSOR c_delete_prof2(p_resource_id NUMBER,p_user_id NUMBER) IS --delete prof2
 SELECT resource_id
 FROM   CSM_RS_RESOURCE_EXTNS_ACC ACC
 WHERE  acc.user_id=p_user_id
 AND    NOT EXISTS ( SELECT 1
                     FROM jtf_rs_group_members jtf_rs_grp,
                          jtf_rs_resource_extns valid_fnd_user
                     WHERE EXISTS (SELECT 1
                                   FROM jtf_rs_group_members
                                   WHERE group_id = jtf_rs_grp.group_id
                                   AND   resource_id = p_resource_id
                                   AND   delete_flag = 'N')
                     AND jtf_rs_grp.resource_id= Acc.resource_id
					 AND valid_fnd_user.resource_id=Acc.resource_id
					 AND valid_fnd_user.USER_ID IS NOT NULL
    			     AND valid_fnd_user.USER_NAME IS NOT NULL);

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering PROCESS_USER for resource_id: ' || p_resource_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

  IF PROFILE_VALUE(p_user_id)=0 THEN  --ALL MFS USERS

    CSM_UTIL_PKG.LOG('DELETING FOR PROFILE-0 for user id : ' || p_user_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);
    FOR user_rec IN c_delete_prof0(p_resource_id,p_user_id)
    LOOP
      RESOURCE_EXTNS_ACC_D(user_rec.resource_id,p_user_id);
    END LOOP;

    CSM_UTIL_PKG.LOG('INSERTING FOR PROFILE-0 for user id : ' || p_user_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);
    FOR user_rec IN c_insert_prof0(p_user_id)
    LOOP
      RESOURCE_EXTNS_ACC_I(user_rec.resource_id,p_user_id);
    END LOOP;

  ELSE

   CSM_UTIL_PKG.LOG('DELETING FOR PROFILE "1" for user id : ' || p_user_id,
                                  'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

   FOR user_rec IN c_delete_prof2(p_resource_id,p_user_id)
   LOOP
     RESOURCE_EXTNS_ACC_D(user_rec.resource_id,p_user_id);
   END LOOP;

   CSM_UTIL_PKG.LOG('INSERTING FOR PROFILE "1" for user id : ' || p_user_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);

   FOR user_rec IN c_grp_members(p_resource_id,p_user_id)
   LOOP
    RESOURCE_EXTNS_ACC_I(user_rec.resource_id,p_user_id);
   END LOOP;

  END IF;

   CSM_UTIL_PKG.LOG('Leaving PROCESS_USER for resource_id: ' || p_resource_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_USER',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  PROCESS_USER for resource_id:' || to_char(p_resource_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_USER',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END PROCESS_USER;

--Bug 5236469 : CONCURRENT PROGRAM TO CAPTURE PROFILE UPDATES
PROCEDURE PROCESS_NOTIFICATION_SCOPE(p_status OUT NOCOPY VARCHAR2,p_message OUT NOCOPY VARCHAR2)
IS
PRAGMA AUTONOMOUS_TRANSACTION;

 CURSOR c_palm_users IS
  SELECT USER_ID,RESOURCE_ID
  FROM ASG_USER au,
       ASG_USER_PUB_RESPS aupr
  WHERE au.USER_NAME=aupr.USER_NAME
  AND   au.USER_ID=au.OWNER_ID
  AND   au.ENABLED='Y'
  AND   aupr.PUB_NAME='SERVICEP';

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);
l_scope NUMBER;
BEGIN
   CSM_UTIL_PKG.LOG('Entering RESOURCE_EXTNS_ACC_CLEANUP',
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_CLEANUP',FND_LOG.LEVEL_PROCEDURE);

   FOR r_users IN C_PALM_USERS
   LOOP
    Process_user(r_users.resource_id,r_users.user_id);
    COMMIT;
   END LOOP;

  p_status  := 'FINE';
  p_message := 'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_NOTIFICATION_SCOPE executed successfully';

   CSM_UTIL_PKG.LOG('Leaving PROCESS_NOTIFICATION_SCOPE',
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_NOTIFICATION_SCOPE',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  PROCESS_NOTIFICATION_SCOPE :' || l_sqlerrno || ':' || l_sqlerrmsg;
        p_status := 'ERROR';
        p_message := 'Error in CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_NOTIFICATION_SCOPE: ' || l_sqlerrno || ':' || l_sqlerrmsg;
        ROLLBACK;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.PROCESS_NOTIFICATION_SCOPE',FND_LOG.LEVEL_EXCEPTION);
END PROCESS_NOTIFICATION_SCOPE;

/* RESOURCE_EXTNS_ACC_PROCESSOR
 * ----------------------------
 * Populate the CSM_RESOURCE_EXTNS_ACC table.
 */
 --Bug 5236469
PROCEDURE RESOURCE_EXTNS_ACC_PROCESSOR (p_resource_id IN NUMBER, p_user_id IN NUMBER)
IS
-- Cursor to get grp members
CURSOR c_grp_palm_members (p_resource_id  jtf_rs_group_members.resource_id%TYPE) IS
  SELECT DISTINCT au.user_id,
                  au.resource_id
  FROM jtf_rs_group_members jtf_rs_grp,
       ASG_user au,
       ASG_USER_PUB_RESPS aupr
  WHERE EXISTS (SELECT 1
                FROM jtf_rs_group_members
                WHERE group_id = jtf_rs_grp.group_id
                AND   resource_id = p_resource_id
                AND   delete_flag = 'N')
  AND   jtf_rs_grp.resource_id=au.resource_id
  AND   au.enabled='Y'
  AND   au.resource_id<>p_resource_id
  AND   au.USER_NAME=aupr.USER_NAME
  AND   aupr.PUB_NAME='SERVICEP';


CURSOR c_all_mfs_users(p_resource_id  jtf_rs_group_members.resource_id%TYPE)  IS
  SELECT AU.user_id,AU.resource_id
  FROM ASG_USER AU,
       ASG_USER_PUB_RESPS aupr
  WHERE AU.ENABLED='Y'
  AND   AU.resource_id<>p_resource_id
  AND   au.USER_NAME=aupr.USER_NAME
  AND   aupr.PUB_NAME='SERVICEP';


TYPE TABLE_TYPE is TABLE OF NUMBER INDEX BY VARCHAR2(80);
grp_mfs_user TABLE_TYPE;

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

BEGIN
   CSM_UTIL_PKG.LOG('Entering RESOURCE_EXTNS_ACC_PROCESSOR for resource_id: ' || p_resource_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);

   IF csm_util_pkg.is_palm_resource(p_resource_id) THEN
   -- when the parameter RESOURCE_ID is a mobile user..also for him enabled='N' at the time of creation
   ---the above api takes care of this.
   --Insert his record to himself
       RESOURCE_EXTNS_ACC_I(p_resource_id,p_user_id);

    -- Insert all other users based on profile
       PROCESS_USER(p_resource_id,p_user_id);

   	   grp_mfs_user.delete;
       FOR user_rec in c_grp_palm_members(p_resource_id)
       LOOP
        grp_mfs_user(to_char(user_rec.user_id)) :=user_rec.user_id;

        --  insert to this user regardless of profile...since this guy is grp member and mfs user
        RESOURCE_EXTNS_ACC_I(p_resource_id,user_rec.user_id);
       END LOOP;

       --for other non-grp mfs users if their profile_value =0 then insert
       FOR user_rec IN c_all_mfs_users(p_resource_id)
       LOOP
        IF (NOT grp_mfs_user.EXISTS(to_char(user_rec.user_id))) AND PROFILE_VALUE(user_rec.user_id)=0 THEN
          RESOURCE_EXTNS_ACC_I(p_resource_id,user_rec.user_id);
        END IF;
       END LOOP;

  END IF;

   CSM_UTIL_PKG.LOG('Leaving RESOURCE_EXTNS_ACC_PROCESSOR for resource_id: ' || p_resource_id,
                                   'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_PROCESSOR',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  RESOURCE_EXTNS_ACC_PROCESSOR for resource_id:' || to_char(p_resource_id)
                           || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.RESOURCE_EXTNS_ACC_PROCESSOR',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END RESOURCE_EXTNS_ACC_PROCESSOR;

--Bug 5236469
PROCEDURE RS_GROUP_MEMBERS_INS_INIT(p_resource_id IN NUMBER, p_group_id IN NUMBER)
IS

CURSOR l_group_members_csr(p_group_id IN number, p_resource_id IN number)
IS
SELECT au.resource_id, au.user_id
FROM jtf_rs_group_members grp,
     asg_user au,
     asg_user_pub_resps aupr
WHERE grp.group_id = p_group_id
AND   grp.resource_id = au.resource_id
AND   grp.delete_flag = 'N'
AND   au.enabled='Y'
AND   au.USER_NAME=aupr.USER_NAME
AND   aupr.PUB_NAME='SERVICEP'
AND   grp.resource_id <> p_resource_id
AND EXISTS (SELECT 1                            --12.1 -SHD BE A VALID FND USER
            FROM JTF_RS_RESOURCE_EXTNS
            WHERE RESOURCE_ID=p_resource_id
            AND USER_NAME IS NOT NULL
            AND USER_ID IS NOT NULL );


CURSOR l_resource_csr(p_resource_id jtf_rs_resource_extns.resource_id%TYPE)
IS
SELECT au.user_id
FROM   asg_user au,
       asg_user_pub_resps aupr
WHERE au.resource_id = p_resource_id
AND   au.USER_NAME=aupr.USER_NAME
AND   aupr.PUB_NAME='SERVICEP'
AND   au.enabled='Y';

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_user_id fnd_user.user_id%TYPE := NULL;
BEGIN
   CSM_UTIL_PKG.LOG('Entering RS_GROUP_MEMBERS_INS_INIT for resource_id: ' || to_char(p_resource_id) || ' and group_id: '
                         || TO_CHAR(p_group_id), 'CSM_RESOURCE_EXTNS_EVENT_PKG.RS_GROUP_MEMBERS_INS_INIT',FND_LOG.LEVEL_PROCEDURE);

  -- get user_id
   OPEN l_resource_csr(p_resource_id);
   FETCH l_resource_csr INTO l_user_id;
   CLOSE l_resource_csr;


  -- add this resource to existing MFS members in the group
    FOR r_group_members_rec IN l_group_members_csr(p_group_id, p_resource_id)
    LOOP
       IF l_user_id IS NOT NULL THEN    --he's a palm user
        IF PROFILE_VALUE(l_user_id)=2 THEN   --0 means all palm users are already there so dont insert
         RESOURCE_EXTNS_ACC_I(r_group_members_rec.resource_id,l_user_id);
        END IF;
        IF PROFILE_VALUE(r_group_members_rec.user_id)=2 THEN --0 means all palm users are already there so dont insert
         RESOURCE_EXTNS_ACC_I(p_resource_id,r_group_members_rec.user_id);
        END IF;
       ELSE
        IF PROFILE_VALUE(r_group_members_rec.user_id)=2 THEN --insert if profile is set at grp level
          RESOURCE_EXTNS_ACC_I(p_resource_id,r_group_members_rec.user_id);
        END IF;
       END IF;
    END LOOP;


   CSM_UTIL_PKG.LOG('Leaving RS_GROUP_MEMBERS_INS_INIT for resource_id: ' || to_char(p_resource_id) || ' and group_id: '
                         || TO_CHAR(p_group_id), 'CSM_RESOURCE_EXTNS_EVENT_PKG.RS_GROUP_MEMBERS_INS_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  RS_GROUP_MEMBERS_INS_INIT for resource_id:' || to_char(p_resource_id) || ' and group_id: '
                         || TO_CHAR(p_group_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.RS_GROUP_MEMBERS_INS_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END RS_GROUP_MEMBERS_INS_INIT;

--Bug 5236469
PROCEDURE RS_GROUP_MEMBERS_DEL_INIT(p_resource_id IN NUMBER, p_group_id IN NUMBER)
IS

CURSOR l_group_members_csr(p_group_id IN number, p_resource_id IN number)
IS
SELECT au.resource_id, au.user_id
FROM jtf_rs_group_members grp,
     asg_user au,
     asg_user_pub_resps aupr
WHERE grp.group_id = p_group_id
AND   grp.resource_id = au.resource_id
AND   grp.delete_flag = 'N'
AND   au.enabled='Y'
AND   au.USER_NAME=aupr.USER_NAME
AND   aupr.PUB_NAME='SERVICEP'
AND   grp.resource_id <> p_resource_id
AND EXISTS (SELECT 1                            --12.1 -SHD BE A VALID FND USER
            FROM JTF_RS_RESOURCE_EXTNS
            WHERE RESOURCE_ID=p_resource_id
            AND USER_NAME IS NOT NULL
            AND USER_ID IS NOT NULL);


CURSOR l_resource_csr(p_resource_id jtf_rs_resource_extns.resource_id%TYPE)
IS
SELECT au.user_id
FROM   asg_user au,
       asg_user_pub_resps aupr
WHERE au.resource_id = p_resource_id
AND   au.USER_NAME=aupr.USER_NAME
AND   aupr.PUB_NAME='SERVICEP'
AND   au.enabled='Y';

l_sqlerrno VARCHAR2(20);
l_sqlerrmsg VARCHAR2(4000);
l_error_msg VARCHAR2(4000);
l_return_status VARCHAR2(2000);

l_user_id fnd_user.user_id%TYPE := NULL;

BEGIN
   CSM_UTIL_PKG.LOG('Entering RS_GROUP_MEMBERS_DEL_INIT for resource_id: ' || to_char(p_resource_id) || ' and group_id: '
                         || TO_CHAR(p_group_id), 'CSM_RESOURCE_EXTNS_EVENT_PKG.RS_GROUP_MEMBERS_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);

   -- get the user_id
   OPEN l_resource_csr(p_resource_id);
   FETCH l_resource_csr INTO l_user_id;
   CLOSE l_resource_csr;

  -- delete this resource from existing MFS members in the group
    FOR r_group_members_rec IN l_group_members_csr(p_group_id, p_resource_id)
    LOOP
       IF l_user_id IS NOT NULL THEN      --he's a palm user
        IF PROFILE_VALUE(l_user_id)=2 THEN   --0 means all palm users shd be there so dont delete
         RESOURCE_EXTNS_ACC_D(r_group_members_rec.resource_id,l_user_id);
        END IF;
        IF PROFILE_VALUE(r_group_members_rec.user_id)=2 THEN --0 means all palm users shd be there so dont delete
         RESOURCE_EXTNS_ACC_D(p_resource_id,r_group_members_rec.user_id);
        END IF;
	   ELSE --non palm user so delete if he leaves the grp and if the profile is set to grp level
        IF PROFILE_VALUE(r_group_members_rec.user_id)=2 THEN
          RESOURCE_EXTNS_ACC_D(p_resource_id,r_group_members_rec.user_id);
        END IF;
       END IF;
    END LOOP;

   CSM_UTIL_PKG.LOG('Leaving RS_GROUP_MEMBERS_DEL_INIT for resource_id: ' || to_char(p_resource_id) || ' and group_id: '
                         || TO_CHAR(p_group_id), 'CSM_RESOURCE_EXTNS_EVENT_PKG.RS_GROUP_MEMBERS_DEL_INIT',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION
  	WHEN OTHERS THEN
        l_sqlerrno := to_char(SQLCODE);
        l_sqlerrmsg := substr(SQLERRM, 1,2000);
        l_error_msg := ' Exception in  RS_GROUP_MEMBERS_DEL_INIT for resource_id:' || to_char(p_resource_id) || ' and group_id: '
                        || TO_CHAR(p_group_id) || ':' || l_sqlerrno || ':' || l_sqlerrmsg;
        CSM_UTIL_PKG.LOG(l_error_msg, 'CSM_RESOURCE_EXTNS_EVENT_PKG.RS_GROUP_MEMBERS_DEL_INIT',FND_LOG.LEVEL_EXCEPTION);
        RAISE;
END RS_GROUP_MEMBERS_DEL_INIT;

END CSM_RESOURCE_EXTNS_EVENT_PKG;

/
