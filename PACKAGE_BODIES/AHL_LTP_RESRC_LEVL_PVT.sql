--------------------------------------------------------
--  DDL for Package Body AHL_LTP_RESRC_LEVL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_LTP_RESRC_LEVL_PVT" AS
/* $Header: AHLVRLGB.pls 120.8 2008/02/25 11:35:34 rnahata ship $ */
--
G_PKG_NAME          CONSTANT VARCHAR2(30) := 'AHL_LTP_RESRC_LEVL_PVT';
G_OPER_ASSOC_TYPE   CONSTANT VARCHAR2(30) := 'OPERATION';
G_RT_ASSOC_TYPE     CONSTANT VARCHAR2(30) := 'ROUTE';
G_SECS_IN_DAY       CONSTANT NUMBER := 86400;
G_SECS_IN_HOUR      CONSTANT NUMBER := 3600;
G_HOLIDAY_TYPE      CONSTANT NUMBER := 2;

-- yazhou 17Aug2005 starts
-- bug fix #4559462
/*
G_MACHINE_RESOURCE  CONSTANT NUMBER := 1;
G_MACHINE_RES_NAME  CONSTANT VARCHAR2(10) := 'Machine';
G_LABOR_RESOURCE    CONSTANT NUMBER := 2;
G_LABOR_RES_NAME    CONSTANT VARCHAR2(10) := 'Labor';
*/
-- yazhou 17Aug2005 ends

G_JSP_MODULE_TYPE   CONSTANT VARCHAR2(3) := 'JSP';
G_ASO_RESOURCE      CONSTANT VARCHAR2(20) := 'ASORESOURCE';
G_BOM_RESOURCE      CONSTANT VARCHAR2(20) := 'BOMRESOURCE';
G_STATUS_PLANNING   CONSTANT VARCHAR2(20) := 'PLANNING';
G_PLAN_TYPE_PRIMARY CONSTANT VARCHAR2(1) := 'Y';
G_UOM_HOUR          CONSTANT VARCHAR2(3) := 'HR';
G_UOM_DAY           CONSTANT VARCHAR2(10) := 'DAYS';
G_UOM_WEEK          CONSTANT VARCHAR2(10) := 'WEEKS';
G_UOM_MONTH         CONSTANT VARCHAR2(10) := 'MONTHS';


-- Package level Global Variables used in time calculations
G_ZERO_TIME         DATE := NULL;
TYPE Dates_Tbl_Type IS TABLE OF DATE INDEX BY BINARY_INTEGER;
G_WORKING_DATES_TBL Dates_Tbl_Type;
G_EXCEPTION_DATES_TBL Dates_Tbl_Type;
G_CALENDAR_CODE     VARCHAR2(10) := NULL;
G_SHIFT_NUM         NUMBER := NULL;
G_SHIFT_START       NUMBER := NULL;
G_SHIFT_END         NUMBER := NULL;
G_DAYS_ON           NUMBER := NULL;
G_DAYS_OFF          NUMBER := NULL;
G_CAL_START         DATE   := NULL;
G_CAL_END           DATE   := NULL;
G_MAX_CAL_DAY       NUMBER := -1;
G_SHIFT_DURATION_HRS NUMBER := 0;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

l_log_current_level     NUMBER      := fnd_log.g_current_runtime_level;
l_log_statement         NUMBER      := fnd_log.level_statement;
l_log_procedure         NUMBER      := fnd_log.level_procedure;
l_log_error             NUMBER      := fnd_log.level_error;
l_log_unexpected        NUMBER      := fnd_log.level_unexpected;

-- Record of Operation Details
TYPE Time_Period_Details_Rec_Type IS RECORD (
        VISIT_ID                NUMBER           := NULL,  -- Visit Id
        TASK_ID                 NUMBER           := NULL,  -- Task Id
        ROUTE_ID                NUMBER           := NULL,  -- Route Id
        MR_ROUTE_ID             NUMBER           := NULL, --ADDED ENAHNCEMENTS
        OPERATION_ID            NUMBER           := NULL,  -- Operation Id (Null for Route Level)
        STEP                    NUMBER           := NULL,  -- Operation sequence within Task
        START_HOUR              NUMBER           := NULL,  -- Start Hour of the task/operation
        END_HOUR                NUMBER           := NULL,  -- End Hour of the task/operation
        MAX_DURATION            NUMBER           := NULL,  -- Max duration required for this task/op.
        START_TIME              DATE             := NULL,  -- Start time of task/operation
        END_TIME                DATE             := NULL,  -- End time of task/operation
        QUANTITY                NUMBER           := NULL,  -- Quantity of a resource
        TASK_TYPE_CODE          VARCHAR2(30)            ,
        REQUIRED_UNITS          NUMBER           := NULL,
      AVAILABLE_UNITS         NUMBER           := NULL,
      ASO_RESOURCE_ID         NUMBER           := NULL,
      DEPARTMENT_ID           NUMBER           := NULL,
        BOM_RESOURCE_ID         NUMBER           := NULL
        );

TYPE Resource_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- yazhou 24Aug2005 ends

-- Record of event and quantity changes
TYPE Qty_Change_Rec_Type IS RECORD (
        EVENT_TIME              DATE,
        QTY_CHANGE              NUMBER
        );

TYPE Time_Period_Details_Tbl_Type IS TABLE OF Time_Period_Details_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Qty_Change_Tbl_Type IS TABLE OF Qty_Change_Rec_Type INDEX BY BINARY_INTEGER;

TYPE Person_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;



-------------------------------
-- Declare Local Procedures --
-------------------------------
-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

  -- Gets all the tasks and their times for all visits for a given plan and department during a given period
  -- If current plan is a simulation and the p_inc_primary flag is 'Y', visits in primary plan are also included.
  PROCEDURE Get_Plan_Tasks(
    p_dept_id               IN            NUMBER,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_inc_primary_flag      IN            BOOLEAN := FALSE,
    x_tp_dtls_tbl           OUT NOCOPY Time_Period_Details_Tbl_Type,
    x_visit_task_times_tbl  OUT NOCOPY Visit_Task_Times_Tbl_Type);

  -- Gets the task and operation times for a given visit. Also builds the
  -- Time Period table if required
  PROCEDURE Derive_Task_Op_Times(
    p_visit_id              IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_department_id         IN            NUMBER,
    p_x_tp_dtls_tbl         IN OUT NOCOPY Time_Period_Details_Tbl_Type,
    x_visit_start_time      OUT NOCOPY           DATE,
    x_visit_end_time        OUT NOCOPY           DATE,
    x_visit_end_hour        OUT NOCOPY           NUMBER,
    x_visit_task_times_tbl  OUT NOCOPY    Visit_Task_Times_Tbl_Type);

-- yazhou 24Aug2005 ends

  -- Gets the resources required by the given task
  PROCEDURE Get_Task_Resources(
    p_required_capacity IN      NUMBER ,
    p_task_id           IN      NUMBER,
    p_tstart_date       IN      DATE,
    p_tend_date         IN      DATE,
    p_distinct_flag     IN      BOOLEAN,  -- If true, duplicate resource are not added to table
    p_x_task_rsrc_tbl   IN OUT  NOCOPY Plan_Rsrc_Tbl_Type);

  -- Gets the details of a resource
  PROCEDURE Get_Resource_Details(
    p_aso_resource_id   IN      NUMBER,
    p_x_task_rsrc_tbl   IN OUT  NOCOPY Plan_Rsrc_Tbl_Type);
  -- Gets the details of a recource and capacity units
  PROCEDURE Get_Resource_Details
(
    p_required_capacity IN      NUMBER,
    p_aso_resource_id   IN      NUMBER,
    p_bom_resource_id   IN      NUMBER,
    p_bom_department_id IN      NUMBER,
    p_start_date        IN      DATE,
    p_end_date          IN      DATE,
    p_x_task_rsrc_tbl   IN OUT  NOCOPY Plan_Rsrc_Tbl_Type);

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

  -- Populates a Time Period table with a task's requirement' start time and end time
  -- (If the task's route has operations and if ressources are not associated at route level)
  -- or with the task's start time and end time
  -- Also populate the table with resource id

  PROCEDURE Get_Operation_Details(
    p_task_dtls      IN      Visit_Task_Times_Rec_Type,
    p_visit_id       IN      NUMBER,
    p_department_id  IN      NUMBER,
    p_organization_id IN     NUMBER,
    p_start_time     IN      DATE,
    p_end_time       IN      DATE,
    p_x_tp_dtls_tbl  IN OUT  NOCOPY Time_Period_Details_Tbl_Type);

-- yazhou 24Aug2005 ends

  -- Filters out tasks/operations that don't require the resource
  -- and gets quantity of resource required by the task/operation
  PROCEDURE Filter_By_Resource(
    p_resource_id    IN      NUMBER,
  p_start_time     IN      DATE,
  p_end_time       IN      DATE,
    p_x_tp_dtls_tbl  IN OUT NOCOPY  Time_Period_Details_Tbl_Type);
 --
 /* Commented by rnahata since its not being used
 PROCEDURE get_qty_By_Resource(
    p_resource_id    IN      NUMBER,
    p_aso_bom_type   IN      VARCHAR2,
    p_x_tp_dtls_tbl  IN OUT NOCOPY  Time_Period_Details_Tbl_Type);
 */

  -- Creates Timeperiods from the start time and end time based on the UOM
  -- and populates the table
  PROCEDURE Create_Time_Periods(
    p_start_time     IN DATE,
    p_end_time       IN DATE,
    p_UOM_code       IN VARCHAR2,
    p_org_id         IN NUMBER,
    p_dept_id        IN NUMBER,
    x_per_rsrc_tbl   OUT NOCOPY Period_Rsrc_Req_Tbl_Type);

  -- Sorts the Quantity Change table based on event time
  PROCEDURE Sort_Qty_Change_Table(
    p_x_qty_change_tbl  IN OUT NOCOPY Qty_Change_Tbl_Type);

  -- Sorts the Time_Period_Details_Tbl By Visit/Task
  PROCEDURE Sort_By_Visit_Task(
    p_x_tp_tbl  IN OUT NOCOPY Time_Period_Details_Tbl_Type);

  -- Aggregates Task Quantities and gets Task and Visit Names
  PROCEDURE Aggregate_Task_Quantities(
    P_resource_id       IN  NUMBER,
    p_org_name         IN VARCHAR2,
    p_dept_name        IN  VARCHAR2,
    p_tp_dtls_table    IN  Time_Period_Details_Tbl_Type,
    x_task_req_tbl     OUT NOCOPY Task_Requirement_Tbl_Type);

  -- Gets the duration of a Route from its timespan column
  PROCEDURE Get_Route_Duration(
    p_route_id  IN  NUMBER,
    x_duration  OUT NOCOPY NUMBER);

  -- Gets the duration of a Route from its resource requirements (directly or through the route's operations)
  PROCEDURE Get_Rt_Ops_Duration(
    p_route_id  IN  NUMBER,
    x_duration  OUT NOCOPY NUMBER);

  -- Gets the duration of an operation from its resource requirements
  PROCEDURE Get_Oper_Max_Duration(
    p_operation_id  IN  NUMBER,
    x_duration      OUT NOCOPY NUMBER);

  -- Gets the duration of a route directly from its resource requirements
  PROCEDURE Get_Rt_Max_Duration(
    p_route_id      IN  NUMBER,
    x_duration      OUT NOCOPY NUMBER);

  -- Initializes the calendar based variables
  PROCEDURE Init_Time_Vars(
    p_visit_start_date IN  DATE,
    p_department_id    IN  NUMBER);
  -- Gets the Nth Working Day
  FUNCTION Get_Nth_Day(p_day_index NUMBER) RETURN DATE;

  -- Determines if a specific date is a holiday
  FUNCTION IS_DEPT_Holiday(l_curr_date DATE) RETURN BOOLEAN;

  -- Determines if a specific resource is available at a specific time
  FUNCTION Resource_In_Duty(p_resource_id NUMBER, p_start_date_time DATE) RETURN BOOLEAN;

  -- Determines if the Resource is already present in the given table
  FUNCTION Is_Resource_Present(p_aso_resource_id NUMBER,
                               p_task_rsrc_tbl   Plan_Rsrc_Tbl_Type) RETURN BOOLEAN;
  -- Function to determine if two time periods overlap
  -- Note that If the end time of one period coincides with the
  -- start time of the other time period, the timeperiods DON'T overlap
  FUNCTION Periods_Overlap(p1_start_time DATE,
                           p1_end_time DATE,
                           p2_start_time DATE,
                           p2_end_time DATE) RETURN BOOLEAN;

  -- Calculates the maximum required quantity during a given period
  FUNCTION Get_Required_Quantity(p_start_time   DATE,
                                 p_end_time     DATE,
                                 p_tp_dtls_tbl  Time_Period_Details_Tbl_Type) RETURN NUMBER;
  -- Compares a visit/task combination with another
  -- Returns +1, -1 or 0 depending on whether first visit task is greater, lesser
  -- or equal to the second visit task
  FUNCTION Compare_Visit_Tasks(p_visit_1 NUMBER,
                               p_task_1  NUMBER,
                               p_visit_2 NUMBER,
                               p_task_2  NUMBER) RETURN NUMBER;

  -- Function to determine if a specific date is not a holiday in the given department
  FUNCTION Not_A_Holiday(p_curr_date DATE, p_dept_id NUMBER) RETURN BOOLEAN;
 -- Get wip job requirements
  -- AnRaj: Obsoleted Procedure
/*
PROCEDURE GET_WIP_DISC_REQ_UNITS(p_org_id            IN NUMBER,
                                  p_bom_dept_id       IN NUMBER,
                                  p_bom_resource_id   IN NUMBER,
                                  p_start_date        IN DATE,
                                  p_end_date          IN DATE,
                                  x_assigned_units    OUT NOCOPY NUMBER);
*/
-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

FUNCTION Get_Available_Units(p_resource_id  NUMBER,
                             p_dept_id      NUMBER) RETURN NUMBER;


PROCEDURE Get_Used_Resources
(
   p_dept_id       IN NUMBER,
   p_start_date    IN DATE,
   p_end_date      IN DATE,
   p_tp_dtls_tbl   IN Time_Period_Details_Tbl_Type,
   x_resources_tbl OUT NOCOPY Resource_Tbl_Type
);

PROCEDURE Append_WIP_Requirements
(
   p_org_id       IN NUMBER,
   p_dept_id      IN NUMBER,
   p_start_date   IN DATE,
   p_end_date     IN DATE,
   p_resource_id  IN NUMBER,
   p_x_tp_dtls_tbl  IN OUT NOCOPY Time_Period_Details_Tbl_Type
);
-- yazhou 24Aug2005 ends

-------------------------------------
-- End Local Procedures Declaration--
-------------------------------------

-- Start of Comments --
--  Procedure name    : Derive_Visit_Task_Times
--  Type              : Private
--  Function          : Derive the start and end times/hours of task associated with a visit
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Derive_Visit_Task_Times Parameters:
--      p_visit_id                      IN      NUMBER       Required
--         The id of the visit whose associated tasks' start and end times or hours
--         need to be derived
--      p_start_time                    IN      DATE         DEFAULT NULL
--         Start time filter for tasks. Only tasks that start after this time will be returned.
--         If null, no filtering will be done
--      p_end_time                      IN      DATE         DEFAULT NULL
--         End time filter for tasks. Only tasks that start before this time will be returned.
--         If null, no filtering will be done
--      x_visit_start_time              OUT     DATE
--         The start time of the visit
--      x_visit_end_time                OUT     DATE
--         The derived end time of the visit
--      x_visit_end_hour                OUT     NUMBER
--         The derived end hour (normalized) of the visit
--      x_visit_task_times_tbl          OUT     Visit_Task_Times_Tbl_Type
--         The table containing details about the tasks associated with this visit
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

--
-- This API has been deprecated -yazhou 24Aug2005
--

PROCEDURE Derive_Visit_Task_Times
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_visit_id              IN            NUMBER,
    p_start_time            IN            DATE      := NULL,
    p_end_time              IN            DATE      := NULL,
    x_visit_start_time      OUT NOCOPY           DATE,
    x_visit_end_time        OUT NOCOPY           DATE,
    x_visit_end_hour        OUT NOCOPY           NUMBER,
    x_visit_task_times_tbl  OUT  NOCOPY   AHL_LTP_RESRC_LEVL_PVT.Visit_Task_Times_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
) IS

  CURSOR l_validate_visit_csr(p_visit_id  IN NUMBER) IS
    SELECT 'x' FROM ahl_visits_b
    WHERE VISIT_ID = p_visit_id;

  l_api_version            CONSTANT NUMBER := 1.0;
  l_api_name               CONSTANT VARCHAR2(30) := 'Derive_Visit_Task_Times';
  l_dummy_table            Time_Period_Details_Tbl_Type;
  l_junk                   VARCHAR2(1);

BEGIN
--  dbms_output.put_line('Entering Derive_Visit_Task_Times');
  -- Standard start of API savepoint
  SAVEPOINT Derive_Visit_Task_Times_pvt;

  -- Standard call to check for call compatibility
  IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Begin Processing

  -- Enable Debug (optional)
  Ahl_Debug_Pub.enable_debug;

  -- ASSUMPTIONS:
  --   A Task can appear only once for a given visit (ahl_visit_tasks_b)
  --   A Department can have only one shift (ahl_department_shifts)
  --   Shift_Num is unique in bom_shift_times

  -- Validate Visit Id
  IF (p_visit_id IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ID_NULL');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  ELSE
    OPEN l_validate_visit_csr(p_visit_id);
    FETCH l_validate_visit_csr INTO l_junk;
    IF (l_validate_visit_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ID_INVALID');
      Fnd_Message.Set_Token('VISIT_ID', p_visit_id);
      Fnd_Msg_Pub.ADD;
      CLOSE l_validate_visit_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE l_validate_visit_csr;
  END IF;

  -- Validate Dates
  IF (p_start_time IS NOT NULL AND p_end_time IS NOT NULL AND p_start_time > p_end_time) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_STIME_GT_ETIME');
    Fnd_Message.Set_Token('STIME', p_start_time);
    Fnd_Message.Set_Token('ETIME', p_end_time);
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

  -- Call helper method to do the actual processing
  Ahl_Debug_Pub.debug('Beginning Processing for Visit: ' || p_visit_id, 'LTP:Derive_Visit_Task_Times');
  Derive_Task_Op_Times(
    p_visit_id              => p_visit_id,
    p_start_time            => p_start_time,
    p_end_time              => p_end_time,
    p_department_id         => NULL, -- dummy for compliation purpose
    p_x_tp_dtls_tbl         => l_dummy_table,  -- Dummy Table for Operation Time Periods
    x_visit_start_time      => x_visit_start_time,
    x_visit_end_time        => x_visit_end_time,
    x_visit_end_hour        => x_visit_end_hour,
    x_visit_task_times_tbl  => x_visit_task_times_tbl);

  Ahl_Debug_Pub.debug('Completed Processing. Checking for errors', 'LTP:Derive_Visit_Task_Times');
  -- Check Error Message stack.
  x_msg_count := Fnd_Msg_Pub.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

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

  -- Disable debug (if enabled)
  Ahl_Debug_Pub.disable_debug;
--  dbms_output.put_line('Exiting LTP:Derive_Visit_Task_Times');

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   ROLLBACK TO Derive_Visit_Task_Times_pvt;
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);


 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Derive_Visit_Task_Times_pvt;
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);
   --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

 WHEN OTHERS THEN
    ROLLBACK TO Derive_Visit_Task_Times_pvt;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
       Fnd_Msg_Pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Derive_Visit_Task_Times',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);
    --AHL_UTIL_PKG.Err_Mesg_To_Table(x_err_mesg_tbl);

END Derive_Visit_Task_Times;

-- Start of Comments --
--  Procedure name    : Get_Plan_Resources
--  Type              : Private
--  Function          : Gets the distinct Resources (Name, Type, Code) required by a given
--                      department during a given period for a given Plan
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Plan_Resources Parameters:
--      p_dept_id                       IN      NUMBER       REQUIRED
--         The department that is to be searched for resources
--      p_dept_name                     IN      VARCHAR2     REQUIRED
--         The name of the department (will be mapped to Id if p_dept_id is not given)
--      p_org_name                      IN      VARCHAR2     REQUIRED
--         The name of the organization where the department is
--      p_plan_id                       IN      NUMBER     REQUIRED
--         The id of the plan for which to get the resources
--      p_start_time                    IN      DATE         REQUIRED
--         Start time filter for tasks. Only tasks that are in progress at or after this
--         time will be considered. Tasks that end before this time will be ignored.
--      p_end_time                      IN      DATE         REQUIRED
--         End time filter for tasks. Only tasks that are in progress at or before this
--         time will be considered. Tasks that start after this time will be ignored.
--      x_plan_rsrc_tbl                 OUT  Plan_Rsrc_Tbl_Type
--         The table containing the distinct resources required.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
--
-- This API has been deprecated -yazhou 24Aug2005
--

PROCEDURE Get_Plan_Resources
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_dept_id               IN            NUMBER,
    p_dept_name             IN            VARCHAR2,
    p_org_name              IN            VARCHAR2,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    x_plan_rsrc_tbl         OUT NOCOPY    AHL_LTP_RESRC_LEVL_PVT.Plan_Rsrc_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
) IS

  CURSOR l_dept_id_csr(p_dept_name IN VARCHAR2, p_org_name IN VARCHAR2) IS
    SELECT department_id FROM bom_departments dept, hr_all_organization_units org
    WHERE org.name = p_org_name AND
    dept.ORGANIZATION_ID = org.ORGANIZATION_ID AND
    dept.description = p_dept_name;

  CURSOR l_validate_dept_csr(l_dept_id IN NUMBER) IS
    SELECT 'x' FROM bom_departments WHERE
    department_id = l_dept_id;

   CURSOR l_validate_plan_csr(l_plan_id IN NUMBER) IS
    SELECT 'x' FROM ahl_simulation_plans_b WHERE
    simulation_plan_id = l_plan_id;

  l_api_version     CONSTANT NUMBER := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Plan_Resources';

  l_dept_id         NUMBER := NULL;
  l_junk            VARCHAR2(1);
  l_task_times_tbl  Visit_Task_Times_Tbl_Type;
  l_temp_rsrc_tbl   Plan_Rsrc_Tbl_Type;
  l_dummy_table     Time_Period_Details_Tbl_Type;
  l_required_capacity  NUMBER;
BEGIN
--  dbms_output.put_line('Entering Get_Plan_Resources');
  -- Standard start of API savepoint
  SAVEPOINT Get_Plan_Resources_pvt;

  -- Standard call to check for call compatibility
  IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Enable Debug (optional)
  Ahl_Debug_Pub.enable_debug;

  -- Begin Processing
--  dbms_output.put_line('Begin Processing');
  -- Map Dept Name To Dept Id
  IF (p_module_type = G_JSP_MODULE_TYPE) THEN
