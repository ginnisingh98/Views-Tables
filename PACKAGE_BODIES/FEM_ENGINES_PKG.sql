--------------------------------------------------------
--  DDL for Package Body FEM_ENGINES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_ENGINES_PKG" AS
-- $Header: fem_engs_body.pls 120.2 2006/02/24 15:06:15 ghall ship $

/***************************************************************************
                    Copyright (c) 2003 Oracle Corporation
                           Redwood Shores, CA, USA
                             All rights reserved.
 ***************************************************************************
  FILENAME
    fem_engs_body.pls

  DESCRIPTION

  HISTORY
    Tim Moore   20-Dec-2002  Original script
    Greg Hall   21-Jun-2005  Bug# 4445212: Added procedure Get_PB_Param_Value,
                             for retrieving a process behavior parameter value
                             from the database.  Also added procedure
                             Validate_OA_Params as an internal procedure, for
                             use by OA-compliant procedures.
    G Cheng     20-Feb-2006  Bug 5040902: FND_MESSAGE.Tech_Message should not
                v115.7       perform any action if the debug log level from
                             the caller is less than the debug level profile
                             option value set by the user.
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

v_msg_mode  NUMBER := 0;

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


/***************************************************************************
 ===========================================================================
                               Public Procedures
 ===========================================================================
 ***************************************************************************/

PROCEDURE Put_Message
  (p_app_name     IN   VARCHAR2,
   p_msg_name     IN   VARCHAR2,
   p_token1       IN   VARCHAR2 DEFAULT NULL,
   p_value1       IN   VARCHAR2 DEFAULT NULL,
   p_trans1       IN   VARCHAR2 DEFAULT NULL,
   p_token2       IN   VARCHAR2 DEFAULT NULL,
   p_value2       IN   VARCHAR2 DEFAULT NULL,
   p_trans2       IN   VARCHAR2 DEFAULT NULL,
   p_token3       IN   VARCHAR2 DEFAULT NULL,
   p_value3       IN   VARCHAR2 DEFAULT NULL,
   p_trans3       IN   VARCHAR2 DEFAULT NULL,
   p_token4       IN   VARCHAR2 DEFAULT NULL,
   p_value4       IN   VARCHAR2 DEFAULT NULL,
   p_trans4       IN   VARCHAR2 DEFAULT NULL,
   p_token5       IN   VARCHAR2 DEFAULT NULL,
   p_value5       IN   VARCHAR2 DEFAULT NULL,
   p_trans5       IN   VARCHAR2 DEFAULT NULL,
   p_token6       IN   VARCHAR2 DEFAULT NULL,
   p_value6       IN   VARCHAR2 DEFAULT NULL,
   p_trans6       IN   VARCHAR2 DEFAULT NULL,
   p_token7       IN   VARCHAR2 DEFAULT NULL,
   p_value7       IN   VARCHAR2 DEFAULT NULL,
   p_trans7       IN   VARCHAR2 DEFAULT NULL,
   p_token8       IN   VARCHAR2 DEFAULT NULL,
   p_value8       IN   VARCHAR2 DEFAULT NULL,
   p_trans8       IN   VARCHAR2 DEFAULT NULL,
   p_token9       IN   VARCHAR2 DEFAULT NULL,
   p_value9       IN   VARCHAR2 DEFAULT NULL,
   p_trans9       IN   VARCHAR2 DEFAULT NULL)
IS
   v_token           VARCHAR2(30);
   v_value           VARCHAR2(4000);
   v_trans           BOOLEAN;

   TYPE msg_array     IS VARRAY(27) OF VARCHAR2(4000);
   tokens_values      msg_array;

