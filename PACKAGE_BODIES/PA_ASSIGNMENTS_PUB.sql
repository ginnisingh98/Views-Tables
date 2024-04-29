--------------------------------------------------------
--  DDL for Package Body PA_ASSIGNMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_ASSIGNMENTS_PUB" AS
/*$Header: PARAPUBB.pls 120.13.12010000.15 2010/05/14 06:53:55 nisinha ship $*/
--

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
li_message_level NUMBER := 1;

PROCEDURE Execute_Create_Assignment
( p_asgn_creation_mode          IN    VARCHAR2                                                := 'FULL'
 ,p_unfilled_assignment_status    IN    pa_project_assignments.status_code%TYPE               := FND_API.G_MISS_CHAR
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
 ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
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
 ,p_calendar_id                 IN    pa_project_assignments.calendar_id%TYPE                 := FND_API.G_MISS_NUM
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
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                                 := FND_API.G_MISS_CHAR
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
 ,p_sum_tasks_flag              IN    VARCHAR2                                                := FND_API.G_FALSE     -- FP.M Development
 ,p_budget_version_id                   IN      pa_resource_assignments.budget_version_id%TYPE                    := FND_API.G_MISS_NUM
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
)
IS

  l_assignment_rec      PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_return_status       VARCHAR2(1);
   /*Added for the bug 3464074*/
 l_person_name                 PER_PEOPLE_F.full_name%TYPE;
 l_error_message_code      fnd_new_messages.message_name%TYPE;
 l_work_type_exixts varchar2(1) := 'N'; --bug#8368384

 -- start of cursor or work type validation bug 8368384
 CURSOR c_validate_work_type (p_wrk_typ_id number,p_start_dt Date, p_end_dt Date) IS
   SELECT 'Y' Flag
  FROM PA_WORK_TYPES_B B
  WHERE B.work_type_id = p_wrk_typ_id
  AND TRUNC(SYSDATE) BETWEEN start_date_active
  AND  NVL(end_date_active,TRUNC(SYSDATE));
BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN

    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment.begin'
                       ,x_msg         => 'Beginning of the Execute_Create_Assignment'
                       ,x_log_level   => 5);
  END IF;
 /*
  changes start  for bug#8368384
  */

  OPEN c_validate_work_type(p_work_type_id,p_start_date,p_end_date);
  FETCH c_validate_work_type into l_work_type_exixts;
  close c_validate_work_type;

  IF l_work_type_exixts='Y' then

     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment.begin'
                       ,x_msg         => 'Work type is valid'
                       ,x_log_level   => 5);
  ELSE
                 PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment.begin'
                       ,x_msg         => 'Work type is not valid'
                       ,x_log_level   => 5);

                PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_INVALID_WORK_TYPE');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;


  END IF;

  /*
  changes end for bug#8368384
  */
  --
  -- Assign the scalar parameters to the assignment record fields
  --
--p_rate_disc_reason_code = FND_API.G_MISS_CHAR or


  l_assignment_rec.assignment_name             := p_assignment_name;
  l_assignment_rec.assignment_type             := p_assignment_type;
  l_assignment_rec.multiple_status_flag        := p_multiple_status_flag;
  l_assignment_rec.status_code                 := p_status_code;

    IF p_status_code is NULL THEN  -- Added default value population for Status Code. Bug 7309934

      IF p_assignment_type = 'OPEN_ASSIGNMENT' THEN
       FND_PROFILE.Get('PA_START_OPEN_ASGMT_STATUS',l_assignment_rec.status_code);
       IF l_assignment_rec.status_code IS NULL THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
      END IF;

      IF (p_assignment_type = 'STAFFED_ASSIGNMENT' OR p_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT') THEN
       FND_PROFILE.Get('PA_START_STAFFED_ASGMT_STATUS',l_assignment_rec.status_code);
       IF l_assignment_rec.status_code IS NULL THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
      END IF;

  ELSE

     l_assignment_rec.status_code                 := p_status_code;

  END IF;


  l_assignment_rec.staffing_priority_code      := p_staffing_priority_code;
  l_assignment_rec.project_id                  := p_project_id;
  l_assignment_rec.assignment_template_id      := p_assignment_template_id;
  l_assignment_rec.project_role_id             := p_project_role_id;
  l_assignment_rec.resource_id                 := p_resource_id;
  l_assignment_rec.project_party_id            := p_project_party_id;
  l_assignment_rec.description                 := p_description;
  l_assignment_rec.start_date                  := p_start_date;
  l_assignment_rec.end_date                    := p_end_date;
  l_assignment_rec.assignment_effort           := p_assignment_effort;
  l_assignment_rec.extension_possible          := p_extension_possible;
  l_assignment_rec.source_assignment_id        := p_source_assignment_id;
  l_assignment_rec.min_resource_job_level      := p_min_resource_job_level;
  l_assignment_rec.max_resource_job_level      := p_max_resource_job_level;
  l_assignment_rec.additional_information      := p_additional_information;
  l_assignment_rec.work_type_id                := p_work_type_id;
  l_assignment_rec.location_id                 := p_location_id;
  l_assignment_rec.revenue_currency_code       := p_revenue_currency_code;
  l_assignment_rec.revenue_bill_rate           := p_revenue_bill_rate;
  l_assignment_rec.markup_percent              := p_markup_percent;
  l_assignment_rec.expense_owner               := p_expense_owner;
  l_assignment_rec.expense_limit               := p_expense_limit;
  l_assignment_rec.expense_limit_currency_code := p_expense_limit_currency_code;
  l_assignment_rec.fcst_tp_amount_type         := p_fcst_tp_amount_type;
  l_assignment_rec.fcst_job_id                 := p_fcst_job_id;
  l_assignment_rec.fcst_job_group_id           := p_fcst_job_group_id;
  l_assignment_rec.expenditure_org_id          := p_expenditure_org_id;
  l_assignment_rec.expenditure_organization_id := p_expenditure_organization_id;
  l_assignment_rec.expenditure_type_class      := p_expenditure_type_class;
  l_assignment_rec.expenditure_type            := p_expenditure_type;
  l_assignment_rec.calendar_type               := p_calendar_type;
  l_assignment_rec.calendar_id                 := p_calendar_id;
  l_assignment_rec.resource_calendar_percent   := p_resource_calendar_percent;

  IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment'
              ,x_msg         => 'Execute_Create_Assignment before L'
              ,x_log_level   => li_message_level);
  END IF;

  -- FP.L Development
  l_assignment_rec.bill_rate_override          := p_bill_rate_override;
  l_assignment_rec.bill_rate_curr_override     := p_bill_rate_curr_override;
  l_assignment_rec.markup_percent_override     := p_markup_percent_override;
  l_assignment_rec.discount_percentage         := p_discount_percentage;
  l_assignment_rec.rate_disc_reason_code       := p_rate_disc_reason_code;
  l_assignment_rec.tp_rate_override            := p_tp_rate_override;
  l_assignment_rec.tp_currency_override        := p_tp_currency_override;
  l_assignment_rec.tp_calc_base_code_override  := p_tp_calc_base_code_override;
  l_assignment_rec.tp_percent_applied_override := p_tp_percent_applied_override;
  l_assignment_rec.staffing_owner_person_id    := p_staffing_owner_person_id;

  IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment'
              ,x_msg         => 'Execute_Create_Assignment before M'
              ,x_log_level   => li_message_level);
  END IF;
  -- FP.M Development
  l_assignment_rec.resource_list_member_id     := p_resource_list_member_id;

  l_assignment_rec.attribute_category          := p_attribute_category;
  l_assignment_rec.attribute1                  := p_attribute1;
  l_assignment_rec.attribute2                  := p_attribute2;
  l_assignment_rec.attribute3                  := p_attribute3;
  l_assignment_rec.attribute4                  := p_attribute4;
  l_assignment_rec.attribute5                  := p_attribute5;
  l_assignment_rec.attribute6                  := p_attribute6;
  l_assignment_rec.attribute7                  := p_attribute7;
  l_assignment_rec.attribute8                  := p_attribute8;
  l_assignment_rec.attribute9                  := p_attribute9;
  l_assignment_rec.attribute10                 := p_attribute10;
  l_assignment_rec.attribute11                 := p_attribute11;
  l_assignment_rec.attribute12                 := p_attribute12;
  l_assignment_rec.attribute13                 := p_attribute13;
  l_assignment_rec.attribute14                 := p_attribute14;
  l_assignment_rec.attribute15                 := p_attribute15;

  -- 5130421 Begin
  l_assignment_rec.comp_match_weighting        := p_comp_match_weighting;
  l_assignment_rec.avail_match_weighting       := p_avail_match_weighting;
  l_assignment_rec.job_level_match_weighting   := p_job_level_match_weighting;
  l_assignment_rec.search_min_availability     := p_search_min_availability;
  l_assignment_rec.search_country_code         := p_search_country_code;
  l_assignment_rec.search_exp_org_struct_ver_id := p_search_exp_org_struct_ver_id;
  l_assignment_rec.search_exp_start_org_id     := p_search_exp_start_org_id;
  l_assignment_rec.search_min_candidate_score  := p_search_min_candidate_score;
  l_assignment_rec.enable_auto_cand_nom_flag   := p_enable_auto_cand_nom_flag;
  -- 5130421 End

  --Start Bug 3249669 : Check for profile option PA: Global Week Start Day being set.
  IF NVL(FND_PROFILE.value('PA_GLOBAL_WEEK_START_DAY'),'N') = 'N' THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_GLOBAL_WEEK_START_DAY_ERR' );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;
  --End Bug 3249669 : Check for profile option PA: Global Week Start Day being set.

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment.create_asgmt'
                       ,x_msg         => 'Calling Create_Assignment'
                       ,x_log_level   => 5);
  END IF;

  --
  -- Call the create assignment public API

  /*Added for the bug 3464074*/
     IF l_assignment_rec.staffing_owner_person_id = FND_API.G_MISS_NUM
--        Bug 4049534: when user explicitly clears staffing_owner,
--        it shouldn't be derived.
--        OR l_assignment_rec.staffing_owner_person_id IS NULL

     THEN

         pa_assignment_utils.Get_Default_Staffing_Owner
          ( p_project_id                  => l_assignment_rec.project_id
           ,p_exp_org_id                  => null
           ,x_person_id                   => l_assignment_rec.staffing_owner_person_id
           ,x_person_name                 => l_person_name
           ,x_return_status               => l_return_status
           ,x_error_message_code          => l_error_message_code);


      END IF;

          IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment'
                ,x_msg         => 'before calling pub.Create_Assignment'
                ,x_log_level   => li_message_level);
          END IF;

  PA_ASSIGNMENTS_PUB.Create_Assignment
  ( p_assignment_rec             => l_assignment_rec
   ,p_asgn_creation_mode         => p_asgn_creation_mode
   ,p_project_number             => p_project_number
   ,p_project_name               => p_project_name
   ,p_resource_name              => p_resource_name
   ,p_resource_source_id         => p_resource_source_id
   ,p_project_subteam_id         => p_project_subteam_id
   ,p_project_subteam_name       => p_project_subteam_name
   ,p_project_status_name        => p_project_status_name
   ,p_staffing_priority_name     => p_staffing_priority_name
   ,p_project_role_name          => p_project_role_name
   ,p_location_city              => p_location_city
   ,p_location_region            => p_location_region
   ,p_location_country_name      => p_location_country_name
   ,p_location_country_code      => p_location_country_code
   ,p_calendar_name              => p_calendar_name
   ,p_work_type_name             => p_work_type_name
   ,p_role_list_id               => p_role_list_id
   ,p_adv_action_set_id          => p_adv_action_set_id
   ,p_start_adv_action_set_flag  => p_start_adv_action_set_flag
   ,p_adv_action_set_name        => p_adv_action_set_name
   ,p_staffing_owner_name        => p_staffing_owner_name
   ,p_sum_tasks_flag                     => p_sum_tasks_flag   -- FP.M Development
   ,p_budget_version_id                  => p_budget_version_id
   ,p_number_of_requirements     => p_number_of_requirements
   ,p_api_version                => p_api_version
   ,p_commit                     => p_commit
   ,p_validate_only              => p_validate_only
   ,p_max_msg_count              => p_max_msg_count
   ,x_new_assignment_id          => x_new_assignment_id
   ,x_assignment_number          => x_assignment_number
   ,x_assignment_row_id          => x_assignment_row_id
   ,x_resource_id                => x_resource_id
   ,x_return_status              => l_return_status
   ,x_msg_count                  => x_msg_count
   ,x_msg_data                   => x_msg_data
);

  IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exceute_Create_Assignment'
            ,x_msg         => 'after calling pub.Create_Assignment'
            ,x_log_level   => li_message_level);
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If there are any messages in the stack then set x_return_status

  IF FND_MSG_PUB.Count_Msg > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

-- Bug 3132280 : MOved the following table initialization outside the if
--               so that the NPE can be avoided in Java Layer
 x_new_assignment_id_tbl:= SYSTEM.pa_num_tbl_type();

IF  PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.count > 0 THEN -- Bug 3132280

   /*Added the code for bug 3079906*/
   IF p_asgn_creation_mode <> 'MASS' OR (p_asgn_creation_mode = 'MASS' AND p_validate_only = FND_API.G_FALSE) THEN
        --  Bug 3132280 x_new_assignment_id_tbl:= SYSTEM.pa_num_tbl_type();
        FOR i in PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.FIRST..PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.LAST LOOP
            x_new_assignment_id_tbl.extend(1);
            x_new_assignment_id_tbl(i):=PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id;
        END LOOP;
      /* code addition for bug 3079906 ends*/
   end if;
END IF;
   EXCEPTION
    WHEN OTHERS THEN
       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENTS_PUB.Execute_Create_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END Execute_Create_Assignment;


PROCEDURE Exec_Create_Assign_With_Def
( p_asgn_creation_mode          IN    VARCHAR2                                                := 'FULL'
 ,p_role_name                   IN     pa_project_role_types.meaning%TYPE                     := FND_API.G_MISS_CHAR
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
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  l_assignment_rec      PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_return_status       VARCHAR2(1);
  l_person_name         PER_PEOPLE_F.full_name%TYPE;
  l_err_msg_code        VARCHAR2(80);

BEGIN


  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Exec_Create_Assign_With_Def');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exec_Create_Assign_With_Def.begin'
                       ,x_msg         => 'Beginning of the Exec_Create_Assign_With_Def'
                       ,x_log_level   => 5);
  END IF;

  --
  -- Assign the scalar parameters to the assignment record fields
  --

  l_assignment_rec.assignment_name             := p_role_name;

  l_assignment_rec.assignment_type             := p_assignment_type;
  l_assignment_rec.multiple_status_flag        := p_multiple_status_flag;
  l_assignment_rec.project_id                  := p_project_id;
  l_assignment_rec.project_role_id             := p_project_role_id;
  l_assignment_rec.resource_id                 := p_resource_id;
  l_assignment_rec.project_party_id            := p_project_party_id;
  l_assignment_rec.start_date                  := p_start_date;
  l_assignment_rec.end_date                    := p_end_date;


  -- Retrieve default staffing owner person id
  pa_assignment_utils.Get_Default_Staffing_Owner
  ( p_project_id                  => p_project_id
   ,p_exp_org_id                  => null
   ,x_person_id                   => l_assignment_rec.staffing_owner_person_id
   ,x_person_name                 => l_person_name
   ,x_return_status               => x_return_status
   ,x_error_message_code          => l_err_msg_code);

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Exec_Create_Assign_With_Def.begin'
                       ,x_msg         => 'Calling Create_Assign_With_Def'
                       ,x_log_level   => 5);
  END IF;
  --
  -- Call the create staff assignment with defaults public API

  PA_ASSIGNMENTS_PUB.Create_Assign_With_Def
  ( p_assignment_rec             => l_assignment_rec
   ,p_asgn_creation_mode         => p_asgn_creation_mode
   ,p_role_name                  => p_role_name
   ,p_project_name               => p_project_name
   ,p_project_number             => p_project_number
   ,p_resource_name              => p_resource_name
   ,p_resource_source_id         => p_resource_source_id
   ,p_init_msg_list              => p_init_msg_list
   ,p_commit                     => p_commit
   ,p_validate_only              => p_validate_only
   ,p_max_msg_count              => p_max_msg_count
   ,x_new_assignment_id          => x_new_assignment_id
   ,x_assignment_number          => x_assignment_number
   ,x_assignment_row_id          => x_assignment_row_id
   ,x_return_status              => l_return_status
   ,x_msg_count                  => x_msg_count
   ,x_msg_data                   => x_msg_data
);


  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENTS_PUB.Execute_Create_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END Exec_Create_Assign_With_Def;


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
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )

IS

  l_assignment_rec          PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_return_status           VARCHAR2(1);
  l_schedulable_flag        VARCHAR2(1);
  l_msg_index_out           NUMBER;
  l_menu_id                 NUMBER;
  l_assignment_status_name  PA_PROJECT_STATUSES.project_status_name%TYPE;
  l_job_id                  NUMBER;
  l_error_message_code      fnd_new_messages.message_name%TYPE;
  l_competencies_tbl        PA_HR_COMPETENCE_UTILS.Competency_Tbl_Typ;
  l_location_country_code   pa_locations.country_code%TYPE;
  l_resource_id             pa_resources.resource_id%TYPE;
  l_msg_count               NUMBER;
  l_msg_data                VARCHAR2(4000);
  l_work_type_id            NUMBER;
  l_check_id_flag           VARCHAR2(1);
  l_person_name         PER_PEOPLE_F.full_name%TYPE; -- Bug 3466411
  l_err_msg_code        VARCHAR2(80); -- Bug 3466411
  -- Bug: 4537865
  l_new_project_role_id     pa_project_assignments.project_role_id%TYPE;
  -- Bug: 4537865

-- Commented this cursor for Performance Fix 4898314 SQL ID 14905800
--CURSOR get_project_defaults IS
--SELECT work_type_id, calendar_id, location_id, country_code
--FROM   pa_projects_prm_v
--WHERE  project_id = l_assignment_rec.project_id;

-- Start of Performance Fix 4898314 SQL ID 14905800
CURSOR get_project_defaults IS
SELECT ppa.work_type_id,ppa.calendar_id ,pl.location_id ,pl.country_code
  FROM pa_projects_all ppa,pa_locations pl
WHERE  project_id = l_assignment_rec.project_id
  AND  PPA.LOCATION_ID = PL.LOCATION_ID(+) ;
-- End of Performance Fix 4898314 SQL ID 14905800

BEGIN


  l_assignment_rec := p_assignment_rec;

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Create_Assign_With_Def');

  -- Initialize the error flag
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_FALSE;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASG_PUB_CREATE_ASGMT_WITH_DEF;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN

    FND_MSG_PUB.initialize;
  END IF;
  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assign_With_Def.begin'
                       ,x_msg         => 'Beginning of Create_Assign_With_Def'
                       ,x_log_level   => 5);
  END IF;

  -- Assign the record to the local variable
  l_assignment_rec := p_assignment_rec;

--l_assignment_rec.project_role_id := 2007;

/* A temporary fix:
   Need to avoid the LOV ID clearing check implemented in most validation packages.
   Since only the ids are passed in and not the names.
*/

l_check_id_flag := PA_STARTUP.G_Check_ID_Flag;
IF PA_STARTUP.G_Calling_Application = 'SELF_SERVICE' THEN
   PA_STARTUP.G_Check_ID_Flag := 'N';
END IF;

     --
     -- Validate Role details
     --

     PA_ROLE_UTILS.Check_Role_Name_Or_Id( p_role_id            => l_assignment_rec.project_role_id
                                         ,p_role_name          => p_role_name
                                         ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                       --,x_role_id            => l_assignment_rec.project_role_id      Bug: 4537865
                                         ,x_role_id            => l_new_project_role_id                 -- Bug: 4537865
                                         ,x_return_status      => l_return_status
                                         ,x_error_message_code => l_error_message_code );
   -- Bug: 4537865
         IF l_return_status =  FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.project_role_id := l_new_project_role_id;
         END IF;
   -- Bug: 4537865

  --
  -- Get role default values and forecast defaults
  --

  IF l_assignment_rec.project_role_id IS NOT NULL THEN

     --
     -- Get role default values
     --
     PA_ROLE_UTILS.Get_Role_Defaults( p_role_id               => l_assignment_rec.project_role_id
                                  ,x_meaning               => l_assignment_rec.assignment_name
                                  ,x_default_min_job_level => l_assignment_rec.min_resource_job_level
                                  ,x_default_max_job_level => l_assignment_rec.max_resource_job_level
                                  ,x_menu_id               => l_menu_id
                                  ,x_schedulable_flag      => l_schedulable_flag
                                  ,x_default_job_id        => l_job_id
                                  ,x_def_competencies      => l_competencies_tbl
                                  ,x_return_status         => l_return_status
                                  ,x_error_message_code    => l_error_message_code );


     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => l_error_message_code );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

     IF l_schedulable_flag <> 'Y' THEN
        PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_ROLE_NOT_SCHEDULABLE' );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        return;
     END IF;

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assign_With_Def.role_defaults'
                         ,x_msg         => 'After gettting role defaults'
                         ,x_log_level   => 5);
    END IF;

     --
     --Get forecast defaults
     --

     PA_FORECAST_ITEMS_UTILS.Get_Assignment_Default(
                                  p_assignment_type             => l_assignment_rec.assignment_type,
                                  p_project_id                  => l_assignment_rec.project_id,
                                  p_project_role_id             => l_assignment_rec.project_role_id,
                                  p_work_type_id                => NULL, -- Bug 2318503
                                  x_work_type_id                => l_work_type_id,
                                  x_default_tp_amount_type      => l_assignment_rec.fcst_tp_amount_type,
                                  x_default_job_group_id        => l_assignment_rec.fcst_job_group_id,
                                  x_default_job_id              => l_assignment_rec.fcst_job_id,
                                  x_org_id                      => l_assignment_rec.expenditure_org_id,
                                  x_carrying_out_organization_id=> l_assignment_rec.expenditure_organization_id,
                                  x_default_assign_exp_type     => l_assignment_rec.expenditure_type,
                                  x_default_assign_exp_type_cls => l_assignment_rec.expenditure_type_class,
                                  x_return_status               => l_return_status,
                                  x_msg_count                   => l_msg_count,
                                  x_msg_data                    => l_msg_data
                                  );
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assign_With_Def.utilization_defaults'
                         ,x_msg         => 'After gettting utilization defaults'
                         ,x_log_level   => 5);
    END IF;
   END IF;

   OPEN get_project_defaults;

   FETCH get_project_defaults INTO l_assignment_rec.work_type_id, l_assignment_rec.calendar_id, l_assignment_rec.location_id, l_location_country_code;

   IF get_project_defaults%NOTFOUND THEN

      PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_CANNOT_GET_PROJ_DEFAULTS');
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

   END IF;

   CLOSE get_project_defaults;

  --Set calendar_type to 'PROJECT'as default
  l_assignment_rec.calendar_type := 'PROJECT';

  FND_PROFILE.Get('PA_START_STAFFED_ASGMT_STATUS',l_assignment_rec.status_code);

  IF l_assignment_rec.status_code IS NULL THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  END IF;

  -- Bug 3466411
  -- Retrieve default staffing owner person id
  pa_assignment_utils.Get_Default_Staffing_Owner
  ( p_project_id                  => l_assignment_rec.project_id
   ,p_exp_org_id                  => null
   ,x_person_id                   => l_assignment_rec.staffing_owner_person_id
   ,x_person_name                 => l_person_name
   ,x_return_status               => x_return_status
   ,x_error_message_code          => l_err_msg_code);

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assign_With_Def.create_asgmt'
                       ,x_msg         => 'Calling Create_Assignment'
                       ,x_log_level   => 5);
  END IF;

  PA_ASSIGNMENTS_PUB.Create_Assignment
  ( p_assignment_rec             => l_assignment_rec
   ,p_asgn_creation_mode         => p_asgn_creation_mode
   ,p_project_name               => p_project_name
   ,p_project_number             => p_project_number
   ,p_resource_name              => p_resource_name
   ,p_resource_source_id         => p_resource_source_id
   ,p_project_role_name          => p_role_name
   ,p_location_country_code      => l_location_country_code
   ,p_api_version                => p_api_version
   ,p_commit                     => p_commit
   ,p_validate_only              => p_validate_only
   ,p_max_msg_count              => p_max_msg_count
   ,x_new_assignment_id          => x_new_assignment_id
   ,x_assignment_number          => x_assignment_number
   ,x_assignment_row_id          => x_assignment_row_id
   ,x_resource_id                => l_resource_id
   ,x_return_status              => l_return_status
   ,x_msg_count                  => x_msg_count
   ,x_msg_data                   => x_msg_data
);

--set the global check_id_flag back to the orignal
PA_STARTUP.G_Check_ID_Flag := l_check_id_flag;

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF FND_MSG_PUB.Count_Msg >0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     ELSE
        ROLLBACK TO ASG_PUB_CREATE_ASGMT_WITH_DEF;
     END IF;
  END IF;

  -- Put any message text from message stack into the Message ARRAY
  --
  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_CREATE_ASGMT_WITH_DEF;
        END IF;
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Create_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
--

END Create_Assign_With_Def;




PROCEDURE Create_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
 ,p_project_name                IN    pa_projects_all.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_project_number              IN    pa_projects_all.segment1%TYPE                    := FND_API.G_MISS_CHAR
 ,p_resource_name               IN     pa_resources.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_project_subteam_id          IN     pa_project_subteams.project_subteam_id%TYPE     := FND_API.G_MISS_NUM
 ,p_project_subteam_name        IN     pa_project_subteams.name%TYPE                   := FND_API.G_MISS_CHAR
 ,p_project_status_name         IN     pa_project_statuses.project_status_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_staffing_priority_name      IN    pa_lookups.meaning%TYPE                          := FND_API.G_MISS_CHAR
 ,p_project_role_name           IN     pa_project_role_types.meaning%TYPE              := FND_API.G_MISS_CHAR
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_name       IN     fnd_territories_tl.territory_short_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_calendar_name               IN     jtf_calendars_tl.calendar_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_work_type_name              IN     pa_work_types_vl.name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_role_list_id                IN     pa_role_lists.role_list_id%TYPE                 := FND_API.G_MISS_NUM
 ,p_adv_action_set_id           IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_start_adv_action_set_flag   IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_adv_action_set_name         IN     pa_action_sets.action_set_name%TYPE             := FND_API.G_MISS_CHAR
 ,p_staffing_owner_name        IN     per_people_f.full_name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_sum_tasks_flag                          IN     VARCHAR2                                                                                := FND_API.G_FALSE  -- FP.M Development
 ,p_budget_version_id                   IN         pa_resource_assignments.budget_version_id%TYPE  := FND_API.G_MISS_NUM
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
 )
IS

 l_assignment_rec              PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_resource_source_id          NUMBER;
 -- Bug: 4537865
 l_new_resource_source_id      NUMBER;
 l_new_project_role_id         pa_project_assignments.project_role_id%TYPE;
 l_new_role_list_id            pa_role_lists.role_list_id%TYPE;
 l_new_calendar_id             pa_project_assignments.calendar_id %TYPE;
 l_new_staffing_priority_code  pa_project_assignments.staffing_priority_code%TYPE;
 -- Bug: 4537865
 l_location_country_name       fnd_territories_tl.territory_short_name%TYPE;
 l_location_country_code       fnd_territories.territory_code%TYPE;
 l_calendar_id                 jtf_calendars_b.calendar_id%TYPE;
 l_return_status               VARCHAR2(1);
 l_error_message_code          fnd_new_messages.message_name%TYPE;
 l_unfilled_assignment_id      pa_project_assignments.assignment_id%TYPE;
 l_resource_type_id            NUMBER;
 l_msg_index_out               NUMBER;
 l_msg_count                   NUMBER;
 l_msg_data                    VARCHAR2(2000);
 l_valid_flag                  VARCHAR2(1);
 l_project_status_type         PA_PROJECT_STATUSES.status_type%TYPE := null;
 l_status_code                 PA_PROJECT_STATUSES.project_status_code%TYPE;
 l_subteam_id                  pa_project_subteams.project_subteam_id%TYPE;
 l_admin_flag                  pa_project_types_all.administrative_flag%TYPE;
 l_unassigned_time             pa_project_types_all.unassigned_time%TYPE;
 l_object_type                 pa_project_subteams.object_type%TYPE;
 l_object_id                   pa_project_subteams.object_id%TYPE;
 l_workflow_in_progress_flag   pa_team_templates.workflow_in_progress_flag%TYPE;
 l_role_list_id                pa_role_lists.role_list_id%TYPE;
 l_project_id                  pa_project_assignments.project_id%TYPE;
 l_adv_action_set_id           NUMBER;

 l_temp_expenditure_type_class pa_project_assignments.expenditure_type_class%TYPE;
 l_temp_work_type_id           pa_project_assignments.work_type_id%TYPE;
 l_temp_staff_owner_person_id NUMBER;
 l_valid_assign_start_flag     VARCHAR2(1) := 'Y';   -- Bug 6411422
 l_profile_begin_date          DATE;                 -- Bug 6411422

-- Commented this cursor for Performance Fix 4898314 SQL ID 14905832
-- CURSOR get_project_number_info IS
-- SELECT administrative_flag, calendar_id, project_currency_code, unassigned_time
-- FROM   pa_projects_prm_v
-- WHERE  segment1 = p_project_number;

-- Start of Performance Fix 4898314 SQL ID 14905832
CURSOR get_project_number_info IS
SELECT ppt.administrative_flag, ppa.calendar_id, ppa.project_currency_code, ppt.unassigned_time
  FROM pa_projects_all ppa,pa_project_types_all ppt
WHERE  segment1 = p_project_number
   AND PPA.PROJECT_TYPE = PPT.PROJECT_TYPE
   AND PPA.ORG_ID = PPT.ORG_ID;
-- End of Performance Fix 4898314 SQL ID 14905832

 CURSOR get_expenditure_type_class IS
 SELECT system_linkage_function
 FROM   pa_expend_typ_sys_links_v
 WHERE  expenditure_type = l_assignment_rec.expenditure_type
 AND    system_linkage_function in ('ST', 'OT');

 CURSOR check_team_template_wf IS
 SELECT workflow_in_progress_flag
   FROM pa_team_templates
  WHERE team_template_id = l_assignment_rec.assignment_template_id;

 CURSOR get_resource_source_id IS
 SELECT person_id
 FROM   pa_resource_txn_attributes
 WHERE  resource_id = l_assignment_rec.resource_id;

BEGIN

  IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
            ,x_msg         => 'Entrance of pub.Create_Assignment'
            ,x_log_level   => li_message_level);
  END IF;

  --dbms_output.put_line('PA_ASSIGNMENTS_PUB.Create_Assignment');
  /* Moved the call for deleting the global table from below to above for bug 3079906*/
  PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.DELETE;
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Create_Assignment');

  -- Initialize the error flag
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_FALSE;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASG_PUB_CREATE_ASSIGNMENT;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment.begin'
                       ,x_msg         => 'Beginning of Create_Assignment'
                       ,x_log_level   => 5);
  END IF;

  -- Assign the record to the local variable
  l_assignment_rec := p_assignment_rec;

  --------------------------------------------------------------------
  -- Bug Ref : 6411422 ---
  -- Keeping this check for Making sure that no assignments are created
  -- with Start date prior to the Profile value for utilization date.
  --------------------------------------------------------------------
  IF (l_assignment_rec.project_id IS NOT NULL or l_assignment_rec.project_id <> FND_API.G_MISS_NUM) THEN
   l_valid_assign_start_flag := PA_PROJECT_DATES_UTILS.IS_VALID_ASSIGN_START_DATE( p_project_id => l_assignment_rec.project_id,
                                                                            p_assign_start_date => l_assignment_rec.start_date ) ;
  END IF ;
  IF ( l_valid_assign_start_flag = 'Y' ) THEN
  --if this is a template requirement then check that worflow is not in progress
  --on the parent team template.  If it is in progress then no new template requirements
  --can be created.
  IF (l_assignment_rec.project_id IS NULL or l_assignment_rec.project_id = FND_API.G_MISS_NUM) AND
     (l_assignment_rec.assignment_template_id IS NOT NULL and l_assignment_rec.assignment_template_id <>FND_API.G_MISS_NUM) THEN

     OPEN check_team_template_wf;
     FETCH check_team_template_wf INTO l_workflow_in_progress_flag;
     CLOSE check_team_template_wf;

     IF l_workflow_in_progress_flag='Y' THEN
        PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_NO_REQ_WF');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;

-- Bug 2513254
-- Comment this IF condition out so that this part of the code will be executed
-- within workflow autonomous transaction
--IF PA_STARTUP.G_Calling_Application = 'SELF_SERVICE' THEN

  --When project number is present, do the Project Number validation
  --IF project number is present, but not project id, then get the defaults from project table
  -- IF the passed in calendar type is 'PROJECT', then use the default Calendar.

  --Assumption: Add Template Requirement does not pass in Project Number

  IF P_DEBUG_MODE = 'Y' THEN
         pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
          ,x_msg         => 'before check project number'
          ,x_log_level   => li_message_level);
  END IF;

  --Check to see if project number is passed in
  IF (p_project_number IS NOT NULL AND p_project_number <> FND_API.G_MISS_CHAR )THEN

        IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
            ,x_msg         => 'project number is ok'
            ,x_log_level   => li_message_level);
        END IF;

    --Do Number to ID validation
    PA_PROJECT_UTILS2.Check_Project_Number_Or_Id
                  ( p_project_id        => l_assignment_rec.project_id
                   ,p_project_number    => p_project_number
                   ,p_check_id_flag     => PA_STARTUP.G_Check_ID_Flag
                   ,x_project_id        => l_project_id
                   ,x_return_status     => l_return_status
                   ,x_error_message_code => l_error_message_code );

    --dbms_output.put_line('error_message_code :'||l_error_message_code);

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => l_error_message_code);
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;
    l_return_status := FND_API.G_MISS_CHAR;
    l_error_message_code := FND_API.G_MISS_CHAR;


     -- Bug 2513254
     -- Comment this IF condition out so that this part of the code
     -- will be executed within Mass Transaction workflow
    --If project id is not passed in, then get defaults from project table
