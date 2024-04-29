--------------------------------------------------------
--  DDL for Package Body PA_OPEN_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_OPEN_ASSIGNMENT_PVT" AS
/*$Header: PAROPVTB.pls 120.3.12010000.2 2009/12/21 18:56:59 asahoo ship $*/
--
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
li_message_level NUMBER := 1;
PROCEDURE Create_Open_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_adv_action_set_id           IN    NUMBER                                           := FND_API.G_MISS_NUM
 ,p_start_adv_action_set_flag   IN    VARCHAR2                                         := FND_API.G_MISS_CHAR
 ,p_sum_tasks_flag				IN	   VARCHAR2										   := FND_API.G_FALSE  -- FP.M Development
 ,p_budget_version_id			IN	   pa_resource_assignments.budget_version_id%TYPE  := FND_API.G_MISS_NUM
 ,p_number_of_requirements      IN     NUMBER                                          := 1
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_new_assignment_id           OUT    NOCOPY pa_project_assignments.assignment_id%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_number           OUT    NOCOPY pa_project_assignments.assignment_number%TYPE --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

 l_assignment_rec               PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_assignment_id                pa_project_assignments.assignment_id%TYPE;
 l_def_assignment_name          pa_project_assignments.assignment_name%TYPE;
 l_def_min_resource_job_level   pa_project_assignments.min_resource_job_level%TYPE;
 l_def_max_resource_job_level   pa_project_assignments.max_resource_job_level%TYPE;
 l_source_assignment_id         pa_project_assignments.source_assignment_id%TYPE;
 l_source_calendar_type         pa_project_assignments.calendar_type%TYPE;
 l_source_status_code           pa_project_assignments.status_code%TYPE;
 l_menu_id                      NUMBER;
 l_return_status                VARCHAR2(1);
 l_competencies_tbl             PA_HR_COMPETENCE_UTILS.Competency_Tbl_Typ;
 l_job_id                       NUMBER;
 l_error_message_code           fnd_new_messages.message_name%TYPE;
 l_schedulable_flag             VARCHAR2(1);
 l_location_row_id              ROWID;
 l_no_of_competencies           NUMBER;
 l_task_id                      NUMBER;
 l_task_percentage              NUMBER;
 l_msg_count                    NUMBER;
 l_msg_data                     VARCHAR2(2000);

 l_element_rowid                ROWID;
 l_element_id                   NUMBER;
 l_element_return_status        VARCHAR2(1);
 l_req_text                     FND_NEW_MESSAGES.message_text%TYPE;
 l_calendar_id                  NUMBER;
 l_work_type_id                 NUMBER;
 l_raw_revenue                  NUMBER;

 l_comp_match_weighting         pa_project_assignments.competence_match_weighting%TYPE;
 l_avail_match_weighting        pa_project_assignments.availability_match_weighting%TYPE;
 l_job_level_match_weighting    pa_project_assignments.job_level_match_weighting%TYPE;
 l_search_min_availability      pa_project_assignments.search_min_availability%TYPE;
 l_search_exp_org_struct_ver_id pa_project_assignments.search_exp_org_struct_ver_id%TYPE;
 l_search_exp_start_org_id      pa_project_assignments.search_exp_start_org_id%TYPE;
 l_search_country_code          pa_project_assignments.search_country_code%TYPE;
 l_search_min_candidate_score   pa_project_assignments.search_min_candidate_score%TYPE;
 l_starting_status_code         pa_action_sets.status_code%TYPE;
 l_new_action_set_id            NUMBER;
 l_adv_action_set_id            NUMBER;
 l_start_adv_action_set_flag    VARCHAR2(1);
 l_task_assignment_id_tbl       system.pa_num_tbl_type := system.pa_num_tbl_type(); --Fix for bug#9095861
 l_proj_req_res_format_id       NUMBER;
 l_project_assignment_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_budget_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_struct_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_last_bvid					NUMBER;
 l_update_task_asgmt_id_tbl		system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_update_count					NUMBER;
 l_last_struct_version_id 		NUMBER;
 l_task_version_id_tbl			system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_update_task_version_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();

 l_fcst_job_id_tmp 			 pa_project_assignments.fcst_job_id%TYPE;
 l_expenditure_org_id_tmp 	 pa_project_assignments.expenditure_organization_id%TYPE;
 l_expenditure_type_tmp 	 pa_project_assignments.expenditure_type%TYPE;
 l_project_role_id_tmp 		 pa_project_assignments.project_role_id%TYPE;
 l_assignment_name_tmp 		 pa_project_assignments.assignment_name%TYPE;

 l_fcst_tp_amount_type_tmp   pa_project_assignments.fcst_tp_amount_type%TYPE;
 l_fcst_job_group_id_tmp     pa_project_assignments.fcst_job_group_id%TYPE;
 l_exp_org_id_tmp 	         pa_project_assignments.expenditure_org_id%TYPE;
 l_expenditure_type_class_tmp pa_project_assignments.expenditure_type_class%TYPE;
 l_enable_auto_cand_nom_flag  pa_project_assignments.enable_auto_cand_nom_flag%TYPE;

CURSOR get_project_info IS
SELECT calendar_id, competence_match_wt, availability_match_wt, job_level_match_wt, search_min_availability, search_org_hier_id, search_starting_org_id, search_country_code, min_cand_score_reqd_for_nom, adv_action_set_id, start_adv_action_set_flag,
enable_automated_search -- Added for bug 4306049
  FROM pa_projects_all
 WHERE project_id = l_assignment_rec.project_id;

-- Bottom Up Flow
CURSOR get_bu_resource_assignments IS
SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id
FROM  PA_RESOURCE_ASSIGNMENTS ra
     ,PA_BUDGET_VERSIONS bv
     ,PA_PROJ_ELEM_VER_STRUCTURE evs
 WHERE ra.project_id = bv.project_id
 AND   bv.project_id = evs.project_id
 AND   bv.budget_type_code IS NULL  -- added for bug#9095861
 AND   ra.budget_version_id = bv.budget_version_id
 AND   bv.project_structure_version_id = evs.element_version_id
 AND   ra.project_id = l_assignment_rec.project_id
 AND   ra.resource_list_member_id = l_assignment_rec.resource_list_member_id
 AND   ra.project_assignment_id = -1
-- AND   evs.latest_eff_published_flag = 'N'
 AND   ra.budget_version_id = p_budget_version_id;
--ORDER BY bv.budget_version_id, bv.project_structure_version_id;

-- Top-Down Flow
 CURSOR get_td_resource_assignments IS
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
          AND   bv.budget_type_code IS NULL  -- added for bug#9095861
	  AND   bv.project_structure_version_id = evs.element_version_id
	  AND   ra.project_id = l_assignment_rec.project_id
 	  AND   ra.resource_list_member_id = l_assignment_rec.resource_list_member_id
	  AND   ra.project_assignment_id = -1
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
          AND   bv.budget_type_code IS NULL  -- added for bug#9095861
	  AND   ra.budget_version_id = bv.budget_version_id
	  AND   bv.project_structure_version_id = evs.element_version_id
 	  AND   ra.resource_list_member_id = l_assignment_rec.resource_list_member_id
	  AND   ra.project_id = l_assignment_rec.project_id
	  AND   ra.project_assignment_id = -1)
 )
 ORDER BY budget_version_id, project_structure_version_id;

