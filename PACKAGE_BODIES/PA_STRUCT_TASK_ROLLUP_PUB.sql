--------------------------------------------------------
--  DDL for Package Body PA_STRUCT_TASK_ROLLUP_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_STRUCT_TASK_ROLLUP_PUB" as
/* $Header: PATKRUPB.pls 120.12.12010000.6 2009/06/27 01:11:05 asahoo ship $ */

-- API name                      : Rollup_From_Subproject
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version                 IN  NUMBER      := 1.0
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_versions            IN  PA_NUM_1000_NUM
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2

-- This procedure is created as a to rollup subproject association,
	 /* Bug 6854670: Renamed procedure, changed type for input parameter p_element_versions
 	  * This procedure as of now is called only directly from the procedure Program_Schedule_dates_rollup
 	  * in the same package.
 	  * All other flows still calls Rollup_From_Subproject
 	  */

 PROCEDURE Rollup_From_Subproject_Unltd(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_element_versions                  IN  SYSTEM.PA_NUM_TBL_TYPE
   ,p_published_str_ver_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  --bug5861729
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                       )
  IS
--
    l_rollup_table     PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE;
    l_process_number   NUMBER;
--
    TYPE t_proj_id_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_proj_id_tbl t_proj_id_table;
--
    --added for bulk update
    TYPE t_schDate_Tbl IS TABLE Of DATE INDEX BY BINARY_INTEGER;
    l_old_sch_st_date_tbl t_schDate_Tbl;
    l_old_sch_fn_date_tbl t_schDate_Tbl;
    l_sch_start_date_tbl t_schDate_Tbl;
    l_sch_finish_date_tbl t_schDate_Tbl;
    l_effort_tbl t_proj_id_table;
    l_elem_ver_id_tbl t_proj_id_table;
--
    l_res_asgmt_id_tbl SYSTEM.PA_NUM_TBL_TYPE;
    l_planning_start_tbl SYSTEM.pa_date_tbl_type;
    l_planning_end_tbl SYSTEM.pa_date_tbl_type;
--
    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_cur DYNAMIC_CUR;
    l_sql VARCHAR2(32767);
    l_sql1 VARCHAR2(32767);
    l_predicate VARCHAR2(32767);
--
    l_cnt NUMBER :=0; -- for 5660584, pqe base bug5638103
--
    l_project_id NUMBER;
    l_element_version_id NUMBER;
    l_object_type VARCHAR2(30);
    l_wbs_level NUMBER;
    l_start_date DATE;
    l_finish_date DATE;
    l_parent_id NUMBER;
    l_parent_object_type VARCHAR2(30);
--
    l_structure_version_id NUMBER;
    l_baseline_proj_id     NUMBER;
    l_versioning           VARCHAR2(1);
    l_planned_effort       PA_PROJ_ELEM_VER_SCHEDULE.PLANNED_EFFORT%TYPE;
--
    -- Dates changes
    l_template_flag VARCHAR2(1);
    l_record_version_number NUMBER;
--
    cursor get_proj_attr_csr(c_project_id NUMBER)
    IS
    SELECT template_flag, record_version_number
    FROM pa_projects_all
    WHERE project_id = c_project_id;
--
    l_structure_id     NUMBER;
    l_struc_project_id NUMBER;
--
    --status control is not used anymore
    CURSOR get_system_status_code(c_element_version_id NUMBER)
    IS
    SELECT decode(project_system_status_code, 'CANCELLED', 'N', 'Y')
    FROM pa_proj_elements a, pa_proj_element_versions b,
         pa_project_statuses c
    where a.proj_element_id = b.proj_element_id
    and a.project_id = b.project_id
    and b.element_version_id = c_element_version_id
    and a.status_code = c.project_status_code
    and c.status_type = 'TASK';
--
    l_rollup_flag  VARCHAR2(1);
--
     --Getting the linking tasks
     CURSOR get_lnk_task(cp_task_version_id NUMBER) IS
     SELECT ppe.proj_element_id,
            ppev.element_version_id lnk_task_ver_id,
        ppev.project_id lnk_task_project_id
       FROM pa_proj_element_versions ppev,
            pa_proj_elements ppe,
            pa_proj_elem_ver_schedule pevs,
--bug 4541039
            pa_object_relationships por,
            pa_proj_elem_ver_structure pevst
--bug 4541039
      WHERE ppe.project_id = ppev.project_id
        AND ppe.proj_element_id = ppev.proj_element_id
        AND ppev.object_type = 'PA_TASKS'
        AND ppe.object_type = 'PA_TASKS'
        AND ppe.link_Task_flag = 'Y'
        AND ppev.project_id = pevs.project_id
        AND ppev.proj_element_id = pevs.proj_element_id
        AND ppev.element_version_id = pevs.element_version_id
--bug 4541039 rollup only from the published versions
        and por.object_id_from1 = ppev.element_version_id
        and pevst.element_version_id = por.object_id_to1
        and pevst.status_code = 'STRUCTURE_PUBLISHED'
        and pevst.project_id = por.object_id_to2
--bug 4541039
        AND ppev.element_version_id IN (
                       SELECT object_id_to1
                         FROM pa_object_relationships
                        WHERE relationship_type = 'S'
                   START WITH object_id_from1 = cp_task_version_id
                          AND object_type_from IN ('PA_TASKS','PA_STRUCTURES')
                          AND relationship_type = 'S'
                   CONNECT BY object_id_from1 = prior object_id_to1
                          AND RELATIONSHIP_TYPE = prior relationship_type
                          AND object_type_from = prior object_type_to);
     get_lnk_task_rec get_lnk_task%ROWTYPE;
--
     --Getting linking relationship details.
     CURSOR get_lnk_task_rel_det(cp_lnk_task_version_id NUMBER) IS
     Select object_id_from1 lnk_task_ver_id,object_id_to1 struct_version_id,
            object_id_from2 lnk_proj_id_from,object_id_to2 lnk_proj_id_to           --Bug 3634389
       FROM pa_object_relationships
      WHERE object_id_from1 = cp_lnk_task_version_id
        AND relationship_type = 'LW'
        AND object_id_from2 <> object_id_to2
        AND object_type_from = 'PA_TASKS'                --Bug 3634389
        AND object_type_to = 'PA_STRUCTURES';              --Bug 3634389
--        AND object_type_to = 'PA_TASKS'                 --Bug 3634389
--        AND object_type_from = 'PA_STRUCTURES';         --Bug 3634389
     get_lnk_task_rel_det_rec get_lnk_task_rel_det%ROWTYPE;
--
     CURSOR get_lnk_task_start_dt(cp_lnk_task_version_id NUMBER,
                                  cp_lnk_proj_id_from NUMBER,
                                  cp_lnk_proj_id_to NUMBER) IS
     SELECT min(scheduled_start_date) lnk_task_sch_start_Dt
       FROM (SELECT min(b.scheduled_start_date) scheduled_start_date  --bug 3967855
               FROM pa_proj_element_versions a,
                    pa_proj_elem_ver_schedule b
              WHERE a.project_id = b.project_id
                AND a.element_version_id = b.element_version_id
        AND b.project_id = cp_lnk_proj_id_from           --Bug 3634389 Added for performance
                AND b.element_version_id IN (SELECT object_id_from1
                                               FROM pa_object_relationships pora
                                              WHERE object_id_from1 = cp_lnk_task_version_id
                                                AND relationship_type = 'S'
                                                AND object_id_from2 <> object_id_to2
                                                AND object_type_from IN ('PA_STRUCTURES','PA_TASKS')   --Bug 3634389
                                                AND object_type_to = 'PA_TASKS')
--                                                AND object_type_from = 'PA_STRUCTURES')              --Bug 3634389
          UNION ALL
             SELECT min(d.scheduled_start_date) scheduled_start_date   --bug 3967855
               FROM pa_proj_element_versions c,
                    pa_proj_elem_ver_schedule d
                    ,pa_proj_elem_ver_structure e  --bug 4541039
              WHERE c.project_id = d.project_id
	        AND d.project_id =e.project_id  --Bug#6277752  Added for performance
                AND d.element_version_id = e.element_version_id  --Bug#6277752  Added for performance
                AND E.PROJECT_ID=C.PROJECT_ID --Bug 7607077
        AND d.project_id = cp_lnk_proj_id_to           --Bug 3634389 Added for performance
                --make sure that the rollup is happeningonly from published version of the sub-project bug 4541039
                AND e.element_version_id = c.element_version_id
                AND e.project_id = c.project_id -- Bug # 4868867.
                AND e.status_code = 'STRUCTURE_PUBLISHED'
                --end bug 4541039
                AND c.element_version_id IN (SELECT object_id_to1
                                               FROM pa_object_relationships
                                              WHERE object_id_from1 = cp_lnk_task_version_id
                                                AND relationship_type = 'LW'
                                                AND object_id_from2 <> object_id_to2
                                                AND object_type_from = 'PA_TASKS'                     --Bug 3634389
                                                AND object_type_to = 'PA_STRUCTURES'));               --Bug 3634389
--                                                AND object_type_to = 'PA_TASKS'                     --Bug 3634389
--                                                AND object_type_from = 'PA_STRUCTURES'));           --Bug 3634389
     get_lnk_task_start_dt_rec get_lnk_task_start_dt%ROWTYPE;
--
     CURSOR get_lnk_task_finish_dt(cp_lnk_task_version_id NUMBER,
                                  cp_lnk_proj_id_from NUMBER,
                                  cp_lnk_proj_id_to NUMBER) IS
     SELECT max(scheduled_finish_date) lnk_task_sch_finish_Dt
       FROM (SELECT max(b.scheduled_finish_date) scheduled_finish_date   --bug 3967855
               FROM pa_proj_element_versions a,
                    pa_proj_elem_ver_schedule b
              WHERE a.project_id = b.project_id
                AND a.element_version_id = b.element_version_id
        AND b.project_id = cp_lnk_proj_id_from           --Bug 3634389 Added for performance
                AND b.element_version_id IN (SELECT object_id_from1
                                               FROM pa_object_relationships pora
                                              WHERE object_id_from1 = cp_lnk_task_version_id
                                                AND relationship_type = 'S'
                                                AND object_id_from2 <> object_id_to2
                                                AND object_type_from IN ('PA_STRUCTURES','PA_TASKS')   --Bug 3634389
                                                AND object_type_to = 'PA_TASKS')
--                                                AND object_type_from = 'PA_STRUCTURES')              --Bug 3634389
          UNION ALL
             SELECT max(d.scheduled_finish_date) scheduled_finish_date   --bug 3967855
               FROM pa_proj_element_versions c,
                    pa_proj_elem_ver_schedule d
                    ,pa_proj_elem_ver_structure e    --bug 4541039
              WHERE c.project_id = d.project_id
              AND d.project_id =e.project_id 	--Bug#6277752  Added for performance
              AND d.element_version_id = e.element_version_id --Bug#6277752  Added for performance
        AND d.project_id = cp_lnk_proj_id_to           --Bug 3634389  Added for performance
                --make sure that the rollup is happeningonly from published version of the sub-project bug 4541039
                AND e.element_version_id = c.element_version_id
                and e.project_id = c.project_id -- Bug # 4868867.
                AND e.status_code = 'STRUCTURE_PUBLISHED'
                --end bug 4541039
                AND c.element_version_id IN (SELECT object_id_to1
                                        FROM pa_object_relationships
                                              WHERE object_id_from1 = cp_lnk_task_version_id
                                                AND relationship_type = 'LW'
                                                AND object_id_from2 <> object_id_to2
                                                AND object_type_from = 'PA_TASKS'                     --Bug 3634389
                                                AND object_type_to = 'PA_STRUCTURES'));               --Bug 3634389
--                                                AND object_type_to = 'PA_TASKS'                     --Bug 3634389
--                                                AND object_type_from = 'PA_STRUCTURES'));           --Bug 3634389
    get_lnk_task_finish_dt_rec get_lnk_task_finish_dt%ROWTYPE;

--bug 4238036
    Cursor get_sch_dates(c_element_version_id NUMBER) IS
      SELECT a.scheduled_start_date, a.scheduled_finish_date
      from pa_proj_elem_ver_schedule a
      where a.element_version_id = c_element_version_id;
    l_parent_start_date DATE;
    l_parent_finish_date DATE;
--bug 4238036

    l_lnk_task_project_id NUMBER;
    l_assgn_context     VARCHAR2(30);   --bug 4153366


--bug 4416432 issue # 5 and 6
    CURSOR get_scheduled_dates(c_project_Id NUMBER, c_element_version_id NUMBER)
    IS
    select scheduled_start_date, scheduled_finish_date
    from pa_proj_elem_ver_schedule
    where project_id = c_project_id
    and element_version_id = c_element_version_id;
    l_get_sch_dates_cur get_scheduled_dates%ROWTYPE;

    cursor get_structure_id(c_structure_ver_id NUMBER)
    IS
    SELECT project_id, proj_element_id
    FROM   pa_proj_element_versions
    where  element_version_id = c_structure_ver_id;
--end bug 4416432 issue # 5 and 6

    -- Start of Bug 6719725
    -- Generic lock for any project_id
    CURSOR c_wh_generic_lock_cur (l_project_id IN NUMBER) IS
      SELECT  project_id
      FROM    pa_proj_elem_ver_schedule
      WHERE   project_id = l_project_id
      FOR UPDATE NOWAIT;

    excp_resource_busy EXCEPTION;
    PRAGMA EXCEPTION_INIT(excp_resource_busy, -54);
    -- End of Bug 6719725

    l_debug_mode     VARCHAR2(1);

    -- 5660584, pqe base bug 5638103
    l_predicate1 VARCHAR2(32767);
    l_predicate_cnt NUMBER;
    l_tot_predicate_cnt NUMBER;
    dont_close_cursor VARCHAR2(1):='N';
    processing_completed VARCHAR2(1):='N';
    i number;