--    IF (l_assignment_rec.project_id IS NULL OR l_assignment_rec.project_id = FND_API.G_MISS_NUM) THEN

        --dbms_output.put_line('Before Get project_number_info');

                IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
                ,x_msg         => 'before get calendar id'
                ,x_log_level   => li_message_level);
                END IF;

        --Get the Administrative Flag, calendar id, currency code  from the fetched Project ID
        OPEN get_project_number_info;
        FETCH get_project_number_info INTO l_admin_flag, l_calendar_id,
                                           l_assignment_rec.expense_limit_currency_code, l_unassigned_time;
        CLOSE get_project_number_info;

        --dbms_output.put_line('After Get project_number_info');

        --
        --Return error if a non-admin project is used to Create Admin Assignment or
        -- an admin project is used to Create Delivery Assignment
        --
        IF (l_assignment_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' AND
            l_admin_flag <> 'Y') OR
           (l_assignment_rec.assignment_type = 'STAFFED_ASSIGNMENT' AND l_admin_flag = 'Y') THEN
                PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                     ,p_msg_name       => 'PA_CREATE_ADMIN_RESTRICT');
                PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF; --staffed admin or staffed assignment with admin project

                IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
                ,x_msg         => 'before calendar=PROJECT?'
                ,x_log_level   => li_message_level);
                END IF;

        --
        --IF Calendar Type is 'PROJECT', then set calendar_id as the default from the project table.
        --
        IF l_assignment_rec.calendar_type = 'PROJECT' THEN
          l_assignment_rec.calendar_id := l_calendar_id;
        END IF;
--     END IF; --end of project id not passed in

     --
     --Set the project id to the result after the project number validation
     l_assignment_rec.project_id := l_project_id;

  END IF; --end of project number is passed in.
--END IF; -- end of self-service
        --dbms_output.put_line('end of project number');

  --validate that the project is not an unassigned time project.
  --assignments are not allowed on unassigned time projects
  IF l_assignment_rec.project_id IS NOT NULL and l_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN
     IF l_unassigned_time IS NULL THEN
        l_unassigned_time := PA_PROJECT_UTILS.is_unassigned_time_project(l_assignment_rec.project_id);
     END IF;
     IF l_unassigned_time = 'Y' THEN
        PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_NO_ASGMT_UNASSIGN_TIME_PROJ');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

    -- Check for Org Project
    PA_FP_ORG_FCST_UTILS.detect_org_project(
      p_project_id        => l_assignment_rec.project_id,
      x_return_status     => l_return_status,
      x_err_code          => l_error_message_code
    );

    IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      PA_ASSIGNMENT_UTILS.Add_Message(
               p_app_short_name => 'PA'
              ,p_msg_name       => l_error_message_code
      );
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;

    l_return_status := FND_API.G_MISS_CHAR;
    l_error_message_code := FND_API.G_MISS_CHAR;

  END IF;

  --Check that start_date <= end_date
  --
  IF  l_assignment_rec.start_date > l_assignment_rec.end_date THEN
    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_INVALID_START_DATE');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;


  --
  -- Validate Resource detail
  --
  --if this a mass assignment online validation then don't need to validate
  --the resource ids - they must be valid.
  IF p_asgn_creation_mode <> 'MASS' THEN
   IF l_assignment_rec.assignment_type <> 'OPEN_ASSIGNMENT' THEN
     IF l_assignment_rec.resource_id IS NOT NULL AND l_assignment_rec.resource_id <> FND_API.G_MISS_NUM THEN

      OPEN get_resource_source_id;
      FETCH get_resource_source_id INTO l_resource_source_id;
      CLOSE get_resource_source_id;

    ELSE
      l_resource_source_id := p_resource_source_id;
    END IF;  -- resource id not null

    PA_RESOURCE_UTILS.Check_ResourceName_Or_Id ( p_resource_id        => l_resource_source_id
                                                ,p_resource_name      => p_resource_name
                                                ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                ,p_date               => l_assignment_rec.start_date
                                                ,p_end_date           => l_assignment_rec.end_date -- 3235018 : Added this
                                              --,x_resource_id        => l_resource_source_id           * Bug: 4537865
                                                ,x_resource_id        => l_new_resource_source_id       --Bug: 4537865
                                                ,x_resource_type_id   => l_resource_type_id
                                                ,x_return_status      => l_return_status
                                                ,x_error_message_code => l_error_message_code);
    -- Bug: 4537865
    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        l_resource_source_id := l_new_resource_source_id;
    END IF;
    -- Bug: 4537865

    IF l_return_status = FND_API.G_RET_STS_ERROR THEN
      PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => l_error_message_code);
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
      l_assignment_rec.resource_id := NULL;
    END IF;

    l_return_status := FND_API.G_MISS_CHAR;
    l_error_message_code := FND_API.G_MISS_CHAR;
  END IF; -- if open assignment
 END IF; -- if mass

  --
  -- Validate Status code
  --
  -- need to convert from assignment status types to the status type
  -- defined in pa_project_statuses.

  --don't need to validate status if copying a team role

  IF p_asgn_creation_mode <> 'COPY' THEN

     IF l_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' THEN

        l_project_status_type := 'OPEN_ASGMT';

     ELSIF l_assignment_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN

        l_project_status_type := 'STAFFED_ASGMT';

     ELSIF l_assignment_rec.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN

        l_project_status_type := 'STAFFED_ASGMT';

     END IF;

     IF l_assignment_rec.status_code = FND_API.G_MISS_CHAR THEN

        l_status_code := null;

     ELSE l_status_code := l_assignment_rec.status_code;

     END IF;

     PA_PROJECT_STUS_UTILS.Check_Status_Name_Or_Code ( p_status_code        => l_status_code
                                                      ,p_status_name        => p_project_status_name
                                                      ,p_status_type        => l_project_status_type
                                                      ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                      ,x_status_code        => l_assignment_rec.status_code
                                                      ,x_return_status      => l_return_status
                                                      ,x_error_message_code => l_error_message_code);
     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                       , p_msg_name       => l_error_message_code);
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     l_return_status := FND_API.G_MISS_CHAR;
     l_error_message_code := FND_API.G_MISS_CHAR;

   END IF;


     -- Validate Staffing Owner
     IF (l_assignment_rec.staffing_owner_person_id <> FND_API.G_MISS_NUM
        AND l_assignment_rec.staffing_owner_person_id IS NOT NULL)
        OR (p_staffing_owner_name <> FND_API.G_MISS_CHAR and p_staffing_owner_name IS NOT NULL) THEN

        l_temp_staff_owner_person_id := l_assignment_rec.staffing_owner_person_id;
        PA_RESOURCE_UTILS.Check_ResourceName_Or_Id (
              p_resource_id        => l_temp_staff_owner_person_id
             ,p_resource_name      => p_staffing_owner_name
             ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
             ,p_date               => sysdate
             ,x_resource_id        => l_assignment_rec.staffing_owner_person_id
             ,x_resource_type_id   => l_resource_type_id
             ,x_return_status      => l_return_status
             ,x_error_message_code => l_error_message_code);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_resource_type_id <> 101 THEN
           PA_UTILS.Add_Message ('PA', 'PA_INV_STAFF_OWNER');
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;

        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;

         IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
             ,x_msg         => 'before calendar = resource'
             ,x_log_level   => li_message_level);
         END IF;

   --
   --Check that resource calendar percent is between 0 and 100 if calender type is resource.
   --
   IF l_assignment_rec.calendar_type = 'RESOURCE' AND
     (l_assignment_rec.resource_calendar_percent IS NULL OR l_assignment_rec.resource_calendar_percent < 0  OR l_assignment_rec.resource_calendar_percent > 100) THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => 'PA_CALENDAR_PERCENT_INVALID');
     PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
   END IF;

  -- initialize local action set id variable
  --
  l_adv_action_Set_id := p_adv_action_set_id;

  -- The value to ID conversions which follow are not required
  -- in the following 2 cases:
  --
  -- 1) a staffed assignment is being created from an open assignment
  -- 2) an new open assignment is being created because the previous
  --    open assignment was partially filled.

  IF l_assignment_rec.source_assignment_id = FND_API.G_MISS_NUM THEN

     --
     -- Validate Role details
     -- This API will validate
     -- 1) the role
     -- 2) that the role belongs to the role list(if any)

     --if the role list is not passed to the API then get it from the
     --project or team template.
     --PRM client side may pass in -999 b/c they can't pass in
     --FND_API.G_MISS_NUM and they need to bind the variable with something
     --as this API call is used in a number of different situations
     ---  -999 should be treated as FND_API.G_MISS_NUM
     IF p_role_list_id = FND_API.G_MISS_NUM OR p_role_list_id = -999 THEN
        IF l_assignment_rec.project_id IS NOT NULL  AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN
           SELECT role_list_id INTO l_role_list_id
             FROM pa_projects_all
            WHERE project_id = l_assignment_rec.project_id;
        ELSIF l_assignment_rec.assignment_template_id IS NOT NULL  AND l_assignment_rec.assignment_template_id <> FND_API.G_MISS_NUM THEN
           SELECT role_list_id INTO l_role_list_id
             FROM pa_team_templates
            WHERE team_template_id = l_assignment_rec.assignment_template_id;
        END IF;
      ELSE
        l_role_list_id := p_role_list_id;
      END IF;

     PA_ROLE_UTILS.Check_Role_RoleList ( p_role_id            => l_assignment_rec.project_role_id
                                         ,p_role_name          => p_project_role_name
                                         ,p_role_list_id       => l_role_list_id
                                         ,p_role_list_name     => NULL
                                         ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                       --,x_role_id            => l_assignment_rec.project_role_id              Bug: 4537865
                                         ,x_role_id            => l_new_project_role_id                       --Bug: 4537865
                                       --,x_role_list_id       => l_role_list_id                                Bug: 4537865
                                         ,x_role_list_id       => l_new_role_list_id                          --Bug: 4537865
                                         ,x_return_status      => l_return_status
                                         ,x_error_message_code => l_error_message_code );
      -- Bug: 4537865
     IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.project_role_id := l_new_project_role_id;
                l_role_list_id                   := l_new_role_list_id;
     END IF;
     -- Bug: 4537865

     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
       PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                           , p_msg_name       => l_error_message_code );
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     l_return_status := FND_API.G_MISS_CHAR;
     l_error_message_code := FND_API.G_MISS_CHAR;

        --dbms_output.put_line('After Check Role List');

     --
     -- Validate Location detail
     -- If country name is valid ans country_code is null returns the country_code
     --
     --No Need to Validate if country code and name are both not passed in

     IF (p_location_country_code IS NOT NULL AND p_location_country_code <> FND_API.G_MISS_CHAR) OR
        (p_location_country_name IS NOT NULL AND p_location_country_name <> FND_API.G_MISS_CHAR) THEN

       PA_LOCATION_UTILS.Check_Country_Name_Or_Code( p_country_code       => p_location_country_code
                                                    ,p_country_name       => p_location_country_name
                                                    ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                    ,x_country_code       => l_location_country_code
                                                    ,x_return_status      => l_return_status
                                                    ,x_error_message_code => l_error_message_code );
       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;
     -- if country is not passed in, but region/city is passed in, give an error.
     ELSIF (p_location_city IS NOT NULL AND p_location_city <> FND_API.G_MISS_CHAR) OR
           (p_location_region IS NOT NULL AND p_location_region <> FND_API.G_MISS_CHAR) THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_COUNTRY_INVALID');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

     --
     --
     -- Validate assignment Job Levels only for Open Assignments
     --

     IF l_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' THEN

        -- Check Min level
        PA_JOB_UTILS.Check_JobLevel( p_level              => l_assignment_rec.min_resource_job_level
                                    ,x_valid              => l_valid_flag
                                    ,x_return_status      => l_return_status
                                    ,x_error_message_code => l_error_message_code );
        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                            ,p_msg_name       => l_error_message_code );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;

        -- Check Max level
        PA_JOB_UTILS.Check_JobLevel( p_level              => l_assignment_rec.max_resource_job_level
                                    ,x_valid              => l_valid_flag
                                    ,x_return_status      => l_return_status
                                    ,x_error_message_code => l_error_message_code );
        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                            ,p_msg_name       => l_error_message_code );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;

        -- Check that max job level is >= min job level
        --
        IF  l_assignment_rec.min_resource_job_level > l_assignment_rec.max_resource_job_level THEN
           PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                           ,p_msg_name       => 'PA_MIN_JL_GREATER_THAN_MAX');
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;

        --
        -- Validate number of requirements only for Open Assignments
        --

        IF p_number_of_requirements - ROUND(p_number_of_requirements) <> 0
           OR p_number_of_requirements < 1 THEN

           PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name  => 'PA_INVALID_REQ_COPIES_NO' );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;

     END IF;

     --
     --Validate Subteam Name / Subteam Id
     --
     IF  ((p_project_subteam_id IS NOT NULL AND p_project_subteam_id <> FND_API.G_MISS_NUM) OR
         (p_project_subteam_name IS NOT NULL AND p_project_subteam_name <> FND_API.G_MISS_CHAR)) AND
         ((l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <>FND_API.G_MISS_NUM) OR
         (l_assignment_rec.assignment_template_id IS NOT NULL AND l_assignment_rec.assignment_template_id <> FND_API.G_MISS_NUM)) THEN

       IF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <>FND_API.G_MISS_NUM THEN

           l_object_type := 'PA_PROJECTS';

           l_object_id := l_assignment_rec.project_id;

       ELSIF l_assignment_rec.assignment_template_id IS NOT NULL AND l_assignment_rec.assignment_template_id <> FND_API.G_MISS_NUM THEN

           l_object_type := 'PA_TEAM_TEMPLATES';

           l_object_id := l_assignment_rec.assignment_template_id;

        END IF;

        l_subteam_id := p_project_subteam_id;

        IF (l_subteam_id = FND_API.G_MISS_NUM) THEN
           l_subteam_id := NULL;
        END IF;

        PA_PROJECT_SUBTEAM_UTILS.Check_Subteam_Name_Or_Id( p_subteam_name       => p_project_subteam_name
                                                          ,p_object_type        => l_object_type
                                                          ,p_object_id          => l_object_id
                                                          ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                          ,x_subteam_id         => l_subteam_id
                                                          ,x_return_status      => l_return_status
                                                          ,x_error_message_code => l_error_message_code );
        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN

         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => l_error_message_code );
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;
     END IF;
     --dbms_output.put_line('Project Subteam Id'||l_subteam_id);

         IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
             ,x_msg         => 'before calendar = project'
             ,x_log_level   => li_message_level);
         END IF;

     /* Bug 2887390 : Added the following condition */
     IF (l_assignment_rec.calendar_type = 'PROJECT' AND l_assignment_rec.calendar_id is NULL)
     THEN
          PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_INVALID_CAL_PROJ_SETUP' );

          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

     --
     --Calendar validation is only necessary when
     -- 1) For self-service, only Other calendar type need the check (since the project calendar is not user entered)
     -- 2) For non self-service, resource calendar does not need to be checked.

     IF ((l_assignment_rec.calendar_type = 'OTHER' AND PA_STARTUP.G_Calling_Application = 'SELF_SERVICE')
        OR (l_assignment_rec.calendar_type <> 'RESOURCE' AND PA_STARTUP.G_Calling_Application <> 'SELF_SERVICE')) THEN

                IF P_DEBUG_MODE = 'Y' THEN
           pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
                ,x_msg         => 'cal_id='||l_assignment_rec.calendar_id||
                                                                  ', cal_name=' ||p_calendar_name
                ,x_log_level   => li_message_level);
                END IF;

        --
        -- Validate Calendar detail
        -- If calendar name is valid and calendar_id is null then returns the calendar_id
        --
        PA_CALENDAR_UTILS.Check_Calendar_Name_Or_Id( p_calendar_id        => l_assignment_rec.calendar_id
                                                   ,p_calendar_name      => p_calendar_name
                                                   ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                 --,x_calendar_id        => l_assignment_rec.calendar_id        * Bug: 4537865
                                                   ,x_calendar_id        => l_new_calendar_id                   --Bug: 4537865
                                                   ,x_return_status      => l_return_status
                                                   ,x_error_message_code => l_error_message_code );
        -- Bug:4537865
        IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.calendar_id := l_new_calendar_id;
        END IF;
        -- Bug:4537865

        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;
        --dbms_output.put_line('After Calendar Check');

     --
     -- Validate Work Type
     -- If work type name is valid and work_type_id is null then returns the work_type_id
     --
         IF P_DEBUG_MODE = 'Y' THEN
        pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
             ,x_msg         => 'work_type_id='||l_assignment_rec.work_type_id||
                          ', work_type_name='||p_work_type_name||
                                          ', flag='||PA_STARTUP.G_Check_ID_Flag
             ,x_log_level   => li_message_level);
         END IF;

     -- Bug 4499172
     l_temp_work_type_id := l_assignment_rec.work_type_id;
     PA_WORK_TYPE_UTILS.Check_Work_Type_Name_Or_Id( p_work_type_id       => l_temp_work_type_id
                                                   ,p_name               => p_work_type_name
                                                   ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                   ,x_work_type_id       => l_assignment_rec.work_type_id
                                                   ,x_return_status      => l_return_status
                                                   ,x_error_message_code => l_error_message_code );



     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
       PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     l_return_status := FND_API.G_MISS_CHAR;
     l_error_message_code := FND_API.G_MISS_CHAR;


    IF l_assignment_rec.expenditure_type IS NOT NULL AND l_assignment_rec.expenditure_type <> FND_API.G_MISS_CHAR THEN
     --
     --Validate Expenditure Type
     --

     --Call Name to ID validation
     PA_EXPENDITURES_UTILS.Check_Expenditure_Type( p_expenditure_type   => l_assignment_rec.expenditure_type
                                                    ,p_date               => l_assignment_rec.start_date
                                                    ,x_valid              => l_valid_flag
                                                    ,x_return_status      => l_return_status
                                                    ,x_error_message_code => l_error_message_code);

     IF  l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     l_return_status := FND_API.G_MISS_CHAR;
     l_error_message_code := FND_API.G_MISS_CHAR;


     --
     --Validate Expenditure Type Class
     --

     --Call Name to ID validation
     IF (l_assignment_rec.expenditure_type_class IS NOT NULL) AND
        (l_assignment_rec.expenditure_type_class <> FND_API.G_MISS_CHAR) THEN

       l_temp_expenditure_type_class := l_assignment_rec.expenditure_type_class;
       PA_EXPENDITURES_UTILS.Check_Exp_Type_Class_Code(
                        p_sys_link_func     => l_temp_expenditure_type_class
                       ,p_exp_meaning       => NULL
                       ,p_check_id_flag     => PA_STARTUP.G_Check_ID_Flag
                       ,x_sys_link_func     => l_assignment_rec.expenditure_type_class
                       ,x_return_status     => l_return_status
                       ,x_error_message_code=> l_error_message_code) ;
       IF  l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     --else get expenditure type class using expenditure type
     ELSIF  (l_assignment_rec.expenditure_type <> NULL
         AND l_assignment_rec.expenditure_type <>FND_API.G_MISS_CHAR) THEN
       --Get expenditure type class code
       OPEN get_expenditure_type_class;
       FETCH get_expenditure_type_class INTO l_assignment_rec.expenditure_type_class;

       IF get_expenditure_type_class%NOTFOUND THEN
           PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_EXPTYPE_INVALID' );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       CLOSE get_expenditure_type_class;
     END IF;



     --
     --Validate Expenditure Type and Type Class comb
     l_valid_flag := 'Y'; --
     PA_EXPENDITURES_UTILS.Check_Exp_Type_Sys_Link_Combo(
                        p_exp_type          => l_assignment_rec.expenditure_type
                       ,p_ei_date           => l_assignment_rec.start_date
                       ,p_sys_link_func     => l_assignment_Rec.expenditure_type_class
                       ,x_valid             => l_valid_flag
                       ,x_return_status     => l_return_status
                       ,x_error_message_code=> l_error_message_code);

      -- 5130421 : We shd check both l_return_status and also l_valid_flag
      -- This is because of a bug in Check_Exp_Type_Sys_Link_Combo code
     --IF  l_return_status = FND_API.G_RET_STS_ERROR  THEN
     IF l_valid_flag <> 'Y' THEN
        PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_EXPTYPE_SYSLINK_INVALID' );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     IF l_return_status = FND_API.G_RET_STS_ERROR THEN
        PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     l_return_status := FND_API.G_MISS_CHAR;
     l_error_message_code := FND_API.G_MISS_CHAR;
    END IF; -- end of checking expenditure type and expenditure type class

     -- Bug 5130421 : Validate expense limit to be positive
     IF (l_assignment_rec.expense_limit < 0) THEN
        PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                         ,p_msg_name       => 'PA_EXPENSE_LIMIT_INVALID' );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     -- End Bug 5130421
     --
     --Validate Staffing Priority
     --
     IF (l_assignment_rec.staffing_priority_code IS NOT NULL AND
        l_assignment_rec.staffing_priority_code <> FND_API.G_MISS_CHAR) OR
        (p_staffing_priority_name IS NOT NULL AND p_staffing_priority_name <> FND_API.G_MISS_CHAR) THEN

        PA_ASSIGNMENT_UTILS.Check_STF_PriorityName_Or_Code (p_staffing_priority_code  => l_assignment_rec.staffing_priority_code
                                       ,p_staffing_priority_name  => p_staffing_priority_name
                                       ,p_check_id_flag           => PA_STARTUP.G_Check_ID_Flag
                                     --,x_staffing_priority_code  => l_assignment_rec.staffing_priority_code         Bug:4537865
                                       ,x_staffing_priority_code  => l_new_staffing_priority_code                    --Bug:4537865
                                       ,x_return_status           => l_return_status
                                       ,x_error_message_code      => l_error_message_code);
        -- Bug: 4537865
        IF  l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                l_assignment_rec.staffing_priority_code := l_new_staffing_priority_code;
        END IF;
        -- Bug: 4537865
        IF  l_return_status = FND_API.G_RET_STS_ERROR  THEN
          PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;
     END IF;

     --dbms_output.put_line('before calling check action set name or id = '|| p_adv_action_set_id);

     --Validate Advertisement Action Set
     --
     IF (p_adv_action_set_id IS NOT NULL AND p_adv_action_set_id <> FND_API.G_MISS_NUM) OR
        (p_adv_action_set_name IS NOT NULL AND p_adv_action_set_name <> FND_API.G_MISS_CHAR) THEN

       PA_ACTION_SET_UTILS.Check_Action_Set_Name_or_Id(
         p_action_set_id        => p_adv_action_set_id
        ,p_action_set_name      => p_adv_action_set_name
        ,p_action_set_type_code => 'ADVERTISEMENT'
        ,p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag
        ,p_date                 => sysdate
        ,x_action_set_id        => l_adv_action_set_id
        ,x_return_status        => l_return_status
        ,x_error_message_code   => l_error_message_code
       );

       IF  l_return_status = FND_API.G_RET_STS_ERROR  THEN
          PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;

  END IF; --if source_assignment_id IS NULL

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment.after_validation'
                       ,x_msg         => 'Finished Validation, calling private create_assignment'
                       ,x_log_level   => 5);
  END IF;

  IF p_asgn_creation_mode <> 'MASS' OR (p_asgn_creation_mode = 'MASS' AND p_validate_only = FND_API.G_FALSE) THEN

        IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
          ,x_msg         => 'before call pvt.create_assignment'
          ,x_log_level   => li_message_level);
        END IF;

    -- Call the private package
    PA_ASSIGNMENTS_PVT.Create_Assignment
    ( p_assignment_rec               => l_assignment_rec
     ,p_asgn_creation_mode           => p_asgn_creation_mode
     ,p_resource_source_id           => l_resource_source_id
     ,p_project_subteam_id           => l_subteam_id
     ,p_location_city                => p_location_city
     ,p_location_region              => p_location_region
     ,p_location_country_code        => l_location_country_code
     ,p_adv_action_set_id            => l_adv_action_set_id
     ,p_start_adv_action_set_flag    => p_start_adv_action_set_flag
         ,p_sum_tasks_flag                               => p_sum_tasks_flag  -- FP.M Development
         ,p_budget_version_id                    => p_budget_version_id
     ,p_number_of_requirements       => p_number_of_requirements
     ,p_commit                       => p_commit
     ,p_validate_only                => p_validate_only
     ,x_new_assignment_id            => x_new_assignment_id
     ,x_assignment_number            => x_assignment_number
     ,x_assignment_row_id            => x_assignment_row_id
     ,x_resource_id                  => x_resource_id
     ,x_return_status                => l_return_status
    );
        IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Create_Assignment'
          ,x_msg         => 'after call pvt.create_assignment'
          ,x_log_level   => li_message_level);
        END IF;

  END IF;

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --

  x_msg_count :=  FND_MSG_PUB.Count_Msg;

  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  --clear global table of newly created assignment ids
  /* Commented the code for bug 3079906
  PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.DELETE;*/


  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF FND_MSG_PUB.Count_Msg > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     ELSE
        ROLLBACK TO ASG_PUB_CREATE_ASSIGNMENT;
     END IF;
  END IF;

  ELSE -- IF ( l_valid_assign_start_flag = 'Y' )
   -- l_profile_begin_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY'); /* commenting for For Bug 7304151 */
   l_profile_begin_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'); /*Adding For Bug 7304151 */
   PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name => 'PA_INVALID_ASSIGN_START_DATE'
                                    ,p_token1   => 'PROFILE_DATE'
                                    ,p_value1   => l_profile_begin_date );
   PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
   x_return_status := FND_API.G_RET_STS_ERROR;
   l_error_message_code := 'PA_INVALID_ASSIGN_START_DATE';
  END IF; -- IF ( l_valid_assign_start_flag = 'Y' )

  EXCEPTION
    WHEN OTHERS THEN

            IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_CREATE_ASSIGNMENT;
        END IF;

        --clear global table of newly created assignment ids
        PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.DELETE;

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Create_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
--
END Create_Assignment;



PROCEDURE Execute_Staff_Assign_From_Open
( p_asgn_creation_mode          IN    VARCHAR2                                                := 'FULL'
 ,p_record_version_number       IN    NUMBER                                                  := FND_API.G_MISS_NUM
 ,p_multiple_status_flag        IN    pa_project_assignments.multiple_status_flag%TYPE        := FND_API.G_MISS_CHAR
 ,p_assignment_status_code      IN    pa_project_statuses.project_status_code%TYPE            := FND_API.G_MISS_CHAR
 ,p_assignment_status_name      IN    pa_project_statuses.project_status_name%TYPE            := FND_API.G_MISS_CHAR
 ,p_unfilled_assign_status_code  IN    pa_project_statuses.project_status_code%TYPE           := FND_API.G_MISS_CHAR
 ,p_unfilled_assign_status_name  IN    pa_project_statuses.project_status_name%TYPE           := FND_API.G_MISS_CHAR
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
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

  l_assignment_rec      PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
  l_return_status       VARCHAR2(1);
  l_msg_index_out       NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Execute_Staff_Assign_From_Open');

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Execute_Staff_Assign_From_Open.begin'
                       ,x_msg         => 'Beginning of Execute_Staff_Assign_From_Open'
                       ,x_log_level   => 5);
  END IF;

  --
  -- Assign the scalar parameters to the assignment record fields
  --
 BEGIN
  l_assignment_rec.assignment_type             := 'STAFFED_ASSIGNMENT';
  l_assignment_rec.multiple_status_flag        := p_multiple_status_flag;
  l_assignment_rec.status_code                 := p_assignment_status_code;
  l_assignment_rec.resource_id                 := p_resource_id;
  l_assignment_rec.project_party_id            := p_project_party_id;
  l_assignment_rec.start_date                  := p_start_date;
  l_assignment_rec.end_date                    := p_end_date;
  l_assignment_rec.source_assignment_id        := p_source_assignment_id;
  l_assignment_rec.record_version_number       := p_record_version_number;
 END;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Execute_Staff_Assign_From_Open.staff_assign'
                       ,x_msg         => 'Calling Staff_Assign_From_Open'
                       ,x_log_level   => 5);
  END IF;
  --
  -- Call the assign resource to open assignment public API
  PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open
  ( p_assignment_rec             => l_assignment_rec
   ,p_asgn_creation_mode         => p_asgn_creation_mode
   ,p_unfilled_assign_status_code => p_unfilled_assign_status_code
   ,p_unfilled_assign_status_name => p_unfilled_assign_status_name
   ,p_remaining_candidate_code   => p_remaining_candidate_code
   ,p_change_reason_code         => p_change_reason_code
   ,p_resource_name              => p_resource_name
   ,p_resource_source_id         => p_resource_source_id
   ,p_assignment_status_name     => p_assignment_status_name
   ,p_api_version                => p_api_version
   ,p_commit                     => p_commit
   ,p_validate_only              => p_validate_only
   ,p_max_msg_count              => p_max_msg_count
   ,x_new_assignment_id          => x_new_assignment_id
   ,x_assignment_number          => x_assignment_number
   ,x_assignment_row_id          => x_assignment_row_id
   ,x_resource_id                => x_resource_id
   ,x_return_status              => l_return_status
   ,x_msg_count                  => x_msg_count
   ,x_msg_data                   => x_msg_data
);

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  IF x_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     ELSE
        ROLLBACK TO ASG_PUB_STAFF_ASSIGN_FROM_OPEN;
     END IF;
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  EXCEPTION
    WHEN OTHERS THEN

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_ASSIGNMENTS_PUB.Exec_Staff_Assign_From_Open'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs

END Execute_Staff_Assign_From_Open;




PROCEDURE Staff_Assign_From_Open
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
 ,p_unfilled_assign_status_code IN     pa_project_statuses.project_status_code%TYPE    := FND_API.G_MISS_CHAR
 ,p_unfilled_assign_status_name IN     pa_project_statuses.project_status_name%TYPE    := FND_API.G_MISS_CHAR
 ,p_remaining_candidate_code    IN     pa_lookups.lookup_code%TYPE                     := FND_API.G_MISS_CHAR
 ,p_change_reason_code          IN    pa_lookups.lookup_code%TYPE                             := FND_API.G_MISS_CHAR
 ,p_resource_name               IN     pa_resources.name%TYPE                          := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_assignment_status_name      IN     pa_project_statuses.project_status_name%TYPE    := FND_API.G_MISS_CHAR
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
 )
IS

 l_assignment_rec              PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_source_assignment_rec       PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_new_open_assignment_tbl     PA_ASSIGNMENTS_PUB.Assignment_Tbl_Type;
 l_resource_source_id          NUMBER;
 l_return_status               VARCHAR2(1);
 l_error_message_code          fnd_new_messages.message_name%TYPE;
 l_msg_count                   NUMBER;
 l_msg_data                    VARCHAR2(2000);
 l_new_open_asgn_id            NUMBER;
 l_new_open_asgn_number        NUMBER;
 l_new_open_asgn_row_id        ROWID;
 l_resource_type_id            NUMBER;
 l_msg_index_out               NUMBER;
 l_default_filled_status_code  VARCHAR2(80);
 l_sch_exception_id            NUMBER;
 l_status_controls_valid       VARCHAR2(1) := 'Y';
 l_index                       NUMBER;

 l_task_assignment_id_tbl       system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_task_version_id_tbl                  system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_budget_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_struct_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_task_id_tbl                          system.pa_num_tbl_type := system.pa_num_tbl_type();

 l_resource_list_members_tbl    SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_resource_class_flag_tbl              SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
 l_resource_class_code_tbl              SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_resource_class_id_tbl                SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_res_type_code_tbl                    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_incur_by_res_type_tbl                SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_person_id_tbl                                SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_job_id_tbl                                   SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_person_type_code_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_named_role_tbl                               SYSTEM.PA_VARCHAR2_80_TBL_TYPE := system.pa_varchar2_80_tbl_type();
 l_bom_resource_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_non_labor_resource_tbl               SYSTEM.PA_VARCHAR2_20_TBL_TYPE := system.pa_varchar2_20_tbl_type();
 l_inventory_item_id_tbl                SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_item_category_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_project_role_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_organization_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_fc_res_type_code_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_expenditure_type_tbl                 SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_expenditure_category_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_event_type_tbl                               SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_revenue_category_code_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_supplier_id_tbl                              SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_spread_curve_id_tbl                  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_etc_method_code_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_mfc_cost_type_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_incurred_by_res_flag_tbl             SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
 l_incur_by_res_class_code_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_incur_by_role_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_unit_of_measure_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_org_id_tbl                                   SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_rate_based_flag_tbl                  SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
 l_rate_expenditure_type_tbl    SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_rate_func_curr_code_tbl              SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
 l_rate_incurred_by_org_id_tbl  SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
 l_cur_role_flag                                Varchar2(1);

CURSOR check_record_version IS
SELECT ROWID
FROM   pa_project_assignments
WHERE  assignment_id = p_assignment_rec.source_assignment_id
AND    record_version_number = p_assignment_rec.record_version_number;

CURSOR get_status_codes IS
SELECT DISTINCT status_code
  FROM pa_schedules /* Bug 5614557  Changed usage from pa_schedules_v to pa_schedules */
 WHERE assignment_id = p_assignment_rec.source_assignment_id;

