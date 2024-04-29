--------------------------------------------------------
--  DDL for Package Body IEC_SUBSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_SUBSET_PVT" AS
/* $Header: IECOCSBB.pls 115.27 2004/09/03 16:47:23 alromero noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_SUBSET_PVT';

TYPE TerritoryList IS TABLE OF VARCHAR2(2) INDEX BY BINARY_INTEGER;
TYPE UniqueIdList IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

G_NUM_MINUTES_IN_DAY CONSTANT NUMBER := 1440;
G_SYSTEM_OUTCOME_CODE CONSTANT NUMBER := 37;
G_LOST_RESULT_CODE CONSTANT NUMBER := 11;
G_RELEASE_STRATEGY_DEFAULT CONSTANT VARCHAR2(30) := 'QUA';
G_QUANTUM_DEFAULT CONSTANT NUMBER := 100;
G_QUOTA_DEFAULT CONSTANT NUMBER := 100;
G_QUOTA_RESET_DEFAULT CONSTANT NUMBER := 60;
G_MIN_CACHE_ENTRIES CONSTANT NUMBER := 1000;
G_MAX_INIT_CACHE_ENTRIES CONSTANT NUMBER := 30000;
G_QUERY_CALLBACK_NUM CONSTANT NUMBER := 1000;
g_error_msg VARCHAR2(2048) := NULL;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : LOG
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_ACTIVITY_DESC  IN     NUMBER            Required
--                P_METHOD_NAME    IN     NUMBER            Required
--                P_SQL_CODE       IN     NUMBER            Required
--                P_SQL_ERRM       IN     VARCHAR2          Required
--                P_SOURCE_ID      IN     NUMBER            Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Log ( p_method_name   IN VARCHAR2
              , p_sub_method    IN VARCHAR2
              , p_sql_errm      IN VARCHAR2)
IS
   l_error_msg VARCHAR2(2048);
BEGIN

   IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
                      ( 'IEC_SUBSET_PVT'
                      , p_method_name
                      , p_sub_method
                      , p_sql_errm
                      , g_error_msg
                      );

END Log;

-- Logs a translatable message that has already been initialized
PROCEDURE Log
   ( p_method_name   IN VARCHAR2
   , p_sub_method    IN VARCHAR2)
IS
   l_module VARCHAR2(4000);
BEGIN

   IEC_OCS_LOG_PVT.Get_Module('IEC_SUBSET_PVT', p_method_name, p_sub_method, l_module);
   g_error_msg := l_module || ':' || g_error_msg;
   IEC_OCS_LOG_PVT.Log_Message(l_module);

END Log;

PROCEDURE Log_SubsetViewInvalid
   ( p_method_name   IN VARCHAR2
   , p_sub_method    IN VARCHAR2
   , p_subset_name   IN VARCHAR2
   , p_list_name     IN VARCHAR2)
IS
   l_module VARCHAR2(4000);
   l_encoded_message VARCHAR2(4000);
BEGIN

   IEC_OCS_LOG_PVT.Init_SubsetViewInvalidMsg(p_subset_name, p_list_name, g_error_msg, l_encoded_message);
   IEC_OCS_LOG_PVT.Get_Module('IEC_SUBSET_PVT', p_method_name, p_sub_method, l_module);
   g_error_msg := l_module || ':' || g_error_msg;
   IEC_OCS_LOG_PVT.Log_Message(l_module);

END Log_SubsetViewInvalid;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : TRACELOG
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_TEXT     IN     NUMBER                Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE TRACELOG
   (P_TEXT IN VARCHAR2)
IS
BEGIN
--   DBMS_OUTPUT.PUT_LINE(P_TEXT);
   NULL;
END TRACELOG;

FUNCTION Get_AppsSchemaName
RETURN VARCHAR2
IS
   l_schema_name VARCHAR2(30);
BEGIN

   SELECT ORACLE_USERNAME
   INTO l_schema_name
   FROM FND_ORACLE_USERID
   WHERE READ_ONLY_FLAG = 'U';

   RETURN l_schema_name;

EXCEPTION
   WHEN OTHERS THEN
      Log( 'Get_AppsSchemaName'
         , 'MAIN'
         , SQLERRM);
      RAISE fnd_api.g_exc_unexpected_error;

END Get_AppsSchemaName;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : LOCK_SCHEDULE
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Attempt to lock or unlock the schedule.
--
--  Parameters  : P_SOURCE_ID    IN     NUMBER            Required
--                P_SCHED_ID     IN     NUMBER            Required
--                P_SERVER_ID    IN     NUMBER            Required
--                P_LOCK_FLAG    IN     VARCHAR2          Required
--                X_SUCCESS_FLAG    OUT VARCHAR2          Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE LOCK_SCHEDULE
   ( P_SOURCE_ID    IN            NUMBER
   , P_SCHED_ID     IN            NUMBER
   , P_SERVER_ID    IN            NUMBER
   , P_LOCK_FLAG    IN            VARCHAR2
   , X_SUCCESS_FLAG    OUT NOCOPY VARCHAR2
   )
IS
BEGIN

   IEC_COMMON_UTIL_PVT.LOCK_SCHEDULE
      ( P_SOURCE_ID
      , P_SCHED_ID
      , P_SERVER_ID
      , P_LOCK_FLAG
      , X_SUCCESS_FLAG
      );

EXCEPTION
   WHEN OTHERS THEN
      -- FND_MESSAGE is initialized but not logged in IEC_COMMON_UTIL_PVT
      -- if an exception is thrown, so we log it here with current
      -- module
      Log( 'LOCK_SCHEDULE'
         , 'MAIN.SCHEDULE_' || P_SCHED_ID
         );
      RAISE fnd_api.g_exc_unexpected_error;

END LOCK_SCHEDULE;

FUNCTION Get_ListName
   (p_list_id IN NUMBER)
RETURN VARCHAR2
IS
   l_name VARCHAR2(240);
BEGIN

   IEC_COMMON_UTIL_PVT.Get_ListName(p_list_id, l_name);

   RETURN l_name;
EXCEPTION
   WHEN OTHERS THEN
      -- FND_MESSAGE is initialized but not logged in IEC_COMMON_UTIL_PVT
      -- if an exception is thrown, so we log it here with current
      -- module
      Log('Get_ListName', 'MAIN.LIST_' || p_list_id);
      RAISE fnd_api.g_exc_unexpected_error;
END Get_ListName;

FUNCTION Get_SubsetName
   (p_subset_id IN NUMBER)
RETURN VARCHAR2
IS
   l_name VARCHAR2(240);
BEGIN

   IEC_COMMON_UTIL_PVT.Get_SubsetName(p_subset_id, l_name);

   RETURN l_name;
EXCEPTION
   WHEN OTHERS THEN
      -- FND_MESSAGE is initialized but not logged in IEC_COMMON_UTIL_PVT
      -- if an exception is thrown, so we log it here with current
      -- module
      Log('Get_ListName', 'MAIN.SUBSET_' || p_subset_id);
      RAISE fnd_api.g_exc_unexpected_error;
END Get_SubsetName;


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : GET_SOURCETYPE_VIEW_NAME
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Retrieve the target group's source type view name.
--
--  Parameters  : P_SOURCE_ID          IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     VARCHAR2                     Required
--                X_VIEW_NAME          IN OUT DBMS_SQL.VARCHAR2S           Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE GET_SOURCETYPE_VIEW_NAME
   ( P_SOURCE_ID          IN            NUMBER
   , P_TARGET_GROUP_ID    IN            VARCHAR2
   , X_VIEW_NAME             OUT NOCOPY VARCHAR2
   )
IS
BEGIN

   IEC_COMMON_UTIL_PVT.Get_SourceTypeView(p_target_group_id, x_view_name);

EXCEPTION
   WHEN OTHERS THEN
      -- FND_MESSAGE is initialized but not logged in Get_SourceTypeView
      -- if an exception is thrown, so we log it here with current
      -- module
      Log( 'GET_SOURCETYPE_VIEW_NAME'
         , 'MAIN.LIST_' || p_target_group_id
         );
      RAISE fnd_api.g_exc_unexpected_error;

END GET_SOURCETYPE_VIEW_NAME;

PROCEDURE UPDATE_SUBSET_COUNTS
   ( p_campaign_id IN NUMBER
   , p_schedule_id IN NUMBER
   , p_list_id     IN NUMBER
   , p_subset_id   IN NUMBER
   , p_rec_loaded  IN NUMBER
   , p_rec_called  IN NUMBER)
IS
   l_rec_count NUMBER;
BEGIN

   -- Check for existence of record for the current subset
   EXECUTE IMMEDIATE
      'SELECT COUNT(*)
       FROM IEC_G_REP_SUBSET_COUNTS
       WHERE SUBSET_ID = :subset_id'
   INTO l_rec_count
   USING p_subset_id;

   -- If record does not exist, create record and initialize counts
   IF l_rec_count = 0 THEN

      EXECUTE IMMEDIATE
         'INSERT INTO IEC_G_REP_SUBSET_COUNTS
          ( SUBSET_COUNT_ID
          , CAMPAIGN_ID
          , SCHEDULE_ID
          , LIST_HEADER_ID
          , SUBSET_ID
          , RECORD_LOADED
          , RECORD_CALLED_ONCE
          , RECORD_CALLED_AND_REMOVED
          , RECORD_CALLED_AND_REMOVED_COPY
          , LAST_COPY_TIME
          , CREATED_BY
          , CREATION_DATE
          , LAST_UPDATE_LOGIN
          , LAST_UPDATE_DATE
          , LAST_UPDATED_BY
          , OBJECT_VERSION_NUMBER
          )
          VALUES
          (IEC_G_REP_SUBSET_COUNTS_S.NEXTVAL
          , :campaign_id
          , :schedule_id
          , :list_id
          , :subset_id
          , :records_loaded
          , :records_called
          , 0
          , 0
          , SYSDATE
          , 1
          , SYSDATE
          , 1
          , SYSDATE
          , 0
          , 0)'
      USING p_campaign_id
          , p_schedule_id
          , p_list_id
          , p_subset_id
          , p_rec_loaded
          , p_rec_called;

   ELSE
      -- If record exists, simply update counts by appropriate increment
      EXECUTE IMMEDIATE
         'UPDATE IEC_G_REP_SUBSET_COUNTS
          SET RECORD_LOADED = NVL(RECORD_LOADED, 0) + :records_loaded
            , RECORD_CALLED_ONCE = NVL(RECORD_CALLED_ONCE, 0) + :records_called
            , LAST_UPDATE_DATE = SYSDATE
          WHERE SUBSET_ID = :subset_id'
      USING p_rec_loaded
          , p_rec_called
          , p_subset_id;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      Log( 'UPDATE_SUBSET_COUNTS'
         , 'MAIN.SUBSET_' || p_subset_id
         , SQLERRM
         );
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
END UPDATE_SUBSET_COUNTS;

-----------------------------++++++-------------------------------
-- Start of comments
--
--  API name    : CREATE_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Creates a view for the specified subset using
--                the view name provided.
--
--  Parameters  : P_SOURCE_ID                IN     NUMBER                       Required
--                P_SUBSET_ID                IN     NUMBER                       Required
--                P_VIEW_NAME                IN     VARCHAR2                     Required
--                P_TARGET_GROUP_ID          IN     NUMBER                       Required
--                P_SOURCE_TYPE_VIEW_NAME    IN     VARCHAR2                     Required
--                P_DEFAULT_SUBSET_FLAG      IN     VARCHAR2                     Required
--                X_RETURN_CODE                 OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE CREATE_SUBSET_VIEW
   ( P_SOURCE_ID             IN            NUMBER
   , P_SUBSET_ID             IN            NUMBER
   , P_VIEW_NAME             IN            VARCHAR2
   , P_TARGET_GROUP_ID       IN            NUMBER
   , P_SOURCE_TYPE_VIEW_NAME IN            VARCHAR2
   , P_DEFAULT_SUBSET_FLAG   IN            VARCHAR2
   , X_RETURN_CODE              OUT NOCOPY VARCHAR2
   )
IS

   ----------------------------------------------------------------
   -- A table of VARCHAR2(256) that is used to build the subset
   -- query.
   ----------------------------------------------------------------
   l_create_statement DBMS_SQL.VARCHAR2S;

   ----------------------------------------------------------------
   -- The identifier for the DBMS_SQL cursor that we are going to
   -- use.
   ----------------------------------------------------------------
    l_work_cursor NUMBER;

   ----------------------------------------------------------------
   -- Dummy number variable used in the execute function.
   ----------------------------------------------------------------
   l_dummy NUMBER;

   ----------------------------------------------------------------
   -- The first part of the subset query SQL that is unique to
   -- each list by source view id and list id:
   ----------------------------------------------------------------
   l_create_start_str  CONSTANT VARCHAR2(16) := 'CREATE VIEW ';

   ----------------------------------------------------------------
   -- The first part of the subset query SQL that is unique to
   -- each list by source view id and list id:
   ----------------------------------------------------------------
   l_create_as_str  CONSTANT VARCHAR2(100) := ' AS SELECT LIST_ENTRY_ID FROM ';

   ----------------------------------------------------------------
   -- The first part of the subset query SQL that is unique to
   -- each list by source view id and list id:
   ----------------------------------------------------------------
   l_create_where_str  CONSTANT VARCHAR2(32) := ' WHERE LIST_HEADER_ID = ';

   ----------------------------------------------------------------
   -- Local Status code.
   ----------------------------------------------------------------
   l_status_code VARCHAR2(1);

BEGIN
   TRACELOG( 'STARTING CREATE SUBSET VIEW');
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

   ----------------------------------------------------------------
   -- If this is a default subset, then we need to call the get
   -- default subset criteria procedure.
   ----------------------------------------------------------------
   IF NVL(P_DEFAULT_SUBSET_FLAG, 'N') = 'N'
   THEN

      l_create_statement(1) := l_create_start_str
                            || P_VIEW_NAME
                            || l_create_as_str
                            || P_SOURCE_TYPE_VIEW_NAME
                            || l_create_where_str
                            || P_TARGET_GROUP_ID
                            || ' AND ';

      ----------------------------------------------------------------
      -- Append the subset criteria clause.
      ----------------------------------------------------------------
      IEC_CRITERIA_UTIL_PVT.Append_SubsetCriteriaClause( p_source_id
                                                       , p_subset_id
                                                       , p_source_type_view_name
                                                       , l_create_statement
                                                       , l_status_code);

      TRACELOG('Number of subset lines ' || l_Create_statement.COUNT);

      FOR T IN l_create_statement.FIRST..l_create_statement.LAST
      LOOP
         TRACELOG(l_create_statement(T));
      END LOOP;

      l_work_cursor := DBMS_SQL.OPEN_CURSOR;

      DBMS_SQL.PARSE( c             => l_work_cursor
                    , statement     => l_create_statement
                    , lb            => 1
                    , ub            => l_create_statement.COUNT
                    , lfflg         => FALSE
                    , language_flag => DBMS_SQL.NATIVE);


      l_dummy := DBMS_SQL.EXECUTE(l_work_cursor);

      DBMS_SQL.CLOSE_CURSOR(l_work_cursor);

   ----------------------------------------------------------------
   -- If this is a default subset, then we don't create a view.
   ----------------------------------------------------------------
   ELSE
      NULL;
   END IF; -- end of the if default subset conditional.
   TRACELOG('STOP CREATE SUBSET VIEW');

EXCEPTION
   -- Fixme add logic to handle if entry does not exist.
   -- This should no happen.
   WHEN FND_API.G_EXC_ERROR  THEN
      IF DBMS_SQL.IS_OPEN(l_work_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(l_work_cursor);
      END IF;
      X_RETURN_CODE := 'E';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF DBMS_SQL.IS_OPEN(l_work_cursor) THEN
         DBMS_SQL.CLOSE_CURSOR(l_work_cursor);
      END IF;
      X_RETURN_CODE := 'U';
    WHEN OTHERS THEN
      TRACELOG('SQLERRM: ' || SQLERRM);
      IF DBMS_SQL.IS_OPEN(l_work_cursor)
      THEN
         DBMS_SQL.CLOSE_CURSOR(l_work_cursor);
      END IF;
      X_RETURN_CODE := 'U';

END CREATE_SUBSET_VIEW;

-----------------------------++++++-------------------------------
-- Start of comments
--
--  API name    : DROP_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Drops the view defined for the specified subset.
--
--  Parameters  : P_SOURCE_ID                IN     NUMBER                       Required
--                P_SUBSET_ID                IN     NUMBER                       Required
--                X_RETURN_CODE                 OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE DROP_SUBSET_VIEW
   ( P_SOURCE_ID             IN             NUMBER
   , P_SUBSET_ID             IN             NUMBER
   , X_RETURN_CODE              OUT NOCOPY VARCHAR2
   )
IS

  ----------------------------------------------------------------
  -- Local Status code.
  ----------------------------------------------------------------
  l_status_code VARCHAR2(1);
  l_view_name VARCHAR2(30);
  l_view_owner VARCHAR2(30);
  l_ignore NUMBER;

BEGIN
   TRACELOG('STARTING DROP SUBSET VIEW');
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

   /*
       DROP VIEW IEC_SUBSET_<id>_V
   */

   l_view_name := 'IEC_SUBSET_' || P_SUBSET_ID || '_V';
   l_view_owner := Get_AppsSchemaName;

   BEGIN
      SELECT 1
      INTO   l_ignore
      FROM   ALL_VIEWS
      WHERE  VIEW_NAME = UPPER(l_view_name)
      AND    OWNER = UPPER(l_view_owner);

      EXECUTE IMMEDIATE 'DROP VIEW ' || l_view_name;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN OTHERS THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   TRACELOG('STOP DROP SUBSET VIEW');

