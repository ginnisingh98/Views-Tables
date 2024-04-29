--------------------------------------------------------
--  DDL for Package Body PA_PROJECT_DATES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJECT_DATES_UTILS" AS
/* $Header: PARMPDUB.pls 120.16.12010000.6 2010/05/02 22:21:53 nisinha ship $ */


-- Global constant
G_PKG_NAME              CONSTANT VARCHAR2(30) := 'PA_PROJECT_DATES_UTILS';


-- API name		: Get_Project_Start_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_PROJECT_START_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE
IS
   l_target_start_date   DATE;
   l_scheduled_start_date DATE;
   l_actual_start_date    DATE;
   l_start_date		  DATE; -- Fix for Bug # 4506308.

   CURSOR get_dates_csr
   IS
   SELECT target_start_date, scheduled_start_date, actual_start_date, start_date -- Fix for Bug # 4506308.
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

BEGIN

   OPEN get_dates_csr;
   FETCH get_dates_csr INTO l_target_start_date, l_scheduled_start_date, l_actual_start_date, l_start_date;
										 -- Fix for Bug # 4506308.
   CLOSE get_dates_csr;

   IF l_actual_start_date IS NULL THEN
      IF l_scheduled_start_date IS NULL THEN

	 -- Begin fix for Bug # 4506308.

	 -- return l_target_start_date;

         if l_target_start_date is null then
	 	return l_start_date;
	 else
		return l_target_start_date;
	 end if;

	 -- End fix for Bug # 4506308.

      ELSE
         return l_scheduled_start_date;
      END IF;
   ELSE
      return l_actual_start_date;
   END IF;

EXCEPTION
   when OTHERS then
     return NULL;
END GET_PROJECT_START_DATE;



-- API name		: Get_Project_Finish_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_PROJECT_FINISH_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE
IS
   l_target_finish_date   DATE;
   l_scheduled_finish_date DATE;
   l_actual_finish_date    DATE;
   l_completion_date	   DATE; -- Fix for Bug # 4506308.

   CURSOR get_dates_csr
   IS
   SELECT target_finish_date, scheduled_finish_date, actual_finish_date, completion_date
										-- Fix for Bug # 4506308.
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

BEGIN

   OPEN get_dates_csr;
   FETCH get_dates_csr INTO l_target_finish_date, l_scheduled_finish_date, l_actual_finish_date
			    , l_completion_date; -- Fix for Bug # 4506308.
   CLOSE get_dates_csr;

   IF l_actual_finish_date IS NULL THEN
      IF l_scheduled_finish_date IS NULL THEN

	 -- Begin fix for Bug # 4506308.

         -- return l_target_finish_date;

	 if l_target_finish_date is null then
	 	return l_completion_date;
	 else
		return l_target_finish_date;
	 end if;

	 -- End fix for Bug # 4506308.

      ELSE
         return l_scheduled_finish_date;
      END IF;
   ELSE
      return l_actual_finish_date;
   END IF;

EXCEPTION
   when OTHERS then
     return NULL;
END GET_PROJECT_FINISH_DATE;



-- API name		: Check_Financial_Task_Exists
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_proj_element_id                    IN NUMBER

FUNCTION CHECK_FINANCIAL_TASK_EXISTS
(  p_proj_element_id                    IN NUMBER
) RETURN VARCHAR2
IS
   l_dummy         VARCHAR2(1);

   CURSOR C1
   IS
   SELECT 'Y'
   FROM PA_TASKS
   WHERE task_id = p_proj_element_id;

BEGIN
   OPEN C1;
   FETCH C1 INTO l_dummy;

   if C1%NOTFOUND then
      CLOSE C1;
      return 'N';
   else
      CLOSE C1;
      return 'Y';
   end if;

EXCEPTION
   when OTHERS then
      return 'N';
END CHECK_FINANCIAL_TASK_EXISTS;


-- API name		: Get_Task_Start_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_start_date               OUT DATE
-- x_start_as_of_date              OUT DATE
PROCEDURE GET_TASK_START_DATE
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_start_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_start_as_of_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
)
IS
  CURSOR get_task_sch_dates_csr
  IS
  SELECT a.scheduled_start_date, a.last_update_date
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = p_proj_element_id
  AND   b.element_version_id = a.element_version_id
  AND   b.project_id = a.project_id;

  CURSOR get_task_act_dates_csr
  IS
  SELECT a.actual_start_date, a.last_update_date
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = p_proj_element_id
  AND   b.element_version_id = a.element_version_id
  AND   b.project_id = a.project_id;

  l_scheduled_start_date     DATE;
  l_actual_start_date        DATE;
  l_scheduled_update_date    DATE;
  l_actual_update_date       DATE;
BEGIN

  x_task_start_date := NULL;
  x_start_as_of_date := NULL;

  OPEN get_task_sch_dates_csr;
  FETCH get_task_sch_dates_csr INTO l_scheduled_start_date, l_scheduled_update_date;
  CLOSE get_task_sch_dates_csr;

  OPEN get_task_act_dates_csr;
  FETCH get_task_act_dates_csr INTO l_actual_start_date, l_actual_update_date;
  CLOSE get_task_act_dates_csr;

  if l_actual_start_date IS NULL then
    if l_scheduled_start_date IS NULL then
      NULL;
    else
      x_task_start_date := l_scheduled_start_date;
      x_start_as_of_date := l_scheduled_update_date;
    end if;
  else
    x_task_start_date := l_actual_start_date;
    x_start_as_of_date := l_actual_update_date;
  end if;

EXCEPTION
   when OTHERS then
     x_task_start_date := NULL;
     x_start_as_of_date := NULL;
END GET_TASK_START_DATE;



