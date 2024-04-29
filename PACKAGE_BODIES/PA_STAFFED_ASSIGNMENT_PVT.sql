--------------------------------------------------------
--  DDL for Package Body PA_STAFFED_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STAFFED_ASSIGNMENT_PVT" AS
/*$Header: PARDPVTB.pls 120.8.12010000.9 2010/05/02 21:57:49 nisinha ship $*/
--
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N'); /* Added Debug Profile Option  variable initialization for bug#2674619 */
li_message_level NUMBER := 1;

PROCEDURE Create_Staffed_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_asgn_creation_mode          IN     VARCHAR2                                        := 'FULL'
 ,p_unfilled_assignment_status  IN     pa_project_assignments.status_code%TYPE         := FND_API.G_MISS_CHAR
 ,p_resource_source_id          IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_sum_tasks_flag				IN	   VARCHAR2										   := FND_API.G_FALSE  -- FP.M Development
 ,p_budget_version_id			IN	   pa_resource_assignments.budget_version_id%TYPE  := FND_API.G_MISS_NUM
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_new_assignment_id           OUT    NOCOPY pa_project_assignments.assignment_id%TYPE  --File.Sql.39 bug 4440895
 ,x_assignment_row_id           OUT    NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_resource_id                 OUT    NOCOPY pa_resources.resource_id%TYPE  --File.Sql.39 bug 4440895
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 )
IS

 l_assignment_rec          PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_source_assignment_rec   PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 l_schedule_basis_flag     VARCHAR2(1);
 l_msg_count               NUMBER;
 l_msg_data                VARCHAR2(2000);
 l_new_open_asgn_count     NUMBER := 0;
 l_new_open_asgn_id        pa_project_assignments.assignment_id%TYPE;
 l_new_open_asgn_number    pa_project_assignments.assignment_number%TYPE;
 l_new_open_asgn_row_id    ROWID;
 l_return_status           VARCHAR2(1);
 l_ret_code                VARCHAR2(1);
 l_system_status_code      pa_project_statuses.project_system_status_code%TYPE;
 l_cc_ok                   VARCHAR2(1);
 l_error_message_code      VARCHAR2(2000);
 l_wf_type                 VARCHAR2(80);
 l_wf_item_type            VARCHAR2(2000);
 l_wf_process              VARCHAR2(2000);
 l_pp_assignment_id        NUMBER;
 l_resource_source_id      NUMBER;
 l_project_manager_person_id   NUMBER ;
 l_project_manager_name        VARCHAR2(200);
 l_project_party_id            NUMBER ;
 l_project_role_id             NUMBER ;
 l_project_role_name           VARCHAR2(80);
 l_project_status_code         pa_project_statuses.project_status_code%TYPE;
 l_project_status_name         pa_project_statuses.project_status_name%TYPE;
 l_assignment_status_name      pa_project_statuses.project_status_name%TYPE;
 l_asgn_text                   VARCHAR2(30);
 l_allow_asgmt                 VARCHAR2(1);
 l_work_type_id                NUMBER;
 l_raw_revenue                 NUMBER;
 l_project_parties_error_exists   VARCHAR2(1) := FND_API.G_FALSE;
 l_check_resource              VARCHAR2(1);
 l_proj_asgmt_res_format_id    NUMBER;
 l_person_id                   NUMBER;
 l_task_assignment_id_tbl      system.pa_num_tbl_type  := system.pa_num_tbl_type();
 l_project_assignment_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_named_role_tbl               system.PA_VARCHAR2_80_TBL_TYPE := system.PA_VARCHAR2_80_TBL_TYPE();
 l_proj_req_res_format_id       NUMBER;
 l_budget_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_struct_version_id_tbl        system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_last_bvid					NUMBER;
 l_update_task_asgmt_id_tbl		system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_update_count					NUMBER;
 l_last_struct_version_id 		NUMBER;
 l_task_version_id_tbl			system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_update_task_version_id_tbl   system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_resource_organization_id     NUMBER;

 l_person_id_tmp 				 NUMBER;
 l_fcst_job_id_tmp 			 pa_project_assignments.fcst_job_id%TYPE;
 l_expenditure_type_tmp 		 pa_project_assignments.expenditure_type%TYPE;
 l_project_role_id_tmp 		 pa_project_assignments.project_role_id%TYPE;
 l_assignment_name_tmp 		 pa_project_assignments.assignment_name%TYPE;
 l_person_type_code			 Varchar2(30);
 l_future_dated_emp          Varchar2(1);
 l_future_term_wf_flag  pa_resources.future_term_wf_flag%TYPE := NULL;  -- Added for Bug 6056112

 CURSOR get_resource_source_id IS
 SELECT person_id
 FROM   pa_resource_txn_attributes
 WHERE  resource_id = l_assignment_rec.resource_id;

/* Created for bug 2381199 */
CURSOR get_system_status IS
SELECT project_system_status_code
FROM PA_PROJECT_STATUSES
WHERE project_status_code = l_assignment_rec.status_code;
/* Created for bug 2381199 */

-- Bottom Up Flow
CURSOR get_bu_resource_assignments IS
SELECT ra.resource_assignment_id, ra.wbs_element_version_id, bv.budget_version_id, bv.project_structure_version_id
FROM  PA_RESOURCE_ASSIGNMENTS ra
     ,PA_BUDGET_VERSIONS bv
     ,PA_PROJ_ELEM_VER_STRUCTURE evs
 WHERE ra.project_id = bv.project_id
 AND   bv.project_id = evs.project_id
 AND   bv.budget_type_code IS NULL  -- added for bug 7492618
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
          AND   bv.budget_type_code IS NULL  -- added for bug 7492618
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
	  AND   bv.budget_type_code IS NULL  -- added for bug 7492618
	  AND   ra.budget_version_id = bv.budget_version_id
	  AND   bv.project_structure_version_id = evs.element_version_id
 	  AND   ra.resource_list_member_id = l_assignment_rec.resource_list_member_id
	  AND   ra.project_id = l_assignment_rec.project_id
	  AND   ra.project_assignment_id = -1)
 )
 ORDER BY budget_version_id, project_structure_version_id;

 -- get the resource's organization in HR
 CURSOR get_resource_organization IS
 SELECT resource_organization_id
 FROM pa_resources_denorm
 WHERE l_assignment_rec.start_date BETWEEN resource_effective_start_date AND resource_effective_end_date
 AND resource_id = l_assignment_rec.resource_id;

 CURSOR check_future_dated_employee IS
 SELECT 'X'
 FROM 	per_all_people_f
 WHERE 	person_id = l_person_id_tmp
 AND 	effective_start_date <= sysdate
 AND 	rownum = 1;

-- 5130421 : Added the following variables
l_expenditure_type_tmp1  pa_project_assignments.expenditure_type%TYPE;
l_expenditure_type_class_tmp  pa_project_assignments.expenditure_type_class%TYPE;
l_fcst_tp_amount_type_tmp     pa_project_assignments.fcst_tp_amount_type%TYPE;
l_apprvl_status_code	      PA_PROJECT_ASSIGNMENTS.APPRVL_STATUS_CODE%TYPE;
-- 5130421 : End

BEGIN

  -- 4537865 : Initialize the return_status
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment');
  --dbms_output.put_line('create staffed assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment.begin'
                     ,x_msg         => 'Beginning of Create_Staff_Assignment'
                     ,x_log_level   => 5);
  END IF;
  --
  -- Assign the record to the local variable
  --
  l_assignment_rec := p_assignment_rec;


  --
  --Get assignment text from message to be used as values for token
  --
  l_asgn_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_TEXT');


  --
  -- Check that mandatory inputs for Staffed Assignment record are not null
  --
  --
  -- Check that mandatory project id exists
  --
  IF (l_assignment_rec.project_id IS NULL OR l_assignment_rec.project_id = FND_API.G_MISS_NUM) THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_ID_REQUIRED_FOR_ASGN'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_asgn_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    RETURN;
  END IF;

  --
  -- Check that mandatory assignment name exists
  --
  IF l_assignment_rec.assignment_name IS NULL OR
     l_assignment_rec.assignment_name = FND_API.G_MISS_CHAR THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_NAME_REQUIRED_FOR_ASGN');
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  --  Check that mandatory project role exists
  --
  IF l_assignment_rec.project_role_id IS NULL
     OR l_assignment_rec.project_role_id = FND_API.G_MISS_NUM THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_ROLE_REQUIRED_FOR_ASGN'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_asgn_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  --Check p_work_type_id IS NOT NULL
  --
  IF  l_assignment_rec.work_type_id IS NULL
      OR l_assignment_rec.work_type_id = FND_API.G_MISS_NUM
	  OR l_assignment_rec.work_type_id = 0 THEN

    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_WORK_TYPE_REQUIRED_FOR_ASGN' );
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  ELSE
    --
    --check for indirect project, only non-billable work types
    --
    PA_WORK_TYPE_UTILS.CHECK_WORK_TYPE (
 	P_WORK_TYPE_ID             =>  l_assignment_rec.work_type_id
 	,P_PROJECT_ID               =>  l_assignment_rec.project_id
        ,P_TASK_ID                  =>  NULL
 	,X_RETURN_STATUS            =>  l_return_status
 	,X_ERROR_MESSAGE_CODE       =>  l_error_message_code);
    IF l_return_status = FND_API.G_RET_STS_ERROR  THEN
      PA_UTILS.Add_Message( p_app_short_name => 'PA'
                           ,p_msg_name       => l_error_message_code );
      PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    END IF;

  END IF;

  --
  -- Check valid starting status
  --
  IF (PA_PROJECT_STUS_UTILS.Is_Starting_Status( x_project_status_code => p_assignment_rec.status_code)) = 'N' THEN
    PA_UTILS.Add_Message( p_app_short_name  => 'PA'
                         ,p_msg_name        => 'PA_INVALID_ASGN_STARTING_STUS'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_asgn_text);
  PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  -- Check Action allowed status (check that it  is allowed to have a staffed assignment for a project or open assignment)

  -- IF an staffed assignment for a project
  IF p_assignment_rec.project_id is NOT NULL THEN

     l_allow_asgmt := PA_ASSIGNMENT_UTILS.is_asgmt_allow_stus_ctl_check
                                                      (p_asgmt_status_code => l_assignment_rec.status_code,
                                                       p_project_id => l_assignment_rec.project_id,
                                                       p_add_message => 'Y');

     IF l_allow_asgmt = 'N' THEN
             PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
             RETURN; -- Fix for bug#9033815
     END IF; --l_allow_asgmt := 'N'

  END IF; --p_assignment_rec.project_id is NOT NULL

  --LOCATION

  --  Rules:
  --  If all the location input parameters are null then default location from project
  --  If location details are passed then get the location id for the for the given  location parameters
  --  If the location does not already exist then create it
  --
  IF  (l_assignment_rec.location_id IS NULL OR l_assignment_rec.location_id = FND_API.G_MISS_NUM)
      AND (p_location_city IS NULL OR p_location_city = FND_API.G_MISS_CHAR)
      AND (p_location_region IS NULL OR p_location_region = FND_API.G_MISS_CHAR)
      AND (p_location_country_code IS NULL OR p_location_country_code = FND_API.G_MISS_CHAR)
   THEN

