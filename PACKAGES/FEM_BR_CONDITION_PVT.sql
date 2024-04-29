--------------------------------------------------------
--  DDL for Package FEM_BR_CONDITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_CONDITION_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVCONDS.pls 120.0.12010000.1 2008/07/24 11:02:10 appldev ship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------

--
-- PROCEDURE
--	 DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records of a Condition Rule Definition.
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
--   Creates all the detail records of a new Condition Definition (target)
--   by copying the detail records of another Condition Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--
PROCEDURE CopyObjectDefinition(
  p_source_obj_def_id   in          number
  ,p_target_obj_def_id  in          number
  ,p_created_by         in          number
  ,p_creation_date      in          date
);


--
-- PROCEDURE
--	 DeleteCondComponent
--
-- DESCRIPTION
--   Deletes all the details records of a Condition Component
--
-- IN
--   p_cond_component_obj_id    - Component Object ID.
--   p_data_dim_flag - Component type
--
PROCEDURE DeleteCondComponent(
  p_condition_obj_def_id             in number
  ,p_cond_component_obj_id         in          number
  ,p_data_dim_flag                in          char
  ,p_init_msg_list                in          varchar2
  ,x_return_status                out nocopy  varchar2
  ,x_msg_count                    out nocopy  number
  ,x_msg_data                     out nocopy  varchar2
);



END FEM_BR_CONDITION_PVT;

/
