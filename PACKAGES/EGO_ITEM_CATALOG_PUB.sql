--------------------------------------------------------
--  DDL for Package EGO_ITEM_CATALOG_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EGO_ITEM_CATALOG_PUB" AUTHID CURRENT_USER AS
/* $Header: EGOBCAGS.pls 120.1 2005/06/29 00:01:18 lkapoor noship $ */

-- Validation level

g_VALIDATE_NONE     CONSTANT  NUMBER  :=  0;
g_VALIDATE_RULES    CONSTANT  NUMBER  :=  10;
g_VALIDATE_IDS      CONSTANT  NUMBER  :=  20;
g_VALIDATE_VALUES   CONSTANT  NUMBER  :=  30;
g_VALIDATE_ALL      CONSTANT  NUMBER  :=  100;
g_VALIDATE_LEVEL_FULL  CONSTANT  NUMBER  :=  100;

/* Catalog Group Exposed column record definition */

TYPE Catalog_Group_Rec_Type IS RECORD
(
  Catalog_Group_Name		VARCHAR2(2000)
, Parent_Catalog_Group_Name	VARCHAR2(2000)
, Catalog_Group_Id	  	NUMBER
, Parent_Catalog_Group_Id 	NUMBER
, Description			VARCHAR2(240)
, Item_Creation_Allowed_Flag 	VARCHAR2(1)
, Start_Effective_Date		DATE
, Inactive_Date			DATE
, Enabled_Flag			VARCHAR2(1)
, Summary_Flag			VARCHAR2(1)
, segment1                      VARCHAR2(40)
, segment2                      VARCHAR2(40)
, segment3                      VARCHAR2(40)
, segment4                      VARCHAR2(40)
, segment5                      VARCHAR2(40)
, segment6                      VARCHAR2(40)
, segment7                      VARCHAR2(40)
, segment8                      VARCHAR2(40)
, segment9                      VARCHAR2(40)
, segment10                     VARCHAR2(40)
, segment11                     VARCHAR2(40)
, segment12                     VARCHAR2(40)
, segment13                     VARCHAR2(40)
, segment14                     VARCHAR2(40)
, segment15                     VARCHAR2(40)
, segment16                     VARCHAR2(40)
, segment17                     VARCHAR2(40)
, segment18                     VARCHAR2(40)
, segment19                     VARCHAR2(40)
, segment20                     VARCHAR2(40)
, Attribute_category    	VARCHAR2(30)
, Attribute1            	VARCHAR2(150)
, Attribute2            	VARCHAR2(150)
, Attribute3            	VARCHAR2(150)
, Attribute4            	VARCHAR2(150)
, Attribute5            	VARCHAR2(150)
, Attribute6            	VARCHAR2(150)
, Attribute7            	VARCHAR2(150)
, Attribute8            	VARCHAR2(150)
, Attribute9            	VARCHAR2(150)
, Attribute10           	VARCHAR2(150)
, Attribute11           	VARCHAR2(150)
, Attribute12           	VARCHAR2(150)
, Attribute13           	VARCHAR2(150)
, Attribute14           	VARCHAR2(150)
, Attribute15           	VARCHAR2(150)
, Transaction_Type      	VARCHAR2(30)
, Return_Status         	VARCHAR2(1)
);

/* Catalog Group Unexposed Record Type */

TYPE Catalog_Group_UnExp_Rec_Type IS RECORD
(
  Catalog_Group_Id	  NUMBER
 ,Parent_Catalog_Group_Id NUMBER
);

TYPE Catalog_Group_Tbl_Type IS TABLE OF Catalog_Group_Rec_Type
	INDEX BY BINARY_INTEGER;


/* Missing record and Table Definition */
G_MISS_CATALOG_GROUP_REC	EGO_Item_Catalog_Pub.Catalog_Group_Rec_Type;
G_MISS_CATALOG_GROUP_TBL	EGO_Item_Catalog_Pub.Catalog_Group_Tbl_Type;


/* Flexfield segment store */
G_KF_SEGMENT_VALUES FND_FLEX_EXT.SegmentArray;


/* Public API for processing catalog groups
** Applications can call catalog group api to a create the catalog group hierarchy.
** Parameters:
** init_msg_list: will be used to initialize the message stack. If the calling
** application intends to accumulate the messages between calls to the api,this parameter can
** can be passed as False.
** Catalog_Group_Tbl: This is the table calling application constructs to create the
** catalog group heirarchy
** return_status: this is returned by the api to indicate the success/failure of the call
** msg_count: this is returned by the api to indicate the number of message logged for this
** call.
**
*/

