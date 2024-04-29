--------------------------------------------------------
--  DDL for Package GMD_RECIPE_DETAIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_DETAIL" AUTHID CURRENT_USER AS
/* $Header: GMDPRCDS.pls 120.5.12010000.4 2010/02/08 18:09:27 rnalla ship $ */
/*#
 * This interface is used to create and update Recipe Details like Process Loss, Customers,
 * Validity Rules and Routing Steps.
 * This package defines and implements the procedures and datatypes required to
 * create and update recipe details.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Recipe Details API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_RECIPE
 */

  /*  Define all record types   */
   TYPE FLEX IS RECORD (
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(240) DEFAULT NULL,
        ATTRIBUTE2              VARCHAR2(240),
        ATTRIBUTE3              VARCHAR2(240),
        ATTRIBUTE4              VARCHAR2(240),
        ATTRIBUTE5              VARCHAR2(240),
        ATTRIBUTE6              VARCHAR2(240),
        ATTRIBUTE7              VARCHAR2(240),
        ATTRIBUTE8              VARCHAR2(240),
        ATTRIBUTE9              VARCHAR2(240),
        ATTRIBUTE10             VARCHAR2(240),
        ATTRIBUTE11             VARCHAR2(240),
        ATTRIBUTE12             VARCHAR2(240),
        ATTRIBUTE13             VARCHAR2(240),
        ATTRIBUTE14             VARCHAR2(240),
        ATTRIBUTE15             VARCHAR2(240),
        ATTRIBUTE16             VARCHAR2(240),
        ATTRIBUTE17             VARCHAR2(240),
        ATTRIBUTE18             VARCHAR2(240),
        ATTRIBUTE19             VARCHAR2(240),
        ATTRIBUTE20             VARCHAR2(240),
        ATTRIBUTE21             VARCHAR2(240),
        ATTRIBUTE22             VARCHAR2(240),
        ATTRIBUTE23             VARCHAR2(240),
        ATTRIBUTE24             VARCHAR2(240),
        ATTRIBUTE25             VARCHAR2(240),
        ATTRIBUTE26             VARCHAR2(240),
        ATTRIBUTE27             VARCHAR2(240),
        ATTRIBUTE28             VARCHAR2(240),
        ATTRIBUTE29             VARCHAR2(240),
        ATTRIBUTE30             VARCHAR2(240)
   );

   TYPE UPDATE_FLEX IS RECORD (
        ATTRIBUTE_CATEGORY      VARCHAR2(30)       ,
        ATTRIBUTE1              VARCHAR2(240)      ,
        ATTRIBUTE2              VARCHAR2(240)      ,
        ATTRIBUTE3              VARCHAR2(240)      ,
        ATTRIBUTE4              VARCHAR2(240)      ,
        ATTRIBUTE5              VARCHAR2(240)      ,
        ATTRIBUTE6              VARCHAR2(240)      ,
        ATTRIBUTE7              VARCHAR2(240)      ,
        ATTRIBUTE8              VARCHAR2(240)      ,
        ATTRIBUTE9              VARCHAR2(240)      ,
        ATTRIBUTE10             VARCHAR2(240)      ,
        ATTRIBUTE11             VARCHAR2(240)      ,
        ATTRIBUTE12             VARCHAR2(240)      ,
        ATTRIBUTE13             VARCHAR2(240)      ,
        ATTRIBUTE14             VARCHAR2(240)      ,
        ATTRIBUTE15             VARCHAR2(240)      ,
        ATTRIBUTE16             VARCHAR2(240)      ,
        ATTRIBUTE17             VARCHAR2(240)      ,
        ATTRIBUTE18             VARCHAR2(240)      ,
        ATTRIBUTE19             VARCHAR2(240)      ,
        ATTRIBUTE20             VARCHAR2(240)      ,
        ATTRIBUTE21             VARCHAR2(240)      ,
        ATTRIBUTE22             VARCHAR2(240)      ,
        ATTRIBUTE23             VARCHAR2(240)      ,
        ATTRIBUTE24             VARCHAR2(240)      ,
        ATTRIBUTE25             VARCHAR2(240)      ,
        ATTRIBUTE26             VARCHAR2(240)      ,
        ATTRIBUTE27             VARCHAR2(240)      ,
        ATTRIBUTE28             VARCHAR2(240)      ,
        ATTRIBUTE29             VARCHAR2(240)      ,
        ATTRIBUTE30             VARCHAR2(240)
   );

   TYPE RECIPE_DTL IS RECORD (
        RECIPE_ID                NUMBER         ,
        RECIPE_NO                VARCHAR2(32)           ,
        RECIPE_VERSION           NUMBER         ,
        USER_ID                  FND_USER.USER_ID%TYPE   ,
        USER_NAME                FND_USER.USER_NAME%TYPE ,
        ORGN_CODE                VARCHAR2(4)   ,
	ORGANIZATION_ID          NUMBER,
	SITE_ID                  NUMBER,
	ORG_ID                   NUMBER,
        RECIPE_PROCESS_LOSS_ID   NUMBER , /* for recipe process loss updates */
        PROCESS_LOSS             NUMBER         , /* for routing steps */
        ACTIVITY_FACTOR          NUMBER         , /* for recipe orgn activities */
        MAX_CAPACITY             NUMBER         , /* for recipe orgn resources */
        MIN_CAPACITY             NUMBER         , /* for recipe orgn resources */
        PROCESS_PARAMETER_1      VARCHAR2(16)   , /* for recipe orgn resources */
        PROCESS_PARAMETER_2      VARCHAR2(16)   , /* for recipe orgn resources */
        PROCESS_PARAMETER_3      VARCHAR2(16)   , /* for recipe orgn resources */
        PROCESS_PARAMETER_4      VARCHAR2(16)   , /* for recipe orgn resources */
        PROCESS_PARAMETER_5      VARCHAR2(16)   , /* for recipe orgn resources */
        CUSTOMER_ID              NUMBER ,
        CUSTOMER_NO              VARCHAR2(32)           ,
        ROUTINGSTEP_ID           NUMBER ,
        OPRN_LINE_ID             NUMBER , /* for recipe orgn act */
        RESOURCES                VARCHAR2(16)   , /* for recipe orgn resources */
        PROCESS_UM               VARCHAR2(25)         ,
        USAGE_UOM                gmd_recipe_orgn_resources.USAGE_UOM%TYPE  ,
        RESOURCE_USAGE           gmd_recipe_orgn_resources.RESOURCE_USAGE%TYPE,
        PROCESS_QTY              gmd_recipe_orgn_resources.PROCESS_QTY%TYPE ,
        STEP_QTY                 gmd_recipe_routing_steps.STEP_QTY%TYPE,
        MASS_QTY                 gmd_recipe_routing_steps.MASS_QTY%TYPE,
        MASS_REF_UOM             gmd_recipe_routing_steps.MASS_REF_UOM%TYPE,
        VOLUME_QTY               gmd_recipe_routing_steps.VOLUME_QTY%TYPE,
        VOLUME_REF_UOM           gmd_recipe_routing_steps.VOLUME_REF_UOM%TYPE,
	MASS_STD_UOM             gmd_recipe_routing_steps.MASS_STD_UOM%TYPE,
	VOLUME_STD_UOM           gmd_recipe_routing_steps.VOLUME_STD_UOM%TYPE,
        TEXT_CODE                NUMBER ,
        DELETE_MARK              NUMBER ,
        CONTIGUOUS_IND           NUMBER ,
        CREATION_DATE            DATE   ,
        CREATED_BY               NUMBER ,
        LAST_UPDATED_BY          NUMBER ,
        LAST_UPDATE_DATE         DATE   ,
        LAST_UPDATE_LOGIN        NUMBER ,
        ITEM_ID                  NUMBER ,
        OWNER_ID                 NUMBER,
	FIXED_PROCESS_LOSS	 NUMBER, /* B6811759*/
	FIXED_PROCESS_LOSS_UOM 	 VARCHAR2(3) /* B6811759*/
   );

   TYPE RECIPE_VR IS RECORD (
         RECIPE_VALIDITY_RULE_ID  NUMBER
        ,RECIPE_ID                NUMBER
        ,RECIPE_NO                VARCHAR2(32)
        ,RECIPE_VERSION           NUMBER
        ,USER_ID                  FND_USER.USER_ID%TYPE
        ,USER_NAME                FND_USER.USER_NAME%TYPE
        ,ORGN_CODE                VARCHAR2(4)
        -- NPD Conv. Modified item_id to inventory_item_id and added Revision column.
        ,INVENTORY_ITEM_ID        NUMBER
        ,REVISION                 VARCHAR2(3)
        ,ITEM_NO                  VARCHAR2(40)
        ,RECIPE_USE               VARCHAR2(30)
        ,PREFERENCE               NUMBER
        ,START_DATE               DATE
        ,END_DATE                 DATE
        ,MIN_QTY                  NUMBER
        ,MAX_QTY                  NUMBER
        ,STD_QTY                  NUMBER
        -- NPD Conv. Modified item_um to detail_uom
        ,DETAIL_UOM               VARCHAR2(25)
        ,INV_MIN_QTY              NUMBER
        ,INV_MAX_QTY              NUMBER
        ,TEXT_CODE                NUMBER
        ,CREATED_BY               NUMBER
        ,CREATION_DATE            DATE
        ,LAST_UPDATED_BY          NUMBER
        ,LAST_UPDATE_DATE         DATE
        ,LAST_UPDATE_LOGIN        NUMBER
        ,DELETE_MARK              NUMBER   := 0
        ,PLANNED_PROCESS_LOSS     NUMBER
        ,VALIDITY_RULE_STATUS     VARCHAR2(30)
        ,ORGANIZATION_ID          NUMBER --w.r.t. bug 4004501 INVCONV kkillams
 	, FIXED_PROCESS_LOSS     NUMBER /* B6811759*/
 	, FIXED_PROCESS_LOSS_UOM  VARCHAR2(3) /* B6811759*/
   );

   TYPE RECIPE_MATERIAL IS RECORD (
        RECIPE_ID                NUMBER  ,
        RECIPE_NO                VARCHAR2(32)    ,
        RECIPE_VERSION           NUMBER  ,
        USER_ID                  FND_USER.USER_ID%TYPE   ,
        USER_NAME                FND_USER.USER_NAME%TYPE ,
        FORMULALINE_ID           NUMBER  ,
        TEXT_CODE                NUMBER  ,
        CREATION_DATE            DATE            ,
        CREATED_BY               NUMBER  ,
        LAST_UPDATED_BY          NUMBER  ,
        LAST_UPDATE_DATE         DATE            ,
        LAST_UPDATE_LOGIN        NUMBER  ,
        ROUTINGSTEP_ID           NUMBER
   );

   /* Define all table types based on the record types above */

   TYPE recipe_detail_tbl IS TABLE OF RECIPE_DTL
        INDEX BY BINARY_INTEGER;

   TYPE recipe_flex IS TABLE OF FLEX
        INDEX BY BINARY_INTEGER;

   TYPE recipe_update_flex IS TABLE OF UPDATE_FLEX
        INDEX BY BINARY_INTEGER;

   TYPE recipe_vr_tbl IS TABLE OF RECIPE_VR
        INDEX BY BINARY_INTEGER;

   TYPE recipe_mtl_tbl IS TABLE OF RECIPE_MATERIAL
        INDEX BY BINARY_INTEGER;


