--------------------------------------------------------
--  DDL for Package CN_DIM_HIERARCHIES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_DIM_HIERARCHIES_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvdimhs.pls 120.3 2005/12/13 02:01:02 hanaraya noship $

-- Create a new hierarchy type
PROCEDURE Create_Hierarchy_Type
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_name                       IN      CN_DIMENSIONS.NAME%TYPE,
   p_base_table_id              IN      CN_OBJ_TABLES_V.TABLE_ID%TYPE,
   p_primary_key_id             IN      CN_OBJ_COLUMNS_V.COLUMN_ID%TYPE,
   p_user_column_id             IN      CN_OBJ_COLUMNS_V.COLUMN_ID%TYPE,
    --R12 MOAC Changes--Start
   p_org_id			IN		CN_DIMENSIONS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   p_description                IN      CN_DIMENSIONS.DESCRIPTION%TYPE, -- Added for R12
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_dimension_id               OUT NOCOPY     CN_DIMENSIONS.DIMENSION_ID%TYPE);

-- Update hierarchy type (only name is updateable)
PROCEDURE Update_Hierarchy_Type
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_id               IN      CN_DIMENSIONS.DIMENSION_ID%TYPE,
   p_name                       IN      CN_DIMENSIONS.NAME%TYPE,
   p_object_version_number      IN  OUT NOCOPY    CN_DIMENSIONS.OBJECT_VERSION_NUMBER%TYPE,
    --R12 MOAC Changes--Start
   p_org_id			IN		CN_DIMENSIONS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   p_description                IN      CN_DIMENSIONS.DESCRIPTION%TYPE, -- Added for R12
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Delete hierarchy type
PROCEDURE Delete_Hierarchy_Type
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_id               IN      CN_DIMENSIONS.DIMENSION_ID%TYPE,
    --R12 MOAC Changes--Start
   p_org_id			IN		CN_DIMENSIONS.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Create head hierarchy
PROCEDURE Create_Head_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dimension_id               IN      CN_HEAD_HIERARCHIES.DIMENSION_ID%TYPE,
   p_name                       IN      CN_HEAD_HIERARCHIES.NAME%TYPE,
    --R12 MOAC Changes--Start
   p_org_id			IN		CN_HEAD_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_head_hierarchy_id          OUT NOCOPY     CN_HEAD_HIERARCHIES.HEAD_HIERARCHY_ID%TYPE);

-- Update head hierarchy (only name is updateable)
PROCEDURE Update_Head_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_head_hierarchy_id          IN      CN_HEAD_HIERARCHIES.HEAD_HIERARCHY_ID%TYPE,
   p_name                       IN      CN_HEAD_HIERARCHIES.NAME%TYPE,
   p_object_version_number      IN   OUT NOCOPY   CN_HEAD_HIERARCHIES.OBJECT_VERSION_NUMBER%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		CN_HEAD_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Delete head hierarchy
PROCEDURE Delete_Head_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_head_hierarchy_id          IN      CN_HEAD_HIERARCHIES.HEAD_HIERARCHY_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		CN_HEAD_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Create dimension hierarchy
PROCEDURE Create_Dim_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_head_hierarchy_id          IN      CN_DIM_HIERARCHIES.HEADER_DIM_HIERARCHY_ID%TYPE,
   p_start_date                 IN      CN_DIM_HIERARCHIES.START_DATE%TYPE,
   p_end_date                   IN      CN_DIM_HIERARCHIES.END_DATE%TYPE,
   p_root_node                  IN      CN_DIM_HIERARCHIES.ROOT_NODE%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		CN_DIM_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_dim_hierarchy_id           OUT NOCOPY     CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE);

-- Update dimension hierarchy (only dates are updateable)
PROCEDURE Update_Dim_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   p_start_date                 IN      CN_DIM_HIERARCHIES.START_DATE%TYPE,
   p_end_date                   IN      CN_DIM_HIERARCHIES.END_DATE%TYPE,
   p_object_version_number      IN  OUT NOCOPY    CN_DIM_HIERARCHIES.OBJECT_VERSION_NUMBER%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		CN_DIM_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Delete dimension hierarchy
PROCEDURE Delete_Dim_Hierarchy
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_DIM_HIERARCHIES.DIM_HIERARCHY_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		CN_DIM_HIERARCHIES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);

-- Create edge
PROCEDURE Create_Edge
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_HIERARCHY_EDGES.DIM_HIERARCHY_ID%TYPE,
   p_parent_value_id            IN      CN_HIERARCHY_EDGES.PARENT_VALUE_ID%TYPE,
   p_name                       IN      CN_HIERARCHY_NODES.NAME%TYPE,
   p_external_id                IN      CN_HIERARCHY_NODES.EXTERNAL_ID%TYPE,
   --R12 MOAC Changes--Start
   p_org_id			IN		CN_HIERARCHY_EDGES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2,
   x_value_id                   OUT NOCOPY     CN_HIERARCHY_EDGES.VALUE_ID%TYPE);

-- Delete edge
PROCEDURE Delete_Edge
  (p_api_version                IN      NUMBER,     -- required
   p_init_msg_list              IN      VARCHAR2 := FND_API.G_FALSE,
   p_commit                     IN      VARCHAR2 := FND_API.G_FALSE,
   p_validation_level           IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_dim_hierarchy_id           IN      CN_HIERARCHY_EDGES.DIM_HIERARCHY_ID%TYPE,
   p_value_id                   IN      CN_HIERARCHY_EDGES.VALUE_ID%TYPE,
   p_parent_value_id            IN      CN_HIERARCHY_EDGES.PARENT_VALUE_ID%TYPE,
    --R12 MOAC Changes--Start
   p_org_id			IN		CN_HIERARCHY_EDGES.ORG_ID%TYPE,
   --R12 MOAC Changes--End
   x_return_status              OUT NOCOPY     VARCHAR2,
   x_msg_count                  OUT NOCOPY     NUMBER,
   x_msg_data                   OUT NOCOPY     VARCHAR2);


-- export
PROCEDURE Export
  (errbuf                    OUT NOCOPY   VARCHAR2,
   retcode                   OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
    --R12 MOAC Changes--Start
   p_org_id			IN		NUMBER);
   --R12 MOAC Changes--End


END CN_DIM_HIERARCHIES_PVT;

 

/
