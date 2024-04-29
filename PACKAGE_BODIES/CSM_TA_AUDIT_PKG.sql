--------------------------------------------------------
--  DDL for Package Body CSM_TA_AUDIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSM_TA_AUDIT_PKG" AS
/* $Header: csmutaab.pls 120.2.12010000.2 2009/08/20 14:12:40 trajasek noship $ */

error EXCEPTION;


/*** Globals ***/
g_object_name  CONSTANT VARCHAR2(30) := 'CSM_TA_AUDIT_PKG';
g_pub_name     CONSTANT VARCHAR2(30) := 'CSM_TASK_ASSIGNMENTS_AUDIT';
g_debug_level           NUMBER; -- debug level

/* Select all inq records */
CURSOR c_ta_audit( b_user_name VARCHAR2, b_tranid NUMBER, b_assignment_id NUMBER) is
  SELECT *
  FROM  CSM_TASK_ASSIGNMENTS_AUDIT_INQ
  WHERE tranid$$ = b_tranid
  AND   clid$$cs = b_user_name
  AND   assignment_id = b_assignment_id;
/***
  This procedure is called by APPLY_CLIENT_CHANGES when an inserted record is to be processed.
***/
PROCEDURE APPLY_INSERT
         (
           p_record        IN c_ta_audit%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS

--Variable Declarations
l_object_version_number  NUMBER := 1;
l_msg_count          NUMBER;
l_msg_data           VARCHAR2(4000);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  CSM_UTIL_PKG.LOG('Entering CSM_TA_AUDIT_PKG.APPLY_INSERT for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,
                         'CSM_TA_AUDIT_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);

   CSM_UTIL_PKG.LOG('Before calling JTF_TASK_ASSIGNMENT_AUDIT_PKG.INSERT_ROW for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,
                         'CSM_TA_AUDIT_PKG.APPLY_INSERT',FND_LOG.LEVEL_EVENT);
    --We are calling this API as they do not support old values
    --in create_task_assignment_audit procedure
    JTF_TASK_ASSIGNMENT_AUDIT_PKG.INSERT_ROW(
        X_ASSIGNMENT_AUDIT_ID         => p_record.ASSIGNMENT_AUDIT_ID,
        X_ASSIGNMENT_ID               => p_record.ASSIGNMENT_ID,
        X_TASK_ID                     => p_record.TASK_ID,
        X_CREATION_DATE               => p_record.CREATION_DATE,
        X_CREATED_BY                  => p_record.CREATED_BY,
        X_LAST_UPDATE_DATE            => p_record.LAST_UPDATE_DATE,
        X_LAST_UPDATED_BY             => p_record.LAST_UPDATED_BY,
        X_LAST_UPDATE_LOGIN           => p_record.LAST_UPDATE_LOGIN,
        X_OLD_RESOURCE_TYPE_CODE      => p_record.OLD_RESOURCE_TYPE_CODE,
        X_NEW_RESOURCE_TYPE_CODE      => p_record.NEW_RESOURCE_TYPE_CODE,
        X_OLD_RESOURCE_ID             => p_record.OLD_RESOURCE_ID,
        X_NEW_RESOURCE_ID             => p_record.NEW_RESOURCE_ID,
        X_OLD_ASSIGNMENT_STATUS_ID    => p_record.OLD_ASSIGNMENT_STATUS_ID,
        X_NEW_ASSIGNMENT_STATUS_ID    => p_record.NEW_ASSIGNMENT_STATUS_ID,
        X_OLD_ACTUAL_EFFORT           => NULL,
        X_NEW_ACTUAL_EFFORT           => NULL,
        X_OLD_ACTUAL_EFFORT_UOM       => NULL,
        X_NEW_ACTUAL_EFFORT_UOM       => NULL,
        X_OLD_RES_TERRITORY_ID        => NULL,
        X_NEW_RES_TERRITORY_ID        => NULL,
        X_OLD_ASSIGNEE_ROLE           => NULL,
        X_NEW_ASSIGNEE_ROLE           => NULL,
        X_OLD_ALARM_TYPE              => NULL,
        X_NEW_ALARM_TYPE              => NULL,
        X_OLD_ALARM_CONTACT           => NULL,
        X_NEW_ALARM_CONTACT           => NULL,
        X_OLD_CATEGORY_ID             => NULL,
        X_NEW_CATEGORY_ID             => NULL,
        X_OLD_BOOKING_START_DATE      => NULL,
        X_NEW_BOOKING_START_DATE      => NULL,
        X_OLD_BOOKING_END_DATE        => NULL,
        X_NEW_BOOKING_END_DATE        => NULL,
        X_OLD_ACTUAL_TRAVEL_DISTANCE  => p_record.OLD_ACTUAL_TRAVEL_DISTANCE,
        X_NEW_ACTUAL_TRAVEL_DISTANCE  => p_record.NEW_ACTUAL_TRAVEL_DISTANCE,
        X_OLD_ACTUAL_TRAVEL_DURATION  => p_record.OLD_ACTUAL_TRAVEL_DURATION,
        X_NEW_ACTUAL_TRAVEL_DURATION  => p_record.NEW_ACTUAL_TRAVEL_DURATION,
        X_OLD_ACTUAL_TRAVEL_DUR_UOM   => p_record.OLD_ACTUAL_TRAVEL_DURATION_UOM,
        X_NEW_ACTUAL_TRAVEL_DUR_UOM   => p_record.NEW_ACTUAL_TRAVEL_DURATION_UOM,
        X_OLD_SCHED_TRAVEL_DISTANCE   => p_record.OLD_SCHED_TRAVEL_DISTANCE,
        X_NEW_SCHED_TRAVEL_DISTANCE   => p_record.NEW_SCHED_TRAVEL_DISTANCE,
        X_OLD_SCHED_TRAVEL_DURATION   => p_record.OLD_SCHED_TRAVEL_DURATION,
        X_NEW_SCHED_TRAVEL_DURATION   => p_record.NEW_SCHED_TRAVEL_DURATION,
        X_OLD_SCHED_TRAVEL_DUR_UOM    => p_record.OLD_SCHED_TRAVEL_DURATION_UOM,
        X_NEW_SCHED_TRAVEL_DUR_UOM    => p_record.NEW_SCHED_TRAVEL_DURATION_UOM,
        X_OLD_ACTUAL_START_DATE       => p_record.OLD_ACTUAL_START_DATE,
        X_NEW_ACTUAL_START_DATE       => p_record.NEW_ACTUAL_START_DATE,
        X_OLD_ACTUAL_END_DATE         => p_record.OLD_ACTUAL_END_DATE,
        X_NEW_ACTUAL_END_DATE         => p_record.NEW_ACTUAL_END_DATE,
        X_FREE_BUSY_TYPE_CHANGED      => NULL,
        X_UPDATE_STATUS_FLAG_CHANGED  => NULL,
        X_SHOW_ON_CALENDAR_CHANGED    => NULL,
        X_SCHEDULED_FLAG_CHANGED      => NULL
      );

  CSM_UTIL_PKG.LOG('Leaving CSM_TA_AUDIT_PKG.APPLY_INSERT for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,
                         'CSM_TA_AUDIT_PKG.APPLY_INSERT',FND_LOG.LEVEL_PROCEDURE);
  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION WHEN OTHERS THEN
  fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_INSERT', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_INSERT: ' || sqlerrm
               || ' for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.APPLY_INSERT',FND_LOG.LEVEL_EXCEPTION);

    x_return_status := FND_API.G_RET_STS_SUCCESS;
END APPLY_INSERT;


/***
  This procedure is called by APPLY_CLIENT_CHANGES for every record in in-queue that needs to be processed.
***/
PROCEDURE APPLY_RECORD
         (
           p_record        IN     c_ta_audit%ROWTYPE,
           p_error_msg     out nocopy    VARCHAR2,
           x_return_status IN out nocopy VARCHAR2
         ) IS
  l_rc                    BOOLEAN;
  l_access_id             NUMBER;
BEGIN
  /*** initialize return status and message list ***/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  FND_MSG_PUB.INITIALIZE;

  CSM_UTIL_PKG.LOG('Entering CSM_TA_AUDIT_PKG.APPLY_RECORD for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,
                         'CSM_TA_AUDIT_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);

  IF p_record.dmltype$$='I' THEN
    -- Process insert
    APPLY_INSERT
      (
        p_record,
        p_error_msg,
        x_return_status
      );
  ELSE --Delete and update is not supported for this PI
    -- invalid dml type
      CSM_UTIL_PKG.LOG
        ( 'Invalid DML type: ' || p_record.dmltype$$ || ' is not supported for this entity'
      || ' for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.APPLY_RECORD',FND_LOG.LEVEL_ERROR);

    p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
      (
        p_message        => 'CSM_DML_OPERATION'
      , p_token_name1    => 'DML'
      , p_token_value1   => p_record.dmltype$$
      );

    x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  CSM_UTIL_PKG.LOG('Leaving CSM_TA_AUDIT_PKG.APPLY_RECORD for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,
                         'CSM_TA_AUDIT_PKG.APPLY_RECORD',FND_LOG.LEVEL_PROCEDURE);
EXCEPTION WHEN OTHERS THEN
     fnd_msg_pub.Add_Exc_Msg( g_object_name, 'APPLY_RECORD', sqlerrm);
     p_error_msg := CSM_UTIL_PKG.GET_ERROR_MESSAGE_TEXT
     (
       p_api_error      => TRUE
     );
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_RECORD: ' || sqlerrm
               || ' for Task Assignment Audit ID ' || p_record.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.APPLY_RECORD',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_RECORD;

/***
  This procedure is called by CSM_SERVICEP_WRAPPER_PKG when publication item CSM_TASK_ASSIGNMENT_AUDIT
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE APPLY_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_assignment_id IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN out nocopy VARCHAR2
         ) IS

  l_process_status VARCHAR2(1);
  l_error_msg      VARCHAR2(4000);

BEGIN
CSM_UTIL_PKG.LOG('Entering CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES ',
                         'CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through all the  records in inqueue ***/
  FOR r_ta_audit_rec IN c_ta_audit( p_user_name, p_tranid, p_assignment_id) LOOP
    --SAVEPOINT save_rec ;
    /*** apply record ***/
    APPLY_RECORD
      (
        r_ta_audit_rec
      , l_error_msg
      , l_process_status
      );

    /*** was record processed successfully? ***/
    IF l_process_status = FND_API.G_RET_STS_SUCCESS THEN
      /*** Yes -> Reject record from inqueue ***/
      CSM_UTIL_PKG.DELETE_RECORD
        (
          p_user_name,
          p_tranid,
          r_ta_audit_rec.seqno$$,
          r_ta_audit_rec.ASSIGNMENT_AUDIT_ID,
          g_object_name,
          g_pub_name,
          l_error_msg,
          l_process_status
        );
      /*** was delete successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
       /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Deleting from inqueue failed, No rolling back to savepoint'
      || ' for Task Assignment Audit ID ' || r_ta_audit_rec.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        x_return_status := FND_API.G_RET_STS_SUCCESS;
      END IF;
    ELSIF l_process_Status <> FND_API.G_RET_STS_SUCCESS THEN
      /*** Record was not applied successfully -> defer and reject records ***/
      csm_util_pkg.log( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_ta_audit_rec.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.REJECT_RECORD
       (
         p_user_name
       , p_tranid
       , r_ta_audit_rec.seqno$$
       , r_ta_audit_rec.ASSIGNMENT_AUDIT_ID
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Reject record failed, No rolling back to savepoint'
          || ' for PK ' || r_ta_audit_rec.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        --ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;
    END IF;

  END LOOP;

  CSM_UTIL_PKG.LOG('Leaving CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES',
                         'CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);

EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.APPLY_CLIENT_CHANGES: ' || sqlerrm
               ,'CSM_TA_AUDIT_PKG.APPLY_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END APPLY_CLIENT_CHANGES;

/***
  This procedure is called by CSM_TASK_ASSIGNMENTS_PKG when publication item CSM_TASK_ASSIGNMENTS/CSM_TASK_ASSIGNMENT_AUDIT
  is dirty. This happens when a mobile field service device executed DML on an updatable table and did
  a fast sync. This procedure will insert the data that came from mobile into the backend tables using
  public APIs.
***/
PROCEDURE DEFER_CLIENT_CHANGES
         (
           p_user_name     IN VARCHAR2,
           p_tranid        IN NUMBER,
           p_assignment_id IN NUMBER,
           p_debug_level   IN NUMBER,
           x_return_status IN out nocopy VARCHAR2
         ) IS

l_process_status VARCHAR2(10);
l_error_msg      VARCHAR2(4000);

BEGIN
CSM_UTIL_PKG.LOG('Entering CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES ',
                         'CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  g_debug_level := p_debug_level;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*** loop through all the  records in inqueue to Defer ***/
  FOR r_ta_audit_rec IN c_ta_audit( p_user_name, p_tranid, p_assignment_id) LOOP

    /*** Parent Task Assignment Defered and hence Defer the TA Audit records ***/
      csm_util_pkg.log( 'Record not processed successfully, deferring and rejecting record'
      || ' for PK ' || r_ta_audit_rec.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here

      CSM_UTIL_PKG.DEFER_RECORD
       (
         p_user_name
       , p_tranid
       , r_ta_audit_rec.seqno$$
       , r_ta_audit_rec.ASSIGNMENT_AUDIT_ID
       , g_object_name
       , g_pub_name
       , l_error_msg
       , l_process_status
       , r_ta_audit_rec.dmltype$$
       );

      /*** Was defer successful? ***/
      IF l_process_status <> FND_API.G_RET_STS_SUCCESS THEN
        /*** no -> rollback ***/
          CSM_UTIL_PKG.LOG
          ( 'Defer record failed, No rolling back to savepoint'
          || ' for PK ' || r_ta_audit_rec.ASSIGNMENT_AUDIT_ID ,'CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES',FND_LOG.LEVEL_ERROR); -- put PK column here
        --ROLLBACK TO save_rec;
        x_return_status := FND_API.G_RET_STS_ERROR;
        EXIT;
       END IF;
  END LOOP;
  CSM_UTIL_PKG.LOG('Leaving CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES',
                         'CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES',FND_LOG.LEVEL_PROCEDURE);
  RETURN;
EXCEPTION WHEN OTHERS THEN
  /*** catch and log exceptions ***/
     CSM_UTIL_PKG.log( 'Exception in ' || g_object_name || '.DEFER_CLIENT_CHANGES: ' || sqlerrm
               ,'CSM_TA_AUDIT_PKG.DEFER_CLIENT_CHANGES',FND_LOG.LEVEL_EXCEPTION);

  x_return_status := FND_API.G_RET_STS_ERROR;

END DEFER_CLIENT_CHANGES;

END CSM_TA_AUDIT_PKG;

/
