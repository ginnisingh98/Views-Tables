--------------------------------------------------------
--  DDL for Package PA_CREATE_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CREATE_RESOURCE" AUTHID CURRENT_USER AS
/* $Header: PACRRESS.pls 120.1 2005/08/19 16:21:00 mwasowic noship $*/

   -- Standard who
   g_last_updated_by         NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_date        DATE       := SYSDATE;
   g_creation_date           DATE       := SYSDATE;
   g_created_by              NUMBER(15) := FND_GLOBAL.USER_ID;
   g_last_update_login       NUMBER(15) := FND_GLOBAL.LOGIN_ID;

  PROCEDURE Create_Resource_group
                                (p_resource_list_id        IN  NUMBER,
                                 p_resource_group          IN  VARCHAR2,
                                 p_resource_name           IN  VARCHAR2,
                                 p_alias                   IN  VARCHAR2,
                                 p_sort_order              IN  NUMBER,
                                 p_display_flag            IN  VARCHAR2,
                                 p_enabled_flag            IN  VARCHAR2,
                                 p_track_as_labor_flag     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 p_resource_id             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_code                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 p_err_stack            IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE Create_Resource_List
              (p_resource_list_name  IN  VARCHAR2,
               p_description         IN  VARCHAR2,
               p_public_flag         IN  VARCHAR2 DEFAULT 'Y',
               p_group_resource_type IN  VARCHAR2,
               p_start_date          IN  DATE DEFAULT SYSDATE,
               p_end_date            IN  DATE DEFAULT NULL,
               p_business_group_id   IN  NUMBER DEFAULT NULL,
               p_job_group_id        IN  NUMBER,  -- Added for bug 2486405.
               p_job_group_name      IN  VARCHAR2 DEFAULT NULL,
               p_use_for_wp_flag     IN  VARCHAR2 DEFAULT NULL,
	       p_control_flag        IN  VARCHAR2 DEFAULT NULL,
               p_migration_code      IN  VARCHAR2 DEFAULT NULL,
               p_record_version_number IN NUMBER DEFAULT NULL,
               p_resource_list_id    OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
               p_err_code            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
               p_err_stage        IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
               p_err_stack        IN OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE Update_Resource_List
              (p_resource_list_name  IN  VARCHAR2 DEFAULT NULL,
               p_description         IN  VARCHAR2 DEFAULT NULL,
               p_start_date          IN  DATE DEFAULT NULL,
               p_end_date            IN  DATE DEFAULT NULL,
               p_job_group_id        IN OUT NOCOPY NUMBER,
               p_job_group_name      IN  VARCHAR2 DEFAULT NULL,
               p_use_for_wp_flag     IN  VARCHAR2 DEFAULT NULL,
               p_control_flag        IN  VARCHAR2 DEFAULT NULL,
               p_migration_code      IN  VARCHAR2 DEFAULT NULL,
               p_record_version_number IN OUT NOCOPY NUMBER,
               p_resource_list_id    IN  NUMBER,
               x_msg_count           OUT NOCOPY  NUMBER,
               x_return_status       OUT NOCOPY  VARCHAR2,
               x_msg_data            OUT NOCOPY  VARCHAR2);

  PROCEDURE Create_Resource_txn_Attribute
                          ( p_resource_id                 IN  NUMBER,
                            p_resource_type_Code          IN  VARCHAR2,
                            p_person_id                   IN  NUMBER,
                            p_job_id                      IN  NUMBER,
                            p_proj_organization_id        IN  NUMBER,
                            p_vendor_id                   IN  NUMBER,
                            p_expenditure_type            IN  VARCHAR2,
                            p_event_type                  IN  VARCHAR2,
                            p_expenditure_category        IN  VARCHAR2,
                            p_revenue_category_code       IN  VARCHAR2,
                            p_non_labor_resource          IN  VARCHAR2,
                            p_system_linkage              IN  VARCHAR2,
                            p_project_role_id             IN  NUMBER DEFAULT NULL,
                            p_resource_txn_attribute_id   OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            p_err_code                    OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            p_err_stage                IN OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            p_err_stack                IN OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   PROCEDURE Create_Resource_list_member
                         (p_resource_list_id          IN  NUMBER,
                          p_resource_name             IN  VARCHAR2,
                          p_resource_type_Code        IN  VARCHAR2,
                          p_alias                     IN  VARCHAR2,
                          p_sort_order                IN  NUMBER,
                          p_display_flag              IN  VARCHAR2,
                          p_enabled_flag              IN  VARCHAR2,
                          p_person_id                 IN  NUMBER,
                          p_job_id                    IN  NUMBER,
                          p_proj_organization_id      IN  NUMBER,
                          p_vendor_id                 IN  NUMBER,
                          p_expenditure_type          IN  VARCHAR2,
                          p_event_type                IN  VARCHAR2,
                          p_expenditure_category      IN  VARCHAR2,
                          p_revenue_category_code     IN  VARCHAR2,
                          p_non_labor_resource        IN  VARCHAR2,
                          p_system_linkage            IN  VARCHAR2,
                          p_project_role_id           IN  NUMBER  DEFAULT NULL,
			  p_job_group_id              IN  NUMBER  DEFAULT NULL,         --- Added for Bug 2486405.
                          p_parent_member_id         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_resource_list_member_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_track_as_labor_flag     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_err_code                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_err_stack            IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

      PROCEDURE Create_Resource (p_resource_name             IN  VARCHAR2,
                                 p_resource_type_Code        IN  VARCHAR2,
                                 p_description               IN  VARCHAR2,
                                 p_unit_of_measure           IN  VARCHAR2,
                                 p_rollup_quantity_flag      IN  VARCHAR2,
                                 p_track_as_labor_flag       IN  VARCHAR2,
                                 p_start_date                IN  DATE,
                                 p_end_date                  IN  DATE,
                                 p_person_id                 IN  NUMBER,
                                 p_job_id                    IN  NUMBER,
                                 p_proj_organization_id      IN  NUMBER,
                                 p_vendor_id                 IN  NUMBER,
                                 p_expenditure_type          IN  VARCHAR2,
                                 p_event_type                IN  VARCHAR2,
                                 p_expenditure_category      IN  VARCHAR2,
                                 p_revenue_category_code     IN  VARCHAR2,
                                 p_non_labor_resource        IN  VARCHAR2,
                                 p_system_linkage            IN  VARCHAR2,
                                 p_project_role_id           IN  NUMBER DEFAULT NULL,
                                 p_resource_id              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_code                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 p_err_stage            IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 p_err_stack            IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

       PROCEDURE Add_Resouce_List_Member
                         (p_resource_list_id          IN  NUMBER,
                          p_resource_name             IN  VARCHAR2,
                          p_resource_type_Code        IN  VARCHAR2,
                          p_alias                     IN  VARCHAR2,
                          p_sort_order                IN  NUMBER,
                          p_display_flag              IN  VARCHAR2,
                          p_enabled_flag              IN  VARCHAR2,
                          p_person_id                 IN  NUMBER,
                          p_job_id                    IN  NUMBER,
                          p_proj_organization_id      IN  NUMBER,
                          p_vendor_id                 IN  NUMBER,
                          p_expenditure_type          IN  VARCHAR2,
                          p_event_type                IN  VARCHAR2,
                          p_expenditure_category      IN  VARCHAR2,
                          p_revenue_category_code     IN  VARCHAR2,
                          p_non_labor_resource        IN  VARCHAR2,
                          p_system_linkage            IN  VARCHAR2,
                          p_parent_member_id          IN  NUMBER,
                          p_project_role_id           IN  NUMBER DEFAULT NULL,
                          p_track_as_labor_flag      OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_resource_id              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_resource_list_member_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_err_code                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          p_err_stage             IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          p_err_stack             IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE Create_Default_Res_List ( X_business_group_id   IN NUMBER
                                    , X_err_code            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                                    , X_err_stage           IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                    , X_err_stack           IN OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

  PROCEDURE Delete_Plan_Res_List (p_resource_list_id   IN  NUMBER,
                                  x_return_status      OUT NOCOPY VARCHAR2,
                                  x_msg_count          OUT NOCOPY NUMBER,
                                  x_msg_data           OUT NOCOPY VARCHAR2);

/*************************************************************
 * Function    : Check_pl_alias_unique
 * Description : The purpose of this function is to determine
 *               the uniqueness of the resource alias if it is not null.
 *               Further details are specified in the Body.
 *************************************************************/

   FUNCTION Check_pl_alias_unique(
                        p_resource_list_id      IN VARCHAR2,
                        p_resource_alias        IN VARCHAR2,
                        p_resource_list_member_id IN VARCHAR2)
   RETURN VARCHAR2;

   PROCEDURE Add_language;

/*******************************************************
 * Procedure : Create_Proj_Resource_List
 * Description : This procedure is used to create resource
 *               list members, whenever we create a project
 *               specific resource list(ie when a resource
 *               list is associated to a project).
 *               We are copying the resource members
 *               from the existing members for the same
 *               resource list.
 ******************************************************/
   PROCEDURE Create_Proj_Resource_List
            (p_resource_list_id   IN VARCHAR2,
             p_project_id         IN NUMBER,
             x_return_status      OUT NOCOPY     VARCHAR2,
             x_error_msg_data     OUT NOCOPY     Varchar2,
             x_msg_count          OUT NOCOPY     Number);



/* Procedure to create a resource list and copy all its elements from the selected parent resource list id*/
/* Added by smullapp */

PROCEDURE COPY_RESOURCE_LIST(
			P_Commit             		IN Varchar2 Default Fnd_Api.G_False,
        		P_Init_Msg_List      		IN Varchar2 Default Fnd_Api.G_True,
        		P_API_Version_Number 		IN Number,
                        p_parent_resource_list_id       IN PA_RESOURCE_LISTS_ALL_BG.resource_list_id%TYPE,
			p_name                          IN PA_RESOURCE_LISTS_ALL_BG.name%TYPE,
                        p_description                   IN PA_RESOURCE_LISTS_ALL_BG.description%TYPE,
                        p_start_date_active             IN PA_RESOURCE_LISTS_ALL_BG.START_DATE_ACTIVE%TYPE,
                        p_END_DATE_ACTIVE               IN PA_RESOURCE_LISTS_ALL_BG.END_DATE_ACTIVE%TYPE,
                        p_JOB_GROUP_ID                  IN PA_RESOURCE_LISTS_ALL_BG.JOB_GROUP_ID%TYPE,
                        p_CONTROL_FLAG                  IN PA_RESOURCE_LISTS_ALL_BG.CONTROL_FLAG%TYPE,
                        p_USE_FOR_WP_FLAG               IN PA_RESOURCE_LISTS_ALL_BG.USE_FOR_WP_FLAG%TYPE,
                        x_return_status         	OUT NOCOPY	Varchar2,
                        x_msg_data              	OUT NOCOPY	Varchar2,
                        x_msg_count             	OUT NOCOPY	NUMBER
                );


/******************************************************
 * Procedure : Copy_Resource_Lists
 * Description : This API is used to copy all the
 *               Resource list members for the resource_list_id's
 *               associated to the source project -->
 *               into the destination project.
 *               Further details in the body.
 * **************************************************/
 PROCEDURE Copy_Resource_Lists
       (p_source_project_id        IN  Number,
        p_destination_project_id   IN  Number,
        x_return_status            OUT NOCOPY Varchar2);


/******************************************************
 * Procedure : TRANSLATE_ROW
 * Description : This API is used to tranlslate all
 *               translatable colmuns os pa_resource_lits_tl
 *               table. This is called from the lct file.
 * **************************************************/
procedure TRANSLATE_ROW(
  P_RESOURCE_LIST_ID            in NUMBER   ,
  P_OWNER                       in VARCHAR2 ,
  P_NAME                        in VARCHAR2 ,
  P_DESCRIPTION                 in VARCHAR2
                      );

/******************************************************
 * Procedure : LOAD_ROW
 * Description : This API is used to update or insert rows
 *               into table pa_resource_lists_bg and
 *               pa_resource_lits_tl table. This procedure
 *               is called from the lct file.
 * **************************************************/
procedure LOAD_ROW(
  P_RESOURCE_LIST_ID               in NUMBER,
  P_NAME                           in VARCHAR2,
  P_DESCRIPTION                    in VARCHAR2,
  P_PUBLIC_FLAG                    in VARCHAR2,
  P_GROUP_RESOURCE_TYPE_ID         in NUMBER,
  P_START_DATE_ACTIVE              in DATE,
  P_END_DATE_ACTIVE                in DATE,
  P_UNCATEGORIZED_FLAG             in VARCHAR2,
  P_BUSINESS_GROUP_ID              in NUMBER,
  P_JOB_GROUP_ID                   in NUMBER,
  P_RESOURCE_LIST_TYPE             in VARCHAR2,
  P_OWNER                          in VARCHAR2
);

END PA_CREATE_RESOURCE;

 

/
