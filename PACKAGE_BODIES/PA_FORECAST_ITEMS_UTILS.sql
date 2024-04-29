--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_ITEMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_ITEMS_UTILS" AS
/* $Header: PARFIUTB.pls 120.7.12010000.5 2010/04/13 06:58:18 amehrotr ship $ */

------------------------------------------------------------------------------------------------------------------
-- This function gets the unique identifier for the forecast item
-- Input parameters
-- Parameters                   Type           Required  Description
--
-- Out parameters
-- li_forecast_item_id          NUMBER            YES       It returns the unique identifier for forecast item
--
--------------------------------------------------------------------------------------------------------------------
FUNCTION  Get_Next_ForeCast_Item_ID  RETURN NUMBER IS
	li_forecast_item_id NUMBER;
BEGIN
    BEGIN

        SELECT pa_forecast_items_s.NEXTVAL
  	INTO li_forecast_item_id
	FROM DUAL;

    EXCEPTION
    	WHEN OTHERS then
          RAISE;
    END;

    RETURN li_forecast_item_id;

END Get_Next_ForeCast_Item_ID;

-- This function returns a lock handle for retrieving
-- and releasing a dbms_lock.  We have made it as
-- an autonomous transaction because it issues a commit.
-- However, requesting and releasing a lock does not
-- issue a commit;
PROCEDURE allocate_unique(p_lock_name  IN VARCHAR2,
                          p_lock_handle OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
   PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
	 dbms_lock.allocate_unique(
		 lockname => p_lock_name,
		 lockhandle => p_lock_handle);
   commit;

--4537865
EXCEPTION
WHEN OTHERS THEN
        p_lock_handle := NULL ;
        -- RAISE is not needed here . Caller takes care of this scenario by checking against p_lock_handle
END allocate_unique;

------------------------------------------------------------------------------------------------------------
-- This function will set and acquire the user lock
--
-- Input parameters
-- Parameter           Type       Required  Description
-- p_assignment_id      NUMBER      Yes      Assignment Id used for locking the corresponding record
-- p_lock_commitmode    BOOLEAN     Yes      Parameter to set the condition for releasing the lock
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock
--------------------------------------------------------------------------------------------------------------


FUNCTION Set_User_Lock ( p_source_id         IN  NUMBER,
                         p_lock_for          IN  VARCHAR2)

RETURN NUMBER
IS
     lock_status   	NUMBER;
     lock_name     	VARCHAR2(50);
     lockhndl      	VARCHAR2(128);
     lock_mode     	NUMBER:=6;
     lock_commitmode 	BOOLEAN:=TRUE;
BEGIN

    lock_name   := 'FI-' || p_lock_for || '-' || p_source_id;
    IF ( p_source_id IS NULL ) THEN
      Return -99;
    END IF;

      /* Get lock handle for user lock */
        pa_forecast_items_utils.allocate_unique(
            p_lock_name   =>lock_name,
				    p_lock_handle =>lockhndl);

        IF ( lockhndl IS NOT NULL ) then
          /* Request the lock */
          lock_status := dbms_lock.request( lockhandle        => lockhndl,
                                            lockmode          => lock_mode,
                                            release_on_commit => lock_CommitMode);

          IF ( lock_status = 0 ) then  -- Got the lock
                Return 0;
          ELSE
                Return (-1*lock_status);
                -- Return the status obtained on request
          END IF;
        ELSE
          Return -99;  -- Failed to allocate lock
        END IF;
  RETURN(lock_status);

END  Set_User_Lock;


-------------------------------------------------------
-- This procedure will release user lock
--
-- Input parameters
-- Parameter           Type       Required            Description
-- p_assignment_id     NUMBER      Yes                Assignment id which was used to lock the transaction
--
-- Return Values
--  0         Success
-- Other      Unable to acquire lock
---------------------------------------------------------
FUNCTION Release_User_Lock
	   (p_source_id   IN  NUMBER,
      p_lock_for    IN  VARCHAR2)
 RETURN NUMBER
 IS
     lock_status   number;
     lock_name     VARCHAR2(50);
     lockhndl      	VARCHAR2(128);
BEGIN
  lock_name   := 'FI-' || p_lock_for || '-' || p_source_id;
    IF ( p_source_id IS NULL ) THEN
      Return -99;
    END IF;

      /* Get lock handle for user lock */
        pa_forecast_items_utils.allocate_unique(
           p_lock_name   =>lock_name,
				   p_lock_handle =>lockhndl);

   IF ( lockhndl IS NOT NULL ) then
      lock_status := dbms_lock.release(lockhandle =>lockhndl);

          IF ( lock_status = 0 ) then  -- Got the lock
                Return 0;
          ELSE
                Return (-1*lock_status);
                -- Return the status obtained on request
          END IF;
        ELSE
          Return -99;  -- Failed to allocate lock
        END IF;
  RETURN(lock_status);

END Release_User_Lock;


--------------------------------------------------------------------------------------------------------------
-- This procedure prints the text which is being passed as the input
-- Input parameters
-- Parameters                   Type           Required  Description
--  p_log_msg                   VARCHAR2        YES      It stores text which you want to print on screen
-- Out parameters
----------------------------------------------------------------------------------------------------------------
PROCEDURE log_message (p_log_msg IN VARCHAR2)
IS
BEGIN
	-- dbms_output.put_line('log: ' || p_log_msg);
        NULL;
END log_message;


---------------------------------------------------------------------------------------------------------------------
-- This procedure gets the schedule related to the resource assignment
-- Input parameters
-- Parameters                   Type           Required  Description
-- p_resource_id                NUMBER          YES      Resource id
-- p_start_date                 DATE            YES      Start date for the resource
-- p_end_date                   DATE            YES      End date for the resource
-- Out parameters
-- x_ScheduleTab                ScheduleTabTyp  YES       It stores the resource schedule for the given data range
---------------------------------------------------------------------------------------------------------------------
PROCEDURE Get_Resource_Asgn_Schedules (
                                        p_resource_id           IN      NUMBER,
                                        p_start_date            IN      DATE,
                                        p_end_date              IN      DATE,
                                        x_ScheduleTab           OUT     NOCOPY PA_FORECAST_GLOB.ScheduleTabTyp, /* 2674619 - Nocopy change */
                                        x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        x_msg_data              OUT     NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS

CURSOR cur_res_asgn   IS SELECT sch.schedule_id                   schedule_id,
                                sch.monday_hours                  monday_hours,
                                sch.tuesday_hours                 tuesday_hours,
                                sch.wednesday_hours               wednesday_hours,
                                sch.thursday_hours                thursday_hours,
                                sch.friday_hours                  friday_hours,
                                sch.saturday_hours                saturday_hours,
                                sch.sunday_hours                  sunday_hours,
                                sch.status_code   	          status_code,
                                sch.start_date                    start_date,
                                sch.end_date                      end_date,
				sch.forecast_txn_version_number   forecast_txn_version_number,
				sch.forecast_txn_generated_flag   forecast_txn_generated_flag,
                                pst.project_system_status_code    system_status_code
                                FROM pa_schedules sch,
                                     pa_project_assignments prasgn,
                                     pa_project_statuses pst
                                WHERE ( ( p_start_date BETWEEN sch.start_date AND sch.end_date)
                          	   OR ( p_end_date   BETWEEN sch.start_date AND sch.end_date)
                          	   OR ( p_start_date < sch.start_date AND p_end_date > sch.end_date) )
                                   AND  sch.assignment_id = prasgn.assignment_id
                                   AND  prasgn.resource_id = p_resource_id
                                   AND  sch.status_code = pst.project_status_code
                                   AND  pst.project_system_status_code <> 'STAFFED_ASGMT_CANCEL'
                                   AND  PST.STATUS_TYPE = 'STAFFED_ASGMT'   --Bug 7301626
                                   ORDER  BY sch.start_date;

        cur_res_asgn_rec        cur_res_asgn%ROWTYPE;
        li_cnt                  NUMBER:=0;
BEGIN
             PA_DEBUG.Init_err_stack(
                       'PA_FORECAST_ITEMS_UTILS.Get_Resource_Asgn_Schedules');

	BEGIN
        li_cnt :=1;

                OPEN cur_res_asgn;
                LOOP

                        FETCH cur_res_asgn INTO cur_res_asgn_rec;
                        EXIT WHEN cur_res_asgn%NOTFOUND;

                        x_ScheduleTab(li_cnt).schedule_id                := cur_res_asgn_rec.schedule_id;
                        x_ScheduleTab(li_cnt).status_code                := cur_res_asgn_rec.status_code;
                        x_ScheduleTab(li_cnt).start_date                 := cur_res_asgn_rec.start_date;
                        x_ScheduleTab(li_cnt).end_date                   := cur_res_asgn_rec.end_date;
                        x_ScheduleTab(li_cnt).monday_hours               := cur_res_asgn_rec.monday_hours;
                        x_ScheduleTab(li_cnt).tuesday_hours              := cur_res_asgn_rec.tuesday_hours;
                        x_ScheduleTab(li_cnt).wednesday_hours            := cur_res_asgn_rec.wednesday_hours;
                        x_ScheduleTab(li_cnt).thursday_hours             := cur_res_asgn_rec.thursday_hours;
                        x_ScheduleTab(li_cnt).friday_hours               := cur_res_asgn_rec.friday_hours;
                        x_ScheduleTab(li_cnt).saturday_hours             := cur_res_asgn_rec.saturday_hours;
                        x_ScheduleTab(li_cnt).sunday_hours               := cur_res_asgn_rec.sunday_hours;
                        x_ScheduleTab(li_cnt).forecast_txn_version_number := cur_res_asgn_rec.forecast_txn_version_number;
                        x_ScheduleTab(li_cnt).forecast_txn_generated_flag := cur_res_asgn_rec.forecast_txn_generated_flag;
                        x_ScheduleTab(li_cnt).system_status_code := cur_res_asgn_rec.system_status_code;
                        li_cnt := li_cnt +1;


                END LOOP;

                CLOSE cur_res_asgn;

                PA_DEBUG.Reset_Err_Stack;

                x_return_status := FND_API.G_RET_STS_SUCCESS;
        EXCEPTION
        WHEN OTHERS THEN
                x_msg_count     := 1;
                x_msg_data      := sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                         'PA_FORECAST_ITEMS_UTILS.Get_Resource_Asgn_Schedules',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
                raise;

	END;


END Get_Resource_Asgn_Schedules;


-------------------------------------------------------------------------------------------------------------
-- This procedure will get all the schedule for the given assignment id
-- and having process mode as 'GENERATE'
-- Input parameters
-- Parameters                   Type           Required  Description
-- p_assignment_id              NUMBER         YES       Assignment id for which schedule record is to be needed
-- p_start_date                 DATE           YES       Start date from which the schedule is to be needed
-- p_end_date                   DATE           YES       End date from which the schedule is to be needed
-- p_process_mode               VARCHAR2       YES       Process mode i.e. wheather the assignment is to be
--                                                       Generated or not
-- Out parameters
-- X_ScheduleTab                ScheduleTabTyp YES       It stores the schedules record
--------------------------------------------------------------------------------------------------------------
PROCEDURE Get_Assignment_Schedule(p_assignment_id       IN      NUMBER,
                                  p_start_date          IN      DATE ,
                                  p_end_date            IN      DATE,
                                  p_process_mode        IN      VARCHAR2,
                                  X_ScheduleTab         OUT     NOCOPY PA_FORECAST_GLOB.ScheduleTabTyp, /* 2674619 - Nocopy change */
                                  x_return_status       OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count           OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data            OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

CURSOR cur_asgn_sch   IS SELECT sch.schedule_id                 schedule_id,
                                sch.monday_hours        	monday_hours,
                                sch.tuesday_hours       	tuesday_hours,
                                sch.wednesday_hours 	    	wednesday_hours,
                                sch.thursday_hours    	  	thursday_hours,
                                sch.friday_hours        	friday_hours,
                                sch.saturday_hours      	saturday_hours,
                                sch.sunday_hours        	sunday_hours,
                                sch.status_code			status_code,
                                sch.start_date       		start_date,
                                sch.end_date         		end_date,
				sch.forecast_txn_version_number	forecast_txn_version_number,
				sch.forecast_txn_generated_flag	forecast_txn_generated_flag,
                                pst.project_system_status_code    system_status_code
                       FROM 	pa_schedules sch, pa_project_statuses pst
                       WHERE    p_start_date IS NOT NULL
                       AND sch.status_code = pst.project_status_code
			 AND    p_end_date IS NOT NULL
			 AND  	sch.assignment_id=p_assignment_id
			 /**  commented out as the  FIs were not generated between the schedules
			  *   when two or more wf - process launched concurrently
			 --AND    sch.forecast_txn_generated_flag=
                         --       DECODE(p_process_mode,'GENERATE','N',sch.forecast_txn_generated_flag)
			 **/
               		 AND    ( ( p_start_date BETWEEN sch.start_date AND sch.end_date)
               		  OR       ( p_end_date   BETWEEN sch.start_date AND sch.end_date)
               		  OR       ( p_start_date < sch.start_date AND p_end_date > sch.end_date) )
			UNION
			SELECT  sch.schedule_id                 schedule_id,
                                sch.monday_hours                monday_hours,
                                sch.tuesday_hours               tuesday_hours,
                                sch.wednesday_hours             wednesday_hours,
                                sch.thursday_hours              thursday_hours,
                                sch.friday_hours                friday_hours,
                                sch.saturday_hours              saturday_hours,
                                sch.sunday_hours                sunday_hours,
                                sch.status_code                 status_code,
                                sch.start_date                  start_date,
                                sch.end_date                    end_date,
                                sch.forecast_txn_version_number       forecast_txn_version_number,
                                sch.forecast_txn_generated_flag forecast_txn_generated_flag,
                                pst.project_system_status_code    system_status_code
                       FROM   pa_schedules sch, pa_project_statuses pst
                       WHERE  p_start_date IS NULL
                         AND  p_end_date IS NULL
                         AND  sch.assignment_id=p_assignment_id
                         AND  sch.status_code = pst.project_status_code
                         /**  commented out as the  FIs were not generated between the schedules
                          *   when two or more wf - process launched concurrently
			 --AND    sch.forecast_txn_generated_flag=
                         --       DECODE(p_process_mode,'GENERATE','N',sch.forecast_txn_generated_flag)
			 **/
                      ORDER  BY start_date;

        cur_asgn_sch_rec       cur_asgn_sch%ROWTYPE;
        li_cnt                  NUMBER:=0;
BEGIN
       PA_DEBUG.Init_err_stack(
                'PA_FORECAST_ITEMS_UTILS.Get_Resource_Asgn_Schedules');
    BEGIN

        li_cnt :=1;


                OPEN cur_asgn_sch;
                LOOP

                        FETCH cur_asgn_sch INTO cur_asgn_sch_rec;
                        EXIT WHEN cur_asgn_sch%NOTFOUND;

                        x_ScheduleTab(li_cnt).schedule_id  		  := cur_asgn_sch_rec.schedule_id;
                        x_ScheduleTab(li_cnt).status_code  		  := cur_asgn_sch_rec.status_code;
                        x_ScheduleTab(li_cnt).start_date      		  := cur_asgn_sch_rec.start_date;
                        x_ScheduleTab(li_cnt).end_date        		  := cur_asgn_sch_rec.end_date;
                        x_ScheduleTab(li_cnt).monday_hours    		  := cur_asgn_sch_rec.monday_hours;
                        x_ScheduleTab(li_cnt).tuesday_hours   		  := cur_asgn_sch_rec.tuesday_hours;
                        x_ScheduleTab(li_cnt).wednesday_hours 		  := cur_asgn_sch_rec.wednesday_hours;
                        x_ScheduleTab(li_cnt).thursday_hours  		  := cur_asgn_sch_rec.thursday_hours;
                        x_ScheduleTab(li_cnt).friday_hours    		  := cur_asgn_sch_rec.friday_hours;
                        x_ScheduleTab(li_cnt).saturday_hours  		  := cur_asgn_sch_rec.saturday_hours;
                        x_ScheduleTab(li_cnt).sunday_hours    		  := cur_asgn_sch_rec.sunday_hours;
                        x_ScheduleTab(li_cnt).forecast_txn_version_number       := cur_asgn_sch_rec.forecast_txn_version_number;
                        x_ScheduleTab(li_cnt).forecast_txn_generated_flag := cur_asgn_sch_rec.forecast_txn_generated_flag;
                        x_ScheduleTab(li_cnt).system_status_code := cur_asgn_sch_rec.system_status_code;

                        li_cnt := li_cnt +1;


                END LOOP;

                CLOSE cur_asgn_sch;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
        PA_DEBUG.Reset_Err_Stack;
        EXCEPTION
        WHEN OTHERS THEN
                x_msg_count     := 1;
                x_msg_data      := sqlerrm;
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
                FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                         'PA_FORECAST_ITEMS_UTILS.Get_Assignment_Schedule',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
                raise;
	END;

END Get_Assignment_Schedule;



-------------------------------------------------------------------------------
--  Function 		Get_Period_Set_Name
--  Purpose		To get the Period name for OU
--  Input parameters
--  Parameters                   Type           Required  Description
--  p_org_id                     NUMBER         YES       Operating Unit id
--                                                        Generated or not
-- Out parameters
---------------------------------------------------------------------------------

FUNCTION Get_Period_Set_Name(p_org_id NUMBER) RETURN VARCHAR2 IS
	lv_period_set_name VARCHAR2(15);
BEGIN
  PA_FORECASTITEM_PVT.print_message('Inside Get_Period_Set_Name');


  -- 2196924: Adding case when p_org_id = -88
  -- This may occur when there's no HR assignment for
  -- part of the resources time, so no ou for which
  -- to select work type id.

  if (p_org_id = -88) then
    return '-99';
  else
     BEGIN

/* Commented for bug 3434019. Period_set_name will be fetched from pa_implementations_all based on OU.
	SELECT 	gl.period_set_name
  	  INTO 	lv_period_set_name
          FROM	gl_sets_of_books gl,
       		pa_implementations_all imp
 	 WHERE imp.set_of_books_id=gl.set_of_books_id
   	   AND nvl(imp.org_id,-99) = nvl(p_org_id,-99);
*/
--R12: MOAC Changes: Bug 4363092: Removed nvl usage with org_id
        SELECT 	imp.period_set_name
  	  INTO 	lv_period_set_name
          FROM	pa_implementations_all imp
 	 WHERE imp.org_id = p_org_id;

	 EXCEPTION
		WHEN NO_DATA_FOUND THEN
			lv_period_set_name := 'NO_DATA_FOUND';
                        NULL;
      PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND');
		WHEN OTHERS THEN
			lv_period_set_name := 'ERROR';
                        NULL;
      PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND');
	END;
  END IF;

RETURN (lv_period_set_name);

END Get_Period_Set_Name;



----------------------------------------------------------------------------------------------------
--  Procedure 		Get_Work_Type_Details
--  Purpose		To get detail for the passed work type
--  Input parameters
--  Parameters                   Type           Required  Description
--  p_work_type_id               NUMBER         YES       Work type id
-- Out parameters
--  x_BillableFlag               VARCHAR2       YES       Billable flag
--  x_ResUtilPercentage          NUMBER         YES       resource util percentage
--  x_OrgUtilPercentage          NUMBER         YES       Org util percentage
--  x_ResUtilCategoryID          NUMBER         YES       resource util category id
--  x_OrgUtilCategoryID          NUMBER         YES       Org uti category id
--  x_ReduceCapacityFlag       VARCHAR2       YES       Reduced capacity Flag
---------------------------------------------------------------------------------------------------------
PROCEDURE Get_Work_Type_Details(p_work_type_id          IN       NUMBER,
                                x_BillableFlag          OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_ResUtilPercentage     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_OrgUtilPercentage     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_ResUtilCategoryID     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_OrgUtilCategoryID     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_ReduceCapacityFlag    OUT      NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

	 l_msg_index_out NUMBER;
BEGIN


              -- 2196924: Adding case when p_work_type_id is null
              -- This may occur when there's no HR assignment for
              -- part of the resources time, so no ou for which
              -- to select work type id.
              if (p_work_type_id is null) then
                  x_ResUtilPercentage := null;
                  x_OrgUtilPercentage := null;
                  x_ResUtilCategoryID := null;
                  x_OrgUtilCategoryID := null;
                  x_ReduceCapacityFlag := null;
              else


        SELECT wk.billable_capitalizable_flag,
		wk.res_utilization_percentage,
		wk.org_utilization_percentage,
		wk.res_util_category_id,
		wk.org_util_category_id,
                wk.reduce_capacity_flag
          INTO  x_BillableFlag,
		x_ResUtilPercentage,
		x_OrgUtilPercentage,
		x_ResUtilCategoryID,
		x_OrgUtilCategoryID,
                x_ReduceCapacityFlag
          FROM  pa_work_types_b wk
         WHERE wk.work_type_id=p_work_type_id;
   end if;
EXCEPTION


       WHEN OTHERS THEN
           x_BillableFlag        := 'N';
	   x_ResUtilPercentage   := 0;
	   x_OrgUtilPercentage   := 0;
	   x_ResUtilCategoryID   := 0;
	   x_OrgUtilCategoryID   := 0;
           x_ReduceCapacityFlag   := 'N';
           NULL;


END Get_Work_Type_Details;



---------------------------------------------------------------------------------------------------------
--  Procedure 		Get_PA_Period_Name
--  Purpose		To get the PA Period name for OU
--  Input parameters
--  Parameters                   Type           Required  Description
--  p_org_id                     NUMBER         YES       Org id
--  p_start_date                 DATE           YES       Start date
--  p_end_date                   DATE           YES       End date
-- Out parameters
--  x_StartDateTab               DateTabTyp       YES     Used to store start date in bulk
--  x_EndDateTab                 DateTabTyp       YES     Used to store end date in bulk
--  x_PAPeriodNameTab            PeriodNameTabTyp YES     Used to store period name
---------------------------------------------------------------------------------------------------------------
PROCEDURE Get_PA_Period_Name(p_org_id           IN NUMBER,
                             p_start_date       IN DATE,
                             p_end_date         IN DATE,
                             x_StartDateTab     OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                             x_EndDateTab       OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                             x_PAPeriodNameTab  OUT NOCOPY PA_FORECAST_GLOB.PeriodNameTabTyp) /* 2674619 - Nocopy change */
IS

  BEGIN

  PA_FORECASTITEM_PVT.print_message('Inside Get_PA_Period_Name');

  -- 2196924: Adding case when p_org_id = -88
  -- This may occur when there's no HR assignment for
  -- part of the resources time, so no ou for which
  -- to select work type id.
  if (p_org_id = -88) then
    x_StartDateTab(1) := p_start_date;
    x_EndDateTab(1) := p_end_date;
    x_PAPeriodNameTab(1) := '-99';
  else

	IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN

	   BEGIN

/* Commented for bug 3434019. Pa_periods_all is used to fetch data.
	       SELECT glper.start_date,
	   	      glper.end_date,
		      glper.period_name
	       BULK COLLECT INTO x_StartDateTab,x_EndDateTab,x_PAPeriodNameTab
               FROM  pa_implementations_all imp,
	     	     gl_sets_of_books gl,
	             gl_periods glper,
                     gl_date_period_map glmaps
               WHERE  nvl(imp.org_id,-99) = nvl(p_org_id,-99)
               AND  imp.set_of_books_id = gl.set_of_books_id
               AND  gl.period_set_name  = glper.period_set_name
               AND  imp.pa_period_type  = glper.period_type
               AND  glmaps.period_type  = glper.period_type
               AND  glmaps.period_name  = glper.period_name
               AND  glmaps.period_set_name  = glper.period_set_name
               AND ( (p_start_date BETWEEN glper.start_date AND glper.end_date)
                    OR (p_end_date BETWEEN glper.start_date AND glper.end_date)
                    OR ( p_start_date < glper.start_date AND
                         p_end_date  > glper.end_date ))
               order by glper.start_date;
*/
--R12: MOAC Changes: Bug 4363092: Removed nvl usage with org_id
              SELECT pp.start_date,
	             pp.end_date,
		     pp.period_name
	      BULK COLLECT
	      INTO x_StartDateTab,x_EndDateTab,x_PAPeriodNameTab
	      FROM pa_periods_all pp
	      WHERE pp.org_id = p_org_id
               --Bug 4276273 - trunc added
               AND  ( (trunc(p_start_date) BETWEEN pp.start_date AND
                                                   pp.end_date)
                    OR (trunc(p_end_date) BETWEEN pp.start_date AND pp.end_date)
                    OR ( trunc(p_start_date) < pp.start_date AND
                         trunc(p_end_date)  > pp.end_date ))
	     order by pp.start_date;


 	   END;

	ELSIF p_start_date IS NOT NULL THEN


		BEGIN

/* Commented for bug 3434019. Instead pa_periods_all is used to fetch data.
		   SELECT glper.start_date,
                          glper.end_date,
                          glper.period_name
                   BULK COLLECT
		   INTO x_StartDateTab,x_EndDateTab,x_PAPeriodNameTab
                   FROM pa_implementations_all imp,
                        gl_sets_of_books gl,
                        gl_periods glper,
                        gl_date_period_map glmaps
                   WHERE  nvl(imp.org_id,-99) = nvl(p_org_id,-99)
                   AND  imp.set_of_books_id     = gl.set_of_books_id
                   AND  gl.period_set_name      = glper.period_set_name
                   AND  imp.pa_period_type      = glper.period_type
                   AND  glmaps.period_type      = glper.period_type
                   AND  glmaps.period_name      = glper.period_name
                   AND  glmaps.period_set_name  = glper.period_set_name
                   AND  p_start_date BETWEEN glper.start_date AND glper.end_date
                   order by glper.end_date;
*/
--R12: MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                 SELECT pp.start_date,
		        pp.end_date,
			pp.period_name
	         BULK COLLECT
		 INTO x_StartDateTab,x_EndDateTab,x_PAPeriodNameTab
		 FROM pa_periods_all pp
 	         WHERE pp.org_id = p_org_id
                 --Bug 4276273 - trunc added
                 AND   trunc(p_start_date) BETWEEN pp.start_date and pp.end_date
		 order by pp.end_date;

		END;

	END IF;
  end if;

  if (NVL(x_StartDateTab.count,0) = 0) then
    PA_FORECASTITEM_PVT.print_message('No periods found.');
  else
    PA_FORECASTITEM_PVT.print_message('x_StartDateTab(first): ' || x_StartDateTab(x_StartDateTab.first));
    PA_FORECASTITEM_PVT.print_message('x_EndDateTab(first): ' || x_EndDateTab(x_EndDateTab.first));
    PA_FORECASTITEM_PVT.print_message('x_PAPeriodNameTab(first): ' || x_PAPeriodNameTab(x_PAPeriodNameTab.first));
    PA_FORECASTITEM_PVT.print_message('x_StartDateTab(last): ' || x_StartDateTab(x_StartDateTab.last));
    PA_FORECASTITEM_PVT.print_message('x_EndDateTab(last): ' || x_EndDateTab(x_EndDateTab.last));
    PA_FORECASTITEM_PVT.print_message('x_PAPeriodNameTab(last): ' || x_PAPeriodNameTab(x_PAPeriodNameTab.last));

   end if;

	 EXCEPTION
		WHEN NO_DATA_FOUND THEN
      PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND');
			NULL;
		WHEN OTHERS THEN -- 4537865 : Included this block
			x_StartDateTab.delete;
			x_EndDateTab.delete;
			x_PAPeriodNameTab.delete ;
			FND_MSG_PUB.add_exc_msg
			( p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS'
			, p_procedure_name => 'Get_PA_Period_Name'
			, p_error_text	=> SUBSTRB(SQLERRM,1,240));
			RAISE ;
END Get_PA_Period_Name;



-----------------------------------------------------------------------------------------------------------
--  Procedure 		Get_GL_Period_Name
--  Purpose		To get the GL Period name for OU
--  Input parameters
--  Parameters                   Type           Required  Description
--  p_org_id                     NUMBER         YES       Org id
--  p_start_date                 DATE           YES       Start date
--  p_end_date                   DATE           YES       End date
-- Out parameters
--  x_StartDateTab               DateTabTyp       YES     Used to store start date in bulk
--  x_EndDateTab                 DateTabTyp       YES     Used to store end date in bulk
--  x_PAPeriodNameTab            PeriodNameTabTyp YES     Used to store period name
------------------------------------------------------------------------------------------------------------
PROCEDURE Get_GL_Period_Name(p_org_id           IN NUMBER,
                             p_start_date       IN DATE,
                             p_end_date         IN DATE,
                             x_StartDateTab     OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                             x_EndDateTab       OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                             x_PAPeriodNameTab  OUT NOCOPY PA_FORECAST_GLOB.PeriodNameTabTyp) /* 2674619 - Nocopy change */
IS

BEGIN
  PA_FORECASTITEM_PVT.print_message('Inside Get_GL_Period_Name');

  -- 2196924: Adding case when p_org_id = -88
  -- This may occur when there's no HR assignment for
  -- part of the resources time, so no ou for which
  -- to select work type id.
  if (p_org_id = -88) then
    x_StartDateTab(1) := p_start_date;
    x_EndDateTab(1) := p_end_date;
    x_PAPeriodNameTab(1) := '-99';
  else

	IF p_start_date IS NOT NULL AND p_end_date IS NOT NULL THEN

	   BEGIN
--R12: MOAC Changes: Bug 4363092: Removed nvl usage with org_id
               SELECT glper.start_date,
	  	      glper.end_date,
		      glper.period_name
	       BULK COLLECT
               INTO   x_StartDateTab,x_EndDateTab,x_PAPeriodNameTab
               FROM   pa_implementations_all imp,
                     gl_sets_of_books gl,
                     gl_periods glper,
                     gl_date_period_map glmaps
               WHERE  imp.org_id = p_org_id
               AND  imp.set_of_books_id = gl.set_of_books_id
               AND  gl.period_set_name  = glper.period_set_name
               AND  gl.accounted_period_type  = glper.period_type
               AND  glmaps.period_type        = glper.period_type
               AND  glmaps.period_name        = glper.period_name
			   --AND glmaps.accounting_date in (p_start_date,p_end_date)  -- bug#9325153, commented by bug9558375
               AND  glmaps.period_set_name    = glper.period_set_name
               --Bug 4276273 - trunc added
               AND ( (trunc(p_start_date) BETWEEN glper.start_date AND
                                                  glper.end_date)
                    OR (trunc(p_end_date) BETWEEN glper.start_date AND
                                                  glper.end_date)
                    OR ( trunc(p_start_date) < glper.start_date AND
                         trunc(p_end_date)  > glper.end_date ))
               order by glper.start_date;


		END;

	ELSIF p_start_date IS NOT NULL THEN

                BEGIN
--R12: MOAC Changes: Bug 4363092: Removed nvl usage with org_id
                   SELECT  glper.start_date,
                           glper.end_date,
                           glper.period_name
                   BULK COLLECT
                   INTO x_StartDateTab,x_EndDateTab,x_PAPeriodNameTab
                   FROM  pa_implementations_all imp,
                         gl_sets_of_books gl,
                         gl_periods glper,
                         gl_date_period_map glmaps
                   WHERE  imp.org_id = p_org_id
                   AND  imp.set_of_books_id = gl.set_of_books_id
                   AND  gl.period_set_name  = glper.period_set_name
                   AND  gl.accounted_period_type  = glper.period_type
                   AND  glmaps.period_type        = glper.period_type
                   AND  glmaps.period_name        = glper.period_name
                   AND  glmaps.period_set_name    = glper.period_set_name
                   --Bug 4276273 - trunc added
                   AND  trunc(p_start_date) BETWEEN glper.start_date AND
                                                    glper.end_date
                   order by glper.start_date;

                END;
	END IF;
  END IF;
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
      PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND');
			NULL;
        WHEN OTHERS THEN -- 4537865 : Included this block
                        x_StartDateTab.delete;
                        x_EndDateTab.delete;
                        x_PAPeriodNameTab.delete ;
                        FND_MSG_PUB.add_exc_msg
                        ( p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS'
                        , p_procedure_name => 'Get_GL_Period_Name'
                        , p_error_text  => SUBSTRB(SQLERRM,1,240));
                        RAISE ;
END Get_GL_Period_Name;



--------------------------------------------------------------------------------------------------------
--  Procedure 		Get_Resource_OU
--  Purpose		To get the Resource OU for a Period
--  Input parameters
--  Parameters                   Type           Required  Description
--  p_resource_id                NUMBER         YES       Resource id
--  p_start_date                 DATE           YES       Start date
--  p_end_date                   DATE           YES       End date
-- Out parameters
--  x_StartDateTab               DateTabTyp     YES       Used to store start date in bulk
--  x_EndDateTab                 DateTabTyp     YES       Used to store end date in bulk
--  x_ResourceOUTab              NumberTabTyp   YES       Used to store resource id
----------------------------------------------------------------------------------------------------------
PROCEDURE Get_Resource_OU(p_resource_id      IN NUMBER,
                          p_start_date       IN DATE,
                          p_end_date         IN DATE,
                          x_StartDateTab     OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                          x_EndDateTab       OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                          x_ResourceOUTab    OUT NOCOPY PA_FORECAST_GLOB.NumberTabTyp) /* 2674619 - Nocopy change */
IS

 ld_start_date DATE;
 ld_end_date DATE;
 li_count NUMBER;
 li_first_index NUMBER;
 li_last_index NUMBER;
 li_new_first_index NUMBER;
 li_new_last_index NUMBER;
 ld_first_start_date DATE;
 li_first_ou NUMBER;
 ld_last_end_date DATE;
 li_last_ou NUMBER;

 g_TimelineProfileSetup  PA_TIMELINE_GLOB.TimelineProfileSetup;
 AVAILABILITY_DURATION   NUMBER;

 l_new_StartDateTab PA_FORECAST_GLOB.DateTabTyp;
 l_new_EndDateTab PA_FORECAST_GLOB.DateTabTyp;
 l_new_ResourceOUTab PA_FORECAST_GLOB.NumberTabTyp;
 li_new_index NUMBER;
 ld_prev_end_date DATE;
	 l_msg_index_out NUMBER;

BEGIN
  PA_FORECASTITEM_PVT.print_message('Inside Get_Resource_OU');
  g_TimelineProfileSetup  := PA_TIMELINE_UTIL.get_timeline_profile_setup;
  availability_duration   := g_TimelineProfileSetup.availability_duration;

  ld_start_date := NVL(p_start_date, ADD_MONTHS(sysdate, -12));
  ld_end_date := NVL(p_end_date, ADD_MONTHS(sysdate, availability_duration * (12)));

  PA_FORECASTITEM_PVT.print_message('p_resource_id: ' || p_resource_id);
  PA_FORECASTITEM_PVT.print_message('p_start_date: ' || p_start_date);
  PA_FORECASTITEM_PVT.print_message('p_end_date: ' || p_end_date);
  PA_FORECASTITEM_PVT.print_message('ld_start_date: ' || ld_start_date);
  PA_FORECASTITEM_PVT.print_message('ld_end_date: ' || ld_end_date);

  -- 2196924: Added logic so it wouldn't raise NO_DATA_FOUND
  BEGIN
 --Bug 4207110 :Added equalto condition while performing date check

		SELECT nvl(rou.resource_org_id,-99),
			rou.resource_effective_start_date,
			NVL(rou.resource_effective_end_date,SYSDATE)
		BULK COLLECT INTO
			x_ResourceOUTab,x_StartDateTab,x_EndDateTab
		FROM pa_resources_denorm rou
		WHERE rou.resource_id= p_resource_id
    AND ld_start_date <=  NVL(rou.resource_effective_end_date,SYSDATE)
    AND ld_end_date >= rou.resource_effective_start_date
    ORDER BY rou.resource_effective_start_date;

--Bug 4207110 END

    PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND ok, exception not raised');
	EXCEPTION
	WHEN NO_DATA_FOUND THEN
    PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND ok, exception not raised');
  END;


  -- 2196924: Added logic so that all dates have a record in out table.

  li_count := NVL(x_ResourceOUTab.count,0);
  if (li_count = 0) then
    x_ResourceOUTab(1) := -88;
    x_StartDateTab(1) := ld_start_date;
    x_EndDateTab(1) := ld_end_date;
    li_count := 1;
  end if;

  li_first_index := x_ResourceOUTab.first;
  li_new_first_index := li_first_index - 1;
  li_last_index := x_ResourceOUTab.last;
  li_new_last_index := li_last_index + 1;
  ld_first_start_date := x_StartDateTab(li_first_index);
  li_first_ou := x_ResourceOUTab(li_first_index);
  ld_last_end_date := x_EndDateTab(li_last_index);
  li_last_ou := x_ResourceOUTab(li_last_index);

  PA_FORECASTITEM_PVT.print_message('li_first_index: ' || li_first_index);
  PA_FORECASTITEM_PVT.print_message('li_new_first_index: ' || li_new_first_index);
  PA_FORECASTITEM_PVT.print_message('li_last_index: ' || li_last_index);
  PA_FORECASTITEM_PVT.print_message('li_new_last_index: ' || li_new_last_index);
  PA_FORECASTITEM_PVT.print_message('ld_first_start_date: ' || ld_first_start_date);
  PA_FORECASTITEM_PVT.print_message('ld_last_end_date: ' || ld_last_end_date);
  PA_FORECASTITEM_PVT.print_message('li_first_ou: ' || li_first_ou);
  PA_FORECASTITEM_PVT.print_message('li_last_ou: ' || li_last_ou);

  if (ld_first_start_date > ld_start_date) then
     -- Insert a record into table
     PA_FORECASTITEM_PVT.print_message('ld_first_start_date > ld_start_date');
     x_ResourceOUTab(li_new_first_index) := -88;
     x_StartDateTab(li_new_first_index) := ld_start_date;
     x_EndDateTab(li_new_first_index) := ld_first_start_date - 1;
  end if;

  if (ld_last_end_date < ld_end_date) then
     -- Insert a record into table
     PA_FORECASTITEM_PVT.print_message('ld_last_end_date < ld_end_date');
     x_ResourceOUTab(li_new_last_index) := -88;
     x_StartDateTab(li_new_last_index) := ld_last_end_date + 1;
     x_EndDateTab(li_new_last_index) := ld_end_date;
  end if;

  -- Fix holes (x_StartDateTab is definitely not empty here,
  -- so no need to check)
  li_new_index := 1;
  ld_prev_end_date := ld_start_date-1;
  for i IN x_StartDateTab.first .. x_StartDateTab.last LOOP
     if (x_StartDateTab(i) > ld_prev_end_date+1) then
        -- Insert record for hole.
        l_new_StartDateTab(li_new_index) := ld_prev_end_date + 1;
        l_new_EndDateTab(li_new_index) := x_StartDateTab(i)-1;
        l_new_ResourceOUTab(li_new_index) := -88;
        li_new_index := li_new_index + 1;
     end if;
     l_new_StartDateTab(li_new_index) := x_StartDateTab(i);
     l_new_EndDateTab(li_new_index) := x_EndDateTab(i);
     l_new_ResourceOUTab(li_new_index) := x_ResourceOUTab(i);

     li_new_index := li_new_index + 1;
     ld_prev_end_date := x_EndDateTab(i);
  end loop;

  x_ResourceOUTab := l_new_ResourceOUTab;
  x_StartDateTab := l_new_StartDateTab;
  x_EndDateTab := l_new_EndDateTab;
-- 4537865 : EXCEPTION BLOCK INCLUDED
EXCEPTION
WHEN NO_DATA_FOUND THEN
    PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND ok, exception not raised');
    NULL ;
WHEN OTHERS THEN
	x_ResourceOUTab.delete;
	x_StartDateTab.delete;
	x_EndDateTab.delete;
        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS'
        , p_procedure_name => 'Get_Resource_OU'
        , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
END Get_Resource_OU;



----------------------------------------------------------------------------------------------------------
--  Procedure 		Get_Res_Org_And_Job
--  Purpose		To get the Resource Organization for Period
--  Input parameters
--  Parameters                   Type           Required  Description
--  p_person_id                  NUMBER         YES       Persion id
--  p_start_date                 DATE           YES       Start date
--  p_end_date                   DATE           YES       End date
-- Out parameters
--  x_StartDateTab               DateTabTyp     YES       Used to store start date in bulk
--  x_EndDateTab                 DateTabTyp     YES       Used to store end date in bulk
--  x_ResourceOrganizationIDTab  NumberTabTyp   YES       Used to store organization id
--  x_ResourceJobIDTab           NumberTabTyp   YES       Used to store resource job id
---------------------------------------------------------------------------------------------------------------
PROCEDURE Get_Res_Org_And_Job(p_person_id                 IN NUMBER,
                                    p_start_date                IN DATE,
                                    p_end_date                  IN DATE,
                                    x_StartDateTab              OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp, /* 2674619 - Nocopy change */
                                    x_EndDateTab                OUT NOCOPY PA_FORECAST_GLOB.DateTabTyp,/* 2674619 - Nocopy change */
                                    x_ResourceOrganizationIDTab OUT NOCOPY PA_FORECAST_GLOB.NumberTabTyp, /* 2674619 - Nocopy change */
                                    x_ResourceJobIDTab          OUT NOCOPY PA_FORECAST_GLOB.NumberTabTyp) /* 2674619 - Nocopy change */
IS

  l_new_ResOrganizationIDTab PA_FORECAST_GLOB.NumberTabTyp;
	l_new_StartDateTab PA_FORECAST_GLOB.DateTabTyp;
	l_new_EndDateTab PA_FORECAST_GLOB.DateTabTyp;
	l_new_ResourceJobIDTab PA_FORECAST_GLOB.NumberTabTyp;
  li_new_index NUMBER;
  ld_prev_end_date DATE;

  ld_start_date DATE;
  ld_end_date DATE;
  li_count NUMBER;
  li_first_index NUMBER;
  li_last_index NUMBER;
  li_new_first_index NUMBER;
  li_new_last_index NUMBER;
  ld_first_start_date DATE;
  ld_last_end_date DATE;

  g_TimelineProfileSetup  PA_TIMELINE_GLOB.TimelineProfileSetup;
  AVAILABILITY_DURATION   NUMBER;
	 l_msg_index_out NUMBER;

BEGIN

  PA_FORECASTITEM_PVT.print_message('Get_Res_Org_And_Job');

  g_TimelineProfileSetup  := PA_TIMELINE_UTIL.get_timeline_profile_setup;
  availability_duration   := g_TimelineProfileSetup.availability_duration;

  ld_start_date := NVL(p_start_date, ADD_MONTHS(sysdate, -12));
  ld_end_date := NVL(p_end_date, ADD_MONTHS(sysdate, availability_duration * (12)));

  PA_FORECASTITEM_PVT.print_message('p_person_id: ' || p_person_id);
  PA_FORECASTITEM_PVT.print_message('p_start_date: ' || p_start_date);
  PA_FORECASTITEM_PVT.print_message('p_end_date: ' || p_end_date);
  PA_FORECASTITEM_PVT.print_message('ld_start_date: ' || ld_start_date);
  PA_FORECASTITEM_PVT.print_message('ld_end_date: ' || ld_end_date);

--- |   18-sep-01 jmarques 	2001160: modified per_people_x select
--- |                       statement to select from per_people_f
--- |                       also added new date criteria since
--- |                       per_people_f could contain multiple records
--- |                       per resource.

--- Modified select statements to select directly off of pa_resources_denorm
--- This is for better performance and it is safer.

  BEGIN
--Bug 4207110 :Added equalto condition while performing date check

    select  nvl(RESOURCE_ORGANIZATION_ID, -99) resource_Organization_id,
            RESOURCE_EFFECTIVE_START_DATE effective_start_date,
            RESOURCE_EFFECTIVE_END_DATE effective_end_date,
            job_id job_id
	  BULK COLLECT INTO
			x_ResourceOrganizationIDTab,
			x_StartDateTab,
			x_EndDateTab,
			x_ResourceJobIDTab
    from pa_resources_denorm rou
    where person_id = p_person_id
    AND ld_start_date <=  NVL(rou.resource_effective_end_date,SYSDATE)
    AND ld_end_date >= rou.resource_effective_start_date
    ORDER BY rou.resource_effective_start_date;

--Bug 4207110 END


	EXCEPTION
	WHEN NO_DATA_FOUND THEN
    PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND ok, exception not raised');
  END;

  PA_FORECASTITEM_PVT.print_message('JM: 1');

  -- 2196924: Added logic so that all dates have a record in out table.
  li_count := NVL(x_StartDateTab.count,0);
  if (li_count = 0) then
    PA_FORECASTITEM_PVT.print_message('JM: 2');
    x_StartDateTab(1) := ld_start_date;
    x_EndDateTab(1) := ld_end_date;
    x_ResourceOrganizationIDTab(1) := -77;
    x_ResourceJobIDTab(1) := null;
    li_count := 1;
  end if;

  PA_FORECASTITEM_PVT.print_message('JM: 3');
  li_first_index := x_StartDateTab.first;
  li_new_first_index := li_first_index - 1;
  li_last_index := x_StartDateTab.last;
  li_new_last_index := li_last_index + 1;
  ld_first_start_date := x_StartDateTab(li_first_index);
  ld_last_end_date := x_EndDateTab(li_last_index);

  PA_FORECASTITEM_PVT.print_message('JM: 4');
  PA_FORECASTITEM_PVT.print_message('li_first_index: ' || li_first_index);
  PA_FORECASTITEM_PVT.print_message('li_new_first_index: ' || li_new_first_index);
  PA_FORECASTITEM_PVT.print_message('li_last_index: ' || li_last_index);
  PA_FORECASTITEM_PVT.print_message('li_new_last_index: ' || li_new_last_index);
  PA_FORECASTITEM_PVT.print_message('ld_first_start_date: ' || ld_first_start_date);
  PA_FORECASTITEM_PVT.print_message('ld_last_end_date: ' || ld_last_end_date);

  if (ld_first_start_date > ld_start_date) then
     -- Insert a record into table
     PA_FORECASTITEM_PVT.print_message('ld_first_start_date > ld_start_date');
     x_ResourceOrganizationIDTab(li_new_first_index) := -77;
     x_ResourceJobIDTab(li_new_first_index) := null;
     x_StartDateTab(li_new_first_index) := ld_start_date;
     x_EndDateTab(li_new_first_index) := ld_first_start_date - 1;
  end if;

  if (ld_last_end_date < ld_end_date) then
     -- Insert a record into table
     PA_FORECASTITEM_PVT.print_message('ld_last_end_date < ld_end_date');
     x_ResourceOrganizationIDTab(li_new_last_index) := -77;
     x_ResourceJobIDTab(li_new_last_index) := null;
     x_StartDateTab(li_new_last_index) := ld_last_end_date + 1;
     x_EndDateTab(li_new_last_index) := ld_end_date;
  end if;

  -- Fix holes (x_StartDateTab is definitely not empty here,
  -- so no need to check)
  li_new_index := 1;
  ld_prev_end_date := ld_start_date-1;
  for i IN x_StartDateTab.first .. x_StartDateTab.last LOOP
     if (x_StartDateTab(i) > ld_prev_end_date+1) then
        -- Insert record for hole.
        l_new_StartDateTab(li_new_index) := ld_prev_end_date + 1;
        l_new_EndDateTab(li_new_index) := x_StartDateTab(i)-1;
        l_new_ResOrganizationIDTab(li_new_index) := -77;
	      l_new_ResourceJobIDTab(li_new_index) := null;
        li_new_index := li_new_index + 1;
     end if;
     l_new_StartDateTab(li_new_index) := x_StartDateTab(i);
     l_new_EndDateTab(li_new_index) := x_EndDateTab(i);
     l_new_ResOrganizationIDTab(li_new_index)
                                := x_ResourceOrganizationIDTab(i);
	   l_new_ResourceJobIDTab(li_new_index) := x_ResourceJobIDTab(i);
     li_new_index := li_new_index + 1;
     ld_prev_end_date := x_EndDateTab(i);
  end loop;

  x_ResourceOrganizationIDTab := l_new_ResOrganizationIDTab;
  x_ResourceJobIDTab := l_new_ResourceJobIDTab;
  x_StartDateTab := l_new_StartDateTab;
  x_EndDateTab := l_new_EndDateTab;
-- 4537865 : EXCEPTION BLOCK INCLUDED
EXCEPTION
WHEN NO_DATA_FOUND THEN
    PA_FORECASTITEM_PVT.print_message('NO_DATA_FOUND ok, exception not raised');
    NULL ;
WHEN OTHERS THEN
        x_ResourceOrganizationIDTab.delete;
	x_ResourceJobIDTab.delete;
        x_StartDateTab.delete;
        x_EndDateTab.delete;
        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS'
        , p_procedure_name => 'Get_Res_Org_And_Job'
        , p_error_text  => SUBSTRB(SQLERRM,1,240));
        RAISE ;
END Get_Res_Org_And_Job;


-----------------------------------------------------------------------------------
--  Function 		Get_Person_Id
--  Purpose		To get the Person ID for resource Id
--  Parameters		Resource Id    NUMBER   YES    Resource Id
------------------------------------------------------------------------------------
FUNCTION Get_Person_Id(p_resource_id NUMBER) RETURN NUMBER IS
      li_person_id      NUMBER;
BEGIN
  PA_FORECASTITEM_PVT.print_message('p_resource_id: ' || p_resource_id);
	SELECT person_id
	  INTO li_person_id
	  FROM pa_resource_txn_attributes
         WHERE resource_id = p_resource_id
           AND rownum = 1;    --Bug 3086960. Adde by Sachin.
RETURN (li_person_id);
END Get_Person_id;


-----------------------------------------------------------------------------------
--  Function 		Get_Resource_Id
--  Purpose		To get the resource Id for person id
--  Parameters		Person Id    NUMBER   YES    Person Id
------------------------------------------------------------------------------------
FUNCTION Get_resource_Id(p_person_id NUMBER) RETURN NUMBER IS
      li_resource_id      NUMBER;
BEGIN
	SELECT resource_id
	  INTO li_resource_id
	  FROM pa_resource_txn_attributes
	WHERE person_id = p_person_id;
RETURN (li_resource_id);
END Get_resource_id;
------------------------------------------------------------------------------------------
--  Function 		Get_Resource_Type
--  Purpose		To get the Resource Type for resource Id
--  Parameters		Resource Id    NUMBER    YES  Resource id for its type
------------------------------------------------------------------------------------------
FUNCTION Get_Resource_Type(p_resource_id NUMBER) RETURN VARCHAR2 IS
       lv_resource_type  VARCHAR2(30);
BEGIN

	SELECT typ.RESOURCE_TYPE_CODE
	  INTO lv_resource_type
  	  FROM pa_resource_types typ,
	       pa_resources res
   	 WHERE res.resource_type_id= typ.resource_type_id
	   AND res.resource_id= p_resource_id;

RETURN (lv_resource_type);
END Get_Resource_Type;



----------------------------------------------------------------------------------------------------------------------
--  Procedure 		Get_ForecastOptions
--  Purpose		To get the all forecast options from pa_forecasting_options_all table
--  Input parameters
--  Parameters                      Type           Required  Description
--  p_org_id                        NUMBER         YES       Org id for which all the necessary information is needed
-- Out parameters
--  x_include_admin_proj_flag       VARCHAR2       YES       Used to store admin project flag
--  x_util_cal_method               VARCHAR2       YES       Used to store util cal method
--  x_bill_unassign_proj_id         NUMBER         YES       Used to store bill unassigned project id
--  x_bill_unassign_exp_type_class  VARCHAR2       YES       Used to store bill unassigned expenditure type class
--  x_bill_unassign_exp_type        VARCHAR2       YES       Used to store bill unassigned expenditure type
--  x_nobill_unassign_proj_id        NUMBER        YES       Used to store without bill unassigned project id
--  x_nobill_unassign_exp_type_class VARCHAR2      YES       Used to store without bill unassigned expenditure
--                                                           type class
--  x_nobill_unassign_exp_type       VARCHAR2      YES       Used to store without bill unassigned expenditure type
--  x_default_tp_amount_type         VARCHAR2      YES       Used to store default tp amount type
-----------------------------------------------------------------------------------------------------------------------
PROCEDURE Get_ForecastOptions(  p_org_id                        IN       NUMBER,
                               -- x_include_admin_proj_flag       OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895, 4576715
                                x_util_cal_method               OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_bill_unassign_proj_id         OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_bill_unassign_exp_type_class  OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_bill_unassign_exp_type        OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_nonbill_unassign_proj_id      OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_nonbill_unassign_exp_typ_cls  OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_nonbill_unassign_exp_type     OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_default_tp_amount_type        OUT      NOCOPY VARCHAR2 , --File.Sql.39 bug 4440895
                                x_return_status                 OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                     OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data                      OUT      NOCOPY VARCHAR2)  --File.Sql.39 bug 4440895
IS
	 l_msg_index_out NUMBER;

BEGIN

-- 4537865 : Initialize x_return_status to SUCCESS
x_return_status := FND_API.G_RET_STS_SUCCESS;

     PA_DEBUG.Init_err_stack(
          'PA_FORECAST_ITEMS_UTILS.Get_forecastoptions');
   -- Selecting columns corresponding to the given org id

   PA_FORECASTITEM_PVT.print_message('p_org_id: ' ||  p_org_id );

   -- 2196924: Adding case when p_org_id is null
   -- This may occur when there's no HR assignment for
   -- part of the resources time, so no ou.
   if (p_org_id = -88) then
       -- x_include_admin_proj_flag := null; Bug 4576715
      x_util_cal_method := null;
      x_bill_unassign_proj_id := -66;
      x_bill_unassign_exp_type_class := '-99';
      x_bill_unassign_exp_type  := '-99';
      x_nonbill_unassign_proj_id  := -66;
      x_nonbill_unassign_exp_typ_cls := '-99';
      x_nonbill_unassign_exp_type   := '-99';
      x_default_tp_amount_type    := '-99';
   else

   --R12: MOAC Changes: Bug 4363092: Removed nvl usage with org_id
   BEGIN
   SELECT  -- include_admin_proj_flag, Bug 4576715
           bill_unassign_proj_id,
           bill_unassign_exp_type_class,bill_unassign_exp_type,
           nonbill_unassign_proj_id,nonbill_unassign_exp_typ_cls,
           nonbill_unassign_exp_type,default_tp_amount_type,
           util_calc_method
   INTO    -- x_include_admin_proj_flag, Bug 4576715
           x_bill_unassign_proj_id,
           x_bill_unassign_exp_type_class,x_bill_unassign_exp_type,
           x_nonbill_unassign_proj_id,x_nonbill_unassign_exp_typ_cls,
           x_nonbill_unassign_exp_type,x_default_tp_amount_type,
           x_util_cal_method
   FROM    pa_forecasting_options_all
   WHERE   org_id = p_org_id;

  /* Bug 2458198 -- Begin */
   IF (
          -- x_include_admin_proj_flag = 'N' OR  Bug 4576715
	  x_nonbill_unassign_proj_id  is null OR x_bill_unassign_proj_id is null) THEN
   	  PA_UTILS.Add_Message(
      				p_app_short_name => 'PA'
                               ,p_msg_name      =>'PA_UNASSIGNED_PROJ_NO_DEFN');
 	  x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data      := 'PA_UNASSIGNED_PROJ_NO_DEFN';
		x_msg_count := FND_MSG_PUB.Count_Msg;

   END IF;
  /* Bug 2458198 -- End */
  exception
	WHEN NO_DATA_FOUND THEN
	  PA_UTILS.Add_Message(
      				p_app_short_name => 'PA'
                               ,p_msg_name      =>'PA_FORECAST_OPTIONS_NOT_SETUP');
 	  x_return_status := FND_API.G_RET_STS_ERROR;
		x_msg_data      := 'PA_FORECAST_OPTIONS_NOT_SETUP';
		x_msg_count := FND_MSG_PUB.Count_Msg;
  end;
  end if;
   PA_DEBUG.Reset_Err_Stack;

 EXCEPTION
   WHEN NO_DATA_FOUND THEN

        x_msg_count     := 1;
        x_msg_data      := sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.add_exc_msg
               (p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS.Get_forecastoptions',
                p_procedure_name => PA_DEBUG.G_Err_Stack);

        RAISE;

   WHEN OTHERS THEN
        x_msg_count     := 1;
        x_msg_data      := sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        FND_MSG_PUB.add_exc_msg
               (p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS.Get_forecastoptions',
                p_procedure_name => PA_DEBUG.G_Err_Stack);
     RAISE;


 END Get_ForecastOptions;


----------------------------------------------------------------------------------------------------------------------
--  Procedure           Get_Week_Dates_Range_Fc
--  Purpose             To get the global week end date
--  Input parameters
--  Parameters                      Type                    Required  Description
--  P_Start_Date                    DATE                     YES       Start date for the week date range
--  P_End_Date                      DATE                     YES       End date for the week date range
-- Out parameters
--  X_Week_Date_Range_Tab           WEEKDATESRANGEFCTABTYP   YES       Used to store week start and end date
-----------------------------------------------------------------------------------------------------------------------
PROCEDURE Get_Week_Dates_Range_Fc( p_start_date            IN DATE,
                                   p_end_date              IN DATE,
                                   x_week_date_range_tab   OUT NOCOPY PA_FORECAST_GLOB.WeekDatesRangeFcTabTyp , /* 2674619 - Nocopy change */
                                   x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                   x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                   x_msg_data              OUT     NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

IS
  l_week_ending_date               DATE;
  l_week_starting_date             DATE;
  l_week_ending_day                VARCHAR2(120);
  l_week_starting_day_index          NUMBER      := 2;
  li_cnt                           INTEGER     :=1;
	 l_msg_index_out NUMBER;
  l_end_date                       DATE; /* Added for bug#2462076 */
  l_week_starting_day              VARCHAR2(120); /*Bug 5549814 */

BEGIN


    PA_DEBUG.Init_err_stack(
              'PA_FORECAST_ITEMS_UTILS.Get_Week_Dates_Range_Fc');
   -- Taking value of the day from the profile option

   l_week_starting_day_index := TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY'));

/*Commenting below for Bug 7012687 : not use Select from dual to evaluate expression*/
/* Added for Bug 5549814*/
/* Utilizing the fact that 01-01-1950 was a Sunday and PA lookups value for a Sunday is 1 */
--Select (trim(to_char((to_date('01-01-1950','dd-mm-yyyy')+(l_week_starting_day_index - 1)),'DAY')))
--into l_week_starting_day
--from dual;

/*Adding below for Bug 7012687*/
  l_week_starting_day := (trim(to_char((to_date('01-01-1950','dd-mm-yyyy')+(l_week_starting_day_index - 1)),'DAY')));


/* Bug#2462076 Added code for using trunc on the start and end date parameters */
   l_week_starting_date  := trunc(p_start_date);
   l_end_date            := trunc(p_end_date);
   LOOP
      /*Commenting below for Bug 7012687 : not use Select from dual to evaluate expression*/
      --SELECT (NEXT_DAY(l_week_starting_date,l_week_starting_day)-1) /*Bug 5549814 - Changed l_week_starting_day_index to l_week_starting_day*/
      --INTO l_week_ending_date
      --FROM dual;

      /*Adding below for Bug 7012687*/
      l_week_ending_date := (NEXT_DAY(l_week_starting_date,l_week_starting_day)-1);

      l_week_starting_date  := l_week_ending_date -6;
      x_week_date_range_tab(li_cnt).week_start_date := l_week_starting_date;
      x_week_date_range_tab(li_cnt).week_end_date   := l_week_ending_date;
      l_week_starting_date    := l_week_ending_date +1;
      EXIT WHEN l_week_starting_date > l_end_date; /* Bug#2462076 Changed p_end_date to l_end_date */
      li_cnt := li_cnt +1;

   END LOOP;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   PA_DEBUG.Reset_Err_Stack;

EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg
           (p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS.Get_Week_Dates_Range_Fc',
            p_procedure_name => PA_DEBUG.G_Err_Stack);
      RAISE;
END Get_Week_Dates_Range_Fc;



----------------------------------------------------------------------------------------------------------------------
--  Procedure           Check_TPAmountType
--  Purpose             To validate the tp amount type and code or description
--  Input parameters
--  Parameters                      Type                    Required  Description
--  p_tp_amount_type_code           VARCHAR2                 YES       Tp amount type code
--  p_tp_amount_type_desc           VARCHAR2                 YES       Tp amount type desc
--  p_check_id_flag                 VARCHAR2                 YES       Check id flage
-- Out parameters
--  x_tp_amount_type_code           VARCHAR2                 YES       Tp amount type code
--  x_tp_amount_type_desc           VARCHAR2                 YES       Tp amount type desc
-----------------------------------------------------------------------------------------------------------------------
PROCEDURE    Check_TPAmountType(
                     p_tp_amount_type_code    IN VARCHAR2,
                     p_tp_amount_type_desc    IN VARCHAR2,
                     p_check_id_flag          IN VARCHAR2,
                     x_tp_amount_type_code    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_tp_amount_type_desc    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                     x_msg_data               OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

         lv_error_msg  VARCHAR2(30);

 BEGIN

         PA_DEBUG.Init_err_stack(
                       'PA_FORECAST_ITEMS_UTILS.Check_TPAmountType');
        IF p_tp_amount_type_code IS NOT NULL AND
                      p_tp_amount_type_code<>FND_API.G_MISS_CHAR THEN

                IF p_check_id_flag = 'Y' THEN

                        lv_error_msg := 'PA_AMOUNT_TYPE_CODE_AMBIGUOUS';

                        SELECT lookup_code, meaning
                        INTO   x_tp_amount_type_code,
                               x_tp_amount_type_desc
                        FROM   pa_lookups
                        WHERE  lookup_type = 'TP_AMOUNT_TYPE'
                        AND    lookup_code =  p_tp_amount_type_code;

                ELSE
                        x_tp_amount_type_code := p_tp_amount_type_code;

                END IF;

        ELSE

                lv_error_msg := 'PA_AMOUNT_TYPE_DESC_AMBIGUOUS';

                SELECT lookup_code
                INTO   x_tp_amount_type_code
                FROM   pa_lookups
                WHERE  lookup_type = 'TP_AMOUNT_TYPE'
                AND    meaning =  p_tp_amount_type_desc;


        END IF;

        PA_DEBUG.Reset_Err_Stack;

        x_return_status := FND_API.G_RET_STS_SUCCESS;
 EXCEPTION
        WHEN NO_DATA_FOUND THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := lv_error_msg;

		-- 4537865 : Start
		 x_tp_amount_type_code    := NULL ;
		 x_tp_amount_type_desc    := NULL ;
		--4537865 : End

                FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                         'PA_FORECAST_ITEMS_UTILS.Check_TPAmountType',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
        WHEN TOO_MANY_ROWS THEN
                x_return_status := FND_API.G_RET_STS_ERROR;
                x_msg_data := lv_error_msg;

                -- 4537865 : Start
                 x_tp_amount_type_code    := NULL ;
                 x_tp_amount_type_desc    := NULL ;
                --4537865 : End

                FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                         'PA_FORECAST_ITEMS_UTILS.Check_TPAmountType',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
        WHEN OTHERS THEN
                x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

                -- 4537865 : Start
                 x_tp_amount_type_code    := NULL ;
                 x_tp_amount_type_desc    := NULL ;
                --4537865 : End

                FND_MSG_PUB.add_exc_msg
                      (p_pkg_name   =>
                         'PA_FORECAST_ITEMS_UTILS.Check_TPAmountType',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
                --PA_Error_Utils.Set_Error_Stack
                -- (`pa_resource_utils.check_resourcename_or_id');
                        -- This sets the current program unit name in the
                        -- error stack. Helpful in Debugging
                raise;

 END Check_TPAmountType;



----------------------------------------------------------------------------------------------------------
-- Description          This procedure will get the defautl values for the Assignment
--
-- Procedure Name       Get_Assignment_Default
-- Used Subprograms     None
-- Input parameters    Type       Required            Description
-- p_assignment_type  VARCHAR2      Yes             The assignment type, can be either
--                                                  'Open assignment'or 'Staffed assignment'.
-- p_project_id       NUMBER        Yes             Project ID
-- p_project_role_id  NUMBER        Yes             Project role ID

-- Output parameters            Type            Description
-- x_work_type_id               NUMBER          Default Work Type ID
-- x_default_tp_amount_type     VARCHAR2        Default transfer price amount type
-- x_default_job_group_id       NUMBER          Default job group ID
-- x_default_job_id             NUMBER          Default jog ID
-- x_org_id                     NUMBER          Default Expenditure OU ID
-- x_carrying_out_organization_id NUMBER        Default Expenditure Org ID
-- x_default_assign_exp_type    VARCHAR2        Default Expenditure Type
-- x_default_assign_exp_type_cls VARCHAR2       Default Expenditure Type Class
-- x_return_status              VARCHAR2        The return status of this procedure
-------------------------------------------------------------------------------------------------------------
PROCEDURE Get_Assignment_Default (p_assignment_type                     IN              VARCHAR2,
                                  p_project_id                          IN              NUMBER,
                                  p_project_role_id                     IN              NUMBER,
                                  p_work_type_id                        IN              NUMBER,
                                  x_work_type_id                        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_tp_amount_type              OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_default_job_group_id                OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_job_id                      OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_org_id                              OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_carrying_out_organization_id        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type             OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type_cls         OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status                       OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count                           OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data                            OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  )
IS
BEGIN
    x_return_status :=  FND_API.G_RET_STS_SUCCESS;

    Get_Project_Default( p_assignment_type              => p_assignment_type,
                         p_project_id                   => p_project_id,
                         x_work_type_id                 => x_work_type_id,
                         x_default_tp_amount_type       => x_default_tp_amount_type,
                         x_org_id                       => x_org_id,
                         x_carrying_out_organization_id => x_carrying_out_organization_id,
                         x_default_assign_exp_type      => x_default_assign_exp_type,
                         x_default_assign_exp_type_cls  => x_default_assign_exp_type_cls,
                         x_return_status                => x_return_status,
                         x_msg_count                    => x_msg_count,
                         x_msg_data                     => x_msg_data );

    Get_Project_Role_Default (p_assignment_type      => p_assignment_type,
                              p_project_role_id      => p_project_role_id,
                              x_default_job_group_id => x_default_job_group_id,
                              x_default_job_id       => x_default_job_id,
                              x_return_status        => x_return_status,
                              x_msg_count            => x_msg_count,
                              x_msg_data             => x_msg_data );

    IF FND_MSG_PUB.Count_Msg > 0 THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count     := FND_MSG_PUB.Count_Msg;
       x_msg_data      := NULL;
    END IF;

EXCEPTION
 WHEN OTHERS THEN
-- 4537865 : Start

	x_work_type_id                        := NULL ;
	x_default_tp_amount_type              := NULL ;
	x_default_job_group_id                := NULL ;
	x_default_job_id                      := NULL ;
	x_org_id                              := NULL ;
	x_carrying_out_organization_id        := NULL ;
	x_default_assign_exp_type             := NULL ;
	x_default_assign_exp_type_cls         := NULL ;
-- 4537865 : End
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg
         (p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS.Get_assignment_default',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
    raise;

END Get_Assignment_Default;

PROCEDURE Get_Project_Default (   p_assignment_type                     IN              VARCHAR2,
                                  p_project_id                          IN              NUMBER,
                                  x_work_type_id                        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_tp_amount_type              OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_org_id                              OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_carrying_out_organization_id        OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type             OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_default_assign_exp_type_cls         OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_return_status                       OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count                           OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data                            OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  )
IS

BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  SELECT  work_type_id,
          org_id,
          carrying_out_organization_id
  INTO    x_work_type_id,
          x_org_id,
          x_carrying_out_organization_id
  FROM    pa_projects_all
  WHERE   project_id = p_project_id;

  begin
  --R12: MOAC Changes: Bug 4363092: Removed nvl usage with org_id
     SELECT default_assign_exp_type,
            default_assign_exp_type_class
     INTO   x_default_assign_exp_type,
            x_default_assign_exp_type_cls
     FROM   pa_forecasting_options_all
     WHERE  org_id = x_org_id;

  exception
     WHEN NO_DATA_FOUND THEN
          PA_UTILS.Add_Message(
                    p_app_short_name => 'PA'
                   ,p_msg_name       =>'PA_FORECAST_OPTIONS_NOT_SETUP');
     x_return_status := FND_API.G_RET_STS_ERROR;
  end;

  -- Populate expenditure_organization_id only for requirement
  IF p_assignment_type <> 'OPEN_ASSIGNMENT' THEN
     x_org_id                       := NULL;
     x_carrying_out_organization_id := NULL;
  END IF;

  IF (x_return_status = FND_API.G_RET_STS_SUCCESS) then
     Pa_Fp_Org_Fcst_Utils.Get_Tp_Amount_Type(
                              p_project_id => p_project_id,
                              p_work_type_id => x_work_type_id,
                              x_tp_amount_type => x_default_tp_amount_type,
                              x_return_status => x_return_status,
                              x_msg_count => x_msg_count,
                              x_msg_data => x_msg_data);
  END IF;

EXCEPTION
 WHEN OTHERS THEN
-- 4537865 : Start

        x_work_type_id                        := NULL ;
        x_default_tp_amount_type              := NULL ;
        x_org_id                              := NULL ;
        x_carrying_out_organization_id        := NULL ;
        x_default_assign_exp_type             := NULL ;
        x_default_assign_exp_type_cls         := NULL ;
-- 4537865 : End
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg
         (p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS.Get_project_default',
                       p_procedure_name => PA_DEBUG.G_Err_Stack);
    raise;

END Get_Project_Default;

PROCEDURE Get_Project_Role_Default (p_assignment_type                     IN              VARCHAR2,
                                    p_project_role_id                     IN              NUMBER,
                                    x_default_job_group_id                OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_default_job_id                      OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_return_status                       OUT             NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                    x_msg_count                           OUT             NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                    x_msg_data                            OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                  )
IS
BEGIN
  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  begin
     SELECT b.job_group_id,
            a.default_job_id
     INTO   x_default_job_group_id,
            x_default_job_id
     FROM   (select project_role_id,
                    pa_role_job_bg_utils.get_job_id(project_role_id) default_job_id
             from pa_project_role_types_b
             where role_party_class = 'PERSON'
             and project_role_id = p_project_role_id) a,
            per_jobs b
     WHERE  b.job_id = a.default_job_id;
  exception
     WHEN NO_DATA_FOUND THEN
          PA_UTILS.Add_Message(
                   p_app_short_name => 'PA'
                  ,p_msg_name       => 'PA_JOB_NOT_FOUND');
  end;

  IF p_assignment_type <> 'OPEN_ASSIGNMENT' THEN
     x_default_job_id := NULL;
  END IF;

EXCEPTION
 WHEN OTHERS THEN

-- 4537865 : Start
	x_default_job_group_id                := NULL ;
	x_default_job_id                      := NULL ;
-- 4537865 : End
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg
         (p_pkg_name   => 'PA_FORECAST_ITEMS_UTILS.Get_Project_Role_default',
                           p_procedure_name => PA_DEBUG.G_Err_Stack);
    raise;

END Get_Project_Role_Default;

END PA_FORECAST_ITEMS_UTILS;


/
