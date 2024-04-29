--------------------------------------------------------
--  DDL for Package Body IEC_RECORD_FILTER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEC_RECORD_FILTER_PVT" AS
/* $Header: IECRECFB.pls 115.10 2004/09/03 16:34:19 alromero noship $ */

g_pkg_name CONSTANT VARCHAR2(30) := 'IEC_RECORD_FILTER_PVT';

g_error_msg VARCHAR2(2048);
g_source_id NUMBER(15);

PROCEDURE Log ( p_activity_desc IN VARCHAR2
              , p_method_name   IN VARCHAR2
              , p_sub_method    IN VARCHAR2
              , p_sql_code      IN NUMBER
              , p_sql_errm      IN VARCHAR2)
IS
   l_error_msg VARCHAR2(2048);
BEGIN

   IEC_OCS_LOG_PVT.LOG_INTERNAL_PLSQL_ERROR
                      ( 'IEC_RECORD_FILTER_PVT'
                      , p_method_name
                      , p_sub_method
                      , p_activity_desc
                      , p_sql_code
                      , p_sql_errm
                      , l_error_msg
                      );

   IF g_error_msg IS NULL THEN

      g_error_msg := l_error_msg;

   END IF;

END Log;

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
      Log( NULL
         , 'Get_AppsSchemaName'
         , 'MAIN'
         , SQLCODE
         , SQLERRM);
      RAISE fnd_api.g_exc_unexpected_error;

END Get_AppsSchemaName;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Make_ListEntriesAvailable
--  Type        : Private
--  Pre-reqs    : None
--  Function    : Makes list entries with specified do not use reason available by setting
--                the DO_NOT_USE_FLAG to 'N' in IEC_G_RETURN_ENTRIES.  Report counts
--                are updated to reflect that these entries are now available.
--
--  Parameters  : p_list_header_id       IN     NUMBER            Required
--                p_dnu_reason_code      IN     NUMBER            Required
--                p_commit               IN     VARCHAR2          Required
--                x_return_status           OUT VARCHAR2          Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Make_ListEntriesAvailable
   ( p_list_header_id	  IN	        NUMBER
   , p_dnu_reason_code	  IN	        NUMBER
   , p_commit             IN            BOOLEAN
   , x_return_status         OUT NOCOPY VARCHAR2)
IS

   l_returns_ids   system.number_tbl_type := system.number_tbl_type();
   l_itm_cc_tz_ids system.number_tbl_type := system.number_tbl_type();

BEGIN

   SAVEPOINT SP1;

   x_return_status := 'S';

   IF p_dnu_reason_code IS NOT NULL THEN

      SELECT RETURNS_ID, ITM_CC_TZ_ID
      BULK COLLECT INTO l_returns_ids, l_itm_cc_tz_ids
      FROM IEC_G_RETURN_ENTRIES
      WHERE LIST_HEADER_ID = P_LIST_HEADER_ID AND DO_NOT_USE_FLAG = 'Y' AND DO_NOT_USE_REASON = P_DNU_REASON_CODE;

   ELSE

      SELECT RETURNS_ID, ITM_CC_TZ_ID
      BULK COLLECT INTO l_returns_ids, l_itm_cc_tz_ids
      FROM IEC_G_RETURN_ENTRIES
      WHERE LIST_HEADER_ID = P_LIST_HEADER_ID AND DO_NOT_USE_FLAG = 'Y';

   END IF;

   IF l_returns_ids IS NOT NULL AND l_returns_ids.COUNT > 0 THEN

      FORALL I IN l_returns_ids.FIRST..l_returns_ids.LAST
         UPDATE IEC_G_RETURN_ENTRIES
         SET DO_NOT_USE_FLAG = 'N'
           , DO_NOT_USE_REASON = NULL
         WHERE RETURNS_ID = l_returns_ids(I);

      FORALL I IN l_itm_cc_tz_ids.FIRST..l_itm_cc_tz_ids.LAST
         UPDATE IEC_G_MKTG_ITEM_CC_TZS
         SET RECORD_COUNT = NVL(RECORD_COUNT, 0) + 1
         WHERE ITM_CC_TZ_ID = l_itm_cc_tz_ids(I);

   END IF;

   IF p_commit THEN
      COMMIT;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      ROLLBACK TO SP1;
      x_return_status := 'E';