-- API name		: Get_Task_Finish_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_finish_date              OUT DATE
-- x_finish_as_of_date             OUT DATE
PROCEDURE GET_TASK_FINISH_DATE
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_finish_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_finish_as_of_date             OUT NOCOPY DATE --File.Sql.39 bug 4440895
)
IS
  CURSOR get_task_sch_dates_csr
  IS
  SELECT a.scheduled_finish_date, a.last_update_date
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = p_proj_element_id
  AND   b.element_version_id = a.element_version_id
  AND   b.project_id = a.project_id;

  CURSOR get_task_act_dates_csr
  IS
  SELECT a.actual_finish_date, a.last_update_date
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = p_proj_element_id
  AND   b.element_version_id = a.element_version_id
  AND   b.project_id = a.project_id;

  l_scheduled_finish_date     DATE;
  l_actual_finish_date        DATE;
  l_scheduled_update_date     DATE;
  l_actual_update_date        DATE;
  l_finish_update_date        DATE;
BEGIN

  x_task_finish_date := NULL;
  x_finish_as_of_date := NULL;

  OPEN get_task_sch_dates_csr;
  FETCH get_task_sch_dates_csr INTO l_scheduled_finish_date, l_scheduled_update_date;
  CLOSE get_task_sch_dates_csr;

  OPEN get_task_act_dates_csr;
  FETCH get_task_act_dates_csr INTO l_actual_finish_date, l_actual_update_date;
  CLOSE get_task_act_dates_csr;

  if l_actual_finish_date IS NULL then
    if l_scheduled_finish_date IS NULL then
      NULL;
    else
      x_task_finish_date := l_scheduled_finish_date;
      x_finish_as_of_date := l_scheduled_update_date;
    end if;
  else
    x_task_finish_date := l_actual_finish_date;
    x_finish_as_of_date := l_actual_update_date;
  end if;

EXCEPTION
   when OTHERS then
     x_task_finish_date := NULL;
     x_finish_as_of_date := NULL;
END GET_TASK_FINISH_DATE;


-- API name		: Get_Task_Derived_Dates
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_start_date               OUT DATE
-- x_task_finish_date              OUT DATE
-- x_task_as_of_date               OUT DATE
PROCEDURE GET_TASK_DERIVED_DATES
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_start_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_task_finish_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_task_as_of_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
)
IS
  l_task_start_date      DATE;
  l_task_finish_date     DATE;
  l_task_as_of_date      DATE;

  l_start_as_of_date     DATE;
  l_finish_as_of_date    DATE;
BEGIN
  PA_PROJECT_DATES_UTILS.GET_TASK_START_DATE (
   p_project_id                  => p_project_id
  ,p_proj_element_id             => p_proj_element_id
  ,p_parent_structure_version_id => p_parent_structure_version_id
  ,x_task_start_date             => l_task_start_date
  ,x_start_as_of_date            => l_start_as_of_date );

  PA_PROJECT_DATES_UTILS.GET_TASK_FINISH_DATE (
   p_project_id                  => p_project_id
  ,p_proj_element_id             => p_proj_element_id
  ,p_parent_structure_version_id => p_parent_structure_version_id
  ,x_task_finish_date            => l_task_finish_date
  ,x_finish_as_of_date           => l_finish_as_of_date );

  x_task_start_date := l_task_start_date;
  x_task_finish_date := l_task_finish_date;
  -- Commented out for bug 2635769
  --if l_start_as_of_date > l_finish_as_of_date then
  --  x_task_as_of_date := l_start_as_of_date;
  --else
  --  x_task_as_of_date := l_finish_as_of_date;
  --end if;
   x_task_as_of_date := NULL;

EXCEPTION
   when OTHERS then
     x_task_start_date := NULL;
     x_task_finish_date := NULL;
     x_task_as_of_date := NULL;
END GET_TASK_DERIVED_DATES;


-- API name		: Get_Task_Copy_Dates
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_start_date               OUT DATE
-- x_task_finish_date              OUT DATE
PROCEDURE GET_TASK_COPY_DATES
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_start_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_task_finish_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,p_act_fin_date_flag             IN VARCHAR2   DEFAULT 'Y'  --bug 4229865
)
IS
  /* Commented for bug 5258713
  CURSOR get_task_sch_dates_csr
  IS
  SELECT a.scheduled_start_date, a.scheduled_finish_date
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = p_proj_element_id
  AND   b.element_version_id = a.element_version_id;

  CURSOR get_task_act_dates_csr
  IS
  SELECT a.actual_start_date, a.actual_finish_date
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = p_proj_element_id
  AND   b.element_version_id = a.element_version_id;
  */

  /*Added for bug 5258713 - Merged the two cursors*/
 	   CURSOR get_task_dates_csr
 	   IS
 	   SELECT a.actual_start_date, a.actual_finish_date,a.scheduled_start_date, a.scheduled_finish_date
 	   FROM PA_PROJ_ELEM_VER_SCHEDULE a,
 	        PA_PROJ_ELEMENT_VERSIONS b
 	   WHERE b.parent_structure_version_id = p_parent_structure_version_id
 	   AND   b.project_id = p_project_id
 	   AND   b.proj_element_id = p_proj_element_id
 	   AND   b.element_version_id = a.element_version_id
 	   AND   A.PROJECT_ID = B.PROJECT_ID; -- Also added a new condition for 5258713
 /* End Added for bug 5258713 */

  l_scheduled_start_date      DATE;
  l_scheduled_finish_date     DATE;
  l_actual_start_date         DATE;
  l_actual_finish_date        DATE;
BEGIN
   /*Commented for bug 5258713
  OPEN get_task_sch_dates_csr;
  FETCH get_task_sch_dates_csr INTO l_scheduled_start_date, l_scheduled_finish_date;
  CLOSE get_task_sch_dates_csr;

  OPEN get_task_act_dates_csr;
  FETCH get_task_act_dates_csr INTO l_actual_start_date, l_actual_finish_date;
  CLOSE get_task_act_dates_csr;
   */

   /*Added for bug 5258713 */
 OPEN get_task_dates_csr;
 FETCH get_task_dates_csr INTO l_actual_start_date, l_actual_finish_date, l_scheduled_start_date, l_scheduled_finish_date;
 CLOSE get_task_dates_csr;
   /* End Added for bug 5258713 */

