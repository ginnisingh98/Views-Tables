--------------------------------------------------------
--  DDL for Package Body AHL_VWP_TIMES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VWP_TIMES_PVT" AS
 /* $Header: AHLVTMSB.pls 120.3.12010000.5 2010/01/27 09:47:40 skpathak ship $ */

-----------------------------------------------------------------
--   Define Global CONSTANTS                                   --
-----------------------------------------------------------------
G_APP_NAME            CONSTANT VARCHAR2(3) := 'AHL';
G_PKG_NAME            CONSTANT VARCHAR2(30) := 'AHL_VWP_TIMES_PVT';

G_SECS_IN_DAY         CONSTANT NUMBER := 86400; --Seconds in a day
G_HOLIDAY_TYPE        CONSTANT NUMBER := 2;

-- Package level Global Variables used in time calculations
G_CURRENT_DEPT_ID     NUMBER := NULL;  -- Cached department id, so to know whether to reload

G_CAL_START           DATE   := NULL;  -- Calendar start date for shift data
G_CAL_END             DATE   := NULL;  -- Calendar end date for shift data
G_SHIFT_START         NUMBER := NULL;  -- Shift start in .decimal value of days
G_SHIFT_END           NUMBER := NULL;  -- Shift end in .decimal value of days
G_DAYS_ON             NUMBER := NULL;  -- Number of Days on
G_DAYS_OFF            NUMBER := NULL;  -- Number of Days off
G_VISIT_START_DATE    DATE   := NULL;  -- The visit start date
G_VISIT_DEPT_ID       NUMBER := NULL;  -- The visit department
G_VISIT_STATUS        VARCHAR2(30):= NULL;  --The visit status
G_RESET_SYSDATE_FLAG  VARCHAR2(1);

/*Added by sowsubra*/
G_ASSOC_TYPE_ROUTE      CONSTANT VARCHAR2(30) := 'ROUTE';
G_ASSOC_TYPE_OPERATION  CONSTANT VARCHAR2(30) := 'OPERATION';

-- Table type for all the Dates while deriving visit and task times
TYPE Dates_Tbl_Type IS TABLE OF DATE
    INDEX BY BINARY_INTEGER;
TYPE Number_Tbl_Type IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

G_EXCEPTION_DATES_TBL Dates_Tbl_Type; -- Stores the holidays for dept
G_STAGES_TBL  Number_Tbl_Type;        -- Stores the stage offsets for visit
------------------------------------
-- Common constants and variables --
------------------------------------
l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;
-----------------------------------------------------------------------
/*procedure adbug(p_msg_txt in varchar2 , p_message in date)
is
begin
    if (true) then
     dbms_output.put_line(p_msg_txt || to_char(p_message,'dd:mm:yyyy hh24:mi:ss'));
    end if;
end adbug;

procedure adbug(p_message in varchar2)
is
begin
    if (true) then
     dbms_output.put_line(p_message);
   end if;
end adbug;
*/
--------------------------------------------------------------------
-- Define local procedures signature                              --
--------------------------------------------------------------------
--------------------------------------------------------------------
--Initializes the global variables based on the department id
--------------------------------------------------------------------
PROCEDURE Init_Shift_Data(p_department_id IN number);

--------------------------------------------------------------------
--Internal recursion code for setting task times
--------------------------------------------------------------------
-- SKPATHAK :: Bug 8343599 :: 14-APR-2009
-- Added the optional in param p_task_start_date
PROCEDURE Adjust_Task_Times_Internal(p_task_id         IN NUMBER,
                                     p_task_start_date IN DATE default NULL);

--------------------------------------------------------------------
-- Define local functions signature                               --
--------------------------------------------------------------------

----------------------------------------------------------------------
-- Gets the duration of a Route from its timespan column
---------------------------------------------------------------------
-- Determines if a specific date is a holiday
FUNCTION Is_Dept_Holiday(l_curr_date DATE) RETURN BOOLEAN;

----------------------------------------------------------
-- Derive the shift start date based on shift timing.
------------------------------------------------------------
FUNCTION get_shift_start_date(p_date IN DATE)
RETURN DATE
IS
BEGIN
 --If it's an overnight shift and time is before shift ends on the same day,
  --the shift started a day earlier
  IF (G_SHIFT_END < G_SHIFT_START AND
     p_date < trunc(p_date)+G_SHIFT_END) THEN
        RETURN TRUNC(p_date) -1;
  ELSE
        RETURN TRUNC(p_date);
  END IF;
END get_shift_start_date;
--------------------------------------------------------------------
-- Define procedures body                                   --
--------------------------------------------------------------------
--------------------------------------------------------------------
--  Function name    : Get_Visit_Start_Time
--  Type             : Public
--  Purpose          : Fetches Master Work Order Actual Start Date if the
--                     Visit is Closed, else RETURNs the Visit Start Date.
--
--  Parameters  :
--        p_visit_id   Visit ID to fetch the data
--
--  Version :
--     17 September, 2007   RNAHATA  Initial Version - 1.0
--
--  Added for Bug 6430038
--------------------------------------------------------------------
function Get_Visit_Start_Time(
     p_visit_id   IN   NUMBER
 )
RETURN DATE
IS
--
-- To get the Start Date and Status of the Visit
CURSOR c_visit_csr (c_visit_id IN NUMBER) IS
 SELECT START_DATE_TIME, STATUS_CODE
 FROM AHL_VISITS_B
 WHERE VISIT_ID = c_visit_id;

-- Actual Visit Start Date
CURSOR get_actual_start_date_csr(c_visit_id IN NUMBER) IS
 SELECT ACTUAL_START_DATE
 FROM AHL_WORKORDERS
 WHERE VISIT_ID = c_visit_id
  AND VISIT_TASK_ID IS NULL
  AND MASTER_WORKORDER_FLAG = 'Y';

--
l_actual_start_date DATE := null;
c_visit_rec c_visit_csr%ROWTYPE;
L_API_NAME    CONSTANT VARCHAR2(30)  := 'Get_Visit_Start_Time';
L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
--
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL function. Visit Id = ' || p_visit_id);
   END IF;

   OPEN c_visit_csr(p_visit_id);
   FETCH c_visit_csr INTO c_visit_rec;
   CLOSE c_visit_csr;

   -- Closed
   IF c_visit_rec.STATUS_CODE ='CLOSED' THEN
      OPEN get_actual_start_date_csr (p_visit_id);
      FETCH get_actual_start_date_csr INTO l_actual_start_date;
      CLOSE get_actual_start_date_csr;
      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL function. Visit Start Date = ' || l_actual_start_date);
      END IF;
      RETURN l_actual_start_date;

   -- Planning/Released/Partially Released/Cancelled
   ELSE
      IF (l_log_procedure >= l_log_current_level) THEN
         fnd_log.string(l_log_procedure,
                        L_DEBUG_KEY ||'.end',
                        'At the end of PL SQL function. Visit Start Date = ' || c_visit_rec.START_DATE_TIME);
      END IF;
      RETURN c_visit_rec.START_DATE_TIME;
   END IF;

END Get_Visit_Start_Time;

--------------------------------------------------------------------
-- Define procedures body
--------------------------------------------------------------------
--------------------------------------------------------------------
--  Function name    : Get_Visit_End_Time
--  Type             : Public
--  Purpose          : To RETURN the End Date for the visit.
--                     For Unit Affectivity API it returns
--                      Master Work Order Actual End Date when visit is Closed
--                      and NVL(Visit Close Date,Max(Task End Times))
--                     For VWP it returns
--                      Max(Task End Times) when Visit is in Planning
--                      Max(Max(WO Released Job Completion Date),Max(Task End Times))
--
--  Parameters  :
--       p_visit_id    Visit ID to fetch the data
--       p_use_actual  This is a boolean value equal to FND_API.G_FALSE
--                     when the call is made from UA or FND_API.G_TRUE
--                     the call is made internally from VWP.
--
--------------------------------------------------------------------
FUNCTION Get_Visit_End_Time(
      p_visit_id     IN   NUMBER,
      p_use_actuals  IN   VARCHAR2 := FND_API.G_TRUE
  )
