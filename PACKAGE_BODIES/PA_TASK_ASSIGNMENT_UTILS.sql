--------------------------------------------------------
--  DDL for Package Body PA_TASK_ASSIGNMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASK_ASSIGNMENT_UTILS" as
--/* $Header: PATAUTLB.pls 120.16.12010000.4 2010/03/16 23:21:24 rbruno ship $ */

P_DEBUG_MODE varchar2(1) := NVL(FND_PROFILE.value('PA_DEBUG_MODE'), 'N');
L_MODULE varchar2(100) := 'PA_TASK_ASSIGNMENT_UTILS';
li_message_level NUMBER := 1;
li_curr_level NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;





--
--  FUNCTION
--              Get_Task_Resources
--  PURPOSE
--              Returns VARCHAR - a string of planning resource aliases on a given task.
-- Input parameters
-- Parameters                   Type           Required  Description
-- p_element_version_id         NUMBER          YES      Element Version Id
--  Author : jraj 01/08/03

FUNCTION Get_Task_Resources(p_element_version_id IN NUMBER) RETURN VARCHAR2 IS

l_resource_aliases VARCHAR2(20000);

CURSOR C1_GTR(p_element_version_id in NUMBER) IS
	SELECT pr.alias
	FROM pa_resource_assignments ra, pa_resource_list_members pr
	WHERE ra.resource_list_member_id = pr.resource_list_member_id
	AND ra.wbs_element_version_id = p_element_version_id
	AND ra.resource_class_code = 'PEOPLE'
	AND ra.ta_display_flag = 'Y'
	AND rownum <= 5

	UNION ALL

	SELECT pr.alias
	FROM pa_resource_assignments ra, pa_resource_list_members pr
	WHERE ra.resource_list_member_id = pr.resource_list_member_id
	AND ra.wbs_element_version_id = p_element_version_id
	AND ra.resource_class_code = 'EQUIPMENT'
	AND ra.ta_display_flag = 'Y'
	AND rownum <= 5

	UNION ALL

	SELECT pr.alias
	FROM pa_resource_assignments ra, pa_resource_list_members pr
	WHERE ra.resource_list_member_id = pr.resource_list_member_id
	AND ra.wbs_element_version_id = p_element_version_id
	AND ra.resource_class_code = 'MATERIAL_ITEMS'
	AND ra.ta_display_flag = 'Y'
	AND rownum <= 5

	UNION ALL

	SELECT pr.alias
	FROM pa_resource_assignments ra, pa_resource_list_members pr
	WHERE ra.resource_list_member_id = pr.resource_list_member_id
	AND ra.wbs_element_version_id = p_element_version_id
	AND ra.resource_class_code = 'FINANCIAL_ELEMENTS'
	AND ra.ta_display_flag = 'Y'
	AND rownum <= 5;

L_FuncProc varchar2(250) := 'DEFAULT';
v_C1_GTR C1_GTR%ROWTYPE;

BEGIN

   L_FuncProc := 'Get_Task_Resources';

   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
       PA_DEBUG.write_log (x_module      => L_Module,
                           x_msg         => 'Entered' || L_FuncProc,
                           x_log_level   => 3);
   END IF;

   OPEN C1_GTR( p_element_version_id);

   FOR loop_index in 1..6 LOOP

      FETCH C1_GTR INTO v_C1_GTR;
      EXIT WHEN C1_GTR%NOTFOUND;
      IF loop_index = 1 THEN
         l_resource_aliases := v_C1_GTR.alias;
      ELSIF loop_index < 6 THEN
         l_resource_aliases := l_resource_aliases || ',' || v_C1_GTR.alias;
      ELSIF loop_index = 6 THEN
         l_resource_aliases := l_resource_aliases || '...';
      END IF;

   END LOOP;

   CLOSE C1_GTR;

   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
       PA_DEBUG.write_log (x_module    => L_Module,
                           x_msg       => 'Returning:' || L_FuncProc,
                           x_log_level => 3);
   END IF;

   RETURN (l_resource_aliases);

   EXCEPTION

       WHEN NO_DATA_FOUND THEN
           IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
               PA_DEBUG.write_log (x_module    => L_Module,
                                   x_msg       => 'Error:' || L_FuncProc || SQLERRM,
                                   x_log_level => 5);
           END IF;

       WHEN OTHERS THEN
           IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
               PA_DEBUG.write_log (x_module    => L_Module,
                                   x_msg       => 'Unexp. Error:' || L_FuncProc || SQLERRM,
                                   x_log_level => 6);
           END IF;
           FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TASK_ASSIGNMENT_UTILS',
                                    p_procedure_name => 'Get_Task_Resources');
           RAISE;

END  Get_Task_Resources;





--
--  FUNCTION
--              Check_Asgmt Exists in Task
--  PURPOSE
--              Returns VARCHAR - 'Y' if task assignment exists in the given workplan task version.
-- Input parameters
-- Parameters                   Type           Required  Description
-- p_element_version_id         NUMBER          YES      Element Version Id
--  Author : jraj 01/08/03

FUNCTION Check_Asgmt_Exists_In_Task(p_element_version_id IN NUMBER) RETURN VARCHAR2

IS

l_exists varchar2(1) := 'N';

CURSOR C1_Check_Exists(p_element_version_id IN NUMBER) IS
   SELECT 'Y'
   FROM pa_resource_assignments ra
   WHERE ra.ta_display_flag = 'Y'
   AND ra.wbs_element_version_id = p_element_version_id
   AND rownum = 1;

L_FuncProc varchar2(250) ;

BEGIN

    L_FuncProc := 'Check_Asgmt_Exists_In_Task';

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        PA_DEBUG.write_log (x_module    => L_Module,
                            x_msg       => 'Entered' || L_FuncProc,
                            x_log_level => 3);
    END IF;

    OPEN C1_Check_Exists(p_element_version_id);
    FETCH C1_Check_Exists INTO L_exists;
    CLOSE C1_Check_Exists;

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        PA_DEBUG.write_log (x_module => L_Module,
                            x_msg         => 'Returning:' || L_FuncProc ||':'|| L_EXISTS,
                            x_log_level   => 3);
    END IF;

    RETURN L_EXISTS;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
            PA_DEBUG.write_log (x_module    => L_Module,
                                x_msg       => 'Error:' || L_FuncProc || SQLERRM,
                                x_log_level => 5);
        END IF;
        RETURN 'N';

    WHEN OTHERS THEN
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexp. Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_TASK_ASSIGNMENT_UTILS',
                                 p_procedure_name => 'Check_Asgmt_Exists_In_Task');
        RAISE;

END Check_Asgmt_Exists_In_Task;





--DOOSAN 2
--
--  FUNCTION
--              	Check_Task_Asgmt_Exists
--  PURPOSE
--  If task assignment exists in the given financial task on the given ei date
--  for a person, return 'Y'; otherwise, return 'N'.
-- Input parameters
-- Parameters                   Type           Required  Description
-- p_element_version_id         NUMBER          YES      Element Version Id
-- p_person_id                  NUMBER          YES      Person Id
-- p_financial_task_id          NUMBER          YES      Financial Task Id
-- p_ei_date                    DATE            YES
--  Author : jraj 01/08/03

FUNCTION Check_Task_Asgmt_Exists(
         p_person_id IN NUMBER,
         p_financial_task_id IN NUMBER,
         p_ei_date IN DATE) RETURN VARCHAR2
IS

l_exists VARCHAR2(1) := 'N';
--l_wp_task_id NUMBER;

--CURSOR C1_Check_Exists(p_wp_task_id IN NUMBER, p_ei_date IN DATE) IS
CURSOR C1_Check_Exists(p_ei_date IN DATE, p_project_id IN NUMBER) IS
	SELECT 'Y'
	FROM pa_resource_assignments ra, pa_map_wp_to_fin_tasks_v map
	WHERE p_ei_date BETWEEN ra.planning_start_date AND ra.planning_end_Date
	AND ra.person_id = p_person_id
	AND ra.ta_display_flag = 'Y'
	AND ra.wbs_element_version_id = map.element_version_id
	AND map.mapped_fin_task_id = p_financial_task_id
	AND map.project_id = p_project_id
	AND ROWNUM = 1;

CURSOR C_Get_Project_Id IS
	SELECT project_id
	FROM pa_proj_elements
	WHERE proj_element_id = p_financial_task_id;

l_project_id NUMBER := to_number(NULL);
L_FuncProc VARCHAR2(250) ;

BEGIN

    L_FuncProc := 'Check_Task_Asgmt_Exists';

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        PA_DEBUG.write_log (x_module => L_Module,
                            x_msg         => 'Entered:' || L_FuncProc,
                            x_log_level   => 3);
    END IF;

	OPEN C_Get_Project_Id;
	FETCH C_Get_Project_Id INTO l_project_id;
	CLOSE C_Get_Project_Id;

	IF l_project_id IS NOT NULL THEN

	    OPEN C1_Check_Exists(p_ei_date, l_project_id);
	    FETCH C1_Check_Exists INTO L_exists;
	    CLOSE C1_Check_Exists;

	END IF;

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        PA_DEBUG.write_log (x_module => L_Module,
                            x_msg         => 'Returning:' || L_FuncProc ||':'|| L_EXISTS,
                            x_log_level   => 3);
    END IF;

    RETURN L_EXISTS;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
          PA_DEBUG.write_log (x_module => L_Module,
                              x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                              x_log_level   => 5);
        END IF;
        RETURN 'N';

    WHEN OTHERS THEN
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
          PA_DEBUG.write_log (x_module => L_Module,
                              x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                              x_log_level   => 6);
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                                 p_procedure_name => L_FuncProc);
        RAISE;

END Check_Task_Asgmt_Exists;





--
--  FUNCTION
--              Compare Dates
--  PURPOSE
--              Returns VARCHAR - 'E ' if first date is earlier than second and
--                                'L' if first date is greater than second and
--                                'S' otherwise.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_First_Date                 DATE            YES       First  Date for Comparison
-- P_Second_Date                DATE            YES       Second Date for Comparison
--  Author : jraj 01/08/03

FUNCTION Compare_Dates(p_first_date IN DATE, p_second_date IN DATE) RETURN VARCHAR2

IS

L_value varchar2(1) := 'L';
L_FuncProc varchar2(250) ;

BEGIN

    L_FuncProc := 'Compare_Dates';

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
        PA_DEBUG.write_log (x_module => L_Module,
                            x_msg         => 'Entered:' || L_FuncProc,
                            x_log_level   => 3);
    END IF;

    IF p_first_date < p_second_date THEN
        RETURN 'E';
    ELSIF p_first_date > p_second_date THEN
        RETURN 'L';
    ELSE
        RETURN 'S';
    END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 5);
        END IF;
        RETURN 'N';

    WHEN OTHERS THEN
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
          PA_DEBUG.write_log (x_module => L_Module,
                              x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                              x_log_level   => 6);
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                                 p_procedure_name => L_FuncProc);
        RAISE;

END Compare_Dates;





-- This procedure will Adjust the Task Assignment Dates
-- upon changes on a Task's Scheduled Dates.
-- Input parameters
-- Parameters                   Type           Required  Description
--p_context                     VARCHAR        NO        'COPY' - does not call
--                                                       update planning transaction.
--                                                       Returns the new dates.
--                                                       'UPDATE' - calls update
--                                                       planning transaction.
--                                                       'INSERT_VALUES' - insert
--                                                       values into temp table.
--p_element_version_id          NUMBER,        YES       Element Version Id
--p_old_task_sch_start          DATE,          YES       Old Task Scheduled Start
--p_old_task_sch_finish         DATE,          YES       Old Task Sch. Finish
--p_new_task_sch_start          DATE,          YES       New Task Sch. Start
--p_new_task_sch_finish         DATE,          YES       New Task Sch. Finish
-- Out parameters
-- Standard


PROCEDURE Adjust_Asgmt_Dates
(
	p_context                IN   VARCHAR2 DEFAULT 'UPDATE',
	p_element_version_id     IN   NUMBER,
	p_old_task_sch_start     IN   DATE,
	p_old_task_sch_finish    IN   DATE DEFAULT NULL,
	p_new_task_sch_start     IN   DATE,
	p_new_task_sch_finish    IN   DATE,
	x_res_assignment_id_tbl  OUT NOCOPY  SYSTEM.PA_NUM_TBL_TYPE,
	x_planning_start_tbl     OUT NOCOPY  SYSTEM.PA_DATE_TBL_TYPE,
	x_planning_end_tbl       OUT NOCOPY  SYSTEM.PA_DATE_TBL_TYPE,
	x_return_status          OUT NOCOPY  VARCHAR2
)

IS

l_struct_ver_id number;
l_budget_ver_id number;
l_use_task_sch_asgmt_tbl     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_use_task_quantity_tbl      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_use_task_task_ver_tbl      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_adj_dates_asgmt_tbl	     SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_adj_task_quantity_tbl      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_adj_task_task_ver_tbl      SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_quantity_tbl               SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_finish_flg_tbl             SYSTEM.pa_varchar2_1_tbl_type  := SYSTEM.pa_varchar2_1_tbl_type();
k                            number;
l_task_elem_version_id_tbl   SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_resource_assignment_id_tbl SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_schedule_start_date_tbl    SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_schedule_end_date_tbl      SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_delay_tbl                  SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_duration_tbl               SYSTEM.pa_num_tbl_type  := SYSTEM.pa_num_tbl_type();
l_new_start_tbl              SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_new_end_tbl                SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_resource_rec_tbl           l_resource_rec_tbl_type;
l_task_rec                   task_rec_type;
l_msg_data                   VARCHAR2(4000);
l_msg_count                  NUMBER;
l_x_return_status            VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS;
l_new_task_sch_start         SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_new_task_sch_finish        SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_use_task_new_sch_start     SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_use_task_new_sch_end       SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_num_of_tasks               NUMBER;
l_db_block_size              NUMBER;
l_num_blocks                 NUMBER;

cursor get_bvid IS
	SELECT bv.budget_version_id, pev.parent_structure_version_id
	from pa_proj_element_versions pev, pa_budget_versions bv
	where pev.element_version_id = p_element_version_id
	and pev.parent_structure_version_id = bv.project_structure_version_id;

L_FuncProc varchar2(250) ;

BEGIN

    L_FuncProc := 'Adjust_Asgmt_Dates';
    x_return_status :=   l_x_return_status ;

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	    pa_debug.g_err_stage:='Beginning of TA: Adjust_Asgmt_Dates: ';
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	    pa_debug.g_err_stage:= 'p_context: ' || p_context;
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	    pa_debug.g_err_stage:= 'p_element_version_id :' || p_element_version_id ;
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	    pa_debug.g_err_stage:='p_old_task_sch_start: ' || p_old_task_sch_start;
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	    pa_debug.g_err_stage:= 'p_new_task_sch_start: ' || p_new_task_sch_start;
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	    pa_debug.g_err_stage:= 'p_new_task_sch_finish: ' || p_new_task_sch_finish ;
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

    IF p_old_task_sch_start <> p_new_task_sch_start OR
       p_old_task_sch_finish <> p_new_task_sch_finish OR
       p_old_task_sch_finish is null THEN

       -- Bug 4153366: If p_context = 'INSERT_VALUES' or 'COPY' or 'UPDATE,
       -- just insert the IN parameters into temp table.

	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	        pa_debug.g_err_stage:= 'insert into temp table:';
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
		END IF;

 /*Bug 4377886 : Included explicitly the column names in the INSERT statement
                 to remove the GSCC Warning File.Sql.33 */

        INSERT INTO pa_copy_asgmts_temp
        (
	SRC_ELEM_VER_ID,
	TARG_ELEM_VER_ID,
	OLD_TASK_SCH_START,
	OLD_TASK_SCH_END,
	NEW_TASK_SCH_START,
	NEW_TASK_SCH_END
	)
        VALUES
	(p_element_version_id, null,
         p_old_task_sch_start,p_old_task_sch_finish,
         p_new_task_sch_start,p_new_task_sch_finish);


    END IF;

    -- Bug 4153366: If p_context = 'UPDATE' or 'COPY'
    -- proceed on deriving new assignment dates
    IF p_context = 'UPDATE' OR p_context = 'COPY' THEN

      SELECT count(SRC_ELEM_VER_ID)
      INTO l_num_of_tasks
      FROM pa_copy_asgmts_temp;

      IF l_num_of_tasks > 0 THEN

        x_res_assignment_id_tbl  := SYSTEM.PA_NUM_TBL_TYPE() ;
        x_planning_start_tbl     := SYSTEM.PA_DATE_TBL_TYPE() ;
        x_planning_end_tbl       := SYSTEM.PA_DATE_TBL_TYPE() ;

        OPEN get_bvid;
        FETCH get_bvid into l_budget_ver_id, l_struct_ver_id;
        CLOSE get_bvid;

	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	        pa_debug.g_err_stage:= 'l_budget_ver_id: ' || l_budget_ver_id;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:= 'l_struct_ver_id: ' || l_struct_ver_id ;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
		END IF;

        -- Bug 4153366: Manually seed the statistics for the temporary table.
	SELECT to_number(value)
	INTO   l_db_block_size
	FROM   v$parameter
	WHERE  name = 'db_block_size';

	l_num_blocks := 1.25 * (l_num_of_tasks * 75) / l_db_block_size;

	-- Manually seed the statistics for the temporary table.
	set_table_stats('PA','PA_COPY_ASGMTS_TEMP', l_num_of_tasks, l_num_blocks, 75);

        --Get all task assignments in the given task with '
    	--Assignment same as Task Duration' flag checked
        --Bug 4153366: Select task versions from temp table.
        SELECT  ra.resource_assignment_id, ra.total_plan_quantity,
                tasks.src_elem_ver_id, tasks.new_task_sch_start, tasks.new_task_sch_end
        BULK COLLECT INTO l_use_task_sch_asgmt_tbl, l_use_task_quantity_tbl,
                          l_use_task_task_ver_tbl, l_use_task_new_sch_start, l_use_task_new_sch_end --Bug 4153366
        FROM    pa_resource_assignments ra, pa_copy_asgmts_temp tasks
        WHERE   ra.use_task_schedule_flag = 'Y'
        AND     ra.ta_display_flag is not null
        AND     ra.budget_version_id =  l_budget_ver_id -- Bug 4229020
        AND     ra.wbs_element_version_id = tasks.src_elem_ver_id;

	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
			pa_debug.g_err_stage:= 'Use task sch case found' ;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
		END IF;

        -- Get all task assignments without the above flag checked and with start or
        -- end date outside the new task dates range:
        -- IB2 Unplanned Actual changes
        -- Replace planning dates with schedule dates
        --Bug 4153366: Select task versions from temp table.
        SELECT ra.resource_assignment_id, ra.total_plan_quantity,
        (ra.schedule_start_date - tasks.OLD_TASK_SCH_START) old_delay,
        (ra.schedule_end_date - ra.schedule_start_date) old_duration,
        (tasks.NEW_TASK_SCH_START + (ra.schedule_start_date - tasks.OLD_TASK_SCH_START)) new_start_date,
        (tasks.NEW_TASK_SCH_START + (ra.schedule_start_date - tasks.OLD_TASK_SCH_START)
                            + (ra.schedule_end_date - ra.schedule_start_date)) new_end_date,
        Compare_Dates((tasks.NEW_TASK_SCH_START + (ra.schedule_start_date - tasks.OLD_TASK_SCH_START)
        + (ra.schedule_end_date - ra.schedule_start_date)), tasks.NEW_TASK_SCH_END),
        -- compare 'new assignment start + old duration' to 'task new end'
        tasks.NEW_TASK_SCH_START,
        tasks.NEW_TASK_SCH_END,
        tasks.src_elem_ver_id
        BULK COLLECT INTO
        l_adj_dates_asgmt_tbl, l_adj_task_quantity_tbl, l_delay_tbl, l_duration_tbl,
  	    l_new_start_tbl,  l_new_end_tbl, l_finish_flg_tbl, l_new_task_sch_start, l_new_task_sch_finish, l_adj_task_task_ver_tbl
        FROM pa_resource_assignments ra, pa_copy_asgmts_temp tasks
        WHERE nvl(ra.use_task_schedule_flag, 'N') <> 'Y'
        AND ra.ta_display_flag is not null
        AND ra.budget_version_id =  l_budget_ver_id
        AND ra.wbs_element_version_id = tasks.src_elem_ver_id;

	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
			pa_debug.g_err_stage:= 'Use Adj. sch case found' ;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:= 'B4 check for dates NULL or not';
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
		END IF;

        IF (l_use_task_sch_asgmt_tbl is not null OR l_adj_dates_asgmt_tbl is not NULL)
           AND ( l_use_task_sch_asgmt_tbl.COUNT  + l_adj_dates_asgmt_tbl.COUNT > 0) THEN

		    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	            pa_debug.g_err_stage:= 'A4 check for dates NULL or not';
	            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			END IF;

            l_resource_assignment_id_tbl.extend(l_use_task_sch_asgmt_tbl.COUNT+l_adj_dates_asgmt_tbl.COUNT);
            l_schedule_start_date_tbl.extend(l_use_task_sch_asgmt_tbl.COUNT+l_adj_dates_asgmt_tbl.COUNT);
            l_schedule_end_date_tbl.extend(l_use_task_sch_asgmt_tbl.COUNT+l_adj_dates_asgmt_tbl.COUNT);
            l_quantity_tbl.extend(l_use_task_sch_asgmt_tbl.COUNT+l_adj_dates_asgmt_tbl.COUNT);
            l_task_elem_version_id_tbl.extend(l_use_task_sch_asgmt_tbl.COUNT+l_adj_dates_asgmt_tbl.COUNT); --Bug 4153366

            For i IN 1..l_use_task_sch_asgmt_tbl.COUNT LOOP

                l_resource_assignment_id_tbl(i) := l_use_task_sch_asgmt_tbl(i);
	        l_quantity_tbl(i)               := l_use_task_quantity_tbl(i);
                l_schedule_start_date_tbl(i)    := l_use_task_new_sch_start(i); --Bug 4153366
                l_schedule_end_date_tbl(i)      := l_use_task_new_sch_end(i); --Bug 4153366
                l_task_elem_version_id_tbl(i)   := l_use_task_task_ver_tbl(i); --Bug 4153366

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:=' l_task_elem_version_id_tbl(i): ' ||  l_task_elem_version_id_tbl(i);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='l_resource_assignment_id_tbl(' || i || ') : ' || l_resource_assignment_id_tbl(i);
			        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			        pa_debug.g_err_stage:='l_schedule_start_date_tbl(' || i || ') : ' || l_schedule_start_date_tbl(i);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='l_schedule_end_date_tbl(' || i || ') : ' || l_schedule_end_date_tbl(i);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

	    END LOOP;

            k := 1;

            FOR i IN (l_use_task_sch_asgmt_tbl.COUNT+1)..(l_use_task_sch_asgmt_tbl.COUNT+l_adj_dates_asgmt_tbl.COUNT) LOOP

    		l_resource_assignment_id_tbl(i)   := l_adj_dates_asgmt_tbl(k);
                l_quantity_tbl(i)                 := l_adj_task_quantity_tbl(k);
                l_task_elem_version_id_tbl(i)     := l_adj_task_task_ver_tbl(k); --Bug 4153366

                --Bug 4153366
    	        IF l_delay_tbl(k) <=  (l_new_task_sch_finish(k) - l_new_task_sch_start(k)) THEN

    		    --new assignment start date = task new start + delay
                    l_schedule_start_date_tbl(i) := l_new_start_tbl(k);

                    IF l_finish_flg_tbl(k) = 'L' THEN
                        --Bug 4153366
                        l_schedule_end_date_tbl(i)  := l_new_task_sch_finish(k);
                    ELSE
                        l_schedule_end_date_tbl(i)  := l_new_end_tbl(k);
                    END IF;

                ELSIF l_delay_tbl(k) > (p_new_task_sch_finish - p_new_task_sch_start ) THEN

                    --Assignment dates should be defaulted to task dates:
                    --Bug 4153366
    	            l_schedule_start_date_tbl(i) := l_new_task_sch_start(k);
                    l_schedule_end_date_tbl(i)   := l_new_task_sch_finish(k);

                END IF;

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:='l_resource_assignment_id_tbl(' || i || ') : ' || l_resource_assignment_id_tbl(i);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='l_schedule_start_date_tbl(' || i || ') : ' || l_schedule_start_date_tbl(i);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='l_schedule_end_date_tbl(' || i || ') : ' || l_schedule_end_date_tbl(i);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

    		k := k + 1;

            END LOOP;

            IF p_context = 'UPDATE' THEN

	    	   	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:= ' B4 update planning transaction call  update in adjust dates:  ' ||  x_return_status;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

                pa_fp_planning_transaction_pub.update_planning_transactions
                (
                    p_context                      =>          'TASK_ASSIGNMENT',
                    p_struct_elem_version_id       =>          l_struct_ver_id,
                    p_budget_version_id            =>          l_budget_ver_id,
                    p_task_elem_version_id_tbl     =>          l_task_elem_version_id_tbl,
                    p_resource_assignment_id_tbl   =>          l_resource_assignment_id_tbl,
                    p_schedule_start_date_tbl      =>          l_schedule_start_date_tbl,
                    p_schedule_end_date_tbl        =>          l_schedule_end_date_tbl,
                    X_Return_Status		   =>          x_return_status,
                    X_Msg_Data		           =>          l_msg_data,
                    X_Msg_Count		           =>          l_msg_count
		);

			    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:= 'x_return_status after update in adjust dates ' ||  x_return_status;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

                -- Bug 4153366 - clear the temp table
		DELETE pa_copy_asgmts_temp;

            ELSIF p_context = 'COPY' THEN

                x_res_assignment_id_tbl  := l_resource_assignment_id_tbl ;
                x_planning_start_tbl     := l_schedule_start_date_tbl ;
                x_planning_end_tbl       := l_schedule_end_date_tbl ;

                -- Bug 4153366 - clear the temp table
                -- Bug 4164909 - Should also empty the temp table upon copy
                DELETE pa_copy_asgmts_temp;

            END IF; -- p_context

        END IF; -- IF (l_use_task_sch_asgmt_tbl is not null...

       END IF; -- IF l_num_of_tasks > 0 THEN

      END IF; --  IF p_context = 'UPDATE' OR p_context = 'COPY' THEN

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN

	-- 4537865
	x_res_assignment_id_tbl :=  NULL ;
        x_planning_start_tbl    := NULL ;
        x_planning_end_tbl      := NULL ;
	-- 4537865

        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 5);
        END IF;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        -- 4537865
        x_res_assignment_id_tbl :=  NULL ;
        x_planning_start_tbl    := NULL ;
        x_planning_end_tbl      := NULL ;
        -- 4537865
        -- Bug 4153366 - clear the temp table
        DELETE pa_copy_asgmts_temp;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        RAISE;

    WHEN OTHERS THEN
        -- 4537865
        x_res_assignment_id_tbl :=  NULL ;
        x_planning_start_tbl    := NULL ;
        x_planning_end_tbl      := NULL ;
        -- 4537865
        -- Bug 4153366 - clear the temp table
        DELETE pa_copy_asgmts_temp;

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                                 p_procedure_name => L_FuncProc);
        RAISE;

END Adjust_Asgmt_Dates;





-- This procedure will Validate the Creation
-- and also obtain task assignment specific attributes upon
-- Planning transaction creation.

PROCEDURE Validate_Create_Assignment
(
	p_calling_context              IN            VARCHAR2 DEFAULT NULL,   -- Added for Bug 6856934
	p_one_to_one_mapping_flag      IN VARCHAR2 DEFAULT 'N',
	p_task_rec_tbl                 IN            l_task_rec_tbl_type,
	p_task_assignment_tbl          IN OUT NOCOPY l_resource_rec_tbl_type,
	x_del_task_level_rec_code_tbl  OUT NOCOPY     SYSTEM.PA_VARCHAR2_30_TBL_TYPE,
	x_return_status                OUT NOCOPY     VARCHAR2
)

IS

l_task_sch_start  DATE;
l_task_sch_end    DATE;
l_people_index    NUMBER;
l_equip_index     NUMBER;
l_people_count    NUMBER;
l_equip_count     NUMBER;
l_task_people_effort NUMBER;
l_task_equip_effort  NUMBER;
l_task_number    VARCHAR2(240);
l_task_name      VARCHAR2(240);
l_resource_class_code VARCHAR2(240);
l_msg_count NUMBER;
l_msg_data VARCHAR2(2000);
l_task_effort_asgmt_exist_flag VARCHAR2(1) := 'N';
L_FuncProc varchar2(250) ;

CURSOR C1_Task_Info(p_elem_version_id IN NUMBER) IS
    SELECT pevs.scheduled_start_date, pevs.scheduled_finish_date,
	   pe.name task_name, pe.element_number task_number,
           pe.proj_element_id
    FROM pa_proj_elem_ver_schedule pevs, pa_proj_element_versions pev,
	     pa_proj_elements pe
    WHERE pev.element_version_id = pevs.element_version_id
    AND pev.element_version_id = p_elem_version_id
	AND pev.proj_element_id = pe.proj_element_id;

CURSOR C_Named_Role(p_project_assignment_id IN NUMBER) IS
	SELECT assignment_name, project_role_id
	FROM pa_project_assignments
	WHERE assignment_id = p_project_assignment_id;

l_planning_resource_alias varchar2(240);
l_edit_task_ok VARCHAR2(1);
l_task_people_act_effort NUMBER;
l_task_equip_act_effort NUMBER;
l_task_rec_project_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_task_rec_task_ver_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

-- IB2 Unplanned Actual changes
l_task_version_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_task_planned_effort_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();

l_progress_task_id SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_progress_rlm_id SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_task_proj_element_id NUMBER := NULL;
l_progress_exists VARCHAR2(1);
l_progress_rollup_required VARCHAR2(1) := 'N';
l_return_status VARCHAR2(1);

-- rbruno added for bug 9468665 - start
cursor c_use_task_schedule_flag(p_project_id in number) is
  select use_task_schedule_flag
  from pa_workplan_options_v
  where project_id = p_project_id;
l_use_task_schedule_flag VARCHAR2(1);
-- rbruno added for bug 9468665 - end


