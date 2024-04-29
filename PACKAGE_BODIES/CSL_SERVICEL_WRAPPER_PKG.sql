--------------------------------------------------------
--  DDL for Package Body CSL_SERVICEL_WRAPPER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_SERVICEL_WRAPPER_PKG" AS
/* $Header: csllwrpb.pls 115.22 2003/08/27 07:34:13 vekrishn ship $ */

/*** Globals ***/
g_debug_level           NUMBER; -- debug level
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_SERVICEL_WRAPPER_PKG';

/***
  This function accepts a list of publication items and a publication item name and
  returns whether the item name was found within the item list.
  When the item name was found, it will be removed from the list.
***/
FUNCTION ITEM_EXISTS
        (
          p_pubitems_tbl IN OUT NOCOPY asg_apply.vc2_tbl_type,
          p_item_name    IN     VARCHAR2
        )
RETURN BOOLEAN IS
  l_index BINARY_INTEGER;
BEGIN

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering CSL_SERVICEL_WRAPPER_PKG.ITEM_EXISTS'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF p_pubitems_tbl.COUNT <= 0 THEN
    /*** no items in list -> item name not found ***/
    RETURN FALSE;
  END IF;
  FOR l_index IN p_pubitems_tbl.FIRST..p_pubitems_tbl.LAST LOOP
    IF p_pubitems_tbl.EXISTS( l_index ) THEN
      IF p_pubitems_tbl( l_index ) = p_item_name THEN
        /*** found item -> delete from array and return TRUE ***/
        p_pubitems_tbl.DELETE( l_index );

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => null
          , v_object_name => g_object_name
          , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.ITEM_EXISTS'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
        END IF;
        RETURN TRUE;
      END IF;
    END IF;
  END LOOP;
  /*** item name not found ***/

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.ITEM_EXISTS'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN FALSE;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in CSL_SERVICEL_WRAPPER_PKG.ITEM_EXISTS:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.ITEM_EXISTS'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN FALSE;
END ITEM_EXISTS;

