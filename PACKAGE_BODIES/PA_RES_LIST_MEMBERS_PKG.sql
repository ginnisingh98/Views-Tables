--------------------------------------------------------
--  DDL for Package Body PA_RES_LIST_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_LIST_MEMBERS_PKG" AS
/* $Header: PAPRESTB.pls 120.0 2005/06/03 13:52:05 appldev noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
  -- g_last_update_login       NUMBER(15) := FND_GLOBAL.LOG_ID;

/*******************************************************
 * Procedure : Insert_Row
 * Description : This procedure is used to take in the parameters
 * passed from pa_planning_resource_pub.create_planning_resource
 * Procedure and Insert into pa_resource_list_members
 * table.
 ***********************************************************/
PROCEDURE Insert_Row
     ( p_resource_list_member_id IN
             pa_resource_list_members.resource_list_member_id%TYPE,
     p_resource_list_id     IN pa_resource_list_members.resource_list_id%TYPE,
     p_resource_id          IN pa_resource_list_members.resource_id%TYPE,
     p_resource_alias       IN pa_resource_list_members.alias%TYPE,
     p_person_id            IN pa_resource_list_members.person_id%TYPE,
     p_job_id               IN pa_resource_list_members.job_id%TYPE  ,
     p_organization_id      IN pa_resource_list_members.organization_id%TYPE  ,
     p_vendor_id            IN pa_resource_list_members.vendor_id%TYPE  ,
     p_expenditure_type     IN pa_resource_list_members.expenditure_type%TYPE  ,
     p_event_type           IN pa_resource_list_members.event_type%TYPE  ,
     p_non_labor_resource   IN
              pa_resource_list_members.non_labor_resource%TYPE,
     p_expenditure_category IN
                         pa_resource_list_members.expenditure_category%TYPE,
     p_revenue_category     IN pa_resource_list_members.revenue_category%TYPE  ,
     p_role_id              IN
                         pa_resource_list_members.project_role_id%TYPE  ,
     p_resource_class_id    IN pa_resource_list_members.resource_class_id%TYPE ,
     p_res_class_code       IN
                        pa_resource_list_members.resource_class_code%TYPE,
     p_res_format_id        IN  NUMBER ,
     p_spread_curve_id      IN  pa_resource_list_members.spread_curve_id%TYPE ,
     p_etc_method_code      IN  pa_resource_list_members.etc_method_code%TYPE ,
     p_mfc_cost_type_id     IN  pa_resource_list_members.mfc_cost_type_id%TYPE ,
     p_res_class_flag       IN
            pa_resource_list_members.resource_class_flag%TYPE ,
     p_fc_res_type_code     IN  pa_resource_list_members.fc_res_type_code%TYPE ,
     p_inventory_item_id    IN  pa_resource_list_members.inventory_item_id%TYPE ,
     p_item_category_id     IN  pa_resource_list_members.item_category_id%TYPE,
     p_attribute_category   IN pa_resource_list_members.attribute_category%TYPE,
     p_attribute1           IN pa_resource_list_members.attribute1%TYPE,
     p_attribute2           IN pa_resource_list_members.attribute2%TYPE,
     p_attribute3           IN pa_resource_list_members.attribute3%TYPE,
     p_attribute4           IN pa_resource_list_members.attribute4%TYPE,
     p_attribute5           IN pa_resource_list_members.attribute5%TYPE,
     p_attribute6           IN pa_resource_list_members.attribute6%TYPE,
     p_attribute7           IN pa_resource_list_members.attribute7%TYPE,
     p_attribute8           IN pa_resource_list_members.attribute8%TYPE,
     p_attribute9           IN pa_resource_list_members.attribute9%TYPE,
     p_attribute10          IN pa_resource_list_members.attribute10%TYPE,
     p_attribute11          IN pa_resource_list_members.attribute11%TYPE,
     p_attribute12          IN pa_resource_list_members.attribute12%TYPE,
     p_attribute13          IN pa_resource_list_members.attribute13%TYPE,
     p_attribute14          IN pa_resource_list_members.attribute14%TYPE,
     p_attribute15          IN pa_resource_list_members.attribute15%TYPE,
     p_attribute16          IN pa_resource_list_members.attribute16%TYPE,
     p_attribute17          IN pa_resource_list_members.attribute17%TYPE,
     p_attribute18          IN pa_resource_list_members.attribute18%TYPE,
     p_attribute19          IN pa_resource_list_members.attribute19%TYPE,
     p_attribute20          IN pa_resource_list_members.attribute20%TYPE,
     p_attribute21          IN pa_resource_list_members.attribute21%TYPE,
     p_attribute22          IN pa_resource_list_members.attribute22%TYPE,
     p_attribute23          IN pa_resource_list_members.attribute23%TYPE,
     p_attribute24          IN pa_resource_list_members.attribute24%TYPE,
     p_attribute25          IN pa_resource_list_members.attribute25%TYPE,
     p_attribute26          IN pa_resource_list_members.attribute26%TYPE,
     p_attribute27          IN pa_resource_list_members.attribute27%TYPE,
     p_attribute28          IN pa_resource_list_members.attribute28%TYPE,
     p_attribute29          IN pa_resource_list_members.attribute29%TYPE,
     p_attribute30          IN pa_resource_list_members.attribute30%TYPE,
     p_person_type_code     IN pa_resource_list_members.person_type_code%TYPE,
     p_bom_resource_id      IN pa_resource_list_members.bom_resource_id%TYPE,
     p_team_role            IN pa_resource_list_members.team_role%TYPE,
     p_incur_by_res_flag    IN
                    pa_resource_list_members.incurred_by_res_flag%TYPE,
     p_incur_by_res_class_code   IN
                    pa_resource_list_members.incur_by_res_class_code%TYPE,
     p_incur_by_role_id     IN pa_resource_list_members.incur_by_role_id%TYPE,
     p_object_type          IN pa_resource_list_members.object_type%TYPE,
     p_object_id            IN pa_resource_list_members.object_id%TYPE,
     p_wp_eligible_flag      IN pa_resource_list_members.wp_eligible_flag%TYPE,
     p_unit_of_measure      IN pa_resource_list_members.unit_of_measure%TYPE,
     x_msg_count            IN OUT NOCOPY  NUMBER,
     x_return_status        OUT    NOCOPY  VARCHAR2,
     x_error_msg_data       OUT    NOCOPY  VARCHAR2 )
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     INSERT INTO PA_RESOURCE_LIST_MEMBERS(
        RESOURCE_LIST_MEMBER_ID,
        RESOURCE_LIST_ID,
        RESOURCE_ID,
        ALIAS,
        DISPLAY_FLAG,
        ENABLED_FLAG,
        TRACK_AS_LABOR_FLAG,
        PERSON_ID,
        JOB_ID,
        ORGANIZATION_ID,
        VENDOR_ID,
        EXPENDITURE_TYPE,
        EVENT_TYPE,
        NON_LABOR_RESOURCE,
        EXPENDITURE_CATEGORY,
        REVENUE_CATEGORY,
        PROJECT_ROLE_ID,
        OBJECT_TYPE,
        OBJECT_ID,
        RESOURCE_CLASS_ID,
        RESOURCE_CLASS_CODE,
        RES_FORMAT_ID,
        SPREAD_CURVE_ID,
        ETC_METHOD_CODE,
        MFC_COST_TYPE_ID,
        COPY_FROM_RL_FLAG,
        RESOURCE_CLASS_FLAG,
        FC_RES_TYPE_CODE,
        INVENTORY_ITEM_ID,
        ITEM_CATEGORY_ID,
        MIGRATION_CODE,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3  ,
        ATTRIBUTE4  ,
         ATTRIBUTE5  ,
        ATTRIBUTE6   ,
        ATTRIBUTE7   ,
        ATTRIBUTE8   ,
        ATTRIBUTE9   ,
        ATTRIBUTE10  ,
        ATTRIBUTE11  ,
        ATTRIBUTE12  ,
        ATTRIBUTE13  ,
        ATTRIBUTE14  ,
        ATTRIBUTE15  ,
        ATTRIBUTE16  ,
        ATTRIBUTE17   ,
        ATTRIBUTE18  ,
        ATTRIBUTE19 ,
        ATTRIBUTE20   ,
        ATTRIBUTE21   ,
        ATTRIBUTE22   ,
        ATTRIBUTE23   ,
        ATTRIBUTE24   ,
        ATTRIBUTE25   ,
        ATTRIBUTE26     ,
        ATTRIBUTE27    ,
        ATTRIBUTE28   ,
        ATTRIBUTE29  ,
        ATTRIBUTE30 ,
        RECORD_VERSION_NUMBER,
        PERSON_TYPE_CODE,
        BOM_RESOURCE_ID,
        TEAM_ROLE,
        INCURRED_BY_RES_FLAG,
        INCUR_BY_RES_CLASS_CODE,
        INCUR_BY_ROLE_ID,
        WP_ELIGIBLE_FLAG,
        UNIT_OF_MEASURE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        CREATION_DATE,
        CREATED_BY,
        LAST_UPDATE_LOGIN)
   VALUES
        (p_resource_list_member_id,
         p_resource_list_id,
         nvl(p_resource_id, -99),
         p_resource_alias,
         'Y',
         'Y',
         NULL,
         p_person_id,
         p_job_id               ,
         p_organization_id      ,
         p_vendor_id            ,
         p_expenditure_type     ,
         p_event_type           ,
         p_non_labor_resource   ,
         p_expenditure_category ,
         p_revenue_category     ,
         p_role_id              ,
         p_object_type        ,
         p_object_id     ,
         p_resource_class_id    ,
         p_res_class_code       ,
         p_res_format_id        ,
         p_spread_curve_id      ,
         p_etc_method_code      ,
         p_mfc_cost_type_id     ,
         'N'                    ,
         p_res_class_flag       ,
         p_fc_res_type_code     ,
         p_inventory_item_id    ,
         p_item_category_id     ,
         'N'                    ,
         p_attribute_category   ,
         p_attribute1           ,
         p_attribute2           ,
         p_attribute3           ,
         p_attribute4           ,
         p_attribute5           ,
         p_attribute6           ,
         p_attribute7           ,
         p_attribute8           ,
         p_attribute9           ,
         p_attribute10          ,
         p_attribute11          ,
         p_attribute12          ,
         p_attribute13          ,
         p_attribute14          ,
         p_attribute15          ,
         p_attribute16          ,
         p_attribute17          ,
         p_attribute18          ,
         p_attribute19          ,
         p_attribute20          ,
         p_attribute21          ,
         p_attribute22          ,
         p_attribute23          ,
         p_attribute24          ,
         p_attribute25          ,
         p_attribute26          ,
         p_attribute27          ,
         p_attribute28          ,
         p_attribute29          ,
         p_attribute30          ,
         1,
         p_person_type_code,
         p_bom_resource_id,
         p_team_role,
         nvl(p_incur_by_res_flag, 'N'),
         p_incur_by_res_class_code,
         p_incur_by_role_id,
         p_wp_eligible_flag,
         p_unit_of_measure,
         FND_GLOBAL.USER_ID,
         Sysdate,
         Sysdate,
         FND_GLOBAL.USER_ID,
         FND_GLOBAL.LOGIN_ID);