--Added condition OR (l_actual_finish_date IS NULL) for bug 5338208
  if (l_actual_start_date IS NULL) OR (l_actual_finish_date IS NULL) then
    x_task_start_date := l_scheduled_start_date;
    x_task_finish_date := l_scheduled_finish_date;
  else
    x_task_start_date := l_actual_start_date;
    x_task_finish_date := l_actual_finish_date;
  end if;

-- bug 4229865
/*  Commented for bug 5338208
  IF  p_act_fin_date_flag = 'N'
  THEN
     x_task_finish_date := NULL;
  END IF;*/
-- end bug 4229865


EXCEPTION
   when OTHERS then
     x_task_start_date := NULL;
     x_task_finish_date := NULL;
END GET_TASK_COPY_DATES;


-- API name		: Get_Default_Proj_Start_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_DEFAULT_PROJ_START_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE
IS
   l_target_start_date   DATE;
   l_scheduled_start_date DATE;
   l_actual_start_date    DATE;

   CURSOR get_dates_csr
   IS
   SELECT target_start_date, scheduled_start_date, actual_start_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

BEGIN

   OPEN get_dates_csr;
   FETCH get_dates_csr INTO l_target_start_date, l_scheduled_start_date, l_actual_start_date;
   CLOSE get_dates_csr;

   IF l_actual_start_date IS NULL THEN
      IF l_scheduled_start_date IS NULL THEN
         IF l_target_start_date IS NULL THEN
            return SYSDATE;
         ELSE
            return l_target_start_date;
         END IF;
      ELSE
         return l_scheduled_start_date;
      END IF;
   ELSE
      return l_actual_start_date;
   END IF;

EXCEPTION
   when OTHERS then
     return SYSDATE;
END GET_DEFAULT_PROJ_START_DATE;



-- Bug 6335446: Start

-- API name             : Get_Default_Assign_Start_Date
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_DEFAULT_ASSIGN_START_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE
IS
   l_target_start_date    DATE;
   l_scheduled_start_date DATE;
   l_actual_start_date    DATE;
   l_return_date          DATE;
   l_util_start_date      DATE;
   l_transaction_date     DATE;

   CURSOR get_dates_csr
   IS
   SELECT target_start_date, scheduled_start_date, actual_start_date,start_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

BEGIN

   OPEN get_dates_csr;
   FETCH get_dates_csr INTO l_target_start_date, l_scheduled_start_date, l_actual_start_date, l_transaction_date;
   CLOSE get_dates_csr;

   IF l_transaction_date IS NULL THEN -- 6853114
    IF l_actual_start_date IS NULL THEN
      IF l_scheduled_start_date IS NULL THEN
         IF l_target_start_date IS NULL THEN
            l_return_date := SYSDATE;
         ELSE
            l_return_date := l_target_start_date;
         END IF;
       ELSE
          l_return_date :=  l_scheduled_start_date;
       END IF;
     ELSE
      l_return_date := l_actual_start_date;
     END IF;
   ELSE
     l_return_date := l_transaction_date;
   END IF;
   -- l_util_start_date :=  to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY'); /* commenting for For Bug 7304151 */
   l_util_start_date :=  to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'); /*Adding For Bug 7304151 */
   IF(  l_util_start_date IS NOT NULL ) THEN
     IF ( l_util_start_date >= l_return_date ) THEN
        l_return_date := l_util_start_date ;
     END IF;
   END IF;
   return  l_return_date ;
EXCEPTION
   when OTHERS then
   return SYSDATE;
END GET_DEFAULT_ASSIGN_START_DATE;


-- API name             : Is_Valid_Assign_Start_Date
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id           IN NUMBER
-- p_assign_start_date    IN DATE

FUNCTION IS_VALID_ASSIGN_START_DATE
(  p_project_id                    IN NUMBER,
   p_assign_start_date             IN DATE
) RETURN VARCHAR2
IS
   l_result_date          DATE;
   l_util_start_date      DATE;

BEGIN

   -- l_util_start_date :=  to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY'); /* commenting for For Bug 7304151 */
   l_util_start_date :=  to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=AMERICAN'); /*Adding For Bug 7304151 */
   IF(  l_util_start_date IS NOT NULL ) THEN
     l_result_date := l_util_start_date ;
   END IF;
   IF ( l_util_start_date IS NOT NULL ) THEN
     IF (  p_assign_start_date < l_result_date ) THEN
       RETURN 'N';
     ELSE
       RETURN 'Y';
     END IF;
   ELSE
      RETURN 'Y';
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
   RETURN 'N' ;
END IS_VALID_ASSIGN_START_DATE;

-- Bug 6335446: End



-- API name		: Get_Struct_Schedule_Dates
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_structure_version_id   IN NUMBER
-- x_schedule_start_date               OUT DATE
-- x_schedule_finish_date              OUT DATE
-- x_schedule_as_of_date               OUT DATE
-- x_schedule_duration                 OUT NUMBER
PROCEDURE GET_STRUCT_SCHEDULE_DATES
(  p_structure_version_id	    IN NUMBER
  ,x_schedule_start_date           OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_schedule_finish_date          OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_schedule_as_of_date           OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_schedule_duration             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
)
IS
  CURSOR get_sch_dates_csr
  IS
  SELECT scheduled_start_date,
         scheduled_finish_date,
         last_update_date,
         pa_proj_elements_utils.convert_hr_to_days(duration)
  FROM PA_PROJ_ELEM_VER_SCHEDULE
  WHERE element_version_id = p_structure_version_id;

  l_scheduled_start_date      DATE;
  l_scheduled_finish_date     DATE;
  l_schedule_as_of_date       DATE;
  l_schedule_duration         NUMBER;

