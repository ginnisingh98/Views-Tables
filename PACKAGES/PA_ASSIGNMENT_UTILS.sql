--------------------------------------------------------
--  DDL for Package PA_ASSIGNMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSIGNMENT_UTILS" AUTHID CURRENT_USER AS
-- $Header: PARAUTLS.pls 120.2 2005/08/19 16:48:42 mwasowic noship $

g_team_template_id               PA_TEAM_TEMPLATES.team_template_id%TYPE      := NULL;
g_team_template_name_token       PA_TEAM_TEMPLATES.team_template_name%TYPE    := NULL;
g_team_role_name_token           PA_PROJECT_ASSIGNMENTS.assignment_name%TYPE  := NULL;
g_provisional_hours              NUMBER := 0;
g_confirmed_hours                NUMBER := 0;
g_person_id_wo_name              pa_resources_denorm.person_id%TYPE           := NULL;
g_project_id_wo_name             pa_project_assignments.project_id%TYPE       := NULL;
g_ei_date_wo_name                DATE := NULL;

g_person_id_w_name               pa_resources_denorm.person_id%TYPE           := NULL;
g_project_id_w_name              pa_project_assignments.project_id%TYPE       := NULL;
g_ei_date_w_name                 DATE := NULL;

g_in_asgmt_name                  pa_project_assignments.assignment_name%TYPE  := NULL;
g_out_asgmt_name                 pa_project_assignments.assignment_name%TYPE  := NULL;
g_assignment_id_w_name           pa_project_assignments.assignment_id%TYPE    := NULL;
g_assignment_id_wo_name          pa_project_assignments.assignment_id%TYPE    := NULL;

