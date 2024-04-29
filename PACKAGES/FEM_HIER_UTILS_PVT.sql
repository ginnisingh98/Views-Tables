--------------------------------------------------------
--  DDL for Package FEM_HIER_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_HIER_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVDHUS.pls 120.4 2007/07/18 11:58:33 gdonthir ship $ */


 /*TYPE g_children_rec_type is RECORD
 (
   childids          number,
   childdepthnums    number,
   childvaluesetids  number,
   displayordernum   number,
   weightingpct      number
 );

 TYPE g_children_tbl_type IS TABLE OF g_children_rec_type
    INDEX BY BINARY_INTEGER;

 TYPE g_base_rec_type is RECORD
 (
   childids         number,
   childvaluesetids number
 );

 TYPE g_base_tbl_type IS TABLE OF g_base_rec_type
    INDEX BY BINARY_INTEGER; */




PROCEDURE Flatten_Focus_Node
(
  p_api_version           IN           NUMBER ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status         OUT  NOCOPY  VARCHAR2 ,
  x_msg_count             OUT  NOCOPY  NUMBER   ,
  x_msg_data              OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id      IN           NUMBER,
  p_hier_table_name       IN           VARCHAR2,
  p_focus_node            IN           NUMBER   ,
  p_focus_value_set_id    IN           NUMBER
);

PROCEDURE Unflatten_Focus_Node_Tree
(
  p_api_version                 IN           NUMBER ,
  p_init_msg_list               IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                      IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level            IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status               OUT  NOCOPY  VARCHAR2 ,
  x_msg_count                   OUT  NOCOPY  NUMBER   ,
  x_msg_data                    OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id            IN           NUMBER,
  p_hier_table_name             IN           VARCHAR2,
  p_focus_node                  IN           NUMBER   ,
  p_focus_value_set_id          IN           NUMBER,
  p_parent_id                   IN           NUMBER,
  p_parent_value_set_id         IN           NUMBER,
  p_imm_child_id                IN           NUMBER,
  p_imm_child_value_set_id      IN           NUMBER,
  p_operation                   IN           VARCHAR2
);

PROCEDURE Flatten_Focus_Node_Tree
(
  p_api_version           IN           NUMBER ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status         OUT  NOCOPY  VARCHAR2 ,
  x_msg_count             OUT  NOCOPY  NUMBER   ,
  x_msg_data              OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id      IN           NUMBER,
  p_hier_table_name       IN           VARCHAR2,
  p_focus_node            IN           NUMBER ,
  p_focus_value_set_id    IN           NUMBER
);

PROCEDURE Flatten_Whole_Hier_Version
(
  p_api_version           IN           NUMBER ,
  p_init_msg_list         IN           VARCHAR2 := FND_API.G_FALSE ,
  p_commit                IN           VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level      IN           NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  x_return_status         OUT  NOCOPY  VARCHAR2 ,
  x_msg_count             OUT  NOCOPY  NUMBER   ,
  x_msg_data              OUT  NOCOPY  VARCHAR2 ,
  --
  p_hier_obj_defn_id      IN           NUMBER
);

PROCEDURE Flatten_Whole_Hier_Version_CP
(
  errbuf                  OUT  NOCOPY  VARCHAR2  ,
  retcode                 OUT  NOCOPY  VARCHAR2  ,
  --
  p_hierarchy_id          IN           NUMBER    ,
  p_hier_obj_defn_id      IN           NUMBER
);


PROCEDURE Flatten_Focus_Node_CP
(
  errbuf                        OUT  NOCOPY  VARCHAR2  ,
  retcode                       OUT  NOCOPY  VARCHAR2  ,
  --
  p_hier_obj_defn_id            IN           NUMBER    ,
  p_hier_table_name             IN           VARCHAR2  ,
  p_focus_node                  IN           NUMBER    ,
  p_focus_value_set_id          IN           NUMBER    ,
  p_parent_id                   IN           NUMBER    ,
  p_parent_value_set_id         IN           NUMBER    ,
  p_imm_child_id                IN           NUMBER    ,
  p_imm_child_value_set_id      IN           NUMBER    ,
  p_operation                   IN           VARCHAR2
);