--bug 1795160: no need to get location from project, location not required.
/*
   SELECT location_id
   INTO   l_assignment_rec.location_id
   FROM   pa_projects_all
   WHERE  project_id = l_assignment_rec.project_id;
*/
   --Log Message
   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment.location'
                     ,x_msg         => 'No need to get location from project'
                     ,x_log_level   => 5);
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
         PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => l_error_message_code );
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  END IF;

  --
  -- Resource name to id is already done in the public API
  --
  -- Get the resource_id and project_parties_id for a given resource_source_id
  -- Schedule_flag default value is 'N'. The value will be'Y' when
  --  an assignment exists for that person and role combination.
  --

--dbms_output.put_line(l_assignment_rec.project_id);
--dbms_output.put_line(l_assignment_rec.project_role_id);
--dbms_output.put_line('resource source id' ||p_resource_source_id);
--dbms_output.put_line(l_assignment_rec.start_date);
--dbms_output.put_line(l_assignment_rec.end_date);
--dbms_output.put_line('project_party_id' || l_assignment_rec.project_party_id);

--dbms_output.put_line('resource source id is '||p_resource_source_id);



  l_resource_source_id := p_resource_source_id;

--Additional Check: If Project Id is not present, no need to run the following program that depends on it.
 IF l_assignment_rec.project_id IS NOT NULL AND
    l_assignment_rec.project_id <> FND_API.G_MISS_NUM THEN

  --If resource id exist, get the resource_source_id, and use it to create project party
  IF (l_assignment_rec.resource_id IS NOT NULL AND l_assignment_rec.resource_id <> FND_API.G_MISS_NUM) AND
     (l_resource_source_id IS NULL OR l_resource_source_id =FND_API.G_MISS_NUM) THEN

     --Log Message
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment.res_source_id'
                     ,x_msg         => 'Getting Resource Source Id'
                     ,x_log_level   => 5);
      END IF;
      OPEN get_resource_source_id;
      FETCH get_resource_source_id INTO l_resource_source_id;
      CLOSE get_resource_source_id;
  END IF;


  IF (l_assignment_rec.project_party_id = FND_API.G_MISS_NUM OR l_assignment_rec.project_party_id IS NULL) AND
     (l_assignment_rec.project_role_id IS NOT NULL AND l_assignment_rec.project_role_id <> FND_API.G_MISS_NUM) AND
     (l_resource_source_id IS NOT NULL AND l_resource_source_id <>FND_API.G_MISS_NUM) THEN

--dbms_output.put_line('*****calling create_project_party');
--dbms_output.put_line('*****resource_source_id:'||l_resource_source_id);
--dbms_output.put_line('*****resource_id:'||l_assignment_rec.resource_id);

     --Log Message
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment.project_party'
                     ,x_msg         => 'Creating Project Party'
                     ,x_log_level   => 5);
     END IF;

  /* PA_PROJECT_PARTIES_PVT.Create_Project_Party
      (  p_object_id            => l_assignment_rec.project_id
        ,p_object_type          => 'PA_PROJECTS'
        ,p_project_id           => l_assignment_rec.project_id
        ,p_resource_type_id     => 101
        ,p_project_role_id      => l_assignment_rec.project_role_id
        ,p_resource_source_id   => l_resource_source_id
        ,p_start_date_active    => l_assignment_rec.start_date
        ,p_scheduled_flag       => 'Y'
        ,p_calling_module       => 'ASSIGNMENT'
        ,p_project_end_date     => NULL
        ,p_end_date_active      => l_assignment_rec.end_date
        ,p_validate_only        => p_validate_only
        ,p_commit               => FND_API.G_FALSE
        ,x_project_party_id     => l_assignment_rec.project_party_id
        ,x_resource_id          => l_assignment_rec.resource_id
        ,x_assignment_id        => l_pp_assignment_id
        ,x_wf_type              => l_wf_type
        ,x_wf_item_type         => l_wf_item_type
        ,x_wf_process           => l_wf_process
        ,x_return_status        => x_return_status
        ,x_msg_count            => l_msg_count
        ,x_msg_data             => l_msg_data
      );
  */ -- Commented this call for Bug 6631033
 	 /* Added the call below for Bug 6631033. This is the same API being called from
 	    Add key Members page */
 	      PA_PROJECT_PARTIES_PUB.Create_Project_Party_Wrp
 	       (  p_commit               => FND_API.G_FALSE
 	         ,p_validate_only        => p_validate_only
 	         ,p_object_id            => l_assignment_rec.project_id
 	         ,p_object_type          => 'PA_PROJECTS'
 	         ,p_project_role_id      => l_assignment_rec.project_role_id
 	         ,p_resource_type_id     => 101
 	         ,p_resource_source_id   => l_resource_source_id
 	         ,p_start_date_active    => l_assignment_rec.start_date
 	         ,p_scheduled_flag       => 'Y'
 	         ,p_calling_module       => 'ASSIGNMENT'
 	         ,p_project_id           => l_assignment_rec.project_id
 	         ,p_project_end_date     => NULL
 	         ,p_end_date_active      => l_assignment_rec.end_date
 	         ,p_mgr_validation_type  => 'SS'
 	         ,x_project_party_id     => l_assignment_rec.project_party_id
 	         ,x_resource_id          => l_assignment_rec.resource_id
 	         ,x_assignment_id        => l_pp_assignment_id
 	         ,x_wf_type              => l_wf_type
 	         ,x_wf_item_type         => l_wf_item_type
 	         ,x_wf_process           => l_wf_process
 	         ,x_return_status        => x_return_status
 	         ,x_msg_count            => l_msg_count
 	         ,x_msg_data             => l_msg_data
 	       );
 	 /* End of code chnage for Bug 6631033 */

  	 IF P_DEBUG_MODE = 'Y' THEN
     	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
        ,x_msg         => 'create project party,status='||x_return_status
        ,x_log_level   => li_message_level);
	 END IF;


	 x_resource_id := l_assignment_rec.resource_id;
