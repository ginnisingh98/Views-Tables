--------------------------------------------------------
--  DDL for Package Body IEC_CPN_RLSE_STTGY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_CPN_RLSE_STTGY_PVT" AS
/* $Header: IECVCRLB.pls 115.55 2004/05/18 19:38:15 minwang ship $ */

G_CAMPAIGN_ID NUMBER;
G_SERVER_ID NUMBER;
G_SOURCE_ID CONSTANT  NUMBER := -1;
-- Sub-Program Unit Declarations

-- Check if a cpn is active..
PROCEDURE Log
   ( p_method        IN VARCHAR2
   , p_sub_method    IN VARCHAR2
   , p_activity      IN VARCHAR2
   , p_sql_code      IN NUMBER
   , p_sql_errm      IN VARCHAR2)
IS
   l_error_msg VARCHAR2(2048);
BEGIN

   IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
      ( 'IEC_CPN_RLSE_STTGY_PVT'
      , p_method
      , p_sub_method
      , p_activity
      , p_sql_code
      , p_sql_errm
      , l_error_msg
      );

END Log;



PROCEDURE GET_UNAVAILABLE_REASON
  (P_LIST_ID                     IN            NUMBER
  ,X_CALLBACK_AVAILABLE_COUNT    IN OUT NOCOPY NUMBER
  ,X_AVAILABLE_COUNT             IN OUT NOCOPY NUMBER
  ,X_CALLBACK_CHECKED_OUT_COUNT  IN OUT NOCOPY NUMBER
  ,X_CHECKED_OUT_COUNT           IN OUT NOCOPY NUMBER
  ,X_CALENDAR_COUNT              IN OUT NOCOPY NUMBER
  ,X_CALLBACK_CALENDAR_COUNT     IN OUT NOCOPY NUMBER
  ,X_INACTIVE_COUNT              IN OUT NOCOPY NUMBER
  ,X_CALLBACK_RESTRICT_COUNT     IN OUT NOCOPY NUMBER
  )
AS

  L_CALLABLE_FLAG IEC_G_MKTG_ITEM_CC_TZS.CALLABLE_FLAG%TYPE;
  L_STILL_CALLABLE BINARY_INTEGER;
  L_CALLBACK_FLAG IEC_G_RETURN_ENTRIES.CALLBACK_FLAG%TYPE;
  L_CHECKED_OUT_FLAG IEC_G_RETURN_ENTRIES.RECORD_OUT_FLAG%TYPE;
  L_CALLBACK_EXPIRATION BINARY_INTEGER;
  L_STATUS_CODE IEC_G_LIST_SUBSETS.STATUS_CODE%TYPE;
  L_GROUP_COUNT NUMBER;

  L_CALLBACK_AVAILABLE_COUNT NUMBER := 0;
  L_AVAILABLE_COUNT NUMBER := 0;
  L_CALLBACK_CHECKED_OUT_COUNT NUMBER := 0;
  L_CHECKED_OUT_COUNT NUMBER := 0;
  L_CALENDAR_COUNT NUMBER := 0;
  L_CALLBACK_CALENDAR_COUNT NUMBER := 0;
  L_CALLBACK_RESTRICT_COUNT NUMBER := 0;
  L_INACTIVE_COUNT NUMBER := 0;


  CURSOR l_count_cursor(L_LIST_ID NUMBER) IS
    select b.callable_flag
    , decode(sign(nvl(b.last_callable_time, SYSDATE) - SYSDATE), 0, 0, 1, 1, 0)
    , a.callback_flag
    , decode(sign(nvl(NEXT_CALL_TIME, SYSDATE) - SYSDATE), 0, 0, 1, 1, 0)
    , a.record_out_flag
    , c.status_code
    , count(*)
    from iec_g_return_entries a
    , iec_g_mktg_item_Cc_tzs b
    , iec_g_list_subsets c
    where a.list_header_id = L_LIST_ID
    and a.list_header_id = c.list_header_id
    and a.itm_cc_Tz_id = b.itm_cc_tz_id
    and a.do_not_use_Flag = 'N'
    group by b.callable_flag
    , decode(sign(nvl(b.last_callable_time, SYSDATE) - SYSDATE), 0, 0, 1, 1, 0)
    , a.callback_flag
    , decode(sign(nvl(NEXT_CALL_TIME, SYSDATE) - SYSDATE), 0, 0, 1, 1, 0)
    , a.record_out_flag
    , c.status_code;

BEGIN

  BEGIN
    OPEN l_count_cursor(P_LIST_ID);

    LOOP

       FETCH l_count_cursor
         INTO L_CALLABLE_FLAG
         ,    L_STILL_CALLABLE
         ,    L_CALLBACK_FLAG
         ,    L_CALLBACK_EXPIRATION
         ,    L_CHECKED_OUT_FLAG
         ,    L_STATUS_CODE
         ,    L_GROUP_COUNT;

       EXIT WHEN l_count_cursor%NOTFOUND;


       ----------------------------------------------------------------
       -- If the group belongs to an inactive subset then all of the
       -- entries are inactive.
       ----------------------------------------------------------------
       IF (L_STATUS_CODE <> 'ACTIVE')
       THEN
          L_INACTIVE_COUNT := L_INACTIVE_COUNT + L_GROUP_COUNT;

       ----------------------------------------------------------------
       -- This is a callback so count against the callback totals.
       ----------------------------------------------------------------
       ELSIF (L_CALLBACK_FLAG <> 'N')
       THEN

          ----------------------------------------------------------------
          -- These entries are currently checked out.
          ----------------------------------------------------------------
          IF (L_CHECKED_OUT_FLAG = 'Y')
          THEN
             L_CALLBACK_CHECKED_OUT_COUNT := L_CALLBACK_CHECKED_OUT_COUNT + L_GROUP_COUNT;

          ELSIF (L_CALLABLE_FLAG <> 'Y' OR L_STILL_CALLABLE = 0)
          THEN

             L_CALLBACK_CALENDAR_COUNT := L_CALLBACK_CALENDAR_COUNT + L_GROUP_COUNT;

          ELSIF (L_CALLBACK_EXPIRATION = 1)
          THEN
             L_CALLBACK_RESTRICT_COUNT := L_CALLBACK_RESTRICT_COUNT + L_GROUP_COUNT;
          ELSE

             L_CALLBACK_AVAILABLE_COUNT := L_CALLBACK_AVAILABLE_COUNT + L_GROUP_COUNT;

          END IF;
       ----------------------------------------------------------------
       -- This is not a callback so count against the non-callback totals.
       ----------------------------------------------------------------
       ELSE

          ----------------------------------------------------------------
          -- These entries are currently checked out.
          ----------------------------------------------------------------
          IF (L_CHECKED_OUT_FLAG = 'Y')
          THEN
             L_CHECKED_OUT_COUNT := L_CHECKED_OUT_COUNT + L_GROUP_COUNT;

          ELSIF (L_CALLABLE_FLAG <> 'Y' OR L_STILL_CALLABLE = 0)
          THEN

             L_CALENDAR_COUNT := L_CALENDAR_COUNT + L_GROUP_COUNT;

          ELSE

             L_AVAILABLE_COUNT := L_AVAILABLE_COUNT + L_GROUP_COUNT;

          END IF;

       END IF;

    END LOOP;


    CLOSE l_count_cursor;

    X_CALLBACK_AVAILABLE_COUNT := L_CALLBACK_AVAILABLE_COUNT ;
    X_AVAILABLE_COUNT := L_AVAILABLE_COUNT ;
    X_CALLBACK_CHECKED_OUT_COUNT := L_CALLBACK_CHECKED_OUT_COUNT ;
    X_CHECKED_OUT_COUNT := L_CHECKED_OUT_COUNT ;
    X_CALENDAR_COUNT := L_CALENDAR_COUNT ;
    X_CALLBACK_CALENDAR_COUNT := L_CALLBACK_CALENDAR_COUNT ;
    X_INACTIVE_COUNT := L_INACTIVE_COUNT ;


  EXCEPTION
   WHEN NO_DATA_FOUND THEN
     RETURN;
   WHEN OTHERS THEN
     RAISE;
  END;

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END GET_UNAVAILABLE_REASON;


