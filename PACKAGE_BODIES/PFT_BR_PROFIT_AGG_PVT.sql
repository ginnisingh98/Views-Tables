--------------------------------------------------------
--  DDL for Package Body PFT_BR_PROFIT_AGG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_BR_PROFIT_AGG_PVT" AS
/* $Header: PFTVPAGB.pls 120.0 2005/06/06 18:59:20 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'PFT_BR_PROFIT_AGG_PVT;';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------




PROCEDURE CopyAggRuleRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
);


PROCEDURE DeleteAggRuleRec(
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
--   Creates all the detail records of a new Profit Aggregation Rule Definition (target)
--   by copying the detail records of another Profit Aggregation Rule Definition (source).
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


  CopyAggRuleRec(
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
--   Deletes all the details records of a Profit Aggregation Rule Definition.
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

  DeleteAggRuleRec(
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
--	 CopyAggRuleRec
--
-- DESCRIPTION
--   Creates a new Profit Aggregation Rule Definition Formula by copying records in the
--   PFT_PPROF_AGG_RULES table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyAggRuleRec(
  p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id  IN          NUMBER
  ,p_created_by         IN          NUMBER
  ,p_creation_date      IN          DATE
)
--------------------------------------------------------------------------------
IS
BEGIN

  INSERT INTO PFT_PPROF_AGG_RULES (
     pprof_agg_obj_def_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
    ,col_tmplt_obj_id
    ,condition_obj_id
    ,hierarchy_obj_id
    ,dimension_grp_id_from
    ,dimension_grp_id_to
  ) SELECT
     p_target_obj_def_id
    ,NVL(p_created_by,created_by)
    ,NVL(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,SYSDATE
    ,FND_GLOBAL.login_id
    ,object_version_number
    ,col_tmplt_obj_id
    ,condition_obj_id
    ,hierarchy_obj_id
    ,dimension_grp_id_from
    ,dimension_grp_id_to
  FROM pft_pprof_agg_rules
  WHERE pprof_agg_obj_def_id = p_source_obj_def_id;

END CopyAggRuleRec;


--
-- PROCEDURE
--	 DeletAggRuleRec
--
-- DESCRIPTION
--   Deletes a Profit Aggregation Rule Definition by performing deletes on records
--   in the PFT_PPROF_AGG_RULES table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteAggRuleRec(
  p_obj_def_id  IN   NUMBER
)
--------------------------------------------------------------------------------
IS
BEGIN

  DELETE FROM PFT_PPROF_AGG_RULES
  WHERE PPROF_AGG_OBJ_DEF_ID = p_obj_def_id;

END DeleteAggRuleRec;



END PFT_BR_PROFIT_AGG_PVT;

/
