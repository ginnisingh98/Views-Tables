--------------------------------------------------------
--  DDL for Package Body IEC_EXECOCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_EXECOCS_PVT" AS
/* $Header: IECOCEXB.pls 115.25.1158.3 2002/10/02 18:25:56 lcrew ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_SVR_UTIL_PVT';

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : UPDATE_LIST_STATUS
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Makes call to AMS_LISTHEADER_PVT.UpdateListheader to change the value of the
--                particular list's status value.
--  Parameters  : P_LIST_HEADER_ID               IN     NUMBER                         Required
--                P_STATUS                       IN     VARCHAR2                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE UPDATE_LIST_STATUS
   ( P_LIST_HEADER_ID     IN       NUMBER
   , P_SOURCE_ID          IN       NUMBER
   , P_STATUS             IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
   l_api_name CONSTANT VARCHAR2(30) := 'UPDATE_LIST_STATUS';
   l_list_rec     AMS_LISTHEADER_PVT.list_header_rec_type;
   l_api_version   CONSTANT NUMBER        := 1.0;
   l_msg_count              NUMBER;
   l_msg_data               VARCHAR2(4000);
   l_source_id IEO_LNA_SOURCES.SOURCE_ID%TYPE;
   l_record_id IEO_LNA_RECORDS.RECORD_ID%TYPE;
   l_desc_arr IEC_SQL_LOGGER_PVT.VARCHAR2_TABLE;
   l_desc_app IEC_SQL_LOGGER_PVT.VARCHAR2_TABLE;
   l_desc_pos_arr IEC_SQL_LOGGER_PVT.NUMBER_TABLE;
   l_param_msg_name_arr IEC_SQL_LOGGER_PVT.VARCHAR2_TABLE;
   l_param_msg_app IEC_SQL_LOGGER_PVT.VARCHAR2_TABLE;
   l_parm_value_arr IEC_SQL_LOGGER_PVT.VARCHAR2_TABLE;
   l_parm_value_type_arr IEC_SQL_LOGGER_PVT.NUMBER_TABLE;

BEGIN
   X_RETURN_CODE := 'S';

   AMS_LISTHEADER_PVT.Init_ListHeader_rec(x_listheader_rec  => l_list_rec);

   l_list_rec.list_header_id := P_LIST_HEADER_ID ;
   l_list_rec.user_status_id  := P_STATUS ;

   AMS_LISTHEADER_PVT.Update_ListHeader
            ( p_api_version                      => l_api_version,
              p_init_msg_list                    => FND_API.G_FALSE,
              p_commit                           => FND_API.G_FALSE,
              p_validation_level                 => FND_API.G_VALID_LEVEL_FULL,
              x_return_status                    => X_RETURN_CODE,
              x_msg_count                        => l_msg_count,
              x_msg_data                         => l_msg_data ,
              p_listheader_rec                   => l_list_rec
                );

   -- If any errors happen abort API.
   IF X_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS THEN
    l_msg_count := FND_MSG_PUB.count_msg;
    IEC_SQL_LOGGER_PVT.log( P_SOURCE_ID
                          , IEC_SQL_LOGGER_PVT.G_TL_INFO
                          , SYSDATE
                          , 0
                          , IEC_SQL_LOGGER_PVT.G_ALERT_NONE
                          , IEC_SQL_LOGGER_PVT.G_TL_DEBUG
                          , 'IEC_COMM_TRACE'
                          , 'IEC'
                          , ''
                          , l_record_id);
    FOR i IN 1..FND_MSG_PUB.count_msg LOOP
      l_msg_data := FND_MSG_PUB.GET(i, FND_API.G_FALSE);
      l_desc_arr(1) := 'IEC_COMM_TRACE_DESC';
      l_desc_app(1) := 'IEC';
      IEC_SQL_LOGGER_PVT.LOG_DESCRIPTION( l_record_id, l_desc_arr, l_desc_app);
      l_desc_pos_arr(1) := 1;
      l_param_msg_name_arr(1) := 'IEC_TRACE_TOKEN';
      l_param_msg_app(1) := 'IEC';
      l_parm_value_arr(1) := l_msg_data;
      l_parm_value_type_arr(1) := 1;
      IEC_SQL_LOGGER_PVT.DESCRIPTION_PARAMS( l_record_id
                                           , l_desc_pos_arr
                                           , l_param_msg_name_arr
                                           , l_param_msg_app
                                           , l_parm_value_arr
                                           , l_parm_value_type_arr);
    END LOOP;
   END IF;

   IF X_RETURN_CODE = FND_API.G_RET_STS_ERROR THEN
 		RAISE FND_API.G_EXC_ERROR;
   ELSIF X_RETURN_CODE = FND_API.G_RET_STS_UNEXP_ERROR THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      X_RETURN_CODE := 'E';
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      X_RETURN_CODE := 'E';
   WHEN OTHERS THEN
      ROLLBACK;
      X_RETURN_CODE := 'U';
END UPDATE_LIST_STATUS;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : REFRESH_ENTRIES
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Refresh entries that have been checked out of AMS_LIST_ENTRIES for longer
--                than the time sent in as P_STALE_INTERVAL.
--  Parameters  : P_LOST_INTERVAL                IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Recover Plugin. */
PROCEDURE REFRESH_ENTRIES
   ( P_SOURCE_ID            IN     NUMBER
   , P_STALE_INTERVAL        IN     NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   ) AS LANGUAGE JAVA NAME 'oracle.apps.iec.storedproc.ocs.common.IecExecocsPvt.refreshStaleEntries(long, long, java.lang.String[])';


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : RECOVER_ENTRIES
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Recover entries that have been checked out of AMS_LIST_ENTRIES for longer
--                than the time sent in as P_LOST_INTERVAL.
--  Parameters  : P_LOST_INTERVAL                IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Recover Plugin. */
PROCEDURE RECOVER_ENTRIES
   ( P_SOURCE_ID            IN     NUMBER
   , P_LOST_INTERVAL        IN     NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   ) AS LANGUAGE JAVA NAME 'oracle.apps.iec.storedproc.ocs.common.IecExecocsPvt.recoverLostEntries(long, long, java.lang.String[])';

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : HANDLE_CALLBACKS
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID                      IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Callback Plugin. */
PROCEDURE HANDLE_CALLBACKS
   ( P_SOURCE_ID          IN       NUMBER
   , P_SCHED_ID           IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   ) AS LANGUAGE JAVA NAME 'oracle.apps.iec.storedproc.ocs.common.IecExecocsPvt.handleCallbacks(long, long, java.lang.String[])';

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : HANDLE_STATUS_TRANSITIONS
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID                      IN     NUMBER                       Required
--                P_SERVER_ID                      IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Status Plugin. */
PROCEDURE HANDLE_STATUS_TRANSITIONS
   ( P_SOURCE_ID          IN       NUMBER
   , P_SERVER_ID          IN       NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   ) AS LANGUAGE JAVA NAME 'oracle.apps.iec.storedproc.ocs.common.IecExecocsPvt.handleStatusTransitions(long, long, java.lang.String[])';

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : POPULATE_CACHE
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID                      IN     NUMBER                       Required
--                P_SCHEDULE_ID                    IN     NUMBER                       Required
--                P_LOW_THRESH_PCT                 IN     NUMBER                       Required
--                P_HIGH_THRESH_PCT                IN     NUMBER                       Required
--                P_LIST_INCREASE_PCT              IN     NUMBER                       Required
--                P_INIT_CACHE_PCT                 IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Retrieve Plugin. */
PROCEDURE POPULATE_CACHE
   ( P_SOURCE_ID          IN     NUMBER
   , P_SCHEDULE_ID        IN     NUMBER
   , P_LOW_THRESH_PCT     IN     NUMBER
   , P_HIGH_THRESH_PCT    IN     NUMBER
   , P_LIST_INCREASE_PCT  IN     NUMBER
   , P_INIT_CACHE_PCT     IN     NUMBER
   , X_RETURN_CODE          OUT    VARCHAR2
   ) AS LANGUAGE JAVA NAME 'oracle.apps.iec.storedproc.ocs.common.IecExecocsPvt.populateCache(long, long, int, int, int, int, java.lang.String[])';

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : RECYCLE_ENTRIES
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Called by the Recycle plugin to recycle entries in IEC_G_RETURNS.
--  Parameters  : X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Recycle Plugin. */
PROCEDURE RECYCLE_ENTRIES
   ( P_SOURCE_ID             IN     NUMBER
    , X_RETURN_CODE          OUT    VARCHAR2
   )