EXCEPTION
    -- Fixme add logic to handle if entry does not exist.
    -- This should no happen.
    WHEN FND_API.G_EXC_ERROR  THEN
      X_RETURN_CODE := 'E';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_RETURN_CODE := 'U';
    WHEN OTHERS THEN
      TRACELOG('SQLERRM: ' || SQLERRM);
      X_RETURN_CODE := 'U';
END DROP_SUBSET_VIEW;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : DROP_TARGET_GROUP_VIEWS
--  Type        : Private
--  Pre-reqs    : None
--  Function    : For each subset in the specified target group,
--                drop the subset view.
--
--  Parameters  : P_SOURCE_ID            IN     NUMBER                       Required
--                P_TARGET_GROUP_ID      IN     NUMBER                       Required
--                X_RETURN_CODE             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE DROP_TARGET_GROUP_VIEWS
   ( P_SOURCE_ID             IN            NUMBER
   , P_TARGET_GROUP_ID       IN            NUMBER
   , X_RETURN_CODE              OUT NOCOPY VARCHAR2
   )
IS

  ----------------------------------------------------------------
  -- Local Status code.
  ----------------------------------------------------------------
  l_status_code VARCHAR2(1);

BEGIN
   TRACELOG('STARTING DROP TARGET GROUP VIEWS');
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

    FOR subset_rec IN (SELECT LIST_SUBSET_ID
                      FROM    IEC_G_LIST_SUBSETS
                      WHERE   LIST_HEADER_ID = P_TARGET_GROUP_ID
                      AND     NVL(DEFAULT_SUBSET_FLAG, 'N') = 'N')
    LOOP
       DROP_SUBSET_VIEW( P_SOURCE_ID
                       , subset_rec.LIST_SUBSET_ID
                       , l_status_code);
    END LOOP;

   TRACELOG('STOP CREATE TARGET GROUP VIEWS');

EXCEPTION
    -- Fixme add logic to handle if entry does not exist.
    -- This should no happen.
    WHEN FND_API.G_EXC_ERROR  THEN
      X_RETURN_CODE := 'E';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_RETURN_CODE := 'U';
    WHEN OTHERS THEN
      TRACELOG('SQLERRM: ' || SQLERRM);
      X_RETURN_CODE := 'U';

END DROP_TARGET_GROUP_VIEWS;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : VERIFY_SUBSET_VIEW
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID       IN     NUMBER         Required
--                P_SUBSET_ID       IN     NUMBER         Required
--                X_VIEW_NAME          OUT VARCHAR2       Required
--                X_VIEW_EXISTS        OUT VARCHAR2       Required
--                X_RETURN_CODE        OUT VARCHAR2       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE VERIFY_SUBSET_VIEW
   ( P_SOURCE_ID          IN            NUMBER
   , P_SUBSET_ID          IN            NUMBER
   , P_TARGET_GROUP_ID    IN            NUMBER
   , X_VIEW_NAME             OUT NOCOPY VARCHAR2
   , X_VIEW_EXISTS           OUT NOCOPY VARCHAR2
   , X_RETURN_CODE           OUT NOCOPY VARCHAR2
   )
IS

   L_STATUS VARCHAR2(10);
   L_VIEW_NAME VARCHAR2(30);
   l_view_owner VARCHAR2(30);
   L_RETURN_CODE VARCHAR2(1);

BEGIN
   TRACELOG('STARTING VERIFY SUBSET VIEW');
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;
   X_VIEW_NAME := NULL;
   X_VIEW_EXISTS := 'N';

   L_VIEW_NAME := 'IEC_SUBSET_' || P_SUBSET_ID || '_V';
   l_view_owner := Get_AppsSchemaName;

   BEGIN

     EXECUTE IMMEDIATE ' SELECT STATUS ' ||
                       ' FROM ALL_OBJECTS ' ||
                       ' WHERE OWNER = :owner ' ||
                       ' AND OBJECT_NAME = :b1 ' ||
                       ' AND OBJECT_TYPE = ''VIEW'' '
     INTO L_STATUS
     USING l_view_owner
         , L_VIEW_NAME;


     IF (L_STATUS <> 'VALID')
     THEN

       BEGIN
          EXECUTE IMMEDIATE 'ALTER VIEW ' || L_VIEW_NAME || ' COMPILE';
          X_VIEW_EXISTS := 'Y';
       EXCEPTION
         WHEN OTHERS THEN
           TRACELOG('VIEW <' || L_VIEW_NAME || '> IS INVALID');
           Log_SubsetViewInvalid
              ( 'VERIFY_SUBSET_VIEW'
    	      , 'RECOMPILE_SUBSET_VIW'
    	      , Get_SubsetName(p_subset_id)
    	      , Get_ListName(p_target_group_id)
	          );
         RAISE FND_API.G_EXC_ERROR;
       END;

     ELSE
       X_VIEW_EXISTS := 'Y';
     END IF;

     X_VIEW_NAME := L_VIEW_NAME;

   EXCEPTION
    WHEN NO_DATA_FOUND THEN
       X_VIEW_EXISTS := 'N';
       X_VIEW_NAME := L_VIEW_NAME;
    WHEN OTHERS THEN
       RAISE;
   END;

   TRACELOG('END VERIFY SUBSET VIEW ' || X_VIEW_EXISTS);
   TRACELOG('END VERIFY SUBSET VIEWNAME ' || X_VIEW_NAME);

EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
       X_RETURN_CODE := 'E';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       X_RETURN_CODE := 'U';
    WHEN OTHERS THEN
       TRACELOG('SQLERRM: ' || SQLERRM);
       LOG( 'VERIFY_SUBSET_VIEW'
    	  , 'MAIN.SUBSET_' || p_subset_id
	      , SQLERRM
	      );
       X_RETURN_CODE := 'U';

END VERIFY_SUBSET_VIEW;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : CREATE_SUBSET_RT_INFO
--  Type        : Public
--  Pre-reqs    : None
--  Function    : If the subset runtime information entries do not
--                already exist, create them.
--
--  Parameters  : P_SUBSET_ID      IN     NUMBER                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE CREATE_SUBSET_RT_INFO
   ( P_SUBSET_ID            IN            NUMBER
   )
IS

  L_RELEASE_STRATEGY VARCHAR2(30);
  L_RETURN_CODE      VARCHAR2(1);
  L_STATUS_CODE      VARCHAR2(100);
  L_LOAD_PRIORITY    NUMBER;
  L_QUANTUM          NUMBER;
  L_QUOTA            NUMBER;
  L_QUOTA_RESET      NUMBER;
  L_LOGIN_USERID     NUMBER;
  L_USERID           NUMBER;

BEGIN
  L_LOGIN_USERID     := NVL(FND_GLOBAL.conc_login_id, -1);
  L_USERID           := NVL(FND_GLOBAL.user_id, -1);

  ----------------------------------------------------------------
  -- Create save point for this procedure.
  ----------------------------------------------------------------
  SAVEPOINT CREATE_SUBSET_RT_INFO_SAVE;

  ----------------------------------------------------------------
  -- Retrieve the default data values for the release strategy
  -- from the subset entry on the IEC_G_LIST_SUBSETS table.  If
  -- default values do not exists then we use defaults.  We could
  -- have retrieved this data in the populate cache procedure, but
  -- a subset is only going to retrieve these once, but could be
  -- used for a long time.  That was the reason behind taking the
  -- performance hit here.
  ----------------------------------------------------------------

  BEGIN
    SELECT NVL(RELEASE_STRATEGY, G_RELEASE_STRATEGY_DEFAULT)
    ,      NVL(QUANTUM, G_QUANTUM_DEFAULT)
    ,      NVL(QUOTA, G_QUOTA_DEFAULT)
    ,      NVL(QUOTA_RESET, G_QUOTA_RESET_DEFAULT)
    ,      STATUS_CODE
    ,      LOAD_PRIORITY
    INTO   L_RELEASE_STRATEGY
    ,      L_QUANTUM
    ,      L_QUOTA
    ,      L_QUOTA_RESET
    ,      L_STATUS_CODE
    ,      L_LOAD_PRIORITY
    FROM   IEC_G_LIST_SUBSETS
    WHERE  LIST_SUBSET_ID = P_SUBSET_ID;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ----------------------------------------------------------------
      -- This shouldn't happen, if it does log an error and stop
      -- processing for this subset. TODO
      ----------------------------------------------------------------
      RAISE;
    WHEN OTHERS THEN
      RAISE;
  END; -- end block to query for subset default values.

  ----------------------------------------------------------------
  -- If the release strategy is quantum then we need to set the
  -- value of the quota equal to the start value of the quantum.
  ----------------------------------------------------------------
  IF L_RELEASE_STRATEGY = 'QUA'
  THEN
    L_QUOTA := L_QUANTUM;
  END IF;

  ----------------------------------------------------------------
  -- We calculate the next time to reset the quota be taking the
  -- quota reset interval retrieved in the previous query,
  -- dividing it by the number of minutes in a day (1440), and
  -- adding this value to the current SYSDATE.
  ----------------------------------------------------------------
  L_QUOTA_RESET := L_QUOTA_RESET / G_NUM_MINUTES_IN_DAY;

  ----------------------------------------------------------------
  -- Create an entry in the IEC_G_SUBSET_RT_INFO table to support
  -- the new subset.
  ----------------------------------------------------------------
  BEGIN

    INSERT INTO IEC_G_SUBSET_RT_INFO
    (           SUBSET_RT_INFO_ID
    ,           LIST_SUBSET_ID
    ,           WORKING_QUANTUM
    ,           WORKING_QUOTA
    ,           QUOTA_RESET_TIME
    ,           CACHE_AMT_NEEDED
    ,           VALID_FLAG
    ,           USE_FLAG
    ,           CALLABLE_FLAG
    ,           TOTAL_CACHE_COUNT
    ,           STATUS_CODE
    ,           LOAD_PRIORITY
    ,           CREATED_BY
    ,           CREATION_DATE
    ,           LAST_UPDATED_BY
    ,           LAST_UPDATE_DATE
    )
    VALUES
    (           IEC_G_SUBSET_RT_INFO_S.NEXTVAL
    ,           P_SUBSET_ID
    ,           L_QUANTUM
    ,           L_QUOTA
    ,           SYSDATE + L_QUOTA_RESET
    ,           NULL
    ,           'Y'
    ,           'Y'
    ,           'Y'
    ,           0
    ,           L_STATUS_CODE
    ,           L_LOAD_PRIORITY
    ,           L_USERID
    ,           SYSDATE
    ,           L_LOGIN_USERID
    ,           SYSDATE
    );

  EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
	   EXECUTE IMMEDIATE
          ' UPDATE IEC_G_SUBSET_RT_INFO
		    SET  STATUS_CODE = :1
              ,  LOAD_PRIORITY = :2
		   	  ,  LAST_UPDATE_DATE = SYSDATE
			WHERE LIST_SUBSET_ID = :3'
       USING L_STATUS_CODE, L_LOAD_PRIORITY, P_SUBSET_ID;

    WHEN OTHERS THEN
      RAISE;
  END; -- end of block for inserting entry into IEC_G_SUBSET_RT_INFO table.

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO CREATE_SUBSET_RT_INFO_SAVE;
      Log( 'CREATE_SUBSET_RT_INFO'
         , 'MAIN.SUBSET_' || p_subset_id
         , SQLERRM
         );
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END CREATE_SUBSET_RT_INFO;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : GET_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Returns the subset view name after verifying that the view
--                exists, creating the view if necessary.
--
--  Parameters  : P_SOURCE_ID                IN     NUMBER                       Required
--                P_TARGET_GROUP_ID          IN     NUMBER                       Required
--                P_SUBSET_ID                IN     NUMBER                       Required
--                P_DEFAULT_SUBSET_FLAG      IN     VARCHAR2                     Required
--                P_SOURCE_TYPE_VIEW_NAME    IN     VARCHAR2                     Required
--                X_RETURN_CODE                 OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
FUNCTION GET_SUBSET_VIEW
   ( P_SOURCE_ID                IN            NUMBER
   , P_TARGET_GROUP_ID          IN            NUMBER
   , P_SUBSET_ID                IN            NUMBER
   , P_DEFAULT_SUBSET_FLAG      IN            VARCHAR2
   , P_SOURCE_TYPE_VIEW_NAME    IN            VARCHAR2
   , X_RETURN_CODE                 OUT NOCOPY VARCHAR2
   )