BEGIN

   IF (p_msg_name IS NOT NULL) AND
      (p_app_name IS NOT NULL)
   THEN

      ---------------------------------
      -- Get message from dictionary --
      ---------------------------------
      fnd_message.set_name(p_app_name,p_msg_name);

      ----------------------------
      -- Load token/value array --
      ----------------------------
      tokens_values := msg_array
                       (p_token1,p_value1,p_trans1,
                        p_token2,p_value2,p_trans2,
                        p_token3,p_value3,p_trans3,
                        p_token4,p_value4,p_trans4,
                        p_token5,p_value5,p_trans5,
                        p_token6,p_value6,p_trans6,
                        p_token7,p_value7,p_trans7,
                        p_token8,p_value8,p_trans8,
                        p_token9,p_value9,p_trans9);

      ----------------------------------
      -- Substitute values for tokens --
      ----------------------------------
      FOR i IN 1..27 LOOP
         IF (MOD(i,3) = 1)
         THEN
            v_token := tokens_values(i);
            IF (v_token IS NOT NULL)
            THEN
               v_value := tokens_values(i+1);
               IF (tokens_values(i+2) = 'Y')
               THEN
                  v_trans := TRUE;
               ELSE
                  v_trans := FALSE;
               END IF;
               fnd_message.set_token(v_token,v_value,v_trans);
            ELSE
               EXIT;
            END IF;
         END IF;
      END LOOP;

      IF (v_msg_mode = 0)
      THEN
         fnd_msg_pub.add;
      END IF;
      v_msg_mode := 0;

   END IF;

END Put_Message;


PROCEDURE Tech_Message
  (p_severity     IN   NUMBER,
   p_module       IN   VARCHAR2,
   p_msg_text     IN   VARCHAR2 DEFAULT NULL,
   p_app_name     IN   VARCHAR2 DEFAULT NULL,
   p_msg_name     IN   VARCHAR2 DEFAULT NULL,
   p_token1       IN   VARCHAR2 DEFAULT NULL,
   p_value1       IN   VARCHAR2 DEFAULT NULL,
   p_trans1       IN   VARCHAR2 DEFAULT NULL,
   p_token2       IN   VARCHAR2 DEFAULT NULL,
   p_value2       IN   VARCHAR2 DEFAULT NULL,
   p_trans2       IN   VARCHAR2 DEFAULT NULL,
   p_token3       IN   VARCHAR2 DEFAULT NULL,
   p_value3       IN   VARCHAR2 DEFAULT NULL,
   p_trans3       IN   VARCHAR2 DEFAULT NULL,
   p_token4       IN   VARCHAR2 DEFAULT NULL,
   p_value4       IN   VARCHAR2 DEFAULT NULL,
   p_trans4       IN   VARCHAR2 DEFAULT NULL,
   p_token5       IN   VARCHAR2 DEFAULT NULL,
   p_value5       IN   VARCHAR2 DEFAULT NULL,
   p_trans5       IN   VARCHAR2 DEFAULT NULL,
   p_token6       IN   VARCHAR2 DEFAULT NULL,
   p_value6       IN   VARCHAR2 DEFAULT NULL,
   p_trans6       IN   VARCHAR2 DEFAULT NULL,
   p_token7       IN   VARCHAR2 DEFAULT NULL,
   p_value7       IN   VARCHAR2 DEFAULT NULL,
   p_trans7       IN   VARCHAR2 DEFAULT NULL,
   p_token8       IN   VARCHAR2 DEFAULT NULL,
   p_value8       IN   VARCHAR2 DEFAULT NULL,
   p_trans8       IN   VARCHAR2 DEFAULT NULL,
   p_token9       IN   VARCHAR2 DEFAULT NULL,
   p_value9       IN   VARCHAR2 DEFAULT NULL,
   p_trans9       IN   VARCHAR2 DEFAULT NULL)

IS
   v_msg_text     VARCHAR2(4000);
