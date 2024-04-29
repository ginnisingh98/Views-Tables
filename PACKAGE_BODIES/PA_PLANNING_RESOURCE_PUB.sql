--------------------------------------------------------
--  DDL for Package Body PA_PLANNING_RESOURCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PLANNING_RESOURCE_PUB" AS
/* $Header: PAPRESPB.pls 120.0 2005/05/30 10:13:59 appldev noship $*/

/**************************************************************
 * Procedure   : Create_Planning_Resource
 * Description : The purpose of this procedure is to Validate
 *               and create a new planning resource  for a
 *               resource list.
 *               It first checks for the uniqueness of the
 *               p_resource_alias
 * Calls Prog  : pa_planning_resource_utils.Validate_Planning_Resource,
 *               pa_res_list_members_pkg.insert_row
 *               pa_planning_resource_utils. Get_Plan_Res_Combination
 ****************************************************************/
PROCEDURE Create_Planning_Resource(
       p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_init_msg_list             IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_resource_list_id          IN    VARCHAR2,
       P_planning_resource_in_tbl  IN           Planning_Resource_In_Tbl,
       X_planning_resource_out_tbl OUT NOCOPY   Planning_Resource_Out_Tbl,
       x_return_status             OUT NOCOPY  VARCHAR2,
       x_msg_count                 OUT NOCOPY  NUMBER,
       x_error_msg_data            OUT NOCOPY  VARCHAR2  )