PROCEDURE IS_SCHEDULE_ACTIVE
  (P_SCHEDULE_ID    IN            NUMBER
  ,X_ACTIVE         IN OUT NOCOPY VARCHAR2
  )
  AS
  l_schedule_id NUMBER;
BEGIN

  -- Return success for now..
  X_ACTIVE := FND_API.G_RET_STS_ERROR;

  Begin
        EXECUTE IMMEDIATE 'select unique SCHEDULE_ID ' ||
                          ' from  IEC_G_EXECUTING_LISTS_V ' ||
                          ' where  SCHEDULE_ID = :1 '
                          INTO l_schedule_id
                          USING P_SCHEDULE_ID;

          X_ACTIVE := FND_API.G_RET_STS_SUCCESS;

  Exception
   when NO_DATA_FOUND then
     return;
  End;

END IS_SCHEDULE_ACTIVE;


-- Update subset release strategy info

PROCEDURE UPDATE_SUBSET_RT_INFO
  (P_CAMPAIGN_ID    IN            NUMBER
  ,P_LIST_HEADER_ID IN            NUMBER
  ,P_SUBSET_ID      IN            NUMBER
  ,P_QUANTUM        IN            NUMBER
  ,P_QUOTA          IN            NUMBER
  ,P_QUOTA_RESET    IN            DATE
  ,P_USE_FLAG       IN            VARCHAR2
  ,X_RESULT         IN OUT NOCOPY VARCHAR2
  )
AS
  PRAGMA AUTONOMOUS_TRANSACTION;

BEGIN

  EXECUTE IMMEDIATE 'update iec_g_subset_rt_info ' ||
                    'set working_quantum = :1 ' ||
                    ',   use_flag = :2 ' ||
                    ',   working_quota = :3 ' ||
                    ',   quota_reset_time = :4 ' ||
                    ',   last_update_date = SYSDATE ' ||
                    'where list_subset_id = :5 '
         USING P_QUANTUM
         ,     P_USE_FLAG
         ,     P_QUOTA
         ,     P_QUOTA_RESET
         ,     P_SUBSET_ID;

  X_RESULT := FND_API.G_RET_STS_SUCCESS;
  commit;

END UPDATE_SUBSET_RT_INFO;

PROCEDURE CHECK_OUT_ENTRIES
  (P_SERVER_ID      IN  NUMBER
  ,P_RETURNS_ID_TAB IN  SYSTEM.NUMBER_TBL_TYPE
  )
  AS

   ----------------------------------------------------------------
   -- Bulk Update to check the entries out of AMS_LIST_ENTRIES.
   -- At first don't specify unique index.
   ----------------------------------------------------------------
   BEGIN

   FORALL j IN P_RETURNS_ID_TAB.FIRST..P_RETURNS_ID_TAB.LAST
      UPDATE IEC_G_RETURN_ENTRIES
      SET    RECORD_OUT_FLAG = 'Y'
      ,      CHECKOUT_ACTION_ID = P_SERVER_ID
      ,      RECORD_RELEASE_TIME = SYSDATE
      ,      LAST_UPDATE_DATE = SYSDATE
      WHERE  RETURNS_ID = P_RETURNS_ID_TAB(j);

EXCEPTION
   WHEN OTHERS THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END CHECK_OUT_ENTRIES;

PROCEDURE GET_CUST_CALLBACKS
  (P_SERVER_ID              IN            NUMBER
  ,P_CAMPAIGN_ID            IN            NUMBER
  ,P_SCHEDULE_ID            IN            NUMBER
  ,P_LIST_ID                IN            NUMBER
  ,P_VIEW_NAME              IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID       IN            NUMBER
  ,X_RETURNS_ID_TAB            OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  ,X_RETURN_CODE            IN OUT NOCOPY VARCHAR2
  )
  AS
  CURSOR l_callback_query_cursor(L_LIST_ID NUMBER) IS
                        select
                        d.list_entry_id,
                        d.returns_id,
                        c.priority
                        from iec_g_return_entries d
                        ,    iec_g_list_subsets c
                        where     itm_cc_tz_id in
                        ( select itm_cc_tz_id
                          from  iec_g_mktg_item_cc_tzs
                          where subset_id in
                          ( select a.list_Subset_id
                            from iec_g_list_Subsets a
                            ,    iec_g_subset_rt_info b
                            where a.list_header_id = L_LIST_ID
                            and   a.list_subset_id = b.list_subset_id
                            and   b.working_quota > 0
                            and   b.status_code = 'ACTIVE')
                          and     nvl(callable_flag, 'Y') <> 'N'
                          and     last_callable_time > sysdate)
                        and     nvl( callback_flag, 'N') = 'C'
                        and     nvl( contact_point_index, 0) > 0
                        and     nvl( record_out_flag, 'N') = 'N'
                        and     nvl( do_not_use_flag, 'N') = 'N'
                        and     pulled_subset_id is null
                        and     sysdate > NEXT_CALL_TIME
                        and     d.subset_id = c.list_subset_id
                        order by c.priority;
  l_record_id NUMBER(15);
  l_index BINARY_INTEGER := 0;
  l_callback_count BINARY_INTEGER := 0;
  l_returns_id_tab SYSTEM.NUMBER_TBL_TYPE;

  l_list_entry_id IEC_G_RETURN_ENTRIES.LIST_ENTRY_ID%TYPE;
  l_subset_priority IEC_G_LIST_SUBSETS.PRIORITY%TYPE;
  l_returns_id IEC_G_RETURN_ENTRIES.RETURNS_ID%TYPE;
  l_callable_flag VARCHAR2(1);
  l_return_code VARCHAR2(1);
  l_error_code NUMBER;

