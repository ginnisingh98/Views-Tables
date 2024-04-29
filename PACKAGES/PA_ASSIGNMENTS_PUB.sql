--------------------------------------------------------
--  DDL for Package PA_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSIGNMENTS_PUB" AUTHID CURRENT_USER AS
/*$Header: PARAPUBS.pls 120.2.12010000.6 2009/12/02 06:09:31 kkorrapo ship $*/
--

--
--Global Variable used to determine if any error has occured in the procedure.
--
g_error_exists  VARCHAR2(1) := FND_API.G_FALSE;
--
--Composite Record used to pass information from the API wrapper
--
TYPE Assignment_Rec_Type
IS RECORD
 ( assignment_row_id          ROWID
 ,assignment_id               pa_project_assignments.assignment_id%TYPE                := FND_API.G_MISS_NUM
 ,assignment_name             pa_project_assignments.assignment_name%TYPE              := FND_API.G_MISS_CHAR
 ,assignment_type             pa_project_assignments.assignment_type%TYPE              := FND_API.G_MISS_CHAR
 ,apprvl_status_code          pa_project_assignments.apprvl_status_code%TYPE           := FND_API.G_MISS_CHAR
 ,status_code                 pa_project_assignments.status_code%TYPE                  := FND_API.G_MISS_CHAR
 ,staffing_priority_code      pa_project_assignments.staffing_priority_code%TYPE       := FND_API.G_MISS_CHAR
 ,multiple_status_flag        pa_project_assignments.multiple_status_flag%TYPE         := 'N'
 ,record_version_number       pa_project_assignments.record_version_number%TYPE        := FND_API.G_MISS_NUM
 ,project_id                  pa_project_assignments.project_id%TYPE                   := FND_API.G_MISS_NUM
 ,project_role_id             pa_project_assignments.project_role_id%TYPE              := FND_API.G_MISS_NUM
 ,resource_id                 pa_project_assignments.resource_id%TYPE                  := FND_API.G_MISS_NUM
 ,project_party_id            pa_project_assignments.project_party_id%TYPE             := FND_API.G_MISS_NUM
 ,description                 pa_project_assignments.description%TYPE                  := FND_API.G_MISS_CHAR
 ,note_to_approver            pa_project_assignments.note_to_approver%TYPE             := FND_API.G_MISS_CHAR
 ,start_date                  pa_project_assignments.start_date%TYPE                   := FND_API.G_MISS_DATE
 ,end_date                    pa_project_assignments.end_date%TYPE                     := FND_API.G_MISS_DATE
 ,assignment_effort           pa_project_assignments.assignment_effort%TYPE            := FND_API.G_MISS_NUM
 ,extension_possible          pa_project_assignments.extension_possible%TYPE           := FND_API.G_MISS_CHAR
 ,source_assignment_id        pa_project_assignments.source_assignment_id%TYPE         := FND_API.G_MISS_NUM
 ,min_resource_job_level      pa_project_assignments.min_resource_job_level%TYPE       := FND_API.G_MISS_NUM
 ,max_resource_job_level      pa_project_assignments.max_resource_job_level%TYPE       := FND_API.G_MISS_NUM
 ,assignment_number           pa_project_assignments.assignment_number%TYPE            := FND_API.G_MISS_NUM
 ,additional_information      pa_project_assignments.additional_information%TYPE       := FND_API.G_MISS_CHAR
 ,location_id                 pa_project_assignments.location_id%TYPE                  := FND_API.G_MISS_NUM
 ,work_type_id                pa_project_assignments.work_type_id%TYPE                 := FND_API.G_MISS_NUM
 ,revenue_currency_code       pa_project_assignments.revenue_currency_code%TYPE        := FND_API.G_MISS_CHAR
 ,revenue_bill_rate           pa_project_assignments.revenue_bill_rate%TYPE            := FND_API.G_MISS_NUM
 ,markup_percent              pa_project_assignments.markup_percent%TYPE               := FND_API.G_MISS_NUM
 ,expense_owner               pa_project_assignments.expense_owner%TYPE                := FND_API.G_MISS_CHAR
 ,expense_limit               pa_project_assignments.expense_limit%TYPE                := FND_API.G_MISS_NUM
 ,expense_limit_currency_code pa_project_assignments.expense_limit_currency_code%TYPE  := FND_API.G_MISS_CHAR
 ,fcst_tp_amount_type         pa_project_assignments.fcst_tp_amount_type%TYPE          := FND_API.G_MISS_CHAR
 ,fcst_job_id                 pa_project_assignments.fcst_job_id%TYPE                  := FND_API.G_MISS_NUM
 ,fcst_job_group_id           pa_project_assignments.fcst_job_group_id%TYPE           := FND_API.G_MISS_NUM
 ,expenditure_org_id          pa_project_assignments.expenditure_org_id%TYPE          := FND_API.G_MISS_NUM
 ,expenditure_organization_id pa_project_assignments.expenditure_organization_id%TYPE := FND_API.G_MISS_NUM
 ,expenditure_type_class      pa_project_assignments.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
 ,expenditure_type            pa_project_assignments.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
 ,calendar_type               pa_project_assignments.calendar_type%TYPE                := FND_API.G_MISS_CHAR
 ,calendar_id                 pa_project_assignments.calendar_id %TYPE                 := FND_API.G_MISS_NUM
 ,resource_calendar_percent   pa_project_assignments.resource_calendar_percent%TYPE    := FND_API.G_MISS_NUM
 ,no_of_active_candidates     pa_project_assignments.no_of_active_candidates%TYPE      := FND_API.G_MISS_NUM
 ,assignment_template_id      pa_project_assignments.assignment_template_id%TYPE       := FND_API.G_MISS_NUM
 ,template_flag               pa_project_assignments.template_flag%TYPE                := FND_API.G_MISS_CHAR
 ,source_assignment_type      VARCHAR2(80)                                             := NULL
 ,comp_match_weighting        pa_project_assignments.competence_match_weighting%TYPE   := FND_API.G_MISS_NUM
 ,avail_match_weighting       pa_project_assignments.availability_match_weighting%TYPE := FND_API.G_MISS_NUM
 ,job_level_match_weighting   pa_project_assignments.job_level_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,search_min_availability     pa_project_assignments.search_min_availability%TYPE      := FND_API.G_MISS_NUM
 ,search_country_code         pa_project_assignments.search_country_code%TYPE          := FND_API.G_MISS_CHAR
 ,search_exp_org_struct_ver_id pa_project_assignments.search_exp_org_struct_ver_id%TYPE := FND_API.G_MISS_NUM
 ,search_exp_start_org_id     pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,search_min_candidate_score  pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,last_auto_search_date       pa_project_assignments.last_auto_search_date%TYPE         := FND_API.G_MISS_DATE
 ,enable_auto_cand_nom_flag   pa_project_assignments.enable_auto_cand_nom_flag%TYPE     := FND_API.G_MISS_CHAR
 ,mass_wf_in_progress_flag    pa_project_assignments.mass_wf_in_progress_flag%TYPE      := FND_API.G_MISS_CHAR
 ,bill_rate_override          pa_project_assignments.bill_rate_override%TYPE            := FND_API.G_MISS_NUM
 ,bill_rate_curr_override     pa_project_assignments.bill_rate_curr_override%TYPE       := FND_API.G_MISS_CHAR
 ,markup_percent_override     pa_project_assignments.markup_percent_override%TYPE       := FND_API.G_MISS_NUM
 ,discount_percentage       pa_project_assignments.discount_percentage%TYPE           := FND_API.G_MISS_NUM -- Bug 2531267
 ,rate_disc_reason_code     pa_project_assignments.rate_disc_reason_code%TYPE         := FND_API.G_MISS_CHAR -- Bug 2531267
 ,tp_rate_override            pa_project_assignments.tp_rate_override%TYPE              := FND_API.G_MISS_NUM
 ,tp_currency_override        pa_project_assignments.tp_currency_override%TYPE          := FND_API.G_MISS_CHAR
 ,tp_calc_base_code_override  pa_project_assignments.tp_calc_base_code_override%TYPE    := FND_API.G_MISS_CHAR
 ,tp_percent_applied_override pa_project_assignments.tp_percent_applied_override%TYPE   := FND_API.G_MISS_NUM
,staffing_owner_person_id     pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM
 -- FP.M Development
 ,resource_list_member_id     pa_project_assignments.resource_list_member_id%TYPE       := FND_API.G_MISS_NUM
 ,attribute_category          pa_project_assignments.attribute_category%TYPE           := FND_API.G_MISS_CHAR
 ,attribute1                  pa_project_assignments.attribute1%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute2                  pa_project_assignments.attribute2%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute3                  pa_project_assignments.attribute3%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute4                  pa_project_assignments.attribute4%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute5                  pa_project_assignments.attribute5%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute6                  pa_project_assignments.attribute6%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute7                  pa_project_assignments.attribute7%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute8                  pa_project_assignments.attribute8%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute9                  pa_project_assignments.attribute9%TYPE                   := FND_API.G_MISS_CHAR
 ,attribute10                 pa_project_assignments.attribute10%TYPE                  := FND_API.G_MISS_CHAR
 ,attribute11                 pa_project_assignments.attribute11%TYPE                  := FND_API.G_MISS_CHAR
 ,attribute12                 pa_project_assignments.attribute12%TYPE                  := FND_API.G_MISS_CHAR
 ,attribute13                 pa_project_assignments.attribute13%TYPE                  := FND_API.G_MISS_CHAR
 ,attribute14                 pa_project_assignments.attribute14%TYPE                  := FND_API.G_MISS_CHAR
 ,attribute15                 pa_project_assignments.attribute15%TYPE                  := FND_API.G_MISS_CHAR
/* Added for bug 3051110 */
 ,transfer_price_rate        pa_project_assignments.transfer_price_rate%TYPE           := FND_API.G_MISS_NUM
 ,transfer_pr_rate_curr      pa_project_assignments.transfer_pr_rate_curr%TYPE         := FND_API.G_MISS_CHAR
);