BEGIN

    L_FuncProc := 'Validate_Create_Assignment';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_require_progress_rollup := 'N'; -- End of Bug 4492493

    --Loop through each task record in p_task_rec_tbl
    --Get default Planning Dates:
    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	    pa_debug.g_err_stage:='Beginning of PA_TASK_ASSIGNMENT_UTILS.Validate_Create_Assignment';
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

    x_del_task_level_rec_code_tbl := system.pa_varchar2_30_tbl_type();
    x_del_task_level_rec_code_tbl.extend(p_task_rec_tbl.COUNT);

    IF p_task_rec_tbl.COUNT > 0 THEN

        l_task_rec_project_id_tbl.extend(p_task_rec_tbl.COUNT);
        l_task_rec_task_ver_id_tbl.extend(p_task_rec_tbl.COUNT);

        --Bug 4492493: Check if Progress Rollup is required on CREATION
        l_progress_rollup_required := Is_Progress_Rollup_Required(p_task_rec_tbl(1).project_id);
        -- End of Bug 4492493

        FOR k in 1..p_task_rec_tbl.COUNT LOOP

            -- IB2 Unplanned Actual changes
            -- Allow creation of unplanned transaction on published version
            IF p_task_assignment_tbl.COUNT > 0 AND p_task_assignment_tbl(1).unplanned_flag = 'Y' THEN
                l_edit_task_ok := 'Y';
            ELSE
                -- Bug 6856934
                if nvl(p_calling_context,'X') = 'PA_PROJECT_ASSIGNMENT' then
                        l_edit_task_ok := 'Y';
                else

                l_edit_task_ok := check_edit_task_ok(
                                      P_PROJECT_ID	     => p_task_rec_tbl(k).project_id,
                                      P_STRUCTURE_VERSION_ID	=> p_task_rec_tbl(k).struct_elem_version_id,
                                      P_CURR_STRUCT_VERSION_ID	=> p_task_rec_tbl(k).struct_elem_version_id);
                end if;
                -- Bug 6856934
            END IF;

            IF 'Y' = l_edit_task_ok THEN

                --get task info:
                OPEN C1_Task_Info(p_task_rec_tbl(k).task_elem_version_id);
                FETCH C1_Task_Info INTO l_task_sch_start, l_task_sch_end, l_task_name, l_task_number, l_task_proj_element_id;
                CLOSE C1_Task_Info;

                IF (p_task_rec_tbl(k).start_date is not null AND
                    p_task_rec_tbl(k).start_date <> FND_API.G_MISS_DATE  AND
                    p_task_rec_tbl(k).end_date is not null AND
                    p_task_rec_tbl(k).end_date <> FND_API.G_MISS_DATE) THEN

                    l_task_sch_start := p_task_rec_tbl(k).start_date;
                    l_task_sch_end :=  p_task_rec_tbl(k).end_date;

                END IF;

                --Initialize per task..
                l_people_count    := 0;
                l_equip_count     := 0;
                l_task_people_effort := 0;
                l_task_equip_effort  := 0;
                l_people_index := 1;
                l_equip_index := 1;

                IF p_task_assignment_tbl.COUNT > 0 AND x_return_status = FND_API.G_RET_STS_SUCCESS THEN

                    IF p_one_to_one_mapping_flag <> 'Y' THEN

                        FOR i in 1..p_task_assignment_tbl.COUNT LOOP

                            --0. Bug 4492493: Check if Progress Rollup is required on CREATION
                            IF g_require_progress_rollup = 'N' AND
                               l_progress_rollup_required = 'Y' AND
                               p_task_assignment_tbl(i).total_quantity IS NOT NULL AND
                               p_task_assignment_tbl(i).total_quantity <> FND_API.G_MISS_NUM THEN
                              g_require_progress_rollup := 'Y';
                            END IF;
                            -- End of Bug 4492493

                            --1. RESOURCE INFORMATION VALIDATION.
                            --Validate Financial Category:
                            --Get default Procure Resource in Resource Information:
                            If p_task_assignment_tbl(i).supplier_id IS NOT NULL THEN
                                p_task_assignment_tbl(i).procure_resource_flag := 'Y';
                            else
                                p_task_assignment_tbl(i).procure_resource_flag := 'N';
                            End If;

	    					IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                            pa_debug.g_err_stage:='TA: p_task_assignment_tbl(i).procure_resource_flag'||p_task_assignment_tbl(i).procure_resource_flag;
	                            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
							END IF;

                            --2. SCHEDULE INFORMATION VALIDATION
                            -- Bug 3793623
                            -- Should honor Scheduled Dates provided by user before
                            -- defaulting to task scheduled dates
                            -- Should also honor Planning Dates
                            IF p_task_assignment_tbl(i).schedule_start_date IS NOT NULL AND
                               p_task_assignment_tbl(i).schedule_start_date <> FND_API.G_MISS_DATE THEN

                                p_task_assignment_tbl(i).planning_start_date := p_task_assignment_tbl(i).schedule_start_date;

					        ELSIF p_task_assignment_tbl(i).planning_start_date IS NOT NULL AND
                                  p_task_assignment_tbl(i).planning_start_date <> FND_API.G_MISS_DATE THEN

                                p_task_assignment_tbl(i).schedule_start_date := p_task_assignment_tbl(i).planning_start_date;

                            ELSE

                                p_task_assignment_tbl(i).planning_start_date := l_task_sch_start;
                                p_task_assignment_tbl(i).schedule_start_date := l_task_sch_start;

                            END IF;

                            IF p_task_assignment_tbl(i).schedule_end_date IS NOT NULL AND
                               p_task_assignment_tbl(i).schedule_end_date <> FND_API.G_MISS_DATE THEN

                                p_task_assignment_tbl(i).planning_end_date := p_task_assignment_tbl(i).schedule_end_date;

                            ELSIF p_task_assignment_tbl(i).planning_end_date IS NOT NULL AND
                                  p_task_assignment_tbl(i).planning_end_date <> FND_API.G_MISS_DATE THEN

                                p_task_assignment_tbl(i).schedule_end_date := p_task_assignment_tbl(i).planning_end_date;

                            ELSE

                                p_task_assignment_tbl(i).planning_end_date := l_task_sch_end;
                                p_task_assignment_tbl(i).schedule_end_date := l_task_sch_end;

                            END IF;

                            --rbruno bug 9468665 - start
                            -- validate whether assignment same as task duration is checked at workplan level.
                            -- if the flag is checked at workplan level and the task and assignment dates
                            -- are not same, then set the flag to 'N' at assignment level during amg flow.
                            open c_use_task_schedule_flag(p_task_rec_tbl(k).project_id);
                            fetch c_use_task_schedule_flag into l_use_task_schedule_flag;
                            close c_use_task_schedule_flag;
                            if (l_use_task_schedule_flag = 'Y' )
             			               AND (trunc(p_task_assignment_tbl(i).schedule_start_date) <> trunc(l_task_sch_start) OR
		                                  trunc(p_task_assignment_tbl(i).schedule_end_date) <> trunc(l_task_sch_end)) THEN
                              p_task_assignment_tbl(i).use_task_schedule_flag := 'N';
                            end if;
                            -- rbruno bug 9468665 - end


                            -- Validate that assignment dates should be within task dates
                            IF trunc(p_task_assignment_tbl(i).schedule_start_date) < trunc(l_task_sch_start) OR
                               trunc(p_task_assignment_tbl(i).schedule_start_date) > trunc(l_task_sch_end) OR
                               trunc(p_task_assignment_tbl(i).schedule_end_date) < trunc(l_task_sch_start) OR
                               trunc(p_task_assignment_tbl(i).schedule_end_date) > trunc(l_task_sch_end) THEN

                                PA_UTILS.ADD_MESSAGE
                                    (p_app_short_name => 'PA',
                                     p_msg_name       => 'PA_PL_TXN_SCH_DATES_ERR',
                                     p_token1         => 'TASK_NAME',
                                     p_value1         =>  l_task_name,
                                     p_token2         => 'TASK_NUMBER',
                                     p_value2         =>  l_task_number,
                                     p_token3         => 'PL_RES_ALIAS',
                                     p_value3         =>  p_task_assignment_tbl(i).planning_resource_alias);
                                x_return_status := FND_API.G_RET_STS_ERROR;
                            END IF;
                            -- End of fix: Bug 3793623

							-- scheduled_delay must be positive or null
							IF nvl(p_task_assignment_tbl(i).scheduled_delay, 0) < 0 THEN

                                PA_UTILS.ADD_MESSAGE
                                (
									p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_SCHED_DELAY_ERR'
								);
                                x_return_status := FND_API.G_RET_STS_ERROR;
							END IF;

		                    -- Bug 3818133: Copy the assignment name in the named_role cell
		                    IF (p_task_assignment_tbl(i).project_assignment_id IS NOT NULL) AND
		                       (p_task_assignment_tbl(i).project_assignment_id <> FND_API.G_MISS_NUM) AND
		                       (p_task_assignment_tbl(i).project_assignment_id <> -1) THEN

		                    	OPEN C_Named_Role(p_task_assignment_tbl(i).project_assignment_id);
		                    	FETCH C_Named_Role INTO p_task_assignment_tbl(i).named_role, p_task_assignment_tbl(i).project_role_id;
		                    	CLOSE C_Named_Role;

                    		END IF;


                            -- Default this to 'N' always
                            -- rbruno commenting for bug 9468665
                            --p_task_assignment_tbl(i).use_task_schedule_flag := 'N';

                                    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                            pa_debug.g_err_stage:='TA: p_task_assignment_tbl(i).planning_start_date'||p_task_assignment_tbl(i).planning_start_date;
	                            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                            pa_debug.g_err_stage:='TA: p_task_assignment_tbl(i).planning_end_date'||p_task_assignment_tbl(i).planning_end_date;
	                            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                            pa_debug.g_err_stage:='TA: l_task_people_effort'||l_task_people_effort;
	                            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                            pa_debug.g_err_stage:='TA: l_task_equip_effort'||l_task_equip_effort;
	                            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                            pa_debug.g_err_stage:='TA: p_task_assignment_tbl(i).total_quantity'||p_task_assignment_tbl(i).total_quantity;
	                            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                            pa_debug.g_err_stage:='TA: p_task_assignment_tbl(i).use_task_schedule_flag'||p_task_assignment_tbl(i).use_task_schedule_flag;
	                            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
							END IF;

                        END LOOP;

                    ELSIF p_one_to_one_mapping_flag = 'Y' THEN

                        If p_task_assignment_tbl(k).supplier_id is not null THEN
                            p_task_assignment_tbl(k).procure_resource_flag := 'Y';
                        else
                            p_task_assignment_tbl(k).procure_resource_flag := 'N';
                        End If;

						IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                        pa_debug.g_err_stage:='TA: p_task_assignment_tbl(k).procure_resource_flag'||p_task_assignment_tbl(k).procure_resource_flag;
	                        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
						END IF;

                        --2. SCHEDULE INFORMATION VALIDATION
                        -- Bug 3793623
                        -- Should honor Scheduled Dates provided by user before
                        -- defaulting to task scheduled dates
                        -- Should also honor Planning Dates
                        IF p_task_assignment_tbl(k).schedule_start_date IS NOT NULL AND
                           p_task_assignment_tbl(k).schedule_start_date <> FND_API.G_MISS_DATE THEN

                            p_task_assignment_tbl(k).planning_start_date := p_task_assignment_tbl(k).schedule_start_date;

                        ELSIF p_task_assignment_tbl(k).planning_start_date IS NOT NULL AND
                              p_task_assignment_tbl(k).planning_start_date <> FND_API.G_MISS_DATE THEN

                            p_task_assignment_tbl(k).schedule_start_date := p_task_assignment_tbl(k).planning_start_date;

                        ELSE

                            p_task_assignment_tbl(k).planning_start_date := l_task_sch_start;
                            p_task_assignment_tbl(k).schedule_start_date := l_task_sch_start;

                        END IF;

                        IF p_task_assignment_tbl(k).schedule_end_date IS NOT NULL AND
                           p_task_assignment_tbl(k).schedule_end_date <> FND_API.G_MISS_DATE THEN

                            p_task_assignment_tbl(k).planning_end_date := p_task_assignment_tbl(k).schedule_end_date;

                        ELSIF p_task_assignment_tbl(k).planning_end_date IS NOT NULL AND
                              p_task_assignment_tbl(k).planning_end_date <> FND_API.G_MISS_DATE THEN

                            p_task_assignment_tbl(k).schedule_end_date := p_task_assignment_tbl(k).planning_end_date;

                        ELSE

                            p_task_assignment_tbl(k).planning_end_date := l_task_sch_end;
                            p_task_assignment_tbl(k).schedule_end_date := l_task_sch_end;

                        END IF;

                            -- rbruno bug 9468665 - start
                         -- validate whether assignment same as task duration is checked at workplan level.
                         -- if the flag is checked at workplan level and the task and assignment dates
                         -- are not same, then set the flag to 'N' at assignment level during amg flow.
                         open c_use_task_schedule_flag(p_task_rec_tbl(k).project_id);
                         fetch c_use_task_schedule_flag into l_use_task_schedule_flag;
                         close c_use_task_schedule_flag;
                         if (l_use_task_schedule_flag = 'Y' )
                            AND (trunc(p_task_assignment_tbl(k).schedule_start_date) <> trunc(l_task_sch_start) OR
                                 trunc(p_task_assignment_tbl(k).schedule_end_date) <> trunc(l_task_sch_end)) THEN
                           p_task_assignment_tbl(k).use_task_schedule_flag := 'N';
                         end if;
                         -- rbruno bug 9468665 - end


                        -- Validate that assignment dates should be within task dates
                        IF trunc(p_task_assignment_tbl(k).schedule_start_date) < trunc(l_task_sch_start) OR
                           trunc(p_task_assignment_tbl(k).schedule_start_date) > trunc(l_task_sch_end) OR
                           trunc(p_task_assignment_tbl(k).schedule_end_date) < trunc(l_task_sch_start) OR
                           trunc(p_task_assignment_tbl(k).schedule_end_date) > trunc(l_task_sch_end) THEN

                            PA_UTILS.ADD_MESSAGE
                                (p_app_short_name => 'PA',
                                 p_msg_name       => 'PA_PL_TXN_SCH_DATES_ERR',
                                 p_token1         => 'TASK_NAME',
                                 p_value1         =>  l_task_name,
                                 p_token2         => 'TASK_NUMBER',
                                 p_value2         =>  l_task_number,
                                 p_token3         => 'PL_RES_ALIAS',
                                 p_value3         =>  p_task_assignment_tbl(k).planning_resource_alias);
                            x_return_status := FND_API.G_RET_STS_ERROR;
                        END IF;
                        -- End of fix: Bug 3793623

			IF nvl(p_task_assignment_tbl(k).scheduled_delay, 0) < 0 THEN

                               PA_UTILS.ADD_MESSAGE
                               (   p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_SCHED_DELAY_ERR'
		               );
                               x_return_status := FND_API.G_RET_STS_ERROR;

			END IF;

		                -- Bug 3818133: Copy the assignment name in the named_role cell
		                IF (p_task_assignment_tbl(k).project_assignment_id IS NOT NULL) AND
		                   (p_task_assignment_tbl(k).project_assignment_id <> FND_API.G_MISS_NUM) AND
		                   (p_task_assignment_tbl(k).project_assignment_id <> -1) THEN

		                	OPEN C_Named_Role(p_task_assignment_tbl(k).project_assignment_id);
		                	FETCH C_Named_Role INTO p_task_assignment_tbl(k).named_role, p_task_assignment_tbl(k).project_role_id;
		                	CLOSE C_Named_Role;

		                END IF;

						IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                        pa_debug.g_err_stage:='TA: p_task_assignment_tbl(k).planning_start_date'||p_task_assignment_tbl(k).planning_start_date;
	                        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                        pa_debug.g_err_stage:='TA: p_task_assignment_tbl(k).planning_end_date'||p_task_assignment_tbl(k).planning_end_date;
	                        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                        pa_debug.g_err_stage:='TA: l_task_people_effort'||l_task_people_effort;
	                        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                        pa_debug.g_err_stage:='TA: l_task_equip_effort'||l_task_equip_effort;
	                        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                        pa_debug.g_err_stage:='TA: p_task_assignment_tbl(k).total_quantity'||p_task_assignment_tbl(k).total_quantity;
	                        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
						END IF;


                        --Get default 'Assignment same as Task Duration' flag:
                         -- rbruno commenting for bug 9468665
                        -- p_task_assignment_tbl(k).use_task_schedule_flag := 'N';


						IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                        pa_debug.g_err_stage:='TA: p_task_assignment_tbl(k).use_task_schedule_flag'||p_task_assignment_tbl(k).use_task_schedule_flag;
	                        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
						END IF;

                    END IF; -- p_one_to_one_mapping_flag = 'N'

                END IF; -- p_task_assignment_tbl.COUNT > 0 AND x_return_status = FND_API.G_RET_STS_SUCCESS


            ELSE -- check task edit ok

                -- Bug 4533152
                --PA_UTILS.ADD_MESSAGE
                --    (p_app_short_name => 'PA',
                --     p_msg_name       => 'PA_UPDATE_PUB_VER_ERR');
                x_return_status := FND_API.G_RET_STS_ERROR;

            END IF;

            -- Bug 3640647
            l_task_rec_project_id_tbl(k) := p_task_rec_tbl(k).project_id;
            l_task_rec_task_ver_id_tbl(k) := p_task_rec_tbl(k).task_elem_version_id;
            -- END of Bug 3640647

        END LOOP; -- FOR k in 1..p_task_rec_tbl.COUNT LOOP

        -- Bug 3640647
        -- 9/23/04: It was agreed by Sakthi, Angela and Kaushik that the system
        -- generated (ta_display_flag='N') assignment should be converted
        -- into a regular assignment as soon as the first assignment is created
        -- on the task version.
        -- 10/12/04: This is only allowed on the published version when unplanned
        --           assignment is created. Need to convert the progress record from
        --           PA_TASKS to PA_ASSIGNMENT.

	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	        pa_debug.g_err_stage:='Validate_Create_Assignment - Updating ta_display_flag to Y';
			pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
		END IF;

       -- 10/19/04: Discussed with Sakthi, Koushik and Ansari. We should not
       --  convert ta_display_flag from 'N' to 'Y' on published version
       --  when unplanned assignents are created.
        -- 5/12/05:  Discussed with Ansari, Saima and Koushik.  We need to convert
        --           hidden assignment to regular assignment even on published version
        --           upon creation of unplanned assignment.  Due to bug 4354041.

       IF l_task_rec_project_id_tbl.COUNT > 0 THEN
--          (p_task_assignment_tbl(1).unplanned_flag IS NULL OR
--           p_task_assignment_tbl(1).unplanned_flag = FND_API.G_MISS_CHAR OR
--           p_task_assignment_tbl(1).unplanned_flag <> 'Y') THEN

        FORALL k IN l_task_rec_project_id_tbl.FIRST .. l_task_rec_project_id_tbl.LAST
            UPDATE pa_resource_assignments
            SET ta_display_flag = 'Y',
                record_version_number = record_version_number + 1
            WHERE project_id = l_task_rec_project_id_tbl(k)
            AND wbs_element_version_id = l_task_rec_task_ver_id_tbl(k)
            AND ta_display_flag = 'N'
        RETURNING task_id, resource_list_member_id
         BULK COLLECT INTO l_progress_task_id, l_progress_rlm_id;
       END IF;

/* 10/14/04: Spoke with Ansari.  I will comment this out until after IB6.

       IF l_progress_task_id.COUNT > 0 AND
          p_task_assignment_tbl(1).unplanned_flag = 'Y' THEN

        FOR k IN l_progress_task_id.FIRST .. l_progress_task_id.LAST LOOP
          --dbms_output.put_line('rlm id:'||l_progress_rlm_id(k));
          --dbms_output.put_line('p_task_rec_tbl(1).project_id:'||p_task_rec_tbl(1).project_id);
          --dbms_output.put_line('l_progress_task_id(k):'||l_progress_task_id(k));
          --dbms_output.put_line('p_task_rec_tbl(1).struct_elem_version_id:'||p_task_rec_tbl(1).struct_elem_version_id);

         PA_PROGRESS_PVT.Convert_Task_Prog_To_Assgn(
             p_resource_list_mem_id => l_progress_rlm_id(k),
             p_project_id           => p_task_rec_tbl(1).project_id,
             p_task_id              => l_progress_task_id(k),
             p_structure_version_id => p_task_rec_tbl(1).struct_elem_version_id,
             x_return_status        => l_return_status,
             x_msg_count            => l_msg_count,
             x_msg_data             => l_msg_data
          );
          IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            x_return_status := l_return_status;
          END IF;

        END LOOP;
       END IF;
       -- END of Bug 3640647

 10/14/04: Spoke with Ansari.  I will comment this out until after IB6
*/


    END IF; -- IF p_task_rec_tbl.count > 0

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	    pa_debug.g_err_stage:='End of PA_TASK_ASSIGNMENT_UTILS.Validate_Create_Assignment';
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 5);
        END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        RAISE;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                                 p_procedure_name => L_FuncProc);
        RAISE;

END Validate_Create_Assignment;





-- This procedure will Validate the Update of Planning Transactions

PROCEDURE Validate_Update_Assignment
(
    p_calling_context        IN            VARCHAR2 DEFAULT NULL,  -- Added for Bug 6856934
    p_task_assignment_tbl    IN OUT NOCOPY l_resource_rec_tbl_type,
    x_return_status             OUT NOCOPY VARCHAR2
)

IS

l_task_sch_start DATE;
l_task_sch_end   DATE;
l_task_number    VARCHAR2(240);
l_task_name      VARCHAR2(240);
l_published_flag pa_proj_elem_ver_structure.latest_eff_published_flag%TYPE;
l_return_status VARCHAR2(1);
x_msg_data VARCHAR2(4000);
x_msg_count NUMBER;
l_wbs_element_version_id NUMBER;
l_struct_ver_id NUMBER;
l_project_id NUMBER;
l_budget_version_id NUMBER;
l_actual_start_date DATE;
l_actual_end_date DATE;
l_error_msg_code VARCHAR2(100);
l_task_assignment_rec resource_rec_type;
l_viol_indicator NUMBER;
l_P_Resource_List_Member_Id  l_task_assignment_rec.resource_list_member_id%TYPE;
l_P_Project_Role_Id	       l_task_assignment_rec.project_role_id%TYPE;
l_P_Organization_Id	       l_task_assignment_rec.organization_id%TYPE;
l_P_Supplier_Id		       l_task_assignment_rec.supplier_id%TYPE;
l_prog_finish_date  DATE;
l_progress_exists  VARCHAR2(1);
l_ta_display_flag VARCHAR2(1);
l_rlm_id NUMBER;
L_FuncProc varchar2(250) ;
l_valid_member_flag VARCHAR(1);
l_sp_fixed_date DATE;

CURSOR C1_Task_Dates(p_elem_version_id IN NUMBER) IS
    SELECT pevs.scheduled_start_date, pevs.scheduled_finish_date,
	       pe.name task_name, pe.element_number task_number
    FROM pa_proj_elem_ver_schedule pevs, pa_proj_element_versions pev,
	     pa_proj_elements pe
    WHERE pev.element_version_id = pevs.element_version_id
    AND pev.element_version_id = p_elem_version_id
	AND pev.proj_element_id = pe.proj_element_id;

CURSOR C2_Published_Flag(p_elem_version_id IN NUMBER) IS
    SELECT latest_eff_published_flag
    FROM pa_proj_elem_ver_structure pevs, pa_proj_element_versions pev
    WHERE pev.element_version_id = p_elem_version_id
    AND pev.parent_structure_version_id = pevs.element_version_id
    AND pev.project_id = pevs.project_id;

CURSOR C_Res_Assignment_Info(p_resource_assignment_id IN NUMBER) IS
    SELECT *
    FROM pa_resource_assignments
    WHERE resource_assignment_id = p_resource_assignment_id;

CURSOR C_Budget_Version_Info (p_resource_assignment_id IN NUMBER) IS
    SELECT budget_version_id
    FROM pa_resource_assignments
    WHERE resource_assignment_id = p_resource_assignment_id;

CURSOR C2_Task_Effort_Assignment(p_resource_assignment_id IN NUMBER) IS
    SELECT ra.ta_display_flag, ra.resource_list_member_id, ra.project_id, ra.task_id, bv.project_structure_version_id
    FROM pa_resource_assignments ra, pa_budget_versions bv
    WHERE ra.resource_assignment_id = p_resource_assignment_id
      AND ra.budget_version_id = bv.budget_version_id;

CURSOR C_Get_Actuals(p_resource_assignment_id IN NUMBER) IS
    SELECT actual_effort
    FROM pa_assgn_cost_effort_v
    WHERE resource_assignment_id = p_resource_assignment_id
	AND progress_rollup_id IS NOT NULL
    and rownum = 1;

CURSOR C_Get_Project_Id IS
    SELECT project_id
      FROM pa_resource_assignments
     WHERE resource_assignment_id = p_task_assignment_tbl(1).resource_assignment_id;

R_Res_Assignment_Rec C_Res_Assignment_Info%ROWTYPE;
l_proj_element_id NUMBER;
L_Incur_By_Resource_Type VARCHAR2(240);
l_P_named_role  VARCHAR2(80);

-- For Resource defaults
--Start of variables for Variable for Resource Attributes
lr_resource_class_flag_tbl         SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
lr_resource_class_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_resource_class_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_res_type_code_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_incur_by_res_type_tbl           SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_job_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_person_id_tbl                   SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_person_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_named_role_tbl                  SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
lr_bom_resource_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_non_labor_resource_tbl          SYSTEM.PA_VARCHAR2_20_TBL_TYPE    := SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
lr_inventory_item_id_tbl           SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_item_category_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_project_role_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_organization_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_fc_res_type_code_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_expenditure_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_expenditure_category_tbl        SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_event_type_tbl                  SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_revenue_category_code_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_supplier_id_tbl                 SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_unit_of_measure_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_spread_curve_id_tbl             SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_etc_method_code_tbl             SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_mfc_cost_type_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_procure_resource_flag_tbl       SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
lr_incurred_by_res_flag_tbl        SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
lr_Incur_by_res_class_code_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_Incur_by_role_id_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_org_id_tbl                      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_rate_based_flag_tbl             SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
lr_rate_expenditure_type_tbl       SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_rate_func_curr_code_tbl         SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_rate_incurred_by_org_id_tbl     SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_resource_assignment_id_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_assignment_description_tbl      SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
lr_planning_resource_alias_tbl     SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
lr_resource_name_tbl               SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_project_role_name_tbl           SYSTEM.PA_VARCHAR2_150_TBL_TYPE   := SYSTEM.PA_VARCHAR2_150_TBL_TYPE();
lr_organization_name_tbl           SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
lr_financial_category_code_tbl     SYSTEM.PA_VARCHAR2_80_TBL_TYPE    := SYSTEM.PA_VARCHAR2_80_TBL_TYPE();
lr_project_assignment_id_tbl       SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_use_task_schedule_flag_tbl      SYSTEM.PA_VARCHAR2_1_TBL_TYPE     := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
lr_planning_start_date_tbl         SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
lr_planning_end_date_tbl           SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
lr_total_quantity_tbl              SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_override_currency_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_billable_percent_tbl            SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_cost_rate_override_tbl          SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_burdened_rate_override_tbl      SYSTEM.PA_NUM_TBL_TYPE            := SYSTEM.PA_NUM_TBL_TYPE();
lr_sp_fixed_date_tbl               SYSTEM.PA_DATE_TBL_TYPE           := SYSTEM.PA_DATE_TBL_TYPE();
lr_financial_category_name_tbl     SYSTEM.PA_VARCHAR2_30_TBL_TYPE    := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
lr_supplier_name_tbl               SYSTEM.PA_VARCHAR2_240_TBL_TYPE   := SYSTEM.PA_VARCHAR2_240_TBL_TYPE();
--End of variables for Variable for Resource Attributes

  lr_eligible_rlm_id_tbl        SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();

  l_progress_project_id NUMBER;
  l_progress_task_id NUMBER;
  l_progress_struct_ver_id NUMBER;
  l_progress_rollup_required VARCHAR2(1) := 'N';
  l_msg_added_flag VARCHAR2(1) := 'N'; -- Fix for Bug # 4319137.

   -- 4537865
   l_new_resource_list_member_id NUMBER ;

  l_edit_task_ok VARCHAR2(1) := 'N'; -- Bug 6856934

