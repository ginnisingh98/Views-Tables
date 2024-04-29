--------------------------------------------------------
--  DDL for Package Body PA_ASSIGNMENTS_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSIGNMENTS_HISTORY_PKG" AS
/*$Header: PARAAPKB.pls 120.1 2005/08/19 16:47:02 mwasowic noship $*/

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
)
IS

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INSERT INTO pa_assignments_history
       (assignment_id,
        assignment_name,
        assignment_type,
        multiple_status_flag,
        record_version_number,
        change_id,
        apprvl_status_code,
        status_code,
        staffing_priority_code,
        staffing_owner_person_id,
        project_id,
        project_role_id,
        project_party_id,
        project_subteam_id,
        description,
        note_to_approver,
        start_date,
        end_date,
        resource_id,
        assignment_effort,
        extension_possible,
        source_assignment_id,
        assignment_template_id,
        min_resource_job_level,
        max_resource_job_level,
        assignment_number,
        additional_information,
        work_type_id,
        revenue_currency_code,
        revenue_bill_rate,
        expense_owner,
        expense_limit,
        expense_limit_currency_code,
        fcst_tp_amount_type,
        fcst_job_id,
        fcst_job_group_id,
        expenditure_org_id,
        expenditure_organization_id,
        expenditure_type_class,
        expenditure_type,
        location_id,
        calendar_type,
        calendar_id,
        resource_calendar_percent,
        pending_approval_flag,
        last_approved_flag,
        no_of_active_candidates,
        competence_match_weighting,
        availability_match_weighting,
        job_level_match_weighting,
        search_min_availability,
        search_country_code,
        search_exp_org_struct_ver_id,
        search_exp_start_org_id,
        search_min_candidate_score,
        last_auto_search_date,
        enable_auto_cand_nom_flag,
        mass_wf_in_progress_flag,
        bill_rate_override,
        bill_rate_curr_override,
        markup_percent_override,
        tp_rate_override,
        tp_currency_override,
        tp_calc_base_code_override,
        tp_percent_applied_override,
        markup_percent,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
        transfer_price_rate,  --For bug 3051110
        transfer_pr_rate_curr,
	discount_percentage,  -- Added for bug 3041583
	rate_disc_reason_code -- Added for bug 3041583
	)
 VALUES
      ( DECODE(p_assignment_id, FND_API.G_MISS_NUM, NULL, p_assignment_id),
        DECODE(p_assignment_name, FND_API.G_MISS_CHAR, NULL, p_assignment_name),
        DECODE(p_assignment_type, FND_API.G_MISS_CHAR, NULL, p_assignment_type),
        DECODE(p_multiple_status_flag, FND_API.G_MISS_CHAR, NULL, p_multiple_status_flag),
        DECODE(p_record_version_number, FND_API.G_MISS_NUM, NULL, p_record_version_number),
        pa_assignments_history_s.NEXTVAL,
        DECODE(p_apprvl_status_code, FND_API.G_MISS_CHAR, NULL, p_apprvl_status_code),
        DECODE(p_status_code, FND_API.G_MISS_CHAR, NULL, p_status_code),
        DECODE(p_staffing_priority_code, FND_API.G_MISS_CHAR, NULL, p_staffing_priority_code),
        DECODE(p_staffing_owner_person_id, FND_API.G_MISS_NUM, NULL, p_staffing_owner_person_id),
        DECODE(p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id),
        DECODE(p_project_role_id, FND_API.G_MISS_NUM, NULL, p_project_role_id),
        DECODE(p_project_party_id, FND_API.G_MISS_NUM, NULL, p_project_party_id),
        DECODE(p_project_subteam_id, FND_API.G_MISS_NUM, NULL, p_project_subteam_id),
        DECODE(p_description, FND_API.G_MISS_CHAR, NULL, p_description),
        DECODE(p_note_to_approver, FND_API.G_MISS_CHAR, NULL, p_note_to_approver),
        DECODE(p_start_date, FND_API.G_MISS_DATE, NULL, p_start_date),
        DECODE(p_end_date, FND_API.G_MISS_DATE, NULL, p_end_date),
        DECODE(p_resource_id, FND_API.G_MISS_NUM, NULL, p_resource_id),
        DECODE(p_assignment_effort, FND_API.G_MISS_NUM, NULL, p_assignment_effort),
        DECODE(p_extension_possible, FND_API.G_MISS_CHAR, NULL, p_extension_possible),
        DECODE(p_source_assignment_id, FND_API.G_MISS_NUM, NULL, p_source_assignment_id),
        DECODE(p_assignment_template_id, FND_API.G_MISS_NUM, NULL, p_assignment_template_id),
        DECODE(p_min_resource_job_level, FND_API.G_MISS_NUM, NULL, p_min_resource_job_level),
        DECODE(p_max_resource_job_level, FND_API.G_MISS_NUM, NULL, p_max_resource_job_level),
        DECODE(p_assignment_number, FND_API.G_MISS_NUM, NULL, p_assignment_number),
        DECODE(p_additional_information, FND_API.G_MISS_CHAR, NULL, p_additional_information),
        DECODE(p_work_type_id, FND_API.G_MISS_NUM, NULL, p_work_type_id),
        DECODE(p_revenue_currency_code, FND_API.G_MISS_CHAR, NULL, p_revenue_currency_code),
        DECODE(p_revenue_bill_rate, FND_API.G_MISS_NUM, NULL, p_revenue_bill_rate),
        DECODE(p_expense_owner, FND_API.G_MISS_CHAR, NULL, p_expense_owner),
        DECODE(p_expense_limit, FND_API.G_MISS_NUM, NULL, p_expense_limit),
        DECODE(p_expense_limit_currency_code, FND_API.G_MISS_CHAR, NULL, p_expense_limit_currency_code),
        DECODE(p_fcst_tp_amount_type, FND_API.G_MISS_CHAR, NULL, p_fcst_tp_amount_type),
        DECODE(p_fcst_job_id, FND_API.G_MISS_NUM, NULL, p_fcst_job_id),
        DECODE(p_fcst_job_group_id, FND_API.G_MISS_NUM, NULL, p_fcst_job_group_id),
        DECODE(p_expenditure_org_id, FND_API.G_MISS_NUM, NULL, p_expenditure_org_id),
        DECODE(p_expenditure_organization_id, FND_API.G_MISS_NUM, NULL, p_expenditure_organization_id),
        DECODE(p_expenditure_type_class, FND_API.G_MISS_CHAR, NULL, p_expenditure_type_class),
        DECODE(p_expenditure_type, FND_API.G_MISS_CHAR, NULL, p_expenditure_type),
        DECODE(p_location_id, FND_API.G_MISS_NUM, NULL, p_location_id),
        DECODE(p_calendar_type, FND_API.G_MISS_CHAR, NULL, p_calendar_type),
        DECODE(p_calendar_id, FND_API.G_MISS_NUM, NULL, p_calendar_id),
        DECODE(p_resource_calendar_percent, FND_API.G_MISS_NUM, NULL, p_resource_calendar_percent),
        DECODE(p_pending_approval_flag, FND_API.G_MISS_CHAR, NULL, p_pending_approval_flag),
        DECODE(p_last_approved_flag, FND_API.G_MISS_CHAR, NULL, p_last_approved_flag),
        DECODE(p_no_of_active_candidates, FND_API.G_MISS_NUM, NULL, p_no_of_active_candidates),
        DECODE(p_comp_match_weighting, FND_API.G_MISS_NUM, NULL, p_comp_match_weighting),
        DECODE(p_avail_match_weighting, FND_API.G_MISS_CHAR, NULL, p_avail_match_weighting),
        DECODE(p_job_level_match_weighting, FND_API.G_MISS_NUM, NULL, p_job_level_match_weighting),
        DECODE(p_search_min_availability, FND_API.G_MISS_NUM, NULL, p_search_min_availability),
        DECODE(p_search_country_code, FND_API.G_MISS_CHAR, NULL, p_search_country_code),
        DECODE(p_search_exp_org_struct_ver_id, FND_API.G_MISS_NUM, NULL, p_search_exp_org_struct_ver_id),
        DECODE(p_search_exp_start_org_id, FND_API.G_MISS_NUM, NULL, p_search_exp_start_org_id),
        DECODE(p_search_min_candidate_score, FND_API.G_MISS_NUM, NULL, p_search_min_candidate_score),
        DECODE(p_last_auto_search_date, FND_API.G_MISS_DATE, NULL, p_last_auto_search_date),
        DECODE(p_enable_auto_cand_nom_flag, FND_API.G_MISS_CHAR, NULL, p_enable_auto_cand_nom_flag),
        DECODE(p_mass_wf_in_progress_flag, FND_API.G_MISS_CHAR, NULL, p_mass_wf_in_progress_flag),
        DECODE(p_bill_rate_override , FND_API.G_MISS_NUM, NULL, p_bill_rate_override ),
        DECODE(p_bill_rate_curr_override, FND_API.G_MISS_CHAR, NULL, p_bill_rate_curr_override),
        DECODE(p_markup_percent_override, FND_API.G_MISS_NUM, NULL, p_markup_percent_override),
        DECODE(p_tp_rate_override, FND_API.G_MISS_NUM, NULL, p_tp_rate_override),
        DECODE(p_tp_currency_override, FND_API.G_MISS_CHAR, NULL, p_tp_currency_override),
        DECODE(p_tp_calc_base_code_override, FND_API.G_MISS_CHAR, NULL, p_tp_calc_base_code_override),
        DECODE(p_tp_percent_applied_override, FND_API.G_MISS_NUM, NULL, p_tp_percent_applied_override),
        DECODE(p_markup_percent, FND_API.G_MISS_NUM, NULL, p_markup_percent),
        DECODE(p_attribute_category, FND_API.G_MISS_CHAR, NULL, p_attribute_category),
        DECODE(p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1),
        DECODE(p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2),
        DECODE(p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3),
        DECODE(p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4),
        DECODE(p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5),
        DECODE(p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6),
        DECODE(p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7),
        DECODE(p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8),
        DECODE(p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9),
        DECODE(p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10),
        DECODE(p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11),
        DECODE(p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12),
        DECODE(p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13),
        DECODE(p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14),
        DECODE(p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15),
        sysdate,
        fnd_global.user_id,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        DECODE(p_transfer_price_rate, FND_API.G_MISS_NUM, NULL, p_transfer_price_rate),  -- Added for 3051110
        DECODE(p_transfer_pr_rate_curr, FND_API.G_MISS_CHAR, NULL, p_transfer_pr_rate_curr),
	DECODE(p_discount_percentage, FND_API.G_MISS_NUM, NULL, p_discount_percentage),  -- Added for 3041583
	DECODE(p_rate_disc_reason_code, FND_API.G_MISS_CHAR, NULL, p_rate_disc_reason_code) -- Added for 3041583
   )

   RETURNING rowid, change_id INTO x_assignment_row_id, x_change_id;

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_HISTORY_PKG.Insert_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Insert_Row;


