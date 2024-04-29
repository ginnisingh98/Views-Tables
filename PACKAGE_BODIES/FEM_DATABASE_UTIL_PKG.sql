--------------------------------------------------------
--  DDL for Package Body FEM_DATABASE_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_DATABASE_UTIL_PKG" AS
-- $Header: fem_db_utl.plb 120.6 2007/02/20 03:10:48 gcheng ship $

/***************************************************************************
                    Copyright (c) 2005 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
  FILENAME
    fem_db_utl.plb

  DESCRIPTION
    FEM Database Utilities Package

  HISTORY
    Tim Moore    14-Oct-2003   Original script
    Tim Moore    31-Aug-2004   Added Validate_Table_Columns
    Greg Hall    23-May-2005   Bug# 4301983: Added procedures for managing
                               temporary tables, indexes, and views.
    Greg Hall    21-Jun-2005   Bug# 4445212: Added calls to Get_PB_Param_Value
                               for data-driven tablespace and storage parameters.
    Greg Hall    13-Jul-2005   Bug# 4491889:  Fixed bug in the Exec procedure.
    Greg Hall    19-Jul-2006   Bug# 5146586: Fixed bug that prevented logging
                               of the SQL error message to FEM_DDL_LOG for
                               failed SQL statements.
    Greg Hall    19-Jul-2006   Bug# 5212287:  for all four temp object
                               procedures, added Oracle error message into
                               the error message that is returned on the message
                               stack when a dynamic DDL statement fails.
    Gordon Cheng 19-Feb-2007   Bug 5873766: Added p_pb_object_id
                 v120.6        parameter to the following procedures:
                                 Create_Temp_Table
                                 Create_Temp_Index
                                 Create_Temp_View
                                 Drop_Temp_DB_Objects
 **************************************************************************/

---------------------------------------
-- Declare Private Package Variables --
---------------------------------------

c_log_level_1  CONSTANT  NUMBER  := fnd_log.level_statement;
c_log_level_2  CONSTANT  NUMBER  := fnd_log.level_procedure;
c_log_level_3  CONSTANT  NUMBER  := fnd_log.level_event;
c_log_level_4  CONSTANT  NUMBER  := fnd_log.level_exception;
c_log_level_5  CONSTANT  NUMBER  := fnd_log.level_error;
c_log_level_6  CONSTANT  NUMBER  := fnd_log.level_unexpected;

c_user_id      CONSTANT NUMBER := FND_GLOBAL.User_ID;
c_login_id     CONSTANT NUMBER := FND_GLOBAL.Login_Id;


/***************************************************************************
 ===========================================================================
                              Private Procedures
 ===========================================================================
 ***************************************************************************/


/****************************************************************************/
PROCEDURE Validate_OA_Params (p_api_version     IN NUMBER,
                              p_init_msg_list   IN VARCHAR2,
                              p_commit          IN VARCHAR2,
                              p_encoded         IN VARCHAR2,
                              x_return_status   OUT NOCOPY VARCHAR2) IS
-- ==========================================================================
-- DESCRIPTION
--    Validates the OA input parameters for other procedures in this package.
-- Parameters:
--      See description of other OA-compliant procedures having these same
--      parameters for a description of the IN parameters.
--    x_return_status:
--      Returns the value from FND_API.G_RET_STS_ERROR ('E') if there are
--      any parameter validation errors.
-- HISTORY
--    Greg Hall     23-May-2005   Bug# 4301983: copied from
--                                FEM_DIMENSION_UTIL_PKG.
-- ==========================================================================

   e_bad_p_api_ver         EXCEPTION;
   e_bad_p_init_msg_list   EXCEPTION;
   e_bad_p_commit          EXCEPTION;
   e_bad_p_encoded         EXCEPTION;

BEGIN

   x_return_status := c_success;

   CASE p_api_version
      WHEN c_api_version THEN NULL;
      ELSE RAISE e_bad_p_api_ver;
   END CASE;

   CASE p_init_msg_list
      WHEN c_false THEN NULL;
      WHEN c_true THEN
         FND_MSG_PUB.Initialize;
      ELSE RAISE e_bad_p_init_msg_list;
   END CASE;

   CASE p_encoded
      WHEN c_false THEN NULL;
      WHEN c_true THEN NULL;
      ELSE RAISE e_bad_p_encoded;
   END CASE;

   CASE p_commit
      WHEN c_false THEN NULL;
      WHEN c_true THEN NULL;
      ELSE RAISE e_bad_p_commit;
   END CASE;

EXCEPTION
   WHEN e_bad_p_api_ver THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_api_version);
      x_return_status := c_error;

   WHEN e_bad_p_init_msg_list THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_INIT_MSG_LIST_ERR');
      x_return_status := c_error;

   WHEN e_bad_p_encoded THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_ENCODED_ERR');
      x_return_status := c_error;

   WHEN e_bad_p_commit THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_COMMIT_ERR');
      x_return_status := c_error;

END Validate_OA_Params;


/****************************************************************************/
PROCEDURE exec (p_request_id  IN NUMBER,
                p_object_id   IN NUMBER,
                p_proc_name   IN VARCHAR2,
                p_command     IN VARCHAR2,
                p_ddl_logging IN VARCHAR2  DEFAULT 'OFF') IS
-- ==========================================================================
-- DESCRIPTION
--    Executes the DDL SQL statement passed to it, using EXECUTE IMMEDIATE.
--    It logs the DDL operation in the Apps debug log.
--    If the FEM Process Behavior parameter setting that is in effect for
--    p_object_id = 'ON' then tt logs the DDL operation into FEM_DDL_LOG.
--    Note that since DDL statements perform an implicit COMMIT, there is no
--    point in trying to honor the p_commit parameter received by any of the
--    calling procedures, so this procedure doesn't even bother taking it,
--    and all inserts into FEM_DDL_LOG are commited.
--    If the DDL statement fails, the error is re-raised, to be trapped by the
--    calling program.
--    This procedure should only be used for executing DDL or other SQL that
--    must be built "on-the-fly".  All other SQL statements should be executed
--    directly or in a declared cursor.
-- PARAMETERS
--    The SQL statement in p_command is executed. All other parameters are
--    used for logging the DDL operation in FEM_DDL_LOG.
-- HISTORY
--    Greg Hall     23-May-2005   Bug# 4301983: created.
--    Greg Hall     13-Jul-2005   Bug# 4491889: moved SUBSTR function outside
--                                of the INSERT commands, into a separate
--                                PL/SQL assignment statement, to avoid an
--                                error when p_command > 4000 char. Also
--                                moved Debug log calls ahead of DDL log
--                                inserts, in case the latter fails it won't
--                                prevent the former, and added error handlers
--                                for DDL log insert statements.
--    Greg Hall     19-Jul-2006   Bug# 5146586: fixed bug that prevented logging
--                                of the SQL error message to FEM_DDL_LOG for
--                                failed SQL statements.
-- ==========================================================================

   v_command_short   VARCHAR2(4000);
   v_sqlerrm         VARCHAR2(255);