PROCEDURE insert_root_node (
			p_api_version         	IN    		NUMBER ,
  			p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  			p_return_status       	OUT NOCOPY   	VARCHAR2 ,
  			p_msg_count           	OUT NOCOPY   	NUMBER  ,
  			p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
  			p_rowid	                IN OUT NOCOPY	VARCHAR2,
                        p_vs_required_flag      IN          	VARCHAR2,
 			p_hier_table_name 	IN 		VARCHAR2,
			p_hier_obj_def_id 	IN 		NUMBER,
			p_parent_depth_num 	IN 		NUMBER,
			p_parent_id 		IN 		NUMBER,
			p_parent_value_set_id 	IN 		NUMBER,
			p_child_depth_num 	IN 		NUMBER,
			p_child_id 		IN 		NUMBER,
			p_child_value_set_id 	IN 		NUMBER,
			p_single_depth_flag 	IN 		VARCHAR2,
			p_display_order_num 	IN 		NUMBER,
			p_weighting_pct 	IN 		NUMBER );

PROCEDURE launch_dup_hier_process(ERRBUFF	IN OUT NOCOPY	VARCHAR2,
				  RETCODE	IN OUT NOCOPY VARCHAR2,
				  p_hier_table_name       IN VARCHAR2,
			          p_src_hier_obj_id 	  IN NUMBER,
				  p_dest_hier_name IN VARCHAR2,
				  p_dest_hier_desc in VARCHAR2,
				  p_dest_hier_folder_id IN NUMBER,
				  p_src_hier_version_id IN NUMBER,
				  p_dest_version_name IN VARCHAR2,
				  p_dest_version_desc IN VARCHAR2,
				  p_dest_start_date IN VARCHAR2,
				  p_dest_end_date IN VARCHAR2);

PROCEDURE duplicate_hierarchy (
			p_api_version         	IN    		NUMBER ,
  			p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  			p_return_status       	OUT NOCOPY   	VARCHAR2 ,
  			p_msg_count           	OUT NOCOPY   	NUMBER  ,
  			p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
 			p_hier_table_name 	IN 		VARCHAR2,
			p_src_hier_obj_id 	IN 		NUMBER,
                        p_dest_hier_name        IN 		VARCHAR2,
                        p_dest_hier_desc        IN 		VARCHAR2,
                        p_dest_hier_folder_id   IN 		NUMBER,
			p_src_hier_version_id 	IN 		NUMBER,
                        p_dest_version_name     IN 		VARCHAR2,
                        p_dest_version_desc     IN 		VARCHAR2,
                        p_dest_start_date       IN      DATE,
                        p_dest_end_date         IN      DATE);


PROCEDURE launch_dup_hier_ver_process(ERRBUFF	IN OUT NOCOPY	VARCHAR2,
				  RETCODE	IN OUT NOCOPY   VARCHAR2,
				  p_hier_table_name       IN VARCHAR2,
			          p_src_hier_obj_id 	  IN NUMBER,
				  p_src_hier_version_id IN NUMBER,
				  p_dest_version_name IN VARCHAR2,
				  p_dest_version_desc IN VARCHAR2,
				  p_dest_start_date IN VARCHAR2,
				  p_dest_end_date IN VARCHAR2);


PROCEDURE duplicate_hier_version(
			p_api_version         	IN    		NUMBER ,
  			p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  			p_return_status       	OUT NOCOPY   	VARCHAR2 ,
  			p_msg_count           	OUT NOCOPY   	NUMBER  ,
  			p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
                        p_hier_table_name       IN      	VARCHAR2,
			p_src_hier_obj_id 	IN 		NUMBER,
  			p_src_hier_version_id 	IN 		NUMBER,
			p_dest_hier_obj_id 	IN 		NUMBER,
                        p_dest_version_name     IN 		VARCHAR2,
                        p_dest_version_desc     IN 		VARCHAR2,
                        p_dest_start_date       IN      	DATE,
                        p_dest_end_date         IN      	DATE);

PROCEDURE launch_del_hier_process(ERRBUFF	IN OUT NOCOPY	VARCHAR2,
				  RETCODE	IN OUT NOCOPY   VARCHAR2,
				  p_hier_table_name       IN VARCHAR2,
			          p_hier_obj_id 	  IN NUMBER);

PROCEDURE delete_hierarchy(
			p_api_version         	IN    		NUMBER ,
  			p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  			p_return_status       	OUT NOCOPY   	VARCHAR2 ,
  			p_msg_count           	OUT NOCOPY   	NUMBER  ,
  			p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
                        p_hier_table_name       IN      	VARCHAR2,
			p_hier_obj_id 	        IN 		NUMBER );