--    dbms_output.put_line('JSP Module: Doing Value to ID Conversion');
    OPEN l_dept_id_csr(p_dept_name, p_org_name);
    FETCH l_dept_id_csr INTO l_dept_id;
    IF (l_dept_id_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_INVALID');
      Fnd_Message.Set_Token('DEPT', p_dept_name);
      Fnd_Msg_Pub.ADD;
      CLOSE l_dept_id_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE l_dept_id_csr;
--    dbms_output.put_line('l_dept_id = ' || l_dept_id);
  ELSE
    -- Validate Dept Id
    IF (p_dept_id IS NULL) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_NULL');
      Fnd_Msg_Pub.ADD;
      RAISE  Fnd_Api.G_EXC_ERROR;
    ELSE
      OPEN l_validate_dept_csr(p_dept_id);
      FETCH l_validate_dept_csr INTO l_junk;
      IF (l_validate_dept_csr%NOTFOUND) THEN
        Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_ID_INVALID');
        Fnd_Message.Set_Token('DEPT', p_dept_id);
        Fnd_Msg_Pub.ADD;
        CLOSE l_validate_dept_csr;
        RAISE  Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE l_validate_dept_csr;
    END IF;
    l_dept_id := p_dept_id;
--    dbms_output.put_line('l_dept_id = ' || l_dept_id);
  END IF;

  -- Validate Plan Id
  IF (p_plan_id IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_PLAN_ID_NULL');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  ELSE
    OPEN l_validate_plan_csr(p_plan_id);
    FETCH l_validate_plan_csr INTO l_junk;
    IF (l_validate_plan_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_PLAN_ID_INVALID');
      Fnd_Message.Set_Token('PLAN', p_plan_id);
      Fnd_Msg_Pub.ADD;
      CLOSE l_validate_plan_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE l_validate_plan_csr;
  END IF;
--  dbms_output.put_line('p_plan_id = ' || p_plan_id);

  -- Validate Dates
  IF (p_start_time IS NOT NULL AND p_end_time IS NOT NULL AND p_start_time > p_end_time) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_STIME_GT_ETIME');
    Fnd_Message.Set_Token('STIME', p_start_time);
    Fnd_Message.Set_Token('ETIME', p_end_time);
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

--  dbms_output.put_line('Completed Mapping. Calling Get_Plan_Tasks');
  -- Get all the tasks for the given dept/plan
  -- that are in progress during the given timeframe
  Get_Plan_Tasks(
    p_dept_id              => p_dept_id,
    p_plan_id              => p_plan_id,
    p_start_time           => p_start_time,
    p_end_time             => p_end_time,
    p_inc_primary_flag     => FALSE,  -- No need to include primary plan tasks even if this plan is a simulation
--    p_op_times_flag        => FALSE,  -- No need to get Operation Time Period details
    x_tp_dtls_tbl          => l_dummy_table, -- Dummy Table for Operation Time Period details
    x_visit_task_times_tbl => l_task_times_tbl);

--  dbms_output.put_line('Completed Get_Plan_Tasks. Calling Get_Task_Resources');
--  dbms_output.put_line('l_task_times_tbl.Count = ' || l_task_times_tbl.COUNT);
  -- Get Distinct Resources for all valid visits/tasks
  IF (l_task_times_tbl.COUNT > 0) THEN
    FOR i IN l_task_times_tbl.FIRST .. l_task_times_tbl.LAST LOOP
      Get_Task_Resources(
        p_required_capacity    => l_required_capacity,
      p_task_id              => l_task_times_tbl(i).VISIT_TASK_ID,
        p_tstart_date      => 'SYSDATE',
        p_tend_date        => 'SYSDATE',
        p_distinct_flag        => TRUE,
        p_x_task_rsrc_tbl      => l_temp_rsrc_tbl);
    END LOOP;
  END IF;

  -- Assign output parameters with locally generated table
  x_plan_rsrc_tbl := l_temp_rsrc_tbl;

  Ahl_Debug_Pub.debug('Completed Processing. Checking for errors', 'LTP');
  -- Check Error Message stack.
  x_msg_count := Fnd_Msg_Pub.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

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

  -- Disable debug (if enabled)
  Ahl_Debug_Pub.disable_debug;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   ROLLBACK TO Get_Plan_Resources_pvt;
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Get_Plan_Resources_pvt;
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    ROLLBACK TO Get_Plan_Resources_pvt;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
       Fnd_Msg_Pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Plan_Resources',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);

END Get_Plan_Resources;

-- Start of Comments --
--  Procedure name    : Get_Rsrc_Req_By_Period
--  Type              : Private
--  Function          : Gets the Requirements and Availability of a Resource
--                      by periods for a given department, during a given period,
--                      for a given Plan
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Plan_Resources Parameters:
--      p_dept_id                       IN      NUMBER       REQUIRED
--         The department that is to be searched for resources
--      p_dept_name                     IN      VARCHAR2     REQUIRED
--         The name of the department (will be mapped to Id if p_dept_id is not given)
--      p_org_name                      IN      VARCHAR2     REQUIRED
--         The name of the organization where the department is
--      p_plan_id                       IN      NUMBER     REQUIRED
--         The id of the plan for which to get the resources
--      p_start_time                    IN      DATE         REQUIRED
--         Start time filter for tasks. Only tasks that are in progress at or after this
--         time will be considered. Tasks that end before this time will be ignored.
--      p_end_time                      IN      DATE         REQUIRED
--         End time filter for tasks. Only tasks that are in progress at or before this
--         time will be considered. Tasks that start after this time will be ignored.
--      p_UOM_id                        IN      NUMBER     REQUIRED
--         The id of the Period's unit of Measure (Days, Weeks, Months etc.)
--      p_resource_id                   IN      NUMBER     REQUIRED
--         The id of the Resource whose requirements/Availabilities are to be derived
--      p_aso_bom_rsrc_type             IN      VARCHAR2    REQUIRED
--         The type of the resource (ASORESOURCE or BOMRESOURCE)
--      x_per_rsrc_tbl                  OUT  Period_Rsrc_Req_Tbl_Type
--         The table containing the distinct resources required.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.

PROCEDURE Get_Rsrc_Req_By_Period
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_dept_id               IN            NUMBER,
    p_dept_name             IN            VARCHAR2,
    p_org_name              IN            VARCHAR2,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_UOM_code              IN            VARCHAR2,
    p_required_capacity     IN            NUMBER,
    x_per_rsrc_tbl          OUT NOCOPY  Ahl_Ltp_Resrc_Levl_Pvt.Period_Rsrc_Req_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
) IS

  /* Renamed l_dept_id_csr0 to l_dept_id_csr by mpothuku on 01/18/05
     Also added the exists condition to retrieve only departments with shifts
  */

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- Added department name as Select field

  CURSOR l_dept_id_csr(p_dept_name IN VARCHAR2, p_org_name IN VARCHAR2) IS
    SELECT department_id, org.organization_id, dept.description dept_name
    FROM bom_departments dept, hr_all_organization_units org
    WHERE org.name = p_org_name AND
    dept.ORGANIZATION_ID = org.ORGANIZATION_ID AND
  EXISTS ( SELECT 'x' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = dept.DEPARTMENT_ID) AND
    (  (p_dept_name is not null and dept.description = p_dept_name)
     or p_dept_name is null ) ;

-- yazhou 24Aug2005 ends

  /* Added the exists condition to retrieve only departments with shifts */
  CURSOR l_validate_dept_csr(l_dept_id IN NUMBER) IS
    SELECT description FROM bom_departments WHERE
    department_id = l_dept_id and exists ( SELECT 'x' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = bom_departments.DEPARTMENT_ID);
  --
  CURSOR l_validate_org_csr(l_org_name IN VARCHAR2) IS
    SELECT name FROM hr_all_organization_units WHERE
    name = l_org_name;
  --
  CURSOR l_validate_plan_csr(l_plan_id IN NUMBER) IS
    SELECT 'x' FROM ahl_simulation_plans_b WHERE
    simulation_plan_id = l_plan_id;
  --

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

  CURSOR l_resource_dtl_csr (l_resource_id IN NUMBER) IS
   SELECT d.resource_code,
          d.description,
          d.resource_type,
          m.meaning resource_type_mean
     FROM bom_resources d,  mfg_lookups m
    WHERE d.resource_id = l_resource_id
      AND d.resource_type = m.lookup_code
      AND m.lookup_type = 'BOM_RESOURCE_TYPE';

-- yazhou 24Aug2005 ends

  l_api_version     CONSTANT NUMBER := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Rsrc_Req_By_Period';
  l_return_status    VARCHAR2(1);
  l_msg_data         VARCHAR2(200);
  l_msg_count        NUMBER;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

  l_available_quantity   NUMBER;
  l_required_quantity    NUMBER;
  l_unused_capacity      NUMBER;
  l_dept_id              NUMBER := NULL;
  l_org_id               NUMBER := NULL;
  l_department_name       bom_departments.description%type;
  l_period_start_time    DATE;
  l_period_end_time      DATE;

  l_idx                  NUMBER := 0;

  l_task_times_tbl  Visit_Task_Times_Tbl_Type;
  l_tp_dtls_table   Time_Period_Details_Tbl_Type;
  l_tp_dtls_table_dept   Time_Period_Details_Tbl_Type;
  l_tp_dtls_table_resc   Time_Period_Details_Tbl_Type;
  l_per_rsrc_tbl        Period_Rsrc_Req_Tbl_Type;
  l_resc_tbl       Resource_Tbl_Type;

  l_resource_dtl_rec    l_resource_dtl_csr%rowtype;
-- yazhou 24Aug2005 ends

  l_name           HR_ALL_ORGANIZATION_UNITS.NAME%TYPE;
  l_deprt_id        NUMBER;
  l_orga_id         NUMBER;
  l_junk            VARCHAR2(1);
  l_dept_name       bom_departments.description%type;

BEGIN
  -- Standard start of API savepoint
  SAVEPOINT Get_Rsrc_Req_By_Period_pvt;

  -- Standard call to check for call compatibility
  IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Enable Debug (optional)
  Ahl_Debug_Pub.enable_debug;

  -- Begin Processing

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- Added Organization, start and end date mandatory check

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_plan_id:'||p_plan_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_start_time:'||TO_CHAR( p_start_time, 'DD-MON-YYYY hh24:mi')
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_end_time:'||TO_CHAR( p_end_time, 'DD-MON-YYYY hh24:mi')
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_UOM_code:'||p_UOM_code
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_org_name:'||p_org_name
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_dept_name:'||p_dept_name
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_required_capacity:'||p_required_capacity
        );
     END IF;

  IF (p_org_name IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_ORG_MAN_JSP');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

  IF (p_start_time IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_STARTDATE_MAN_JSP');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

  IF (p_end_time IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_ENDDATE_MAN_JSP');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

  IF (TRUNC(p_start_time) < TRUNC(SYSDATE) ) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_INVALID_START_DATE');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

  IF (TRUNC(p_end_time) < TRUNC(SYSDATE) ) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_INVALID_END_DATE');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;
-- yazhou 24Aug2005 ends

  -- Map Dept Name To Dept Id
IF (p_module_type = G_JSP_MODULE_TYPE) THEN
--    dbms_output.put_line('JSP MODULE: Doing Value TO ID Conversion');
 -- validate org name
  OPEN l_validate_org_csr(p_org_name);
  FETCH l_validate_org_csr INTO l_name;
  IF (l_validate_org_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_ORG_ID_INVALID');
      Fnd_Message.Set_Token('ORG', p_org_name);
      Fnd_Msg_Pub.ADD;
    CLOSE l_validate_org_csr;
     RAISE  Fnd_Api.G_EXC_ERROR;
   END IF;
  --
  CLOSE l_validate_org_csr;
  -- Validate dept name
  OPEN l_dept_id_csr(p_dept_name,p_org_name);
  FETCH l_dept_id_csr INTO l_deprt_id,l_orga_id, l_department_name;
  IF (l_dept_id_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_INV_OR_NO_SFT');
      Fnd_Message.Set_Token('DEPT', p_dept_name);
      Fnd_Msg_Pub.ADD;
     CLOSE l_dept_id_csr;
   RAISE  Fnd_Api.G_EXC_ERROR;
   END IF;
   CLOSE l_dept_id_csr;
   --
   l_dept_name := p_dept_name;

ELSE
-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- removed the code to throw exception when p_dept_id is null

    -- Validate Dept Id
    IF (p_dept_id IS NOT NULL) THEN
      OPEN l_validate_dept_csr(p_dept_id);
      FETCH l_validate_dept_csr INTO l_dept_name;
      IF (l_validate_dept_csr%NOTFOUND) THEN
        Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_INV_OR_NO_SFT');
        Fnd_Message.Set_Token('DEPT', p_dept_id);
        Fnd_Msg_Pub.ADD;
        CLOSE l_validate_dept_csr;
        RAISE  Fnd_Api.G_EXC_ERROR;
      END IF;
    END IF;

-- yazhou 24Aug2005 ends

  END IF;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- Moved out of department loop

  -- Validate Plan Id
  IF (p_plan_id IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_PLAN_ID_NULL');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  ELSE
    OPEN l_validate_plan_csr(p_plan_id);
    FETCH l_validate_plan_csr INTO l_junk;
    IF (l_validate_plan_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_PLAN_ID_INVALID');
      Fnd_Message.Set_Token('PLAN', p_plan_id);
      Fnd_Msg_Pub.ADD;
      CLOSE l_validate_plan_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE l_validate_plan_csr;
  END IF;

--  dbms_output.put_line('p_plan_id = ' || p_plan_id);
  Ahl_Debug_Pub.debug('p_plan_id = ' || p_plan_id);

  -- Validate Dates
  IF (p_start_time IS NOT NULL AND p_end_time IS NOT NULL AND p_start_time > p_end_time) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_STIME_GT_ETIME');
    Fnd_Message.Set_Token('STIME', p_start_time);
    Fnd_Message.Set_Token('ETIME', p_end_time);
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

-- yazhou 24Aug2005 ends

--
-- Check for each department in the given organization
--
FOR var in l_dept_id_csr( l_dept_name , p_org_name) LOOP

     l_dept_id := var.department_id;
     l_org_id  := var.organization_id;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
     l_department_name := var.dept_name;
-- yazhou 24Aug2005 ends

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_org_id:'||l_org_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_dept_id:'||l_dept_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_department_name:'||l_department_name
        );
     END IF;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

  -- Get all the tasks for the given dept/plan
  -- that are in progress during the given timeframe
  -- since p_end_date is surfixed with "00:00", to include resources for the end date
   -- increase the date by 1
  Get_Plan_Tasks(
    p_dept_id              => l_dept_id,
    p_plan_id              => p_plan_id,
    p_start_time           => p_start_time,
    p_end_time             => p_end_time+1,
    p_inc_primary_flag     => TRUE,  -- Need to include primary plan tasks if this plan is a simulation
--    p_op_times_flag        => TRUE,  -- Need to get Operation Time Period details
    x_tp_dtls_tbl          => l_tp_dtls_table, -- Table for Operation Time Period details
    x_visit_task_times_tbl => l_task_times_tbl);

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'After calling Get_Plan_Tasks'
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_tp_dtls_table.COUNT:'||l_tp_dtls_table.COUNT
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_task_times_tbl.COUNT:'||l_task_times_tbl.COUNT
        );
  END IF;

 -- continue only if there are requirements for this department
 IF l_tp_dtls_table.count>0 THEN
  -- Create the timeperiods table for output
  -- since p_end_date is surfixed with "00:00", to create time periods that includes
  -- the end date, increase the date by 1
  Create_Time_Periods(
    p_start_time     => p_start_time,
    p_end_time       => p_end_time+1,
    p_UOM_code       => p_UOM_code,
    p_org_id         => l_org_id,
    p_dept_id        => l_dept_id,
    x_per_rsrc_tbl   => l_per_rsrc_tbl);

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'After calling Create_Time_Periods'
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_per_rsrc_tbl.COUNT:'||l_per_rsrc_tbl.COUNT
        );
  END IF;

  -- For each time period, get all the resources required for the given department

  IF l_per_rsrc_tbl.COUNT > 0 THEN
   FOR i IN l_per_rsrc_tbl.FIRST..l_per_rsrc_tbl.LAST LOOP

     l_period_start_time := l_per_rsrc_tbl(i).period_start;
     l_period_end_time   := l_per_rsrc_tbl(i).period_end;

     l_tp_dtls_table_dept := l_tp_dtls_table;

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_per_rsrc_tbl('||i||').period_start:'||TO_CHAR( l_period_start_time, 'DD-MON-YYYY hh24:mi')
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_per_rsrc_tbl('||i||').period_end:'||TO_CHAR( l_period_end_time, 'DD-MON-YYYY hh24:mi')
        );
     END IF;

     -- Get all the resources that are used in the given period for the given department
     -- by tasks in Planning
     Get_Used_Resources(
        p_dept_id              => l_dept_id,
        p_start_date           => l_period_start_time,
        p_end_date             => l_period_end_time,
        p_tp_dtls_tbl          => l_tp_dtls_table_dept,
        x_resources_tbl        => l_resc_tbl);

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'After calling Get_Used_Resources'
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_resc_tbl.COUNT:'||l_resc_tbl.COUNT
        );
     END IF;

     -- For each resource, check for required quantity and calculate availability capacity
     IF l_resc_tbl.COUNT > 0 THEN
      FOR j IN l_resc_tbl.FIRST..l_resc_tbl.LAST LOOP

        l_tp_dtls_table_resc := l_tp_dtls_table_dept;

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string
           (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
              'l_resc_tbl('||j||'):' || l_resc_tbl(j)
           );
        END IF;

        -- Filter resource requirements table to get only those for the given resource,
        -- given period and given department
        Filter_By_Resource(
           p_resource_id    =>l_resc_tbl(j),
         p_start_time     =>l_period_start_time,
         p_end_time       =>l_period_end_time,
           p_x_tp_dtls_tbl  =>l_tp_dtls_table_resc);

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string
           (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
              'After Calling Filter_By_Resource'
           );
           fnd_log.string
           (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
              'l_tp_dtls_table_resc.count: ' ||l_tp_dtls_table_resc.count
           );
        END IF;

        -- Populate output table only if there are resource requirements by tasks
        IF l_tp_dtls_table_resc.COUNT>0 THEN

          -- Add resource requirements by WIP job for the same department, resource, period
          Append_WIP_Requirements(
             p_org_id          => l_org_id,
             p_dept_id         => l_dept_id,
             p_start_date      => l_period_start_time,
             p_end_date        => l_period_end_time,
             p_resource_id     => l_resc_tbl(j),
             p_x_tp_dtls_tbl   => l_tp_dtls_table_resc);

          IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
              'After Calling Append_WIP_Requirements'
            );
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
              'l_tp_dtls_table_resc.count: ' ||l_tp_dtls_table_resc.count
            );
          END IF;

          l_required_quantity := Get_Required_Quantity(
                                  p_start_time     =>l_period_start_time,
                                  p_end_time       =>l_period_end_time,
                                    p_tp_dtls_tbl    =>l_tp_dtls_table_resc);

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                'l_required_quantity:'||l_required_quantity
             );
          END IF;

          l_available_quantity := Get_Available_Units(
                                    p_resource_id  =>l_resc_tbl(j),
                                    p_dept_id      =>l_dept_id);

          IF (l_log_statement >= l_log_current_level) THEN
              fnd_log.string
             (
                fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                'l_available_quantity:'||l_available_quantity
             );
          END IF;

         IF (l_available_quantity >0 AND l_required_quantity>0 ) THEN

             l_unused_capacity := (1-(l_required_quantity/l_available_quantity))*100;

             IF (l_log_statement >= l_log_current_level) THEN
                fnd_log.string
               (
                 fnd_log.level_statement,
                'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                'l_unused_capacity:'||l_unused_capacity
               );
             END IF;

             IF l_unused_capacity <= p_required_capacity THEN

                x_per_rsrc_tbl(l_idx).resource_id            := l_resc_tbl(j);
                x_per_rsrc_tbl(l_idx).capacity_units         := round(l_unused_capacity);
                x_per_rsrc_tbl(l_idx).period_start           := l_period_start_time;
                x_per_rsrc_tbl(l_idx).period_end             := l_period_end_time;
                x_per_rsrc_tbl(l_idx).period_string          := l_per_rsrc_tbl(i).period_string;
                x_per_rsrc_tbl(l_idx).DEPARTMENT_ID          := l_dept_id;
                x_per_rsrc_tbl(l_idx).REQUIRED_UNITS         := l_required_quantity;
                x_per_rsrc_tbl(l_idx).AVAILABLE_UNITS       := l_available_quantity;
                x_per_rsrc_tbl(l_idx).dept_description       := l_department_name;

                -- Populate resource name, type code, type meaning and description
                OPEN l_resource_dtl_csr(l_resc_tbl(j));
                FETCH l_resource_dtl_csr into l_resource_dtl_rec;
                CLOSE l_resource_dtl_csr;

                x_per_rsrc_tbl(l_idx).resource_type          := l_resource_dtl_rec.RESOURCE_TYPE;
                x_per_rsrc_tbl(l_idx).resource_type_meaning  := l_resource_dtl_rec.RESOURCE_TYPE_MEAN;
                x_per_rsrc_tbl(l_idx).resource_name          := l_resource_dtl_rec.RESOURCE_CODE;
                x_per_rsrc_tbl(l_idx).resource_description   := l_resource_dtl_rec.DESCRIPTION;

                l_idx := l_idx +1;

                IF (l_log_statement >= l_log_current_level) THEN
                   fnd_log.string
                  (
                    fnd_log.level_statement,
                   'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                   'l_idx:'||l_idx
                  );
                END IF;

            END IF;--l_unused_capacity <= p_required_capacity

          END IF;  -- l_available_quantity >0 AND l_required_quantity>0
        END IF; --l_tp_dtls_table_resc.COUNT>0
      END LOOP; --l_resc_tbl.LOOP
     END IF; -- l_resc_tbl.count
   END LOOP; --l_per_rsrc_tbl.LOOP
  END IF; -- l_per_rsrc_tbl.count
 END IF; --l_tp_dtls_table.count>0

-- yazhou 24Aug2005 ends

END LOOP; --dept id

  -- Check Error Message stack.

  x_msg_count := Fnd_Msg_Pub.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;


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

  -- Disable debug (if enabled)
  Ahl_Debug_Pub.disable_debug;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   ROLLBACK TO Get_Rsrc_Req_By_Period_pvt;
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Get_Rsrc_Req_By_Period_pvt;
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    ROLLBACK TO Get_Rsrc_Req_By_Period_pvt;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
       Fnd_Msg_Pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Rsrc_Req_By_Period',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);

END Get_Rsrc_Req_By_Period;