BEGIN

  --dbms_output.put_line('PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment');
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment');

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment.begin'
                     ,x_msg         => 'Beginning of Create_Open_Assignment'
                     ,x_log_level   => li_message_level);

  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Assign the input record to the local variable
  l_assignment_rec := p_assignment_rec;

  --The following is done when a team role is being copied to create a new
  --requirement:
  --Store the source assignment id in a local variable.
  --If we are COPYING a team role then null out the source assignment id in the
  --l_assignment_rec so that it won't be inserted to the db
  --as part of the new assignment record.
  --In the case of copying a team role, we need the source assignment id to create the subteam parties,
  --but we do not want to keep the link between the new requirement and the
  --team role it was copied from b/c then we shouldn't allow the team role it
  --was copied from to be deleted.
  --Confirmed with anchen that not keeping the link is OK.
  --Also get the default starting requirement status which will be
  --used as the status of the new requirement - NOT WHEN CREATING A REQUIREMENT FROM A TEMPLATE REQUIREMENT
  --in that case use the status from the template requirement.

  l_source_assignment_id := l_assignment_rec.source_assignment_id;

  IF p_asgn_creation_mode = 'COPY' AND (l_assignment_rec.assignment_template_id IS NULL OR l_assignment_rec.assignment_template_id = FND_API.G_MISS_NUM) THEN

     l_assignment_rec.source_assignment_id := NULL;

     --get the default starting requirement status.

     l_source_status_code := l_assignment_rec.status_code;

     FND_PROFILE.Get('PA_START_OPEN_ASGMT_STATUS',l_assignment_rec.status_code);

     IF l_assignment_rec.status_code IS NULL THEN

        PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                               ,p_msg_name => 'PA_START_STATUS_NOT_DEFINED');
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

     END IF;

  END IF;  --asgn creation mode is copy.

  --
  --Get assignment text from message to be used as values for token
  --
  l_req_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_TEXT');

  --
  -- Check that mandatory project id exists if this is not a template requirement.
  --
  IF (p_assignment_rec.project_id IS NULL OR p_assignment_rec.project_id = FND_API.G_MISS_NUM) AND
     (p_assignment_rec.assignment_template_id IS NULL OR p_assignment_rec.assignment_template_id = FND_API.G_MISS_NUM) THEN
    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_ID_REQUIRED_FOR_ASGN'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_req_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  -- Check that mandatory assignment name exists
  --
  IF p_assignment_rec.assignment_name IS NULL OR
     p_assignment_rec.assignment_name = FND_API.G_MISS_CHAR THEN
    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       =>  'PA_NAME_REQUIRED_FOR_ASGN');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  -- Check valid starting status
  --
  IF (PA_PROJECT_STUS_UTILS.Is_Starting_Status( x_project_status_code => l_assignment_rec.status_code)) = 'N' THEN
    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name  => 'PA'
                         ,p_msg_name        => 'PA_INVALID_ASGN_STARTING_STUS'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_req_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  --  Check that mandatory project role exists
  --
  IF p_assignment_rec.project_role_id IS NULL
     OR p_assignment_rec.project_role_id = FND_API.G_MISS_NUM THEN
    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_ROLE_REQUIRED_FOR_ASGN'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_req_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
   END IF;

  --if the new requirement is being copied from a requirement or a template
  --requirement then get the competencies from the source requirement
  --otherwise get the competencies from the role.
  -- Bug 2401916: ADDED COMPETENCE IN THE BASE REQ. IS NOT GETTING COPIED
  IF l_source_assignment_id IS NOT NULL
     AND l_source_assignment_id <> FND_API.G_MISS_NUM
     AND l_assignment_rec.source_assignment_type = 'OPEN_ASSIGNMENT' THEN

     PA_HR_COMPETENCE_UTILS.get_competencies(p_object_name => 'OPEN_ASSIGNMENT',
                                             p_object_id => l_source_assignment_id,
                                             x_competency_tbl => l_competencies_tbl,
                                             x_no_of_competencies => l_no_of_competencies,
                                             x_error_message_code => l_error_message_code,
                                             x_return_status => l_return_status);

      IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
          PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                                ,p_msg_name => l_error_message_code );
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
      END IF;

  ELSE

     --
     -- Get role default values
     --
     PA_ROLE_UTILS.Get_Role_Defaults( p_role_id               => p_assignment_rec.project_role_id
                                     ,x_meaning               => l_def_assignment_name
                                     ,x_default_min_job_level => l_def_min_resource_job_level
                                     ,x_default_max_job_level => l_def_max_resource_job_level
                                     ,x_menu_id               => l_menu_id
                                     ,x_schedulable_flag      => l_schedulable_flag
                                     ,x_default_job_id        => l_fcst_job_id_tmp
                                     ,x_def_competencies      => l_competencies_tbl
                                     ,x_return_status         => l_return_status
                                     ,x_error_message_code    => l_error_message_code );

     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN

        PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => l_error_message_code );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

     IF l_schedulable_flag <> 'Y' THEN

        PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                              ,p_msg_name => 'PA_ROLE_NOT_SCHEDULABLE' );
        PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        return;
     END IF;

     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
       IF  l_assignment_rec.min_resource_job_level IS NULL
         OR l_assignment_rec.min_resource_job_level = FND_API.G_MISS_NUM  THEN
        l_assignment_rec.min_resource_job_level := l_def_min_resource_job_level;
       END IF;
       --
       IF  l_assignment_rec.max_resource_job_level IS NULL
         OR l_assignment_rec.max_resource_job_level = FND_API.G_MISS_NUM  THEN
        l_assignment_rec.max_resource_job_level := l_def_max_resource_job_level;
       END IF;

       -- 5130421 : It is possible to null out the job so remove the null check
       IF --l_assignment_rec.fcst_job_id IS NULL
         l_assignment_rec.fcst_job_id = FND_API.G_MISS_NUM THEN
        l_assignment_rec.fcst_job_id := l_fcst_job_id_tmp;
       END IF;
     END IF;
  END IF;

  --Get utilization defaults before creating requirement/assignment
  --IF it has not been defaulted already OR
  --IF it is copying from an assignment into a requirement AND
  --IF IT IS NOT a template requirement.

  IF (((l_assignment_rec.expenditure_type IS NULL) OR
     (l_assignment_rec.expenditure_type = FND_API.G_MISS_CHAR) OR
     (p_asgn_creation_mode <> 'COPY') OR
     (p_asgn_creation_mode = 'COPY' AND l_assignment_rec.source_assignment_type <> 'OPEN_ASSIGNMENT')) AND
     (l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM))THEN

    --dbms_output.put_line('calling assignment default');
    --Log Message
    IF (P_DEBUG_MODE = 'Y') THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
                     ,x_msg         => 'Getting Utilization Defaults.'
                     ,x_log_level   => li_message_level);
    END IF;

    PA_FORECAST_ITEMS_UTILS.Get_Assignment_Default(
                                  p_assignment_type             => l_assignment_rec.assignment_type,
                                  p_project_id                  => l_assignment_rec.project_id,
                                  p_project_role_id             => l_assignment_rec.project_role_id,
                                  p_work_type_id                => l_assignment_rec.work_type_id,
                                  x_work_type_id                => l_work_type_id,
                                  x_default_tp_amount_type      => l_fcst_tp_amount_type_tmp,
                                  x_default_job_group_id        => l_fcst_job_group_id_tmp,
                                  x_default_job_id              => l_fcst_job_id_tmp,
                                  x_org_id                      => l_exp_org_id_tmp,
                                  x_carrying_out_organization_id=> l_expenditure_org_id_tmp,
                                  x_default_assign_exp_type     => l_expenditure_type_tmp,
                                  x_default_assign_exp_type_cls => l_expenditure_type_class_tmp,
                                  x_return_status               => l_return_status,
                                  x_msg_count                   => l_msg_count,
                                  x_msg_data                    => l_msg_data
                                  );
    -- Bug 5130421
    -- fcst tp amount type shd get default from work type
    -- it was getting default from the default work type
    IF l_assignment_rec.work_type_id IS NOT NULL AND l_assignment_rec.work_type_id <> FND_API.G_MISS_NUM THEN
         Pa_Fp_Org_Fcst_Utils.Get_Tp_Amount_Type(
                              p_project_id => l_assignment_rec.project_id,
                              p_work_type_id => l_assignment_rec.work_type_id,
                              x_tp_amount_type => l_fcst_tp_amount_type_tmp,
                              x_return_status => l_return_status,
                              x_msg_count => l_msg_count,
                              x_msg_data => l_msg_data);
		IF (l_assignment_rec.fcst_tp_amount_type IS NULL OR
		    l_assignment_rec.fcst_tp_amount_type = FND_API.G_MISS_CHAR) THEN
			l_assignment_rec.fcst_tp_amount_type := l_fcst_tp_amount_type_tmp;
		END IF;
    ELSE
	IF (l_assignment_rec.fcst_tp_amount_type IS NULL OR
	    l_assignment_rec.fcst_tp_amount_type = FND_API.G_MISS_CHAR) THEN
		l_assignment_rec.fcst_tp_amount_type := l_fcst_tp_amount_type_tmp;
	END IF;
    END IF;
    -- 5130421 : It is possible to null out the job and job group so remove the null check
    IF (--l_assignment_rec.fcst_job_group_id IS NULL OR
	    l_assignment_rec.fcst_job_group_id = FND_API.G_MISS_NUM) THEN
		l_assignment_rec.fcst_job_group_id := l_fcst_job_group_id_tmp;
	END IF;
    IF (--l_assignment_rec.fcst_job_id IS NULL OR
	    l_assignment_rec.fcst_job_id = FND_API.G_MISS_NUM) THEN
		l_assignment_rec.fcst_job_id := l_fcst_job_id_tmp;
	END IF;
    IF (l_assignment_rec.expenditure_org_id IS NULL OR
	    l_assignment_rec.expenditure_org_id = FND_API.G_MISS_NUM) THEN
		l_assignment_rec.expenditure_org_id := l_exp_org_id_tmp;
	END IF;
    IF (l_assignment_rec.expenditure_organization_id IS NULL OR
	    l_assignment_rec.expenditure_organization_id = FND_API.G_MISS_NUM) THEN
		l_assignment_rec.expenditure_organization_id := l_expenditure_org_id_tmp;
	END IF;
    IF (l_assignment_rec.expenditure_type IS NULL OR
	    l_assignment_rec.expenditure_type = FND_API.G_MISS_CHAR) THEN
		l_assignment_rec.expenditure_type := l_expenditure_type_tmp;
	END IF;
    IF (l_assignment_rec.expenditure_type_class IS NULL OR
	    l_assignment_rec.expenditure_type_class = FND_API.G_MISS_CHAR) THEN
		l_assignment_rec.expenditure_type_class := l_expenditure_type_class_tmp;
	END IF;

    --dbms_output.put_line('after assignment default:'|| l_return_status);
    --IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
    --  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    --ELSE

   END IF;

      --
      -- Get bill rate and bill rate currency code, and markup percent
      -- Call this API only if the required parameters are present.
      -- Note: expenditure_org_id(OU) can be NULL in the case of single org
      IF l_assignment_rec.fcst_job_id IS NOT NULL AND l_assignment_rec.fcst_job_id <> FND_API.G_MISS_NUM AND
         l_assignment_rec.fcst_job_group_id IS NOT NULL AND l_assignment_rec.fcst_job_group_id <> FND_API.G_MISS_NUM AND
         l_assignment_rec.expenditure_organization_id IS NOT NULL AND l_assignment_rec.expenditure_organization_id <> FND_API.G_MISS_NUM THEN

        --Log Message
	IF (P_DEBUG_MODE = 'Y') THEN
	PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
                           ,x_msg         => 'Getting Revenue Bill Rate'
                           ,x_log_level   => li_message_level);

	END IF;

        PA_FORECAST_REVENUE.Get_Rev_Amt(
         p_project_id            => l_assignment_rec.project_id
        ,p_quantity   	         => 0
        ,p_person_id             => NULL
        ,p_item_date             => l_assignment_rec.start_date
        ,p_forecast_job_id       => l_assignment_rec.fcst_job_id
        ,p_forecast_job_group_id => l_assignment_rec.fcst_job_group_id
        ,p_expenditure_org_id    => l_assignment_rec.expenditure_org_id
        ,p_expenditure_organization_id => l_assignment_rec.expenditure_organization_id
        ,p_check_error_flag      => 'N'
        ,x_bill_rate             => l_assignment_rec.revenue_bill_rate
        ,x_raw_revenue           => l_raw_revenue
        ,x_rev_currency_code     => l_assignment_rec.revenue_currency_code
        ,x_markup_percentage     => l_assignment_rec.markup_percent
        ,x_return_status         => l_return_status
        ,x_msg_count             => l_msg_count
        ,x_msg_data              => l_msg_data);

     END IF; -- if required parameters are present
    --END IF; -- if get_assignment_default returns success
  --END IF;

  -- FP.M Development
  IF P_DEBUG_MODE = 'Y' THEN
  	 pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
         ,x_msg         => 'FP.M Development'
         ,x_log_level   => li_message_level);
  END IF;

  IF (p_assignment_rec.resource_list_member_id = FND_API.G_MISS_NUM OR
  	  p_assignment_rec.resource_list_member_id IS NULL) AND
     p_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN
     SELECT proj_req_res_format_id
     INTO   l_proj_req_res_format_id
     FROM   PA_PROJECTS_ALL
     WHERE  project_id = p_assignment_rec.project_id;

	 l_fcst_job_id_tmp := l_assignment_rec.fcst_job_id;
     IF l_fcst_job_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_fcst_job_id_tmp := NULL;
	 END IF;

     l_expenditure_org_id_tmp := l_assignment_rec.expenditure_organization_id;
     IF l_expenditure_org_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_expenditure_org_id_tmp := NULL;
	 END IF;

	 l_expenditure_type_tmp := l_assignment_rec.expenditure_type;
     IF l_expenditure_type_tmp = FND_API.G_MISS_CHAR THEN
	  	l_expenditure_type_tmp := NULL;
	 END IF;

	 l_project_role_id_tmp := l_assignment_rec.project_role_id;
     IF l_project_role_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_project_role_id_tmp := NULL;
	 END IF;

	 l_assignment_name_tmp := l_assignment_rec.assignment_name;
     IF l_assignment_name_tmp = FND_API.G_MISS_CHAR THEN
	  	l_assignment_name_tmp := NULL;
	 END IF;

  	 IF P_DEBUG_MODE = 'Y' THEN
   	   pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
       ,x_msg         => 'proj_id='||p_assignment_rec.project_id||
				   	  ' res_format='||l_proj_req_res_format_id||
					  ' job_id='||l_fcst_job_id_tmp
       ,x_log_level   => li_message_level);
 	   pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
       ,x_msg         => 'org_id='||l_expenditure_org_id_tmp||
				   	  ' exp_type='||l_expenditure_type_tmp||
					  ' role_id='||l_project_role_id_tmp||
					  ' named_role='||l_assignment_name_tmp
       ,x_log_level   => li_message_level);
	 END IF;

     l_assignment_rec.resource_list_member_id :=
     PA_PLANNING_RESOURCE_UTILS.DERIVE_RESOURCE_LIST_MEMBER (
                                p_project_id            => p_assignment_rec.project_id
                               ,p_res_format_id         => l_proj_req_res_format_id
                               ,p_job_id                => l_fcst_job_id_tmp
                               ,p_organization_id       => l_expenditure_org_id_tmp
                               ,p_expenditure_type      => l_expenditure_type_tmp
                               ,p_project_role_id       => l_project_role_id_tmp
                               ,p_named_role            => l_assignment_name_tmp);
  	 IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
           ,x_msg         => 'resource_list_member_id='||l_assignment_rec.resource_list_member_id
           ,x_log_level   => li_message_level);
	 END IF;

  END IF;

  --
  --Check p_work_type_id IS NOT NULL
  --
  IF  l_assignment_rec.work_type_id IS NULL
      OR l_assignment_rec.work_type_id = FND_API.G_MISS_NUM
	  OR l_assignment_rec.work_type_id = 0 THEN
    --dbms_output.put_line('WORK TYPE INVALID');
    PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_WORK_TYPE_REQUIRED_FOR_ASGN' );
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  ELSIF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN
    --
    --check for indirect project, only non-billable work types if this is NOT
    --a template requirement
    PA_WORK_TYPE_UTILS.CHECK_WORK_TYPE (
 	P_WORK_TYPE_ID             =>  l_assignment_rec.work_type_id
 	,P_PROJECT_ID               =>  l_assignment_rec.project_id
        ,P_TASK_ID                  =>  NULL
 	,X_RETURN_STATUS            =>  l_return_status
 	,X_ERROR_MESSAGE_CODE       =>  l_error_message_code);
    IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
      PA_ASSIGNMENT_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => l_error_message_code );
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;

  END IF;

  --
  -- For Open Assignment multiple status flag should be set to 'N'
  --
  l_assignment_rec.multiple_status_flag := 'N';

  --  Rules:
  --  If this is NOT a template requirement AND
  --  If all the location input parameters are null then default location from project
  --  If location details are passed then get the location id for the for the given  location parameters
  --  If the location does not already exist then create it
  --
  IF  (l_assignment_rec.location_id IS NULL OR l_assignment_rec.location_id = FND_API.G_MISS_NUM)
      AND (p_location_city IS NULL OR p_location_city = FND_API.G_MISS_CHAR)
      AND (p_location_region IS NULL OR p_location_region = FND_API.G_MISS_CHAR)
      AND (p_location_country_code IS NULL OR p_location_country_code = FND_API.G_MISS_CHAR)
      AND (l_assignment_rec.project_id IS NOT NULL and l_assignment_rec.project_id <> FND_API.G_MISS_NUM)
   THEN