RETURN VARCHAR2
IS
   l_subset_view_name VARCHAR2(500);
   l_return_code      VARCHAR2(1);
   l_view_exists      VARCHAR2(1);
   l_default_subset_flag VARCHAR2(1);

BEGIN
   l_return_code      := FND_API.G_RET_STS_SUCCESS;
   l_view_exists      := 'N';
   l_default_subset_flag := 'N';

   TRACELOG('BEGIN GET SUBSET VIEW');
   ----------------------------------------------------------------
   -- Initialize the return code.
   ----------------------------------------------------------------
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

   ----------------------------------------------------------------
   -- Create save point for this procedure.
   ----------------------------------------------------------------
   SAVEPOINT GET_SUBSET_VIEW_SAVE;

   IF P_DEFAULT_SUBSET_FLAG = 'Y' OR P_DEFAULT_SUBSET_FLAG = 'N'
   THEN
      l_default_Subset_Flag := P_DEFAULT_SUBSET_FLAG;
   ELSE

      BEGIN
         SELECT NVL(DEFAULT_SUBSET_FLAG, 'N')
         INTO l_default_subset_Flag
         FROM   IEC_G_LIST_SUBSETS
         WHERE  LIST_HEADER_ID = P_TARGET_GROUP_ID
         AND    LIST_SUBSET_ID = P_SUBSET_ID;
      EXCEPTION
      WHEN OTHERS THEN
         RAISE;
      END;

   END IF;

   IF l_default_subset_flag <> 'Y' THEN

      l_subset_view_name := 'IEC_SUBSET_' || P_SUBSET_ID || '_V';

      TRACELOG('BEFORE VERIFY SUBSET VIEW ' || l_subset_view_name);
      VERIFY_SUBSET_VIEW ( P_SOURCE_ID => P_SOURCE_ID
                         , P_SUBSET_ID => P_SUBSET_ID
                         , P_TARGET_GROUP_ID => P_TARGET_GROUP_ID
                         , X_VIEW_NAME => l_subset_view_name
                         , X_VIEW_EXISTS => l_view_exists
                         , X_RETURN_CODE => l_return_code
                         );

      TRACELOG('AFTER VERIFY SUBSET VIEW ' || l_return_code || ' : ' || l_view_exists);

      IF (l_return_code = FND_API.G_RET_STS_SUCCESS AND l_view_exists = 'N') THEN

         CREATE_SUBSET_VIEW( P_SOURCE_ID => P_SOURCE_ID
                           , P_SUBSET_ID => P_SUBSET_ID
                           , P_VIEW_NAME => l_subset_view_name
                           , P_TARGET_GROUP_ID => P_TARGET_GROUP_ID
                           , P_SOURCE_TYPE_VIEW_NAME => P_SOURCE_TYPE_VIEW_NAME
                           , P_DEFAULT_SUBSET_FLAG => l_default_Subset_Flag
                           , X_RETURN_CODE => l_return_code
                           );

         IF (l_return_code <> FND_API.G_RET_STS_SUCCESS) THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      ELSIF (l_return_code <> FND_API.G_RET_STS_SUCCESS) THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   ELSE
      l_subset_view_name := 'DEFAULT';
   END IF;

   TRACELOG('END GET SUBSET VIEW ' || l_subset_view_name);
   RETURN l_subset_view_name;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO GET_SUBSET_VIEW_SAVE;
      X_RETURN_CODE := FND_API.G_RET_STS_UNEXP_ERROR;

END GET_SUBSET_VIEW;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : RECREATE_SUBSET_VIEW
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Recreates the subset view, deleting it first if necessary.
--
--  Parameters  : P_SOURCE_ID           IN            NUMBER   Required
--                P_TARGET_GROUP_ID     IN            NUMBER   Required
--                P_SUBSET_ID           IN            NUMBER   Required
--                X_SUBSET_VIEW_NAME       OUT NOCOPY VARCHAR2 Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE RECREATE_SUBSET_VIEW
   ( P_SOURCE_ID                IN            NUMBER
   , P_TARGET_GROUP_ID          IN            NUMBER
   , P_SUBSET_ID                IN            NUMBER
   , X_SUBSET_VIEW_NAME            OUT NOCOPY VARCHAR2
   )
IS
   l_subset_view_name VARCHAR2(500);
   l_source_type_view_name VARCHAR2(30);
   l_view_exists      VARCHAR2(1);
   l_return_code      VARCHAR2(1);

BEGIN
   l_view_exists      := 'N';
   ----------------------------------------------------------------
   -- Initialize the return code.
   ----------------------------------------------------------------
   l_return_code := FND_API.G_RET_STS_SUCCESS;

   X_SUBSET_VIEW_NAME := 'ERROR';

   ----------------------------------------------------------------
   -- Create save point for this procedure.
   ----------------------------------------------------------------
   SAVEPOINT RECREATE_SUBSET_VIEW_SAVE;

    ----------------------------------------------------------------
    -- This will retrieve the view name from an IEc lookup value
    -- that has been seeded in the database.  In the future there
    -- might be an algorithm used to BUILD the view name using values
    -- stored in the marketing schema.
    ----------------------------------------------------------------
    GET_SOURCETYPE_VIEW_NAME
      ( P_SOURCE_ID  => P_SOURCE_ID
      , P_TARGET_GROUP_ID  => P_TARGET_GROUP_ID
      , X_VIEW_NAME  => l_source_type_view_name);


   l_subset_view_name := 'IEC_SUBSET_' || P_SUBSET_ID || '_V';

   ----------------------------------------------------------------
   -- Check to see if the view already exists.
   ----------------------------------------------------------------
   VERIFY_SUBSET_VIEW ( P_SOURCE_ID => P_SOURCE_ID
                      , P_SUBSET_ID => P_SUBSET_ID
                      , P_TARGET_GROUP_ID => P_TARGET_GROUP_ID
                      , X_VIEW_NAME => l_subset_view_name
                      , X_VIEW_EXISTS => l_view_exists
                      , X_RETURN_CODE => l_return_code
                      );

   ----------------------------------------------------------------
   -- If the view already exists then drop the view.
   ----------------------------------------------------------------
   IF (l_return_code = FND_API.G_RET_STS_SUCCESS AND l_view_exists = 'Y')
   THEN
      DROP_SUBSET_VIEW( P_SOURCE_ID => P_SOURCE_ID
                      , P_SUBSET_ID => P_SUBSET_ID
                      , X_RETURN_CODE => l_return_code);

   ELSIF (l_return_code <> FND_API.G_RET_STS_SUCCESS)
   THEN
      Log( 'RECREATE_SUBSET_VIEW'
         , 'VERIFY_SUBSET_VIEW.SUBSET_' || p_subset_id
         , SQLERRM);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   ----------------------------------------------------------------
   -- If everything was successful up to this point then we
   -- create the subset view.
   ----------------------------------------------------------------
   IF (l_return_code = FND_API.G_RET_STS_SUCCESS)
   THEN
      CREATE_SUBSET_VIEW( P_SOURCE_ID => P_SOURCE_ID
                        , P_SUBSET_ID => P_SUBSET_ID
                        , P_VIEW_NAME => l_subset_view_name
                        , P_TARGET_GROUP_ID => P_TARGET_GROUP_ID
                        , P_SOURCE_TYPE_VIEW_NAME => l_source_type_view_name
                        , P_DEFAULT_SUBSET_FLAG => 'N'
                        , X_RETURN_CODE => l_return_code
                        );

      IF (l_return_code <> FND_API.G_RET_STS_SUCCESS) THEN
         Log( 'RECREATE_SUBSET_VIEW'
            , 'CREATE_SUBSET_VIEW.SUBSET_' || p_subset_id
            , SQLERRM);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      X_SUBSET_VIEW_NAME := l_subset_view_name;

   ELSE
      Log( 'RECREATE_SUBSET_VIEW'
         , 'DROP_SUBSET_VIEW.SUBSET_' || p_subset_id
         , SQLERRM);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
--      ROLLBACK TO RECREATE_SUBSET_VIEW_SAVE;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN OTHERS THEN
      Log( 'RECREATE_SUBSET_VIEW'
         , 'MAIN.SUBSET_' || p_subset_id
         , SQLERRM);
--      ROLLBACK TO RECREATE_SUBSET_VIEW_SAVE;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END RECREATE_SUBSET_VIEW;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : TRANSITION_NON_CHECKED_ENTRIES
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID                      IN     NUMBER                       Required
--                P_TARGET_GROUP_ID                IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE TRANSITION_NON_CHECKED_ENTRIES
   ( P_SOURCE_ID          IN     NUMBER
   , p_CAMPAIGN_ID        IN     NUMBER
   , P_SCHEDULE_ID        IN     NUMBER
   , P_TARGET_GROUP_ID    IN     NUMBER
   , P_STYPE_VIEW_NAME    IN     VARCHAR2
   , P_REINIT_FLAG        IN     VARCHAR2
   )
IS

  l_called_once_count NUMBER;