RETURN DATE
IS
--
-- To find visit related information
CURSOR c_visit_csr (c_id IN NUMBER) IS
SELECT CLOSE_DATE_TIME, START_DATE_TIME, DEPARTMENT_ID, status_code
FROM AHL_VISITS_B
WHERE VISIT_ID = c_id;
--
CURSOR get_end_date_csr(c_visit_id IN NUMBER) IS
 SELECT MAX(end_date_time)
 FROM AHL_VISIT_TASKS_B
 WHERE VISIT_ID = c_visit_id
 AND STATUS_CODE NOT IN ('RELEASED','DELETED'); -- Modified by rnahata for Bug 6369279
 -- AND STATUS_CODE <> 'RELEASED';
--
-- Added by yazhou Sept-21-2004
CURSOR get_wo_end_date_csr(c_visit_id IN NUMBER) IS
    SELECT MAX(WIP.SCHEDULED_COMPLETION_DATE)
    FROM AHL_WORKORDERS WO,
         WIP_DISCRETE_JOBS WIP,
         AHL_VISIT_TASKS_B VT
    WHERE vt.status_code = 'RELEASED'
    AND vt.VISIT_ID = c_visit_id
    AND vt.visit_task_id = wo.VISIT_TASK_ID
--  AND wo.MASTER_WORKORDER_FLAG = 'N'
    AND WIP.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
    AND wo.status_code not in ('22','7');

-- Begin changes by rnahata for Bug 6430038
-- Actual Visit End Date
CURSOR get_actual_end_date_csr(c_visit_id IN NUMBER) IS
 SELECT ACTUAL_END_DATE
 FROM AHL_WORKORDERS
 WHERE VISIT_ID = c_visit_id
  AND VISIT_TASK_ID IS NULL
  AND MASTER_WORKORDER_FLAG = 'Y';
--
CURSOR get_valid_visit_tasks_csr(c_visit_id IN NUMBER) IS
 SELECT count(*)
 FROM AHL_VISIT_TASKS_B
 WHERE VISIT_ID = c_visit_id
 AND STATUS_CODE <>'DELETED';
-- End changes by rnahata for Bug 6430038

  l_end_date    DATE := null; --The visit end date
  l_wo_end_date DATE := null; --The last WO end date
  c_visit_rec c_visit_csr%ROWTYPE;
  l_cnt         NUMBER := 0;
  L_API_NAME    CONSTANT VARCHAR2(30)  := 'Get_Visit_End_Time';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
--
BEGIN

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL function. Visit Id = ' || p_visit_id ||
                     ', p_use_actuals = ' || p_use_actuals);
   END IF;

   --Fetch the visit information
   OPEN c_visit_csr(p_visit_id);
   FETCH c_visit_csr INTO c_visit_rec;
   CLOSE c_visit_csr;

   IF (c_visit_rec.START_DATE_TIME IS NOT NULL
       AND c_visit_rec.START_DATE_TIME <> Fnd_Api.G_MISS_DATE
       AND c_visit_rec.DEPARTMENT_ID IS NOT NULL
       AND c_visit_rec.DEPARTMENT_ID <> Fnd_Api.G_MISS_NUM) THEN

      OPEN get_end_date_csr (p_visit_id);
      FETCH get_end_date_csr INTO l_end_date;
      CLOSE get_end_date_csr;
   END IF;

   IF ((p_use_actuals IS NOT NULL AND    --p_use_actuals is not null and
      NOT(FND_API.TO_BOOLEAN(p_use_actuals)))) THEN --p_use_actuals is false
      -- Begin changes by rnahata for Bug 6430038

      -- Closed Visit
      IF c_visit_rec.STATUS_CODE ='CLOSED' THEN
         OPEN get_actual_end_date_csr (p_visit_id);
         FETCH get_actual_end_date_csr INTO l_end_date;
         CLOSE get_actual_end_date_csr;
         RETURN l_end_date;

      -- Planning/Released/Partially Released/Cancelled Visit
      ELSE
         IF (c_visit_rec.CLOSE_DATE_TIME IS NOT NULL) THEN
            RETURN c_visit_rec.CLOSE_DATE_TIME;
         ELSE
            OPEN get_valid_visit_tasks_csr (p_visit_id);
            FETCH get_valid_visit_tasks_csr INTO l_cnt;
            CLOSE get_valid_visit_tasks_csr;

            IF ( l_cnt > 0 ) THEN
              RETURN l_end_date;
            ELSE
              RETURN c_visit_rec.START_DATE_TIME;
            END IF;
         END IF;
      END IF;
      -- End changes by rnahata for Bug 6430038
   END IF;

   -- Added by yazhou Sept-21-2004
   IF c_visit_rec.status_code ='PLANNING' THEN
      RETURN l_end_date;
   ELSE  -- Released/Partially Released/Closed/Cancelled

      OPEN get_wo_end_date_csr (p_visit_id);
      FETCH get_wo_end_date_csr INTO l_wo_end_date;
      CLOSE get_wo_end_date_csr;

      IF l_end_date IS NULL THEN
         RETURN  l_wo_end_date;
      END IF;

      IF l_wo_end_date IS NULL THEN
          RETURN  l_end_date;
      END IF;

      IF l_wo_end_date > l_end_date THEN
         RETURN l_wo_end_date;
      ELSE
         RETURN l_end_date;
      END IF;

   END IF;
END Get_Visit_End_Time;

-------------------------------------------------------------------
--  Procedure name    : Calculate_Task_Times
--  Type              : Private
--  Function          : Derive the start and end times/hours of tasks
--                      and the end_date_time of the visit
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status       OUT     VARCHAR2     Required
--      x_msg_count           OUT     NUMBER       Required
--      x_msg_data            OUT     VARCHAR2     Required
--
--  Calculate_Task_Times Parameters:
--      p_visit_id            IN      NUMBER       Required
--         The id of the visit whose associated tasks' start and end times or hours
--         need to be derived
--  Version :
--      Initial Version   1.0
--
-- ASSUMPTIONS:
--   A Task can appear only once for a given visit (ahl_visit_tasks_b)
--   A Department can have only one shift (ahl_department_shifts)
--   Shift_Num is unique in bom_shift_times
--
-------------------------------------------------------------------
PROCEDURE Calculate_Task_Times
(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit           IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level IN         NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_visit_id         IN         NUMBER)
IS
--
--Fetch basic visit data
CURSOR get_visit_data_csr(p_visit_id IN NUMBER) IS
SELECT v.start_date_time, v.department_id
FROM AHL_VISITS_B v, AHL_DEPARTMENT_SHIFTS shifts
WHERE v.department_id = shifts.department_id
AND v.visit_id = p_visit_id;
--
--Cursor for deriving all the stage start hours
CURSOR get_stage_data_csr(P_VISIT_ID IN number)
IS
SELECT stage_id, duration
--, sum(duration) over(order by stage_num) CUMUL_DURATION
from ahl_vwp_stages_vl
where visit_id = p_visit_id
order by stage_num;
-----------
--Fetch the tasks for the visit in tech dependency sorted sequence
CURSOR get_task_data_csr(p_visit_id IN NUMBER)
IS
SELECT dtl.visit_task_id,
       max(dtl.task_level) task_level,
       max(NVL(vtsk.start_from_hour,0)) start_from_hour,
       /*sowsubra*/
       max(NVL(vtsk.duration, NVL(Get_task_duration(vtsk.quantity, routes.route_id), 0))) duration,
       max(vtsk.stage_id) stage_id,
       max(vtsk.department_id) department_id