EXCEPTION
WHEN OTHERS THEN
       x_return_status :=  FND_API.G_RET_STS_UNEXP_ERROR;
       x_msg_count := x_msg_count + 1;
       RETURN;
END Insert_Row;
/*************************************************/

/*******************************************************
 * Procedure : Update_Row
 * Description : This procedure is used to take in the parameters
 * passed from pa_planning_resource_pub.update_planning_resource
 * Procedure and Update the pa_resource_list_members
 * table.
 ***********************************************************/
PROCEDURE Update_Row
     (p_alias             IN VARCHAR2,
     p_enabled_flag       IN VARCHAR2,
     p_resource_list_member_id IN
                     pa_resource_list_members.resource_list_member_id%TYPE,
     p_spread_curve_id    IN pa_resource_list_members.spread_curve_id%TYPE,
     p_etc_method_code    IN pa_resource_list_members.etc_method_code%TYPE,
     p_mfc_cost_type_id   IN pa_resource_list_members.MFC_COST_TYPE_ID%TYPE ,
     p_attribute_category IN pa_resource_list_members.attribute_category%TYPE,
     p_attribute1         IN pa_resource_list_members.attribute1%TYPE,
     p_attribute2         IN pa_resource_list_members.attribute2%TYPE,
     p_attribute3         IN pa_resource_list_members.attribute3%TYPE,
     p_attribute4         IN pa_resource_list_members.attribute4%TYPE,
     p_attribute5         IN pa_resource_list_members.attribute5%TYPE,
     p_attribute6         IN pa_resource_list_members.attribute6%TYPE,
     p_attribute7         IN pa_resource_list_members.attribute7%TYPE,
     p_attribute8         IN pa_resource_list_members.attribute8%TYPE,
     p_attribute9         IN pa_resource_list_members.attribute9%TYPE,
     p_attribute10        IN pa_resource_list_members.attribute10%TYPE,
     p_attribute11        IN pa_resource_list_members.attribute11%TYPE,
     p_attribute12        IN pa_resource_list_members.attribute12%TYPE,
     p_attribute13        IN pa_resource_list_members.attribute13%TYPE,
     p_attribute14        IN pa_resource_list_members.attribute14%TYPE,
     p_attribute15        IN pa_resource_list_members.attribute15%TYPE,
     p_attribute16        IN pa_resource_list_members.attribute16%TYPE,
     p_attribute17        IN pa_resource_list_members.attribute17%TYPE,
     p_attribute18        IN pa_resource_list_members.attribute18%TYPE,
     p_attribute19        IN pa_resource_list_members.attribute19%TYPE,
     p_attribute20        IN pa_resource_list_members.attribute20%TYPE,
     p_attribute21        IN pa_resource_list_members.attribute21%TYPE,
     p_attribute22        IN pa_resource_list_members.attribute22%TYPE,
     p_attribute23        IN pa_resource_list_members.attribute23%TYPE,
     p_attribute24        IN pa_resource_list_members.attribute24%TYPE,
     p_attribute25        IN pa_resource_list_members.attribute25%TYPE,
     p_attribute26        IN pa_resource_list_members.attribute26%TYPE,
     p_attribute27        IN pa_resource_list_members.attribute27%TYPE,
     p_attribute28        IN pa_resource_list_members.attribute28%TYPE,
     p_attribute29        IN pa_resource_list_members.attribute29%TYPE,
     p_attribute30        IN pa_resource_list_members.attribute30%TYPE,
     p_record_version_number IN
                        pa_resource_list_members.RECORD_VERSION_NUMBER%TYPE,
     x_msg_count          IN OUT NOCOPY NUMBER,
     x_return_status      OUT    NOCOPY VARCHAR2,
     x_error_msg_data     OUT    NOCOPY VARCHAR2)
