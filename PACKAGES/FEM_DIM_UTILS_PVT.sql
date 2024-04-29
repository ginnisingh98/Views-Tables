--------------------------------------------------------
--  DDL for Package FEM_DIM_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FEM_DIM_UTILS_PVT" AUTHID CURRENT_USER AS
/* $Header: FEMVDDUS.pls 120.6.12010000.2 2008/08/19 08:26:20 lkiran ship $ */

   -- Global Variable to set security context
   g_user_mode           varchar2(1) := 'N';
   g_dimension_id        NUMBER;

FUNCTION Get_Dim_Attr_Req_Flag_Access
(
  p_dimension_id              IN           NUMBER
) RETURN VARCHAR2;

FUNCTION Get_Dim_Attribute_Access
(
  p_attribute_id              IN           NUMBER,
  p_personal_flag             IN           VARCHAR2 := 'N'
) RETURN VARCHAR2;

/* Bug#3980015
 * Added to handle behavious of Delete switcher
 * to seperate its behaviour from the update
 * switcher's logic
 */
FUNCTION Get_Dim_Attribute_Access_Del
(
  p_attribute_id              IN           NUMBER,
  p_personal_flag             IN           VARCHAR2 := 'N'
) RETURN VARCHAR2;

/* Bug#3738974
 * Parameter 'p_operation_type' added
 * to distinguish between 'Update' and 'delete' operations
 */

FUNCTION Get_Dim_Group_Access
(
  p_group_id              IN           NUMBER,
  p_read_only_flag        IN           VARCHAR2,
  p_personal_flag         IN           VARCHAR2,
  p_created_by            IN           NUMBER,
  p_dimension_id          IN           VARCHAR2,
  p_operation_type        IN           VARCHAR2
) RETURN  VARCHAR2;

FUNCTION Get_Dim_Member_Access
(
  p_member_id             IN           VARCHAR2,
  p_read_only_flag        IN           VARCHAR2,
  p_personal_flag         IN           VARCHAR2,
  p_created_by            IN           NUMBER,
  p_operation             IN           VARCHAR2
) RETURN  VARCHAR2;


PROCEDURE Set_Security_Context;

PROCEDURE Set_Security_Dim_Context (
  p_dimension_id               IN       NUMBER
);


PROCEDURE Set_Non_Security_Context;


FUNCTION Grp_Attribute_Validation
(
  p_attribute_id          IN           NUMBER,
  p_dim_group_id          IN           VARCHAR2
) RETURN  VARCHAR2;


PROCEDURE Set_Non_Security_Dim_Context (
  p_dimension_id               IN       NUMBER
);


PROCEDURE Create_Comp_Dim_Member (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_structure_id              IN       NUMBER ,
  p_display_code              IN       VARCHAR2 ,
  p_dim_varchar_label         IN       VARCHAR2 ,
  p_segment_1                 IN       VARCHAR2 ,
  p_segment_2                 IN       VARCHAR2 ,
  p_segment_3                 IN       VARCHAR2 ,
  p_segment_4                 IN       VARCHAR2 ,
  p_segment_5                 IN       VARCHAR2 ,
  p_segment_6                 IN       VARCHAR2 ,
  p_segment_7                 IN       VARCHAR2 ,
  p_segment_8                 IN       VARCHAR2 ,
  p_segment_9                 IN       VARCHAR2 ,
  p_segment_10                 IN       VARCHAR2 ,
  p_segment_11                 IN       VARCHAR2 ,
  p_segment_12                 IN       VARCHAR2 ,
  p_segment_13                 IN       VARCHAR2 ,
  p_segment_14                 IN       VARCHAR2 ,
  p_segment_15                 IN       VARCHAR2 ,
  p_segment_16                 IN       VARCHAR2 ,
  p_segment_17                 IN       VARCHAR2 ,
  p_segment_18                 IN       VARCHAR2 ,
  p_segment_19                 IN       VARCHAR2 ,
  p_segment_20                 IN       VARCHAR2 ,
  p_segment_21                 IN       VARCHAR2 ,
  p_segment_22                 IN       VARCHAR2 ,
  p_segment_23                 IN       VARCHAR2 ,
  p_segment_24                 IN       VARCHAR2 ,
  p_segment_25                 IN       VARCHAR2 ,
  p_segment_26                 IN       VARCHAR2 ,
  p_segment_27                 IN       VARCHAR2 ,
  p_segment_28                 IN       VARCHAR2 ,
  p_segment_29                 IN       VARCHAR2 ,
  p_segment_30                 IN       VARCHAR2,
  p_local_vs_combo_id          IN       VARCHAR2);