--Bug 1795160: no need to get location from project, location not required
/*
   SELECT location_id
   INTO   l_assignment_rec.location_id
   FROM   pa_projects_all
   WHERE  project_id = l_assignment_rec.project_id;
*/
   --Log Message
   IF (P_DEBUG_MODE = 'Y') THEN
   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment.location'
                     ,x_msg         => 'No need to get location from project'
                     ,x_log_level   => li_message_level);
   END IF;



  --only call get_location if location_id IS NULL
  ELSIF l_assignment_rec.location_id IS NULL OR l_assignment_rec.location_id = FND_API.G_MISS_NUM THEN

    PA_LOCATION_UTILS.Get_Location( p_city                => p_location_city
                                   ,p_region              => p_location_region
                                   ,p_country_code        => p_location_country_code
                                   ,x_location_id         => l_assignment_rec.location_id
                                   ,x_error_message_code  => l_error_message_code
                                   ,x_return_status       => l_return_status );

      IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
         PA_ASSIGNMENT_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => l_error_message_code );
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  END IF;

  --get defaults from project when a requirement (not template
  --requirement) is being either newly created
  --or created(copied) from an assignment
  IF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN

    OPEN get_project_info;
    FETCH get_project_info INTO l_calendar_id,
                                l_comp_match_weighting,
                                l_avail_match_weighting,
                                l_job_level_match_weighting,
                                l_search_min_availability,
                                l_search_exp_org_struct_ver_id,
                                l_search_exp_start_org_id,
                                l_search_country_code,
                                l_search_min_candidate_score,
                                l_adv_action_set_id,
                                l_start_adv_action_set_flag,
				l_enable_auto_cand_nom_flag;  --Added for bug 4306049
    CLOSE get_project_info;
  END IF;

  -- if no candidate or search settings parameters is passed in
  -- and this is not to create template requirement
  -- use candidate and search settings defaulted from the project

  -- FP.M Development: Default the following attributes when
  -- l_assignment_rec.resource_list_member_id IS NOT NULL
  IF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM
     AND (l_assignment_rec.comp_match_weighting IS NULL OR l_assignment_rec.comp_match_weighting = FND_API.G_MISS_NUM OR l_assignment_rec.resource_list_member_id <> FND_API.G_MISS_NUM)
     AND PA_STARTUP.G_Calling_Application <> 'PLSQL' --    Bug 5130421 : added PLSQL check
  THEN
    l_assignment_rec.comp_match_weighting := l_comp_match_weighting;
    l_assignment_rec.avail_match_weighting := l_avail_match_weighting;
    l_assignment_rec.job_level_match_weighting := l_job_level_match_weighting;
    l_assignment_rec.search_min_availability := l_search_min_availability;
    l_assignment_rec.search_exp_org_struct_ver_id := l_search_exp_org_struct_ver_id;
    l_assignment_rec.search_exp_start_org_id := l_search_exp_start_org_id;
    l_assignment_rec.search_country_code := l_search_country_code;
    l_assignment_rec.search_min_candidate_score := l_search_min_candidate_score;
    l_assignment_rec.enable_auto_cand_nom_flag := l_enable_auto_cand_nom_flag;  -- Changed 'Y' to l_enable_auto_cand_nom_flag for bug 4306049;
  --    Bug 5130421 Added ELSIF
  ELSIF PA_STARTUP.G_Calling_Application = 'PLSQL' AND  l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM
  THEN
        IF l_assignment_rec.comp_match_weighting IS NULL OR l_assignment_rec.comp_match_weighting = FND_API.G_MISS_NUM THEN
                l_assignment_rec.comp_match_weighting := l_comp_match_weighting;
        END IF;
        IF l_assignment_rec.avail_match_weighting IS NULL OR l_assignment_rec.avail_match_weighting = FND_API.G_MISS_NUM THEN
                l_assignment_rec.avail_match_weighting := l_avail_match_weighting;
        END IF;
        IF l_assignment_rec.job_level_match_weighting IS NULL OR l_assignment_rec.job_level_match_weighting = FND_API.G_MISS_NUM THEN
                l_assignment_rec.job_level_match_weighting := l_job_level_match_weighting;
        END IF;
        IF l_assignment_rec.search_min_availability IS NULL OR l_assignment_rec.search_min_availability = FND_API.G_MISS_NUM THEN
                l_assignment_rec.search_min_availability := l_search_min_availability;
        END IF;
        IF l_assignment_rec.search_exp_org_struct_ver_id IS NULL OR l_assignment_rec.search_exp_org_struct_ver_id = FND_API.G_MISS_NUM THEN
                l_assignment_rec.search_exp_org_struct_ver_id := l_search_exp_org_struct_ver_id;
        END IF;
        IF l_assignment_rec.search_exp_start_org_id IS NULL OR l_assignment_rec.search_exp_start_org_id = FND_API.G_MISS_NUM THEN
                l_assignment_rec.search_exp_start_org_id := l_search_exp_start_org_id;
        END IF;
        IF l_assignment_rec.search_country_code = FND_API.G_MISS_CHAR THEN
                -- Search country code can be null
                l_assignment_rec.search_country_code := l_search_country_code;
        END IF;
        IF l_assignment_rec.search_min_candidate_score IS NULL OR l_assignment_rec.search_min_candidate_score = FND_API.G_MISS_NUM THEN
                l_assignment_rec.search_min_candidate_score := l_search_min_candidate_score;
        END IF;
        IF l_assignment_rec.enable_auto_cand_nom_flag IS NULL OR l_assignment_rec.enable_auto_cand_nom_flag = FND_API.G_MISS_CHAR THEN
                l_assignment_rec.enable_auto_cand_nom_flag := 'Y';
        END IF;
  END IF;

  --if a new requirement is being created(copied) from an assignment with a
  --RESOURCE calendar then use the PROJECT calendar for the new requirement.
  --It doesn't make sense to create a requirement with a resource calendar, as
  --there is no resource for a requirement.
  l_source_calendar_type := l_assignment_rec.calendar_type;

  -- FP.M Development
  IF l_assignment_rec.calendar_type = 'RESOURCE' THEN
     l_assignment_rec.calendar_type := 'PROJECT';
     l_assignment_rec.calendar_id := l_calendar_id;
