--------------------------------------------------------
--  DDL for Package Body FEM_LEDGERS_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_LEDGERS_UTIL_PKG" AS
/* $Header: fem_ledger_utl.plb 120.0 2006/05/09 14:52:32 rflippo noship $ */
/*=======================================================================+
Copyright (c) 1995 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME
 |   fem_ledger_utl.plb
 |
 | DESCRIPTION
 |   Creates body for package used to create user defined attributes
 |
 | MODIFICATION HISTORY
 |   Robert Flippo       04/06/2006 Created
 |
 |
 *=======================================================================*/

/* ***********************
** Package constants
** ***********************/


/* ***********************
** Package variables
** ***********************/
--dbms_utility.format_call_stack                 VARCHAR2(2000);

/* ***********************
** Package exceptions
** ***********************/
e_invalid_dimension  EXCEPTION;
e_invalid_attr_dimension  EXCEPTION;
e_existing_attr_varchar_label EXCEPTION;
e_invalid_order_type EXCEPTION;
e_existing_attr_name EXCEPTION;
e_invalid_attr_data_type_code EXCEPTION;

gv_prg_msg      VARCHAR2(2000);
gv_callstack    VARCHAR2(2000);


/*************************************************************************

                         Get_Default_Dim_Member

Purpose:  This function returns the Calendar associated with a given
          Ledger ID.  The Calendar for a Ledger is based upon the
          Calendar Period hierarchy that is assigned to that Ledger.

Usage:    The caller must provide a Ledger ID

Return variables:
   x_calendar_id           - Identifies a Calendar member
   x_return_status
      - FND_API.G_RET_STS_SUCCESS ('S') if calendar was found
      - FND_API.G_RET_STS_ERROR ('E') if no calendar is associated to the ledger
      - FND_API.G_RET_STS_UNEXP_ERROR if something unexpected occurs

*************************************************************************/

PROCEDURE Get_Calendar (
   p_api_version                 IN  NUMBER DEFAULT 1.0,
   p_init_msg_list               IN  VARCHAR2 DEFAULT pc_false,
   p_commit                      IN  VARCHAR2 DEFAULT pc_false,
   p_encoded                     IN  VARCHAR2 DEFAULT pc_true,
   p_ledger_id                   IN  NUMBER,
   x_calendar_id                 OUT NOCOPY NUMBER,
   x_return_status               OUT NOCOPY VARCHAR2,
   x_msg_count                   OUT NOCOPY NUMBER,
   x_msg_data                    OUT NOCOPY VARCHAR2
)

IS

  C_MODULE            CONSTANT FND_LOG_MESSAGES.module%TYPE :=
     'fem.plsql.fem_ledger_util_pkg.get_calendar';
  C_API_VERSION       CONSTANT NUMBER := 1.0;
  C_API_NAME          CONSTANT VARCHAR2(30)  := 'Get_Calendar';
  e_no_calendar         EXCEPTION;
  e_unexp               EXCEPTION;

  v_ledger_dim_id     FEM_DIMENSIONS_B.dimension_id%TYPE;
  v_calp_hier_attr_id FEM_LEDGERS_ATTR.attribute_id%TYPE;
  v_calp_hier_vrs_id FEM_LEDGERS_ATTR.version_id%TYPE;
  v_calp_hier_obj_def_id FEM_LEDGERS_ATTR.dim_attribute_numeric_member%TYPE;


