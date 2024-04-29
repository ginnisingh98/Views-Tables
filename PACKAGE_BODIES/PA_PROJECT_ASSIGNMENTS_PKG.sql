--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_ASSIGNMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_ASSIGNMENTS_PKG" AS
/*$Header: PARAPKGB.pls 120.1 2005/08/19 16:47:19 mwasowic noship $*/
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
)
IS

 TYPE  assignment_id          IS TABLE OF  pa_project_assignments.assignment_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_assignment_id              assignment_id;
 TYPE  assignment_name        IS TABLE OF  pa_project_assignments.assignment_name%TYPE
                              INDEX BY BINARY_INTEGER;
 l_assignment_name            assignment_name;
 TYPE  assignment_number      IS TABLE OF  pa_project_assignments.assignment_number%TYPE
                              INDEX BY BINARY_INTEGER;
 l_assignment_number          assignment_number;
 TYPE assignment_type         IS TABLE OF  pa_project_assignments.assignment_type%TYPE
                              INDEX BY BINARY_INTEGER;
 l_assignment_type            assignment_type;
 TYPE multiple_status_flag    IS TABLE OF  pa_project_assignments.multiple_status_flag%TYPE
                              INDEX BY BINARY_INTEGER;
 l_multiple_status_flag       multiple_status_flag;
 TYPE apprvl_status_code      IS TABLE OF  pa_project_assignments.apprvl_status_code%TYPE
                              INDEX BY BINARY_INTEGER;
 l_apprvl_status_code         apprvl_status_code;
 TYPE status_code             IS TABLE OF  pa_project_assignments.status_code%TYPE
                              INDEX BY BINARY_INTEGER;
 l_status_code                status_code;
 TYPE staffing_priority_code  IS TABLE OF  pa_project_assignments.staffing_priority_code%TYPE
                              INDEX BY BINARY_INTEGER;
 l_staffing_priority_code     staffing_priority_code;
 TYPE project_id              IS TABLE OF  pa_project_assignments.project_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_project_id                 project_id;
 TYPE assignment_template_id  IS TABLE OF  pa_project_assignments.assignment_template_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_assignment_template_id     assignment_template_id;
 TYPE project_role_id         IS TABLE OF  pa_project_assignments.project_role_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_project_role_id            project_role_id;
 TYPE resource_id             IS TABLE OF  pa_project_assignments.resource_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_resource_id                resource_id;
 TYPE project_party_id        IS TABLE OF  pa_project_assignments.project_party_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_project_party_id           project_party_id;
 TYPE description             IS TABLE OF  pa_project_assignments.description%TYPE
                              INDEX BY BINARY_INTEGER;
 l_description                description;
 TYPE note_to_approver        IS TABLE OF  pa_project_assignments.note_to_approver%TYPE
                              INDEX BY BINARY_INTEGER;
 l_note_to_approver           note_to_approver;
 TYPE start_date              IS TABLE OF  pa_project_assignments.start_date%TYPE
                              INDEX BY BINARY_INTEGER;
 l_start_date                 start_date;
 TYPE end_date                IS TABLE OF  pa_project_assignments.end_date%TYPE
                              INDEX BY BINARY_INTEGER;
 l_end_date                   end_date;
 TYPE assignment_effort       IS TABLE OF  pa_project_assignments.assignment_effort%TYPE
                              INDEX BY BINARY_INTEGER;
 l_assignment_effort          assignment_effort;
 TYPE extension_possible      IS TABLE OF  pa_project_assignments.extension_possible%TYPE
                              INDEX BY BINARY_INTEGER;
 l_extension_possible         extension_possible;
 TYPE source_assignment_id    IS TABLE OF  pa_project_assignments.source_assignment_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_source_assignment_id       source_assignment_id;
 TYPE min_resource_job_level  IS TABLE OF  pa_project_assignments.min_resource_job_level%TYPE
                              INDEX BY BINARY_INTEGER;
 l_min_resource_job_level     min_resource_job_level;
 TYPE max_resource_job_level  IS TABLE OF  pa_project_assignments.max_resource_job_level%TYPE
                              INDEX BY BINARY_INTEGER;
 l_max_resource_job_level     max_resource_job_level;
 TYPE additional_information  IS TABLE OF  pa_project_assignments.additional_information%TYPE
                              INDEX BY BINARY_INTEGER;
 l_additional_information     additional_information;
 TYPE work_type_id            IS TABLE OF  pa_project_assignments.work_type_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_work_type_id               work_type_id;
 TYPE revenue_currency_code   IS TABLE OF  pa_project_assignments.revenue_currency_code%TYPE
                              INDEX BY BINARY_INTEGER;
 l_revenue_currency_code      revenue_currency_code;
 TYPE revenue_bill_rate       IS TABLE OF  pa_project_assignments.revenue_bill_rate%TYPE
                              INDEX BY BINARY_INTEGER;
 l_revenue_bill_rate          revenue_bill_rate;

 TYPE markup_percent          IS TABLE OF  pa_project_assignments.markup_percent%TYPE
                              INDEX BY BINARY_INTEGER;
 l_markup_percent             markup_percent;

 TYPE expense_owner           IS TABLE OF  pa_project_assignments.expense_owner%TYPE
                              INDEX BY BINARY_INTEGER;
 l_expense_owner              expense_owner;
 TYPE expense_limit           IS TABLE OF  pa_project_assignments.expense_limit%TYPE
                              INDEX BY BINARY_INTEGER;
 l_expense_limit              expense_limit;
 TYPE expense_limit_currency_code IS TABLE OF  pa_project_assignments.expense_limit_currency_code%TYPE
                              INDEX BY BINARY_INTEGER;
 l_expense_limit_currency_code expense_limit_currency_code;
 TYPE fcst_tp_amount_type     IS TABLE OF  pa_project_assignments.fcst_tp_amount_type%TYPE
                              INDEX BY BINARY_INTEGER;
 l_fcst_tp_amount_type        fcst_tp_amount_type;
 TYPE fcst_job_id             IS TABLE OF  pa_project_assignments.fcst_job_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_fcst_job_id                fcst_job_id;
 TYPE fcst_job_group_id       IS TABLE OF  pa_project_assignments.fcst_job_group_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_fcst_job_group_id          fcst_job_group_id;
 TYPE expenditure_org_id      IS TABLE OF  pa_project_assignments.expenditure_org_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_expenditure_org_id         expenditure_org_id;
 TYPE expenditure_organization_id IS TABLE OF  pa_project_assignments.expenditure_organization_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_expenditure_organization_id expenditure_organization_id;
 TYPE expenditure_type_class  IS TABLE OF  pa_project_assignments.expenditure_type_class%TYPE
                              INDEX BY BINARY_INTEGER;
 l_expenditure_type_class     expenditure_type_class;
 TYPE expenditure_type        IS TABLE OF  pa_project_assignments.expenditure_type%TYPE
                              INDEX BY BINARY_INTEGER;
 l_expenditure_type           expenditure_type;
 TYPE location_id             IS TABLE OF  pa_project_assignments.location_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_location_id                location_id;
 TYPE calendar_type           IS TABLE OF  pa_project_assignments.calendar_type%TYPE
                              INDEX BY BINARY_INTEGER;
 l_calendar_type              calendar_type;
 TYPE calendar_id	      IS TABLE OF  pa_project_assignments.calendar_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_calendar_id                calendar_id;
 TYPE resource_calendar_percent IS TABLE OF  pa_project_assignments.resource_calendar_percent%TYPE
                              INDEX BY BINARY_INTEGER;
 l_resource_calendar_percent  resource_calendar_percent;
 TYPE no_of_active_candidates IS TABLE OF  pa_project_assignments.no_of_active_candidates%TYPE
                              INDEX BY BINARY_INTEGER;
 l_no_of_active_candidates    no_of_active_candidates;

 TYPE comp_match_weighting    IS TABLE OF pa_project_assignments.competence_match_weighting%TYPE
                              INDEX BY BINARY_INTEGER;
 l_comp_match_weighting       comp_match_weighting;

 TYPE avail_match_weighting   IS TABLE OF pa_project_assignments.availability_match_weighting%TYPE
                              INDEX BY BINARY_INTEGER;
 l_avail_match_weighting      avail_match_weighting;

 TYPE job_level_match_weighting IS TABLE OF pa_project_assignments.job_level_match_weighting%TYPE
                              INDEX BY BINARY_INTEGER;
 l_job_level_match_weighting  job_level_match_weighting;

 TYPE search_min_availability IS TABLE OF pa_project_assignments.search_min_availability%TYPE
                              INDEX BY BINARY_INTEGER;
 l_search_min_availability    search_min_availability;

 TYPE search_country_code     IS TABLE OF pa_project_assignments.search_country_code%TYPE
                              INDEX BY BINARY_INTEGER;
 l_search_country_code        search_country_code;

 TYPE search_exp_org_struct_ver_id IS TABLE OF pa_project_assignments.search_exp_org_struct_ver_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_search_exp_org_struct_ver_id search_exp_org_struct_ver_id;

 TYPE search_exp_start_org_id IS TABLE OF pa_project_assignments.search_exp_start_org_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_search_exp_start_org_id    search_exp_start_org_id;

 TYPE search_min_candidate_score IS TABLE OF pa_project_assignments.search_min_candidate_score%TYPE
                              INDEX BY BINARY_INTEGER;
 l_search_min_candidate_score search_min_candidate_score;

 TYPE enable_auto_cand_nom_flag IS TABLE OF pa_project_assignments.enable_auto_cand_nom_flag%TYPE
                              INDEX BY BINARY_INTEGER;
 l_enable_auto_cand_nom_flag  enable_auto_cand_nom_flag;


 TYPE bill_rate_override IS TABLE OF pa_project_assignments.bill_rate_override%TYPE
                              INDEX BY BINARY_INTEGER;
 l_bill_rate_override  bill_rate_override;


 TYPE bill_rate_curr_override IS TABLE OF pa_project_assignments.bill_rate_curr_override%TYPE
                              INDEX BY BINARY_INTEGER;
 l_bill_rate_curr_override  bill_rate_curr_override;

 TYPE markup_percent_override IS TABLE OF pa_project_assignments.markup_percent_override%TYPE
                              INDEX BY BINARY_INTEGER;
 l_markup_percent_override  markup_percent_override;

 -- FP.L Development
 TYPE discount_percentage IS TABLE OF pa_project_assignments.discount_percentage%TYPE
                              INDEX BY BINARY_INTEGER;
 l_discount_percentage      discount_percentage;

 -- FP.L Development
 TYPE rate_disc_reason_code IS TABLE OF pa_project_assignments.rate_disc_reason_code%TYPE
                              INDEX BY BINARY_INTEGER;
 l_rate_disc_reason_code    rate_disc_reason_code;

 TYPE tp_rate_override IS TABLE OF pa_project_assignments.tp_rate_override%TYPE
                              INDEX BY BINARY_INTEGER;
 l_tp_rate_override  tp_rate_override;

 TYPE tp_currency_override IS TABLE OF pa_project_assignments.tp_currency_override%TYPE
                              INDEX BY BINARY_INTEGER;
 l_tp_currency_override  tp_currency_override;

 TYPE tp_calc_base_code_override IS TABLE OF pa_project_assignments.tp_calc_base_code_override%TYPE
                              INDEX BY BINARY_INTEGER;
 l_tp_calc_base_code_override  tp_calc_base_code_override;

 TYPE tp_percent_applied_override IS TABLE OF pa_project_assignments.tp_percent_applied_override%TYPE
                              INDEX BY BINARY_INTEGER;
 l_tp_percent_applied_override  tp_percent_applied_override;

 -- FP.L Development
 TYPE staffing_owner_person_id IS TABLE OF pa_project_assignments.staffing_owner_person_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_staffing_owner_person_id    staffing_owner_person_id;

 -- FP.M Development
 TYPE resource_list_member_id IS TABLE OF pa_project_assignments.resource_list_member_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_resource_list_member_id    resource_list_member_id;

 TYPE attribute_category      IS TABLE OF  pa_project_assignments.attribute_category%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute_category         attribute_category;
 TYPE attribute1              IS TABLE OF  pa_project_assignments.attribute1%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute1                 attribute1;
 TYPE attribute2              IS TABLE OF  pa_project_assignments.attribute2%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute2                 attribute2;
 TYPE attribute3              IS TABLE OF  pa_project_assignments.attribute3%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute3                 attribute3;
 TYPE attribute4              IS TABLE OF  pa_project_assignments.attribute4%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute4                 attribute4;
 TYPE attribute5              IS TABLE OF  pa_project_assignments.attribute5%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute5                 attribute5;
 TYPE attribute6              IS TABLE OF  pa_project_assignments.attribute6%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute6                 attribute6;
 TYPE attribute7              IS TABLE OF  pa_project_assignments.attribute7%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute7                 attribute7;
 TYPE attribute8              IS TABLE OF  pa_project_assignments.attribute8%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute8                 attribute8;
 TYPE attribute9              IS TABLE OF  pa_project_assignments.attribute9%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute9                 attribute9;
 TYPE attribute10             IS TABLE OF  pa_project_assignments.attribute10%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute10                attribute10;
 TYPE attribute11             IS TABLE OF  pa_project_assignments.attribute11%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute11                attribute11;
 TYPE attribute12             IS TABLE OF  pa_project_assignments.attribute12%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute12                attribute12;
 TYPE attribute13             IS TABLE OF  pa_project_assignments.attribute13%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute13                attribute13;
 TYPE attribute14             IS TABLE OF  pa_project_assignments.attribute14%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute14                attribute14;
 TYPE attribute15             IS TABLE OF  pa_project_assignments.attribute15%TYPE
                              INDEX BY BINARY_INTEGER;
 l_attribute15                attribute15;
 /* Added for bug 3051110 */
 TYPE transfer_price_rate     IS TABLE OF  pa_project_assignments.transfer_price_rate%TYPE
                              INDEX BY BINARY_INTEGER;
 l_transfer_price_rate        transfer_price_rate;
 TYPE transfer_pr_rate_curr   IS TABLE OF  pa_project_assignments.transfer_pr_rate_curr%TYPE
                              INDEX BY BINARY_INTEGER;
 l_transfer_pr_rate_curr      transfer_pr_rate_curr;
 TYPE rowid_table             IS TABLE OF  ROWID
                              INDEX BY BINARY_INTEGER;
 l_rowid                      rowid_table;

 l_index                      NUMBER;
 l_workflow_in_progress_flag  pa_team_templates.workflow_in_progress_flag%TYPE;

 CURSOR check_team_template_wf IS
 SELECT workflow_in_progress_flag
   FROM pa_team_templates
  WHERE team_template_id = p_assignment_template_id;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.DELETE;

 --if this is a template requirement then check that worflow is not in progress
 --on the parent team template.  If it is in progress then no new template requirements
 --can be created
 IF (p_project_id IS NULL OR p_project_id = FND_API.G_MISS_NUM) AND
    (p_assignment_template_id IS NOT NULL and p_assignment_template_id <>FND_API.G_MISS_NUM) THEN
     OPEN check_team_template_wf;
     FETCH check_team_template_wf INTO l_workflow_in_progress_flag;
     CLOSE check_team_template_wf;

     IF l_workflow_in_progress_flag='Y' THEN
        PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_NO_REQ_WF');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     END IF;
  END IF;

 FOR l_index IN 1 .. p_number_of_requirements LOOP

    l_assignment_name(l_index)          := p_assignment_name;
    l_assignment_type(l_index)          := p_assignment_type;
    l_multiple_status_flag(l_index)     := p_multiple_status_flag;
    l_apprvl_status_code(l_index)       := p_apprvl_status_code;
    l_status_code(l_index)              := p_status_code;
    l_staffing_priority_code(l_index)   := p_staffing_priority_code;
    l_project_id(l_index)               := p_project_id;
    l_assignment_template_id(l_index)   := p_assignment_template_id;
    l_project_role_id(l_index)          := p_project_role_id;
    l_resource_id(l_index)              := p_resource_id;
    l_project_party_id(l_index)         := p_project_party_id;
    l_description(l_index)              := p_description;
    l_note_to_approver(l_index)         := p_note_to_approver;
    l_start_date(l_index)               := p_start_date;
    l_end_date(l_index)                 := p_end_date;
    l_assignment_effort(l_index)        := p_assignment_effort;
    l_extension_possible(l_index)       := p_extension_possible;
    l_source_assignment_id(l_index)     := p_source_assignment_id;
    l_min_resource_job_level(l_index)   := p_min_resource_job_level;
    l_max_resource_job_level(l_index)   := p_max_resource_job_level;
    l_additional_information(l_index)   := p_additional_information;
    l_work_type_id(l_index)             := p_work_type_id;
    l_revenue_currency_code(l_index)    := p_revenue_currency_code;
    l_revenue_bill_rate(l_index)        := p_revenue_bill_rate;
    l_markup_percent(l_index)           := p_markup_percent;
    l_expense_owner(l_index)            := p_expense_owner;
    l_expense_limit(l_index)            := p_expense_limit;
    l_expense_limit_currency_code(l_index) := p_expense_limit_currency_code;
    l_fcst_tp_amount_type(l_index)      := p_fcst_tp_amount_type;
    l_fcst_job_id(l_index)              := p_fcst_job_id;
    l_fcst_job_group_id(l_index)        := p_fcst_job_group_id;
    l_expenditure_org_id(l_index)       := p_expenditure_org_id;
    l_expenditure_organization_id(l_index) := p_expenditure_organization_id;
    l_expenditure_type_class(l_index)   := p_expenditure_type_class;
    l_expenditure_type(l_index)         := p_expenditure_type;
    l_location_id(l_index)              := p_location_id;
    l_calendar_type(l_index)            := p_calendar_type;
    l_calendar_id(l_index)              := p_calendar_id;
    l_resource_calendar_percent(l_index):= p_resource_calendar_percent;
    l_no_of_active_candidates(l_index)  := p_no_of_active_candidates;
    l_comp_match_weighting(l_index)     := p_comp_match_weighting;
    l_avail_match_weighting(l_index)    := p_avail_match_weighting;
    l_job_level_match_weighting(l_index):= p_job_level_match_weighting;
    l_search_min_availability(l_index)  := p_search_min_availability;
    l_search_country_code(l_index)      := p_search_country_code;
    l_search_exp_org_struct_ver_id(l_index) := p_search_exp_org_struct_ver_id;
    l_search_exp_start_org_id(l_index)  := p_search_exp_start_org_id;
    l_search_min_candidate_score(l_index) := p_search_min_candidate_score;
    l_enable_auto_cand_nom_flag(l_index) := p_enable_auto_cand_nom_flag;
    l_attribute_category(l_index)       := p_attribute_category;
    l_attribute1(l_index)               := p_attribute1;
    l_attribute2(l_index)               := p_attribute2;
    l_attribute3(l_index)               := p_attribute3;
    l_attribute4(l_index)               := p_attribute4;
    l_attribute5(l_index)               := p_attribute5;
    l_attribute6(l_index)               := p_attribute6;
    l_attribute7(l_index)               := p_attribute7;
    l_attribute8(l_index)               := p_attribute8;
    l_attribute9(l_index)               := p_attribute9;
    l_attribute10(l_index)              := p_attribute10;
    l_attribute11(l_index)              := p_attribute11;
    l_attribute12(l_index)              := p_attribute12;
    l_attribute13(l_index)              := p_attribute13;
    l_attribute14(l_index)              := p_attribute14;
    l_attribute15(l_index)              := p_attribute15;

    l_bill_rate_override(l_index)          := p_bill_rate_override;
    l_bill_rate_curr_override(l_index)     := p_bill_rate_curr_override;
    l_markup_percent_override(l_index)     := p_markup_percent_override;
    l_discount_percentage(l_index)         := p_discount_percentage;
    l_rate_disc_reason_code(l_index)       := p_rate_disc_reason_code;
    l_tp_rate_override(l_index)            := p_tp_rate_override;
    l_tp_currency_override(l_index)        := p_tp_currency_override;
    l_tp_calc_base_code_override(l_index)  := p_tp_calc_base_code_override;
    l_tp_percent_applied_override(l_index) := p_tp_percent_applied_override;
    l_staffing_owner_person_id(l_index)    := p_staffing_owner_person_id;
    l_resource_list_member_id(l_index)     := p_resource_list_member_id;
    /* Added for bug 3051110 */
    l_transfer_price_rate(l_index)         := p_transfer_price_rate;
    l_transfer_pr_rate_curr(l_index)       := p_transfer_pr_rate_curr;

 END LOOP;

 FORALL i IN 1 .. p_number_of_requirements

    INSERT INTO pa_project_assignments
         (assignment_id,
          assignment_name,
          assignment_type,
          multiple_status_flag,
          record_version_number,
          apprvl_status_code,
          status_code,
          staffing_priority_code,
          project_id,
          assignment_template_id,
          template_flag,
          project_role_id,
          project_party_id,
          description,
          note_to_approver,
          start_date,
          end_date,
          resource_id,
          assignment_effort,
          extension_possible,
          source_assignment_id,
          min_resource_job_level,
          max_resource_job_level,
          assignment_number,
          additional_information,
          work_type_id,
          revenue_currency_code,
          revenue_bill_rate,
          markup_percent,
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
          no_of_active_candidates,
          competence_match_weighting,
          availability_match_weighting,
          job_level_match_weighting,
          search_min_availability,
          search_country_code,
          search_exp_org_struct_ver_id,
          search_exp_start_org_id,
          search_min_candidate_score,
          enable_auto_cand_nom_flag,
          staffing_owner_person_id,
          resource_list_member_id,
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
          bill_rate_override,
          bill_rate_curr_override,
          markup_percent_override,
          discount_percentage,
          rate_disc_reason_code,
          tp_rate_override,
          tp_currency_override,
          tp_calc_base_code_override,
          tp_percent_applied_override,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login,
          transfer_price_rate,  --For bug 3051110
          transfer_pr_rate_curr)
   VALUES
        ( pa_project_assignments_s.NEXTVAL,
          DECODE(l_assignment_name(i), FND_API.G_MISS_CHAR, NULL, l_assignment_name(i)),
          DECODE(l_assignment_type(i), FND_API.G_MISS_CHAR, NULL, l_assignment_type(i)),
          DECODE(l_multiple_status_flag(i), FND_API.G_MISS_CHAR, NULL, l_multiple_status_flag(i)),
          1,
          DECODE(l_apprvl_status_code(i), FND_API.G_MISS_CHAR, NULL, l_apprvl_status_code(i)),
          DECODE(l_status_code(i), FND_API.G_MISS_CHAR, NULL, l_status_code(i)),
          DECODE(l_staffing_priority_code(i), FND_API.G_MISS_CHAR, NULL, l_staffing_priority_code(i)),
          DECODE(l_project_id(i), FND_API.G_MISS_NUM, NULL, l_project_id(i)),
          DECODE(l_assignment_template_id(i), FND_API.G_MISS_NUM, NULL, l_assignment_template_id(i)),
          DECODE(l_project_id(i), FND_API.G_MISS_NUM, 'Y', DECODE(l_project_id(i), NULL, 'Y', 'N')),
          DECODE(l_project_role_id(i), FND_API.G_MISS_NUM, NULL, l_project_role_id(i)),
          DECODE(l_project_party_id(i), FND_API.G_MISS_NUM, NULL, l_project_party_id(i)),
          DECODE(l_description(i), FND_API.G_MISS_CHAR, NULL, l_description(i)),
          DECODE(l_note_to_approver(i), FND_API.G_MISS_CHAR, NULL, l_note_to_approver(i)),
          DECODE(l_start_date(i), FND_API.G_MISS_DATE, NULL, l_start_date(i)),
          DECODE(l_end_date(i), FND_API.G_MISS_DATE, NULL, l_end_date(i)),
          DECODE(l_resource_id(i), FND_API.G_MISS_NUM, NULL, l_resource_id(i)),
          DECODE(l_assignment_effort(i), FND_API.G_MISS_NUM, NULL, l_assignment_effort(i)),
          DECODE(l_extension_possible(i), FND_API.G_MISS_CHAR, NULL, l_extension_possible(i)),
          DECODE(l_source_assignment_id(i), FND_API.G_MISS_NUM, NULL, l_source_assignment_id(i)),
          DECODE(l_min_resource_job_level(i), FND_API.G_MISS_NUM, NULL, l_min_resource_job_level(i)),
          DECODE(l_max_resource_job_level(i), FND_API.G_MISS_NUM, NULL, l_max_resource_job_level(i)),
          --DECODE(l_assignment_type(i), 'OPEN_ASSIGNMENT', pa_assignment_number_s.NEXTVAL, NULL),
          pa_assignment_number_s.NEXTVAL,
          DECODE(l_additional_information(i), FND_API.G_MISS_CHAR, NULL, l_additional_information(i)),
          DECODE(l_work_type_id(i), FND_API.G_MISS_NUM, NULL, l_work_type_id(i)),
          DECODE(l_revenue_currency_code(i), FND_API.G_MISS_CHAR, NULL, l_revenue_currency_code(i)),
          DECODE(l_revenue_bill_rate(i), FND_API.G_MISS_NUM, NULL, l_revenue_bill_rate(i)),
          DECODE(l_markup_percent(i), FND_API.G_MISS_NUM, NULL, l_markup_percent(i)),
          DECODE(l_expense_owner(i), FND_API.G_MISS_CHAR, NULL, l_expense_owner(i)),
          DECODE(l_expense_limit(i), FND_API.G_MISS_NUM, NULL, l_expense_limit(i)),
          DECODE(l_expense_limit_currency_code(i), FND_API.G_MISS_CHAR, NULL, l_expense_limit_currency_code(i)),
          DECODE(l_fcst_tp_amount_type(i), FND_API.G_MISS_CHAR, NULL, l_fcst_tp_amount_type(i)),
          DECODE(l_fcst_job_id(i), FND_API.G_MISS_NUM, NULL, l_fcst_job_id(i)),
          DECODE(l_fcst_job_group_id(i), FND_API.G_MISS_NUM, NULL, l_fcst_job_group_id(i)),
          DECODE(l_expenditure_org_id(i), FND_API.G_MISS_NUM, NULL,l_expenditure_org_id(i)),
          DECODE(l_expenditure_organization_id(i), FND_API.G_MISS_NUM, NULL,l_expenditure_organization_id(i)),
          DECODE(l_expenditure_type_class(i), FND_API.G_MISS_CHAR, NULL,l_expenditure_type_class(i)),
          DECODE(l_expenditure_type(i), FND_API.G_MISS_CHAR, NULL,l_expenditure_type(i)),
          DECODE(l_location_id(i), FND_API.G_MISS_NUM, NULL, l_location_id(i)),
          DECODE(l_calendar_type(i), FND_API.G_MISS_CHAR, NULL, l_calendar_type(i)),
          DECODE(l_calendar_id(i), FND_API.G_MISS_NUM, NULL, l_calendar_id(i)),
          DECODE(l_resource_calendar_percent(i), FND_API.G_MISS_NUM, NULL, l_resource_calendar_percent(i)),
          DECODE(l_no_of_active_candidates(i), FND_API.G_MISS_NUM, NULL, l_no_of_active_candidates(i)),
          DECODE(l_comp_match_weighting(i), FND_API.G_MISS_NUM, NULL, l_comp_match_weighting(i)),
          DECODE(l_avail_match_weighting(i), FND_API.G_MISS_NUM, NULL, l_avail_match_weighting(i)),
          DECODE(l_job_level_match_weighting(i), FND_API.G_MISS_NUM, NULL, l_job_level_match_weighting(i)),
          DECODE(l_search_min_availability(i), FND_API.G_MISS_NUM, NULL, l_search_min_availability(i)),
          DECODE(l_search_country_code(i), FND_API.G_MISS_CHAR, NULL, l_search_country_code(i)),
          DECODE(l_search_exp_org_struct_ver_id(i), FND_API.G_MISS_NUM, NULL, l_search_exp_org_struct_ver_id(i)),
          DECODE(l_search_exp_start_org_id(i), FND_API.G_MISS_NUM, NULL, l_search_exp_start_org_id(i)),
          DECODE(l_search_min_candidate_score(i), FND_API.G_MISS_NUM, NULL, l_search_min_candidate_score(i)),
          DECODE(l_enable_auto_cand_nom_flag(i), FND_API.G_MISS_CHAR, NULL, l_enable_auto_cand_nom_flag(i)),
          DECODE(l_staffing_owner_person_id(i), FND_API.G_MISS_NUM, NULL, l_staffing_owner_person_id(i)),
          DECODE(l_resource_list_member_id(i), FND_API.G_MISS_NUM, NULL, l_resource_list_member_id(i)),
          DECODE(l_attribute_category(i), FND_API.G_MISS_CHAR, NULL, l_attribute_category(i)),
          DECODE(l_attribute1(i), FND_API.G_MISS_CHAR, NULL, l_attribute1(i)),
          DECODE(l_attribute2(i), FND_API.G_MISS_CHAR, NULL, l_attribute2(i)),
          DECODE(l_attribute3(i), FND_API.G_MISS_CHAR, NULL, l_attribute3(i)),
          DECODE(l_attribute4(i), FND_API.G_MISS_CHAR, NULL, l_attribute4(i)),
          DECODE(l_attribute5(i), FND_API.G_MISS_CHAR, NULL, l_attribute5(i)),
          DECODE(l_attribute6(i), FND_API.G_MISS_CHAR, NULL, l_attribute6(i)),
          DECODE(l_attribute7(i), FND_API.G_MISS_CHAR, NULL, l_attribute7(i)),
          DECODE(l_attribute8(i), FND_API.G_MISS_CHAR, NULL, l_attribute8(i)),
          DECODE(l_attribute9(i), FND_API.G_MISS_CHAR, NULL, l_attribute9(i)),
          DECODE(l_attribute10(i), FND_API.G_MISS_CHAR, NULL, l_attribute10(i)),
          DECODE(l_attribute11(i), FND_API.G_MISS_CHAR, NULL, l_attribute11(i)),
          DECODE(l_attribute12(i), FND_API.G_MISS_CHAR, NULL, l_attribute12(i)),
          DECODE(l_attribute13(i), FND_API.G_MISS_CHAR, NULL, l_attribute13(i)),
          DECODE(l_attribute14(i), FND_API.G_MISS_CHAR, NULL, l_attribute14(i)),
          DECODE(l_attribute15(i), FND_API.G_MISS_CHAR, NULL, l_attribute15(i)),
          DECODE(l_bill_rate_override(i), FND_API.G_MISS_NUM, NULL, l_bill_rate_override(i)),
          DECODE(l_bill_rate_curr_override(i), FND_API.G_MISS_CHAR, NULL, l_bill_rate_curr_override(i)),
          DECODE(l_markup_percent_override(i), FND_API.G_MISS_NUM, NULL, l_markup_percent_override(i)),
          DECODE(l_discount_percentage(i), FND_API.G_MISS_NUM, NULL, l_discount_percentage(i)),
          DECODE(l_rate_disc_reason_code(i), FND_API.G_MISS_CHAR, NULL, l_rate_disc_reason_code(i)),
          DECODE(l_tp_rate_override(i), FND_API.G_MISS_NUM, NULL, l_tp_rate_override(i)),
          DECODE(l_tp_currency_override(i), FND_API.G_MISS_CHAR, NULL, l_tp_currency_override(i)),
          DECODE(l_tp_calc_base_code_override(i), FND_API.G_MISS_CHAR, NULL, l_tp_calc_base_code_override(i)),
          DECODE(l_tp_percent_applied_override(i), FND_API.G_MISS_NUM, NULL, l_tp_percent_applied_override(i)),
          sysdate,
          fnd_global.user_id,
          sysdate,
          fnd_global.user_id,
          fnd_global.login_id,
          DECODE(l_transfer_price_rate(i), FND_API.G_MISS_NUM, NULL, l_transfer_price_rate(i)),  -- Added for 3051110
          DECODE(l_transfer_pr_rate_curr(i), FND_API.G_MISS_CHAR, NULL, l_transfer_pr_rate_curr(i))
     )
     RETURNING assignment_id, assignment_number, rowid BULK COLLECT INTO l_assignment_id, l_assignment_number, l_rowid;

    --when creating MULTIPLE requirements we need to pass all the new assignment ids to the schedule API.
    --I don't want to add a new OUT parameter b/c many other APIs are calling
    --this table handler and the impact is too big at this time.
    --so storing the pl/sql table of new assignments in a global.
    --note that we only create multiple requirements, NOT assignments.
    --can't bulk collect into a table of records - so need to loop through.
    FOR i IN l_assignment_id.FIRST .. l_assignment_id.LAST LOOP
       PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id := l_assignment_id(i);
    END LOOP;
     /*Commented the code for bug 3079906*/
    --IF p_number_of_requirements = 1 THEN
       --only return the new assignment id, number and assignment row id if we are creating only 1 requirement.
          x_new_assignment_id := l_assignment_id(1);
          x_assignment_number := l_assignment_number(1);
          x_assignment_row_id := l_rowid(1);

   -- END IF; -- number of requirements =1


  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_ASSIGNMENTS_PKG.Insert_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Insert_Row;


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
 ,p_assignment_number           IN   pa_project_assignments.assignment_number%TYPE           := FND_API.G_MISS_NUM
 ,p_additional_information      IN   pa_project_assignments.additional_information%TYPE      := FND_API.G_MISS_CHAR
 ,p_work_type_id                IN   pa_project_assignments.work_type_id%TYPE                := FND_API.G_MISS_NUM
 ,p_revenue_currency_code       IN   pa_project_assignments.revenue_currency_code%TYPE       := FND_API.G_MISS_CHAR
 ,p_revenue_bill_rate           IN   pa_project_assignments.revenue_bill_rate%TYPE           := FND_API.G_MISS_NUM
 ,p_markup_percent              IN   pa_project_assignments.markup_percent%TYPE              := FND_API.G_MISS_NUM
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
 ,p_resource_list_member_id      IN  pa_project_assignments.resource_list_member_id%TYPE       := FND_API.G_MISS_NUM   -- FP.M Development
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
)IS


 l_row_id                      ROWID := p_assignment_row_id;
 l_record_version_number       NUMBER;
 l_workflow_in_progress_flag  pa_team_templates.workflow_in_progress_flag%TYPE;

 TYPE  assignment_id          IS TABLE OF  pa_project_assignments.assignment_id%TYPE
                              INDEX BY BINARY_INTEGER;
 l_assignment_id              assignment_id;
 l_mass_wf_in_progress_flag   pa_project_assignments.mass_wf_in_progress_flag%TYPE;