BEGIN

    L_FuncProc := 'Validate_Update_Assignment';
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_require_progress_rollup := 'N'; -- End of Bug 4492493

    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	    pa_debug.g_err_stage:='Beginning of TA:Validate_Update_Assignment';
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

	l_msg_added_flag := 'N'; -- Fix for Bug # 4319137.


    --Bug 4492493: Check if Progress Rollup is required on UPDATE
    OPEN C_Get_Project_Id;
    FETCH C_Get_Project_Id INTO l_project_id;
    CLOSE C_Get_Project_Id;

    l_progress_rollup_required := Is_Progress_Rollup_Required(l_project_id);
    -- End of Bug 4492493

    FOR i in 1..p_task_assignment_tbl.COUNT LOOP

        -- Initialize the error indicator
        l_viol_indicator := null;

	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	        pa_debug.g_err_stage:='P_resource_assignment_id:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).resource_assignment_id;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_Planning_Resource_Alias:' ||  i || p_task_assignment_tbl(i).planning_resource_alias;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_resource_list_member_id:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).resource_list_member_id;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_resource_class_code:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).resource_class_code;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_res_type_code:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).res_type_code;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_resource_code:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).resource_code;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_resource_name:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).resource_name;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_project_role_id:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).project_role_id;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_project_role_name:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).project_role_name;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_organization_id:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).organization_id;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_organization_name:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).organization_name;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_FC_Res_Type_Code:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).fc_res_type_code;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_Fin_Category_Name:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).financial_category_name;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_Supplier_id:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).supplier_id;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_Supplier_name:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).supplier_name;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_INcur_By_Resource_Code:' ||   i   ||  ' :  ' ||  p_task_assignment_tbl(i).incur_by_resource_code;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_planning_start_date:' ||   i   ||  ' :  ' || p_task_assignment_tbl(i).planning_start_date;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_planning_end_date : ' ||   i   ||  ' :  ' || p_task_assignment_tbl(i).planning_end_date;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_schedule_start_date:' ||   i   ||  ' :  ' || p_task_assignment_tbl(i).schedule_start_date;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	        pa_debug.g_err_stage:='P_schedule_end_date : ' ||   i   ||  ' :  ' || p_task_assignment_tbl(i).schedule_end_date;
	        pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
		END IF;

        -- get old assignment data
        OPEN  C_Res_Assignment_Info(p_task_assignment_tbl(i).resource_assignment_id);
        FETCH C_Res_Assignment_Info INTO R_Res_Assignment_Rec;
        CLOSE C_Res_Assignment_Info;
        l_sp_fixed_date := NULL;


        -- Bug 4492493: Check if Progress Rollup is required on UPDATE
        IF g_require_progress_rollup = 'N' AND
           l_progress_rollup_required = 'Y' AND
           p_task_assignment_tbl(i).total_quantity IS NOT NULL AND
           (R_Res_Assignment_Rec.total_plan_quantity <> p_task_assignment_tbl(i).total_quantity OR
            R_Res_Assignment_Rec.total_plan_quantity IS NULL) THEN
          g_require_progress_rollup := 'Y';
        END IF;
        -- End of Bug 4492493

        -- Bug 3640647
        -- If the resource list member of a task effort assignment is changed
        -- toggle the ta_display_flag
        -- 10/12/04: Do not allow the rlm of the ta_display_flag = 'N' record to be
        --           updated if progress/actual exists on the published version
        OPEN C2_Task_Effort_Assignment(p_task_assignment_tbl(i).resource_assignment_id);
        FETCH C2_Task_Effort_Assignment INTO l_ta_display_flag, l_rlm_id, l_progress_project_id, l_progress_task_id, l_progress_struct_ver_id;
        CLOSE C2_Task_Effort_Assignment;

        l_progress_exists := 'N';

        IF l_rlm_id <> p_task_assignment_tbl(i).resource_list_member_id AND
           l_ta_display_flag = 'N' THEN

            UPDATE pa_resource_assignments
            SET ta_display_flag = 'Y'
            WHERE resource_assignment_id = p_task_assignment_tbl(i).resource_assignment_id;

        END IF; -- l_rlm_id <> p_task_assignment_tbl(i).resource_list_member_id
        -- END OF Bug 3640647


		l_wbs_element_version_id := R_Res_Assignment_Rec.wbs_element_version_id;

		BEGIN

			l_struct_ver_id := -99;
			l_project_id := -99;

	        SELECT parent_structure_version_id, project_id, proj_element_id
			INTO l_struct_ver_id, l_project_id, l_proj_element_id
            from pa_proj_element_versions
            where element_version_id = l_wbs_element_version_id;

        EXCEPTION
            WHEN NO_DATA_FOUND THEN
	            NULL;
		    WHEN OTHERS THEN
		        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END;

			-- Bug 6856934
			if nvl(p_calling_context,'X') = 'PA_PROJECT_ASSIGNMENT' then
			    l_edit_task_ok := 'Y';
			else

			    l_edit_task_ok := check_edit_task_ok(P_PROJECT_ID => l_project_id,
                             P_STRUCTURE_VERSION_ID   => l_struct_ver_id,
                             P_CURR_STRUCT_VERSION_ID => l_struct_ver_id);
			end if;
			-- Bug 6856934

			IF 'Y' = l_edit_task_ok then
			/*check_edit_task_ok(P_PROJECT_ID => l_project_id,
                           P_STRUCTURE_VERSION_ID   => l_struct_ver_id,
                           P_CURR_STRUCT_VERSION_ID => l_struct_ver_id) THEN Bug 6856934*/

			OPEN C1_Task_Dates(l_wbs_element_version_id);
	        FETCH C1_Task_Dates INTO l_task_sch_start, l_task_sch_end, l_task_name, l_task_number;
	        CLOSE C1_Task_Dates;

	    	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	            pa_debug.g_err_stage:='TA: alias:'||p_task_assignment_tbl(i).planning_resource_alias;
	            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	            pa_debug.g_err_stage:='TA: resource_list_member_id:'||p_task_assignment_tbl(i).resource_list_member_id;
	            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			END IF;

            L_Incur_By_Resource_Type := NULL;
            --reinitialize..
			Lr_eligible_rlm_id_tbl := SYSTEM.PA_NUM_TBL_TYPE();

            -- Added by clevesqu on 2004/09/08 for bug 3877543
			-- If the user re-select the same planning resource with via the planning resource LOV
			-- (e.g. when the user selects the same planning resource but picks one with a team role)
			-- Keep the attributes which have been defaulted.
			IF (p_task_assignment_tbl(i).resource_list_member_id = R_Res_Assignment_Rec.resource_list_member_id
				OR p_task_assignment_tbl(i).resource_list_member_id IS NULL) THEN

				p_task_assignment_tbl(i).organization_id := R_Res_Assignment_Rec.organization_id;
				p_task_assignment_tbl(i).expenditure_type := R_Res_Assignment_Rec.expenditure_type;
				p_task_assignment_tbl(i).person_type_code := R_Res_Assignment_Rec.person_type_code;
				p_task_assignment_tbl(i).job_id := R_Res_Assignment_Rec.job_id;

			END IF;
			-- End added by clevesqu on 2004/09/08 for bug 3877543

			IF (p_task_assignment_tbl(i).resource_list_member_id IS NOT NULL OR
			    p_task_assignment_tbl(i).planning_resource_alias IS NOT NULL) AND
			   (p_task_assignment_tbl(i).resource_list_member_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
				p_task_assignment_tbl(i).planning_resource_alias <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
			   (p_task_assignment_tbl(i).resource_list_member_id <> FND_API.G_MISS_NUM OR
				p_task_assignment_tbl(i).planning_resource_alias <> FND_API.G_MISS_CHAR) AND
			   nvl(p_task_assignment_tbl(i).resource_list_member_id, -99) <> nvl(R_Res_Assignment_Rec.resource_list_member_id, -99) THEN

				-- Added by clevesqu on 2004/09/03 for bug 3861936
				PA_PLANNING_RESOURCE_UTILS.check_list_member_on_list(
				    p_resource_list_id          => Get_WP_Resource_List_Id(l_project_id),
					p_resource_list_member_id   => p_task_assignment_tbl(i).resource_list_member_id,
					p_project_id                => l_project_id,
					p_alias                     => p_task_assignment_tbl(i).planning_resource_alias,
			-- 4537865 x_resource_list_member_id   => p_task_assignment_tbl(i).resource_list_member_id,
					x_resource_list_member_id => l_new_resource_list_member_id , -- 4537865
					x_valid_member_flag         => l_valid_member_flag,
					x_return_status             => x_return_status,
					x_msg_count                 => x_msg_count,
					x_msg_data                  => x_msg_data);
			IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

				p_task_assignment_tbl(i).resource_list_member_id := l_new_resource_list_member_id ;  -- 4537865
			END IF ;

				IF(x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF(x_return_status = FND_API.G_RET_STS_ERROR) THEN
				    RAISE  FND_API.G_EXC_ERROR;
				END IF;
				-- End added by clevesqu on 2004/09/03 for bug 3861936

				Lr_eligible_rlm_id_tbl.extend(1);
				Lr_eligible_rlm_id_tbl(1) := p_task_assignment_tbl(i).resource_list_member_id;

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:='About to call PA_PLANNING_RESOURCE_UTILS.get_resource_defaults w/ret.status='||x_return_status;
					pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

				PA_PLANNING_RESOURCE_UTILS.get_resource_defaults(
				    p_resource_list_members        =>  Lr_eligible_rlm_id_tbl,
				    p_project_id                   =>  l_project_id,
				    x_resource_class_flag          =>  lr_resource_class_flag_tbl,
				    x_resource_class_code          =>  lr_resource_class_code_tbl,
				    x_resource_class_id            =>  lr_resource_class_id_tbl,
				    x_res_type_code                =>  lr_res_type_code_tbl,
				    x_incur_by_res_type            =>  lr_incur_by_res_type_tbl,
				    x_person_id                    =>  lr_person_id_tbl,
				    x_job_id                       =>  lr_job_id_tbl,
				    x_person_type_code             =>  lr_person_type_code_tbl,
				    x_named_role                   =>  lr_named_role_tbl,
				    x_bom_resource_id              =>  lr_bom_resource_id_tbl,
				    x_non_labor_resource           =>  lr_non_labor_resource_tbl,
				    x_inventory_item_id            =>  lr_inventory_item_id_tbl,
				    x_item_category_id             =>  lr_item_category_id_tbl,
				    x_project_role_id              =>  lr_project_role_id_tbl,
				    x_organization_id              =>  lr_organization_id_tbl,
				    x_fc_res_type_code             =>  lr_fc_res_type_code_tbl,
				    x_expenditure_type             =>  lr_expenditure_type_tbl,
				    x_expenditure_category         =>  lr_expenditure_category_tbl,
				    x_event_type                   =>  lr_event_type_tbl,
				    x_revenue_category_code        =>  lr_revenue_category_code_tbl,
				    x_supplier_id                  =>  lr_supplier_id_tbl,
				    x_unit_of_measure              =>  lr_unit_of_measure_tbl,
				    x_spread_curve_id              =>  lr_spread_curve_id_tbl,
				    x_etc_method_code              =>  lr_etc_method_code_tbl,
				    x_mfc_cost_type_id             =>  lr_mfc_cost_type_id_tbl,
				    x_incurred_by_res_flag         =>  lr_incurred_by_res_flag_tbl,
				    x_incur_by_res_class_code      =>  lr_incur_by_res_class_code_tbl,
				    x_Incur_by_role_id             =>  lr_Incur_by_role_id_tbl,
			        x_org_id                       =>  lr_org_id_tbl,
				    X_rate_based_flag              =>  lr_rate_based_flag_tbl,
				    x_rate_expenditure_type        =>  lr_rate_expenditure_type_tbl,
				    x_rate_func_curr_code          =>  lr_rate_func_curr_code_tbl,
					x_msg_data                     =>  x_msg_data,
				    x_msg_count                    =>  x_msg_count,
				    x_return_status                =>  x_return_status);

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:='After PA_PLANNING_RESOURCE_UTILS.get_resource_defaults='||x_return_status;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Resource_List_Member_Id  => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).resource_list_member_id ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_resource_class_flag_tbl => ' ||  lr_resource_class_flag_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_resource_class_code_tbl => ' ||  lr_resource_class_code_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_resource_class_id_tbl => ' ||  lr_resource_class_id_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_res_type_code_tbl => ' ||  lr_res_type_code_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_incur_by_res_type_tbl => ' ||  lr_incur_by_res_type_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_person_id_tbl => ' ||  lr_person_id_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_person_type_code_tbl => ' ||  lr_person_type_code_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_named_role_tbl => ' ||  lr_named_role_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_bom_resource_id_tbl => ' ||  lr_bom_resource_id_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_non_labor_resource_tbl => ' ||  lr_non_labor_resource_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_inventory_item_id_tbl => ' ||  lr_inventory_item_id_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_item_category_id_tbl => ' ||  lr_item_category_id_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_project_role_id_tbl => ' ||  lr_project_role_id_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_organization_id_tbl => ' ||  lr_organization_id_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_fc_res_type_code_tbl => ' ||  lr_fc_res_type_code_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_expenditure_type_tbl => ' ||  lr_expenditure_type_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_event_type_tbl => ' ||  lr_event_type_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_revenue_category_code_tbl => ' ||  lr_revenue_category_code_tbl(1) ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_supplier_id            =>' ||  lr_supplier_id_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_unit_of_measure        =>' ||  lr_unit_of_measure_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_spread_curve_id        =>' ||  lr_spread_curve_id_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_etc_method_code        =>' ||  lr_etc_method_code_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_mfc_cost_type_id       =>' ||  lr_mfc_cost_type_id_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_incurred_by_res_flag   =>' ||  lr_incurred_by_res_flag_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_incur_by_res_class_code=>' ||  lr_incur_by_res_class_code_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_Incur_by_role_id       =>' ||  lr_Incur_by_role_id_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_org_id                 =>' ||  lr_org_id_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_rate_based_flag        =>' ||  lr_rate_based_flag_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_rate_expenditure_type  =>' ||  lr_rate_expenditure_type_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='x_rate_func_curr_code    =>' ||  lr_rate_func_curr_code_tbl(1);
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

				-- DHI Fix: override currency
				R_Res_Assignment_Rec.rate_based_flag := lr_rate_based_flag_tbl(1);

				IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
				    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
				ELSIF  (x_return_status = FND_API.G_RET_STS_ERROR) THEN
				    RAISE  FND_API.G_EXC_ERROR;
				END IF;

				P_task_assignment_tbl(i).resource_class_flag     := gchar(lr_resource_class_flag_tbl(1), 'B');
				P_task_assignment_tbl(i).resource_class_code     := gchar(lr_resource_class_code_tbl(1), 'B');
				P_task_assignment_tbl(i).resource_class_id       := gnum(lr_resource_class_id_tbl(1), 'B');
				P_task_assignment_tbl(i).res_type_code           := gchar(lr_res_type_code_tbl(1), 'B');
				P_task_assignment_tbl(i).incur_by_res_type       := gchar(lr_incur_by_res_type_tbl(1), 'B');
				P_task_assignment_tbl(i).Person_Id               := gnum(lr_Person_Id_tbl(1), 'B');
				P_task_assignment_tbl(i).Job_Id                  := gnum(lr_Job_Id_tbl(1), 'B');
				P_task_assignment_tbl(i).Person_Type_Code        := gchar(lr_Person_Type_Code_tbl(1), 'B');
				P_task_assignment_tbl(i).named_role              := NVL(gchar(p_task_assignment_tbl(i).named_role),gchar(lr_named_role_tbl(1), 'B'));
				P_task_assignment_tbl(i).bom_resource_id         := gnum(lr_bom_resource_id_tbl(1), 'B');
				P_task_assignment_tbl(i).non_labor_resource      := gchar(lr_non_labor_resource_tbl(1), 'B');
				P_task_assignment_tbl(i).inventory_item_id       := gnum(lr_inventory_item_id_tbl(1), 'B');
				P_task_assignment_tbl(i).item_category_id        := gnum(lr_item_category_id_tbl(1), 'B');
				P_task_assignment_tbl(i).project_role_id         := gnum(lr_project_role_id_tbl(1), 'B');
				P_task_assignment_tbl(i).organization_id         := gnum(lr_organization_id_tbl(1), 'B');
				P_task_assignment_tbl(i).fc_res_type_code        := gchar(lr_fc_res_type_code_tbl(1), 'B');
				P_task_assignment_tbl(i).expenditure_type        := gchar(lr_expenditure_type_tbl(1), 'B');
				P_task_assignment_tbl(i).expenditure_category    := gchar(lr_expenditure_category_tbl(1),'B');
				P_task_assignment_tbl(i).event_type              := gchar(lr_event_type_tbl(1), 'B');
				P_task_assignment_tbl(i).revenue_category_code   := gchar(lr_revenue_category_code_tbl(1), 'B');
				P_task_assignment_tbl(i).supplier_id             := gnum(lr_supplier_id_tbl(1), 'B');
				P_task_assignment_tbl(i).unit_of_measure         := gchar(lr_unit_of_measure_tbl(1), 'B');
				P_task_assignment_tbl(i).spread_curve_id         := gnum(lr_spread_curve_id_tbl(1), 'B');
				P_task_assignment_tbl(i).etc_method_code         := gchar(lr_etc_method_code_tbl(1), 'B');
				P_task_assignment_tbl(i).mfc_cost_type_id        := gnum(lr_mfc_cost_type_id_tbl(1), 'B');
				P_task_assignment_tbl(i).incurred_by_res_flag    := gchar(lr_incurred_by_res_flag_tbl(1), 'B');
				P_task_assignment_tbl(i).incur_by_res_class_code := gchar(lr_incur_by_res_class_code_tbl(1), 'B');
				P_task_assignment_tbl(i).Incur_by_role_id        := gnum(lr_Incur_by_role_id_tbl(1), 'B');
				P_task_assignment_tbl(i).org_id                  := gnum(lr_org_id_tbl(1), 'B');
				P_task_assignment_tbl(i).rate_based_flag         := gchar(lr_rate_based_flag_tbl(1), 'B');
				P_task_assignment_tbl(i).rate_expenditure_type   := gchar(lr_rate_expenditure_type_tbl(1), 'B');
				P_task_assignment_tbl(i).rate_func_curr_code     := gchar(lr_rate_func_curr_code_tbl(1), 'B');

            ELSIF p_task_assignment_tbl(i).resource_list_member_id is not Null Then

				--1. Resource Information
                IF (p_task_assignment_tbl(i).incur_by_resource_code IS NOT NULL AND
                    p_task_assignment_tbl(i).incur_by_resource_code <> FND_API.G_MISS_CHAR)
                   OR
                   (p_task_assignment_tbl(i).incur_by_resource_name IS NOT NULL AND
                    p_task_assignment_tbl(i).incur_by_resource_name <> FND_API.G_MISS_CHAR) THEN

			        L_Incur_By_Resource_Type	:= gchar(p_task_assignment_tbl(i).res_type_code);

		        END IF;

        		l_P_Resource_List_Member_Id := gnum(p_task_assignment_tbl(i).resource_list_member_id);
        		l_P_Project_Role_Id	        := gnum(p_task_assignment_tbl(i).project_role_id);
        		l_P_Organization_Id	        := gnum(p_task_assignment_tbl(i).organization_id);
        		l_P_Supplier_Id		        := gnum(p_task_assignment_tbl(i).supplier_id);
                l_P_named_role              := gchar(p_task_assignment_tbl(i).named_role);

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:='Before validate_planning_resource call in task assignment utils, return status='||x_return_status;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

				PA_PLANNING_RESOURCE_UTILS.Validate_Planning_Resource(
        		    P_Task_Name		           => l_task_name,
        		    P_Task_Number		       => l_task_number,
        		    P_Planning_Resource_Alias  => gchar(p_task_assignment_tbl(i).planning_resource_alias),
        		    P_Resource_List_Member_Id  => l_p_resource_list_member_id,
        		    P_Res_Format_Id		       => null,
        		    P_Resource_Class_Code      => gchar(p_task_assignment_tbl(i).resource_class_code),
        		    P_Res_Type_Code		       => gchar(p_task_assignment_tbl(i).res_type_code),
        		    P_Resource_Code		       => gchar(p_task_assignment_tbl(i).resource_code),
        		    P_Resource_Name		       => gchar(p_task_assignment_tbl(i).resource_name),
        		    P_Project_Role_Id	       => l_p_project_role_id,
        		    P_Project_Role_Name	       => gchar(p_task_assignment_tbl(i).project_role_name),
				    P_Team_Role     	       => l_p_named_role,
        		    P_Organization_Id	       => l_p_organization_id,
        		    P_Organization_Name	       => gchar(p_task_assignment_tbl(i).organization_name),
        		    P_FC_Res_Type_Code	       => gchar(p_task_assignment_tbl(i).fc_res_type_code),
        		    P_Fin_Category_Name	       => gchar(p_task_assignment_tbl(i).financial_category_name),
        		    P_Supplier_Id		       => l_p_supplier_id,
        		    P_Supplier_Name		       => gchar(p_task_assignment_tbl(i).supplier_name),
        		    P_Incur_By_Resource_Code   => gchar(p_task_assignment_tbl(i).incur_by_resource_code),
        		    P_Incur_By_Resource_Type   => L_Incur_By_Resource_Type,
        		    X_Resource_List_Member_Id  => P_task_assignment_tbl(i).Resource_List_Member_Id,
        		    X_Person_Id		           => P_task_assignment_tbl(i).Person_Id,
        		    X_Bom_Resource_Id	       => P_task_assignment_tbl(i).Bom_Resource_Id,
        		    X_Job_Id		           => P_task_assignment_tbl(i).Job_Id,
        		    X_Person_Type_Code	       => P_task_assignment_tbl(i).Person_Type_Code,
        		    X_Non_Labor_Resource       => P_task_assignment_tbl(i).Non_Labor_Resource ,
        		    X_Inventory_Item_Id	       => P_task_assignment_tbl(i).Inventory_Item_Id,
        		    X_Item_Category_Id	       => P_task_assignment_tbl(i).item_category_id,
        		    X_Project_Role_Id	       => P_task_assignment_tbl(i).project_role_id,
				    X_Team_Role     	       => p_task_assignment_tbl(i).named_role,
        	    	X_Organization_Id	       => P_task_assignment_tbl(i).organization_id,
        	    	X_Expenditure_Type	       => P_task_assignment_tbl(i).expenditure_type,
        	    	X_Expenditure_Category	   => P_task_assignment_tbl(i).expenditure_category,
        	    	X_Event_Type		       => P_task_assignment_tbl(i).event_type,
        	    	X_Revenue_Category_Code	   => P_task_assignment_tbl(i).revenue_category_code,
        	    	X_Supplier_Id		       => P_task_assignment_tbl(i).supplier_id,
        	    	X_Resource_Class_Id	       => P_task_assignment_tbl(i).resource_class_id,
        	    	X_Incur_By_Role_Id	       => P_task_assignment_tbl(i).incur_by_role_id,
        	    	X_Incur_By_Res_Class_Code  => P_task_assignment_tbl(i).incur_by_res_class_code,
        	    	X_Incur_By_Res_Flag	       => P_task_assignment_tbl(i).incurred_by_res_flag,
          	    	X_Resource_Class_Flag      => P_task_assignment_tbl(i).resource_class_flag,
        	    	X_Return_Status		       => x_return_status,
        	    	X_Msg_Data		           => x_msg_data,
        	    	X_Msg_Count		           => x_msg_count);

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:='After validate_planning_resource, return status='||x_return_status;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

                IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                    RAISE FND_API.G_EXC_ERROR;
	          	ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

				P_task_assignment_tbl(i).expenditure_type := NULL; --nvl(P_task_assignment_tbl(i).expenditure_type, FND_API.G_MISS_CHAR);
				P_task_assignment_tbl(i).expenditure_category := NULL; --nvl(P_task_assignment_tbl(i).expenditure_category,FND_API.G_MISS_CHAR);
	        	P_task_assignment_tbl(i).event_type := NULL; --nvl(P_task_assignment_tbl(i).event_type, FND_API.G_MISS_CHAR);
	        	P_task_assignment_tbl(i).revenue_category_code := NULL; --nvl(P_task_assignment_tbl(i).revenue_category_code, FND_API.G_MISS_CHAR);
	            P_task_assignment_tbl(i).fc_res_type_code := NULL; --nvl(p_task_assignment_tbl(i).fc_res_type_code, FND_API.G_MISS_CHAR);
				P_task_assignment_tbl(i).incur_by_role_id := NULL; --nvl(P_task_assignment_tbl(i).incur_by_role_id, FND_API.G_MISS_NUM);
	        	P_task_assignment_tbl(i).incur_by_res_class_code := NULL; --nvl(P_task_assignment_tbl(i).incur_by_res_class_code, FND_API.G_MISS_CHAR);

				-- Setting to null for bug 3664052
				P_task_assignment_tbl(i).Person_Id := NULL;
				P_task_assignment_tbl(i).Bom_Resource_Id := NULL;
				P_task_assignment_tbl(i).Job_Id := NULL;
				P_task_assignment_tbl(i).Person_Type_Code := NULL;
				P_task_assignment_tbl(i).Non_Labor_Resource := NULL;
				P_task_assignment_tbl(i).Inventory_Item_Id := NULL;
				P_task_assignment_tbl(i).Item_Category_Id := NULL;

	            -- Distinguishing new output params that are converted. 5/24/04
	        	P_task_assignment_tbl(i).project_role_id := gnum(P_task_assignment_tbl(i).project_role_id, 'B');
				p_task_assignment_tbl(i).named_role := gchar(p_task_assignment_tbl(i).named_role, 'B');

	        	P_task_assignment_tbl(i).organization_id := NULL; --gnum(P_task_assignment_tbl(i).organization_id, 'B');
	        	P_task_assignment_tbl(i).supplier_id := NULL; --gnum(P_task_assignment_tbl(i).supplier_id, 'B');
	        	P_task_assignment_tbl(i).resource_class_id := NULL; --gnum(P_task_assignment_tbl(i).resource_class_id, 'B');
	        	P_task_assignment_tbl(i).incur_by_role_id := NULL; --gnum(P_task_assignment_tbl(i).incur_by_role_id, 'B');
	            P_task_assignment_tbl(i).incur_by_res_class_code := NULL; --gchar(P_task_assignment_tbl(i).incur_by_res_class_code, 'B');
	            P_task_assignment_tbl(i).incurred_by_res_flag := NULL; --gchar(P_task_assignment_tbl(i).incurred_by_res_flag, 'B');
	          	P_task_assignment_tbl(i).resource_class_flag := NULL; --gchar(P_task_assignment_tbl(i).resource_class_flag, 'B');

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:='X_Resource_List_Member_Id  => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).resource_list_member_id ;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Person_Id		           => ' ||    i    ||   ' : ' ||   p_task_assignment_tbl(i).person_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Bom_Resource_Id	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).bom_resource_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Job_Id		           => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).job_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Person_Type_Code	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).person_type_code;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Non_Labor_Resource       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).non_labor_resource;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Inventory_Item_Id	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).inventory_item_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Item_Category_Id	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).item_category_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Project_Role_Id	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).project_role_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Organization_Id	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).organization_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Expenditure_Type	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).expenditure_type;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Expenditure_Category	   => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).expenditure_category;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Event_Type		       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).event_type;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Revenue_Category_Code	   => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).revenue_category_code;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Supplier_Id		       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).supplier_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Resource_Class_Id	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).resource_class_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Incur_By_Role_Id	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).incur_by_role_id;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Incur_By_Res_Class_Code  => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).incur_by_res_class_code;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Incur_By_Res_Flag	       => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).incurred_by_res_flag;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Resource_Class_Flag      => ' ||    i    ||   ' : ' ||  p_task_assignment_tbl(i).resource_class_flag;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='X_Return_Status		       => ' ||    i    ||   ' : ' ||  x_return_status;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

	        END IF;

			IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	            pa_debug.g_err_stage:='B4 Validate Fin Cat for WP: ' || L_FuncProc || ':return_status:' || x_return_status;
	            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			END IF;

		    IF Validate_Fin_Cat_For_WP(p_task_assignment_tbl(i).fc_res_type_code ) <> 'Y' THEN
			    x_return_status := FND_API.G_RET_STS_ERROR;
	        END IF;

			IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	            pa_debug.g_err_stage:='B4 Validate Pl_Res_For_WP: ' || L_FuncProc || ':return_status:' || x_return_status;
	            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			END IF;

		    IF Validate_Pl_Res_For_WP(p_task_assignment_tbl(i).resource_list_member_id) <> 'Y' THEN
			    x_return_status := FND_API.G_RET_STS_ERROR;
	        END IF;

			IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	            pa_debug.g_err_stage:='After Validate Pl_Res_For_WP: ' || L_FuncProc || ':return_status:' || x_return_status;
	            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			END IF;

            --2. Schedule Information
            --Validate the assignment Scheduled Dates:
            --first, if use_task_schedule_flag is set to Y, then assignment dates must be the same as task dates

            -- IB2 Unplanned Actual changes
            -- Replaced planning_start/end_date with schedule_start/end_date
            IF p_task_assignment_tbl(i).schedule_start_date IS NOT NULL OR
               p_task_assignment_tbl(i).schedule_end_date IS NOT NULL THEN

                IF p_task_assignment_tbl(i).schedule_start_date IS NULL THEN
                  p_task_assignment_tbl(i).schedule_start_date := R_Res_Assignment_Rec.schedule_start_date;
                ELSIF p_task_assignment_tbl(i).schedule_end_date IS NULL THEN
                  p_task_assignment_tbl(i).schedule_end_date := R_Res_Assignment_Rec.schedule_end_date;
                END IF;

                IF p_task_assignment_tbl(i).use_task_schedule_flag IS NULL THEN
                   p_task_assignment_tbl(i).use_task_schedule_flag := R_Res_Assignment_Rec.use_task_schedule_flag;
                END IF;



                -- Bug 4339939: Check if schedule start is greater than schedule end date
                IF p_task_assignment_tbl(i).schedule_start_date > p_task_assignment_tbl(i).schedule_end_date THEN

		   PA_UTILS.ADD_MESSAGE
                    (
			p_app_short_name => 'PA',
                        p_msg_name       => 'PA_PL_TXN_DATES_ERR',
                        p_token1         => 'TASK_NAME',
                        p_value1         =>  l_task_name,
                        p_token2         => 'TASK_NUMBER',
                        p_value2         =>  l_task_number,
                        p_token3         => 'PL_RES_ALIAS',
                        p_value3         =>  p_task_assignment_tbl(i).planning_resource_alias
                    );
                    x_return_status := FND_API.G_RET_STS_ERROR;

                -- CASE 1: If use_task_schedule_flag is set, make sure task and ta schedule
                -- dates are the same
               -- rbruno modified for bug 9468665 - start
                -- if use_task_schedule_flag is set and task and ta schedule dates are not
                -- same, then reset use_task_schedule_flag to 'N'

                ELSIF ((p_task_assignment_tbl(i).use_task_schedule_flag = 'Y')
			        AND (trunc(p_task_assignment_tbl(i).schedule_start_date) <> trunc(l_task_sch_start) OR
		                 trunc(p_task_assignment_tbl(i).schedule_end_date) <> trunc(l_task_sch_end))) THEN
                    p_task_assignment_tbl(i).use_task_schedule_flag := 'N';
                  -- rbruno modified for bug 9468665 - end
                -- CASE2: otherwise if use_task_schedule_flag is not set,
                -- then assignment dates should be within task dates
                ELSIF trunc(p_task_assignment_tbl(i).schedule_start_date) < trunc(l_task_sch_start) OR
                      trunc(p_task_assignment_tbl(i).schedule_start_date) > trunc(l_task_sch_end) OR
                      trunc(p_task_assignment_tbl(i).schedule_end_date) < trunc(l_task_sch_start) OR
                      trunc(p_task_assignment_tbl(i).schedule_end_date) > trunc(l_task_sch_end) THEN

                    PA_UTILS.ADD_MESSAGE
                    (
					    p_app_short_name => 'PA',
                        p_msg_name       => 'PA_PL_TXN_SCH_DATES_ERR',
                        p_token1         => 'TASK_NAME',
                        p_value1         =>  l_task_name,
                        p_token2         => 'TASK_NUMBER',
                        p_value2         =>  l_task_number,
                        p_token3         => 'PL_RES_ALIAS',
                        p_value3         =>  p_task_assignment_tbl(i).planning_resource_alias
                    );
                    x_return_status := FND_API.G_RET_STS_ERROR;

                END IF;

				-- scheduled_delay must be positive or null
				IF nvl(p_task_assignment_tbl(i).scheduled_delay, 0) < 0 THEN

					PA_UTILS.ADD_MESSAGE
					(
						p_app_short_name => 'PA',
						p_msg_name       => 'PA_SCHED_DELAY_ERR'
					);
					x_return_status := FND_API.G_RET_STS_ERROR;
				END IF;

                -- CASE3: IB2 Unplanned Actual changes
                -- Set planning dates to schedule dates
                -- Bug 3676062
                OPEN C_Budget_Version_Info (p_task_assignment_tbl(i).resource_assignment_id);
                FETCH C_Budget_Version_Info INTO l_budget_version_id;
                CLOSE C_Budget_Version_Info;

                PA_FIN_PLAN_UTILS2.get_blactual_dates
                (
		    	 	p_budget_version_id       => l_budget_version_id,
                    p_resource_assignment_id  => p_task_assignment_tbl(i).resource_assignment_id,
                    x_bl_actual_start_date    => l_actual_start_date,
                    x_bl_actual_end_date      => l_actual_end_date,
                    x_return_status           => l_return_status,
                    x_error_msg_code          => l_error_msg_code
                );

                IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		   x_return_status := l_return_status;
		END IF;

		IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                pa_debug.g_err_stage:='l_actual_start_date => ' || l_actual_start_date;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='l_actual_end_date => ' || l_actual_end_date;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='schedule_start_date => ' || p_task_assignment_tbl(i).schedule_start_date;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	                pa_debug.g_err_stage:='schedule_end_date => ' || p_task_assignment_tbl(i).schedule_end_date;
	                pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

                IF (l_actual_start_date IS NULL) OR (p_task_assignment_tbl(i).schedule_start_date <= l_actual_start_date) THEN
                    p_task_assignment_tbl(i).planning_start_date := p_task_assignment_tbl(i).schedule_start_date;
                ELSE
                    p_task_assignment_tbl(i).planning_start_date := R_Res_Assignment_Rec.planning_start_date;
                END IF;

                IF (l_actual_end_date IS NULL) OR (p_task_assignment_tbl(i).schedule_end_date >= l_actual_end_date) THEN
                    p_task_assignment_tbl(i).planning_end_date := p_task_assignment_tbl(i).schedule_end_date;
                ELSE
                    p_task_assignment_tbl(i).planning_end_date := R_Res_Assignment_Rec.planning_end_date;
                END IF;

                -- Shift sp_fixed_date accordingly if it is in Adjust
                -- Adjust Date flow
                -- new sp_fixed_date = min(old sp_fixed_date +(new planning
                -- start date - old planning start date), new planning end date)
				-- 10/14/04 Kaushik: Fixed Date should be shifted regardless of
                --   the flow.
                l_sp_fixed_date := p_task_assignment_tbl(i).sp_fixed_date;

                IF (l_sp_fixed_date is NULL OR
                    l_sp_fixed_date = FND_API.G_MISS_DATE) THEN
                    l_sp_fixed_date := R_Res_Assignment_Rec.sp_fixed_date;
                END IF;

                IF l_sp_fixed_date is not NULL AND
                   l_sp_fixed_date <> FND_API.G_MISS_DATE AND
                   (l_sp_fixed_date > p_task_assignment_tbl(i).planning_end_date OR
                    l_sp_fixed_date < p_task_assignment_tbl(i).planning_start_date) THEN

                    p_task_assignment_tbl(i).sp_fixed_date := R_Res_Assignment_Rec.sp_fixed_date +
                        (p_task_assignment_tbl(i).planning_start_date - R_Res_Assignment_Rec.planning_start_date);

                    IF p_task_assignment_tbl(i).sp_fixed_date > p_task_assignment_tbl(i).planning_end_date THEN
                        p_task_assignment_tbl(i).sp_fixed_date := p_task_assignment_tbl(i).planning_end_date;
                    ELSIF p_task_assignment_tbl(i).sp_fixed_date < p_task_assignment_tbl(i).planning_start_date THEN
                        p_task_assignment_tbl(i).sp_fixed_date := p_task_assignment_tbl(i).planning_start_date;

                    END IF;

                END IF; -- IF (l_sp_fixed_date is not NULL..

            END IF; -- p_task_assignment_tbl(i).schedule_*_date IS NOT NULL

            --Validate default Spread Curve - handled by the generic create planning transaction API.

            -- DHI Fix
            -- If no progress and no published version exists, override currency is only allowed
            -- if override rate also exists for rate based assignments
		    IF (R_Res_Assignment_Rec.rate_based_flag = 'Y' AND
			    p_task_assignment_tbl(i).override_currency_code <> FND_API.G_MISS_CHAR AND
				p_task_assignment_tbl(i).override_currency_code IS NOT NULL AND
				(p_task_assignment_tbl(i).cost_rate_override = FND_API.G_MISS_NUM OR
				 p_task_assignment_tbl(i).cost_rate_override IS NULL)) THEN

                l_viol_indicator := 8.7;

			END IF;

			IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
				pa_debug.g_err_stage:='After Progress violation checks: l_viol_indicator' || l_viol_indicator;
	            pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			END IF;

       	    IF l_viol_indicator is not null THEN
                -- override currency must goes with override raw cost rate for rate-based asgmts
                IF (l_viol_indicator = 8.7) THEN
                    PA_UTILS.ADD_MESSAGE
                    (
					    p_app_short_name => 'PA',
                        p_msg_name       => 'PA_UP_TA_OVR_CUR_ERR'
    				);
                    x_return_status := FND_API.G_RET_STS_ERROR;
	    	END IF;
	    END IF;

        --4. Financial Summary Validation handled by generic update planning transaction API
        ELSE -- check task edit ok

            -- Bug 4533152
            --PA_UTILS.ADD_MESSAGE
            --(
	    --	p_app_short_name => 'PA',
            --    p_msg_name       => 'PA_UPDATE_PUB_VER_ERR'
	    --);
            x_return_status := FND_API.G_RET_STS_ERROR;
        END IF;

	-- Begin fix for Bug # 4319137.

	if (x_return_status = FND_API.G_RET_STS_ERROR) then

		l_msg_added_flag := 'Y';

	end if;

        -- End fix for Bug # 4319137.

    END LOOP;


        -- Begin fix for Bug # 4319137.

	if (l_msg_added_flag = 'Y') then

		x_return_status := FND_API.G_RET_STS_ERROR;
	end if;

        -- End fix for Bug # 4319137.

    -- Finally, check the progress business rules.
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
    	PA_PROGRESS_UTILS.check_prog_for_update_asgmts
	    (
		    p_task_assignment_tbl => p_task_assignment_tbl,
		    x_return_status => x_return_status
	    );
    END IF;

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	    pa_debug.g_err_stage:='End of TA:Validate_Update_Assignment';
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 5);

        END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        RAISE;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                                 p_procedure_name => L_FuncProc);
        RAISE;