Procedure Process_Catalog_Groups
(  p_bo_identifier           IN  VARCHAR2 := 'ICG'
 , p_api_version_number      IN  NUMBER := 1.0
 , p_init_msg_list           IN  BOOLEAN := FALSE
 , p_catalog_group_tbl	     IN  Ego_Item_Catalog_Pub.Catalog_Group_Tbl_Type
 , p_user_id		     IN  NUMBER
 , p_language_code	     IN  VARCHAR2 := 'US'
 , x_catalog_group_tbl       OUT NOCOPY Ego_Item_Catalog_Pub.Catalog_Group_Tbl_Type
 , x_return_status           OUT NOCOPY VARCHAR2
 , x_msg_count               OUT NOCOPY NUMBER
 , p_debug                   IN  VARCHAR2 := 'N'
 , p_output_dir              IN  VARCHAR2 := NULL
 , p_debug_filename          IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
 );


/* Process_Catalog_Group
** Convenience method that can be called once for every catalog group in the catalog group
** hierarchy
*/

Procedure Process_Catalog_Group
(  p_Catalog_Group_Name            IN  VARCHAR2		:= NULL
 , p_Parent_Catalog_Group_Name     IN  VARCHAR2		:= NULL
 , p_Catalog_Group_Id              IN  NUMBER 		:= NULL
 , p_Parent_Catalog_Group_Id       IN  NUMBER        	:= NULL
 , p_Description                   IN  VARCHAR2		:= NULL
 , p_Item_Creation_Allowed_Flag    IN  VARCHAR2		:= NULL
 , p_Start_Effective_Date 	   IN  DATE		:= NULL
 , p_Inactive_date		   IN  DATE		:= NULL
 , p_Enabled_Flag                  IN  VARCHAR2		:= NULL
 , p_Summary_Flag                  IN  VARCHAR2		:= NULL
 , p_segment1			   IN  VARCHAR2		:= NULL
 , p_segment2			   IN  VARCHAR2		:= NULL
 , p_segment3			   IN  VARCHAR2		:= NULL
 , p_segment4			   IN  VARCHAR2		:= NULL
 , p_segment5			   IN  VARCHAR2		:= NULL
 , p_segment6			   IN  VARCHAR2		:= NULL
 , p_segment7			   IN  VARCHAR2		:= NULL
 , p_segment8			   IN  VARCHAR2		:= NULL
 , p_segment9			   IN  VARCHAR2		:= NULL
 , p_segment10			   IN  VARCHAR2		:= NULL
 , p_segment11			   IN  VARCHAR2		:= NULL
 , p_segment12			   IN  VARCHAR2		:= NULL
 , p_segment13			   IN  VARCHAR2		:= NULL
 , p_segment14			   IN  VARCHAR2		:= NULL
 , p_segment15			   IN  VARCHAR2		:= NULL
 , p_segment16			   IN  VARCHAR2		:= NULL
 , p_segment17			   IN  VARCHAR2		:= NULL
 , p_segment18			   IN  VARCHAR2		:= NULL
 , p_segment19			   IN  VARCHAR2		:= NULL
 , p_segment20		   	   IN  VARCHAR2		:= NULL
 , Attribute_category        	   IN  VARCHAR2 	:= NULL
 , Attribute1                	   IN  VARCHAR2 	:= NULL
 , Attribute2                	   IN  VARCHAR2 	:= NULL
 , Attribute3                	   IN  VARCHAR2 	:= NULL
 , Attribute4                	   IN  VARCHAR2 	:= NULL
 , Attribute5                	   IN  VARCHAR2 	:= NULL
 , Attribute6                	   IN  VARCHAR2 	:= NULL
 , Attribute7                	   IN  VARCHAR2 	:= NULL
 , Attribute8                	   IN  VARCHAR2 	:= NULL
 , Attribute9                	   IN  VARCHAR2 	:= NULL
 , Attribute10               	   IN  VARCHAR2 	:= NULL
 , Attribute11               	   IN  VARCHAR2 	:= NULL
 , Attribute12               	   IN  VARCHAR2 	:= NULL
 , Attribute13               	   IN  VARCHAR2 	:= NULL
 , Attribute14               	   IN  VARCHAR2 	:= NULL
 , Attribute15               	   IN  VARCHAR2 	:= NULL
 , p_User_id		           IN  NUMBER
 , p_Language_Code	           IN  VARCHAR2 	:= 'US'
 , p_Transaction_Type              IN  VARCHAR2
 , x_Return_Status                 OUT NOCOPY VARCHAR2
 , x_msg_count			   OUT NOCOPY NUMBER
 , p_debug                   	   IN  VARCHAR2 := 'N'
 , p_output_dir              	   IN  VARCHAR2 := NULL
 , p_debug_filename          	   IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
 , x_catalog_group_id              OUT NOCOPY NUMBER
 , x_catalog_group_name            OUT NOCOPY VARCHAR2
);

