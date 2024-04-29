--------------------------------------------------------
--  DDL for Package FEM_BR_DATASET_GROUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_BR_DATASET_GROUP_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVDSGS.pls 120.0 2005/06/06 20:14:14 appldev noship $ */

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
--   Deletes all the details records of a Dataset Group Rule Definition.
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



END FEM_BR_DATASET_GROUP_PVT;

 

/