IS
BEGIN
-- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   /***************************************************************
    * For Loop. To loop through the table of records and
    * Validate each one of them and insert accordingly.
    **************************************************************/
 FOR i IN 1..P_Planning_Resource_In_Tbl.COUNT
 LOOP
    /*************************************************
    * Assigning Initial values for some of the elements.
    *************************************************/
     x_msg_count :=    0;
     x_return_status   :=    FND_API.G_RET_STS_SUCCESS;
     /******************************************************
     * Call to pa_planning_resource_pvt.create_planning_resource
     * which would take care of the validation and creation
     * of the resource list members. The table elements are being passed as
     * parameters.
      ******************************************************/
 Pa_Planning_Resource_Pvt.Create_Planning_Resource
   (p_resource_list_id    => p_resource_list_id,
   p_resource_list_member_id =>
              P_planning_resource_in_tbl(i).p_resource_list_member_id,
   p_resource_alias      => P_planning_resource_in_tbl(i).p_resource_alias,
   p_person_id           => P_planning_resource_in_tbl(i).p_person_id,
   p_person_name         => P_planning_resource_in_tbl(i).p_person_name,
   p_job_id              => P_planning_resource_in_tbl(i).p_job_id,
   p_job_name            => P_planning_resource_in_tbl(i).p_job_name,
   p_organization_id     => P_planning_resource_in_tbl(i).p_organization_id,
   p_organization_name   => P_planning_resource_in_tbl(i).p_organization_name,
   p_vendor_id           => P_planning_resource_in_tbl(i).p_vendor_id,
   p_vendor_name         => P_planning_resource_in_tbl(i).p_vendor_name,
   p_fin_category_name   => P_planning_resource_in_tbl(i).p_fin_category_name,
   p_non_labor_resource  => P_planning_resource_in_tbl(i).p_non_labor_resource,
   p_project_role_id     => P_planning_resource_in_tbl(i).p_project_role_id,
   p_project_role_name   => P_planning_resource_in_tbl(i).p_project_role_name,
   p_resource_class_id   => P_planning_resource_in_tbl(i).p_resource_class_id,
   p_resource_class_code => P_planning_resource_in_tbl(i).p_resource_class_code,
   p_res_format_id       => P_planning_resource_in_tbl(i).p_res_format_id,
   p_spread_curve_id     => P_planning_resource_in_tbl(i).p_spread_curve_id,
   p_etc_method_code     => P_planning_resource_in_tbl(i).p_etc_method_code,
   p_mfc_cost_type_id    => P_planning_resource_in_tbl(i).p_mfc_cost_type_id,
   p_copy_from_rl_flag   => P_planning_resource_in_tbl(i).p_copy_from_rl_flag,
   p_resource_class_flag => P_planning_resource_in_tbl(i).p_resource_class_flag,
   p_fc_res_type_code    => P_planning_resource_in_tbl(i).p_fc_res_type_code,
   p_inventory_item_id   => P_planning_resource_in_tbl(i).p_inventory_item_id,
   p_inventory_item_name => P_planning_resource_in_tbl(i).p_inventory_item_name,
   p_item_category_id    => P_planning_resource_in_tbl(i).p_item_category_id,
   p_item_category_name  => P_planning_resource_in_tbl(i).p_item_category_name,
   p_migration_code      => P_planning_resource_in_tbl(i).p_migration_code,
   p_attribute_category  => P_planning_resource_in_tbl(i).p_attribute_category,
   p_attribute1          => P_planning_resource_in_tbl(i).p_attribute1,
   p_attribute2          => P_planning_resource_in_tbl(i).p_attribute2,
   p_attribute3          => P_planning_resource_in_tbl(i).p_attribute3,
   p_attribute4          => P_planning_resource_in_tbl(i).p_attribute4,
   p_attribute5          => P_planning_resource_in_tbl(i).p_attribute5,
   p_attribute6          => P_planning_resource_in_tbl(i).p_attribute6,
   p_attribute7          => P_planning_resource_in_tbl(i).p_attribute7,
   p_attribute8          => P_planning_resource_in_tbl(i).p_attribute8,
   p_attribute9          => P_planning_resource_in_tbl(i).p_attribute9,
   p_attribute10         => P_planning_resource_in_tbl(i).p_attribute10,
   p_attribute11         => P_planning_resource_in_tbl(i).p_attribute11,
   p_attribute12         => P_planning_resource_in_tbl(i).p_attribute12,
   p_attribute13         => P_planning_resource_in_tbl(i).p_attribute13,
   p_attribute14         => P_planning_resource_in_tbl(i).p_attribute14,
   p_attribute15         => P_planning_resource_in_tbl(i).p_attribute15,
   p_attribute16         => P_planning_resource_in_tbl(i).p_attribute16,
   p_attribute17         => P_planning_resource_in_tbl(i).p_attribute17,
   p_attribute18         => P_planning_resource_in_tbl(i).p_attribute18,
   p_attribute19         => P_planning_resource_in_tbl(i).p_attribute19,
   p_attribute20         => P_planning_resource_in_tbl(i).p_attribute20,
   p_attribute21         => P_planning_resource_in_tbl(i).p_attribute21,
   p_attribute22         => P_planning_resource_in_tbl(i).p_attribute22,
   p_attribute23         => P_planning_resource_in_tbl(i).p_attribute23,
   p_attribute24         => P_planning_resource_in_tbl(i).p_attribute24,
   p_attribute25         => P_planning_resource_in_tbl(i).p_attribute25,
   p_attribute26         => P_planning_resource_in_tbl(i).p_attribute26,
   p_attribute27         => P_planning_resource_in_tbl(i).p_attribute27,
   p_attribute28         => P_planning_resource_in_tbl(i).p_attribute28,
   p_attribute29         => P_planning_resource_in_tbl(i).p_attribute29,
   p_attribute30         => P_planning_resource_in_tbl(i).p_attribute30,
   p_person_type_code    => P_planning_resource_in_tbl(i).p_person_type_code,
   p_bom_resource_id     =>  P_planning_resource_in_tbl(i).p_bom_resource_id,
   p_bom_resource_name   => P_planning_resource_in_tbl(i).p_bom_resource_name,
   p_team_role           => P_planning_resource_in_tbl(i).p_team_role,
   p_incur_by_res_code   => P_planning_resource_in_tbl(i).p_incur_by_res_code,
   p_incur_by_res_type   => P_planning_resource_in_tbl(i).p_incur_by_res_type,
   x_resource_list_member_id =>
            x_planning_resource_out_tbl(i).x_resource_list_member_id,
   x_record_version_number =>
            x_planning_resource_out_tbl(i).x_record_version_number,
   x_return_status       => x_return_status,
   x_msg_count           => x_msg_count  ,
   x_error_msg_data      => x_error_msg_data);

END LOOP;
/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
/***************/

/***************************************/
END Create_Planning_Resource;
/*****************************************************/

/**************************************************************
 * Procedure   : Create_Planning_Resource
 * Description : The purpose of this procedure is to Validate
 *               and create a new planning resource  for a
 *               resource list.
 * Calls Prog  : pa_Planning_resource_pvt.Create_Planning_Resource
 ****************************************************************/