AS LANGUAGE JAVA NAME 'oracle.apps.iec.storedproc.algorithms.AlgWrapSPUJ.recycleEntries(int, java.lang.String [])';


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : CALL_IH
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Called by the Recycle process to record the IH related information for Advanced Outbound Predicitive dialing.
--  Parameters  : X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
/* Called by the Recycle Process to record the IH related information. */
PROCEDURE CALL_IH
   ( P_PARTY_ID 	IN	NUMBER
   , P_START_TIME	IN	DATE
   , P_END_TIME		IN	DATE
   , P_OUTCOME_ID	IN	NUMBER
   , P_REASON_ID	IN	NUMBER
   , P_RESULT_ID	IN	NUMBER
   , P_ACTION_ITEM_ID   IN	NUMBER
   ,X_RETURN_STATUS	OUT	VARCHAR2
   )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_api_version      	CONSTANT NUMBER       := 1.0;
  l_init_msg_list		VARCHAR2(1) :=FND_API.G_TRUE;
  l_commit			VARCHAR2(1) :=FND_API.G_TRUE;
  l_user_id			NUMBER := 0;
  l_media_id			NUMBER;
  l_return_status		VARCHAR2(1);
  l_msg_count			NUMBER;
  l_msg_data			VARCHAR2(2000);
  l_null			CHAR(1);
