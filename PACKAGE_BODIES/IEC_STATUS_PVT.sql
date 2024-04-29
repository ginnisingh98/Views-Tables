--------------------------------------------------------
--  DDL for Package Body IEC_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_STATUS_PVT" AS
/* $Header: IECOCSTB.pls 120.1 2006/03/28 07:57:56 minwang noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_STATUS_PVT';

g_error_msg VARCHAR2(2048) := NULL;

G_LIST_STATUS_EXECUTING CONSTANT NUMBER := 310;
G_LIST_STATUS_LOCKED CONSTANT NUMBER := 304;

G_NUM_MINUTES_IN_DAY CONSTANT NUMBER := 1440;
G_FUNCTIONAL CONSTANT NUMBER := 2;
G_PERFORMANCE CONSTANT NUMBER := 1;
G_DEFAULT_SUBSET_NAME CONSTANT VARCHAR2(30) := 'IEC_DEFAULT_SUBSET_NAME';
TYPE KEY_LIST IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

PROCEDURE Log
   ( p_method        IN VARCHAR2
   , p_sub_method    IN VARCHAR2
   , p_sqlerrm       IN VARCHAR2)
IS
BEGIN

   IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
      ( 'IEC_STATUS_PVT'
      , p_method
      , p_sub_method
      , p_sqlerrm
      , g_error_msg
      );

END Log;

PROCEDURE Log_IecStatusError
   ( p_method        IN VARCHAR2
   , p_sub_method    IN VARCHAR2
   , p_list_id       IN NUMBER
   , p_status_id     IN NUMBER
   )
IS
BEGIN

   IEC_OCS_LOG_PVT.LOG_LIST_STATUS_IEC_ERROR
      ( 'IEC_STATUS_PVT'
      , p_method
      , p_sub_method
      , p_list_id
      , p_status_id
      , g_error_msg
      );

END Log_IecStatusError;

PROCEDURE Log_AmsStatusError
   ( p_method        IN VARCHAR2
   , p_sub_method    IN VARCHAR2
   , p_list_id       IN NUMBER
   , p_status_id     IN NUMBER
   )
IS
BEGIN

   IEC_OCS_LOG_PVT.LOG_LIST_STATUS_AMS_ERROR
      ( 'IEC_STATUS_PVT'
      , p_method
      , p_sub_method
      , p_list_id
      , p_status_id
      , g_error_msg
      );

END Log_AmsStatusError;

PROCEDURE Log_CannotStopSchedule
   ( p_method        IN VARCHAR2
   , p_sub_method    IN VARCHAR2
   , p_schedule_name     IN VARCHAR2
   )
IS
   l_message VARCHAR2(4000);
   l_encoded_message VARCHAR2(4000);
   l_module VARCHAR2(4000);
BEGIN

   IEC_OCS_LOG_PVT.Init_CannotStopScheduleMsg
      ( p_schedule_name
      , l_message
      , l_encoded_message
      );

   IEC_OCS_LOG_PVT.Get_Module('IEC_STATUS_PVT', p_method, p_sub_method, l_module);
   IEC_OCS_LOG_PVT.Log_Message(l_module);

END Log_CannotStopSchedule;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Update_Schedule_Status
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Makes call to AMS_LISTHEADER_PUB.UpdateListheader to change the value of the
--                particular list's status value.
--
--  Parameters  : p_schedule_id      IN      NUMBER          Required
--                p_status           IN      NUMBER          Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Update_Schedule_Status
   ( p_schedule_id     IN            NUMBER
   , p_status          IN            NUMBER
   , p_user_id         IN            NUMBER
   )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_SCHEDULE_STATUS';
   l_schedule_rec           AMS_CAMP_SCHEDULE_PUB.schedule_rec_type;
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_return_code            VARCHAR2(1);

   l_object_version_number  NUMBER;
BEGIN

  ----------------------------------------------------------------
  -- We modify the header id and user status id fields to indicate
  -- that the status is what we want to modify on this list.
  ----------------------------------------------------------------
  l_schedule_rec.schedule_id := p_schedule_id;
  l_schedule_rec.user_status_id := p_status;
  l_schedule_rec.status_date := sysdate;
  l_schedule_rec.last_update_date := sysdate;
  l_schedule_rec.last_updated_by := p_user_id;

  -- Get object version number
  SELECT OBJECT_VERSION_NUMBER
  INTO l_schedule_rec.object_version_number
  FROM AMS_CAMPAIGN_SCHEDULES_B
  WHERE SCHEDULE_ID = p_schedule_id;

  ----------------------------------------------------------------
  -- Call the AMS api to execute the schedule modification for
  -- us.
  ----------------------------------------------------------------
  AMS_CAMP_SCHEDULE_PUB.Update_Camp_Schedule
            ( p_api_version_number               => l_api_version,
              p_init_msg_list                    => FND_API.G_TRUE,
              p_commit                           => FND_API.G_FALSE,
              p_validation_level                 => FND_API.G_VALID_LEVEL_FULL,
              x_return_status                    => l_return_code,
              x_msg_count                        => l_msg_count,
              x_msg_data                         => l_msg_data ,
              p_schedule_rec                     => l_schedule_rec,
              x_object_version_number            => l_object_version_number
            );
  ----------------------------------------------------------------
  -- If the call to the ams api did not complete successfully then write
  -- a log and stop the update list procedure.
  ----------------------------------------------------------------
  IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN

    Log_AmsStatusError('UPDATE_SCHEDULE_STATUS', 'UPDATE_SCHEDULE', p_schedule_id, p_status);

    IF l_return_code = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

  END IF;

  COMMIT;

EXCEPTION
  ----------------------------------------------------------------
  -- If either of the two FND_API exceptions have been thrown then
  -- the procedure has already logged the error and we now just
  -- set the return status flag and return to the calling
  -- procedure.
  ----------------------------------------------------------------
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);
  ----------------------------------------------------------------
  -- If an anonymous exception has been thrown then
  -- the we must log an internal PLSQL error and
  -- set the return status flag and return to the calling
  -- procedure.
  ----------------------------------------------------------------
  WHEN OTHERS THEN
    LOG ( l_api_name
        , 'MAIN'
        , SQLERRM );
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END Update_Schedule_Status;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Update_List_Status
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Updates the Advanced Outbound list status, and
--                makes call to AMS_LISTHEADER_PVT.UpdateListheader
--                to update the Marketing list status as well.
--                Accepts a parameter p_api_init_flag that is used
--                to flag whether or not a call to a public api
--                initiated the status change (i.e. start purge).
--                In most cases, this flag isn't relevant and the
--                overloaded procedure Update_List_Status that accepts
--                only p_list_id and p_status parameters should be used.
--
--  Parameters  : p_list_id       IN      NUMBER          Required
--                p_status        IN      VARCHAR2        Required
--                p_api_init_flag IN      VARCHAR2        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Update_List_Status
   ( p_list_id       IN NUMBER
   , p_status        IN VARCHAR2
   , p_api_init_flag IN VARCHAR2
   )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_LIST_STATUS';
   l_list_rec               AMS_LISTHEADER_PVT.list_header_rec_type;
   l_api_version   CONSTANT NUMBER       := 1.0;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_return_code            VARCHAR2(1);

   l_mkt_status             NUMBER;
   l_curr_mkt_status        NUMBER;

   l_api_init_flag          VARCHAR2(1);
BEGIN

   BEGIN

      ----------------------------------------------------------------
      -- In order to set a list associated with an AO schedule to
      -- ACTIVE, we must set the execution start time.
      ----------------------------------------------------------------
      IF (p_status = 'ACTIVE') THEN

         l_mkt_status := G_LIST_STATUS_EXECUTING;

         -- Set Execution Start Time
         BEGIN
            UPDATE IEC_G_LIST_RT_INFO
            SET    EXECUTION_START_TIME = SYSDATE
                 , LAST_UPDATED_BY = NVL(FND_GLOBAL.conc_login_id, -1)
                 , LAST_UPDATE_DATE = SYSDATE
            WHERE LIST_HEADER_ID = p_list_id
            AND EXECUTION_START_TIME IS NULL;
         EXCEPTION
            WHEN OTHERS THEN
               Log ( l_api_name
                   , 'PRE_PROCESSING.UPDATE_EXECUTION_START_TIME'
                   , SQLERRM );
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

      ELSIF (p_status = 'PENDING_VALIDATION') THEN

         l_mkt_status := G_LIST_STATUS_EXECUTING;

      ELSIF (p_status = 'FAILED_VALIDATION') THEN

         l_mkt_status := G_LIST_STATUS_LOCKED;

      ELSIF (p_status = 'VALIDATING') THEN

         l_mkt_status := G_LIST_STATUS_EXECUTING;

      ELSIF (p_status = 'VALIDATED') THEN

         l_mkt_status := G_LIST_STATUS_LOCKED;

      ELSIF (p_status = 'STOPPING') THEN

         l_mkt_status := G_LIST_STATUS_EXECUTING;

      ELSIF (p_status = 'INACTIVE') THEN

         l_mkt_status := G_LIST_STATUS_LOCKED;

      ELSIF (p_status = 'PENDING_PURGE') THEN

         l_mkt_status := G_LIST_STATUS_EXECUTING;

      ELSIF (p_status = 'FAILED_PURGE') THEN

         l_mkt_status := G_LIST_STATUS_LOCKED;

      ELSIF (p_status = 'PURGING') THEN

         l_mkt_status := G_LIST_STATUS_EXECUTING;

      ELSIF (p_status = 'PURGED') THEN

         l_mkt_status := G_LIST_STATUS_LOCKED;

      END IF;

   EXCEPTION
      ----------------------------------------------------------------
      -- This has already been logged so just re-raise the exception.
      ----------------------------------------------------------------
      WHEN FND_API.G_EXC_ERROR THEN
         RAISE;
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
         RAISE;
      ----------------------------------------------------------------
      -- If the preprocessing throws an unexpected exception then write
      -- a log and stop the update list procedure.
      ----------------------------------------------------------------
      WHEN OTHERS THEN
         Log_IecStatusError(l_api_name, 'PRE_PROCESSING', p_list_id, p_status);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- We only want to use the flag to indicate when an api
   -- initiated the call to change the status (or perform an
   -- action).  If not initiated by an api, then should be NULL,
   -- rather than 'N'
   IF p_api_init_flag = 'Y' THEN
      l_api_init_flag := 'Y';
   ELSE
      l_api_init_flag := NULL;
   END IF;

   -- Update AO List Status
   BEGIN
      UPDATE IEC_G_LIST_RT_INFO
      SET    STATUS_CODE = p_status
           , API_INITIATED_FLAG = l_api_init_flag
           , LAST_UPDATED_BY = NVL(FND_GLOBAL.conc_login_id, -1)
           , LAST_UPDATE_DATE = SYSDATE
      WHERE LIST_HEADER_ID = p_list_id;
   EXCEPTION
      WHEN OTHERS THEN
         Log ( l_api_name
             , 'UPDATE_AO_STATUS'
             , SQLERRM );
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- Get current Marketing list status
   BEGIN
      SELECT USER_STATUS_ID
      INTO l_curr_mkt_status
      FROM AMS_LIST_HEADERS_ALL
      WHERE LIST_HEADER_ID = p_list_id;
   EXCEPTION
      WHEN OTHERS THEN
         Log ( l_api_name
             , 'GET_AMS_STATUS'
             , SQLERRM );
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   -- Update Marketing list status has changed
   IF l_curr_mkt_status <> l_mkt_status THEN

      ----------------------------------------------------------------
      -- We need to grab an empty list header rec from marketing.
      ----------------------------------------------------------------
      AMS_LISTHEADER_PVT.Init_ListHeader_rec(x_listheader_rec  => l_list_rec);

      ----------------------------------------------------------------
      -- We modify the header id and user status id fields to indicate
      -- that the status is what we want to modify on this list.
      ----------------------------------------------------------------
      l_list_rec.list_header_id := p_list_id;
      l_list_rec.user_status_id := l_mkt_status;

      ----------------------------------------------------------------
      -- Call the AMS api to execute the list header modification for
      -- us.  FUTURE: we might have to use their public api in the
      -- future.
      ----------------------------------------------------------------
      AMS_LISTHEADER_PVT.Update_ListHeader
            ( p_api_version                      => l_api_version,
              p_init_msg_list                    => FND_API.G_TRUE,
              p_commit                           => FND_API.G_FALSE,
              p_validation_level                 => FND_API.G_VALID_LEVEL_FULL,
              x_return_status                    => l_return_code,
              x_msg_count                        => l_msg_count,
              x_msg_data                         => l_msg_data ,
              p_listheader_rec                   => l_list_rec
            );

      ----------------------------------------------------------------
      -- If the call to the ams api did not complete successfully then write
      -- a log and stop the update list procedure.
      ----------------------------------------------------------------
      IF l_return_code <> FND_API.G_RET_STS_SUCCESS THEN

         Log ( l_api_name
             , 'UPDATE_AMS_LIST_STATUS'
             , l_msg_data );

         IF l_return_code = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF l_return_code = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF;
   END IF;

   COMMIT;

EXCEPTION

  ----------------------------------------------------------------
  -- If either of the two FND_API exceptions have been thrown then
  -- the procedure has already logged the error and we now just
  -- set the return status flag and return to the calling
  -- procedure.
  ----------------------------------------------------------------
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);

  ----------------------------------------------------------------
  -- If an anonymous exception has been thrown then
  -- the we must log an internal PLSQL error and
  -- set the return status flag and return to the calling
  -- procedure.
  ----------------------------------------------------------------
  WHEN OTHERS THEN
    LOG ( l_api_name
        , 'MAIN'
        , SQLERRM );
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END Update_List_Status;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Update_List_Status
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Updates the Advanced Outbound list status, and
--                makes call to AMS_LISTHEADER_PVT.UpdateListheader
--                to update the Marketing list status as well.
--
--  Parameters  : p_list_id      IN      NUMBER          Required
--                p_status       IN      VARCHAR2        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Update_List_Status
   ( p_list_id     IN           NUMBER
   , p_status      IN           VARCHAR2
   )
IS
BEGIN
   Update_List_Status(p_list_id, p_status, 'N');
END Update_List_Status;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Stop_Lists
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Stops executing on lists that currently have a status
--                code of STOPPING.
--
--  Parameters  :
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Stop_Lists
IS
  l_method_name CONSTANT VARCHAR2(30) := 'STOP_LISTS';
  l_error_stack VARCHAR2(4000);
BEGIN

   SAVEPOINT STOP_LISTS_START;

   FOR list_rec IN (SELECT LIST_HEADER_ID
                    FROM   IEC_O_LISTS_TO_STOP_V)
   LOOP

      BEGIN
         Stop_ListExecution(list_rec.LIST_HEADER_ID);
      EXCEPTION
         WHEN OTHERS THEN
            IF l_error_stack IS NOT NULL THEN
               l_error_stack := l_error_stack || ':' || g_error_msg;
            ELSE
               l_error_stack := g_error_msg;
            END IF;
      END;

   END LOOP;

   IF l_error_stack IS NOT NULL THEN
      g_error_msg := l_error_stack;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
     RAISE;
  WHEN OTHERS THEN
    LOG ( l_method_name
        , 'MAIN'
        , SQLERRM );
    ROLLBACK TO STOP_LISTS_START;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Stop_Lists;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Clean_ListEntries
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Set the list status to 'DELETED' and make sure
--                that all unecessary database entries related to the list
--                are delted.
--
--  Parameters  : p_list_id IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Clean_ListEntries (p_list_id IN NUMBER)
IS
   l_method_name CONSTANT VARCHAR2(30) := 'Clean_ListEntries';
   l_stopped_server_id_col SYSTEM.number_tbl_type;
   l_records_out NUMBER;
   l_user_status_id NUMBER;
BEGIN

   -- REMOVE ENTRIES FROM THE CALL HISTORIES TABLE FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_O_RCY_CALL_HISTORIES WHERE RETURNS_ID IN ' ||
                        '(SELECT RETURNS_ID FROM IEC_G_RETURN_ENTRIES WHERE LIST_HEADER_ID = :1)'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_CALL_HISTORY.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE POSSIBLE ENTRIES FROM ONE OF THE SUBSET TRANSITION TABLES FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_O_TRANSITION_PHONES WHERE LIST_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_TRANSITION_PHONES.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE POSSIBLE ENTRIES FROM ONE OF THE SUBSET TRANSITION TABLES FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_O_TRANSITION_SUBSETS WHERE LIST_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_TRANSITION_SUBSETS.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE POSSIBLE ENTRIES FROM ONE OF THE SUBSET TRANSITION TABLES FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_O_TRANSITION_SUBSETS WHERE LIST_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_TRANSITION_SUBSETS.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE POSSIBLE ENTRIES FROM THE SUBSET COUNTS TABLE.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_G_REP_SUBSET_COUNTS WHERE LIST_HEADER_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_SUBSET_COUNTS.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE ENTRIES FROM THE CALL ZONE TABLE FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_G_MKTG_ITEM_CC_TZS WHERE LIST_HEADER_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_CALLABLE_ZONES.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE ENTRIES FROM THE VALIDATION HISTORY TABLE FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_O_VALIDATION_HISTORY WHERE LIST_HEADER_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_VALIDATION_HISTORY.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE ENTRIES FROM THE VALIDATION REPORT DETAILS TABLE FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_O_VALIDATION_REPORT_DETS WHERE LIST_HEADER_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_VALIDATION_REPORT_DETAILS.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE ENTRIES FROM THE VALIDATION STATUS TABLE FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_O_VALIDATION_STATUS WHERE LIST_HEADER_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_VALIDATION_STATUS.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- REMOVE ENTRIES FROM THE AO ENTRIES TABLE FOR THIS TARGET GROUP.
   BEGIN
      EXECUTE IMMEDIATE 'DELETE FROM IEC_G_RETURN_ENTRIES WHERE LIST_HEADER_ID = :1'
         USING p_list_id;
   EXCEPTION
   WHEN OTHERS THEN
      LOG ( l_method_name
          , 'DELETE_RETURN_ENTRIES.LIST_' || p_list_id
          , SQLERRM );
      RAISE;
   END;

   -- Update target group status to reflect
   -- that the entries have been removed.
   Update_List_Status(p_list_id, 'DELETED');

   -- Commit the changes to make it final.
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      LOG ( l_method_name
          , 'MAIN.LIST_' || p_list_id
          , SQLERRM );
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
END Clean_ListEntries;


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Start_ListExecution
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Set the list status to 'EXECUTING' and update
--                the execution start time.
--
--  Parameters  : p_list_id IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Start_ListExecution (p_list_id IN NUMBER)
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_method_name CONSTANT VARCHAR2(30) := 'Start_ListExecution';
BEGIN

   ----------------------------------------------------------------
   -- We call update list status to set the status of this list to
   -- ACTIVE.  The UPDATE_LIST_STATUS procedure will handle any
   -- addtional procedures that need to be executed for a list to
   -- become active.  This includes creating the runtime information.
   ----------------------------------------------------------------
   UPDATE_LIST_STATUS( p_list_id
                     , 'ACTIVE');
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      LOG ( l_method_name
          , 'MAIN.LIST_' || p_list_id
          , SQLERRM );
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
END Start_ListExecution;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Stop_ListExecution
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Set the list status to 'LOCKED' and make sure
--                that all entries are checked back into list.
--
--  Parameters  : p_list_id IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Stop_ListExecution (p_list_id IN NUMBER)
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_method_name CONSTANT VARCHAR2(30) := 'Stop_ListExecution';
   l_stopped_server_id_col SYSTEM.number_tbl_type;
   l_records_out NUMBER;
   l_user_status_id NUMBER;
BEGIN

   -- Get list of STOPPED servers that have records checked out
   SELECT DISTINCT B.SERVER_ID
   BULK COLLECT INTO l_stopped_server_id_col
   FROM IEC_G_RETURN_ENTRIES A, IEO_SVR_RT_INFO B
   WHERE A.CHECKOUT_ACTION_ID = B.SERVER_ID
   AND A.LIST_HEADER_ID = p_list_id
   AND A.RECORD_OUT_FLAG = 'Y'
   AND B.STATUS = 1;

   -- Recover any records that are checked out to STOPPED servers
   IF l_stopped_server_id_col IS NOT NULL AND l_stopped_server_id_col.COUNT > 0 THEN
      FORALL i IN l_stopped_server_id_col.FIRST..l_stopped_server_id_col.LAST
         UPDATE IEC_G_RETURN_ENTRIES
         SET RECORD_OUT_FLAG = 'N'
           , CHECKOUT_ACTION_ID = NULL
           , LAST_UPDATE_DATE = SYSDATE
         WHERE LIST_HEADER_ID = p_list_id
         AND CHECKOUT_ACTION_ID = l_stopped_server_id_col(i);
   END IF;

   -- Check if all records have been checked back in
   SELECT COUNT(*)
   INTO l_records_out
   FROM IEC_G_RETURN_ENTRIES
   WHERE LIST_HEADER_ID = p_list_id
   AND RECORD_OUT_FLAG = 'Y';

   IF l_records_out = 0 THEN

      -- Update status to Inactive since we can stop the list right now
      UPDATE_LIST_STATUS( p_list_id
                        , 'INACTIVE');

   ELSE
      -- Update status to Stopping since we can't stop the list right now
      -- since a running dial server still has entries checked out
      UPDATE_LIST_STATUS( p_list_id
                        , 'STOPPING');

   END IF;

   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      LOG ( l_method_name
          , 'MAIN.LIST_' || p_list_id
          , SQLERRM );
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
END Stop_ListExecution;

PROCEDURE Stop_ScheduleExecution_Pub
   ( p_schedule_id   IN            NUMBER
   , p_commit        IN            BOOLEAN
   , x_return_status    OUT NOCOPY VARCHAR2)
IS
   l_method_name CONSTANT VARCHAR2(30) := 'Stop_ListExecution_Pub';

   l_list_id NUMBER(15);
   l_schedule_name VARCHAR2(100);
   l_status_code VARCHAR2(30);

   l_stopped_server_id_col SYSTEM.number_tbl_type;
   l_records_out NUMBER;
   l_user_status_id NUMBER;

BEGIN

   SAVEPOINT stop_list;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IEC_COMMON_UTIL_PVT.Get_ListId(p_schedule_id, l_list_id);

   -- Check ao status to make sure that list is Active
   -- It only makes sense to stop an Active schedule, but
   -- the user may call this api with an Inactive schedule
   EXECUTE IMMEDIATE
      'SELECT A.STATUS_CODE
       FROM IEC_G_AO_LISTS_V A
       WHERE A.LIST_HEADER_ID = :list_id
       AND LANGUAGE = USERENV(''LANG'')'
   INTO l_status_code
   USING l_list_id;

   -- Only Active schedules may be stopped
   IF l_status_code <> 'ACTIVE' THEN
      RETURN;
   END IF;

   -- Update status to Stopping with api_initiated_flag = 'Y'
   Update_List_Status(l_list_id, 'STOPPING', 'Y');

   -- Get list of STOPPED servers that have records checked out
   SELECT DISTINCT B.SERVER_ID
   BULK COLLECT INTO l_stopped_server_id_col
   FROM IEC_G_RETURN_ENTRIES A, IEO_SVR_RT_INFO B
   WHERE A.CHECKOUT_ACTION_ID = B.SERVER_ID
   AND A.LIST_HEADER_ID = l_list_id
   AND A.RECORD_OUT_FLAG = 'Y'
   AND B.STATUS = 1;

   -- Recover any records that are checked out to STOPPED servers
   IF l_stopped_server_id_col IS NOT NULL AND l_stopped_server_id_col.COUNT > 0 THEN
      FORALL i IN l_stopped_server_id_col.FIRST..l_stopped_server_id_col.LAST
         UPDATE IEC_G_RETURN_ENTRIES
         SET RECORD_OUT_FLAG = 'N'
           , CHECKOUT_ACTION_ID = NULL
           , LAST_UPDATE_DATE = SYSDATE
         WHERE LIST_HEADER_ID = l_list_id
         AND CHECKOUT_ACTION_ID = l_stopped_server_id_col(i);
   END IF;

   -- Check if all records have been checked back in
   SELECT COUNT(*)
   INTO l_records_out
   FROM IEC_G_RETURN_ENTRIES
   WHERE LIST_HEADER_ID = l_list_id
   AND RECORD_OUT_FLAG = 'Y';

   IF l_records_out = 0 THEN
      -- Update status to Inactive since we can stop the list right now
      UPDATE_LIST_STATUS( l_list_id
                        , 'INACTIVE'
                        , NULL);

   ELSE
      -- List cannot be stopped b/c records are still checked out
      -- Rather than update the status to STOPPING so that the
      -- status plugin will continually check to see if the records
      -- are checked back in, we will simply log a message and
      -- set the status back to ACTIVE.
      -- The reasoning is that if they are calling an api to stop
      -- the list, they really can't wait for it to happen.
      UPDATE_LIST_STATUS( l_list_id
                        , 'ACTIVE'
                        , NULL);

      IEC_COMMON_UTIL_PVT.Get_ScheduleName(p_schedule_id, l_schedule_name);
      Log_CannotStopSchedule(l_method_name, 'CANNOT_STOP_LIST', l_schedule_name);
      RAISE fnd_api.g_exc_error;
   END IF;

   IF p_commit THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO stop_list;
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN OTHERS THEN
      ROLLBACK TO stop_list;
      LOG ( l_method_name
          , 'MAIN.SCHEDULE_' || p_schedule_id
          , SQLERRM );
      FND_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
END Stop_ScheduleExecution_Pub;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Pause_ListExecution
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Set the schedule status to 'ON_HOLD'.
--
--  Parameters  : p_schedule_id IN NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Pause_ScheduleExecution
   ( p_schedule_id IN NUMBER
   , p_user_id     IN NUMBER
   )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_method_name CONSTANT VARCHAR2(30) := 'Pause_ListExecution';
   l_user_status_id NUMBER;
BEGIN

   SELECT USER_STATUS_ID
   INTO l_user_status_id
   FROM AMS_USER_STATUSES_B
   WHERE SYSTEM_STATUS_TYPE = 'AMS_CAMPAIGN_SCHEDULE_STATUS'
   AND SYSTEM_STATUS_CODE = 'ON_HOLD'
   AND ROWNUM = 1;

   UPDATE_SCHEDULE_STATUS( p_schedule_id
                         , l_user_status_id
                         , p_user_id
                         );
   COMMIT;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      LOG ( l_method_name
          , 'MAIN.SCHEDULE_' || p_schedule_id
          , SQLERRM );
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
END Pause_ScheduleExecution;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : HANDLE_STATUS_TRANSITIONS
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Called by the Status plugin to execute status
--                transitions.
--  Parameters  : P_SERVER_ID     IN      NUMBER        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE HANDLE_STATUS_TRANSITIONS
   ( P_SERVER_ID          IN            NUMBER
   )
IS
  L_STATUS_CODE VARCHAR2(1);
  L_DEFAULT_SUBSET_NAME VARCHAR2(255);
  L_USER_ID NUMBER;
  L_LOGIN_ID NUMBER;
  l_log_status VARCHAR2(1);
  l_method_name CONSTANT VARCHAR2(30) := 'HANDLE_STATUS_TRANSITIONS';

BEGIN
  L_STATUS_CODE := 'S';
  L_DEFAULT_SUBSET_NAME := 'DEFAULT SUBSET';
  L_USER_ID := NVL(FND_GLOBAL.USER_ID, -1);
  L_LOGIN_ID := NVL(FND_GLOBAL.CONC_LOGIN_ID, -1);

  SAVEPOINT STATUS_START;

  ----------------------------------------------------------------
  -- Call procedure to stop lists that no longer meet the
  -- requirements for execution.
  ----------------------------------------------------------------
  STOP_LISTS;

  COMMIT;

EXCEPTION
  ----------------------------------------------------------------
  -- If either of the two FND_API exceptions have been thrown then
  -- the procedure has already logged the error and we now just
  -- set the return status flag and return to the calling
  -- procedure.
  ----------------------------------------------------------------
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO STATUS_START;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO STATUS_START;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);
  ----------------------------------------------------------------
  -- If an anonymous exception has been thrown then
  -- the we must log an internal PLSQL error and
  -- set the return status flag and return to the calling
  -- procedure.
  ----------------------------------------------------------------
  WHEN OTHERS THEN
    ROLLBACK TO STATUS_START;
    LOG ( l_method_name
        , 'MAIN'
        , SQLERRM );
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);
END HANDLE_STATUS_TRANSITIONS;

END IEC_STATUS_PVT;

/