END Validate_Update_Assignment;





-- This procedure will Validate the Deletion of Planning Transactions
-- and return Assignments that can be deleted.

-- Case 1: Delete tasks
-- p_context = 'WORKPLAN' and p_task_or_res = 'TASKS'
-- p_elem_ver_id_tbl is required = all task versions to be delete
-- returns x_delete_task_flag_tbl which indicate whether all assignment
-- under the task can be deleted or not.

-- Case 2: Create subtask and delete parent task's task effort assignment
-- p_context = 'WORKPLAN' and p_task_or_res = 'ASSIGNMENT'
-- p_resource_assignment_id_tbl is required = ta_display_flag = 'N' records
-- for the given task versions
-- returns x_delete_asgmt_flag_tbl which indicate whether the given
-- assignments can be deleted

-- Case 3: Delete selected task assignments
-- p_context = 'TASK_ASSIGNMENT' and p_task_or_res = 'ASSIGNMENT'
-- p_resource_assignment_id_tbl is required = select assignments
-- returns x_delete_asgmt_flag_tbl which indicate whether the given
-- assignments can be deleted

--Bug 4951422. Added the OUT parameter x_task_assmt_ids_tbl. This tbl will be populated
--when p_task_or_res parameter is TASKS and p_context is WORKPLAN. This table will contain
--the resource assignment ids that are eligible for deletion so that delete_planning_transactions
--uses these ids instead of element_version_ids for deleting data

PROCEDURE Validate_Delete_Assignment
(
    p_context                    IN   VARCHAR2,
    p_calling_context            IN   VARCHAR2 DEFAULT NULL,   -- Added for Bug 6856934
    p_task_or_res                IN   VARCHAR2 DEFAULT 'ASSIGNMENT',
    p_elem_ver_id_tbl            IN   SYSTEM.PA_NUM_TBL_TYPE,
    p_task_name_tbl              IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE,
    p_task_number_tbl            IN   SYSTEM.PA_VARCHAR2_240_TBL_TYPE,
    p_resource_assignment_id_tbl IN   SYSTEM.PA_NUM_TBL_TYPE,
    x_delete_task_flag_tbl       OUT  NOCOPY SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
    x_delete_asgmt_flag_tbl      OUT  NOCOPY SYSTEM.PA_VARCHAR2_1_TBL_TYPE,
    x_task_assmt_ids_tbl         OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE, --Bug 4951422
    x_return_status              OUT  NOCOPY VARCHAR2
)

IS

L_FuncProc varchar2(250) ;

CURSOR C_Element_Info(p_wbs_element_version_id IN NUMBER) IS
    SELECT pev.project_id, pev.parent_structure_version_id, pev.proj_element_id, pe.name, pe.element_number
    FROM  pa_proj_element_versions pev, pa_proj_elements pe
    WHERE pev.element_version_id = p_wbs_element_version_id AND pe.proj_element_id = pev.proj_element_id;

CURSOR C_Element_Info2(p_resource_assignment_id IN NUMBER) IS
    SELECT ra.wbs_element_version_id, ra.project_id, pev.proj_element_id, ra.resource_list_member_id, ra.ta_display_flag, ra.task_id, ra.unplanned_flag, ra.total_plan_quantity
    FROM pa_resource_assignments ra, pa_proj_element_versions pev
    WHERE resource_assignment_id = p_resource_assignment_id
	and pev.element_version_id = ra.wbs_element_version_id;

CURSOR C_Task_Asgmts(p_element_version_id IN NUMBER) IS
    SELECT resource_assignment_id
    FROM pa_resource_assignments
    WHERE wbs_element_version_id = p_element_version_id;

-- Bug 4492493: Check if Progress Rollup is required on DELETION
CURSOR C_Planned_Effort_Exists(p_element_version_id IN NUMBER) IS
    SELECT 'Y'
      FROM pa_resource_assignments
     WHERE wbs_element_version_id = p_element_version_id
       AND total_plan_quantity > 0
       AND rownum = 1;

CURSOR C_Asgmt_Planned_Effort_Exists(p_resource_assignment_id IN NUMBER) IS
    SELECT 'Y'
      FROM pa_resource_assignments
     WHERE resource_assignment_id = p_resource_assignment_id
       AND total_plan_quantity > 0;

CURSOR C_Task_Get_Project_Id(p_elem_version_id IN NUMBER) IS
    SELECT project_id
      FROM pa_proj_element_versions
     WHERE element_version_id = p_elem_version_id;

CURSOR C_Asgmt_Get_Project_Id(p_resource_assignment_id IN NUMBER) IS
    SELECT project_id
      FROM pa_resource_assignments
     WHERE resource_assignment_id = p_resource_assignment_id;

-- End of Bug 4492493

l_task_asgmts_tbl SYSTEM.PA_NUM_TBL_TYPE;
l_struct_ver_id NUMBER;
l_project_id NUMBER;
l_wbs_element_version_id NUMBER;
l_planning_resource_alias VARCHAR2(240);
l_proj_element_id NUMBER;
l_progress_exists VARCHAR2(1);
l_rlm_id NUMBER;
l_structure_version_id NUMBER;
l_return_status VARCHAR2(1);
l_msg_data VARCHAR2(4000);
l_msg_count NUMBER;
l_task_name VARCHAR2(240);
l_task_number VARCHAR2(100);
l_alias VARCHAR2(240);
l_task_id NUMBER;
l_ta_display_flag VARCHAR2(1);
l_unplanned_flag VARCHAR2(1);
l_planned_effort_exists VARCHAR2(1);
l_progress_rollup_required VARCHAR2(1) := 'N';
l_total_plan_quantity NUMBER;
l_edit_task_ok varchar2(1) := 'N'; -- Bug 6856934

BEGIN

    x_return_status := FND_API.G_RET_STS_SUCCESS;
    g_require_progress_rollup := 'N'; -- End of Bug 4492493
    L_FuncProc := 'Validate_Delete_Assignment';

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	    pa_debug.g_err_stage:='Beginning of TA:Validate_Delete_Assignment';
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

    x_delete_task_flag_tbl  := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();
    x_delete_asgmt_flag_tbl := SYSTEM.PA_VARCHAR2_1_TBL_TYPE();

    --Bug 4951422
    x_task_assmt_ids_tbl := SYSTEM.PA_NUM_TBL_TYPE();

    --Bug 4492493: Check if Progress Rollup is required on CREATION
    IF p_context = 'WORKPLAN' and p_task_or_res = 'TASKS' THEN
      OPEN C_Task_Get_Project_Id(p_elem_ver_id_tbl(1));
      FETCH C_Task_Get_Project_Id INTO l_project_id;
      CLOSE C_Task_Get_Project_Id;
    ELSE
      OPEN C_Asgmt_Get_Project_Id(p_resource_assignment_id_tbl(1));
      FETCH C_Asgmt_Get_Project_Id INTO l_project_id;
      CLOSE C_Asgmt_Get_Project_Id;
    END IF;

    l_progress_rollup_required := Is_Progress_Rollup_Required(l_project_id);
    -- End of Bug 4492493

    -- Case 1: Delete Tasks
    IF p_context = 'WORKPLAN' AND p_task_or_res = 'TASKS' THEN

        x_delete_task_flag_tbl.extend(p_elem_ver_id_tbl.COUNT);

        FOR i in 1..p_elem_ver_id_tbl.COUNT LOOP

            OPEN C_Element_Info(p_elem_ver_id_tbl(i));
            FETCH C_Element_Info
            INTO l_project_id, l_structure_version_id, l_proj_element_id, l_task_name, l_task_number;
            CLOSE C_Element_Info;

            -- Bug 4492493: Check if Progress Rollup is required on DELETION
            IF g_require_progress_rollup = 'N' AND
               l_progress_rollup_required = 'Y' THEN

              l_planned_effort_exists := 'N';
              OPEN C_Planned_Effort_Exists(p_elem_ver_id_tbl(i));
              FETCH C_Planned_Effort_Exists INTO l_planned_effort_exists;
              CLOSE C_Planned_Effort_Exists;
              IF l_planned_effort_exists = 'Y' THEN
                g_require_progress_rollup := 'Y';
              END IF;

            END IF;
            -- End of Bug 4492493

            l_progress_exists := 'N';

            -- Bug 4073659
            -- Use this new API to check for published progress only and delete progress
            l_progress_exists := PA_PROGRESS_UTILS.check_prog_exists_and_delete(

	                                         l_project_id,
                                                 l_proj_element_id,
                                                 'PA_TASKS',
                                                 l_proj_element_id,
                                                 'WORKPLAN');


            IF l_progress_exists = 'Y' THEN
                x_delete_task_flag_tbl(i) := 'N';
                PA_UTILS.ADD_MESSAGE
                (
				    p_app_short_name => 'PA',
                    p_msg_name       => 'PA_DL_TASK_PROG_ERR',
                    p_token1         => 'TASK_NAME',
                    p_value1         =>  l_task_name,
                    p_token2         => 'TASK_NUMBER',
                    p_value2         =>  l_task_number,
                    p_token3         => 'PL_RES_ALIAS',
                    p_value3         =>  l_alias
                );
                x_return_status := FND_API.G_RET_STS_ERROR;

            ELSE

                x_delete_task_flag_tbl(i) := 'Y';

                -- use cursor to query up all task assignments in the task version
		--Bug 4951422. Initialize the table before loading it.
                l_task_asgmts_tbl:=SYSTEM.pa_num_tbl_type();

                OPEN C_Task_Asgmts(p_elem_ver_id_tbl(i));
                FETCH C_Task_Asgmts BULK COLLECT INTO l_task_asgmts_tbl;
                CLOSE C_Task_Asgmts;

                IF l_task_asgmts_tbl.COUNT > 0 THEN

                    -- LOOP through the l_task_asgmts_tbl and call the following API per assingment
                    -- use PA_ASSIGNMENT context
                    FOR j IN 1..l_task_asgmts_tbl.COUNT LOOP

		        --Bug 4951422. Populate x_task_assmt_ids_tbl with the Resource Assignment ids
                        --that should be deleted.
                        x_task_assmt_ids_tbl.extend;
                        x_task_assmt_ids_tbl(x_task_assmt_ids_tbl.COUNT) := l_task_asgmts_tbl(j);

	              pa_deliverable_pub.delete_dlv_task_asscn_in_bulk
				    (
					p_init_msg_list     => FND_API.G_FALSE,
			                p_calling_context   => 'PA_ASSIGNMENTS',
			                p_task_element_id   => l_task_asgmts_tbl(j),
			                p_task_version_id   => NULL,
			                p_project_id        => l_project_id,
			                x_return_status     => l_return_status,
			                x_msg_count         => l_msg_count,
			                x_msg_data          => l_msg_data
			            );

                     -- Bug 4317547: Should check the return status
                     IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                        x_return_status := FND_API.G_RET_STS_ERROR;
                     END IF;

	           END LOOP;

                END IF;

            END IF;

        END LOOP;

    ELSIF p_task_or_res = 'ASSIGNMENT' THEN

        -- Bug 3888432
        -- Case 2: Create subtask and delete sys generated assignment on parent task
        IF p_context = 'WORKPLAN' THEN

            x_delete_asgmt_flag_tbl.extend(p_resource_assignment_id_tbl.COUNT);

            FOR i in 1..p_resource_assignment_id_tbl.COUNT LOOP

              -- Bug 4492493: Check if Progress Rollup is required on DELETION
              IF g_require_progress_rollup = 'N' AND
                 l_progress_rollup_required = 'Y' THEN

                l_planned_effort_exists := 'N';
                OPEN C_Asgmt_Planned_Effort_Exists(p_resource_assignment_id_tbl(i));
                FETCH C_Asgmt_Planned_Effort_Exists INTO l_planned_effort_exists;
                CLOSE C_Asgmt_Planned_Effort_Exists;
                IF l_planned_effort_exists = 'Y' THEN
                  g_require_progress_rollup := 'Y';
                END IF;

              END IF;
              -- End of Bug 4492493

                x_delete_asgmt_flag_tbl(i) := 'Y';
            END LOOP;

        -- Case 3: Delete selected task assignments
        ELSIF p_context = 'TASK_ASSIGNMENT' THEN

            x_delete_asgmt_flag_tbl.extend(p_resource_assignment_id_tbl.COUNT);

            FOR i in 1..p_resource_assignment_id_tbl.COUNT LOOP

	            OPEN C_Element_Info2(p_resource_assignment_id_tbl(i));
	            FETCH C_Element_Info2
	            INTO l_wbs_element_version_id, l_project_id, l_proj_element_id, l_rlm_id, l_ta_display_flag, l_task_id, l_unplanned_flag, l_total_plan_quantity;
	            CLOSE C_Element_Info2;

                    -- Bug 4492493: Check if Progress Rollup is required on DELETION
                    IF g_require_progress_rollup = 'N' AND
                       l_progress_rollup_required = 'Y' AND
                       l_total_plan_quantity > 0 THEN

                      g_require_progress_rollup := 'Y';
                    END IF;
                    -- End of Bug 4492493

                        -- Bug 6856934
                        if nvl(p_calling_context,'X') = 'PA_PROJECT_ASSIGNMENT' then
                                l_edit_task_ok := 'Y';
                        else

                                l_edit_task_ok := check_edit_task_ok(P_PROJECT_ID           => l_project_id,
                                 P_STRUCTURE_VERSION_ID    => l_struct_ver_id,
                                 P_CURR_STRUCT_VERSION_ID  => l_struct_ver_id,
                                 P_Element_Id              => NULL,
                                 P_Element_Version_Id      => NULL,
                                 P_Task_Assignment_Id      => p_resource_assignment_id_tbl(i));
                        end if;
                        -- Bug 6856934

                    -- Bug 4073659: Allow unplanned assignment to be deleted
                    IF l_unplanned_flag = 'Y' OR
                       'Y' = l_edit_task_ok then
                       /*check_edit_task_ok(P_PROJECT_ID           => l_project_id,
                                 P_STRUCTURE_VERSION_ID    => l_struct_ver_id,
                                 P_CURR_STRUCT_VERSION_ID  => l_struct_ver_id,
                                 P_Element_Id              => NULL,
                                 P_Element_Version_Id      => NULL,
                                 P_Task_Assignment_Id      => p_resource_assignment_id_tbl(i)) THEN Bug 6856934*/



                        -- Bug 4073659
                        -- Use this new API to check for published progress only and delete progress

                        l_progress_exists := PA_PROGRESS_UTILS.check_prog_exists_and_delete(

	                                         l_project_id,
                                                 l_proj_element_id,
                                                 'PA_ASSIGNMENTS',
                                                 l_rlm_id,
                                                 'WORKPLAN');

	                IF l_progress_exists = 'Y' THEN
	                    x_delete_asgmt_flag_tbl(i) := 'N';
	                    PA_UTILS.ADD_MESSAGE
	                    (
						    p_app_short_name => 'PA',
	                        p_msg_name       => 'PA_DL_TA_PROG_ERR'
	                    );
	                    x_return_status := FND_API.G_RET_STS_ERROR;
	                ELSE
	                    x_delete_asgmt_flag_tbl(i) := 'Y';
	                    pa_deliverable_pub.delete_dlv_task_asscn_in_bulk
	                    (
					p_init_msg_list     => FND_API.G_FALSE,
					p_calling_context   => 'PA_ASSIGNMENTS',
	                 		p_task_element_id   => p_resource_assignment_id_tbl(i),
					p_task_version_id   => l_wbs_element_version_id,
	                  		p_project_id        => l_project_id,
					x_return_status     => l_return_status,
					x_msg_count         => l_msg_count,
					x_msg_data          => l_msg_data
			    );

                            -- Bug 4317547: Should check the return status
                            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              x_return_status := FND_API.G_RET_STS_ERROR;
                            END IF;

		        END IF;

				ELSE -- check task edit ok

                                        -- Bug 4533152
					--PA_UTILS.ADD_MESSAGE
					--(
					--    p_app_short_name => 'PA',
					--    p_msg_name       => 'PA_UPDATE_PUB_VER_ERR'
					--);
					x_return_status := FND_API.G_RET_STS_ERROR;

				END IF; -- check task edit ok

			END LOOP;

		END IF; -- ELSIF p_context = 'TASK_ASSIGNMENT' THEN

	END IF;

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		pa_debug.g_err_stage:='End of TA:Validate_Delete_Assignment';
		pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 5);
        END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	    IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        RAISE;

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
            PA_DEBUG.write_log (x_module => L_Module,
                                x_msg         =>'Unexpected Error:' || L_FuncProc || SQLERRM,
                                x_log_level   => 6);
        END IF;
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                                 p_procedure_name => L_FuncProc);
        RAISE;

END Validate_Delete_Assignment;





-- This procedure will Validate the Copying of Planning Transaction
-- and return Assignments that can be copied.

PROCEDURE Validate_Copy_Assignment
(
    p_src_project_id         IN NUMBER,
    p_target_project_id      IN NUMBER,
    p_src_elem_ver_id_tbl    IN SYSTEM.PA_NUM_TBL_TYPE,
    p_targ_elem_ver_id_tbl   IN SYSTEM.PA_NUM_TBL_TYPE,
    p_copy_people_flag       IN VARCHAR2,
    p_copy_equip_flag        IN VARCHAR2,
    p_copy_mat_item_flag     IN VARCHAR2,
    p_copy_fin_elem_flag     IN VARCHAR2,
    p_copy_external_flag     IN VARCHAR2   DEFAULT 'N',
    x_resource_rec_tbl       OUT NOCOPY l_resource_rec_tbl_type,
    x_calculate_flag         OUT NOCOPY VARCHAR2,
	x_rbs_diff_flag          OUT NOCOPY VARCHAR2,
    x_return_status          OUT NOCOPY VARCHAR2
)

IS

-- Declare a dynamic cursor and variables:
l_index NUMBER := 1;
L_FuncProc varchar2(250) ;
l_res_class1 varchar2(500);
l_res_class2 varchar2(500);
l_res_class3 varchar2(500);
l_res_class4 varchar2(500);
l_res_class5 varchar2(500);

l_ta_structure_version_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_ta_resource_assgt_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_project_assgt_tbl  SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
-- Bug 4097749.
l_ta_named_role_tbl     SYSTEM.pa_varchar2_80_tbl_type := SYSTEM.pa_varchar2_80_tbl_type();
l_ta_role_in_format_flag_tbl   SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
-- \Bug 4097749.
l_ta_wbs_elem_ver_tbl   SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_schedule_start_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_ta_schedule_end_tbl   SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_ta_planning_start_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_ta_planning_end_tbl   SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_ta_res_mem_id_tbl     SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_display_flag_tbl   SYSTEM.pa_varchar2_1_tbl_type := SYSTEM.pa_varchar2_1_tbl_type();
l_t_src_start_tbl      SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_t_src_end_tbl        SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_t_target_start_tbl   SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_t_target_end_tbl     SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_c_resource_assgt_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_c_schedule_start_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_c_schedule_end_tbl   SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_c_planning_start_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_c_planning_end_tbl   SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_c_res_mem_id_tbl     SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_src_res_mem_id_tbl   SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();

l_src_resource_list_id NUMBER;
l_target_resource_list_id NUMBER;
l_published VARCHAR2(1);
l_ta_structure_version_id NUMBER;
l_t_target_start_date DATE;
l_t_target_end_date DATE;
l_t_src_start_date DATE;
l_t_src_end_date DATE;
l_ta_resource_assgt_id NUMBER;
l_ta_project_assgt_id NUMBER;
l_ta_wbs_elem_ver_id NUMBER;
l_ta_planning_start_date DATE;
l_ta_planning_end_date DATE;
l_ta_schedule_start_date DATE;
l_ta_schedule_end_date DATE;
l_ta_display_flag VARCHAR2(1);
l_ta_res_mem_id NUMBER;
l_accum_people_qty NUMBER;
l_accum_equip_qty NUMBER;
l_accum_mat_item_cost NUMBER;
l_accum_fin_elem_cost NUMBER;
l_people_class_index NUMBER := -999;
l_equip_class_index NUMBER := -999;
l_mat_item_class_index NUMBER := -999;
l_fin_elem_class_index NUMBER := -999;
l_ta_res_type_code  pa_resource_assignments.res_type_code%TYPE;
l_ta_resource_class_code pa_resource_assignments.resource_class_code%TYPE;
l_ta_resource_class_flag pa_resource_assignments.resource_class_flag%TYPE;
l_ta_total_plan_quantity pa_resource_assignments.total_plan_quantity%TYPE;
l_ta_total_plan_raw_cost pa_resource_assignments.total_plan_raw_cost%TYPE;
l_ta_total_proj_raw_cost pa_resource_assignments.total_project_raw_cost%TYPE;
l_ta_rate_based_flag pa_resource_assignments.rate_based_flag%TYPE;
l_ta_tar_res_mem_id_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_budget_version_id pa_resource_assignments.budget_version_id%TYPE;
l_class_rlm_id pa_resource_list_members.resource_list_member_id%TYPE;
l_ta_tr_res_list_member_id pa_project_assignments.resource_list_member_id%TYPE;
l_ta_task_id pa_resource_assignments.task_id%TYPE;
l_ta_res_type_code_tbl  SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
l_ta_resource_class_code_tbl SYSTEM.pa_varchar2_30_tbl_type   := SYSTEM.pa_varchar2_30_tbl_type();
l_ta_resource_class_flag_tbl SYSTEM.pa_varchar2_1_tbl_type   := SYSTEM.pa_varchar2_1_tbl_type();
l_ta_total_plan_quantity_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_total_plan_raw_cost_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_total_proj_raw_cost_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_rate_based_flag_tbl SYSTEM.pa_varchar2_1_tbl_type   := SYSTEM.pa_varchar2_1_tbl_type();
l_ta_budget_version_id_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_previous_elem_version_id NUMBER;
l_add_elem_version_id_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_add_res_list_member_id_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_add_qty_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_add_raw_cost_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_ta_tr_res_list_member_id_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_add_projfunc_cur_code_tbl SYSTEM.pa_varchar2_15_tbl_type   := SYSTEM.pa_varchar2_15_tbl_type();
l_ta_task_id_tbl SYSTEM.pa_num_tbl_type := SYSTEM.pa_num_tbl_type();
l_target_budget_version_id pa_resource_assignments.budget_version_id%TYPE;
l_target_structure_version_id pa_budget_versions.project_structure_version_id%TYPE;
l_target_workplan_costs_flag pa_proj_fp_options.track_workplan_costs_flag%TYPE;
l_source_workplan_costs_flag pa_proj_fp_options.track_workplan_costs_flag%TYPE;
l_source_cost_time_phased_code pa_proj_fp_options.cost_time_phased_code%TYPE;
l_target_cost_time_phased_code pa_proj_fp_options.cost_time_phased_code%TYPE;

l_element_version_index NUMBER;
-- NEW plsql table to hold the ordered src date
l_adj_src_t_start_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_adj_src_t_end_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_adj_tar_t_start_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_adj_tar_t_end_tbl SYSTEM.pa_date_tbl_type  := SYSTEM.pa_date_tbl_type();
l_t_src_elem_ver_id NUMBER;
l_t_src_elem_ver_id_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
l_t_target_elem_ver_id NUMBER;
l_t_target_elem_ver_id_tbl SYSTEM.pa_num_tbl_type   := SYSTEM.pa_num_tbl_type();
-- Variables for the Currency Conversion API
l_api_version NUMBER;
l_init_msg_list VARCHAR2(32767);
l_commit VARCHAR2(32767);
l_validate_only VARCHAR2(32767);
l_validation_level NUMBER;
l_calling_module VARCHAR2(32767);
l_debug_mode VARCHAR2(32767);
l_max_msg_count NUMBER;
l_txn_curr_code VARCHAR2(32767);
l_structure_version_id NUMBER;
l_project_curr_code VARCHAR2(32767);
l_project_rate_type VARCHAR2(32767);
l_project_rate_date DATE;
l_project_exch_rate NUMBER;
l_project_raw_cost NUMBER;
l_projfunc_curr_code VARCHAR2(32767);
l_projfunc_cost_rate_type VARCHAR2(32767);
l_projfunc_cost_rate_date DATE;
l_projfunc_cost_exch_rate NUMBER;
l_projfunc_raw_cost NUMBER;
l_txn_mat_item_cost NUMBER;
l_txn_fin_elem_cost NUMBER;
l_src_project_curr_code VARCHAR2(15);
l_src_projfunc_curr_code VARCHAR2(15);
l_tar_projfunc_cur_code VARCHAR2(15);
l_tar_proj_cur_code VARCHAR2(15);

CURSOR get_target_project_info (p_target_element_version_id IN NUMBER) IS
	select pev.parent_structure_version_id structure_version_id, bv.budget_version_id, fpo.track_workplan_costs_flag
	from pa_proj_element_versions pev, pa_budget_versions bv, pa_proj_fp_options fpo
	where bv.project_structure_version_id = pev.parent_structure_version_id
	and bv.project_id = fpo.project_id
	and bv.fin_plan_type_id = fpo.fin_plan_type_id
	and bv.budget_version_id = fpo.fin_plan_version_id
	and fpo.fin_plan_option_level_code = 'PLAN_VERSION'
	and bv.wp_version_flag = 'Y'
	and pev.element_version_id = p_target_element_version_id;

-- Bug 3951947 get the PC and PFC of the project
CURSOR get_proj_currency_code (c_project_id IN NUMBER) IS
	select projfunc_currency_code, project_currency_code
	from pa_projects_all
	where project_id = c_project_id;

CURSOR get_txn_currency_code (p_resource_assignment_id NUMBER) IS
	select txn_currency_code
	from pa_budget_lines
	where resource_assignment_id = p_resource_assignment_id
	and rownum = 1;

l_add_cnt NUMBER := 0;
l_msg_count NUMBER;
l_msg_data VARCHAR2(4000);

-- IMPORTANT
-- These 2 cursors HAVE to be ordered by wbs_element_version_id.
CURSOR c_get_asgmts_for_copy(p_res_class1 VARCHAR2, p_res_class2 VARCHAR2, p_res_class3 VARCHAR2, p_res_class4 VARCHAR2) IS
	SELECT * FROM
	(
		SELECT
		ra.resource_assignment_id,
		ra.project_assignment_id,
		ra.named_role,
		rf.role_enabled_flag,
		ra.wbs_element_version_id,
		ra.planning_start_date,
		ra.planning_end_date,
		ra.schedule_start_date,
		ra.schedule_end_date,
		ra.ta_display_flag,
		ra.resource_list_member_id res_mem_list_id,
		pev.parent_structure_version_id,
		ra.res_type_code,
		ra.resource_class_code,
		ra.resource_class_flag,
		sum(bl.quantity),
		sum(bl.txn_raw_cost),
		-- Bug 3951947: Should sum up raw cost in projfunc currency
		sum(bl.raw_cost),
		ra.rate_based_flag,
		ra.budget_version_id,
		asgn.resource_list_member_id tr_res_mem_list_id,
		ra.task_id,
		'RES_ASSIGNMENT',
		ra.person_id,
		ra.job_id,
		ra.organization_id,
		ra.supplier_id,
		ra.expenditure_type,
		ra.event_type,
		ra.expenditure_category,
		ra.revenue_category_code,
		ra.project_role_id,
		ra.item_category_id,
		ra.person_type_code,
		ra.bom_resource_id,
		ra.non_labor_resource,
		ra.inventory_item_id
		FROM
		pa_copy_asgmts_temp temp,
		pa_proj_element_versions pev,
		pa_resource_assignments ra,
		pa_project_assignments asgn,
		pa_budget_lines bl,
		pa_resource_list_members rlm,
		pa_res_formats_b rf
		WHERE
		pev.element_version_id = temp.src_elem_ver_id AND
		pev.element_version_id = ra.wbs_element_version_id AND
		bl.resource_assignment_id = ra.resource_assignment_id AND
		ra.ta_display_flag IS NOT NULL AND
		(ra.unplanned_flag = 'N' OR ra.unplanned_flag IS NULL) AND
		decode(ra.project_assignment_id, -1, null, ra.project_assignment_id) = asgn.assignment_id(+) AND
		ra.resource_class_code IN ( p_res_class1 , p_res_class2 , p_res_class3, p_res_class4 ) AND
		rlm.resource_list_member_id = ra.resource_list_member_id AND
		rf.res_format_id = rlm.res_format_id
		GROUP BY
		ra.resource_assignment_id,
		ra.project_assignment_id,
		ra.named_role,
		rf.role_enabled_flag,
		ra.wbs_element_version_id,
		ra.planning_start_date,
		ra.planning_end_date,
		ra.schedule_start_date,
		ra.schedule_end_date,
		ra.ta_display_flag,
		ra.resource_list_member_id,
		pev.parent_structure_version_id,
		ra.res_type_code,
		ra.resource_class_code,
		ra.resource_class_flag,
		ra.rate_based_flag,
		ra.budget_version_id,
		asgn.resource_list_member_id,
		ra.task_id,
		ra.person_id,
		ra.job_id,
		ra.organization_id,
		ra.supplier_id,
		ra.expenditure_type,
		ra.event_type,
		ra.expenditure_category,
		ra.revenue_category_code,
		ra.project_role_id,
		ra.item_category_id,
		ra.person_type_code,
		ra.bom_resource_id,
		ra.non_labor_resource,
		ra.inventory_item_id

		UNION ALL

		SELECT
		ra.resource_assignment_id,
		ra.project_assignment_id,
		ra.named_role,
		rf.role_enabled_flag,
		ra.wbs_element_version_id,
		ra.planning_start_date,
		ra.planning_end_date,
		ra.schedule_start_date,
		ra.schedule_end_date,
		ra.ta_display_flag,
		ra.resource_list_member_id res_mem_list_id,
		pev.parent_structure_version_id,
		ra.res_type_code,
		ra.resource_class_code,
		ra.resource_class_flag,
		to_number(NULL),
		to_number(NULL),
		to_number(NULL),
		ra.rate_based_flag,
		ra.budget_version_id,
		asgn.resource_list_member_id tr_res_mem_list_id,
		ra.task_id,
		'RES_ASSIGNMENT',
		ra.person_id,
		ra.job_id,
		ra.organization_id,
		ra.supplier_id,
		ra.expenditure_type,
		ra.event_type,
		ra.expenditure_category,
		ra.revenue_category_code,
		ra.project_role_id,
		ra.item_category_id,
		ra.person_type_code,
		ra.bom_resource_id,
		ra.non_labor_resource,
		ra.inventory_item_id
		FROM
		pa_copy_asgmts_temp temp,
		pa_proj_element_versions pev,
		pa_resource_assignments ra,
		pa_project_assignments asgn,
		pa_resource_list_members rlm,
		pa_res_formats_b rf
		WHERE
		pev.element_version_id = temp.src_elem_ver_id AND
		pev.element_version_id = ra.wbs_element_version_id AND
		ra.ta_display_flag IS NOT NULL AND
		(ra.unplanned_flag = 'N' OR ra.unplanned_flag IS NULL) AND
		decode(ra.project_assignment_id, -1, NULL, ra.project_assignment_id) = asgn.assignment_id(+) AND
		ra.resource_class_code IN ( p_res_class1 , p_res_class2 , p_res_class3, p_res_class4 ) AND
		rlm.resource_list_member_id = ra.resource_list_member_id AND
		rf.res_format_id = rlm.res_format_id AND
		NOT EXISTS
		(SELECT 1 FROM pa_budget_lines bl WHERE bl.resource_assignment_id = ra.resource_assignment_id)
	) ORDER BY 5;