BEGIN

            ----------------------------------------------------------------
            -- Need to collect counts.  This is for the records that have
            -- NOT been checked out of AMS_LIST_ENTRIES.  Those records
            -- need to be treated differently to keep from causing
            -- deadlocks with the other processes.
            ----------------------------------------------------------------
            FOR count_rec IN (
               select   orig_subset_id
               ,        new_subset_id
               ,        do_not_use_flag
               ,        orig_itm_cc_tz_id
               ,        new_itm_cc_tz_id
               ,        call_Attempts
               ,        count(*) NUM_ENTRIES
               from     iec_o_transition_subsets
               where    (record_out_Flag = 'N' OR record_out_flag = 'R')
--               and      new_subset_id <> orig_subset_id
               and      list_id = P_TARGET_GROUP_ID
               group by orig_subset_id
               ,        new_Subset_id
               ,        do_not_use_flag
               ,        orig_itm_cc_tz_id
               ,        new_itm_cc_Tz_id
               ,        call_Attempts
               )
            LOOP

               ----------------------------------------------------------------
               -- Update the subset ids for the entries that have changed
               -- subsets and are not checked out in bulk.  These are only
               -- available for updates by prefetching or validation and these
               -- should not be allowed at the same time as the subset
               -- transitioning for this schedule.  I only updates these by time zones so I can
               -- update one record at a time from the IEC_G_REP_SUBSET_COUNTS and
               -- IEC_G_MKTG_ITEM_CC_TZS table to avoid deadlocks with validation
               -- calendar and recycling.
               ----------------------------------------------------------------
               TRACELOG('UPDATING RETURN_ENTRIES ');

               EXECUTE IMMEDIATE 'UPDATE IEC_G_RETURN_ENTRIES A ' ||
                                 'SET A.SUBSET_ID = :newSubset ' ||
                                 ', A.ITM_CC_TZ_ID = :newCallZone ' ||
                                 ', A.PULLED_SUBSET_ID = NULL ' ||
                                 'WHERE A.LIST_ENTRY_ID IN (SELECT C.LIST_ENTRY_ID ' ||
                                                           'FROM   IEC_O_TRANSITION_SUBSETS C ' ||
                                                           'WHERE  C.LIST_ID = :listID ' ||
                                                           'AND    C.NEW_SUBSET_ID = :newSubset ' ||
                                                           'AND    C.ORIG_SUBSET_ID = :origSubset ' ||
                                                           'AND    C.NEW_ITM_CC_TZ_ID = :newCall ' ||
                                                           'AND    C.ORIG_ITM_CC_TZ_ID = :origCall ' ||
                                                           'AND    C.CALL_ATTEMPTS = :callAttempts ' ||
                                                           'AND    C.DO_NOT_USE_FLAG = :do_not_use_Flag ' ||
                                                           'AND    (C.RECORD_OUT_FLAG = ''N'' OR C.RECORD_OUT_FLAG = ''R''))' ||
                                 'AND A.LIST_HEADER_ID = :listID'
                                 USING count_rec.new_subset_id
                                     , count_rec.new_itm_cc_tz_id
                                     , P_TARGET_GROUP_ID
                                     , count_rec.new_subset_id
                                     , count_rec.orig_subset_id
                                     , count_rec.new_itm_cc_tz_id
                                     , count_rec.orig_itm_cc_tz_id
                                     , count_rec.call_Attempts
                                     , count_rec.do_not_use_flag
                                     , P_TARGET_GROUP_ID;

               TRACELOG('UPDATED RETURN_ENTRIES ' || SQL%ROWCOUNT);
               ----------------------------------------------------------------
               -- Update the phone cross reference foreign keys for all of the
               -- entries that are moving subsets.  Once we move to the
               -- architecture away from ALE then this will no longer be needed.
               ----------------------------------------------------------------
               TRACELOG('UPDATING VIEW ');
               EXECUTE IMMEDIATE 'UPDATE ' || P_STYPE_VIEW_NAME || ' A ' ||
                                 ' SET A.REASON_CODE_S1 = ( SELECT /*+ index(B iec_o_transition_phones_u1) */ ITM_CC_TZ_ID ' ||
                                                          ' FROM IEC_O_TRANSITION_PHONES B' ||
                                                          ' WHERE B.PHONE_INDEX = 1 ' ||
                                                          ' AND B.LIST_ENTRY_ID = A.LIST_ENTRY_ID  ' ||
                                                          ' AND B.LIST_ID = A.LIST_HEADER_ID ) ' ||
                                 ' , A.REASON_CODE_S2 = ( SELECT /*+ index(C iec_o_transition_phones_u1) */ C.ITM_CC_TZ_ID ' ||
                                                          ' FROM IEC_O_TRANSITION_PHONES C' ||
                                                          ' WHERE C.PHONE_INDEX = 2 ' ||
                                                          ' AND C.LIST_ENTRY_ID = A.LIST_ENTRY_ID  ' ||
                                                          ' AND C.LIST_ID = A.LIST_HEADER_ID ) ' ||
                                 ' , A.REASON_CODE_S3 = ( SELECT /*+ index(D iec_o_transition_phones_u1) */ D.ITM_CC_TZ_ID ' ||
                                                          ' FROM IEC_O_TRANSITION_PHONES D' ||
                                                          ' WHERE D.PHONE_INDEX = 3 ' ||
                                                          ' AND D.LIST_ENTRY_ID = A.LIST_ENTRY_ID  ' ||
                                                          ' AND D.LIST_ID = A.LIST_HEADER_ID ) ' ||
                                 ' , A.REASON_CODE_S4 = ( SELECT /*+ index(E iec_o_transition_phones_u1) */ E.ITM_CC_TZ_ID ' ||
                                                          ' FROM IEC_O_TRANSITION_PHONES E' ||
                                                          ' WHERE E.PHONE_INDEX = 4 ' ||
                                                          ' AND E.LIST_ENTRY_ID = A.LIST_ENTRY_ID  ' ||
                                                          ' AND E.LIST_ID = A.LIST_HEADER_ID ) ' ||
                                 ' , A.REASON_CODE_S5 = ( SELECT /*+ index(F iec_o_transition_phones_u1) */ F.ITM_CC_TZ_ID ' ||
                                                          ' FROM IEC_O_TRANSITION_PHONES F' ||
                                                          ' WHERE F.PHONE_INDEX = 5 ' ||
                                                          ' AND F.LIST_ENTRY_ID = A.LIST_ENTRY_ID  ' ||
                                                          ' AND F.LIST_ID = A.LIST_HEADER_ID ) ' ||
                                 ' , A.REASON_CODE_S6 = ( SELECT /*+ index(G iec_o_transition_phones_u1) */ G.ITM_CC_TZ_ID ' ||
                                                          ' FROM IEC_O_TRANSITION_PHONES G' ||
                                                          ' WHERE G.PHONE_INDEX = 6 ' ||
                                                          ' AND G.LIST_ENTRY_ID = A.LIST_ENTRY_ID  ' ||
                                                          ' AND G.LIST_ID = A.LIST_HEADER_ID ) ' ||
                                 'WHERE A.LIST_ENTRY_ID IN (SELECT H.LIST_ENTRY_ID ' ||
                                                           'FROM   IEC_O_TRANSITION_SUBSETS H ' ||
                                                           'WHERE  H.LIST_ID = :listID ' ||
                                                           'AND    H.NEW_SUBSET_ID = :newSubset ' ||
                                                           'AND    H.ORIG_SUBSET_ID = :origSubset ' ||
                                                           'AND    H.NEW_ITM_CC_TZ_ID = :newCall ' ||
                                                           'AND    H.ORIG_ITM_CC_TZ_ID = :origCall ' ||
                                                           'AND    H.CALL_ATTEMPTS = :callAttempts ' ||
                                                           'AND    H.DO_NOT_USE_FLAG = :do_not_use_Flag ' ||
                                                           'AND    (H.RECORD_OUT_FLAG = ''N'' OR H.RECORD_OUT_FLAG = ''R''))' ||
                                 'AND A.LIST_HEADER_ID = :listID'
                                 USING P_TARGET_GROUP_ID
                                     , count_rec.new_subset_id
                                     , count_rec.orig_subset_id
                                     , count_rec.new_itm_cc_tz_id
                                     , count_rec.orig_itm_cc_tz_id
                                     , count_rec.call_Attempts
                                     , count_rec.do_not_use_flag
                                     , P_TARGET_GROUP_ID;

               TRACELOG('UPDATED VIEW ' || SQL%ROWCOUNT);

               TRACELOG('Before Modifying callzones ' || count_rec.new_itm_cc_tz_id ||
                                       ' : ' || count_rec.orig_itm_cc_tz_id || ' : ' || count_rec.do_not_use_flag);
               ----------------------------------------------------------------
               -- If this group represents a remaining group then we have to
               -- adjust the iec_g_mktg_item_cc_Tzs callZones counts.
               ----------------------------------------------------------------
               IF count_rec.do_not_use_flag = 'N' AND count_rec.new_itm_cc_tz_id  <> count_rec.orig_itm_cc_tz_id
               THEN

                  TRACELOG('Modifying callzones ' || count_rec.new_itm_cc_tz_id ||
                                       ' : ' || count_rec.orig_itm_cc_tz_id || ' : ' || count_rec.NUM_ENTRIES);
                  ----------------------------------------------------------------
                  -- Update the IEC_G_MKTG_ITEM_CC_TZS table.  May need to select
                  -- for update to dismiss the deadlock possibilities.
                  ----------------------------------------------------------------
                  EXECUTE IMMEDIATE 'UPDATE IEC_G_MKTG_ITEM_CC_TZS ' ||
                                    'SET    RECORD_COUNT = RECORD_COUNT + :remainingCount ' ||
                                    'WHERE  ITM_CC_TZ_ID = :callZone'
                                    USING count_rec.NUM_ENTRIES, count_rec.new_itm_cc_tz_id;

                  ----------------------------------------------------------------
                  -- Update the IEC_G_MKTG_ITEM_CC_TZS table.
                  ----------------------------------------------------------------
                  IF (P_REINIT_FLAG = 'N')
                  THEN
                     EXECUTE IMMEDIATE 'UPDATE IEC_G_MKTG_ITEM_CC_TZS ' ||
                                       'SET    RECORD_COUNT = RECORD_COUNT - :remainingCount ' ||
                                       'WHERE  ITM_CC_TZ_ID = :callZone'
                                       USING count_rec.NUM_ENTRIES, count_rec.orig_itm_cc_tz_id;
                  END IF;
               END IF;

               ----------------------------------------------------------------
               -- Has this group been called once or not.
               ----------------------------------------------------------------
               IF count_rec.call_Attempts = 0
               THEN
                  l_called_once_count := 0;
               ELSE
                  l_called_once_count := count_rec.NUM_ENTRIES;
               END IF;

               ----------------------------------------------------------------
               -- Update the IEC_G_REP_SUBSET_COUNTS table.
               -- May need to select for update to dismiss the deadlock possibilities.
               ----------------------------------------------------------------
               IF  count_rec.new_subset_id <>  count_rec.orig_subset_id
               THEN
                  UPDATE_SUBSET_COUNTS( P_CAMPAIGN_ID
                                      , P_SCHEDULE_ID
                                      , P_TARGET_GROUP_ID
                                      , count_rec.new_subset_id
                                      , count_rec.NUM_ENTRIES
                                      , l_called_once_count
                                      );

                  IF (P_REINIT_FLAG = 'N')
                  THEN
                     UPDATE_SUBSET_COUNTS( P_CAMPAIGN_ID
                                         , P_SCHEDULE_ID
                                         , P_TARGET_GROUP_ID
                                         , count_rec.orig_subset_id
                                         , (0 - count_rec.NUM_ENTRIES)
                                         , (0 - l_called_once_count)
                                         );
                  END IF;
               END IF;
               COMMIT;

            END LOOP;



EXCEPTION
   -- Fixme add logic to handle if entry does not exist.
    -- This should no happen.
    WHEN FND_API.G_EXC_ERROR  THEN
      ROLLBACK;
      RAISE;
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      RAISE;
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END TRANSITION_NON_CHECKED_ENTRIES;-- PL/SQL Block


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : GET_NEW_ZONE_XREF
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID                      IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     NUMBER
--                P_NEW_SUBSET_ID IN NUMBER
--                P_ORIG_XREF IN NUMBER
--                X_NEW_XREF  OUT NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE GET_NEW_ZONE_XREF( P_SOURCE_ID       IN            NUMBER
                           , P_SCHEDULE_ID     IN            NUMBER
                           , P_TARGET_GROUP_ID IN            NUMBER
                           , P_NEW_SUBSET_ID   IN            NUMBER
                           , P_ORIG_XREF       IN            NUMBER
                           , X_NEW_XREF           OUT NOCOPY NUMBER)
IS

BEGIN

  x_new_xref := NULL;

  ----------------------------------------------------------------
  -- If the original id is -1 then one was not assigned.
  ----------------------------------------------------------------
  IF (P_ORIG_XREF = -1)
  THEN
    X_NEW_XREF := -1;

  ----------------------------------------------------------------
  -- The original id isn't -1 then one was assigned.
  ----------------------------------------------------------------
  ELSE
    BEGIN

      EXECUTE IMMEDIATE 'SELECT ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS ' ||
                        ' WHERE LIST_HEADER_ID = :listId AND SUBSET_ID = :subsetID ' ||
                        ' AND (TERRITORY_CODE, TIMEZONE_ID, NVL(REGION_ID, -1)) = ' ||
                        ' (SELECT TERRITORY_CODE, TIMEZONE_ID, NVL(REGION_ID, -1) ' ||
                        ' FROM IEC_G_MKTG_ITEM_CC_TZS WHERE ITM_CC_TZ_ID = :xref_id)'
                        INTO X_NEW_XREF
                        USING P_TARGET_GROUP_ID, P_NEW_SUBSET_ID, P_ORIG_XREF;

    EXCEPTION
      ----------------------------------------------------------------
      -- If we cannot find a new zone then we need to create one.
      ----------------------------------------------------------------
      WHEN NO_DATA_FOUND THEN

        BEGIN
          ----------------------------------------------------------------
          -- Insert a new entry into the iec_g_mktg_item_cc_Tzs table for
          -- any new zone that is now in the
          ----------------------------------------------------------------
          EXECUTE IMMEDIATE 'INSERT INTO IEC_G_MKTG_ITEM_CC_TZS ' ||
                            ' (ITM_CC_TZ_ID, LIST_HEADER_ID, CAMPAIGN_SCHEDULE_ID, TERRITORY_CODE, ' ||
                            ' TIMEZONE_ID, LAST_CALLABLE_TIME, CALLABLE_FLAG, OBJECT_VERSION_NUMBER, ' ||
                            ' SECURITY_GROUP_ID, LAST_UPDATE_DATE, RECORD_COUNT, REGION_ID, SUBSET_ID) '||
                            ' select IEC_G_MKTG_ITEM_CC_TZS_S.NEXTVAL, :listID, :schedID ' ||
                            ', a.territory_code, a.timezone_id, NULL, ''N'', 0, -1 ' ||
                            ', SYSDATE, 0, a.region_id, :subsetId from ' ||
                            ' (SELECT region_id, territory_code,  timezone_id '||
                            ' from iec_g_mktg_item_cc_tzs c where c.itm_cc_Tz_id = :xref_id) a ' ||
                            ' RETURNING ITM_CC_TZ_ID '
                            INTO X_NEW_XREF
                            USING P_TARGET_GROUP_ID, P_SCHEDULE_ID, P_ORIG_XREF;
        EXCEPTION
          WHEN OTHERS THEN
            RAISE;
        END;   -- end insertingnew xref block.
      WHEN OTHERS THEN
        RAISE;
    END; -- end locating new xref block.
  END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN OTHERS THEN
      ROLLBACK;
      Log( 'GET_NEW_ZONE_XREF'
         , 'ASSIGN_NEW_CALLABLE_ZONES.LIST_' || p_target_group_id
         , SQLERRM);
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END GET_NEW_ZONE_XREF;


-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : CONTINUAL_TRANSITION
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID          IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     NUMBER                       Required
--                X_NUM_REMAINING         OUT NUMBER                       Required
--                X_ACTION_ID             OUT NUMBER                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE CONTINUAL_TRANSITION
   ( P_SOURCE_ID          IN            NUMBER
   , P_CAMPAIGN_ID        IN            NUMBER
   , P_SCHEDULE_ID        IN            NUMBER
   , P_TARGET_GROUP_ID    IN            NUMBER
   , X_NUM_REMAINING         OUT NOCOPY NUMBER
   , X_ACTION_ID             OUT NOCOPY NUMBER
   )
IS
  l_new_itm_xref_id1 NUMBER := 0;
  l_new_itm_xref_id2 NUMBER := 0;
  l_new_itm_xref_id3 NUMBER := 0;
  l_new_itm_xref_id4 NUMBER := 0;
  l_new_itm_xref_id5 NUMBER := 0;
  l_new_itm_xref_id6 NUMBER := 0;
  l_old_itm_xref_id1 NUMBER := 0;
  l_old_itm_xref_id2 NUMBER := 0;
  l_old_itm_xref_id3 NUMBER := 0;
  l_old_itm_xref_id4 NUMBER := 0;
  l_old_itm_xref_id5 NUMBER := 0;
  l_old_itm_xref_id6 NUMBER := 0;
  l_curr_itm_xref_id NUMBER := 0;
  l_curr_phone_index NUMBER := 0;

  ----------------------------------------------------------------
  -- The source type view name for the current list.
  ----------------------------------------------------------------
  l_src_type_view_name VARCHAR2(30);

