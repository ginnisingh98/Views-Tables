--------------------------------------------------------
--  DDL for Package Body PA_TIMELINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TIMELINE_PVT" as
 /* $Header: PARLPVTB.pls 120.6.12010000.7 2010/03/24 06:55:44 sugupta ship $   */

-- Procedure level variable declaration.


-- Procedure  : create_timeline (Overloaded)
-- Purpose    : This is overloaded procedure for creating timeline records for
--              a new assignment. It generates forecast items and computes
--              assignment effort.
PROCEDURE Create_Timeline (p_assignment_id  IN   NUMBER,
                           x_return_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data       OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

  l_start_date DATE;
  l_end_date DATE;

/*
  CURSOR c1 IS
    SELECT item_quantity
    FROM pa_forecast_items
    WHERE assignment_id = p_assignment_id
    AND item_date BETWEEN l_start_date and l_end_date
    AND delete_flag IN ('Y', 'N');

--  TYPE NumVarrayType IS VARRAY(200) OF NUMBER;
--  l_quantity_arr NumVarrayType := NumVarrayType();
*/

  l_sum NUMBER :=0;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  SELECT start_date, end_date
  INTO l_start_date, l_end_date
  FROM pa_project_assignments
  WHERE assignment_id = p_assignment_id;

  -- Generate forecast items.
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
  PA_FORECASTITEM_PVT.Create_Forecast_Item(
                 p_assignment_id    => p_assignment_id,
                 p_start_date       => l_start_date,
                 p_end_date         => l_end_date,
                 p_process_mode     => 'GENERATE',
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
  END IF;

  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
  -- Compute assignment effort and update pa_project_assignments table.

   l_sum := PA_SCHEDULE_UTILS.get_num_hours(
                                          p_project_id => null,
                                          p_assignment_id => p_assignment_id);
   PA_PROJECT_ASSIGNMENTS_PKG.update_row(
     			 p_assignment_id     => p_assignment_id,
           p_assignment_effort => l_sum,
           x_return_status     => x_return_status);

  END IF;

EXCEPTION
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
       p_procedure_name => 'Create_Timeline assignment');
     RAISE;

END create_timeline;


-- Procedure :       Create_Timeline (Overloaded)
-- Purpose   :       This is overloaded function for creating timeline records
--                   from resource id or resoure name. This will be called from
--                   concurrent program.
PROCEDURE Create_Timeline (p_start_resource_name  IN     VARCHAR2,
                           p_end_resource_name    IN     VARCHAR2,
                           p_resource_id          IN     NUMBER,
                           p_start_date           IN     DATE,
                           p_end_date             IN     DATE,
                           x_return_status        OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                           x_msg_count            OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
                           x_msg_data             OUT    NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   ld_start_date  DATE;
   ld_end_date    DATE;      --  End  date */

-- 2001305: Local variables for fix.
   ld_fi_start_date DATE;

   pi_commit_size    NUMBER :=1000;
   li_commit_size    NUMBER:=0;

-- 2001305: Adding resource_effective_start_date to cursor,
-- so that we can pass this value to fi generation when p_start_date is null.

   -- Made this cursor simpler since timeline code was obsoleted.

-- MOAC Changes : Bug 4363092: In R12  Rebuild Timeline Program should process all resources across OUs
--                             Hence removing the client_info filter
   CURSOR cur_res_det  IS
     SELECT distinct res.resource_id resource_id
       FROM pa_resources_denorm res
       WHERE upper(res.resource_name) BETWEEN  upper(p_start_resource_name) AND upper(p_end_resource_name)
--       AND   NVL(res.resource_org_id,NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
--       ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))), -99)) =
--       NVL(TO_NUMBER(DECODE(SUBSTR(USERENV('CLIENT_INFO'),1,1),
--       ' ',NULL,SUBSTR(USERENV('CLIENT_INFO'),1,10))),-99)
       UNION ALL
       SELECT  distinct res.resource_id resource_id
         FROM pa_resources_denorm res
         WHERE     res.resource_id = p_resource_id;


       cur_res_det_rec    cur_res_det%ROWTYPE;

 g_TimelineProfileSetup  PA_TIMELINE_GLOB.TimelineProfileSetup;
 AVAILABILITY_DURATION   NUMBER;
 l_no_timeline_to_create EXCEPTION;
 l_debug_mode            VARCHAR2(20) := 'N';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- Add the following two lines so that debug messages get written to the log file.
  fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);
  IF l_debug_mode = 'Y' THEN  -- Added for bug 4345291
    pa_debug.set_process('PLSQL','LOG',l_debug_mode);
  END IF;

  pa_timeline_util.debug(' Entering Create_Timeline for resource id or resource names ');
  g_TimelineProfileSetup  := PA_TIMELINE_UTIL.get_timeline_profile_setup;
  availability_duration   := nvl(g_TimelineProfileSetup.availability_duration,0);

  -- 2196924: If dates are null or greater than avail period,
  -- then default to availability period.

  if (availability_duration = 0) then
    pa_timeline_util.debug('availability_duration = 0');
    raise l_no_timeline_to_create;
  end if;

  ld_start_date := NVL(p_start_date, ADD_MONTHS(sysdate, -12));
  ld_end_date := NVL(p_end_date, ADD_MONTHS(sysdate, availability_duration * (12)));

  if (ld_start_date < ADD_MONTHS(sysdate, -12)) then
    ld_start_date := ADD_MONTHS(sysdate, -12);
  end if;

  if (ld_end_date > ADD_MONTHS(sysdate, availability_duration * (12))) then
    ld_end_date := ADD_MONTHS(sysdate, availability_duration * (12));
  end if;

  if (ld_start_date > ld_end_date) then
    raise l_no_timeline_to_create;
  end if;

/* 2196924: No longer necessary to find end date of week for timeline.
  ld_start_date := PA_TIMELINE_UTIL.Get_Week_End_Date(
        p_org_id=>-99,
        p_given_date=>ld_start_date) - 6;

  ld_end_date := PA_TIMELINE_UTIL.Get_Week_End_Date(
           p_org_id=>-99,
           p_given_date=>ld_end_date);
*/

  li_commit_size :=1;

   FOR cur_res_det_rec IN cur_res_det LOOP
      pa_timeline_util.debug(' Processing Resource ID ' || to_char(cur_res_det_rec.resource_id));


      pa_timeline_util.debug('Calling forecast item generation');

      -- Generate forecast items.
      PA_FORECASTITEM_PVT.Create_Forecast_Item(
                 p_resource_id      => cur_res_det_rec.resource_id,
                 p_start_date       => ld_start_date,
                 p_end_date         => ld_end_date,
                 p_process_mode     => 'GENERATE',
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
      pa_timeline_util.debug('End calling forecast item generation: 10');

      -- jmarques (1569373):
      -- When this procedure is called from a concurrent process,
      -- we partially commit the data.  If p_start_resource_name is not
      -- null, then this means that the procedure is called from
      -- a concurrent process.
      if (p_start_resource_name is not null) then
         li_commit_size :=  NVL(li_commit_size,0) +1;

         IF pi_commit_size = li_commit_size  THEN
            commit;
            li_commit_size :=0;
         END IF;
      END IF;

   END LOOP;

EXCEPTION
   WHEN l_no_timeline_to_create THEN
     -- There is no timeline to create
     pa_timeline_util.debug('no timeline to create');

   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
       p_procedure_name => 'Create_Timeline Resource');
     RAISE;

END Create_Timeline;