--  ELSIF l_assignment_rec.calendar_type = 'TASK_ASSIGNMENT' THEN
--          l_sum_tasks_flag := 'Y';
          --l_assignment_rec.calendar_type := 'PROJECT';
  END IF;

  --
  -- Create the Open Assignment Record
  --

  IF p_validate_only = FND_API.G_FALSE AND FND_MSG_PUB.Count_Msg = 0 THEN

    --Log Message
    IF (P_DEBUG_MODE = 'Y') THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment.insert_row'
                     ,x_msg         => 'Inserting record into pa_project_assignments.'
                     ,x_log_level   => li_message_level);
    END IF;

    --dbms_output.put_line('calling insert_row');
    PA_PROJECT_ASSIGNMENTS_PKG.Insert_Row
    ( p_assignment_name             => l_assignment_rec.assignment_name
     ,p_assignment_type             => l_assignment_rec.assignment_type
     ,p_multiple_status_flag        => l_assignment_rec.multiple_status_flag
     ,p_status_code                 => l_assignment_rec.status_code
     ,p_staffing_priority_code      => l_assignment_rec.staffing_priority_code
     ,p_project_id                  => l_assignment_rec.project_id
     ,p_assignment_template_id      => l_assignment_rec.assignment_template_id
     ,p_project_role_id             => l_assignment_rec.project_role_id
     ,p_description                 => l_assignment_rec.description
     ,p_start_date                  => l_assignment_rec.start_date
     ,p_end_date                    => l_assignment_rec.end_date
     ,p_assignment_effort           => l_assignment_rec.assignment_effort
     ,p_extension_possible          => l_assignment_rec.extension_possible
     ,p_source_assignment_id        => l_assignment_rec.source_assignment_id
     ,p_min_resource_job_level      => l_assignment_rec.min_resource_job_level
     ,p_max_resource_job_level      => l_assignment_rec.max_resource_job_level
     ,p_additional_information      => l_assignment_rec.additional_information
     ,p_work_type_id                => l_assignment_rec.work_type_id
     ,p_revenue_currency_code       => l_assignment_rec.revenue_currency_code
     ,p_revenue_bill_rate           => l_assignment_rec.revenue_bill_rate
     ,p_markup_percent              => l_assignment_rec.markup_percent
     ,p_expense_owner               => l_assignment_rec.expense_owner
     ,p_expense_limit               => l_assignment_rec.expense_limit
     ,p_expense_limit_currency_code => l_assignment_rec.expense_limit_currency_code
     ,p_fcst_tp_amount_type         => l_assignment_rec.fcst_tp_amount_type
     ,p_fcst_job_id                 => l_assignment_rec.fcst_job_id
     ,p_fcst_job_group_id           => l_assignment_rec.fcst_job_group_id
     ,p_expenditure_org_id          => l_assignment_rec.expenditure_org_id
     ,p_expenditure_organization_id => l_assignment_rec.expenditure_organization_id
     ,p_expenditure_type_class      => l_assignment_rec.expenditure_type_class
     ,p_expenditure_type            => l_assignment_rec.expenditure_type
     ,p_location_id                 => l_assignment_rec.location_id
     ,p_calendar_type               => l_assignment_rec.calendar_type
     ,p_calendar_id                 => l_assignment_rec.calendar_id
     ,p_comp_match_weighting        => l_assignment_rec.comp_match_weighting
     ,p_avail_match_weighting       => l_assignment_rec.avail_match_weighting
     ,p_job_level_match_weighting   => l_assignment_rec.job_level_match_weighting
     ,p_search_min_availability     => l_assignment_rec.search_min_availability
     ,p_search_country_code         => l_assignment_rec.search_country_code
     ,p_search_exp_org_struct_ver_id => l_assignment_rec.search_exp_org_struct_ver_id
     ,p_search_exp_start_org_id     => l_assignment_rec.search_exp_start_org_id
     ,p_search_min_candidate_score  => l_assignment_rec.search_min_candidate_score
     ,p_enable_auto_cand_nom_flag   => l_assignment_rec.enable_auto_cand_nom_flag
     ,p_bill_rate_override          => l_assignment_rec.bill_rate_override
     ,p_bill_rate_curr_override     => l_assignment_rec.bill_rate_curr_override
     ,p_markup_percent_override     => l_assignment_rec.markup_percent_override
     ,p_discount_percentage         => l_assignment_rec.discount_percentage    -- FP.L Development
     ,p_rate_disc_reason_code       => l_assignment_rec.rate_disc_reason_code  -- FP.L Development
     ,p_tp_rate_override            => l_assignment_rec.tp_rate_override
     ,p_tp_currency_override        => l_assignment_rec.tp_currency_override
     ,p_tp_calc_base_code_override  => l_assignment_rec.tp_calc_base_code_override
     ,p_tp_percent_applied_override => l_assignment_rec.tp_percent_applied_override
     ,p_staffing_owner_person_id    => l_assignment_rec.staffing_owner_person_id -- FP.L Development
     ,p_resource_list_member_id     => l_assignment_rec.resource_list_member_id -- FP.M Development
     ,p_attribute_category          => l_assignment_rec.attribute_category
     ,p_attribute1                  => l_assignment_rec.attribute1
     ,p_attribute2                  => l_assignment_rec.attribute2
     ,p_attribute3                  => l_assignment_rec.attribute3
     ,p_attribute4                  => l_assignment_rec.attribute4
     ,p_attribute5                  => l_assignment_rec.attribute5
     ,p_attribute6                  => l_assignment_rec.attribute6
     ,p_attribute7                  => l_assignment_rec.attribute7
     ,p_attribute8                  => l_assignment_rec.attribute8
     ,p_attribute9                  => l_assignment_rec.attribute9
     ,p_attribute10                 => l_assignment_rec.attribute10
     ,p_attribute11                 => l_assignment_rec.attribute11
     ,p_attribute12                 => l_assignment_rec.attribute12
     ,p_attribute13                 => l_assignment_rec.attribute13
     ,p_attribute14                 => l_assignment_rec.attribute14
     ,p_attribute15                 => l_assignment_rec.attribute15
     ,p_number_of_requirements      => p_number_of_requirements
     ,x_assignment_row_id           => x_assignment_row_id
     ,x_new_assignment_id           => l_assignment_id
     ,x_assignment_number           => x_assignment_number
    ,x_return_status                => x_return_status
    );

    x_new_assignment_id := l_assignment_id;

    --Log Message
    IF (P_DEBUG_MODE = 'Y') THEN
    PA_DEBUG.write_log (x_module    => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment.insert_schedule'
                     ,x_msg         => 'Insert the schedule days for the open assignment.'
                     ,x_log_level   => li_message_level);
    END IF;

    --
    -- Insert the schedule days for the open assignment
    -- Do not create the schedule if this is a template requirement.
    IF l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN

       IF l_source_assignment_id = FND_API.G_MISS_NUM THEN
          l_source_assignment_id := NULL;
       END IF;

       --if this requirement is being copied from a team role then
       --a)pass a NULL calendar id to the create schedule API if the source team role did not
       --  have a RESOURCE calendar type.  This is because the
       --  schedule API will just copy the schedule from the source team role and the
       --  NULL calendar id is a flag to the create schedule API.
       --b)do pass the calendar id to the create schedule API if the source team role
       --  has a resource calendar because the new requirement cannot use a
       --  resource calendar (it would use the project calendar as described above)
       --  so the create schedule API will actually create a new schedule.
       --If this requirement is being created from a template requirement (assignment template id
       --is populated then we must pass the calendar and status because a template requirement
       --does not have any schedule so it must be created.
       IF p_asgn_creation_mode = 'COPY' AND (l_assignment_rec.assignment_template_id IS NULL OR
          l_assignment_rec.assignment_template_id = FND_API.G_MISS_NUM) THEN

          IF l_source_calendar_type <> 'RESOURCE' THEN
             l_assignment_rec.calendar_id := NULL;

             --If the source status code (status code of the team role being copied) is
             --the same as the default requirement starting status then don't pass the
             --status code to the create schedule API.  That is a flag to the create schedule
             --API that the status is the same.
             --if calendar id is going to be passed then status code also MUST be passed.
             --that is why this IF condition is inside the outer.
             IF l_source_status_code = l_assignment_rec.status_code THEN
                l_assignment_rec.status_code := NULL;
             END IF;
          END IF;

      END IF;
      /*
      dbms_output.put_line('l_assignment_rec.project_id='||l_assignment_rec.project_id);
      dbms_output.put_line('l_assignment_rec.calendar_id='||l_assignment_rec.calendar_id);
      dbms_output.put_line('l_source_assignment_id='||l_source_assignment_id);
      dbms_output.put_line('l_assignment_rec.start_date='||l_assignment_rec.start_date);
      dbms_output.put_line('l_assignment_rec.end_date='||l_assignment_rec.end_date);
      dbms_output.put_line('l_assignment_rec.status_code='||l_assignment_rec.status_code);
      */

      --FP.M Development
 IF p_assignment_rec.project_id <> FND_API.G_MISS_NUM AND
     p_asgn_creation_mode <> 'COPY' THEN

  	IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
  		          ,x_msg         => 'FP.M Development'
		          ,x_log_level   => li_message_level);

    pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
                ,x_msg         => 'resource_list_member_id'||l_assignment_rec.resource_list_member_id
                ,x_log_level   => li_message_level);

    pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
                ,x_msg         => 'budget_version_id'||p_budget_version_id
                ,x_log_level   => li_message_level);
	END IF;

    IF p_budget_version_id IS NOT NULL AND p_budget_version_id <> FND_API.G_MISS_NUM AND
     l_assignment_rec.resource_list_member_id IS NOT NULL AND
	 l_assignment_rec.resource_list_member_id <> FND_API.G_MISS_NUM THEN

	    OPEN  get_bu_resource_assignments;
	    FETCH get_bu_resource_assignments
	     BULK COLLECT INTO l_task_assignment_id_tbl,
	          		       l_task_version_id_tbl,
	  	   		   		   l_budget_version_id_tbl,
						   l_struct_version_id_tbl;
	    CLOSE get_bu_resource_assignments;

  	ELSE

            /*Added this IF for bug 9095861 */
            IF l_assignment_rec.resource_list_member_id IS NOT NULL AND l_assignment_rec.resource_list_member_id <> FND_API.G_MISS_NUM THEN
	    OPEN  get_td_resource_assignments;
	    FETCH get_td_resource_assignments
	     BULK COLLECT INTO l_task_assignment_id_tbl,
	                       l_task_version_id_tbl,
	  	   		   		   l_budget_version_id_tbl,
						   l_struct_version_id_tbl;
	    CLOSE get_td_resource_assignments;
            END IF ;
            /*Added this IF for bug 9095861 */
  	END IF;

       -- If multiple requirements are created, only the first requirement will be
       -- linked to the task assignments.
       -- Call planning_transaction_utils api to update project_assignment_id in
       -- pa_resource_assignments table.
  	pa_assignments_pvt.Update_Task_Assignments(
	  p_mode					=>  'CREATE'
	 ,p_task_assignment_id_tbl	=> 	l_task_assignment_id_tbl
	 ,p_task_version_id_tbl		=>  l_task_version_id_tbl
	 ,p_budget_version_id_tbl	=>  l_budget_version_id_tbl
	 ,p_struct_version_id_tbl	=>  l_struct_version_id_tbl
	 -- change project_assignment_id to this assignment_id
	 ,p_project_assignment_id 	=>  PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(1).assignment_id
--	 ,p_resource_list_member_id =>  l_assignment_rec.resource_list_member_id
	 -- change the named role to this assignment name
	 ,p_named_role				=> 	p_assignment_rec.assignment_name
	 ,p_project_role_id			=>	p_assignment_rec.project_role_id
	 ,x_return_status           =>  l_return_status
  );

 END IF;  -- IF p_assignment_rec.project_id <> FND_API.G_MISS_NUM AND
               -- p_asgn_creation_mode <> 'COPY' THEN

      PA_SCHEDULE_PVT.Create_OPN_ASG_Schedule
                               ( p_project_id              => l_assignment_rec.project_id
                                ,p_calendar_id             => l_assignment_rec.calendar_id
                                ,p_assignment_id_tbl       => PA_ASSIGNMENTS_PUB.g_assignment_id_tbl
                                ,p_assignment_source_id    => l_source_assignment_id
                                ,p_start_date              => l_assignment_rec.start_date
                                ,p_end_date                => l_assignment_rec.end_date
                                ,p_assignment_status_code  => l_assignment_rec.status_code
                                ,p_task_assignment_id_tbl  => l_task_assignment_id_tbl
                                ,p_sum_tasks_flag          => p_sum_tasks_flag
								,p_budget_version_id	   => p_budget_version_id
							    ,x_return_status           => l_return_status
                                ,x_msg_count               => l_msg_count
                                ,x_msg_data                => l_msg_data
                                             );

  	IF P_DEBUG_MODE = 'Y' THEN
       pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
                ,x_msg         => 'create_opn_asg_schedule '||l_return_status
                ,x_log_level   => li_message_level);
    END IF;

/* Bug 3051110 - Added code to call PA_ASSIGNMENTS_PVT.Calc_Init_Transfer_Price if the l_return status is success,
this is to populate the TP columns in pa_project_assignments table */

   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

      IF p_debug_mode = 'Y' THEN
          PA_DEBUG.WRITE('PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment', 'About to call .Calc_Init_Transfer_Price', 3);
          PA_DEBUG.WRITE('PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment', 'Assignment_id is :'||l_assignment_id||' and start date:'||l_assignment_rec.start_date, 3);
      END IF;

      FOR i IN PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.FIRST .. PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.LAST LOOP

        PA_ASSIGNMENTS_PVT.Calc_Init_Transfer_Price
	    (p_assignment_id => PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id,
	     p_start_date => l_assignment_rec.start_date,
	     p_debug_mode => p_debug_mode,
	     x_return_status => l_return_status,
	     x_msg_data => l_msg_data,
	     x_msg_count => l_msg_count );
  		IF P_DEBUG_MODE = 'Y' THEN
	       pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
	                ,x_msg         => 'calc_init_transfer_price '||l_return_status
	                ,x_log_level   => li_message_level);
	    END IF;
      END LOOP;

   END IF;

      --
      -- Bug 2388060 - Apply Action Set after schedule has been created
      -- Apply the Advertisement Action Set on the non-template requirement
      --
      IF p_adv_action_set_id IS NOT NULL AND p_adv_action_set_id <> FND_API.G_MISS_NUM THEN
        l_adv_action_set_id := p_adv_action_set_id;
      END IF;

      IF p_start_adv_action_set_flag IS NOT NULL AND p_start_adv_action_set_flag <> FND_API.G_MISS_CHAR THEN
        l_start_adv_action_set_flag := p_start_adv_action_set_flag;
      END IF;

      -- set the global variable for PA_ADVERTISEMENTS_PUB
      -- Is_Action_Set_Started_On_Apply to return to overriding flag
