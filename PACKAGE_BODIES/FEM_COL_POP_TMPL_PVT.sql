--------------------------------------------------------
--  DDL for Package Body FEM_COL_POP_TMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_COL_POP_TMPL_PVT" AS
/* $Header: FEMVCOTB.pls 120.0 2005/06/06 21:16:45 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME CONSTANT VARCHAR2(30) := 'FEM_BR_COLUMN_OBJ_TMPL_PVT;';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------




PROCEDURE CopyColPopTmpltRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
);


PROCEDURE DeleteColPopTmpltRec(
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
--   Creates all the detail records of a new Column Object Template Definition(target)
--   by copying the detail records of another Column Object Template Definition (source).
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

  g_api_name    CONSTANT VARCHAR2(30)   := 'CopyObjectDefinition';

BEGIN


  CopyColPopTmpltRec(
     p_source_obj_def_id   => p_source_obj_def_id
    ,p_target_obj_def_id   => p_target_obj_def_id
    ,p_created_by          => p_created_by
    ,p_creation_date       => p_creation_date

  );


EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;


--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Column Object Template Definition.
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

  g_api_name    CONSTANT VARCHAR2(30)   := 'DeleteObjectDefinition';

BEGIN

  DeleteColPopTmpltRec(
    p_obj_def_id          => p_obj_def_id
  );

EXCEPTION

  WHEN OTHERS THEN
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;



--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------



--
-- PROCEDURE
--	 CopyColPopTmpltRec
--
-- DESCRIPTION
--   Creates a new Column Object Template Definition  by copying records in the
--   FEM_COL_POP_TMPLT_DTL table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyColPopTmpltRec(
   p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id   IN          NUMBER
  ,p_created_by          IN          NUMBER
  ,p_creation_date       IN          DATE
)
--------------------------------------------------------------------------------
IS

  l_row_id               VARCHAR2(500);
  l_last_updated_by 	 NUMBER;
  l_last_update_login 	 NUMBER;
  l_source_table_name    VARCHAR2(50);

BEGIN

  l_last_updated_by   := FND_GLOBAL.USER_ID;
  l_last_update_login := FND_GLOBAL.LOGIN_ID;

  INSERT INTO FEM_COL_POPULATION_TMPLT_VL(
   COL_POP_TEMPLT_OBJ_DEF_ID
  ,TARGET_TABLE_NAME
  ,TARGET_COLUMN_NAME
  ,DATA_POPULATION_METHOD_CODE
  ,SOURCE_TABLE_NAME
  ,SOURCE_COLUMN_NAME
  ,DIMENSION_ID
  ,ATTRIBUTE_ID
  ,ATTRIBUTE_VERSION_ID
  ,AGGREGATION_METHOD
  ,CONSTANT_NUMERIC_VALUE
  ,CONSTANT_ALPHANUMERIC_VALUE
  ,CONSTANT_DATE_VALUE
  ,CREATED_BY
  ,CREATION_DATE
  ,LAST_UPDATED_BY
  ,LAST_UPDATE_DATE
  ,LAST_UPDATE_LOGIN
  ,OBJECT_VERSION_NUMBER
  ,SYSTEM_RESERVED_FLAG
  ,ENG_PROC_PARAM
  ,PARAMETER_FLAG
  ,DESCRIPTION
 ) SELECT
   p_target_obj_def_id
  ,TARGET_TABLE_NAME
  ,TARGET_COLUMN_NAME
  ,DATA_POPULATION_METHOD_CODE
  ,SOURCE_TABLE_NAME
  ,SOURCE_COLUMN_NAME
  ,DIMENSION_ID
  ,ATTRIBUTE_ID
  ,ATTRIBUTE_VERSION_ID
  ,AGGREGATION_METHOD
  ,CONSTANT_NUMERIC_VALUE
  ,CONSTANT_ALPHANUMERIC_VALUE
  ,CONSTANT_DATE_VALUE
  ,NVL(p_created_by,created_by)
  ,NVL(p_creation_date,creation_date)
  ,FND_GLOBAL.user_id
  ,SYSDATE
  ,FND_GLOBAL.login_id
  ,OBJECT_VERSION_NUMBER
  ,SYSTEM_RESERVED_FLAG
  ,ENG_PROC_PARAM
  ,PARAMETER_FLAG
  ,DESCRIPTION
FROM FEM_COL_POPULATION_TMPLT_VL
WHERE COL_POP_TEMPLT_OBJ_DEF_ID = p_source_obj_def_id;

END CopyColPopTmpltRec;


--
-- PROCEDURE
--	 DeleteCalRuleRec
--
-- DESCRIPTION
--   Deletes a Column Object Template Definition by performing deletes on records
--   in the FEM_COL_POP_TMPLT_DTL table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteColPopTmpltRec(
  p_obj_def_id   IN  NUMBER
)
--------------------------------------------------------------------------------
IS
BEGIN


  DELETE FROM FEM_COL_POPULATION_TMPLT_VL
  WHERE COL_POP_TEMPLT_OBJ_DEF_ID = p_obj_def_id;

END DeleteColPopTmpltRec;


END FEM_COL_POP_TMPL_PVT;

/
