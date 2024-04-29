--------------------------------------------------------
--  DDL for Package Body CSL_TASK_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSL_TASK_ASSIGNMENTS_PKG" AS
/* $Header: cslvtasb.pls 120.1 2005/10/12 00:21:29 hhaugeru noship $ */

error EXCEPTION;

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSL_TASK_ASSIGNMENTS_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSL_JTF_TASK_ASSIGNMENTS';
g_debug_level           NUMBER; -- debug level

CURSOR c_task_ass( b_user_name VARCHAR2, b_tranid NUMBER) is
  SELECT *
  FROM  CSL_JTF_TASK_ASSIGNMENTS_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_task_ass%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

  CURSOR c_task_assignment
    ( b_task_assignment_id number
    )
  IS
    SELECT jta.assignment_status_id
    ,      jta.object_version_number
    FROM   jtf_task_assignments jta
    WHERE  jta.task_assignment_id = b_task_assignment_id;

  r_task_assignment           c_task_assignment%rowtype;

  l_task_assignment_id NUMBER;

  l_msg_count          NUMBER;
  l_msg_data           VARCHAR2(240);

  l_assignment_obj_version_nr NUMBER;
  l_assignment_status_id      NUMBER;
  l_task_obj_version_nr       NUMBER;
  l_task_status_id            NUMBER;
  l_task_status_name          VARCHAR2(30);

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Create a Task Assignment
  JTF_TASK_ASSIGNMENTS_PUB.create_task_assignment (
    p_api_version          => 1.0,
    p_init_msg_list        => FND_API.G_TRUE,
    p_commit               => FND_API.G_FALSE,
    p_task_assignment_id   => p_record.TASK_ASSIGNMENT_ID,
    p_task_id              => p_record.TASK_ID,
    p_resource_type_code   => 'RS_EMPLOYEE',
    p_resource_id          => JTM_HOOK_UTIL_PKG.get_resource_id(p_record.clid$$cs),
    p_assignment_status_id => p_record.ASSIGNMENT_STATUS_ID,
    x_return_status        => x_return_status,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data,
    x_task_assignment_id   => l_task_assignment_id
  );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
  END IF;


  -- Retrieve the task_id and the current object version number
  -- from the known task_assignment_id.
  OPEN c_task_assignment
    ( b_task_assignment_id => p_record.task_assignment_id
    );
  FETCH c_task_assignment
  INTO r_task_assignment;
  IF c_task_assignment%NOTFOUND THEN
    CLOSE c_task_assignment;
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.task_assignment_id
      , v_object_name => g_object_name
      , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    -- Bail out.
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;    --TODO ADD error msg.
  END IF;

  l_assignment_obj_version_nr := r_task_assignment.object_version_number;
  l_assignment_status_id      := r_task_assignment.assignment_status_id;

  CLOSE c_task_assignment;


  csf_task_assignments_pub.update_assignment_status
      ( p_api_version                => 1.0
      , p_init_msg_list              => FND_API.G_TRUE
      , p_commit                     => FND_API.G_FALSE
      , x_return_status              => x_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_task_assignment_id         => p_record.task_assignment_id
      , p_assignment_status_id       => l_assignment_status_id
      , p_object_version_number      => l_assignment_obj_version_nr
      , p_update_task                => 'T'
      , x_task_object_version_number => l_task_obj_version_nr
      , x_task_status_id             => l_task_status_id
      );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** exception occurred in API -> return errmsg ***/
      p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
        (
          p_api_error      => TRUE
        );
      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.task_assignment_id
        , v_object_name => g_object_name
        , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;
      RETURN;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_INSERT'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
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
    ( v_object_id   => p_record.task_assignment_id
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
           p_record        IN c_task_ass%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  CURSOR c_task_assignment
    ( b_task_assignment_id number
    )
  IS
    SELECT jta.assignment_status_id
    ,      jta.object_version_number
    FROM   jtf_task_assignments jta
    WHERE  jta.task_assignment_id = b_task_assignment_id;

  r_task_assignment           c_task_assignment%rowtype;

  cursor c_last_update_date
     ( b_task_assignment_id NUMBER
	 )
  is
    SELECT LAST_UPDATE_DATE, LAST_UPDATED_BY
	from JTF_TASK_ASSIGNMENTS
	where task_assignment_id = b_task_assignment_id;

  r_last_update_date     c_last_update_date%ROWTYPE;

  l_msg_count                 NUMBER;
  l_msg_data                  VARCHAR2(240);

  l_assignment_obj_version_nr NUMBER;
  l_assignment_status_id      NUMBER;
  l_task_obj_version_nr       NUMBER;
  l_task_status_id            NUMBER;
  l_task_status_name          VARCHAR2(30);
  l_profile_value             VARCHAR2(240);
  l_task_type_id              NUMBER;

BEGIN
  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  -- Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Check for Stale data
  l_profile_value := fnd_profile.value('JTM_APPL_CONFLICT_RULE');
  if l_profile_value = 'SERVER_WINS' AND
  ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_object_name, p_record.seqno$$) <> FND_API.G_TRUE
  then
    open c_last_update_date(b_task_assignment_id => p_record.task_assignment_id);
    fetch c_last_update_date into r_last_update_date;
    if c_last_update_date%found then
      if r_last_update_date.last_updated_by <> asg_base.get_user_id( p_record.clid$$cs ) AND r_last_update_date.last_update_date <> p_record.last_update_date then
        close c_last_update_date;
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_record.task_assignment_id
          , v_object_name => g_object_name
          , v_message     => 'Record is stale data'
          , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
        END IF;
        fnd_message.set_name
          ( 'JTM'
          , 'JTM_STALE_DATA'
          );
        fnd_msg_pub.add;

        IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => p_record.task_assignment_id
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
        ( v_object_id   => p_record.task_assignment_id
        , v_object_name => g_object_name
        , v_message     => 'No record found in Apps Database.'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;
    end if;
    close c_last_update_date;
  end if;

  -- Retrieve the task_id and the current object version number
  -- from the known task_assignment_id.
  OPEN c_task_assignment
    ( b_task_assignment_id => p_record.task_assignment_id
    );
  FETCH c_task_assignment
  INTO r_task_assignment;
  IF c_task_assignment%NOTFOUND THEN
    CLOSE c_task_assignment;
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.task_assignment_id
      , v_object_name => g_object_name
      , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    -- Bail out.
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;    --TODO ADD error msg.
  END IF;

  l_assignment_obj_version_nr := r_task_assignment.object_version_number;
  l_assignment_status_id      := r_task_assignment.assignment_status_id;

  CLOSE c_task_assignment;

  -- See "status update"-doc at the beginning of the procedure!
  -- We do not update the status of the task assignment here.
  -- A special API for that exists.

  -- Call task assignments public api
  JTF_TASK_ASSIGNMENTS_PUB.Update_Task_Assignment
    ( p_api_version               => 1.0
    , p_task_assignment_id        => p_record.task_assignment_id
    , p_object_version_number     => l_assignment_obj_version_nr
    , p_task_id                   => p_record.task_id
    , p_resource_type_code        => p_record.resource_type_code
    , p_resource_id               => p_record.resource_id
    , p_resource_territory_id     => FND_API.G_MISS_NUM
    , p_actual_start_date         => p_record.actual_start_date
    , p_actual_end_date           => p_record.actual_end_date
    , p_sched_travel_distance     => p_record.sched_travel_distance
    , p_sched_travel_duration     => p_record.sched_travel_duration
    , p_sched_travel_duration_uom => p_record.sched_travel_duration_uom
    , p_shift_construct_id        => FND_API.G_MISS_NUM
    , p_attribute1                => p_record.attribute1
    , p_attribute2                => p_record.attribute2
    , p_attribute3                => p_record.attribute3
    , p_attribute4                => p_record.attribute4
    , p_attribute5                => p_record.attribute5
    , p_attribute6                => p_record.attribute6
    , p_attribute7                => p_record.attribute7
    , p_attribute8                => p_record.attribute8
    , p_attribute9                => p_record.attribute9
    , p_attribute10               => p_record.attribute10
    , p_attribute11               => p_record.attribute11
    , p_attribute12               => p_record.attribute12
    , p_attribute13               => p_record.attribute13
    , p_attribute14               => p_record.attribute14
    , p_attribute15               => p_record.attribute15
    , p_attribute_category        => p_record.attribute_category
    , x_return_status             => x_return_status
    , x_msg_count                 => l_msg_count
    , x_msg_data                  => l_msg_data
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    /*** exception occurred in API -> return errmsg ***/
    p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_api_error      => TRUE
      );
    IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.task_assignment_id
      , v_object_name => g_object_name
      , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
    END IF;
    RETURN;
  END IF;

  -- Do a check before calling the API that the status has changed.
  -- If it hasn't then do nothing.
  IF l_assignment_status_id <> p_record.assignment_status_id
  THEN
    -- Validation is not a good thing for this particular API-call: as
    -- the laptop application does the check for state changes, it is not
    -- necessary to redo them here. Even worse, a state change in two steps
    -- A -> B and B -> C may be OK for laptop application, but if the
    -- intermediate step is not sent to CRM, the API will see A -> C and
    -- refuse it.
    -- To allow for A -> C no validation is done here. This is not a problem
    -- as the laptop application does the check if going from a -> C in 2
    -- steps is valid.

    csf_task_assignments_pub.update_assignment_status
      ( p_api_version                => 1.0
      , p_init_msg_list              => FND_API.G_TRUE
      , p_commit                     => FND_API.G_FALSE
      , x_return_status              => x_return_status
      , x_msg_count                  => l_msg_count
      , x_msg_data                   => l_msg_data
      , p_task_assignment_id         => p_record.task_assignment_id
      , p_assignment_status_id       => p_record.assignment_status_id
      , p_object_version_number      => l_assignment_obj_version_nr
      , p_update_task                => 'T'
      , x_task_object_version_number => l_task_obj_version_nr
      , x_task_status_id             => l_task_status_id
      );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** exception occurred in API -> return errmsg ***/
      p_error_msg := CSL_SERVICEL_WRAPPER_PKG.GET_ERROR_MESSAGE_TEXT
        (
          p_api_error      => TRUE
        );
      IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => p_record.task_assignment_id
        , v_object_name => g_object_name
        , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
      END IF;
      RETURN;
    END IF;
  END IF;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_UPDATE'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

EXCEPTION WHEN OTHERS THEN
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
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
    ( v_object_id   => p_record.task_assignment_id
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
           p_record        IN     c_task_ass%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
  l_rc                        BOOLEAN;
  l_access_id                 NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  IF g_debug_level = JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
    , v_object_name => g_object_name
    , v_message     => 'Entering ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
    jtm_message_log_pkg.Log_Msg
      ( v_object_id   => p_record.task_assignment_id
      , v_object_name => g_object_name
      , v_message     => 'Processing TASK_ASSIGNMENT_ID = ' || p_record.task_assignment_id || fnd_global.local_chr(10) ||
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
        ( v_object_id   => p_record.task_assignment_id
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
      ( v_object_id   => p_record.task_assignment_id
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
                                    p_acc_table_name => 'CSL_JTF_TASK_ASS_ACC',
                                    p_resource_id    => JTM_HOOK_UTIL_PKG.get_resource_id( p_record.clid$$cs ),
                                    p_pk1_name       => 'TASK_ASSIGNMENT_ID',
                                    p_pk1_num_value  => p_record.TASK_ASSIGNMENT_ID
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
    ( v_object_id   => p_record.task_assignment_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;
EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_ERROR THEN
    jtm_message_log_pkg.Log_Msg
    ( v_object_id   => p_record.task_assignment_id
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
    ( v_object_id   => p_record.task_assignment_id
    , v_object_name => g_object_name
    , v_message     => 'Leaving ' || g_object_name || '.APPLY_RECORD'
    , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_RECORD;

/***
  This procedure is called by CSL_SERVICEL_WRAPPER_PKG when publication item CSL_JTF_TASK_ASSIGNMENTS
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

  -- ER 3218717
  -- Check if there are any debrief line records in INQUEUE

  CURSOR c_chk_debrief_lines ( b_task_assignment_id NUMBER) IS
  SELECT COUNT(*) FROM CSL_CSF_DEBRIEF_LINES_INQ
   WHERE DEBRIEF_HEADER_ID IN (
    SELECT DEBRIEF_HEADER_ID
    FROM CSL_CSF_DEBRIEF_HEADERS_INQ inq
    WHERE inq.TASK_ASSIGNMENT_ID = b_task_assignment_id
    UNION
    SELECT DEBRIEF_HEADER_ID
    FROM CSF_DEBRIEF_HEADERS header
    WHERE header.TASK_ASSIGNMENT_ID = b_task_assignment_id
  ) ;

  -- ER 3218717
  CURSOR c_chk_task_status
    (  b_task_assignment_id NUMBER
    ) IS
  SELECT dh.debrief_header_id, tst.rejected_flag, tst.on_hold_flag,
         tst.cancelled_flag, tst.closed_flag, tst.completed_flag
      FROM csf_debrief_headers dh, jtf_task_assignments tas,
           jtf_task_statuses_b tst
      WHERE dh.task_assignment_id = tas.task_assignment_id
        AND tas.assignment_status_id = tst.task_status_id
        AND tas.task_assignment_id = b_task_assignment_id;

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);

  -- ER 3218717
  l_rejected_flag   VARCHAR2(1);
  l_on_hold_flag    VARCHAR2(1);
  l_cancelled_flag  VARCHAR2(1);
  l_closed_flag     VARCHAR2(1);
  l_completed_flag  VARCHAR2(1);
  l_dbl_count       NUMBER := NULL;
  l_header_id       NUMBER := NULL;

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

  /*** loop through CSL_JTF_TASK_ASSIGNMENTS records in inqueue ***/
  FOR r_task_ass IN c_task_ass( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_task_ass
      , l_error_msg
      , l_process_status
      );

      jtm_message_log_pkg.Log_Msg
      ( v_object_id   => r_task_ass.task_assignment_id
      , v_object_name => g_object_name
      , v_message     => 'l_error_msg = ' || l_error_msg || fnd_global.local_chr(10) ||
                         'l_process_status = ' || l_process_status
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN

      -- ER 3218717 Check if there are any Debrief Line records
      OPEN c_chk_debrief_lines (r_task_ass.task_assignment_id);
      FETCH c_chk_debrief_lines INTO l_dbl_count;
      CLOSE c_chk_debrief_lines;

      IF ( l_dbl_count = 0 ) THEN

        OPEN c_chk_task_status (r_task_ass.task_assignment_id);
        FETCH c_chk_task_status INTO l_header_id, l_rejected_flag,
           l_on_hold_flag, l_cancelled_flag, l_closed_flag, l_completed_flag;
        CLOSE c_chk_task_status;

        IF ( (l_rejected_flag='Y') OR (l_on_hold_flag='Y')
             OR (l_cancelled_flag='Y') OR (l_closed_flag='Y')
             OR (l_completed_flag='Y') ) THEN

          csf_debrief_update_pkg.form_Call (1.0, l_header_id);

        END IF;

      END IF;

      /*** Yes -> delete record from inqueue ***/
      IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
        jtm_message_log_pkg.Log_Msg
        ( v_object_id   => r_task_ass.task_assignment_id
        , v_object_name => g_object_name
        , v_message     => 'Record successfully processed, deleting from inqueue'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_task_ass.seqno$$,
          r_task_ass.task_assignment_id,
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
          ( v_object_id   => r_task_ass.task_assignment_id
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
        ( v_object_id   => r_task_ass.task_assignment_id
        , v_object_name => g_object_name
        , v_message     => 'Record not processed successfully, deferring and rejecting record'
        , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM);
      END IF;

      CSL_SERVICEL_WRAPPER_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_task_ass.seqno$$
       , r_task_ass.task_assignment_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_task_ass.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        IF g_debug_level >= JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_MEDIUM THEN
          jtm_message_log_pkg.Log_Msg
          ( v_object_id   => r_task_ass.task_assignment_id
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

  -- ER 3218717
  IF c_chk_debrief_lines%ISOPEN THEN
    CLOSE c_chk_debrief_lines;
  END IF;

  IF c_chk_task_status%ISOPEN THEN
    CLOSE c_chk_task_status;
  END IF;

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_CLIENT_CHANGES;


/* New for Scottish Water Bug */
FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2 IS
  l_profile_value VARCHAR2(30) ;
  l_user_id NUMBER ;
  cursor get_user_id(l_tran_id in number,
                   l_user_name in varchar2)
  IS
  SELECT b.last_updated_by
  FROM JTF_TASK_ASSIGNMENTS b, CSL_JTF_TASK_ASSIGNMENTS_INQ a
  WHERE a.clid$$cs = l_user_name
     AND tranid$$ = l_tran_id AND a.task_assignment_id = b.task_assignment_id
     AND a.SEQNO$$ =  p_sequence;

BEGIN

   jtm_message_log_pkg.Log_Msg
    ( v_object_id     => null
      , v_object_name => g_object_name
      , v_message     => 'Entering Task Assignments CONFLICT_RESOLUTION_HANDLER : User '
                         ||p_user_name
      , v_level_id    => JTM_HOOK_UTIL_PKG.G_DEBUG_LEVEL_FULL);

   l_profile_value := fnd_profile.value('JTM_APPL_CONFLICT_RULE');

   OPEN get_user_id(p_tran_id,p_user_name) ;
   FETCH get_user_id INTO l_user_id ;
   CLOSE get_user_id ;

  if l_profile_value = 'SERVER_WINS'
       AND l_user_id <> asg_base.get_user_id( p_user_name ) then
      RETURN 'S' ;
  else
      RETURN 'C' ;
  END IF ;

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'C';
END CONFLICT_RESOLUTION_METHOD;

END CSL_TASK_ASSIGNMENTS_PKG;

/