/*#
 * Creates Recipe Process loss
 * This PL/SQL procedure is responsible creating Recipe Process Loss
 * Call is made to CREATE_RECIPE_PROCESS_LOSS of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_detail_tbl Table structure of recipe details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Recipe Process Loss procedure
 * @rep:compatibility S
 */
  PROCEDURE CREATE_RECIPE_PROCESS_LOSS
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl
   );

/*#
 * Creates Recipe Customers
 * This PL/SQL procedure is responsible for creating Recipe Customers
 * Call is made to CREATE_RECIPE_CUSTOMERS of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_detail_tbl Table structure of recipe details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Recipe Customers procedure
 * @rep:compatibility S
 */
  PROCEDURE CREATE_RECIPE_CUSTOMERS
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl
   );

/*#
 * Creates Recipe Validity Rules
 * This PL/SQL procedure is responsible for creating Recipe Validity Rules
 * Call is made to CREATE_RECIPE_VR of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_vr_tbl Table structure of validity rule details
 * @param p_recipe_vr_flex Table structure of validity rule flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Recipe Validity Rule procedure
 * @rep:compatibility S
 */
  PROCEDURE CREATE_RECIPE_VR
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_vr_tbl         IN      recipe_vr_tbl                   ,
        p_recipe_vr_flex        IN      recipe_flex
   );