CURSOR get_row_id IS
SELECT rowid
FROM   pa_project_assignments
WHERE  assignment_id = p_assignment_id;

CURSOR check_team_template_wf IS
SELECT workflow_in_progress_flag
  FROM pa_team_templates
 WHERE team_template_id = p_assignment_template_id;

/*
-- do not have to check mass_wf_in_progress_flag again
-- right before insert
-- 1) for Mass, select checkboxes are disabled on Team page if wf
-- is pending for the role
-- 2) for Single, check is taken care of in PA_ASSIGNMENT_PUB
CURSOR check_project_assignment_wf IS
SELECT mass_wf_in_progress_flag
  FROM pa_project_assignments
 WHERE assignment_id = p_assignment_id;
*/
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 --if this is a template requirement then check that worflow is not in progress
 --on the parent team template.  If it is in progress then no new template requirements
 --can be created
 IF (p_project_id IS NULL OR p_project_id = FND_API.G_MISS_NUM) AND
    (p_assignment_template_id IS NOT NULL and p_assignment_template_id <>FND_API.G_MISS_NUM)   THEN
     OPEN check_team_template_wf;
     FETCH check_team_template_wf INTO l_workflow_in_progress_flag;
     CLOSE check_team_template_wf;

     IF l_workflow_in_progress_flag='Y' THEN
        PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_NO_REQ_WF');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        x_return_status := FND_API.G_RET_STS_ERROR;
        RETURN;
     END IF;
  END IF;

