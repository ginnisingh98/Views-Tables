--------------------------------------------------------
--  DDL for Package Body PA_FP_ADJUSTMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_ADJUSTMENT_UTILS" AS
-- $Header: PAFPADJB.pls 120.5 2007/11/26 07:50:38 vgovvala ship $

P_DEBUG_MODE varchar2(1) :=  NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
L_MODULE varchar2(100)   :=  'PA_FP_ADJUSTMENT_UTILS';
L_FuncProc varchar2(250) :=  'DEFAULT';
li_message_level NUMBER  :=  1;
li_curr_level NUMBER     :=  FND_LOG.G_CURRENT_RUNTIME_LEVEL;


-- This procedure will Get Summary Information on a
-- given Budget Version Id/Name

PROCEDURE Get_Summary_Info
( p_project_id                   IN NUMBER
  ,p_cost_budget_version_id      IN  NUMBER
  ,p_rev_budget_version_id       IN  NUMBER
  ,p_WBS_Element_Id	         IN  NUMBER    DEFAULT NULL
  ,p_RBS_Element_Id	         IN  NUMBER    DEFAULT NULL
  ,p_WBS_Structure_Version_Id    IN  NUMBER    DEFAULT NULL
  ,p_RBS_Version_Id              IN  NUMBER    DEFAULT NULL
  ,p_WBS_Rollup_Flag             IN  VARCHAR2
  ,p_RBS_Rollup_Flag             IN  VARCHAR2
  ,p_resource_tbl_flag           IN  VARCHAR2  DEFAULT 'N'
  ,p_resource_assignment_id_tbl  IN  SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
  ,p_txn_currency_code_tbl       IN  SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
  ,x_version                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_version_name                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_project_id                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_structure_version_id        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_version                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_version_name            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_task_number                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_task_name                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_resource_name               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_plan_setup                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_plan_type_name              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_fin_plan_type_id            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_version_type                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_plan_type_name          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_workplan_flag           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_plan_setup              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_plan_class_code         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_fin_plan_type_id        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_version_type         	 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_workplan_flag               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_plan_class_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_raw_cost                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_burdened_cost            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_revenue                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_currency                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_raw_cost                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_burdened_cost           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_revenue                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_currency                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_margin                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_margin                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_margin_percent              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_total_labor_hours           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_total_equip_hours           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_total_labor_hours       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_total_equip_hours       OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
  ,x_resource_assignment_id_tbl  OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
  ,x_txn_currency_code_tbl       OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE --File.Sql.39 bug 4440895
  ,x_workplan_costs_enabled_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                    OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

TYPE  DYNAMIC_CUR IS REF CURSOR;
l_cur DYNAMIC_CUR;
l_sql VARCHAR2(32767);

l_predicate1 VARCHAR2(32767);
l_curr_code_predicate VARCHAR(32767);

-- Check when to account for 'Cost and revenue separately' with diff.
-- fin plan option level code..

l_task_name   pa_proj_elements.name%TYPE;
l_task_number pa_proj_elements.element_number%TYPE;

--C1_Plan_Info_Rev C1_Plan_Info%ROWTYPE;
l_margin_code            VARCHAR2(240);
l_rev_margin_code        VARCHAR2(240);
l_labor_res_class        VARCHAR2(30) := 'PEOPLE';
l_equip_res_class        VARCHAR2(30) := 'EQUIPMENT';
l_msg_count              NUMBER;
l_msg_data               VARCHAR2(4000);
l_report_using           VARCHAR2(30);

l_resource_assignment_id NUMBER;
l_currency_code          VARCHAR2(15);
l_pfc_raw_cost           NUMBER;
l_pfc_burdened_cost      NUMBER;
l_pc_raw_cost            NUMBER;
l_pc_burdened_cost       NUMBER;
l_pc_revenue             NUMBER;
l_pfc_revenue            NUMBER;
l_labor_hours            NUMBER;
l_equip_hours            NUMBER;
l_rev_labor_hours        NUMBER;
l_rev_equip_hours        NUMBER;

l_pfc_raw_cost_total      NUMBER := 0;
l_pfc_burdened_cost_total NUMBER := 0;
l_pc_raw_cost_total       NUMBER := 0;
l_pc_burdened_cost_total  NUMBER := 0;
l_pc_revenue_total        NUMBER := 0;
l_pfc_revenue_total       NUMBER := 0;
l_labor_hours_total       NUMBER := 0;
l_equip_hours_total       NUMBER := 0;
l_rev_labor_hours_total   NUMBER := 0;
l_rev_equip_hours_total   NUMBER := 0;

CURSOR C1_Plan_Info(p_budget_version_id IN NUMBER) IS
SELECT
B.VERSION_NUMBER,
B.VERSION_NAME,
B.PROJECT_ID,
DECODE(b.wp_version_flag,'Y',B.PROJECT_STRUCTURE_VERSION_ID,
       PA_PROJECT_STRUCTURE_UTILS.GET_FIN_STRUC_VER_ID(b.project_id )),
B.FIN_PLAN_TYPE_ID,
B.VERSION_TYPE,
--B.RECORD_VERSION_NUMBER,
A1.NAME PLAN_TYPE_NAME,
B.WP_VERSION_FLAG,
C.FIN_PLAN_PREFERENCE_CODE PLAN_SETUP,
A.PLAN_CLASS_CODE,
C.MARGIN_DERIVED_FROM_CODE,
C.report_labor_hrs_from_code,
C.track_workplan_costs_flag
FROM
PA_FIN_PLAN_TYPES_B A,
PA_FIN_PLAN_TYPES_TL A1,
PA_BUDGET_VERSIONS B,
PA_PROJ_FP_OPTIONS C
WHERE
A.FIN_PLAN_TYPE_ID = B.FIN_PLAN_TYPE_ID
AND A.FIN_PLAN_TYPE_ID = A1.FIN_PLAN_TYPE_ID
AND B.PROJECT_ID = C.PROJECT_ID
AND B.FIN_PLAN_TYPE_ID = C.FIN_PLAN_TYPE_ID
AND B.BUDGET_VERSION_ID = C.FIN_PLAN_VERSION_ID
AND C.FIN_PLAN_OPTION_LEVEL_CODE = 'PLAN_VERSION'
AND B.BUDGET_VERSION_ID = p_budget_version_id
AND A1.Language = userenv('LANG');

CURSOR C1_Currency_Info(p_project_id IN NUMBER) IS
SELECT project_currency_code, projfunc_currency_code
FROM pa_projects_all
WHERE project_id = p_project_id;

CURSOR C1_Task_Info(p_wbs_element_id IN NUMBER) IS
SELECT pe.name task_name, pe.element_number task_number
FROM pa_proj_elements pe
WHERE pe.proj_element_id = p_wbs_element_id;

CURSOR C2_Task_Info(p_resource_assignment_id IN NUMBER) IS
SELECT pe.name task_name, pe.element_number task_number
FROM pa_proj_elements pe, Pa_resource_assignments ra
WHERE ra.task_id = pe.proj_element_id
and ra.resource_assignment_id = p_resource_assignment_id;

CURSOR C1_Resource_Info(p_rbs_element_id IN NUMBER) IS
SELECT name.resource_name
FROM pa_rbs_elements element, pa_rbs_element_names_tl name
WHERE element.rbs_element_name_id = name.rbs_element_name_id
AND element.rbs_element_id = p_rbs_element_id
AND name.language=userenv('LANG');

CURSOR C_Get_Object_Type (p_wbs_element_id IN NUMBER, p_wbs_structure_version_id IN NUMBER) IS
SELECT object_type
FROM pa_proj_element_versions
WHERE proj_element_id = p_wbs_element_id
AND element_version_id = p_wbs_structure_version_id;

l_structure_version_id varchar2(2000);
l_object_type pa_proj_element_versions.object_type%TYPE;
l_project_level_node_flag varchar2(1) := 'N';
l_workplan_costs_enabled_flag pa_proj_fp_options.track_workplan_costs_flag%TYPE;

BEGIN
--dbms_output.put_line('in sum test test1');

L_FuncProc := 'Get_Summary_Info';
x_return_status := FND_API.G_RET_STS_SUCCESS;

pa_debug.g_err_stage:='Beginning of ' || L_FuncProc;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);

--Obtain Plan Info

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_project_id: ' || p_project_id,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_cost_budget_version_id: ' || p_cost_budget_version_id,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_rev_budget_version_id: ' || p_rev_budget_version_id,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_wbs_element_id: ' || p_wbs_element_id,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_rbs_element_id: ' || p_rbs_element_id,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_wbs_structure_version_id: ' || p_wbs_structure_version_id,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_rbs_version_id: ' || p_rbs_version_id,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_resource_tbl_flag: ' || p_resource_tbl_flag,
                 x_log_level => 3);
  FOR temp_i IN 1..p_resource_assignment_id_tbl.COUNT LOOP
    PA_DEBUG.write(x_module    => L_Module,
                   x_msg       => 'p_resource_assignment_id_tbl(' || temp_i || '): ' || p_resource_assignment_id_tbl(temp_i),
                   x_log_level => 3);
  END LOOP;
  FOR temp_i IN 1..p_txn_currency_code_tbl.COUNT LOOP
    PA_DEBUG.write(x_module    => L_Module,
                   x_msg       => 'p_txn_currency_code_tbl(' || temp_i || '): ' || p_txn_currency_code_tbl(temp_i),
                   x_log_level => 3);
  END LOOP;
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_wbs_rollup_flag: ' || p_wbs_rollup_flag,
                 x_log_level => 3);
  PA_DEBUG.write(x_module    => L_Module,
                 x_msg       => 'p_rbs_rollup_flag: ' || p_rbs_rollup_flag,
                 x_log_level => 3);
END IF;

IF nvl(p_cost_budget_version_id, -1) <> -1 THEN
    OPEN C1_Plan_Info(p_cost_budget_version_id);
    FETCH C1_Plan_Info INTO
         x_version,
         x_version_name,
	 --x_record_version_number,
         x_project_id,
         x_structure_version_id,
         x_fin_plan_type_id,
         x_version_type,
         x_plan_type_name,
         x_workplan_flag,
         x_plan_setup,
         x_plan_class_code,
         l_margin_code,
         l_report_using,
         l_workplan_costs_enabled_flag;
    CLOSE C1_Plan_Info;
END IF;

x_workplan_costs_enabled_flag := l_workplan_costs_enabled_flag;
IF x_workplan_costs_enabled_flag IS NULL THEN
  x_workplan_costs_enabled_flag := 'Y';
END IF;

--Obtain Revenue Separate Plan Info

IF nvl(p_rev_budget_version_id, -1) <> -1 THEN
    OPEN C1_Plan_Info(p_rev_budget_version_id);
    FETCH C1_Plan_Info INTO
	 x_rev_version,
         x_rev_version_name,
         x_project_id,
         --x_rev_rec_vers_number,
         l_structure_version_id,
         x_rev_fin_plan_type_id,
         x_rev_version_type,
         x_rev_plan_type_name,   --Not displaying on UI ??
         x_rev_workplan_flag,
         x_rev_plan_setup,
         x_rev_plan_class_code,
         l_rev_margin_code,
         l_report_using,
         l_workplan_costs_enabled_flag;
    CLOSE C1_Plan_Info;
END IF;

PA_DEBUG.write(x_module    => L_Module,
               x_msg       => 'Got Plan Info',
               x_log_level => 3);

--Obtain Currency Info
IF p_project_id is not NULL THEN
   OPEN C1_Currency_Info(p_project_id);
   FETCH C1_Currency_Info INTO
        x_pc_currency,
        x_pfc_currency;
   CLOSE C1_Currency_Info;
END IF;