END Make_ListEntriesAvailable;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Verify_RecordFilterView
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--
--  Parameters  : P_SUBSET_ID                      IN     NUMBER                       Required
--                X_RETURN_CODE                    OUT  VARCHAR2                       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Verify_RecordFilterView
   ( p_record_filter_id   IN            NUMBER
   , x_view_name             OUT NOCOPY VARCHAR2
   , x_view_exists           OUT NOCOPY VARCHAR2
   , x_return_code           OUT NOCOPY VARCHAR2
   )
IS
   l_status      VARCHAR2(10);
   l_view_name   VARCHAR2(30);
   l_view_owner  VARCHAR2(30);
   l_return_code VARCHAR2(1);

BEGIN

   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;
   X_VIEW_EXISTS := 'N';

   L_VIEW_NAME := 'IEC_REC_FILTER_' || p_record_filter_id || '_V';
   l_view_owner := Get_AppsSchemaName;

   BEGIN
      EXECUTE IMMEDIATE ' SELECT STATUS ' ||
                        ' FROM ALL_OBJECTS ' ||
                        ' WHERE OWNER = :owner ' ||
                        ' AND OBJECT_NAME = :b1 ' ||
                        ' AND OBJECT_TYPE = ''VIEW'' '
      INTO l_status
      USING l_view_owner
          , l_view_name;

      IF (l_status <> 'VALID')
      THEN
       -- TODO: Need to log that this record filter has invalid criteria.
       -- Might want to attempt to rebuild the view to make
       -- sure the lates changes have been built into the view
       -- prior to making this assertion.
         x_return_code := FND_API.G_RET_STS_ERROR;
      ELSE
         x_view_exists := 'Y';
      END IF;

      x_view_name := l_view_name;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         x_view_exists := 'N';
         x_view_name := l_view_name;
      WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR  THEN
      X_RETURN_CODE := 'E';
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      X_RETURN_CODE := 'U';
   WHEN OTHERS THEN
      X_RETURN_CODE := 'U';

END Verify_RecordFilterView;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Create_RecordFilterView
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--  Parameters  : P_LIST_ID              IN     NUMBER                       Required
--                X_RETURN_CODE             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Create_RecordFilterView
   ( p_record_filter_id      IN            NUMBER
   , p_view_name             IN            VARCHAR2
   , p_source_type_view_name IN            VARCHAR2
   , x_return_code              OUT NOCOPY VARCHAR2
   )
IS
   PRAGMA AUTONOMOUS_TRANSACTION;

   ----------------------------------------------------------------
   -- A table of VARCHAR2(256) that is used to build the record
   -- filter query.
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
   -- The first part of the record filter query SQL that is unique to
   -- each list by source view id and list id:
   ----------------------------------------------------------------
   l_create_start_str  CONSTANT VARCHAR2(16) := 'CREATE VIEW ';

   ----------------------------------------------------------------
   -- The first part of the record filter query SQL that is unique to
   -- each list by source view id and list id:
   ----------------------------------------------------------------
   l_create_as_str  CONSTANT VARCHAR2(100) := ' AS SELECT LIST_HEADER_ID, LIST_ENTRY_ID FROM ';

   ----------------------------------------------------------------
   -- The first part of the record filter query SQL that is unique to
   -- each list by source view id and list id:
   ----------------------------------------------------------------
   l_create_where_str  CONSTANT VARCHAR2(32) := ' WHERE ';

   ----------------------------------------------------------------
   -- Local Status code.
   ----------------------------------------------------------------
   l_status_code VARCHAR2(1);

