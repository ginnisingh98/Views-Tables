--------------------------------------------------------
--  DDL for Package Body PFT_BR_COUC_ROLLUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_BR_COUC_ROLLUP_PVT" AS
/* $Header: PFTVCORB.pls 120.0 2005/06/06 19:02:57 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'PFT_BR_COUC_ROLLUP_PVT';

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
--   Deletes all the details records of a Cost Object Unit Cost Rollup Rule Definition.
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

  g_api_name    constant varchar2(30)   := 'DeleteObjectDefinition';

BEGIN

  delete from PFT_COUC_ROLLUP_RULES
  where couc_rollup_obj_def_id = p_obj_def_id;

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END DeleteObjectDefinition;


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Cost Object Unit Cost Rollup Rule Definition
--   (target) by copying the detail records of another Cost Object Unit Cost Rollup Rule
--   Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS

  g_api_name    constant varchar2(30)   := 'CopyObjectDefinition';

BEGIN

  insert into PFT_COUC_ROLLUP_RULES(
    couc_rollup_obj_def_id
    ,cost_object_hier_obj_id
    ,currency_code
    ,condition_obj_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,cost_object_hier_obj_id
    ,currency_code
    ,condition_obj_id
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from PFT_COUC_ROLLUP_RULES
  where couc_rollup_obj_def_id = p_source_obj_def_id;


EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;



END PFT_BR_COUC_ROLLUP_PVT;

/
