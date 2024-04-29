--------------------------------------------------------
--  DDL for Package Body CSM_TASKS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_TASKS_PKG" AS
/* $Header: csmutskb.pls 120.12.12010000.12 2010/05/13 08:22:53 trajasek ship $ */

  /*
   * The function to be called by CSM_SERVICEP_WRAPPER_PKG, for upward sync of
   * publication item CSM_TASKS
   */
-- Purpose: Update Tasks changes on Handheld to Enterprise database
--
-- MODIFICATION HISTORY
-- Person      Date                 Comments
-- DBhagat     11th September 2002  Created
--
-- ---------   -------------------  ------------------------------------------
   -- Enter package declarations as shown below

/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_TASKS_PKG';  -- package name
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_TASKS';  -- publication item name
g_debug_level           NUMBER; -- debug level

CURSOR c_tasks_inq( b_user_name VARCHAR2, b_tranid NUMBER) IS
  SELECT *
  FROM  csm_tasks_inq
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name;


/***
  This procedure is called by APPLY_CRECORD when
  an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_tasks_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2,
           x_reject_row    OUT NOCOPY BOOLEAN   --Bug 5288413
         ) IS
--Bug 5288413
CURSOR c_is_private_owner(b_task_type_id NUMBER) IS
 SELECT decode(NVL(PRIVATE_FLAG,'N'),'Y',1,0)
 FROM  JTF_TASK_TYPES_B
 WHERE TASK_TYPE_ID = b_task_type_id;

--Bug 5288413
CURSOR c_res_id (b_user_name VARCHAR2) IS
 SELECT RESOURCE_ID
 FROM ASG_USER
 WHERE USER_NAME=b_user_name;

CURSOR c_csm_appl IS
  SELECT APPLICATION_ID
  FROM fnd_application
  WHERE application_short_name = 'CSM';

CURSOR c_csm_resp(c_user_id NUMBER)
IS
  SELECT RESPONSIBILITY_ID
  FROM   ASG_USER
  WHERE USER_ID = c_user_id;

  -- Declare OUT parameters
  l_msg_count             NUMBER;
  l_msg_data              VARCHAR2(240);
  l_task_id              jtf_tasks_b.task_id%TYPE;

  -- Declare default parameters
  l_task_type       jtf_tasks_b.task_type_id%TYPE;
  l_task_status     jtf_tasks_b.task_status_id%TYPE;
  l_task_priority   jtf_tasks_b.task_priority_id%TYPE;
  l_task_source_object_name jtf_tasks_b.source_object_name%TYPE;
  l_address_id      JTF_TASKS_B.ADDRESS_ID%TYPE := null;
  l_customer_id     JTF_TASKS_B.CUSTOMER_ID%TYPE;
  l_incident_location_type     CS_INCIDENTS_ALL_B.INCIDENT_LOCATION_TYPE%TYPE;
  l_incident_location_id     CS_INCIDENTS_ALL_B.INCIDENT_LOCATION_ID%TYPE;
  l_location_id     JTF_TASKS_B.LOCATION_ID%TYPE := null;
  l_owner_id        JTF_tasks_b.owner_id%type :=null;
  l_owner_type      JTF_tasks_b.owner_type_code%type :=null;
  l_is_private      NUMBER;
  l_sync_resource_id l_owner_id%TYPE;
  l_responsibility_id     NUMBER;
  l_csm_appl_id           NUMBER;
  l_territory_assign      VARCHAR2(255);
  l_service_request_rec   CS_ServiceRequest_PUB.service_request_rec_type;
  l_task_attribute_rec    CS_SR_TASK_AUTOASSIGN_PKG.SR_Task_rec_type;
  l_owner_group_id        NUMBER;
  l_group_type            VARCHAR(240);
  l_territory_id          NUMBER;
  l_profile_value         VARCHAR2(240);

BEGIN

  -- Retrieve default value if null according to profiles --
  IF p_record.task_type_id IS NULL THEN
    l_task_type := csm_profile_pkg.value_specific('JTF_TASK_DEFAULT_TASK_TYPE', p_record.created_by);
  ELSE
    l_task_type := p_record.task_type_id;
  END IF;

--Bug 5288413
  x_reject_row :=TRUE;

  OPEN c_res_id(p_record.clid$$cs);
  FETCH c_res_id INTO l_sync_resource_id;
  CLOSE c_res_id;

  OPEN c_is_private_owner(l_task_type);
  FETCH c_is_private_owner INTO l_is_private;
  CLOSE c_is_private_owner;

  -- Bug 5336807
  l_task_priority := p_record.task_priority_id;

  IF p_record.task_status_id IS NULL THEN
    l_task_status := csm_profile_pkg.value_specific('CSF_DEFAULT_TASK_INPLANNING_STATUS', p_record.created_by);
  ELSE
     l_task_status := p_record.task_status_id;
  END IF;

--R12Asset
  IF p_record.source_object_type_code = 'SR' THEN
    SELECT INCIDENT_NUMBER, INCIDENT_LOCATION_ID,
           CUSTOMER_ID,INCIDENT_LOCATION_TYPE
    INTO l_task_source_object_name , l_incident_location_id,
         l_customer_id,l_incident_location_type
    FROM CS_INCIDENTS_ALL_B
    WHERE INCIDENT_ID = p_record.source_object_id;

-- Note: location_type is HZ_LOCATION in CS_INCIDENTS_ALL_B and
-- HZ_LOCATIONS in CSI_ITEM_INSTANCES
    IF  l_incident_location_type = 'HZ_LOCATION' THEN
      l_location_id := l_incident_location_id;
    ELSE
      l_address_id := l_incident_location_id;
    END IF;
  ELSE --Personal Task
      l_location_id := p_record.location_id;
  END IF;

  --Get Mobile responsibility
  OPEN c_csm_resp(p_record.created_by);
  FETCH c_csm_resp INTO l_responsibility_id;
  CLOSE c_csm_resp;
  -- get csm application id
  OPEN c_csm_appl;
  FETCH c_csm_appl INTO l_csm_appl_id;
  CLOSE c_csm_appl;

  --Get Task Assignment Manger profile
  l_territory_assign := fnd_profile.value_specific('CSM_SELECT_TASK_THRU_TERRITORY_ASSIGN'
                                          , p_record.created_by
                                          , l_responsibility_id
                                          , l_csm_appl_id);

  IF l_territory_assign = 'Y' AND p_record.source_object_type_code ='SR' THEN

    l_task_attribute_rec.task_type_id     := l_task_type;
    l_task_attribute_rec.task_status_id   := l_task_status;
    l_task_attribute_rec.task_priority_id := l_task_priority;

   CS_SR_TASK_AUTOASSIGN_PKG.Assign_Task_Resource
     (p_api_version            => 1.0,
      p_init_msg_list          => fnd_api.g_true,
      p_commit                 => fnd_api.g_false,
      p_incident_id            => p_record.source_object_id,
      p_service_request_rec    => l_service_request_rec,
      p_task_attribute_rec     => l_task_attribute_rec,
      x_owner_group_id         => l_owner_group_id,
      x_group_type             => l_group_type,
      x_owner_type             => l_owner_type,
      x_owner_id               => l_owner_id,
      x_territory_id           => l_territory_id,
      x_return_status          => x_return_status,
      x_msg_count              => l_msg_count,
      x_msg_data               => l_msg_data
    );

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      IF l_owner_id IS NULL THEN
          l_owner_type  := l_group_type;
          l_owner_id    := l_owner_group_id;
      END IF;
    ELSE
      x_return_status := FND_API.G_RET_STS_ERROR;

      CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
        || ' ROOT ERROR: CS_SR_TASK_AUTOASSIGN_PKG.Assign_Task_Resource'
        || ' for PK ' || p_record.TASK_ID || l_msg_data,
        g_object_name || '.APPLY_INSERT',
        FND_LOG.LEVEL_ERROR );
    END IF;
  ELSE
    l_owner_type := csm_profile_pkg.value_specific('INC_DEFAULT_INCIDENT_TASK_OWNER_TYPE', p_record.created_by);
    l_owner_id   := csm_profile_pkg.value_specific('INC_DEFAULT_INCIDENT_TASK_OWNER', p_record.created_by);

  END IF;

  IF l_is_private=1 OR  l_owner_type IS NULL OR l_owner_id IS NULL THEN
      l_owner_type := 'RS_EMPLOYEE';
      l_owner_id :=l_sync_resource_id;
  END IF;

  -- Create new Task
  jtf_tasks_pub.Create_Task
    ( p_api_version               => 1.0,
      p_init_msg_list             => fnd_api.g_true,
      p_commit                    => fnd_api.g_false,
      p_task_id                   => p_record.task_id,
      p_task_name                 => p_record.task_name,
      p_task_type_id              => l_task_type,
      p_description               => p_record.description,
      p_task_status_id            => l_task_status,
      p_task_priority_id          => l_task_priority,
      p_owner_type_code           => l_owner_type,
      p_owner_id                  => l_owner_id,
      p_owner_territory_id        => l_territory_id,
      p_planned_start_date        => p_record.planned_start_date,
      p_planned_end_date          => p_record.planned_end_date,
      p_scheduled_start_date      => p_record.scheduled_start_date,
      p_scheduled_end_date        => p_record.scheduled_end_date,
      -- bug 4248868
--      p_actual_start_date         => p_record.actual_start_date,
--      p_actual_end_date           => p_record.actual_end_date,
      p_source_object_type_code   => p_record.source_object_type_code,
      p_source_object_id          => p_record.source_object_id,
      p_source_object_name        => l_task_source_object_name,
      p_planned_effort            => p_record.planned_effort,
      p_planned_effort_uom        => p_record.planned_effort_uom,
      p_escalation_level          => p_record.escalation_level,
      p_address_id                => l_address_id,
      x_return_status             => x_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data,
      x_task_id                   => l_task_id,
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
      p_attribute_category        => p_record.attribute_category,
      p_customer_id	          => NVL(p_record.customer_id, l_customer_id),
      p_location_id               => l_location_id,
	  p_cust_account_id			  => p_record.cust_account_id
      );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_INSERT:'
      || ' ROOT ERROR: jtf_tasks_pub.Create_Task'
      || ' for PK ' || p_record.TASK_ID,
      g_object_name || '.APPLY_INSERT',
      FND_LOG.LEVEL_ERROR );
    RETURN ;
  END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN others THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT:'
       || ' for PK ' || p_record.task_id,
       g_object_name || '.APPLY_INSERT',
       FND_LOG.LEVEL_EXCEPTION );

     x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_INSERT;


/***
  This procedure is called by APPLY_CRECORD when
  an updated record is to be processed.
  For CSM 11583, we support updates on the DFF columns
***/
PROCEDURE APPLY_UPDATE
         (
           p_record        IN c_tasks_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2
         )
