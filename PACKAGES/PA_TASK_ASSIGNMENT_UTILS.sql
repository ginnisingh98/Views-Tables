--------------------------------------------------------
--  DDL for Package PA_TASK_ASSIGNMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_ASSIGNMENT_UTILS" AUTHID CURRENT_USER AS
-- $Header: PATAUTLS.pls 120.11 2008/03/20 09:00:33 rthumma noship $


  p_multi_asgmt_req_flag VARCHAR2(1) := 'N'; /* Added for bug 3724780.*/
  p_assignment_effort    NUMBER;

  g_require_progress_rollup VARCHAR(1) := 'N'; --  Bug 4492493
  g_process_flow VARCHAR(20) := null; --  Bug 4646016

/* This record type is used to pass the details of the tasks that should to be
   processed by the TA validation API. This record type will be passed to the TA
   validation API from add_planning_transactions API and update_planninng_transactions API*/
TYPE task_rec_type IS RECORD
(
       project_id                NUMBER                                                    DEFAULT NULL
      ,task_elem_version_id      NUMBER                                                    DEFAULT NULL
      ,struct_elem_version_id    NUMBER                                                    DEFAULT NULL
      ,task_name                 pa_proj_elements.name%TYPE                                DEFAULT NULL
      ,task_number               pa_proj_elements.element_number%TYPE                      DEFAULT NULL
      ,start_date                pa_resource_assignments.planning_start_date%TYPE          DEFAULT NULL
      ,end_date                  pa_resource_assignments.planning_end_date%TYPE            DEFAULT NULL
      ,planned_people_effort     pa_resource_assignments.total_plan_quantity%TYPE          DEFAULT NULL
      ,planned_equip_effort      pa_resource_assignments.total_plan_quantity%TYPE          DEFAULT NULL
      ,latest_eff_pub_flag       pa_proj_elem_ver_structure.latest_eff_published_flag%TYPE DEFAULT NULL
);

/* This record type is used to pass the details of the resource assignments that should to be
   processed by the TA validation API. This record type will be passed to the TA
   validation API from add_planning_transactions API and update_planninng_transactions API*/
