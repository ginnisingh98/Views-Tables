--------------------------------------------------------
--  DDL for Package PA_PLANNING_RESOURCE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLANNING_RESOURCE_PVT" AUTHID CURRENT_USER AS
/* $Header: PAPRESVS.pls 120.1 2005/09/08 02:26:43 appldev noship $*/

/*********************************************************
 * Package : PA_PLANNING_RESOURCE_PVT
 * Description : This Package contains the foll proc/func
 *               Check_pl_alias_unique, Create_Planning_Resource,
 *               Update_Planning_Resource, Delete_Planning_Resource
 *               The details are specified in the Body.
 ********************************************************/
   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;

   -- Global variable for token in error messages for add multiple/single
   -- and AMG API's

   g_token                   VARCHAR2(1000) := null;
   g_amg_flow                VARCHAR2(1) := 'N';

 /***************************************************************
 * Function : Check_pl_alias_unique
 * Description : This Function is used to check the
 *               uniqueness of the resource alias if it is not null.
 *               Further details are specified in the Body.
 *************************************************************/
   FUNCTION Check_pl_alias_unique(
                        p_resource_list_id        IN VARCHAR2,
                        p_resource_alias          IN VARCHAR2,
                        p_resource_list_member_id IN VARCHAR2,
                        p_object_type             IN   VARCHAR2,
                        p_object_id               IN   NUMBER)
   RETURN VARCHAR2;