/***
  This procedure is called by ASG_APPLY.APPLY_CLIENT_CHANGES if a list of dirty publication items
  has been retrieved for a user/tranid combination. This procedure gets called for both
  deferred and non-deferred publication items.
***/
PROCEDURE APPLY_DIRTY_PUBITEMS
         (
           p_user_name     IN     VARCHAR2,
           p_tranid        IN     NUMBER,
           p_pubitems_tbl  IN OUT NOCOPY asg_apply.vc2_tbl_type,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  l_index BINARY_INTEGER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering CSL_SERVICEL_WRAPPER_PKG.APPLY_DIRTY_PUBITEMS'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** call incident wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSL_CS_INCIDENTS_ALL_VL') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CSL_CS_INCIDENTS_ALL_VL'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CSL_CS_INCIDENTS_ALL_VL'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_SERVICE_REQUESTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call task wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSL_JTF_TASKS_VL') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CSL_JTF_TASKS_VL'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CSL_JTF_TASKS_VL'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_TASKS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call task assignment wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSL_JTF_TASK_ASSIGNMENTS') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CSL_JTF_TASK_ASSIGNMENTS'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CSL_JTF_TASK_ASSIGNMENTS'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_TASK_ASSIGNMENTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call debrief header wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSF_DEBRIEF_LINES')
     OR ITEM_EXISTS( p_pubitems_tbl, 'CSF_DEBRIEF_HEADERS')
  THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CSF_DEBRIEF_LINES'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CSF_DEBRIEF_LINES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_DEBRIEF_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call notes wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'JTF_NOTES_VL') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'JTF_NOTES_VL'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item JTF_NOTES_VL'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_NOTES_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call notifications wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'WF_NOTIFICATIONS') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'WF_NOTIFICATIONS'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item WF_NOTIFICATIONS'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_NOTIFICATIONS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;


  /*** call lobs wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSL_LOBS') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CSL_LOBS'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CSL_LOBS'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_LOBS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;


  /*** call notification attributes wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'WF_NOTIFICATION_ATTR') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'WF_NOTIFICATION_ATTR'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item WF_NOTIFICATION_ATTR'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_NOTIFICATION_ATTR_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call requirements wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CSP_REQUIREMENT_LINES') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CSP_REQUIREMENT_LINES'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CSP_REQUIREMENT_LINES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_REQUIREMENTS_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call counter wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CS_COUNTER_VALUES') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CS_COUNTER_VALUES'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CS_COUNTER_VALUES'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_COUNTER_VALUES_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call counter properties wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'CS_COUNTER_PROP_VALS') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'CS_COUNTER_PROP_VALS'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item CS_COUNTER_PROP_VALS'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_COUNTER_PROP_VALUES_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** call material transaction wrapper ***/
  IF ITEM_EXISTS( p_pubitems_tbl, 'MTL_MAT_TRANSACTIONS') THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => 'MTL_MAT_TRANSACTIONS'
      , v_object_name => g_object_name
      , v_message     => 'Calling wrapper for publication item MTL_MAT_TRANSACTIONS'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

      CSL_MATERIAL_TRANSACTION_PKG.APPLY_CLIENT_CHANGES
         (
           p_user_name,
           p_tranid,
           g_debug_level,
           x_return_status
         );
  END IF;

  /*** check if all dirty items got processed ***/
  IF p_pubitems_tbl.COUNT > 0 THEN
    /*** no -> print publication item names that are still dirty ***/
    FOR l_index IN p_pubitems_tbl.FIRST..p_pubitems_tbl.LAST LOOP
      IF p_pubitems_tbl.EXISTS( l_index) THEN
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
            jtm_message_log_pkg.Log_Msg
            ( v_object_id   => p_pubitems_tbl(l_index)
            , v_object_name => g_object_name
            , v_message     => 'No wrapper available for dirty publication item ' || p_pubitems_tbl(l_index)
            , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.APPLY_DIRTY_PUBITEMS'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in CSL_SERVICEL_WRAPPER_PKG.APPLY_DIRTY_PUBITEMS:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.APPLY_DIRTY_PUBITEMS'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_DIRTY_PUBITEMS;

/***
  This procedure is called by ASG_APPLY.PROCESS_UPLOAD when a publication item for publication SERVICEL
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will detect which publication items got dirty and will execute the wrapper
  procedures which will insert the data that came from mobile into the backend tables using public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name IN VARCHAR2,
           p_tranid    IN NUMBER
         ) IS
  l_pubitems_tbl  asg_apply.vc2_tbl_type;
  l_return_status VARCHAR2(1);
BEGIN
  g_debug_level := JTM_HOOK_UTIL_PKG.Get_Debug_Level;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering CSL_SERVICEL_WRAPPER_PKG.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Applying changes for user ' || p_user_name ||
                       ', tranid = ' || TO_CHAR( p_tranid )
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  /*** retrieve names of non-deferred dirty SERVICEL publication items ***/
/*** get_all_dirty and get_all_defered_pub_items is replaced by get_all_pub_items ***/
  asg_apply.get_all_pub_items(p_user_name,
    p_tranid,
    'SERVICEL',
    l_pubitems_tbl,
    l_return_status);

  /*** successfully retrieved item names? ***/
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_pubitems_tbl.COUNT = 0 THEN
    /*** No -> log that no items were retrieved ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'asg_apply.get_all_dirty_pub_items didn''t return any records'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  ELSE
    /*** yes -> process them ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'Found ' || l_pubitems_tbl.COUNT || ' dirty non-deferred publication item(s)'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    APPLY_DIRTY_PUBITEMS
         ( p_user_name
         , p_tranid
         , l_pubitems_tbl
         , l_return_status
         );
  END IF;

  /*** retrieve names of deferred dirty SERVICEL publication items ***/
/*  asg_apply.get_all_deferred_pub_items(p_user_name,
                                       p_tranid,
                                       'SERVICEL',
                                       l_pubitems_tbl,
                                       l_return_status);
*/

  /*** successfully retrieved item names? ***/
  IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_pubitems_tbl.COUNT = 0 THEN
    /*** No -> log that no items were retrieved ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'asg_apply.get_all_deferred_pub_items didn''t return any records'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;
  ELSE
    /*** yes -> process them ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => null
      , v_object_name => g_object_name
      , v_message     => 'Found ' || l_pubitems_tbl.COUNT || ' dirty deferred publication item(s)'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    APPLY_DIRTY_PUBITEMS
         ( p_user_name
         , p_tranid
         , l_pubitems_tbl
         , l_return_status
         );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
   jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in CSL_SERVICEL_WRAPPER_PKG.Apply_Client_Changes:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
END APPLY_CLIENT_CHANGES;

/***
  This function returns a translated error message string. If p_api_error is FALSE, it gets
  message with MESSAGE_NAME = p_message from FND_NEW_MESSAGES and replaces any tokens with
  the supplied token values. If p_api_error is TRUE, it just returns the api error in the
  FND_MSG_PUB message stack.
***/
FUNCTION GET_ERROR_MESSAGE_TEXT
         (
           p_api_error      IN BOOLEAN  --DEFAULT FALSE
         , p_message        IN FND_NEW_MESSAGES.MESSAGE_NAME%TYPE --DEFAULT NULL
         , p_token_name1    IN VARCHAR2 --DEFAULT NULL
         , p_token_value1   IN VARCHAR2 --DEFAULT NULL
         , p_token_name2    IN VARCHAR2 --DEFAULT NULL
         , p_token_value2   IN VARCHAR2 --DEFAULT NULL
         , p_token_name3    IN VARCHAR2 --DEFAULT NULL
         , p_token_value3   IN VARCHAR2 --DEFAULT NULL
         )
RETURN VARCHAR2 IS
  l_fnd_message VARCHAR2(4000);
  l_counter     NUMBER;
  l_msg_data    VARCHAR2(4000);
  l_msg_dummy   NUMBER;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering CSL_SERVICEL_WRAPPER_PKG.Get_error_message_text'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** Is this an API error? ***/
  IF NOT p_api_error THEN
    /*** no -> retrieve error message p_message and replace tokens ***/
    FND_MESSAGE.Set_Name
      ( application => 'CSL'
      , name        => p_message
      );
    IF p_token_name1 IS NOT NULL
    THEN
     FND_MESSAGE.Set_Token
       ( token => p_token_name1
       , value => p_token_value1
       );
    END IF;
    IF p_token_name2 IS NOT NULL
    THEN
      FND_MESSAGE.Set_Token
        ( token => p_token_name2
        , value => p_token_value2
        );
    END IF;
    IF p_token_name3 IS NOT NULL
    THEN
     FND_MESSAGE.Set_Token
       ( token => p_token_name3
       , value => p_token_value3
       );
    END IF;

    l_fnd_message := FND_MESSAGE.Get;
  ELSE
    /*** API error -> retrieve error from message stack ***/
    IF FND_MSG_PUB.Count_Msg > 0 THEN
      FND_MSG_PUB.Get
        ( p_msg_index     => 1
        , p_encoded       => FND_API.G_FALSE
        , p_data          => l_msg_data
        , p_msg_index_out => l_msg_dummy
        );
      l_fnd_message := l_msg_data;
      FOR l_counter
      IN 2 .. FND_MSG_PUB.Count_Msg
      LOOP
        FND_MSG_PUB.Get
          ( p_msg_index     => l_counter
          , p_encoded       => FND_API.G_FALSE
          , p_data          => l_msg_data
          , p_msg_index_out => l_msg_dummy
          );
        l_fnd_message := l_fnd_message || FND_GLOBAL.Newline || l_msg_data;
      END LOOP;
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.Get_error_message_text'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  RETURN l_fnd_message;
EXCEPTION WHEN OTHERS THEN

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in CSL_SERVICEL_WRAPPER_PKG.Get_error_message_text:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_SERVICEL_WRAPPER_PKG.Get_error_message_text'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_fnd_message;
END GET_ERROR_MESSAGE_TEXT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure when a record was successfully
  applied and needs to be deleted from the in-queue.
***/
PROCEDURE DELETE_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     OUT NOCOPY VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Entering ' || g_object_name || '.DELETE_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  asg_apply.delete_row(p_user_name,
                       p_tranid,
                       p_pub_name,
                       p_seqno,
                       x_return_status);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** error occurred ***/
    fnd_msg_pub.Add_Exc_Msg( g_object_name, 'DELETE_RECORD', 'Unknown error');
    p_error_msg := GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Leaving ' || g_object_name || '.DELETE_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Exception occurred in DELETE_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'DELETE_RECORD', sqlerrm);
  p_error_msg := GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Leaving ' || g_object_name || '.DELETE_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  x_return_status := FND_API.G_RET_STS_ERROR;