TYPE resource_rec_type IS RECORD
(
       resource_assignment_id   NUMBER                                                  DEFAULT NULL
      ,assignment_description   pa_resource_assignments.assignment_description%TYPE     DEFAULT NULL
      ,resource_list_member_id  NUMBER                                                  DEFAULT NULL
      ,planning_resource_alias  pa_resource_list_members.alias%TYPE                     DEFAULT NULL
      ,resource_class_flag      pa_resource_list_members.resource_class_flag%TYPE       DEFAULT NULL
      ,resource_class_code      pa_resource_assignments.resource_class_code%TYPE        DEFAULT NULL
      ,resource_class_id        NUMBER                                                  DEFAULT NULL
      ,res_type_code            pa_resource_assignments.res_type_code%TYPE              DEFAULT NULL
      ,resource_code            VARCHAR2(30)                                            DEFAULT NULL
      ,resource_name            VARCHAR2(240)                                            DEFAULT NULL
      ,person_id                NUMBER                                                  DEFAULT NULL
      ,job_id                   NUMBER                                                  DEFAULT NULL
      ,person_type_code         pa_resource_assignments.person_type_code%TYPE           DEFAULT NULL
      ,bom_resource_id          NUMBER                                                  DEFAULT NULL
      ,non_labor_resource       pa_resource_assignments.non_labor_resource%TYPE         DEFAULT NULL
      ,inventory_item_id        NUMBER                                                  DEFAULT NULL
      ,item_category_id         NUMBER                                                  DEFAULT NULL
      ,project_role_id          NUMBER                                                  DEFAULT NULL
      ,project_role_name        pa_proj_roles_v.meaning%TYPE                            DEFAULT NULL
      ,organization_id          NUMBER                                                  DEFAULT NULL
      ,organization_name        hr_all_organization_units.name%TYPE                     DEFAULT NULL
      ,fc_res_type_code         pa_resource_assignments.fc_res_type_code%TYPE           DEFAULT NULL
      ,financial_category_code  VARCHAR2(30)                                            DEFAULT NULL
      ,expenditure_type         pa_resource_assignments.expenditure_type%TYPE           DEFAULT NULL
      ,expenditure_category     pa_resource_assignments.expenditure_category%TYPE       DEFAULT NULL
      ,event_type               pa_resource_assignments.event_type%TYPE                 DEFAULT NULL
      ,revenue_category_code    pa_resource_assignments.revenue_category_code%TYPE      DEFAULT NULL
      ,supplier_id              NUMBER                                                  DEFAULT NULL
      ,project_assignment_id    NUMBER                                                  DEFAULT NULL
      ,unit_of_measure          pa_resource_assignments.unit_of_measure%TYPE            DEFAULT NULL
      ,spread_curve_id          NUMBER                                                  DEFAULT NULL
      ,etc_method_code          pa_resource_assignments.etc_method_code%TYPE            DEFAULT NULL
      ,mfc_cost_type_id         NUMBER                                                  DEFAULT NULL
      ,procure_resource_flag    pa_resource_assignments.procure_resource_flag%TYPE      DEFAULT NULL
      ,incurred_by_res_flag     pa_resource_assignments.incurred_by_res_flag%TYPE       DEFAULT NULL
      ,incur_by_resource_code   VARCHAR2(30)                                            DEFAULT NULL
      ,incur_by_resource_name   VARCHAR2(240)                                           DEFAULT NULL
      ,Incur_by_res_class_code  pa_resource_assignments.Incur_by_res_class_code%TYPE    DEFAULT NULL
      ,Incur_by_role_id         NUMBER                                                  DEFAULT NULL
      ,use_task_schedule_flag   pa_resource_assignments.use_task_schedule_flag%TYPE     DEFAULT NULL
      ,planning_start_date      pa_resource_assignments.planning_start_date%TYPE        DEFAULT NULL
      ,planning_end_date        pa_resource_assignments.planning_end_date%TYPE          DEFAULT NULL
      ,schedule_start_date     pa_resource_assignments.schedule_start_date%TYPE        DEFAULT NULL
      ,schedule_end_date       pa_resource_assignments.schedule_end_date%TYPE          DEFAULT NULL
      ,total_quantity           pa_resource_assignments.total_plan_quantity%TYPE        DEFAULT NULL
      ,total_raw_cost           pa_resource_assignments.total_plan_raw_cost%TYPE        DEFAULT NULL
      ,override_currency_code   pa_fp_txn_currencies.txn_currency_code%TYPE             DEFAULT NULL
      ,billable_percent         pa_resource_assignments.billable_percent%TYPE           DEFAULT NULL
      ,cost_rate_override       NUMBER                                                  DEFAULT NULL
      ,burdened_rate_override   NUMBER                                                  DEFAULT NULL
      ,sp_fixed_date            pa_resource_assignments.sp_fixed_date%TYPE              DEFAULT NULL
      ,named_role               pa_resource_assignments.named_role%TYPE                 DEFAULT NULL
      ,financial_category_name  VARCHAR2(80)                                            DEFAULT NULL
      ,supplier_name            VARCHAR2(240)                                            DEFAULT NULL
      ,wbs_element_version_id   NUMBER                                                  DEFAULT NULL
      ,unplanned_flag           VARCHAR2(1)                                             DEFAULT NULL
      ,org_id                   pa_resource_assignments.rate_expenditure_org_id%TYPE    DEFAULT NULL
      ,rate_based_flag          pa_resource_assignments.rate_based_flag%TYPE            DEFAULT NULL
      ,rate_expenditure_type    pa_resource_assignments.rate_expenditure_type%TYPE      DEFAULT NULL
      ,rate_func_curr_code      pa_resource_assignments.rate_exp_func_curr_code%TYPE    DEFAULT NULL
	  --parameter not used for resource defaults anymore..
      -- ,rate_incurred_by_org_id  pa_resource_assignments.rate_incurred_by_organz_id%TYPE DEFAULT NULL
      ,incur_by_res_type        VARCHAR2(30)                                            DEFAULT NULL
      ,task_id                  pa_resource_assignments.task_id%TYPE                    DEFAULT NULL
      ,structure_version_id     pa_proj_element_versions.parent_structure_version_id%TYPE DEFAULT NULL
      ,ATTRIBUTE_CATEGORY       pa_resource_assignments.attribute_category%TYPE         DEFAULT NULL
      ,ATTRIBUTE1               pa_resource_assignments.attribute1%TYPE                 DEFAULT NULL
      ,ATTRIBUTE2               pa_resource_assignments.attribute2%TYPE                 DEFAULT NULL
      ,ATTRIBUTE3               pa_resource_assignments.attribute3%TYPE                 DEFAULT NULL
      ,ATTRIBUTE4               pa_resource_assignments.attribute4%TYPE                 DEFAULT NULL
      ,ATTRIBUTE5               pa_resource_assignments.attribute5%TYPE                 DEFAULT NULL
      ,ATTRIBUTE6               pa_resource_assignments.attribute6%TYPE                 DEFAULT NULL
      ,ATTRIBUTE7               pa_resource_assignments.attribute7%TYPE                 DEFAULT NULL
      ,ATTRIBUTE8               pa_resource_assignments.attribute8%TYPE                 DEFAULT NULL
      ,ATTRIBUTE9               pa_resource_assignments.attribute9%TYPE                 DEFAULT NULL
      ,ATTRIBUTE10              pa_resource_assignments.attribute10%TYPE                DEFAULT NULL
      ,ATTRIBUTE11              pa_resource_assignments.attribute11%TYPE                DEFAULT NULL
      ,ATTRIBUTE12              pa_resource_assignments.attribute12%TYPE                DEFAULT NULL
      ,ATTRIBUTE13              pa_resource_assignments.attribute13%TYPE                DEFAULT NULL
      ,ATTRIBUTE14              pa_resource_assignments.attribute14%TYPE                DEFAULT NULL
      ,ATTRIBUTE15              pa_resource_assignments.attribute15%TYPE                DEFAULT NULL
      ,ATTRIBUTE16              pa_resource_assignments.attribute16%TYPE                DEFAULT NULL
      ,ATTRIBUTE17              pa_resource_assignments.attribute17%TYPE                DEFAULT NULL
      ,ATTRIBUTE18              pa_resource_assignments.attribute18%TYPE                DEFAULT NULL
      ,ATTRIBUTE19              pa_resource_assignments.attribute19%TYPE                DEFAULT NULL
      ,ATTRIBUTE20              pa_resource_assignments.attribute20%TYPE                DEFAULT NULL
      ,ATTRIBUTE21              pa_resource_assignments.attribute21%TYPE                DEFAULT NULL
      ,ATTRIBUTE22              pa_resource_assignments.attribute22%TYPE                DEFAULT NULL
      ,ATTRIBUTE23              pa_resource_assignments.attribute23%TYPE                DEFAULT NULL
      ,ATTRIBUTE24              pa_resource_assignments.attribute24%TYPE                DEFAULT NULL
      ,ATTRIBUTE25              pa_resource_assignments.attribute25%TYPE                DEFAULT NULL
      ,ATTRIBUTE26              pa_resource_assignments.attribute26%TYPE                DEFAULT NULL
      ,ATTRIBUTE27              pa_resource_assignments.attribute27%TYPE                DEFAULT NULL
      ,ATTRIBUTE28              pa_resource_assignments.attribute28%TYPE                DEFAULT NULL
      ,ATTRIBUTE29              pa_resource_assignments.attribute29%TYPE                DEFAULT NULL
      ,ATTRIBUTE30              pa_resource_assignments.attribute30%TYPE                DEFAULT NULL
	  ,scheduled_delay			pa_resource_assignments.scheduled_delay%TYPE			DEFAULT NULL
);

