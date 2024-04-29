--------------------------------------------------------
--  DDL for Package Body CSL_WF_NOTIFICATION_AT_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_WF_NOTIFICATION_AT_ACC_PKG" AS
/* $Header: cslwaacb.pls 115.16 2002/11/08 13:59:56 asiegers ship $ */


/*** Globals for notification attributes ***/
g_publication_item_name  CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
                         JTM_HOOK_UTIL_PKG.t_publication_item_list('WF_NOTIFICATION_ATTR');
g_publication_item_name2 CONSTANT JTM_HOOK_UTIL_PKG.t_publication_item_list :=
                         JTM_HOOK_UTIL_PKG.t_publication_item_list('WF_NOTIFICATIONS');

g_acc_table_name         CONSTANT VARCHAR2(30) := 'JTM_WF_NOTIFICATION_AT_ACC';
g_acc_table_name2        CONSTANT VARCHAR2(30) := 'JTM_WF_NOTIFICATIONS_ACC';
g_table_name             CONSTANT VARCHAR2(30) := 'WF_NOTIFICATION_ATTRIBUTES';
g_table_name2            CONSTANT VARCHAR2(30) := 'WF_NOTIFICATIONS';
g_pk1_name               CONSTANT VARCHAR2(30) := 'NOTIFICATION_ID';
g_pk2_name               CONSTANT VARCHAR2(30) := 'NAME';
g_debug_level            NUMBER;

PROCEDURE INSERT_NOTIFICATION_ATTRIBUTE ( p_notification_id IN NUMBER, p_name IN VARCHAR2 )
IS

  l_sender_user               BOOLEAN;
  l_recipient_user            BOOLEAN;
  l_sender_mobile_resource    BOOLEAN;
  l_recipient_mobile_resource BOOLEAN;

  /*** Cursor for retrieving user id of the sender of the notification ***/
  CURSOR c_get_sender
    ( b_notification_id NUMBER
    )
  IS
  SELECT user_id
  FROM   fnd_user                   usr
  ,      wf_notifications           wno
  ,      wf_notification_attributes wna
  WHERE  usr.user_name       = wna.text_value
  AND    wna.notification_id = wno.notification_id
  AND    wna.notification_id = b_notification_id
  AND    wno.MESSAGE_TYPE    = 'CS_MSGS'
  AND    wno.MESSAGE_NAME    = 'FYI_MESSAGE'
  AND    wno.STATUS          = 'OPEN'
  AND    wna.name            = 'SENDER';

  r_get_sender  c_get_sender%ROWTYPE;

  /*** Cursor for retrieving user id of the recipient of the notification ***/
  CURSOR c_get_recipient
     ( b_notification_id NUMBER
     )
  IS
  SELECT user_id
  FROM   fnd_user              usr
  ,      wf_notifications      wfn
  WHERE  wfn.recipient_role  = usr.user_name
  AND    wfn.MESSAGE_TYPE    = 'CS_MSGS'
  AND    wfn.MESSAGE_NAME    = 'FYI_MESSAGE'
  AND    wfn.STATUS          = 'OPEN'
  AND    wfn.notification_id = b_notification_id;

  r_get_recipient c_get_recipient%ROWTYPE;

  /*** Cursor to retrieve the resource belonging to a user id ***/
  CURSOR c_get_user_resource
    ( b_user_id NUMBER
    )
  IS
  SELECT resource_id
  FROM   jtf_rs_resource_extns
  WHERE  nvl(end_date_active, sysdate) >= sysdate
  AND    category = 'EMPLOYEE'
  AND    user_id = b_user_id;

  r_get_sender_resource    c_get_user_resource%ROWTYPE;
  r_get_recipient_resource c_get_user_resource%ROWTYPE;

  /*** Cursor to retrieve all notification attributes for a resource ***/
  CURSOR c_recipient_attr (b_notification_id NUMBER, b_resource_id NUMBER)
  IS
  SELECT notification_id , name
  FROM   JTM_WF_NOTIFICATION_AT_ACC
  WHERE  notification_id = b_notification_id
  AND    resource_id = b_resource_id;

  r_recipient_attr c_recipient_attr%ROWTYPE;

  CURSOR c_notification_exists( b_notification_id NUMBER ) IS
    SELECT access_id
    ,      resource_id
    FROM   JTM_WF_NOTIFICATIONS_ACC
    WHERE  NOTIFICATION_ID = b_notification_id;

  r_notification_exists c_notification_exists%ROWTYPE;