BEGIN
  OPEN get_sch_dates_csr;
  FETCH get_sch_dates_csr
  INTO l_scheduled_start_date,
       l_scheduled_finish_date,
       l_schedule_as_of_date,
       l_schedule_duration;
  IF get_sch_dates_csr%NOTFOUND then
    CLOSE get_sch_dates_csr;
     x_schedule_start_date := NULL;
     x_schedule_finish_date := NULL;
     x_schedule_as_of_date := NULL;
     x_schedule_duration := NULL;
    return;
  ELSE
    CLOSE get_sch_dates_csr;
     x_schedule_start_date := l_scheduled_start_date;
     x_schedule_finish_date := l_scheduled_finish_date;
     x_schedule_as_of_date := l_schedule_as_of_date;
     x_schedule_duration := l_schedule_duration;
  END IF;

EXCEPTION
   when OTHERS then
     x_schedule_start_date := NULL;
     x_schedule_finish_date := NULL;
     x_schedule_as_of_date := NULL;
     x_schedule_duration := NULL;
END GET_STRUCT_SCHEDULE_DATES;

-- API name		: Get_Project_Start_Date_Src
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_PROJECT_START_DATE_SRC
(  p_project_id                    IN NUMBER
) RETURN VARCHAR2
IS
   l_target_start_date   DATE;
   l_scheduled_start_date DATE;
   l_actual_start_date    DATE;

   CURSOR get_dates_csr
   IS
   SELECT target_start_date, scheduled_start_date, actual_start_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

BEGIN

   OPEN get_dates_csr;
   FETCH get_dates_csr INTO l_target_start_date, l_scheduled_start_date, l_actual_start_date;
   CLOSE get_dates_csr;

   IF l_actual_start_date IS NULL THEN
      IF l_scheduled_start_date IS NULL THEN
         return 'T';
      ELSE
         return 'S';
      END IF;
   ELSE
      return 'A';
   END IF;

EXCEPTION
   when OTHERS then
     return NULL;
END GET_PROJECT_START_DATE_SRC;



-- API name		: Get_Project_Finish_Date_Src
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_PROJECT_FINISH_DATE_SRC
(  p_project_id                    IN NUMBER
) RETURN VARCHAR2
IS
   l_target_finish_date   DATE;
   l_scheduled_finish_date DATE;
   l_actual_finish_date    DATE;

   CURSOR get_dates_csr
   IS
   SELECT target_finish_date, scheduled_finish_date, actual_finish_date
   FROM PA_PROJECTS_ALL
   WHERE project_id = p_project_id;

BEGIN

   OPEN get_dates_csr;
   FETCH get_dates_csr INTO l_target_finish_date, l_scheduled_finish_date, l_actual_finish_date;
   CLOSE get_dates_csr;

   IF l_actual_finish_date IS NULL THEN
      IF l_scheduled_finish_date IS NULL THEN
         return 'T';
      ELSE
         return 'S';
      END IF;
   ELSE
      return 'A';
   END IF;

EXCEPTION
   when OTHERS then
     return NULL;
END GET_PROJECT_FINISH_DATE_SRC;

-- API name             : chek_all_tsk_have_act_fin_dt
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id           IN NUMBER
-- Description          : This API returns 'N' if any of the tasks in the structure version does not have actual finish date.

FUNCTION chek_all_tsk_have_act_fin_dt
(  p_project_id                           IN NUMBER,
   p_parent_structure_version_id          IN NUMBER
) RETURN VARCHAR2 AS

 CURSOR cur_chk_act_fin_dt
 IS
  SELECT 'x'
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = a.proj_element_id
  AND   b.element_version_id = a.element_version_id
  AND a.actual_finish_date IS NULL
  ;
  l_dummy  VARCHAR2(1);
BEGIN
    OPEN cur_chk_act_fin_dt;
    FETCH cur_chk_act_fin_dt INTO l_dummy;
    IF cur_chk_act_fin_dt%FOUND
    THEN
       return 'N';
    ELSE
       return 'Y';
    END IF;

EXCEPTION
   when OTHERS then
     return NULL;
end chek_all_tsk_have_act_fin_dt;

-- API name             : chek_one_task_has_act_st_date
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id           IN NUMBER
-- Description          : This API checks and returns 'Y' if any of the task has actual start date.

FUNCTION chek_one_task_has_act_st_date
(  p_project_id                           IN NUMBER,
   p_parent_structure_version_id          IN NUMBER
) RETURN VARCHAR2 AS

CURSOR cur_chk_act_fin_dt
 IS
  SELECT 'x'
  FROM PA_PROJ_ELEM_VER_SCHEDULE a,
       PA_PROJ_ELEMENT_VERSIONS b
  WHERE b.parent_structure_version_id = p_parent_structure_version_id
  AND   b.project_id = p_project_id
  AND   b.proj_element_id = a.proj_element_id
  AND   b.element_version_id = a.element_version_id
  AND a.actual_start_date IS NOT NULL
  ;
  l_dummy  VARCHAR2(1);
BEGIN
    OPEN cur_chk_act_fin_dt;
    FETCH cur_chk_act_fin_dt INTO l_dummy;
    IF cur_chk_act_fin_dt%FOUND
    THEN
       return 'Y';
    ELSE
       return 'N';
    END IF;

EXCEPTION
   when OTHERS then
     return NULL;
end chek_one_task_has_act_st_date;

/*============Bug 6511907:PJR DATE VALIDATION ENHANCEMENT=======START=======*/

/* ===============================================
   Validates the Project Transaction start and end dates against
   Resource Assignment/Requirement Least and Most dates.
   x_start_date_status/x_end_date_status: V-->Valid, I-->Invalid.
   x_validate: W/Y/N --> Warning/Yes/No.
   ================================================ */

PROCEDURE Validate_Project_Dates(p_project_id IN NUMBER,
                                 p_start_date IN DATE,
				 p_end_date IN DATE,
				 x_validate OUT NOCOPY VARCHAR2,
				 x_start_date_status OUT NOCOPY VARCHAR2,
				 x_end_date_status   OUT NOCOPY VARCHAR2)