PROCEDURE Create_Planning_Resource(
  p_resource_list_id       IN    VARCHAR2,
  p_resource_list_member_id  IN  SYSTEM.PA_NUM_TBL_TYPE  DEFAULT NULL,
  p_resource_alias         IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
  p_person_id              IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  --Bug 3593613
  p_person_name            IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
  p_job_id                 IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  -- Bug 3593613
  p_job_name               IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
  p_organization_id        IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_organization_name      IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
  p_vendor_id              IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  --Bug 3592496
  p_vendor_name            IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE  DEFAULT NULL,
  p_fin_category_name      IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_non_labor_resource     IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_project_role_id        IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_project_role_name      IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
  p_resource_class_id      IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_resource_class_code    IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_res_format_id          IN   SYSTEM.PA_NUM_TBL_TYPE    ,
  p_spread_curve_id        IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_etc_method_code        IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_mfc_cost_type_id       IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_copy_from_rl_flag      IN   SYSTEM.PA_VARCHAR2_1_TBL_TYPE  DEFAULT NULL,
  p_resource_class_flag    IN   SYSTEM.PA_VARCHAR2_1_TBL_TYPE  DEFAULT NULL,
  p_fc_res_type_code       IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_inventory_item_id      IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_inventory_item_name    IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
  p_item_category_id       IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_item_category_name     IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE  DEFAULT NULL,
  p_migration_code         IN   SYSTEM.PA_VARCHAR2_150_TBL_TYPE ,
  p_attribute_category     IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
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
  p_person_type_code       IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_bom_resource_id        IN   SYSTEM.PA_NUM_TBL_TYPE    DEFAULT NULL,
  p_bom_resource_name      IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_team_role              IN   SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT NULL,
  p_incur_by_res_code      IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_incur_by_res_type      IN   SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT NULL,
  p_commit                 IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_init_msg_list          IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
  p_project_id             IN    NUMBER DEFAULT NULL,
  x_resource_list_member_id OUT NOCOPY   SYSTEM.PA_NUM_TBL_TYPE  ,
  x_record_version_number  OUT     NOCOPY   SYSTEM.PA_NUM_TBL_TYPE  ,
  x_return_status          OUT     NOCOPY   VARCHAR2  ,
  x_msg_count              OUT     NOCOPY   NUMBER    ,
  x_error_msg_data         OUT     NOCOPY   VARCHAR2  )
IS
BEGIN
    x_record_version_number := SYSTEM.PA_NUM_TBL_TYPE();
    x_resource_list_member_id := SYSTEM.PA_NUM_TBL_TYPE();
    x_record_version_number.extend(p_res_format_id.count) ;
    x_resource_list_member_id.extend(p_res_format_id.count) ;