CURSOR check_project_assignment_wf IS
SELECT mass_wf_in_progress_flag
  FROM pa_project_assignments
 WHERE assignment_id = p_assignment_rec.source_assignment_id;

 -- get advertisement action set details
 CURSOR get_action_set IS
 SELECT action_set_id, record_version_number
   FROM pa_action_sets
  WHERE object_id = p_assignment_rec.source_assignment_id
    AND object_type = 'OPEN_ASSIGNMENT'
    AND action_set_type_code = 'ADVERTISEMENT'
    AND status_code <> 'DELETED';

 -- get rlm of the new staffed assignment
 CURSOR get_staffed_asgmt_rlm(c_assignment_id NUMBER) IS
 SELECT pa.resource_list_member_id, rta.person_id
   FROM pa_project_assignments pa,
        pa_resource_txn_attributes rta
  WHERE pa.assignment_id = c_assignment_id
    AND pa.resource_id = rta.resource_id;

 CURSOR get_linked_res_asgmts IS
 SELECT resource_assignment_id, wbs_element_version_id, budget_version_id, project_structure_version_id
 FROM
 (
         (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id
          FROM  PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
          WHERE ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
          AND   ra.project_id = l_assignment_rec.project_id
          AND   ra.project_assignment_id = l_assignment_rec.source_assignment_id
          AND   evs.status_code = 'STRUCTURE_WORKING')
   UNION ALL
         (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id
          FROM  PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
                   ,PA_PROJ_WORKPLAN_ATTR pwa
          WHERE pwa.wp_enable_Version_flag = 'N'
          AND   pwa.project_id = ra.project_id
          AND   pwa.proj_element_id = evs.proj_element_id
          AND   ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
          AND   ra.project_id = l_assignment_rec.project_id
          AND   ra.project_assignment_id = l_assignment_rec.source_assignment_id)
 )
 ORDER BY budget_version_id, project_structure_version_id;

 CURSOR get_rlm_changeable_linked_ra (p_new_resource_list_member_id NUMBER)  IS
 SELECT resource_assignment_id, wbs_element_version_id, budget_version_id, project_structure_version_id, task_id
 FROM
 (
    (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id, ra.task_id
         FROM   PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
          WHERE ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
          AND   ra.project_id = l_assignment_rec.project_id
          AND   ra.project_assignment_id = l_assignment_rec.source_assignment_id
          AND   evs.status_code = 'STRUCTURE_WORKING')
   UNION ALL
         (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id, ra.task_id
          FROM  PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
                   ,PA_PROJ_WORKPLAN_ATTR pwa
          WHERE pwa.wp_enable_Version_flag = 'N'
          AND   pwa.project_id = ra.project_id
          AND   pwa.proj_element_id = evs.proj_element_id
          AND   ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
          AND   ra.project_id = l_assignment_rec.project_id
          AND   ra.project_assignment_id = l_assignment_rec.source_assignment_id)
 ) linked_res_asgmts
 WHERE NOT EXISTS
 (
   SELECT *
   FROM  pa_resource_assignments ra
   WHERE ra.budget_version_id = linked_res_asgmts.budget_version_id
   AND   ra.resource_list_member_id = p_new_resource_list_member_id
   AND   ra.task_id = linked_res_asgmts.task_id
   AND   ra.resource_assignment_id <> linked_res_asgmts.resource_assignment_id
 )
 ORDER BY budget_version_id, project_structure_version_id;

 CURSOR get_rlm_unchangeable_linked_ra (p_new_resource_list_member_id NUMBER)  IS
 SELECT resource_assignment_id, wbs_element_version_id, budget_version_id, project_structure_version_id, task_id
 FROM
 (
    (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id, ra.task_id
         FROM   PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
          WHERE ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
          AND   ra.project_id = l_assignment_rec.project_id
          AND   ra.project_assignment_id = l_assignment_rec.source_assignment_id
          AND   evs.status_code = 'STRUCTURE_WORKING')
   UNION ALL
         (SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id, ra.task_id
          FROM  PA_RESOURCE_ASSIGNMENTS ra
               ,PA_BUDGET_VERSIONS bv
               ,PA_PROJ_ELEM_VER_STRUCTURE evs
                   ,PA_PROJ_WORKPLAN_ATTR pwa
          WHERE pwa.wp_enable_Version_flag = 'N'
          AND   pwa.project_id = ra.project_id
          AND   pwa.proj_element_id = evs.proj_element_id
          AND   ra.project_id = bv.project_id
          AND   bv.project_id = evs.project_id
          AND   ra.budget_version_id = bv.budget_version_id
          AND   bv.project_structure_version_id = evs.element_version_id
          AND   ra.project_id = l_assignment_rec.project_id
          AND   ra.project_assignment_id = l_assignment_rec.source_assignment_id)
 ) linked_res_asgmts
 WHERE EXISTS
 (
   SELECT *
   FROM  pa_resource_assignments ra
   WHERE ra.budget_version_id = linked_res_asgmts.budget_version_id
   AND   ra.resource_list_member_id = p_new_resource_list_member_id
   AND   ra.task_id = linked_res_asgmts.task_id
   AND   ra.resource_assignment_id <> linked_res_asgmts.resource_assignment_id
 )
 ORDER BY budget_version_id, project_structure_version_id;

 CURSOR get_res_mand_attributes IS
 SELECT rf.ROLE_ENABLED_FLAG
 FROM   pa_res_formats_b rf,
        pa_resource_list_members rlm,
                pa_project_assignments pa
 WHERE  pa.assignment_id = l_assignment_rec.source_assignment_id
 AND    pa.resource_list_member_id IS NOT NULL
 AND    rlm.resource_list_member_id = pa.resource_list_member_id
 AND    rlm.res_format_id = rf.res_format_id;


TYPE status_codes       IS TABLE OF pa_project_assignments.status_code%TYPE;
l_status_codes          status_codes;
l_mass_wf_in_progress_flag pa_project_assignments.mass_wf_in_progress_flag%TYPE;
l_action_set_id         NUMBER;
l_record_version_number NUMBER;

l_new_rlm_id            pa_project_assignments.resource_list_member_id%TYPE;
l_old_rlm_id            pa_project_assignments.resource_list_member_id%TYPE;
l_new_person_id         pa_resource_txn_attributes.person_id%TYPE;
l_rlm_id                pa_project_assignments.resource_list_member_id%TYPE;

l_candidate_in_rec      PA_RES_MANAGEMENT_AMG_PUB.CANDIDATE_IN_REC_TYPE; -- Added for bug 9187892

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open');
  --dbms_output.put_line('PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open');

  -- Initialize the error flag
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_FALSE;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASG_PUB_STAFF_ASSIGN_FROM_OPEN;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open.begin'
                       ,x_msg         => 'Staff_Assign_From_Open, src_asgmt_id='||p_assignment_rec.source_assignment_id
                       ,x_log_level   => 5);
  END IF;
  l_assignment_rec := p_assignment_rec;

  OPEN check_project_assignment_wf;
  FETCH check_project_assignment_wf INTO l_mass_wf_in_progress_flag;
  CLOSE check_project_assignment_wf;

  OPEN check_record_version;
  FETCH check_record_version INTO l_assignment_rec.assignment_row_id;

  IF l_mass_wf_in_progress_flag = 'Y' THEN

    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name       => 'PA_ASSIGNMENT_WF');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  ELSIF check_record_version%NOTFOUND THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  ELSE

    FND_PROFILE.Get('PA_DEF_FILLED_ASGMT_STATUS',l_default_filled_status_code);

    IF l_default_filled_status_code IS NULL THEN

       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => 'PA_FILLED_STATUS_NOT_DEFINED');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

    ELSE

  -- Assign the record to the local variable

  -- Get the details of the open assignment.  These details are required to
  -- 1) create a new Staffed Assignment from the existing Open Assignment and
  -- 2) create new Open Assignment(s) if the open assignment is only being
  --    partially filled.

    --
    -- Load the source open assignment detail into the source record
    --
    SELECT  assignment_id
           ,assignment_name
           ,assignment_type
           ,status_code
           ,staffing_priority_code
           ,project_id
           ,project_role_id
           ,description
           ,start_date
           ,end_date
           ,assignment_effort
           ,extension_possible
           ,source_assignment_id
           ,min_resource_job_level
           ,max_resource_job_level
           ,additional_information
           ,location_id
           ,work_type_id
           ,revenue_currency_code
           ,revenue_bill_rate
           ,markup_percent
           ,expense_owner
           ,expense_limit
           ,expense_limit_currency_code
           ,fcst_tp_amount_type
           ,fcst_job_id
           ,fcst_job_group_id
           ,expenditure_org_id
           ,expenditure_organization_id
           ,expenditure_type_class
           ,expenditure_type
           ,calendar_type
           ,calendar_id
           ,attribute_category
           ,attribute1
           ,attribute2
           ,attribute3
           ,attribute4
           ,attribute5
           ,attribute6
           ,attribute7
           ,attribute8
           ,attribute9
           ,attribute10
           ,attribute11
           ,attribute12
           ,attribute13
           ,attribute14
           ,attribute15
           ,bill_rate_override
           ,bill_rate_curr_override
           ,markup_percent_override
           ,tp_rate_override
           ,tp_currency_override
           ,tp_calc_base_code_override
           ,tp_percent_applied_override
           ,staffing_owner_person_id
                   ,resource_list_member_id
    INTO
          l_source_assignment_rec.assignment_id
         ,l_source_assignment_rec.assignment_name
         ,l_source_assignment_rec.assignment_type
         ,l_source_assignment_rec.status_code
         ,l_source_assignment_rec.staffing_priority_code
         ,l_source_assignment_rec.project_id
         ,l_source_assignment_rec.project_role_id
         ,l_source_assignment_rec.description
         ,l_source_assignment_rec.start_date
         ,l_source_assignment_rec.end_date
         ,l_source_assignment_rec.assignment_effort
         ,l_source_assignment_rec.extension_possible
         ,l_source_assignment_rec.source_assignment_id
         ,l_source_assignment_rec.min_resource_job_level
         ,l_source_assignment_rec.max_resource_job_level
         ,l_source_assignment_rec.additional_information
         ,l_source_assignment_rec.location_id
         ,l_source_assignment_rec.work_type_id
         ,l_source_assignment_rec.revenue_currency_code
         ,l_source_assignment_rec.revenue_bill_rate
         ,l_source_assignment_rec.markup_percent
         ,l_source_assignment_rec.expense_owner
         ,l_source_assignment_rec.expense_limit
         ,l_source_assignment_rec.expense_limit_currency_code
         ,l_source_assignment_rec.fcst_tp_amount_type
         ,l_source_assignment_rec.fcst_job_id
         ,l_source_assignment_rec.fcst_job_group_id
         ,l_source_assignment_rec.expenditure_org_id
         ,l_source_assignment_rec.expenditure_organization_id
         ,l_source_assignment_rec.expenditure_type_class
         ,l_source_assignment_rec.expenditure_type
         ,l_source_assignment_rec.calendar_type
         ,l_source_assignment_rec.calendar_id
         ,l_source_assignment_rec.attribute_category
         ,l_source_assignment_rec.attribute1
         ,l_source_assignment_rec.attribute2
         ,l_source_assignment_rec.attribute3
         ,l_source_assignment_rec.attribute4
         ,l_source_assignment_rec.attribute5
         ,l_source_assignment_rec.attribute6
         ,l_source_assignment_rec.attribute7
         ,l_source_assignment_rec.attribute8
         ,l_source_assignment_rec.attribute9
         ,l_source_assignment_rec.attribute10
         ,l_source_assignment_rec.attribute11
         ,l_source_assignment_rec.attribute12
         ,l_source_assignment_rec.attribute13
         ,l_source_assignment_rec.attribute14
         ,l_source_assignment_rec.attribute15
         ,l_source_assignment_rec.bill_rate_override
         ,l_source_assignment_rec.bill_rate_curr_override
         ,l_source_assignment_rec.markup_percent_override
         ,l_source_assignment_rec.tp_rate_override
         ,l_source_assignment_rec.tp_currency_override
         ,l_source_assignment_rec.tp_calc_base_code_override
         ,l_source_assignment_rec.tp_percent_applied_override
         ,l_source_assignment_rec.staffing_owner_person_id
                 ,l_old_rlm_id
    FROM   pa_project_assignments
    WHERE  assignment_id = p_assignment_rec.source_assignment_id;

  --Check that assign resource to the given requirement is allowed
  --the requirement may have multiple statuses.  If it does have multiple
  --statuses (status_code IS NULL in pa_project_assignments) then get all
  --of the statuses and check status controls on each one.
  IF l_source_assignment_rec.status_code IS NULL THEN
     OPEN get_status_codes;
     FETCH get_status_codes BULK COLLECT INTO l_status_codes;
     CLOSE get_status_codes;
  ELSE
     --use constructor to initialize the nested table.
     l_status_codes := status_codes(l_source_assignment_rec.status_code);
  END IF;



  FOR l_index IN 1..l_status_codes.COUNT LOOP
     l_return_status := PA_PROJECT_UTILS.Check_prj_stus_action_allowed
                                       ( x_project_status_code  => l_status_codes(l_index)
                                        ,x_action_code  => 'OPEN_ASGMT_ASSIGN_RESOURCES');
     IF l_return_status <> 'Y' THEN
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                             ,p_msg_name       => 'PA_ASGN_NOT_ALLOWED_FOR_STUS');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        l_status_controls_valid := 'N';
        EXIT;
        --dbms_output.put_line('Open Assignment Status not allowed');
     END IF;
   END LOOP;

   --continue if the status control validation is successful.
   IF l_status_controls_valid = 'Y' THEN

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open.after_source'
                         ,x_msg         => 'After getting requirement details, now assign requirement details'
                         ,x_log_level   => 5);
    END IF;

    l_assignment_rec.assignment_name := l_source_assignment_rec.assignment_name;
    l_assignment_rec.staffing_priority_code := l_source_assignment_rec.staffing_priority_code;
    l_assignment_rec.project_id := l_source_assignment_rec.project_id;
    l_assignment_rec.project_role_id := l_source_assignment_rec.project_role_id;
    l_assignment_rec.description := l_source_assignment_rec.description;
    l_assignment_rec.assignment_effort := l_source_assignment_rec.assignment_effort;
    l_assignment_rec.extension_possible := l_source_assignment_rec.extension_possible;
    l_assignment_rec.source_assignment_id := l_source_assignment_rec.assignment_id;
    l_assignment_rec.min_resource_job_level := l_source_assignment_rec.min_resource_job_level;
    l_assignment_rec.max_resource_job_level := l_source_assignment_rec.max_resource_job_level;
    l_assignment_rec.additional_information := l_source_assignment_rec.additional_information;
    l_assignment_rec.location_id := l_source_assignment_rec.location_id;
    l_assignment_rec.work_type_id := l_source_assignment_rec.work_type_id;
    l_assignment_rec.revenue_currency_code := l_source_assignment_rec.revenue_currency_code;
    l_assignment_rec.revenue_bill_rate := l_source_assignment_rec.revenue_bill_rate;
    l_assignment_rec.markup_percent := l_source_assignment_rec.markup_percent;
    l_assignment_rec.expense_owner := l_source_assignment_rec.expense_owner;
    l_assignment_rec.expense_limit := l_source_assignment_rec.expense_limit;
    l_assignment_rec.expense_limit_currency_code := l_source_assignment_rec.expense_limit_currency_code;
    l_assignment_rec.fcst_tp_amount_type := l_source_assignment_rec.fcst_tp_amount_type;
    l_assignment_rec.fcst_job_id := l_source_assignment_rec.fcst_job_id;
    l_assignment_rec.expenditure_type := l_source_assignment_rec.expenditure_type;
    l_assignment_rec.expenditure_type_class := l_source_assignment_rec.expenditure_type_class;
    l_assignment_rec.calendar_type := l_source_assignment_rec.calendar_type;
    l_assignment_rec.calendar_id := l_source_assignment_rec.calendar_id;
    l_assignment_rec.attribute_category := l_source_assignment_rec.attribute_category;
    l_assignment_rec.attribute1 := l_source_assignment_rec.attribute1;
    l_assignment_rec.attribute2 := l_source_assignment_rec.attribute2;
    l_assignment_rec.attribute3 := l_source_assignment_rec.attribute3;
    l_assignment_rec.attribute4 := l_source_assignment_rec.attribute4;
    l_assignment_rec.attribute5 := l_source_assignment_rec.attribute5;
    l_assignment_rec.attribute6 := l_source_assignment_rec.attribute6;
    l_assignment_rec.attribute7 := l_source_assignment_rec.attribute7;
    l_assignment_rec.attribute8 := l_source_assignment_rec.attribute8;
    l_assignment_rec.attribute9 := l_source_assignment_rec.attribute9;
    l_assignment_rec.attribute10 := l_source_assignment_rec.attribute10;
    l_assignment_rec.attribute11 := l_source_assignment_rec.attribute11;
    l_assignment_rec.attribute12 := l_source_assignment_rec.attribute12;
    l_assignment_rec.attribute13 := l_source_assignment_rec.attribute13;
    l_assignment_rec.attribute14 := l_source_assignment_rec.attribute14;
    l_assignment_rec.attribute15 := l_source_assignment_rec.attribute15;
    l_assignment_rec.bill_rate_override :=
                          l_source_assignment_rec.bill_rate_override;
    l_assignment_rec.bill_rate_curr_override :=
                          l_source_assignment_rec.bill_rate_curr_override;
    l_assignment_rec.markup_percent_override :=
                          l_source_assignment_rec.markup_percent_override;
    l_assignment_rec.tp_rate_override :=
                          l_source_assignment_rec.tp_rate_override;
    l_assignment_rec.tp_currency_override :=
                          l_source_assignment_rec.tp_currency_override;
    l_assignment_rec.tp_calc_base_code_override :=
                          l_source_assignment_rec.tp_calc_base_code_override;
    l_assignment_rec.tp_percent_applied_override :=
                          l_source_assignment_rec.tp_percent_applied_override;
    l_assignment_rec.staffing_owner_person_id := l_source_assignment_rec.staffing_owner_person_id;

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
      PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open.dates_compare'
                         ,x_msg         => 'Differentiate between 4 possibility for Dates'
                         ,x_log_level   => 5);
    END IF;


    --If the unfilled assignment status is not null and the assignment is being
    --partially staffed then create new open assignment(s) for the unfilled duration.

    IF (p_unfilled_assign_status_name <> FND_API.G_MISS_CHAR OR p_unfilled_assign_status_code <> FND_API.G_MISS_CHAR)
        AND p_asgn_creation_mode = 'PARTIAL' THEN

     --
     -- If assignment is direct against a project then there is no validation
     -- peformed against the start or end date
     --
     --
     -- For staffed assignment against an open assignment there are four scenarios:
     --
     -- 1)  IF staffed assignment start_date <= open assignment start_date AND
     --       staffed assignment end_date >= open assignment end_date THEN
     --    create a staffed assignment with the from staffed assignment start to end date
     --    No new open assignment created.
     --
     -- 2)  IF staffed assignment start_date <= open assignment start_date AND
     --     staffed assignment end_date < open assignment end_date THEN
     --    create a staffed assignment from staffed assignment start date to end date
     --    + create an open assignment from staff assignment end_date (+1) to open assignment end_date
     --
     -- 3) IF staffed assignment start_date > open assignment start_date AND
     --     staffed assignment end_date >= open assignment end_date THEN
     --    create a staffed assignment from staffed assignment start date to end date
     --   + create an open assignment from open assignment start_date to staffed assignment start_date (-1)
     --
     -- 4) IF staffed assignment start_date > open assignment start_date AND
     --     staffed assignment end_date < open assignment end_date THEN
     --  create a staffed assignment from staffed assignment start date to end date
     -- + create two new open assignments:
     -- open assignment1 from open assignment start_date to staffed assignment start_date (-1)
     -- AND
     -- open assignment2 from staffed_assignment end_date(+1) to open assignment end_date
     --
     --

       -- Case 1)

       IF l_assignment_rec.start_date <= l_source_assignment_rec.start_date
         AND l_assignment_rec.end_date >= l_source_assignment_rec.end_date THEN

            NULL;

        -- Create an staff assignment from l_assignment_rec.start_date to l_assignment_rec.end_date


       --Case 2)

       ELSIF l_assignment_rec.start_date <= l_source_assignment_rec.start_date
            AND l_assignment_rec.end_date < l_source_assignment_rec.end_date THEN

         --  Create an staff assignment from l_assignment_rec.start_date to l_assignment_rec.end_date
         --  Create an open assignment from staff assignment end_date (+1) to open assignment end_date

         l_new_open_assignment_tbl(1) := l_source_assignment_rec;

         l_new_open_assignment_tbl(1).start_date := l_assignment_rec.end_date + 1;
         l_new_open_assignment_tbl(1).end_date   := l_source_assignment_rec.end_date;
         l_new_open_assignment_tbl(1).source_assignment_id := l_source_assignment_rec.assignment_id;


       --Case 3)

       ELSIF l_assignment_rec.start_date > l_source_assignment_rec.start_date
           AND l_assignment_rec.end_date >= l_source_assignment_rec.end_date THEN

         l_new_open_assignment_tbl(1) := l_source_assignment_rec;

         -- Create an staff assignment from l_assignment_rec.start_date to l_assignment_rec.end_date
         -- Create an open assignment from open assignment start_date to staffed assignment start_date (-1)

         l_new_open_assignment_tbl(1).start_date := l_source_assignment_rec.start_date;

         -- Bug 3134204 The condition below to get start date was incorrect.
         -- l_new_open_assignment_tbl(1).end_date   := l_assignment_rec.end_date - 1;
         l_new_open_assignment_tbl(1).end_date   := l_assignment_rec.start_date - 1;
         l_new_open_assignment_tbl(1).source_assignment_id := l_source_assignment_rec.assignment_id;


       -- Case 4)

       ELSIF l_assignment_rec.start_date > l_source_assignment_rec.start_date AND
            l_assignment_rec.end_date < l_source_assignment_rec.end_date THEN

         l_new_open_assignment_tbl(1) := l_source_assignment_rec;

         l_new_open_assignment_tbl(2) := l_source_assignment_rec;

         -- Create an staff assignment from l_assignment_rec.start_date to l_assignment_rec.end_date
         -- Create two new open assignments:
         -- open assignment1 from open assignment start_date to staffed assignment start_date (-1)
         -- AND
         -- open assignment2 from staffed_assignment end_date(+1) to open assignment end_date
         -- Dates of first record

         l_new_open_assignment_tbl(1).start_date := l_source_assignment_rec.start_date;
         l_new_open_assignment_tbl(1).end_date   := l_assignment_rec.start_date - 1;
         l_new_open_assignment_tbl(1).source_assignment_id := l_source_assignment_rec.assignment_id;

         --  Dates of second record

         l_new_open_assignment_tbl(2).start_date := l_assignment_rec.end_date + 1;
         l_new_open_assignment_tbl(2).end_date   := l_source_assignment_rec.end_date;
         l_new_open_assignment_tbl(2).source_assignment_id := l_source_assignment_rec.assignment_id;


       END IF; --dates check for partial assignments

     --create the new open assignments

     FOR l_counter IN 1 .. l_new_open_assignment_tbl.COUNT LOOP

        l_new_open_assignment_tbl(l_counter).status_code := p_unfilled_assign_status_code;
        l_new_open_assignment_tbl(l_counter).assignment_type := 'OPEN_ASSIGNMENT';
        l_new_open_assignment_tbl(l_counter).source_assignment_id := l_source_assignment_rec.assignment_id;
        l_new_open_assignment_tbl(l_counter).source_assignment_type := 'OPEN_ASSIGNMENT'; --added for Bug 7211057



      --Log Message
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
        PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open.create_open'
                           ,x_msg         => 'Creating Requirement.'
                           ,x_log_level   => 5);
      END IF;




       -- Create the open assignment
      PA_ASSIGNMENTS_PUB.Create_Assignment
       ( p_assignment_rec             => l_new_open_assignment_tbl(l_counter)
        ,p_asgn_creation_mode         => p_asgn_creation_mode
        ,p_project_status_name        => p_unfilled_assign_status_name
        ,p_resource_name              => p_resource_name
        ,p_resource_source_id         => p_resource_source_id
        ,p_commit                     => p_commit
        ,p_validate_only              => p_validate_only
        ,p_max_msg_count              => p_max_msg_count
        ,x_new_assignment_id          => l_new_open_asgn_id
        ,x_assignment_number          => l_new_open_asgn_number
        ,x_assignment_row_id          => l_new_open_asgn_row_id
        ,x_resource_id                => x_resource_id
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        );


       IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
        --Copy the Candidate List from the old requirement to the new requirement
        PA_CANDIDATE_PUB.Copy_Candidates
                         (p_old_requirement_id  => l_source_assignment_rec.assignment_id
                         ,p_new_requirement_id  => l_new_open_asgn_id
                         ,p_new_start_date      => l_new_open_assignment_tbl(l_counter).start_date
                         ,x_return_status       => l_return_status
                         ,x_msg_count           => l_msg_count
                         ,x_msg_data            => l_msg_data);

       ELSE
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                              ,p_msg_name       => 'PA_FAILED_TO_CREATE_OPEN_ASGN');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       --

      END LOOP; --loop through new open assignments to be created.

     END IF; -- unfilled status code is passed.

      --create the new staffed assignment

      --Log Message
      IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
         PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open.create_staff'
                            ,x_msg         => 'Creating Assignment'
                            ,x_log_level   => 5);
      END IF;

       --dbms_output.put_line('Creating staff assignment');
      PA_ASSIGNMENTS_PUB.Create_Assignment
      ( p_assignment_rec             => l_assignment_rec
       ,p_asgn_creation_mode         => p_asgn_creation_mode
       ,p_project_status_name        => p_assignment_status_name
       ,p_resource_name              => p_resource_name
       ,p_resource_source_id         => p_resource_source_id
       ,p_commit                     => p_commit
       ,p_validate_only              => p_validate_only
       ,p_max_msg_count              => p_max_msg_count
       ,x_new_assignment_id          => x_new_assignment_id
       ,x_assignment_number          => x_assignment_number
       ,x_assignment_row_id          => x_assignment_row_id
       ,x_resource_id                => x_resource_id
       ,x_return_status              => l_return_status
       ,x_msg_count                  => x_msg_count
       ,x_msg_data                   => x_msg_data
      );

      IF P_DEBUG_MODE = 'Y' THEN
                 pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open'
                ,x_msg         => 'Create new staffed assignment,status='||l_return_status
                ,x_log_level   => li_message_level);
          END IF;

          IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                -- FP.M Development

                -- 1. get the new staffed assignment's derived rlm and person ids
        IF P_DEBUG_MODE = 'Y' THEN
                   pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open'
                ,x_msg         => 'x_new_assignment_id='||x_new_assignment_id
                ,x_log_level   => li_message_level);
                END IF;

        OPEN get_staffed_asgmt_rlm(x_new_assignment_id);
                FETCH get_staffed_asgmt_rlm INTO l_new_rlm_id, l_new_person_id;
                CLOSE get_staffed_asgmt_rlm;

        IF P_DEBUG_MODE = 'Y' THEN
                   pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open'
                ,x_msg         => 'l_new_rlm_id='||l_new_rlm_id||
                                                                  ' l_new_person_id='||l_new_person_id
                ,x_log_level   => li_message_level);
                END IF;

                -- TAs should be delinked from the filled requirement for sure.

                IF l_new_rlm_id IS NULL THEN
                  l_rlm_id := l_old_rlm_id;

                  -- if no planning resource can be derived of the staffed
                  -- assignment, use the planning resource from the filled
                  -- requirement
                  UPDATE pa_project_assignments
                     SET resource_list_member_id = l_old_rlm_id
                   WHERE assignment_id = x_new_assignment_id;

                ELSE
                  l_rlm_id := l_new_rlm_id;
                END IF;

        IF P_DEBUG_MODE = 'Y' THEN
                   pa_debug.write(x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open'
                ,x_msg         => 'l_rlm_id='||l_rlm_id
                ,x_log_level   => li_message_level);
                END IF;

        -- 2. if the planning resource can be derived on the new
                --    staffed assignment,TAs should use the new planning
                --    resource and be linked to new assignment if possible.

            IF l_new_rlm_id IS NOT NULL AND
               l_new_rlm_id <> l_old_rlm_id THEN

/* bug 3730480 - remove call to get_resource_defaults

                   -- get default resource attributes of the new rlm
                   l_resource_list_members_tbl.extend(1);
                   l_resource_list_members_tbl(1) := l_rlm_id;
                   pa_planning_resource_utils.get_resource_defaults (
                        P_resource_list_members   => l_resource_list_members_tbl
                   ,P_project_id                          => p_assignment_rec.project_id
                   ,X_resource_class_flag         => l_resource_class_flag_tbl
                   ,X_resource_class_code         => l_resource_class_code_tbl
                   ,X_resource_class_id           => l_resource_class_id_tbl
                   ,X_res_type_code                       => l_res_type_code_tbl
                   ,X_incur_by_res_type           => l_incur_by_res_type_tbl
                   ,X_person_id                           => l_person_id_tbl
                   ,X_job_id                              => l_job_id_tbl
                   ,X_person_type_code            => l_person_type_code_tbl
                   ,X_named_role                          => l_named_role_tbl
                   ,X_bom_resource_id             => l_bom_resource_id_tbl
                   ,X_non_labor_resource          => l_non_labor_resource_tbl
                   ,X_inventory_item_id           => l_inventory_item_id_tbl
                   ,X_item_category_id            => l_item_category_id_tbl
                   ,X_project_role_id             => l_project_role_id_tbl
                   ,X_organization_id             => l_organization_id_tbl
                   ,X_fc_res_type_code            => l_fc_res_type_code_tbl
                   ,X_expenditure_type            => l_expenditure_type_tbl
                   ,X_expenditure_category        => l_expenditure_category_tbl
                   ,X_event_type                          => l_event_type_tbl
                   ,X_revenue_category_code       => l_revenue_category_code_tbl
                   ,X_supplier_id                         => l_supplier_id_tbl
                   ,X_spread_curve_id             => l_spread_curve_id_tbl
                   ,X_etc_method_code             => l_etc_method_code_tbl
                   ,X_mfc_cost_type_id            => l_mfc_cost_type_id_tbl
                   ,X_incurred_by_res_flag        => l_incurred_by_res_flag_tbl
                   ,X_incur_by_res_class_code => l_incur_by_res_class_code_tbl
                   ,X_incur_by_role_id            => l_incur_by_role_id_tbl
                   ,X_unit_of_measure             => l_unit_of_measure_tbl
                   ,X_org_id                              => l_org_id_tbl
                   ,X_rate_based_flag             => l_rate_based_flag_tbl
                   ,X_rate_expenditure_type       => l_rate_expenditure_type_tbl
                   ,X_rate_func_curr_code         => l_rate_func_curr_code_tbl
--                 ,X_rate_incurred_by_org_id => l_rate_incurred_by_org_id_tbl
                   ,X_msg_data                            => l_msg_data
                   ,X_msg_count                           => l_msg_count
                   ,X_return_status                       => l_return_status
                  );
bug 3730480 */

        /*
                -- if the planning resource on the TAs are not changed,
                        -- stamp the person on the TAs
                        IF l_new_rlm_id IS NULL THENt

                          l_person_id_tbl(1) := l_new_person_id;
                          l_res_type_code_tbl(1) := 'NAMED_PERSON';

                        END IF;
        */

                   OPEN  get_rlm_changeable_linked_ra(l_new_rlm_id);
                   FETCH get_rlm_changeable_linked_ra
                   BULK COLLECT INTO l_task_assignment_id_tbl,
                                     l_task_version_id_tbl,
                                                         l_budget_version_id_tbl,
                                                         l_struct_version_id_tbl,
                                                         l_task_id_tbl;
                   CLOSE get_rlm_changeable_linked_ra;

                   pa_assignments_pvt.Update_Task_Assignments(
                        p_task_assignment_id_tbl  => l_task_assignment_id_tbl
                   ,p_task_version_id_tbl         => l_task_version_id_tbl
                   ,p_budget_version_id_tbl       => l_budget_version_id_tbl
                   ,p_struct_version_id_tbl       => l_struct_version_id_tbl
                   ,p_project_assignment_id       => x_new_assignment_id
                   -- change resource list member
                   ,p_resource_list_member_id => l_new_rlm_id
                   ,p_named_role                          => l_assignment_rec.assignment_name
                   ,p_project_role_id             => l_assignment_rec.project_role_id
                   ,x_return_status           => l_return_status
                   );
                           --Log Message
                   IF P_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staffed_Assign_From_Open'
                                      ,x_msg         => 'Update_task_assignments(case 1), status='||l_return_status
                                      ,x_log_level   => 5);
                   END IF;

                   OPEN  get_rlm_unchangeable_linked_ra(l_new_rlm_id);
                   FETCH get_rlm_unchangeable_linked_ra
                   BULK COLLECT INTO l_task_assignment_id_tbl,
                                     l_task_version_id_tbl,
                                                         l_budget_version_id_tbl,
                                                         l_struct_version_id_tbl,
                                                         l_task_id_tbl;
                   CLOSE get_rlm_unchangeable_linked_ra;

                   OPEN  get_res_mand_attributes;
                   FETCH get_res_mand_attributes INTO l_cur_role_flag;

                   IF get_res_mand_attributes%FOUND AND l_cur_role_flag = 'Y' THEN
                           pa_assignments_pvt.Update_Task_Assignments(
                                 p_task_assignment_id_tbl       =>      l_task_assignment_id_tbl
                                ,p_task_version_id_tbl          =>  l_task_version_id_tbl
                                ,p_budget_version_id_tbl        =>  l_budget_version_id_tbl
                                ,p_struct_version_id_tbl        =>  l_struct_version_id_tbl
                                ,p_project_assignment_id        =>  -1
                                ,x_return_status            =>  l_return_status
                           );
                   ELSE
                           pa_assignments_pvt.Update_Task_Assignments(
                                 p_task_assignment_id_tbl       =>      l_task_assignment_id_tbl
                                ,p_task_version_id_tbl          =>  l_task_version_id_tbl
                                ,p_budget_version_id_tbl        =>  l_budget_version_id_tbl
                                ,p_struct_version_id_tbl        =>  l_struct_version_id_tbl
                                ,p_project_assignment_id        =>  -1
                                ,p_named_role                           =>      FND_API.G_MISS_CHAR
                                ,x_return_status            =>  l_return_status
                           );
                   END IF;
                   CLOSE get_res_mand_attributes;

                           --Log Message
                   IF P_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staffed_Assign_From_Open'
                                      ,x_msg         => 'Update_task_assignments(case 2), status='||l_return_status
                                      ,x_log_level   => 5);
                   END IF;

            ELSIF l_rlm_id IS NOT NULL THEN

               -- 3. If planning resource cannot be derived on the new staffed
                   --    assignment, planning resource on TAs should be unchanged.
                   --    And TAs linked to filled requirement should be linked to
                   --    new staffed assignment.

                   --    get all the TA linked to the filled requirement in
                   --    all working versions
                   OPEN  get_linked_res_asgmts;
                   FETCH get_linked_res_asgmts
                   BULK COLLECT INTO l_task_assignment_id_tbl,
                                     l_task_version_id_tbl,
                                                         l_budget_version_id_tbl,
                                                         l_struct_version_id_tbl;
                   CLOSE get_linked_res_asgmts;

                  pa_assignments_pvt.Update_Task_Assignments(
                        p_task_assignment_id_tbl  => l_task_assignment_id_tbl
                   ,p_task_version_id_tbl         => l_task_version_id_tbl
                   ,p_budget_version_id_tbl       => l_budget_version_id_tbl
                   ,p_struct_version_id_tbl       => l_struct_version_id_tbl
                   ,p_project_assignment_id       => x_new_assignment_id
                   ,p_named_role                          => l_assignment_rec.assignment_name
                   ,p_project_role_id             => l_assignment_rec.project_role_id
                   ,x_return_status           => l_return_status
                  );
                           --Log Message
                   IF P_DEBUG_MODE = 'Y' THEN
                   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staffed_Assign_From_Open'
                                      ,x_msg         => 'Update_task_assignments(case 3), status='||l_return_status
                                      ,x_log_level   => 5);
                   END IF;

                END IF; --IF l_new_rlm_id IS NOT NULL AND l_new_rlm_id <> l_old_rln_id THEN

                -- End of FP.M Development

       --Log Message
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
          PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open.change_status'
                             ,x_msg         => 'calling schedule change_status'
                             ,x_log_level   => 5);
       END IF;

       --Change Open Requirement status to Filled.
       PA_SCHEDULE_PUB.Change_Status(p_record_version_number => p_assignment_rec.record_version_number,
                                p_project_id => l_source_assignment_rec.project_id,
                                p_calendar_id =>l_source_assignment_rec.calendar_id,
                                p_assignment_id => l_source_assignment_rec.assignment_id,
                                p_assignment_type => 'OPEN_ASSIGNMENT',
                                p_status_type => null,
                                p_start_date => l_source_assignment_rec.start_date,
                                p_end_date => l_source_assignment_rec.end_date,
                                p_assignment_status_code => l_default_filled_status_code,
                                p_asgn_start_date => l_source_assignment_rec.start_date,
                                p_asgn_end_date => l_source_assignment_rec.end_date,
                                x_return_status => l_return_status,
                                x_msg_count => x_msg_count,
                                x_msg_data => x_msg_data);

       -- Close the Open Requirement's Advertisement Action Set
       OPEN get_action_set;
        FETCH get_action_set INTO l_action_set_id, l_record_version_number;
       CLOSE get_action_set;

       PA_ACTION_SETS_PUB.Update_Action_Set(
                 p_action_set_id         => l_action_set_id
                ,p_object_id             => l_source_assignment_rec.assignment_id
                ,p_object_type           => 'OPEN_ASSIGNMENT'
                ,p_action_set_type_code  => 'ADVERTISEMENT'
                ,p_status_code           => 'CLOSED'
                ,p_record_version_number => l_record_version_number
                ,p_commit                => p_commit
                ,p_validate_only         => p_validate_only
                ,p_init_msg_list         => FND_API.G_FALSE
                ,x_return_status         => l_return_status
                ,x_msg_count             => x_msg_count
                ,x_msg_data              => x_msg_data);

       --Assign status to the remaining candidates
       --This API update the record number.
       --IF p_remaining_candidate_code IS NOT NULL AND p_remaining_candidate_code <> FND_API.G_MISS_CHAR THEN

          PA_CANDIDATE_PUB.Update_Remaining_Candidates(p_assignment_id => p_assignment_rec.source_assignment_id
                                                      ,p_resource_id     => x_resource_id
                                                      ,p_status_code     => p_remaining_candidate_code
                                                      ,p_change_reason_code => p_change_reason_code
                                                      -- Added for bug 9187892
                                                      ,p_attribute_category    => l_candidate_in_rec.attribute_category
                                                      ,p_attribute1            => l_candidate_in_rec.attribute1
                                                      ,p_attribute2            => l_candidate_in_rec.attribute2
                                                      ,p_attribute3            => l_candidate_in_rec.attribute3
                                                      ,p_attribute4            => l_candidate_in_rec.attribute4
                                                      ,p_attribute5            => l_candidate_in_rec.attribute5
                                                      ,p_attribute6            => l_candidate_in_rec.attribute6
                                                      ,p_attribute7            => l_candidate_in_rec.attribute7
                                                      ,p_attribute8            => l_candidate_in_rec.attribute8
                                                      ,p_attribute9            => l_candidate_in_rec.attribute9
                                                      ,p_attribute10           => l_candidate_in_rec.attribute10
                                                      ,p_attribute11           => l_candidate_in_rec.attribute11
                                                      ,p_attribute12           => l_candidate_in_rec.attribute12
                                                      ,p_attribute13           => l_candidate_in_rec.attribute13
                                                      ,p_attribute14           => l_candidate_in_rec.attribute14
                                                      ,p_attribute15           => l_candidate_in_rec.attribute15
                                                      ,x_return_status   => l_return_status
                                                      ,x_msg_data        => x_msg_data
                                                      ,x_msg_count       => x_msg_count);

          END IF; --IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN (Create staffed asgmt)

       END IF;  -- end of checking assign resource allowed

     END IF; --IF l_default_filled_status_code IS NULL THEN

  END IF;--end of checking mass wf in progress


  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --

  CLOSE check_record_version;

  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program

  PA_DEBUG.Reset_Err_Stack;

  IF x_msg_count > 0 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     ELSE
        ROLLBACK TO ASG_PUB_STAFF_ASSIGN_FROM_OPEN;
     END IF;
  END IF;



  EXCEPTION
    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_STAFF_ASSIGN_FROM_OPEN;
        END IF;
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Staff_Assign_From_Open'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
--
END Staff_Assign_From_Open;



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
 ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
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
 ,p_resource_list_member_id      IN  pa_project_assignments.resource_list_member_id%TYPE       := FND_API.G_MISS_NUM
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
)
IS