IS
	l_res_min_date          DATE;
	l_res_max_date          DATE;
	l_tsk_min_date          DATE; -- Added for bug6866666
	l_tsk_max_date          DATE; -- Added for bug6866666
	l_validate              DATE;

	CURSOR l_res_dt_minmax_csr (l_proj_id NUMBER)
	IS
	SELECT min(start_date), max(end_date)
	FROM   pa_project_assignments
	WHERE  project_id = l_proj_id
	AND    assignment_type IN ('OPEN_ASSIGNMENT', 'STAFFED_ASSIGNMENT');

    CURSOR l_tsk_dt_minmax_csr (l_proj_id NUMBER) -- Added for bug6866666
	IS
	SELECT min(start_date), max(completion_date)
	FROM   pa_tasks
	WHERE  project_id = l_proj_id;

BEGIN

   OPEN  l_res_dt_minmax_csr(p_project_id);
   FETCH l_res_dt_minmax_csr INTO l_res_min_date, l_res_max_date;
   CLOSE l_res_dt_minmax_csr;

   x_validate := FND_PROFILE.value('PA_VALIDATE_ASSIGN_DATES');
   x_start_date_status := 'V';
   x_end_date_status   := 'V';

   IF NVL(x_validate,'N') in ('Y','W') THEN
      IF p_start_date IS NOT NULL THEN
          IF p_start_date > l_res_min_date THEN
            x_start_date_status  := 'I';
          END IF;
      END IF;

      IF p_end_date IS NOT NULL THEN
          IF p_end_date < l_res_max_date THEN
            x_end_date_status    := 'I';
          END IF;
       END IF;
   END IF;

   -- Added for bug6866666 Start
   OPEN  l_tsk_dt_minmax_csr(p_project_id);
   FETCH l_tsk_dt_minmax_csr INTO l_tsk_min_date, l_tsk_max_date;
   CLOSE l_tsk_dt_minmax_csr;

   IF p_start_date IS NOT NULL THEN
       IF p_start_date > l_tsk_min_date THEN
          x_start_date_status  := 'J';
       END IF;
   END IF;

   IF p_end_date IS NOT NULL THEN
       IF p_end_date < l_tsk_max_date THEN
          x_end_date_status    := 'J';
       END IF;
   END IF;
   -- Added for bug6866666 End

EXCEPTION

   when OTHERS then
     return;

END Validate_Project_Dates;

/* ===============================================
   Bug 6860603: For work plan publish flow:
   Validates the Project Transaction start and end dates against
   Resource Assignment/Requirement Least and Most dates.
   x_start_date_status/x_end_date_status: V-->Valid, I-->Invalid.
   x_validate: W/Y/N --> Warning/Yes/No.
   ================================================ */

PROCEDURE WPP_Validate_Project_Dates
   (p_project_id IN NUMBER,
    p_start_date IN DATE,
	p_end_date IN DATE,
	p_alwd_start_date OUT NOCOPY DATE,
	p_alwd_end_date OUT NOCOPY DATE,
	p_res_min_date OUT NOCOPY DATE,
	p_res_max_date OUT NOCOPY DATE,
	x_validate OUT NOCOPY VARCHAR2,
	x_start_date_status OUT NOCOPY VARCHAR2,
	x_end_date_status   OUT NOCOPY VARCHAR2)

IS
	l_res_min_date          DATE;
	l_res_max_date          DATE;
	l_tsk_min_date          DATE; -- Added for bug6866666
	l_tsk_max_date          DATE; -- Added for bug6866666
	l_validate              DATE;
	l_structure_id          NUMBER;
    l_structure_ver_id      NUMBER;
    l_buffer                NUMBER;


	CURSOR l_res_dt_minmax_csr (l_proj_id NUMBER)
	IS
	SELECT min(start_date), max(end_date)
	FROM   pa_project_assignments
	WHERE  project_id = l_proj_id
	AND    assignment_type IN ('OPEN_ASSIGNMENT', 'STAFFED_ASSIGNMENT');

   CURSOR get_structure
   IS
   SELECT a.proj_element_id
   FROM pa_proj_elements a,
        pa_proj_structure_types b,
        pa_structure_types c
   WHERE a.proj_element_id = b.proj_element_id
   AND a.object_type = 'PA_STRUCTURES'
   AND a.project_id = p_project_id
   AND b.structure_type_id = c.structure_type_id
   AND c.structure_type = 'WORKPLAN';

   CURSOR get_latest_struct_ver(c_structure_id NUMBER)
   IS
   select element_version_id
   from pa_proj_elem_ver_structure
   where project_id = p_project_id
   and proj_element_id = c_structure_id
   and status_code = 'STRUCTURE_PUBLISHED'
   and latest_eff_published_flag = 'Y';

   CURSOR get_work_struct_ver(c_structure_id NUMBER)
   IS
   SELECT element_version_id
   from pa_proj_elem_ver_structure
   where project_id = p_project_id
   and proj_element_id = c_structure_id
   and status_code <> 'STRUCTURE_PUBLISHED';

   CURSOR get_buffer(c_structure_id NUMBER) IS
     SELECT NVL(TXN_DATE_SYNC_BUF_DAYS,0)
     FROM PA_PROJ_WORKPLAN_ATTR
     WHERE PROJ_ELEMENT_ID = c_structure_id;

BEGIN

/* Getting the Buffer Period*/

  OPEN get_structure;
   FETCH get_structure into l_structure_id;
   CLOSE get_structure;

   IF ('Y' = PA_PROJECT_STRUCTURE_UTILS.CHECK_PUBLISHED_VER_EXISTS(
                              p_project_id, l_structure_id)) THEN
     --Get latest published version id
     OPEN get_latest_struct_ver(l_structure_id);
     FETCH get_latest_struct_ver into l_structure_ver_id;
     CLOSE get_latest_struct_ver;
   ELSE
     --Get working version id
     --this should only return 1 row because this is only called when
     --  when structure is of both workplan and financial type
     OPEN get_work_struct_ver(l_structure_id);
     FETCH get_work_struct_ver into l_structure_ver_id;
     CLOSE get_work_struct_ver;
   END IF;

   --Get buffer from workplan table
   OPEN get_buffer(l_structure_id);
   FETCH get_buffer into l_buffer;
   CLOSE get_buffer;