-- Start of Comments --
--  Procedure name    : Get_Task_Requirements
--  Type              : Private
--  Function          : Gets the Requirements of a Resource by Visit/Task
--                      for a given department, during a given period,
--                      for a given Plan
--  Pre-reqs    :
--  Parameters  :
--
--  Standard IN  Parameters :
--      p_api_version                   IN      NUMBER       Required
--      p_init_msg_list                 IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_commit                        IN      VARCHAR2     Default  FND_API.G_FALSE
--      p_validation_level              IN      NUMBER       Default  FND_API.G_VALID_LEVEL_FULL
--      p_default                       IN      VARCHAR2     Default  FND_API.G_TRUE
--      p_module_type                   IN      VARCHAR2     Default  NULL.
--
--  Standard OUT Parameters :
--      x_return_status                 OUT     VARCHAR2     Required
--      x_msg_count                     OUT     NUMBER       Required
--      x_msg_data                      OUT     VARCHAR2     Required
--
--  Get_Plan_Resources Parameters:
--      p_dept_id                       IN      NUMBER       REQUIRED
--         The department that is to be searched for resources
--      p_dept_name                     IN      VARCHAR2     REQUIRED
--         The name of the department (will be mapped to Id if p_dept_id is not given)
--      p_org_name                      IN      VARCHAR2     REQUIRED
--         The name of the organization where the department is
--      p_plan_id                       IN      NUMBER     REQUIRED
--         The id of the plan for which to get the resources
--      p_start_time                    IN      DATE         REQUIRED
--         Start time filter for tasks. Only tasks that are in progress at or after this
--         time will be considered. Tasks that end before this time will be ignored.
--      p_end_time                      IN      DATE         REQUIRED
--         End time filter for tasks. Only tasks that are in progress before this
--         time will be considered. Tasks that start at or after this time will be ignored.
--      p_resource_id                   IN      NUMBER     REQUIRED
--         The id of the Resource whose requirements/Availabilities are to be derived
--      p_aso_bom_rsrc_type             IN      VARCHAR2    REQUIRED
--         The type of the resource (ASORESOURCE or BOMRESOURCE)
--      x_task_req_tbl                  OUT     Task_Requirement_Tbl_Type
--         The table containing the resource requirements.
--
--  Version :
--      Initial Version   1.0
--
--  End of Comments.
PROCEDURE Get_Task_Requirements
(
    p_api_version           IN            NUMBER,
    p_init_msg_list         IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_commit                IN            VARCHAR2  := Fnd_Api.G_FALSE,
    p_validation_level      IN            NUMBER    := Fnd_Api.G_VALID_LEVEL_FULL,
    p_default               IN            VARCHAR2  := Fnd_Api.G_TRUE,
    p_module_type           IN            VARCHAR2  := NULL,
    p_dept_id               IN            NUMBER,
    p_dept_name             IN            VARCHAR2,
    p_org_name              IN            VARCHAR2,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_dstart_time           IN            DATE,
    p_dend_time             IN            DATE,
    p_resource_id           IN            NUMBER,
    p_aso_bom_rsrc_type     IN            VARCHAR2,
    x_task_req_tbl          OUT  NOCOPY  AHL_LTP_RESRC_LEVL_PVT.Task_Requirement_Tbl_Type,
    x_return_status         OUT NOCOPY           VARCHAR2,
    x_msg_count             OUT NOCOPY           NUMBER,
    x_msg_data              OUT NOCOPY           VARCHAR2
) IS


 /* Modified l_dept_id_csr by mpothuku on 01/18/05
     to add the exists condition to retrieve only department with shifts
  */

  CURSOR l_dept_id_csr(p_dept_name IN VARCHAR2, p_org_name IN VARCHAR2) IS
    SELECT department_id,org.organization_id FROM bom_departments dept, hr_all_organization_units org
    WHERE org.name = p_org_name AND
    dept.ORGANIZATION_ID = org.ORGANIZATION_ID AND
    dept.description = p_dept_name and exists ( SELECT 'x' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = dept.DEPARTMENT_ID);

  /* Added the exists condition to retrieve only departments with shifts */
  CURSOR l_validate_dept_csr(l_dept_id IN NUMBER) IS
    SELECT 'x' FROM bom_departments WHERE
    department_id = l_dept_id and exists ( SELECT 'x' FROM AHL_DEPARTMENT_SHIFTS WHERE DEPARTMENT_ID = bom_departments.DEPARTMENT_ID);

   CURSOR l_validate_plan_csr(l_plan_id IN NUMBER) IS
    SELECT 'x' FROM ahl_simulation_plans_b WHERE
    simulation_plan_id = l_plan_id;


  l_api_version     CONSTANT NUMBER := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Task_Requirements';

  l_dept_id         NUMBER := NULL;
  l_org_id          NUMBER;
  l_junk            VARCHAR2(1);
  l_task_times_tbl  Visit_Task_Times_Tbl_Type;
  l_temp_rsrc_tbl   Plan_Rsrc_Tbl_Type;
  l_tp_dtls_table     Time_Period_Details_Tbl_Type;
  l_start_time      DATE;
  l_end_time        DATE;
  l_aso_resource_id NUMBER;
BEGIN
--  dbms_output.put_line('Entering Get_Task_Requirements');
  -- Standard start of API savepoint
  SAVEPOINT Get_Task_Requirements_pvt;

  -- Standard call to check for call compatibility
  IF NOT Fnd_Api.Compatible_API_Call(l_api_version, p_api_version, l_api_name,
                                     G_PKG_NAME) THEN
    RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
  IF Fnd_Api.To_Boolean(p_init_msg_list) THEN
    Fnd_Msg_Pub.Initialize;
  END IF;

  -- Initialize API return status to success
  x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

  -- Enable Debug (optional)
  Ahl_Debug_Pub.enable_debug;

  -- Begin Processing
--  dbms_output.put_line('BEGIN Processing');
  -- Map Dept Name To Dept Id
  IF (p_module_type = G_JSP_MODULE_TYPE) THEN
--    dbms_output.put_line('JSP MODULE: Doing Value TO ID Conversion');
    OPEN l_dept_id_csr(p_dept_name, p_org_name);
    FETCH l_dept_id_csr INTO l_dept_id,l_org_id;
    IF (l_dept_id_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_INV_OR_NO_SFT');
      Fnd_Message.Set_Token('DEPT', p_dept_name);
      Fnd_Msg_Pub.ADD;
      CLOSE l_dept_id_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE l_dept_id_csr;
--    dbms_output.put_line('l_dept_id = ' || l_dept_id);
  ELSE
    -- Validate Dept Id
    IF (p_dept_id IS NULL) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_NULL');
      Fnd_Msg_Pub.ADD;
      RAISE  Fnd_Api.G_EXC_ERROR;
    ELSE
      OPEN l_validate_dept_csr(p_dept_id);
      FETCH l_validate_dept_csr INTO l_junk;
      IF (l_validate_dept_csr%NOTFOUND) THEN
        Fnd_Message.Set_Name('AHL','AHL_LTP_DEPT_INV_OR_NO_SFT');
        Fnd_Message.Set_Token('DEPT', p_dept_id);
        Fnd_Msg_Pub.ADD;
        CLOSE l_validate_dept_csr;
        RAISE  Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE l_validate_dept_csr;
    END IF;
    l_dept_id := p_dept_id;
--    dbms_output.put_line('l_dept_id = ' || l_dept_id);
  END IF;

  -- Validate Plan Id
  IF (p_plan_id IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_PLAN_ID_NULL');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  ELSE
    OPEN l_validate_plan_csr(p_plan_id);
    FETCH l_validate_plan_csr INTO l_junk;
    IF (l_validate_plan_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_PLAN_ID_INVALID');
      Fnd_Message.Set_Token('PLAN', p_plan_id);
      Fnd_Msg_Pub.ADD;
      CLOSE l_validate_plan_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE l_validate_plan_csr;
  END IF;
--  dbms_output.put_line('p_plan_id = ' || p_plan_id);

  -- Validate Dates
  IF (p_start_time IS NOT NULL AND p_end_time IS NOT NULL AND p_start_time > p_end_time) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_STIME_GT_ETIME');
    Fnd_Message.Set_Token('STIME', p_start_time);
    Fnd_Message.Set_Token('ETIME', p_end_time);
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

--  dbms_output.put_line('Completed Mapping. Calling Get_Plan_Tasks');
--  l_start_time := trunc(p_start_time);
--  l_end_time := trunc(p_start_time) + 1;

  -- Get all the tasks for the given dept/plan
  -- that are in progress during the given timeframe
  Get_Plan_Tasks(
    p_dept_id              => p_dept_id,
    p_plan_id              => p_plan_id,
    p_start_time           => p_start_time,
    p_end_time             => p_end_time,
    p_inc_primary_flag     => TRUE,  -- Need to include primary plan tasks if this plan is a simulation
--    p_op_times_flag        => TRUE,  -- Need to get Operation Time Period details
    x_tp_dtls_tbl          => l_tp_dtls_table, -- Table for Operation Time Period details
    x_visit_task_times_tbl => l_task_times_tbl);

  --  dbms_output.put_line('Completed Get_Plan_Tasks. Calling Filter_By_Resource');
  Ahl_Debug_Pub.debug('before call filter l_tp_dtls_table.COUNT = ' || l_tp_dtls_table.COUNT);
  Ahl_Debug_Pub.debug('p_resource_id = ' || p_resource_id);
  Ahl_Debug_Pub.debug('p_strat_time = ' || p_start_time);
  Ahl_Debug_Pub.debug('p_end_time   = ' || p_end_time);

  -- Filter by the required resource and get quantity
  Filter_By_Resource(
    p_resource_id    => p_resource_id,
  p_start_time     => p_dstart_time,
  p_end_time       => p_dend_time,
    p_x_tp_dtls_tbl  => l_tp_dtls_table);

--  dbms_output.put_line('l_tp_dtls_table.COUNT = ' || l_tp_dtls_table.COUNT);

  Ahl_Debug_Pub.debug('l_tp_dtls_tablafter filter = ' || l_tp_dtls_table.COUNT);

  -- Sort By Visit, Task
  Sort_By_Visit_Task(l_tp_dtls_table);

  Ahl_Debug_Pub.debug('after sort by visit = ' || l_tp_dtls_table.COUNT);

  -- Aggregate task quantities and get visit and task names into output table
  Aggregate_Task_Quantities(p_resource_id,p_org_name, p_dept_name, l_tp_dtls_table, x_task_req_tbl);

  Ahl_Debug_Pub.debug('x_task_req_tbl.COUNT = ' || x_task_req_tbl.COUNT);

--  dbms_output.put_line('x_task_req_tbl.COUNT = ' || x_task_req_tbl.COUNT);
  Ahl_Debug_Pub.debug('Completed Processing. Checking FOR errors', 'LTP');
  -- Check Error Message stack.
  x_msg_count := Fnd_Msg_Pub.count_msg;
  IF x_msg_count > 0 THEN
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

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

  -- Disable debug (if enabled)
  Ahl_Debug_Pub.disable_debug;

EXCEPTION
 WHEN Fnd_Api.G_EXC_ERROR THEN
   ROLLBACK TO Get_Task_Requirements_pvt;
   x_return_status := Fnd_Api.G_RET_STS_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Get_Task_Requirements_pvt;
   x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
   Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                              p_data  => x_msg_data,
                              p_encoded => Fnd_Api.g_false);

 WHEN OTHERS THEN
    ROLLBACK TO Get_Task_Requirements_pvt;
    x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
    IF Fnd_Msg_Pub.check_msg_level(Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR) THEN
       Fnd_Msg_Pub.add_exc_msg(p_pkg_name       => G_PKG_NAME,
                               p_procedure_name => 'Get_Task_Requirements',
                               p_error_text     => SUBSTR(SQLERRM,1,240));
    END IF;
    Fnd_Msg_Pub.count_and_get( p_count => x_msg_count,
                               p_data  => x_msg_data,
                               p_encoded => Fnd_Api.g_false);

END Get_Task_Requirements;

----------------------------------------
-- Local Procedure Definitions follow --
----------------------------------------
----------------------------------------
-- Gets all the tasks and their times for all visits
-- for a given plan and department during a given period
-- If current plan is a simulation and the p_inc_primary flag is 'Y'
-- Visits in primary plan are also included.
----------------------------------------

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- changed x_visit_task_times_tbl from in out parameter to out parameter only
-- removed p_op_times_flag
PROCEDURE Get_Plan_Tasks
(
    p_dept_id               IN            NUMBER,
    p_plan_id               IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_inc_primary_flag      IN            BOOLEAN := FALSE,
    x_tp_dtls_tbl           OUT NOCOPY Time_Period_Details_Tbl_Type,
    x_visit_task_times_tbl  OUT NOCOPY    Visit_Task_Times_Tbl_Type
) IS

  -- Should include visits with tasks in given department as well as
  -- those visits with given department
  CURSOR l_get_plan_visits(p_dept_id  IN NUMBER,
                           p_plan_id  IN NUMBER,
                           p_start_time IN DATE,
                           p_end_time IN DATE) IS
    SELECT VISIT_ID
    FROM ahl_visits_b v
    WHERE (DEPARTMENT_ID = p_dept_id OR
           (DEPARTMENT_ID is not null and exists (select 1
                                                FROM ahl_visit_tasks_b
                                                where visit_id =v.visit_id
                                                AND department_id =p_dept_id
                                                AND nvl(status_code,'x') ='PLANNING'))) AND
    SIMULATION_PLAN_ID = p_plan_id AND
    STATUS_CODE IN ('PLANNING','PARTIALLY RELEASED') AND
    START_DATE_TIME IS NOT NULL AND
    trunc(START_DATE_TIME) <= p_end_time AND
    AHL_VWP_TIMES_PVT.get_visit_end_time(visit_id) >=p_start_time AND
    SIMULATION_DELETE_FLAG = 'N';

  CURSOR l_get_primary_visits(p_dept_id  IN NUMBER,
                              p_plan_id  IN NUMBER,
                              p_start_time IN DATE,
                              p_end_time IN DATE) IS
    SELECT VISIT_ID
    FROM ahl_visits_b a
    WHERE (DEPARTMENT_ID = p_dept_id OR
           (DEPARTMENT_ID is not null and exists (select 1
                                                FROM ahl_visit_tasks_b
                                                where visit_id =a.visit_id
                                                AND department_id =p_dept_id
                                                AND nvl(status_code,'x') ='PLANNING'))) AND
    SIMULATION_PLAN_ID IN (SELECT SIMULATION_PLAN_ID FROM ahl_simulation_plans_b WHERE
                           PRIMARY_PLAN_FLAG = G_PLAN_TYPE_PRIMARY) AND
    NOT EXISTS (SELECT 1 FROM ahl_visits_b  WHERE SIMULATION_PLAN_ID = p_plan_id
                                              AND ASSO_PRIMARY_VISIT_ID = a.VISIT_ID) AND
    STATUS_CODE IN ('PLANNING','PARTIALLY RELEASED') AND
    START_DATE_TIME IS NOT NULL AND
    trunc(START_DATE_TIME) <= p_end_time AND
    AHL_VWP_TIMES_PVT.get_visit_end_time(visit_id) >=p_start_time;

-- yazhou 24Aug2005 ends

  CURSOR l_get_plan_type_csr(p_plan_id IN NUMBER) IS
    SELECT PRIMARY_PLAN_FLAG FROM ahl_simulation_plans_b
    WHERE SIMULATION_PLAN_ID = p_plan_id;

  l_api_version     CONSTANT NUMBER := 1.0;
  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Plan_Tasks';

  l_temp_times_tbl  Visit_Task_Times_Tbl_Type;
  l_final_times_tbl Visit_Task_Times_Tbl_Type;
  l_temp_index      NUMBER := 1;
  l_temp_visit      NUMBER;
  l_temp_sttime     DATE;
  l_temp_endtime    DATE;
  l_return_status  VARCHAR2(1);
  l_msg_count NUMBER;
  l_msg_data VARCHAR2(1000);
  l_temp_num1 NUMBER;
  l_plan_type VARCHAR2(30);
  l_end_time   DATE := trunc(p_end_time);

BEGIN

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_start_time:'||p_start_time
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_end_time:'||l_end_time
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_dept_id:'||p_dept_id
        );

  END IF;

  OPEN l_get_plan_visits(p_dept_id, p_plan_id, p_start_time,l_end_time);
  LOOP
    FETCH l_get_plan_visits INTO l_temp_visit;
    EXIT WHEN l_get_plan_visits%NOTFOUND;

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_temp_visit:'||l_temp_visit
        );
     END IF;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

-- removed the logic to check for mr route ID
--since now that's done inside Derive_Task_Op_Times already

     -- Call helper method to do the actual processing
     Derive_Task_Op_Times(
      p_visit_id              => l_temp_visit,
      p_start_time            => p_start_time,
      p_end_time              => p_end_time,
      p_department_id         => p_dept_id,
      p_x_tp_dtls_tbl         => x_tp_dtls_tbl, -- Table for Operation Time Periods
      x_visit_start_time      => l_temp_sttime,
      x_visit_end_time        => l_temp_endtime,
      x_visit_end_hour        => l_temp_num1,
      x_visit_task_times_tbl  => l_final_times_tbl);

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'After calling Derive_Task_Op_Times'
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_final_times_tbl.count: '|| l_final_times_tbl.count
        );
     END IF;

/*
     -- Collect the task info for the current visit into the master tasks table
     IF (l_temp_times_tbl.COUNT > 0) THEN

      l_temp_num1 := l_temp_times_tbl.FIRST;

      WHILE l_temp_num1 IS NOT NULL LOOP
        IF l_temp_times_tbl(l_temp_num1).mr_route_id IS NOT NULL
    THEN
        l_final_times_tbl(l_temp_index) := l_temp_times_tbl(l_temp_num1);
        l_temp_index := l_temp_index + 1;

        END IF;
    l_temp_num1 := l_temp_times_tbl.NEXT(l_temp_num1);
      END LOOP;  -- All valid tasks for current visit
    END IF;

*/
-- yazhou 24Aug2005 ends

  END LOOP;  -- All valid visits for current dept
  CLOSE l_get_plan_visits;


  IF (p_inc_primary_flag) THEN
    -- Need to include primary plan visits also
--    dbms_output.put_line('Getting PRIMARY Plans Visits');
    OPEN l_get_plan_type_csr(p_plan_id);
    FETCH l_get_plan_type_csr INTO l_plan_type;
    CLOSE l_get_plan_type_csr;

     IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_plan_type: '|| l_plan_type
        );
     END IF;

    IF (l_plan_type <> G_PLAN_TYPE_PRIMARY) THEN
      -- Current Plan is a simulation: Include primary plan's visit tasks
      OPEN l_get_primary_visits(p_dept_id, p_plan_id, p_start_time, l_end_time);
      LOOP
        FETCH l_get_primary_visits INTO l_temp_visit;
        EXIT WHEN l_get_primary_visits%NOTFOUND;

        IF (l_log_statement >= l_log_current_level) THEN
            fnd_log.string
            (
              fnd_log.level_statement,
              'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
              'l_temp_visit:'||l_temp_visit
             );
        END IF;

        -- Call helper method to do the actual processing
        Derive_Task_Op_Times(
          p_visit_id              => l_temp_visit,
          p_start_time            => p_start_time,
          p_end_time              => p_end_time,
          p_department_id         => p_dept_id,
          p_x_tp_dtls_tbl         => x_tp_dtls_tbl, -- Table for Operation Time Periods
          x_visit_start_time      => l_temp_sttime,
          x_visit_end_time        => l_temp_endtime,
          x_visit_end_hour        => l_temp_num1,
          x_visit_task_times_tbl  => l_temp_times_tbl);

        IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string
          (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'After calling Derive_Task_Op_Times'
          );
          fnd_log.string
          (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'l_temp_times_tbl.count: '|| l_temp_times_tbl.count
          );
        END IF;


-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

-- removed the logic to check for mr route ID
--since now that's done inside Derive_Task_Op_Times already

        -- Collect the task info for the current visit into the master tasks table
        IF (l_temp_times_tbl.COUNT > 0) THEN
          l_temp_num1 := l_temp_times_tbl.FIRST;
          l_temp_index := l_final_times_tbl.LAST +1;

          WHILE l_temp_num1 IS NOT NULL LOOP

--          IF l_temp_times_tbl(l_temp_num1).mr_route_id IS NOT NULL THEN
            l_final_times_tbl(l_temp_index) := l_temp_times_tbl(l_temp_num1);
            l_temp_index := l_temp_index + 1;

--          END IF;
        l_temp_num1 := l_temp_times_tbl.NEXT(l_temp_num1);


          END LOOP;  -- All valid tasks for current visit
        END IF;

-- yazhou 24Aug2005 ends

      END LOOP;  -- All valid primary plan visits for current dept
      CLOSE l_get_primary_visits;
    END IF;
  END IF;

  x_visit_task_times_tbl := l_final_times_tbl;

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_visit_task_times_tbl.count: '|| x_visit_task_times_tbl.count
        );
  END IF;

  IF x_visit_task_times_tbl.COUNT >0 THEN
    FOR i IN x_visit_task_times_tbl.FIRST..x_visit_task_times_tbl.LAST
   LOOP
   --
--   Ahl_Debug_Pub.debug('Exiting GET_PLAN_TASKS MR ID:'||x_visit_task_times_tbl(i).mr_route_id);
--   Ahl_Debug_Pub.debug('Exiting GET_PLAN_TASKS VTID:'||x_visit_task_times_tbl(i).visit_task_id);
--   Ahl_Debug_Pub.debug('Exiting GET_PLAN_TASKS STIME:'||x_visit_task_times_tbl(i).task_start_time);
--   Ahl_Debug_Pub.debug('Exiting GET_PLAN_TASKS ETIME:'||x_visit_task_times_tbl(i).task_end_time);
     null;
   --
   END LOOP;
   END IF;
   --
IF x_tp_dtls_tbl.COUNT >0 THEN
 FOR i IN x_tp_dtls_tbl.FIRST..x_tp_dtls_tbl.LAST
 LOOP

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').visit_id: '|| x_tp_dtls_tbl(i).visit_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').route_id: '|| x_tp_dtls_tbl(i).route_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').mr_route_id: '|| x_tp_dtls_tbl(i).mr_route_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').operation_id: '|| x_tp_dtls_tbl(i).operation_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').task_id: '|| x_tp_dtls_tbl(i).task_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').start_time: '|| x_tp_dtls_tbl(i).start_time
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').end_time: '|| x_tp_dtls_tbl(i).end_time
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').bom_resource_id: '|| x_tp_dtls_tbl(i).bom_resource_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').department_id: '|| x_tp_dtls_tbl(i).department_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_tp_dtls_tbl('||i||').quantity: '|| x_tp_dtls_tbl(i).quantity
        );

    END IF;
 END LOOP;
END IF;

   --
END Get_Plan_Tasks;

----------------------------------------
-- Gets the task and operation times for a given visit
-- Also builds the Time Period table if required
----------------------------------------
-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

-- The start/end time calulation is no longer required
-- since now task time is calculated and stored in VWP

-- added p_department_id as input parameter
-- and removed default values for start/end time and p_op_times_flag

-- Return only time for tasks with MR route associated

PROCEDURE Derive_Task_Op_Times
(
    p_visit_id              IN            NUMBER,
    p_start_time            IN            DATE,
    p_end_time              IN            DATE,
    p_department_id         IN            NUMBER,
    p_x_tp_dtls_tbl         IN OUT NOCOPY Time_Period_Details_Tbl_Type,
    x_visit_start_time      OUT NOCOPY           DATE,
    x_visit_end_time        OUT NOCOPY           DATE,
    x_visit_end_hour        OUT NOCOPY           NUMBER,
    x_visit_task_times_tbl  OUT NOCOPY Visit_Task_Times_Tbl_Type
) IS

  -- Find all the tasks with route associated in the given department

  CURSOR l_tasks_csr(p_visit_id IN NUMBER, p_dept_id IN NUMBER) IS
    SELECT vt.visit_task_id,  mr_route_id,
           NVL(start_from_hour, 0) start_from_hour,
           NVL(duration, 0) duration,
           start_date_time,
           end_date_time
    FROM  ahl_visit_tasks_b vt
    WHERE vt.visit_id = p_visit_id AND
          status_code = 'PLANNING' AND
         (department_id = p_dept_id OR (department_id is NULL AND
                                   p_dept_id = (select department_id from ahl_visits_b
                                                where visit_id = p_visit_id))) AND
         mr_route_id is not null
    ORDER BY vt.visit_task_id;


