--------------------------------------------------------
--  DDL for Package Body CSL_WF_NOTIFICATIONS_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_WF_NOTIFICATIONS_ACC_PKG" AS
/* $Header: cslwnacb.pls 115.5 2002/08/21 07:50:03 rrademak ship $ */


/*** Globals for notifications ***/
g_acc_table_name        CONSTANT VARCHAR2(30) := 'JTM_WF_NOTIFICATIONS_ACC';
g_publication_item_name CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
JTM_HOOK_UTIL_PKG.t_publication_item_list('WF_NOTIFICATIONS');
g_table_name            CONSTANT VARCHAR2(30) := 'WF_NOTIFICATIONS';
g_pk1_name              CONSTANT VARCHAR2(30) := 'NOTIFICATION_ID';
g_debug_level           NUMBER;

FUNCTION REPLICATE_RECORD( p_notification_id IN NUMBER )
RETURN BOOLEAN
IS
 CURSOR c_notification( b_notification_id NUMBER ) IS
  SELECT wn.RECIPIENT_ROLE
  ,      wna.TEXT_VALUE
  FROM  WF_NOTIFICATIONS wn
  ,     WF_NOTIFICATION_ATTRIBUTES wna
  WHERE wn.NOTIFICATION_ID = b_notification_id
  AND   wn.MESSAGE_TYPE = 'CS_MSGS'
  AND   wn.MESSAGE_NAME = 'FYI_MESSAGE'
  AND   wn.STATUS = 'OPEN'
  AND   wn.NOTIFICATION_ID = wna.NOTIFICATION_ID
  AND   wna.NAME = 'SENDER';

 r_notification c_notification%ROWTYPE;

 CURSOR c_mobile( b_user_name VARCHAR2 ) IS
  SELECT jre.RESOURCE_ID
  FROM   JTF_RS_RESOURCE_EXTNS jre
  ,      FND_USER usr
  WHERE  usr.USER_NAME = b_user_name
  AND    usr.user_id = jre.user_id;

 r_mobile    c_mobile%ROWTYPE;

 l_ret_value BOOLEAN;
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_notification_id
    , g_table_name
    , 'Entering function REPLICATE_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_ret_value := FALSE;
  OPEN c_notification( p_notification_id );
  FETCH c_notification INTO r_notification;
  IF c_notification%FOUND THEN
    /*check if recipient is a valid mobile user*/
    OPEN c_mobile( r_notification.recipient_role );
    FETCH c_mobile INTO r_mobile;
    IF c_mobile%FOUND THEN
      l_ret_value := JTM_HOOK_UTIL_PKG.isMobileFSresource(r_mobile.resource_id);
    END IF;
    CLOSE c_mobile;

    /*If recipient is not mobile, check if sender is*/
    IF l_ret_value = FALSE THEN
      OPEN c_mobile( r_notification.text_value );
      FETCH c_mobile INTO r_mobile;
      IF c_mobile%FOUND THEN
        /*Check if sender is a valid mobile user*/
        l_ret_value := JTM_HOOK_UTIL_PKG.isMobileFSresource(r_mobile.resource_id);
      END IF;
      CLOSE c_mobile;
      IF l_ret_value = FALSE THEN
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
            ( p_notification_id
            , g_table_name
            , 'Notification '||p_notification_id||' is not for a valid mobile field service user.'
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
      END IF;
    END IF;
  ELSE
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( p_notification_id
      , g_table_name
      , 'Notification '||p_notification_id||' is not an open CS_MSGS/FYI_MESSAGE'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  END IF;
  CLOSE c_notification;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_notification_id
    , g_table_name
    , 'Leaving function REPLICATE_RECORD'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_ret_value;
END REPLICATE_RECORD;

PROCEDURE INSERT_NOTIFICATION( p_notification_id IN NUMBER )
IS
  l_replicate     BOOLEAN;

  /*** Cursor to get user id which will be used to check if its a mobile resource ***/
  CURSOR c_get_recipient
    ( b_notification_id NUMBER
    )
  IS
  SELECT jre.resource_id
  ,      usr.user_id
  FROM   jtf_rs_resource_extns jre
  ,      fnd_user              usr
  ,      wf_notifications      wfn
  WHERE  wfn.recipient_role = usr.user_name
  AND    usr.user_id        = jre.user_id
  AND    jre.category       = 'EMPLOYEE'
  AND    wfn.notification_id = b_notification_id;

  r_get_recipient c_get_recipient%ROWTYPE;

  CURSOR c_get_sender( b_notification_id NUMBER ) IS
    SELECT jre.resource_id
    FROM   jtf_rs_resource_extns      jre
    ,      fnd_user                   usr
    ,      wf_notification_attributes wna
    WHERE  wna.name           = 'SENDER'
    AND    wna.text_value     = usr.user_name
    AND    usr.user_id        = jre.user_id
    AND    jre.category       = 'EMPLOYEE'
    AND    wna.notification_id = b_notification_id;

   r_get_sender c_get_sender%ROWTYPE;

BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_notification_id
    , g_table_name
    , 'Entering Procedure INSERT_NOTIFICATION'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_replicate := REPLICATE_RECORD( p_notification_id );
  IF l_replicate THEN
    /*First check if mail is for mobile user */
    OPEN c_get_recipient( p_notification_id );
    FETCH c_get_recipient INTO r_get_recipient;
    IF c_get_recipient%FOUND THEN
      IF JTM_HOOK_UTIL_PKG.isMobileFSresource(r_get_recipient.resource_id) THEN
        JTM_HOOK_UTIL_PKG.Insert_Acc
          ( p_publication_item_names => g_publication_item_name
          , p_acc_table_name         => g_acc_table_name
          , p_pk1_name               => g_pk1_name
          , p_pk1_num_value          => p_notification_id
          , p_resource_id            => r_get_recipient.resource_id
          );
        /*** Call FND_USER Hook to make sure the recipient gets replicated as well. ***/
        CSL_FND_USER_ACC_PKG.Insert_User (r_get_recipient.user_id, r_get_recipient.resource_id);
      END IF;
    END IF;
    CLOSE c_get_recipient;
    /*Check if sender also needs this record*/
    OPEN c_get_sender( p_notification_id );
    FETCH c_get_sender INTO r_get_sender;
    IF c_get_sender%FOUND THEN
      IF JTM_HOOK_UTIL_PKG.isMobileFSresource(r_get_sender.resource_id) THEN
        JTM_HOOK_UTIL_PKG.Insert_Acc
          ( p_publication_item_names => g_publication_item_name
          , p_acc_table_name         => g_acc_table_name
          , p_pk1_name               => g_pk1_name
          , p_pk1_num_value          => p_notification_id
          , p_resource_id            => r_get_sender.resource_id
          );
        /*Record should ge to the sender, user is user of notification record*/
        /*** Call FND_USER Hook to make sure the recipient gets replicated as well. ***/
        CSL_FND_USER_ACC_PKG.Insert_User (r_get_recipient.user_id, r_get_sender.resource_id);
      END IF;
    END IF;
    CLOSE c_get_sender;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.LOG_MSG
      ( p_notification_id
      , g_table_name
      , 'Leaving Procedure INSERT_NOTIFICATION'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

END INSERT_NOTIFICATION;

END CSL_WF_NOTIFICATIONS_ACC_PKG;

/
