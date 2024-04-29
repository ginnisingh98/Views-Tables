--------------------------------------------------------
--  DDL for Package Body CSM_TASK_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_TASK_ASSIGNMENTS_PKG" AS
/* $Header: csmutab.pls 120.6.12010000.9 2010/05/21 11:00:02 trajasek ship $ */

  /*
   * The function to be called by CSM_SERVICEP_WRAPPER_PKG, for upward sync of
   * publication item CSM_TASK_ASSIGNMENTS
   */

-- Purpose: Update Task Assignments changes on Handheld to Enterprise database
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- DBhagat     11th September 2002  Created
--
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_TASK_ASSIGNMENTS_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_TASK_ASSIGNMENTS';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_task_assignments_inq( b_user_name VARCHAR2, b_tranid NUMBER) IS
  SELECT *
  FROM  csm_task_assignments_inq
  WHERE tranid$$ = b_tranid
  AND   CLID$$CS = B_USER_NAME;

--Cursor for Aux Objects
Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME NOT IN('JTF_TASK_ASSIGNMENTS_AUDIT_B')
ORDER BY HA_PAYLOAD_ID ASC;

--cursor for Audit Insert
Cursor C_Get_Aud_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME IN('JTF_TASK_ASSIGNMENTS_AUDIT_B')
ORDER BY HA_PAYLOAD_ID ASC;

/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_task_assignments_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

l_task_assignment_id NUMBER;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(4000);
l_ovn                   NUMBER;
l_ta_object_version_number number;
l_task_object_version_number number;
l_task_status_id             number;
l_task_status_name           varchar2(240);
l_task_type_id               number;

  CURSOR c_task_assignment
    ( b_task_assignment_id number
    )
  IS
    SELECT jta.object_version_number
    FROM   jtf_task_assignments jta
    WHERE  jta.task_assignment_id = b_task_assignment_id;


BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_TASK_ASSIGNMENTS_PKG.APPLY_INSERT for task_assignment_id ' || p_record.task_assignment_id ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);

  -- Create a Task Assignment
 csf_task_assignments_pub.create_task_assignment (
    p_api_version          => 1.0,
          p_init_msg_list        => fnd_api.g_true,
          p_commit               => fnd_api.g_false,
          p_task_assignment_id   => p_record.TASK_ASSIGNMENT_ID,
          p_validation_level   => NULL,
          p_task_id              => p_record.TASK_ID,
          p_task_name            => NULL,
          p_task_number          => NULL,
          p_resource_id          => p_record.RESOURCE_ID,
          p_resource_type_code   => 'RS_EMPLOYEE',
          p_resource_name        => NULL,
          p_actual_effort        => NULL,
	  p_actual_effort_uom    => NULL,
	  p_schedule_flag        => NULL,
	  p_alarm_type_code      => NULL,
	  p_alarm_contact        => NULL,
          p_sched_travel_distance=> p_record.SCHED_TRAVEL_DISTANCE,
	  p_sched_travel_duration=> p_record.SCHED_TRAVEL_DURATION,
          p_sched_travel_duration_uom  => p_record.SCHED_TRAVEL_DURATION_UOM,
          p_actual_travel_distance =>p_record.ACTUAL_TRAVEL_DISTANCE,
          p_actual_travel_duration => p_record.ACTUAL_TRAVEL_DURATION,
          p_actual_travel_duration_uom => p_record.ACTUAL_TRAVEL_DURATION_UOM,
          p_actual_start_date    => p_record.ACTUAL_START_DATE,
          p_actual_end_date      => p_record.ACTUAL_END_DATE,
          p_palm_flag            => NULL,
          p_wince_flag           => NULL,
          p_laptop_flag          => NULL,
          p_device1_flag         => NULL,
          p_device2_flag         => NULL,
          p_device3_flag         => NULL,
          p_resource_territory_id=> NULL,
          p_assignment_status_id => p_record.ASSIGNMENT_STATUS_ID,
          p_shift_construct_id   => NULL,
          p_object_capacity_id   => NULL,
          p_update_task          => NULL,
          x_return_status        => x_return_status,
          x_msg_count            => l_msg_count,
          x_msg_data             => l_msg_data,
          x_task_assignment_id   => l_task_assignment_id,
          x_ta_object_version_number   => l_ta_object_version_number,
          x_task_object_version_number => l_task_object_version_number,
          x_task_status_id             => l_task_status_id
  );
/*
  JTF_TASK_ASSIGNMENTS_PUB.create_task_assignment (
    p_api_version          => 1.0,
    p_init_msg_list        => FND_API.G_TRUE,
    p_commit               => FND_API.G_FALSE,
    p_task_assignment_id   => p_record.TASK_ASSIGNMENT_ID,
    p_task_id              => p_record.TASK_ID,
    p_resource_type_code   => 'RS_EMPLOYEE',
    p_resource_id          => p_record.resource_id,
    p_assignment_status_id => p_record.ASSIGNMENT_STATUS_ID,
    p_attribute1           => p_record.attribute1,
    p_attribute2           => p_record.attribute2,
    p_attribute3           => p_record.attribute3,
    p_attribute4           => p_record.attribute4,
    p_attribute5           => p_record.attribute5,
    p_attribute6           => p_record.attribute6,
    p_attribute7           => p_record.attribute7,
    p_attribute8           => p_record.attribute8,
    p_attribute9           => p_record.attribute9,
    p_attribute10          => p_record.attribute10,
    p_attribute11          => p_record.attribute11,
    p_attribute12          => p_record.attribute12,
    p_attribute13          => p_record.attribute13,
    p_attribute14          => p_record.attribute14,
    p_attribute15          => p_record.attribute15,
--Bug 5182470
    p_attribute_category   => p_record.attribute_category,
    x_return_status        => x_return_status,
    x_msg_count            => l_msg_count,
    x_msg_data             => l_msg_data,
    x_task_assignment_id   => l_task_assignment_id
  );
*/
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
      || ' ROOT ERROR: JTF_TASK_ASSIGNMENTS_PUB.create_task_assignment'
      || ' for PK ' || p_record.TASK_ASSIGNMENT_ID,
      g_object_name || '.APPLY_INSERT',FND_LOG.LEVEL_ERROR );
    RETURN ;
  END IF;

   -- Ask for the task. It must exist. Exceptions will abort.
  OPEN c_task_assignment
    ( b_task_assignment_id => p_record.task_assignment_id
    );
  FETCH c_task_assignment INTO l_ovn;
  CLOSE c_task_assignment;

  -- Synchronize Task Assignment and Task statuses
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

  csf_task_assignments_pub.update_assignment_status
    ( p_api_version                => 1.0
    , p_init_msg_list              => FND_API.G_TRUE
    , p_commit                     => FND_API.G_FALSE
    , p_validation_level 		   => FND_API.G_VALID_LEVEL_NONE
    , x_return_status              => x_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_task_assignment_id         => p_record.task_assignment_id
    , p_assignment_status_id       => p_record.assignment_status_id
    , p_object_version_number      => l_ovn
    , p_update_task                => 'T'
    , x_task_object_version_number => l_task_object_version_number
    , x_task_status_id             => l_task_status_id
    );
 END IF;
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
      || ' ROOT ERROR: csf_tasks_pub.update_assignment_status'
      || ' for PK ' || p_record.TASK_ASSIGNMENT_ID,
      g_object_name || '.APPLY_UPDATE',FND_LOG.LEVEL_ERROR );
    RETURN ;
  END IF;


  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT:' ||g_object_name || '.APPLY_INSERT',
       FND_LOG.LEVEL_EXCEPTION );

  x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_INSERT;