/* Validation of resource assignment dates against project transaction dates*/

   OPEN  l_res_dt_minmax_csr(p_project_id);
   FETCH l_res_dt_minmax_csr INTO l_res_min_date, l_res_max_date;
   CLOSE l_res_dt_minmax_csr;

   p_alwd_start_date := l_res_min_date+l_buffer;
   p_alwd_end_date := l_res_max_date-l_buffer;
   p_res_min_date:=l_res_min_date;
   p_res_max_date:=l_res_max_date;



   x_validate := FND_PROFILE.value('PA_VALIDATE_ASSIGN_DATES');
   x_start_date_status := 'V';
   x_end_date_status   := 'V';

   IF NVL(x_validate,'N') in ('Y','W') THEN
      IF p_start_date IS NOT NULL THEN
          IF p_start_date > l_res_min_date THEN
            x_start_date_status  := 'I';
          END IF;
      END IF;

      IF p_end_date IS NOT NULL THEN
          IF p_end_date < l_res_max_date THEN
            x_end_date_status    := 'I';
          END IF;
       END IF;
   END IF;



EXCEPTION

   when OTHERS then
     return;

END WPP_Validate_Project_Dates;


 /* =============================================
    Validates the Resource Req/Assign start and end dates
    against Project Transaction Start and End dates.
    x_start_date_status/ x_end_date_status:V-->Valid, I-->Invalid.
    x_validate: W/Y/N --> Warning/Yes/No.
    ============================================= */

PROCEDURE Validate_Resource_Dates(p_project_id IN NUMBER,
                                  p_start_date IN OUT NOCOPY DATE,
				                  p_end_date IN OUT NOCOPY DATE,
				                  x_validate OUT NOCOPY VARCHAR2,
				                  x_start_date_status OUT NOCOPY VARCHAR2,
				                  x_end_date_status   OUT NOCOPY VARCHAR2)

IS
	l_prj_min_date          DATE;
	l_prj_max_date          DATE;
	l_validate              DATE;

	CURSOR l_prj_dt_minmax_csr (l_proj_id NUMBER)
	IS
	SELECT start_date, completion_date
	FROM   pa_projects_all
	WHERE  project_id = l_proj_id ;

BEGIN



   OPEN  l_prj_dt_minmax_csr(p_project_id);
   FETCH l_prj_dt_minmax_csr INTO l_prj_min_date, l_prj_max_date;
   CLOSE l_prj_dt_minmax_csr;

   x_validate := FND_PROFILE.value('PA_VALIDATE_ASSIGN_DATES');
   x_start_date_status := 'V';
   x_end_date_status   := 'V';

    IF NVL(x_validate,'N') in ('Y','W') THEN

        IF p_start_date IS NOT NULL THEN
          IF p_start_date < l_prj_min_date THEN
            x_start_date_status  := 'I';
          END IF;
        END IF;

        IF p_end_date IS NOT NULL THEN
          IF p_end_date > l_prj_max_date THEN
            x_end_date_status    := 'I';
          END IF;
        END IF;

    END IF;

EXCEPTION

   when OTHERS then
     return;

END;


/**
@author NISINHA
Procedure VALIDATE_ASSIGNMENT_DATES_BULK
Description : This procedure is used to validate the dates of Assignments when updated from the Updatable Scheduled People Page
*/

PROCEDURE VALIDATE_ASSIGNMENT_DATES_BULK
                                 (p_project_id_tbl        IN                   SYSTEM.PA_NUM_TBL_TYPE,
                                  p_start_date_tbl        IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
				  p_end_date_tbl          IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
				  x_validate_tbl          IN OUT NOCOPY        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
				  x_start_date_status_tbl OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
				  x_end_date_status_tbl   OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
				  x_msg_data_tbl          OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE)

IS
         	l_prj_min_date          DATE;
        	l_prj_max_date          DATE;
        	l_start_date            Date;
        	l_completion_date       Date;

        	CURSOR l_prj_dt_minmax_csr (l_proj_id NUMBER)
        	IS
	        SELECT start_date, completion_date
	        FROM   pa_projects_all
	        WHERE  project_id = l_proj_id ;

        l_validate VARCHAR2 (2000);
        l_validate_tbl            SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;
        l_start_date_status_tbl   SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;
        l_end_date_status_tbl     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;
        l_msg_data_tbl            SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;

        l_valid_assign_start_flag  VARCHAR2(1) := 'Y';

