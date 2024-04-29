--------------------------------------------------------
--  DDL for Package FEM_FUNC_DIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_FUNC_DIM_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVFUNCDIMS.pls 120.0 2006/05/11 05:46:10 ahyanki noship $ */

--------------------------------------------------------------------------------
-- PUBLIC CONSTANTS
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- PUBLIC SPECIFICATIONS
--------------------------------------------------------------------------------


--
-- PROCEDURE
--       CopyObjectDefinition
--
-- DESCRIPTION
--   Creates all the detail records of a Functional Dimension Definition (target)
--   by copying the detail records of another Functional Dimension Definition (source).
--
-- IN
--   p_source_obj_def_id    - Source Object Definition ID.
--   p_target_obj_def_id    - Target Object Definition ID.
--   p_created_by           - FND User ID (optional).
--   p_creation_date        - System Date (optional).

PROCEDURE CopyObjectDefinition(
   p_source_obj_def_id   IN          NUMBER
  ,p_target_obj_def_id   IN          NUMBER
  ,p_created_by          IN          NUMBER
  ,p_creation_date       IN          DATE
  );

--
-- PROCEDURE
--       DeleteObjectDefinition
--
-- DESCRIPTION
--   Deletes all the details records related to a FUnctional Dimension Definition.
--
-- IN
--   p_obj_def_id    - Object Definition ID.
--
PROCEDURE DeleteObjectDefinition(
  p_obj_def_id          IN          NUMBER
);

--
-- PROCEDURE
--       GetDataColumnDimension
--
-- DESCRIPTION
--   Fetches dimension_id and functional dimension set name for a given
--   version id, table name and column name
--
-- IN
--   p_version_id    - given version id.
--   p_table_name    - given table name.
--   p_column_name   - given column name.
--   x_dimension_id  - out parameter for dimension id.
--   x_func_dim_set_name -  out parameter for functional dimension set name.
--
PROCEDURE GetDataColumnDimension(
  p_version_id IN NUMBER
 ,p_table_name IN VARCHAR2
 ,p_column_name IN VARCHAR2
 ,x_dimension_id OUT NOCOPY NUMBER
 ,x_func_dim_set_name OUT NOCOPY VARCHAR2
 );

--
-- PROCEDURE
--       UpdateColumnDisplayNames
--
-- DESCRIPTION
--   Updates display name for a column-table combination in FEM_TAB_COLUMNS_VL depending upon given
--   p_set_ids in a collection
-- IN
--   p_sets  - given set ids.
--
PROCEDURE UpdateColumnDisplayNames(
 p_api_version                IN   NUMBER,
 p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
 p_commit                     IN   VARCHAR2 := FND_API.G_FALSE,
 p_validation_level           IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
 x_return_status              OUT  NOCOPY      VARCHAR2,
 x_msg_count                  OUT  NOCOPY      NUMBER,
 x_msg_data                   OUT  NOCOPY      VARCHAR2,
 --
 p_sets IN FEM_FUNC_DIM_SET_TYP
 );


END FEM_FUNC_DIM_PVT;
 

/