PROCEDURE Create_Catalog_Group
(  p_Catalog_Group_Id              IN  NUMBER           := NULL
 , p_Parent_Catalog_Group_Id       IN  NUMBER           := NULL
 , p_Description                   IN  VARCHAR2         := NULL
 , p_Item_Creation_Allowed_Flag    IN  VARCHAR2         := NULL
 , p_Start_Effective_Date          IN  DATE             := NULL
 , p_Inactive_date                 IN  DATE             := NULL
 , p_Enabled_Flag                  IN  VARCHAR2         := NULL
 , p_Summary_Flag                  IN  VARCHAR2         := NULL
 , p_segment1                      IN  VARCHAR2         := NULL
 , p_segment2                      IN  VARCHAR2         := NULL
 , p_segment3                      IN  VARCHAR2         := NULL
 , p_segment4                      IN  VARCHAR2         := NULL
 , p_segment5                      IN  VARCHAR2         := NULL
 , p_segment6                      IN  VARCHAR2         := NULL
 , p_segment7                      IN  VARCHAR2         := NULL
 , p_segment8                      IN  VARCHAR2         := NULL
 , p_segment9                      IN  VARCHAR2         := NULL
 , p_segment10                     IN  VARCHAR2         := NULL
 , p_segment11                     IN  VARCHAR2         := NULL
 , p_segment12                     IN  VARCHAR2         := NULL
 , p_segment13                     IN  VARCHAR2         := NULL
 , p_segment14                     IN  VARCHAR2         := NULL
 , p_segment15                     IN  VARCHAR2         := NULL
 , p_segment16                     IN  VARCHAR2         := NULL
 , p_segment17                     IN  VARCHAR2         := NULL
 , p_segment18                     IN  VARCHAR2         := NULL
 , p_segment19                     IN  VARCHAR2         := NULL
 , p_segment20                     IN  VARCHAR2         := NULL
 , Attribute_category              IN  VARCHAR2         := NULL
 , Attribute1                      IN  VARCHAR2         := NULL
 , Attribute2                      IN  VARCHAR2         := NULL
 , Attribute3                      IN  VARCHAR2         := NULL
 , Attribute4                      IN  VARCHAR2         := NULL
 , Attribute5                      IN  VARCHAR2         := NULL
 , Attribute6                      IN  VARCHAR2         := NULL
 , Attribute7                      IN  VARCHAR2         := NULL
 , Attribute8                      IN  VARCHAR2         := NULL
 , Attribute9                      IN  VARCHAR2         := NULL
 , Attribute10                     IN  VARCHAR2         := NULL
 , Attribute11                     IN  VARCHAR2         := NULL
 , Attribute12                     IN  VARCHAR2         := NULL
 , Attribute13                     IN  VARCHAR2         := NULL
 , Attribute14                     IN  VARCHAR2         := NULL
 , Attribute15                     IN  VARCHAR2         := NULL
 , p_Template_Id                   IN  NUMBER
 , p_User_id                       IN  NUMBER
 , x_return_status                 OUT NOCOPY VARCHAR2
 , x_msg_count                     OUT NOCOPY NUMBER
 , x_msg_data                      OUT NOCOPY VARCHAR2
 , p_debug                         IN  VARCHAR2 := 'N'
 , p_output_dir                    IN  VARCHAR2 := NULL
 , p_debug_filename                IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
 , x_catalog_group_id              OUT NOCOPY NUMBER
 , x_catalog_group_name            OUT NOCOPY VARCHAR2
);

