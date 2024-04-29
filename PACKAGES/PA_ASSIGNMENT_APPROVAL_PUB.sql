--------------------------------------------------------
--  DDL for Package PA_ASSIGNMENT_APPROVAL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSIGNMENT_APPROVAL_PUB" AUTHID CURRENT_USER AS
/*$Header: PARAAPBS.pls 120.1 2005/08/19 16:46:58 mwasowic noship $*/

--Global Constants for type of action that can be performed
g_approve_action CONSTANT VARCHAR2(7) := 'APPROVE';
g_reject_action  CONSTANT VARCHAR2(7) := 'REJECT';
g_submit_action  CONSTANT VARCHAR2(7) := 'SUBMIT';
g_revert_action  CONSTANT VARCHAR2(7) := 'REVERT';
g_update_action  CONSTANT VARCHAR2(7) := 'UPDATE';
g_cancel_action  COnSTANT VARCHAR2(7) := 'CANCEL';


--Global Constants for assignment approval status_code
g_working      CONSTANT VARCHAR2(24) := 'ASGMT_APPRVL_WORKING';
g_approved     CONSTANT VARCHAR2(24) := 'ASGMT_APPRVL_APPROVED';
g_rejected     CONSTANT VARCHAR2(24) := 'ASGMT_APPRVL_REJECTED';
g_submitted    CONSTANT VARCHAR2(24) := 'ASGMT_APPRVL_SUBMITTED';
g_req_resub    CONSTANT VARCHAR2(24) := 'ASGMT_APPRVL_REQ_RESUB';
g_canceled     CONSTANT VARCHAR2(24) := 'ASGMT_APPRVL_CANCELED';

--Empty tables for mass assignment approval
prm_empty_num_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
prm_empty_varchar2_1_tbl      SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
prm_empty_varchar2_30_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
prm_empty_varchar2_240_tbl    SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();


--Record for the PL/SQL table to store approvers
TYPE Asgmt_Approvers_Rec_Type
IS RECORD
( person_id                 NUMBER                           := FND_API.G_MISS_NUM
 ,orders                    NUMBER                           := FND_API.G_MISS_NUM
 ,approver_person_type      VARCHAR2(100)	             := FND_API.G_MISS_CHAR
);


--Global PL/SQL table used to store approvers
TYPE Asgmt_Approvers_Tbl_Type IS TABLE OF Asgmt_Approvers_Rec_Type
   INDEX BY BINARY_INTEGER;

--Global PL/SQL table variable declared
g_approver_tbl  PA_ASSIGNMENT_APPROVAL_PUB.Asgmt_Approvers_Tbl_Type;



--
--Wrapper API to set approval status and determine which kind of workflow to launch.  The API will only be called from
-- Submit for Approval Page, when the user hit Submit, Approve or Reject buttons.
--
--p_action_code allowed: 'APPROVE', 'SUBMIT', 'REJECT'
--
PROCEDURE Start_Assignment_Approvals
( p_assignment_id               IN pa_project_assignments.assignment_id%TYPE
 ,p_new_assignment_flag         IN VARCHAR2
 ,p_action_code                 IN VARCHAR2
 ,p_note_to_approver            IN VARCHAR2                  := FND_API.G_MISS_CHAR
 ,p_record_version_number       IN NUMBER
 ,p_apr_person_id               IN NUMBER   DEFAULT NULL
 ,p_apr_person_name             IN VARCHAR2 DEFAULT NULL
 ,p_apr_person_type             IN VARCHAR2 DEFAULT NULL
 ,p_apr_person_order            IN NUMBER   DEFAULT NULL
 ,p_apr_person_exclude          IN VARCHAR2 DEFAULT NULL
 ,p_check_overcommitment_flag   IN VARCHAR2                  := 'N'
 ,p_conflict_group_id           IN NUMBER   DEFAULT NULL
 ,p_resolve_con_action_code     IN VARCHAR2 DEFAULT NULL
 ,p_api_version                 IN    NUMBER                 := 1.0
 ,p_init_msg_list               IN    VARCHAR2               := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2               := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2               := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                 := FND_API.G_MISS_NUM
 ,x_overcommitment_flag         OUT   NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
 ,x_conflict_group_id           OUT   NOCOPY VARCHAR2      --File.Sql.39 bug 4440895
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);





