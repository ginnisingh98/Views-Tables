--------------------------------------------------------
--  DDL for Package FEM_BR_MAPPING_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_MAPPING_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVMAPS.pls 120.4.12010000.1 2008/07/24 11:02:34 appldev ship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 CopyObjectDetails
--
-- DESCRIPTION
--   Copies the object extension data for fem_alloc_br_objects
--   for mapping rules.
--
-- IN
--   p_copy_type_code       - Copy Type Code (ignored by procedure)
--   p_source_obj_def_id    - Source Object ID.
--   p_target_obj_def_id    - Target Object ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
PROCEDURE CopyObjectDetails (
  p_copy_type_code      in          varchar2
  ,p_source_obj_id      in          number
  ,p_target_obj_id      in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

--
-- PROCEDURE
--	 DeleteObjectDetails
--
-- DESCRIPTION
--   Deletes the object extension data from fem_alloc_br_objects
--   for mapping rules.
--
-- IN
--   p_obj_id    - Object ID.
--
PROCEDURE DeleteObjectDetails (
  p_obj_id              in          number
);


--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Mapping Rule Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          in          number
);


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Mapping Rule Definition (target)
--   by copying the detail records of another Mapping Rule Definition (source).
--
-- IN
--   p_copy_type_code       - Copy Type Code
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
PROCEDURE CopyObjectDefinition(
  p_copy_type_code     in          varchar2
  ,p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);

--
-- PROCEDURE
--	 synchronize_mapping_definition
--
-- DESCRIPTION
--   Synchronize the mappping definition with meta data.
--   Psudo code
--   Loop through all corresponding formula rows
--     for every formula row that includes a table
--       if the table is enabled
--         call synchronize_dim_rows
--       else if FEM_BALANCES is enabled
--         update the formula row with FEM_BALANCES
--         delete all corresponding rows in the FEM_ALLOC_BR_DIMENSIONS
--         populate default rows in the FEM_ALLOC_BR_DIMENSIONS for FEM_BALANCES
--       else if FEM_BALANCES is disabled
--         error out
--
-- IN
--   p_api_version          - API Version
--   p_init_msg_list        - Initialize Message List Flag (Boolean)
--   p_commit               - Commit Work Flag (Boolean)
--   p_obj_def_id           - Object Definition ID
--
-- OUT
--   x_return_status        - Return Status of API Call
--   x_msg_count            - Total Count of Error Messages in API Call
--   x_msg_data             - Error Message in API Call
--
PROCEDURE synchronize_mapping_definition(
   p_api_version                 in number
  ,p_init_msg_list               in varchar2 := FND_API.G_FALSE
  ,p_commit                      in varchar2 := FND_API.G_FALSE
  ,p_obj_def_id                  in number
  ,x_return_status               out nocopy  varchar2
  ,x_msg_count                   out nocopy  number
  ,x_msg_data                    out nocopy  varchar2
);



--
-- PROCEDURE
--	 delete_map_rule_content
--
-- DESCRIPTION
--   Deletes all the contents of the mapping rule definition.
--   except for the catalog data.
--   The helper records are not deleted by this API.
--
-- IN
--   p_object_definition_id    - Object Definition ID.
--
PROCEDURE delete_map_rule_content(
  p_object_definition_id          in          number
);

-- Bug#6496686 -- Begin
--
-- PROCEDURE
--	 DeleteTuningOptionDetails
--
-- DESCRIPTION
--   Deletes any other details associated with a mapping rule.
--
-- IN
--   p_obj_id    - Object ID
--
PROCEDURE DeleteTuningOptionDetails(
  p_obj_id          in          number
);
-- Bug#6496686 -- End

END FEM_BR_MAPPING_RULE_PVT;

/
