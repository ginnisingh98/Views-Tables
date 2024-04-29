--------------------------------------------------------
--  DDL for Package Body PA_TASK_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_ASSIGNMENTS_PVT" AS
-- $Header: PATAPVTB.pls 120.7.12010000.5 2010/05/26 12:07:31 bifernan ship $

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'PA_TASK_ASSIGNMENTS_PVT';
P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
li_curr_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;







PROCEDURE Create_Task_Assignment_Periods
( p_api_version_number	         IN   NUMBER	     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit			             IN   VARCHAR2	     := FND_API.G_FALSE
 ,p_init_msg_list	             IN   VARCHAR2	     := FND_API.G_FALSE
 ,p_pm_product_code	             IN   VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference         IN   VARCHAR2       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id      IN   NUMBER         := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignment_periods_in   IN   PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_PERIODS_TBL_TYPE
 ,p_task_assignment_periods_out  OUT  NOCOPY PA_TASK_ASSIGNMENTS_PUB.ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count		             OUT  NOCOPY NUMBER
 ,x_msg_data		             OUT  NOCOPY VARCHAR2
 ,x_return_status		         OUT  NOCOPY VARCHAR2
) IS
   l_calling_context varchar2(200);
   l_fin_plan_version_id number;
   l_finplan_lines_tab pa_fin_plan_pvt.budget_lines_tab;
   --pa_fp_rollup_tmp
   l_project_id                  pa_projects.project_id%type;
   l_d_task_id                   NUMBER;
   l_resource_assignment_id_tbl      system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_msg_count                   NUMBER ;
   l_msg_data                    VARCHAR2(2000);
   l_function_allowed            VARCHAR2(1);
   l_resp_id                     NUMBER := 0;
   l_user_id                     NUMBER := 0;
   l_module_name                 VARCHAR2(80);
   l_return_status               VARCHAR2(1);
   l_api_name                    CONSTANT  VARCHAR2(30)     := 'add_task_assignments';
   i                             NUMBER;
   l_count                       NUMBER;

   l_context                     varchar2(200);
   l_calling_module              varchar2(200);
   l_struct_elem_version_id      number;
   l_budget_version_id           pa_budget_versions.budget_version_id%TYPE;
   l_task_elem_version_id_tbl    system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_start_date_tbl              system.pa_date_tbl_type := system.pa_date_tbl_type();
   l_end_date_tbl                system.pa_date_tbl_type := system.pa_date_tbl_type();
   l_resource_list_member_id_tbl system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_quantity_tbl                system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_currency_code_tbl           system.pa_varchar2_15_tbl_type := system.pa_varchar2_15_tbl_type();
   l_raw_cost_tbl                system.pa_num_tbl_type := system.pa_num_tbl_type();
   l_burdened_cost_tbl           system.pa_num_tbl_type := system.pa_num_tbl_type();

   l_project_currency_code       pa_projects_all.project_currency_code%TYPE;

   l_txn_currency_code           pa_budget_lines.txn_currency_code%TYPE;

   l_period_set_name gl_sets_of_books.period_set_name%TYPE;
   l_accounted_period_type gl_sets_of_books.accounted_period_type%TYPE;
   l_pa_period_type pa_implementations_all.pa_period_type%TYPE;
   l_time_phased_code pa_proj_fp_options.all_time_phased_code%TYPE;
   l_period_name  gl_periods.period_name%TYPE;
   l_period_start_date DATE;
   l_period_end_date DATE;
   -- 10/22/04: To handle only lines after the progress as of date
   l_finplan_line_count NUMBER := 1;

   l_etc_start_date pa_budget_versions.etc_start_date%TYPE;
   l_project_name pa_projects_all.name%TYPE;

   CURSOR C_Get_txn_Currency(p_resource_assignment_id IN NUMBER) IS
   select txn_currency_code -- ,min(start_date) bug 6407736 - skkoppul
          from pa_resource_asgn_curr
          where resource_assignment_id = p_resource_assignment_id;
          -- group by txn_currency_code;bug 6407736 - skkoppul

   CURSOR C_Res_Asgmt_Data(p_resource_assignment_id IN NUMBER) IS
   select task_id, wbs_element_version_id, supplier_id, resource_class_code, resource_assignment_id,
   project_role_id, organization_id,
   fc_res_type_code, named_role,res_type_code, planning_start_date, planning_end_date,
   procure_resource_flag, use_task_schedule_flag, rate_based_flag from pa_resource_assignments where
   resource_assignment_id = p_resource_assignment_id;
   C_Res_Asgmt_Data_Rec C_Res_Asgmt_Data%ROWTYPE;

   CURSOR C_Get_res_info(p_resource_assignment_id IN NUMBER) IS
   select rate_based_flag , resource_list_member_id, planning_start_date, planning_end_date
   from pa_resource_assignments  r
   where resource_assignment_id = p_resource_assignment_id;
   C_Get_res_info_rec C_Get_res_info%ROWTYPE;

   CURSOR C_Get_Budget_Version_Id(p_structure_version_id IN NUMBER, p_project_id IN NUMBER) is
   select a.budget_version_id, b.project_currency_code
   from pa_budget_versions a, pa_projects_all b
   where a.project_structure_version_id = p_structure_version_id
   and a.project_id = b.project_id
   and a.project_id = p_project_id;

   CURSOR C_Progress_Exists(p_project_id IN NUMBER, p_task_id IN NUMBER, p_resource_assignment_id IN NUMBER) IS
   SELECT prog.actual_finish_date, pa_progress_utils.Check_object_has_prog(
			  p_project_id,
			  p_task_id,
			  p_resource_assignment_id,
			  'PA_ASSIGNMENTS',
                    'WORKPLAN'
               ) Progress_Exists
    FROM pa_assignment_progress_v prog
    WHERE prog.resource_assignment_id =  p_resource_assignment_id;

   l_prog_finish_date DATE;
   l_progress_exists varchar2(1);

   l_task_elem_version_id  NUMBER;
   l_task_name pa_proj_elements.name%TYPE;
   l_rlm_alias pa_resource_list_members.alias%TYPE;

   CURSOR C_Task_Elem_Version_Id(p_structure_version_id IN NUMBER,
                                 p_task_id in NUMBER,
                                 p_project_id IN NUMBER) IS
   SELECT pe.element_version_id
   from pa_proj_element_versions pe
   where parent_structure_version_id = p_structure_version_id
   and pe.proj_element_id = p_task_id
   and pe.project_id = p_project_id;

   CURSOR C_task_version(p_task_element_version_id IN NUMBER) IS
   SELECT pe.element_version_id, pe.proj_element_id
   from pa_proj_element_versions pe
   where pe.element_version_id = p_task_element_version_id;

  -- Bug# 6432606 Start
  /*
   CURSOR C_Prog_Date(p_resource_assignment_id IN NUMBER) IS
   SELECT a.as_of_date from pa_assignment_progress_v a
   WHERE a.resource_assignment_id = p_resource_assignment_id
   and a.project_id = p_pa_project_id
   and a.structure_version_id = p_pa_structure_version_id;
  */
   -- Commented above and added below for Bug 6432606
   /*
   CURSOR C_Prog_Date(p_resource_assignment_id IN NUMBER) IS
   select ppr.as_of_date
   from pa_progress_rollup ppr,
        pa_proj_element_versions ppv,
        pa_resource_assignments pra
   where ppv.parent_structure_version_id=p_pa_structure_version_id
    and ppv.project_id=p_pa_project_id
    and pra.resource_assignment_id=p_resource_assignment_id
    and pra.project_id=ppv.project_id
    and ppv.proj_element_id=pra.task_id
    and ppr.object_id=pra.resource_list_member_id
    and ppr.object_type='PA_ASSIGNMENTS'
    and ppr.object_version_id=ppv.element_version_id
    and ppr.project_id=ppv.project_id
    and ppr.structure_version_id=ppv.parent_structure_version_id
    and ppr.structure_type='WORKPLAN'
    and ppr.current_flag='Y';
   -- Bug# 6432606 End


   C_Prog_Date_Rec C_Prog_Date%ROWTYPE;
*/

   L_FuncProc varchar2(2000);

   CURSOR get_resource_alias(c_resource_list_member_id IN NUMBER) IS
   SELECT alias
   from pa_resource_list_members
   where resource_list_member_id = c_resource_list_member_id;

   CURSOR get_task_name(c_task_id NUMBER) IS
   SELECT NAME
   FROM pa_proj_elements
   WHERE proj_element_id = c_task_id;

   --C_Res_List_Mem_Check_Rec C_Res_List_Mem_Check%ROWTYPE;

   CURSOR c_cur_out(p_structure_version_id IN NUMBER,
                    p_project_id IN NUMBER,
					p_wbs_version_id IN NUMBER,
					p_resource_list_member_id IN NUMBER ) IS
   Select a.alias, b.resource_assignment_id
   from pa_resource_list_members a, pa_resource_assignments b, pa_budget_versions bv
   where a.resource_list_member_id = b.resource_list_member_id
   and b.resource_list_member_id = p_resource_list_member_id
   and b.ta_display_flag = 'Y'
   and b.budget_version_id = bv.budget_version_id
   and b.project_id = bv.project_id
   and bv.project_structure_version_id = p_structure_version_id
   and b.project_id = p_project_id
   and b.wbs_element_version_id = p_wbs_version_id;
    c_rec_out c_cur_out%ROWTYPE;


   CURSOR C_Workplan_Costs_enabled(p_budget_version_id IN NUMBER) IS
	select TRACK_WORKPLAN_COSTS_FLAG enabled_flag from pa_proj_fp_options
    where fin_plan_version_id = p_budget_version_id;
	C_Workplan_costs_rec C_Workplan_Costs_enabled%ROWTYPE;

  -- MOAC Changes: Bug 4363092: removed nvl with org_id
   CURSOR get_fp_options_csr(c_budget_version_id NUMBER) IS
   	SELECT gsb.period_set_name
              ,gsb.accounted_period_type
	      ,pia.pa_period_type
	      ,decode(pbv.version_type,
		        'COST',ppfo.cost_time_phased_code,
                	'REVENUE',ppfo.revenue_time_phased_code,
			 ppfo.all_time_phased_code) time_phase_code
               ,pbv.etc_start_date
	 FROM    gl_sets_of_books       gsb
	     	,pa_implementations_all pia
		,pa_projects_all        ppa
		,pa_budget_versions     pbv
		,pa_proj_fp_options     ppfo
	WHERE ppa.project_id        = pbv.project_id
	  AND pbv.budget_version_id = ppfo.fin_plan_version_id
	  AND ppa.org_id   = pia.org_id
	  AND gsb.set_of_books_id   = pia.set_of_books_id
	  AND pbv.budget_version_id = c_budget_version_id;


   l_start_date DATE;
   k_index NUMBER := 0;