l_assignment_rec      PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
l_return_status       VARCHAR2(1);

/*Code addition for bug 3096132 starts*/
 l_br_rate_oride       VARCHAR2(1);
 l_br_rate_dics        VARCHAR2(1);
 l_req_rdisc_reason    VARCHAR2(1);
 --MOAC changes Bug 4363092: removed nvl with org_id
 Cursor bil_rate_oride_imple(p_project_id number) is
 SELECT impl.RATE_DISCOUNT_REASON_FLAG,impl.BR_OVERRIDE_FLAG,impl.BR_DISCOUNT_OVERRIDE_FLAG
 FROM PA_IMPLEMENTATIONS_ALL impl,pa_projects_all proj
 WHERE proj.org_id=impl.org_id
 and proj.project_id = p_project_id ;
 /*Code addition for bug 3096132 ends*/

BEGIN




  --dbms_output.put_line('Beginning Execute_Update_Assignment');
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Execute_Update_Assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Execute_Update_Assignment.begin'
                       ,x_msg         => 'Beginning of Execute_Update_Assignment'
                       ,x_log_level   => 5);
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --dbms_output.put_line('In execute_update_assigment');

  -- Assign the scalar parameters to the assignment record fields
  --
  /*Code addition for bug 3096132 starts*/
  /*Corrected the order of the fetch from l_br_rate_oride,l_br_rate_dics,l_req_rdisc_reason to
  l_req_rdisc_reason,l_br_rate_oride,l_br_rate_dics for the bug 3132323*/
   Open bil_rate_oride_imple(p_project_id);
  fetch bil_rate_oride_imple into l_req_rdisc_reason,l_br_rate_oride,l_br_rate_dics;
  close bil_rate_oride_imple;

  if (l_br_rate_oride ='Y' OR l_br_rate_dics='Y') then
    if l_req_rdisc_reason = 'Y' then
     if ((p_bill_rate_override <> FND_API.G_MISS_NUM AND p_bill_rate_override IS NOT NULL)
     OR (p_discount_percentage <> FND_API.G_MISS_NUM AND p_discount_percentage IS NOT NULL))
     then
      if (p_rate_disc_reason_code IS NULL OR p_rate_disc_reason_code = FND_API.G_MISS_CHAR) then
         PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_RATE_DISC_REASON_REQUIRED');
        --PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        x_return_status := FND_API.G_RET_STS_ERROR;

       end if;
      end if;
     end if;
   end if;

   /*Code addition for bug 3096132 ends*/
  l_assignment_rec.assignment_row_id           := p_assignment_row_id;
  l_assignment_rec.assignment_id               := p_assignment_id;
  l_assignment_rec.record_version_number       := p_record_version_number;
  l_assignment_rec.assignment_name             := p_assignment_name;
  l_assignment_rec.assignment_type             := p_assignment_type;
  l_assignment_rec.multiple_status_flag        := p_multiple_status_flag;
  l_assignment_rec.staffing_priority_code      := p_staffing_priority_code;
  l_assignment_rec.project_id                  := p_project_id;
  l_assignment_rec.assignment_template_id      := p_assignment_template_id;
  l_assignment_rec.project_role_id             := p_project_role_id;
  l_assignment_rec.project_party_id            := p_project_party_id;
  l_assignment_rec.description                 := p_description;
  l_assignment_rec.assignment_effort           := p_assignment_effort;
  l_assignment_rec.extension_possible          := p_extension_possible;
  l_assignment_rec.source_assignment_id        := p_source_assignment_id;
  l_assignment_rec.min_resource_job_level      := p_min_resource_job_level;
  l_assignment_rec.max_resource_job_level      := p_max_resource_job_level;
  l_assignment_rec.assignment_number           := p_assignment_number;
  l_assignment_rec.additional_information      := p_additional_information;
  l_assignment_rec.work_type_id                := p_work_type_id;
  l_assignment_rec.location_id                 := p_location_id;
  l_assignment_rec.revenue_currency_code       := p_revenue_currency_code;
  l_assignment_rec.revenue_bill_rate           := p_revenue_bill_rate;
  l_assignment_rec.markup_percent              := p_markup_percent;
  l_assignment_rec.expense_owner               := p_expense_owner;
  l_assignment_rec.expense_limit               := p_expense_limit;
  l_assignment_rec.expense_limit_currency_code := p_expense_limit_currency_code;
  l_assignment_rec.fcst_tp_amount_type         := p_fcst_tp_amount_type;
  l_assignment_rec.fcst_job_id                 := p_fcst_job_id;
  l_assignment_rec.fcst_job_group_id           := p_fcst_job_group_id;
  l_assignment_rec.expenditure_org_id          := p_expenditure_org_id;
  l_assignment_rec.expenditure_organization_id := p_expenditure_organization_id;
  l_assignment_rec.expenditure_type_class      := p_expenditure_type_class;
  l_assignment_rec.expenditure_type            := p_expenditure_type;
  l_assignment_rec.comp_match_weighting        := p_comp_match_weighting;
  l_assignment_rec.avail_match_weighting       := p_avail_match_weighting;
  l_assignment_rec.job_level_match_weighting   := p_job_level_match_weighting;
  l_assignment_rec.search_min_availability     := p_search_min_availability;
  l_assignment_rec.search_country_code         := p_search_country_code;
  l_assignment_rec.search_exp_org_struct_ver_id := p_search_exp_org_struct_ver_id;
  l_assignment_rec.search_exp_start_org_id     := p_search_exp_start_org_id;
  l_assignment_rec.search_min_candidate_score  := p_search_min_candidate_score;
  l_assignment_rec.enable_auto_cand_nom_flag   := p_enable_auto_cand_nom_flag;
  l_assignment_rec.bill_rate_override          := p_bill_rate_override;
  l_assignment_rec.bill_rate_curr_override     := p_bill_rate_curr_override;
  l_assignment_rec.markup_percent_override     := p_markup_percent_override;
  l_assignment_rec.discount_percentage        := p_discount_percentage; -- Bug2590938
  l_assignment_rec.rate_disc_reason_code       := p_rate_disc_reason_code; -- Bug2590938
  l_assignment_rec.tp_rate_override            := p_tp_rate_override;
  l_assignment_rec.tp_currency_override        := p_tp_currency_override;
  l_assignment_rec.tp_calc_base_code_override  := p_tp_calc_base_code_override;
  l_assignment_rec.tp_percent_applied_override := p_tp_percent_applied_override;
  l_assignment_rec.staffing_owner_person_id    := p_staffing_owner_person_id;
  l_assignment_rec.resource_list_member_id     := p_resource_list_member_id;
  l_assignment_rec.attribute_category          := p_attribute_category;
  l_assignment_rec.attribute1                  := p_attribute1;
  l_assignment_rec.attribute2                  := p_attribute2;
  l_assignment_rec.attribute3                  := p_attribute3;
  l_assignment_rec.attribute4                  := p_attribute4;
  l_assignment_rec.attribute5                  := p_attribute5;
  l_assignment_rec.attribute6                  := p_attribute6;
  l_assignment_rec.attribute7                  := p_attribute7;
  l_assignment_rec.attribute8                  := p_attribute8;
  l_assignment_rec.attribute9                  := p_attribute9;
  l_assignment_rec.attribute10                 := p_attribute10;
  l_assignment_rec.attribute11                 := p_attribute11;
  l_assignment_rec.attribute12                 := p_attribute12;
  l_assignment_rec.attribute13                 := p_attribute13;
  l_assignment_rec.attribute14                 := p_attribute14;
  l_assignment_rec.attribute15                 := p_attribute15;
  IF PA_ASSIGNMENTS_PUB.G_update_assignment_bulk_call = 'Y' THEN--9108007
  l_assignment_rec.calendar_id                 := p_calendar_id;
  END IF;

  --The following parameters are only updateable through this API is the
  --requirement is a TEMPLATE REQUIREMENT.  For requirements which belong to a project,
  --the updates to these attributes go through the schedule API - TEMPLATE REQUIREMENTS
  --do not have a schedule.

  IF p_project_id = FND_API.G_MISS_NUM OR p_project_id IS NULL THEN
     l_assignment_rec.start_date      := p_start_date;
     l_assignment_rec.end_date        := p_end_date;
     l_assignment_rec.status_code     := p_status_code;
     l_assignment_rec.calendar_id     := p_calendar_id;

  END IF;
  /* Added  condition for GSI PJR enhancement. bug # 7693634*/
  IF p_context = 'SS_UPDATE_ASSIGN' THEN
     l_assignment_rec.start_date      := p_start_date;
     l_assignment_rec.end_date        := p_end_date;
 END IF;
  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Execute_Update_Assignment.update_assignment'
                       ,x_msg         => 'After record assignment, Calling Update_Assignment'
                       ,x_log_level   => 5);
  END IF;
  -- Call the update  assignment public API
  --dbms_output.put_line('Calling Update_Assignment');
  PA_ASSIGNMENTS_PUB.Update_Assignment
  ( p_assignment_rec               => l_assignment_rec
   ,p_asgn_update_mode             => p_asgn_update_mode
   ,p_project_number               => p_project_number
   ,p_resource_name                => p_resource_name
   ,p_resource_source_id           => p_resource_source_id
   ,p_resource_id                  => p_resource_id
   ,p_project_status_name          => p_project_status_name
   ,p_project_subteam_id           => p_project_subteam_id
   ,p_project_subteam_party_id     => p_project_subteam_party_id
   ,p_project_subteam_name         => p_project_subteam_name
   ,p_calendar_name                => p_calendar_name
   ,p_staffing_priority_name       => p_staffing_priority_name
   ,p_project_role_name            => p_project_role_name
   ,p_location_city                => p_location_city
   ,p_location_region              => p_location_region
   ,p_location_country_name        => p_location_country_name
   ,p_location_country_code        => p_location_country_code
   ,p_work_type_name               => p_work_type_name
   ,p_fcst_job_name                => p_fcst_job_name
   ,p_fcst_job_group_name          => p_fcst_job_group_name
   ,p_expenditure_org_name         => p_expenditure_org_name
   ,p_exp_organization_name        => p_exp_organization_name
   ,p_search_country_name          => p_search_country_name
   ,p_search_exp_org_hier_name     => p_search_exp_org_hier_name
   ,p_search_exp_start_org_name    => p_search_exp_start_org_name
   ,p_staffing_owner_name          => p_staffing_owner_name
   ,p_api_version                  => p_api_version
   ,p_commit                       => p_commit
   ,p_validate_only                => p_validate_only
   ,p_context                      => p_context    -- Added for GSI PJR Enhancement bug 7693634
   ,p_max_msg_count                => p_max_msg_count
   ,x_return_status                => x_return_status
   ,x_msg_count                    => x_msg_count
   ,x_msg_data                     => x_msg_data
  );

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;


  -- Put any message text from message stack into the Message ARRAY
  EXCEPTION
    WHEN OTHERS THEN

      -- Set the excetption Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_ASSIGNMENT_PUB.Execute_Update_Assignment'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --
END Execute_Update_Assignment;




/*  Bug 8233045: Added the below procedure. This procedure can be invoked in bulk and
further calls Execute_Update_Assignment within loop*/

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
 ,p_resource_list_member_id_tbl      IN  SYSTEM.PA_NUM_TBL_TYPE               := NULL--Bug#9108007
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
 ,p_bulk_context                    IN    varchar2                            := 'N'
)

IS



 l_asgn_update_mode              varchar2(2000);
 l_assignment_id                 number;
 l_record_version_number         number;
 l_assignment_name               varchar2(2000);
 l_assignment_type               varchar2(2000);
 l_multiple_status_flag          varchar2(2000);
 l_status_code                   varchar2(2000);
 l_start_date                    date;
 l_end_date                      date;
 l_staffing_priority_code        varchar2(2000);
 l_project_id                    number;
 l_assignment_template_id        number;
 l_project_subteam_id            number;
 l_project_subteam_party_id      number;
 l_description                   varchar2(2000);
 l_extension_possible            varchar2(2000);
 l_min_resource_job_level        number;
 l_max_resource_job_level        number;
 l_additional_information        varchar2(2000);
 l_work_type_id                  number;
 l_project_role_id               number;--Bug#9108007
 l_expense_owner                 varchar2(2000);
 l_expense_limit                 number;
 l_fcst_tp_amount_type           varchar2(2000);
 l_fcst_job_id                   number;
 l_fcst_job_group_id             number;
 l_expenditure_org_id            number;
 l_exp_organization_id           number;
 l_expenditure_type_class        varchar2(2000);
 l_expenditure_type              varchar2(2000);
 l_project_subteam_name          varchar2(2000);
 l_location_city                 varchar2(2000);
 l_location_region               varchar2(2000);
 l_location_country_name         varchar2(2000);
 l_calendar_name                 varchar2(2000);
 l_calendar_id                   number;
 l_fcst_job_name                 varchar2(2000);
 l_fcst_job_group_name           varchar2(2000);
 l_expenditure_org_name          varchar2(2000);
 l_exp_organization_name         varchar2(2000);
 l_comp_match_weighting          number;
 l_avail_match_weighting         number;
 l_job_level_match_weight        number;
 l_search_min_availability       number;
 l_search_country_code           varchar2(2000);
 l_search_country_name           varchar2(2000);
 l_search_exp_org_st_ver_id      number;
 l_search_exp_org_hier_name      varchar2(2000);
 l_search_exp_start_org_id       number;
 l_search_exp_start_org          varchar2(2000);
 l_search_min_candidate_sc       number;
 l_enable_auto_cand_nom_flg      varchar2(2000);
 l_bill_rate_override            number;
 l_bill_rate_curr_override       varchar2(2000);
 l_markup_percent_override       number;
 l_discount_percentage           number;
 l_rate_disc_reason_code         varchar2(2000);
 l_tp_rate_override              number;
 l_tp_currency_override          varchar2(2000);
 l_staffing_owner_person_id      number;
 l_staffing_owner_name           varchar2(2000);
 l_resource_list_member_id       number;--Bug#9108007
 l_attribute_category            varchar2(2000);
 l_attribute1                    varchar2(2000);
 l_attribute2                    varchar2(2000);
 l_attribute3                    varchar2(2000);
 l_attribute4                    varchar2(2000);
 l_attribute5                    varchar2(2000);
 l_attribute6                    varchar2(2000);
 l_attribute7                    varchar2(2000);
 l_attribute8                    varchar2(2000);
 l_attribute9                    varchar2(2000);
 l_attribute10                   varchar2(2000);
 l_attribute11                   varchar2(2000);
 l_attribute12                   varchar2(2000);
 l_attribute13                   varchar2(2000);
 l_attribute14                   varchar2(2000);
 l_attribute15                   varchar2(2000);
 l_api_version                   number;
 l_init_msg_list                 varchar2(2000);
 l_commit                        varchar2(2000);
 l_validate_only                 varchar2(2000);
 l_context                       varchar2(2000);

BEGIN

G_update_assignment_bulk_call := p_bulk_context;

fnd_msg_pub.initialize;

x_return_status_tbl  := p_assignment_name_tbl;
x_msg_count_tbl      := p_assignment_id_tbl;
x_msg_data_tbl       := p_assignment_name_tbl;


for i in p_assignment_id_tbl.first .. p_assignment_id_tbl.last loop


BEGIN


      l_asgn_update_mode :=  FND_API.G_MISS_CHAR;

if p_assignment_id_tbl is null then
    l_assignment_id := FND_API.G_MISS_NUM;
else
    l_assignment_id := p_assignment_id_tbl(i);
end if;

if p_record_version_number_tbl is null then
    l_record_version_number := FND_API.G_MISS_NUM;
else
    l_record_version_number := p_record_version_number_tbl(i);
end if;

if p_assignment_name_tbl is null then
    l_assignment_name := FND_API.G_MISS_CHAR;
else
    l_assignment_name := p_assignment_name_tbl(i);
end if;

if p_assignment_type_tbl is null then
    l_assignment_type := FND_API.G_MISS_CHAR;
else
    l_assignment_type := p_assignment_type_tbl(i);
end if;

if p_multiple_status_flag_tbl is null then
    l_multiple_status_flag := FND_API.G_MISS_CHAR;
else
    l_multiple_status_flag := p_multiple_status_flag_tbl(i);
end if;

if p_status_code_tbl is null then
    l_status_code := FND_API.G_MISS_CHAR;
else
    l_status_code := p_status_code_tbl(i);
end if;
if  p_start_date_tbl is null then
     l_start_date := FND_API.G_MISS_DATE;
else
     l_start_date := p_start_date_tbl(i);
end if;

if p_end_date_tbl is null then
    l_end_date := FND_API.G_MISS_DATE;
else
    l_end_date := p_end_date_tbl(i);
end if;

if p_staffing_priority_code_tbl is null then
    l_staffing_priority_code := FND_API.G_MISS_CHAR;
else
    l_staffing_priority_code := p_staffing_priority_code_tbl(i);
end if;

if p_project_id_tbl is null then
    l_project_id := FND_API.G_MISS_NUM;
else
    l_project_id := p_project_id_tbl(i);
end if;

if p_assignment_template_id_tbl is null then
    l_assignment_template_id := NULL ;
else
    l_assignment_template_id := p_assignment_template_id_tbl(i);
end if;

if p_project_subteam_id_tbl is null then
    l_project_subteam_id :=NULL ;
elsif p_project_subteam_id_tbl(i) = -99999 then
    l_project_subteam_id := NULL ;
   else
    l_project_subteam_id := p_project_subteam_id_tbl(i);
end if;

if p_project_subteam_party_id_tbl is null then
    l_project_subteam_party_id := NULL ;
    elsif p_project_subteam_party_id_tbl(i) = -99999 then
      l_project_subteam_party_id :=  NULL ;
else
    l_project_subteam_party_id := p_project_subteam_party_id_tbl(i);
end if;

if p_description_tbl is null then
    l_description := FND_API.G_MISS_CHAR;
else
    l_description := p_description_tbl(i);
end if;

if p_extension_possible_tbl is null then
    l_extension_possible := FND_API.G_MISS_CHAR;
else
    l_extension_possible := p_extension_possible_tbl(i);
end if;

if p_min_resource_job_level_tbl is null then
    l_min_resource_job_level := FND_API.G_MISS_NUM;
else
    l_min_resource_job_level := p_min_resource_job_level_tbl(i);
end if;

if p_max_resource_job_level_tbl is null then
    l_max_resource_job_level := FND_API.G_MISS_NUM;
else
    l_max_resource_job_level := p_max_resource_job_level_tbl(i);
end if;

if p_additional_information_tbl is null then
    l_additional_information := FND_API.G_MISS_CHAR;
else
    l_additional_information := p_additional_information_tbl(i);
end if;

if p_work_type_id_tbl is null then
    l_work_type_id := FND_API.G_MISS_NUM;
else
    l_work_type_id := p_work_type_id_tbl(i);
end if;

--Bug#9108007 - Addition starts
if p_project_role_id_tbl is null then
    l_project_role_id := FND_API.G_MISS_NUM;
else
  -- l_project_role_id := p_project_role_id_tbl(i);  --nisinha
      l_project_role_id := FND_API.G_MISS_NUM;

end if;
--Bug#9108007 - Addition end

if p_expense_owner_tbl is null then
    l_expense_owner := FND_API.G_MISS_CHAR;
else
    l_expense_owner := p_expense_owner_tbl(i);
end if;

if p_expense_limit_tbl is null then
    l_expense_limit := NULL ;
else
    l_expense_limit := p_expense_limit_tbl(i);
end if;

if p_fcst_tp_amount_type_tbl is null then
    l_fcst_tp_amount_type := FND_API.G_MISS_CHAR;
else
    l_fcst_tp_amount_type := p_fcst_tp_amount_type_tbl(i);
end if;

if p_fcst_job_id_tbl is null then
    l_fcst_job_id := FND_API.G_MISS_NUM;
else
    l_fcst_job_id := p_fcst_job_id_tbl(i);
end if;

if p_fcst_job_group_id_tbl is null then
    l_fcst_job_group_id := FND_API.G_MISS_NUM;
else
    l_fcst_job_group_id := p_fcst_job_group_id_tbl(i);
end if;

if p_expenditure_org_id_tbl is null then
    l_expenditure_org_id := FND_API.G_MISS_NUM;
else
    l_expenditure_org_id := p_expenditure_org_id_tbl(i);
end if;

if p_exp_organization_id_tbl is null then
    l_exp_organization_id := FND_API.G_MISS_NUM;
else
    l_exp_organization_id := p_exp_organization_id_tbl(i);
end if;

if p_expenditure_type_class_tbl is null then
    l_expenditure_type_class := FND_API.G_MISS_CHAR;
else
    l_expenditure_type_class := p_expenditure_type_class_tbl(i);
end if;

if p_expenditure_type_tbl is null then
    l_expenditure_type := FND_API.G_MISS_CHAR;
else
    l_expenditure_type := p_expenditure_type_tbl(i);
end if;

if p_project_subteam_name_tbl is null then
    l_project_subteam_name := FND_API.G_MISS_CHAR;
else
    l_project_subteam_name := p_project_subteam_name_tbl(i);
end if;

if p_location_city_tbl is null then
    l_location_city := FND_API.G_MISS_CHAR;
else
    l_location_city := p_location_city_tbl(i);
end if;

if p_location_region_tbl is null then
    l_location_region := FND_API.G_MISS_CHAR;
else
    l_location_region := p_location_region_tbl(i);
end if;

if p_location_country_name_tbl is null then
    l_location_country_name := FND_API.G_MISS_CHAR;
else
    l_location_country_name := p_location_country_name_tbl(i);
end if;

if p_calendar_name_tbl is null then
    l_calendar_name := FND_API.G_MISS_CHAR;
else
    l_calendar_name := p_calendar_name_tbl(i);
end if;

if p_calendar_id_tbl is null then
    l_calendar_id := FND_API.G_MISS_NUM;
else
    l_calendar_id := p_calendar_id_tbl(i);
end if;

if p_fcst_job_name_tbl is null then
    l_fcst_job_name := FND_API.G_MISS_CHAR;
else
    l_fcst_job_name := p_fcst_job_name_tbl(i);
end if;


if p_fcst_job_group_name_tbl is null then
    l_fcst_job_group_name := FND_API.G_MISS_CHAR;
else
    l_fcst_job_group_name := p_fcst_job_group_name_tbl(i);
end if;

if p_expenditure_org_name_tbl is null then
    l_expenditure_org_name := FND_API.G_MISS_CHAR;
else
    l_expenditure_org_name := p_expenditure_org_name_tbl(i);
end if;


if p_exp_organization_name_tbl is null then
    l_exp_organization_name := FND_API.G_MISS_CHAR;
else
    l_exp_organization_name := p_exp_organization_name_tbl(i);
end if;


if p_comp_match_weighting_tbl is null then
    l_comp_match_weighting := FND_API.G_MISS_NUM;
else
    l_comp_match_weighting := p_comp_match_weighting_tbl(i);
end if;


if p_avail_match_weighting_tbl is null then
    l_avail_match_weighting := FND_API.G_MISS_NUM;
else
    l_avail_match_weighting := p_avail_match_weighting_tbl(i);
end if;

if p_job_level_match_weight_tbl is null then
    l_job_level_match_weight := FND_API.G_MISS_NUM;
else
    l_job_level_match_weight := p_job_level_match_weight_tbl(i);
end if;


if p_search_min_availability_tbl is null then
    l_search_min_availability := FND_API.G_MISS_NUM;
else
    l_search_min_availability := p_search_min_availability_tbl(i);
end if;

if p_search_country_code_tbl is null then
    l_search_country_code := FND_API.G_MISS_CHAR;
else
    l_search_country_code := p_search_country_code_tbl(i);
end if;

if p_search_country_name_tbl is null then
    l_search_country_name := FND_API.G_MISS_CHAR;
else
    l_search_country_name := p_search_country_name_tbl(i);
end if;

if p_search_exp_org_st_ver_id_tbl is null then
    l_search_exp_org_st_ver_id := FND_API.G_MISS_NUM;
else
    l_search_exp_org_st_ver_id := p_search_exp_org_st_ver_id_tbl(i);
end if;


if p_search_exp_org_hier_name_tbl is null then
    l_search_exp_org_hier_name := FND_API.G_MISS_CHAR;
else
    l_search_exp_org_hier_name := p_search_exp_org_hier_name_tbl(i);
end if;

if p_search_exp_start_org_id_tbl is null then
    l_search_exp_start_org_id := FND_API.G_MISS_NUM;
else
    l_search_exp_start_org_id := p_search_exp_start_org_id_tbl(i);
end if;

if p_search_exp_start_org_tbl is null then
    l_search_exp_start_org := FND_API.G_MISS_CHAR;
else
    l_search_exp_start_org := p_search_exp_start_org_tbl(i);
end if;

if p_search_min_candidate_sc_tbl is null then
    l_search_min_candidate_sc := FND_API.G_MISS_NUM;
else
    l_search_min_candidate_sc := p_search_min_candidate_sc_tbl(i);
end if;

if p_enable_auto_cand_nom_flg_tbl is null then
    l_enable_auto_cand_nom_flg := FND_API.G_MISS_CHAR;
else
    l_enable_auto_cand_nom_flg := p_enable_auto_cand_nom_flg_tbl(i);
end if;

if p_bill_rate_override_tbl is null then
    l_bill_rate_override := FND_API.G_MISS_NUM;
else
    l_bill_rate_override := p_bill_rate_override_tbl(i);
end if;

if p_bill_rate_curr_override_tbl is null then
    l_bill_rate_curr_override := FND_API.G_MISS_CHAR;
else
    l_bill_rate_curr_override := p_bill_rate_curr_override_tbl(i);
end if;


if p_markup_percent_override_tbl is null then
    l_markup_percent_override := FND_API.G_MISS_NUM;
else
    l_markup_percent_override := p_markup_percent_override_tbl(i);
end if;


if p_discount_percentage_tbl is null then
    l_discount_percentage := FND_API.G_MISS_NUM;
else
    l_discount_percentage := p_discount_percentage_tbl(i);
end if;


if p_rate_disc_reason_code_tbl is null then
    l_rate_disc_reason_code := FND_API.G_MISS_CHAR;
else
    l_rate_disc_reason_code := p_rate_disc_reason_code_tbl(i);
end if;


if p_tp_rate_override_tbl is null then
    l_tp_rate_override := FND_API.G_MISS_NUM;
else
    l_tp_rate_override := p_tp_rate_override_tbl(i);
end if;


if p_tp_currency_override_tbl is null then
    l_tp_currency_override := FND_API.G_MISS_CHAR;
else
    l_tp_currency_override := p_tp_currency_override_tbl(i);
end if;

if p_staffing_owner_person_id_tbl is null then
    l_staffing_owner_person_id := FND_API.G_MISS_NUM;
else
    l_staffing_owner_person_id := p_staffing_owner_person_id_tbl(i);
end if;

if p_staffing_owner_name_tbl is null then
    l_staffing_owner_name := FND_API.G_MISS_CHAR;
else
    l_staffing_owner_name := p_staffing_owner_name_tbl(i);
end if;

if p_resource_list_member_id_tbl is null then
    l_resource_list_member_id := FND_API.G_MISS_NUM;
else
    l_resource_list_member_id := p_resource_list_member_id_tbl(i);
end if;

if p_attribute_category_tbl is null then
    l_attribute_category := FND_API.G_MISS_CHAR;
else
    l_attribute_category := p_attribute_category_tbl(i);
end if;

if p_attribute1_tbl is null then
    l_attribute1 := FND_API.G_MISS_CHAR;
else
    l_attribute1 := p_attribute1_tbl(i);
end if;

if p_attribute2_tbl is null then
    l_attribute2 := FND_API.G_MISS_CHAR;
else
    l_attribute2 := p_attribute2_tbl(i);
end if;


if p_attribute3_tbl is null then
    l_attribute3 := FND_API.G_MISS_CHAR;
else
    l_attribute3 := p_attribute3_tbl(i);
end if;

if p_attribute4_tbl is null then
    l_attribute4 := FND_API.G_MISS_CHAR;
else
    l_attribute4 := p_attribute4_tbl(i);
end if;

if p_attribute5_tbl is null then
    l_attribute5 := FND_API.G_MISS_CHAR;
else
    l_attribute5 := p_attribute5_tbl(i);
end if;

if p_attribute6_tbl is null then
    l_attribute6 := FND_API.G_MISS_CHAR;
else
    l_attribute6 := p_attribute6_tbl(i);
end if;

if p_attribute7_tbl is null then
    l_attribute7 := FND_API.G_MISS_CHAR;
else
    l_attribute7 := p_attribute7_tbl(i);
end if;

if p_attribute8_tbl is null then
    l_attribute8 := FND_API.G_MISS_CHAR;
