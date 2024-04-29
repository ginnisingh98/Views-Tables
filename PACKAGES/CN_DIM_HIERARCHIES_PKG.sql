--------------------------------------------------------
--  DDL for Package CN_DIM_HIERARCHIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_DIM_HIERARCHIES_PKG" AUTHID CURRENT_USER AS
--$Header: cndidhs.pls 120.3 2005/12/14 00:26:34 hanaraya noship $

-- Procedure Name
--   insert_row
-- Purpose
--   Insert row into cn_dim_hierarchies
-- History
--   18-MAY-2001  mblum          Created
--
PROCEDURE insert_row
  (x_header_dim_hierarchy_id   IN CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE,
   x_start_date                IN CN_DIM_HIERARCHIES.START_DATE%TYPE,
   x_end_date                  IN CN_DIM_HIERARCHIES.END_DATE%TYPE,
   x_root_node                OUT NOCOPY CN_DIM_HIERARCHIES.ROOT_NODE%TYPE,
   x_dim_hierarchy_id         OUT NOCOPY CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   x_org_id                     IN CN_DIM_HIERARCHIES.ORG_ID%TYPE);

--
-- Procedure Name
--   update_row
-- Purpose
--   Update a row in cn_dim_hierarchies
-- History
--   18-MAY-2001  mblum          Created
--
PROCEDURE update_row
  (x_dim_hierarchy_id          IN CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   x_header_dim_hierarchy_id   IN CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE,
   x_start_date                IN CN_DIM_HIERARCHIES.START_DATE%TYPE,
   x_end_date                  IN CN_DIM_HIERARCHIES.END_DATE%TYPE,
   x_root_node                 IN CN_DIM_HIERARCHIES.ROOT_NODE%TYPE,
   x_object_version_number     IN OUT NOCOPY CN_DIM_HIERARCHIES.OBJECT_VERSION_NUMBER%TYPE,
   x_org_id                     IN CN_DIM_HIERARCHIES.ORG_ID%TYPE);




--
-- Procedure Name
--   delete_row
-- Purpose
--   Delete a row from cn_dim_hierarchies
-- History
--   18-MAY-2001  mblum          Created
--
PROCEDURE delete_row
  (x_dim_hierarchy_id          IN CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE);

END CN_DIM_HIERARCHIES_PKG;

 

/