-- Added organization_id as select field and removed template_flag

  CURSOR l_visit_details_csr(p_visit_id IN NUMBER) IS
    SELECT start_date_time,department_id,close_date_time, organization_id
     FROM ahl_visits_b
    WHERE visit_id = p_visit_id;


-- yazhou 24Aug2005 ends

  l_task_times_tbl    visit_task_times_Tbl_Type;
  l_visit_dtls_rec    l_visit_details_csr%ROWTYPE;

  l_dept_id          NUMBER;
  l_temp_num1        NUMBER;
  l_index            NUMBER;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
  l_api_name        CONSTANT VARCHAR2(30) := 'Derive_Task_Op_Times';
  l_org_id          NUMBER;
  l_tasks_rec       l_tasks_csr%ROWTYPE;
-- yazhou 24Aug2005 ends

BEGIN

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_start_time:'||p_start_time
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_end_time:'||p_end_time
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_department_id:'||p_department_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_visit_id:'||p_visit_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl.count:'||p_x_tp_dtls_tbl.count
        );

  END IF;
  -- Get the visit details
  OPEN l_visit_details_csr(p_visit_id);

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- Added organization_id as select field
  FETCH l_visit_details_csr INTO x_visit_start_time, l_dept_id,
                                 x_visit_end_time,l_org_id;
-- yazhou 24Aug2005 ends

  IF(l_visit_details_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ID_NULL');
    Fnd_Msg_Pub.ADD;
    CLOSE l_visit_details_csr;
    Ahl_Debug_Pub.debug('Invalid visit Id', 'LTP: Derive_Visit_Task_Times');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_visit_details_csr;

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

-- x_visit_end_time null check is not required for resource leveling

  IF x_visit_end_time IS NOT NULL THEN
     x_visit_end_hour := to_number(to_char(x_visit_end_time,'HH24'));
  END IF;

-- Get task start/end time from VWP directly
  OPEN l_tasks_csr(p_visit_id,p_department_id);
  LOOP
    FETCH l_tasks_csr INTO l_tasks_rec;
    EXIT WHEN l_tasks_csr%NOTFOUND;
       l_index := l_tasks_rec.visit_task_id;
       l_task_times_tbl(l_index).VISIT_TASK_ID := l_index;
       l_task_times_tbl(l_index).MR_ROUTE_ID := l_tasks_rec.mr_route_id;
       Get_Route_Duration(l_tasks_rec.mr_route_id, l_task_times_tbl(l_index).TASK_DURATION);
       l_task_times_tbl(l_index).TASK_START_TIME := l_tasks_rec.start_date_time;
       l_task_times_tbl(l_index).TASK_END_TIME := l_tasks_rec.end_date_time;
       l_task_times_tbl(l_index).TASK_START_HOUR := to_number(to_char(l_tasks_rec.start_date_time,'HH24'));
       l_task_times_tbl(l_index).TASK_END_HOUR := to_number(to_char(l_tasks_rec.end_date_time,'HH24'));

  END LOOP;
  CLOSE l_tasks_csr;

  -- yazhou: remove the IF condition since template check is no longer required
  -- and p_start_time/p_end_time both cannot be null

  -- Filter based on time period: Currenlty supporting filtering only if
  -- both: start time as well as end time are given

--  IF (l_template_flag = 'Y' OR p_start_time IS NULL OR p_end_time IS NULL) THEN
--    x_visit_task_times_tbl := l_task_times_tbl;
--  ELSE

   IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_task_times_tbl.COUNT:'||l_task_times_tbl.COUNT
        );
   END IF;

   IF l_task_times_tbl.COUNT > 0 THEN

      -- To set all the global constants about the Department.
      INIT_TIME_VARS(x_visit_start_time, p_department_id);

      l_index := l_task_times_tbl.FIRST;
      l_temp_num1 := 1;
      WHILE l_index IS NOT NULL LOOP

-- Requirement date should be based on operation time if requirements
-- are defined for operaion, so should not only use task time to decide
-- whether Get_Operation_Details should be called for this task.

        IF (Periods_Overlap (l_task_times_tbl(l_index).TASK_START_TIME,
                             l_task_times_tbl(l_index).TASK_END_TIME,
                             p_start_time,
                             p_end_time)) THEN
          x_visit_task_times_tbl(l_temp_num1) := l_task_times_tbl(l_index);
          l_temp_num1 := l_temp_num1 + 1;
        END IF;

        Get_Operation_Details(p_task_dtls     => l_task_times_tbl(l_index),
                                  p_visit_id      => p_visit_id,
                                  p_department_id => p_department_id,
                                  p_organization_id => l_org_id,
                                  p_start_time      => p_start_time,
                                  p_end_time        => p_end_time,
                                  p_x_tp_dtls_tbl => p_x_tp_dtls_tbl);

        IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string
           (
              fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
             'l_index-('||l_index||') After Calling Get_Operation_Details'
           );
           fnd_log.string
           (
              fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
             'p_x_tp_dtls_tbl.COUNT:'||p_x_tp_dtls_tbl.COUNT
           );
        END IF;

        l_index := l_task_times_tbl.NEXT(l_index);
      END LOOP;
    END IF;
--  END IF;

    IF (l_log_statement >= l_log_current_level) THEN
           fnd_log.string
           (
              fnd_log.level_statement,
             'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
             'l_task_times_tbl.COUNT:'||l_task_times_tbl.COUNT
           );
    END IF;

-- yazhou 24Aug2005 ends


END Derive_Task_Op_Times;

----------------------------------------
-- Gets the resources required by the given task
----------------------------------------
PROCEDURE Get_Task_Resources
(
    p_required_capacity IN      NUMBER ,
    p_task_id           IN      NUMBER,
    p_tstart_date       IN      DATE,
    p_tend_date         IN      DATE,
    p_distinct_flag     IN      BOOLEAN,
    p_x_task_rsrc_tbl   IN OUT NOCOPY Plan_Rsrc_Tbl_Type
) IS

  CURSOR l_get_route_csr(p_task_id IN NUMBER) IS
    SELECT a.MR_ROUTE_ID,B.route_id
    FROM ahl_visit_tasks_b a, ahl_mr_routes_app_v B
    WHERE VISIT_TASK_ID = p_task_id
    AND a.mr_route_id = B.mr_route_id;

  CURSOR l_get_dept_csr(p_task_id IN NUMBER) IS
    SELECT vt.DEPARTMENT_ID,v.department_id,v.organization_id
    FROM ahl_visits_b v, ahl_visit_tasks_b vt
    WHERE vt.VISIT_TASK_ID = p_task_id
    AND v.visit_id = vt.visit_id;

  CURSOR l_get_rt_resources_csr(c_route_id IN NUMBER) IS
    SELECT ASO_RESOURCE_ID
    FROM ahl_rt_oper_resources WHERE
    ASSOCIATION_TYPE_CODE = G_RT_ASSOC_TYPE
    /*LTP CHANGES FOR NONSCHEDULED RESOURCE REQUIREMENTS - sowsubra*/
    AND NVL(SCHEDULED_TYPE_ID,1) <> 2
    AND OBJECT_ID = c_route_id;

  CURSOR l_get_oper_resources_csr(c_route_id IN NUMBER) IS
    SELECT ASO_RESOURCE_ID
    FROM ahl_rt_oper_resources WHERE
    ASSOCIATION_TYPE_CODE = G_OPER_ASSOC_TYPE
    /*LTP CHANGES FOR NONSCHEDULED RESOURCE REQUIREMENTS - sowsubra*/
    AND NVL(SCHEDULED_TYPE_ID,1) <> 2
    AND OBJECT_ID IN (SELECT OPERATION_ID FROM ahl_route_operations WHERE ROUTE_ID = c_route_id);

  CURSOR l_get_bom_resources_csr(c_aso_resource_id IN NUMBER,
                                 c_org_id  IN NUMBER) IS
    SELECT BOM_RESOURCE_ID
    FROM ahl_resource_mappings WHERE
    ASO_RESOURCE_ID = c_aso_resource_id
    AND bom_org_id = c_org_id;

  l_mr_route_id       NUMBER := NULL;
  l_route_id          NUMBER := NULL;
  l_vdept_id          NUMBER := NULL;
  l_vtdept_id         NUMBER := NULL;
  l_dept_id           NUMBER;
  l_org_id            NUMBER;
  l_bom_resource_id   NUMBER;
  l_bom_org_id        NUMBER;
  l_rt_resource_rec    l_get_rt_resources_csr%ROWTYPE;
  l_oper_resource_rec  l_get_oper_resources_csr%ROWTYPE;
  l_qualified        BOOLEAN;
  l_time_period_details_tbl Time_Period_Details_Tbl_Type;
BEGIN
--  dbms_output.put_line('Entering Get_Task_Resources, p_task_id = ' || p_task_id);
Ahl_Debug_Pub.debug('Entering Get_Task_Resources, p_task_id = ' || p_task_id);
Ahl_Debug_Pub.debug('Get_Task_Resources, p_x_task_rsrc_tbl.count = ' || p_x_task_rsrc_tbl.count);
Ahl_Debug_Pub.debug('Get_Task_Resources, p_x_task_rsrc_tbl.STIME = ' || p_x_task_rsrc_tbl.count);

  OPEN l_get_route_csr(p_task_id);
  FETCH l_get_route_csr INTO l_mr_route_id,l_route_id;
  IF l_get_route_csr%NOTFOUND OR l_route_id IS NULL THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_ROUTE_FOR_TASK');
    Fnd_Message.Set_Token('TASK_ID', p_task_id);
    Fnd_Msg_Pub.ADD;
    CLOSE l_get_route_csr;
    RETURN;
  END IF;
  CLOSE l_get_route_csr;

  OPEN l_get_dept_csr(p_task_id);
  FETCH l_get_dept_csr INTO l_vtdept_id,l_vdept_id,l_org_id;
  IF l_get_dept_csr%NOTFOUND THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_DEPT_FOR_TASK');
    Fnd_Message.Set_Token('TASK_ID', p_task_id);
    Fnd_Msg_Pub.ADD;
    CLOSE l_get_dept_csr;
    RETURN;
  END IF;
  l_dept_id := NVL(l_vtdept_id,l_vdept_id);
  CLOSE l_get_dept_csr;

Ahl_Debug_Pub.debug('Get_Task_Resources, route id = ' || l_route_id);
--
  OPEN l_get_rt_resources_csr(l_route_id);
  FETCH l_get_rt_resources_csr INTO l_rt_resource_rec;
  --
  IF (l_get_rt_resources_csr%FOUND) THEN
    -- Resources assigned at Route Level itself
    LOOP
      l_qualified := TRUE;
      -- Get Route Resource Details
      IF (l_qualified) THEN

    Ahl_Debug_Pub.debug('Get_Task_Resources, aso resource id = ' || l_rt_resource_rec.ASO_RESOURCE_ID);
      --  Get bom resource id for the corresponding aso resource
    OPEN l_get_bom_resources_csr(l_rt_resource_rec.ASO_RESOURCE_ID,l_org_id);
    FETCH l_get_bom_resources_csr INTO l_bom_resource_id;
        IF l_get_bom_resources_csr%NOTFOUND THEN
          Fnd_Message.Set_Name('AHL','AHL_LTP_NO_BOM_RESRC_ID');
          Fnd_Msg_Pub.ADD;
         CLOSE l_get_bom_resources_csr;
         RAISE  Fnd_Api.G_EXC_ERROR;
--        RETURN;
        END IF;
  CLOSE l_get_bom_resources_csr;
    --
Ahl_Debug_Pub.debug('ROUTE LEVEL, l_bom_resource_id = ' || l_bom_resource_id);
Ahl_Debug_Pub.debug('ROUTE LEVEL, l_bom_org_id = ' || l_org_id);
    --
        Get_Resource_Details(
          p_required_capacity => p_required_capacity,
          p_aso_resource_id   => l_rt_resource_Rec.ASO_RESOURCE_ID,
        p_bom_resource_id   => l_bom_resource_id,
        p_bom_department_id => l_dept_id,
          p_start_date        => p_tstart_date,
          p_end_date          => p_tend_date,
          p_x_task_rsrc_tbl   => p_x_task_rsrc_tbl
        );
    Ahl_Debug_Pub.debug('Number of records for resources = ' ||p_x_task_rsrc_tbl.count);
      END IF;
      FETCH l_get_rt_resources_csr INTO l_rt_resource_rec;
      EXIT WHEN l_get_rt_resources_csr%NOTFOUND;
    END LOOP;
  ELSE

Ahl_Debug_Pub.debug('Get_Task_Resources, operation level route id = ' || l_route_id);

    -- Get resources from operation level
    OPEN l_get_oper_resources_csr(l_route_id);
    LOOP
      FETCH l_get_oper_resources_csr INTO l_oper_resource_rec;
      EXIT WHEN l_get_oper_resources_csr%NOTFOUND;
      l_qualified := TRUE;
      -- Get Route Resource Details
      IF (l_qualified) THEN

Ahl_Debug_Pub.debug('Get_Task_Resources, aso resource id oper = ' || l_oper_resource_rec.ASO_RESOURCE_ID);
Ahl_Debug_Pub.debug('inside, l_org_id = ' || l_org_id);

      --  Get bom resource id for the corresponding aso resource
    OPEN l_get_bom_resources_csr(l_oper_resource_rec.ASO_RESOURCE_ID,l_org_id);
    FETCH l_get_bom_resources_csr INTO l_bom_resource_id;

    Ahl_Debug_Pub.debug('OPERATION LEVEL, bom resource id oper = ' || l_bom_resource_id);

        IF l_get_bom_resources_csr%NOTFOUND THEN
          Fnd_Message.Set_Name('AHL','AHL_LTP_NO_BOM_RESRC_ID');
          Fnd_Msg_Pub.ADD;
         CLOSE l_get_bom_resources_csr;
         RAISE  Fnd_Api.G_EXC_ERROR;
--        RETURN;
        END IF;
        CLOSE l_get_bom_resources_csr;
  --
        Get_Resource_Details(
          p_required_capacity => p_required_capacity,
          p_aso_resource_id   => l_rt_resource_Rec.ASO_RESOURCE_ID,
          p_bom_resource_id   => l_bom_resource_id,
      p_bom_department_id => l_dept_id,
          p_start_date        => p_tstart_date,
          p_end_date          => p_tend_date,
          p_x_task_rsrc_tbl   => p_x_task_rsrc_tbl
        );
    Ahl_Debug_Pub.debug('Number of records for resources = ' ||p_x_task_rsrc_tbl.count);
      END IF;
    END LOOP;
    CLOSE l_get_oper_resources_csr;
  END IF;
  CLOSE l_get_rt_resources_csr;
--  dbms_output.put_line('Exiting Get_Task_Resources');
END Get_Task_Resources;

----------------------------------------
-- Gets the details of a resource
----------------------------------------
PROCEDURE Get_Resource_Details
(   p_required_capacity IN      NUMBER,
    p_aso_resource_id   IN      NUMBER,
    p_bom_resource_id   IN      NUMBER,
    p_bom_department_id IN      NUMBER,
    p_start_date        IN      DATE,
    p_end_date          IN      DATE,
    p_x_task_rsrc_tbl   IN OUT  NOCOPY Plan_Rsrc_Tbl_Type
) IS

-- yazhou 17Aug2005 starts
-- bug fix #4559462

    CURSOR l_get_bom_rsrc_dtls_csr(p_bom_resource_id   IN NUMBER,
                                 p_bom_department_id IN NUMBER) IS
    SELECT a.RESOURCE_TYPE,a.RESOURCE_CODE,a.DESCRIPTION,
       B.CAPACITY_UNITS, M.meaning resource_type_mean
    FROM bom_resources A,
         bom_department_resources B,
         mfg_lookups M
  WHERE a.resource_id = B.resource_id
   AND B.resource_id = p_bom_resource_id
   AND B.department_id = p_bom_department_id
     AND A.resource_type = M.lookup_code
     AND M.lookup_type = 'BOM_RESOURCE_TYPE';

-- yazhou 17Aug2005 ends

  -- Gets shift capacity
    CURSOR l_get_shift_dtls_csr(p_bom_resource_id   IN NUMBER,
                                p_bom_department_id IN NUMBER) IS
    SELECT SHIFT_NUM,
       CAPACITY_UNITS SHIFT_CAPACITY
    FROM bom_resource_shifts
  WHERE resource_id = p_bom_resource_id
   AND  department_id = p_bom_department_id;

  --
  CURSOR l_get_dept_desc_cur (p_bom_department_id IN NUMBER) IS
   SELECT department_code,description
     FROM bom_departments
  WHERE department_id = p_bom_department_id;
  --
  l_shift_num          NUMBER;
  l_shift_capacity     NUMBER;
  l_department_code    VARCHAR2(30);
  --
  l_table_index      NUMBER := p_x_task_rsrc_tbl.COUNT + 1; -- 1 based index

BEGIN
Ahl_Debug_Pub.debug('enter get resource details p_bom_resource_id  = ' || p_bom_resource_id);
Ahl_Debug_Pub.debug('enter get resource details p_bom_department_id = ' || p_bom_department_id);
Ahl_Debug_Pub.debug('get resource details l_table_index: = ' || l_table_index);

  IF (p_bom_resource_id IS NOT NULL) THEN
    -- BOM Resource
    p_x_task_rsrc_tbl(l_table_index).ASO_BOM_TYPE := G_BOM_RESOURCE;
    p_x_task_rsrc_tbl(l_table_index).RESOURCE_ID := p_bom_resource_id;
    -- Get the type, name and description for this BOM Resource
    OPEN l_get_bom_rsrc_dtls_csr(p_bom_resource_id,p_bom_department_id);

    -- yazhou 17Aug2005 starts
    -- bug fix #4559462
    FETCH l_get_bom_rsrc_dtls_csr INTO p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE,
                                       p_x_task_rsrc_tbl(l_table_index).RESOURCE_NAME,
                                       p_x_task_rsrc_tbl(l_table_index).RESOURCE_DESCRIPTION,
                                       p_x_task_rsrc_tbl(l_table_index).CAPACITY_UNITS,
                                       p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE_MEANING;
    -- yazhou 17Aug2005 ends

    IF (l_get_bom_rsrc_dtls_csr%NOTFOUND) THEN
       Fnd_Message.Set_Name('AHL','AHL_LTP_BOM_RSRC_ID_INVALID');
       Fnd_Message.Set_Token('ASO_RSRC_ID', p_bom_resource_id);
       Fnd_Msg_Pub.ADD;
       CLOSE l_get_bom_rsrc_dtls_csr;
       RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    -- Check for shift capacity
    OPEN  l_get_shift_dtls_csr(p_bom_resource_id,p_bom_department_id);
    FETCH l_get_shift_dtls_csr INTO l_shift_num,l_shift_capacity;
    CLOSE l_get_shift_dtls_csr;
    --
    IF l_shift_capacity IS NOT NULL THEN
       p_x_task_rsrc_tbl(l_table_index).CAPACITY_UNITS := (p_x_task_rsrc_tbl(l_table_index).CAPACITY_UNITS + l_shift_capacity);
    ELSE
       p_x_task_rsrc_tbl(l_table_index).CAPACITY_UNITS := p_x_task_rsrc_tbl(l_table_index).CAPACITY_UNITS ;
    END IF;

    Ahl_Debug_Pub.debug('get resource details p_capacity_units = ' || p_x_task_rsrc_tbl(l_table_index).CAPACITY_UNITS);
    p_x_task_rsrc_tbl(l_table_index).RESOURCE_ID := p_aso_resource_id;
   --
   OPEN l_get_dept_desc_cur(p_bom_department_id);
   FETCH l_get_dept_desc_cur INTO l_department_code,
                                  p_x_task_rsrc_tbl(l_table_index).dept_description;
     CLOSE l_get_dept_desc_cur;
   --
   --Assign department id
   p_x_task_rsrc_tbl(l_table_index).dept_id := p_bom_department_id;
   p_x_task_rsrc_tbl(l_table_index).period_start := p_start_date;
   p_x_task_rsrc_tbl(l_table_index).period_end  := p_end_date;

   --
-- yazhou 17Aug2005 starts
-- bug fix #4559462
/*
   --
    -- //@@@@@ Resolve Hardcoding
    IF (p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE = G_MACHINE_RESOURCE) THEN
      p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE_MEANING := G_MACHINE_RES_NAME;
    ELSIF (p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE = G_LABOR_RESOURCE) THEN
      p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE_MEANING := G_LABOR_RES_NAME;
    ELSE
      -- Unknown Resource Type
      NULL;
    END IF;
*/

   CLOSE l_get_bom_rsrc_dtls_csr;
  END IF;
END Get_Resource_Details;

----------------------------------------
-- Gets the details of a resource
----------------------------------------
PROCEDURE Get_Resource_Details
(
    p_aso_resource_id   IN      NUMBER,
    p_x_task_rsrc_tbl   IN OUT  NOCOPY Plan_Rsrc_Tbl_Type
) IS

  CURSOR l_get_aso_rsrc_dtls_csr(p_rsrc_id IN NUMBER) IS
    SELECT NAME, DESCRIPTION FROM ahl_resources WHERE
    resource_id = p_rsrc_id;

-- yazhou 17Aug2005 starts
-- bug fix #4559462
  CURSOR l_get_bom_rsrc_dtls_csr(p_rsrc_id IN NUMBER) IS
    SELECT b.RESOURCE_TYPE, b.RESOURCE_CODE, b.DESCRIPTION, m.meaning
    FROM bom_resources b, mfg_lookups m
    WHERE b.resource_type = m.lookup_code
    AND   m.lookup_type = 'BOM_RESOURCE_TYPE'
    AND   resource_id = p_rsrc_id;
-- yazhou 17Aug2005 ends

  l_table_index      NUMBER := p_x_task_rsrc_tbl.COUNT + 1; -- 1 based index

BEGIN
  IF (p_aso_resource_id IS NOT NULL) THEN
    -- BOM Resource
    p_x_task_rsrc_tbl(l_table_index).ASO_BOM_TYPE := G_BOM_RESOURCE;
    p_x_task_rsrc_tbl(l_table_index).RESOURCE_ID := p_aso_resource_id;
    -- Get the type, name and description for this BOM Resource
    OPEN l_get_bom_rsrc_dtls_csr(p_aso_resource_id);

-- yazhou 17Aug2005 starts
-- bug fix #4559462
    FETCH l_get_bom_rsrc_dtls_csr INTO p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE,
                                       p_x_task_rsrc_tbl(l_table_index).RESOURCE_NAME,
                                       p_x_task_rsrc_tbl(l_table_index).RESOURCE_DESCRIPTION,
                                       p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE_MEANING;