BEGIN
     l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF (l_debug_mode = 'Y') THEN
       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Entered...', 3);
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
       savepoint Rollup_From_Subproject_PVT;
     END IF;

     IF (l_debug_mode = 'Y') THEN
       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Performing validations...', 3);
     END IF;

     IF (p_element_versions.count = 0) THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;
     END IF;

     i:=1;
     loop -- loop1

        -- 5660584, pqe base bug 5638103
        l_predicate := null;
        l_tot_predicate_cnt:=0;

        --Loop thru the element version table and get the linking tasks for each element version if
        --any. For each linking task get the start date, finish date and then update the schedules
        --table for that linking task with the start date and finish date.

        -- FOR i IN p_element_versions.first..p_element_versions.last LOOP
        loop   -- loop2
          l_predicate1 := null;
          l_predicate_cnt:=0;

          IF NOT get_lnk_task%ISOPEN THEN -- don't open the cursor if still there are some more records in it.
              IF i > p_element_versions.last THEN
                  processing_completed:='Y';
                  exit; --from loop2 we are done with all the element version ids
              END IF;
              OPEN get_lnk_task(p_element_versions(i));
              i:=i+1;
          END IF;

          IF (l_debug_mode = 'Y') THEN
             pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Inside Loop p_element_versions(i)='||p_element_versions(i-1), 3);
          END IF;
          LOOP  --  bug 5638103 loop3

           FETCH get_lnk_task INTO get_lnk_task_rec;
--bug 4541039
           IF get_lnk_task%FOUND
           THEN
              IF l_predicate1 IS NOT NULL
              THEN
                 l_predicate1 := l_predicate1 ||',';
              END IF;
              l_predicate1 := l_predicate1||to_char(get_lnk_task_rec.lnk_task_ver_id);
              l_predicate_cnt:=l_predicate_cnt+1;
           ELSE
              exit; -- exit from loop3 no records exists
           END IF;
           --l_predicate := l_predicate||to_char(get_lnk_task_rec.lnk_task_ver_id);
           --EXIT WHEN get_lnk_task%NOTFOUND;
           --l_predicate := l_predicate||',';
--bug 4541039
           l_lnk_task_project_id := get_lnk_task_rec.lnk_task_project_id;
--
           --Getting linking task relationship details(target str version id
           OPEN get_lnk_task_rel_det(get_lnk_task_rec.lnk_task_ver_id);
           FETCH get_lnk_task_rel_det INTO get_lnk_task_rel_det_rec;
           CLOSE get_lnk_task_rel_det;
--
           --Getting the start date for the linking task
           OPEN get_lnk_task_start_dt(get_lnk_task_rec.lnk_task_ver_id,
                                      get_lnk_task_rel_det_rec.lnk_proj_id_from,      --Bug 3634389
                      get_lnk_task_rel_det_rec.lnk_proj_id_to);       --Bug 3634389

           FETCH get_lnk_task_start_dt INTO get_lnk_task_start_dt_rec;
           IF get_lnk_task_start_dt%NOTFOUND THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           CLOSE get_lnk_task_start_dt;
--
           --Getting the finish date for the linking task
           OPEN get_lnk_task_finish_dt(get_lnk_task_rec.lnk_task_ver_id,
                                       get_lnk_task_rel_det_rec.lnk_proj_id_from,     --Bug 3634389
                                       get_lnk_task_rel_det_rec.lnk_proj_id_to);      --Bug 3634389
           FETCH get_lnk_task_finish_dt INTO get_lnk_task_finish_dt_rec;
           IF get_lnk_task_finish_dt%NOTFOUND THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           CLOSE get_lnk_task_finish_dt;
--
--bug 4238036
           OPEN get_sch_dates(p_element_versions(i-1)); -- 5660584, pqe base bug 5638103
           FETCH get_sch_dates INTO l_parent_start_date, l_parent_finish_date;
           CLOSE get_sch_dates;

            -- Bug 6719725
            IF ((l_parent_start_date <> get_lnk_task_start_dt_rec.lnk_task_sch_start_Dt ) OR
            (l_parent_finish_date <> get_lnk_task_finish_dt_rec.lnk_task_sch_finish_Dt) ) THEN

           -- IF (l_parent_start_date > get_lnk_task_start_dt_rec.lnk_task_sch_start_Dt ) THEN
       -- Fix for Bug # 4385027.

             l_parent_start_date := get_lnk_task_start_dt_rec.lnk_task_sch_start_Dt;

           -- END IF;
           -- Fix for Bug # 4385027.

           -- IF (l_parent_finish_date < get_lnk_task_finish_dt_rec.lnk_task_sch_finish_Dt) THEN
           -- Fix for Bug # 4385027.

             l_parent_finish_date := get_lnk_task_finish_dt_rec.lnk_task_sch_finish_Dt;

           -- END IF;
           -- Fix for Bug # 4385027.

--end bug 4238036
           IF (l_debug_mode = 'Y') THEN
              pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Updating task ver:'||get_lnk_task_rec.lnk_task_ver_id, 3);
              pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Sch start date='||l_parent_start_date, 3);
              pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Sch finish date='||l_parent_finish_date, 3);
           END IF;

           -- Bug 6719725
           OPEN c_wh_generic_lock_cur(
           l_project_id => l_lnk_task_project_id);
           CLOSE c_wh_generic_lock_cur;

           UPDATE pa_proj_elem_ver_schedule
              SET scheduled_start_date  = l_parent_start_date
                 ,scheduled_finish_date = l_parent_finish_date
                 ,record_version_number = NVL( record_version_number, 0 ) + 1
            WHERE element_version_id = get_lnk_task_rec.lnk_task_ver_id
          AND project_id = l_lnk_task_project_id                                  --Bug 3634389
          ;
           IF SQL%NOTFOUND THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;

            END IF; -- Bug 6719725

            if l_predicate_cnt+l_tot_predicate_cnt = 1000 then
                   dont_close_cursor:='Y';
                   exit; -- exit from loop3 still there exists some records
            end if;
--
        END LOOP; --end loop3

        if dont_close_cursor <> 'Y' then
            CLOSE get_lnk_task;
        else
            dont_close_cursor:='N';
        end if;
        l_tot_predicate_cnt := l_predicate_cnt+l_tot_predicate_cnt;

        IF l_predicate1 IS NOT NULL THEN
           IF l_predicate IS NOT NULL
           THEN
             l_predicate := l_predicate||',';
           END IF;
           l_predicate := l_predicate||l_predicate1;
        END IF;

        IF l_tot_predicate_cnt = 1000 THEN
            exit; -- exit from loop2
        END IF;

     END LOOP; -- end loop2

     --kchaitan by the time we come out of loop2
     -- we will have predicate with not more than 1000
     --params
--
     IF (l_debug_mode = 'Y') THEN
       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Predicate = '||l_predicate, 3);
     END IF;
--
-- 5660584, pqe base bug 5638103
/* bug 5638103
--bug: 3696446
     IF (length(l_predicate) IS NULL) THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;
     END IF;
--end bug 3696446
*/

    -- 5660584, pqe base bug 5638103
    -- below part is applicable only if l_predicate is not null

    IF l_predicate is not null THEN

     --first select stmt - get all parents along the branch of the element
     --second select stmt - get direct child of all parents
     --third select stmt - get input element
        if l_sql1 is not null then
           l_sql1 := l_sql1||' or ';
        end if;

        l_sql1 :='object_id_to1 IN ('||
                 l_predicate||
                 ') ';
     END IF; -- IF l_predicate is not null THEN
     IF processing_completed = 'Y' THEN
         exit; -- exit from loop1
     END IF;
end loop; -- by kchaitan end loop1
     IF l_sql1 is not null THEN
     l_sql :=
              ' SELECT a.project_id, a.element_version_id,'||
              ' a.object_type, b.PLANNED_EFFORT, '||
              ' NVL(a.wbs_level,0), b.scheduled_start_date+NVL(b.scheduled_start_date_rollup,0), '||
              ' b.scheduled_finish_date+NVL(b.scheduled_finish_date_rollup,0), c.object_id_from1, '||
              ' c.object_type_from FROM '||
              ' pa_proj_element_versions a, pa_proj_elem_ver_schedule b, '||
              ' pa_object_relationships c, pa_proj_elements d WHERE '||
              ' a.element_version_id = c.object_id_to1(+) AND '||
              ' c.relationship_type(+)= '||''''||'S'||''''||' AND '||
              ' a.project_id = b.project_id AND '||
              ' a.element_version_id = b.element_version_id AND '||
              ' a.proj_element_id = d.proj_element_id AND '||
            --  ' d.link_task_flag = '||''''||'N'||''''||' and '||
              ' a.element_version_id IN ('||
              ' SELECT object_id_from1 FROM '||
              ' pa_object_relationships CONNECT BY '||
              ' PRIOR object_id_from1 = object_id_to1 '||
              ' AND RELATIONSHIP_TYPE = prior relationship_type '||
              ' AND relationship_type = '||''''||'S'||''''||
              ' START WITH ('||
              l_sql1||
              ') ' ||
              ' and relationship_type = '||''''||'S'||''''||
              ') UNION '||
              ' SELECT distinct a.project_id, a.element_version_id, '||
              ' a.object_type, b.PLANNED_EFFORT, '||
              ' nvl(a.wbs_level,0), b.scheduled_start_date+NVL(b.scheduled_start_date_rollup,0), '||
              ' b.scheduled_finish_date+NVL(b.scheduled_finish_date_rollup,0), c.object_id_from1, '||
              ' c.object_type_from FROM '||
              ' pa_proj_element_versions a, pa_proj_elem_ver_schedule b, '||
              ' pa_object_relationships c, pa_proj_elements d WHERE '||
              ' a.element_version_id = c.object_id_to1 AND '||
              ' c.relationship_type = '||''''||'S'||''''||' AND '||
              ' a.project_id = b.project_id AND '||
              ' a.element_version_id = b.element_version_id AND '||
              ' a.proj_element_id = d.proj_element_id AND '|| -- 3305199
              -- ' a.element_version_id = d.proj_element_id AND '||
              --' d.link_task_flag = '||''''||'N'||''''||' AND '||
              ' c.object_id_from1 IN ('||
              ' select object_id_from1 FROM '||
              ' pa_object_relationships CONNECT BY '||
              ' PRIOR object_id_from1 = object_id_to1 '||
              ' AND RELATIONSHIP_TYPE = prior relationship_type '||
              ' AND relationship_type = '||''''||'S'||''''||
              ' START WITH ('||
              l_sql1||
              ')' ||
              ' AND relationship_type = '||''''||'S'||''''||
              ')';
--
--
     --dbms_output.put_line('after');
--
     -- l_cnt := 0; -- 5660584, pqe base bug 5638103
     OPEN l_cur FOR l_sql;
     LOOP

        FETCH l_cur INTO l_project_id,
                         l_element_version_id,
                         l_object_type,
                         l_planned_effort,
                         l_wbs_level,
                         l_start_date,
                         l_finish_date,
                         l_parent_id,
                         l_parent_object_type;
        EXIT WHEN l_cur%NOTFOUND;
        l_cnt := l_cnt + 1; -- 5660584, pqe base bug 5638103
--
        l_proj_id_tbl(l_cnt) := l_project_id;
        l_rollup_table(l_cnt).object_id := l_element_version_id;
        l_rollup_table(l_cnt).object_type := l_object_type;
        l_rollup_table(l_cnt).REMAINING_EFFORT1 := l_planned_effort;
        l_rollup_table(l_cnt).wbs_level := l_wbs_level;
        l_rollup_table(l_cnt).start_date1 := l_start_date;
        l_rollup_table(l_cnt).finish_date1 := l_finish_date;
        l_rollup_table(l_cnt).parent_object_id := l_parent_id;
        l_rollup_table(l_cnt).parent_object_type := l_parent_object_type;
        l_rollup_table(l_cnt).dirty_flag1 := 'N';
--
        OPEN get_system_status_code(l_element_version_id);
        FETCH get_system_status_code into l_rollup_flag;
        CLOSE get_system_status_code;
--
        l_rollup_table(l_cnt).ROLLUP_NODE1 := l_rollup_flag;
--
        --dbms_output.put_line('....count =  '||l_cnt||'....');
        --dbms_output.put_line('pid  ='||l_proj_id_tbl(l_cnt));
        --dbms_output.put_line('elem ='||l_rollup_table(l_cnt).object_id||' , parent='||l_rollup_table(l_cnt).parent_object_id);
        --dbms_output.put_line('sd   ='||l_rollup_table(l_cnt).start_date1||', fd ='||l_rollup_table(l_cnt).finish_date1);
        --dbms_output.put_line('id = '||l_element_version_id);
--
        FOR j IN p_element_versions.FIRST..p_element_versions.LAST LOOP
            IF l_element_version_id = p_element_versions(j) THEN
               l_rollup_table(l_cnt).dirty_flag1 := 'Y';
            END IF;
        END LOOP;
--
        --get the structure version id
        IF (l_rollup_table(l_cnt).object_type = 'PA_STRUCTURES') THEN
            --save structure id
            l_structure_version_id := l_rollup_table(l_cnt).object_id;
            l_baseline_proj_id := l_proj_id_tbl(l_cnt);
--
            --get template flag; will need to change when incorporating linking
            OPEN get_proj_attr_csr(l_baseline_proj_id);
            FETCH get_proj_attr_csr INTO l_template_flag, l_record_version_number;
            CLOSE get_proj_attr_csr;
        END IF;
--
     END LOOP;  --end loop for dynamic cursor
     --dbms_output.put_line('fetched = '||l_cur%ROWCOUNT);
--
     CLOSE l_cur;
     END IF; -- IF l_sql1 is not null THEN
--Moved for the final fix
      /*
      END IF; -- IF l_predicate is not null THEN
      IF processing_completed = 'Y' THEN
        exit; -- exit from loop1
     END IF;
end loop; -- by kchaitan end loop1
*/
--Moved for final fix
    IF (l_rollup_table.count = 0) THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;
     END IF;
     -- end changes for bug 5638103

     PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE(
          p_debug_mode => 'N',
          p_data_structure         => l_rollup_table,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          x_process_number         => l_process_number,
          p_process_flag1          => 'Y',
          p_partial_process_flag1  => 'N',  --bug 4020077
          p_partial_dates_flag1    => 'Y',
          p_partial_effort_flag1   => 'Y',
          p_process_rollup_flag1   => 'Y',
          p_process_effort_flag1   => 'Y');
--
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSE
        IF ((PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_lnk_task_project_id) ='N') AND
           (PA_RELATIONSHIP_UTILS.IS_AUTO_ROLLUP(l_lnk_task_project_id) = 'Y')) OR
           ((PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_lnk_task_project_id) ='Y') AND
           (PA_RELATIONSHIP_UTILS.IS_AUTO_ROLLUP(l_lnk_task_project_id) = 'Y') AND
            ((PA_PROJECT_STRUCTURE_UTILS.get_structrue_version_status(l_lnk_task_project_id, l_structure_version_id) <> 'STRUCTURE_PUBLISHED')
             OR ( p_published_str_ver_id = l_structure_version_id))  --bug5861729
             )THEN
              FOR i IN l_rollup_table.FIRST..l_rollup_table.LAST LOOP
                  l_sch_start_date_tbl(i) := l_rollup_table(i).start_date1;
                  l_sch_finish_date_tbl(i) := l_rollup_table(i).finish_date1;
                  l_effort_tbl(i) := l_rollup_table(i).remaining_effort1;
                  l_elem_ver_id_tbl(i) := l_rollup_table(i).object_id;
              END LOOP;