IS
CURSOR	 c_task ( b_task_id NUMBER ) IS
SELECT 	 object_version_number
FROM   	 jtf_tasks_b
WHERE  	 task_id = b_task_id;

CURSOR c_last_update_date ( b_task_id NUMBER)
IS
SELECT LAST_UPDATE_DATE,
       last_updated_by
FROM   jtf_tasks_b
WHERE  task_id = b_task_id;

--variable declarations
  r_task 	   	 		c_task%ROWTYPE;
  r_last_update_date	c_last_update_date%ROWTYPE;
  l_profile_value     	VARCHAR2(240);
  l_msg_count          	NUMBER;
  l_msg_data            VARCHAR2(240);
  l_uom_class  			MTL_UNITS_OF_MEASURE.UOM_CLASS%TYPE;
  l_plan_eff_uom		CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE;
  l_min_uom  			CSM_UNIT_OF_MEASURE_TL_ACC.UOM_CODE%TYPE;
  l_planned_effort		NUMBER;
  l_user_id				NUMBER;

BEGIN
  l_profile_value := fnd_profile.value('JTM_APPL_CONFLICT_RULE');
  l_user_id		  := asg_base.get_user_id(p_record.clid$$cs);

  IF l_profile_value = 'SERVER_WINS' AND
     ASG_DEFER.IS_DEFERRED(p_record.clid$$cs, p_record.tranid$$,g_pub_name, p_record.seqno$$) <> FND_API.G_TRUE
  THEN
    OPEN  c_last_update_date(b_task_id => p_record.task_id);
    FETCH c_last_update_date INTO r_last_update_date;

    IF c_last_update_date%FOUND THEN
      IF (r_last_update_date.last_update_date <> p_record.server_last_update_date AND r_last_update_date.last_updated_by <> asg_base.get_user_id(p_record.clid$$cs)) THEN
        CLOSE c_last_update_date;
        CSM_UTIL_PKG.log( 'Record has stale data. Leaving  ' || g_object_name || '.APPLY_INSERT:'
          || ' for PK ' || p_record.task_id,
          g_object_name || '.APPLY_INSERT',
          FND_LOG.LEVEL_PROCEDURE );
        fnd_message.set_name
          ( 'JTM'
          , 'JTM_STALE_DATA'
          );
        fnd_msg_pub.add;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
      END IF;
    ELSE
      CSM_UTIL_PKG.log( 'No record found in Apps Database in ' || g_object_name || '.APPLY_INSERT:',
          g_object_name || '.APPLY_INSERT',
          FND_LOG.LEVEL_PROCEDURE );
    END IF;
    CLOSE c_last_update_date;
  END IF;

  -- get object version from task record so client updates succeed even when record was updated
  -- on server side (CLIENT_WINS)
  OPEN  c_task( p_record.task_id );
  FETCH c_task INTO r_task;
  CLOSE c_task;

  --Get planned effort
  	IF p_record.planned_effort_uom IS NULL THEN
		l_plan_eff_uom := CSM_PROFILE_PKG.VALUE_SPECIFIC('CSF_DEFAULT_EFFORT_UOM',l_user_id,NULL,NULL);
	ELSE
		l_plan_eff_uom := p_record.planned_effort_uom;
	END IF;

	l_uom_class := CSM_PROFILE_PKG.VALUE_SPECIFIC('JTF_TIME_UOM_CLASS',l_user_id,NULL,NULL);
	l_min_uom	:= CSM_PROFILE_PKG.VALUE_SPECIFIC('CSF_UOM_MINUTES',l_user_id,NULL,NULL);
	--Get planned effort for the required UOM
  	l_planned_effort := csm_util_pkg.Get_Datediff_For_Req_UOM(
							 p_record.scheduled_start_date,
							 p_record.scheduled_end_date,
							 l_uom_class,
							 l_plan_eff_uom,
							 l_min_uom
							 );

  -- Update the task.
  JTF_TASKS_PUB.Update_Task (
      p_api_version             => 1.0,
      p_init_msg_list           => FND_API.G_TRUE,
      p_commit                  => FND_API.G_FALSE,
      p_task_id                 => p_record.TASK_ID,
      p_description             => p_record.description,
      p_object_version_number   => r_task.object_version_number,
      p_planned_start_date        => p_record.planned_start_date,
      p_planned_end_date          => p_record.planned_end_date,
      p_scheduled_start_date      => p_record.scheduled_start_date,
      p_scheduled_end_date        => p_record.scheduled_end_date,
      -- bug 4248868
--      p_actual_start_date         => p_record.actual_start_date,
--      p_actual_end_date           => p_record.actual_end_date,
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
      p_attribute_category        => p_record.attribute_category,
      x_return_status             => x_return_status,
      x_msg_count                 => l_msg_count,
      x_msg_data                  => l_msg_data,
      p_planned_effort            => l_planned_effort,
      p_planned_effort_uom        => l_plan_eff_uom,
      p_cust_account_id	          => p_record.cust_account_id,
      p_task_priority_id          => p_record.task_priority_id
     );

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS
  THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    CSM_UTIL_PKG.log( 'Error in ' || g_object_name || '.APPLY_UPDATE:'
      || ' ROOT ERROR: jtf_tasks_pub.UPDATE_TASK'
      || ' for PK ' || p_record.TASK_ID,
      g_object_name || '.APPLY_UPDATE',
      FND_LOG.LEVEL_ERROR );
    RETURN ;
  END IF;

  -- success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN others THEN
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_UPDATE:'
       || ' for PK ' || p_record.task_id,
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
           p_record        IN     c_tasks_inq%ROWTYPE,
           p_error_msg     OUT NOCOPY    VARCHAR2,
           x_return_status IN OUT NOCOPY VARCHAR2,
           x_reject_row    OUT NOCOPY BOOLEAN  --Bug 5288413
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
        x_return_status,
        x_reject_row         --Bug 5288413
      );
  ELSIF p_record.dmltype$$='U' THEN -- YLIAO: for 11583, we do support UPDATE
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
      ( 'Delete and Update is not supported for this entity'
        || ' for PK ' || p_record.task_id ,
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

EXCEPTION
WHEN OTHERS THEN
  /*** defer record when any process exception occurs ***/
  CSM_UTIL_PKG.LOG
    ( 'Exception occurred in ' || g_object_name || '.APPLY_RECORD:' || ' ' || SQLERRM
      || ' for PK ' || p_record.task_id ,
      g_object_name || '.APPLY_RECORD',
      FND_LOG.LEVEL_EXCEPTION);
  -- temp -- find more detail --remove comment
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', SQLERRM);
  p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
      p_api_error      => TRUE
    );

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;