BEGIN


     fnd_msg_pub.initialize;
     l_validate := FND_PROFILE.Value('PA_VALIDATE_ASSIGN_DATES');   -- This profile option is for only validating the assignment dates against project dates

     FOR  i IN  p_project_id_tbl.first .. p_project_id_tbl.last LOOP

          l_validate_tbl(i)          := NULL ;
          l_start_date_status_tbl(i) := NULL ;
          l_end_date_status_tbl(i)   := NULL ;
          l_msg_data_tbl(i)          := NULL ;



          IF  p_project_id_tbl(i) IS  NOT  NULL  THEN

                OPEN  l_prj_dt_minmax_csr(p_project_id_tbl(i));
                FETCH l_prj_dt_minmax_csr INTO l_prj_min_date, l_prj_max_date;
                CLOSE l_prj_dt_minmax_csr;


                l_validate_tbl(i) := l_validate;
                l_start_date_status_tbl(i) := 'V';
                l_end_date_status_tbl(i)   := 'V';

                                   -- This new condition sets the status as G indicating that Start date is greater than End date.
                   IF p_start_date_tbl(i) IS NOT NULL AND p_end_date_tbl(i) IS NOT NULL THEN
                       IF p_start_date_tbl(i) > p_end_date_tbl(i) THEN

                                  l_start_date_status_tbl(i)  := 'G';
                                  l_msg_data_tbl(i) := 'PA_INVALID_START_DATE';
                                  PA_UTILS.Add_Message( p_app_short_name => 'PA',
			                            p_msg_name       => 'PA_INVALID_START_DATE');


                       END IF;
                   END IF;

               IF NVL(l_validate_tbl(i),'N') in ('Y','W') THEN
                   IF p_start_date_tbl(i) IS NOT NULL THEN
                       IF p_start_date_tbl(i) < l_prj_min_date THEN
                                  l_start_date_status_tbl(i)  := 'I';


                       END IF;
                   END IF;

                   IF p_end_date_tbl(i) IS NOT NULL THEN
                       IF p_end_date_tbl(i) > l_prj_max_date THEN
                                  l_end_date_status_tbl(i)    := 'I';


                       END IF;
                   END IF;



                   l_valid_assign_start_flag := PA_PROJECT_DATES_UTILS.IS_VALID_ASSIGN_START_DATE
                                                           ( p_project_id        => p_project_id_tbl(i),
                                                             p_assign_start_date => p_start_date_tbl(i) ) ;
                   IF ( l_valid_assign_start_flag <> 'Y' ) THEN
                                  l_start_date_status_tbl(i)  := 'I';
                   END IF;

               END IF;

	             IF  l_validate_tbl(i) = 'Y' THEN
	                 SELECT  start_date, completion_date
	                 INTO  l_start_date, l_completion_date
	                 FROM   pa_projects_prm_v proj
	                 WHERE  project_id = p_project_id_tbl(i);

	                 IF  (l_start_date_status_tbl(i) = 'I' AND  l_start_date IS  NOT  NULL ) THEN
	                      l_msg_data_tbl(i) := 'PA_PJR_DATE_START_ERROR';
		      	            PA_UTILS.Add_Message( p_app_short_name => 'PA',
			                            p_msg_name       => 'PA_PJR_DATE_START_ERROR',
                                  p_token1         => 'PROJ_TXN_START_DATE',
			                            p_value1         => ' ');

		               END  IF ;

   	               IF  (l_end_date_status_tbl(i) = 'I' AND  l_completion_date IS  NOT  NULL ) THEN
	                      l_msg_data_tbl(i) := 'PA_PJR_DATE_FINISH_ERROR';
		     	              PA_UTILS.Add_Message( p_app_short_name => 'PA',
			                            p_msg_name       => 'PA_PJR_DATE_FINISH_ERROR',
                                  p_token1         => 'PROJ_TXN_END_DATE',
		                            	p_value1         => ' ');

	                 END  IF ;


               ELSIF  l_validate_tbl(i) = 'W' THEN
	                IF  (l_start_date_status_tbl(i) = 'I') THEN
	                      l_msg_data_tbl(i) := 'StartDateWarning';
                  END  IF ;

	                IF  (l_end_date_status_tbl(i) = 'I') THEN
	                      l_msg_data_tbl(i) := 'EndDateWarning';
	                END  IF ;
	             END  IF ;

          END  IF ;  -- p_project_id_tbl(i) is not null

     END  LOOP ;

     x_validate_tbl          := l_validate_tbl;
     x_start_date_status_tbl := l_start_date_status_tbl;
     x_end_date_status_tbl   := l_end_date_status_tbl;
     x_msg_data_tbl          := l_msg_data_tbl;


EXCEPTION

     WHEN  OTHERS THEN

        RAISE ;

END VALIDATE_ASSIGNMENT_DATES_BULK;


/* END OF PROCEDURE VALIDATE_ASSIGNMENT_DATES_BULK */

/*   Bug 7693634 start */

PROCEDURE Validate_Resource_Dates_Bulk
                                 (p_project_id_tbl        IN                   SYSTEM.PA_NUM_TBL_TYPE,
                                  p_start_date_tbl        IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
				  p_end_date_tbl          IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
				  x_validate_tbl          IN OUT NOCOPY        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
				  x_start_date_status_tbl OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
				  x_end_date_status_tbl   OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
				  x_msg_data_tbl          OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE)

IS
	l_prj_min_date          DATE;
	l_prj_max_date          DATE;
	l_start_date            Date;
	l_completion_date       Date;

	CURSOR l_prj_dt_minmax_csr (l_proj_id NUMBER)
	IS
	SELECT start_date, completion_date
	FROM   pa_projects_all
	WHERE  project_id = l_proj_id ;

l_validate varchar2(2000);
l_validate_tbl            SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;
l_start_date_status_tbl   SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;
l_end_date_status_tbl     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;
l_msg_data_tbl            SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := x_validate_tbl;

l_valid_assign_start_flag  VARCHAR2(1) := 'Y';

BEGIN


fnd_msg_pub.initialize;  --  bug 8233045
l_validate := FND_PROFILE.value('PA_VALIDATE_ASSIGN_DATES');