PROCEDURE launch_del_hier_ver_process(ERRBUFF       IN OUT NOCOPY VARCHAR2,
				      RETCODE       IN OUT NOCOPY VARCHAR2,
				      p_hier_table_name   IN VARCHAR2,
			              p_hier_obj_id 	  IN NUMBER,
			              p_hier_version_id   IN NUMBER);

PROCEDURE delete_hier_version(
			p_api_version         	IN    		NUMBER ,
  			p_init_msg_list       	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_commit              	IN    		VARCHAR2 := FND_API.G_FALSE ,
  			p_validation_level    	IN    		NUMBER  := FND_API.G_VALID_LEVEL_FULL ,
  			p_return_status       	OUT NOCOPY   	VARCHAR2 ,
  			p_msg_count           	OUT NOCOPY   	NUMBER  ,
  			p_msg_data            	OUT NOCOPY   	VARCHAR2 ,
                        p_hier_table_name       IN      	VARCHAR2,
			p_hier_obj_id 	        IN 		NUMBER,
                        p_hier_version_id       IN              NUMBER);

PROCEDURE Remove_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_member_id                  IN       NUMBER,
  p_value_set_id               IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2,
  p_flatten_rows_flag          IN       VARCHAR2,
  p_user_id                    IN       NUMBER
);

PROCEDURE Move_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_source_member_id           IN       NUMBER,
  p_source_value_set_id        IN       NUMBER,
  p_dest_member_id             IN       NUMBER,
  p_dest_value_set_id          IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2,
  p_flatten_rows_flag          IN       VARCHAR2,
  p_user_id                    IN       NUMBER
);

PROCEDURE Add_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_parent_member_id           IN       NUMBER,
  p_parent_value_set_id        IN       NUMBER,
  p_child_members              IN       FEM_DHM_MEMBER_TAB_TYP,
  p_user_id                    IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2,
  p_flatten_rows_flag          IN       VARCHAR2
);

PROCEDURE Add_Root_Nodes
(
  p_api_version                IN       NUMBER,
  p_init_msg_list              IN       VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN       VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_version_id                 IN       NUMBER,
  p_child_members              IN       FEM_DHM_MEMBER_TAB_TYP,
  p_user_id                    IN       NUMBER,
  p_hier_table_name            IN       VARCHAR2,
  p_value_set_required_flag    IN       VARCHAR2
);

procedure  Hier_Member_Sequence_Update (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_new_display_order_num     IN    NUMBER ,
  p_hierarchy_table_name      IN    VARCHAR2 ,
  p_hierarchy_obj_def_id      IN    NUMBER ,
  p_parent_id                 IN    NUMBER ,
  p_parent_value_set_id       IN    NUMBER ,
  p_child_id                  IN    NUMBER ,
  p_child_value_set_id        IN    NUMBER
);

FUNCTION Is_Lowest_Group
(
  p_hierarchy_obj_id           IN        NUMBER,
  p_dimension_group_id         IN        NUMBER
)
RETURN VARCHAR2;

FUNCTION Is_Highest_Group
(
  p_hierarchy_obj_id           IN        NUMBER,
  p_dimension_group_id         IN        NUMBER
)
RETURN VARCHAR2;

FUNCTION Is_Reorder_Allowed
(
  p_dimension_id               IN        NUMBER,
  p_hierarchy_obj_id           IN        NUMBER,
  p_hierarchy_obj_def_id       IN        NUMBER,
  p_member_id                  IN        NUMBER := 0,
  p_value_set_id               IN        NUMBER,
  p_user_mode                  IN        VARCHAR2,
  p_comp_dim_flag              IN        VARCHAR2 := 'N'
)
RETURN VARCHAR2;

PROCEDURE Add_Relation(
  p_api_version                IN               NUMBER,
  p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN               VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN               NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN               NUMBER,
  p_version_id                 IN               NUMBER,
  p_parent_id                  IN               NUMBER,
  p_parent_qty                 IN               NUMBER,
  p_child_id                   IN               NUMBER,
  p_child_qty                  IN               NUMBER,
  p_yield_pct                  IN               NUMBER,
  p_bom_reference              IN               VARCHAR2,
  p_display_order_num          IN               NUMBER,
  p_hier_table_name            IN               VARCHAR2
);