PROCEDURE Update_Catalog_Group
(  p_Catalog_Group_Id              IN  NUMBER           := NULL
 , p_Parent_Catalog_Group_Id       IN  NUMBER           := NULL
 , p_Description                   IN  VARCHAR2         := NULL
 , p_Item_Creation_Allowed_Flag    IN  VARCHAR2         := NULL
 , p_Start_Effective_Date          IN  DATE             := NULL
 , p_Inactive_date                 IN  DATE             := NULL
 , p_Enabled_Flag                  IN  VARCHAR2         := NULL
 , p_Summary_Flag                  IN  VARCHAR2         := NULL
 , p_segment1                      IN  VARCHAR2         := NULL
 , p_segment2                      IN  VARCHAR2         := NULL
 , p_segment3                      IN  VARCHAR2         := NULL
 , p_segment4                      IN  VARCHAR2         := NULL
 , p_segment5                      IN  VARCHAR2         := NULL
 , p_segment6                      IN  VARCHAR2         := NULL
 , p_segment7                      IN  VARCHAR2         := NULL
 , p_segment8                      IN  VARCHAR2         := NULL
 , p_segment9                      IN  VARCHAR2         := NULL
 , p_segment10                     IN  VARCHAR2         := NULL
 , p_segment11                     IN  VARCHAR2         := NULL
 , p_segment12                     IN  VARCHAR2         := NULL
 , p_segment13                     IN  VARCHAR2         := NULL
 , p_segment14                     IN  VARCHAR2         := NULL
 , p_segment15                     IN  VARCHAR2         := NULL
 , p_segment16                     IN  VARCHAR2         := NULL
 , p_segment17                     IN  VARCHAR2         := NULL
 , p_segment18                     IN  VARCHAR2         := NULL
 , p_segment19                     IN  VARCHAR2         := NULL
 , p_segment20                     IN  VARCHAR2         := NULL
 , Attribute_category              IN  VARCHAR2         := NULL
 , Attribute1                      IN  VARCHAR2         := NULL
 , Attribute2                      IN  VARCHAR2         := NULL
 , Attribute3                      IN  VARCHAR2         := NULL
 , Attribute4                      IN  VARCHAR2         := NULL
 , Attribute5                      IN  VARCHAR2         := NULL
 , Attribute6                      IN  VARCHAR2         := NULL
 , Attribute7                      IN  VARCHAR2         := NULL
 , Attribute8                      IN  VARCHAR2         := NULL
 , Attribute9                      IN  VARCHAR2         := NULL
 , Attribute10                     IN  VARCHAR2         := NULL
 , Attribute11                     IN  VARCHAR2         := NULL
 , Attribute12                     IN  VARCHAR2         := NULL
 , Attribute13                     IN  VARCHAR2         := NULL
 , Attribute14                     IN  VARCHAR2         := NULL
 , Attribute15                     IN  VARCHAR2         := NULL
 , p_Template_Id                   IN  NUMBER
 , p_User_id                       IN  NUMBER
 , x_Return_Status                 OUT NOCOPY VARCHAR2
 , x_msg_count                     OUT NOCOPY NUMBER
 , x_msg_data                      OUT NOCOPY VARCHAR2
 , p_debug                         IN  VARCHAR2 := 'N'
 , p_output_dir                    IN  VARCHAR2 := NULL
 , p_debug_filename                IN  VARCHAR2 := 'Ego_Catalog_Grp.log'
 , x_catalog_group_id              OUT NOCOPY NUMBER
 , x_catalog_group_name            OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------
-- Check before deleting an attribute group assoc ----
---------------------------------------------------------------
PROCEDURE Check_Delete_AttrGroup_Assoc
(
    p_api_version                   IN      NUMBER
   ,p_association_id                IN      NUMBER
	 ,p_classification_code           IN      VARCHAR2
	 ,p_data_level                    IN      VARCHAR2
	 ,p_attr_group_id                 IN      NUMBER
	 ,p_application_id                IN      NUMBER
	 ,p_attr_group_type               IN      VARCHAR2
	 ,p_attr_group_name               IN      VARCHAR2
	 ,p_enabled_code                  IN      VARCHAR2
	 ,p_init_msg_list				          IN      VARCHAR2   := fnd_api.g_FALSE
	 ,x_ok_to_delete                  OUT     NOCOPY VARCHAR2
	 ,x_return_status           			OUT     NOCOPY VARCHAR2
	 ,x_errorcode               			OUT     NOCOPY NUMBER
	 ,x_msg_count               			OUT     NOCOPY NUMBER
   ,x_msg_data 			                OUT     NOCOPY VARCHAR2
);

---------------------------------------------------------------
PROCEDURE LOCK_ROW (
  p_item_catalog_group_id          IN       NUMBER,
  p_parent_catalog_group_id        IN       NUMBER,
  p_item_creation_allowed_flag     IN       VARCHAR2,
  p_inactive_date                  IN       DATE,
  p_segment1                       IN       VARCHAR2,
  p_segment2                       IN       VARCHAR2,
  p_segment3                       IN       VARCHAR2,
  p_segment4                       IN       VARCHAR2,
  p_segment5                       IN       VARCHAR2,
  p_segment6                       IN       VARCHAR2,
  p_segment7                       IN       VARCHAR2,
  p_segment8                       IN       VARCHAR2,
  p_segment9                       IN       VARCHAR2,
  p_segment10                      IN       VARCHAR2,
  p_segment11                      IN       VARCHAR2,
  p_segment12                      IN       VARCHAR2,
  p_segment13                      IN       VARCHAR2,
  p_segment14                      IN       VARCHAR2,
  p_segment15                      IN       VARCHAR2,
  p_segment16                      IN       VARCHAR2,
  p_segment17                      IN       VARCHAR2,
  p_segment18                      IN       VARCHAR2,
  p_segment19                      IN       VARCHAR2,
  p_segment20                      IN       VARCHAR2,
  p_description                    IN       VARCHAR2
);




END EGO_ITEM_CATALOG_PUB;

 

/