--
-- Global Variables
--
g_resource_assignment_id       pa_resource_assignments.resource_assignment_id%TYPE := -999;

g_baselined_asgmt_start_date   pa_resource_assignments.planning_end_date%TYPE;
g_baselined_asgmt_end_date     pa_resource_assignments.planning_start_date%TYPE;

g_baselined_planned_qty   pa_resource_assignments.total_plan_quantity%TYPE;
g_bl_planned_bur_cost_txn_cur pa_resource_assignments.total_plan_raw_cost%TYPE;
g_bl_bur_cost_proj_cur    pa_resource_assignments.total_project_burdened_cost%TYPE;
g_bl_bur_cost_projfunc_cur pa_resource_assignments.total_plan_burdened_cost%TYPE;
g_bl_planned_raw_cost_txn_cur pa_budget_lines.txn_raw_cost%TYPE;
g_bl_raw_cost_proj_cur    pa_resource_assignments.total_project_raw_cost%TYPE;
g_bl_raw_cost_projfunc_cur pa_resource_assignments.total_plan_raw_cost%TYPE;

g_pl_resource_assignment_id       pa_resource_assignments.resource_assignment_id%TYPE := -999;

g_planned_quantity         pa_budget_lines.quantity%TYPE;
g_planned_bur_cost_txn_cur pa_budget_lines.txn_burdened_cost%TYPE;
g_planned_raw_cost_txn_cur pa_budget_lines.txn_raw_cost%TYPE;
g_actual_quantity          pa_budget_lines.init_quantity%TYPE;
g_act_bur_cost_txn_cur     pa_budget_lines.init_burdened_cost%TYPE;
g_act_raw_cost_txn_cur     pa_budget_lines.init_raw_cost%TYPE;
g_avg_raw_cost_rate        pa_budget_lines.txn_standard_cost_rate%TYPE;
g_avg_bur_cost_rate        pa_budget_lines.burden_cost_rate%TYPE;