-- Procedure : Create_Timeline (Overloaded)
-- Purpose   : The purpose of this procedure to create timeline records for
--             resource which attached with given calendar id's. This will be
--             called from Calendar concurrent program.
PROCEDURE Create_Timeline(p_calendar_id    IN  NUMBER,
                          x_return_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count    OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data    OUT  NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   -- Get the resource which belong to the calendar

   -- jmarques: 1786935: Modified cursor to include resource_type_code
   -- since resource_id is not unique.

   -- 1965289: Work around for CRM bug (cannot create future dated resources).
   -- Added UNION, so that we always recreate timeline for future dated
   -- resources even if they are not associated with p_calendar_id.
   -- It is too much impact to find those resources which have
   -- p_calendar_id as the default calendar.

	 CURSOR cur_clndar IS
     SELECT   pares.resource_id resource_id,
       trunc(start_date_time) start_date,
       NVL(trunc(end_date_time), TO_DATE('12/31/4712','MM/DD/YYYY')) end_date
       FROM    jtf_cal_resource_assign jtf_res,pa_resources pares
       WHERE  jtf_res.resource_id = pares.jtf_resource_id
       AND  jtf_res.resource_type_code = 'RS_EMPLOYEE'
       AND  jtf_res.calendar_id = p_calendar_id
       AND  jtf_res.primary_calendar_flag = 'Y'
     UNION ALL
     SELECT res.resource_id,
            resdenorm.resource_effective_start_date start_date,
            TO_DATE('12/31/4712','MM/DD/YYYY') end_date
     from pa_resources res, pa_resources_denorm resdenorm
     where res.jtf_resource_id is null
     and res.resource_id = resdenorm.resource_id
     and res.resource_type_id = 101 -- Bug 4370196
     ;

     li_commit_size   NUMBER:=1;
     pi_commit_size    NUMBER :=1000;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
   pa_timeline_util.debug('Start Date and Time   ' || TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MM:SS'));

   FOR cur_clndar_rec IN cur_clndar LOOP

      -- This call will rebuild the resource forecast items.
      create_timeline(p_start_resource_name=>NULL,
        p_end_resource_name =>NULL,
        p_resource_id=>cur_clndar_rec.resource_id,
        p_start_date=>cur_clndar_rec.start_date,
        p_end_date =>cur_clndar_rec.end_date,
        x_return_status=>x_return_status,
        x_msg_count=>x_msg_count,
        x_msg_data=>x_msg_data);

      IF li_commit_size >= pi_commit_size THEN
         COMMIT;
         li_commit_size :=1;
      END IF;
      li_commit_size := li_commit_size +1;

   END LOOP;

   pa_timeline_util.debug('End Date and Time   ' || TO_CHAR(SYSDATE,'DD-MON-YYYY HH:MM:SS'));

EXCEPTION
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
       p_procedure_name => 'Create_Timeline Calendar');
     RAISE;

END Create_Timeline;


PROCEDURE Delete_Timeline(p_assignment_id  IN   NUMBER,
                          x_return_status  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data       OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
  l_start_date DATE;
  l_end_date DATE;
  l_resource_id NUMBER;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  PA_FORECASTITEM_PVT.Delete_FI (p_assignment_id  => p_assignment_id ,
                      x_return_status  =>  x_return_status,
                      x_msg_count      =>  x_msg_count,
                      x_msg_data       =>  x_msg_data);

  -- Regenerate Resource FIs for the period
  IF (x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
  select start_date, end_date, resource_id
  into l_start_date, l_end_date, l_resource_id
  from pa_project_assignments
  where assignment_id = p_assignment_id;

  if (l_resource_id is not null) then
      PA_FORECASTITEM_PVT.Create_Forecast_Item(
                 p_resource_id      => l_resource_id,
                 p_start_date       => l_start_date,
                 p_end_date         => l_end_date,
                 p_process_mode     => 'GENERATE',
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
  end if;
  end if;

EXCEPTION
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
       p_procedure_name => 'Delete_Timeline');
     RAISE;

END Delete_Timeline;


-- Procedure            : copy_open_asgn_timeline
-- Purpose              : Copy timeline data, pa_timeline_row_label and
--                        pa_proj_asgn_time_chart, for a newly created open
--                        assignment whose timeline has NOT been built.
--                        Currently, the only API calling this is
--                        PA_SCHEDULE_PVT.create_opn_asg_schedule.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_assignment_id             NUMBER           YES      Id of the newly created open assignment
-- P_assignment_source_id      NUMBER           YES      Id of the source open assignment from which timeline data are copied

PROCEDURE copy_open_asgn_timeline (p_assignment_id_tbl      IN   PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
                                   p_assignment_source_id   IN   NUMBER,
                                   x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_msg_data               OUT  NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  PA_FORECASTITEM_PVT.copy_requirement_fi(p_requirement_id_tbl => p_assignment_id_tbl,
    p_requirement_source_id => p_assignment_source_id,
    x_return_status  => x_return_status,
    x_msg_count      => x_msg_count,
    x_msg_data       => x_msg_data);

EXCEPTION
   WHEN OTHERS THEN
     x_msg_count     := 1;
     x_msg_data      := sqlerrm;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
       p_procedure_name => 'Copy_Open_Asgn_Timeline');
     RAISE;

END copy_open_asgn_timeline;


-- Procedure            : populate_time_chart_table
-- Purpose              : Populates global temp table PA_TIME_CHART_TEMP with
--                        time chart records. The procedure is called from
--                        front end to display timeline.
-- Input parameters
-- Parameters           Required  Description
-- p_timeline_type      Yes       The type of time chart records to create.
--                                Valid values include: 'ProjectAssignments',
--                                'ResourceSchedules', 'ResourceAssignments',
--                                'ResourceOvercommitmentCalc'.
-- p_row_label_id_tbl   Yes       For Team List: assignment_id
--                                For Resource List: resource_id
--                                For Resource Details: assignment_id
-- p_resource_id        No        Required for Resource Details timeline
-- p_start_date         Yes       The start date of the time chart.
-- p_end_date           Yes       The end date of the time chart.
-- p_scale_type         Yes       The scale type of the time chart. Valid
--                                values include: 'THREE_MONTH', 'MONTH'.
-- p_delete_flag        No        If 'Y', all records are deleted from
--                                PA_TIME_CHART_TEMP before creating new records.
--                                Otherwise, no records are deleted.
-- x_return_status      Yes       Return status code.
-- x_msg_count          Yes       Message count.
-- x_msg_data           Yes       Message data.
PROCEDURE populate_time_chart_table (p_timeline_type IN VARCHAR2,
            p_row_label_id_tbl  IN SYSTEM.PA_NUM_TBL_TYPE,
            p_resource_id       IN NUMBER DEFAULT NULL,
            p_conflict_group_id IN NUMBER DEFAULT NULL,
            p_assignment_id     IN NUMBER DEFAULT NULL,
            p_start_date        IN DATE,
            p_end_date          IN DATE,
            p_scale_type        IN VARCHAR2,
            p_delete_flag       IN VARCHAR2 DEFAULT 'Y',
            x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS

  g_availability_cal_period VARCHAR2(15) := FND_PROFILE.VALUE('PA_AVAILABILITY_CAL_PERIOD');
  g_res_capacity_percentage NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_RES_CAPACITY_PERCENTAGE'))/100;
  g_overcommitment_percentage NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_OVERCOMMITMENT_PERCENTAGE'))/100;
  l_row_label_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;
  l_count NUMBER;
  prm_license VARCHAR(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  pa_timeline_util.debug('************************************');
  pa_timeline_util.debug('Entering populate_time_chart_table');
  pa_timeline_util.debug('p_timeline_type: '|| p_timeline_type);
  pa_timeline_util.debug('p_resource_id: ' ||  p_resource_id);
  pa_timeline_util.debug('p_conflict_group_id: '|| p_conflict_group_id);
  pa_timeline_util.debug('p_assignment_id: '|| p_assignment_id);
  pa_timeline_util.debug('p_start_date: ' || p_start_date);
  pa_timeline_util.debug('p_end_date: ' || p_end_date);
  pa_timeline_util.debug('p_scale_type: ' || p_scale_type);
  pa_timeline_util.debug('p_delete_flag: ' || p_delete_flag);
  pa_timeline_util.debug('************************************');

  pa_timeline_util.debug('g_res_capacity_percentage =' || g_res_capacity_percentage);
  pa_timeline_util.debug('g_overcommitment_percentage = '|| g_overcommitment_percentage);
  pa_timeline_util.debug('g_availability_cal_period = '||g_availability_cal_period);

  IF p_delete_flag = 'Y' then
    PA_TIME_CHART_PKG.delete_row(x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data);
  END IF;

  pa_timeline_util.debug('After delete row');

  l_count := p_row_label_id_tbl.COUNT;
  pa_timeline_util.debug('Count = '|| l_count);
  prm_license := PA_INSTALL.IS_PRM_LICENSED();

  IF l_count > 0 THEN
    FOR j IN 1 .. (TRUNC(l_count/25)+1) LOOP
  pa_timeline_util.debug('Enter For loop');

      IF j < TRUNC(l_count/25) +1 THEN
        FOR i IN 1 .. 25 LOOP
            l_row_label_id_tbl(i) := p_row_label_id_tbl((j-1)*25+i);
        END LOOP;
      ELSE
        FOR i IN 1.. MOD(l_count, 25) LOOP
          l_row_label_id_tbl(i) := p_row_label_id_tbl((j-1)*25+i);
  pa_timeline_util.debug('l_row_label_id = '|| l_row_label_id_tbl(i));
        END LOOP;
        FOR i IN (MOD(l_count, 25)+1) .. 25 LOOP
          l_row_label_id_tbl(i):= null;
  pa_timeline_util.debug('l_row_label_id = '|| l_row_label_id_tbl(i));
        END LOOP;
      END IF;

      IF p_timeline_type = 'ResourceSchedules' THEN
        IF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'RESOURCE' time_chart_record_type,
resource_id row_label_id,
item_date start_date,
item_date end_date,
global_exp_period_end_date week_end_date,
'MONTH' scale_type,
decode(availability_flag,
  'Y', decode(sign(capacity_quantity*g_res_capacity_percentage-availability_quantity), 1, 0, availability_quantity),
  'N', decode(sign(capacity_quantity*g_overcommitment_percentage-overcommitment_quantity), 1, 0, 0, 0, overcommitment_quantity)) quantity, --For Bug 8812042
col.render_priority,
col.file_name color_file_name
from pa_forecast_items, pa_timeline_colors col
where resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and error_flag in ('N','Y')   --Bug#9479220
and forecast_item_type = 'U'
and item_date between p_start_date and p_end_date
and delete_flag = 'N'
and (availability_flag = 'Y' or overcommitment_flag = 'Y')
and col.lookup_code = decode(availability_flag, 'Y', 'AVAILABLE', 'N',
 decode(sign(overcommitment_quantity - capacity_quantity*g_overcommitment_percentage), 1, 'OVERCOMMITTED', 0, 'AVAILABLE')) --For Bug 8812042
UNION ALL
select
'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added  for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'DAILY' AND p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select 'RESOURCE' time_chart_record_type,
resource_id row_label_id,
global_exp_period_end_date-6 start_date,
global_exp_period_end_date end_date,
global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(decode(availability_flag,
      'Y', decode(sign((capacity_quantity*g_res_capacity_percentage)-availability_quantity), 1, 0, availability_quantity),
      'N', decode(sign((capacity_quantity*g_overcommitment_percentage)-overcommitment_quantity), 1, 0, 0, 0, overcommitment_quantity))) quantity, --For Bug 8812042
col.render_priority,
col.file_name color_file_name
from pa_forecast_items, pa_timeline_colors col
where resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and error_flag in ('N','Y')   --Bug#9479220
and item_date between p_start_date and p_end_date
and delete_flag = 'N'
and col.lookup_code = decode(availability_flag, 'Y', 'AVAILABLE', 'N',
 decode(sign(overcommitment_quantity - capacity_quantity*g_overcommitment_percentage), 1, 'OVERCOMMITTED', 0, 'AVAILABLE')) --For Bug 8812042
and (availability_flag = 'Y' or overcommitment_flag = 'Y')
GROUP BY resource_id,
global_exp_period_end_date,
col.file_name,
col.render_priority
UNION ALL
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
GROUP BY fi.resource_id,
fi.global_exp_period_end_date,
fi.forecast_item_type,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'DAILY' AND p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
GROUP BY fi.resource_id,
fi.global_exp_period_end_date,
fi.forecast_item_type,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
decode(fi_week.availability_flag, 'Y', fi.availability_quantity, 'N', fi.overcommitment_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col,
(select resource_id,
  global_exp_period_end_date week_end_date,
  decode(sign(sum(capacity_quantity)*g_res_capacity_percentage-sum(availability_quantity)),1, 'N', 'Y') availability_flag,
  decode(sign(sum(capacity_quantity)*g_overcommitment_percentage-sum(overcommitment_quantity)), 1, 'N',
         0, decode(sum(overcommitment_quantity), 0, 'N', 'Y'),
         -1, 'Y') overcommitment_flag,
  forecast_item_type,
  delete_flag
  from pa_forecast_items
  where item_date between p_start_date and p_end_date
  group by resource_id,
  global_exp_period_end_date,
  forecast_item_type,
  delete_flag) fi_week
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.resource_id = fi_week.resource_id
and fi.item_date between p_start_date and p_end_date
and fi.global_exp_period_end_date = fi_week.week_end_date
and fi.forecast_item_type = 'U'
and fi.forecast_item_type = fi_week.forecast_item_type
and fi.delete_flag = 'N'
and fi.delete_flag = fi_week.delete_flag
and (fi.availability_quantity > 0 or fi.overcommitment_quantity > 0)
and (fi_week.availability_flag = 'Y' or fi_week.overcommitment_flag = 'Y')
and col.lookup_code = decode(fi_week.availability_flag, 'Y', 'AVAILABLE', 'N', 'OVERCOMMITTED')
UNION ALL
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(decode(fi_week.availability_flag, 'Y', fi.availability_quantity, 'N', fi.overcommitment_quantity)) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col,
(select resource_id,
  global_exp_period_end_date week_end_date,
  decode(sign(sum(capacity_quantity)*g_res_capacity_percentage-sum(availability_quantity)),1, 'N', 'Y') availability_flag,
  decode(sign(sum(capacity_quantity)*g_overcommitment_percentage-sum(overcommitment_quantity)), 1, 'N',
         0, decode(sum(overcommitment_quantity), 0, 'N', 'Y'),
         -1, 'Y') overcommitment_flag,
  forecast_item_type,
  delete_flag
  from pa_forecast_items
  where item_date between p_start_date and p_end_date
  group by resource_id,
  global_exp_period_end_date,
  forecast_item_type,
  delete_flag) fi_week
where fi.resource_id in(l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.resource_id = fi_week.resource_id
and fi.item_date between p_start_date and p_end_date
and fi.global_exp_period_end_date = fi_week.week_end_date
and fi.forecast_item_type = 'U'
and fi.forecast_item_type = fi_week.forecast_item_type
and fi.delete_flag = 'N'
and fi.delete_flag = fi_week.delete_flag
and (fi.availability_quantity > 0 or fi.overcommitment_quantity > 0)
and (fi_week.availability_flag = 'Y' or fi_week.overcommitment_flag = 'Y')
and col.lookup_code = decode(fi.availability_flag, 'Y', 'AVAILABLE', 'N',
 decode(sign(fi.overcommitment_quantity - fi.capacity_quantity*g_overcommitment_percentage), 1, 'OVERCOMMITTED', 0, 'AVAILABLE')) --For Bug 8812042
GROUP BY fi.resource_id,
fi.global_exp_period_end_date,
fi_week.availability_flag,
col.file_name,
col.render_priority
UNION ALL
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
GROUP BY fi.resource_id,
fi.global_exp_period_end_date,
fi.forecast_item_type,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select 'RESOURCE' time_chart_record_type,
fi.resource_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and fi.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                 'STAFFED_ADMIN_ASSIGNMENT',decode(asgmt_sys_status_code,
                                                   'STAFFED_ASGMT_CONF',
                                                   'CONFIRMED_ADMIN',
                                                   'STAFFED_ASGMT_PROV'),
                 'STAFFED_ASSIGNMENT', decode(asgmt_sys_status_code,
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_CONF',
                                              'STAFFED_ASGMT_PROV'))
GROUP BY fi.resource_id,
fi.global_exp_period_end_date,
fi.forecast_item_type,
col.file_name,
col.render_priority
);
        END IF;

      -- Resource Details Timeline
			ELSIF p_timeline_type = 'ResourceAssignments' THEN
        IF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
decode(fi.availability_flag, 'Y', 'AVAILABLE', 'N', 'OVERCOMMITTED')time_chart_record_type,
decode(fi.availability_flag, 'Y', -99, 'N', -100) row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
decode (fi.availability_flag,
  'Y', decode(sign(fi.availability_quantity-fi.capacity_quantity*g_res_capacity_percentage), -1, 0, fi.availability_quantity),
  'N', decode(sign(fi.overcommitment_quantity-fi.capacity_quantity*g_overcommitment_percentage), -1, 0, 0, 0, fi.overcommitment_quantity)) quantity, --Bug 8627070
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col
where fi.resource_id = p_resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'U'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and (fi.availability_flag = 'Y' or fi.overcommitment_flag = 'Y')
and col.lookup_code = decode(availability_flag, 'Y', 'AVAILABLE', 'N',
 decode(sign(overcommitment_quantity - capacity_quantity*g_overcommitment_percentage), 1, 'OVERCOMMITTED', 0, 'AVAILABLE')) --For Bug 8812042
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'DAILY' AND p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
decode(fi.availability_flag, 'Y', 'AVAILABLE', 'N', 'OVERCOMMITTED') time_chart_record_type,
decode(fi.availability_flag, 'Y', -99, 'N', -100) row_label_id,
fi.global_exp_period_end_date - 6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(decode(fi.availability_flag,
      'Y', decode(sign(fi.capacity_quantity*g_res_capacity_percentage-fi.availability_quantity), 1, 0, fi.availability_quantity),
      'N', decode(sign(fi.capacity_quantity*g_overcommitment_percentage-fi.overcommitment_quantity), 1, 0, 0, 0, fi.overcommitment_quantity))) quantity,   --Bug 8627070
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col
where fi.resource_id = p_resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'U'
and fi.item_date between p_start_date and p_end_date
and fi.delete_flag = 'N'
and col.lookup_code = decode(availability_flag, 'Y', 'AVAILABLE', 'N',
 decode(sign(overcommitment_quantity - capacity_quantity*g_overcommitment_percentage), 1, 'OVERCOMMITTED', 0, 'AVAILABLE')) --For Bug 8812042
and (fi.availability_flag = 'Y' or fi.overcommitment_flag = 'Y')
GROUP BY fi.assignment_id,
fi.global_exp_period_end_date,
fi.availability_flag,
col.file_name,
col.render_priority
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
GROUP BY fi.assignment_id,
fi.global_exp_period_end_date,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'DAILY' AND p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
GROUP BY fi.assignment_id,
fi.global_exp_period_end_date,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'MONTH' and prm_license = 'Y' THEN
  pa_timeline_util.debug('Resource Details: weekly month');
          INSERT INTO pa_time_chart_temp (
select
decode(fi_week.availability_flag, 'Y', 'AVAILABLE', 'N', 'OVERCOMMITTED') time_chart_record_type,
decode(fi_week.availability_flag, 'Y', -99, 'N', -100) row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi_week.week_end_date,
'MONTH' scale_type,
decode(fi_week.availability_flag, 'Y', fi.availability_quantity, 'N', fi.overcommitment_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col,
(select resource_id,
  global_exp_period_end_date week_end_date,
  decode(sign(sum(capacity_quantity)*g_res_capacity_percentage-sum(availability_quantity)),1, 'N', 'Y') availability_flag,
  decode(sign(sum(capacity_quantity)*g_overcommitment_percentage-sum(overcommitment_quantity)), 1, 'N',
         0, decode(sum(overcommitment_quantity), 0, 'N', 'Y'),
         -1, 'Y') overcommitment_flag,
  forecast_item_type,
  delete_flag
  from pa_forecast_items
  where item_date between p_start_date and p_end_date
  group by resource_id,
  global_exp_period_end_date,
  forecast_item_type,
  delete_flag) fi_week
where fi.resource_id = p_resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.resource_id = fi_week.resource_id
and fi.item_date between p_start_date and p_end_date
and fi.global_exp_period_end_date = fi_week.week_end_date
and fi.forecast_item_type = 'U'
and fi.forecast_item_type = fi_week.forecast_item_type
and fi.delete_flag = 'N'
and fi.delete_flag = fi_week.delete_flag
and (fi.availability_quantity > 0 or fi.overcommitment_quantity > 0)
and (fi_week.availability_flag = 'Y' or fi_week.overcommitment_flag = 'Y')
and col.lookup_code = decode(fi.availability_flag, 'Y', 'AVAILABLE', 'N',
 decode(sign(fi.overcommitment_quantity - fi.capacity_quantity*g_overcommitment_percentage), 1, 'OVERCOMMITTED', 0, 'AVAILABLE')) --For Bug 8812042
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
  pa_timeline_util.debug('Resource Details: weekly month');
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
  pa_timeline_util.debug('Resource Details: weekly | three_month');
          INSERT INTO pa_time_chart_temp (
select
decode(fi_week.availability_flag, 'Y', 'AVAILABLE', 'N', 'OVERCOMMITTED') time_chart_record_type,
decode(fi_week.availability_flag, 'Y', -99, 'N', -100) row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(decode(fi_week.availability_flag, 'Y', fi.availability_quantity, 'N', fi.overcommitment_quantity)) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col,
(select resource_id,
  global_exp_period_end_date week_end_date,
  decode(sign(sum(capacity_quantity)*g_res_capacity_percentage-sum(availability_quantity)),1, 'N', 'Y') availability_flag,
  decode(sign(sum(capacity_quantity)*g_overcommitment_percentage-sum(overcommitment_quantity)), 1, 'N',
         0, decode(sum(overcommitment_quantity), 0, 'N', 'Y'),
         -1, 'Y') overcommitment_flag,
  forecast_item_type,
  delete_flag
  from pa_forecast_items
  where item_date between p_start_date and p_end_date
  group by resource_id,
  global_exp_period_end_date,
  forecast_item_type,
  delete_flag) fi_week
where fi.resource_id = p_resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.resource_id = fi_week.resource_id
and fi.item_date between p_start_date and p_end_date
and fi.global_exp_period_end_date = fi_week.week_end_date
and fi.forecast_item_type = 'U'
and fi.forecast_item_type = fi_week.forecast_item_type
and fi.delete_flag = 'N'
and fi.delete_flag = fi_week.delete_flag
and (fi.availability_quantity > 0 or fi.overcommitment_quantity > 0)
and (fi_week.availability_flag = 'Y' or fi_week.overcommitment_flag = 'Y')
and col.lookup_code = decode(fi.availability_flag, 'Y', 'AVAILABLE', 'N',
 decode(sign(fi.overcommitment_quantity - fi.capacity_quantity*g_overcommitment_percentage), 1, 'OVERCOMMITTED', 0, 'AVAILABLE')) --For Bug 8812042
GROUP BY fi.resource_id,
fi.global_exp_period_end_date,
fi_week.availability_flag,
col.file_name,
col.render_priority
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
group by fi.assignment_id,
fi.global_exp_period_end_date,
col.render_priority,
col.file_name
);

        ELSIF g_availability_cal_period = 'WEEKLY' AND p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
  pa_timeline_util.debug('Resource Details: weekly | three_month');
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
group by fi.assignment_id,
fi.global_exp_period_end_date,
col.render_priority,
col.file_name
);


        END IF;

      -- Resource Overcommitment Timeline
      ELSIF p_timeline_type = 'ResourceOvercommitmentCalc' THEN
        IF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'OVERCOMMITTED' time_chart_record_type,
-100 row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
(fi_assigned.assigned_quantity-fi.capacity_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col,
(select resource_id,
 sum(item_quantity) assigned_quantity,
 item_date,
 delete_flag
 from
 (select fi1.resource_id,
  fi1.item_quantity,
  fi1.item_date,
  fi1.delete_flag
  from pa_forecast_items fi1, pa_project_assignments asgn, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
  where (fi1.assignment_id = p_assignment_id
      or fi1.assignment_id in
      (select conflict_assignment_id
       from pa_assignment_conflict_hist
       where assignment_id = p_assignment_id
       and conflict_group_id = p_conflict_group_id
       and self_conflict_flag = 'N'
       and intra_txn_conflict_flag = 'Y'))
  and fi1.assignment_id = asgn.assignment_id
  and asgn.assignment_id = sch.assignment_id
  and asgn.apprvl_status_code NOT IN ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
  and fi1.item_date between sch.start_date and sch.end_date
  and sch.status_code = a.project_status_code
  and a.wf_success_status_code = b.project_status_code
  and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
  and fi1.forecast_item_type = 'A'
  UNION ALL
  select fi2.resource_id,
  item_quantity,
  fi2.item_date,
  fi2.delete_flag
  from pa_forecast_items fi2, pa_project_assignments asgn, pa_assignment_conflict_hist hist
  where fi2.assignment_id = asgn.assignment_id
  and fi2.assignment_id = hist.conflict_assignment_id
  and hist.conflict_group_id = p_conflict_group_id
  and hist.assignment_id = p_assignment_id
  and hist.self_conflict_flag = 'N'
  and fi2.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
  and ((asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED') and hist.intra_txn_conflict_flag = 'Y')
        or hist.intra_txn_conflict_flag = 'N')
  and fi2.forecast_item_type = 'A'
  UNION ALL
  select fi2.resource_id,
  item_quantity,
  fi2.item_date,
  fi2.delete_flag
  from pa_forecast_items fi2, pa_project_assignments asgn
  where fi2.assignment_id = p_assignment_id
  and fi2.assignment_id = asgn.assignment_id
  and fi2.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
  and asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
  and fi2.forecast_item_type = 'A'
  )
  group by resource_id, item_date, delete_flag
)FI_ASSIGNED
where fi.forecast_item_type = 'U'
and ((fi_assigned.assigned_quantity-fi.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) > 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
   or(fi_assigned.assigned_quantity-fi.capacity_quantity > 0 and G_OVERCOMMITMENT_PERCENTAGE = 0)) -- Bug 8627070
and fi.delete_flag = 'N'
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.delete_flag = fi_assigned.delete_flag
and fi.item_date between p_start_date and p_end_date
and fi.item_date = fi_assigned.item_date
and fi.resource_id = p_resource_id
and fi.resource_id = fi_assigned.resource_id
and col.lookup_code = 'OVERCOMMITTED'
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and fi.assignment_id = asgn.assignment_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'OVERCOMMITTED' time_chart_record_type,
-100 row_label_id,
fi.global_exp_period_end_date - 6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi_assigned.assigned_quantity-fi.capacity_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col,
(select resource_id,
 sum(item_quantity) assigned_quantity,
 item_date,
 delete_flag
 from
 (select fi1.resource_id,
  fi1.item_quantity,
  fi1.item_date,
  fi1.delete_flag
  from pa_forecast_items fi1, pa_project_assignments asgn, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
  where (fi1.assignment_id = p_assignment_id
      or fi1.assignment_id in
      (select conflict_assignment_id
       from pa_assignment_conflict_hist
       where assignment_id = p_assignment_id
       and conflict_group_id = p_conflict_group_id
       and self_conflict_flag = 'N'
       and intra_txn_conflict_flag = 'Y'))
  and fi1.assignment_id = asgn.assignment_id
  and asgn.assignment_id = sch.assignment_id
  and asgn.apprvl_status_code NOT IN ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
  and fi1.item_date between sch.start_date and sch.end_date
  and sch.status_code = a.project_status_code
  and a.wf_success_status_code = b.project_status_code
  and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
  and fi1.forecast_item_type = 'A'
  UNION ALL
  select fi2.resource_id,
  item_quantity,
  fi2.item_date,
  fi2.delete_flag
  from pa_forecast_items fi2, pa_project_assignments asgn, pa_assignment_conflict_hist hist
  where fi2.assignment_id = asgn.assignment_id
  and fi2.assignment_id = hist.conflict_assignment_id
  and hist.conflict_group_id = p_conflict_group_id
  and hist.assignment_id = p_assignment_id
  and hist.self_conflict_flag = 'N'
  and fi2.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
  and ((asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED') and hist.intra_txn_conflict_flag = 'Y')
        or hist.intra_txn_conflict_flag = 'N')
  and fi2.forecast_item_type = 'A'
  UNION ALL
  select fi2.resource_id,
  item_quantity,
  fi2.item_date,
  fi2.delete_flag
  from pa_forecast_items fi2, pa_project_assignments asgn
  where fi2.assignment_id = p_assignment_id
  and fi2.assignment_id = asgn.assignment_id
  and fi2.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
  and asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
  and fi2.forecast_item_type = 'A'
  )
  group by resource_id, item_date, delete_flag
)FI_ASSIGNED
where forecast_item_type = 'U'
and ((fi_assigned.assigned_quantity-fi.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) > 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
   or(fi_assigned.assigned_quantity-fi.capacity_quantity > 0 and G_OVERCOMMITMENT_PERCENTAGE = 0)) -- Bug 8627070
and fi.delete_flag = 'N'
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.delete_flag = fi_assigned.delete_flag
and fi.item_date between p_start_date and p_end_date
and fi.item_date = fi_assigned.item_date
and fi.resource_id = p_resource_id
and fi.resource_id = fi_assigned.resource_id
and col.lookup_code = 'OVERCOMMITTED'
GROUP BY fi.resource_id,
fi.global_exp_period_end_date,
col.file_name,
col.render_priority
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and fi.assignment_id = asgn.assignment_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
GROUP BY fi.assignment_id,
fi.global_exp_period_end_date,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and fi.assignment_id = asgn.assignment_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
GROUP BY fi.assignment_id,
fi.global_exp_period_end_date,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'OVERCOMMITTED' time_chart_record_type,
-100 row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi. global_exp_period_end_date week_end_date,
'MONTH' scale_type,
(fi_assigned.assigned_quantity-fi.capacity_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col,
(select resource_id,
   sum(item_quantity) assigned_quantity,
   item_date,
   delete_flag
   from
   (select fi1.resource_id,
   item_quantity,
   fi1.item_date,
   fi1.delete_flag
   from pa_forecast_items fi1, pa_project_assignments asgn, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
   where (fi1.assignment_id = p_assignment_id
      or fi1.assignment_id in
      (select conflict_assignment_id
       from pa_assignment_conflict_hist
       where assignment_id = p_assignment_id
       and conflict_group_id = p_conflict_group_id
       and self_conflict_flag = 'N'
       and intra_txn_conflict_flag = 'Y'))
   and fi1.assignment_id = asgn.assignment_id
   and asgn.assignment_id = sch.assignment_id
   and asgn.apprvl_status_code NOT IN ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
   and fi1.item_date between sch.start_date and sch.end_date
   and sch.status_code = a.project_status_code
   and a.wf_success_status_code = b.project_status_code
   and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
   and forecast_item_type = 'A'
   UNION ALL
   select fi2.resource_id,
   item_quantity,
   fi2.item_date,
   fi2.delete_flag
   from pa_forecast_items fi2, pa_project_assignments asgn, pa_assignment_conflict_hist hist
   where fi2.assignment_id = asgn.assignment_id
   and fi2.assignment_id = hist.conflict_assignment_id
   and hist.conflict_group_id = p_conflict_group_id
   and hist.assignment_id = p_assignment_id
   and hist.self_conflict_flag = 'N'
   and fi2.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
   and ((asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED') and hist.intra_txn_conflict_flag = 'Y')
           or hist.intra_txn_conflict_flag = 'N')
   and fi2.forecast_item_type = 'A'
   UNION ALL
   select fi2.resource_id,
   item_quantity,
   fi2.item_date,
   fi2.delete_flag
   from pa_forecast_items fi2, pa_project_assignments asgn
   where fi2.assignment_id = p_assignment_id
   and fi2.assignment_id = asgn.assignment_id
   and fi2.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
   and asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
   and fi2.forecast_item_type = 'A'
   )
   group by resource_id, item_date, delete_flag
)FI_ASSIGNED,
(select fi_week_capacity.resource_id,
    decode(sign((fi_week_assigned.assigned_quantity-fi_week_capacity.capacity_quantity)-fi_week_capacity.capacity_quantity*G_OVERCOMMITMENT_PERCENTAGE),
    -1, 'N',
    0, decode(fi_week_assigned.assigned_quantity-fi_week_capacity.capacity_quantity, 0, 'N', 'Y'),
    1, 'Y') overcom_flag,
    fi_week_capacity.global_exp_period_end_date,
    fi_week_capacity.delete_flag
    from
   (select resource_id,
      sum(item_quantity) assigned_quantity,
      global_exp_period_end_date,
      delete_flag
      from
     (select fi3.resource_id,
       fi3.item_quantity,
       fi3.global_exp_period_end_date,
       fi3.delete_flag
       from pa_forecast_items fi3, pa_project_assignments asgn, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
       where (fi3.assignment_id = p_assignment_id
       or fi3.assignment_id in
        (select conflict_assignment_id
         from pa_assignment_conflict_hist
         where assignment_id = p_assignment_id
         and conflict_group_id = p_conflict_group_id
         and self_conflict_flag = 'N'
         and intra_txn_conflict_flag = 'Y'))
       and fi3.assignment_id = asgn.assignment_id
       and asgn.assignment_id = sch.assignment_id
       and asgn.apprvl_status_code NOT IN ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
       and fi3.item_date between sch.start_date and sch.end_date
       and sch.status_code = a.project_status_code
       and a.wf_success_status_code = b.project_status_code
       and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
       and fi3.forecast_item_type = 'A'
       UNION ALL
       select fi4.resource_id,
       fi4.item_quantity,
       fi4.global_exp_period_end_date,
       fi4.delete_flag
       from pa_forecast_items fi4, pa_project_assignments asgn, pa_assignment_conflict_hist hist
       where fi4.assignment_id = asgn.assignment_id
       and fi4.assignment_id = hist.conflict_assignment_id
       and hist.conflict_group_id = p_conflict_group_id
       and hist.assignment_id = p_assignment_id
       and hist.self_conflict_flag = 'N'
       and fi4.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
       and ((asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED') and hist.intra_txn_conflict_flag = 'Y')
          or hist.intra_txn_conflict_flag = 'N')
       and fi4.forecast_item_type = 'A'
       UNION ALL
       select fi4.resource_id,
       item_quantity,
       fi4.global_exp_period_end_date,
       fi4.delete_flag
       from pa_forecast_items fi4, pa_project_assignments asgn
       where fi4.assignment_id = p_assignment_id
       and fi4.assignment_id = asgn.assignment_id
       and fi4.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
       and asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
       and fi4.forecast_item_type = 'A')
     group by resource_id, global_exp_period_end_date, delete_flag) FI_WEEK_ASSIGNED,
     (select resource_id,
      sum(capacity_quantity) capacity_quantity,
      global_exp_period_end_date,
      delete_flag
      from pa_forecast_items
      where forecast_item_type = 'U'
      group by resource_id, global_exp_period_end_date, delete_flag) FI_WEEK_CAPACITY
   where fi_week_capacity.resource_id = fi_week_assigned.resource_id
   and fi_week_capacity.global_exp_period_end_date = fi_week_assigned.global_exp_period_end_date
   and fi_week_capacity.delete_flag = fi_week_assigned.delete_flag
)FI_WEEK
where fi.resource_id = p_resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.resource_id = fi_assigned.resource_id
and fi_assigned.resource_id = fi_week.resource_id
and fi.forecast_item_type = 'U'
and fi.delete_flag = 'N'
and fi.delete_flag = fi_assigned.delete_flag
and fi_assigned.delete_flag = fi_week.delete_flag
and fi.item_date between p_start_date and p_end_date
and fi.item_date = fi_assigned.item_date
and fi.global_exp_period_end_date = fi_week.global_exp_period_end_date
and fi_week.overcom_flag = 'Y'
and col.lookup_code = 'OVERCOMMITTED'
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.item_date start_date,
fi.item_date end_date,
fi.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
);

        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'OVERCOMMITTED' time_chart_record_type,
-100 row_label_id,
fi_week.global_exp_period_end_date-6 start_date,
fi_week.global_exp_period_end_date end_date,
fi_week.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
fi_week.overcom_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_timeline_colors col,
(select
   fi_week_capacity.resource_id,
   decode(sign((fi_week_assigned.assigned_quantity-fi_week_capacity.capacity_quantity)-fi_week_capacity.capacity_quantity*G_OVERCOMMITMENT_PERCENTAGE),
   -1, 0, fi_week_assigned.assigned_quantity-fi_week_capacity.capacity_quantity) overcom_quantity,
   fi_week_capacity.global_exp_period_end_date,
   fi_week_capacity.delete_flag
   from
   (select resource_id,
      sum(item_quantity) assigned_quantity,
      global_exp_period_end_date,
      delete_flag
      from
     (select fi3.resource_id,
       fi3.item_quantity,
       fi3.global_exp_period_end_date,
       fi3.delete_flag
       from pa_forecast_items fi3, pa_project_assignments asgn, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
       where (fi3.assignment_id = p_assignment_id
       or fi3.assignment_id in
        (select conflict_assignment_id
         from pa_assignment_conflict_hist
         where assignment_id = p_assignment_id
         and conflict_group_id = p_conflict_group_id
         and self_conflict_flag = 'N'
         and intra_txn_conflict_flag = 'Y'))
       and fi3.assignment_id = asgn.assignment_id
       and asgn.assignment_id = sch.assignment_id
       and asgn.apprvl_status_code NOT IN ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
       and fi3.item_date between sch.start_date and sch.end_date
       and sch.status_code = a.project_status_code
       and a.wf_success_status_code = b.project_status_code
       and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
       and fi3.forecast_item_type = 'A'
       UNION ALL
       select fi4.resource_id,
       fi4.item_quantity,
       fi4.global_exp_period_end_date,
       fi4.delete_flag
       from pa_forecast_items fi4, pa_project_assignments asgn, pa_assignment_conflict_hist hist
       where fi4.assignment_id = asgn.assignment_id
       and fi4.assignment_id = hist.conflict_assignment_id
       and hist.conflict_group_id = p_conflict_group_id
       and hist.assignment_id = p_assignment_id
       and hist.self_conflict_flag = 'N'
       and fi4.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
       and ((asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED') and hist.intra_txn_conflict_flag = 'Y')
          or hist.intra_txn_conflict_flag = 'N')
       and fi4.forecast_item_type = 'A'
       UNION ALL
       select fi4.resource_id,
       item_quantity,
       fi4.global_exp_period_end_date,
       fi4.delete_flag
       from pa_forecast_items fi4, pa_project_assignments asgn
       where fi4.assignment_id = p_assignment_id
       and fi4.assignment_id = asgn.assignment_id
       and fi4.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
       and asgn.apprvl_status_code in ('ASGMT_APPRVL_APPROVED', 'ASGMT_APPRVL_REJECTED')
       and fi4.forecast_item_type = 'A')
       group by resource_id, global_exp_period_end_date, delete_flag) FI_WEEK_ASSIGNED,
       (select resource_id,
        sum(capacity_quantity) capacity_quantity,
        global_exp_period_end_date,
        delete_flag
        from pa_forecast_items
        where forecast_item_type = 'U'
        group by resource_id, global_exp_period_end_date, delete_flag) FI_WEEK_CAPACITY
   where fi_week_capacity.resource_id = fi_week_assigned.resource_id
   and fi_week_capacity.global_exp_period_end_date = fi_week_assigned.global_exp_period_end_date
   and fi_week_capacity.delete_flag = fi_week_assigned.delete_flag
)FI_WEEK
where fi_week.resource_id = p_resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi_week.delete_flag = 'N'
and fi_week.overcom_quantity > 0
and fi_week.global_exp_period_end_date between p_start_date and p_end_date
and col.lookup_code = 'OVERCOMMITTED'
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
group by fi.assignment_id,
fi.global_exp_period_end_date,
col.render_priority,
col.file_name
);

        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
'ASSIGNMENT' time_chart_record_type,
fi.assignment_id row_label_id,
fi.global_exp_period_end_date-6 start_date,
fi.global_exp_period_end_date end_date,
fi.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi, pa_timeline_colors col, pa_project_assignments asgn
where fi.resource_id = p_resource_id
and (fi.assignment_id = p_assignment_id or fi.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25)))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi.error_flag in ('N','Y')   --Bug#9479220
and fi.assignment_id = asgn.assignment_id
and fi.forecast_item_type = 'A'
and fi.delete_flag = 'N'
and fi.item_date between p_start_date and p_end_date
and col.lookup_code = decode(asgn.assignment_type,
  'STAFFED_ADMIN_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                                'STAFFED_ASGMT_CONF',
                                'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
  'STAFFED_ASSIGNMENT', decode(fi.asgmt_sys_status_code,
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_CONF',
                          'STAFFED_ASGMT_PROV'))
group by fi.assignment_id,
fi.global_exp_period_end_date,
col.render_priority,
col.file_name
);
        END IF;


      -- Team List Timeline.
      ELSIF p_timeline_type = 'ProjectAssignments' THEN

        IF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp  (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi1.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and fi1.delete_flag = 'N'
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.assignment_id = asgn.assignment_id
and fi1.delete_flag = 'N'
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
/* Commenting for bug 3280808
UNION ALL
 select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi_admin.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.item_date between p_start_date and p_end_date
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.resource_id = fi_admin.resource_id
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
End of commenting for bug 3280808 */
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi_overcom.overcommitment_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.item_date,
   fi.delete_flag,
   decode(sign(fi.capacity_quantity*g_overcommitment_percentage-fi.overcommitment_quantity), 1, 0, 0, 0, fi.overcommitment_quantity) overcommitment_quantity --For Bug 8812042
   from pa_forecast_items fi
   where fi.forecast_item_type = 'U' ) fi_overcom
where fi1.resource_id = fi_overcom.resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.forecast_item_type = 'A'
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_overcom.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_overcom.delete_flag
and col.lookup_code = 'OVERCOMMITTED'
and fi_overcom.overcommitment_quantity > 0
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp  (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi1.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.delete_flag = 'N'
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.assignment_id = asgn.assignment_id
and fi1.delete_flag = 'N'
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
/* Commenting for bug 3280808
UNION ALL
 select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi_admin.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.item_date between p_start_date and p_end_date
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.resource_id = fi_admin.resource_id
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
End of commenting for bug 3280808 */
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.global_exp_period_end_date-6 start_date,
fi1.global_exp_period_end_date end_date,
fi1.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi1.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and fi1.delete_flag = 'N'
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
/* Commenting for bug 3280808
UNION ALL
 select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
trunc(fi1.global_exp_period_end_date)-6 start_date,
trunc(fi1.global_exp_period_end_date) end_date,
trunc(fi1.global_exp_period_end_date) week_end_date,
'THREE_MONTH' scale_type,
sum(fi_admin.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.resource_id = fi_admin.resource_id
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
End of commenting for bug bug 3280808*/
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.global_exp_period_end_date-6 start_date,
fi1.global_exp_period_end_date end_date,
fi1.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi_overcom.overcommitment_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.item_date,
   fi.delete_flag,
   decode(sign(fi.capacity_quantity*g_overcommitment_percentage-fi.overcommitment_quantity), 1, 0, 0, 0, fi.overcommitment_quantity) overcommitment_quantity --For Bug 8812042
   from pa_forecast_items fi
   where fi.forecast_item_type = 'U' ) fi_overcom
where fi1.resource_id = fi_overcom.resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.forecast_item_type = 'A'
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_overcom.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_overcom.delete_flag
and col.lookup_code = 'OVERCOMMITTED'
and fi_overcom.overcommitment_quantity > 0
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'DAILY' and p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
          INSERT INTO pa_time_chart_temp (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.global_exp_period_end_date-6 start_date,
fi1.global_exp_period_end_date end_date,
fi1.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi1.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.delete_flag = 'N'
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
/* Commenting for bug 3280808
UNION ALL
 select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
trunc(fi1.global_exp_period_end_date)-6 start_date,
trunc(fi1.global_exp_period_end_date) end_date,
trunc(fi1.global_exp_period_end_date) week_end_date,
'THREE_MONTH' scale_type,
sum(fi_admin.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.resource_id = fi_admin.resource_id
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
End of commenting for bug bug 3280808*/
);


        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'MONTH' and prm_license = 'Y' THEN
-----------------------------------------------------------------
-- Bug Reference : 6524548
-- We are restricting the Index Scan (ROW_ID) on PA_FORECAST_ITEMS
-- By supplying the Resource Ids for the assignments by joining
-- PA_PROJECT_ASSIGNMENTS and Further filtering on DELETE FLAG ('N')
-- As DELETE_FLAG having value 'Y' are records which are eligible
-- purge and we need not scan them too.
------------------------------------------------------------------
            INSERT INTO pa_time_chart_temp  (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi1.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.delete_flag = 'N'
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.assignment_id = asgn.assignment_id
and fi1.delete_flag = 'N'
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
/*Commenting for bug 3280808
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi_admin.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.item_date between p_start_date and p_end_date
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.resource_id = fi_admin.resource_id
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
End of commenting for bug 3280808 */
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi_overcom.overcommitment_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.item_date,
   fi.delete_flag,
   decode(fi_week.overcommitment_flag, 'Y', fi.overcommitment_quantity, 'N', 0) overcommitment_quantity
   from pa_forecast_items fi,
-- Added below for Bug# 6524548
     (select paf.resource_id,
        paf.global_exp_period_end_date,
        decode(sign(sum(paf.capacity_quantity)*g_overcommitment_percentage-sum(paf.overcommitment_quantity)),
1, 'N',
         0, decode(sum(paf.overcommitment_quantity), 0, 'N', 'Y'),
     --(select resource_id,
     --   global_exp_period_end_date,
     --   decode(sign(sum(capacity_quantity)*g_overcommitment_percentage-sum(overcommitment_quantity)), 1, 'N',
     --    0, decode(sum(overcommitment_quantity), 0, 'N', 'Y'),
-- End for Bug# 6524548
         -1, 'Y') overcommitment_flag,
-- Added below for Bug# 6524548
        paf.forecast_item_type,
        paf.delete_flag
      from pa_forecast_items paf,
           PA_PROJECT_ASSIGNMENTS PAP
     where PAF.RESOURCE_ID = PAP.RESOURCE_ID
       AND PAF.DELETE_FLAG = 'N'
       AND PAP.ASSIGNMENT_ID IN ( l_row_label_id_tbl(1), l_row_label_id_tbl(2),
                                  l_row_label_id_tbl(3), l_row_label_id_tbl(4),
				  l_row_label_id_tbl(5), l_row_label_id_tbl(6),
				  l_row_label_id_tbl(7), l_row_label_id_tbl(8),
                                  l_row_label_id_tbl(9), l_row_label_id_tbl(10),
				  l_row_label_id_tbl(11),l_row_label_id_tbl(12),
				  l_row_label_id_tbl(13),l_row_label_id_tbl(14),
                                  l_row_label_id_tbl(15),l_row_label_id_tbl(16),
				  l_row_label_id_tbl(17),l_row_label_id_tbl(18),
				  l_row_label_id_tbl(19),l_row_label_id_tbl(20),
                                  l_row_label_id_tbl(21),l_row_label_id_tbl(22),
				  l_row_label_id_tbl(23),l_row_label_id_tbl(24),
				  l_row_label_id_tbl(25) )
            AND PAF.item_date between p_start_date and p_end_date
      group by PAF.resource_id, PAF.global_exp_period_end_date, PAF.forecast_item_type, PAF.delete_flag)fi_week
        --forecast_item_type,
        --delete_flag
      --from pa_forecast_items
      --where item_date between p_start_date and p_end_date
      --group by resource_id, global_exp_period_end_date, forecast_item_type, delete_flag)fi_week
-- End for Bug# 6524548
   where fi.resource_id = fi_week.resource_id
   and fi.global_exp_period_end_date = fi_week.global_exp_period_end_date
   and fi.forecast_item_type = 'U'
   and fi.forecast_item_type = fi_week.forecast_item_type
   and fi.delete_flag = fi_week.delete_flag) fi_overcom
where fi1.resource_id = fi_overcom.resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.forecast_item_type = 'A'
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_overcom.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_overcom.delete_flag
and col.lookup_code = 'OVERCOMMITTED'
and fi_overcom.overcommitment_quantity > 0
);

        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'MONTH' and prm_license <> 'Y' THEN
            INSERT INTO pa_time_chart_temp  (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi1.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.delete_flag = 'N'
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.assignment_id = asgn.assignment_id
and fi1.delete_flag = 'N'
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
/*Commenting for bug 3280808
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.item_date start_date,
fi1.item_date end_date,
fi1.global_exp_period_end_date week_end_date,
'MONTH' scale_type,
fi_admin.item_quantity quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.item_date between p_start_date and p_end_date
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.resource_id = fi_admin.resource_id
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
End of commenting for bug 3280808 */
);

        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'THREE_MONTH' and prm_license = 'Y' THEN
-----------------------------------------------------------------
-- Bug Reference : 6524548
-- We are restricting the Index Scan (ROW_ID) on PA_FORECAST_ITEMS
-- By supplying the Resource Ids for the assignments by joining
-- PA_PROJECT_ASSIGNMENTS and Further filtering on DELETE FLAG ('N')
-- As DELETE_FLAG having value 'Y' are records which are eligible
-- purge and we need not scan them too.
------------------------------------------------------------------
            INSERT INTO pa_time_chart_temp  (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.global_exp_period_end_date-6 start_date,
fi1.global_exp_period_end_date end_date,
fi1.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi1.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.delete_flag = 'N'
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
/* Commenting for bug 3280808
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
trunc(fi1.global_exp_period_end_date)-6 start_date,
trunc(fi1.global_exp_period_end_date) end_date,
trunc(fi1.global_exp_period_end_date) week_end_date,
'THREE_MONTH' scale_type,
sum(fi_admin.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.resource_id = fi_admin.resource_id
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
End of Commenting for bug 3280808 */
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.global_exp_period_end_date-6 start_date,
fi1.global_exp_period_end_date end_date,
fi1.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi_overcom.overcommitment_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.item_date,
   fi.delete_flag,
   decode(fi_week.overcommitment_flag, 'Y', fi.overcommitment_quantity, 'N', 0) overcommitment_quantity
   from pa_forecast_items fi,
-- Added below for Bug# 6524548
     (select PAF.resource_id,
        PAF.global_exp_period_end_date,
        decode(sign(sum(PAF.capacity_quantity)*g_overcommitment_percentage-sum(PAF.overcommitment_quantity)),
1, 'N',
         0, decode(sum(PAF.overcommitment_quantity), 0, 'N', 'Y'),
     --(select resource_id,
     --   global_exp_period_end_date,
     --   decode(sign(sum(capacity_quantity)*g_overcommitment_percentage-sum(overcommitment_quantity)), 1, 'N',
     --    0, decode(sum(overcommitment_quantity), 0, 'N', 'Y'),
-- End for Bug# 6524548
         -1, 'Y') overcommitment_flag,
  -- Added below for Bug# 6524548
        PAF.forecast_item_type,
        PAF.delete_flag
      from pa_forecast_items PAF,
           PA_PROJECT_ASSIGNMENTS PAP
     where PAF.RESOURCE_ID = PAP.RESOURCE_ID
       AND PAF.DELETE_FLAG = 'N'
       AND PAP.ASSIGNMENT_ID IN ( l_row_label_id_tbl(1), l_row_label_id_tbl(2),
                                  l_row_label_id_tbl(3), l_row_label_id_tbl(4),
				  l_row_label_id_tbl(5), l_row_label_id_tbl(6),
				  l_row_label_id_tbl(7), l_row_label_id_tbl(8),
                                  l_row_label_id_tbl(9), l_row_label_id_tbl(10),
				  l_row_label_id_tbl(11),l_row_label_id_tbl(12),
				  l_row_label_id_tbl(13),l_row_label_id_tbl(14),
                                  l_row_label_id_tbl(15),l_row_label_id_tbl(16),
				  l_row_label_id_tbl(17),l_row_label_id_tbl(18),
				  l_row_label_id_tbl(19),l_row_label_id_tbl(20),
                                  l_row_label_id_tbl(21),l_row_label_id_tbl(22),
				  l_row_label_id_tbl(23),l_row_label_id_tbl(24),
				  l_row_label_id_tbl(25) )
	AND PAF.item_date between p_start_date and p_end_date
      group by PAF.resource_id, PAF.global_exp_period_end_date, PAF.forecast_item_type, PAF.delete_flag)fi_week
        --forecast_item_type,
        --delete_flag
      --from pa_forecast_items
      --where item_date between p_start_date and p_end_date
      --group by resource_id, global_exp_period_end_date, forecast_item_type, delete_flag)fi_week
   -- End for Bug# 6524548
   where fi.resource_id = fi_week.resource_id
   and fi.global_exp_period_end_date = fi_week.global_exp_period_end_date
   and fi.forecast_item_type = 'U'
   and fi.forecast_item_type = fi_week.forecast_item_type
   and fi.delete_flag = fi_week.delete_flag) fi_overcom
where fi1.resource_id = fi_overcom.resource_id
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.forecast_item_type = 'A'
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_overcom.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_overcom.delete_flag
and col.lookup_code = 'OVERCOMMITTED'
and fi_overcom.overcommitment_quantity > 0
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
col.file_name,
col.render_priority
);

        ELSIF g_availability_cal_period = 'WEEKLY' and p_scale_type = 'THREE_MONTH' and prm_license <> 'Y' THEN
            INSERT INTO pa_time_chart_temp  (
select
decode(fi1.forecast_item_type, 'A', 'ASSIGNMENT', 'R', 'REQUIREMENT') time_chart_record_type,
fi1.assignment_id row_label_id,
fi1.global_exp_period_end_date-6 start_date,
fi1.global_exp_period_end_date end_date,
fi1.global_exp_period_end_date week_end_date,
'THREE_MONTH' scale_type,
sum(fi1.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col, pa_project_assignments asgn
where fi1.forecast_item_type in ('A', 'R')
and col.lookup_type =  'TIMELINE_STATUS' -- Added for Bug 5079783
and fi1.error_flag in ('N','Y')   --Bug#9479220
and fi1.delete_flag = 'N'
and fi1.item_date between p_start_date and p_end_date
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.assignment_id = asgn.assignment_id
and col.lookup_code = decode(asgn.assignment_type,
                   'STAFFED_ADMIN_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                      'STAFFED_ASGMT_CONF',
                                                      'CONFIRMED_ADMIN', 'STAFFED_ASGMT_PROV'),
                   'STAFFED_ASSIGNMENT', decode(fi1.asgmt_sys_status_code,
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_CONF',
                                                'STAFFED_ASGMT_PROV'),
                   'OPEN_ASSIGNMENT',  'OPEN_ASGMT')
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
/* Commenting for bug 3280808
UNION ALL
select
'ASSIGNMENT' time_chart_record_type,
fi1.assignment_id row_label_id,
trunc(fi1.global_exp_period_end_date)-6 start_date,
trunc(fi1.global_exp_period_end_date) end_date,
trunc(fi1.global_exp_period_end_date) week_end_date,
'THREE_MONTH' scale_type,
sum(fi_admin.item_quantity) quantity,
col.render_priority,
col.file_name color_file_name
from pa_forecast_items fi1, pa_timeline_colors col,
(select fi.resource_id,
   fi.assignment_id,
   fi.global_exp_period_end_date week_end_date,
   fi.item_date,
   fi.item_quantity,
   fi.forecast_item_type,
   fi.delete_flag
   from pa_forecast_items fi, pa_project_assignments asgn
   where fi.assignment_id = asgn.assignment_id
   and asgn.assignment_type = 'STAFFED_ADMIN_ASSIGNMENT'
   and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF') fi_admin
where fi1.resource_id = fi_admin.resource_id
and fi1.forecast_item_type = 'A'
and fi1.forecast_item_type = fi_admin.forecast_item_type
and fi1.assignment_id in (l_row_label_id_tbl(1), l_row_label_id_tbl(2),
l_row_label_id_tbl(3), l_row_label_id_tbl(4),l_row_label_id_tbl(5),
l_row_label_id_tbl(6), l_row_label_id_tbl(7),l_row_label_id_tbl(8),
l_row_label_id_tbl(9), l_row_label_id_tbl(10),l_row_label_id_tbl(11),
l_row_label_id_tbl(12), l_row_label_id_tbl(13),l_row_label_id_tbl(14),
l_row_label_id_tbl(15), l_row_label_id_tbl(16),l_row_label_id_tbl(17),
l_row_label_id_tbl(18), l_row_label_id_tbl(19),l_row_label_id_tbl(20),
l_row_label_id_tbl(21), l_row_label_id_tbl(22),l_row_label_id_tbl(23),
l_row_label_id_tbl(24), l_row_label_id_tbl(25))
and fi1.item_date between p_start_date and p_end_date
and fi1.item_date = fi_admin.item_date
and fi1.delete_flag = 'N'
and fi1.delete_flag = fi_admin.delete_flag
and col.lookup_code = 'CONFIRMED_ADMIN'
group by fi1.assignment_id,
fi1.global_exp_period_end_date,
fi1.forecast_item_type,
col.file_name,
col.render_priority
End of Commenting for bug 3280808 */
);

        END IF; -- End of Team List

      END IF;

    END LOOP;
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN OTHERS THEN
    x_msg_count     := 1;
    x_msg_data      := sqlerrm;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
      p_procedure_name => 'Poplulate_Time_Chart_Table');
    RAISE;

END populate_time_chart_table;


END PA_TIMELINE_PVT;

/