BEGIN

   v_command_short := SUBSTR(p_command, 1, 3980);

   EXECUTE IMMEDIATE p_command;

-- Log to Debug Log

   FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => c_log_level_1,
      p_module   => 'fem.plsql.fem_database_util_pkg.' || lower(p_proc_name) || '.exec',
      p_msg_text => 'SUCCESSFUL DDL: ' || v_command_short );

   COMMIT;

-- Log to DDL Log

   IF p_ddl_logging = 'ON' THEN

      BEGIN

         INSERT into fem_ddl_log
           (request_id,
            object_id,
            exec_seq,
            timestamp,
            procedure_name,
            status,
            sql_error_msg,
            sql_statement,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login)
         VALUES
           (p_request_id,
            p_object_id,
            fem_ddl_log_s.nextval,
            TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'),
            p_proc_name,
            'S',
            NULL,
            v_command_short,
            c_user_id,
            SYSDATE,
            c_user_id,
            SYSDATE,
            c_login_id);

      EXCEPTION
         WHEN OTHERS THEN

            v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

         -- Log to Debug Log

            FEM_ENGINES_PKG.TECH_MESSAGE(
               p_severity => c_log_level_5,
               p_module   => 'fem.plsql.fem_database_util_pkg.' || lower(p_proc_name) || '.exec',
               p_msg_text => v_sqlerrm );

      END;

      COMMIT;

   END IF;

EXCEPTION
   WHEN OTHERS THEN

      v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

   -- Log to Debug Log

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => c_log_level_5,
         p_module   => 'fem.plsql.fem_database_util_pkg.' || lower(p_proc_name) || '.exec',
         p_msg_text => 'FAILED DDL: ' || v_command_short );

      FEM_ENGINES_PKG.TECH_MESSAGE(
         p_severity => c_log_level_5,
         p_module   => 'fem.plsql.fem_database_util_pkg.' || lower(p_proc_name) || '.exec',
         p_msg_text => v_sqlerrm );

      COMMIT;

   -- Log to DDL Log

      IF p_ddl_logging = 'ON' THEN

         BEGIN

            INSERT into fem_ddl_log
              (request_id,
               object_id,
               exec_seq,
               timestamp,
               procedure_name,
               status,
               sql_error_msg,
               sql_statement,
               created_by,
               creation_date,
               last_updated_by,
               last_update_date,
               last_update_login)
            VALUES
              (p_request_id,
               p_object_id,
               fem_ddl_log_s.nextval,
               TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'),
               p_proc_name,
               'F',
               v_sqlerrm,
               v_command_short,
               c_user_id,
               SYSDATE,
               c_user_id,
               SYSDATE,
               c_login_id);

         EXCEPTION
            WHEN OTHERS THEN

               v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

            -- Log to Debug Log

               FEM_ENGINES_PKG.TECH_MESSAGE(
                  p_severity => c_log_level_5,
                  p_module   => 'fem.plsql.fem_database_util_pkg.' || lower(p_proc_name) || '.exec',
                  p_msg_text => v_sqlerrm );

         END;

         COMMIT;

      END IF;

      RAISE;

END exec;


/***************************************************************************
 ===========================================================================
                              Public Procedures
 ===========================================================================
 ***************************************************************************/


/***************************************************************************/
PROCEDURE Get_Table_Owner (
            p_api_version     IN         NUMBER     DEFAULT c_api_version,
            p_init_msg_list   IN         VARCHAR2   DEFAULT c_false,
            p_commit          IN         VARCHAR2   DEFAULT c_false,
            p_encoded         IN         VARCHAR2   DEFAULT c_true,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_syn_name        IN         VARCHAR2,
            x_tab_name        OUT NOCOPY VARCHAR2,
            x_tab_owner       OUT NOCOPY VARCHAR2 ) IS
-- =========================================================================
-- Returns the table name and table owner for a specified synonym.
-- =========================================================================

BEGIN

   x_return_status := c_success;

   ---------------------------------
   -- Get table name and table owner
   ---------------------------------

   SELECT table_name,table_owner
   INTO x_tab_name,x_tab_owner
   FROM user_synonyms
   WHERE synonym_name = p_syn_name;

EXCEPTION

   WHEN no_data_found THEN
      FEM_ENGINES_PKG.Put_Message(
        p_app_name => 'FEM',
        p_msg_name => 'FEM_DB_BAD_SYNONYM_ERR',
        p_token1 => 'SYN_NAME',
        p_value1 => p_syn_name);

      FND_MSG_PUB.Count_and_Get(
        p_encoded => p_encoded,
        p_count => x_msg_count,
        p_data => x_msg_data);

      x_return_status := c_error;

END Get_Table_Owner;


/**************************************************************************/
PROCEDURE Get_Unique_Temp_Name (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_false,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_temp_type        IN         VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_table_seq        IN         NUMBER     DEFAULT NULL,
   p_index_seq        IN         NUMBER     DEFAULT NULL,
   x_temp_name        OUT NOCOPY VARCHAR2) IS
-- ===========================================================================
-- DESCRIPTION
--    Returns a table name, view name, or index
--    name that is guaranteed to be unique within the FEM schema, for
--    creating a temporary object.  The object name returned is of the form:
--     FEM_{p_request_id}_{p_object_id}_[p_table_seq]_{T|V}_[p_index_seq]
--  Parameters:
--    p_api_version:
--       Optional OA-compliance parameter.
--       Default is 1.0 (and this is currently the only acceptable value).
--    p_init_msg_list
--       Optional OA-compliance flag parameter.
--       Tells whether or not to initialize the FND_MSG_PUB message stack by
--       calling FND_MSG_PUB.Initialize.
--       Valid values are 'T' and 'F'; default is 'F'.
--    p_commit:
--       Optional OA-compliance flag parameter.  Valid values are 'T' and 'F'.
--       Note that this procedure is read-only, there is nothing to commit,
--       so this parameter is not used.
--    p_encoded:
--       Optional OA-compliance flag parameter.
--       Passed to FND_MSG_PUB.Count_and_Get to determine the format of any
--       message passed back in x_msg_data.
--       Valid values are 'T' and 'F'; default is 'T'.
--    x_return_status:
--       OA-compliance OUT parameter.  This procedure returns 'S' for
--       success, 'E' for error in any of the values passed to the optional
--       OA parameters.
--    x_msg_count:
--       OA-compliance OUT parameter.  Tells how many messages are waiting
--       on the FND_MSG_PUB message stack.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    x_msg_data:
--       OA-compliance OUT parameter.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    p_temp_type:
--       Required. Specifies the type of temporary database object for which a
--       unique name is requested. Valid values are 'TABLE', 'VIEW', 'INDEX'.
--    p_request_id:
--       The concurrent manager REQUEST_ID of the calling
--       process. Required for all values of p_temp_type.
--    p_object_id:
--       The FEM OBJECT_ID identifying the executable rule
--       for which the temporary table, view, or index
--       will be created. Required for all values of
--       p_temp_type.
--    p_table_seq:
--       Provides uniqueness for creation of up to 100
--       tables per REQUEST_ID/OBJECT_ID combination.
--       Required (for all values of p_temp_type) if multiple
--       tables or views are being created for the same
--       REQUEST_ID/OBJECT_ID combination.  Valid values
--       are 0-99.
--    p_index_seq:
--       Provides uniqueness for creation of up to 10
--       indexes per table. Required when p_temp_type =
--       'INDEX'. Valid values are 0-9.
--    x_temp_name:
--       Returns the temporary DB object name built by the procedure.
-- HISTORY
--    Greg Hall     23-May-2005   Bug# 4301983: created.
-- ===========================================================================

   v_request_id      VARCHAR2(38);
   v_object_id       VARCHAR2(38);
   v_table_seq       VARCHAR2(38);
   v_index_seq       VARCHAR2(38);
   v_length          NUMBER(2);
   v_start           NUMBER(2);
   v_unique_name     VARCHAR2(30);

