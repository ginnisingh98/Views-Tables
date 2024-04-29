--------------------------------------------------------
--  DDL for Package PA_RES_LIST_MEMBERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RES_LIST_MEMBERS_PKG" AUTHID CURRENT_USER AS
/* $Header: PAPRESTS.pls 120.0 2005/05/30 20:02:52 appldev noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
  -- g_last_update_login       NUMBER(15) := FND_GLOBAL.LOG_ID;

/******************************************************
 * Procedure   : Insert_Row
 * Description : This procedure is used to take in parameters
 *               passed from the
 *               pa_planning_resource_pub.create_planning_resource
 *               procedure and insert into the pa_resource_list_members
 *               table.
 ****************************************************/
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
     p_non_labor_resource   IN pa_resource_list_members.non_labor_resource%TYPE  ,
     p_expenditure_category IN
                         pa_resource_list_members.expenditure_category%TYPE,
     p_revenue_category     IN pa_resource_list_members.revenue_category%TYPE  ,
     p_role_id              IN
                         pa_resource_list_members.project_role_id%TYPE  ,
     p_resource_class_id    IN  pa_resource_list_members.resource_class_id%TYPE   ,
     p_res_class_code       IN  pa_resource_list_members.resource_class_code%TYPE,
     p_res_format_id        IN  NUMBER ,
     p_spread_curve_id      IN  pa_resource_list_members.spread_curve_id%TYPE ,
     p_etc_method_code      IN  pa_resource_list_members.etc_method_code%TYPE ,
     p_mfc_cost_type_id     IN  pa_resource_list_members.mfc_cost_type_id%TYPE ,
     p_res_class_flag       IN  pa_resource_list_members.resource_class_flag%TYPE ,
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
     p_wp_eligible_flag     IN pa_resource_list_members.wp_eligible_flag%TYPE,
     p_unit_of_measure      IN pa_resource_list_members.unit_of_measure%TYPE,
     x_msg_count            IN OUT NOCOPY  NUMBER,
     x_return_status        OUT NOCOPY     VARCHAR2,
     x_error_msg_data       OUT NOCOPY     VARCHAR2 ) ;

/******************************************************
 * Procedure   : Update_Row
 * Description : This procedure is used to take in parameters
 *               passed from the
 *               pa_planning_resource_pub.update_planning_resource
 *               procedure and update the pa_resource_list_members
 *               table.
 ****************************************************/
PROCEDURE UPDATE_ROW
    (p_alias              IN VARCHAR2,
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
     x_msg_count          IN OUT NOCOPY  NUMBER,
     x_return_status      OUT NOCOPY     VARCHAR2,
     x_error_msg_data     OUT NOCOPY     VARCHAR2 )
;

/******************************************************
 * Procedure   : Delete_Row
 * Description : This procedure is used to take in parameters
 *               passed from the
 *               pa_planning_resource_pub.update_planning_resource
 *               procedure and update the pa_resource_list_members
 *               table.
 ****************************************************/
PROCEDURE DELETE_ROW
(p_resource_list_member_id  IN            VARCHAR2,
 p_exist_res_list           IN            VARCHAR2,
 x_msg_count                IN OUT NOCOPY VARCHAR2,
 x_return_status            OUT NOCOPY    VARCHAR2);

END Pa_Res_List_Members_Pkg;

 

/