BEGIN
  l_src_type_view_name := 'NULL';
  X_NUM_REMAINING := 0;
  x_action_id := NULL;

   ----------------------------------------------------------------
   -- Need to get the source type name.
   ----------------------------------------------------------------
   GET_SOURCETYPE_VIEW_NAME
     ( P_SOURCE_ID  => P_SOURCE_ID
     , P_TARGET_GROUP_ID  => P_TARGET_GROUP_ID
     , X_VIEW_NAME  => l_src_type_view_name
     );

   IF (l_src_type_view_name <> 'NULL')
   THEN
     ----------------------------------------------------------------
     -- Need to loop thru the entries we were unable to transition
     -- due to their state in the system and transition them
     -- if they have been checked back in.
     ----------------------------------------------------------------
     FOR entry_rec IN (
                 select   a.subset_id SUBSET_ID
                 ,        a.pulled_subset_id TRANSITION_SUBSET_ID
                 ,        a.list_entry_id  LIST_ENTRY_ID
                 ,        a.record_out_flag RECORD_OUT_FLAG
                 ,        a.itm_cc_Tz_id ITM_CC_TZ_ID
                 ,        a.contact_point_index CONTACT_POINT_INDEX
                 ,        a.returns_id RETURNS_ID
                 ,        a.do_not_use_flag DO_NOT_USE_FLAG
                 ,        DECODE(NVL(SUM(B.CALL_ATTEMPT), 0), 0, 0, 1) CALLED_ONCE
                 from     iec_g_return_entries a
                 ,        IEC_O_RCY_CALL_HISTORIES B
                 where    a.LIST_HEADER_ID = P_TARGET_GROUP_ID
                 and      a.pulled_subset_id IS NOT NULL
                 and      a.returns_id = b.returns_id(+)
								 group by a.subset_id
								 ,        a.pulled_subset_id
                 ,        a.list_entry_id
                 ,        a.record_out_flag
                 ,        a.itm_cc_Tz_id
                 ,        a.contact_point_index
                 ,        a.returns_id
                 ,        a.do_not_use_flag
                 )
     LOOP


       ----------------------------------------------------------------
       -- If the entry is still checked out then simply update the
       -- counter.
       ----------------------------------------------------------------
       IF (entry_rec.record_out_flag = 'Y')
       THEN
         X_NUM_REMAINING := X_NUM_REMAINING + 1;

       ----------------------------------------------------------------
       -- The record has been checked back in so execute the transition.
       ----------------------------------------------------------------
       ELSE

         ----------------------------------------------------------------
         -- We have to get the new itm_cc_Tz_ids for the entry.
         ----------------------------------------------------------------
         EXECUTE IMMEDIATE 'SELECT NVL(A.reason_code_S1, -1), NVL(A.reason_code_S2, -1), ' ||
                           ' NVL(A.reason_code_S3, -1), NVL(A.reason_code_S4, -1), ' ||
                           ' NVL(A.reason_code_S5, -1), NVL(A.reason_code_S6, -1) ' ||
                           ' FROM ' || l_src_type_view_name || ' a ' ||
                           ' WHERE A.LIST_HEADER_ID = :listID AND A.LIST_ENTRY_ID = :entryId'
                           INTO l_old_itm_xref_id1, l_old_itm_xref_id2, l_old_itm_xref_id3
                           ,    l_old_itm_xref_id4, l_old_itm_xref_id5, l_old_itm_xref_id6
                           USING P_TARGET_GROUP_ID, entry_rec.list_entry_id;

         ----------------------------------------------------------------
         -- Look at each phone cross ref to see if it has been assigned.
         -- And try to fetch the new one if it hasn't.
         ----------------------------------------------------------------
         GET_NEW_ZONE_XREF( P_SOURCE_ID
                          , P_SCHEDULE_ID
                          , P_TARGET_GROUP_ID
                          , entry_rec.TRANSITION_SUBSET_ID
                          , l_old_itm_xref_id1
                          , l_new_itm_xref_id1);

         GET_NEW_ZONE_XREF( P_SOURCE_ID
                          , P_SCHEDULE_ID
                          , P_TARGET_GROUP_ID
                          , entry_rec.TRANSITION_SUBSET_ID
                          , l_old_itm_xref_id2
                          , l_new_itm_xref_id2);

         GET_NEW_ZONE_XREF( P_SOURCE_ID
                          , P_SCHEDULE_ID
                          , P_TARGET_GROUP_ID
                          , entry_rec.TRANSITION_SUBSET_ID
                          , l_old_itm_xref_id3
                          , l_new_itm_xref_id3);

         GET_NEW_ZONE_XREF( P_SOURCE_ID
                          , P_SCHEDULE_ID
                          , P_TARGET_GROUP_ID
                          , entry_rec.TRANSITION_SUBSET_ID
                          , l_old_itm_xref_id4
                          , l_new_itm_xref_id4);

         GET_NEW_ZONE_XREF( P_SOURCE_ID
                          , P_SCHEDULE_ID
                          , P_TARGET_GROUP_ID
                          , entry_rec.TRANSITION_SUBSET_ID
                          , l_old_itm_xref_id5
                          , l_new_itm_xref_id5);

         GET_NEW_ZONE_XREF( P_SOURCE_ID
                          , P_SCHEDULE_ID
                          , P_TARGET_GROUP_ID
                          , entry_rec.TRANSITION_SUBSET_ID
                          , l_old_itm_xref_id6
                          , l_new_itm_xref_id6);

         ----------------------------------------------------------------
         -- Need to set the current xref id according to the index.
         ----------------------------------------------------------------
         IF (entry_rec.CONTACT_POINT_INDEX = 1)
         THEN
           l_curr_itm_xref_id := l_new_itm_xref_id1;

         ELSIF (entry_rec.CONTACT_POINT_INDEX = 2)
         THEN
           l_curr_itm_xref_id := l_new_itm_xref_id2;

         ELSIF (entry_rec.CONTACT_POINT_INDEX = 3)
         THEN
           l_curr_itm_xref_id := l_new_itm_xref_id3;

         ELSIF (entry_rec.CONTACT_POINT_INDEX = 4)
         THEN
           l_curr_itm_xref_id := l_new_itm_xref_id4;

         ELSIF (entry_rec.CONTACT_POINT_INDEX = 5)
         THEN
           l_curr_itm_xref_id := l_new_itm_xref_id5;

         ELSIF (entry_rec.CONTACT_POINT_INDEX = 6)
         THEN
           l_curr_itm_xref_id := l_new_itm_xref_id6;
         END IF;


         ----------------------------------------------------------------
         -- FIRST RESET THE SUBSET AND CURRENT CALL ZONE ON THE LIST.
         ----------------------------------------------------------------
         EXECUTE IMMEDIATE 'UPDATE IEC_G_RETURN_ENTRIES SET SUBSET_ID = :subsetId ' ||
                           ', PULLED_SUBSET_ID = NULL, ITM_CC_TZ_ID = :xrefId ' ||
                           ' WHERE RETURNS_ID = :returnsId'
                           USING entry_rec.TRANSITION_SUBSET_ID
                               , l_curr_itm_xref_id
                               , entry_rec.RETURNS_ID;

         IF (l_new_itm_xref_id1 = -1)
         THEN
            l_new_itm_xref_id1 := NULL;
         END IF;
         IF (l_new_itm_xref_id2 = -1)
         THEN
            l_new_itm_xref_id2 := NULL;
         END IF;
         IF (l_new_itm_xref_id3 = -1)
         THEN
            l_new_itm_xref_id3 := NULL;
         END IF;
         IF (l_new_itm_xref_id4 = -1)
         THEN
            l_new_itm_xref_id4 := NULL;
         END IF;
         IF (l_new_itm_xref_id5 = -1)
         THEN
            l_new_itm_xref_id5 := NULL;
         END IF;
         IF (l_new_itm_xref_id6 = -1)
         THEN
            l_new_itm_xref_id6 := NULL;
         END IF;

         ----------------------------------------------------------------
         -- RESET ALL OF THE CALL ZONES FOR THE ENTRY ON THE LIST.
         ----------------------------------------------------------------
         EXECUTE IMMEDIATE 'UPDATE ' || l_src_type_view_name || ' SET ' ||
                           ' REASON_CODE_S1 = :zoneXref1, ' ||
                           ' REASON_CODE_S2 = :zoneXref2, ' ||
                           ' REASON_CODE_S3 = :zoneXref3, ' ||
                           ' REASON_CODE_S4 = :zoneXref4, ' ||
                           ' REASON_CODE_S5 = :zoneXref5, ' ||
                           ' REASON_CODE_S6 = :zoneXref6 ' ||
                           ' WHERE LIST_HEADER_ID = :listID AND LIST_ENTRY_ID = :entryID '
                           USING l_new_itm_xref_id1
                           ,     l_new_itm_xref_id2
                           ,     l_new_itm_xref_id3
                           ,     l_new_itm_xref_id4
                           ,     l_new_itm_xref_id5
                           ,     l_new_itm_xref_id6
                           ,     P_TARGET_GROUP_ID, entry_rec.LIST_ENTRY_ID;

         ----------------------------------------------------------------
         -- Update the count of the callzones that the entry is
         -- transitioning between if the entry is still usable.
         ----------------------------------------------------------------
         IF (entry_rec.DO_NOT_USE_FLAG = 'N')
         THEN

           ----------------------------------------------------------------
           -- Increment the count for the new callzone by one.
           ----------------------------------------------------------------
           EXECUTE IMMEDIATE 'UPDATE IEC_G_MKTG_ITEM_CC_TZS ' ||
                              ' SET RECORD_COUNT = RECORD_COUNT + 1' ||
                              ', LAST_UPDATE_DATE = SYSDATE ' ||
                              ' WHERE ITM_CC_TZ_ID = :xrefId '
                              USING l_curr_itm_xref_id;

           ----------------------------------------------------------------
           -- Decrement the count for the orig callzone by one.
           ----------------------------------------------------------------
           EXECUTE IMMEDIATE 'UPDATE IEC_G_MKTG_ITEM_CC_TZS ' ||
                              ' SET RECORD_COUNT = RECORD_COUNT - 1' ||
                              ', LAST_UPDATE_DATE = SYSDATE ' ||
                              ' WHERE ITM_CC_TZ_ID = :xrefId '
                              USING entry_rec.ITM_CC_TZ_ID;

         END IF;

         ----------------------------------------------------------------
         -- Increment the count for the new subset by one.
         ----------------------------------------------------------------
         UPDATE_SUBSET_COUNTS( P_CAMPAIGN_ID
                             , P_SCHEDULE_ID
                             , P_TARGET_GROUP_ID
                             , entry_rec.TRANSITION_SUBSET_ID
                             , 1
                             , entry_rec.CALLED_ONCE
                             );

         ----------------------------------------------------------------
         -- Decrement the count for the original subset by one.
         ----------------------------------------------------------------
         UPDATE_SUBSET_COUNTS( P_CAMPAIGN_ID
                             , P_SCHEDULE_ID
                             , P_TARGET_GROUP_ID
                             , entry_rec.SUBSET_ID
                             , (0 - 1)
                             , (0 - entry_rec.CALLED_ONCE)
                             );
         COMMIT;
       END IF;

     END LOOP;

  ----------------------------------------------------------------
  -- We weren't able to process cause we couldn't find the
  -- source type view name.
  ----------------------------------------------------------------
  ELSE
    -- this won't really happen - procedure to get source type view
    -- will throw exception if source type view doesn't exist
    g_error_msg := 'Could not locate source type view name for list: ' || P_TARGET_GROUP_ID;

  END IF; -- end of if we could find the source type view name.

EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN OTHERS THEN
       Log( 'CONTINUAL_TRANSITION'
          , 'TRANSITION_SUBSETS.LIST_' || p_target_group_id
          , SQLERRM);
       ROLLBACK;
       RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END CONTINUAL_TRANSITION;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : GET_LIST_SCHEDULE_ID
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID          IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     NUMBER
--                X_SCHED_ID              OUT NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE GET_LIST_SCHEDULE_ID( P_SOURCE_ID       IN            NUMBER
                              , P_TARGET_GROUP_ID IN            NUMBER
                              , X_SCHEDULE_ID        OUT NOCOPY NUMBER
)
IS
BEGIN

   x_schedule_id := NULL;
   IEC_COMMON_UTIL_PVT.Get_ScheduleId(p_target_group_id, x_schedule_id);

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      -- FND_MESSAGE is initialized but not logged in IEC_COMMON_UTIL_PVT
      -- if an exception is thrown, so we log it here with current
      -- module
      Log( 'GET_LIST_SCHEDULE_ID', 'MAIN.LIST_' || p_target_group_id);
      RAISE fnd_api.g_exc_unexpected_error;

END GET_LIST_SCHEDULE_ID;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : GET_DEFAULT_SUBSET_ID
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID          IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     NUMBER
--                X_DEFAULT_SUBSET_ID              OUT NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE GET_DEFAULT_SUBSET_ID( P_SOURCE_ID         IN            NUMBER
                               , P_TARGET_GROUP_ID   IN            NUMBER
                               , X_DEFAULT_SUBSET_ID    OUT NOCOPY NUMBER
)
IS
BEGIN

   x_default_subset_id := NULL;

   EXECUTE IMMEDIATE 'SELECT LIST_SUBSET_ID FROM IEC_G_LIST_SUBSETS ' ||
                     'WHERE LIST_HEADER_ID = :listID AND DEFAULT_SUBSET_FLAG = ''Y'''
   INTO X_DEFAULT_SUBSET_ID
   USING P_TARGET_GROUP_ID;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK;
      x_default_subset_id := NULL;
      Log( 'GET_DEFAULT_SUBSET_ID'
         , 'MAIN.LIST_' || p_target_group_id
         , SQLERRM);
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END GET_DEFAULT_SUBSET_ID;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : TRANSITION_ENTRIES
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID          IN     NUMBER                       Required
--                P_SERVER_ID          IN     NUMBER                       Required
--                P_SCHED_ID           IN     NUMBER                       Required
--                P_TARGET_GROUP_ID    IN     NUMBER                       Required
--                P_FROM_SUBSET        IN     NUMBER_TBL_TYPE              Required
--                P_INTO_SUBSET        IN     NUMBER_TBL_TYPE              Required
--                P_ACTION_TYPE        IN     VARCHAR2                     Required
--                P_PHONE_SQL          IN     VARCHAR2                     Required
--                P_ENTRY_SQL          IN     VARCHAR2                     Required
--                P_BATCH_SIZE         IN     NUMBER                       Required
--                P_SRC_TYPE_VIEW      IN     VARCHAR2                     Required
--                X_NUM_PENDING        IN OUT NUMBER                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE TRANSITION_ENTRIES
   ( P_SOURCE_ID          IN            NUMBER
   , P_SERVER_ID          IN            NUMBER
   , P_CAMPAIGN_ID        IN            NUMBER
   , P_SCHED_ID           IN            NUMBER
   , P_TARGET_GROUP_ID    IN            NUMBER
   , P_FROM_SUBSET        IN            NUMBER
   , P_INTO_SUBSET        IN            NUMBER
   , P_ACTION_TYPE        IN            VARCHAR2
   , P_PHONE_SQL          IN            VARCHAR2
   , P_ENTRY_SQL          IN            VARCHAR2
   , P_BATCH_SIZE         IN            NUMBER
   , P_SRC_TYPE_VIEW      IN            VARCHAR2
   , X_NUM_PENDING        IN OUT NOCOPY NUMBER)
IS

  TYPE SubsetEntryType IS REF CURSOR;

  l_return_tbl SYSTEM.NUMBER_TBL_TYPE := SYSTEM.NUMBER_TBL_TYPE();
  l_locked_flag VARCHAR2(1);
  l_subset_entry_cursor SubsetEntryType;
  l_checked_entry_cursor SubsetEntryType;
  l_phone_cursor SubsetEntryType;
  l_phone_index NUMBER := 0;
  l_curr_list_Entry_id NUMBER;
  l_curr_subset_id NUMBER;
  l_curr_returns_id NUMBER;
  l_phone_entry_tbl UniqueIdList;
  l_phone_subset_tbl UniqueIdList;
  l_index_tbl UniqueIdList;
  l_region_tbl UniqueIdList;
  l_timezone_tbl UniqueIdList;
  l_territory_tbl TerritoryList;
  l_curr_return_id NUMBER;

