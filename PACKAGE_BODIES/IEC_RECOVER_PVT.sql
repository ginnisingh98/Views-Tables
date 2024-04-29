--------------------------------------------------------
--  DDL for Package Body IEC_RECOVER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RECOVER_PVT" AS
/* $Header: IECOCRCB.pls 115.30 2004/05/19 17:14:04 minwang ship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_RECOVER_PVT';
g_error_msg VARCHAR2(2048);

G_RECOVER_ACTION_TYPE CONSTANT NUMBER := 2;
G_NUM_MINUTES_IN_DAY CONSTANT NUMBER := 1440;
G_SYSTEM_OUTCOME_CODE CONSTANT NUMBER := 37;
G_LOST_RESULT_CODE CONSTANT NUMBER := 11;
G_FUNCTIONAL CONSTANT NUMBER := 2;
G_PERFORMANCE CONSTANT NUMBER := 1;
G_SOURCE_ID NUMBER;


PROCEDURE Log ( p_activity_desc IN VARCHAR2
              , p_method_name   IN VARCHAR2
              , p_sub_method    IN VARCHAR2
              , p_sql_code      IN NUMBER
              , p_sql_errm      IN VARCHAR2)
IS
   l_error_msg VARCHAR2(2048);
BEGIN

   IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
                      ( 'IEC_RECOVER_PVT'
                      , p_method_name
                      , p_sub_method
                      , p_activity_desc
                      , p_sql_code
                      , p_sql_errm
                      , l_error_msg
                      );

END Log;


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : RECOVER_LIST_ENTRIES
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
PROCEDURE RECOVER_LIST_ENTRIES
   ( P_SOURCE_ID            IN             NUMBER
   , P_LIST_ID              IN             NUMBER
   , P_LOST_INTERVAL        IN             NUMBER
   , X_ACTION_ID            IN   OUT NOCOPY  NUMBER
   )
 IS

  l_api_name CONSTANT VARCHAR2(30) := 'RECOVER_LIST_ENTRIES';
  TYPE EntryCollection IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
  TYPE FlagCollection IS TABLE OF VARCHAR2(1) INDEX BY BINARY_INTEGER;
  l_update_count NUMBER := 0;
  l_update_list EntryCollection;
  l_entry_list EntryCollection;
  l_cache_list EntryCollection;
  l_subset_collection EntryCollection;
  l_update_subset_collection EntryCollection;
  l_callback_collection FlagCollection;
  l_recycle_list NUMBER := 0;
  l_ok_list NUMBER := 0;
  l_lost_interval NUMBER;
  l_list_entry_found NUMBER;
  l_returns_id NUMBER;
  l_user_id NUMBER;
  l_err_msg VARCHAR2(100);
  l_update_date DATE;
  l_check_date DATE;
  l_recycle_flag VARCHAR2(10);
  l_batch_entries CONSTANT NUMBER := 10000;
  l_entry_count NUMBER;
  l_watermark NUMBER := 0;
  l_outer_itertion NUMBER := 0;
  l_inner_itertion NUMBER := 0;
  l_start_time NUMBER ;
  l_end_time NUMBER ;
  l_log_status VARCHAR2(1);
  l_total_count NUMBER;
  l_sequence NUMBER;
  l_subset_id NUMBER;
  l_cache_id NUMBER;
  l_callback_flag VARCHAR2(1);
  l_no_sequence_except EXCEPTION;
  l_status_code VARCHAR2(1);
  l_action_id NUMBER;
 BEGIN

  l_user_id := NVL(FND_GLOBAL.USER_ID, -1);
  l_entry_count := l_batch_entries;
  l_subset_id := -1;
  l_cache_id := -1;
  SAVEPOINT RECOVER_SUBSET_START;

  l_action_id := x_action_id;

  ----------------------------------------------------------------
  -- The percentage of the day that the entry can reside in
  -- the cache prior to being thought of as LOST.
  ----------------------------------------------------------------
  l_lost_interval := P_LOST_INTERVAL / G_NUM_MINUTES_IN_DAY;

  ----------------------------------------------------------------
  -- Retrieve the sysdate once to use in the update returns table
  -- buld insert.
  ----------------------------------------------------------------
  SELECT SYSDATE
  INTO   l_update_date
  FROM   DUAL;

  ----------------------------------------------------------------
  -- this loop returns all of the entries that have been checked
  -- out of the list for too long.
  ----------------------------------------------------------------
  FOR entry_rec IN (SELECT   LIST_ENTRY_ID
                    ,        RETURNS_ID
                    FROM     IEC_G_RETURN_ENTRIES
                    WHERE    LIST_HEADER_ID = P_LIST_ID
                    AND      RECORD_OUT_FLAG = 'Y'
                    AND      DO_NOT_USE_FLAG = 'N'
                    AND      NVL(RECYCLE_FLAG, 'N') = 'N'
                    AND      l_update_date > RECORD_RELEASE_TIME + l_lost_interval
                    ORDER BY LIST_ENTRY_ID)
  LOOP

    l_update_count := l_update_list.COUNT + 1;
    l_update_list(l_update_count) := entry_rec.RETURNS_ID;

    IF l_update_list.COUNT = 500
    THEN

      IF (l_action_id = -1)
      THEN

         SELECT IEC_G_RETURN_ENTRY_ACTION_S.NEXTVAL
         INTO   l_action_id
         FROM   DUAL;

         X_ACTION_ID := l_action_id;

      END IF;

    -- might want to get sysdate once and use.
      FORALL j IN 1..L_UPDATE_LIST.COUNT
                UPDATE IEC_G_RETURN_ENTRIES
                SET    RECORD_OUT_FLAG = 'N'
                ,      LAST_UPDATE_DATE = SYSDATE
                ,      LAST_UPDATED_BY = l_user_id
                ,      CHECKIN_ACTION_TYPE = G_RECOVER_ACTION_TYPE
                ,      CHECKIN_ACTION_TIME = SYSDATE
                ,      CHECKIN_ACTION_ID = l_action_id
                WHERE  RETURNS_ID = l_update_list(j);

      l_update_list.DELETE;
      COMMIT;
    END IF;

  END LOOP;  -- end entry loop

    IF l_update_list.COUNT > 0
    THEN

      IF (l_action_id = -1)
      THEN
         SELECT IEC_G_RETURN_ENTRY_ACTION_S.NEXTVAL
         INTO   l_action_id
         FROM   DUAL;

         X_ACTION_ID := l_action_id;

      END IF;

    -- might want to get sysdate once and use.
      FORALL j IN 1..L_UPDATE_LIST.COUNT
                UPDATE IEC_G_RETURN_ENTRIES
                SET    RECORD_OUT_FLAG = 'N'
                ,      CHECKIN_ACTION_TYPE = G_RECOVER_ACTION_TYPE
                ,      CHECKIN_ACTION_TIME = SYSDATE
                ,      CHECKIN_ACTION_ID = l_action_id
                ,      LAST_UPDATE_DATE = SYSDATE
                ,      LAST_UPDATED_BY = l_user_id
                WHERE  RETURNS_ID = l_update_list(j);

      l_update_list.DELETE;
      COMMIT;
    END IF;



 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK;
    RAISE;
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK;
    RAISE;

  ----------------------------------------------------------------
  -- If an anonymous exception has been thrown then
  -- the we must log an internal PLSQL error and
  -- set the return status flag and return to the calling
  -- procedure.
  ----------------------------------------------------------------
  WHEN OTHERS THEN
    Log( 'Recovering List Entries on list ' || p_list_id
       , l_api_name
       , 'MAIN'
       , SQLCODE
       , SQLERRM
       );
    ROLLBACK;
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

 END RECOVER_LIST_ENTRIES;

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
PROCEDURE RECOVER_SCHED_ENTRIES
   ( P_SOURCE_ID            IN             NUMBER
   , P_SCHED_ID             IN             NUMBER
   , P_LOST_INTERVAL        IN             NUMBER
   , X_ACTION_ID               OUT NOCOPY  NUMBER
   )
 IS
  l_status_code VARCHAR2(1);
  l_log_status VARCHAR2(1);
  l_api_name CONSTANT VARCHAR2(30) := 'RECOVER_SCHED_ENTRIES';
  l_action_id NUMBER;

BEGIN
  l_status_code := FND_API.G_RET_STS_SUCCESS;
  x_action_id := NULL;

  ----------------------------------------------------------------
  -- Set the source id to use for logging in
  -- the rest of the package.
  ----------------------------------------------------------------
  G_SOURCE_ID := P_SOURCE_ID;

  ----------------------------------------------------------------
  -- Initialize the return code to 'S'
  ----------------------------------------------------------------
  x_action_id := -1;
  l_action_id := -1;

  ----------------------------------------------------------------
  -- Loop thru the set of executing Lists.  An executing
  -- List is one that has been assigned the AO activity, has
  -- a status of 'ACTIVE' and has the target group associated
  -- with it that has a status of 'EXECUTING'.
  ----------------------------------------------------------------
  FOR schedule_rec IN (SELECT LIST_HEADER_ID
                       FROM   IEC_G_EXECUTING_LISTS_V
											 WHERE SCHEDULE_ID = P_SCHED_ID)
  LOOP

    RECOVER_LIST_ENTRIES( P_SOURCE_ID
                         , schedule_rec.LIST_HEADER_ID
                         , P_LOST_INTERVAL
                         , l_action_id);
  END LOOP;  -- end schedule loop


  COMMIT;

  X_ACTION_ID := l_action_id;

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
    Log( 'Recovering Sched Entries'
       , l_api_name
       , 'MAIN'
       , SQLCODE
       , SQLERRM
       );
    ROLLBACK;
    RAISE_APPLICATION_ERROR(-20999, g_error_msg);

 END RECOVER_SCHED_ENTRIES;

END IEC_RECOVER_PVT;

/
