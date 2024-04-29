--------------------------------------------------------
--  DDL for Package Body PFT_BR_PROFIT_CALC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_BR_PROFIT_CALC_PVT" AS
/* $Header: PFTVPCAB.pls 120.1 2005/06/20 08:40:10 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------
G_PKG_NAME CONSTANT VARCHAR2(30) := 'PFT_BR_PROFIT_CALC_PVT;';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------




PROCEDURE CopyCalRuleRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
);


PROCEDURE DeleteCalRuleRec(
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
--   Creates all the detail records of a new Profit Calculation Rule Definition (target)
--   by copying the detail records of another Profit Calculation Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id    IN         NUMBER
  ,p_target_obj_def_id   IN         NUMBER
  ,p_created_by          IN         NUMBER
  ,p_creation_date       IN         DATE
)
--------------------------------------------------------------------------------
IS

  G_API_NAME    CONSTANT VARCHAR2(30)   := 'CopyObjectDefinition';

BEGIN


  CopyCalRuleRec(
     p_source_obj_def_id  =>  p_source_obj_def_id
    ,p_target_obj_def_id  =>  p_target_obj_def_id
    ,p_created_by         =>  p_created_by
    ,p_creation_date      =>  p_creation_date
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
--   Deletes all the details records of a Profit Calculation Rule Definition.
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

  DeleteCalRuleRec(
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
--	 CopyCalRuleRec
--
-- DESCRIPTION
--   Creates a new Profit Calculation Rule Definition Formula by copying records in the
--   PFT_PPROF_CALC_RULES table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyCalRuleRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
)
--------------------------------------------------------------------------------
IS
BEGIN

  INSERT INTO PFT_PPROF_CALC_RULES (
    PPROF_CALC_OBJ_DEF_ID
    ,VALUE_INDEX_FORMULA_ID
    ,CONDITION_OBJ_ID
    ,REGION_COUNTING_FLAG
    ,PROFT_PERCENTILE_FLAG
    ,VALUE_INDEX_FLAG
    ,PROSPECT_IDENT_FLAG
    ,HIERARCHY_OBJ_ID
    ,CUSTOMER_LEVEL
    ,OUTPUT_COLUMN
    ,CREATED_BY
    ,CREATION_DATE
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number

  ) SELECT
    p_target_obj_def_id
    ,VALUE_INDEX_FORMULA_ID
    ,CONDITION_OBJ_ID
    ,REGION_COUNTING_FLAG
    ,PROFT_PERCENTILE_FLAG
    ,VALUE_INDEX_FLAG
    ,PROSPECT_IDENT_FLAG
    ,HIERARCHY_OBJ_ID
    ,CUSTOMER_LEVEL
    ,OUTPUT_COLUMN
    ,NVL(p_created_by,created_by)
    ,NVL(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,SYSDATE
    ,FND_GLOBAL.login_id
    ,object_version_number
  FROM PFT_PPROF_CALC_RULES
  WHERE PPROF_CALC_OBJ_DEF_ID = p_source_obj_def_id;

END CopyCalRuleRec;


--
-- PROCEDURE
--	 DeletCalRuleRec
--
-- DESCRIPTION
--   Deletes a Profit Calculation Rule Definition by performing deletes on records
--   in the PFT_PPROF_CALC_RULES table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteCalRuleRec(
  p_obj_def_id IN NUMBER
)
--------------------------------------------------------------------------------
IS
BEGIN

  DELETE FROM PFT_PPROF_CALC_RULES
  WHERE PPROF_CALC_OBJ_DEF_ID = p_obj_def_id;

END DeleteCalRuleRec;


END PFT_BR_PROFIT_CALC_PVT;

/
