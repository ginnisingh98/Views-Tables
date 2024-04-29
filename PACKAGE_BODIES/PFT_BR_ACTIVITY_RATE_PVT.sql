--------------------------------------------------------
--  DDL for Package Body PFT_BR_ACTIVITY_RATE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PFT_BR_ACTIVITY_RATE_PVT" AS
/* $Header: PFTVRATB.pls 120.0 2005/06/06 19:08:04 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'PFT_BR_ACTIVITY_RATE_PVT';

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
--   Deletes all the details records of an Activity Rate Definition.
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

  delete from PFT_ACTIVITY_DRIVER_ASGN
  where activity_rate_obj_def_id = p_obj_def_id;

  delete from PFT_ACTIVITY_RATES
  where activity_rate_obj_def_id = p_obj_def_id;

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
--   Creates all the detail records of a new Activity Rate Definition
--   (target) by copying the detail records of another Activity Rate
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

  insert into pft_activity_rates (
    activity_rate_obj_def_id
    ,activity_hier_obj_id
    ,currency_code
    ,condition_obj_id
    ,top_nodes_flag
    ,output_to_rate_stat_flag
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,activity_hier_obj_id
    ,currency_code
    ,condition_obj_id
    ,top_nodes_flag
    ,output_to_rate_stat_flag
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from pft_activity_rates
  where activity_rate_obj_def_id = p_source_obj_def_id;



  insert into pft_activity_driver_asgn (
    activity_rate_obj_def_id
    ,activity_id
    ,source_table_name
    ,column_name
    ,statistic_basis_id
    ,condition_obj_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,activity_id
    ,source_table_name
    ,column_name
    ,statistic_basis_id
    ,condition_obj_id
    ,nvl(p_created_by,created_by)
    ,nvl(p_creation_date,creation_date)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,object_version_number
  from pft_activity_driver_asgn
  where activity_rate_obj_def_id = p_source_obj_def_id;


EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;



END PFT_BR_ACTIVITY_RATE_PVT;

/