PA_DEBUG.write(x_module    => L_Module,
               x_msg       => 'Got Currency Info',
               x_log_level => 3);

--Obtain Task Name/Number.
IF p_WBS_Element_Id is not NULL THEN
  OPEN C1_Task_Info(p_wbs_element_id);
  FETCH C1_Task_Info into x_task_name, x_task_number;
  CLOSE C1_Task_Info;
ELSIF p_resource_assignment_id_tbl IS NOT NULL THEN
-- Check if on a condition of  Single Adjust/multiple resource assignments when to
-- display and when not to display task name/number.
  IF p_resource_assignment_id_tbl.exists(1) THEN
    OPEN C2_Task_Info(p_resource_assignment_id_tbl(1));
    FETCH C2_Task_Info into x_task_name, x_task_number;
    CLOSE C2_Task_Info;
  END IF;
  FOR i IN 1 .. p_resource_assignment_id_tbl.COUNT LOOP
    OPEN C2_Task_Info(p_resource_assignment_id_tbl(i));
    FETCH C2_Task_Info into l_task_name, l_task_number;
    CLOSE C2_Task_Info;
    IF l_task_name <> x_task_name THEN
      x_task_name := 'Multiple';
      x_task_number := 'Multiple';
      EXIT;
    END IF;
  END LOOP;
END IF;

PA_DEBUG.write(x_module    => L_Module,
               x_msg       => 'Got Task Name/Number',
               x_log_level => 3);

--Obtain Resource Name
IF p_RBS_Element_Id	IS NOT NULL THEN
    --dbms_output.put_line('in sum test test6');
	OPEN C1_Resource_Info(p_rbs_element_id);
	FETCH C1_Resource_Info into x_resource_name;
	CLOSE C1_Resource_Info;
END IF;

-- Check if Project Level WBS Node
IF (p_wbs_element_id IS NOT NULL) AND (p_wbs_structure_version_id IS NOT NULL) THEN
  OPEN C_Get_Object_Type(p_wbs_element_id, p_wbs_structure_version_id);
  FETCH C_Get_Object_Type into l_object_type;
  CLOSE C_Get_Object_Type;

  IF l_object_type = 'PA_STRUCTURES' THEN
    l_project_level_node_flag := 'Y';
  END IF;
END IF;

IF p_resource_assignment_id_tbl IS NOT NULL THEN
    FOR j in 1..p_resource_assignment_id_tbl.COUNT LOOP
       IF j > 1 THEN
	   l_predicate1 := l_predicate1 || ',' || p_resource_assignment_id_tbl(j);
       ELSE
	   l_predicate1 := p_resource_assignment_id_tbl(j);
       END IF;
    END LOOP;
END IF;