BEGIN

-- Validate OA parameters

   x_return_status := c_success;

   Validate_OA_Params (
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_encoded => p_encoded,
      x_return_status => x_return_status);

   IF (x_return_status <> c_success)
   THEN
      FND_MSG_PUB.Count_and_Get(
         p_encoded => c_false,
         p_count => x_msg_count,
         p_data => x_msg_data);
      RETURN;
   END IF;

-- Build Request ID string; limit it to the 10 least significant digits

   v_request_id := LTRIM(TO_CHAR(p_request_id), ' -');
   v_length := LENGTH(v_request_id);

   IF v_length > 11 THEN
      v_start := v_length - 9;
      v_request_id := SUBSTR(v_request_id, v_start);
   END IF;

   v_request_id := v_request_id || '_';

-- Build Object ID string; limit it to the 8 least significant digits

   v_object_id := LTRIM(TO_CHAR(p_object_id), ' -');
   v_length := LENGTH(v_object_id);

   IF v_length > 8 THEN
      v_start := v_length - 7;
      v_object_id := SUBSTR(v_object_id, v_start);
   END IF;

   v_object_id := v_object_id || '_';

-- Build Table Sequence string; limit it to the 2 least significant digits

   IF p_table_seq IS NOT NULL THEN

      v_table_seq := LTRIM(TO_CHAR(p_table_seq), ' -');
      v_length := LENGTH(v_table_seq);

      IF v_length > 2 THEN
         v_start := v_length - 1;
         v_table_seq := SUBSTR(v_table_seq, v_start);
      END IF;

      v_table_seq := v_table_seq || '_';

   END IF;

-- Build Index Sequence string; limit it to the 1 least significant digit

   IF p_index_seq IS NOT NULL THEN

      v_index_seq := LTRIM(TO_CHAR(p_index_seq), ' -');
      v_length := LENGTH(v_index_seq);

      IF v_length > 1 THEN
         v_start := v_length;
         v_index_seq := SUBSTR(v_index_seq, v_start);
      END IF;

      v_index_seq := '_' || v_index_seq;

   END IF;

-- Build unique name

   v_unique_name := 'FEM_' || v_request_id || v_object_id || v_table_seq;

   IF p_temp_type in ('TABLE', 'INDEX') THEN

      v_unique_name := v_unique_name || 'T';

      IF p_temp_type = 'INDEX' THEN
         v_unique_name := v_unique_name || v_index_seq;
      END IF;

   ELSIF p_temp_type = 'VIEW' THEN
      v_unique_name := v_unique_name || 'V';
   ELSE
      NULL;  -- Log Invalid p_temp_type debug warning HERE
   END IF;

   x_temp_name := v_unique_name;

   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

END Get_Unique_Temp_Name;


/**************************************************************************/
PROCEDURE Create_Temp_Table (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_table_name       IN         VARCHAR2,
   p_table_def        IN         VARCHAR2,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL') IS
-- ===========================================================================
-- DESCRIPTION
--    Creates a conventional table in the FEM schema, according to the
--    definition passed in p_table_def.
--    TABLESPACE, INITIAL_EXTENT, and NEXT_EXTENT are queried by the procedure
--    from the process parameters 'TEMP_TABLE_TABLESPACE', 'TEMP_TABLE_INIT_EXTENT'
--    and 'TEMP_TABLE_NEXT_EXTENT', as set in the Admin=>Tuning Options UI.
--    Tables created by this procedure are expected to be temporary, i.e.
--    to be dropped by a call to Drop_Temp_DB_Objects before the end of the
--    concurrent process.
--    A synonym for the table is created in the APPS schema. The table is
--    logged by REQUEST_ID and OBJECT_ID in FEM_PL_TEMP_OBJECTS, so that it
--    can be undone by the Undo engine in case of failure.  All DDL, including
--    synonym creation, is logged in FEM_DDL_LOG. This logging can be toggled
--    on/off by the process parameter 'DDL_LOGGING' in Admin=>Tuning Options.
--  Parameters:
--    p_api_version:
--       Optional OA-compliance parameter.
--       Default is 1.0 (and this is currently the only acceptable value).
--    p_init_msg_list
--       Optional OA-compliance flag parameter.
--       Tells whether or not to initialize the FND_MSG_PUB message stack by
--       calling FND_MSG_PUB.Initialize.
--       Valid values are 'T' and 'F'; default is 'F'.
--    p_commit:
--       Optional OA-compliance flag parameter.  Valid values are 'T' and 'F'.
--       Note that since DDL operations, such as creating a table, index,
--       or view, always do an implicit COMMIT, this parameter cannot be
--       honored by this procedure: it will always commit.
--    p_encoded:
--       Optional OA-compliance flag parameter.
--       Passed to FND_MSG_PUB.Count_and_Get to determine the format of any
--       message passed back in x_msg_data.
--       Valid values are 'T' and 'F'; default is 'T'.
--    x_return_status:
--       OA-compliance OUT parameter.  This procedure returns 'S' for
--       success, 'E' for error in any of the values passed to the optional
--       OA parameters, and 'U' for unexpected errors, e.g. if the DDL
--       statement fails.
--    x_msg_count:
--       OA-compliance OUT parameter.  Tells how many messages are waiting
--       on the FND_MSG_PUB message stack.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    x_msg_data:
--       OA-compliance OUT parameter.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    p_request_id:
--       The concurrent manager REQUEST_ID of the calling process.
--    p_object_id:
--       The FEM OBJECT_ID identifying the executable rule for which the
--       temporary table is being created.
--    p_pb_object_id:
--       Optional parameter that specifies the FEM OBJECT_ID that this
--       procedure will use to determine the Process Behavior parameters.
--       If this parameter is NULL, this procedure will rely on
--       "p_object_id" parameter to determine the PB params.
--    p_table_name:
--       The name of the table. Use the Get_Unique_Temp_Name procedure to get
--       a unique table name.
--    p_table_def:
--       This is the columns definition of the table.  It is the DDL statement
--       for creating the table, minus the CREATE TABLE key words, the table
--       name, and the physical properties. It can be specified either in
--       column definition format, or in AS SELECT format, as illustrated:
--          Column Definiton format example:
--             (COL1 NUMBER NOT NULL, COL2 VARCHAR2(30), COL3 DATE)
--          AS SELECT format example:
--             AS SELECT col1,col2,col3 FROM copy_table WHERE col2='ABC'
--       The SELECT statement for the AS SELECT format can be a complex
--       statement including joins, subqueries, etc.
--       This parameter can be up to 32000 characters long.
--    p_step_name:
--       Optional parameter for specifying the engine step, used in looking up
--       process behavior parameters for DDL Logging, tablespaces, and initial
--       and next extents.  Default value is 'ALL'.
-- HISTORY
--    Greg Hall     23-May-2005   Bug# 4301983: created.
-- ===========================================================================

   v_pb_object_type   VARCHAR2(30);
   v_pb_object_id     FEM_OBJECT_CATALOG_B.object_id%TYPE;
   v_param_data_type  VARCHAR2(6);
   v_ddl_logging      VARCHAR2(3);
   v_initial_extent   VARCHAR2(30);
   v_next_extent      VARCHAR2(30);
   v_tablespace       VARCHAR2(30);
   v_physical_clause  VARCHAR2(300);
   v_sql_statement    VARCHAR2(32767);
   v_sqlerrm          VARCHAR2(255);

   v_fnd_schema       VARCHAR2(30); -- the schema name returned by the
                                    -- FND_INSTALLATION.Get_App_Info function.
-- Also required for the FND_INSTALLATION.Get_App_Info function, but the return
-- values are not actually used.
   v_fnd_status       VARCHAR2(100);
   v_fnd_industry     VARCHAR2(100);

BEGIN

-- Validate OA parameters

   x_return_status := c_success;

   Validate_OA_Params (
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_encoded => p_encoded,
      x_return_status => x_return_status);

   IF (x_return_status <> c_success)
   THEN
      FND_MSG_PUB.Count_and_Get(
         p_encoded => c_false,
         p_count => x_msg_count,
         p_data => x_msg_data);
      RETURN;
   END IF;

-- Get DDL_LOGGING parameter value

   -- Set Process Behavior object id to "p_object_id" if
   -- "p_pb_object_id" was not provided.
   v_pb_object_id := nvl(p_pb_object_id, p_object_id);

   SELECT object_type_code
   INTO v_pb_object_type
   FROM fem_object_catalog_b
   WHERE object_id = v_pb_object_id;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'DDL_LOGGING',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_ddl_logging);

   IF v_ddl_logging IS NULL THEN
      v_ddl_logging := 'OFF';
   END IF;