BEGIN
  l_locked_flag := 'N';

   ----------------------------------------------------------------
   -- OPEN THE CURSOR FOR ALL ENTRIES TRANSITIONED FROM THE FROM
   -- SUBSET TO THE INTO SUBSET.
   ----------------------------------------------------------------
   OPEN l_subset_entry_cursor FOR P_ENTRY_SQL USING P_FROM_SUBSET;

   LOOP

      LOOP
         FETCH l_subset_entry_cursor INTO l_curr_return_id;

         EXIT WHEN l_subset_entry_cursor%NOTFOUND;

         l_return_tbl.EXTEND(1);
         l_return_tbl(l_return_tbl.LAST) := l_curr_return_id;

         EXIT WHEN l_return_tbl.COUNT >=  P_BATCH_SIZE;
      END LOOP;

      ----------------------------------------------------------------
      -- If fetch did not return any rows then drop out of loop.
      ----------------------------------------------------------------
      EXIT WHEN l_return_tbl.COUNT = 0 ;

      ----------------------------------------------------------------
      -- We first lock the schedule.  This is only executed in order
      -- to lock individual entries.  If we try to lock individual
      -- subsets there maybe the chance that we leave the subsets
      -- locked indefinitely if the procedure is cancelled.  Therefore
      -- we stick at the schedule level for safety reasons.
      ----------------------------------------------------------------
      LOCK_SCHEDULE( P_SOURCE_ID    => P_SOURCE_ID
                   , P_SCHED_ID     => P_SCHED_ID
                   , P_SERVER_ID    => P_SERVER_ID
                   , P_LOCK_FLAG    => 'Y'
                   , X_SUCCESS_FLAG => l_locked_flag);

      ----------------------------------------------------------------
      -- If we were able to lock the schedule then we will update
      -- all of the pulled subset ids for this particular batch
      -- of entries that have not been pulled yet so they are locked.
      ----------------------------------------------------------------
      IF l_locked_flag = 'Y' THEN
         TRACELOG('LOCKED SCHEDULE ' || P_SCHED_ID);

         BEGIN
            EXECUTE IMMEDIATE 'UPDATE IEC_G_RETURN_ENTRIES A ' ||
                              'SET A.PULLED_SUBSET_ID = :newSubsetId ' ||
                              'WHERE A.RETURNS_ID IN (SELECT * FROM TABLE(CAST(:collection AS SYSTEM.NUMBER_TBL_TYPE))) ' ||
                              'AND A.RECORD_OUT_FLAG = ''N'' AND A.PULLED_SUBSET_ID IS NULL'
            USING P_INTO_SUBSET
            ,     l_return_tbl;

            ----------------------------------------------------------------
            -- Increment transition entries to account for these
            -- entries.
            ----------------------------------------------------------------
            X_NUM_PENDING := X_NUM_PENDING + SQL%ROWCOUNT;

            ----------------------------------------------------------------
            -- Commit will lock the entries.
            ----------------------------------------------------------------
            COMMIT;

         EXCEPTION
            WHEN OTHERS THEN
               Log( 'Transition_Entries'
                  , 'LOCK_SUBSET_ENTRIES.SUBSET_' || p_from_subset
                  , SQLERRM);
               ----------------------------------------------------------------
               -- We can now unlock the schedule.
               ----------------------------------------------------------------
               LOCK_SCHEDULE( P_SOURCE_ID    => P_SOURCE_ID
                            , P_SCHED_ID     => P_SCHED_ID
                            , P_SERVER_ID    => P_SERVER_ID
                            , P_LOCK_FLAG    => 'N'
                            , X_SUCCESS_FLAG => l_locked_flag);
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END;

         ----------------------------------------------------------------
         -- We can now unlock the schedule.
         ----------------------------------------------------------------
         LOCK_SCHEDULE( P_SOURCE_ID    => P_SOURCE_ID
                      , P_SCHED_ID     => P_SCHED_ID
                      , P_SERVER_ID    => P_SERVER_ID
                      , P_LOCK_FLAG    => 'N'
                      , X_SUCCESS_FLAG => l_locked_flag);

      ELSE
         TRACELOG('COULD NOT LOCK SCHEDULE ' || P_SCHED_ID);
      END IF;

      ----------------------------------------------------------------
      -- At This point either we have entries that have already been
      -- checked out or we weren't able to get a lock so we have
      -- to loop thru the remaining entries and lock them one by one.
      ----------------------------------------------------------------

      OPEN l_checked_entry_cursor FOR 'SELECT RETURNS_ID FROM IEC_G_RETURN_ENTRIES ' ||
                                      'WHERE PULLED_SUBSET_ID IS NULL ' ||
                                      'AND RETURNS_ID IN (SELECT * FROM TABLE(CAST(:collection AS SYSTEM.NUMBER_TBL_TYPE)))'
      USING l_return_tbl;

      ----------------------------------------------------------------
      -- LOOP THRU ENTRIES RETRIEVED IN THE FETCH.  These are the
      -- entries in the original cursor that were not previously
      -- locked.
      ----------------------------------------------------------------
      LOOP
         FETCH l_checked_entry_cursor
         INTO  l_curr_returns_id;
         EXIT WHEN l_checked_entry_cursor%NOTFOUND;

         EXECUTE IMMEDIATE 'UPDATE IEC_G_RETURN_ENTRIES A ' ||
                           'SET PULLED_SUBSET_ID = :newSubsetId ' ||
                           'WHERE RETURNS_ID = :returnsId ' ||
                           'AND PULLED_SUBSET_ID IS NULL'
         USING P_INTO_SUBSET
         ,     l_curr_returns_id;

         ----------------------------------------------------------------
         -- Increment transition entries to account for this individual
         -- entry.
         ----------------------------------------------------------------
         X_NUM_PENDING := X_NUM_PENDING + 1;

         COMMIT;
      END LOOP;

      CLOSE l_checked_entry_cursor;

      ----------------------------------------------------------------
      -- Make sure the table has been cleaned of any entries belonging
      -- to this target group.  If we only allow one subset transition
      -- at a time, then we could truncate the table.
      ----------------------------------------------------------------
      BEGIN
         EXECUTE IMMEDIATE 'DELETE FROM iec_o_transition_subsets ' ||
                           'WHERE list_id = :1 '
         USING P_TARGET_GROUP_ID;
      EXCEPTION
         WHEN OTHERS THEN
            RAISE;
      END;

      ----------------------------------------------------------------
      -- The entries are locked and we now need to transition this
      -- batch.  First we pull entries that are not checked out into
      -- the transition table.  Ones that are checked out will be
      -- transitioned when they are checked back in.
      ----------------------------------------------------------------
      EXECUTE IMMEDIATE 'INSERT INTO IEC_O_TRANSITION_SUBSETS ' ||
              '( LIST_ID  ' ||
              ', LIST_ENTRY_ID  ' ||
              ', ORIG_SUBSET_ID ' ||
              ', NEW_SUBSET_ID ' ||
              ', ORIG_ITM_CC_TZ_ID ' ||
              ', NEW_ITM_CC_TZ_ID ' ||
              ', DO_NOT_USE_FLAG ' ||
              ', RECORD_OUT_FLAG ' ||
              ', RETURNS_ID ' ||
              ', CALL_ATTEMPTS  ' ||
              ') ' ||
              'SELECT A.LIST_HEADER_ID, A.LIST_ENTRY_ID, A.SUBSET_ID, A.PULLED_SUBSET_ID ' ||
                    ',  A.ITM_CC_TZ_ID, NULL, A.DO_NOT_USE_FLAG, ''N'', A.RETURNS_ID,  ' ||
                    ' DECODE(NVL(SUM(B.CALL_ATTEMPT), 0), 0, 0, 1) ' ||
                    ' FROM IEC_G_RETURN_ENTRIES A, IEC_O_RCY_CALL_HISTORIES B ' ||
                    ' WHERE A.SUBSET_ID = :oldSubsetId ' ||
                    ' AND A.RETURNS_ID = B.RETURNS_ID(+) ' ||
                    ' AND A.PULLED_SUBSET_ID = :newSubsetId' ||
                    ' AND A.RECORD_OUT_FLAG = ''N'' GROUP BY ' ||
                    ' A.LIST_HEADER_ID, A.LIST_ENTRY_ID, A.SUBSET_ID, A.PULLED_SUBSET_ID ' ||
                    ',  A.ITM_CC_TZ_ID, NULL, A.DO_NOT_USE_FLAG, ''N'', A.RETURNS_ID'
      USING P_FROM_SUBSET
      ,     P_INTO_SUBSET;

      ----------------------------------------------------------------
      -- Now that we have all of the entries in the transition table
      -- we need to get all of the entries phone numbers in the
      -- phone number entry table.  First we make sure the
      -- phone number transition table is cleared of all
      -- entries that pertain to this target group.
      ----------------------------------------------------------------
      EXECUTE IMMEDIATE 'DELETE FROM iec_o_transition_phones where list_id = :1'
      USING P_TARGET_GROUP_ID;

      ----------------------------------------------------------------
      -- Need to get all of the unique calling zones of the moved entries
      -- phone numbers.  Make sure there is a zone in the
      -- IEC_G_MKTG_ITEM_CC_TZS table to support.
      ----------------------------------------------------------------
      l_phone_index := 0;

      ----------------------------------------------------------------
      -- open the cursor to fetch the phone numbers for the current
      -- set of transitioning entries.
      ----------------------------------------------------------------
      OPEN l_phone_cursor FOR P_PHONE_SQL USING P_TARGET_GROUP_ID;

      ----------------------------------------------------------------
      -- Continue fetching the entries phone numbers and bringing
      -- them into a local collection.
      ----------------------------------------------------------------
      LOOP
         l_phone_index := l_phone_index + 1;

         FETCH l_phone_cursor INTO l_curr_list_Entry_id
                                 , l_curr_subset_id
                                 , l_index_tbl(l_phone_index)
                                 , l_territory_tbl(l_phone_index)
                                 , l_timezone_tbl(l_phone_index)
                                 , l_region_tbl(l_phone_index)
                                 , l_index_tbl(l_phone_index + 1)
                                 , l_territory_tbl(l_phone_index + 1)
                                 , l_timezone_tbl(l_phone_index + 1)
                                 , l_region_tbl(l_phone_index + 1)
                                 , l_index_tbl(l_phone_index + 2)
                                 , l_territory_tbl(l_phone_index + 2)
                                 , l_timezone_tbl(l_phone_index + 2)
                                 , l_region_tbl(l_phone_index + 2)
                                 , l_index_tbl(l_phone_index + 3)
                                 , l_territory_tbl(l_phone_index + 3)
                                 , l_timezone_tbl(l_phone_index + 3)
                                 , l_region_tbl(l_phone_index + 3)
                                 , l_index_tbl(l_phone_index + 4)
                                 , l_territory_tbl(l_phone_index + 4)
                                 , l_timezone_tbl(l_phone_index + 4)
                                 , l_region_tbl(l_phone_index + 4)
                                 , l_index_tbl(l_phone_index + 5)
                                 , l_territory_tbl(l_phone_index + 5)
                                 , l_timezone_tbl(l_phone_index + 5)
                                 , l_region_tbl(l_phone_index + 5);

         ----------------------------------------------------------------
         -- When cursor returns NOTFOUND we have stopped fetching from
         -- the cursor and therefore can exit the loop.
         ----------------------------------------------------------------
         EXIT WHEN l_phone_cursor%NOTFOUND;

         l_phone_subset_tbl(l_phone_index) := l_curr_subset_id;
         l_phone_entry_tbl(l_phone_index) := l_curr_list_Entry_id;
         l_phone_subset_tbl(l_phone_index + 1) := l_curr_subset_id;
         l_phone_entry_tbl(l_phone_index + 1) := l_curr_list_Entry_id;
         l_phone_subset_tbl(l_phone_index + 2) := l_curr_subset_id;
         l_phone_entry_tbl(l_phone_index + 2) := l_curr_list_Entry_id;
         l_phone_subset_tbl(l_phone_index + 3) := l_curr_subset_id;
         l_phone_entry_tbl(l_phone_index + 3) := l_curr_list_Entry_id;
         l_phone_subset_tbl(l_phone_index + 4) := l_curr_subset_id;
         l_phone_entry_tbl(l_phone_index + 4) := l_curr_list_Entry_id;
         l_phone_subset_tbl(l_phone_index + 5) := l_curr_subset_id;
         l_phone_entry_tbl(l_phone_index + 5) := l_curr_list_Entry_id;
         l_phone_index := l_phone_index + 5;

      END LOOP;

      ----------------------------------------------------------------
      -- Now that the internal collections have been filled we can close
      -- the phone cursor.
      ----------------------------------------------------------------
      CLOSE l_phone_cursor;

      ----------------------------------------------------------------
      -- Insert the phone entries into the transition table using
      -- the internal collections.
      ----------------------------------------------------------------
      IF l_phone_entry_tbl.COUNT > 0
      THEN
         FORALL j IN l_phone_entry_tbl.FIRST..l_phone_entry_tbl.LAST
            INSERT INTO iec_o_transition_phones
               ( LIST_ID
               , LIST_ENTRY_ID
               , SUBSET_ID
               , territory_code
               , region_id
               , timezone_id
               , phone_index
               )
               VALUES
               ( P_TARGET_GROUP_ID
               , l_phone_entry_tbl(j)
               , l_phone_subset_tbl(j)
               , l_territory_tbl(j)
               , l_region_tbl(j)
               , l_timezone_tbl(j)
               , l_index_tbl(j));
      END IF;

      ----------------------------------------------------------------
      -- Initialize all of the internal collections.
      ----------------------------------------------------------------
      l_phone_entry_tbl.DELETE;
      l_phone_subset_tbl.DELETE;
      l_territory_tbl.DELETE;
      l_region_tbl.DELETE;
      l_timezone_tbl.DELETE;
      l_index_tbl.DELETE;

      ----------------------------------------------------------------
      -- Insert a new entry into the iec_g_mktg_item_cc_Tzs table for
      -- any new zone that is now in the phone transition table.
      ----------------------------------------------------------------
      EXECUTE IMMEDIATE 'INSERT INTO IEC_G_MKTG_ITEM_CC_TZS ' ||
                        ' (ITM_CC_TZ_ID, LIST_HEADER_ID, CAMPAIGN_SCHEDULE_ID, TERRITORY_CODE, ' ||
                        ' TIMEZONE_ID, LAST_CALLABLE_TIME, CALLABLE_FLAG, OBJECT_VERSION_NUMBER, ' ||
                        ' SECURITY_GROUP_ID, LAST_UPDATE_DATE, RECORD_COUNT, REGION_ID, SUBSET_ID) '||
                        ' select IEC_G_MKTG_ITEM_CC_TZS_S.NEXTVAL, :listID, :schedID ' ||
                        ', a.territory_code, a.timezone_id, NULL, ''N'', 0, -1 ' ||
                        ', SYSDATE, 0, a.region_code, a.subset_id from ' ||
                        ' (SELECT DISTINCT DECODE(region_id, -1, NULL, region_id) region_code, territory_code, subset_id, timezone_id '||
                        ' from iec_o_transition_phones c where c.list_id = :listID ' ||
                        ' and territory_code <> ''-1'' and timezone_id <> -1 ' ||
                        ' and not exists (select null from iec_g_mktg_item_Cc_Tzs b where ' ||
                        ' c.subset_id = b.subset_id and c.territory_code = b.territory_code ' ||
                        ' and NVL(b.region_id, -1) = c.region_id and c.timezone_id = b.timezone_id ' ||
                        ' and c.list_id = b.list_header_id) ) a'
                        USING P_TARGET_GROUP_ID
                        ,     P_SCHED_ID
                        ,     P_TARGET_GROUP_ID;

      ----------------------------------------------------------------
      -- Updating the temporary
      -- phones table with the callable zones cross reference id.
      ----------------------------------------------------------------
      EXECUTE IMMEDIATE 'UPDATE IEC_O_TRANSITION_PHONES A SET A.ITM_CC_TZ_ID = ' ||
                        '( SELECT B.ITM_CC_TZ_ID FROM IEC_G_MKTG_ITEM_CC_TZS B ' ||
                        ' WHERE B.LIST_HEADER_ID = A.LIST_ID AND B.SUBSET_ID = A.SUBSET_ID ' ||
                        ' AND B.TERRITORY_CODE = A.TERRITORY_CODE AND B.TIMEZONE_ID = A.TIMEZONE_ID ' ||
                        ' AND NVL(B.REGION_ID, -1) = A.REGION_ID) WHERE A.LIST_ID = :listID ' ||
                        ' AND A.TERRITORY_CODE <> ''-1'' AND A.TIMEZONE_ID <> -1 '
                        USING P_TARGET_GROUP_ID;

      ----------------------------------------------------------------
      -- Updating the transition entries table with the
      -- new current callable zone cross reference id.
      ----------------------------------------------------------------
      EXECUTE IMMEDIATE 'UPDATE IEC_O_TRANSITION_SUBSETS A SET A.NEW_ITM_CC_TZ_ID = ' ||
                        ' (SELECT D.ITM_CC_TZ_ID ' ||
                        ' FROM IEC_G_RETURN_ENTRIES B, IEC_G_MKTG_ITEM_CC_TZS C, IEC_G_MKTG_ITEM_CC_TZS D ' ||
                        ' WHERE A.LIST_ENTRY_ID = B.LIST_ENTRY_ID AND A.LIST_ID = B.LIST_HEADER_ID ' ||
                        ' AND B.LIST_HEADER_ID = C.LIST_HEADER_ID AND B.ITM_CC_TZ_ID = C.ITM_CC_TZ_ID' ||
                        ' AND D.TERRITORY_CODE = C.TERRITORY_CODE AND D.SUBSET_ID = A.NEW_SUBSET_ID AND ' ||
                        ' D.TIMEZONE_ID = C.TIMEZONE_ID AND D.LIST_HEADER_ID = C.LIST_HEADER_ID ' ||
                        ' AND NVL(D.REGION_ID, -1) = NVL(C.REGION_ID, -1)) ' ||
                        ' WHERE A.LIST_ID = :list_ID' ||
                        ' AND A.ORIG_SUBSET_ID <> A.NEW_SUBSET_ID'
                        USING P_TARGET_GROUP_ID;

      ----------------------------------------------------------------
      -- Need to transition entries.  This is for the records that have
      -- NOT been checked out of AMS_LIST_ENTRIES.  Those records
      -- need to be treated differently to keep from causing
      -- deadlocks with the other processes.
      ----------------------------------------------------------------
      TRANSITION_NON_CHECKED_ENTRIES( P_SOURCE_ID
                                    , P_CAMPAIGN_ID
                                    , P_SCHED_ID
                                    , P_TARGET_GROUP_ID
                                    , P_SRC_TYPE_VIEW
                                    , 'N');

      ----------------------------------------------------------------
      -- If fetch did not return batch size then finished with cursor.
      ----------------------------------------------------------------
      EXIT WHEN l_return_tbl.COUNT < P_BATCH_SIZE ;

      l_return_tbl.DELETE;
   END LOOP;

   ----------------------------------------------------------------
   -- Return the number of entries that have yet to be transitioned.
   -- For perforamnce reasons we could choose to simply look for
   -- the first instead of actually counting.
   ----------------------------------------------------------------
   EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM IEC_G_RETURN_ENTRIES WHERE SUBSET_ID = :1 and PULLED_SUBSET_ID IS NOT NULL'
   INTO X_NUM_PENDING
   USING P_FROM_SUBSET;

   ----------------------------------------------------------------
   -- Makes sure the returns collection is removed.
   ----------------------------------------------------------------
   l_return_tbl.DELETE;

   ----------------------------------------------------------------
   -- Makes sure the subset entry cursor is closed.
   ----------------------------------------------------------------
   CLOSE l_subset_entry_cursor;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR  THEN
      IF l_subset_entry_cursor%ISOPEN
      THEN
         CLOSE l_subset_entry_cursor;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF l_subset_entry_cursor%ISOPEN
      THEN
         CLOSE l_subset_entry_cursor;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
   WHEN OTHERS THEN
      Log( 'Transition_Entries'
         , 'MAIN.LIST_' || p_target_group_id
         , SQLERRM);
      IF l_subset_entry_cursor%ISOPEN
      THEN
        CLOSE l_subset_entry_cursor;
      END IF;
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END TRANSITION_ENTRIES;-- PL/SQL Block

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : SUBSET_TRANSITION
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_SOURCE_ID                      IN     NUMBER                       Required
--                P_SERVER_ID          IN     NUMBER
--                P_TARGET_GROUP_ID    IN     NUMBER
--                P_FROM_SUBSETS       IN     NUMBER_TBL_TYPE
--                P_INTO_SUBSETS       IN     NUMBER_TBL_TYPE
--                P_ACTION_TYPE        IN     VARCHAR2
--                X_NUM_PENDING           OUT NUMBER
--                X_ACTION_ID             OUT NUMBER
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE SUBSET_TRANSITION
   ( P_SOURCE_ID          IN            NUMBER
   , P_SERVER_ID          IN            NUMBER
   , P_CAMPAIGN_ID        IN            NUMBER
   , P_SCHEDULE_ID        IN            NUMBER
   , P_TARGET_GROUP_ID    IN            NUMBER
   , P_FROM_SUBSETS       IN            SYSTEM.NUMBER_TBL_TYPE
   , P_INTO_SUBSETS       IN            SYSTEM.NUMBER_TBL_TYPE
   , P_ACTION_TYPE        IN            VARCHAR2
   , X_NUM_PENDING           OUT NOCOPY NUMBER
   , X_ACTION_ID             OUT NOCOPY NUMBER
   )