BEGIN
   ---------------------------------------------------------
   -- Initialize the status string to send back to success.
   ---------------------------------------------------------
    X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

    l_returns_id_tab := SYSTEM.NUMBER_TBL_TYPE();

   ---------------------------------------------------------
   -- Check to see if the campaign is locked.
   ---------------------------------------------------------
    IEC_COMMON_UTIL_PVT.LOCK_SCHEDULE( P_SOURCE_ID => G_SOURCE_ID
                                     , P_SCHED_ID => P_SCHEDULE_ID
                                     , P_SERVER_ID => P_SERVER_ID
                                     , P_LOCK_ATTEMPTS => 1
                                     , P_ATTEMPT_INTERVAL => 0
                                     , X_SUCCESS_FLAG => l_return_code);

    IF( l_return_code <> 'Y' )
    THEN
      X_RETURN_CODE := SCHEDULE_IS_LOCKED;
      return;
    END IF;

    l_index := l_returns_id_tab.COUNT;

   -------------------------------------------------------------------
   -- First get the customer specified callbacks.  We return all of
   -- these regardless of amount.
   -------------------------------------------------------------------
    OPEN l_callback_query_cursor(P_LIST_ID);

    LOOP

       FETCH l_callback_query_cursor
       INTO l_list_entry_id
       ,    l_returns_id
       ,    l_subset_priority;

       EXIT WHEN l_callback_query_cursor%NOTFOUND;

       -------------------------------------------------------------------
       -- Check DNC and Record Filter before adding this entry to
       -- the list.
       -------------------------------------------------------------------
       IEC_DNC_PVT.IS_CALLABLE( G_SOURCE_ID
                                , P_VIEW_NAME
                                , l_list_entry_id
                                , P_LIST_ID
                                , l_returns_id
                                , l_callable_flag);

       IF (l_callable_flag = 'Y')
       THEN

          -- Check for record filter
          IF (p_rlse_ctrl_alg_id > 0)
          THEN
             IEC_RECORD_FILTER_PVT.Apply_RecordFilter( l_list_entry_id
                                                     , p_list_id
                                                     , l_returns_id
                                                     , p_rlse_ctrl_alg_id
                                                     , p_view_name
                                                     , l_callable_flag);
          END IF;

          IF (l_callable_flag = 'Y')
          THEN
             l_callback_count := l_callback_count + 1;
             l_index := l_index + 1;
             l_returns_id_tab.EXTEND(1);
             l_returns_id_tab(l_index) := l_returns_id;
          END IF;

       END IF;

    END LOOP;

    IF (l_returns_id_tab.COUNT > 0)
    THEN

       CHECK_OUT_ENTRIES( P_SERVER_ID
                        , l_returns_id_tab);
       X_RETURNS_ID_TAB := l_returns_id_tab;

    ELSE
       X_RETURN_CODE := SCHEDULE_IS_EMPTY;
    END IF;

    CLOSE l_callback_query_cursor;

    -- UNLOCK THE CAMPAIGN
    IEC_COMMON_UTIL_PVT.UNLOCK_SCHEDULE( P_SOURCE_ID => G_SOURCE_ID
                                       , P_SCHED_ID => P_SCHEDULE_ID
                                       , P_SERVER_ID => P_SERVER_ID
                                       , X_SUCCESS_FLAG => l_return_code);

    RETURN;
EXCEPTION
   WHEN no_data_found THEN

      IF l_callback_query_cursor%ISOPEN
      THEN
         CLOSE l_callback_query_cursor;
      END IF;
       return;
   WHEN OTHERS THEN
      L_ERROR_CODE := SQLCODE;
      IF l_callback_query_cursor%ISOPEN
      THEN
         CLOSE l_callback_query_cursor;
      END IF;

      raise_application_error
        ( -20000
         , 'SQLCODE: <' || L_ERROR_CODE || '> SQLMESSAGE <' || SQLERRM || '>'
         ,TRUE
        );
END GET_CUST_CALLBACKS;

PROCEDURE GET_CALLBACKS
  (P_SERVER_ID              IN            NUMBER
  ,P_CAMPAIGN_ID            IN            NUMBER
  ,P_SCHEDULE_ID            IN            NUMBER
  ,P_LIST_ID                IN            NUMBER
  ,P_COUNT                  IN            NUMBER
  ,P_VIEW_NAME              IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID       IN            NUMBER
  ,X_RETURNS_ID_TAB            OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  ,X_RETURN_CODE            IN OUT NOCOPY VARCHAR2
  )
  AS

  CURSOR l_callback_query_cursor(L_LIST_ID NUMBER) IS
                        select
                        d.list_entry_id,
                        d.returns_id,
                        c.priority
                        from iec_g_return_entries d
                        ,    iec_g_list_subsets c
                        where     itm_cc_tz_id in
                        ( select itm_cc_tz_id
                          from  iec_g_mktg_item_cc_tzs
                          where subset_id in
                          ( select a.list_Subset_id
                            from iec_g_list_Subsets a
                            ,    iec_g_subset_rt_info b
                            where a.list_header_id = L_LIST_ID
                            and   a.list_subset_id = b.list_subset_id
                            and   b.working_quota > 0
                            and   b.status_code = 'ACTIVE')
                          and     nvl(callable_flag, 'Y') <> 'N'
                          and     last_callable_time > sysdate)
                        and     nvl( callback_flag, 'N') = 'Y'
                        and     nvl( contact_point_index, 0) > 0
                        and     nvl( record_out_flag, 'N') = 'N'
                        and     nvl( do_not_use_flag, 'N') = 'N'
                        and     pulled_subset_id is null
                        and     sysdate > NEXT_CALL_TIME
                        and     d.subset_id = c.list_subset_id
                        order by c.priority;

  l_record_id NUMBER(15);
  l_index BINARY_INTEGER := 0;
  l_callback_count BINARY_INTEGER := 0;
  l_returns_id_tab SYSTEM.NUMBER_TBL_TYPE := SYSTEM.NUMBER_TBL_TYPE();

  l_list_entry_id IEC_G_RETURN_ENTRIES.LIST_ENTRY_ID%TYPE;
  l_subset_priority IEC_G_LIST_SUBSETS.PRIORITY%TYPE;
  l_returns_id IEC_G_RETURN_ENTRIES.RETURNS_ID%TYPE;
  l_callable_flag VARCHAR2(1);
  l_return_code VARCHAR2(1);
  l_error_code NUMBER;

BEGIN

   ---------------------------------------------------------
   -- Initialize the status string to send back to success.
   ---------------------------------------------------------
    X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

   ---------------------------------------------------------
   -- Check to see if the campaign is locked.
   ---------------------------------------------------------
    IEC_COMMON_UTIL_PVT.LOCK_SCHEDULE( P_SOURCE_ID => G_SOURCE_ID
                                     , P_SCHED_ID => P_SCHEDULE_ID
                                     , P_SERVER_ID => P_SERVER_ID
                                     , P_LOCK_ATTEMPTS => 1
                                     , P_ATTEMPT_INTERVAL => 0
                                     , X_SUCCESS_FLAG => l_return_code);

    IF( l_return_code <> 'Y' )
    THEN
      X_RETURN_CODE := SCHEDULE_IS_LOCKED;
      return;
    END IF;

    l_index := l_returns_id_tab.COUNT;

    IF (P_COUNT > 0)
    THEN
       OPEN l_callback_query_cursor(P_LIST_ID);

       LOOP

          FETCH l_callback_query_cursor
          INTO l_list_entry_id
          ,    l_returns_id
          ,    l_subset_priority;

          EXIT WHEN l_callback_query_cursor%NOTFOUND;

          -------------------------------------------------------------------
          -- Check DNC and Record Filter before adding this entry to
          -- the list.
          -------------------------------------------------------------------
          IEC_DNC_PVT.IS_CALLABLE( G_SOURCE_ID
                                 , P_VIEW_NAME
                                 , l_list_entry_id
                                 , P_LIST_ID
                                 , l_returns_id
                                 , l_callable_flag);

          IF (l_callable_flag = 'Y')
          THEN

             -- Check for record filter
             IF (p_rlse_ctrl_alg_id > 0)
             THEN
                IEC_RECORD_FILTER_PVT.Apply_RecordFilter( l_list_entry_id
                                                        , p_list_id
                                                        , l_returns_id
                                                        , p_rlse_ctrl_alg_id
                                                        , p_view_name
                                                        , l_callable_flag);
             END IF;

             IF (l_callable_flag = 'Y')
             THEN
                l_callback_count := l_callback_count + 1;
                l_index := l_index + 1;
                l_returns_id_tab.EXTEND(1);
                l_returns_id_tab(l_index) := l_returns_id;
             END IF;

          END IF;

          EXIT WHEN l_callback_count >= P_COUNT;

       END LOOP;

       IF (l_returns_id_tab.COUNT > 0)
       THEN

          CHECK_OUT_ENTRIES( P_SERVER_ID
                           , l_returns_id_tab);
          X_RETURNS_ID_TAB := l_returns_id_tab;

       ELSE
          X_RETURN_CODE := SCHEDULE_IS_EMPTY;
       END IF;

    END IF;

    CLOSE l_callback_query_cursor;

    -- UNLOCK THE CAMPAIGN
    IEC_COMMON_UTIL_PVT.UNLOCK_SCHEDULE( P_SOURCE_ID => G_SOURCE_ID
                                       , P_SCHED_ID => P_SCHEDULE_ID
                                       , P_SERVER_ID => P_SERVER_ID
                                       , X_SUCCESS_FLAG => l_return_code);


    RETURN;