else
    l_attribute8 := p_attribute8_tbl(i);
end if;

if p_attribute9_tbl is null then
    l_attribute9 := FND_API.G_MISS_CHAR;
else
    l_attribute9 := p_attribute9_tbl(i);
end if;

if p_attribute10_tbl is null then
    l_attribute10 := FND_API.G_MISS_CHAR;
else
    l_attribute10 := p_attribute10_tbl(i);
end if;

if p_attribute11_tbl is null then
    l_attribute11 := FND_API.G_MISS_CHAR;
else
    l_attribute11 := p_attribute11_tbl(i);
end if;

if p_attribute12_tbl is null then
    l_attribute12 := FND_API.G_MISS_CHAR;
else
    l_attribute12 := p_attribute12_tbl(i);
end if;

if p_attribute13_tbl is null then
    l_attribute13 := FND_API.G_MISS_CHAR;
else
    l_attribute13 := p_attribute13_tbl(i);
end if;

if p_attribute14_tbl is null then
    l_attribute14 := FND_API.G_MISS_CHAR;
else
    l_attribute14 := p_attribute14_tbl(i);
end if;

if p_attribute15_tbl is null then
    l_attribute15 := FND_API.G_MISS_CHAR;
else
    l_attribute15 := p_attribute15_tbl(i);
end if;

if p_api_version_tbl is null then
    l_api_version := 1.0;
else
    l_api_version := p_api_version_tbl(i);
end if;

if p_init_msg_list_tbl is null then
    l_init_msg_list := FND_API.G_FALSE;
else
    l_init_msg_list := p_init_msg_list_tbl(i);
end if;

if p_commit_tbl is null then
    l_commit := FND_API.G_FALSE;
else
    l_commit := p_commit_tbl(i);
end if;

if p_validate_only_tbl is null then
    l_validate_only := FND_API.G_TRUE;
else
    l_validate_only := p_validate_only_tbl(i);
end if;

if p_context_tbl is null then
    l_context := FND_API.G_MISS_CHAR;
else
    l_context := p_context_tbl(i);
end if;

   --nisinha Bug9468685
-- Min and Max lob levels from Sch people update should be retained as it is.
IF PA_ASSIGNMENTS_PUB.G_update_assignment_bulk_call = 'Y' THEN
SELECT fcst_tp_amount_type
       ,min_resource_job_level
       ,max_resource_job_level
INTO   l_fcst_tp_amount_type
       ,l_min_resource_job_level
       ,l_max_resource_job_level
FROM pa_project_assignments_v

WHERE assignment_id=  l_assignment_id;
end if;
-- Bug#9468685

  Execute_Update_Assignment
         (
          p_asgn_update_mode              =>    l_asgn_update_mode
         ,p_assignment_id                 =>    l_assignment_id
         ,p_record_version_number         =>    l_record_version_number
         ,p_assignment_name               =>    l_assignment_name
         ,p_assignment_type               =>    l_assignment_type
         ,p_multiple_status_flag          =>    l_multiple_status_flag
         ,p_status_code                   =>    l_status_code
         ,p_start_date                    =>    l_start_date
         ,p_end_date                      =>    l_end_date
         ,p_staffing_priority_code        =>    l_staffing_priority_code
         ,p_project_id                    =>    l_project_id
         ,p_assignment_template_id        =>    l_assignment_template_id
         ,p_project_subteam_id            =>    l_project_subteam_id
         ,p_project_subteam_party_id      =>    l_project_subteam_party_id
         ,p_description                   =>    l_description
         ,p_extension_possible            =>    l_extension_possible
         ,p_min_resource_job_level        =>    l_min_resource_job_level
         ,p_max_resource_job_level        =>    l_max_resource_job_level
         ,p_additional_information        =>    l_additional_information
         ,p_work_type_id                  =>    l_work_type_id
	 ,p_project_role_id               =>    l_project_role_id--Bug#9108007
         ,p_expense_owner                 =>    l_expense_owner
         ,p_expense_limit                 =>    l_expense_limit
         ,p_fcst_tp_amount_type           =>    l_fcst_tp_amount_type
         ,p_fcst_job_id                   =>    l_fcst_job_id
         ,p_fcst_job_group_id             =>    l_fcst_job_group_id
         ,p_expenditure_org_id            =>    l_expenditure_org_id
         ,p_expenditure_organization_id   =>    l_exp_organization_id
         ,p_expenditure_type_class        =>    l_expenditure_type_class
         ,p_expenditure_type              =>    l_expenditure_type
         ,p_project_subteam_name          =>    l_project_subteam_name
         ,p_location_city                 =>    l_location_city
         ,p_location_region               =>    l_location_region
         ,p_location_country_name         =>    l_location_country_name
         ,p_calendar_name                 =>    l_calendar_name
         ,p_calendar_id                   =>    l_calendar_id
         ,p_fcst_job_name                 =>    l_fcst_job_name
         ,p_fcst_job_group_name           =>    l_fcst_job_group_name
         ,p_expenditure_org_name          =>    l_expenditure_org_name
         ,p_exp_organization_name         =>    l_exp_organization_name
         ,p_comp_match_weighting          =>    l_comp_match_weighting
         ,p_avail_match_weighting         =>    l_avail_match_weighting
         ,p_job_level_match_weighting     =>    l_job_level_match_weight
         ,p_search_min_availability       =>    l_search_min_availability
         ,p_search_country_code           =>    l_search_country_code
         ,p_search_country_name           =>    l_search_country_name
         ,p_search_exp_org_struct_ver_id  =>    l_search_exp_org_st_ver_id
         ,p_search_exp_org_hier_name      =>    l_search_exp_org_hier_name
         ,p_search_exp_start_org_id       =>    l_search_exp_start_org_id
         ,p_search_exp_start_org_name     =>    l_search_exp_start_org
         ,p_search_min_candidate_score    =>    l_search_min_candidate_sc
         ,p_enable_auto_cand_nom_flag     =>    l_enable_auto_cand_nom_flg
         ,p_bill_rate_override            =>    l_bill_rate_override
         ,p_bill_rate_curr_override       =>    l_bill_rate_curr_override
         ,p_markup_percent_override       =>    l_markup_percent_override
         ,p_discount_percentage           =>    l_discount_percentage
         ,p_rate_disc_reason_code         =>    l_rate_disc_reason_code
         ,p_tp_rate_override              =>    l_tp_rate_override
         ,p_tp_currency_override          =>    l_tp_currency_override
         ,p_staffing_owner_person_id      =>    l_staffing_owner_person_id
         ,p_staffing_owner_name           =>    l_staffing_owner_name
         ,p_resource_list_member_id       =>    l_resource_list_member_id
         ,p_attribute_category            =>    l_attribute_category
         ,p_attribute1                    =>    l_attribute1
         ,p_attribute2                    =>    l_attribute2
         ,p_attribute3                    =>    l_attribute3
         ,p_attribute4                    =>    l_attribute4
         ,p_attribute5                    =>    l_attribute5
         ,p_attribute6                    =>    l_attribute6
         ,p_attribute7                    =>    l_attribute7
         ,p_attribute8                    =>    l_attribute8
         ,p_attribute9                    =>    l_attribute9
         ,p_attribute10                   =>    l_attribute10
         ,p_attribute11                   =>    l_attribute11
         ,p_attribute12                   =>    l_attribute12
         ,p_attribute13                   =>    l_attribute13
         ,p_attribute14                   =>    l_attribute14
         ,p_attribute15                   =>    l_attribute15
         ,p_api_version                   =>    l_api_version
         ,p_init_msg_list                 =>    l_init_msg_list
         ,p_commit                        =>    l_commit
         ,p_validate_only                 =>    l_validate_only
         ,p_context                       =>    l_context
         ,x_return_status                 =>    x_return_status_tbl(i)
         ,x_msg_count                     =>    x_msg_count_tbl(i)
         ,x_msg_data                      =>    x_msg_data_tbl(i));

EXCEPTION
    WHEN OTHERS THEN

      -- Set the excetption Message and the stack
      FND_MSG_PUB.add_exc_msg ( p_pkg_name       => 'PA_ASSIGNMENT_PUB.Execute_Update_Assignment'
                               ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status_tbl(i) := FND_API.G_RET_STS_UNEXP_ERROR ;
       RAISE;  -- This is optional depending on the needs
       --
END;

end loop;

END Execute_Update_Assignment_bulk;





 PROCEDURE Update_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_update_mode            IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_project_number              IN     pa_projects_all.segment1%TYPE                   := FND_API.G_MISS_CHAR /* Bug 1851096 */
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
 ,p_search_exp_org_hier_name    IN     per_organization_structures.name%TYPE           := FND_API.G_MISS_CHAR
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
 )IS

 l_assignment_rec             PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_assignment_id              pa_project_assignments.assignment_id%TYPE;
 l_project_id                 pa_projects.project_id%TYPE;
 l_resource_source_id         pa_resources.resource_id%TYPE;
 l_status_code                pa_project_statuses.project_status_code%TYPE;
 l_project_role_id            pa_project_role_types.project_role_id%TYPE;
 l_location_country_name      fnd_territories_tl.territory_short_name%TYPE;
 l_location_country_code      fnd_territories.territory_code%TYPE;
 l_calendar_id                jtf_calendars_b.calendar_id%TYPE;
 l_return_status              VARCHAR2(1);
 l_tp_amount_type_desc        VARCHAR2(80);
 l_msg_count                  NUMBER;
 l_msg_data                   VARCHAR2(2000);
 l_resource_type_id           NUMBER;
 l_error_message_code         fnd_new_messages.message_name%TYPE;
 l_msg_index_out              NUMBER;
 l_valid_flag                 VARCHAR2(1);
 l_project_status_type        PA_PROJECT_STATUSES.status_type%TYPE := null;
 l_subteam_id                 pa_project_subteams.project_subteam_id%TYPE;
 l_object_type                pa_project_subteams.object_type%TYPE;
 l_object_id                  pa_project_subteams.object_id%TYPE;
 l_workflow_in_progress_flag  pa_team_templates.workflow_in_progress_flag%TYPE;
 l_project_status_name        pa_project_statuses.project_status_name%TYPE;
 l_calendar_name              jtf_calendars_tl.calendar_name%TYPE;
 l_record_version_check       VARCHAR2(1) := 'Y';
 l_pending_wf_check           VARCHAR2(1) := 'Y';
 l_mass_wf_in_progress_flag   pa_project_assignments.mass_wf_in_progress_flag%TYPE;
 l_ret_code                   VARCHAR2(1);
 l_project_system_status_code pa_project_statuses.project_system_status_code%TYPE;

 l_temp_expenditure_type_class pa_project_assignments.expenditure_type_class%TYPE;
 l_temp_fcst_job_group_id     NUMBER;
 l_temp_fcst_tp_amount_type   pa_project_assignments.fcst_tp_amount_type%TYPE;
 l_temp_status_code           pa_project_statuses.project_status_code%TYPE;
 l_temp_calendar_id           NUMBER;
 l_temp_fcst_job_id           NUMBER;
 l_temp_exp_organization_id   NUMBER;
 l_temp_expenditure_org_id    NUMBER;
 l_temp_work_type_id          NUMBER;
 l_temp_staff_owner_person_id NUMBER;
 -- Bug: 4537865
 t_search_exp_org_struct_ver_id     pa_project_assignments.search_exp_org_struct_ver_id%TYPE;
 l_new_search_exp_start_org_id      pa_project_assignments.search_exp_start_org_id%TYPE;
 --l_new_tp_currency_override         pa_project_assignments.tp_rate_override%TYPE;
 --Bug 8277143
 l_new_tp_currency_override         pa_project_assignments.tp_currency_override%TYPE;
 l_new_search_country_code          pa_project_assignments.search_country_code%TYPE;
 l_new_bill_rate_curr_override      pa_project_assignments.bill_rate_curr_override%TYPE;
 l_new_staffing_priority_code        pa_project_assignments.staffing_priority_code%TYPE;
 -- Bug: 4537865
 CURSOR check_record_version IS
 SELECT ROWID, apprvl_status_code
 FROM   pa_project_assignments
 WHERE  assignment_id = p_assignment_rec.assignment_id
 AND    record_version_number = nvl (p_assignment_rec.record_version_number, record_version_number);

 CURSOR get_expenditure_type_class IS
 SELECT system_linkage_function
 FROM   pa_expend_typ_sys_links_v
 WHERE  expenditure_type = l_assignment_rec.expenditure_type
 AND    system_linkage_function in ('ST', 'OT');

 CURSOR get_start_date IS
 SELECT start_date
 FROM   pa_project_assignments
 WHERE  assignment_id = l_assignment_rec.assignment_id;

 CURSOR check_team_template_wf IS
 SELECT workflow_in_progress_flag
   FROM pa_team_templates
  WHERE team_template_id = l_assignment_rec.assignment_template_id;

 CURSOR check_project_assignment_wf IS
 SELECT mass_wf_in_progress_flag
   FROM pa_project_assignments
  WHERE assignment_id = l_assignment_rec.assignment_id;

 CURSOR get_project_system_status_code IS
 SELECT ps.project_system_status_code
   FROM pa_project_assignments asgn,
        pa_project_statuses ps
  WHERE asgn.assignment_id = l_assignment_rec.assignment_id
    AND asgn.status_code = ps.project_status_code(+);

  /* Bug 2590938 Begin */
-- MOAC Changes bug 4363092: removed nvl used with org_id
  CURSOR get_bill_rate_override_flags IS
  SELECT impl.RATE_DISCOUNT_REASON_FLAG
        ,impl.BR_OVERRIDE_FLAG
        ,impl.BR_DISCOUNT_OVERRIDE_FLAG
  FROM PA_IMPLEMENTATIONS_ALL impl
       ,pa_projects_all proj
  WHERE proj.org_id=impl.org_id
  and proj.project_id = l_assignment_rec.project_id ;

  l_rate_discount_reason_flag varchar2(1);
  l_br_override_flag varchar2(1);
  l_br_discount_override_flag varchar2(1);
  /* Bug 2590938 End */

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Update_Assignment');
  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Update_Assignment.begin'
                       ,x_msg         => 'Beginning of Update_Assignment'
                       ,x_log_level   => 5);
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Initialize the error flag
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_FALSE;

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT ASG_PUB_UPDATE_ASSIGNMENT;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  -- Assign the record to the local variable
  l_assignment_rec := p_assignment_rec;

  --if this is a template requirement then check that worflow is not in progress
  --on the parent team template.  If it is in progress then no new template requirements
  --can be created.
  IF (l_assignment_rec.project_id IS NULL or l_assignment_rec.project_id = FND_API.G_MISS_NUM) AND
     (l_assignment_rec.assignment_template_id IS NOT NULL and l_assignment_rec.assignment_template_id <>FND_API.G_MISS_NUM) THEN

     OPEN check_team_template_wf;
     FETCH check_team_template_wf INTO l_workflow_in_progress_flag;
     CLOSE check_team_template_wf;

     IF l_workflow_in_progress_flag='Y' THEN

        PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_NO_REQ_WF');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
   -- check that mass workflow for updating assignment is not in progress.
   -- if mass workflow is in progress, cannot update the assignment
   -- perform this check only if this is online single update


   IF p_asgn_update_mode <> PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO
   and p_asgn_update_mode <> PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS
   and p_asgn_update_mode <> 'MASS_ONLINE' THEN

     --dbms_output.put_line('single update - check number_mass_wf_in_progress');

     OPEN check_project_assignment_wf;
     FETCH check_project_assignment_wf INTO l_mass_wf_in_progress_flag;
     CLOSE check_project_assignment_wf;

     IF l_mass_wf_in_progress_flag = 'Y' THEN
       PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                        ,p_msg_name       => 'PA_ASSIGNMENT_WF');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
   END IF;
   -- check that the assignment or requirement is cancelled or filled
   -- only if this is during mass workflow
   -- do not allow user to update cancelled or filled asgn/req
   IF p_asgn_update_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO
   OR p_asgn_update_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS THEN
     OPEN get_project_system_status_code;
     FETCH get_project_system_status_code INTO l_project_system_status_code;
     CLOSE get_project_system_status_code;

     IF l_project_system_status_code = 'OPEN_ASGMT_FILLED' OR
        l_project_system_status_code = 'OPEN_ASGMT_CANCEL' OR
        l_project_system_status_code = 'STAFFED_ASGMT_CANCEL' THEN

       PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                       ,p_msg_name       => 'PA_UPDATE_CAN_FILL_ASMT');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;

   END IF;
--Neither schedule attributes (dates, calendar) nor status
--can be updated through this API.  Updates to schedule attributes
--must go through the schedule APIs.  If any of these attributes
--are passed in to this API then return an error.
--UNLESS THIS IS A TEMPLATE REQUIREMENT.  Updates to these attributes for TEMPLATE REQUIREMENTS
--are allowed - template requirements do not have schedules.
--
--The schedule attributes are allowed to be passed in if they are from PRM pages.
--For PRM pages, the PA_STARTUP.G_Check_ID_Flag will be set to 'N'.
--In this case, these schedule attributes will be reset to default values and ignored.
--If these attributes are not from PRM pages, and this is not a template requirement
--then an error will be thrown.

-- Bug 8233045: If call is from Schedule People page, then flow should continue.

IF (l_assignment_rec.project_id <> FND_API.G_MISS_NUM AND l_assignment_rec.project_id IS NOT NULL) AND
   (l_assignment_rec.start_date <> FND_API.G_MISS_DATE OR
   l_assignment_rec.end_date <> FND_API.G_MISS_DATE OR
   l_assignment_rec.status_code <> FND_API.G_MISS_CHAR OR
   p_project_status_name <> FND_API.G_MISS_CHAR OR
   l_assignment_rec.calendar_id <> FND_API.G_MISS_NUM OR
   p_calendar_name <> FND_API.G_MISS_CHAR OR
   l_assignment_rec.calendar_type <> FND_API.G_MISS_CHAR) AND
   (PA_STARTUP.G_Calling_Application <> 'SELF_SERVICE' OR PA_STARTUP.G_Calling_Application IS NULL) /*AND
   PA_ASSIGNMENTS_PUB.G_update_assignment_bulk_call <> 'Y' */ THEN -- Bug 8233045

/*
        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_SCH_UPDATE_NOT_ALLOWED');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
*/

NULL;

--Update to Resource or Project Role is not allowed for Version 1.
--So if any role/resource attributes is passed in (or NULL is passed in),
--Then throw an error.
--Do not throw error if this is with in Mass Update Workflow
ELSIF p_asgn_update_mode <> PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO
  AND p_asgn_update_mode <> PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS
  AND ((l_assignment_rec.project_role_id <> FND_API.G_MISS_NUM OR l_assignment_rec.project_role_id IS NULL) OR
       (p_project_role_name <> FND_API.G_MISS_CHAR OR p_project_role_name IS NULL) OR
       (p_resource_id <> FND_API.G_MISS_NUM OR p_resource_id IS NULL) OR
       (p_resource_name <> FND_API.G_MISS_CHAR OR p_resource_name IS NULL) OR
       (p_resource_source_id <> FND_API.G_MISS_NUM OR p_resource_source_id IS NULL) ) THEN

        PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_RES_OR_ROLE_NOT_ALLOWED');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;


ELSE

   l_project_status_name := p_project_status_name;
   l_calendar_name := p_calendar_name;

   /* Added extra condition for GSI PJR enhancement. bug # 7693634*/
   --For non Template Requirement, reset schedule attributes to default values.


   IF (l_assignment_rec.project_id <> FND_API.G_MISS_NUM AND l_assignment_rec.project_id IS NOT NULL AND p_context <>'SS_UPDATE_ASSIGN') THEN

     l_assignment_rec.start_date  :=FND_API.G_MISS_DATE;
     l_assignment_rec.end_date    :=FND_API.G_MISS_DATE;
     l_assignment_rec.status_code :=FND_API.G_MISS_CHAR;
     l_project_status_name        :=FND_API.G_MISS_CHAR;
     IF PA_ASSIGNMENTS_PUB.G_update_assignment_bulk_call <> 'Y' THEN--Bug#9108007
     l_assignment_rec.calendar_id :=FND_API.G_MISS_NUM;
     END IF;
     l_calendar_name              :=FND_API.G_MISS_CHAR;
     l_assignment_rec.calendar_type :=FND_API.G_MISS_CHAR;

    ELSIF p_context = 'SS_UPDATE_ASSIGN' THEN

     l_assignment_rec.status_code :=FND_API.G_MISS_CHAR;
     l_project_status_name        :=FND_API.G_MISS_CHAR;
     l_assignment_rec.calendar_id :=FND_API.G_MISS_NUM;
     l_calendar_name              :=FND_API.G_MISS_CHAR;
     l_assignment_rec.calendar_type :=FND_API.G_MISS_CHAR;
   END IF;

--dbms_output.put_line('Before Opening Cursor');

--IF in Mass_Online Mode which is only for validation, do not check record version number, or check workflow pending.

IF p_asgn_update_mode <> 'MASS_ONLINE' and p_asgn_update_mode <> 'MASS_UPDATE_ASGMT_BASIC_INFO_BULK' THEN

 OPEN check_record_version;

 FETCH check_record_version INTO l_assignment_rec.assignment_row_id, l_assignment_rec.apprvl_status_code;


 IF PA_ASGMT_WFSTD.is_approval_pending(p_assignment_id => l_assignment_rec.assignment_id) = 'Y' THEN

   PA_UTILS.Add_Message( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_WF_APPROVAL_PENDING');
   PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
   l_pending_wf_check := 'N';


/* bug 8233045: GSI ER, skipping the following validation only when call is in bulk mode. This might need to be revisited later */
 ELSIF ((check_record_version%NOTFOUND )) THEN

   PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
   PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
   l_record_version_check := 'N';

 END IF;

 CLOSE check_record_version;
END IF; -- end of checking not in Mass Online Mode, Mass Online can avoid check record version number


IF (l_record_version_check <> 'N') AND (l_pending_wf_check <> 'N') THEN
  --do validation for these attributes when passed for a template requirement.



  IF (l_assignment_rec.status_code <> FND_API.G_MISS_CHAR AND l_assignment_rec.status_code IS NOT NULL) OR
     (l_project_status_name <> FND_API.G_MISS_CHAR AND l_project_status_name IS NOT NULL) THEN
     -- Validate Status code
     --
     -- need to convert from assignment status types to the status type
     -- defined in pa_project_statuses.

     IF l_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' THEN

        l_project_status_type := 'OPEN_ASGMT';

     ELSIF l_assignment_rec.assignment_type = 'STAFFED_ASSIGNMENT' THEN

        l_project_status_type := 'STAFFED_ASGMT';

     ELSIF l_assignment_rec.assignment_type = 'ADMIN_ASSIGNMENT' THEN

        l_project_status_type := 'STAFFED_ASGMT';

     END IF;
     IF l_assignment_rec.status_code = FND_API.G_MISS_CHAR THEN

        l_status_code := null;

     ELSE l_status_code := l_assignment_rec.status_code;

     END IF;
     l_temp_status_code := l_assignment_rec.status_code;
     PA_PROJECT_STUS_UTILS.Check_Status_Name_Or_Code ( p_status_code        => l_temp_status_code
                                                      ,p_status_name        => l_project_status_name
                                                      ,p_status_type        => l_project_status_type
                                                      ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                      ,x_status_code        => l_assignment_rec.status_code
                                                      ,x_return_status      => l_return_status
                                                      ,x_error_message_code => l_error_message_code);

     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           , p_msg_name       => l_error_message_code);
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

     l_return_status := FND_API.G_MISS_CHAR;
     l_error_message_code := FND_API.G_MISS_CHAR;
     l_assignment_rec.status_code := l_status_code;

   END IF;

     /* Bug 2887390 : Added the following condition */
     IF (l_assignment_rec.calendar_type = 'PROJECT' AND l_assignment_rec.calendar_id is NULL)
     THEN
          PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_INVALID_CAL_PROJ_SETUP' );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
   IF (l_calendar_name <> FND_API.G_MISS_CHAR AND l_calendar_name IS NOT NULL) OR
      (l_assignment_rec.calendar_id <> FND_API.G_MISS_NUM AND l_assignment_rec.calendar_id IS NOT NULL) THEN

        -- Validate Calendar detail
        -- If calendar name is valid and calendar_id is null then returns the calendar_id
        --
        l_temp_calendar_id := l_assignment_rec.calendar_id;
        PA_CALENDAR_UTILS.Check_Calendar_Name_Or_Id( p_calendar_id        => l_temp_calendar_id
                                                   ,p_calendar_name      => l_calendar_name
                                                   ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                   ,x_calendar_id        => l_assignment_rec.calendar_id
                                                   ,x_return_status      => l_return_status
                                                   ,x_error_message_code => l_error_message_code );
        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;
    END IF;
  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Update_Assignment.Id_validation'
                       ,x_msg         => 'Do Value to ID conversion.'
                       ,x_log_level   => 5);
  END IF;

  -- Do all Value to ID conversions and validations
  IF (l_assignment_rec.project_id IS NULL OR l_assignment_rec.project_id = FND_API.G_MISS_NUM)
     AND (p_project_number IS NOT NULL AND p_project_number <> FND_API.G_MISS_CHAR) THEN
    l_assignment_rec.project_id := PA_UTILS.GetProjId (x_project_num => p_project_number);
  END IF;
  IF (p_asgn_update_mode <> 'MASS_ONLINE') THEN
   IF l_assignment_rec.start_date IS NULL OR l_assignment_rec.start_date = FND_API.G_MISS_DATE THEN
     --
     --Get assignment start date
     --
     OPEN get_start_date;
     FETCH get_start_date into l_assignment_rec.start_date;
     CLOSE get_start_date;
   END IF;
  END IF;


  --Currently all changes to Status must go through the Schedule APIs,
  --so commenting out.
  --No updates to assignment dates / status allowed through the
  --Update Assignment API.

     --dbms_output.put_line('Before Validate Location');
     --
     -- Validate Location detail
     --

     IF p_location_country_code = FND_API.G_MISS_CHAR THEN

        l_location_country_code := null;

     ELSE l_location_country_code := p_location_country_code;

     END IF;
     --
     -- Validate Location detail
     -- If country name is valid and country_code is null returns the country_code
     --
     --No Need to Validate if country code and name are both not passed in

     IF (l_location_country_code IS NOT NULL) OR
        (p_location_country_name IS NOT NULL AND p_location_country_name <> FND_API.G_MISS_CHAR) THEN
       PA_LOCATION_UTILS.Check_Country_Name_Or_Code( p_country_code       => p_location_country_code
                                                    ,p_country_name       => p_location_country_name
                                                    ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                    ,x_country_code       => l_location_country_code
                                                    ,x_return_status      => l_return_status
                                                    ,x_error_message_code => l_error_message_code );
       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     -- if country is not passed in, but region/city is passed in, give an error.
     ELSIF (p_location_city IS NOT NULL AND p_location_city <> FND_API.G_MISS_CHAR) OR
           (p_location_region IS NOT NULL AND p_location_region <> FND_API.G_MISS_CHAR) THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_COUNTRY_INVALID');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

     --Bug 1795160: when user empty the location fields, the location id needs to be nulled out.
     --If in self-service mode, if country name and code is null, then set location id to NULL
     ELSIF l_location_country_code IS NULL AND p_location_country_name IS NULL AND PA_STARTUP.G_Calling_Application =

'SELF_SERVICE' THEN
        l_assignment_rec.location_id := NULL;

     END IF;

     --
     -- Validate assignment Job Levels
     --
     IF l_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' AND
        l_assignment_rec.min_resource_job_level <> FND_API.G_MISS_NUM AND
        l_assignment_rec.max_resource_job_level <> FND_API.G_MISS_NUM THEN
       -- Check Min level
       PA_JOB_UTILS.Check_JobLevel( p_level              => l_assignment_rec.min_resource_job_level
                                 ,x_valid              => l_valid_flag
                                 ,x_return_status      => l_return_status
                                 ,x_error_message_code => l_error_message_code );
       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

       -- Check Max level
       PA_JOB_UTILS.Check_JobLevel( p_level              => l_assignment_rec.max_resource_job_level
                                 ,x_valid              => l_valid_flag
                                 ,x_return_status      => l_return_status
                                 ,x_error_message_code => l_error_message_code );
       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;


       --
       -- Check that max job level is >= min job level
       --
       IF  l_assignment_rec.min_resource_job_level > l_assignment_rec.max_resource_job_level THEN
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                            ,p_msg_name       => 'PA_MIN_JL_GREATER_THAN_MAX');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;

     END IF;  -- end of checking job levels for only open assignments
     --
     -- Validate Candidate Score Match Weightings
     --
     IF (l_assignment_rec.comp_match_weighting <> FND_API.G_MISS_NUM AND l_assignment_rec.comp_match_weighting IS NOT NULL)

THEN
        IF l_assignment_rec.comp_match_weighting < 0 OR l_assignment_rec.comp_match_weighting > 100 THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_MATCH_WEIGHTING');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
      END IF;

      IF (l_assignment_rec.avail_match_weighting <> FND_API.G_MISS_NUM AND l_assignment_rec.avail_match_weighting IS NOT NULL) THEN
        IF l_assignment_rec.avail_match_weighting < 0 OR l_assignment_rec.avail_match_weighting > 100 THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_MATCH_WEIGHTING');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
      END IF;

      IF (l_assignment_rec.job_level_match_weighting <> FND_API.G_MISS_NUM AND l_assignment_rec.job_level_match_weighting IS NOT

NULL) THEN
        IF l_assignment_rec.job_level_match_weighting < 0 OR l_assignment_rec.job_level_match_weighting > 100 THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_MATCH_WEIGHTING');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
      END IF;


     -- Validate Search Minimum Availiability
     --

     IF l_assignment_rec.search_min_availability <> FND_API.G_MISS_NUM AND l_assignment_rec.search_min_availability IS NOT NULL THEN
       IF l_assignment_rec.search_min_availability < 0 OR
          l_assignment_rec.search_min_availability > 100 THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_MIN_AVAIL_INVALID');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
     END IF;
     --
     -- Validate Search Min Candidate Score
     --

     IF l_assignment_rec.search_min_candidate_score <> FND_API.G_MISS_NUM AND l_assignment_rec.search_min_candidate_score IS NOT

NULL THEN
       IF l_assignment_rec.search_min_candidate_score < 0 OR
          l_assignment_rec.search_min_candidate_score > 100 THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_MIN_CAN_SCORE_INVALID');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
     END IF;

     --
     -- Validate Search Org_Hierarchy
     --
     IF (l_assignment_rec.search_exp_org_struct_ver_id <> FND_API.G_MISS_NUM AND l_assignment_rec.search_exp_org_struct_ver_id  IS

NOT NULL) OR (p_search_exp_org_hier_name <> FND_API.G_MISS_CHAR AND p_search_exp_org_hier_name IS NOT NULL ) THEN

        PA_HR_ORG_UTILS.Check_OrgHierName_Or_Id (p_org_hierarchy_version_id => l_assignment_rec.search_exp_org_struct_ver_id,
                                                 p_org_hierarchy_name => p_search_exp_org_hier_name,
                                                 p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                                 -- Bug: 4537865
                                               --x_org_hierarchy_version_id => l_assignment_rec.search_exp_org_struct_ver_id,
                                                 x_org_hierarchy_version_id => t_search_exp_org_struct_ver_id,
                                                 -- Bug: 4537865
                                                 x_return_status => l_return_status,
                                                 x_error_msg_code => l_error_message_code);
        -- Bug: 4537865
       IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.search_exp_org_struct_ver_id := t_search_exp_org_struct_ver_id;
       END IF;
       -- Bug: 4537865

       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       ELSE

          l_return_status := FND_API.G_MISS_CHAR;
          l_error_message_code := FND_API.G_MISS_CHAR;

          -- check if the org hierarchy is of the correct type, i.e EXPENDITURES
          PA_ORG_UTILS.Check_OrgHierarchy_Type(
                p_org_structure_version_id => l_assignment_rec.search_exp_org_struct_ver_id,
                p_org_structure_type => 'EXPENDITURES',
                x_return_status => l_return_status,
                x_error_message_code => l_error_message_code);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                   ,p_msg_name       => l_error_message_code );
             PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
          END IF;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;
     END IF;
     --
     -- Validate Search Start Org
     --

     IF (l_assignment_rec.search_exp_start_org_id <> FND_API.G_MISS_NUM AND l_assignment_rec.search_exp_start_org_id IS NOT NULL)

OR (p_search_exp_start_org_name <> FND_API.G_MISS_CHAR and p_search_exp_start_org_name IS NOT NULL) THEN
        PA_HR_ORG_UTILS.Check_OrgName_Or_Id (p_organization_id => l_assignment_rec.search_exp_start_org_id,
                                             p_organization_name => p_search_exp_start_org_name,
                                             p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                           --x_organization_id => l_assignment_rec.search_exp_start_org_id,     * Bug: 4537865
                                             x_organization_id => l_new_search_exp_start_org_id,                --Bug: 4537865
                                             x_return_status => l_return_status,
                                             x_error_msg_code => l_error_message_code);
       -- Bug: 4537865
       IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.search_exp_start_org_id := l_new_search_exp_start_org_id;
       END IF;
       -- Bug: 4537865

       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       ELSE

          l_return_status := FND_API.G_MISS_CHAR;
          l_error_message_code := FND_API.G_MISS_CHAR;

          -- check if the starting org is of the correct type i.e.EXPENDITURES
          PA_ORG_UTILS.Check_Org_Type(
                p_organization_id => l_assignment_rec.search_exp_start_org_id,
                p_org_structure_type => 'EXPENDITURES',
                x_return_status => l_return_status,
                x_error_message_code => l_error_message_code);

          IF l_return_status = FND_API.G_RET_STS_ERROR THEN
             PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                   ,p_msg_name       => l_error_message_code );
             PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
          END IF;

       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;
     --
     -- Validate if Search Start Org is in the Search Org Hierarchy
     --

     IF (l_assignment_rec.search_exp_start_org_id <> FND_API.G_MISS_NUM AND l_assignment_rec.search_exp_start_org_id IS NOT NULL)