CURSOR c_get_asgmts_for_copy_proj(p_res_class1 VARCHAR2, p_res_class2 VARCHAR2, p_res_class3 VARCHAR2, p_res_class4 VARCHAR2) IS
	SELECT * FROM
	(
		SELECT
		ra.resource_assignment_id,
		ra.project_assignment_id,
		ra.named_role,
		rf.role_enabled_flag,
		ra.wbs_element_version_id,
		ra.planning_start_date,
		ra.planning_end_date,
		ra.schedule_start_date,
		ra.schedule_end_date,
		ra.ta_display_flag,
		source_rlm.resource_list_member_id src_res_mem_list_id,
		target_rlm.resource_list_member_id tar_res_mem_list_id,
		pev.parent_structure_version_id,
		ra.res_type_code,
		ra.resource_class_code,
		ra.resource_class_flag,
		sum(bl.quantity),
		sum(bl.txn_raw_cost),
		-- Bug 3951947: Should sum up raw cost in projfunc currency
		sum(bl.raw_cost),
		ra.rate_based_flag,
		ra.budget_version_id,
		asgn.resource_list_member_id tr_res_mem_list_id,
		ra.task_id,
		'RES_ASSIGNMENT',
		ra.person_id,
		ra.job_id,
		ra.organization_id,
		ra.supplier_id,
		ra.expenditure_type,
		ra.event_type,
		ra.expenditure_category,
		ra.revenue_category_code,
		ra.project_role_id,
		ra.item_category_id,
		ra.person_type_code,
		ra.bom_resource_id,
		ra.non_labor_resource,
		ra.inventory_item_id
		FROM
		pa_copy_asgmts_temp temp,
		pa_proj_element_versions pev,
		pa_resource_assignments ra,
		pa_project_assignments asgn,
		pa_budget_lines bl,
		pa_resource_list_members source_rlm,
		pa_resource_list_members target_rlm,
		pa_res_formats_b rf
		WHERE
		pev.element_version_id = temp.src_elem_ver_id AND
		pev.element_version_id = ra.wbs_element_version_id AND
		bl.resource_assignment_id = ra.resource_assignment_id AND
		ra.ta_display_flag IS NOT NULL AND
		(ra.unplanned_flag = 'N' OR ra.unplanned_flag IS NULL) AND
		decode(ra.project_assignment_id, -1, null, ra.project_assignment_id) = asgn.assignment_id(+) AND
		ra.resource_class_code IN ( p_res_class1 , p_res_class2 , p_res_class3, p_res_class4 ) AND
		source_rlm.resource_list_member_id = ra.resource_list_member_id AND
		target_rlm.resource_list_id  = source_rlm.resource_list_id AND
		target_rlm.alias  = source_rlm.alias AND
		target_rlm.object_type = source_rlm.object_type AND
		target_rlm.object_id = p_target_project_id AND
		rf.res_format_id = target_rlm.res_format_id
		GROUP BY
		ra.resource_assignment_id,
		ra.project_assignment_id,
		ra.named_role,
		rf.role_enabled_flag,
		ra.wbs_element_version_id,
		ra.planning_start_date,
		ra.planning_end_date,
		ra.schedule_start_date,
		ra.schedule_end_date,
		ra.ta_display_flag,
		source_rlm.resource_list_member_id,
		target_rlm.resource_list_member_id,
		pev.parent_structure_version_id,
		ra.res_type_code,
		ra.resource_class_code,
		ra.resource_class_flag,
		ra.rate_based_flag,
		ra.budget_version_id,
		asgn.resource_list_member_id,
		ra.task_id,
		ra.person_id,
		ra.job_id,
		ra.organization_id,
		ra.supplier_id,
		ra.expenditure_type,
		ra.event_type,
		ra.expenditure_category,
		ra.revenue_category_code,
		ra.project_role_id,
		ra.item_category_id,
		ra.person_type_code,
		ra.bom_resource_id,
		ra.non_labor_resource,
		ra.inventory_item_id

		UNION ALL

		SELECT
		ra.resource_assignment_id,
		ra.project_assignment_id,
		ra.named_role,
		rf.role_enabled_flag,
		ra.wbs_element_version_id,
		ra.planning_start_date,
		ra.planning_end_date,
		ra.schedule_start_date,
		ra.schedule_end_date,
		ra.ta_display_flag,
		source_rlm.resource_list_member_id src_res_mem_list_id,
		target_rlm.resource_list_member_id tar_res_mem_list_id,
		pev.parent_structure_version_id,
		ra.res_type_code,
		ra.resource_class_code,
		ra.resource_class_flag,
		to_number(NULL),
		to_number(NULL),
		to_number(NULL),
		ra.rate_based_flag,
		ra.budget_version_id,
		asgn.resource_list_member_id tr_res_mem_list_id,
		ra.task_id,
		'RES_ASSIGNMENT',
		ra.person_id,
		ra.job_id,
		ra.organization_id,
		ra.supplier_id,
		ra.expenditure_type,
		ra.event_type,
		ra.expenditure_category,
		ra.revenue_category_code,
		ra.project_role_id,
		ra.item_category_id,
		ra.person_type_code,
		ra.bom_resource_id,
		ra.non_labor_resource,
		ra.inventory_item_id
		FROM
		pa_copy_asgmts_temp temp,
		pa_proj_element_versions pev,
		pa_resource_assignments ra,
		pa_project_assignments asgn,
		pa_resource_list_members source_rlm,
		pa_resource_list_members target_rlm,
		pa_res_formats_b rf
		WHERE
		pev.element_version_id = temp.src_elem_ver_id AND
		pev.element_version_id = ra.wbs_element_version_id AND
		ra.ta_display_flag IS NOT NULL AND
		(ra.unplanned_flag = 'N' OR ra.unplanned_flag IS NULL) AND
		source_rlm.resource_list_member_id = ra.resource_list_member_id AND
		target_rlm.resource_list_id  = source_rlm.resource_list_id AND
		target_rlm.alias  = source_rlm.alias AND
		target_rlm.object_type = source_rlm.object_type AND
		target_rlm.object_id =  p_target_project_id AND
		decode(ra.project_assignment_id, -1, NULL, ra.project_assignment_id) = asgn.assignment_id(+) AND
		ra.resource_class_code IN ( p_res_class1 , p_res_class2 , p_res_class3, p_res_class4 ) AND
		rf.res_format_id = target_rlm.res_format_id AND
		NOT EXISTS
		(SELECT 1 FROM pa_budget_lines bl WHERE bl.resource_assignment_id = ra.resource_assignment_id)
	) ORDER BY 5;


l_num_of_tasks NUMBER;
l_db_block_size NUMBER;
l_num_blocks NUMBER;

CURSOR c_get_src_sched_dates IS
	SELECT pev.element_version_id, pevs.scheduled_start_date, pevs.scheduled_finish_date
	FROM pa_copy_asgmts_temp temp, pa_proj_element_versions pev, pa_proj_elem_ver_schedule pevs
	WHERE pev.element_version_id = pevs.element_version_id
	AND pev.element_version_id = temp.src_elem_ver_id;

CURSOR c_get_targ_sched_dates IS
	SELECT pev.element_version_id, pevs.scheduled_start_date, pevs.scheduled_finish_date
	FROM pa_copy_asgmts_temp temp, pa_proj_element_versions pev, pa_proj_elem_ver_schedule pevs
	WHERE pev.element_version_id = pevs.element_version_id
	AND pev.element_version_id = temp.targ_elem_ver_id;

CURSOR get_rl_proj_specific_flag(c_resource_list_id NUMBER) IS
	SELECT decode(rlab.control_flag, 'Y', 'N', 'Y'), rl.uncategorized_flag
	FROM pa_resource_lists_all_bg rlab, pa_resource_lists rl
	WHERE rlab.resource_list_id = c_resource_list_id
        AND rlab.resource_list_id = rl.resource_list_id;

l_rl_proj_specific_flag VARCHAR2(1);
l_tar_rl_none_flag VARCHAR2(1) := null;

-- Bug 3974569.
CURSOR c_get_bv_and_rbs_id(c_evid NUMBER) IS
	SELECT bv.budget_version_id, pfo.rbs_version_id
	FROM pa_proj_element_versions pev, pa_budget_versions bv, pa_proj_fp_options pfo
	WHERE pev.element_version_id = c_evid
	AND bv.project_structure_version_id = pev.parent_structure_version_id
	AND pfo.fin_plan_version_id = bv.budget_version_id;

CURSOR get_multi_cur_flag(c_project_id NUMBER) IS
select nvl(PLAN_IN_MULTI_CURR_FLAG, 'N'), nvl(track_workplan_costs_flag, 'N'), nvl(cost_time_phased_code, 'N')
from   pa_proj_fp_options
where fin_plan_type_id = (select fin_plan_type_id
                          from pa_fin_plan_types_b
			  where use_for_workplan_flag = 'Y')
and project_id = c_project_id
and fin_plan_option_level_code = 'PLAN_TYPE';


l_src_bvid NUMBER;
l_tar_bvid NUMBER;
l_src_rbs_ver_id NUMBER;
l_tar_rbs_ver_id NUMBER;
l_src_multi_cur_flag VARCHAR2(1);
l_tar_multi_cur_flag VARCHAR2(1);
l_copy_res_mem_id_tbl  SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();

l_txn_source_type_code_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_person_id_tbl             SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_job_id_tbl                SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_organization_id_tbl       SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_supplier_id_tbl           SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_expenditure_type_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_event_type_tbl            SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_expenditure_category_tbl  SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_revenue_category_code_tbl SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_project_role_id_tbl       SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_item_category_id_tbl      SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_person_type_code_tbl      SYSTEM.PA_VARCHAR2_30_TBL_TYPE := SYSTEM.PA_VARCHAR2_30_TBL_TYPE();
l_bom_resource_id_tbl       SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_non_labor_resource_tbl    SYSTEM.PA_VARCHAR2_20_TBL_TYPE := SYSTEM.PA_VARCHAR2_20_TBL_TYPE();
l_inventory_item_id_tbl     SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();

l_txn_source_id_tab         SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_res_list_member_id_tab    SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_rbs_element_id_tab        SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
l_txn_accum_header_id_tab   SYSTEM.PA_NUM_TBL_TYPE         := SYSTEM.PA_NUM_TBL_TYPE();
-- \Bug 3974569.
l_progress_rollup_required  VARCHAR2(1) := 'N';

BEGIN

	x_return_status := FND_API.G_RET_STS_SUCCESS;
        g_require_progress_rollup := 'N'; -- End of Bug 4492493
	L_FuncProc := 'Validate_Copy_Assignment';
	x_calculate_flag := 'N';
	x_rbs_diff_flag := 'N';

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		PA_DEBUG.write(x_module => L_Module, x_msg => 'p_src_project_id: ' || p_src_project_id, x_log_level => 3);
		PA_DEBUG.write(x_module => L_Module, x_msg => 'p_target_project_id: ' || p_target_project_id, x_log_level => 3);

		FOR temp_i IN 1..p_src_elem_ver_id_tbl.COUNT LOOP
			PA_DEBUG.write(x_module => L_Module, x_msg => 'p_src_elem_ver_id_tbl(' || temp_i || '): ' || p_src_elem_ver_id_tbl(temp_i), x_log_level => 3);
		END LOOP;

		FOR temp_i IN 1..p_targ_elem_ver_id_tbl.COUNT LOOP
			PA_DEBUG.write(x_module => L_Module, x_msg => 'p_targ_elem_ver_id_tbl(' || temp_i || '): ' || p_targ_elem_ver_id_tbl(temp_i), x_log_level => 3);
		END LOOP;

		PA_DEBUG.write(x_module => L_Module, x_msg => 'p_copy_people_flag: ' || p_copy_people_flag, x_log_level => 3);
		PA_DEBUG.write(x_module => L_Module, x_msg => 'p_copy_equip_flag: ' || p_copy_equip_flag, x_log_level => 3);
		PA_DEBUG.write(x_module => L_Module, x_msg => 'p_copy_mat_item_flag: ' || p_copy_mat_item_flag, x_log_level => 3);
		PA_DEBUG.write(x_module => L_Module, x_msg => 'p_copy_fin_elem_flag: ' || p_copy_fin_elem_flag, x_log_level => 3);
	END IF;

	IF (p_copy_people_flag is null) AND
           (p_copy_equip_flag is null) AND
           (p_copy_mat_item_flag is null) AND
           (p_copy_fin_elem_flag is null) THEN
             x_calculate_flag := 'N';
             RETURN;
        ELSIF (p_copy_people_flag = 'N') AND
          (p_copy_equip_flag = 'N') AND
          (p_copy_mat_item_flag = 'N') AND
          (p_copy_fin_elem_flag = 'N') THEN
             x_calculate_flag := 'N';
             RETURN;
        END IF;

        -- Get the source and target resource lists
	l_src_resource_list_id := Get_WP_Resource_List_Id(p_src_project_id);
	l_target_resource_list_id := Get_WP_Resource_List_Id(p_target_project_id);

	-- Check whether the target resource list is project specific or centrally controlled
	OPEN get_rl_proj_specific_flag(l_target_resource_list_id);
	FETCH get_rl_proj_specific_flag INTO l_rl_proj_specific_flag, l_tar_rl_none_flag;
	CLOSE get_rl_proj_specific_flag;

        -- ER 4127235: Get the multi-currency setup for the 2 projects
        OPEN get_multi_cur_flag(p_src_project_id);
        FETCH get_multi_cur_flag INTO l_src_multi_cur_flag, l_source_workplan_costs_flag, l_source_cost_time_phased_code;
        CLOSE get_multi_cur_flag;

        OPEN get_multi_cur_flag(p_target_project_id);
        FETCH get_multi_cur_flag INTO l_tar_multi_cur_flag, l_target_workplan_costs_flag, l_target_cost_time_phased_code;
        CLOSE get_multi_cur_flag;

	-- Bug 3951947: get target project's project functional currency code
	OPEN get_proj_currency_code(p_target_project_id);
	FETCH get_proj_currency_code INTO l_tar_projfunc_cur_code,  l_tar_proj_cur_code;
	CLOSE get_proj_currency_code;

	OPEN get_proj_currency_code(p_src_project_id);
	FETCH get_proj_currency_code INTO l_src_projfunc_curr_code,  l_src_project_curr_code;
	CLOSE get_proj_currency_code;

        -- Do not allow Copy External if the target project's Resource List is None
        IF l_tar_rl_none_flag = 'Y' and p_copy_external_flag='Y' THEN
               PA_UTILS.ADD_MESSAGE
               (p_app_short_name => 'PA',
                p_msg_name       => 'PA_RES_LIST_NONE_ERR'
               );
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
        END IF;

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		PA_DEBUG.write(x_module => L_Module, x_msg => 'l_src_resource_list_id: ' || l_src_resource_list_id, x_log_level => 3);
		PA_DEBUG.write(x_module => L_Module, x_msg => 'l_target_resource_list_id: ' || l_target_resource_list_id, x_log_level => 3);
	END IF;

	IF p_targ_elem_ver_id_tbl.COUNT > 0 THEN
		OPEN get_target_project_info (p_targ_elem_ver_id_tbl(1));
		FETCH get_target_project_info INTO l_target_structure_version_id, l_target_budget_version_id, l_target_workplan_costs_flag;
		CLOSE get_target_project_info;
	END IF;

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		PA_DEBUG.write(x_module => L_Module, x_msg => 'l_target_structure_version_id: ' || l_target_structure_version_id, x_log_level => 3);
		PA_DEBUG.write(x_module => L_Module, x_msg => 'l_target_budget_version_id: ' || l_target_budget_version_id, x_log_level   => 3);
		PA_DEBUG.write(x_module  => L_Module, x_msg => 'l_target_track_workplan_costs_flag: ' || l_target_workplan_costs_flag, x_log_level   => 3);

		pa_debug.g_err_stage:='Beginning of TA: ' || L_FuncProc;
		pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;



        -- ER 4127235: re-calculate in Copy External flow only if any of the
        --   followings are different  on source and target projects:
        --    resource list
        --    track workplan costR
        --    multi-currency settings
        --    time phase setting
        --    PC/PFC
	IF p_copy_external_flag = 'Y' AND
           (l_source_workplan_costs_flag <> l_target_workplan_costs_flag OR
            l_src_resource_list_id <> l_target_resource_list_id OR
            l_src_multi_cur_flag <> l_tar_multi_cur_flag OR
            l_target_cost_time_phased_code <> l_source_cost_time_phased_code OR
            l_tar_projfunc_cur_code <> l_src_projfunc_curr_code OR
            l_tar_proj_cur_code <> l_src_project_curr_code OR
            l_rl_proj_specific_flag = 'Y') THEN
		x_calculate_flag := 'Y';

	END IF;

        --Bug 4492493: Check if Progress Rollup is required on CREATION
        l_progress_rollup_required := Is_Progress_Rollup_Required(p_target_project_id);
        -- End of Bug 4492493

	--Construct predicate depending on the copy resource class flag.
	IF p_copy_people_flag = 'Y' THEN
		l_res_class1  := 'PEOPLE';
	END IF;
	IF p_copy_equip_flag = 'Y' THEN
		l_res_class2 := 'EQUIPMENT';
	END IF;
	IF p_copy_mat_item_flag = 'Y' THEN
		l_res_class3 := 'MATERIAL_ITEMS';
	END IF;
	IF p_copy_fin_elem_flag = 'Y' THEN
		l_res_class4 := 'FINANCIAL_ELEMENTS';
	END IF;

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		pa_debug.g_err_stage:= 'TA: ' || L_FuncProc || ' class1: ' || l_res_class1 || ' 2:' || l_res_class2 || ' 3: ' || l_res_class3 || ' 4: ' || l_res_class4;
	    pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

	IF p_src_elem_ver_id_tbl IS NOT NULL THEN

		l_num_of_tasks := p_src_elem_ver_id_tbl.COUNT;

		SELECT to_number(value)
		INTO   l_db_block_size
		FROM   v$parameter
		WHERE  name = 'db_block_size';

		l_num_blocks := 1.25 * (l_num_of_tasks * 75) / l_db_block_size;

		-- Manually seed the statistics for the temporary table.
		set_table_stats('PA','PA_COPY_ASGMTS_TEMP', l_num_of_tasks, l_num_blocks, 75);

		DELETE pa_copy_asgmts_temp;
		FORALL i IN 1..p_src_elem_ver_id_tbl.COUNT

			/*Bug 4377886 : Included explicitly the column names in the INSERT statement
					to remove the GSCC Warning File.Sql.33 */
                        -- Changed due to bug 4153366
			INSERT INTO pa_copy_asgmts_temp
			        (
        			SRC_ELEM_VER_ID,
        			TARG_ELEM_VER_ID,
        			OLD_TASK_SCH_START,
        			OLD_TASK_SCH_END,
        			NEW_TASK_SCH_START,
        			NEW_TASK_SCH_END
        			)
			VALUES
			(p_src_elem_ver_id_tbl(i), p_targ_elem_ver_id_tbl(i),null,null,null,null);

		-- If copy project and resource list is project specific.
		IF p_src_project_id <> p_target_project_id
		   AND p_copy_external_flag <> 'Y'
		   AND l_rl_proj_specific_flag = 'Y' THEN


			OPEN c_get_asgmts_for_copy_proj(l_res_class1, l_res_class2, l_res_class3, l_res_class4);
			FETCH c_get_asgmts_for_copy_proj BULK COLLECT INTO
				l_ta_resource_assgt_tbl, l_ta_project_assgt_tbl, l_ta_named_role_tbl, l_ta_role_in_format_flag_tbl,
				l_ta_wbs_elem_ver_tbl, l_ta_planning_start_tbl,
				l_ta_planning_end_tbl, l_ta_schedule_start_tbl, l_ta_schedule_end_tbl, l_ta_display_flag_tbl,
				l_ta_res_mem_id_tbl, l_ta_tar_res_mem_id_tbl, l_ta_structure_version_tbl, l_ta_res_type_code_tbl,
				l_ta_resource_class_code_tbl, l_ta_resource_class_flag_tbl, l_ta_total_plan_quantity_tbl,
				l_ta_total_plan_raw_cost_tbl, l_ta_total_proj_raw_cost_tbl, l_ta_rate_based_flag_tbl,
				l_ta_budget_version_id_tbl, l_ta_tr_res_list_member_id_tbl, l_ta_task_id_tbl,
				l_txn_source_type_code_tbl, l_person_id_tbl, l_job_id_tbl, l_organization_id_tbl, l_supplier_id_tbl,
				l_expenditure_type_tbl, l_event_type_tbl, l_expenditure_category_tbl, l_revenue_category_code_tbl,
				l_project_role_id_tbl, l_item_category_id_tbl, l_person_type_code_tbl, l_bom_resource_id_tbl,
				l_non_labor_resource_tbl, l_inventory_item_id_tbl;
			CLOSE c_get_asgmts_for_copy_proj;

		ELSE

			OPEN c_get_asgmts_for_copy(l_res_class1, l_res_class2, l_res_class3, l_res_class4);
			FETCH c_get_asgmts_for_copy BULK COLLECT INTO
				l_ta_resource_assgt_tbl, l_ta_project_assgt_tbl, l_ta_named_role_tbl, l_ta_role_in_format_flag_tbl,
				l_ta_wbs_elem_ver_tbl, l_ta_planning_start_tbl,
				l_ta_planning_end_tbl, l_ta_schedule_start_tbl, l_ta_schedule_end_tbl, l_ta_display_flag_tbl,
				l_ta_res_mem_id_tbl, l_ta_structure_version_tbl, l_ta_res_type_code_tbl, l_ta_resource_class_code_tbl,
				l_ta_resource_class_flag_tbl, l_ta_total_plan_quantity_tbl, l_ta_total_plan_raw_cost_tbl,
				l_ta_total_proj_raw_cost_tbl, l_ta_rate_based_flag_tbl, l_ta_budget_version_id_tbl,
				l_ta_tr_res_list_member_id_tbl, l_ta_task_id_tbl, l_txn_source_type_code_tbl, l_person_id_tbl,
				l_job_id_tbl, l_organization_id_tbl, l_supplier_id_tbl, l_expenditure_type_tbl, l_event_type_tbl,
				l_expenditure_category_tbl, l_revenue_category_code_tbl, l_project_role_id_tbl, l_item_category_id_tbl,
				l_person_type_code_tbl, l_bom_resource_id_tbl, l_non_labor_resource_tbl, l_inventory_item_id_tbl;
			CLOSE c_get_asgmts_for_copy;

		END IF;

		IF l_ta_resource_assgt_tbl.COUNT > 0 THEN

			IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
				pa_debug.g_err_stage:='TA: ' || L_FuncProc || ' Res assgt. count ' || l_ta_resource_assgt_tbl.COUNT;
				pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
			END IF;

			l_index := 0;
			l_previous_elem_version_id := l_ta_wbs_elem_ver_tbl(1);
			l_accum_people_qty := 0;
			l_accum_equip_qty := 0;
			l_accum_mat_item_cost := 0;
			l_accum_fin_elem_cost := 0;

			-- Bug 3974569: Get the budget_version_id for the detination.
			OPEN c_get_bv_and_rbs_id(p_targ_elem_ver_id_tbl(1));
			FETCH c_get_bv_and_rbs_id INTO l_tar_bvid, l_tar_rbs_ver_id;
			CLOSE c_get_bv_and_rbs_id;

			OPEN c_get_bv_and_rbs_id(p_src_elem_ver_id_tbl(1));
			FETCH c_get_bv_and_rbs_id INTO l_src_bvid, l_src_rbs_ver_id;
			CLOSE c_get_bv_and_rbs_id;
			-- \Bug 3974569.
/* moved up
			-- Bug 3951947: get target project's project functional currency code
			OPEN get_proj_currency_code(p_target_project_id);
			FETCH get_proj_currency_code INTO l_tar_projfunc_cur_code;
			CLOSE get_proj_currency_code;
*/
                        -- ER 4127235: Move this outside the loop
                        --  Call Copy Planning Resource only in Copy External
                        --  flow when src and tar projects are different,
                        --  and resource list are the same and are centrally controlled
		        IF p_src_project_id <> p_target_project_id AND
                           p_copy_external_flag = 'Y' AND
                           (l_src_resource_list_id <> l_target_resource_list_id OR
                            l_rl_proj_specific_flag = 'Y') THEN

			  IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
				PA_DEBUG.write(x_module      => L_Module,
					       x_msg         => 'Calling Copy_Planning Resources',
					       x_log_level   => 3);
				PA_DEBUG.write(x_module      => L_Module,
					       x_msg         => 'p_source_resource_list_id: ' || l_src_resource_list_id,
					       x_log_level   => 3);
				PA_DEBUG.write(x_module      => L_Module,
					       x_msg         => 'p_destination_resource_list_id: ' || l_target_resource_list_id,
					       x_log_level   => 3);
				PA_DEBUG.write(x_module      => L_Module,
					       x_msg         => 'p_destination_project_id: ' || p_target_project_id,
					       x_log_level   => 3);
				FOR temp_i IN 1..l_ta_res_mem_id_tbl.COUNT LOOP
					PA_DEBUG.write(x_module      => L_Module,
						       x_msg         => 'p_src_res_list_member_id_tbl(' || temp_i || '): ' || l_ta_res_mem_id_tbl(temp_i),
						       x_log_level   => 3);
				END LOOP;
			  END IF;

 			  -- Call Copy Planning Resource API to get a valid
			  -- rlm id in the target project
			  Pa_Planning_Resource_Pvt.Copy_Planning_Resources(
						p_source_resource_list_id       => l_src_resource_list_id,
						p_destination_resource_list_id  => l_target_resource_list_id,
						p_destination_project_id        => p_target_project_id,
						p_src_res_list_member_id_tbl    => l_ta_res_mem_id_tbl,
						x_dest_res_list_member_id_tbl   => l_copy_res_mem_id_tbl);

                        END IF; -- IF p_src_project_id <> p_target_project_id


			FOR i in 1..l_ta_resource_assgt_tbl.COUNT+1 LOOP

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
					PA_DEBUG.write(x_module      => L_Module,
					               x_msg         => 'Iteration through assignments: ' || i,
					               x_log_level   => 3);
				END IF;


                                -- Bug 4492493: Check if Progress Rollup is required on COPY

                                -- Bug 4492493: Check if Progress Rollup is required on COPY
                                -- Bug Fix 5632835.
                                -- The following unconditional code is causing the subscript beyond count issue.
                                -- As per sheenie we need to skip this for the count+1 iteration, hence adding an additional if condition.

                              IF i <> l_ta_resource_assgt_tbl.COUNT+1 THEN
                                IF g_require_progress_rollup = 'N' AND
                                   l_progress_rollup_required = 'Y' AND
                                   l_ta_total_plan_quantity_tbl(i) IS NOT NULL AND
                                   l_ta_total_plan_quantity_tbl(i) > 0 THEN
                                  g_require_progress_rollup := 'Y';
                                END IF;
                                -- End of Bug 4492493
                              END IF;
                              -- End of Bug Fix 5632835.


				-- Initialize accum values per task
				IF i = l_ta_resource_assgt_tbl.COUNT+1 OR
				   l_previous_elem_version_id <> l_ta_wbs_elem_ver_tbl(i) THEN

					IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
					   PA_DEBUG.write(x_module      => L_Module,
					                  x_msg         => 'End of Previous Task',
					                  x_log_level   => 3);
					END IF;

					-- creation or update of resource class TA
					IF l_accum_people_qty > 0 THEN

						IF l_people_class_index <> -999 THEN

							IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'l_people_class_index: ' || l_people_class_index,
								               x_log_level   => 3);
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'l_accum_people_qty: ' || l_accum_people_qty,
								               x_log_level   => 3);
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'x_resource_rec_qty: ' || x_resource_rec_tbl(l_people_class_index).total_quantity,
								               x_log_level   => 3);
							END IF;

							x_resource_rec_tbl(l_people_class_index).total_quantity := x_resource_rec_tbl(l_people_class_index).total_quantity + nvl(l_accum_people_qty,0);

							IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'x_resource_rec_qty: ' || x_resource_rec_tbl(l_people_class_index).total_quantity,
								               x_log_level   => 3);
							END IF;

						ELSE -- l_people_class_index <> -999

							IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'Calling get_class_member_id function for PEOPLE',
								               x_log_level   => 3);
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'l_target_resource_list_id: ' || l_target_resource_list_id,
								               x_log_level   => 3);
							END IF;

							l_class_rlm_id := PA_PLANNING_RESOURCE_UTILS.get_class_member_id(
                                                                    p_project_id          => p_target_project_id,
                                                                    p_resource_list_id    => l_target_resource_list_id,
                                                                    p_resource_class_code => 'PEOPLE');

							IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'l_class_rlm_id: ' || l_class_rlm_id,
								               x_log_level   => 3);
							END IF;

							l_add_cnt := l_add_cnt +1;
							l_add_res_list_member_id_tbl.extend(1);
							l_add_res_list_member_id_tbl(l_add_cnt) := l_class_rlm_id;



                                                        FOR l IN 1 .. p_src_elem_ver_id_tbl.COUNT LOOP
							  l_element_version_index := l;
						          EXIT WHEN p_src_elem_ver_id_tbl(l_element_version_index) = l_previous_elem_version_id;
						        END LOOP;

						        l_add_elem_version_id_tbl.extend(1);
						        l_add_elem_version_id_tbl(l_add_cnt) := p_targ_elem_ver_id_tbl(l_element_version_index);

							l_add_qty_tbl.extend(1);
							l_add_qty_tbl(l_add_cnt) :=  l_accum_people_qty;
							l_add_raw_cost_tbl.extend(1);
							l_add_raw_cost_tbl(l_add_cnt) := NULL;
                                                        -- Bug 3951947 get the project functional currency code
							l_add_projfunc_cur_code_tbl.extend(1);
							l_add_projfunc_cur_code_tbl(l_add_cnt) := l_tar_projfunc_cur_code;

						END IF; -- l_people_class_index <> -999

					END IF; -- l_accum_people_qty > 0

					IF l_accum_equip_qty > 0 THEN

						IF l_equip_class_index <> -999 THEN

							x_resource_rec_tbl(l_equip_class_index).total_quantity := x_resource_rec_tbl(l_equip_class_index).total_quantity + nvl(l_accum_equip_qty,0);

						ELSE

							IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'Calling get_class_member_id function for EQUIPEMENT',
								               x_log_level   => 3);
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'l_target_resource_list_id: ' || l_target_resource_list_id,
								               x_log_level   => 3);
							END IF;

							l_class_rlm_id := PA_PLANNING_RESOURCE_UTILS.get_class_member_id(
				                		p_project_id          => p_target_project_id,
				                		p_resource_list_id    => l_target_resource_list_id,
				                		p_resource_class_code => 'EQUIPMENT');

							IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'l_class_rlm_id: ' || l_class_rlm_id,
								               x_log_level   => 3);
							END IF;

							l_add_cnt := l_add_cnt +1;
							l_add_res_list_member_id_tbl.extend(1);
							l_add_res_list_member_id_tbl(l_add_cnt) := l_class_rlm_id;
                                                        FOR l IN 1 .. p_src_elem_ver_id_tbl.COUNT LOOP
							  l_element_version_index := l;
						          EXIT WHEN p_src_elem_ver_id_tbl(l_element_version_index) = l_previous_elem_version_id;
						        END LOOP;

						        l_add_elem_version_id_tbl.extend(1);
						        l_add_elem_version_id_tbl(l_add_cnt) := p_targ_elem_ver_id_tbl(l_element_version_index);

							l_add_qty_tbl.extend(1);
							l_add_qty_tbl(l_add_cnt) :=  l_accum_equip_qty;
							l_add_raw_cost_tbl.extend(1);
							l_add_raw_cost_tbl(l_add_cnt) :=  NULL;
                                                        -- Bug 3951947 get the project functional currency code
							l_add_projfunc_cur_code_tbl.extend(1);
							l_add_projfunc_cur_code_tbl(l_add_cnt) := l_tar_projfunc_cur_code;

						END IF; -- l_equip_class_index <> -999

					END IF; -- l_accum_equip_qty > 0

					IF l_accum_mat_item_cost > 0 THEN

						IF l_target_workplan_costs_flag <> 'N' THEN

							IF l_mat_item_class_index <> -999 THEN

								OPEN get_txn_currency_code(x_resource_rec_tbl(l_mat_item_class_index).resource_assignment_id);
								FETCH get_txn_currency_code INTO l_txn_curr_code;
								CLOSE get_txn_currency_code;

								-- Get exchange rate to convert project_currency to txn_currency
								pa_progress_utils.convert_currency_amounts(
									p_api_version             => l_api_version,
									p_init_msg_list           => l_init_msg_list,
									p_commit                  => l_commit,
									p_validate_only           => l_validate_only,
									p_validation_level        => l_validation_level,
									p_calling_module          => l_calling_module,
									p_debug_mode              => l_debug_mode,
									p_max_msg_count           => l_max_msg_count,
									p_project_id              => p_src_project_id,
                                                                        p_calling_mode            => 'PLAN_RATES', -- 4372462
                                                                        p_budget_version_id       => l_src_bvid, -- 4372462
                                                                        p_res_assignment_id       => -999, -- 4372462
									p_task_id                 => x_resource_rec_tbl(l_mat_item_class_index).task_id,
									p_as_of_date              => trunc(sysdate),
									p_txn_cost                => 0,
									p_txn_curr_code           => l_txn_curr_code,
									p_structure_version_id    => x_resource_rec_tbl(l_mat_item_class_index).structure_version_id,
									p_project_curr_code       => l_project_curr_code,
									p_project_rate_type       => l_project_rate_type,
									p_project_rate_date       => l_project_rate_date,
									p_project_exch_rate       => l_project_exch_rate,
									p_project_raw_cost        => l_project_raw_cost,
									p_projfunc_curr_code      => l_projfunc_curr_code,
									p_projfunc_cost_rate_type => l_projfunc_cost_rate_type,
									p_projfunc_cost_rate_date => l_projfunc_cost_rate_date,
									p_projfunc_cost_exch_rate => l_projfunc_cost_exch_rate,
									p_projfunc_raw_cost       => l_projfunc_raw_cost,
									x_return_status           => x_return_status,
									x_msg_count               => l_msg_count,
									x_msg_data                => l_msg_data);

								IF x_return_status = FND_API.G_RET_STS_ERROR THEN
									RAISE FND_API.G_EXC_ERROR;
								ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;

								IF l_txn_curr_code = l_projfunc_curr_code THEN
									l_projfunc_cost_exch_rate := 1;
								END IF;

								IF nvl(l_projfunc_cost_exch_rate,0) <> 0 THEN
									l_txn_mat_item_cost := nvl(l_accum_mat_item_cost,0) / l_projfunc_cost_exch_rate;
								END IF;


								x_resource_rec_tbl(l_mat_item_class_index).total_raw_cost := x_resource_rec_tbl(l_mat_item_class_index).total_raw_cost + nvl(l_txn_mat_item_cost,0);

							ELSE -- l_mat_item_class_index <> -999

								IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
									PA_DEBUG.write(x_module      => L_Module,
									               x_msg         => 'Calling get_class_member_id function for MATERIAL ITEM',
									               x_log_level   => 3);
									PA_DEBUG.write(x_module      => L_Module,
									               x_msg         => 'l_target_resource_list_id: ' || l_target_resource_list_id,
									               x_log_level   => 3);
								END IF;
								l_class_rlm_id := PA_PLANNING_RESOURCE_UTILS.get_class_member_id(
									p_project_id          => p_target_project_id,
									p_resource_list_id    => l_target_resource_list_id,
									p_resource_class_code => 'MATERIAL_ITEMS');

								IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
									PA_DEBUG.write(x_module      => L_Module,
									               x_msg         => 'l_class_rlm_id: ' || l_class_rlm_id,
									               x_log_level   => 3);
								END IF;