--
              FOR i IN l_rollup_table.FIRST..l_rollup_table.LAST LOOP
                  SELECT scheduled_start_date, scheduled_finish_date
                    into l_old_sch_st_date_tbl(i), l_old_sch_fn_date_tbl(i)
                    FROM pa_proj_elem_ver_schedule
                   WHERE project_id = l_proj_id_tbl(i)
                     AND element_version_id = l_elem_ver_id_tbl(i);
              END LOOP;
--
              FORALL i IN l_rollup_table.FIRST..l_rollup_table.LAST
                  UPDATE pa_proj_elem_ver_schedule
                     SET scheduled_start_date = l_sch_start_date_tbl(i),
                         scheduled_finish_date = l_sch_finish_date_tbl(i),
                         planned_effort = l_effort_tbl(i),
                         duration = l_sch_finish_date_tbl(i) - l_sch_start_date_tbl(i) + 1,
                         last_update_date = sysdate,
                         last_updated_by = FND_GLOBAL.USER_ID,
                         last_update_login = FND_GLOBAL.LOGIN_ID
                   WHERE project_id = l_proj_id_tbl(i)
                     AND element_version_id = l_elem_ver_id_tbl(i)
                     AND ( scheduled_start_date <> l_sch_start_date_tbl(i) OR     -- Bug 6719725
                           scheduled_finish_date <> l_sch_finish_date_tbl(i) OR
                           planned_effort <> l_effort_tbl(i)
                     );
--
                   -- Upon changes on a Task's Scheduled Dates.
              FOR i IN l_rollup_table.first..l_rollup_table.last LOOP

                    --bug 4153366
                    IF i = l_rollup_table.last
                    THEN
                       l_assgn_context := 'UPDATE';
                    ELSE
                       l_assgn_context := 'INSERT_VALUES';
                    END IF;
                    --bug 4153366

                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Before calling PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates', 3);
                   END IF;

                    PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates(
                                   p_element_version_id     => l_elem_ver_id_tbl(i),
                                   p_old_task_sch_start     => l_old_sch_st_date_tbl(i),
                                   p_old_task_sch_finish    => l_old_sch_fn_date_tbl(i),
                                   p_new_task_sch_start     => l_sch_start_date_tbl(i),
                                   p_new_task_sch_finish    => l_sch_finish_date_tbl(i),
                                   p_context                => l_assgn_context,          --4153366
                                   x_res_assignment_id_tbl  => l_res_asgmt_id_tbl,
                                   x_planning_start_tbl     => l_planning_start_tbl,
                                   x_planning_end_tbl       => l_planning_end_tbl,
                                   x_return_status          => x_return_status);

                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'After calling PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates x_return_status='||x_return_status, 3);
                   END IF;

                    IF x_return_status = FND_API.G_RET_STS_ERROR then
                       RAISE FND_API.G_EXC_ERROR;
                    END IF;
              END LOOP;
        ELSE
            FOR i IN l_rollup_table.FIRST..l_rollup_table.LAST LOOP
                l_sch_start_date_tbl(i) := l_rollup_table(i).start_date1;
                l_sch_finish_date_tbl(i) := l_rollup_table(i).finish_date1;
                l_effort_tbl(i) := l_rollup_table(i).remaining_effort1;
                l_elem_ver_id_tbl(i) := l_rollup_table(i).object_id;
            END LOOP;
--
            FOR i IN l_rollup_table.FIRST..l_rollup_table.LAST LOOP
                SELECT scheduled_start_date into l_old_sch_st_date_tbl(i)
                  FROM pa_proj_elem_ver_schedule
                 WHERE project_id = l_proj_id_tbl(i)
                   AND element_version_id = l_elem_ver_id_tbl(i);
            END LOOP;
--
            FORALL i IN l_rollup_table.FIRST..l_rollup_table.LAST
                UPDATE pa_proj_elem_ver_schedule
                   SET scheduled_start_date_rollup = l_sch_start_date_tbl(i) - scheduled_start_date,
                       scheduled_finish_date_rollup = l_sch_finish_date_tbl(i) - scheduled_finish_date,
                       last_update_date = sysdate,
                       last_updated_by = FND_GLOBAL.USER_ID,
                       last_update_login = FND_GLOBAL.LOGIN_ID
                 WHERE project_id = l_proj_id_tbl(i)
                   AND element_version_id = l_elem_ver_id_tbl(i)
                   AND(scheduled_start_date_rollup <>(l_sch_start_date_tbl(i) - scheduled_start_date) OR -- Bug 6719725
                       scheduled_finish_date_rollup <> (l_sch_finish_date_tbl(i) - scheduled_finish_date)
                   );
--
        END IF; --end if for checking versions enabled and checking auto_roolup

--bug 4416432 issue # 5 and 6
--call baseline dates, update project dates and auto-copy txn dates apis
--for the parent project.
            FOR i IN l_rollup_table.FIRST..l_rollup_table.LAST LOOP
                IF l_rollup_table(i).object_type = 'PA_STRUCTURES'
                THEN
                   l_versioning := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_proj_id_tbl(i));
                   IF (l_versioning = 'N') THEN
                      OPEN get_scheduled_dates(l_proj_id_tbl(i), l_rollup_table(i).object_id);
                      FETCH get_scheduled_dates into l_get_sch_dates_cur;
                      CLOSE get_scheduled_dates;

                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Before calling PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES', 3);
                   END IF;

                      PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
                           p_validate_only          => FND_API.G_FALSE
                          ,p_project_id             => l_proj_id_tbl(i)
                          ,p_date_type              => 'SCHEDULED'
                          ,p_start_date             => l_get_sch_dates_cur.scheduled_start_date
                          ,p_finish_date            => l_get_sch_dates_cur.scheduled_finish_date
                          ,p_record_version_number  => l_record_version_number
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data );

                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'After calling PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES x_return_status='||x_return_status, 3);
                   END IF;

                      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                          RAISE FND_API.G_EXC_ERROR;
                      END IF;
                   END IF;

                   IF (l_versioning = 'N') THEN
                    --baseline
                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Before calling PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION', 3);
                   END IF;

                      PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION(
                          p_commit => FND_API.G_FALSE,
                          p_structure_version_id => l_rollup_table(i).object_id,
                          x_return_status => x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);

                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'After calling PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION x_return_status='||x_return_status, 3);
                   END IF;


                     If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
                         x_msg_count := FND_MSG_PUB.count_msg;
                         if x_msg_count = 1 then
                            x_msg_data := x_msg_data;
                         end if;
                         raise FND_API.G_EXC_ERROR;
                     end if;
                   END IF;
                   --end baseline changes

                   --auto sync changes
                   OPEN get_structure_id(l_rollup_table(i).object_id);
                   FETCH get_structure_id into l_struc_project_id, l_structure_id;
                   CLOSE get_structure_id;

                  --auto sync changes
                  IF ((PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_structure_id) = 'Y') AND
                     (PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_struc_project_id) = 'SHARE_FULL')) AND
                     (l_versioning = 'N') THEN
                     --copy to transaction dates
                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'Before calling  PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES', 3);
                   END IF;

                     PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES(
                         p_validate_only => FND_API.G_FALSE
                        ,p_project_id => l_struc_project_id
                        ,x_return_status => x_return_status
                        ,x_msg_count => x_msg_count
                        ,x_msg_data => x_msg_data
                         );

                   IF (l_debug_mode = 'Y') THEN
                       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 'After calling  PA_PROJECT_DATES_PUB.COPY_PROJECT_DATESx_return_status='||x_return_status, 3);
                   END IF;

                     If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
                         x_msg_count := FND_MSG_PUB.count_msg;
                         if x_msg_count = 1 then
                            x_msg_data := x_msg_data;
                         end if;
                         raise FND_API.G_EXC_ERROR;
                     end if;
                   END IF;
                END IF; --<<l_rollup_table(i).object_type = 'PA_STRUCTURES'>>
             END LOOP;
--end bug 4416432 issue # 5 and 6

     END IF; --end if for return status after calling pa_schedule_objects_pvt.generate_schedule
--
--     x_return_status := FND_API.G_RET_STS_SUCCESS;
--
  EXCEPTION
    WHEN excp_resource_busy THEN        -- Bug 6719725
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to Rollup_From_Subproject_PVT;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;

      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                              p_procedure_name => 'Rollup_From_Subproject',
                              p_error_text     => 'The Strucuture of one of the project in program hierarchy is currently being updated by another process. Please re-submit the process update after sometime.');

      RAISE;
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to Rollup_From_Subproject_PVT;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to Rollup_From_Subproject_PVT;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                              p_procedure_name => 'Rollup_From_Subproject_Unltd',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
	  END Rollup_From_Subproject_Unltd;

	 /* Bug 6854670
 	  * This is a wrapper procedure which simply converts the parameter from type PA_NUM_1000_NUM
 	  * to SYSTEM.PA_NUM_TBL_TYPE and delegates the processing to Rollup_From_Subproject_Unltd
 	  * This procedure should be there to maintain compatibility with calls from online flow
 	  */
 	 PROCEDURE Rollup_From_Subproject(
 	     p_api_version                       IN  NUMBER      := 1.0
 	    ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
 	    ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
 	    ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
 	    ,p_validation_level                  IN  VARCHAR2    := 100
 	    ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
 	    ,p_debug_mode                        IN  VARCHAR2    := 'N'
 	    ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 	    ,p_element_versions                  IN  PA_NUM_1000_NUM
		,p_published_str_ver_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM  --bug5861729
 	    ,x_return_status                     OUT  NOCOPY VARCHAR2
 	    ,x_msg_count                         OUT  NOCOPY NUMBER
 	    ,x_msg_data                          OUT  NOCOPY VARCHAR2
 	                                        )
 	   IS

 	   l_element_versions    SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
 	   l_debug_mode          VARCHAR2(1);

 	   BEGIN

 	         l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

 	         IF (l_debug_mode = 'Y') THEN
 	                 pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.ROLLUP_FROM_SUBPROJECT', 'BEGIN', 3);
 	         END IF;

 	         IF (p_element_versions.count = 0) THEN
 	                 x_return_status := FND_API.G_RET_STS_SUCCESS;

 	                 IF (l_debug_mode = 'Y') THEN
 	                         pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.ROLLUP_FROM_SUBPROJECT', 'p_element_versions.COUNT is 0', 3);
 	                 END IF;

 	                 return;
 	         END IF;

 	         FOR i IN p_element_versions.FIRST .. p_element_versions.LAST LOOP
 	                 l_element_versions.extend;
 	                 l_element_versions(i) := p_element_versions(i);
 	         END LOOP;

 	         -- Call Rollup_From_Subproject_Unltd
 	         Rollup_From_Subproject_Unltd(p_api_version        => p_api_version,
 	                                 p_init_msg_list                => p_init_msg_list,
 	                                 p_commit                => p_commit,
 	                                 p_validate_only                => p_validate_only,
 	                                 p_validation_level        => p_validation_level,
 	                                 p_calling_module        => p_calling_module,
 	                                 p_debug_mode                => p_debug_mode,
 	                                 p_max_msg_count                => p_max_msg_count,
 	                                 p_element_versions        => l_element_versions,
 	                                 x_return_status                => x_return_status,
 	                                 x_msg_count                => x_msg_count,
 	                                 x_msg_data                => x_msg_data);

 	         IF (l_debug_mode = 'Y') THEN
 	                 pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.ROLLUP_FROM_SUBPROJECT', 'END', 3);
 	         END IF;

 	   END Rollup_From_Subproject;

-- API name                      : Tasks_Rollup_Unlimited
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version                       IN  NUMBER      := 1.0
-- p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level                  IN  VARCHAR2    := 100
-- p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                        IN  VARCHAR2    := 'N'
-- p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_versions                  IN  pa_element_version_id_tbl_typ
-- x_return_status                     OUT  VARCHAR2
-- x_msg_count                         OUT  NUMBER
-- x_msg_data                          OUT  VARCHAR2

-- This procedure is created as a wrapper api for tasks_rollup,
-- to overcome the limitations of Tasks_Rollup api,
-- which works only for 1000 tasks.
-- The reason for not changing the Tasks_Roolup api is that it is also
-- being called directly from Self-Service (update tasks page), and we
-- cannot use PL/SQL table as an input/output parameter

