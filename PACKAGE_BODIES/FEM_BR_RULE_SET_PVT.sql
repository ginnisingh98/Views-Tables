--------------------------------------------------------
--  DDL for Package Body FEM_BR_RULE_SET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_RULE_SET_PVT" AS
/* $Header: FEMVRUSB.pls 120.0 2005/06/06 19:47:24 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FEM_BR_RULE_SET_PVT;';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------




PROCEDURE CopyRuleSetRec(
   p_source_obj_def_id   IN          NUMBER
   ,p_target_obj_def_id  IN          NUMBER
   ,p_created_by         IN          NUMBER
   ,p_creation_date      IN          DATE
);

PROCEDURE CopyMembersRec(
   p_source_obj_def_id   IN          NUMBER
   ,p_target_obj_def_id  IN          NUMBER
   ,p_created_by         IN          NUMBER
   ,p_creation_date      IN          DATE
  );

PROCEDURE DeleteRuleSetRec(
   p_obj_def_id          IN          NUMBER
);

PROCEDURE DeleteMembersRec(
   p_obj_def_id          IN          NUMBER
);

--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates the detail records of a new Rule Set Definition (target)
--   by copying the detail records of another Rule Set Definition Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
)
--------------------------------------------------------------------------------
IS

  G_API_NAME    CONSTANT VARCHAR2(30)   := 'CopyObjectDefinition';

BEGIN


  CopyRuleSetRec(
     p_source_obj_def_id  => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyMembersRec(
     p_source_obj_def_id  => p_source_obj_def_id
    ,p_target_obj_def_id  => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, G_API_NAME);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;


END CopyObjectDefinition;


--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Rule Set Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          IN          NUMBER
)
--------------------------------------------------------------------------------
IS

  G_API_NAME    CONSTANT VARCHAR2(30)   := 'DeleteObjectDefinition';

BEGIN

  DeleteRuleSetRec(
     p_obj_def_id  =>  p_obj_def_id
  );

  DeleteMembersRec(
     p_obj_def_id  =>  p_obj_def_id
  );

EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, G_API_NAME);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;



--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------



--
-- PROCEDURE
--	 CopyRuleSetRec
--
-- DESCRIPTION
--   Creates a new Rule Set Definition by copying records in the
--   FEM_RULE_SETS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyRuleSetRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
)
--------------------------------------------------------------------------------
IS
BEGIN

  INSERT INTO FEM_RULE_SETS (
    RULE_SET_OBJ_DEF_ID
    ,RULE_SET_OBJECT_TYPE_CODE
    ,OBJECT_VERSION_NUMBER
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
  ) SELECT
    p_target_obj_def_id
    ,RULE_SET_OBJECT_TYPE_CODE
    ,OBJECT_VERSION_NUMBER
    ,NVL(p_creation_date,creation_date)
    ,NVL(p_created_by,created_by)
    ,SYSDATE
    ,FND_GLOBAL.user_id
    ,FND_GLOBAL.login_id
  FROM FEM_RULE_SETS
  WHERE RULE_SET_OBJ_DEF_ID = p_source_obj_def_id;

END CopyRuleSetRec;


--
-- PROCEDURE
--	 CopyMembersRec
--
-- DESCRIPTION
--   Creates a new Rule Set Members by copying records in the
--   FEM_RULE_SET_MEMBERS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyMembersRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
)
--------------------------------------------------------------------------------
IS
BEGIN

  INSERT INTO FEM_RULE_SET_MEMBERS (
    RULE_SET_OBJ_DEF_ID
    ,CHILD_OBJ_ID
    ,CHILD_EXECUTION_SEQUENCE
    ,EXECUTE_CHILD_FLAG
    ,OBJECT_VERSION_NUMBER
    ,CREATION_DATE
    ,CREATED_BY
    ,LAST_UPDATE_DATE
    ,LAST_UPDATED_BY
    ,LAST_UPDATE_LOGIN
  ) SELECT
    p_target_obj_def_id
    ,CHILD_OBJ_ID
    ,CHILD_EXECUTION_SEQUENCE
    ,EXECUTE_CHILD_FLAG
    ,OBJECT_VERSION_NUMBER
    ,NVL(p_creation_date,creation_date)
    ,NVL(p_created_by,created_by)
    ,SYSDATE
    ,FND_GLOBAL.user_id
    ,FND_GLOBAL.login_id
  FROM FEM_RULE_SET_MEMBERS
  WHERE RULE_SET_OBJ_DEF_ID = p_source_obj_def_id;

END CopyMembersRec;

--
-- PROCEDURE
--	 DeletRuleSetRec
--
-- DESCRIPTION
--   Deletes a Rule Set Definition by performing deletes on records
--   in the FEM_RULE_SETS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteRuleSetRec(
  p_obj_def_id IN NUMBER
)
--------------------------------------------------------------------------------
IS
BEGIN

  DELETE FROM FEM_RULE_SETS
  WHERE RULE_SET_OBJ_DEF_ID = p_obj_def_id;

END DeleteRuleSetRec;


--
-- PROCEDURE
--	 DeleteMembersRec
--
-- DESCRIPTION
--   Deletes Rule Set Members by performing deletes on records
--   in the FEM_RULE_SET_MEMBERS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteMembersRec(
  p_obj_def_id IN NUMBER
)
--------------------------------------------------------------------------------
IS
BEGIN

  DELETE FROM FEM_RULE_SET_MEMBERS
  WHERE RULE_SET_OBJ_DEF_ID = p_obj_def_id;

END DeleteMembersRec;


END FEM_BR_RULE_SET_PVT;

/