BEGIN

   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

   l_create_statement(1) := l_create_start_str
                         || p_view_name
                         || l_create_as_str
                         || p_source_type_view_name
                         || l_create_where_str;

   IEC_CRITERIA_UTIL_PVT.Append_RecFilterCriteriaClause
      ( NULL
      , p_record_filter_id
      , p_source_type_view_name
      , l_create_statement
      , l_status_code);

   IF l_status_code = FND_API.G_RET_STS_SUCCESS THEN
      l_work_cursor := DBMS_SQL.OPEN_CURSOR;

      DBMS_SQL.PARSE( c             => l_work_cursor
                    , statement     => l_create_statement
                    , lb            => 1
                    , ub            => l_create_statement.COUNT
                    , lfflg         => FALSE
                    , language_flag => DBMS_SQL.NATIVE);


      l_dummy := DBMS_SQL.EXECUTE(l_work_cursor);

      DBMS_SQL.CLOSE_CURSOR(l_work_cursor);

   ELSIF l_status_code = 'N' THEN
      Log( 'View creation for record filter ' || p_record_filter_id
         , 'Create_RecordFilterView'
         , 'CREATE_VIEW_DBMS_SQL'
         , NULL
         , 'Error building record filter criteria WHERE clause.'
         );

      X_RETURN_CODE := l_status_code;
   ELSE

      X_RETURN_CODE := l_status_code;
   END IF;

   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR  THEN
      IF DBMS_SQL.IS_OPEN(l_work_cursor)
      THEN
         DBMS_SQL.CLOSE_CURSOR(l_work_cursor);
      END IF;
      ROLLBACK;
      X_RETURN_CODE := 'E';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      IF DBMS_SQL.IS_OPEN(l_work_cursor)
      THEN
         DBMS_SQL.CLOSE_CURSOR(l_work_cursor);
      END IF;
      ROLLBACK;
      X_RETURN_CODE := 'U';
    WHEN OTHERS THEN
      IF DBMS_SQL.IS_OPEN(l_work_cursor)
      THEN
         DBMS_SQL.CLOSE_CURSOR(l_work_cursor);
      END IF;
      ROLLBACK;
      X_RETURN_CODE := 'U';

END Create_RecordFilterView;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Drop_RecordFilterView
--  Type        : Private
--  Pre-reqs    : None
--  Function    :
--
--  Parameters  : p_record_filter_id     IN     NUMBER                       Required
--                x_return_code             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Drop_RecordFilterView
   ( p_record_filter_id      IN            NUMBER
   , x_return_code              OUT NOCOPY VARCHAR2
   )
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  l_status_code VARCHAR2(1);
  l_view_name   VARCHAR2(30);
  l_view_owner  VARCHAR2(30);
  l_ignore      NUMBER;

BEGIN

   x_return_code := FND_API.G_RET_STS_SUCCESS;

   -- DROP VIEW IEC_REC_FILTER_<id>_V

   l_view_name := 'IEC_REC_FILTER_' || p_record_filter_id || '_V';
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

   COMMIT;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR  THEN
      ROLLBACK;
      X_RETURN_CODE := 'E';
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK;
      X_RETURN_CODE := 'U';
    WHEN OTHERS THEN
      ROLLBACK;
      X_RETURN_CODE := 'U';

END Drop_RecordFilterView;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_RecordFilterView
--  Type        : Public
--  Pre-reqs    : None
--  Function    : Returns the record filter view name after verifying that the view
--                exists, creating the view if necessary.
--
--  Parameters  : p_record_filter_id        IN     NUMBER                       Required
--                p_source_type_view_name   IN     VARCHAR2                     Required
--                x_return_code                OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
FUNCTION Get_RecordFilterView
   ( p_record_filter_id         IN            NUMBER
   , p_source_type_view_name    IN            VARCHAR2
   , x_return_code                 OUT NOCOPY VARCHAR2
   )