-- First clear the message stack.
   IF FND_API.to_boolean(p_init_msg_list)
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   /***************************************************************
    * For Loop. To loop through the table of records and
    * Validate each one of them and insert accordingly.
    **************************************************************/
    FOR i IN p_res_format_id.first..p_res_format_id.last
    LOOP
       /*************************************************
       * Assigning Initial values for some of the elements.
       *************************************************/
        x_msg_count :=    0;
        x_return_status   :=    FND_API.G_RET_STS_SUCCESS;
        /******************************************************
        * Call to pa_planning_resource_pvt.create_planning_resource
        * which would take care of the validation and creation
        * of the resource list members. The table elements are being passed as
        * parameters.
        ******************************************************/
  Pa_Planning_Resource_Pvt.Create_Planning_Resource
   (p_resource_list_id        => p_resource_list_id,
    p_project_id              => p_project_id,
    p_resource_list_member_id => p_resource_list_member_id(i),
    p_resource_alias          => p_resource_alias(i),
    p_person_id               => p_person_id(i),
    p_person_name             => p_person_name(i),
    p_job_id                  => p_job_id(i),
    p_job_name                => p_job_name(i),
    p_organization_id         => p_organization_id(i),
    p_organization_name       => p_organization_name(i),
    p_vendor_id               => p_vendor_id(i),
    p_vendor_name             => p_vendor_name(i),
    p_fin_category_name       => p_fin_category_name(i),
    p_non_labor_resource      => p_non_labor_resource(i),
    p_project_role_id         => p_project_role_id(i),
    p_project_role_name       => p_project_role_name(i),
    p_resource_class_id       => p_resource_class_id(i),
    p_resource_class_code     => P_resource_class_code(i),
    p_res_format_id           => p_res_format_id(i),
    p_spread_curve_id         => p_spread_curve_id(i),
    p_etc_method_code         => p_etc_method_code(i),
    p_mfc_cost_type_id        => p_mfc_cost_type_id(i),
    p_copy_from_rl_flag       => p_copy_from_rl_flag(i),
    p_resource_class_flag     => p_resource_class_flag(i),
    p_fc_res_type_code        => p_fc_res_type_code(i),
    p_inventory_item_id       => p_inventory_item_id(i),
    p_inventory_item_name     => p_inventory_item_name(i),
    p_item_category_id        => p_item_category_id(i),
    p_item_category_name      => p_item_category_name(i),
    p_migration_code          => p_migration_code(i),
    p_attribute_category      => p_attribute_category(i),
    p_attribute1              => p_attribute1(i),
    p_attribute2              => p_attribute2(i),
    p_attribute3              => p_attribute3(i),
    p_attribute4              => p_attribute4(i),
    p_attribute5              => p_attribute5(i),
    p_attribute6              => p_attribute6(i),
    p_attribute7              => p_attribute7(i),
    p_attribute8              => p_attribute8(i),
    p_attribute9              => p_attribute9(i),
    p_attribute10             => p_attribute10(i),
    p_attribute11             => p_attribute11(i),
    p_attribute12             => p_attribute12(i),
    p_attribute13             => p_attribute13(i),
    p_attribute14             => p_attribute14(i),
    p_attribute15             => p_attribute15(i),
    p_attribute16             => p_attribute16(i),
    p_attribute17             => p_attribute17(i),
    p_attribute18             => p_attribute18(i),
    p_attribute19             => p_attribute19(i),
    p_attribute20             => p_attribute20(i),
    p_attribute21             => p_attribute21(i),
    p_attribute22             => p_attribute22(i),
    p_attribute23             => p_attribute23(i),
    p_attribute24             => p_attribute24(i),
    p_attribute25             => p_attribute25(i),
    p_attribute26             => p_attribute26(i),
    p_attribute27             => p_attribute27(i),
    p_attribute28             => p_attribute28(i),
    p_attribute29             => p_attribute29(i),
    p_attribute30             => p_attribute30(i),
    p_person_type_code        => p_person_type_code(i),
    p_bom_resource_id         => p_bom_resource_id(i),
    p_bom_resource_name       => p_bom_resource_name(i),
    p_team_role               => p_team_role(i),
    p_incur_by_res_code       => p_incur_by_res_code(i),
    p_incur_by_res_type       => p_incur_by_res_type(i),
    x_resource_list_member_id => x_resource_list_member_id(i),
    x_record_version_number   => x_record_version_number(i),
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_error_msg_data          => x_error_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RETURN;
    END IF;
 END LOOP;

/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
/***************/

END Create_Planning_Resource;

/***************************************************
 * Procedure : Update_Planning_Resource
 * Description : The purpose of this procedure is to
 *               Validate and update attributes on an existing
 *               planning resource for a resource list.
 *               It first checks for the Uniqueness of the
 *               resource list. If it is Unique then it updates
 *               the table PA_RESOURCE_LIST_MEMBERS
 *               with the values passed.
 * Calls Prog : Pa_Planning_Resource_Utils.Get_Plan_Res_Combination
 *              pa_res_list_members_pkg.update_row
 ******************************************************/
PROCEDURE Update_Planning_Resource
       (p_commit                    IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_init_msg_list              IN    VARCHAR2 DEFAULT FND_API.G_FALSE,
       p_resource_list_id           IN    NUMBER,
       p_enabled_flag               IN    VARCHAR2,
       P_planning_resource_in_tbl   IN            Planning_Resource_In_Tbl,
       X_planning_resource_out_tbl  OUT NOCOPY    Planning_Resource_Out_Tbl,
       x_return_status              OUT NOCOPY  VARCHAR2,
       x_msg_count                  OUT NOCOPY  NUMBER,
       x_error_msg_data             OUT NOCOPY  VARCHAR2  )
IS
BEGIN

-- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;

   FOR i IN 1..P_Planning_Resource_In_Tbl.COUNT
   LOOP
      x_msg_count := 0;
      x_return_status :=   FND_API.G_RET_STS_SUCCESS;

   pa_planning_resource_pvt.Update_Planning_Resource(
       p_resource_list_id   => p_resource_list_id,
       p_resource_list_member_id  =>
               p_planning_resource_in_tbl(i).p_resource_list_member_id,
       p_enabled_flag       =>p_enabled_flag,
       p_resource_alias     => P_planning_resource_in_tbl(i).p_resource_alias,
       p_spread_curve_id    => P_planning_resource_in_tbl(i).p_spread_curve_id,
       p_etc_method_code    => P_planning_resource_in_tbl(i).p_etc_method_code,
       p_mfc_cost_type_id   =>
               P_planning_resource_in_tbl(i).p_mfc_cost_type_id,
       p_attribute_category =>
               P_planning_resource_in_tbl(i).p_attribute_category,
       p_attribute1         => P_planning_resource_in_tbl(i).p_attribute1,
       p_attribute2         => P_planning_resource_in_tbl(i).p_attribute2,
       p_attribute3         => P_planning_resource_in_tbl(i).p_attribute3,
       p_attribute4         => P_planning_resource_in_tbl(i).p_attribute4,
       p_attribute5         => P_planning_resource_in_tbl(i).p_attribute5,
       p_attribute6         => P_planning_resource_in_tbl(i).p_attribute6,
       p_attribute7         => P_planning_resource_in_tbl(i).p_attribute7,
       p_attribute8         => P_planning_resource_in_tbl(i).p_attribute8,
       p_attribute9         => P_planning_resource_in_tbl(i).p_attribute9,
       p_attribute10        => P_planning_resource_in_tbl(i).p_attribute10,
       p_attribute11        => P_planning_resource_in_tbl(i).p_attribute11,
       p_attribute12        => P_planning_resource_in_tbl(i).p_attribute12,
       p_attribute13        => P_planning_resource_in_tbl(i).p_attribute13,
       p_attribute14        => P_planning_resource_in_tbl(i).p_attribute14,
       p_attribute15        => P_planning_resource_in_tbl(i).p_attribute15,
       p_attribute16        => P_planning_resource_in_tbl(i).p_attribute16,
       p_attribute17        => P_planning_resource_in_tbl(i).p_attribute17,
       p_attribute18        => P_planning_resource_in_tbl(i).p_attribute18,
       p_attribute19        => P_planning_resource_in_tbl(i).p_attribute19,
       p_attribute20        => P_planning_resource_in_tbl(i).p_attribute20,
       p_attribute21        => P_planning_resource_in_tbl(i).p_attribute21,
       p_attribute22        => P_planning_resource_in_tbl(i).p_attribute22,
       p_attribute23        => P_planning_resource_in_tbl(i).p_attribute23,
       p_attribute24        => P_planning_resource_in_tbl(i).p_attribute24,
       p_attribute25        => P_planning_resource_in_tbl(i).p_attribute25,
       p_attribute26        => P_planning_resource_in_tbl(i).p_attribute26,
       p_attribute27        => P_planning_resource_in_tbl(i).p_attribute27,
       p_attribute28        => P_planning_resource_in_tbl(i).p_attribute28,
       p_attribute29        => P_planning_resource_in_tbl(i).p_attribute29,
       p_attribute30        => P_planning_resource_in_tbl(i).p_attribute30,
       p_record_version_number =>
              p_planning_resource_in_tbl(i).p_record_version_number,
       x_record_version_number    =>
          x_planning_resource_out_tbl(i).x_record_version_number,
       x_return_status      => x_return_status,
       x_msg_count          => x_msg_count  ,
       x_error_msg_data     => x_error_msg_data);

END LOOP;

/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
/***************/
END Update_Planning_Resource;
/************************************/

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
    p_record_version_number  IN    SYSTEM.PA_NUM_TBL_TYPE  ,
    p_commit                 IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    p_init_msg_list          IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
    x_record_version_number  OUT NOCOPY   SYSTEM.PA_NUM_TBL_TYPE  ,
    x_return_status          OUT    NOCOPY   VARCHAR2  ,
    x_msg_count              OUT    NOCOPY   NUMBER    ,
    x_error_msg_data         OUT    NOCOPY   VARCHAR2  )