FROM AHL_VISIT_TASKS_B vtsk,
         ahl_routes_app_v routes, ahl_mr_routes_app_v mr,
   (SELECT visit_task_id, level+1 task_level
     FROM ahl_task_links tl
     WHERE visit_task_id in (
       SELECT visit_task_id from ahl_visit_tasks_b vt
         where (VT.STATUS_CODE IS NULL OR (VT.STATUS_CODE  <> 'DELETED' AND VT.STATUS_CODE  <> 'RELEASED')))
     START WITH tl.parent_task_id in
      (SELECT visit_task_id from ahl_visit_tasks_b vt
         where  vt.visit_id=p_visit_id
           AND  vt.visit_task_id not in (SELECT visit_task_id from ahl_task_links)
           and (VT.STATUS_CODE IS NULL OR (VT.STATUS_CODE  <> 'DELETED' AND VT.STATUS_CODE  <> 'RELEASED'))
           AND vt.TASK_TYPE_CODE <> 'SUMMARY')
     CONNECT BY tl.parent_task_id = prior tl.visit_task_id
     union
     SELECT vt.visit_task_id, 1 task_level
     FROM ahl_visit_tasks_b vt
     WHERE vt.visit_task_id not in (SELECT visit_task_id from ahl_task_links)
     AND vt.visit_id =p_visit_id
     AND (VT.STATUS_CODE IS NULL OR (VT.STATUS_CODE  <> 'DELETED' AND VT.STATUS_CODE  <> 'RELEASED'))
     AND vt.TASK_TYPE_CODE <> 'SUMMARY'
 ) dtl
 WHERE dtl.visit_task_id = vtsk.visit_task_id
   AND routes.route_id (+)= mr.route_id
   AND mr.mr_route_id (+) = vtsk.mr_route_id
 group by dtl.visit_task_id
 order by task_level;

--
--This cursor uses the technical dependencies and finds the parent task
-- that finishes last.
CURSOR get_tech_dependency_csr(p_task_id IN NUMBER) IS
SELECT max(vt.end_date_time)
FROM AHL_VISIT_TASKS_B vt, AHL_TASK_LINKS tl
WHERE vt.visit_task_id = tl.parent_task_id
AND tl.visit_task_id = p_task_id;
--

--Cursor for deriving all the tasks in production
CURSOR get_wo_data_csr(P_VISIT_ID IN number)
IS
    SELECT vt.VISIT_TASK_ID,
          WIP.SCHEDULED_START_DATE,
          WIP.SCHEDULED_COMPLETION_DATE
    FROM AHL_WORKORDERS WO,
         WIP_DISCRETE_JOBS WIP,
         AHL_VISIT_TASKS_B VT
    WHERE vt.status_code = 'RELEASED'
    AND   vt.VISIT_ID = P_VISIT_ID
    AND   vt.visit_task_id = wo.VISIT_TASK_ID(+)
--  AND   wo.MASTER_WORKORDER_FLAG = 'N'
    AND   WIP.WIP_ENTITY_ID(+) = WO.WIP_ENTITY_ID
    AND   wo.status_code not in ('22','7');

-- Define local variables
  l_api_version CONSTANT NUMBER := 1.0;
  L_API_NAME    CONSTANT VARCHAR2(30) := 'Calculate_Task_Times';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_start_date           DATE;   --Task start date
  l_end_date             DATE;   --Task end date
  l_temp_date            DATE;   --temporary local variable
  l_cum_duration         NUMBER :=0;
  l_task_data_rec        get_task_data_csr%ROWTYPE;
  l_stage_data_rec       get_stage_data_csr%ROWTYPE;
  l_wo_data_rec          get_wo_data_csr%ROWTYPE;
--
BEGIN

   SAVEPOINT calculate_task_Times_pvt;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Visit Id = ' || p_visit_id);
   END IF;

   -- Standard call to check for call compatibility
   IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   -- Initialize API RETURN status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Calculate Task time for tasks in Planning Status
   -- Begin Processing
   -- 1. Fetch the Visit's deparment id and visit start date
    OPEN get_visit_data_csr(p_visit_id);
    FETCH get_visit_data_csr INTO G_VISIT_START_DATE, G_VISIT_DEPT_ID;
    IF (get_visit_data_csr%NOTFOUND) THEN

       UPDATE AHL_VISIT_TASKS_B
       SET START_DATE_TIME = Null,
           END_DATE_TIME = Null,
           object_version_number = object_version_number +1
       WHERE visit_id = p_visit_id
       AND nvl(Status_Code, 'X') <>'DELETED'
       -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
       AND PAST_TASK_START_DATE IS NULL;


       --Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ID_INVALID');
       --Fnd_Message.Set_Token('VISIT_ID', p_visit_id);
       --Fnd_Msg_Pub.ADD;
       CLOSE get_visit_data_csr;
       RETURN;
    END IF;
    CLOSE get_visit_data_csr;

    /*
    --Can not evaluate if either visit start date or visit department is null
    IF (G_VISIT_START_DATE IS NULL) THEN
        --Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ST_DATE_NULL');
        --Fnd_Msg_Pub.ADD;
        RETURN;
    ELSIF (G_VISIT_DEPT_ID IS NULL) THEN
        --Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_DEPT_NULL');
        --Fnd_Msg_Pub.ADD;
        RETURN;
    END IF;
    */

    --Clear up previous calculated task start/end date if visit start date or dept is missing
    IF (G_VISIT_START_DATE IS NULL) OR (G_VISIT_DEPT_ID IS NULL) THEN
       UPDATE AHL_VISIT_TASKS_B
       SET START_DATE_TIME = Null,
           END_DATE_TIME = Null,
           object_version_number = object_version_number +1
       WHERE visit_id = p_visit_id
       AND nvl(Status_Code, 'X') <>'DELETED'
       -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
       AND PAST_TASK_START_DATE IS NULL;

       RETURN;
    END IF;

   --2. Derive the stage time durations
   FOR l_stage_data_rec in get_stage_data_csr(p_visit_id)
   LOOP
     G_STAGES_TBL(l_stage_data_rec.stage_id) := l_cum_duration;
     l_cum_duration := l_cum_duration + l_stage_data_rec.duration;
   END LOOP; -- get_stage_data_csr;

   --3. Fetch all the tasks sorted by the dependency hierarchy.
   FOR l_task_data_rec in get_task_data_csr(p_visit_id)
   LOOP

      --Add the stage offset 1st to the visit date and use visit department id
      IF (l_task_data_rec.stage_id IS NOT NULL) THEN
         l_start_date := Compute_Date (G_VISIT_START_DATE, G_VISIT_DEPT_ID, G_STAGES_TBL(l_task_data_rec.stage_id));
      ELSE
         l_start_date := G_VISIT_START_DATE;
      END IF;

      --Compute using the department id of the task for task offset number
      l_start_date := Compute_Date(l_start_date, nvl(l_task_data_rec.department_id, G_VISIT_DEPT_ID), l_task_data_rec.start_from_hour);

      --3a. Find the max end time of the dependent parents. All parents should be calculated
      -- because of the sort order of the task cursor query.
      OPEN get_tech_dependency_csr(l_task_data_rec.visit_task_id);
      FETCH get_tech_dependency_csr INTO l_temp_date;
      IF (get_tech_dependency_csr%FOUND AND
         l_temp_date IS NOT NULL) THEN
         --If stage offset is later than technical dependencies.
         --Conform the task end date to the shift times
         IF (l_temp_date > l_start_date) THEN
            l_start_date := Compute_Date(l_temp_date, nvl(l_task_data_rec.department_id, G_VISIT_DEPT_ID),0);
         END IF;
      END IF;
      CLOSE get_tech_dependency_csr;

      --3c. Now derive the end date based on the start date
      l_end_date := compute_date(l_start_date,
                           nvl(l_task_data_rec.department_id, G_VISIT_DEPT_ID),
                           l_task_data_rec.duration);

      --3d Update the tasks table with the new dates and times.
      UPDATE AHL_VISIT_TASKS_B
      SET START_DATE_TIME = l_start_date,
          END_DATE_TIME = l_end_date
      WHERE visit_task_id = l_task_data_rec.visit_task_id
       -- SKPATHAK :: ER: 9147951 :: 11-JAN-2010
       AND PAST_TASK_START_DATE IS NULL;


   END LOOP; --get_task_data_csr;

   -- Added by yazhou Sept-21-2004
   -- Derive Task time for tasks in Released Status
   FOR l_wo_data_rec in get_wo_data_csr(p_visit_id)
   LOOP
       --Update the tasks table with the new dates and times.
       UPDATE AHL_VISIT_TASKS_B
       SET START_DATE_TIME = l_wo_data_rec.SCHEDULED_START_DATE,
           END_DATE_TIME = l_wo_data_rec.SCHEDULED_COMPLETION_DATE
       WHERE visit_task_id = l_wo_data_rec.visit_task_id;

   END LOOP; --get_wo_data_csr;

  -- Standard check of p_commit
  IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
     COMMIT WORK;
  END IF;

  -- Standard call to get message count and if count is 1, get message info
  Fnd_Msg_Pub.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => Fnd_Api.g_false
    );

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure. RETURN Status = ' || x_return_status);
  END IF;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   ROLLBACK TO calculate_task_Times_pvt;
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO calculate_task_Times_pvt;
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    ROLLBACK TO calculate_task_Times_pvt;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
       Fnd_Msg_Pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Calculate_Task_Times',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