/*Commented for bug 2636577*/
      --PA_ADVERTISEMENTS_PUB.g_start_adv_action_set_flag := l_start_adv_action_set_flag;

      --dbms_output.put_line('before calling PA_ACTION_SETS_PUB.Apply_Action_Set');
      --dbms_output.put_line('action set id= '||l_adv_action_set_id);
      --dbms_output.put_line('start action set ? '||l_start_adv_action_set_flag);

      --Log Message
      IF (P_DEBUG_MODE = 'Y') THEN
      PA_DEBUG.write_log (x_module    => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
                         ,x_msg       => 'calling PA_ACTION_SETS_PUB.Apply_Action_Set'
                         ,x_log_level => li_message_level);
      END IF;


      IF FND_MSG_PUB.Count_Msg = 0 THEN

         FOR i IN PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.FIRST .. PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.LAST LOOP
         /*Added for bug 2636577*/

             PA_ADVERTISEMENTS_PUB.g_start_adv_action_set_flag := l_start_adv_action_set_flag;

        /*code change end for 2636577*/

  			 IF P_DEBUG_MODE = 'Y' THEN
	 	       pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
		                ,x_msg         => 'before Apply_Action_Set, action_set_id='||l_adv_action_set_id||
									   	  ' obj_id='||PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id||
										  ' commit='||p_commit||
										  ' val='||p_validate_only
		                ,x_log_level   => li_message_level);
  			 END IF;

             PA_ACTION_SETS_PUB.Apply_Action_Set(
                p_action_set_id        => l_adv_action_set_id
               ,p_object_type          => 'OPEN_ASSIGNMENT'
               ,p_object_id            => PA_ASSIGNMENTS_PUB.g_assignment_id_tbl(i).assignment_id
               ,p_perform_action_set_flag => 'Y'
               ,p_commit               => p_commit
               ,p_validate_only        => p_validate_only
               ,p_init_msg_list        => FND_API.G_FALSE
               ,x_new_action_set_id    => l_new_action_set_id
               ,x_return_status        => l_return_status
               ,x_msg_count            => l_msg_count
               ,x_msg_data             => l_msg_data);

  			 IF P_DEBUG_MODE = 'Y' THEN
	 	       pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
		                ,x_msg         => 'Apply_Action_Set, status='||l_return_status
		                ,x_log_level   => li_message_level);
  			 END IF;

         END LOOP;
    END IF;

      --dbms_output.put_line('after calling PA_ACTION_SETS_PUB.Apply_Action_Set');

    END IF;


    --Log Message
    IF (P_DEBUG_MODE = 'Y') THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment.create_competency'
                     ,x_msg         => 'Creating competencies.'
                     ,x_log_level   => li_message_level);
    END IF;


    --
    -- Create Competencies for Requirement and Template Requiremento
    --
    --dbms_output.put_line('competency table count: ' || l_competencies_tbl.COUNT);
    --
    -- FP.L Development
    -- User can now specify competences in the page, so there is no need to insert
    -- competences defaulting from the role.
    -- In this case, we only need to insert competencies when the requirement is
    -- created from template
    --
	-- FP.M Development
	-- If creating requirement from Create Team Roles page, insert the competencies.

        -- 5130421 : Added G_Calling_Application check so that competencies are copied
        -- while creation of new requirments

    IF (l_source_assignment_id IS NOT NULL AND
	    l_source_assignment_id <> FND_API.G_MISS_NUM AND
		l_assignment_rec.source_assignment_type = 'OPEN_ASSIGNMENT')
      OR (p_assignment_rec.resource_list_member_id <> FND_API.G_MISS_NUM AND
	      l_assignment_rec.source_assignment_type = 'OPEN_ASSIGNMENT')
	  OR (p_budget_version_id IS NOT NULL AND
	      p_budget_version_id <> FND_API.G_MISS_NUM AND
          l_assignment_rec.resource_list_member_id IS NOT NULL AND
	      l_assignment_rec.resource_list_member_id <> FND_API.G_MISS_NUM)
              OR (PA_STARTUP.G_Calling_Application = 'PLSQL' AND PA_STARTUP.G_Calling_module = 'AMG')
              THEN

       FOR i IN 1..l_competencies_tbl.COUNT LOOP
       /*
       dbms_output.put_line('PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.COUNT='||PA_ASSIGNMENTS_PUB.g_assignment_id_tbl.COUNT);
       dbms_output.put_line('l_assignment_rec.project_id='||l_assignment_rec.project_id);
       dbms_output.put_line('l_competencies_tbl(1).competence_id='||l_competencies_tbl(1).competence_id);
       dbms_output.put_line('l_competencies_tbl(1).rating_level_id='||l_competencies_tbl(1).rating_level_id);
       dbms_output.put_line('l_competencies_tbl(1).mandatory='||l_competencies_tbl(1).mandatory);
       */
         PA_COMPETENCE_PVT.Add_Competence_Element
         ( p_object_name            => 'OPEN_ASSIGNMENT'
          ,p_object_id              => PA_ASSIGNMENTS_PUB.g_assignment_id_tbl
          ,p_project_id             => l_assignment_rec.project_id
          ,p_competence_id          => l_competencies_tbl(i).competence_id
          ,p_rating_level_id        => l_competencies_tbl(i).rating_level_id
          ,p_mandatory_flag         => l_competencies_tbl(i).mandatory
          ,p_commit                 => p_commit
          ,p_validate_only          => p_validate_only
          ,x_element_rowid          => l_element_rowid
          ,x_element_id             => l_element_id
          ,x_return_status          => l_element_return_status
         );
       END LOOP;
    END IF;

  END IF;



  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;



  EXCEPTION
    WHEN OTHERS THEN

       -- 4537865 : RESET other OUT params also.
	x_new_assignment_id := NULL ;
	x_assignment_number := NULL ;
	x_assignment_row_id := NULL ;

       -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
END Create_Open_Assignment;


PROCEDURE Update_Open_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)
IS

 l_assignment_rec       PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_old_status_code      pa_project_assignments.status_code%TYPE;
 l_old_start_date       pa_project_assignments.start_date%TYPE;
 l_old_end_date         pa_project_assignments.end_date%TYPE;
 l_return_status        VARCHAR2(1);
 l_msg_count            NUMBER;
 l_error_message_code   fnd_new_messages.message_name%TYPE;
 l_msg_data             FND_NEW_MESSAGES.message_text%TYPE;
 l_req_text             FND_NEW_MESSAGES.message_text%TYPE;
 l_proj_req_res_format_id NUMBER;
 l_task_assignment_id_tbl       system.pa_num_tbl_type;
 l_resource_list_member_id_tbl  system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_project_assignment_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_budget_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_struct_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_last_bvid					NUMBER;
 l_update_task_asgmt_id_tbl		system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_update_count					NUMBER;
 l_last_struct_version_id 		NUMBER;
 l_task_version_id_tbl			system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_update_task_version_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();

 l_cur_resource_id 				pa_project_assignments.resource_id%TYPE;
 l_cur_fcst_job_id 				pa_project_assignments.fcst_job_id%TYPE;
 l_cur_exp_org_id 				pa_project_assignments.expenditure_organization_id%TYPE;
 l_cur_expenditure_type 		pa_project_assignments.expenditure_type%TYPE;
 l_cur_project_role_id 			pa_project_assignments.project_role_id%TYPE;
 l_cur_assignment_name 			pa_project_assignments.assignment_name%TYPE;
 l_cur_resource_list_member_id  pa_project_assignments.resource_list_member_id%TYPE;
 l_new_person_id				pa_resource_txn_attributes.person_id%TYPE;
 l_named_role					pa_project_assignments.ASSIGNMENT_NAME%TYPE;

 l_cur_res_format_id pa_res_formats_b.res_format_id%TYPE;
 l_cur_res_type_flag pa_res_formats_b.res_type_enabled_flag%TYPE;
 l_cur_orgn_flag pa_res_formats_b.orgn_enabled_flag%TYPE;
 l_cur_fin_cat_flag pa_res_formats_b.fin_cat_enabled_flag%TYPE;
 l_cur_role_flag pa_res_formats_b.role_enabled_flag%TYPE;