EXCEPTION
   WHEN no_data_found THEN

      IF l_callback_query_cursor%ISOPEN
      THEN
         CLOSE l_callback_query_cursor;
      END IF;
       return;
   WHEN OTHERS THEN
      L_ERROR_CODE := SQLCODE;
      IF l_callback_query_cursor%ISOPEN
      THEN
         CLOSE l_callback_query_cursor;
      END IF;
      raise_application_error
        ( -20000
         , 'SQLCODE: <' || L_ERROR_CODE || '> SQLMESSAGE <' || SQLERRM || '>'
         ,TRUE
        );
END GET_CALLBACKS;

-- Get a working subset
PROCEDURE GET_SUBSET_ENTRIES
  (P_CAMPAIGN_ID       IN            NUMBER
  ,P_LIST_HEADER_ID    IN            NUMBER
  ,P_SUBSET_ID         IN            NUMBER
  ,P_COUNT             IN            NUMBER
  ,P_RLSE_CTRL_ALG_ID  IN            IEC_G_EXECUTING_LISTS_V.RELEASE_CONTROL_ALG_ID%TYPE
  ,P_VIEW_NAME         IN            VARCHAR2
  ,X_RETURN_CODE       IN OUT NOCOPY VARCHAR2
  ,X_RETURNS_ID_TAB    IN OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  )
  AS

  CURSOR l_entry_query_cursor(L_SUBSET_ID NUMBER) IS
                        select /*+ index ( iec_g_return_entries, iec_g_return_entries_n8 ) */ list_entry_id,
                        returns_id
                        from iec_g_return_entries
                        where   itm_cc_tz_id in
                        ( select itm_cc_tz_id
                          from  iec_g_mktg_item_cc_tzs
                          where subset_id  = L_SUBSET_ID
                          and     nvl(callable_flag, 'Y') <> 'N'
                          and     last_callable_time > sysdate)
                        and     nvl( callback_flag, 'N') = 'N'
                        and     nvl( contact_point_index, 0) > 0
                        and     nvl( record_out_flag, 'N') = 'N'
                        and     nvl( do_not_use_flag, 'N') = 'N'
                        and     pulled_subset_id is null
                        order by record_release_time asc;

  l_record_id NUMBER := 0;
  l_list_entry_id NUMBER := 0;
  l_returns_id NUMBER := 0;
  l_entry_count BINARY_INTEGER := 0;
  l_callable_flag VARCHAR2(1);
  l_index NUMBER;

BEGIN

   -- Init defaults -
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;
   l_index := X_RETURNS_ID_TAB.COUNT;

   OPEN l_entry_query_cursor(P_SUBSET_ID);

   -------------------------------------------------------------------
   -- Need to change this to fetch one-by-one and apply the dnc and
   -- record filter.
   -------------------------------------------------------------------
    LOOP

       FETCH l_entry_query_cursor
       INTO l_list_entry_id
       ,    l_returns_id;

       EXIT WHEN l_entry_query_cursor%NOTFOUND;

       -------------------------------------------------------------------
       -- Check DNC and Record Filter before adding this entry to
       -- the list.
       -------------------------------------------------------------------
       IEC_DNC_PVT.IS_CALLABLE( G_SOURCE_ID
                                , P_VIEW_NAME
                                , l_list_entry_id
                                , P_LIST_HEADER_ID
                                , l_returns_id
                                , l_callable_flag);

       IF (l_callable_flag = 'Y')
       THEN

          -- Check for record filter
          IF (p_rlse_ctrl_alg_id > 0)
          THEN
             IEC_RECORD_FILTER_PVT.Apply_RecordFilter( l_list_entry_id
                                                     , p_list_header_id
                                                     , l_returns_id
                                                     , p_rlse_ctrl_alg_id
                                                     , p_view_name
                                                     , l_callable_flag);
          END IF;

          IF (l_callable_flag = 'Y')
          THEN
             l_entry_count := l_entry_count + 1;
             l_index := l_index + 1;
             X_RETURNS_ID_TAB.EXTEND(1);
             X_RETURNS_ID_TAB(l_index) := l_returns_id;
          END IF;

       END IF;


       EXIT WHEN l_entry_count >= P_COUNT;

    END LOOP;

    CLOSE l_entry_query_cursor;

    return;
EXCEPTION
   WHEN no_data_found then
       return;
END GET_SUBSET_ENTRIES;

PROCEDURE GET_SCHED_ENTRIES
  (P_CAMPAIGN_ID       IN            NUMBER
  ,P_SCHED_ID          IN            NUMBER
  ,P_LIST_HEADER_ID    IN            NUMBER
  ,P_COUNT             IN            NUMBER
  ,P_VIEW_NAME         IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID  IN            NUMBER
  ,X_RETURN_CODE       IN OUT NOCOPY VARCHAR2
  ,X_RETURNS_ID_TAB    IN OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  )
  AS

  l_subset_priority_tbl     SUBSET_PRIORITY;
  l_subset_id_tbl           SUBSET_ID;
  l_working_quantum_tbl     WORKING_QUANTUM;
  l_working_quota_tbl       WORKING_QUOTA;
  l_quantum_tbl             QUANTUM;
  l_quota_tbl               QUOTA;
  l_quota_reset_time_tbl    QUOTA_RESET_TIME;
  l_quota_reset_tbl         QUOTA_RESET;
  l_use_flag_tbl            USE_FLAG;
  l_release_strategy_tbl    RELEASE_STRATEGY;
  l_subset_updated_tbl      FLAG_COLLECTION;
  l_subset_empty_tbl        FLAG_COLLECTION;
  l_entries_released_tbl    QUOTA;

  l_reg_returns_id_tab      SYSTEM.NUMBER_TBL_TYPE := SYSTEM.NUMBER_TBL_TYPE();

  l_has_records NUMBER(1);

  l_fetch_records NUMBER(10) := 0;

  l_list_count NUMBER := 0;
  l_subset_count NUMBER := 0;
  l_callback_count NUMBER := 0;

  l_record_id NUMBER(15);
  l_entry_index NUMBER := 0;

  -------------------------------------------------------------------
  -- Physical index is used to store the start of the subsets that
  -- are assigned the current priority in the subset collection.
  -------------------------------------------------------------------
  l_priority_start_index BINARY_INTEGER := 0;

  -------------------------------------------------------------------
  -- Physical index is used to store the end of the subsets that
  -- are assigned the current priority in the subset collection.
  -------------------------------------------------------------------
  l_priority_end_index BINARY_INTEGER := 0;

  -------------------------------------------------------------------
  -- Logical index is used to store the subset that had the token
  -- at the start of the routine for the subsets that
  -- are assigned the current priority in the subset collection.
  -------------------------------------------------------------------
  l_priority_logical_index BINARY_INTEGER := 0;
  l_priority_current_index BINARY_INTEGER := 0;

  l_subset_index BINARY_INTEGER := 0;

  l_current_priority BINARY_INTEGER := 0;
  l_current_priority_count BINARY_INTEGER := 0;

  l_additional_entries_in_pri BOOLEAN := FALSE;
  l_additional_entries_in_list BOOLEAN := FALSE;
  l_restriction_encountered BOOLEAN := FALSE;
  l_disregard_restriction BOOLEAN := FALSE;
  l_priority_transition BOOLEAN := TRUE;
  l_subset_transition BOOLEAN := FALSE;
  l_priority_token_found BOOLEAN := FALSE;