--dbms_output.put_line('proj party return status is '||x_return_status);
--dbms_output.put_line('proj party resource id is '||l_assignment_rec.resource_id);
--dbms_output.put_line('proj party id is '||l_assignment_rec.project_party_id);
--dbms_output.put_line('number of error '||l_msg_count);

     IF (x_return_status <>FND_API.G_RET_STS_SUCCESS) THEN
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
       l_project_parties_error_exists := FND_API.G_TRUE;
     END IF;

  END IF; --end of create project party check

  --Assign out parameter: resource id
  IF (l_assignment_rec.resource_id <> FND_API.G_MISS_NUM) THEN
    x_resource_id := l_assignment_rec.resource_id;
  END IF;

  --Bug 2229861: Check if the resource records are pulled into
  -- pa_resources_denorm table on the assignment start date
  l_check_resource := FND_API.G_RET_STS_SUCCESS;

  PA_RESOURCE_UTILS.Validate_Person (
           p_person_id      => l_resource_source_id
          ,p_start_date     => l_assignment_rec.start_date
          ,x_return_status  => l_check_resource
  );
  IF P_DEBUG_MODE = 'Y' THEN
  	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
        ,x_msg         => 'validate person, status='||l_check_resource
        ,x_log_level   => li_message_level);
  END IF;

  IF l_check_resource <> FND_API.G_RET_STS_SUCCESS THEN
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
    -- bug 4091194 : This person is invalid for the assignment.
	-- Set it to null to avoid further process.
	l_assignment_rec.resource_id := NULL;
  END IF;

  --Get utilization defaults before creating requirement/assignment
  --IF it has not been defaulted already OR
  --IF it is copying from an assignment into a requirement AND
  --IF IT IS NOT a template requirement.
  IF (((l_assignment_rec.fcst_tp_amount_type IS NULL) OR
     (l_assignment_rec.fcst_tp_amount_type = FND_API.G_MISS_CHAR) OR
     (p_asgn_creation_mode = 'COPY' AND l_assignment_rec.source_assignment_type <> 'OPEN_ASSIGNMENT')) AND
     (l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM)) THEN

    --dbms_output.put_line('calling assignment default');
    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENTS_PVT.Create_Assignment.utilization_defaults'
                     ,x_msg         => 'Getting Utilization Defaults.'
                     ,x_log_level   => 5);
    END IF;

    PA_FORECAST_ITEMS_UTILS.Get_Assignment_Default(
                                  p_assignment_type             => l_assignment_rec.assignment_type,
                                  p_project_id                  => l_assignment_rec.project_id,
                                  p_project_role_id             => l_assignment_rec.project_role_id,
                                  p_work_type_id                => l_assignment_rec.work_type_id,
                                  x_work_type_id                => l_work_type_id,
                                  x_default_tp_amount_type      => l_fcst_tp_amount_type_tmp, -- 5130421
                                  x_default_job_group_id        => l_assignment_rec.fcst_job_group_id,
                                  x_default_job_id              => l_assignment_rec.fcst_job_id,
                                  x_org_id                      => l_assignment_rec.expenditure_org_id,
                                  x_carrying_out_organization_id=> l_assignment_rec.expenditure_organization_id,
                                  x_default_assign_exp_type     => l_expenditure_type_tmp1, -- 5130421
                                  x_default_assign_exp_type_cls => l_expenditure_type_class_tmp, -- 5130421
                                  x_return_status               => l_return_status,
                                  x_msg_count                   => l_msg_count,
                                  x_msg_data                    => l_msg_data
                                  );

  -- Bug 5130421 : Expenditure type and class can be passed in, so don't default if passed from PLSQL
  IF PA_STARTUP.G_Calling_Application = 'PLSQL' AND l_assignment_rec.expenditure_type IS NOT NULL AND l_assignment_rec.expenditure_type <> FND_API.G_MISS_CHAR
  AND l_assignment_rec.expenditure_type_class IS NOT NULL AND l_assignment_rec.expenditure_type_class IS NOT NULL
  THEN
        null;
  ELSE
        l_assignment_rec.expenditure_type:=l_expenditure_type_tmp1;
        l_assignment_rec.expenditure_type_class:=l_expenditure_type_class_tmp;
  END IF;

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
    END IF;
    l_assignment_rec.fcst_tp_amount_type := l_fcst_tp_amount_type_tmp;
  -- Bug 5130421 : End

  IF P_DEBUG_MODE = 'Y' THEN
  pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
                ,x_msg         => 'work_type_id='||l_work_type_id||
								  ' tp_amount_type='||l_assignment_rec.fcst_tp_amount_type||
								  ' job_group_id='||l_assignment_rec.fcst_job_group_id
                ,x_log_level   => li_message_level);

  pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
                ,x_msg         => 'job_id='||l_assignment_rec.fcst_job_id||
								  ' org_id='||l_assignment_rec.expenditure_org_id||
								  ' carry_out_org_id='||l_assignment_rec.expenditure_organization_id
                ,x_log_level   => li_message_level);

  pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
                ,x_msg         => 'exp_type='||l_assignment_rec.expenditure_type||
								  ' exp_type_cls='||l_assignment_rec.expenditure_type_class||
								  ' return_status='||l_return_status
                ,x_log_level   => li_message_level);
  END IF;

    --dbms_output.put_line('after assignment default:'|| l_return_status);

  END IF;

  --
  -- Get bill rate and bill rate currency code, and markup percent
  -- if this is not an admin assignment
  --
  IF (l_assignment_rec.project_id IS NOT NULL AND l_assignment_rec.project_id <> FND_API.G_MISS_NUM) AND
     l_project_parties_error_exists <> FND_API.G_TRUE AND
     l_check_resource = FND_API.G_RET_STS_SUCCESS AND
     l_assignment_rec.assignment_type <> 'STAFFED_ADMIN_ASSIGNMENT' AND
     l_resource_source_id IS NOT NULL THEN

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_ASSIGNMENT_PVT.Create_Assignment.bill_rate'
                             ,x_msg         => 'Getting Revenue Bill Rate'
                             ,x_log_level   => 5);
    END IF;
    --dbms_output.put_line('before get rev amt');

    PA_FORECAST_REVENUE.Get_Rev_Amt(
           p_project_id            => l_assignment_rec.project_id
          ,p_quantity   	         => 0
          ,p_person_id             => l_resource_source_id
          ,p_item_date             => l_assignment_rec.start_date
          ,p_forecast_job_id       => l_assignment_rec.fcst_job_id
          ,p_forecast_job_group_id => l_assignment_rec.fcst_job_group_id
          ,p_expenditure_org_id    => NULL
          ,p_expenditure_organization_id => NULL
          ,p_check_error_flag      => 'N'
          ,x_bill_rate             => l_assignment_rec.revenue_bill_rate
          ,x_raw_revenue           => l_raw_revenue
          ,x_rev_currency_code     => l_assignment_rec.revenue_currency_code
          ,x_markup_percentage     => l_assignment_rec.markup_percent
          ,x_return_status         => l_return_status
          ,x_msg_count             => l_msg_count
          ,x_msg_data              => l_msg_data);
    --dbms_output.put_line('after get rev amt');

  END IF;
  IF P_DEBUG_MODE = 'Y' THEN
  	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
        ,x_msg         => 'get_rev_amt done'
        ,x_log_level   => li_message_level);
  END IF;

  -- FP.M Development
  IF (p_assignment_rec.resource_list_member_id = FND_API.G_MISS_NUM OR
  	  p_assignment_rec.resource_list_member_id IS NULL) AND
      p_assignment_rec.project_id <> FND_API.G_MISS_NUM AND
	  l_assignment_rec.resource_id IS NOT NULL THEN
     begin

     SELECT proj_asgmt_res_format_id
     INTO   l_proj_asgmt_res_format_id
     FROM   PA_PROJECTS_ALL
     WHERE  project_id = p_assignment_rec.project_id;

  	 IF P_DEBUG_MODE = 'Y' THEN
     	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
           ,x_msg         => 'resource_id='||l_assignment_rec.resource_id
           ,x_log_level   => li_message_level);
	 END IF;

     SELECT person_id
     INTO   l_person_id
     FROM   pa_resources_denorm
     WHERE  resource_id = l_assignment_rec.resource_id
     AND    rownum = 1;

     exception
     when others then
     null;
     end;

     IF l_proj_asgmt_res_format_id = FND_API.G_MISS_NUM THEN
	  	l_proj_asgmt_res_format_id := NULL;
	 END IF;

	 l_person_id_tmp := l_person_id;
     IF l_person_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_person_id_tmp := NULL;
	 END IF;

	 l_fcst_job_id_tmp := l_assignment_rec.fcst_job_id;
     IF l_fcst_job_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_fcst_job_id_tmp := NULL;
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

	 -- For Staffed Assignment only, get organization from resource before
	 -- deriving planning resources
	 OPEN get_resource_organization;
	 FETCH get_resource_organization INTO l_resource_organization_id;
	 CLOSE get_resource_organization;

	 -- Whenever we call Derive_resource_list_member for staffed assignment
	 -- by passing in person_id, the job_id and person_type are required to pass in.

  /* Start of Changes for Bug 6056112 */
	 SELECT nvl(future_term_wf_flag,'N')
	 INTO l_future_term_wf_flag
	 FROM pa_resources
	 WHERE resource_id = l_assignment_rec.resource_id;

  IF (nvl(l_future_term_wf_flag,'N') = 'Y') THEN

	 SELECT job_id
	 INTO         l_fcst_job_id_tmp
	 FROM  pa_resources_denorm prd
	 WHERE prd.person_id = l_person_id_tmp
	 AND   l_assignment_rec.start_date BETWEEN prd.resource_effective_start_date
	 AND     prd.resource_effective_end_date ;

	 SELECT decode(nvl(peo.employee_number,0), 0,'CWK','EMP')
	 INTO        l_person_type_code
	 FROM  per_all_people_f peo
	 WHERE peo.person_id = l_person_id_tmp
	 AND   l_assignment_rec.start_date BETWEEN peo.effective_start_date
	 AND   peo.effective_end_date ;

  ELSE --IF (nvl(l_future_term_wf_flag,'N') = 'Y')

	 SELECT job_id
	 INTO 	l_fcst_job_id_tmp
     FROM 	per_all_assignments_f assn
     WHERE 	assn.person_id = l_person_id_tmp
     AND    l_assignment_rec.start_date BETWEEN assn.effective_start_date
                       AND  assn.effective_end_date
     AND 	assn.assignment_type in ('C','E')
     AND 	assn.primary_flag = 'Y'
     AND 	ROWNUM = 1;

	 SELECT decode(peo.current_employee_flag, 'Y', 'EMP', 'CWK')
	 INTO	l_person_type_code
     FROM 	per_all_people_f peo
     WHERE 	peo.person_id = l_person_id_tmp
     AND    l_assignment_rec.start_date BETWEEN peo.effective_start_date
                       AND peo.effective_end_date
     AND 	ROWNUM = 1;

  END IF ; --IF (nvl(l_future_term_wf_flag,'N') = 'Y')
  /* End of Changes for Bug 6056112 */

  	 IF P_DEBUG_MODE = 'Y' THEN
   	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
       ,x_msg         => 'proj_id='||p_assignment_rec.project_id||
				   	  ' res_format='||l_proj_asgmt_res_format_id||
					  ' person_id='||l_person_id_tmp||
					  ' job_id='||l_fcst_job_id_tmp
       ,x_log_level   => li_message_level);
 	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
       ,x_msg         => 'org_id='||l_resource_organization_id||
				   	  ' exp_type='||l_expenditure_type_tmp||
					  ' role_id='||l_project_role_id_tmp||
					  ' named_role='||l_assignment_name_tmp
       ,x_log_level   => li_message_level);
	 END IF;

	 -- check if this is a future dated employee. If it is, do
	 -- NOT call derive_resource_list_member API.
     OPEN  check_future_dated_employee;
	 FETCH check_future_dated_employee INTO l_future_dated_emp;

	 IF P_DEBUG_MODE = 'Y' THEN
     	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
           ,x_msg         => 'future_dated_employee ='||l_future_dated_emp
           ,x_log_level   => li_message_level);
	 END IF;

	 IF check_future_dated_employee%NOTFOUND THEN
	 	l_assignment_rec.resource_list_member_id := NULL;
	 ELSE
		l_assignment_rec.resource_list_member_id :=
	    PA_PLANNING_RESOURCE_UTILS.DERIVE_RESOURCE_LIST_MEMBER (
	                               p_project_id            => p_assignment_rec.project_id
	                              ,p_res_format_id         => l_proj_asgmt_res_format_id
	                              ,p_person_id             => l_person_id_tmp
	                              ,p_job_id                => l_fcst_job_id_tmp
	                              ,p_organization_id       => l_resource_organization_id
	                              ,p_expenditure_type      => l_expenditure_type_tmp
	                              ,p_project_role_id       => l_project_role_id_tmp
							      ,p_person_type_code	   => l_person_type_code
	                              ,p_named_role            => l_assignment_name_tmp);
	 END IF;
	 CLOSE check_future_dated_employee;

  	 IF P_DEBUG_MODE = 'Y' THEN
     	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
           ,x_msg         => 'resource_list_member_id='||l_assignment_rec.resource_list_member_id
           ,x_log_level   => li_message_level);
	 END IF;

  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment.function_security'
                     ,x_msg         => 'Check if user can confirm an assignment.'
                     ,x_log_level   => 5);
   END IF;
  --function security call:

  -- Perform security check to see if user has privilege to create
  -- administrative assignment on the resource if this is mass transaction


  IF p_asgn_creation_mode = 'MASS' AND
     l_assignment_rec.resource_id IS NOT NULL THEN

      IF  l_assignment_rec.assignment_type='STAFFED_ADMIN_ASSIGNMENT' THEN

           pa_security_pvt.check_confirm_asmt(p_project_id => l_assignment_rec.project_id,
                                              p_resource_id => l_assignment_rec.resource_id,
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
  END IF;

  --If the logged in user is trying to confirm an assignment then
  --see if that user has the permission to confirm an assignment for the
  --resource.
/* Created for bug 2381199 */
OPEN  get_system_status;
FETCH get_system_status INTO l_system_status_code;
CLOSE get_system_status;
/* Created for bug 2381199 */
  IF l_assignment_rec.resource_id IS NOT NULL THEN

     IF l_system_status_code = 'STAFFED_ASGMT_CONF' THEN

        IF  l_assignment_rec.assignment_type='STAFFED_ASSIGNMENT' THEN

           pa_security_pvt.check_confirm_asmt(p_project_id => l_assignment_rec.project_id,
                                              p_resource_id => l_assignment_rec.resource_id,
                                              p_resource_name => null,
                                              p_privilege => 'PA_ASN_CONFIRM',
                                              p_start_date => l_assignment_rec.start_date,
                                              x_ret_code => l_ret_code,
                                              x_return_status => l_return_status,
                                              x_msg_count => l_msg_count,
                                              x_msg_data => l_msg_data);
           --dbms_output.put_line('function security check: ret_code is: '||l_ret_code);
        ELSIF l_assignment_rec.assignment_type='STAFFED_ADMIN_ASSIGNMENT' THEN

           pa_security_pvt.check_confirm_asmt(p_project_id => l_assignment_rec.project_id,
                                              p_resource_id => l_assignment_rec.resource_id,
                                              p_resource_name => null,
                                              p_privilege => 'PA_ADM_ASN_CONFIRM',
                                              p_start_date => l_assignment_rec.start_date,
                                              x_ret_code => l_ret_code,
                                              x_return_status => l_return_status,
                                              x_msg_count => l_msg_count,
                                              x_msg_data => l_msg_data);
         END IF;

         IF  l_ret_code = FND_API.G_FALSE THEN
           PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                                 ,p_msg_name       => 'PA_ASGN_CONFIRM_NOT_ALLOWED' );
           PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
         END IF;

     END IF;

  END IF; -- end of check resource id not null

  --DBMS_OUTPUT.Put_Line('Debug stage 1');

  --cross charge validation.

  IF l_assignment_rec.resource_id IS NOT NULL AND l_assignment_rec.resource_id <> FND_API.G_MISS_NUM  THEN

     --dbms_output.put_line('cc resource id: '||l_assignment_rec.resource_id);
     --dbms_output.put_line('cc start date: '||l_assignment_rec.start_date);
     --dbms_output.put_line('cc end date: '||l_assignment_rec.end_date);

     --Log Message
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment.cc_resource'
                     ,x_msg         => 'Check if resource can be cross-charged.'
                     ,x_log_level   => 5);
     END IF;
     PA_RESOURCE_UTILS.check_cc_for_resource(p_resource_id => l_assignment_rec.resource_id,
                                             p_project_id  => l_assignment_rec.project_id,
                                             p_start_date  => l_assignment_rec.start_date,
                                             p_end_date    => l_assignment_rec.end_date,
                                             x_cc_ok       => l_cc_ok,
                                             x_return_status => l_return_status,
                                             x_error_message_code => l_error_message_code);

     IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => l_error_message_code);
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
--dbms_output.put_line('l_cc_ok: '||l_cc_ok);
     IF l_cc_ok <> 'Y' THEN
       PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                ,p_msg_name       => 'CROSS_CHARGE_VALIDATION_FAILED');
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;

  END IF;

 END IF; --end of bypassing procedure that use Project Id