END DELETE_RECORD;

/***
  This procedure is called by APPLY_CLIENT_CHANGES wrapper procedure
  when a record failed to be processed and needs to be deferred and rejected from mobile.
***/
PROCEDURE DEFER_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
	   x_return_status IN OUT NOCOPY VARCHAR2,
           p_dml_type      IN VARCHAR2 --DEFAULT 'I'
         ) IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Entering ' || g_object_name || '.DEFER_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  asg_defer.defer_row(p_user_name,
                      p_tranid,
                      p_pub_name,
                      p_seqno,
                      p_error_msg,
                      x_return_status);
  /*** check if defer was successfull ***/
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** no -> log and return error  ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_pk
      , v_object_name => p_object_name
      , v_message     => 'asg_defer.defer_row failed:' || fnd_global.local_chr(10) || p_error_msg
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;

    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_pk
      , v_object_name => p_object_name
      , v_message     => 'Leaving ' || g_object_name || '.DEFER_RECORD'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    RETURN;
  END IF;

  /*** defer successful -> reject record except for updates ***/
  IF p_dml_type = 'I' THEN
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_pk
      , v_object_name => p_object_name
      , v_message     => 'Rejecting record'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
    END IF;

    asg_defer.reject_row(p_user_name,
                         p_tranid,
                         p_pub_name,
                         p_seqno,
                         p_error_msg,
                         x_return_status);
    /*** check if reject was successfull ***/
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** no -> log error  ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_pk
        , v_object_name => p_object_name
        , v_message     => 'asg_defer.reject_row failed:' || fnd_global.local_chr(10) || p_error_msg
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
      END IF;
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Leaving ' || g_object_name || '.DEFER_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Exception occurred in ' || g_object_name || '.DEFER_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Leaving ' || g_object_name || '.DEFER_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END DEFER_RECORD;