IS

  ----------------------------------------------------------------
  -- Local copy of the subsets to move entries into.
  ----------------------------------------------------------------
  l_into_subsets SYSTEM.NUMBER_TBL_TYPE := SYSTEM.NUMBER_TBL_TYPE();

  ----------------------------------------------------------------
  -- Status code used locally.
  ----------------------------------------------------------------
  L_STATUS_CODE VARCHAR2(1);

  ----------------------------------------------------------------
  -- Status code used locally.
  ----------------------------------------------------------------
  l_return_code VARCHAR2(1);

  ----------------------------------------------------------------
  -- The source type view name for the current list.
  ----------------------------------------------------------------
  l_src_type_view_name VARCHAR2(30);

  ----------------------------------------------------------------
  -- The subset view name for the current subset.
  ----------------------------------------------------------------
  l_subset_view_name VARCHAR2(30);

  ----------------------------------------------------------------
  -- Query used to return candidate entries.
  ----------------------------------------------------------------
  l_first_query_entry_sql VARCHAR2(3000);

  ----------------------------------------------------------------
  -- Query used to return candidate entries.
  ----------------------------------------------------------------
  l_second_query_entry_sql VARCHAR2(3000);

  ----------------------------------------------------------------
  -- Query used to return candidate entries' phone numbers.
  ----------------------------------------------------------------
  l_phone_sql VARCHAR2(3000);

  ----------------------------------------------------------------
  -- Default Subset id for the passed in list.
  ----------------------------------------------------------------
  l_default_subset_id NUMBER := 0;

  ----------------------------------------------------------------
  -- The size of the current subset that the entries
  -- will be transitioned from.
  ----------------------------------------------------------------
  l_subset_load_size NUMBER := 0;

  ----------------------------------------------------------------
  -- The number of entries left in the current subset that the entries
  -- will be transitioned from.
  ----------------------------------------------------------------
  l_subset_left_size NUMBER := 0;

  ----------------------------------------------------------------
  -- The number of entries callable in the current subset that the entries
  -- will be transitioned from.
  ----------------------------------------------------------------
  l_subset_callable_size NUMBER := 0;

  ----------------------------------------------------------------
  -- The maximum number of entries to lock of the next entries.
  ----------------------------------------------------------------
  l_first_batch_size NUMBER := 0;

  ----------------------------------------------------------------
  -- The maximum number of entries to lock of all of the rest
  -- of the entries.
  ----------------------------------------------------------------
  l_last_batch_size NUMBER := 0;

  ----------------------------------------------------------------
  -- Initialize l_transition_entries to 0.  If l_transition_entries
  -- is greater than 0 at the end of this procedure then this is a
  -- continuous transition.
  ----------------------------------------------------------------
  l_transition_entries NUMBER := 0;

  ----------------------------------------------------------------
  -- Flag determines if there are currently any entries callable.
  -- If there are then the candidate entries in the first transition
  -- process will be the callable entries if not then the candidate
  -- entries will be all of the entries that can still be used.
  ----------------------------------------------------------------
  L_USE_CALLABLE_FLAG BOOLEAN := TRUE;