END Calculate_Task_Times;

--------------------------------------------------------------------
--  Procedure name    : Adjust_task_times
--  Type              : Private
--  Purpose           : Adjusts tasks times and all dependent task times
--  Parameters  :
--
--  Standard OUT Parameters :
--   x_return_status        OUT     VARCHAR2     Required,
--
--  Adjust_task_Times IN Parameters :
--  p_task_id             IN  NUMBER     Required
--
--  Version :
--      Initial Version   1.0
--
--------------------------------------------------------------------
-- SKPATHAK :: Bug 8343599 :: 14-APR-2009
-- Added the optional in param p_task_start_date
PROCEDURE Adjust_Task_Times
(
    p_api_version        IN         NUMBER,
    p_init_msg_list      IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit             IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level   IN         NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    p_task_id            IN         NUMBER,
    p_reset_sysdate_flag IN         VARCHAR2 := FND_API.G_FALSE,
    p_task_start_date    IN         DATE     := NULL)
IS
--
--Cursor for fetching visit info
CURSOR get_visit_data_csr(p_task_id IN NUMBER) IS
SELECT v.start_date_time, v.department_id, v.visit_id, v.status_code
FROM AHL_VISITS_B v, AHL_VISIT_TASKS_B vt, AHL_DEPARTMENT_SHIFTS dept
WHERE v.visit_id = vt.visit_id
AND dept.department_id = v.department_id
AND vt.visit_task_id = p_task_id;
--
--Cursor for deriving all the stage start hours
CURSOR get_stage_data_csr(p_task_ID IN number)
IS
SELECT st.stage_id, st.duration
--,  sum(st.duration) over(order by st.stage_num) CUMUL_DURATION
from ahl_vwp_stages_vl st, ahl_visit_tasks_b vt
where st.visit_id = vt.visit_id
AND vt.visit_task_id = p_task_id
order by st.stage_num;
-- Define local variables
  l_api_version CONSTANT NUMBER := 1.0;
  L_API_NAME    CONSTANT VARCHAR2(30) := 'Adjust_Task_Times';
  L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
  l_visit_id             NUMBER;
  l_cum_duration         NUMBER :=0;
--
BEGIN

   SAVEPOINT Adjust_Task_Times_pvt;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Task Id = ' || p_task_id);
   END IF;

   -- Standard call to check for call compatibility
   IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   -- Initialize API RETURN status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   --Start Processing here
   -- 1. Fetch the Visit's deparment id and visit start date
    OPEN get_visit_data_csr(p_task_id);
    FETCH get_visit_data_csr INTO G_VISIT_START_DATE, G_VISIT_DEPT_ID, l_visit_id, G_VISIT_STATUS;
    IF (get_visit_data_csr%NOTFOUND) THEN
       --Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ID_INVALID');
       --Fnd_Message.Set_Token('VISIT_ID', l_visit_id);
       --Fnd_Msg_Pub.ADD;
       CLOSE get_visit_data_csr;
       RETURN;
    END IF;
    CLOSE get_visit_data_csr;

    --Can not evaluate if either visit start date or visit department is null
    IF (G_VISIT_START_DATE IS NULL)THEN
        --Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ST_DATE_NULL');
        --Fnd_Msg_Pub.ADD;
        RETURN;
    ELSIF (G_VISIT_DEPT_ID IS NULL) THEN
        --Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_DEPT_NULL');
        --Fnd_Msg_Pub.ADD;
        RETURN;
    END IF;

   --2. Derive the stage time durations
   FOR l_stage_data_rec in get_stage_data_csr(p_task_id)
   LOOP
     G_STAGES_TBL(l_stage_data_rec.stage_id) := l_cum_duration;
       l_cum_duration := l_cum_duration + l_stage_data_rec.duration;
   END LOOP; -- get_stage_data_csr;

   G_RESET_SYSDATE_FLAG := p_reset_sysdate_flag;

   --3. Call the internal recursive loop on task time adjustment
   -- SKPATHAK :: Bug 8343599 :: 14-APR-2009
   -- Passed on the new p_task_start_date param
   Adjust_Task_Times_Internal(p_task_id,
                              p_task_start_date => p_task_start_date);

   -- Standard check of p_commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

  -- Standard call to get message count and if count is 1, get message info
  Fnd_Msg_Pub.Count_And_Get
    ( p_count => x_msg_count,
      p_data  => x_msg_data,
      p_encoded => Fnd_Api.g_false
    );

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure. RETURN Status = ' || x_return_status);
  END IF;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   ROLLBACK TO Adjust_Task_Times_pvt;
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Adjust_Task_Times_pvt;
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    ROLLBACK TO Adjust_Task_Times_pvt;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
       Fnd_Msg_Pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Adjust_Task_Times',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
END Adjust_Task_Times;

-----------------------------------------------------------------------------
--Function:         Private Method for recursion of task derivation
------------------------------------------------------------------------------

-- SKPATHAK :: Bug 8343599 :: 14-APR-2009
-- Added the optional in param p_task_start_date
PROCEDURE Adjust_Task_Times_Internal(p_task_id         IN NUMBER,
                                     p_task_start_date IN DATE default NULL)
IS
--Fetch basic visit data
CURSOR get_task_data_csr(p_task_id IN NUMBER) IS
SELECT vt.start_date_time, vt.end_date_time,
   nvl(vt.department_id, v.department_id),
   /*B6182718 - sowsubra*/
   nvl(vt.duration, NVL(Get_task_duration(vt.quantity, routes.route_id), 0)) duration,
   vt.stage_id,
   nvl(vt.start_from_hour, 0)
FROM AHL_VISIT_TASKS_B vt, AHL_VISITS_B v,
     ahl_routes_app_v routes, ahl_mr_routes_app_v mr