-- l_unlink_flag VARCHAR2(1) := 'N';

  l_resource_list_members_tbl	SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_resource_class_flag_tbl		SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
  l_resource_class_code_tbl		SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_resource_class_id_tbl		SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_res_type_code_tbl			SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_incur_by_res_type_tbl		SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_person_id_tbl				SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_job_id_tbl					SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_person_type_code_tbl		SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_named_role_tbl				SYSTEM.PA_VARCHAR2_80_TBL_TYPE := system.pa_varchar2_80_tbl_type();
  l_bom_resource_id_tbl			SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_non_labor_resource_tbl		SYSTEM.PA_VARCHAR2_20_TBL_TYPE := system.pa_varchar2_20_tbl_type();
  l_inventory_item_id_tbl		SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_item_category_id_tbl		SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_project_role_id_tbl			SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_organization_id_tbl			SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_fc_res_type_code_tbl		SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_expenditure_type_tbl		SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_expenditure_category_tbl	SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_event_type_tbl				SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_revenue_category_code_tbl	SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_supplier_id_tbl				SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_spread_curve_id_tbl			SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_etc_method_code_tbl			SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_mfc_cost_type_id_tbl		SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_incurred_by_res_flag_tbl	SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
  l_incur_by_res_class_code_tbl	SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_incur_by_role_id_tbl		SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_unit_of_measure_tbl			SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_org_id_tbl					SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();
  l_rate_based_flag_tbl			SYSTEM.PA_VARCHAR2_1_TBL_TYPE := system.pa_varchar2_1_tbl_type();
  l_rate_expenditure_type_tbl	SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_rate_func_curr_code_tbl		SYSTEM.PA_VARCHAR2_30_TBL_TYPE := system.pa_varchar2_30_tbl_type();
  l_rate_incurred_by_org_id_tbl	SYSTEM.PA_NUM_TBL_TYPE := system.pa_num_tbl_type();

  l_fcst_job_id_tmp 			 pa_project_assignments.fcst_job_id%TYPE;
  l_expenditure_org_id_tmp 	     pa_project_assignments.expenditure_organization_id%TYPE;
  l_expenditure_type_tmp 		 pa_project_assignments.expenditure_type%TYPE;
  l_project_role_id_tmp 		 pa_project_assignments.project_role_id%TYPE;
  l_assignment_name_tmp 		 pa_project_assignments.assignment_name%TYPE;

 CURSOR   assignment_status_code_csr IS
 SELECT   status_code, start_date, end_date
 FROM     pa_project_assignments
 WHERE    assignment_id  = p_assignment_rec.assignment_id;

 CURSOR get_unlinked_res_asgmts IS
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
 	  AND   ra.resource_list_member_id = l_assignment_rec.resource_list_member_id
	  AND   ra.project_assignment_id = -1
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
 	  AND   ra.resource_list_member_id = l_assignment_rec.resource_list_member_id
	  AND   ra.project_id = l_assignment_rec.project_id
	  AND   ra.project_assignment_id = -1)
 )
 ORDER BY budget_version_id, project_structure_version_id;

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
	  AND   ra.project_assignment_id = l_assignment_rec.assignment_id
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
	  AND   ra.project_assignment_id = l_assignment_rec.assignment_id)
 )
 ORDER BY budget_version_id, project_structure_version_id;

 CURSOR get_res_mand_attributes IS
 SELECT rf.res_format_id, rf.RES_TYPE_ENABLED_FLAG,
        rf.ORGN_ENABLED_FLAG, rf.FIN_CAT_ENABLED_FLAG,
		rf.ROLE_ENABLED_FLAG
 FROM   pa_res_formats_b rf,
        pa_resource_list_members rlm
 WHERE  rlm.res_format_id = rf.res_format_id
 AND    rlm.resource_list_member_id = l_assignment_rec.resource_list_member_id;

 CURSOR get_cur_asgmt_attributes IS
 SELECT resource_id, fcst_job_id, expenditure_organization_id,
        expenditure_type,
        project_role_id, assignment_name,
		resource_list_member_id,
		project_role_id
 FROM   pa_project_assignments
 WHERE  assignment_id = l_assignment_rec.assignment_id;

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment');

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
                     ,x_msg         => 'Beginning of Update_Open_Assignment'
                     ,x_log_level   => li_message_level);
  END IF;


  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Assign the input record to the local variable
  l_assignment_rec := p_assignment_rec;

  --dbms_output.put_line('IN PVT open assignment');

  -- get the current attributes of the project team role
  OPEN  get_cur_asgmt_attributes;
  FETCH get_cur_asgmt_attributes INTO
	    l_cur_resource_id,
	    l_cur_fcst_job_id,
	    l_cur_exp_org_id,
	    l_cur_expenditure_type,
	    l_cur_project_role_id,
	    l_cur_assignment_name,
	    l_cur_resource_list_member_id,
		l_cur_project_role_id;
  CLOSE get_cur_asgmt_attributes;

  IF p_assignment_rec.project_role_id = FND_API.G_MISS_NUM THEN
  	 l_assignment_rec.project_role_id := l_cur_project_role_id;
  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
                     ,x_msg         => 'Old resource list member id='||l_cur_resource_list_member_id
                     ,x_log_level   => li_message_level);
  END IF;

  IF l_cur_resource_list_member_id IS NOT NULL AND
     p_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN

	  -- get the mandatory attributes of planning resource
	  OPEN  get_res_mand_attributes;
	  FETCH get_res_mand_attributes INTO
		    l_cur_res_format_id,
		    l_cur_res_type_flag,
		    l_cur_orgn_flag,
		    l_cur_fin_cat_flag,
		    l_cur_role_flag;
	  CLOSE get_res_mand_attributes;

	 -- check if mandatory attributes are changed
	 IF (l_cur_res_type_flag = 'Y' AND
	  p_assignment_rec.resource_id <> FND_API.G_MISS_NUM AND
	  p_assignment_rec.resource_id <> l_cur_resource_id) OR
	 (l_cur_res_type_flag = 'Y' AND
	  p_assignment_rec.fcst_job_id <> FND_API.G_MISS_NUM AND
	  p_assignment_rec.fcst_job_id <> l_cur_fcst_job_id) OR
	 (l_cur_orgn_flag = 'Y' AND
	  p_assignment_rec.expenditure_organization_id <> FND_API.G_MISS_NUM AND
	  p_assignment_rec.expenditure_organization_id <> l_cur_exp_org_id) OR
	 (l_cur_fin_cat_flag = 'Y' AND
	  p_assignment_rec.expenditure_type <> FND_API.G_MISS_CHAR AND
	  p_assignment_rec.expenditure_type <> l_cur_expenditure_type) OR
	 (l_cur_role_flag = 'Y' AND
	  p_assignment_rec.project_role_id <> FND_API.G_MISS_NUM AND
	  p_assignment_rec.project_role_id <> l_cur_project_role_id) OR
	 (l_cur_role_flag = 'Y' AND
	  p_assignment_rec.assignment_name <> FND_API.G_MISS_CHAR AND
	  p_assignment_rec.assignment_name <> l_cur_assignment_name) THEN
	  --Log Message
	  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
	                     ,x_msg         => 'Mandatory attributes changed'
	                     ,x_log_level   => li_message_level);
	  END IF;

	 l_fcst_job_id_tmp := l_assignment_rec.fcst_job_id;
     IF l_fcst_job_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_fcst_job_id_tmp := NULL;
	 END IF;

	 l_expenditure_org_id_tmp := l_assignment_rec.expenditure_organization_id;
     IF l_expenditure_org_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_expenditure_org_id_tmp := NULL;
	 END IF;

	 l_expenditure_type_tmp := l_assignment_rec.expenditure_type;
     IF l_expenditure_type_tmp = FND_API.G_MISS_CHAR THEN
	  	l_expenditure_type_tmp := NULL;
	 END IF;

	 l_project_role_id_tmp := l_assignment_rec.project_role_id;
     IF l_project_role_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_project_role_id_tmp := NULL;
	 END IF;

	 l_assignment_name_tmp := l_assignment_rec.assignment_name;
     IF l_assignment_name_tmp = FND_API.G_MISS_CHAR THEN
	  	l_assignment_name_tmp := NULL;
	 END IF;

  	 IF P_DEBUG_MODE = 'Y' THEN
   	   pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
       ,x_msg         => 'proj_id='||p_assignment_rec.project_id||
				   	  ' res_format='||l_proj_req_res_format_id||
					  ' job_id='||l_fcst_job_id_tmp
       ,x_log_level   => li_message_level);
 	   pa_debug.write(x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Create_Open_Assignment'
       ,x_msg         => 'org_id='||l_expenditure_org_id_tmp||
				   	  ' exp_type='||l_expenditure_type_tmp||
					  ' role_id='||l_project_role_id_tmp||
					  ' named_role='||l_assignment_name_tmp
       ,x_log_level   => li_message_level);
	 END IF;

	 l_assignment_rec.resource_list_member_id :=
     PA_PLANNING_RESOURCE_UTILS.DERIVE_RESOURCE_LIST_MEMBER (
                                p_project_id              => p_assignment_rec.project_id
                               ,p_res_format_id         => l_cur_res_format_id
                               ,p_job_id                => l_fcst_job_id_tmp
                               ,p_organization_id       => l_expenditure_org_id_tmp
                               ,p_expenditure_type      => l_expenditure_type_tmp
                               ,p_project_role_id       => l_project_role_id_tmp
                               ,p_named_role            => l_assignment_name_tmp);
	 --Log Message
	 IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	 PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
	                    ,x_msg         => 'new resource list member id='||l_assignment_rec.resource_list_member_id
	                    ,x_log_level   => li_message_level);
	 END IF;

	IF l_assignment_rec.resource_list_member_id IS NOT NULL THEN

    -- 1. change the  resource list member in pa_resource_assignments
    --    on the linked task assignments in all working versions.

	 -- if original resource list member on the team role <>
	 -- the rlm returned from the derive API above
	 IF l_assignment_rec.resource_list_member_id <> l_cur_resource_list_member_id THEN

	   OPEN  get_linked_res_asgmts;
	   FETCH get_linked_res_asgmts
	    BULK COLLECT INTO l_task_assignment_id_tbl,
	                      l_task_version_id_tbl,
	  	     		   	  l_budget_version_id_tbl,
						  l_struct_version_id_tbl;
	   CLOSE get_linked_res_asgmts;