-- v1.1 change: Admin assignment can use project, resource, or other calendar
/*
  --Admin assignments should use the resource calendar at 100%

  IF l_assignment_rec.assignment_type='STAFFED_ADMIN_ASSIGNMENT' THEN

     l_assignment_rec.calendar_type := 'RESOURCE';
     l_assignment_rec.resource_calendar_percent := 100;

  END IF;
*/

  --dbms_output.put_line('before calling insert row');

/*Adding changes for Bug 5918412 to get calendar id when the calendar_type = 'RESOURCE'*/
  IF (l_assignment_rec.calendar_type = 'RESOURCE')
  AND l_project_parties_error_exists <> FND_API.G_TRUE -- 6210780
  AND l_assignment_rec.resource_id IS NOT NULL -- 6210780
  THEN

    l_assignment_rec.calendar_id := pa_schedule_utils.get_res_calendar(p_resource_id => l_assignment_rec.resource_id ,
                                                                      p_start_date => l_assignment_rec.start_date,
                                                                      p_end_date => l_assignment_rec.end_date);
   END IF ;
/*Changes end for Bug 5918412 */

  IF (p_validate_only <> FND_API.G_TRUE AND FND_MSG_PUB.Count_Msg = 0) THEN


    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment.insert_row'
                     ,x_msg         => 'Insert new assignment into Table.'
                     ,x_log_level   => 5);
    END IF;

    -- Start 5130421
    -- nvl in below clause is needed for flow other than AMG
    IF nvl(PA_STAFFED_ASSIGNMENT_PVT.G_AUTO_APPROVE,'N') = 'Y' THEN
	l_apprvl_status_code := PA_ASSIGNMENT_APPROVAL_PUB.g_approved;
    ELSE
	l_apprvl_status_code := PA_ASSIGNMENT_APPROVAL_PUB.g_working ;
    END IF;

    --RESET the global variable after usage
    PA_STAFFED_ASSIGNMENT_PVT.G_AUTO_APPROVE := NULL;
    --End 5130421

    PA_PROJECT_ASSIGNMENTS_PKG.Insert_Row
    (p_assignment_name             => l_assignment_rec.assignment_name
    ,p_assignment_type             => l_assignment_rec.assignment_type
    ,p_multiple_status_flag        => l_assignment_rec.multiple_status_flag
    ,p_status_code                 => l_assignment_rec.status_code
    -- Commented for PJR Enhancement 5130421  ,p_apprvl_status_code          => PA_ASSIGNMENT_APPROVAL_PUB.g_working
    ,p_apprvl_status_code          => l_apprvl_status_code  -- Included for 5130421
    ,p_staffing_priority_code      => l_assignment_rec.staffing_priority_code
    ,p_project_id                  => l_assignment_rec.project_id
    ,p_project_role_id             => l_assignment_rec.project_role_id
    ,p_resource_id                 => l_assignment_rec.resource_id
    ,p_project_party_id            => l_assignment_rec.project_party_id
    ,p_description                 => l_assignment_rec.description
    ,p_start_date                  => l_assignment_rec.start_date
    ,p_end_date                    => l_assignment_rec.end_date
    ,p_assignment_effort           => l_assignment_rec.assignment_effort
    ,p_extension_possible          => l_assignment_rec.extension_possible
    ,p_source_assignment_id        => l_assignment_rec.source_assignment_id
    ,p_additional_information      => l_assignment_rec.additional_information
    ,p_work_type_id                => l_assignment_rec.work_type_id
    ,p_revenue_currency_code       => l_assignment_rec.revenue_currency_code
    ,p_revenue_bill_rate           => l_assignment_rec.revenue_bill_rate
    ,p_markup_percent              => l_assignment_rec.markup_percent
    ,p_fcst_tp_amount_type         => l_assignment_rec.fcst_tp_amount_type
    ,p_fcst_job_id                 => l_assignment_rec.fcst_job_id
    ,p_fcst_job_group_id           => l_assignment_rec.fcst_job_group_id
    ,p_expenditure_org_id          => l_assignment_rec.expenditure_org_id
    ,p_expenditure_organization_id => l_assignment_rec.expenditure_organization_id
    ,p_expenditure_type_class      => l_assignment_rec.expenditure_type_class
    ,p_expenditure_type            => l_assignment_rec.expenditure_type
    ,p_expense_owner               => l_assignment_rec.expense_owner
    ,p_expense_limit               => l_assignment_rec.expense_limit
    ,p_expense_limit_currency_code => l_assignment_rec.expense_limit_currency_code
    ,p_location_id                 => l_assignment_rec.location_id
    ,p_calendar_type               => l_assignment_rec.calendar_type
    ,p_calendar_id                 => l_assignment_rec.calendar_id
    ,p_resource_calendar_percent   => l_assignment_rec.resource_calendar_percent
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
	,p_resource_list_member_id     => l_assignment_rec.resource_list_member_id
    ,x_assignment_row_id           => x_assignment_row_id
    ,x_new_assignment_id           => x_new_assignment_id
    ,x_assignment_number           => l_assignment_rec.assignment_number
    ,x_return_status               => x_return_status
    );
  	IF P_DEBUG_MODE = 'Y' THEN
  	   pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
        ,x_msg         => 'after insert_row, status='||x_return_status
        ,x_log_level   => li_message_level);
	END IF;

    l_assignment_rec.assignment_id := x_new_assignment_id;

	  -- p_sch_basis_flag :
	  -- This field is required to know the following :
	  -- 'R' -> Resource  :--> Schedule creation for  Staffed team role is
	  -- based on  resource calendars work pattern.
	  -- 'A' --> Open Assignment  :--> Schedule creation for  Staffed team
	  --  role is based on Opem assignment  work pattern.
	  -- Work pattern for 'Staffed Assignment' may be different from the project itself, since
	  -- user can change the work pattern after 'Open Assignment' is created.
	  -- 'P' & 'O'  --> for these two parameters i will use the calendar_id passed to the API.
	  --
	  -- ( 'R' -> based on resource , 'A' -> based on open assignment, 'P' -> project , 'O' -> others


    IF l_assignment_rec.source_assignment_id IS NOT NULL AND l_assignment_rec.source_assignment_id <>
        FND_API.G_MISS_NUM THEN

        l_schedule_basis_flag := 'A';

    ELSIF l_assignment_rec.calendar_type = 'PROJECT' THEN

		l_schedule_basis_flag := 'P';

    ELSIF l_assignment_rec.calendar_type = 'RESOURCE' THEN

		l_schedule_basis_flag := 'R';

   	ELSIF l_assignment_rec.calendar_type = 'OTHER' THEN

		l_schedule_basis_flag := 'O';

--   ELSIF l_assignment_rec.calendar_type = 'TASK_ASSIGNMENT' THEN
--        l_sum_tasks_flag := 'Y';

   	END IF;

	--dbms_output.put_line('resource_id ='||l_assignment_rec.resource_id);
	--dbms_output.put_line('project_id ='||l_assignment_rec.project_id);
	--dbms_output.put_line('sched basis ='||l_schedule_basis_flag);
	--dbms_output.put_line('proj party id ='||l_assignment_rec.project_party_id);
	--dbms_output.put_line('cal_id ='||l_assignment_rec.calendar_id);
	--dbms_output.put_line('assignment_id ='||l_assignment_rec.assignment_id);
	--dbms_output.put_line('source_ass_id ='||l_assignment_rec.source_assignment_id);
	--dbms_output.put_line('res_cal_per_ ='||l_assignment_rec.resource_calendar_percent);
	--dbms_output.put_line('start_date ='||l_assignment_rec.start_date);
	--dbms_output.put_line('end_date ='||l_assignment_rec.end_date);
	--dbms_output.put_line('status code ='||l_assignment_rec.status_code);
	--dbms_output.put_line('work type id ='||l_assignment_rec.work_type_id);

	--pa_schedule_utils.l_print_log := TRUE;

    --FP.M Development
  	IF P_DEBUG_MODE = 'Y' THEN
    pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
		          ,x_msg         => 'FP.M Development'
          		  ,x_log_level   => li_message_level);

  	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
               	  ,x_msg         => 'resource_list_member_id'||l_assignment_rec.resource_list_member_id
                  ,x_log_level   => li_message_level);

    pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
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

         /*Added this IF for bug 7492618*/
         IF l_assignment_rec.resource_list_member_id IS NOT NULL AND
            l_assignment_rec.resource_list_member_id <> FND_API.G_MISS_NUM THEN

	    OPEN  get_td_resource_assignments;
	    FETCH get_td_resource_assignments
	     BULK COLLECT INTO l_task_assignment_id_tbl,
	                       l_task_version_id_tbl,
	  	   		   		   l_budget_version_id_tbl,
						   l_struct_version_id_tbl;
	    CLOSE get_td_resource_assignments;
         END IF ;
	 /*Added this IF for bug 7492618*/

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
  	IF P_DEBUG_MODE = 'Y' THEN
	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
		          ,x_msg         => 'Update_Task_Assignments status '||l_return_status
			      ,x_log_level   => li_message_level);

   	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
	              ,x_msg         => 'project_id='||l_assignment_rec.project_id||
		   	      				 	' sch_flag='||l_schedule_basis_flag||
									' party_id='||l_assignment_rec.project_party_id
	              ,x_log_level   => li_message_level);

	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
	              ,x_msg         => 'cal_id='||l_assignment_rec.calendar_id||
		   	  	  				 	' asgmt_id='||l_assignment_rec.assignment_id||
			  						' src_asgmt_id='||l_assignment_rec.source_assignment_id
	              ,x_log_level   => li_message_level);

	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
	              ,x_msg         => 's_date='||l_assignment_rec.start_date||
			  	  				 	' cal_perct='||l_assignment_rec.resource_calendar_percent||
		   	  						' e_date='||l_assignment_rec.end_date||
			  						' status='||l_assignment_rec.status_code
	           	  ,x_log_level   => li_message_level);
	END IF;

    IF l_task_assignment_id_tbl.COUNT <> 0 THEN
	   FOR j IN l_task_assignment_id_tbl.FIRST .. l_task_assignment_id_tbl.LAST LOOP
  	   	 IF P_DEBUG_MODE = 'Y' THEN
		   pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
		           ,x_msg         => 'tait('||j||')='||l_task_assignment_id_tbl(j)
			   	   ,x_log_level   => li_message_level);
		 END IF;
	   END LOOP;
    END IF;

  	IF P_DEBUG_MODE = 'Y' THEN
	   pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
	           	  ,x_msg         => 'task_flag='||p_sum_tasks_flag||
		   	  	  				 	' work_type='||l_assignment_rec.work_type_id
	           	  ,x_log_level   => li_message_level);
	END IF;

  	PA_SCHEDULE_PVT.Create_STF_ASG_Schedule
	(    p_project_id                => l_assignment_rec.project_id
	    ,p_schedule_basis_flag       => l_schedule_basis_flag
	    ,p_project_party_id          => l_assignment_rec.project_party_id
	    ,p_calendar_id               => l_assignment_rec.calendar_id
	    ,p_assignment_id             => l_assignment_rec.assignment_id
	    ,p_open_assignment_id        => l_assignment_rec.source_assignment_id
	    ,p_resource_calendar_percent => l_assignment_rec.resource_calendar_percent
	    ,p_start_date                => l_assignment_rec.start_date
	    ,p_end_date                  => l_assignment_rec.end_date
	    ,p_assignment_status_code    => l_assignment_rec.status_code
	    ,p_task_assignment_id_tbl    => l_task_assignment_id_tbl
	    ,p_sum_tasks_flag            => p_sum_tasks_flag
	    ,p_work_type_id              => l_assignment_rec.work_type_id
	    ,p_task_id                   => Null
	    ,p_task_percentage           => Null
		,p_budget_version_id		 => p_budget_version_id
	    ,x_return_status             => x_return_status
	    ,x_msg_count                 =>l_msg_count
	    ,x_msg_data                  =>l_msg_data
	);

	/* Added calc_init_transfer_price for bug 3051110 */

	IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	   PA_ASSIGNMENTS_PVT.Calc_Init_Transfer_Price
	     (p_assignment_id =>l_assignment_rec.assignment_id,
	      p_start_date => l_assignment_rec.start_date,
	      p_debug_mode => P_DEBUG_MODE,
	      x_return_status => l_return_status,
 	      x_msg_data => l_msg_data,
	      x_msg_count => l_msg_count );

	   x_return_status := l_return_status;
	END IF;

  END IF; -- IF (p_validate_only <> FND_API.G_TRUE AND FND_MSG_PUB.Count_Msg = 0)

  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_err_stack;


  EXCEPTION
    WHEN OTHERS THEN

	-- 4537865 : RESET OUT Params : Start

	 x_new_assignment_id           := NULL ;
	 x_assignment_row_id           := NULL ;
	 x_resource_id                 := NULL ;
	-- 4537865 : End

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_STAFFED_ASSIGNMENT_PVT.Create_Staffed_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Create_Staffed_Assignment;