BEGIN

  /*** Execute necessary cursors before the notification attribute is checked and init vars. ***/
  g_debug_level    := JTM_HOOK_UTIL_PKG.Get_Debug_Level;
  l_sender_user    := True;
  l_recipient_user := True;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( p_notification_id
    , g_table_name
    , 'Entering Procedure INSERT_NOTIFICATION_ATTRIBUTE'
    , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** First check if sender and recipient are fnd users.       ***/
  /*** Then check if sender and recipient are mobile resources. ***/

  /*** Get user_id of sender ***/
  OPEN  c_get_sender ( p_notification_id );
  FETCH c_get_sender INTO r_get_sender;

  IF c_get_sender%NOTFOUND THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
        ( p_notification_id
        , g_table_name
        , 'Notification is not an open CS_MSGS/FYI_MESSAGE or sender user can not be found'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    l_sender_user := False;
  END IF;
  CLOSE c_get_sender;

  /*** Get user_id of recipient ***/
  OPEN  c_get_recipient ( p_notification_id );
  FETCH c_get_recipient INTO r_get_recipient;

  IF c_get_recipient%NOTFOUND THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
        ( p_notification_id
        , g_table_name2
        , 'Notification is not an open CS_MSGS/FYI_MESSAGE or recipient user can not be found'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
    l_recipient_user := False;
  END IF;
  CLOSE c_get_recipient;

  /*** If the sender is a user then check if it is a resource and a mobile resource ***/
  IF l_sender_user THEN
    OPEN c_get_user_resource (r_get_sender.user_id);
    FETCH c_get_user_resource INTO r_get_sender_resource;

    IF c_get_user_resource%NOTFOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
          ( p_notification_id
          , g_table_name
          , 'Sender of notification is not a resource.'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      /*** If sender is not a resource then it is also not a mobile resource ***/
      l_sender_mobile_resource := False;
    ELSE
      /*** Check if sender is a mobile resource ***/
      l_sender_mobile_resource := JTM_HOOK_UTIL_PKG.isMobileFSresource(r_get_sender_resource.resource_id);
    END IF;
    CLOSE c_get_user_resource;
  ELSE
    /*** If sender is not a user then it cannot be a resource and also not a mobile resource ***/
    l_sender_mobile_resource := False;
  END IF;

  /*** If the recipient is a user then check if it is a mobile resource ***/
  IF l_recipient_user THEN
    OPEN c_get_user_resource (r_get_recipient.user_id);
    FETCH c_get_user_resource INTO r_get_recipient_resource;

    IF c_get_user_resource%NOTFOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
          ( p_notification_id
          , g_table_name
          , 'Recipient of notification is not a resource.'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      /*** If recipient is not a resource then it is also not a mobile resource ***/
      l_recipient_mobile_resource := False;
    ELSE
     /*** Check if recipient is a mobile resource ***/
     l_recipient_mobile_resource := JTM_HOOK_UTIL_PKG.isMobileFSresource(r_get_recipient_resource.resource_id);
    END IF;
    CLOSE c_get_user_resource;
  ELSE
    /*** If recipient is not a user then it cannot be a resource and also not a mobile resource ***/
    l_recipient_mobile_resource := False;
  END IF;

  /* INSERT NOTIFICATION ATTRIBUTE */
  /* There are 4 possible values for p_name: 'SENDER', 'DELETE_FLAG', 'READ_FLAG' or 'MESSAGE_TEXT'.      */
  /* First all specific code is executed depending of the value for p_name, then all common code.         */
  /* Specific code for Attribute Name = 'SENDER'                                                          */

  IF (p_name = 'SENDER' AND l_sender_mobile_resource) THEN
    OPEN c_notification_exists( p_notification_id );
    FETCH c_notification_exists INTO r_notification_exists;
    IF c_notification_exists%NOTFOUND THEN
      /*** Notification id is not in ACC table yet: Insert ***/
      CSL_WF_NOTIFICATIONS_ACC_PKG.INSERT_NOTIFICATION( p_notification_id );
    END IF;
    CLOSE c_notification_exists;
  END IF;

  /*** Specific code for Attribute Name = 'DELETE_FLAG' ***/
  IF p_name = 'DELETE_FLAG' THEN
    IF l_recipient_mobile_resource THEN
      /*** Delete notification id for recipient from Notification ACC table. ***/
      JTM_HOOK_UTIL_PKG.Delete_Acc
        ( p_publication_item_names => g_publication_item_name2
        , p_acc_table_name         => g_acc_table_name2
        , p_pk1_name               => g_pk1_name
        , p_pk1_num_value          => p_notification_id
        , p_resource_id            => r_get_recipient_resource.resource_id
        );

      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
          ( p_notification_id
          , g_table_name2
          , 'Deleted recipient notification id from Notification Attribute ACC table.'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;

      /* Delete all attributes of notification id of recipient from Notification Attribute ACC table.        */
      /* Retrieve all attributes, loop through them and call JTM_HOOK_UTIL_PKG.Delete_Acc for all attributes.*/
      OPEN c_recipient_attr(p_notification_id, r_get_recipient_resource.resource_id);
      FETCH c_recipient_attr INTO r_recipient_attr;
      IF c_recipient_attr%NOTFOUND THEN
        /*** could not find any notification attribute records to be deleted ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
            ( p_notification_id
            , g_table_name
            , 'Did not find any Notification Attribute records to be deleted for recipient.'
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        CLOSE c_recipient_attr;
      ELSE
        /*** Loop over all available records and delete them from the Notification Attribute ACC table ***/
        WHILE c_recipient_attr%FOUND LOOP
            /*** Call delete function of JTM_HOOK_UTIL_PKG to delete records from the ACC table ***/
          JTM_HOOK_UTIL_PKG.Delete_Acc
            ( p_publication_item_names => g_publication_item_name
            , p_acc_table_name         => g_acc_table_name
            , p_pk1_name               => g_pk1_name
            , p_pk1_num_value          => p_notification_id
            , p_pk2_name               => g_pk2_name
            , p_pk2_char_value         => r_recipient_attr.name
            , p_resource_id            => r_get_recipient_resource.resource_id
            );

          FETCH c_recipient_attr INTO r_recipient_attr;
        END LOOP;
        CLOSE c_recipient_attr;

        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
            ( p_notification_id
            , g_table_name
            , 'Deleted all records for recipient from Notification Attribute ACC table.'
            , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
      END IF;
    ELSE
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
          ( p_notification_id
          , g_table_name
          , 'Recipient of notification is not a Mobile Resource: No deletion of notification from ACC table.'
          , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    END IF;
  END IF;


  /* No specific code has to be executed for Notification Attribute Names: 'READ_FLAG' and 'MESSAGE_TEXT' */
  /* Common code for Notification Attribute Name is 'SENDER' and 'MESSAGE_TEXT':                          */
  /* Insert Notification Attribute id and name into ACC table for Notification Attributes.                */
  IF ((( p_name = 'SENDER')
    OR ( p_name = 'MESSAGE_TEXT')
    OR ( p_name = 'PRIORITY')
    OR ( p_name = 'SUBJECT'))
    AND l_sender_mobile_resource) THEN

    /*** Do an insert into ACC table for sender of notification attribute ***/
    JTM_HOOK_UTIL_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
      , p_acc_table_name         => g_acc_table_name
      , p_pk1_name               => g_pk1_name
      , p_pk1_num_value          => p_notification_id
      , p_pk2_name               => g_pk2_name
      , p_pk2_char_value         => p_name
      , p_resource_id            => r_get_sender_resource.resource_id
      );

    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
       ( p_notification_id
       , g_table_name
       , 'Inserted attributes for sender notification ' || p_notification_id|| ' + ' || p_name
       , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END IF;


  /*** Common code for Notification Attribute Name is 'SENDER' and 'READ_FLAG':              ***/
  /*** Insert Notification Attribute id and name into ACC table for Notification Attributes. ***/
  IF ( ((p_name = 'SENDER')
     OR (p_name = 'READ_FLAG')
     OR (p_name = 'MESSAGE_TEXT')
     OR (p_name = 'SUBJECT')
     OR (p_name = 'PRIORITY'))
     AND l_recipient_mobile_resource) THEN

    /*** Insert recipient notification id and name into Notification Attribute ACC table.    ***/
    JTM_HOOK_UTIL_PKG.Insert_Acc
      ( p_publication_item_names => g_publication_item_name
      , p_acc_table_name         => g_acc_table_name
      , p_pk1_name               => g_pk1_name
      , p_pk1_num_value          => p_notification_id
      , p_pk2_name               => g_pk2_name
      , p_pk2_char_value         => p_name
      , p_resource_id            => r_get_recipient_resource.resource_id
      );

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
        ( p_notification_id
        , g_table_name
        , 'Inserted recipient notification id and name into Notification Attribute ACC table.'
        , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.LOG_MSG
      ( p_notification_id
      , g_table_name
      , 'Leaving Procedure INSERT_NOTIFICATION_ATTRIBUTE'
      , JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END INSERT_NOTIFICATION_ATTRIBUTE;

/******/

PROCEDURE Insert_All_ACC_Records(
                 p_resource_id     IN  NUMBER,
                 x_return_status   OUT NOCOPY VARCHAR2
                 )
IS

  CURSOR c_notification_sender (b_resource_id NUMBER) IS
    SELECT DISTINCT WNO.NOTIFICATION_ID
    FROM WF_NOTIFICATIONS            WNO,
         WF_NOTIFICATION_ATTRIBUTES  WNA,
         FND_USER                    USR,
         ASG_USER                    ADU
    WHERE WNO.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      AND WNA.NAME            = 'SENDER'
      AND WNO.MESSAGE_TYPE    = 'CS_MSGS'
      AND WNO.MESSAGE_NAME    = 'FYI_MESSAGE'
      AND WNO.STATUS          = 'OPEN'
      AND WNA.TEXT_VALUE      = USR.USER_NAME
      AND USR.USER_ID         = ADU.USER_ID
      AND ADU.RESOURCE_ID     = b_resource_id;
  r_notification_sender c_notification_sender%ROWTYPE;

  CURSOR c_notification_receive (b_resource_id NUMBER) IS
	SELECT DISTINCT WNO.NOTIFICATION_ID
    FROM WF_NOTIFICATIONS     WNO,
         FND_USER             USR,
         ASG_USER             ADU
    WHERE WNO.RECIPIENT_ROLE = USR.USER_NAME
      AND USR.USER_ID        = ADU.USER_ID
      AND ADU.RESOURCE_ID    = b_resource_id
      AND WNO.STATUS         = 'OPEN'
      AND WNO.MESSAGE_TYPE   = 'CS_MSGS'
      AND WNO.MESSAGE_NAME   = 'FYI_MESSAGE'
      AND NOT EXISTS
         ( SELECT NULL
             FROM WF_NOTIFICATION_ATTRIBUTES WNA_DEL
            WHERE WNA_DEL.NOTIFICATION_ID = WNO.NOTIFICATION_ID
              AND WNA_DEL.NAME            = 'DELETE_FLAG')
	  AND EXISTS
	  ( SELECT NULL
             FROM WF_NOTIFICATION_ATTRIBUTES WNA_DEL
            WHERE WNA_DEL.NOTIFICATION_ID = WNO.NOTIFICATION_ID
              AND WNA_DEL.NAME            = 'MESSAGE_TEXT')
	  AND EXISTS
	  ( SELECT NULL
             FROM WF_NOTIFICATION_ATTRIBUTES WNA_DEL
            WHERE WNA_DEL.NOTIFICATION_ID = WNO.NOTIFICATION_ID
              AND WNA_DEL.NAME            = 'SENDER'
              AND WNA_DEL.TEXT_VALUE IN (
	      SELECT USER_NAME
                     FROM   FND_USER
		)
	  );
  r_notification_receive c_notification_receive%ROWTYPE;

  CURSOR c_get_attribute_name (p_notification_id NUMBER) IS
    SELECT NAME
    FROM   WF_NOTIFICATION_ATTRIBUTES
    WHERE  NOTIFICATION_ID = p_notification_id;
  r_get_attribute_name c_get_attribute_name%ROWTYPE;

  l_return_value VARCHAR2(2000) := FND_API.G_RET_STS_SUCCESS;

BEGIN

  g_debug_level    := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_resource_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN

    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_resource_id
    , v_object_name => g_table_name
    , v_message     => 'Insert all Notification acc and Notification Attributes ACC records for user: '||
                       p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  IF JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
  /*** First insert the send records of a mobile user ***/
    OPEN  c_notification_sender ( p_resource_id );
    FETCH c_notification_sender INTO r_notification_sender;
    IF c_notification_sender%NOTFOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_resource_id
        , v_object_name => g_table_name
        , v_message     => 'Insert all Notification ACC: no send-records found for user: ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    ELSE
      WHILE c_notification_sender%FOUND LOOP
        CSL_WF_NOTIFICATIONS_ACC_PKG.Insert_Notification(r_notification_sender.notification_id);
        OPEN  c_get_attribute_name ( r_notification_sender.notification_id );
        FETCH c_get_attribute_name INTO r_get_attribute_name;
        IF c_get_attribute_name%NOTFOUND THEN
	  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
             ( v_object_id   => p_resource_id
             , v_object_name => g_table_name
             , v_message     => 'No Attributes records found for notification: ' ||
	                      r_notification_sender.notification_id
             , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
	  END IF;
        ELSE
          WHILE c_get_attribute_name%FOUND LOOP
            Insert_Notification_Attribute(r_notification_sender.notification_id,r_get_attribute_name.name);
            FETCH c_get_attribute_name INTO r_get_attribute_name;
          END LOOP;
          CLOSE c_get_attribute_name;
        END IF;
        FETCH c_notification_sender INTO r_notification_sender;
      END LOOP;
      CLOSE c_notification_sender;
      l_return_value := FND_API.G_RET_STS_SUCCESS;
    END IF;
    /*** Second insert all received records ***/
    OPEN  c_notification_receive ( p_resource_id );
    FETCH c_notification_receive INTO r_notification_receive;
    IF c_notification_receive%NOTFOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_resource_id
        , v_object_name => g_table_name
        , v_message     => 'No received records found for user : ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    ELSE
      WHILE c_notification_receive%FOUND LOOP
        CSL_WF_NOTIFICATIONS_ACC_PKG.Insert_Notification(r_notification_receive.notification_id);
        OPEN  c_get_attribute_name ( r_notification_receive.notification_id );
        FETCH c_get_attribute_name INTO r_get_attribute_name;
        IF c_get_attribute_name%NOTFOUND THEN
         IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
           jtm_message_log_pkg.Log_Msg
            ( v_object_id   => p_resource_id
            , v_object_name => g_table_name
            , v_message     => 'No received Notification Attributes records found for notification: '||
	                       r_notification_receive.notification_id
            , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
	 END IF;
        ELSE
          WHILE c_get_attribute_name%FOUND LOOP
            Insert_Notification_Attribute(r_notification_receive.notification_id,r_get_attribute_name.name);
            FETCH c_get_attribute_name INTO r_get_attribute_name;
          END LOOP;
          CLOSE c_get_attribute_name;
        END IF;
        FETCH c_notification_receive INTO r_notification_receive;
      END LOOP;
      CLOSE c_notification_receive;
    END IF;
    l_return_value := FND_API.G_RET_STS_SUCCESS;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_resource_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Insert_All_ACC_Records procedure for user: ' || p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := l_return_value;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  fnd_msg_pub.Add_Exc_Msg('CSL_CSP_REQ_HEADERS_ACC_PKG','Insert_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

END Insert_All_ACC_Records;

PROCEDURE Delete_All_ACC_Records(
                 p_resource_id     IN  NUMBER,
                 x_return_status   OUT NOCOPY VARCHAR2
                 )
IS

  CURSOR c_notification_sender (b_resource_id NUMBER) IS
    SELECT DISTINCT WNO.NOTIFICATION_ID,
                    USR.USER_ID
    FROM WF_NOTIFICATIONS            WNO,
         WF_NOTIFICATION_ATTRIBUTES  WNA,
         FND_USER                    USR,
         ASG_USER                    ADU
    WHERE WNO.NOTIFICATION_ID = WNA.NOTIFICATION_ID
      AND WNA.NAME            = 'SENDER'
      AND WNA.TEXT_VALUE      = USR.USER_NAME
      AND USR.USER_ID         = ADU.USER_ID
      AND ADU.RESOURCE_ID     = b_resource_id;
  r_notification_sender c_notification_sender%ROWTYPE;

  CURSOR c_notification_receive (b_resource_id NUMBER) IS
    SELECT DISTINCT WNO.NOTIFICATION_ID,
                    USR.USER_ID
    FROM WF_NOTIFICATIONS     WNO,
         FND_USER             USR,
         ASG_USER             ADU
    WHERE WNO.RECIPIENT_ROLE = USR.USER_NAME
      AND USR.USER_ID        = ADU.USER_ID
      AND ADU.RESOURCE_ID    = b_resource_id
      AND WNO.STATUS         = 'OPEN'
      AND NOT EXISTS
         ( SELECT NULL
             FROM WF_NOTIFICATION_ATTRIBUTES WNA_DEL
            WHERE WNA_DEL.NOTIFICATION_ID = WNO.NOTIFICATION_ID
              AND WNA_DEL.NAME            = 'DELETE_FLAG');
  r_notification_receive c_notification_receive%ROWTYPE;

  CURSOR c_get_attribute_name (p_notification_id NUMBER) IS
    SELECT NAME
    FROM   WF_NOTIFICATION_ATTRIBUTES
    WHERE  NOTIFICATION_ID = p_notification_id;
  r_get_attribute_name c_get_attribute_name%ROWTYPE;

  l_return_value VARCHAR2(2000) := FND_API.G_RET_STS_SUCCESS;

BEGIN
  /*Get the debug level*/
  g_debug_level    := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_resource_id
    , v_object_name => g_table_name
    , v_message     => 'Entering Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_resource_id
    , v_object_name => g_table_name
    , v_message     => 'Delete all Notification acc and Notification Attributes ACC records for user: '||
                        p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  IF JTM_HOOK_UTIL_PKG.isMobileFSresource( p_resource_id ) THEN
    /*** First delete the send records of a mobile user ***/
    OPEN  c_notification_sender ( p_resource_id );
    FETCH c_notification_sender INTO r_notification_sender;
    IF c_notification_sender%NOTFOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_resource_id
        , v_object_name => g_table_name
        , v_message     => 'No sent record found for user: ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    ELSE
      WHILE c_notification_sender%FOUND LOOP
        JTM_HOOK_UTIL_PKG.Delete_Acc
          ( p_publication_item_names => g_publication_item_name
          ,p_acc_table_name         => g_acc_table_name2
          ,p_pk1_name               => g_pk1_name
          ,p_pk1_num_value          => r_notification_sender.notification_id
          ,p_resource_id            => p_resource_id
          );
	/*Call CSL_FND_USER_ACC_PKG to delete the sender fnd_user from the acc table*/
        CSL_FND_USER_ACC_PKG.Delete_User(r_notification_sender.user_id , p_resource_id);

        OPEN  c_get_attribute_name ( r_notification_sender.notification_id );
        FETCH c_get_attribute_name INTO r_get_attribute_name;
        IF c_get_attribute_name%NOTFOUND THEN
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
            ( v_object_id   => p_resource_id
            , v_object_name => g_table_name
            , v_message     => 'No notification attributes found for notification: ' ||
   	                     r_notification_sender.notification_id
            , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
	  END IF;
        ELSE
          WHILE c_get_attribute_name%FOUND LOOP
            JTM_HOOK_UTIL_PKG.Delete_Acc
               ( p_publication_item_names => g_publication_item_name
              , p_acc_table_name         => g_acc_table_name
              , p_pk1_name               => g_pk1_name
              , p_pk1_num_value          => r_notification_sender.notification_id
              , p_pk2_name               => g_pk2_name
              , p_pk2_char_value         => r_get_attribute_name.name
              , p_resource_id            => p_resource_id
              );
            FETCH c_get_attribute_name INTO r_get_attribute_name;
          END LOOP;
          CLOSE c_get_attribute_name;
        END IF;
        FETCH c_notification_sender INTO r_notification_sender;
      END LOOP;
      CLOSE c_notification_sender;
      l_return_value := FND_API.G_RET_STS_SUCCESS;
    END IF;
    /*** Second Delete all received records ***/
    OPEN  c_notification_receive ( p_resource_id );
    FETCH c_notification_receive INTO r_notification_receive;
    IF c_notification_receive%NOTFOUND THEN
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_resource_id
        , v_object_name => g_table_name
        , v_message     => 'No received records found for user: ' || p_resource_id
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    ELSE
      WHILE c_notification_receive%FOUND LOOP
        JTM_HOOK_UTIL_PKG.Delete_Acc
          ( p_publication_item_names => g_publication_item_name
          , p_acc_table_name         => g_acc_table_name2
          , p_pk1_name               => g_pk1_name
          , p_pk1_num_value          => r_notification_receive.notification_id
          , p_resource_id            => p_resource_id
          );
	/*Delete the receiving user*/
        CSL_FND_USER_ACC_PKG.Delete_User(r_notification_receive.user_id , p_resource_id);

        OPEN  c_get_attribute_name ( r_notification_receive.notification_id );
        FETCH c_get_attribute_name INTO r_get_attribute_name;
        IF c_get_attribute_name%NOTFOUND THEN
          IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
            jtm_message_log_pkg.Log_Msg
            ( v_object_id   => p_resource_id
            , v_object_name => g_table_name
            , v_message     => 'No attributes found for notification ' ||
	                     r_notification_receive.notification_id
            , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
	  END IF;
        ELSE
          WHILE c_get_attribute_name%FOUND LOOP
            JTM_HOOK_UTIL_PKG.Delete_Acc
               ( p_publication_item_names => g_publication_item_name
              , p_acc_table_name         => g_acc_table_name
              , p_pk1_name               => g_pk1_name
              , p_pk1_num_value          => r_notification_receive.notification_id
              , p_pk2_name               => g_pk2_name
              , p_pk2_char_value         => r_get_attribute_name.name
              , p_resource_id            => p_resource_id
              );
            FETCH c_get_attribute_name INTO r_get_attribute_name;
          END LOOP;
          CLOSE c_get_attribute_name;
        END IF;
        FETCH c_notification_receive INTO r_notification_receive;
      END LOOP;
      CLOSE c_notification_receive;
      l_return_value := FND_API.G_RET_STS_SUCCESS;
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_resource_id
    , v_object_name => g_table_name
    , v_message     => 'Leaving Delete_All_ACC_Records procedure for user: ' || p_resource_id
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := l_return_value;
EXCEPTION WHEN OTHERS THEN
  /*** hook failed -> log error ***/
  jtm_message_log_pkg.Log_Msg
  ( v_object_id   => p_resource_id
  , v_object_name => g_table_name
  , v_message     => 'Error occurred in Delete_All_ACC_Records'||sqlerrm
  , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  fnd_msg_pub.Add_Exc_Msg('CSL_WF_NOTIFICATION_AT_ACC_PKG','Delete_All_ACC_Records',sqlerrm);
--  x_return_status := FND_API.G_RET_STS_ERROR;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

END Delete_All_ACC_Records;

END CSL_WF_NOTIFICATION_AT_ACC_PKG;

/
