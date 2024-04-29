--------------------------------------------------------
--  DDL for Package Body FEM_BR_DATASET_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_DATASET_GROUP_PVT" AS
/* $Header: FEMVDSGB.pls 120.0 2005/06/06 20:59:47 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'FEM_BR_DATASET_GROUP_PVT';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE DeleteDatasetGroup(
  p_obj_def_id in number
);

PROCEDURE DeleteInputDatasets(
  p_obj_def_id in number
);

PROCEDURE CopyDatasetGroup(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyInputDatasets(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

--------------------------------------------------------------------------------
-- PUBLIC BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Dataset Group Rule Definition.
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

  DeleteDatasetGroup(
    p_obj_def_id     => p_obj_def_id
  );

  DeleteInputDatasets(
    p_obj_def_id     => p_obj_def_id
  );

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
--   Creates all the detail records of a new Dataset Group Rule Definition (target)
--   by copying the detail records of another Dataset Group Rule Definition (source).
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

  CopyDatasetGroup(
    p_source_obj_def_id     => p_source_obj_def_id
    ,p_target_obj_def_id    => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyInputDatasets(
    p_source_obj_def_id     => p_source_obj_def_id
    ,p_target_obj_def_id    => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

EXCEPTION

  when others then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, g_api_name);
    raise FND_API.G_EXC_UNEXPECTED_ERROR;

END CopyObjectDefinition;



--------------------------------------------------------------------------------
-- PRIVATE BODIES
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 DeleteDatasetGroup
--
-- DESCRIPTION
--   Deletes a Dataset Group Rule Definition by performing deletes on records
--   in the FEM_DS_INPUT_OUTPUT_DEFS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteDatasetGroup(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_ds_input_output_defs
  where dataset_io_obj_def_id = p_obj_def_id;

END DeleteDatasetGroup;


--
-- PROCEDURE
--	 DeleteInputDatasets
--
-- DESCRIPTION
--   Deletes a Dataset Group Rule Definition by performing deletes on records
--   in the FEM_DS_INPUT_LISTS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteInputDatasets(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_ds_input_lists
  where dataset_io_obj_def_id = p_obj_def_id;

END DeleteInputDatasets;


--
-- PROCEDURE
--	 CopyDatasetGroup
--
-- DESCRIPTION
--   Creates a new Dataset Group Rule Definition by copying records in the
--   FEM_DS_INPUT_OUTPUT_DEFS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyDatasetGroup(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_ds_input_output_defs(
    dataset_io_obj_def_id
    ,output_dataset_code
    ,calendar_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,output_dataset_code
    ,calendar_id
    ,nvl(p_created_by,FND_GLOBAL.user_id)
    ,nvl(p_creation_date,sysdate)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,1
  from fem_ds_input_output_defs
  where dataset_io_obj_def_id = p_source_obj_def_id;

END CopyDatasetGroup;



--
-- PROCEDURE
--	 CopyInputDatasets
--
-- DESCRIPTION
--   Creates a new Dataset Group Rule Definition by copying records in the
--   FEM_DS_INPUT_LISTS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyInputDatasets(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_ds_input_lists(
    dataset_io_obj_def_id
    ,input_list_item_num
    ,input_dataset_code
    ,absolute_cal_period_flag
    ,absolute_cal_period_id
    ,use_default_dim_grp_id_code
    ,relative_dimension_group_id
    ,relative_cal_period_offset
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,fem_input_list_item_num_seq.nextval
    ,input_dataset_code
    ,absolute_cal_period_flag
    ,absolute_cal_period_id
    ,use_default_dim_grp_id_code
    ,relative_dimension_group_id
    ,relative_cal_period_offset
    ,nvl(p_created_by,FND_GLOBAL.user_id)
    ,nvl(p_creation_date,sysdate)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,1
  from fem_ds_input_lists
  where dataset_io_obj_def_id = p_source_obj_def_id;

END CopyInputDatasets;



END FEM_BR_DATASET_GROUP_PVT;

/