WHERE vt.visit_id = v.visit_id
AND routes.route_id (+) = mr.route_id
AND mr.mr_route_id (+)= vt.mr_route_id
AND  vt.visit_task_id = p_task_id
AND vt.task_type_code <> 'SUMMARY'
AND (VT.STATUS_CODE IS NULL OR VT.STATUS_CODE <> 'DELETED');
--
--This cursor uses the technical dependencies and finds the parent task
-- that finishes last.
CURSOR get_tech_dependency_csr(p_task_id IN NUMBER) IS
SELECT max(vt.end_date_time)
FROM AHL_VISIT_TASKS_B vt, AHL_TASK_LINKS tl
WHERE vt.visit_task_id = tl.parent_task_id
AND tl.visit_task_id = p_task_id;
--
--Cursor which fetches all child technical dependent tasks
CURSOR get_child_dependency_csr(p_task_id IN NUMBER) IS
SELECT visit_task_id
FROM AHL_TASK_LINKS
WHERE parent_task_id = p_task_id;
--
l_old_task_start       DATE;   --Existing task start time
l_old_task_end         DATE;   --Existing task end time
l_task_dept_id         NUMBER; --Existing task department
l_task_duration        NUMBER; --Tasks duration
l_task_stage_id        NUMBER; --Tasks stage id
l_task_offset          NUMBER; --Number of hours offset based on stage.
l_start_date           DATE;   --Newly derived task start date
l_end_date             DATE;   --Newly derived task end date
l_temp_date            DATE;    --Temporary date for comparison purposes
l_child_task_id        NUMBER; --Child task id
L_API_VERSION CONSTANT NUMBER        := 1.0;
L_API_NAME    CONSTANT VARCHAR2(30)  := 'Adjust_Task_Times_Internal';
L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
--
BEGIN
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.begin',
                      'At the start of PL SQL procedure. Visit Task Id = ' || p_task_id);
    END IF;

    -- 1. Fetch the task's old info and task related info
    OPEN get_task_data_csr(p_task_id);
    FETCH get_task_data_csr INTO l_old_task_start, l_old_task_end, l_task_dept_id,
                            l_task_duration, l_task_stage_id , l_task_offset;

    --If it is a valid task
    IF (get_task_data_csr%FOUND) THEN

     --2. Check the task stage time value
     --Get stage offset if stage id is not null
    -- SKPATHAK :: Bug 8343599 :: 14-APR-2009 :: Begin
    -- If a task start date has been passed (for Non Routines), use that date as the baseline
    -- to calculate the actual start time of the task.
    IF (p_task_start_date IS NOT NULL) THEN
      l_start_date := p_task_start_date;
    ELSE
      l_start_date := G_VISIT_START_DATE;
    END IF;
    IF (l_task_stage_id IS NOT NULL) THEN
      l_start_date := Compute_Date (l_start_date, G_VISIT_DEPT_ID, G_STAGES_TBL(l_task_stage_id));
    END IF;
    -- SKPATHAK :: Bug 8343599 :: 14-APR-2009 :: End


    --Adjust the start date to the task offset
    l_start_date := Compute_Date (l_start_date, nvl(l_task_dept_id, G_VISIT_DEPT_ID), l_task_offset);

     --3. Find the max end time of the dependent parents. Adjust based on parent
     OPEN get_tech_dependency_csr(p_task_id);
     FETCH get_tech_dependency_csr INTO l_temp_date;
     IF (get_tech_dependency_csr%FOUND) THEN
        l_temp_date := Compute_Date (l_temp_date, nvl(l_task_dept_id, G_VISIT_DEPT_ID),0);

        --If shift adjusted dependency date is later than stage offset date
        IF (l_temp_date > l_start_date) THEN
           l_start_date := l_temp_date;
        END IF;
     END IF;
     CLOSE get_tech_dependency_csr;

     --Adjust start date for partially released/released tasks to sysdate start date
     IF ((G_VISIT_STATUS = 'PARTIALLY RELEASED' OR G_VISIT_STATUS = 'RELEASED')
        AND Fnd_Api.TO_BOOLEAN(G_RESET_SYSDATE_FLAG)) THEN
      IF (l_start_date < sysdate AND p_task_start_date IS NULL) THEN
            l_start_date := COMPUTE_DATE(sysdate, nvl(l_task_dept_id, G_VISIT_DEPT_ID),0);
        END IF;
     END IF;

     --4. Now derive the end date
     l_end_date := compute_date(l_start_date, l_task_dept_id, l_task_duration);
     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'Start Date = ' || l_start_date ||
                       '. End Date = ' || l_end_date);
     END IF;

     --5. Update the record if it has been changed and call child tasks
     IF (l_old_task_start IS NULL OR
         l_old_task_end IS NULL OR
         l_start_date <> l_old_task_start OR
         l_end_date <> l_old_task_end) THEN

       --3d Update the tasks table with the new dates and times.
       UPDATE AHL_VISIT_TASKS_B
       SET START_DATE_TIME = l_start_date,
           END_DATE_TIME = l_end_date
       WHERE visit_task_id = p_task_id;

       --If the end date has changed, recursively call the child tasks
       -- To see if they need to be adjusted. Potentially expensive.
       IF (l_old_task_end IS NULL OR
           l_end_date <>  l_old_task_end) THEN
          OPEN get_child_dependency_csr(p_task_id);
          LOOP
            FETCH get_child_dependency_csr INTO l_child_task_id;
            EXIT WHEN get_child_dependency_csr%NOTFOUND;
            IF (l_log_statement >= l_log_current_level) THEN
               fnd_log.string(l_log_statement,
                              L_DEBUG_KEY,
                              'Calling child task: ' || l_child_task_id);
            END IF;
            Adjust_Task_Times_Internal(l_child_task_id);
          END LOOP;
          CLOSE get_child_dependency_csr;
        END IF;
      END IF; --start time has changed;

   END IF; --end found
   CLOSE get_task_data_csr;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure.');
   END IF;

END Adjust_Task_Times_Internal;
-------------------------------------------------------------------
--  Procedure name    : Calculate_Task_Times_For_Dept
--  Type              : Private
--  Function          : Recalculate all Visits for Dept for Task Times
--  Parameters  :
--
--  Standard OUT Parameters :
--      x_return_status       OUT     VARCHAR2     Required
--      x_msg_count           OUT     NUMBER       Required
--      x_msg_data            OUT     VARCHAR2     Required
--
--  Derive_Visit_Task_Times Parameters:
--      p_dept_id            IN      NUMBER       Required
--         The dept id which need to have all its visits recalculated.
--     Need to be called from concurrent program due to performance issues.
--
-------------------------------------------------------------------
PROCEDURE Calculate_Task_Times_For_Dept
(
    p_api_version      IN         NUMBER,
    p_init_msg_list    IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit           IN         VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level IN         NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2,
    p_dept_id          IN         NUMBER)