/**************************************************************
 * Procedure   : Create_Planning_Resource
 * Description : The purpose of this procedure is to Validate
 *               and create a new planning resource  for a
 *               resource list.
 *               Further details specified in the Body.
 *               The reason why the p_resource_list_member_id is being
 *               passed as an IN parameter is because the Mapping
 *               Algorithm is going to pass the resource_list_member_id
 *               in Bulk while calling this proc(instead of using the sequence)
 ****************************************************************/
  PROCEDURE Create_Planning_Resource(
         p_resource_list_member_id IN NUMBER DEFAULT NULL,
         p_resource_list_id       IN   VARCHAR2,
         p_resource_alias         IN   VARCHAR2  DEFAULT NULL,
         p_person_id              IN   NUMBER    DEFAULT NULL,
         p_person_name            IN   VARCHAR2  DEFAULT NULL,
         p_job_id                 IN   NUMBER    DEFAULT NULL,
         p_job_name               IN   VARCHAR2  DEFAULT NULL,
         p_organization_id        IN   NUMBER    DEFAULT NULL,
         p_organization_name      IN   VARCHAR2  DEFAULT NULL,
         p_vendor_id              IN   NUMBER    DEFAULT NULL,
         p_vendor_name            IN   VARCHAR2  DEFAULT NULL,
         p_fin_category_name      IN   VARCHAR2  DEFAULT NULL,
         p_non_labor_resource     IN   VARCHAR2  DEFAULT NULL,
         p_project_role_id        IN   NUMBER    DEFAULT NULL,
         p_project_role_name      IN   VARCHAR2  DEFAULT NULL,
         p_resource_class_id      IN   NUMBER    DEFAULT NULL,
         p_resource_class_code    IN   VARCHAR2  DEFAULT NULL,
         p_res_format_id          IN   NUMBER    ,
         p_spread_curve_id        IN   NUMBER    DEFAULT NULL,
         p_etc_method_code        IN   VARCHAR2  DEFAULT NULL,
         p_mfc_cost_type_id       IN   NUMBER    DEFAULT NULL,
         p_copy_from_rl_flag      IN   VARCHAR2  DEFAULT NULL,
         p_resource_class_flag    IN   VARCHAR2  DEFAULT NULL,
         p_fc_res_type_code       IN   VARCHAR2  DEFAULT NULL,
         p_inventory_item_id      IN   NUMBER    DEFAULT NULL,
         p_inventory_item_name    IN   VARCHAR2  DEFAULT NULL,
         p_item_category_id       IN   NUMBER    DEFAULT NULL,
         p_item_category_name     IN   VARCHAR2  DEFAULT NULL,
         p_migration_code         IN   VARCHAR2  DEFAULT 'N',
         p_attribute_category     IN   VARCHAR2  DEFAULT NULL,
         p_attribute1             IN   VARCHAR2  DEFAULT NULL,
         p_attribute2             IN   VARCHAR2  DEFAULT NULL,
         p_attribute3             IN   VARCHAR2  DEFAULT NULL,
         p_attribute4             IN   VARCHAR2  DEFAULT NULL,
         p_attribute5             IN   VARCHAR2  DEFAULT NULL,
         p_attribute6             IN   VARCHAR2  DEFAULT NULL,
         p_attribute7             IN   VARCHAR2  DEFAULT NULL,
         p_attribute8             IN   VARCHAR2  DEFAULT NULL,
         p_attribute9             IN   VARCHAR2  DEFAULT NULL,
         p_attribute10            IN   VARCHAR2  DEFAULT NULL,
         p_attribute11            IN   VARCHAR2  DEFAULT NULL,
         p_attribute12            IN   VARCHAR2  DEFAULT NULL,
         p_attribute13            IN   VARCHAR2  DEFAULT NULL,
         p_attribute14            IN   VARCHAR2  DEFAULT NULL,
         p_attribute15            IN   VARCHAR2  DEFAULT NULL,
         p_attribute16            IN   VARCHAR2  DEFAULT NULL,
         p_attribute17            IN   VARCHAR2  DEFAULT NULL,
         p_attribute18            IN   VARCHAR2  DEFAULT NULL,
         p_attribute19            IN   VARCHAR2  DEFAULT NULL,
         p_attribute20            IN   VARCHAR2  DEFAULT NULL,
         p_attribute21            IN   VARCHAR2  DEFAULT NULL,
         p_attribute22            IN   VARCHAR2  DEFAULT NULL,
         p_attribute23            IN   VARCHAR2  DEFAULT NULL,
         p_attribute24            IN   VARCHAR2  DEFAULT NULL,
         p_attribute25            IN   VARCHAR2  DEFAULT NULL,
         p_attribute26            IN   VARCHAR2  DEFAULT NULL,
         p_attribute27            IN   VARCHAR2  DEFAULT NULL,
         p_attribute28            IN   VARCHAR2  DEFAULT NULL,
         p_attribute29            IN   VARCHAR2  DEFAULT NULL,
         p_attribute30            IN   VARCHAR2  DEFAULT NULL,
         p_person_type_code       IN   VARCHAR2  DEFAULT NULL,
         p_bom_resource_id        IN   NUMBER    DEFAULT NULL,
         p_bom_resource_name      IN   VARCHAR2  DEFAULT NULL,
         p_team_role              IN   VARCHAR2  DEFAULT NULL,
         --p_named_role             IN   VARCHAR2  DEFAULT NULL,
         p_incur_by_res_code      IN   VARCHAR2  DEFAULT NULL,
         p_incur_by_res_type      IN   VARCHAR2  DEFAULT NULL,
         p_project_id             IN   NUMBER    DEFAULT NULL,
         p_init_msg_list          IN   VARCHAR2  DEFAULT FND_API.G_FALSE,  -- Added for bug#4350589
         x_resource_list_member_id OUT NOCOPY   NUMBER  ,
         x_record_version_number  OUT  NOCOPY   NUMBER  ,
         x_return_status          OUT  NOCOPY   VARCHAR2  ,
         x_msg_count              OUT  NOCOPY   NUMBER    ,
         x_error_msg_data         OUT  NOCOPY   VARCHAR2  );