-- yazhou 17Aug2005 ends

    IF (l_get_bom_rsrc_dtls_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_BOM_RSRC_ID_INVALID');
      Fnd_Message.Set_Token('ASO_RSRC_ID', p_aso_resource_id);
      Fnd_Msg_Pub.ADD;
      CLOSE l_get_bom_rsrc_dtls_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;

-- yazhou 17Aug2005 starts
-- bug fix #4559462
/*
    -- //@@@@@ Resolve Hardcoding
    IF (p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE = G_MACHINE_RESOURCE) THEN
      p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE_MEANING := G_MACHINE_RES_NAME;
    ELSIF (p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE = G_LABOR_RESOURCE) THEN
      p_x_task_rsrc_tbl(l_table_index).RESOURCE_TYPE_MEANING := G_LABOR_RES_NAME;
    ELSE
      -- Unknown Resource Type
      NULL;
    END IF;
*/

-- yazhou 17Aug2005 ends
    CLOSE l_get_bom_rsrc_dtls_csr;
  END IF;
END Get_Resource_Details;


----------------------------------------
-- Populates a Time Period table with a task's operations' start time and end time
-- (If the task's route has operations AND IF ressources are NOT associated AT route LEVEL)
-- or with the task's start time and end time
----------------------------------------

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

-- Return all resource requirement for the given department and period
-- Use requirements defined for the routes if there are any, otherwise use those for operations
-- Added department_id and bom_resource_id in the output table
-- And populate required quantity as well as start/end dates
-- Also change to call AHL_VWP_TIMES_PVT.compute_date to calculate operation dates

PROCEDURE Get_Operation_Details
(
    p_task_dtls      IN      Visit_Task_Times_Rec_Type,
    p_visit_id       IN      NUMBER,
    p_department_id  IN      NUMBER,
    p_organization_id IN     NUMBER,
    p_start_time     IN      DATE,
    p_end_time       IN      DATE,
    p_x_tp_dtls_tbl  IN OUT  NOCOPY Time_Period_Details_Tbl_Type
) IS

  -- get only operations with latest revision
  CURSOR l_get_ops_count(p_route_id IN NUMBER) IS
    SELECT COUNT(ro.operation_id)
    FROM ahl_route_operations ro, AHL_OPERATIONS_VL OP
    WHERE OP.operation_id=RO.operation_id
      AND ro.ROUTE_ID = p_route_id
      AND OP.revision_number IN
           ( SELECT MAX(OP1.revision_number)
             FROM   AHL_OPERATIONS_B_KFV OP1
             WHERE  OP1.concatenated_segments=OP.concatenated_segments
             AND    OP1.revision_status_code='COMPLETE'
             AND    TRUNC(SYSDATE) BETWEEN TRUNC(OP1.start_date_active) AND
                                           TRUNC(NVL(OP1.end_date_active,SYSDATE+1))
           );

  CURSOR l_get_rt_rsrc_count(p_route_id IN NUMBER) IS
    SELECT COUNT(*) FROM ahl_rt_oper_resources
    WHERE OBJECT_ID = p_route_id AND
    ASSOCIATION_TYPE_CODE = G_RT_ASSOC_TYPE;

  -- get only operations with latest revision
  CURSOR l_get_rt_oper_csr(p_route_id IN NUMBER) IS
    SELECT RO.OPERATION_ID, RO.STEP
    FROM ahl_route_operations ro, AHL_OPERATIONS_VL OP
    WHERE OP.operation_id=RO.operation_id
      AND ro.ROUTE_ID = p_route_id
      AND OP.revision_number IN
           ( SELECT MAX(OP1.revision_number)
             FROM   AHL_OPERATIONS_B_KFV OP1
             WHERE  OP1.concatenated_segments=OP.concatenated_segments
             AND    OP1.revision_status_code='COMPLETE'
             AND    TRUNC(SYSDATE) BETWEEN TRUNC(OP1.start_date_active) AND
                                           TRUNC(NVL(OP1.end_date_active,SYSDATE+1))
           )
    ORDER BY RO.STEP;

  CURSOR l_get_route_id(p_mr_route_id IN NUMBER) IS
    SELECT ROUTE_ID FROM ahl_mr_routes_app_v
    WHERE MR_ROUTE_ID = p_mr_route_id;

 -- get resources associated to route
CURSOR l_rt_resource_dtl_csr (l_route_id IN NUMBER,
                             l_dept_id  IN NUMBER,
                             l_org_id   IN NUMBER) IS
 SELECT a.aso_resource_id,
        a.quantity,
        b.bom_resource_id
 FROM ahl_rt_oper_resources a,
      ahl_resource_mappings b,
      bom_department_resources c
 WHERE a.aso_resource_id = b. aso_resource_id
   AND a.object_id = l_route_id
   AND b.bom_resource_id = c.resource_id
   AND b.bom_org_id = l_org_id
   AND c.department_id = l_dept_id
   /*B6459500 - LTP CHANGES FOR NONSCHEDULED RESOURCE REQUIREMENTS - sowsubra*/
   AND nvl(scheduled_type_id,1) <> 2
   AND ASSOCIATION_TYPE_CODE = G_RT_ASSOC_TYPE;

-- get resources associated to operations
CURSOR l_oper_resource_dtl_csr (l_operation_id IN NUMBER,
                                 l_dept_id      IN NUMBER,
                                 l_org_id       IN NUMBER) IS
 SELECT a.aso_resource_id,
        a.quantity,
        b.bom_resource_id
 FROM ahl_rt_oper_resources a,
      ahl_resource_mappings b,
      bom_department_resources c
 WHERE  a.object_id  = l_operation_id
  AND  a.ASSOCIATION_TYPE_CODE = 'OPERATION'
  AND  a.aso_resource_id = b. aso_resource_id
  AND  b.bom_resource_id = c.resource_id
  AND  c.department_id = l_dept_id
  /*B6459500 - LTP CHANGES FOR NONSCHEDULED RESOURCE REQUIREMENTS - sowsubra*/
  AND nvl(scheduled_type_id,1) <> 2
  AND  b.bom_org_id = l_org_id;

  l_dept_id          NUMBER := NULL;
  l_operation_id     NUMBER;
  l_operation_step   NUMBER;
  l_table_index      NUMBER := p_x_tp_dtls_tbl.COUNT + 1;  -- 1 based
  l_temp_count       NUMBER := 0;
  l_temp_duration    NUMBER;

  l_route_id         NUMBER;
  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Operation_Details';

  l_rt_resource_dtl_rec    l_rt_resource_dtl_csr%rowtype;
  l_oper_resource_dtl_rec  l_oper_resource_dtl_csr%rowtype;
  l_oper_START_TIME   DATE;
  l_oper_END_TIME   DATE;

BEGIN

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_start_time:'||p_start_time
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_end_time:'||p_end_time
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_department_id:'||p_department_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_visit_id:'||p_visit_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_organization_id:'||p_organization_id
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_task_dtls.MR_ROUTE_ID:'||p_task_dtls.MR_ROUTE_ID
        );
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_task_dtls.VISIT_TASK_ID:'||p_task_dtls.VISIT_TASK_ID
        );
  END IF;

  IF (p_task_dtls.MR_ROUTE_ID IS NULL) THEN
    -- no need to include this task
    RETURN;
  END IF;

  -- Find the route ID with MR_route_id associated to task

  OPEN l_get_route_id(p_task_dtls.MR_ROUTE_ID);
  FETCH l_get_route_id INTO l_route_id;
  CLOSE l_get_route_id;

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'l_route_id:'||l_route_id
        );
  END IF;

  -- Check to see if route has any resource requirements defined
  OPEN l_get_rt_rsrc_count(l_route_id);
  FETCH l_get_rt_rsrc_count INTO l_temp_count;
  CLOSE l_get_rt_rsrc_count;

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'number of resources associated to route:'||l_temp_count
        );
  END IF;

  IF l_temp_count >0  THEN

    -- Add resource requirements to output table only if task start/end date
    -- overlaps with the given period

    IF (Periods_Overlap (p_task_dtls.TASK_START_TIME,p_task_dtls.TASK_END_TIME,
                         p_start_time, p_end_time)) THEN

        -- There are resource requirements defined for the route
        OPEN l_rt_resource_dtl_csr(l_route_id,p_department_id,p_organization_id);
        LOOP
           FETCH l_rt_resource_dtl_csr INTO l_rt_resource_dtl_rec;
           EXIT WHEN l_rt_resource_dtl_csr%NOTFOUND;

             p_x_tp_dtls_tbl(l_table_index).VISIT_ID := p_visit_id;
             p_x_tp_dtls_tbl(l_table_index).TASK_ID := p_task_dtls.VISIT_TASK_ID;
             p_x_tp_dtls_tbl(l_table_index).ROUTE_ID := l_route_id;
             p_x_tp_dtls_tbl(l_table_index).MR_ROUTE_ID := p_task_dtls.MR_ROUTE_ID;
             p_x_tp_dtls_tbl(l_table_index).OPERATION_ID := NULL;
             p_x_tp_dtls_tbl(l_table_index).STEP := NULL;
             p_x_tp_dtls_tbl(l_table_index).START_HOUR := p_task_dtls.TASK_START_HOUR;
             p_x_tp_dtls_tbl(l_table_index).END_HOUR := p_task_dtls.TASK_END_HOUR;
             p_x_tp_dtls_tbl(l_table_index).MAX_DURATION := p_task_dtls.TASK_DURATION;
             p_x_tp_dtls_tbl(l_table_index).START_TIME := p_task_dtls.TASK_START_TIME;
             p_x_tp_dtls_tbl(l_table_index).END_TIME := p_task_dtls.TASK_END_TIME;
             p_x_tp_dtls_tbl(l_table_index).QUANTITY := l_rt_resource_dtl_rec.quantity;
             p_x_tp_dtls_tbl(l_table_index).ASO_RESOURCE_ID := l_rt_resource_dtl_rec.ASO_RESOURCE_ID;
             p_x_tp_dtls_tbl(l_table_index).BOM_RESOURCE_ID := l_rt_resource_dtl_rec.BOM_RESOURCE_ID;
             p_x_tp_dtls_tbl(l_table_index).DEPARTMENT_ID := p_department_id;

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                    'p_x_tp_dtls_tbl('||l_table_index||').start_time: '|| TO_CHAR(p_x_tp_dtls_tbl(l_table_index).start_time, 'DD-MON-YYYY hh24:mi')
                 );
                 fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                    'p_x_tp_dtls_tbl('||l_table_index||').end_time: '|| TO_CHAR( p_x_tp_dtls_tbl(l_table_index).end_time, 'DD-MON-YYYY hh24:mi')
                 );
                 fnd_log.string
                 (
                     fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                    'p_x_tp_dtls_tbl('||l_table_index||').bom_resource_id: '|| p_x_tp_dtls_tbl(l_table_index).bom_resource_id
                 );
                 fnd_log.string
                 (
                     fnd_log.level_statement,
                     'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'p_x_tp_dtls_tbl('||l_table_index||').quantity: '|| p_x_tp_dtls_tbl(l_table_index).quantity
                 );

             END IF;

             l_table_index := l_table_index + 1;

        END LOOP;-- loop through all resources
        CLOSE l_rt_resource_dtl_csr;
     END IF;  -- period overlap

  ELSE                     -- Check for operation resources

    -- Check if route has any operations
    OPEN l_get_ops_count(l_route_id);
    FETCH l_get_ops_count INTO l_temp_count;
    CLOSE l_get_ops_count;

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'number of operations associated to route:'||l_temp_count
        );
    END IF;

    IF (l_temp_count = 0) THEN
      -- No operations
      RETURN;
    END IF;

--    l_next_start_hour := p_task_dtls.TASK_START_HOUR;  -- Start hour of first operation w.r.t visit
    l_oper_END_TIME :=p_task_dtls.TASK_START_TIME;

    IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_task_dtls.TASK_START_TIME:'||TO_CHAR(p_task_dtls.TASK_START_TIME, 'DD-MON-YYYY hh24:mi')
        );
    END IF;

    OPEN l_get_rt_oper_csr(l_route_id);
    LOOP
      FETCH l_get_rt_oper_csr INTO l_operation_id, l_operation_step;
      EXIT WHEN l_get_rt_oper_csr%NOTFOUND;

  --    Ahl_Debug_Pub.debug('l_operation_id:'||l_operation_id);
       l_temp_duration := 0;

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string
          (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'l_operation_id:'||l_operation_id
          );
          fnd_log.string
          (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'l_operation_step:'||l_operation_step
          );
       END IF;

       -- Get the duration of the operation
       Get_Oper_Max_Duration(l_operation_id, l_temp_duration);

       l_oper_START_TIME := l_oper_END_TIME;
       l_oper_END_TIME := AHL_VWP_TIMES_PVT.COMPUTE_DATE(l_oper_START_TIME,p_department_id,l_temp_duration);

       IF (l_log_statement >= l_log_current_level) THEN
          fnd_log.string
          (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'operation duration:'||l_temp_duration
          );
          fnd_log.string
          (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'l_oper_START_TIME:'||TO_CHAR(l_oper_START_TIME, 'DD-MON-YYYY hh24:mi')
          );
          fnd_log.string
          (
            fnd_log.level_statement,
            'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
            'l_oper_END_TIME:'||TO_CHAR(l_oper_END_TIME, 'DD-MON-YYYY hh24:mi')
          );
       END IF;

       -- Add resource requirements to output table only if operation start/end date
       -- overlaps with the given period

       IF (Periods_Overlap(l_oper_START_TIME,l_oper_END_TIME,p_start_time, p_end_time)) THEN

         OPEN l_oper_resource_dtl_csr(l_operation_id,p_department_id,p_organization_id);
         LOOP
           FETCH l_oper_resource_dtl_csr INTO l_oper_resource_dtl_rec;
           EXIT WHEN l_oper_resource_dtl_csr%NOTFOUND;

                p_x_tp_dtls_tbl(l_table_index).VISIT_ID := p_visit_id;
                p_x_tp_dtls_tbl(l_table_index).TASK_ID := p_task_dtls.VISIT_TASK_ID;
                p_x_tp_dtls_tbl(l_table_index).ROUTE_ID := l_route_id;
                p_x_tp_dtls_tbl(l_table_index).MR_ROUTE_ID := p_task_dtls.MR_ROUTE_ID;
                p_x_tp_dtls_tbl(l_table_index).OPERATION_ID := l_operation_id;
                p_x_tp_dtls_tbl(l_table_index).STEP := l_operation_step;

                p_x_tp_dtls_tbl(l_table_index).START_HOUR := to_number(to_char(l_oper_START_TIME,'HH24'));
                p_x_tp_dtls_tbl(l_table_index).MAX_DURATION := l_temp_duration;
                p_x_tp_dtls_tbl(l_table_index).END_HOUR := to_number(to_char(l_oper_END_TIME,'HH24'));
                p_x_tp_dtls_tbl(l_table_index).START_TIME := l_oper_START_TIME;
                p_x_tp_dtls_tbl(l_table_index).END_TIME := l_oper_END_TIME;

                p_x_tp_dtls_tbl(l_table_index).QUANTITY := l_oper_resource_dtl_rec.quantity;
                p_x_tp_dtls_tbl(l_table_index).ASO_RESOURCE_ID := l_oper_resource_dtl_rec.ASO_RESOURCE_ID;
                p_x_tp_dtls_tbl(l_table_index).BOM_RESOURCE_ID := l_oper_resource_dtl_rec.BOM_RESOURCE_ID;
                p_x_tp_dtls_tbl(l_table_index).DEPARTMENT_ID := p_department_id;

             IF (l_log_statement >= l_log_current_level) THEN
                 fnd_log.string
                 (
                     fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                    'p_x_tp_dtls_tbl('||l_table_index||').OPERATION_ID: '|| p_x_tp_dtls_tbl(l_table_index).OPERATION_ID
                 );
                 fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                    'p_x_tp_dtls_tbl('||l_table_index||').start_time: '|| TO_CHAR(p_x_tp_dtls_tbl(l_table_index).start_time, 'DD-MON-YYYY hh24:mi')
                 );
                 fnd_log.string
                 (
                    fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                    'p_x_tp_dtls_tbl('||l_table_index||').end_time: '|| TO_CHAR( p_x_tp_dtls_tbl(l_table_index).end_time, 'DD-MON-YYYY hh24:mi')
                 );
                 fnd_log.string
                 (
                     fnd_log.level_statement,
                    'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                    'p_x_tp_dtls_tbl('||l_table_index||').bom_resource_id: '|| p_x_tp_dtls_tbl(l_table_index).bom_resource_id
                 );
                 fnd_log.string
                 (
                     fnd_log.level_statement,
                     'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
                     'p_x_tp_dtls_tbl('||l_table_index||').quantity: '|| p_x_tp_dtls_tbl(l_table_index).quantity
                 );
             END IF;

             l_table_index := l_table_index + 1;

         END LOOP; -- Loop through operation resources
         CLOSE l_oper_resource_dtl_csr;

       END IF; -- period overlap

      END LOOP; --loop through all operations
      CLOSE l_get_rt_oper_csr;

  END IF; -- l_temp_count >0 (route resource number >0)

END Get_Operation_Details;
-- yazhou 24Aug2005 ends

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

----------------------------------------
-- Filters out requirements that don't require the given resource for the given period
----------------------------------------
PROCEDURE Filter_By_Resource
(
    p_resource_id    IN      NUMBER,
  p_start_time     IN      DATE,
  p_end_time       IN      DATE,
    p_x_tp_dtls_tbl  IN OUT  NOCOPY Time_Period_Details_Tbl_Type
) IS

  l_temp_table Time_Period_Details_Tbl_Type;
  l_table_index NUMBER;

  l_api_name        CONSTANT VARCHAR2(30) := 'Filter_By_Resource';

BEGIN

  IF (p_resource_id IS NULL) THEN
    -- Error
    FND_MESSAGE.Set_Name('AHL','AHL_LTP_RSRC_ID_NULL');
    FND_MSG_PUB.ADD;
    RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_resource_id: '|| p_resource_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_start_time: '||  TO_CHAR( p_start_time, 'DD-MON-YYYY hh24:mi')
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_end_time: '|| TO_CHAR( p_end_time, 'DD-MON-YYYY hh24:mi')
        );

   END IF;

  IF (p_x_tp_dtls_tbl.COUNT > 0) THEN

      l_table_index := 0;

      FOR i in p_x_tp_dtls_tbl.FIRST .. p_x_tp_dtls_tbl.LAST LOOP

        -- keep the requirement only if it's for the given resource
        -- and falls in the given period
        IF p_x_tp_dtls_tbl(i).bom_resource_id = p_resource_id AND
          (Periods_Overlap (p_x_tp_dtls_tbl(i).START_TIME,p_x_tp_dtls_tbl(i).END_TIME,
             p_start_time, p_end_time)) THEN

            l_temp_table(l_table_index) := p_x_tp_dtls_tbl(i);

            l_table_index := l_table_index + 1;

        END IF; -- l_rsrc_exist_cur%FOUND

      END LOOP;
    END IF;

  -- Assign Local table to Output Parameter
  p_x_tp_dtls_tbl := l_temp_table;

IF p_x_tp_dtls_tbl.COUNT >0 THEN
  FOR i IN p_x_tp_dtls_tbl.FIRST..p_x_tp_dtls_tbl.LAST
  LOOP

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').visit_id: '|| p_x_tp_dtls_tbl(i).visit_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').route_id: '|| p_x_tp_dtls_tbl(i).route_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').mr_route_id: '|| p_x_tp_dtls_tbl(i).mr_route_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').operation_id: '|| p_x_tp_dtls_tbl(i).operation_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').task_id: '|| p_x_tp_dtls_tbl(i).task_id
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').start_time: '|| p_x_tp_dtls_tbl(i).start_time
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').end_time: '|| p_x_tp_dtls_tbl(i).end_time
        );

      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||i||').quantity: '|| p_x_tp_dtls_tbl(i).quantity
        );

    END IF;
 END LOOP;
END IF;


END Filter_By_Resource;

-- yazhou 24Aug2005 ends


--
/* Commented by rnahata since its not being used
PROCEDURE get_qty_By_Resource
(
    p_resource_id    IN      NUMBER,
    p_aso_bom_type   IN      VARCHAR2,
    p_x_tp_dtls_tbl  IN OUT  NOCOPY Time_Period_Details_Tbl_Type
) IS
  CURSOR l_aso_rsrc_csr(p_aso_rsrc_id IN NUMBER,
                         p_object_id   IN NUMBER,
                         p_object_type IN VARCHAR2) IS
    SELECT QUANTITY FROM ahl_rt_oper_resources WHERE
    ASO_RESOURCE_ID = p_aso_rsrc_id AND
    OBJECT_ID = p_object_id AND
    ASSOCIATION_TYPE_CODE = p_object_type;


  l_temp_table Time_Period_Details_Tbl_Type;
  l_table_index NUMBER := 1;
  l_quantity    NUMBER;

BEGIN
  IF (p_resource_id IS NULL) THEN
    -- Error
    Fnd_Message.Set_Name('AHL','AHL_LTP_RSRC_ID_NULL');
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF (p_aso_bom_type = G_ASO_RESOURCE) THEN
    -- ASO Resource
    IF (p_x_tp_dtls_tbl.COUNT > 0) THEN
      FOR i IN p_x_tp_dtls_tbl.FIRST .. p_x_tp_dtls_tbl.LAST LOOP
        l_quantity := 0;
        IF (p_x_tp_dtls_tbl(i).OPERATION_ID IS NULL) THEN
          -- Route
          OPEN l_aso_rsrc_csr(p_resource_id, p_x_tp_dtls_tbl(i).ROUTE_ID, G_RT_ASSOC_TYPE);
        ELSE
          -- Operation
          OPEN l_aso_rsrc_csr(p_resource_id, p_x_tp_dtls_tbl(i).OPERATION_ID, G_OPER_ASSOC_TYPE);
        END IF;
        FETCH l_aso_rsrc_csr INTO l_quantity;
        IF (l_aso_rsrc_csr%FOUND AND l_quantity > 0) THEN
          -- Resource used by this Route/Operation: Add to output table
          l_temp_table(l_table_index) := p_x_tp_dtls_tbl(i);
          l_temp_table(l_table_index).QUANTITY := l_quantity;
          l_table_index := l_table_index + 1;
        END IF;
        CLOSE l_aso_rsrc_csr;
      END LOOP;
    END IF;
  ELSE
    -- Error
    Fnd_Message.Set_Name('AHL','AHL_LTP_RSRC_TYPE_INVALID');
    Fnd_Message.Set_Token('RSRC_TYPE', p_aso_bom_type);
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  -- Assign Local table to Output Parameter
  p_x_tp_dtls_tbl := l_temp_table;
END Get_qty_By_Resource;
*/