/***
 This procedure gets called when a record needs to be rejected when e.g. the api provides its own pk
***/
PROCEDURE REJECT_RECORD
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_seqno         IN NUMBER,
           p_pk            IN VARCHAR2,
           p_object_name   IN VARCHAR2,
           p_pub_name      IN VARCHAR2,
           p_error_msg     IN VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         )IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Entering ' || g_object_name || '.REJECT_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;


  asg_defer.reject_row(p_user_name,
                       p_tranid,
                       p_pub_name,
                       p_seqno,
                       p_error_msg,
                       x_return_status);

  /*** check if reject was successfull ***/
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** no -> log error  ***/
    IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_pk
      , v_object_name => p_object_name
      , v_message     => 'asg_defer.reject_row failed:' || fnd_global.local_chr(10) || p_error_msg
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Leaving ' || g_object_name || '.REJECT_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Exception occurred in ' || g_object_name || '.REJECT_RECORD:' || fnd_global.local_chr(10) || sqlerrm
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_pk
    , v_object_name => p_object_name
    , v_message     => 'Leaving ' || g_object_name || '.REJECT_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END REJECT_RECORD;

/***
 This procedure gets called when a user gets created
***/
PROCEDURE POPULATE_ACCESS_RECORDS ( P_USER_ID IN NUMBER )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
 CURSOR c_user( b_user_id NUMBER ) IS
  SELECT RESOURCE_ID
  FROM ASG_USER
  WHERE USER_ID = b_user_id;
 r_user c_user%ROWTYPE;
 x_status VARCHAR2(30);