PROCEDURE TASKS_ROLLUP_UNLIMITED(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_element_versions                  IN  pa_element_version_id_tbl_typ
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
    l_element_ver_ids      PA_NUM_1000_NUM := PA_NUM_1000_NUM();
    l_count number :=0;
BEGIN

     IF (p_debug_mode = 'Y') THEN
       pa_debug.debug('PA_STRUCT_TASK_ROLLUP_PUB.Tasks_Rollup_Unlimited BEGIN');
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
       savepoint TASKS_ROLLUP_UNLIMITED_PUB;
     END IF;

     If (p_element_versions.count = 0) THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;
     END IF;

     FOR i in 1..p_element_versions.count LOOP
    l_count := l_count +1;

    IF (l_count mod 1000) = 0 then

       -- 1000 th record from table is reached
       l_element_ver_ids.extend;
       l_element_ver_ids(l_element_ver_ids.count) := p_element_versions(i);
       -- Call api which takes array of 1000
           Tasks_Rollup(
            p_api_version       => p_api_version
           ,p_init_msg_list     => p_init_msg_list
           ,p_commit            => p_commit
           ,p_validate_only     => p_validate_only
           ,p_validation_level      => p_validation_level
           ,p_calling_module        => p_calling_module
           ,p_debug_mode        => p_debug_mode
           ,p_max_msg_count     => p_max_msg_count
           ,p_element_versions      => l_element_ver_ids
           ,x_return_status             => x_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data
           );
           --Added by rtarway for BUG 4349474
       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               RAISE  FND_API.G_EXC_ERROR;
       END IF;
       -- delete the array 100 records are reached
       l_element_ver_ids.delete;
    ELSE
       l_element_ver_ids.extend;
       l_element_ver_ids(l_element_ver_ids.count) := p_element_versions(i);
    END IF;
     END LOOP;

     IF l_element_ver_ids.count > 0 THEN
    -- Call Tasks_Rollup for remaining records in array if any
           Tasks_Rollup(
            p_api_version       => p_api_version
           ,p_init_msg_list     => p_init_msg_list
           ,p_commit            => p_commit
           ,p_validate_only     => p_validate_only
           ,p_validation_level      => p_validation_level
           ,p_calling_module        => p_calling_module
           ,p_debug_mode        => p_debug_mode
           ,p_max_msg_count     => p_max_msg_count
           ,p_element_versions      => l_element_ver_ids
           ,x_return_status             => x_return_status
           ,x_msg_count         => x_msg_count
           ,x_msg_data          => x_msg_data
           );
            --Added by rtarway for BUG 4349474
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
               RAISE  FND_API.G_EXC_ERROR;
        END IF;
     END IF;


     IF (p_commit = FND_API.G_TRUE) THEN
       commit;
     END IF;

     x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASKS_ROLLUP_UNLIMITED_PUB;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASKS_ROLLUP_UNLIMITED_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                              p_procedure_name => 'Tasks_Rollup_Unlimited',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END TASKS_ROLLUP_UNLIMITED;


-- API name                      : Tasks_Rollup
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version                       IN  NUMBER      := 1.0
-- p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level                  IN  VARCHAR2    := 100
-- p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                        IN  VARCHAR2    := 'N'
-- p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_element_versions                  IN  PA_NUM_1000_NUM
-- x_return_status                     OUT  VARCHAR2
-- x_msg_count                         OUT  NUMBER
-- x_msg_data                          OUT  VARCHAR2


  Procedure Tasks_Rollup(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_max_msg_count                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_element_versions                  IN  PA_NUM_1000_NUM
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                       )
  IS

    l_rollup_table     PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE;
    l_process_number   NUMBER;

    TYPE t_proj_id_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    l_proj_id_tbl t_proj_id_table;

--added for bulk update
    TYPE t_schDate_Tbl IS TABLE Of DATE INDEX BY BINARY_INTEGER;
    l_old_sch_st_date_tbl t_schDate_Tbl;
    l_old_sch_fn_date_tbl t_schDate_Tbl;
    l_sch_start_date_tbl t_schDate_Tbl;
    l_sch_finish_date_tbl t_schDate_Tbl;
    l_effort_tbl t_proj_id_table;
    l_elem_ver_id_tbl t_proj_id_table;

    l_res_asgmt_id_tbl SYSTEM.PA_NUM_TBL_TYPE;
    /* Bug #: 3305199 SMukka                                                         */
    /* Changing data type from PA_PLSQL_DATATYPES.IdTabTyp to SYSTEM.pa_num_tbl_type */
    /*l_planning_start_tbl PA_PLSQL_DATATYPES.NumTabTyp;                             */
    /*l_planning_end_tbl PA_PLSQL_DATATYPES.NumTabTyp;                               */
    l_planning_start_tbl SYSTEM.pa_date_tbl_type;
    l_planning_end_tbl SYSTEM.pa_date_tbl_type;

    TYPE DYNAMIC_CUR IS REF CURSOR;
    l_cur DYNAMIC_CUR;
    l_sql VARCHAR2(32767);
    l_predicate VARCHAR2(32767);
    l_predicate2 VARCHAR2(32767);
    l_index NUMBER;

    l_cnt NUMBER;

    l_CursorId Integer;
    l_update_stmt VARCHAR2(32767);
    l_RowsUpdated NUMBER;

    l_project_id NUMBER;
    l_element_version_id NUMBER;
    l_object_type VARCHAR2(30);
    l_wbs_level NUMBER;
    l_start_date DATE;
    l_finish_date DATE;
    l_parent_id NUMBER;
    l_parent_object_type VARCHAR2(30);

    l_duration NUMBER;
    l_duration_days NUMBER;
    l_calendar_id NUMBER;

    l_structure_version_id NUMBER;
    l_baseline_proj_id     NUMBER;
    l_versioning           VARCHAR2(1);
    l_planned_effort       PA_PROJ_ELEM_VER_SCHEDULE.PLANNED_EFFORT%TYPE;

    --bug 4290472, rtarway
    str_start_date DATE;
    str_end_date DATE;


    CURSOR c_get_project_dates (l_project_id NUMBER) IS
         SELECT START_DATE, COMPLETION_DATE
         FROM  PA_PROJECTS_ALL
         WHERE PROJECT_ID = l_project_id;

    --bug 4290472, rtarway

-- anlee
-- Dates changes
    l_template_flag VARCHAR2(1);
    l_record_version_number NUMBER;

    cursor get_proj_attr_csr(c_project_id NUMBER)
    IS
    SELECT template_flag, record_version_number
    FROM pa_projects_all
    WHERE project_id = c_project_id;
-- End of changes

    cursor c1(c_child_element_id NUMBER) IS
      select b.project_id, b.element_version_id
        from pa_object_relationships a,
             pa_proj_element_versions b
       where a.relationship_type = 'L'
         and a.object_id_to1 = c_child_element_id
         and a.object_type_from = 'PA_TASKS'
         and a.object_id_from1 = b.element_version_id
         and a.object_type_from = b.object_type;
    c1_rec c1%ROWTYPE;

-- hyau get calendar id to calculate duration
    cursor get_calendar_id_csr(c_project_id NUMBER, c_element_version_id NUMBER)
    IS
    SELECT calendar_id
    FROM   pa_proj_elem_ver_schedule
    WHERE  element_version_id = c_element_version_id
    AND    project_id = c_project_id;

-- hsiu added for bulk update
    CURSOR get_scheduled_dates(c_project_Id NUMBER, c_element_version_id NUMBER)
    IS
    select scheduled_start_date, scheduled_finish_date
    from pa_proj_elem_ver_schedule
    where project_id = c_project_id
    and element_version_id = c_element_version_id;
    l_get_sch_dates_cur get_scheduled_dates%ROWTYPE;

-- hsiu auto sync changes
    cursor get_structure_id(c_structure_ver_id NUMBER)
    IS
    SELECT project_id, proj_element_id
    FROM   pa_proj_element_versions
    where  element_version_id = c_structure_ver_id;

    l_structure_id     NUMBER;
    l_struc_project_id NUMBER;

-- hsiu added for task partial rollup
    CURSOR get_rollup_flag(c_element_version_id NUMBER)
    IS
    SELECT PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_STUS_ACTION_ALLOWED(
             a.STATUS_CODE, 'PLAN_ROLLUP')
    FROM pa_proj_elements a, pa_proj_element_versions b
    WHERE a.proj_element_id = b.proj_element_id
    AND a.project_id = b.project_id
    AND b.element_version_id = c_element_version_id;

    --hsiu: bug 2660330
    --status control is not used anymore
    CURSOR get_system_status_code(c_element_version_id NUMBER)
    IS
    SELECT decode(project_system_status_code, 'CANCELLED', 'N', 'Y')
    FROM pa_proj_elements a, pa_proj_element_versions b,
         pa_project_statuses c
    where a.proj_element_id = b.proj_element_id
    and a.project_id = b.project_id
    and b.element_version_id = c_element_version_id
    and a.status_code = c.project_status_code
    and c.status_type = 'TASK';

    l_rollup_flag  VARCHAR2(1);
--
    --Bug No 3450684
    CURSOR get_str_ver_ic_lnk_tasks(cp_structure_Version_id NUMBER) IS
    SELECT pora.object_id_from1 parent_lnk_task_ver_id,
           pora.object_id_to1 struct_version_id,
           pora.object_id_from2 parent_proj_id,
       porb.object_id_from1 parent_task_ver_id
      FROM pa_object_relationships pora,
           pa_object_relationships porb
     WHERE pora.object_id_to1 = cp_structure_Version_id
       AND pora.RELATIONSHIP_TYPE = 'LW'
       AND pora.object_id_from2 <> pora.object_id_to2
       AND pora.OBJECT_TYPE_TO = 'PA_STRUCTURES'
       AND pora.OBJECT_TYPE_FROM = 'PA_TASKS'
       AND pora.object_id_from1 = porb.object_id_to1
       AND porb.RELATIONSHIP_TYPE = 'S'
       AND porb.OBJECT_TYPE_TO = 'PA_TASKS'
       AND porb.OBJECT_TYPE_FROM = 'PA_TASKS';
       get_str_ver_ic_lnk_tasks_rec get_str_ver_ic_lnk_tasks%ROWTYPE;

    CURSOR chk_str_working_ver(cp_proj_id NUMBER, cp_str_ver_id NUMBER) IS
    SELECT 1
      FROM pa_proj_elem_ver_structure
     WHERE project_id = cp_proj_id
    -- AND proj_element_id = p_structure_id
       AND element_version_id = ( select parent_structure_version_id
                                   from pa_proj_element_versions where element_version_id=cp_str_ver_id) --bug 4287813
       AND status_code <> 'STRUCTURE_PUBLISHED';
       chk_str_working_ver_rec chk_str_working_ver%ROWTYPE;

    CURSOR get_parent_task_str_ver(cp_parent_task_ver_id NUMBER) IS
    SELECT PARENT_STRUCTURE_VERSION_ID,project_id
      FROM pa_proj_element_versions
     WHERE element_version_id = cp_parent_task_ver_id;
     parent_task_str_ver_id NUMBER;
     parent_task_proj_id NUMBER;
--
     l_parent_task_ver_id_tbl PA_NUM_1000_NUM := PA_NUM_1000_NUM();
     l_dummy NUMBER;

     l_assgn_context     VARCHAR2(30);   --bug 4153366
     l_debug_mode        varchar2(1) := 'N';--added by rtarway, 4218977
     g_module_name       varchar2(200) := 'PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP';--added by rtarway, 4218977
--

--bug 4296915
  CURSOR check_pub_str(cp_project_id NUMBER, cp_str_ver_id NUMBER)
  IS
    SELECT 'x'
      FROM pa_proj_elem_ver_structure
     WHERE project_id=cp_project_id
       AND element_version_id = cp_str_ver_id
       AND status_code = 'STRUCTURE_PUBLISHED'
       ;
   l_dummy_char       VARCHAR2(1);
--end bug 4296915


--bug 4541039
--select all the programs up in the hierarchy and pass it to rollup_from_subprojects
--in order to propagate the schedule dates upto the top of the hierarchy.
    CURSOR cur_select_hier(c_project_id NUMBER, c_structure_version_id NUMBER)
    IS
      SELECT object_id_from1, object_id_from2, object_id_to1, object_id_to2
        FROM pa_object_relationships
        START with object_id_to2 = c_project_id and relationship_type = 'LW' and object_id_to1 = c_structure_version_id
        CONNECT by object_id_to2 = prior object_id_from2
        AND relationship_type = prior relationship_type;
  l_rollup_from_sub_project    VARCHAR2(1);
--end bug  4541039

  begin

     l_debug_mode := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');--added by rtarway, 4218977

     IF (l_debug_mode = 'Y') THEN
       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP', 'Entered...', 3);
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
       savepoint TASKS_ROLLUP_PVT;
     END IF;

     IF (l_debug_mode = 'Y') THEN
       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP', 'Performing validations',3);
     END IF;

     If (p_element_versions.count = 0) THEN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       return;
     END IF;

     l_index := 1;
     l_predicate := '';
     l_predicate2 := '';
     LOOP
       l_predicate := l_predicate||to_char(p_element_versions(l_index));
       l_predicate2 := l_predicate2||to_char(p_element_versions(l_index));
       exit when l_index = p_element_versions.count;
       l_predicate := l_predicate||',';
       l_predicate2 := l_predicate2||',';
       l_index := l_index + 1;
     END LOOP;

--dbms_output.put_line('Predicate => '||l_predicate);
--dbms_output.put_line('Predicate2 => '||l_predicate2);

     IF (l_debug_mode = 'Y') THEN
       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Predicate = '||l_predicate,3);
       pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Predicate2 = '||l_predicate2,3);
     END IF;

--first select stmt - get all parents along the branch of the element
--second select stmt - get direct child of all parents
--third select stmt - get input element
--  hsiu: removing third one because the second statment should cover it
-- FPM bug 3301192 : Added pa_proj_elements join and link_task_flag condition
     l_sql :=
              ' select a.project_id, a.element_version_id,'||
              ' a.object_type, b.PLANNED_EFFORT, '||
              ' nvl(a.wbs_level,0), b.scheduled_start_date, '||
              ' b.scheduled_finish_date, c.object_id_from1, '||
              ' c.object_type_from from '||
              ' pa_proj_element_versions a, pa_proj_elem_ver_schedule b, '||
              ' pa_object_relationships c, pa_proj_elements d where '||
              ' a.element_version_id = c.object_id_to1(+) and '||
              ' c.relationship_type(+)= '||''''||'S'||''''||' and '||
              ' a.project_id = b.project_id and '||
              ' a.element_version_id = b.element_version_id and '||
              ' a.proj_element_id = d.proj_element_id and '|| -- 3305199
              ' d.link_task_flag = '||''''||'N'||''''||' and '||
              ' a.element_version_id IN ('||
              ' select object_id_from1 from '||
              ' pa_object_relationships connect by '||
              ' prior object_id_from1 = object_id_to1 '||
              ' AND RELATIONSHIP_TYPE = prior relationship_type '||
              ' and relationship_type = '||''''||'S'||''''||
              ' start with object_id_to1 IN ('||
              l_predicate||
              ') ' ||
              ' and relationship_type = '||''''||'S'||''''||
              ') UNION '||
              ' select distinct a.project_id, a.element_version_id, '||
              ' a.object_type, b.PLANNED_EFFORT, '||
              ' nvl(a.wbs_level,0), b.scheduled_start_date, '||
              ' b.scheduled_finish_date, c.object_id_from1, '||
              ' c.object_type_from from '||
              ' pa_proj_element_versions a, pa_proj_elem_ver_schedule b, '||
              ' pa_object_relationships c, pa_proj_elements d where '||
              ' a.element_version_id = c.object_id_to1 and '||
              ' c.relationship_type = '||''''||'S'||''''||' and '||
              ' a.project_id = b.project_id and '||
              ' a.element_version_id = b.element_version_id and '||
              ' a.proj_element_id = d.proj_element_id and '|| -- 3305199
              -- ' a.element_version_id = d.proj_element_id and '||
              ' d.link_task_flag = '||''''||'N'||''''||' and '||
              ' c.object_id_from1 IN ('||
              ' select object_id_from1 from '||
              ' pa_object_relationships connect by '||
              ' prior object_id_from1 = object_id_to1 '||
              ' and relationship_type = '||''''||'S'||''''||
              ' AND RELATIONSHIP_TYPE = prior relationship_type '||
              ' start with object_id_to1 IN ('||
              l_predicate||
              ')' ||
              ' and relationship_type = '||''''||'S'||''''||
              ')';

--              ') UNION '||
--              ' select distinct a.project_id, a.element_version_id, '||
--              ' a.object_type, b.PLANNED_EFFORT, '||
--              ' nvl(a.wbs_level,0), b.scheduled_start_date, '||
--              ' b.scheduled_finish_date, c.object_id_from1, '||
--              ' c.object_type_from from '||
--              ' pa_proj_element_versions a, pa_proj_elem_ver_schedule b, '||
--              ' pa_object_relationships c where '||
--              ' a.element_version_id = c.object_id_to1(+) and '||
--              ' c.relationship_type(+)  = '||''''||'S'||''''||' and '||
--              ' a.project_id = b.project_id and '||
--              ' a.element_version_id = b.element_version_id and '||
--              ' a.element_version_id IN ('||l_predicate2||
--              ')';

--dbms_output.put_line('after');


     l_cnt := 0;
     open l_cur for l_sql;
     LOOP
       l_cnt := l_cnt + 1;
--Cannot fetch into PL/SQL table because it will create a null row when %NOTFOUND.
       FETCH l_cur into l_project_id,
                        l_element_version_id,
                        l_object_type,
                        l_planned_effort,
                        l_wbs_level,
                        l_start_date,
                        l_finish_date,
                        l_parent_id,
                        l_parent_object_type;
       exit when l_cur%NOTFOUND;

       l_proj_id_tbl(l_cnt) := l_project_id;
       l_rollup_table(l_cnt).object_id := l_element_version_id;
       l_rollup_table(l_cnt).object_type := l_object_type;
       l_rollup_table(l_cnt).REMAINING_EFFORT1 := l_planned_effort;
       l_rollup_table(l_cnt).wbs_level := l_wbs_level;
       l_rollup_table(l_cnt).start_date1 := l_start_date;
       l_rollup_table(l_cnt).finish_date1 := l_finish_date;
       l_rollup_table(l_cnt).parent_object_id := l_parent_id;
       l_rollup_table(l_cnt).parent_object_type := l_parent_object_type;
       l_rollup_table(l_cnt).dirty_flag1 := 'N';

       --hsiu added for task partial rollup
--commented out for bug 2660330
--       OPEN get_rollup_flag(l_element_version_id);
--       FETCH get_rollup_flag into l_rollup_flag;
--       CLOSE get_rollup_flag;
       OPEN get_system_status_code(l_element_version_id);
       FETCH get_system_status_code into l_rollup_flag;
       CLOSE get_system_status_code;
--done changes for bug 2660330

       l_rollup_table(l_cnt).ROLLUP_NODE1 := l_rollup_flag;

--dbms_output.put_line('....count =  '||l_cnt||'....');
--dbms_output.put_line('pid  ='||l_proj_id_tbl(l_cnt));
--dbms_output.put_line('elem ='||l_rollup_table(l_cnt).object_id||' , parent='||l_rollup_table(l_cnt).parent_object_id);
--dbms_output.put_line('sd   ='||l_rollup_table(l_cnt).start_date1||', fd ='||l_rollup_table(l_cnt).finish_date1);
--dbms_output.put_line('id = '||l_element_version_id);

       l_index := 1;
       LOOP
         if l_element_version_id = p_element_versions(l_index) then
           l_rollup_table(l_cnt).dirty_flag1 := 'Y';
         end if;
         exit when l_index = p_element_versions.count;
         l_index := l_index + 1;
       END LOOP;

       --get the structure version id
       IF (l_rollup_table(l_cnt).object_type = 'PA_STRUCTURES') THEN
         --save structure id
         l_structure_version_id := l_rollup_table(l_cnt).object_id;
         l_baseline_proj_id := l_proj_id_tbl(l_cnt);

         --get template flag; will need to change when incorporating linking
         OPEN get_proj_attr_csr(l_baseline_proj_id);
         FETCH get_proj_attr_csr INTO l_template_flag, l_record_version_number;
         CLOSE get_proj_attr_csr;
       END IF;

     END LOOP;
--dbms_output.put_line('fetched = '||l_cur%ROWCOUNT);


     close l_cur;
     --Added by rtarway, 4218977
        IF l_debug_mode = 'Y' THEN
             pa_debug.g_err_stage := 'Value of G_OP_VALIDATE_flag'||PA_PROJECT_PUB.G_OP_VALIDATE_FLAG ;
             pa_debug.write(g_module_name,pa_debug.g_err_stage,3);
        END IF;
     --If Added by rtarway, BUG 4218977
     --Added null condition, for BUG 4226832
     if (PA_PROJECT_PUB.G_OP_VALIDATE_FLAG is null OR PA_PROJECT_PUB.G_OP_VALIDATE_FLAG = 'Y' ) then

          PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE(
               p_debug_mode => 'N',
               p_data_structure         => l_rollup_table,
               x_return_status          => x_return_status,
               x_msg_count              => x_msg_count,
               x_msg_data               => x_msg_data,
               x_process_number         => l_process_number,
               p_process_flag1          => 'Y',
               p_partial_process_flag1  => 'Y',
               p_partial_dates_flag1    => 'Y',
               p_partial_effort_flag1   => 'Y',
               p_process_rollup_flag1   => 'Y',
               p_process_effort_flag1   => 'Y');
     end if;

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       RAISE FND_API.G_EXC_ERROR;
     ELSE
/*       BEGIN
         --Update the tasks
         l_CursorId := DBMS_SQL.OPEN_CURSOR;
         l_update_stmt := 'Update pa_proj_elem_ver_schedule '||
                          'set SCHEDULED_START_DATE = :sd, '||
                          'SCHEDULED_FINISH_DATE = :fd, '||
                          'PLANNED_EFFORT = :pe, '||
                          'DURATION = :dur, '||
                          'RECORD_VERSION_NUMBER = NVL(RECORD_VERSION_NUMBER,1)+1, '||
                          'LAST_UPDATE_DATE = SYSDATE, ' ||
                          'LAST_UPDATED_BY = FND_GLOBAL.USER_ID, ' ||
                          'LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID ' ||
                          'where '||
                          'project_id = :pid and element_version_id = :evid';

         --Parse statement
         DBMS_SQL.PARSE(l_CursorId, l_update_stmt, DBMS_SQL.V7);

         l_index := l_rollup_table.First;
         LOOP
           IF (p_debug_mode = 'Y') THEN
             pa_debug.debug('Binding: '||l_index||', id = '||l_rollup_table(l_index).object_id);
           END IF;
--dbms_output.put_line('Binding: '||l_index||', id = '||l_rollup_table(l_index).object_id);

-- hyau          l_duration := trunc(l_rollup_table(l_index).finish_date1 - l_rollup_table(l_index).start_date1) + 1;

-- hyau call API to get duration in hours to store to db
           OPEN get_calendar_id_csr(l_project_id, l_element_version_id);
           FETCH get_calendar_id_csr INTO l_calendar_id;
       IF  get_calendar_id_csr%NOTFOUND then
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count := 1;
          x_msg_data := 'PA_PS_NO_SCHEDULE_RECORD';
          RAISE FND_API.G_EXC_ERROR;
       end if;
           CLOSE get_calendar_id_csr;

        pa_duration_utils.get_duration(
         p_calendar_id      => l_calendar_id
                ,p_start_date       => l_rollup_table(l_index).start_date1
            ,p_end_date         => l_rollup_table(l_index).finish_date1
                ,x_duration_days    => l_duration_days
                ,x_duration_hours   => l_duration
                ,x_return_status    => x_return_status
                ,x_msg_count        => x_msg_count
                ,x_msg_data         => x_msg_data);

            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
            END IF;

         --Bind variables
           DBMS_SQL.BIND_VARIABLE(l_CursorId, ':sd', l_rollup_table(l_index).start_date1);
           DBMS_SQL.BIND_VARIABLE(l_CursorId, ':fd', l_rollup_table(l_index).finish_date1);
           DBMS_SQL.BIND_VARIABLE(l_CursorId, ':pe', l_rollup_table(l_index).REMAINING_EFFORT1);
           DBMS_SQL.BIND_VARIABLE(l_CursorId, ':dur', l_duration);
           DBMS_SQL.BIND_VARIABLE(l_CursorId, ':pid', l_proj_id_tbl(l_index));
           DBMS_SQL.BIND_VARIABLE(l_CursorId, ':evid', l_rollup_table(l_index).object_id);

           --Update rows
           l_RowsUpdated := DBMS_SQL.EXECUTE(l_CursorId);

           -- anlee
           -- Dates changes
           OPEN get_proj_attr_csr(l_proj_id_tbl(l_index));
           FETCH get_proj_attr_csr INTO l_template_flag, l_record_version_number;
           CLOSE get_proj_attr_csr;

           -- Rollup scheduled dates to the project level for templates
           -- or project without versioning
           if l_template_flag = 'Y' OR
              PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_proj_id_tbl(l_index)) = 'N' then
             if l_rollup_table(l_index).object_type = 'PA_STRUCTURES' then
               PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
                 p_validate_only          => FND_API.G_FALSE
                ,p_project_id             => l_proj_id_tbl(l_index)
                ,p_date_type              => 'SCHEDULED'
                ,p_start_date             => l_rollup_table(l_index).start_date1
                ,p_finish_date            => l_rollup_table(l_index).finish_date1
                ,p_record_version_number  => l_record_version_number
                ,x_return_status          => x_return_status
                ,x_msg_count              => x_msg_count
                ,x_msg_data               => x_msg_data );

               IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                 RAISE FND_API.G_EXC_ERROR;
               END IF;
             END IF;
           END IF;
           -- End of changes

           -- baesline changes
           IF l_rollup_table(l_index).object_type = 'PA_STRUCTURES' THEN
             l_structure_version_id := l_rollup_table(l_index).object_id;
             l_baseline_proj_id     := l_proj_id_tbl(l_index);
           END IF;
           -- end changes

           --Check for linking tasks
           OPEN c1(l_rollup_table(l_index).object_id);
           LOOP
             FETCH c1 into c1_rec;
             EXIT when c1%NOTFOUND;

             --update linking task
             DBMS_SQL.BIND_VARIABLE(l_CursorId, ':sd', l_rollup_table(l_index).start_date1);
             DBMS_SQL.BIND_VARIABLE(l_CursorId, ':fd', l_rollup_table(l_index).finish_date1);
             DBMS_SQL.BIND_VARIABLE(l_CursorId, ':dur', l_duration);
             DBMS_SQL.BIND_VARIABLE(l_CursorId, ':pid', c1_rec.project_id);
             DBMS_SQL.BIND_VARIABLE(l_CursorId, ':evid', c1_rec.element_version_id);

             IF (p_debug_mode = 'Y') THEN
               pa_debug.debug('Updating linking task '||c1_rec.element_version_id);
             END IF;
--dbms_output.put_line('Updating linking task '||c1_rec.element_version_id);
             --Update rows
             l_RowsUpdated := DBMS_SQL.EXECUTE(l_CursorId);

           END LOOP;
           CLOSE c1;

           EXIT when l_index = l_rollup_table.LAST;
           l_index := l_rollup_table.NEXT(l_index);
         END LOOP;
         DBMS_SQL.CLOSE_CURSOR(l_CursorId);
       EXCEPTION
         WHEN OTHERS THEN
           DBMS_SQL.CLOSE_CURSOR(l_CursorId);
           RAISE;
       END;
*/
if (PA_PROJECT_PUB.G_OP_VALIDATE_FLAG is null OR PA_PROJECT_PUB.G_OP_VALIDATE_FLAG = 'Y' ) then

       FOR i IN l_rollup_table.first..l_rollup_table.last LOOP
         l_sch_start_date_tbl(i) := l_rollup_table(i).start_date1;
         l_sch_finish_date_tbl(i) := l_rollup_table(i).finish_date1;
         l_effort_tbl(i) := l_rollup_table(i).remaining_effort1;
         l_elem_ver_id_tbl(i) := l_rollup_table(i).object_id;
       END LOOP;

       --bug 3305199 hsiu
       FOR i IN l_rollup_table.first..l_rollup_table.last LOOP
         select scheduled_start_date, scheduled_finish_date
           into l_old_sch_st_date_tbl(i), l_old_sch_fn_date_tbl(i)
           from pa_proj_elem_ver_schedule
          where project_id = l_proj_id_tbl(i)
            and element_version_id = l_elem_ver_id_tbl(i);
       END LOOP;
       --end 3305199 hsiu

/* bug 3305199
   remove duration calculation
                duration = pa_duration_utils.get_total_hours(
                                               calendar_id,
                                               l_sch_start_date_tbl(i),
                                               l_sch_finish_date_tbl(i)),
*/
       FORALL i IN l_rollup_table.first..l_rollup_table.last
         UPDATE pa_proj_elem_ver_schedule
            set scheduled_start_date = l_sch_start_date_tbl(i),
                scheduled_finish_date = l_sch_finish_date_tbl(i),
                planned_effort = l_effort_tbl(i),
                duration = l_sch_finish_date_tbl(i) - l_sch_start_date_tbl(i) + 1,
                last_update_date = sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                last_update_login = FND_GLOBAL.LOGIN_ID
          where project_id = l_proj_id_tbl(i)
            and element_version_id = l_elem_ver_id_tbl(i) and   -- Bug 6719725
            (scheduled_start_date <> l_sch_start_date_tbl(i) or
                scheduled_finish_date <> l_sch_finish_date_tbl(i) or
                planned_effort <> l_effort_tbl(i)
            );

--BUG 4290472, rtarway
else
      --Added by rtarway for BUG 4349474
      FOR i IN l_rollup_table.first..l_rollup_table.last LOOP
         l_sch_start_date_tbl(i) := l_rollup_table(i).start_date1;
         l_sch_finish_date_tbl(i) := l_rollup_table(i).finish_date1;
         l_effort_tbl(i) := l_rollup_table(i).remaining_effort1;
         l_elem_ver_id_tbl(i) := l_rollup_table(i).object_id;
      END LOOP;


       FOR i IN l_rollup_table.first..l_rollup_table.last LOOP
         select scheduled_start_date, scheduled_finish_date
           into l_old_sch_st_date_tbl(i), l_old_sch_fn_date_tbl(i)
           from pa_proj_elem_ver_schedule
          where project_id = l_proj_id_tbl(i)
            and element_version_id = l_elem_ver_id_tbl(i);

        ---- Start of addition for bug 6393979
        If l_structure_version_id <> l_elem_ver_id_tbl(i) Then
        	if nvl(str_start_date,l_sch_start_date_tbl(i)) >= l_sch_start_date_tbl(i) then
          str_start_date := l_sch_start_date_tbl(i);
        end if;

        if nvl(str_end_date,l_sch_finish_date_tbl(i)) <= l_sch_finish_date_tbl(i) then
          str_end_date := l_sch_finish_date_tbl(i);
        end if;

        end if;
    	  --- End of addition for bug 6393979
       END LOOP;
      --Added by rtarway for BUG 4349474

       /* Commented for bug 6393979
      OPEN  c_get_project_dates(l_baseline_proj_id);
      FETCH c_get_project_dates  INTO str_start_date, str_end_date;
      CLOSE c_get_project_dates;*/

      UPDATE pa_proj_elem_ver_schedule
            set scheduled_start_date =str_start_date,
                scheduled_finish_date = str_end_date,
        duration =  str_end_date - str_start_date + 1,
                last_update_date = sysdate,
                last_updated_by = FND_GLOBAL.USER_ID,
                last_update_login = FND_GLOBAL.LOGIN_ID
          where project_id = l_baseline_proj_id
            and element_version_id = l_structure_version_id
            and (scheduled_start_date <> str_start_date or   -- Bug 6719725
                scheduled_finish_date <> str_end_date
            );
end if;
--BUG 4290472, rtarway



     -- Added by skannoji
     -- Upon changes on a Task's Scheduled Dates.
       FOR i IN l_rollup_table.first..l_rollup_table.last LOOP
          /*Smukka Bug No. 3474141 Date 03/01/2004                                    */
          /*moved PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates into plsql block        */
          BEGIN

              --bug 4153366
              IF i = l_rollup_table.last
              THEN
                 l_assgn_context := 'UPDATE';
              ELSE
                 l_assgn_context := 'INSERT_VALUES';
              END IF;
              --bug 4153366

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Before calling PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates l_assgn_context = '||l_assgn_context,3);
              END IF;

              PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates(
                                  p_element_version_id     => l_elem_ver_id_tbl(i),
                                  p_old_task_sch_start     => l_old_sch_st_date_tbl(i),
                                  p_old_task_sch_finish    => l_old_sch_fn_date_tbl(i),
                                  p_new_task_sch_start     => l_sch_start_date_tbl(i),
                                  p_new_task_sch_finish    => l_sch_finish_date_tbl(i),
                                  p_context                => l_assgn_context,          --4153366
                                  x_res_assignment_id_tbl  => l_res_asgmt_id_tbl,
                                  x_planning_start_tbl     => l_planning_start_tbl,
                                  x_planning_end_tbl       => l_planning_end_tbl,
                                  x_return_status          => x_return_status);
              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','After calling PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates x_return_status = '||x_return_status,3);
              END IF;

          EXCEPTION
              WHEN OTHERS THEN
                   fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                                           p_procedure_name => 'Tasks_Rollup',
                                           p_error_text     => SUBSTRB('PA_TASK_ASSIGNMENT_UTILS.Adjust_Asgmt_Dates:'||SQLERRM,1,240));
                   RAISE FND_API.G_EXC_ERROR;
          END;

                    IF x_return_status = FND_API.G_RET_STS_ERROR then
                        RAISE FND_API.G_EXC_ERROR;
                    End If;
        END LOOP;
        -- till here by skannoji

     --baseline changes
     l_versioning := PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(
                       l_baseline_proj_id);

     --added for rolling up to project level
     IF (l_template_flag = 'Y' OR l_versioning = 'N') THEN

       OPEN get_scheduled_dates(l_baseline_proj_id, l_structure_version_id);
       FETCH get_scheduled_dates into l_get_sch_dates_cur;
       CLOSE get_scheduled_dates;

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Before calling PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES',3);
              END IF;


       PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES (
          p_validate_only          => FND_API.G_FALSE
         ,p_project_id             => l_baseline_proj_id
         ,p_date_type              => 'SCHEDULED'
         ,p_start_date             => l_get_sch_dates_cur.scheduled_start_date
         ,p_finish_date            => l_get_sch_dates_cur.scheduled_finish_date
         ,p_record_version_number  => l_record_version_number
         ,x_return_status          => x_return_status
         ,x_msg_count              => x_msg_count
         ,x_msg_data               => x_msg_data );

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','After calling PA_PROJECT_DATES_PUB.UPDATE_PROJECT_DATES x_return_status='||x_return_status,3);
              END IF;


       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;


     IF (l_template_flag = 'N' AND l_versioning = 'N') THEN
       --baseline
              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Before calling PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION l_structure_version_id='||l_structure_version_id,3);
              END IF;

       PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION(
                       p_commit => FND_API.G_FALSE,
                       p_structure_version_id => l_structure_version_id,
                       x_return_status => x_return_status,
                       x_msg_count => x_msg_count,
                       x_msg_data => x_msg_data);

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','After calling PA_PROJECT_STRUCTURE_PVT1.BASELINE_STRUCTURE_VERSION x_return_status='||x_return_status,3);
              END IF;


       If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         x_msg_count := FND_MSG_PUB.count_msg;
         if x_msg_count = 1 then
           x_msg_data := x_msg_data;
         end if;
         raise FND_API.G_EXC_ERROR;
       end if;
     END IF;
     --end baseline changes

     END IF;

     --auto sync changes
     OPEN get_structure_id(l_structure_version_id);
     FETCH get_structure_id into l_struc_project_id, l_structure_id;
     CLOSE get_structure_id;