-- Get tablespace, initial extent, and next extent parameter values

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'TEMP_TABLE_TABLESPACE',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_tablespace);

   IF v_tablespace IS NULL THEN
      SELECT default_tablespace
      INTO v_tablespace
      FROM user_users
      WHERE username = USER;
   END IF;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'TEMP_TABLE_INIT_EXTENT',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_initial_extent);

   IF v_initial_extent IS NULL THEN
      SELECT initial_extent
      INTO v_initial_extent
      FROM user_tablespaces
      WHERE tablespace_name = v_tablespace;
   END IF;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'TEMP_TABLE_NEXT_EXTENT',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_next_extent);

   IF v_next_extent IS NULL THEN
      SELECT next_extent
      INTO v_next_extent
      FROM user_tablespaces
      WHERE tablespace_name = v_tablespace;
   END IF;

-- Complete the storage parameters clause later
   v_physical_clause := ' TABLESPACE ' || v_tablespace ||
                        ' STORAGE ' ||
                        '(INITIAL ' || v_initial_extent ||
                        ' NEXT '    || v_next_extent ||
                        ' MINEXTENTS 1 MAXEXTENTS UNLIMITED' ||
                        ' PCTINCREASE 0)' ||
                        ' INITRANS 10 MAXTRANS 255 PCTFREE 10 ';

-- Get the schema name for the FEM application
   IF FND_INSTALLATION.Get_App_Info (
         APPLICATION_SHORT_NAME => 'FEM',
         STATUS        => v_fnd_status,
         INDUSTRY      => v_fnd_industry,
         ORACLE_SCHEMA => v_fnd_schema) THEN
      NULL;
   ELSE
      v_fnd_schema := 'FEM';
   END IF;

   IF INSTR(UPPER(p_table_def), 'AS SELECT') > 0 THEN

   -- p_table_def is specified using the AS SELECT format
      v_sql_statement := 'CREATE TABLE ' || v_fnd_schema || '.' ||
                         p_table_name ||
                         v_physical_clause || p_table_def;
   ELSE

   -- p_table_def is specified using the column definition format
      v_sql_statement := 'CREATE TABLE ' || v_fnd_schema || '.' ||
                         p_table_name || ' ' ||
                         p_table_def || v_physical_clause;
   END IF;

   BEGIN
      exec(p_request_id, p_object_id, 'CREATE_TEMP_TABLE', v_sql_statement, v_ddl_logging);
   EXCEPTION
      WHEN OTHERS THEN
      -- Put user error message on the FND_MSG_PUB stack
      -- "Failed to create temporary table: TABLE_NAME"

         v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_CREATE_TEMP_TABLE_FAILURE',
            p_token1 => 'ORACLE_ERROR_MSG',
            p_value1 => v_sqlerrm,
            p_token2 => 'TABLE_NAME',
            p_value2 => p_table_name);
         RAISE;
   END;

-- Log table in FEM_PL_TEMP_OBJECTS

   BEGIN
      INSERT INTO fem_pl_temp_objects
        (request_id,
         object_id,
         object_type,
         object_name,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login)
      VALUES
        (p_request_id,
         p_object_id,
         'TABLE',
         p_table_name,
         c_user_id,
         SYSDATE,
         c_user_id,
         SYSDATE,
         c_login_id);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE fem_pl_temp_objects
         SET created_by        = c_user_id,
             creation_date     = SYSDATE,
             last_updated_by   = c_user_id,
             last_update_date  = SYSDATE,
             last_update_login = c_login_id
         WHERE request_id  = p_request_id
           AND object_id   = p_object_id
           AND object_type = 'TABLE'
           AND object_name = p_table_name;
   END;

   COMMIT;

-- Create APPS synonym for the new FEM table.

   v_sql_statement := 'CREATE SYNONYM ' || p_table_name || ' FOR ' ||
                      v_fnd_schema || '.' || p_table_name;

   BEGIN
      exec(p_request_id, p_object_id, 'CREATE_TEMP_TABLE', v_sql_statement, v_ddl_logging);
   EXCEPTION
      WHEN OTHERS THEN
      -- Put user error message on the FND_MSG_PUB stack
      -- "Failed to create synonym for temporary table: TABLE_NAME"

         v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_CREATE_TEMP_SYN_FAILURE',
            p_token1 => 'ORACLE_ERROR_MSG',
            p_value1 => v_sqlerrm,
            p_token2 => 'TABLE_NAME',
            p_value2 => p_table_name);
         RAISE;
   END;

   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_unexp;

END Create_Temp_Table;