----------------------------------------
-- Creates Timeperiods from the start time and end time based on the UOM
-- and populates the table
-- //@@@@@ Formatting hardcoding to be removed
----------------------------------------
PROCEDURE Create_Time_Periods
(
    p_start_time     IN DATE,
    p_end_time       IN DATE,
    p_UOM_code       IN VARCHAR2,
    p_org_id         IN NUMBER,
    p_dept_id        IN NUMBER,
    x_per_rsrc_tbl OUT NOCOPY Period_Rsrc_Req_Tbl_Type
) IS

  CURSOR l_dept_shift_csr(p_department_id IN NUMBER) IS
    SELECT calendar_code, shift_num FROM ahl_department_shifts
    WHERE department_id = p_department_id;

  CURSOR l_shift_times_csr(p_calendar_code IN VARCHAR2, p_shift_num IN NUMBER) IS
    SELECT FROM_TIME, TO_TIME FROM bom_shift_times
    WHERE CALENDAR_CODE = p_calendar_code AND
    SHIFT_NUM = p_shift_num;

  CURSOR l_workday_pattern_csr(p_calendar_code IN VARCHAR2, p_shift_num IN NUMBER) IS
    SELECT DAYS_ON, DAYS_OFF FROM bom_workday_patterns
    WHERE CALENDAR_CODE = p_calendar_code AND
    SHIFT_NUM = p_shift_num;

  CURSOR l_calendar_csr(p_calendar_code IN VARCHAR2) IS
    SELECT CALENDAR_START_DATE, CALENDAR_END_DATE FROM bom_calendars
    WHERE CALENDAR_CODE = p_calendar_code;

  CURSOR l_dept_name_csr (c_org_id IN NUMBER,
                          c_dept_id IN NUMBER)
  IS
   SELECT  description FROM bom_departments
     WHERE organization_id = c_org_id
      AND department_id = c_dept_id;

  l_api_name        CONSTANT VARCHAR2(30) := 'Create_Time_Periods';

  l_temp_start  DATE;
  l_temp_end    DATE;
  l_temp_index  NUMBER := 1;
  l_temp_num    NUMBER;
  l_check_date  BOOLEAN := TRUE;
  l_working_day BOOLEAN;
  l_dept_name   VARCHAR2(80);

  L_CALENDAR_CODE  VARCHAR2(10);
  L_SHIFT_NUM   NUMBER;
  L_CAL_START   DATE;
  L_CAL_END     DATE;
  L_SHIFT_START NUMBER;
  L_SHIFT_END   NUMBER;
  L_DAYS_ON     NUMBER;
  L_DAYS_OFF    NUMBER;