/*
-- do not have to check mass_wf_in_progress_flag again
-- right before insert
-- 1) for Mass, select checkboxes are disabled on Team page if wf
-- is pending for the role
-- 2) for Single, check is taken care of in PA_ASSIGNMENT_PUB

  -- check that mass workflow for updating assignment is not in progress.
  -- if mass workflow is in progress, cannot update the assignment
  -- The p_assignment_id is null only when user is creating multiple
  -- copies of requirement.  Therefore, do not have to check if wf is in progress
  -- because these are newly created requirements
  IF p_assignment_id IS NOT NULL THEN
    OPEN check_project_assignment_wf;
    FETCH check_project_assignment_wf INTO l_mass_wf_in_progress_flag;
    CLOSE check_project_assignment_wf;

    IF l_mass_wf_in_progress_flag = 'Y' THEN

      PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_ASSIGNMENT_WF');
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
    END IF;
  END IF;
*/
  -- Increment the record version number by 1
  l_record_version_number :=  p_record_version_number +1;

  -- Copy the global assignment_id table into the local array
  -- If global table is empty, then insert the passed in assignment_id into the local array
  -- The global assignment_id table is not empty only when user is
  -- creating multiple copies of requirement
  IF PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.COUNT > 0 AND p_assignment_id IS NULL THEN
    FOR i IN PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.FIRST .. PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.LAST LOOP
     l_assignment_id(i) :=PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id;
    END LOOP;
  ELSE
    l_assignment_id(1) := p_assignment_id;
  END IF;