BEGIN

   IF (p_severity IS NOT NULL) AND
      (p_module IS NOT NULL)
   THEN
    -- Only log the message if the caller debug level is greater than
    -- the FND profile debug level set by the user.
    IF (p_severity >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      IF (p_app_name IS NOT NULL) AND
         (p_msg_name IS NOT NULL)
      THEN
         v_msg_mode := 1;
         Put_Message
           (p_app_name,p_msg_name,
            p_token1,p_value1,p_trans1,
            p_token2,p_value2,p_trans2,
            p_token3,p_value3,p_trans3,
            p_token4,p_value4,p_trans4,
            p_token5,p_value5,p_trans5,
            p_token6,p_value6,p_trans6,
            p_token7,p_value7,p_trans7,
            p_token8,p_value8,p_trans8,
            p_token9,p_value9,p_trans9);

         v_msg_text := SUBSTR(FND_Message.Get,1,4000);
      ELSE
         v_msg_text := SUBSTR(p_msg_text,1,4000);
      END IF;

      fnd_log.string(p_severity,p_module,NVL(v_msg_text,'NULL'));
    END IF;

   END IF;

END Tech_Message;


PROCEDURE User_Message
   (p_msg_text     IN   VARCHAR2 DEFAULT NULL,
    p_app_name     IN   VARCHAR2 DEFAULT NULL,
    p_msg_name     IN   VARCHAR2 DEFAULT NULL,
    p_token1       IN   VARCHAR2 DEFAULT NULL,
    p_value1       IN   VARCHAR2 DEFAULT NULL,
    p_trans1       IN   VARCHAR2 DEFAULT NULL,
    p_token2       IN   VARCHAR2 DEFAULT NULL,
    p_value2       IN   VARCHAR2 DEFAULT NULL,
    p_trans2       IN   VARCHAR2 DEFAULT NULL,
    p_token3       IN   VARCHAR2 DEFAULT NULL,
    p_value3       IN   VARCHAR2 DEFAULT NULL,
    p_trans3       IN   VARCHAR2 DEFAULT NULL,
    p_token4       IN   VARCHAR2 DEFAULT NULL,
    p_value4       IN   VARCHAR2 DEFAULT NULL,
    p_trans4       IN   VARCHAR2 DEFAULT NULL,
    p_token5       IN   VARCHAR2 DEFAULT NULL,
    p_value5       IN   VARCHAR2 DEFAULT NULL,
    p_trans5       IN   VARCHAR2 DEFAULT NULL,
    p_token6       IN   VARCHAR2 DEFAULT NULL,
    p_value6       IN   VARCHAR2 DEFAULT NULL,
    p_trans6       IN   VARCHAR2 DEFAULT NULL,
    p_token7       IN   VARCHAR2 DEFAULT NULL,
    p_value7       IN   VARCHAR2 DEFAULT NULL,
    p_trans7       IN   VARCHAR2 DEFAULT NULL,
    p_token8       IN   VARCHAR2 DEFAULT NULL,
    p_value8       IN   VARCHAR2 DEFAULT NULL,
    p_trans8       IN   VARCHAR2 DEFAULT NULL,
    p_token9       IN   VARCHAR2 DEFAULT NULL,
    p_value9       IN   VARCHAR2 DEFAULT NULL,
    p_trans9       IN   VARCHAR2 DEFAULT NULL)

IS
   v_msg_text     VARCHAR2(4000);
BEGIN

   IF (p_app_name IS NOT NULL) AND
      (p_msg_name IS NOT NULL)
   THEN
      v_msg_mode := 1;
      Put_Message
        (p_app_name,p_msg_name,
         p_token1,p_value1,p_trans1,
         p_token2,p_value2,p_trans2,
         p_token3,p_value3,p_trans3,
         p_token4,p_value4,p_trans4,
         p_token5,p_value5,p_trans5,
         p_token6,p_value6,p_trans6,
         p_token7,p_value7,p_trans7,
         p_token8,p_value8,p_trans8,
         p_token9,p_value9,p_trans9);

      v_msg_text := SUBSTR(FND_Message.Get,1,4000);
   ELSE
      v_msg_text := SUBSTR(p_msg_text,1,4000);
   END IF;

   fnd_file.put_line(fnd_file.log,
                     NVL(v_msg_text,'No message found'));

END User_Message;

/***************************************************************************/
PROCEDURE Get_PB_Param_Value
  (p_api_version        IN         NUMBER     DEFAULT c_api_version,
   p_init_msg_list      IN         VARCHAR2   DEFAULT c_false,
   p_commit             IN         VARCHAR2   DEFAULT c_false,
   p_encoded            IN         VARCHAR2   DEFAULT c_true,
   x_return_status      OUT NOCOPY VARCHAR2,
   x_msg_count          OUT NOCOPY NUMBER,
   x_msg_data           OUT NOCOPY VARCHAR2,
   p_parameter_name     IN         VARCHAR2,
   p_object_type_code   IN         VARCHAR2,
   p_step_name          IN         VARCHAR2,
   p_object_id          IN         NUMBER,
   x_pb_param_data_type OUT NOCOPY VARCHAR2,
   x_pb_param_value     OUT NOCOPY VARCHAR2) IS
-- ===========================================================================
-- DESCRIPTION
--    Returns the process behavior parameter value for the specified
--    parameter for the specified object type, step name, and object ID.
--    Selection is made from the most specific assignment level to the most
--    general one until a matching assignment level is found.  The assignment
--    level precedence is as follows, from most specific to most general
--    (consistent with how the multiprocessing parameter values are selected):
--    1. Match on
--         OBJECT_TYPE_CODE = p_object_type_code AND
--         STEP_NAME        = p_step_name AND
--         OBJECT_ID        = p_object_id.
--    2. Match on
--         OBJECT_TYPE_CODE = p_object_type_code AND
--         STEP_NAME        = 'ALL' AND
--         OBJECT_ID        = p_object_id.
--    3. Match on
--         OBJECT_TYPE_CODE = p_object_type_code AND
--         STEP_NAME        = p_step_name AND
--         OBJECT_ID        IS NULL.
--    4. Match on
--         OBJECT_TYPE_CODE = p_object_type_code AND
--         STEP_NAME        = 'ALL' AND
--         OBJECT_ID        IS NULL.
--    Note that level 3 and level 4 are the same for engines that don't use
--    distinct steps, as they will always pass in 'ALL' for p_step_name.
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
--       OA-compliance OUT parameter.
--       Returns 'S' for success if an assignment level is found;
--       Returns 'E' for error if no assignment level is found.
--    x_msg_count:
--       OA-compliance OUT parameter.  Tells how many messages are waiting
--       on the FND_MSG_PUB message stack.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    x_msg_data:
--       OA-compliance OUT parameter.  If x_msg_count = 1, the message
--       has already been fetched from the stack and is found in x_msg_data.
--    p_parameter_name:
--       The PARAMETER_NAME of the parameter value to be retrieved.
--    p_object_type_code:
--       The OBJECT_TYPE_CODE of the object being processed, and for which
--       the Process Behavior parameter value is to be retrieved.
--    p_step_name:
--       The STEP_NAME identifying the engine processing step for which the
--       Process Behavior parameter is to be retrieved.  If there is no
--       STEP_NAME-level assignment, then the value for the 'ALL' step
--       assignment level is returned.
--    p_object_id:
--       The FEM OBJECT_ID identifying the executable rule for which the
--       Process Behavior parameter is to be retrieved.  If there is no
--       Object ID-level assignment, then the value for a more general
--       assignment level is returned.
--    x_pb_param_data_type:
--       Returns 'NUMBER', 'CHAR', or 'DATE' according to the data type of
--       the parameter for the applicable assignment level.  Returns NULL
--       if no assignment is found for the given parameter and object type.
--    x_pb_param_value:
--       Returns the alphanumeric value of the process behavior parameter from
--       the applicable assignment level. Returns NULL if no assignment levels
--       are found for the specified parameter and object type. Number and Date
--       parameters are returned as alphanumeric, and will need to be converted
--       by the calling program.
-- HISTORY
--    Greg Hall     21-Jun-2005   Bug# 4445212: created.
-- ===========================================================================

   v_param_numeric_value  NUMBER;
   v_param_char_value     VARCHAR2(255);
   v_param_date_value     DATE;

   v_param_data_type      VARCHAR2(6);
   v_param_default_value  VARCHAR2(255);

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

   BEGIN

   -- Assignment Level 1 (most specific):

      SELECT parameter_numeric_value,
             parameter_char_value,
             parameter_date_value
      INTO   v_param_numeric_value,
             v_param_char_value,
             v_param_date_value
      FROM   fem_pb_parameters
      WHERE  parameter_name = p_parameter_name
      AND    object_type_code = p_object_type_code
      AND    step_name = p_step_name
      AND    object_id = p_object_id;

      SELECT param_data_type_code, param_default_value
      INTO   v_param_data_type, v_param_default_value
      FROM   fem_pb_param_assignmt
      WHERE  parameter_name = p_parameter_name
      AND    object_type_code = p_object_type_code
      AND    step_name = p_step_name
      AND    object_id_level_flag = 'Y';

      FEM_ENGINES_PKG.TECH_MESSAGE
       (p_severity => c_log_level_1,
        p_module   => 'fem.plsql.fem_database_util_pkg.get_pb_param_value',
        p_msg_text => 'Value found for PB parameter ' || p_parameter_name ||
                      ' at assignment level 1: Object Type, specific Step, specific Object ID');
   EXCEPTION
      WHEN no_data_found THEN

      BEGIN

      -- Assignment Level 2

         SELECT parameter_numeric_value,
                parameter_char_value,
                parameter_date_value
         INTO   v_param_numeric_value,
                v_param_char_value,
                v_param_date_value
         FROM   fem_pb_parameters
         WHERE  parameter_name = p_parameter_name
         AND    object_type_code = p_object_type_code
         AND    step_name = 'ALL'
         AND    object_id = p_object_id;

         SELECT param_data_type_code, param_default_value
         INTO   v_param_data_type, v_param_default_value
         FROM   fem_pb_param_assignmt
         WHERE  parameter_name = p_parameter_name
         AND    object_type_code = p_object_type_code
         AND    step_name = 'ALL'
         AND    object_id_level_flag = 'Y';

         FEM_ENGINES_PKG.TECH_MESSAGE
          (p_severity => c_log_level_1,
           p_module   => 'fem.plsql.fem_database_util_pkg.get_pb_param_value',
           p_msg_text => 'Value found for PB parameter ' || p_parameter_name ||
                         ' at assignment level 2: Object Type, Step=ALL, specific Object ID');
      EXCEPTION
         WHEN no_data_found THEN

         BEGIN

         -- Assignment Level 3

            SELECT parameter_numeric_value,
                   parameter_char_value,
                   parameter_date_value
            INTO   v_param_numeric_value,
                   v_param_char_value,
                   v_param_date_value
            FROM   fem_pb_parameters
            WHERE  parameter_name = p_parameter_name
            AND    object_type_code = p_object_type_code
            AND    step_name = p_step_name
            AND    object_id IS NULL;

            SELECT param_data_type_code, param_default_value
            INTO   v_param_data_type, v_param_default_value
            FROM   fem_pb_param_assignmt
            WHERE  parameter_name = p_parameter_name
            AND    object_type_code = p_object_type_code
            AND    step_name = p_step_name
            AND    object_id_level_flag = 'N';

            FEM_ENGINES_PKG.TECH_MESSAGE
             (p_severity => c_log_level_1,
              p_module   => 'fem.plsql.fem_database_util_pkg.get_pb_param_value',
              p_msg_text => 'Value found for PB parameter ' || p_parameter_name ||
                            ' at assignment level 3: Object Type, specific Step, Object ID IS NULL');
         EXCEPTION
            WHEN no_data_found THEN

            BEGIN

            -- Assignment Level 4 (most general)

               SELECT parameter_numeric_value,
                      parameter_char_value,
                      parameter_date_value
               INTO   v_param_numeric_value,
                      v_param_char_value,
                      v_param_date_value
               FROM   fem_pb_parameters
               WHERE  parameter_name = p_parameter_name
               AND    object_type_code = p_object_type_code
               AND    step_name = 'ALL'
               AND    object_id IS NULL;

               SELECT param_data_type_code, param_default_value
               INTO   v_param_data_type, v_param_default_value
               FROM   fem_pb_param_assignmt
               WHERE  parameter_name = p_parameter_name
               AND    object_type_code = p_object_type_code
               AND    step_name = 'ALL'
               AND    object_id_level_flag = 'N';

               FEM_ENGINES_PKG.TECH_MESSAGE
                (p_severity => c_log_level_1,
                 p_module   => 'fem.plsql.fem_database_util_pkg.get_pb_param_value',
                 p_msg_text => 'Value found for PB parameter ' || p_parameter_name ||
                               ' at assignment level 4: Object Type, Step=ALL, Object ID IS NULL');
            EXCEPTION
               WHEN no_data_found THEN

               -- Put user error message on the FND_MSG_PUB stack and to the debug log:
               -- "No parameter assignment found. Parameter Name: PARAMETER_NAME. Object Type: OBJECT_TYPE"
                  FEM_ENGINES_PKG.PUT_MESSAGE
                   (p_app_name => 'FEM',
                    p_msg_name => 'FEM_PB_NO_ASSIGNMENTS_ERROR',
                    p_token1 => 'PARAMETER_NAME',
                    p_value1 => p_parameter_name,
                    p_token2 => 'OBJECT_TYPE',
                    p_value2 => p_object_type_code);

                  FEM_ENGINES_PKG.TECH_MESSAGE
                   (p_severity => c_log_level_5,
                    p_module   => 'fem.plsql.fem_database_util_pkg.get_pb_param_value',
                    p_app_name => 'FEM',
                    p_msg_name => 'FEM_PB_NO_ASSIGNMENTS_ERROR',
                    p_token1 => 'PARAMETER_NAME',
                    p_value1 => p_parameter_name,
                    p_token2 => 'OBJECT_TYPE',
                    p_value2 => p_object_type_code);

                  FND_MSG_PUB.Count_and_Get(
                     p_encoded => p_encoded,
                     p_count => x_msg_count,
                     p_data => x_msg_data);

                  x_return_status := c_error;

                  RETURN;
            END;
         END;
      END;
   END;

   IF v_param_data_type = 'NUMBER' THEN

      x_pb_param_value := NVL(TO_CHAR(v_param_numeric_value), v_param_default_value);

   ELSIF v_param_data_type = 'CHAR' THEN

      x_pb_param_value := NVL(v_param_char_value, v_param_default_value);

   ELSE
   -- v_param_data_type = 'DATE'

      x_pb_param_value := NVL(TO_CHAR(v_param_date_value), v_param_default_value);

   END IF;

   FEM_ENGINES_PKG.TECH_MESSAGE
    (p_severity => c_log_level_1,
     p_module   => 'fem.plsql.fem_database_util_pkg.get_pb_param_value',
     p_msg_text => 'Returning ' || v_param_data_type || ' parameter value: ' || x_pb_param_value);

   x_pb_param_data_type := v_param_data_type;

   FND_MSG_PUB.Count_and_Get(
      p_encoded => p_encoded,
      p_count => x_msg_count,
      p_data => x_msg_data);

END Get_PB_Param_Value;


END FEM_Engines_Pkg;

/
