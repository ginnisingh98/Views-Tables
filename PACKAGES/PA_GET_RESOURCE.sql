--------------------------------------------------------
--  DDL for Package PA_GET_RESOURCE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_GET_RESOURCE" AUTHID CURRENT_USER AS
/* $Header: PAGTRESS.pls 120.1 2005/08/19 16:33:32 mwasowic noship $*/

G_include_inactive_res_flag   VARCHAR2(1) := 'N';


   Procedure Get_Resource_group (p_resource_list_id        In  Number,
                                 p_resource_group          In  Varchar2,
                                 p_resource_list_member_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 p_resource_id             Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 p_track_as_labor_flag     Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 p_err_code                Out NOCOPY Number, --File.Sql.39 bug 4440895
                                 p_err_stage            In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                 p_err_stack            In Out NOCOPY Varchar2); --File.Sql.39 bug 4440895

   Procedure Get_Resource_list_member (p_resource_list_id        In  Number,
                                       p_resource_name           In  Varchar2,
                                       p_resource_type_Code      In  Varchar2,
                                       p_group_resource_type_id  In  Number,
                                       p_person_id               In  Number,
                                       p_job_id                  In  Number,
                                       p_proj_organization_id    In  Number,
                                       p_vendor_id               In  Number,
                                       p_expenditure_type        In  Varchar2,
                                       p_event_type              In  Varchar2,
                                       p_expenditure_category    In  Varchar2,
                                       p_revenue_category_code   In  Varchar2,
                                       p_non_labor_resource      In  Varchar2,
                                       p_system_linkage          In  Varchar2,
                                       p_parent_member_id        In  Number,
                                       p_project_role_id         IN  NUMBER DEFAULT NULL,
                                       p_resource_id            Out  NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_resource_list_member_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_track_as_labor_flag    Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_code               Out  NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_err_stage           In Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_stack           In Out  NOCOPY Varchar2); --File.Sql.39 bug 4440895

    Procedure Get_Resource (p_resource_name           In  Varchar2,
                            p_resource_type_Code      In  Varchar2,
                            p_person_id               In  Number,
                            p_job_id                  In  Number,
                            p_proj_organization_id    In  Number,
                            p_vendor_id               In  Number,
                            p_expenditure_type        In  Varchar2,
                            p_event_type              In  Varchar2,
                            p_expenditure_category    In  Varchar2,
                            p_revenue_category_code   In  Varchar2,
                            p_non_labor_resource      In  Varchar2,
                            p_system_linkage          In  Varchar2,
                            p_project_role_id         IN  NUMBER DEFAULT NULL,
                            p_resource_id            Out  NOCOPY Number, --File.Sql.39 bug 4440895
                            p_err_code               Out  NOCOPY Number, --File.Sql.39 bug 4440895
                            p_err_stage           In Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                            p_err_stack           In Out  NOCOPY Varchar2); --File.Sql.39 bug 4440895

   Procedure Get_Resource_Information (p_resource_type_Code      In  Varchar2,
                                       p_resource_attr_value     In  Varchar2,
                                       p_unit_of_measure        Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_Rollup_quantity_flag   Out  NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_track_as_labor_flag    Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_code               Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_err_stage           In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_stack           In Out NOCOPY Varchar2); --File.Sql.39 bug 4440895

   Procedure Get_Uncateg_Resource_Info (p_resource_list_id        Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_resource_list_member_id Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_resource_id             Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_track_as_labor_flag     Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        p_err_code                Out NOCOPY Number, --File.Sql.39 bug 4440895
                                        p_err_stage            In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                        p_err_stack            In Out NOCOPY Varchar2); --File.Sql.39 bug 4440895

   Procedure Get_Unclassified_Member (p_resource_list_id           In Number,
                                      p_parent_member_id           In Number,
                                      p_unclassified_resource_id   In Number,
                                      p_resource_list_member_id   Out NOCOPY Number, --File.Sql.39 bug 4440895
                                      p_track_as_labor_flag       Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      p_err_code                  Out NOCOPY Number, --File.Sql.39 bug 4440895
                                      p_err_stage              In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                      p_err_stack              In Out NOCOPY Varchar2); --File.Sql.39 bug 4440895

  Procedure Get_Unclassified_Resource (p_resource_id              Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_resource_name            Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_track_as_labor_flag      Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_unit_of_measure          Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_rollup_quantity_flag     Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_code                 Out NOCOPY Number, --File.Sql.39 bug 4440895
                                       p_err_stage             In Out NOCOPY Varchar2, --File.Sql.39 bug 4440895
                                       p_err_stack             In Out NOCOPY Varchar2); --File.Sql.39 bug 4440895

FUNCTION Include_Inactive_Resources RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES ( Include_Inactive_Resources, WNDS, WNPS);

FUNCTION Child_Resource_exists(p_resource_id in number,
                               p_task_id in number,
                               p_project_id  in number)
  RETURN VARCHAR2;
  pragma RESTRICT_REFERENCES ( Child_Resource_exists, WNDS, WNPS);

PROCEDURE Set_Inactive_Resources_Flag (p_Set_Flag IN VARCHAR2);
PROCEDURE delete_resource_list_ok(l_resource_list_id IN NUMBER,
				 p_is_plan_res_list  IN VARCHAR2 default 'N',
                                 x_err_code IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_err_stage IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
PROCEDURE delete_resource_list_member_ok(l_resource_list_id IN NUMBER,
                                        l_resource_list_member_id IN NUMBER,
                                        x_err_code IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_err_stage IN OUT NOCOPY VARCHAR2);                                        --File.Sql.39 bug 4440895
END PA_GET_RESOURCE;

 

/