/**************************************************************************/
PROCEDURE Create_Temp_Index (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_table_name       IN         VARCHAR2,
   p_index_name       IN         VARCHAR2,
   p_index_columns    IN         VARCHAR2,
   p_unique_flag      IN         VARCHAR2,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL') IS
-- ===========================================================================
-- DESCRIPTION
--    Creates an index in the FEM schema, on the table specified in
--    p_table_name, on the columns specified in p_index_columns.
--    Tablespace, INITIAL_EXTENT, and NEXT_EXTENT are queried by the procedure
--    from the process parameters 'TEMP_INDEX_TABLESPACE', 'TEMP_INDEX_INIT_EXTENT'
--    and 'TEMP_INDEX_NEXT_EXTENT', as set in the Admin=>Tuning Options UI.
--    Indexes created by this procedure are expected to be temporary, i.e.
--    to be dropped by a call to Drop_Temp_DB_Objects before the end of the
--    concurrent process.
--    The index is logged by REQUEST_ID and OBJECT_ID in FEM_PL_TEMP_OBJECTS,
--    so that it can be undone by the Undo engine in case of failure.  All DDL
--    is logged in FEM_DDL_LOG. This logging can be toggled on/off by the
--    process parameter 'DDL_LOGGING' in Admin=>Tuning Options.
--  Parameters:
--    p_api_version:
--       Optional OA-compliance parameter.
--       Default is 1.0 (and this is currently the only acceptable value).
--    p_init_msg_list
--       Optional OA-compliance flag parameter.
--       Tells whether or not to initialize the FND_MSG_PUB message stack by
--       calling FND_MSG_PUB.Initialize.
--       Valid values are 'T' and 'F'; default is 'F'.
--    p_commit:
--       Optional OA-compliance flag parameter.  Valid values are 'T' and 'F'.
--       Note that since DDL operations, such as creating a table, index,
--       or view, always do an implicit COMMIT, this parameter cannot be
--       honored by this procedure: it will always commit.
--    p_encoded:
--       Optional OA-compliance flag parameter.
--       Passed to FND_MSG_PUB.Count_and_Get to determine the format of any
--       message passed back in x_msg_data.
--       Valid values are 'T' and 'F'; default is 'T'.
--    x_return_status:
--       OA-compliance OUT parameter.  This procedure returns 'S' for
--       success, 'E' for error in any of the values passed to the optional
--       OA parameters, and 'U' for unexpected errors, e.g. if the DDL
--       statement fails.
--    x_msg_count:
--       OA-compliance OUT parameter.  Tells how many messages are waiting
--       on the FND_MSG_PUB message stack.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    x_msg_data:
--       OA-compliance OUT parameter.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    p_request_id:
--       The concurrent manager REQUEST_ID of the calling process.
--    p_object_id:
--       The FEM OBJECT_ID identifying the executable rule for which the
--       temporary index is being created.
--    p_pb_object_id:
--       Optional parameter that specifies the FEM OBJECT_ID that this
--       procedure will use to determine the Process Behavior parameters.
--       If this parameter is NULL, this procedure will rely on
--       "p_object_id" parameter to determine the PB params.
--    p_table_name:
--       The name of the table to create the index on.
--    p_index_name:
--       The name of the index. Use the Get_Unique_Temp_Name procedure to get
--       a unique index name that is based on the name of the table that the
--       index is for.
--    p_index_columns:
--       A comma-separated list of the columns to be indexed.
--    p_unique_flag:
--       'Y' means create a unique index; 'N' means create a non-unique index.
--    p_step_name:
--       Optional parameter for specifying the engine step, used in looking up
--       process behavior parameters for DDL Logging, tablespaces, and initial
--       and next extents.  Default value is 'ALL'.
-- HISTORY
--    Greg Hall     27-May-2005   Bug# 4301983: created.
-- ===========================================================================

   v_pb_object_type   VARCHAR2(30);
   v_pb_object_id     FEM_OBJECT_CATALOG_B.object_id%TYPE;
   v_param_data_type  VARCHAR2(6);
   v_ddl_logging      VARCHAR2(3);
   v_initial_extent   VARCHAR2(30);
   v_next_extent      VARCHAR2(30);
   v_tablespace       VARCHAR2(30);
   v_unique           VARCHAR2(7);
   v_physical_clause  VARCHAR2(300);
   v_sql_statement    VARCHAR2(32767);
   v_sqlerrm          VARCHAR2(255);

   v_fnd_schema       VARCHAR2(30); -- the schema name returned by the
                                    -- FND_INSTALLATION.Get_App_Info function.
-- Also required for the FND_INSTALLATION.Get_App_Info function, but the return
-- values are not actually used.
   v_fnd_status       VARCHAR2(100);
   v_fnd_industry     VARCHAR2(100);

BEGIN

-- Validate OA parameters

   x_return_status := c_success;

   Validate_OA_Params (
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_encoded => p_encoded,
      x_return_status => x_return_status);

   IF (x_return_status <> c_success)
   THEN
      FND_MSG_PUB.Count_and_Get(
         p_encoded => c_false,
         p_count => x_msg_count,
         p_data => x_msg_data);
      RETURN;
   END IF;

   -- Set Process Behavior object id to "p_object_id" if
   -- "p_pb_object_id" was not provided.
   v_pb_object_id := nvl(p_pb_object_id, p_object_id);

   SELECT object_type_code
   INTO v_pb_object_type
   FROM fem_object_catalog_b
   WHERE object_id = v_pb_object_id;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'DDL_LOGGING',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_ddl_logging);

   IF v_ddl_logging IS NULL THEN
      v_ddl_logging := 'OFF';
   END IF;

-- Get tablespace, initial extent, and next extent parameter values

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'TEMP_INDEX_TABLESPACE',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_tablespace);

   IF v_tablespace IS NULL THEN
      SELECT default_tablespace
      INTO v_tablespace
      FROM user_users
      WHERE username = USER;
   END IF;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'TEMP_INDEX_INIT_EXTENT',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_initial_extent);

   IF v_initial_extent IS NULL THEN
      SELECT initial_extent
      INTO v_initial_extent
      FROM user_tablespaces
      WHERE tablespace_name = v_tablespace;
   END IF;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'TEMP_INDEX_NEXT_EXTENT',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_next_extent);

   IF v_next_extent IS NULL THEN
      SELECT next_extent
      INTO v_next_extent
      FROM user_tablespaces
      WHERE tablespace_name = v_tablespace;
   END IF;

-- Complete the storage parameters clause
   v_physical_clause := ' TABLESPACE ' || v_tablespace ||
                        ' STORAGE ' ||
                        '(INITIAL ' || v_initial_extent ||
                        ' NEXT '    || v_next_extent ||
                        ' MINEXTENTS 1 MAXEXTENTS UNLIMITED' ||
                        ' PCTINCREASE 0)' ||
                        ' INITRANS 10 MAXTRANS 255 PCTFREE 10 ';

   IF p_unique_flag = 'Y' THEN
      v_unique := 'UNIQUE ';
   ELSE
      v_unique := '';
   END IF;