BEGIN

  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'Begin Procedure');
  END IF;

  -- Initialize return status to unexpected error
  x_return_status := pc_ret_sts_unexp_error;

  -- Check for call compatibility.
  IF NOT FND_API.Compatible_API_Call (C_API_VERSION,
                p_api_version,
                C_API_NAME,
                PC_PKG_NAME)
  THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'API Version ('||C_API_VERSION||') not compatible with '
                    ||'passed in version ('||p_api_version||')');
    END IF;
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    RAISE e_unexp;
  END IF;

  Validate_OA_Params (p_api_version => p_api_version,
                              p_init_msg_list  => p_init_msg_list,
                              p_commit     => p_commit,
                              p_encoded   => p_encoded,
                              x_return_status => x_return_status);



  IF (x_return_status <> pc_ret_sts_success) THEN
    FND_MSG_PUB.Count_And_Get(p_encoded => p_encoded,
                              p_count => x_msg_count,
                              p_data => x_msg_data);
    RETURN;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'p_ledger_id = '||to_char(p_ledger_id));
  END IF;

  -- Identify the dimension_id for LEDGER
  SELECT dimension_id
  INTO v_ledger_dim_id
  FROM fem_dimensions_b
  WHERE dimension_varchar_label = 'LEDGER';

  -- Identify the attribute_id for the Calendar Period Hierarchy attribute
  SELECT attribute_id
  INTO v_calp_hier_attr_id
  FROM fem_dim_attributes_b
  WHERE dimension_id= v_ledger_dim_id
  AND attribute_varchar_label = 'CAL_PERIOD_HIER_OBJ_DEF_ID';

  -- Identify the default version for the attribute
  SELECT version_id
  INTO v_calp_hier_vrs_id
  FROM fem_dim_attr_versions_b
  WHERE attribute_id = v_calp_hier_attr_id
  AND default_version_flag = 'Y';

  -- Identify the cal period hier for the ledger
  SELECT dim_attribute_numeric_member
  INTO v_calp_hier_obj_def_id
  FROM fem_ledgers_attr
  WHERE ledger_id = p_ledger_id
  AND attribute_id = v_calp_hier_attr_id
  AND version_id = v_calp_hier_vrs_id;

  -- Get the Calendar for the hierarchy object definition
  SELECT H.calendar_id
  INTO x_calendar_id
  FROM fem_hierarchies H, fem_hier_definitions D, fem_object_definition_b O
  WHERE D.hierarchy_obj_def_id = v_calp_hier_obj_def_id
  AND D.hierarchy_obj_def_id = O.object_definition_id
  AND O.object_id = H.hierarchy_obj_id;


  IF x_calendar_id IS NULL THEN
    x_return_status := pc_ret_sts_error;
  ELSE
    x_return_status := pc_ret_sts_success;
  END IF;

  IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_calendar_id = '||x_calendar_id);
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_statement,
      p_module   => C_MODULE,
      p_msg_text => 'x_return_status = '||x_return_status);
  END IF;
  IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
    FEM_ENGINES_PKG.TECH_MESSAGE(
      p_severity => FND_LOG.level_procedure,
      p_module   => C_MODULE,
      p_msg_text => 'End Procedure');
  END IF;

EXCEPTION
  WHEN e_no_calendar THEN
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_calendar_id := NULL;
    x_return_status := pc_ret_sts_error;
  WHEN others THEN
    IF FND_LOG.level_statement >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_statement,
        p_module   => C_MODULE,
        p_msg_text => 'Unexpected error.');
    END IF;
    IF FND_LOG.level_procedure >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FEM_ENGINES_PKG.TECH_MESSAGE(
        p_severity => FND_LOG.level_procedure,
        p_module   => C_MODULE,
        p_msg_text => 'End Procedure');
    END IF;
    x_return_status := pc_ret_sts_unexp_error;

END Get_Calendar;


/*************************************************************************

                         OA Exception Handler

*************************************************************************/

PROCEDURE Validate_OA_Params (
   p_api_version     IN NUMBER,
   p_init_msg_list   IN VARCHAR2,
   p_commit          IN VARCHAR2,
   p_encoded         IN VARCHAR2,
   x_return_status   OUT NOCOPY VARCHAR2
)
IS
   e_bad_p_api_ver         EXCEPTION;
   e_bad_p_init_msg_list   EXCEPTION;
   e_bad_p_commit          EXCEPTION;
   e_bad_p_encoded         EXCEPTION;
BEGIN

x_return_status := pc_ret_sts_success;

CASE p_api_version
   WHEN pc_api_version THEN NULL;
   ELSE RAISE e_bad_p_api_ver;
END CASE;

CASE p_init_msg_list
   WHEN pc_false THEN NULL;
   WHEN pc_true THEN
      FND_MSG_PUB.Initialize;
   ELSE RAISE e_bad_p_init_msg_list;
END CASE;

CASE p_encoded
   WHEN pc_false THEN NULL;
   WHEN pc_true THEN NULL;
   ELSE RAISE e_bad_p_encoded;
END CASE;

CASE p_commit
   WHEN pc_false THEN NULL;
   WHEN pc_true THEN NULL;
   ELSE RAISE e_bad_p_commit;
END CASE;

EXCEPTION
   WHEN e_bad_p_api_ver THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_API_VER_ERR',
         p_token1 => 'VALUE',
         p_value1 => p_api_version);
      x_return_status := pc_ret_sts_error;

   WHEN e_bad_p_init_msg_list THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_INIT_MSG_LIST_ERR');
      x_return_status := pc_ret_sts_error;

   WHEN e_bad_p_encoded THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_ENCODED_ERR');
      x_return_status := pc_ret_sts_error;

   WHEN e_bad_p_commit THEN
      FEM_ENGINES_PKG.Put_Message(
         p_app_name => 'FEM',
         p_msg_name => 'FEM_BAD_P_COMMIT_ERR');
      x_return_status := pc_ret_sts_error;

END Validate_OA_Params;



END FEM_LEDGERS_UTIL_PKG;

/