BEGIN
--	DBMS_OUTPUT.PUT_LINE('----begin create interaction-----0');
        IF(L_INITIAL = 0 ) THEN
	  l_interaction_rec.interaction_id := NULL;
	  l_interaction_rec.reference_form := NULL;
	  l_interaction_rec.follow_up_action := NULL;
	  l_interaction_rec.inter_interaction_duration := NULL;
	  l_interaction_rec.non_productive_time_amount := NULL;
	  l_interaction_rec.preview_time_amount := NULL;
	  l_interaction_rec.productive_time_amount := NULL;
	  l_interaction_rec.wrapUp_time_amount := NULL;
	  l_interaction_rec.handler_id := 545;
	  l_interaction_rec.script_id := NULL;

	  --- temp set resource_id
	  l_interaction_rec.resource_id := 1;

	  l_interaction_rec.parent_id := NULL;
	  l_interaction_rec.object_id := NULL;
	  l_interaction_rec.object_type := NULL;
	  l_interaction_rec.source_code_id := NULL;
	  l_interaction_rec.source_code := NULL;
	  l_interaction_rec.attribute1 := NULL;
	  l_interaction_rec.attribute2 := NULL;
	  l_interaction_rec.attribute3 := NULL;
	  l_interaction_rec.attribute4 := NULL;
	  l_interaction_rec.attribute5 := NULL;
	  l_interaction_rec.attribute6 := NULL;
	  l_interaction_rec.attribute7 := NULL;
	  l_interaction_rec.attribute8 := NULL;
	  l_interaction_rec.attribute9 := NULL;
	  l_interaction_rec.attribute10 := NULL;
	  l_interaction_rec.attribute11 := NULL;
	  l_interaction_rec.attribute12 := NULL;
	  l_interaction_rec.attribute13 := NULL;
	  l_interaction_rec.attribute14 := NULL;
	  l_interaction_rec.attribute15 := NULL;
	  l_interaction_rec.attribute_category := NULL;

          l_activities_tbl(1).activity_id := NULL;
	  l_activities_tbl(1).cust_account_id := NULL;
	  l_activities_tbl(1).cust_org_id := NULL;
	  l_activities_tbl(1).role := NULL;
	  l_activities_tbl(1).task_id := NULL;
	  l_activities_tbl(1).doc_id := NULL;
	  l_activities_tbl(1).doc_ref := NULL;
          l_activities_tbl(1).doc_source_object_name := NULL;
	  l_activities_tbl(1).media_id := NULL;
          l_activities_tbl(1).interaction_id := NULL;
	  l_activities_tbl(1).description := NULL;
	  l_activities_tbl(1).action_id := NULL;
	  l_activities_tbl(1).interaction_action_type := NULL;
	  l_activities_tbl(1).object_id := NULL;
	  l_activities_tbl(1).object_type := NULL;
	  l_activities_tbl(1).source_code_id := NULL;
	  l_activities_tbl(1).source_code := NULL;
          l_activities_tbl(1).script_trans_id := NULL;

	  l_media_rec.media_id := NULL;
	  l_media_rec.source_id := NULL;
	  l_media_rec.direction := 'OUTBOUND';
	  l_media_rec.interaction_performed := NULL;
	  l_media_rec.media_data := NULL;
	  l_media_rec.source_item_create_date_time := NULL;
	  l_media_rec.source_item_id := NULL;
	  l_media_rec.media_item_type := 'TELEPHONE';
	  l_media_rec.media_item_ref := NULL;
          l_media_rec.media_abandon_flag := NULL;
          l_media_rec.media_transferred_flag := NULL;

	  l_media_lc_rec.type_type := NULL;
	  l_media_lc_rec.type_id := NULL;
	  l_media_lc_rec.milcs_id := NULL;

	  --- temp set milcs_type_id
	  l_media_lc_rec.milcs_type_id := 10015;

	  l_media_lc_rec.handler_id := 545;

	  --- temp set resource_id
	  l_media_lc_rec.resource_id := 1;

          l_media_lc_rec.milcs_code := NULL;

	  L_INITIAL := 1;
	END IF;

        l_interaction_rec.duration := ROUND((p_end_time - p_start_time) *24*60);
	l_interaction_rec.end_date_time := p_end_time;
	l_interaction_rec.start_date_time := p_start_time;
	l_interaction_rec.outcome_id := p_outcome_id;
	l_interaction_rec.result_id := p_result_id;
	l_interaction_rec.reason_id := p_reason_id;

	l_interaction_rec.party_id := p_party_id;
	l_activities_tbl(1).duration := ROUND((p_end_time - p_start_time) *24*60);
	l_activities_tbl(1).end_date_time := p_end_time;
	l_activities_tbl(1).start_date_time := p_start_time;
	l_activities_tbl(1).action_item_id := p_action_item_id;
	l_activities_tbl(1).outcome_id := p_outcome_id;
	l_activities_tbl(1).result_id := p_result_id;
	l_activities_tbl(1).reason_id := p_reason_id;
 --       DBMS_OUTPUT.PUT_LINE('----before call JTF_IH_PUB create interaction-----');

        JTF_IH_PUB.Create_Interaction(
          p_api_version=>l_api_version,
          p_init_msg_list=>l_init_msg_list,
          p_commit=>l_commit,
	  p_user_id=>l_user_id,
          x_return_status=>l_return_status,
          x_msg_count=>l_msg_count,
          x_msg_data=>l_msg_data,
	  p_interaction_rec=>l_interaction_rec,
          p_activities=>l_activities_tbl);
        x_return_status := l_return_status;

 --       DBMS_OUTPUT.PUT_LINE('----end create interaction----- with x_return_status '||l_return_status);
  -- DBMS_OUTPUT.PUT_LINE('----end create interaction----- with x_msg_data '||l_msg_data);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
 		RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
                x_return_status := l_return_status;
        END IF;