/* moved up
								OPEN get_proj_currency_code(p_src_project_id);
								FETCH get_proj_currency_code INTO l_src_project_curr_code;
								CLOSE get_proj_currency_code;
*/
								-- Get exchange rate to convert source project_currency to target project currency
								pa_progress_utils.convert_currency_amounts(
									p_api_version             => l_api_version,
									p_init_msg_list           => l_init_msg_list,
									p_commit                  => l_commit,
									p_validate_only           => l_validate_only,
									p_validation_level        => l_validation_level,
									p_calling_module          => l_calling_module,
									p_debug_mode              => l_debug_mode,
									p_max_msg_count           => l_max_msg_count,
									p_project_id              => p_target_project_id,
                                                                        p_calling_mode            => 'PLAN_RATES', -- 4372462
                                                                        p_budget_version_id       => l_tar_bvid, -- 4372462
                                                                        p_res_assignment_id       => -999, -- 4372462
									p_task_id                 => null,
									p_as_of_date              => trunc(sysdate),
									p_txn_cost                => 0,
									p_txn_curr_code           => l_src_project_curr_code,
									p_structure_version_id    => null,
									p_project_curr_code       => l_project_curr_code,
									p_project_rate_type       => l_project_rate_type,
									p_project_rate_date       => l_project_rate_date,
									p_project_exch_rate       => l_project_exch_rate,
									p_project_raw_cost        => l_project_raw_cost,
									p_projfunc_curr_code      => l_projfunc_curr_code,
									p_projfunc_cost_rate_type => l_projfunc_cost_rate_type,
									p_projfunc_cost_rate_date => l_projfunc_cost_rate_date,
									p_projfunc_cost_exch_rate => l_projfunc_cost_exch_rate,
									p_projfunc_raw_cost       => l_projfunc_raw_cost,
									x_return_status           => x_return_status,
									x_msg_count               => l_msg_count,
									x_msg_data                => l_msg_data);

								IF x_return_status = FND_API.G_RET_STS_ERROR THEN
									RAISE FND_API.G_EXC_ERROR;
								ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;

								-- Bug 3951947 Should compare the source and target
								--  projects' project currencies
								IF l_src_project_curr_code = l_projfunc_curr_code THEN
									l_projfunc_cost_exch_rate := 1;
								END IF;

								IF nvl(l_projfunc_cost_exch_rate,0) <> 0 THEN
									l_txn_mat_item_cost := nvl(l_accum_mat_item_cost,0) / l_projfunc_cost_exch_rate;
								END IF;


								l_add_cnt := l_add_cnt +1;
								l_add_res_list_member_id_tbl.extend(1);
								l_add_res_list_member_id_tbl(l_add_cnt) := l_class_rlm_id;

                                                                FOR l IN 1 .. p_src_elem_ver_id_tbl.COUNT LOOP
							          l_element_version_index := l;
						                  EXIT WHEN p_src_elem_ver_id_tbl(l_element_version_index) = l_previous_elem_version_id;
						                END LOOP;

						                l_add_elem_version_id_tbl.extend(1);
						                l_add_elem_version_id_tbl(l_add_cnt) := p_targ_elem_ver_id_tbl(l_element_version_index);

								l_add_qty_tbl.extend(1);
								l_add_qty_tbl(l_add_cnt) :=  NULL;
								l_add_raw_cost_tbl.extend(1);
								l_add_raw_cost_tbl(l_add_cnt) :=  nvl(l_txn_mat_item_cost,0);
								-- Bug 3951947 get the project functional currency code
								l_add_projfunc_cur_code_tbl.extend(1);
								l_add_projfunc_cur_code_tbl(l_add_cnt) := l_tar_projfunc_cur_code;

							END IF; -- l_mat_item_class_index <> -999

						END IF; -- l_target_workplan_costs_flag <> 'N'

					END IF; -- l_accum_mat_item_cost > 0

					IF l_accum_fin_elem_cost > 0 THEN

						IF l_target_workplan_costs_flag <> 'N' THEN

							IF l_fin_elem_class_index <> -999 THEN

								OPEN get_txn_currency_code(x_resource_rec_tbl(l_fin_elem_class_index).resource_assignment_id);
								FETCH get_txn_currency_code INTO l_txn_curr_code;
								CLOSE get_txn_currency_code;

								-- Get exchange rate to convert project_currency to txn_currency
								pa_progress_utils.convert_currency_amounts(
									p_api_version             => l_api_version,
									p_init_msg_list           => l_init_msg_list,
									p_commit                  => l_commit,
									p_validate_only           => l_validate_only,
									p_validation_level        => l_validation_level,
									p_calling_module          => l_calling_module,
									p_debug_mode              => l_debug_mode,
									p_max_msg_count           => l_max_msg_count,
									p_project_id              => p_src_project_id,
                                                                        p_calling_mode            => 'PLAN_RATES', -- 4372462
                                                                        p_budget_version_id       => l_src_bvid, -- 4372462
                                                                        p_res_assignment_id       => -999, -- 4372462
									p_task_id                 => x_resource_rec_tbl(l_fin_elem_class_index).task_id,
									p_as_of_date              => trunc(sysdate),
									p_txn_cost                => 0,
									p_txn_curr_code           => l_txn_curr_code,
									p_structure_version_id    => x_resource_rec_tbl(l_fin_elem_class_index).structure_version_id,
									p_project_curr_code       => l_project_curr_code,
									p_project_rate_type       => l_project_rate_type,
									p_project_rate_date       => l_project_rate_date,
									p_project_exch_rate       => l_project_exch_rate,
									p_project_raw_cost        => l_project_raw_cost,
									p_projfunc_curr_code      => l_projfunc_curr_code,
									p_projfunc_cost_rate_type => l_projfunc_cost_rate_type,
									p_projfunc_cost_rate_date => l_projfunc_cost_rate_date,
									p_projfunc_cost_exch_rate => l_projfunc_cost_exch_rate,
									p_projfunc_raw_cost       => l_projfunc_raw_cost,
									x_return_status           => x_return_status,
									x_msg_count               => l_msg_count,
									x_msg_data                => l_msg_data);

								IF x_return_status = FND_API.G_RET_STS_ERROR THEN
									RAISE FND_API.G_EXC_ERROR;
								ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;

								IF l_txn_curr_code = l_projfunc_curr_code THEN
									l_projfunc_cost_exch_rate := 1;
								END IF;

								IF nvl(l_projfunc_cost_exch_rate,0) <> 0 THEN
									l_txn_fin_elem_cost := nvl(l_accum_fin_elem_cost,0) / l_projfunc_cost_exch_rate;
								END IF;

								x_resource_rec_tbl(l_fin_elem_class_index).total_raw_cost := x_resource_rec_tbl(l_fin_elem_class_index).total_raw_cost + nvl(l_txn_fin_elem_cost,0);

							ELSE -- l_fin_elem_class_index <> -999

								IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
									PA_DEBUG.write(x_module      => L_Module,
												   x_msg         => 'Calling get_class_member_id function for FINANCIAL ELEMENT',
												   x_log_level   => 3);
									PA_DEBUG.write(x_module      => L_Module,
									               x_msg         => 'l_target_resource_list_id: ' || l_target_resource_list_id,
									               x_log_level   => 3);
								END IF;

								l_class_rlm_id := PA_PLANNING_RESOURCE_UTILS.get_class_member_id(
									p_project_id          => p_target_project_id,
									p_resource_list_id    => l_target_resource_list_id,
									p_resource_class_code => 'FINANCIAL_ELEMENTS'); -- Bug 3800726

								IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
									PA_DEBUG.write(x_module      => L_Module,
									               x_msg         => 'l_class_rlm_id: ' || l_class_rlm_id,
									               x_log_level   => 3);
								END IF;
/* moved up
								OPEN get_proj_currency_code(p_src_project_id);
								FETCH get_proj_currency_code INTO l_src_project_curr_code;
								CLOSE get_proj_currency_code;
*/
								-- Get exchange rate to convert source project_currency to target project currency
								pa_progress_utils.convert_currency_amounts(
									p_api_version             => l_api_version,
									p_init_msg_list           => l_init_msg_list,
									p_commit                  => l_commit,
									p_validate_only           => l_validate_only,
									p_validation_level        => l_validation_level,
									p_calling_module          => l_calling_module,
									p_debug_mode              => l_debug_mode,
									p_max_msg_count           => l_max_msg_count,
									p_project_id              => p_target_project_id,
                                                                        p_calling_mode            => 'PLAN_RATES', -- 4372462
                                                                        p_budget_version_id       => l_tar_bvid, -- 4372462
                                                                        p_res_assignment_id       => -999, -- 4372462
									p_task_id                 => null,
									p_as_of_date              => trunc(sysdate),
									p_txn_cost                => 0,
									p_txn_curr_code           => l_src_project_curr_code,
									p_structure_version_id    => null,
									p_project_curr_code       => l_project_curr_code,
									p_project_rate_type       => l_project_rate_type,
									p_project_rate_date       => l_project_rate_date,
									p_project_exch_rate       => l_project_exch_rate,
									p_project_raw_cost        => l_project_raw_cost,
									p_projfunc_curr_code      => l_projfunc_curr_code,
									p_projfunc_cost_rate_type => l_projfunc_cost_rate_type,
									p_projfunc_cost_rate_date => l_projfunc_cost_rate_date,
									p_projfunc_cost_exch_rate => l_projfunc_cost_exch_rate,
									p_projfunc_raw_cost       => l_projfunc_raw_cost,
									x_return_status           => x_return_status,
									x_msg_count               => l_msg_count,
									x_msg_data                => l_msg_data);

								IF x_return_status = FND_API.G_RET_STS_ERROR THEN
									RAISE FND_API.G_EXC_ERROR;
								ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
									RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
								END IF;

								-- Bug 3951947 Should compare the source and target
								--  projects' project currencies
								IF l_src_project_curr_code = l_projfunc_curr_code THEN
									l_projfunc_cost_exch_rate := 1;
								END IF;

								IF nvl(l_projfunc_cost_exch_rate,0) <> 0 THEN
									l_txn_fin_elem_cost := nvl(l_accum_fin_elem_cost,0) / l_projfunc_cost_exch_rate;
								END IF;


								l_add_cnt := l_add_cnt +1;
								l_add_res_list_member_id_tbl.extend(1);
								l_add_res_list_member_id_tbl(l_add_cnt) := l_class_rlm_id;

                                                                FOR l IN 1 .. p_src_elem_ver_id_tbl.COUNT LOOP
							          l_element_version_index := l;
						                  EXIT WHEN p_src_elem_ver_id_tbl(l_element_version_index) = l_previous_elem_version_id;
						                END LOOP;

						                l_add_elem_version_id_tbl.extend(1);
						                l_add_elem_version_id_tbl(l_add_cnt) := p_targ_elem_ver_id_tbl(l_element_version_index);

								l_add_qty_tbl.extend(1);
								l_add_qty_tbl(l_add_cnt) :=  NULL;
								l_add_raw_cost_tbl.extend(1);
								l_add_raw_cost_tbl(l_add_cnt) :=  nvl(l_txn_fin_elem_cost,0);
                                                                -- Bug 3951947 get the project functional currency code
							        l_add_projfunc_cur_code_tbl.extend(1);
							        l_add_projfunc_cur_code_tbl(l_add_cnt) := l_tar_projfunc_cur_code;


							END IF; -- l_fin_elem_class_index <> -999

						END IF; -- l_target_workplan_costs_flag <> 'N'

					END IF; -- l_accum_fin_elem_cost > 0

					-- initialize accum values and indexes
					l_accum_people_qty := 0;
					l_accum_equip_qty := 0;
					l_accum_mat_item_cost := 0;
					l_accum_fin_elem_cost := 0;
					l_people_class_index := -999;
					l_equip_class_index := -999;
					l_mat_item_class_index := -999;
					l_fin_elem_class_index := -999;

					-- Bug 3831695, 3834509: update elem version id in the loop
					IF i < l_ta_resource_assgt_tbl.COUNT+1 THEN
						l_previous_elem_version_id := l_ta_wbs_elem_ver_tbl(i);
					END IF;

				END IF; -- i = l_ta_resource_assgt_tbl.COUNT+1 OR l_previous_elem_version_id <> l_ta_wbs_elem_ver_tbl(i)

   				EXIT WHEN i = l_ta_resource_assgt_tbl.COUNT+1;

				--Initialize every time..
				l_c_res_mem_id_tbl := system.pa_num_tbl_type();

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
					pa_debug.g_err_stage:='TA: ' || L_FuncProc || ' b4  copy planning resources.';
					pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;

				-- CASE 1: Copy External
				--   call Copy_Planning_Resource
				-- CASE 2: Copy Project flow and RLs are project specific
				--   do not call Copy_Planning_Resource but return back the re-derived
				--   rlm ids from the above SQL
				-- CASE 3: Copy Project flow and RLs are centrally controlled OR
				--         Copy Task flow within the same project
				--   return the same source rlm ids

				-- CASE 1: Copy External
				IF p_src_project_id <> p_target_project_id AND p_copy_external_flag = 'Y' THEN

					IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN

						PA_DEBUG.write(x_module      => L_Module,
						               x_msg         => 'p_source_resource_list_id: ' || l_src_resource_list_id,
						               x_log_level   => 3);
						PA_DEBUG.write(x_module      => L_Module,
						               x_msg         => 'p_destination_resource_list_id: ' || l_target_resource_list_id,
						               x_log_level   => 3);
						PA_DEBUG.write(x_module      => L_Module,
						               x_msg         => 'p_destination_project_id: ' || p_target_project_id,
						               x_log_level   => 3);
					END IF;

                                        IF l_src_resource_list_id = l_target_resource_list_id AND
                                           l_rl_proj_specific_flag = 'N' THEN

					   -- if source and target resource list are the same
                                           -- and if they are both centrally controlled
                                           -- just return the same rlm id
					   l_c_res_mem_id_tbl.extend(1);
					   l_c_res_mem_id_tbl(1) := l_ta_res_mem_id_tbl(i);

                                        ELSE

                                         --  ER 4127235: copy planning resource is called outside the loop
                                         l_c_res_mem_id_tbl.extend(1);
                                         l_c_res_mem_id_tbl(1) := l_copy_res_mem_id_tbl(i);

                                        END IF;

				-- CASE 2: Copy Project flow and RLs are project specific
				ELSIF p_src_project_id <> p_target_project_id
					  AND p_copy_external_flag <> 'Y'
					  AND l_rl_proj_specific_flag = 'Y' THEN

					l_c_res_mem_id_tbl.extend(1);
					l_c_res_mem_id_tbl(1) := l_ta_tar_res_mem_id_tbl(i);

				-- CASE 3: Copy Project flow and RLs are centrally controlled OR
				ELSE -- p_src_project_id <> p_target_project_id

					-- if copying to and from the same project, just
					-- use the same rlm from the target assignment
					l_c_res_mem_id_tbl.extend(1);
					l_c_res_mem_id_tbl(1) := l_ta_res_mem_id_tbl(i);

				END IF; -- p_src_project_id <> p_target_project_id

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN

					pa_debug.g_err_stage:='TA: ' || L_FuncProc || ' a4 calling copy planning resources.';
					pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);

					FOR temp_i IN 1..l_c_res_mem_id_tbl.COUNT LOOP
						PA_DEBUG.write(x_module      => L_Module,
						               x_msg         => 'l_c_res_mem_id_tbl(' || temp_i || '): ' || l_c_res_mem_id_tbl(temp_i),
						               x_log_level   => 3);
					END LOOP;

				END IF;

				IF l_c_res_mem_id_tbl.exists(1) and l_c_res_mem_id_tbl(1) IS NOT NULL THEN

					l_index := l_index + 1;
					x_resource_rec_tbl(l_index).resource_assignment_id  := l_ta_resource_assgt_tbl(i);
					l_published := 'N';

					IF l_ta_res_type_code_tbl(i) = 'RESOURCE_CLASS' AND
					   l_ta_resource_class_flag_tbl(i) = 'Y' THEN

						IF l_ta_resource_class_code_tbl(i) = 'PEOPLE' THEN
							l_people_class_index := l_index;
						ELSIF l_ta_resource_class_code_tbl(i) = 'EQUIPMENT' THEN
							l_equip_class_index := l_index;
						ELSIF l_ta_resource_class_code_tbl(i) = 'MATERIAL_ITEMS' THEN
							l_mat_item_class_index := l_index;
						ELSE
							l_fin_elem_class_index := l_index;
						END IF;

					END IF;

					-- Bug 3745338, disallow copy of TR if the resource list member has changed.
					-- Bug 4097749 - Do not copy project_assignment_id if copying to another project,
					IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
						pa_debug.g_err_stage:='TA: ' || L_FuncProc || 'l_ta_tr_res_list_member_id_tbl(i): ' || l_ta_tr_res_list_member_id_tbl(i);
						pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
						pa_debug.g_err_stage:='TA: ' || L_FuncProc || 'l_c_res_mem_id_tbl(1): ' || l_c_res_mem_id_tbl(1);
						pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
					END IF;

					IF l_ta_tr_res_list_member_id_tbl(i) <> l_c_res_mem_id_tbl(1) OR
					   p_src_project_id <> p_target_project_id THEN

						x_resource_rec_tbl(l_index).project_assignment_id := -1;
						IF l_ta_role_in_format_flag_tbl(i) = 'N' THEN
							x_resource_rec_tbl(l_index).named_role := NULL;
						ELSE
							x_resource_rec_tbl(l_index).named_role := l_ta_named_role_tbl(i);
						END IF;

					ELSE

						x_resource_rec_tbl(l_index).project_assignment_id := l_ta_project_assgt_tbl(i);
						x_resource_rec_tbl(l_index).named_role := l_ta_named_role_tbl(i);

					END IF;

					-- Bug 3850848
					-- When copy from another project, actuals are not copied and therefore
					--  we are defaulted planning dates back to scheduled dates
					IF p_src_project_id <> p_target_project_id THEN
						x_resource_rec_tbl(l_index).planning_start_date     := l_ta_schedule_start_tbl(i);
						x_resource_rec_tbl(l_index).planning_end_date       := l_ta_schedule_end_tbl(i);
					ELSE
						x_resource_rec_tbl(l_index).planning_start_date     := l_ta_planning_start_tbl(i);
						x_resource_rec_tbl(l_index).planning_end_date       := l_ta_planning_end_tbl(i);
					END IF;

					x_resource_rec_tbl(l_index).schedule_start_date     := l_ta_schedule_start_tbl(i);
					x_resource_rec_tbl(l_index).schedule_end_date       := l_ta_schedule_end_tbl(i);
					x_resource_rec_tbl(l_index).resource_list_member_id := l_c_res_mem_id_tbl(1);

					IF  l_ta_rate_based_flag_tbl(i) = 'N' THEN
						x_resource_rec_tbl(l_index).total_quantity := l_ta_total_plan_quantity_tbl(i);
						x_resource_rec_tbl(l_index).total_raw_cost := l_ta_total_plan_raw_cost_tbl(i);
					ELSE
						x_resource_rec_tbl(l_index).total_quantity := l_ta_total_plan_quantity_tbl(i);
					END IF;

					-- Bug 4646016 : In Copy Assignments flow from one version to other
					-- we should make plan as 0 if it is -ve
					-- Begin
					IF nvl(PA_TASK_ASSIGNMENT_UTILS.g_process_flow,'XYZ') <> 'PUBLISH' THEN
						IF  l_ta_rate_based_flag_tbl(i) = 'N' THEN
							IF x_resource_rec_tbl(l_index).total_quantity < 0  THEN
								x_resource_rec_tbl(l_index).total_quantity := 0;
								x_resource_rec_tbl(l_index).total_raw_cost := 0;
								x_calculate_flag := 'Y';
							END IF;
						ELSE
							IF x_resource_rec_tbl(l_index).total_quantity < 0 THEN
								x_resource_rec_tbl(l_index).total_quantity := 0;
								x_calculate_flag := 'Y';
							END IF;
						END IF;
					END IF;
					-- End

					x_resource_rec_tbl(l_index).task_id := l_ta_task_id_tbl(i);
					x_resource_rec_tbl(l_index).structure_version_id := l_ta_structure_version_tbl(i);

				ELSE -- IF rlm id is NULL
					IF l_ta_resource_class_code_tbl(i) = 'PEOPLE' THEN
						l_accum_people_qty := l_accum_people_qty + nvl(l_ta_total_plan_quantity_tbl(i),0);
					ELSIF l_ta_resource_class_code_tbl(i) = 'EQUIPMENT' THEN
						l_accum_equip_qty := l_accum_equip_qty + nvl(l_ta_total_plan_quantity_tbl(i),0);
					ELSIF l_ta_resource_class_code_tbl(i) = 'MATERIAL_ITEMS' THEN
						l_accum_mat_item_cost := l_accum_mat_item_cost + nvl(l_ta_total_proj_raw_cost_tbl(i),0);
					ELSE
						l_accum_fin_elem_cost := l_accum_fin_elem_cost + nvl(l_ta_total_proj_raw_cost_tbl(i),0);
					END IF;

				END IF; -- IF l_c_res_mem_id_tbl.exists(1) and l_c_res_mem_id_tbl(1) IS NOT NULL THEN

			END LOOP; -- FOR i in 1..l_ta_resource_assgt_tbl.COUNT+1 LOOP


			IF p_src_project_id <> p_target_project_id THEN

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
					pa_debug.g_err_stage:='TA: ' || L_FuncProc || ' Src project N.E. to target ' ;
					pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;


				--Get the task scheduled dates of all tasks in p_src_version_id_tbl
				--Assign the dates to p_src_start_tbl, p_src_end_tbl
				-- Bug 3850848
				OPEN c_get_src_sched_dates;
				FETCH c_get_src_sched_dates BULK COLLECT INTO l_t_src_elem_ver_id_tbl, l_t_src_start_tbl, l_t_src_end_tbl;
				CLOSE c_get_src_sched_dates;

				OPEN c_get_targ_sched_dates;
				FETCH c_get_targ_sched_dates BULK COLLECT INTO l_t_target_elem_ver_id_tbl, l_t_target_start_tbl, l_t_target_end_tbl;
				CLOSE c_get_targ_sched_dates;

				-- Bug 3850848
				IF p_src_elem_ver_id_tbl.COUNT > 0 THEN
					-- Bug3820625
					l_adj_src_t_start_tbl.extend(p_src_elem_ver_id_tbl.COUNT);
					l_adj_src_t_end_tbl.extend(p_src_elem_ver_id_tbl.COUNT);
					FOR src_index IN 1..p_src_elem_ver_id_tbl.COUNT LOOP
						FOR src_date_index IN 1..l_t_src_elem_ver_id_tbl.COUNT LOOP
							IF p_src_elem_ver_id_tbl(src_index) = l_t_src_elem_ver_id_tbl(src_date_index) THEN
								-- Bug3820625
								--l_adj_src_t_start_tbl.extend(1);
								--l_adj_src_t_end_tbl.extend(1);
								l_adj_src_t_start_tbl(src_index) := l_t_src_start_tbl(src_date_index);
								l_adj_src_t_end_tbl(src_index) := l_t_src_end_tbl(src_date_index);
							END IF;
						END LOOP; -- FOR src_date_index IN 1..l_t_src_elem_ver_id_tbl.COUNT LOOP
					END LOOP; --FOR src_index IN 1..p_src_elem_ver_id_tbl.COUNT LOOP
				END IF; -- IF p_src_elem_ver_id_tbl.COUNT > 0 THEN

				IF p_targ_elem_ver_id_tbl.COUNT > 0 THEN
					-- Bug3820625
					l_adj_tar_t_start_tbl.extend(p_targ_elem_ver_id_tbl.COUNT);
					l_adj_tar_t_end_tbl.extend(p_targ_elem_ver_id_tbl.COUNT);
					FOR target_index IN 1..p_targ_elem_ver_id_tbl.COUNT LOOP
						FOR target_date_index IN 1..l_t_target_elem_ver_id_tbl.COUNT LOOP
							IF p_targ_elem_ver_id_tbl(target_index) = l_t_target_elem_ver_id_tbl(target_date_index) THEN
							-- Bug3820625
							--l_adj_tar_t_start_tbl.extend(1);
							--l_adj_tar_t_end_tbl.extend(1);
							l_adj_tar_t_start_tbl(target_index) := l_t_target_start_tbl(target_date_index);
							l_adj_tar_t_end_tbl(target_index) := l_t_target_end_tbl(target_date_index);
							END IF;
						END LOOP; -- FOR src_date_index IN 1..l_t_src_elem_ver_id_tbl.COUNT LOOP
					END LOOP; --FOR src_index IN 1..p_src_elem_ver_id_tbl.COUNT LOOP
				END IF; -- IF p_src_elem_ver_id_tbl.COUNT > 0 THEN
				-- End of Bug 3850848

			END IF; -- IF p_src_project_id <> p_target_project_id THEN


			IF ( l_adj_src_t_start_tbl.COUNT > 0 AND l_adj_tar_t_start_tbl.COUNT > 0 ) OR
			   ( l_adj_src_t_start_tbl.COUNT > 0 AND l_adj_tar_t_end_tbl.COUNT > 0 ) THEN

				FOR k in 1..l_adj_src_t_start_tbl.COUNT LOOP

					IF l_adj_src_t_start_tbl(k) <> l_adj_tar_t_start_tbl(k) OR
					   l_adj_src_t_end_tbl(k) <> l_adj_tar_t_end_tbl(k) THEN


						IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
							pa_debug.g_err_stage:='TA: ' || L_FuncProc || ' adjusting dates here ' ;
							pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
						END IF;

						x_calculate_flag := 'Y';


                                                -- Clear pa_copy_asgmt_temp before calling Adjust_Asgmt_Dates
                                                -- since this temp table is also being used.
                                                DELETE pa_copy_asgmts_temp;

						Adjust_Asgmt_Dates(
							p_context                => 'COPY',
							p_element_version_id     => p_src_elem_ver_id_tbl(k),
							p_old_task_sch_start     => l_adj_src_t_start_tbl(k),
							p_new_task_sch_start     => l_adj_tar_t_start_tbl(k),
							p_new_task_sch_finish    => l_adj_tar_t_end_tbl(k),
							x_res_assignment_id_tbl  => l_c_resource_assgt_tbl,
							x_planning_start_tbl     => l_c_schedule_start_tbl,
							x_planning_end_tbl       => l_c_schedule_end_tbl,
							x_return_status          => x_return_status);

						IF x_return_status = FND_API.G_RET_STS_ERROR THEN
							RAISE FND_API.G_EXC_ERROR;
						ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
							RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
						END IF;

						IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
							pa_debug.g_err_stage:= 'TA: ' || L_FuncProc || ' Returned count on adjust: ' || l_c_resource_assgt_tbl.COUNT ;
							pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
						END IF;

						FOR i in 1..x_resource_rec_tbl.COUNT LOOP

							FOR j in 1..l_c_resource_assgt_tbl.COUNT LOOP

								IF x_resource_rec_tbl(i).resource_assignment_id = l_c_resource_assgt_tbl(j) THEN

									x_resource_rec_tbl(i).project_assignment_id  := -1;
									-- IB2 Unplanned Actual changes
									x_resource_rec_tbl(i).schedule_start_date     := l_c_schedule_start_tbl(j);
									x_resource_rec_tbl(i).schedule_end_date := l_c_schedule_end_tbl(j);
									-- Bug 3850848
									-- make planning dates equal to scheduled dates
									x_resource_rec_tbl(i).planning_start_date := l_c_schedule_start_tbl(j);
									x_resource_rec_tbl(i).planning_end_date := l_c_schedule_end_tbl(j);

									IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
										PA_DEBUG.write(x_module      => L_Module,
										        x_msg         => '1: x_resource_rec_tbl(' || i || ').planning_start_date: ' || x_resource_rec_tbl(i).planning_start_date,
										        x_log_level   => 3);
										PA_DEBUG.write(x_module      => L_Module,
										        x_msg         => '1: x_resource_rec_tbl(' || i || ').planning_end_date: ' || x_resource_rec_tbl(i).planning_end_date,
										        x_log_level   => 3);
									END IF;

								END IF; -- IF x_resource_rec_tbl(i).resource_assignment_id = l_c_resource_assgt_tbl(j) THEN

							END LOOP; -- FOR j in 1..l_c_resource_assgt_tbl.COUNT LOOP

