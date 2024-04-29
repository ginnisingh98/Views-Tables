--------------------------------------------------------
--  DDL for Package GMD_RECIPE_HEADER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_RECIPE_HEADER" AUTHID CURRENT_USER AS
/* $Header: GMDPRCHS.pls 120.3.12010000.2 2008/11/12 18:50:52 rnalla ship $ */
/*#
 * This interface is used to create, update and delete Recipe Headers.
 * This package defines and implements the procedures and datatypes
 * required to create, update and delete recipe header information.
 * @rep:scope public
 * @rep:product GMD
 * @rep:lifecycle active
 * @rep:displayname Recipe Header API
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMD_RECIPE
 */

   TYPE FLEX IS RECORD (
        ATTRIBUTE_CATEGORY      VARCHAR2(30),
        ATTRIBUTE1              VARCHAR2(240),
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

   TYPE RECIPE_HDR IS RECORD (
         RECIPE_ID              NUMBER(15)
        ,RECIPE_DESCRIPTION     VARCHAR2(70)
        ,RECIPE_NO              VARCHAR2(32)
        ,RECIPE_VERSION         NUMBER(5)
        ,USER_ID                FND_USER.user_id%TYPE
        ,USER_NAME              FND_USER.user_name%TYPE
        ,OWNER_ORGN_CODE        VARCHAR2(4)
        ,CREATION_ORGN_CODE     VARCHAR2(4)
        ,OWNER_ORGANIZATION_ID  NUMBER
        ,CREATION_ORGANIZATION_ID NUMBER
        ,FORMULA_ID             FM_FORM_MST.formula_id%TYPE
        ,FORMULA_NO             FM_FORM_MST.formula_no%TYPE
        ,FORMULA_VERS           FM_FORM_MST.formula_vers%TYPE
        ,ROUTING_ID             NUMBER
        ,ROUTING_NO             FM_ROUT_HDR.routing_no%TYPE
        ,ROUTING_VERS           FM_ROUT_HDR.routing_vers%TYPE
        ,PROJECT_ID             NUMBER(15)
        ,RECIPE_STATUS          VARCHAR2(30)    := '100'
        ,PLANNED_PROCESS_LOSS   NUMBER          := 0
        ,TEXT_CODE              NUMBER(10)
        ,DELETE_MARK            NUMBER(5)       := 0
        ,CONTIGUOUS_IND         NUMBER
        ,ENHANCED_PI_IND        VARCHAR2(1)
        ,RECIPE_TYPE            NUMBER
        ,CREATION_DATE          DATE
        ,CREATED_BY             NUMBER(15)
        ,LAST_UPDATED_BY        NUMBER(15)
        ,LAST_UPDATE_DATE       DATE
        ,LAST_UPDATE_LOGIN      NUMBER(15)
        ,OWNER_ID               NUMBER(15)
        ,OWNER_LAB_TYPE         VARCHAR2(4)
        ,CALCULATE_STEP_QUANTITY NUMBER(5)
	,FIXED_PROCESS_LOSS	NUMBER  /* B6811759 */
	,FIXED_PROCESS_LOSS_UOM VARCHAR2(3) /* B6811759 */
    );

   /* define this record for calculating charges */
   TYPE CHARGE_REC IS RECORD (
        RoutingStep_id  NUMBER,
        Max_Capacity    NUMBER,
        charge          INTEGER
   );

   TYPE PROCESS_LOSS_REC IS RECORD (
        qty             NUMBER  := 0    ,
        Recipe_id       NUMBER          ,
        Formula_id      NUMBER          ,
        Routing_id      NUMBER
   );

   /* All table definitions */
   TYPE recipe_tbl IS TABLE OF RECIPE_HDR
        INDEX BY BINARY_INTEGER;

   TYPE recipe_flex IS TABLE OF FLEX
        INDEX BY BINARY_INTEGER;

   TYPE recipe_update_flex IS TABLE OF UPDATE_FLEX
        INDEX BY BINARY_INTEGER;

   /*  Define a table type for charges  */
   TYPE charge_tbl IS TABLE OF CHARGE_REC
        INDEX BY BINARY_INTEGER;

/*#
 * Inserts Recipe Header
 * This is a PL/SQL procedure to create a recipe header.
 * Call is made to create_recipe_header API of GMD_RECIPE_HEADER_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_recipe_header_tbl Table structure of recipe header
 * @param p_recipe_header_flex Table structure of flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Recipe Header procedure
 * @rep:compatibility S
 */
 PROCEDURE CREATE_RECIPE_HEADER
  (p_api_version            IN          NUMBER
   ,p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE
   ,p_commit                IN          VARCHAR2 := FND_API.G_FALSE
   ,p_called_from_forms     IN          VARCHAR2 := 'NO'
   ,x_return_status         OUT NOCOPY  VARCHAR2
   ,x_msg_count             OUT NOCOPY  NUMBER
   ,x_msg_data              OUT NOCOPY  VARCHAR2
   ,p_recipe_header_tbl     IN          recipe_tbl
   ,p_recipe_header_flex    IN          recipe_flex
  );

/*#
 * Updates Recipe Header
 * This is a PL/SQL procedure to update a recipe header.
 * Call is made to update_recipe_header of GMD_RECIPE_HEADER_PVT package.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_recipe_header_tbl Table structure of recipe header
 * @param p_recipe_update_flex Table structure of flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update Recipe Header procedure
 * @rep:compatibility S
 */
   PROCEDURE UPDATE_RECIPE_HEADER
   ( p_api_version           IN          NUMBER
     ,p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE
     ,p_commit                IN          VARCHAR2 := FND_API.G_FALSE
     ,p_called_from_forms     IN          VARCHAR2 := 'NO'
     ,x_return_status         OUT NOCOPY  VARCHAR2
     ,x_msg_count             OUT NOCOPY  NUMBER
     ,x_msg_data              OUT NOCOPY  VARCHAR2
     ,p_recipe_header_tbl     IN          recipe_tbl
     ,p_recipe_update_flex    IN          recipe_update_flex
   );

/*#
 * Deletes Recipe Header
 * This is a PL/SQL procedure to delete a recipe header
 * Delete in OPM world is not a physical delete.  Its a logical delete
 * (i.e) its an update with the delete_mark set to 1. Therefore prior to
 * calling this procedure the delete_mark needs to be set to 1.
 * @param p_api_version API version field
 * @param p_init_msg_list Flag to check if message list intialized
 * @param p_commit Flag to check for commit
 * @param p_called_from_forms Flag to check if API is called from a form
 * @param x_return_status  'S'-Success, 'E'-Error, 'U'-Unexpected Error
 * @param x_msg_count Number of msg's on message stack
 * @param x_msg_data Actual message data on message stack
 * @param p_recipe_header_tbl Table structure of recipe header
 * @param p_recipe_update_flex Table structure of flex fields
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete Recipe Header procedure
 * @rep:compatibility S
 */
   PROCEDURE DELETE_RECIPE_HEADER
   ( p_api_version           IN          NUMBER
    ,p_init_msg_list         IN          VARCHAR2 := FND_API.G_FALSE
    ,p_commit                IN          VARCHAR2 := FND_API.G_FALSE
    ,p_called_from_forms     IN          VARCHAR2 := 'NO'
    ,x_return_status         OUT NOCOPY  VARCHAR2
    ,x_msg_count             OUT NOCOPY  NUMBER
    ,x_msg_data              OUT NOCOPY  VARCHAR2
    ,p_recipe_header_tbl     IN          recipe_tbl
    ,p_recipe_update_flex    IN          recipe_update_flex
   );

END;

/