--   l_org_id  NUMBER;  --Bug 4363092: Commenting this
   l_progress_safe VARCHAR2(1);

   p_task_assignment_tbl pa_task_assignment_utils.l_resource_rec_tbl_type;

   val_index number := 0;

   l_old_resource_assignment_id NUMBER;
   l_old_txn_currency VARCHAR2(15);
   l_prog_resource_assignment_id NUMBER;

   l_valid_member_flag varchar2(1);
   l_resource_list_id number;
   l_resource_list_member_id number;
BEGIN

L_FuncProc := 'Create_Task_Asgmts Periods';

--Bug 4363092: MOAC Changes: Commenting beloew call as l_org_id is not used anywhere
--fnd_profile.get('ORG_ID', l_org_id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='Entered ' || L_FuncProc ;
	pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
 --dbms_output.put_line('Entered Create Task Asgmts.');
--  Standard begin of API savepoint

    SAVEPOINT add_task_asgmt_periods;

--  Standard call to check for call compatibility.

     IF NOT FND_API.Compatible_API_Call ( 1.0, --pa_project_pub.g_api_version_number  ,
                               p_api_version_number  ,
                               l_api_name         ,
                               G_PKG_NAME         )
    THEN

          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

  --dbms_output.put_line('Fnd Api is compatible:');

--  Initialize the message table if requested.

    IF FND_API.TO_BOOLEAN( p_init_msg_list )
    THEN

  FND_MSG_PUB.initialize;

    END IF;

--  Set API return status to success

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --  Initialize the message table if requested.
    --  pm_product_code is mandatory

 --dbms_output.put_line('Initialized message table.');

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
 pa_debug.g_err_stage:='Checking p_pm_product_code ' || L_FuncProc;
 pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

    IF p_pm_product_code IS NOT NULL
    AND p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR   THEN

       IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PRODUCT_CODE_IS_MISSING'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'N'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
       END IF;
       RAISE FND_API.G_EXC_ERROR;

    END IF;

 --dbms_output.put_line('Product Code is checked:');

    l_resp_id := FND_GLOBAL.Resp_id;
    l_user_id := FND_GLOBAL.User_id;

 --dbms_output.put_line('User id :' || l_user_id || 'l_resp_id' || l_resp_id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:=' p_pm_product_code check successful.' || L_FuncProc;
	pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
--> Need sep. fn. for periods ? check..

    l_module_name := 'PA_PM_ADD_TASK_ASSIGNMENT';

--> Project Id check.

	IF p_pa_project_id is NOT NULL AND p_pa_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

     l_project_id := p_pa_project_id;

     --dbms_output.put_line('Project_id successfully passed..Check ' || l_project_id);

    ELSE
	 --dbms_output.put_line('Converting Project ref to id:' || p_pm_project_reference);
        PA_PROJECT_PVT.Convert_pm_projref_to_id
        (           p_pm_project_reference =>      p_pm_project_reference
                 ,  p_pa_project_id     =>      p_pa_project_id
                 ,  p_out_project_id    =>      l_project_id
                 ,  p_return_status     =>      l_return_status
        );

        IF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN

		       --dbms_output.put_line('Project_id not successful ');
			   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
			       pa_debug.g_err_stage:=' Project ref to id check not successful.' || L_FuncProc;
	               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
				END IF;
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;

        ELSIF  (l_return_status = FND_API.G_RET_STS_ERROR) THEN

		       --dbms_output.put_line('Project_id conv. not successful ');
			   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
			       pa_debug.g_err_stage:=' Project ref to id check not successful.' || L_FuncProc;
	               pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
			   END IF;
               RAISE  FND_API.G_EXC_ERROR;

		END IF;
	END IF;

	 --dbms_output.put_line('Project ref to id check successful for Project ' || l_Project_id);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:=' Project ref to id check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package

    pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
    	pa_debug.g_err_stage:=' After initializing security..' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to add task or not

       --dbms_output.put_line('Security Initialize successful.');
      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := l_project_id;  --bug 2471668 ( in the project context )

      PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_ADD_TASK_ASSIGNMENT',
       p_msg_count      => l_msg_count,
       p_msg_data           => l_msg_data,
       p_return_status      => l_return_status,
       p_function_allowed   => l_function_allowed);

       IF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

       ELSIF l_return_status = FND_API.G_RET_STS_ERROR
       THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	   	pa_debug.g_err_stage:=' PA_PM_ADD_TASK_ASSIGNMENT function check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
        --dbms_output.put_line('PA_PM_ADD_TASK_ASSIGNMENT function check successful.');
       IF l_function_allowed = 'N' THEN
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_FUNCTION_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
         RAISE FND_API.G_EXC_ERROR;
       END IF;
	   --dbms_output.put_line('PA_FUNCTION_SECURITY_ENFORCED function check successful.');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      pa_debug.g_err_stage:=' PA_FUNCTION_SECURITY_ENFORCED function check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;


      -- Now verify whether project security allows the user to update
      -- the project
      -- The user does not have query privileges on this project
      -- Hence, cannot update the project.Raise error
	  -- If the user has query privileges, then check whether
      -- update privileges are also available

      IF pa_security.allow_query(x_project_id => l_project_id ) = 'N' OR
	     pa_security.allow_update(x_project_id => l_project_id ) = 'N' THEN

            -- The user does not have update privileges on this project
            -- Hence , raise error
         --dbms_output.put_line('pa_security.allow_query or update not allowed..');
         pa_interface_utils_pub.map_new_amg_msg
           ( p_old_message_code => 'PA_PROJECT_SECURITY_ENFORCED'
            ,p_msg_attribute    => 'CHANGE'
            ,p_resize_flag      => 'Y'
            ,p_msg_context      => 'GENERAL'
            ,p_attribute1       => ''
            ,p_attribute2       => ''
            ,p_attribute3       => ''
            ,p_attribute4       => ''
            ,p_attribute5       => '');
         RAISE FND_API.G_EXC_ERROR;
     END IF;

  	 --dbms_output.put_line('pa_security.allow_query or update  successful..');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
  	 pa_debug.g_err_stage:='PA_PROJECT_SECURITY_ENFORCED function check successful.' || L_FuncProc;
     pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;
	 --dbms_output.put_line('Project Id:'  || l_project_id);

	  IF  NVL(PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( l_project_id ), 'N') = 'N' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
		   --dbms_output.put_line('PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS IS N..');
            pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PS_WP_NOT_SEP_FN_AMG'
                  ,p_msg_attribute    => 'CHANGE'
                  ,p_resize_flag      => 'N'
                  ,p_msg_context      => 'GENERAL'
                  ,p_attribute1       => ''
                  ,p_attribute2       => ''
                  ,p_attribute3       => ''
                  ,p_attribute4       => ''
                  ,p_attribute5       => '');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

   --dbms_output.put_line('PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS IS Fine..');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS function check successful.' || L_FuncProc;
   pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

		IF  p_pa_structure_version_id IS NOT NULL AND
		    (p_pa_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

	         l_struct_elem_version_id := p_pa_structure_version_id;

	    ELSE
		     --dbms_output.put_line('Getting current structure version'  );
		     l_struct_elem_version_id := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(
			                             p_project_id => l_project_id);


	    END IF;

		    --dbms_output.put_line(' structure version: ' || l_struct_elem_version_id );
			--Project Structures Integration

        IF ( l_struct_elem_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
            l_struct_elem_version_id IS NULL  )
       THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
               pa_interface_utils_pub.map_new_amg_msg
                    ( p_old_message_code => 'PA_PS_STRUC_VER_REQ'
                     ,p_msg_attribute    => 'CHANGE'
                     ,p_resize_flag      => 'N'
                     ,p_msg_context      => 'GENERAL'
                     ,p_attribute1       => ''
                     ,p_attribute2       => ''
                     ,p_attribute3       => ''
                     ,p_attribute4       => ''
                     ,p_attribute5       => '');
            END IF;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

                -- DHI ER: allowing multiple user to update task assignment
                --         Removed logic to lock version.
		--lock_version( l_project_id, l_struct_elem_version_id);

		IF 'N' = pa_task_assignment_utils.check_edit_task_ok( P_PROJECT_ID           => l_project_id,
	                                                        P_STRUCTURE_VERSION_ID    => l_struct_elem_version_id,
															P_CURR_STRUCT_VERSION_ID  => l_struct_elem_version_id) THEN
                        -- Bug 4533152
			--PA_UTILS.ADD_MESSAGE
                        --       (p_app_short_name => 'PA',
                        --        p_msg_name       => 'PA_UPDATE_PUB_VER_ERR'
                        --        );
			x_return_status := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;
       END IF;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		pa_debug.g_err_stage:='struct_elem version id function check successful.' || L_FuncProc;
        pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;


		OPEN C_Get_Budget_Version_Id(l_struct_elem_version_id, l_project_id);
		FETCH C_Get_Budget_Version_Id INTO l_budget_version_id, l_project_currency_code;
		CLOSE C_Get_Budget_Version_Id;

      IF ( l_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
            l_budget_version_id IS NULL  )
       THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
			PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_FP_PROJ_VERSION_MISMATCH'
                                );
            END IF;
			x_return_status    := FND_API.G_RET_STS_ERROR;
            RAISE FND_API.G_EXC_ERROR;

       END IF;

	  --dbms_output.put_line(' budget version id: ' || l_budget_version_id );

	l_count := p_task_assignment_periods_in.COUNT;

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='Count of task assignment periods' || l_count || ':' || L_FuncProc;
    pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

	--dbms_output.put_line(' Input Count of Global Input Tables..: ' || l_count );

	l_task_elem_version_id_tbl.extend(l_count);
	l_start_date_tbl.extend(l_count);
	l_end_date_tbl.extend(l_count);
	l_resource_list_member_id_tbl.extend(l_count);
	l_quantity_tbl.extend(l_count);
	l_currency_code_tbl.extend(l_count);
	l_raw_cost_tbl.extend(l_count);
	l_burdened_cost_tbl.extend(l_count);
	l_resource_assignment_id_tbl.extend(l_count);

	--dbms_output.put_line('Entering Loop for internal table set..');

  -- Bug 3866222: Get info from pa_proj_fp_options for checking period details
  OPEN get_fp_options_csr(l_budget_version_id);
  FETCH get_fp_options_csr INTO
     l_period_set_name
    ,l_accounted_period_type
    ,l_pa_period_type
    ,l_time_phased_code
    ,l_etc_start_date;
  CLOSE get_fp_options_csr;

  select name into l_project_name from pa_projects_all where project_id = l_project_id;

  FOR i in 1..l_count LOOP

   -- Bug 3866222: Initial period details
   l_period_name  := null;
   l_period_start_date := null;
   l_period_end_date := null;