g_cur_resource_assignment_id     pa_resource_assignments.resource_assignment_id%TYPE := -999;

g_txn_currency_code        pa_budget_lines.txn_currency_code%TYPE;

g_ta_display_flag          VARCHAR2(1) := 'N';
g_apply_progress_flag      VARCHAR2(1) := 'N'; -- Bug 4286558

--
--  FUNCTION
--              Get_Task_Resources
--  PURPOSE
--              Returns VARCHAR - a string of planning resource aliases on a given task.
--
FUNCTION Get_Task_Resources(p_element_version_id IN NUMBER) RETURN VARCHAR2;

--
--  FUNCTION
--              Check_Asgmt Exists in Task
--  PURPOSE
--              Returns VARCHAR - 'Y' if task assignment exists in the given workplan task version.
--
FUNCTION Check_Asgmt_Exists_In_Task(p_element_version_id IN NUMBER) RETURN VARCHAR2;

--
--  FUNCTION
--              	Check_Task_Asgmt_Exists
--  PURPOSE
--  If task assignment exists in the given financial task on the given ei date
--  for a person, return 'Y'; otherwise, return 'N'

FUNCTION Check_Task_Asgmt_Exists(
         p_person_id IN NUMBER,
		 p_financial_task_id IN NUMBER,
         p_ei_date IN DATE) RETURN VARCHAR2;

--
--  FUNCTION
--              Compare Dates
--  PURPOSE
--              Returns VARCHAR - 'E ' if first date is earlier than second and
--                                 'L' otherwise.
--
FUNCTION Compare_Dates(p_first_date IN DATE, p_second_date IN DATE) RETURN VARCHAR2;

-- This procedure will Adjust the Task Assignment Dates
-- upon changes on a Task's Scheduled Dates.
PROCEDURE Adjust_Asgmt_Dates(
            p_context                IN   VARCHAR2 DEFAULT 'UPDATE',
            p_element_version_id     IN   NUMBER,
			p_old_task_sch_start     IN   DATE,
			p_old_task_sch_finish    IN   DATE DEFAULT NULL,
			p_new_task_sch_start     IN   DATE,
			p_new_task_sch_finish    IN   DATE,
            x_res_assignment_id_tbl  OUT NOCOPY  SYSTEM.PA_NUM_TBL_TYPE,
            x_planning_start_tbl     OUT NOCOPY  SYSTEM.PA_DATE_TBL_TYPE,
            x_planning_end_tbl       OUT NOCOPY  SYSTEM.PA_DATE_TBL_TYPE,
			x_return_status          OUT NOCOPY  VARCHAR2);

TYPE l_task_rec_tbl_type IS TABLE OF task_rec_type
INDEX BY BINARY_INTEGER;
TYPE l_resource_rec_tbl_type IS TABLE OF resource_rec_type
INDEX BY BINARY_INTEGER;



-- This procedure will Validate the Creation
-- and also obtain task assignment specific attributes upon
-- Planning transaction creation.

PROCEDURE Validate_Create_Assignment
		  			(
                        p_calling_context              IN            VARCHAR2 DEFAULT NULL,  -- Added for Bug 6856934
                        p_one_to_one_mapping_flag      IN            VARCHAR2 DEFAULT 'N',
                        p_task_rec_tbl                 IN            l_task_rec_tbl_type,
			p_task_assignment_tbl          IN OUT NOCOPY l_resource_rec_tbl_type,
			x_del_task_level_rec_code_tbl  OUT NOCOPY     SYSTEM.PA_VARCHAR2_30_TBL_TYPE ,
			x_return_status                OUT NOCOPY     VARCHAR2
						);