FORALL i IN l_assignment_id.FIRST .. l_assignment_id.LAST

  UPDATE pa_project_assignments
  SET assignment_name             = DECODE(p_assignment_name, FND_API.G_MISS_CHAR, assignment_name, p_assignment_name),
      assignment_type             = DECODE(p_assignment_type, FND_API.G_MISS_CHAR, assignment_type, p_assignment_type),
      record_version_number       = DECODE(p_record_version_number, NULL, record_version_number, l_record_version_number),
      multiple_status_flag        = DECODE(p_multiple_status_flag, FND_API.G_MISS_CHAR, multiple_status_flag, p_multiple_status_flag),
      apprvl_status_code          = DECODE(p_apprvl_status_code, FND_API.G_MISS_CHAR, apprvl_status_code, p_apprvl_status_code),
      status_code                 = DECODE(p_status_code, FND_API.G_MISS_CHAR, status_code, p_status_code),
      staffing_priority_code      = DECODE(p_staffing_priority_code, FND_API.G_MISS_CHAR, staffing_priority_code, p_staffing_priority_code),
      project_id                  = DECODE(p_project_id, FND_API.G_MISS_NUM, project_id, p_project_id),
      assignment_template_id            = DECODE(p_assignment_template_id, FND_API.G_MISS_NUM, assignment_template_id, p_assignment_template_id),
      project_role_id             = DECODE(p_project_role_id, FND_API.G_MISS_NUM, project_role_id, p_project_role_id),
      resource_id                 = DECODE(p_resource_id,FND_API.G_MISS_NUM,resource_id, p_resource_id),
      project_party_id            = DECODE(p_project_party_id, FND_API.G_MISS_NUM, project_party_id, p_project_party_id),
      description                 = DECODE(p_description, FND_API.G_MISS_CHAR, description, p_description),
      note_to_approver                 = DECODE(p_note_to_approver, FND_API.G_MISS_CHAR,note_to_approver , p_note_to_approver),
      start_date                  = DECODE(p_start_date, FND_API.G_MISS_DATE, start_date, p_start_date),
      end_date                    = DECODE(p_end_date, FND_API.G_MISS_DATE, end_date, p_end_date),
      assignment_effort           = DECODE(p_assignment_effort, FND_API.G_MISS_NUM, assignment_effort, p_assignment_effort),
      extension_possible          = DECODE(p_extension_possible, FND_API.G_MISS_CHAR, extension_possible, p_extension_possible),
      source_assignment_id        = DECODE(p_source_assignment_id, FND_API.G_MISS_NUM, source_assignment_id, p_source_assignment_id),
      min_resource_job_level      = DECODE(p_min_resource_job_level, FND_API.G_MISS_NUM, min_resource_job_level, p_min_resource_job_level),
      max_resource_job_level      = DECODE(p_max_resource_job_level, FND_API.G_MISS_NUM, max_resource_job_level, p_max_resource_job_level),
      assignment_number           = DECODE(p_assignment_number, FND_API.G_MISS_NUM, assignment_number, p_assignment_number),
      additional_information      = DECODE(p_additional_information, FND_API.G_MISS_CHAR, additional_information, p_additional_information),
      work_type_id                = DECODE(p_work_type_id, FND_API.G_MISS_NUM, work_type_id, p_work_type_id),
      revenue_currency_code       = DECODE(p_revenue_currency_code, FND_API.G_MISS_CHAR, revenue_currency_code, p_revenue_currency_code),
      revenue_bill_rate           = DECODE(p_revenue_bill_rate, FND_API.G_MISS_NUM, revenue_bill_rate, p_revenue_bill_rate),
      markup_percent              = DECODE(p_markup_percent, FND_API.G_MISS_NUM, markup_percent, p_markup_percent),
      expense_owner               = DECODE(p_expense_owner, FND_API.G_MISS_CHAR, expense_owner, p_expense_owner),
      expense_limit               = DECODE(p_expense_limit, FND_API.G_MISS_NUM, expense_limit, p_expense_limit),
      expense_limit_currency_code = DECODE(p_expense_limit_currency_code, FND_API.G_MISS_CHAR, expense_limit_currency_code, p_expense_limit_currency_code),
      fcst_tp_amount_type         = DECODE(p_fcst_tp_amount_type, FND_API.G_MISS_CHAR, fcst_tp_amount_type, p_fcst_tp_amount_type),
      fcst_job_id                 = DECODE(p_fcst_job_id, FND_API.G_MISS_NUM, fcst_job_id, p_fcst_job_id),
      fcst_job_group_id           = DECODE(p_fcst_job_group_id, FND_API.G_MISS_NUM,fcst_job_group_id, p_fcst_job_group_id),
      expenditure_org_id          = DECODE(p_expenditure_org_id, FND_API.G_MISS_NUM,expenditure_org_id, p_expenditure_org_id),
      expenditure_organization_id = DECODE(p_expenditure_organization_id, FND_API.G_MISS_NUM,expenditure_organization_id, p_expenditure_organization_id),
      expenditure_type_class      = DECODE(p_expenditure_type_class, FND_API.G_MISS_CHAR,expenditure_type_class, p_expenditure_type_class),
      expenditure_type            = DECODE(p_expenditure_type, FND_API.G_MISS_CHAR,expenditure_type, p_expenditure_type),
      location_id                 = DECODE(p_location_id, FND_API.G_MISS_NUM, location_id, p_location_id),
      calendar_type               = DECODE(p_calendar_type, FND_API.G_MISS_CHAR, calendar_type, p_calendar_type),
      calendar_id                 = DECODE(p_calendar_id, FND_API.G_MISS_NUM, calendar_id, p_calendar_id),
      resource_calendar_percent   = DECODE(p_resource_calendar_percent, FND_API.G_MISS_NUM, resource_calendar_percent, p_resource_calendar_percent),
      pending_approval_flag       = DECODE(p_pending_approval_flag, FND_API.G_MISS_CHAR, pending_approval_flag, p_pending_approval_flag),
      no_of_active_candidates     = DECODE(p_no_of_active_candidates, FND_API.G_MISS_NUM, no_of_active_candidates, p_no_of_active_candidates),
      competence_match_weighting  = DECODE(p_comp_match_weighting, FND_API.G_MISS_NUM, competence_match_weighting, p_comp_match_weighting),
      availability_match_weighting= DECODE(p_avail_match_weighting, FND_API.G_MISS_NUM, availability_match_weighting, p_avail_match_weighting),
      job_level_match_weighting   = DECODE(p_job_level_match_weighting, FND_API.G_MISS_NUM, job_level_match_weighting, p_job_level_match_weighting),
      search_min_availability     = DECODE(p_search_min_availability, FND_API.G_MISS_NUM, search_min_availability, p_search_min_availability),
      search_country_code         = DECODE(p_search_country_code, FND_API.G_MISS_CHAR, search_country_code, p_search_country_code),
      search_exp_org_struct_ver_id = DECODE(p_search_exp_org_struct_ver_id, FND_API.G_MISS_NUM, search_exp_org_struct_ver_id, p_search_exp_org_struct_ver_id),
      search_exp_start_org_id     = DECODE(p_search_exp_start_org_id, FND_API.G_MISS_NUM, search_exp_start_org_id, p_search_exp_start_org_id),
      search_min_candidate_score  = DECODE(p_search_min_candidate_score, FND_API.G_MISS_NUM, search_min_candidate_score, p_search_min_candidate_score),
      enable_auto_cand_nom_flag = DECODE(p_enable_auto_cand_nom_flag, FND_API.G_MISS_CHAR, enable_auto_cand_nom_flag, p_enable_auto_cand_nom_flag),
      bill_rate_override          = DECODE(p_bill_rate_override, FND_API.G_MISS_NUM, bill_rate_override, p_bill_rate_override),
      bill_rate_curr_override     = DECODE(p_bill_rate_curr_override, FND_API.G_MISS_CHAR, bill_rate_curr_override, p_bill_rate_curr_override),
      markup_percent_override     = DECODE(p_markup_percent_override, FND_API.G_MISS_NUM, markup_percent_override, p_markup_percent_override),
      discount_percentage         = DECODE(p_discount_percentage, FND_API.G_MISS_NUM, discount_percentage, p_discount_percentage), -- Bug 2590938
      rate_disc_reason_code       = DECODE(p_rate_disc_reason_code, FND_API.G_MISS_CHAR, rate_disc_reason_code, p_rate_disc_reason_code), -- Bug 2590938
      tp_rate_override            = DECODE(p_tp_rate_override, FND_API.G_MISS_NUM, tp_rate_override, p_tp_rate_override),
      tp_currency_override        = DECODE(p_tp_currency_override, FND_API.G_MISS_CHAR, tp_currency_override, p_tp_currency_override),
      tp_calc_base_code_override  = DECODE(p_tp_calc_base_code_override, FND_API.G_MISS_CHAR,tp_calc_base_code_override, p_tp_calc_base_code_override),
      tp_percent_applied_override = DECODE(p_tp_percent_applied_override, FND_API.G_MISS_NUM, tp_percent_applied_override, p_tp_percent_applied_override),
      staffing_owner_person_id    = DECODE(p_staffing_owner_person_id, FND_API.G_MISS_NUM, staffing_owner_person_id, p_staffing_owner_person_id),
      resource_list_member_id     = DECODE(p_resource_list_member_id, FND_API.G_MISS_NUM, resource_list_member_id, p_resource_list_member_id),
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
      transfer_pr_rate_curr       = DECODE(p_transfer_pr_rate_curr, FND_API.G_MISS_CHAR, transfer_pr_rate_curr, p_transfer_pr_rate_curr)
      WHERE  assignment_id = l_assignment_id(i)
      AND    nvl(p_record_version_number, record_version_number) = record_version_number;


  IF (SQL%NOTFOUND) THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;


  --
  EXCEPTION
    WHEN OTHERS THEN -- catch the exceptins here
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_ASSIGNMENTS_PKG.Update_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
  --