PROCEDURE Update_Staffed_Assignment
( p_assignment_rec              IN     PA_ASSIGNMENTS_PUB.Assignment_Rec_Type
 ,p_location_city               IN     pa_locations.city%TYPE                          := FND_API.G_MISS_CHAR
 ,p_location_region             IN     pa_locations.region%TYPE                        := FND_API.G_MISS_CHAR
 ,p_location_country_code       IN     pa_locations.country_code%TYPE                  := FND_API.G_MISS_CHAR
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) IS

 l_assignment_rec       		PA_ASSIGNMENTS_PUB.Assignment_Rec_Type;
 -- added for Bug: 4537865
 l_new_status_code  pa_project_assignments.status_code%TYPE ;

 -- added for Bug: 4537865
 l_old_status_code      		pa_project_assignments.status_code%TYPE;
 l_old_start_date       		pa_project_assignments.start_date%TYPE;
 l_old_end_date         		pa_project_assignments.end_date%TYPE;
 l_return_status        		VARCHAR2(1);
 l_msg_count            		NUMBER;
 l_msg_data             		VARCHAR2(2000);
 l_change_id            		NUMBER;
 l_error_message_code      		VARCHAR2(2000);
 l_asgn_text            		VARCHAR2(30);
 l_proj_asgmt_res_format_id 	NUMBER;
 l_person_id            		NUMBER;
 l_task_assignment_id_tbl       system.pa_num_tbl_type;
 l_resource_list_member_id_tbl  system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_project_assignment_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
 l_proj_req_res_format_id       NUMBER;
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

  l_resource_organization_id     NUMBER;

  l_person_id_tmp 				 NUMBER;
  l_fcst_job_id_tmp 			 pa_project_assignments.fcst_job_id%TYPE;
  l_expenditure_type_tmp 		 pa_project_assignments.expenditure_type%TYPE;
  l_project_role_id_tmp 		 pa_project_assignments.project_role_id%TYPE;
  l_assignment_name_tmp 		 pa_project_assignments.assignment_name%TYPE;
  l_person_type_code			 Varchar2(30);
  l_future_term_wf_flag    pa_resources.future_term_wf_flag%TYPE := NULL  ; --Added for Bug 6056112

 CURSOR  assignment_status_code_csr
 IS
 SELECT status_code, start_date, end_date
 FROM   pa_project_assignments
 WHERE  assignment_id  = p_assignment_rec.assignment_id;

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

 -- get the resource's organization in HR
 CURSOR get_resource_organization IS
 SELECT resource_organization_id
 FROM pa_resources_denorm
 WHERE l_assignment_rec.start_date BETWEEN resource_effective_start_date AND resource_effective_end_date
 AND resource_id = l_assignment_rec.resource_id;