/*#
 * Creates an entry in Recipe Material Table
 * This PL/SQL procedure creates an entry in Recipe Material Table
 * Call is made to CREATE_RECIPE_MTL of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_mtl_tbl Table structure of recipe material table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Recipe Material procedure
 * @rep:compatibility S
 */
   PROCEDURE CREATE_RECIPE_MTL
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                ,
        x_msg_count             OUT NOCOPY      NUMBER                  ,
        x_msg_data              OUT NOCOPY      VARCHAR2                ,
        p_recipe_mtl_tbl        IN      recipe_mtl_tbl    		,
        p_recipe_mtl_flex       IN      recipe_flex
   );

/*#
 * Updates Recipe Process Loss
 * This PL/SQL procedure is responsible for updating Recipe Process Loss
 * Call is made to of UPDATE_RECIPE_PROCESS_LOSS of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_detail_tbl Table structure of recipe detailsl table
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Recipe Process Loss procedure
 * @rep:compatibility S
 */
   PROCEDURE UPDATE_RECIPE_PROCESS_LOSS
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl
   );

 /*#
 * Updates Recipe Customers
 * This PL/SQL procedure is responsible for updating Recipe Customers
 * Call is made to UPDATE_RECIPE_CUSTOMERS of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_detail_tbl Table structure of recipe details
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Update Recipe Customers procedure
 * @rep:compatibility S
 */
   PROCEDURE UPDATE_RECIPE_CUSTOMERS
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl
   );

 /*#
 * Inserts/Updates Recipe Routing Steps
 * This PL/SQL procedure is responsible for inserting/updating Recipe Routing Steps
 * Call is made to RECIPE_ROUTING_STEPS of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_detail_tbl Table structure of recipe details
 * @param p_recipe_insert_flex Table structure for insert of recipe flex fields
 * @param p_recipe_update_flex Table structure for update of recipe flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Recipe Routing Steps procedure
 * @rep:compatibility S
 */
   PROCEDURE RECIPE_ROUTING_STEPS
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl               ,
        p_recipe_insert_flex    IN      recipe_flex                     ,
        p_recipe_update_flex    IN      recipe_update_flex
   );