--
--  PROCEDURE
--              Check_Status_Is_In_use
--  PURPOSE
--              This procedure Checks whether a given status is used in
--      Assignments and assignment schedules
--  HISTORY
--   16-JUL-2000      R. Krishnamurthy       Created
--
PROCEDURE Check_Status_Is_In_use
            ( p_status_code IN pa_project_statuses.project_status_code%TYPE
             ,x_in_use_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  PROCEDURE
--              Validate_Asgmt_Competency
--  PURPOSE
--              This procedure validates the competencies for an assignment
--  HISTORY
--   17-JUL-2000      R. Krishnamurthy       Created
--
PROCEDURE Validate_Asgmt_Competency
            ( p_project_id  IN pa_projects_all.project_id%TYPE DEFAULT NULL
             ,p_assignment_id   IN pa_project_assignments.assignment_id%TYPE
             ,p_competence_id   IN per_competences.competence_id%TYPE
         ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  PROCEDURE
--              Get_Def_Asgmt_Statuses
--    This procedure returns the default assignment statuses
--    17-JUL-2000      R. Krishnamurthy       Created

PROCEDURE Get_Def_Asgmt_Statuses
   (x_starting_oa_status OUT NOCOPY pa_project_statuses.project_status_code%TYPE, --File.Sql.39 bug 4440895
    x_starting_sa_status OUT NOCOPY pa_project_statuses.project_status_code%TYPE, --File.Sql.39 bug 4440895
    x_starting_fa_status OUT NOCOPY pa_project_statuses.project_status_code%TYPE, --File.Sql.39 bug 4440895
    x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--  FUNCTION
--              Get_project_id
--    This function returns the project id for a given assignment

--    17-JUL-2000      R. Krishnamurthy       Created
FUNCTION  Get_Project_Id (p_assignment_id IN NUMBER) RETURN NUMBER;

FUNCTION Is_Confirmed_Status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2;
-- This function returns whether a given assignment status is
-- a confirmed status or not
--    18-JUL-2000      R. Krishnamurthy       Created

pragma RESTRICT_REFERENCES (Is_Confirmed_Status, WNDS, WNPS);

FUNCTION Is_Provisional_Status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2;
-- This function returns whether a given assignment status is
-- a Provisional status or not
--    18-JUL-2000      R. Krishnamurthy       Created
pragma RESTRICT_REFERENCES (Is_Provisional_Status, WNDS, WNPS);

FUNCTION Is_Asgmt_Filled
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2;
-- This function returns whether a given assignment status is
-- a Filled status or not
--    18-JUL-2000      R. Krishnamurthy       Created
pragma RESTRICT_REFERENCES (Is_Asgmt_Filled, WNDS, WNPS);

FUNCTION Is_Asgmt_In_Open_Status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2;
-- This function returns whether a given assignment status is
-- an Open status or not
--    18-JUL-2000      R. Krishnamurthy       Created
pragma RESTRICT_REFERENCES (Is_Asgmt_In_Open_Status, WNDS, WNPS);

FUNCTION Is_Open_Asgmt_Cancelled
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2;
-- This function returns whether a given open assignment status is
-- a cancelled status or not
--    18-JUL-2000      R. Krishnamurthy       Created
pragma RESTRICT_REFERENCES (Is_Open_Asgmt_Cancelled, WNDS, WNPS);

FUNCTION Is_Staffed_Asgmt_Cancelled
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
 p_status_type IN pa_project_statuses.status_type%TYPE )
 return VARCHAR2;
-- This function returns whether a given staffed assignment status is
-- a cancelled status or not
--    18-JUL-2000      R. Krishnamurthy       Created
pragma RESTRICT_REFERENCES (Is_Staffed_Asgmt_Cancelled, WNDS, WNPS);

FUNCTION Check_input_system_status
(p_status_code IN pa_project_statuses.project_status_code%TYPE ,
p_status_type IN pa_project_statuses.status_type%TYPE ,
p_in_system_status_code IN pa_project_statuses.project_system_status_code%TYPE)
return VARCHAR2;
-- This function returns whether a given status
-- has the specified system status
--    18-JUL-2000      R. Krishnamurthy       Created
pragma RESTRICT_REFERENCES (Check_input_system_status, WNDS, WNPS);

PROCEDURE Check_proj_Assignments_Exist
             (p_project_id                IN NUMBER
             ,x_assignments_exist_flag   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--  PURPOSE
--              This procedure Checks whether a given project has
--      Assignments and assignment schedules

PROCEDURE Check_Assignment_Number_Or_Id( p_assignment_id      IN pa_project_assignments.assignment_id%TYPE
                                        ,p_assignment_number  IN pa_project_assignments.assignment_number%TYPE
                                        ,p_check_id_flag      IN VARCHAR2 := 'A'
                                        ,x_assignment_id      OUT NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
                                        ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                        ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--Validates the assignment number



--
--Validate the Staffing Priority Name/Code
--
PROCEDURE Check_STF_PriorityName_Or_Code (p_staffing_priority_code  IN pa_project_assignments.staffing_priority_code%TYPE
                                               ,p_staffing_priority_name  IN pa_lookups.meaning%TYPE
                                               ,p_check_id_flag           IN VARCHAR2
                                               ,x_staffing_priority_code  OUT NOCOPY pa_project_assignments.staffing_priority_code%TYPE --File.Sql.39 bug 4440895
                                               ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                               ,x_error_message_code      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--
--Possible values for return: 'Roll On', 'Roll Off', 'Pending Approval'
--
--Use the dates passed in to decided if the assignment is rolling on, or rolling off or pending approval.

FUNCTION  get_role_activity_text (p_assignment_id  IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date IN DATE,
                                  p_apprvl_status_code IN VARCHAR2,
                                  p_num_of_weeks IN NUMBER) RETURN VARCHAR2;


--
--Possible values for return: start_date, end_date
--
--IF assignment rolling on, then return start_date
--IF assignment rolling off, then return end_date
--IF pending approval, then return start_date

FUNCTION  get_role_activity_date (p_assignment_id  IN NUMBER,
                                  p_start_date IN DATE,
                                  p_end_date IN DATE,
                                  p_apprvl_status_code IN VARCHAR2,
                                  p_num_of_weeks IN NUMBER) RETURN DATE;

PROCEDURE Add_Message(p_app_short_name   IN    VARCHAR2,
                      p_msg_name         IN    VARCHAR2,
                      p_token1           IN    VARCHAR2 DEFAULT NULL,
                      p_value1           IN    VARCHAR2 DEFAULT NULL);

FUNCTION is_asgmt_allow_stus_ctl_check(p_asgmt_status_code IN   pa_project_statuses.project_status_code%TYPE,
                                       p_project_id        IN   pa_projects_all.project_id%TYPE,
                                       p_add_message       IN   VARCHAR2)
   RETURN VARCHAR2;

PROCEDURE Get_Person_Asgmt
            ( p_person_id          IN pa_resources_denorm.person_id%TYPE
             ,p_project_id         IN pa_project_assignments.project_id%TYPE
             ,p_ei_date            IN DATE
             ,x_assignment_name    IN OUT NOCOPY pa_project_assignments.assignment_name%TYPE --File.Sql.39 bug 4440895
             ,x_assignment_id      OUT NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
         ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Get_Assignment_Measures
         ( p_assignment_id        IN pa_project_assignments.assignment_id%TYPE
          ,p_resource_id          IN pa_project_assignments.resource_id%TYPE
          ,p_asgn_effort          IN pa_project_assignments.assignment_effort%TYPE
          ,p_asgn_start_date      IN pa_project_assignments.start_date%TYPE
          ,p_asgn_end_date        IN pa_project_assignments.end_date%TYPE
          ,p_multiple_status_flag IN pa_project_assignments.multiple_status_flag%TYPE)
RETURN NUMBER;

FUNCTION Get_Asgn_Provisional_Hours
RETURN NUMBER;

FUNCTION Get_Asgn_Confirmed_Hours
RETURN NUMBER;

--
--  PROCEDURE
--             Get Default Staffing Owner
--  PURPOSE
--              This procedure returns the default team role
--              staffing owner given the project_id and exp_org_id
--  HISTORY
--   29-APR-2003      shyugen       Created
--
PROCEDURE Get_Default_Staffing_Owner
            ( p_project_id  IN pa_projects_all.project_id%TYPE
             ,p_exp_org_id      IN pa_project_assignments.expenditure_org_id%TYPE := NULL
             ,x_person_id   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_person_name     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

------------------------------------------------------------------------------
--  PROCEDURE
--             Get All Staffing Owner
--  PURPOSE
--              This procedure returns the project and team role
--              staffing owners for a team role
--  HISTORY
--   29-APR-2003      shyugen       Created
------------------------------------------------------------------------------
PROCEDURE Get_All_Staffing_Owners
            ( p_assignment_id   IN pa_project_assignments.assignment_id%TYPE
             ,p_project_id      IN pa_projects_all.project_id%TYPE
             ,x_person_id_tbl   OUT NOCOPY system.pa_num_tbl_type --File.Sql.39 bug 4440895
             ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

------------------------------------------------------------------------------
--  PROCEDURE
--             Associate Planning Resource
--  PURPOSE
--              This procedure finds and associate planning resource to
--              existing Team Roles
--  HISTORY
--   29-APR-2003      shyugen       Created
------------------------------------------------------------------------------
PROCEDURE Associate_Planning_Resources
            ( p_project_id             IN NUMBER
             ,p_old_resource_list_id   IN NUMBER
             ,p_new_resource_list_id   IN NUMBER
             ,x_return_status   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
             ,x_msg_count       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
             ,x_msg_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION Get_multi_team_role_flag RETURN VARCHAR2; /* Added new function to check if team role is associated with multiple assignement
                                                  or requirement for bug 3724780 */
/* Added for bug 3724780, to get assignment_id from pa_project_assignments */
FUNCTION Get_project_assignment_id
           (p_resource_list_member_id IN NUMBER,
            p_project_id IN NUMBER) RETURN NUMBER;
FUNCTION Get_project_assignment_type
           (p_resource_list_member_id IN NUMBER,
            p_project_id IN NUMBER) RETURN VARCHAR2;



------------------------------------------------------------------------------
--  FUNCTION
--             Check_Res_Format_Used_For_TR
--  PURPOSE
--             This function checks if the resource format is the default
--             format for Requirement creation.
--  HISTORY
--   22-JUL-2004      clevesqu       Created
------------------------------------------------------------------------------
FUNCTION Check_Res_Format_Used_For_TR(p_res_format_id IN NUMBER, p_resource_list_id IN NUMBER) RETURN VARCHAR2;

------------------------------------------------------------------------------
--  FUNCTION
--
--  PURPOSE
--             This function checks if the resource list member_id has a single submitted status
--               for the project
--  HISTORY
--   09-10-2004      jraj       Created
------------------------------------------------------------------------------
FUNCTION Get_single_submitted_status(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER) RETURN VARCHAR2;

------------------------------------------------------------------------------
--  FUNCTION
--
--  PURPOSE
--             This function checks if the resource list member_id has task assignment's beyond team role dates
--  HISTORY
--   09-15-2004      jraj       Created
------------------------------------------------------------------------------
FUNCTION Get_At_Risk_Status(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER, p_budget_version_id IN NUMBER, p_start IN VARCHAR2) RETURN VARCHAR2;


FUNCTION Get_Team_Role_Start(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER)
RETURN DATE;

FUNCTION Get_Team_Role_End(p_project_id IN NUMBER, p_resource_list_member_id IN NUMBER)
RETURN DATE ;

-- 4363092 Added following function for MOAC Changes
-- returns default org_id
FUNCTION Get_Dft_Info
RETURN NUMBER;

end PA_ASSIGNMENT_UTILS ;

 

/