/* bug 3730480 - remove call to get_resource_defaults

	   -- get default resource attributes of the new rlm
	   l_resource_list_members_tbl.extend(1);
	   l_resource_list_members_tbl(1) := l_assignment_rec.resource_list_member_id;
	   pa_planning_resource_utils.get_resource_defaults (
		P_resource_list_members   => l_resource_list_members_tbl
	   ,P_project_id			  => l_assignment_rec.project_id
	   ,X_resource_class_flag	  => l_resource_class_flag_tbl
	   ,X_resource_class_code	  => l_resource_class_code_tbl
	   ,X_resource_class_id		  => l_resource_class_id_tbl
	   ,X_res_type_code			  => l_res_type_code_tbl
	   ,X_incur_by_res_type		  => l_incur_by_res_type_tbl
	   ,X_person_id				  => l_person_id_tbl
	   ,X_job_id				  => l_job_id_tbl
	   ,X_person_type_code		  => l_person_type_code_tbl
	   ,X_named_role			  => l_named_role_tbl
	   ,X_bom_resource_id		  => l_bom_resource_id_tbl
	   ,X_non_labor_resource	  => l_non_labor_resource_tbl
	   ,X_inventory_item_id		  => l_inventory_item_id_tbl
	   ,X_item_category_id		  => l_item_category_id_tbl
	   ,X_project_role_id		  => l_project_role_id_tbl
	   ,X_organization_id		  => l_organization_id_tbl
	   ,X_fc_res_type_code		  => l_fc_res_type_code_tbl
	   ,X_expenditure_type		  => l_expenditure_type_tbl
	   ,X_expenditure_category	  => l_expenditure_category_tbl
	   ,X_event_type			  => l_event_type_tbl
	   ,X_revenue_category_code	  => l_revenue_category_code_tbl
	   ,X_supplier_id			  => l_supplier_id_tbl
	   ,X_spread_curve_id		  => l_spread_curve_id_tbl
	   ,X_etc_method_code		  => l_etc_method_code_tbl
	   ,X_mfc_cost_type_id		  => l_mfc_cost_type_id_tbl
	   ,X_incurred_by_res_flag	  => l_incurred_by_res_flag_tbl
	   ,X_incur_by_res_class_code => l_incur_by_res_class_code_tbl
	   ,X_incur_by_role_id		  => l_incur_by_role_id_tbl
	   ,X_unit_of_measure		  => l_unit_of_measure_tbl
	   ,X_org_id				  => l_org_id_tbl
	   ,X_rate_based_flag		  => l_rate_based_flag_tbl
	   ,X_rate_expenditure_type	  => l_rate_expenditure_type_tbl
	   ,X_rate_func_curr_code	  => l_rate_func_curr_code_tbl
--	   ,X_rate_incurred_by_org_id => l_rate_incurred_by_org_id_tbl
	   ,X_msg_data				  => l_msg_data
	   ,X_msg_count				  => l_msg_count
	   ,X_return_status			  => l_return_status
	  );
	  --Log Message
	  IF P_DEBUG_MODE = 'Y' THEN -- Added Debug Profile Option Check for bug#2674619
	  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
	                     ,x_msg         => 'Get resource defaults, status='||l_return_status
	                     ,x_log_level   => li_message_level);
	  END IF;

	 l_named_role := l_named_role_tbl(1);
	 IF l_named_role IS NULL THEN
	   l_named_role := l_assignment_rec.assignment_name;
	 END IF;

bug 3730480 */

	 -- Invoke Update_Planning_Transaction API
	 pa_assignments_pvt.Update_Task_Assignments(
   	  	p_task_assignment_id_tbl  => l_task_assignment_id_tbl
	   ,p_task_version_id_tbl	  => l_task_version_id_tbl
	   ,p_budget_version_id_tbl	  => l_budget_version_id_tbl
	   ,p_struct_version_id_tbl	  => l_struct_version_id_tbl
	   ,p_project_assignment_id	  => l_assignment_rec.assignment_id
	   -- change resource list member
	   ,p_resource_list_member_id => l_assignment_rec.resource_list_member_id
	   ,p_named_role			  => l_assignment_rec.assignment_name
	   ,p_project_role_id		  => l_assignment_rec.project_role_id
	   ,x_return_status           => l_return_status
	 );
	  --Log Message
	  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
	                     ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                     ,x_log_level   => li_message_level);
	  END IF;

	 END IF;--IF l_assignment_rec.resource_list_member_id <> l_cur_resource_list_member_id THEN


	   -- 2. get all unlinked task assignment using the same planning
	   --    resource in the working version and link them to
	   --    this team role.  Also, stamp the assignment name on the
	   --    task assignment's named_role field
	   OPEN  get_unlinked_res_asgmts;
	   FETCH get_unlinked_res_asgmts
	    BULK COLLECT INTO l_task_assignment_id_tbl,
	                      l_task_version_id_tbl,
	  	     		   	  l_budget_version_id_tbl,
						  l_struct_version_id_tbl;
	   CLOSE get_unlinked_res_asgmts;

  	   pa_assignments_pvt.Update_Task_Assignments(
		  p_task_assignment_id_tbl	=> 	l_task_assignment_id_tbl
		 ,p_task_version_id_tbl		=>  l_task_version_id_tbl
		 ,p_budget_version_id_tbl	=>  l_budget_version_id_tbl
		 ,p_struct_version_id_tbl	=>  l_struct_version_id_tbl
		 -- change project_assignment_id to this assignment_id
		 ,p_project_assignment_id 	=>  l_assignment_rec.assignment_id
		 ,p_resource_list_member_id =>  l_assignment_rec.resource_list_member_id
	   	 -- change the named role to this assignment name
	     ,p_named_role				=> 	l_assignment_rec.assignment_name
	 	 ,p_project_role_id			=>	l_assignment_rec.project_role_id
 		 ,x_return_status           =>  l_return_status
	   );
	  --Log Message
	  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
	                     ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                     ,x_log_level   => li_message_level);
	  END IF;

	ELSE --IF l_assignment_rec.resource_list_member_id IS NOT NULL THEN

	   -- break the link between this team role and associated task assignments
	   OPEN  get_linked_res_asgmts;
	   FETCH get_linked_res_asgmts
	    BULK COLLECT INTO l_task_assignment_id_tbl,
	                      l_task_version_id_tbl,
	  	     		   	  l_budget_version_id_tbl,
						  l_struct_version_id_tbl;
	   CLOSE get_linked_res_asgmts;

	   -- change project_assignment_id to NULL
  	   IF l_cur_role_flag = 'Y' THEN
	  	   pa_assignments_pvt.Update_Task_Assignments(
			  p_task_assignment_id_tbl	=> 	l_task_assignment_id_tbl
			 ,p_task_version_id_tbl		=>  l_task_version_id_tbl
			 ,p_budget_version_id_tbl	=>  l_budget_version_id_tbl
			 ,p_struct_version_id_tbl	=>  l_struct_version_id_tbl
			 ,p_project_assignment_id 	=>  -1
	 		 ,x_return_status           =>  l_return_status
		   );
	   ELSE
	  	   pa_assignments_pvt.Update_Task_Assignments(
			  p_task_assignment_id_tbl	=> 	l_task_assignment_id_tbl
			 ,p_task_version_id_tbl		=>  l_task_version_id_tbl
			 ,p_budget_version_id_tbl	=>  l_budget_version_id_tbl
			 ,p_struct_version_id_tbl	=>  l_struct_version_id_tbl
			 ,p_project_assignment_id 	=>  -1
			 ,p_named_role				=>  FND_API.G_MISS_CHAR
	 		 ,x_return_status           =>  l_return_status
		   );
	   END IF;

	   --Log Message
	   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
	                      ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                      ,x_log_level   => li_message_level);
	   END IF;

	END IF; --IF l_assignment_rec.resource_list_member_id IS NOT NULL THEN

   -- IF mandatory attributes are NOT changed
   ELSIF p_assignment_rec.assignment_name <> FND_API.G_MISS_CHAR AND
	  	 p_assignment_rec.assignment_name <> l_cur_assignment_name THEN

	   --Log Message
	   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
		                  ,x_msg         => 'Mandatory attributes not changed'
		                  ,x_log_level   => li_message_level);
	   END IF;

	   OPEN  get_linked_res_asgmts;
	   FETCH get_linked_res_asgmts
	    BULK COLLECT INTO l_task_assignment_id_tbl,
	                      l_task_version_id_tbl,
	  	     		   	  l_budget_version_id_tbl,
						  l_struct_version_id_tbl;
	   CLOSE get_linked_res_asgmts;

	   -- change named_role to p_assignment_rec.assignment_name
  	   pa_assignments_pvt.Update_Task_Assignments(
		  p_task_assignment_id_tbl	=> 	l_task_assignment_id_tbl
		 ,p_task_version_id_tbl		=>  l_task_version_id_tbl
		 ,p_budget_version_id_tbl	=>  l_budget_version_id_tbl
		 ,p_struct_version_id_tbl	=>  l_struct_version_id_tbl
	     ,p_named_role				=> 	l_assignment_rec.assignment_name
	 	 ,p_project_role_id			=>	l_assignment_rec.project_role_id
 		 ,x_return_status           =>  l_return_status
	   );
	   --Log Message
	   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.begin'
	                      ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                      ,x_log_level   => li_message_level);
	   END IF;

	END IF; -- IF mandatory attributes are changed

  END IF;  -- IF l_cur_resource_list_member_id IS NOT NULL ...

  --
  -- Check that mandatory inputs for Open Assignment  record are not null:
  --

  -- Check p_assignment_id IS NOT NULL
  IF p_assignment_rec.assignment_id IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_ASGN_ID_REQUIRED_FOR_ASG'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_req_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;


  --the following validation not required for updating an assignment.


  -- Check p_assignment_name is not null
  IF p_assignment_rec.assignment_name IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_ASGN_NAME_REQUIRED_FOR_ASG'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_req_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;


  --Status code updates and start/end date updates for TEMPLATE REQUIREMENTS ONLY are allowed through this
  --API - status updates and start/end date updates to PROJECT REQUIREMENTS must go through the schedule
  --page.  If this is a template requirement then validate the next allowable status and that
  --start date <= end date

  IF l_assignment_rec.project_id IS NULL or l_assignment_rec.project_id = FND_API.G_MISS_NUM THEN

      OPEN  assignment_status_code_csr;
      FETCH assignment_status_code_csr INTO l_old_status_code
                                           ,l_old_start_date
                                           ,l_old_end_date;
      CLOSE assignment_status_code_csr;

      IF l_old_status_code <> l_assignment_rec.status_code THEN
         --
         -- Check if the new status code is a valid next status code
         --
         IF ('Y' <> PA_PROJECT_STUS_UTILS.Allow_Status_Change( o_status_code  => l_old_status_code
                                                              ,n_status_code  => l_assignment_rec.status_code))THEN
            PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_ASGN_INV_NEXT_STATUS_CODE');
            PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
         END IF;

       END IF;

       --start date <= end_date validation
       IF  l_assignment_rec.start_date > l_assignment_rec.end_date THEN
          PA_UTILS.Add_Message( p_app_short_name => 'PA'
                               ,p_msg_name       => 'PA_INVALID_START_DATE');
          PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       END IF;

    END IF; --project id is null
  --
  --Check p_work_type_id IS NOT NULL
  --
  IF  l_assignment_rec.work_type_id IS NULL THEN
    --dbms_output.put_line('WORK TYPE INVALID');
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_WORK_TYPE_REQUIRED_FOR_ASGN' );
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  END IF;


  --No updates to assignment dates / status allowed through the
  --Update Assignment API.  Must use Schedule APIs.

  -- Get the location id for the p_location_id for the given  location parameters
  -- If the location does not already exsists, then create it
  --However, if country code is not available then no need to get_location at all.

 IF (p_location_country_code IS NOT NULL AND p_location_country_code <> FND_API.G_MISS_CHAR) THEN

  --dbms_output.put_line('location code is '||p_location_country_code);
  PA_LOCATION_UTILS.Get_Location( p_city                => p_location_city
                                 ,p_region              => p_location_region
                                 ,p_country_code        => p_location_country_code
                                 ,x_location_id         => l_assignment_rec.location_id
                                 ,x_error_message_code  => l_error_message_code
                                 ,x_return_status       => l_return_status );

  --dbms_output.put_line('location id is '||l_assignment_rec.location_id);
  --dbms_output.put_line('return status is '||l_return_status);

  IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => l_error_message_code );
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;
 END IF;