RETURN VARCHAR2
IS
   l_view_name        VARCHAR2(500);
   l_return_code      VARCHAR2(1);
   l_view_exists      VARCHAR2(1);

BEGIN
   l_return_code      := FND_API.G_RET_STS_SUCCESS;
   l_view_exists      := 'N';
   ----------------------------------------------------------------
   -- Initialize the return code.
   ----------------------------------------------------------------
   X_RETURN_CODE := FND_API.G_RET_STS_SUCCESS;

   ----------------------------------------------------------------
   -- Create save point for this procedure.
   ----------------------------------------------------------------
   SAVEPOINT GET_RECORD_FILTER_VIEW_SP;

   l_view_name := 'IEC_REC_FILTER_' || p_record_filter_id || '_V';

   Verify_RecordFilterView ( p_record_filter_id => p_record_filter_id
                           , x_view_name => l_view_name
                           , x_view_exists => l_view_exists
                           , x_return_code => l_return_code
                           );

   IF (l_return_code = FND_API.G_RET_STS_SUCCESS AND l_view_exists = 'N')
   THEN
      Create_RecordFilterView ( p_record_filter_id => p_record_filter_id
                              , p_view_name => l_view_name
                              , p_source_type_view_name => p_source_type_view_name
                              , x_return_code => l_return_code
                              );

      IF (l_return_code <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (l_return_code = 'N')
         THEN
            l_view_name := NULL;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

   ELSIF (l_return_code <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   RETURN l_view_name;

EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK TO GET_RECORD_FILTER_VIEW_SP;
      X_RETURN_CODE := FND_API.G_RET_STS_UNEXP_ERROR;

END Get_RecordFilterView;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Get_RecordFilterSourceType
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Returns the source type view for the record filter.
--
--  Parameters  : p_record_filter_id          IN     NUMBER                       Required
--                x_source_type_view             OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Get_RecordFilterSourceType
   ( p_record_filter_id         IN            NUMBER
   , x_source_type_view            OUT NOCOPY VARCHAR2
   )
IS
   l_ignore      VARCHAR2(500);
   l_view_owner  VARCHAR2(30);

BEGIN

   -- Get source type of record filter
   BEGIN
      EXECUTE IMMEDIATE
         'SELECT B.TAG
          FROM IEC_O_RELEASE_CTLS_B A, IEC_LOOKUPS B
          WHERE A.RELEASE_CONTROL_ID = :record_filter_id
          AND B.LOOKUP_TYPE = ''IEC_SOURCE_VIEW_MAP''
          AND A.SOURCE_TYPE_CODE = B.LOOKUP_CODE'
      INTO x_source_type_view
      USING p_record_filter_id;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20999, 'Source type view not supported by Advanced Outbound.');
      WHEN OTHERS THEN
         RAISE_APPLICATION_ERROR(-20999, 'Unexpected error: ' || SQLERRM);
   END;

   l_view_owner := Get_AppsSchemaName;
   BEGIN
      EXECUTE IMMEDIATE
         'SELECT VIEW_NAME
          FROM ALL_VIEWS
          WHERE VIEW_NAME = UPPER(:source_type_view)
          AND OWNER = UPPER(:owner)'
      INTO l_ignore
      USING x_source_type_view
          , l_view_owner;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         RAISE_APPLICATION_ERROR(-20999, 'Source type view ' || x_source_type_view || ' has not been created in Oracle Marketing  Online.');
   END;

END Get_RecordFilterSourceType;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Recreate_RecordFilterView
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Recreates the record filter view, deleting it first if necessary.
--
--  Parameters  : p_record_filter_id          IN     NUMBER                       Required
--                x_record_filter_view_name      OUT VARCHAR2                     Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Recreate_RecordFilterView
   ( p_record_filter_id         IN            NUMBER
   , x_record_filter_view_name     OUT NOCOPY VARCHAR2
   )
IS
   l_source_type_view_name VARCHAR2(30);
   l_view_name             VARCHAR2(500);
   l_view_exists           VARCHAR2(1);
   l_return_code           VARCHAR2(1);

BEGIN
   l_view_exists            := 'N';
   ----------------------------------------------------------------
   -- Initialize the return code.
   ----------------------------------------------------------------
   l_return_code := FND_API.G_RET_STS_SUCCESS;

   x_record_filter_view_name := 'ERROR';

   ----------------------------------------------------------------
   -- Create save point for this procedure.
   ----------------------------------------------------------------
   SAVEPOINT RECREATE_RECORD_FILTER_VIEW_SP;

   ----------------------------------------------------------------
   -- Retrieve the source type view for the record filter.
   ----------------------------------------------------------------
   Get_RecordFilterSourceType ( p_record_filter_id
                              , l_source_type_view_name
                              );

   l_view_name := 'IEC_REC_FILTER_' || p_record_filter_id || '_V';

   ----------------------------------------------------------------
   -- Check to see if the view already exists.
   ----------------------------------------------------------------
   Verify_RecordFilterView ( p_record_filter_id => p_record_filter_id
                           , x_view_name => l_view_name
                           , x_view_exists => l_view_exists
                           , x_return_code => l_return_code
                           );

   ----------------------------------------------------------------
   -- If the view already exists then drop the view.
   ----------------------------------------------------------------
   IF (l_return_code = FND_API.G_RET_STS_SUCCESS AND l_view_exists = 'Y')
   THEN
      Drop_RecordFilterView ( p_record_filter_id => p_record_filter_id
                            , x_return_code => l_return_code);

   ELSIF (l_return_code <> FND_API.G_RET_STS_SUCCESS)
   THEN
      g_error_msg := SUBSTR( 'Verifying view for record filter: ' || p_record_filter_id
                           || ' SLQCODE: ' || SQLCODE || ':' || SQLERRM
                           , 1
                           , 2048);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   ----------------------------------------------------------------
   -- If everything was successful up to this point then we
   -- create the record filter view.
   ----------------------------------------------------------------
   IF (l_return_code = FND_API.G_RET_STS_SUCCESS)
   THEN
      Create_RecordFilterView ( p_record_filter_id => p_record_filter_id
                              , p_view_name => l_view_name
                              , p_source_type_view_name => l_source_type_view_name
                              , x_return_code => l_return_code
                              );

      IF (l_return_code <> FND_API.G_RET_STS_SUCCESS) THEN

         IF (l_return_code = 'N')
         THEN
            g_error_msg := SUBSTR( 'Creating view for record filter: ' || p_record_filter_id
                                 || ' SLQCODE: ' || SQLCODE || ':' || SQLERRM
                                 , 1
                                 , 2048);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;

      x_record_filter_view_name := l_view_name;

   ELSE
      g_error_msg := SUBSTR( 'Dropping view for record filter: ' || p_record_filter_id
                           || ' SLQCODE: ' || SQLCODE || ':' || SQLERRM
                           , 1
                           , 2048);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR
    THEN
      ROLLBACK TO RECREATE_RECORD_FILTER_VIEW_SP;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);
    WHEN OTHERS THEN
      g_error_msg := SUBSTR( 'Recreating view for record filter: ' || p_record_filter_id
                           || ' SLQCODE: ' || SQLCODE || ':' || SQLERRM
                           , 1
                           , 2048);
      ROLLBACK TO RECREATE_RECORD_FILTER_VIEW_SP;
      RAISE_APPLICATION_ERROR(-20999, g_error_msg);