-- Get the schema name for the FEM application
   IF FND_INSTALLATION.Get_App_Info (
         APPLICATION_SHORT_NAME => 'FEM',
         STATUS        => v_fnd_status,
         INDUSTRY      => v_fnd_industry,
         ORACLE_SCHEMA => v_fnd_schema) THEN
      NULL;
   ELSE
      v_fnd_schema := 'FEM';
   END IF;

   v_sql_statement := 'CREATE ' || v_unique || 'INDEX ' || v_fnd_schema || '.' ||
                       p_index_name || ' ON ' || p_table_name ||
                       ' (' || p_index_columns || ') ' ||
                      v_physical_clause;

   BEGIN
      exec(p_request_id, p_object_id, 'CREATE_TEMP_INDEX', v_sql_statement, v_ddl_logging);
   EXCEPTION
      WHEN OTHERS THEN
      -- Put user error message on the FND_MSG_PUB stack
      -- "Failed to create temporary index: INDEX_NAME on table: TABLE_NAME"

         v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_CREATE_TEMP_INDEX_FAILURE',
            p_token1 => 'ORACLE_ERROR_MSG',
            p_value1 => v_sqlerrm,
            p_token2 => 'INDEX_NAME',
            p_value2 => p_index_name,
            p_token3 => 'TABLE_NAME',
            p_value3 => p_table_name);
         RAISE;
   END;

-- Log index in FEM_PL_TEMP_OBJECTS

   BEGIN
      INSERT INTO fem_pl_temp_objects
        (request_id,
         object_id,
         object_type,
         object_name,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login)
      VALUES
        (p_request_id,
         p_object_id,
         'INDEX',
         p_index_name,
         c_user_id,
         SYSDATE,
         c_user_id,
         SYSDATE,
         c_login_id);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE fem_pl_temp_objects
         SET created_by        = c_user_id,
             creation_date     = SYSDATE,
             last_updated_by   = c_user_id,
             last_update_date  = SYSDATE,
             last_update_login = c_login_id
         WHERE request_id = p_request_id
           AND object_id  = p_object_id
           AND object_type = 'INDEX'
           AND object_name = p_index_name;
   END;

   COMMIT;

   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_unexp;

END Create_Temp_Index;


/**************************************************************************/
PROCEDURE Create_Temp_View (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_view_name        IN         VARCHAR2,
   p_view_def         IN         VARCHAR2,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL') IS
-- ===========================================================================
-- DESCRIPTION
--    Creates a view in the APPS schema, according to the view definition in
--    p_view_def. Views created by this procedure are expected to be temporary,
--    i.e. to be dropped by a call to Drop_Temp_DB_Objects before the end of the
--    concurrent process. The view is logged by REQUEST_ID and OBJECT_ID in
--    FEM_PL_TEMP_OBJECTS, so that it can be undone by the Undo engine in case
--    of failure.  All DDL is logged in FEM_DDL_LOG. This logging can be toggled
--    on/off by the process parameter 'DDL_LOGGING' in Admin=>Tuning Options.
--  Parameters:
--    p_api_version:
--       Optional OA-compliance parameter.
--       Default is 1.0 (and this is currently the only acceptable value).
--    p_init_msg_list
--       Optional OA-compliance flag parameter.
--       Tells whether or not to initialize the FND_MSG_PUB message stack by
--       calling FND_MSG_PUB.Initialize.
--       Valid values are 'T' and 'F'; default is 'F'.
--    p_commit:
--       Optional OA-compliance flag parameter.  Valid values are 'T' and 'F'.
--       Note that since DDL operations, such as creating a table, index,
--       or view, always do an implicit COMMIT, this parameter cannot be
--       honored by this procedure: it will always commit.
--    p_encoded:
--       Optional OA-compliance flag parameter.
--       Passed to FND_MSG_PUB.Count_and_Get to determine the format of any
--       message passed back in x_msg_data.
--       Valid values are 'T' and 'F'; default is 'T'.
--    x_return_status:
--       OA-compliance OUT parameter.  This procedure returns 'S' for
--       success, 'E' for error in any of the values passed to the optional
--       OA parameters, and 'U' for unexpected errors, e.g. if the DDL
--       statement fails.
--    x_msg_count:
--       OA-compliance OUT parameter.  Tells how many messages are waiting
--       on the FND_MSG_PUB message stack.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    x_msg_data:
--       OA-compliance OUT parameter.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    p_request_id:
--       The concurrent manager REQUEST_ID of the calling process.
--    p_object_id:
--       The FEM OBJECT_ID identifying the executable rule for which the
--       temporary view is being created.
--    p_pb_object_id:
--       Optional parameter that specifies the FEM OBJECT_ID that this
--       procedure will use to determine the Process Behavior parameters.
--       If this parameter is NULL, this procedure will rely on
--       "p_object_id" parameter to determine the PB params.
--    p_view_name:
--       The name of the view. Use the Get_Unique_Temp_Name function to get
--       a unique view name.
--    p_view_def:
--       This is the definition of the view. It is the DDL statement
--       for creating the view, without the "CREATE VIEW view_name AS" part,
--       which is prepended by the procedure.
--       This parameter can be up to 32700 characters long.
--    p_step_name:
--       Optional parameter for specifying the engine step, used in looking up
--       process behavior parameters for DDL Logging.  Default value is 'ALL'.
-- HISTORY
--    Greg Hall     27-May-2005   Bug# 4301983: created.
-- ===========================================================================

   v_pb_object_type   VARCHAR2(30);
   v_param_data_type  VARCHAR2(6);
   v_ddl_logging      VARCHAR2(3);
   v_pb_object_id     FEM_OBJECT_CATALOG_B.object_id%TYPE;

   v_sql_statement    VARCHAR2(32767);
   v_sqlerrm VARCHAR2(255);

BEGIN

-- Validate OA parameters

   x_return_status := c_success;

   Validate_OA_Params (
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_encoded => p_encoded,
      x_return_status => x_return_status);

   IF (x_return_status <> c_success)
   THEN
      FND_MSG_PUB.Count_and_Get(
         p_encoded => c_false,
         p_count => x_msg_count,
         p_data => x_msg_data);
      RETURN;
   END IF;

   -- Set Process Behavior object id to "p_object_id" if
   -- "p_pb_object_id" was not provided.
   v_pb_object_id := nvl(p_pb_object_id, p_object_id);

   SELECT object_type_code
   INTO v_pb_object_type
   FROM fem_object_catalog_b
   WHERE object_id = v_pb_object_id;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'DDL_LOGGING',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_ddl_logging);

   IF v_ddl_logging IS NULL THEN
      v_ddl_logging := 'OFF';
   END IF;

-- Create the view

   v_sql_statement := 'CREATE OR REPLACE VIEW ' ||
                       p_view_name || ' AS ' || p_view_def;

   BEGIN
      exec(p_request_id, p_object_id, 'CREATE_TEMP_VIEW', v_sql_statement, v_ddl_logging);
   EXCEPTION
      WHEN OTHERS THEN
      -- Put user error message on the FND_MSG_PUB stack
      -- "Failed to create temporary view: VIEW_NAME"

         v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

         FEM_ENGINES_PKG.Put_Message(
            p_app_name => 'FEM',
            p_msg_name => 'FEM_CREATE_TEMP_VIEW_FAILURE',
            p_token1 => 'ORACLE_ERROR_MSG',
            p_value1 => v_sqlerrm,
            p_token2 => 'VIEW_NAME',
            p_value2 => p_view_name);
         RAISE;
   END;