PROCEDURE Update_Row
( p_assignment_row_id           IN   ROWID                                                   :=NULL
 ,p_assignment_id               IN   pa_assignments_history.assignment_id%TYPE
 ,p_change_id                   IN   pa_assignments_history.change_id%TYPE	             :=NULL
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
 ,p_extension_possible          IN   pa_assignments_history.extension_possible%TYPE          := FND_API.G_MISS_CHAR
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
 ,p_rate_disc_reason_code       IN   pa_assignments_history.rate_disc_reason_code%TYPE      := FND_API.G_MISS_CHAR
 ,x_return_status               OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)IS


 l_row_id  ROWID := p_assignment_row_id;


CURSOR get_row_id IS
SELECT rowid
FROM   pa_assignments_history
WHERE  assignment_id = p_assignment_id
AND last_approved_flag = nvl(p_last_approved_flag, last_approved_flag)
AND change_id = nvl(p_change_id, change_id);

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

/*
  -- Lock the row first
  SELECT rowid  INTO l_row_id
  FROM pa_assignments_history
  WHERE assignment_id = p_assignment_id
  OR    rowid = p_assignment_row_id
  FOR  UPDATE NOWAIT;
*/


--get the ROWID for the row to be updated if
--p_assignment_row_id is not passed to the API.

