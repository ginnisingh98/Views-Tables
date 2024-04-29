--------------------------------------------------------
--  DDL for Package Body CSL_NOTIFICATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_NOTIFICATIONS_PKG" AS
/* $Header: cslvnotb.pls 115.30 2002/11/08 14:00:23 asiegers ship $ */
error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_NOTIFICATIONS_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'WF_NOTIFICATIONS';
g_debug_level           NUMBER; -- debug level

CURSOR c_notification( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSL_WF_NOTIFICATIONS_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

CURSOR c_notification_attr( b_user_name VARCHAR2, b_tranid NUMBER, b_notification_id NUMBER) is
  SELECT *
  FROM  CSL_WF_NOTIFICATION_ATTR_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND   notification_id = b_notification_id;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_user_name     IN      VARCHAR2,
           p_record        IN      c_notification%ROWTYPE,
           p_error_msg     OUT NOCOPY     VARCHAR2,
           x_return_status IN OUT NOCOPY  VARCHAR2
         ) IS
  CURSOR c_fnd_user
    ( b_user_name fnd_user.user_name%TYPE
    )
  IS
    SELECT fu.user_name
    ,      fu.start_date
    ,      fu.end_date
    FROM   fnd_user fu
    WHERE  fu.user_name = b_user_name;

  r_fnd_user            c_fnd_user%ROWTYPE;

  CURSOR c_attr( b_notification_id NUMBER, b_name VARCHAR2 ) IS
   SELECT *
   FROM  WF_NOTIFICATION_ATTRIBUTES
   WHERE NOTIFICATION_ID = b_notification_id
   AND   NAME = b_name;

  r_attr c_attr%ROWTYPE;

  l_notification_id     NUMBER;
  l_msg_count           NUMBER;
  l_msg_data            VARCHAR2(240);

  l_receiver_found      BOOLEAN;
  l_valid_receiver      BOOLEAN;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  l_receiver_found := FALSE;
  l_valid_receiver := FALSE;
  -- Check if receiver exists
  OPEN c_fnd_user( b_user_name => p_record.recipient_role );
  FETCH c_fnd_user INTO r_fnd_user;
  IF c_fnd_user%FOUND THEN
    l_receiver_found := TRUE;
  ELSE
    l_receiver_found := FALSE;
  END IF;
  CLOSE c_fnd_user;

  IF l_receiver_found THEN
    -- Check if receiver is valid for the current date
    IF TRUNC(r_fnd_user.start_date) > TRUNC(SYSDATE) THEN
      -- The receiver is not yet valid
      x_return_status := FND_API.G_RET_STS_ERROR;
      p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
       (  p_message        => 'CSL_MAIL_RECEIVER_NOT_YET'
        , p_token_name1    => 'MAIL_RECEIVER'
        , p_token_value1   => p_record.recipient_role
	, p_token_name2    => 'START_DATE'
	, p_token_value2   => FND_DATE.Date_To_CharDT(r_fnd_user.start_date)
        );
    ELSIF TRUNC(r_fnd_user.end_date) < TRUNC(SYSDATE)
    THEN
      -- The receiver is no longer valid
      x_return_status := FND_API.G_RET_STS_ERROR;
      p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
       (  p_message        => 'CSL_MAIL_RECEIVER_OUTDATED'
        , p_token_name1    => 'MAIL_RECEIVER'
        , p_token_value1   => p_record.recipient_role
	, p_token_name2    => 'END_DATE'
	, p_token_value2   => FND_DATE.Date_To_CharDT(r_fnd_user.end_date)
        );
    ELSE
      -- The receiver is valid
      l_valid_receiver := TRUE;
    END IF;
  ELSE
    -- The receiver is unknown
    x_return_status := FND_API.G_RET_STS_ERROR;
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
     (  p_message        => 'CSL_MAIL_RECEIVER_UNKNOWN'
      , p_token_name1    => 'MAIL_RECEIVER'
      , p_token_value1   => p_record.recipient_role
     );
  END IF;

  IF l_valid_receiver  THEN
    -- Create a notification
    l_notification_id := WF_NOTIFICATION.Send
                           ( role     => p_record.recipient_role
                           , msg_type => 'CS_MSGS'     -- Service Message
                           , msg_name => 'FYI_MESSAGE' -- ...
                           );

    -- The WF_NOTIFICATION.Send API has also created the following attributes:
    -- COMMENT, MESSAGE_TEXT, OBJECT_FORM, OBJECT_ID, OBJECT_TYPE, PRIORITY,
    -- RESULT, SENDER.

    -- Set the 'PRIORITY' attribute for the priority of the notification
    WF_NOTIFICATION.SetAttrText
      ( l_notification_id
      , 'PRIORITY'
      , p_record.priority
      );

    -- Create a 'SUBJECT' attribute for the subject of the notification
    WF_NOTIFICATION.AddAttr
      ( nid   => l_notification_id
      , aname => 'SUBJECT'
      );

    -- Set the 'SUBJECT' attribute
    WF_NOTIFICATION.SetAttrText
      ( l_notification_id
      , 'SUBJECT'
      , p_record.subject
      );

   /*Get the attributes for this notification ( SENDER, MESSAGE_TEXT, READ_FLAG, DELETE_FLAG )*/
   /*Need to do this now because the record gets another PK*/
   FOR r_notification_attr IN c_notification_attr( p_record.clid$$cs
                                                 , p_record.tranid$$
						 , p_record.notification_id ) LOOP
     /*** First check if attri exists otherwise create it ***/
     OPEN c_attr( b_notification_id => l_notification_id
                , b_name            => r_notification_attr.name );
     FETCH c_attr INTO r_attr;
     IF c_attr%NOTFOUND THEN
       -- Create the attribute
       WF_NOTIFICATION.AddAttr
        ( nid   => l_notification_id
        , aname => r_notification_attr.name );
     END IF;
     CLOSE c_attr;
     WF_NOTIFICATION.SetAttrText
      ( l_notification_id
      , r_notification_attr.name
      , r_notification_attr.text_value
      );
   END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

  END IF;

  /*** Call Concurrent Program to push new Notification and Attributes to mobile ***/
  CSL_CONC_NOTIFICATION_PKG.RUN_CONCURRENT_NOTIFICATIONS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_INSERT:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_notification%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- No update possible ( is done in attributes ) so return success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_UPDATE:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_UPDATE', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id -- put PK column here
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_user_name     IN      VARCHAR2,
           p_record        IN      c_notification%ROWTYPE,
           p_error_msg     OUT NOCOPY     VARCHAR2,
           x_return_status IN OUT NOCOPY  VARCHAR2
         ) IS
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.notification_id
      , v_object_name => g_object_name
      , v_message     => 'Processing NOTIFICATION_ID = ' || p_record.notification_id || fnd_global.local_chr(10) ||
       'DMLTYPE = ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_user_name,
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSIF p_record.dmltype$$='U' THEN
    -- Process update
    APPLY_UPDATE
      (
       p_record,
       p_error_msg,
       x_return_status
     );
  ELSIF p_record.dmltype$$='D' THEN
    -- Process delete; not supported for this entity
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.notification_id
        , v_object_name => g_object_name
        , v_message     => 'Delete is not supported for this entity'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  ELSE
    -- invalid dml type
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
       jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.notification_id
      , v_object_name => g_object_name
      , v_message     => 'Invalid DML type: ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSL_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
  p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.notification_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item WF_NOTIFICATIONS
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
BEGIN
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** loop through WF_NOTIFICATION records in inqueue ***/
  FOR r_notification IN c_notification( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        p_user_name
      , r_notification
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> reject record because of changed pk ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_notification.notification_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_notification.seqno$$,
          r_notification.notification_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );

      IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
        /*** Reject successfull than reject matching attributes ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_notification.notification_id
          , v_object_name => g_object_name
          , v_message     => 'Record rejected, now rejecting attributes'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        FOR r_notification_attr IN c_notification_attr( p_user_name
                                                      , p_tranid
 					              , r_notification.notification_id ) LOOP
          CSL_SERVICEL_WRAPPER_PKG.REJECT_RECORD
           ( p_user_name,
             p_tranid,
             r_notification_attr.seqno$$,
             r_notification_attr.notification_id,
             g_object_name,
             'WF_NOTIFICATION_ATTR',
             l_error_msg,
             l_process_status
           );
	END LOOP;
      END IF;

      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_notification.notification_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_notification.seqno$$,
          r_notification.notification_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );
      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_notification.notification_id
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      ELSE
        /*** Yes -> Delete Attributes ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_notification.notification_id
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue succeeded, deleting attributes'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;

        FOR r_notification_attr IN c_notification_attr( p_user_name
                                                      , p_tranid
 					              , r_notification.notification_id ) LOOP

          CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_notification_attr.seqno$$,
            r_notification_attr.notification_id,
            g_object_name,
            'WF_NOTIFICATION_ATTR',
            l_error_msg,
            l_process_status
          );

	END LOOP;
      END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_notification.notification_id
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_notification.seqno$$
       , r_notification.notification_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_notification.notification_id
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    ELSE
      /*** Yes -> also defer attributes ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_notification.notification_id
        , v_object_name => g_object_name
        , v_message     => 'Defer record succeeded, deferring and rejecting Attribute record(s)'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
      FOR r_notification_attr IN c_notification_attr( p_user_name
                                                    , p_tranid
 					            , r_notification.notification_id ) LOOP

        CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
        (
          p_user_name,
          p_tranid,
          r_notification_attr.seqno$$,
          r_notification_attr.notification_id,
          g_object_name,
          'WF_NOTIFICATION_ATTR',
          l_error_msg,
          l_process_status
        );
       END LOOP;
      END IF;
    END IF;
  END LOOP;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in APPLY_CLIENT_CHANGES:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;

END CSL_NOTIFICATIONS_PKG;

/