-- Log view in FEM_PL_TEMP_OBJECTS

   BEGIN
      INSERT INTO fem_pl_temp_objects
        (request_id,
         object_id,
         object_type,
         object_name,
         created_by,
         creation_date,
         last_updated_by,
         last_update_date,
         last_update_login)
      VALUES
        (p_request_id,
         p_object_id,
         'VIEW',
         p_view_name,
         c_user_id,
         SYSDATE,
         c_user_id,
         SYSDATE,
         c_login_id);
   EXCEPTION
      WHEN DUP_VAL_ON_INDEX THEN
         UPDATE fem_pl_temp_objects
         SET created_by        = c_user_id,
             creation_date     = SYSDATE,
             last_updated_by   = c_user_id,
             last_update_date  = SYSDATE,
             last_update_login = c_login_id
         WHERE request_id = p_request_id
           AND object_id  = p_object_id
           AND object_type = 'VIEW'
           AND object_name = p_view_name;
   END;

   COMMIT;

   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN

      FND_MSG_PUB.Count_and_Get(
         p_encoded => p_encoded,
         p_count => x_msg_count,
         p_data => x_msg_data);
      x_return_status := c_unexp;

END Create_Temp_View;


/**************************************************************************/
PROCEDURE Drop_Temp_DB_Objects (
   p_api_version      IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list    IN         VARCHAR2   DEFAULT c_false,
   p_commit           IN         VARCHAR2   DEFAULT c_true,
   p_encoded          IN         VARCHAR2   DEFAULT c_true,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_request_id       IN         NUMBER,
   p_object_id        IN         NUMBER,
   p_pb_object_id     IN         NUMBER     DEFAULT NULL,
   p_step_name        IN         VARCHAR2   DEFAULT 'ALL') IS
-- ===========================================================================
-- DESCRIPTION
--    Drops all temporary tables and synonyms, views, and indexes that are
--    logged in FEM_PL_TEMP_OBJECTS for the given Request ID and Object ID.
--  Parameters:
--    p_api_version:
--       Optional OA-compliance parameter.
--       Default is 1.0 (and this is currently the only acceptable value).
--    p_init_msg_list
--       Optional OA-compliance flag parameter.
--       Tells whether or not to initialize the FND_MSG_PUB message stack by
--       calling FND_MSG_PUB.Initialize.
--       Valid values are 'T' and 'F'; default is 'F'.
--    p_commit:
--       Optional OA-compliance flag parameter.  Valid values are 'T' and 'F'.
--       Note that since DDL operations, such as dropping a table, index,
--       or view, always do an implicit COMMIT, this parameter cannot be
--       honored by this procedure: it will always commit.
--    p_encoded:
--       Optional OA-compliance flag parameter.
--       Passed to FND_MSG_PUB.Count_and_Get to determine the format of any
--       message passed back in x_msg_data.
--       Valid values are 'T' and 'F'; default is 'T'.
--    x_return_status:
--       OA-compliance OUT parameter.
--       For this procedure, success means that all temp objects logged in
--       FEM_PL_TEMP_OBJECTS for the given Request ID and Object ID have
--       been dropped or could not be dropped because they already did not
--       exist, and x_return_status = 'S'.  If an object exists, but cannot
--       be dropped for some reason, his procedure returns 'E' for error in
--       x_return_status, but it continues to try to drop all other temp DB
--       objects for the given Request ID and Object ID.  'U' is returned for
--       any other type of unexpected error.
--    x_msg_count:
--       OA-compliance OUT parameter.  Tells how many messages are waiting
--       on the FND_MSG_PUB message stack.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    x_msg_data:
--       OA-compliance OUT parameter.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    p_request_id:
--       The concurrent manager REQUEST_ID for which the temporary database
--       objects to be dropped were created.
--    p_object_id:
--       The FEM OBJECT_ID identifying the executable rule for which the
--       temporary database objects to be dropped were created.
--    p_pb_object_id:
--       Optional parameter that specifies the FEM OBJECT_ID that this
--       procedure will use to determine the Process Behavior parameters.
--       If this parameter is NULL, this procedure will rely on
--       "p_object_id" parameter to determine the PB params.
--    p_step_name:
--       Optional parameter for specifying the engine step, used in looking up
--       process behavior parameter for DDL Logging. Default value is 'ALL'.
-- HISTORY
--    Greg Hall     27-May-2005   Bug# 4301983: created.
-- ===========================================================================

   v_pb_object_type   VARCHAR2(30);
   v_param_data_type  VARCHAR2(6);
   v_ddl_logging      VARCHAR2(3);
   v_pb_object_id     FEM_OBJECT_CATALOG_B.object_id%TYPE;

   v_sql_statement    VARCHAR2(100);
   v_sqlerrm          VARCHAR2(255);

   v_fnd_schema       VARCHAR2(30); -- the schema name returned by the
                                   -- FND_INSTALLATION.Get_App_Info function.
-- Also required for the FND_INSTALLATION.Get_App_Info function, but the return
-- values are not actually used.
   v_fnd_status       VARCHAR2(100);
   v_fnd_industry     VARCHAR2(100);

   CURSOR c1(cp_obj_type IN VARCHAR2) IS
      SELECT object_type, object_name
      FROM fem_pl_temp_objects
      WHERE request_id = p_request_id
        AND object_id  = p_object_id
        AND object_type = cp_obj_type
      ORDER BY object_name;

   table_or_view_not_exist EXCEPTION;
   PRAGMA EXCEPTION_INIT(table_or_view_not_exist, -942);

   index_not_exist         EXCEPTION;
   PRAGMA EXCEPTION_INIT(index_not_exist, -1418);

   synonym_not_exist       EXCEPTION;
   PRAGMA EXCEPTION_INIT(synonym_not_exist, -1434);

BEGIN

-- Validate OA parameters

   x_return_status := c_success;

   Validate_OA_Params (
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_commit => p_commit,
      p_encoded => p_encoded,
      x_return_status => x_return_status);

   IF (x_return_status <> c_success)
   THEN
      FND_MSG_PUB.Count_and_Get(
         p_encoded => c_false,
         p_count => x_msg_count,
         p_data => x_msg_data);
      RETURN;
   END IF;

   -- Set Process Behavior object id to "p_object_id" if
   -- "p_pb_object_id" was not provided.
   v_pb_object_id := nvl(p_pb_object_id, p_object_id);

   SELECT object_type_code
   INTO v_pb_object_type
   FROM fem_object_catalog_b
   WHERE object_id = v_pb_object_id;

   FEM_ENGINES_PKG.Get_PB_Param_Value
     (p_api_version      => p_api_version,
      p_init_msg_list    => p_init_msg_list,
      p_commit           => p_commit,
      p_encoded          => p_encoded,
      x_return_status    => x_return_status,
      x_msg_count        => x_msg_count,
      x_msg_data         => x_msg_data,
      p_parameter_name   => 'DDL_LOGGING',
      p_object_type_code => v_pb_object_type,
      p_step_name        => p_step_name,
      p_object_id        => v_pb_object_id,
      x_pb_param_data_type  => v_param_data_type,
      x_pb_param_value      => v_ddl_logging);

   IF v_ddl_logging IS NULL THEN
      v_ddl_logging := 'OFF';
   END IF;

