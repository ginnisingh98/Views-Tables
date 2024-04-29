--------------------------------------------------------
--  DDL for Package Body PA_TASKS_MAINT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASKS_MAINT_UTILS" as
/*$Header: PATSKSUB.pls 120.4.12010000.5 2009/07/21 14:32:05 anuragar ship $*/

  --Begin add rtarway FP-M development ,
  g_module_name   VARCHAR2(100) := 'PA_TASKS_MAINT_UTILS';
  --End add rtarway FP-M development

  procedure CHECK_TASK_MGR_NAME_OR_ID
  (
     p_task_mgr_name             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_mgr_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_project_id                IN  NUMBER      := NULL
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,p_calling_module            IN  VARCHAR2    := 'SELF_SERVICE'
    ,x_task_mgr_id               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_current_id      NUMBER := NULL;
    l_rows            NUMBER := 0;
    l_id_found_flag   VARCHAR2(1) := 'N';

    cursor c IS
      select person_id
      from pa_employees
      where upper(full_name) = upper(p_task_mgr_name)
      and active = '*'; --for bug 3245820

    cursor c1 IS
      select person_id
      from pa_employees
      where upper(full_name) = upper(p_task_mgr_name)
      and active = '*' -- for bug 3245820
      and person_id in
        ( select RESOURCE_source_ID
            from pa_project_parties ppp
           where ppp.RESOURCE_type_ID = 101
             and ppp.project_id = p_project_id
             and trunc(sysdate) between ppp.START_DATE_ACTIVE
                 and NVL(ppp.end_date_active, SYSDATE));

  BEGIN
    IF (p_task_mgr_id IS NULL OR p_task_mgr_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      -- ID is empty
      IF (p_task_mgr_name IS NOT NULL AND p_task_mgr_name<> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
        --Added for task manager changes;
        IF (PA_TASKS_MAINT_UTILS.GET_TASK_MANAGER_PROFILE = 'N') THEN
          --select from pa_employees
          OPEN c;
          LOOP
            FETCH c INTO l_current_id;
            EXIT when c%NOTFOUND;
            IF (l_current_id = p_task_mgr_id) THEN
              l_id_found_flag := 'Y';
              x_task_mgr_id := l_current_id;
            END IF;
          END LOOP;
          l_rows := c%ROWCOUNT;
          CLOSE c;
        ELSE
          --select from team members
          OPEN c1;
          LOOP
            FETCH c1 INTO l_current_id;
            EXIT when c1%NOTFOUND;
            IF (l_current_id = p_task_mgr_id) THEN
              l_id_found_flag := 'Y';
              x_task_mgr_id := l_current_id;
            END IF;
          END LOOP;
          l_rows := c1%ROWCOUNT;
          CLOSE c1;
        END IF;

        If (l_rows = 0) THEN
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_task_mgr_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    ELSE
      -- ID is not empty;
      IF (p_check_id_flag = 'Y') THEN
        --Added for task manager changes;
        IF (PA_TASKS_MAINT_UTILS.GET_TASK_MANAGER_PROFILE = 'N') THEN
          --select from pa_employees
          SELECT person_id
          INTO   x_task_mgr_id
          FROM   pa_employees
          WHERE  person_id = p_task_mgr_id;
        ELSE
          --select from team members
          SELECT person_id
          INTO   x_task_mgr_id
          FROM   pa_employees
          WHERE  person_id = p_task_mgr_id
          AND person_id in
              ( select RESOURCE_source_ID
                from pa_project_parties ppp
                where ppp.RESOURCE_type_ID = 101
                and ppp.project_id = p_project_id
                and trunc(sysdate) between ppp.START_DATE_ACTIVE
                and NVL(ppp.end_date_active, SYSDATE));
        END IF;
      ELSIF (p_check_id_flag = 'N') THEN
        x_task_mgr_id := p_task_mgr_id;
      ELSIF (p_check_id_flag = 'A') THEN
        --Added for task manager changes;
        IF (PA_TASKS_MAINT_UTILS.GET_TASK_MANAGER_PROFILE = 'N') THEN
          --select from pa_employees
          OPEN c;
          LOOP
            FETCH c INTO l_current_id;
            EXIT when c%NOTFOUND;
            IF (l_current_id = p_task_mgr_id) THEN
              l_id_found_flag := 'Y';
              x_task_mgr_id := l_current_id;
            END IF;
          END LOOP;
          l_rows := c%ROWCOUNT;
          CLOSE c;
        ELSE
          --select from team members
          OPEN c1;
          LOOP
            FETCH c1 INTO l_current_id;
            EXIT when c1%NOTFOUND;
            IF (l_current_id = p_task_mgr_id) THEN
              l_id_found_flag := 'Y';
              x_task_mgr_id := l_current_id;
            END IF;
          END LOOP;
          l_rows := c1%ROWCOUNT;
          CLOSE c1;
        END IF;

        If (l_rows = 0) THEN
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_task_mgr_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;

      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_task_mgr_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_TASK_MGR_ID_INVALID';
    WHEN TOO_MANY_ROWS THEN
      x_task_mgr_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_TASK_MGR_ID_NOT_UNIQUE';
    WHEN OTHERS THEN
      x_task_mgr_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET x_error_msg_code also
	x_error_msg_code := SQLCODE;

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_TASK_MGR_NAME_OR_ID');
      RAISE;
  END CHECK_TASK_MGR_NAME_OR_ID;


  procedure CHECK_PROJECT_NAME_OR_ID
  (
     p_project_name              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_project_id                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,x_project_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ) AS
    l_current_id      NUMBER := NULL;
    l_rows            NUMBER := 0;
    l_id_found_flag   VARCHAR2(1) := 'N';

    cursor c IS
      select project_id
      from pa_projects_all
      where UPPER(name) = UPPER(p_project_name);

  BEGIN
    IF (p_project_id IS NULL OR  p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM)  THEN
      -- ID is empty
      IF (p_project_name IS NOT NULL AND p_project_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
        OPEN c;
        LOOP
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_project_id) THEN
            l_id_found_flag := 'Y';
            x_project_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_project_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    ELSE
      -- ID is not empty;
      IF (p_check_id_flag = 'Y') THEN
        SELECT project_id
        INTO   x_project_id
        FROM   pa_projects_all
        WHERE  project_id = p_project_id;
      ELSIF (p_check_id_flag = 'N') THEN
        x_project_id := p_project_id;
      ELSIF (p_check_id_flag = 'A') THEN
        OPEN c;
        LOOP
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_project_id) THEN
            l_id_found_flag := 'Y';
            x_project_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_project_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_project_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_TASK_INV_PRJ_ID';
    WHEN TOO_MANY_ROWS THEN
      x_project_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_TASK_PRJ_ID_NOT_UNIQ';
    WHEN OTHERS THEN
      x_project_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET x_error_msg_code also
	x_error_msg_code := SQLCODE ;

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_PROJECT_NAME_OR_ID');
      RAISE;
  END CHECK_PROJECT_NAME_OR_ID;

  procedure CHECK_TASK_NAME_OR_ID
  (
     p_project_id                IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_task_name                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_id                   IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_check_id_flag             IN  VARCHAR2    := 'A'
    ,x_task_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_error_msg_code            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_current_id      NUMBER := NULL;
    l_rows            NUMBER := 0;
    l_id_found_flag   VARCHAR2(1) := 'N';

    cursor c IS
      select task_id
      from pa_tasks
      where UPPER(task_name) = UPPER(p_task_name)
        and project_id = p_project_id;
  BEGIN
    IF (p_task_id IS NULL OR p_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      -- ID is empty
      IF (p_task_name IS NOT NULL AND p_task_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
        OPEN c;
        LOOP
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_task_id) THEN
            l_id_found_flag := 'Y';
            x_task_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_task_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    ELSE
      -- ID is not empty;
      IF (p_check_id_flag = 'Y') THEN
        SELECT task_id
        INTO   x_task_id
        FROM   pa_tasks
        WHERE  task_id = p_task_id and project_id = p_project_id;
      ELSIF (p_check_id_flag = 'N') THEN
        x_task_id := p_task_id;
      ELSIF (p_check_id_flag = 'A') THEN
        OPEN c;
        LOOP
          FETCH c INTO l_current_id;
          EXIT WHEN c%NOTFOUND;
          IF (l_current_id = p_task_id) THEN
            l_id_found_flag := 'Y';
            x_task_id := l_current_id;
          END IF;
        END LOOP;
        l_rows := c%ROWCOUNT;
        CLOSE c;
        If (l_rows = 0) THEN
          RAISE NO_DATA_FOUND;
        ELSIF (l_rows = 1) THEN
          x_task_id := l_current_id;
        ELSIF (l_id_found_flag = 'N') THEN
          RAISE TOO_MANY_ROWS;
        END IF;
      END IF;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_task_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_TASK_ID_INVALID';
    WHEN TOO_MANY_ROWS THEN
      x_task_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_msg_code := 'PA_TASK_ID_NOT_UNIQUE';
    WHEN OTHERS THEN
      x_task_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET x_error_msg_code also
	x_error_msg_code := SQLCODE;

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_TASK_NAME_OR_ID');
      RAISE;
  END CHECK_TASK_NAME_OR_ID;



  FUNCTION Get_Sequence_Number(p_peer_or_sub IN VARCHAR2,
                               p_project_id  IN NUMBER,
                               p_task_id     IN NUMBER)
  RETURN NUMBER
  IS
    l_s_num NUMBER;
    l_s_num_min NUMBER;
  BEGIN
/*HY
    IF (p_peer_or_sub = 'SUB') THEN
      select display_sequence
      into l_s_num
      from pa_tasks
      where project_id = p_project_id
      and task_id = p_task_id;

      if (l_s_num < 0) then
        return l_s_num - 1;
      else
        return -(l_s_num+1);
      end if;
    ELSE -- 'PEER'
      select max(display_sequence), min(display_sequence)
      into l_s_num, l_s_num_min
      from (
        select display_sequence
        from pa_tasks
        where project_id = p_project_id
        start with task_id = p_task_id
        connect by prior task_id = parent_task_id
      );

      if (l_s_num_min > 0) then
        return -(l_s_num+1);
      else
        return l_s_num_min-1;
      end if;
    END IF;
*/ return 1;
  END;

  --For getting address id when defaulting top task
  FUNCTION default_address_id(p_proj_id IN NUMBER)
  RETURN NUMBER
  IS
    CURSOR get_addr IS
      select min(ship_to_address_id) address_id, count('1') count
        from pa_project_customers
       where project_id = p_proj_id;
    temp_addr get_addr%ROWTYPE;

  BEGIN
    OPEN get_addr;
    FETCH get_addr INTO temp_addr;
    IF (temp_addr.count = 1) THEN
      return temp_addr.address_id;
    ELSE
      return NULL;
    END IF;
    return NULL;
  END default_address_id;


  PROCEDURE CHECK_TASK_NUMBER_DISP(
    p_project_id IN NUMBER,
    p_task_id IN NUMBER,
    p_task_number IN VARCHAR2,
    p_rowid IN VARCHAR2)
  IS
    x_err_code    Number := 0;
    x_err_stage   Varchar2(80);
    x_err_stack   Varchar2(630);
  BEGIN
          pa_task_utils.change_lowest_task_num_ok(
      p_task_id,
      x_err_code,
      x_err_stage,
      x_err_stack);
    IF (x_err_code <> 0) THEN
      PA_UTILS.ADD_MESSAGE('PA',substr(x_err_stage,1,30));
      return;
    END IF;

    If Pa_Task_Utils.Check_Unique_Task_number (p_project_id,
                                               p_task_number,
                                               p_rowid ) <> 1 Then
      PA_UTILS.ADD_MESSAGE('PA','PA_ALL_DUPLICATE_NUM');
      return;
    END IF;
  END CHECK_TASK_NUMBER_DISP;


  procedure Check_Start_Date(p_project_id      IN NUMBER,
                             p_parent_task_id  IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_start_date      IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
    l_start_date   DATE;
    l_end_date     DATE;

    -- Bug 6163119
    l_pstart_date   DATE;
    l_pend_date     DATE;
    l_tstart_date   DATE;
    l_tend_date     DATE;

	--bug 8566495 anuragag
	l_sch_s_date DATE;
	l_sch_e_date DATE;

    CURSOR c1(tid NUMBER) IS
    select min(start_date), max(completion_date) --Bug 6163119
    from pa_tasks
    where --parent_task_id = c1.tid  --Bug 6163119
    project_id = p_project_id
    start with parent_task_id=c1.tid
    connect by prior task_id= parent_task_id; --Bug 6163119

	--bug 8566495 anuragag
	cursor get_parent_dates(p_task_id NUMBER) is
	select scheduled_start_date,scheduled_finish_date from pa_proj_elem_ver_schedule where
element_version_id =
(select por.object_id_from1 from pa_proj_element_versions ppev,pa_object_relationships por
where ppev.proj_element_id = p_task_id
and ppev.element_version_id = por.object_id_to1
and relationship_subtype = 'TASK_TO_TASK'
);


  BEGIN

    IF (p_parent_task_id IS NULL) THEN -- TOP TASK, compare with project

      --select project start date
      select start_date, completion_date
      into l_start_date, l_end_date
      from pa_projects_all
      where project_id = p_project_id;
      IF (p_start_date IS NOT NULL and
          l_start_date > p_start_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_TK_OUTSIDE_PROJECT_RANGE');
        x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (l_end_date IS NOT NULL and
          p_start_date > l_end_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_TK_OUTSIDE_PROJECT_RANGE');
        x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

	  if(PA_TASK_PVT1.G_CHG_DOC_CNTXT = 1 )
then
open get_parent_dates(p_task_id);
fetch get_parent_dates into l_sch_s_date,l_sch_e_date;
close get_parent_dates;
if(l_sch_s_date is not null and l_sch_s_date>p_start_date) then
x_msg_data := 'PA_PARENT_TASK_GREATER';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

end if;
    ELSE -- NOT A TOP TASK, compare with parent task
      --select parent task start date
      select start_date, completion_date
      into l_start_date, l_end_date
      from pa_tasks
      where task_id = p_parent_task_id;
      IF (p_start_date is NOT NULL and
          l_start_date > p_start_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_PARENT_TASK_GREATER');
        x_msg_data := 'PA_PARENT_TASK_GREATER';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (l_end_date IS NOT NULL and
          p_start_date > l_end_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_PARENT_TASK_GREATER');
        x_msg_data := 'PA_PARENT_TASK_GREATER';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Bug Start 6163119
      select start_date, completion_date
      into l_pstart_date, l_pend_date
      from pa_projects_all
      where project_id = p_project_id;

      select max(start_date),
      min(completion_date)
      into l_tstart_date,
      l_tend_date
      from pa_tasks
      where project_id=p_project_id
      start with task_id=p_parent_task_id
      connect by task_id= prior parent_task_id;

      -- Bug fix 7482184
      IF p_start_date IS NOT NULL AND l_start_date IS NULL THEN
        IF l_tstart_date IS NOT NULL THEN
          IF(l_tstart_date > p_start_date) THEN
            x_msg_data := 'PA_PARENT_TASK_GREATER';
            RAISE FND_API.G_EXC_ERROR;
	  END IF;
        ELSIF l_pstart_date IS NOT NULL THEN
          IF(l_pstart_date > p_start_date) THEN
            x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      -- Bug fix 7482184
      IF p_start_date IS NOT NULL AND l_end_date IS NULL THEN
        IF l_tend_date IS NOT NULL THEN
          IF (p_start_date > l_tend_date) THEN
	    x_msg_data := 'PA_PARENT_TASK_GREATER';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSIF l_pend_date IS NOT NULL THEN
          IF(p_start_date > l_pend_date) THEN
            x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      -- Bug End 6163119


    END IF;

    IF (p_task_id IS NOT NULL) THEN
      -- This is an existing task
      -- select start date of children
      OPEN c1(p_task_id);
      LOOP
        FETCH c1 INTO l_start_date, l_end_date;
        EXIT WHEN c1%NOTFOUND;
        IF (p_start_date is NOT NULL and
            l_start_date < p_start_date) THEN -- Bug 7386335
--          PA_UTILS.ADD_MESSAGE('PA', 'PA_CHILD_TASK_DATE_EARLIER');
          x_msg_data := 'PA_CHILD_TASK_DATE_EARLIER';
          CLOSE c1;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (l_end_date IS NOT NULL and
            p_start_date > l_end_date) THEN
--          PA_UTILS.ADD_MESSAGE('PA', 'PA_CHILD_TASK_DATE_EARLIER');
          x_msg_data := 'PA_CHILD_TASK_DATE_EARLIER';
          CLOSE c1;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      CLOSE c1;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET other OUT params too
      x_msg_count := 1;
      x_msg_data := SUBSTRB(SQLERRM ,1,240);

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_START_DATE',
			      p_error_text     => x_msg_data); -- 4537865
      RAISE;
  END Check_Start_Date;


  procedure Check_End_Date(  p_project_id      IN NUMBER,
                             p_parent_task_id  IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_end_date        IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
    l_start_date   DATE;
    l_end_date     DATE;

    -- Bug 6163119
    l_pstart_date   DATE;
    l_pend_date     DATE;
    l_tstart_date   DATE;
    l_tend_date     DATE;

	--bug 8566495 anuragag
	l_sch_s_date DATE;
	l_sch_e_date DATE;

    CURSOR c1(tid NUMBER) IS
    select min(start_date), max(completion_date) --Bug 6163119
    from pa_tasks
    where --parent_task_id = c1.tid --Bug 6163119
    project_id = p_project_id
    start with parent_task_id=c1.tid
    connect by prior task_id= parent_task_id;--Bug 6163119

	--bug 8566495 anuragag
	cursor get_parent_dates(p_task_id NUMBER) is
	select scheduled_start_date,scheduled_finish_date from pa_proj_elem_ver_schedule where
element_version_id =
(select por.object_id_from1 from pa_proj_element_versions ppev,pa_object_relationships por
where ppev.proj_element_id = p_task_id
and ppev.element_version_id = por.object_id_to1
and relationship_subtype = 'TASK_TO_TASK'
);

  BEGIN

    IF (p_parent_task_id IS NULL) THEN -- TOP TASK, compare with project
      --select project completion date
      select start_date, completion_date
      into l_start_date, l_end_date
      from pa_projects_all
      where project_id = p_project_id;
      IF (p_end_date IS NOT NULL and
          l_end_date < p_end_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_TK_OUTSIDE_PROJECT_RANGE');
        x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_end_date IS NOT NULL and
          l_start_date > p_end_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_TK_OUTSIDE_PROJECT_RANGE');
        x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

	  if(PA_TASK_PVT1.G_CHG_DOC_CNTXT = 1 )
then
open get_parent_dates(p_task_id);
fetch get_parent_dates into l_sch_s_date,l_sch_e_date;
close get_parent_dates;
if(l_sch_s_date is not null and l_sch_e_date<p_end_date) then
x_msg_data := 'PA_PARENT_COMPLETION_EARLIER';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

end if;

    ELSE -- NOT A TOP TASK, compare with parent task
      --select parent task completion date
      select start_date, completion_date
      into l_start_date, l_end_date
      from pa_tasks
      where task_id = p_parent_task_id;
      IF (p_end_date is NOT NULL and
          l_end_date < p_end_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_PARENT_COMPLETION_EARLIER');
        x_msg_data := 'PA_PARENT_COMPLETION_EARLIER';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (p_end_date is NOT NULL and
          l_start_date > p_end_date) THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_PARENT_COMPLETION_EARLIER');
        x_msg_data := 'PA_PARENT_COMPLETION_EARLIER';
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Bug Start 6163119
      select start_date, completion_date
      into l_pstart_date, l_pend_date
      from pa_projects_all
      where project_id = p_project_id;

      select max(start_date),
      min(completion_date)
      into l_tstart_date,
      l_tend_date
      from pa_tasks
      where project_id=p_project_id
      start with task_id=p_parent_task_id
      connect by task_id= prior parent_task_id;

      -- Bug fix 7482184
      IF p_end_date IS NOT NULL AND l_end_date IS NULL  THEN
        IF l_tend_date IS NOT NULL THEN
          IF (l_tend_date < p_end_date) THEN
            x_msg_data := 'PA_PARENT_COMPLETION_EARLIER';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSIF l_pend_date IS NOT NULL THEN
          IF (l_pend_date < p_end_date) THEN
            x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      -- Bug fix 7482184
      IF  p_end_date IS NOT NULL AND l_start_date IS NULL THEN
        IF l_tstart_date IS NOT NULL THEN
          IF(l_tstart_date > p_end_date) THEN
	    x_msg_data := 'PA_PARENT_COMPLETION_EARLIER';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSIF l_pstart_date is NOT NULL THEN
          IF(l_pstart_date > p_end_date) THEN
            x_msg_data := 'PA_TK_OUTSIDE_PROJECT_RANGE';
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        END IF;
      END IF;

      -- Bug End 6163119

    END IF;

    IF (p_task_id IS NOT NULL) THEN
      -- This is an existing task
      -- select start date of children
      OPEN c1(p_task_id);
      LOOP
        FETCH c1 INTO l_start_date, l_end_date;
        EXIT WHEN c1%NOTFOUND;
        IF (p_end_date is NOT NULL and
            l_end_date > p_end_date) THEN
--          PA_UTILS.ADD_MESSAGE('PA', 'PA_CHILD_COMPLETION_LATER');
          x_msg_data := 'PA_CHILD_COMPLETION_LATER';
          CLOSE c1;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
        IF (p_end_date is NOT NULL and
            l_start_date > p_end_date) THEN
--          PA_UTILS.ADD_MESSAGE('PA', 'PA_PARENT_TASK_GREATER');
          x_msg_data := 'PA_CHILD_COMPLETION_LATER';
          CLOSE c1;
          RAISE FND_API.G_EXC_ERROR;
        END IF;

      END LOOP;
      CLOSE c1;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET other OUT params too
      x_msg_count := 1;
      x_msg_data := SUBSTRB(SQLERRM ,1,240);
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_END_DATE',
			      p_error_text => x_msg_data); -- 4537865
  END Check_End_Date;


  PROCEDURE Check_Chargeable_Flag( p_chargeable_flag IN VARCHAR2,
                             p_receive_project_invoice_flag IN VARCHAR2,
                             p_project_type    IN VARCHAR2,
			     p_project_id      IN number,  -- Added for bug#3512486
                             x_receive_project_invoice_flag OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
  -- MOAC Changes: Bug 4363092: removed nvl with org_id
    CURSOR c1 IS
      select nvl(cc_ic_billing_recvr_flag, 'N')
      from pa_implementations_all   -- Modified pa_implementations to pa_implementations_all for bug#3512486
      where org_id = (select org_id from pa_projects_all where project_id = p_project_id);  -- Added the where condition for bug#3512486

  -- MOAC Changes: Bug 4363092: removed nvl with org_id
    CURSOR c2 IS
      select nvl(cc_prvdr_flag, 'N')
      from pa_project_types_all  -- Modified pa_project_types to pa_project_types_all for bug#3512486
      where project_type = p_project_type
      and org_id = (select org_id from pa_projects_all where project_id = p_project_id);  -- Added the and condition for bug#3512486

    l_c1_flag VARCHAR2(1);
    l_c2_flag VARCHAR2(2);
  BEGIN
    IF (p_chargeable_flag = 'Y') THEN
      BEGIN
        OPEN c1;
        FETCH c1 INTO l_c1_flag;
        CLOSE c1;
        OPEN c2;
        FETCH c2 INTO l_c2_flag;
        CLOSE c2;

        IF (l_c1_flag = 'Y' AND l_c2_flag = 'N') THEN
          x_receive_project_invoice_flag := p_receive_project_invoice_flag;
        ELSE
          x_receive_project_invoice_flag := 'N';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          x_receive_project_invoice_flag := 'N';
      END;
    END IF;
  END Check_Chargeable_Flag;



  PROCEDURE CHECK_SCHEDULE_DATES(p_project_id IN NUMBER,
                                 p_sch_start_date IN DATE,
                                 p_sch_end_date IN DATE,
                                 x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
    CURSOR c1 IS
      select SCHEDULED_START_DATE, SCHEDULED_FINISH_DATE
      from pa_projects_all
      where project_id = p_project_id;

    l_start_date DATE;
    l_finish_date DATE;
    l_f1 VARCHAR2(1);
    l_f2 VARCHAR2(1);
    l_ret VARCHAR2(1);

  BEGIN
    IF (p_sch_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_sch_start_date IS NULL) AND
       (p_sch_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_sch_end_date IS NULL) THEN
      check_start_end_date(
        p_old_start_date => null,
        p_old_end_date => null,
        p_new_start_date => p_sch_start_date,
        p_new_end_date => p_sch_end_date,
        p_update_start_date_flag => l_f1,
        p_update_end_date_flag => l_f2,
        p_return_status => l_ret);
      IF (l_ret <> 'S') THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_SCH_DATES');
        --commenting the following line after discussing with
        --sakthi. The reason is that there are two messages being appended
        --for the same error.
        --x_msg_data := 'PA_INVALID_SCH_DATES';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    OPEN c1;
    FETCH c1 INTO l_start_date, l_finish_date;
    IF c1%NOTFOUND THEN
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PROJ_NOT_EXIST');
      x_msg_data := 'PA_PROJ_NOT_EXIST';
      CLOSE c1;
      RAISE FND_API.G_EXC_ERROR;
    END IF;
    CLOSE c1;

    IF (p_sch_start_date IS NOT NULL and l_start_date > p_sch_start_date) THEN
--      PA_UTILS.ADD_MESSAGE('PA', 'PA_SCH_DATE_OUTSIDE_PROJ_RANGE');
      x_msg_data := 'PA_SCH_DATE_OUTSIDE_PROJ_RANGE';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF (p_sch_end_date IS NOT NULL and l_finish_date < p_sch_end_date) THEN
--      PA_UTILS.ADD_MESSAGE('PA', 'PA_SCH_DATE_OUTSIDE_PROJ_RANGE');
      x_msg_data := 'PA_SCH_DATE_OUTSIDE_PROJ_RANGE';
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    x_msg_data := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET other OUT params too
      x_msg_count := 1;
      x_msg_data := SUBSTRB(SQLERRM ,1,240);

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_SCHEDULE_DATES',
			      p_error_text => x_msg_data ); -- 4537865
  END CHECK_SCHEDULE_DATES;


  PROCEDURE CHECK_ESTIMATE_DATES(p_project_id IN NUMBER,
                                 p_estimate_start_date IN DATE,
                                 p_estimate_end_date IN DATE,
                                 x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
    l_f1 VARCHAR2(1);
    l_f2 VARCHAR2(1);
    l_ret VARCHAR2(1);
  BEGIN

    IF (p_estimate_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_estimate_start_date IS NULL) AND
       (p_estimate_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_estimate_end_date IS NULL) THEN
      check_start_end_date(
        p_old_start_date => null,
        p_old_end_date => null,
        p_new_start_date => p_estimate_start_date,
        p_new_end_date => p_estimate_end_date,
        p_update_start_date_flag => l_f1,
        p_update_end_date_flag => l_f2,
        p_return_status => l_ret);
      IF (l_ret <> 'S') THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_EST_DATES');
        x_msg_data := 'PA_INVALID_EST_DATES';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    x_msg_data := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET other OUT params too
      x_msg_count := 1;
      x_msg_data := SUBSTRB(SQLERRM ,1,240);
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_ESTIMATE_DATES',
			      p_error_text => x_msg_data ); -- 4537865
  END CHECK_ESTIMATE_DATES;


  PROCEDURE CHECK_ACTUAL_DATES(p_project_id IN NUMBER,
                               p_actual_start_date IN DATE,
                               p_actual_end_date IN DATE,
                               x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               x_msg_data OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS
    l_f1 VARCHAR2(1);
    l_f2 VARCHAR2(1);
    l_ret VARCHAR2(1);
  BEGIN

    IF (p_actual_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_actual_start_date IS NULL) AND
       (p_actual_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_actual_end_date IS NULL) THEN
      check_start_end_date(
        p_old_start_date => null,
        p_old_end_date => null,
        p_new_start_date => p_actual_start_date,
        p_new_end_date => p_actual_end_date,
        p_update_start_date_flag => l_f1,
        p_update_end_date_flag => l_f2,
        p_return_status => l_ret);
      IF (l_ret <> 'S') THEN
--        PA_UTILS.ADD_MESSAGE('PA', 'PA_INVALID_ACTUAL_DATES');
        x_msg_data := 'PA_INVALID_ACTUAL_DATES';
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;

    x_msg_data := NULL;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- 4537865 : RESET other OUT params too
      x_msg_count := 1;
      x_msg_data := SUBSTRB(SQLERRM ,1,240);
      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'CHECK_ACTUAL_DATES',
                              p_error_text => x_msg_data ); -- 4537865
  END CHECK_ACTUAL_DATES;


  PROCEDURE SET_ORG_ID(p_project_id IN NUMBER)
  IS
    l_org_id NUMBER;
  BEGIN
    SELECT org_id INTO l_org_id
    FROM PA_PROJECTS_ALL
    WHERE project_id = p_project_id;

  END SET_ORG_ID;


  function rearrange_display_seq (p_display_seq IN   NUMBER,
                                  p_above_seq   IN   NUMBER,
                                  p_number_tasks IN  NUMBER,
                                  p_mode        IN   VARCHAR2,
                                  p_operation   IN   VARCHAR2) return NUMBER
  is
    i   NUMBER;
  begin
    if p_mode = 'INSERT' then
      if p_display_seq < 0 then
        i := abs(p_display_seq);
      elsif p_display_seq > 0 then
        if p_display_seq  > p_above_seq then
          i := p_display_seq;
        else
          i := p_display_seq + p_number_tasks;
        end if;
      end if;
    end if;
    if p_mode = 'MOVE' then
      if p_operation = 'UP' then
        if p_display_seq < 0 then
          i := abs(p_display_seq);
        elsif p_display_seq > 0 then
          if p_display_seq >= p_above_seq then
            i := p_display_seq;
          else
            i := p_display_seq + p_number_tasks;
          end if;
        end if;
      end if;
      if p_operation = 'DOWN' then
        if p_display_seq < 0 then
          i := abs(p_display_seq) - p_number_tasks;
        elsif p_display_seq > 0 then
          --if p_display_seq >= p_above_seq then
          if p_display_seq > p_above_seq then
            i := p_display_seq;
          else
            i := p_display_seq - p_number_tasks;
          end if;
        end if;
      end if;
    end if;

    if p_mode = 'DELETE' then
      i := p_display_seq - p_number_tasks;
    end if;
    return(i);
  end rearrange_display_seq;


-- API name                      : DEFAULT_TASK_ATTRIBUTES
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_reference_task_id          IN  NUMBER    REQUIRED
-- p_task_type                  IN  VARCHAR2  REQUIRED
-- x_carrying_out_org_id        OUT NUMBER    REQUIRED
-- x_carrying_out_org_name      OUT VARCHAR2  REQUIRED
-- x_work_type_id               OUT NUMBER    REQUIRED
-- x_work_type_name             OUT VARCHAR2  REQUIRED
-- x_service_type_code          OUT VARCHAR2    REQUIRED
-- x_service_type_name          OUT VARCHAR2  REQUIRED
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  14-JUN-01   Majid Ansari             -Created
--
--

    PROCEDURE DEFAULT_TASK_ATTRIBUTES(
       p_reference_task_id          IN  NUMBER,
       p_task_type                  IN  VARCHAR2,
       x_carrying_out_org_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_carrying_out_org_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_work_type_id               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_work_type_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_code          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_name          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ) AS

      CURSOR cur_pa_parent_task
      IS
        SELECT parent_task_id, project_id
          FROM pa_tasks
         WHERE task_id = p_reference_task_id;

      l_parent_task_id                   NUMBER;
      l_project_id                       NUMBER;

    BEGIN
         x_return_status := FND_API.G_RET_STS_SUCCESS;
         IF p_reference_task_id IS NULL
         THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_msg_code := 'PA_PRJ_TASK_ID_REQ';
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF p_task_type IS NULL
         THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_error_msg_code := 'PA_PRJ_TASK_TYPE_REQ';
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF p_task_type = 'SUB'
         THEN
             FETCH_TASK_ATTIBUTES(
                       p_task_id                  => p_reference_task_id,
                       x_carrying_out_org_id      => x_carrying_out_org_id,
                       x_carrying_out_org_name    => x_carrying_out_org_name,
                       x_work_type_id             => x_work_type_id,
                       x_work_type_name           => x_work_type_name,
                       x_service_type_code        => x_service_type_code,
                       x_service_type_name        => x_service_type_name,
                       x_return_status         => x_return_status,
                       x_error_msg_code        => x_error_msg_code
                      );

         ELSIF p_task_type = 'PEER'
         THEN
            OPEN cur_pa_parent_task;
            FETCH cur_pa_parent_task INTO l_parent_task_id, l_project_id;
            CLOSE cur_pa_parent_task;

            --if parent of the reference task exists then get the attributes                                                             --of the parent task.
            IF l_parent_task_id IS NOT NULL
            THEN
               FETCH_TASK_ATTIBUTES(
                       p_task_id                  => l_parent_task_id,
                       x_carrying_out_org_id      => x_carrying_out_org_id,
                       x_carrying_out_org_name    => x_carrying_out_org_name,
                       x_work_type_id             => x_work_type_id,
                       x_work_type_name           => x_work_type_name,
                       x_service_type_code        => x_service_type_code,
                       x_service_type_name        => x_service_type_name,
                       x_return_status         => x_return_status,
                       x_error_msg_code        => x_error_msg_code
                      );
            --otherwise fetch the attributes of their project.
            ELSE
               FETCH_PROJECT_ATTIBUTES(
                       p_project_id               => l_project_id,
                       x_carrying_out_org_id      => x_carrying_out_org_id,
                       x_carrying_out_org_name    => x_carrying_out_org_name,
                       x_work_type_id             => x_work_type_id,
                       x_work_type_name           => x_work_type_name,
                       x_service_type_code        => x_service_type_code,
                       x_service_type_name        => x_service_type_name,
                       x_return_status         => x_return_status,
                       x_error_msg_code        => x_error_msg_code
                      );
            END IF;
         END IF;

    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
 	-- 4537865 : RESET other OUT params too
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;

       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
	 -- 4537865 : Start
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;

	 x_error_msg_code := SQLCODE ;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_UILS',
                              p_procedure_name => 'DEFAULT_TASK_ATTRIBUTES',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
	 -- 4537865 : End
         RAISE;
    END DEFAULT_TASK_ATTRIBUTES;

-- API name                      : FETCH_TASK_ATTIBUTES
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_task_id                    IN  NUMBER    REQUIRED
-- x_carrying_out_org_id        OUT NUMBER    REQUIRED
-- x_carrying_out_org_name      OUT VARCHAR2  REQUIRED
-- x_work_type_id               OUT NUMBER    REQUIRED
-- x_work_type_name             OUT VARCHAR2  REQUIRED
-- x_service_type_code          OUT VARCHAR2    REQUIRED
-- x_service_type_name          OUT VARCHAR2  REQUIRED
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  14-JUN-01   Majid Ansari             -Created
--
--

   PROCEDURE FETCH_TASK_ATTIBUTES(
       p_task_id                     IN NUMBER,
       x_carrying_out_org_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_carrying_out_org_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_work_type_id               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_work_type_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_code          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_name          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) AS

/* Bug 2680486 -- Performance changes -- To avoid Non-mergable view issue,
                  Changed PA_WORK_TYPES_VL to PA_WORK_TYPES_TL and added condition for userenev('lang')*/

      CURSOR cur_pa_tasks_sub
      IS
        SELECT  PT.CARRYING_OUT_ORGANIZATION_ID
               ,HOU.NAME            CARRYING_OUT_ORGANIZATION_NAME
               ,PT.WORK_TYPE_ID
               ,PWT.NAME            WORK_TYPE_NAME
               ,PT.SERVICE_TYPE_CODE
               ,PL.MEANING          SERVICE_TYPE_NAME
          FROM  PA_TASKS              PT
               ,HR_ORGANIZATION_UNITS HOU
               ,PA_WORK_TYPES_TL      PWT
               ,PA_LOOKUPS            PL
         WHERE PT.TASK_ID                      = p_task_id
           AND PT.CARRYING_OUT_ORGANIZATION_ID = HOU.ORGANIZATION_ID
           AND PT.WORK_TYPE_ID                 = PWT.WORK_TYPE_ID(+)
        AND userenv('lang')                 = PWT.language(+)
           AND PT.SERVICE_TYPE_CODE            = PL.LOOKUP_CODE(+)
           AND PL.LOOKUP_TYPE(+)               = 'SERVICE_TYPE';

      l_record_found                     VARCHAR2(1) := 'N';
      l_num_of_records                   NUMBER;

   BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        OPEN cur_pa_tasks_sub;
        LOOP
           FETCH cur_pa_tasks_sub INTO   x_carrying_out_org_id
                                         ,x_carrying_out_org_name
                                         ,x_work_type_id
                                         ,x_work_type_name
                                         ,x_service_type_code
                                         ,x_service_type_name;
           IF cur_pa_tasks_sub%NOTFOUND
           THEN
              EXIT;
           ELSE
              l_record_found := 'Y';
           END IF;
        END LOOP;
        l_num_of_records := cur_pa_tasks_sub%ROWCOUNT;
        CLOSE cur_pa_tasks_sub;
        --more than one row is found
        IF l_num_of_records > 1 AND l_record_found = 'Y'
        THEN
           x_error_msg_code:= 'PA_PRJ_TOO_MANY_TASKS';
           RAISE TOO_MANY_ROWS;
        ELSIF l_num_of_records = 0 AND l_record_found = 'N'
        THEN
           --no row with p_task_id is found
           x_error_msg_code:= 'PA_PRJ_INV_TASK_ID';
           RAISE NO_DATA_FOUND;
        END IF;
   EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         -- 4537865 : Start
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;
	-- 4537865 : End
       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
         -- 4537865 : Start
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;

         -- 4537865 : End
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
         -- 4537865 : Start
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;

         x_error_msg_code := SQLCODE ;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_UILS',
                              p_procedure_name => 'FETCH_TASK_ATTIBUTES',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
         -- 4537865 : End
         RAISE;
   END FETCH_TASK_ATTIBUTES;


-- API name                      : FETCH_PROJECT_ATTIBUTES
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                 IN  NUMBER    REQUIRED
-- x_carrying_out_org_id        OUT NUMBER    REQUIRED
-- x_carrying_out_org_name      OUT VARCHAR2  REQUIRED
-- x_work_type_id               OUT NUMBER    REQUIRED
-- x_work_type_name             OUT VARCHAR2  REQUIRED
-- x_service_type_code          OUT VARCHAR2    REQUIRED
-- x_service_type_name          OUT VARCHAR2  REQUIRED
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  14-JUN-01   Majid Ansari             -Created
--
--

   PROCEDURE FETCH_PROJECT_ATTIBUTES(
       p_project_id                  IN NUMBER,
       x_carrying_out_org_id        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_carrying_out_org_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_work_type_id               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_work_type_name             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_code          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_service_type_name          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) AS

/* Bug 2680486 -- Performance changes -- To avoid Non-mergable view issue,
                  Changed PA_WORK_TYPES_VL to PA_WORK_TYPES_TL and added condition for userenev('lang')*/

  -- MOAC Changes: Bug 4363092: removed nvl with org_id
      CURSOR cur_pa_project
      IS
        SELECT  PPA.CARRYING_OUT_ORGANIZATION_ID
               ,HOU.NAME            CARRYING_OUT_ORGANIZATION_NAME
               ,PPA.WORK_TYPE_ID
               ,PWT.NAME            WORK_TYPE_NAME
               ,PPT.SERVICE_TYPE_CODE
               ,PL.MEANING          SERVICE_TYPE_NAME
          FROM  PA_PROJECTS_ALL       PPA
               ,HR_ORGANIZATION_UNITS HOU
               ,PA_WORK_TYPES_TL      PWT
               ,PA_LOOKUPS            PL
               ,PA_PROJECT_TYPES_ALL  PPT
         WHERE PPA.PROJECT_ID                      = p_project_id
           AND PPA.CARRYING_OUT_ORGANIZATION_ID = HOU.ORGANIZATION_ID
           AND PPA.WORK_TYPE_ID                 = PWT.WORK_TYPE_ID(+)
           AND userenv('lang')                  = PWT.language(+)
           AND PPA.PROJECT_TYPE                 = PPT.PROJECT_TYPE
           AND PPA.ORG_ID                       = PPT.ORG_ID
           AND PPT.SERVICE_TYPE_CODE            = PL.LOOKUP_CODE(+)
           AND PL.LOOKUP_TYPE(+)                = 'SERVICE_TYPE';

      l_record_found                     VARCHAR2(1) := 'N';
      l_num_of_records                   NUMBER;

   BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
        OPEN cur_pa_project;
        LOOP
           FETCH cur_pa_project INTO   x_carrying_out_org_id
                                         ,x_carrying_out_org_name
                                         ,x_work_type_id
                                         ,x_work_type_name
                                         ,x_service_type_code
                                         ,x_service_type_name;
           IF cur_pa_project%NOTFOUND
           THEN
              EXIT;
           ELSE
              l_record_found := 'Y';
           END IF;
        END LOOP;
        l_num_of_records := cur_pa_project%ROWCOUNT;
        CLOSE cur_pa_project;
        --more than one row is found
        IF l_num_of_records > 1 AND l_record_found = 'Y'
        THEN
           x_error_msg_code:= 'PA_PRJ_TOO_MANY_PROJ';
           RAISE TOO_MANY_ROWS;
        ELSIF l_num_of_records = 0 AND l_record_found = 'N'
        THEN
           --no row with p_task_id is found
           x_error_msg_code:= 'PA_PRJ_INV_PROJECT_ID';
           RAISE NO_DATA_FOUND;
        END IF;
   EXCEPTION
       WHEN no_data_found THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
-- 4537865 :Start
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;

-- 4537865 :End
       WHEN too_many_rows THEN
         x_return_status:= FND_API.G_RET_STS_ERROR;
-- 4537865 :Start
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;

-- 4537865 :End
       WHEN OTHERS THEN
         x_return_status:= FND_API.G_RET_STS_UNEXP_ERROR;
-- 4537865 :Start
       x_carrying_out_org_id        := NULL ;
       x_carrying_out_org_name      := NULL ;
       x_work_type_id               := NULL ;
       x_work_type_name             := NULL ;
       x_service_type_code          := NULL ;
       x_service_type_name          := NULL ;


         x_error_msg_code := SQLCODE ;
         fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_UILS',
                              p_procedure_name => 'FETCH_PROJECT_ATTIBUTES',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
-- 4537865 :End
         RAISE;
   END FETCH_PROJECT_ATTIBUTES;


  Function IsSummaryTask(p_project_id IN NUMBER,
                         p_task_id    IN NUMBER)
  return varchar2
  IS

    cursor c1 IS
    select 'Y'
    from pa_tasks t
    where t.project_id = p_project_id and
    t.parent_task_id = p_task_id;

    l_summary_flag VARCHAR2(1);

  BEGIN

  OPEN c1;
  FETCH c1 INTO l_summary_flag;
  IF c1%NOTFOUND THEN
    CLOSE c1;
    return 'N';
  ELSE
    CLOSE c1;
    return 'Y';
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      return 'N';
  END IsSummaryTask;

-- API name                      : GetWbsLevel
-- Type                          : Utility Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                 IN  NUMBER    REQUIRED
-- p_task_id                    IN  NUMBER    REQUIRED
-- x_task_level                 OUT NUMBER    REQUIRED
-- x_task_level_above           OUT NUMBER    REQUIRED
-- x_return_status         OUT VARCHAR2  REQUIRED
-- x_error_msg_code        OUT VARCHAR2  REQUIRED
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

   PROCEDURE GetWbsLevel(
       p_project_id                 IN NUMBER,
       p_task_id                    IN NUMBER,

       x_task_level                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_parent_task_id             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_top_task_id                OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_display_sequence           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895

       x_task_level_above           OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
       x_parent_task_id_above       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_top_task_id_above          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_display_sequence_above     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895

       x_task_id_above              OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
       x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_error_msg_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ) AS

     --Get wbs of the task shown above the indenting task.
/*     CURSOR cur_wbs_above
     IS
       SELECT wbs_level, task_id, top_task_id, parent_task_id, display_sequence
         FROM pa_tasks
        WHERE project_id = p_project_id
          AND display_sequence = ( SELECT max( display_sequence )
                                     FROM pa_tasks
                                    WHERE project_id = p_project_id
                                      AND display_sequence < ( SELECT display_sequence
                                                                 FROM pa_tasks
                                                                WHERE project_id = p_project_id
                                                                  AND task_id = p_task_id ) );*/

     --WITH THE CHANGE IN THE DATA MODEL p_task_id will from now act as p_task_version_id
     CURSOR cur_wbs_above
     IS
       SELECT pt.wbs_level, pt.task_id, pt.top_task_id, pt.parent_task_id, ppev.display_sequence
         FROM pa_tasks pt, pa_proj_element_versions ppev
        WHERE pt.project_id = p_project_id
          AND ppev.proj_element_id = pt.task_id
          AND ppev.display_sequence = ( SELECT max( display_sequence )
                                          FROM pa_proj_element_versions
                                         WHERE project_id = p_project_id
                                           AND display_sequence < ( SELECT display_sequence
                                                                      FROM pa_proj_element_versions
                                                                     WHERE project_id = p_project_id
                                                                       AND proj_element_id = p_task_id ) );
     ---Get the wbs of the task being indented.
/*     CURSOR cur_wbs
     IS
       SELECT wbs_level, top_task_id, parent_task_id, display_sequence
         FROM pa_tasks
        WHERE project_id = p_project_id
          AND task_id    = p_task_id;*/

     CURSOR cur_wbs
     IS
       SELECT pt.wbs_level, pt.top_task_id, pt.parent_task_id, ppev.display_sequence
         FROM pa_tasks pt, pa_proj_element_versions ppev
        WHERE pt.project_id = p_project_id
          AND ppev.proj_element_id = p_task_id
          AND ppev.proj_element_id = pt.task_id;

   BEGIN

      x_return_status:= FND_API.G_RET_STS_SUCCESS;

      OPEN cur_wbs_above;
      FETCH cur_wbs_above INTO x_task_level_above, x_task_id_above, x_top_task_id_above,
                               x_parent_task_id_above, x_display_sequence_above;
      CLOSE cur_wbs_above;

      OPEN cur_wbs;
      FETCH cur_wbs INTO x_task_level, x_top_task_id,
                               x_parent_task_id, x_display_sequence;
      CLOSE cur_wbs;

   EXCEPTION
      WHEN OTHERS THEN
      x_return_status:= FND_API.G_RET_STS_ERROR;
-- 4537865 : Start
       x_task_level                 := 1 ; -- set task level as 1 so that ,caller API throws error properly
       x_parent_task_id             := NULL ;
       x_top_task_id                := NULL ;
       x_display_sequence           := 1; -- set x_display_sequence as 1 so that ,caller API throws error properly

       x_task_level_above           := NULL ;
       x_parent_task_id_above       := NULL ;
       x_top_task_id_above          := NULL ;
       x_display_sequence_above     := NULL ;

       x_task_id_above              := NULL ;
-- 4537865 : End
   END GetWbsLevel;

-- API name                      : REF_PRJ_TASK_ID_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_reference_project_id      IN    NUMBER     REQUIRED
-- p_reference_task_id         IN    NUMBER     REQUIRED
-- x_return_status         OUT      VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  REF_PRJ_TASK_ID_REQ_CHECK(
 p_reference_project_id      IN    NUMBER   ,
 p_reference_task_id         IN    NUMBER    ,
 x_return_status               OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) AS
BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;
     IF p_reference_project_id IS NULL OR p_reference_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
         x_error_msg_code := 'PA_TASK_TARGET_PRJ_ID_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_reference_task_id IS NULL OR p_reference_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
         x_error_msg_code := 'PA_TASK_TARGET_TASK_ID_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END REF_PRJ_TASK_ID_REQ_CHECK;


-- API name                      : SRC_PRJ_TASK_ID_REQ_CHECK
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id      IN    NUMBER     REQUIRED
-- p_task_id         IN    NUMBER     REQUIRED
-- x_return_status         OUT      VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  25-MAY-01   Majid Ansari             -Created
--
--

 PROCEDURE  SRC_PRJ_TASK_ID_REQ_CHECK(
 p_project_id      IN    NUMBER   ,
 p_task_id         IN    NUMBER    ,
 x_return_status               OUT   NOCOPY VARCHAR2   , --File.Sql.39 bug 4440895
 x_error_msg_code            OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) AS
BEGIN
     x_return_status:= FND_API.G_RET_STS_SUCCESS;
     IF p_project_id IS NULL OR p_project_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
         x_error_msg_code := 'PA_TASK_SOURCE_PRJ_ID_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;

     IF p_task_id IS NULL OR p_task_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
     THEN
         x_error_msg_code := 'PA_TASK_SOURCE_TASK_ID_REQ';
         x_return_status:= FND_API.G_RET_STS_ERROR;
         RAISE  FND_API.G_EXC_ERROR;
     END IF;
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
    x_return_status:= FND_API.G_RET_STS_ERROR;
END SRC_PRJ_TASK_ID_REQ_CHECK;


--procedure from pa_project_check_pvt.check_start_end_date_Pvt
PROCEDURE check_start_end_date
( p_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_context                 IN  VARCHAR2 := 'START'
 ,p_old_start_date          IN  DATE
 ,p_new_start_date          IN  DATE
 ,p_old_end_date            IN  DATE
 ,p_new_end_date            IN  DATE
 ,p_update_start_date_flag  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_update_end_date_flag    OUT NOCOPY VARCHAR2          ) --File.Sql.39 bug 4440895
IS
  l_api_name      CONSTANT VARCHAR2(30) := 'check_start_end_date';
  l_start_date    DATE;
  l_end_date      DATE;
  l_meaning       pa_lookups.meaning%TYPE;
BEGIN
p_return_status := FND_API.G_RET_STS_SUCCESS;

-- added by hsiu
-- set token
IF p_context = 'START' then
    l_meaning := null;
else
    select meaning into l_meaning
    from pa_lookups
    where lookup_type = 'PA_DATE' and lookup_code = p_context;
end if;

IF p_new_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
AND p_new_start_date IS NOT NULL        --redundant, but added for clarity
THEN
     IF p_new_start_date <> NVL(p_old_start_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
     THEN
          p_update_start_date_flag := 'Y';
          l_start_date := p_new_start_date;
     ELSE
          p_update_start_date_flag := 'N';
          l_start_date := p_new_start_date;
     END IF;

     IF p_new_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     AND p_new_end_date IS NOT NULL     --redundant, but added for clarity
     THEN
          IF p_new_end_date <> NVL(p_old_end_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
          THEN
               p_update_end_date_flag := 'Y';
               l_end_date := p_new_end_date;
          ELSE
               p_update_end_date_flag := 'N';
               l_end_date := p_new_end_date;
          END IF;

          IF l_start_date > l_end_date
          THEN
               IF FND_MSG_PUB.check_msg_level
                          (FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
/*
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_START_DATE2'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');

*/
        fnd_message.set_name('PA', 'PA_INVALID_START_DATE2');
--hsiu: commented for bug 2686499
--        fnd_message.set_token('PA_DATE',l_meaning);
        fnd_msg_pub.add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
          END IF;

     ELSIF p_new_end_date IS NULL
     THEN
          IF p_old_end_date IS NOT NULL
          THEN
               p_update_end_date_flag := 'Y';
          ELSE
               p_update_end_date_flag := 'N';
          END IF;
     ELSE

          p_update_end_date_flag := 'N';

          IF p_old_end_date IS NULL
          THEN
               NULL;
          ELSE

              IF l_start_date > p_old_end_date THEN
               IF FND_MSG_PUB.check_msg_level
                           (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
/*
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_START_DATE2'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             fnd_message.set_token('PA_DATE',l_meaning);
*/
        fnd_message.set_name('PA', 'PA_INVALID_START_DATE2');
--commented for bug 2686499
--        fnd_message.set_token('PA_DATE',l_meaning);
        fnd_msg_pub.add;
               END IF;
               RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF;
     END IF;

ELSIF p_new_start_date IS NULL
THEN
     IF p_old_start_date IS NOT NULL
     THEN
          p_update_start_date_flag := 'Y';
     ELSE
          p_update_start_date_flag := 'N';
     END IF;

     IF p_new_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     AND p_new_end_date IS NOT NULL
     THEN
          IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
          THEN
/*
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_DATES_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             fnd_message.set_token('PA_DATE',l_meaning);
*/
        fnd_message.set_name('PA', 'PA_DATES_INVALID');
        fnd_message.set_token('PA_DATE',l_meaning);
        fnd_msg_pub.add;
          END IF;

          RAISE FND_API.G_EXC_ERROR;

     ELSIF p_new_end_date IS NULL
     THEN
          IF p_old_end_date IS NOT NULL
          THEN
               p_update_end_date_flag := 'Y';
          ELSE
               p_update_end_date_flag := 'N';
          END IF;
     ELSE

          p_update_end_date_flag := 'N';

          IF p_old_end_date IS NOT NULL   --start_date is null
          THEN
               IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
               THEN
/*
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_DATES_INVALID'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             fnd_message.set_token('PA_DATE',l_meaning);
*/
        fnd_message.set_name('PA', 'PA_INVALID_START_DATE2');
--commented for bug 2686499
--        fnd_message.set_token('PA_DATE',l_meaning);
        fnd_msg_pub.add;
               END IF;

               RAISE FND_API.G_EXC_ERROR;
          END IF;
     END IF;

ELSE --p_new_start_date was not passed

     p_update_start_date_flag := 'N';

     IF p_new_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
     AND p_new_end_date IS NOT NULL
     THEN
          IF p_new_end_date <> nvl(p_old_end_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE)
          THEN
               p_update_end_date_flag := 'Y';

               IF p_old_start_date IS NULL
               OR p_old_start_date > p_new_end_date
               THEN
                 IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR)
                    THEN
/*
             pa_interface_utils_pub.map_new_amg_msg
              ( p_old_message_code => 'PA_INVALID_START_DATE2'
               ,p_msg_attribute    => 'CHANGE'
               ,p_resize_flag      => 'N'
               ,p_msg_context      => 'GENERAL'
               ,p_attribute1       => ''
               ,p_attribute2       => ''
               ,p_attribute3       => ''
               ,p_attribute4       => ''
               ,p_attribute5       => '');
             fnd_message.set_token('PA_DATE',l_meaning);
*/
          fnd_message.set_name('PA', 'PA_INVALID_START_DATE2');
--commented for bug 2686499
--          fnd_message.set_token('PA_DATE',l_meaning);
          fnd_msg_pub.add;
                    END IF;

                    RAISE FND_API.G_EXC_ERROR;
               END IF;

          ELSE
               p_update_end_date_flag := 'N';

          END IF;

     ELSIF p_new_end_date IS NULL
     THEN
          IF p_old_end_date IS NOT NULL
          THEN
               p_update_end_date_flag := 'Y';

          ELSE
               p_update_end_date_flag := 'N';

          END IF;
     ELSE
          p_update_end_date_flag := 'N';

     END IF;
END IF;


EXCEPTION

     WHEN FND_API.G_EXC_ERROR
     THEN

     p_return_status := FND_API.G_RET_STS_ERROR;

-- 4537865 : Start RESET other out params too.
     p_update_start_date_flag := NULL ;
     p_update_end_date_flag := NULL ;

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
     THEN

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

-- 4537865 : Start RESET other out params too.
     p_update_start_date_flag := NULL ;
     p_update_end_date_flag := NULL ;
-- 4537865 : End

     WHEN OTHERS THEN

     p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
-- 4537865 : Start RESET other out params too.
     p_update_start_date_flag := NULL ;
     p_update_end_date_flag := NULL ;
-- 4537865 : End

     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
          FND_MSG_PUB.add_exc_msg
                    ( p_pkg_name        => 'PA_TASKS_MAINT_UTILS'
                    , p_procedure_name  => l_api_name  );

     END IF;

END check_start_end_date;

-- API name                      : LOCK_PROJECT
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                        IN    NUMBER     REQUIRED
-- p_wbs_record_version_number         IN    NUMBER     REQUIRED
-- p_validate_only             IN  VARCHAR2    := FND_API.G_TRUE
-- x_return_status         OUT      VARCHAR2   REQUIRED
-- x_error_msg_code            OUT   VARCHAR2   REQUIRED
--
--  History
--
--  16-JUL-01   Majid Ansari             -Created
--
--

 PROCEDURE  LOCK_PROJECT(
 p_validate_only             IN  VARCHAR2 := FND_API.G_TRUE,
 p_calling_module            IN  VARCHAR2 := 'SELF_SERVICE',
 p_project_id                IN  NUMBER,
 p_wbs_record_version_number IN  NUMBER,
 x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
 x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) AS
 l_dummy_char  VARCHAR2(1);
BEGIN
      IF p_validate_only <> FND_API.G_TRUE
      THEN
        BEGIN
           SELECT 'x' INTO l_dummy_char
            -- HY: changed from pa_projects_all to pa_proj_elem_ver_structure
             FROM pa_proj_elem_ver_structure
            WHERE project_id             = p_project_id
              AND wbs_record_version_number  = p_wbs_record_version_number
              FOR UPDATE OF record_version_number NOWAIT;

        EXCEPTION
           WHEN TIMEOUT_ON_RESOURCE THEN
               PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                    p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
               x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
               x_return_status := 'E' ;
           WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
               IF SQLCODE = -54 THEN
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                  x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                  x_return_status := 'E' ;
               ELSE
                  raise;
               END IF;
        END;
      ELSE
         BEGIN
           SELECT 'x' INTO l_dummy_char
            -- HY: changed from pa_projects_all to pa_proj_elem_ver_structure
           FROM pa_proj_elem_ver_structure
           WHERE project_id           = p_project_id
           AND wbs_record_version_number  = p_wbs_record_version_number;
          EXCEPTION
            WHEN NO_DATA_FOUND THEN
               if p_calling_module = 'FORM' then
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'FND',
                                       p_msg_name       => 'FORM_RECORD_CHANGED');
                  x_msg_data := 'FORM_RECORD_CHANGED';
               else
                  PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                       p_msg_name       => 'PA_XC_RECORD_CHANGED');
                  x_msg_data := 'PA_XC_RECORD_CHANGED';
               end if;
               x_return_status := 'E' ;
            WHEN OTHERS THEN
              IF SQLCODE = -54 THEN
                 PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                      p_msg_name       => 'PA_XC_ROW_ALREADY_LOCKED');
                 x_msg_data := 'PA_XC_ROW_ALREADY_LOCKED';
                 x_return_status := 'E' ;
              END IF;
          END;
      END IF;
END LOCK_PROJECT;

-- API name                      : INCREMENT_WBS_REC_VER_NUM
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_project_id                IN    NUMBER     REQUIRED
-- p_wbs_record_version_number IN NUMBER
-- x_return_status         OUT      VARCHAR2   REQUIRED
--
--  History
--
--  16-JUL-01   Majid Ansari             -Created
--
--

PROCEDURE INCREMENT_WBS_REC_VER_NUM(
 p_project_id                 IN NUMBER,
 p_wbs_record_version_number  IN NUMBER,
 x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) AS
BEGIN
  x_return_status := 'S';

  /* increment wbs_record_version_number for project id */
  -- HY: changed from pa_projects_all to pa_proj_elem_ver_structure
  UPDATE pa_proj_elem_ver_structure
     SET wbs_record_version_number = NVL( wbs_record_version_number, 0 ) + 1
   WHERE project_id = p_project_id
     AND wbs_record_version_number = p_wbs_record_version_number;

EXCEPTION WHEN OTHERS THEN
     x_return_status := 'E';
END INCREMENT_WBS_REC_VER_NUM;


-- API name                      : GET_TASK_MANAGER_PROFILE
-- Type                          : Utility procedure
-- Pre-reqs                      : None
-- Return Value                  : Y or N
-- Parameters                    : N/A
--
--  History
--
--  21-NOV-02   hubert siu            -Created
--
--
FUNCTION GET_TASK_MANAGER_PROFILE RETURN VARCHAR2
IS
  l_ret VARCHAR2(1);
BEGIN
  l_ret := fnd_profile.value('PA_TM_PROJ_MEMBER');
  IF (l_ret IS NULL) THEN
    return 'N';
  END IF;
  return l_ret;
END GET_TASK_MANAGER_PROFILE;

--Begin add rtarway FP.M development

-- Procedure            : CHECK_MOVE_FINANCIAL_TASK_OK
-- Type                 : Public Procedure
-- Purpose              : The API will be used to check the financial task is not getting moved of Workplan task.
--                      : This API needs to be called from Move/Copy and Indent task
-- Note                 : If the task being moved is financial task, check the task under which it is being moved.
--                      : If it is non-financial task, raise error.
-- Assumptions          : The API assumes that API is called under partial sharing case only

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_task_version_id            NUMBER   Yes              This indicates the financial task which is being moved
-- p_ref_task_version_id        NUMBER   Yes              This task indicates the task under which the financial task is being moved.

PROCEDURE CHECK_MOVE_FINANCIAL_TASK_OK
   (
       p_api_version            IN   NUMBER   := 1.0
     , p_calling_module         IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode             IN   VARCHAR2 := 'N'
     , p_task_version_id        IN   NUMBER
     , p_ref_task_version_id    IN   NUMBER
     , x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data               OUT  NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
     , x_error_msg_code         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_fin_task_flag_ptask           VARCHAR2(1);
l_fin_task_flag_reftask         VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

--This CURSOR will fetch the financial task flag value for the passed task version id

CURSOR c_get_fin_task_flag (l_task_version_id NUMBER )
IS
SELECT FINANCIAL_TASK_FLAG
FROM PA_PROJ_ELEMENT_VERSIONS plv
WHERE plv.ELEMENT_VERSION_ID = l_task_version_id;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CHECK_MOVE_FINANCIAL_TASK_OK',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_UTILS : CHECK_MOVE_FINANCIAL_TASK_OK : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_task_version_id'||':'||p_task_version_id,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_ref_task_version_id'||':'||p_ref_task_version_id,
                                     l_debug_level3);
     END IF;


     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_UTILS : CHECK_MOVE_FINANCIAL_TASK_OK : Checking whether p_task_version_id is Financial or WorkPlan';
          Pa_Debug.WRITE(g_module_name , Pa_Debug.g_err_stage , l_debug_level3);
     END IF;


    OPEN  c_get_fin_task_flag (p_task_version_id);
    FETCH c_get_fin_task_flag INTO l_fin_task_flag_ptask;
    CLOSE c_get_fin_task_flag ;

    IF (l_fin_task_flag_ptask = 'Y')THEN


     OPEN  c_get_fin_task_flag (p_ref_task_version_id);
     FETCH c_get_fin_task_flag INTO l_fin_task_flag_reftask;
     CLOSE c_get_fin_task_flag ;

         IF (l_fin_task_flag_reftask = 'N')
          THEN

             --Raise an error message
              x_error_msg_code := 'PA_CANT_MOVE_SELECTED_TASK';
              x_return_status := FND_API.G_RET_STS_ERROR;
           return;
         END IF;
    END IF;

EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     -- 4537865 : RESET x_error_message_code also
	x_error_msg_code := SQLCODE ;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_TASKS_MAINT_UTILS'
                    ,p_procedure_name  => 'CHECK_MOVE_FINANCIAL_TASK_OK'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END CHECK_MOVE_FINANCIAL_TASK_OK;

-- Procedure            : CHECK_WORKPLAN_TASK_EXISTS
-- Type                 : Public Procedure
-- Purpose              : This API will be used to check whether there exists any workplan task under the
--                      : passed financial task. If there exists any workplan task below a financial task,
--                      : the task cannot be deleted.This API will be directly called from Delete Financial Task page
-- Note                 :
--                      :
-- Assumptions          : This will be called with one task version id and not with many task version ids.

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_task_version_id            NUMBER   Yes             The column indicates the task Id that is getting deleted.



PROCEDURE CHECK_WORKPLAN_TASK_EXISTS
   (
       p_api_version         IN   NUMBER   :=  1.0
     , p_calling_module      IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode          IN   NUMBER   := 'N'
     , p_task_version_id     IN   NUMBER
     , x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count           OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data            OUT  NOCOPY VARCHAR2    --File.Sql.39 bug 4440895
     , x_error_msg_code      OUT  NOCOPY VARCHAR2              --File.Sql.39 bug 4440895
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_counter                       NUMBER := 1;
l_task_id                       pa_proj_element_versions.element_version_id%TYPE;
l_fin_flag                      VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;


--This cursor selects 'X' from dual if any non-financial task exists
--in the hierarchy from PA_OBJECT_RELATIONSHIPS
--for the passed task version id.
CURSOR c_get_WP_rec(l_element_version_id NUMBER)
IS
SELECT 'X'
FROM dual
WHERE EXISTS
(
     SELECT proj_element_id
     , element_version_id
     , financial_task_flag
     FROM PA_PROJ_ELEMENT_VERSIONS plv
     WHERE element_version_id
     IN
     (     -- This select statement tries to select childs task version ids
          SELECT object_id_to1
          FROM pa_object_relationships
          WHERE relationship_type='S'
          AND relationship_subtype='TASK_TO_TASK'
          START WITH object_id_from1 = l_element_version_id
          CONNECT BY object_id_from1 = PRIOR object_id_to1
     )
     AND financial_task_flag = 'N'
);

BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');

     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'CHECK_WORKPLAN_TASK_EXISTS',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_UTILS : CHECK_WORKPLAN_TASK_EXISTS : Printing Input parameters';
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_module_name,'p_task_version_id'||':'||p_task_version_id,
                                     l_debug_level3);
     END IF;

     --If any non financial task exists in the hierarchy, the cursor will select 'X'
     OPEN  c_get_WP_rec(p_task_version_id);
     FETCH c_get_WP_rec
     INTO  l_fin_flag;
     CLOSE c_get_WP_rec;

     IF (l_fin_flag = 'X')
     THEN
          --Populate error message
           x_error_msg_code := 'PA_WORKPLAN_TASK_EXISTS';
           x_return_status  := FND_API.G_RET_STS_ERROR;

     END IF;
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS )
     THEN
         return;
     END IF;

EXCEPTION

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;

     -- 4537865 : RESET x_error_message_code also
        x_error_msg_code := SQLCODE ;

     IF c_get_WP_rec%ISOPEN THEN
          CLOSE c_get_WP_rec;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_TASKS_MAINT_UTILS'
                    ,p_procedure_name  => 'CHECK_WORKPLAN_TASK_EXISTS'
                    ,p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_module_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

END CHECK_WORKPLAN_TASK_EXISTS;

-- End Add rtarway FP-M Development

--Added by rtarway for BUG 4081329
/*Check_End_Date_EI
 This API validates if the passed end date is greater or equal to the maximum of all subtasks' EI dates
*/
procedure Check_End_Date_EI(  p_project_id      IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_end_date        IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS

   CURSOR cur_date(l_task_id NUMBER, l_project_id NUMBER ) IS
   SELECT MAX(pe.expenditure_item_date) ei_date
    FROM pa_expenditure_items_all pe
   WHERE pe.task_id IN (SELECT p.task_id
                        FROM pa_tasks p
                        where p.project_id = l_project_id
			--Added by rtarway for bug 4242216
                        AND not exists
		        (
		         select parent_task_id
			 from   pa_tasks pt
			 where  pt.parent_task_id =p.task_id
			 and    pt.project_id=l_project_id
		        )
			--Added by rtarway for bug 4242216
 		        START WITH p.task_id= l_task_id
                        CONNECT BY PRIOR p.task_id = p.parent_task_id
                        and p.project_id = l_project_id)
   AND pe.project_id = l_project_id;

   x_ei_date pa_expenditure_items_all.expenditure_item_date%TYPE ;

   -- Bug 6633233
   l_task_num  pa_proj_elements.element_number%type;

  BEGIN

   OPEN cur_date(p_task_id, p_project_id);
   FETCH cur_date INTO x_ei_date ;
   IF cur_date%NOTFOUND THEN
     CLOSE cur_date ;
   ELSE
       IF (x_ei_date IS NOT NULL AND
           p_end_date IS NOT NULL AND
           p_end_date < x_ei_date ) THEN
               close cur_date;
               -- Start Changes for bug 6467429
               l_task_num := pa_task_utils.get_task_number(p_task_id);
               PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_EI_INVALID_DATES_TSK',
                           p_token1         => 'TASKNUM',
                           p_value1         => l_task_num,
                           p_token2         => 'EIFINISHDATE',
                           p_value2         => x_ei_date);
               x_msg_data := 'PA_EI_INVALID_DATES_TSK';
               /*
               PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_EI_INVALID_DATES',
                           p_token1         => 'EIDATE',
                           p_value1         => x_ei_date);
               x_msg_data := 'PA_EI_INVALID_DATES';
               */
               -- End Changes for bug 6467429
               RAISE FND_API.G_EXC_ERROR;
      ELSE
        close cur_date;
      END IF ;
   END IF ;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	-- 4537865 : RESET x_msg_count, x_msg_data also
	x_msg_count := 1 ;
	x_msg_data := SUBSTRB(SQLERRM,1,240);

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'Check_End_Date_EI',
			      p_error_text => x_msg_data); -- 4537865
  END Check_End_Date_EI;
/*Check_Start_Date_EI
 This API validates if the passed start date is less or equal to the minimun of all subtasks' EI dates
*/

procedure Check_Start_Date_EI(  p_project_id      IN NUMBER,
                             p_task_id         IN NUMBER,
                             p_start_date        IN DATE,
                             x_return_status   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data        OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
  IS

CURSOR cur_start_date(l_task_id NUMBER, l_project_id NUMBER) IS
  SELECT MIN(pe.expenditure_item_date) ei_date
    FROM pa_expenditure_items_all pe
   WHERE pe.task_id IN (
                        SELECT p.task_id
                        FROM pa_tasks p
                        WHERE p.project_id = l_project_id
                        --Added by rtarway for bug 4242216
			AND not exists
			(
			 select parent_task_id
			 from   pa_tasks pt
			 where  pt.parent_task_id =p.task_id
			 and    pt.project_id=l_project_id
			)
			--Added by rtarway for bug 4242216
			START WITH p.task_id= l_task_id
                        CONNECT BY PRIOR p.task_id = p.parent_task_id
                        AND p.project_id = l_project_id
                       )
   and pe.project_id = l_project_id;

x_ei_min_date pa_expenditure_items_all.expenditure_item_date%TYPE ;

-- Bug 6633233
l_task_num  pa_proj_elements.element_number%type;

  BEGIN

   OPEN cur_start_date(p_task_id, p_project_id);
   FETCH cur_start_date INTO x_ei_min_date ;
   IF cur_start_date%NOTFOUND THEN
     CLOSE cur_start_date ;
   ELSE
       IF (x_ei_min_date IS NOT NULL AND
           p_start_date IS NOT NULL AND
           p_start_date > x_ei_min_date ) THEN
               close cur_start_date;
               -- Start Changes for Bug 6633233
               l_task_num := pa_task_utils.get_task_number(p_task_id);
               PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_EI_INVALID_START_DATE_TSK',
                           p_token1         => 'TASKNUM',
                           p_value1         => l_task_num,
                           p_token2         => 'EISTARTDATE',
                           p_value2         => x_ei_min_date);
               x_msg_data := 'PA_EI_INVALID_START_DATE_TSK';
               /*
               PA_UTILS.ADD_MESSAGE
                          (p_app_short_name => 'PA',
                           p_msg_name       => 'PA_EI_INVALID_START_DATE',
                           p_token1         => 'EISTARTDATE',
                           p_value1         => x_ei_min_date);
               x_msg_data := 'PA_EI_INVALID_START_DATE';
               */
               -- End Changes for Bug 6633233
               RAISE FND_API.G_EXC_ERROR;
      ELSE
        close cur_start_date;
      END IF ;
   END IF ;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- 4537865 : RESET x_msg_count, x_msg_data also
        x_msg_count := 1 ;
        x_msg_data := SUBSTRB(SQLERRM,1,240);

      FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TASKS_MAINT_UTILS',
                              p_procedure_name => 'Check_Start_Date_EI',
			      p_error_text => x_msg_data);  -- 4537865
  END Check_Start_Date_EI;
--Added by rtarway for BUG 4081329

end PA_TASKS_MAINT_UTILS;

/