-- This procedure will Validate the Updation on Planning Transaction

PROCEDURE Validate_Update_Assignment
		  			(
                        p_calling_context        IN            VARCHAR2 DEFAULT NULL,  -- Added for Bug 6856934
			p_task_assignment_tbl    IN OUT NOCOPY l_resource_rec_tbl_type,
			x_return_status             OUT NOCOPY VARCHAR2
					);

-- This procedure will Validate the Deletion of Planning Transactions
-- and return Assignments that can be deleted.
--Bug 4951422. Added the OUT parameter x_task_assmt_ids_tbl. This tbl will be populated
--when p_task_or_res parameter is 'TASKS'. This table will contain the resource assignment ids
--that are eligible for deletion so that delete_planning_transactions uses these ids instead
--of element_version_ids for deleting data
PROCEDURE Validate_Delete_Assignment
		  (     p_context                    IN   VARCHAR2,
                        p_calling_context            IN            VARCHAR2 DEFAULT NULL,  -- Added for Bug 6856934
                        p_task_or_res                IN   VARCHAR2 DEFAULT 'ASSIGNMENT',
		        p_elem_ver_id_tbl            IN   SYSTEM.PA_NUM_TBL_TYPE,
		        p_task_name_tbl              IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE,
		        p_task_number_tbl            IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE,
		        p_resource_assignment_id_tbl IN   SYSTEM.PA_NUM_TBL_TYPE,
		        x_delete_task_flag_tbl       OUT  NOCOPY SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
		        x_delete_asgmt_flag_tbl      OUT  NOCOPY SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
			x_task_assmt_ids_tbl         OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --Bug 4951422
		        x_return_status              OUT  NOCOPY VARCHAR2);

-- This procedure will Validate the Copying of Planning Transaction
-- and return Assignments that can be copied.

PROCEDURE Validate_Copy_Assignment(
            p_src_project_id         IN   NUMBER,
            p_target_project_id      IN   NUMBER,
            p_src_elem_ver_id_tbl    IN   SYSTEM.PA_NUM_TBL_TYPE,
            p_targ_elem_ver_id_tbl   IN   SYSTEM.PA_NUM_TBL_TYPE,
            p_copy_people_flag       IN   VARCHAR2,
            p_copy_equip_flag        IN   VARCHAR2,
            p_copy_mat_item_flag     IN   VARCHAR2,
            p_copy_fin_elem_flag     IN   VARCHAR2,
            p_copy_external_flag     IN   VARCHAR2   DEFAULT 'N',
            x_resource_rec_tbl       OUT NOCOPY l_resource_rec_tbl_type,
            x_calculate_flag         OUT NOCOPY VARCHAR2,
			x_rbs_diff_flag          OUT NOCOPY VARCHAR2,
            x_return_status          OUT NOCOPY VARCHAR2 ) ;



-- This function will Validates the Planning Resources for a Workplan

FUNCTION Validate_Pl_Res_For_WP( p_resource_list_member_id  IN   NUMBER ) RETURN VARCHAR2 ;

-- This function will Validate whether a financial category is valid for workplan
-- Returns error if the given fc_res_type_code is 'REVENUE_CATEGORY' or 'EVENT_TYPE'.

FUNCTION Validate_Fin_Cat_For_WP( p_fc_res_type_code  IN  VARCHAR2) RETURN VARCHAR2;

--Function below calls both pa_proj_element_utils.check_edit_task_ok &
--PA_PROJECT_STRUCTURE_UTILS.GET_UPDATE_WBS_FLAG
--Needs Project_Id
--Structure Version Id & Element_Id will be queried based on
--either Element Version Id or Task Assignment Id if not passed.

FUNCTION Check_Edit_Task_Ok(P_PROJECT_ID	   IN NUMBER default NULL,
   P_STRUCTURE_VERSION_ID	IN NUMBER default NULL,
   P_CURR_STRUCT_VERSION_ID IN NUMBER default NULL,
   P_Element_Id IN NUMBER default NULL,
   P_Element_Version_Id IN NUMBER default NULL,
   P_Task_Assignment_Id IN NUMBER default NULL) RETURN VARCHAR2;

FUNCTION Get_WP_Resource_List_Id(
            p_project_id         IN   NUMBER)
RETURN   pa_proj_fp_options.all_resource_list_id%TYPE;