--   C_Prog_Date_Rec := NULL;

  --dbms_output.put_line('Entering setting in create Task Assignment periods for index:' || i);
  --dbms_output.put_line('Within load of internal tables..index is:' || i);


	l_d_task_id := NULL;
	l_task_elem_version_id := NULL;

        -- Bug 9544497
	IF p_task_assignment_periods_in(i).pa_task_assignment_id is not NULL AND
           p_task_assignment_periods_in(i).pa_task_assignment_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
          OPEN C_Res_Asgmt_Data(p_task_assignment_periods_in(i).pa_task_assignment_id );
	  FETCH C_Res_Asgmt_Data into C_Res_Asgmt_Data_Rec;
	  CLOSE C_Res_Asgmt_Data;

          l_d_task_id := C_Res_Asgmt_Data_Rec.task_id;
          l_task_elem_version_id := C_Res_Asgmt_Data_Rec.wbs_element_version_id;
	END IF;

        --l_d_task_id := C_Res_Asgmt_Data_Rec.task_id;
	--l_task_elem_version_id := C_Res_Asgmt_Data_Rec.wbs_element_version_id;


	IF l_task_elem_version_id IS NULL AND p_task_assignment_periods_in.exists(i) AND p_task_assignment_periods_in(i).pa_task_element_version_id IS NOT NULL AND
	   p_task_assignment_periods_in(i).pa_task_element_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

	     OPEN C_task_version(p_task_assignment_periods_in(i).pa_task_element_version_id);
		 FETCH C_task_version INTO l_task_elem_version_id, l_d_task_id;
		 CLOSE C_task_version;


	ELSIF l_task_elem_version_id IS NULL AND p_task_assignment_periods_in.exists(i) AND p_task_assignment_periods_in(i).pa_task_id IS NOT NULL AND
	   p_task_assignment_periods_in(i).pa_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

	  l_d_task_id := p_task_assignment_periods_in(i).pa_task_id;

	  --dbms_output.put_line('l_d_task_id valid input:'|| l_d_task_id);

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	  pa_debug.g_err_stage:='task_id ' || l_d_task_id;
      pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

	  --dbms_output.put_line('l_d_task_id'|| l_d_task_id);

          IF ( l_d_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                 l_d_task_id IS NULL  )
            THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                 THEN
     			  PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_TASK_REQUIRED'
                                     );
                 END IF;

                 RAISE FND_API.G_EXC_ERROR;
            END IF;



	  l_task_elem_version_id := PA_PROJ_ELEMENTS_UTILS.GET_TASK_VERSION_ID(p_structure_version_id => l_struct_elem_version_id
                                          ,p_task_id => l_d_task_id);


	ELSIF l_task_elem_version_id IS NULL AND p_task_assignment_periods_in.exists(i) AND
	      p_task_assignment_periods_in(i).pm_task_reference IS NOT NULL AND
	      p_task_assignment_periods_in(i).pm_task_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

	 --dbms_output.put_line('l_d_task_reference'|| p_task_assignment_periods_in(i).pm_task_reference);



           PA_PROJECT_PVT.CONVERT_PM_TASKREF_TO_ID_all(p_pa_project_id => l_project_id
                                              ,p_pm_task_reference => p_task_assignment_periods_in(i).pm_task_reference
                                              ,p_structure_type => 'WORKPLAN'
                                              ,p_out_task_id => l_d_task_id
                                              ,p_return_status => l_return_status);

    			--dbms_output.put_line('l_d_task_id'|| l_d_task_id);

           IF ( l_d_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
                l_d_task_id IS NULL  )
           THEN
                IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                THEN
    			  PA_UTILS.ADD_MESSAGE
                                   (p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_TASK_REQUIRED'
                                    );
                END IF;

                RAISE FND_API.G_EXC_ERROR;
            END IF;



			l_task_elem_version_id := PA_PROJ_ELEMENTS_UTILS.GET_TASK_VERSION_ID(p_structure_version_id => l_struct_elem_version_id
                                          ,p_task_id => l_d_task_id);

	END IF;

     IF l_task_elem_version_id is not NULL AND
          l_task_elem_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

		   --extended already.

           l_task_elem_version_id_tbl(i):= l_task_elem_version_id;

	   ELSE
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
            THEN
	        PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_TASK_VERSION_REQUIRED'
                                );

            RAISE FND_API.G_EXC_ERROR;
            END IF;
       END IF;



	  --dbms_output.put_line('l_task_elem_version_id' || l_task_elem_version_id);

  IF p_task_assignment_periods_in(i).pa_task_assignment_id is NOT null AND
     p_task_assignment_periods_in(i).pa_task_assignment_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

		 --dbms_output.put_line('Accepting Task Assignment Id given:' || p_task_assignment_periods_in(i).pa_task_assignment_id );
	     l_resource_assignment_id_tbl(i) := p_task_assignment_periods_in(i).pa_task_assignment_id;

  ELSIF p_task_assignment_periods_in(i).pm_task_asgmt_reference is not null AND
        p_task_assignment_periods_in(i).pm_task_asgmt_reference <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

      --dbms_output.put_line('Converting Task Asgmt Reference:' || p_task_assignment_periods_in(i).pm_task_asgmt_reference );

	 PA_TASK_ASSIGNMENTS_PUB.Convert_PM_TARef_To_ID( p_pm_product_code         => p_pm_product_code
	 												 ,p_pa_project_id           => l_project_id
													 ,p_pa_structure_version_id => l_struct_elem_version_id
													 ,p_pa_task_id              => l_d_task_id
													 ,p_pa_task_elem_ver_id     => l_task_elem_version_id_tbl(i)
													 ,p_pm_task_asgmt_reference =>  p_task_assignment_periods_in(i).pm_task_asgmt_reference
													 ,p_pa_task_assignment_id   =>  p_task_assignment_periods_in(i).pa_task_assignment_id
													 ,p_resource_alias          =>  p_task_assignment_periods_in(i).resource_alias
													 ,p_resource_list_member_id =>  p_task_assignment_periods_in(i).resource_list_member_id
													 ,x_pa_task_assignment_id   =>  l_resource_assignment_id_tbl(i)
													 ,x_return_status		    =>  x_return_status
													 );


   END IF;


   IF  l_resource_assignment_id_tbl(i) IS NULL OR
       l_resource_assignment_id_tbl(i) = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
	          --new message case bug 3855080
	          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
   			  PA_UTILS.ADD_MESSAGE
                                  (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PM_TASK_ASGMT_REQ',
								   p_token1         => 'RESOURCE_REF',
                                   p_value1         =>  p_task_assignment_periods_in(i).pm_task_asgmt_reference
                                   );
               END IF;
   			   x_return_status    := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;

   END IF;

        -- Bug 3866222: validate period data
	-- Additional check to ensure periodic date information is passed
        OPEN get_resource_alias(l_resource_list_member_id);
        FETCH get_resource_alias INTO l_rlm_alias;
        CLOSE get_resource_alias;

        OPEN get_task_name(l_d_task_id);
        FETCH get_task_name INTO l_task_name;
        CLOSE get_task_name;
        -- End of Bug 3866222: validate period data

	IF (
	     (
	       (p_task_assignment_periods_in(i).start_date IS NULL OR
	        p_task_assignment_periods_in(i).start_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
		   )
		  OR
	       (p_task_assignment_periods_in(i).end_date IS NULL OR
		    p_task_assignment_periods_in(i).end_date = PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
		   )
	      )
		  AND
           (p_task_assignment_periods_in(i).period_name IS NULL OR
	        p_task_assignment_periods_in(i).period_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
			)
		)THEN

	        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN

   	         PA_UTILS.ADD_MESSAGE
                 (p_app_short_name => 'PA',
                  p_msg_name       => 'PA_INVALID_PERIOD_ERR',
                  p_token1         => 'TASK_NAME',
                  p_value1         =>  l_task_name,
                  p_token2         => 'PL_RES_ALIAS',
                  p_value2         =>  l_rlm_alias,
                  p_token3         => 'PERIOD_NAME',
                  p_value3         => p_task_assignment_periods_in(i).period_name,
                  p_token4         => 'START_DATE',
                  p_value4         => p_task_assignment_periods_in(i).start_date,
                  p_token5         => 'END_DATE',
                  p_value5         => p_task_assignment_periods_in(i).end_date
                 );

                  	x_return_status := FND_API.G_RET_STS_ERROR;
                        RAISE FND_API.G_EXC_ERROR;
                END IF;

   	END IF;

        -- Bug 3866222: validate period data
        l_period_name := p_task_assignment_periods_in(i).period_name;
        l_period_start_date := p_task_assignment_periods_in(i).start_date;
        l_period_end_date := p_task_assignment_periods_in(i).end_date;

        --dbms_output.put_line('before l_period_name:'||l_period_name);
        --dbms_output.put_line('before l_period_start_date:'||l_period_start_date);
        --dbms_output.put_line('before l_period_end_date:'||l_period_end_date);

        Check_Period_Details(
         P_BUDGET_VERSION_ID      => l_budget_version_id,
         p_period_set_name        => l_period_set_name,
         p_time_phase_code        => l_time_phased_code,
         p_accounted_period_type  => l_accounted_period_type,
         p_pa_period_type         => l_pa_period_type,
         p_task_name              => l_task_name,
         p_rlm_alias              => l_rlm_alias,
         P_PERIOD_NAME            => l_period_name,
         P_PERIOD_START_DATE      => l_period_start_date,
         P_PERIOD_END_DATE        => l_period_end_date,
         x_return_status          => l_return_status
        );

        -- dbms_output.put_line('after l_period_name:'||l_period_name);
        -- dbms_output.put_line('after l_period_start_date:'||l_period_start_date);
        -- dbms_output.put_line('after l_period_end_date:'||l_period_end_date);

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        ELSIF l_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;
        -- End of Bug 3866222: validate period data

	 -- Bug 8498316 - Raise an error if data is passed for a period which
        -- is prior to the period on which the etc start date falls.
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
            pa_debug.g_err_stage := 'ETC Start Date - ' || l_etc_start_date;
            pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
        END IF;

        IF p_task_assignment_periods_in(i).resource_list_member_id IS NOT NULL AND
           p_task_assignment_periods_in(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
            OPEN get_resource_alias(p_task_assignment_periods_in(i).resource_list_member_id);
            FETCH get_resource_alias INTO l_rlm_alias;
            CLOSE get_resource_alias;
        END IF;

        -- ETC Start Date is greater than period end date, raise error
	-- This is now consistent with the self service front end behaviour and with
	-- the code in the Calculate API
        IF (((l_etc_start_date IS NOT NULL) AND (l_period_end_date IS NOT NULL)) AND
	   (l_etc_start_date > l_period_end_date)) THEN
            IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	        PA_UTILS.ADD_MESSAGE
                (
                     p_app_short_name => 'PA',
                     p_msg_name       => 'PA_FP_ETC_SPREAD_DATE_ERR',
                     p_token1         => 'G_PROJECT_NAME' ,
                     p_value1         => l_project_name,
                     p_token2         => 'G_TASK_NAME',
                     p_value2         => l_task_name,
                     p_token3         => 'G_RESOURCE_NAME',
                     p_value3         => l_rlm_alias,
                     p_token4         => 'G_SPREAD_FROM_DATE',
                     p_value4         => l_etc_start_date
                );
                x_return_status := FND_API.G_RET_STS_ERROR;
                RAISE FND_API.G_EXC_ERROR;
            END IF;
	END IF;

        /* Commenting for bug 8498316

        -- Ignore the period line if progress/actual exists in period after this line
        l_progress_safe := 'Y';
        l_start_date    := Null;

        OPEN C_Prog_Date(l_resource_assignment_id_tbl(i));
        FETCH C_Prog_Date INTO  C_Prog_Date_Rec;

        IF C_Prog_Date%FOUND AND
           -- Replaced l_period_start_date with l_period_end_date for Bug# 6432606
    	   -- l_period_start_date < C_Prog_Date_Rec.as_of_date THEN
    	    l_period_end_date < C_Prog_Date_Rec.as_of_date THEN

    	  l_progress_safe := 'N';
	  l_prog_resource_assignment_id := l_resource_assignment_id_tbl(i);

        END IF;

        CLOSE C_Prog_Date;
        -- End of progress/actual check
	*/

-- IF l_progress_safe <> 'N' THEN

	IF p_task_assignment_periods_in(i).resource_list_member_id IS NOT NULL AND
	  p_task_assignment_periods_in(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN

	   l_resource_list_id := PA_TASK_ASSIGNMENT_UTILS.Get_WP_Resource_List_Id(l_project_id);

   	   PA_PLANNING_RESOURCE_UTILS.check_list_member_on_list(
                    p_resource_list_id          => l_resource_list_id,
                    p_resource_list_member_id   => p_task_assignment_periods_in(i).resource_list_member_id,
                    p_project_id                => l_project_id,
                    p_chk_enabled               => 'Y',
					x_resource_list_member_id   => l_resource_list_member_id,
                    x_valid_member_flag         => l_valid_member_flag,
                    x_return_status             => x_return_status,
                    x_msg_count                 => x_msg_count,
                    x_msg_data                  => x_msg_data ) ;

           IF l_valid_member_flag <> 'Y' THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
   	                        PA_UTILS.ADD_MESSAGE
                                  (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_INVALID_RES_LIST_MEM_ID'
                                   );
   			x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
   	   END IF;

   	ELSIF p_task_assignment_periods_in(i).pa_task_assignment_id IS NULL AND
	  (p_task_assignment_periods_in(i).resource_list_member_id IS  NULL OR
	  p_task_assignment_periods_in(i).resource_list_member_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
	    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
   	                        PA_UTILS.ADD_MESSAGE
                                  (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_INVALID_RES_LIST_MEM_ID'
                                   );
   			x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
             END IF;
	END IF;

        /* Bug 8498316 - Handle the variable l_prog_resource_assignment_id
         * If progress has been applied for this task assignment, then set
         * l_prog_resource_assignment_id to l_resource_assignment_id_tbl(i)
         * for later validations to kick in.
         */
	IF 'Y' =  pa_progress_utils.check_prog_exists_and_delete(
                              p_project_id           => l_project_id,
                              p_task_id              => l_d_task_id,
                              p_object_type          => 'PA_ASSIGNMENTS',
                              p_object_id            => p_task_assignment_periods_in(i).resource_list_member_id,
                              p_structure_type       => 'WORKPLAN',
                              p_delete_progress_flag => 'N'
                           ) THEN
            l_prog_resource_assignment_id := l_resource_assignment_id_tbl(i);
        END IF;


      -- 10/22/04: To handle only lines after the progress as of date
      l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id    := pa_task_assignments_pvt.pfnum(l_resource_assignment_id_tbl(i));

	OPEN C_Get_res_info(l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id);
	FETCH C_Get_res_info INTO C_Get_res_info_rec;
	CLOSE C_Get_res_info;



        l_txn_currency_code  := NULL;

	OPEN C_Get_txn_Currency(l_resource_assignment_id_tbl(i));
	FETCH C_Get_txn_Currency INTO  l_txn_currency_code; --, l_txn_start_date; bug 6407736 - skkoppul
	CLOSE C_Get_txn_Currency;

	OPEN C_Workplan_Costs_enabled(l_budget_version_id);
	FETCH C_Workplan_Costs_enabled into C_Workplan_Costs_rec;
	CLOSE C_Workplan_Costs_enabled;

	--dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id);
	l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference1    :=  pa_task_assignments_pvt.pfnum(l_d_task_id);
	--dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference1: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference1);
	l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference2    :=  NVL(pa_task_assignments_pvt.pfnum(p_task_assignment_periods_in(i).resource_list_member_id), C_Get_res_info_rec.resource_list_member_id);
    --dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference2:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference2);
	l_FINPLAN_LINES_TAB(l_finplan_line_count).start_date                :=  pa_task_assignments_pvt.pfdate(l_period_start_date) ;
	--dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).start_date:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).start_date);
	l_FINPLAN_LINES_TAB(l_finplan_line_count).end_date                  :=  pa_task_assignments_pvt.pfdate(l_period_end_date) ;
	--dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).end_date:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).end_date);
	l_FINPLAN_LINES_TAB(l_finplan_line_count).quantity                  :=  pa_task_assignments_pvt.pfnum(p_task_assignment_periods_in(i).quantity) ;
	--dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).quantity:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).quantity);
	l_FINPLAN_LINES_TAB(l_finplan_line_count).period_name               :=  pa_task_assignments_pvt.pfchar(l_period_name) ;
	--dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).period_name:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).period_name);

	  IF l_prog_resource_assignment_id = l_resource_assignment_id_tbl(i) THEN
	       --new message case bug 3855080
	       IF  pa_task_assignments_pvt.pfchar(p_task_assignment_periods_in(i).txn_currency_code)  <> l_txn_currency_code THEN
		                       PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_TA_SAME_CURR_PROG_ERR',
                                p_token1         => 'RESOURCE_REF',
                                p_value1         =>  p_task_assignment_periods_in(i).pm_task_asgmt_reference

                                );
	       ELSE
		       l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code  :=  l_txn_currency_code ;
           END IF;
	  ELSIF l_prog_resource_assignment_id <> l_resource_assignment_id_tbl(i) AND
	        l_old_resource_assignment_id  <> l_resource_assignment_id_tbl(i) THEN

		IF 	C_Get_res_info_rec.rate_based_flag = 'Y' AND C_Workplan_Costs_rec.enabled_flag = 'N' THEN
		    l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code         :=  NVL(l_txn_currency_code, l_project_currency_code) ;
		ELSE
	        l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code         :=
			           NVL(NVL(pa_task_assignments_pvt.pfchar(p_task_assignment_periods_in(i).txn_currency_code),
					           l_txn_currency_code), l_project_currency_code) ;
		END IF;
	  ELSIF l_prog_resource_assignment_id <> l_resource_assignment_id_tbl(i) AND
	        l_old_resource_assignment_id  = l_resource_assignment_id_tbl(i)  THEN
			--new message case bug 3855080
            IF  pa_task_assignments_pvt.pfchar(p_task_assignment_periods_in(i).txn_currency_code)  <> l_old_txn_currency THEN
		                       PA_UTILS.ADD_MESSAGE
                               (p_app_short_name => 'PA',
                                p_msg_name       => 'PA_TA_SAME_CURR_ERR',
                                p_token1         => 'RESOURCE_REF',
                                p_value1         =>  p_task_assignment_periods_in(i).pm_task_asgmt_reference
                                );
	        ELSE
		        l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code         := l_old_txn_currency;
            END IF;
	  ELSE
	        l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code         :=  NVL(l_txn_currency_code, l_project_currency_code) ;
	  END IF;



	   --dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code);
	   l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_raw_cost              :=  pa_task_assignments_pvt.pfnum(p_task_assignment_periods_in(i).txn_raw_cost) ;
	   --dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_raw_cost:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_raw_cost);
	   l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_burdened_cost         :=  pa_task_assignments_pvt.pfnum(p_task_assignment_periods_in(i).txn_burdened_cost) ;
       --dbms_output.put_line('l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_burdened_cost:' || l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_burdened_cost);

	   l_old_txn_currency := l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code;

	--dbms_output.put_line('End of Loop');

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
   pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


   pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference1 (task_id): ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference1;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


   pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference2 (resource_list_member_id): ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).system_reference2;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


   pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).start_date: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).start_date;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


   pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).end_date: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).end_date;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


   pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).period_name: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).period_name;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);


   pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

	  pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_raw_cost: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_raw_cost;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

    pa_debug.g_err_stage:='l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_burdened_cost: ' || l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_burdened_cost;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

	    val_index := val_index + 1;

        p_task_assignment_tbl(val_index).resource_assignment_id  :=    l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id;
        p_task_assignment_tbl(val_index).override_currency_code  :=    l_FINPLAN_LINES_TAB(l_finplan_line_count).txn_currency_code;

        --For purposes of validation of updation override is passed as not null & defaulted below..discussed as per Sheenie 08/25/04
		p_task_assignment_tbl(val_index).cost_rate_override      :=    1;
        p_task_assignment_tbl(val_index).burdened_rate_override  :=    1;
        p_task_assignment_tbl(val_index).total_quantity          :=    l_FINPLAN_LINES_TAB(l_finplan_line_count).quantity;


        -- Bug Fix 5638541.
	-- removed the hard coded apps.
        -- APPS.PA_TASK_ASSIGNMENT_UTILS.VALIDATE_UPDATE_ASSIGNMENT ( P_TASK_ASSIGNMENT_TBL, X_RETURN_STATUS );
        -- Paramererized arguments for Bug 6856934
        PA_TASK_ASSIGNMENT_UTILS.VALIDATE_UPDATE_ASSIGNMENT ( p_task_assignment_tbl => P_TASK_ASSIGNMENT_TBL,
                                                              x_return_status       => X_RETURN_STATUS );
        -- End of Bug Fix 5638541.


	   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;

	  --Prior to calling do resets

	       /*      OPEN C_Prog_Date(l_resource_assignment_id_tbl(i));
                   FETCH C_Prog_Date INTO  C_Prog_Date_Rec;
    			 CLOSE C_Prog_Date;
                */

                         -- Bug 3954155 Should not access a closed cursor
    			-- IF C_Prog_Date_Rec.as_of_date IS NOT NULL THEN
                       -- delete from pa_budget_lines
                      --  where resource_assignment_id = l_resource_assignment_id_tbl(i)
    	--			and start_date > C_Prog_Date_Rec.as_of_date;
    	--		 ELSE
    	--		      delete from pa_budget_lines where resource_assignment_id = l_resource_assignment_id_tbl(i);
    	--		 END IF;

            	  update pa_resource_assignments set sp_fixed_date=null,spread_curve_id =null, record_version_number=(record_version_number+1)
            	  where resource_assignment_id = l_FINPLAN_LINES_TAB(l_finplan_line_count).resource_assignment_id;

        -- 10/22/04: Increment the l_finplan_lines table coutn
        l_finplan_line_count := l_finplan_line_count+1;

 --  END IF; --IF l_progress_safe <> 'N' THEN

		  l_old_resource_assignment_id := l_resource_assignment_id_tbl(i);

  END LOOP;
  --dbms_output.put_line('After end of Loop');



IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      pa_debug.g_err_stage:='Calling context.' ||l_calling_context;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);

	  pa_debug.g_err_stage:='Return status B4  add fin plan lines:' ||x_return_status;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

  --dbms_output.put_line('Calling PA_FIN_PLAN_PVT.ADD_FIN_PLAN_LINES');
   PA_FIN_PLAN_PVT.ADD_FIN_PLAN_LINES
   ( PA_FP_CONSTANTS_PKG.G_AMG_API,
     l_budget_version_id,
     l_FINPLAN_LINES_TAB,
	 X_RETURN_STATUS,
	 X_MSG_COUNT,
	 X_MSG_DATA );

	  --dbms_output.put_line('After returning from returning from add fin plan lines. return status:' ||x_return_status );

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	   pa_debug.g_err_stage:='Return status after add fin plan lines:' ||x_return_status;
	  pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

	   IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                RAISE  FND_API.G_EXC_ERROR;
        END IF;


	 	  --dbms_output.put_line(' Internal Add Tables index' || k_index);


		FOR i in 1..l_FINPLAN_LINES_TAB.COUNT LOOP

		  --dbms_output.put_line('Obtaining Task Assignment Ids index:' || i);

		  open c_cur_out( l_struct_elem_version_id, l_project_id, l_task_elem_version_id_tbl(i), p_task_assignment_periods_in(i).resource_list_member_id );
		  fetch c_cur_out into c_rec_out;

		  IF c_cur_out%FOUND THEN
		    --dbms_output.put_line('Success on index:' || i);
		    p_task_assignment_periods_out(i).return_status  := 'S';
                        -- Bug Fix 5638541.
	                -- removed the hard coded apps.
			-- APPS.PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).return_status:= 'S';
			PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).return_status:= 'S';
                        -- End of Bug Fix 5638541.

		  ELSE
		    --dbms_output.put_line('Errored on index:' || i);
		    p_task_assignment_periods_out(i).return_status  := 'E';
                        -- Bug Fix 5638541.
	                -- removed the hard coded apps.
			-- APPS.PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).return_status:= 'E';
			PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).return_status:= 'E';
                        -- End of Bug Fix 5638541.
		  END IF;

		   --dbms_output.put_line('Out resource_assignment_id:' || c_rec_out.resource_assignment_id);
		   --dbms_output.put_line('Out resource alias:' || c_rec_out.alias);

		  p_task_assignment_periods_out(i).pa_task_assignment_id  := c_rec_out.resource_assignment_id;
		  p_task_assignment_periods_out(i).resource_alias         := c_rec_out.alias;

                  -- Bug Fix 5638541.
	          -- removed the hard coded apps.
		  -- APPS.PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).pa_task_assignment_id := c_rec_out.resource_assignment_id;
		  -- APPS.PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).resource_alias        := c_rec_out.alias;
		  PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).pa_task_assignment_id := c_rec_out.resource_assignment_id;
		  PA_TASK_ASSIGNMENTS_PUB.g_asgmts_periods_out_tbl(i).resource_alias        := c_rec_out.alias;
                  -- End of Bug Fix 5638541.


		  close c_cur_out;


	      END LOOP;

		  --dbms_output.put_line('End of Create Task Assignments:');

EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN
      ROLLBACK TO add_task_asgmt_periods;

      x_return_status := FND_API.G_RET_STS_ERROR;
	  IF P_DEBUG_MODE = 'Y' THEN
	      PA_DEBUG.write_log (x_module => G_PKG_NAME
	                              ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
	                              ,x_log_level   => 5);
	  END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count    =>  x_msg_count  ,
              p_data    =>  x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN
      ROLLBACK TO add_task_asgmt_periods;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF P_DEBUG_MODE = 'Y' THEN
	      PA_DEBUG.write_log (x_module => G_PKG_NAME
	                              ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
	                              ,x_log_level   => 5);
	  END IF;
      FND_MSG_PUB.Count_And_Get
          (   p_count    =>  x_msg_count  ,
              p_data    =>  x_msg_data  );

  WHEN OTHERS THEN
  ROLLBACK TO add_task_asgmt_periods;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF P_DEBUG_MODE = 'Y' THEN
      PA_DEBUG.write_log (x_module => G_PKG_NAME
                              ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                              ,x_log_level   => 5);
	  END IF;
      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
        FND_MSG_PUB.add_exc_msg
            ( p_pkg_name    => G_PKG_NAME
            , p_procedure_name  => l_api_name  );

      END IF;

      FND_MSG_PUB.Count_And_Get
          (   p_count    =>  x_msg_count  ,
              p_data    =>  x_msg_data  );

END CREATE_TASK_ASSIGNMENT_PERIODS;


FUNCTION PFCHAR(P_CHAR IN VARCHAR2 DEFAULT to_char(NULL) ) RETURN VARCHAR2 IS
begin


if p_char IS NOT NULL and p_char =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

  return to_char(NULL);

elsif p_char IS NOT NULL and p_char =  FND_API.G_MISS_CHAR THEN

  return to_char(NULL);

elsif p_char IS NULL  THEN

  return fnd_api.g_miss_char;

else

  return p_char;

end if;

EXCEPTION WHEN OTHERS THEN
RETURN P_CHAR;

END PFCHAR;

FUNCTION PFNUM(P_NUM IN NUMBER DEFAULT TO_NUMBER(NULL)) RETURN NUMBER IS
begin


--dbms_output.put_line('entered pfnum 1');
if p_num IS NOT NULL and p_num =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM THEN
--dbms_output.put_line('entered pfnum 2');

  return to_number(NULL);

elsif p_num IS NOT NULL and p_num =  FND_API.G_MISS_NUM THEN
--dbms_output.put_line('entered pfnum 3');

  return to_number(NULL);

elsif p_num IS NULL THEN
--dbms_output.put_line('entered pfnum 4');

  return fnd_api.g_miss_num;

else
--dbms_output.put_line('entered pfnum 5');

  return p_num;

end if;

EXCEPTION WHEN OTHERS THEN
    RETURN P_NUM;

END PFNUM;

FUNCTION PFDATE(P_DATE IN DATE DEFAULT TO_DATE(NULL)) RETURN DATE IS
begin


if p_date IS NOT NULL and p_date =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN

  return to_date(NULL);

elsif p_date IS NOT NULL and p_date =  FND_API.G_MISS_DATE THEN

  return to_date(NULL);

elsif p_date IS NULL THEN

  return fnd_api.g_miss_date;

else

  return p_date;

end if;

EXCEPTION WHEN OTHERS THEN
    RETURN P_DATE;

END PFDATE;

/*
FUNCTION GET_PERIOD_START_DATE(P_PERIOD_NAME IN VARCHAR2, P_BUDGET_VERSION_ID IN NUMBER) RETURN DATE IS

  l_period_set_name               gl_sets_of_books.period_set_name%type;
  l_accounted_period_type     gl_sets_of_books.accounted_period_type%type;
  l_pa_period_type                 pa_implementations_all.pa_period_type%type;
  l_time_phase_code              pa_proj_fp_options.cost_time_phased_code%type;


  cursor c_period_data IS
   SELECT gsb.period_set_name
       ,gsb.accounted_period_type
       ,pia.pa_period_type
       ,decode(pbv.version_type,
               'COST',ppfo.cost_time_phased_code,
               'REVENUE',ppfo.revenue_time_phased_code,
                ppfo.all_time_phased_code) time_phase_code
                ,glp.start_date period_start_date,glp.end_date period_end_date
  FROM gl_sets_of_books          gsb
                ,pa_implementations_all pia
                ,pa_projects_all        ppa
                ,pa_budget_versions     pbv
                ,pa_proj_fp_options     ppfo
                ,gl_periods             glp
  WHERE ppa.project_id        = pbv.project_id
  AND pbv.budget_version_id = ppfo.fin_plan_version_id
  AND nvl(ppa.org_id,-99)   = nvl(pia.org_id,-99)
  AND gsb.set_of_books_id   = pia.set_of_books_id
  AND pbv.budget_version_id = p_budget_version_id
  AND glp.period_set_name = gsb.period_set_name
  -- this condition is not required as
  -- period_set_name and period_name are the unique columns on gl_periods
  -- and glp.period_type     = decode(pbv.version_type
  --                          ,'COST', decode(ppfo.cost_time_phased_code,'G',gsb.accounted_period_type,'P',pia.pa_period_type)
  --                          ,'REVENUE',decode(ppfo.revenue_time_phased_code,'G',gsb.accounted_period_type,'P',pia.pa_period_type)
  --                          ,decode(ppfo.all_time_phased_code,'G',gsb.accounted_period_type,'P',pia.pa_period_type))
  --
  AND glp.period_name = p_period_name
  AND adjustment_period_flag = 'N' ;

  c_period_data_rec c_period_data%rowtype;

  v_return_status varchar2(3);
  v_msg_count    number;
  v_msg_data      varchar2(2000);

  begin
   null;


    open c_period_data;
    fetch c_period_data into c_period_data_rec;
    close c_period_data;


    --dbms_output.put_line('st date' || c_period_data_rec.period_start_date );

    --dbms_output.put_line('get_period_start_date end');

	return c_period_data_rec.period_start_date;


EXCEPTION WHEN OTHERS THEN
  --  --dbms_output.put_line('Exception');
  return to_date(null);

END GET_PERIOD_START_DATE;
*/

