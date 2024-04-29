--------------------------------------------------------
--  DDL for Package PA_PLANNING_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLANNING_RESOURCE_PUB" AUTHID CURRENT_USER AS
/* $Header: PAPRESPS.pls 120.0 2005/06/03 13:48:17 appldev noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
  -- g_last_update_login       NUMBER(15) := FND_GLOBAL.LOG_ID;

/**************************************************************
 * Record Structure Declaration
 * Record : PLANNING_RESOURCE_IN_REC
 * ***********************************************************/
TYPE Planning_Resource_In_Rec IS RECORD
(
         p_resource_list_member_id   NUMBER        DEFAULT NULL,
         p_resource_alias            VARCHAR2(80)  DEFAULT NULL,
         p_person_id                 NUMBER        DEFAULT NULL,
         p_person_name               VARCHAR2(240)  DEFAULT NULL,
         p_job_id                    NUMBER        DEFAULT NULL,
         p_job_name                  VARCHAR2(240)  DEFAULT NULL,
         p_organization_id           NUMBER        DEFAULT NULL,
         p_organization_name         VARCHAR2(240)  DEFAULT NULL,
         p_vendor_id                 NUMBER        DEFAULT NULL,
         -- 3592496
         p_vendor_name               VARCHAR2(240) DEFAULT NULL,
         p_fin_category_name         VARCHAR2(30)  DEFAULT NULL,
         p_non_labor_resource        VARCHAR2(30)  DEFAULT NULL,
         p_project_role_id           NUMBER        DEFAULT NULL,
         p_project_role_name         VARCHAR2(80)  DEFAULT NULL,
         p_resource_class_id         NUMBER        DEFAULT NULL,
         p_resource_class_code       VARCHAR2(30)  DEFAULT NULL,
         p_res_format_id             NUMBER        ,
         p_spread_curve_id           NUMBER        DEFAULT NULL,
         p_etc_method_code           VARCHAR2(30)  DEFAULT NULL,
         p_mfc_cost_type_id          NUMBER        DEFAULT NULL,
         p_copy_from_rl_flag         VARCHAR2(1)   DEFAULT NULL,
         p_resource_class_flag       VARCHAR2(1)   DEFAULT NULL,
         p_fc_res_type_code          VARCHAR2(30)  DEFAULT NULL,
         p_inventory_item_id         NUMBER        DEFAULT NULL,
         p_inventory_item_name       VARCHAR2(80)  DEFAULT NULL,
         p_item_category_id          NUMBER        DEFAULT NULL,
         p_item_category_name        VARCHAR2(150) DEFAULT NULL,
         p_migration_code            VARCHAR2(150) DEFAULT 'N',
         p_attribute_category        VARCHAR2(150) DEFAULT NULL,
         p_attribute1                VARCHAR2(150) DEFAULT NULL,
         p_attribute2                VARCHAR2(150) DEFAULT NULL,
         p_attribute3                VARCHAR2(150) DEFAULT NULL,
         p_attribute4                VARCHAR2(150) DEFAULT NULL,
         p_attribute5                VARCHAR2(150) DEFAULT NULL,
         p_attribute6                VARCHAR2(150) DEFAULT NULL,
         p_attribute7                VARCHAR2(150) DEFAULT NULL,
         p_attribute8                VARCHAR2(150) DEFAULT NULL,
         p_attribute9                VARCHAR2(150) DEFAULT NULL,
         p_attribute10               VARCHAR2(150) DEFAULT NULL,
         p_attribute11               VARCHAR2(150) DEFAULT NULL,
         p_attribute12               VARCHAR2(150) DEFAULT NULL,
         p_attribute13               VARCHAR2(150) DEFAULT NULL,
         p_attribute14               VARCHAR2(150) DEFAULT NULL,
         p_attribute15               VARCHAR2(150) DEFAULT NULL,
         p_attribute16               VARCHAR2(150) DEFAULT NULL,
         p_attribute17               VARCHAR2(150) DEFAULT NULL,
         p_attribute18               VARCHAR2(150) DEFAULT NULL,
         p_attribute19               VARCHAR2(150) DEFAULT NULL,
         p_attribute20               VARCHAR2(150) DEFAULT NULL,
         p_attribute21               VARCHAR2(150) DEFAULT NULL,
         p_attribute22               VARCHAR2(150) DEFAULT NULL,
         p_attribute23               VARCHAR2(150) DEFAULT NULL,
         p_attribute24               VARCHAR2(150) DEFAULT NULL,
         p_attribute25               VARCHAR2(150) DEFAULT NULL,
         p_attribute26               VARCHAR2(150) DEFAULT NULL,
         p_attribute27               VARCHAR2(150) DEFAULT NULL,
         p_attribute28               VARCHAR2(150) DEFAULT NULL,
         p_attribute29               VARCHAR2(150) DEFAULT NULL,
         p_attribute30               VARCHAR2(150) DEFAULT NULL,
         p_person_type_code          VARCHAR2(30)  DEFAULT NULL,
         p_bom_resource_id           NUMBER        DEFAULT NULL,
         p_bom_resource_name         VARCHAR2(30)  DEFAULT NULL,
         p_team_role                 VARCHAR2(80)  DEFAULT NULL,
         p_incur_by_res_code         VARCHAR2(30)  DEFAULT NULL,
         p_incur_by_res_type         VARCHAR2(30)  DEFAULT NULL,
         p_record_version_number     NUMBER,
         p_project_id                NUMBER
);


