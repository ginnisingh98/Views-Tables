--------------------------------------------------------
--  DDL for Package Body FEM_BR_DATA_INSPECTOR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FEM_BR_DATA_INSPECTOR_PVT" AS
/* $Header: FEMVDIB.pls 120.0 2005/06/06 19:50:15 appldev noship $ */

--------------------------------------------------------------------------------
-- PRIVATE CONSTANTS
--------------------------------------------------------------------------------

G_PKG_NAME constant varchar2(30) := 'FEM_BR_DATA_INSPECTOR_PVT';

--------------------------------------------------------------------------------
-- PRIVATE SPECIFICATIONS
--------------------------------------------------------------------------------

PROCEDURE DeleteDataInspector(
  p_obj_def_id in number
);

PROCEDURE DeleteDataInspectorCols(
  p_obj_def_id in number
);

PROCEDURE CopyDataInspector(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

PROCEDURE CopyDataInspectorCols(
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
--   Deletes all the details records of a Data Inspector Rule Definition.
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

  DeleteDataInspector(
    p_obj_def_id     => p_obj_def_id
  );

  DeleteDataInspectorCols(
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
--   Creates all the detail records of a new Data Inspector Rule Definition (target)
--   by copying the detail records of another Data Inspector Rule Definition (source).
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

  CopyDataInspector(
    p_source_obj_def_id     => p_source_obj_def_id
    ,p_target_obj_def_id    => p_target_obj_def_id
    ,p_created_by         => p_created_by
    ,p_creation_date      => p_creation_date
  );

  CopyDataInspectorCols(
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
--	 DeleteDataInspector
--
-- DESCRIPTION
--   Deletes a Data Inspector Rule Definition by performing deletes on records
--   in the FEM_DATA_INSPECTORS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteDataInspector(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_data_inspectors
  where data_inspector_obj_def_id = p_obj_def_id;

END DeleteDataInspector;


--
-- PROCEDURE
--	 DeleteDataInspectorCols
--
-- DESCRIPTION
--   Deletes a Data Inspector Rule Definition by performing deletes on records
--   in the FEM_DATA_INSPECTOR_COLS table.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
--------------------------------------------------------------------------------
PROCEDURE DeleteDataInspectorCols(
  p_obj_def_id in number
)
--------------------------------------------------------------------------------
IS
BEGIN

  delete from fem_data_inspector_cols
  where data_inspector_obj_def_id = p_obj_def_id;

END DeleteDataInspectorCols;


--
-- PROCEDURE
--	 CopyDataInspector
--
-- DESCRIPTION
--   Creates a new Data Inspector Rule Definition by copying records in the
--   FEM_DATA_INSPECTORS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyDataInspector(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_data_inspectors(
    data_inspector_obj_def_id
    ,table_name
    ,num_rows
    ,condition_obj_id
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,table_name
    ,num_rows
    ,condition_obj_id
    ,nvl(p_created_by,FND_GLOBAL.user_id)
    ,nvl(p_creation_date,sysdate)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,1
  from fem_data_inspectors
  where data_inspector_obj_def_id = p_source_obj_def_id;

END CopyDataInspector;



--
-- PROCEDURE
--	 CopyDataInspectorCols
--
-- DESCRIPTION
--   Creates a new Data Inspector Rule Definition by copying records in the
--   FEM_DATA_INSPECTOR_COLS table.
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
--------------------------------------------------------------------------------
PROCEDURE CopyDataInspectorCols(
  p_source_obj_def_id in number
  ,p_target_obj_def_id in number
  ,p_created_by         in          number
  ,p_creation_date      in          date
)
--------------------------------------------------------------------------------
IS
BEGIN

  insert into fem_data_inspector_cols(
    data_inspector_obj_def_id
    ,table_name
    ,column_name
    ,display_sequence
    ,editable_flag
    ,sort_sequence
    ,sort_direction_flag
    ,created_by
    ,creation_date
    ,last_updated_by
    ,last_update_date
    ,last_update_login
    ,object_version_number
  ) select
    p_target_obj_def_id
    ,table_name
    ,column_name
    ,display_sequence
    ,editable_flag
    ,sort_sequence
    ,sort_direction_flag
    ,nvl(p_created_by,FND_GLOBAL.user_id)
    ,nvl(p_creation_date,sysdate)
    ,FND_GLOBAL.user_id
    ,sysdate
    ,FND_GLOBAL.login_id
    ,1
  from fem_data_inspector_cols
  where data_inspector_obj_def_id = p_source_obj_def_id;

END CopyDataInspectorCols;



END FEM_BR_DATA_INSPECTOR_PVT;

/