PROCEDURE lock_version( p_project_id IN NUMBER, p_structure_version_id IN NUMBER) IS
cursor version_info IS
     select pev_structure_id, record_version_number,name
            from PA_proj_elem_ver_structure
            where element_version_id   = p_structure_version_id
            and   project_id           = p_project_id;

l_api_name                      CONSTANT VARCHAR2(30)  := 'lock_version';

l_record_version_number         pa_proj_elem_ver_structure.record_version_number%type;
l_name                          pa_proj_elem_ver_structure.name%type;
x_return_status        VARCHAR2(1);
x_msg_data             VARCHAR2(2000);
x_msg_count            NUMBER;
str version_info%ROWTYPE;
l_structure_id NUMBER;

L_FuncProc varchar2(200);

BEGIN

L_FuncProc := 'lock_version';

--dbms_output.put_line(' Entered lock version');
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
pa_debug.g_err_stage:='Entered ' || L_FuncProc ;
pa_debug.write(G_PKG_NAME ,pa_debug.g_err_stage,3);
END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

        OPEN version_info;
        FETCH version_info INTO str;
        IF version_info%NOTFOUND THEN
           RAISE NO_DATA_FOUND;
        END IF;

        l_record_version_number := str.record_version_number;
        l_name                  := str.name;
        l_structure_id          := str.pev_structure_id;

        CLOSE version_info;

    --dbms_output.put_line(' lock version name'   || l_name);
    --dbms_output.put_line(' lock version number' || l_record_version_number);
    --dbms_output.put_line(' lock structure id'   || l_structure_id);

  PA_PROJECT_STRUCTURE_PUB1.Update_Structure_Version_Attr
            (
             p_pev_structure_id            => l_structure_id
          -- Commented for bug 4240130
          --,p_locked_status_code          => 'LOCKED'
            ,p_structure_version_name      => l_name
            ,p_record_version_number       => l_record_version_number
            ,x_return_status               => x_return_status
            ,x_msg_count                   => x_msg_count
            ,x_msg_data                    => x_msg_data
            );
        --dbms_output.put_line(' After lock version upd str vers attr call return status' || x_return_status);
		IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
		        PA_UTILS.ADD_MESSAGE
                                  (p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_PS_STRUC_VER_LOCKED'
                                   );
                RAISE  FND_API.G_EXC_ERROR;
        END IF;




		--dbms_output.put_line(' Leaving lock version');
EXCEPTION

  WHEN FND_API.G_EXC_ERROR
  THEN

        x_return_status := FND_API.G_RET_STS_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.write_log (x_module => G_PKG_NAME
                                ,x_msg         => 'Expected Error:' || L_FuncProc || SQLERRM
                                ,x_log_level   => 5);
END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>  x_msg_count  ,
                p_data    =>  x_msg_data  );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR
  THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' THEN
        PA_DEBUG.write_log (x_module => G_PKG_NAME
                                ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                                ,x_log_level   => 5);
END IF;
        FND_MSG_PUB.Count_And_Get
            (   p_count    =>  x_msg_count  ,
                p_data    =>  x_msg_data  );

  WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        PA_DEBUG.write_log (x_module => G_PKG_NAME
                                ,x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM
                                ,x_log_level   => 5);
END IF;
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.add_exc_msg
                ( p_pkg_name    => G_PKG_NAME
                , p_procedure_name  => l_api_name  );

        END IF;

        FND_MSG_PUB.Count_And_Get
            (   p_count    =>  x_msg_count  ,
                p_data    =>  x_msg_data  );


END lock_version;


/***********************************************************************
 * This API is invoked upon the following flows:
 * 1. Actual summerization for shared structure
 * 2. Submit or Apply progress for split structure
 *
 * It returns the appropriate resource assignment on which
 * actuals should be tracked against for the given rlm and task version
 * combination.
 * 1. Return the existing planned assignment if exists
 * 2. Otherwise, create the unplanned assignment using the given rlm
 *   2.1 In shared case, the unplanned assignment will be created
 *       as the task level assignment with ta_display_flag = 'N' if
 *       the wp resource list is None and the rlm is of the people class
 *   2.2 In split case, the unplanned assignment will be created
 *       as the task level assignment with ta_display_flag = 'N' if
 *       rlm is not passed into the API.
 **********************************************************************/
PROCEDURE Derive_Task_Assignments
( p_project_id              IN PA_PROJECTS_ALL.project_id%TYPE
 ,p_task_version_id         IN PA_PROJ_ELEMENT_VERSIONS.element_version_id%TYPE
 ,p_scheduled_start         IN DATE
 ,p_scheduled_end           IN DATE
 ,p_resource_class_code     IN PA_RESOURCE_LIST_MEMBERS.resource_class_code%TYPE
 ,p_resource_list_member_id IN PA_RESOURCE_LIST_MEMBERS.resource_list_member_id%TYPE
 ,p_unplanned_flag          IN PA_RESOURCE_ASSIGNMENTS.unplanned_flag%TYPE
 ,x_resource_assignment_id  OUT NOCOPY NUMBER -- 4537865 Added Nocopy hint
 ,x_task_version_id         OUT NOCOPY NUMBER -- 4537865 Added Nocopy hint
 ,x_resource_list_member_id OUT NOCOPY NUMBER -- 4537865 Added Nocopy hint
 ,x_currency_code           OUT NOCOPY VARCHAR2 -- 4537865 Added Nocopy hint
 ,x_rate_based_flag         OUT NOCOPY VARCHAR2 -- 4537865 Added Nocopy hint
 ,x_rbs_element_id          OUT NOCOPY NUMBER -- 4537865 Added Nocopy hint
 ,x_msg_count		    OUT NOCOPY NUMBER
 ,x_msg_data		    OUT NOCOPY VARCHAR2
 ,x_return_status           OUT NOCOPY VARCHAR2
)
IS

CURSOR get_task_assignment(c_resource_list_member_id NUMBER) IS
SELECT resource_assignment_id,
       DECODE(ta_display_flag, 'N', wbs_element_version_id, NULL),
       rate_based_flag,
       rbs_element_id
FROM pa_resource_assignments
WHERE resource_list_member_id = c_resource_list_member_id
AND wbs_element_version_id = p_task_version_id
AND ta_display_flag IS NOT NULL
AND rownum = 1;

CURSOR get_task_level_rec IS
SELECT resource_assignment_id, resource_list_member_id
FROM pa_resource_assignments
WHERE wbs_element_version_id = p_task_version_id
AND ta_display_flag = 'N'
AND rownum = 1;

CURSOR get_people_class_asgmt IS
SELECT resource_assignment_id, resource_list_member_id
FROM pa_resource_assignments
WHERE wbs_element_version_id = p_task_version_id
AND ta_display_flag = 'Y'
AND resource_class_code = 'PEOPLE'
AND rownum = 1;

CURSOR get_budget_version_id IS
SELECT bv.budget_version_id
FROM pa_budget_versions bv,
     pa_proj_element_versions ev,
     pa_proj_elem_ver_structure evs
WHERE bv.project_id = p_project_id
  AND bv.wp_version_flag = 'Y'
  AND bv.project_structure_version_id = evs.element_version_id
  AND ev.project_id = p_project_id
  AND ev.element_version_id = p_task_version_id
  AND evs.project_id = ev.project_id
  AND ev.parent_structure_version_id = evs.element_version_id;

CURSOR get_struct_version_id IS
SELECT ev.parent_structure_version_id
FROM pa_proj_element_versions ev
WHERE ev.project_id = p_project_id
  AND ev.element_version_id = p_task_version_id;

CURSOR get_txn_cur_code(c_resource_assignment_id NUMBER) IS
SELECT txn_currency_code
FROM pa_budget_lines
where resource_assignment_id = c_resource_assignment_id
and txn_currency_code is not null
and rownum = 1;

CURSOR get_proj_cur_code IS
SELECT project_currency_code
FROM pa_projects_all
where project_id = p_project_id;

CURSOR check_none_resource_list(c_resource_list_id NUMBER) IS
SELECT uncategorized_flag
from pa_resource_lists
where resource_list_id = c_resource_list_id;

l_resource_assignment_id NUMBER := NULL;
l_resource_list_member_id NUMBER := NULL;
l_task_version_id NUMBER := NULL;
l_ta_exists VARCHAR2(1) := 'N';
l_bvid NUMBER(15) := NULL;
l_struct_ver_id NUMBER(15) := NULL;
l_in_resource_list_member_id NUMBER := NULL;
l_in_resource_class_code VARCHAR2(30) := NULL;
l_resource_list_id NUMBER := NULL;
l_rate_based_flag VARCHAR2(1) := NULL;
l_uncategorized_flag VARCHAR2(1) := 'N';
l_toggle_ta_display_flag VARCHAR2(1) := 'N';
l_rbs_element_id NUMBER := NULL;


TYPE l_number_tbl IS TABLE OF NUMBER;
TYPE l_date_tbl IS TABLE OF DATE;
TYPE l_varchar_tbl is TABLE OF VARCHAR2(1);