/* bug 3676078
     IF ((PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_structure_id) = 'Y') AND
        (PA_PROJECT_STRUCTURE_UTILS.CHECK_SHARING_ENABLED(l_struc_project_id) = 'Y')) AND
        (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_struc_project_id) = 'N') THEN
*/
     IF ((PA_WORKPLAN_ATTR_UTILS.CHECK_AUTO_DATE_SYNC_ENABLED(l_structure_id) = 'Y') AND
        (PA_PROJECT_STRUCTURE_UTILS.get_Structure_sharing_code(l_struc_project_id) = 'SHARE_FULL')) AND
        (PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(l_struc_project_id) = 'N') THEN
       --copy to transaction dates

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Before calling PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES',3);
              END IF;

       PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES(
         p_validate_only => FND_API.G_FALSE
        ,p_project_id => l_struc_project_id
        ,x_return_status => x_return_status
        ,x_msg_count => x_msg_count
        ,x_msg_data => x_msg_data
       );

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','After calling PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES x_return_status='||x_return_status,3);
              END IF;


       If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         x_msg_count := FND_MSG_PUB.count_msg;
         if x_msg_count = 1 then
           x_msg_data := x_msg_data;
         end if;
         raise FND_API.G_EXC_ERROR;
       end if;

       --copy to project level

     END IF;
     --end auto sync changes