-- Get the schema name for the FEM application
   IF FND_INSTALLATION.Get_App_Info (
         APPLICATION_SHORT_NAME => 'FEM',
         STATUS        => v_fnd_status,
         INDUSTRY      => v_fnd_industry,
         ORACLE_SCHEMA => v_fnd_schema) THEN
      NULL;
   ELSE
      v_fnd_schema := 'FEM';
   END IF;

-- Drop views

   FOR obj IN c1('VIEW') LOOP

      BEGIN

         v_sql_statement := 'DROP VIEW ' || obj.object_name;

         exec(p_request_id, p_object_id, 'DROP_TEMP_DB_OBJECTS', v_sql_statement, v_ddl_logging);

      EXCEPTION

         WHEN table_or_view_not_exist THEN
            NULL;
         WHEN OTHERS THEN
         -- Put user error message on the FND_MSG_PUB stack
         -- "Failed to drop temporary database object. Object Type: VIEW. Object Name: DB_OBJECT_NAME"

            v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

            FEM_ENGINES_PKG.Put_Message(
               p_app_name => 'FEM',
               p_msg_name => 'FEM_DROP_TEMP_DB_OBJ_FAILURE',
               p_token1 => 'ORACLE_ERROR_MSG',
               p_value1 => v_sqlerrm,
               p_token2 => 'DB_OBJECT_TYPE',
               p_value2 => 'VIEW',
               p_token3 => 'DB_OBJECT_NAME',
               p_value3 => obj.object_name);
            x_return_status := c_error;
      END;

   END LOOP;

   DELETE FROM fem_pl_temp_objects tobj
   WHERE request_id  = p_request_id
     AND object_id   = p_object_id
     AND object_type = 'VIEW'
     AND NOT EXISTS
        (SELECT NULL
         FROM user_views
         WHERE view_name = tobj.object_name);

   COMMIT;

-- Drop indexes

   FOR obj IN c1('INDEX') LOOP

      BEGIN

         v_sql_statement := 'DROP INDEX ' || v_fnd_schema || '.' || obj.object_name;

         exec(p_request_id, p_object_id, 'DROP_TEMP_DB_OBJECTS', v_sql_statement, v_ddl_logging);

      EXCEPTION

         WHEN index_not_exist THEN
            NULL;
         WHEN OTHERS THEN
         -- Put user error message on the FND_MSG_PUB stack
         -- "Failed to drop temporary database object: OBJECT_NAME. Object Type: INDEX"

            v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

            FEM_ENGINES_PKG.Put_Message(
               p_app_name => 'FEM',
               p_msg_name => 'FEM_DROP_TEMP_DB_OBJ_FAILURE',
               p_token1 => 'ORACLE_ERROR_MSG',
               p_value1 => v_sqlerrm,
               p_token2 => 'DB_OBJECT_NAME',
               p_value2 => obj.object_name,
               p_token3 => 'DB_OBJECT_TYPE',
               p_value3 => 'INDEX');
            x_return_status := c_error;
      END;

   END LOOP;

   DELETE FROM fem_pl_temp_objects tobj
   WHERE request_id  = p_request_id
     AND object_id   = p_object_id
     AND object_type = 'INDEX'
     AND NOT EXISTS
        (SELECT NULL
         FROM user_indexes
         WHERE index_name = tobj.object_name);

   COMMIT;

-- Drop tables

   FOR obj IN c1('TABLE') LOOP

      BEGIN

         v_sql_statement := 'DROP SYNONYM ' || obj.object_name;

         exec(p_request_id, p_object_id, 'DROP_TEMP_DB_OBJECTS', v_sql_statement, v_ddl_logging);

      EXCEPTION

         WHEN synonym_not_exist THEN
            NULL;
         WHEN OTHERS THEN
         -- Put user error message on the FND_MSG_PUB stack
         -- "Failed to drop temporary database object. Object Type: SYNONYM. Object Name: OBJECT_NAME"

            v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

            FEM_ENGINES_PKG.Put_Message(
               p_app_name => 'FEM',
               p_msg_name => 'FEM_DROP_TEMP_DB_OBJ_FAILURE',
               p_token1 => 'ORACLE_ERROR_MSG',
               p_value1 => v_sqlerrm,
               p_token2 => 'DB_OBJECT_TYPE',
               p_value2 => 'SYNONYM',
               p_token3 => 'DB_OBJECT_NAME',
               p_value3 => obj.object_name);
            x_return_status := c_error;
      END;

      BEGIN

         v_sql_statement := 'DROP TABLE ' || v_fnd_schema || '.' || obj.object_name;

         exec(p_request_id, p_object_id, 'DROP_TEMP_DB_OBJECTS', v_sql_statement, v_ddl_logging);

      EXCEPTION

         WHEN table_or_view_not_exist THEN
            NULL;
         WHEN OTHERS THEN
         -- Put user error message on the FND_MSG_PUB stack
         -- "Failed to drop temporary database object. Object Type: TABLE. Object Name: OBJECT_NAME"

            v_sqlerrm := SUBSTR(SQLERRM, 1, 255);

            FEM_ENGINES_PKG.Put_Message(
               p_app_name => 'FEM',
               p_msg_name => 'FEM_DROP_TEMP_DB_OBJ_FAILURE',
               p_token1 => 'ORACLE_ERROR_MSG',
               p_value1 => v_sqlerrm,
               p_token2 => 'DB_OBJECT_TYPE',
               p_value2 => 'TABLE',
               p_token3 => 'DB_OBJECT_NAME',
               p_value3 => obj.object_name);
            x_return_status := c_error;
      END;

   END LOOP;

   DELETE FROM fem_pl_temp_objects tobj
   WHERE request_id  = p_request_id
     AND object_id   = p_object_id
     AND object_type = 'TABLE'
     AND NOT EXISTS
        (SELECT NULL
         FROM user_tables
         WHERE table_name = tobj.object_name);

   COMMIT;

   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

   EXCEPTION
      WHEN OTHERS THEN
         FEM_ENGINES_PKG.TECH_MESSAGE(
            p_severity => c_log_level_6,
            p_module   => 'fem.plsql.fem_database_util_pkg.drop_temp_db_objects',
            p_msg_text => SUBSTR(SQLERRM, 1, 255) );

        FND_MSG_PUB.Count_and_Get(
           p_encoded => p_encoded,
           p_count => x_msg_count,
           p_data => x_msg_data);
        x_return_status := c_unexp;

END Drop_Temp_DB_Objects;


END FEM_Database_Util_Pkg;

/