END Recreate_RecordFilterView;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Apply_RecordFilter
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Applies a specified record filter to an entry
--                belonging to specified target group.
--
--  Parameters  : p_list_entry_id          IN     NUMBER         Required
--                p_list_id                IN     NUMBER         Required
--                p_returns_id             IN     NUMBER         Required
--                p_record_filter_id       IN     NUMBER         Required
--                p_source_type_view_name  IN     VARCHAR2       Required
--                x_callable_flag             OUT VARCHAR2       Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Apply_RecordFilter
   ( p_list_entry_id          IN             NUMBER
   , p_list_id                IN             NUMBER
   , p_returns_id             IN             NUMBER
   , p_record_filter_id       IN             NUMBER
   , p_source_type_view_name  IN             VARCHAR2
   , x_callable_flag             OUT  NOCOPY VARCHAR2
   )
AS
   l_return_code         VARCHAR2(1);
   l_view_name           VARCHAR2(32);

BEGIN

   x_callable_flag := 'Y';

   BEGIN
      l_view_name := Get_RecordFilterView
                     ( p_record_filter_id
                     , p_source_type_view_name
                     , l_return_code
                     );
   EXCEPTION
      -- If we have a problem getting the record filter view, then
      -- simply assume that record filter is invalid and do not apply
      WHEN OTHERS THEN
         l_view_name := NULL;
   END;

   IF l_view_name IS NOT NULL THEN
      BEGIN
         EXECUTE IMMEDIATE
            'SELECT ''N''
             FROM ' || l_view_name || '
             WHERE LIST_HEADER_ID = :list_id
             AND LIST_ENTRY_ID = :list_entry_id
             AND ROWNUM <= 1'
         INTO x_callable_flag
         USING IN p_list_id
             , IN p_list_entry_id;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            x_callable_flag := 'Y';
         WHEN OTHERS THEN
            RAISE;
      END;

      IF x_callable_flag = 'N' THEN
         iec_returns_util_pvt.Update_Entry( p_returns_id
                                          , -1
                                          , to_char(null)
                                          , to_char(null)
                                          , to_char(null)
                                          , 38
                                          , 0
                                          , 0
                                          , 'N');
      END IF;
   END IF;