/*
-- Bug 4541039: Task level effort assignment should be treated in the same way

							IF l_ta_display_flag_tbl(i) = 'N' THEN

								-- IB2 Unplanned Actual changes
								x_resource_rec_tbl(i).schedule_start_date := l_adj_tar_t_start_tbl(k);
								x_resource_rec_tbl(i).schedule_end_date := l_adj_tar_t_end_tbl(k);
                                                                x_resource_rec_tbl(i).planning_start_date := l_adj_tar_t_start_tbl(k);
                                                                x_resource_rec_tbl(i).planning_end_date := l_adj_tar_t_end_tbl(k);
                                                                --Bug 4188138
								-- Planning dates should be shifted according to the task dates
								--x_resource_rec_tbl(i).planning_start_date := x_resource_rec_tbl(i).planning_start_date + (l_adj_tar_t_start_tbl(k) - l_adj_src_t_start_tbl(k));
								--x_resource_rec_tbl(i).planning_end_date := x_resource_rec_tbl(i).planning_end_date + (l_adj_tar_t_start_tbl(k) - l_adj_src_t_start_tbl(k));

								IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                                PA_DEBUG.write(x_module      => L_Module,
	                                               x_msg         => '2: l_adj_tar_t_start_tbl(k): ' || l_adj_tar_t_start_tbl(k),
	                                               x_log_level   => 3);
	                                PA_DEBUG.write(x_module      => L_Module,
	                                               x_msg         => '2: l_adj_src_t_start_tbl(k): ' || l_adj_src_t_start_tbl(k),
	                                               x_log_level   => 3);
	                                PA_DEBUG.write(x_module      => L_Module,
	                                               x_msg         => '2: x_resource_rec_tbl(' || i || ').planning_start_date: ' || x_resource_rec_tbl(i).planning_start_date,
	                                               x_log_level   => 3);
	                                PA_DEBUG.write(x_module      => L_Module,
	                                               x_msg         => '2: x_resource_rec_tbl(' || i || ').planning_end_date: ' || x_resource_rec_tbl(i).planning_end_date,
	                                               x_log_level   => 3);
								END IF;

								IF x_resource_rec_tbl(i).planning_start_date > x_resource_rec_tbl(i).schedule_start_date THEN
									x_resource_rec_tbl(i).planning_start_date := x_resource_rec_tbl(i).schedule_start_date;
								END IF;

								IF x_resource_rec_tbl(i).planning_end_date < x_resource_rec_tbl(i).schedule_end_date THEN
									x_resource_rec_tbl(i).planning_end_date := x_resource_rec_tbl(i).schedule_end_date;
								END IF;

								IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	                                PA_DEBUG.write(x_module      => L_Module,
	                                               x_msg         => '3: x_resource_rec_tbl(' || i || ').planning_start_date: ' || x_resource_rec_tbl(i).planning_start_date,
	                                               x_log_level   => 3);
	                                PA_DEBUG.write(x_module      => L_Module,
	                                               x_msg         => '3: x_resource_rec_tbl(' || i || ').planning_end_date: ' || x_resource_rec_tbl(i).planning_end_date,
	                                               x_log_level   => 3);
								END IF;

							END IF; -- IF l_ta_display_flag_tbl(i) = 'N' THEN
-- End of Bug 4541039
*/

						END LOOP; -- FOR i in 1..x_resource_rec_tbl.COUNT LOOP

					END IF; -- l_adj_src_t_*_tbl(k) <> l_adj_tar_t_*_tbl(k)

				END LOOP; -- FOR k in 1..l_t_src_start_tbl.COUNT LOOP

			END IF; -- l_adj_*_t_*_tbl.COUNT > 0

                        -- Bug 4200146: Should call add_planning_transaction once only instead for each task
	                IF l_add_res_list_member_id_tbl.COUNT > 0 THEN


				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
					PA_DEBUG.write(x_module      => L_Module,
						       x_msg         => 'Calling Add_Planning_Transactions',
						       x_log_level   => 3);
					PA_DEBUG.write(x_module      => L_Module,
						       x_msg         => 'p_project_id: ' || p_target_project_id,
						       x_log_level   => 3);
					PA_DEBUG.write(x_module      => L_Module,
						       x_msg         => 'p_budget_version_id: ' || l_target_budget_version_id,
						       x_log_level   => 3);
					PA_DEBUG.write(x_module      => L_Module,
						       x_msg         => 'p_struct_elem_version_id: ' || l_target_structure_version_id,
						       x_log_level   => 3);
					FOR temp_i IN 1..l_add_elem_version_id_tbl.COUNT LOOP

						PA_DEBUG.write(x_module      => L_Module,
							       x_msg         => 'p_task_elem_version_id_tbl(' || temp_i || '): ' || l_add_elem_version_id_tbl(temp_i),
							       x_log_level   => 3);
					END LOOP;
					FOR temp_i IN 1..l_add_res_list_member_id_tbl.COUNT LOOP

								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'p_resource_list_member_id_tbl(' || temp_i || '): ' || l_add_res_list_member_id_tbl(temp_i),
								               x_log_level   => 3);

					END LOOP;
					FOR temp_i IN 1..l_add_qty_tbl.COUNT LOOP

								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'p_quantity_tbl(' || temp_i || '): ' || l_add_qty_tbl(temp_i),
								               x_log_level   => 3);
					END LOOP;
					FOR temp_i IN 1..l_add_raw_cost_tbl.COUNT LOOP
								PA_DEBUG.write(x_module      => L_Module,
								               x_msg         => 'p_raw_cost_tbl(' || temp_i || '): ' || l_add_raw_cost_tbl(temp_i),
								               x_log_level   => 3);
					END LOOP;
				END IF; -- P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3)


                                -- Set this mask flag to prevent PJI rollup
                                PA_TASK_PUB1.G_CALL_PJI_ROLLUP := 'N';

				PA_FP_PLANNING_TRANSACTION_PUB.Add_Planning_Transactions(
							p_context                     => 'TASK_ASSIGNMENT',
                                                        p_one_to_one_mapping_flag     => 'Y',
							p_project_id                  => p_target_project_id,
							p_budget_version_id           => l_target_budget_version_id,
							p_struct_elem_version_id      => l_target_structure_version_id,
							p_task_elem_version_id_tbl    => l_add_elem_version_id_tbl,
							p_resource_list_member_id_tbl => l_add_res_list_member_id_tbl,
							p_quantity_tbl                => l_add_qty_tbl,
							p_raw_cost_tbl                => l_add_raw_cost_tbl,
							-- Bug 3951947 use the project functional currency code
							p_currency_code_tbl           => l_add_projfunc_cur_code_tbl,
							x_return_status               => x_return_status,
							x_msg_count                   => l_msg_count,
							x_msg_data                    => l_msg_data);

                                PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;

				IF x_return_status = FND_API.G_RET_STS_ERROR THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

				IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
					pa_debug.g_err_stage:='TA: ' || L_FuncProc || 'Add_Planning_Transactions return status: ' || x_return_status;
					pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
				END IF;
			END IF; -- IF l_add_res_list_member_id_tbl.COUNT > 0 THEN
                        -- End of Bug 4200146

			-- Bug 3974569.
			IF (p_copy_external_flag = 'Y') AND
			   (l_tar_rbs_ver_id IS NOT NULL) AND -- Bug 4043709
			   ((l_src_rbs_ver_id <> l_tar_rbs_ver_id) OR (l_src_resource_list_id <> l_target_resource_list_id)) THEN

				x_rbs_diff_flag := 'Y';

				PA_RLMI_RBS_MAP_PUB.Map_Rlmi_Rbs(
					p_budget_version_id           => l_tar_bvid,
					p_resource_list_id            => l_target_resource_list_id,
					p_rbs_version_id              => l_tar_rbs_ver_id,
					p_calling_process             => 'RBS_REFRESH',
					p_calling_context             => 'PLSQL',
					p_process_code                => 'RBS_MAP',
					p_calling_mode                => 'PLSQL_TABLE',
					p_init_msg_list_flag          => 'N',
					p_commit_flag                 => 'N',
					p_txn_source_id_tab           => l_ta_resource_assgt_tbl,
					p_txn_source_type_code_tab    => l_txn_source_type_code_tbl,
					p_person_id_tab               => l_person_id_tbl,
					p_job_id_tab                  => l_job_id_tbl,
					p_organization_id_tab         => l_organization_id_tbl,
					p_vendor_id_tab               => l_supplier_id_tbl,
					p_expenditure_type_tab        => l_expenditure_type_tbl,
					p_event_type_tab              => l_event_type_tbl,
					p_expenditure_category_tab    => l_expenditure_category_tbl,
					p_revenue_category_code_tab   => l_revenue_category_code_tbl,
					p_project_role_id_tab         => l_project_role_id_tbl,
					p_resource_class_code_tab     => l_ta_resource_class_code_tbl,
					p_item_category_id_tab        => l_item_category_id_tbl,
					p_person_type_code_tab        => l_person_type_code_tbl,
					p_bom_resource_id_tab         => l_bom_resource_id_tbl,
					p_non_labor_resource_tab      => l_non_labor_resource_tbl,
					p_inventory_item_id_tab       => l_inventory_item_id_tbl,
					x_txn_source_id_tab           => l_txn_source_id_tab,
					x_res_list_member_id_tab      => l_res_list_member_id_tab,
					x_rbs_element_id_tab          => l_rbs_element_id_tab,
					x_txn_accum_header_id_tab     => l_txn_accum_header_id_tab,
					x_return_status               => x_return_status,
					x_msg_count                   => l_msg_count,
					x_msg_data                    => l_msg_data);

				IF x_return_status = FND_API.G_RET_STS_ERROR THEN
					RAISE FND_API.G_EXC_ERROR;
				ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
					RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
				END IF;

			END IF;
			-- \Bug 3974569.

		END IF; -- l_ta_resource_assgt_tbl.COUNT > 0

	END IF; -- p_src_elem_ver_id_tbl IS NOT NULL

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		FOR temp_i IN 1..x_resource_rec_tbl.COUNT LOOP
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').resource_assignment_id: ' || x_resource_rec_tbl(temp_i).resource_assignment_id,
			               x_log_level   => 3);
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').resource_list_member_id: ' || x_resource_rec_tbl(temp_i).resource_list_member_id,
			               x_log_level   => 3);
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').total_quantity: ' || x_resource_rec_tbl(temp_i).total_quantity,
			               x_log_level   => 3);
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').total_raw_cost: ' || x_resource_rec_tbl(temp_i).total_raw_cost,
			               x_log_level   => 3);
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').schedule_start_date: ' || x_resource_rec_tbl(temp_i).schedule_start_date,
			               x_log_level   => 3);
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').schedule_end_date: ' || x_resource_rec_tbl(temp_i).schedule_end_date,
			               x_log_level   => 3);
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').planning_start_date: ' || x_resource_rec_tbl(temp_i).planning_start_date,
			               x_log_level   => 3);
			PA_DEBUG.write(x_module      => L_Module,
			               x_msg         => 'x_resource_rec_tbl(' || temp_i || ').planning_end_date: ' || x_resource_rec_tbl(temp_i).planning_end_date,
			               x_log_level   => 3);

		END LOOP; -- FOR temp_i IN 1..x_resource_rec_tbl.COUNT LOOP


		pa_debug.g_err_stage:='End of TA: ' || L_FuncProc;
		pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);

	END IF;

	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		pa_debug.g_err_stage:= 'x_calculate_flag :=' || x_calculate_flag;
		pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;

        -- should clear this temporary table after being used since the table will be
        -- reused in adjust_asgmt_date right away in the same session in publishing flow.
        -- Otherwise, publishing flow may error out.
        DELETE pa_copy_asgmts_temp;

EXCEPTION

	WHEN FND_API.G_EXC_ERROR THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
                DELETE pa_copy_asgmts_temp;
		IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
			PA_DEBUG.write_log (x_module => L_Module,
								x_msg         => 'Error:' || L_FuncProc || SQLERRM,
								x_log_level   => 5);
		END IF;

	WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                DELETE pa_copy_asgmts_temp;
		IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
			PA_DEBUG.write_log (x_module => L_Module,
								x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
								x_log_level   => 6);
		END IF;
		RAISE;

	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                DELETE pa_copy_asgmts_temp;
                PA_TASK_PUB1.G_CALL_PJI_ROLLUP := null;
		IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
			PA_DEBUG.write_log (x_module => L_Module,
								x_msg         => 'Unexpected Error:' || L_FuncProc || SQLERRM,
								x_log_level   => 6);
		END IF;
		FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
								 p_procedure_name => L_FuncProc);
		RAISE;

END Validate_Copy_Assignment;





-- This function will Validates the Planning Resources for a Workplan

FUNCTION Validate_Pl_Res_For_WP( p_resource_list_member_id  IN   NUMBER ) RETURN VARCHAR2 IS



CURSOR C_pl_check(p_res_list_member_id IN NUMBER) IS

select par.alias, restype.name Res_type from  pa_resource_list_members par,

pa_res_types_vl restype

where par.fc_res_type_code = restype.RES_TYPE_CODE

and par.resource_list_member_id =  p_res_list_member_id;



R_Pl_Check C_Pl_Check%ROWTYPE;

L_FuncProc varchar2(250) ;

BEGIN

L_FuncProc := 'Validate_Pl_Res_For_WP';



IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='Entering: ' || L_FuncProc;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
END IF;


IF p_resource_list_member_id is NOT NULL AND
   p_resource_list_member_id <> FND_API.G_MISS_NUM THEN


IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='B4 query : ' || L_FuncProc;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
END IF;


  OPEN C_Pl_Check(p_resource_list_member_id);
  FETCH C_Pl_Check into R_Pl_Check;
  CLOSE C_Pl_Check;



	IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		pa_debug.g_err_stage:='A4 Query: ' || L_FuncProc;
		pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
	END IF;


  IF R_Pl_Check.res_type in ('REVENUE_CATEGORY', 'EVENT_TYPE') THEN



       PA_UTILS.ADD_MESSAGE

                               (p_app_short_name => 'PA',

                                p_msg_name       => 'PA_PL_RES_FC_RES_TYPE_ERR',

                                p_token1         => 'PLANNING_RESOURCE',

                                p_value1         =>  R_Pl_Check.alias,

								p_token2         => 'RES_TYPE',

                                p_value2         =>  R_Pl_Check.Res_type

                                );

		IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
		   pa_debug.g_err_stage:='Wrong Res type: ' || L_FuncProc;
	       pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
		END IF;

	   RETURN 'N';

  END IF;



END IF;



RETURN 'Y';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='End of TA: ' || L_FuncProc;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN

          PA_DEBUG.write_log (x_module => L_Module

                          ,x_msg         => 'Error:' || L_FuncProc || SQLERRM

                          ,x_log_level   => 5);

        END IF;

      RETURN 'N';

    WHEN OTHERS THEN

	  IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN

          PA_DEBUG.write_log (x_module => L_Module

                          ,x_msg         => 'Error:' || L_FuncProc || SQLERRM

                          ,x_log_level   => 6);

        END IF;

      FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,

                               p_procedure_name => L_FuncProc);

    RAISE;

END Validate_Pl_Res_For_WP;







-- This function will Validate whether a financial category is valid for workplan

-- Returns error if the given fc_res_type_code is 'REVENUE_CATEGORY' or 'EVENT_TYPE'.



FUNCTION Validate_Fin_Cat_For_WP( p_fc_res_type_code  IN  VARCHAR2) RETURN VARCHAR2 IS

CURSOR C_Fc_Check(p_fc_res_type_code  IN VARCHAR2) IS

select restype.name Res_type from

pa_res_types_vl restype

where p_fc_res_type_code = restype.RES_TYPE_CODE;



R_Fc_Check C_Fc_Check%ROWTYPE;

L_FuncProc varchar2(250) ;

BEGIN

L_FuncProc := 'Validate_Fin_Cat_For_WP';



IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='Entering: ' || L_FuncProc;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
END IF;


IF p_fc_res_type_code is NOT NULL AND

   p_fc_res_type_code <> FND_API.G_MISS_CHAR THEN



  OPEN C_Fc_Check(p_fc_res_type_code);

  FETCH C_Fc_Check into R_Fc_Check;

  CLOSE C_Fc_Check;





  IF p_fc_res_type_code in ('REVENUE_CATEGORY', 'EVENT_TYPE') THEN



       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',

                                p_msg_name       => 'PA_FC_RES_TYPE_ERR',

								p_token1         => 'RES_TYPE',

                                p_value1         =>  R_Fc_Check.Res_type

                                );

		RETURN 'N';

  END IF;



END IF;



RETURN 'Y';

IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='End of TA: ' || L_FuncProc;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
END IF;

EXCEPTION

    WHEN NO_DATA_FOUND THEN

	   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN

          PA_DEBUG.write_log (x_module => L_Module

                          ,x_msg         => 'Error:' || L_FuncProc || SQLERRM

                          ,x_log_level   => 5);

        END IF;

      RETURN 'N';

    WHEN OTHERS THEN

	  IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN

          PA_DEBUG.write_log (x_module => L_Module

                          ,x_msg         => 'Error:' || L_FuncProc || SQLERRM

                          ,x_log_level   => 6);

        END IF;

      FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,

                               p_procedure_name => L_FuncProc);

    RAISE;

END Validate_Fin_Cat_For_WP;









FUNCTION Get_WP_Resource_List_Id(

            p_project_id         IN   NUMBER)

RETURN   pa_proj_fp_options.all_resource_list_id%TYPE

IS

L_FuncProc varchar2(250) ;

CURSOR get_res_list_id IS

select cost_Resource_list_id

from   pa_proj_fp_options

where fin_plan_type_id = (select fin_plan_type_id

                          from pa_fin_plan_types_b

			  where use_for_workplan_flag = 'Y')

and project_id = p_project_id

and fin_plan_option_level_code = 'PLAN_TYPE';



l_bv_id NUMBER;

l_resource_list_id NUMBER := NULL;



BEGIN



  -- Get the workplan resource list id

  OPEN get_res_list_id;

  FETCH get_res_list_id INTO l_resource_list_id;

  CLOSE get_res_list_id;



  RETURN l_resource_list_id;



END Get_WP_Resource_List_Id;



FUNCTION Check_Edit_Task_Ok(P_PROJECT_ID        IN NUMBER default NULL,
  P_STRUCTURE_VERSION_ID    IN NUMBER default NULL,
  P_CURR_STRUCT_VERSION_ID IN NUMBER default NULL,
  P_Element_Id IN NUMBER default NULL,
  P_Element_Version_Id IN NUMBER default NULL,
  P_Task_Assignment_Id IN NUMBER default NULL) RETURN VARCHAR2

  IS

  L_FuncProc varchar2(250) ;
  L_status varchar2(1);
  M_status varchar2(1);
  Process_Status varchar2(20);
  l_structure_version_id number;
  l_project_id number;
  l_wbs_element_version_id number;

  CURSOR C_Wbs_Element_Version_Id(p_resource_assignment_id IN NUMBER) IS
   SELECT wbs_element_version_id
   FROM pa_resource_assignments
   WHERE resource_assignment_id = p_resource_assignment_id;

  CURSOR C_structure_Version_Id(p_element_version_id IN NUMBER) IS
   SELECT parent_structure_version_id, project_id
   from pa_proj_element_versions
   where element_version_id = p_element_version_id;

-- Begin fix for Bug # 4373055.
  l_str_ver_id	 	NUMBER:= null;
  l_conc_request_id	NUMBER := null;
  l_message_name  VARCHAR2(30) := null;
  l_message_type  VARCHAR2(30) := null;
-- End fix for Bug # 4373055.

  BEGIN

  L_FuncProc := 'Check_Edit_Task_Ok';

  IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='Entering: ' || L_FuncProc;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
  END IF;

  IF P_structure_version_id is null or
     P_Project_Id is null THEN

     IF P_Element_Version_Id  IS NULL THEN
       OPEN C_Wbs_Element_Version_Id(p_task_assignment_id);
       FETCH C_Wbs_Element_Version_Id INTO l_wbs_element_version_id;
       CLOSE C_Wbs_Element_Version_Id;
     ELSE
       l_wbs_element_version_id := P_Element_Version_Id ;
     END IF;

     OPEN C_Structure_Version_Id(l_wbs_element_version_id);
     FETCH C_Structure_Version_Id INTO l_structure_version_id, l_project_id;
     CLOSE C_Structure_Version_Id;

  ELSE

     L_Structure_Version_Id := p_structure_version_id;
     L_Project_Id           := p_project_id;

  END IF;

  L_Status := pa_proj_elements_utils.check_edit_task_ok(
              P_PROJECT_ID                => l_project_id,
              P_STRUCTURE_VERSION_ID      => l_structure_version_id,
              P_CURR_STRUCT_VERSION_ID    => l_structure_version_id,
              p_require_lock_flag         => 'N',
              p_add_error_flag            => 'Y' -- Bug 4533152
              ) ;

  IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='g_apply_progress_flag='||g_apply_progress_flag;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
  END IF;

  IF L_Status = 'N' then

    RETURN 'N';

  -- Bug 4286558
  -- skip progress update check in apply progress mode
  -- because apply progress can be done within process update
  ELSIF g_apply_progress_flag = 'Y' THEN

   RETURN 'Y';

  ELSE

   IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='check process update';
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
   END IF;

   M_Status := PA_PROJECT_STRUCTURE_UTILS.GET_UPDATE_WBS_FLAG(
               P_PROJECT_ID         => l_project_id,
               P_STRUCTURE_VERSION_ID    => l_structure_version_id);

   IF (M_Status = 'Y') THEN

-- Begin fix for Bug # 4373055.

/*
     Process_Status :=  PA_PROJECT_STRUCTURE_UTILS.GET_PROCESS_STATUS_CODE(
               P_PROJECT_ID         => l_project_id,
               P_STRUCTURE_VERSION_ID    => l_structure_version_id);


       -- Confirmed w/Sakthi to use Structure Version & not project leve for TA
       -- jraj
       --As above is being used for a particular Structure version basis perspective..
       --Only on Task level, one would go on project level as P_STRUCTURE_TYPE     => 'WORKPLAN');

     IF Process_Status = 'WUE' THEN
        L_Status := 'Y';
     ELSIF Process_Status is NULL THEN
        L_Status := 'Y';
     ELSIF Process_Status = 'WUP' THEN
        L_Status := 'N';
     END IF;

*/

        PA_PROJECT_STRUCTURE_UTILS.GET_PROCESS_STATUS_MSG(
        p_project_id              => l_project_id
        , p_structure_type        => NULL
        , p_structure_version_id  => l_structure_version_id
        , p_context               => null
        , x_message_name          => l_message_name
        , x_message_type          => l_message_type
        , x_structure_version_id  => l_str_ver_id
        , x_conc_request_id       => l_conc_request_id);


	IF l_message_type = 'ERROR' THEN
          L_Status := 'Y';
	ELSIF l_message_type = 'PROCESS' THEN
          L_Status := 'N';
          -- Bug 4533152
          PA_UTILS.ADD_MESSAGE
                    (p_app_short_name => 'PA',
                     p_msg_name       => 'PA_PS_UDTWBS_PRC_INPROC');
          -- End of Bug 4533152
	ELSIF l_message_type is null THEN
          L_Status := 'Y';
	END IF;

-- End fix for Bug # 4373055.

   ELSIF (M_Status = 'N') THEN

     L_Status := 'Y';

   END IF;       --to implement..

  RETURN L_Status;

  END IF;

  IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 3) THEN
	pa_debug.g_err_stage:='End of TA: ' || L_FuncProc;
	pa_debug.write('PA_TASK_ASSIGNMENT_UTILS',pa_debug.g_err_stage,3);
  END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN

     IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 5) THEN
         PA_DEBUG.write_log (x_module => L_Module
                         ,x_msg         => 'Error:' || L_FuncProc || SQLERRM
                         ,x_log_level   => 5);
     END IF;
     RETURN 'N';

   WHEN OTHERS THEN

     IF P_DEBUG_MODE = 'Y' AND (li_curr_level <= 6) THEN
         PA_DEBUG.write_log (x_module => L_Module
                         ,x_msg         => 'Error:' || L_FuncProc || SQLERRM
                         ,x_log_level   => 6);
     END IF;

     FND_MSG_PUB.add_exc_msg( p_pkg_name       => L_Module,
                              p_procedure_name => L_FuncProc);
     RAISE;

END ;





FUNCTION Get_Min_Max_Task_Asgmt_Date(p_resource_list_member_id IN NUMBER, p_mode IN VARCHAR2,

  p_project_id IN NUMBER, p_budget_version_id IN NUMBER, p_unstaffed_only IN VARCHAR2 default 'N') RETURN DATE IS

  L_FuncProc varchar2(250) ;

  Cursor C_Min_Date IS
  select min(ra.SCHEDULE_START_DATE)
  from pa_resource_assignments ra
  where resource_list_member_id = p_resource_list_member_id
  and project_id = p_project_id
  and budget_version_id = p_budget_version_id
  and ('Y' <> p_unstaffed_only or nvl(project_assignment_id, -1) = -1);

  Cursor C_Max_Date IS
  select max(ra.SCHEDULE_END_DATE)
  from pa_resource_assignments ra
  where resource_list_member_id = p_resource_list_member_id
  and project_id = p_project_id
  and budget_version_id = p_budget_version_id
  and ('Y' <> p_unstaffed_only or nvl(project_assignment_id, -1) = -1);

  L_Date Date;



  BEGIN



  IF P_MODE = 'MIN' THEN



   OPEN C_Min_Date;

   Fetch C_Min_Date INTO L_DATE;

   CLOSE C_Min_Date;

   RETURN L_Date;



  ELSE



   OPEN C_Max_Date;

   Fetch C_Max_Date INTO L_DATE;

   CLOSE C_Max_Date;

   RETURN L_Date;



   END IF;



   END;


/**
Based on Resource Class find out Count of distinct UOM for a project, budget Version
Author: JRAJ
**/


FUNCTION Get_Class_UOM(p_project_id IN NUMBER,
                       p_budget_version_id IN NUMBER,
					   p_class IN VARCHAR2 )
RETURN VARCHAR2 IS

L_FuncProc varchar2(250) ;

Cursor C_Single_UOM IS
select count(distinct ra.unit_of_measure) cnt
from pa_resource_assignments ra
where ta_display_flag = 'Y' and
ra.project_id = p_project_id and
ra.budget_version_id = p_budget_version_id and
ra.resource_class_code = p_class;

L_Single_UOM VARCHAR2(2000) := -1;


BEGIN


   OPEN C_Single_UOM;

   Fetch C_Single_UOM INTO L_Single_UOM ;


   CLOSE C_Single_UOM;



   RETURN L_Single_UOM;


EXCEPTION

WHEN OTHERS THEN

   NULL;

   RETURN L_Single_UOM;

END Get_Class_UOM;


FUNCTION Get_Role(p_resource_list_member_id IN NUMBER DEFAULT NULL, p_project_id IN NUMBER default NULL)

RETURN VARCHAR2 IS

L_FuncProc varchar2(250) ;

Cursor C_Role IS

select distinct ro.meaning project_role

from pa_project_assignments pa,

pa_proj_roles_v ro

where

pa.project_role_id = ro.project_role_id (+)

and pa.resource_list_member_id = p_resource_list_member_id

and pa.project_id = p_project_id;



C_Role_rec C_Role%ROWTYPE;



L_Role VARCHAR2(2000);



BEGIN



IF p_resource_list_member_id IS NOT NULL THEN

   OPEN C_Role;

   Fetch C_Role INTO C_Role_rec;



   L_Role := C_Role_rec.project_role;



   WHILE C_Role%FOUND

   LOOP



      Fetch C_Role INTO C_Role_rec;



      L_Role := L_Role || ',' || C_Role_rec.project_role;



   END LOOP;



   CLOSE C_Role;



   RETURN L_Role;

ELSE

   RETURN L_Role;

END IF;

EXCEPTION

WHEN OTHERS THEN

   NULL;

   RETURN L_Role;

END;





FUNCTION Get_Assignment_Effort
RETURN NUMBER IS
begin
return pa_task_assignment_utils.p_assignment_effort;
exception when others then
return pa_task_assignment_utils.p_assignment_effort;
end;

FUNCTION Get_Team_Role(p_resource_list_member_id IN NUMBER default NULL, p_project_id IN NUMBER default NULL)

RETURN VARCHAR2 IS

L_FuncProc varchar2(250) ;

Cursor C_Team_Role IS

select distinct pap.assignment_name Team_Role, pap.assignment_effort

from pa_project_assignments pap, pa_project_statuses stat

where

pap.resource_list_member_id = p_resource_list_member_id

and pap.project_id = p_project_id
and
pap.STATUS_CODE = stat.PROJECT_STATUS_CODE (+) and
nvl(stat.PROJECT_SYSTEM_STATUS_CODE, '-1') not  in
('OPEN_ASGMT_CANCEL','STAFFED_ASGMT_CANCEL', 'OPEN_ASGMT_FILLED');



C_Team_Role_rec C_Team_Role%ROWTYPE;



L_Team_Role VARCHAR2(2000);



BEGIN

PA_TASK_ASSIGNMENT_UTILS.p_multi_asgmt_req_flag := 'N';
pa_task_assignment_utils.p_assignment_effort := to_number(NULL);


IF p_resource_list_member_id IS NOT NULL THEN

   OPEN C_Team_Role;

   Fetch C_Team_Role INTO C_Team_Role_rec;



   L_Team_Role := C_Team_Role_rec.team_role;
   pa_task_assignment_utils.p_assignment_effort := C_Team_Role_rec.assignment_effort;


   WHILE C_Team_Role%FOUND

   LOOP



      Fetch C_Team_Role INTO C_Team_Role_rec;



      IF C_Team_Role%FOUND THEN

        L_Team_Role := L_Team_Role || ',' || C_Team_Role_rec.team_role;
        PA_TASK_ASSIGNMENT_UTILS.p_multi_asgmt_req_flag := 'Y'; /* Added for bug ???? */
        pa_task_assignment_utils.p_assignment_effort := pa_task_assignment_utils.p_assignment_effort + C_Team_Role_rec.assignment_effort;


      END IF;



   END LOOP;



   CLOSE C_Team_Role;



   RETURN L_Team_Role;

ELSE

   RETURN L_Team_Role;

END IF;



EXCEPTION

WHEN OTHERS THEN

   NULL;

   RETURN L_Team_Role;

END;



-----------------------------------------------------------------

--

-- This API is designed specifically for pa_task_assignments_v.

--

-----------------------------------------------------------------

FUNCTION get_baselined_asgmt_dates(

  p_project_id             IN pa_projects_all.project_id%TYPE,

  p_element_version_id     IN pa_proj_element_versions.element_version_id%TYPE,

  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,

  p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE,

  p_proj_currency_code     IN pa_projects_all.project_currency_code%TYPE,

  p_projfunc_currency_code IN pa_projects_all.projfunc_currency_code%TYPE,

  p_code IN VARCHAR2) RETURN DATE IS



l_current_version_id      pa_budget_versions.budget_version_id%TYPE;

l_baselined_version_id    pa_budget_versions.budget_version_id%TYPE;

l_new_baselined_version_id pa_budget_versions.budget_version_id%TYPE; -- 4537865

l_published_version_id    pa_budget_versions.budget_version_id%TYPE;

l_planning_start_date     pa_resource_assignments.planning_start_date%TYPE;

l_planning_end_date       pa_resource_assignments.planning_start_date%TYPE;


l_init_raw_cost_rate      pa_budget_lines.txn_standard_cost_rate%TYPE;

l_avg_raw_cost_rate       pa_budget_lines.txn_standard_cost_rate%TYPE;

l_init_burd_cost_rate     pa_budget_lines.txn_standard_cost_rate%TYPE;

l_avg_burd_cost_rate      pa_budget_lines.txn_standard_cost_rate%TYPE;



l_revenue_txn_cur         pa_budget_lines.txn_revenue%TYPE;

l_revenue_proj_cur        pa_resource_assignments.total_project_revenue%TYPE;

l_revenue_proj_func_cur   pa_resource_assignments.total_plan_revenue%TYPE;

l_init_rev_rate           pa_budget_lines.txn_standard_bill_rate%TYPE;

l_avg_rev_rate            pa_budget_lines.txn_standard_bill_rate%TYPE;

l_margin_txn_cur          NUMBER;

l_margin_proj_cur         NUMBER;

l_margin_proj_func_cur    NUMBER;

l_margin_pct              NUMBER;

l_etc_avg_rev_rate	      pa_budget_lines.txn_standard_bill_rate%TYPE;

l_etc_avg_raw_cost_rate   pa_budget_lines.txn_standard_bill_rate%TYPE;

l_etc_avg_burd_cost_rate  pa_budget_lines.txn_standard_bill_rate%TYPE;

l_txn_currency_code       pa_budget_lines.txn_currency_code%TYPE;

l_return_status           VARCHAR2(1);

l_msg_count               NUMBER;

l_msg_data                VARCHAR2(200);


CURSOR get_txn_currency_code (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE) IS
SELECT bl.txn_currency_code
FROM pa_budget_lines bl
WHERE bl.resource_assignment_id = p_resource_assignment_id
AND rownum = 1;