TYPE Assignment_Tbl_Type IS TABLE OF Assignment_Rec_Type
   INDEX BY BINARY_INTEGER;

TYPE Assignment_Id_Rec_Type IS RECORD
 (assignment_id   NUMBER);

TYPE Assignment_Id_Tbl_Type IS TABLE OF Assignment_Id_Rec_Type
   INDEX BY BINARY_INTEGER;

TYPE num_tbl_type IS TABLE OF NUMBER
   INDEX BY BINARY_INTEGER;

TYPE res_name_tbl_type IS TABLE OF pa_resources_denorm.resource_name%TYPE
   INDEX BY BINARY_INTEGER;

g_assignment_id_tbl    Assignment_Id_Tbl_Type;
G_update_assignment_bulk_call    varchar2(1) := 'N';  -- Bug 8223045

-- ----------------------------------------------------------------------------
-- |--------------------------<Execute_Create_Assignment>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	This API creates a requirement or an assignment from the scalar values passed to it. It loads the composite
--      record with scalar values and calls Create_Assignment.
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type             Description
-- p_asgn_creation_mode                  VARCHAR2         Indicates whether the assignment creation is FULL or
--                                                          PARTIAL. Defaults to 'FULL'
-- p_unfilled_assignment_status          VARCHAR2         Status of the newly created requirement when assignment is
--                                                          partial.
-- p_assignment_name                X    VARCHAR2         Required if p_assignment_id is null.
-- p_assignment_type                Y    VARCHAR2         Indicates the type of the object for which status is shown.
--                                                          'OPEN_ASSIGNMENT'   => Requirement
--                                                          'STAFFED_ASSIGNMENT'=> Assignment/Project Assignment
--                                                          'STAFFED_ADMIN_ASSIGNMENT' => Administrative Assignment
-- p_multiple_status_flag           Y    VARCHAR2         Indicates whether the underlying schedule for the Assignment
--                                                          have more than one statuses. For requirement, use 'N'
-- p_status_code                    X    VARCHAR2         Indicates the status of the assignment. This column may be
--						   	    null if the underlying schedule has multiple status codes.
--                                                          This is mandatory if p_project_status_name is null.
-- p_project_id                     X    NUMBER           The identifier of the project to which this record belongs
--                                                          This is mandatory if p_project_number is null.
-- p_project_role_id                X    NUMBER           Identifier of the project role for the record.
--                                                          This is mandatory if project_role_name is null.
-- p_resource_id                         NUMBER           Identifier of the project resource.
-- p_project_party_id                    NUMBER           The identifier of the project party on an assignment.
-- p_project_subteam_id             X    NUMBER           The identifier for the project subteam to which this record
--                                                           belongs. Mandatory if p_project_subteam_name is null.
-- p_description                         VARCHAR2         The free text description of the record.
-- p_start_date                     Y    DATE             Start date of the requirement/assignment
-- p_end_date                       Y    DATE             End date of the requirement/assignment.
-- p_assignment_effort                   NUMBER		  Total number of hours of the requirement/assignment
-- p_extension_possible                  VARCHAR2         Indicates whether it is possible to extend the
--       						    requirement/assignment.
-- p_source_assignment_id                NUMBER           Identifies the assignment from which this assignment record
--                                                          is originated.
-- p_min_resource_job_level              NUMBER           Indicates the minimum acceptable job level for a requirement.
-- p_max_resource_job_level	         NUMBER           Indidates the maximum acceptable job level for a requirement.
-- p_additional_information              VARCHAR2         Free text for additional information on a record.
-- p_location_id                         NUMBER           Identifier of the location of the assignment. For new
--                                                          assignments this column gets default value from the project
--                                                          setup.
-- p_work_type_id                  X     NUMBER           Identifies the type of work being carried out. Gets defaulted
--                                                          from project setup for open assignment and from staffed
--                                                          assignments not created from an open assignment.Mandatory
--                                                          if work_type_name is null
-- p_revenue_currency_code               VARCHAR2         Currency code of the revenue
-- p_revenue_bill_rate                   NUMBER           Bill rate of the revenue
-- p_expense_owner                       VARCHAR2         Owner of the expense
-- p_expense_limit                       NUMBER           The maximum amount that expense owner is willing to pay.
-- p_expense_limit_currency_code         VARCHAR2         Currency code of the expense limit.
-- p_fcst_tp_amount_type		 VARCHAR2
-- p_fcst_job_id                         NUMBER
-- p_calendar_type                       VARCHAR2         Indicates the base calendar used for generating schedules.
-- p_calendar_id	                 NUMBER           Identifier of the calendar
-- p_resource_calendar_percent           NUMBER           Daily percentage of the resource calendar
-- p_project_name                 X      VARCHAR2         Required if p_project_number and p_project_id are null.
-- p_project_number               X      VARCHAR2         Required if p_project_id and p_project_name are null.
-- p_resource_name                X      VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id           X      NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_project_subteam_name                VARCHAR2
-- p_project_status_name          X      VARCHAR2         Required if p_project_status_code is null.
-- p_project_role_name            X      VARCHAR2         Required if p_project_role_id is null.
-- p_location_city                       VARCHAR2
-- p_location_region                     VARCHAR2
-- p_location_country_name               VARCHAR2
-- p_location_country_code               VARCHAR2
-- p_calendar_name                X      VARCHAR2         Required if p_calendar_id is null.
-- p_work_type_name               X      VARCHAR2         Required if p_work_type_id is null.
-- p_attribute_category                  VARCHAR2	  Descriptive flexfield context field
-- p_attribute1                  	 VARCHAR2	  Descriptive flexfield segment
-- p_attribute2                  	 VARCHAR2
-- p_attribute3                 	 VARCHAR2
-- p_attribute4                		 VARCHAR2
-- p_attribute5                		 VARCHAR2
-- p_attribute6                   	 VARCHAR2
-- p_attribute7                 	 VARCHAR2
-- p_attribute8                  	 VARCHAR2
-- p_attribute9                 	 VARCHAR2
-- p_attribute10                 	 VARCHAR2
-- p_attribute11                 	 VARCHAR2
-- p_attribute12                  	 VARCHAR2
-- p_attribute13                	 VARCHAR2
-- p_attribute14                	 VARCHAR2
-- p_attribute15                 	 VARCHAR2
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
--Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_new_assignment_id              NUMBER   System generated id of the requirement/assignment
-- x_assignment_number              NUMBER   System generated number of the requirement/assignment
-- x_assignment_row_id              ROWID    requirement/assignment row id
-- x_resource_id                    NUMBER   Identifier of the Project resource, it is null for a requirement
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
-- x_new_assignment_id_tbl          Number table type.Poplulating in case of multiple requirements.
--   13-aug-2003    sramesh     -- Added the new parameter x_new_assignment_id_tbl for the procedure
--                                 Execute_Create_Assignment and also in the impacted places.
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Execute_Create_Assignment
( p_asgn_creation_mode          IN    VARCHAR2                                                := 'FULL'
 ,p_unfilled_assignment_status  IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_status_code                 IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN    pa_project_assignments.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_project_role_id             IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_role_list_id                IN    pa_role_lists.role_list_id%TYPE                         := FND_API.G_MISS_NUM
 ,p_resource_id                 IN    pa_resources.resource_id%TYPE                           := FND_API.G_MISS_NUM
 ,p_project_party_id            IN    pa_project_assignments.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
 ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_assignment_effort           IN    pa_project_assignments.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN    pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN    pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN    pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN    pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
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
 ,p_calendar_type               IN    pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
 ,p_calendar_id	                IN    pa_project_assignments.calendar_id%TYPE	              := FND_API.G_MISS_NUM
 ,p_resource_calendar_percent   IN    pa_project_assignments.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
 ,p_project_name                IN    pa_projects_all.name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR
 ,p_resource_name               IN    pa_resources.name%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN    NUMBER                                                  := FND_API.G_MISS_NUM
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
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_adv_action_set_id           IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_start_adv_action_set_flag   IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
 ,p_adv_action_set_name         IN    pa_action_sets.action_set_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_bill_rate_override          IN  pa_project_assignments.bill_rate_override%TYPE            := FND_API.G_MISS_NUM
 ,p_bill_rate_curr_override     IN  pa_project_assignments.bill_rate_curr_override%TYPE       := FND_API.G_MISS_CHAR
 ,p_markup_percent_override     IN  pa_project_assignments.markup_percent_override%TYPE       := FND_API.G_MISS_NUM
 ,p_discount_percentage         IN  pa_project_assignments.discount_percentage%TYPE           := FND_API.G_MISS_NUM
 ,p_rate_disc_reason_code       IN  pa_project_assignments.rate_disc_reason_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_tp_rate_override            IN  pa_project_assignments.tp_rate_override%TYPE              := FND_API.G_MISS_NUM
 ,p_tp_currency_override        IN  pa_project_assignments.tp_currency_override%TYPE          := FND_API.G_MISS_CHAR
 ,p_tp_calc_base_code_override  IN  pa_project_assignments.tp_calc_base_code_override%TYPE    := FND_API.G_MISS_CHAR
 ,p_tp_percent_applied_override IN  pa_project_assignments.tp_percent_applied_override%TYPE   := FND_API.G_MISS_NUM
 ,p_staffing_owner_person_id    IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM
 ,p_staffing_owner_name         IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_resource_list_member_id     IN  pa_project_assignments.resource_list_member_id%TYPE       := FND_API.G_MISS_NUM
 ,p_sum_tasks_flag				IN    VARCHAR2												  := FND_API.G_FALSE  -- FP.M Development
 ,p_budget_version_id			IN	  pa_resource_assignments.budget_version_id%TYPE  		  := FND_API.G_MISS_NUM
 ,p_attribute_category          IN    pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN    pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN    pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN    pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN    pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN    pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN    pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN    pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN    pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN    pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN    pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN    pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN    pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN    pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN    pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN    pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,p_number_of_requirements      IN    NUMBER                                                  := 1
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 -- 5130421 Begin
 ,p_comp_match_weighting         IN    pa_project_assignments.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,p_avail_match_weighting        IN    pa_project_assignments.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting    IN    pa_project_assignments.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_availability      IN    pa_project_assignments.search_min_availability%TYPE       := FND_API.G_MISS_NUM
 ,p_search_country_code          IN    pa_project_assignments.search_country_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN    pa_project_assignments.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_id      IN    pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_min_candidate_score   IN    pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag    IN    pa_project_assignments.enable_auto_cand_nom_flag%TYPE     := FND_API.G_MISS_CHAR
  -- 5130421 End
  ,x_new_assignment_id_tbl       OUT   NOCOPY system.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_new_assignment_id           OUT   NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT   NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT   NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_resource_id                 OUT   NOCOPY pa_resources.resource_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- ----------------------------------------------------------------------------
-- |----------------------------<Create_Assignment>----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	Creates or validates for creation of a requirement or an assignment record and all of  its detail records.
-- Prerequisites:
--
-- In Parameters:
--   Name                         Reqd Type               Description
-- p_assignment_rec               Y    Assignment_Rec_Type A record type defined in this package, use to hold
--                                                           information concerning the requirment/assignment to be
--							     created.
-- p_asgn_creation_mode                  VARCHAR2         Indicates whether the assignment creation is FULL or
--                                                          PARTIAL. Defaults to 'FULL'
-- p_project_name                 X      VARCHAR2         Required if p_project_number and p_project_id are null.
-- p_project_number               X      VARCHAR2         Required if p_project_id and p_project_name are null.
-- p_resource_name                X      VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id           X      NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_project_subteam_name                VARCHAR2         Name of the subteam
-- p_project_subteam_id                  NUMBER           Identifier of the subteam
-- p_project_status_name          X      VARCHAR2         Required if p_project_status_code is null.
-- p_project_role_name            X      VARCHAR2         Required if p_project_role_name is null.
-- p_location_city                       VARCHAR2         name of the city where the job is carried out.
-- p_location_region                     VARCHAR2         name of the region where the job is carried out.
-- p_location_country_name               VARCHAR2	  name of the country where the job is carried out.
-- p_location_country_code               VARCHAR2	  code of the country where the job is carried out.
-- p_calendar_name                X      VARCHAR2         Required if p_calendar_id is null.
-- p_work_type_name               X      VARCHAR2         Required if p_work_type_id is null.
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
--Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_new_assignment_id              NUMBER   System generated id of the requirement/assignment
-- x_assignment_number              NUMBER   System generated number of the requirement/assignment
-- x_assignment_row_id              ROWID    requirement/assignment row id
-- x_resource_id                    NUMBER   Identifier of the Project resource, it is null for a requirement
-- x_wf_type                        VARCHAR2 Type of the workflow that can be launched during an assignment
-- x_wf_item_type                   VARCHAR2 Item Type of the workflow during an assignment
-- x_wf_process                     VARCHAR2 Workflow process during an assignment
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Create_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
-- ,p_unfilled_assignment_status  IN     pa_project_assignments.status_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_project_name                IN    pa_projects_all.name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR
 ,p_resource_name               IN     pa_resources.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN     pa_project_subteams.project_subteam_id%TYPE     := FND_API.G_MISS_NUM
 ,p_project_subteam_name        IN     pa_project_subteams.name%TYPE                  := FND_API.G_MISS_CHAR
 ,p_project_status_name         IN     pa_project_statuses.project_status_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN     pa_lookups.meaning%TYPE                         := FND_API.G_MISS_CHAR
 ,p_project_role_name           IN     pa_project_role_types.meaning%TYPE              := FND_API.G_MISS_CHAR
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN     fnd_territories_tl.territory_short_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_calendar_name               IN     jtf_calendars_tl.calendar_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_work_type_name              IN     pa_work_types_vl.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_role_list_id                IN     pa_role_lists.role_list_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_adv_action_set_id           IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_start_adv_action_set_flag   IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_adv_action_set_name         IN     pa_action_sets.action_set_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_staffing_owner_name         IN     per_people_f.full_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_sum_tasks_flag				IN     VARCHAR2										   := FND_API.G_FALSE  -- FP.M Development
 ,p_budget_version_id			IN	   pa_resource_assignments.budget_version_id%TYPE  := FND_API.G_MISS_NUM
 ,p_number_of_requirements      IN     NUMBER                                          := 1
 ,p_api_version                 IN     NUMBER                                          := 1.0
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,x_new_assignment_id           OUT    NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT    NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_resource_id                 OUT    NOCOPY pa_resources.resource_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- ----------------------------------------------------------------------------
-- |----------------------------<Exec_Create_Assign_With_Def>----------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	Assign defaults from the role to the composite record, then call Create_Assign_With_Def with the record
--      to create a requirement or an assignment using scalar values passed in and the defaults from the role.
-- Prerequisites:
--
-- In Parameters:
--   Name                         Reqd   Type             Description
--
-- p_asgn_creation_mode                  VARCHAR2         Indicates whether the assignment creation is FULL or
--                                                          PARTIAL. Defaults to 'FULL'
-- p_role_name            	  X      VARCHAR2         Required if p_project_role_id is null.
-- p_assignment_type              Y      VARCHAR2         Indicates the type of the object for which status is shown.
--                                                          'OPEN_ASSIGNMENT'   => Requirement
--                                                          'STAFFED_ASSIGNMENT'=> Assignment/Project Assignment
--                                                          'STAFFED_ADMIN_ASSIGNMENT' => Administrative Assignment
-- p_multiple_status_flag         Y      VARCHAR2         Indicates whether the underlying schedule for the Assignment
--                                                          have more than one statuses. For requirement, use 'N'
-- p_project_id                   X      NUMBER           The identifier of the project to which this record belongs
--                                                          This is mandatory if p_project_number is null.
-- p_project_name                 X      VARCHAR2         Required if p_project_number and p_project_id are null.
-- p_project_number               X      VARCHAR2         Required if p_project_id and p_project_name are null.
-- p_project_role_id              X      NUMBER           Identifier of the project role for the record.
--                                                          This is mandatory if p_role_name is null.
-- p_resource_id                         NUMBER           Identifier of the project resource.
-- p_project_party_id                    NUMBER           The identifier of the project party on an assignment.
-- p_start_date                   Y      DATE             Start date of the requirement/assignment
-- p_end_date                     Y      DATE             End date of the requirement/assignment.
-- p_resource_name                X      VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id           X      NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
--Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_new_assignment_id              NUMBER   System generated id of the requirement/assignment
-- x_assignment_number              NUMBER   System generated number of the requirement/assignment
-- x_assignment_row_id              ROWID    requirement/assignment row id
-- x_resource_id                    NUMBER   Identifier of the Project resource, it is null for a requirement
-- x_wf_type                        VARCHAR2 Type of the workflow that can be launched during an assignment
-- x_wf_item_type                   VARCHAR2 Item Type of the workflow during an assignment
-- x_wf_process                     VARCHAR2 Workflow process during an assignment
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Exec_Create_Assign_With_Def
( p_asgn_creation_mode          IN    VARCHAR2                                                := 'FULL'
 ,p_role_name                   IN    pa_project_role_types.meaning%TYPE                      := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := 'N'
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_project_name                IN    pa_projects_all.name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR
 ,p_project_role_id             IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_resource_id                 IN    pa_resources.resource_id%TYPE                           := FND_API.G_MISS_NUM
 ,p_project_party_id            IN    pa_project_assignments.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_resource_name               IN    pa_resources.name%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN    per_all_people_f.person_id%TYPE                          := FND_API.G_MISS_NUM
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_new_assignment_id           OUT   NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT   NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT   NOCOPY ROWID --File.Sql.39 bug 4440895
-- ,x_wf_type                     OUT   VARCHAR2
-- ,x_wf_item_type                OUT   VARCHAR2
-- ,x_wf_process                  OUT   VARCHAR2
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- ----------------------------------------------------------------------------
-- |----------------------------< Create_Assign_With_Def>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	 Create a requirement or an assignment using the composite record passed in which contains role defaults and
--       additional scalar values.
-- Prerequisites:
--
-- In Parameters:
--   Name                         Reqd Type               Description
-- p_assignment_rec               Y    Assignment_Rec_Type A record type defined in this package, use to hold
--                                                           information concerning the requirment/assignment to be
--							     created.
-- p_role_name            	  X      VARCHAR2         Required if p_project_role_id is null.
-- p_asgn_creation_mode                  VARCHAR2         Indicates whether the assignment creation is FULL or
--                                                          PARTIAL. Defaults to 'FULL'
-- p_project_name                 X      VARCHAR2         Required if p_project_number and p_project_id are null.
-- p_project_number               X      VARCHAR2         Required if p_project_id and p_project_name are null.
-- p_resource_name                X      VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id           X      NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
--Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_new_assignment_id              NUMBER   System generated id of the requirement/assignment
-- x_assignment_number              NUMBER   System generated number of the requirement/assignment
-- x_assignment_row_id              ROWID    requirement/assignment row id
-- x_resource_id                    NUMBER   Identifier of the Project resource, it is null for a requirement
-- x_wf_type                        VARCHAR2 Type of the workflow that can be launched during an assignment
-- x_wf_item_type                   VARCHAR2 Item Type of the workflow during an assignment
-- x_wf_process                     VARCHAR2 Workflow process during an assignment
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Create_Assign_With_Def
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_role_name                   IN     pa_project_role_types.meaning%TYPE              := FND_API.G_MISS_CHAR
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
 ,p_project_name                IN     pa_projects_all.name%TYPE                       := FND_API.G_MISS_CHAR
 ,p_project_number              IN     pa_projects_all.segment1%TYPE                   := FND_API.G_MISS_CHAR
 ,p_resource_name               IN     pa_resources.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     per_all_people_f.person_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_api_version                 IN     NUMBER                                          := 1.0
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,x_new_assignment_id           OUT    NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT    NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
-- ,x_new_unfilled_assignment_id OUT    pa_project_assignments.assignment_id%TYPE
-- ,x_wf_type                     OUT    VARCHAR2
-- ,x_wf_item_type                OUT    VARCHAR2
-- ,x_wf_process                  OUT    VARCHAR2
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- ----------------------------------------------------------------------------
-- |---------------------<Execute_Staff_Assign_From_Open>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	Create an assignment on top of a requirement by assigning resource to the requirement. Staff_Assign_From_Open
--        is called to create the new assignment using defaults from the exisiting requirement and additional scalar
--        values (such as resource being assigned, start date and end date).
--
-- Prerequisites:
--
-- In Parameters:
--   Name                         Reqd   Type             Description
-- p_asgn_creation_mode                  VARCHAR2         Indicates whether the assignment creation is FULL or
--                                                          PARTIAL.
-- p_record_version_number        Y      NUMBER		  A number used to keep track how many updates have been done
--                                                          on this record.  Used to avoid overwrite the latest version
--                                                          of the record.
-- p_multiple_status_flag         Y      VARCHAR2         Indicates whether the underlying schedule for the Assignment
--                                                          have more than one statuses. For requirement, use 'N'
-- p_assignment_status_code       X      VARCHAR2         Status code for the assignment,required if status_name is null
-- p_assignment_status_name       X      VARCHAR2         Status name for the assignment,required if status_code is null
-- p_unfilled_assign_status_code         VARCHAR2         In the case of an partial assignment, this is the status code
--                                                          for the newly created requirement of the remaining duration.
-- p_unfilled_assign_status_name         VARCHAR2         Can be used in place of p_unfilled_assign_status_code.
-- p_resource_id                         NUMBER           Identifier of the project resource.
-- p_project_party_id                    NUMBER           The identifier of the project party on an assignment.
-- p_start_date                   Y      DATE             Start date of the requirement/assignment
-- p_end_date                     Y      DATE             End date of the requirement/assignment.
-- p_source_assignment_id         Y      NUMBER           The identifier of the source requirement where the resource is
--                                                          being assigned to.
-- p_resource_name                X      VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id           X      NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
--Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_new_assignment_id              NUMBER   System generated id of the requirement/assignment
-- x_assignment_number              NUMBER   System generated number of the requirement/assignment
-- x_assignment_row_id              ROWID    requirement/assignment row id
-- x_resource_id                    NUMBER   Identifier of the Project resource, it is null for a requirement
-- x_wf_type                        VARCHAR2 Type of the workflow that can be launched during an assignment
-- x_wf_item_type                   VARCHAR2 Item Type of the workflow during an assignment
-- x_wf_process                     VARCHAR2 Workflow process during an assignment
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Execute_Staff_Assign_From_Open
( p_asgn_creation_mode          IN    VARCHAR2                                                := 'FULL'
 ,p_record_version_number       IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_assignment_status_code      IN    pa_project_statuses.project_status_code%TYPE            := FND_API.G_MISS_CHAR
 ,p_assignment_status_name      IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_unfilled_assign_status_code  IN    pa_project_statuses.project_status_code%TYPE            := FND_API.G_MISS_CHAR
 ,p_unfilled_assign_status_name  IN    pa_project_statuses.project_status_name%TYPE       := FND_API.G_MISS_CHAR
 ,p_remaining_candidate_code    IN    pa_lookups.lookup_code%TYPE                             := FND_API.G_MISS_CHAR
 ,p_change_reason_code          IN    pa_lookups.lookup_code%TYPE                             := FND_API.G_MISS_CHAR
 ,p_resource_id                 IN    pa_resources.resource_id%TYPE                           := FND_API.G_MISS_NUM
 ,p_project_party_id            IN    pa_project_assignments.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_source_assignment_id        IN    pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_resource_name               IN    pa_resources.name%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_new_assignment_id           OUT   NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT   NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT   NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_resource_id                 OUT   NOCOPY pa_resources.resource_id%TYPE --File.Sql.39 bug 4440895
-- ,x_wf_type                     OUT   VARCHAR2
-- ,x_wf_item_type                OUT   VARCHAR2
-- ,x_wf_process                  OUT   VARCHAR2
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


-- ----------------------------------------------------------------------------
-- |----------------------------<Staff_Assign_From_Open>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	Create an assignment on top of an requirement by assigning a resource to the requirement. If it is an partial
--	  assignment, Create_Assignment is called to create a new requirement for the remaining duration if status code/
--	  name is given for the unfilled duration.
-- Prerequisites:
--
-- In Parameters:
--   Name                         Reqd   Type             Description
-- p_assignment_rec               Y    Assignment_Rec_Type A record type defined in this package, use to hold
--                                                           information concerning the requirment/assignment to be
--							     created.
-- p_asgn_creation_mode                  VARCHAR2         Indicates whether the assignment creation is FULL or
--                                                          PARTIAL.
-- p_unfilled_assign_status_code         VARCHAR2         In the case of an partial assignment, this is the status code
--                                                          for the newly created requirement of the remaining duration.
-- p_unfilled_assign_status_name         VARCHAR2         Can be used in place of p_unfilled_assign_status_code.
-- p_resource_name                X      VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id           X      NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_assignment_status_name       X      VARCHAR2         Status name for the assignment,required if status_code is null
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
--Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_new_assignment_id              NUMBER   System generated id of the requirement/assignment
-- x_assignment_number              NUMBER   System generated number of the requirement/assignment
-- x_assignment_row_id              ROWID    requirement/assignment row id
-- x_resource_id                    NUMBER   Identifier of the Project resource, it is null for a requirement
-- x_wf_type                        VARCHAR2 Type of the workflow that can be launched during an assignment
-- x_wf_item_type                   VARCHAR2 Item Type of the workflow during an assignment
-- x_wf_process                     VARCHAR2 Workflow process during an assignment
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Staff_Assign_From_Open
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
 ,p_unfilled_assign_status_code  IN pa_project_statuses.project_status_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_unfilled_assign_status_name  IN  pa_project_statuses.project_status_name%TYPE      := FND_API.G_MISS_CHAR
 ,p_remaining_candidate_code    IN    pa_lookups.lookup_code%TYPE                      := FND_API.G_MISS_CHAR
 ,p_change_reason_code          IN    pa_lookups.lookup_code%TYPE                      := FND_API.G_MISS_CHAR
 ,p_resource_name               IN     pa_resources.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_assignment_status_name         IN     pa_project_statuses.project_status_name%TYPE := FND_API.G_MISS_CHAR
 ,p_api_version                 IN     NUMBER                                          := 1.0
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,x_new_assignment_id           OUT    NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT    NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
--,x_new_unfilled_assignment_id OUT    pa_project_assignments.assignment_id%TYPE
 ,x_resource_id                 OUT    NOCOPY pa_resources.resource_id%TYPE --File.Sql.39 bug 4440895
-- ,x_wf_type                     OUT    VARCHAR2
-- ,x_wf_item_type                OUT    VARCHAR2
-- ,x_wf_process                  OUT    VARCHAR2
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

-- ----------------------------------------------------------------------------
-- |--------------------------<Execute_Update_Assignment>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	This API updates a requirement or an assignment from the scalar values passed to it. It loads the composite
--      record with scalar values and calls Update_Assignment.
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type             Description
-- p_assignment_row_id                   ROWID            Record row_id
-- p_assignment_id                  X    NUMBER           System generated number that uniquely identifiers the
--  							    requirement/assignment. Required if p_assignment_name is
--                                                          null.
-- p_record_version_number          Y    NUMBER           System generated version of row.  Increments by one with each
--                                                          update.
-- p_assignment_name                X    VARCHAR2         Required if p_assignment_id is null.
-- p_assignment_type                Y    VARCHAR2         Indicates the type of the object for which status is shown.
--                                                          'OPEN_ASSIGNMENT'   => Requirement
--                                                          'STAFFED_ASSIGNMENT'=> Assignment/Project Assignment
--                                                          'STAFFED_ADMIN_ASSIGNMENT' => Administrative Assignment
-- p_multiple_status_flag           Y    VARCHAR2         Indicates whether the underlying schedule for the Assignment
--                                                          have more than one statuses. For requirement, use 'N'
-- p_project_id                     X    NUMBER           The identifier of the project to which this record belongs
--                                                          This is mandatory if p_project_number is null.
-- p_project_role_id                     NUMBER           Identifier of the project role for the record.
--                                                          This is mandatory if project_role_name is null.
-- p_resource_id                         NUMBER           Identifier of the project resource.
-- p_project_party_id                    NUMBER           The identifier of the project party on an assignment.
-- p_project_subteam_id                  NUMBER           The identifier for the project subteam to which this
--							     requirement/assignment belongs.
-- p_project_subteam_party_id            NUMBER           The identifier for the intermediate project subteam party
--                                                           that connects between the project subteam and the
--                                                           requirement/assignment.
-- p_description                         VARCHAR2         The free text description of the record.
-- p_assignment_effort                   NUMBER		  Total number of hours of the requirement/assignment
-- p_extension_possible                  VARCHAR2         Indicates whether it is possible to extend the
--       						    requirement/assignment.
-- p_source_assignment_id                NUMBER           Identifies the assignment from which this assignment record
--                                                          is originated.
-- p_min_resource_job_level              NUMBER           Indicates the minimum acceptable job level for a requirement.
-- p_max_resource_job_level	         NUMBER           Indidates the maximum acceptable job level for a requirement.
-- p_assignment_number                   NUMBER           A reference number that uniquely identifies a requirement.
-- p_additional_information              VARCHAR2         Free text for additional information on a record.
-- p_work_type_id                        NUMBER           Identifies the type of work being carried out. Gets defaulted
--                                                          from project setup for open assignment and from staffed
--                                                          assignments not created from an open assignment.Mandatory
--                                                          if work_type_name is null
-- p_location_id                         NUMBER           Identifier of the location of the assignment. For new
--                                                          assignments this column gets default value from the project
--                                                          setup.
-- p_revenue_currency_code               VARCHAR2         Currency code of the revenue
-- p_revenue_bill_rate                   NUMBER           Bill rate of the revenue
-- p_expense_owner                       VARCHAR2         Owner of the expense
-- p_expense_limit                       NUMBER           The maximum amount that expense owner is willing to pay.
-- p_expense_limit_currency_code         VARCHAR2         Currency code of the expense limit.
-- p_fcst_tp_amount_type		 VARCHAR2
-- p_fcst_job_id                         NUMBER
-- p_project_number               X      VARCHAR2         Required if p_project_id is null.
-- p_resource_name                       VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id                  NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_resource_id                         NUMBER           Identifier of the project resource.
-- p_project_subteam_name                VARCHAR2
-- p_project_role_name                   VARCHAR2         Required if p_project_role_id is null.
-- p_location_city                       VARCHAR2
-- p_location_region                     VARCHAR2
-- p_location_country_name               VARCHAR2
-- p_location_country_code               VARCHAR2
-- p_work_type_name                      VARCHAR2         Required if p_work_type_id is null.
-- p_attribute_category                  VARCHAR2	  Descriptive flexfield context field
-- p_attribute1                  	 VARCHAR2	  Descriptive flexfield segment
-- p_attribute2                  	 VARCHAR2
-- p_attribute3                 	 VARCHAR2
-- p_attribute4                		 VARCHAR2
-- p_attribute5                		 VARCHAR2
-- p_attribute6                   	 VARCHAR2
-- p_attribute7                 	 VARCHAR2
-- p_attribute8                  	 VARCHAR2
-- p_attribute9                 	 VARCHAR2
-- p_attribute10                 	 VARCHAR2
-- p_attribute11                 	 VARCHAR2
-- p_attribute12                  	 VARCHAR2
-- p_attribute13                	 VARCHAR2
-- p_attribute14                	 VARCHAR2
-- p_attribute15                 	 VARCHAR2
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
-- Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Execute_Update_Assignment
( p_asgn_update_mode            IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
 ,p_assignment_row_id           IN    ROWID                                                   := NULL
 ,p_assignment_id               IN    pa_project_assignments.assignment_id%TYPE               := FND_API.G_MISS_NUM
 ,p_record_version_number       IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_project_status_name         IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_status_code                 IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_staffing_priority_code      IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN    pa_project_assignments.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_project_role_id             IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_project_party_id            IN    pa_project_assignments.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
 ,p_project_subteam_party_id    IN    pa_project_subteam_parties.project_subteam_party_id%TYPE    := FND_API.G_MISS_NUM
 ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_assignment_effort           IN    pa_project_assignments.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN    pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_assignment_number           IN    pa_project_assignments.assignment_number%TYPE           := FND_API.G_MISS_NUM
 ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN    pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN    pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN    pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
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
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR/*2386679*/
 ,p_resource_name               IN    pa_resources.name%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_resource_id                 IN    pa_resources.resource_id%TYPE                           := FND_API.G_MISS_NUM
 ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_project_role_name           IN    pa_project_role_types.meaning%TYPE                      := FND_API.G_MISS_CHAR
 ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
 ,p_calendar_name               IN    jtf_calendars_tl.calendar_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_calendar_id                 IN    jtf_calendars_tl.calendar_id%TYPE                       := FND_API.G_MISS_NUM
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                              := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_comp_match_weighting        IN    pa_project_assignments.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,p_avail_match_weighting       IN    pa_project_assignments.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting   IN    pa_project_assignments.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE       := FND_API.G_MISS_NUM
 ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE              := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
 ,p_search_exp_org_hier_name    IN  per_organization_structures.name%TYPE                       := FND_API.G_MISS_CHAR
 ,p_search_exp_start_org_id      IN   pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_name    IN   hr_organization_units.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_search_min_candidate_score   IN   pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag    IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_bill_rate_override           IN  pa_project_assignments.bill_rate_override%TYPE            := FND_API.G_MISS_NUM
 ,p_bill_rate_curr_override      IN  pa_project_assignments.bill_rate_curr_override%TYPE       := FND_API.G_MISS_CHAR
 ,p_markup_percent_override      IN  pa_project_assignments.markup_percent_override%TYPE       := FND_API.G_MISS_NUM
 ,p_discount_percentage          IN  pa_project_assignments.discount_percentage%TYPE           := FND_API.G_MISS_NUM -- Bug 2531267
 ,p_rate_disc_reason_code        IN  pa_project_assignments.rate_disc_reason_code%TYPE         := FND_API.G_MISS_CHAR -- Bug 2531267
 ,p_tp_rate_override             IN  pa_project_assignments.tp_rate_override%TYPE              := FND_API.G_MISS_NUM
 ,p_tp_currency_override         IN  pa_project_assignments.tp_currency_override%TYPE          := FND_API.G_MISS_CHAR
 ,p_tp_calc_base_code_override   IN  pa_project_assignments.tp_calc_base_code_override%TYPE    := FND_API.G_MISS_CHAR
 ,p_tp_percent_applied_override  IN  pa_project_assignments.tp_percent_applied_override%TYPE   := FND_API.G_MISS_NUM
 ,p_staffing_owner_person_id     IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM
 ,p_staffing_owner_name          IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_resource_list_member_id     IN  pa_project_assignments.resource_list_member_id%TYPE       := FND_API.G_MISS_NUM
 ,p_attribute_category          IN    pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN    pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN    pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN    pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN    pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN    pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN    pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN    pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN    pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN    pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN    pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN    pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN    pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN    pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN    pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN    pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_context                     IN    VARCHAR2                                                := FND_API.G_MISS_CHAR -- Added for GSI PJR Enhancement bug 7693634
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);



-- Bug 8233045
-- procedure     : update_schedule
-- Purpose       : Same Procedure as above but invoked in bulk mode
--
PROCEDURE Execute_Update_Assignment_bulk (
  p_asgn_update_mode_tbl            IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_assignment_id_tbl               IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_record_version_number_tbl       IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_assignment_name_tbl             IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_assignment_type_tbl             IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_multiple_status_flag_tbl        IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_status_code_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_start_date_tbl                  IN    SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_end_date_tbl                    IN    SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_staffing_priority_code_tbl      IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_project_id_tbl                  IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_assignment_template_id_tbl      IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_project_subteam_id_tbl          IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_project_subteam_party_id_tbl    IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_description_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_extension_possible_tbl          IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_min_resource_job_level_tbl      IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_max_resource_job_level_tbl      IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_additional_information_tbl      IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_work_type_id_tbl                IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_project_role_id_tbl             IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL --Bug#9108007
 ,p_expense_owner_tbl               IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_expense_limit_tbl               IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_fcst_tp_amount_type_tbl         IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_fcst_job_id_tbl                 IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_fcst_job_group_id_tbl           IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_expenditure_org_id_tbl          IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_exp_organization_id_tbl         IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_expenditure_type_class_tbl      IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_expenditure_type_tbl            IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_project_subteam_name_tbl        IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_location_city_tbl               IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_location_region_tbl             IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_location_country_name_tbl       IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_calendar_name_tbl               IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_calendar_id_tbl                 IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_fcst_job_name_tbl               IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_fcst_job_group_name_tbl         IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_expenditure_org_name_tbl        IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_exp_organization_name_tbl       IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_comp_match_weighting_tbl        IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_avail_match_weighting_tbl       IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_job_level_match_weight_tbl      IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_search_min_availability_tbl     IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_search_country_code_tbl         IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_search_country_name_tbl         IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_search_exp_org_st_ver_id_tbl    IN   SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_search_exp_org_hier_name_tbl    IN   SYSTEM.PA_VARCHAR2_2000_TBL_TYPE     := NULL
 ,p_search_exp_start_org_id_tbl     IN   SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_search_exp_start_org_tbl        IN   SYSTEM.PA_VARCHAR2_2000_TBL_TYPE     := NULL
 ,p_search_min_candidate_sc_tbl     IN   SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_enable_auto_cand_nom_flg_tbl    IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE      := NULL
 ,p_bill_rate_override_tbl           IN  SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_bill_rate_curr_override_tbl      IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE     := NULL
 ,p_markup_percent_override_tbl      IN  SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_discount_percentage_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_rate_disc_reason_code_tbl        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE     := NULL
 ,p_tp_rate_override_tbl             IN  SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_tp_currency_override_tbl         IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE     := NULL
 ,p_staffing_owner_person_id_tbl     IN  SYSTEM.PA_NUM_TBL_TYPE               := NULL
 ,p_staffing_owner_name_tbl          IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE     := NULL
 ,p_resource_list_member_id_tbl      IN  SYSTEM.PA_NUM_TBL_TYPE               := NULL --Bug#9108007
 ,p_attribute_category_tbl          IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute1_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute2_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute3_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute4_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute5_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute6_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute7_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute8_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute9_tbl                  IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute10_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute11_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute12_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute13_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute14_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_attribute15_tbl                 IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_api_version_tbl                 IN    SYSTEM.PA_NUM_TBL_TYPE              := NULL
 ,p_init_msg_list_tbl               IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_commit_tbl                      IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_validate_only_tbl               IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,p_context_tbl                     IN    SYSTEM.PA_VARCHAR2_2000_TBL_TYPE    := NULL
 ,x_return_status_tbl               OUT   NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
 ,x_msg_count_tbl                   OUT   NOCOPY SYSTEM.PA_NUM_TBL_TYPE
 ,x_msg_data_tbl                    OUT   NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
 ,p_bulk_context                    IN    varchar2 := 'N'
);


-- ----------------------------------------------------------------------------
-- |-------------------------------<Update_Assignment>-------------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	Updates a requirement/assignment with the scalar values and a given composite record containing information for
--         the update.
--
--
-- Prerequisites:
--
-- In Parameters:
--   Name                         Reqd   Type             Description
-- p_assignment_rec               Y    Assignment_Rec_Type A record type defined in this package, use to hold
--                                                           information concerning the requirment/assignment to be
--							     created.

-- p_project_number               X      VARCHAR2         Required if project_id is null.
-- p_resource_name                       VARCHAR2         Required for an assignment and if p_resource_source_id is null
-- p_resource_source_id                  NUMBER           Person ID used by HR, used to staff an assignment.
--                                                          Required for an assignment
-- p_resource_id                         NUMBER           Identifier of the project resource.
-- p_project_subteam_id                  NUMBER           The identifier for the project subteam to which this
--							     requirement/assignment belongs.
-- p_project_subteam_party_id            NUMBER           The identifier for the intermediate project subteam party
--                                                           that connects between the project subteam and the
--                                                           requirement/assignment.
-- p_project_subteam_name                VARCHAR2
-- p_project_role_name                   VARCHAR2
-- p_location_city                       VARCHAR2
-- p_location_region                     VARCHAR2
-- p_location_country_name               VARCHAR2
-- p_location_country_code               VARCHAR2
-- p_work_type_name                      VARCHAR2
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
-- Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Update_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_update_mode            IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_project_number              IN     pa_projects_all.segment1%TYPE                   := FND_API.G_MISS_CHAR/*bug2386679*/
 ,p_resource_name               IN     pa_resources.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_resource_id                 IN     pa_resources.resource_id%TYPE                   := FND_API.G_MISS_NUM
 ,p_calendar_name               IN     jtf_calendars_tl.calendar_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_project_status_name         IN     pa_project_statuses.project_status_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_project_subteam_id          IN     pa_project_subteams.project_subteam_id%TYPE     := FND_API.G_MISS_NUM
 ,p_project_subteam_party_id    IN     pa_project_subteam_parties.project_subteam_party_id%TYPE  := FND_API.G_MISS_NUM
 ,p_project_subteam_name        IN     pa_project_subteams.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN     pa_lookups.meaning%TYPE                         := FND_API.G_MISS_CHAR
 ,p_project_role_name           IN     pa_project_role_types.meaning%TYPE              := FND_API.G_MISS_CHAR
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN     fnd_territories_tl.territory_short_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_work_type_name              IN     pa_work_types_vl.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN     per_jobs.name%TYPE                              := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN     per_job_groups.displayed_name%TYPE              := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN     per_organization_units.name%TYPE                := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN     per_organization_units.name%TYPE                := FND_API.G_MISS_CHAR
 ,p_search_country_name         IN     fnd_territories_vl.territory_short_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_search_exp_org_hier_name    IN   per_organization_structures.name%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_exp_start_org_name   IN     hr_organization_units.name%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_owner_name         IN     per_people_f.full_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_api_version                 IN     NUMBER                                          := 1
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_context                     IN     VARCHAR2                                        := FND_API.G_MISS_CHAR -- Added for GSI PJR Enhancement bug 7693634
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- ----------------------------------------------------------------------------
-- |--------------------------<Delete_Assignment>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	This API updates a requirement or an assignment from the scalar values passed to it. It loads the composite
--      record with scalar values and calls Update_Assignment.
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type             Description
-- p_assignment_row_id                   ROWID            Record row_id
-- p_assignment_id                  X    NUMBER           System generated number that uniquely identifiers the
--  							    requirement/assignment. Required if p_assignment_name is
--                                                          null.
-- p_record_version_number          Y    NUMBER           System generated version of row.  Increments by one with each
--                                                          update.
-- p_assignment_type                Y    VARCHAR2         Indicates the type of the object for which status is shown.
--                                                          'OPEN_ASSIGNMENT'   => Requirement
--                                                          'STAFFED_ASSIGNMENT'=> Assignment/Project Assignment
--                                                          'STAFFED_ADMIN_ASSIGNMENT' => Administrative Assignment
-- p_assignment_number                   NUMBER           A reference number that uniquely identifies a requirement.
-- p_calling_module                      VARCHAR2         Indicates which module is calling this delete requirement or
--                                                          assignment procedure.
-- p_api_version                         VARCHAR2         A NO Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
-- Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--
PROCEDURE Delete_Assignment
( p_assignment_row_id           IN     ROWID                                           := NULL
 ,p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE       := FND_API.G_MISS_NUM
 ,p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_assignment_type             IN     pa_project_assignments.assignment_type%TYPE     := FND_API.G_MISS_CHAR
 ,p_assignment_number           IN     pa_project_assignments.assignment_number%TYPE   := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_api_version                 IN     NUMBER                                          := 1.0
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- ----------------------------------------------------------------------------
-- |--------------------------<Copy_Team_Role>----------------------|
-- ----------------------------------------------------------------------------
--
-- {Start Of Comments}
--
-- Description:
-- 	This API creates a new requirement from an existing requirement or assignment.
-- Prerequisites:
--
-- In Parameters:
--   Name                           Reqd Type             Description
-- p_assignment_id                  X    NUMBER           System generated number that uniquely identifiers the
--  							    requirement/assignment.
--                                                          assignment procedure.
-- p_api_version                         VARCHAR2         A NOT Null field, defaults to '1.0'
-- p_init_msg_list                       VARCHAR2         'T' => Initialize message stack
--							  'F' => append to exisiting message stack
-- p_commit                              VARCHAR2         'F' => calling program does the database commit.
--							  'T' => This API does the database commit
-- p_validate_only                       VARCHAR2         'T' => perform validation only
--                                                        'F' => perform validation and DML
-- p_max_msg_count                       NUMBER            Optional. Indicates the maximum number of messages that can
--                                                           be put on the message stack.
-- Out Parameters:
--
--   The api will set the following out parameters:
--
--   Name                           Type     Description
--
-- x_new_assignment_id              NUMBER   System generated id of the requirement/assignment
-- x_assignment_number              NUMBER   System generated number of the requirement/assignment
-- x_assignment_row_id              ROWID    requirement/assignment row id
-- x_return_status                  VARCHAR2 Return Status: 'S' => Successful
--                                                          'E' => Error occured.
--                                                          'U' => Unexpected error occured.
-- x_msg_count                      NUMBER   Number of error count.
-- x_msg_data                       VARCHAR2 If only one error occurs, this parameter will contain the error message.
--
-- Access Status:
--   Public.
--
-- {End Of Comments}
--

PROCEDURE Copy_Team_Role
 (p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'COPY'
 ,p_api_version                 IN     NUMBER                                          := 1.0 /*bug2386679*/
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,x_new_assignment_id           OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

PROCEDURE Mass_Exec_Create_Assignments
( p_asgn_creation_mode          IN    VARCHAR2
 ,p_unfilled_assignment_status  IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_status_code                 IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN    pa_project_assignments.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_project_role_id             IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_role_list_id                IN    pa_role_lists.role_list_id%TYPE                         := FND_API.G_MISS_NUM
 ,p_resource_id_tbl             IN    system.pa_num_tbl_type                                  := NULL
 ,p_resource_name_tbl           IN    system.pa_varchar2_240_tbl_type                         := NULL
 ,p_resource_source_id_tbl      IN    system.pa_num_tbl_type                                  := NULL
 ,p_project_subteam_id          IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
 ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_assignment_effort           IN    pa_project_assignments.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN    pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN    pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN    pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN    pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
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
 ,p_calendar_type               IN    pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
 ,p_calendar_id	                IN    pa_project_assignments.calendar_id%TYPE	              := FND_API.G_MISS_NUM
 ,p_resource_calendar_percent   IN    pa_project_assignments.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
 ,p_project_name                IN    pa_projects_all.name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR
 ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_project_status_name         IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_project_role_name           IN    pa_project_role_types.meaning%TYPE                      := FND_API.G_MISS_CHAR
 ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
 ,p_calendar_name               IN    jtf_calendars_tl.calendar_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_attribute_category          IN    pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN    pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN    pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN    pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN    pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN    pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN    pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN    pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN    pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN    pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN    pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN    pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN    pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN    pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN    pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN    pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,p_number_of_requirements      IN    NUMBER                                                  := 1
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Mass_Create_Assignments
( p_asgn_creation_mode          IN    VARCHAR2
 ,p_unfilled_assignment_status  IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_status_code                 IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN    pa_project_assignments.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_project_role_id             IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_role_list_id                IN    pa_role_lists.role_list_id%TYPE                         := FND_API.G_MISS_NUM
 ,p_resource_id_tbl             IN    system.pa_num_tbl_type
 ,p_project_subteam_id          IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
 ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_assignment_effort           IN    pa_project_assignments.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN    pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN    pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN    pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN    pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
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
 ,p_calendar_type               IN    pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
 ,p_calendar_id	                IN    pa_project_assignments.calendar_id%TYPE	              := FND_API.G_MISS_NUM
 ,p_resource_calendar_percent   IN    pa_project_assignments.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
 ,p_project_name                IN    pa_projects_all.name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR
 ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_project_status_name         IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_project_role_name           IN    pa_project_role_types.meaning%TYPE                      := FND_API.G_MISS_CHAR
 ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
 ,p_calendar_name               IN    jtf_calendars_tl.calendar_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_attribute_category          IN    pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN    pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN    pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN    pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN    pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN    pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN    pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN    pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN    pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN    pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN    pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN    pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN    pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN    pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN    pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN    pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,p_number_of_requirements      IN    NUMBER                                                  := 1
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_success_assignment_id_tbl   OUT   NOCOPY system.pa_num_tbl_type  -- For 1159 mandate changes bug#2674619
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);



PROCEDURE Mass_Exec_Update_Assignments
( p_asgn_update_mode            IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
 ,p_assignment_id_tbl           IN    system.pa_num_tbl_type
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE      := FND_API.G_MISS_CHAR
 ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE      := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
 ,p_append_description_flag     IN    VARCHAR2                                                := 'N'
 ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_append_information_flag     IN    VARCHAR2                                                := 'N'
 ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
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
 ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                              := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_comp_match_weighting        IN    pa_project_assignments.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,p_avail_match_weighting       IN    pa_project_assignments.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting   IN    pa_project_assignments.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE       := FND_API.G_MISS_NUM
 ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE              := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
 ,p_search_exp_org_hier_name    IN  per_organization_structures.name%TYPE                       := FND_API.G_MISS_CHAR
 ,p_search_exp_start_org_id      IN   pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_name    IN   hr_organization_units.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_search_min_candidate_score   IN   pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag     IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_staffing_owner_person_id     IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM
 ,p_staffing_owner_name          IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_attribute_category          IN    pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN    pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN    pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN    pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN    pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN    pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN    pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN    pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN    pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN    pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN    pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN    pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN    pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN    pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN    pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN    pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);



PROCEDURE Mass_Update_Assignments
( p_update_mode                 IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
 ,p_assignment_id_tbl           IN    system.pa_num_tbl_type
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
 ,p_append_description_flag     IN    VARCHAR2                                                := 'N'
 ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_append_information_flag     IN    VARCHAR2                                                := 'N'
 ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
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
 ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                              := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_comp_match_weighting        IN    pa_project_assignments.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,p_avail_match_weighting       IN    pa_project_assignments.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting   IN    pa_project_assignments.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE       := FND_API.G_MISS_NUM
 ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE              := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
 ,p_search_exp_org_hier_name    IN  per_organization_structures.name%TYPE                       := FND_API.G_MISS_CHAR
 ,p_search_exp_start_org_id      IN   pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_name    IN   hr_organization_units.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_search_min_candidate_score   IN   pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag     IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE  := FND_API.G_MISS_CHAR
 ,p_staffing_owner_person_id     IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM       --FP.L Development
 ,p_staffing_owner_name          IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR      --FP.L Development
 ,p_attribute_category          IN    pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN    pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN    pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN    pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN    pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN    pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN    pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN    pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN    pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN    pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN    pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN    pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN    pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN    pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN    pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN    pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_success_assignment_id_tbl   OUT   NOCOPY system.pa_num_tbl_type  -- For 1159 mandate changes bug#2674619
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Execute_Update_Requirement
( p_asgn_update_mode            IN    VARCHAR2                                                := FND_API.G_MISS_CHAR
 ,p_assignment_row_id           IN    ROWID                                                   := NULL
 ,p_assignment_id               IN    pa_project_assignments.assignment_id%TYPE               := FND_API.G_MISS_NUM
 ,p_record_version_number       IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_assignment_name             IN    pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN    pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_project_status_name         IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_status_code                 IN    pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_start_date                  IN    pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN    pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_staffing_priority_code      IN    pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN    pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN    pa_project_assignments.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_project_role_id             IN    pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_project_party_id            IN    pa_project_assignments.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN    pa_project_subteams.project_subteam_id%TYPE             := FND_API.G_MISS_NUM
 ,p_project_subteam_party_id    IN    pa_project_subteam_parties.project_subteam_party_id%TYPE    := FND_API.G_MISS_NUM
 ,p_description                 IN    pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_assignment_effort           IN    pa_project_assignments.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN    pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN    pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN    pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_assignment_number           IN    pa_project_assignments.assignment_number%TYPE           := FND_API.G_MISS_NUM
 ,p_additional_information      IN    pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_location_id                 IN    pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_work_type_id                IN    pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN    pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN    pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN    pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
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
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                           := FND_API.G_MISS_CHAR /* Bug 1851096 */
 ,p_resource_name               IN    pa_resources.name%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_resource_id                 IN    pa_resources.resource_id%TYPE                           := FND_API.G_MISS_NUM
 ,p_project_subteam_name        IN    pa_project_subteams.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_project_role_name           IN    pa_project_role_types.meaning%TYPE                      := FND_API.G_MISS_CHAR
 ,p_location_city               IN    pa_locations.city%TYPE                                  := FND_API.G_MISS_CHAR
 ,p_location_region             IN    pa_locations.region%TYPE                                := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN    fnd_territories_tl.territory_short_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN    pa_locations.country_code%TYPE                          := FND_API.G_MISS_CHAR
 ,p_calendar_name               IN    jtf_calendars_tl.calendar_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_calendar_id                 IN    jtf_calendars_tl.calendar_id%TYPE                       := FND_API.G_MISS_NUM
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                              := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_comp_match_weighting        IN    pa_project_assignments.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,p_avail_match_weighting       IN    pa_project_assignments.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting   IN    pa_project_assignments.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE       := FND_API.G_MISS_NUM
 ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_country_name         IN    fnd_territories_vl.territory_short_name%TYPE              := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
 ,p_search_exp_org_hier_name    IN  per_organization_structures.name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_search_exp_start_org_id     IN   pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_name   IN   hr_organization_units.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_search_min_candidate_score  IN   pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag    IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_bill_rate_override           IN  pa_project_assignments.bill_rate_override%TYPE            := FND_API.G_MISS_NUM
 ,p_bill_rate_curr_override      IN  pa_project_assignments.bill_rate_curr_override%TYPE       := FND_API.G_MISS_CHAR
 ,p_markup_percent_override      IN  pa_project_assignments.markup_percent_override%TYPE       := FND_API.G_MISS_NUM
 ,p_discount_percentage          IN  pa_project_assignments.discount_percentage%TYPE           := FND_API.G_MISS_NUM -- Bug 2590938
 ,p_rate_disc_reason_code        IN  pa_project_assignments.rate_disc_reason_code%TYPE         := FND_API.G_MISS_CHAR -- Bug 2590938
 ,p_tp_rate_override             IN  pa_project_assignments.tp_rate_override%TYPE              := FND_API.G_MISS_NUM
 ,p_tp_currency_override         IN  pa_project_assignments.tp_currency_override%TYPE          := FND_API.G_MISS_CHAR
 ,p_tp_calc_base_code_override   IN  pa_project_assignments.tp_calc_base_code_override%TYPE    := FND_API.G_MISS_CHAR
 ,p_tp_percent_applied_override  IN  pa_project_assignments.tp_percent_applied_override%TYPE   := FND_API.G_MISS_NUM
 ,p_staffing_owner_person_id     IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM
 ,p_staffing_owner_name          IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR
 ,p_attribute_category          IN    pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN    pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN    pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN    pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN    pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN    pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN    pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN    pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN    pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN    pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN    pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN    pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN    pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN    pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN    pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN    pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 ,p_api_version                 IN    NUMBER                                                  := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                                := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                                := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE DELETE_PJR_TXNS
 (p_project_id                  IN    pa_project_assignments.project_id%TYPE
    := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2
    := FND_API.G_MISS_CHAR
 ,p_api_version                 IN     NUMBER
    := 1.0
 ,p_init_msg_list               IN     VARCHAR2
    := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2
    := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2
    := FND_API.G_TRUE
 ,p_max_msg_count               IN     NUMBER
    := FND_API.G_MISS_NUM
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

 /* Added the procedure for bug 8557453 */
PROCEDURE VALIDATE_PROJECT_ROLE(
       p_assignment_id IN NUMBER,
       x_return_status OUT NOCOPY NUMBER);

END pa_assignments_pub;

/