l_task_elem_version_id_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(1);
l_res_list_member_id_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(1);
l_planned_people_effort_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(1);
l_quantity_tbl SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE(1);
l_start_date_tbl SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(NULL);
l_end_date_tbl SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE(NULL);
l_unplanned_flag_tbl SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.PA_VARCHAR2_1_TBL_TYPE(NULL);

BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := NULL;
  l_in_resource_list_member_id := p_resource_list_member_id;
  l_in_resource_class_code := p_resource_class_code;
  l_uncategorized_flag := 'N';

    --dbms_output.put_line('derive TA, p_resource_list_member_id:'||p_resource_list_member_id);
    --dbms_output.put_line('derive TA, p_task_version_id:'||p_task_version_id);
    --dbms_output.put_line('derive TA, p_resource_class_code:'||p_resource_class_code);

  -- Added to support Apply Progress flow in which when progress was
  -- entered against the task, rlm id will not be passed into this API
  -- upon Apply Progress.  Should get the PEOPLE class rlm in this case.
  -- Also, in shared case, we need to check whether resource list
  -- is a None resource list if the given rlm is of the people class.
  IF p_resource_list_member_id IS NULL OR
     p_resource_list_member_id = FND_API.G_MISS_NUM OR
     p_resource_class_code = 'PEOPLE' THEN

    l_resource_list_id := pa_task_assignment_utils.Get_WP_Resource_List_Id(p_project_id);

    OPEN check_none_resource_list(l_resource_list_id);
    FETCH check_none_resource_list INTO l_uncategorized_flag;
    CLOSE check_none_resource_list;

    --dbms_output.put_line('derive TA, l_uncategorized_flag:'||l_uncategorized_flag);

    IF p_resource_list_member_id IS NULL OR
     p_resource_list_member_id = FND_API.G_MISS_NUM THEN

      l_in_resource_list_member_id := PA_PLANNING_RESOURCE_UTILS.get_class_member_id(
            p_project_id          => p_project_id,
            p_resource_list_id    => l_resource_list_id,
            p_resource_class_code => 'PEOPLE');
      l_in_resource_class_code := 'PEOPLE';

    END IF;

  END IF;

  --dbms_output.put_line('l_in_resource_list_member_id:'||l_in_resource_list_member_id);


  -- CASE 1: return the assignment if it already exists for the task and
  -- resource list member combination
  OPEN get_task_assignment(l_in_resource_list_member_id);
  FETCH get_task_assignment INTO l_resource_assignment_id, l_task_version_id, l_rate_based_flag, l_rbs_element_id;
  CLOSE get_task_assignment;

  IF l_resource_assignment_id IS NOT NULL THEN

    --dbms_output.put_line('CASE 1');

    x_resource_assignment_id := l_resource_assignment_id;
    x_task_version_id := l_task_version_id;
    x_resource_list_member_id := l_in_resource_list_member_id;
    x_rate_based_flag := l_rate_based_flag;
    x_rbs_element_id := l_rbs_element_id;

  -- CASE 2: otherwise, create the task assignment record and
  -- take care of the unplanned_flag
  ELSE
      --dbms_output.put_line('CASE 4');
      l_task_elem_version_id_tbl(1) := p_task_version_id;
      l_res_list_member_id_tbl(1) := l_in_resource_list_member_id;
      l_planned_people_effort_tbl(1) := 0;
      l_quantity_tbl(1) := 0;
      l_start_date_tbl(1) := p_scheduled_start;
      l_end_date_tbl(1)   := p_scheduled_end;
      l_unplanned_flag_tbl(1) := p_unplanned_flag;

      --dbms_output.put_line('project_id:'||p_project_id);
      --dbms_output.put_line('p_task_version_id:'||p_task_version_id);
      --dbms_output.put_line('l_in_resource_list_member_id:'||l_in_resource_list_member_id);
      --dbms_output.put_line('p_scheduled_start:'||p_scheduled_start);
      --dbms_output.put_line('p_scheduled_end:'||p_scheduled_end);
      --dbms_output.put_line('p_unplanned_flag:'||p_unplanned_flag);

      OPEN get_struct_version_id;
      FETCH get_struct_version_id INTO l_struct_ver_id;
      CLOSE get_struct_version_id;

      OPEN get_budget_version_id;
      FETCH get_budget_version_id INTO l_bvid;
      CLOSE get_budget_version_id;

       -- Bug 3849244
       -- Update ta_display_flag = 'Y' to make the created record
       -- a task effort record IF:
       --  1. in split case, rlm id is passed in as NULL
       --  2. in shared case, the RL is None and the rlm is of People class
       --  AND no assignment exists on the task version
      l_toggle_ta_display_flag := 'N';
      pa_task_assignment_utils.g_ta_display_flag := 'Y';

      IF (p_resource_list_member_id IS NULL OR
           p_resource_list_member_id = FND_API.G_MISS_NUM OR
           l_uncategorized_flag = 'Y') AND
          pa_task_assignment_utils.Check_Asgmt_Exists_In_Task(p_task_version_id) = 'N' THEN

         l_toggle_ta_display_flag := 'Y';

      END IF;


      --dbms_output.put_line('l_bvid:'||l_bvid);
      --dbms_output.put_line('l_struct_ver_id:'||l_struct_ver_id);


      --dbms_output.put_line('pa_task_assignment_utils.g_ta_display_flag:'||pa_task_assignment_utils.g_ta_display_flag);

     --dbms_output.put_line('CASE 4: before add planning transaction');

     -- Bug 4286558
     -- skip progress update check in apply progress mode
     -- because apply progress can be done within process update
     PA_TASK_ASSIGNMENT_UTILS.g_apply_progress_flag := 'Y';

      PA_FP_PLANNING_TRANSACTION_PUB.Add_Planning_Transactions(
            p_context                     => 'TASK_ASSIGNMENT'
           ,p_project_id                  => p_project_id
           ,p_budget_version_id           => l_bvid
           , p_struct_elem_version_id      => l_struct_ver_id
           ,p_task_elem_version_id_tbl    => l_task_elem_version_id_tbl
           ,p_resource_list_member_id_tbl => l_res_list_member_id_tbl
           ,p_planned_people_effort_tbl   => l_planned_people_effort_tbl
           ,p_start_date_tbl              => l_start_date_tbl
           ,p_end_date_tbl                => l_end_date_tbl
           ,p_quantity_tbl                => l_quantity_tbl
           ,p_unplanned_flag_tbl          => l_unplanned_flag_tbl
           ,x_return_status               => x_return_status
           ,x_msg_count                   => x_msg_count
           ,x_msg_data                    => x_msg_data
      );
      pa_task_assignment_utils.g_ta_display_flag := 'N';
      PA_TASK_ASSIGNMENT_UTILS.g_apply_progress_flag := 'N'; -- Bug 4286558

     --dbms_output.put_line('CASE 4: after add planning transaciton'||x_return_status);
     -- dbms_output.put_line('pa_task_assignment_utils.g_ta_display_flag:'||pa_task_assignment_utils.g_ta_display_flag);


     IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

       OPEN get_task_assignment(l_in_resource_list_member_id);
       FETCH get_task_assignment INTO l_resource_assignment_id, l_task_version_id, l_rate_based_flag, l_rbs_element_id;
       CLOSE get_task_assignment;

       --dbms_output.put_line('CASE 4: resource assignment id '|| l_resource_assignment_id);
       --dbms_output.put_line('CASE 4: l_task_version_id '|| l_task_version_id);
       -- Bug 3849244
       -- Update ta_display_flag = 'Y' to make the created record
       -- a task effort record IF:
       --  1. in split case, rlm id is passed in as NULL
       --  2. in shared case, the RL is None and the rlm is of People class
       --  AND no assignment exists on the task version
       IF l_toggle_ta_display_flag = 'Y' THEN

          UPDATE pa_resource_assignments
             SET ta_display_flag = 'N'
           WHERE resource_assignment_id = l_resource_assignment_id;

       END IF;

       x_resource_assignment_id := l_resource_assignment_id;
       x_resource_list_member_id := l_in_resource_list_member_id;
       x_rate_based_flag := l_rate_based_flag;
       x_rbs_element_id := l_rbs_element_id;

     END IF;

  END IF; -- cases

  -- Return the appropriate currency code
  OPEN get_txn_cur_code (x_resource_assignment_id);
  FETCH get_txn_cur_code INTO x_currency_code;
  CLOSE get_txn_cur_code;

  IF x_currency_code IS NULL THEN
    OPEN get_proj_cur_code;
    FETCH get_proj_cur_code INTO x_currency_code;
    CLOSE get_proj_cur_code;
  END IF;

EXCEPTION
    WHEN OTHERS THEN

       pa_task_assignment_utils.g_ta_display_flag := 'N';
       PA_TASK_ASSIGNMENT_UTILS.g_apply_progress_flag := 'N'; -- Bug 4286558

       -- Set the excetption Message and the stack
       FND_MSG_PUB.add_exc_msg ( p_pkg_name => 'PA_TASK_ASSIGNMENTS_PVT.Derive_Task_Assignments'
                                ,p_procedure_name => PA_DEBUG.G_Err_Stack );
       --
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

	-- Start 4537865
	x_resource_assignment_id  := NULL ;
	x_task_version_id         := NULL ;
	x_resource_list_member_id := NULL ;
	x_currency_code           := NULL ;
	x_rate_based_flag         := NULL ;
	x_rbs_element_id          := NULL ;

	-- End : 4537865

       RAISE;  -- This is optional depending on the needs

END Derive_Task_Assignments;





PROCEDURE Copy_Missing_Unplanned_Asgmts
(
	p_project_id				IN	PA_PROJECTS_ALL.PROJECT_ID%TYPE,
	p_old_structure_version_id	IN	PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	p_new_structure_version_id	IN	PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	p_new_budget_version_id		IN	PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE			DEFAULT NULL,
	x_msg_count					OUT	NOCOPY NUMBER,
	x_msg_data					OUT	NOCOPY VARCHAR2,
	x_return_status				OUT	NOCOPY VARCHAR2
)

IS

l_old_budget_version_id				PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;
l_new_budget_version_id				PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE;

l_parent_struct_ver_id_tbl			SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_element_version_id_tbl			SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_resource_list_member_id_tbl		SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_planned_people_effort_tbl			SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_planning_start_date_tbl			SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
l_planning_end_date_tbl				SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
l_task_start_date_tbl				SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
l_task_end_date_tbl					SYSTEM.PA_DATE_TBL_TYPE := SYSTEM.PA_DATE_TBL_TYPE();
l_quantity_tbl						SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
l_unplanned_flag_tbl				SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
l_ta_display_flag_tbl				SYSTEM.PA_VARCHAR2_1_TBL_TYPE := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