BEGIN
  l_has_records := -1;

   -- Init defaults -
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;
   l_list_count := P_COUNT;
   l_entry_index := X_RETURNS_ID_TAB.COUNT;

   -------------------------------------------------------------------
   -- Get the subsets for the highest priority.
   -------------------------------------------------------------------
   SELECT a.list_subset_id
   ,      a.priority
   ,      a.release_strategy
   ,      b.working_quantum
   ,      b.working_quota
   ,      a.quota
   ,      a.quantum
   ,      b.quota_reset_time
   ,      b.use_flag
   ,      a.quota_reset
   BULK COLLECT INTO l_subset_id_tbl
   ,                 l_subset_priority_tbl
   ,                 l_release_strategy_tbl
   ,                 l_working_quantum_tbl
   ,                 l_working_quota_tbl
   ,                 l_quota_tbl
   ,                 l_quantum_tbl
   ,                 l_quota_reset_time_tbl
   ,                 l_use_flag_tbl
   ,                 l_quota_reset_tbl
   FROM iec_g_list_subsets a
   ,    iec_g_subset_rt_info b
   WHERE a.list_header_id = P_LIST_HEADER_ID
   AND   a.list_subset_id = b.list_subset_id
   AND   b.valid_flag = 'Y'
   AND   b.callable_flag = 'Y'
   AND   b.STATUS_CODE = 'ACTIVE'
   ORDER BY a.priority, a.list_subset_id;

   -------------------------------------------------------------------
   -- Create two more collections for storing information on each
   -- subset as to whether it was updated and if it contains
   -- callable records.
   -------------------------------------------------------------------
   FOR j in 1 .. l_subset_id_tbl.COUNT
   LOOP
      l_subset_updated_tbl(j) := 'Y';
      l_subset_empty_tbl(j) := 'N';
      l_entries_released_tbl(j) := 0;
   END LOOP;

   -------------------------------------------------------------------
   -- While we still have entries to fulfill.
   -------------------------------------------------------------------
   WHILE l_list_count > 0
   LOOP
      -------------------------------------------------------------------
      -- Initialize the collection used to retrieve subset entries.
      -------------------------------------------------------------------
      l_reg_returns_id_tab.DELETE;

      -------------------------------------------------------------------
      -- If we have switched priorities then we need to locate the
      -- subset that currently owns the token to start fetching records
      -- from for that priority.  If none of the subsets owns the token
      -- then pick the first one.  We also will locate the index in
      -- the collection that marks the final subset with this priority
      -- and get a count of how many subsets are in this priority.
      -------------------------------------------------------------------
      IF l_priority_transition = TRUE
      THEN

         l_priority_transition := FALSE;
         l_priority_token_found := FALSE;

         -------------------------------------------------------------------
         -- Check to ensure that the current priority is not the last
         -- priority in the collection.
         -------------------------------------------------------------------
         IF l_priority_end_index >= l_subset_priority_tbl.COUNT
         THEN

            -------------------------------------------------------------------
            -- Since the routine has been thru the entire collection of priorities
            -- assigned to this list and we didn't come across any subsets that
            -- still had entries then just return with what we have.
            -------------------------------------------------------------------
            IF l_additional_entries_in_list = FALSE
            THEN

               -------------------------------------------------------------------
               -- If this list is set for quota and some subsets were turned off
               -- due to quota restrictions then remove restrictions and try
               -- again.
               -------------------------------------------------------------------
               IF l_restriction_encountered = TRUE
               THEN
                  l_additional_entries_in_pri := FALSE;
                  l_additional_entries_in_list := FALSE;
                  l_restriction_encountered := FALSE;
                  l_disregard_restriction := TRUE;
                  l_priority_end_index := 0;
               ELSE
                  EXIT;
               END IF;

            -------------------------------------------------------------------
            -- If there are still entries in the list then return to the first priority and
            -- reinitialize the list_index, additional_entries_in_pri, and
            -- priority_index variable.  We might need to set the working quantum
            -- here if we change to the next list.  Also need to look at the use
            -- flag (the priority token).
            -------------------------------------------------------------------
            ELSE
               l_additional_entries_in_pri := FALSE;
               l_additional_entries_in_list := FALSE;
               l_priority_end_index := 0;
            END IF;

         END IF;

         -------------------------------------------------------------------
         -- Reinitialize the priority indexes.
         -------------------------------------------------------------------
         l_priority_start_index := l_priority_end_index + 1;
         l_priority_end_index := 0;
         l_priority_logical_index := l_priority_start_index;
         l_priority_current_index := l_priority_start_index;
         l_current_priority := l_subset_priority_tbl(l_priority_start_index);
         l_current_priority_count := 1;

         -------------------------------------------------------------------
         -- Continue looping thru collection until we locate the last
         -- subset in the collection that belongs to this priority.
         -------------------------------------------------------------------
         WHILE l_priority_end_index = 0
         LOOP

            -------------------------------------------------------------------
            -- Found the subset in the priority has the token so continue
            -- on and set the priority transition flag to FALSE.
            -------------------------------------------------------------------
            IF l_use_flag_tbl(l_priority_current_index) = 'Y'
            THEN
               l_priority_logical_index := l_priority_current_index;
               l_priority_token_found := TRUE;
            END IF;

            -------------------------------------------------------------------
            -- If the current index is equal to the last entry in the collection
            -- then we can assume that we have checked all of the subsets in
            -- this priority and make the appropriate assignments for
            -- this priority.
            -------------------------------------------------------------------
            IF l_priority_current_index < l_subset_priority_tbl.COUNT
            THEN

               -------------------------------------------------------------------
               -- If the priority on the next subset in the collection indicates
               -- that it is belongs to the same priority as the previous subset
               -- then increment the subset index.
               -------------------------------------------------------------------
               IF l_subset_priority_tbl(l_priority_current_index + 1) = l_current_priority
               THEN
                  l_priority_current_index := l_priority_current_index + 1;
                  l_current_priority_count := l_current_priority_count + 1;

               -------------------------------------------------------------------
               -- If the priority on the next subset in the collection indicates
               -- that it belongs to a different priority as the previous subset
               -- then give the token to the first subset in priority.
               -------------------------------------------------------------------
               ELSE
                  IF l_priority_token_found = FALSE
                  THEN
                     l_subset_index := l_priority_start_index;
                     l_use_flag_tbl(l_priority_start_index) := 'Y';
                  ELSE
                     l_subset_index := l_priority_logical_index;
                     l_use_flag_tbl(l_priority_logical_index) := 'Y';
                  END IF;
                  l_priority_end_index := l_priority_current_index;
               END IF;

            -------------------------------------------------------------------
            -- If there are no more subsets to check then
            -- set the end index for this priority.
            -------------------------------------------------------------------
            ELSE
               l_subset_index := l_priority_logical_index;
               l_use_flag_tbl(l_priority_logical_index) := 'Y';
               l_priority_end_index := l_priority_current_index;
            END IF;

         END LOOP;

      END IF;  -- Priority transition conditional

      -------------------------------------------------------------------
      -- If this subset has already been visited and determined that no
      -- entries could be fetched from it, then don't try again.
      -------------------------------------------------------------------
      IF l_subset_empty_tbl(l_subset_index) = 'N'
      THEN

         -------------------------------------------------------------------
         -- If quantum strategy then use working quantum only.
         -------------------------------------------------------------------
         IF l_release_strategy_tbl(l_subset_index) = QUANTUM_RLSE_STTGY
         THEN

            -------------------------------------------------------------------
            -- Determines the number to try and retrieve.  If there is only
            -- one subset in this priority then try to fulfill the number
            -- requested on this list using just the single subset.  Otherwise
            -- if requested is greater than working quantum on current subset
            -- then retrieve current subset otherwise return requested.
            -------------------------------------------------------------------
            IF l_current_priority_count = 1
            THEN
               l_subset_count := l_list_count;
            ELSE
               IF l_working_quantum_tbl(l_subset_index) < l_list_count
               THEN
                  l_subset_count := l_working_quantum_tbl(l_subset_index);
               ELSE
                  l_subset_count := l_list_count;
               END IF;
            END IF;
         -------------------------------------------------------------------
         -- If quota strategy then check working quota as well.
         -------------------------------------------------------------------
         ELSIF l_release_strategy_tbl(l_subset_index) = QUOTA_RLSE_STTGY
         THEN

            -------------------------------------------------------------------
            -- First check to see if the quota reset time has been reached.  If
            -- it has we then need to update the quota reset time to the next
            -- time.
            -------------------------------------------------------------------
            IF l_quota_reset_time_tbl(l_subset_index) <= SYSDATE
            THEN
               l_working_quota_tbl(l_subset_index) := l_quota_tbl(l_subset_index);
               IF (l_quota_reset_time_tbl(l_subset_index) + (l_quota_reset_tbl(l_subset_index) / 1440)) > SYSDATE
               THEN
                  l_quota_reset_time_tbl(l_subset_index) := l_quota_reset_time_tbl(l_subset_index) + (l_quota_reset_tbl(l_subset_index) / 1440);
               ELSE
                  l_quota_reset_time_tbl(l_subset_index) := SYSDATE + (l_quota_reset_tbl(l_subset_index) / 1440);
               END IF;
            END IF;

            -------------------------------------------------------------------
            -- The quota on this subset has been reached but the reset time has
            -- not expired therefore we move on to the next subset.  This disregards
            -- priorities.  The only reason we would pull from this subset at
            -- this time is if there are no other subsets that have quota left.
            -------------------------------------------------------------------
            IF (l_working_quota_tbl(l_subset_index) = 0 OR l_entries_released_tbl(l_subset_index) >= l_working_quota_tbl(l_subset_index))
               AND l_disregard_restriction = FALSE
            THEN
               l_restriction_encountered := TRUE;
               l_subset_count := 0;

            ELSE

               -------------------------------------------------------------------
               -- If the quota is greater than zero then we release according to
               -- the quantum.  This could cause some issues with quota release
               -- strategy because the dial server now could contain 100 entries
               -- from this list even though the quota only is 1.  If the one
               -- is reached then currently we have no means to flush out the
               -- entries that are currently in the dial server.
               -------------------------------------------------------------------

               -------------------------------------------------------------------
               -- This strategy will only release maximum the remaining quota number
               -- of entries or the remaining quantum which ever is smaller.
               -------------------------------------------------------------------
               IF l_working_quota_tbl(l_subset_index) < l_list_count AND l_disregard_restriction = FALSE
               THEN
                  IF l_working_quantum_tbl(l_subset_index) < l_working_quota_tbl(l_subset_index)
                  THEN
                     l_subset_count := l_working_quantum_tbl(l_subset_index);
                  ELSE
                     l_subset_count := l_working_quota_tbl(l_subset_index);
                  END IF;
               ELSE
                  IF l_current_priority_count = 1
                  THEN
                     l_subset_count := l_list_count;
                  ELSE
                     IF l_working_quantum_tbl(l_subset_index) < l_list_count
                     THEN
                        l_subset_count := l_working_quantum_tbl(l_subset_index);
                     ELSE
                        l_subset_count := l_list_count;
                     END IF;
                  END IF;
               END IF;
            END IF;
         END IF;

         IF l_subset_count > 0
         THEN
            get_subset_entries( P_CAMPAIGN_ID => P_CAMPAIGN_ID
                              , P_LIST_HEADER_ID => P_LIST_HEADER_ID
                              , P_SUBSET_ID => l_subset_id_tbl(l_subset_index)
                              , P_COUNT => l_subset_count
                              , P_RLSE_CTRL_ALG_ID  => P_RLSE_CTRL_ALG_ID
                              , P_VIEW_NAME => P_VIEW_NAME
                              , X_RETURN_CODE => X_RETURN_CODE
                              , X_RETURNS_ID_TAB => l_reg_RETURNS_ID_TAB );

            IF ( X_RETURN_CODE <> FND_API.G_RET_STS_SUCCESS )
            THEN
               exit;
            END IF;

            -------------------------------------------------------------------
            -- If entries are returned then add the returned entries to
            -- the collection returned for the schedule as a whole.
            -------------------------------------------------------------------
            IF (l_reg_returns_id_tab.COUNT > 0)
            THEN

               IF (X_RETURNS_ID_TAB.COUNT = 0)
               THEN
                  l_entry_index := 0;
               ELSE
                  l_entry_index := X_RETURNS_ID_TAB.COUNT;
               END IF;

               FOR M in l_reg_returns_id_tab.FIRST .. l_reg_returns_id_tab.LAST
               LOOP
                  l_entry_index := l_entry_index + 1;
                  X_RETURNS_ID_TAB.EXTEND(1);
                  X_RETURNS_ID_TAB(l_entry_index) := l_reg_returns_id_tab(M);
               END LOOP;

               CHECK_OUT_ENTRIES( G_SERVER_ID
                                , l_reg_returns_id_tab);

               l_entries_released_tbl(l_subset_index) := l_entries_released_tbl(l_subset_index) + l_reg_returns_id_tab.COUNT;

            END IF;  -- IF ENTRIES WERE RETURNED

            -------------------------------------------------------------------
            -- If the number returned is less then the number requested then
            -- the subset has no more callable records to contribute at this
            -- time.  Determine if the process needs to continue to the next
            -- subset or not.
            -------------------------------------------------------------------
            IF (l_reg_returns_id_tab.COUNT < l_subset_count)
            THEN
               l_subset_transition := TRUE;
               l_subset_empty_tbl(l_subset_index) := 'Y';
            ELSE
               l_subset_empty_tbl(l_subset_index) := 'N';
               l_additional_entries_in_pri := TRUE;
               l_additional_entries_in_list := TRUE;
               IF l_reg_returns_id_tab.COUNT < l_list_count
               THEN
                  l_subset_transition := TRUE;
               ELSE
                  IF l_working_quantum_tbl(l_subset_index) <= l_reg_returns_id_tab.COUNT
                  THEN
                     l_subset_transition := TRUE;
                  END IF;
               END IF;
            END IF;

            l_list_count := l_list_count - l_reg_returns_id_tab.COUNT;

         ELSE
            l_subset_transition := TRUE;
         END IF; -- IF SUBSET COUNT > 0
      ELSE
         l_subset_transition := TRUE;
      END IF;  -- IF SUBSET EMPTY CONDITIONAL.

      -------------------------------------------------------------------
      -- The next section determines if the next subset to attempt to
      -- retrieve entries from is assigned the same priority as the
      -- current subset.
      -------------------------------------------------------------------
      IF l_subset_index = l_priority_end_index
      THEN
         l_priority_current_index := l_priority_start_index;
      ELSE
         l_priority_current_index := l_subset_index + 1;
      END IF;

      -------------------------------------------------------------------
      -- We have gone thru all of the subsets for this priority once.
      -------------------------------------------------------------------
      IF l_priority_current_index =  l_priority_logical_index
      THEN

         -------------------------------------------------------------------
         -- We have alredy went thru the priority once so reset the fetch
         -- token as well as the additional entries in priority flag.
         -------------------------------------------------------------------
         IF l_subset_Transition = TRUE
         THEN
            l_working_quantum_tbl(l_subset_index) := l_quantum_tbl(l_subset_index);
            l_use_flag_tbl(l_subset_index) := 'N';
            l_use_flag_tbl(l_priority_current_index) := 'Y';
         ELSE
            l_working_quantum_tbl(l_subset_index) := l_working_quantum_tbl(l_subset_index) - l_reg_returns_id_tab.COUNT;
         END IF;

         -------------------------------------------------------------------
         -- If there are additional entries in the current priority then
         -- stay with this priority otherwise move to the next priority.
         -------------------------------------------------------------------
         IF l_additional_entries_in_pri = TRUE
         THEN
            l_subset_index := l_priority_logical_index;
            l_priority_transition := FALSE;
         ELSE
            l_subset_index := l_priority_end_index;
            l_priority_transition := TRUE;
         END IF;
         l_additional_entries_in_pri := FALSE;

      -------------------------------------------------------------------
      -- Haven't gone thru the priority so move to next subset in
      -- priority.
      -------------------------------------------------------------------
      ELSE
         l_priority_transition := FALSE;
         IF l_subset_Transition = TRUE
         THEN
            l_working_quantum_tbl(l_subset_index) := l_quantum_tbl(l_subset_index);
            l_use_flag_tbl(l_subset_index) := 'N';
            l_use_flag_tbl(l_priority_current_index) := 'Y';
         ELSE
            l_working_quantum_tbl(l_subset_index) := l_working_quantum_tbl(l_subset_index) - l_reg_returns_id_tab.COUNT;
         END IF;
         l_subset_index := l_priority_current_index;
      END IF;

      l_subset_transition := FALSE;

   END LOOP;         -- list loop

   -------------------------------------------------------------------
   -- Loop thru the subsets and update rt info when necessary.
   -------------------------------------------------------------------
   FOR j in 1 .. l_subset_id_tbl.COUNT
   LOOP
      IF l_subset_updated_tbl(j) = 'Y'
      THEN
         UPDATE_SUBSET_RT_INFO( P_CAMPAIGN_ID    => P_CAMPAIGN_ID
                              , P_LIST_HEADER_ID => P_LIST_HEADER_ID
                              , P_SUBSET_ID      => l_subset_id_tbl(j)
                              , P_QUANTUM        => l_working_quantum_tbl(j)
                              , P_QUOTA          => l_working_quota_tbl(j)
                              , P_QUOTA_RESET    => l_quota_reset_time_tbl(j)
                              , P_USE_FLAG       => l_use_flag_tbl(j)
                              , X_RESULT         => X_RETURN_CODE);
      END IF;
   END LOOP;