IS
--
CURSOR get_all_visits_csr(p_dept_id IN NUMBER) IS
SELECT visit_id
FROM AHL_VISITS_B
WHERE DEPARTMENT_ID = p_dept_id
UNION
SELECT visit_id
FROM AHL_VISIT_TASKS_B
WHERE department_id = p_dept_id;
--
-- Define local variables
l_api_version CONSTANT NUMBER := 1.0;
L_API_NAME    CONSTANT VARCHAR2(30)  := 'Calculate_Task_Times_For_Dept';
L_DEBUG_KEY   CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
l_visit_id             NUMBER;
--
BEGIN
   SAVEPOINT Calculate_Times_for_dept_pvt;

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.begin',
                     'At the start of PL SQL procedure. Dept Id = ' || p_dept_id);
   END IF;

   -- Standard call to check for call compatibility
   IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
      RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE
   IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
      Fnd_Msg_Pub.Initialize;
   END IF;

   -- Initialize API RETURN status to success
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   OPEN get_all_visits_csr(p_dept_id);
   LOOP
      FETCH get_all_visits_csr INTO l_visit_id;
      EXIT WHEN get_all_visits_csr%NOTFOUND;

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'Before calling CALCULATE_TASK_TIMES.');
      END IF;

      Calculate_Task_Times(p_api_version      => 1.0,
                           p_init_msg_list    => Fnd_Api.G_FALSE,
                           p_commit           => Fnd_Api.G_FALSE,
                           p_validation_level => Fnd_Api.G_VALID_LEVEL_FULL,
                           x_return_status    => x_return_status,
                           x_msg_count        => x_msg_count,
                           x_msg_data         => x_msg_data,
                           p_visit_id         => l_visit_id);

      IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string(l_log_statement,
                        L_DEBUG_KEY,
                        'After calling CALCULATE_TASK_TIMES. RETURN Status = ' ||
                        x_return_status);
      END IF;

      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string(l_log_statement,
                           L_DEBUG_KEY,
                           'Errors from CALCULATE_TASK_TIMES. Message count: ' ||
                           x_msg_count || ', message data: ' || x_msg_data);
         END IF;
         CLOSE get_all_visits_csr;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSE
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      END IF;
   END LOOP;
   CLOSE get_all_visits_csr;

   -- Standard check of p_commit
   IF Fnd_Api.TO_BOOLEAN(p_commit) THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info
   Fnd_Msg_Pub.Count_And_Get
     ( p_count => x_msg_count,
       p_data  => x_msg_data,
       p_encoded => Fnd_Api.g_false
     );

   IF (l_log_procedure >= l_log_current_level) THEN
      fnd_log.string(l_log_procedure,
                     L_DEBUG_KEY ||'.end',
                     'At the end of PL SQL procedure. RETURN Status = ' || x_return_status);
   END IF;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   ROLLBACK TO calculate_Times_for_dept_pvt;
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO calculate_Times_for_dept_pvt;
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    ROLLBACK TO calculate_Times_for_dept_pvt;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
       Fnd_Msg_Pub.add_exc_msg( p_pkg_name       => G_PKG_NAME,
                                p_procedure_name => 'Calculate_Task_Times_For_Dept',
                                p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
END Calculate_Task_Times_For_Dept;

----------------END OF TASK/VISIT SECTION ----------------------------------------


----------------START OF SHIFT DATE TIME SECTION------------------------------------

-----------------------------------------------------------
--  Function Name:  Compute_Date
--  Type:           Private
--  Function:       Converts date+duration and department into end date/time
--                  Has to be super-efficient as this is called repeatedly.
--                  Performance tuning is top priority for this method.
--                  - no debug code or debug checks.
--                  - code inlined as much as possible, use memory instead of queries
--
--  Compute_Date Parameters:
--      p_start_date  IN  NUMBER  Required
--      The start date of the compute date value
--      p_dept_id     IN  NUMBER  Required
--      The department id to calculate the date for
--      p_duration    IN  NUMBER
--      The duration in hours of the tasks offset
--   RETURNs the department shift adjusted end date of p_start_date+p_duration
--
---------------------------------------------------------
FUNCTION Compute_Date(
    p_start_date date,
    p_dept_id number,
    p_duration number)
  RETURN DATE
IS
--
--Get the number of holiday days that falls under the duration
 CURSOR get_holiday_csr(p_department_id IN NUMBER,
                         p_start_date IN DATE,
                         p_end_date IN DATE) IS
    SELECT COUNT(ex.EXCEPTION_DATE)
    FROM bom_calendar_exceptions ex, ahl_department_shifts dept
    WHERE ex.CALENDAR_CODE = dept.calendar_code
    AND EXCEPTION_TYPE = G_HOLIDAY_TYPE
    AND dept.department_id = p_department_id
    AND ex.exception_date > p_start_date
    AND ex.exception_date <= p_end_date;
--
l_start_date         DATE;   -- The p_start_date adjusted for different department.
l_shift_start_date   DATE;   --The date that the shift started.
l_end_date           DATE;   --The end date that is being calculated.
l_end_hour           NUMBER; --Ending hour
l_curr_wday          NUMBER; --current wday
l_num_of_weekends    NUMBER; --Number of weekends (multiple by off days)
l_mod_days           NUMBER; --Modulo workdays for given weekend
l_days_to_add        NUMBER; --Number of holiday days to add.
l_shift_duration     NUMBER; --The shift duration in UOM of day
L_API_NAME  CONSTANT VARCHAR2(30)  := 'Compute_Date';
L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
--
BEGIN

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL function. Start Date = ' || p_start_date ||
                    ', Department Id = ' || p_dept_id || ', Duration = ' || p_duration);
  END IF;

  --1. Re-init the department shift time data if not the same
  -- as the current cached department
  IF (G_CURRENT_DEPT_ID IS NULL or
      p_dept_id <> G_CURRENT_DEPT_ID) THEN
  Init_Shift_Data(p_dept_id);
  G_CURRENT_DEPT_ID := p_dept_id;
  END IF;

  --2. Adjust the start date to department shift
  l_start_date := p_start_date;

 --Reset the start time to shift start hour if shift starts after current time.
   IF (G_SHIFT_END < G_SHIFT_START) THEN
     IF (l_start_date < TRUNC(l_start_date) + G_SHIFT_START AND
         l_start_date  >= TRUNC(l_start_date) + G_SHIFT_END) THEN
         l_start_date := trunc(l_start_date)+ G_SHIFT_START;
     END IF;
   ELSE
      IF (l_start_date < TRUNC(l_start_date) + G_SHIFT_START) THEN
          l_start_date := trunc(l_start_date)+ G_SHIFT_START;
      ELSIF (l_start_date  >= TRUNC(l_start_date) + G_SHIFT_END) THEN
         --Add another day if shift starts tomorrow
         l_start_date := trunc(l_start_date)+ 1 + G_SHIFT_START;
     END IF;
   END IF;

   --If it's an overnight shift and time is before shift ends on the same day,
  --the shift started a day earlier
  l_shift_start_date :=  get_shift_start_date(l_start_date);

  l_curr_wday := MOD((TRUNC(l_shift_start_date) - G_CAL_START), (G_DAYS_ON + G_DAYS_OFF));

  -- Add to a day_on (basically, passed the weekend)
  IF(l_curr_wday +1 > G_DAYS_ON) THEN
    l_start_date := TRUNC(l_shift_start_date + (G_DAYS_ON+G_DAYS_OFF-l_curr_wday))+G_SHIFT_START;
  END IF;

  --If it's an overnight shift and time is before shift ends on the same day,
  --the shift started a day earlier
  l_shift_start_date :=  get_shift_start_date(l_start_date);

  -- Not Day Off: Check if holiday and adjust based on holiday
  WHILE (Is_Dept_Holiday(l_shift_start_date)) LOOP
       l_shift_start_date := l_shift_start_date+1;

       l_curr_wday := MOD((l_shift_start_date - G_CAL_START), (G_DAYS_ON + G_DAYS_OFF));
       -- Add to a day_on (basically, passed the weekend)
       IF(l_curr_wday +1 > G_DAYS_ON) THEN
          l_shift_start_date := l_shift_start_date + (G_DAYS_ON+G_DAYS_OFF-l_curr_wday);
       END IF;

       l_start_date := TRUNC(l_shift_start_date) + G_SHIFT_START;
  END LOOP;

  IF (p_duration = 0) THEN
    -- If duration is 0, RETURN the adjusted start date.
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL function. Start Date = ' || l_start_date);
    END IF;
    RETURN l_start_date;

  ELSE

    --1. derive shift duration
    IF(G_SHIFT_END < G_SHIFT_START) THEN
     l_shift_duration := (24*G_SHIFT_END + 24  - 24*G_SHIFT_START)/24;
    ELSE
     l_shift_duration := (24*G_SHIFT_END - 24*G_SHIFT_START)/24;
    END IF;

    --2. Calculate the end date based on the start and duration. p_duration is in hours
    -- so must divide duration/24 to get fractions of a day
    --Both the p_duration/24 and the l_shift_duration are stored as fraction of a day

    --If the border condition of p_duration/shift_duration is an exact number of days and
    -- l_start_date equals the shift start date. Then set end date to shift end time
    -- and date to n-1 days from start date
    --SKPATHAK :: Bug 8322149 :: 20-APR-2009
    --Changed the condition from (MOD(p_duration/24, l_shift_duration)=0 to (MOD(p_duration, l_shift_duration*24)=0
    IF (MOD(p_duration, l_shift_duration*24) =0
      AND l_start_date-TRUNC(l_start_date)= G_SHIFT_START) THEN
      l_end_date := l_start_date + (TRUNC((p_duration/24)/l_shift_duration)-1)+l_shift_duration;
    ELSE
      l_end_date := l_start_date + TRUNC((p_duration/24)/l_shift_duration) + MOD(p_duration/24, l_shift_duration);
    END IF;

    --Get the end hour as fraction of a day
    l_end_hour := l_end_date - TRUNC(l_end_date);

    --3. If new end hours goes beyond shift end hour, adjust til next shift
    IF (l_end_hour > G_SHIFT_END) THEN
      --Adjust end hour into the next shift. So if end_hour is 9pm and shift end is 5pm.
      -- Then must add 4 hours to shift start time. (all in fraction of a day)
      --This value could be > 1 for overnight shifts
       l_end_hour := G_SHIFT_START + (l_end_hour-G_SHIFT_END);

       --Add a day to the end date if the shift ends after start time. (Regular shift)
       IF (G_SHIFT_START < G_SHIFT_END) THEN
        l_end_date := TRUNC(l_end_date)+1+l_end_hour;
       ELSE
        l_end_date := TRUNC(l_end_date)+l_end_hour;
       END IF;
    END IF;

    --Add in the days off
    --First calculate number of days off
    l_num_of_weekends := TRUNC((get_shift_start_date(l_end_date)-get_shift_start_date(l_start_date))/G_DAYS_ON);

    --This gets the number of extra days over week so that we can check if we get an extra weekend.
    l_mod_days :=MOD(get_shift_start_date(l_end_date)- get_shift_start_date(l_start_date), G_DAYS_ON);

    --This is the weekday of the start day.
    l_curr_wday := MOD(get_shift_start_date(l_start_date) - G_CAL_START, G_DAYS_ON + G_DAYS_OFF);

    --If the extra days pushes into an extra week, add 1 more weekend.
    IF(l_curr_wday+l_mod_days+1>G_DAYS_ON) THEN
      l_num_of_weekends := l_num_of_weekends +1;
    END IF;
    l_end_date := l_end_date + G_DAYS_OFF * l_num_of_weekends;

    --Add in the holidays if not already added
    l_days_to_add := 0;
    OPEN get_holiday_csr(p_dept_id, get_shift_start_date(l_start_date),
                                      get_shift_start_date(l_end_date));
    FETCH get_holiday_csr INTO l_days_to_add;
    CLOSE get_holiday_csr;

    WHILE (l_days_to_add > 0) LOOP
       --Increment and decrement the days
       l_end_date := l_end_date +1;
       l_days_to_add := l_days_to_add -1;

       --Skip the weekends and the additional holidays
       l_curr_wday := MOD(get_shift_start_date(l_end_date)- G_CAL_START, G_DAYS_ON + G_DAYS_OFF);

       IF (l_curr_wday+1 > G_DAYS_ON) THEN
          l_days_to_add := l_days_to_add + 1;
       ELSIF(Is_Dept_Holiday(get_shift_start_date(l_end_date))) THEN
            l_days_to_add := l_days_to_add + 1;
       END IF;
    END LOOP;

   --RETURN the derived end date.
    IF (l_log_procedure >= l_log_current_level) THEN
       fnd_log.string(l_log_procedure,
                      L_DEBUG_KEY ||'.end',
                      'At the end of PL SQL function. End Date = ' || l_end_date);
    END IF;
    RETURN l_end_date;

  END IF;

END Compute_Date;

------------------------------------------------------------------------------
-- Private function that initializes global variables for computing date/time
------------------------------------------------------------------------------
PROCEDURE Init_Shift_Data(p_department_id number)
IS
-- Define local cursors
--Find all shift information into the local variables
CURSOR l_shift_info_csr(p_department_id IN NUMBER) IS
   SELECT TRUNC(cal.CALENDAR_START_DATE), TRUNC(cal.CALENDAR_END_DATE),
          times.FROM_TIME/G_SECS_IN_DAY, times.TO_TIME/G_SECS_IN_DAY,
          pattern.DAYS_ON, pattern.DAYS_OFF
    FROM bom_shift_times times, bom_workday_patterns pattern,
         bom_calendars cal, ahl_department_shifts dept
     WHERE dept.calendar_code = times.calendar_code
     AND dept.shift_num = times.shift_num
     AND pattern.calendar_code = dept.calendar_code
     AND pattern.shift_num = dept.shift_num
     AND cal.calendar_code = dept.calendar_code
     AND dept.department_id = p_department_id;
--
-- Fetch the holidays for the given department
  CURSOR l_exceptions_csr(p_department_id IN NUMBER) IS
    SELECT ex.EXCEPTION_DATE
    FROM bom_calendar_exceptions ex, ahl_department_shifts dept
    WHERE ex.CALENDAR_CODE = dept.calendar_code
    AND EXCEPTION_TYPE = G_HOLIDAY_TYPE
    AND dept.department_id = p_department_id
    ORDER BY EXCEPTION_DATE;
--
l_temp_index NUMBER;
l_temp_date  DATE;
L_API_NAME        CONSTANT VARCHAR2(30)  := 'Init_Shift_Data';
L_DEBUG_KEY       CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || L_API_NAME;
--
BEGIN

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of PL SQL procedure. Department Id = ' || p_department_id);
  END IF;
  -- Get the department informations
  OPEN l_shift_info_csr(p_department_id);
  FETCH l_shift_info_csr INTO G_CAL_START, G_CAL_END,
                             G_SHIFT_START, G_SHIFT_END,
                             G_DAYS_ON, G_DAYS_OFF;
  IF (l_shift_info_csr%NOTFOUND) THEN
    --Fnd_Message.Set_Name('AHL','AHL_LTP_NO_SHIFT_FOR_DEPT');
    --Fnd_Message.Set_Token('DEPT_ID', p_department_id);
    --Fnd_Msg_Pub.ADD;
    CLOSE l_shift_info_csr;
    RETURN; --RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_shift_info_csr;

  -- Get the Exception (Holidays) days
  OPEN l_exceptions_csr(p_department_id);
  l_temp_index := 1;
  LOOP
    FETCH l_exceptions_csr INTO l_temp_date;
    EXIT WHEN l_exceptions_csr%NOTFOUND;
    G_EXCEPTION_DATES_TBL(l_temp_index) := TRUNC(l_temp_date);
    l_temp_index := l_temp_index + 1;
  END LOOP;
  CLOSE l_exceptions_csr;

  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.end',
                    'At the end of PL SQL procedure.');
  END IF;

END Init_shift_Data;

----------------------------------------
-- Function to determine if a specific date is a holiday
----------------------------------------
FUNCTION Is_Dept_Holiday(l_curr_date DATE) RETURN BOOLEAN
IS
  l_temp_date DATE := TRUNC(l_curr_date);
BEGIN
  IF (G_EXCEPTION_DATES_TBL.COUNT = 0) THEN
    RETURN FALSE;
  END IF;
  --Iterate through the exception dates to make sure it's not a holiday.
  FOR i IN G_EXCEPTION_DATES_TBL.FIRST .. G_EXCEPTION_DATES_TBL.LAST LOOP
    IF (l_temp_date = G_EXCEPTION_DATES_TBL(i)) THEN
      RETURN TRUE;
    --Assumes the exception table is sorted by date
    ELSIF (l_temp_date < G_EXCEPTION_DATES_TBL(i)) THEN
      RETURN FALSE;
    END IF;
  END LOOP;

  RETURN FALSE;

END Is_Dept_Holiday;

--------------------------------------------------------------------
--  Function name    : Get_task_duration
--  Type             : Public
--  Purpose          : To return the total duration of the task
--                     based on the resource requirements defined
--                     at the route/operation level.
--
--  Parameters  :
--       p_vst_task_qty   : Visit task quantity
--       p_route_id       : Route id
--
--  27/Nov/2007       Initial Version Sowmya
--------------------------------------------------------------------
Function Get_task_duration(
     p_vst_task_qty   IN   NUMBER,
     p_route_id       IN   NUMBER
 )
RETURN NUMBER IS

CURSOR c_get_route_level_res_reqs (c_route_id IN NUMBER) IS
  SELECT COST_BASIS_ID, DURATION, RT_OPER_RESOURCE_ID
  FROM ahl_rt_oper_resources
  WHERE OBJECT_ID = c_route_id
  AND NVL(SCHEDULED_TYPE_ID,1) <> 2
  AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_ROUTE;

get_route_level_res_reqs_rec  c_get_route_level_res_reqs%ROWTYPE;

CURSOR c_get_op_level_res_reqs (c_oprn_id IN NUMBER) IS
  SELECT COST_BASIS_ID, DURATION, RT_OPER_RESOURCE_ID
  FROM ahl_rt_oper_resources
  WHERE OBJECT_ID = c_oprn_id
  AND NVL(SCHEDULED_TYPE_ID,1) <> 2
  AND ASSOCIATION_TYPE_CODE = G_ASSOC_TYPE_OPERATION;

get_op_level_res_reqs_rec   c_get_op_level_res_reqs%ROWTYPE;

CURSOR c_get_oprns (c_route_id IN NUMBER) IS
  SELECT RO.operation_id
  FROM ahl_operations_vl O, ahl_route_operations RO
  WHERE O.operation_id = RO.operation_id
  AND RO.route_id = c_route_id
  AND O.revision_status_code = 'COMPLETE'
  AND O.revision_number IN (SELECT max(revision_number)
                            FROM ahl_operations_b_kfv
                            WHERE concatenated_segments = O.concatenated_segments
                            AND trunc(sysdate) between trunc(start_date_active) and
                            trunc(NVL(end_date_active,SYSDATE+1))
                            );

get_oprns_rec   c_get_oprns%ROWTYPE;

CURSOR c_get_route_time_span (c_route_id IN NUMBER) IS
  SELECT time_span
  FROM ahl_routes_b
  WHERE ROUTE_ID = c_route_id;

L_API_NAME  CONSTANT VARCHAR2(30)  := 'Get_task_duration';
L_DEBUG_KEY CONSTANT VARCHAR2(100) := 'ahl.plsql.' || G_PKG_NAME || '.' || l_api_name;
l_vst_task_qty       NUMBER := p_vst_task_qty;
max_duration         NUMBER := 0;
ro_duration          NUMBER := 0;
total_opr_duration   NUMBER := 0;
rt_final_duration    NUMBER := 0;
rt_time_span         NUMBER := 0;

BEGIN
  -- Log API entry point
  IF (l_log_procedure >= l_log_current_level) THEN
     fnd_log.string(l_log_procedure,
                    L_DEBUG_KEY ||'.begin',
                    'At the start of function. Route Id = ' || p_route_id || ' and Task Quantity = ' || p_vst_task_qty);
  END IF;

  IF (p_route_id IS NULL) THEN
     IF (l_log_statement >= l_log_current_level)THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'Route Id is null.');
     END IF;
     RETURN 0;
  END IF;

  OPEN c_get_route_time_span (p_route_id);
  FETCH c_get_route_time_span INTO rt_time_span;
  CLOSE c_get_route_time_span;

  IF (l_log_statement >= l_log_current_level)THEN
     fnd_log.string(l_log_statement,
                    L_DEBUG_KEY,
                    'Route time span = ' || rt_time_span || ', Visit task Quantity = ' || l_vst_task_qty);
  END IF;

  IF (nvl(l_vst_task_qty,1) = 1) THEN --serialized items
     IF (l_log_statement >= l_log_current_level)THEN
        fnd_log.string(l_log_statement,
                       L_DEBUG_KEY,
                       'serialized item. rt_time_span = ' || rt_time_span);
     END IF;
     RETURN rt_time_span;
  ELSIF (l_vst_task_qty > 1) THEN --non-serialized items
    OPEN c_get_route_level_res_reqs (p_route_id);
    FETCH c_get_route_level_res_reqs INTO get_route_level_res_reqs_rec;
    IF (c_get_route_level_res_reqs%FOUND) THEN --requirements exist at route level
      LOOP
        EXIT WHEN c_get_route_level_res_reqs%NOTFOUND;
        IF (nvl(get_route_level_res_reqs_rec.cost_basis_id,2) = 1) THEN --item based resource
            ro_duration := get_route_level_res_reqs_rec.duration * l_vst_task_qty;
        ELSE --lot based resource
            ro_duration := get_route_level_res_reqs_rec.duration ;
        END IF;

        IF (ro_duration > max_duration) THEN
            max_duration := ro_duration;
        END IF;

        FETCH c_get_route_level_res_reqs INTO get_route_level_res_reqs_rec;
      END LOOP;
      CLOSE c_get_route_level_res_reqs;
      rt_final_duration := max_duration;
    ELSE --requirements exist at operation level
      CLOSE c_get_route_level_res_reqs;
      OPEN c_get_oprns (p_route_id);
      LOOP
        FETCH c_get_oprns INTO get_oprns_rec;
        EXIT WHEN c_get_oprns%NOTFOUND;

        max_duration := 0;

        OPEN c_get_op_level_res_reqs (get_oprns_rec.operation_id);
        LOOP
          FETCH c_get_op_level_res_reqs INTO get_op_level_res_reqs_Rec;
          EXIT WHEN c_get_op_level_res_reqs%NOTFOUND;
          IF (nvl(get_op_level_res_reqs_Rec.cost_basis_id,2) = 1) THEN --item based resource
              ro_duration := get_op_level_res_reqs_Rec.duration * l_vst_task_qty;
          ELSE --lot based resource
              ro_duration := get_op_level_res_reqs_Rec.duration ;
          END IF;

          IF (ro_duration > max_duration) THEN
              max_duration := ro_duration;
          END IF;
        END LOOP;
        CLOSE c_get_op_level_res_reqs;
        /*max durations of all operations are summed up since they are assumed to be performed sequentially.*/
        total_opr_duration := total_opr_duration + max_duration;
      END LOOP;
      CLOSE c_get_oprns;

      rt_final_duration := total_opr_duration;
    END IF; --requirements exist at route level

    IF (l_log_statement >= l_log_current_level)THEN
       fnd_log.string(l_log_statement,
          L_DEBUG_KEY,
          'Route Duration - ' ||rt_final_duration);
    END IF;

    IF (rt_time_span >= rt_final_duration) THEN
       IF (l_log_procedure >= l_log_current_level) THEN
          fnd_log.string(l_log_procedure,
                         L_DEBUG_KEY ||'.end',
                         'At the end of PL SQL function. non-serialized item. rt_time_span = ' || rt_time_span);
       END IF;
       RETURN rt_time_span;
    ELSE
       IF (l_log_procedure >= l_log_current_level) THEN
          fnd_log.string(l_log_procedure,
                         L_DEBUG_KEY ||'.end',
                         'At the end of PL SQL function. non-serialized item. rt_final_duration = ' || rt_final_duration);
       END IF;
       RETURN rt_final_duration;
    END IF;
  END IF; --non-serialized items

END Get_task_duration;

END AHL_VWP_TIMES_PVT;

/