BEGIN

    -- 4537865 : Initialize the return_status
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.begin'
                     ,x_msg         => 'Beginning of Update_Staff_Assignment'
                     ,x_log_level   => 5);
  END IF;
  --
  -- Assign the record to the local variable
  --
  l_assignment_rec := p_assignment_rec;

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

  IF p_assignment_rec.resource_id = FND_API.G_MISS_NUM THEN
  	 l_assignment_rec.resource_id := l_cur_resource_id;
  END IF;

  IF P_DEBUG_MODE = 'Y' THEN
  	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
     			,x_msg         => 'l_asgmt_rec.resource_id='||l_assignment_rec.resource_id
     			,x_log_level   => li_message_level);
  END IF;

  IF p_assignment_rec.project_role_id = FND_API.G_MISS_NUM THEN
  	 l_assignment_rec.project_role_id := l_cur_project_role_id;
  END IF;

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.begin'
                     ,x_msg         => 'Old resource list member id='||l_cur_resource_list_member_id
                     ,x_log_level   => 5);
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
	 IF l_assignment_rec.resource_id <> FND_API.G_MISS_NUM THEN
		 select person_id
		 into   l_person_id
		 from   pa_resource_txn_attributes
	 	 WHERE  resource_id = l_assignment_rec.resource_id;
	 END IF;
  	 IF P_DEBUG_MODE = 'Y' THEN
  	 	pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
     			   ,x_msg         => 'l_person_id='||l_person_id
     			   ,x_log_level   => li_message_level);
	 END IF;

	 IF (l_cur_res_type_flag = 'Y' AND
	  l_assignment_rec.resource_id <> FND_API.G_MISS_NUM AND
	  l_assignment_rec.resource_id <> l_cur_resource_id) OR
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
	  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.begin'
	                     ,x_msg         => 'Mandatory attributes changed'
	                     ,x_log_level   => 5);
	  END IF;