OR (p_search_exp_start_org_name <> FND_API.G_MISS_CHAR and p_search_exp_start_org_name IS NOT NULL) THEN
       IF l_assignment_rec.search_exp_start_org_id IS NOT NULL AND l_assignment_rec.search_exp_org_struct_ver_id IS NOT NULL THEN
          PA_ORG_UTILS.Check_Org_In_OrgHierarchy(
                p_organization_id => l_assignment_rec.search_exp_start_org_id,
                p_org_structure_version_id => l_assignment_rec.search_exp_org_struct_ver_id,
                p_org_structure_type => 'EXPENDITURES',
                x_return_status => l_return_status,
                x_error_message_code => l_error_message_code);

          IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
            PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
          END IF;
          l_return_status := FND_API.G_MISS_CHAR;
          l_error_message_code := FND_API.G_MISS_CHAR;

       END IF;

     END IF;


     -- Validate Staffing Owner
     IF (l_assignment_rec.staffing_owner_person_id <> FND_API.G_MISS_NUM AND l_assignment_rec.staffing_owner_person_id IS NOT NULL)

OR (p_staffing_owner_name <> FND_API.G_MISS_CHAR and p_staffing_owner_name IS NOT NULL) THEN
        l_temp_staff_owner_person_id := l_assignment_rec.staffing_owner_person_id;
        PA_RESOURCE_UTILS.Check_ResourceName_Or_Id (
              p_resource_id        => l_temp_staff_owner_person_id
             ,p_resource_name      => p_staffing_owner_name
             ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
             ,p_date               => sysdate
             ,x_resource_id        => l_assignment_rec.staffing_owner_person_id
             ,x_resource_type_id   => l_resource_type_id
             ,x_return_status      => l_return_status
             ,x_error_message_code => l_error_message_code);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS OR l_resource_type_id <> 101 THEN
           PA_UTILS.Add_Message ('PA', 'PA_INV_STAFF_OWNER');
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;

        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;
     --
     -- Validate Transfer Price Currency
     --

     IF l_assignment_rec.tp_currency_override <> FND_API.G_MISS_CHAR AND l_assignment_rec.tp_currency_override IS NOT NULL THEN

       PA_PROJECTS_MAINT_UTILS.Check_currency_name_or_code(
          p_agreement_currency       => l_assignment_rec.tp_currency_override
         ,p_agreement_currency_name  => null
         ,p_check_id_flag            => 'Y'
       --,x_agreement_currency       => l_assignment_rec.tp_currency_override              Bug: 4537865
         ,x_agreement_currency       => l_new_tp_currency_override                      -- Bug: 4537865
         ,x_return_status            => l_return_status
         ,x_error_msg_code           => l_error_message_code);
       --Bug:4537865
       IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.tp_currency_override := l_new_tp_currency_override;
       END IF;
       --Bug:4537865

       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CURR_NOT_VALID');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;
     --
     -- Validate Bill Rate Currency
     --

     IF l_assignment_rec.bill_rate_curr_override <> FND_API.G_MISS_CHAR AND l_assignment_rec.bill_rate_curr_override IS NOT NULL THEN

       PA_PROJECTS_MAINT_UTILS.Check_currency_name_or_code(
          p_agreement_currency       => l_assignment_rec.bill_rate_curr_override
         ,p_agreement_currency_name  => null
         ,p_check_id_flag            => 'Y'
       --,x_agreement_currency       => l_assignment_rec.bill_rate_curr_override        Bug: 4537865
         ,x_agreement_currency       => l_new_bill_rate_curr_override                   --Bug: 4537865
         ,x_return_status            => l_return_status
         ,x_error_msg_code           => l_error_message_code);
       -- Bug: 4537865
        IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.bill_rate_curr_override := l_new_bill_rate_curr_override;
        END IF;
       -- Bug: 4537865

       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
         PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_CURR_NOT_VALID');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;

     --
     -- Validate Transfer Price Overrides - Transfer Price Rate
     --
     IF l_assignment_rec.tp_rate_override <> FND_API.G_MISS_NUM AND l_assignment_rec.tp_rate_override IS NOT NULL THEN

       IF l_assignment_rec.tp_rate_override < 0 THEN   -- Bug 3198183
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_TP_RATE_OVRD');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
     END IF;

     --
     -- Validate Bill Rate Overrides - Bill Rate
     --
     IF l_assignment_rec.bill_rate_override <> FND_API.G_MISS_NUM AND l_assignment_rec.bill_rate_override IS NOT NULL THEN

       IF l_assignment_rec.bill_rate_override <= 0 THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_BILL_RATE_OVRD');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
     END IF;
     --
     -- Validate Bill Rate Overrides - Markup %
     --

     IF l_assignment_rec.markup_percent_override <> FND_API.G_MISS_NUM AND l_assignment_rec.markup_percent_override  IS NOT NULL

THEN

        IF l_assignment_rec.markup_percent_override < 0 THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_MARKUP_PERCENT');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;

     END IF;

     /* Bug2590938 Begin */
     --
     -- Validate Bill Rate Overrides - Discount %
     --
     IF (l_assignment_rec.discount_percentage <> FND_API.G_MISS_NUM AND l_assignment_rec.discount_percentage IS NOT NULL) THEN

        IF (l_assignment_rec.discount_percentage < 0 OR l_assignment_rec.discount_percentage > 100)THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_DISCOUNT_PERCENT');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;

     END IF;


     OPEN get_bill_rate_override_flags;
     FETCH get_bill_rate_override_flags INTO  l_rate_discount_reason_flag, l_br_override_flag, l_br_discount_override_flag;
     CLOSE get_bill_rate_override_flags;




     -- This message is being populated here instead of java code because of easy code implementation steps
     IF (l_assignment_rec.rate_disc_reason_code = FND_API.G_MISS_CHAR OR l_assignment_rec.rate_disc_reason_code is NULL)THEN
        IF (l_rate_discount_reason_flag ='Y' AND (l_br_override_flag ='Y' OR l_br_discount_override_flag='Y') AND
           ((l_assignment_rec.discount_percentage <> FND_API.G_MISS_NUM AND l_assignment_rec.discount_percentage IS NOT NULL) OR
           (l_assignment_rec.discount_percentage <> FND_API.G_MISS_NUM AND l_assignment_rec.discount_percentage IS NOT NULL) OR
           (l_assignment_rec.discount_percentage <> FND_API.G_MISS_NUM AND l_assignment_rec.discount_percentage IS NOT NULL))) THEN

              PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_RATE_DISC_REASON_REQUIRED');
              PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

        END IF;
     END IF;
    /*  Bug2590938 End */

     --
     -- Validate Bill Rate Overrides - Basis Apply %
     --
     IF l_assignment_rec.tp_percent_applied_override <> FND_API.G_MISS_NUM AND l_assignment_rec.tp_percent_applied_override  IS NOT

NULL THEN

        IF l_assignment_rec.tp_percent_applied_override < 0 THEN

          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_APPLY_BASIS_PERCENT');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;

     END IF;
     --
     -- Validate Search Country
     --


     IF (l_assignment_rec.search_country_code <> FND_API.G_MISS_CHAR AND l_assignment_rec.search_country_code IS NOT NULL) OR

(p_search_country_name <> FND_API.G_MISS_CHAR AND p_search_country_name IS NOT NULL) THEN
       PA_LOCATION_UTILS.Check_Country_Name_Or_Code(p_country_code => l_assignment_rec.search_country_code,
                                                    p_country_name => p_search_country_name,
                                                    p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                                  --x_country_code => l_assignment_rec.search_country_code,     Bug:4537865
                                                    x_country_code => l_new_search_country_code,                --Bug: 4537865
                                                    x_return_status => l_return_status,
                                                    x_error_message_code => l_error_message_code);
        -- Bug: 4537865
        IF  l_return_status = FND_API.G_RET_STS_SUCCESS THEN
                l_assignment_rec.search_country_code := l_new_search_country_code;
        END IF;

       -- Bug: 4537865

        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;


     --
     --Validate Subteam
     --

     IF  ((p_project_subteam_id IS NOT NULL AND p_project_subteam_id <> FND_API.G_MISS_NUM) OR
         (p_project_subteam_name IS NOT NULL AND p_project_subteam_name <> FND_API.G_MISS_CHAR)) AND
         ((l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <>FND_API.G_MISS_NUM) OR
         (l_assignment_rec.assignment_template_id IS NOT NULL AND l_assignment_rec.assignment_template_id <> FND_API.G_MISS_NUM))

THEN

       IF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <>FND_API.G_MISS_NUM THEN

           l_object_type := 'PA_PROJECTS';

           l_object_id := l_assignment_rec.project_id;

       ELSIF l_assignment_rec.assignment_template_id IS NOT NULL AND l_assignment_rec.assignment_template_id <> FND_API.G_MISS_NUM

THEN

           l_object_type := 'PA_TEAM_TEMPLATES';

           l_object_id := l_assignment_rec.assignment_template_id;

       END IF;


        l_subteam_id := p_project_subteam_id;

        IF (l_subteam_id = FND_API.G_MISS_NUM) THEN
           l_subteam_id := NULL;
        END IF;

        PA_PROJECT_SUBTEAM_UTILS.Check_Subteam_Name_Or_Id( p_subteam_name       => p_project_subteam_name
                                                          ,p_object_type        => l_object_type
                                                          ,p_object_id          => l_object_id
                                                          ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                          ,x_subteam_id         => l_subteam_id  --IN/OUT
                                                          ,x_return_status      => l_return_status
                                                          ,x_error_message_code => l_error_message_code );

        IF  l_return_status = FND_API.G_RET_STS_ERROR THEN

         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name       => l_error_message_code );
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;
     END IF;

     --dbms_output.put_line('after check subteam name');
     --dbms_output.put_line('subteam id'||l_subteam_id);

     --
     -- Validate Work Type
     -- If work type name is valid and work_type_id is null then returns the work_type_id
     --
     -- 5130421 : Replaced AND with OR

     IF l_assignment_rec.work_type_id <> FND_API.G_MISS_NUM OR
        p_work_type_name <> FND_API.G_MISS_CHAR THEN

       l_temp_work_type_id := l_assignment_rec.work_type_id;
       PA_WORK_TYPE_UTILS.Check_Work_Type_Name_Or_Id( p_work_type_id       => l_temp_work_type_id
                                                   ,p_name               => p_work_type_name
                                                   ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                                                   ,x_work_type_id       => l_assignment_rec.work_type_id
                                                   ,x_return_status      => l_return_status
                                                   ,x_error_message_code => l_error_message_code );
       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name       => l_error_message_code );
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
         --dbms_output.put_line('work type error');

       ELSIF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN
         --
         --check for indirect project, only non-billable work types if this is NOT
         --a template requirement
         --
         PA_WORK_TYPE_UTILS.CHECK_WORK_TYPE (
          P_WORK_TYPE_ID             =>  l_assignment_rec.work_type_id
          ,P_PROJECT_ID               =>  l_assignment_rec.project_id
          ,P_TASK_ID                  =>  NULL
        ,X_RETURN_STATUS            =>  l_return_status
        ,X_ERROR_MESSAGE_CODE       =>  l_error_message_code);
         --dbms_output.put_line('after check work type');


         IF l_return_status = FND_API.G_RET_STS_ERROR  THEN


          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
         END IF;

       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     END IF; -- validate work type
     --
     --Validate Staffing Priority
     --
     IF (l_assignment_rec.staffing_priority_code IS NOT NULL AND
        l_assignment_rec.staffing_priority_code <> FND_API.G_MISS_CHAR) OR
        (p_staffing_priority_name IS NOT NULL AND p_staffing_priority_name <> FND_API.G_MISS_CHAR) THEN

        PA_ASSIGNMENT_UTILS.Check_STF_PriorityName_Or_Code (p_staffing_priority_code  => l_assignment_rec.staffing_priority_code
                                       ,p_staffing_priority_name  => p_staffing_priority_name
                                       ,p_check_id_flag           => PA_STARTUP.G_Check_ID_Flag
                                     --,x_staffing_priority_code  => l_assignment_rec.staffing_priority_code    Bug: 4537865
                                       ,x_staffing_priority_code  => l_new_staffing_priority_code               -- Bug: 4537865
                                       ,x_return_status           => l_return_status
                                       ,x_error_message_code      => l_error_message_code);
        -- Bug: 4537865
        IF  l_return_status = FND_API.G_RET_STS_SUCCESS  THEN
                l_assignment_rec.staffing_priority_code := l_new_staffing_priority_code;
        END IF;
        -- Bug: 4537865
        IF  l_return_status = FND_API.G_RET_STS_ERROR  THEN
          PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;
     END IF;

     --
     --Validate Expenditure Type Class
     --


     --Call Name to ID validation
     --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS
     IF (l_assignment_rec.expenditure_type_class IS NOT NULL) AND
        (l_assignment_rec.expenditure_type_class <> FND_API.G_MISS_CHAR) AND
        (l_assignment_rec.project_id <> FND_API.G_MISS_NUM AND l_assignment_rec.project_id IS NOT NULL) THEN

       l_temp_expenditure_type_class := l_assignment_rec.expenditure_type_class;
       PA_EXPENDITURES_UTILS.Check_Exp_Type_Class_Code(
                        p_sys_link_func     => l_temp_expenditure_type_class
                       ,p_exp_meaning       => NULL
                       ,p_check_id_flag     => PA_STARTUP.G_Check_ID_Flag
                       ,x_sys_link_func     => l_assignment_rec.expenditure_type_class
                       ,x_return_status     => l_return_status
                       ,x_error_message_code=> l_error_message_code) ;
       IF  l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN


         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                             ,p_msg_name       => l_error_message_code );
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        --dbms_output.put_line('expenditure type class error1');

       END IF;
       l_return_status := FND_API.G_MISS_CHAR;
       l_error_message_code := FND_API.G_MISS_CHAR;

     --else get expenditure type class using expenditure type
     ELSIF (l_assignment_rec.expenditure_type <> FND_API.G_MISS_CHAR
       AND l_assignment_rec.expenditure_type IS NOT NULL) THEN
       --Get expenditure type class code
       --dbms_output.put_line('get expenditure type class ');

       OPEN get_expenditure_type_class;
       FETCH get_expenditure_type_class INTO l_assignment_rec.expenditure_type_class;

       IF get_expenditure_type_class%NOTFOUND THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_EXPTYPE_INVALID' );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
       CLOSE get_expenditure_type_class;
     END IF;


    IF (p_asgn_update_mode <> 'MASS_ONLINE') THEN


     --
     --Validate Expenditure Type
     --
     --dbms_output.put_line('start date:'||l_assignment_rec.start_date);
     --Call Name to ID validation
     --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS
     IF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <>FND_API.G_MISS_NUM AND
        l_assignment_rec.expenditure_type <> FND_API.G_MISS_CHAR AND l_assignment_rec.expenditure_type IS NOT NULL THEN

        PA_EXPENDITURES_UTILS.Check_Expenditure_Type( p_expenditure_type   => l_assignment_rec.expenditure_type
                                                     ,p_date               => l_assignment_rec.start_date
                                                     ,x_valid              => l_valid_flag
                                                     ,x_return_status      => l_return_status
                                                     ,x_error_message_code => l_error_message_code);

         IF  l_return_status <> FND_API.G_RET_STS_SUCCESS  THEN
            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                  ,p_msg_name       => l_error_message_code );
            PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
           --dbms_output.put_line('expenditure type error');

         END IF;
         l_return_status := FND_API.G_MISS_CHAR;
         l_error_message_code := FND_API.G_MISS_CHAR;

     END IF;
     --
     --Validate Expenditure Type and Type Class comb
     --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS
     IF (l_assignment_rec.project_id <> FND_API.G_MISS_NUM AND l_assignment_rec.project_id IS NOT NULL) AND
        l_assignment_rec.expenditure_type <> FND_API.G_MISS_CHAR AND l_assignment_rec.expenditure_type IS NOT NULL AND
        l_assignment_Rec.expenditure_type_class <> FND_API.G_MISS_CHAR AND l_assignment_rec.expenditure_type_class IS NOT NULL

THEN
        l_valid_flag := 'Y';  -- 5130421
        PA_EXPENDITURES_UTILS.Check_Exp_Type_Sys_Link_Combo(
                           p_exp_type          => l_assignment_rec.expenditure_type
                          ,p_ei_date           => l_assignment_rec.start_date
                          ,p_sys_link_func     => l_assignment_Rec.expenditure_type_class
                          ,x_valid             => l_valid_flag
                          ,x_return_status     => l_return_status
                          ,x_error_message_code=> l_error_message_code);
	-- 5130421 : We shd check both l_return_status and also l_valid_flag
	-- This is because of a bug in Check_Exp_Type_Sys_Link_Combo code
	--IF  l_return_status = FND_API.G_RET_STS_ERROR  THEN
	IF l_valid_flag <> 'Y' THEN
		PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
				     ,p_msg_name       => 'PA_EXPTYPE_SYSLINK_INVALID' );
		PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
	END IF;
	IF l_return_status = FND_API.G_RET_STS_ERROR THEN
		PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
				     ,p_msg_name       => l_error_message_code );
		PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
	END IF;
        l_return_status := FND_API.G_MISS_CHAR;
        l_error_message_code := FND_API.G_MISS_CHAR;
     END IF;
    END IF;  -- end of checking not in Mass Online mode, the date related validation should be avoided.
     --
     -- The following validation only need to be done for Requirement - NOT TEMPLATE REQUIREMENTS
     --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS
     IF l_assignment_rec.assignment_type = 'OPEN_ASSIGNMENT' AND
        (l_assignment_rec.project_id <> FND_API.G_MISS_NUM AND l_assignment_rec.project_id IS NOT NULL) THEN

       --
       --Validate Oganization Name/ID
       --
       --Call validation API
     IF (l_assignment_rec.expenditure_organization_id <> FND_API.G_MISS_NUM AND l_assignment_rec.expenditure_organization_id IS NOT

NULL) OR (p_exp_organization_name <> FND_API.G_MISS_CHAR AND p_exp_organization_name IS NOT NULL ) THEN

         l_temp_exp_organization_id := l_assignment_rec.expenditure_organization_id;
         PA_HR_ORG_UTILS.Check_OrgName_Or_Id (p_organization_id => l_temp_exp_organization_id,
                                             p_organization_name => p_exp_organization_name,
                                             p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                             x_organization_id =>l_assignment_rec.expenditure_organization_id,
                                             x_return_status => l_return_status,
                                             x_error_msg_code =>l_error_message_code );
         IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                  ,p_msg_name       => 'PA_EXP_ORG_INVALID');
            PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

         ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
           IF (p_asgn_update_mode <> 'MASS_ONLINE') THEN

             --check a valid expenditure organization
             l_valid_flag := PA_UTILS2.CheckExpOrg (x_org_id => l_assignment_rec.expenditure_organization_id,
                                          x_txn_date => l_assignment_rec.start_date);

             IF l_valid_flag <> 'Y' THEN

              PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => 'PA_INVALID_EXP_ORG');
              PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
              --dbms_output.put_line('orgn id  error2:'||l_valid_flag);

             END IF;
           END IF; -- end of checking in Mass Update Online Mode, in which case start date related checks are skipped.

         END IF;
         l_return_status := FND_API.G_MISS_CHAR;
         l_error_message_code := FND_API.G_MISS_CHAR;
         l_valid_flag := FND_API.G_MISS_CHAR;

       END IF; -- Validate Oganization Name/ID
       --
       --Validate Forecast Job Group Name/ID
       --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS
       --Call validation API
     IF (l_assignment_rec.fcst_job_group_id <> FND_API.G_MISS_NUM AND l_assignment_rec.fcst_job_group_id IS NOT NULL) OR

(p_fcst_job_group_name <> FND_API.G_MISS_CHAR AND p_fcst_job_group_name IS NOT NULL ) THEN

         l_temp_fcst_job_group_id := l_assignment_rec.fcst_job_group_id;
         PA_JOB_UTILS.Check_Job_GroupName_Or_Id(
                        p_job_group_id       => l_temp_fcst_job_group_id
                       ,p_job_group_name     => p_fcst_job_group_name
                       ,p_check_id_flag      => PA_STARTUP.G_Check_ID_Flag
                       ,x_job_group_id       => l_assignment_rec.fcst_job_group_id
                       ,x_return_status      => l_return_status
                       ,x_error_message_code => l_error_message_code );

         IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
            PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
            PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
            --dbms_output.put_line('job group  error1');

         END IF;
         l_return_status := FND_API.G_MISS_CHAR;
         l_error_message_code := FND_API.G_MISS_CHAR;
       END IF;
       --
       --Validate Forecast Job Name/ID
       --
       --Call validation API
       --dbms_output.put_line('job   name'||p_fcst_job_name);
       --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS
     IF (l_assignment_rec.fcst_job_id <> FND_API.G_MISS_NUM AND l_assignment_rec.fcst_job_id IS NOT NULL) OR (p_fcst_job_name <>

FND_API.G_MISS_CHAR AND p_fcst_job_name IS NOT NULL ) THEN

                       l_temp_fcst_job_id := l_assignment_rec.fcst_job_id;
                       PA_JOB_UTILS.Check_JobName_Or_Id (
                          p_job_id              => l_temp_fcst_job_id
                         ,p_job_name            => p_fcst_job_name
                         ,p_check_id_flag       => PA_STARTUP.G_Check_ID_Flag
                         ,x_job_id              => l_assignment_rec.fcst_job_id
                         ,x_return_status       => l_return_status
                         ,x_error_message_code  => l_error_message_code);

          IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
             PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                   ,p_msg_name       => l_error_message_code );
             PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
             --dbms_output.put_line('job   error1');

          END IF;
          l_return_status := FND_API.G_MISS_CHAR;
          l_error_message_code := FND_API.G_MISS_CHAR;
       END IF;
       --
       --Validate Job is part of the Job Group
       --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS
       IF l_assignment_rec.fcst_job_id IS NOT NULL AND l_assignment_rec.fcst_job_id <> FND_API.G_MISS_NUM AND
          l_assignment_rec.fcst_job_group_id IS NOT NULL AND l_assignment_rec.fcst_job_group_id <> FND_API.G_MISS_NUM THEN

         PA_JOB_UTILS.validate_job_relationship (
                 p_job_id             => l_assignment_rec.fcst_job_id
                ,p_job_group_id       => l_assignment_rec.fcst_job_group_id
                ,x_return_status      => l_return_status
                ,x_error_message_code => l_error_message_code);
         IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
           --dbms_output.put_line('job relation  error1');
         END IF;
         l_return_status := FND_API.G_MISS_CHAR;
         l_error_message_code := FND_API.G_MISS_CHAR;
       END IF;

       --
       --Validate Operating Unit Name/ID
       --
       --Call Name to ID validation
       --NO FORECASTING ATTRIBUTES FOR TEMPLATE REQUIREMENTS

     IF (l_assignment_rec.expenditure_org_id <> FND_API.G_MISS_NUM AND l_assignment_rec.expenditure_org_id IS NOT NULL) OR

(p_expenditure_org_name <> FND_API.G_MISS_CHAR AND p_expenditure_org_name IS NOT NULL ) THEN

          l_temp_expenditure_org_id := l_assignment_rec.expenditure_org_id;
          PA_HR_ORG_UTILS.Check_OrgName_Or_Id (p_organization_id => l_temp_expenditure_org_id,
                                                p_organization_name => p_expenditure_org_name,
                                                p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
                                                x_organization_id =>l_assignment_rec.expenditure_org_id,
                                                x_return_status => l_return_status,
                                                x_error_msg_code =>l_error_message_code );

          IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
             PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                   ,p_msg_name       => 'PA_EXP_OU_INVALID' );
             PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

          ELSIF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
              l_return_status := FND_API.G_MISS_CHAR;
              l_error_message_code := FND_API.G_MISS_CHAR;

              --
              --Validate a valid Operating Unit
              --
              pa_hr_update_api.check_exp_OU(p_org_id             =>l_assignment_rec.expenditure_org_id
                                       ,x_return_status      =>l_return_status
                                       ,x_error_message_code =>l_error_message_code ) ;
              IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
                PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                  ,p_msg_name       => l_error_message_code );
                PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
                --dbms_output.put_line('OU id  error1');

              END IF;
           END IF;
           l_return_status := FND_API.G_MISS_CHAR;
           l_error_message_code := FND_API.G_MISS_CHAR;
           --dbms_output.put_line('after OU check');

       END IF; -- Validate Operating Unit Name/ID
     END IF; --end of Requirement (NOT TEMPLATE REQUIREMENTS) validations

     --
     --Validation for Amount Type, no need if Admin Assignment OR TEMPLATE REQUIREMENT
     --

    IF (l_assignment_rec.fcst_tp_amount_type IS NOT NULL AND l_assignment_rec.fcst_tp_amount_type <>FND_API.G_MISS_CHAR)
        AND  (l_assignment_rec.project_id <> FND_API.G_MISS_NUM AND l_assignment_rec.project_id IS NOT NULL)
        THEN

       --Call validation API
       l_temp_fcst_tp_amount_type := l_assignment_rec.fcst_tp_amount_type;
       PA_FORECAST_ITEMS_UTILS.Check_TPAmountType(
                     p_tp_amount_type_code  => l_temp_fcst_tp_amount_type
                    ,p_tp_amount_type_desc  => NULL
                    ,p_check_id_flag        => PA_STARTUP.G_Check_ID_Flag
                    ,x_tp_amount_type_code  => l_assignment_rec.fcst_tp_amount_type
                    ,x_tp_amount_type_desc  => l_tp_amount_type_desc
                    ,x_return_status        => l_return_status
                    ,x_msg_count            => l_msg_count
                    ,x_msg_data             => l_msg_data);
       IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
          --dbms_output.put_line('TP amount type  error1');

       END IF;
       l_return_status := FND_API.G_MISS_CHAR;

     END IF; --end of Amount Type

  -- Perform security check for Admin Assignment
  -- if this is with in Mass Update Workflow
  IF l_assignment_rec.assignment_type='STAFFED_ADMIN_ASSIGNMENT' AND p_resource_id IS NOT NULL THEN

    IF p_asgn_update_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO OR
       p_asgn_update_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS THEN

        --dbms_output.put_line('check PA_ADM_ASN_CR_AND_DL for Mass Update ');

         pa_security_pvt.check_confirm_asmt(p_project_id => l_assignment_rec.project_id,
                                              p_resource_id => p_resource_id,
                                              p_resource_name => null,
                                              p_privilege => 'PA_ADM_ASN_CR_AND_DL',
                                              p_start_date => l_assignment_rec.start_date,
                                              x_ret_code => l_ret_code,
                                              x_return_status => l_return_status,
                                              x_msg_count => l_msg_count,
                                              x_msg_data => l_msg_data);

         IF  l_ret_code = FND_API.G_FALSE THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_ADD_ADMIN_ASMT_SECURITY' );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
         END IF;
    END IF;
    IF p_asgn_update_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS THEN

       --dbms_output.put_line('check PA_ADM_ASN_CR_AND_DL for Mass Update Forecast ');

         pa_security_pvt.check_confirm_asmt(p_project_id => l_assignment_rec.project_id,
                                              p_resource_id => p_resource_id,
                                              p_resource_name => null,
                                              p_privilege => 'PA_ADM_ASN_FCST_INFO_ED',
                                              p_start_date => l_assignment_rec.start_date,
                                              x_ret_code => l_ret_code,
                                              x_return_status => l_return_status,
                                              x_msg_count => l_msg_count,
                                              x_msg_data => l_msg_data);

         IF  l_ret_code = FND_API.G_FALSE THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_ADD_ADMIN_ASMT_SECURITY' );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
         END IF;
    END IF;

  END IF;
  --dbms_output.put_line('Finish Validation');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Update_Assignment.pvt_update_asgmt'
                       ,x_msg         => 'Calling PVT Update_Assignment'
                       ,x_log_level   => 5);
  END IF;

   --For non Template Requirement, reset start_date to default values.
   /* Added extra condition for GSI PJR enhancement. bug # 7693634*/
   IF (l_assignment_rec.project_id <> FND_API.G_MISS_NUM AND l_assignment_rec.project_id IS NOT NULL AND p_context <> 'SS_UPDATE_ASSIGN') THEN
     l_assignment_rec.start_date := FND_API.G_MISS_DATE;
   END IF;

   IF p_asgn_update_mode <> 'MASS_ONLINE' THEN


    --dbms_output.put_line('Calling PVTB Update_Assignment');
    PA_ASSIGNMENTS_PVT.Update_Assignment
   ( p_assignment_rec         => l_assignment_rec
   ,p_project_subteam_id      => l_subteam_id
   ,p_project_subteam_party_id=> p_project_subteam_party_id
   ,p_location_city           => p_location_city
   ,p_location_region         => p_location_region
   ,p_location_country_code   => l_location_country_code
   ,p_commit                  => p_commit
   ,p_validate_only           => p_validate_only
   ,x_return_status           => l_return_status
   );


  END IF;

  END IF;  -- end of checking if record version and wf pending is OK.

END IF;  -- end of checking if trying to change schedule status for non template requirement.

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  --IF PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_TRUE  THEN
  IF   x_msg_count > 0 THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     ELSE
        ROLLBACK TO ASG_PUB_UPDATE_ASSIGNMENT;
     END IF;
  END IF;

  --
  -- Put any message text from message stack into the Message ARRAY
  --
  EXCEPTION
    WHEN OTHERS THEN

        IF p_commit = FND_API.G_TRUE THEN
          ROLLBACK TO ASG_PUB_UPDATE_ASSIGNMENT;
        END IF;
        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Update_Assignment'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
--
END Update_Assignment;



PROCEDURE Delete_Assignment
( p_assignment_row_id           IN     ROWID                                           := NULL
 ,p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE       := FND_API.G_MISS_NUM
 ,p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_assignment_type             IN     pa_project_assignments.assignment_type%TYPE     := FND_API.G_MISS_CHAR
 ,p_assignment_number           IN     pa_project_assignments.assignment_number%TYPE   := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_api_version                 IN     NUMBER                                          := 1.0 /* Bug 1851096 */
 ,p_init_msg_list               IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,p_max_msg_count               IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

 l_project_party_id            NUMBER;
 l_msg_index_out               NUMBER;
 l_assignment_row_id           ROWID;
 l_assignment_id               NUMBER;
 l_workflow_in_progress_flag   pa_team_templates.workflow_in_progress_flag%TYPE;
 l_project_id                  pa_project_assignments.project_id%TYPE;
 l_mass_wf_in_progress_flag pa_project_assignments.mass_wf_in_progress_flag%TYPE;
 l_return_status       VARCHAR2(1);

CURSOR check_record_version IS
SELECT ROWID, project_party_id,project_id
FROM   pa_project_assignments
WHERE  assignment_id = p_assignment_id
AND    record_version_number = p_record_version_number;

CURSOR check_source_assignment IS
SELECT assignment_id
FROM   pa_project_assignments
WHERE  source_assignment_id = p_assignment_id;

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

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Delete_Assignment');
  --dbms_output.put_line('PA_ASSIGNMENTS_PUB.delete assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Delete_Assignment.begin'
                       ,x_msg         => 'Beginning of Delete_Assignment'
                       ,x_log_level   => 5);
  END IF;

  -- Initialize the error flag
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_FALSE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PUB_DELETE_ASSIGNMENT;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;


--check if this assignment is the source of another assignment.
--if so, it can't be deleted.
OPEN check_source_assignment;
FETCH check_source_assignment INTO l_assignment_id;
CLOSE check_source_assignment;
IF l_assignment_id IS NOT NULL THEN

   PA_UTILS.Add_Message( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_ASGN_AS_SOURCE_ASGN');
   PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
   x_return_status := FND_API.G_RET_STS_ERROR;

ELSE

--check the record version number
OPEN check_record_version;
FETCH check_record_version INTO l_assignment_row_id, l_project_party_id, l_project_id;
CLOSE check_record_version;
IF l_assignment_row_id IS NULL THEN
   PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_XC_RECORD_CHANGED');
   PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
   x_return_status := FND_API.G_RET_STS_ERROR;

ELSE

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

ELSE

-- check that mass workflow for updating assignment is not in progress.
-- if mass workflow is in progress, cannot delete the assignment
OPEN check_project_assignment_wf;
FETCH check_project_assignment_wf INTO l_mass_wf_in_progress_flag;
CLOSE check_project_assignment_wf;

--dbms_output.put_line('mass_wf_in_progress_flag='||l_mass_wf_in_progress_flag);

    IF l_mass_wf_in_progress_flag = 'Y' THEN
      PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                                      ,p_msg_name       => 'PA_ASSIGNMENT_WF');
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
      x_return_status := FND_API.G_RET_STS_ERROR;

    ELSE

      --IF assignment is pending approval, abort the approval process
      IF PA_ASGMT_WFSTD.is_approval_pending(p_assignment_id => p_assignment_id) = 'Y' THEN
        PA_ASSIGNMENT_APPROVAL_PVT.Abort_Assignment_Approval(p_assignment_id => p_assignment_id
                                                             ,p_project_id   => l_project_id
                                                             ,x_return_status => l_return_status);
        IF x_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
      END IF;
    END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Delete_Assignment.pvt_delete_asgmt'
                       ,x_msg         => 'Calling PVT Delete_Assignment'
                       ,x_log_level   => 5);
  END IF;

  -- Call the private API
  PA_ASSIGNMENTS_PVT.Delete_Assignment
  ( p_assignment_row_id     => l_assignment_row_id
   ,p_assignment_id         => p_assignment_id
   ,p_assignment_type       => p_assignment_type
   ,p_record_version_number => p_record_version_number
   ,p_assignment_number     => p_assignment_number
   ,p_project_party_id      => l_project_party_id
   ,p_calling_module        => p_calling_module
   ,p_commit                => p_commit
   ,p_validate_only         => p_validate_only
   ,x_return_status         => l_return_status
  );

END IF;
END IF;
END IF;
END IF;
  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     ELSE
        ROLLBACK TO ASG_PUB_DELETE_ASSIGNMENT;
     END IF;
  END IF;

   -- Put any message text from message stack into the Message ARRAY
   --
   EXCEPTION
     WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO ASG_PUB_DELETE_ASSIGNMENT;
         END IF;
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Delete_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs
--
END Delete_Assignment;


PROCEDURE Copy_Team_Role
 (p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'COPY'
 ,p_api_version                 IN     NUMBER                                          := 1.0 /* Bug 1851096 */
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
 )