EXCEPTION
   WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20999, 'Error applying record filter ' || l_view_name || ': ' || SQLERRM);

END Apply_RecordFilter;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Cancel_RecordFilter
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Remove record filter from all affected entries.
--
--  Parameters  : p_record_filter_id       IN     VARCHAR2        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Cancel_RecordFilter(p_record_filter_id IN NUMBER)
IS
   cursor c_list_rlse is
      select list_header_id from ams_list_headers_all where release_control_alg_id = p_record_filter_id;

   l_return_status VARCHAR2(1);

BEGIN

   FOR v_list_rlse IN c_list_rlse LOOP

      Make_ListEntriesAvailable
         ( v_list_rlse.list_header_id
         , 8
         , TRUE
         , l_return_status);

      IF l_return_status <> 'S' THEN
         RAISE_APPLICATION_ERROR(-20999, 'Error removing record filter ' || p_record_filter_id || ' from target group ' || v_list_rlse.list_header_id);
      END IF;

  END LOOP;

END Cancel_RecordFilter;

-----------------------------++++++-------------------------------
--
-- Start of comments
--
--  API name    : Cancel_RecordFilterForList
--  Type        : Public
--  Pre-reqs    : None
--  Procedure   : Remove record filter from specified list.
--
--  Parameters  : p_list_header_id         IN     NUMBER        Required
--
--  Version     : Initial version 1.0
--
-- End of comments
--
-----------------------------++++++-------------------------------
PROCEDURE Cancel_RecordFilterForList(p_list_header_id IN NUMBER)
IS
   l_return_status VARCHAR2(1);

BEGIN

      Make_ListEntriesAvailable
         ( p_list_header_id
         , 8
         , TRUE
         , l_return_status);

      IF l_return_status <> 'S' THEN
         RAISE_APPLICATION_ERROR(-20999, 'Error removing record filter from target group ' || p_list_header_id);
      END IF;

END Cancel_RecordFilterForList;

END IEC_RECORD_FILTER_PVT;

/