IF p_txn_currency_code_tbl IS NOT NULL THEN
    FOR j in 1..p_txn_currency_code_tbl.COUNT LOOP
	    IF j > 1 THEN
		  l_curr_code_predicate := l_curr_code_predicate || ',''' || p_txn_currency_code_tbl(j) || '''';
		ELSE
		  l_curr_code_predicate := '''' || p_txn_currency_code_tbl(j) || '''';
		END IF;
    END LOOP;
END IF;

PA_DEBUG.write(x_module    => L_Module,
               x_msg       => 'Got Resource Info',
               x_log_level => 3);

IF l_predicate1 is not null and p_txn_currency_code_tbl.COUNT > 0 THEN
  l_sql :=
  ' SELECT BL.RESOURCE_ASSIGNMENT_ID, BL.TXN_CURRENCY_CODE, ' ||
  ' NVL(SUM(BL.RAW_COST),0) PFC_RAW_COST,' ||
  ' NVL(SUM(BL.BURDENED_COST),0) PFC_BURDENED_COST,' ||
  ' NVL(SUM(BL.PROJECT_RAW_COST),0) PC_RAW_COST, ' ||
  ' NVL(SUM(BL.PROJECT_BURDENED_COST),0) PC_BURDENED_COST, ' ;

  l_sql := l_sql ||
  ' NVL(SUM(PA_FP_ADJUSTMENT_UTILS.revenue(bl.budget_version_id, :1, :2, ' ||
  ' BL.PROJECT_REVENUE)),0) PC_REVENUE, ' ||
  ' NVL(SUM(PA_FP_ADJUSTMENT_UTILS.revenue(bl.budget_version_id, :3, :4, ' ||
  ' BL.REVENUE)),0) PFC_REVENUE, ' ;

  l_sql := l_sql ||
  ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(bl.budget_version_id, :5, null, :6, :7, ' ||
  ' ra.resource_class_code, bl.quantity, ra.rate_based_flag)),0),2) TOTAL_LABOR_HOURS, ' ||
  ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(bl.budget_version_id, :8, null, :9,  :10, ' ||
  ' ra.resource_class_code, bl.quantity, ra.rate_based_flag)),0),2)  TOTAL_EQUIP_HOURS, ' ||
  ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(bl.budget_version_id, null, :11, :12, :13, ' ||
  ' ra.resource_class_code, bl.quantity, ra.rate_based_flag)),0),2) TOTAL_REV_LABOR_HOURS, ' ||
  ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(bl.budget_version_id, null, :14, :15,  :16, ' ||
  ' ra.resource_class_code, bl.quantity, ra.rate_based_flag)),0),2)  TOTAL_REV_EQUIP_HOURS ' ;

  l_sql := l_sql || ' FROM PA_BUDGET_LINES BL, PA_RESOURCE_ASSIGNMENTS RA ' ||
  ' where bl.resource_assignment_id = ra.resource_assignment_id ' ||
  ' and bl.resource_assignment_id in ( ' || l_predicate1 || ' ) ' ||
  ' and bl.txn_currency_code in ( ' || l_curr_code_predicate || ' ) ' ||
  ' group by BL.RESOURCE_ASSIGNMENT_ID, BL.TXN_CURRENCY_CODE ';

  OPEN l_cur FOR l_sql using p_cost_budget_version_id, p_rev_budget_version_id,
              p_cost_budget_version_id, p_rev_budget_version_id,
              p_cost_budget_version_id, l_report_using, l_labor_res_class,
              p_cost_budget_version_id, l_report_using, l_equip_res_class,
              p_rev_budget_version_id, l_report_using, l_labor_res_class,
              p_rev_budget_version_id, l_report_using, l_equip_res_class;
  LOOP

    FETCH l_cur INTO l_resource_assignment_id, l_currency_code,
                     l_pfc_raw_cost, l_pfc_burdened_cost, l_pc_raw_cost,
                     l_pc_burdened_cost, l_pc_revenue, l_pfc_revenue,
                     l_labor_hours, l_equip_hours,
                     l_rev_labor_hours, l_rev_equip_hours;

	EXIT WHEN l_cur%NOTFOUND;

	FOR j in 1..p_resource_assignment_id_tbl.COUNT LOOP
      IF l_resource_assignment_id = p_resource_assignment_id_tbl(j) AND
	     l_currency_code = p_txn_currency_code_tbl(j) THEN
		   l_pfc_raw_cost_total      := l_pfc_raw_cost_total      + l_pfc_raw_cost;
           l_pfc_burdened_cost_total := l_pfc_burdened_cost_total + l_pfc_burdened_cost;
		   l_pc_raw_cost_total       := l_pc_raw_cost_total       + l_pc_raw_cost;
		   l_pc_burdened_cost_total  := l_pc_burdened_cost_total  + l_pc_burdened_cost;
		   l_pc_revenue_total        := l_pc_revenue_total        + l_pc_revenue;
		   l_pfc_revenue_total       := l_pfc_revenue_total       + l_pfc_revenue;
		   l_labor_hours_total       := l_labor_hours_total       + l_labor_hours;
		   l_equip_hours_total       := l_equip_hours_total       + l_equip_hours;
		   l_rev_labor_hours_total   := l_rev_labor_hours_total   + l_rev_labor_hours;
		   l_rev_equip_hours_total   := l_rev_equip_hours_total   + l_rev_equip_hours;

		   EXIT;
	  END IF;
	END LOOP;
  END LOOP;

  x_pfc_raw_cost          := l_pfc_raw_cost_total;
  x_pfc_burdened_cost     := l_pfc_burdened_cost_total;
  x_pc_raw_cost           := l_pc_raw_cost_total;
  x_pc_burdened_cost      := l_pc_burdened_cost_total;
  x_pc_revenue            := l_pc_revenue_total;
  x_pfc_revenue           := l_pfc_revenue_total;
  x_total_labor_hours     := l_labor_hours_total;
  x_total_equip_hours     := l_equip_hours_total;
  x_rev_total_labor_hours := l_rev_labor_hours_total;
  x_rev_total_equip_hours := l_rev_equip_hours_total;

  CLOSE l_cur;
ELSIF l_predicate1 is not null and p_txn_currency_code_tbl.COUNT = 0 THEN

    l_sql :=
    ' SELECT NVL(SUM(TOTAL_PLAN_RAW_COST),0) PFC_RAW_COST,' ||
    ' NVL(SUM(TOTAL_PLAN_BURDENED_COST),0) PFC_BURDENED_COST,' ||
    ' NVL(SUM(TOTAL_PROJECT_RAW_COST),0) PC_RAW_COST, ' ||
    ' NVL(SUM(TOTAL_PROJECT_BURDENED_COST),0) PC_BURDENED_COST, ' ;

    l_sql := l_sql ||
    ' NVL(SUM(PA_FP_ADJUSTMENT_UTILS.revenue(budget_version_id, :1, :2, ' ||
    ' TOTAL_PROJECT_REVENUE)),0) PC_REVENUE, ' ||
    ' NVL(SUM(PA_FP_ADJUSTMENT_UTILS.revenue(budget_version_id, :3, :4, ' ||
    ' TOTAL_PLAN_REVENUE)),0) PFC_REVENUE, ' ;

    l_sql := l_sql ||
    ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(budget_version_id, :5, null, :6, :7, ' ||
    ' resource_class_code, total_plan_quantity, rate_based_flag)),0),2) TOTAL_LABOR_HOURS, ' ||
    ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(budget_version_id, :8, null, :9,  :10, ' ||
    ' resource_class_code, total_plan_quantity, rate_based_flag)),0),2)  TOTAL_EQUIP_HOURS, ' ||
    ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(budget_version_id, null, :11, :12, :13, ' ||
    ' resource_class_code, total_plan_quantity, rate_based_flag)),0),2) TOTAL_REV_LABOR_HOURS, ' ||
    ' ROUND(NVL(SUM(PA_FP_ADJUSTMENT_UTILS.class_hours(budget_version_id, null, :14, :15,  :16, ' ||
    ' resource_class_code, total_plan_quantity, rate_based_flag)),0),2)  TOTAL_REV_EQUIP_HOURS ' ;

    l_sql := l_sql || ' FROM PA_RESOURCE_ASSIGNMENTS ' ||
    ' where resource_assignment_id in ( ';

    l_sql := l_sql ||  l_predicate1  || ' )';

    OPEN l_cur FOR l_sql using p_cost_budget_version_id, p_rev_budget_version_id,
              p_cost_budget_version_id, p_rev_budget_version_id,
              p_cost_budget_version_id, l_report_using, l_labor_res_class,
              p_cost_budget_version_id, l_report_using, l_equip_res_class,
              p_rev_budget_version_id, l_report_using, l_labor_res_class,
              p_rev_budget_version_id, l_report_using, l_equip_res_class;

    FETCH l_cur INTO x_pfc_raw_cost, x_pfc_burdened_cost, x_pc_raw_cost,
                     x_pc_burdened_cost, x_pc_revenue, x_pfc_revenue,
                     x_total_labor_hours, x_total_equip_hours,
                     x_rev_total_labor_hours, x_rev_total_equip_hours;
    CLOSE l_cur;
ELSIF  p_wbs_element_id is not null AND p_rbs_element_id IS NULL THEN

    l_sql := 'SELECT ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, raw_cost, 0)),0) pfc_raw_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, brdn_cost, 0)),0) pfc_burdened_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, raw_cost, 0)),0) pc_raw_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, brdn_cost, 0)),0) pc_burdened_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, revenue, 0)),0) pc_revenue, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, revenue, 0)),0) pfc_revenue, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :1, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, labor_hrs, 0), 0)),2),0) total_labor_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :2, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, equipment_hours, 0), 0)),2),0) total_equip_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :3, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, labor_hrs, 0), 0)),2),0) total_rev_labor_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :4, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, equipment_hours, 0), 0)),2),0) total_rev_equip_hours ' ||
    ' FROM ' ||
    ' ( SELECT raw_cost, brdn_cost, revenue, labor_hrs, equipment_hours, ' ||
	' curr_record_type_id, plan_version_id ' ||
    ' FROM pji_fp_xbs_accum_f ' ||
    ' WHERE bitand(curr_record_type_id, 12) > 0 ' ||
    ' AND calendar_type = ''A'' ' ||
    ' AND prg_rollup_flag = ''N'' ' ||
	' AND project_id = :5 ' ||
    ' AND plan_version_id IN (:6, :7) ';

	l_sql := l_sql || ' AND project_element_id = :8 ' ||
                      ' AND rbs_element_id = -1 AND rbs_version_id = -1 ';

    IF p_WBS_Rollup_Flag = 'Y' THEN
      l_sql := l_sql || ' AND wbs_rollup_flag IN (''Y'',''N'') ';
	ELSE
	  l_sql := l_sql || ' AND wbs_rollup_flag = ''N'' ';
    END IF;

    l_sql := l_sql || ' )';

    OPEN l_cur FOR l_sql using p_cost_budget_version_id, p_cost_budget_version_id,
                               p_rev_budget_version_id, p_rev_budget_version_id,
                               p_project_id, p_cost_budget_version_id, p_rev_budget_version_id,
                               p_wbs_element_id;

	FETCH l_cur INTO x_pfc_raw_cost, x_pfc_burdened_cost, x_pc_raw_cost,
                     x_pc_burdened_cost, x_pc_revenue, x_pfc_revenue,
                     x_total_labor_hours, x_total_equip_hours,
                     x_rev_total_labor_hours, x_rev_total_equip_hours;
    CLOSE l_cur;
ELSIF  p_wbs_element_id is null AND p_rbs_element_id IS NOT NULL THEN

    l_sql := 'SELECT ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, raw_cost, 0)),0) pfc_raw_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, brdn_cost, 0),0)) pfc_burdened_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, raw_cost, 0)),0) pc_raw_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, brdn_cost, 0)),0) pc_burdened_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, revenue, 0)),0) pc_revenue, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, revenue, 0)),0) pfc_revenue, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :1, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, labor_hrs, 0), 0)),2),0) total_labor_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :2, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, equipment_hours, 0), 0)),2),0) total_equip_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :3, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, labor_hrs, 0), 0)),2),0) total_rev_labor_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :4, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, equipment_hours, 0), 0)),2),0) total_rev_equip_hours ' ||
    ' FROM ' ||
    ' ( SELECT raw_cost, brdn_cost, revenue, labor_hrs, equipment_hours, ' ||
	' curr_record_type_id, plan_version_id ' ||
    ' FROM pji_fp_xbs_accum_f ' ||
    ' WHERE bitand(curr_record_type_id, 12) > 0 ' ||
    ' AND calendar_type = ''A'' ' ||
    ' AND prg_rollup_flag = ''N'' ' ||
	' AND project_id = :5 ' ||
    ' AND plan_version_id IN (:6, :7) ';

	l_sql := l_sql ||
	' AND rbs_element_id = :8 ' ||
    ' AND rbs_version_id = :9 ' ||
	' AND wbs_element_id = -1 ';

    IF p_RBS_Rollup_Flag = 'Y' THEN
      l_sql := l_sql || ' AND rbs_aggr_level IN (''R'',''L'') ';
	ELSE
	  l_sql := l_sql || ' AND rbs_aggr_level = ''L'' ';
    END IF;

    l_sql := l_sql || ' )';

    OPEN l_cur FOR l_sql using p_cost_budget_version_id, p_cost_budget_version_id,
                               p_rev_budget_version_id, p_rev_budget_version_id,
                               p_project_id, p_cost_budget_version_id, p_rev_budget_version_id,
	                           p_rbs_element_id, p_rbs_version_id;

    FETCH l_cur INTO x_pfc_raw_cost, x_pfc_burdened_cost, x_pc_raw_cost,
                     x_pc_burdened_cost, x_pc_revenue, x_pfc_revenue,
                     x_total_labor_hours, x_total_equip_hours,
                     x_rev_total_labor_hours, x_rev_total_equip_hours;
    CLOSE l_cur;
ELSIF  p_wbs_element_id is not null AND p_rbs_element_id IS NOT NULL THEN

    l_sql := 'SELECT ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, raw_cost, 0)),0) pfc_raw_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, brdn_cost, 0)),0) pfc_burdened_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, raw_cost, 0)),0) pc_raw_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, brdn_cost, 0)),0) pc_burdened_cost, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 8)), 1, revenue, 0)),0) pc_revenue, ' ||
    ' NVL(SUM(DECODE(SIGN(bitand(curr_record_type_id, 4)), 1, revenue, 0)),0) pfc_revenue, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :1, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, labor_hrs, 0), 0)),2),0) total_labor_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :2, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, equipment_hours, 0), 0)),2),0) total_equip_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :3, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, labor_hrs, 0), 0)),2),0) total_rev_labor_hours, ' ||
    ' NVL(ROUND(SUM(DECODE(plan_version_id, -1, 0, :4, DECODE(SIGN(bitand(curr_record_type_id,4)), 1, equipment_hours, 0), 0)),2),0) total_rev_equip_hours ' ||
    ' FROM ' ||
    ' ( SELECT raw_cost, brdn_cost, revenue, labor_hrs, equipment_hours, ' ||
	' curr_record_type_id, plan_version_id ' ||
    ' FROM pji_fp_xbs_accum_f ' ||
    ' WHERE bitand(curr_record_type_id, 12) > 0 ' ||
    ' AND calendar_type = ''A'' ' ||
    ' AND prg_rollup_flag = ''N'' ' ||
	' AND project_id = :5 ' ||
    ' AND plan_version_id IN (:6, :7) ';

	l_sql := l_sql ||
	' AND rbs_element_id = :8 ' ||
    ' AND rbs_version_id = :9 ' ||
	' AND project_element_id = :10 ';

	IF p_WBS_Rollup_Flag = 'Y' THEN
      l_sql := l_sql || ' AND wbs_rollup_flag IN (''Y'',''N'') ';
	ELSE
	  l_sql := l_sql || ' AND wbs_rollup_flag = ''N'' ';
    END IF;

    IF p_RBS_Rollup_Flag = 'Y' THEN
      l_sql := l_sql || ' AND rbs_aggr_level IN (''R'',''L'') ';
	ELSE
	  l_sql := l_sql || ' AND rbs_aggr_level = ''L'' ';
    END IF;

    l_sql := l_sql || ' )';

    OPEN l_cur FOR l_sql using p_cost_budget_version_id, p_cost_budget_version_id,
                               p_rev_budget_version_id, p_rev_budget_version_id,
                               p_project_id, p_cost_budget_version_id, p_rev_budget_version_id,
	                           p_rbs_element_id, p_rbs_version_id, p_wbs_element_id;

    FETCH l_cur INTO x_pfc_raw_cost, x_pfc_burdened_cost, x_pc_raw_cost,
                     x_pc_burdened_cost, x_pc_revenue, x_pfc_revenue,
                     x_total_labor_hours, x_total_equip_hours,
                     x_rev_total_labor_hours, x_rev_total_equip_hours;
    CLOSE l_cur;
END IF;

PA_DEBUG.write(x_module    => L_Module,
               x_msg       => 'Fetched Data',
               x_log_level => 3);

--Margin Calculation can be calculated using either Raw Cost or Burdened Cost.
--The selection will be based on the setup value of  'Report Cost Using':

--'B' - Burdened Cost,'R' - Raw Cost
--When Raw Cost is used in the calculation: Margin=(Revenue-Raw Cost)
--When Burdened Cost is used in the calculation: Margin=(Revenue-Burdened Cost)


IF l_margin_code = 'R' THEN
  x_pc_margin     := NVL(x_pc_revenue  - x_pc_raw_cost,0);
  x_pfc_margin    := NVL(x_pfc_revenue - x_pfc_raw_cost,0);
ELSIF l_margin_code = 'B' THEN
  x_pc_margin     := NVL(x_pc_revenue  - x_pc_burdened_cost,0);
  x_pfc_margin    := NVL(x_pfc_revenue - x_pfc_burdened_cost,0);
END IF;

IF x_pc_revenue <> 0 THEN
  x_margin_percent := NVL((x_pc_margin/x_pc_revenue)*100,0);
END IF;

pa_debug.g_err_stage:='End of ' || L_FuncProc;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);

EXCEPTION
    WHEN OTHERS THEN
	    --dbms_output.put_line('Others Exception in ' || L_FuncProc);
	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
          PA_DEBUG.write_log (x_module => L_Module
                          ,x_msg         => 'Unexp. Error:' || L_FuncProc || SQLERRM
                          ,x_log_level   => 6);
        END IF;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                               p_procedure_name => L_FuncProc);
    RAISE;
END GET_SUMMARY_INFO;


-- Purpose: Private Specific to compute relevant planning transaction id's affected in
--          computing summary amounts/adjusting plan via Adjust/Mass Adjust.
-- Called by Get_Summary_Info and AMG Adjust Interface API.

PROCEDURE COMPUTE_HIERARCHY(
     p_cost_budget_version_id   IN NUMBER
    ,p_rev_budget_version_id    IN NUMBER
    ,p_WBS_Element_Id	        IN NUMBER DEFAULT NULL
    ,p_RBS_Element_Id	        IN NUMBER DEFAULT NULL
    ,p_WBS_Structure_Version_Id IN NUMBER DEFAULT NULL
    ,p_RBS_Version_Id           IN NUMBER DEFAULT NULL
    ,p_WBS_Rollup_Flag          IN VARCHAR2
    ,p_RBS_Rollup_Flag          IN VARCHAR2
    ,X_res_assignment_id_tbl     OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,X_txn_currency_code_tbl     OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type --File.Sql.39 bug 4440895
    ,X_rev_res_assignment_id_tbl OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,X_rev_txn_currency_code_tbl OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type --File.Sql.39 bug 4440895
    ,X_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )   IS
-- WBS only - Rollup
CURSOR C_WBS_RES_ID_ROLL(p_budget_version_id IN NUMBER, p_wbs_element_id IN NUMBER,
                         p_wbs_structure_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_xbs_denorm xbs, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and xbs.sub_emt_id = ra.task_id
and ra.budget_version_id = p_budget_version_id
and xbs.sup_emt_id = p_wbs_element_id
and xbs.struct_version_id = p_wbs_structure_version_id
and xbs.struct_type in ('WBS','XBS');

-- WBS only - Self-node
CURSOR C_WBS_RES_ID_SELF(p_budget_version_id IN NUMBER, p_wbs_element_id IN NUMBER,
                         p_wbs_structure_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_xbs_denorm xbs, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and xbs.sub_emt_id = ra.task_id
and ra.budget_version_id = p_budget_version_id
and xbs.sup_emt_id = p_wbs_element_id
and xbs.struct_version_id = p_wbs_structure_version_id
and xbs.struct_type in ('WBS','XBS')
and xbs.sub_level = xbs.sup_level;

-- WBS Only - Project Level Rollup
CURSOR C_WBS_RES_ID_PROJ_ROLL (p_budget_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and ra.budget_version_id = p_budget_version_id;

-- WBS Only - Project Level Self-node
CURSOR C_WBS_RES_ID_PROJ_SELF (p_budget_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and ra.budget_version_id = p_budget_version_id
and ra.task_id = 0;

-- RBS only - Rollup
CURSOR C_RBS_RES_ID_ROLL(p_budget_version_id IN NUMBER, p_rbs_element_id IN NUMBER,
                    p_rbs_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and fp.fin_plan_version_id = ra.budget_version_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and ra.budget_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id;

-- RBS only - Self-node
CURSOR C_RBS_RES_ID_SELF(p_budget_version_id IN NUMBER, p_rbs_element_id IN NUMBER,
                    p_rbs_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and fp.fin_plan_version_id = ra.budget_version_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and ra.budget_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id
and rbs.sub_level = rbs.sup_level;

-- Both - WBS Rollup RBS Rollup
CURSOR C_BOTH_RES_ID_ROLL_ROLL(p_budget_version_id IN NUMBER, p_wbs_element_id IN NUMBER,
                               p_rbs_element_id IN NUMBER, p_rbs_version_id IN NUMBER,
                               p_wbs_structure_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pji_xbs_denorm xbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and xbs.sub_emt_id = ra.task_id
and xbs.sup_project_id = fp.project_id
and fp.fin_plan_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id
and xbs.sup_emt_id = p_wbs_element_id
and xbs.struct_version_id = p_wbs_structure_version_id
and xbs.struct_type in ('WBS','XBS');

-- Both - WBS Rollup RBS Self-node
CURSOR C_BOTH_RES_ID_ROLL_SELF(p_budget_version_id IN NUMBER, p_wbs_element_id IN NUMBER,
                     p_rbs_element_id IN NUMBER, p_rbs_version_id IN NUMBER,
                     p_wbs_structure_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pji_xbs_denorm xbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and xbs.sub_emt_id = ra.task_id
and xbs.sup_project_id = fp.project_id
and fp.fin_plan_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id
and xbs.sup_emt_id = p_wbs_element_id
and xbs.struct_version_id = p_wbs_structure_version_id
and xbs.struct_type in ('WBS','XBS')
and rbs.sub_level = rbs.sup_level;

-- Both - WBS Self-node RBS Rollup
CURSOR C_BOTH_RES_ID_SELF_ROLL(p_budget_version_id IN NUMBER, p_wbs_element_id IN NUMBER,
                     p_rbs_element_id IN NUMBER, p_rbs_version_id IN NUMBER,
                     p_wbs_structure_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pji_xbs_denorm xbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and xbs.sub_emt_id = ra.task_id
and xbs.sup_project_id = fp.project_id
and fp.fin_plan_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id
and xbs.sup_emt_id = p_wbs_element_id
and xbs.struct_version_id = p_wbs_structure_version_id
and xbs.struct_type in ('WBS','XBS')
and xbs.sub_level = xbs.sup_level;

-- Both - WBS Self-node RBS Self-node
CURSOR C_BOTH_RES_ID_SELF_SELF(p_budget_version_id IN NUMBER, p_wbs_element_id IN NUMBER,
                     p_rbs_element_id IN NUMBER, p_rbs_version_id IN NUMBER,
                     p_wbs_structure_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pji_xbs_denorm xbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and xbs.sub_emt_id = ra.task_id
and xbs.sup_project_id = fp.project_id
and fp.fin_plan_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id
and xbs.sup_emt_id = p_wbs_element_id
and xbs.struct_version_id = p_wbs_structure_version_id
and xbs.struct_type in ('WBS','XBS')
and xbs.sub_level = xbs.sup_level
and rbs.sub_level = rbs.sup_level;

-- Both - WBS Project Level Self-node RBS Rollup
CURSOR C_BOTH_RES_ID_PROJ_ROLL(p_budget_version_id IN NUMBER, p_rbs_element_id IN NUMBER,
                    p_rbs_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and fp.fin_plan_version_id = ra.budget_version_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and ra.budget_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id
and ra.task_id = 0;

-- Both - WBS Project Level Self-node RBS Self-node
CURSOR C_BOTH_RES_ID_PROJ_SELF(p_budget_version_id IN NUMBER, p_rbs_element_id IN NUMBER,
                    p_rbs_version_id IN NUMBER) IS
Select distinct ra.resource_assignment_id, bl.TXN_CURRENCY_CODE
from pji_rbs_denorm rbs, pa_proj_fp_options fp, pa_resource_assignments ra, pa_budget_lines bl
where ra.resource_assignment_id = bl.resource_assignment_id
and fp.fin_plan_version_id = ra.budget_version_id
and rbs.struct_version_id = fp.rbs_version_id
and rbs.sub_id = ra.rbs_element_id
and ra.budget_version_id = p_budget_version_id
and rbs.sup_id = p_rbs_element_id
and rbs.struct_version_id = p_rbs_version_id
and rbs.sub_level = rbs.sup_level
and ra.task_id = 0;

CURSOR C_Get_Object_Type (p_wbs_element_id IN NUMBER, p_wbs_structure_version_id IN NUMBER) IS
SELECT object_type
FROM pa_proj_element_versions
WHERE proj_element_id = p_wbs_element_id
AND element_version_id = p_wbs_structure_version_id;

l_object_type pa_proj_element_versions.object_type%TYPE;
l_project_level_node_flag varchar2(1) := 'N';

l_t_id NUMBER;
l_t_code VARCHAR2(15);
l_cnt NUMBER;

BEGIN

L_FuncProc := 'Compute_Hierarchy';
x_return_status := FND_API.G_RET_STS_SUCCESS;

pa_debug.g_err_stage:='Beginning of ' || L_FuncProc;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);

x_res_assignment_id_tbl := SYSTEM.PA_NUM_TBL_TYPE();
x_txn_currency_code_tbl := SYSTEM.pa_varchar2_15_tbl_type();
x_rev_res_assignment_id_tbl := SYSTEM.PA_NUM_TBL_TYPE();
x_rev_txn_currency_code_tbl := SYSTEM.pa_varchar2_15_tbl_type();

-- Check if Project Level WBS Node
IF (p_wbs_element_id IS NOT NULL) AND (p_wbs_structure_version_id IS NOT NULL) THEN
  OPEN C_Get_Object_Type(p_wbs_element_id, p_wbs_structure_version_id);
  FETCH C_Get_Object_Type into l_object_type;
  CLOSE C_Get_Object_Type;

  IF l_object_type = 'PA_STRUCTURES' THEN
    l_project_level_node_flag := 'Y';
  END IF;
END IF;

IF P_Wbs_Element_Id is not null AND P_RBS_Element_Id is NULL THEN

  IF nvl(p_cost_budget_version_id,-1) <> -1 THEN
    IF l_project_level_node_flag = 'Y' THEN
      IF p_WBS_Rollup_Flag = 'N' THEN
        OPEN C_WBS_RES_ID_PROJ_SELF(p_cost_budget_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_PROJ_SELF INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_PROJ_SELF%NOTFOUND;
          x_res_assignment_id_tbl.extend(1);
          x_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_PROJ_SELF;
      ELSE
        OPEN C_WBS_RES_ID_PROJ_ROLL(p_cost_budget_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_PROJ_ROLL INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_PROJ_ROLL%NOTFOUND;
          x_res_assignment_id_tbl.extend(1);
          x_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_PROJ_ROLL;
      END IF;
    ELSE
      IF p_WBS_Rollup_Flag = 'N' THEN
        OPEN C_WBS_RES_ID_SELF(p_cost_budget_version_id, p_wbs_element_id, p_wbs_structure_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_SELF INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_SELF%NOTFOUND;
          x_res_assignment_id_tbl.extend(1);
          x_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_SELF;
      ELSE
        OPEN C_WBS_RES_ID_ROLL(p_cost_budget_version_id, p_wbs_element_id, p_wbs_structure_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_ROLL INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_ROLL%NOTFOUND;
          x_res_assignment_id_tbl.extend(1);
          x_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_ROLL;
      END IF;
    END IF;
  END IF;

  IF nvl(p_rev_budget_version_id,-1) <> -1 THEN
    IF l_project_level_node_flag = 'Y' THEN
      IF p_WBS_Rollup_Flag = 'N' THEN
        OPEN C_WBS_RES_ID_PROJ_SELF(p_rev_budget_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_PROJ_SELF INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_PROJ_SELF%NOTFOUND;
          x_rev_res_assignment_id_tbl.extend(1);
          x_rev_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_PROJ_SELF;
      ELSE
        OPEN C_WBS_RES_ID_PROJ_ROLL(p_rev_budget_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_PROJ_ROLL INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_PROJ_ROLL%NOTFOUND;
          x_rev_res_assignment_id_tbl.extend(1);
          x_rev_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_PROJ_ROLL;
      END IF;
    ELSE
      IF p_WBS_Rollup_Flag = 'N' THEN
        OPEN C_WBS_RES_ID_SELF(p_rev_budget_version_id, p_wbs_element_id, p_wbs_structure_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_SELF INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_SELF%NOTFOUND;
          x_rev_res_assignment_id_tbl.extend(1);
          x_rev_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_SELF;
      ELSE
        OPEN C_WBS_RES_ID_ROLL(p_rev_budget_version_id, p_wbs_element_id, p_wbs_structure_version_id);
        l_cnt := 0;
        LOOP
          FETCH C_WBS_RES_ID_ROLL INTO l_t_id, l_t_code;
          EXIT WHEN C_WBS_RES_ID_ROLL%NOTFOUND;
          x_rev_res_assignment_id_tbl.extend(1);
          x_rev_txn_currency_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
          x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE C_WBS_RES_ID_ROLL;
      END IF;
    END IF;
  END IF;

ELSIF P_Rbs_Element_Id is not null AND P_WBS_Element_Id is NULL THEN

  IF nvl(p_cost_budget_version_id,-1) <> -1 THEN
    IF p_RBS_Rollup_Flag = 'N' THEN
      OPEN C_RBS_RES_ID_SELF(p_cost_budget_version_id, p_rbs_element_id, p_rbs_version_id);
      l_cnt := 0;
      LOOP
        FETCH C_RBS_RES_ID_SELF INTO l_t_id, l_t_code;
        EXIT WHEN C_RBS_RES_ID_SELF%NOTFOUND;
        x_res_assignment_id_tbl.extend(1);
        x_txn_currency_code_tbl.extend(1);
        l_cnt := l_cnt + 1;
        x_res_assignment_id_tbl(l_cnt) := l_t_id;
        x_txn_currency_code_tbl(l_cnt) := l_t_code;
      END LOOP;
      CLOSE C_RBS_RES_ID_SELF;
    ELSE
      OPEN C_RBS_RES_ID_ROLL(p_cost_budget_version_id, p_rbs_element_id, p_rbs_version_id);
      l_cnt := 0;
      LOOP
        FETCH C_RBS_RES_ID_ROLL INTO l_t_id, l_t_code;
        EXIT WHEN C_RBS_RES_ID_ROLL%NOTFOUND;
        x_res_assignment_id_tbl.extend(1);
        x_txn_currency_code_tbl.extend(1);
        l_cnt := l_cnt + 1;
        x_res_assignment_id_tbl(l_cnt) := l_t_id;
        x_txn_currency_code_tbl(l_cnt) := l_t_code;
      END LOOP;
      CLOSE C_RBS_RES_ID_ROLL;
    END IF;
  END IF;

  IF nvl(p_rev_budget_version_id,-1) <> -1 THEN
    IF p_RBS_Rollup_Flag = 'N' THEN
      OPEN C_RBS_RES_ID_SELF(p_rev_budget_version_id, p_rbs_element_id, p_rbs_version_id);
      l_cnt := 0;
      LOOP
        FETCH C_RBS_RES_ID_SELF INTO l_t_id, l_t_code;
        EXIT WHEN C_RBS_RES_ID_SELF%NOTFOUND;
        x_rev_res_assignment_id_tbl.extend(1);
        x_rev_txn_currency_code_tbl.extend(1);
        l_cnt := l_cnt + 1;
        x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
        x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
      END LOOP;
      CLOSE C_RBS_RES_ID_SELF;
    ELSE
      OPEN C_RBS_RES_ID_ROLL(p_rev_budget_version_id, p_rbs_element_id, p_rbs_version_id);
      l_cnt := 0;
      LOOP
        FETCH C_RBS_RES_ID_ROLL INTO l_t_id, l_t_code;
        EXIT WHEN C_RBS_RES_ID_ROLL%NOTFOUND;
        x_rev_res_assignment_id_tbl.extend(1);
        x_rev_txn_currency_code_tbl.extend(1);
        l_cnt := l_cnt + 1;
        x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
        x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
      END LOOP;
      CLOSE C_RBS_RES_ID_ROLL;
    END IF;
  END IF;

ELSIF P_Wbs_Element_Id is not null AND P_RBS_Element_Id is NOT NULL THEN

  IF nvl(p_cost_budget_version_id,-1) <> -1 THEN
    IF l_project_level_node_flag = 'Y' THEN
      IF p_WBS_Rollup_Flag = 'N' THEN
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_BOTH_RES_ID_PROJ_SELF(p_cost_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_PROJ_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_PROJ_SELF%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_PROJ_SELF;
        ELSE
          OPEN C_BOTH_RES_ID_PROJ_ROLL(p_cost_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_PROJ_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_PROJ_ROLL%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_PROJ_ROLL;
        END IF;
      ELSE
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_RBS_RES_ID_SELF(p_cost_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_RBS_RES_ID_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_RBS_RES_ID_SELF%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_RBS_RES_ID_SELF;
        ELSE
          OPEN C_RBS_RES_ID_ROLL(p_cost_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_RBS_RES_ID_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_RBS_RES_ID_ROLL%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_RBS_RES_ID_ROLL;
        END IF;
      END IF;
    ELSE
      IF p_WBS_Rollup_Flag = 'N' THEN
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_BOTH_RES_ID_SELF_SELF(p_cost_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_SELF_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_SELF_SELF%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_SELF_SELF;
        ELSE
          OPEN C_BOTH_RES_ID_SELF_ROLL(p_cost_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_SELF_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_SELF_ROLL%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_SELF_ROLL;
        END IF;
      ELSE
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_BOTH_RES_ID_ROLL_SELF(p_cost_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_ROLL_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_ROLL_SELF%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_ROLL_SELF;
        ELSE
          OPEN C_BOTH_RES_ID_ROLL_ROLL(p_cost_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_ROLL_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_ROLL_ROLL%NOTFOUND;
            x_res_assignment_id_tbl.extend(1);
            x_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_ROLL_ROLL;
        END IF;
      END IF;
    END IF;
  END IF;

  IF nvl(p_rev_budget_version_id,-1) <> -1 THEN
    IF l_project_level_node_flag = 'Y' THEN
      IF p_WBS_Rollup_Flag = 'N' THEN
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_BOTH_RES_ID_PROJ_SELF(p_rev_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_PROJ_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_PROJ_SELF%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_PROJ_SELF;
        ELSE
          OPEN C_BOTH_RES_ID_PROJ_ROLL(p_rev_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_PROJ_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_PROJ_ROLL%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_PROJ_ROLL;
        END IF;
      ELSE
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_RBS_RES_ID_SELF(p_rev_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_RBS_RES_ID_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_RBS_RES_ID_SELF%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_RBS_RES_ID_SELF;
        ELSE
          OPEN C_RBS_RES_ID_ROLL(p_rev_budget_version_id, p_rbs_element_id, p_rbs_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_RBS_RES_ID_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_RBS_RES_ID_ROLL%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_RBS_RES_ID_ROLL;
        END IF;
      END IF;
    ELSE
      IF p_WBS_Rollup_Flag = 'N' THEN
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_BOTH_RES_ID_SELF_SELF(p_rev_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_SELF_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_SELF_SELF%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_SELF_SELF;
        ELSE
          OPEN C_BOTH_RES_ID_SELF_ROLL(p_rev_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_SELF_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_SELF_ROLL%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_SELF_ROLL;
        END IF;
      ELSE
        IF p_RBS_Rollup_Flag = 'N' THEN
          OPEN C_BOTH_RES_ID_ROLL_SELF(p_rev_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_ROLL_SELF INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_ROLL_SELF%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_ROLL_SELF;
        ELSE
          OPEN C_BOTH_RES_ID_ROLL_ROLL(p_rev_budget_version_id, p_wbs_element_id,
                                       p_rbs_element_id, p_rbs_version_id,
									   p_wbs_structure_version_id);
          l_cnt := 0;
          LOOP
            FETCH C_BOTH_RES_ID_ROLL_ROLL INTO l_t_id, l_t_code;
            EXIT WHEN C_BOTH_RES_ID_ROLL_ROLL%NOTFOUND;
            x_rev_res_assignment_id_tbl.extend(1);
            x_rev_txn_currency_code_tbl.extend(1);
            l_cnt := l_cnt + 1;
            x_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
            x_rev_txn_currency_code_tbl(l_cnt) := l_t_code;
          END LOOP;
          CLOSE C_BOTH_RES_ID_ROLL_ROLL;
        END IF;
      END IF;
    END IF;
  END IF;

END IF;

  pa_debug.g_err_stage:='End of ' || L_FuncProc;
  pa_debug.write(L_Module,pa_debug.g_err_stage,3);

EXCEPTION
    WHEN OTHERS THEN
	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
          PA_DEBUG.write_log (x_module => L_Module
                          ,x_msg         => 'Unexp. Error:' || L_FuncProc || SQLERRM
                          ,x_log_level   => 6);
        END IF;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                               p_procedure_name => L_FuncProc);
    RAISE;
END COMPUTE_HIERARCHY;


-- This procedure will Adjust the relevant Planning transactions based on a percentage
-- for the relevant parameters
--
PROCEDURE Adjust_Planning_Transactions
(
     p_Project_Id                   IN  NUMBER
    ,p_Context                      IN  VARCHAR2
    ,p_user_id                      IN  NUMBER DEFAULT FND_GLOBAL.USER_ID
    ,p_cost_budget_version_id	    IN  NUMBER
    ,p_rev_budget_version_id        IN  NUMBER   DEFAULT NULL
    ,p_cost_fin_plan_type_id        IN  NUMBER
    ,p_cost_version_type            IN  VARCHAR2
    ,p_cost_plan_setup              IN  VARCHAR2
    ,p_rev_fin_plan_type_id         IN  NUMBER	 DEFAULT NULL
    ,p_rev_version_type             IN  VARCHAR2 DEFAULT NULL
    ,p_rev_plan_setup               IN  VARCHAR2 DEFAULT NULL
    ,p_new_version_flag	            IN  VARCHAR2 DEFAULT 'N'
    ,p_new_version_name	            IN  VARCHAR2 DEFAULT NULL
    ,p_new_version_desc	            IN  VARCHAR2 DEFAULT NULL
    ,p_adjustment_type	            IN  VARCHAR2 DEFAULT NULL
    ,p_adjustment_percentage	    IN  NUMBER
    ,p_WBS_Element_Id               IN  NUMBER   DEFAULT NULL
    ,p_RBS_Element_Id               IN  NUMBER   DEFAULT NULL
    ,p_WBS_Structure_Version_Id     IN  NUMBER   DEFAULT NULL
    ,p_RBS_Version_Id               IN  NUMBER   DEFAULT NULL
    ,p_WBS_Rollup_Flag              IN  VARCHAR2
    ,p_RBS_Rollup_Flag              IN  VARCHAR2
    ,p_resource_assignment_id_tbl   IN  SYSTEM.PA_NUM_TBL_TYPE
    ,p_txn_currency_code_tbl        IN  SYSTEM.pa_varchar2_15_tbl_type
    ,x_cost_budget_version_id	    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_rev_budget_version_id        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                     OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

    TYPE  DYNAMIC_CUR IS REF CURSOR;
    l_cur DYNAMIC_CUR;
    l_sql VARCHAR2(32767);
    l_predicate1 VARCHAR2(32767);

    l_cur2 DYNAMIC_CUR;
    l_sql2 VARCHAR2(32767);
    l_predicate2 VARCHAR2(32767);

    l_cur3 DYNAMIC_CUR;
    l_sql3 VARCHAR2(32767);
    l_predicate3 VARCHAR2(32767);

    l_quantity_adj_pct              NUMBER;
    l_cost_rate_adj_pct             NUMBER;
    l_burdened_rate_adj_pct         NUMBER;
    l_bill_rate_adj_pct             NUMBER;
    /* IPM changes */
    l_raw_cost_adj_pct                  NUMBER;
    l_burden_cost_adj_pct               NUMBER;
    l_revenue_adj_pct                   NUMBER;

    L_res_assignment_id_tbl      SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
    L_txn_curr_code_tbl          SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();
    L_rev_res_assignment_id_tbl  SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
    L_rev_txn_curr_code_tbl      SYSTEM.pa_varchar2_15_tbl_type:=SYSTEM.pa_varchar2_15_tbl_type();

    l_t_id NUMBER;
    l_t_code VARCHAR2(15);
    l_cnt NUMBER;

    l_cost_budget_version_id     NUMBER;
    l_rev_budget_version_id      NUMBER;
    l_target_budget_version_id   NUMBER;
    l_target_rev_version_id      NUMBER;

	l_target_budget_version_id_tbl		SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();
	l_target_rev_version_id_tbl			SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE();

    api_exception EXCEPTION ;

    l_struct_ver_id              NUMBER;

    l_locked_by_user_flag        VARCHAR2(1);
    l_locked_by_person_id        NUMBER;
    l_editable_flag              VARCHAR2(1);

    r_locked_by_user_flag        VARCHAR2(1);
    r_locked_by_person_id        NUMBER;
    r_editable_flag              VARCHAR2(1);

    l_user_id  NUMBER;
BEGIN

l_user_id := FND_GLOBAL.USER_ID;

L_FuncProc := 'Adjust_Planning_Transactions';
x_return_status := FND_API.G_RET_STS_SUCCESS;

pa_debug.g_err_stage:='Beginning of ' || L_FuncProc;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);

IF p_adjustment_type = 'QUANTITY' THEN
  l_quantity_adj_pct := p_adjustment_percentage;
ELSIF p_adjustment_type = 'COST_QUANTITY' THEN
  l_quantity_adj_pct := p_adjustment_percentage;
ELSIF p_adjustment_type = 'REVENUE_QUANTITY' THEN
  l_quantity_adj_pct := p_adjustment_percentage;
ELSIF p_adjustment_type = 'COST_RATE' THEN
  l_cost_rate_adj_pct := p_adjustment_percentage;
ELSIF p_adjustment_type = 'BILL_RATE' THEN
  l_bill_rate_adj_pct := p_adjustment_percentage;
ELSIF p_adjustment_type = 'BURDENED_RATE' THEN
  l_burdened_rate_adj_pct := p_adjustment_percentage;
/* IPM changes */
ELSIF p_adjustment_type = 'RAW_COST' THEN
        l_raw_cost_adj_pct := p_adjustment_percentage;
ELSIF  p_adjustment_type = 'BURDENED_COST' THEN
        l_burden_cost_adj_pct := p_adjustment_percentage;
ELSIF p_adjustment_type = 'REVENUE' THEN
        l_revenue_adj_pct := p_adjustment_percentage;
ELSE
  RETURN;
END IF;

pa_debug.g_err_stage:='p_project_id ' || p_project_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_context: ' || p_context;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_user_id: ' || p_user_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_cost_budget_version_id: ' || p_cost_budget_version_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_rev_budget_version_id: ' || p_rev_budget_version_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_cost_fin_plan_type_id: ' || p_cost_fin_plan_type_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_cost_version_type: ' || p_cost_version_type;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_rev_fin_plan_type_id: ' || p_rev_fin_plan_type_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_rev_version_type: ' || p_rev_version_type;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_new_version_flag: ' || p_new_version_flag;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_new_version_name: ' || p_new_version_name;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_new_version_desc: ' || p_new_version_desc;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_adjustment_type: ' || p_adjustment_type;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_adjustment_percentage: ' || p_adjustment_percentage;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_WBS_Element_Id: ' || p_WBS_Element_Id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_RBS_Element_Id: ' || p_RBS_Element_Id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_WBS_Structure_Version_Id: ' || p_WBS_Structure_Version_Id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:= L_FuncProc || ' p_RBS_Version_Id: ' || p_RBS_Version_Id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
IF p_resource_assignment_id_tbl.COUNT > 0 THEN
   FOR i IN p_resource_assignment_id_tbl.FIRST .. p_resource_assignment_id_tbl.LAST LOOP
   	   pa_debug.g_err_stage:= L_FuncProc || '  p_resource_assignment_id_tbl(' || i || '): ' || p_resource_assignment_id_tbl(i);
	   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
   END LOOP;
ELSE
   pa_debug.g_err_stage:= L_FuncProc || ' p_resource_assignment_id_tbl is EMPTY';
   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
END IF;
IF p_txn_currency_code_tbl.COUNT > 0 THEN
   FOR i IN p_txn_currency_code_tbl.FIRST .. p_txn_currency_code_tbl.LAST LOOP
   	   pa_debug.g_err_stage:= L_FuncProc || '  p_txn_currency_code_tbl(' || i || '): ' || p_txn_currency_code_tbl(i);
	   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
   END LOOP;
ELSE
   pa_debug.g_err_stage:= L_FuncProc || ' p_txn_currency_code_tbl is EMPTY';
   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
END IF;

IF P_CONTEXT='WORKPLAN' THEN
 IF 'Y' <> pa_task_assignment_utils.check_edit_task_ok(
   P_PROJECT_ID	     => P_project_id,
   P_STRUCTURE_VERSION_ID	=> p_wbs_structure_version_id,
   P_CURR_STRUCT_VERSION_ID	=> p_wbs_structure_version_id
   ) THEN
         -- Bug 4533152
         --PA_UTILS.ADD_MESSAGE
         -- (p_app_short_name => 'PA',
         --  p_msg_name       => 'PA_UPDATE_PUB_VER_ERR'
         --  );
           x_return_status := FND_API.G_RET_STS_ERROR;
   RETURN;
 ELSE
      l_locked_by_user_flag := 'Y';
 END IF;
ELSIF P_CONTEXT IN ('BUDGET', 'FORECAST') THEN
   IF nvl(p_cost_budget_version_id, -1) <> -1 THEN

      pa_debug.g_err_stage:= L_FuncProc || ' l_user_id: ' || l_user_id;
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);

      pa_fin_plan_utils.Check_Locked_By_User
      (p_user_id              => l_user_id,
       p_budget_version_id    => p_cost_budget_version_id,
       x_is_locked_by_userid  => l_locked_by_user_flag,
       x_locked_by_person_id  => l_locked_by_person_id,
       x_return_status        => x_return_status,
       x_msg_count            => x_msg_count,
       x_msg_data             => x_msg_data);

      pa_debug.g_err_stage:= L_FuncProc || ' x_return_status: ' || x_return_status;
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         pa_debug.g_err_stage:='Rasing API_EXCEPTION 1';
         pa_debug.write(L_Module,pa_debug.g_err_stage,3);
         RAISE api_exception;
      END IF;

      pa_fin_plan_utils.CHECK_IF_PLAN_TYPE_EDITABLE
      (p_project_id        => p_project_id,
       p_fin_plan_type_id  => p_cost_fin_plan_type_id,
       p_version_type      => p_cost_version_type,
       x_editable_flag     => l_editable_flag,
       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         pa_debug.g_err_stage:='Rasing API_EXCEPTION 2';
         pa_debug.write(L_Module,pa_debug.g_err_stage,3);
         RAISE api_exception;
      END IF;
   END IF;

   IF l_locked_by_person_id is null then
      l_locked_by_user_flag := 'Y';  -- unlocked is equivalent to locked by user
   END IF;

   IF nvl(P_rev_budget_version_id, -1) = -1 AND
      (l_locked_by_user_flag <> 'Y' OR l_editable_flag <> 'Y') THEN

      PA_UTILS.ADD_MESSAGE
      (p_app_short_name => 'PA',
       p_msg_name       => 'PA_NO_ACCESS_TO_UPDATE');

      pa_debug.reset_err_stack;
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   ELSIF nvl(P_rev_budget_version_id, -1) <> -1  THEN
     -- No access to update for the cost version in terms of
     -- cost rate or burdened rate which applies to cost version only..

       IF p_adjustment_type in ('COST_RATE', 'BURDENED_RATE', 'COST_QUANTITY','RAW_COST','BURDENED_COST') AND
          (l_locked_by_user_flag <> 'Y' OR l_editable_flag <> 'Y') THEN

           PA_UTILS.ADD_MESSAGE
          (p_app_short_name => 'PA',
           p_msg_name       => 'PA_NO_ACCESS_TO_UPDATE');
    	   pa_debug.reset_err_stack;
           x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
       END IF;

       IF p_adjustment_type IN ( 'BILL_RATE', 'QUANTITY', 'REVENUE_QUANTITY','REVENUE') THEN

          pa_fin_plan_utils.Check_Locked_By_User
          (p_user_id              => l_user_id,
           p_budget_version_id    => p_rev_budget_version_id,
           x_is_locked_by_userid  => r_locked_by_user_flag,
           x_locked_by_person_id  => r_locked_by_person_id,
           x_return_status        => x_return_status,
           x_msg_count            => x_msg_count,
           x_msg_data             => x_msg_data);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            pa_debug.g_err_stage:='Rasing API_EXCEPTION 3';
            pa_debug.write(L_Module,pa_debug.g_err_stage,3);
            RAISE api_exception;
         END IF;

	  pa_fin_plan_utils.CHECK_IF_PLAN_TYPE_EDITABLE
	  (p_project_id        => p_project_id,
	   p_fin_plan_type_id  => p_rev_fin_plan_type_id,
           p_version_type      => p_rev_version_type,
           x_editable_flag     => r_editable_flag,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data);

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            pa_debug.g_err_stage:='Rasing API_EXCEPTION 4';
            pa_debug.write(L_Module,pa_debug.g_err_stage,3);
            RAISE api_exception;
         END IF;

         IF r_locked_by_person_id is null then
            r_locked_by_user_flag := 'Y';  -- unlocked is equivalent to locked by user
         END IF;

         IF p_adjustment_type in ('BILL_RATE','REVENUE') AND
            (r_locked_by_user_flag <> 'Y' OR r_editable_flag <> 'Y') THEN

            PA_UTILS.ADD_MESSAGE
            (p_app_short_name => 'PA',
             p_msg_name       => 'PA_UPDATE_PUB_VER_ERR');

    	    pa_debug.reset_err_stack;
            x_return_status := FND_API.G_RET_STS_ERROR;
            RETURN;
         ELSIF p_adjustment_type IN ('QUANTITY', 'REVENUE_QUANTITY') AND
		 	   (r_locked_by_user_flag <> 'Y' OR r_editable_flag <> 'Y' OR
           	    l_locked_by_user_flag <> 'Y' OR l_editable_flag <> 'Y') THEN

           PA_UTILS.ADD_MESSAGE
           (p_app_short_name => 'PA',
            p_msg_name       => 'PA_UPDATE_PUB_VER_ERR');

    	   pa_debug.reset_err_stack;
           x_return_status := FND_API.G_RET_STS_ERROR;
           RETURN;
         END IF;
	  END IF;  -- IF p_adjustment_type IN ( 'BILL_RATE', 'QUANTITY') THEN
   END IF;  --IF P_rev_budget_version_id IS NULL AND
--For quantity proceeding if even one of the two ie.., cost or revenue budget version id is not locked.
END IF;

--Need to call updates for revenue version / cost version when appropriate as above.
--Based on the respective rates and versions when both are planned together.

--On check edit failure of financial structure for even one of the versions
--or check edit failure of workplan structure, need to output error message similar
--to that in task assignments.

IF p_resource_assignment_id_tbl.count = 0 THEN
   IF (p_wbs_element_id IS NOT NULL AND p_wbs_structure_version_id IS NOT NULL) OR
      (p_rbs_element_id IS NOT NULL AND p_rbs_version_id IS NOT NULL) THEN

      COMPUTE_HIERARCHY
      (P_cost_budget_version_id    => P_cost_budget_version_id,
       P_rev_budget_version_id     => P_rev_budget_version_id,
       P_WBS_Element_Id            => P_WBS_Element_Id,
       P_RBS_Element_Id            => P_RBS_Element_Id,
       p_WBS_Structure_Version_Id  => p_WBS_Structure_Version_Id,
       p_RBS_Version_Id            => p_RBS_Version_Id,
       p_WBS_Rollup_Flag           => p_WBS_Rollup_Flag,
       p_RBS_Rollup_Flag           => p_RBS_Rollup_Flag,
       X_res_assignment_id_tbl     => L_res_assignment_id_tbl,
       X_txn_currency_code_tbl     => L_txn_curr_code_tbl,
       X_rev_res_assignment_id_tbl => L_rev_res_assignment_id_tbl,
       X_rev_txn_currency_code_tbl => L_rev_txn_curr_code_tbl,
       X_return_status             => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         pa_debug.g_err_stage:='Rasing API_EXCEPTION 5';
         pa_debug.write(L_Module,pa_debug.g_err_stage,3);
         RAISE api_exception;
      END IF;
   ELSE
     pa_debug.g_err_stage:='Rasing API_EXCEPTION 6';
     pa_debug.write(L_Module,pa_debug.g_err_stage,3);
     RAISE api_exception;
   END IF;
ELSE
       IF p_txn_currency_code_tbl.count = 0 THEN
       FOR j in 1..p_resource_assignment_id_tbl.COUNT LOOP
           IF j > 1 THEN
        	  l_predicate1 := l_predicate1 || ',' || p_resource_assignment_id_tbl(j);
           ELSE
        	  l_predicate1 := p_resource_assignment_id_tbl(j);
           END IF;
       END LOOP;

       l_sql := ' select distinct resource_assignment_id, txn_currency_code ' ||
                ' from pa_budget_lines ' ||
                ' where resource_ASSIGNMENT_ID in (' || l_predicate1 || ')';

	OPEN l_cur FOR l_sql;
        l_cnt := 0;
        LOOP
          FETCH l_cur INTO l_t_id, l_t_code;
          EXIT WHEN l_cur%NOTFOUND;
          l_res_assignment_id_tbl.extend(1);
          l_txn_curr_code_tbl.extend(1);
          l_cnt := l_cnt + 1;
          l_res_assignment_id_tbl(l_cnt) := l_t_id;
          l_txn_curr_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE l_cur;
    ELSE
	l_res_assignment_id_tbl := p_resource_assignment_id_tbl;
        l_txn_curr_code_tbl      := p_txn_currency_code_tbl;
        l_rev_res_assignment_id_tbl := p_resource_assignment_id_tbl;
        l_rev_txn_curr_code_tbl := p_txn_currency_code_tbl;
    END IF;
END IF;

IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
  pa_debug.g_err_stage:='Rasing API_EXCEPTION 7';
  pa_debug.write(L_Module,pa_debug.g_err_stage,3);
  RAISE api_exception;
END IF;

IF P_new_version_flag = 'Y' THEN
  IF nvl(p_cost_budget_version_id, -1) <> -1 AND
     ((p_adjustment_type IN ('COST_RATE', 'BURDENED_RATE', 'QUANTITY', 'COST_QUANTITY','RAW_COST','BURDENED_COST')) OR
      (p_cost_plan_setup = 'COST_AND_REV_SAME' AND p_adjustment_type in ('BILL_RATE','REVENUE'))) THEN

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'Calling Copy_Version for Cost',
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_project_id: ' || p_project_id,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_source_version_id: ' || p_cost_budget_version_id,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_copy_mode: ' || PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_calling_mode: ' || PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'px_target_version_id: ' || l_target_budget_version_id,
                     x_log_level => 3);
    END IF;

    PA_FIN_PLAN_PUB.Copy_Version
    (p_project_id           => p_project_id,
     p_source_version_id    => P_cost_budget_version_id ,
     p_copy_mode            => PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
     p_calling_module       => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
	 p_pji_rollup_required	=> 'N',
     px_target_version_id   => l_target_budget_version_id,
     x_return_status        => x_return_status,
     x_msg_count            => x_msg_count,
     x_msg_data             => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      pa_debug.g_err_stage:='Rasing API_EXCEPTION 8';
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);
      RAISE api_exception;
    ELSE
      pa_debug.g_err_stage:='Copy_Version Returned Success';
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);

      IF L_res_assignment_id_tbl.count <> 0 THEN
	    FOR j in 1..l_res_assignment_id_tbl.COUNT LOOP
          IF j > 1 THEN
        	l_predicate3 := l_predicate3 || ',' || l_res_assignment_id_tbl(j);
          ELSE
        	l_predicate3 := l_res_assignment_id_tbl(j);
          END IF;
       	END LOOP;

        --Reinitialize  L_res_assignment_id_tbl if necessary...

        -- SQL Repository Bug 4884427; SQL ID 14901305
        -- Replaced l_target_budget_version_id literal with a bind variable.

        l_sql3 := ' select distinct pra.resource_assignment_id, bl.txn_currency_code ' ||
        ' from pa_resource_assignments pra, pa_budget_lines bl ' ||
        ' where pra.budget_version_id = :1 ' || /* to_char(l_target_budget_version_id) || */
        ' and   pra.resource_assignment_id = bl.resource_assignment_id ' ||
        ' and pra.parent_assignment_id in (' || l_predicate3 || ')';

        pa_debug.g_err_stage:='l_sql3: ' || l_sql3;
        pa_debug.write(L_Module,pa_debug.g_err_stage,3);

        -- SQL Repository Bug 4884427; SQL ID 14901305
        -- Supply the bind variable value with the USING clause.

        OPEN l_cur3 FOR l_sql3 USING l_target_budget_version_id;
        l_cnt := 0;
        LOOP
          FETCH l_cur3 into l_t_id, l_t_code;
          EXIT WHEN l_cur3%NOTFOUND;
          l_cnt := l_cnt + 1;
          IF NOT l_res_assignment_id_tbl.exists(l_cnt) THEN
            l_res_assignment_id_tbl.extend(1);
          END IF;
          IF NOT l_txn_curr_code_tbl.exists(l_cnt) THEN
            l_txn_curr_code_tbl.extend(1);
          END IF;
          l_res_assignment_id_tbl(l_cnt) := l_t_id;
          l_txn_curr_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE l_cur3;
       END IF;
     END IF;

     IF (P_new_version_name IS NOT NULL)
        OR (P_new_version_desc IS NOT NULL) THEN

       UPDATE PA_BUDGET_VERSIONS SET version_name = p_new_version_name,
                                     description = p_new_version_desc
                               WHERE budget_version_id = l_target_budget_version_id;
     END IF;
     x_cost_budget_version_id := l_target_budget_version_id;
  END IF;

  IF nvl(p_rev_budget_version_id, -1) <> -1 AND
     p_adjustment_type IN ('BILL_RATE', 'QUANTITY', 'REVENUE_QUANTITY','REVENUE') THEN

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'Calling Copy_Version for Revenue',
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_project_id: ' || p_project_id,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_source_version_id: ' || p_rev_budget_version_id,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_copy_mode: ' || PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'p_calling_mode: ' || PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
                     x_log_level => 3);
      PA_DEBUG.write(x_module    => L_Module,
                     x_msg       => 'px_target_version_id: ' || l_target_rev_version_id,
                     x_log_level => 3);
    END IF;

    PA_FIN_PLAN_PUB.Copy_Version
    (p_project_id           => p_project_id,
     p_source_version_id    => P_rev_budget_version_id ,
     p_copy_mode            => PA_FP_CONSTANTS_PKG.G_BUDGET_STATUS_WORKING,
     p_calling_module       => PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_FIN_PLAN,
	 p_pji_rollup_required	=> 'N',
     px_target_version_id   => l_target_rev_version_id,
     x_return_status        => x_return_status,
     x_msg_count            => x_msg_count,
     x_msg_data             => x_msg_data);

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      pa_debug.g_err_stage:='Rasing API_EXCEPTION 9';
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);
      RAISE api_exception;
    ELSE
      pa_debug.g_err_stage:='copy Version Returned Success';
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);
      IF L_rev_res_assignment_id_tbl.count <> 0 THEN
        FOR j in 1..L_rev_res_assignment_id_tbl.COUNT LOOP
          IF j > 1 THEN
            l_predicate2 := l_predicate2 || ',' || L_rev_res_assignment_id_tbl(j);
          ELSE
            l_predicate2 := L_rev_res_assignment_id_tbl(j);
          END IF;
        END LOOP;

        -- SQL Repository Bug 4884427; SQL ID 14901323
        -- Replaced l_target_rev_version_id literal with a bind variable.

         l_sql2 := ' select distinct pra.resource_assignment_id, bl.txn_currency_code ' ||
         ' from pa_resource_assignments pra, pa_budget_lines bl ' ||
         ' where pra.budget_version_id = :1 ' || /* to_char(l_target_rev_version_id) || */
         ' and   pra.resource_assignment_id = bl.resource_assignment_id ' ||
       	 ' and pra.parent_assignment_id in (' || l_predicate2 || ')';


        pa_debug.g_err_stage:='l_sql2: ' || l_sql2;
        pa_debug.write(L_Module,pa_debug.g_err_stage,3);

        -- SQL Repository Bug 4884427; SQL ID 14901323
        -- Supply the bind variable value with the USING clause.

        OPEN l_cur2 FOR l_sql2 USING l_target_rev_version_id;
        l_cnt := 0;
        LOOP
          FETCH l_cur2 INTO l_t_id, l_t_code;
          EXIT WHEN l_cur2%NOTFOUND;
          l_cnt := l_cnt + 1;
          IF NOT l_rev_res_assignment_id_tbl.exists(l_cnt) THEN
            l_rev_res_assignment_id_tbl.extend(1);
          END IF;
          IF NOT l_rev_txn_curr_code_tbl.exists(l_cnt) THEN
            l_rev_txn_curr_code_tbl.extend(1);
          END IF;
          l_rev_res_assignment_id_tbl(l_cnt) := l_t_id;
          l_rev_txn_curr_code_tbl(l_cnt) := l_t_code;
        END LOOP;
        CLOSE l_cur2;
      END IF;
    END IF;

   	IF  (P_new_version_name IS NOT NULL)
     OR (P_new_version_desc IS NOT NULL) THEN

       UPDATE PA_BUDGET_VERSIONS SET version_name = p_new_version_name,
                                     description = p_new_version_desc
                               WHERE budget_version_id = l_target_rev_version_id;
    END IF;
    x_rev_budget_version_id := l_target_rev_version_id;
  END IF;
END IF;

-- Start of Debug Statements
pa_debug.g_err_stage:='l_cost_budget_version_id ' || l_cost_budget_version_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:='l_rev_budget_version_id ' || l_rev_budget_version_id;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:='l_quantity_adj_pct ' || l_quantity_adj_pct;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:='l_burdened_rate_adj_pct ' || l_burdened_rate_adj_pct;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
pa_debug.g_err_stage:='l_bill_rate_adj_pct ' || l_bill_rate_adj_pct;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);

IF l_res_assignment_id_tbl.COUNT > 0 THEN
   FOR i IN l_res_assignment_id_tbl.FIRST .. l_res_assignment_id_tbl.LAST LOOP
      pa_debug.g_err_stage:= L_FuncProc || '  l_res_assignment_id_tbl(' || i || '): ' || l_res_assignment_id_tbl(i);
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);
   END LOOP;
ELSE
   pa_debug.g_err_stage:= L_FuncProc || ' l_res_assignment_id_tbl is EMPTY';
   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
END IF;

IF l_txn_curr_code_tbl.COUNT > 0 THEN
   FOR i IN l_txn_curr_code_tbl.FIRST .. l_txn_curr_code_tbl.LAST LOOP
      pa_debug.g_err_stage:= L_FuncProc || '  l_txn_curr_code_tbl(' || i || '): ' || l_txn_curr_code_tbl(i);
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);
   END LOOP;
ELSE
   pa_debug.g_err_stage:= L_FuncProc || ' l_txn_curr_code_tbl is EMPTY';
   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
END IF;

IF l_rev_res_assignment_id_tbl.COUNT > 0 THEN
   FOR i IN l_rev_res_assignment_id_tbl.FIRST .. l_rev_res_assignment_id_tbl.LAST LOOP
      pa_debug.g_err_stage:= L_FuncProc || '  l_rev_res_assignment_id_tbl(' || i || '): ' || l_rev_res_assignment_id_tbl(i);
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);
   END LOOP;
ELSE
   pa_debug.g_err_stage:= L_FuncProc || ' l_rev_res_assignment_id_tbl is EMPTY';
   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
END IF;

IF l_rev_txn_curr_code_tbl.COUNT > 0 THEN
   FOR i IN l_rev_txn_curr_code_tbl.FIRST .. l_rev_txn_curr_code_tbl.LAST LOOP
      pa_debug.g_err_stage:= L_FuncProc || '  l_rev_txn_curr_code_tbl(' || i || '): ' || l_rev_txn_curr_code_tbl(i);
      pa_debug.write(L_Module,pa_debug.g_err_stage,3);
   END LOOP;
ELSE
   pa_debug.g_err_stage:= L_FuncProc || ' l_rev_txn_curr_code_tbl is EMPTY';
   pa_debug.write(L_Module,pa_debug.g_err_stage,3);
END IF;
-- End of Debugging Statements

IF l_res_assignment_id_tbl.COUNT = 0 AND l_rev_res_assignment_id_tbl.COUNT = 0 THEN
   PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA'
                        ,p_msg_name       => 'PA_PL_ADJUST_NO_DATA');
   x_msg_data := 'PA_PL_ADJUST_NO_DATA';
   x_return_status := FND_API.G_RET_STS_ERROR;
   RAISE  FND_API.G_EXC_ERROR;
ELSE
   IF nvl(p_cost_budget_version_id, -1) <> -1 AND
      ((p_adjustment_type IN ('COST_RATE', 'BURDENED_RATE', 'QUANTITY', 'COST_QUANTITY','RAW_COST','BURDENED_COST')) OR
       (p_cost_plan_setup = 'COST_AND_REV_SAME' AND p_adjustment_type in ('BILL_RATE','REVENUE'))) AND
      l_res_assignment_id_tbl.COUNT > 0 THEN

      IF p_new_version_flag = 'Y' THEN
		 pa_fp_calc_plan_pkg.calculate (
                       p_project_id                    => p_project_id
                      ,p_budget_version_id             => l_target_budget_version_id
		      ,p_rollup_required_flag	       => 'N'
                      ,p_mass_adjust_flag              => 'Y'
                      ,p_quantity_adj_pct              => l_quantity_adj_pct
                      ,p_cost_rate_adj_pct             => l_cost_rate_adj_pct
                      ,p_burdened_rate_adj_pct         => l_burdened_rate_adj_pct
                      /* IPM changes */
                      ,p_raw_cost_adj_pct              => l_raw_cost_adj_pct
                      ,p_burden_cost_adj_pct           => l_burden_cost_adj_pct
                      ,p_revenue_adj_pct               => l_revenue_adj_pct
                      ,p_bill_rate_adj_pct             => l_bill_rate_adj_pct
                      ,p_source_context                => 'RESOURCE_ASSIGNMENT'
                      ,p_resource_assignment_tab       => l_res_assignment_id_tbl
                      ,p_txn_currency_code_tab         => l_txn_curr_code_tbl
                      ,x_return_status                 => x_return_status
                      ,x_msg_count                     => x_msg_count
                      ,x_msg_data                      => x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          pa_debug.g_err_stage:='Rasing API_EXCEPTION 10';
          pa_debug.write(L_Module,pa_debug.g_err_stage,3);
          RAISE api_exception;
        END IF;

		l_target_budget_version_id_tbl.extend(1);
		l_target_budget_version_id_tbl(1) := l_target_budget_version_id;

		PJI_FM_XBS_ACCUM_MAINT.Plan_Create (
		  p_fp_version_ids    => l_target_budget_version_id_tbl,
		  x_return_status	  => x_return_status,
		  x_msg_code		  => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          pa_debug.g_err_stage:='Rasing API_EXCEPTION 11';
          pa_debug.write(L_Module,pa_debug.g_err_stage,3);
          RAISE api_exception;
        END IF;
      ELSE
		pa_fp_calc_plan_pkg.calculate (
                       p_project_id                    => p_project_id
                      ,p_budget_version_id             => p_cost_budget_version_id
		      ,p_rollup_required_flag	       => 'Y'
                      ,p_mass_adjust_flag              => 'Y'
                      ,p_quantity_adj_pct              => l_quantity_adj_pct
                      ,p_cost_rate_adj_pct             => l_cost_rate_adj_pct
                      ,p_burdened_rate_adj_pct         => l_burdened_rate_adj_pct
                      ,p_bill_rate_adj_pct             => l_bill_rate_adj_pct
                      /* IPM changes */
                      ,p_raw_cost_adj_pct              => l_raw_cost_adj_pct
                      ,p_burden_cost_adj_pct           => l_burden_cost_adj_pct
                      ,p_revenue_adj_pct               => l_revenue_adj_pct
                      ,p_source_context                => 'RESOURCE_ASSIGNMENT'
                      ,p_resource_assignment_tab       => l_res_assignment_id_tbl
                      ,p_txn_currency_code_tab         => l_txn_curr_code_tbl
                      ,x_return_status                 => x_return_status
                      ,x_msg_count                     => x_msg_count
                      ,x_msg_data                      => x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          pa_debug.g_err_stage:='Rasing API_EXCEPTION 12';
          pa_debug.write(L_Module,pa_debug.g_err_stage,3);
          RAISE api_exception;
        END IF;
      END IF;
   END IF;

   IF nvl(p_rev_budget_version_id, -1) <> -1 AND
      nvl(p_rev_budget_version_id, -1) <> nvl(p_cost_budget_version_id, -1) AND
      p_adjustment_type IN ('BILL_RATE', 'QUANTITY', 'REVENUE_QUANTITY','REVENUE') AND
      l_rev_res_assignment_id_tbl.COUNT > 0 THEN

      IF p_new_version_flag = 'Y' THEN
        pa_fp_calc_plan_pkg.calculate (
                       p_project_id                    => p_project_id
                      ,p_budget_version_id             => l_target_rev_version_id
                      ,p_rollup_required_flag		   => 'N'
                      ,p_mass_adjust_flag              => 'Y'
                      ,p_quantity_adj_pct              => l_quantity_adj_pct
                      ,p_cost_rate_adj_pct             => l_cost_rate_adj_pct
                      ,p_burdened_rate_adj_pct         => l_burdened_rate_adj_pct
                      ,p_bill_rate_adj_pct             => l_bill_rate_adj_pct
                      /* IPM changes */
                      ,p_raw_cost_adj_pct              => l_raw_cost_adj_pct
                      ,p_burden_cost_adj_pct           => l_burden_cost_adj_pct
                      ,p_revenue_adj_pct               => l_revenue_adj_pct
                      ,p_source_context                => 'RESOURCE_ASSIGNMENT'
                      ,p_resource_assignment_tab       => l_rev_res_assignment_id_tbl
                      ,p_txn_currency_code_tab         => l_rev_txn_curr_code_tbl
                      ,x_return_status                 => x_return_status
                      ,x_msg_count                     => x_msg_count
                      ,x_msg_data                      => x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          pa_debug.g_err_stage:='Rasing API_EXCEPTION 13';
          pa_debug.write(L_Module,pa_debug.g_err_stage,3);
          RAISE api_exception;
        END IF;

		l_target_rev_version_id_tbl.extend(1);
		l_target_rev_version_id_tbl(1) := l_target_rev_version_id;

		PJI_FM_XBS_ACCUM_MAINT.Plan_Create (
		  p_fp_version_ids    => l_target_rev_version_id_tbl,
		  x_return_status	  => x_return_status,
		  x_msg_code		  => x_msg_data);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          pa_debug.g_err_stage:='Rasing API_EXCEPTION 14';
          pa_debug.write(L_Module,pa_debug.g_err_stage,3);
          RAISE api_exception;
        END IF;
      ELSE
        pa_fp_calc_plan_pkg.calculate (
                       p_project_id                    => p_project_id
                      ,p_budget_version_id             => p_rev_budget_version_id
                      ,p_rollup_required_flag		   => 'Y'
                      ,p_mass_adjust_flag              => 'Y'
                      ,p_quantity_adj_pct              => l_quantity_adj_pct
                      ,p_cost_rate_adj_pct             => l_cost_rate_adj_pct
                      ,p_burdened_rate_adj_pct         => l_burdened_rate_adj_pct
                      ,p_bill_rate_adj_pct             => l_bill_rate_adj_pct
                      /* IPM changes */
                      ,p_raw_cost_adj_pct              => l_raw_cost_adj_pct
                      ,p_burden_cost_adj_pct           => l_burden_cost_adj_pct
                      ,p_revenue_adj_pct               => l_revenue_adj_pct
                      ,p_source_context                => 'RESOURCE_ASSIGNMENT'
                      ,p_resource_assignment_tab       => l_rev_res_assignment_id_tbl
                      ,p_txn_currency_code_tab         => l_rev_txn_curr_code_tbl
                      ,x_return_status                 => x_return_status
                      ,x_msg_count                     => x_msg_count
                      ,x_msg_data                      => x_msg_data);
		IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          pa_debug.g_err_stage:='Rasing API_EXCEPTION 15';
          pa_debug.write(L_Module,pa_debug.g_err_stage,3);
          RAISE api_exception;
        END IF;
      END IF;
   END IF;

   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      COMMIT;
   END IF;
END IF;

pa_debug.g_err_stage:='End of ' || L_FuncProc;
pa_debug.write(L_Module,pa_debug.g_err_stage,3);
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_count := Fnd_Msg_Pub.count_msg;
    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      PA_DEBUG.write_log (x_module    => L_Module
                         ,x_msg       => 'Error: ' || L_FuncProc || ' ' || SQLERRM
                         ,x_log_level => 3);
    END IF;
  WHEN API_EXCEPTION THEN
    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
      PA_DEBUG.write_log (x_module    => L_Module
                         ,x_msg       => 'Error:' || L_FuncProc || SQLERRM
                         ,x_log_level => 3);
    END IF;
	FND_MSG_PUB.add_exc_msg(p_pkg_name       => L_Module,
                            p_procedure_name => L_FuncProc);
    RAISE;
  WHEN OTHERS THEN
    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
      PA_DEBUG.write_log (x_module    => L_Module
                         ,x_msg       => 'Unexp. Error:' || L_FuncProc || SQLERRM
                         ,x_log_level => 6);
    END IF;
    FND_MSG_PUB.add_exc_msg(p_pkg_name       => L_Module,
                            p_procedure_name => L_FuncProc);
    RAISE;
END ADJUST_PLANNING_TRANSACTIONS;



FUNCTION CLASS_HOURS(p_current_budget_version_id IN NUMBER, p_input_budget_version_id IN NUMBER,
                     p_rev_budget_version_id IN NUMBER, p_report_using IN VARCHAR2,
                     p_mode IN VARCHAR2, p_resource_class_code IN VARCHAR2,
                     p_total_plan_quantity IN NUMBER, p_rate_based_flag IN VARCHAR2 ) RETURN NUMBER IS
l_num NUMBER;
BEGIN

IF p_report_using = 'COST' and p_current_budget_version_id <> p_input_budget_version_id THEN
  l_num := 0;
  RETURN l_num;
ELSIF p_report_using = 'REVENUE' and p_rev_budget_version_id IS NOT NULL AND
      p_current_budget_version_id <> p_rev_budget_version_id THEN
  l_num := 0;
  RETURN l_num;
END IF;

IF (p_input_budget_version_id IS NULL OR p_current_budget_version_id <> p_input_budget_version_id) AND
   (p_rev_budget_version_id IS NULL OR p_current_budget_version_id <> p_rev_budget_version_id) THEN
  l_num := 0;
  RETURN l_num;
END IF;

IF p_resource_class_code = 'PEOPLE' and p_mode = 'PEOPLE' and p_rate_based_flag = 'Y' then
 l_num := nvl(p_total_plan_quantity, 0);
ELSIF p_resource_class_code  =  'EQUIPMENT' and p_mode = 'EQUIPMENT' and p_rate_based_flag = 'Y' then
 l_num := nvl(p_total_plan_quantity, 0);
ELSE
 l_num := 0;
END IF;

RETURN l_num;
EXCEPTION WHEN OTHERS THEN
  RETURN 0;
END;


FUNCTION REVENUE(p_current_budget_version_id IN NUMBER, p_input_budget_version_id IN NUMBER,
                 p_rev_budget_version_id IN NUMBER, p_REVENUE IN NUMBER) RETURN NUMBER IS
l_num NUMBER;

BEGIN

IF nvl(p_rev_budget_version_id, -1) = -1 and (p_input_budget_version_id = p_current_budget_version_id) THEN

 l_num := nvl(p_REVENUE , 0);

ELSIF  nvl(p_rev_budget_version_id, -1) <> -1 and
      (p_rev_budget_version_id = p_current_budget_version_id)  THEN

 l_num := nvl(p_REVENUE , 0);

ELSE
 l_num := 0;
END IF;

RETURN l_num;
EXCEPTION WHEN OTHERS THEN
  RETURN 0;
END;

--Messages --Use PA_NO_ACCESS_TO_UPDATE and
-- PA_ALL_NO_UPDATE_RECORD
END PA_FP_ADJUSTMENT_UTILS ;

/