PROCEDURE Add_Relations(
  p_api_version                IN               NUMBER,
  p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN               VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN               NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN               NUMBER,
  p_version_id                 IN               NUMBER,
  p_hier_table_name            IN               VARCHAR2,
  p_relation_details_tbl       IN               FEM_DHM_HIER_NODE_TAB_TYP
);

PROCEDURE Update_Relation(
  p_api_version                IN               NUMBER,
  p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN               VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN               NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN               NUMBER,
  p_version_id                 IN               NUMBER,
  p_parent_id                  IN               NUMBER,
  p_parent_qty                 IN               NUMBER,
  p_child_id                   IN               NUMBER,
  p_child_qty                  IN               NUMBER,
  p_child_sequence_num         IN               NUMBER,
  p_yield_pct                  IN               NUMBER,
  p_bom_reference              IN               VARCHAR2,
  p_display_order_num          IN               NUMBER,
  p_hier_table_name            IN               VARCHAR2
);

PROCEDURE Update_Relations(
  p_api_version                IN               NUMBER,
  p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN               VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN               NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN               NUMBER,
  p_version_id                 IN               NUMBER,
  p_hier_table_name            IN               VARCHAR2,
  p_relation_details_tbl       IN               FEM_DHM_HIER_NODE_TAB_TYP
);

PROCEDURE Remove_Relation(
  p_api_version                IN               NUMBER,
  p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN               VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN               NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN               NUMBER,
  p_version_id                 IN               NUMBER,
  p_parent_id                  IN               NUMBER,
  p_child_id                   IN               NUMBER,
  p_child_sequence_num         IN               NUMBER,
  p_hier_table_name            IN               VARCHAR2,
  p_remove_all_children_flag   IN               VARCHAR);


PROCEDURE Move_Relation(
  p_api_version                IN               NUMBER,
  p_init_msg_list              IN               VARCHAR2 := FND_API.G_FALSE,
  p_commit                     IN               VARCHAR2 := FND_API.G_FALSE,
  p_validation_level           IN               NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT  NOCOPY      VARCHAR2,
  x_msg_count                  OUT  NOCOPY      NUMBER,
  x_msg_data                   OUT  NOCOPY      VARCHAR2,
  --
  p_hierarchy_id               IN               NUMBER,
  p_version_id                 IN               NUMBER,
  p_hier_table_name            IN               VARCHAR2,
  p_child_id                   IN               NUMBER,
  p_src_parent_id              IN               NUMBER,
  p_dest_parent_id             IN               NUMBER,
  p_child_sequence_num         IN               NUMBER
);

PROCEDURE Flatten_Whole_Hierarchy_CP
(
  errbuf                  OUT  NOCOPY  VARCHAR2  ,
  retcode                 OUT  NOCOPY  VARCHAR2  ,
  p_hierarchy_id          IN           NUMBER
);

FUNCTION  Get_Version_Access_Code
(
  p_version_id IN NUMBER,
  p_object_access_code IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION can_delete_hierarchy
(
  p_hierarchy_id           IN        NUMBER,
  p_folder_id              IN        NUMBER
)
RETURN VARCHAR2;

FUNCTION can_delete_hier_version
(
  p_hier_version_id        IN        NUMBER,
  p_folder_id              IN        NUMBER
)
RETURN VARCHAR2;

FUNCTION can_view_ver_detail
(
  p_hier_version_id        IN        NUMBER
)
RETURN VARCHAR2;

FUNCTION can_duplicate_hier_version
(
  p_hier_version_id        IN        NUMBER
)

RETURN VARCHAR2;

FUNCTION Can_Update_Hierarchy
(
p_object_access_code    IN VARCHAR2,
p_hier_created_by       IN VARCHAR2
)
RETURN VARCHAR2;

FUNCTION is_hier_deleted
(
 p_hierarchy_id            IN        NUMBER
)
RETURN VARCHAR2;

FUNCTION is_hier_ver_deleted
(
 p_hier_ver_id             IN        NUMBER
)
RETURN VARCHAR2;

FUNCTION is_hier_vs_deleteable
(
  p_hierarchy_id IN NUMBER,
  p_value_set_id IN NUMBER,
  p_hier_table IN VARCHAR2
)
RETURN VARCHAR2;

end FEM_HIER_UTILS_PVT;

/