BEGIN

     IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_start_time:'||TO_CHAR( p_start_time, 'DD-MON-YYYY hh24:mi')
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_end_time:'||TO_CHAR( p_end_time, 'DD-MON-YYYY hh24:mi')
        );
     END IF;

  -- First, Get all Calendar/Shift Values
  OPEN l_dept_name_csr(p_org_id,p_dept_id);
  FETCH l_dept_name_csr INTO l_dept_name;
  CLOSE l_dept_name_csr;
  --
  -- Get the Calendar code and Shift Num for the department
  OPEN l_dept_shift_csr(p_dept_id);
  FETCH l_dept_shift_csr INTO L_CALENDAR_CODE, L_SHIFT_NUM;
  IF (l_dept_shift_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_SHIFT_FOR_DEPT');
    Fnd_Message.Set_Token('DEPT_ID', l_dept_name);
    Fnd_Msg_Pub.ADD;
    CLOSE l_dept_shift_csr;
    Ahl_Debug_Pub.debug('No shift/calendar code for department: ' || p_dept_id, 'LTP: Create_Time_Periods');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_dept_shift_csr;
--  dbms_output.put_line('L_CALENDAR_CODE := ' || L_CALENDAR_CODE);
--  dbms_output.put_line('L_SHIFT_NUM := ' || L_SHIFT_NUM);

  -- Get the calendar start date and the calendar end date
  OPEN l_calendar_csr(L_CALENDAR_CODE);
  FETCH l_calendar_csr INTO L_CAL_START, L_CAL_END;
  IF (l_calendar_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_CAL_CODE_INVALID');
    Fnd_Message.Set_Token('CAL_CODE', L_CALENDAR_CODE);
    Fnd_Msg_Pub.ADD;
    CLOSE l_calendar_csr;
    Ahl_Debug_Pub.debug('No BOM_CALENDARS entry for calendar code: ' || L_CALENDAR_CODE, 'LTP: Create_Time_Periods');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_calendar_csr;
  -- Truncate the date values
  L_CAL_START := TRUNC(L_CAL_START);
  L_CAL_END := TRUNC(L_CAL_END);
--  dbms_output.put_line('L_CAL_START := ' || L_CAL_START);
--  dbms_output.put_line('L_CAL_END := ' || L_CAL_END);

  -- Get Days On and Days Off
  OPEN l_workday_pattern_csr(L_CALENDAR_CODE, L_SHIFT_NUM);
  FETCH l_workday_pattern_csr INTO L_DAYS_ON, L_DAYS_OFF;
  IF (l_workday_pattern_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_PTRN_FOR_DEPT');
    Fnd_Message.Set_Token('DEPT_ID', l_dept_name);
    Fnd_Msg_Pub.ADD;
    CLOSE l_workday_pattern_csr;
    Ahl_Debug_Pub.debug('No Work Day Pattern for department: ' || p_dept_id, 'LTP: Create_Time_Periods');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_workday_pattern_csr;

  -- Start processing based on UOM code
  IF (p_UOM_code = G_UOM_HOUR) THEN
--    dbms_output.put_line('Hour UOM');
    -- Get the shift start and shift end times
    OPEN l_shift_times_csr(L_CALENDAR_CODE, L_SHIFT_NUM);
    FETCH l_shift_times_csr INTO L_SHIFT_START, L_SHIFT_END;
    IF (l_shift_times_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_NO_SHIFT_FOR_DEPT');
      Fnd_Message.Set_Token('DEPT_ID', l_dept_name);
      Fnd_Msg_Pub.ADD;
      CLOSE l_shift_times_csr;
      Ahl_Debug_Pub.debug('No shift start and end times for department: ' || p_dept_id, 'LTP: Create_Time_Periods');
      RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
    END IF;
    CLOSE l_shift_times_csr;
--    dbms_output.put_line('L_SHIFT_START := ' || L_SHIFT_START);
--    dbms_output.put_line('L_SHIFT_END := ' || L_SHIFT_END);

   -- Break up into hours
    l_temp_start := p_start_time;
    l_temp_end := p_end_time;
    WHILE (l_temp_start < l_temp_end) LOOP
--      dbms_output.put_line('l_temp_start = ' || l_temp_start);
      IF (l_check_date) THEN
        l_working_day := FALSE;
        l_temp_num := MOD((TRUNC(l_temp_start) - L_CAL_START), (L_DAYS_ON + L_DAYS_OFF)) + 1;
        IF (l_temp_num <= L_DAYS_ON) THEN
--          dbms_output.put_line('Not Day Off');
          -- Not Day Off: Check if Holiday
          IF(Not_A_Holiday(l_temp_start, p_dept_id)) THEN
--            dbms_output.put_line('Not a holiday');
            -- Working Day: Check if day is in calendar range
            IF(l_temp_start > L_CAL_END) THEN
              Fnd_Message.Set_Name('AHL','AHL_LTP_INSUFFICIENT_CAL_RANGE');
              Fnd_Msg_Pub.ADD;
              Ahl_Debug_Pub.debug('Computed date (' || l_temp_start|| ') is outside calendar range', 'LTP: Init_Time_Vars');
              RAISE  Fnd_Api.G_EXC_ERROR;
            END IF;
            l_working_day := TRUE;
          END IF;  -- Not a holiday
        END IF;  -- Not Day Off
      END IF;
      IF (l_working_day) THEN
        -- Check if hour is valid
        l_temp_num := (l_temp_start - TRUNC(l_temp_start)) * G_SECS_IN_DAY;
        IF ((L_SHIFT_START < L_SHIFT_END AND l_temp_num >= L_SHIFT_START AND l_temp_num < L_SHIFT_END) OR
            (L_SHIFT_START > L_SHIFT_END AND (l_temp_num >= L_SHIFT_START OR l_temp_num < L_SHIFT_END))) THEN
--          dbms_output.put_line('In Shift');
          x_per_rsrc_tbl(l_temp_index).PERIOD_START := l_temp_start;
          -- //@@@@@ Remove Hardcoding
          x_per_rsrc_tbl(l_temp_index).PERIOD_STRING := TO_CHAR(l_temp_start, 'DD-MM-YYYY HH:MI:SS AM');
          x_per_rsrc_tbl(l_temp_index).PERIOD_END := l_temp_start + (1/24);  -- 1 Hour Long
          IF ((l_temp_num + G_SECS_IN_HOUR) = L_SHIFT_END) THEN
            l_check_date := TRUE;  -- Last Hour of Shift: Check if next day is a working Day
          ELSE
            l_check_date := FALSE;  -- Not Last Hour of Shift: No need to Check again if this is a working Day
          END IF;
          l_temp_index := l_temp_index + 1;
        END IF;  -- Hour Valid
        l_temp_start := l_temp_start + (1/24);  -- Next Hour
      ELSE
        -- Not a working day: Go the start of shift of next day
        l_temp_start := TRUNC(l_temp_start) + 1 + (L_SHIFT_START/G_SECS_IN_DAY);
      END IF;  -- Working Day
    END LOOP;
  ELSIF (p_UOM_code = G_UOM_DAY) THEN
--    dbms_output.put_line('Day UOM');
    -- Break up into days
    l_temp_start := p_start_time;
    l_temp_end := p_end_time;
    WHILE (l_temp_start < l_temp_end) LOOP
--      dbms_output.put_line('l_temp_start = ' || l_temp_start);
      l_temp_num := MOD((TRUNC(l_temp_start) - L_CAL_START), (L_DAYS_ON + L_DAYS_OFF)) + 1;
      IF (l_temp_num <= L_DAYS_ON) THEN
--        dbms_output.put_line('Not Day Off');
        -- Not Day Off: Check if Holiday
        IF(Not_A_Holiday(l_temp_start, p_dept_id)) THEN
--          dbms_output.put_line('Not a holiday');
          -- Working Day: Check if day is in calendar range
          IF(l_temp_start > L_CAL_END) THEN
            Fnd_Message.Set_Name('AHL','AHL_LTP_INSUFFICIENT_CAL_RANGE');
            Fnd_Msg_Pub.ADD;
            Ahl_Debug_Pub.debug('Computed date (' || l_temp_start || ') is outside calendar range', 'LTP: Init_Time_Vars');
            RAISE  Fnd_Api.G_EXC_ERROR;
          END IF;
          x_per_rsrc_tbl(l_temp_index).PERIOD_START := trunc(l_temp_start);
          -- //@@@@@ Remove Hardcoding
          x_per_rsrc_tbl(l_temp_index).PERIOD_STRING := TO_CHAR(l_temp_start, 'DD-MM-YYYY');

  Ahl_Debug_Pub.debug('before create time day:'||p_UOM_code||x_per_rsrc_tbl(l_temp_index).PERIOD_STRING);

-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design

          x_per_rsrc_tbl(l_temp_index).PERIOD_END := l_temp_start + 1;  -- 1 Day long
--          x_per_rsrc_tbl(l_temp_index).PERIOD_END := trunc(l_temp_start);  -- 1 Day long

-- yazhou 24Aug2005 ends

          l_temp_index := l_temp_index + 1;

        END IF;  -- Not a holiday
      END IF;  -- Not Day Off
      l_temp_start := l_temp_start + 1;  -- Next Day
    END LOOP;
  ELSIF (p_UOM_code = G_UOM_WEEK) THEN
--    dbms_output.put_line('Week UOM');
    -- Break up into weeks
    l_temp_start := p_start_time;
    l_temp_end := p_end_time;
    WHILE (l_temp_start < l_temp_end) LOOP
      x_per_rsrc_tbl(l_temp_index).PERIOD_START := l_temp_start;
      -- //@@@@@ Remove Hardcoding
      x_per_rsrc_tbl(l_temp_index).PERIOD_STRING := TO_CHAR(l_temp_start, 'DD-MM-YYYY');
--      l_temp_start := l_temp_start + 7;  -- 7 Days
      l_temp_start := l_temp_start + 6;  -- 7 Days
      x_per_rsrc_tbl(l_temp_index).PERIOD_END := l_temp_start;
      l_temp_start :=  l_temp_start + 1;  -- 7 Days
      l_temp_index := l_temp_index + 1;
    END LOOP;
  ELSIF (p_UOM_code = G_UOM_MONTH) THEN
--    dbms_output.put_line('Month UOM');
    -- Break up into months
    l_temp_start := p_start_time;
    l_temp_end := p_end_time;
    WHILE (l_temp_start < l_temp_end) LOOP
      x_per_rsrc_tbl(l_temp_index).PERIOD_START := l_temp_start;
      IF (l_temp_index = 1) THEN
        -- //@@@@@ Remove Hardcoding
        x_per_rsrc_tbl(l_temp_index).PERIOD_STRING := TO_CHAR(l_temp_start, 'DD-MM-YYYY');


      ELSE
        -- //@@@@@ Remove Hardcoding
        x_per_rsrc_tbl(l_temp_index).PERIOD_STRING := TO_CHAR(l_temp_start, 'fmMONTH YYYY');
      END IF;
      SELECT LAST_DAY(l_temp_start) INTO l_temp_start FROM DUAL;
      l_temp_start := l_temp_start + 1;  -- First day of next month
      x_per_rsrc_tbl(l_temp_index).PERIOD_END := l_temp_start;
      l_temp_index := l_temp_index + 1;

    END LOOP;
  ELSE
    -- Invalid UOM Code
    Fnd_Message.Set_Name('AHL','AHL_LTP_UOM_CODE_INVALID');
    Fnd_Message.Set_Token('UOM_CODE', p_UOM_code);
    Fnd_Msg_Pub.ADD;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;
  -- Ensure that the end time of the last period does not exceed user given end time
  IF (l_temp_index > 1 AND (x_per_rsrc_tbl(l_temp_index - 1).PERIOD_END > l_temp_end)) THEN
    x_per_rsrc_tbl(l_temp_index - 1).PERIOD_END := l_temp_end;
  END IF;

  --For debug
  IF x_per_rsrc_tbl.COUNT > 0 THEN
    FOR i in x_per_rsrc_tbl.FIRST..x_per_rsrc_tbl.LAST LOOP

     IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_per_rsrc_tbl('||i||') START:'||TO_CHAR( x_per_rsrc_tbl(i).PERIOD_START, 'DD-MON-YYYY hh24:mi')
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_per_rsrc_tbl('||i||') END:'||TO_CHAR( x_per_rsrc_tbl(i).PERIOD_END, 'DD-MON-YYYY hh24:mi')
        );
      fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'x_per_rsrc_tbl('||i||') STRING:'||x_per_rsrc_tbl(i).PERIOD_STRING
        );

     END IF;
    END LOOP;
  END IF;
  --
END Create_Time_Periods;

----------------------------------------
-- Sorts the Quantity Change table based on event time
----------------------------------------
PROCEDURE Sort_Qty_Change_Table
(
    p_x_qty_change_tbl  IN OUT NOCOPY Qty_Change_Tbl_Type
) IS

  l_temp_qty_chng_rec  Qty_Change_Rec_Type;

BEGIN
  IF (p_x_qty_change_tbl.COUNT < 2) THEN
    RETURN;
  END IF;
  FOR i IN p_x_qty_change_tbl.FIRST .. (p_x_qty_change_tbl.LAST - 1) LOOP
    FOR j IN (i + 1) .. p_x_qty_change_tbl.LAST LOOP
      IF (p_x_qty_change_tbl(i).EVENT_TIME > p_x_qty_change_tbl(j).EVENT_TIME) THEN
        -- Swap
        l_temp_qty_chng_rec := p_x_qty_change_tbl(i);
        p_x_qty_change_tbl(i) := p_x_qty_change_tbl(j);
        p_x_qty_change_tbl(j) := l_temp_qty_chng_rec;
      END IF;
    END LOOP;
  END LOOP;
END Sort_Qty_Change_Table;

----------------------------------------
-- Sorts the Time_Period_Details_Tbl By Visit/Task
----------------------------------------
PROCEDURE Sort_By_Visit_Task
(
    p_x_tp_tbl  IN OUT NOCOPY Time_Period_Details_Tbl_Type
) IS

  l_temp_tp_rec  Time_Period_Details_Rec_Type;

BEGIN
  IF (p_x_tp_tbl.COUNT < 2) THEN
    RETURN;
  END IF;
  FOR i IN p_x_tp_tbl.FIRST .. (p_x_tp_tbl.LAST - 1) LOOP
    FOR j IN (i + 1) .. p_x_tp_tbl.LAST LOOP
      IF (Compare_Visit_Tasks(p_x_tp_tbl(i).VISIT_ID, p_x_tp_tbl(i).TASK_ID , p_x_tp_tbl(j).VISIT_ID, p_x_tp_tbl(j).TASK_ID) > 0) THEN
        -- Swap
        l_temp_tp_rec := p_x_tp_tbl(i);
        p_x_tp_tbl(i) := p_x_tp_tbl(j);
        p_x_tp_tbl(j) := l_temp_tp_rec;
      END IF;
    END LOOP;
  END LOOP;
END Sort_By_Visit_Task;

----------------------------------------
-- Aggregates Task Quantities and gets Task and Visit Names
----------------------------------------
PROCEDURE Aggregate_Task_Quantities
(   P_resource_id      IN  NUMBER,
    P_org_name         IN  VARCHAR2,
    P_dept_name        IN  VARCHAR2,
    p_tp_dtls_table    IN  Time_Period_Details_Tbl_Type,
    x_task_req_tbl     OUT NOCOPY Task_Requirement_Tbl_Type
) IS

  CURSOR l_get_visit_name_csr(p_visit_id IN NUMBER) IS
    SELECT VISIT_NAME, VISIT_NUMBER FROM ahl_visits_vl WHERE
    VISIT_ID = p_visit_id;

  CURSOR l_get_task_name_csr(p_task_id IN NUMBER) IS
    SELECT VISIT_TASK_NAME,TASK_TYPE_CODE FROM ahl_visit_tasks_vl WHERE
    VISIT_TASK_ID = p_task_id;
  --
  CURSOR l_get_dept_cur (c_dept_name IN VARCHAR2,
                         c_org_name  IN VARCHAR2)
   IS
   SELECT B.department_id,A.organization_id FROM
         HR_ALL_ORGANIZATION_UNITS A, BOM_DEPARTMENTS B
   WHERE A.organization_id = B.organization_id
     AND a.name            = c_org_name
     AND b.description     = c_dept_name;
  --
  l_visit_id   NUMBER;
  l_task_id    NUMBER;
  l_qty        NUMBER;
  l_required_qty  NUMBER;
  l_available_qty NUMBER;
  l_new_index  NUMBER := 1;
  l_task_name  VARCHAR2(80);
  l_prev_visit_id  NUMBER := -1;
  l_prev_visit_name VARCHAR2(80);
  l_prev_visit_number NUMBER;
  l_task_type_code VARCHAR2(30);
  l_dept_id     NUMBER;
  l_org_id      NUMBER;
BEGIN
  IF (p_tp_dtls_table.COUNT = 0) THEN
    RETURN;
  END IF;
  --
Ahl_Debug_Pub.debug('enter aggtegate O'||p_org_name);
Ahl_Debug_Pub.debug('enter aggtegate D'||p_dept_name);

  --Get dept id
  OPEN l_get_dept_cur(p_dept_name,p_org_name);
  FETCH l_get_dept_cur INTO l_dept_id,l_org_id;
  CLOSE l_get_dept_cur;
  --
Ahl_Debug_Pub.debug('AFTER CURSOR aggtegate'||l_org_id);
Ahl_Debug_Pub.debug('AFTER CURSOR aggtegate'||l_dept_id);

  --
  l_visit_id := p_tp_dtls_table(p_tp_dtls_table.FIRST).VISIT_ID;
  l_task_id := p_tp_dtls_table(p_tp_dtls_table.FIRST).TASK_ID;
  l_qty := p_tp_dtls_table(p_tp_dtls_table.FIRST).QUANTITY;
  l_required_qty := p_tp_dtls_table(p_tp_dtls_table.FIRST).REQUIRED_UNITS;
  l_available_qty := Get_Available_Units(p_resource_id, l_dept_id);


  Ahl_Debug_Pub.debug('l_qty aggregate visit:'||l_qty);
  Ahl_Debug_Pub.debug('l_visit_id aggregate visit:'||l_visit_id);
  Ahl_Debug_Pub.debug('l_task_id aggregate visit:'||l_task_id);

  FOR i IN p_tp_dtls_table.FIRST .. p_tp_dtls_table.LAST LOOP
    IF (p_tp_dtls_table(i).VISIT_ID <> l_visit_id OR p_tp_dtls_table(i).TASK_ID <> l_task_id) THEN
      -- New Visit Task: Update x_task_req_tbl
      x_task_req_tbl(l_new_index).VISIT_ID := l_visit_id;
      x_task_req_tbl(l_new_index).TASK_ID := l_task_id;
      x_task_req_tbl(l_new_index).REQUIRED_UNITS := l_qty;
      x_task_req_tbl(l_new_index).AVAILABLE_UNITS := l_available_qty;

      IF (l_visit_id <> l_prev_visit_id) THEN
        -- Get Visit Name, Visit Number
        OPEN l_get_visit_name_csr(l_visit_id);
        FETCH l_get_visit_name_csr INTO l_prev_visit_name, l_prev_visit_number;
        IF (l_get_visit_name_csr%NOTFOUND) THEN
          Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ID_INVALID');
          Fnd_Message.Set_Token('VISIT_ID', l_visit_id);
          Fnd_Msg_Pub.ADD;
          CLOSE l_get_visit_name_csr;
          RAISE  Fnd_Api.G_EXC_ERROR;
        END IF;
        CLOSE l_get_visit_name_csr;
        l_prev_visit_id := l_visit_id;
      END IF;
      x_task_req_tbl(l_new_index).VISIT_NAME := l_prev_visit_name;
      x_task_req_tbl(l_new_index).VISIT_NUMBER := l_prev_visit_number;
      x_task_req_tbl(l_new_index).REQUIRED_UNITS := l_qty;
      x_task_req_tbl(l_new_index).AVAILABLE_UNITS := l_available_qty;
      x_task_req_tbl(l_new_index).DEPT_NAME := P_dept_name;

      -- Get Task Name
      OPEN l_get_task_name_csr(l_task_id);
      FETCH l_get_task_name_csr INTO l_task_name,l_task_type_code;
      IF (l_get_task_name_csr%NOTFOUND) THEN
        Fnd_Message.Set_Name('AHL','AHL_LTP_TASK_ID_INVALID');
        Fnd_Message.Set_Token('TASK_ID', l_task_id);
        Fnd_Msg_Pub.ADD;
        CLOSE l_get_task_name_csr;
        RAISE  Fnd_Api.G_EXC_ERROR;
      END IF;
      CLOSE l_get_task_name_csr;
      x_task_req_tbl(l_new_index).VISIT_TASK_NAME := l_task_name;
      x_task_req_tbl(l_new_index).TASK_TYPE_CODE := l_task_type_code;
      x_task_req_tbl(l_new_index).REQUIRED_UNITS := l_qty;
      x_task_req_tbl(l_new_index).AVAILABLE_UNITS := l_available_qty;
      x_task_req_tbl(l_new_index).DEPT_NAME := P_dept_name;

      l_new_index := l_new_index + 1;
      -- Next, update l_visit_id, l_task_id and l_qty
      l_visit_id := p_tp_dtls_table(i).VISIT_ID;
      l_task_id := p_tp_dtls_table(i).TASK_ID;
      l_qty := p_tp_dtls_table(i).QUANTITY;
      l_required_qty := p_tp_dtls_table(i).REQUIRED_UNITS;
--      l_available_qty := p_tp_dtls_table(i).AVAILABLE_UNITS;
    ELSE
      -- Same Visit/Task: Update l_qty if required
      IF (p_tp_dtls_table(i).QUANTITY > l_qty) THEN
        l_qty := p_tp_dtls_table(i).QUANTITY;
      END IF;
    END IF;
  END LOOP;

  -- Add for last visit/task
  x_task_req_tbl(l_new_index).VISIT_ID := l_visit_id;
  x_task_req_tbl(l_new_index).TASK_ID := l_task_id;
  x_task_req_tbl(l_new_index).REQUIRED_UNITS := l_qty;
  x_task_req_tbl(l_new_index).TASK_TYPE_CODE := l_task_type_code;
  x_task_req_tbl(l_new_index).AVAILABLE_UNITS := l_available_qty;
  x_task_req_tbl(l_new_index).DEPT_NAME := P_dept_name;

  IF (l_visit_id <> l_prev_visit_id) THEN
    -- Get Visit Name
    OPEN l_get_visit_name_csr(l_visit_id);
    FETCH l_get_visit_name_csr INTO l_prev_visit_name, l_prev_visit_number;
    IF (l_get_visit_name_csr%NOTFOUND) THEN
      Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ID_INVALID');
      Fnd_Message.Set_Token('VISIT_ID', l_visit_id);
      Fnd_Msg_Pub.ADD;
      CLOSE l_get_visit_name_csr;
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
    CLOSE l_get_visit_name_csr;
  END IF;
  x_task_req_tbl(l_new_index).VISIT_NAME := l_prev_visit_name;
  x_task_req_tbl(l_new_index).VISIT_NUMBER := l_prev_visit_number;
  -- Get Task Name
  OPEN l_get_task_name_csr(l_task_id);
  FETCH l_get_task_name_csr INTO l_task_name,l_task_type_code;
  IF (l_get_task_name_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_TASK_ID_INVALID');
    Fnd_Message.Set_Token('TASK_ID', l_task_id);
    Fnd_Msg_Pub.ADD;
    CLOSE l_get_task_name_csr;
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;
  CLOSE l_get_task_name_csr;
  x_task_req_tbl(l_new_index).VISIT_TASK_NAME := l_task_name;
  x_task_req_tbl(l_new_index).TASK_TYPE_CODE := l_task_type_code;
  x_task_req_tbl(l_new_index).DEPT_NAME := P_dept_name;
  x_task_req_tbl(l_new_index).REQUIRED_UNITS := l_qty;
  x_task_req_tbl(l_new_index).AVAILABLE_UNITS := l_available_qty;
  x_task_req_tbl(l_new_index).DEPT_NAME := P_dept_name;
  -- For debugging
  IF x_task_req_tbl.COUNT > 0 THEN
    FOR i in x_task_req_tbl.FIRST..x_task_req_tbl.LAST
    LOOP
      --
        Ahl_Debug_Pub.debug('END Task quantites VISIT TASK:'||x_task_req_tbl(i).visit_task_name);
        Ahl_Debug_Pub.debug('END Task quantites REQUNITS:'||x_task_req_tbl(i).required_units);
        Ahl_Debug_Pub.debug('END Task quantites AUNITS:'||x_task_req_tbl(i).available_units);
    --
    END LOOP;
  END IF;
  --
END Aggregate_Task_Quantities;
----------------------------------------
-- Gets the duration of a route from the timespan column
-- of ahl_routes_b table
----------------------------------------
PROCEDURE Get_Route_Duration
(
    p_route_id  IN  NUMBER,
    x_duration  OUT NOCOPY NUMBER
) IS

   CURSOR l_route_csr (p_route_id IN NUMBER) IS
    SELECT route_id FROM ahl_mr_routes_app_v
    WHERE mr_route_id = p_route_id;

  CURSOR l_route_time_span_csr (p_route_id IN NUMBER) IS
    SELECT NVL(time_span, 0) FROM ahl_routes_b
    WHERE route_id = p_route_id;
  x_route_id NUMBER;
BEGIN

  OPEN l_route_csr(p_route_id);
  FETCH l_route_csr INTO x_route_id;
  IF (l_route_csr%FOUND) THEN

      OPEN l_route_time_span_csr(x_route_id);
      FETCH l_route_time_span_csr INTO x_duration;
      IF (l_route_time_span_csr%NOTFOUND) THEN
            Fnd_Message.Set_Name('AHL', 'AHL_LTP_ROUTE_ID_INVALID');
            Fnd_Message.Set_Token('ROUTE_ID', p_route_id);
            Fnd_Msg_Pub.ADD;
            CLOSE l_route_time_span_csr;
            Ahl_Debug_Pub.debug('Invalid route Id: ' || x_duration, 'LTP: Get_Route_Duration');
            RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;
      CLOSE l_route_time_span_csr;

 CLOSE l_route_csr;
 END IF;

END Get_Route_Duration;

----------------------------------------
-- Gets the duration of a route based on the resources either directly or through
-- the operations constituting the route
----------------------------------------
PROCEDURE Get_Rt_Ops_Duration
(
    p_route_id  IN  NUMBER,
    x_duration  OUT NOCOPY NUMBER
) IS

  CURSOR l_route_operations_csr(p_route_id IN NUMBER) IS
    SELECT OPERATION_ID FROM ahl_route_operations
    WHERE route_id = p_route_id;

  l_operation_id   NUMBER;
  l_temp_duration  NUMBER := 0;

BEGIN
  x_duration := 0;
  Get_Rt_Max_Duration(p_route_id, l_temp_duration);
  IF (l_temp_duration <> 0) THEN
    -- Defined at Route Level itself. Not necessary to go to operations
    x_duration := l_temp_duration;
    RETURN;
  ELSE
    -- Not defined at route level. Go to operation level
    OPEN l_route_operations_csr(p_route_id);
    LOOP
      FETCH l_route_operations_csr INTO l_operation_id;
      EXIT WHEN l_route_operations_csr%NOTFOUND;
      Get_Oper_Max_Duration(l_operation_id, l_temp_duration);
      x_duration := x_duration + l_temp_duration;
    END LOOP;
  END IF;
  CLOSE l_route_operations_csr;
END Get_Rt_Ops_Duration;

----------------------------------------
-- Gets the time take for a given operation: Gets the maximum of all machines
-- and labor required by this operation
----------------------------------------
PROCEDURE Get_Oper_Max_Duration
(
    p_operation_id  IN  NUMBER,
    x_duration      OUT NOCOPY NUMBER
) IS

  CURSOR l_oper_rsrc_time_csr(p_operation_id IN NUMBER) IS
    SELECT NVL(MAX(duration), 0) FROM ahl_rt_oper_resources
    WHERE OBJECT_ID = p_operation_id AND
    ASSOCIATION_TYPE_CODE = G_OPER_ASSOC_TYPE;

  l_rsrc_max   NUMBER := 0;

BEGIN
  x_duration := 0;
  OPEN l_oper_rsrc_time_csr(p_operation_id);
  FETCH l_oper_rsrc_time_csr INTO l_rsrc_max;
  CLOSE l_oper_rsrc_time_csr;

  x_duration := l_rsrc_max;

END Get_Oper_Max_Duration;

----------------------------------------
-- Gets the time take for a given Route that has no operations: Gets the maximum
-- of all machines and labor required by this Route
----------------------------------------
PROCEDURE Get_Rt_Max_Duration
(
    p_route_id  IN  NUMBER,
    x_duration  OUT NOCOPY NUMBER
) IS

  CURSOR l_rt_rsrc_time_csr(p_route_id IN NUMBER) IS
    SELECT NVL(MAX(duration), 0) FROM ahl_rt_oper_resources
    WHERE OBJECT_ID = p_route_id AND
    ASSOCIATION_TYPE_CODE = G_RT_ASSOC_TYPE;

  l_rsrc_max   NUMBER := 0;

BEGIN
  x_duration := 0;
  OPEN l_rt_rsrc_time_csr(p_route_id);
  FETCH l_rt_rsrc_time_csr INTO l_rsrc_max;
  CLOSE l_rt_rsrc_time_csr;

  x_duration := l_rsrc_max;

END Get_Rt_Max_Duration;

----------------------------------------
-- Calculate and Initialize the global variables used for
-- calculating task dates
----------------------------------------
PROCEDURE Init_Time_Vars
(
  p_visit_start_date IN  DATE,
  p_department_id    IN  NUMBER
) IS

  CURSOR l_dept_shift_csr(p_department_id IN NUMBER) IS
    SELECT calendar_code, shift_num FROM ahl_department_shifts
    WHERE department_id = p_department_id;

  CURSOR l_shift_times_csr(p_calendar_code IN VARCHAR2, p_shift_num IN NUMBER) IS
    SELECT FROM_TIME, TO_TIME FROM bom_shift_times
    WHERE CALENDAR_CODE = p_calendar_code AND
    SHIFT_NUM = p_shift_num;

  CURSOR l_workday_pattern_csr(p_calendar_code IN VARCHAR2, p_shift_num IN NUMBER) IS
    SELECT DAYS_ON, DAYS_OFF FROM bom_workday_patterns
    WHERE CALENDAR_CODE = p_calendar_code AND
    SHIFT_NUM = p_shift_num;

  CURSOR l_calendar_csr(p_calendar_code IN VARCHAR2) IS
    SELECT CALENDAR_START_DATE, CALENDAR_END_DATE FROM bom_calendars
    WHERE CALENDAR_CODE = p_calendar_code;

  CURSOR l_exceptions_csr(p_calendar_code IN VARCHAR2) IS
    SELECT EXCEPTION_DATE FROM bom_calendar_exceptions
    WHERE CALENDAR_CODE = p_calendar_code AND
    EXCEPTION_TYPE = G_HOLIDAY_TYPE
    ORDER BY EXCEPTION_DATE;
   --
   CURSOR l_dept_name_csr(c_dept_id IN NUMBER)
    IS
    SELECT description FROM bom_departments
    WHERE department_id = c_dept_id;

  l_visit_start_date DATE := TRUNC(p_visit_start_date);
  l_temp_date DATE;
  l_temp_index NUMBER := 1;
  l_curr_wday_index NUMBER;
  l_dept_name  VARCHAR2(240);
BEGIN
  -- Clean-up any existing records
  G_WORKING_DATES_TBL.DELETE;
  --Get department name
  OPEN l_dept_name_csr(p_department_id);
  FETCH l_dept_name_csr INTO l_dept_name;
  CLOSE l_dept_name_csr;
  --
  -- Get the Calendar code and Shift Num for the department
  OPEN l_dept_shift_csr(p_department_id);
  FETCH l_dept_shift_csr INTO G_CALENDAR_CODE, G_SHIFT_NUM;
  IF (l_dept_shift_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_SHIFT_FOR_DEPT');
    Fnd_Message.Set_Token('DEPT_ID', l_dept_name);
    Fnd_Msg_Pub.ADD;
    CLOSE l_dept_shift_csr;
    Ahl_Debug_Pub.debug('No shift/calendar code for department: ' || p_department_id, 'LTP: Init_Time_Vars');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_dept_shift_csr;
--  dbms_output.put_line('G_CALENDAR_CODE := ' || G_CALENDAR_CODE);
--  dbms_output.put_line('G_SHIFT_NUM := ' || G_SHIFT_NUM);

  -- Get the calendar start date and the calendar end date
  OPEN l_calendar_csr(G_CALENDAR_CODE);
  FETCH l_calendar_csr INTO G_CAL_START, G_CAL_END;
  IF (l_calendar_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_CAL_CODE_INVALID');
    Fnd_Message.Set_Token('CAL_CODE', G_CALENDAR_CODE);
    Fnd_Msg_Pub.ADD;
    CLOSE l_calendar_csr;
    Ahl_Debug_Pub.debug('No BOM_CALENDARS entry for calendar code: ' || G_CALENDAR_CODE, 'LTP: Init_Time_Vars');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_calendar_csr;
  -- Truncate the date values
  G_CAL_START := TRUNC(G_CAL_START);
  G_CAL_END := TRUNC(G_CAL_END);
--  dbms_output.put_line('G_CAL_START := ' || G_CAL_START);
--  dbms_output.put_line('G_CAL_END := ' || G_CAL_END);

  -- Get the shift start and shift end times
  OPEN l_shift_times_csr(G_CALENDAR_CODE, G_SHIFT_NUM);
  FETCH l_shift_times_csr INTO G_SHIFT_START, G_SHIFT_END;
  IF (l_shift_times_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_SHIFT_FOR_DEPT');
    Fnd_Message.Set_Token('DEPT_ID', l_dept_name);
    Fnd_Msg_Pub.ADD;
    CLOSE l_shift_times_csr;
    Ahl_Debug_Pub.debug('No shift start and end times for department: ' || p_department_id, 'LTP: Init_Time_Vars');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_shift_times_csr;
--  dbms_output.put_line('G_SHIFT_START := ' || G_SHIFT_START);
--  dbms_output.put_line('G_SHIFT_END := ' || G_SHIFT_END);
  IF(G_SHIFT_END < G_SHIFT_START) THEN
     G_SHIFT_DURATION_HRS := (G_SHIFT_END + G_SECS_IN_DAY - G_SHIFT_START)/G_SECS_IN_HOUR;
  ELSE
     G_SHIFT_DURATION_HRS := (G_SHIFT_END - G_SHIFT_START)/G_SECS_IN_HOUR;
  END IF;
--  dbms_output.put_line('G_SHIFT_DURATION_HRS := ' || G_SHIFT_DURATION_HRS);

  -- Get Days On and Days Off
  OPEN l_workday_pattern_csr(G_CALENDAR_CODE, G_SHIFT_NUM);
  FETCH l_workday_pattern_csr INTO G_DAYS_ON, G_DAYS_OFF;
  IF (l_workday_pattern_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_PTRN_FOR_DEPT');
    Fnd_Message.Set_Token('DEPT_ID', l_dept_name);
    Fnd_Msg_Pub.ADD;
    CLOSE l_workday_pattern_csr;
    Ahl_Debug_Pub.debug('No Work Day Pattern for department: ' || p_department_id, 'LTP: Init_Time_Vars');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_workday_pattern_csr;

  -- Get the Exception (Holidays) days
  OPEN l_exceptions_csr(G_CALENDAR_CODE);
  l_temp_index := 1;
  LOOP
    FETCH l_exceptions_csr INTO l_temp_date;
    EXIT WHEN l_exceptions_csr%NOTFOUND;
    G_EXCEPTION_DATES_TBL(l_temp_index) := TRUNC(l_temp_date);
    l_temp_index := l_temp_index + 1;
  END LOOP;
  CLOSE l_exceptions_csr;

  IF (p_visit_start_date IS NULL) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ST_DATE_NULL');
    Fnd_Msg_Pub.ADD;
    Ahl_Debug_Pub.debug('Visit start date is null', 'LTP: Init_Time_Vars');
    RAISE  Fnd_Api.G_EXC_ERROR;
  ELSIF (p_visit_start_date < G_CAL_START OR p_visit_start_date > G_CAL_END) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ST_DATE_INVALID');
    Fnd_Message.Set_Token('VISIT_ST_DATE', p_visit_start_date);
    Fnd_Msg_Pub.ADD;
    Ahl_Debug_Pub.debug('Visit start date (' || p_visit_start_date || ') is outside calendar range', 'LTP: Init_Time_Vars');
    RAISE  Fnd_Api.G_EXC_ERROR;
  END IF;

 --Code fixed by shbhanda on 21st Oct'02
  -- Ensure that the visit start date falls on a working day
  l_curr_wday_index := MOD((l_visit_start_date - G_CAL_START), (G_DAYS_ON + G_DAYS_OFF)) + 1;
  WHILE (l_curr_wday_index > G_DAYS_ON) LOOP
    -- Day Off
    Ahl_Debug_Pub.debug('Visit Start Date = ' ||l_visit_start_date );
    l_visit_start_date := l_visit_start_date + 1;
    l_curr_wday_index := MOD((l_visit_start_date - G_CAL_START), (G_DAYS_ON + G_DAYS_OFF)) + 1;
    Ahl_Debug_Pub.debug('Inside first while loop');
  END LOOP;

    -- Not Day Off: Check if Holiday
  WHILE (IS_DEPT_Holiday(l_visit_start_date)) LOOP
      Ahl_Debug_Pub.debug('Visit Start Date = ' ||l_visit_start_date );
      l_visit_start_date := l_visit_start_date + 1;
      Ahl_Debug_Pub.debug('Inside second while loop');
      -- Holiday
  END LOOP;

  -- Commented by shbhanda 21 Oct '02
 /* -- Ensure that the visit start date falls on a working day
  l_curr_wday_index := MOD((l_visit_start_date - G_CAL_START), (G_DAYS_ON + G_DAYS_OFF)) + 1;
  IF (l_curr_wday_index > G_DAYS_ON) THEN
    -- Day Off
    Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ST_WDATE_INVALID');
    Fnd_Message.Set_Token('VISIT_ST_DATE', p_visit_start_date);
    Fnd_Msg_Pub.ADD;
    Ahl_Debug_Pub.debug('Visit start date (' || p_visit_start_date || ') is not a working day', 'LTP: Init_Time_Vars');
    RAISE  Fnd_Api.G_EXC_ERROR;
  ELSE
    -- Not Day Off: Check if Holiday
    IF(IS_DEPT_Holiday(l_visit_start_date)) THEN
      -- Holiday
      Fnd_Message.Set_Name('AHL','AHL_LTP_VISIT_ST_WDATE_INVALID');
      Fnd_Message.Set_Token('VISIT_ST_DATE', p_visit_start_date);
      Fnd_Msg_Pub.ADD;
      Ahl_Debug_Pub.debug('Visit start date (' || p_visit_start_date || ') is not a working day', 'LTP: Init_Time_Vars');
      RAISE  Fnd_Api.G_EXC_ERROR;
    END IF;
  END IF;*/


  -- Add shift start to l_visit_start_date and set it to G_ZERO_TIME and G_WORKING_DATES_TBL(0)
  l_visit_start_date := l_visit_start_date + (G_SHIFT_START/G_SECS_IN_DAY);
  G_ZERO_TIME := l_visit_start_date;
--  dbms_output.put_line('G_ZERO_TIME := ' || TO_CHAR(G_ZERO_TIME, 'MM/DD/YY HH24:MI:SS'));
  G_WORKING_DATES_TBL(0) := G_ZERO_TIME;
  G_MAX_CAL_DAY := 0;

END Init_Time_Vars;

----------------------------------------
-- Determine the Nth working date (including shift start time)
-- based on the applicable calendar
----------------------------------------
FUNCTION Get_Nth_Day(p_day_index NUMBER) RETURN DATE
IS

  l_temp_index NUMBER;
  l_curr_day   DATE;
  l_curr_wday_index NUMBER;
  l_temp_flag BOOLEAN;

BEGIN
  IF (p_day_index <= G_MAX_CAL_DAY) THEN
    RETURN G_WORKING_DATES_TBL(p_day_index);
  ELSE
    FOR l_temp_index IN G_MAX_CAL_DAY + 1 .. p_day_index LOOP
      l_curr_day := G_WORKING_DATES_TBL(l_temp_index - 1) + 1;
      l_temp_flag := FALSE;
      WHILE NOT l_temp_flag LOOP
        -- Check if l_curr_day is a working day
        l_curr_wday_index := MOD((TRUNC(l_curr_day) - G_CAL_START), (G_DAYS_ON + G_DAYS_OFF)) + 1;
        IF (l_curr_wday_index > G_DAYS_ON) THEN
          -- Day Off
          l_temp_flag := FALSE;
          l_curr_day := l_curr_day + 1;
        ELSE
          -- Not Day Off: Check if Holiday
          IF(IS_DEPT_Holiday(l_curr_day)) THEN
            -- Holiday
            l_temp_flag := FALSE;
            l_curr_day := l_curr_day + 1;
          ELSE
-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- Remove calendar range validation to sync with time calculation in VWP
/*
            -- Working Day: Check if day is in calendar range
            IF(l_curr_day > G_CAL_END) THEN
              Fnd_Message.Set_Name('AHL','AHL_LTP_INSUFFICIENT_CAL_RANGE');
              Fnd_Msg_Pub.ADD;
              Ahl_Debug_Pub.debug('Computed date (' || l_curr_day || ') is outside calendar range', 'LTP: Init_Time_Vars');
              RAISE  Fnd_Api.G_EXC_ERROR;
            END IF;
*/
-- yazhou 24Aug2005 ends

            -- Add this day to the table
            G_WORKING_DATES_TBL(l_temp_index) := l_curr_day;
            G_MAX_CAL_DAY := l_temp_index;
            l_temp_flag := TRUE;
          END IF;
        END IF;
      END LOOP;
    END LOOP;
    RETURN G_WORKING_DATES_TBL(p_day_index);
  END IF;
END Get_Nth_Day;

----------------------------------------
-- Function to determine if a specific date is a holiday
----------------------------------------
FUNCTION IS_DEPT_Holiday(l_curr_date DATE) RETURN BOOLEAN
IS
  l_temp_date DATE := TRUNC(l_curr_date);
BEGIN
  IF (G_EXCEPTION_DATES_TBL.COUNT = 0) THEN
    RETURN FALSE;
  END IF;
  FOR i IN G_EXCEPTION_DATES_TBL.FIRST .. G_EXCEPTION_DATES_TBL.LAST LOOP
    IF (l_temp_date = G_EXCEPTION_DATES_TBL(i)) THEN
      RETURN TRUE;
    ELSIF (l_temp_date < G_EXCEPTION_DATES_TBL(i)) THEN
      RETURN FALSE;
    END IF;
  END LOOP;
  RETURN FALSE;
END IS_DEPT_Holiday;

----------------------------------------
-- Function to determine if a specific date is not
-- a holiday in the given department
----------------------------------------
FUNCTION Not_A_Holiday(p_curr_date DATE, p_dept_id NUMBER) RETURN BOOLEAN
IS
  l_junk      VARCHAR2(1);
BEGIN
  SELECT 'x' INTO l_junk FROM AHL_DEPARTMENT_SHIFTS ADS, BOM_CALENDAR_EXCEPTIONS BCE
  WHERE ADS.DEPARTMENT_ID = p_dept_id AND
  BCE.CALENDAR_CODE = ADS.CALENDAR_CODE AND
  BCE.EXCEPTION_TYPE = G_HOLIDAY_TYPE AND
  TRUNC(BCE.EXCEPTION_DATE) = TRUNC(p_curr_date);

  IF (SQL%NOTFOUND) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN
    RETURN TRUE;

END Not_A_Holiday;

----------------------------------------
-- Function to determine if a specific resource is available
-- (working in a shift) at a specific time
----------------------------------------
FUNCTION Resource_In_Duty(p_resource_id NUMBER, p_start_date_time DATE) RETURN BOOLEAN
IS

  CURSOR l_shift_details_csr(p_resource_id NUMBER) IS
    SELECT from_time, to_time
    FROM bom_shift_times st, bom_resource_shifts rs
    WHERE st.shift_num = rs.shift_num AND
    rs.resource_id = p_resource_id;

  l_shift_start NUMBER := 0;
  l_shift_end NUMBER := 0;
  l_start_second NUMBER := 0;

BEGIN

  -- Get Days On and Days Off
  OPEN l_shift_details_csr(p_resource_id);
  FETCH l_shift_details_csr INTO l_shift_start, l_shift_end;
  IF (l_shift_details_csr%NOTFOUND) THEN
    Fnd_Message.Set_Name('AHL','AHL_LTP_NO_SHIFT_FOR_RSRC');
    Fnd_Message.Set_Token('RSRC_ID', p_resource_id);
    Fnd_Msg_Pub.ADD;
    CLOSE l_shift_details_csr;
    Ahl_Debug_Pub.debug('No Shift for Resource: ' || p_resource_id, 'LTP: Resource_In_Duty');
    RAISE  Fnd_Api.G_EXC_UNEXPECTED_ERROR;
  END IF;
  CLOSE l_shift_details_csr;

  l_start_second := (p_start_date_time - TRUNC(p_start_date_time)) * G_SECS_IN_DAY;
  IF (l_shift_start > l_shift_end) THEN
    RETURN (l_start_second >= l_shift_start OR l_start_second <= l_shift_end);
  ELSE
    RETURN  (l_start_second >= l_shift_start AND l_start_second <= l_shift_end);
  END IF;
END Resource_In_Duty;

----------------------------------------
-- Function to determine if the Resource is already present in the given table
----------------------------------------
FUNCTION Is_Resource_Present(p_aso_resource_id NUMBER,
                             p_task_rsrc_tbl   Plan_Rsrc_Tbl_Type) RETURN BOOLEAN
IS
BEGIN
  IF (p_task_rsrc_tbl.COUNT = 0) THEN
    RETURN FALSE;
  ELSE
    IF (p_aso_resource_id IS NOT NULL) THEN
      FOR i IN p_task_rsrc_tbl.FIRST .. p_task_rsrc_tbl.LAST LOOP
        IF (p_task_rsrc_tbl(i).ASO_BOM_TYPE = G_ASO_RESOURCE AND
            p_task_rsrc_tbl(i).RESOURCE_ID = p_aso_resource_id) THEN
          RETURN TRUE;
        END IF;
      END LOOP;
  END IF;
  END IF;
END Is_Resource_Present;
----------------------------------------
-- Function to determine if two time periods overlap
-- Note that If the end time of one period coincides with the
-- start time of the other time period, the timeperiods DON'T overlap
----------------------------------------
FUNCTION Periods_Overlap(p1_start_time DATE, p1_end_time DATE, p2_start_time DATE, p2_end_time DATE)
RETURN BOOLEAN IS
  l1s DATE := p1_start_time;
  l1e DATE := p1_end_time;
  l2s DATE := p2_start_time;
  l2e DATE := p2_end_time;

  l_temp_time DATE;
BEGIN
 IF (p1_start_time IS NULL OR p2_start_time IS NULL) THEN
   -- Invalid: Return false
   RETURN FALSE;
 END IF;

 IF(l1s > l2s) THEN
   -- Swap so that l1 starts first
   l_temp_time := l1s;
   l1s := l2s;
   l2s := l_temp_time;
   l_temp_time := l1e;
   l1e := l2e;
   l2e := l_temp_time;
 END IF;
 RETURN (l1e > l2s);
END Periods_Overlap;

----------------------------------------
  -- Calculates the maximum required quantity during a given period
----------------------------------------
FUNCTION Get_Required_Quantity(
  p_start_time   DATE,
  p_end_time     DATE,
  p_tp_dtls_tbl  Time_Period_Details_Tbl_Type)
RETURN NUMBER IS

  l_qty_change_tbl  Qty_Change_Tbl_Type;
  l_temp_index      NUMBER := 1;
  l_initial_req     NUMBER := 0;
  l_max_demand      NUMBER := 0;
  l_cur_demand      NUMBER := 0;
  l_peak_instant    DATE;

  l_api_name        CONSTANT VARCHAR2(30) := 'Get_Required_Quantity';

BEGIN

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'inside Get_Required_Quantity. p_tp_dtls_tbl.count: '||p_tp_dtls_tbl.count
        );

  END IF;

  -- Fill the Quantity Change table with operations/tasks that are in
  -- progress during the time period, Getting the Initial demand along the way
  FOR i IN p_tp_dtls_tbl.FIRST .. p_tp_dtls_tbl.LAST LOOP

    IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          ' i: '||i
         );
    END IF;

    IF (Periods_Overlap(p_start_time, p_end_time, p_tp_dtls_tbl(i).START_TIME, p_tp_dtls_tbl(i).END_TIME)) THEN

       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          ' Periods_Overlap'
         );
      END IF;

      l_qty_change_tbl(l_temp_index).EVENT_TIME := p_tp_dtls_tbl(i).START_TIME;
      l_qty_change_tbl(l_temp_index).QTY_CHANGE := p_tp_dtls_tbl(i).QUANTITY;

       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          ' l_qty_change_tbl('||l_temp_index||').QTY_CHANGE: '||l_qty_change_tbl(l_temp_index).QTY_CHANGE
         );

       END IF;

      l_temp_index := l_temp_index + 1;
      l_qty_change_tbl(l_temp_index).EVENT_TIME := p_tp_dtls_tbl(i).END_TIME;
      l_qty_change_tbl(l_temp_index).QTY_CHANGE := -(p_tp_dtls_tbl(i).QUANTITY);

       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          ' l_qty_change_tbl('||l_temp_index||').QTY_CHANGE: '||l_qty_change_tbl(l_temp_index).QTY_CHANGE
         );

       END IF;

      l_temp_index := l_temp_index + 1;
      IF (p_tp_dtls_tbl(i).START_TIME < p_start_time) THEN
        l_initial_req := l_initial_req + p_tp_dtls_tbl(i).QUANTITY;
      END IF;

       IF (l_log_statement >= l_log_current_level) THEN
         fnd_log.string
         (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          ' l_temp_index: '||l_temp_index
         );

       END IF;
    END IF;
  END LOOP;

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'After loop l_qty_change_tbl.count: '||l_qty_change_tbl.count
        );

  END IF;


  IF (l_qty_change_tbl.COUNT = 0) THEN
    -- No Task/Operation during this period
    RETURN 0;
  ELSIF (l_qty_change_tbl.COUNT = 2) THEN
    -- Only one task
    RETURN l_qty_change_tbl(l_qty_change_tbl.FIRST).QTY_CHANGE;
  END IF;

  -- Sort Quantity Change Table on Event time
  Sort_Qty_Change_Table(l_qty_change_tbl);

  -- Get the maximum demand
  l_cur_demand := l_initial_req;
  l_max_demand := l_initial_req;
  l_peak_instant := l_qty_change_tbl(l_qty_change_tbl.FIRST).EVENT_TIME;
  FOR j IN l_qty_change_tbl.FIRST .. l_qty_change_tbl.LAST LOOP
    IF (l_qty_change_tbl(j).EVENT_TIME >= p_start_time) THEN
      l_cur_demand := l_cur_demand + l_qty_change_tbl(j).QTY_CHANGE;
      IF (l_cur_demand > l_max_demand) THEN
        l_max_demand := l_cur_demand;
        l_peak_instant := l_qty_change_tbl(j).EVENT_TIME;
      END IF;
    END IF;
  END LOOP;

  IF (l_log_statement >= l_log_current_level) THEN
        fnd_log.string
        (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'Complete Get_Required_Quantity. l_max_demand: '||l_max_demand
        );

  END IF;
--  dbms_output.put_line('Max demand = ' || l_max_demand || ' at ' || TO_CHAR(l_peak_instant, 'MM/DD/YY HH24:MI:SS'));
  -- Return the maximum requirement
  RETURN l_max_demand;
END;
----------------------------------------
-- Compares a visit/task combination with another
-- Returns +1 If first visit task > second visit task
-- Returns -1 If first visit task < second visit task
-- Returns 0 If first visit task = second visit task
----------------------------------------
FUNCTION Compare_Visit_Tasks(p_visit_1 NUMBER, p_task_1 NUMBER, p_visit_2 NUMBER, p_task_2 NUMBER)
RETURN NUMBER IS
BEGIN
  IF (p_visit_1 > p_visit_2) THEN
    RETURN 1;
  ELSIF (p_visit_1 < p_visit_2) THEN
    RETURN -1;
  ELSE
    -- Visit Ids are equal: Compare by task id
    IF (p_task_1 > p_task_2) THEN
      RETURN 1;
    ELSIF (p_task_1 < p_task_2) THEN
      RETURN -1;
    ELSE
      RETURN 0;
    END IF;
  END IF;
END Compare_Visit_Tasks;
/*
----------------------------------------
-- Diagnostic procedure to test work day calculations
----------------------------------------
PROCEDURE Dump_Working_dates_tbl
(
--  p_start_date IN DATE := TO_DATE('15-May-2002'),
  p_dept_id IN NUMBER := 1,
  p_num_days IN NUMBER := 100
) IS

  l_index NUMBER;
  l_temp_date DATE;
BEGIN
--  dbms_output.put_line('Beginning Dump_Working_dates_tbl');
--  dbms_output.put_line('p_start_date = ' || p_start_date);

  Init_Time_Vars(p_start_date, p_dept_id);

  IF G_EXCEPTION_DATES_TBL.COUNT > 0 THEN
    l_index := G_EXCEPTION_DATES_TBL.FIRST;
    WHILE l_index IS NOT NULL LOOP
--      dbms_output.put_line('Holiday: ' || l_index || ' Date: ' || TO_CHAR(G_EXCEPTION_DATES_TBL(l_index), 'MM/DD/YY HH24:MI:SS'));
      l_index := G_EXCEPTION_DATES_TBL.NEXT(l_index);
    END LOOP;
  END IF;

  l_temp_date := Get_Nth_Day(p_num_days);
--  dbms_output.put_line('G_WORKING_DATES_TBL COUNT = ' || G_WORKING_DATES_TBL.COUNT);
  IF G_WORKING_DATES_TBL.COUNT > 0 THEN
    l_index := G_WORKING_DATES_TBL.FIRST;
    WHILE l_index IS NOT NULL LOOP
--      dbms_output.put_line('Day: ' || l_index || ' Date: ' || TO_CHAR(G_WORKING_DATES_TBL(l_index), 'MM/DD/YY HH24:MI:SS'));
      l_index := G_WORKING_DATES_TBL.NEXT(l_index);
    END LOOP;
  END IF;
--  dbms_output.put_line('Ending Dump_Working_dates_tbl');
END;
*/
-------------------------------
-- End Local Procedures --
-------------------------------

---------------------------------------
-- Calculates the available units of
-- a resource during a given period
----------------------------------------
-- yazhou 24Aug2005 starts
-- Resource Leveling Re-design
-- Get the shift number for the given department
-- And then retrieve shift capacity for that shift only
-- Also removed p_org_id as input parameter since it's not used

FUNCTION Get_Available_Units(p_resource_id  NUMBER,
                             p_dept_id      NUMBER)
RETURN NUMBER IS
  --
    CURSOR l_get_bom_rsrc_dtls_csr(p_bom_resource_id   IN NUMBER,
                                 p_bom_department_id IN NUMBER) IS
    SELECT B.CAPACITY_UNITS,a.description
    FROM bom_resources A,
         bom_department_resources B
  WHERE a. resource_id = B.resource_id
   AND B.resource_id = p_bom_resource_id
   AND B.department_id = p_bom_department_id;

  -- Gets shift capacity
    CURSOR l_get_shift_dtls_csr(p_bom_resource_id   IN NUMBER,
                                p_bom_department_id IN NUMBER) IS
    SELECT CAPACITY_UNITS SHIFT_CAPACITY
    FROM bom_resource_shifts
  WHERE resource_id = p_bom_resource_id
   AND  department_id = p_bom_department_id
     AND  SHIFT_NUM = ( select shift_num
                          FROM  AHL_DEPARTMENT_SHIFTS
                          WHERE department_id = p_bom_department_id);

--  l_res_type            NUMBER;
--  l_bom_org_id          NUMBER;
  l_total_quantity      NUMBER := 0;
--  l_bom_resource_id     NUMBER;
  l_capacity_units      NUMBER;
--  l_shift_num           NUMBER;
  l_shift_capacity      NUMBER;
  l_description         bom_resources.description%type;

-- yazhou 24Aug2005 ends

BEGIN
    Ahl_Debug_Pub.debug('enter get available p_resource_id:'||p_resource_id);
    Ahl_Debug_Pub.debug('enter get available p_dept_id:'||p_dept_id);

    --Get available units
    OPEN l_get_bom_rsrc_dtls_csr(p_resource_id,p_dept_id);
    FETCH l_get_bom_rsrc_dtls_csr INTO l_capacity_units,l_description;
    IF l_get_bom_rsrc_dtls_csr%NOTFOUND THEN
       Fnd_Message.Set_Name('AHL','AHL_LTP_RES_ID_INVALID');
       Fnd_Message.Set_Token('RES_ID', l_description);
       Fnd_Msg_Pub.ADD;
    END IF;
    CLOSE l_get_bom_rsrc_dtls_csr;
    Ahl_Debug_Pub.debug('Inside get available l_capacity_units:'||l_capacity_units);

    -- Get shift capacity
    OPEN l_get_shift_dtls_csr(p_resource_id,p_dept_id);
    FETCH l_get_shift_dtls_csr INTO l_shift_capacity;
    CLOSE l_get_shift_dtls_csr;

    Ahl_Debug_Pub.debug('Inside get available l_shift_capacity:'||l_shift_capacity);

   IF l_shift_capacity IS NOT NULL THEN
      l_total_quantity := l_shift_capacity;
     ELSE
      l_total_quantity := l_capacity_units;
   END IF;

    Ahl_Debug_Pub.debug('Inside get available l_total_quantity:'||l_total_quantity);

   RETURN l_total_quantity;

END Get_Available_Units;
--
-- AnRaj: Obsoleted Procedure
/*
PROCEDURE GET_WIP_DISC_REQ_UNITS(
             p_org_id          IN NUMBER,
             p_bom_dept_id     IN NUMBER,
             p_bom_resource_id IN NUMBER,
             p_start_date      IN DATE,
             p_end_date        IN DATE,
             x_assigned_units  OUT NOCOPY NUMBER)
IS

 CURSOR wip_disc_cur (c_org_id IN NUMBER)
    IS
    SELECT wip.wip_entity_id
    FROM wip_discrete_jobs wip
  WHERE wip.organization_id = c_org_id
   AND (p_start_date BETWEEN wip.scheduled_start_date
      AND wip.scheduled_completion_date
    OR
    p_end_date BETWEEN wip.scheduled_start_date
    AND wip.scheduled_completion_date)
     AND not exists (select wip_entity_id
     from ahl_workorders wo
     where wo.wip_entity_id = wip.wip_entity_id
     and wo.status_code = '17');

  --
  CURSOR wip_oper_cur (c_wip_entity_id IN NUMBER,
                       c_dept_id       IN NUMBER)
   IS
     SELECT wip_entity_id
       FROM wip_operations
    WHERE wip_entity_id = c_wip_entity_id
        AND department_id = c_dept_id;
        --
   CURSOR wip_res_cur (c_wip_entity_id IN NUMBER,
                       c_resource_id   IN NUMBER)
   IS
     SELECT SUM(assigned_units)
      FROM wip_operation_resources
     WHERE wip_entity_id = c_wip_entity_id
      AND  resource_id = c_resource_id;
  l_wip_entity_id    NUMBER;
  l_wip_op_entity_id NUMBER;
  l_assigned_units   NUMBER;
 BEGIN
    --
  OPEN wip_disc_cur(p_org_id);
  LOOP
  FETCH wip_disc_cur INTO l_wip_entity_id;
  EXIT WHEN wip_disc_cur%NOTFOUND;
  IF l_wip_entity_id IS NOT NULL THEN
      OPEN wip_oper_cur(l_wip_entity_id,p_bom_dept_id);
    LOOP
    FETCH wip_oper_cur INTO l_wip_op_entity_id;
    EXIT WHEN wip_oper_cur%NOTFOUND;
     IF wip_oper_cur%FOUND THEN
        OPEN wip_res_cur(l_wip_op_entity_id,p_bom_resource_id);
      FETCH wip_res_cur INTO x_assigned_units;
      CLOSE wip_res_cur;
     END IF;
       END LOOP;
     CLOSE wip_oper_cur;
     END IF;
    END LOOP;
  CLOSE wip_disc_cur;
  END;
  */
--
PROCEDURE GET_WIP_DISC_ASSIGN_UNITS(
       p_bom_resource_id   IN NUMBER,
       p_start_date        IN DATE,
       p_end_date          IN DATE,
       x_assigned_persons  OUT NOCOPY NUMBER)
IS
CURSOR get_per_ins_cur(c_resource_id IN NUMBER)
  IS
   SELECT person_id,
          instance_id,
      effective_start_date,effective_end_date
    FROM bom_resource_employees
   WHERE resource_id = c_resource_id;
   --
CURSOR get_assign_per_cur(c_instance_id IN NUMBER,
                          c_start_date  IN DATE,
              c_end_date    IN DATE)
  IS
   SELECT COUNT(*)
    FROM wip_op_resource_instances
   WHERE instance_id = c_instance_id
    AND (c_start_date BETWEEN start_date AND
      completion_date) OR
    (c_end_date BETWEEN start_date AND
    completion_date);

   l_get_per_ins_rec    get_per_ins_cur%ROWTYPE;
   l_dummy              NUMBER;
   --
BEGIN
    OPEN get_per_ins_cur(p_bom_resource_id);
  LOOP
   FETCH get_per_ins_cur INTO l_get_per_ins_rec;
   EXIT WHEN get_per_ins_cur%NOTFOUND;
   IF l_get_per_ins_rec.instance_id IS NOT NULL
     THEN
       OPEN get_assign_per_cur(l_get_per_ins_rec.instance_id,
                             p_start_date,p_end_date);
     FETCH get_assign_per_cur INTO l_dummy;
     CLOSE get_assign_per_cur;
    END IF;
     x_assigned_persons := l_dummy;
  END LOOP;
  CLOSE get_per_ins_cur;
END;

-- JARAMANA 24Aug2005 starts
-- Resource Leveling Re-design

-- Gets the (unique) ids of all the resources used in the
-- given department and in the given time range by the given resource requirements.
PROCEDURE Get_Used_Resources
(
   p_dept_id       IN NUMBER,
   p_start_date    IN DATE,
   p_end_date      IN DATE,
   p_tp_dtls_tbl   IN Time_Period_Details_Tbl_Type,
   x_resources_tbl OUT NOCOPY Resource_Tbl_Type
) IS
 l_temp_index  NUMBER := 1;
 l_temp_index2  NUMBER;
 l_temp_num_tbl Resource_Tbl_Type;
BEGIN
 IF (p_tp_dtls_tbl.COUNT > 0) THEN
   FOR i IN p_tp_dtls_tbl.FIRST..p_tp_dtls_tbl.LAST LOOP
     IF (p_tp_dtls_tbl(i).DEPARTMENT_ID = p_dept_id AND
         Periods_Overlap(p_tp_dtls_tbl(i).START_TIME, p_tp_dtls_tbl(i).END_TIME,
                         p_start_date, p_end_date)) THEN
       -- This reseource is required in the given dept during the given time range
       l_temp_num_tbl(p_tp_dtls_tbl(i).BOM_RESOURCE_ID) := p_tp_dtls_tbl(i).BOM_RESOURCE_ID;
     END IF;
   END LOOP;

   -- Transfer from the associative array to the 1 based output table
   IF (l_temp_num_tbl.COUNT > 0) THEN
     l_temp_index2 := l_temp_num_tbl.FIRST;
     WHILE (l_temp_index2 IS NOT NULL) LOOP
       x_resources_tbl(l_temp_index) := l_temp_index2;
       l_temp_index := l_temp_index + 1;
       l_temp_index2 := l_temp_num_tbl.NEXT(l_temp_index2);
     END LOOP;
   END IF;
 END IF;
END Get_Used_Resources;

PROCEDURE Append_WIP_Requirements
(
   p_org_id        IN NUMBER,
   p_dept_id       IN NUMBER,
   p_start_date    IN DATE,
   p_end_date      IN DATE,
   p_resource_id   IN NUMBER,
   p_x_tp_dtls_tbl IN OUT NOCOPY Time_Period_Details_Tbl_Type
) IS
 CURSOR get_wip_req_dtls_csr IS
   SELECT wor.start_date, wor.completion_date, wor.assigned_units, wor.wip_entity_id
   FROM wip_operation_resources wor, wip_operations wo, wip_discrete_jobs wdj,
         AHL_WORKORDERS aw
   WHERE wor.resource_id = p_resource_id
     AND wo.department_id = p_dept_id
     AND wo.wip_entity_id = wor.wip_entity_id
     AND wdj.WIP_ENTITY_ID = aw.WIP_ENTITY_ID
     AND aw.STATUS_CODE not in ('17','22','7','12','18','4','5')
     --(17-Draft, 22-Deleted, 7-Cancelled, 12-Closed, 18-Deferrred, 4-Complete, 5-Complete No-charge)
     AND wdj.organization_id = p_org_id
     AND wdj.wip_entity_id = wo.wip_entity_id
     AND ((wor.start_date BETWEEN p_start_date and p_end_date) OR
          (wor.completion_date BETWEEN p_start_date and p_end_date) OR
          (wor.start_date < p_start_date AND wor.completion_date > p_end_date));

 l_temp_index  NUMBER := p_x_tp_dtls_tbl.LAST + 1;
 l_api_name        CONSTANT VARCHAR2(30) := 'Append_WIP_Requirements';

BEGIN
 FOR wip_req_dtls IN get_wip_req_dtls_csr LOOP
   p_x_tp_dtls_tbl(l_temp_index).START_TIME := wip_req_dtls.start_date;
   p_x_tp_dtls_tbl(l_temp_index).END_TIME := wip_req_dtls.completion_date;
   p_x_tp_dtls_tbl(l_temp_index).QUANTITY := wip_req_dtls.assigned_units;
   -- None of the other fields in the p_x_tp_dtls_tbl(l_temp_index) record
   -- are populated since they are not relevant.

   IF (l_log_statement >= l_log_current_level) THEN
      fnd_log.string
      (
          fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'wip_entity_id: '|| wip_req_dtls.wip_entity_id
      );
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_x_tp_dtls_tbl('||l_temp_index||').start_time: '|| TO_CHAR(p_x_tp_dtls_tbl(l_temp_index).start_time, 'DD-MON-YYYY hh24:mi')
      );
      fnd_log.string
      (
         fnd_log.level_statement,
         'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
         'p_x_tp_dtls_tbl('||l_temp_index||').end_time: '|| TO_CHAR( p_x_tp_dtls_tbl(l_temp_index).end_time, 'DD-MON-YYYY hh24:mi')
      );
      fnd_log.string
      (
          fnd_log.level_statement,
          'ahl.plsql.'||g_pkg_name||'.'||l_api_name,
          'p_x_tp_dtls_tbl('||l_temp_index||').quantity: '|| p_x_tp_dtls_tbl(l_temp_index).quantity
      );

    END IF;

   l_temp_index := l_temp_index + 1;
 END LOOP;

END Append_WIP_Requirements;

-- JARAMANA 24Aug2005 ends
--
END Ahl_Ltp_Resrc_Levl_Pvt;

/