--
--API used to revert the current record in pa_project_assignments table to the last approved record in history table.
--
PROCEDURE Revert_To_Last_Approved
( p_assignment_id          IN   pa_project_assignments.assignment_id%TYPE
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


--
-- This procedure populates the PA_ASGMT_CHANGED_ITEMS table with changes on the assignment if the
-- assignment has been previously approved (i.e. not a new assignment). It compares the record with
-- the last approved record, and stores those changed fields and their old and new values in the table.
-- Currently, this api is called by Single/Mass Submit for Approval
--
PROCEDURE Populate_Changed_Items_Table
( p_assignment_id		IN  pa_project_assignments.assignment_id%TYPE
 ,p_populate_mode               IN  VARCHAR2                                                := 'SAVED'
 ,p_assignment_name             IN  pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_project_id                  IN  pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_staffing_priority_code      IN  pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_description                 IN  pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_extension_possible          IN  pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_additional_information      IN  pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_work_type_id                IN  pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_expense_owner               IN  pa_project_assignments.expense_owner%TYPE               := FND_API.G_MISS_CHAR
 ,p_expense_limit               IN  pa_project_assignments.expense_limit%TYPE               := FND_API.G_MISS_NUM
 ,p_fcst_tp_amount_type         IN  pa_project_assignments.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
 ,p_expenditure_type_class      IN  pa_project_assignments.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
 ,p_expenditure_type            IN  pa_project_assignments.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_id                 IN  pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_staffing_owner_person_id    IN  pa_project_assignments.staffing_owner_person_id%TYPE    := FND_API.G_MISS_NUM
 ,p_staffing_owner_name         IN  per_people_f.full_name%TYPE                             := FND_API.G_MISS_CHAR
 ,p_exception_type_code         IN  VARCHAR2                                                := NULL
 ,p_start_date                  IN  DATE                                                    := NULL
 ,p_end_date                    IN  DATE                                                    := NULL
 ,p_requirement_status_code     IN  VARCHAR2                                                := NULL
 ,p_assignment_status_code      IN  VARCHAR2                                                := NULL
 ,p_start_date_tbl              IN  SYSTEM.PA_DATE_TBL_TYPE                                 := NULL
 ,p_end_date_tbl                IN  SYSTEM.PA_DATE_TBL_TYPE                                 := NULL
 ,p_monday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_tuesday_hours_tbl           IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_wednesday_hours_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_thursday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_friday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_saturday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_sunday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE                                  := NULL
 ,p_non_working_day_flag        IN  VARCHAR2                                                := 'N'
 ,p_change_hours_type_code      IN  VARCHAR2                                                := NULL
 ,p_hrs_per_day                 IN  NUMBER                                                  := NULL
 ,p_calendar_percent            IN  NUMBER                                                  := NULL
 ,p_change_calendar_type_code   IN  VARCHAR2                                                := NULL
 ,p_change_calendar_name        IN  VARCHAR2                                                := NULL
 ,p_change_calendar_id          IN  NUMBER                                                  := NULL
 ,p_duration_shift_type_code    IN  VARCHAR2                                                := NULL
 ,p_duration_shift_unit_code    IN  VARCHAR2                                                := NULL
 ,p_number_of_shift             IN  NUMBER                                                  := NULL
 ,p_api_version                 IN  NUMBER                                                  := 1.0
 ,p_init_msg_list               IN  VARCHAR2                                                := FND_API.G_FALSE
 ,p_max_msg_count               IN  NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_new_assignment_flag         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_approval_required_flag      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_record_version_number       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_return_status		OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : Cancel_Assignment
-- Purpose              : cancel an assignment and reopen the original requirement.
-- Parameters           :
--
PROCEDURE Change_Assignment_Status
        (
          p_record_version_number         IN Number          ,
          p_assignment_id                 IN Number          ,
          p_assignment_type               IN Varchar2        ,
          p_start_date                    IN date            ,
          p_end_date                      IN date            ,
          p_assignment_status_code        IN Varchar2        := FND_API.G_MISS_CHAR,
          p_init_msg_list                 IN VARCHAR2        :=  FND_API.G_FALSE,
          p_commit                        IN VARCHAR2        :=  FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY Varchar2      , --File.Sql.39 bug 4440895
          x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
          x_msg_data                      OUT  NOCOPY Varchar2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : Get_Current_Approver
-- Purpose              : Get the approver which has the current approver flag set.
-- Parameters           :
--

PROCEDURE Get_Current_Approver
        (
          p_assignment_id                 IN NUMBER          ,
          p_project_id                    IN NUMBER          ,
          p_apprvl_status_code            IN VARCHAR2        ,
          x_approver_name                 OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



PROCEDURE Cancel_Assignment
        (
          p_record_version_number         IN Number          ,
          p_assignment_id                 IN Number          ,
          p_assignment_type               IN Varchar2        ,
          p_start_date                    IN date            ,
          p_end_date                      IN date            ,
          p_init_msg_list                 IN VARCHAR2        :=  FND_API.G_FALSE,
          p_commit                        IN VARCHAR2        :=  FND_API.G_FALSE,
          x_return_status                 OUT  NOCOPY Varchar2      , --File.Sql.39 bug 4440895
          x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
          x_msg_data                      OUT  NOCOPY Varchar2 ); --File.Sql.39 bug 4440895


/* This API is called from the Mass Submit for approval pages. */

PROCEDURE mass_submit_for_asgmt_aprvl
           (p_mode                        IN    VARCHAR2
           ,p_action                      IN    VARCHAR2
           ,p_resource_id_tbl             IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
           ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
           ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
           ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
            ,p_status_code                IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
            ,p_multiple_status_flag       IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
            ,p_staffing_priority_code     IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
            ,p_project_id                 IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
            ,p_project_role_id            IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
            ,p_role_list_id               IN    pa_role_lists.role_list_id%TYPE                         := FND_API.G_MISS_NUM
            ,p_project_subteam_id         IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
           ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
           ,p_append_description_flag     IN    VARCHAR2                                                := 'N'
           ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
           ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
           ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
           ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
           ,p_max_resource_job_level	  IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
           ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
           ,p_append_information_flag     IN    VARCHAR2                                                := 'N'
           ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
           ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
           ,p_calendar_type               IN    pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
           ,p_calendar_id	              IN    pa_project_assignments.calendar_id%TYPE	                := FND_API.G_MISS_NUM
           ,p_resource_calendar_percent   IN    pa_project_assignments.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
           ,p_project_name                IN    pa_projects_all.name%TYPE                               := FND_API.G_MISS_CHAR
           ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR
           ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                           := FND_API.G_MISS_CHAR
           ,p_project_status_name         IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
           ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
           ,p_project_role_name           IN    pa_project_role_types.meaning%TYPE                      := FND_API.G_MISS_CHAR
           ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
           ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
           ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
           ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
           ,p_calendar_name               IN    jtf_calendars_tl.calendar_name%TYPE                     := FND_API.G_MISS_CHAR
           ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                              := FND_API.G_MISS_CHAR
           ,p_expense_owner               IN    pa_project_assignments.expense_owner%TYPE               := FND_API.G_MISS_CHAR
           ,p_expense_limit               IN    pa_project_assignments.expense_limit%TYPE               := FND_API.G_MISS_NUM
           ,p_expense_limit_currency_code IN    pa_project_assignments.expense_limit_currency_code%TYPE := FND_API.G_MISS_CHAR
           ,p_fcst_tp_amount_type         IN    pa_project_assignments.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
           ,p_fcst_job_id                 IN    pa_project_assignments.fcst_job_id%TYPE                 := FND_API.G_MISS_NUM
           ,p_fcst_job_group_id           IN    pa_project_assignments.fcst_job_group_id%TYPE           := FND_API.G_MISS_NUM
           ,p_expenditure_org_id          IN    pa_project_assignments.expenditure_org_id%TYPE          := FND_API.G_MISS_NUM
           ,p_expenditure_organization_id IN    pa_project_assignments.expenditure_organization_id%TYPE := FND_API.G_MISS_NUM
           ,p_expenditure_type_class      IN    pa_project_assignments.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
           ,p_expenditure_type            IN    pa_project_assignments.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
           ,p_comp_match_weighting        IN    pa_project_assignments.competence_match_weighting%TYPE  := FND_API.G_MISS_NUM
           ,p_avail_match_weighting       IN    pa_project_assignments.availability_match_weighting%TYPE := FND_API.G_MISS_NUM
           ,p_job_level_match_weighting   IN    pa_project_assignments.job_level_match_weighting%TYPE   := FND_API.G_MISS_NUM
           ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE     := FND_API.G_MISS_NUM
           ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE         := FND_API.G_MISS_CHAR
           ,p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
          ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE := FND_API.G_MISS_NUM
           ,p_search_exp_org_hier_name    IN    per_organization_structures.name%TYPE                   := FND_API.G_MISS_CHAR
           ,p_search_exp_start_org_id     IN    pa_project_assignments.search_exp_start_org_id%TYPE     := FND_API.G_MISS_NUM
           ,p_search_exp_start_org_name   IN    hr_organization_units.name%TYPE                         := FND_API.G_MISS_CHAR
           ,p_search_min_candidate_score  IN    pa_project_assignments.search_min_candidate_score%TYPE  := FND_API.G_MISS_NUM
           ,p_enable_auto_cand_nom_flag   IN	pa_project_assignments.enable_auto_cand_nom_flag%TYPE	:= FND_API.G_MISS_CHAR
           ,p_staffing_owner_person_id    IN    pa_project_assignments.staffing_owner_person_id%TYPE    := FND_API.G_MISS_NUM
           ,p_staffing_owner_name         IN    per_people_f.full_name%TYPE                             := FND_API.G_MISS_CHAR
           ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
           ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
           ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
           ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
            ,p_exception_type_code        IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_start_date          IN    DATE                                                    := FND_API.G_MISS_DATE
            ,p_change_end_date            IN    DATE                                                    := FND_API.G_MISS_DATE
            ,p_change_rqmt_status_code    IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_asgmt_status_code   IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_start_date_tbl      IN    SYSTEM.PA_DATE_TBL_TYPE := NULL
            ,p_change_end_date_tbl        IN    SYSTEM.PA_DATE_TBL_TYPE := NULL
            ,p_monday_hours_tbl           IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_tuesday_hours_tbl          IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_wednesday_hours_tbl        IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_thursday_hours_tbl         IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_friday_hours_tbl           IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_saturday_hours_tbl         IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_sunday_hours_tbl           IN    SYSTEM.PA_NUM_TBL_TYPE  := NULL
            ,p_non_working_day_flag       IN    VARCHAR2                                                := 'N'
            ,p_change_hours_type_code     IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_hrs_per_day                IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_calendar_percent           IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_change_calendar_type_code  IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_calendar_name       IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_change_calendar_id         IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_duration_shift_type_code   IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_duration_shift_unit_code   IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_num_of_shift               IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_approver1_id_tbl           IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_approver1_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                               := prm_empty_varchar2_240_tbl
            ,p_approver2_id_tbl           IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_approver2_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                               := prm_empty_varchar2_240_tbl
            ,p_appr_over_auth_flag        IN    VARCHAR2                                                := 'N'
            ,p_note_to_all_approvers      IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_competence_id_tbl          IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_competence_name_tbl        IN    SYSTEM.pa_varchar2_240_tbl_type                               := prm_empty_varchar2_240_tbl
            ,p_competence_alias_tbl       IN    SYSTEM.pa_varchar2_30_tbl_type                                := prm_empty_varchar2_30_tbl
            ,p_rating_level_id_tbl        IN    SYSTEM.pa_num_tbl_type                                        := prm_empty_num_tbl
            ,p_mandatory_flag_tbl         IN    SYSTEM.pa_varchar2_1_tbl_type                                 := prm_empty_varchar2_1_tbl
            ,p_resolve_con_action_code    IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_api_version                IN    NUMBER                                                  := 1.0
            ,p_init_msg_list              IN    VARCHAR2                                                := FND_API.G_TRUE
            ,p_max_msg_count              IN    NUMBER                                                  := FND_API.G_MISS_NUM
            ,p_commit                     IN    VARCHAR2                                                := FND_API.G_FALSE
            ,p_validate_only              IN    VARCHAR2                                                := FND_API.G_TRUE            ,x_return_status              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count                  OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
            ,x_msg_data                   OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

PROCEDURE mass_assignment_approval
    ( p_project_id                  IN    pa_project_assignments.project_id%TYPE   := FND_API.G_MISS_NUM
     ,p_mode                        IN    VARCHAR2
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver1_id_tbl            IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver1_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_approver2_id_tbl            IN    SYSTEM.pa_num_tbl_type           := prm_empty_num_tbl
     ,p_approver2_name_tbl          IN    SYSTEM.pa_varchar2_240_tbl_type  := prm_empty_varchar2_240_tbl
     ,p_overriding_authority_flag   IN    VARCHAR2                     := 'N'
     ,p_submitter_user_id           IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_note_to_all_approvers       IN    VARCHAR2                     := FND_API.G_MISS_CHAR
     ,p_conflict_group_id           IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_update_info_doc             IN    VARCHAR2                     := FND_API.G_MISS_CHAR
     ,p_api_version                 IN    NUMBER                       := 1.0
     ,p_init_msg_list               IN    VARCHAR2                     := FND_API.G_TRUE
     ,p_max_msg_count               IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_commit                      IN    VARCHAR2                     := FND_API.G_FALSE
     ,p_validate_only               IN    VARCHAR2                     := FND_API.G_TRUE
     ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                   OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data                    OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

PROCEDURE mass_process_approval_result
    ( p_project_id                  IN    pa_project_assignments.project_id%TYPE   := FND_API.G_MISS_NUM
     ,p_mode                        IN    VARCHAR2
     ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type             := prm_empty_num_tbl
     ,p_approval_status_tbl         IN    SYSTEM.pa_varchar2_30_tbl_type     := prm_empty_varchar2_30_tbl
     ,p_group_id                    IN    NUMBER
     ,p_approver_group_id           IN    NUMBER
     ,p_routing_order               IN    NUMBER
     ,p_item_key                    IN    NUMBER
     ,p_notification_id             IN    NUMBER
     ,p_submitter_user_name         IN    VARCHAR2
     ,p_conflict_group_id           IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_api_version                 IN    NUMBER                       := 1.0
     ,p_init_msg_list               IN    VARCHAR2                     := FND_API.G_TRUE
     ,p_max_msg_count               IN    NUMBER                       := FND_API.G_MISS_NUM
     ,p_commit                      IN    VARCHAR2                     := FND_API.G_FALSE
     ,p_validate_only               IN    VARCHAR2                     := FND_API.G_TRUE
     ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                   OUT   NOCOPY NUMBER         --File.Sql.39 bug 4440895
     ,x_msg_data                    OUT   NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);


END PA_ASSIGNMENT_APPROVAL_PUB;
 

/