IS
    l_mfc_cost_type_id    Number;
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    /*****************************************************************
     * Bug - 3571205
     * Desc - For MFC Cost Type ID, We need to do an extra chedck to
     *        determine if the user has explicitely Nulled out the
     *        field or not. This can be determined by checking the
     *        FND_API.G_MISS_NUM field. If the user wants to explicitely
     *        Null out the field then he should pass FND_API.G_MISS_NUM
     *        to the p_mfc_cost_type_id parameter.
     *****************************************************************/
    IF p_mfc_cost_type_id IS NOT NULL AND p_mfc_cost_type_id <> FND_API.G_MISS_NUM THEN
        l_mfc_cost_type_id := p_mfc_cost_type_id;
    END IF;

    IF p_mfc_cost_type_id IS NULL THEN
        BEGIN
           SELECT mfc_cost_type_id
           INTO l_mfc_cost_type_id
           FROM pa_resource_list_members
           WHERE resource_list_member_id = p_resource_list_member_id;
        EXCEPTION
        WHEN OTHERS THEN
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           Return;
        END;
    END IF;

    IF p_mfc_cost_type_id = FND_API.G_MISS_NUM THEN
         l_mfc_cost_type_id := Null;
    END IF;
    /************************************************************
    * Bug         : 3494646
    * Description : When a user disables a planning resource, the
    *               attributes should not be removed.
    *               Therefore if the values for most of the attributes
    *               like spread_curve_id, etc_method_code,
    *               mfc_cost_type_id, attribute_category,
    *               attribute1 etc are passed in as Null then we just
    *               default it with the value that was originally present
    *               in the DB.
    *****************************************************************/
    UPDATE PA_RESOURCE_LIST_MEMBERS
      SET alias              = p_alias,
          enabled_flag       = p_enabled_flag,
          spread_curve_id    = nvl(p_spread_curve_id,spread_curve_id),
          etc_method_code    = nvl(p_etc_method_code,etc_method_code),
          mfc_cost_type_id   = l_mfc_cost_type_id,
          attribute_category = nvl(p_attribute_category,attribute_category),
          attribute1         = nvl(p_attribute1,attribute1),
          attribute2         = nvl(p_attribute2,attribute2),
          attribute3         = nvl(p_attribute3,attribute3),
          attribute4         = nvl(p_attribute4,attribute4),
          attribute5         = nvl(p_attribute5,attribute5),
          attribute6         = nvl(p_attribute6,attribute6),
          attribute7         = nvl(p_attribute7,attribute7),
          attribute8         = nvl(p_attribute8,attribute8),
          attribute9         = nvl(p_attribute9,attribute9),
          attribute10        = nvl(p_attribute10,attribute10),
          attribute11        = nvl(p_attribute11,attribute11),
          attribute12        = nvl(p_attribute12,attribute12),
          attribute13        = nvl(p_attribute13,attribute13),
          attribute14        = nvl(p_attribute14,attribute14),
          attribute15        = nvl(p_attribute15,attribute15),
          attribute16        = nvl(p_attribute16,attribute16),
          attribute17        = nvl(p_attribute17,attribute17),
          attribute18        = nvl(p_attribute18,attribute18),
          attribute19        = nvl(p_attribute19,attribute19),
          attribute20        = nvl(p_attribute20,attribute20),
          attribute21        = nvl(p_attribute21,attribute21),
          attribute22        = nvl(p_attribute22,attribute22),
          attribute23        = nvl(p_attribute23,attribute23),
          attribute24        = nvl(p_attribute24,attribute24),
          attribute25        = nvl(p_attribute25,attribute25),
          attribute26        = nvl(p_attribute26,attribute26),
          attribute27        = nvl(p_attribute27,attribute27),
          attribute28        = nvl(p_attribute28,attribute28),
          attribute29        = nvl(p_attribute29,attribute29),
          attribute30        = nvl(p_attribute30,attribute30),
          record_version_number = nvl(RECORD_VERSION_NUMBER,0) + 1,
          last_update_date   = sysdate
     WHERE resource_list_member_id =
                  p_resource_list_member_id
     AND  nvl(record_version_number, 0) =
         nvl(p_record_version_number, 0);

   IF (SQL%NOTFOUND) THEN
   /************************************************
   * If we couldn't find a matching record for Updation.
   ***************************************************/
         PA_UTILS.Add_message(p_app_short_name => 'PA'
                    ,p_msg_name => 'PA_XC_RECORD_CHANGED');
         x_msg_count :=
                    x_msg_count + 1;
         x_return_status :=
                    FND_API.G_RET_STS_ERROR;
         x_error_msg_data :=
                    'PA_XC_RECORD_CHANGED';
         RETURN;
   END IF;
