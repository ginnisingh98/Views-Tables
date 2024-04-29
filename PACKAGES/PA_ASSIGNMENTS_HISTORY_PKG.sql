--------------------------------------------------------
--  DDL for Package PA_ASSIGNMENTS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ASSIGNMENTS_HISTORY_PKG" AUTHID CURRENT_USER AS
/*$Header: PARAAPKS.pls 120.1 2005/08/19 16:47:06 mwasowic noship $*/

PROCEDURE Insert_Row
( p_assignment_id               IN   pa_assignments_history.assignment_id%TYPE               := FND_API.G_MISS_NUM
 ,p_assignment_name             IN   pa_assignments_history.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_number           IN   pa_assignments_history.assignment_number%TYPE           := FND_API.G_MISS_NUM
 ,p_assignment_type             IN   pa_assignments_history.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN   pa_assignments_history.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_record_version_number       IN   pa_assignments_history.record_version_number%TYPE       := FND_API.G_MISS_NUM
 ,p_apprvl_status_code          IN   pa_assignments_history.apprvl_status_code%TYPE          := FND_API.G_MISS_CHAR
 ,p_status_code                 IN   pa_assignments_history.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN   pa_assignments_history.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_staffing_owner_person_id    IN   pa_assignments_history.staffing_owner_person_id%TYPE    := FND_API.G_MISS_NUM
 ,p_project_id                  IN   pa_assignments_history.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_project_role_id             IN   pa_assignments_history.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_resource_id                 IN   pa_assignments_history.resource_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_project_party_id            IN   pa_assignments_history.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN   pa_assignments_history.project_subteam_id%TYPE          := FND_API.G_MISS_NUM
 ,p_description                 IN   pa_assignments_history.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_note_to_approver            IN   pa_assignments_history.note_to_approver%TYPE            := FND_API.G_MISS_CHAR
 ,p_start_date                  IN   pa_assignments_history.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN   pa_assignments_history.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_assignment_effort           IN   pa_assignments_history.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN   pa_assignments_history.extension_possible%TYPE     := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN   pa_assignments_history.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN   pa_assignments_history.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN   pa_assignments_history.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN   pa_assignments_history.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_additional_information      IN   pa_assignments_history.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_work_type_id                IN   pa_assignments_history.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN   pa_assignments_history.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN   pa_assignments_history.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_expense_owner               IN   pa_assignments_history.expense_owner%TYPE               := FND_API.G_MISS_CHAR
 ,p_expense_limit               IN   pa_assignments_history.expense_limit%TYPE               := FND_API.G_MISS_NUM
 ,p_expense_limit_currency_code IN   pa_assignments_history.expense_limit_currency_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fcst_tp_amount_type         IN   pa_assignments_history.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
 ,p_fcst_job_id                 IN   pa_assignments_history.fcst_job_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_fcst_job_group_id           IN   pa_assignments_history.fcst_job_group_id%TYPE           := FND_API.G_MISS_NUM
 ,p_expenditure_org_id          IN   pa_assignments_history.expenditure_org_id%TYPE          := FND_API.G_MISS_NUM
 ,p_expenditure_organization_id IN   pa_assignments_history.expenditure_organization_id%TYPE := FND_API.G_MISS_NUM
 ,p_expenditure_type_class      IN   pa_assignments_history.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
 ,p_expenditure_type            IN   pa_assignments_history.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_id                 IN   pa_assignments_history.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_calendar_type               IN   pa_assignments_history.calendar_type%TYPE               := FND_API.G_MISS_CHAR
 ,p_calendar_id	                IN   pa_assignments_history.calendar_id%TYPE	             := FND_API.G_MISS_NUM
 ,p_resource_calendar_percent   IN   pa_assignments_history.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
 ,p_attribute_category          IN   pa_assignments_history.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_pending_approval_flag       IN   pa_assignments_history.pending_approval_flag%TYPE       := FND_API.G_MISS_CHAR
 ,p_last_approved_flag          IN   pa_assignments_history.last_approved_flag%TYPE          := FND_API.G_MISS_CHAR
 ,p_no_of_active_candidates     IN   pa_assignments_history.no_of_active_candidates%TYPE     := FND_API.G_MISS_NUM
 ,p_comp_match_weighting        IN   pa_assignments_history.competence_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_avail_match_weighting       IN   pa_assignments_history.availability_match_weighting%TYPE := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting   IN   pa_assignments_history.job_level_match_weighting%TYPE   := FND_API.G_MISS_NUM
 ,p_search_min_availability     IN   pa_assignments_history.search_min_availability%TYPE     := FND_API.G_MISS_NUM
 ,p_search_country_code         IN   pa_assignments_history.search_country_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN  pa_assignments_history.search_exp_org_struct_ver_id%TYPE:= FND_API.G_MISS_NUM
 ,p_search_exp_start_org_id     IN   pa_assignments_history.search_exp_start_org_id%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_candidate_score  IN   pa_assignments_history.search_min_candidate_score%TYPE  := FND_API.G_MISS_NUM
 ,p_last_auto_search_date       IN   pa_assignments_history.last_auto_search_date%TYPE       := FND_API.G_MISS_DATE
 ,p_enable_auto_cand_nom_flag   IN   pa_assignments_history.enable_auto_cand_nom_flag%TYPE   := FND_API.G_MISS_CHAR
 ,p_mass_wf_in_progress_flag    IN   pa_assignments_history.mass_wf_in_progress_flag%TYPE    := FND_API.G_MISS_CHAR
 ,p_bill_rate_override          IN   pa_assignments_history.bill_rate_override%TYPE          := FND_API.G_MISS_NUM
 ,p_bill_rate_curr_override     IN   pa_assignments_history.bill_rate_curr_override%TYPE     := FND_API.G_MISS_CHAR
 ,p_markup_percent_override     IN   pa_assignments_history.markup_percent_override%TYPE     := FND_API.G_MISS_NUM
 ,p_tp_rate_override            IN   pa_assignments_history.tp_rate_override%TYPE            := FND_API.G_MISS_NUM
 ,p_tp_currency_override        IN   pa_assignments_history.tp_currency_override%TYPE        := FND_API.G_MISS_CHAR
 ,p_tp_calc_base_code_override  IN   pa_assignments_history.tp_calc_base_code_override%TYPE  := FND_API.G_MISS_CHAR
 ,p_tp_percent_applied_override IN   pa_assignments_history.tp_percent_applied_override%TYPE := FND_API.G_MISS_NUM
 ,p_markup_percent              IN   pa_assignments_history.markup_percent%TYPE              := FND_API.G_MISS_NUM
 ,p_attribute1                  IN   pa_assignments_history.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_assignments_history.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_assignments_history.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_assignments_history.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_assignments_history.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_assignments_history.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_assignments_history.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_assignments_history.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_assignments_history.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_assignments_history.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_assignments_history.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_assignments_history.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_assignments_history.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_assignments_history.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_assignments_history.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 /* Added 2 columns for 3051110 */
 ,p_transfer_price_rate         IN   pa_project_assignments.transfer_price_rate%TYPE         := FND_API.G_MISS_NUM
 ,p_transfer_pr_rate_curr       IN   pa_project_assignments.transfer_pr_rate_curr%TYPE       := FND_API.G_MISS_CHAR
  /* Added 2 columns for 3041583 */
 ,p_discount_percentage		IN   pa_assignments_history.discount_percentage%TYPE         := FND_API.G_MISS_NUM
 ,p_rate_disc_reason_code       IN   pa_assignments_history.rate_disc_reason_code%TYPE      := FND_API.G_MISS_CHAR
 ,x_assignment_row_id           OUT  NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_change_id                   OUT  NOCOPY pa_assignments_history.change_id%TYPE         --File.Sql.39 bug 4440895
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Update_Row
( p_assignment_row_id           IN   ROWID                                                   :=NULL
 ,p_assignment_id               IN   pa_assignments_history.assignment_id%TYPE
 ,p_change_id             IN   pa_assignments_history.change_id%TYPE	     :=NULL
 ,p_last_approved_flag          IN   pa_assignments_history.last_approved_flag%TYPE          :=NULL
 ,p_record_version_number       IN   pa_assignments_history.record_version_number%TYPE       := FND_API.G_MISS_NUM
 ,p_assignment_name             IN   pa_assignments_history.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN   pa_assignments_history.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN   pa_assignments_history.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_apprvl_status_code          IN   pa_assignments_history.apprvl_status_code%TYPE          := FND_API.G_MISS_CHAR
 ,p_status_code                 IN   pa_assignments_history.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN   pa_assignments_history.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_staffing_owner_person_id    IN   pa_assignments_history.staffing_owner_person_id%TYPE    := FND_API.G_MISS_NUM
 ,p_project_id                  IN   pa_assignments_history.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_project_role_id             IN   pa_assignments_history.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_project_party_id            IN   pa_assignments_history.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN   pa_assignments_history.project_subteam_id%TYPE          := FND_API.G_MISS_NUM
 ,p_description                 IN   pa_assignments_history.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_note_to_approver            IN   pa_assignments_history.note_to_approver%TYPE            := FND_API.G_MISS_CHAR
 ,p_start_date                  IN   pa_assignments_history.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN   pa_assignments_history.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_assignment_effort           IN   pa_assignments_history.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible     IN   pa_assignments_history.extension_possible%TYPE     := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN   pa_assignments_history.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN   pa_assignments_history.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN   pa_assignments_history.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN   pa_assignments_history.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_assignment_number           IN   pa_assignments_history.assignment_number%TYPE           := FND_API.G_MISS_NUM
 ,p_additional_information      IN   pa_assignments_history.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_work_type_id                IN   pa_assignments_history.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN   pa_assignments_history.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN   pa_assignments_history.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_expense_owner               IN   pa_assignments_history.expense_owner%TYPE               := FND_API.G_MISS_CHAR
 ,p_expense_limit               IN   pa_assignments_history.expense_limit%TYPE               := FND_API.G_MISS_NUM
 ,p_expense_limit_currency_code IN   pa_assignments_history.expense_limit_currency_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fcst_tp_amount_type         IN   pa_assignments_history.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
 ,p_fcst_job_id                 IN   pa_assignments_history.fcst_job_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_fcst_job_group_id           IN   pa_assignments_history.fcst_job_group_id%TYPE           := FND_API.G_MISS_NUM
 ,p_expenditure_org_id          IN   pa_assignments_history.expenditure_org_id%TYPE          := FND_API.G_MISS_NUM
 ,p_expenditure_organization_id IN   pa_assignments_history.expenditure_organization_id%TYPE := FND_API.G_MISS_NUM
 ,p_expenditure_type_class      IN   pa_assignments_history.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
 ,p_expenditure_type            IN   pa_assignments_history.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_id                 IN   pa_assignments_history.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_calendar_type               IN   pa_assignments_history.calendar_type%TYPE               := FND_API.G_MISS_CHAR
 ,p_calendar_id	                IN   pa_assignments_history.calendar_id%TYPE	             := FND_API.G_MISS_NUM
 ,p_resource_calendar_percent   IN   pa_assignments_history.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
 ,p_pending_approval_flag       IN   pa_assignments_history.pending_approval_flag%TYPE       := FND_API.G_MISS_CHAR
 ,p_no_of_active_candidates     IN   pa_assignments_history.no_of_active_candidates%TYPE     := FND_API.G_MISS_NUM
 ,p_attribute_category          IN   pa_assignments_history.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN   pa_assignments_history.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_assignments_history.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_assignments_history.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_assignments_history.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_assignments_history.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_assignments_history.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_assignments_history.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_assignments_history.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_assignments_history.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_assignments_history.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_assignments_history.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_assignments_history.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_assignments_history.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_assignments_history.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_assignments_history.attribute15%TYPE                 := FND_API.G_MISS_CHAR
 /* Added 2 columns for 3051110 */
 ,p_transfer_price_rate         IN   pa_project_assignments.transfer_price_rate%TYPE         := FND_API.G_MISS_NUM
 ,p_transfer_pr_rate_curr       IN   pa_project_assignments.transfer_pr_rate_curr%TYPE       := FND_API.G_MISS_CHAR
 /* Added 2 columns for 3041583 */
 ,p_discount_percentage		IN   pa_assignments_history.discount_percentage%TYPE         := FND_API.G_MISS_NUM
 ,p_rate_disc_reason_code       IN   pa_assignments_history.rate_disc_reason_code%TYPE       := FND_API.G_MISS_CHAR
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_Row
( p_assignment_row_id           IN   ROWID                                              := NULL
 ,p_assignment_id               IN   pa_assignments_history.assignment_id%TYPE
 ,p_change_id                   IN   pa_assignments_history.change_id%TYPE              := NULL
 ,p_last_approved_flag          IN   pa_assignments_history.last_approved_flag%TYPE     := NULL
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Delete_By_Assignment
( p_assignment_id		IN   pa_assignments_history.assignment_id%TYPE
 ,x_return_status		OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END PA_ASSIGNMENTS_HISTORY_PKG;

 

/