/***************************************************
 * Procedure : Update_Planning_Resource
 * Description : The purpose of this procedure is to
 *               Validate and update attributes on an existing
 *               planning resource for a resource list.
 *               Further details in the Body.
***************************************************/
PROCEDURE Update_Planning_Resource(
         p_resource_list_id         IN   NUMBER,
         p_resource_list_member_id   IN   NUMBER,
         p_enabled_flag              IN   VARCHAR2,
         p_resource_alias            IN   VARCHAR2  ,
         p_spread_curve_id           IN   NUMBER    DEFAULT NULL,
         p_etc_method_code           IN   VARCHAR2  DEFAULT NULL,
         p_mfc_cost_type_id          IN   NUMBER    DEFAULT NULL,
         p_attribute_category        IN   VARCHAR2  DEFAULT NULL,
         p_attribute1                IN   VARCHAR2  DEFAULT NULL,
         p_attribute2                IN   VARCHAR2  DEFAULT NULL,
         p_attribute3                IN   VARCHAR2  DEFAULT NULL,
         p_attribute4                IN   VARCHAR2  DEFAULT NULL,
         p_attribute5                IN   VARCHAR2  DEFAULT NULL,
         p_attribute6                IN   VARCHAR2  DEFAULT NULL,
         p_attribute7                IN   VARCHAR2  DEFAULT NULL,
         p_attribute8                IN   VARCHAR2  DEFAULT NULL,
         p_attribute9                IN   VARCHAR2  DEFAULT NULL,
         p_attribute10               IN   VARCHAR2  DEFAULT NULL,
         p_attribute11               IN   VARCHAR2  DEFAULT NULL,
         p_attribute12               IN   VARCHAR2  DEFAULT NULL,
         p_attribute13               IN   VARCHAR2  DEFAULT NULL,
         p_attribute14               IN   VARCHAR2  DEFAULT NULL,
         p_attribute15               IN   VARCHAR2  DEFAULT NULL,
         p_attribute16               IN   VARCHAR2  DEFAULT NULL,
         p_attribute17               IN   VARCHAR2  DEFAULT NULL,
         p_attribute18               IN   VARCHAR2  DEFAULT NULL,
         p_attribute19               IN   VARCHAR2  DEFAULT NULL,
         p_attribute20               IN   VARCHAR2  DEFAULT NULL,
         p_attribute21               IN   VARCHAR2  DEFAULT NULL,
         p_attribute22               IN   VARCHAR2  DEFAULT NULL,
         p_attribute23               IN   VARCHAR2  DEFAULT NULL,
         p_attribute24               IN   VARCHAR2  DEFAULT NULL,
         p_attribute25               IN   VARCHAR2  DEFAULT NULL,
         p_attribute26               IN   VARCHAR2  DEFAULT NULL,
         p_attribute27               IN   VARCHAR2  DEFAULT NULL,
         p_attribute28               IN   VARCHAR2  DEFAULT NULL,
         p_attribute29               IN   VARCHAR2  DEFAULT NULL,
         p_attribute30               IN   VARCHAR2  DEFAULT NULL,
         p_record_version_number     IN   NUMBER,
         x_record_version_number     OUT    NOCOPY   NUMBER  ,
         x_return_status             OUT    NOCOPY   VARCHAR2  ,
         x_msg_count                 OUT    NOCOPY   NUMBER    ,
         x_error_msg_data            OUT    NOCOPY   VARCHAR2  );

/*************************************************
 * Procedure : Delete_Planning_Resource
 * Description : The purpose of this procedure is to
 *              delete a planning resource if it is not
 *              being used, else disable it.
 *              Further details in the Body.
 ***************************************************/
PROCEDURE Delete_Planning_Resource(
         p_resource_list_member_id  IN   NUMBER,
         x_return_status            OUT NOCOPY  VARCHAR2,
         x_msg_count                OUT NOCOPY  NUMBER,
         x_error_msg_data           OUT NOCOPY  VARCHAR2);


PROCEDURE Copy_Planning_Resources(
        p_source_resource_list_id       IN  Number,
        p_destination_resource_list_id  IN  Number,
        p_src_res_list_member_id_tbl    IN  SYSTEM.PA_NUM_TBL_TYPE,
        x_dest_res_list_member_id_tbl   OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE,
        p_destination_project_id        IN  Number DEFAULT NULL);



END Pa_Planning_Resource_Pvt;

 

/