--
--
     IF PA_PROJECT_STRUCTURE_UTILS.Check_Subproject_Exists(l_struc_project_id,l_structure_version_id, 'WORKPLAN') = 'Y' THEN
      /* 4541039 Always rollup to the parent. This will fulfill the following cases:
         1) Update Task flow
              + schedule dates are getting updated for a non-versioned project. If the sub-project is
              + schedule dates are getting updated on a working verison for a versioned project. The dates from the sub-project
                will be rolled up into the parent project.
         2) Publish flow
            In this flow, the data from sub-project published verison will be rolled up into the new published verison.
            The api will also be called for working version if the process WBS updates is already not run.
         3) Running Process Updates
            In this flow, data from the sub-projects rolls up to this project.

        --bug 4296915
        OPEN check_pub_str(l_struc_project_id,l_structure_version_id);
        FETCH check_pub_str INTO l_dummy_char;
        IF check_pub_str%FOUND
        THEN
       bug 4541039 */
        ----end bug 4296915
        --Bug No.3450684
        --Start rolling up from subproject associations

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Before calling Rollup_From_Subproject to rollup from the current project''s sub-project',3);
              END IF;

           Rollup_From_Subproject(
                p_api_version           =>  p_api_version
               ,p_init_msg_list         =>  p_init_msg_list
               ,p_commit                =>  p_commit
               ,p_validate_only         =>  p_validate_only
               ,p_validation_level      =>  p_validation_level
               ,p_calling_module        =>  p_calling_module
               ,p_debug_mode            =>  p_debug_mode
               ,p_max_msg_count         =>  p_max_msg_count
               ,p_element_versions      =>  p_element_versions  --Check with hubert
               ,x_return_status         =>  x_return_status
               ,x_msg_count             =>  x_msg_count
               ,x_msg_data              =>  x_msg_data);

              IF (l_debug_mode = 'Y') THEN
                  pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','After calling Rollup_From_Subproject to rollup from the current project''s sub-project x_return_status='||x_return_status,3);
              END IF;

--
                If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  x_msg_count := FND_MSG_PUB.count_msg;
                  if x_msg_count = 1 then
                    x_msg_data := x_msg_data;
                  end if;
                  raise FND_API.G_EXC_ERROR;
                end if;
         /* bug 4541039
         --bug 4296915
         END IF;
         CLOSE check_pub_str;
        --end bug 4296915
         bug 4541039 */
     END IF; --end if for checking existence of subproject association
--
  --The following code is added to rollup schedule dates to the top of the program hierarchy. Currently there is an issue
  --the schedules dates rollup. The dates are not rollin up to the top if the hierarchy has more than 2 levels.
  --
  --The cursor cur_select_hier will select all the programs in the hierarchy.
  --object_id_from2 is the parent project
  --object_id_to2 is the sub project of the parent sub-project.
  --
  --Here l_struc_project_id is the current sub-project. This sub-project may be getting updated or getting published if its versioend.
  -- Rollup happnes from the following:
     --published version of the sub-project to the working version of the program.
     --published verion of the sub-project to the published verison of the program if program is versioned disabled.
     --no rollup happens from a published verison of versioned program to its program(that is to third level).

----bug 4541039

                     IF (l_debug_mode = 'Y') THEN
                         pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','l_struc_project_id='||l_struc_project_id,3);
                     END IF;

   FOR cur_select_hier_rec in cur_select_hier( l_struc_project_id, l_structure_version_id  ) LOOP   ----bug 4541039

     --do not rollup from working version except when the current project is getting published.
     IF l_struc_project_id <> cur_select_hier_rec.object_id_to2
        AND  PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(cur_select_hier_rec.object_id_to2) = 'Y'
     THEN
        l_rollup_from_sub_project := 'N';
     ELSE
        l_rollup_from_sub_project := 'Y';
     END IF;


                     IF (l_debug_mode = 'Y') THEN
                         pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','l_rollup_from_sub_project='||l_struc_project_id,3);
                     END IF;

     IF l_rollup_from_sub_project = 'Y'
       THEN