PROCEDURE Member_Insert_Row (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_rowid                       in out NOCOPY VARCHAR2,
  p_dimension_varchar_label  IN    VARCHAR2 ,
  p_dimension_id             IN    NUMBER ,
  p_value_set_id             IN    NUMBER ,
  p_dimension_group_id       IN    NUMBER ,
  p_display_code             IN    VARCHAR2 ,
  p_member_name              IN    VARCHAR2 ,
  p_member_description       IN    VARCHAR2,
  p_object_version_number    IN    NUMBER,
  p_read_only_flag           IN    VARCHAR2,
  p_enabled_flag             IN    VARCHAR2,
  p_personal_flag            IN    VARCHAR2,
  p_calendar_id              IN    NUMBER,
  p_member_id                IN    VARCHAR2
);


PROCEDURE Member_Update_Row (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_dimension_varchar_label  IN    VARCHAR2 ,
  p_member_id                IN    NUMBER ,
  p_value_set_id             IN    NUMBER ,
  p_dimension_group_id       IN    NUMBER ,
  p_display_code             IN    VARCHAR2 ,
  p_member_name              IN    VARCHAR2 ,
  p_member_description       IN    VARCHAR2,
  p_object_version_number    IN    NUMBER,
  p_read_only_flag           IN    VARCHAR2,
  p_enabled_flag             IN    VARCHAR2,
  p_personal_flag            IN    VARCHAR2,
  p_calendar_id              IN    NUMBER
);

--Bug#4406010
--Added param p_value_set_id.

PROCEDURE Member_Delete_Row (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_dimension_varchar_label   IN VARCHAR2,
  p_member_id                 IN VARCHAR2,
  p_value_set_id              IN VARCHAR2
);

--Bug#4230148
--Added p_user_mode,p_snapshot_id

FUNCTION Do_Member_Adv_Search (
  p_member_attr_table_name    IN VARCHAR2,
  p_member_column_name        IN VARCHAR2,
  p_search_attribute_id       IN VARCHAR2,
  p_search_version_id         IN VARCHAR2,
  p_search_attribute_value    IN VARCHAR2,
  p_user_mode                 IN VARCHAR2,
  p_snapshot_id               IN VARCHAR2
)
RETURN FND_TABLE_OF_VARCHAR2_120;


PROCEDURE Attribute_Insert_Row (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --

  p_attribute_table_name     IN    VARCHAR2 ,
  p_attribute_column_name    IN    VARCHAR2 ,
  p_attribute_id             IN    NUMBER ,
  p_version_id               IN    NUMBER ,
  p_member_id                IN    VARCHAR2 ,
  p_member_value_set_id      IN    NUMBER ,
  p_attribute_value_set_id   IN    NUMBER ,
  p_attribute_numeric_member IN    NUMBER,
  p_attribute_varchar_member IN    VARCHAR2,
  p_number_assign_value      IN    NUMBER,
  p_varchar_assign_value     IN    VARCHAR2,
  p_date_assign_value        IN    DATE,
  p_value_set_required_flag  IN    VARCHAR2

);