/***
  APPLY_CLIENT_CHANGE procedure is called by CSM_SERVICEP_WRAPPER_PKG, for upward sync of
  publication item CSM_TASKS
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
  l_return_status  VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);
  l_reject_row     boolean := FALSE;
BEGIN
  csm_util_pkg.log
  ( g_object_name || '.APPLY_CLIENT_CHANGES entered',
    g_object_name || '.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through tasks records in inqueue ***/
  FOR r_tasks IN c_tasks_inq( p_user_name, p_tranid) LOOP

    SAVEPOINT save_rec;

    /*** apply record ***/
    APPLY_RECORD
      (
        r_tasks
      , l_error_msg
      , l_process_status
      , l_reject_row     --Bug 5288413
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** If Yes -> delete record from inqueue ***/
--Bug 5288413
      IF l_reject_row  THEN
       CSM_UTIL_PKG.REJECT_RECORD
        (
          p_user_name,
          p_tranid,
          r_tasks.seqno$$,
          r_tasks.task_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_return_status
        );

      --Bug 8931803 - Asg REJECT_ROW doesn't call delete_row on reapply as the record was deferred.
        IF (l_return_status = FND_API.G_RET_STS_SUCCESS AND
		    ASG_DEFER.is_deferred(p_user_name,p_tranid,g_pub_name,r_tasks.seqno$$)=FND_API.G_TRUE) THEN
          CSM_UTIL_PKG.DELETE_RECORD
           (
            p_user_name,
            p_tranid,
            r_tasks.seqno$$,
            r_tasks.task_id,
            g_object_name,
            g_pub_name,
            l_error_msg,
            l_return_status
           );
		END IF;
      ELSE
       CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_tasks.seqno$$,
          r_tasks.task_id,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_return_status --Introduced new variable l_return_status since Defer
        );                --process doesn't depend on this delete_record API
      END IF;
      /*** was delete/reject successful? ***/
      IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** If No -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( 'Deleting from inqueue failed, rolling back to savepoint'
          || ' for PK ' || r_tasks.task_id ,
          g_object_name || '.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

    IF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not processed successfully or delete failed
      -> defer and reject record ***/
      CSM_UTIL_PKG.LOG
      ( 'Record not processed successfully, deferring and rejecting record'
        || ' for PK ' || r_tasks.task_id ,
        g_object_name || '.APPLY_CLIENT_CHANGES',
        FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       ( p_user_name
       , p_tranid
       , r_tasks.seqno$$
       , r_tasks.task_id
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_tasks.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
        CSM_UTIL_PKG.LOG
        ( 'Defer record failed, rolling back to savepoint'
          || ' for PK ' || r_tasks.task_id ,
          g_object_name || '.APPLY_CLIENT_CHANGES',
          FND_LOG.LEVEL_ERROR); -- put PK column here
        ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
  CSM_UTIL_PKG.LOG
  ( 'Exception occurred in ' || g_object_name || '.APPLY_CLIENT_CHANGES:' || ' ' || SQLERRM,
    g_object_name || '.APPLY_CLIENT_CHANGES',
    FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

--code for HA
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
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
L_AUD_RETURN_STATUS   VARCHAR2(200);
L_AUD_ERROR_MESSAGE   VARCHAR2(2000);
L_TASKS_REC           JTF_TASKS_B%ROWTYPE;
l_task_id             NUMBER;
L_FREE_BUSY_TYPE      VARCHAR2(100);
L_OBJECT_CAPACITY_ID  NUMBER;
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_API_VERSION    CONSTANT NUMBER := 1.0;
L_TASK_NAME           VARCHAR2(80);
L_DESCRIPTION         VARCHAR2(4000);

Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME NOT IN('JTF_TASK_AUDITS_B','JTF_TASK_AUDITS_TL')
ORDER BY HA_PAYLOAD_ID ASC;

--cursor for Audit Insert
Cursor C_Get_Aud_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME IN('JTF_TASK_AUDITS_B','JTF_TASK_AUDITS_TL')
ORDER BY HA_PAYLOAD_ID ASC;


l_Aux_Name_List   Csm_Varchar_List;
l_aux_Value_List  Csm_Varchar_List;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_TASKS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

--Process Aux Objects
  For R_Get_Aux_Objects In C_Get_Aux_Objects(P_Ha_Payload_Id)  Loop

    CSM_HA_PROCESS_PKG.Parse_Xml(P_Ha_Payload_Id =>R_Get_Aux_Objects.Ha_Payload_Id,
                        X_Col_Name_List  => l_Aux_Name_List,
                        x_COL_VALUE_LIST => l_Aux_Value_List,
                        X_Con_Name_List  => L_CON_NAME_LIST,
                        x_COn_VALUE_LIST => L_CON_VALUE_LIST,
                        X_Return_Status  => L_Return_Status,
                        X_ERROR_MESSAGE  => L_ERROR_MESSAGE);
    IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN

      IF R_GET_AUX_OBJECTS.OBJECT_NAME = 'JTF_TASKS_TL' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
              IF L_AUX_NAME_LIST(I) = 'TASK_NAME' THEN
                L_TASK_NAME := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'DESCRIPTION' THEN
                L_DESCRIPTION := L_AUX_VALUE_LIST(I);
              END IF;
            END LOOP;
           END IF;
      END IF;
    END IF;
  END LOOP;

---Create Task Assignment
  FOR I IN 1..L_COL_NAME_LIST.COUNT-1 LOOP

    IF  L_COL_VALUE_LIST(I) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'TASK_ID' THEN
        L_TASKS_REC.TASK_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_NUMBER' THEN
        L_TASKS_REC.TASK_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_TYPE_ID' THEN
        L_TASKS_REC.TASK_TYPE_ID  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_STATUS_ID' THEN
        L_TASKS_REC.TASK_STATUS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_PRIORITY_ID' THEN
        L_TASKS_REC.TASK_PRIORITY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_ID' THEN
        L_TASKS_REC.OWNER_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_TYPE_CODE' THEN
        L_TASKS_REC.OWNER_TYPE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_TERRITORY_ID' THEN
        L_TASKS_REC.OWNER_TERRITORY_ID  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ASSIGNED_BY_ID' THEN
        L_TASKS_REC.ASSIGNED_BY_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'CUST_ACCOUNT_ID' THEN
        L_TASKS_REC.CUST_ACCOUNT_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_ID' THEN
        L_TASKS_REC.CUSTOMER_ID  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ADDRESS_ID' THEN
       L_TASKS_REC.ADDRESS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'PLANNED_START_DATE' THEN
       L_TASKS_REC.PLANNED_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'PLANNED_END_DATE' THEN
       L_TASKS_REC.PLANNED_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHEDULED_START_DATE' THEN
       L_TASKS_REC.SCHEDULED_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHEDULED_END_DATE' THEN
       L_TASKS_REC.SCHEDULED_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_START_DATE' THEN
       L_TASKS_REC.ACTUAL_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_END_DATE' THEN
       L_TASKS_REC.ACTUAL_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SOURCE_OBJECT_TYPE_CODE' THEN
       L_TASKS_REC.SOURCE_OBJECT_TYPE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SOURCE_OBJECT_ID' THEN
       L_TASKS_REC.SOURCE_OBJECT_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SOURCE_OBJECT_NAME' THEN
       L_TASKS_REC.SOURCE_OBJECT_NAME := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DURATION' THEN
       L_TASKS_REC.DURATION := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DURATION_UOM' THEN
       L_TASKS_REC.DURATION_UOM := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PLANNED_EFFORT' THEN
       L_TASKS_REC.PLANNED_EFFORT := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PLANNED_EFFORT_UOM' THEN
       L_TASKS_REC.PLANNED_EFFORT_UOM := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ACTUAL_EFFORT' THEN
       L_TASKS_REC.ACTUAL_EFFORT := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ACTUAL_EFFORT_UOM' THEN
       L_TASKS_REC.ACTUAL_EFFORT_UOM := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PERCENTAGE_COMPLETE' THEN
       L_TASKS_REC.PERCENTAGE_COMPLETE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'REASON_CODE' THEN
       L_TASKS_REC.REASON_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PRIVATE_FLAG' THEN
       L_TASKS_REC.PRIVATE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PUBLISH_FLAG' THEN
       L_TASKS_REC.PUBLISH_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'RESTRICT_CLOSURE_FLAG' THEN
       L_TASKS_REC.RESTRICT_CLOSURE_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'MULTI_BOOKED_FLAG' THEN
       L_TASKS_REC.MULTI_BOOKED_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'MILESTONE_FLAG' THEN
       L_TASKS_REC.MILESTONE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'HOLIDAY_FLAG' THEN
       L_TASKS_REC.HOLIDAY_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'BILLABLE_FLAG' THEN
       L_TASKS_REC.BILLABLE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'BOUND_MODE_CODE' THEN
       L_TASKS_REC.BOUND_MODE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SOFT_BOUND_FLAG' THEN
       L_TASKS_REC.SOFT_BOUND_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'WORKFLOW_PROCESS_ID' THEN
       L_TASKS_REC.WORKFLOW_PROCESS_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'NOTIFICATION_FLAG' THEN
       L_TASKS_REC.NOTIFICATION_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'NOTIFICATION_PERIOD' THEN
       L_TASKS_REC.NOTIFICATION_PERIOD := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'NOTIFICATION_PERIOD_UOM' THEN
       L_TASKS_REC.NOTIFICATION_PERIOD_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PARENT_TASK_ID' THEN
       L_TASKS_REC.PARENT_TASK_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_START' THEN
       L_TASKS_REC.ALARM_START := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_START_UOM' THEN
       L_TASKS_REC.ALARM_START_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_ON' THEN
       L_TASKS_REC.ALARM_ON := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_COUNT' THEN
       L_TASKS_REC.ALARM_COUNT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_INTERVAL' THEN
       L_TASKS_REC.ALARM_INTERVAL := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_INTERVAL_UOM' THEN
       L_TASKS_REC.ALARM_INTERVAL_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DELETED_FLAG' THEN
       L_TASKS_REC.DELETED_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PALM_FLAG' THEN
       L_TASKS_REC.PALM_FLAG   := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'WINCE_FLAG' THEN
       L_TASKS_REC.WINCE_FLAG := null; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAPTOP_FLAG' THEN
       L_TASKS_REC.LAPTOP_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE1_FLAG' THEN
       L_TASKS_REC.DEVICE1_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DEVICE2_FLAG' THEN
       L_TASKS_REC.DEVICE2_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE3_FLAG' THEN
       L_TASKS_REC.DEVICE3_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'COSTS' THEN
       L_TASKS_REC.COSTS := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'CURRENCY_CODE' THEN
       L_TASKS_REC.CURRENCY_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ESCALATION_LEVEL' THEN
       L_TASKS_REC.ESCALATION_LEVEL := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_TASKS_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_TASKS_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_TASKS_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_TASKS_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_TASKS_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_TASKS_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_TASKS_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_TASKS_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_TASKS_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_TASKS_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_TASKS_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_TASKS_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_TASKS_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_TASKS_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_TASKS_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_TASKS_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DATE_SELECTED' THEN
       L_TASKS_REC.DATE_SELECTED := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TEMPLATE_ID' THEN
       L_TASKS_REC.TEMPLATE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TEMPLATE_GROUP_ID' THEN
       L_TASKS_REC.TEMPLATE_GROUP_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TASK_SPLIT_FLAG' THEN
       L_TASKS_REC.TASK_SPLIT_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CHILD_POSITION' THEN
       L_TASKS_REC.CHILD_POSITION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CHILD_SEQUENCE_NUM' THEN
       L_TASKS_REC.CHILD_SEQUENCE_NUM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LOCATION_ID' THEN
       L_TASKS_REC.LOCATION_ID := L_COL_VALUE_LIST(I);
      END IF;

     END IF;
  END LOOP;

 JTF_TASKS_PUB.CREATE_TASK(
    P_API_VERSION             => L_API_VERSION
  , p_init_msg_list           => fnd_api.g_true
  , P_COMMIT                  => FND_API.G_FALSE
  , P_TASK_ID                 => L_TASKS_REC.TASK_ID
  , P_TASK_NAME               => L_TASK_NAME
  , P_TASK_TYPE_ID            => L_TASKS_REC.TASK_TYPE_ID
  , P_DESCRIPTION             => L_DESCRIPTION
  , P_TASK_STATUS_ID          => L_TASKS_REC.TASK_STATUS_ID
  , P_TASK_PRIORITY_ID        => L_TASKS_REC.TASK_PRIORITY_ID
  , P_OWNER_TYPE_CODE         => L_TASKS_REC.OWNER_TYPE_CODE
  , P_OWNER_ID                => L_TASKS_REC.OWNER_ID
  , P_OWNER_TERRITORY_ID      => L_TASKS_REC.OWNER_TERRITORY_ID
  , P_ASSIGNED_BY_ID          => L_TASKS_REC.ASSIGNED_BY_ID
  , P_CUSTOMER_ID             => L_TASKS_REC.CUSTOMER_ID
  , P_CUST_ACCOUNT_ID         => L_TASKS_REC.CUST_ACCOUNT_ID
  , P_ADDRESS_ID              => L_TASKS_REC.ADDRESS_ID
  , P_PLANNED_START_DATE      => L_TASKS_REC.PLANNED_START_DATE
  , P_PLANNED_END_DATE        => L_TASKS_REC.PLANNED_END_DATE
  , P_SCHEDULED_START_DATE    => L_TASKS_REC.SCHEDULED_START_DATE
  , P_SCHEDULED_END_DATE      => L_TASKS_REC.SCHEDULED_END_DATE
  , P_ACTUAL_START_DATE       => L_TASKS_REC.ACTUAL_START_DATE
  , P_ACTUAL_END_DATE         => L_TASKS_REC.ACTUAL_END_DATE
  , P_SOURCE_OBJECT_TYPE_CODE => L_TASKS_REC.SOURCE_OBJECT_TYPE_CODE
  , P_SOURCE_OBJECT_ID        => L_TASKS_REC.SOURCE_OBJECT_ID
  , P_SOURCE_OBJECT_NAME      => L_TASKS_REC.SOURCE_OBJECT_NAME
  , P_DURATION                => L_TASKS_REC.DURATION
  , P_DURATION_UOM            => L_TASKS_REC.DURATION_UOM
  , P_PLANNED_EFFORT          => L_TASKS_REC.PLANNED_EFFORT
  , P_PLANNED_EFFORT_UOM      => L_TASKS_REC.PLANNED_EFFORT_UOM
  , P_ACTUAL_EFFORT           => L_TASKS_REC.ACTUAL_EFFORT
  , P_ACTUAL_EFFORT_UOM       => L_TASKS_REC.ACTUAL_EFFORT_UOM
  , P_PERCENTAGE_COMPLETE     => L_TASKS_REC.PERCENTAGE_COMPLETE
  , P_REASON_CODE             => L_TASKS_REC.REASON_CODE
  , P_PRIVATE_FLAG            => L_TASKS_REC.PRIVATE_FLAG
  , P_PUBLISH_FLAG            => L_TASKS_REC.PUBLISH_FLAG
  , P_RESTRICT_CLOSURE_FLAG   => L_TASKS_REC.RESTRICT_CLOSURE_FLAG
  , P_MULTI_BOOKED_FLAG       => L_TASKS_REC.MULTI_BOOKED_FLAG
  , P_MILESTONE_FLAG          => L_TASKS_REC.MILESTONE_FLAG
  , P_HOLIDAY_FLAG            => L_TASKS_REC.HOLIDAY_FLAG
  , P_BILLABLE_FLAG           => L_TASKS_REC.BILLABLE_FLAG
  , P_BOUND_MODE_CODE         => L_TASKS_REC.BOUND_MODE_CODE
  , P_SOFT_BOUND_FLAG         => L_TASKS_REC.SOFT_BOUND_FLAG
  , P_WORKFLOW_PROCESS_ID     => L_TASKS_REC.WORKFLOW_PROCESS_ID
  , P_NOTIFICATION_FLAG       => L_TASKS_REC.NOTIFICATION_FLAG
  , P_NOTIFICATION_PERIOD     => L_TASKS_REC.NOTIFICATION_PERIOD
  , p_notification_period_uom => L_TASKS_REC.NOTIFICATION_PERIOD_UOM
  , P_PARENT_TASK_ID          => L_TASKS_REC.PARENT_TASK_ID
  , P_ALARM_START             => L_TASKS_REC.ALARM_START
  , P_ALARM_START_UOM         => L_TASKS_REC.ALARM_START_UOM
  , P_ALARM_ON                => L_TASKS_REC.ALARM_ON
  , P_ALARM_COUNT             => L_TASKS_REC.ALARM_COUNT
  , P_ALARM_INTERVAL          => L_TASKS_REC.ALARM_INTERVAL
  , p_alarm_interval_uom      => L_TASKS_REC.ALARM_INTERVAL_UOM
  , P_PALM_FLAG               => L_TASKS_REC.PALM_FLAG
  , P_WINCE_FLAG              => L_TASKS_REC.WINCE_FLAG
  , P_LAPTOP_FLAG             => L_TASKS_REC.LAPTOP_FLAG
  , P_DEVICE1_FLAG            => L_TASKS_REC.DEVICE1_FLAG
  , P_DEVICE2_FLAG            => L_TASKS_REC.DEVICE2_FLAG
  , P_DEVICE3_FLAG            => L_TASKS_REC.DEVICE3_FLAG
  , P_COSTS                   => L_TASKS_REC.COSTS
  , P_CURRENCY_CODE           => L_TASKS_REC.CURRENCY_CODE
  , P_ESCALATION_LEVEL        => L_TASKS_REC.ESCALATION_LEVEL
  , X_RETURN_STATUS           => L_RETURN_STATUS
  , X_MSG_COUNT               => L_MSG_COUNT
  , X_MSG_DATA                => L_MSG_DATA
  , x_task_id                 =>  l_task_id
  , P_ATTRIBUTE1                => L_TASKS_REC.ATTRIBUTE1
  , P_ATTRIBUTE2                => L_TASKS_REC.ATTRIBUTE2
  , P_ATTRIBUTE3                => L_TASKS_REC.ATTRIBUTE3
  , P_ATTRIBUTE4                => L_TASKS_REC.ATTRIBUTE4
  , P_ATTRIBUTE5                => L_TASKS_REC.ATTRIBUTE5
  , P_ATTRIBUTE6                => L_TASKS_REC.ATTRIBUTE6
  , P_ATTRIBUTE7                => L_TASKS_REC.ATTRIBUTE7
  , P_ATTRIBUTE8                => L_TASKS_REC.ATTRIBUTE8
  , P_ATTRIBUTE9                => L_TASKS_REC.ATTRIBUTE9
  , P_ATTRIBUTE10               => L_TASKS_REC.ATTRIBUTE10
  , P_ATTRIBUTE11               => L_TASKS_REC.ATTRIBUTE11
  , P_ATTRIBUTE12               => L_TASKS_REC.ATTRIBUTE12
  , P_ATTRIBUTE13               => L_TASKS_REC.ATTRIBUTE13
  , P_ATTRIBUTE14               => L_TASKS_REC.ATTRIBUTE14
  , P_ATTRIBUTE15               => L_TASKS_REC.ATTRIBUTE15
  , P_ATTRIBUTE_CATEGORY        => L_TASKS_REC.ATTRIBUTE_CATEGORY
  , p_date_selected           => L_TASKS_REC. DATE_SELECTED
  , P_TEMPLATE_ID             => L_TASKS_REC. TEMPLATE_ID
  , P_TEMPLATE_GROUP_ID       => L_TASKS_REC. TEMPLATE_GROUP_ID
  , p_enable_workflow         => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
  , P_ABORT_WORKFLOW          => FND_PROFILE.VALUE('JTF_TASK_ABORT_PREV_WF')
  , p_task_split_flag         => L_TASKS_REC. TASK_SPLIT_FLAG
  , P_CHILD_POSITION          => L_TASKS_REC.CHILD_POSITION
  , P_CHILD_SEQUENCE_NUM      => L_TASKS_REC.CHILD_SEQUENCE_NUM
  , P_LOCATION_ID             => L_TASKS_REC.LOCATION_ID
  );

/*  , p_task_assign_tbl         IN            task_assign_tbl DEFAULT g_miss_task_assign_tbl
  , p_task_depends_tbl        IN            task_depends_tbl DEFAULT g_miss_task_depends_tbl
  , p_task_rsrc_req_tbl       IN            task_rsrc_req_tbl DEFAULT g_miss_task_rsrc_req_tbl
  , p_task_refer_tbl          IN            task_refer_tbl DEFAULT g_miss_task_refer_tbl
  , p_task_dates_tbl          IN            task_dates_tbl DEFAULT g_miss_task_dates_tbl
  , p_task_notes_tbl          IN            task_notes_tbl DEFAULT g_miss_task_notes_tbl
  , p_task_recur_rec          IN            task_recur_rec DEFAULT g_miss_task_recur_rec
  , P_TASK_CONTACTS_TBL       IN            TASK_CONTACTS_TBL DEFAULT G_MISS_TASK_CONTACTS_TBL
*/
  IF l_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
    --After Successful Task insert process TAsk audit
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
  ELSE
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;

  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_TASKS_PKG.APPLY_HA_INSERT for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_INSERT', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_TASKS_PKG.APPLY_HA_INSERT: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASKS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_Error_Message := S_Msg_Data;
END APPLY_HA_INSERT;
--Apply Update
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
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
L_AUD_RETURN_STATUS   VARCHAR2(200);
L_AUD_ERROR_MESSAGE   VARCHAR2(2000);
L_TASKS_REC           JTF_TASKS_B%ROWTYPE;
l_task_id             NUMBER;
L_FREE_BUSY_TYPE      VARCHAR2(100);
L_OBJECT_CAPACITY_ID  NUMBER;
l_msg_count           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_API_VERSION    CONSTANT NUMBER := 1.0;
L_TASK_NAME           VARCHAR2(80);
L_DESCRIPTION         VARCHAR2(4000);
L_OBJECT_VERSION_NUMBER NUMBER;

Cursor C_Get_Aux_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID,
       OBJECT_NAME,
       DML_TYPE
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME NOT IN('JTF_TASK_AUDITS_B','JTF_TASK_AUDITS_TL')
ORDER BY HA_PAYLOAD_ID ASC;

--cursor for Audit Insert
Cursor C_Get_Aud_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME IN('JTF_TASK_AUDITS_B','JTF_TASK_AUDITS_TL')
ORDER BY HA_PAYLOAD_ID ASC;

CURSOR C_GET_TASK_VERSION( C_TASK_ID NUMBER )
IS
SELECT OBJECT_VERSION_NUMBER FROM
JTF_TASKS_B
WHERE TASK_ID =C_TASK_ID;

l_Aux_Name_List   Csm_Varchar_List;
l_aux_Value_List  Csm_Varchar_List;

BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_TASKS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

--Process Aux Objects
  For R_Get_Aux_Objects In C_Get_Aux_Objects(P_Ha_Payload_Id)  Loop

    CSM_HA_PROCESS_PKG.Parse_Xml(P_Ha_Payload_Id =>R_Get_Aux_Objects.Ha_Payload_Id,
                        X_Col_Name_List  => l_Aux_Name_List,
                        x_COL_VALUE_LIST => l_Aux_Value_List,
                        X_Con_Name_List  => L_CON_NAME_LIST,
                        x_COn_VALUE_LIST => L_CON_VALUE_LIST,
                        X_Return_Status  => L_Return_Status,
                        X_ERROR_MESSAGE  => L_ERROR_MESSAGE);
    IF L_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN

      IF R_GET_AUX_OBJECTS.OBJECT_NAME = 'JTF_TASKS_TL' THEN
           If  L_Return_Status = Fnd_Api.G_Ret_Sts_Success And  L_Aux_Name_List.Count > 0 Then
            FOR I IN 1..L_AUX_NAME_LIST.COUNT-1 LOOP
              IF L_AUX_NAME_LIST(I) = 'TASK_NAME' THEN
                L_TASK_NAME := L_AUX_VALUE_LIST(I);
              ELSIF  L_AUX_NAME_LIST(I) = 'DESCRIPTION' THEN
                L_DESCRIPTION := L_AUX_VALUE_LIST(I);
              END IF;
            END LOOP;
           END IF;
      END IF;
    END IF;
  END LOOP;

---Create Task Assignment
  FOR i in 1..l_COL_NAME_LIST.COUNT-1 LOOP

    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'TASK_ID' THEN
        L_TASKS_REC.TASK_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_NUMBER' THEN
        L_TASKS_REC.TASK_NUMBER := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_TYPE_ID' THEN
        L_TASKS_REC.TASK_TYPE_ID  := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_STATUS_ID' THEN
        L_TASKS_REC.TASK_STATUS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_PRIORITY_ID' THEN
        L_TASKS_REC.TASK_PRIORITY_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_ID' THEN
        L_TASKS_REC.OWNER_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_TYPE_CODE' THEN
        L_TASKS_REC.OWNER_TYPE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'OWNER_TERRITORY_ID' THEN
        L_TASKS_REC.OWNER_TERRITORY_ID  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ASSIGNED_BY_ID' THEN
        L_TASKS_REC.ASSIGNED_BY_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'CUST_ACCOUNT_ID' THEN
        L_TASKS_REC.CUST_ACCOUNT_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'CUSTOMER_ID' THEN
        L_TASKS_REC.CUSTOMER_ID  := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ADDRESS_ID' THEN
       L_TASKS_REC.ADDRESS_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'PLANNED_START_DATE' THEN
       L_TASKS_REC.PLANNED_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'PLANNED_END_DATE' THEN
       L_TASKS_REC.PLANNED_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHEDULED_START_DATE' THEN
       L_TASKS_REC.SCHEDULED_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SCHEDULED_END_DATE' THEN
       L_TASKS_REC.SCHEDULED_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_START_DATE' THEN
       L_TASKS_REC.ACTUAL_START_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ACTUAL_END_DATE' THEN
       L_TASKS_REC.ACTUAL_END_DATE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'SOURCE_OBJECT_TYPE_CODE' THEN
       L_TASKS_REC.SOURCE_OBJECT_TYPE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SOURCE_OBJECT_ID' THEN
       L_TASKS_REC.SOURCE_OBJECT_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SOURCE_OBJECT_NAME' THEN
       L_TASKS_REC.SOURCE_OBJECT_NAME := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DURATION' THEN
       L_TASKS_REC.DURATION := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DURATION_UOM' THEN
       L_TASKS_REC.DURATION_UOM := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PLANNED_EFFORT' THEN
       L_TASKS_REC.PLANNED_EFFORT := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PLANNED_EFFORT_UOM' THEN
       L_TASKS_REC.PLANNED_EFFORT_UOM := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ACTUAL_EFFORT' THEN
       L_TASKS_REC.ACTUAL_EFFORT := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ACTUAL_EFFORT_UOM' THEN
       L_TASKS_REC.ACTUAL_EFFORT_UOM := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PERCENTAGE_COMPLETE' THEN
       L_TASKS_REC.PERCENTAGE_COMPLETE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'REASON_CODE' THEN
       L_TASKS_REC.REASON_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PRIVATE_FLAG' THEN
       L_TASKS_REC.PRIVATE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'PUBLISH_FLAG' THEN
       L_TASKS_REC.PUBLISH_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'RESTRICT_CLOSURE_FLAG' THEN
       L_TASKS_REC.RESTRICT_CLOSURE_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'MULTI_BOOKED_FLAG' THEN
       L_TASKS_REC.MULTI_BOOKED_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'MILESTONE_FLAG' THEN
       L_TASKS_REC.MILESTONE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'HOLIDAY_FLAG' THEN
       L_TASKS_REC.HOLIDAY_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'BILLABLE_FLAG' THEN
       L_TASKS_REC.BILLABLE_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'BOUND_MODE_CODE' THEN
       L_TASKS_REC.BOUND_MODE_CODE := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'SOFT_BOUND_FLAG' THEN
       L_TASKS_REC.SOFT_BOUND_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'WORKFLOW_PROCESS_ID' THEN
       L_TASKS_REC.WORKFLOW_PROCESS_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'NOTIFICATION_FLAG' THEN
       L_TASKS_REC.NOTIFICATION_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'NOTIFICATION_PERIOD' THEN
       L_TASKS_REC.NOTIFICATION_PERIOD := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'NOTIFICATION_PERIOD_UOM' THEN
       L_TASKS_REC.NOTIFICATION_PERIOD_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PARENT_TASK_ID' THEN
       L_TASKS_REC.PARENT_TASK_ID := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_START' THEN
       L_TASKS_REC.ALARM_START := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_START_UOM' THEN
       L_TASKS_REC.ALARM_START_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_ON' THEN
       L_TASKS_REC.ALARM_ON := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_COUNT' THEN
       L_TASKS_REC.ALARM_COUNT := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_INTERVAL' THEN
       L_TASKS_REC.ALARM_INTERVAL := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'ALARM_INTERVAL_UOM' THEN
       L_TASKS_REC.ALARM_INTERVAL_UOM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DELETED_FLAG' THEN
       L_TASKS_REC.DELETED_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'PALM_FLAG' THEN
       L_TASKS_REC.PALM_FLAG   := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'WINCE_FLAG' THEN
       L_TASKS_REC.WINCE_FLAG := null; --l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'LAPTOP_FLAG' THEN
       L_TASKS_REC.LAPTOP_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE1_FLAG' THEN
       L_TASKS_REC.DEVICE1_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  L_COL_NAME_LIST(I) = 'DEVICE2_FLAG' THEN
       L_TASKS_REC.DEVICE2_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'DEVICE3_FLAG' THEN
       L_TASKS_REC.DEVICE3_FLAG := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'COSTS' THEN
       L_TASKS_REC.COSTS := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'CURRENCY_CODE' THEN
       L_TASKS_REC.CURRENCY_CODE := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'ESCALATION_LEVEL' THEN
       L_TASKS_REC.ESCALATION_LEVEL := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE1' THEN
       L_TASKS_REC.ATTRIBUTE1 := L_COL_VALUE_LIST(I);
      ELSIF  l_COL_NAME_LIST(i) = 'ATTRIBUTE2' THEN
       L_TASKS_REC.ATTRIBUTE2 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE3' THEN
       L_TASKS_REC.ATTRIBUTE3 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE4' THEN
       L_TASKS_REC.ATTRIBUTE4 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE5' THEN
       L_TASKS_REC.ATTRIBUTE5 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE6' THEN
       L_TASKS_REC.ATTRIBUTE6 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE7' THEN
       L_TASKS_REC.ATTRIBUTE7 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE8' THEN
       L_TASKS_REC.ATTRIBUTE8 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE9' THEN
       L_TASKS_REC.ATTRIBUTE9 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE10' THEN
       L_TASKS_REC.ATTRIBUTE10 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE11' THEN
       L_TASKS_REC.ATTRIBUTE11 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE12' THEN
       L_TASKS_REC.ATTRIBUTE12 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE13' THEN
       L_TASKS_REC.ATTRIBUTE13 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE14' THEN
       L_TASKS_REC.ATTRIBUTE14 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE15' THEN
       L_TASKS_REC.ATTRIBUTE15 := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'ATTRIBUTE_CATEGORY' THEN
       L_TASKS_REC.ATTRIBUTE_CATEGORY := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'DATE_SELECTED' THEN
       L_TASKS_REC.DATE_SELECTED := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TEMPLATE_ID' THEN
       L_TASKS_REC.TEMPLATE_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TEMPLATE_GROUP_ID' THEN
       L_TASKS_REC.TEMPLATE_GROUP_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'TASK_SPLIT_FLAG' THEN
       L_TASKS_REC.TASK_SPLIT_FLAG := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CHILD_POSITION' THEN
       L_TASKS_REC.CHILD_POSITION := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'CHILD_SEQUENCE_NUM' THEN
       L_TASKS_REC.CHILD_SEQUENCE_NUM := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'LOCATION_ID' THEN
       L_TASKS_REC.LOCATION_ID := L_COL_VALUE_LIST(I);
      ELSIF  L_COL_NAME_LIST(I) = 'OBJECT_VERSION_NUMBER' THEN
       L_OBJECT_VERSION_NUMBER := L_COL_VALUE_LIST(I)-1;
      END IF;

     END IF;
  END LOOP;
  --Get the Latest Version number from the DB
  OPEN  C_GET_TASK_VERSION( L_TASKS_REC.TASK_ID );
  FETCH C_GET_TASK_VERSION INTO L_OBJECT_VERSION_NUMBER;
  CLOSE C_GET_TASK_VERSION;

 JTF_TASKS_PUB.update_task(
    P_API_VERSION             => L_API_VERSION
  , p_init_msg_list           => fnd_api.g_true
  , P_COMMIT                  => FND_API.G_FALSE
  , P_OBJECT_VERSION_NUMBER   => L_OBJECT_VERSION_NUMBER
  , P_TASK_ID                 => L_TASKS_REC.TASK_ID
  , p_task_number             => L_TASKS_REC.TASK_NUMBER
  , P_TASK_NAME               => L_TASK_NAME
  , P_TASK_TYPE_ID            => L_TASKS_REC.TASK_TYPE_ID
  , P_DESCRIPTION             => L_DESCRIPTION
  , P_TASK_STATUS_ID          => L_TASKS_REC.TASK_STATUS_ID
  , P_TASK_PRIORITY_ID        => L_TASKS_REC.TASK_PRIORITY_ID
  , P_OWNER_TYPE_CODE         => L_TASKS_REC.OWNER_TYPE_CODE
  , P_OWNER_ID                => L_TASKS_REC.OWNER_ID
  , P_OWNER_TERRITORY_ID      => L_TASKS_REC.OWNER_TERRITORY_ID
  , P_ASSIGNED_BY_ID          => L_TASKS_REC.ASSIGNED_BY_ID
  , P_CUSTOMER_ID             => L_TASKS_REC.CUSTOMER_ID
  , P_CUST_ACCOUNT_ID         => L_TASKS_REC.CUST_ACCOUNT_ID
  , P_ADDRESS_ID              => L_TASKS_REC.ADDRESS_ID
  , P_PLANNED_START_DATE      => L_TASKS_REC.PLANNED_START_DATE
  , P_PLANNED_END_DATE        => L_TASKS_REC.PLANNED_END_DATE
  , P_SCHEDULED_START_DATE    => L_TASKS_REC.SCHEDULED_START_DATE
  , P_SCHEDULED_END_DATE      => L_TASKS_REC.SCHEDULED_END_DATE
  , P_ACTUAL_START_DATE       => L_TASKS_REC.ACTUAL_START_DATE
  , P_ACTUAL_END_DATE         => L_TASKS_REC.ACTUAL_END_DATE
  , P_SOURCE_OBJECT_TYPE_CODE => L_TASKS_REC.SOURCE_OBJECT_TYPE_CODE
  , P_SOURCE_OBJECT_ID        => L_TASKS_REC.SOURCE_OBJECT_ID
  , P_SOURCE_OBJECT_NAME      => L_TASKS_REC.SOURCE_OBJECT_NAME
  , P_DURATION                => L_TASKS_REC.DURATION
  , P_DURATION_UOM            => L_TASKS_REC.DURATION_UOM
  , P_PLANNED_EFFORT          => L_TASKS_REC.PLANNED_EFFORT
  , P_PLANNED_EFFORT_UOM      => L_TASKS_REC.PLANNED_EFFORT_UOM
  , P_ACTUAL_EFFORT           => L_TASKS_REC.ACTUAL_EFFORT
  , P_ACTUAL_EFFORT_UOM       => L_TASKS_REC.ACTUAL_EFFORT_UOM
  , P_PERCENTAGE_COMPLETE     => L_TASKS_REC.PERCENTAGE_COMPLETE
  , P_REASON_CODE             => L_TASKS_REC.REASON_CODE
  , P_PRIVATE_FLAG            => L_TASKS_REC.PRIVATE_FLAG
  , P_PUBLISH_FLAG            => L_TASKS_REC.PUBLISH_FLAG
  , P_RESTRICT_CLOSURE_FLAG   => L_TASKS_REC.RESTRICT_CLOSURE_FLAG
  , P_MULTI_BOOKED_FLAG       => L_TASKS_REC.MULTI_BOOKED_FLAG
  , P_MILESTONE_FLAG          => L_TASKS_REC.MILESTONE_FLAG
  , P_HOLIDAY_FLAG            => L_TASKS_REC.HOLIDAY_FLAG
  , P_BILLABLE_FLAG           => L_TASKS_REC.BILLABLE_FLAG
  , P_BOUND_MODE_CODE         => L_TASKS_REC.BOUND_MODE_CODE
  , P_SOFT_BOUND_FLAG         => L_TASKS_REC.SOFT_BOUND_FLAG
  , P_WORKFLOW_PROCESS_ID     => L_TASKS_REC.WORKFLOW_PROCESS_ID
  , P_NOTIFICATION_FLAG       => L_TASKS_REC.NOTIFICATION_FLAG
  , P_NOTIFICATION_PERIOD     => L_TASKS_REC.NOTIFICATION_PERIOD
  , p_notification_period_uom => L_TASKS_REC.NOTIFICATION_PERIOD_UOM
  , P_PARENT_TASK_ID          => L_TASKS_REC.PARENT_TASK_ID
  , P_ALARM_START             => L_TASKS_REC.ALARM_START
  , P_ALARM_START_UOM         => L_TASKS_REC.ALARM_START_UOM
  , P_ALARM_ON                => L_TASKS_REC.ALARM_ON
  , P_ALARM_COUNT             => L_TASKS_REC.ALARM_COUNT
  , P_ALARM_INTERVAL          => L_TASKS_REC.ALARM_INTERVAL
  , p_alarm_interval_uom      => L_TASKS_REC.ALARM_INTERVAL_UOM
  , P_PALM_FLAG               => L_TASKS_REC.PALM_FLAG
  , P_WINCE_FLAG              => L_TASKS_REC.WINCE_FLAG
  , P_LAPTOP_FLAG             => L_TASKS_REC.LAPTOP_FLAG
  , P_DEVICE1_FLAG            => L_TASKS_REC.DEVICE1_FLAG
  , P_DEVICE2_FLAG            => L_TASKS_REC.DEVICE2_FLAG
  , P_DEVICE3_FLAG            => L_TASKS_REC.DEVICE3_FLAG
  , P_COSTS                   => L_TASKS_REC.COSTS
  , P_CURRENCY_CODE           => L_TASKS_REC.CURRENCY_CODE
  , P_ESCALATION_LEVEL        => L_TASKS_REC.ESCALATION_LEVEL
  , X_RETURN_STATUS           => L_RETURN_STATUS
  , X_MSG_COUNT               => L_MSG_COUNT
  , X_MSG_DATA                => L_MSG_DATA
  , P_ATTRIBUTE1                => L_TASKS_REC.ATTRIBUTE1
  , P_ATTRIBUTE2                => L_TASKS_REC.ATTRIBUTE2
  , P_ATTRIBUTE3                => L_TASKS_REC.ATTRIBUTE3
  , P_ATTRIBUTE4                => L_TASKS_REC.ATTRIBUTE4
  , P_ATTRIBUTE5                => L_TASKS_REC.ATTRIBUTE5
  , P_ATTRIBUTE6                => L_TASKS_REC.ATTRIBUTE6
  , P_ATTRIBUTE7                => L_TASKS_REC.ATTRIBUTE7
  , P_ATTRIBUTE8                => L_TASKS_REC.ATTRIBUTE8
  , P_ATTRIBUTE9                => L_TASKS_REC.ATTRIBUTE9
  , P_ATTRIBUTE10               => L_TASKS_REC.ATTRIBUTE10
  , P_ATTRIBUTE11               => L_TASKS_REC.ATTRIBUTE11
  , P_ATTRIBUTE12               => L_TASKS_REC.ATTRIBUTE12
  , P_ATTRIBUTE13               => L_TASKS_REC.ATTRIBUTE13
  , P_ATTRIBUTE14               => L_TASKS_REC.ATTRIBUTE14
  , P_ATTRIBUTE15               => L_TASKS_REC.ATTRIBUTE15
  , P_ATTRIBUTE_CATEGORY        => L_TASKS_REC.ATTRIBUTE_CATEGORY
  , p_date_selected           => L_TASKS_REC. DATE_SELECTED
  , p_enable_workflow         => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
  , P_ABORT_WORKFLOW          => FND_PROFILE.VALUE('JTF_TASK_ABORT_PREV_WF')
  , p_task_split_flag         => L_TASKS_REC. TASK_SPLIT_FLAG
  , P_CHILD_POSITION          => L_TASKS_REC.CHILD_POSITION
  , P_CHILD_SEQUENCE_NUM      => L_TASKS_REC.CHILD_SEQUENCE_NUM
  , P_LOCATION_ID             => L_TASKS_REC.LOCATION_ID
  );

/*  , p_task_assign_tbl         IN            task_assign_tbl DEFAULT g_miss_task_assign_tbl
  , p_task_depends_tbl        IN            task_depends_tbl DEFAULT g_miss_task_depends_tbl
  , p_task_rsrc_req_tbl       IN            task_rsrc_req_tbl DEFAULT g_miss_task_rsrc_req_tbl
  , p_task_refer_tbl          IN            task_refer_tbl DEFAULT g_miss_task_refer_tbl
  , p_task_dates_tbl          IN            task_dates_tbl DEFAULT g_miss_task_dates_tbl
  , p_task_notes_tbl          IN            task_notes_tbl DEFAULT g_miss_task_notes_tbl
  , p_task_recur_rec          IN            task_recur_rec DEFAULT g_miss_task_recur_rec
  , P_TASK_CONTACTS_TBL       IN            TASK_CONTACTS_TBL DEFAULT G_MISS_TASK_CONTACTS_TBL
*/
  IF l_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
       --After Successful Task insert process TAsk audit
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
  ELSE
    /*** exception occurred in API -> return errmsg ***/
    s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
    (
        p_api_error      => TRUE
    );
    x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    X_ERROR_MESSAGE := S_MSG_DATA;

  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_TASKS_PKG.APPLY_HA_UPDATE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_UPDATE', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_TASKS_PKG.APPLY_HA_UPDATE: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASKS_PKG.APPLY_HA_UPDATE',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := S_MSG_DATA;
END APPLY_HA_UPDATE;

--Apply Update
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
L_CON_NAME_LIST  CSM_VARCHAR_LIST;
l_CON_VALUE_LIST CSM_VARCHAR_LIST;
L_RETURN_STATUS       VARCHAR2(200);
L_ERROR_MESSAGE       VARCHAR2(2000);
L_AUD_RETURN_STATUS   VARCHAR2(200);
L_AUD_ERROR_MESSAGE   VARCHAR2(2000);
L_TASK_ID             NUMBER;
L_MSG_COUNT           NUMBER;
L_MSG_DATA            VARCHAR2(1000);
S_MSG_DATA            VARCHAR2(1000);
L_API_VERSION    CONSTANT NUMBER := 1.0;
L_TASK_NUMBER           VARCHAR2(80);
L_OBJECT_VERSION_NUMBER NUMBER;

--cursor for Audit Insert
Cursor C_Get_Aud_Objects(C_Payload_Id Number)
Is
SELECT HA_PAYLOAD_ID
From   Csm_Ha_Payload_Data
Where  Parent_Payload_Id = C_Payload_Id
AND    HA_PAYLOAD_ID <> PARENT_PAYLOAD_ID
AND    OBJECT_NAME IN('JTF_TASK_AUDITS_B','JTF_TASK_AUDITS_TL')
ORDER BY HA_PAYLOAD_ID ASC;

CURSOR C_GET_TASK_VERSION( C_TASK_ID NUMBER )
IS
SELECT OBJECT_VERSION_NUMBER FROM
JTF_TASKS_B
WHERE TASK_ID =C_TASK_ID;


BEGIN

  CSM_UTIL_PKG.LOG('Entering CSM_TASKS_PKG.APPLY_HA_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_DELETE',FND_LOG.LEVEL_PROCEDURE);

   -- Initialization
l_HA_PAYLOAD_ID := p_HA_PAYLOAD_ID;
L_COL_NAME_LIST   := P_COL_NAME_LIST;
l_COL_VALUE_LIST  := p_COL_VALUE_LIST;

---Create Task Assignment
  FOR I IN 1..L_COL_NAME_LIST.COUNT-1 LOOP
    EXIT  WHEN L_TASK_ID IS NOT NULL AND L_TASK_NUMBER IS NOT NULL;
    IF  l_COL_VALUE_LIST(i) IS NOT NULL THEN
      IF L_COL_NAME_LIST(I) = 'TASK_ID' THEN
        L_TASK_ID := l_COL_VALUE_LIST(i);
      ELSIF  l_COL_NAME_LIST(i) = 'TASK_NUMBER' THEN
        L_TASK_NUMBER := l_COL_VALUE_LIST(i);
      END IF;
     END IF;
  END LOOP;

  --Get the Latest Version number from the DB
  IF L_TASK_ID IS NOT NULL THEN
    OPEN  C_GET_TASK_VERSION( L_TASK_ID );
    FETCH C_GET_TASK_VERSION INTO L_OBJECT_VERSION_NUMBER;
    CLOSE C_GET_TASK_VERSION;

     JTF_TASKS_PUB.DELETE_TASK(
        P_API_VERSION             => L_API_VERSION
      , P_INIT_MSG_LIST           => FND_API.G_TRUE
      , P_COMMIT                  => FND_API.G_FALSE
      , P_OBJECT_VERSION_NUMBER   => L_OBJECT_VERSION_NUMBER
      , P_TASK_ID                 => L_TASK_ID
      , P_TASK_NUMBER             => L_TASK_NUMBER
      , P_DELETE_FUTURE_RECURRENCES => FND_API.G_FALSE
      , X_RETURN_STATUS           => L_RETURN_STATUS
      , X_MSG_COUNT               => L_MSG_COUNT
      , X_MSG_DATA                => L_MSG_DATA
      , p_enable_workflow         => fnd_profile.VALUE('JTF_TASK_ENABLE_WORKFLOW')
      , P_ABORT_WORKFLOW          => FND_PROFILE.VALUE('JTF_TASK_ABORT_PREV_WF')
      );
      IF l_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
           --After Successful Task insert process TAsk audit
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
      ELSE
        /*** exception occurred in API -> return errmsg ***/
        s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
        (
            p_api_error      => TRUE
        );
        x_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
        X_ERROR_MESSAGE := S_MSG_DATA;

      END IF;
  END IF;
  CSM_UTIL_PKG.LOG('Leaving CSM_TASKS_PKG.APPLY_HA_DELETE for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_DELETE',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_HA_DELETE', sqlerrm);
     s_msg_data := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in CSM_TASKS_PKG.APPLY_HA_DELETE: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASKS_PKG.APPLY_HA_DELETE',FND_LOG.LEVEL_EXCEPTION);
  x_return_status := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := S_MSG_DATA;
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

  CSM_UTIL_PKG.LOG('Entering CSM_TASKS_PKG.APPLY_HA_CHANGES for Payload ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

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
  CSM_UTIL_PKG.LOG('Leaving CSM_TASKS_PKG.APPLY_HA_CHANGES for HA ID ' || p_HA_PAYLOAD_ID ,
                         'CSM_TASKS_PKG.APPLY_HA_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  CSM_UTIL_PKG.log( 'Exception in CSM_TASKS_PKG.APPLY_HA_CHANGES: ' || sqlerrm
               || ' for HA ID ' || p_HA_PAYLOAD_ID ,'CSM_TASKS_PKG.APPLY_HA_INSERT',FND_LOG.LEVEL_EXCEPTION);
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
  X_ERROR_MESSAGE := TO_CHAR(SQLERRM,2000);

END APPLY_HA_CHANGES;

END CSM_TASKS_PKG; -- Package spec

/