/*
-- commenting this out for mass update
-- should not null out location id if
-- l_assignment_rec.location_id = FND_API.G_MISS_NUM

-- for single update, if location_country_name is passed in as null
-- then null out location id (in pa_assignment_pub)

 --Bug 1795160: when user empty the location fields, the location id need to be nulled out.
 --If in self-service mode, and still no location id by now, then set it to NULL
 IF l_assignment_rec.location_id = FND_API.G_MISS_NUM AND PA_STARTUP.G_Calling_Application = 'SELF_SERVICE' THEN
    l_assignment_rec.location_id := NULL;
 END IF;
*/

  --dbms_output.put_line('validate only = '||p_validate_only);
  --dbms_output.put_line('error exists = '||PA_ASSIGNMENTS_PUB.g_error_exists);

  IF p_validate_only = FND_API.G_FALSE AND PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_FALSE
  THEN

    --Log Message
    IF (P_DEBUG_MODE = 'Y') THEN
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment.update_row'
                     ,x_msg         => 'Update Assignment Record in the table'
                     ,x_log_level   => li_message_level);
    END IF;

  --dbms_output.put_line('calling PA_PROJECT_ASSIGNMENTS_PKG.Update_Row');


    PA_PROJECT_ASSIGNMENTS_PKG.Update_Row
    ( p_assignment_row_id           => l_assignment_rec.assignment_row_id
     ,p_assignment_id               => l_assignment_rec.assignment_id
     ,p_record_version_number       => l_assignment_rec.record_version_number
     ,p_assignment_name             => l_assignment_rec.assignment_name
     ,p_assignment_type             => l_assignment_rec.assignment_type
     ,p_multiple_status_flag        => l_assignment_rec.multiple_status_flag
     ,p_status_code                 => l_assignment_rec.status_code
     ,p_staffing_priority_code      => l_assignment_rec.staffing_priority_code
     ,p_project_role_id             => l_assignment_rec.project_role_id
     ,p_description                 => l_assignment_rec.description
     ,p_start_date                  => l_assignment_rec.start_date
     ,p_end_date                    => l_assignment_rec.end_date
     ,p_assignment_effort           => l_assignment_rec.assignment_effort
     ,p_source_assignment_id        => l_assignment_rec.source_assignment_id
     ,p_min_resource_job_level      => l_assignment_rec.min_resource_job_level
     ,p_max_resource_job_level      => l_assignment_rec.max_resource_job_level
     ,p_additional_information      => l_assignment_rec.additional_information
     ,p_work_type_id                => l_assignment_rec.work_type_id
     ,p_revenue_currency_code       => l_assignment_rec.revenue_currency_code
     ,p_revenue_bill_rate           => l_assignment_rec.revenue_bill_rate
     ,p_markup_percent              => l_assignment_rec.markup_percent
     ,p_extension_possible          => l_assignment_rec.extension_possible
     ,p_expense_owner               => l_assignment_rec.expense_owner
     ,p_expense_limit               => l_assignment_rec.expense_limit
     ,p_expense_limit_currency_code => l_assignment_rec.expense_limit_currency_code
     ,p_fcst_tp_amount_type         => l_assignment_rec.fcst_tp_amount_type
     ,p_fcst_job_id                 => l_assignment_rec.fcst_job_id
     ,p_fcst_job_group_id           => l_assignment_rec.fcst_job_group_id
     ,p_expenditure_org_id          => l_assignment_rec.expenditure_org_id
     ,p_expenditure_organization_id => l_assignment_rec.expenditure_organization_id
     ,p_expenditure_type_class      => l_assignment_rec.expenditure_type_class
     ,p_expenditure_type            => l_assignment_rec.expenditure_type
     ,p_location_id                 => l_assignment_rec.location_id
     ,p_calendar_type               => l_assignment_rec.calendar_type
     ,p_calendar_id                 => l_assignment_rec.calendar_id
     ,p_comp_match_weighting        => l_assignment_rec.comp_match_weighting
     ,p_avail_match_weighting       => l_assignment_rec.avail_match_weighting
     ,p_job_level_match_weighting   => l_assignment_rec.job_level_match_weighting
     ,p_search_min_availability     => l_assignment_rec.search_min_availability
     ,p_search_country_code         => l_assignment_rec.search_country_code
     ,p_search_exp_org_struct_ver_id => l_assignment_rec.search_exp_org_struct_ver_id
     ,p_search_exp_start_org_id     => l_assignment_rec.search_exp_start_org_id
     ,p_search_min_candidate_score  => l_assignment_rec.search_min_candidate_score
     ,p_enable_auto_cand_nom_flag   => l_assignment_rec.enable_auto_cand_nom_flag
     ,p_bill_rate_override          => l_assignment_rec.bill_rate_override
     ,p_bill_rate_curr_override     => l_assignment_rec.bill_rate_curr_override
     ,p_markup_percent_override     => l_assignment_rec.markup_percent_override
     ,p_discount_percentage         => l_assignment_rec.discount_percentage    -- Bug 2590938
     ,p_rate_disc_reason_code       => l_assignment_rec.rate_disc_reason_code  -- Bug 2590938
     ,p_tp_rate_override            => l_assignment_rec.tp_rate_override
     ,p_tp_currency_override        => l_assignment_rec.tp_currency_override
     ,p_tp_calc_base_code_override  => l_assignment_rec.tp_calc_base_code_override
     ,p_tp_percent_applied_override => l_assignment_rec.tp_percent_applied_override
     ,p_staffing_owner_person_id    => l_assignment_rec.staffing_owner_person_id
     ,p_resource_list_member_id     => l_assignment_rec.resource_list_member_id  -- FP-M Development                        -- FP.M Development
     ,p_attribute_category          => l_assignment_rec.attribute_category
     ,p_attribute1                  => l_assignment_rec.attribute1
     ,p_attribute2                  => l_assignment_rec.attribute2
     ,p_attribute3                  => l_assignment_rec.attribute3
     ,p_attribute4                  => l_assignment_rec.attribute4
     ,p_attribute5                  => l_assignment_rec.attribute5
     ,p_attribute6                  => l_assignment_rec.attribute6
     ,p_attribute7                  => l_assignment_rec.attribute7
     ,p_attribute8                  => l_assignment_rec.attribute8
     ,p_attribute9                  => l_assignment_rec.attribute9
     ,p_attribute10                 => l_assignment_rec.attribute10
     ,p_attribute11                 => l_assignment_rec.attribute11
     ,p_attribute12                 => l_assignment_rec.attribute12
     ,p_attribute13                 => l_assignment_rec.attribute13
     ,p_attribute14                 => l_assignment_rec.attribute14
     ,p_attribute15                 => l_assignment_rec.attribute15
     ,x_return_status               => x_return_status
 );

  END IF;


  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_Err_Stack;

  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_OPEN_ASSIGNMENT_PVT.Update_Open_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs
END Update_Open_Assignment;



PROCEDURE Delete_Open_Assignment
( p_assignment_row_id           IN     ROWID
 ,p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE       := FND_API.G_MISS_NUM
 ,p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2                                        := FND_API.G_MISS_NUM
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

 l_return_status  	VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
 l_msg_count      	NUMBER;
 l_msg_count_sum 	NUMBER;
 l_msg_data       	VARCHAR2(2000);
 l_competency_tbl 	PA_HR_COMPETENCE_UTILS.competency_tbl_typ;
 l_no_of_competencies   NUMBER;
 l_error_message_code   fnd_new_messages.message_name%TYPE;
 l_check_id_flag        VARCHAR2(1);
 l_action_set_id        NUMBER;
 l_record_version_number NUMBER;

 -- get advertisement action set details
 CURSOR get_action_set IS
 SELECT action_set_id, record_version_number
   FROM pa_action_sets
  WHERE object_id = p_assignment_id
    AND object_type = 'OPEN_ASSIGNMENT'
    AND action_set_type_code = 'ADVERTISEMENT'
    AND status_code <> 'DELETED';

BEGIN
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_OPEN_ASSIGNMENT_PVT.Delete_Open_Assignment');

  --Log Message
  IF (P_DEBUG_MODE = 'Y') THEN
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Delete_Open_Assignment.begin'
                     ,x_msg         => 'Beginning of Delete_Open_Assignment'
                     ,x_log_level   => li_message_level);
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF p_validate_only = FND_API.G_FALSE AND PA_ASSIGNMENTS_PUB.g_error_exists <> FND_API.G_TRUE THEN

     IF p_calling_module <> 'TEMPLATE_REQUIREMENT' THEN

     --Log Message
     IF (P_DEBUG_MODE = 'Y') THEN
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Delete_Open_Assignment.delete_schedule'
                        ,x_msg         => 'Deleting Open Assignment schedules'
                        ,x_log_level   => li_message_level);
     END IF;

     -- Delete all the child shedule records before deleting the parent open assignment record
     -- unless this is a template requirement.  No schedules exists for template requirements.

        PA_SCHEDULE_PVT.Delete_Asgn_Schedules
            ( p_assignment_id   => p_assignment_id
	     ,p_perm_delete     => FND_API.G_TRUE    --Added for bug 4389372
             ,x_return_status   => l_return_status
             ,x_msg_count       => l_msg_count
             ,x_msg_data        => l_msg_data
             );

     END IF; --calling module <> template requirement

     --Delete the advertisement action set
     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

       -- Bug 2497298: PJ.J:B3:GEN: DELETE TEAM TEMPLATE GIVES SQLEXCEPTION
       -- Do not delete action set if requirement does not have an
       -- associated action set
       OPEN get_action_set;
        FETCH get_action_set INTO l_action_set_id, l_record_version_number;
        IF get_action_set%NOTFOUND THEN
          CLOSE get_action_set;
        ELSE

          PA_ACTION_SETS_PUB.Delete_Action_Set (
             p_init_msg_list          => FND_API.G_FALSE -- 5130421
            ,p_action_set_id          => l_action_set_id
            ,p_action_set_type_code   => 'ADVERTISEMENT'
            ,p_object_id              => p_assignment_id
            ,p_object_type            => 'OPEN_ASSIGNMENT'
            ,p_record_version_number  => l_record_version_number
            ,p_commit                 => p_commit
            ,p_validate_only          => p_validate_only
            ,x_return_status          => l_return_status
            ,x_msg_count              => l_msg_count
            ,x_msg_data               => l_msg_data );

	  CLOSE get_action_set;
       END IF;

     END IF;


     --Delete related candidate records
     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
       PA_CANDIDATE_PUB.Delete_Candidates (p_assignment_id   => p_assignment_id
                                          ,x_return_status   => l_return_status
                                          ,x_msg_count       => l_msg_count
                                          ,x_msg_data        => l_msg_data );
     END IF;

     --l_return_status is initialized to success.
     IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

        --dbms_output.put_line('Getting Competency Table');
        --Delete the Competencies associated with the assignment
        --Get the Competencies table first

        PA_HR_COMPETENCE_UTILS.Get_Competencies
        ( p_object_name           => 'OPEN_ASSIGNMENT'
         ,p_object_id             => p_assignment_id
         ,x_competency_tbl        => l_competency_tbl
         ,x_no_of_competencies    => l_no_of_competencies
         ,x_error_message_code    => l_error_message_code
         ,x_return_status         => l_return_status);

        IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

            --Delete the Competencies Elements

            l_msg_count_sum := 0;

            --dbms_output.put_line('Start Deleting Competencies');
/* A temporary fix:
   Need to avoid the LOV ID clearing check implemented in most validation packages.
   Since only the ids are passed in and not the names.
*/

l_check_id_flag := PA_STARTUP.G_Check_ID_Flag;
IF PA_STARTUP.G_Calling_Application = 'SELF_SERVICE' THEN
   PA_STARTUP.G_Check_ID_Flag := 'N';
END IF;

            --If the competency table is not empty for this assignment then delete
            IF (l_competency_tbl.FIRST IS NOT NULL) THEN

	       FOR i IN l_competency_tbl.FIRST .. l_competency_tbl.LAST LOOP

                  --Log Message
		  IF (P_DEBUG_MODE = 'Y') THEN
                  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Delete_Open_Assignment.del_competency'
                                  ,x_msg         => 'Deleting Requirement Competencies.'
                                  ,x_log_level   => li_message_level);
		  END IF;

                   PA_COMPETENCE_PUB.Delete_Competence_Element
                     ( p_object_name           => 'OPEN_ASSIGNMENT'
	              ,p_object_id             => p_assignment_id
                      ,p_competence_id         => l_competency_tbl(i).competence_id
                      ,p_element_id            => l_competency_tbl(i).competence_element_id
                      ,p_object_version_number => l_competency_tbl(i).object_version_number
                      ,x_return_status         => l_return_status
                      ,x_msg_count             => l_msg_count
                      ,x_msg_data              => l_msg_data);

               l_msg_count_sum := l_msg_count_sum + l_msg_count;

            END LOOP;  --loop through competence table

          END IF; --competency tbl is not null

        IF (l_msg_count_sum > 0 ) THEN
             PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
        ELSE

           --Log Message
	   IF (P_DEBUG_MODE = 'Y') THEN
           PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_OPEN_ASSIGNMENT_PVT.Delete_Open_Assignment.del_asgmt'
                     ,x_msg         => 'Deleting Requirement Record'
                     ,x_log_level   => li_message_level);
           END IF;


            -- Delete the master record
            PA_PROJECT_ASSIGNMENTS_PKG.Delete_Row
            ( p_assignment_row_id     => p_assignment_row_id
             ,p_assignment_id         => p_assignment_id
             ,p_record_version_number => p_record_version_number
             ,x_return_status         => x_return_status);

        END IF;--end of l_msg_count_sum > 0

--set the global check_id_flag back to the orignal
PA_STARTUP.G_Check_ID_Flag := l_check_id_flag;

      ELSE
           PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code);
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
      END IF;  --success getting the competencies

   ELSE

      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => 'PA_FAILED_TO_DEL_ASGN_SCHEDULE');
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

   END IF;  --success deleting the schedule

  END IF; --validate only is false and no errors exist


  -- If g_error_exists is TRUE then set the x_return_status to 'E'

  IF PA_ASSIGNMENTS_PUB.g_error_exists = FND_API.G_TRUE  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;

  END IF;

  EXCEPTION
    WHEN OTHERS THEN

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_OPEN_ASSIGNMENT_PVT.Delete_Open_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;
END Delete_Open_Assignment;
--
--
END pa_open_assignment_pvt;

/