BEGIN
 OPEN c_user( P_USER_ID );
 FETCH c_user INTO r_user;
 IF c_user%FOUND THEN
  CSL_USER_PKG.CREATE_USER( P_RESOURCE_ID   => r_user.RESOURCE_ID
                          , X_RETURN_STATUS => x_status);

 END IF;
 CLOSE c_user;

 /*** if create_user returned error then raise exception ***/
 IF x_status <> FND_API.G_RET_STS_SUCCESS THEN
   ROLLBACK;
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;
END POPULATE_ACCESS_RECORDS;

/***
 This procedure gets called when a user gets deleted
***/
PROCEDURE DELETE_ACCESS_RECORDS ( P_USER_ID IN NUMBER )
IS
PRAGMA AUTONOMOUS_TRANSACTION;
 CURSOR c_user( b_user_id NUMBER ) IS
  SELECT RESOURCE_ID
  FROM ASG_USER
  WHERE USER_ID = b_user_id;
 r_user c_user%ROWTYPE;
 x_status VARCHAR2(30);
BEGIN
 OPEN c_user( P_USER_ID );
 FETCH c_user INTO r_user;
 IF c_user%FOUND THEN
  CSL_USER_PKG.DELETE_USER( P_RESOURCE_ID   => r_user.RESOURCE_ID
                          , X_RETURN_STATUS => x_status);

 END IF;
 CLOSE c_user;

 /*** if delete user returned error then raise exception ***/
 IF x_status <> FND_API.G_RET_STS_SUCCESS THEN
   ROLLBACK;
   RAISE FND_API.G_EXC_ERROR;
 END IF;

 COMMIT;
END DELETE_ACCESS_RECORDS;

FUNCTION AUTONOMOUS_MARK_DIRTY
                       (
                        p_pub_item     IN VARCHAR2,
                        p_accessid     IN NUMBER,
                        p_resourceid   IN NUMBER,
                        p_dml          IN CHAR,
                        p_timestamp    IN DATE
                       )
RETURN BOOLEAN IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_rc BOOLEAN;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.AUTONOMOUS_MARK_DIRTY'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
  l_rc := asg_download.markDirty(
                                 P_PUB_ITEM     => p_pub_item,
                                 P_ACCESSID     => p_accessid,
                                 P_RESOURCEID   => p_resourceid,
                                 P_DML          => p_dml,
                                 P_TIMESTAMP    => p_timestamp
                                 );
  COMMIT;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.AUTONOMOUS_MARK_DIRTY'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  RETURN l_rc;
EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => null
    , v_object_name => g_object_name
    , v_message     => 'Exception occurred in AUTONOMOUS_MARK_DIRTY.'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR);
  END IF;
  COMMIT;
  RETURN FALSE;
END AUTONOMOUS_MARK_DIRTY;


 FUNCTION detect_conflict(p_user_name IN VARCHAR2) RETURN VARCHAR2 IS
 BEGIN

   jtm_message_log_pkg.Log_Msg
   ( v_object_id   => null
     , v_object_name => g_object_name
     , v_message     => 'Entering DETECT_CONFLICT : User '||p_user_name
     , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL
   );

   RETURN 'Y' ;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'Y';
 END;


 FUNCTION CONFLICT_RESOLUTION_HANDLER (
       p_user_name IN VARCHAR2,
       p_tran_id IN NUMBER,
       p_sequence IN NUMBER) RETURN VARCHAR2 IS

   l_profile_value VARCHAR2(30) ;

 BEGIN

   jtm_message_log_pkg.Log_Msg
    ( v_object_id     => null
      , v_object_name => g_object_name
      , v_message     => 'Entering CONFLICT_RESOLUTION_HANDLER : User '
                         ||p_user_name
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

   l_profile_value := fnd_profile.value('JTM_APPL_CONFLICT_RULE');
   IF l_profile_value = 'SERVER_WINS' THEN
      RETURN 'S' ;
   ELSE
      RETURN 'C' ;
   END IF ;

 EXCEPTION
   WHEN OTHERS THEN
     RETURN 'C';
 END ;

END CSL_SERVICEL_WRAPPER_PKG;

/
