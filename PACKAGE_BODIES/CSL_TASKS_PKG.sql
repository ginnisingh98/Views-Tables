--------------------------------------------------------
--  DDL for Package Body CSL_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_TASKS_PKG" AS
/* $Header: cslvtskb.pls 115.32 2003/11/18 10:01:52 vekrishn ship $ */

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_TASKS_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSL_JTF_TASKS_VL';
g_debug_level           NUMBER; -- debug level

CURSOR c_task( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  csl_jtf_tasks_vl_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_task%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(240);
  l_task_id   jtf_tasks_b.task_id%type;
BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Entering CSL_TASKS_PKG.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  JTF_TASKS_PUB.create_task (
      p_api_version             => 1.0,
      p_init_msg_list           => FND_API.g_true,
      p_commit                  => fnd_api.g_false,
      p_task_id                 => p_record.TASK_ID,
      p_task_name               => p_record.TASK_NAME,
      p_task_type_id            => p_record.TASK_TYPE_ID,
      p_description             => p_record.DESCRIPTION,
      p_task_status_id          => p_record.TASK_STATUS_ID,
      p_task_priority_id        => p_record.TASK_PRIORITY_ID,
      p_owner_type_code         => 'RS_EMPLOYEE',
      p_owner_id                => JTM_HOOK_UTIL_PKG.get_resource_id( p_record.clid$$cs ),
      p_customer_id             => p_record.CUSTOMER_ID,
      p_planned_start_date      => p_record.PLANNED_START_DATE,
      p_planned_end_date        => p_record.PLANNED_END_DATE,
      p_scheduled_start_date    => p_record.SCHEDULED_START_DATE,
      p_scheduled_end_date      => p_record.SCHEDULED_END_DATE,
      p_source_object_type_code => p_record.SOURCE_OBJECT_TYPE_CODE,
      p_source_object_id        => p_record.SOURCE_OBJECT_ID,
      p_source_object_name      => p_record.SOURCE_OBJECT_NAME,
      p_planned_effort          => p_record.PLANNED_EFFORT,
      p_planned_effort_uom      => p_record.PLANNED_EFFORT_UOM,
      p_private_flag            => p_record.PRIVATE_FLAG,
      p_attribute1                => p_record.attribute1,
      p_attribute2                => p_record.attribute2,
      p_attribute3                => p_record.attribute3,
      p_attribute4                => p_record.attribute4,
      p_attribute5                => p_record.attribute5,
      p_attribute6                => p_record.attribute6,
      p_attribute7                => p_record.attribute7,
      p_attribute8                => p_record.attribute8,
      p_attribute9                => p_record.attribute9,
      p_attribute10               => p_record.attribute10,
      p_attribute11               => p_record.attribute11,
      p_attribute12               => p_record.attribute12,
      p_attribute13               => p_record.attribute13,
      p_attribute14               => p_record.attribute14,
      p_attribute15               => p_record.attribute15,
      p_attribute_category        => p_record.attribute_category ,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data,
      x_task_id                 => l_task_id
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
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_TASKS_PKG.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_id
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
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_TASKS_PKG.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_task%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(240);

  CURSOR c_task ( b_task_id NUMBER ) IS
    SELECT object_version_number
    FROM   jtf_tasks_b
    WHERE  task_id = b_task_id;
  r_task c_task%ROWTYPE;

  cursor c_last_update_date
     ( b_task_id NUMBER
	 )
  is
    SELECT LAST_UPDATE_DATE
	from jtf_tasks_b
	where task_id = b_task_id;

  r_last_update_date     c_last_update_date%ROWTYPE;

  l_profile_value     VARCHAR2(240);

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Entering CSL_TASKS_PKG.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Check for Stale data
  l_profile_value := fnd_profile.value('JTM_APPL_CONFLICT_RULE');
  if l_profile_value = 'SERVER_WINS' AND
  ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_object_name, p_record.seqno$$) <> FND_API.G_TRUE  then
    open c_last_update_date(b_task_id => p_record.task_id);
    fetch c_last_update_date into r_last_update_date;
    if c_last_update_date%found then
      if r_last_update_date.last_update_date <> p_record.last_update_date then
        close c_last_update_date;
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_record.task_id
          , v_object_name => g_object_name
          , v_message     => 'Record has stale data'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        fnd_message.set_name
          ( 'JTM'
          , 'JTM_STALE_DATA'
          );
        fnd_msg_pub.add;
        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_record.task_id
          , v_object_name => g_object_name
          , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
        END IF;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        return;
      end if;
    else
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.task_id
        , v_object_name => g_object_name
        , v_message     => 'No record found in Apps Database.'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    end if;
    close c_last_update_date;
  end if;

  -- get object version from task record so client updates succeed even when record was updated
  -- on server side (CLIENT_WINS)
  OPEN c_task( p_record.task_id );
  FETCH c_task INTO r_task;
  CLOSE c_task;

  -- Update the task.
  JTF_TASKS_PUB.Update_Task (
      p_api_version             => 1.0,
      p_init_msg_list           => FND_API.G_TRUE,
      p_commit                  => FND_API.G_FALSE,
      p_task_id                 => p_record.TASK_ID,
      p_object_version_number   => r_task.object_version_number,
      p_planned_start_date      => p_record.PLANNED_START_DATE,
      p_planned_end_date        => p_record.PLANNED_END_DATE,
      p_scheduled_start_date    => p_record.SCHEDULED_START_DATE,
      p_scheduled_end_date      => p_record.SCHEDULED_END_DATE,
      p_task_priority_id        =>
NVL(p_record.TASK_PRIORITY_ID,FND_API.G_MISS_NUM),
      p_planned_effort          => p_record.PLANNED_EFFORT,
      p_planned_effort_uom      => p_record.PLANNED_EFFORT_UOM,
      p_attribute1                => p_record.attribute1,
      p_attribute2                => p_record.attribute2,
      p_attribute3                => p_record.attribute3,
      p_attribute4                => p_record.attribute4,
      p_attribute5                => p_record.attribute5,
      p_attribute6                => p_record.attribute6,
      p_attribute7                => p_record.attribute7,
      p_attribute8                => p_record.attribute8,
      p_attribute9                => p_record.attribute9,
      p_attribute10               => p_record.attribute10,
      p_attribute11               => p_record.attribute11,
      p_attribute12               => p_record.attribute12,
      p_attribute13               => p_record.attribute13,
      p_attribute14               => p_record.attribute14,
      p_attribute15               => p_record.attribute15,
      p_attribute_category        => p_record.attribute_category ,
      -- ER 3211017
      p_task_type_id            => p_record.TASK_TYPE_ID,
      x_return_status           => x_return_status,
      x_msg_count               => l_msg_count,
      x_msg_data                => l_msg_data
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
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_TASKS_PKG.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_id
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
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_TASKS_PKG.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UPDATE;

/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_task%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  l_rc                BOOLEAN;
  l_access_id         NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Entering CSL_TASKS_PKG.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.task_id
      , v_object_name => g_object_name
      , v_message     => 'Processing task_id = ' || p_record.task_id || fnd_global.local_chr(10) ||
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
        ( v_object_id   => p_record.task_id
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
      ( v_object_id   => p_record.task_id
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

  IF p_record.dmltype$$ = 'U' AND x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    l_access_id := jtm_hook_util_pkg.get_acc_id(
                                    p_acc_table_name => 'CSL_JTF_TASKS_ACC',
                                    p_resource_id    => JTM_HOOK_UTIL_PKG.get_resource_id( p_record.clid$$cs ),
                                    p_pk1_name       => 'TASK_ID',
                                    p_pk1_num_value  => p_record.TASK_ID
                                               );
    l_rc := CSL_SERVICEL_WRAPPER_PKG.AUTONOMOUS_MARK_DIRTY(
                                    P_PUB_ITEM     => g_pub_name,
                                    P_ACCESSID     => l_access_id,
                                    P_RESOURCEID   => JTM_HOOK_UTIL_PKG.get_resource_id( p_record.clid$$cs ),
                                    P_DML          => 'U',
                                    P_TIMESTAMP    => sysdate
                                                          );
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_TASKS_PKG.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_id
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
    ( v_object_id   => p_record.task_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving CSL_TASKS_PKG.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item CSL_JTF_TASKS_VL
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
    , v_message     => 'Entering CSL_TASKS_PKG.Apply_Client_Changes'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  /*** loop through task records in inqueue ***/
  FOR r_task IN c_task( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_task
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_task.task_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_task.seqno$$,
          r_task.task_id,
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
          ( v_object_id   => r_task.task_id
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
        ( v_object_id   => r_task.task_id
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_task.seqno$$
       , r_task.task_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_task.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_task.task_id
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
    , v_message     => 'Leaving CSL_TASKS_PKG.Apply_Client_Changes'
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

END CSL_TASKS_PKG;

/