EXCEPTION
   WHEN no_data_found then
       return;
END GET_SCHED_ENTRIES;

-- Get the records.
PROCEDURE GET_RECORDS
  (P_SERVER_ID        IN            NUMBER
  ,P_CAMPAIGN_ID      IN            NUMBER
  ,P_SCHED_ID         IN            NUMBER
  ,P_TARGET_GROUP_ID  IN            NUMBER
  ,P_COUNT            IN            NUMBER
  ,P_VIEW_NAME        IN            VARCHAR2
  ,P_RLSE_CTRL_ALG_ID IN            NUMBER
  ,X_CACHE_RECORDS       OUT NOCOPY SYSTEM.NUMBER_TBL_TYPE
  ,X_RETURN_CODE         OUT NOCOPY VARCHAR2
  )
  AS

  l_result_code varchar2( 1 );
  l_count NUMBER := 0;
  l_returns_id_tab SYSTEM.NUMBER_TBL_TYPE := SYSTEM.NUMBER_TBL_TYPE();
  l_return_code VARCHAR2(1);
  L_CALLBACK_AVAILABLE_COUNT NUMBER := 0;
  L_AVAILABLE_COUNT NUMBER := 0;
  L_CALLBACK_CHECKED_OUT_COUNT NUMBER := 0;
  L_CHECKED_OUT_COUNT NUMBER := 0;
  L_CALENDAR_COUNT NUMBER := 0;
  L_CALLBACK_CALENDAR_COUNT NUMBER := 0;
  L_INACTIVE_COUNT NUMBER := 0;
  L_CALLBACK_RESTRICT_COUNT NUMBER := 0;
  L_ERROR_CODE NUMBER := 0;