IS

l_return_status             VARCHAR2(1);
l_msg_data                  VARCHAR2(2000);
l_msg_count                 NUMBER;
l_msg_index_out             NUMBER;
l_assignment_rec            assignment_rec_type;
l_resource_id               pa_resources_denorm.resource_id%TYPE;
l_start_req_status_code     pa_project_statuses.project_status_code%TYPE;
l_adv_action_set_id         pa_action_sets.action_set_id%TYPE;

BEGIN

  --dbms_output.put_line('PA_ASSIGNMENTS_PUB.Copy_Team_Role');

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Copy_Team_Role');
  --dbms_output.put_line('PA_ASSIGNMENTS_PUB.Copy_Team_Role');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Copy_Team_Role'
                       ,x_msg         => 'Beginning of Copy_Team_Role'
                       ,x_log_level   => 5);
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  --Initialize return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- bill rate and transfer price override values are not copied

 SELECT  pa.assignment_name
        ,'OPEN_ASSIGNMENT'
        ,pa.assignment_type
        ,pa.staffing_priority_code
        ,pa.project_id
        ,pa.project_role_id
        ,pa.description
        ,pa.start_date
        ,pa.end_date
        ,pa.status_code
        ,pa.assignment_effort
        ,pa.extension_possible
        ,pa.min_resource_job_level
        ,pa.max_resource_job_level
        ,pa.additional_information
        ,pa.location_id
        ,pa.work_type_id
        ,pa.revenue_currency_code
        ,pa.revenue_bill_rate
        ,pa.markup_percent
        ,pa.expense_owner
        ,pa.expense_limit
        ,pa.expense_limit_currency_code
        ,pa.fcst_tp_amount_type
        ,pa.fcst_job_id
        ,pa.fcst_job_group_id
        ,pa.expenditure_org_id
        ,pa.expenditure_organization_id
        ,pa.expenditure_type_class
        ,pa.expenditure_type
        ,pa.calendar_type
        ,pa.calendar_id
        ,pa.competence_match_weighting
        ,pa.availability_match_weighting
        ,pa.job_level_match_weighting
        ,pa.search_min_availability
        ,pa.search_country_code
        ,pa.search_exp_org_struct_ver_id
        ,pa.search_exp_start_org_id
        ,pa.search_min_candidate_score
        ,pa.enable_auto_cand_nom_flag
        ,pa.staffing_owner_person_id
        ,pa.attribute_category
        ,pa.attribute1
        ,pa.attribute2
        ,pa.attribute3
        ,pa.attribute4
        ,pa.attribute5
        ,pa.attribute6
        ,pa.attribute7
        ,pa.attribute8
        ,pa.attribute9
        ,pa.attribute10
        ,pa.attribute11
        ,pa.attribute12
        ,pa.attribute13
        ,pa.attribute14
        ,pa.attribute15
        ,asets.action_set_id
        ,pa.bill_rate_override
        ,pa.bill_rate_curr_override
        ,pa.markup_percent_override
        ,pa.tp_rate_override
        ,pa.tp_currency_override
        ,pa.tp_calc_base_code_override
        ,pa.tp_percent_applied_override
        ,pa.resource_list_member_id -- FP.M Development
 INTO
       l_assignment_rec.assignment_name
      ,l_assignment_rec.assignment_type
      ,l_assignment_rec.source_assignment_type
      ,l_assignment_rec.staffing_priority_code
      ,l_assignment_rec.project_id
      ,l_assignment_rec.project_role_id
      ,l_assignment_rec.description
      ,l_assignment_rec.start_date
      ,l_assignment_rec.end_date
      ,l_assignment_rec.status_code
      ,l_assignment_rec.assignment_effort
      ,l_assignment_rec.extension_possible
      ,l_assignment_rec.min_resource_job_level
      ,l_assignment_rec.max_resource_job_level
      ,l_assignment_rec.additional_information
      ,l_assignment_rec.location_id
      ,l_assignment_rec.work_type_id
      ,l_assignment_rec.revenue_currency_code
      ,l_assignment_rec.revenue_bill_rate
      ,l_assignment_rec.markup_percent
      ,l_assignment_rec.expense_owner
      ,l_assignment_rec.expense_limit
      ,l_assignment_rec.expense_limit_currency_code
      ,l_assignment_rec.fcst_tp_amount_type
      ,l_assignment_rec.fcst_job_id
      ,l_assignment_rec.fcst_job_group_id
      ,l_assignment_rec.expenditure_org_id
      ,l_assignment_rec.expenditure_organization_id
      ,l_assignment_rec.expenditure_type_class
      ,l_assignment_rec.expenditure_type
      ,l_assignment_rec.calendar_type
      ,l_assignment_rec.calendar_id
      ,l_assignment_rec.comp_match_weighting
      ,l_assignment_rec.avail_match_weighting
      ,l_assignment_rec.job_level_match_weighting
      ,l_assignment_rec.search_min_availability
      ,l_assignment_rec.search_country_code
      ,l_assignment_rec.search_exp_org_struct_ver_id
      ,l_assignment_rec.search_exp_start_org_id
      ,l_assignment_rec.search_min_candidate_score
      ,l_assignment_rec.enable_auto_cand_nom_flag
      ,l_assignment_rec.staffing_owner_person_id
      ,l_assignment_rec.attribute_category
      ,l_assignment_rec.attribute1
      ,l_assignment_rec.attribute2
      ,l_assignment_rec.attribute3
      ,l_assignment_rec.attribute4
      ,l_assignment_rec.attribute5
      ,l_assignment_rec.attribute6
      ,l_assignment_rec.attribute7
      ,l_assignment_rec.attribute8
      ,l_assignment_rec.attribute9
      ,l_assignment_rec.attribute10
      ,l_assignment_rec.attribute11
      ,l_assignment_rec.attribute12
      ,l_assignment_rec.attribute13
      ,l_assignment_rec.attribute14
      ,l_assignment_rec.attribute15
      ,l_adv_action_set_id
      ,l_assignment_rec.bill_rate_override
      ,l_assignment_rec.bill_rate_curr_override
      ,l_assignment_rec.markup_percent_override
      ,l_assignment_rec.tp_rate_override
      ,l_assignment_rec.tp_currency_override
      ,l_assignment_rec.tp_calc_base_code_override
      ,l_assignment_rec.tp_percent_applied_override
      ,l_assignment_rec.resource_list_member_id
  FROM  pa_project_assignments pa,
        pa_action_sets asets
 WHERE  pa.assignment_id = p_assignment_id
   AND  asets.object_id(+) = pa.assignment_id
   AND  asets.object_type(+) = 'OPEN_ASSIGNMENT'
   AND  asets.action_set_type_code(+) = 'ADVERTISEMENT'
   AND  asets.status_code(+) <> 'DELETED';


 -- p_asgn_creation_mode = 'FULL' means it's cancel team role flow where we copy
 -- the planning resource of the once filled requirment to the new requirement
 IF p_asgn_creation_mode <> 'FULL' THEN
        l_assignment_rec.resource_list_member_id := NULL;
 END IF;

 l_assignment_rec.source_assignment_id := p_assignment_id;

 /* This is added because in Cancel_Assignment, this API is called to copy a new requirement
    from the old requirement with mode = 'FULL', but the source_assignment_id should not be NULLed out to
    keep link between the two records
 */
 IF p_asgn_creation_mode = 'FULL' THEN

   FND_PROFILE.Get('PA_START_OPEN_ASGMT_STATUS',l_assignment_rec.status_code);

   IF l_assignment_rec.status_code IS NULL THEN

        PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

   END IF;
 END IF;

 IF l_assignment_rec.calendar_type = 'RESOURCE' THEN
    l_assignment_rec.calendar_type := 'PROJECT';
    SELECT calendar_id INTO l_assignment_rec.calendar_id
      FROM pa_projects_all
     WHERE project_id = l_assignment_rec.project_id;
 END IF;

  -- Create the requirement
  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Copy_Team_Role'
                       ,x_msg         => 'Calling create assignment'
                       ,x_log_level   => 5);
  END IF;

  --dbms_output.put_line('calling PA_ASSIGNMENTS_PUB.Create_Assignment');
  --dbms_output.put_line('action set id = '|| l_adv_action_set_id );
  PA_ASSIGNMENTS_PUB.Create_Assignment
      ( p_assignment_rec             => l_assignment_rec
       ,p_asgn_creation_mode         => p_asgn_creation_mode
       ,p_adv_action_set_id          => l_adv_action_set_id
       ,p_commit                     => p_commit
       ,p_validate_only              => p_validate_only
       ,p_max_msg_count              => p_max_msg_count
       ,p_init_msg_list              => FND_API.G_TRUE
       ,x_new_assignment_id          => x_new_assignment_id
       ,x_assignment_number          => x_assignment_number
       ,x_assignment_row_id          => x_assignment_row_id
       ,x_resource_id                => l_resource_id
       ,x_return_status              => l_return_status
       ,x_msg_count                  => l_msg_count
       ,x_msg_data                   => l_msg_data
       );

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

   EXCEPTION
     WHEN OTHERS THEN
         -- Set the excetption Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Copy_Team_Role'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;

END Copy_Team_Role;


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
 ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
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
 ,p_calendar_id                 IN    pa_project_assignments.calendar_id%TYPE                 := FND_API.G_MISS_NUM
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
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
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
)
IS

cursor csr_get_tp_amt_type (p_asg_id NUMBER) IS
SELECT fcst_tp_amount_type
FROM   pa_project_assignments -- 5078700 changed from pa_project_assignments_v to pa_project_assignments
WHERE  assignment_id = p_asg_id;

l_new_assignment_id     pa_project_assignments.assignment_id%TYPE;
l_resource_id           pa_resources_denorm.resource_id%TYPE;
l_assignment_number     pa_project_assignments.assignment_number%TYPE;
l_assignment_row_id     ROWID;
l_status_code           pa_project_assignments.status_code%TYPE ; --Bug 7309934

l_new_assignment_id_tbl system.pa_num_tbl_type;
l_asg_tp_amount_type    pa_project_assignments_v.FCST_TP_AMOUNT_TYPE%TYPE;

BEGIN

  l_status_code       :=   p_status_code ;   -- Added default value population for Status Code. Bug 7309934

  IF l_status_code is NULL THEN

      IF (p_assignment_type = 'OPEN_ASSIGNMENT') THEN
       FND_PROFILE.Get('PA_START_OPEN_ASGMT_STATUS',l_status_code);
       IF l_status_code IS NULL THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
      END IF;

      IF (p_assignment_type = 'STAFFED_ASSIGNMENT' OR p_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT') THEN
       FND_PROFILE.Get('PA_START_STAFFED_ASGMT_STATUS',l_status_code);
       IF l_status_code IS NULL THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');
         PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;
      END IF;

  END IF;


   --  l_new_assignment_id_tbl:= SYSTEM.pa_num_tbl_type();
      --do online validation
      PA_ASSIGNMENTS_PUB.Execute_Create_Assignment
        ( p_asgn_creation_mode          => 'MASS'
         ,p_unfilled_assignment_status  => p_unfilled_assignment_status
         ,p_assignment_name             => p_assignment_name
         ,p_assignment_type             => p_assignment_type
         ,p_multiple_status_flag        => p_multiple_status_flag
         ,p_status_code                 => l_status_code
         ,p_staffing_priority_code      => p_staffing_priority_code
         ,p_project_id                  => p_project_id
         ,p_assignment_template_id      => p_assignment_template_id
         ,p_project_role_id             => p_project_role_id
         ,p_role_list_id                => p_role_list_id
         ,p_project_subteam_id          => p_project_subteam_id
         ,p_description                 => p_description
         ,p_start_date                  => p_start_date
         ,p_end_date                    => p_end_date
         ,p_assignment_effort           => p_assignment_effort
         ,p_extension_possible          => p_extension_possible
         ,p_source_assignment_id        => p_source_assignment_id
         ,p_min_resource_job_level      => p_min_resource_job_level
         ,p_max_resource_job_level      => p_max_resource_job_level
         ,p_additional_information      => p_additional_information
         ,p_location_id                 => p_location_id
         ,p_work_type_id                => p_work_type_id
         ,p_revenue_currency_code       => p_revenue_currency_code
         ,p_revenue_bill_rate           => p_revenue_bill_rate
         ,p_markup_percent              => p_markup_percent
         ,p_expense_owner               => p_expense_owner
         ,p_expense_limit               => p_expense_limit
         ,p_expense_limit_currency_code => p_expense_limit_currency_code
         ,p_fcst_tp_amount_type         => p_fcst_tp_amount_type
         ,p_fcst_job_id                 => p_fcst_job_id
         ,p_fcst_job_group_id           => p_fcst_job_group_id
         ,p_expenditure_org_id          => p_expenditure_org_id
         ,p_expenditure_organization_id => p_expenditure_organization_id
         ,p_expenditure_type_class      => p_expenditure_type_class
         ,p_expenditure_type            => p_expenditure_type
         ,p_calendar_type               => p_calendar_type
         ,p_calendar_id                 => p_calendar_id
         ,p_resource_calendar_percent   => p_resource_calendar_percent
         ,p_project_name                => p_project_name
         ,p_project_number              => p_project_number
         ,p_project_subteam_name        => p_project_subteam_name
         ,p_project_status_name         => p_project_status_name
         ,p_staffing_priority_name      => p_staffing_priority_name
         ,p_project_role_name           => p_project_role_name
         ,p_location_city               => p_location_city
         ,p_location_region             => p_location_region
         ,p_location_country_name       => p_location_country_name
         ,p_location_country_code       => p_location_country_code
         ,p_calendar_name               => p_calendar_name
         ,p_work_type_name              => p_work_type_name
         ,p_fcst_job_name               => p_fcst_job_name
         ,p_fcst_job_group_name         => p_fcst_job_group_name
         ,p_expenditure_org_name        => p_expenditure_org_name
         ,p_exp_organization_name       => p_exp_organization_name
         ,p_attribute_category          => p_attribute_category
         ,p_attribute1                  => p_attribute1
         ,p_attribute2                  => p_attribute2
         ,p_attribute3                  => p_attribute3
         ,p_attribute4                  => p_attribute4
         ,p_attribute5                  => p_attribute5
         ,p_attribute6                  => p_attribute6
         ,p_attribute7                  => p_attribute7
         ,p_attribute8                  => p_attribute8
         ,p_attribute9                  => p_attribute9
         ,p_attribute10                 => p_attribute10
         ,p_attribute11                 => p_attribute11
         ,p_attribute12                 => p_attribute12
         ,p_attribute13                 => p_attribute13
         ,p_attribute14                 => p_attribute14
         ,p_attribute15                 => p_attribute15
         ,p_api_version                 => p_api_version
         ,p_init_msg_list               => p_init_msg_list
         ,p_commit                      => p_commit
         ,p_validate_only               => FND_API.G_TRUE
         ,p_max_msg_count               => p_max_msg_count
         ,x_new_assignment_id_tbl       => l_new_assignment_id_tbl /*Added the parameter for bug 3079906*/
         ,x_new_assignment_id           => l_new_assignment_id
         ,x_assignment_number           => l_assignment_number
         ,x_assignment_row_id           => l_assignment_row_id
         ,x_resource_id                 => l_resource_id
         ,x_return_status               => x_return_status
         ,x_msg_count                   => x_msg_count
         ,x_msg_data                    => x_msg_data
     );


     --if p_validate_only=false and there are no errors then start the workflow process.
     IF p_validate_only = FND_API.G_FALSE AND FND_MSG_PUB.Count_Msg =0 THEN

       OPEN csr_get_tp_amt_type(l_new_assignment_id);
       FETCH csr_get_tp_amt_type into l_asg_tp_amount_type;
       CLOSE csr_get_tp_amt_type;

       --start the mass WF
       PA_MASS_ASGMT_TRX.Start_Mass_Asgmt_Trx_Wf(
          p_mode                        => PA_MASS_ASGMT_TRX.G_MASS_ASGMT
         ,p_action                      => PA_MASS_ASGMT_TRX.G_SAVE
         ,p_resource_id_tbl             => p_resource_id_tbl
         ,p_assignment_name             => p_assignment_name
         ,p_assignment_type             => p_assignment_type
         ,p_multiple_status_flag        => p_multiple_status_flag
         ,p_status_code                 => l_status_code
         ,p_staffing_priority_code      => p_staffing_priority_code
         ,p_project_id                  => p_project_id
         ,p_project_role_id             => p_project_role_id
         ,p_project_subteam_id          => p_project_subteam_id
         ,p_description                 => p_description
         ,p_start_date                  => p_start_date
         ,p_end_date                    => p_end_date
         ,p_extension_possible          => p_extension_possible
         ,p_min_resource_job_level      => p_min_resource_job_level
         ,p_max_resource_job_level      => p_max_resource_job_level
         ,p_additional_information      => p_additional_information
         ,p_location_id                 => p_location_id
         ,p_work_type_id                => p_work_type_id
         ,p_expense_owner               => p_expense_owner
         ,p_expense_limit               => p_expense_limit
         ,p_expense_limit_currency_code => p_expense_limit_currency_code
         ,p_fcst_tp_amount_type         => l_asg_tp_amount_type
         ,p_fcst_job_id                 => p_fcst_job_id
         ,p_fcst_job_group_id           => p_fcst_job_group_id
         ,p_expenditure_org_id          => p_expenditure_org_id
         ,p_expenditure_organization_id => p_expenditure_organization_id
         ,p_expenditure_type_class      => p_expenditure_type_class
         ,p_expenditure_type            => p_expenditure_type
         ,p_calendar_type               => p_calendar_type
         ,p_calendar_id                 => p_calendar_id
         ,p_resource_calendar_percent   => p_resource_calendar_percent
         ,p_project_name                => p_project_name
         ,p_project_number              => p_project_number
         ,p_project_subteam_name        => p_project_subteam_name
         ,p_project_status_name         => p_project_status_name
         ,p_staffing_priority_name      => p_staffing_priority_name
         ,p_project_role_name           => p_project_role_name
         ,p_location_city               => p_location_city
         ,p_location_region             => p_location_region
         ,p_location_country_name       => p_location_country_name
         ,p_location_country_code       => p_location_country_code
         ,p_calendar_name               => p_calendar_name
         ,p_work_type_name              => p_work_type_name
         ,p_revenue_currency_code       => p_revenue_currency_code
         ,p_revenue_bill_rate           => p_revenue_bill_rate
         ,p_fcst_job_name               => p_fcst_job_name
         ,p_fcst_job_group_name         => p_fcst_job_group_name
         ,p_expenditure_org_name        => p_expenditure_org_name
         ,p_exp_organization_name       => p_exp_organization_name
         ,x_return_status               => x_return_status
       );


     END IF;

     EXCEPTION
       WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Mass_Exec_Create_Assignments'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

END Mass_Exec_Create_Assignments;



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
 ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
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
 ,p_calendar_id                 IN    pa_project_assignments.calendar_id%TYPE                 := FND_API.G_MISS_NUM
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
 ,p_work_type_name              IN    pa_work_types_vl.name%TYPE                                 := FND_API.G_MISS_CHAR
 ,p_fcst_job_name               IN    per_jobs.name%TYPE                                      := FND_API.G_MISS_CHAR
 ,p_fcst_job_group_name         IN    per_job_groups.displayed_name%TYPE                      := FND_API.G_MISS_CHAR
 ,p_expenditure_org_name        IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
 ,p_exp_organization_name       IN    per_organization_units.name%TYPE                        := FND_API.G_MISS_CHAR
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
 ,x_success_assignment_id_tbl   OUT   NOCOPY  system.pa_num_tbl_type  -- For 1159 mandate changes bug#2674619
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

l_new_assignment_id     pa_project_assignments.assignment_id%TYPE;
l_new_assignment_id_tbl system.pa_num_tbl_type := p_resource_id_tbl;
l_resource_id           pa_resources_denorm.resource_id%TYPE;
l_assignment_number     pa_project_assignments.assignment_number%TYPE;
l_assignment_row_id     ROWID;
l_new_assignment_tabl     system.pa_num_tbl_type;
l_return_status         VARCHAR2(1);
l_staffing_owner_name   PER_PEOPLE_F.full_name%TYPE := null;
l_err_msg_code        VARCHAR2(80);
l_staffing_owner_person_id pa_project_assignments.staffing_owner_person_id%TYPE := null;

BEGIN


   -- Default Staffing Owner for the assignments
   IF p_assignment_type = 'STAFFED_ASSIGNMENT' THEN
      pa_assignment_utils.Get_Default_Staffing_Owner
          ( p_project_id                  => p_project_id
           ,p_exp_org_id                  => p_expenditure_org_id
           ,x_person_id                   => l_staffing_owner_person_id
           ,x_person_name                 => l_staffing_owner_name
           ,x_return_status               => x_return_status
           ,x_error_message_code          => l_err_msg_code);
   END IF;

   --loop through the resource ids and call execute_create_assignment
   --to actually create the assignment.  This is the WF (offline) process

   FOR i IN p_resource_id_tbl.FIRST .. p_resource_id_tbl.LAST LOOP

           --call execute_create_assignment
         PA_ASSIGNMENTS_PUB.Execute_Create_Assignment
           ( p_asgn_creation_mode          => 'MASS'
            ,p_unfilled_assignment_status  => p_unfilled_assignment_status
            ,p_assignment_name             => p_assignment_name
            ,p_assignment_type             => p_assignment_type
            ,p_multiple_status_flag        => p_multiple_status_flag
            ,p_status_code                 => p_status_code
            ,p_staffing_priority_code      => p_staffing_priority_code
            ,p_project_id                  => p_project_id
            ,p_assignment_template_id      => p_assignment_template_id
            ,p_project_role_id             => p_project_role_id
            ,p_role_list_id                => p_role_list_id
            ,p_resource_id                 => p_resource_id_tbl(i)
            ,p_project_subteam_id          => p_project_subteam_id
            ,p_description                 => p_description
            ,p_start_date                  => p_start_date
            ,p_end_date                    => p_end_date
            ,p_assignment_effort           => p_assignment_effort
            ,p_extension_possible          => p_extension_possible
            ,p_source_assignment_id        => p_source_assignment_id
            ,p_min_resource_job_level      => p_min_resource_job_level
            ,p_max_resource_job_level      => p_max_resource_job_level
            ,p_additional_information      => p_additional_information
            ,p_location_id                 => p_location_id
            ,p_work_type_id                => p_work_type_id
            ,p_revenue_currency_code       => p_revenue_currency_code
            ,p_revenue_bill_rate           => p_revenue_bill_rate
            ,p_markup_percent              => p_markup_percent
            ,p_expense_owner               => p_expense_owner
            ,p_expense_limit               => p_expense_limit
            ,p_expense_limit_currency_code => p_expense_limit_currency_code
            ,p_fcst_tp_amount_type         => p_fcst_tp_amount_type
            ,p_fcst_job_id                 => p_fcst_job_id
            ,p_fcst_job_group_id           => p_fcst_job_group_id
            ,p_expenditure_org_id          => p_expenditure_org_id
            ,p_expenditure_organization_id => p_expenditure_organization_id
            ,p_expenditure_type_class      => p_expenditure_type_class
            ,p_expenditure_type            => p_expenditure_type
            ,p_calendar_type               => p_calendar_type
            ,p_calendar_id                 => p_calendar_id
            ,p_resource_calendar_percent   => p_resource_calendar_percent
            ,p_project_name                => p_project_name
            ,p_project_number              => p_project_number
            ,p_project_subteam_name        => p_project_subteam_name
            ,p_project_status_name         => p_project_status_name
            ,p_staffing_priority_name      => p_staffing_priority_name
            ,p_project_role_name           => p_project_role_name
            ,p_location_city               => p_location_city
            ,p_location_region             => p_location_region
            ,p_location_country_name       => p_location_country_name
            ,p_location_country_code       => p_location_country_code
            ,p_calendar_name               => p_calendar_name
            ,p_work_type_name              => p_work_type_name
            ,p_fcst_job_name               => p_fcst_job_name
            ,p_fcst_job_group_name         => p_fcst_job_group_name
            ,p_expenditure_org_name        => p_expenditure_org_name
            ,p_exp_organization_name       => p_exp_organization_name
            ,p_staffing_owner_person_id    => l_staffing_owner_person_id
            ,p_staffing_owner_name         => l_staffing_owner_name
            ,p_attribute_category          => p_attribute_category
            ,p_attribute1                  => p_attribute1
            ,p_attribute2                  => p_attribute2
            ,p_attribute3                  => p_attribute3
            ,p_attribute4                  => p_attribute4
            ,p_attribute5                  => p_attribute5
            ,p_attribute6                  => p_attribute6
            ,p_attribute7                  => p_attribute7
            ,p_attribute8                  => p_attribute8
            ,p_attribute9                  => p_attribute9
            ,p_attribute10                 => p_attribute10
            ,p_attribute11                 => p_attribute11
            ,p_attribute12                 => p_attribute12
            ,p_attribute13                 => p_attribute13
            ,p_attribute14                 => p_attribute14
            ,p_attribute15                 => p_attribute15
            ,p_api_version                 => p_api_version
            ,p_init_msg_list               => FND_API.G_TRUE
            ,p_commit                      => p_commit
            ,p_validate_only               => p_validate_only
            ,p_max_msg_count               => p_max_msg_count
            ,x_new_assignment_id_tbl       => l_new_assignment_tabl /*Added the parameter for bug 3079906*/
            ,x_new_assignment_id           => l_new_assignment_id
            ,x_assignment_number           => l_assignment_number
            ,x_assignment_row_id           => l_assignment_row_id
            ,x_resource_id                 => l_resource_id
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data
        );

        l_new_assignment_id_tbl(i) := l_new_assignment_id;

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           l_new_assignment_id_tbl(i) := NULL;
           PA_MESSAGE_UTILS.save_messages(p_user_id            =>  PA_MASS_ASGMT_TRX.G_SUBMITTER_USER_ID,
                                          p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                                          p_source_type2       =>  PA_MASS_ASGMT_TRX.G_MASS_ASGMT,
                                          p_source_identifier1 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_TYPE,
                                          p_source_identifier2 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY,
                                          p_context1           =>  p_project_id,
                                          p_context2           =>  NULL,
                                          p_context3           =>  p_resource_id_tbl(i),
                                          p_commit             =>  FND_API.G_TRUE,
                                          x_return_status      =>  l_return_status);

        END IF;

   END LOOP;

   x_success_assignment_id_tbl := l_new_assignment_id_tbl;

EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Mass_Create_Assignments'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;

END Mass_Create_Assignments;


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
 ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
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
 ,p_search_exp_start_org_id     IN   pa_project_assignments.search_exp_start_org_id%TYPE        := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_name   IN   hr_organization_units.name%TYPE                            := FND_API.G_MISS_CHAR
 ,p_search_min_candidate_score  IN   pa_project_assignments.search_min_candidate_score%TYPE     := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag    IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE   := FND_API.G_MISS_CHAR
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
)

IS

l_wf_mode  VARCHAR2(200);
  l_return_status       VARCHAR2(1);

BEGIN

--This API is only called to do value-id validations

pa_assignments_pub.Execute_Update_Assignment
( p_asgn_update_mode            => 'MASS_ONLINE'
 ,p_assignment_name             => p_assignment_name
 ,p_assignment_type             => p_assignment_type
 ,p_staffing_priority_code      => p_staffing_priority_code
 ,p_project_id                  => p_project_id
 ,p_project_subteam_id          => p_project_subteam_id
 ,p_description                 => p_description
 ,p_extension_possible          => p_extension_possible
 ,p_min_resource_job_level      => p_min_resource_job_level
 ,p_max_resource_job_level      => p_max_resource_job_level
 ,p_additional_information      => p_additional_information
 ,p_location_id                 => p_location_id
 ,p_work_type_id                => p_work_type_id
 ,p_expense_owner               => p_expense_owner
 ,p_expense_limit               => p_expense_limit
 ,p_expense_limit_currency_code => p_expense_limit_currency_code
 ,p_fcst_tp_amount_type         => p_fcst_tp_amount_type
 ,p_fcst_job_id                 => p_fcst_job_id
 ,p_fcst_job_group_id           => p_fcst_job_group_id
 ,p_expenditure_org_id          => p_expenditure_org_id
 ,p_expenditure_organization_id => p_expenditure_organization_id
 ,p_expenditure_type_class      => p_expenditure_type_class
 ,p_expenditure_type            => p_expenditure_type
 ,p_project_subteam_name        => p_project_subteam_name
 ,p_staffing_priority_name      => p_staffing_priority_name
 ,p_location_city               => p_location_city
 ,p_location_region             => p_location_region
 ,p_location_country_name       => p_location_country_name
 ,p_location_country_code       => p_location_country_code
 ,p_work_type_name              => p_work_type_name
 ,p_fcst_job_name               => p_fcst_job_name
 ,p_fcst_job_group_name         => p_fcst_job_group_name
 ,p_expenditure_org_name        => p_expenditure_org_name
 ,p_exp_organization_name       => p_exp_organization_name
 ,p_comp_match_weighting        => p_avail_match_weighting
 ,p_avail_match_weighting       => p_avail_match_weighting
 ,p_job_level_match_weighting   => p_job_level_match_weighting
 ,p_search_min_availability     => p_search_min_availability
 ,p_search_country_code         => p_search_country_code
 ,p_search_country_name         => p_search_country_name
 ,p_search_exp_org_struct_ver_id => p_search_exp_org_struct_ver_id
 ,p_search_exp_org_hier_name    => p_search_exp_org_hier_name
 ,p_search_exp_start_org_id     => p_search_exp_start_org_id
 ,p_search_exp_start_org_name   => p_search_exp_start_org_name
 ,p_search_min_candidate_score  => p_search_min_candidate_score
 ,p_enable_auto_cand_nom_flag   => p_enable_auto_cand_nom_flag
 ,p_staffing_owner_person_id    => p_staffing_owner_person_id
 ,p_staffing_owner_name         => p_staffing_owner_name
 ,p_attribute_category          => p_attribute_category
 ,p_attribute1                  => p_attribute1
 ,p_attribute2                  => p_attribute2
 ,p_attribute3                  => p_attribute3
 ,p_attribute4                  => p_attribute4
 ,p_attribute5                  => p_attribute5
 ,p_attribute6                  => p_attribute6
 ,p_attribute7                  => p_attribute7
 ,p_attribute8                  => p_attribute8
 ,p_attribute9                  => p_attribute9
 ,p_attribute10                 => p_attribute10
 ,p_attribute11                 => p_attribute11
 ,p_attribute12                 => p_attribute12
 ,p_attribute13                 => p_attribute13
 ,p_attribute14                 => p_attribute14
 ,p_attribute15                 => p_attribute15
 ,p_api_version                 => p_api_version
 ,p_init_msg_list               => p_init_msg_list
 ,p_commit                      => p_commit
 ,p_validate_only               => p_validate_only
 ,p_max_msg_count               => p_max_msg_count
 ,x_return_status               => x_return_status
 ,x_msg_count                   => x_msg_count
 ,x_msg_data                    => x_msg_data
);

  --if p_validate_only=false and there are no errors then start the workflow process.
  IF p_validate_only = FND_API.G_FALSE AND FND_MSG_PUB.Count_Msg =0 THEN

    IF p_asgn_update_mode = 'Forecast' THEN
      l_wf_mode := PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS;
    ELSE
      -- update BasicInfo or Candidate
      l_wf_mode := PA_MASS_ASGMT_TRX.G_MASS_UPDATE_ASGMT_BASIC_INFO;
    END IF;

     --start the mass WF
     PA_MASS_ASGMT_TRX.Start_Mass_Asgmt_Trx_Wf(
        p_mode                        => l_wf_mode
       ,p_action                      => PA_MASS_ASGMT_TRX.G_SAVE
       ,p_assignment_id_tbl           => p_assignment_id_tbl
       ,p_assignment_name             => p_assignment_name
       ,p_assignment_type             => p_assignment_type
       ,p_staffing_priority_code      => p_staffing_priority_code
       ,p_project_id                  => p_project_id
       ,p_project_subteam_id          => p_project_subteam_id
       ,p_description                 => p_description
       ,p_append_description_flag     => p_append_description_flag
       ,p_extension_possible          => p_extension_possible
       ,p_min_resource_job_level      => p_min_resource_job_level
       ,p_max_resource_job_level      => p_max_resource_job_level
       ,p_additional_information      => p_additional_information
       ,p_append_information_flag     => p_append_information_flag
       ,p_location_id                 => p_location_id
       ,p_work_type_id                => p_work_type_id
       ,p_expense_owner               => p_expense_owner
       ,p_expense_limit               => p_expense_limit
       ,p_expense_limit_currency_code => p_expense_limit_currency_code
       ,p_fcst_tp_amount_type         => p_fcst_tp_amount_type
       ,p_fcst_job_id                 => p_fcst_job_id
       ,p_fcst_job_group_id           => p_fcst_job_group_id
       ,p_expenditure_org_id          => p_expenditure_org_id
       ,p_expenditure_organization_id => p_expenditure_organization_id
       ,p_expenditure_type_class      => p_expenditure_type_class
       ,p_expenditure_type            => p_expenditure_type
       ,p_project_subteam_name        => p_project_subteam_name
       ,p_staffing_priority_name      => p_staffing_priority_name
       ,p_location_city               => p_location_city
       ,p_location_region             => p_location_region
       ,p_location_country_name       => p_location_country_name
       ,p_location_country_code       => p_location_country_code
       ,p_work_type_name              => p_work_type_name
       ,p_fcst_job_name               => p_fcst_job_name
       ,p_fcst_job_group_name         => p_fcst_job_group_name
       ,p_expenditure_org_name        => p_expenditure_org_name
       ,p_exp_organization_name       => p_exp_organization_name
       ,p_comp_match_weighting        => p_comp_match_weighting
       ,p_avail_match_weighting       => p_avail_match_weighting
       ,p_job_level_match_weighting   => p_job_level_match_weighting
       ,p_search_min_availability     => p_search_min_availability
       ,p_search_country_code         => p_search_country_code
       ,p_search_exp_org_struct_ver_id => p_search_exp_org_struct_ver_id
       ,p_search_exp_start_org_id     => p_search_exp_start_org_id
       ,p_search_min_candidate_score  => p_search_min_candidate_score
       ,p_enable_auto_cand_nom_flag   => p_enable_auto_cand_nom_flag
       ,p_search_country_name         => p_search_country_name
       ,p_search_exp_org_hier_name    => p_search_exp_org_hier_name
       ,p_search_exp_start_org_name   => p_search_exp_start_org_name
       ,p_staffing_owner_person_id    => p_staffing_owner_person_id
       ,p_staffing_owner_name         => p_staffing_owner_name
       ,x_return_status               => x_return_status
    );

  END IF;

  EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Mass_Exec_Update_Assignments'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;

