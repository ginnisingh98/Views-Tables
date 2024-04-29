--------------------------------------------------------
--  DDL for Package Body FEM_BR_CONDITION_DIMENSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_CONDITION_DIMENSION_PVT" AS
/* $Header: FEMVCONDDIMB.pls 120.2.12010000.1 2008/12/11 01:02:46 huli noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'FEM_BR_CONDITION_DIMENSION_PVT';
G_FEM                       constant varchar2(3)    := 'FEM';
G_BLOCK                     constant varchar2(80)   := G_FEM||'.PLSQL.'||G_PKG_NAME;

-- Log Level Constants
G_LOG_LEVEL_1               constant number := FND_LOG.Level_Statement;
G_LOG_LEVEL_2               constant number := FND_LOG.Level_Procedure;
G_LOG_LEVEL_3               constant number := FND_LOG.Level_Event;
G_LOG_LEVEL_4               constant number := FND_LOG.Level_Exception;
G_LOG_LEVEL_5               constant number := FND_LOG.Level_Error;
G_LOG_LEVEL_6               constant number := FND_LOG.Level_Unexpected;


--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Condition Dimension Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
)
--------------------------------------------------------------------------------
IS

  l_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';

  l_prg_msg                       VARCHAR2(2000);
  l_callstack                     VARCHAR2(2000);

  l_object_type_code fem_object_types.object_type_code%TYPE := NULL;

  CURSOR c_object_type IS
     SELECT object_type_code
     FROM fem_object_catalog_b
     WHERE object_id = (SELECT object_id
                        FROM fem_object_definition_b
                        WHERE object_definition_id = p_obj_def_id);

BEGIN

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'BEGIN, p_obj_def_id:' || p_obj_def_id
  );
  OPEN c_object_type;
  FETCH c_object_type INTO l_object_type_code;
  CLOSE c_object_type;
  IF (l_object_type_code IS NOT NULL AND l_object_type_code = 'CONDITION_DIMENSION_COMPONENT') THEN
     delete from fem_cond_dim_cmp_dtl
     where cond_dim_cmp_obj_def_id = p_obj_def_id;

     delete from fem_cond_dim_components
     where cond_dim_cmp_obj_def_id = p_obj_def_id;
  ELSE
     fem_engines_pkg.user_message(p_app_name =>'FEM',
     p_msg_name => 'FEM_INVALID_OBJECT_TYPE',
     p_token1 => 'OBJTYPE',
     p_value1 => l_object_type_code);
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  FEM_ENGINES_PKG.Tech_Message (
    p_severity  => G_LOG_LEVEL_3
    ,p_module   => G_BLOCK||'.'||l_api_name
    ,p_msg_text => 'END'
  );

EXCEPTION

  when others then
     l_callstack := DBMS_UTILITY.Format_Call_Stack;
     l_prg_msg := SQLERRM;
     FEM_ENGINES_PKG.Tech_Message (
       p_severity  => G_LOG_LEVEL_6
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'others condition, l_callstack:' || l_callstack
     );
     FEM_ENGINES_PKG.Tech_Message (
       p_severity  => G_LOG_LEVEL_6
       ,p_module   => G_BLOCK||'.'||l_api_name
       ,p_msg_text => 'others condition, l_prg_msg:' || l_prg_msg
     );

    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;



END FEM_BR_CONDITION_DIMENSION_PVT;

/