BEGIN
    G_CAMPAIGN_ID := P_CAMPAIGN_ID;
    G_SERVER_ID := P_SERVER_ID;

  ---------------------------------------------------------
  -- Initialize the status string to send back to success.
  ---------------------------------------------------------
  X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

  ---------------------------------------------------------
  -- Make sure all parameters are passed in.
  ---------------------------------------------------------
  IF( ( P_SERVER_ID is null )
    OR( P_CAMPAIGN_ID is null )
    OR( P_SCHED_ID is null )
    OR( P_TARGET_GROUP_ID is null )
    OR( P_COUNT is null )
    OR( P_VIEW_NAME is null)
    )
  THEN
    raise_application_error
      ( -20000
       , 'P_SERVER_ID , P_CAMPAIGN_ID cannot be null.'
         || 'Values sent are Server id (' || P_SERVER_ID || ')'
         || ' Campaign id (' || P_CAMPAIGN_ID || ')'
         || ' Count (' || P_COUNT || ')'
       ,TRUE
      );
  END IF;

  ---------------------------------------------------------
  -- Check to make sure the campaign is active.
  ---------------------------------------------------------
  IS_SCHEDULE_ACTIVE( P_SCHED_ID
                    , l_return_code );

  IF( l_return_code <> FND_API.G_RET_STS_SUCCESS )
  THEN
    X_RETURN_CODE := SCHEDULE_IS_NOT_ACTIVE;
    return;
  END IF;

  ---------------------------------------------------------
  -- Check to see if the campaign is locked.
  ---------------------------------------------------------
  IEC_COMMON_UTIL_PVT.LOCK_SCHEDULE( P_SOURCE_ID => G_SOURCE_ID
                                   , P_SCHED_ID => P_SCHED_ID
                                   , P_SERVER_ID => P_SERVER_ID
                                   , P_LOCK_ATTEMPTS => 1
                                   , P_ATTEMPT_INTERVAL => 0
                                   , X_SUCCESS_FLAG => l_return_code);

  IF( l_return_code <> 'Y' )
  THEN
    X_RETURN_CODE := SCHEDULE_IS_LOCKED;
    return;
  END IF;

  ---------------------------------------------------------
  -- Move the desired customer count to a local variable.
  ---------------------------------------------------------
  l_count := P_COUNT;

  ---------------------------------------------------------
  -- Procedure to return the entries for this schedule.
  ---------------------------------------------------------
  GET_SCHED_ENTRIES( P_CAMPAIGN_ID      => P_CAMPAIGN_ID
                   , P_SCHED_ID         => P_SCHED_ID
                   , P_LIST_HEADER_ID   => P_TARGET_GROUP_ID
                   , P_COUNT            => l_COUNT
                   , P_VIEW_NAME        => P_VIEW_NAME
                   , P_RLSE_CTRL_ALG_ID => P_RLSE_CTRL_ALG_ID
                   , X_RETURN_CODE      => l_result_code
                   , X_RETURNS_ID_TAB   => l_returns_id_tab );

    if( l_result_code <> FND_API.G_RET_STS_SUCCESS )
    then
       IEC_COMMON_UTIL_PVT.UNLOCK_SCHEDULE( P_SOURCE_ID    => G_SOURCE_ID
                                          , P_SCHED_ID     => P_SCHED_ID
                                          , P_SERVER_ID    => P_SERVER_ID
                                          , X_SUCCESS_FLAG => l_return_code);
       X_RETURN_CODE := SCHEDULE_INTERNAL_ERROR;
       return;
    end if;

    if( l_returns_id_tab.count <= 0 )
    then
       IEC_COMMON_UTIL_PVT.UNLOCK_SCHEDULE( P_SOURCE_ID => G_SOURCE_ID
                                          , P_SCHED_ID => P_SCHED_ID
                                          , P_SERVER_ID => P_SERVER_ID
                                          , X_SUCCESS_FLAG => l_return_code);

       ---------------------------------------------------------
       -- At this point try to determine why we could
       -- not get any more entries:
       -- (1) Have all of the customers been serviced?
       -- (2) Calendar issue.
       -- (3) All are checked out.
       ---------------------------------------------------------
       GET_UNAVAILABLE_REASON
         (P_LIST_ID                     => P_TARGET_GROUP_ID
         ,X_CALLBACK_AVAILABLE_COUNT    => L_CALLBACK_AVAILABLE_COUNT
         ,X_AVAILABLE_COUNT             => L_AVAILABLE_COUNT
         ,X_CALLBACK_CHECKED_OUT_COUNT  => L_CALLBACK_CHECKED_OUT_COUNT
         ,X_CHECKED_OUT_COUNT           => L_CHECKED_OUT_COUNT
         ,X_CALENDAR_COUNT              => L_CALENDAR_COUNT
         ,X_CALLBACK_CALENDAR_COUNT     => L_CALLBACK_CALENDAR_COUNT
         ,X_INACTIVE_COUNT              => L_INACTIVE_COUNT
         ,X_CALLBACK_RESTRICT_COUNT     => L_CALLBACK_RESTRICT_COUNT);

       ---------------------------------------------------------
       -- This means that there are no records currently available
       -- so we will try to give a detailed reason why.
       ---------------------------------------------------------
       IF (L_AVAILABLE_COUNT = 0 AND L_CALLBACK_AVAILABLE_COUNT = 0)
       THEN

          ---------------------------------------------------------
          -- Unless we can find any other reason, the schedule
          -- is thought to be exhausted.
          ---------------------------------------------------------
          X_RETURN_CODE := SCHEDULE_IS_EMPTY;

          ---------------------------------------------------------
          -- Check to see if there are entries already checked out.
          ---------------------------------------------------------
          IF (L_CALLBACK_CHECKED_OUT_COUNT > 0 OR L_CHECKED_OUT_COUNT > 0)
          THEN
             X_RETURN_CODE := SCHEDULE_ALL_CHECKED_OUT;
          END IF;

          ---------------------------------------------------------
          -- Check to see if there are calendar restrictions.
          ---------------------------------------------------------
          IF (L_CALLBACK_CALENDAR_COUNT > 0 OR L_CALENDAR_COUNT > 0)
          THEN

             IF (X_RETURN_CODE = SCHEDULE_ALL_CHECKED_OUT)
             THEN
                X_RETURN_CODE := SCHEDULE_CALENDAR_OUT;
             ELSE
                X_RETURN_CODE := SCHEDULE_CALENDAR_RESTRICTION;
             END IF;
          END IF;

          ---------------------------------------------------------
          -- Check to see if there are callback restrictions.
          ---------------------------------------------------------
          IF (L_CALLBACK_RESTRICT_COUNT > 0 )
          THEN

             IF (X_RETURN_CODE = SCHEDULE_ALL_CHECKED_OUT)
             THEN
                X_RETURN_CODE := SCHEDULE_CALLBACK_OUT;
             ELSIF  (X_RETURN_CODE = SCHEDULE_CALENDAR_RESTRICTION)
             THEN
                X_RETURN_CODE := SCHEDULE_CALENDAR_CALLBACK;
             ELSIF  (X_RETURN_CODE = SCHEDULE_CALENDAR_OUT)
             THEN
                X_RETURN_CODE := SCHEDULE_CALENDAR_CALLBACK_OUT;
             ELSE
                X_RETURN_CODE := SCHEDULE_CALLBACK_EXPIRATION;
             END IF;
          END IF;

       END IF;

       RETURN;
    end if;

    -- UNLOCK THE CAMPAIGN
    IEC_COMMON_UTIL_PVT.UNLOCK_SCHEDULE( P_SOURCE_ID => G_SOURCE_ID
                                       , P_SCHED_ID => P_SCHED_ID
                                       , P_SERVER_ID => P_SERVER_ID
                                       , X_SUCCESS_FLAG => l_return_code);

    X_CACHE_RECORDS := l_returns_id_tab;

    return;
EXCEPTION
   WHEN OTHERS THEN

    L_ERROR_CODE := SQLCODE;
    Log( 'GET_RECORDS'
       , 'UNKNOWN'
       , 'Retrieving records for campaign ' || p_campaign_id
       , SQLCODE
       , SQLERRM);


    raise_application_error
      ( -20000
       , 'SQLCODE: <' || L_ERROR_CODE || '> SQLMESSAGE <' || SQLERRM || '>'
       ,TRUE
      );

   RAISE;

END GET_RECORDS;

END IEC_CPN_RLSE_STTGY_PVT;

/