/*#
 * Updates Recipe Validity Rules Table
 * This PL/SQL procedure is responsible for updating Recipe Validity Rules
 * Call is made to UPDATE_RECIPE_VR of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_vr_tbl Table structure of validity rule details
 * @param p_recipe_update_flex Table structure for update of validity rule flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Recipe Validity Rule procedure
 * @rep:compatibility S
 */
   PROCEDURE UPDATE_RECIPE_VR
   (    p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                ,
        x_msg_count             OUT NOCOPY      NUMBER                  ,
        x_msg_data              OUT NOCOPY      VARCHAR2                ,
        p_recipe_vr_tbl         IN      recipe_vr_tbl                   ,
        p_recipe_update_flex    IN      recipe_update_flex
   );

/*#
 * Inserts/Updates Recipe Organization Operations
 * This PL/SQL procedure is responsible for inserting/ updating recipe orgn. activities
 * Call is made to RECIPE_ORGN_OPERATIONS of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_detail_tbl Table structure of recipe details
 * @param p_recipe_insert_flex Table structure for insert of recipe flex fields
 * @param p_recipe_update_flex Table structure for update of recipe flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Recipe Organization Operations procedure
 * @rep:compatibility S
 */
  PROCEDURE RECIPE_ORGN_OPERATIONS
  (     p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                        ,
        x_msg_count             OUT NOCOPY      NUMBER                          ,
        x_msg_data              OUT NOCOPY      VARCHAR2                        ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl               ,
        p_recipe_insert_flex    IN      recipe_flex                     ,
        p_recipe_update_flex    IN      recipe_update_flex
  );

/*#
 * Inserts/Updates Recipe Organization Resources
 * This PL/SQL procedure is responsible for inserting/ updating recipe orgn. resources
 * Call is made to RECIPE_ORGN_RESOURCES of GMD_RECIPE_DETAIL_PVT package
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual meesage data on message stack
 * @param p_recipe_detail_tbl Table structure of recipe details
 * @param p_recipe_insert_flex Table structure for insert of recipe flex fields
 * @param p_recipe_update_flex Table structure for update of recipe flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname  Recipe Organization Resources procedure
 * @rep:compatibility S
 */
  PROCEDURE RECIPE_ORGN_RESOURCES
  (     p_api_version           IN      NUMBER                          ,
        p_init_msg_list         IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_commit                IN      VARCHAR2 := FND_API.G_FALSE     ,
        p_called_from_forms     IN      VARCHAR2 := 'NO'                ,
        x_return_status         OUT NOCOPY      VARCHAR2                ,
        x_msg_count             OUT NOCOPY      NUMBER                  ,
        x_msg_data              OUT NOCOPY      VARCHAR2                ,
        p_recipe_detail_tbl     IN      recipe_detail_tbl               ,
        p_recipe_insert_flex    IN      recipe_flex                     ,
        p_recipe_update_flex    IN      recipe_update_flex
  );

END;

/
