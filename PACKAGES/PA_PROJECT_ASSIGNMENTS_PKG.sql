--------------------------------------------------------
--  DDL for Package PA_PROJECT_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_ASSIGNMENTS_PKG" AUTHID CURRENT_USER AS
/*$Header: PARAPKGS.pls 120.1 2005/08/19 16:47:24 mwasowic noship $*/
--

PROCEDURE Insert_Row
( p_assignment_name             IN   pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN   pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN   pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_apprvl_status_code          IN   pa_project_assignments.apprvl_status_code%TYPE          := FND_API.G_MISS_CHAR
 ,p_status_code                 IN   pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN   pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN   pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_assignment_template_id      IN   pa_project_assignments.assignment_template_id%TYPE      := FND_API.G_MISS_NUM
 ,p_project_role_id             IN   pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_resource_id                 IN   pa_project_assignments.resource_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_project_party_id            IN   pa_project_assignments.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_description                 IN   pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_note_to_approver            IN   pa_project_assignments.note_to_approver%TYPE            := FND_API.G_MISS_CHAR
 ,p_start_date                  IN   pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN   pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_assignment_effort           IN   pa_project_assignments.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN   pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN   pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN   pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN   pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_additional_information      IN   pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_work_type_id                IN   pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN   pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN   pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN    pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
 ,p_expense_owner               IN   pa_project_assignments.expense_owner%TYPE               := FND_API.G_MISS_CHAR
 ,p_expense_limit               IN   pa_project_assignments.expense_limit%TYPE               := FND_API.G_MISS_NUM
 ,p_expense_limit_currency_code IN   pa_project_assignments.expense_limit_currency_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fcst_tp_amount_type         IN   pa_project_assignments.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
 ,p_fcst_job_id                 IN   pa_project_assignments.fcst_job_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_fcst_job_group_id           IN   pa_project_assignments.fcst_job_group_id%TYPE           := FND_API.G_MISS_NUM
 ,p_expenditure_org_id          IN   pa_project_assignments.expenditure_org_id%TYPE          := FND_API.G_MISS_NUM
 ,p_expenditure_organization_id IN   pa_project_assignments.expenditure_organization_id%TYPE := FND_API.G_MISS_NUM
 ,p_expenditure_type_class      IN   pa_project_assignments.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
 ,p_expenditure_type            IN   pa_project_assignments.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_id                 IN   pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_calendar_type               IN   pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
 ,p_calendar_id	                IN   pa_project_assignments.calendar_id%TYPE	             := FND_API.G_MISS_NUM
 ,p_resource_calendar_percent   IN   pa_project_assignments.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
 ,p_no_of_active_candidates     IN   pa_project_assignments.no_of_active_candidates%TYPE     := FND_API.G_MISS_NUM
 ,p_comp_match_weighting        IN   pa_project_assignments.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,p_avail_match_weighting       IN   pa_project_assignments.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting   IN   pa_project_assignments.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE       := FND_API.G_MISS_NUM
 ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_id     IN   pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_min_candidate_score  IN   pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag   IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_bill_rate_override           IN  pa_project_assignments.bill_rate_override%TYPE            := FND_API.G_MISS_NUM
 ,p_bill_rate_curr_override      IN  pa_project_assignments.bill_rate_curr_override%TYPE       := FND_API.G_MISS_CHAR
 ,p_markup_percent_override      IN  pa_project_assignments.markup_percent_override%TYPE       := FND_API.G_MISS_NUM
 ,p_discount_percentage          IN  pa_project_assignments.discount_percentage%TYPE           := FND_API.G_MISS_NUM -- FP.L Development
 ,p_rate_disc_reason_code        IN  pa_project_assignments.rate_disc_reason_code%TYPE         := FND_API.G_MISS_CHAR -- FP.L Development
 ,p_tp_rate_override             IN  pa_project_assignments.tp_rate_override%TYPE              := FND_API.G_MISS_NUM
 ,p_tp_currency_override         IN  pa_project_assignments.tp_currency_override%TYPE          := FND_API.G_MISS_CHAR
 ,p_tp_calc_base_code_override   IN  pa_project_assignments.tp_calc_base_code_override%TYPE    := FND_API.G_MISS_CHAR
 ,p_tp_percent_applied_override  IN  pa_project_assignments.tp_percent_applied_override%TYPE   := FND_API.G_MISS_NUM
 ,p_staffing_owner_person_id     IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM  -- FP.L Development
 ,p_resource_list_member_id     IN  pa_project_assignments.resource_list_member_id%TYPE       := FND_API.G_MISS_NUM   -- FP.M Development
 ,p_attribute_category          IN   pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN   pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
/* Added 2 columns for 3051110 */
 ,p_transfer_price_rate         IN   pa_project_assignments.transfer_price_rate%TYPE         := FND_API.G_MISS_NUM
 ,p_transfer_pr_rate_curr       IN   pa_project_assignments.transfer_pr_rate_curr%TYPE       := FND_API.G_MISS_CHAR
 ,p_number_of_requirements      IN   NUMBER                                                  := 1
 ,x_assignment_row_id           OUT  NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_new_assignment_id           OUT  NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT  NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Update_Row
( p_assignment_row_id           IN   ROWID                                                   :=NULL
 ,p_assignment_id               IN   pa_project_assignments.assignment_id%TYPE
 ,p_record_version_number       IN   NUMBER                                                  := NULL
 ,p_assignment_name             IN   pa_project_assignments.assignment_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_assignment_type             IN   pa_project_assignments.assignment_type%TYPE             := FND_API.G_MISS_CHAR
 ,p_multiple_status_flag        IN   pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_apprvl_status_code          IN   pa_project_assignments.apprvl_status_code%TYPE          := FND_API.G_MISS_CHAR
 ,p_status_code                 IN   pa_project_assignments.status_code%TYPE                 := FND_API.G_MISS_CHAR
 ,p_staffing_priority_code      IN   pa_project_assignments.staffing_priority_code%TYPE      := FND_API.G_MISS_CHAR
 ,p_project_id                  IN   pa_project_assignments.project_id%TYPE                  := FND_API.G_MISS_NUM
 ,p_assignment_template_id            IN   pa_project_assignments.assignment_template_id%TYPE             := FND_API.G_MISS_NUM
 ,p_project_role_id             IN   pa_project_assignments.project_role_id%TYPE             := FND_API.G_MISS_NUM
 ,p_resource_id                 IN   pa_project_assignments.resource_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_project_party_id            IN   pa_project_assignments.project_party_id%TYPE            := FND_API.G_MISS_NUM
 ,p_description                 IN   pa_project_assignments.description%TYPE                 := FND_API.G_MISS_CHAR
 ,p_note_to_approver            IN   pa_project_assignments.note_to_approver%TYPE            := FND_API.G_MISS_CHAR
 ,p_start_date                  IN   pa_project_assignments.start_date%TYPE                  := FND_API.G_MISS_DATE
 ,p_end_date                    IN   pa_project_assignments.end_date%TYPE                    := FND_API.G_MISS_DATE
 ,p_assignment_effort           IN   pa_project_assignments.assignment_effort%TYPE           := FND_API.G_MISS_NUM
 ,p_extension_possible          IN   pa_project_assignments.extension_possible%TYPE          := FND_API.G_MISS_CHAR
 ,p_source_assignment_id        IN   pa_project_assignments.source_assignment_id%TYPE        := FND_API.G_MISS_NUM
 ,p_min_resource_job_level      IN   pa_project_assignments.min_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_max_resource_job_level	IN   pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
 ,p_assignment_number           IN   pa_project_assignments.assignment_number%TYPE           := FND_API.G_MISS_NUM
 ,p_additional_information      IN   pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_work_type_id                IN   pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN   pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN   pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN    pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
 ,p_expense_owner               IN   pa_project_assignments.expense_owner%TYPE               := FND_API.G_MISS_CHAR
 ,p_expense_limit               IN   pa_project_assignments.expense_limit%TYPE               := FND_API.G_MISS_NUM
 ,p_expense_limit_currency_code IN   pa_project_assignments.expense_limit_currency_code%TYPE := FND_API.G_MISS_CHAR
 ,p_fcst_tp_amount_type         IN   pa_project_assignments.fcst_tp_amount_type%TYPE         := FND_API.G_MISS_CHAR
 ,p_fcst_job_id                 IN   pa_project_assignments.fcst_job_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_fcst_job_group_id           IN   pa_project_assignments.fcst_job_group_id%TYPE           := FND_API.G_MISS_NUM
 ,p_expenditure_org_id          IN   pa_project_assignments.expenditure_org_id%TYPE          := FND_API.G_MISS_NUM
 ,p_expenditure_organization_id IN   pa_project_assignments.expenditure_organization_id%TYPE := FND_API.G_MISS_NUM
 ,p_expenditure_type_class      IN   pa_project_assignments.expenditure_type_class%TYPE      := FND_API.G_MISS_CHAR
 ,p_expenditure_type            IN   pa_project_assignments.expenditure_type%TYPE            := FND_API.G_MISS_CHAR
 ,p_location_id                 IN   pa_project_assignments.location_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_calendar_type               IN   pa_project_assignments.calendar_type%TYPE               := FND_API.G_MISS_CHAR
 ,p_calendar_id	                IN   pa_project_assignments.calendar_id%TYPE	             := FND_API.G_MISS_NUM
 ,p_resource_calendar_percent   IN   pa_project_assignments.resource_calendar_percent%TYPE   := FND_API.G_MISS_NUM
 ,p_pending_approval_flag       IN   pa_project_assignments.pending_approval_flag%TYPE       := FND_API.G_MISS_CHAR
 ,p_no_of_active_candidates     IN   pa_project_assignments.no_of_active_candidates%TYPE     := FND_API.G_MISS_NUM
 ,p_comp_match_weighting        IN   pa_project_assignments.competence_match_weighting%TYPE    := FND_API.G_MISS_NUM
 ,p_avail_match_weighting       IN   pa_project_assignments.availability_match_weighting%TYPE  := FND_API.G_MISS_NUM
 ,p_job_level_match_weighting   IN   pa_project_assignments.job_level_match_weighting%TYPE     := FND_API.G_MISS_NUM
 ,p_search_min_availability     IN    pa_project_assignments.search_min_availability%TYPE       := FND_API.G_MISS_NUM
 ,p_search_country_code         IN    pa_project_assignments.search_country_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_search_exp_org_struct_ver_id IN   pa_project_assignments.search_exp_org_struct_ver_id%TYPE  := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_id     IN   pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_min_candidate_score  IN   pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag   IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_bill_rate_override           IN  pa_project_assignments.bill_rate_override%TYPE            := FND_API.G_MISS_NUM
 ,p_bill_rate_curr_override      IN  pa_project_assignments.bill_rate_curr_override%TYPE       := FND_API.G_MISS_CHAR
 ,p_markup_percent_override      IN  pa_project_assignments.markup_percent_override%TYPE       := FND_API.G_MISS_NUM
 ,p_discount_percentage          IN  pa_project_assignments.discount_percentage%TYPE           := FND_API.G_MISS_NUM  -- Bug 2590938
 ,p_rate_disc_reason_code        IN  pa_project_assignments.rate_disc_reason_code%TYPE         := FND_API.G_MISS_CHAR -- Bug 2590938
 ,p_tp_rate_override             IN  pa_project_assignments.tp_rate_override%TYPE              := FND_API.G_MISS_NUM
 ,p_tp_currency_override         IN  pa_project_assignments.tp_currency_override%TYPE          := FND_API.G_MISS_CHAR
 ,p_tp_calc_base_code_override   IN  pa_project_assignments.tp_calc_base_code_override%TYPE    := FND_API.G_MISS_CHAR
 ,p_tp_percent_applied_override  IN  pa_project_assignments.tp_percent_applied_override%TYPE   := FND_API.G_MISS_NUM
 ,p_staffing_owner_person_id     IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM
 ,p_resource_list_member_id      IN  pa_project_assignments.resource_list_member_id%TYPE       := FND_API.G_MISS_NUM
 ,p_attribute_category          IN   pa_project_assignments.attribute_category%TYPE          := FND_API.G_MISS_CHAR
 ,p_attribute1                  IN   pa_project_assignments.attribute1%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute2                  IN   pa_project_assignments.attribute2%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute3                  IN   pa_project_assignments.attribute3%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute4                  IN   pa_project_assignments.attribute4%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute5                  IN   pa_project_assignments.attribute5%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute6                  IN   pa_project_assignments.attribute6%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute7                  IN   pa_project_assignments.attribute7%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute8                  IN   pa_project_assignments.attribute8%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute9                  IN   pa_project_assignments.attribute9%TYPE                  := FND_API.G_MISS_CHAR
 ,p_attribute10                 IN   pa_project_assignments.attribute10%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute11                 IN   pa_project_assignments.attribute11%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute12                 IN   pa_project_assignments.attribute12%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute13                 IN   pa_project_assignments.attribute13%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute14                 IN   pa_project_assignments.attribute14%TYPE                 := FND_API.G_MISS_CHAR
 ,p_attribute15                 IN   pa_project_assignments.attribute15%TYPE                 := FND_API.G_MISS_CHAR
/* Added 2 columns for 3051110 */
 ,p_transfer_price_rate         IN   pa_project_assignments.transfer_price_rate%TYPE         := FND_API.G_MISS_NUM
 ,p_transfer_pr_rate_curr       IN   pa_project_assignments.transfer_pr_rate_curr%TYPE       := FND_API.G_MISS_CHAR
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

PROCEDURE Delete_Row
( p_assignment_row_id           IN    ROWID
 ,p_assignment_id               IN    pa_project_assignments.assignment_id%TYPE
 ,p_record_version_number       IN    NUMBER                                                := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


PROCEDURE Lock_Row
( p_assignment_row_id           IN   ROWID
 ,p_assignment_id               IN   pa_project_assignments.assignment_id%TYPE
 ,p_record_version_number       IN   NUMBER                                                := NULL
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


END pa_project_assignments_pkg;

 

/