PROCEDURE Attribute_Update_Row (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_attribute_table_name     IN    VARCHAR2 ,
  p_attribute_column_name    IN    VARCHAR2 ,
  p_attribute_id             IN    NUMBER ,
  p_version_id               IN    NUMBER ,
  p_member_id                IN    VARCHAR2 ,
  p_member_value_set_id      IN    NUMBER ,
  p_attribute_value_set_id   IN    NUMBER ,
  p_attribute_numeric_member IN    NUMBER,
  p_attribute_varchar_member IN    VARCHAR2,
  p_number_assign_value      IN    NUMBER,
  p_varchar_assign_value     IN    VARCHAR2,
  p_date_assign_value        IN    DATE,
  p_value_set_required_flag  IN    VARCHAR2,
  p_object_version_number    IN    NUMBER
);

PROCEDURE Attribute_Delete_Row (
  p_api_version               IN       NUMBER ,
  p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE ,
  p_commit                    IN       VARCHAR2 := FND_API.G_FALSE ,
  p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL ,
  p_return_status             OUT  NOCOPY      VARCHAR2 ,
  p_msg_count                 OUT  NOCOPY      NUMBER   ,
  p_msg_data                  OUT  NOCOPY      VARCHAR2 ,
  --
  p_attribute_table_name     IN    VARCHAR2 ,
  p_member_col_name          IN    VARCHAR2 ,
  p_attribute_id             IN    NUMBER ,
  p_version_id               IN    NUMBER ,
  p_member_id                IN    VARCHAR2 ,
  p_member_value_set_id      IN    NUMBER ,
  p_dim_attr_numeric_member  IN    NUMBER ,
  p_dim_attr_varchar_member  IN    VARCHAR2,
  p_dim_attr_value_set_id    IN    NUMBER
);

-- Bug#3738974: Function to determine if a given group has members
FUNCTION Group_Has_Members (
  p_dim_mem_tbl_name        IN		VARCHAR2,
  p_group_id	            IN		NUMBER
) RETURN VARCHAR2;

--Bug#4370513
--Added param p_global_vs_combo_id

--Bug#4449895
--Added param p_member_group_id

PROCEDURE Check_Unique_Member
(
  p_api_version              IN          NUMBER,
  p_init_msg_list            IN          VARCHAR2 := FND_API.G_FALSE,
  p_commit                   IN          VARCHAR2 := FND_API.G_FALSE,
  p_validation_level         IN          NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  p_return_status            OUT NOCOPY  VARCHAR2,
  p_msg_count                OUT NOCOPY  NUMBER,
  p_msg_data                 OUT NOCOPY  VARCHAR2,
  --
  p_comp_dim_flag            IN          VARCHAR2,
  p_member_name              IN          VARCHAR2,
  p_member_display_code      IN          VARCHAR2,
  p_dimension_varchar_label  IN          VARCHAR2,
  p_member_group_id          IN          NUMBER,
  p_value_set_id             IN          NUMBER,
  p_calendar_id              IN          NUMBER := NULL,
  p_global_vs_combo_id       IN          NUMBER,
  p_member_id                IN          VARCHAR2);

--Bug#3998511: Added Validate_Cal_Period_Member Procedure
--Bug#4002913: Added the parameter p_calendar_id
--Bug#4096945: Added the parameters p_current_period_flag,p_cal_period_id
PROCEDURE Validate_Cal_Period_Member (
  p_api_version              IN          NUMBER,
  p_init_msg_list            IN          VARCHAR2 := FND_API.G_FALSE,
  x_return_status            OUT NOCOPY  VARCHAR2,
  x_msg_count                OUT NOCOPY  NUMBER,
  x_msg_data                 OUT NOCOPY  VARCHAR2,
  --
  p_dimension_id             IN          NUMBER,
  p_dimension_group_id       IN          NUMBER,
  p_start_date               IN          DATE,
  p_end_date                 IN          DATE,
  p_adjustment_period_flag   IN          VARCHAR2,
  p_calendar_id              IN          NUMBER,
  p_current_period_flag      IN          VARCHAR2,
  p_cal_period_id            IN          VARCHAR2
);

  FUNCTION Get_Ogl_Locked_Member_Access
   (
     p_attribute_id            IN           NUMBER,
     p_read_only_flag          IN           VARCHAR2
   ) RETURN  VARCHAR2;


END FEM_DIM_UTILS_PVT;

/
