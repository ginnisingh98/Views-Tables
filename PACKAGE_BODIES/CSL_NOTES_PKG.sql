--------------------------------------------------------
--  DDL for Package Body CSL_NOTES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_NOTES_PKG" AS
/* $Header: cslvntsb.pls 115.19 2002/11/08 14:00:18 asiegers ship $ */

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_NOTES_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'JTF_NOTES_VL';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_note( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSL_JTF_NOTES_VL_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_note%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
 l_note_id   NUMBER;
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(240);
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Create a note
  jtf_notes_pub.Create_note
    ( p_api_version        => 1.0
    , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    , p_init_msg_list      => FND_API.G_TRUE
    , p_commit             => FND_API.G_FALSE
    , x_return_status      => x_return_status
    , x_msg_count          => l_msg_count
    , x_msg_data           => l_msg_data
    , p_jtf_note_id        => p_record.jtf_note_id
    , p_parent_note_id     => p_record.parent_note_id
    , p_source_object_id   => p_record.source_object_id
    , p_source_object_code => p_record.source_object_code
    , p_notes              => p_record.notes
    , p_note_status        => p_record.note_status
    , p_note_type          => p_record.note_type
    , p_entered_by         => p_record.entered_by
    , p_entered_date       => p_record.entered_date
    , p_created_by         => p_record.entered_by
    , p_creation_date      => SYSDATE
    , p_last_updated_by    => FND_GLOBAL.USER_ID
    , p_last_update_date   => SYSDATE
    , p_last_update_login  => FND_GLOBAL.LOGIN_ID
    , x_jtf_note_id        => l_note_id
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
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
    ( v_object_id   => p_record.jtf_note_id
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
           p_record        IN c_note%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
 l_msg_count NUMBER;
 l_msg_data  VARCHAR2(240);
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

   -- Update the note
  jtf_notes_pub.Update_note
    ( p_api_version        => 1.0
    , p_validation_level   => FND_API.G_VALID_LEVEL_FULL
    , p_init_msg_list      => FND_API.G_TRUE
    , p_commit             => FND_API.G_FALSE
    , x_return_status      => x_return_status
    , x_msg_count          => l_msg_count
    , x_msg_data           => l_msg_data
    , p_jtf_note_id        => p_record.jtf_note_id
    , p_notes              => p_record.notes
    , p_note_status        => p_record.note_status
    , p_note_type          => p_record.note_type
    , p_entered_by         => p_record.entered_by
    , p_last_updated_by    => FND_GLOBAL.USER_ID
    , p_last_update_date   => SYSDATE
    , p_last_update_login  => FND_GLOBAL.LOGIN_ID
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
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
    ( v_object_id   => p_record.jtf_note_id
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
           p_record        IN     c_note%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.jtf_note_id
      , v_object_name => g_object_name
      , v_message     => 'Processing JTF_NOTE_ID = ' || p_record.jtf_note_id || fnd_global.local_chr(10) ||
       'DMLTYPE = ' || p_record.dmltype$$
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
  END IF;

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
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
        ( v_object_id   => p_record.jtf_note_id
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
      ( v_object_id   => p_record.jtf_note_id
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
    ( v_object_id   => p_record.jtf_note_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.jtf_note_id
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
    ( v_object_id   => p_record.jtf_note_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item JTF_NOTES_VL
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

  /*** loop through jtf_notes_vl records in inqueue ***/
  FOR r_note IN c_note( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_note
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_note.jtf_note_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_note.seqno$$,
          r_note.jtf_note_id,
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
          ( v_object_id   => r_note.jtf_note_id
          , v_object_name => g_object_name
          , v_message     => 'Deleting from inqueue failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed -> defer and reject record ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_note.jtf_note_id
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_note.seqno$$
       , r_note.jtf_note_id
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
          ( v_object_id   => r_note.jtf_note_id
          , v_object_name => g_object_name
          , v_message     => 'Defer record failed, rolling back to savepoint'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        ROLLBACK TO save_rec;
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

END CSL_NOTES_PKG;

/