----bug 4541039

        --Getting all the linking information from linking task
        --provide the sub-project structure verison id.
        OPEN get_str_ver_ic_lnk_tasks(cur_select_hier_rec.object_id_to1);   -- bug 4541039. Provide the sub-project structure version.
        LOOP
           FETCH get_str_ver_ic_lnk_tasks INTO get_str_ver_ic_lnk_tasks_rec;
           EXIT WHEN get_str_ver_ic_lnk_tasks%NOTFOUND;
--
/*
           --Getting the parent_structure_version_id from the given task version id
           --Trying to execute the following if block only when the project id changes
           IF parent_task_proj_id IS NULL OR (parent_task_proj_id = get_str_ver_ic_lnk_tasks_rec.parent_proj_id) THEN
              OPEN get_parent_task_str_ver(get_str_ver_ic_lnk_tasks_rec.parent_task_ver_id);
              FETCH get_parent_task_str_ver INTO parent_task_str_ver_id,
                                              parent_task_proj_id;
              EXIT WHEN get_parent_task_str_ver%NOTFOUND;
              CLOSE get_parent_task_str_ver;
           END IF;
*/
--
           IF PA_WORKPLAN_ATTR_UTILS.CHECK_WP_VERSIONING_ENABLED(get_str_ver_ic_lnk_tasks_rec.parent_proj_id) ='Y' THEN

              --Checking to see if the parent structure version is working version.
              OPEN chk_str_working_ver(get_str_ver_ic_lnk_tasks_rec.parent_proj_id,
                                       get_str_ver_ic_lnk_tasks_rec.parent_task_ver_id);  --bug 4287813
              FETCH chk_str_working_ver into l_dummy;
              IF chk_str_working_ver%NOTFOUND THEN
                 CLOSE chk_str_working_ver;
              ELSE
                  --bug 4296915
                  ---check if the current structure version is a published or working ( this api is called from update task as well as publishing)
                 --check the if the sub-project from where the rollup happens is a publsihed version or not.
                 OPEN check_pub_str(cur_select_hier_rec.object_id_to2,cur_select_hier_rec.object_id_to1);  --bug 4541039 Provide the sub-project structure verison.
                  FETCH check_pub_str INTO l_dummy_char;
                  IF check_pub_str%FOUND
                  THEN
                  --end bug 4296915
                     l_index := 1;
                     l_parent_task_ver_id_tbl.extend;
                     l_parent_task_ver_id_tbl(l_index):=get_str_ver_ic_lnk_tasks_rec.parent_task_ver_id;
                     IF (l_debug_mode = 'Y') THEN
                         pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Before calling Rollup_From_Subproject to rollup from the current project id='||
                         cur_select_hier_rec.object_id_to2||' to its parent project id='||get_str_ver_ic_lnk_tasks_rec.parent_proj_id,3);
                     END IF;

                     PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject(
                        p_api_version       => p_api_version
                       ,p_init_msg_list     => p_init_msg_list
                       ,p_commit            => p_commit
                       ,p_validate_only     => p_validate_only
                           ,p_validation_level      => p_validation_level
                           ,p_calling_module        => p_calling_module
                           ,p_debug_mode        => p_debug_mode
                           ,p_max_msg_count     => p_max_msg_count
                           ,p_element_versions      => l_parent_task_ver_id_tbl
                           ,x_return_status             => x_return_status
                           ,x_msg_count         => x_msg_count
                           ,x_msg_data          => x_msg_data);

                    IF (l_debug_mode = 'Y') THEN
                         pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','After calling Rollup_From_Subproject to rollup from the current project id='||
                         cur_select_hier_rec.object_id_to2||' to its parent project id='||get_str_ver_ic_lnk_tasks_rec.parent_proj_id||' x_return_status='||x_return_status,3);
                    END If;
                      If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
                          x_msg_count := FND_MSG_PUB.count_msg;
                          if x_msg_count = 1 then
                             x_msg_data := x_msg_data;
                          end if;
                          raise FND_API.G_EXC_ERROR;
                      end if;
                    END IF;  ----check_pub_str bug 4296915
                    CLOSE check_pub_str;
                    CLOSE chk_str_working_ver;  --this shold be inside ELSE otherwise its giving invalid cursor. --maansari 4293726
                  END IF; --chk_str_working_ver
           ELSE