/*
     BEGIN

	 -- Don't need to get the default format
     -- because we should use the format on the planning resource
	 -- on the team role
     SELECT proj_asgmt_res_format_id
     INTO   l_proj_asgmt_res_format_id
     FROM   PA_PROJECTS_ALL
     WHERE  project_id = p_assignment_rec.project_id;


     SELECT person_id
     INTO   l_person_id
     FROM   pa_resources_denorm
     WHERE  resource_id = p_assignment_rec.resource_id
     AND    rownum = 1;

     exception
     when others then
     null;
     end;

     IF l_proj_asgmt_res_format_id = FND_API.G_MISS_NUM THEN
	  	l_proj_asgmt_res_format_id := NULL;
	 END IF;
*/
	 l_person_id_tmp := l_person_id;
     IF l_person_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_person_id_tmp := NULL;
	 END IF;

	 l_fcst_job_id_tmp := l_assignment_rec.fcst_job_id;
     IF l_fcst_job_id_tmp = FND_API.G_MISS_NUM THEN
	  	l_fcst_job_id_tmp := NULL;
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

	 -- For Staffed Assignment only, get organization from resource before
	 -- deriving planning resources
	 OPEN get_resource_organization;
	 FETCH get_resource_organization INTO l_resource_organization_id;
	 CLOSE get_resource_organization;
  	 IF P_DEBUG_MODE = 'Y' THEN
  	   pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
        ,x_msg         => 'l_resource_organization_id='||l_resource_organization_id
        ,x_log_level   => li_message_level);
	 END IF;

	 -- Whenever we call Derive_resource_list_member for staffed assignment
	 -- by passing in person_id, the job_id and person_type are required to pass in.

  /* Start of Changes for Bug 6056112 */
	 SELECT nvl(future_term_wf_flag,'N')
	 INTO l_future_term_wf_flag
	 FROM pa_resources
	 WHERE resource_id = l_assignment_rec.resource_id;


  IF (nvl(l_future_term_wf_flag,'N') = 'Y') THEN

	 SELECT job_id
	 INTO         l_fcst_job_id_tmp
	 FROM  pa_resources_denorm prd
	 WHERE prd.person_id = l_person_id_tmp
	 AND   l_assignment_rec.start_date BETWEEN prd.resource_effective_start_date
	 AND     prd.resource_effective_end_date ;

	 IF P_DEBUG_MODE = 'Y' THEN
	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
                 ,x_msg         => 'l_fcst_job_id_tmp='||l_fcst_job_id_tmp
                 ,x_log_level   => li_message_level);
	 END IF;

	 SELECT decode(nvl(peo.employee_number,0), 0,'CWK','EMP')
	 INTO        l_person_type_code
	 FROM  per_all_people_f peo
	 WHERE peo.person_id = l_person_id_tmp
	 AND   l_assignment_rec.start_date BETWEEN peo.effective_start_date
	 AND   peo.effective_end_date ;

  ELSE    --IF (nvl(l_future_term_wf_flag,'N') = 'Y')

	 SELECT job_id
	 INTO 	l_fcst_job_id_tmp
     FROM 	per_all_assignments_f assn, pa_project_assignments pa
     WHERE 	assn.person_id = l_person_id_tmp
	 AND	pa.assignment_id = l_assignment_rec.assignment_id
     AND    pa.start_date BETWEEN assn.effective_start_date
                       AND  assn.effective_end_date
     AND 	assn.assignment_type in ('C','E')
     AND 	assn.primary_flag = 'Y'
     AND 	ROWNUM = 1;
  	 IF P_DEBUG_MODE = 'Y' THEN
  	   pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
        ,x_msg         => 'l_fcst_job_id_tmp='||l_fcst_job_id_tmp
        ,x_log_level   => li_message_level);
	 END IF;

	 SELECT decode(peo.current_employee_flag, 'Y', 'EMP', 'CWK')
	 INTO	l_person_type_code
     FROM 	per_all_people_f peo, pa_project_assignments pa
     WHERE 	peo.person_id = l_person_id_tmp
	 AND	pa.assignment_id = l_assignment_rec.assignment_id
     AND    pa.start_date BETWEEN peo.effective_start_date
                       AND peo.effective_end_date
     AND 	ROWNUM = 1;

  END IF ; --IF (nvl(l_future_term_wf_flag,'N') = 'Y')
  /* End of Changes for Bug 6056112 */

  	 IF P_DEBUG_MODE = 'Y' THEN
  	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
        ,x_msg         => 'l_person_type_code='||l_person_type_code
        ,x_log_level   => li_message_level);

  	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
        ,x_msg         => 'proj_id='||p_assignment_rec.project_id||
					   	  ' res_format='||l_cur_res_format_id||
						  ' person_id='||l_person_id_tmp||
						  ' job_id='||l_fcst_job_id_tmp
        ,x_log_level   => li_message_level);
  	 pa_debug.write(x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
        ,x_msg         => 'org_id='||l_resource_organization_id||
					   	  ' exp_type='||l_expenditure_type_tmp||
						  ' role_id='||l_project_role_id_tmp||
						  ' named_role='||l_assignment_name_tmp
        ,x_log_level   => li_message_level);
	 END IF;

	 l_assignment_rec.resource_list_member_id :=
     PA_PLANNING_RESOURCE_UTILS.DERIVE_RESOURCE_LIST_MEMBER (
                                p_project_id              => p_assignment_rec.project_id
                               ,p_res_format_id         => l_cur_res_format_id
                               ,p_person_id             => l_person_id_tmp
                               ,p_job_id                => l_fcst_job_id_tmp
                               ,p_organization_id       => l_resource_organization_id
                               ,p_expenditure_type      => l_expenditure_type_tmp
                               ,p_project_role_id       => l_project_role_id_tmp
							   ,p_person_type_code		=> l_person_type_code
                               ,p_named_role            => l_assignment_name_tmp);
	 --Log Message
	 IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	 PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.begin'
	                    ,x_msg         => 'new resource list member id='||l_assignment_rec.resource_list_member_id
	                    ,x_log_level   => 5);
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

	 -- Invoke Update_Planning_Transaction API
	 pa_assignments_pvt.Update_Task_Assignments(
   	  	p_task_assignment_id_tbl  => l_task_assignment_id_tbl
	   ,p_task_version_id_tbl	  => l_task_version_id_tbl
	   ,p_budget_version_id_tbl	  => l_budget_version_id_tbl
	   ,p_struct_version_id_tbl	  => l_struct_version_id_tbl
	   ,p_project_assignment_id	  => l_assignment_rec.assignment_id
	   -- change resource list member
	   ,p_resource_list_member_id => l_assignment_rec.resource_list_member_id
/*	   -- pass in resource attributes
	   ,p_resource_class_flag	  => l_resource_class_flag_tbl(1)
	   ,p_resource_class_code	  => l_resource_class_code_tbl(1)
	   ,p_resource_class_id		  => l_resource_class_id_tbl(1)
	   ,p_res_type_code			  => l_res_type_code_tbl(1)
	   ,p_incur_by_res_type		  => l_incur_by_res_type_tbl(1)
	   ,p_person_id				  => l_person_id_tbl(1)
	   ,p_job_id				  => l_job_id_tbl(1)
	   ,p_person_type_code		  => l_person_type_code_tbl(1) */
	   ,p_named_role			  => l_assignment_rec.assignment_name
/*	   ,p_bom_resource_id		  => l_bom_resource_id_tbl(1)
	   ,p_non_labor_resource	  => l_non_labor_resource_tbl(1)
	   ,p_inventory_item_id		  => l_inventory_item_id_tbl(1)
	   ,p_item_category_id		  => l_item_category_id_tbl(1)
*/	   ,p_project_role_id		  => l_assignment_rec.project_role_id
/*	   ,p_organization_id		  => l_organization_id_tbl(1)
	   ,p_fc_res_type_code		  => l_fc_res_type_code_tbl(1)
	   ,p_expenditure_type		  => l_expenditure_type_tbl(1)
	   ,p_expenditure_category	  => l_expenditure_category_tbl(1)
	   ,p_event_type			  => l_event_type_tbl(1)
	   ,p_revenue_category_code	  => l_revenue_category_code_tbl(1)
	   ,p_supplier_id			  => l_supplier_id_tbl(1)
	   ,p_spread_curve_id		  => l_spread_curve_id_tbl(1)
	   ,p_etc_method_code		  => l_etc_method_code_tbl(1)
	   ,p_mfc_cost_type_id		  => l_mfc_cost_type_id_tbl(1)
	   ,p_incurred_by_res_flag	  => l_incurred_by_res_flag_tbl(1)
	   ,p_incur_by_res_class_code => l_incur_by_res_class_code_tbl(1)
	   ,p_incur_by_role_id		  => l_incur_by_role_id_tbl(1)
	   ,p_unit_of_measure		  => l_unit_of_measure_tbl(1)
	   ,p_org_id				  => l_org_id_tbl(1)
	   ,p_rate_based_flag		  => l_rate_based_flag_tbl(1)
	   ,p_rate_expenditure_type	  => l_rate_expenditure_type_tbl(1)
	   ,p_rate_func_curr_code	  => l_rate_func_curr_code_tbl(1)
--	   ,p_rate_incurred_by_org_id => l_rate_incurred_by_org_id_tbl(1) */
	   ,x_return_status           => l_return_status
	 );
	  --Log Message
	  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
	                     ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                     ,x_log_level   => 5);
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
	  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
	                     ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                     ,x_log_level   => 5);
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

	   -- 1. change project_assignment_id to NULL
	   -- 2. Don't wipe out project_role_id,
	   -- 3. Wipe out named_role when it is not a mandatory attribute
	   --    of planning resource
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
			 ,p_named_role				=>	FND_API.G_MISS_CHAR
	 		 ,x_return_status           =>  l_return_status
		   );
	   END IF;


	   --Log Message
	   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.begin'
	                      ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                      ,x_log_level   => 5);
	   END IF;

	END IF; --IF l_assignment_rec.resource_list_member_id IS NOT NULL THEN

   -- IF mandatory attributes are NOT changed
   ELSIF p_assignment_rec.assignment_name <> FND_API.G_MISS_CHAR AND
	  	 p_assignment_rec.assignment_name <> l_cur_assignment_name THEN

	   --Log Message
	   IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
	   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.begin'
		                  ,x_msg         => 'Mandatory attributes not changed'
		                  ,x_log_level   => 5);
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
	   PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.begin'
	                      ,x_msg         => 'Update_task_assignments, status='||l_return_status
	                      ,x_log_level   => 5);
	   END IF;

	END IF; -- IF mandatory attributes are changed

  END IF;  -- IF l_cur_resource_list_member_id IS NOT NULL ...


  --dbms_output.put_line('In PVT update staffed assignment');

  -- Check that mandatory inputs for Staffed Assignment record are not null:

  -- Check p_assignment_id IS NOT NULL
  IF l_assignment_rec.assignment_id IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_ASGN_ID_REQUIRED_FOR_ASG'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_asgn_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  --Get assignment text from message to be used as values for token
  --
  l_asgn_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_TEXT');

  --
  -- Check that mandatory project id exists
  --
  IF l_assignment_rec.project_id IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_ID_REQUIRED_FOR_ASGN'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_asgn_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;


  --
  -- Check that mandatory assignment name exists
  --
  IF l_assignment_rec.assignment_name IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_ASGN_NAME_REQUIRED_FOR_ASG'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_asgn_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;


  --
  --  Check that mandatory project role exists
  --
  IF l_assignment_rec.project_role_id IS NULL THEN
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_PROJ_ROLE_REQUIRED_FOR_ASGN'
			 ,p_token1         => 'ASGNTYPE'
			 ,p_value1         => l_asgn_text);
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;

  --
  --Check p_work_type_id IS NOT NULL
  --
  IF  l_assignment_rec.work_type_id IS NULL THEN
    --dbms_output.put_line('WORK TYPE INVALID');
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                         ,p_msg_name       => 'PA_WORK_TYPE_REQUIRED_FOR_ASGN' );
    PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  END IF;

  -- Get the location id for the p_location_id for the given  location parameters
  -- If the location does not already exsists, then create it
  IF (p_location_country_code IS NOT NULL AND p_location_country_code <> FND_API.G_MISS_CHAR) THEN
    PA_LOCATION_UTILS.Get_Location( p_city                => p_location_city
                                   ,p_region              => p_location_region
                                   ,p_country_code        => p_location_country_code
                                   ,x_location_id         => l_assignment_rec.location_id
                                   ,x_error_message_code  => l_msg_data
                                   ,x_return_status       => l_return_status );

    IF  l_return_status = FND_API.G_RET_STS_ERROR THEN
       PA_UTILS.Add_Message ( p_app_short_name => 'PA'
                           ,p_msg_name => l_msg_data );
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

  --Insert into history table if changing from 'APPROVED' to 'WORKING'
  IF l_assignment_rec.apprvl_status_code= PA_ASSIGNMENT_APPROVAL_PUB.g_approved  THEN

    --Log Message
  	 IF P_DEBUG_MODE = 'Y' THEN
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.insert_history'
                     ,x_msg         => 'Inserting into Assignment History.'
                     ,x_log_level   => 5);
  	 END IF;

     PA_ASSIGNMENT_APPROVAL_PVT.Insert_Into_Assignment_History ( p_assignment_id => l_assignment_rec.assignment_id
                                                         ,x_change_id => l_change_id
                                                         ,x_return_status => l_return_status);
     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
     END IF;
     l_return_status := FND_API.G_MISS_CHAR;
  END IF;


  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.get_next_stus'
                     ,x_msg         => 'Getting next assignment approval status.'
                     ,x_log_level   => 5);

  END IF;
  -- Get the status code after action performed.