--	DBMS_OUTPUT.PUT_LINE('----begin create MediaItem-----');

        l_media_rec.duration := ROUND((p_end_time - p_start_time) *24*60);
	l_media_rec.end_date_time := p_end_time;
	l_media_rec.start_date_time := p_start_time;

        JTF_IH_PUB.Create_MediaItem(
          p_api_version=>l_api_version,
          p_init_msg_list=>l_init_msg_list,
          p_commit=>l_commit,
	  p_user_id=>l_user_id,
          x_return_status=>l_return_status,
          x_msg_count=>l_msg_count,
          x_msg_data=>l_msg_data,
	  p_media_rec=>l_media_rec,
          x_media_id=>l_media_id);
        x_return_status := l_return_status;
--	DBMS_OUTPUT.PUT_LINE('----end create MediaItem----- with x_return_status '||l_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
 		RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
                x_return_status := l_return_status;
        END IF;
 --       DBMS_OUTPUT.PUT_LINE('----begin Create_MediaLifecycle-----');
	l_media_lc_rec.start_date_time := p_start_time;
	l_media_lc_rec.duration := ROUND((p_end_time - p_start_time)*24*60);
	l_media_lc_rec.end_date_time := p_end_time;
	l_media_lc_rec.media_id := l_media_id;

        JTF_IH_PUB.Create_MediaLifecycle(
          p_api_version=>l_api_version,
          p_init_msg_list=>l_init_msg_list,
          p_commit=>l_commit,
	  p_user_id=>l_user_id,
          x_return_status=>l_return_status,
          x_msg_count=>l_msg_count,
          x_msg_data=>l_msg_data,
	  p_media_lc_rec=>l_media_lc_rec);
        x_return_status := l_return_status;
--	DBMS_OUTPUT.PUT_LINE('----end Create_MediaLifecycle----- with x_return_status '||l_return_status);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
 		RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
 		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSE
                x_return_status := l_return_status;
        END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK;
      X_RETURN_STATUS := 'E';
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      X_RETURN_STATUS := 'U';
   WHEN OTHERS THEN
      ROLLBACK;
      X_RETURN_STATUS := 'E';
END CALL_IH;

/* Called by Recover plugin to remove uneccesary entries from cache. */
PROCEDURE REMOVE_OLD_ENTRIES
   ( SCHED_ID IN NUMBER
   , LIST_ID  IN NUMBER
   , SUBSET_ID IN NUMBER
   , X_RETURN_STATUS    OUT     VARCHAR2
   )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  TYPE EntryList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  deleteList EntryList;
  maxRecordId NUMBER;
  recordCount NUMBER := 0;
  recordOutFlag VARCHAR2(1);
  startTime1 CHAR(5);
  endTime1 CHAR(5);
  startTime2 CHAR(5);
  endTime2 CHAR(5);
  startTime3 CHAR(5);
  endTime3 CHAR(5);
  startTime4 CHAR(5);
  endTime4 CHAR(5);

  CURSOR entry_cursor(listId NUMBER, subsetId NUMBER, callbackFlag VARCHAR2) IS
    SELECT A.LIST_ENTRY_ID, A.CACHE_RECORD_ID
    FROM IEC_G_CACHE_RECORDS A
    WHERE A.LIST_HEADER_ID = listId
    AND A.SUBSET_ID = subsetId
    AND A.CALLBACK_FLAG = callbackFlag
    AND A.CACHE_RECORD_ID < (SELECT B.RECORD_CACHE_SEQ
    FROM IEC_G_CACHE_MKTG_ITEMS B
    WHERE B.LIST_HEADER_ID = A.LIST_HEADER_ID
    AND B.SUBSET_ID = A.SUBSET_ID
    AND B.CALLBACK_FLAG = A.CALLBACK_FLAG);
BEGIN
  X_RETURN_STATUS := 'S';

  SELECT TO_CHAR(SYSDATE, 'SSSSS') INTO startTime1 FROM DUAL;
  startTime4 := startTime1;

  -- Remove unnecessary non-callback cache entries.
  FOR entry_rec IN entry_cursor(LIST_ID, SUBSET_ID, 'Y')
  LOOP

    -- If there exist a cache record with an entryid and listid
    -- that has the check out flag set to N in the list entries table
    -- then we can assume that this entry is no longer of any use.
    BEGIN
      SELECT /*+ INDEX (AMS_LIST_ENTRIES AMS_LIST_ENTRIES_U1) */ RECORD_OUT_FLAG
      INTO recordOutFlag
      FROM AMS_LIST_ENTRIES
      WHERE LIST_ENTRY_ID = entry_rec.LIST_ENTRY_ID
      AND LIST_HEADER_ID = LIST_ID;
    EXCEPTION
      -- Fixme add logic to handle if entry does not exist.
      -- This should no happen.
      WHEN OTHERS THEN
        RAISE;
    END;

    IF (recordOutFlag = 'N')
    THEN
      recordCount := recordCount + 1;
      deleteList(recordCount) := entry_rec.CACHE_RECORD_ID;
    ELSE

      -- If there exist a cache record with the same entryid and listid
      -- that has a higher cache sequence then we can assume that this
      -- entry is no longer of any use.
      BEGIN
        SELECT MAX(CACHE_RECORD_ID)
        INTO maxRecordId
        FROM IEC_G_CACHE_RECORDS
        WHERE LIST_HEADER_ID = LIST_ID
        AND   LIST_ENTRY_ID = entry_rec.LIST_ENTRY_ID;
      EXCEPTION
        -- Fixme add logic to handle if entry does not exist.
        -- This should no happen.
        WHEN OTHERS THEN
          RAISE;
      END;

      IF (maxRecordId > entry_rec.CACHE_RECORD_ID)
      THEN
        recordCount := recordCount + 1;
        deleteList(recordCount) := entry_rec.CACHE_RECORD_ID;
      END IF;

    END IF;
  END LOOP;
  SELECT TO_CHAR(SYSDATE, 'SSSSS') INTO endTime1 FROM DUAL;

  startTime2 := endTime1;

  -- Remove unnecessary callback cache entries.
  FOR entry_rec IN entry_cursor(LIST_ID, SUBSET_ID, 'N') LOOP
    -- If there exist a cache record with an entryid and listid
    -- that has the check out flag set to N in the list entries table
    -- then we can assume that this entry is no longer of any use.
    BEGIN
      SELECT /*+ INDEX (AMS_LIST_ENTRIES AMS_LIST_ENTRIES_U1) */ RECORD_OUT_FLAG
      INTO recordOutFlag
      FROM AMS_LIST_ENTRIES
      WHERE LIST_ENTRY_ID = entry_rec.LIST_ENTRY_ID
      AND LIST_HEADER_ID = LIST_ID;
    EXCEPTION
      -- Fixme add logic to handle if entry does not exist.
      -- This should no happen.
      WHEN OTHERS THEN
        RAISE;
    END;

    IF (recordOutFlag = 'N')
    THEN
      recordCount := recordCount + 1;
      deleteList(recordCount) := entry_rec.CACHE_RECORD_ID;
    ELSE

      -- If there exist a cache record with the same entryid and listid
      -- that has a higher cache sequence then we can assume that this
      -- entry is no longer of any use.
      BEGIN
        SELECT MAX(CACHE_RECORD_ID)
        INTO maxRecordId
        FROM IEC_G_CACHE_RECORDS
        WHERE LIST_HEADER_ID = LIST_ID
        AND   LIST_ENTRY_ID = entry_rec.LIST_ENTRY_ID;
      EXCEPTION
        -- Fixme add logic to handle if entry does not exist.
        -- This should no happen.
        WHEN OTHERS THEN
          RAISE;
      END;

      IF (maxRecordId > entry_rec.CACHE_RECORD_ID)
      THEN
        recordCount := recordCount + 1;
        deleteList(recordCount) := entry_rec.CACHE_RECORD_ID;
      END IF;

    END IF;
  END LOOP;

  SELECT TO_CHAR(SYSDATE, 'SSSSS') INTO endTime2 FROM DUAL;
  startTime3 := endTime2;

  FORALL j IN 1..recordCount
    DELETE FROM IEC_G_CACHE_RECORDS WHERE CACHE_RECORD_ID = deleteList(j);

  SELECT TO_CHAR(SYSDATE, 'SSSSS') INTO endTime3 FROM DUAL;

  COMMIT;
  SELECT TO_CHAR(SYSDATE, 'SSSSS') INTO endTime4 FROM DUAL;

  -- DBMS_OUTPUT.PUT_LINE('Execution Time (secs)');
  -- DBMS_OUTPUT.PUT_LINE('Number deleted: ' || TO_CHAR(recordCount));
  -- DBMS_OUTPUT.PUT_LINE('Identifying non-callbacks: ' || TO_CHAR(endTime1 - startTime1));
  -- DBMS_OUTPUT.PUT_LINE('Identifying callbacks: ' || TO_CHAR(endTime2 - startTime2));
  -- DBMS_OUTPUT.PUT_LINE('Deleting: ' || TO_CHAR(endTime3 - startTime3));
  -- DBMS_OUTPUT.PUT_LINE('Total Execution: ' || TO_CHAR(endTime4 - startTime4));

  EXCEPTION
    -- Fixme add logic to handle if entry does not exist.
    -- This should no happen.
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;

END REMOVE_OLD_ENTRIES;

/* Called by Recover plugin to remove uneccesary entries from cache. */
PROCEDURE INSERT_LIST_RETURNS_RECORDS
   ( P_SCHED_ID IN NUMBER
   , P_LIST_ID  IN NUMBER
   , P_VIEW_NAME IN VARCHAR2
   , P_DIALING_METHOD IN VARCHAR2
   , X_RETURN_STATUS    OUT     VARCHAR2
   )
IS
  L_RETURN_STATUS VARCHAR2(1) := 'S';
  L_VIEW_NAME VARCHAR2(250);
  L_ENTRY_COUNT NUMBER := 1000;
  L_LAST_ENTRY_ID NUMBER := -1;
  startTime1 CHAR(5);
  endTime1 CHAR(5);

  TYPE ListEntryTab IS TABLE OF NUMBER;
  L_LIST_ENTRIES_TAB ListEntryTab;

  CURSOR entry_cursor(listId NUMBER, lastEntrySeq NUMBER) IS
    SELECT LIST_ENTRY_ID
    FROM AMS_LIST_ENTRIES
    WHERE LIST_HEADER_ID = listId
    AND LIST_ENTRY_ID > lastEntrySeq
    AND ROWNUM <= 1000
    ORDER BY LIST_ENTRY_ID;
BEGIN
  -- Create a savepoint so that we can rollback to this point.

  X_RETURN_STATUS := 'S';

  SAVEPOINT remove_old_entries;

  SELECT TO_CHAR(SYSDATE, 'SSSSS') INTO startTime1 FROM DUAL;

  WHILE (L_ENTRY_COUNT = 1000)
  LOOP

    OPEN entry_cursor( P_LIST_ID
                     , L_LAST_ENTRY_ID);

    FETCH entry_cursor BULK COLLECT INTO L_LIST_ENTRIES_TAB;

    FORALL j IN L_LIST_ENTRIES_TAB.FIRST..L_LIST_ENTRIES_TAB.LAST
      INSERT INTO IEC_G_RETURN_ENTRIES
      ( RETURNS_ID
      , LIST_ENTRY_ID
      , LIST_HEADER_ID
      , SUBSET_ID
      , OUTCOME_ID
      , RESULT_ID
      , REASON_ID
      , CONTACT_POINT
      , CONTACT_POINT_ID
      , DELIVER_IH_FLAG
      , CALL_TYPE
      , CAMPAIGN_SCHEDULE_ID
      , LIST_VIEW_NAME
      , RECYCLE_FLAG
      , CREATED_BY
      , CREATION_DATE
      , LAST_UPDATED_BY
      , LAST_UPDATE_DATE
      , LAST_UPDATE_LOGIN
      )
      VALUES
      (
        IEC_G_RETURN_ENTRIES_S.NEXTVAL
      , L_LIST_ENTRIES_TAB(j)
      , P_LIST_ID
      , -1
      , -1
      , -1
      , -1
      , FND_API.G_MISS_CHAR
      , 0
      , 'N'
      , P_DIALING_METHOD
      , P_SCHED_ID
      , P_VIEW_NAME
      , 'N'
      , nvl( FND_GLOBAL.user_id, -1 )
      , SYSDATE
      , nvl( FND_GLOBAL.conc_login_id, -1 )
      , SYSDATE
      , nvl( FND_GLOBAL.conc_login_id, -1 )
      );

    L_LAST_ENTRY_ID := L_LIST_ENTRIES_TAB(L_LIST_ENTRIES_TAB.LAST);

    L_ENTRY_COUNT := L_LIST_ENTRIES_TAB.COUNT;

    CLOSE entry_cursor;

    COMMIT;

    L_LIST_ENTRIES_TAB.DELETE;
  END LOOP;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO remove_old_entries;
      DELETE FROM IEC_G_RETURN_ENTRIES
      WHERE LIST_HEADER_ID = P_LIST_ID;
      COMMIT;
      X_RETURN_STATUS := 'E';

END INSERT_LIST_RETURNS_RECORDS;


-- PL/SQL Block
END IEC_EXECOCS_PVT;

/
