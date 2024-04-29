--------------------------------------------------------
--  DDL for Package Body CSL_CONC_NOTIFICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_CONC_NOTIFICATION_PKG" AS
/* $Header: cslcnwfb.pls 115.5 2002/08/21 08:24:57 rrademak noship $ */

PROCEDURE RUN_CONCURRENT_NOTIFICATIONS
IS

 CURSOR c_LastRundate IS
  SELECT LAST_RUN_DATE
  FROM   JTM_CON_REQUEST_DATA
  WHERE  package_name =  'CSL_CONC_NOTIFICATION_PKG'
  AND    procedure_name = 'RUN_CONCURRENT_NOTIFICATIONS';
 r_LastRundate  c_LastRundate%ROWTYPE;

 CURSOR c_notification( b_last_date DATE ) IS
  SELECT NOTIFICATION_ID
  FROM WF_NOTIFICATIONS
  WHERE BEGIN_DATE >=NVL( b_last_date, BEGIN_DATE )
  AND NOTIFICATION_ID NOT IN
  ( SELECT NOTIFICATION_ID
    FROM JTM_WF_NOTIFICATIONS_ACC );

 CURSOR c_attributes( b_notification_id NUMBER ) IS
  SELECT NAME
  FROM WF_NOTIFICATION_ATTRIBUTES
  WHERE NOTIFICATION_ID = b_notification_id;

  /** Cursor for retrieving all Mobile Resources ***/
  CURSOR c_all_mobile_res IS
   SELECT asgusr.resource_id
   FROM   asg_pub                pub
   ,      asg_pub_responsibility pubresp
   ,      fnd_user_resp_groups   usrresp
   ,      fnd_user               usr
   ,      jtf_rs_resource_extns  res
   ,      asg_user               asgusr
   WHERE  asgusr.resource_id = res.resource_id
   AND    pub.name    = 'SERVICEL'
   AND    pub.enabled = 'Y'
   AND    pub.status  = 'Y'
   AND    pub.pub_id  = pubresp.pub_id
   AND    pubresp.responsibility_id = usrresp.responsibility_id
   AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(usrresp.start_date,sysdate))
                             AND TRUNC(NVL(usrresp.end_date,sysdate))
   AND    usrresp.user_id = usr.user_id
   AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(usr.start_date,sysdate))
                             AND TRUNC(NVL(usr.end_date,sysdate))
   AND    usr.user_id = res.user_id
   AND    TRUNC(sysdate) BETWEEN TRUNC(NVL(res.start_date_active,sysdate))
                             AND TRUNC(NVL(res.end_date_active,sysdate));

   r_all_mobile_res c_all_mobile_res%ROWTYPE;

  /** Cursor for retrieving all Attributes per Notification ***/
  CURSOR c_get_attr_per_notification (b_resource_id NUMBER) IS
   SELECT NOTIFICATION_ID, NAME
   FROM   WF_NOTIFICATION_ATTRIBUTES
   WHERE  NAME IN ('SENDER', 'SUBJECT', 'MESSAGE_TEXT', 'PRIORITY', 'READ_FLAG', 'DELETE_FLAG')
   AND    (NOTIFICATION_ID, NAME) NOT IN
          (
            SELECT NOTIFICATION_ID, NAME
            FROM   JTM_WF_NOTIFICATION_AT_ACC
            WHERE  RESOURCE_ID = b_resource_id
          )
   AND    NOTIFICATION_ID IN
          (
            SELECT NOTIFICATION_ID
            FROM   JTM_WF_NOTIFICATIONS_ACC
            WHERE  RESOURCE_ID = b_resource_id
          );

   r_get_attr_per_notification c_get_attr_per_notification%ROWTYPE;

BEGIN
 /*Fetch and update last run date*/
 OPEN  c_LastRundate;
 FETCH c_LastRundate  INTO r_LastRundate;
 IF c_LastRundate%NOTFOUND THEN
  /*Never seeded = ERROR */
  jtm_message_log_pkg.Log_Msg
    ( 0
    , 'CSL_CONC_NOTIFICATION_PKG'
    , 'CSL_CONC_NOTIFICATION_PKG called but not seeded'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR
    );
  CLOSE c_LastRundate;
  RETURN;
 END IF;
 CLOSE c_LastRundate;

 /*Update the last run date*/
 UPDATE JTM_CON_REQUEST_DATA
 SET    LAST_RUN_DATE = SYSDATE
 WHERE  package_name = 'CSL_CONC_NOTIFICATION_PKG'
 AND    procedure_name = 'RUN_CONCURRENT_NOTIFICATIONS';

 FOR r_notification IN c_notification( r_LastRundate.LAST_RUN_DATE ) LOOP
   /*We have all new notifications now call notification package*/
   CSL_WF_NOTIFICATIONS_ACC_PKG.INSERT_NOTIFICATION( r_notification.NOTIFICATION_ID );

   /*Now fetch the attributes*/
   FOR r_attribute IN c_attributes( r_notification.NOTIFICATION_ID ) LOOP
     CSL_WF_NOTIFICATION_AT_ACC_PKG.INSERT_NOTIFICATION_ATTRIBUTE ( r_notification.NOTIFICATION_ID
                                                                , r_attribute.NAME );
   END LOOP;
 END LOOP;

 /***
   Retrieve per Mobile Resource all Notification Attributes that are not in ACC table yet
   but for which a Notification exists in the Notification ACC table.
   These are (newly) created Notification Attributes that would not get pushed by the Concurrent
   Program because the Notification itself is not new but only the Attributes are.
 ***/
 FOR r_all_mobile_res IN c_all_mobile_res LOOP
   FOR r_get_attr_per_notification IN c_get_attr_per_notification (r_all_mobile_res.resource_id) LOOP
     CSL_WF_NOTIFICATION_AT_ACC_PKG.INSERT_NOTIFICATION_ATTRIBUTE
       ( r_get_attr_per_notification.NOTIFICATION_ID,
         r_get_attr_per_notification.NAME );
   END LOOP;
 END LOOP;

EXCEPTION WHEN OTHERS THEN
 ROLLBACK;
END RUN_CONCURRENT_NOTIFICATIONS;

END CSL_CONC_NOTIFICATION_PKG;

/