IF l_row_id IS NULL THEN

  OPEN get_row_id;

  FETCH get_row_id INTO l_row_id;

  CLOSE get_row_id;

END IF;


  UPDATE pa_assignments_history
  SET assignment_name             = DECODE(p_assignment_name, FND_API.G_MISS_CHAR, assignment_name, p_assignment_name),
      assignment_type             = DECODE(p_assignment_type, FND_API.G_MISS_CHAR, assignment_type, p_assignment_type),
      change_id                   = DECODE(p_change_id, NULL, change_id, p_change_id),
      last_approved_flag          = DECODE(p_last_approved_flag,NULL, last_approved_flag, p_last_approved_flag),
      record_version_number       = DECODE(p_record_version_number,FND_API.G_MISS_NUM,record_version_number, p_record_version_number),
      multiple_status_flag        = DECODE(p_multiple_status_flag, FND_API.G_MISS_CHAR, multiple_status_flag, p_multiple_status_flag),
      apprvl_status_code          = DECODE(p_apprvl_status_code, FND_API.G_MISS_CHAR, apprvl_status_code, p_apprvl_status_code),
      status_code                 = DECODE(p_status_code, FND_API.G_MISS_CHAR, status_code, p_status_code),
      staffing_priority_code      = DECODE(p_staffing_priority_code, FND_API.G_MISS_CHAR, staffing_priority_code, p_staffing_priority_code),
      staffing_owner_person_id    = DECODE(p_staffing_owner_person_id, FND_API.G_MISS_NUM, staffing_owner_person_id, p_staffing_owner_person_id),
      project_id                  = DECODE(p_project_id, FND_API.G_MISS_NUM, project_id, p_project_id),
      project_role_id             = DECODE(p_project_role_id, FND_API.G_MISS_NUM, project_role_id, p_project_role_id),
      project_party_id            = DECODE(p_project_party_id, FND_API.G_MISS_NUM, project_party_id, p_project_party_id),
      project_subteam_id          = DECODE(p_project_subteam_id, FND_API.G_MISS_NUM, project_subteam_id, p_project_subteam_id),
      description                 = DECODE(p_description, FND_API.G_MISS_CHAR, description, p_description),
      note_to_approver            = DECODE(p_note_to_approver, FND_API.G_MISS_CHAR, note_to_approver, p_note_to_approver),
      start_date                  = DECODE(p_start_date, FND_API.G_MISS_DATE, start_date, p_start_date),
      end_date                    = DECODE(p_end_date, FND_API.G_MISS_DATE, end_date, p_end_date),
      assignment_effort           = DECODE(p_assignment_effort, FND_API.G_MISS_NUM, assignment_effort, p_assignment_effort),
      extension_possible          = DECODE(p_extension_possible, FND_API.G_MISS_CHAR, extension_possible, p_extension_possible),
      source_assignment_id        = DECODE(p_source_assignment_id, FND_API.G_MISS_NUM, source_assignment_id, p_source_assignment_id),
      assignment_template_id      = DECODE(p_assignment_template_id, FND_API.G_MISS_NUM, assignment_template_id, p_assignment_template_id),
      min_resource_job_level      = DECODE(p_min_resource_job_level, FND_API.G_MISS_NUM, min_resource_job_level, p_min_resource_job_level),
      max_resource_job_level      = DECODE(p_max_resource_job_level, FND_API.G_MISS_NUM, max_resource_job_level, p_max_resource_job_level),
      assignment_number           = DECODE(p_assignment_number, FND_API.G_MISS_NUM, assignment_number, p_assignment_number),
      additional_information      = DECODE(p_additional_information, FND_API.G_MISS_CHAR, additional_information, p_additional_information),
      work_type_id                = DECODE(p_work_type_id, FND_API.G_MISS_NUM, work_type_id, p_work_type_id),
      revenue_currency_code       = DECODE(p_revenue_currency_code, FND_API.G_MISS_CHAR, revenue_currency_code, p_revenue_currency_code),
      revenue_bill_rate           = DECODE(p_revenue_bill_rate, FND_API.G_MISS_NUM, revenue_bill_rate, p_revenue_bill_rate),
      expense_owner               = DECODE(p_expense_owner, FND_API.G_MISS_CHAR, expense_owner, p_expense_owner),
      expense_limit               = DECODE(p_expense_limit, FND_API.G_MISS_NUM, expense_limit, p_expense_limit),
      expense_limit_currency_code = DECODE(p_expense_limit_currency_code, FND_API.G_MISS_CHAR, expense_limit_currency_code, p_expense_limit_currency_code),
      fcst_tp_amount_type         = DECODE(p_fcst_tp_amount_type, FND_API.G_MISS_CHAR, fcst_tp_amount_type, p_fcst_tp_amount_type),
      fcst_job_id                 = DECODE(p_fcst_job_id, FND_API.G_MISS_NUM, fcst_job_id, p_fcst_job_id),
      fcst_job_group_id           = DECODE(p_fcst_job_group_id, FND_API.G_MISS_NUM,fcst_job_group_id, p_fcst_job_group_id),
      expenditure_org_id          = DECODE(p_expenditure_org_id, FND_API.G_MISS_NUM,expenditure_org_id , p_expenditure_org_id),
      expenditure_organization_id = DECODE(p_expenditure_organization_id, FND_API.G_MISS_NUM,expenditure_organization_id , p_expenditure_organization_id),
      expenditure_type_class      = DECODE(p_expenditure_type_class, FND_API.G_MISS_CHAR,expenditure_type_class , p_expenditure_type_class),
      expenditure_type            = DECODE(p_expenditure_type, FND_API.G_MISS_CHAR, expenditure_type, p_expenditure_type),
      location_id                 = DECODE(p_location_id, FND_API.G_MISS_NUM, location_id, p_location_id),
      calendar_type               = DECODE(p_calendar_type, FND_API.G_MISS_CHAR, calendar_type, p_calendar_type),
      calendar_id                 = DECODE(p_calendar_id, FND_API.G_MISS_NUM, calendar_id, p_calendar_id),
      resource_calendar_percent   = DECODE(p_resource_calendar_percent, FND_API.G_MISS_NUM, resource_calendar_percent, p_resource_calendar_percent),
      pending_approval_flag       = DECODE(p_pending_approval_flag, FND_API.G_MISS_CHAR, pending_approval_flag, p_pending_approval_flag),
      no_of_active_candidates     = DECODE(p_no_of_active_candidates, FND_API.G_MISS_NUM,no_of_active_candidates, p_no_of_active_candidates),
      attribute_category          = DECODE(p_attribute_category, FND_API.G_MISS_CHAR, attribute_category, p_attribute_category),
      attribute1                  = DECODE(p_attribute1, FND_API.G_MISS_CHAR, attribute1, p_attribute1),
      attribute2                  = DECODE(p_attribute2, FND_API.G_MISS_CHAR, attribute2, p_attribute2),
      attribute3                  = DECODE(p_attribute3, FND_API.G_MISS_CHAR, attribute3, p_attribute3),
      attribute4                  = DECODE(p_attribute4, FND_API.G_MISS_CHAR, attribute4, p_attribute4),
      attribute5                  = DECODE(p_attribute5, FND_API.G_MISS_CHAR, attribute5, p_attribute5),
      attribute6                  = DECODE(p_attribute6, FND_API.G_MISS_CHAR, attribute6, p_attribute6),
      attribute7                  = DECODE(p_attribute7, FND_API.G_MISS_CHAR, attribute7, p_attribute7),
      attribute8                  = DECODE(p_attribute8, FND_API.G_MISS_CHAR, attribute8, p_attribute8),
      attribute9                  = DECODE(p_attribute9, FND_API.G_MISS_CHAR, attribute9, p_attribute9),
      attribute10                 = DECODE(p_attribute10, FND_API.G_MISS_CHAR, attribute10, p_attribute10),
      attribute11                 = DECODE(p_attribute11, FND_API.G_MISS_CHAR, attribute11, p_attribute11),
      attribute12                 = DECODE(p_attribute12, FND_API.G_MISS_CHAR, attribute12, p_attribute12),
      attribute13                 = DECODE(p_attribute13, FND_API.G_MISS_CHAR, attribute13, p_attribute13),
      attribute14                 = DECODE(p_attribute14, FND_API.G_MISS_CHAR, attribute14, p_attribute14),
      attribute15                 = DECODE(p_attribute15, FND_API.G_MISS_CHAR, attribute15, p_attribute15),
      last_update_date            = sysdate,
      last_updated_by             = fnd_global.user_id,
      last_update_login           = fnd_global.login_id,
      transfer_price_rate         = DECODE(p_transfer_price_rate, FND_API.G_MISS_NUM, transfer_price_rate, p_transfer_price_rate), -- Added for 3051110
      transfer_pr_rate_curr       = DECODE(p_transfer_pr_rate_curr, FND_API.G_MISS_CHAR, transfer_pr_rate_curr, p_transfer_pr_rate_curr),
      discount_percentage	  = DECODE(p_discount_percentage, FND_API.G_MISS_NUM, NULL, p_discount_percentage),  -- Added for 3041583
      rate_disc_reason_code       = DECODE(p_rate_disc_reason_code, FND_API.G_MISS_CHAR, NULL, p_rate_disc_reason_code) -- Added for 3041583
      WHERE  rowid = l_row_id
      AND    nvl(p_change_id, change_id) = change_id;


  IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_HISTORY_PKG.Update_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Update_Row;