END Mass_Exec_Update_Assignments;



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
 ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
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
 ,p_search_exp_org_hier_name     IN  per_organization_structures.name%TYPE                     := FND_API.G_MISS_CHAR
 ,p_search_exp_start_org_id      IN   pa_project_assignments.search_exp_start_org_id%TYPE       := FND_API.G_MISS_NUM
 ,p_search_exp_start_org_name    IN   hr_organization_units.name%TYPE                           := FND_API.G_MISS_CHAR
 ,p_search_min_candidate_score   IN   pa_project_assignments.search_min_candidate_score%TYPE    := FND_API.G_MISS_NUM
 ,p_enable_auto_cand_nom_flag    IN  pa_project_assignments.enable_auto_cand_nom_flag%TYPE := FND_API.G_MISS_CHAR
 ,p_staffing_owner_person_id     IN  pa_project_assignments.staffing_owner_person_id%TYPE      := FND_API.G_MISS_NUM       --FP.L Development
 ,p_staffing_owner_name          IN  per_people_f.full_name%TYPE                               := FND_API.G_MISS_CHAR       --FP.L Development
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
)
IS


l_assignment_id_tbl system.pa_num_tbl_type;

l_subteam_party_id     NUMBER;
l_description          pa_project_assignments.description%TYPE := NULL;
l_additional_info      pa_project_assignments.additional_information%TYPE := NULL;
l_assignment_type      pa_project_assignments.assignment_type%TYPE;
l_start_date           pa_project_assignments.start_date%TYPE;
l_end_date             pa_project_assignments.end_date%TYPE;
l_msg_index_out        NUMBER;
l_return_status        VARCHAR2(1);

l_min_resource_job_level       pa_project_assignments.min_resource_job_level%TYPE;
l_max_resource_job_level       pa_project_assignments.max_resource_job_level%TYPE;
l_fcst_job_id                  pa_project_assignments.fcst_job_id%TYPE;
l_fcst_job_group_id            pa_project_assignments.fcst_job_group_id%TYPE;
l_expenditure_org_id           pa_project_assignments.expenditure_org_id%TYPE;
l_expenditure_organization_id  pa_project_assignments.expenditure_organization_id%TYPE;
l_fcst_job_name                per_jobs.name%TYPE;
l_fcst_job_group_name          per_job_groups.displayed_name%TYPE;
l_expenditure_org_name         per_organization_units.name%TYPE;
l_exp_organization_name        per_organization_units.name%TYPE;
l_fcst_tp_amount_type          pa_project_assignments.fcst_tp_amount_type%TYPE;
l_req_max_resource_job_level   pa_project_assignments.max_resource_job_level%TYPE;
l_req_min_resource_job_level   pa_project_assignments.min_resource_job_level%TYPE;
l_resource_id                  pa_resources.resource_id%TYPE;

CURSOR get_asgn_info(l_asmt_id  NUMBER) IS
SELECT ppsp.project_subteam_party_id, ppa.assignment_type, ppa.description, ppa.additional_information, ppa.start_date, ppa.end_date, ppa.min_resource_job_level, ppa.max_resource_job_level, ppa.resource_id
FROM   pa_project_assignments ppa,
       pa_project_subteam_parties ppsp
WHERE ppa.assignment_id = l_asmt_id
AND   ppsp.object_type (+)= 'PA_PROJECT_ASSIGNMENTS'
AND   ppa.assignment_id = ppsp.object_id(+)
AND   ppsp.primary_subteam_flag(+) = 'Y';

BEGIN

  --dbms_output.put_line('mass_update_assignments');

  --should we clear the fnd_msg_pub stack right here?
  --if we will pass p_init_msg_list = false to the API
  --so that we don't clear the stack between assignments then we
  --should clear the stack here before we start looping.
  --open issue - waiting to find out how errors will be handled
  --in mass assign.
  --FND_MSG_PUB.initialize;

  --assign local plsql table
  --update this local table for out x_success_assignment_id_tbl
  l_assignment_id_tbl := p_assignment_id_tbl;

  --loop through the assignment ids and call execute_update_assignment
  --to actually update the assignment.  This is the WF (offline) process
  FOR i IN p_assignment_id_tbl.FIRST .. p_assignment_id_tbl.LAST LOOP

    OPEN get_asgn_info(p_assignment_id_tbl(i));
    FETCH get_asgn_info INTO l_subteam_party_id, l_assignment_type,l_description, l_additional_info, l_start_date, l_end_date, l_req_min_resource_job_level, l_req_max_resource_job_level, l_resource_id;
    CLOSE get_asgn_info;

    --dbms_output.put_line('assignment id = '|| p_assignment_id_tbl(i));
    --dbms_output.put_line('assignment_type =  '|| l_assignment_type);

    --Check to see if original description need to be appended.
    IF p_description IS NOT NULL AND p_description <> FND_API.G_MISS_CHAR THEN

      IF p_append_description_flag = 'Y' THEN
        -- Only get the first 2000 characters
        l_description := SUBSTR(l_description || p_description, 1, 2000);
      ELSE
        l_description := p_description;
      END IF;
    END IF;

      --Check to see if original additional information need to be appended.
    IF p_additional_information IS NOT NULL AND p_additional_information <> FND_API.G_MISS_CHAR THEN

      IF p_append_information_flag = 'Y' THEN
        -- Only get the first 2000 characters
        l_additional_info := SUBSTR(l_additional_info || p_additional_information, 1, 2000);
      ELSE
        l_additional_info := p_additional_information;
      END IF;
    END IF;

    --If this is not a requirement, pass FND_API.G_MISS_CHAR/NUM
    --to the following parameters:
    IF l_assignment_type <> 'OPEN_ASSIGNMENT' THEN
      l_min_resource_job_level := FND_API.G_MISS_NUM;
      l_max_resource_job_level := FND_API.G_MISS_NUM;
      l_fcst_job_id := FND_API.G_MISS_NUM;
      l_fcst_job_group_id := FND_API.G_MISS_NUM;
      l_expenditure_org_id := FND_API.G_MISS_NUM;
      l_expenditure_organization_id := FND_API.G_MISS_NUM;
      l_fcst_job_name := FND_API.G_MISS_CHAR;
      l_fcst_job_group_name := FND_API.G_MISS_CHAR;
      l_expenditure_org_name := FND_API.G_MISS_CHAR;
      l_exp_organization_name := FND_API.G_MISS_CHAR;
    ELSE
      l_min_resource_job_level := p_min_resource_job_level;
      l_max_resource_job_level := p_max_resource_job_level;
      l_fcst_job_id := p_fcst_job_id;
      l_fcst_job_group_id := p_fcst_job_group_id;
      l_expenditure_org_id := p_expenditure_org_id;
      l_expenditure_organization_id := p_expenditure_organization_id;
      l_fcst_job_name := p_fcst_job_name;
      l_fcst_job_group_name := p_fcst_job_group_name;
      l_expenditure_org_name := p_expenditure_org_name;
      l_exp_organization_name := p_exp_organization_name;
    END IF;

    --If this is admin assigment, pass FND_API.G_MISS_CHAR
    --to the following parameter:
    IF l_assignment_type = 'STAFFED_ADMIN_ASSIGNMENT' THEN
      l_fcst_tp_amount_type := FND_API.G_MISS_CHAR;
    ELSE
      l_fcst_tp_amount_type := p_fcst_tp_amount_type;
    END IF;

    --dbms_output.put_line('before calling Execute_Update_Assignment ');

    --1. If user chooses not to update a field on the Mass Update page
    -- client side will pass in NULL to the corresponding parameters;
    --2. If user updates Forecasting Info
    -- client side will pass in NULL to the parameters corresponding to
    -- Basic Info section and vice versa
    --Therefore, for Mass Update, if any parameters are passed in as NULL
    -- set them to FND_API.G_MISS_NUM/CHAR
    -- 3. Pass in the min and max resource job level of the requirement
    --  if NULL was passed in from the client side.  This is to ensure
    --  validation on min and max job level is done even if user
    --  specifies only min job level or only max job level for mass update

    --call execute_update_assignment
    pa_assignments_pub.Execute_Update_Assignment
    ( p_asgn_update_mode            => p_update_mode
     ,p_assignment_id               => p_assignment_id_tbl(i)
     ,p_record_version_number       => NULL
     ,p_assignment_type             => l_assignment_type
     ,p_assignment_name             => nvl(p_assignment_name, FND_API.G_MISS_CHAR)
     ,p_staffing_priority_code      => nvl(p_staffing_priority_code, FND_API.G_MISS_CHAR)
     ,p_project_id                  => p_project_id
     ,p_project_subteam_id          => nvl(p_project_subteam_id, FND_API.G_MISS_NUM)
     ,p_project_subteam_party_id    => l_subteam_party_id
     ,p_description                 => nvl(l_description, FND_API.G_MISS_CHAR)
     ,p_extension_possible          => nvl(p_extension_possible, FND_API.G_MISS_CHAR)
     ,p_min_resource_job_level      => nvl(l_min_resource_job_level, l_req_min_resource_job_level)
     ,p_max_resource_job_level      => nvl(l_max_resource_job_level, l_req_max_resource_job_level)
     ,p_additional_information      => nvl(l_additional_info, FND_API.G_MISS_CHAR)
     ,p_location_id                 => nvl(p_location_id, FND_API.G_MISS_NUM)
     ,p_work_type_id                => nvl(p_work_type_id, FND_API.G_MISS_NUM)
     ,p_expense_owner               => nvl(p_expense_owner, FND_API.G_MISS_CHAR)
     ,p_expense_limit               => nvl(p_expense_limit, FND_API.G_MISS_NUM)
     ,p_expense_limit_currency_code => nvl(p_expense_limit_currency_code, FND_API.G_MISS_CHAR)
     ,p_fcst_tp_amount_type         => nvl(p_fcst_tp_amount_type, FND_API.G_MISS_CHAR)
     ,p_fcst_job_id                 => nvl(p_fcst_job_id, FND_API.G_MISS_NUM)
     ,p_fcst_job_group_id           => nvl(p_fcst_job_group_id, FND_API.G_MISS_NUM)
     ,p_expenditure_org_id          => nvl(p_expenditure_org_id, FND_API.G_MISS_NUM)
     ,p_expenditure_organization_id => nvl(p_expenditure_organization_id, FND_API.G_MISS_NUM)
     ,p_expenditure_type_class      => nvl(p_expenditure_type_class, FND_API.G_MISS_CHAR)
     ,p_expenditure_type            => nvl(p_expenditure_type, FND_API.G_MISS_CHAR)
     ,p_project_subteam_name        => nvl(p_project_subteam_name, FND_API.G_MISS_CHAR)
     ,p_staffing_priority_name      => nvl(p_staffing_priority_name, FND_API.G_MISS_CHAR)
     ,p_location_city               => nvl(p_location_city, FND_API.G_MISS_CHAR)
     ,p_location_region             => nvl(p_location_region, FND_API.G_MISS_CHAR)
     ,p_location_country_name       => nvl(p_location_country_name, FND_API.G_MISS_CHAR)
     ,p_location_country_code       => nvl(p_location_country_code, FND_API.G_MISS_CHAR)
     ,p_work_type_name              => nvl(p_work_type_name, FND_API.G_MISS_CHAR)
     ,p_fcst_job_name               => nvl(p_fcst_job_name, FND_API.G_MISS_CHAR)
     ,p_fcst_job_group_name         => nvl(p_fcst_job_group_name, FND_API.G_MISS_CHAR)
     ,p_expenditure_org_name        => nvl(p_expenditure_org_name, FND_API.G_MISS_CHAR)
     ,p_exp_organization_name       => nvl(p_exp_organization_name, FND_API.G_MISS_CHAR)
     ,p_resource_id                 => nvl(l_resource_id, FND_API.G_MISS_NUM)
     ,p_comp_match_weighting        => nvl(p_comp_match_weighting, FND_API.G_MISS_NUM)
     ,p_avail_match_weighting       => nvl(p_avail_match_weighting, FND_API.G_MISS_NUM)
     ,p_job_level_match_weighting   => nvl(p_job_level_match_weighting, FND_API.G_MISS_NUM)
     ,p_search_min_availability     => nvl(p_search_min_availability, FND_API.G_MISS_NUM)
     ,p_search_country_code         => nvl(p_search_country_code, FND_API.G_MISS_CHAR)
     ,p_search_country_name         => nvl(p_search_country_name, FND_API.G_MISS_CHAR)
     ,p_search_exp_org_struct_ver_id => nvl(p_search_exp_org_struct_ver_id, FND_API.G_MISS_NUM)
     ,p_search_exp_org_hier_name    => nvl(p_search_exp_org_hier_name, FND_API.G_MISS_CHAR)

     ,p_search_exp_start_org_id     => nvl(p_search_exp_start_org_id, FND_API.G_MISS_NUM)
     ,p_search_exp_start_org_name   => nvl(p_search_exp_start_org_name, FND_API.G_MISS_CHAR)
     ,p_search_min_candidate_score  => nvl(p_search_min_candidate_score, FND_API.G_MISS_NUM)
     ,p_enable_auto_cand_nom_flag    => nvl(p_enable_auto_cand_nom_flag, FND_API.G_MISS_CHAR)
     -- FP.L Development
     ,p_staffing_owner_person_id     => nvl(p_staffing_owner_person_id, FND_API.G_MISS_NUM)
     ,p_staffing_owner_name          => nvl(p_staffing_owner_name, FND_API.G_MISS_CHAR)
      ,p_attribute_category          => nvl(p_attribute_category, FND_API.G_MISS_CHAR)
      ,p_attribute1                  => nvl(p_attribute1, FND_API.G_MISS_CHAR)
      ,p_attribute2                  => nvl(p_attribute2, FND_API.G_MISS_CHAR)
      ,p_attribute3                  => nvl(p_attribute3, FND_API.G_MISS_CHAR)
      ,p_attribute4                  => nvl(p_attribute4, FND_API.G_MISS_CHAR)
      ,p_attribute5                  => nvl(p_attribute5, FND_API.G_MISS_CHAR)
      ,p_attribute6                  => nvl(p_attribute6, FND_API.G_MISS_CHAR)
      ,p_attribute7                  => nvl(p_attribute7, FND_API.G_MISS_CHAR)
      ,p_attribute8                  => nvl(p_attribute8, FND_API.G_MISS_CHAR)
      ,p_attribute9                  => nvl(p_attribute9, FND_API.G_MISS_CHAR)
      ,p_attribute10                 => nvl(p_attribute10, FND_API.G_MISS_CHAR)
      ,p_attribute11                 => nvl(p_attribute11, FND_API.G_MISS_CHAR)
      ,p_attribute12                 => nvl(p_attribute12, FND_API.G_MISS_CHAR)
      ,p_attribute13                 => nvl(p_attribute13, FND_API.G_MISS_CHAR)
      ,p_attribute14                 => nvl(p_attribute14, FND_API.G_MISS_CHAR)
      ,p_attribute15                 => nvl(p_attribute15, FND_API.G_MISS_CHAR)
      ,p_api_version                 => p_api_version
      ,p_init_msg_list               => p_init_msg_list
      ,p_commit                      => p_commit
      ,p_validate_only               => p_validate_only
      ,p_max_msg_count               => p_max_msg_count
      ,x_return_status               => x_return_status
      ,x_msg_count                   => x_msg_count
      ,x_msg_data                    => x_msg_data
    );

    --dbms_output.put_line('after calling execute_update_assignment');

    --if successful and update mode is 'update forecast'
    --then call forecast API to generate forecast items
    IF x_return_status = FND_API.G_RET_STS_SUCCESS AND
       p_update_mode = PA_MASS_ASGMT_TRX.G_MASS_UPDATE_FORECAST_ITEMS THEN

      --dbms_output.put_line('calling PA_FORECASTITEM_PVT.Create_Forecast_Item');

      PA_FORECASTITEM_PVT.Create_Forecast_Item(
            p_assignment_id         => l_assignment_id_tbl(i)
           ,p_start_date            => l_start_date
           ,p_end_date              => l_end_date
           ,p_process_mode          => 'GENERATE'
           ,x_return_status         => x_return_status
           ,x_msg_count             => x_msg_count
           ,x_msg_data              => x_msg_data
      );

      --dbms_output.put_line('after calling PA_FORECASTITEM_PVT.Create_Forecast_Item');

    END IF;

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      l_assignment_id_tbl(i) := NULL;

        PA_MESSAGE_UTILS.save_messages(p_user_id            =>  PA_MASS_ASGMT_TRX.G_SUBMITTER_USER_ID,
                                       p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                                       p_source_type2       =>  p_update_mode,
                                       p_source_identifier1 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_TYPE,
                                       p_source_identifier2 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY,
                                       p_context1           =>  p_project_id,
                                       p_context2           =>  p_assignment_id_tbl(i),
                                       p_context3           =>  NULL,
                                       p_commit             =>  FND_API.G_TRUE,
                                       x_return_status      =>  l_return_status);
    END IF;

  END LOOP;

  x_success_assignment_id_tbl := l_assignment_id_tbl;

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

   EXCEPTION
     WHEN OTHERS THEN
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Mass_Update_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;



END Mass_Update_Assignments;


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
 ,p_max_resource_job_level      IN    pa_project_assignments.max_resource_job_level%TYPE      := FND_API.G_MISS_NUM
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
)

IS
l_assignment_rec      PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
l_return_status       VARCHAR2(1);
l_exists              VARCHAR2(1) := 'N';
l_return_code         VARCHAR2(1);

BEGIN

  --dbms_output.put_line('Beginning Execute_Update_Assignment');
  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Execute_Update_Assignment');


  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Execute_Update_Requirement.begin'
                       ,x_msg         => 'Beginning of Execute_Update_Assignment'
                       ,x_log_level   => 5);
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  BEGIN
    SELECT 'Y'
    INTO   l_exists
    FROM   pa_project_assignments asgn
          ,pa_project_subteam_parties psp
          ,pa_locations loc
    WHERE  asgn.project_id               = p_project_id
    AND    asgn.assignment_id            = p_assignment_id
    AND    asgn.assignment_name          = p_assignment_name
    AND    asgn.min_resource_job_level   = p_min_resource_job_level
    AND    asgn.max_resource_job_level   = p_max_resource_job_level
    AND    asgn.staffing_priority_code   = p_staffing_priority_code
    AND    asgn.staffing_owner_person_id = p_staffing_owner_person_id
    AND    asgn.description              = p_description
    AND    asgn.additional_information   = p_additional_information
    AND    psp.project_subteam_id        = p_project_subteam_id
    AND    loc.country_code              = p_location_country_code
    AND    loc.region                    = p_location_region
    AND    loc.city                      = p_location_city
    AND    asgn.assignment_id            = psp.object_id (+)
    AND    psp.object_type(+)            = 'PA_PROJECT_ASSIGNMENTS'
    AND    psp.primary_subteam_flag(+)   = 'Y'
    AND    asgn.location_id              = loc.location_id (+);

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                       x_ret_code       => l_return_code,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_privilege      => 'PA_ASN_BASIC_INFO_ED',
                       p_object_name    => 'PA_PROJECTS',
                       p_object_key     => p_project_id);

       IF l_return_code <> FND_API.G_TRUE THEN

          PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                          x_ret_code       => l_return_code,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_privilege      => 'PA_ASN_BASIC_INFO_ED',
                          p_object_name    => 'PA_PROJECT_ASSIGNMENTS',
                          p_object_key     => p_assignment_id);

          IF l_return_code <> FND_API.G_TRUE THEN
             pa_utils.add_message (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_UPD_ASGN_BASIC_INFO');
          END IF;
       END IF;
  END;

  BEGIN
    SELECT 'Y'
    INTO   l_exists
    FROM   pa_project_assignments
    WHERE  project_id                    = p_project_id
    AND    assignment_id                 = p_assignment_id
    AND    competence_match_weighting    = p_comp_match_weighting
    AND    availability_match_weighting  = p_avail_match_weighting
    AND    job_level_match_weighting     = p_job_level_match_weighting
    AND    enable_auto_cand_nom_flag     = p_enable_auto_cand_nom_flag
    AND    search_min_availability       = p_search_min_availability
    AND    search_exp_org_struct_ver_id  = p_search_exp_org_struct_ver_id
    AND    search_exp_start_org_id       = p_search_exp_start_org_id
    AND    search_country_code           = p_search_country_code
    AND    search_min_candidate_score    = p_search_min_candidate_score;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                       x_ret_code       => l_return_code,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_privilege      => 'PA_CREATE_CANDIDATES',
                       p_object_name    => 'PA_PROJECTS',
                       p_object_key     => p_project_id);

       IF l_return_code <> FND_API.G_TRUE THEN
          PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                          x_ret_code       => l_return_code,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_privilege      => 'PA_CREATE_CANDIDATES',
                          p_object_name    => 'PA_PROJECT_ASSIGNMENTS',
                          p_object_key     => p_assignment_id);

          IF l_return_code <> FND_API.G_TRUE THEN
             pa_utils.add_message (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_UPD_ASGN_CANDIDATE');
          END IF;
       END IF;
  END;

  BEGIN
    SELECT 'Y'
    INTO   l_exists
    FROM   pa_project_assignments
    WHERE  project_id                    = p_project_id
    AND    assignment_id                 = p_assignment_id
    AND    extension_possible            = p_extension_possible
    AND    expense_owner                 = p_expense_owner
    AND    expense_limit                 = p_expense_limit
    AND    expenditure_org_id            = p_expenditure_org_id
    AND    expenditure_organization_id   = p_expenditure_organization_id
    AND    expenditure_type_class        = p_expenditure_type_class
    AND    fcst_job_group_id             = p_fcst_job_group_id
    AND    fcst_job_id                   = p_fcst_job_id
    AND    work_type_id                  = p_fcst_job_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
       PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                       x_ret_code       => l_return_code,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_privilege      => 'PA_ASN_FCST_INFO_ED',
                       p_object_name    => 'PA_PROJECTS',
                       p_object_key     => p_project_id);

       IF l_return_code <> FND_API.G_TRUE THEN
          PA_SECURITY_PVT.CHECK_USER_PRIVILEGE(
                          x_ret_code       => l_return_code,
                          x_return_status  => x_return_status,
                          x_msg_count      => x_msg_count,
                          x_msg_data       => x_msg_data,
                          p_privilege      => 'PA_CREATE_CANDIDATES',
                          p_object_name    => 'PA_PROJECT_ASSIGNMENTS',
                          p_object_key     => p_assignment_id);

          IF l_return_code <> FND_API.G_TRUE THEN
             pa_utils.add_message (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_UPD_ASGN_FIN_INFO');
          END IF;
       END IF;
  END;

  IF FND_MSG_PUB.Count_Msg > 0 THEN
     RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- Assign the scalar parameters to the assignment record fields
  l_assignment_rec.assignment_row_id           := p_assignment_row_id;
  l_assignment_rec.assignment_id               := p_assignment_id;
  l_assignment_rec.record_version_number       := p_record_version_number;
  l_assignment_rec.assignment_name             := p_assignment_name;
  l_assignment_rec.assignment_type             := p_assignment_type;
  l_assignment_rec.multiple_status_flag        := p_multiple_status_flag;
  l_assignment_rec.staffing_priority_code      := p_staffing_priority_code;
  l_assignment_rec.project_id                  := p_project_id;
  l_assignment_rec.assignment_template_id      := p_assignment_template_id;
  l_assignment_rec.project_role_id             := p_project_role_id;
  l_assignment_rec.project_party_id            := p_project_party_id;
  l_assignment_rec.description                 := p_description;
  l_assignment_rec.assignment_effort           := p_assignment_effort;
  l_assignment_rec.extension_possible          := p_extension_possible;
  l_assignment_rec.source_assignment_id        := p_source_assignment_id;

  l_assignment_rec.min_resource_job_level      := p_min_resource_job_level;
  l_assignment_rec.max_resource_job_level      := p_max_resource_job_level;
  l_assignment_rec.assignment_number           := p_assignment_number;
  l_assignment_rec.additional_information      := p_additional_information;
  l_assignment_rec.work_type_id                := p_work_type_id;
  l_assignment_rec.location_id                 := p_location_id;
  l_assignment_rec.revenue_currency_code       := p_revenue_currency_code;
  l_assignment_rec.revenue_bill_rate           := p_revenue_bill_rate;
  l_assignment_rec.markup_percent              := p_markup_percent;
  l_assignment_rec.expense_owner               := p_expense_owner;
  l_assignment_rec.expense_limit               := p_expense_limit;
  l_assignment_rec.expense_limit_currency_code := p_expense_limit_currency_code;

  l_assignment_rec.fcst_tp_amount_type         := p_fcst_tp_amount_type;
  l_assignment_rec.fcst_job_id                 := p_fcst_job_id;
  l_assignment_rec.fcst_job_group_id           := p_fcst_job_group_id;
  l_assignment_rec.expenditure_org_id          := p_expenditure_org_id;
  l_assignment_rec.expenditure_organization_id := p_expenditure_organization_id;

  l_assignment_rec.expenditure_type_class      := p_expenditure_type_class;
  l_assignment_rec.expenditure_type            := p_expenditure_type;
  l_assignment_rec.comp_match_weighting        := p_comp_match_weighting;
  l_assignment_rec.avail_match_weighting       := p_avail_match_weighting;
  l_assignment_rec.job_level_match_weighting   := p_job_level_match_weighting;
  l_assignment_rec.search_min_availability     := p_search_min_availability;
  l_assignment_rec.search_country_code         := p_search_country_code;
  l_assignment_rec.search_exp_org_struct_ver_id := p_search_exp_org_struct_ver_id;

  l_assignment_rec.search_exp_start_org_id     := p_search_exp_start_org_id;
  l_assignment_rec.search_min_candidate_score  := p_search_min_candidate_score;
  l_assignment_rec.enable_auto_cand_nom_flag   := p_enable_auto_cand_nom_flag;
  l_assignment_rec.bill_rate_override          := p_bill_rate_override;
  l_assignment_rec.bill_rate_curr_override     := p_bill_rate_curr_override;
  l_assignment_rec.markup_percent_override     := p_markup_percent_override;
  l_assignment_rec.discount_percentage         := p_discount_percentage;

  l_assignment_rec.rate_disc_reason_code       := p_rate_disc_reason_code;
  l_assignment_rec.tp_rate_override            := p_tp_rate_override;
  l_assignment_rec.tp_currency_override        := p_tp_currency_override;
  l_assignment_rec.tp_calc_base_code_override  := p_tp_calc_base_code_override;
  l_assignment_rec.tp_percent_applied_override := p_tp_percent_applied_override;
  l_assignment_rec.staffing_owner_person_id    := p_staffing_owner_person_id;

  l_assignment_rec.attribute_category          := p_attribute_category;
  l_assignment_rec.attribute1                  := p_attribute1;
  l_assignment_rec.attribute2                  := p_attribute2;
  l_assignment_rec.attribute3                  := p_attribute3;
  l_assignment_rec.attribute4                  := p_attribute4;
  l_assignment_rec.attribute5                  := p_attribute5;
  l_assignment_rec.attribute6                  := p_attribute6;
  l_assignment_rec.attribute7                  := p_attribute7;
  l_assignment_rec.attribute8                  := p_attribute8;
  l_assignment_rec.attribute9                  := p_attribute9;
  l_assignment_rec.attribute10                 := p_attribute10;
  l_assignment_rec.attribute11                 := p_attribute11;
  l_assignment_rec.attribute12                 := p_attribute12;
  l_assignment_rec.attribute13                 := p_attribute13;
  l_assignment_rec.attribute14                 := p_attribute14;
  l_assignment_rec.attribute15                 := p_attribute15;

  --dbms_output.put_line('Calling Update_Assignment');
  PA_ASSIGNMENTS_PUB.Update_Assignment
  ( p_assignment_rec               => l_assignment_rec
   ,p_asgn_update_mode             => p_asgn_update_mode
   ,p_project_number               => p_project_number
   ,p_resource_name                => p_resource_name
   ,p_resource_source_id           => p_resource_source_id
   ,p_resource_id                  => p_resource_id
   ,p_project_status_name          => p_project_status_name
   ,p_project_subteam_id           => p_project_subteam_id
   ,p_project_subteam_party_id     => p_project_subteam_party_id
   ,p_project_subteam_name         => p_project_subteam_name
   ,p_calendar_name                => p_calendar_name
   ,p_staffing_priority_name       => p_staffing_priority_name
   ,p_project_role_name            => p_project_role_name
   ,p_location_city                => p_location_city
   ,p_location_region              => p_location_region
   ,p_location_country_name        => p_location_country_name
   ,p_location_country_code        => p_location_country_code
   ,p_work_type_name               => p_work_type_name
   ,p_fcst_job_name                => p_fcst_job_name
   ,p_fcst_job_group_name          => p_fcst_job_group_name
   ,p_expenditure_org_name         => p_expenditure_org_name
   ,p_exp_organization_name        => p_exp_organization_name
   ,p_search_country_name          => p_search_country_name
   ,p_search_exp_org_hier_name     => p_search_exp_org_hier_name
   ,p_search_exp_start_org_name    => p_search_exp_start_org_name
   ,p_staffing_owner_name          => p_staffing_owner_name
   ,p_api_version                  => p_api_version
   ,p_commit                       => p_commit
   ,p_validate_only                => p_validate_only
   ,p_max_msg_count                => p_max_msg_count
   ,x_return_status                => x_return_status
   ,x_msg_count                    => x_msg_count
   ,x_msg_data                     => x_msg_data
   );
END Execute_Update_Requirement;

PROCEDURE DELETE_PJR_TXNS
 (p_project_id                  IN    pa_project_assignments.project_id%TYPE          := FND_API.G_MISS_NUM
 ,p_calling_module              IN    VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_api_version                 IN    NUMBER                                          := 1.0
 ,p_init_msg_list               IN    VARCHAR2                                        := FND_API.G_FALSE
 ,p_commit                      IN    VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN    VARCHAR2                                        := FND_API.G_TRUE
 ,p_max_msg_count               IN    NUMBER                                          := FND_API.G_MISS_NUM
 ,x_return_status               OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                   OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                    OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )

IS

 CURSOR asgn_details IS
 SELECT ROWID  row_id
       ,assignment_id
       ,assignment_type
       ,record_version_number
       ,assignment_number
       ,project_party_id
   FROM pa_project_assignments a
  WHERE a.project_id = p_project_id;

 l_return_status       VARCHAR2(1);
 l_msg_index_out       NUMBER;

BEGIN

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_ASSIGNMENTS_PUB.Delete_PJR_Txns');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Delete_PJR_Txns.begin'
                       ,x_msg         => 'Beginning of Delete_PJR_Txns'
                       ,x_log_level   => 5);
  END IF;

  -- Initialize the error flag
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_FALSE;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --  Issue API savepoint if the transaction is to be committed
  IF p_commit  = FND_API.G_TRUE THEN
    SAVEPOINT   ASG_PUB_DELETE_PJR_TXNS;
  END IF;

  --Clear the global PL/SQL message table
  IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

   FOR l_rec IN asgn_details
   LOOP

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENTS_PUB.Delete_PJR_Txns.pvt_delete_asgmt'
                       ,x_msg         => 'Calling PVT Delete_Assignment'
                       ,x_log_level   => 5);
  END IF;

       PA_ASSIGNMENTS_PVT.Delete_Assignment
       ( p_assignment_row_id     => l_rec.row_id
        ,p_assignment_id         => l_rec.assignment_id
        ,p_assignment_type       => l_rec.assignment_type
        ,p_record_version_number => l_rec.record_version_number
        ,p_assignment_number     => l_rec.assignment_number
        ,p_project_party_id      => l_rec.project_party_id
        ,p_calling_module        => p_calling_module
        ,p_commit                => p_commit
        ,p_validate_only         => p_validate_only
        ,x_return_status         => l_return_status
       );

     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

  END LOOP;

  --
  -- IF the number of messaages is 1 then fetch the message code from the stack and return its text
  --
  x_msg_count :=  FND_MSG_PUB.Count_Msg;
  IF x_msg_count = 1 THEN
    pa_interface_utils_pub.get_messages ( p_encoded       => FND_API.G_TRUE
                                         ,p_msg_index     => 1
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out
                                        );
  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  -- If any errors exist then set the x_return_status to 'E'

  IF x_msg_count > 0  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  -- Reset the error stack when returning to the calling program
  PA_DEBUG.Reset_Err_Stack;

  IF p_commit = FND_API.G_TRUE THEN
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        COMMIT;
     ELSE
        ROLLBACK TO ASG_PUB_DELETE_PJR_TXNS;
     END IF;
  END IF;

    -- Put any message text from message stack into the Message ARRAY
   --

   EXCEPTION
     WHEN OTHERS THEN
         IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO ASG_PUB_DELETE_PJR_TXNS;
         END IF;
         -- Set the exception Message and the stack
         FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_ASSIGNMENTS_PUB.Delete_PJR_Txns'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
         --
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
         RAISE;  -- This is optional depending on the needs
--
END DELETE_PJR_TXNS;

/* Added the procedure for bug 8557453 */

PROCEDURE VALIDATE_PROJECT_ROLE(
       p_assignment_id IN NUMBER,
       x_return_status OUT NOCOPY NUMBER) IS

     BEGIN
         x_return_status := 0;

         Select 1 INTO x_return_status from dual
         where exists (
         Select role.project_role_id from
         pa_project_role_types_b role,
         pa_project_assignments asm where
         asm.project_role_id = role.project_role_id and
         trunc(SYSDATE) Between trunc(role.start_date_active) and trunc(NVL(role.end_date_active,SYSDATE+1))
         and asm.assignment_id = p_assignment_id);

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            x_return_status := 0;
          WHEN OTHERS THEN
            RAISE;

   END VALIDATE_PROJECT_ROLE;
END pa_assignments_pub;

/