IS
BEGIN
-- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;
    x_record_version_number := SYSTEM.PA_NUM_TBL_TYPE();
    x_record_version_number.extend(p_resource_list_member_id.count) ;

   /***************************************************************
    * For Loop. To loop through the table of records and
    * Validate each one of them and insert accordingly.
    **************************************************************/

   FOR i IN 1..p_resource_list_member_id.COUNT
   LOOP
      x_msg_count := 0;
      x_return_status :=   FND_API.G_RET_STS_SUCCESS;

Pa_Planning_Resource_Pvt.Update_Planning_Resource
    (p_resource_list_id          =>p_resource_list_id,
    p_resource_list_member_id    =>p_resource_list_member_id(i),
    p_enabled_flag             => p_enabled_flag,
    p_resource_alias           => p_resource_alias(i) ,
    p_spread_curve_id          =>p_spread_curve_id(i),
    p_etc_method_code          =>p_etc_method_code(i),
    p_mfc_cost_type_id         =>p_mfc_cost_type_id(i),
    p_attribute_category       =>p_attribute_category(i),
    p_attribute1               =>p_attribute1(i),
    p_attribute2               =>p_attribute2(i),
    p_attribute3               =>p_attribute3(i),
    p_attribute4               =>p_attribute4(i),
    p_attribute5               =>p_attribute5(i),
    p_attribute6               =>p_attribute6(i),
    p_attribute7               =>p_attribute7(i),
    p_attribute8               =>p_attribute8(i),
    p_attribute9               =>p_attribute9(i),
    p_attribute10              =>p_attribute10(i),
    p_attribute11              =>p_attribute11(i),
    p_attribute12              =>p_attribute12(i),
    p_attribute13              =>p_attribute13(i),
    p_attribute14              =>p_attribute14(i),
    p_attribute15              =>p_attribute15(i),
    p_attribute16              =>p_attribute16(i),
    p_attribute17              =>p_attribute17(i),
    p_attribute18              =>p_attribute18(i),
    p_attribute19              =>p_attribute19(i),
    p_attribute20              =>p_attribute20(i),
    p_attribute21              =>p_attribute21(i),
    p_attribute22              =>p_attribute22(i),
    p_attribute23              =>p_attribute23(i),
    p_attribute24              =>p_attribute24(i),
    p_attribute25              =>p_attribute25(i),
    p_attribute26              =>p_attribute26(i),
    p_attribute27              =>p_attribute27(i),
    p_attribute28              =>p_attribute28(i),
    p_attribute29              =>p_attribute29(i),
    p_attribute30              =>p_attribute30(i),
    p_record_version_number     => p_record_version_number(i),
    x_record_version_number    =>x_record_version_number(i),
    x_return_status            =>x_return_status,
    x_msg_count                => x_msg_count,
    x_error_msg_data           => x_error_msg_data);