PROCEDURE Delete_Row
( p_assignment_row_id           IN    ROWID                                          :=NULL
 ,p_assignment_id               IN    pa_assignments_history.assignment_id%TYPE
 ,p_change_id                   IN     pa_assignments_history.change_id%TYPE         := NULL
 ,p_last_approved_flag          IN    pa_assignments_history.last_approved_flag%TYPE := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_row_id  ROWID;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;


/*
  -- Lock  the Assignment;
  SELECT rowid  INTO l_row_id
  FROM pa_assignments_history
  WHERE assignment_id = p_assignment_id
  FOR  UPDATE NOWAIT;
*/
  DELETE FROM  pa_assignments_history
  WHERE  assignment_id  = p_assignment_id
  AND    nvl (p_last_approved_flag, last_approved_flag)=last_approved_flag
  OR     rowid = p_assignment_row_id
  AND    nvl(p_change_id, change_id) = change_id;
  --
  IF (SQL%NOTFOUND) THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;
  --
  --

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the current program unit name in the error stack
--      PA_Error_Utils.Set_Error_Stack('PA_ASSIGNMENTS_HISTORY_PKG.Delete_Row');
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_HISTORY_PKG.Delete_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;



PROCEDURE Delete_By_Assignment
( p_assignment_id		IN   pa_assignments_history.assignment_id%TYPE
 ,x_return_status		OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;


/*
  -- Lock  the Assignment;
  SELECT rowid  INTO l_row_id
  FROM pa_assignments_history
  WHERE assignment_id = p_assignment_id
  FOR  UPDATE NOWAIT;
*/
  DELETE FROM  pa_assignments_history
  WHERE  assignment_id  = p_assignment_id;
  --
/*  IF (SQL%NOTFOUND) THEN

--dbms_output.put_line('Assignment not previously approved');
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;

       --No error, since possible that an assignment has not been previously approved.
  END IF;
*/
  --
  --

  EXCEPTION
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_HISTORY_PKG.Delete_By_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_By_Assignment;

--
--
END PA_ASSIGNMENTS_HISTORY_PKG;

/