--              IF PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(get_str_ver_ic_lnk_tasks_rec.parent_proj_id,
--                                                                       parent_task_str_ver_id) = 'Y' THEN
                 l_index := 1;
                 l_parent_task_ver_id_tbl.extend;
                 l_parent_task_ver_id_tbl(l_index):=get_str_ver_ic_lnk_tasks_rec.parent_task_ver_id;

                     IF (l_debug_mode = 'Y') THEN
                         pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','Before calling Rollup_From_Subproject to rollup from the current project id='||
                         cur_select_hier_rec.object_id_to2||' to its parent project id='||get_str_ver_ic_lnk_tasks_rec.parent_proj_id,3);
                     END IF;

                 PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject(
                    p_api_version       => p_api_version
                   ,p_init_msg_list     => p_init_msg_list
                   ,p_commit            => p_commit
                   ,p_validate_only     => p_validate_only
                           ,p_validation_level      => p_validation_level
                           ,p_calling_module        => p_calling_module
                           ,p_debug_mode        => p_debug_mode
                           ,p_max_msg_count     => p_max_msg_count
                           ,p_element_versions      => l_parent_task_ver_id_tbl
                           ,x_return_status             => x_return_status
                           ,x_msg_count         => x_msg_count
                           ,x_msg_data          => x_msg_data);
                    IF (l_debug_mode = 'Y') THEN
                         pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.TASKS_ROLLUP','After calling Rollup_From_Subproject to rollup from the current project id='||
                        cur_select_hier_rec.object_id_to2||' to its parent project id='||get_str_ver_ic_lnk_tasks_rec.parent_proj_id||' x_return_status='||x_return_status,3);
                    END IF;

                If (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
                  x_msg_count := FND_MSG_PUB.count_msg;
                  if x_msg_count = 1 then
                    x_msg_data := x_msg_data;
                  end if;
                  raise FND_API.G_EXC_ERROR;
                end if;

--              END IF;--end if for checking published ver exists or not
           END IF;--end if for checking veriosning enabled or not
        END LOOP; --End loop for get_str_ver_ic_lnk_tasks cursor
        CLOSE get_str_ver_ic_lnk_tasks;
----bug 4541039
      END IF;  --l_rollup_from_sub_project = 'Y'
     END LOOP;
----bug 4541039

     x_return_status := FND_API.G_RET_STS_SUCCESS;
--
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASKS_ROLLUP_PVT;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASKS_ROLLUP_PVT;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                              p_procedure_name => 'Tasks_Rollup',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

  end Tasks_Rollup;

  Procedure Task_Status_Rollup(
     p_api_version              IN  NUMBER      := 1.0
    ,p_init_msg_list            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                   IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level         IN  VARCHAR2    := 100
    ,p_calling_module           IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode               IN  VARCHAR2    := 'N'
    ,p_max_msg_count            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_structure_version_id     IN  NUMBER
    ,p_element_version_id       IN  NUMBER      := NULL
    ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    --1 for whole structure; 2 for a branch
    CURSOR get_task_version_id(c_input NUMBER) IS
      select a.proj_element_id, a.object_type, b.wbs_level,
             decode(d.object_type, 'PA_STRUCTURES', NULL, d.proj_element_id) object_id_from1, decode(d.object_type, 'PA_STRUCTURES', NULL, d.object_type) object_type_from, c.PROJECT_STATUS_WEIGHT,
             a.status_code
        from pa_proj_elements a,
             pa_proj_element_versions b,
             pa_project_statuses c,
             pa_proj_element_versions d,
             pa_object_relationships e
       where a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and a.status_code = c.project_status_code
         and b.element_version_id = e.object_id_to1
         and b.object_type = e.object_type_to
         and d.element_version_id = e.object_id_from1
         and d.object_type = e.object_type_from
         and e.relationship_type = 'S'
         and b.element_version_id IN
             ( select object_id_to1
                 from pa_object_relationships
                where relationship_type = 'S'
                  and 1 = c_input
           start with object_id_from1 = p_structure_version_id
                  and object_type_from = 'PA_STRUCTURES'
                  and relationship_type = 'S'
           connect by prior object_id_to1 = object_id_from1
                  AND RELATIONSHIP_TYPE = prior relationship_type
                  and prior object_type_to = object_type_from
               UNION
               select object_id_to1
                 from pa_object_relationships
                where relationship_type = 'S'
                  and 2 = c_input
                  and object_id_from1 IN
                      ( select object_id_from1
                          from pa_object_relationships
                         where relationship_type = 'S'
                    start with object_id_to1 = p_element_version_id
                           and object_type_to = 'PA_TASKS'
                           and relationship_type = 'S'
                    connect by object_id_to1 = prior object_id_from1
                           AND RELATIONSHIP_TYPE = prior relationship_type
                           and object_type_to = prior object_type_from
                      )
             );

    CURSOR get_task_status IS
      select a.project_status_code, a.project_status_weight
        from pa_project_statuses a
       where a.predefined_flag = 'Y'
         and a.STATUS_TYPE = 'TASK';
    l_temp_status_code         pa_project_statuses.project_status_code%TYPE;
    l_temp_status_weight       pa_project_statuses.project_status_weight%TYPE;
    l_final_status_code        pa_project_statuses.project_status_code%TYPE;
    l_final_status_weight      pa_project_statuses.project_status_weight%TYPE;

    CURSOR check_completed_ok(c_element_id NUMBER) IS
      select 1
        from pa_object_relationships rel,
             pa_proj_element_versions a,
             pa_proj_element_versions b,
             pa_proj_elements ppe,
             pa_project_statuses pps
       where a.proj_element_id = c_element_id
         and a.parent_structure_version_id = p_structure_version_id
         and a.element_version_id = rel.object_id_from1
         and a.object_type = rel.object_type_from
         and b.element_version_id = rel.object_id_to1
         and b.object_type = rel.object_type_to
         and rel.relationship_type = 'S'
         and ppe.proj_element_id = b.proj_element_id
         and b.project_id = ppe.project_id
         and ppe.status_code = pps.project_status_code
         and pps.project_system_status_code NOT IN ('COMPLETED', 'CANCELLED', 'ON_HOLD');

    l_process_number           NUMBER;
    l_temp                     NUMBER;

    l_option                   NUMBER;
    l_get_task_ver_id_rec      get_task_version_id%ROWTYPE;
    l_rollup_table             PA_SCHEDULE_OBJECTS_PVT.PA_SCHEDULE_OBJECTS_TBL_TYPE;
    l_cnt                      NUMBER;

    TYPE t_status_code IS TABLE OF pa_proj_elements.status_code%TYPE
      INDEX BY BINARY_INTEGER;
    l_status_codes             t_status_code;

    --hsiu: bug 2800553: added for performance improvement
    l_partial_flag             VARCHAR2(1);
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PVT.TASK_STATUS_ROLLUP BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint TASK_STATUS_ROLLUP_PUB;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    --begin rollup
    --check if task id is available. If not, rollup the whole structure
    IF (p_element_version_id IS NULL) THEN
      l_option := 1;
    ELSE
      l_option := 2;
    END IF;

    l_cnt := 0;
    OPEN get_task_version_id(l_option);
    LOOP
      l_cnt := l_cnt + 1;
      FETCH get_task_version_id into l_get_task_ver_id_rec;
      EXIT WHEN get_task_version_id%NOTFOUND;

      --populate rollup table
      l_rollup_table(l_cnt).object_id := l_get_task_ver_id_rec.proj_element_id;
      l_rollup_table(l_cnt).object_type := l_get_task_ver_id_rec.object_type;
      l_rollup_table(l_cnt).wbs_level := l_get_task_ver_id_rec.wbs_level;
      l_rollup_table(l_cnt).parent_object_id := l_get_task_ver_id_rec.object_id_from1;
      l_rollup_table(l_cnt).parent_object_type := l_get_task_ver_id_rec.object_type_from;
-- hsiu: bug 2800553: commented out for performance improvement
--      l_rollup_table(l_cnt).dirty_flag1 := 'Y';
-- hsiu: bug 2800553: added for performance improvement
      IF (p_element_version_id IS NULL) THEN
        l_rollup_table(l_cnt).dirty_flag1 := 'Y';
      ELSIF (p_element_version_id = l_rollup_table(l_cnt).object_id) THEN
        l_rollup_table(l_cnt).dirty_flag1 := 'Y';
      ELSE
        l_rollup_table(l_cnt).dirty_flag1 := 'N';
      END IF;
-- end performance changes
      l_rollup_table(l_cnt).TASK_STATUS1 := l_get_task_ver_id_rec.PROJECT_STATUS_WEIGHT;
      l_rollup_table(l_cnt).TASK_STATUS2 := l_get_task_ver_id_rec.PROJECT_STATUS_WEIGHT;
    END LOOP;
    CLOSE get_task_version_id;

-- hsiu: bug 2800553: added for performance improvement
    IF (p_element_version_id IS NULL) THEN
      l_partial_flag := 'N';
    ELSE
      l_partial_flag := 'Y';
    END IF;

    PA_SCHEDULE_OBJECTS_PVT.GENERATE_SCHEDULE(
          p_debug_mode => 'N',
          p_data_structure         => l_rollup_table,
          x_return_status          => x_return_status,
          x_msg_count              => x_msg_count,
          x_msg_data               => x_msg_data,
          x_process_number         => l_process_number,
          p_process_flag1          => 'Y',
          p_process_rollup_flag1   => 'Y',
          p_process_task_status_flag1 => 'Y',
          p_partial_progress_flag1 => l_partial_flag,
          p_process_flag2          => 'N',
          p_process_rollup_flag2   => 'N',
          p_process_progress_flag2 => 'N');

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    --getting task status
    OPEN get_task_status;
    LOOP
      FETCH get_task_status into l_temp_status_code, l_temp_status_weight;
      EXIT WHEN get_task_status%NOTFOUND;
      l_status_codes(l_temp_status_weight) := l_temp_status_code;
    END LOOP;
    CLOSE get_task_status;

    --update tasks if status has been modified
    l_cnt := l_rollup_table.First;
    IF (l_cnt IS NOT NULL) THEN
      LOOP
        IF (l_rollup_table(l_cnt).TASK_STATUS1 IS NULL) THEN
          l_final_status_weight := l_rollup_table(l_cnt).TASK_STATUS2;
          l_final_status_code := l_status_codes(l_rollup_table(l_cnt).TASK_STATUS2);
        ELSE
          l_final_status_weight := l_rollup_table(l_cnt).TASK_STATUS1;
          l_final_status_code := l_status_codes(l_rollup_table(l_cnt).TASK_STATUS1);
        END IF;

--hsiu: removed due to rollup api changes
--        IF (l_final_status_weight = 20) THEN
          --status is completed; check if all child are completed
          --and cancelled
--          OPEN check_completed_ok(l_rollup_table(l_cnt).object_id);
--          FETCH check_completed_ok into l_temp;
--          IF check_completed_ok%FOUND THEN
--            l_final_status_code := l_status_codes(30);
--            l_final_status_weight := 30;
--          END IF;
--          CLOSE check_completed_ok;
--        END IF;

  --check if status has been modified
        IF (l_final_status_weight <> l_rollup_table(l_cnt).TASK_STATUS2) THEN
          UPDATE PA_PROJ_ELEMENTS
             set status_code = l_final_status_code,
                 RECORD_VERSION_NUMBER = NVL(RECORD_VERSION_NUMBER,1)+1,
                 LAST_UPDATE_DATE = SYSDATE,
                 LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
                 LAST_UPDATE_LOGIN = FND_GLOBAL.LOGIN_ID
           where proj_element_id = l_rollup_table(l_cnt).object_id;
        END IF;

        EXIT when l_cnt = l_rollup_table.LAST;
        l_cnt := l_rollup_table.NEXT(l_cnt);

      END LOOP;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASK_STATUS_ROLLUP_PUB;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASK_STATUS_ROLLUP_PUB;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                              p_procedure_name => 'Task_Status_Rollup',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END Task_Status_Rollup;


  Procedure Task_Stat_Pushdown_Rollup(
     p_api_version              IN  NUMBER      := 1.0
    ,p_init_msg_list            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                   IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only            IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level         IN  VARCHAR2    := 100
    ,p_calling_module           IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode               IN  VARCHAR2    := 'N'
    ,p_max_msg_count            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_structure_version_id     IN  NUMBER
    ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )
  IS
    CURSOR get_zero_weight_status IS
      select a.project_id, a.proj_element_id,
             b.element_version_id, a.status_code
        from pa_proj_elements a,
             pa_proj_element_versions b,
             pa_project_statuses c
       where a.project_id = b.project_id
         and a.proj_element_id = b.proj_element_id
         and b.parent_structure_version_id = p_structure_version_id
         and c.project_status_code = a.status_code
         and c.project_status_weight = 0
         and c.status_type = 'TASK';
    l_zero_weight_rec get_zero_weight_status%ROWTYPE;
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PVT.TASK_STATUS_ROLLUP BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint TASK_STAT_PUSHDOWN_ROLLUP;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    --push down all cancelled and on-hold statuses
    OPEN get_zero_weight_status;
    LOOP
      FETCH get_zero_weight_status into l_zero_weight_rec;
      EXIT WHEN get_zero_weight_status%NOTFOUND;

      PA_PROGRESS_PUB.PUSH_DOWN_TASK_STATUS(
        p_validate_only => FND_API.G_FALSE
       ,p_task_status => l_zero_weight_rec.status_code
       ,p_project_id => l_zero_weight_rec.project_id
       ,p_object_id => l_zero_weight_rec.proj_element_id
       ,p_object_version_id => l_zero_weight_rec.element_version_id
       ,p_object_type => 'PA_TASKS'
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
      );

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END LOOP;
    CLOSE get_zero_weight_status;

    --done with push down. Now Rollup
    PA_STRUCT_TASK_ROLLUP_PUB.Task_Status_Rollup(
      p_structure_version_id => p_structure_version_id
     ,x_return_status => x_return_status
     ,x_msg_count => x_msg_count
     ,x_msg_data => x_msg_data);

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASK_STAT_PUSHDOWN_ROLLUP;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to TASK_STAT_PUSHDOWN_ROLLUP;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                              p_procedure_name => 'Task_Stat_Pushdown_Rollup',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END Task_Stat_Pushdown_Rollup;


-- API name                      : Program_Schedule_dates_rollup
-- Type                          : Public procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version                 IN  NUMBER      := 1.0
-- p_init_msg_list               IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                      IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only               IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level            IN  VARCHAR2    := 100
-- p_calling_module              IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                  IN  VARCHAR2    := 'N'
-- p_max_msg_count               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- p_structure_version_id        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
-- x_return_status               OUT VARCHAR2
-- x_msg_count                   OUT NUMBER
-- x_msg_data                    OUT VARCHAR2
--
-- DESCRIPTION:
-- This API is created to call rollup_from_subporject api. The API has 2 modes.
--1) If project id is passed and no structure version id is passed then the api
--calls rollup_from_subproject api for every single project in the hierarchy starting
--from projects at the lowest level.
--2) if structure version id and project id both are passed then the api calls rollup_from_subproject
--api only for that project.
--This api is called from publishing flow in both modes.
-- Bug 4541039

   PROCEDURE Program_Schedule_dates_rollup(
    p_api_version               IN  NUMBER      := 1.0
   ,p_init_msg_list             IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                    IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only             IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level          IN  VARCHAR2    := 100
   ,p_calling_module            IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                IN  VARCHAR2    := 'N'
   ,p_max_msg_count             IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_project_id                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_structure_version_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,p_published_str_ver_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
   ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) IS
        CURSOR cur_top_task(c_structure_version_id NUMBER)
    IS
    SELECT object_id_to1
    FROM pa_object_relationships
    WHERE object_id_from1 = c_structure_version_id
    AND relationship_type = 'S'
    AND object_type_from = 'PA_STRUCTURES'
    AND object_type_to = 'PA_TASKS'
        ;
     -- Bug 6854670 (Changed type from PA_NUM_1000_NUM to SYSTEM.PA_NUM_TBL_TYPE)
    l_tasks_ver_ids            SYSTEM.PA_NUM_TBL_TYPE := SYSTEM.PA_NUM_TBL_TYPE();
    l_top_task_version_id      NUMBER;
        l_debug_mode               VARCHAR2(1);

        --select all the projects belonging to the same program group as p_project_id.
        CURSOR cur_select_grid
        IS
        --select working verisons from versioned projects
        SELECT a.project_id, a.element_version_id, a.prg_level
          FROM pa_proj_element_versions a,
               pa_proj_elem_ver_structure b,
               pa_proj_workplan_attr ppwa,
               pa_proj_structure_types ppst,
               pa_proj_element_versions c
         WHERE
               c.project_id = p_project_id
           AND c.prg_group = a.prg_group
           AND a.object_type = 'PA_STRUCTURES'      -- bug 7607077
           AND a.project_id = b.project_id
           AND a.element_version_id = b.element_version_id
           AND b.status_code = 'STRUCTURE_WORKING'
      AND ppwa.wp_enable_version_flag = 'Y'
      AND a.project_id = ppwa.project_id
      AND a.proj_element_id = ppwa.proj_element_id
      AND a.proj_element_id = ppst.proj_element_id
      AND ppst.structure_type_id =1
           UNION
        --select published verisons from non-versioned projects
        SELECT a.project_id, a.element_version_id, a.prg_level
          FROM pa_proj_element_versions a,
               pa_proj_elem_ver_structure b,
               pa_proj_workplan_attr ppwa,
               pa_proj_structure_types ppst,
               pa_proj_element_versions c
         WHERE
               c.project_id = p_project_id
           AND c.prg_group = a.prg_group
           AND a.object_type = 'PA_STRUCTURES'       -- bug 7607077
           AND a.project_id = b.project_id
           AND a.element_version_id = b.element_version_id
           AND b.status_code = 'STRUCTURE_PUBLISHED'
      AND ppwa.wp_enable_version_flag = 'N'
      AND a.project_id = ppwa.project_id
      AND a.proj_element_id = ppwa.proj_element_id
      AND a.proj_element_id = ppst.proj_element_id
      AND ppst.structure_type_id =1
    order by 3 desc;    --select the lowest level of projects first.

   BEGIN

        x_msg_count := 0;
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

        IF (p_debug_mode = 'Y') THEN
           pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDULE_DATES_ROLLUP','Entered in PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP p_structure_version_id='||p_structure_version_id, 3);
           pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDULE_DATES_ROLLUP','Entered in PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP p_project_id='||p_project_id, 3);
        END IF;

        IF (p_commit = FND_API.G_TRUE) THEN
            savepoint Program_Schedule_dates_rollup;
        END IF;

  IF (p_structure_version_id  IS NULL OR p_structure_version_id =  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
    AND (p_project_id IS NOT NULL AND p_project_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM )
  THEN
           IF l_debug_mode  = 'Y' THEN
                pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP', 'Before Opening cursor cur_select_grid', 3);
           END IF;

    FOR cur_select_grid_rec IN cur_select_grid LOOP

        --when rollinup to a working verison which is being published, first rollup to the published version then continue with the working
        --verison and up in the hierarchy.
        IF p_published_str_ver_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND p_published_str_ver_id IS NOT NULL
           AND p_project_id= cur_select_grid_rec.project_id
        THEN

           IF l_debug_mode  = 'Y' THEN
                pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP', 'Before calling PA_STRUCT_TASK_ROLLUP_PUB.Program_Schedule_dates_rollup for published version of the project:'||cur_select_grid_rec.project_id, 3);
           END IF;

         PA_STRUCT_TASK_ROLLUP_PUB.Program_Schedule_dates_rollup(
                       p_project_id           => p_project_id,
                       p_structure_version_id => p_published_str_ver_id,
                       p_published_str_ver_id      => p_published_str_ver_id,  --bug5861729
               x_return_status => x_return_status,
               x_msg_count => x_msg_count,
               x_msg_data => x_msg_data);

           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;


           IF l_debug_mode  = 'Y' THEN
                pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP', 'After calling PA_STRUCT_TASK_ROLLUP_PUB.Program_Schedule_dates_rollup for published version of the project:'||
                               cur_select_grid_rec.project_id||' x_return_status='||x_return_status, 3);
           END IF;

        END IF;

    OPEN cur_top_task(cur_select_grid_rec.element_version_id);
    FETCH cur_top_task BULK COLLECT INTO l_tasks_ver_ids;
    CLOSE cur_top_task;

    IF l_tasks_ver_ids.count > 0 THEN

           IF l_debug_mode  = 'Y' THEN
        pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP', 'Before calling PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd for project'||cur_select_grid_rec.project_id, 3);
           END IF;

                 -- Bug 6854670: Changed call to Rollup_From_Subproject_Unltd
 	                  PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd(
                            p_api_version               => p_api_version
                           ,p_init_msg_list             => p_init_msg_list
                           ,p_commit                    => p_commit
                           ,p_validate_only             => p_validate_only
                           ,p_validation_level          => p_validation_level
                           ,p_calling_module            => p_calling_module
                           ,p_debug_mode                => p_debug_mode
                           ,p_max_msg_count             => p_max_msg_count
                           ,p_element_versions          => l_tasks_ver_ids
                           ,p_published_str_ver_id      => p_published_str_ver_id --bug5861729
                           ,x_return_status             => x_return_status
                           ,x_msg_count                 => x_msg_count
                           ,x_msg_data                  => x_msg_data);


       IF l_debug_mode  = 'Y' THEN
        pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP', 'After calling PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd x_return_status='||x_return_status, 3);
       END IF;

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;
     END LOOP;
  ELSIF (p_structure_version_id  IS NOT NULL AND p_structure_version_id <>  PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM ) --bug5861729
  THEN

        OPEN cur_top_task(p_structure_version_id);
        FETCH cur_top_task BULK COLLECT INTO l_tasks_ver_ids;
        CLOSE cur_top_task;

        IF l_tasks_ver_ids.count > 0 THEN

           IF l_debug_mode  = 'Y' THEN
                pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP', 'Before calling PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd', 3);
           END IF;

                  -- Bug 6854670: Changed call to Rollup_From_Subproject_Unltd
 	                  PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd(
                            p_api_version               => p_api_version
                           ,p_init_msg_list             => p_init_msg_list
                           ,p_commit                    => p_commit
                           ,p_validate_only             => p_validate_only
                           ,p_validation_level          => p_validation_level
                           ,p_calling_module            => p_calling_module
                           ,p_debug_mode                => p_debug_mode
                           ,p_max_msg_count             => p_max_msg_count
                           ,p_element_versions          => l_tasks_ver_ids
                           ,p_published_str_ver_id      => p_published_str_ver_id --bug5861729
                           ,x_return_status             => x_return_status
                           ,x_msg_count                 => x_msg_count
                           ,x_msg_data                  => x_msg_data);


           IF l_debug_mode  = 'Y' THEN
                pa_debug.write('PA_STRUCT_TASK_ROLLUP_PUB.PROGRAM_SCHEDUlE_DATES_ROLLUP', 'After calling PA_STRUCT_TASK_ROLLUP_PUB.Rollup_From_Subproject_Unltd x_return_status='||x_return_status, 3);
           END IF;

           IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                RAISE FND_API.G_EXC_ERROR;
           END IF;
        END IF;

  END IF;  --if p_structure_verison is not null

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to Program_Schedule_dates_rollup;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to Program_Schedule_dates_rollup;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_STRUCT_TASK_ROLLUP_PUB',
                              p_procedure_name => 'Program_Schedule_dates_rollup',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;

END Program_Schedule_dates_rollup;

END PA_STRUCT_TASK_ROLLUP_PUB;

/