END Update_Row;


PROCEDURE Delete_Row
( p_assignment_row_id           IN    ROWID
 ,p_assignment_id               IN    pa_project_assignments.assignment_id%TYPE
 ,p_record_version_number       IN    NUMBER                                                := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_row_id                      ROWID;
l_workflow_in_progress_flag   pa_team_templates.workflow_in_progress_flag%TYPE;
l_mass_wf_in_progress_flag    pa_project_assignments.mass_wf_in_progress_flag%TYPE;

CURSOR check_team_template_wf IS
SELECT tt.workflow_in_progress_flag
  FROM pa_project_assignments asgn,
       pa_team_templates tt
 WHERE asgn.assignment_id = p_assignment_id
   AND asgn.template_flag = 'Y'
   AND tt.team_template_id = asgn.assignment_template_id;

 CURSOR check_project_assignment_wf IS
 SELECT mass_wf_in_progress_flag
   FROM pa_project_assignments
  WHERE assignment_id = p_assignment_id;

BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 --check if workflow is in progress for the parent team template.
 --if so, it can't be deleted.
 --if this is not a template requirement the cursor won't return any
 --rows and the delete API will continue.
 --we don't know if this is a template requirement (no project_id in the API) prior
 --to opening the cursor.
 OPEN check_team_template_wf;
 FETCH check_team_template_wf INTO l_workflow_in_progress_flag;
 CLOSE check_team_template_wf;
 IF l_workflow_in_progress_flag = 'Y' THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_NO_REQ_WF');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
 END IF;

 -- check that mass workflow for updating assignment is not in progress.
 -- if mass workflow is in progress, cannot delete the assignment
 OPEN check_project_assignment_wf;
 FETCH check_project_assignment_wf INTO l_mass_wf_in_progress_flag;
 CLOSE check_project_assignment_wf;

 IF l_mass_wf_in_progress_flag = 'Y' THEN

    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_ASSIGNMENT_WF');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    x_return_status := FND_API.G_RET_STS_ERROR;
    RETURN;
  END IF;

  IF (p_assignment_id IS NOT NULL AND p_assignment_id <> FND_API.G_MISS_NUM) THEN

    DELETE FROM  pa_project_assignments
    WHERE  assignment_id  = p_assignment_id
    AND    nvl(p_record_version_number, record_version_number) = record_version_number;

  ELSIF (p_assignment_row_id IS NOT NULL) THEN
    DELETE FROM  pa_project_assignments
    WHERE  rowid = p_assignment_row_id
    AND    nvl(p_record_version_number, record_version_number) = record_version_number;

  END IF;

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
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_ASSIGNMENTS_PKG.Delete_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Row;


PROCEDURE Lock_Row
( p_assignment_row_id           IN    ROWID
 ,p_assignment_id               IN    pa_project_assignments.assignment_id%TYPE
 ,p_record_version_number       IN    NUMBER                                                := NULL
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_row_id  ROWID;

BEGIN
  -- Lock  the Assignment;
  SELECT rowid  INTO l_row_id
  FROM pa_project_assignments
  WHERE assignment_id = p_assignment_id
  OR  rowid = p_assignment_row_id
  FOR  UPDATE NOWAIT;
  --
  --
  EXCEPTION
    WHEN OTHERS THEN
        -- Set the exception Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_PROJECT_ASSIGNMENTS_PKG.Lock_Row'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;

END Lock_Row;
--
--
END pa_project_assignments_pkg;

/