/* bug 8233045: GSI ER, skipping the following validation only when call is in bulk mode. This might need to be revisited later */
-- bug#9441844
--  if (PA_ASSIGNMENTS_PUB.G_update_assignment_bulk_call <> 'Y') then
  PA_ASSIGNMENT_APPROVAL_PVT.Get_Next_Status_After_Action ( p_action_code => PA_ASSIGNMENT_APPROVAL_PUB.g_update_action
                                                    ,p_status_code => l_assignment_rec.apprvl_status_code
                                                 -- ,x_status_code => l_assignment_rec.apprvl_status_code * commented for Bug: 4537865
						    ,x_status_code => l_new_status_code -- added for Bug: 4537865
                                                    ,x_return_status => l_return_status);
  --else
    --  l_assignment_rec.record_version_number := null;
  --end if;
/* end bug 8233045 */
  -- added for bug: 4537865

  IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
  l_assignment_rec.apprvl_status_code := l_new_status_code;
  END IF;

  -- added for Bug: 4537865

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;
  END IF;
  l_return_status := FND_API.G_MISS_CHAR;

  IF (p_validate_only = FND_API.G_FALSE AND PA_ASSIGNMENTS_PUB.g_error_exists <> FND_API.G_TRUE) THEN

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment.update_row'
                     ,x_msg         => 'Update Assignment Record.'
                     ,x_log_level   => 5);
     END IF;

    PA_PROJECT_ASSIGNMENTS_PKG.Update_Row
    (p_assignment_row_id           => l_assignment_rec.assignment_row_id
    ,p_assignment_id               => l_assignment_rec.assignment_id
    ,p_record_version_number       => l_assignment_rec.record_version_number
    ,p_assignment_name             => l_assignment_rec.assignment_name
    ,p_assignment_type             => l_assignment_rec.assignment_type
    ,p_multiple_status_flag        => l_assignment_rec.multiple_status_flag
    ,p_apprvl_status_code          => l_assignment_rec.apprvl_status_code
    ,p_status_code                 => l_assignment_rec.status_code
    ,p_staffing_priority_code      => l_assignment_rec.staffing_priority_code
    ,p_project_id                  => l_assignment_rec.project_id
    ,p_project_role_id             => l_assignment_rec.project_role_id
    ,p_project_party_id            => l_assignment_rec.project_party_id
    ,p_description                 => l_assignment_rec.description
    ,p_start_date                  => l_assignment_rec.start_date
    ,p_end_date                    => l_assignment_rec.end_date
    ,p_assignment_effort           => l_assignment_rec.assignment_effort
    ,p_extension_possible          => l_assignment_rec.extension_possible
    ,p_source_assignment_id        => l_assignment_rec.source_assignment_id
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
    ,p_resource_calendar_percent   => l_assignment_rec.resource_calendar_percent
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
	,p_resource_list_member_id     => l_assignment_rec.resource_list_member_id
    ,x_return_status               => x_return_status
  );


 END IF;


  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_err_stack;


  EXCEPTION
    WHEN OTHERS THEN

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_STAFFED_ASSIGNMENT_PVT.Update_Staffed_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Update_Staffed_Assignment;


PROCEDURE Delete_Staffed_Assignment
( p_assignment_row_id           IN     ROWID --(Bug-1851096)
 ,p_assignment_id               IN     pa_project_assignments.assignment_id%TYPE       := FND_API.G_MISS_NUM
 ,p_record_version_number       IN     NUMBER                                          := FND_API.G_MISS_NUM
 ,p_project_party_id            IN     pa_project_parties.project_party_id%TYPE        := FND_API.G_MISS_NUM
 ,p_calling_module              IN     VARCHAR2                                        := FND_API.G_MISS_CHAR
 ,p_commit                      IN     VARCHAR2                                        := FND_API.G_FALSE
 ,p_validate_only               IN     VARCHAR2                                        := FND_API.G_TRUE
 ,x_return_status               OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ) IS

 l_return_status  VARCHAR2(1);
 l_msg_count      NUMBER;
 l_msg_data       VARCHAR2(2000);
 l_start_date     DATE;
 l_end_date       DATE;
 l_error_message_code      VARCHAR2(2000);
 l_project_id                NUMBER;
 l_person_id                 NUMBER;

 CURSOR get_start_end_date IS
  SELECT asgn.start_date, asgn.end_date, asgn.project_id, res.person_id
  FROM   pa_project_assignments asgn,
         pa_resources_denorm res
  WHERE  assignment_id = p_assignment_id
    AND  res.resource_id = asgn.resource_id
    AND  rownum=1;

BEGIN

  -- 4537865 : Initialize the return_status
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  -- Initialize the Error Stack
  PA_DEBUG.set_err_stack('PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment');

  --Log Message
  IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
  PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment.begin'
                     ,x_msg         => 'Beginning of Delete_Staff_Assignment'
                     ,x_log_level   => 5);
  END IF;
  -- Assignment cannot be deleted if project transactions are associated with it
  OPEN get_start_end_date;
  FETCH get_start_end_date INTO l_start_date, l_end_date, l_project_id, l_person_id;
  CLOSE get_start_end_date;

  -- Bug 2797890: Added p_project_id, p_person_id parameters
  PA_TRANS_UTILS.Check_Txn_Exists(  p_assignment_id   => p_assignment_id
                                   ,p_calling_mode    => 'DELETE'
                                   ,p_project_id      => l_project_id
                                   ,p_person_id       => l_person_id
                                   ,p_old_start_date  => null
                                   ,p_old_end_date    => null
                                   ,p_new_start_date  => l_start_date
                                   ,p_new_end_date    => l_end_date
                                   ,x_error_message_code => l_error_message_code
                                   ,x_return_status      => l_return_status);

  IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     PA_UTILS.Add_Message( p_app_short_name => 'PA'
                          ,p_msg_name       => l_error_message_code);
     PA_ASSIGNMENTS_PUB.g_error_exists := FND_API.G_TRUE;

  END IF;
  l_return_status := NULL;

  IF (p_validate_only = FND_API.G_FALSE AND PA_ASSIGNMENTS_PUB.g_error_exists <> FND_API.G_TRUE) THEN

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment.del_schedules'
                       ,x_msg         => 'Deleting Assignment Schedules'
                       ,x_log_level   => 5);
    END IF;

    --
    -- Delete all the child shedule records before deleting the parent staff assignment record
    --

    PA_SCHEDULE_PVT.Delete_Asgn_Schedules
    ( p_assignment_id   => p_assignment_id
     ,p_perm_delete     => FND_API.G_TRUE    --Added for bug 4389372
     ,x_return_status   => l_return_status
     ,x_msg_count       => l_msg_count
     ,x_msg_data        => l_msg_data
    );

    --Log Message
    IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
    PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment.del_asgmt'
                       ,x_msg         => 'Deleting Assignment record.'
                       ,x_log_level   => 5);
     END IF;

    -- Delete the master record
    PA_PROJECT_ASSIGNMENTS_PKG.Delete_Row
    ( p_assignment_row_id     => p_assignment_row_id
     ,p_assignment_id         => p_assignment_id
     ,p_record_version_number => p_record_version_number
     ,x_return_status => x_return_status
   );

    --Delete Project Party
    IF x_return_status = 'S'AND p_project_party_id IS NOT NULL THEN

       --Log Message
       IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
       PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment.proj_party.'
                       ,x_msg         => 'Deleting Project Party'
                       ,x_log_level   => 5);
       END IF;

       PA_PROJECT_PARTIES_PVT.Delete_Project_Party(
                                                   p_commit => 'F',
                                                   p_validate_only => 'F',
                                                   p_project_party_id => p_project_party_id,
                                                   p_calling_module => 'ASSIGNMENT',
                                                   p_record_version_number => null,
                                                   x_return_status => x_return_status,
                                                   x_msg_count => l_msg_count,
                                                   x_msg_data => l_msg_data);
     END IF;


     --Log Message
     IF P_DEBUG_MODE = 'Y' THEN /* Added Debug Profile Option Check for bug#2674619 */
     PA_DEBUG.write_log (x_module      => 'pa.plsql.PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment.del_history'
                       ,x_msg         => 'Deleting Assignment History.'
                       ,x_log_level   => 5);
     END IF;

     --
     --Delete any related record in history table and any related record in wf table
     --
     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       PA_ASSIGNMENTS_HISTORY_PKG.Delete_By_Assignment ( p_assignment_id =>p_assignment_id
 							,x_return_status => x_return_status);

       PA_ASGMT_WFSTD.Delete_Assignment_WF_Records (p_assignment_id => p_assignment_id,
                                                    p_project_id    => l_project_id);
     END IF;


  -- Reset the error stack when returning to the calling program
     PA_DEBUG.Reset_err_stack;

END IF;

  EXCEPTION
    WHEN OTHERS THEN

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_STAFFED_ASSIGNMENT_PVT.Delete_Staffed_Assignment'
                                 ,p_procedure_name => PA_DEBUG.G_Err_Stack );
        --
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        RAISE;  -- This is optional depending on the needs

END Delete_Staffed_Assignment;

--
--
END pa_staffed_assignment_pvt;

/