k NUMBER;

CURSOR c_get_budget_version_id(structure_version_id PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE) IS
	SELECT budget_version_id
	FROM pa_budget_versions
	WHERE project_structure_version_id = structure_version_id
	AND wp_version_flag = 'Y';

CURSOR c_get_missing_asgmts(old_structure_version_id PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	   						new_structure_version_id PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	   						old_budget_version_id PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE,
	   						new_budget_version_id PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE) IS
	SELECT
	pev.element_version_id,
	ra_old.resource_list_member_id,
	0,
	ra_old.planning_start_date,
	ra_old.planning_end_date,
	pevs.scheduled_start_date,
	pevs.scheduled_finish_date,
	0,
	'Y',
	ra_old.ta_display_flag
	FROM
	pa_resource_assignments ra_old,
	pa_proj_element_versions pev,
	pa_proj_elem_ver_schedule pevs
	WHERE
	ra_old.budget_version_id = old_budget_version_id AND
	PA_PROGRESS_UTILS.Check_Prog_Exists_And_Delete
	(
		ra_old.project_id,
		ra_old.task_id,
		'PA_ASSIGNMENTS',
		ra_old.resource_list_member_id,
		'WORKPLAN',
		'N'
	) = 'Y' AND
	pev.parent_structure_version_id = new_structure_version_id AND
	pev.proj_element_id = ra_old.task_id AND
	pevs.element_version_id = pev.element_version_id AND
	NOT EXISTS
	(
		SELECT
		ra_new.resource_assignment_id
		FROM
		pa_resource_assignments ra_new
		WHERE
		ra_new.resource_list_member_id = ra_old.resource_list_member_id AND
		ra_new.task_id = ra_old.task_id AND
		ra_new.project_id = ra_old.project_id AND
		ra_new.budget_version_id = new_budget_version_id
	);

BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_msg_count := 0;
	x_msg_data := NULL;

	IF p_old_structure_version_id IS NOT NULL THEN

		IF p_new_budget_version_id IS NOT NULL THEN

			l_new_budget_version_id := p_new_budget_version_id;

		ELSE

			OPEN c_get_budget_version_id(p_new_structure_version_id);
			FETCH c_get_budget_version_id INTO l_new_budget_version_id;
			CLOSE c_get_budget_version_id;

		END IF; -- IF p_new_budget_version_id IS NOT NULL

		OPEN c_get_budget_version_id(p_old_structure_version_id);
		FETCH c_get_budget_version_id INTO l_old_budget_version_id;
		CLOSE c_get_budget_version_id;

		OPEN c_get_missing_asgmts(p_old_structure_version_id,
			 					  p_new_structure_version_id,
			 					  l_old_budget_version_id,
								  l_new_budget_version_id);
		FETCH c_get_missing_asgmts BULK COLLECT INTO l_element_version_id_tbl,
			  					   					 l_resource_list_member_id_tbl,
													 l_planned_people_effort_tbl,
													 l_planning_start_date_tbl,
													 l_planning_end_date_tbl,
													 l_task_start_date_tbl,
													 l_task_end_date_tbl,
													 l_quantity_tbl,
													 l_unplanned_flag_tbl,
													 l_ta_display_flag_tbl;
		CLOSE c_get_missing_asgmts;

		IF l_element_version_id_tbl.COUNT > 0 THEN
			PA_FP_PLANNING_TRANSACTION_PUB.Add_Planning_Transactions
			(
				p_context                     => 'TASK_ASSIGNMENT',
				p_one_to_one_mapping_flag     => 'Y',
				p_project_id                  => p_project_id,
				p_budget_version_id           => l_new_budget_version_id,
				p_struct_elem_version_id      => p_new_structure_version_id,
				p_task_elem_version_id_tbl    => l_element_version_id_tbl,
				p_resource_list_member_id_tbl => l_resource_list_member_id_tbl,
				p_planned_people_effort_tbl   => l_planned_people_effort_tbl,
				p_start_date_tbl              => l_task_start_date_tbl,
				p_end_date_tbl                => l_task_end_date_tbl,
				p_planning_start_date_tbl     => l_task_start_date_tbl,
				p_planning_end_date_tbl       => l_task_end_date_tbl,
				p_quantity_tbl                => l_quantity_tbl,
				p_unplanned_flag_tbl          => l_unplanned_flag_tbl,
				p_skip_duplicates_flag        => 'Y',
				x_return_status               => x_return_status,
				x_msg_count                   => x_msg_count,
				x_msg_data                    => x_msg_data
			);

			-- Workaround to the fact that Add_Planning_Transactions only accept planning_*_date
			-- which are then stemed to schedule_*_date in Validate_Create_Assignment
			FORALL i IN 1..l_element_version_id_tbl.COUNT
				UPDATE pa_resource_assignments
				SET planning_start_date = l_planning_start_date_tbl(i),
					planning_end_date = l_planning_end_date_tbl(i),
					ta_display_flag = l_ta_display_flag_tbl(i)
				WHERE wbs_element_version_id = l_element_version_id_tbl(i)
				AND resource_list_member_id = l_resource_list_member_id_tbl(i);
		END IF;

	END IF; -- IF p_old_structure_version_id IS NOT NULL

EXCEPTION
	WHEN OTHERS THEN
		-- Set the exception message and the stack
		FND_MSG_PUB.Add_Exc_Msg( p_pkg_name			=> 'PA_TASK_ASSIGNMENTS_PVT.Copy_Missing_Unplanned_Asgmts',
								 p_procedure_name	=> PA_DEBUG.G_Err_Stack );
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
		RAISE;  -- This is optional depending on the needs

END Copy_Missing_Unplanned_Asgmts;


PROCEDURE Check_Period_Details(
   P_BUDGET_VERSION_ID      IN pa_budget_versions.budget_version_id%TYPE,
   p_period_set_name        IN gl_periods.period_set_name%TYPE,
   p_time_phase_code        IN pa_proj_fp_options.cost_time_phased_code%TYPE,
   p_accounted_period_type  IN gl_periods.period_type%TYPE,
   p_pa_period_type         IN gl_periods.period_type%TYPE,
   p_task_name              IN pa_proj_elements.name%TYPE,
   p_rlm_alias              IN pa_resource_list_members.alias%TYPE,
   P_PERIOD_NAME            IN OUT NOCOPY VARCHAR2, -- 4537865
   P_PERIOD_START_DATE      IN OUT NOCOPY DATE, -- 4537865
   P_PERIOD_END_DATE        IN OUT NOCOPY DATE, -- 4537865
   x_return_status          OUT NOCOPY VARCHAR2
  ) IS

  l_period_name               gl_periods.period_name%type := NULL;
  l_period_start_date         gl_periods.start_date%type := NULL;
  l_period_end_date           gl_periods.end_date%type := NULL;


  CURSOR get_period_name_from_dates IS
     	SELECT start_date,
               end_date,
               period_name
       	FROM gl_periods
      	WHERE period_set_name = p_period_set_name
        AND period_type =
		decode(p_time_phase_code,'G',p_accounted_period_type,
        	'P',p_pa_period_type)
        AND start_date = p_period_start_date
        AND end_date = p_period_end_date
        AND adjustment_period_flag = 'N';


  CURSOR get_period_dates_from_name IS
     	SELECT start_date,
               end_date,
               period_name
       	FROM gl_periods
      	WHERE period_set_name = p_period_set_name
        AND period_type =
		decode(p_time_phase_code,'G',p_accounted_period_type,
        	'P',p_pa_period_type)
        AND period_name = p_period_name
        AND adjustment_period_flag = 'N';



  BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF p_time_phase_code <> PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_P
     AND p_time_phase_code <> PA_FP_CONSTANTS_PKG.G_TIME_PHASED_CODE_G THEN
	PA_UTILS.ADD_MESSAGE
        (p_app_short_name => 'PA',
         p_msg_name       => 'PA_INVALID_TIMEPHASE_CODE'
        );
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --dbms_output.put_line('p_period_name:'||p_period_name);

    --1. get dates from period name
    IF p_period_name IS NOT NULL
      AND p_period_name <> FND_API.G_MISS_CHAR
      AND p_period_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR THEN

      OPEN get_period_dates_from_name;
      FETCH get_period_dates_from_name
       INTO l_period_start_date, l_period_end_date, l_period_name;
      CLOSE get_period_dates_from_name;

    --2. get period name from dates
    ELSIF p_period_start_date IS NOT NULL
        AND p_period_start_date <> FND_API.G_MISS_DATE
        AND p_period_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE THEN

      OPEN get_period_name_from_dates;
      FETCH get_period_name_from_dates
       INTO l_period_start_date, l_period_end_date, l_period_name;
      CLOSE get_period_name_from_dates;

    END IF;

    IF l_period_start_date IS NULL THEN
       PA_UTILS.ADD_MESSAGE
        (p_app_short_name => 'PA',
         p_msg_name       => 'PA_INVALID_PERIOD_ERR',
         p_token1         => 'TASK_NAME',
         p_value1         =>  p_task_name,
         p_token2         => 'PL_RES_ALIAS',
         p_value2         =>  p_rlm_alias,
         p_token3         => 'PERIOD_NAME',
         p_value3         => p_period_name,
         p_token4         => 'START_DATE',
         p_value4         => p_period_start_date,
         p_token5         => 'END_DATE',
         p_value5         => p_period_end_date
        );
        RAISE FND_API.G_EXC_ERROR;
    ELSE

      P_PERIOD_NAME          := l_period_name;
      P_PERIOD_START_DATE    := l_period_start_date;
      P_PERIOD_END_DATE      := l_period_end_date;

    END IF;


EXCEPTION

  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
    -- Set the exception message and the stack
    FND_MSG_PUB.Add_Exc_Msg( p_pkg_name	=> 'PA_TASK_ASSIGNMENTS_PVT.Check_Period_Details',
			     p_procedure_name	=> PA_DEBUG.G_Err_Stack );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

    P_PERIOD_NAME       := NULL ; -- 4537865
   P_PERIOD_START_DATE  := NULL ; -- 4537865
   P_PERIOD_END_DATE    := NULL ; -- 4537865

    RAISE;  -- This is optional depending on the needs

END Check_Period_Details;


END  PA_TASK_ASSIGNMENTS_PVT;

/