END LOOP;

/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
/***************/

END Update_Planning_Resource;

/*************************************************
 * Procedure : Delete_Planning_Resource
 * Description : The purpose of this procedure is to
 *              delete a planning resource if it is not
 *              being used, else disable it.
 *              Further details in the Body.
 * Calls prog : pa_planning_resource_pub.delete_row
 ***************************************************/
PROCEDURE Delete_Planning_Resource(
         p_resource_list_member_id  IN  SYSTEM.PA_NUM_TBL_TYPE,
         p_commit                   IN  VARCHAR2,
         p_init_msg_list            IN  VARCHAR2,
         x_return_status            OUT NOCOPY  VARCHAR2,
         x_msg_count                OUT NOCOPY  NUMBER,
         x_error_msg_data           OUT NOCOPY  VARCHAR2)

IS
BEGIN
   -- First clear the message stack.
   IF FND_API.to_boolean( p_init_msg_list )
   THEN
           FND_MSG_PUB.initialize;
   END IF;
  /********************************************
  * To Check if resource_list member is currently being
  * used in a planning transaction.
  * We are checking from pa_resource_assignments table.
  *************************************************/
FOR i in 1..p_resource_list_member_id.COUNT
LOOP
  pa_planning_resource_pvt.delete_planning_resource
         (p_resource_list_member_id =>p_resource_list_member_id(i),
         x_return_status            =>x_return_status,
         x_msg_count                =>x_msg_count,
         x_error_msg_data           =>x_error_msg_data);


END LOOP;
/************************************************
 * Check the Commit flag. if it is true then Commit.
 ***********************************************/
   IF FND_API.to_boolean( p_commit )
   THEN
          COMMIT;
   END IF;
/***************/
END Delete_Planning_Resource;

END Pa_Planning_Resource_Pub;

/
