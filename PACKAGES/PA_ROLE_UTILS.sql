--------------------------------------------------------
--  DDL for Package PA_ROLE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ROLE_UTILS" AUTHID CURRENT_USER as
-- $Header: PARLUTLS.pls 120.1 2005/08/19 16:56:23 mwasowic noship $

--
--  PROCEDURE
--              Check_Role_Name_Or_Id
--  PURPOSE
--              This procedure does the following
--              If role name is passed converts it to the id
--		If id is passed, based on the check_id_flag validates it
--  HISTORY
--   22-JUN-2000      R. Krishnamurthy       Created
--
procedure Check_Role_Name_Or_Id
      ( p_role_id  	  IN pa_project_role_types.project_role_id%TYPE
       ,p_role_name       IN pa_project_role_types.meaning%TYPE
       ,p_check_id_flag   IN VARCHAR2 := 'A'
       ,x_role_id        OUT NOCOPY pa_project_role_types.project_role_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              Check_Role_RoleList
--  PURPOSE
--              This procedure does the following
--              If role name is passed converts it to the id
--		If id is passed, based on the check_id_flag validates it
--              If role list name is passed converts it to the id
--		If role list id is passed, based on the check_id_flag validates it
--              It also validates that whether the role belongs to the role list
--  HISTORY
--   19-FEB-2001      Song Yao       Created

procedure Check_Role_RoleList
      ( p_role_id         IN pa_project_role_types.project_role_id%TYPE
       ,p_role_name       IN pa_project_role_types.meaning%TYPE
       ,p_role_list_id    IN pa_role_lists.role_list_id%TYPE := NULL
       ,p_role_list_name  IN pa_role_lists.name%TYPE := null
       ,p_check_id_flag   IN VARCHAR2
       ,x_role_id        OUT NOCOPY pa_project_role_types.project_role_id%TYPE --File.Sql.39 bug 4440895
       ,x_role_list_id   OUT NOCOPY pa_role_lists.role_list_id%TYPE --File.Sql.39 bug 4440895
       ,x_return_status  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--
--  PROCEDURE
--              get_role_defaults
--  PURPOSE
--		This procedure returns the defaults for a role
--
--  HISTORY
--
procedure Get_Role_Defaults
(p_role_id                IN pa_project_role_types.project_role_id%TYPE
,x_meaning                OUT NOCOPY pa_project_role_types.meaning%TYPE --File.Sql.39 bug 4440895
,x_default_min_job_level OUT NOCOPY pa_project_role_types.default_min_job_level%TYPE --File.Sql.39 bug 4440895
,x_default_max_job_level  OUT NOCOPY pa_project_role_types.default_max_job_level%TYPE --File.Sql.39 bug 4440895
,x_menu_id                OUT NOCOPY pa_project_role_types.menu_id%TYPE --File.Sql.39 bug 4440895
,x_schedulable_flag       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_default_job_id         OUT NOCOPY pa_project_role_types.default_job_id%TYPE --File.Sql.39 bug 4440895
,x_def_competencies	 OUT NOCOPY pa_hr_competence_utils.competency_tbl_typ --File.Sql.39 bug 4440895
,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_error_message_code     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Validate_Role_Competency
	     (p_competence_id   IN per_competences.competence_id%TYPE
	     ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Get_Schedulable_flag (p_role_id in number
                                ,x_schedulable_flag out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                ,x_return_status    out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                ,x_error_message_code out NOCOPY varchar2) ; --File.Sql.39 bug 4440895

FUNCTION Get_Schedulable_flag (p_role_id in number) return varchar2  ;


PROCEDURE Check_delete_role_OK (p_role_id in number
                                ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                ,x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895

PROCEDURE Check_remove_control_ok(p_role_id in number
                                           ,p_role_control_code in varchar2
                                           ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                           ,x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895

PROCEDURE Check_delete_role_list_OK(p_role_list_id in number
                                    ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    ,x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895

/*PROCEDURE Check_change_role_menu_OK(p_role_id in number
                                    ,x_return_status out varchar2
                                    ,x_error_message_code out varchar2);*/

PROCEDURE update_menu_in_grants(p_role_id in number
                               , p_menu_id in number
                               ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                               ,x_error_message_code out NOCOPY varchar2) ; --File.Sql.39 bug 4440895

PROCEDURE disable_role_based_sec(p_role_id in number
                               ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                               ,x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895

PROCEDURE Enable_role_based_sec(p_role_id in number
                               ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                               ,x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895

FUNCTION is_role_in_use(p_role_id in number) return varchar2;

PROCEDURE Check_dup_role_name(p_meaning in varchar2
                                    ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    ,x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895

PROCEDURE Check_dup_role_list_name(p_name in varchar2
                                    ,x_return_status out NOCOPY varchar2 --File.Sql.39 bug 4440895
                                    ,x_error_message_code out NOCOPY varchar2); --File.Sql.39 bug 4440895
end PA_ROLE_UTILS ;
 

/