END Update_Row;
/********************************************/

/*******************************************************
 * Procedure : Delete_Row
 * Description : This procedure is used to take in the parameters
 * passed from pa_planning_resource_pub.delete_planning_resource
 * Procedure and delete from the pa_resource_list_members
 * table.
 ***********************************************************/
PROCEDURE Delete_Row
(p_resource_list_member_id  IN            VARCHAR2,
 p_exist_res_list           IN            VARCHAR2,
 x_msg_count                IN OUT NOCOPY VARCHAR2,
 x_return_status            OUT    NOCOPY VARCHAR2)
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF p_exist_res_list = 'Y' THEN
    /*************************************************
    * If 'Y' is returned from the above select, then
    * we cannot Delete the resource list member. So
    * we are just disabling it by setting the enabled flag = 'N'.
    **************************************************/
      BEGIN
             UPDATE pa_resource_list_members
             SET enabled_flag = 'N',
                 last_update_date = sysdate,
                 record_version_number = nvl(record_version_number,0) + 1
             WHERE resource_list_member_id = p_resource_list_member_id;
          EXCEPTION
          WHEN OTHERS THEN
             FND_MSG_PUB.add_exc_msg( p_pkg_name =>
             'pa_create_resource_pub.delete_planning_resource'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
             x_msg_count := x_msg_count+1;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      END;
  ELSE
   /****************************************************
   * If 'N' is returned from the above select. Then it means no
   * CHILD recs existing, so we can go ahead and delete from
   * pa_resource_list_members table.
   ********************************************************/
    BEGIN
       DELETE FROM pa_resource_list_members
       WHERE resource_list_member_id = p_resource_list_member_id;
    EXCEPTION
    WHEN OTHERS THEN
              FND_MSG_PUB.add_exc_msg( p_pkg_name =>
             'pa_create_resource_pub.delete_planning_resource'
             ,p_procedure_name => PA_DEBUG.G_Err_Stack);
             x_msg_count := x_msg_count+1;
             x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END;
   END IF;

END Delete_Row;
/***************************/

END Pa_Res_List_Members_Pkg;
/**************************************/

/
