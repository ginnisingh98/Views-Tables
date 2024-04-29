--------------------------------------------------------
--  DDL for Package PA_MASS_ASGMT_TRX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_MASS_ASGMT_TRX" AUTHID CURRENT_USER AS
-- $Header: PARMATXS.pls 120.1 2005/08/29 20:51:10 sunkalya noship $

pa_empty_num_tbl             SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
pa_empty_varchar2_1_tbl      SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
pa_empty_varchar2_30_tbl     SYSTEM.pa_varchar2_30_tbl_type := SYSTEM.pa_varchar2_30_tbl_type();
pa_empty_varchar2_240_tbl    SYSTEM.pa_varchar2_240_tbl_type := SYSTEM.pa_varchar2_240_tbl_type();


G_MASS_ASGMT                     CONSTANT VARCHAR2(30) := 'MASS_ASGMT';
G_MASS_UPDATE_ASGMT_BASIC_INFO   CONSTANT VARCHAR2(30) := 'MASS_UPDATE_ASGMT_BASIC_INFO';
G_MASS_UPDATE_COMPETENCIES       CONSTANT VARCHAR2(30) := 'MASS_UPDATE_COMPETENCIES';
G_MASS_UPDATE_FORECAST_ITEMS     CONSTANT VARCHAR2(30) := 'MASS_UPDATE_FORECAST_ITEMS';
G_MASS_SUBMIT_FOR_APPROVAL       CONSTANT VARCHAR2(30) := 'MASS_SUBMIT_FOR_APPROVAL';
G_MASS_UPDATE_SCHEDULE           CONSTANT VARCHAR2(30) := 'MASS_UPDATE_SCHEDULE';
G_SAVE                           CONSTANT VARCHAR2(30) := 'SAVE';
G_SAVE_AND_SUBMIT                CONSTANT VARCHAR2(30) := 'SAVE_AND_SUBMIT';
G_SUBMIT                         CONSTANT VARCHAR2(30) := 'SUBMIT';

G_SUBMITTER_USER_ID              NUMBER;
G_SOURCE_TYPE1                   CONSTANT VARCHAR2(30) := 'MASS_ASSIGNMENT_TRANSACTION';
G_WORKFLOW_ITEM_TYPE             CONSTANT VARCHAR2(30) := 'PARMATRX';
G_WORKFLOW_ITEM_KEY              NUMBER;

PROCEDURE start_mass_asgmt_trx_wf
           (p_mode                        IN    VARCHAR2
           ,p_action                      IN    VARCHAR2
           ,p_resource_id_tbl             IN    SYSTEM.pa_num_tbl_type                                  := pa_empty_num_tbl
           ,p_assignment_id_tbl           IN    SYSTEM.pa_num_tbl_type                                  := pa_empty_num_tbl
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
           ,p_calendar_id	          IN    pa_project_assignments.calendar_id%TYPE	                := FND_API.G_MISS_NUM
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
           ,p_revenue_currency_code       IN    pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
           ,p_revenue_bill_rate           IN    pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
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
           ,p_enable_auto_cand_nom_flag   IN    pa_project_assignments.ENABLE_AUTO_CAND_NOM_FLAG%TYPE   := FND_API.G_MISS_CHAR
           ,p_staffing_owner_person_id    IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM       --FP.L Development
           ,p_staffing_owner_name         IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR      --FP.L Development
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
            ,p_approver1_id_tbl           IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
            ,p_approver1_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                        := pa_empty_varchar2_240_tbl
            ,p_approver2_id_tbl           IN    SYSTEM.pa_num_tbl_type                                 := pa_empty_num_tbl
            ,p_approver2_name_tbl         IN    SYSTEM.pa_varchar2_240_tbl_type                        := pa_empty_varchar2_240_tbl
            ,p_appr_over_auth_flag        IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_note_to_all_approvers      IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
            ,p_competence_id_tbl          IN    SYSTEM.pa_num_tbl_type                                       := pa_empty_num_tbl
            ,p_competence_name_tbl        IN    SYSTEM.pa_varchar2_240_tbl_type                              := pa_empty_varchar2_240_tbl
            ,p_competence_alias_tbl       IN    SYSTEM.pa_varchar2_30_tbl_type                                := pa_empty_varchar2_30_tbl
            ,p_rating_level_id_tbl        IN    SYSTEM.pa_num_tbl_type                                        := pa_empty_num_tbl
            ,p_mandatory_flag_tbl         IN    SYSTEM.pa_varchar2_1_tbl_type                                 := pa_empty_varchar2_1_tbl
            ,p_resolve_con_action_code    IN    VARCHAR2                                                   := FND_API.G_MISS_CHAR
            ,x_return_status              OUT   NOCOPY VARCHAR2                        	--Bug: 4537865
);

PROCEDURE mass_asgmt_trx_wf
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY  VARCHAR2);				--Bug: 4537865


PROCEDURE mass_asgmt_autonomous_trx
            (p_item_type                     IN        VARCHAR2,
             p_item_key                      IN        VARCHAR2,
             p_actid                         IN        NUMBER,
             p_funcmode                      IN        VARCHAR2,
             p_resource_id_tbl               IN        SYSTEM.pa_num_tbl_type,
             p_assignment_id_tbl             IN        SYSTEM.pa_num_tbl_type,
             x_mode                          OUT       NOCOPY VARCHAR2,			--Bug: 4537865
             x_action                        OUT       NOCOPY VARCHAR2,			--Bug: 4537865
             x_start_date                    OUT       NOCOPY DATE,			--Bug: 4537865
             x_end_date                      OUT       NOCOPY DATE,			--Bug: 4537865
             x_project_id                    OUT       NOCOPY NUMBER,			--Bug: 4537865
             x_document                      OUT       NOCOPY VARCHAR2);		--Bug: 4537865

PROCEDURE Start_Mass_Apprvl_WF_If_Req
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2);				--Bug: 4537865

 PROCEDURE Display_Updated_Attributes(document_id   IN VARCHAR2,
                                      display_type  IN VARCHAR2,
                                      document      IN OUT NOCOPY VARCHAR2,		--Bug: 4537865
                                      document_type IN OUT NOCOPY VARCHAR2);		--Bug: 4537865

 PROCEDURE Revert_Cancel_Overcom_Items
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2);				--Bug: 4537865

 FUNCTION Is_Asgmt_Revert_Or_Cancel(p_conflict_group_id     IN   NUMBER,
                                    p_assignment_id         IN pa_project_assignments.assignment_id%TYPE)
   RETURN BOOLEAN;

 PROCEDURE check_action_on_conflicts
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2);				--Bug: 4537865

 FUNCTION get_translated_attr_name (p_lookup_code IN VARCHAR2)
   RETURN VARCHAR2;

 PROCEDURE Cancel_Mass_Trx_WF
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2);				--Bug: 4537865

PROCEDURE Abort_Remaining_Trx
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2);				--Bug: 4537865

 PROCEDURE Set_Submitter_User_Name
            (p_item_type     IN        VARCHAR2,
             p_item_key      IN        VARCHAR2,
             p_actid         IN        NUMBER,
             p_funcmode      IN        VARCHAR2,
             p_result        OUT       NOCOPY VARCHAR2);				--Bug: 4537865

END;


 

/