for i in p_project_id_tbl.first .. p_project_id_tbl.last loop
l_validate_tbl(i)          := null;
l_start_date_status_tbl(i) := null;
l_end_date_status_tbl(i)   := null;
l_msg_data_tbl(i)          := null;



 if p_project_id_tbl(i) is not null THEN

   OPEN  l_prj_dt_minmax_csr(p_project_id_tbl(i));
   FETCH l_prj_dt_minmax_csr INTO l_prj_min_date, l_prj_max_date;
   CLOSE l_prj_dt_minmax_csr;


   l_validate_tbl(i) := l_validate;
   l_start_date_status_tbl(i) := 'V';
   l_end_date_status_tbl(i)   := 'V';

    IF NVL(l_validate_tbl(i),'N') in ('Y','W') THEN

        IF p_start_date_tbl(i) IS NOT NULL THEN
          IF p_start_date_tbl(i) < l_prj_min_date THEN
            l_start_date_status_tbl(i)  := 'I';
          END IF;
        END IF;

        IF p_end_date_tbl(i) IS NOT NULL THEN
          IF p_end_date_tbl(i) > l_prj_max_date THEN
            l_end_date_status_tbl(i)    := 'I';
          END IF;
        END IF;

       l_valid_assign_start_flag := PA_PROJECT_DATES_UTILS.IS_VALID_ASSIGN_START_DATE
                                 ( p_project_id        => p_project_id_tbl(i),
                                       p_assign_start_date => p_start_date_tbl(i) ) ;

       IF ( l_valid_assign_start_flag <> 'Y' ) THEN
          l_start_date_status_tbl(i)  := 'I';
       END IF;

    END IF;

	if l_validate_tbl(i) = 'Y' then


	     select start_date, completion_date
	     into l_start_date, l_completion_date
	     from pa_projects_prm_v proj
	     where project_id = p_project_id_tbl(i);

	     if (l_start_date_status_tbl(i) = 'I' and l_start_date is not null) then
	        l_msg_data_tbl(i) := 'PA_PJR_DATE_START_ERROR';

			PA_UTILS.Add_Message( p_app_short_name => 'PA',
			p_msg_name       => 'PA_PJR_DATE_START_ERROR',
                        p_token1         => 'PROJ_TXN_START_DATE',
			p_value1         => ' ');
		end if;

   	     if (l_end_date_status_tbl(i) = 'I' and l_completion_date is not null) then
	        l_msg_data_tbl(i) := 'PA_PJR_DATE_FINISH_ERROR';

			PA_UTILS.Add_Message( p_app_short_name => 'PA',
			p_msg_name       => 'PA_PJR_DATE_FINISH_ERROR',
                        p_token1         => 'PROJ_TXN_END_DATE',
			p_value1         => ' ');
	     end if;

    elsif l_validate_tbl(i) = 'W' then


	     if (l_start_date_status_tbl(i) = 'I') then
	        l_msg_data_tbl(i) := 'StartDateWarning';


	     end if;

	     if (l_end_date_status_tbl(i) = 'I') then
	        l_msg_data_tbl(i) := 'EndDateWarning';

	     end if;


	end if;

 end if;  -- p_project_id_tbl(i) is not null

end loop;

x_validate_tbl          := l_validate_tbl;
x_start_date_status_tbl := l_start_date_status_tbl;
x_end_date_status_tbl   := l_end_date_status_tbl;
x_msg_data_tbl          := l_msg_data_tbl;


EXCEPTION

   when OTHERS THEN

     raise;

END;

/*  Bug 7693634 end */


 /* =============================================
    Validates the Template Teams start and end dates
    against Project Transaction Start and End dates.
    x_start_date_status/ x_end_date_status:V-->Valid, I-->Invalid.
    x_validate: W/Y/N --> Warning/Yes/No.
    ============================================= */


PROCEDURE Validate_Template_Team_Dates
                (p_project_id IN NUMBER,
                 p_template_id IN NUMBER,
				 x_validate OUT NOCOPY VARCHAR2,
				 x_start_date_status OUT NOCOPY VARCHAR2,
				 x_end_date_status   OUT NOCOPY VARCHAR2)

IS
	l_template_min_date        DATE;
	l_template_max_date        DATE;
	l_validate                 Varchar2(10);

   	l_prj_min_date             DATE;
	l_prj_max_date             DATE;

	/*Fix for Bug 6856082 starts*/
	l_team_start_date          DATE;
	l_number_of_days           NUMBER;
	/*Fix for Bug 6856082 ends*/

	CURSOR l_prj_dt_minmax_csr (l_proj_id NUMBER)
	IS
	SELECT start_date, completion_date
	FROM   pa_projects_all
	WHERE  project_id = l_proj_id ;


    CURSOR l_templ_dt_minmax_csr (l_template_id NUMBER)
    IS
	SELECT min(start_date), max(end_date)
	FROM   pa_project_assignments
	WHERE  assignment_template_id = l_template_id
        AND project_id IS NULL ; -- added this for bug 7638712

	/*Fix for Bug 6856082 starts*/
	CURSOR get_team_start_date(l_template_id  NUMBER) IS
	SELECT team_start_date
	FROM pa_team_templates
	WHERE team_template_id = l_template_id;
	/*Fix for Bug 6856082 ends*/
BEGIN

   OPEN  l_prj_dt_minmax_csr(p_project_id);
   FETCH l_prj_dt_minmax_csr INTO l_prj_min_date, l_prj_max_date;
   CLOSE l_prj_dt_minmax_csr;

   OPEN  l_templ_dt_minmax_csr(p_template_id);
   FETCH l_templ_dt_minmax_csr INTO l_template_min_date, l_template_max_date;
   CLOSE l_templ_dt_minmax_csr;

   /*Fix for Bug 6856082 starts*/
   OPEN get_team_start_date(p_template_id);
   FETCH get_team_start_date INTO l_team_start_date;
   CLOSE get_team_start_date ;
	/*Fix for Bug 6856082 ends*/

   l_validate := FND_PROFILE.value('PA_VALIDATE_ASSIGN_DATES');
   --l_validate := 'Y';
   x_validate := l_validate;
   x_start_date_status := 'V';
   x_end_date_status   := 'V';

   /*Fix for Bug 6856082 starts*/
   /* Recalc the start and end dates on the template */
	l_number_of_days := l_prj_min_date - l_team_start_date;

           --determine the requirement's start and end dates by adding l_number_of_days to
           --the template requirement's start and end dates.
	l_template_min_date := l_template_min_date + l_number_of_days ;
	l_template_max_date := l_template_max_date + l_number_of_days ;

	/*Fix for Bug 6856082 ends*/

    IF NVL(l_validate,'N') in ('Y','W') THEN

         IF l_template_min_date IS NOT NULL THEN
          IF l_template_min_date < l_prj_min_date THEN
            x_start_date_status  := 'I';
          END IF;
         END IF;

         IF l_template_max_date IS NOT NULL THEN
          IF l_template_max_date > l_prj_max_date THEN
            x_end_date_status    := 'I';
          END IF;
         END IF;



     END IF;

EXCEPTION

   when OTHERS then
     return;

END;

/*============Bug 6511907:PJR DATE VALIDATION ENHANCEMENT=======END=======*/
END PA_PROJECT_DATES_UTILS;

/
