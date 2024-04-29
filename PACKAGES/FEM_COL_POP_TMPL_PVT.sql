--------------------------------------------------------
--  DDL for Package FEM_COL_POP_TMPL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_COL_POP_TMPL_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVCOTS.pls 120.0 2005/06/06 19:20:52 appldev noship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------


--
-- PROCEDURE
--	 CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a new Column Object Template Definition (target)
--   by copying the detail records of another Column Object Template Rule Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).
--   p_object_type_code     - Object Type Code.
--   p_source_table_name    - Source Table Name.
--
PROCEDURE CopyObjectDefinition(
   p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id   IN          NUMBER
  ,p_created_by          IN          NUMBER
  ,p_creation_date       IN          DATE
  );

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
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          IN          NUMBER
);


END FEM_COL_POP_TMPL_PVT;
 

/