BEGIN

  -- 3956324: Remove caching logic
  --IF g_resource_assignment_id <> p_resource_assignment_id THEN
    OPEN get_txn_currency_code(p_resource_assignment_id);
    FETCH get_txn_currency_code INTO l_txn_currency_code;
    CLOSE get_txn_currency_code;

    PA_PLANNING_ELEMENT_UTILS.get_workplan_bvids
    (p_project_id           => p_project_id,
     p_element_version_id   => p_element_version_id,
     x_current_version_id   => l_current_version_id,
     x_baselined_version_id => l_baselined_version_id,
     x_published_version_id => l_published_version_id,
     x_return_status        => l_return_status,
     x_msg_count            => l_msg_count,
     x_msg_data             => l_msg_data);

    -- get baselined budget version amounts
    PA_PLANNING_ELEMENT_UTILS.get_common_budget_version_info
    (p_budget_version_id       => l_baselined_version_id,
     p_resource_assignment_id  => p_resource_assignment_id,
     p_project_currency_code   => p_proj_currency_code,
     p_projfunc_currency_code  => p_projfunc_currency_code,
     p_txn_currency_code       => l_txn_currency_code,
 -- 4537865    x_budget_version_id       => l_baselined_version_id,
     x_budget_version_id       => l_new_baselined_version_id, -- 4537865
     x_planning_start_date     => l_planning_start_date,
     x_planning_end_date       => l_planning_end_date,
	 x_schedule_start_date     => g_baselined_asgmt_start_date,
   	 x_schedule_end_date       => g_baselined_asgmt_end_date,
     x_quantity                => g_baselined_planned_qty,
     x_revenue_txn_cur         => l_revenue_txn_cur,
     x_revenue_proj_cur        => l_revenue_proj_cur,
     x_revenue_proj_func_cur   => l_revenue_proj_func_cur,
     x_raw_cost_txn_cur        => g_bl_planned_raw_cost_txn_cur,
     x_raw_cost_proj_cur       => g_bl_raw_cost_proj_cur,
     x_raw_cost_proj_func_cur  => g_bl_raw_cost_projfunc_cur,
     x_burd_cost_txn_cur       => g_bl_planned_bur_cost_txn_cur,
     x_burd_cost_proj_cur      => g_bl_bur_cost_proj_cur,
     x_burd_cost_proj_func_cur => g_bl_bur_cost_projfunc_cur,
     x_init_rev_rate           => l_init_rev_rate,
     x_avg_rev_rate            => l_avg_rev_rate,
     x_init_raw_cost_rate      => l_init_raw_cost_rate,
     x_avg_raw_cost_rate       => l_avg_raw_cost_rate,
     x_init_burd_cost_rate     => l_init_burd_cost_rate,
     x_avg_burd_cost_rate      => l_avg_burd_cost_rate,
     x_margin_txn_cur          => l_margin_txn_cur,
     x_margin_proj_cur         => l_margin_proj_cur,
     x_margin_proj_func_cur    => l_margin_proj_func_cur,
     x_margin_pct              => l_margin_pct,
     x_etc_avg_rev_rate	       => l_etc_avg_rev_rate,
     x_etc_avg_raw_cost_rate   => l_etc_avg_raw_cost_rate,
     x_etc_avg_burd_cost_rate  => l_etc_avg_burd_cost_rate,
     x_return_status           => l_return_status,
     x_msg_count               => l_msg_count,
     x_msg_data                => l_msg_data          );

    IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
      -- 4537865
     l_baselined_version_id := l_new_baselined_version_id ; -- Though not used further ,assigning back to l_baselined_version_id to
							    --  retain the older meaning
    END IF;
    --g_resource_assignment_id := p_resource_assignment_id;
  --END IF;

  IF p_code = 'baselined_asgmt_start_date' THEN

   RETURN g_baselined_asgmt_start_date;

  ELSIF p_code = 'baselined_asgmt_end_date' THEN

   RETURN g_baselined_asgmt_end_date;

  ELSE

    RETURN NULL;

  END IF;

EXCEPTION

WHEN OTHERS THEN

   RETURN NULL;



 END get_baselined_asgmt_dates;



-----------------------------------------------------------------

--

-- This API is designed specifically for pa_task_assignments_v.

--

-----------------------------------------------------------------

FUNCTION get_baselined_asgmt_amounts(

  p_project_id             IN pa_projects_all.project_id%TYPE,

  p_element_version_id     IN pa_proj_element_versions.element_version_id%TYPE,

  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,

  p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE,

  p_proj_currency_code     IN pa_projects_all.project_currency_code%TYPE,

  p_projfunc_currency_code IN pa_projects_all.projfunc_currency_code%TYPE,

  p_code IN VARCHAR2) RETURN NUMBER IS



l_current_version_id      pa_budget_versions.budget_version_id%TYPE;

l_baselined_version_id    pa_budget_versions.budget_version_id%TYPE;

l_new_baselined_version_id pa_budget_versions.budget_version_id%TYPE; -- 4537865

l_published_version_id    pa_budget_versions.budget_version_id%TYPE;

l_planning_start_date     pa_resource_assignments.planning_start_date%TYPE;

l_planning_end_date       pa_resource_assignments.planning_start_date%TYPE;


l_init_raw_cost_rate      pa_budget_lines.txn_standard_cost_rate%TYPE;

l_avg_raw_cost_rate       pa_budget_lines.txn_standard_cost_rate%TYPE;

l_init_burd_cost_rate     pa_budget_lines.txn_standard_cost_rate%TYPE;

l_avg_burd_cost_rate      pa_budget_lines.txn_standard_cost_rate%TYPE;



l_revenue_txn_cur         pa_budget_lines.txn_revenue%TYPE;

l_revenue_proj_cur        pa_resource_assignments.total_project_revenue%TYPE;

l_revenue_proj_func_cur   pa_resource_assignments.total_plan_revenue%TYPE;

l_init_rev_rate           pa_budget_lines.txn_standard_bill_rate%TYPE;

l_avg_rev_rate            pa_budget_lines.txn_standard_bill_rate%TYPE;

l_margin_txn_cur          NUMBER;

l_margin_proj_cur         NUMBER;

l_margin_proj_func_cur    NUMBER;

l_margin_pct              NUMBER;

l_etc_avg_rev_rate	      pa_budget_lines.txn_standard_bill_rate%TYPE;

l_etc_avg_raw_cost_rate   pa_budget_lines.txn_standard_bill_rate%TYPE;

l_etc_avg_burd_cost_rate  pa_budget_lines.txn_standard_bill_rate%TYPE;

l_txn_currency_code       pa_budget_lines.txn_currency_code%TYPE;

l_return_status           VARCHAR2(1);

l_msg_count               NUMBER;

l_msg_data                VARCHAR2(200);


CURSOR get_txn_currency_code (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE) IS
SELECT bl.txn_currency_code
FROM pa_budget_lines bl
WHERE bl.resource_assignment_id = p_resource_assignment_id
AND rownum = 1;


BEGIN

  -- 3956324: Remove caching logic
  --IF g_resource_assignment_id <> p_resource_assignment_id THEN
    OPEN get_txn_currency_code(p_resource_assignment_id);
    FETCH get_txn_currency_code INTO l_txn_currency_code;
    CLOSE get_txn_currency_code;

    PA_PLANNING_ELEMENT_UTILS.get_workplan_bvids
    (p_project_id           => p_project_id,
     p_element_version_id   => p_element_version_id,
     x_current_version_id   => l_current_version_id,
     x_baselined_version_id => l_baselined_version_id,
     x_published_version_id => l_published_version_id,
     x_return_status        => l_return_status,
     x_msg_count            => l_msg_count,
     x_msg_data             => l_msg_data);

    -- get baselined budget version amounts
    PA_PLANNING_ELEMENT_UTILS.get_common_budget_version_info
    (p_budget_version_id       => l_baselined_version_id,
     p_resource_assignment_id  => p_resource_assignment_id,
     p_project_currency_code   => p_proj_currency_code,
     p_projfunc_currency_code  => p_projfunc_currency_code,
     p_txn_currency_code       => l_txn_currency_code,
   -- 4537865  x_budget_version_id       => l_baselined_version_id,
     x_budget_version_id       => l_new_baselined_version_id , -- 4537865
     x_planning_start_date     => l_planning_start_date,
     x_planning_end_date       => l_planning_end_date,
	 x_schedule_start_date     => g_baselined_asgmt_start_date,
   	 x_schedule_end_date       => g_baselined_asgmt_end_date,
     x_quantity                => g_baselined_planned_qty,
     x_revenue_txn_cur         => l_revenue_txn_cur,
     x_revenue_proj_cur        => l_revenue_proj_cur,
     x_revenue_proj_func_cur   => l_revenue_proj_func_cur,
     x_raw_cost_txn_cur        => g_bl_planned_raw_cost_txn_cur,
     x_raw_cost_proj_cur       => g_bl_raw_cost_proj_cur,
     x_raw_cost_proj_func_cur  => g_bl_raw_cost_projfunc_cur,
     x_burd_cost_txn_cur       => g_bl_planned_bur_cost_txn_cur,
     x_burd_cost_proj_cur      => g_bl_bur_cost_proj_cur,
     x_burd_cost_proj_func_cur => g_bl_bur_cost_projfunc_cur,
     x_init_rev_rate           => l_init_rev_rate,
     x_avg_rev_rate            => l_avg_rev_rate,
     x_init_raw_cost_rate      => l_init_raw_cost_rate,
     x_avg_raw_cost_rate       => l_avg_raw_cost_rate,
     x_init_burd_cost_rate     => l_init_burd_cost_rate,
     x_avg_burd_cost_rate      => l_avg_burd_cost_rate,
     x_margin_txn_cur          => l_margin_txn_cur,
     x_margin_proj_cur         => l_margin_proj_cur,
     x_margin_proj_func_cur    => l_margin_proj_func_cur,
     x_margin_pct              => l_margin_pct,
   	 x_etc_avg_rev_rate	       => l_etc_avg_rev_rate,
   	 x_etc_avg_raw_cost_rate   => l_etc_avg_raw_cost_rate,
   	 x_etc_avg_burd_cost_rate  => l_etc_avg_burd_cost_rate,
     x_return_status           => l_return_status,
     x_msg_count               => l_msg_count,
     x_msg_data                => l_msg_data          );

     -- 4537865
     -- Though not used further ,assigning l_new_baselined_version_id back to l_baselined_version_id to retain the older meaning
   IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN
     l_baselined_version_id := l_new_baselined_version_id ;
   END IF;
     --g_resource_assignment_id := p_resource_assignment_id;
  --END IF;

  IF p_code = 'baselined_planned_qty' THEN

   RETURN g_baselined_planned_qty;

  ELSIF p_code = 'bl_planned_bur_cost_txn_cur' THEN

   RETURN g_bl_planned_bur_cost_txn_cur;

  ELSIF p_code = 'bl_bur_cost_proj_cur' THEN

   RETURN g_bl_bur_cost_proj_cur;

  ELSIF p_code = 'bl_bur_cost_projfunc_cur' THEN

   RETURN g_bl_bur_cost_projfunc_cur;

  ELSIF p_code = 'bl_raw_cost_txn_cur' THEN

   RETURN g_bl_planned_raw_cost_txn_cur;

  ELSIF p_code = 'bl_raw_cost_proj_cur' THEN

   RETURN g_bl_raw_cost_proj_cur;

  ELSIF p_code = 'bl_raw_cost_projfunc_cur' THEN

   RETURN g_bl_raw_cost_projfunc_cur;

  ELSE

    RETURN NULL;

  END IF;

EXCEPTION

WHEN OTHERS THEN

   RETURN null;

END get_baselined_asgmt_amounts;

/* Commented for 4994791

FUNCTION get_planned_asgmt_amounts(
  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,
  p_code IN VARCHAR2) RETURN NUMBER IS


CURSOR get_resource_assignment_info (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE) IS

SELECT
   SUM(bl.quantity) as planned_quantity,
   SUM(bl.txn_burdened_cost) as planned_bur_cost_txn_cur,
   SUM(bl.txn_raw_cost) as planned_raw_cost_txn_cur,
   SUM(bl.init_quantity) as actual_quantity,
   SUM(bl.txn_init_burdened_cost) as act_bur_cost_txn_cur,
   SUM(bl.txn_init_raw_cost) as act_raw_cost_txn_cur,
   SUM(bl.project_init_burdened_cost) as act_bur_cost_pc_cur,
   SUM(bl.project_init_raw_cost) as act_raw_cost_pc_cur,
   SUM(bl.init_burdened_cost) as act_bur_cost_pfc_cur,
   SUM(bl.init_raw_cost) as act_raw_cost_pfc_cur,
   AVG(nvl(bl.txn_cost_rate_override, bl.txn_standard_cost_rate)) as avg_raw_cost_rate,
   AVG(bl.burden_cost_rate) as avg_bur_cost_rate
FROM pa_budget_lines bl
WHERE bl.resource_assignment_id = p_resource_assignment_id
GROUP BY bl.resource_assignment_id;

l_act_bur_cost_pc_cur NUMBER;
l_act_raw_cost_pc_cur NUMBER;
l_act_bur_cost_pfc_cur NUMBER;
l_act_raw_cost_pfc_cur NUMBER;

BEGIN

-- Bug 3956324: Remove the caching logic
--IF g_pl_resource_assignment_id <> p_resource_assignment_id THEN
   g_planned_quantity         := NULL;
   g_planned_bur_cost_txn_cur := NULL;
   g_planned_raw_cost_txn_cur := NULL;
   g_actual_quantity          := NULL;
   g_act_bur_cost_txn_cur     := NULL;
   g_act_raw_cost_txn_cur     := NULL;
   g_avg_raw_cost_rate        := NULL;
   g_avg_bur_cost_rate        := NULL;

   OPEN get_resource_assignment_info(p_resource_assignment_id);
   FETCH get_resource_assignment_info INTO
      g_planned_quantity, g_planned_bur_cost_txn_cur, g_planned_raw_cost_txn_cur,
      g_actual_quantity, g_act_bur_cost_txn_cur, g_act_raw_cost_txn_cur, l_act_bur_cost_pc_cur,
      l_act_raw_cost_pc_cur, l_act_bur_cost_pfc_cur, l_act_raw_cost_pfc_cur,
      g_avg_raw_cost_rate, g_avg_bur_cost_rate;
   CLOSE get_resource_assignment_info;

--   g_pl_resource_assignment_id := p_resource_assignment_id;
--END IF;

IF p_code = 'planned_quantity' THEN

   return g_planned_quantity;

ELSIF p_code = 'planned_bur_cost_txn_cur' THEN

   return g_planned_bur_cost_txn_cur;

ELSIF p_code = 'planned_raw_cost_txn_cur' THEN

   return g_planned_raw_cost_txn_cur;

ELSIF p_code = 'actual_quantity' THEN

   return g_actual_quantity;

ELSIF p_code = 'act_bur_cost_txn_cur' THEN

   return g_act_bur_cost_txn_cur;

ELSIF p_code = 'act_raw_cost_txn_cur' THEN

   return g_act_raw_cost_txn_cur;

ELSIF p_code = 'act_bur_cost_pc_cur' THEN

   return l_act_bur_cost_pc_cur;

ELSIF p_code = 'act_raw_cost_pc_cur' THEN

   return l_act_raw_cost_pc_cur;

ELSIF p_code = 'act_bur_cost_pfc_cur' THEN

   return l_act_bur_cost_pfc_cur;

ELSIF p_code = 'act_raw_cost_pfc_cur' THEN

   return l_act_raw_cost_pfc_cur;

ELSIF p_code = 'avg_raw_cost_rate' THEN

   return g_avg_raw_cost_rate;

ELSIF p_code = 'avg_bur_cost_rate' THEN

   return g_avg_bur_cost_rate;

ELSE

   return null;

END IF;

END get_planned_asgmt_amounts;

End of Bug Fix 4994791 */


FUNCTION get_planned_currency_info (

  p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE,

  p_project_id IN pa_projects_all.project_id%TYPE,

  p_code IN VARCHAR2) RETURN VARCHAR2 IS

CURSOR get_bl_currency_info (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE) IS
SELECT bl.txn_currency_code as txn_currency_code
FROM pa_budget_lines bl
WHERE bl.resource_assignment_id = p_resource_assignment_id
AND rownum = 1;

CURSOR get_proj_currency_info (p_project_id IN pa_projects_all.project_id%TYPE) IS
SELECT proj.project_currency_code as txn_currency_code
FROM pa_projects_all proj
WHERE proj.project_id = p_project_id
AND rownum = 1;

BEGIN

-- Bug 3956324: Remove the caching logic
--IF g_cur_resource_assignment_id <> p_resource_assignment_id THEN
   g_txn_currency_code := null;

   OPEN get_bl_currency_info(p_resource_assignment_id);
   FETCH get_bl_currency_info INTO g_txn_currency_code;
   CLOSE get_bl_currency_info;

   IF g_txn_currency_code IS NULL THEN
     OPEN get_proj_currency_info(p_project_id);
     FETCH get_proj_currency_info INTO g_txn_currency_code;
     CLOSE get_proj_currency_info;
   END IF;

   g_cur_resource_assignment_id := p_resource_assignment_id;
--END IF;

IF p_code = 'txn_currency_code' THEN

   return g_txn_currency_code;

ELSE

   return null;

END IF;

END get_planned_currency_info;


FUNCTION get_task_level_record(

  p_project_id             IN pa_projects_all.project_id%TYPE,

  p_element_version_id     IN pa_proj_element_versions.element_version_id%TYPE

) RETURN NUMBER IS



CURSOR get_task_level_record IS

select resource_assignment_id

from pa_resource_assignments

where ta_display_flag = 'N'

and wbs_element_version_id = p_element_version_id

and project_id = p_project_id

and rownum = 1;



l_resource_assignment_id NUMBER := NULL;



BEGIN



  OPEN get_task_level_record;

  FETCH get_task_level_record INTO l_resource_assignment_id;

  CLOSE get_task_level_record;



  RETURN l_resource_assignment_id;



EXCEPTION

WHEN OTHERS THEN

   RETURN null;



END get_task_level_record;





function gchar(p_char IN VARCHAR2 default NULL, p_mode IN VARCHAR2 default 'F') return varchar2 IS

begin





if p_mode = 'F' and

(p_char is NULL  OR p_char = fnd_api.g_miss_char) THEN



  return to_char(NULL);



elsif p_mode = 'B' and

(p_char is NULL  OR p_char = fnd_api.g_miss_char) THEN



  return fnd_api.g_miss_char;



elsif p_char is NOT NULL THEN



  return p_char;



end if;



exception when others then

return p_char;



end gchar;



function gnum(p_num IN NUMBER default NULL, p_mode IN VARCHAR2 default 'F') return NUMBER IS

begin





if p_mode = 'F' and

( p_num is NULL  OR p_num = fnd_api.g_miss_num ) THEN



  return to_number(NULL);



elsif p_mode = 'B' and

( p_num is NULL  OR p_num = fnd_api.g_miss_num ) THEN



  return fnd_api.g_miss_num;

elsif p_num is NOT NULL THEN



  return p_num;

end if;



exception when others then

return p_num;



end gnum;



function gdate(p_date IN DATE default NULL, p_mode IN VARCHAR2 default 'F') return DATE IS

begin





if p_mode = 'F' and

(p_date is NULL  OR p_date = fnd_api.g_miss_date ) THEN



  return to_date(NULL);





elsif p_mode = 'B' and

(p_date is NULL  OR p_date = fnd_api.g_miss_date ) THEN



  return fnd_api.g_miss_date;

elsif p_date is NOT NULL THEN



  return p_date;

end if;



exception when others then

return p_date;



end gdate;



/************************************************************************/
/* Procedure: SET_TABLE_STATS                                           */
/* Desciption: Sets table stats to certain values.                      */
/************************************************************************/
PROCEDURE set_table_stats(ownname IN VARCHAR2,
                          tabname IN VARCHAR2,
                          numrows IN NUMBER,
                          numblks IN NUMBER,
                          avgrlen IN NUMBER)
IS
	PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    DBMS_STATS.set_table_stats(ownname,
                               tabname,
                               NULL,
                               NULL,
                               NULL,
                               numrows,
                               numblks,
                               avgrlen,
                               NULL,
                               NULL);
END; /* SET_TABLE_STATS */

------------------BUG 4373411 , rtarway, DHIER refresh rates-----------------------

-- Procedure            : CHECK_EDIT_OK
-- Type                 : Public Procedure
-- Purpose              : This API validates whether it is fine to update the task assignments in
--                      : the workplan by the logged in user
-- Note                 : This API adds all the validation errors to the error stack and return status
--                      : is 'E'/'U' when error occurs or 'S' if sucess.
-- Assumptions          :

-- Parameters           Type     Required        Description and Purpose
------------------------------------------------------------------------
-- p_project_id         NUMBER   Yes             Project Id
-- p_pa_structure_version_id NUMBER Yes          Structure Version Id
-- x_budget_version_id  NUMBER    NA             Returns budget version id


PROCEDURE CHECK_EDIT_OK(
  p_api_version_number    IN   NUMBER   := 1.0
, p_init_msg_list         IN   VARCHAR2 := FND_API.G_FALSE
, p_commit                IN   VARCHAR2 := FND_API.G_FALSE
, p_project_id            IN NUMBER
, p_pa_structure_version_id IN NUMBER
, px_budget_version_id    IN OUT NOCOPY NUMBER
, x_return_status OUT NOCOPY VARCHAR2 -- 4537865
, x_msg_data      OUT NOCOPY VARCHAR2 -- 4537865
, x_msg_count     OUT NOCOPY NUMBER ) -- 4537865

IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_user_id                        NUMBER;
l_login_id                       NUMBER;
l_resp_id                        NUMBER;
l_return_status                 VARCHAR2(1);

l_function_allowed            VARCHAR2(1);

l_project_id                     NUMBER;
l_budget_version_id              NUMBER;
l_str_version_id                 NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

g_module_name                    VARCHAR2(30) := 'PA_TASK_ASSIGNMENT_UTILS';

l_module_name                    VARCHAR2(80) := 'PA_PM_UPDATE_TASK_ASSIGNMENT';

l_struct_elem_version_id         NUMBER;
L_VALID                          VARCHAR2(1);
L_CURR_WORKING_VERSION           NUMBER;


CURSOR C_validate_Budget_Version_Id (l_budget_version_id NUMBER , l_project_id NUMBER) IS
   SELECT budget_version_id, project_structure_version_id
   FROM   pa_budget_versions
   WHERE  budget_version_id = l_budget_version_id
   AND    project_id = l_project_id
   AND    project_structure_version_id is not null;

CURSOR c_validate_str_version_id (l_str_ver_id NUMBER, l_project_id NUMBER) IS
   SELECT 'Y'
   FROM dual
   WHERE EXISTS
	   (SELECT ppev.element_version_id
	   FROM pa_proj_element_versions ppev,
	        pa_proj_elem_ver_structure ppevs,
		pa_proj_structure_types ppst
	   WHERE
	       ppev.element_version_id = l_str_ver_id
	   and ppev.project_id = l_project_id
	   and ppev.object_type='PA_STRUCTURES'
	   and ppev.element_version_id=ppevs.element_version_id
	   and ppev.project_id=ppevs.project_id
           and ppevs.proj_element_id = ppst.proj_element_id
	   and ppst.structure_type_id = 1);

CURSOR C_Get_Budget_Version_Id(l_structure_version_id IN NUMBER) is
   select budget_version_id
   from pa_budget_versions
   where project_structure_version_id = l_structure_version_id
   and project_id = p_project_id;

l_dummy varchar2(1);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_user_id := fnd_global.user_id;
     l_login_id := fnd_global.login_id;
     l_resp_id := FND_GLOBAL.Resp_id;
     l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id, l_login_id,275,null,null),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CHECK_EDIT_OK',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
           FND_MSG_PUB.initialize;
     END IF;

     --Print All Input Params
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'p_pa_structure_version_id'||':'||p_pa_structure_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_module_name,'px_budget_version_id'||':'||px_budget_version_id,
                                     l_debug_level3);
     END IF;

    -- As part of enforcing project security, which would determine
    -- whether the user has the necessary privileges to update the project
    -- need to call the pa_security package
     IF l_debug_mode = 'Y' THEN
	Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Checking Security: UPDATE_TASK_ASSIGNMENT';
	Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
     END IF;
     pa_security.initialize (X_user_id        => l_user_id,
                            X_calling_module => l_module_name);

    -- Actions performed using the APIs would be subject to
    -- function security. If the responsibility does not allow
    -- such functions to be executed, the API should not proceed further
    -- since the user does not have access to such functions

    -- Function security procedure check whether user have the
    -- privilege to UPDATE task or not

      PA_INTERFACE_UTILS_PUB.G_PROJECT_ID := p_project_id;

      PA_PM_FUNCTION_SECURITY_PUB.check_function_security
      (p_api_version_number => p_api_version_number,
       p_responsibility_id  => l_resp_id,
       p_function_name      => 'PA_PM_UPDATE_TASK_ASSIGNMENT',
       p_msg_count          => l_msg_count,
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
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Checking Security: UPDATE_TASK_ASSIGNMENT: Suceess';
         Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
      END IF;
       -- Now verify whether project security allows the user to update
       -- the project
       -- The user does not have query privileges on this project
       -- Hence, cannot update the project.Raise error
       -- If the user has query privileges, then check whether
       -- update privileges are also available
      IF l_debug_mode = 'Y' THEN
	 Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Checking Security: Update/Query Project';
         Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
      END IF;

       IF pa_security.allow_query(x_project_id => p_project_id ) = 'N'
          OR pa_security.allow_update(x_project_id => p_project_id ) = 'N'
	  THEN
            -- The user does not have update privileges on this project
            -- Hence , raise error
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
          x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;
      IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Checking Security: Update/Query Project: Success';
         Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);

         Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Checking Security: Validating Str Version';
         Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
      END IF;
      IF  NVL(PA_PROJ_TASK_STRUC_PUB.WP_STR_EXISTS( p_project_id ), 'N') = 'N' THEN
        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
        THEN
            pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_PS_WP_NOT_SEP_FN'
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

       IF (px_budget_version_id is not null and px_budget_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
           OPEN  C_validate_Budget_Version_Id(px_budget_version_id,p_project_id);
           FETCH C_validate_Budget_Version_Id INTO l_budget_version_id,l_struct_elem_version_id;
           IF   (C_validate_Budget_Version_Id%NOTFOUND) THEN
                   PA_UTILS.ADD_MESSAGE(
                        p_app_short_name  => 'PA'
                       ,p_msg_name        => 'PA_FP_INVALID_VERSION_ID'
                       ,p_token1          => 'BUDGET_VERSION_ID'
                       ,p_value1          => px_budget_version_id);
		    CLOSE C_validate_Budget_Version_Id ;
		    raise FND_API.G_EXC_ERROR;
           END IF;
	   CLOSE C_validate_Budget_Version_Id ;
       ELSIF ( p_pa_structure_version_id IS NOT NULL AND
             ( p_pa_structure_version_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) )THEN
             l_struct_elem_version_id := p_pa_structure_version_id;
	     OPEN  c_validate_str_version_id(l_struct_elem_version_id, p_project_id);
             FETCH c_validate_str_version_id INTO l_valid;
             IF   (c_validate_str_version_id%NOTFOUND) THEN
                  PA_UTILS.ADD_MESSAGE
                  ( p_app_short_name => 'PA',
                    p_msg_name       => 'PA_INVALID_STR_VERSION_ID'
	          );
	          CLOSE c_validate_str_version_id;
                  RAISE FND_API.G_EXC_ERROR;
             END IF;
             CLOSE c_validate_str_version_id;
	     --Get the budget version_id
	     OPEN  C_Get_Budget_Version_Id(l_struct_elem_version_id);
             FETCH C_Get_Budget_Version_Id INTO l_budget_version_id;
             CLOSE C_Get_Budget_Version_Id;
       END IF;

      IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Validating Str/budget Version: Success';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
      END IF;
      --Get Current Working Version Id
      l_curr_working_version := PA_PROJECT_STRUCTURE_UTILS.get_current_working_ver_id(
                                                     p_project_id => p_project_id);
      IF l_debug_mode = 'Y' THEN
        Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Checking Security: Calling Check_edit_ok';
        Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
      END IF;
      IF 'N' = pa_task_assignment_utils.check_edit_task_ok
                    ( P_PROJECT_ID              => p_project_id,
                      P_STRUCTURE_VERSION_ID    => l_struct_elem_version_id,
                      P_CURR_STRUCT_VERSION_ID  => l_curr_working_version) THEN
               -- Bug 4533152
               -- PA_UTILS.ADD_MESSAGE
               --( p_app_short_name => 'PA',
               --  p_msg_name       => 'PA_UPDATE_PUB_VER_ERR'
	       --);
               x_return_status := FND_API.G_RET_STS_ERROR;
               RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF l_debug_mode = 'Y' THEN
         Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Calling Check_edit_ok: Success';
         Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
      END IF;

      IF ( l_budget_version_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR
           l_budget_version_id IS NULL  ) THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
                PA_UTILS.ADD_MESSAGE
                  (p_app_short_name => 'PA',
                   p_msg_name       => 'PA_FP_PROJ_VERSION_MISMATCH'
                  );
          END IF;
          x_return_status    := FND_API.G_RET_STS_ERROR;
	  px_budget_version_id := null;
          RAISE FND_API.G_EXC_ERROR;
      ELSE
          px_budget_version_id := l_budget_version_id;
      END IF;
      IF l_debug_mode = 'Y' THEN
	      Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Check_edit_ok: Budget Version Id'||l_budget_version_id;
	      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);

	      Pa_Debug.g_err_stage:= 'PA_TASK_ASSIGNMENT_UTILS :CHECK_EDIT_OK: Check_edit_ok: End';
	      Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,l_debug_level3);
      END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     -- 4537865
     px_budget_version_id := NULL ;

     IF c_validate_str_version_id%ISOPEN THEN
        CLOSE c_validate_str_version_id;
     END IF;

     IF C_Get_Budget_Version_Id%ISOPEN THEN
        CLOSE C_Get_Budget_Version_Id;
     END IF;

     IF C_validate_Budget_Version_Id%ISOPEN THEN
        CLOSE C_validate_Budget_Version_Id;
     END IF;

     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     -- 4537865
     px_budget_version_id := NULL ;

     IF c_validate_str_version_id%ISOPEN THEN
        CLOSE c_validate_str_version_id;
     END IF;

     IF C_Get_Budget_Version_Id%ISOPEN THEN
        CLOSE C_Get_Budget_Version_Id;
     END IF;

     IF C_validate_Budget_Version_Id%ISOPEN THEN
        CLOSE C_validate_Budget_Version_Id;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TASK_ASSIGNMENT_UTILS'
                    , p_procedure_name  => 'CHECK_EDIT_OK'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END  CHECK_EDIT_OK;
------------------BUG 4373411 , rtarway, DHIER refresh rates-----------------------


-- Bug 4492493
FUNCTION Is_Progress_Rollup_Required(
  p_project_id             IN pa_projects_all.project_id%TYPE
) RETURN VARCHAR2 IS

-- Bug 4492493:
--Need to do progress rollup if ALL of the following are true:
-- 1. This is a creation, update or deletion of workplan task assignment with
--    Planned Effort, i.e. which changes the rollup planned effort.
-- 2. This is a version disabled workplan structure
-- 3. There exists progress data for the project or workplan structure
CURSOR Does_Progress_Exists IS
select 'Y'
from pa_progress_rollup
where project_id = p_project_id
  and object_Type = 'PA_STRUCTURES'
  and structure_version_id is null
  and structure_type = 'WORKPLAN'
  and current_flag = 'Y';

l_progress_exists_flag VARCHAR2(1) := 'N';

BEGIN

  OPEN Does_Progress_Exists;
  FETCH Does_Progress_Exists INTO l_progress_exists_flag;
  CLOSE Does_Progress_Exists;

  IF l_progress_exists_flag = 'Y' AND
     PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(p_project_id) = 'N' THEN
    RETURN 'Y';
  ELSE
    RETURN 'N';
  END IF;

EXCEPTION
   WHEN OTHERS THEN
     RETURN 'N';

END Is_Progress_Rollup_Required;

/* Added for bug 6023345*/
-- This function is to check if a planning resource list (PRL) is an uncategorized resource list or not.
-- Input params : We can pass either :
--  i)p_resource_list_id
--    OR
--  ii)p_project_id - which will get the PRL for the project using get_wp_resource_list_id
--  This function call is used in
--    a)PA_PLANNING_RESOURCE_UTILS.Get_Res_Format_for_Team_Role
--    b)AssignmentUtils.getPLSMissingMsg in java

FUNCTION is_uncategorized_res_list
( p_resource_list_id        IN pa_resource_lists_all_bg.resource_list_id%TYPE := NULL
  ,p_project_id             IN pa_projects_all.project_id%TYPE := NULL
 ) RETURN VARCHAR2 IS

CURSOR get_uncat_flag (c_resource_list_id pa_resource_lists_all_bg.resource_list_id%TYPE)
IS
SELECT UNCATEGORIZED_FLAG
FROM pa_resource_lists_all_bg
WHERE RESOURCE_LIST_ID = c_resource_list_id;

l_uncat_flag VARCHAR2(1) := 'N';
l_resource_list_id pa_resource_lists_all_bg.resource_list_id%TYPE;
BEGIN
        l_resource_list_id := p_resource_list_id;

        IF l_resource_list_id IS NULL THEN
                l_resource_list_id := pa_task_assignment_utils.get_wp_resource_list_id(p_project_id);
        END IF;

        OPEN get_uncat_flag(l_resource_list_id);
        FETCH get_uncat_flag INTO l_uncat_flag;
        CLOSE get_uncat_flag;

        RETURN l_uncat_flag;

END is_uncategorized_res_list;
/* End for bug 6023345*/

END PA_TASK_ASSIGNMENT_UTILS;


/