BEGIN
  L_STATUS_CODE  := FND_API.G_RET_STS_SUCCESS;
  l_return_code  := FND_API.G_RET_STS_SUCCESS;

    X_NUM_PENDING := 0;
    X_ACTION_ID := 0;

    ----------------------------------------------------------------
    -- This will retrieve the view name from an IEc lookup value
    -- that has been seeded in the database.  In the future there
    -- might be an algorithm used to BUILD the view name using values
    -- stored in the marketing schema.
    ----------------------------------------------------------------
    GET_SOURCETYPE_VIEW_NAME
      ( P_SOURCE_ID  => P_SOURCE_ID
      , P_TARGET_GROUP_ID  => P_TARGET_GROUP_ID
      , X_VIEW_NAME  => l_src_type_view_name);



    ----------------------------------------------------------------
    -- If the transition from subset is to be deleted then we need
    -- the id for the default subset in order to transition all
    -- entries that do not fall into the category of another defined
    -- subset.
    ----------------------------------------------------------------
    IF (P_ACTION_TYPE = 'Y')
    THEN

      ----------------------------------------------------------------
      -- This will return the default subset id for this target group.
      ----------------------------------------------------------------
      GET_DEFAULT_SUBSET_ID( P_SOURCE_ID => P_SOURCE_ID
                          , P_TARGET_GROUP_ID  => P_TARGET_GROUP_ID
                          , X_DEFAULT_SUBSET_ID => l_default_subset_id);

      ----------------------------------------------------------------
      -- Loop thru the list of subsets that entries will be
      -- transitioning into.  Make sure the default subset is placed at
      -- the end of the collection.  If the default subset is anywhere
      -- else in the list then set it to -1 so it doesn't try to
      -- execute.
      ----------------------------------------------------------------
      FOR I IN P_INTO_SUBSETS.FIRST..P_INTO_SUBSETS.LAST
      LOOP
        IF (P_INTO_SUBSETS(I) = l_default_subset_id)
        THEN
          IF (I = P_INTO_SUBSETS.LAST)
          THEN
            l_into_subsets.EXTEND(1);
            l_into_subsets(l_into_subsets.LAST) := P_INTO_SUBSETS(I);
            EXIT;
          END IF;
        ELSE
          l_into_subsets.EXTEND(1);
          l_into_subsets(l_into_subsets.LAST) := P_INTO_SUBSETS(I);
          IF (I = P_INTO_SUBSETS.LAST)
          THEN
            l_into_subsets.EXTEND(1);
            l_into_subsets(l_into_subsets.LAST) := l_default_subset_id;
          END IF;
        END IF;
      END LOOP;

    ELSE

      ----------------------------------------------------------------
      -- Loop thru the list of subsets that entries will be
      -- transitioning into.  Make sure the default subset is placed at
      -- the end of the collection.  If the default subset is anywhere
      -- else in the list then set it to -1 so it doesn't try to
      -- execute.
      ----------------------------------------------------------------
      FOR I IN P_INTO_SUBSETS.FIRST..P_INTO_SUBSETS.LAST
      LOOP
        l_into_subsets.EXTEND(1);
        l_into_subsets(l_into_subsets.LAST) := P_INTO_SUBSETS(I);
      END LOOP;

    END IF;

   ----------------------------------------------------------------
   -- Calculate the size of the current subset that the entries
   -- will be transitioned from.
   ----------------------------------------------------------------
   BEGIN
      EXECUTE IMMEDIATE 'SELECT  NVL(RECORD_LOADED,0) ' ||
                        ' FROM   IEC_G_REP_SUBSET_COUNTS ' ||
                        ' WHERE  subset_id = :subsetId '
      INTO   l_subset_load_size
      USING  P_FROM_SUBSETS(1);
   EXCEPTION
      WHEN OTHERS THEN
         Log( 'Subset_Transition'
            , 'GET_TOTAL_ENTRY_COUNT.SUBSET_' || P_FROM_SUBSETS(1)
            , SQLERRM);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   ----------------------------------------------------------------
   -- Calculate the number of entries left in the current subset that the entries
   -- will be transitioned from.
   ----------------------------------------------------------------
   BEGIN
      EXECUTE IMMEDIATE 'SELECT  NVL(SUM(RECORD_COUNT),0) ' ||
                        ' FROM   IEC_G_MKTG_ITEM_CC_TZS ' ||
                        ' WHERE  subset_id = :subsetId '
      INTO   l_subset_left_size
      USING  P_FROM_SUBSETS(1);
   EXCEPTION
      WHEN OTHERS THEN
         Log( 'Subset_Transition'
            , 'GET_REMAINING_ENTRY_COUNT.SUBSET_' || P_FROM_SUBSETS(1)
            , SQLERRM);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   ----------------------------------------------------------------
   -- Calculate the number of entries callable in the current subset that the entries
   -- will be transitioned from.
   ----------------------------------------------------------------
   BEGIN
      EXECUTE IMMEDIATE 'SELECT  NVL(SUM(RECORD_COUNT),0) ' ||
                        ' FROM   IEC_G_MKTG_ITEM_CC_TZS ' ||
                        ' WHERE  subset_id = :subsetId ' ||
                        ' AND    CALLABLE_FLAG = ''Y'' ' ||
                        ' AND    LAST_CALLABLE_TIME > SYSDATE '
      INTO   l_subset_callable_size
      USING  P_FROM_SUBSETS(1);

   EXCEPTION
      WHEN OTHERS THEN
         Log( 'Subset_Transition'
            , 'GET_CALLABLE_ENTRY_COUNT.SUBSET_' || P_FROM_SUBSETS(1)
            , SQLERRM);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

   ----------------------------------------------------------------
   -- Determine the max batch size for moving entries that are
   -- candidates for the next retrieval.
   ----------------------------------------------------------------
   IF (L_SUBSET_CALLABLE_SIZE <= 0) THEN
      IF (L_SUBSET_LEFT_SIZE <= 0) THEN
         IF (L_SUBSET_LEFT_SIZE > 200) THEN
            L_FIRST_BATCH_SIZE := TRUNC(L_SUBSET_LEFT_SIZE / 2);
         ELSE
            L_FIRST_BATCH_SIZE := L_SUBSET_LEFT_SIZE;
         END IF;
      ELSE
         L_FIRST_BATCH_SIZE := 10000;
      END IF;
      L_USE_CALLABLE_FLAG := FALSE;
   ELSE
      IF (L_SUBSET_CALLABLE_SIZE > 200) THEN
         L_FIRST_BATCH_SIZE := TRUNC(L_SUBSET_CALLABLE_SIZE / 2);
      ELSE
         L_FIRST_BATCH_SIZE := L_SUBSET_CALLABLE_SIZE;
      END IF;
      L_USE_CALLABLE_FLAG := TRUE;
   END IF;

   ----------------------------------------------------------------
   -- Determine the max batch size for moving entries that are
   -- not candidates for the next retrieval.
   ----------------------------------------------------------------
   l_LAST_BATCH_SIZE := 10000;

   ----------------------------------------------------------------
   -- We need to retrieve all of the phone numbers for the current
   -- group of candidate entries.
   ----------------------------------------------------------------
   l_phone_sql := 'SELECT a.list_entry_id, h.new_subset_id ' ||
                  ',1, NVL(b.TERRITORY_CODE, ''-1''), NVL(b.TIMEZONE_ID, -1), NVL(b.REGION_ID, -1) ' ||
                  ',2, NVL(c.TERRITORY_CODE, ''-1''), NVL(c.TIMEZONE_ID, -1), NVL(c.REGION_ID, -1) ' ||
                  ',3, NVL(d.TERRITORY_CODE, ''-1''), NVL(d.TIMEZONE_ID, -1), NVL(d.REGION_ID, -1) ' ||
                  ',4, NVL(e.TERRITORY_CODE, ''-1''), NVL(e.TIMEZONE_ID, -1), NVL(e.REGION_ID, -1) ' ||
                  ',5, NVL(f.TERRITORY_CODE, ''-1''), NVL(f.TIMEZONE_ID, -1), NVL(f.REGION_ID, -1) ' ||
                  ',6, NVL(g.TERRITORY_CODE, ''-1''), NVL(g.TIMEZONE_ID, -1), NVL(g.REGION_ID, -1) ' ||
                  'from ' || l_src_type_view_name || ' a ' ||
                  ', iec_g_mktg_item_cc_Tzs b ' ||
                  ', iec_g_mktg_item_cc_Tzs c ' ||
                  ', iec_g_mktg_item_cc_Tzs d ' ||
                  ', iec_g_mktg_item_cc_Tzs e ' ||
                  ', iec_g_mktg_item_cc_Tzs f ' ||
                  ', iec_g_mktg_item_cc_Tzs g ' ||
                  ', IEC_O_TRANSITION_SUBSETS h ' ||
                  'where h.list_id = :listID ' ||
                  'and h.list_id = a.list_header_id ' ||
                  'and h.list_entry_id = a.list_entry_id ' ||
                  'and a.reason_code_S1 = b.itm_cc_tz_id(+) ' ||
                  'and a.reason_code_S2 = c.itm_cc_tz_id(+) ' ||
                  'and a.reason_code_S3 = d.itm_cc_tz_id(+) ' ||
                  'and a.reason_code_S4 = e.itm_cc_tz_id(+) ' ||
                  'and a.reason_code_S5 = f.itm_cc_tz_id(+) ' ||
                  'and a.reason_code_S6 = g.itm_cc_tz_id(+)';

   ----------------------------------------------------------------
   -- Initialize l_transition_entries to 0.  If l_transition_entries
   -- is greater than 0 at the end of this procedure then this is a
   -- continuous transition.
   ----------------------------------------------------------------
   l_transition_entries := 0;

   ----------------------------------------------------------------
   -- Loop thru the list of subsets that entries will be
   -- transitioning into.  Disregard the default subset.
   -- This loop is to move entries that are the next that could be
   -- called.
   ----------------------------------------------------------------
   FOR I IN l_into_subsets.FIRST..l_into_subsets.LAST
   LOOP
      IF (l_into_subsets(I) > 0 OR (P_ACTION_TYPE = 'N' AND l_into_subsets(I) = l_default_subset_id))
      THEN

         IF (P_ACTION_TYPE = 'N' OR l_into_subsets(I) <> l_default_subset_id)
         THEN

            ----------------------------------------------------------------
            -- Return the view that we will use for this into subset.
            ----------------------------------------------------------------
            l_subset_view_name := GET_SUBSET_VIEW( P_SOURCE_ID
                                                 , P_TARGET_GROUP_ID
                                                 , l_into_subsets(I)
                                                 , ' '
                                                 , l_src_type_view_name
                                                 , l_return_code);

            ----------------------------------------------------------------
            -- Build SQL query for the cursor for this into subset.
            -- Think about the timing with the L_USE_CALLABLE_FLAG.
            ----------------------------------------------------------------
            IF L_USE_CALLABLE_FLAG = TRUE
            THEN
               l_first_query_entry_sql := 'SELECT A.RETURNS_ID ' ||
                        ' FROM IEC_G_RETURN_ENTRIES A ' ||
                        ' WHERE A.SUBSET_ID = :subsetId ' ||
                        ' AND A.PULLED_SUBSET_ID IS NULL ' ||
                        ' AND A.ITM_CC_TZ_ID IN ' ||
                        ' (SELECT ITM_CC_TZ_ID FROM ' ||
                        ' IEC_G_MKTG_ITEM_CC_TZS B WHERE ' ||
                        ' A.SUBSET_ID = B.SUBSET_ID ' ||
                        ' AND B.CALLABLE_FLAG = ''Y'' ' ||
                        ' AND B.LAST_CALLABLE_TIME > SYSDATE) ' ||
                        ' AND A.LIST_ENTRY_ID IN (SELECT  C.LIST_ENTRY_ID ' ||
                        ' FROM ' || l_subset_view_name || ' C)';
            ELSE
               l_first_query_entry_sql := 'SELECT A.RETURNS_ID ' ||
                        ' FROM IEC_G_RETURN_ENTRIES A ' ||
                        ' WHERE A.SUBSET_ID = :subsetId ' ||
                        ' AND A.PULLED_SUBSET_ID IS NULL ' ||
                        ' AND A.DO_NOT_USE_FLAG = ''N'' ' ||
                        ' AND A.LIST_ENTRY_ID IN (SELECT  C.LIST_ENTRY_ID ' ||
                        ' FROM ' || l_subset_view_name || ' C)';

            END IF;

            l_second_query_entry_sql := 'SELECT A.RETURNS_ID ' ||
                    ' FROM IEC_G_RETURN_ENTRIES A ' ||
                    ' WHERE A.SUBSET_ID = :subsetId ' ||
                    ' AND A.PULLED_SUBSET_ID IS NULL ' ||
                    ' AND A.LIST_ENTRY_ID IN (SELECT  C.LIST_ENTRY_ID ' ||
                    ' FROM ' || l_subset_view_name || ' C)';

         ELSE
            ----------------------------------------------------------------
            -- Build SQL query for the cursor for this into subset.
            -- Think about the timing with the L_USE_CALLABLE_FLAG.
            ----------------------------------------------------------------
            IF L_USE_CALLABLE_FLAG = TRUE THEN
               l_first_query_entry_sql := 'SELECT A.RETURNS_ID ' ||
                        ' FROM IEC_G_RETURN_ENTRIES A ' ||
                        ' WHERE A.SUBSET_ID = :subsetId ' ||
                        ' AND A.PULLED_SUBSET_ID IS NULL ' ||
                        ' AND A.ITM_CC_TZ_ID IN ' ||
                        ' (SELECT ITM_CC_TZ_ID FROM ' ||
                        ' IEC_G_MKTG_ITEM_CC_TZS B WHERE ' ||
                        ' A.SUBSET_ID = B.SUBSET_ID ' ||
                        ' AND B.CALLABLE_FLAG = ''Y'' ' ||
                        ' AND B.LAST_CALLABLE_TIME > SYSDATE)';
            ELSE
               l_first_query_entry_sql := 'SELECT A.RETURNS_ID ' ||
                        ' FROM IEC_G_RETURN_ENTRIES A ' ||
                        ' WHERE A.SUBSET_ID = :subsetId ' ||
                        ' AND A.PULLED_SUBSET_ID IS NULL ' ||
                        ' AND A.DO_NOT_USE_FLAG = ''N'' ';
            END IF;

            l_second_query_entry_sql := 'SELECT A.RETURNS_ID ' ||
                    ' FROM IEC_G_RETURN_ENTRIES A ' ||
                    ' WHERE A.SUBSET_ID = :subsetId ' ||
                    ' AND A.PULLED_SUBSET_ID IS NULL ';

         END IF;

         ----------------------------------------------------------------
         -- First Call Tranisition Entries to transition the entries that
         -- will be the most likely to be fetched next.
         ----------------------------------------------------------------

         TRANSITION_ENTRIES( P_SOURCE_ID => P_SOURCE_ID
                           , P_SERVER_ID => P_SERVER_ID
                           , P_CAMPAIGN_ID => P_CAMPAIGN_ID
                           , P_SCHED_ID => P_SCHEDULE_ID
                           , P_TARGET_GROUP_ID => P_TARGET_GROUP_ID
                           , P_FROM_SUBSET => P_FROM_SUBSETS(1)
                           , P_INTO_SUBSET => l_into_subsets(I)
                           , P_ACTION_TYPE => P_ACTION_TYPE
                           , P_PHONE_SQL => l_phone_sql
                           , P_ENTRY_SQL => l_first_query_entry_sql
                           , P_BATCH_SIZE => L_FIRST_BATCH_SIZE
                           , P_SRC_TYPE_VIEW => l_src_type_view_name
                           , X_NUM_PENDING => l_transition_entries);

         ----------------------------------------------------------------
         -- Next Call Tranisition Entries to transition the rest of the
         -- entries.
         ----------------------------------------------------------------
         TRANSITION_ENTRIES( P_SOURCE_ID => P_SOURCE_ID
                           , P_SERVER_ID => P_SERVER_ID
                           , P_CAMPAIGN_ID => P_CAMPAIGN_ID
                           , P_SCHED_ID => P_SCHEDULE_ID
                           , P_TARGET_GROUP_ID => P_TARGET_GROUP_ID
                           , P_FROM_SUBSET => P_FROM_SUBSETS(1)
                           , P_INTO_SUBSET => l_into_subsets(I)
                           , P_ACTION_TYPE => P_ACTION_TYPE
                           , P_PHONE_SQL => l_phone_sql
                           , P_ENTRY_SQL => l_second_query_entry_sql
                           , P_BATCH_SIZE => L_LAST_BATCH_SIZE
                           , P_SRC_TYPE_VIEW => l_src_type_view_name
                           , X_NUM_PENDING => l_transition_entries);

      END IF; -- end if subset id <> 0 condition

   END LOOP; -- end loop thru into collection to apply views

   COMMIT;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN OTHERS THEN
      ROLLBACK;
      Log( 'Subset_Transition'
         , 'MAIN.LIST_' || p_target_group_id
         , SQLERRM);
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END SUBSET_TRANSITION;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : TEST_TRANSITION
--  Type        : Public
--  Pre-reqs    : None
--  Function    :
--  Parameters  :
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
  PROCEDURE TEST_TRANSITION
  IS
   LIST_ID NUMBER;
   SUBSET_INTO_TBL SYSTEM.NUMBER_TBL_TYPE;
   SUBSET_FROM_TBL SYSTEM.NUMBER_TBL_TYPE;
   RETURN_NUM NUMBER;
   X_ACTION_ID NUMBER;
BEGIN
   LIST_ID := 10606;
   SUBSET_INTO_TBL := SYSTEM.NUMBER_TBL_TYPE(10041);
   SUBSET_FROM_TBL := SYSTEM.NUMBER_TBL_TYPE(10028);
   TRACELOG(TO_CHAR(SYSDATE, 'MM-DD-YYYY:HH24:MI:SS'));
   IEC_SUBSET_PVT.SUBSET_TRANSITION (      1001
                                         , 10115
                                         , 0 -- CAMPAIGN_ID
                                         , 0 -- SCHEDULE_ID
                                         , LIST_ID
                                         , SUBSET_FROM_TBL
                                         , SUBSET_INTO_TBL
                                         , 'N'
                                         , RETURN_NUM
                                         , X_ACTION_ID);
   TRACELOG(RETURN_NUM);
   TRACELOG(TO_CHAR(SYSDATE, 'MM-DD-YYYY:HH24:MI:SS'));
END TEST_TRANSITION;

END IEC_SUBSET_PVT;

/