/**************************************************************
 * Record Structure Declaration
 * Record : PLANNING_RESOURCE_OUT_REC
 * ***********************************************************/
TYPE Planning_Resource_Out_Rec IS RECORD
(
         x_resource_list_member_id   NUMBER        DEFAULT NULL,
         x_record_version_number     NUMBER        DEFAULT NULL);

/*************************************************************
 * Table of records
 * Table : PLANNING_RESOURCE_IN_TBL
 ************************************************************/
TYPE Planning_Resource_In_Tbl IS TABLE OF Planning_Resource_In_Rec
 INDEX BY BINARY_INTEGER;


/*************************************************************
 * Table of records
 * Table : PLANNING_RESOURCE_OUT_TBL
 ************************************************************/
TYPE Planning_Resource_Out_Tbl IS TABLE OF Planning_Resource_Out_Rec
 INDEX BY BINARY_INTEGER;

/**************************************************************
 * Procedure   : Create_Planning_Resource
 * Description : The purpose of this procedure is to Validate
 *               and create a new planning resource  for a
 *               resource list.
 *               Further details specified in the Body.
 ****************************************************************/
PROCEDURE Create_Planning_Resource(
       p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_init_msg_list             IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_resource_list_id          IN    VARCHAR2,
       P_planning_resource_in_tbl  IN           Planning_Resource_In_Tbl,
       X_planning_resource_out_tbl OUT NOCOPY   Planning_Resource_Out_Tbl,
       x_return_status             OUT NOCOPY   VARCHAR2,
       x_msg_count                 OUT NOCOPY  NUMBER,
       x_error_msg_data            OUT NOCOPY  VARCHAR2  );

/**************************************************************
 * Procedure   : Create_Planning_Resource
 * Description : The purpose of this procedure is to Validate
 *               and create a new planning resource  for a
 *               resource list.
 *               Further details specified in the Body.
 ****************************************************************/