/***
  This procedure is called by APPLY_INSERT when
  an update is to be reverted.
***/

PROCEDURE APPLY_UNDO
         (
           p_record           IN c_task_assignments_inq%ROWTYPE,
           p_error_msg        OUT NOCOPY    VARCHAR2,
           x_return_status    IN  OUT NOCOPY VARCHAR2
         )
IS

CURSOR c_get_undo_inq ( c_user_name VARCHAR2, c_tranid NUMBER,c_pk1_value NUMBER)
IS
SELECT SEQNO$$
FROM  CSM_CLIENT_UNDO_REQUEST_INQ
WHERE tranid$$  = c_tranid
AND   clid$$cs  = c_user_name
AND   PK1_VALUE = c_pk1_value;

CURSOR c_get_task_assignment(c_task_assignment_id NUMBER,c_user_id NUMBER)
IS
SELECT ACCESS_ID
FROM   CSM_TASK_ASSIGNMENTS_ACC
WHERE  TASK_ASSIGNMENT_ID = c_task_assignment_id
AND    USER_ID            = c_user_id;

CURSOR c_get_task(c_task_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_TASKS_ACC acc,
       CSM_TASKS_INQ inq
WHERE  acc.TASK_ID     = c_task_id
AND    acc.USER_ID     = c_user_id
AND    inq.TASK_ID  = acc.TASK_ID
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_incident(c_task_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.INCIDENT_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_INCIDENTS_ALL_ACC acc,
       JTF_TASKS_B b,
       CSM_INCIDENTS_ALL_INQ inq
WHERE  acc.USER_ID     = c_user_id
AND    b.TASK_ID  = c_task_id
AND    b.SOURCE_OBJECT_ID = acc.INCIDENT_ID
AND    b.SOURCE_OBJECT_TYPE_CODE = 'SR'
AND    acc.INCIDENT_ID = inq.INCIDENT_ID
AND    inq.CLID$$CS = c_user_name;


CURSOR c_get_debrief_header(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_HEADER_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_HEADERS_ACC acc,
       CSM_DEBRIEF_HEADERS_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_HEADER_ID = acc.DEBRIEF_HEADER_ID(+)
AND    inq.CLID$$CS = c_user_name;


CURSOR c_get_debrief_expenses(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_LINES_ACC acc,
       CSF_M_DEBRIEF_EXPENSES_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_LINE_ID     = acc.DEBRIEF_LINE_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_debrief_labor(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_LINES_ACC acc,
       CSF_M_DEBRIEF_LABOR_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_LINE_ID = acc.DEBRIEF_LINE_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_debrief_parts(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.DEBRIEF_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_DEBRIEF_LINES_ACC acc,
       CSF_M_DEBRIEF_PARTS_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID  = c_task_assg_id
AND    inq.DEBRIEF_LINE_ID = acc.DEBRIEF_LINE_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_req_header(c_task_assg_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.REQUIREMENT_HEADER_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_REQ_HEADERS_ACC acc,
       CSM_REQ_HEADERS_INQ inq
WHERE  acc.USER_ID(+)     = c_user_id
AND    inq.TASK_ASSIGNMENT_ID    = c_task_assg_id
AND    inq.REQUIREMENT_HEADER_ID = acc.REQUIREMENT_HEADER_ID(+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_req_line(c_req_header_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.REQUIREMENT_LINE_ID,INQ.TRANID$$,INQ.SEQNO$$
FROM   CSM_REQ_LINES_ACC acc,
       CSM_REQ_LINES_INQ inq
WHERE  acc.USER_ID (+)    = c_user_id
AND    inq.REQUIREMENT_HEADER_ID = c_req_header_id
AND    inq.REQUIREMENT_LINE_ID   = acc.REQUIREMENT_LINE_ID (+)
AND    inq.CLID$$CS = c_user_name;

CURSOR c_get_notes(c_task_id NUMBER,c_incident_id NUMBER,c_debrief_header_id NUMBER,c_user_id NUMBER,c_user_name VARCHAR2)
IS
SELECT ACCESS_ID,INQ.JTF_NOTE_ID,INQ.TRANID$$,INQ.SEQNO$$, INQ.DMLTYPE$$
FROM   CSM_NOTES_ACC acc,
       CSF_M_NOTES_INQ inq
WHERE  acc.USER_ID (+)     = c_user_id
AND    inq.JTF_NOTE_ID = acc.JTF_NOTE_ID (+)
AND    inq.CLID$$CS    = c_user_name
AND (
    ( inq.SOURCE_OBJECT_CODE = 'TASK' AND inq.SOURCE_OBJECT_ID = c_task_id )
OR  ( inq.SOURCE_OBJECT_CODE = 'SR' AND inq.SOURCE_OBJECT_ID = c_incident_id)
OR  ( inq.SOURCE_OBJECT_CODE = 'SD' AND inq.SOURCE_OBJECT_ID = c_debrief_header_id)
   );

 CURSOR c_get_user_id (c_user_name VARCHAR2)
 IS
 SELECT USER_ID
 FROM   ASG_USER
 WHERE  USER_NAME = c_user_name;

--Pub items and object declarations


l_task_obj_name VARCHAR2(30) := 'CSM_TASKS_PKG';  -- package name
l_task_pub_name VARCHAR2(30) := 'CSM_TASKS';

l_sr_obj_name VARCHAR2(30) := 'CSM_SERVICE_REQUEST_PKG';
l_sr_pub_name VARCHAR2(30) := 'CSM_INCIDENTS_ALL';

l_dbh_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS_PKG';
l_dbh_pub_name VARCHAR2(30) := 'CSM_DEBRIEF_HEADERS';

l_dble_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_EXPENSES_PKG';
l_dble_pub_name VARCHAR2(30) := 'CSF_M_DEBRIEF_EXPENSES';

l_dbll_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_LABOR_PKG';
l_dbll_pub_name VARCHAR2(30) := 'CSF_M_DEBRIEF_LABOR';

l_dblp_obj_name VARCHAR2(30) := 'CSM_DEBRIEF_PARTS_PKG';
l_dblp_pub_name VARCHAR2(30) := 'CSF_M_DEBRIEF_PARTS';

l_notes_obj_name VARCHAR2(30)  := 'CSM_NOTES_PKG';
l_notes_pub_name VARCHAR2(30)  := 'CSF_M_NOTES';

l_reqh_obj_name VARCHAR2(30) := 'CSM_REQUIREMENTS_PKG';
l_reqh_pub_name VARCHAR2(30) := 'CSM_REQ_HEADERS';

l_reql_obj_name VARCHAR2(30) := 'CSM_REQUIREMENTS_PKG';
l_reql_pub_name VARCHAR2(30) := 'CSM_REQ_LINES';

l_undo_pub_name VARCHAR2(30) := 'CSM_CLIENT_UNDO_REQUEST';

l_access_id     NUMBER;
l_mark_dirty	  BOOLEAN;
l_incident_id   NUMBER;
l_debrief_header_id NUMBER;
l_tran_id       NUMBER;
l_user_name     VARCHAR2(100);
l_user_id       NUMBER;
l_task_assignment_id       NUMBER;
l_task_id         NUMBER;
l_debrief_line_id NUMBER;
l_req_header_id   NUMBER;
l_req_line_id     NUMBER;
l_note_id         NUMBER;
l_process_status  VARCHAR2(1);
l_error_msg       VARCHAR2(4000);
l_markdirty_all   VARCHAR2(1):= 'Y';
l_sequence        NUMBER;
l_dml_type        VARCHAR2(1) := '';

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION WHEN OTHERS THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UNDO:' ||g_object_name || '.APPLY_UNDO',
       FND_LOG.LEVEL_EXCEPTION );
    x_return_status := FND_API.G_RET_STS_ERROR;
END APPLY_UNDO;

/***
  This procedure is called by APPLY_CRECORD when
  an updated record is to be processed.
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_task_assignments_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS

CURSOR c_task_assignment( b_task_assignment_id NUMBER)
IS
   SELECT jta.task_id
   ,      jta.object_version_number
   ,      jta.last_update_date
   ,      jta.last_updated_by
   FROM   jtf_task_assignments jta
   WHERE  jta.task_assignment_id = b_task_assignment_id;

  r_task_assignment       c_task_assignment%ROWTYPE;
  l_ovn                   NUMBER;
  l_profile_value         VARCHAR2(240);

  -- Declare OUT parameters
  l_task_object_version_number NUMBER;
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(4000);
  l_task_status_id        NUMBER;
  l_task_status_name      VARCHAR2(240);
  l_task_type_id	        NUMBER;

BEGIN

  -- Ask for the task. It must exist. Exceptions will abort.
  OPEN  c_task_assignment( b_task_assignment_id => p_record.task_assignment_id);
  FETCH c_task_assignment INTO r_task_assignment;
  l_ovn := r_task_assignment.object_version_number;
  CLOSE c_task_assignment;

  --check for the stale data
  l_profile_value := fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE);
  -- SERVER_WINS profile value
  IF(l_profile_value = csm_profile_pkg.g_SERVER_WINS AND
       ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_pub_name, p_record.seqno$$) <> FND_API.G_TRUE)
  THEN
    IF(r_task_assignment.last_update_date <> p_record.server_last_update_date AND r_task_assignment.last_updated_by <> asg_base.get_user_id(p_record.clid$$cs)) THEN
      p_error_msg := 'UPWARD SYNC CONFLICT: CLIENT LOST For JTF_TASK_ASSIGNMENTS: CSM_TASK_ASSIGNMENTS_PKG.APPLY_UPDATE: P_KEY = '
        || p_record.task_assignment_id;
      x_return_status := FND_API.G_RET_STS_ERROR;
      csm_util_pkg.log(p_error_msg,
        g_object_name || '.APPLY_UPDATE',
        FND_LOG.LEVEL_ERROR);
    RETURN;
    END IF;
  END IF;


  -- The column assignment_status_id is the status of the task_assignment_id.
  -- The column task_assignment_id is task_assignment_id.
  -- Validation is not a good thing for this particular API-call: as
  -- the palm application does the check for state changes, it is not
  -- necessary to redo them here. Even worse, a state change in two steps
  -- A -> B and B -> C may be OK for palm application, but if the intermediate
  -- step is not sent to CRM, the API will see A -> C and refuse it.
  -- To allow for A -> C no validation is done.
  csf_task_assignments_pub.update_assignment_status
    ( p_api_version                => 1.0
    , p_init_msg_list              => FND_API.G_TRUE
    , p_commit                     => FND_API.G_FALSE
    , p_validation_level 		   => FND_API.G_VALID_LEVEL_NONE
    , x_return_status              => x_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , p_task_assignment_id         => p_record.task_assignment_id
    , p_assignment_status_id       => p_record.assignment_status_id
    , p_object_version_number      => l_ovn
    , p_update_task                => 'T'
    , x_task_object_version_number => l_task_object_version_number
    , x_task_status_id             => l_task_status_id
    );
  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN

    x_return_status := FND_API.G_RET_STS_ERROR;
    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_UPDATE:'
      || ' ROOT ERROR: csf_tasks_pub.update_assignment_status'
      || ' for PK ' || p_record.TASK_ASSIGNMENT_ID,
      g_object_name || '.APPLY_UPDATE',FND_LOG.LEVEL_ERROR );
    RETURN ;
  END IF;

  -- Also need to update the actual times of the task assignment update
  -- use a different procedure for this because the csf_tasks_pub.update_assignment_status
  -- doesn't support the actual times and the csf_tasks_pub.Update_Task_Assignment doen't
  -- support the validation level set to none.
  csf_task_assignments_pub.Update_Task_Assignment
    ( p_api_version                => 1.0
    , p_init_msg_list              => FND_API.G_TRUE
    , p_commit                     => FND_API.G_FALSE
    , p_task_assignment_id         => p_record.task_assignment_id
    , p_object_version_number      => l_ovn
    , p_task_id                    => p_record.task_id
    , p_resource_type_code         => FND_API.G_MISS_CHAR
    , p_resource_id                => FND_API.G_MISS_NUM --p_record.resource_id
    , p_resource_territory_id      => FND_API.G_MISS_NUM
    , p_assignment_status_id       => FND_API.G_MISS_NUM
    , p_actual_start_date          => p_record.actual_start_date
    , p_actual_end_date            => p_record.actual_end_date
    , p_sched_travel_distance      => FND_API.G_MISS_NUM
    , p_sched_travel_duration      => FND_API.G_MISS_NUM
    , p_sched_travel_duration_uom  => FND_API.G_MISS_CHAR
    , p_shift_construct_id         => FND_API.G_MISS_NUM
    , p_object_capacity_id         => FND_API.G_MISS_NUM
    , p_attribute1                 => p_record.attribute1
    , p_attribute2                 => p_record.attribute2
    , p_attribute3                 => p_record.attribute3
    , p_attribute4                 => p_record.attribute4
    , p_attribute5                 => p_record.attribute5
    , p_attribute6                 => p_record.attribute6
    , p_attribute7                 => p_record.attribute7
    , p_attribute8                 => p_record.attribute8
    , p_attribute9                 => p_record.attribute9
    , p_attribute10                => p_record.attribute10
    , p_attribute11                => p_record.attribute11
    , p_attribute12                => p_record.attribute12
    , p_attribute13                => p_record.attribute13
    , p_attribute14                => p_record.attribute14
    , p_attribute15                => p_record.attribute15
--Bug 5182470
    , p_attribute_category         => p_record.attribute_category
    , x_return_status              => x_return_status
    , x_msg_count                  => l_msg_count
    , x_msg_data                   => l_msg_data
    , x_task_object_version_number => l_task_object_version_number
    , x_task_status_id             => l_task_status_id
    );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_UPDATE:'
      || ' ROOT ERROR: csf_tasks_pub.Update_Task_Assignment'
      || ' for PK ' || p_record.TASK_ASSIGNMENT_ID,
      g_object_name || '.APPLY_UPDATE',
      FND_LOG.LEVEL_ERROR );
    RETURN ;
  END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN others THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
       || ' for PK ' || p_record.task_assignment_id,
       g_object_name || '.APPLY_UPDATE',
       FND_LOG.LEVEL_EXCEPTION );

     x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_UPDATE;


/***
  This procedure is called by APPLY_CLIENT_CHANGES when a record
  is to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_task_assignments_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         ) IS
BEGIN

  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;


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
  ELSE
    -- Process delete and insert;
    -- Not supported for this entity
    CSM_UTIL_PKG.LOG
      ( 'Delete and Insert is not supported for this entity'
        || ' for PK ' || p_record.task_assignment_id ,
        g_object_name || '.APPLY_RECORD',
        FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

EXCEPTION WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  CSM_UTIL_PKG.LOG
    ( 'Exception occurred in ' || g_object_name || '.APPLY_RECORD:' || ' ' || SQLERRM
      || ' for PK ' || p_record.task_assignment_id ,
      g_object_name || '.APPLY_RECORD',
      FND_LOG.LEVEL_EXCEPTION);
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', SQLERRM);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;


/***
  APPLY_CLIENT_CHANGE procedure is called by SM_SERVICEP_WRAPPER_PKG, for upward sync of
  publication item CSM_TASK_ASSIGNMENTS
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
  IS
  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);

-- ER 3079918
CURSOR c_chk_task_status(  p_task_assignment_id NUMBER)
IS
SELECT dh.debrief_header_id, tst.rejected_flag, tst.on_hold_flag,
         tst.cancelled_flag, tst.closed_flag, tst.completed_flag
FROM csf_debrief_headers dh, jtf_task_assignments tas,
           jtf_task_statuses_b tst
WHERE dh.task_assignment_id  = tas.task_assignment_id
AND tas.assignment_status_id = tst.task_status_id
AND tas.task_assignment_id   = p_task_assignment_id;

CURSOR c_check_undo_request(c_task_assignment_id NUMBER, c_tranid NUMBER)
IS
  SELECT  PK1_VALUE
  FROM    CSM_CLIENT_UNDO_REQUEST_INQ
  WHERE   PUB_ITEM  = 'CSM_TASK_ASSIGNMENTS'
  AND     TRANID$$  = c_tranid
  AND     PK1_VALUE = c_task_assignment_id;

l_rejected_flag   VARCHAR2(1);
l_on_hold_flag    VARCHAR2(1);
l_cancelled_flag  VARCHAR2(1);
l_closed_flag     VARCHAR2(1);
l_completed_flag  VARCHAR2(1);
l_dbl_count       NUMBER := NULL;
l_header_id       NUMBER := NULL;
l_task_assignment_id NUMBER := NULL;
l_err_message     VARCHAR2(4000);
l_return_status   VARCHAR2(100);

BEGIN
  csm_util_pkg.log
  ( g_object_name || '.APPLY_CLIENT_CHANGES entered',
    g_object_name || '.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through task assignments records in inqueue ***/
  FOR r_task_assignments IN c_task_assignments_inq( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

      /*** apply record ***/
      APPLY_RECORD
        (
          r_task_assignments
        , l_error_msg
        , l_process_status
        );

      /*** was record processed successfully? ***/
      IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      -- if update to charges fail, then do not defer the record
        BEGIN
         OPEN c_chk_task_status (r_task_assignments.task_assignment_id);
         FETCH c_chk_task_status INTO l_header_id, l_rejected_flag,
             l_on_hold_flag, l_cancelled_flag, l_closed_flag, l_completed_flag;

         IF c_chk_task_status%FOUND THEN
           IF ( (l_rejected_flag='Y') OR (l_on_hold_flag='Y')
               OR (l_cancelled_flag='Y') OR (l_closed_flag='Y')
               OR (l_completed_flag='Y') ) THEN

             csf_debrief_update_pkg.form_Call (1.0, l_header_id);
           END IF;
         END IF;

         CLOSE c_chk_task_status;
        EXCEPTION
           WHEN others THEN
               NULL;
        END;

        /*** If Yes -> delete record from inqueue ***/
        CSM_UTIL_PKG.DELETE_RECORD
          (
            p_user_name,
            p_tranid,
            r_task_assignments.seqno$$,
            r_task_assignments.task_assignment_id,
            g_object_name,
            g_pub_name,
            l_error_msg,
            l_process_status
          );

        /*** was delete successful? ***/
        IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
             --Task Assignment Audit information is not important and hence
             -- Task Assignment Audit information failure should not be
             -- considered as failure and stops TA Upload
              --Call Task Assignment Audit Upload
          CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES
             (
               p_user_name     =>p_user_name,
               p_tranid        =>p_tranid,
               p_assignment_id =>r_task_assignments.task_assignment_id,
               p_debug_level   =>g_debug_level,
               x_return_status =>l_process_status
             );

            /*** was TA AUDIT UPLOAD successful? ***/
            IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
              /*** If No -> rollback ***/
              CSM_UTIL_PKG.LOG
              ( 'Inserting Task Assignment Audit Failed, Task Assignment Audit Failed for '
                || ' for PK ' || r_task_assignments.task_assignment_id ,
                g_object_name || '.APPLY_CLIENT_CHANGES',
                FND_LOG.LEVEL_ERROR); -- put PK column here
            END IF;

        ELSE
          /*** If No -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, rolling back to savepoint'
            || ' for PK ' || r_task_assignments.task_assignment_id ,
            g_object_name || '.APPLY_CLIENT_CHANGES',
            FND_LOG.LEVEL_ERROR); -- put PK column here
          ROLLBACK TO save_rec;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;
      ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** Record was not processed successfully or delete failed
        -> defer and reject record ***/
        CSM_UTIL_PKG.LOG
        ( 'Record not processed successfully, deferring and rejecting record'
          || ' for PK ' || r_task_assignments.task_assignment_id ,
          g_object_name || '.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_ERROR); -- put PK column here

        CSM_UTIL_PKG.DEFER_RECORD
         ( p_user_name
         , p_tranid
         , r_task_assignments.seqno$$
         , r_task_assignments.task_assignment_id
         , g_object_name
         , g_pub_name
         , l_error_msg
         , l_process_status
         , r_task_assignments.dmltype$$
         );

        /*** Was defer successful? ***/
        IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
            CSM_UTIL_PKG.LOG
            ( 'Inserting Task Assignment Audit , Task Assignment Audit for '
              || ' for PK ' || r_task_assignments.task_assignment_id ,
              g_object_name || '.APPLY_CLIENT_CHANGES',
              FND_LOG.LEVEL_ERROR); -- put PK column here

          CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES
             (
               p_user_name     =>p_user_name,
               p_tranid        =>p_tranid,
               p_assignment_id =>r_task_assignments.task_assignment_id,
               p_debug_level   =>g_debug_level,
               x_return_status =>l_process_status
             );

        END IF;

        IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
          /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, rolling back to savepoint'
            || ' for PK ' || r_task_assignments.task_assignment_id ,
            g_object_name || '.APPLY_CLIENT_CHANGES',
            FND_LOG.LEVEL_ERROR); -- put PK column here
          ROLLBACK TO save_rec;
          x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

      END IF;
  END LOOP;

EXCEPTION WHEN OTHERS THEN
  IF c_chk_task_status%ISOPEN THEN
      CLOSE c_chk_task_status;
  END IF;

  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in ' || g_object_name || '.APPLY_CLIENT_CHANGES:' || ' ' || SQLERRM,
    g_object_name || '.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

FUNCTION CONFLICT_RESOLUTION_METHOD (p_user_name IN VARCHAR2,
                                     p_tran_id IN NUMBER,
                                     p_sequence IN NUMBER)
RETURN VARCHAR2 IS
l_profile_value VARCHAR2(30) ;
l_user_id NUMBER ;
cursor get_user_id(l_tran_id in number,
                   l_user_name in varchar2,
		   l_sequence in number)
IS
SELECT b.last_updated_by
FROM JTF_TASK_ASSIGNMENTS b,
     CSM_TASK_ASSIGNMENTS_INQ a
WHERE a.clid$$cs = l_user_name
AND tranid$$ = l_tran_id
AND seqno$$ = l_sequence
AND a.task_assignment_id = b.task_assignment_id ;

BEGIN
  CSM_UTIL_PKG.LOG('Entering CSM_TASK_ASSIGNMENTS_PKG.CONFLICT_RESOLUTION_METHOD for user ' || p_user_name ,'CSM_TASK_ASSIGNMENTS_PKG.CONFLICT_RESOLUTION_METHOD',FND_LOG.LEVEL_PROCEDURE);
 l_profile_value := fnd_profile.value(csm_profile_pkg.g_JTM_APPL_CONFLICT_RULE);
OPEN get_user_id(p_tran_id, p_user_name, p_sequence) ;
FETCH get_user_id
 INTO l_user_id ;
CLOSE get_user_id ;

  if l_profile_value = 'SERVER_WINS' AND l_user_id <> asg_base.get_user_id(p_user_name) then
      RETURN 'S' ;
  else
      RETURN 'C' ;
  END IF ;

EXCEPTION
  WHEN OTHERS THEN
     RETURN 'C';
END CONFLICT_RESOLUTION_METHOD;

--Code for HA

PROCEDURE APPLY_HA_INSERT
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
l_CON_NAME_LIST       CSM_VARCHAR_LIST;
L_CON_VALUE_LIST      CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
L_AUD_RETURN_STATUS   VARCHAR2(200);
L_AUD_ERROR_MESSAGE   VARCHAR2(2000);
L_TASK_ASSIGNMENT_REC JTF_TASK_ASSIGNMENTS_PUB.task_assignments_rec;
L_TASK_ASSIGNMENT_ID  NUMBER;
L_FREE_BUSY_TYPE      VARCHAR2(100);
L_OBJECT_CAPACITY_ID  NUMBER;
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_ASSIGNEE_ROLE       VARCHAR2(100);
l_Aux_Name_List   Csm_Varchar_List;
l_aux_Value_List  Csm_Varchar_List;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Task Assignment
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  L_COL_VALUE_LIST(I) IS NOT NULL THEN
      IF l_COL_NAME_LIST(i) = 'ASSIGNEE_ROLE' THEN
        L_ASSIGNEE_ROLE := L_COL_VALUE_LIST(I);
      ELSIF l_COL_NAME_LIST(i) = 'TASK_ASSIGNMENT_ID' THEN
        L_TASK_ASSIGNMENT_REC.TASK_ASSIGNMENT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_ID' THEN
        L_TASK_ASSIGNMENT_REC.TASK_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_TYPE_CODE' THEN
        L_TASK_ASSIGNMENT_REC.RESOURCE_TYPE_CODE  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_ID' THEN
        L_TASK_ASSIGNMENT_REC.RESOURCE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ASSIGNMENT_STATUS_ID' THEN
        L_TASK_ASSIGNMENT_REC.ASSIGNMENT_STATUS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_EFFORT' THEN
        L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_TERRITORY_ID' THEN
        L_TASK_ASSIGNMENT_REC.RESOURCE_TERRITORY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_EFFORT_UOM' THEN
        L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT_UOM  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SCHEDULE_FLAG' THEN
        L_TASK_ASSIGNMENT_REC.SCHEDULE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_TYPE_CODE' THEN
        L_TASK_ASSIGNMENT_REC.ALARM_TYPE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_CONTACT' THEN
        L_TASK_ASSIGNMENT_REC.ALARM_CONTACT  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SHIFT_CONSTRUCT_ID' THEN
       L_TASK_ASSIGNMENT_REC.SHIFT_CONSTRUCT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHED_TRAVEL_DISTANCE' THEN
       L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DISTANCE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHED_TRAVEL_DURATION' THEN
       L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHED_TRAVEL_DURATION_UOM' THEN
       L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION_UOM := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_TRAVEL_DISTANCE' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DISTANCE := NULL; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_TRAVEL_DURATION' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_TRAVEL_DURATION_UOM' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION_UOM := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_START_DATE' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_END_DATE' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PALM_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.PALM_FLAG   := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'WINCE_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.WINCE_FLAG := null; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAPTOP_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.LAPTOP_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE1_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.DEVICE1_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DEVICE2_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.DEVICE2_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE3_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.DEVICE3_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SHOW_ON_CALENDAR' THEN
       L_TASK_ASSIGNMENT_REC.SHOW_ON_CALENDAR := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CATEGORY_ID' THEN
       L_TASK_ASSIGNMENT_REC.CATEGORY_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'FREE_BUSY_TYPE' THEN
       L_FREE_BUSY_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OBJECT_CAPACITY_ID' THEN
       L_OBJECT_CAPACITY_ID := L_COL_VALUE_LIST(I);
      END IF;

     END IF;
  END LOOP;
  --Process only if assignee role is assignee
 IF L_ASSIGNEE_ROLE = 'ASSIGNEE' THEN
      JTF_TASK_ASSIGNMENTS_PUB.CREATE_TASK_ASSIGNMENT(
          P_API_VERSION		            => 1.0,
          P_INIT_MSG_LIST		          => FND_API.G_TRUE,
          P_COMMIT		                => FND_API.G_FALSE,
          P_TASK_ASSIGNMENT_ID        => L_TASK_ASSIGNMENT_REC.TASK_ASSIGNMENT_ID ,
          P_TASK_ID                   => L_TASK_ASSIGNMENT_REC.TASK_ID,
          P_TASK_NUMBER		            => NULL,
          P_TASK_NAME                 => NULL,
          P_RESOURCE_TYPE_CODE        => L_TASK_ASSIGNMENT_REC.RESOURCE_TYPE_CODE ,
          P_RESOURCE_ID               => L_TASK_ASSIGNMENT_REC.RESOURCE_ID ,
          P_RESOURCE_NAME             => NULL,
          P_ACTUAL_EFFORT             => L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT ,
          P_ACTUAL_EFFORT_UOM         => L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT_UOM ,
          P_SCHEDULE_FLAG             => L_TASK_ASSIGNMENT_REC.SCHEDULE_FLAG ,
          P_ALARM_TYPE_CODE           => L_TASK_ASSIGNMENT_REC.ALARM_TYPE_CODE ,
          P_ALARM_CONTACT             => L_TASK_ASSIGNMENT_REC.ALARM_CONTACT ,
          P_SCHED_TRAVEL_DISTANCE     => L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DISTANCE ,
          P_SCHED_TRAVEL_DURATION     => L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION ,
          P_SCHED_TRAVEL_DURATION_UOM => L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION_UOM ,
          P_ACTUAL_TRAVEL_DISTANCE    => L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DISTANCE ,
          P_ACTUAL_TRAVEL_DURATION    => L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION ,
          P_ACTUAL_TRAVEL_DURATION_UOM=> L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION_UOM ,
          P_ACTUAL_START_DATE         => L_TASK_ASSIGNMENT_REC.ACTUAL_START_DATE ,
          P_ACTUAL_END_DATE           => L_TASK_ASSIGNMENT_REC.ACTUAL_END_DATE ,
          P_PALM_FLAG                 => L_TASK_ASSIGNMENT_REC.PALM_FLAG ,
          P_WINCE_FLAG                => L_TASK_ASSIGNMENT_REC.WINCE_FLAG ,
          P_LAPTOP_FLAG               => L_TASK_ASSIGNMENT_REC.LAPTOP_FLAG ,
          P_DEVICE1_FLAG              => L_TASK_ASSIGNMENT_REC.DEVICE1_FLAG ,
          P_DEVICE2_FLAG              => L_TASK_ASSIGNMENT_REC.DEVICE2_FLAG ,
          P_DEVICE3_FLAG              => L_TASK_ASSIGNMENT_REC.DEVICE3_FLAG ,
          P_RESOURCE_TERRITORY_ID     => L_TASK_ASSIGNMENT_REC.RESOURCE_TERRITORY_ID,
          P_ASSIGNMENT_STATUS_ID      => L_TASK_ASSIGNMENT_REC.ASSIGNMENT_STATUS_ID ,
          P_SHIFT_CONSTRUCT_ID        => L_TASK_ASSIGNMENT_REC.SHIFT_CONSTRUCT_ID ,
          X_RETURN_STATUS		          => L_RETURN_STATUS ,
          X_MSG_COUNT                 => L_MSG_COUNT ,
          X_MSG_DATA			            => L_MSG_DATA ,
          X_TASK_ASSIGNMENT_ID		    => L_TASK_ASSIGNMENT_ID,
          P_ATTRIBUTE1                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE1 ,
          P_ATTRIBUTE2                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE2 ,
          P_ATTRIBUTE3                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE3 ,
          P_ATTRIBUTE4                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE4 ,
          P_ATTRIBUTE5                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE5 ,
          P_ATTRIBUTE6                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE6 ,
          P_ATTRIBUTE7                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE7 ,
          P_ATTRIBUTE8                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE8 ,
          P_ATTRIBUTE9                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE9 ,
          P_ATTRIBUTE10               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE10 ,
          P_ATTRIBUTE11               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE11 ,
          P_ATTRIBUTE12               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE12 ,
          P_ATTRIBUTE13               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE13 ,
          P_ATTRIBUTE14               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE14 ,
          P_ATTRIBUTE15               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE15 ,
          P_ATTRIBUTE_CATEGORY        => L_TASK_ASSIGNMENT_REC.ATTRIBUTE_CATEGORY ,
          P_SHOW_ON_CALENDAR          => L_TASK_ASSIGNMENT_REC.SHOW_ON_CALENDAR ,
          P_CATEGORY_ID               => L_TASK_ASSIGNMENT_REC.CATEGORY_ID,
          P_ENABLE_WORKFLOW           => 'N' ,
          P_ABORT_WORKFLOW            => 'Y' ,
          P_OBJECT_CAPACITY_ID        => L_OBJECT_CAPACITY_ID,
          P_FREE_BUSY_TYPE            => L_FREE_BUSY_TYPE
           );

        IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN

          --After Successful TA Insert process Object Capacity Updates
          FOR R_GET_AUX_OBJECTS IN C_GET_AUX_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
             CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUX_OBJECTS.HA_PAYLOAD_ID
                                  ,X_RETURN_STATUS => L_RETURN_STATUS
                                  ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);
          END LOOP;

          IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
            --After Successful TA and OC Insert process TA audit
            BEGIN
              FOR R_GET_AUD_OBJECTS IN C_GET_AUD_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUD_OBJECTS.HA_PAYLOAD_ID
                                    ,X_RETURN_STATUS => L_AUD_RETURN_STATUS
                                    ,x_ERROR_MESSAGE => l_AUD_ERROR_MESSAGE);
              END LOOP;
            EXCEPTION
            WHEN OTHERS THEN
              NULL;
            END;
            X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
          ELSE --OC FAILURE
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            X_ERROR_MESSAGE := L_ERROR_MESSAGE;
          END IF;
        ELSE --TA FAILURE
           /*** exception occurred in API -> return errmsg ***/
          s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
          (
              p_api_error      => TRUE
          );

          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          X_ERROR_MESSAGE := S_MSG_DATA;

        END IF;
  ELSE
          X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
          X_ERROR_MESSAGE := 'Record Not Processed.Task assignments with Assignee role as Assignee alone will be processed';

  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_INSERT', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_INSERT: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_Error_Message := S_Msg_Data;
END APPLY_HA_INSERT;

PROCEDURE APPLY_HA_UPDATE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
l_CON_NAME_LIST       CSM_VARCHAR_LIST;
L_CON_VALUE_LIST      CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
L_AUD_RETURN_STATUS   VARCHAR2(200);
L_AUD_ERROR_MESSAGE   VARCHAR2(2000);
L_TASK_ASSIGNMENT_REC JTF_TASK_ASSIGNMENTS_PUB.task_assignments_rec;
L_TASK_ASSIGNMENT_ID  NUMBER;
L_FREE_BUSY_TYPE      VARCHAR2(100);
L_OBJECT_CAPACITY_ID  NUMBER;
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_OBJECT_VERSION_NUMBER NUMBER;
L_ASSIGNEE_ROLE       VARCHAR2(100);

CURSOR C_GET_TA_VERSION( B_TASK_ASSIGNMENT_ID NUMBER)
IS
   SELECT OBJECT_VERSION_NUMBER
   FROM   JTF_TASK_ASSIGNMENTS
   WHERE  TASK_ASSIGNMENT_ID = B_TASK_ASSIGNMENT_ID;


l_Aux_Name_List   Csm_Varchar_List;
l_aux_Value_List  Csm_Varchar_List;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Task Assignment
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  L_COL_VALUE_LIST(I) IS NOT NULL THEN

      IF l_COL_NAME_LIST(i) = 'ASSIGNEE_ROLE' THEN
        L_ASSIGNEE_ROLE := L_COL_VALUE_LIST(I);
      ELSIF l_COL_NAME_LIST(i) = 'TASK_ASSIGNMENT_ID' THEN
        L_TASK_ASSIGNMENT_REC.TASK_ASSIGNMENT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_ID' THEN
        L_TASK_ASSIGNMENT_REC.TASK_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_TYPE_CODE' THEN
        L_TASK_ASSIGNMENT_REC.RESOURCE_TYPE_CODE  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_ID' THEN
        L_TASK_ASSIGNMENT_REC.RESOURCE_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ASSIGNMENT_STATUS_ID' THEN
        L_TASK_ASSIGNMENT_REC.ASSIGNMENT_STATUS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_EFFORT' THEN
        L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'RESOURCE_TERRITORY_ID' THEN
        L_TASK_ASSIGNMENT_REC.RESOURCE_TERRITORY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_EFFORT_UOM' THEN
        L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT_UOM  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SCHEDULE_FLAG' THEN
        L_TASK_ASSIGNMENT_REC.SCHEDULE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_TYPE_CODE' THEN
        L_TASK_ASSIGNMENT_REC.ALARM_TYPE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_CONTACT' THEN
        L_TASK_ASSIGNMENT_REC.ALARM_CONTACT  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SHIFT_CONSTRUCT_ID' THEN
       L_TASK_ASSIGNMENT_REC.SHIFT_CONSTRUCT_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHED_TRAVEL_DISTANCE' THEN
       L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DISTANCE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHED_TRAVEL_DURATION' THEN
       L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHED_TRAVEL_DURATION_UOM' THEN
       L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION_UOM := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_TRAVEL_DISTANCE' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DISTANCE := NULL; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_TRAVEL_DURATION' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_TRAVEL_DURATION_UOM' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION_UOM := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_START_DATE' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_END_DATE' THEN
       L_TASK_ASSIGNMENT_REC.ACTUAL_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PALM_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.PALM_FLAG   := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'WINCE_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.WINCE_FLAG := null; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAPTOP_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.LAPTOP_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE1_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.DEVICE1_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DEVICE2_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.DEVICE2_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE3_FLAG' THEN
       L_TASK_ASSIGNMENT_REC.DEVICE3_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_TASK_ASSIGNMENT_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'SHOW_ON_CALENDAR' THEN
       L_TASK_ASSIGNMENT_REC.SHOW_ON_CALENDAR := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CATEGORY_ID' THEN
       L_TASK_ASSIGNMENT_REC.CATEGORY_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'FREE_BUSY_TYPE' THEN
       L_FREE_BUSY_TYPE := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OBJECT_CAPACITY_ID' THEN
       L_OBJECT_CAPACITY_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OBJECT_VERSION_NUMBER' THEN
       L_OBJECT_VERSION_NUMBER := L_COL_VALUE_LIST(I)-1;
      END IF;

     END IF;
  END LOOP;

  --Get the Latest Version number from the DB
  OPEN  C_GET_TA_VERSION( L_TASK_ASSIGNMENT_REC.TASK_ASSIGNMENT_ID );
  FETCH C_GET_TA_VERSION INTO L_OBJECT_VERSION_NUMBER;
  CLOSE C_GET_TA_VERSION;

  --Process only if assignee role is assignee
  IF L_ASSIGNEE_ROLE = 'ASSIGNEE' THEN
      JTF_TASK_ASSIGNMENTS_PUB.UPDATE_TASK_ASSIGNMENT(
          P_API_VERSION		            => 1.0,
          p_object_version_number     => L_OBJECT_VERSION_NUMBER,
          P_INIT_MSG_LIST		          => FND_API.G_TRUE,
          P_COMMIT		                => FND_API.G_FALSE,
          P_TASK_ASSIGNMENT_ID        => L_TASK_ASSIGNMENT_REC.TASK_ASSIGNMENT_ID ,
          P_TASK_ID                   => L_TASK_ASSIGNMENT_REC.TASK_ID ,
          P_TASK_NUMBER		            => NULL,
          P_TASK_NAME                 => NULL,
          P_RESOURCE_TYPE_CODE        => L_TASK_ASSIGNMENT_REC.RESOURCE_TYPE_CODE ,
          P_RESOURCE_ID               => L_TASK_ASSIGNMENT_REC.RESOURCE_ID ,
          P_RESOURCE_NAME             => NULL,
          P_ACTUAL_EFFORT             => L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT ,
          P_ACTUAL_EFFORT_UOM         => L_TASK_ASSIGNMENT_REC.ACTUAL_EFFORT_UOM ,
          P_SCHEDULE_FLAG             => L_TASK_ASSIGNMENT_REC.SCHEDULE_FLAG ,
          P_ALARM_TYPE_CODE           => L_TASK_ASSIGNMENT_REC.ALARM_TYPE_CODE ,
          P_ALARM_CONTACT             => L_TASK_ASSIGNMENT_REC.ALARM_CONTACT ,
          P_SCHED_TRAVEL_DISTANCE     => L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DISTANCE ,
          P_SCHED_TRAVEL_DURATION     => L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION ,
          P_SCHED_TRAVEL_DURATION_UOM => L_TASK_ASSIGNMENT_REC.SCHED_TRAVEL_DURATION_UOM ,
          P_ACTUAL_TRAVEL_DISTANCE    => L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DISTANCE ,
          P_ACTUAL_TRAVEL_DURATION    => L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION ,
          P_ACTUAL_TRAVEL_DURATION_UOM=> L_TASK_ASSIGNMENT_REC.ACTUAL_TRAVEL_DURATION_UOM ,
          P_ACTUAL_START_DATE         => L_TASK_ASSIGNMENT_REC.ACTUAL_START_DATE ,
          P_ACTUAL_END_DATE           => L_TASK_ASSIGNMENT_REC.ACTUAL_END_DATE ,
          P_PALM_FLAG                 => L_TASK_ASSIGNMENT_REC.PALM_FLAG ,
          P_WINCE_FLAG                => L_TASK_ASSIGNMENT_REC.WINCE_FLAG ,
          P_LAPTOP_FLAG               => L_TASK_ASSIGNMENT_REC.LAPTOP_FLAG ,
          P_DEVICE1_FLAG              => L_TASK_ASSIGNMENT_REC.DEVICE1_FLAG ,
          P_DEVICE2_FLAG              => L_TASK_ASSIGNMENT_REC.DEVICE2_FLAG ,
          P_DEVICE3_FLAG              => L_TASK_ASSIGNMENT_REC.DEVICE3_FLAG ,
          P_RESOURCE_TERRITORY_ID     => L_TASK_ASSIGNMENT_REC.RESOURCE_TERRITORY_ID,
          P_ASSIGNMENT_STATUS_ID      => L_TASK_ASSIGNMENT_REC.ASSIGNMENT_STATUS_ID ,
          P_SHIFT_CONSTRUCT_ID        => L_TASK_ASSIGNMENT_REC.SHIFT_CONSTRUCT_ID ,
          X_RETURN_STATUS		          => L_RETURN_STATUS ,
          X_MSG_COUNT                 => L_MSG_COUNT ,
          X_MSG_DATA			            => L_MSG_DATA ,
          P_ATTRIBUTE1                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE1 ,
          P_ATTRIBUTE2                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE2 ,
          P_ATTRIBUTE3                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE3 ,
          P_ATTRIBUTE4                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE4 ,
          P_ATTRIBUTE5                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE5 ,
          P_ATTRIBUTE6                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE6 ,
          P_ATTRIBUTE7                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE7 ,
          P_ATTRIBUTE8                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE8 ,
          P_ATTRIBUTE9                => L_TASK_ASSIGNMENT_REC.ATTRIBUTE9 ,
          P_ATTRIBUTE10               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE10 ,
          P_ATTRIBUTE11               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE11 ,
          P_ATTRIBUTE12               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE12 ,
          P_ATTRIBUTE13               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE13 ,
          P_ATTRIBUTE14               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE14 ,
          P_ATTRIBUTE15               => L_TASK_ASSIGNMENT_REC.ATTRIBUTE15 ,
          P_ATTRIBUTE_CATEGORY        => L_TASK_ASSIGNMENT_REC.ATTRIBUTE_CATEGORY ,
          P_SHOW_ON_CALENDAR          => L_TASK_ASSIGNMENT_REC.SHOW_ON_CALENDAR ,
          P_CATEGORY_ID               => L_TASK_ASSIGNMENT_REC.CATEGORY_ID,
          P_ENABLE_WORKFLOW           => 'N' ,
          P_ABORT_WORKFLOW            => 'Y' ,
          P_OBJECT_CAPACITY_ID        => L_OBJECT_CAPACITY_ID
           );

      IF l_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
          --After Successful TA Insert process Object Capacity Updates
          FOR R_GET_AUX_OBJECTS IN C_GET_AUX_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
             CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUX_OBJECTS.HA_PAYLOAD_ID
                                  ,X_RETURN_STATUS => L_RETURN_STATUS
                                  ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);
          END LOOP;

          IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
            --After Successful TA and OC Insert process TA audit
            BEGIN
              FOR R_GET_AUD_OBJECTS IN C_GET_AUD_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
                CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUD_OBJECTS.HA_PAYLOAD_ID
                                    ,X_RETURN_STATUS => L_AUD_RETURN_STATUS
                                    ,x_ERROR_MESSAGE => l_AUD_ERROR_MESSAGE);
              END LOOP;
            EXCEPTION
            WHEN OTHERS THEN
              NULL;
            END;
            x_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
          ELSE --OC FAILURE
            X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
            X_ERROR_MESSAGE := L_ERROR_MESSAGE;
          END IF;
      ELSE --TA FAILURE
          /*** exception occurred in API -> return errmsg ***/
          s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
          (
              p_api_error      => TRUE
          );

          X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
          X_ERROR_MESSAGE := S_MSG_DATA;
        END IF;
  ELSE --check for assignee
          X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
          X_ERROR_MESSAGE := 'Record Not Processed.Task assignments with Assignee role as Assignee alone will be processed';

  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_UPDATE', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_UPDATE: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_Error_Message := S_Msg_Data;
END APPLY_HA_UPDATE;
--Apply Delete
PROCEDURE APPLY_HA_DELETE
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           p_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )
IS
L_HA_PAYLOAD_ID       NUMBER;
L_COL_NAME_LIST       CSM_VARCHAR_LIST;
L_COL_VALUE_LIST      CSM_VARCHAR_LIST;
l_CON_NAME_LIST       CSM_VARCHAR_LIST;
L_CON_VALUE_LIST      CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
L_AUD_RETURN_STATUS   VARCHAR2(200);
L_AUD_ERROR_MESSAGE   VARCHAR2(2000);
L_TASK_ASSIGNMENT_ID  NUMBER := NULL;
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_OBJECT_VERSION_NUMBER NUMBER;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_DELETE',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID   := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Task Assignment
  FOR I IN 1..L_COL_NAME_LIST.COUNT-1 LOOP
    EXIT WHEN L_TASK_ASSIGNMENT_ID IS NOT NULL;
    IF  L_COL_VALUE_LIST(I) IS NOT NULL THEN
      IF l_COL_NAME_LIST(i) = 'TASK_ASSIGNMENT_ID' THEN
        L_TASK_ASSIGNMENT_ID := l_COL_VALUE_LIST(i);
      END IF;
     END IF;
  END LOOP;

  JTF_TASK_ASSIGNMENTS_PUB.DELETE_TASK_ASSIGNMENT(
      P_API_VERSION		            => 1.0,
      P_OBJECT_VERSION_NUMBER     => L_OBJECT_VERSION_NUMBER,
      P_INIT_MSG_LIST		          => FND_API.G_TRUE,
      P_COMMIT		                => FND_API.G_FALSE,
      P_TASK_ASSIGNMENT_ID        => L_TASK_ASSIGNMENT_ID ,
      X_RETURN_STATUS             => L_RETURN_STATUS ,
      X_MSG_COUNT                 => L_MSG_COUNT ,
      X_MSG_DATA                  => L_MSG_DATA ,
      P_ENABLE_WORKFLOW           => FND_PROFILE.VALUE('JTF_TASK_ENABLE_WORKFLOW') ,
      P_ABORT_WORKFLOW            => FND_PROFILE.VALUE('JTF_TASK_ABORT_PREV_WF')
       );

    IF l_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
      --After Successful TA Insert process Object Capacity Updates
      FOR R_GET_AUX_OBJECTS IN C_GET_AUX_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
         CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUX_OBJECTS.HA_PAYLOAD_ID
                              ,X_RETURN_STATUS => L_RETURN_STATUS
                              ,x_ERROR_MESSAGE => L_ERROR_MESSAGE);
      END LOOP;

      IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
        --After Successful TA and OC Delete process TA audit

        BEGIN
          FOR R_GET_AUD_OBJECTS IN C_GET_AUD_OBJECTS(P_HA_PAYLOAD_ID)  LOOP
            CSM_HA_PROCESS_PKG.PROCESS_DIRECT_DML(P_PAYLOAD_ID => R_GET_AUD_OBJECTS.HA_PAYLOAD_ID
                                ,X_RETURN_STATUS => L_AUD_RETURN_STATUS
                                ,x_ERROR_MESSAGE => l_AUD_ERROR_MESSAGE);
          END LOOP;
        EXCEPTION
        WHEN OTHERS THEN
          NULL;
        END;
        X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
      ELSE --OC FAILURE
        X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        X_ERROR_MESSAGE := L_ERROR_MESSAGE;
      END IF;
    ELSE --TA FAILURE
      /*** exception occurred in API -> return errmsg ***/
      s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
          p_api_error      => TRUE
      );

      X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
      X_ERROR_MESSAGE := S_MSG_DATA;
    END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_DELETE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_DELETE', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_DELETE: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_DELETE',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_Error_Message := S_Msg_Data;
END APPLY_HA_DELETE;

PROCEDURE APPLY_HA_CHANGES
          (p_HA_PAYLOAD_ID  IN  NUMBER,
           P_COL_NAME_LIST  IN  CSM_VARCHAR_LIST,
           p_COL_VALUE_LIST IN  CSM_VARCHAR_LIST,
           p_dml_type       IN  VARCHAR2,
           x_RETURN_STATUS  OUT NOCOPY VARCHAR2,
           x_ERROR_MESSAGE  OUT NOCOPY VARCHAR2
         )IS
L_RETURN_STATUS  VARCHAR2(100);
l_ERROR_MESSAGE  VARCHAR2(4000);
BEGIN
  /*** initialize return status and message list ***/
  L_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

  IF p_dml_type ='I' THEN
    -- Process insert
            APPLY_HA_INSERT
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                x_ERROR_MESSAGE  => l_ERROR_MESSAGE
              );
  ELSIF p_dml_type ='U' THEN
    -- Process update
            APPLY_HA_UPDATE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  ELSIF P_DML_TYPE ='D' THEN
    -- Process Delete
            APPLY_HA_DELETE
                (p_HA_PAYLOAD_ID  =>p_HA_PAYLOAD_ID,
                p_COL_NAME_LIST  => P_COL_NAME_LIST,
                p_COL_VALUE_LIST => p_COL_VALUE_LIST,
                x_RETURN_STATUS  => l_RETURN_STATUS,
                X_ERROR_MESSAGE  => L_ERROR_MESSAGE
              );
  END IF;
  X_RETURN_STATUS := l_RETURN_STATUS;
  x_ERROR_MESSAGE := l_ERROR_MESSAGE;
  CSM_UTIL_PKG.LOG('Leaving CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASK_ASSIGNMENTS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_CHANGES;

END CSM_TASK_ASSIGNMENTS_PKG; -- Package spec

/