/*  This function find all task assignments a resource is assigned to, and find
    the min/max dates for those assignments.
    p_resource_list_member_id: the resource id.
    p_mode: MAX or MIN
    p_project_id: tasks of which project.
    p_budget_version_id: budget version.
    p_unstaffed_only: Y or N, whether only task assigments without team role created, or all
                      task assignments.
*/
FUNCTION Get_Min_Max_Task_Asgmt_Date(p_resource_list_member_id IN NUMBER, p_mode IN VARCHAR2,
  p_project_id IN NUMBER, p_budget_version_id IN NUMBER, p_unstaffed_only IN VARCHAR2 default 'N') RETURN DATE;

FUNCTION Get_Class_UOM(p_project_id IN NUMBER,
                       p_budget_version_id IN NUMBER,
					   p_class IN VARCHAR2 ) RETURN VARCHAR2;

FUNCTION Get_Role(p_resource_list_member_id IN NUMBER default NULL,
                  p_project_id IN NUMBER default NULL) RETURN VARCHAR2;

FUNCTION Get_Team_Role(p_resource_list_member_id IN NUMBER default NULL,
                       p_project_id IN NUMBER default NULL) RETURN VARCHAR2;

FUNCTION Get_Assignment_Effort RETURN NUMBER ;

FUNCTION get_baselined_asgmt_dates(
  p_project_id             IN pa_projects_all.project_id%TYPE,
  p_element_version_id     IN pa_proj_element_versions.element_version_id%TYPE,
  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,
  p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE,
  p_proj_currency_code     IN pa_projects_all.project_currency_code%TYPE,
  p_projfunc_currency_code IN pa_projects_all.projfunc_currency_code%TYPE,
  p_code IN VARCHAR2) RETURN DATE;

FUNCTION get_baselined_asgmt_amounts(
  p_project_id             IN pa_projects_all.project_id%TYPE,
  p_element_version_id     IN pa_proj_element_versions.element_version_id%TYPE,
  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,
  p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE,
  p_proj_currency_code     IN pa_projects_all.project_currency_code%TYPE,
  p_projfunc_currency_code IN pa_projects_all.projfunc_currency_code%TYPE,
  p_code IN VARCHAR2) RETURN NUMBER;

/*Commented for bug#6798529
FUNCTION get_planned_asgmt_amounts(
  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,
  p_code IN VARCHAR2) RETURN NUMBER;
*/

FUNCTION get_planned_currency_info(
  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,
  p_project_id IN pa_projects_all.project_id%TYPE,
  p_code IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_task_level_record(
  p_project_id             IN pa_projects_all.project_id%TYPE,
  p_element_version_id     IN pa_proj_element_versions.element_version_id%TYPE
) RETURN NUMBER;

--Internal Utiilities to convert char/num/date to NULL or fnd_api.g_miss_xx depending on p_mode of 'F' or 'B'
function gchar(p_char IN VARCHAR2 default NULL, p_mode IN VARCHAR2 default 'F') return varchar2 ;
function gnum(p_num IN NUMBER default NULL, p_mode IN VARCHAR2 default 'F') return NUMBER;
function gdate(p_date IN DATE default NULL, p_mode IN VARCHAR2 default 'F') return DATE ;

PROCEDURE set_table_stats(ownname IN VARCHAR2,
                          tabname IN VARCHAR2,
                          numrows IN NUMBER,
                          numblks IN NUMBER,
                          avgrlen IN NUMBER);
--BUG 4373411 , rtarway, DHIER refresh rates
PROCEDURE CHECK_EDIT_OK( p_api_version_number    IN   NUMBER   := 1.0
, p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE
, p_commit                IN   VARCHAR2 := FND_API.G_FALSE
, p_project_id            IN NUMBER
, p_pa_structure_version_id IN NUMBER
, px_budget_version_id    IN OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2 			  --File.Sql.39 bug 4440895
, x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_msg_count     OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

-- Bug 4492493
FUNCTION Is_Progress_Rollup_Required(
  p_project_id             IN pa_projects_all.project_id%TYPE
) RETURN VARCHAR2;

/* Added for bug 6014706*/
FUNCTION is_uncategorized_res_list
( p_resource_list_id        IN pa_resource_lists_all_bg.resource_list_id%TYPE := NULL
  ,p_project_id             IN pa_projects_all.project_id%TYPE := NULL
) RETURN   VARCHAR2;
/* End for bug 6014706*/

end PA_TASK_ASSIGNMENT_UTILS;



/