PROCEDURE Create_Planning_Resource(
   p_resource_list_id      IN    VARCHAR2,
   p_resource_list_member_id IN   SYSTEM.PA_NUM_TBL_TYPE DEFAULT NULL,
   p_resource_alias        IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
   p_person_id             IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   -- Bug 3593613
   p_person_name           IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
   p_job_id                IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   -- Bug 3593613
   p_job_name              IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
   p_organization_id       IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   -- Bug 3593613
   p_organization_name     IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
   p_vendor_id             IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   --Bug 3592496
   p_vendor_name           IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
   p_fin_category_name     IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_non_labor_resource    IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_project_role_id       IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   -- Bug 3593613
   p_project_role_name     IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
   p_resource_class_id     IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   p_resource_class_code   IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_res_format_id         IN   SYSTEM.PA_NUM_TBL_TYPE    ,
   p_spread_curve_id       IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   p_etc_method_code       IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_mfc_cost_type_id      IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   p_copy_from_rl_flag     IN   SYSTEM.PA_VARCHAR2_1_TBL_TYPE  DEFAULT NULL,
   p_resource_class_flag   IN   SYSTEM.PA_VARCHAR2_1_TBL_TYPE  DEFAULT NULL,
   p_fc_res_type_code      IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_inventory_item_id     IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   -- Bug 3593613
   p_inventory_item_name   IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
   p_item_category_id      IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   p_item_category_name    IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_migration_code        IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE ,
   p_attribute_category    IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_attribute1            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute2            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute3            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute4            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute5            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute6            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute7            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute8            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute9            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute10           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute11           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute12           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute13           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute14           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute15           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute16           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute17           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute18           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute19           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute20           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute21           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute22           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute23           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute24           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute25           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute26           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute27           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute28           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute29           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_attribute30           IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
   p_person_type_code      IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_bom_resource_id       IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
   p_bom_resource_name     IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_team_role             IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
   --p_named_role            IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
   p_incur_by_res_code     IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_incur_by_res_type     IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
   p_commit                IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_init_msg_list         IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
   p_project_id            IN   NUMBER DEFAULT NULL,
   x_resource_list_member_id OUT NOCOPY   SYSTEM.PA_NUM_TBL_TYPE  ,
   x_record_version_number OUT   NOCOPY   SYSTEM.PA_NUM_TBL_TYPE  ,
   x_return_status         OUT   NOCOPY   VARCHAR2  ,
   x_msg_count             OUT   NOCOPY   NUMBER    ,
   x_error_msg_data        OUT   NOCOPY   VARCHAR2  );

/***************************************************
 * Procedure : Update_Planning_Resource
 * Description : The purpose of this procedure is to
 *               Validate and update attributes on an existing
 *               planning resource for a resource list.
 *               Further details in the Body.
***************************************************/
PROCEDURE Update_Planning_Resource
       (p_commit                  IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_init_msg_list            IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_resource_list_id         IN    NUMBER,
       p_enabled_flag             IN    VARCHAR2,
       P_planning_resource_in_tbl IN            Planning_Resource_In_Tbl,
       X_planning_resource_out_tbl  OUT NOCOPY    Planning_Resource_Out_Tbl,
       x_return_status            OUT NOCOPY  VARCHAR2,
       x_msg_count                OUT NOCOPY  NUMBER,
       x_error_msg_data           OUT NOCOPY  VARCHAR2  );

PROCEDURE Update_Planning_Resource(
    p_resource_list_id       IN   NUMBER,
    p_resource_list_member_id IN   SYSTEM.PA_NUM_TBL_TYPE,
    p_enabled_flag           IN   VARCHAR2,
    p_resource_alias         IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  ,
    p_spread_curve_id        IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
    p_etc_method_code        IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
    p_mfc_cost_type_id       IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
    p_attribute_category     IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute1             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute2             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute3             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute4             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute5             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute6             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute7             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute8             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute9             IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute10            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute11            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute12            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute13            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute14            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute15            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute16            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute17            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute18            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute19            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute20            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute21            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute22            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute23            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute24            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute25            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute26            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute27            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute28            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute29            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_attribute30            IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
    p_record_version_number  IN   SYSTEM.PA_NUM_TBL_TYPE  ,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_record_version_number  OUT     NOCOPY   SYSTEM.PA_NUM_TBL_TYPE  ,
    x_return_status          OUT    NOCOPY   VARCHAR2  ,
    x_msg_count              OUT    NOCOPY   NUMBER    ,
    x_error_msg_data         OUT    NOCOPY   VARCHAR2  );


/*************************************************
 * Procedure : Delete_Planning_Resource
 * Description : The purpose of this procedure is to
 *              delete a planning resource if it is not
 *              being used, else disable it.
 *              Further details in the Body.
 ***************************************************/
PROCEDURE Delete_Planning_Resource(
         p_resource_list_member_id  IN   SYSTEM.PA_NUM_TBL_TYPE  ,
         p_commit                   IN  VARCHAR2,
         p_init_msg_list            IN  VARCHAR2,
         x_return_status            OUT NOCOPY  VARCHAR2,
         x_msg_count                OUT NOCOPY  NUMBER,
         x_error_msg_data           OUT NOCOPY  VARCHAR2);


END Pa_Planning_Resource_Pub;

 

/
