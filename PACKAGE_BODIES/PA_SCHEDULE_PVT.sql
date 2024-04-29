--------------------------------------------------------
--  DDL for Package Body PA_SCHEDULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SCHEDULE_PVT" as
	--/* $Header: PARGPVTB.pls 120.19.12010000.11 2010/01/28 09:59:39 svivaram ship $ */

l_out_of_range_date     EXCEPTION;    -- Exception variable for raising the exception when date is out of range
l_invalid_date_range    EXCEPTION;    -- Exception variable for raising the exception when date is invalid  of range
l_empty_tab_record      EXCEPTION;    -- Variable to raise the exception if  the passing table of records is empty
l_remove_conflicts_failed EXCEPTION;  -- Variable to raise the exception if conflicts can not be removed because one or more conflicting assignments are locked
l_x_return_status       VARCHAR2(50); -- variable to store the return status


-- This procedure will get the existing schedule for the duration shift and pattern
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Calendar_Id                NUMBER         YES       Id for that calendar to which you want to get schedule
-- P_Start_Date                 DATE           YES       Starting date of the schedule for that calendar
-- P_Start_Date                 DATE           YES       Ending date of the schedule for that calendar
--x_difference_days       NUMBER     YES        number of days shifted
--x_shift_unit_code         VARCHAR2 YES        Unit of Shift

--
-- Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP YES       It stores  schedule for that calendar
--

PROCEDURE get_existing_schedule ( 	p_calendar_id            IN   NUMBER,
                        p_assignment_id  IN NUMBER,
					    p_start_date             IN   DATE,
						p_end_date               IN   DATE,
						x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
						x_difference_days        IN NUMBER,
						x_shift_unit_code        IN VARCHAR2,
						x_return_status          OUT  NOCOPY VARCHAR2,
						x_msg_count              OUT  NOCOPY NUMBER,
						x_msg_data               OUT  NOCOPY VARCHAR2 )
IS
	 l_I                      NUMBER;
	 l_J                      NUMBER;

	 l_st_dt_done             BOOLEAN;                       -- Temp variable
	 l_end_dt_done            BOOLEAN;                       -- Temp variable
	 l_x_sch_copy_done        BOOLEAN;                       -- Temp variable
	 l_curr_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_out_schedule_rec       PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;


   TYPE calendar_id_tbl IS TABLE OF PA_SCHEDULES.calendar_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE start_date_tbl IS TABLE OF PA_SCHEDULES.start_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE end_date_tbl IS TABLE OF PA_SCHEDULES.end_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Monday_hours_tbl IS TABLE OF PA_SCHEDULES.Monday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Tuesday_hours_tbl IS TABLE OF PA_SCHEDULES.Tuesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Wednesday_hours_tbl IS TABLE OF PA_SCHEDULES.Wednesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Thursday_hours_tbl IS TABLE OF PA_SCHEDULES.Thursday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Friday_hours_tbl IS TABLE OF PA_SCHEDULES.Friday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Saturday_hours_tbl IS TABLE OF PA_SCHEDULES.Saturday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Sunday_hours_tbl IS TABLE OF PA_SCHEDULES.Sunday_hours%TYPE
     INDEX BY BINARY_INTEGER;

   l_calendar_id_tbl calendar_id_tbl;
   l_start_date_tbl  start_date_tbl ;
   l_end_date_tbl  end_date_tbl ;
   l_Monday_hours_tbl  Monday_hours_tbl ;
   l_Tuesday_hours_tbl Tuesday_hours_tbl;
   l_Wednesday_hours_tbl  Wednesday_hours_tbl ;
   l_Thursday_hours_tbl  Thursday_hours_tbl;
   l_Friday_hours_tbl  Friday_hours_tbl  ;
   l_Saturday_hours_tbl Saturday_hours_tbl ;
   l_Sunday_hours_tbl Sunday_hours_tbl ;

   l_first_index NUMBER;
   l_last_index NUMBER;
   i NUMBER;

   l_no_days NUMBER := 0;
   l_next_start_date Date;

BEGIN
	 l_st_dt_done      := FALSE;
	 l_end_dt_done     := FALSE;
	 l_x_sch_copy_done := FALSE;
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	SELECT 	calendar_id,
			start_date,
			end_date,
			Monday_hours,
			Tuesday_hours,
			Wednesday_hours,
			Thursday_hours,
			Friday_hours,
			Saturday_hours,
			Sunday_hours
	BULK COLLECT INTO
			l_calendar_id_tbl ,
			l_start_date_tbl  ,
			l_end_date_tbl ,
			l_Monday_hours_tbl  ,
			l_Tuesday_hours_tbl ,
			l_Wednesday_hours_tbl  ,
			l_Thursday_hours_tbl  ,
			l_Friday_hours_tbl  ,
			l_Saturday_hours_tbl ,
			l_Sunday_hours_tbl
	FROM  PA_SCHEDULES sch
	WHERE sch.assignment_id  = p_assignment_id
	ORDER BY sch.start_date;

  l_first_index := NVL(l_start_date_tbl.first,0);
  l_last_index := NVL(l_start_date_tbl.last,-1);

  FOR i IN l_first_index .. l_last_index LOOP
			l_curr_schedule_rec(i).start_date        := l_start_date_tbl(i);
			l_curr_schedule_rec(i).end_date          := l_end_date_tbl(i);
			l_curr_schedule_rec(i).Monday_hours      := l_Monday_hours_tbl(i);
			l_curr_schedule_rec(i).Tuesday_hours     := l_Tuesday_hours_tbl(i);
			l_curr_schedule_rec(i).Wednesday_hours   := l_Wednesday_hours_tbl(i);
			l_curr_schedule_rec(i).Thursday_hours    := l_Thursday_hours_tbl(i);
			l_curr_schedule_rec(i).Friday_hours      := l_Friday_hours_tbl(i);
			l_curr_schedule_rec(i).Saturday_hours    := l_Saturday_hours_tbl(i);
			l_curr_schedule_rec(i).Sunday_hours      := l_Sunday_hours_tbl(i);


		/*  if (x_shift_unit_code = 'MONTHS') then
		    l_no_days := round(months_between(l_end_date_tbl(i), l_start_date_tbl(i))) ;
		  else
 		    l_no_days := l_end_date_tbl(i) - l_start_date_tbl(i) ;
          end if; */ /* Commented for bug 9229210 */

	/* if (i = l_first_index) then */ /* Commented for bug 9229210 */
	  if (x_shift_unit_code = 'MONTHS') then
	    l_curr_schedule_rec(i).start_date := add_months(l_curr_schedule_rec(i).start_date, x_difference_days);
	    l_curr_schedule_rec(i).end_date := add_months(l_curr_schedule_rec(i).end_date, x_difference_days);
      else
		l_curr_schedule_rec(i).start_date := l_curr_schedule_rec(i).start_date + x_difference_days;
		l_curr_schedule_rec(i).end_date := l_curr_schedule_rec(i).end_date + x_difference_days;
	  end if;
    /* else
        l_curr_schedule_rec(i).start_date := l_next_start_date;
    end if; */ /* Commented for bug 9229210 */

	 /* if (x_shift_unit_code = 'MONTHS') then
	    l_curr_schedule_rec(i).end_date := add_months(l_curr_schedule_rec(i).start_date, l_no_days);
		l_curr_schedule_rec(i).end_date := l_curr_schedule_rec(i).end_date - 1;
      else
		l_curr_schedule_rec(i).end_date := l_curr_schedule_rec(i).start_date + l_no_days;
	  end if;

    l_next_start_date := l_curr_schedule_rec(i).end_date + 1;	*/ /* Commented for bug 9229210 */

	END LOOP;

	IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_curr_schedule_rec,l_curr_schedule_rec.first,l_curr_schedule_rec.last,
		 x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
	 END IF;

	 x_return_status := l_x_return_status;

	 EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'get_existing_schedule');
		 raise;

END get_existing_schedule;



-- This procedure will get the calendar schedule on the basis of calendar id
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Calendar_Id                NUMBER         YES       Id for that calendar to which you want to get schedule
-- P_Start_Date                 DATE           YES       Starting date of the schedule for that calendar
-- P_Start_Date                 DATE           YES       Ending date of the schedule for that calendar
--
-- Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP YES       It stores  schedule for that calendar
--

PROCEDURE get_calendar_schedule ( 	p_calendar_id            IN   NUMBER,
					     	p_start_date             IN   DATE,
						p_end_date               IN   DATE,
						x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
						x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
						x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
						x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_I                      NUMBER;
	 l_J                      NUMBER;

	 l_st_dt_done             BOOLEAN;                       -- Temp variable
	 l_end_dt_done            BOOLEAN;                       -- Temp variable
	 l_x_sch_copy_done        BOOLEAN;                       -- Temp variable
	 l_curr_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_out_schedule_rec       PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;

	 -- This cursor will select the schedule records of the passing calendar
/* Bug - 1846658-  Following lines are commented to incorporate the BULK SELECT to enhance the performance*/

--	 CURSOR C1 IS SELECT calendar_id,start_date,end_date,Monday_hours,Tuesday_hours,Wednesday_hours,Thursday_hours,
--		 Friday_hours,Saturday_hours,Sunday_hours
--		 FROM  PA_SCHEDULES sch
--		 WHERE sch.calendar_id        = p_calendar_id
--		 AND   sch.schedule_type_code = 'CALENDAR'
--		 AND   ( ( p_start_date BETWEEN sch.start_date AND sch.end_date)
--		 OR    ( p_end_date   BETWEEN sch.start_date AND sch.end_date)
--		 OR    ( p_start_date < sch.start_date AND p_end_date > sch.end_date) ) ;
--     ORDER BY sch.start_date

/* Bug - 1846658-  Following lines are added to incorporate the BULK SELECT to enhance the performance*/

   TYPE calendar_id_tbl IS TABLE OF PA_SCHEDULES.calendar_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE start_date_tbl IS TABLE OF PA_SCHEDULES.start_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE end_date_tbl IS TABLE OF PA_SCHEDULES.end_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Monday_hours_tbl IS TABLE OF PA_SCHEDULES.Monday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Tuesday_hours_tbl IS TABLE OF PA_SCHEDULES.Tuesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Wednesday_hours_tbl IS TABLE OF PA_SCHEDULES.Wednesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Thursday_hours_tbl IS TABLE OF PA_SCHEDULES.Thursday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Friday_hours_tbl IS TABLE OF PA_SCHEDULES.Friday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Saturday_hours_tbl IS TABLE OF PA_SCHEDULES.Saturday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Sunday_hours_tbl IS TABLE OF PA_SCHEDULES.Sunday_hours%TYPE
     INDEX BY BINARY_INTEGER;

   l_calendar_id_tbl calendar_id_tbl;
   l_start_date_tbl  start_date_tbl ;
   l_end_date_tbl  end_date_tbl ;
   l_Monday_hours_tbl  Monday_hours_tbl ;
   l_Tuesday_hours_tbl Tuesday_hours_tbl;
   l_Wednesday_hours_tbl  Wednesday_hours_tbl ;
   l_Thursday_hours_tbl  Thursday_hours_tbl;
   l_Friday_hours_tbl  Friday_hours_tbl  ;
   l_Saturday_hours_tbl Saturday_hours_tbl ;
   l_Sunday_hours_tbl Sunday_hours_tbl ;

   l_first_index NUMBER;
   l_last_index NUMBER;
   i NUMBER;

BEGIN
	 l_st_dt_done      := FALSE;
	 l_end_dt_done     := FALSE;
	 l_x_sch_copy_done := FALSE;
	 -- store status success to track the error
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Bug - 1846658-  Following lines are commented to incorporate the BULK SELECT to enhance the performance*/

--	 FOR v_c1 IN C1 LOOP
--			l_curr_schedule_rec(1).start_date        := v_c1.start_date;
--			l_curr_schedule_rec(1).end_date          := v_c1.end_date;
--			l_curr_schedule_rec(1).Monday_hours      := v_c1.Monday_hours;
--			l_curr_schedule_rec(1).Tuesday_hours     := v_c1.Tuesday_hours;
--			l_curr_schedule_rec(1).Wednesday_hours   := v_c1.Wednesday_hours;
--			l_curr_schedule_rec(1).Thursday_hours    := v_c1.Thursday_hours;
--			l_curr_schedule_rec(1).Friday_hours      := v_c1.Friday_hours;
--			l_curr_schedule_rec(1).Saturday_hours    := v_c1.Saturday_hours;
--			l_curr_schedule_rec(1).Sunday_hours      := v_c1.Sunday_hours;

/* Bug - 1846658-  Following lines are added to incorporate the BULK SELECT to enhance the performance*/

	SELECT 	calendar_id,
			start_date,
			end_date,
			Monday_hours,
			Tuesday_hours,
			Wednesday_hours,
			Thursday_hours,
			Friday_hours,
			Saturday_hours,
			Sunday_hours
	BULK COLLECT INTO
			l_calendar_id_tbl ,
			l_start_date_tbl  ,
			l_end_date_tbl ,
			l_Monday_hours_tbl  ,
			l_Tuesday_hours_tbl ,
			l_Wednesday_hours_tbl  ,
			l_Thursday_hours_tbl  ,
			l_Friday_hours_tbl  ,
			l_Saturday_hours_tbl ,
			l_Sunday_hours_tbl
	FROM  PA_SCHEDULES sch
	WHERE sch.calendar_id  = p_calendar_id
	AND   sch.schedule_type_code = 'CALENDAR'
	AND   ( ( p_start_date BETWEEN sch.start_date AND sch.end_date)
	OR    ( p_end_date   BETWEEN sch.start_date AND sch.end_date)
	OR    ( p_start_date < sch.start_date AND p_end_date > sch.end_date) )
	ORDER BY sch.start_date;

  l_first_index := NVL(l_start_date_tbl.first,0);
  l_last_index := NVL(l_start_date_tbl.last,-1);

  FOR i IN l_first_index .. l_last_index LOOP

			l_curr_schedule_rec(1).start_date        := l_start_date_tbl(i);
			l_curr_schedule_rec(1).end_date          := l_end_date_tbl(i);
			l_curr_schedule_rec(1).Monday_hours      := l_Monday_hours_tbl(i);
			l_curr_schedule_rec(1).Tuesday_hours     := l_Tuesday_hours_tbl(i);
			l_curr_schedule_rec(1).Wednesday_hours   := l_Wednesday_hours_tbl(i);
			l_curr_schedule_rec(1).Thursday_hours    := l_Thursday_hours_tbl(i);
			l_curr_schedule_rec(1).Friday_hours      := l_Friday_hours_tbl(i);
			l_curr_schedule_rec(1).Saturday_hours    := l_Saturday_hours_tbl(i);
			l_curr_schedule_rec(1).Sunday_hours      := l_Sunday_hours_tbl(i);


			-- The passing start date if greater the existing end date of the schedule or greater or
			-- equal to the existing start date
			IF (p_start_date > l_curr_schedule_rec(1).end_date) AND (l_st_dt_done = FALSE) THEN
				 NULL;
			ELSE
				 IF (p_start_date = l_curr_schedule_rec(1).start_date) AND ( l_st_dt_done = FALSE) THEN
						l_st_dt_done := TRUE;
				 ELSIF ( p_start_date > l_curr_schedule_rec(1).start_date ) AND (l_st_dt_done = FALSE) THEN
						l_curr_schedule_rec(1).start_date := p_start_date;
						l_st_dt_done:= TRUE;
				 END IF;

				 -- The passing end date if less than or equal to the existing end date of the schedule or
				 -- greater to the existing end date
				 IF ((p_end_date <= l_curr_schedule_rec(1).end_date) AND (l_end_dt_done = FALSE))  THEN
						l_curr_schedule_rec(1).end_date := p_end_date;
						l_end_dt_done                   := TRUE;
				 ELSIF (p_end_date > l_curr_schedule_rec(1).end_date ) AND (l_end_dt_done = FALSE) THEN
						NULL;
				 END IF;


				 -- Appending the record which is being changed in above validation
         IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_curr_schedule_rec,1,1,l_out_schedule_rec,l_x_return_status,x_msg_count,
					 x_msg_data);
         END IF;

				 IF (l_st_dt_done = TRUE ) AND  (l_end_dt_done = TRUE) THEN
						EXIT;
				 END IF;

			END IF;
	 END LOOP;

	 -- The calendar has schedule record in the table of record  then the following processing will occur
	 IF ( l_out_schedule_rec.count > 0 )  THEN
			l_I := l_out_schedule_rec.first;
			l_J := l_out_schedule_rec.Last;

			-- If the start date is lower than the schedule start date the its schedule will be 0 and take the actual schedule
			-- on the schedule start date
			IF (p_start_date < l_out_schedule_rec(l_I).start_date) THEN
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,1,1,l_temp_schedule_rec,l_x_return_status,x_msg_count,
							x_msg_data);
				 END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,p_start_date =>p_start_date,
							p_end_date =>l_out_schedule_rec(l_I).start_date -1 ,p_monday_hours =>0.00,p_tuesday_hours =>0.00,
							p_wednesday_hours =>0.00,p_thursday_hours =>0.00,p_friday_hours =>0.00,p_saturday_hours =>0.00,
							p_sunday_hours =>0.00,x_return_status => l_x_return_status,x_msg_count => x_msg_count,
							x_msg_data =>x_msg_data);
				 END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,1,1,x_sch_record_tab,l_x_return_status,x_msg_count,
							x_msg_data);
				 END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
							x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
				 END IF;
				 l_x_sch_copy_done := TRUE;
			END IF;
			-- If the end date is beyond the end date of the schedule of the passed calendar
			-- then its that period will be having 0 work pattern
			IF (p_end_date > l_out_schedule_rec(l_J).end_date) THEN
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,1,1,l_temp_schedule_rec,l_x_return_status,
							x_msg_count,x_msg_data);
				 END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,
							p_start_date =>l_out_schedule_rec(l_J).end_date + 1 , p_end_date => p_end_date,p_monday_hours =>0.00,
							p_tuesday_hours =>0.00, p_wednesday_hours =>0.00,p_thursday_hours =>0.00,p_friday_hours =>0.00,
							p_saturday_hours =>0.00,p_sunday_hours =>0.00,
							x_return_status => l_x_return_status,x_msg_count => x_msg_count,x_msg_data =>x_msg_data);
				 END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS AND l_x_sch_copy_done <> TRUE ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
							x_sch_record_tab, l_x_return_status,x_msg_count,x_msg_data);
				 END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,1,1,x_sch_record_tab,l_x_return_status,x_msg_count,
							x_msg_data);
				 END IF;
				 l_x_sch_copy_done := TRUE;
			END IF;
	 ELSE
			l_out_schedule_rec(1).start_date      := p_start_date;
			l_out_schedule_rec(1).end_date        := p_end_date ;
			l_out_schedule_rec(1).monday_hours    := 0.00;
			l_out_schedule_rec(1).tuesday_hours   := 0.00;
			l_out_schedule_rec(1).wednesday_hours := 0.00;
			l_out_schedule_rec(1).thursday_hours  := 0.00;
			l_out_schedule_rec(1).friday_hours    := 0.00;
			l_out_schedule_rec(1).saturday_hours  := 0.00;
			l_out_schedule_rec(1).sunday_hours    := 0.00;
	 END IF;

	 IF l_x_sch_copy_done = FALSE  THEN
			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
					 x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
			END IF;
	 END IF;
	 x_return_status := l_x_return_status;

EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'get_calendar_schedule');
		 raise;

END get_calendar_schedule;

-- This procedure will take assignment id,start_date and end date and then will get the schedule for
-- the passed assignment. This is an overloaded procedure.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Assignment_Id              NUMBER         YES       Id for that assignment to which you want to get schedule
-- P_Start_Date                 DATE           YES       Starting date of the schedule for that assignment
-- P_Start_Date                 DATE           YES       Ending date of the schedule for that assignment
--
-- Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP YES       It stores  schedule for that assignment
--

PROCEDURE get_assignment_schedule ( p_assignment_id        IN   NUMBER,
						p_start_date             IN   DATE,
						p_end_date               IN   DATE,
						x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
						x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
						x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
						x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_I                      NUMBER;
	 l_J                      NUMBER;

	 l_st_dt_done             BOOLEAN;
	 l_end_dt_done            BOOLEAN;
	 l_x_sch_copy_done        BOOLEAN;
	 l_curr_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_out_schedule_rec       PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;

	 -- This cursor will select only those records of passing assignment which are open or staffed.
   -- 1561861 Added 'STAFFED_ADMIN_ASSIGNMENT' to the where clause'.
/* Bug - 1846658-  Following lines are commented to incorporate the BULK SELECT to enhance the performance*/

--	 CURSOR C1 IS SELECT   schedule_id, calendar_id,
--		 assignment_id,project_id,schedule_type_code,status_code,
--		 system_status_code,start_date,end_date,Monday_hours,Tuesday_hours,
--		 Wednesday_hours,Thursday_hours,
--		 Friday_hours,Saturday_hours,Sunday_hours
--		 FROM     PA_SCHEDULES_V sch
--		 WHERE    sch.assignment_id = p_assignment_id
--		 AND      sch.schedule_type_code IN
--		 ('OPEN_ASSIGNMENT','STAFFED_ASSIGNMENT', 'STAFFED_ADMIN_ASSIGNMENT')
--		 AND      ( ( p_start_date BETWEEN sch.start_date AND sch.end_date)
--		 OR       ( p_end_date   BETWEEN sch.start_date AND sch.end_date)
--		 OR       ( p_start_date < sch.start_date AND p_end_date > sch.end_date) )
--		 ORDER BY start_date;

/* Bug - 1846658-  Following lines are added to incorporate the BULK SELECT to enhance the performance*/

   TYPE schedule_id_tbl IS TABLE OF PA_SCHEDULES_V.schedule_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE calendar_id_tbl IS TABLE OF PA_SCHEDULES_V.calendar_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE assignment_id_tbl IS TABLE OF PA_SCHEDULES_V.assignment_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE project_id_tbl IS TABLE OF PA_SCHEDULES_V.project_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE schedule_type_code_tbl IS TABLE OF PA_SCHEDULES_V.schedule_type_code%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE status_code_tbl IS TABLE OF PA_SCHEDULES_V.status_code%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE system_status_code_tbl IS TABLE OF PA_SCHEDULES_V.system_status_code%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE start_date_tbl IS TABLE OF PA_SCHEDULES_V.start_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE end_date_tbl IS TABLE OF PA_SCHEDULES_V.end_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Monday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Monday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Tuesday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Tuesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Wednesday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Wednesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Thursday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Thursday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Friday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Friday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Saturday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Saturday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Sunday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Sunday_hours%TYPE
     INDEX BY BINARY_INTEGER;

   l_schedule_id_tbl		schedule_id_tbl ;
   l_calendar_id_tbl		calendar_id_tbl ;
   l_assignment_id_tbl		assignment_id_tbl;
   l_project_id_tbl		project_id_tbl;
   l_schedule_type_code_tbl	schedule_type_code_tbl;
   l_status_code_tbl		status_code_tbl    ;
   l_system_status_code_tbl	system_status_code_tbl;
   l_start_date_tbl		start_date_tbl ;
   l_end_date_tbl			end_date_tbl ;
   l_Monday_hours_tbl		Monday_hours_tbl ;
   l_Tuesday_hours_tbl		Tuesday_hours_tbl;
   l_Wednesday_hours_tbl	Wednesday_hours_tbl ;
   l_Thursday_hours_tbl		Thursday_hours_tbl;
   l_Friday_hours_tbl		Friday_hours_tbl  ;
   l_Saturday_hours_tbl		Saturday_hours_tbl ;
   l_Sunday_hours_tbl		Sunday_hours_tbl ;

   l_first_index NUMBER;
   l_last_index NUMBER;
   i NUMBER;

     /*Bug 2335580 */

   l_assignment_start_date    pa_schedules.start_date%TYPE;
   l_assignment_end_date      pa_schedules.end_date%TYPE;
   l_assignment_calendar_id   pa_schedules.calendar_id%TYPE;

   CURSOR CUR_ASSIGNMENT_SCHEDULE(x_assignment_id IN NUMBER) IS
   SELECT calendar_id, min(start_date), max(end_date)
   FROM PA_SCHEDULES
   WHERE  assignment_id = x_assignment_id
   AND schedule_type_code='OPEN_ASSIGNMENT'
   GROUP BY Calendar_id;


BEGIN
	 l_st_dt_done      := FALSE;
	 l_end_dt_done     := FALSE;
	 l_x_sch_copy_done := FALSE;
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Bug - 1846658-  Following lines are commented to incorporate the BULK SELECT to enhance the performance*/

--	 FOR v_c1 IN C1 LOOP
--			l_curr_schedule_rec(1).assignment_id           := v_c1.assignment_id;
--			l_curr_schedule_rec(1).project_id              := v_c1.project_id;
--			l_curr_schedule_rec(1).schedule_type_code      := v_c1.schedule_type_code;
--			l_curr_schedule_rec(1).assignment_status_code  := v_c1.status_code;
--			l_curr_schedule_rec(1).system_status_code      := v_c1.system_status_code;
--			l_curr_schedule_rec(1).calendar_id             := v_c1.calendar_id;
--			l_curr_schedule_rec(1).schedule_id             := v_c1.schedule_id;
--			l_curr_schedule_rec(1).start_date              := v_c1.start_date;
--			l_curr_schedule_rec(1).end_date                := v_c1.end_date;
--			l_curr_schedule_rec(1).Monday_hours            := v_c1.Monday_hours;
--			l_curr_schedule_rec(1).Tuesday_hours           := v_c1.Tuesday_hours;
--			l_curr_schedule_rec(1).Wednesday_hours         := v_c1.Wednesday_hours;
--			l_curr_schedule_rec(1).Thursday_hours          := v_c1.Thursday_hours;
--			l_curr_schedule_rec(1).Friday_hours            := v_c1.Friday_hours;
--			l_curr_schedule_rec(1).Saturday_hours          := v_c1.Saturday_hours;
--			l_curr_schedule_rec(1).Sunday_hours            := v_c1.Sunday_hours;

/*BUG 2335580 */

  OPEN CUR_ASSIGNMENT_SCHEDULE (p_assignment_id);
  FETCH cur_assignment_schedule INTO l_assignment_calendar_id,l_assignment_start_date, l_assignment_end_date;
  CLOSE cur_assignment_schedule;


/* Bug - 1846658-  Following lines are added to incorporate the BULK SELECT to enhance the performance*/

	SELECT   	schedule_id,
			calendar_id,
			assignment_id,
			project_id,
			schedule_type_code,
			status_code,
			system_status_code,
			start_date,
			end_date,
			Monday_hours,
			Tuesday_hours,
			Wednesday_hours,
			Thursday_hours,
			Friday_hours,
			Saturday_hours,
			Sunday_hours
	BULK COLLECT INTO
			l_schedule_id_tbl,
			l_calendar_id_tbl,
			l_assignment_id_tbl,
			l_project_id_tbl,
			l_schedule_type_code_tbl,
			l_status_code_tbl ,
			l_system_status_code_tbl,
			l_start_date_tbl,
			l_end_date_tbl,
			l_Monday_hours_tbl,
			l_Tuesday_hours_tbl,
			l_Wednesday_hours_tbl,
			l_Thursday_hours_tbl,
			l_Friday_hours_tbl,
			l_Saturday_hours_tbl,
 			l_Sunday_hours_tbl
	FROM     PA_SCHEDULES_V sch
	WHERE    sch.assignment_id = p_assignment_id
	AND      sch.schedule_type_code IN
	('OPEN_ASSIGNMENT','STAFFED_ASSIGNMENT', 'STAFFED_ADMIN_ASSIGNMENT')
	AND      ( ( p_start_date BETWEEN sch.start_date AND sch.end_date)
	OR       ( p_end_date   BETWEEN sch.start_date AND sch.end_date)
	OR       ( p_start_date < sch.start_date AND p_end_date > sch.end_date) )
	ORDER BY start_date;

  l_first_index := NVL(l_schedule_id_tbl.first,0);
  l_last_index := NVL(l_schedule_id_tbl.last,-1);

  FOR i IN l_first_index .. l_last_index LOOP
			l_curr_schedule_rec(1).assignment_id           := l_assignment_id_tbl(i);
			l_curr_schedule_rec(1).project_id              := l_project_id_tbl(i);
			l_curr_schedule_rec(1).schedule_type_code      := l_schedule_type_code_tbl(i);
			l_curr_schedule_rec(1).assignment_status_code  := l_status_code_tbl(i);
			l_curr_schedule_rec(1).system_status_code      := l_system_status_code_tbl(i);
			l_curr_schedule_rec(1).calendar_id             := l_calendar_id_tbl(i);
			l_curr_schedule_rec(1).schedule_id             := l_schedule_id_tbl(i);
			l_curr_schedule_rec(1).start_date              := l_start_date_tbl(i);
			l_curr_schedule_rec(1).end_date                := l_end_date_tbl(i);
			l_curr_schedule_rec(1).Monday_hours            := l_Monday_hours_tbl(i);
			l_curr_schedule_rec(1).Tuesday_hours           := l_Tuesday_hours_tbl(i);
			l_curr_schedule_rec(1).Wednesday_hours         := l_Wednesday_hours_tbl(i);
			l_curr_schedule_rec(1).Thursday_hours          := l_Thursday_hours_tbl(i);
			l_curr_schedule_rec(1).Friday_hours            := l_Friday_hours_tbl(i);
			l_curr_schedule_rec(1).Saturday_hours          := l_Saturday_hours_tbl(i);
			l_curr_schedule_rec(1).Sunday_hours            := l_Sunday_hours_tbl(i);

			-- The passing start date if greater than the existing end date of the schedule or
			-- greater or equal to the existing start date
			IF (p_start_date > l_curr_schedule_rec(1).end_date) AND (l_st_dt_done = FALSE) THEN
				 NULL;
			ELSE
				 IF (p_start_date = l_curr_schedule_rec(1).start_date) AND ( l_st_dt_done = FALSE) THEN
						l_st_dt_done := TRUE;
				 ELSIF ( p_start_date > l_curr_schedule_rec(1).start_date ) AND (l_st_dt_done = FALSE) THEN
						l_curr_schedule_rec(1).start_date := p_start_date;
						l_st_dt_done:= TRUE;
				 END IF;

				 -- The passing end date if less than or equal to the existing end date of the
				 -- schedule or greater than the existing end date
				 IF ((p_end_date <= l_curr_schedule_rec(1).end_date) AND (l_end_dt_done = FALSE))  THEN
						l_curr_schedule_rec(1).end_date := p_end_date;
						l_end_dt_done:= TRUE;
				 ELSIF (p_end_date > l_curr_schedule_rec(1).end_date ) AND (l_end_dt_done = FALSE) THEN
						NULL;
				 END IF;

				 -- Appending records in  l_out_schedule_rec
				 PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_curr_schedule_rec,1,1,l_out_schedule_rec,
					 l_x_return_status,x_msg_count,x_msg_data);

 				 IF (l_st_dt_done = TRUE ) AND  (l_end_dt_done = TRUE) THEN
						EXIT;
				 END IF;
			END IF;

	 END LOOP;

	 -- If the calendar has schedule record in the table then the following processing will occur
	 IF ( l_out_schedule_rec.count > 0 ) THEN
			l_I := l_out_schedule_rec.first;
			l_J := l_out_schedule_rec.Last;
			-- If the start date is falling before the start date of the schedule then its work patern will be 0
			IF (p_start_date < l_out_schedule_rec(l_I).start_date) THEN

                                 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                                                PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,
                                                                                        1,
                                                                                        1,
                                                                                        l_temp_schedule_rec,
                                                                                        l_x_return_status,
                                                                                        x_msg_count,
                                                                                        x_msg_data);
                                 END IF;

                                 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
/*bug 2335580 */
                                      IF l_assignment_calendar_id IS NOT NULL THEN

                                          PA_Schedule_Pvt.get_calendar_schedule(l_assignment_calendar_id,
                                                                                p_start_date,
                                                                                l_out_schedule_rec(l_I).start_date-1,
                                                                                l_temp_schedule_rec,
                                                                                l_x_return_status,
                                                                                x_msg_count,
                                                                                x_msg_data);
                                      ELSE
                                          PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,
                                                                             p_start_date =>p_start_date,
                                                                             p_end_date =>l_out_schedule_rec(l_I).start_date -1,
                                                                             p_monday_hours =>0.00,
                                                                             p_tuesday_hours =>0.00,
                                                                             p_wednesday_hours =>0.00,
                                                                             p_thursday_hours =>0.00,
                                                                             p_friday_hours =>0.00,
                                                                             p_saturday_hours =>0.00,
                                                                             p_sunday_hours =>0.00,
                                                                             x_return_status => l_x_return_status,
                                                                             x_msg_count => x_msg_count,
                                                                             x_msg_data =>x_msg_data);

                                      END IF; --l_calendar_id is not null
                                 END IF;

                                 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                                                PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,
                                                                                       l_temp_schedule_rec.first, -- changed for bug 7713013
                                                                                       l_temp_schedule_rec.last,  -- changed for bug 7713013
                                                                                       x_sch_record_tab,
                                                                                       l_x_return_status,
                                                                                       x_msg_count,
                                                                                       x_msg_data);
                                 END IF;


                                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                                                PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,
                                                                                       l_out_schedule_rec.first,
                                                                                       l_out_schedule_rec.last,
                                                                                       x_sch_record_tab,
                                                                                       l_x_return_status,
                                                                                       x_msg_count,
                                                                                       x_msg_data);
                                 END IF;


				 l_x_sch_copy_done := TRUE;
			END IF;

			-- If the end  date is falling after the end date of the schedule then its work patern will be 0
			IF (p_end_date > l_out_schedule_rec(l_J).end_date) THEN

                                 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                                                PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,
                                                                                        1,
                                                                                        1,
                                                                                        l_temp_schedule_rec,
                                                                                        l_x_return_status,
                                                                                        x_msg_count,
                                                                                        x_msg_data);
                                 END IF;

   /*Code added for bug 2335580 */
                        IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                               IF l_assignment_calendar_id IS NOT NULL THEN

                                          PA_Schedule_Pvt.get_calendar_schedule(l_assignment_calendar_id,
                                                                                l_out_schedule_rec(l_J).end_date+1,
                                                                                p_end_date,
                                                                                l_temp_schedule_rec,
                                                                                l_x_return_status,
                                                                                x_msg_count,
                                                                                x_msg_data);
/*End of code for Bug 2335580 */
                                 ELSE

                                      PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,
                                                                           p_start_date =>l_out_schedule_rec(l_J).end_date + 1,
                                                                           p_end_date => p_end_date,
                                                                           p_monday_hours =>0.00,
                                                                           p_tuesday_hours =>0.00,
                                                                           p_wednesday_hours =>0.00,
                                                                           p_thursday_hours =>0.00,
                                                                           p_friday_hours =>0.00,
                                                                           p_saturday_hours =>0.00,
                                                                           p_sunday_hours =>0.00,
                                                                           x_return_status => l_x_return_status,
                                                                           x_msg_count => x_msg_count,
                                                                           x_msg_data =>x_msg_data);
                                 END IF; --l_assignment_calendar_id is not null
                               END IF;


                                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS AND l_x_sch_copy_done <> TRUE ) THEN
                                                PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,
                                                                                       l_out_schedule_rec.first,
                                                                                       l_out_schedule_rec.last,
                                                                                       x_sch_record_tab,
                                                                                       l_x_return_status,
                                                                                       x_msg_count,
                                                                                       x_msg_data);
                                 END IF;

                                 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                                                PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,
                                                                                       l_temp_schedule_rec.FIRST , --1,Modified  for bug 4504473/4375409
                                                                                       l_temp_schedule_rec.Last ,  --1,Modified for bug 4504473/4375409
                                                                                       x_sch_record_tab,
                                                                                       l_x_return_status,
                                                                                       x_msg_count,
                                                                                        x_msg_data);
                                 END IF;

				 l_x_sch_copy_done := TRUE;
			END IF;
	 ELSE
			-- If the pased calendar des not have any schedule then default schedule is created
			x_sch_record_tab(1).start_date      := p_start_date;
			x_sch_record_tab(1).end_date        := p_end_date ;
			x_sch_record_tab(1).monday_hours    := 0.00;
			x_sch_record_tab(1).tuesday_hours   := 0.00;
			x_sch_record_tab(1).wednesday_hours := 0.00;
			x_sch_record_tab(1).thursday_hours  := 0.00;
			x_sch_record_tab(1).friday_hours    := 0.00;
			x_sch_record_tab(1).saturday_hours  := 0.00;
			x_sch_record_tab(1).sunday_hours    := 0.00;

	 END IF;

	 IF l_x_sch_copy_done = FALSE  THEN
                         IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                                 PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,
                                                                         l_out_schedule_rec.first,
                                                                         l_out_schedule_rec.last,
                                                                         x_sch_record_tab,
                                                                         l_x_return_status,
                                                                         x_msg_count,
                                                                         x_msg_data);
                        END IF;

	 END IF;

	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'get_assignment_schedule');
		 raise;

END get_assignment_schedule;

-- This procedure will take only assignment id and then generate the schedule for that assignment
-- In this procedure the schedule will be just the same as in the schedule tabel means no start date is passed
-- or end date is passed so it will pick only those records.This is an overloaded procedure.
-- Input parameters
-- Parameters                   Type               Required  Description
-- P_Assignment_Id              NUMBER             YES       Id for that assignment to which you want to get schedule
--
-- Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP     YES       It stores  schedule for that assignment
--

PROCEDURE get_assignment_schedule ( p_assignment_id        IN   NUMBER,
						x_sch_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
						x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
						x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
						x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 I                        NUMBER;
	 J                        NUMBER;
	 l_st_dt_done             BOOLEAN;
	 l_end_dt_done            BOOLEAN;
	 l_x_sch_copy_done        BOOLEAN;
	 l_curr_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_out_schedule_rec       PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;

	 -- This cursor will select the schedule records corresponding to the passing assignment id
   -- 1561861 Added 'STAFFED_ADMIN_ASSIGNMENT' to the where clause.
/* Bug - 1846658-  Following lines are commented to incorporate the BULK SELECT to enhance the performance*/

--	 CURSOR C1 IS SELECT    schedule_id, calendar_id,
--		 assignment_id,project_id,schedule_type_code,status_code,
--		 system_status_code,start_date,end_date,Monday_hours,Tuesday_hours,Wednesday_hours,
--		 Thursday_hours,
--		 Friday_hours,Saturday_hours,Sunday_hours
--		 FROM     PA_SCHEDULES_V sch
--		 WHERE    sch.assignment_id = p_assignment_id
--		 AND      sch.schedule_type_code IN
--		 ('OPEN_ASSIGNMENT','STAFFED_ASSIGNMENT', 'STAFFED_ADMIN_ASSIGNMENT')
--		 ORDER BY start_date;

/* Bug - 1846658-  Following lines are added to incorporate the BULK SELECT to enhance the performance*/

   TYPE schedule_id_tbl IS TABLE OF PA_SCHEDULES_V.schedule_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE calendar_id_tbl IS TABLE OF PA_SCHEDULES_V.calendar_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE assignment_id_tbl IS TABLE OF PA_SCHEDULES_V.assignment_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE project_id_tbl IS TABLE OF PA_SCHEDULES_V.project_id%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE schedule_type_code_tbl IS TABLE OF PA_SCHEDULES_V.schedule_type_code%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE status_code_tbl IS TABLE OF PA_SCHEDULES_V.status_code%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE system_status_code_tbl IS TABLE OF PA_SCHEDULES_V.system_status_code%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE start_date_tbl IS TABLE OF PA_SCHEDULES_V.start_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE end_date_tbl IS TABLE OF PA_SCHEDULES_V.end_date%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Monday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Monday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Tuesday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Tuesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Wednesday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Wednesday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Thursday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Thursday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Friday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Friday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Saturday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Saturday_hours%TYPE
     INDEX BY BINARY_INTEGER;
   TYPE Sunday_hours_tbl IS TABLE OF PA_SCHEDULES_V.Sunday_hours%TYPE
     INDEX BY BINARY_INTEGER;

   l_schedule_id_tbl		schedule_id_tbl ;
   l_calendar_id_tbl		calendar_id_tbl ;
   l_assignment_id_tbl		assignment_id_tbl;
   l_project_id_tbl		project_id_tbl;
   l_schedule_type_code_tbl	schedule_type_code_tbl;
   l_status_code_tbl		status_code_tbl    ;
   l_system_status_code_tbl	system_status_code_tbl;
   l_start_date_tbl		start_date_tbl ;
   l_end_date_tbl			end_date_tbl ;
   l_Monday_hours_tbl		Monday_hours_tbl ;
   l_Tuesday_hours_tbl		Tuesday_hours_tbl;
   l_Wednesday_hours_tbl	Wednesday_hours_tbl ;
   l_Thursday_hours_tbl		Thursday_hours_tbl;
   l_Friday_hours_tbl		Friday_hours_tbl  ;
   l_Saturday_hours_tbl		Saturday_hours_tbl ;
   l_Sunday_hours_tbl		Sunday_hours_tbl ;

   l_first_index NUMBER;
   l_last_index NUMBER;
   i NUMBER;

BEGIN
	 l_st_dt_done      := FALSE;
	 l_end_dt_done     := FALSE;
	 l_x_sch_copy_done := FALSE;
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Bug - 1846658-  Following lines are commented to incorporate the BULK SELECT to enhance the performance*/

--	 FOR v_c1 IN C1 LOOP
--
--			l_curr_schedule_rec(1).assignment_id           := v_c1.assignment_id;
--			l_curr_schedule_rec(1).project_id              := v_c1.project_id;
--			l_curr_schedule_rec(1).schedule_type_code      := v_c1.schedule_type_code;
--			l_curr_schedule_rec(1).assignment_status_code  := v_c1.status_code;
--			l_curr_schedule_rec(1).system_status_code      := v_c1.system_status_code;
--			l_curr_schedule_rec(1).calendar_id             := v_c1.calendar_id;
--			l_curr_schedule_rec(1).schedule_id             := v_c1.schedule_id;
--			l_curr_schedule_rec(1).start_date              := v_c1.start_date;
--			l_curr_schedule_rec(1).end_date                := v_c1.end_date;
--			l_curr_schedule_rec(1).Monday_hours            := v_c1.Monday_hours;
--			l_curr_schedule_rec(1).Tuesday_hours           := v_c1.Tuesday_hours;
--			l_curr_schedule_rec(1).Wednesday_hours         := v_c1.Wednesday_hours;
--			l_curr_schedule_rec(1).Thursday_hours          := v_c1.Thursday_hours;
--			l_curr_schedule_rec(1).Friday_hours            := v_c1.Friday_hours;
--			l_curr_schedule_rec(1).Saturday_hours          := v_c1.Saturday_hours;
--			l_curr_schedule_rec(1).Sunday_hours            := v_c1.Sunday_hours;


/* Bug - 1846658-  Following lines are added to incorporate the BULK SELECT to enhance the performance*/

	SELECT   	schedule_id,
			calendar_id,
			assignment_id,
			project_id,
			schedule_type_code,
			status_code,
			system_status_code,
			start_date,
			end_date,
			Monday_hours,
			Tuesday_hours,
			Wednesday_hours,
			Thursday_hours,
			Friday_hours,
			Saturday_hours,
			Sunday_hours
	BULK COLLECT INTO
			l_schedule_id_tbl,
			l_calendar_id_tbl,
			l_assignment_id_tbl,
			l_project_id_tbl,
			l_schedule_type_code_tbl,
			l_status_code_tbl ,
			l_system_status_code_tbl,
			l_start_date_tbl,
			l_end_date_tbl,
			l_Monday_hours_tbl,
			l_Tuesday_hours_tbl,
			l_Wednesday_hours_tbl,
			l_Thursday_hours_tbl,
			l_Friday_hours_tbl,
			l_Saturday_hours_tbl,
 			l_Sunday_hours_tbl
	FROM     PA_SCHEDULES_V sch
	WHERE    sch.assignment_id = p_assignment_id
	AND      sch.schedule_type_code IN ('OPEN_ASSIGNMENT','STAFFED_ASSIGNMENT', 'STAFFED_ADMIN_ASSIGNMENT')
	ORDER BY start_date;

  l_first_index := NVL(l_project_id_tbl.first,0);
  l_last_index := NVL(l_project_id_tbl.last,-1);

   FOR i IN l_first_index .. l_last_index LOOP
			l_curr_schedule_rec(1).assignment_id           := l_assignment_id_tbl(i);
			l_curr_schedule_rec(1).project_id              := l_project_id_tbl(i);
			l_curr_schedule_rec(1).schedule_type_code      := l_schedule_type_code_tbl(i);
			l_curr_schedule_rec(1).assignment_status_code  := l_status_code_tbl(i);
			l_curr_schedule_rec(1).system_status_code      := l_system_status_code_tbl(i);
			l_curr_schedule_rec(1).calendar_id             := l_calendar_id_tbl(i);
			l_curr_schedule_rec(1).schedule_id             := l_schedule_id_tbl(i);
			l_curr_schedule_rec(1).start_date              := l_start_date_tbl(i);
			l_curr_schedule_rec(1).end_date                := l_end_date_tbl(i);
			l_curr_schedule_rec(1).Monday_hours            := l_Monday_hours_tbl(i);
			l_curr_schedule_rec(1).Tuesday_hours           := l_Tuesday_hours_tbl(i);
			l_curr_schedule_rec(1).Wednesday_hours         := l_Wednesday_hours_tbl(i);
			l_curr_schedule_rec(1).Thursday_hours          := l_Thursday_hours_tbl(i);
			l_curr_schedule_rec(1).Friday_hours            := l_Friday_hours_tbl(i);
			l_curr_schedule_rec(1).Saturday_hours          := l_Saturday_hours_tbl(i);
			l_curr_schedule_rec(1).Sunday_hours            := l_Sunday_hours_tbl(i);

			-- appending the record
			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_curr_schedule_rec,1,1,l_out_schedule_rec,l_x_return_status,
				x_msg_count,x_msg_data);
      END IF;

	 END LOOP;

	 IF l_x_sch_copy_done = FALSE  THEN

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
					 x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
			END IF;
	 END IF;

	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN

		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'get_assignment_schedule');
		 raise;

END get_assignment_schedule;

-- This procedure will get the resource schedule if the calendar type is resource it will pick its
-- schedule from the CRM calendar which is associated with this resource
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Source_Id                  NUMBER         YES       Source Id for getting the crm resource id
-- P_Source_Type                VARCHAR2       YES       It is the type of the source e.g PA_PROJECT_PARTY_ID,
--                                                       PA_RESOURCE_ID
-- P_Start_Date                 DATE           YES       Start date of the schedule for that resource
-- P_End_Date                   DATE           YES       End date of the schedule for that resource
--
-- Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP YES       It stores  schedule for that resource
--
PROCEDURE get_resource_schedule (	p_source_id              IN       NUMBER,
						p_source_type            IN       VARCHAR2,
						p_start_date             IN       DATE,
						p_end_date               IN       DATE,
						x_sch_record_tab         IN OUT   NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
						x_return_status          OUT      NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
						x_msg_count              OUT      NOCOPY NUMBER, --File.Sql.39 bug 4440895
						x_msg_data               OUT      NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_I                      NUMBER;
	 l_J                      NUMBER;
	 l_t_resource_id          NUMBER;
	 l_st_dt_done             BOOLEAN;
	 l_end_dt_done            BOOLEAN;
	 l_x_sch_copy_done        BOOLEAN;
	 l_t_first_record         BOOLEAN;
	 l_last_end_date          DATE;
	 l_t_end_date             DATE;
	 l_t_start_date           DATE;
	 l_temp_end_date          DATE;
	 l_temp_start_date        DATE;
	 l_tc_end_date            DATE;
	 l_tc_start_date          DATE;

	 l_invalid_source_id      EXCEPTION;

	 l_cur_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_out_schedule_rec      PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_schedule_rec     PA_SCHEDULE_GLOB.ScheduleTabTyp;

   -- jmarques: 1786935: Modified cursor to include resource_type_code
   -- since resource_id is not unique. Also, added calendar_id > 0
   -- condition so that calendar_id, resource_id index would be used.

	 CURSOR C1 IS SELECT  calendar_id,trunc(start_date_time) start_date,
		 NVL(trunc(end_date_time),TO_DATE('01/01/2050','MM/DD/YYYY')) end_date
		 FROM    jtf_cal_resource_assign jtf_res
		 WHERE   jtf_res.resource_id = l_t_resource_id
		 AND     jtf_res.primary_calendar_flag = 'Y'
     AND     jtf_res.calendar_id > 0
     AND     jtf_res.resource_type_code = 'RS_EMPLOYEE'
		 AND     ( ( l_tc_start_date BETWEEN trunc(jtf_res.start_date_time) AND
		 nvl(trunc(jtf_res.end_date_time),l_tc_end_date))
		 OR      ( l_tc_end_date   BETWEEN jtf_res.start_date_time AND
		 nvl(trunc(jtf_res.end_date_time),l_tc_end_date))
		 OR      ( l_tc_start_date < jtf_res.start_date_time AND
		 l_tc_end_date > nvl(trunc(jtf_res.end_date_time),l_tc_end_date)) )
		 order by start_date;

/*Code Added for bug 2687043 */

      Cursor cur_organization(x_prm_resource_id IN NUMBER) IS
      select resource_organization_id, min(resource_effective_start_date)
        from pa_resources_denorm
        where resource_id = x_prm_resource_id
        group by resource_organization_id;

/*Code ends for bug 2687043 */

    -- jmarques: 1965289: local vars
    l_prm_resource_id        NUMBER;
    l_resource_organization_id  NUMBER;
    l_resource_ou_id         NUMBER;
    l_calendar_id            NUMBER;

    -- jmarques: 2196924: local vars
	 l_ResStartDateTab PA_FORECAST_GLOB.DateTabTyp;
	 l_ResEndDateTab PA_FORECAST_GLOB.DateTabTyp;
	 i NUMBER;
	 l_Sch_Record_Tab PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_cap_start_date DATE;
	 l_cap_end DATE;
	 l_cap_start_index NUMBER;
	 l_cap_end_index NUMBER;
	 l_res_start_date DATE;
	 l_res_end DATE;
	 l_res_start_index NUMBER;
	 l_res_end_index NUMBER;
	 l_cap_first_start_date DATE;
	 l_cap_last_end_date DATE;
	 l_prev_res_end_date DATE;
	 l_last_processed_cap_index NUMBER;
	 l_cap_tab_index NUMBER;
	 l_res_first_start_date DATE;
	 l_res_last_end_date DATE;
	 l_hole_start_date DATE;
	 l_hole_end_date DATE;
	 l_reprocess_flag VARCHAR2(1);
   l_j_index NUMBER;
	 l_temp_index NUMBER;
   l_resource_id NUMBER;

BEGIN
	 l_st_dt_done      := FALSE;
	 l_end_dt_done     := FALSE;
	 l_x_sch_copy_done := FALSE;
	 l_t_first_record  := FALSE;
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;
	 PA_SCHEDULE_UTILS.log_message(1,'first status ... '||l_x_return_status);


	 IF ( p_source_type = 'PA_PROJECT_PARTY_ID')  THEN
      BEGIN
      select distinct NVL(resource_id,-99)
      into l_resource_id
      from pa_project_parties
      where project_party_id = p_source_id;
      EXCEPTION WHEN NO_DATA_FOUND THEN
        l_resource_id := -99;
      END;

			-- Calling resource API that will return the resource id
      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_RESOURCE_UTILS.get_crm_res_id( p_project_player_id  => p_source_id,
				p_resource_id        => NULL,
				x_jtf_resource_id    => l_t_resource_id,
				x_return_status      => l_x_return_status,
				x_error_message_code => x_msg_data );
      PA_SCHEDULE_UTILS.log_message(1,'status ... '||l_x_return_status);
      PA_SCHEDULE_UTILS.log_message(1,'get_crm_res_id');

			END IF;
	 ELSIF ( p_source_type = 'PA_RESOURCE_ID')  THEN
      l_resource_id := p_source_id;
			-- Calling resource API That will return the resource id
      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      PA_RESOURCE_UTILS.get_crm_res_id( p_project_player_id  => NULL,
				p_resource_id         => p_source_id,
				x_jtf_resource_id     => l_t_resource_id,
				x_return_status       => l_x_return_status,
				x_error_message_code  => x_msg_data );
      PA_SCHEDULE_UTILS.log_message(1,'status ... '||l_x_return_status);
      PA_SCHEDULE_UTILS.log_message(1,'get_crm_res_id2');
      END IF;
			PA_SCHEDULE_UTILS.log_message(1,'second status ... '||l_x_return_status);
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'second status ... '||l_x_return_status);
	 IF ( l_x_return_status <> fnd_api.g_ret_sts_success ) THEN
			RAISE l_invalid_source_id;
	 END IF;
	 PA_SCHEDULE_UTILS.log_message(1,'status ... '||l_x_return_status);

   -- 1965289: Work around for CRM bug (cannot create future dated resources).
   -- If the jtf_resource_id is null, then we need to use the default
   -- calendar instead of going to the jtf_cal_resource_assign table.

   -- Start 1965289 bugfix.
   IF (l_t_resource_id is null) THEN
      -- Find the start date for the first HR assignment.
	    IF ( p_source_type = 'PA_PROJECT_PARTY_ID')  THEN
         select resource_id
         into l_prm_resource_id
         from pa_project_parties
         where project_party_id = p_source_id;
	    ELSIF ( p_source_type = 'PA_RESOURCE_ID')  THEN
         l_prm_resource_id := p_source_id;
      END IF;

      -- Get resource's organization on their
      -- min(resource_effective_start_date)

/*  Code added for bug 2687043 */
    OPEN  cur_organization(l_prm_resource_id);
    FETCH cur_organization INTO l_resource_organization_id,l_temp_start_date;
    CLOSE cur_organization;

/*The below code is commented for bug 2687043

      select resource_organization_id, resource_effective_start_date
      into l_resource_organization_id, l_temp_start_date
      from pa_resources_denorm
      where resource_effective_start_date =
        (select min(res1.resource_effective_start_date)
         from pa_resources_denorm res1
         where res1.resource_id = l_prm_resource_id
         and res1.resource_effective_start_date >= trunc(sysdate))
      and resource_id = l_prm_resource_id;

*/

      -- Get default calendar using organization id.
      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        pa_resource_utils.get_org_defaults(
           p_organization_id => l_resource_organization_id,
           x_default_ou => l_resource_ou_id,
           x_default_cal_id =>  l_calendar_id,
           x_return_status => l_x_return_status);
      PA_SCHEDULE_UTILS.log_message(1,'l_resource_organization_id: '||l_resource_organization_id);
      PA_SCHEDULE_UTILS.log_message(1,'status ... '||l_x_return_status);
      PA_SCHEDULE_UTILS.log_message(1,'get_org_defaults');
      END IF;

      if (l_calendar_id is null) then
         l_calendar_id := fnd_profile.value_specific('PA_PRM_DEFAULT_CALENDAR');
      end if;

      -- Fix dates.

      -- l_temp_start_date found above.
      l_temp_end_date := to_date('31/12/4712', 'DD/MM/YYYY');

	    IF (p_start_date IS NULL OR p_start_date < l_temp_start_date) THEN
			   l_tc_start_date := l_temp_start_date;
	    ELSE
			   l_tc_start_date := p_start_date;
	    END IF;

	    IF (p_end_date IS NULL) THEN
			   l_tc_end_date := l_temp_end_date;
	    ELSE
			   l_tc_end_date := p_end_date;
	    END IF;

		  -- Calling the get calendar schedule procedure which will bring
      -- the schedule  for the specified calendar id
		  IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
        get_calendar_schedule(l_calendar_id,
					 l_tc_start_date,
					 l_tc_end_date,
					 l_cur_schedule_rec,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data);
      PA_SCHEDULE_UTILS.log_message(1,'status ... '||l_x_return_status);
      PA_SCHEDULE_UTILS.log_message(1,'get_calendar_schedule');
      END IF;

      IF (p_start_date is not null) then
         l_tc_start_date := p_start_date;
      END IF;

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
         PA_SCHEDULE_UTILS.add_schedule_rec_tab(
           l_cur_schedule_rec,
           l_cur_schedule_rec.first,
					 l_cur_schedule_rec.last,
           l_out_schedule_rec,
           l_x_return_status,
           x_msg_count,
					 x_msg_data);
      PA_SCHEDULE_UTILS.log_message(1,'status ... '||l_x_return_status);
      PA_SCHEDULE_UTILS.log_message(1,'add_schedule_rec_tab');
     END IF;

---- Start: Copied from below (same processing for work around)
   	  IF ( l_out_schedule_rec.count > 0 ) THEN
   			 l_I := l_out_schedule_rec.first;
   			 l_J := l_out_schedule_rec.Last;

			   IF (l_tc_start_date < l_out_schedule_rec(l_I).start_date) THEN

    		 	  IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
   						PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,1,1,l_temp_schedule_rec,l_x_return_status,x_msg_count,
   							x_msg_data);
    				 END IF;

    				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    						PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,p_start_date =>l_tc_start_date,
    							p_end_date =>l_out_schedule_rec(l_I).start_date -1 ,p_monday_hours =>0.00,p_tuesday_hours =>0.00,
    							p_wednesday_hours =>0.00,p_thursday_hours =>0.00,p_friday_hours =>0.00,p_saturday_hours =>0.00,
    							p_sunday_hours =>0.00,x_return_status => l_x_return_status,x_msg_count => x_msg_count,x_msg_data =>x_msg_data);
    				 END IF;

    				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    						PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,1,1,x_sch_record_tab,l_x_return_status,x_msg_count,
    							x_msg_data);
    				 END IF;

    				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    						PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
    							x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
    				 END IF;

    				 l_x_sch_copy_done := TRUE;
    				 --PA_SCHEDULE_UTILS.log_message(2,'X1  :',x_sch_record_tab);
    			END IF;

    			IF (l_tc_end_date > l_out_schedule_rec(l_J).end_date) THEN

	    			 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    						PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,1,1,l_temp_schedule_rec,l_x_return_status,x_msg_count,
    							x_msg_data);
    				 END IF;

    				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    						PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,
    							p_start_date =>l_out_schedule_rec(l_J).end_date + 1 , p_end_date => l_tc_end_date,p_monday_hours =>0.00,
    							p_tuesday_hours =>0.00, p_wednesday_hours =>0.00,p_thursday_hours =>0.00,p_friday_hours =>0.00,
    							p_saturday_hours =>0.00,p_sunday_hours =>0.00,
    							x_return_status => l_x_return_status,x_msg_count => x_msg_count,x_msg_data =>x_msg_data);
    				 END IF;

    				 IF ( l_x_sch_copy_done = FALSE ) THEN
    						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    							 PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
    								 x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
    						END IF;

    				 END IF;

    				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    						PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,1,1,x_sch_record_tab,l_x_return_status,x_msg_count,
    							x_msg_data);
    				 END IF;

    				 l_x_sch_copy_done := TRUE;
    				 --PA_SCHEDULE_UTILS.log_message(2,'X2  :',x_sch_record_tab);
    			END IF;

    			IF l_x_sch_copy_done = FALSE  THEN

    				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
    						PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
    							x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
    				 END IF;
    			END IF;
    	 ELSE
    			x_sch_record_tab(1).start_date      := l_tc_start_date;
    			x_sch_record_tab(1).end_date        := l_tc_end_date ;
    			x_sch_record_tab(1).monday_hours    := 0.00;
    			x_sch_record_tab(1).tuesday_hours   := 0.00;
    			x_sch_record_tab(1).wednesday_hours := 0.00;
    			x_sch_record_tab(1).thursday_hours  := 0.00;
    			x_sch_record_tab(1).friday_hours    := 0.00;
    			x_sch_record_tab(1).saturday_hours  := 0.00;
    			x_sch_record_tab(1).sunday_hours    := 0.00;
    	 END IF;
   -- End: Copied from below (same processing for work around)
   -- End 1965289 bug fix.

   ELSE

   	   -- Taking care if the passing start or end date is null if the dates are null take the value from table
   		 IF (p_start_date IS NULL OR p_end_date IS NULL) THEN
   	      -- jmarques: 1786935: Modified cursor to include resource_type_code
   	      -- since resource_id is not unique. Also, added calendar_id > 0
    	    -- condition so that calendar_id, resource_id index would be used.

   				SELECT  MIN(start_date_time),MAX(NVL(end_date_time,TO_DATE('01/01/2050','MM/DD/YYYY')))
   					INTO    l_temp_start_date,l_temp_end_date
   					FROM    jtf_cal_resource_assign
   					WHERE   jtf_cal_resource_assign.resource_id = l_t_resource_id
   	        AND     jtf_cal_resource_assign.calendar_id > 0
   	        AND     jtf_cal_resource_assign.resource_type_code = 'RS_EMPLOYEE'
   					AND     jtf_cal_resource_assign.primary_calendar_flag = 'Y';
   		 END IF;

   		 PA_SCHEDULE_UTILS.log_message(1,'Start date ... '||to_char(l_temp_start_date)||to_char(p_start_date));
   		 PA_SCHEDULE_UTILS.log_message(1,'end date  ... '||to_char(l_temp_end_date)||to_char(p_end_date));
   		 IF (p_start_date IS NULL ) THEN
   				l_tc_start_date := l_temp_start_date;
   		 ELSE
   				l_tc_start_date := p_start_date;
   		 END IF;

   		 IF (p_end_date IS NULL ) THEN
   				l_tc_end_date := l_temp_end_date;
	   	 ELSE
	   			l_tc_end_date := p_end_date;
	   	 END IF;


	   	 PA_SCHEDULE_UTILS.log_message(1,'Start of the get_resource_schedule API ... ');


	   	 FOR v_c1 IN C1 LOOP

	   			PA_SCHEDULE_UTILS.log_message(1,'inside cursor ... ');

	   			PA_SCHEDULE_UTILS.log_message(2,'REC : '||to_char(v_c1.calendar_id)|| ' '||
	   				to_char(v_c1.start_date)||'  '||
	   				to_char(v_c1.end_date));


	   			IF( l_t_first_record) THEN
	   				 l_t_first_record := FALSE;
	   			ELSIF( v_c1.start_date <> (l_last_end_date + 1) ) THEN
					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	   						PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_cur_schedule_rec,1,1,
								l_temp_schedule_rec,l_x_return_status,x_msg_count,x_msg_data);
					 END IF;

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,
								p_start_date =>l_last_end_date + 1, p_end_date =>v_c1.start_date -1 ,
								p_monday_hours =>0.00,p_tuesday_hours =>0.00,p_wednesday_hours =>0.00,
								p_thursday_hours =>0.00,p_friday_hours =>0.00,p_saturday_hours =>0.00,
									p_sunday_hours =>0.00,
									x_return_status => l_x_return_status,x_msg_count =>
									x_msg_count,x_msg_data =>x_msg_data);
					 END IF;
					 --PA_SCHEDULE_UTILS.log_message(2,'TEMP :',l_temp_schedule_rec);

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							-- Appending the records
							PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,1,1,
								l_out_schedule_rec,l_x_return_status,x_msg_count,x_msg_data);
					 END IF;
				END IF;

				l_cur_schedule_rec.delete;

				PA_SCHEDULE_UTILS.log_message(2,'in deleting CUR '||l_x_return_status);
				IF ( v_c1.end_date > l_tc_end_date ) THEN
					 l_t_end_date := l_tc_end_date;
				ELSE
					 l_t_end_date := v_c1.end_date;
				END IF;

				IF ( v_c1.start_date < l_tc_start_date ) THEN
					 l_t_start_date := l_tc_start_date;
				ELSE
					 l_t_start_date := v_c1.start_date;
					 PA_SCHEDULE_UTILS.log_message(2,'before get resource '||to_char(l_t_start_date,'dd-mon-yyyy'));
				END IF;

				PA_SCHEDULE_UTILS.log_message(2,'before get resource '||l_x_return_status);
				IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
					 -- Calling the get calendar schedule procedure which will bring the schedule  for the specified calendar id
					 get_calendar_schedule( v_c1.calendar_id,
						 l_t_start_date,
						 l_t_end_date,
						 l_cur_schedule_rec,
						 l_x_return_status,
						 x_msg_count,
						 x_msg_data);
					 PA_SCHEDULE_UTILS.log_message(2,'inside get calendar CUR :',l_cur_schedule_rec);
				END IF;
				PA_SCHEDULE_UTILS.log_message(2,'after get resource CUR :',l_cur_schedule_rec);

				IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
					 PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_cur_schedule_rec,l_cur_schedule_rec.first,
						 l_cur_schedule_rec.last,l_out_schedule_rec,l_x_return_status,x_msg_count,
						 x_msg_data);
				END IF;

				l_last_end_date := v_c1.end_date;

				PA_SCHEDULE_UTILS.log_message(2,'OUT :',l_out_schedule_rec);

		 END LOOP;

		 PA_SCHEDULE_UTILS.log_message(2,'OUTSIDE  loop :');

		 IF ( l_out_schedule_rec.count > 0 ) THEN
				l_I := l_out_schedule_rec.first;
				l_J := l_out_schedule_rec.Last;

				IF (l_tc_start_date < l_out_schedule_rec(l_I).start_date) THEN

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,1,1,l_temp_schedule_rec,l_x_return_status,x_msg_count,
								x_msg_data);
					 END IF;

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,p_start_date =>l_tc_start_date,
								p_end_date =>l_out_schedule_rec(l_I).start_date -1 ,p_monday_hours =>0.00,p_tuesday_hours =>0.00,
								p_wednesday_hours =>0.00,p_thursday_hours =>0.00,p_friday_hours =>0.00,p_saturday_hours =>0.00,
								p_sunday_hours =>0.00,x_return_status => l_x_return_status,x_msg_count => x_msg_count,x_msg_data =>x_msg_data);
					 END IF;

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,1,1,x_sch_record_tab,l_x_return_status,x_msg_count,
								x_msg_data);
					 END IF;

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
							x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
					 END IF;

					 l_x_sch_copy_done := TRUE;
					 --PA_SCHEDULE_UTILS.log_message(2,'X1  :',x_sch_record_tab);
				END IF;

				IF (l_tc_end_date > l_out_schedule_rec(l_J).end_date) THEN

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,1,1,l_temp_schedule_rec,l_x_return_status,x_msg_count,
							x_msg_data);
					 END IF;

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab => l_temp_schedule_rec,
								p_start_date =>l_out_schedule_rec(l_J).end_date + 1 , p_end_date => l_tc_end_date,p_monday_hours =>0.00,
								p_tuesday_hours =>0.00, p_wednesday_hours =>0.00,p_thursday_hours =>0.00,p_friday_hours =>0.00,
								p_saturday_hours =>0.00,p_sunday_hours =>0.00,
								x_return_status => l_x_return_status,x_msg_count => x_msg_count,x_msg_data =>x_msg_data);
					 END IF;

					 IF ( l_x_sch_copy_done = FALSE ) THEN
							IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
								 PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
									 x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
							END IF;

					 END IF;

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_schedule_rec,1,1,x_sch_record_tab,l_x_return_status,x_msg_count,
								x_msg_data);
					 END IF;

					 l_x_sch_copy_done := TRUE;
					 --PA_SCHEDULE_UTILS.log_message(2,'X2  :',x_sch_record_tab);
				END IF;

				IF l_x_sch_copy_done = FALSE  THEN

					 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_schedule_rec,l_out_schedule_rec.first,l_out_schedule_rec.last,
								x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
					 END IF;
				END IF;
		 ELSE
				x_sch_record_tab(1).start_date      := l_tc_start_date;
				x_sch_record_tab(1).end_date        := l_tc_end_date ;
				x_sch_record_tab(1).monday_hours    := 0.00;
				x_sch_record_tab(1).tuesday_hours   := 0.00;
				x_sch_record_tab(1).wednesday_hours := 0.00;
				x_sch_record_tab(1).thursday_hours  := 0.00;
				x_sch_record_tab(1).friday_hours    := 0.00;
				x_sch_record_tab(1).saturday_hours  := 0.00;
				x_sch_record_tab(1).sunday_hours    := 0.00;
		 END IF;
   END IF;

   -- 2196924: Fix table by setting 0 for all dates with no HR assignment.
	 IF (NVL(x_sch_record_tab.count,0) <> 0) THEN
			PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab.count<>0');
      for i in x_sch_record_tab.first .. x_sch_record_tab.last loop
			  PA_SCHEDULE_UTILS.log_message(1, i || ' ' || x_sch_record_tab(i).start_date || ' ' || x_sch_record_tab(i).end_date || ' ' || x_sch_record_tab(i).monday_hours);
      end loop;

			l_cap_first_start_date := x_sch_record_tab(x_sch_record_tab.first).start_date;
			l_cap_last_end_date := x_sch_record_tab(x_sch_record_tab.last).end_date;

      PA_SCHEDULE_UTILS.log_message(1,'l_cap_first_start_date: ' || l_cap_first_start_date);
      PA_SCHEDULE_UTILS.log_message(1,'l_cap_last_end_date: ' || l_cap_last_end_date);

      SELECT rou.resource_effective_start_date,
			 NVL(rou.resource_effective_end_date,SYSDATE)
		  BULK COLLECT INTO
			 l_ResStartDateTab,l_ResEndDateTab
		  FROM pa_resources_denorm rou
		  WHERE rou.resource_id= l_resource_id
      AND NVL(rou.resource_effective_end_date,SYSDATE) >=
					l_cap_first_start_date
      AND rou.resource_effective_start_date <= l_cap_last_end_date
      ORDER BY rou.resource_effective_start_date;

			if (NVL(l_ResStartDateTab.count,0) = 0) THEN
				 PA_SCHEDULE_UTILS.log_message(1,'Set all hours to 0 in l_sch_record_tab since no res denorm records exist. ');
				 -- Set all hours to 0 in l_sch_record_tab since no res denorm records
				 -- exist.
				 l_sch_record_tab := x_sch_record_tab;

				 FOR i in l_sch_record_tab.first .. l_sch_record_tab.last loop
						l_sch_record_tab(i).monday_hours := 0;
						l_sch_record_tab(i).tuesday_hours := 0;
						l_sch_record_tab(i).wednesday_hours := 0;
						l_sch_record_tab(i).thursday_hours := 0;
						l_sch_record_tab(i).friday_hours := 0;
						l_sch_record_tab(i).saturday_hours := 0;
						l_sch_record_tab(i).sunday_hours := 0;
				 END LOOP;
			else
				 l_res_first_start_date := l_resstartdatetab(l_resstartdatetab.first);
				 l_res_last_end_date := l_resenddatetab(l_resenddatetab.last);

				 PA_SCHEDULE_UTILS.log_message(1,'l_res_first_start_date: ' || l_res_first_start_date);
				 PA_SCHEDULE_UTILS.log_message(1,'l_res_last_end_date: ' || l_res_last_end_date);

				 PA_SCHEDULE_UTILS.log_message(1,'Resource denorm records do exist.');

				 -- Check if there are any holes in resource denorm records.
				 -- If so, then adjust x_sch_record_tab with that change.

				 -- If the start of the resource records is after the start of
				 -- cap records, then insert a record in the beginning to indicate
				 -- this hole.
				 IF (l_cap_first_start_date < l_res_first_start_date) THEN
						l_resstartdatetab(l_resstartdatetab.first-1) := l_cap_first_start_date-10;
						l_resenddatetab(l_resenddatetab.first-1) := l_cap_first_start_date - 1;
				 END IF;

				 -- If the end of the resource records is after the end of
				 -- cap records, then insert a record in the end to indicate
				 -- this hole.
				 IF (l_cap_last_end_date > l_res_last_end_date) THEN
						l_resstartdatetab(l_resstartdatetab.last+1) := l_cap_last_end_date+1;
						l_resenddatetab(l_resenddatetab.last+1) := l_cap_last_end_date +10;
				 END IF;

				 PA_SCHEDULE_UTILS.log_message(1,'l_prev_res_end_date: ' || l_prev_res_end_date);

				 l_last_processed_cap_index := 0;
				 l_cap_tab_index := 1;

				 PA_SCHEDULE_UTILS.log_message(1,'l_res_last_end_date: ' || l_res_last_end_date);
				 PA_schedule_utils.log_message(1,'l_cap_last_end_date: ' || l_cap_last_end_date);

				 l_last_processed_cap_index := x_sch_record_tab.first-1;
				 PA_SCHEDULE_UTILS.log_message(1,'l_last_processed_cap_index: ' || l_last_processed_cap_index);

				 -- Find holes in l_ResStartDateTab, l_ResEndDateTab
				 FOR i in l_ResStartDateTab.first .. l_ResStartDateTab.last LOOP
						pa_schedule_utils.log_message(1,'i: ' || i);
						PA_SCHEDULE_UTILS.log_message(1,'l_ResStartDateTab(i): ' || l_ResStartDateTab(i));
						PA_SCHEDULE_UTILS.log_message(1,'l_prev_res_end_date: ' || l_prev_res_end_date);
						if (l_ResStartDateTab(i) > l_prev_res_end_date+1) then
							 l_hole_start_date := l_prev_res_end_date+1;
							 l_hole_end_date := l_ResStartDateTab(i)-1;
							 PA_SCHEDULE_UTILS.log_message(1,'Hole found: ' || l_hole_start_date || ' ' || l_hole_end_date);

							 -- Adjust x_sch_record_tab with decrease in availability.
							 -- This is done by copying / modifying records up to hole end date.
							 PA_SCHEDULE_UTILS.log_message(1,'l_last_processed_cap_index: ' || l_last_processed_cap_index);
							 PA_SCHEDULE_UTILS.log_message(1,'Start loop through capacity records.');

							 <<l_cap_record_loop>>
							 for j in (l_last_processed_cap_index + 1) .. x_sch_record_tab.last LOOP

									l_j_index := j;
									PA_SCHEDULE_UTILS.log_message(1,'j: ' || j);
									PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).start_date: ' || x_sch_record_tab(j).start_date);
									PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).end_date: ' || x_sch_record_tab(j).end_date);
									PA_SCHEDULE_UTILS.log_message(1,'l_hole_end_date: ' || l_hole_end_date);
									l_reprocess_flag := 'N';


									IF (x_sch_record_tab(j).start_date = l_hole_end_date + 1) then
										 PA_SCHEDULE_UTILS.log_message(1,'Finished looping through all capacity records for current hole.  Find next hole.');
                     l_reprocess_flag := 'Y';  -- Added after the fact
										 EXIT l_cap_record_loop;
										 -- Reprocess if the capacity record starts after the hole
										 -- end date because it may overlap the next hole.
									ELSIF (x_sch_record_tab(j).start_date > l_hole_end_date + 1) then
										 PA_SCHEDULE_UTILS.log_message(1,'Finished looping through all capacity records for current hole.  Find next hole.');
										 l_reprocess_flag := 'Y';
										 EXIT l_cap_record_loop;
									end if;

									-- If Capacity record is before hole.
									if (x_sch_record_tab(j).end_date <  l_hole_start_date) then

										 PA_SCHEDULE_UTILS.log_message(1,'Capacity record before hole');
										 -- Keep record as is.
										 l_sch_record_tab(l_cap_tab_index) := x_sch_record_tab(j);
										 l_cap_tab_index := l_cap_tab_index + 1;
										 PA_SCHEDULE_UTILS.log_message(1,'j: ' || j);
										 PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).start_date: ' || x_sch_record_tab(j).start_date);
										 PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).end_date: ' || x_sch_record_tab(j).end_date);
										 PA_SCHEDULE_UTILS.log_message(1,'j: ' || j);

										 -- If capacity record overlaps start date of hole.
									elsif (x_sch_record_tab(j).start_date < l_hole_start_date AND
                      x_sch_record_tab(j).end_date <= l_hole_end_date) then

										 PA_SCHEDULE_UTILS.log_message(1,'capacity record overlaps start date of hole.');
										 -- Keep record as is but end date it
										 l_sch_record_tab(l_cap_tab_index) := x_sch_record_tab(j);
										 l_sch_record_tab(l_cap_tab_index).end_date :=
											 l_hole_start_date - 1;
										 l_cap_tab_index := l_cap_tab_index + 1;

										 -- Create record for hole.
										 l_sch_record_tab(l_cap_tab_index).start_date :=
											 l_hole_start_date;
										 l_sch_record_tab(l_cap_tab_index).end_date :=
											 x_sch_record_tab(j).end_date;
										 l_sch_record_tab(l_cap_tab_index).monday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).tuesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).wednesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).thursday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).friday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).saturday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).sunday_hours := 0;
										 l_cap_tab_index := l_cap_tab_index + 1;

									-- If capacity record overlaps start date and end date of hole.
									elsif (x_sch_record_tab(j).start_date < l_hole_start_date AND
										x_sch_record_tab(j).end_date > l_hole_end_date) then

										 PA_SCHEDULE_UTILS.log_message(1,'capacity record overlaps start date and end date of hole.');

										 -- Copy record over and end date it
										 l_sch_record_tab(l_cap_tab_index) := x_sch_record_tab(j);
										 l_sch_record_tab(l_cap_tab_index).end_date :=
											 l_hole_start_date - 1;
										 l_cap_tab_index := l_cap_tab_index + 1;

										 -- Create record for hole.
										 l_sch_record_tab(l_cap_tab_index).start_date :=
											 l_hole_start_date;
										 l_sch_record_tab(l_cap_tab_index).end_date := l_hole_end_date;
										 l_sch_record_tab(l_cap_tab_index).monday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).tuesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).wednesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).thursday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).friday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).saturday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).sunday_hours := 0;
										 l_cap_tab_index := l_cap_tab_index + 1;

										 -- Modify x_sch_record_tab(j) so that the record will
										 -- be reprocessed.
										 PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).start_date: ' || x_sch_record_tab(j).start_date);
										 PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).end_date: ' || x_sch_record_tab(j).end_date);
										 PA_SCHEDULE_UTILS.log_message(1,'j: ' || j);

										 x_sch_record_tab(j).start_date := l_hole_end_date + 1;
										 PA_SCHEDULE_UTILS.log_message(1,'Mark for reprocessing.');
										 l_reprocess_flag := 'Y'; -- Mark for reprocessing.

										 EXIT l_cap_record_loop;

										 -- If capacity record within hole.
									elsif (x_sch_record_tab(j).start_date <= l_hole_end_date AND
                      x_sch_record_tab(j).end_date <= l_hole_end_date) THEN

										 PA_SCHEDULE_UTILS.log_message(1,'capacity record within hole.');

										 -- Create record for hole.
										 l_sch_record_tab(l_cap_tab_index) := x_sch_record_tab(j);
										 l_sch_record_tab(l_cap_tab_index).monday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).tuesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).wednesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).thursday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).friday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).saturday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).sunday_hours := 0;
										 l_cap_tab_index := l_cap_tab_index + 1;

										 -- If capacity record overlaps end date of hole.
									elsif (x_sch_record_tab(j).start_date <= l_hole_end_date AND
										x_sch_record_tab(j).end_date > l_hole_end_date) THEN

										 PA_SCHEDULE_UTILS.log_message(1,'capacity record overlaps end date of hole.');

										 -- Create record for hole.
										 PA_SCHEDULE_UTILS.log_message(1,'l_cap_tab_index: ' || l_cap_tab_index);
										 l_sch_record_tab(l_cap_tab_index) := x_sch_record_tab(j);
										 l_sch_record_tab(l_cap_tab_index).end_date := l_hole_end_date;
										 l_sch_record_tab(l_cap_tab_index).monday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).tuesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).wednesday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).thursday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).friday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).saturday_hours := 0;
										 l_sch_record_tab(l_cap_tab_index).sunday_hours := 0;
										 l_cap_tab_index := l_cap_tab_index + 1;

										 -- Modify x_sch_record_tab(j) so that the record will
										 -- be reprocessed.
										 PA_SCHEDULE_UTILS.log_message(1,'j: ' || j);
										 PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).start_date: ' || x_sch_record_tab(j).start_date);
										 PA_SCHEDULE_UTILS.log_message(1,'x_sch_record_tab(j).end_date: ' || x_sch_record_tab(j).end_date);
										 x_sch_record_tab(j).start_date := l_hole_end_date + 1;

										 PA_SCHEDULE_UTILS.log_message(1,'Mark for reprocessing.');
										 l_reprocess_flag := 'Y'; -- Mark for reprocessing.
										 EXIT l_cap_record_loop;
									END IF;
									-- Type of hole if statement
							 END LOOP;
							 -- for j in l_last_processed_cap_index + 1 ..
							 -- modifying l_sch_record_tab with hole info.

							 PA_SCHEDULE_UTILS.log_message(1,'JM: 1');
							 PA_SCHEDULE_UTILS.log_message(1,'l_j_index: ' || l_j_index);
							 IF (l_reprocess_flag = 'Y') THEN
									l_last_processed_cap_index := l_j_index-1;
							 ELSE
									l_last_processed_cap_index := l_j_index;
							 END IF;

						END IF;
						-- l_ResStartDateTab(i) > l_prev_res_end_date+1
						-- When there is a hole

						l_prev_res_end_date := l_ResEndDateTab(i);
            PA_SCHEDULE_UTILS.log_message(1,'JM: 2');

				 END LOOP;
				 -- FOR i in l_ResStartDateTab.first .. l_ResStartDateTab.last
				 -- Finding holes

				 -- Copy rest of schedule records to local table.
				 for j in l_last_processed_cap_index + 1 .. x_sch_record_tab.last loop
						l_sch_record_tab(l_cap_tab_index) := x_sch_record_tab(j);
						l_cap_tab_index := l_cap_tab_index + 1;
				 END LOOP;

			END IF;
			-- if (NVL(l_ResStartDateTab.count,0) = 0) THEN
			-- If there are any records in resource denorm.
      PA_SCHEDULE_UTILS.log_message(1,'JM: 3');
	 END IF;
	 -- IF (NVL(x_sch_record_tab.count,0) <> 0) THEN
	 -- If there are any capacity records.

	 x_sch_record_tab := l_sch_record_tab;
   -- End 2196924: Fix table by setting 0 for all dates with no HR assignment.

	 x_return_status := l_x_return_status;
   PA_SCHEDULE_UTILS.log_message(1,'last status ... '||l_x_return_status);
   PA_SCHEDULE_UTILS.log_message(1,'leaving get_resource_schedule');
EXCEPTION
	 WHEN  l_invalid_source_id  THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := 'l_invalid_source_id';
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'get_resource_schedule');
		 raise;
	 WHEN OTHERS THEN
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'get_resource_schedule');
		 raise;

END get_resource_schedule;


-- This procedure is called from change_schedule procedure. This procedure applys
-- the resultant schedule details ( after applying exceptions ) on the schedule related tables
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Chg_Sch_Record_Tab         SCHEDULETABTYP      YES  It has the schedule record which are marked for changed
--                                                       e.g I , U
-- P_Del_Sch_Record_Tab         SCHEDULETABTYP      YES  It has the schedule record which are marked for deletion
--

PROCEDURE apply_schedule_change( p_chg_sch_record_tab     IN  PA_SCHEDULE_GLOB.ScheduleTabTyp,
																 p_del_sch_record_tab     IN  PA_SCHEDULE_GLOB.ScheduleTabTyp,
																 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																 x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
																 x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_I                      NUMBER;
	 l_upd_sch_record_tab     PA_SCHEDULE_GLOB.ScheduleTabTyp; -- variable used for storing the records kept for updation
	 l_ins_sch_record_tab     PA_SCHEDULE_GLOB.ScheduleTabTyp; -- variable used for storing the records kept for insertion
BEGIN
	 -- storing status for tracking the error
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;
	 -- checking if the passing records is empty or not
	 IF (p_chg_sch_record_tab.count = 0 ) THEN
			RAISE l_empty_tab_record;
	 ELSE
			l_I := p_chg_sch_record_tab.first;
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of apply_schedule_change .... ');
	 LOOP

			IF (p_chg_sch_record_tab(l_I).change_type_code = 'U') THEN
				 PA_SCHEDULE_UTILS.log_message(1,'U .... ');
				 -- Calling the SCHEDULE UTILS api which will append the record if it marked for updation
				 PA_SCHEDULE_UTILS.Add_Schedule_Rec_Tab(p_chg_sch_record_tab,l_I,l_I,l_upd_sch_record_tab,
					 l_x_return_status,x_msg_count,x_msg_data);
			ELSIF (p_chg_sch_record_tab(l_I).change_type_code = 'I') THEN
				 PA_SCHEDULE_UTILS.log_message(1,'I .... ');

				 -- Calling the SCHEDULE UTILS api which will append the record if it marked for insertion
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
PA_SCHEDULE_UTILS.Add_Schedule_Rec_Tab(p_chg_sch_record_tab,l_I,l_I,l_ins_sch_record_tab,
					 l_x_return_status,x_msg_count,x_msg_data);
         END IF;

			END IF;

			IF (l_I = p_chg_sch_record_tab.last ) THEN
				 EXIT;
			ELSE
				 l_I := p_chg_sch_record_tab.next(l_I);
			END IF;
	 END LOOP;



		 -- Applying the changes according to their status i.e. insert,update or delete
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		PA_SCHEDULE_PKG.Insert_Rows(l_ins_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
	 END IF;

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		PA_SCHEDULE_PKG.Update_Rows(l_upd_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
	 END IF;

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		PA_SCHEDULE_PKG.Delete_Rows(p_del_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
	 END IF;

	  IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		  PA_SCHEDULE_PVT.merge_work_pattern(p_chg_sch_record_tab(1).project_id,p_chg_sch_record_tab(1).assignment_id,l_x_return_status,x_msg_count,x_msg_data);
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'end of apply_schedule_change .... ');
	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN l_empty_tab_record THEN
		 x_return_status := FND_API.G_RET_STS_SUCCESS;
		 NULL;
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'apply_schedule_change');
		 raise;

END apply_schedule_change;

-- This procedure will create the new schedule on the basis of passed criteria i.e change duration
-- ,Change hours and so on
-- Input parameters
-- Parameters                 Type               Required  Description
-- P_Sch_Except_Record_Tab    SCHEXCEPTRECORD    YES       It has the exception record
-- P_Sch_Record               SCHEDULERECORD     YES       It has the schedule record
-- In Out parameters
-- X_Sch_Record_Tab           SCHEDULETABTYP     YES       It store the new schedule
--

PROCEDURE create_new_schedule(
	p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
  	p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
    x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
	x_difference_days  IN NUMBER,  -- Added for bug 7663765
	x_shift_unit_code  IN VARCHAR2, -- Added for bug 7663765
	x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data           OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_t_team_player_id     NUMBER;
	 l_t_res_cal_percent    NUMBER;
	 l_t_calendar_id        NUMBER;
	 l_t_calendar_type      VARCHAR2(30);

BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of create_new_schedule API ..... ');
	 PA_SCHEDULE_UTILS.log_message(1,'exception_type_code '||p_sch_except_record.exception_type_code);

	 -- This procedure will create the new schedule for the given change duration exception it will create by changing
	 -- the duration
	 IF (p_sch_except_record.exception_type_code = 'CHANGE_DURATION' OR
             p_sch_except_record.exception_type_code = 'SHIFT_DURATION' OR
			 p_sch_except_record.exception_type_code = 'DURATION_PATTERN_SHIFT') THEN
			-- Calling the procedure create_new_duration
			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      PA_SCHEDULE_PVT.create_new_duration(p_sch_except_record,
				p_sch_record,
				x_sch_record_tab,
				x_difference_days, -- Added for bug 7663765
				x_shift_unit_code, -- Added for bug 7663765
				l_x_return_status,
				x_msg_count,
				x_msg_data);
      END IF;
	 ELSIF (p_sch_except_record.exception_type_code = 'CHANGE_HOURS') THEN
			-- This procedure will create the new schedule for the given change hours exception it will create by
			-- changing the hours for the given period
			-- Calling the procedure create_new_hours
      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_PVT.create_new_hours(p_sch_except_record,
				p_sch_record,
				x_sch_record_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data);
      END IF;
	 ELSIF (p_sch_except_record.exception_type_code = 'CHANGE_WORK_PATTERN') THEN
			-- This procedure will create the new schedule for the given change work pattern exception it will create
			-- by just changing the work patern for the given period
			-- Calling the procedure create_new_pattern
      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_PVT.create_new_pattern(p_sch_except_record,
				p_sch_record,
				x_sch_record_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data);
      END IF;
	 ELSIF (p_sch_except_record.exception_type_code = 'CHANGE_STATUS') THEN
			-- This procedure will create the new schedule for the given change status exception it will create
			-- by changing the status for that period only
			-- Calling the procedure create_new_status
    IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_PVT.create_new_status(p_sch_except_record,
				p_sch_record,
				x_sch_record_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data);
    END IF;
	 ELSIF (p_sch_except_record.exception_type_code = 'CHANGE_CALENDAR') THEN
			-- This procedure will create the new schedule for the given change calendar exception it will create
			-- by changing the calendar for that period only
			-- Calling the procedure create_new_calendar
    IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_PVT.create_new_calendar(p_sch_except_record,
				p_sch_record,
				x_sch_record_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data);
    END IF;
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'after calling respective APIs return x_sch_record_tab.coun '||to_char
		 (x_sch_record_tab.count)||' Status '||l_x_return_status);
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_UTILS.update_sch_rec_tab(x_sch_record_tab,
				p_change_type_code     => 'I',
				x_return_status        => l_x_return_status,
				x_msg_count            => x_msg_count,
				x_msg_data             => x_msg_data
																					);
	 END IF;
	 x_return_status := l_x_return_status;

EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_new_schedule');
		 raise;

END create_new_schedule;

-- This procedure will create the new calendar with the passed exception
-- Input parameters
-- Parameters                   Type                 Required  Description
-- In Out parameters
-- P_Sch_Except_Record_Tab      SCHEXCEPTRECORD      YES       It has the exception record
-- P_Sch_Record                 SCHEDULERECORD       YES       It has the schedule record
-- X_Sch_Record_Tab             SCHEDULETABTYP       YES       It store the new schedule
--

PROCEDURE create_new_calendar(
															p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
															p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
															x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
															x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
															x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
															x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
														 )
IS
BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
      PA_SCHEDULE_UTILS.check_calendar(
                    p_calendar_id => p_sch_except_record.calendar_id,
                    p_start_date => p_sch_except_record.start_date,
                    p_end_date => p_sch_except_record.end_date,
                    x_return_status => l_x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);
   END IF;

	 -- Calling the procedure get_calendar_schedule that will bring the new schedule of the passed calendar
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	 PA_SCHEDULE_PVT.get_calendar_schedule(p_sch_except_record.calendar_id,
		 p_sch_except_record.start_date,
		 p_sch_except_record.end_date,
		 x_sch_record_tab,
		 l_x_return_status,
		 x_msg_count,
		 x_msg_data
																				);
   END IF;
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_UTILS.update_sch_rec_tab(x_sch_record_tab,
				p_project_id             => p_sch_except_record.project_id,
				p_schedule_type_code     => p_sch_except_record.schedule_type_code,
				p_assignment_id          => p_sch_except_record.assignment_id,
				p_assignment_status_code => p_sch_record.assignment_status_code,
				x_return_status          => l_x_return_status,
				x_msg_count              => x_msg_count,
					x_msg_data               => x_msg_data
																					);
	 END IF;
	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_new_calendar');

		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in create_new_schedule procedure ');
		 raise;

END create_new_calendar;

-- This procedure will create the new schedule by createing the new hours on the basis of change hours
-- code i.e PERCENTAGE or HOURS
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SCHEXCEPTRECORD      YES       It has the exception record
-- P_Sch_Record                 SCHEDULERECORD       YES       It has the schedule record
-- In Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP       YES       It store the new schedule
--

PROCEDURE create_new_hours(
	p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
	p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
	x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
	x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data           OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_t_calendar_id        pa_project_assignments.calendar_id%TYPE;    -- to store the value for new creating hours
	 l_t_calendar_type      pa_project_assignments.calendar_type%TYPE;  -- to store the value for new creating hours
	 l_t_team_player_id     NUMBER;                                     -- to store the value for new creating hours

	 l_t_resource_id     NUMBER;                                     -- to sto
         l_t_asgn_type       pa_project_assignments.assignment_type%TYPE; /*Bug 5682726*/
BEGIN
	 PA_SCHEDULE_UTILS.log_message(1,'start of create new hours ... ');
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;
	 PA_SCHEDULE_UTILS.log_message(1,'start of create new hours ...change_hours_type ...'||
		 p_sch_except_record.change_hours_type_code);

	 -- For this hours code we will changed the previous schedule 's hours with the new passed
	 -- values and create new hours for a given period only
	 IF (p_sch_except_record.change_hours_type_code = 'HOURS') THEN
			x_sch_record_tab(1).start_date  := p_sch_except_record.start_date;
			x_sch_record_tab(1).end_date    := p_sch_except_record.end_date;

			IF (p_sch_except_record.non_working_day_flag = 'Y') THEN
				 x_sch_record_tab(1).Monday_hours    := p_sch_except_record.Monday_hours;
				 x_sch_record_tab(1).Tuesday_hours   := p_sch_except_record.Tuesday_hours;
				 x_sch_record_tab(1).Wednesday_hours := p_sch_except_record.Wednesday_hours;
				 x_sch_record_tab(1).Thursday_hours  := p_sch_except_record.Thursday_hours;
				 x_sch_record_tab(1).Friday_hours    := p_sch_except_record.Friday_hours;
				 x_sch_record_tab(1).Saturday_hours  := p_sch_except_record.Saturday_hours;
				 x_sch_record_tab(1).Sunday_hours    := p_sch_except_record.Sunday_hours;
			ELSE
				 x_sch_record_tab(1).Monday_hours    := 0;
				 x_sch_record_tab(1).Tuesday_hours   := 0;
				 x_sch_record_tab(1).Wednesday_hours := 0;
				 x_sch_record_tab(1).Thursday_hours  := 0;
				 x_sch_record_tab(1).Friday_hours    := 0;
				 x_sch_record_tab(1).Saturday_hours  := 0;
				 x_sch_record_tab(1).Sunday_hours    := 0;

 /* Bug 5682726 - Start Changes */

                  SELECT assignment_type
		  INTO l_t_asgn_type
		  FROM pa_project_assignments
		  where assignment_id = p_sch_except_record.assignment_id;

	         IF ( l_t_asgn_type = 'STAFFED_ASSIGNMENT' OR l_t_asgn_type =
'STAFFED_ADMIN_ASSIGNMENT' ) THEN
       		  SELECT project_party_id
                  INTO l_t_team_player_id
                  FROM pa_project_assignments
                  WHERE assignment_id = p_sch_except_record.assignment_id;

                  SELECT resource_id
                  INTO l_t_resource_id
                  FROM pa_project_assignments
                  WHERE assignment_id = p_sch_except_record.assignment_id;

                  IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                  PA_SCHEDULE_UTILS.check_calendar(p_resource_id => l_t_resource_id,
                                                   p_start_date => p_sch_except_record.start_date,
                                                   p_end_date => p_sch_except_record.end_date,
                                                   x_return_status => l_x_return_status,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data => x_msg_data);
                  END IF;

                  -- Calling the procedure get_resource_schedule that will bring the schedule associated with the resource
                  IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                  PA_SCHEDULE_PVT.get_resource_schedule(l_t_team_player_id,
                                                        'PA_PROJECT_PARTY_ID',
                                                        p_sch_except_record.start_date,
                                                        p_sch_except_record.end_date,
                                                        x_sch_record_tab,
                                                        l_x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);
                  END IF;

		  ELSE
		  IF ( l_t_asgn_type = 'OPEN_ASSIGNMENT' ) THEN
                   SELECT calendar_id
                   INTO l_t_calendar_id
                   FROM pa_project_assignments
                   where assignment_id = p_sch_except_record.assignment_id;

                   IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                   PA_SCHEDULE_UTILS.check_calendar(p_calendar_id => l_t_calendar_id,
                                                   p_start_date => p_sch_except_record.start_date,
                                                   p_end_date => p_sch_except_record.end_date,
                                                   x_return_status => l_x_return_status,
                                                   x_msg_count => x_msg_count,
                                                   x_msg_data => x_msg_data);
                   END IF;


                   -- Calling the procedure get_calendar_schedule that will bring the schedule associated with the
                   -- assignment on the basis of passed calendar id
                   IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                   PA_SCHEDULE_PVT.get_calendar_schedule(l_t_calendar_id,
                                                        p_sch_except_record.start_date,
                                                        p_sch_except_record.end_date,
                                                        x_sch_record_tab,
                                                        l_x_return_status,
                                                        x_msg_count,
                                                        x_msg_data);
	           END IF;

		 END IF; /* IF ( l_t_asgn_type = 'OPEN_ASSIGNMENT' ) */
		END IF; /* IF ( l_t_asgn_type = 'STAFFED_ASSIGNMENT' ) */

				 IF (x_sch_record_tab(1).Monday_hours <> 0) THEN
					x_sch_record_tab(1).Monday_hours  := p_sch_except_record.Monday_hours;
				 END IF;

				 IF (x_sch_record_tab(1).Tuesday_hours <> 0) THEN
						x_sch_record_tab(1).Tuesday_hours  := p_sch_except_record.Tuesday_hours;
				 END IF;

				 IF (x_sch_record_tab(1).Wednesday_hours <> 0) THEN
						x_sch_record_tab(1).Wednesday_hours  := p_sch_except_record.Wednesday_hours;
				 END IF;

				 IF (x_sch_record_tab(1).Thursday_hours <> 0) THEN
						x_sch_record_tab(1).Thursday_hours  := p_sch_except_record.Thursday_hours;
				 END IF;

				 IF (x_sch_record_tab(1).Friday_hours <> 0) THEN
						x_sch_record_tab(1).Friday_hours  := p_sch_except_record.Friday_hours;
				 END IF;

				 IF (x_sch_record_tab(1).Saturday_hours <> 0) THEN
						x_sch_record_tab(1).Saturday_hours  := p_sch_except_record.Saturday_hours;
				 END IF;

				 IF (x_sch_record_tab(1).Sunday_hours <> 0) THEN
						x_sch_record_tab(1).Sunday_hours  := p_sch_except_record.Sunday_hours;
				 END IF;
 /* Bug 5682726 - End Changes */
			END IF;

	 END IF;

	 --  In this case we take the calendar which is asociated with the resource and apply the percentage change
	 -- on the existing one or the created one
	 IF (p_sch_except_record.change_hours_type_code = 'PERCENTAGE') THEN

	      -- If the calendar type is resource, then we 'll pick the value for calendar from
	      -- resource i.e. CRM else from calendar
	      IF (p_sch_except_record.change_calendar_type_code = 'RESOURCE') THEN

                  -- get  project_party_id to pass api 'get_resource_schedule'
   	        SELECT project_party_id
	          INTO l_t_team_player_id
	      	  FROM pa_project_assignments
	 	        WHERE assignment_id = p_sch_except_record.assignment_id;

   	        SELECT resource_id
	          INTO l_t_resource_id
	      	  FROM pa_project_assignments
	 	        WHERE assignment_id = p_sch_except_record.assignment_id;

	          IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
            PA_SCHEDULE_UTILS.check_calendar(p_resource_id => l_t_resource_id,
                    p_start_date => p_sch_except_record.start_date,
                    p_end_date => p_sch_except_record.end_date,
                    x_return_status => l_x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);
            END IF;

		        -- Calling the procedure get_resource_schedule that will bring the schedule associated with the resource
	          IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		        PA_SCHEDULE_PVT.get_resource_schedule(l_t_team_player_id,
						       'PA_PROJECT_PARTY_ID',
						        p_sch_except_record.start_date,
						        p_sch_except_record.end_date,
						        x_sch_record_tab,
						        l_x_return_status,
						        x_msg_count,
						        x_msg_data);
              -- if calendar_type is either 'PROJECT' or 'OTHER'
            END IF;
	      ELSE

	          IF (p_sch_except_record.change_calendar_type_code = 'PROJECT') THEN
   	             SELECT calendar_id
	               INTO l_t_calendar_id
	      	       FROM pa_projects_all
		             WHERE project_id = p_sch_except_record.project_id;

                  -- Use change_calendar_id passed from calendar LOV for the calendar_id to be updated
            ELSIF (p_sch_except_record.change_calendar_type_code = 'OTHER') THEN
		              l_t_calendar_id := p_sch_except_record.change_calendar_id;
            END IF;

	          IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
                  PA_SCHEDULE_UTILS.check_calendar(
                    p_calendar_id => l_t_calendar_id,
                    p_start_date => p_sch_except_record.start_date,
                    p_end_date => p_sch_except_record.end_date,
                    x_return_status => l_x_return_status,
                    x_msg_count => x_msg_count,
                    x_msg_data => x_msg_data);
            END IF;


		        -- Calling the procedure get_calendar_schedule that will bring the schedule associated with the
		        -- assignment on the basis of passed calendar id
	          IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		        PA_SCHEDULE_PVT.get_calendar_schedule(l_t_calendar_id,
			 				 p_sch_except_record.start_date,
							 p_sch_except_record.end_date,
							 x_sch_record_tab,
							 l_x_return_status,
							 x_msg_count,
							 x_msg_data);
            END IF;
	      END IF;

	      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
		    -- Calling the schedule API
		    PA_SCHEDULE_UTILS.apply_percentage(x_sch_record_tab,
			  			      p_sch_except_record.resource_calendar_percent,
						      l_x_return_status,
						      x_msg_count,
					 	      x_msg_data );
	      END IF;

	 END IF; --IF (p_sch_except_record.change_hours_type_code = 'PERCENTAGE')


	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			-- Updating the pa schedules table
			PA_SCHEDULE_UTILS.update_sch_rec_tab(x_sch_record_tab,
				p_project_id             => p_sch_except_record.project_id,
				p_schedule_type_code     => p_sch_except_record.schedule_type_code,
				p_assignment_id          => p_sch_except_record.assignment_id,
				p_calendar_id          => p_sch_except_record.calendar_id,
				p_assignment_status_code => p_sch_record.assignment_status_code,
				x_return_status          => l_x_return_status,
				x_msg_count              => x_msg_count,
				x_msg_data               => x_msg_data
																					);
	 END IF;

	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_new_hours');
		 raise;

END create_new_hours;

-- This procedure will create new duration on the basis of passed exception and schedule
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SCHEXCEPTRECORD      YES       It has the exception record
-- P_Sch_Record                 SCHEDULERECORD       YES       It has the schedule record
-- In Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP       YES       It store the new schedule
--

PROCEDURE create_new_duration(
															p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
															p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
															x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
															x_difference_days    IN NUMBER,  -- Added for bug 7663765
															x_shift_unit_code    IN VARCHAR2, -- Added for bug 7663765
															x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
															x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
															x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
														 )
IS
	 l_t_team_player_id    NUMBER;
	 l_t_res_cal_percent    NUMBER;
	 l_t_calendar_id        NUMBER;
	 l_t_calendar_type      VARCHAR2(30);
BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of create_new_duration API .........');
	 PA_SCHEDULE_UTILS.log_message(1,'schedule_type_code '||p_sch_except_record.schedule_type_code);
	 -- Bug 1580455: added STAFFED_ADMIN_ASSIGNMENT case.
	 /* Added the below if for 7663765 */
 IF (p_sch_except_record.exception_type_code = 'DURATION_PATTERN_SHIFT') then

				 PA_SCHEDULE_PVT.get_existing_schedule(l_t_calendar_id,
				 p_sch_except_record.assignment_id,
					 p_sch_except_record.start_date,
					 p_sch_except_record.end_date,
					 x_sch_record_tab,
					 x_difference_days,
					 x_shift_unit_code,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data	  );
 else
	 IF (p_sch_except_record.schedule_type_code = 'STAFFED_ASSIGNMENT') OR
      (p_sch_except_record.schedule_type_code = 'STAFFED_ADMIN_ASSIGNMENT') THEN

			SELECT project_party_id , resource_calendar_percent,calendar_id,calendar_type
				INTO l_t_team_player_id,l_t_res_cal_percent,l_t_calendar_id,l_t_calendar_type
				FROM pa_project_assignments
				WHERE assignment_id = p_sch_except_record.assignment_id;

			IF ( l_t_calendar_type = 'RESOURCE' ) THEN
				 -- Calling the procedure get_resource_schedule which is assigned to the assignment
         IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 PA_SCHEDULE_PVT.get_resource_schedule(l_t_team_player_id,
					 'PA_PROJECT_PARTY_ID',
					 p_sch_except_record.start_date,
					 p_sch_except_record.end_date,
					 x_sch_record_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data
																							);
         END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						-- Calling the schedule API which will apply the percentage on the schedule
						PA_SCHEDULE_UTILS.apply_percentage(x_sch_record_tab,
							l_t_res_cal_percent,
							l_x_return_status,
							x_msg_count,
							x_msg_data
																							);
				 END IF;

			ELSE
				 -- Calling the procedure get_calendar_schedule  for the calendar assigned to that resource
				 PA_SCHEDULE_PVT.get_calendar_schedule(l_t_calendar_id,
					 p_sch_except_record.start_date,
					 p_sch_except_record.end_date,
					 x_sch_record_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data
																							);
			END IF;

	 ELSE

			PA_SCHEDULE_UTILS.log_message(2,'cal_id '||p_sch_except_record.calendar_id||'  st_dt '||
				p_sch_except_record.start_date||' en_dt '||p_sch_except_record.end_date);

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Calling the procedure get_calendar_schedule on the basis of passed calendar id and for
				 -- calendar type like assignment,project or others
				 PA_SCHEDULE_PVT.get_calendar_schedule(p_sch_except_record.calendar_id,
					 p_sch_except_record.start_date,
					 p_sch_except_record.end_date,
					 x_sch_record_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data
																							);
			END IF;

			PA_SCHEDULE_UTILS.log_message(2,'x_sch ',x_sch_record_tab);
	 END IF;
 end if; -- 7663765

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_UTILS.update_sch_rec_tab(x_sch_record_tab,
				p_project_id             => p_sch_except_record.project_id,
				p_schedule_type_code     => p_sch_except_record.schedule_type_code,
				p_assignment_id          => p_sch_except_record.assignment_id,
				p_calendar_id          => p_sch_except_record.calendar_id,
				p_assignment_status_code => p_sch_except_record.assignment_status_code,
				x_return_status          => l_x_return_status,
				x_msg_count              => x_msg_count,
				x_msg_data               => x_msg_data
																					);
	 END IF;

	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_new_duration');

		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in create_new_duration procedure ');
		 raise;

END create_new_duration;



--*******************************************************************************
-- This procedure will merge the work pattern
-- Input parameters
-- Parameters                   Type        Required  Description
-- p_project_id			NUMBER      YES       It has the project_id
-- p_assignment_id              NUMBER      YES       It has the assignment_id

PROCEDURE merge_work_pattern(
	p_project_id      IN  NUMBER,
	p_assignment_id   IN  NUMBER,
	x_return_status  OUT NOCOPY VARCHAR2,
	x_msg_count      OUT NOCOPY NUMBER,
	x_msg_data       OUT NOCOPY VARCHAR2 )
IS
	CURSOR csr_get_sch IS
		 select
			rowid,
			calendar_id,
			schedule_id,
			schedule_type_code,
			status_code,
			start_date,
			end_date,
			monday_hours,
			tuesday_hours,
			wednesday_hours,
			thursday_hours,
			friday_hours,
			saturday_hours,
			sunday_hours
			from pa_schedules
			where project_id = p_project_id and
			assignment_id = p_assignment_id
			order by start_date;

		 l_temp_sch_rec_tab          PA_SCHEDULE_GLOB.ScheduleTabTyp;
		 l_del_sch_rec_tab           PA_SCHEDULE_GLOB.ScheduleTabTyp;
		 l_final_sch_rec_tab         PA_SCHEDULE_GLOB.ScheduleTabTyp;

		   l_I                       NUMBER;
		   l_J                       NUMBER;
		   l_K                       NUMBER;
		   l_Flag		     VARCHAR2(1) := 'Y';
		   l_Merge_Flag		     VARCHAR2(1) := 'N';
		   l_schrowid		     rowid;
		   l_schedule_id	     number;
		   l_calendar_id             number;
		   l_schedule_type_code      varchar2(30);
		   l_assignment_status_code  varchar2(30);
		   l_start_date		     DATE;
		   l_end_date                DATE;
		   l_monday_hours            number;
		   l_tuesday_hours           number;
		   l_wednesday_hours         number;
		   l_thursday_hours          number;
		   l_friday_hours            number;
		   l_saturday_hours          number;
		   l_sunday_hours            number;

                   /*Added status variable for bug 6921728*/
		   l_x_return_status         varchar2(1) ;


BEGIN
         /*Added initialization for bug 6921728*/
         l_x_return_status  := FND_API.G_RET_STS_SUCCESS;

	 l_I := 1;

	 FOR rec_sch  IN  csr_get_sch LOOP
			l_temp_sch_rec_tab(l_i).schrowid		    := rec_sch.rowid;
			l_temp_sch_rec_tab(l_i).schedule_id                 := rec_sch.schedule_id;
			l_temp_sch_rec_tab(l_i).calendar_id                 := rec_sch.calendar_id;
			l_temp_sch_rec_tab(l_i).schedule_type_code          := rec_sch.schedule_type_code;
			l_temp_sch_rec_tab(l_i).assignment_status_code      := rec_sch.status_code;
			l_temp_sch_rec_tab(l_i).start_date                  := rec_sch.start_date;
			l_temp_sch_rec_tab(l_i).end_date                    := rec_sch.end_date;
			l_temp_sch_rec_tab(l_i).Monday_hours                := rec_sch.Monday_hours;
			l_temp_sch_rec_tab(l_i).Tuesday_hours               := rec_sch.Tuesday_hours;
			l_temp_sch_rec_tab(l_i).Wednesday_hours             := rec_sch.Wednesday_hours;
			l_temp_sch_rec_tab(l_i).Thursday_hours              := rec_sch.Thursday_hours;
			l_temp_sch_rec_tab(l_i).Friday_hours                := rec_sch.Friday_hours;
			l_temp_sch_rec_tab(l_i).saturday_hours              := rec_sch.saturday_hours;
			l_temp_sch_rec_tab(l_i).Sunday_hours                := rec_sch.sunday_hours;
			l_I := l_I + 1;
	 END LOOP;

	l_schrowid		 :=  l_temp_sch_rec_tab(1).schrowid ;
	l_schedule_id		 :=  l_temp_sch_rec_tab(1).schedule_id ;
	l_calendar_id		 :=  l_temp_sch_rec_tab(1).calendar_id ;
	l_schedule_type_code     :=  l_temp_sch_rec_tab(1).schedule_type_code ;
	l_assignment_status_code :=  l_temp_sch_rec_tab(1).assignment_status_code ;
	l_start_date		 :=  l_temp_sch_rec_tab(1).start_date       ;
	l_end_date		 :=  l_temp_sch_rec_tab(1).end_date       ;
	l_monday_hours		 :=  l_temp_sch_rec_tab(1).Monday_hours    ;
	l_tuesday_hours		 :=  l_temp_sch_rec_tab(1).Tuesday_hours   ;
	l_wednesday_hours	 :=  l_temp_sch_rec_tab(1).Wednesday_hours  ;
	l_thursday_hours	 :=  l_temp_sch_rec_tab(1).Thursday_hours  ;
	l_friday_hours		 :=  l_temp_sch_rec_tab(1).Friday_hours ;
	l_saturday_hours	 :=  l_temp_sch_rec_tab(1).saturday_hours;
	l_sunday_hours		 :=  l_temp_sch_rec_tab(1).Sunday_hours    ;

	  l_J := 2;
	  l_K := 1;
	  l_I := 1;


          FOR i  IN 1 .. (l_temp_sch_rec_tab.count - 1) LOOP
		  l_Flag := 'Y';

			IF ((l_temp_sch_rec_tab(l_J).assignment_status_code = l_assignment_status_code) AND
				(l_temp_sch_rec_tab(l_J).Monday_hours = l_monday_hours ) AND
				(l_temp_sch_rec_tab(l_J).Tuesday_hours = l_tuesday_hours ) AND
				(l_temp_sch_rec_tab(l_J).Wednesday_hours = l_wednesday_hours ) AND
				(l_temp_sch_rec_tab(l_J).Thursday_hours = l_thursday_hours ) AND
				(l_temp_sch_rec_tab(l_J).Friday_hours = l_friday_hours ) AND
				(l_temp_sch_rec_tab(l_J).saturday_hours = l_saturday_hours ) AND
				(l_temp_sch_rec_tab(l_J).Sunday_hours = l_sunday_hours )) THEN
					l_Flag := 'N';
					l_Merge_Flag := 'Y';
			END IF;

		   IF (l_Flag = 'Y') THEN

			l_final_sch_rec_tab(l_K).schrowid		     := l_schrowid;
			l_final_sch_rec_tab(l_K).schedule_id                 := l_schedule_id;
			l_final_sch_rec_tab(l_K).calendar_id                 := l_calendar_id;
			l_final_sch_rec_tab(l_K).assignment_id               := p_assignment_id;
			l_final_sch_rec_tab(l_K).project_id                  := p_project_id;
			l_final_sch_rec_tab(l_K).schedule_type_code          := l_schedule_type_code;
			l_final_sch_rec_tab(l_K).assignment_status_code      := l_assignment_status_code;
			l_final_sch_rec_tab(l_K).start_date                  := l_start_date;
			l_final_sch_rec_tab(l_K).end_date                    := l_end_date;
			l_final_sch_rec_tab(l_K).Monday_hours                := l_monday_hours;
			l_final_sch_rec_tab(l_K).Tuesday_hours               := l_tuesday_hours;
			l_final_sch_rec_tab(l_K).Wednesday_hours             := l_wednesday_hours;
			l_final_sch_rec_tab(l_K).Thursday_hours              := l_thursday_hours;
			l_final_sch_rec_tab(l_K).Friday_hours                := l_friday_hours;
			l_final_sch_rec_tab(l_K).saturday_hours              := l_saturday_hours;
			l_final_sch_rec_tab(l_K).Sunday_hours                := l_sunday_hours;

			l_K := l_K + 1;

		        l_schrowid               := l_temp_sch_rec_tab(l_J).schrowid;
			l_schedule_id		 := l_temp_sch_rec_tab(l_J).schedule_id  ;
			l_calendar_id            := l_temp_sch_rec_tab(l_J).calendar_id  ;
			l_schedule_type_code     := l_temp_sch_rec_tab(l_J).schedule_type_code  ;
			l_assignment_status_code := l_temp_sch_rec_tab(l_J).assignment_status_code;
			l_start_date		 := l_temp_sch_rec_tab(l_J).start_date ;
			l_end_date		 := l_temp_sch_rec_tab(l_J).end_date;
			l_monday_hours		 := l_temp_sch_rec_tab(l_J).Monday_hours ;
			l_tuesday_hours		 := l_temp_sch_rec_tab(l_J).Tuesday_hours ;
			l_wednesday_hours	 := l_temp_sch_rec_tab(l_J).Wednesday_hours;
			l_thursday_hours	 := l_temp_sch_rec_tab(l_J).Thursday_hours;
			l_friday_hours		 := l_temp_sch_rec_tab(l_J).Friday_hours;
			l_saturday_hours	 := l_temp_sch_rec_tab(l_J).saturday_hours ;
			l_sunday_hours		 := l_temp_sch_rec_tab(l_J).Sunday_hours;

		   END IF;

		   IF (l_Flag = 'N') THEN
			l_end_date := l_temp_sch_rec_tab(l_J).end_date;
			l_del_sch_rec_tab(l_I).schedule_id := l_temp_sch_rec_tab(l_J).schedule_id;
			l_I := l_I + 1;
		   END IF;

		   l_J := l_J + 1;

	  END LOOP;

		        l_final_sch_rec_tab(l_K).schrowid		     := l_schrowid;
			l_final_sch_rec_tab(l_K).schedule_id                 := l_schedule_id;
			l_final_sch_rec_tab(l_K).calendar_id                 := l_calendar_id;
			l_final_sch_rec_tab(l_K).assignment_id               := p_assignment_id;
			l_final_sch_rec_tab(l_K).project_id                  := p_project_id;
			l_final_sch_rec_tab(l_K).schedule_type_code          := l_schedule_type_code;
			l_final_sch_rec_tab(l_K).assignment_status_code      := l_assignment_status_code;
			l_final_sch_rec_tab(l_K).start_date                  := l_start_date;
			l_final_sch_rec_tab(l_K).end_date                    := l_end_date;
			l_final_sch_rec_tab(l_K).Monday_hours                := l_monday_hours;
			l_final_sch_rec_tab(l_K).Tuesday_hours               := l_tuesday_hours;
			l_final_sch_rec_tab(l_K).Wednesday_hours             := l_wednesday_hours;
			l_final_sch_rec_tab(l_K).Thursday_hours              := l_thursday_hours;
			l_final_sch_rec_tab(l_K).Friday_hours                := l_friday_hours;
			l_final_sch_rec_tab(l_K).saturday_hours              := l_saturday_hours;
			l_final_sch_rec_tab(l_K).Sunday_hours                := l_sunday_hours;


	IF (l_Merge_Flag = 'Y') THEN
	  PA_SCHEDULE_PKG.Update_Rows(l_final_sch_rec_tab,l_x_return_status,x_msg_count,x_msg_data);
	  PA_SCHEDULE_PKG.Delete_Rows(l_del_sch_rec_tab,l_x_return_status,x_msg_count,x_msg_data);
	ELSE
	  PA_SCHEDULE_UTILS.log_message(1,'INFO: No Merging required.... ');

	END IF;

        /*Added for bug 6921728*/
        x_return_status := l_x_return_status ;

EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'merge_work_pattern');

		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in merge_work_pattern procedure ');
		 raise;
END merge_work_pattern;

--*******************************************************************************


-- This procedure will create the new schedule with the new pattern
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SCHEXCEPTRECORD      YES       It has the exception record
-- P_Sch_Record                 SCHEDULERECORD       YES       It has the schedule record
-- In Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP       YES       It store the new schedule
--

PROCEDURE create_new_pattern(
														 p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
														 p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
														 x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
														 x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
														 x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
														 x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
														)
IS

BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	 x_sch_record_tab(1).start_date       := p_sch_except_record.start_date;
	 x_sch_record_tab(1).end_date         := p_sch_except_record.end_date;
	 x_sch_record_tab(1).Monday_hours     := nvl(p_sch_except_record.Monday_hours, p_sch_record.Monday_hours);
	 x_sch_record_tab(1).Tuesday_hours    := nvl(p_sch_except_record.Tuesday_hours, p_sch_record.Tuesday_hours);
	 x_sch_record_tab(1).Wednesday_hours  := nvl(p_sch_except_record.Wednesday_hours, p_sch_record.Wednesday_hours);
	 x_sch_record_tab(1).Thursday_hours   := nvl(p_sch_except_record.Thursday_hours, p_sch_record.Thursday_hours);
	 x_sch_record_tab(1).Friday_hours     := nvl(p_sch_except_record.Friday_hours, p_sch_record.Friday_hours);
	 x_sch_record_tab(1).Saturday_hours   := nvl(p_sch_except_record.Saturday_hours, p_sch_record.Saturday_hours);
	 x_sch_record_tab(1).Sunday_hours     := nvl(p_sch_except_record.Sunday_hours, p_sch_record.Sunday_hours);

	 -- Updating the records with the new work pattern

	 PA_SCHEDULE_UTILS.update_sch_rec_tab(x_sch_record_tab,
		 p_project_id             => p_sch_except_record.project_id,
		 p_schedule_type_code     => p_sch_except_record.schedule_type_code,
		 p_assignment_id          => p_sch_except_record.assignment_id,
		 p_calendar_id          => p_sch_except_record.calendar_id,
		 p_assignment_status_code => p_sch_record.assignment_status_code,
		 x_return_status          => l_x_return_status,
		 x_msg_count              => x_msg_count,
		 x_msg_data               => x_msg_data
																			 );


	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_new_pattern');
		 raise;


END create_new_pattern;

-- This procedure will create the new schedule the with passed status for the given period
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SCHEXCEPTRECORD      YES       It has the exception record
-- P_Sch_Record                 SCHEDULERECORD       YES       It has the schedule record
-- In Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP       YES       It store the new schedule
--

PROCEDURE create_new_status(
														p_sch_except_record  IN     pa_schedule_glob.SchExceptRecord,
														p_sch_record         IN     pa_schedule_glob.ScheduleRecord,
														x_sch_record_tab     IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
														x_return_status      OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
														x_msg_count          OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
														x_msg_data           OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
													 )
IS
	 Status_change_not_allowed   EXCEPTION;
BEGIN
	 l_x_return_status                           := FND_API.G_RET_STS_SUCCESS;
	 x_sch_record_tab(1).start_date              := p_sch_except_record.start_date;
	 x_sch_record_tab(1).end_date                := p_sch_except_record.end_date;
	 x_sch_record_tab(1).assignment_status_code  := p_sch_except_record.assignment_status_code;

	 -- Check if the user is allowed to change the status.

	 IF ( ( p_sch_except_record.assignment_status_code <> p_sch_record.assignment_status_code) AND
		 (PA_PROJECT_STUS_UTILS.Allow_Status_Change(
		 o_status_code  =>  p_sch_record.assignment_status_code ,
		 n_status_code  => p_sch_except_record.assignment_status_code) <> 'Y' ) ) THEN
			Raise  Status_change_not_allowed;
	 END IF;

	 -- Updating the records with the given status
	 PA_SCHEDULE_UTILS.update_sch_rec_tab(x_sch_record_tab,
		 p_project_id             => p_sch_except_record.project_id,
		 p_schedule_type_code     => p_sch_except_record.schedule_type_code,
		 p_assignment_id          => p_sch_except_record.assignment_id,
		 p_calendar_id            => p_sch_except_record.calendar_id,
		 P_monday_hours           => p_sch_record.Monday_hours,
		 P_Tuesday_hours          => p_sch_record.Tuesday_hours,
		 P_Wednesday_hours        => p_sch_record.Wednesday_hours,
		 P_Thursday_hours         => p_sch_record.Thursday_hours,
		 P_Friday_hours           => p_sch_record.Friday_hours,
		 P_Saturday_hours         => p_sch_record.Saturday_hours,
		 P_Sunday_hours           => p_sch_record.Sunday_hours,
		 x_return_status          => l_x_return_status,
		 x_msg_count              => x_msg_count,
		 x_msg_data               => x_msg_data
																			 );

	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN Status_change_not_allowed THEN
		 PA_UTILS.add_message('PA','PA_STATUS_CANT_CHANGE');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_count := 1;
		 x_msg_data := 'PA_STATUS_CANT_CHANGE';

	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_new_status');
		 raise;

END create_new_status;

-- This procedure is called from change_schedule procedure. This procedure will apply 'CHANGE DURATION'
-- exception on the schedule details. Output of this procedure is the resultant schedule records.
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SCHEXCEPTRECORD      YES       It has the exception record
-- P_Sch_Record                 SCHEDULERECORD       YES       It has the schedule record
-- In Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP       YES       It store the new schedule
--

PROCEDURE apply_change_duration
	( p_sch_record_tab    IN     pa_schedule_glob.ScheduleTabTyp,
		p_sch_except_record IN     pa_schedule_glob.SchExceptRecord,
		x_sch_record_tab    IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
		x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
		x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_temp_p_sch_record_tab  PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_out_tr_sch_rec_tab     PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_tr_sch_rec_tab    PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_except_rec        PA_SCHEDULE_GLOB.SchExceptRecord;
	 l_I                      NUMBER;
	 l_temp_first             NUMBER;
	 l_temp_last              NUMBER;
	 l_stat_date_done         BOOLEAN;
	 l_end_date_done          BOOLEAN;
	 l_copy_cur_sch           BOOLEAN;
	 l_cur_exp_start_date     DATE;
	 l_cur_exp_end_date       DATE;
	 l_chg_exp_start_date     DATE;
	 l_chg_exp_end_date       DATE;
/* Added the below parameters for 7663765 */
 	 l_shifted_days           NUMBER := 0;
	 l_difference_days        NUMBER := 0;
	 l_shift_unit_code        VARCHAR2(20) := NULL;

BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;
	 PA_SCHEDULE_UTILS.log_message(1,'start of the apply_change_duration API ....... ');

	 l_stat_date_done := false;
	 l_end_date_done  := false;

	 l_cur_exp_start_date := p_sch_except_record.start_date;
	 l_cur_exp_end_date   := p_sch_except_record.end_date;

	 l_chg_exp_start_date := p_sch_except_record.start_date;
	 l_chg_exp_end_date   := p_sch_except_record.end_date;

	 -- Copying this schedule record for the further calculation
	 PA_SCHEDULE_UTILS.copy_schedule_rec_tab(p_sch_record_tab,
		 p_sch_record_tab.first,
		 p_sch_record_tab.last,
		 l_temp_p_sch_record_tab,
		 l_x_return_status,
		 x_msg_count,
		 x_msg_data );

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			-- Copying exception record for the further calculation
			PA_SCHEDULE_UTILS.copy_except_record(p_sch_except_record,
				l_temp_except_rec,
				l_x_return_status,
				x_msg_count,
				x_msg_data );
	 END IF;

	 l_temp_first := l_temp_p_sch_record_tab.first;
	 l_temp_last := l_temp_p_sch_record_tab.last;

/* Uncommented below for bug 7663765 */
         ----------------------------------------------------------------------------------------------
         --
         --  Logic For Duration Shift
         --
         ----------------------------------------------------------------------------------------------
         IF (p_sch_except_record.exception_type_code = 'DURATION_PATTERN_SHIFT') THEN

             -- If p_number_of_shift is not null, calculate the new start_date and end_date by adding
             -- or substracting p_number_of_shift from p_asgn_start_date and p_asgn_end_date
             IF (p_sch_except_record.number_of_shift is NOT NULL) THEN

                 -- compute shifted_days
                 IF (p_sch_except_record.duration_shift_unit_code = 'DAYS') THEN
                     l_shifted_days := p_sch_except_record.number_of_shift;
                 ELSIF (p_sch_except_record.duration_shift_unit_code = 'WEEKS') THEN
                     l_shifted_days := p_sch_except_record.number_of_shift*7;
                 ELSIF (p_sch_except_record.duration_shift_unit_code = 'MONTHS') THEN
				     l_shift_unit_code := 'MONTHS';
                     l_shifted_days := p_sch_except_record.number_of_shift;
                 END IF;

                 -- set start_Date, end_date according to shift_type_code and shifed_days
	         IF (p_sch_except_record.duration_shift_type_code = 'FORWARD') THEN
				l_difference_days :=  l_shifted_days;
	         ELSIF (p_sch_except_record.duration_shift_type_code = 'BACKWARD') THEN
				l_difference_days := -1 * l_shifted_days;
	         END IF;

             END IF;

         END IF; -- IF (exception_type_code = 'RETAIN_DURATION_PATTERN_SHIFT')

/* Ends uncommenting*/

	 PA_SCHEDULE_UTILS.log_message(1,'SCH_START ',l_temp_p_sch_record_tab);

	 PA_SCHEDULE_UTILS.log_message(1,'START EXCEPT START_DATE '||p_sch_except_record.start_date||' END_DATE '
		 ||p_sch_except_record.end_date);

	 -- Exception date is falling outside the start date and end date of the schedule
	 IF ( p_sch_except_record.start_date IS NOT NULL ) AND
		 ( p_sch_except_record.end_date IS NOT NULL )  AND
		 ( (  p_sch_except_record.end_date <
		 l_temp_p_sch_record_tab(l_temp_first).start_date  )
		 OR
		 (  p_sch_except_record.start_date  >
		 l_temp_p_sch_record_tab(l_temp_last).end_date     ) ) THEN

			PA_SCHEDULE_UTILS.log_message(1,'out side boundary condition ');

			l_stat_date_done  := true;
			l_end_date_done   := true;
			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Marking the schedule record for deletion
				 PA_SCHEDULE_UTILS.mark_del_sch_rec_tab ( l_temp_p_sch_record_tab.first,
					 l_temp_p_sch_record_tab.last,
					 l_temp_p_sch_record_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data);
			END IF;

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Create the new schedule after applying the exception i.e after change the duration
				 create_new_schedule( p_sch_except_record,
					 l_temp_p_sch_record_tab(l_temp_first),
					 l_out_tr_sch_rec_tab,
					 l_difference_days, -- 7663765
					 l_shift_unit_code, -- 7663765
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data );
			END IF;

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Adding the previous record into the new record
				 --7663765
			/*  if (p_sch_except_record.exception_type_code = 'DURATION_PATTERN_SHIFT') then
				PA_SCHEDULE_UTILS.copy_schedule_rec_tab ( l_temp_p_sch_record_tab ,
					l_temp_p_sch_record_tab.first,
					l_temp_p_sch_record_tab.last,
					l_out_tr_sch_rec_tab,
					l_x_return_status,
					x_msg_count,
					x_msg_data );
			  else */
				 PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
					 l_temp_p_sch_record_tab.first,
					 l_temp_p_sch_record_tab.last,
					 l_out_tr_sch_rec_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data );
			  /* end if; */ /* commented for bug 9229210 */
			END IF;
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(2,'BEFORE LOOP');

	 l_I  := l_temp_p_sch_record_tab.first ;

	 IF ( p_sch_except_record.start_date IS NULL ) THEN
			l_stat_date_done := true;
	 END IF;
	 IF ( p_sch_except_record.end_date IS NULL ) THEN
			l_end_date_done := true;
	 END IF;

	 LOOP
			PA_SCHEDULE_UTILS.log_message(2,'LOOP START (l_I='||to_char(l_I)||') s: '||
				l_temp_p_sch_record_tab(l_I).start_date||' e:  '||
				l_temp_p_sch_record_tab(l_I).end_date );

			l_copy_cur_sch := false;

			-- If the exception start date is falling under the end date of the schedule and outside the start date
			-- of the schedule then we will create a record which will be having start date as exception date and
			-- end date will be one day minus from the start date of the scheule for the first record
			IF ( l_stat_date_done = false)  THEN
				 IF (( p_sch_except_record.start_date  <= l_temp_p_sch_record_tab(l_I).end_date )) THEN

						PA_SCHEDULE_UTILS.log_message(2,'inside exp_start_date <= sch_start_date ');

						l_stat_date_done := true;
						IF ( ( l_I = l_temp_first ) AND
							( p_sch_except_record.start_date
							< l_temp_p_sch_record_tab(l_I).start_date )) THEN

							 PA_SCHEDULE_UTILS.log_message(2,'inside exp_start_date < sch_start_date AND First shift ');

							 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
									PA_SCHEDULE_UTILS.update_except_record(px_except_record => l_temp_except_rec,
										p_start_date => p_sch_except_record.start_date,
										p_end_date => l_temp_p_sch_record_tab( l_temp_first).start_date -1,
										x_return_status => l_x_return_status,
										x_msg_count => x_msg_count,
										x_msg_data => x_msg_data );
							 END IF;

							 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
									create_new_schedule( l_temp_except_rec,
										l_temp_p_sch_record_tab(l_temp_first),
										l_out_tr_sch_rec_tab,
										l_difference_days, -- 7663765
										l_shift_unit_code, -- 7663765
										l_x_return_status,
										x_msg_count,
										x_msg_data );
							 END IF;
						ELSE

							 PA_SCHEDULE_UTILS.log_message(2,'inside exp_start_date <= sch_start_date AND NOT Last shift ');

							 l_temp_p_sch_record_tab(l_I).start_date := p_sch_except_record.start_date;
							 l_temp_p_sch_record_tab(l_I).change_type_code := 'U';
						END IF;

						IF ( l_end_date_done )  THEN
							 l_copy_cur_sch := true;
							 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							 -- 7663765
                         /* if (p_sch_except_record.exception_type_code = 'DURATION_PATTERN_SHIFT') then
							PA_SCHEDULE_UTILS.copy_schedule_rec_tab ( l_temp_p_sch_record_tab ,
								l_I,
								l_temp_p_sch_record_tab.last,
								l_out_tr_sch_rec_tab,
								l_x_return_status,
								x_msg_count,
								x_msg_data );
						  else */
							 PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
								 l_I,
								 l_temp_p_sch_record_tab.last,
								 l_out_tr_sch_rec_tab,
								 l_x_return_status,
								 x_msg_count,
								 x_msg_data );
						 /*  end if;	*/ /* commented for bug 9229210 */
							 END IF;

						END IF;
				 ELSE
						PA_SCHEDULE_UTILS.log_message(2,'inside exp_start_date >  sch_start_date  AND MARKING SHIFT as DELETE');
						l_temp_p_sch_record_tab(l_I).change_type_code := 'D';
				 END IF; -- start_date cond if */
			END IF; -- l_stat_date_done if */

			IF ( l_end_date_done = false)  THEN
				 IF (( p_sch_except_record.end_date  <= l_temp_p_sch_record_tab(l_I).end_date )) THEN
						l_end_date_done := true;

						PA_SCHEDULE_UTILS.log_message(2,'inside exp_end_date <= sch_end_date ');

						l_temp_p_sch_record_tab(l_I).end_date := p_sch_except_record.end_date;
						l_temp_p_sch_record_tab(l_I).change_type_code := 'U';

						IF ( l_I < l_temp_last ) THEN

							 PA_SCHEDULE_UTILS.log_message(2,'inside exp_end_date <= sch_end_date AND MARKING DELETE ');
							 --  Mark remaining shifts as delete. */
							 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
									PA_SCHEDULE_UTILS.mark_del_sch_rec_tab ( l_temp_p_sch_record_tab.next(l_I),
										l_temp_p_sch_record_tab.last,
										l_temp_p_sch_record_tab,
										l_x_return_status,
										x_msg_count,
										x_msg_data );
							 END IF;
						END IF;
						l_copy_cur_sch := true;
						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							 PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
								 l_I,
								 l_temp_p_sch_record_tab.last,
								 l_out_tr_sch_rec_tab,
								 l_x_return_status,
								 x_msg_count,
								 x_msg_data );
						END IF;
				 ELSIF ( ( p_sch_except_record.end_date  >  l_temp_p_sch_record_tab(l_I).end_date ) AND
					 ( l_I = l_temp_last ) ) THEN

						PA_SCHEDULE_UTILS.log_message(2,'inside exp_end_date >  sch_end_date AND LAST SHIFT ');

						l_copy_cur_sch := true;
						l_end_date_done := true;
						-- Copy this shift into l_out_tr_sch_rec_tab;  */
						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							 PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
								 l_I,
								 l_I,
								 l_out_tr_sch_rec_tab,
								 l_x_return_status,
								 x_msg_count,
								 x_msg_data );
						END IF;

						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							 PA_SCHEDULE_UTILS.update_except_record(px_except_record => l_temp_except_rec,
								 p_start_date => l_temp_p_sch_record_tab(l_I).end_date +1 ,
								 p_end_date => p_sch_except_record.end_date,
								 x_return_status => l_x_return_status,
								 x_msg_count => x_msg_count,
								 x_msg_data => x_msg_data );

						END IF;

						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							 create_new_schedule( l_temp_except_rec,
								 l_temp_p_sch_record_tab(l_temp_first),
								 l_temp_tr_sch_rec_tab,
								 l_difference_days, -- 7663765
								 l_shift_unit_code, -- 7663765
								 l_x_return_status,
								 x_msg_count,
								 x_msg_data );
						END IF;

						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						-- 7663765
                         /*  if (p_sch_except_record.exception_type_code = 'DURATION_PATTERN_SHIFT') then
							PA_SCHEDULE_UTILS.copy_schedule_rec_tab ( l_temp_tr_sch_rec_tab ,
								l_temp_tr_sch_rec_tab.first,
								l_temp_tr_sch_rec_tab.last,
								l_out_tr_sch_rec_tab,
								l_x_return_status,
								x_msg_count,
								x_msg_data );
						  else */
							 PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_tr_sch_rec_tab ,
								 l_temp_tr_sch_rec_tab.first,
								 l_temp_tr_sch_rec_tab.last,
								 l_out_tr_sch_rec_tab,
								 l_x_return_status,
								 x_msg_count,
								 x_msg_data );
						  /* end if; */ /* commented for bug 9229210 */
						END IF;
				 END IF;  --  end_date cond if */
			END IF; -- l_end_date_done if */

			IF ( l_copy_cur_sch = false ) THEN
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
							l_I,
							l_I,
							l_out_tr_sch_rec_tab,
							l_x_return_status,
							x_msg_count,
							x_msg_data );
				 END IF;
			END IF;

			IF ( ( ( l_stat_date_done ) AND (l_end_date_done) )
				OR
				( l_I = l_temp_last ) ) THEN
				 EXIT;
			ELSE
				 l_I := l_temp_p_sch_record_tab.next(l_I);
			END IF;

	 END LOOP;

	 PA_SCHEDULE_UTILS.log_message(2,'DONE_CHANGE_DURATION :  out_tr.count : '||l_out_tr_sch_rec_tab.count);

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_UTILS.copy_schedule_rec_tab ( l_out_tr_sch_rec_tab ,
				l_out_tr_sch_rec_tab.first,
				l_out_tr_sch_rec_tab.last,
				x_sch_record_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data );
	 END IF;

	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'apply_change_duration');

		 PA_SCHEDULE_UTILS.log_message(1,'ERROR while running apply...');
		 raise;
END apply_change_duration;

-- This procedure is caled from change_schedule procedure .This procedure will apply changes on schedule
-- other than 'CHANGE DURATION' exception on the schedule details. Out put of this procedure is the resultant
-- schedule record
-- Input parameters
-- Parameters                   Type                 Required  Description
-- P_Sch_Except_Record_Tab      SCHEXCEPTRECORD      YES       It has the exception record
-- P_Sch_Record                 SCHEDULERECORD       YES       It has the schedule record
-- In Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP       YES       It store the new schedule
--


PROCEDURE apply_other_changes
	( p_sch_record_tab    IN     pa_schedule_glob.ScheduleTabTyp,
		p_sch_except_record IN     pa_schedule_glob.SchExceptRecord,
		x_sch_record_tab    IN OUT NOCOPY pa_schedule_glob.ScheduleTabTyp,
		x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
		x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
		x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

	 l_temp_p_sch_record_tab  PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_out_tr_sch_rec_tab     PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_tr_sch_rec_tab    PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_temp_except_rec        PA_SCHEDULE_GLOB.SchExceptRecord;
	 l_I                      NUMBER;
	 l_sch_first              NUMBER;
	 l_sch_last               NUMBER;
	 l_chg_exp_start_date     DATE;
	 l_chg_exp_end_date       DATE;
	 l_curr_exp_start_date    DATE;
	 l_curr_exp_end_date      DATE;
	 l_curr_sch_start_date    DATE;
	 l_curr_sch_end_date      DATE;
	 l_change_done            BOOLEAN;
	 l_copy_cur_sch           BOOLEAN;
	 l_create_new_sch         BOOLEAN;
	 l_create_third_sch       BOOLEAN;

BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;
	 PA_SCHEDULE_UTILS.copy_schedule_rec_tab(p_sch_record_tab,
		 p_sch_record_tab.first,
		 p_sch_record_tab.last,
		 l_temp_p_sch_record_tab,
		 l_x_return_status,
		 x_msg_count,
		 x_msg_data );

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_UTILS.copy_except_record(p_sch_except_record,
				l_temp_except_rec,
				l_x_return_status,
				x_msg_count,
				x_msg_data );
	 END IF;

	 l_sch_first := l_temp_p_sch_record_tab.first;
	 l_sch_last := l_temp_p_sch_record_tab.last;

	 l_curr_exp_start_date := p_sch_except_record.start_date;
	 l_curr_exp_end_date   := p_sch_except_record.end_date;

	 PA_SCHEDULE_UTILS.log_message(1,'SCH_START ',l_temp_p_sch_record_tab);
	 PA_SCHEDULE_UTILS.log_message(1,'START EXCEPT START_DATE '||l_curr_exp_start_date||' END_DATE '||l_curr_exp_end_date);

	 l_I  := l_temp_p_sch_record_tab.first ;

	 LOOP
			l_copy_cur_sch := false;
			l_create_new_sch := false;
			l_create_third_sch := false;

			l_curr_sch_start_date := l_temp_p_sch_record_tab(l_I).start_date;
			l_curr_sch_end_date   := l_temp_p_sch_record_tab(l_I).end_date;

			PA_SCHEDULE_UTILS.log_message(2,'SHIFT('||l_I||') '||l_curr_sch_start_date||' '||l_curr_sch_end_date);
			IF ( l_curr_exp_start_date  <= l_curr_sch_end_date ) THEN

				 PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_start_date  <= l_curr_sch_end_date if .... ');
				 IF ( l_curr_exp_start_date <= l_curr_sch_start_date ) THEN

						PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_start_date  <= l_curr_sch_start_date if .... ');
						l_chg_exp_start_date := l_curr_sch_start_date;

						IF ( l_curr_exp_end_date < l_curr_sch_end_date ) THEN

							 PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_end_date < l_curr_sch_end_date  if ...... ');
							 l_chg_exp_end_date := l_curr_exp_end_date;
							 l_temp_p_sch_record_tab(l_I).start_date := l_curr_exp_end_date + 1;
 	 						 IF (nvl(l_temp_p_sch_record_tab(l_I).change_type_code,'U')  <> 'I') THEN -- Added If condition for 4349232
								l_temp_p_sch_record_tab(l_I).change_type_code := 'U';
							 END IF;

						ELSIF ( l_curr_exp_end_date >=  l_curr_sch_end_date ) THEN

							 PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_end_date >= l_curr_sch_end_date  if ...... ');
							 l_chg_exp_end_date := l_curr_sch_end_date;
							 l_temp_p_sch_record_tab(l_I).change_type_code := 'D';

						END IF;
						l_create_new_sch := true;

						IF ( l_curr_exp_end_date <= l_curr_sch_end_date ) THEN
							 PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_end_date <= l_curr_sch_end_date  if ........... ');
							 l_change_done := true;
						END IF;

				 ELSIF ( l_curr_exp_start_date >  l_curr_sch_start_date ) THEN

						PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_start_date >  l_curr_sch_start_date if ...... ');

						l_temp_p_sch_record_tab(l_I).end_date := l_curr_exp_start_date - 1;

						IF (nvl(l_temp_p_sch_record_tab(l_I).change_type_code,'U')  <> 'I') THEN -- Added If condition for 4287560
							l_temp_p_sch_record_tab(l_I).change_type_code := 'U';
						END IF;

						l_copy_cur_sch := true;
						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							 PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
								 l_I,
								 l_I,
								 l_out_tr_sch_rec_tab,
								 l_x_return_status,
								 x_msg_count,
								 x_msg_data );
						END IF;

						PA_SCHEDULE_UTILS.log_message(2,'l_out_tr_sch_rec_tab.count '||to_char(l_out_tr_sch_rec_tab.count));
						l_chg_exp_start_date := l_curr_exp_start_date;
						IF ( l_curr_exp_end_date > l_curr_sch_end_date )  THEN
							 PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_end_date > l_curr_sch_end_date if ....... ');
							 l_chg_exp_end_date := l_curr_sch_end_date;
						ELSE
							 PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_end_date <= l_curr_sch_end_date if ....... ');
							 l_chg_exp_end_date := l_curr_exp_end_date;
							 l_change_done := true;
						END IF;
						l_create_new_sch := true;

						IF ( l_curr_exp_end_date < l_curr_sch_end_date ) THEN
							 PA_SCHEDULE_UTILS.log_message(2,'inside l_curr_exp_end_date < l_curr_sch_end_date if .... ');
							 l_create_third_sch := true;
							 l_change_done := true;
						END IF;

				 END IF; -- end of level 2 if */
			END IF; -- end of level 1 if */

			IF ( l_create_new_sch ) THEN
				 PA_SCHEDULE_UTILS.log_message(2,'inside l_create_new_sch if ........'||'status '||l_x_return_status);
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.update_except_record(px_except_record => l_temp_except_rec,
							p_start_date => l_chg_exp_start_date,
								p_end_date => l_chg_exp_end_date,
									x_return_status => l_x_return_status,
									x_msg_count => x_msg_count,
									x_msg_data => x_msg_data );
				 END IF;

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						create_new_schedule( l_temp_except_rec,
							l_temp_p_sch_record_tab(l_I),
							l_temp_tr_sch_rec_tab,
							0,   -- 7663765
							NULL, --7663765
							l_x_return_status,
							x_msg_count,
							x_msg_data );
				 END IF;
				 PA_SCHEDULE_UTILS.log_message(2,'l_temp_tr_sch_rec_tab.count '||to_char(l_temp_tr_sch_rec_tab.count)||
					 l_x_return_status);

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_tr_sch_rec_tab ,
							l_temp_tr_sch_rec_tab.first,
							l_temp_tr_sch_rec_tab.last,
							l_out_tr_sch_rec_tab,
							l_x_return_status,
							x_msg_count,
							x_msg_data );
				 END IF;
				 PA_SCHEDULE_UTILS.log_message(2,'l_out_tr_sch_rec_tab.count '||to_char(l_out_tr_sch_rec_tab.count));
			END IF;

			IF ( l_create_third_sch = true ) THEN

				 PA_SCHEDULE_UTILS.log_message(2,'inside l_create_third_sch if ........');
				 l_temp_p_sch_record_tab(l_I).start_date := l_curr_exp_end_date + 1;
				 l_temp_p_sch_record_tab(l_I).end_date := l_curr_sch_end_date;
				 l_temp_p_sch_record_tab(l_I).change_type_code := 'I';
				 l_temp_p_sch_record_tab(l_I).schedule_id := -1; -- Included for Bug 4616327
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
							l_I,
							l_I,
							l_out_tr_sch_rec_tab,
							l_x_return_status,
							x_msg_count,
							x_msg_data );
				 END IF;

				 PA_SCHEDULE_UTILS.log_message(2,'l_out_tr_sch_rec_tab.count '||to_char(l_out_tr_sch_rec_tab.count));
			END IF;

			IF ( l_copy_cur_sch = false ) THEN
				 PA_SCHEDULE_UTILS.log_message(2,'inside l_copy_cur_sch if ........');
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
							l_I,
							l_I,
							l_out_tr_sch_rec_tab,
							l_x_return_status,
							x_msg_count,
							x_msg_data );
				 END IF;
				 PA_SCHEDULE_UTILS.log_message(2,'l_out_tr_sch_rec_tab.count '||to_char(l_out_tr_sch_rec_tab.count));
			END IF;

			IF ( l_change_done ) OR ( l_I = l_sch_last ) THEN

				 PA_SCHEDULE_UTILS.log_message(2,'inside l_change_done if ........');
				 IF ( l_I < l_sch_last ) THEN
						PA_SCHEDULE_UTILS.log_message(2,'inside l_I < l_sch_last if ....... ');
						IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
							 PA_SCHEDULE_UTILS.add_schedule_rec_tab ( l_temp_p_sch_record_tab ,
								 l_temp_p_sch_record_tab.next(l_I),
								 l_sch_last,
								 l_out_tr_sch_rec_tab,
								 l_x_return_status,
								 x_msg_count,
								 x_msg_data );
						END IF;
						PA_SCHEDULE_UTILS.log_message(2,'l_out_tr_sch_rec_tab.count '||to_char(l_out_tr_sch_rec_tab.count));
				 END IF;
				 EXIT;
			ELSE
				 PA_SCHEDULE_UTILS.log_message(2,'go to next shift ..... ');
				 l_I := l_temp_p_sch_record_tab.next(l_I);
			END IF;

	 END LOOP;

	 PA_SCHEDULE_UTILS.log_message(2,'end of the loop l_out_tr_sch_rec_tab.count '||
		 to_char(l_out_tr_sch_rec_tab.count)||'status '||l_x_return_status);
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_UTILS.copy_schedule_rec_tab ( l_out_tr_sch_rec_tab ,
				l_out_tr_sch_rec_tab.first,
				l_out_tr_sch_rec_tab.last,
				x_sch_record_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data );
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(2,'end of the loop x_sch_record_tab.count '||to_char(x_sch_record_tab.count));
	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS  THEN
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'apply_other_change');

		 PA_SCHEDULE_UTILS.log_message(2,'ERROR in apply_other_changes ....');
		 PA_SCHEDULE_UTILS.log_message(2,sqlerrm);
		 raise;
END apply_other_changes;


-- This procedure will apply the assignment change for duration change
-- Input parameters
-- Parameters                   Type                 Required  Description
-- Sch_Except_Record_Tab        SCHEXCEPTTABTYP      YES       It has the exception record
-- Chg_Tr_Sch_Rec_Tab           SCHEDULETABTYP       YES       It has the schedule record
--

PROCEDURE apply_assignment_change (
																	 p_record_version_number   IN    NUMBER,
																	 chg_tr_sch_rec_tab    IN     PA_SCHEDULE_GLOB.ScheduleTabTyp,
																	 sch_except_record_tab IN     PA_SCHEDULE_GLOB.SchExceptTabTyp,
																	 p_called_by_proj_party          IN  VARCHAR2         := 'N', -- Added for Bug 6631033
																	 x_return_status       OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																	 x_msg_count           OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
																	 x_msg_data            OUT    NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_t_start_date       DATE := NULL;  -- To store exception start date
	 l_t_end_date         DATE := NULL;  -- To store exception end date
	 l_t_multi_flag       VARCHAR2(1);   -- To stote value Y or N for multiple status
	 l_t_assignment_id    NUMBER;        -- To store the assignment Id for the records to be procesed
	 -- added for Bug fix: 4537865
	 l_new_t_assignment_id	NUMBER;
	 -- added for Bug fix: 4537865
	 l_change_flag        BOOLEAN;       -- To store the value TRUE or FALSE if the status is changed from previous record
	 l_prev_status        VARCHAR2(30);  -- To store the status of the previous record for
	 -- compareing with the current record
	 l_curr_status        VARCHAR2(30);  -- To store the current status of the assignment.
	 -- This will be used to update the assignments table
	 -- if there is only one status .
	 l_J                  NUMBER;        -- To store the first record of the chg_tr_sch_rec_tab

	 l_t_project_id            NUMBER;
	 l_t_project_role_id        NUMBER ;  -- To Store project role id
	 l_t_resource_source_id     NUMBER ;  -- To Store resource source id
	 l_t_resource_id            NUMBER ;
	 l_t_project_party_id       NUMBER ;  -- To Store project party id
	 l_t_record_version_number  NUMBER;
	 l_t_asgn_start_date        DATE   ;  -- To Store Assignment Start Date
	 l_t_asgn_end_date          DATE   ;  -- To Store Assignment End Date
	 l_wf_type                  VARCHAR2(80);
	 l_wf_item_type             VARCHAR2(2000);
	 l_wf_process               VARCHAR2(2000);
	 	 l_new_calendar_id          pa_project_assignments.calendar_id%TYPE; ---- bug#9071974
     l_RESOURCE_CALENDAR_PERCENT   pa_project_assignments.RESOURCE_CALENDAR_PERCENT%TYPE; ---- bug#9071974
BEGIN
	 -- Intilizing the variable */
	 l_t_multi_flag    := 'N';
	 l_change_flag     := FALSE;
	 l_t_assignment_id := chg_tr_sch_rec_tab(1).assignment_id;
	 l_t_project_id    := chg_tr_sch_rec_tab(1).project_id;
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;   -- Storing the status for tracking the error

	 	 l_new_calendar_id := Nvl (sch_except_record_tab(1).change_calendar_id,FND_API.G_MISS_NUM); ---- bug#9071974
     l_RESOURCE_CALENDAR_PERCENT := Nvl (sch_except_record_tab(1).RESOURCE_CALENDAR_PERCENT,FND_API.G_MISS_NUM); ---- bug#9071974

	 -- Loop for processing the exception records from exception table type variable for change duration */
	 IF (sch_except_record_tab.count > 0 ) THEN
			FOR I IN sch_except_record_tab.first..sch_except_record_tab.last LOOP
				 --7663765
				 IF ( (sch_except_record_tab(I).exception_type_code = 'CHANGE_DURATION') OR
                                      (sch_except_record_tab(I).exception_type_code = 'SHIFT_DURATION')
                       OR (sch_except_record_tab(I).exception_type_code = 'DURATION_PATTERN_SHIFT')  ) THEN
						l_t_start_date      := sch_except_record_tab(I).start_date;
						l_t_end_date        := sch_except_record_tab(I).end_date;
						l_change_flag       := TRUE;

				 END IF;

				 IF (sch_except_record_tab(I).exception_type_code = 'CHANGE_STATUS') THEN
						l_change_flag := TRUE;
				 END IF;

			END LOOP;
	 ELSE
			Raise l_empty_tab_record;
	 END IF;

	 -- if the tab type does not contain any data */
	 IF (chg_tr_sch_rec_tab.count = 0 ) THEN
			Raise l_empty_tab_record;
	 ELSE
			l_J  := chg_tr_sch_rec_tab.FIRST;
	 END IF;

	 -- Loop for processing  schedule records from schedule tab type variable if the status is changed from revious one */
	 l_prev_status     := chg_tr_sch_rec_tab(l_J).assignment_status_code;
	 l_curr_status     := chg_tr_sch_rec_tab(l_J).assignment_status_code;

	 FOR K IN chg_tr_sch_rec_tab.FIRST..chg_tr_sch_rec_tab.LAST LOOP

			IF ( l_prev_status <> chg_tr_sch_rec_tab(K).assignment_status_code) THEN
				 l_t_multi_flag   := 'Y';
				 l_change_flag    := TRUE;
				 l_curr_status   := null;
				 EXIT;
			END IF;

	 END LOOP;

	 PA_SCHEDULE_UTILS.log_message(1,'20: ' || l_x_return_status ||
		 ' ' || x_msg_count ||
		 ' ' || x_msg_data);

	 -- if the records is having more than one status then updating the table for it column multi flag */
	 IF (l_change_flag) THEN
	  -- bug#9071974
			PA_PROJECT_ASSIGNMENTS_PKG.Update_Row(
				p_record_version_number => p_record_version_number,
				p_assignment_id => l_t_assignment_id,
				p_start_date  => nvl(l_t_start_date,FND_API.G_MISS_DATE),
				p_end_date    => nvl(l_t_end_date,FND_API.G_MISS_DATE),
				p_multiple_status_flag => l_t_multi_flag,
				p_status_code => l_curr_status,
				p_assignment_effort =>
				pa_schedule_utils.get_num_hours(l_t_project_id, l_t_assignment_id),
			   p_calendar_id => l_new_calendar_id,
        p_resource_calendar_percent => l_resource_calendar_percent,
				x_return_status => l_x_return_status );
	 ELSE
	 -- bug#9071974
			PA_PROJECT_ASSIGNMENTS_PKG.Update_Row(
				p_record_version_number => p_record_version_number,
				p_assignment_id => l_t_assignment_id,
				p_assignment_effort =>
				pa_schedule_utils.get_num_hours(l_t_project_id, l_t_assignment_id),
					p_calendar_id => l_new_calendar_id,
                p_resource_calendar_percent => l_resource_calendar_percent,
				x_return_status => l_x_return_status );
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'20: ' || l_x_return_status ||
		 ' ' || x_msg_count ||
		 ' ' || x_msg_data);

	 -- If assignment record is successfully updated then  call procedure to update pa project parties.
	 --
   -- jmarques (1590046): Added STAFFED_ADMIN_ASSIGNMENT check to if statement.
	 IF ( ( l_x_return_status = FND_API.G_RET_STS_SUCCESS ) AND
		    ( (chg_tr_sch_rec_tab(l_J).schedule_type_code = 'STAFFED_ASSIGNMENT') OR
          (chg_tr_sch_rec_tab(l_J).schedule_type_code = 'STAFFED_ADMIN_ASSIGNMENT') )
      ) THEN

			SELECT
				proj_part.PROJECT_ROLE_ID,
					proj_part.RESOURCE_SOURCE_ID,
					proj_part.PROJECT_PARTY_ID,
					proj_part.RESOURCE_ID,
					proj_part.RECORD_VERSION_NUMBER,
					proj_asgn.START_DATE,
					proj_asgn.END_DATE
					INTO
					l_t_project_role_id,
					l_t_resource_source_id,
					l_t_project_party_id,
					l_t_resource_id,
					l_t_record_version_number,
					l_t_asgn_start_date,
					l_t_asgn_end_date
					FROM pa_project_parties proj_part,
					pa_project_assignments proj_asgn
					WHERE proj_asgn.PROJECT_PARTY_ID = proj_part.PROJECT_PARTY_ID
					AND   proj_asgn.ASSIGNMENT_ID = l_t_assignment_id;

				IF ( l_t_start_date is NULL ) THEN
					 l_t_start_date := l_t_asgn_start_date;
				END IF;

				IF ( l_t_end_date   is NULL ) THEN
					 l_t_end_date   := l_t_asgn_end_date;
				END IF;

				PA_SCHEDULE_UTILS.log_message(1,'21: ' || l_x_return_status ||
					' ' || x_msg_count ||
					' ' || x_msg_data);

			IF p_called_by_proj_party = 'N' then  -- Bug 6631033

				pa_project_parties_pvt.UPDATE_PROJECT_PARTY(
					P_VALIDATE_ONLY => 'F',
					P_OBJECT_ID => chg_tr_sch_rec_tab(l_J).project_id,
					P_OBJECT_TYPE => 'PA_PROJECTS',
					P_PROJECT_ROLE_ID => l_t_project_role_id,
					P_RESOURCE_TYPE_ID => 101,
					P_RESOURCE_SOURCE_ID => l_t_resource_source_id,
					P_RESOURCE_ID => l_t_resource_id,
					P_START_DATE_ACTIVE => l_t_start_date ,
					P_END_DATE_ACTIVE => l_t_end_date  ,
					P_SCHEDULED_FLAG => 'Y',
					P_RECORD_VERSION_NUMBER => l_t_record_version_number,
					P_CALLING_MODULE => 'ASSIGNMENT',
					P_PROJECT_END_DATE => NULL,
					P_PROJECT_ID => chg_tr_sch_rec_tab(l_J).project_id,
					P_PROJECT_PARTY_ID => l_t_project_party_id,
					P_ASSIGNMENT_ID => l_t_assignment_id,
					P_ASSIGN_RECORD_VERSION_NUMBER => p_record_version_number,
				      --X_ASSIGNMENT_ID => l_t_assignment_id,		* Commented for Bug Fix: 4537865
					X_ASSIGNMENT_ID => l_new_t_assignment_id,	-- Added for bug fix: 4537865
					X_WF_TYPE => l_wf_type,
					X_WF_ITEM_TYPE => l_wf_item_type,
					X_WF_PROCESS => l_wf_process,
					X_RETURN_STATUS => l_x_return_status,
					X_MSG_COUNT => x_msg_count,
					X_MSG_DATA => x_msg_data );

			END IF;  -- Bug 6631033

		-- added for Bug fix: 4537865

		IF l_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
		l_t_assignment_id := l_new_t_assignment_id;
		END IF;
		-- added for Bug fix: 4537865

	 END IF;

	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN l_empty_tab_record THEN
		 x_return_status := FND_API.G_RET_STS_SUCCESS;
		 NULL;
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'apply_assignment_change');
		 raise;
END apply_assignment_change;


-- Procedure            : get_periodic_start_end
-- Purpose              : Get min start date and max end date for working days in the schedule...
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Start_Date                 DATE           YES       starting date of the open assignment
-- P_End_Date                   DATE           YES       ending date of the open assignment
-- p_task_assignment_id_tbl     SYSTEM.PA_NUM_TBL_TYPE         YES       Table of resource_assignment_id's


-- Procedure            : get_periodic_start_end
-- Purpose              : Get min start date and max end date for working days in the schedule...
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Start_Date                 DATE           YES       starting date of the open assignment
-- P_End_Date                   DATE           YES       ending date of the open assignment
-- p_task_assignment_id_tbl     SYSTEM.PA_NUM_TBL_TYPE         YES       Table of resource_assignment_id's

PROCEDURE get_periodic_start_end(
				        p_start_date                 IN  DATE,
					  p_end_date                   IN  DATE,
					  p_project_assignment_id      IN  NUMBER,
				        p_task_assignment_id_tbl     IN SYSTEM.PA_NUM_TBL_TYPE,
					  x_min_start_date             OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                x_max_end_date               OUT NOCOPY DATE, --File.Sql.39 bug 4440895
                                          p_project_id                 IN NUMBER,
                                          p_budget_version_id          IN NUMBER,
					  x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					  x_msg_count                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					  x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					     )
IS

	 Cursor C_Periodic_dates1 IS
	 select least(min(start_date), p_start_date), greatest(max(end_date), p_end_date)
         from pa_budget_lines a, pa_resource_assignments b
         where a.resource_assignment_id = b.resource_assignment_id
	 and b.project_assignment_id = p_project_assignment_id
         and b.project_id            = p_project_id
         and b.budget_version_id     = p_budget_version_id
	 and ((a.start_date between p_start_date and p_end_date) OR
              (a.end_date between p_start_date and p_end_date) OR
	      (p_start_date between a.start_date and a.end_date) OR
	      (p_end_date between a.start_date and a.end_date))
         and b.ta_display_flag = 'Y';

	 /**
       -- II phase selective Id's and using Global Temp. Table if necessary.
       --Cursor to obtain earliest periodic start date and latest periodic end date
       --(intermediate/overlapped periods only)
	 --Cursor to be confirmed

	Cursor C_task_assignment_date(p_proj_start_date IN DATE, p_proj_end_date IN DATE) IS
	 --Use commented if considering when project assgt. start date is lesser and end date greater than periods.
	 select least(min(start_date), p_proj_start_date), greatest(max(end_date), p_proj_end_date) from
	 --select min(start_date, p_proj_start_date), max(end_date, p_proj_end_date) from
	 pa_budget_lines a, pa_tmp_task_assign_ids b where
	 (a.start_date between (p_proj_start_date) and (p_proj_end_date)) OR
       (a.end_date between   (p_proj_start_date) and (p_proj_end_date)) OR
	 ((p_proj_start_date) between a.start_date and a.end_date) OR
	 ((p_proj_end_date) between a.start_date and a.end_date)
       AND a.resource_assignment_id = b.resource_assignment_id;


	Cursor C_Project_Assgt_Check is
	Select project_assignment_id from
	PA_TMP_TASK_ASSIGN_IDS where project_assignment_id = p_project_assignment_id;
	***/

BEGIN

       x_return_status := FND_API.G_RET_STS_SUCCESS ;


     OPEN  C_Periodic_dates1;
	 FETCH C_Periodic_dates1 into x_min_start_date, x_max_end_date;
	 CLOSE C_Periodic_dates1;

    	/*Added for 4996210: If dates are null then return error status */

	IF  x_min_start_date IS NULL OR x_max_end_date IS NULL THEN
		x_return_status := FND_API.G_RET_STS_ERROR;
         	x_msg_count     := 1;
		x_msg_data      := 'Error while calling get_periodic_start_end';
	END IF;

	/* End 4996210 */



EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1, 'Error in get_periodic_start_end.....'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'get_periodic_start_end');
		 raise;
END get_periodic_start_end;






-- Procedure            : create_opn_asg_schedule
-- Purpose              : Create schedule for open assignments. it get the schedule for the calendar associated
--                        with the calendar id of the open asignment and create schedules from them
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this
--                                                        assignment
-- P_Assignment_Id              NUMBER         YES       Id of that assignment which being used
--                                                       for creation of open assignment
-- P_Start_Date                 DATE           YES       starting date of the open assignment
-- P_End_Date                   DATE           YES       ending date of the open assignment
-- P_Assignment_Status_Code     VARCHAR2       YES       Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Work_Type_Id               NUMBER         NO        Id for the work type.
-- P_Task_Id                    NUMBER         NO        Id for the tasa.
-- P_Task_Percentage            NUMBER         NO        Percentage of the corresponding task.
-- p_sum_tasks_flag           VARCHAR2         YES       Indicates whether to sum task assignment periodic dates
-- p_task_assignment_id_tbl   SYSTEM.PA_NUM_TBL_TYPE REQUIRED    Indicates the task assignments to choose.



PROCEDURE create_opn_asg_schedule(p_project_id             IN  NUMBER,
					    p_calendar_id            IN  NUMBER,
					    p_assignment_id          IN  NUMBER,
					    p_start_date             IN  DATE,
					    p_end_date               IN  DATE,
					    p_assignment_status_code IN  VARCHAR2,
					    p_work_type_id               IN  NUMBER:=NULL,
					    p_task_id                    IN  NUMBER:=NULL,
					    p_task_percentage            IN  NUMBER:=NULL,
					    p_sum_tasks_flag         IN  VARCHAR2,
					    p_task_assignment_id_tbl IN  SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE(),
                                            p_budget_version_id      IN  NUMBER:= NULL,
					    x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					    x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					    x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					    )
IS

	 l_x_schedule_tab_rec     PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_new_schedule_tab_rec   PA_SCHEDULE_GLOB.ScheduleTabTyp;

	 l_start_date DATE;
	 l_end_date DATE;

       	 l_alias_name PA_RESOURCE_LIST_MEMBERS.ALIAS%TYPE;  	/*Added for 4996210 */
         l_total_hours            NUMBER; -- Bug 5126919
BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;
	 PA_SCHEDULE_UTILS.log_message(1, 'Start of the  create_oasgn_schedule  API ....');

	 PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API get_calendar_schedule ....');

	 -- New code to process task assignment summation jraj 12/19/03
	 -- Based on if p_sum_tasks_flag = Y

	 l_start_date := p_start_date;
	 l_end_date := p_end_date;

	 IF p_sum_tasks_flag = 'Y' then

	   get_periodic_start_end(  p_start_date,
					    p_end_date,
						p_assignment_id,
				        p_task_assignment_id_tbl,
					    l_start_date,
                        l_end_date,
                                        p_project_id,
                                        p_budget_version_id,
					    x_return_status,
					    x_msg_count,
					    x_msg_data
					     );

	 END IF;

 /*Bug 4996210 : If get_periodic_start_end returns error then  raise error for all the resourcelist members for which the planned work quantity is null or zero*/

	 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

			BEGIN
				IF p_task_assignment_id_tbl.COUNT > 0 THEN
					SELECT ALIAS INTO l_alias_name FROM
					pa_resource_list_members WHERE RESOURCE_LIST_MEMBER_ID = (SELECT RESOURCE_LIST_MEMBER_ID
					FROM  pa_resource_assignments WHERE resource_assignment_id = p_task_assignment_id_tbl(1));
				ELSE
					l_alias_name := NULL;
				END IF;


			EXCEPTION
			WHEN OTHERS THEN
				NULL;

			END;

		      FND_MESSAGE.SET_NAME('PA','PA_PLAN_QTY_NULL');
		      FND_MESSAGE.SET_TOKEN('TASK_ASSIG',l_alias_name);
		      FND_MSG_PUB.add;
		      RAISE  FND_API.G_EXC_ERROR;
      END IF;

     /*End for 4996210 */


	 -- Calling the PA_SCHEDULE_PVT API to get the calendar schedule
	 PA_SCHEDULE_PVT.get_calendar_schedule(p_calendar_id,
		 l_start_date,
		 l_end_date,
		 l_x_schedule_tab_rec,
		 l_x_return_status,
		 x_msg_count,
		 x_msg_data
		);


	 IF p_sum_tasks_flag = 'Y' then


	   -- Call task summation API.
	   -- and obtain new l_new_schedule_tab_rec
	   sum_task_assignments(
	        p_task_assignment_id_tbl,
                l_x_schedule_tab_rec,
                p_start_date,
	        p_end_date,
	        l_total_hours, -- Bug 5126919
                l_new_schedule_tab_rec,
	        l_x_return_status,
	        x_msg_count,
	        x_msg_data
		   );

         ELSE

               l_new_schedule_tab_rec := l_x_schedule_tab_rec;


	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API get_calendar_schedule ....');

	 PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API update_sch_rec_tab ....');
	 PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API update_sch_rec_tab ....'||l_x_return_status);

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			-- updating the passed schedule table of record for creating the schedule for open assignment
			PA_SCHEDULE_UTILS.update_sch_rec_tab(l_new_schedule_tab_rec,
				p_project_id             => p_project_id,
				p_calendar_id            => p_calendar_id,
				p_schedule_type_code     => 'OPEN_ASSIGNMENT',
				p_assignment_id          => p_assignment_id,
				p_assignment_status_code => p_assignment_status_code,
				x_return_status          => l_x_return_status,
				x_msg_count              => x_msg_count,
				x_msg_data               => x_msg_data
																					);
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API update_sch_rec_tab .....');
	 PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API insert_rows ....');
	 PA_SCHEDULE_UTILS.log_message(1,'SCH_REC',l_x_schedule_tab_rec);

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	 		-- Inserting the schedule in the PA_SCHEDULE table
			PA_SCHEDULE_PKG.insert_rows(l_new_schedule_tab_rec,
				l_x_return_status,
				x_msg_count,
				x_msg_data,
				l_total_hours  -- Bug 5126919
																 );
	 END IF;

	 -- Calling the Timeline api  to build the timeline records  for the assignment
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_TIMELINE_PVT.CREATE_TIMELINE (p_assignment_id   =>p_assignment_id    ,
				x_return_status   =>l_x_return_status  ,
				x_msg_count       =>x_msg_count        ,
				x_msg_data        =>x_msg_data         );

	 END IF;


	 PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API insert_rows ....');
	 PA_SCHEDULE_UTILS.log_message(1, 'End   of the  create_oasgn_schedule  API ....');
	 x_return_status := l_x_return_status;
EXCEPTION

	/*Added for 4996210 */
	WHEN FND_API.G_EXC_ERROR THEN
	    x_return_status := FND_API.G_RET_STS_ERROR;
	/*End 4996210 */

	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1, 'Error in create_oasgn_schedule API .....'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_opn_asg_schedule');
		 raise;

END create_opn_asg_schedule;

-- Procedure            : create_opn_asg_schedule
-- Purpose              : Add multiple open assignment schedules. Copy
--                        assignment schedules from an open or staffed
--                        assignment.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         NO       project id of the associated calendar
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this
--                                                        assignment
-- P_Assignment_Id_Tbl          PL/SQL TABLE   YES       Ids of the assignmentswhose schedules need to be created.
-- P_Source_Assignment_Id       NUMBER         NO        Id of the source assignment
-- P_Start_Date                 DATE           NO       starting date of the open assignment
-- P_End_Date                   DATE           NO       ending date of the open assignment
-- P_Assignment_Status_Code     VARCHAR2       NO       Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- p_sum_tasks_flag           VARCHAR2         NO       Indicates whether to sum task assignment periodic dates
-- p_task_assignment_id_tbl   SYSTEM.PA_NUM_TBL_TYPE  NO    Indicates the task assignments to choose.


PROCEDURE create_opn_asg_schedule(p_project_id             IN  NUMBER :=NULL,
                                  p_asgn_creation_mode     IN  VARCHAR2 := NULL, /* Added for Bug 6145532 */
				  p_calendar_id            IN  NUMBER :=NULL,
					    p_assignment_id_tbl      IN  PA_ASSIGNMENTS_PUB.assignment_id_tbl_type,
                        p_assignment_source_id   IN  NUMBER :=NULL,
					    p_start_date             IN  DATE:=NULL,
					    p_end_date               IN  DATE   := NULL,
					    p_assignment_status_code IN  VARCHAR2:= NULL,
					    p_sum_tasks_flag         IN  VARCHAR2 default null,
					    p_task_assignment_id_tbl IN  SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE(),
                                            p_budget_version_id      IN  NUMBER:= NULL,
					    x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					    x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					    x_msg_data               OUT NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

   l_assignment_id     PA_PROJECT_ASSIGNMENTS.assignment_id%TYPE;
   l_assignment_id_tbl PA_ASSIGNMENTS_PUB.assignment_id_tbl_type;
   l_x_sch_rec_tab     PA_SCHEDULE_GLOB.ScheduleTabTyp;
   l_current_sch_rec_tab    PA_SCHEDULE_GLOB.ScheduleTabTyp;
   l_temp_number       NUMBER;
BEGIN
  l_assignment_id_tbl := p_assignment_id_tbl;
  l_x_return_status := FND_API.G_RET_STS_SUCCESS;
  PA_SCHEDULE_UTILS.log_message(1, 'Start of the  create_asgn_schedule  API ....');


  -- Case I: add multiple open assignments. When p_assignment_source_id IS
  -- NULL, a new open assignment schedule needs to be generated based on the     -- calendar id passed in, then copy the schedule to the rest of assignments.
  -- Case II: Copy schedule from an existing assignment with calendar change.
  -- The two cases share the same implementation because they both need to
  -- generate new schedule based on the calendar id passed in.

  IF p_assignment_source_id IS NULL OR
     (p_assignment_source_id IS NOT NULL AND p_calendar_id IS NOT NULL) THEN
    -- Create an open assignment schedule for the first assignment in
    -- table l_assignment_id_tbl.



    PA_SCHEDULE_PVT.create_opn_asg_schedule (
              p_project_id        =>  p_project_id,
              p_calendar_id       =>  p_calendar_id,
              p_assignment_id     =>  l_assignment_id_tbl(l_assignment_id_tbl.FIRST).assignment_id,
              p_start_date        =>  p_start_date,
              p_end_date          =>  p_end_date,
              p_assignment_status_code => p_assignment_status_code,
	      p_sum_tasks_flag    => p_sum_tasks_flag,
	      p_task_assignment_id_tbl => p_task_assignment_id_tbl,
              p_budget_version_id    => p_budget_version_id,
	      p_work_type_id      =>  l_temp_number,
              x_return_status     =>  l_x_return_status,
              x_msg_count         =>  x_msg_count,
              x_msg_data          =>  x_msg_data
    );

    -- When more than one assignment ids are passed in, the newly created
    -- schedule will be copied to the rest of the assignments
    IF l_assignment_id_tbl.COUNT >1 THEN
      -- Delete the first assignment_id from l_assignment_id_tbl and store it
      -- in l_assignment_id.
   	  l_assignment_id := l_assignment_id_tbl(l_assignment_id_tbl.FIRST).assignment_id;
      l_assignment_id_tbl.DELETE(l_assignment_id_tbl.FIRST);

      -- Calling the PA_SCHEDULE_PVT API to get the schedule of the first
      -- assignment.
	    PA_SCHEDULE_PVT.get_assignment_schedule(l_assignment_id,
		     l_current_sch_rec_tab,
		     l_x_return_status,
		     x_msg_count,
		     x_msg_data
      );

      -- Copy schedules for the rest of the assignments in the table
      -- l_assignment_id_tbl.
      FOR l_counter IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST LOOP
		    -- Update the passed schedule table of record for creating the schedule for open assignment
		    PA_SCHEDULE_UTILS.update_sch_rec_tab(
          px_sch_record_tab        => l_current_sch_rec_tab,
				  p_assignment_id          => l_assignment_id_tbl(l_counter).assignment_id,
				  x_return_status          => l_x_return_status,
				  x_msg_count              => x_msg_count,
				  x_msg_data               => x_msg_data
      );
        -- Add the schedule record to l_x_sch_rec_tab.
        PA_SCHEDULE_UTILS.add_schedule_rec_tab(
         p_sch_record_tab          => l_current_sch_rec_tab,
         p_start_id                => l_current_sch_rec_tab.first,
         p_end_id                  => l_current_sch_rec_tab.last,
         px_sch_record_tab         => l_x_sch_rec_tab,
         x_return_status           => l_x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
        );
      END LOOP;

      -- Bulk insert all the schedule records stored in l_x_sch_rec_tab.
      	    -- Inserting the schedule in the PA_SCHEDULE table
	    PA_SCHEDULE_PKG.insert_rows(
        p_sch_record_tab       => l_x_sch_rec_tab,
				x_return_status        => l_x_return_status,
				x_msg_count            => x_msg_count,
				x_msg_data             => x_msg_data
	    );

	    PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API insert_rows ....');

      -- Copy timeline data.
      PA_TIMELINE_PVT.copy_open_asgn_timeline (
          p_assignment_id_tbl    => l_assignment_id_tbl,
          p_assignment_source_id => l_assignment_id,
          x_return_status      => l_x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
      );
    END IF;

  -- Case III: Copy schedule from an existing open/staffed assignment with
  -- status change only.
  ELSIF p_assignment_source_id IS NOT NULL AND p_assignment_status_code IS NOT NULL and p_calendar_id IS NULL  THEN
    -- Get source assignment schedule.


--Commenting below for Bug 6145532
/*
PA_SCHEDULE_PVT.get_assignment_schedule(p_assignment_source_id,
		   l_current_sch_rec_tab,
		   l_x_return_status,
		   x_msg_count,
		   x_msg_data
	  );
    */
    /* Added for Bug 6145532*/
    IF ( NVL(p_asgn_creation_mode,'DEFAULT') = 'PARTIAL' ) THEN

    --New call of PA_SCHEDULE_PVT.get_assignment_schedule with

    --dates range, to get partial schedule of assignment for the

    --leftover requirement to be made.

    PA_SCHEDULE_PVT.get_assignment_schedule(p_assignment_source_id,
    p_start_date,
    p_end_date,
    l_current_sch_rec_tab,
    l_x_return_status,
    x_msg_count,
    x_msg_data
    );
    ELSE
    -- Bug 6145532 : this is the old code that was being called always
    PA_SCHEDULE_PVT.get_assignment_schedule(p_assignment_source_id,
    l_current_sch_rec_tab,
    l_x_return_status,
    x_msg_count,
    x_msg_data
    );
    END IF ;
    /* changes end for Bug 6145532*/
    FOR l_counter IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST LOOP
      PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API update_sch_rec_tab ....');
		  -- Update the passed schedule record with p_assignment_status_code
		  PA_SCHEDULE_UTILS.update_sch_rec_tab(
          px_sch_record_tab        => l_current_sch_rec_tab,
          p_schedule_type_code     => 'OPEN_ASSIGNMENT',
				  p_assignment_id          => l_assignment_id_tbl(l_counter).assignment_id,
          p_assignment_status_code => p_assignment_status_code,
				  x_return_status          => l_x_return_status,
				  x_msg_count              => x_msg_count,
				  x_msg_data               => x_msg_data
      );
      PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API update_sch_rec_tab .....');
      -- Add the shedule record to l_x_sch_rec_tab.
      PA_SCHEDULE_UTILS.add_schedule_rec_tab(
         p_sch_record_tab          => l_current_sch_rec_tab,
         p_start_id                => l_current_sch_rec_tab.FIRST,
         p_end_id                  => l_current_sch_rec_tab.LAST,
         px_sch_record_tab         => l_x_sch_rec_tab,
         x_return_status           => l_x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
      );
      PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API add_schedule_rec_tab .....');
    END LOOP;

    -- Bulk insert all the schedule records stored in l_x_sch_rec_tab.
	  PA_SCHEDULE_PKG.insert_rows(
        p_sch_record_tab       => l_x_sch_rec_tab,
				x_return_status        => l_x_return_status,
				x_msg_count            => x_msg_count,
				x_msg_data             => x_msg_data
	  );
	  PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API insert_rows ....');

    -- Calling the Timeline API to build timeline records for the first
    -- assignment in the table l_assignment_id_tbl.
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
     PA_TIMELINE_PVT.CREATE_TIMELINE (
          p_assignment_id   =>l_assignment_id_tbl(l_assignment_id_tbl.FIRST).assignment_id,
				  x_return_status   =>l_x_return_status  ,
				  x_msg_count       =>x_msg_count        ,
				  x_msg_data        =>x_msg_data
     );
    END IF;
    -- Copy timeline records for the rest of the assignments in the
    -- table l_assignment_id_tbl.
    IF l_assignment_id_tbl.COUNT > 1 THEN
      l_assignment_id := l_assignment_id_tbl(l_assignment_id_tbl.FIRST).assignment_id;
      l_assignment_id_tbl.DELETE(l_assignment_id_tbl.FIRST);
      PA_TIMELINE_PVT.copy_open_asgn_timeline (
          p_assignment_id_tbl    => l_assignment_id_tbl,
          p_assignment_source_id => l_assignment_id,
          x_return_status        => l_x_return_status,
          x_msg_count            => x_msg_count,
          x_msg_data             => x_msg_data
      );
    END IF;

    -- Case IV: Copy schedule from an existing open assignment without any
    -- changes except for assignment id.
  ELSIF p_assignment_source_id IS NOT NULL AND p_assignment_status_code IS NULL AND p_calendar_id IS NULL  THEN
    -- Get source assignment schedule.
    PA_SCHEDULE_PVT.get_assignment_schedule(p_assignment_source_id,
		   l_current_sch_rec_tab,
		   l_x_return_status,
		   x_msg_count,
		   x_msg_data
	  );

    FOR l_counter IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST LOOP
      PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API update_sch_rec_tab ....');
		  -- Update the passed schedule record with assignment_id.
		  PA_SCHEDULE_UTILS.update_sch_rec_tab(
          px_sch_record_tab        => l_current_sch_rec_tab,
				  p_assignment_id          => l_assignment_id_tbl(l_counter).assignment_id,
				  x_return_status          => l_x_return_status,
				  x_msg_count              => x_msg_count,
				  x_msg_data               => x_msg_data
      );
      PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API update_sch_rec_tab .....');
      -- Add the shedule record to l_x_sch_rec_tab.
      PA_SCHEDULE_UTILS.add_schedule_rec_tab(
         p_sch_record_tab          => l_current_sch_rec_tab,
         p_start_id                => l_current_sch_rec_tab.first,
         p_end_id                  => l_current_sch_rec_tab.last,
         px_sch_record_tab         => l_x_sch_rec_tab,
         x_return_status           => l_x_return_status,
         x_msg_count               => x_msg_count,
         x_msg_data                => x_msg_data
      );
      PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API add_schedule_rec_tab .....');
    END LOOP;

    -- Bulk insert all the schedule records stored in l_x_sch_rec_tab.
	  PA_SCHEDULE_PKG.insert_rows(
        p_sch_record_tab       => l_x_sch_rec_tab,
				x_return_status        => l_x_return_status,
				x_msg_count            => x_msg_count,
				x_msg_data             => x_msg_data
	  );
	  PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API insert_rows ....');

    -- Copy timeline data.
    PA_TIMELINE_PVT.copy_open_asgn_timeline (
          p_assignment_id_tbl    => l_assignment_id_tbl,
          p_assignment_source_id => p_assignment_source_id,
          x_return_status      => l_x_return_status,
          x_msg_count          => x_msg_count,
          x_msg_data           => x_msg_data
    );

  END IF;

  x_return_status := l_x_return_status;

EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1, 'Error in create_opn_asgn_schedule API .....'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_opn_asg_schedule');
		 raise;

END create_opn_asg_schedule;


-- Procedure            : create_stf_asg_schedule
-- Purpose              : Create schedule for staffed assignments.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Schedule_Basis_Flag        VARCHAR2       YES       It is schedule basis flag.
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this
--                                                        assignment
-- P_Assignment_Id              NUMBER         YES       New id of staffed assignment
-- P_Open_Assignment_Id         NUMBER         YES       Id of that assignment which is beging used
--                                                       for creation of staffed assignment
-- P_Resource_Calendar_Percent  NUMBER         YES       It is percentage of the resource correponding to the calendar
-- P_Start_Date                 DATE           YES       starting date of the open assignment
-- P_End_Date                   DATE           YES       ending date of the open assignment
-- P_Assignment_Status_Code     VARCHAR2       YES       Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Work_Type_Id               NUMBER         NO        Id for the work type.
-- P_Task_Id                    NUMBER         NO        Id for the tasa.
-- P_Task_Percentage            NUMBER         NO        Percentage of the corresponding task.
-- p_sum_tasks_flag           VARCHAR2         NO       Indicates whether to sum task assignment periodic dates
-- p_task_assignment_id_tbl   SYSTEM.PA_NUM_TBL_TYPE  NO    Indicates the task assignments to choose.


PROCEDURE create_stf_asg_schedule(p_project_id               IN  NUMBER,
					    p_schedule_basis_flag        IN  VARCHAR2,
					    p_project_party_id           IN  NUMBER,
					    p_calendar_id                IN  NUMBER,
					    p_assignment_id              IN  NUMBER,
					    p_open_assignment_id         IN  NUMBER,
					    p_resource_calendar_percent  IN  NUMBER,
				            p_start_date                 IN  DATE,
					    p_end_date                   IN  DATE,
					    p_assignment_status_code     IN  VARCHAR2,
					    p_work_type_id               IN  NUMBER,
					    p_task_id                    IN  NUMBER,
					    p_task_percentage            IN  NUMBER,
					    p_sum_tasks_flag             IN  VARCHAR2 default null,
				            p_task_assignment_id_tbl IN  SYSTEM.PA_NUM_TBL_TYPE:=SYSTEM.PA_NUM_TBL_TYPE(),
                                            p_budget_version_id      IN  NUMBER:= NULL,
					    x_return_status              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					    x_msg_count                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
					    x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
					     )
IS

	 l_x_sch_record_tab               PA_SCHEDULE_GLOB.ScheduleTabTyp; -- Temporary variable to store the
	 -- schedule type table of records

         l_req_start_date                 PA_PROJECT_ASSIGNMENTS.start_date%TYPE;
         l_req_end_date                   pa_project_assignments.end_date%TYPE;
         l_calendar_id                    pa_project_assignments.calendar_id%TYPE;

	l_new_schedule_tab			  PA_SCHEDULE_GLOB.ScheduleTabTyp;

	l_start_date DATE;
	l_end_date DATE;
	l_total_hours NUMBER;       -- Bug 5126919

BEGIN
   --jm_profiler.set_time('Create Schedule');

	 -- Assigning status successs for tracking the error
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;
	 PA_SCHEDULE_UTILS.log_message(1,'Start of the create_sasgn_schedule API ... ');

	 -- =================================================
	 -- New code to process task assignment summation jraj 12/19/03

       l_start_date := p_start_date;
	 l_end_date := p_end_date;


       IF p_sum_tasks_flag = 'Y' then

	   get_periodic_start_end(  p_start_date,
					    p_end_date,
						p_assignment_id,
				          p_task_assignment_id_tbl,
					    l_start_date,
                                  l_end_date,
                                           p_project_id,
                                           p_budget_version_id,
					    x_return_status,
					    x_msg_count,
					    x_msg_data
					     );

	 END IF;


     --===================================================

	 -- If the calendar type is resource then it  will generate the schedule on the basis of
	 -- the calendar asign to the resource
	 IF (p_schedule_basis_flag =  'R') then
			PA_SCHEDULE_UTILS.log_message(1, 'Schedule Basis Flag - R');
			PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API get_resource_schedule ....');

			-- Calling tthe PVT API which will get the schedule for staffed asignment and calendar type is resource
			PA_SCHEDULE_PVT.get_resource_schedule(p_project_party_id,
				'PA_PROJECT_PARTY_ID',
				l_start_date,
				l_end_date,
				l_x_sch_record_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data
																					 );
			PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API get_resource_schedule ....');
			PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API apply_percentage ....');

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Calling the PA_SCHEDULE_UTILS API whice will apply the percentage of the resource can be used
				 PA_SCHEDULE_UTILS.apply_percentage(l_x_sch_record_tab,
					 p_resource_calendar_percent,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data
																					 );
			END IF;
			PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API apply_percentage ....');

			-- If the calendar type is other then resource then  it will generate
			-- the schedule on the basis of the assignment  asign to the calendar type
	 ELSIF (p_schedule_basis_flag = 'A') THEN
			PA_SCHEDULE_UTILS.log_message(1, 'Schedule basis flag = A ....');
			PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API get_assignment_schedule ....');

-- code fix starts for bug 2335580
                        SELECT start_date, end_date,calendar_id
                        into l_req_start_date, l_req_end_date, l_calendar_id
                        from pa_project_assignments
                        where assignment_id=p_open_assignment_id;


			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Calling the PVT API which will get the schedule on the basis of passed assignment id
--Added for 2335580
				   -- To check for this date clause jraj 12/19/03..

                                IF (p_start_date >l_req_end_date and p_end_date >l_req_end_date) OR
                                    (p_start_date <l_req_start_date AND p_end_date <l_req_start_date) THEN
                                 PA_SCHEDULE_PVT.get_calendar_schedule(l_calendar_id,
                                                                       l_start_date,
                                                                       l_end_date,
                                                                       l_x_sch_record_tab,
                                                                       l_x_return_status,
                                                                       x_msg_count,
                                                                       x_msg_data

                                                );
                                ELSE


				 PA_SCHEDULE_PVT.get_assignment_schedule(p_open_assignment_id,
	                                   				 l_start_date,
					                                 l_end_date,
                                   					 l_x_sch_record_tab,
				                                  	 l_x_return_status,
                                   					 x_msg_count,
					                                 x_msg_data
																								);
            			END IF;
                             END IF;
			PA_SCHEDULE_UTILS.log_message(1, 'After get_assignment_schedule .',l_x_sch_record_tab);
			PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API get_assignment_schedule ....');

			-- if the calendar type is other then resource then  it will generate
			-- the schedule on the basis of the assignment  asign to the calendar type
	 ELSIF (p_schedule_basis_flag IN ('P','O')) THEN
			PA_SCHEDULE_UTILS.log_message(1, 'Schedule Basis Flag  P or O');
			PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API get_calendar_schedule ....');

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Calling the PVT API which will get the schedule on the basis of passed calendar  id
				 PA_SCHEDULE_PVT.get_calendar_schedule(p_calendar_id,
					 l_start_date,
					 l_end_date,
					 l_x_sch_record_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data
																							);
			END IF;

			PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API get_calendar_schedule ....');
	 END IF;


	 IF p_sum_tasks_flag = 'Y' then

         null;
	   -- Call task summation API.
	   -- and obtain new l_new_schedule_tab_rec
	   	    sum_task_assignments(
	        p_task_assignment_id_tbl,
	        l_x_sch_record_tab,
                p_start_date,
		    p_end_date,
                l_total_hours,     --Bug 5126919
                l_new_schedule_tab,
		    l_x_return_status,
		    x_msg_count,
		    x_msg_data
		   );
         ELSE
	    l_new_schedule_tab := l_x_sch_record_tab;

	 END IF;



	 PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API update_sch_rec_tab ....');
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			-- updating the passed schedule table of record for creating the schedule for staffed assignment
			PA_SCHEDULE_UTILS.update_sch_rec_tab(l_new_schedule_tab,
				P_project_id                => p_project_id,
				p_schedule_type_code        => 'STAFFED_ASSIGNMENT',
				p_calendar_id               => p_calendar_id,
					p_assignment_id             => p_assignment_id,
					p_assignment_status_code    => p_assignment_status_code,
					x_return_status             => l_x_return_status,
					x_msg_count                 => x_msg_count,
						x_msg_data                  => x_msg_data
																					);
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1, 'SCH_REC',l_new_schedule_tab);
	 PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API update_sch_rec_tab ....');
	 PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API insert_rows ....');

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			-- Inserting the record in PA_SCHEDULES table
			PA_SCHEDULE_PKG.insert_rows(
				l_new_schedule_tab,
				l_x_return_status,
				x_msg_count,
				x_msg_data,
				l_total_hours  -- Bug 5126919
																 );
	 END IF;

   --jm_profiler.set_time('Create Schedule');

	 -- Calling the Timeline api  to build the timeline records  for the assignment
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_TIMELINE_PVT.CREATE_TIMELINE (p_assignment_id   =>p_assignment_id    ,
				x_return_status   =>l_x_return_status  ,
				x_msg_count       =>x_msg_count        ,
					x_msg_data        =>x_msg_data         );
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API insert_rows ....');
	 PA_SCHEDULE_UTILS.log_message(1,'End   of the create_sasgn_schedule API ... ');
	 x_return_status := l_x_return_status;
EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in create_sasgn_schedule API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'create_stf_asg_schedule');
			 raise;

END create_stf_asg_schedule;


-- This procedure will delete the schedule,exception records corresponding to the passed assignment id
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Assignment_Id              NUMBER         YES       it is assignment id used for deletion
--
PROCEDURE delete_asgn_schedules ( p_assignment_id IN NUMBER,
																	p_perm_delete IN VARCHAR2 := FND_API.G_TRUE,
	p_change_id IN NUMBER := null,
	x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count OUT NOCOPY NUMBER , --File.Sql.39 bug 4440895
	x_msg_data  OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

	 -- Storing the value for error tracking
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- deleting the records from pa_schedules,pa_schedule_exceptions and pa_schedule_except_history */

	 DELETE pa_schedules
		 WHERE assignment_id = p_assignment_id;

	 DELETE pa_schedule_exceptions
		 WHERE assignment_id  = p_assignment_id;

	 -- Delete entire exception history if p_perm_delete
	 -- Otherwise, just delete exceptions with change_id >= p_change_id
	 if FND_API.TO_BOOLEAN(p_perm_delete) then
			DELETE pa_schedule_except_history
				WHERE assignment_id  = p_assignment_id;
	 else
			DELETE pa_schedule_except_history
				WHERE assignment_id  = p_assignment_id
				and change_id >= p_change_id;
	 end if;

	 -- Delete entire schedules history if p_perm_delete.
	 if FND_API.TO_BOOLEAN(p_perm_delete) then
			DELETE pa_schedules_history
				WHERE assignment_id = p_assignment_id;
	 end if;

	 -- Calling the Timeline api to delete the timeline records
	 -- for the assignment
	 PA_TIMELINE_PVT.DELETE_TIMELINE (p_assignment_id   =>p_assignment_id    ,
		 x_return_status   =>l_x_return_status  ,
		 x_msg_count       =>x_msg_count        ,
			 x_msg_data        =>x_msg_data         );

   x_return_status := l_x_return_status;

EXCEPTION
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_UTILS',
			 p_procedure_name     => 'delete_asgn_schedules');
		 raise;

END delete_asgn_schedules;


-- Effects: Changes the schedule statuses of the assignment to the
-- appropriate success status.
-- Impl Notes: Call API to retrieve next status.  Do nothing if the status is
-- the same.

PROCEDURE update_sch_wf_success(
																p_assignment_id IN NUMBER,
                                p_record_version_number IN NUMBER,
																x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
																x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
															 )
IS

	 l_next_status_code 				pa_project_assignments.status_code%type;
	 l_temp_status_code 				pa_project_assignments.status_code%type;
	 l_project_id							pa_project_assignments.project_id%type;
	 l_calendar_id							pa_project_assignments.calendar_id%type;
	 l_assignment_type					pa_project_assignments.assignment_type%type;
	 l_asgn_start_date							pa_project_assignments.start_date%type;
	 l_asgn_end_date								pa_project_assignments.end_date%type;
	 l_status_type             VARCHAR2(30);
	 l_temp_index_out          NUMBER;
   l_record_version_number   NUMBER;
   -- added for Bug fix: 4537865
   l_new_msg_data	VARCHAR2(2000);
   -- added for Bug fix: 4537865


/*Added for bug 2279209 */

    l_schedule_id         pa_schedules.schedule_id%TYPE;
    l_first_status        pa_schedules.status_code%TYPE;
    l_start_date          pa_schedules.start_date%TYPE;
    l_end_date            pa_schedules.end_date%TYPE;
    l_loop_thru_record    varchar2(1) :='Y';
    l_status_code         pa_schedules.status_code%TYPE;

/* Added for bug 2329948 */
    l_first_start_date pa_schedules.start_date%TYPE;
    l_last_end_date    pa_schedules.end_date%TYPE;
    l_count            NUMBER;


	 CURSOR C1 IS
		 SELECT schedule_id, status_code, start_date, end_date
			 FROM pa_schedules
			 WHERE assignment_id = p_assignment_id
	                 ORDER BY start_date;

		 CURSOR C2 IS
			 SELECT project_id, calendar_id,
				 assignment_type, start_date, end_date
				 FROM pa_project_assignments
				 WHERE assignment_id = p_assignment_id;

BEGIN
	 PA_SCHEDULE_UTILS.log_message(1,'Start of the update_sch_wf_success API');
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_record_version_number := p_record_version_number;

	 open c2;
	 fetch c2 into l_project_id, l_calendar_id,
		 l_assignment_type, l_asgn_start_date, l_asgn_end_date;
	 close c2;

	 -- Derive status type.
	 if ( l_assignment_type  = 'OPEN_ASSIGNMENT' ) then
			l_status_type := 'OPEN_ASGMT';
	 else
			l_status_type := 'STAFFED_ASGMT';
	 end if;

/* Commented for bug 2329948 */

/*
--Added for bug 2279209

          OPEN C1;
          LOOP
          FETCH C1 INTO l_schedule_id, l_status_code, l_start_date, l_end_date;

          IF SQL%ROWCOUNT > 0 THEN
            IF l_first_status IS NULL AND l_status_code IS NOT NULL THEN
              l_first_status :=l_status_code;
            END IF;

            IF l_first_status <>  l_status_code THEN
              l_loop_thru_record :='Y';
              CLOSE C1;
              EXIT ;
            ELSE
              l_first_status :=l_status_code;
              IF C1%NOTFOUND THEN
                l_loop_thru_record :='N';
                EXIT ;
             END IF;
            END IF;
          END IF;
        END LOOP;
       CLOSE C1;

IF  l_loop_thru_record ='N' THEN
     PA_SCHEDULE_UTILS.log_message(1,'Change status API called once');

     SELECT min(start_date), max(end_date)
     INTO l_start_date, l_end_date
     FROM pa_schedules
     where assignment_id= p_assignment_id;

     PA_SCHEDULE_UTILS.log_message(1,'Call API to get next status');
        PA_PROJECT_STUS_UTILS.get_wf_success_failure_status (
                                p_status_code => l_first_status,
                                p_status_type => l_status_type,
                                x_wf_success_status_code => l_next_status_code,
                                x_wf_failure_status_code => l_temp_status_code,
                                x_return_status => l_x_return_status,
                                x_error_message_code => x_msg_data) ;
                                    if (l_next_status_code <> l_first_status) then
                                 PA_SCHEDULE_UTILS.log_message(1, 'Calling change_status');

                                  PA_SCHEDULE_PUB.change_status(
                                         p_record_version_number => l_record_version_number,
                                         p_project_id => l_project_id,
                                         p_calendar_id => l_calendar_id,
                                         p_assignment_id => p_assignment_id,
                                         p_assignment_type => l_assignment_type,
                                         p_status_type => null,
                                         p_start_date => l_start_date,
                                         p_end_date => l_end_date,
                                         p_assignment_status_code => l_next_status_code,
                                         p_asgn_start_date => l_asgn_start_date,
                                         p_asgn_end_date => l_asgn_end_date,
                                         p_init_msg_list => FND_API.G_FALSE,
                                         p_save_to_hist => FND_API.G_FALSE,
                                         x_return_status => l_x_return_status,
                                         x_msg_count => x_msg_count,
                                         x_msg_data => x_msg_data);
                              end if;
                    l_record_version_number := NULL;

ELSE
--Code change ends for bug 2279209

	 FOR rec IN C1 LOOP
			PA_SCHEDULE_UTILS.log_message(1, 'In loop: ' || rec.start_date ||
				' ' || rec.end_date);
			-- Call Ramesh's API to get next success status.
			-- For now, make them the same.
			PA_PROJECT_STUS_UTILS.get_wf_success_failure_status (
				p_status_code => rec.status_code,
				p_status_type => l_status_type,
				x_wf_success_status_code => l_next_status_code,
				x_wf_failure_status_code => l_temp_status_code,
				x_return_status => l_x_return_status,
				x_error_message_code => x_msg_data) ;

			if (l_next_status_code <> rec.status_code) then
				 PA_SCHEDULE_UTILS.log_message(1, 'Calling change_status');
				 PA_SCHEDULE_PUB.change_status(
					 p_record_version_number => l_record_version_number,
					 p_project_id => l_project_id,
					 p_calendar_id => l_calendar_id,
					 p_assignment_id => p_assignment_id,
					 p_assignment_type => l_assignment_type,
					 p_status_type => null,
					 p_start_date => rec.start_date,
					 p_end_date => rec.end_date,
					 p_assignment_status_code => l_next_status_code,
					 p_asgn_start_date => l_asgn_start_date,
					 p_asgn_end_date => l_asgn_end_date,
					 p_init_msg_list => FND_API.G_FALSE,
           p_save_to_hist => FND_API.G_FALSE,
					 x_return_status => l_x_return_status,
					 x_msg_count => x_msg_count,
					 x_msg_data => x_msg_data);

        -- jmarques  1797355: Modifying l_record_version_number to be null
        -- since the record_version_number has already been checked in the
        -- first call to change_status.  We cannot pass
        -- p_record_version_number to subsequent calls of change_status
        -- since the record_version_number has changed between calls.
        -- We must pass null instead.

			  l_record_version_number := NULL;
			END IF;
	 end loop;

  END IF;   -- bug 2279209

 */
/* Commented till here for bug 2329948 */

       /* Added for bug#2329948 */
          SELECT COUNT(*)
          INTO   l_count
          FROM   pa_schedules
          WHERE  assignment_id = p_assignment_id;

          OPEN C1;
          LOOP
             FETCH C1 INTO l_schedule_id, l_status_code, l_start_date, l_end_date;

             IF C1%FOUND THEN
                IF l_first_status IS NULL THEN
                   l_first_status := l_status_code;
                END IF;

                IF l_first_start_date IS NULL THEN
                   l_first_start_date := l_start_date;
                END IF;

                IF l_first_status <> l_status_code THEN
                   PA_SCHEDULE_UTILS.log_message(1,'Call API to get next status');
                   PA_PROJECT_STUS_UTILS.get_wf_success_failure_status (
                                         p_status_code => l_first_status,
                                         p_status_type => l_status_type,
                                         x_wf_success_status_code => l_next_status_code,
                                         x_wf_failure_status_code => l_temp_status_code,
                                         x_return_status => l_x_return_status,
                                         x_error_message_code => x_msg_data);

                   IF (l_next_status_code <> l_first_status) THEN
                      PA_SCHEDULE_UTILS.log_message(1, 'Calling change_status');

                      PA_SCHEDULE_PUB.change_status(
                                      p_record_version_number => l_record_version_number,
                                      p_project_id => l_project_id,
                                      p_calendar_id => l_calendar_id,
                                      p_assignment_id => p_assignment_id,
                                      p_assignment_type => l_assignment_type,
                                      p_status_type => null,
                                      p_start_date => l_first_start_date,
                                      p_end_date => l_last_end_date,
                                      p_assignment_status_code => l_next_status_code,
                                      p_asgn_start_date => l_asgn_start_date,
                                      p_asgn_end_date => l_asgn_end_date,
                                      p_init_msg_list => FND_API.G_FALSE,
                                      p_save_to_hist => FND_API.G_FALSE,
                                      x_return_status => l_x_return_status,
                                      x_msg_count => x_msg_count,
                                      x_msg_data => x_msg_data);
                   END IF;
                   l_record_version_number := NULL;
                   l_first_status := l_status_code;
                   l_first_start_date := l_start_date;
                END IF;
                l_last_end_date := l_end_date;

                IF C1%ROWCOUNT = l_count THEN
                   PA_SCHEDULE_UTILS.log_message(1,'Call API to get next status for last record');
                   PA_PROJECT_STUS_UTILS.get_wf_success_failure_status (
                                         p_status_code => l_first_status,
                                         p_status_type => l_status_type,
                                         x_wf_success_status_code => l_next_status_code,
                                         x_wf_failure_status_code => l_temp_status_code,
                                         x_return_status => l_x_return_status,
                                         x_error_message_code => x_msg_data);

                   IF (l_next_status_code <> l_first_status) THEN
                      PA_SCHEDULE_UTILS.log_message(1, 'Calling change_status last record');

                      PA_SCHEDULE_PUB.change_status(
                                      p_record_version_number => l_record_version_number,
                                      p_project_id => l_project_id,
                                      p_calendar_id => l_calendar_id,
                                      p_assignment_id => p_assignment_id,
                                      p_assignment_type => l_assignment_type,
                                      p_status_type => null,
                                      p_start_date => l_first_start_date,
                                      p_end_date => l_last_end_date,
                                      p_assignment_status_code => l_next_status_code,
                                      p_asgn_start_date => l_asgn_start_date,
                                      p_asgn_end_date => l_asgn_end_date,
                                      p_init_msg_list => FND_API.G_FALSE,
                                      p_save_to_hist => FND_API.G_FALSE,
                                      x_return_status => l_x_return_status,
                                      x_msg_count => x_msg_count,
                                      x_msg_data => x_msg_data);
                   END IF;
                END IF;
             ELSE
                EXIT;
             END IF;
          END LOOP;
          CLOSE C1;
       /* End of code added for bug 2329948 */


	 -- If records exist in pa_schedules_history with last_approved_flag
	 -- set the flag to 'N'
	 PA_SCHEDULE_UTILS.log_message(1, 'Setting last approved flag to N');
	 update pa_schedules_history
		 set last_approved_flag = 'N'
		 where assignment_id = p_assignment_id
		 and last_approved_flag = 'Y';

	 PA_SCHEDULE_UTILS.log_message(1,'End of the update_sch_wf_success API ... '
																   || l_x_return_status);

   x_return_status := l_x_return_status;
	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
			      --p_data           => x_msg_data, 		* Commented for Bug: 4537865
				p_data		 => l_new_msg_data,		-- added for Bug fix: 4537865
				p_msg_index_out  => l_temp_index_out );
		 -- added for Bug fix: 4537865
			x_msg_data := l_new_msg_data;
		  -- added for Bug fix: 4537865
	 End If;


EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in update_sch_wf_success API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'update_sch_wf_success');
END update_sch_wf_success;

-- Effects: Changes the schedule statuses of the assignment to the
-- appropriate failure status.
-- Impl Notes: Call API to retrieve next status.  Do nothing if the status is
-- the same.

PROCEDURE update_sch_wf_failure(
																p_assignment_id IN NUMBER,
                                p_record_version_number IN NUMBER,
																x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
																x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
															 )
IS
	 L_next_status_code 				pa_project_assignments.status_code%type;
	 l_temp_status_code 				pa_project_assignments.status_code%type;
	 l_project_id							pa_project_assignments.project_id%type;
	 l_calendar_id							pa_project_assignments.calendar_id%type;
	 l_assignment_type					pa_project_assignments.assignment_type%type;
	 l_asgn_start_date					pa_project_assignments.start_date%type;
	 l_asgn_end_date						pa_project_assignments.end_date%type;
	 l_status_type             VARCHAR2(30);
	 l_temp_index_out          NUMBER;
   l_record_version_number   NUMBER;
	-- added for Bug Fix: 4537865
		l_new_msg_data	   VARCHAR2(2000);
	-- added for Bug Fix: 4537865


         /* Added for bug 2329948 */
         l_schedule_id         pa_schedules.schedule_id%TYPE;
         l_start_date          pa_schedules.start_date%TYPE;
         l_end_date            pa_schedules.end_date%TYPE;
         l_status_code   pa_schedules.status_code%TYPE;
         l_first_status  pa_schedules.status_code%TYPE;
         l_first_start_date pa_schedules.start_date%TYPE;
         l_last_end_date    pa_schedules.end_date%TYPE;
         l_count            NUMBER;

	 CURSOR C1 IS
		 SELECT schedule_id, status_code, start_date, end_date
			 FROM pa_schedules
			 WHERE assignment_id = p_assignment_id
                         ORDER BY start_date;

		 CURSOR C2 IS
			 SELECT project_id, calendar_id,
				 assignment_type, start_date, end_date
				 FROM pa_project_assignments
				 WHERE assignment_id = p_assignment_id;

BEGIN
	 PA_SCHEDULE_UTILS.log_message(1,'Start of the update_sch_wf_failure API');
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

   l_record_version_number := p_record_version_number;

	 -- Get assignment information
	 open c2;
	 fetch c2 into l_project_id, l_calendar_id,
		 l_assignment_type, l_asgn_start_date, l_asgn_end_date;
	 close c2;

	 -- Derive status type.
	 if ( l_assignment_type  = 'OPEN_ASSIGNMENT' ) then
			l_status_type := 'OPEN_ASGMT';
	 else
			l_status_type := 'STAFFED_ASGMT';
	 end if;

   /* Commented for bug 2329948 */

  /*	 FOR rec IN C1 LOOP
			-- Call Ramesh's API to get next success status.
			-- For now, make them the same.
			PA_PROJECT_STUS_UTILS.get_wf_success_failure_status (
				p_status_code => rec.status_code,
				p_status_type => l_status_type,
				x_wf_success_status_code => l_temp_status_code,
				x_wf_failure_status_code => l_next_status_code,
				x_return_status => l_x_return_status,
				x_error_message_code => x_msg_data) ;

			if (l_next_status_code <> rec.status_code) then
				 PA_SCHEDULE_PUB.change_status(
					 p_record_version_number => l_record_version_number,
					 p_project_id => l_project_id,
					 p_calendar_id => l_calendar_id,
					 p_assignment_id => p_assignment_id,
					 p_assignment_type => l_assignment_type,
					 p_status_type => null,
					 p_start_date => rec.start_date,
					 p_end_date => rec.end_date,
					 p_assignment_status_code => l_next_status_code,
					 p_asgn_start_date => l_asgn_start_date,
					 p_asgn_end_date => l_asgn_end_date,
					 p_init_msg_list => FND_API.G_FALSE,
					 p_save_to_hist => FND_API.G_FALSE,
					 x_return_status => l_x_return_status,
					 x_msg_count => x_msg_count,
					 x_msg_data => x_msg_data);

        -- jmarques  1797355: Modifying l_record_version_number to be null
        -- since the record_version_number has already been checked in the
        -- first call to change_status.  We cannot pass
        -- p_record_version_number to subsequent calls of change_status
        -- since the record_version_number has changed between calls.
        -- We must pass null instead.

			  l_record_version_number := NULL;
			end if;
	 end loop;
   */

   /* Commented till here for bug 2329948 */

       /* Added for bug#2329948 */
          SELECT COUNT(*)
          INTO   l_count
          FROM   pa_schedules
          WHERE  assignment_id = p_assignment_id;

          OPEN C1;
          LOOP
             FETCH C1 INTO l_schedule_id, l_status_code, l_start_date, l_end_date;

             IF C1%FOUND THEN
                IF l_first_status IS NULL THEN
                   l_first_status := l_status_code;
                END IF;

                IF l_first_start_date IS NULL THEN
                   l_first_start_date := l_start_date;
                END IF;

                IF l_first_status <> l_status_code THEN
                   PA_SCHEDULE_UTILS.log_message(1,'Call API to get next status');
                   PA_PROJECT_STUS_UTILS.get_wf_success_failure_status (
                                         p_status_code => l_first_status,
                                         p_status_type => l_status_type,
                                         x_wf_success_status_code => l_temp_status_code,
                                         x_wf_failure_status_code => l_next_status_code,
                                         x_return_status => l_x_return_status,
                                         x_error_message_code => x_msg_data);

                   IF (l_next_status_code <> l_first_status) THEN
                      PA_SCHEDULE_UTILS.log_message(1, 'Calling change_status');

                      PA_SCHEDULE_PUB.change_status(
                                      p_record_version_number => l_record_version_number,
                                      p_project_id => l_project_id,
                                      p_calendar_id => l_calendar_id,
                                      p_assignment_id => p_assignment_id,
                                      p_assignment_type => l_assignment_type,
                                      p_status_type => null,
                                      p_start_date => l_first_start_date,
                                      p_end_date => l_last_end_date,
                                      p_assignment_status_code => l_next_status_code,
                                      p_asgn_start_date => l_asgn_start_date,
                                      p_asgn_end_date => l_asgn_end_date,
                                      p_init_msg_list => FND_API.G_FALSE,
                                      p_save_to_hist => FND_API.G_FALSE,
                                      x_return_status => l_x_return_status,
                                      x_msg_count => x_msg_count,
                                      x_msg_data => x_msg_data);
                   END IF;
                   l_record_version_number := NULL;
                   l_first_status := l_status_code;
                   l_first_start_date := l_start_date;
                END IF;
                l_last_end_date := l_end_date;

                IF C1%ROWCOUNT = l_count THEN
                   PA_SCHEDULE_UTILS.log_message(1,'Call API to get next status for last record');
                   PA_PROJECT_STUS_UTILS.get_wf_success_failure_status (
                                         p_status_code => l_first_status,
                                         p_status_type => l_status_type,
                                         x_wf_success_status_code => l_temp_status_code,
                                         x_wf_failure_status_code => l_next_status_code,
                                         x_return_status => l_x_return_status,
                                         x_error_message_code => x_msg_data);

                   IF (l_next_status_code <> l_first_status) THEN
                      PA_SCHEDULE_UTILS.log_message(1, 'Calling change_status last record');

                      PA_SCHEDULE_PUB.change_status(
                                      p_record_version_number => l_record_version_number,
                                      p_project_id => l_project_id,
                                      p_calendar_id => l_calendar_id,
                                      p_assignment_id => p_assignment_id,
                                      p_assignment_type => l_assignment_type,
                                      p_status_type => null,
                                      p_start_date => l_first_start_date,
                                      p_end_date => l_last_end_date,
                                      p_assignment_status_code => l_next_status_code,
                                      p_asgn_start_date => l_asgn_start_date,
                                      p_asgn_end_date => l_asgn_end_date,
                                      p_init_msg_list => FND_API.G_FALSE,
                                      p_save_to_hist => FND_API.G_FALSE,
                                      x_return_status => l_x_return_status,
                                      x_msg_count => x_msg_count,
                                      x_msg_data => x_msg_data);
                   END IF;
                END IF;
             ELSE
                EXIT;
             END IF;
          END LOOP;
          CLOSE C1;
       /* End of code added for bug 2329948 */


	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
			      --p_data           => x_msg_data, 		* Commented for Bug fix: 4537865
				p_data		 => l_new_msg_data,		-- added for Bug Fix: 4537865
				p_msg_index_out  => l_temp_index_out );
			-- added for Bug Fix: 4537865
				x_msg_data := l_new_msg_data;
			-- added for Bug Fix: 4537865
	 End If;

   x_return_status := l_x_return_status;
	 PA_SCHEDULE_UTILS.log_message(1,'End of the update_sch_wf_failure API ... ');

EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in update_sch_wf_failure API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'update_sch_wf_failure');
END update_sch_wf_failure;

-- Effects: Reverts the schedule back to the last approved schedule.
-- Impl Notes: Copies schedule records with p_assignment_id, from schedules
-- history to schedules table.  Do not update if there are
-- no records with last_approved_flag = 'Y'.  Delete those records from
-- pa_schedule_history.  Be sure to use delete schedule API to remove old
-- schedules.  Also, call create_timeline.

PROCEDURE revert_to_last_approved(
																	p_assignment_id IN NUMBER,
																	p_change_id IN NUMBER,
																	x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																	x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
																	x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
																 )
IS
	 l_index NUMBER;
	 l_temp_index_out NUMBER;
	 -- added for Bug fix: 4537865
	 l_new_msg_data	  VARCHAR2(2000);
	 -- added for Bug fix: 4537865

	 CURSOR C1 IS
		 select schedule_id, calendar_id, assignment_id, project_id,
			 schedule_type_code, status_code, start_date, end_date, monday_hours,
			 tuesday_hours, wednesday_hours, thursday_hours, friday_hours,
			 saturday_hours, sunday_hours, change_id, last_approved_flag, request_id,
			 program_application_id, program_id, program_update_date, creation_date,
			 created_by, last_update_date, last_update_by, last_update_login
			 from pa_schedules_history
			 where assignment_id = p_assignment_id
			 and last_approved_flag = 'Y';

BEGIN
	 PA_SCHEDULE_UTILS.log_message(1,'Start of the revert_to_last_approved API');
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	 l_index := 0;
	 for rec in c1 loop
			l_index := l_index + 1;

			if l_index = 1 then
				 -- Delete schedules for the assignment in order to insert new assignment
				 -- records.
				 delete_asgn_schedules(
					 p_assignment_id => p_assignment_id,
					 p_perm_delete => FND_API.G_FALSE,
					 p_change_id => p_change_id,
					 x_return_status => l_x_return_status,
					 x_msg_count => x_msg_count,
					 x_msg_data => x_msg_data);
			end if;
			-- Insert row into PA_SCHEDULES
			pa_schedule_pkg.insert_rows (
				p_calendar_id => rec.calendar_id,
				p_assignment_id => rec.assignment_id ,
				p_project_id => rec.project_id  ,
				p_schedule_type_code => rec.schedule_type_code,
				p_assignment_status_code => rec.status_code ,
				p_start_date => rec.start_date    ,
				p_end_date => rec.end_date      ,
				p_monday_hours => rec.monday_hours ,
				p_tuesday_hours => rec.tuesday_hours ,
				p_wednesday_hours => rec.wednesday_hours ,
				p_thursday_hours => rec.thursday_hours,
				p_friday_hours => rec.friday_hours ,
				p_saturday_hours => rec.saturday_hours,
				p_sunday_hours => rec.sunday_hours  ,
				x_return_status => l_x_return_status ,
					x_msg_count => x_msg_count     ,
					x_msg_data => x_msg_data);
	 end loop;

	 -- Call create_timeline and delete records from schedule history
	 -- if we inserted any rows.
	 if l_index <> 0 then
			delete pa_schedules_history
				where assignment_id = p_assignment_id
				and last_approved_flag = 'Y';

	    IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_TIMELINE_PVT.CREATE_TIMELINE (
				p_assignment_id   => p_assignment_id,
				x_return_status   => l_x_return_status,
				x_msg_count       => x_msg_count,
				x_msg_data        => x_msg_data);
      END IF;

	 end if;

	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
			      --p_data           => x_msg_data, 		* Commented for Bug fix: 4537865
				p_data		 => l_new_msg_data,		-- added for Bug fix: 4537865
				p_msg_index_out  => l_temp_index_out );
			-- added for Bug fix: 4537865
			x_msg_data := l_new_msg_data;
			-- added for Bug fix: 4537865
	 End If;

	 x_return_status := l_x_return_status;
	 PA_SCHEDULE_UTILS.log_message(1,'End of the revert_to_last_approved API ... ');

EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in revert_to_last_approved API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'revert_to_last_approved');
END revert_to_last_approved;

-- Effects: Adds schedule records for p_assignment_id to pa_schedules_history
-- if they do not already exist.
-- Impl Notes: If records already exist in pa_schedule_history with change_id,
-- then do nothing.  Otherwise, uncheck any records with last_approved_flag
-- and copy schedule records there with correct change_id with
-- last_approved_flag checked.

PROCEDURE update_history_table(
															 p_assignment_id IN NUMBER,
															 p_change_id IN NUMBER,
															 x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
															 x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
															 x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
															)
IS

	 l_index NUMBER;
	 l_assignment_id NUMBER;
	 l_change_id NUMBER;
	 l_temp_index_out NUMBER;
	 -- added for bug fix: 4537865
	 l_new_msg_data	  VARCHAR2(2000);
	 -- added for bug fix: 4537865

	 -- Contains all the records with p_change_id.
	 CURSOR C1 IS
		 select assignment_id
			 from pa_schedules_history
			 where assignment_id = p_assignment_id
			 and change_id = p_change_id;

		 -- Contains the schedule records for assignment_id.
		 CURSOR C2 IS
			 select schedule_id, calendar_id, assignment_id, project_id,
				 schedule_type_code, status_code, start_date, end_date, monday_hours,
				 tuesday_hours, wednesday_hours, thursday_hours, friday_hours,
				 saturday_hours, sunday_hours, creation_date, created_by, last_update_date,
				 last_update_by, last_update_login, request_id, program_application_id,
				 program_id, program_update_date
				 from pa_schedules
				 where assignment_id = p_assignment_id;

BEGIN
	 PA_SCHEDULE_UTILS.log_message(1,'Start of the update_history_table API');
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

	 -- If there are no records in pa_schedules_history with change_id
	 -- then update table.
	 open c1;
	 fetch c1 into l_assignment_id;
	 if c1%NOTFOUND then
			close c1;

			-- Copy records in pa_schedules to pa_schedules_history
			for rec in c2 loop
				 insert into pa_schedules_history
					 ( schedule_id, calendar_id, assignment_id, project_id,
					 schedule_type_code, status_code, start_date, end_date, monday_hours,
					 tuesday_hours, wednesday_hours, thursday_hours, friday_hours,
					 saturday_hours, sunday_hours, change_id, last_approved_flag,
					 creation_date, created_by, last_update_date, last_update_by,
					 last_update_login, request_id, program_application_id, program_id,
					 program_update_date)
					 values
					 ( rec.schedule_id, rec.calendar_id, rec.assignment_id, rec.project_id,
					 rec.schedule_type_code, rec.status_code, rec.start_date, rec.end_date,
					 rec.monday_hours, rec.tuesday_hours, rec.wednesday_hours,
					 rec.thursday_hours, rec.friday_hours, rec.saturday_hours,
					 rec.sunday_hours, p_change_id, 'Y', rec.creation_date, rec.created_by,
					 rec.last_update_date, rec.last_update_by, rec.last_update_login,
					 rec.request_id, rec.program_application_id, rec.program_id,
					 rec.program_update_date);
			end loop;

			-- If there are records in pa_schedules_history with change_id
			-- then do nothing.
	 else
			close c1;
	 end if;

	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
			      --p_data           => x_msg_data, 		* Commented for Bgu: 4537865
				p_data		 => l_new_msg_data,		-- added for bug fix: 4537865
				p_msg_index_out  => l_temp_index_out );
			-- added for bug fix: 4537865
				x_msg_data := l_new_msg_data;
			-- added for bug fix: 4537865
	 End If;

	 x_return_status := l_x_return_status;
	 PA_SCHEDULE_UTILS.log_message(1,'End of the update_history_table API ... ');

EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in update_history_table API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := SQLERRM;
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'update_history_table');
END update_history_table;


--
-- Procedure : Update_asgmt_changed_items_tab
-- Purpose   : Poplulates new and old values for schedule changes to pa_asgmt_changed_items
--             table which stores the assignment_changes that are pending approval.
-- Parameter
--             p_populate_mode : SAVED/ASSIGNMENT_UPDATED/SCHEDULE_UPDATED
--
PROCEDURE update_asgmt_changed_items_tab
( p_assignment_id               IN  NUMBER
 ,p_populate_mode               IN  VARCHAR2                                                := 'SAVED'
 ,p_change_id                   IN  NUMBER
 ,p_exception_type_code         IN  VARCHAR2                                                := NULL
 ,p_start_date                  IN  DATE                                                    := NULL
 ,p_end_date                    IN  DATE                                                    := NULL
 ,p_requirement_status_code     IN  VARCHAR2                                                := NULL
 ,p_assignment_status_code      IN  VARCHAR2                                                := NULL
 ,p_start_date_tbl              IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_end_date_tbl                IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_monday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_tuesday_hours_tbl           IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_wednesday_hours_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_thursday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_friday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_saturday_hours_tbl          IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_sunday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_non_working_day_flag        IN  VARCHAR2                                                := 'N'
 ,p_change_hours_type_code      IN  VARCHAR2                                                := NULL
 ,p_hrs_per_day                 IN  NUMBER                                                  := NULL
 ,p_calendar_percent            IN  NUMBER                                                  := NULL
 ,p_change_calendar_type_code   IN  VARCHAR2                                                := NULL
 ,p_change_calendar_name        IN  VARCHAR2                                                := NULL
 ,p_change_calendar_id          IN  NUMBER                                                  := NULL
 ,p_duration_shift_type_code    IN  VARCHAR2                                                := NULL
 ,p_duration_shift_unit_code    IN  VARCHAR2                                                := NULL
 ,p_number_of_shift             IN  NUMBER                                                  := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2)                                            --File.Sql.39 bug 4440895
IS
  l_changed_item_name      pa_asgmt_changed_items.changed_item_name%TYPE;
  l_date_range             pa_asgmt_changed_items.date_range%TYPE;
  l_old_value              pa_asgmt_changed_items.old_value%TYPE;
  l_new_value              pa_asgmt_changed_items.new_value%TYPE;
/* Added for bug 1635170*/
  temp_start_date          DATE;
  temp_end_date            DATE;
  l_insert_schedule_change BOOLEAN :=TRUE;
/* End for bug 1635170*/
  l_start_date             DATE;
  l_end_date               DATE;
  l_project_calendar_id    NUMBER;
  l_assignment_type        pa_project_assignments.assignment_type%TYPE;
  l_status_code            pa_schedules.status_code%TYPE;
  l_apprvl_status_code pa_project_assignments.apprvl_status_code%TYPE;
  l_shifted_days           NUMBER;
  l_calendar_id            NUMBER;


-- Bug 8856611 ,changed cursor to substitute 0 for null for all hour values
  CURSOR C1 IS
    SELECT exception_type_code, start_date, end_date, calendar_id,
           status_code, resource_calendar_percent, non_working_day_flag,
           change_hours_type_code, nvl(monday_hours,0) monday_hours , nvl(tuesday_hours,0) tuesday_hours,
           nvl(wednesday_hours,0) wednesday_hours, nvl(thursday_hours,0) thursday_hours, nvl(friday_hours,0) friday_hours, nvl(saturday_hours,0) saturday_hours,
           nvl(sunday_hours,0) sunday_hours, change_calendar_type_code, change_calendar_id
    FROM   pa_schedule_except_history
    WHERE  assignment_id = p_assignment_id
    AND    change_id = p_change_id;

  CURSOR get_start_end_date IS
    Select start_date, end_date
    from  pa_project_assignments
    where  assignment_id = p_assignment_id;

  CURSOR get_apprvl_status_code IS
    SELECT apprvl_status_code
    FROM  pa_project_assignments
    WHERE assignment_id = p_assignment_id;

  CURSOR get_project_calendar_id IS
    SELECT prj.calendar_id
    FROM pa_projects_all prj,
         pa_project_assignments asmt
    WHERE asmt.assignment_id = p_assignment_id
    AND   prj.project_id = asmt.project_id;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- get approval status
  OPEN get_apprvl_status_code;
  FETCH get_apprvl_status_code INTO l_apprvl_status_code;
  CLOSE get_apprvl_status_code;

  ------------------------------------------------------------------------
  -- Populate the temp table from pa_schedule_except_history
  ------------------------------------------------------------------------
  -- If there is last approved data in history table and approval status is not 'approve',
  -- populate temp table from history table first. Because we need to consider mass update submit case.
  IF (p_change_id <> -1 AND l_apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_approved) THEN
     FOR v_c1 IN C1 LOOP
        -- If exception_type is either 'CHANGE_DURATION' or 'SHIFT_DURATION', we want to add only one row
        -- to the temp table for both.
        IF ( (v_c1.exception_type_code = 'CHANGE_DURATION' OR v_c1.exception_type_code = 'SHIFT_DURATION'  OR v_c1.exception_type_code = 'DURATION_PATTERN_SHIFT') AND
            l_insert_schedule_change = FALSE) THEN
           NULL;
        ELSE
           l_changed_item_name := PA_SCHEDULE_PVT.get_changed_item_name_text(v_c1.exception_type_code);

           IF (v_c1.exception_type_code='CHANGE_DURATION' OR v_c1.exception_type_code='SHIFT_DURATION'  OR v_c1.exception_type_code = 'DURATION_PATTERN_SHIFT') THEN
              l_date_range := ' ';
           ELSE
              l_date_range := PA_SCHEDULE_PVT.get_date_range_text(v_c1.start_date, v_c1.end_date);
           END IF;

           -- v_c1.start_date,v_c1.end_date are not used for exception_type 'CHANGE_DURATION' or 'SHIFT_DURATION'
           l_old_value := get_old_value_text(v_c1.exception_type_code,
                                             p_assignment_id,
                                             v_c1.start_date,
                                             v_c1.end_date);
           /*Added for bug 1635170 */
           IF (v_c1.exception_type_code = 'CHANGE_DURATION' OR v_c1.exception_type_code = 'SHIFT_DURATION'  OR v_c1.exception_type_code = 'DURATION_PATTERN_SHIFT' )THEN
              OPEN get_start_end_date;
              FETCH get_start_end_date into temp_start_date, temp_end_date;
              CLOSE get_start_end_date;

              IF (p_populate_mode = 'ASSIGNMENT_UPDATED' AND (p_exception_type_code='CHANGE_DURATION'
                  OR p_exception_type_code='SHIFT_DURATION'  OR p_exception_type_code = 'DURATION_PATTERN_SHIFT') ) THEN
                 SELECT DECODE(p_start_date, null, temp_start_date, p_start_date),
                        DECODE(p_end_date, null, temp_end_date, p_end_date)
                 INTO l_start_date,
                      l_end_date
                 FROM DUAL;
              ELSE
                 l_start_date := temp_start_date;
                 l_end_date   := temp_end_date;
              END IF;

              l_insert_schedule_change := FALSE;
           END IF;
           /*End of bug 1635170 */

           IF (v_c1.exception_type_code = 'CHANGE_HOURS' AND v_c1.change_hours_type_code='PERCENTAGE'
               AND v_c1.change_calendar_type_code='PROJECT') THEN
               OPEN get_project_calendar_id;
               FETCH get_project_calendar_id into l_calendar_id;
               CLOSE get_project_calendar_id;
           ELSE
               l_calendar_id := v_c1.calendar_id;
           END IF;

           -- l_start_date, l_end_date are used only for exception_type 'CHANGE_DURATION' or 'SHIFT_DURATION'
           l_new_value := get_new_value_text(v_c1.exception_type_code,
                                             l_calendar_id, --v_c1.calendar_id,
                                             l_start_date,
                                             l_end_date,
                                             v_c1.status_code,
                                             v_c1.change_calendar_id,
                                             v_c1.monday_hours,
                                             v_c1.tuesday_hours,
                                             v_c1.wednesday_hours,
                                             v_c1.thursday_hours,
                                             v_c1.friday_hours,
                                             v_c1.saturday_hours,
                                             v_c1.sunday_hours,
                                             v_c1.change_hours_type_code,
                                             v_c1.non_working_day_flag,
                                             v_c1.monday_hours,
                                             v_c1.resource_calendar_percent,
                                             v_c1.change_calendar_type_code,
                                             null);

           INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, date_range, old_value, new_value)
           VALUES (p_assignment_id, l_changed_item_name, l_date_range, l_old_value, l_new_value);
         END IF; /* Added for bug 1635170*/
      END LOOP;
  END IF;

  ---------------------------------------------------------------------------------
  -- Populate the temp table for the passed parameters (updated but not saved yet)
  ---------------------------------------------------------------------------------
  IF (p_populate_mode = 'SCHEDULE_UPDATED') THEN

     IF ((p_exception_type_code='CHANGE_DURATION' OR p_exception_type_code='SHIFT_DURATION'  OR p_exception_type_code = 'DURATION_PATTERN_SHIFT') AND
         l_insert_schedule_change = FALSE ) THEN
        null;

     -----------------------------------------------
     -- For work pattern changes (passed parameters)
     -----------------------------------------------
     ELSIF (p_exception_type_code = 'CHANGE_WORK_PATTERN') THEN

       IF p_start_date_tbl.COUNT > 0 THEN
         FOR j IN p_start_date_tbl.FIRST .. p_start_date_tbl.LAST LOOP

           l_changed_item_name := PA_SCHEDULE_PVT.get_changed_item_name_text(p_exception_type_code);

           l_date_range := PA_SCHEDULE_PVT.get_date_range_text(p_start_date_tbl(j), p_end_date_tbl(j));

           l_old_value := get_old_value_text(p_exception_type_code,
                                         p_assignment_id,
                                         p_start_date_tbl(j),
                                         p_end_date_tbl(j));

           l_new_value := get_new_value_text(p_exception_type_code,
                                          null,
                                          p_start_date_tbl(j),
                                          p_end_date_tbl(j),
                                          null,
                                          null,
                                          p_monday_hours_tbl(j),
                                          p_tuesday_hours_tbl(j),
                                          p_wednesday_hours_tbl(j),
                                          p_thursday_hours_tbl(j),
                                          p_friday_hours_tbl(j),
                                          p_saturday_hours_tbl(j),
                                          p_sunday_hours_tbl(j),
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null);

         INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, date_range, old_value, new_value)
         VALUES (p_assignment_id, l_changed_item_name, l_date_range, l_old_value, l_new_value);
         END LOOP;

       END IF;

     -----------------------------------------------
     -- For other  changes (passed parameters)
     -----------------------------------------------
     ELSE
       l_changed_item_name := PA_SCHEDULE_PVT.get_changed_item_name_text(p_exception_type_code);

       IF (p_exception_type_code='CHANGE_DURATION' OR p_exception_type_code='SHIFT_DURATION'  OR p_exception_type_code = 'DURATION_PATTERN_SHIFT') THEN
          l_date_range := ' ';
       ELSE
          l_date_range := PA_SCHEDULE_PVT.get_date_range_text(p_start_date, p_end_date);
       END IF;

       l_old_value := get_old_value_text(p_exception_type_code,
                                         p_assignment_id,
                                         p_start_date,
                                         p_end_date);

       IF (p_exception_type_code = 'CHANGE_DURATION' OR p_exception_type_code = 'SHIFT_DURATION'  OR p_exception_type_code = 'DURATION_PATTERN_SHIFT') THEN
          OPEN get_start_end_date;
          FETCH get_start_end_date into temp_start_date, temp_end_date;
          CLOSE get_start_end_date;

          IF p_exception_type_code = 'CHANGE_DURATION' THEN
             SELECT DECODE(p_start_date, null, temp_start_date, p_start_date),
                    DECODE(p_end_date, null, temp_end_date, p_end_date)
             INTO l_start_date,
                  l_end_date
             FROM DUAL;
          ELSE
             IF (p_number_of_shift is NOT NULL) THEN
                 -- compute shifted_days
                 IF (p_duration_shift_unit_code = 'DAYS') THEN
                     l_shifted_days := p_number_of_shift;
                 ELSIF (p_duration_shift_unit_code = 'WEEKS') THEN
                     l_shifted_days := p_number_of_shift*7;
                 END IF;

                 -- set start_Date, end_date according to shift_type_code and shifed_days
	         IF (p_duration_shift_type_code = 'FORWARD') THEN
                     IF (p_duration_shift_unit_code = 'MONTHS') THEN
                         l_start_date := add_months(temp_start_date, p_number_of_shift) ;
                         l_end_date   := add_months(temp_end_date, p_number_of_shift) ;
                     ELSE
		         l_start_date := temp_start_date + l_shifted_days;
                         l_end_date   := temp_end_date + l_shifted_days;
                     END IF;
	         ELSIF (p_duration_shift_type_code = 'BACKWARD') THEN
                     IF (p_duration_shift_unit_code = 'MONTHS') THEN
                         l_start_date := add_months(temp_start_date, p_number_of_shift * -1) ;
                         l_end_date   := add_months(temp_end_date, p_number_of_shift * -1) ;
                     ELSE
		         l_start_date := temp_start_date - l_shifted_days;
                         l_end_date   := temp_end_date - l_shifted_days;
                     END IF;
                 END IF;
             END IF;
          END IF; -- end of duration shift

       -- if project calendar has been selected, pass project_calendar_id
       ELSIF (p_exception_type_code = 'CHANGE_HOURS' AND p_change_hours_type_code='PERCENTAGE' AND
              p_change_calendar_type_code='PROEJCT') THEN
  	  SELECT calendar_id
          INTO  l_project_calendar_id
  	  FROM  pa_project_assignments
	  WHERE assignment_id = p_assignment_id;

       -- If Status has been updated, pass appropriate status_code
       ELSIF (p_exception_type_code = 'CHANGE_STATUS') THEN
  	  SELECT assignment_type
          INTO  l_assignment_type
  	  FROM  pa_project_assignments
	  WHERE assignment_id = p_assignment_id;

          IF (l_assignment_type = 'OPEN_ASSIGNMENT') THEN
             l_status_code := p_requirement_status_code;
          ELSE
             l_status_code := p_assignment_status_code;
          END IF;
       END IF;

       l_new_value := get_new_value_text (p_exception_type_code,
                                          l_project_calendar_id,
                                          l_start_date,
                                          l_end_date,
                                          l_status_code,
                                          p_change_calendar_id,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          null,
                                          p_change_hours_type_code,
                                          p_non_working_day_flag,
                                          p_hrs_per_day,
                                          p_calendar_percent,
                                          p_change_calendar_type_code,
                                          p_change_calendar_name);

       INSERT INTO pa_asgmt_changed_items (assignment_id, changed_item_name, date_range, old_value, new_value)
       VALUES (p_assignment_id, l_changed_item_name, l_date_range, l_old_value, l_new_value);
     END IF;
  END IF; -- IF (p_populate_mode = 'SCHEDULE_UPDATED')

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'update_asgmt_changed_items_tab');
    RAISE;

END update_asgmt_changed_items_tab;



-- Procedure  : check_overcommitment_single
-- Purpose		: First checks if this assignment alone causes resource
--              overcommitment. If Yes, then stores self-conflict and user
--              action in PA_ASSIGNMENT_CONFLICT_HIST.
PROCEDURE check_overcommitment_single( p_assignment_id     IN   NUMBER,
            p_resolve_conflict_action_code			IN		VARCHAR2,
            p_conflict_group_id           IN    NUMBER := NULL,
            x_overcommitment_flag               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_conflict_group_id           OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  G_AVAILABILITY_CAL_PERIOD VARCHAR2(15) := FND_PROFILE.VALUE('PA_AVAILABILITY_CAL_PERIOD');
  G_OVERCOMMITMENT_PERCENTAGE NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_OVERCOMMITMENT_PERCENTAGE'))/100;

  CURSOR c1 IS
    SELECT resource_id, start_date, end_date
    FROM pa_project_assignments
    WHERE assignment_id = p_assignment_id;

  l_assignment_id_tbl PA_PLSQL_DATATYPES.NumTabTyp;
  l_resource_id NUMBER;
  l_start_date DATE;
  l_end_date DATE;
  l_self_conflict_flag VARCHAR2(1) := 'N';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c1;
  FETCH c1 INTO l_resource_id, l_start_date, l_end_date;
  CLOSE c1;

IF l_resource_id IS NOT NULL THEN

  IF G_AVAILABILITY_CAL_PERIOD = 'DAILY' THEN

    select distinct fi.assignment_id
    BULK COLLECT INTO l_assignment_id_tbl
from pa_forecast_items fi,
(select resource_id,
sum(item_quantity) total_assigned_quantity,
item_date,
delete_flag,
forecast_item_type
from pa_forecast_items fi1, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
where (fi1.assignment_id = p_assignment_id or asgmt_sys_status_code = 'STAFFED_ASGMT_CONF' )
and fi1.assignment_id = sch.assignment_id
and fi1.item_date between sch.start_date and sch.end_date
and sch.status_code = a.project_status_code
and a.wf_success_status_code = b.project_status_code
and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
-- Added for bug 9039642
and fi1.delete_flag = 'N'
and fi1.forecast_item_type = 'A'
and fi1.resource_id = l_resource_id
and fi1.item_date between l_start_date AND l_end_date
group by resource_id, item_date, delete_flag, forecast_item_type
)fi_assigned,
(select resource_id,
 capacity_quantity,
 item_date,
 delete_flag
 from pa_forecast_items
 where forecast_item_type = 'U'
 )fi_capacity
where fi.assignment_id <> p_assignment_id
and fi.resource_id = l_resource_id
and fi.resource_id = fi_capacity.resource_id
and fi_capacity.resource_id = fi_assigned.resource_id
and fi_capacity.resource_id = l_resource_id -- Bug 4918687 SQL ID 14905966
and fi.item_date BETWEEN l_start_date AND l_end_date
and fi.item_date = fi_capacity.item_date
and fi_capacity.item_date = fi_assigned.item_date
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.total_assigned_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.total_assigned_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi.delete_flag = 'N'
and fi.delete_flag = fi_capacity.delete_flag
and fi_capacity.delete_flag = fi_assigned.delete_flag
and fi.forecast_item_type = 'A'
and fi.forecast_item_type = fi_assigned.forecast_item_type
and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF';

  -- Check self conflict.
  check_self_conflict(p_assignment_id => p_assignment_id,
    p_resource_id  => l_resource_id,
    p_start_date   => l_start_date,
    p_end_date     => l_end_date,
    x_self_conflict_flag => l_self_conflict_flag,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data);


  ELSIF G_AVAILABILITY_CAL_PERIOD = 'WEEKLY' THEN

    select distinct fi.assignment_id
    BULK COLLECT INTO l_assignment_id_tbl
from pa_forecast_items fi,
(select resource_id,
sum(item_quantity) total_assigned_quantity,
GLOBAL_EXP_PERIOD_END_DATE week_end_date,
delete_flag,
forecast_item_type
from pa_forecast_items fi1, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
where (fi1.assignment_id = p_assignment_id or asgmt_sys_status_code = 'STAFFED_ASGMT_CONF' )
and fi1.item_date between l_start_date and l_end_date
and fi1.assignment_id = sch.assignment_id
and fi1.item_date between sch.start_date and sch.end_date
and sch.status_code = a.project_status_code
and a.wf_success_status_code = b.project_status_code
and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag, forecast_item_type
)fi_assigned,
(select resource_id,
 sum(capacity_quantity) capacity_quantity,
 GLOBAL_EXP_PERIOD_END_DATE week_end_date,
 delete_flag
 from pa_forecast_items
 where forecast_item_type = 'U'
 group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag
 )fi_capacity
where fi.assignment_id <> p_assignment_id
and fi.resource_id = l_resource_id
and fi.resource_id = fi_capacity.resource_id
and fi_capacity.resource_id = fi_assigned.resource_id
and fi.item_date between l_start_date and l_end_date
and fi.GLOBAL_EXP_PERIOD_END_DATE = fi_capacity.week_end_date
and fi_capacity.week_end_date = fi_assigned.week_end_date
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.total_assigned_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.total_assigned_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi.delete_flag = 'N'
and fi.delete_flag = fi_capacity.delete_flag
and fi_capacity.delete_flag = fi_assigned.delete_flag
and fi.forecast_item_type = 'A'
and fi.forecast_item_type = fi_assigned.forecast_item_type
and fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF';

      -- Check self conflict.
  check_self_conflict(p_assignment_id => p_assignment_id,
    p_resource_id  => l_resource_id,
    p_start_date   => l_start_date,
    p_end_date     => l_end_date,
    x_self_conflict_flag => l_self_conflict_flag,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data);


  END IF;
END IF;

  -- Insert the self conflicting assignment_id if applicable.
  IF l_self_conflict_flag = 'Y' THEN
    IF l_assignment_id_tbl.COUNT > 0 THEN
      l_assignment_id_tbl(l_assignment_id_tbl.LAST+1) := p_assignment_id;
    ELSE
      l_assignment_id_tbl(1) := p_assignment_id;
    END IF;
  END IF;


  IF l_assignment_id_tbl.COUNT > 0 THEN
    x_overcommitment_flag := 'Y';
    PA_ASGN_CONFLICT_HIST_PKG.insert_rows(p_conflict_group_id => p_conflict_group_id,
      p_assignment_id              => p_assignment_id,
      p_conflict_assignment_id_tbl => l_assignment_id_tbl,
      p_resolve_conflict_action_code => p_resolve_conflict_action_code,
      p_processed_flag               => 'N',
      x_conflict_group_id       => x_conflict_group_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);

  ELSE
    x_overcommitment_flag := 'N';
    x_conflict_group_id := p_conflict_group_id;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
	x_overcommitment_flag := NULL ; -- 4537865
	x_conflict_group_id := NULL ;-- 4537865

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'check_overcommitment_single');
    RAISE;
END check_overcommitment_single;


-- Procedure  : check_overcommitment_mult
-- Purpose		: First checks if this assignment alone causes resource
--              overcommitment. If Yes, then stores self-conflict and user
--              action in PA_ASSIGNMENT_CONFLICT_HIST.
PROCEDURE check_overcommitment_mult(p_item_type  IN PA_WF_PROCESSES.item_type%TYPE,
            p_item_key           IN   PA_WF_PROCESSES.item_key%TYPE,
            p_conflict_group_id                 IN   NUMBER := NULL,
            p_resolve_conflict_action_code			IN		VARCHAR2,
            x_overcommitment_flag               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_conflict_group_id           OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  G_AVAILABILITY_CAL_PERIOD VARCHAR2(15) := FND_PROFILE.VALUE('PA_AVAILABILITY_CAL_PERIOD');
  G_OVERCOMMITMENT_PERCENTAGE NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_OVERCOMMITMENT_PERCENTAGE'))/100;

  l_assignment_id_tbl PA_PLSQL_DATATYPES.NumTabTyp;
  l_conflict_group_id NUMBER := p_conflict_group_id;
  -- added for bug fix: 4537865
  l_new_conflict_group_id  NUMBER;
  -- added for bug fix: 4537865
  l_intra_txn_conflict_flag_tbl SYSTEM.PA_VARCHAR2_1_TBL_TYPE;
  l_resource_id NUMBER;
  l_start_date DATE;
  l_end_date DATE;
  l_self_conflict_flag VARCHAR2(1) := 'N';

  CURSOR c1 IS
    SELECT assignment_id
    FROM pa_mass_txn_asgmt_success_v
    WHERE item_type = p_item_type
    AND item_key = p_item_key;

BEGIN
  PA_SCHEDULE_UTILS.debug('Entering check_overcommitment_mult');
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_c1 IN c1 LOOP
    IF v_c1.assignment_id IS NOT NULL THEN
      PA_SCHEDULE_UTILS.debug('v_c1.assignment_id = '|| v_c1.assignment_id);
      SELECT resource_id, start_date, end_date
      INTO l_resource_id, l_start_date, l_end_date
      FROM pa_project_assignments
      WHERE assignment_id = v_c1.assignment_id;
      PA_SCHEDULE_UTILS.debug('l_resource_id = '|| l_resource_id);

      IF G_AVAILABILITY_CAL_PERIOD = 'DAILY' THEN
    select distinct fi.assignment_id,
    decode (mass.assignment_id, null, 'N', 'Y') intra_txn_conflict_flag
    BULK COLLECT INTO l_assignment_id_tbl, l_intra_txn_conflict_flag_tbl
from pa_forecast_items fi, pa_mass_txn_asgmt_success_v mass, pa_schedules sch, pa_project_statuses a, pa_project_statuses b,
(select resource_id,
sum(item_quantity) total_assigned_quantity,
item_date,
delete_flag,
forecast_item_type
from
  (select resource_id,
  item_quantity,
  item_date,
  delete_flag,
  forecast_item_type
  from pa_forecast_items fi1, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
  where (fi1.assignment_id in (select assignment_id from pa_mass_txn_asgmt_success_v  where item_type = p_item_type and item_key = p_item_key)  or asgmt_sys_status_code = 'STAFFED_ASGMT_CONF' )
  and fi1.assignment_id = sch.assignment_id
  and fi1.item_date between sch.start_date and sch.end_date
  and sch.status_code = a.project_status_code
  and a.wf_success_status_code = b.project_status_code
  and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
  UNION ALL
  select resource_id,
  item_quantity,
  item_date,
  delete_flag,
  forecast_item_type
  from pa_forecast_items
  where asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
  and assignment_id not in (select assignment_id from pa_mass_txn_asgmt_success_v  where item_type = p_item_type and item_key = p_item_key))
group by resource_id, item_date, delete_flag, forecast_item_type
)FI_ASSIGNED,
(select resource_id,
 capacity_quantity,
 item_date,
 delete_flag
 from pa_forecast_items
 where forecast_item_type = 'U'
 )fi_capacity
where fi.assignment_id <> v_c1.assignment_id
and fi.resource_id = l_resource_id
and fi.resource_id = fi_capacity.resource_id
and fi_capacity.resource_id = fi_assigned.resource_id
and fi.item_date BETWEEN l_start_date AND l_end_date
and fi.item_date = fi_capacity.item_date
and fi_capacity.item_date = fi_assigned.item_date
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.total_assigned_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.total_assigned_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi.delete_flag = 'N'
and fi.delete_flag = fi_capacity.delete_flag
and fi_capacity.delete_flag = fi_assigned.delete_flag
and fi.forecast_item_type = 'A'
and fi.forecast_item_type = fi_assigned.forecast_item_type
and fi.assignment_id = mass.assignment_id(+)
and mass.item_type(+) = p_item_type
and mass.item_key(+) = p_item_key
and (fi.assignment_id in (select assignment_id from pa_mass_txn_asgmt_success_v  where item_type = p_item_type and item_key = p_item_key) or fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF')
and fi.assignment_id = sch.assignment_id
and fi.item_date between sch.start_date and sch.end_date
and sch.status_code = a.project_status_code
and a.wf_success_status_code = b.project_status_code
and b.project_system_status_code = 'STAFFED_ASGMT_CONF';


  -- Check self conflict.
  check_self_conflict(p_assignment_id => v_c1.assignment_id,
    p_resource_id  => l_resource_id,
    p_start_date   => l_start_date,
    p_end_date     => l_end_date,
    x_self_conflict_flag => l_self_conflict_flag,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data);


  ELSIF G_AVAILABILITY_CAL_PERIOD = 'WEEKLY' THEN
  PA_SCHEDULE_UTILS.debug('Entering check_overcommitment_mult: WEEKLY');

    select distinct fi.assignment_id,
    decode (mass.assignment_id, null, 'N', 'Y') intra_txn_flag
    BULK COLLECT INTO l_assignment_id_tbl, l_intra_txn_conflict_flag_tbl
from pa_forecast_items fi,  pa_mass_txn_asgmt_success_v mass, pa_schedules sch, pa_project_statuses a, pa_project_statuses b,
(select resource_id,
sum(item_quantity) total_assigned_quantity,
GLOBAL_EXP_PERIOD_END_DATE,
delete_flag,
forecast_item_type
from
  (select resource_id,
  item_quantity,
  GLOBAL_EXP_PERIOD_END_DATE,
  delete_flag,
  forecast_item_type
  from pa_forecast_items fi1, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
  where (fi1.assignment_id in (select assignment_id from pa_mass_txn_asgmt_success_v  where item_type = p_item_type and item_key = p_item_key)  or asgmt_sys_status_code = 'STAFFED_ASGMT_CONF' )
  and fi1.item_date between l_start_date and l_end_date
  and fi1.assignment_id = sch.assignment_id
  and fi1.item_date between sch.start_date and sch.end_date
  and sch.status_code = a.project_status_code
  and a.wf_success_status_code = b.project_status_code
  and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
  UNION ALL
  select resource_id,
  item_quantity,
  GLOBAL_EXP_PERIOD_END_DATE,
  delete_flag,
  forecast_item_type
  from pa_forecast_items
  where asgmt_sys_status_code = 'STAFFED_ASGMT_CONF'
  and item_date between l_start_date and l_end_date
  and assignment_id not in (select assignment_id from pa_mass_txn_asgmt_success_v  where item_type = p_item_type and item_key = p_item_key))
group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag, forecast_item_type
)FI_ASSIGNED,
(select resource_id,
 sum(capacity_quantity) capacity_quantity,
 GLOBAL_EXP_PERIOD_END_DATE,
 delete_flag
 from pa_forecast_items
 where forecast_item_type = 'U'
 group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag
 )fi_capacity
where fi.assignment_id <> v_c1.assignment_id
and fi.resource_id = l_resource_id
and fi.resource_id = fi_capacity.resource_id
and fi_capacity.resource_id = fi_assigned.resource_id
and fi.item_date BETWEEN l_start_date AND l_end_date
and fi.GLOBAL_EXP_PERIOD_END_DATE = fi_capacity.GLOBAL_EXP_PERIOD_END_DATE
and fi_capacity.GLOBAL_EXP_PERIOD_END_DATE = fi_assigned.GLOBAL_EXP_PERIOD_END_DATE
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.total_assigned_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.total_assigned_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi.delete_flag = 'N'
and fi.delete_flag = fi_capacity.delete_flag
and fi_capacity.delete_flag = fi_assigned.delete_flag
and fi.forecast_item_type = 'A'
and fi.forecast_item_type = fi_assigned.forecast_item_type
and fi.assignment_id = mass.assignment_id(+)
and mass.item_type(+) = p_item_type
and mass.item_key(+) = p_item_key
and (fi.assignment_id in (select assignment_id from pa_mass_txn_asgmt_success_v  where item_type = p_item_type and item_key = p_item_key) or fi.asgmt_sys_status_code = 'STAFFED_ASGMT_CONF')
and fi.assignment_id = sch.assignment_id
and fi.item_date between sch.start_date and sch.end_date
and sch.status_code = a.project_status_code
and a.wf_success_status_code = b.project_status_code
and b.project_system_status_code = 'STAFFED_ASGMT_CONF';


  PA_SCHEDULE_UTILS.debug('Before check_self_conflict');

      -- Check self conflict.
  check_self_conflict(p_assignment_id => v_c1.assignment_id,
    p_resource_id  => l_resource_id,
    p_start_date   => l_start_date,
    p_end_date     => l_end_date,
    x_self_conflict_flag => l_self_conflict_flag,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data);

      PA_SCHEDULE_UTILS.debug('After check_self_conflict');

      END IF;

      -- Insert the self conflicting assignment_id if applicable.
      IF l_self_conflict_flag = 'Y' THEN
        IF l_assignment_id_tbl.COUNT > 0 THEN
          l_assignment_id_tbl(l_assignment_id_tbl.LAST+1) := v_c1.assignment_id;
          l_intra_txn_conflict_flag_tbl.EXTEND;
          l_intra_txn_conflict_flag_tbl(l_intra_txn_conflict_flag_tbl.LAST) := 'N';
        ELSE
          select v_c1.assignment_id, 'N'
          bulk collect into l_assignment_id_tbl, l_intra_txn_conflict_flag_tbl
          from dual;
        --  l_assignment_id_tbl(1) := v_c1.assignment_id;
        --  l_intra_txn_conflict_flag_tbl(1) := 'N';
        END IF;
      END IF;

      PA_SCHEDULE_UTILS.debug('Before insert_rows into conflict history');
      IF l_assignment_id_tbl.COUNT > 0 THEN
        PA_ASGN_CONFLICT_HIST_PKG.insert_rows(p_conflict_group_id => l_conflict_group_id,
          p_assignment_id                => v_c1.assignment_id,
          p_conflict_assignment_id_tbl   => l_assignment_id_tbl,
          p_resolve_conflict_action_code => p_resolve_conflict_action_code,
          p_intra_txn_conflict_flag_tbl  => l_intra_txn_conflict_flag_tbl,
          p_processed_flag               => 'N',
        --x_conflict_group_id            => l_conflict_group_id,		* commented for bug: 4537865
	  x_conflict_group_id		 => l_new_conflict_group_id,		-- added for bug fix: 4537865
          x_return_status           => x_return_status,
          x_msg_count               => x_msg_count,
          x_msg_data                => x_msg_data);

	-- added for bug fix: 4537865
       IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
       l_conflict_group_id := l_new_conflict_group_id;
       END IF;
	-- added for bug fix: 4537865

       END IF;
    PA_SCHEDULE_UTILS.debug('After insert_rows into conflict history');

    END IF;
  END LOOP;

  IF l_conflict_group_id IS NOT NULL THEN
    x_overcommitment_flag := 'Y';
    x_conflict_group_id := l_conflict_group_id;
  ELSE
    x_overcommitment_flag := 'N';
    x_conflict_group_id := NULL;
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
        x_overcommitment_flag := NULL ; -- 4537865
        x_conflict_group_id := NULL ;-- 4537865
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'check_overcommitment_mult');
    RAISE;
END check_overcommitment_mult;


-- Procedure  : check_self_conflict
-- Purpose		: Check if the assignment is causing self conflict.
--
PROCEDURE check_self_conflict(p_assignment_id   IN  NUMBER,
            p_resource_id            IN    NUMBER,
            p_start_date             IN    DATE,
            p_end_date               IN    DATE,
            x_self_conflict_flag     OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  G_AVAILABILITY_CAL_PERIOD VARCHAR2(15) := FND_PROFILE.VALUE('PA_AVAILABILITY_CAL_PERIOD');
  G_OVERCOMMITMENT_PERCENTAGE NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_OVERCOMMITMENT_PERCENTAGE'))/100;

  l_week_start_date DATE;
  l_week_end_date DATE;

  -- Cursor for Daily.
  CURSOR c1 IS
SELECT fi_assigned.item_quantity, fi_assigned.item_date from
(select
resource_id,
item_quantity,
item_date,
asgmt_sys_status_code,
delete_flag
from pa_forecast_items fi, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
where fi.assignment_id = p_assignment_id
and fi.assignment_id = sch.assignment_id
and fi.item_date between sch.start_date and sch.end_date
and forecast_item_type = 'A'
and sch.status_code = a.project_status_code
and a.wf_success_status_code = b.project_status_code
and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
)fi_assigned,
(select resource_id,
 capacity_quantity capacity_quantity,
 item_date,
 delete_flag
 from pa_forecast_items
 where forecast_item_type = 'U'
 )fi_capacity
where fi_assigned.resource_id = p_resource_id
and fi_assigned.resource_id = fi_capacity.resource_id
and fi_assigned.item_date between p_start_date and p_end_date
and fi_assigned.item_date = fi_capacity.item_date
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.item_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.item_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi_assigned.delete_flag = 'N'
and fi_assigned.delete_flag = fi_capacity.delete_flag;

  -- Cursor for Weekly.
  CURSOR c2 IS
    SELECT fi_assigned.weekly_quantity, fi_assigned.week_end_date
from
(select resource_id,
sum(item_quantity) weekly_quantity,
GLOBAL_EXP_PERIOD_END_DATE week_end_date,
delete_flag
from pa_forecast_items fi, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
where fi.assignment_id = p_assignment_id
and fi.assignment_id = sch.assignment_id
and item_date between l_week_start_date and l_week_end_date
and item_date between sch.start_date and sch.end_date
and forecast_item_type = 'A'
and sch.status_code = a.project_status_code
and a.wf_success_status_code = b.project_status_code
and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag
)fi_assigned,
(select resource_id,
 sum(capacity_quantity) capacity_quantity,
 GLOBAL_EXP_PERIOD_END_DATE week_end_date,
 delete_flag
 from pa_forecast_items
 where forecast_item_type = 'U'
 and item_date between l_week_start_date and l_week_end_date
 group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag
 )fi_capacity
where fi_assigned.resource_id = p_resource_id
and fi_assigned.resource_id = fi_capacity.resource_id
and fi_assigned.week_end_date = fi_capacity.week_end_date
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.weekly_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.weekly_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi_assigned.delete_flag = 'N'
and fi_assigned.delete_flag = fi_capacity.delete_flag;

  v_c1 c1%ROWTYPE;
  v_c2 c2%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF G_AVAILABILITY_CAL_PERIOD = 'DAILY' THEN
    OPEN c1;
    FETCH c1 INTO v_c1;
    IF c1%NOTFOUND THEN
      x_self_conflict_flag := 'N';
    ELSE
      x_self_conflict_flag := 'Y';
    END IF;
    CLOSE c1;
  PA_SCHEDULE_UTILS.debug('daily: x_self_conflict_flag = ' || x_self_conflict_flag);
  ELSIF G_AVAILABILITY_CAL_PERIOD = 'WEEKLY' THEN
    -- Bug 2288823: check_self_conflict for the period from the week start date of
    -- p_start_date and the week end date of p_end_date for WEEKLY profile.
    l_week_start_date := PA_TIMELINE_UTIL.get_week_end_date(p_org_id => NULL,
                             p_given_date   => p_start_date) - 6;
    l_week_end_date := PA_TIMELINE_UTIL.get_week_end_date(p_org_id => NULL,
                             p_given_date   => p_end_date);
    OPEN c2;
    FETCH c2 INTO v_c2;
    IF c2%NOTFOUND THEN
      x_self_conflict_flag := 'N';
    ELSE
      x_self_conflict_flag := 'Y';
    END IF;
    CLOSE c2;
  PA_SCHEDULE_UTILS.debug('weekly: x_self_conflict_flag = ' || x_self_conflict_flag);
  END IF;


  EXCEPTION
    WHEN OTHERS THEN
      x_self_conflict_flag := NULL ; -- 4537865
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'check_self_conflict');
    RAISE;
END check_self_conflict;


-- Procedure  : resolve_conflicts
-- Purpose		: Resolves remaining conflicts by taking action chosen to user
--              detailed in PA_ASSIGNMENT_CONFLICT_HIST. Updates
--              processed_flag in the table once complete.
PROCEDURE resolve_conflicts( p_conflict_group_id   IN   NUMBER,
            p_assignment_id     IN   NUMBER,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  G_AVAILABILITY_CAL_PERIOD VARCHAR2(15) := FND_PROFILE.VALUE('PA_AVAILABILITY_CAL_PERIOD');
  G_OVERCOMMITMENT_PERCENTAGE NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_OVERCOMMITMENT_PERCENTAGE'))/100;

  -- Cursor c1 is used to resolve_conflicts_action_code.
  CURSOR c1 IS
    SELECT DISTINCT resolve_conflicts_action_code
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND assignment_id = p_assignment_id
    AND processed_flag = 'N';

  v_c1 c1%ROWTYPE;

  -- Cursor c3 is used to retrieve all the conflicting assignments and also
  -- check if they are locked in another mass wf process.
  CURSOR c3 IS
    SELECT conflict_assignment_id,
      decode(asgn.MASS_WF_IN_PROGRESS_FLAG,
        'Y', decode(hist.intra_txn_conflict_flag, 'N', 'Y', 'N'),
        decode(asgn.apprvl_status_code, 'ASGMT_APPRVL_SUBMITTED', 'Y', 'N')) locking_flag
    FROM pa_assignment_conflict_hist hist, pa_project_assignments asgn
    WHERE hist.conflict_assignment_id = asgn.assignment_id
    AND hist.conflict_group_id = p_conflict_group_id
    AND hist.assignment_id = p_assignment_id
    AND hist.processed_flag = 'N'
    AND hist.resolve_conflicts_action_code = 'REMOVE_CONFLICTS'
    AND hist.self_conflict_flag = 'N';

  -- Parameters for the causing assignment.
  l_resource_id NUMBER;
  l_asn_start_date DATE;
  l_asn_end_date DATE;
  l_resolve_conflict_action_code VARCHAR2(30);

  -- Parameters for the conflicting assignment used to call
  -- PA_SCHEDULE_PUB.change_work_pattern.
  l_record_version_number NUMBER;
  l_project_id NUMBER;
  l_calendar_id NUMBER;
  l_assignment_type pa_project_assignments.assignment_type%TYPE;
  l_start_date DATE;
  l_end_date DATE;
  l_asgn_start_date DATE;
  l_asgn_end_date DATE;

  -- The start date and end date of an assignment causing conflicts.
  l_conflict_start_date DATE;
  l_conflict_end_date DATE;

  -- Parameters used to contruct the work pattern record table.
  l_count NUMBER;
  l_flag VARCHAR2(1);
  l_cur_assignment_id NUMBER;
  l_cur_item_date DATE;
  l_cur_week_end_date DATE;
  l_cur_overcom_quantity NUMBER;
  l_assignment_id_tbl PA_PLSQL_DATATYPES.IdTabTyp;
  l_item_date_tbl PA_PLSQL_DATATYPES.DateTabTyp;
  l_week_end_date_tbl PA_PLSQL_DATATYPES.DateTabTyp;
  l_item_quantity_tbl PA_PLSQL_DATATYPES.NumTabTyp;
  l_overcom_quantity_tbl PA_PLSQL_DATATYPES.NumTabTyp;
  l_work_pattern_tbl WorkPatternTabTyp;
  l_cur_work_pattern_tbl WorkPatternTabTyp;

  l_msg_index_out NUMBER;
  -- added for Bug fix: 4537865
  l_new_msg_data  VARCHAR2(2000);
  -- added for Bug fix: 4537865

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  PA_SCHEDULE_UTILS.debug('p_conflict_group_id = ' || p_conflict_group_id);

  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    l_resolve_conflict_action_code := 'NO_DATA_FOUND';
  ELSE
    l_resolve_conflict_action_code := v_c1.resolve_conflicts_action_code;
  END IF;
  CLOSE c1;

  PA_SCHEDULE_UTILS.debug('l_resolve_conflict_action_code = ' || l_resolve_conflict_action_code);

  -- Processing for action code 'KEEP_CONFLICTS'
  IF l_resolve_conflict_action_code = 'KEEP_CONFLICTS' THEN
    PA_ASGN_CONFLICT_HIST_PKG.update_rows(p_conflict_group_id => p_conflict_group_id,
        p_assignment_id           => p_assignment_id,
        p_processed_flag          => 'Y',
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data);

  ELSIF l_resolve_conflict_action_code = 'REMOVE_CONFLICTS' THEN
    -- Check if any conflicting assignments are locked in another mass wf
    -- process. If yes, return status 'E', populate the error stack with the
    -- error message.
    FOR v_c3 IN c3 LOOP
      IF v_c3.locking_flag = 'Y' THEN
        pa_schedule_utils.log_message(1, 'Remove conflicts failed due to assignments locking');
        RAISE l_remove_conflicts_failed;
      END IF;
    END LOOP;

    SELECT resource_id, start_date, end_date
    INTO l_resource_id, l_asn_start_date, l_asn_end_date
    FROM pa_project_assignments
    WHERE assignment_id = p_assignment_id;

    IF G_AVAILABILITY_CAL_PERIOD = 'DAILY' THEN
      l_conflict_start_date := l_asn_start_date;
      l_conflict_end_date := l_asn_end_date;

      SELECT DISTINCT conf.conflict_assignment_id,
fi.item_date,
fi.GLOBAL_EXP_PERIOD_END_DATE,
fi.item_quantity,
fi_overcom.overcommitment_quantity
BULK COLLECT INTO l_assignment_id_tbl, l_item_date_tbl, l_week_end_date_tbl, l_item_quantity_tbl, l_overcom_quantity_tbl
FROM pa_forecast_items fi,
pa_assignment_conflict_hist conf,
(SELECT
resource_id,
item_date,
DECODE(sign(capacity_quantity*G_OVERCOMMITMENT_PERCENTAGE-overcommitment_quantity), 1, 0, overcommitment_quantity) overcommitment_quantity,
delete_flag
FROM pa_forecast_items
WHERE forecast_item_type = 'U'
) fi_overcom
WHERE fi.resource_id = l_resource_id
AND fi.resource_id = fi_overcom.resource_id
AND fi.item_date between l_conflict_start_date AND l_conflict_end_date
AND fi.item_date = fi_overcom.item_date
AND fi.delete_flag = 'N'
AND fi.delete_flag = fi_overcom.delete_flag
AND fi.forecast_item_type = 'A'
AND fi.assignment_id = conf.conflict_assignment_id
AND conf.assignment_id = p_assignment_id
AND conf.conflict_group_id = p_conflict_group_id
AND conf.resolve_conflicts_action_code = 'REMOVE_CONFLICTS'
AND conf.self_conflict_flag = 'N'
AND fi_overcom.overcommitment_quantity > 0
ORDER BY fi.item_date, fi.item_quantity asc;

    ELSIF G_AVAILABILITY_CAL_PERIOD = 'WEEKLY' THEN
      l_conflict_start_date := l_asn_start_date;
      l_conflict_end_date := l_asn_end_date;
      SELECT DISTINCT fi.assignment_id,
fi.item_date,
fi.GLOBAL_EXP_PERIOD_END_DATE,
fi.item_quantity,
fi_overcom.overcommitment_quantity
BULK COLLECT INTO l_assignment_id_tbl, l_item_date_tbl, l_week_end_date_tbl, l_item_quantity_tbl, l_overcom_quantity_tbl
FROM pa_forecast_items fi, pa_assignment_conflict_hist conf,
(SELECT
resource_id,
overcommitment_quantity,
item_date,
delete_flag
from pa_forecast_items
where forecast_item_type = 'U'
)fi_overcom,
(SELECT
resource_id,
GLOBAL_EXP_PERIOD_END_DATE week_end_date,
decode(sign(sum(capacity_quantity)*G_OVERCOMMITMENT_PERCENTAGE-sum(overcommitment_quantity)), 1, 0, sum(overcommitment_quantity)) overcommitment_quantity,
delete_flag
FROM pa_forecast_items
WHERE forecast_item_type = 'U'
AND item_date BETWEEN l_conflict_start_date AND l_conflict_end_date
GROUP BY resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag
) fi_week
WHERE fi.resource_id = l_resource_id
AND fi.resource_id = fi_overcom.resource_id
AND fi_overcom.resource_id = fi_week.resource_id
AND fi.item_date BETWEEN l_conflict_start_date AND l_conflict_end_date
AND fi.item_date = fi_overcom.item_date
AND fi.GLOBAL_EXP_PERIOD_END_DATE = fi_week.week_end_date
AND fi.delete_flag = 'N'
AND fi.delete_flag = fi_overcom.delete_flag
AND fi_overcom.delete_flag = fi_week.delete_flag
AND fi.forecast_item_type = 'A'
AND fi.assignment_id = conf.conflict_assignment_id
AND conf.assignment_id = p_assignment_id
AND conf.conflict_group_id = p_conflict_group_id
AND conf.resolve_conflicts_action_code = 'REMOVE_CONFLICTS'
AND conf.self_conflict_flag = 'N'
AND fi_week.overcommitment_quantity > 0
ORDER BY fi.item_date, fi.item_quantity asc;


    END IF;

    IF l_assignment_id_tbl.COUNT > 0 THEN
      l_count := 0;
      l_cur_item_date := l_item_date_tbl(l_item_date_tbl.FIRST)-1;
      --PA_SCHEDULE_UTILS.debug ('l_cur_item_date = '|| l_cur_item_date);
      l_cur_week_end_date := l_week_end_date_tbl(l_week_end_date_tbl.FIRST);
      --PA_SCHEDULE_UTILS.debug ('l_cur_week_end_date = '|| l_cur_week_end_date);

      FOR j IN l_assignment_id_tbl.FIRST .. l_assignment_id_tbl.LAST LOOP
      --PA_SCHEDULE_UTILS.debug ('Entering l_assignment_id_tbl LOOP');
      --PA_SCHEDULE_UTILS.debug ('j = ' || j);

        -- When starting a new week.
        IF l_week_end_date_tbl(j) <> l_cur_week_end_date AND l_cur_work_pattern_tbl.COUNT > 0 THEN
          --PA_SCHEDULE_UTILS.debug('New week: l_week_end_date_tbl(j) = '||l_week_end_date_tbl(j));
          l_cur_week_end_date := l_week_end_date_tbl(j);
          -- Insert l_cur_work_pattern_tbl into l_work_pattern_tbl
          insert_work_pattern_tab(p_cur_work_pattern_tbl => l_cur_work_pattern_tbl,
           x_work_pattern_tbl  => l_work_pattern_tbl,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data);
          --empty l_cur_work_pattern_tbl
          l_cur_work_pattern_tbl.DELETE;

        END IF;

        -- When starting a new item_date.
        IF l_item_date_tbl(j) <> l_cur_item_date THEN
          --PA_SCHEDULE_UTILS.debug('New item date: l_item_date_tbl(j) = '||l_item_date_tbl(j));
          -- Remove the overcommitment quantity for all the assignments
          -- on the current item date.
          IF l_count > 0 THEN
            update_work_pattern_record(p_overcom_quantity => l_cur_overcom_quantity,
             p_count             => l_count,
             p_item_date         => l_cur_item_date,
             x_work_pattern_tbl  => l_cur_work_pattern_tbl,
             x_return_status           => x_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data);
          END IF;

          -- Start counting for a new item date.
				  l_count := 1;
          l_cur_item_date := l_item_date_tbl(j);
          l_cur_assignment_id := l_assignment_id_tbl(j);
          l_cur_overcom_quantity := l_overcom_quantity_tbl(j);

          insert_work_pattern_record(p_assignment_id => l_assignment_id_tbl(j),
           p_item_quantity    => l_item_quantity_tbl(j),
           p_item_date        => l_item_date_tbl(j),
           p_week_end_date     => l_week_end_date_tbl(j),
           x_work_pattern_tbl => l_cur_work_pattern_tbl,
           x_return_status           => x_return_status,
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data);

        -- When starting a new assignment on the same item_date.
        ELSIF l_item_date_tbl(j) = l_cur_item_date AND l_assignment_id_tbl(j) <> l_cur_assignment_id THEN
          --PA_SCHEDULE_UTILS.debug('New assignment: l_assignment_id_tbl(j) = '||l_assignment_id_tbl(j));
          l_count := l_count +1;
          insert_work_pattern_record(p_assignment_id => l_assignment_id_tbl(j),
           p_item_quantity    => l_item_quantity_tbl(j),
           p_item_date        => l_item_date_tbl(j),
           p_week_end_date     => l_week_end_date_tbl(j),
           x_work_pattern_tbl => l_cur_work_pattern_tbl,
           x_return_status           => x_return_status,
           x_msg_count               => x_msg_count,
           x_msg_data                => x_msg_data);

        END IF;

        -- Update work pattern for the last day in the current week.
        IF (j <> l_assignment_id_tbl.LAST AND l_week_end_date_tbl(j+1) <> l_cur_week_end_date) OR j = l_assignment_id_tbl.LAST THEN
          update_work_pattern_record(p_overcom_quantity => l_cur_overcom_quantity,
             p_count             => l_count,
             p_item_date         => l_cur_item_date,
             x_work_pattern_tbl  => l_cur_work_pattern_tbl,
             x_return_status           => x_return_status,
             x_msg_count               => x_msg_count,
             x_msg_data                => x_msg_data);
        END IF;


        -- Insert the current work pattern record into l_work_pattern_tbl for the last
        -- week of the l_assignment_id_tbl loop.
        IF j = l_assignment_id_tbl.LAST THEN
          -- Insert l_cur_work_pattern_tbl into l_work_pattern_tbl
          insert_work_pattern_tab(p_cur_work_pattern_tbl => l_cur_work_pattern_tbl,
           x_work_pattern_tbl  => l_work_pattern_tbl,
           x_return_status     => x_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data);
          --empty l_cur_work_pattern_tbl
          l_cur_work_pattern_tbl.DELETE;
        END IF;

      END LOOP;


      -- Update schedules for those conflicting assignments based on the work
      -- pattern information stored in l_work_pattern_tbl.
      FOR v_c3 IN c3 LOOP
        PA_SCHEDULE_UTILS.debug ('Entering c3 loop');
        -- 2167889: null instead of record_version_number
        SELECT null, project_id, calendar_id, assignment_type,start_date, end_date
        INTO l_record_version_number, l_project_id, l_calendar_id, l_assignment_type, l_asgn_start_date, l_asgn_end_date
        FROM pa_project_assignments
        WHERE assignment_id = v_c3.conflict_assignment_id;
        PA_SCHEDULE_UTILS.debug ('l_work_pattern_tbl.COUNT = '|| l_work_pattern_tbl.COUNT);
        FOR i IN l_work_pattern_tbl.FIRST .. l_work_pattern_tbl.LAST LOOP
          IF l_work_pattern_tbl(i).assignment_id = v_c3.conflict_assignment_id THEN

            -- Calculate the start_date and end_date for the updating period.
            -- Bug 2146377: Added start_date/end_date constraint so that the updating
            -- period is always within the conflict_start_date and conflict_end_date.
            -- Also, it is always within the asgn_start_date and asgn_end_date.
            l_start_date := l_work_pattern_tbl(i).start_date;
            l_end_date := l_work_pattern_tbl(i).end_date;
            IF trunc(l_start_date) < trunc(l_conflict_start_date)
              OR trunc(l_start_date) < trunc(l_asgn_start_date) THEN
                IF trunc(l_conflict_start_date) < trunc(l_asgn_start_date) THEN
                  l_start_date := l_asgn_start_date;
                ELSE
                  l_start_date := l_conflict_start_date;
                END IF;
            END IF;
            IF trunc(l_end_date) > trunc(l_conflict_end_date)
              OR trunc(l_end_date) > trunc(l_asgn_end_date) THEN
              IF trunc(l_conflict_end_date) > trunc(l_asgn_end_date) THEN
                l_end_date := l_asgn_end_date;
              ELSE
                l_end_date := l_conflict_end_date;
              END IF;
            END IF;
            PA_SCHEDULE_UTILS.debug('Before Change Work Pattern');
            PA_SCHEDULE_UTILS.debug('l_start_date = '|| l_start_date);
            PA_SCHEDULE_UTILS.debug('l_end_date = '|| l_end_date);

            IF l_work_pattern_tbl(i).monday_hours = -99 THEN
               l_work_pattern_tbl(i).monday_hours := NULL;
            END IF;
            IF l_work_pattern_tbl(i).tuesday_hours = -99 THEN
               l_work_pattern_tbl(i).tuesday_hours := NULL;
            END IF;
            IF l_work_pattern_tbl(i).wednesday_hours = -99 THEN
               l_work_pattern_tbl(i).wednesday_hours := NULL;
            END IF;
            IF l_work_pattern_tbl(i).thursday_hours = -99 THEN
               l_work_pattern_tbl(i).thursday_hours := NULL;
            END IF;
            IF l_work_pattern_tbl(i).friday_hours = -99 THEN
               l_work_pattern_tbl(i).friday_hours := NULL;
            END IF;
            IF l_work_pattern_tbl(i).saturday_hours = -99 THEN
               l_work_pattern_tbl(i).saturday_hours := NULL;
            END IF;
            IF l_work_pattern_tbl(i).sunday_hours = -99 THEN
               l_work_pattern_tbl(i).sunday_hours := NULL;
            END IF;

PA_SCHEDULE_UTILS.debug('work_pattern = '||
l_work_pattern_tbl(i).monday_hours||';'||
l_work_pattern_tbl(i).tuesday_hours||';'||
l_work_pattern_tbl(i).wednesday_hours||';'||
l_work_pattern_tbl(i).thursday_hours||';'||
l_work_pattern_tbl(i).friday_hours||';'||
l_work_pattern_tbl(i).saturday_hours||';'||
l_work_pattern_tbl(i).sunday_hours);

            PA_SCHEDULE_PUB.change_work_pattern(
              p_record_version_number  => l_record_version_number,
	            p_project_id             => l_project_id,
	            p_calendar_id            => l_calendar_id,
	            p_assignment_id          => v_c3.conflict_assignment_id,
	            p_assignment_type        => l_assignment_type,
	            p_start_date             => l_start_date,
	            p_end_date               => l_end_date,
	            p_monday_hours           => l_work_pattern_tbl(i).monday_hours,
	            p_tuesday_hours          => l_work_pattern_tbl(i).tuesday_hours,
	            p_wednesday_hours        => l_work_pattern_tbl(i).wednesday_hours,
	            p_thursday_hours         => l_work_pattern_tbl(i).thursday_hours,
	            p_friday_hours           => l_work_pattern_tbl(i).friday_hours,
	            p_saturday_hours         => l_work_pattern_tbl(i).saturday_hours,
	            p_sunday_hours           => l_work_pattern_tbl(i).sunday_hours,
	            p_asgn_start_date        => l_asgn_start_date,
	            p_asgn_end_date          => l_asgn_end_date,
              p_remove_conflict_flag   => 'Y',
	            x_return_status          => x_return_status,
	            x_msg_count              => x_msg_count,
	            x_msg_data               => x_msg_data );

          PA_SCHEDULE_UTILS.debug('After Change Work Pattern');
          END IF;
        END LOOP;

        -- Update pa_assignment_conflict_hist table.
        IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
          PA_ASGN_CONFLICT_HIST_PKG.update_rows(p_conflict_group_id => p_conflict_group_id,
            p_assignment_id           => p_assignment_id,
            p_processed_flag          => 'Y',
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data);
        END IF;

      END LOOP;
    END IF;

  END IF;

  EXCEPTION
    WHEN l_remove_conflicts_failed THEN
     PA_UTILS.add_message('PA','PA_REMOVE_CONFLICTS_FAILED');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_REMOVE_CONFLICTS_FAILED';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 IF x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
				      --p_data           => x_msg_data,		* Commented for Bug fix: 4537865
					p_data		 => l_new_msg_data,	-- added for Bug fix: 4537865
					p_msg_index_out  => l_msg_index_out );
				-- added for Bug fix: 4537865
					x_msg_data := l_new_msg_data;
				-- added for Bug fix: 4537865
		 End IF;
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'resolve_conflicts');
    RAISE;
END resolve_conflicts;


PROCEDURE insert_work_pattern_record( p_assignment_id   IN   NUMBER,
            p_item_quantity     IN   NUMBER,
            p_item_date         IN   DATE,
            p_week_end_date     IN   DATE,
            x_work_pattern_tbl  IN OUT NOCOPY WorkPatternTabTyp,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS

  l_count NUMBER :=0;
  l_flag VARCHAR(2) := 'N';
  l_week_day VARCHAR2(15);

BEGIN

  FOR j IN 1 .. x_work_pattern_tbl.COUNT LOOP
    IF x_work_pattern_tbl(j).assignment_id = p_assignment_id THEN
      l_count := j;
      l_flag := 'Y';
      EXIT;
    END IF;
  END LOOP;

  IF l_flag = 'N' THEN
    l_count := x_work_pattern_tbl.COUNT +1;
    x_work_pattern_tbl(l_count).assignment_id := p_assignment_id;
    x_work_pattern_tbl(l_count).start_date := p_week_end_date -6;
    x_work_pattern_tbl(l_count).end_date := p_week_end_date;
    x_work_pattern_tbl(l_count).monday_hours := -99;
    x_work_pattern_tbl(l_count).tuesday_hours := -99;
    x_work_pattern_tbl(l_count).wednesday_hours :=-99;
    x_work_pattern_tbl(l_count).thursday_hours :=-99;
    x_work_pattern_tbl(l_count).friday_hours :=-99;
    x_work_pattern_tbl(l_count).saturday_hours := -99;
    x_work_pattern_tbl(l_count).sunday_hours :=-99;
  END IF;

  l_week_day := TO_CHAR(p_item_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

  IF l_week_day = 'MON' THEN
    x_work_pattern_tbl(l_count).monday_hours := p_item_quantity;
  ELSIF l_week_day = 'TUE' THEN
    x_work_pattern_tbl(l_count).tuesday_hours := p_item_quantity;
  ELSIF l_week_day = 'WED' THEN
    x_work_pattern_tbl(l_count).wednesday_hours := p_item_quantity;
  ELSIF l_week_day = 'THU' THEN
    x_work_pattern_tbl(l_count).thursday_hours := p_item_quantity;
  ELSIF l_week_day = 'FRI' THEN
    x_work_pattern_tbl(l_count).friday_hours := p_item_quantity;
  ELSIF l_week_day = 'SAT' THEN
    x_work_pattern_tbl(l_count).saturday_hours := p_item_quantity;
  ELSIF l_week_day = 'SUN' THEN
    x_work_pattern_tbl(l_count).sunday_hours := p_item_quantity;
  END IF;

PA_SCHEDULE_UTILS.debug('After insert_work_pattern_record: work_pattern = '||
 x_work_pattern_tbl(l_count).monday_hours||';'||
 x_work_pattern_tbl(l_count).tuesday_hours||';'||
 x_work_pattern_tbl(l_count).wednesday_hours||';'||
 x_work_pattern_tbl(l_count).thursday_hours||';'||
 x_work_pattern_tbl(l_count).friday_hours||';'||
 x_work_pattern_tbl(l_count).saturday_hours||';'||
 x_work_pattern_tbl(l_count).sunday_hours);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'insert_work_pattern_record');
    RAISE;

END insert_work_pattern_record;


PROCEDURE update_work_pattern_record(p_overcom_quantity     IN   NUMBER,
            p_count             IN   NUMBER,
            p_item_date         IN   DATE,
            x_work_pattern_tbl  IN OUT NOCOPY WorkPatternTabTyp,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895

IS
  l_week_day VARCHAR2(15);
  l_remove_quantity NUMBER;
  l_overcom_quantity NUMBER;
  l_count NUMBER;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF x_work_pattern_tbl.COUNT > 0 THEN

    l_week_day := TO_CHAR(p_item_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');
    l_overcom_quantity := p_overcom_quantity;
    l_remove_quantity := ROUND(p_overcom_quantity / p_count, 2);

    FOR j IN x_work_pattern_tbl.FIRST .. x_work_pattern_tbl.LAST LOOP

      IF l_week_day = 'MON' THEN
        IF (x_work_pattern_tbl(j).monday_hours - l_remove_quantity)>=0 THEN
          x_work_pattern_tbl(j).monday_hours := x_work_pattern_tbl(j).monday_hours - l_remove_quantity;
        ELSIF x_work_pattern_tbl(j).monday_hours > 0 THEN
          l_overcom_quantity := l_overcom_quantity - x_work_pattern_tbl(j).monday_hours;
          l_count := l_count -1;
          l_remove_quantity := ROUND(l_overcom_quantity/l_count, 2);
          x_work_pattern_tbl(j).monday_hours := 0;
        END IF;
      ELSIF l_week_day = 'TUE' THEN
        IF (x_work_pattern_tbl(j).tuesday_hours - l_remove_quantity)>=0 THEN
          x_work_pattern_tbl(j).tuesday_hours := x_work_pattern_tbl(j).tuesday_hours - l_remove_quantity;
        ELSIF x_work_pattern_tbl(j).tuesday_hours > 0 THEN
          l_overcom_quantity := l_overcom_quantity - x_work_pattern_tbl(j).tuesday_hours;
          l_count := l_count -1;
          l_remove_quantity := ROUND(l_overcom_quantity/l_count, 2);
          x_work_pattern_tbl(j).tuesday_hours :=0;
        END IF;
      ELSIF l_week_day = 'WED' THEN
        IF (x_work_pattern_tbl(j).wednesday_hours - l_remove_quantity)>=0 THEN
          x_work_pattern_tbl(j).wednesday_hours:= x_work_pattern_tbl(j).wednesday_hours - l_remove_quantity;
        ELSIF x_work_pattern_tbl(j).wednesday_hours > 0 THEN
          l_overcom_quantity := l_overcom_quantity - x_work_pattern_tbl(j).wednesday_hours;
          l_count := l_count -1;
          l_remove_quantity := ROUND(l_overcom_quantity/l_count, 2);
          x_work_pattern_tbl(j).wednesday_hours :=0;
        END IF;
      ELSIF l_week_day = 'THU' THEN
        IF (x_work_pattern_tbl(j).thursday_hours - l_remove_quantity)>=0 THEN
          x_work_pattern_tbl(j).thursday_hours:= x_work_pattern_tbl(j).thursday_hours - l_remove_quantity;
        ELSIF x_work_pattern_tbl(j).thursday_hours > 0 THEN
          l_overcom_quantity := l_overcom_quantity - x_work_pattern_tbl(j).thursday_hours;
          l_count := l_count -1;
          l_remove_quantity := ROUND(l_overcom_quantity/l_count, 2);
          x_work_pattern_tbl(j).thursday_hours:=0;
        END IF;
      ELSIF l_week_day = 'FRI' THEN
        IF (x_work_pattern_tbl(j).friday_hours - l_remove_quantity)>=0 THEN
          x_work_pattern_tbl(j).friday_hours:= x_work_pattern_tbl(j).friday_hours - l_remove_quantity;
        ELSIF x_work_pattern_tbl(j).friday_hours > 0 THEN
          l_overcom_quantity := l_overcom_quantity - x_work_pattern_tbl(j).friday_hours;
          l_count := l_count -1;
          l_remove_quantity := ROUND(l_overcom_quantity/l_count, 2);
          x_work_pattern_tbl(j).friday_hours :=0;
        END IF;
      ELSIF l_week_day = 'SAT' THEN
        IF (x_work_pattern_tbl(j).saturday_hours - l_remove_quantity)>=0 THEN
          x_work_pattern_tbl(j).saturday_hours:= x_work_pattern_tbl(j).saturday_hours - l_remove_quantity;
        ELSIF x_work_pattern_tbl(j).saturday_hours > 0 THEN
          l_overcom_quantity := l_overcom_quantity - x_work_pattern_tbl(j).saturday_hours;
          l_count := l_count -1;
          l_remove_quantity := ROUND(l_overcom_quantity/l_count, 2);
          x_work_pattern_tbl(j).saturday_hours:=0;
        END IF;
      ELSIF l_week_day = 'SUN' THEN
        IF(x_work_pattern_tbl(j).sunday_hours - l_remove_quantity)>=0 THEN
          x_work_pattern_tbl(j).sunday_hours:= x_work_pattern_tbl(j).sunday_hours - l_remove_quantity;
        ELSIF x_work_pattern_tbl(j).sunday_hours > 0 THEN
          l_overcom_quantity := l_overcom_quantity - x_work_pattern_tbl(j).sunday_hours;
          l_count := l_count -1;
          l_remove_quantity := ROUND(l_overcom_quantity/l_count, 2);
          x_work_pattern_tbl(j).sunday_hours:=0;
        END IF;
      END IF;

 PA_SCHEDULE_UTILS.debug('After update_work_pattern_record: work_pattern = '||
 x_work_pattern_tbl(j).monday_hours||';'||
 x_work_pattern_tbl(j).tuesday_hours||';'||
 x_work_pattern_tbl(j).wednesday_hours||';'||
 x_work_pattern_tbl(j).thursday_hours||';'||
 x_work_pattern_tbl(j).friday_hours||';'||
 x_work_pattern_tbl(j).saturday_hours||';'||
 x_work_pattern_tbl(j).sunday_hours);

    END LOOP;
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'insert_work_pattern_record');
    RAISE;

END update_work_pattern_record;


PROCEDURE insert_work_pattern_tab(p_cur_work_pattern_tbl  IN  WorkPatternTabTyp,
            x_work_pattern_tbl  IN OUT NOCOPY WorkPatternTabTyp,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_cur NUMBER;
  l_flag VARCHAR2(1);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  --l_flag := 'N';
  FOR j IN p_cur_work_pattern_tbl.FIRST .. p_cur_work_pattern_tbl.LAST LOOP

     l_flag := 'N';
     IF x_work_pattern_tbl.COUNT > 0 THEN

       -- Loop through the table from the end because we only want to compare
       -- the new work pattern record with previous week's work pattern record
       -- of the same assignment and see whether they share the same work
       -- pattern. If yes, we simply update the old record with a new end date.
       -- Otherwise, insert a new record.
       FOR i IN x_work_pattern_tbl.FIRST .. x_work_pattern_tbl.LAST LOOP
         IF x_work_pattern_tbl(i).assignment_id = p_cur_work_pattern_tbl(j).assignment_id AND x_work_pattern_tbl(i).end_date = p_cur_work_pattern_tbl(j).end_date - 7 THEN

         PA_SCHEDULE_UTILS.debug('Inside insert table: x_work_pattern_tbl(i).end_date = '|| x_work_pattern_tbl(i).end_date);

           IF (x_work_pattern_tbl(i).monday_hours = p_cur_work_pattern_tbl(j).monday_hours
           AND x_work_pattern_tbl(i).tuesday_hours = p_cur_work_pattern_tbl(j).tuesday_hours
           AND x_work_pattern_tbl(i).wednesday_hours = p_cur_work_pattern_tbl(j).wednesday_hours
           AND x_work_pattern_tbl(i).thursday_hours = p_cur_work_pattern_tbl(j).thursday_hours
           AND x_work_pattern_tbl(i).friday_hours = p_cur_work_pattern_tbl(j).friday_hours
           AND x_work_pattern_tbl(i).saturday_hours = p_cur_work_pattern_tbl(j).saturday_hours
           AND x_work_pattern_tbl(i).sunday_hours = p_cur_work_pattern_tbl(j).sunday_hours)
           THEN
             l_cur := i;
             l_flag := 'Y';
             EXIT;
           ELSE
             l_flag := 'N';
             EXIT;
           END IF;
         END IF;
       END LOOP;

       IF l_flag = 'Y' THEN
         x_work_pattern_tbl(l_cur).end_date := p_cur_work_pattern_tbl(j).end_date;
       ELSE
         l_cur := x_work_pattern_tbl.COUNT +1;
         x_work_pattern_tbl(l_cur).assignment_id := p_cur_work_pattern_tbl(j).assignment_id;
         x_work_pattern_tbl(l_cur).start_date := p_cur_work_pattern_tbl(j).start_date;
         x_work_pattern_tbl(l_cur).end_date := p_cur_work_pattern_tbl(j).end_date;
         x_work_pattern_tbl(l_cur).monday_hours := p_cur_work_pattern_tbl(j).monday_hours;
         x_work_pattern_tbl(l_cur).tuesday_hours := p_cur_work_pattern_tbl(j).tuesday_hours;
         x_work_pattern_tbl(l_cur).wednesday_hours := p_cur_work_pattern_tbl(j).wednesday_hours;
         x_work_pattern_tbl(l_cur).thursday_hours := p_cur_work_pattern_tbl(j).thursday_hours;
         x_work_pattern_tbl(l_cur).friday_hours := p_cur_work_pattern_tbl(j).friday_hours;
         x_work_pattern_tbl(l_cur).saturday_hours := p_cur_work_pattern_tbl(j).saturday_hours;
         x_work_pattern_tbl(l_cur).sunday_hours := p_cur_work_pattern_tbl(j).sunday_hours;
       END IF;

     -- When x_work_pattern_tbl is empty,insert the work pattern record.
     ELSE
       l_cur := x_work_pattern_tbl.COUNT +1;
       x_work_pattern_tbl(l_cur).assignment_id := p_cur_work_pattern_tbl(j).assignment_id;
       x_work_pattern_tbl(l_cur).start_date := p_cur_work_pattern_tbl(j).start_date;
       x_work_pattern_tbl(l_cur).end_date := p_cur_work_pattern_tbl(j).end_date;
       x_work_pattern_tbl(l_cur).monday_hours := p_cur_work_pattern_tbl(j).monday_hours;
       x_work_pattern_tbl(l_cur).tuesday_hours := p_cur_work_pattern_tbl(j).tuesday_hours;
       x_work_pattern_tbl(l_cur).wednesday_hours := p_cur_work_pattern_tbl(j).wednesday_hours;
       x_work_pattern_tbl(l_cur).thursday_hours := p_cur_work_pattern_tbl(j).thursday_hours;
       x_work_pattern_tbl(l_cur).friday_hours := p_cur_work_pattern_tbl(j).friday_hours;
       x_work_pattern_tbl(l_cur).saturday_hours := p_cur_work_pattern_tbl(j).saturday_hours;
       x_work_pattern_tbl(l_cur).sunday_hours := p_cur_work_pattern_tbl(j).sunday_hours;
     END IF;

  END LOOP;


  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'insert_work_pattern_tab');
    RAISE;

END insert_work_pattern_tab;


-- Procedure  : overcom_post_aprvl_processing
-- Purpose		: Completes post-processing for overcommitment module after
--              approval is complete.
PROCEDURE overcom_post_aprvl_processing(p_conflict_group_id  IN  NUMBER,
            p_fnd_user_name     IN   VARCHAR2,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  -- Retriev the source project info.

/* Commented this cursor for bug 3115273 and added new one below.
   Rremoved some columns and modified table from pa_projects_list_v to pa_projects_all,
   Also removed distinct and added rownum = 1

  CURSOR c1 IS
    SELECT DISTINCT asgn.project_id, proj.name, proj.segment1, proj.person_name, proj.carrying_out_organization_name, proj.customer_name
    FROM pa_project_assignments asgn, pa_assignment_conflict_hist hist, pa_project_lists_v proj
    WHERE asgn.assignment_id = hist.assignment_id
    AND hist.conflict_group_id = p_conflict_group_id
    AND asgn.project_id = proj.project_id;

End of comment for bug 3115273 */

/* Cursor added for bug 3115273 */

  CURSOR c1 IS
    SELECT asgn.project_id, proj.name, proj.segment1, proj.carrying_out_organization_id
    FROM pa_project_assignments asgn, pa_assignment_conflict_hist hist, pa_projects_all proj
    WHERE asgn.assignment_id = hist.assignment_id
    AND hist.conflict_group_id = p_conflict_group_id
    AND asgn.project_id = proj.project_id
    AND ROWNUM = 1;

  v_c1 c1%ROWTYPE;

  -- Retrieve conflict projects info.
  CURSOR c2 IS
    SELECT DISTINCT asgn.project_id, proj.name, proj.segment1
    FROM pa_project_assignments asgn, pa_assignment_conflict_hist hist, pa_projects_all proj
    WHERE asgn.assignment_id = hist.conflict_assignment_id
    AND hist.conflict_group_id = p_conflict_group_id
    AND asgn.project_id = proj.project_id
    AND hist.self_conflict_flag = 'N';

  v_c2 c2%ROWTYPE;

  -- Retrieve Self Conflicts info.
  CURSOR c3 IS
    SELECT assignment_id
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND self_conflict_flag = 'Y'
    AND resolve_conflicts_action_code = 'REMOVE_CONFLICTS';

  v_c3 c3%ROWTYPE;

/* Added cursor get_organization_name for bug 3115273 */

  CURSOR get_organization_name(c_organization_id number)is
  SELECT organ.name
  FROM
  hr_all_organization_units_tl organ
  WHERE
  organ.organization_id = c_organization_id AND
  organ.LANGUAGE = USERENV('LANG');

/* End of code added for bug 3115273 */

  l_item_type pa_wf_processes.item_type%TYPE;
  l_item_key pa_wf_processes.item_key%TYPE;
  l_source_proj_id NUMBER;
  l_source_proj_name pa_projects_all.name%TYPE;
  l_source_proj_number pa_projects_all.segment1%TYPE;
  l_source_proj_mgr_name per_all_people_f.full_name%type; /* Bug 3115273  pa_project_lists_v.person_name%TYPE; */
  l_source_proj_organization hr_all_organization_units_tl.name%type; /* Bug 3115273 pa_project_lists_v.carrying_out_organization_name%TYPE; */
  l_source_proj_customer pa_customers_v.customer_name%type;  /* Bug 3115273 pa_project_lists_v.customer_name%TYPE; */
  l_conflict_proj_id NUMBER;
  l_conflict_proj_mgr_id NUMBER;
  -- 3051479: Increased the size of the following two variables.
  l_conflict_mgr_user_name VARCHAR2(360);
  l_conflict_mgr_display_name VARCHAR2(360);
  -- End of 3051479
  l_view_conflicts_url VARCHAR2(600);

  l_err_code                   NUMBER := 0;
  l_err_stage                  VARCHAR2(2000);
  l_err_stack                  VARCHAR2(2000);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c1;
  FETCH c1 INTO v_c1;
  CLOSE c1;
  l_source_proj_id := v_c1.project_id;
  l_source_proj_name := v_c1.name;
  l_source_proj_number := v_c1.segment1;

/*  Commented for bug 3115273
  l_source_proj_mgr_name := v_c1.person_name;
  l_source_proj_organization := v_c1.carrying_out_organization_name;
  l_source_proj_customer := v_c1.customer_name;
*/

  /* Added for bug 3115273 */
  l_source_proj_mgr_name := PA_PROJECT_PARTIES_UTILS.GET_PROJECT_MANAGER_NAME(v_c1.project_id);

  OPEN get_organization_name(v_c1.carrying_out_organization_id);
  Fetch get_organization_name into l_source_proj_organization;
  CLOSE get_organization_name;

  l_source_proj_customer := PA_PROJECTS_MAINT_UTILS.GET_PRIMARY_CUSTOMER_NAME(v_c1.project_id);
  /* End of code added for bug 3115273 */

  l_item_type := 'PAROVCNT';

  -- Loop through the conflicting projects and send notifications depending on
  -- whether the conflicting project manager is present.
  FOR v_c2 in c2 LOOP

    SELECT PA_PRM_WF_ITEM_KEY_S.nextval
    INTO l_item_key
    FROM DUAL;

    l_conflict_proj_id := v_c2.project_id;
    l_conflict_proj_mgr_id := PA_PROJECTS_MAINT_UTILS.get_project_manager(v_c2.project_id);
    PA_SCHEDULE_UTILS.debug('l_conflict_proj_mgr_id = '||l_conflict_proj_mgr_id);
    -- Send notifications to conflicting project managers.
    IF l_conflict_proj_mgr_id IS NOT NULL THEN

      WF_DIRECTORY.getusername
   	  (p_orig_system    => 'PER',
       p_orig_system_id => l_conflict_proj_mgr_id,
     	 p_name           => l_conflict_mgr_user_name,
       p_display_name   => l_conflict_mgr_display_name);

      PA_SCHEDULE_UTILS.debug('l_conflict_mgr_user_name = '|| l_conflict_mgr_user_name);

      -- Create the WF process
      wf_engine.CreateProcess ( ItemType => l_item_type,
                                ItemKey  => l_item_key,
                                process  => 'PRO_PROJ_MGR_WARN');

      l_view_conflicts_url :=
        'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_VIEW_CONFLICTS_LAYOUT&paCallingPage=ProjMgrNotif&addBreadCrumb=RP'
          ||'&paConflictGroupId='||p_conflict_group_id
          ||'&paProjectId='||l_source_proj_id
          ||'&paConflictProjectId='||l_conflict_proj_id;

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_VIEW_CONFLICTS_URL_INFO',
                avalue   => l_view_conflicts_url
              );

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_NTF_RECEPIENT',
                avalue   => l_conflict_mgr_user_name
              );

      -- Now start the WF process
      wf_engine.StartProcess
             ( itemtype => l_item_type,
               itemkey  => l_item_key );

      -- Insert to PA tables wf process information.
      -- This is required for displaying notifications on PA pages.
      PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'OVERCOMMITMENT'
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(l_source_proj_id)
                ,p_entity_key2         => to_char(l_conflict_proj_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

    -- Send notifications to the submitter that conflicting project manager
    -- can not be informed.
    ELSE

      -- Create the WF process
      wf_engine.CreateProcess ( ItemType => l_item_type,
                                ItemKey  => l_item_key,
                                process  => 'PRO_PROJ_MGR_MISSING');

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_NAME',
                avalue   => l_source_proj_name
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_NUMBER',
                avalue   => l_source_proj_number
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_MANAGER',
                avalue   => l_source_proj_mgr_name
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_ORGANIZATION',
                avalue   => l_source_proj_organization
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_CUSTOMER',
                avalue   => l_source_proj_customer
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_CONFLICT_PROJ_NAME',
                avalue   => v_c2.name
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_CONFLICT_PROJ_NUMBER',
                avalue   => v_c2.segment1
              );

      l_view_conflicts_url :=
        'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_VIEW_CONFLICTS_LAYOUT&paCallingPage=NoProjMgrNotif&addBreadCrumb=RP'
          ||'&paConflictGroupId='||p_conflict_group_id
          ||'&paProjectId='||l_source_proj_id
          ||'&paConflictProjectId='||l_conflict_proj_id;

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_VIEW_CONFLICTS_URL_INFO',
                avalue   => l_view_conflicts_url
              );

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_NTF_RECEPIENT',
                avalue   => p_fnd_user_name
              );

      -- Now start the WF process
      wf_engine.StartProcess
             ( itemtype => l_item_type,
               itemkey  => l_item_key );

      -- Insert to PA tables wf process information.
      -- This is required for displaying notifications on PA pages.
      PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'OVERCOMMITMENT'
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(l_source_proj_id)
                ,p_entity_key2         => to_char(l_conflict_proj_id)
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

    END IF;
  END LOOP;

  -- Send Self Conflicts notifications.
  OPEN c3;
  FETCH c3 INTO v_c3;
    IF (c3%FOUND) THEN
      PA_SCHEDULE_UTILS.debug('Send self overcommitment notifications');
      -- Create the WF process
      SELECT PA_PRM_WF_ITEM_KEY_S.nextval
      INTO l_item_key
      FROM DUAL;
      wf_engine.CreateProcess ( ItemType => l_item_type,
                                ItemKey  => l_item_key,
                                process  => 'PRO_SELF_OVC_WARN');

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_NAME',
                avalue   => l_source_proj_name
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_NUMBER',
                avalue   => l_source_proj_number
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_MANAGER',
                avalue   => l_source_proj_mgr_name
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_ORGANIZATION',
                avalue   => l_source_proj_organization
              );
      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_PROJ_CUSTOMER',
                avalue   => l_source_proj_customer
              );

      l_view_conflicts_url :=
        'JSP:/OA_HTML/OA.jsp?akRegionApplicationId=275&akRegionCode=PA_VIEW_CONFLICTS_LAYOUT&paCallingPage=SelfConflictNotif&addBreadCrumb=RP'
         ||'&paConflictGroupId='||p_conflict_group_id
         ||'&paProjectId='||l_source_proj_id;

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_SELF_CONFLICTS_URL_INFO',
                avalue   => l_view_conflicts_url
              );

      wf_engine.SetItemAttrText
              ( itemtype => l_item_type,
                itemkey  => l_item_key,
                aname    => 'ATTR_NTF_RECEPIENT',
                avalue   => p_fnd_user_name
              );

      -- Now start the WF process
      wf_engine.StartProcess
             ( itemtype => l_item_type,
               itemkey  => l_item_key );

      -- Insert to PA tables wf process information.
      -- This is required for displaying notifications on PA pages.
      PA_WORKFLOW_UTILS.Insert_WF_Processes
                (p_wf_type_code        => 'OVERCOMMITMENT'
                ,p_item_type           => l_item_type
                ,p_item_key            => l_item_key
                ,p_entity_key1         => to_char(l_source_proj_id)
                ,p_entity_key2         => 'SELF_OVERCOMMITMENT'
                ,p_description         => NULL
                ,p_err_code            => l_err_code
                ,p_err_stage           => l_err_stage
                ,p_err_stack           => l_err_stack
                );

    END IF;
  CLOSE c3;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'overcom_post_aprvl_processing');
    RAISE;
END overcom_post_aprvl_processing;


-- Procedure  : will_resolve_conflicts_by_rmvl
-- Purpose		: Returns 'Y' if user has chosen to remove one or more
--              conflicts.
PROCEDURE will_resolve_conflicts_by_rmvl(p_conflict_group_id  IN  NUMBER,
            x_resolve_conflicts_by_rmvl  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  CURSOR c1 IS
    SELECT assignment_id
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND resolve_conflicts_action_code = 'REMOVE_CONFLICTS'
    AND self_conflict_flag = 'N'
    AND processed_flag = 'N';

  v_c1 c1%ROWTYPE;

BEGIN

  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    x_resolve_conflicts_by_rmvl := 'N';
  ELSE
    x_resolve_conflicts_by_rmvl := 'Y';
  END IF;
  CLOSE c1;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      --  4537865
	x_resolve_conflicts_by_rmvl := NULL ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'will_resolve_conflicts_by_rmvl');
    RAISE;
END will_resolve_conflicts_by_rmvl;


-- Procedure  : has_resolved_conflicts_by_rmvl
-- Purpose		: Returns 'Y' if remove conflicts has been sucessful.
PROCEDURE has_resolved_conflicts_by_rmvl(p_conflict_group_id  IN  NUMBER,
            p_assignment_id              IN   NUMBER,
            x_resolve_conflicts_by_rmvl  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
   CURSOR c1 IS
    SELECT processed_flag
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND assignment_id = p_assignment_id
    AND resolve_conflicts_action_code = 'REMOVE_CONFLICTS'
    AND self_conflict_flag = 'N'
    AND processed_flag = 'Y';

  v_c1 c1%ROWTYPE;
BEGIN

  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    x_resolve_conflicts_by_rmvl := 'N';
  ELSE
    x_resolve_conflicts_by_rmvl := 'Y';
  END IF;
  CLOSE c1;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      --  4537865
        x_resolve_conflicts_by_rmvl := NULL ;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'has_resolved_conflicts_by_rmvl');
    RAISE;
END has_resolved_conflicts_by_rmvl;


-- Procedure  : cancel_overcom_txn_items
-- Purpose		: Cancels transaction items marked with CANCEL_TXN_ITEM.
--              Updates processed_flag in the table once complete.
PROCEDURE cancel_overcom_txn_items (p_conflict_group_id  IN  NUMBER,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  -- 2167889: null instead of record_version_number
  CURSOR c1 IS
    SELECT DISTINCT conf.assignment_id, null record_version_number, asgn.assignment_type, asgn.start_date, asgn.end_date
    FROM pa_assignment_conflict_hist conf, pa_project_assignments asgn
    WHERE conf.conflict_group_id = p_conflict_group_id
    AND conf.assignment_id = asgn.assignment_id
    AND conf.resolve_conflicts_action_code = 'CANCEL_TXN_ITEM'
    AND conf.processed_flag = 'N';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  For v_c1 in c1 LOOP
    PA_ASSIGNMENT_APPROVAL_PUB.cancel_assignment(p_record_version_number =>v_c1.record_version_number,
      p_assignment_id     => v_c1.assignment_id,
      p_assignment_type   => v_c1.assignment_type,
      p_start_date        => v_c1.start_date,
      p_end_date          => v_c1.end_date,
      x_return_status     => x_return_status,
      x_msg_count         => x_msg_count,
      x_msg_data          => x_msg_data);

    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      PA_ASGN_CONFLICT_HIST_PKG.update_rows(p_conflict_group_id => p_conflict_group_id,
        p_assignment_id           => v_c1.assignment_id,
        p_processed_flag          => 'Y',
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data);
    END IF;
  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'cancel_overcom_txn_items');
    RAISE;
END cancel_overcom_txn_items;


-- Procedure  : revert_overcom_txn_items
-- Purpose		: Reverts transaction items marked with REVERT_TXN_ITEM.
--              Updates processed_flag in the table once complete.
PROCEDURE revert_overcom_txn_items (p_conflict_group_id  IN  NUMBER,
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

   CURSOR c1 IS
    SELECT DISTINCT assignment_id
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND resolve_conflicts_action_code = 'REVERT_TXN_ITEM'
    AND processed_flag = 'N';

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  FOR v_c1 IN c1 LOOP
  PA_SCHEDULE_UTILS.debug('Revert_Overcom_Txn_Items: v_c1.assignment_id = ' || v_c1.assignment_id);
    PA_ASSIGNMENT_APPROVAL_PUB.revert_to_last_approved(p_assignment_id => v_c1.assignment_id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);
    PA_SCHEDULE_UTILS.debug('Revert_Overcom_Txn_Items: After revert_to_last_approved');
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
      PA_ASGN_CONFLICT_HIST_PKG.update_rows(p_conflict_group_id => p_conflict_group_id,
        p_assignment_id           => v_c1.assignment_id,
        p_processed_flag          => 'Y',
        x_return_status           => x_return_status,
        x_msg_count               => x_msg_count,
        x_msg_data                => x_msg_data);
    END IF;
  END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'revert_overcom_txn_items');
    RAISE;
END revert_overcom_txn_items;


-- Procedure  : get_conflicting_asgmt_count
-- Purpose		: Returns number of assignments causing conflict including
--              self conflict.
PROCEDURE get_conflicting_asgmt_count (p_conflict_group_id  IN  NUMBER,
            x_assignment_count  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_return_status     OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count         OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data          OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

BEGIN

  SELECT COUNT(DISTINCT assignment_id)
  INTO x_assignment_count
  FROM pa_assignment_conflict_hist
  WHERE conflict_group_id = p_conflict_group_id;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OTHERS THEN
      --  4537865
	x_assignment_count := NULL ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'get_conflicting_asgmt_count');
    RAISE;
END get_conflicting_asgmt_count;


-- Procedure  : has_action_taken_on_conflicts
-- Purpose		: This is called from View Conflicts page when the notification
--              is sent to a mass txn submitter to choose action on assignment
--              conflicts. This must return 'Y' before the user can continue
--              the mass approval workflow.
PROCEDURE has_action_taken_on_conflicts (p_conflict_group_id  IN
NUMBER,
            x_action_taken         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status        OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data             OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  -- Cursor which retrieves the assignments on which action is not taken.
  CURSOR c1 IS
    SELECT assignment_id
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND resolve_conflicts_action_code = 'NOTIFY_IF_CONFLICT';

  v_c1 c1%ROWTYPE;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    x_action_taken := 'Y';
  ELSE
    x_action_taken := 'N';
  END IF;
  CLOSE c1;

  EXCEPTION
    WHEN OTHERS THEN
      --  4537865
      x_action_taken := NULL ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'has_action_taken_on_conflicts');
    RAISE;
END has_action_taken_on_conflicts;


-- Procedure  : check_asgmt_apprvl_working
-- Purpose    : Return 'Y' if the conflict group contains an assignment whose
--              apprvl_status_code is 'ASGMT_APPRVL_WORKING'. Otherwise, 'N'.
PROCEDURE check_asgmt_apprvl_working (p_conflict_group_id  IN
NUMBER,
            x_result               OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_return_status        OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
            x_msg_count            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
            x_msg_data             OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  CURSOR c1 IS
    SELECT hist.assignment_id
    FROM pa_assignment_conflict_hist hist, pa_project_assignments asgn
    WHERE hist.assignment_id = asgn.assignment_id
    AND hist.conflict_group_id = p_conflict_group_id
    AND asgn.apprvl_status_code = 'ASGMT_APPRVL_WORKING';

  v_c1 c1%ROWTYPE;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    x_result := 'N';
  ELSE
    x_result := 'Y';
  END IF;
  CLOSE c1;

  EXCEPTION
    WHEN OTHERS THEN
      -- 4537865
	x_result := NULL ;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count     := 1;
      x_msg_data      := SQLERRM;
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'check_asgmt_apprvl_working');
    RAISE;
END check_asgmt_apprvl_working;

-- This procedure will sum the task assignments given a schedule of working days and output a
-- new project schedule spanning from p_start_date to p_end_date
-- NOTE: The time span of the schedule of working days must include the time span of all of
-- the tasks falling into the p_start_date to p_end_date
-- Input parameters
-- Parameters                   Type           			Required  Description
-- P_Task_Assignments_Tbl      	TASKASSIGNMENTTABTYPE   YES       Table of Task Assignment IDs to be summed
-- P_Schedule_Tbl				SCHEDULETABTYP			YES		  Working Days Schedule
-- P_Start_Date                 DATE           			YES       Starting date of the schedule for that calendar
-- P_End_Date                 	DATE           			YES       Ending date of the schedule for that calendar
--
-- Out parameters
-- X_Schedule_Tbl            	SCHEDULETABTYP 			YES       Schedule representing the summation of all the tasks
--
--Bug 5126919: Added parameter x_total_hours which will contain the total hours for which the x_schedule_tbl
--will be prepared.
PROCEDURE sum_task_assignments (
	p_task_assignments_tbl	IN	SYSTEM.PA_NUM_TBL_TYPE	,
	p_schedule_tbl			IN	PA_SCHEDULE_GLOB.ScheduleTabTyp			,
	p_start_date			IN	DATE									,
	p_end_date				IN	DATE									,
	x_total_hours			OUT	NOCOPY  NUMBER                                  , -- Bug 5126919
	x_schedule_tbl			OUT	NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp			, --File.Sql.39 bug 4440895
	x_return_status			OUT	NOCOPY VARCHAR2								,		 --File.Sql.39 bug 4440895
	x_msg_count				OUT	NOCOPY NUMBER									, --File.Sql.39 bug 4440895
	x_msg_data				OUT	NOCOPY VARCHAR2					 --File.Sql.39 bug 4440895
)

IS
	TYPE SummationRecord IS RECORD (
		 schedule_date	 		DATE   	  		,
		 working_day			NUMBER	  		,
		 hours					NUMBER	  		,
		 day_of_week			PA_SCHEDULE_PVT.DayOfWeekType	,
		 calendar_id			NUMBER			,
		 assignment_id  		NUMBER			,
		 project_id				NUMBER			,
		 schedule_type_code		VARCHAR2(30)	,
		 assignment_status_code	VARCHAR2(30)	,
		 system_status_code		VARCHAR2(30)	,
		 change_type_code		VARCHAR2(30)	);

	TYPE SummationTableType IS TABLE OF SummationRecord INDEX BY BINARY_INTEGER;

	l_summation_tbl		  		  SummationTableType;
	l_schedule_index_first		  NUMBER;
	l_schedule_index_last		  NUMBER;
	l_schedule_start_date		  DATE;
	l_schedule_end_date		  	  DATE;
	l_schedule_row_start_date	  DATE;
	l_schedule_row_end_date		  DATE;

	l_current_date				  DATE;
	l_working_day				  NUMBER;
	l_hours						  NUMBER;
	l_found						  BOOLEAN;
	l_day_of_week				  PA_SCHEDULE_PVT.DayOfWeekType;

	l_summation_index_first		  NUMBER;
	l_summation_index_last		  NUMBER;

	l_task_assignment_id		  NUMBER;
	l_task_index_first			  NUMBER;
	l_task_index_last			  NUMBER;
	l_period_start_date			  DATE;
	l_period_end_date			  DATE;
	l_ta_planning_start_date	          DATE;
	l_ta_planning_end_date			  DATE;

	l_total_hours				  NUMBER;
	l_num_working_days			  NUMBER;
	l_hours_per_day				  NUMBER;
	l_next_day_schedule_hours	  NUMBER;

	counter						  NUMBER;
	summation_counter			  NUMBER;
	schedule_counter			  NUMBER;
	task_counter				  NUMBER;

	l_schedule_record			  PA_SCHEDULE_GLOB.ScheduleRecord;
	l_empty_schedule_record		  PA_SCHEDULE_GLOB.ScheduleRecord;
        l_debug_mode                      VARCHAR2(20) := 'N'; -- 4387388

	CURSOR C1 IS
		   SELECT a.start_date, a.end_date, NVL(a.quantity,0),
                          c.planning_start_date, c.planning_end_date -- 4367912
		   FROM pa_budget_lines a,
                        -- pa_projects_all b,  -- Bug 5086869
                        pa_resource_assignments c
		   WHERE a.resource_assignment_id = c.resource_assignment_id
		   AND c.resource_assignment_id = l_task_assignment_id;
                   -- Bug 5086869 - In WP, there is only one currency
                   -- so no need for currency join.
		   -- AND a.txn_currency_code = b.project_currency_code
		   -- AND b.project_id = c.project_id

BEGIN

 fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

-- Start of Debugging Statements
IF l_debug_mode = 'Y' THEN -- 4387388
   PA_SCHEDULE_UTILS.log_message(1, 'p_start_date: ' || p_start_date);
   PA_SCHEDULE_UTILS.log_message(1, 'p_end_date: ' || p_end_date);
   IF p_task_assignments_tbl IS NOT NULL THEN
      IF p_task_assignments_tbl.count > 0 THEN
   	     FOR i IN p_task_assignments_tbl.first .. p_task_assignments_tbl.last LOOP
	  	    PA_SCHEDULE_UTILS.log_message(1, 'p_task_assignments_tbl('||i||'): ' || p_task_assignments_tbl(i));
	     END LOOP;
      END IF;
   END IF;
   IF p_schedule_tbl IS NOT NULL THEN
      IF p_schedule_tbl.count > 0 THEN
	    FOR schedule_counter IN p_schedule_tbl.first .. p_schedule_tbl.last LOOP
	        PA_SCHEDULE_UTILS.log_message(1,
	 	                          p_schedule_tbl(schedule_counter).start_date || '|' ||
		 					      p_schedule_tbl(schedule_counter).end_date || '|' ||
		 				 	      round(p_schedule_tbl(schedule_counter).monday_hours,2) || '|' ||
							      round(p_schedule_tbl(schedule_counter).tuesday_hours,2) || '|' ||
							      round(p_schedule_tbl(schedule_counter).wednesday_hours,2) || '|' ||
							      round(p_schedule_tbl(schedule_counter).thursday_hours,2) || '|' ||
							      round(p_schedule_tbl(schedule_counter).friday_hours,2) || '|' ||
							      round(p_schedule_tbl(schedule_counter).saturday_hours,2) || '|' ||
		 				  	      round(p_schedule_tbl(schedule_counter).sunday_hours,2) || '|' ||
							      p_schedule_tbl(schedule_counter).calendar_id || '|' ||
							      p_schedule_tbl(schedule_counter).assignment_id || '|' ||
							      p_schedule_tbl(schedule_counter).project_id || '|' ||
							      p_schedule_tbl(schedule_counter).schedule_type_code || '|' ||
							      p_schedule_tbl(schedule_counter).assignment_status_code || '|' ||
							      p_schedule_tbl(schedule_counter).system_status_code || '|' ||
							      p_schedule_tbl(schedule_counter).change_type_code || '|');
	    END LOOP;
      END IF;
   END IF;
END IF; -- 4387388
-- End of Debugging Statements

     x_return_status := FND_API.G_RET_STS_SUCCESS;
	 -- Check for invalid dates in p_schedule_tbl
	 IF p_schedule_tbl.first IS NULL OR p_schedule_tbl.last IS NULL THEN
	 	l_schedule_start_date := p_start_date - 1;
		l_schedule_end_date := p_start_date - 2;
	 ELSE
	 	l_schedule_index_first := p_schedule_tbl.first;
	 	l_schedule_index_last := p_schedule_tbl.last;

		l_schedule_start_date := p_schedule_tbl(l_schedule_index_first).start_date;
	 	l_schedule_end_date := p_schedule_tbl(l_schedule_index_last).end_date;

		FOR schedule_counter IN l_schedule_index_first .. l_schedule_index_last LOOP
	 	   IF p_schedule_tbl(schedule_counter).start_date IS NULL OR
		   	  p_schedule_tbl(schedule_counter).end_date IS NULL THEN
		   	  l_schedule_start_date := p_start_date - 1;
		   	  l_schedule_end_date := p_start_date - 2;
		   END IF;
	   END LOOP;
	 END IF;

	 -- Initialize l_summation_tbl
	 summation_counter := 1;
	 l_current_date := l_schedule_start_date;
	 WHILE l_current_date <= l_schedule_end_date LOOP

	 	   l_day_of_week := get_day_of_week(p_date => l_current_date);
	 	   l_working_day := 0;
	 	   l_hours := 0;
		   l_found := FALSE;
	 	   FOR counter IN l_schedule_index_first .. l_schedule_index_last LOOP
		   	   l_schedule_row_start_date := p_schedule_tbl(counter).start_date;
			   l_schedule_row_end_date := p_schedule_tbl(counter).end_date;
		   	   IF l_current_date BETWEEN l_schedule_row_start_date AND l_schedule_row_end_date THEN
				  l_hours := get_hours_by_day_of_week( p_schedule_record => p_schedule_tbl(counter),
				  		  	 						   p_day_of_week => l_day_of_week);
				  IF l_hours > 0 THEN
				  	 l_working_day := 1;
				  END IF;
				  l_found := TRUE;
				  schedule_counter := counter;
				  EXIT;
			   END IF;
	 	   END LOOP;
		   IF l_found THEN
		   	  l_summation_tbl(summation_counter).schedule_date := l_current_date;
		   	  l_summation_tbl(summation_counter).working_day := l_working_day;
		   	  l_summation_tbl(summation_counter).hours := 0;
		   	  l_summation_tbl(summation_counter).day_of_week := l_day_of_week;
		   	  l_summation_tbl(summation_counter).calendar_id := p_schedule_tbl(schedule_counter).calendar_id;
		   	  l_summation_tbl(summation_counter).assignment_id := p_schedule_tbl(schedule_counter).assignment_id;
		   	  l_summation_tbl(summation_counter).project_id := p_schedule_tbl(schedule_counter).project_id;
		   	  l_summation_tbl(summation_counter).schedule_type_code := p_schedule_tbl(schedule_counter).schedule_type_code;
		   	  l_summation_tbl(summation_counter).assignment_status_code := p_schedule_tbl(schedule_counter).assignment_status_code;
		   	  l_summation_tbl(summation_counter).system_status_code := p_schedule_tbl(schedule_counter).system_status_code;
		   	  l_summation_tbl(summation_counter).change_type_code := p_schedule_tbl(schedule_counter).change_type_code;
		   ELSE
		      l_summation_tbl(summation_counter).schedule_date := NULL;
		   END IF;
	 	   l_current_date := l_current_date + 1;
	 	   summation_counter := summation_counter + 1;
	 END LOOP;

	 -- Fill in hours data
	 l_task_index_first := NVL(p_task_assignments_tbl.first,0);
	 l_task_index_last := NVL(p_task_assignments_tbl.last,-1);
	 l_summation_index_first := NVL(l_summation_tbl.first,0);
	 l_summation_index_last := NVL(l_summation_tbl.last,-1);

	 x_total_hours :=0;       -- Bug 5126919


	 FOR task_counter IN l_task_index_first .. l_task_index_last LOOP
	 	 l_task_assignment_id := p_task_assignments_tbl(task_counter);
	 	 OPEN C1;
	 	 LOOP
	 	 	 FETCH C1 INTO l_period_start_date, l_period_end_date, l_total_hours,
                                       l_ta_planning_start_date, l_ta_planning_end_date; -- 4367912
			 EXIT WHEN C1%NOTFOUND;

			 x_total_hours := x_total_hours + l_total_hours; -- Bug 5126919

                         -- 4367912: PJ.M:B15:P2:QA:STF:ASNMT THRU BOTOM UP APPROACH & TASK ASNMT SCH USES RES CALNDR
                         -- Make sure the dates used to calculate the number of working
                         -- dates should be within TA planning dates

			 -- Begin Bug:5872132:In order to calculate the number of working days acculately: we need to consider the
			 -- number of working days between Team Role Start Date(p_start_date) & Team Role End date(p_end_date)
			 -- instead of considering TA planning dates.
                         IF l_period_start_date < p_start_date THEN
                           l_period_start_date := p_start_date;
                         END IF;
                         IF l_period_end_date > p_end_date THEN
                           l_period_end_date := p_end_date;
                         END IF;
			 -- End Bug:5872132:

                         -- END OF 4367912

		 	 -- Determine the number of working days in the period
			 l_num_working_days := 0;
			 FOR summation_counter IN l_summation_index_first .. l_summation_index_last LOOP
			 	 IF l_summation_tbl(summation_counter).schedule_date BETWEEN l_period_start_date AND l_period_end_date THEN
				 	IF l_summation_tbl(summation_counter).working_day = 1 THEN
					   l_num_working_days := l_num_working_days + 1;
					END IF;
				 END IF;
			 END LOOP;

			 IF l_num_working_days = 0 THEN
			 	l_hours_per_day := 0;
			 ELSE
			 	l_hours_per_day := l_total_hours / l_num_working_days;
			 END IF;


/*
			 DBMS_OUTPUT.put_line( l_period_start_date || ' ' || l_period_end_date || ' ' ||
			 					   l_total_hours || ' ' || l_num_working_days || ' ' || round(l_hours_per_day,2));
*/
		 	 -- Loop through l_summation_tbl to update hours column
		 	 FOR summation_counter IN l_summation_index_first .. l_summation_index_last LOOP
				 IF l_summation_tbl(summation_counter).schedule_date BETWEEN l_period_start_date AND l_period_end_date THEN
				 	IF l_summation_tbl(summation_counter).working_day = 1 THEN
					   l_summation_tbl(summation_counter).hours := l_summation_tbl(summation_counter).hours + l_hours_per_day;
				 	END IF;
				 END IF;
			 END LOOP;
		END LOOP;
		CLOSE C1;
	 END LOOP;

	 -- Create x_schedule_tbl
	 IF (l_schedule_start_date <= p_start_date) AND (l_schedule_end_date >= p_end_date) THEN
	 	schedule_counter := 1;
	 	summation_counter := NVL(l_summation_tbl.first, 0);

	 	-- Set summation_counter to point to p_start_date
	  	WHILE l_summation_tbl(summation_counter).schedule_date < p_start_date LOOP
		   summation_counter := summation_counter + 1;
		END LOOP;

	 	l_current_date := p_start_date;
     	WHILE l_current_date <= p_end_date LOOP
		   IF l_summation_tbl(summation_counter).schedule_date IS NOT NULL THEN
		   	  set_hours_by_day_of_week( p_schedule_record => l_schedule_record,
		   							 	p_day_of_week => l_summation_tbl(summation_counter).day_of_week,
									 	p_hours => l_summation_tbl(summation_counter).hours );
		   	  IF l_schedule_record.start_date IS NULL THEN
			  	 -- Start New Record
		   	  	 l_schedule_record.start_date := l_current_date;
		   	  	 l_schedule_record.calendar_id := l_summation_tbl(summation_counter).calendar_id;
		   	  	 l_schedule_record.assignment_id := l_summation_tbl(summation_counter).assignment_id;
		   	  	 l_schedule_record.project_id := l_summation_tbl(summation_counter).project_id;
		   	  	 l_schedule_record.schedule_type_code := l_summation_tbl(summation_counter).schedule_type_code;
		   	  	 l_schedule_record.assignment_status_code := l_summation_tbl(summation_counter).assignment_status_code;
		   	  	 l_schedule_record.system_status_code := l_summation_tbl(summation_counter).system_status_code;
		   	  	 l_schedule_record.change_type_code := l_summation_tbl(summation_counter).change_type_code;
		      END IF;
		   	  IF (l_current_date = p_end_date) OR
			  	 (l_summation_tbl(summation_counter+1).schedule_date IS NULL) OR
			  	 (NVL(l_schedule_record.calendar_id,-100) 	   <> NVL(l_summation_tbl(summation_counter+1).calendar_id,-100)) OR
			  	 (NVL(l_schedule_record.assignment_id,-100) 	   <> NVL(l_summation_tbl(summation_counter+1).assignment_id,-100)) OR
		   	  	 (NVL(l_schedule_record.project_id,-100) 		   <> NVL(l_summation_tbl(summation_counter+1).project_id,-100)) OR
		   	  	 (NVL(l_schedule_record.schedule_type_code,'') 	   <> NVL(l_summation_tbl(summation_counter+1).schedule_type_code,'')) OR
		   	  	 (NVL(l_schedule_record.assignment_status_code,'') <> NVL(l_summation_tbl(summation_counter+1).assignment_status_code,'')) OR
		   	  	 (NVL(l_schedule_record.system_status_code,'') 	   <> NVL(l_summation_tbl(summation_counter+1).system_status_code,'')) OR
		   	  	 (NVL(l_schedule_record.change_type_code,'') 	   <> NVL(l_summation_tbl(summation_counter+1).change_type_code,'')) OR
			  	 (NVL( get_hours_by_day_of_week(p_schedule_record => l_schedule_record,p_day_of_week => l_summation_tbl(summation_counter+1).day_of_week) <>
				 	   l_summation_tbl(summation_counter+1).hours, FALSE)) THEN
			  	  -- Add Record to Table and Create a New One
			  	  l_schedule_record.end_date := l_current_date;
		   	  	  IF l_schedule_record.monday_hours IS NULL THEN
			  	  	 l_schedule_record.monday_hours := 0;
			      END IF;
			  	  IF l_schedule_record.tuesday_hours IS NULL THEN
			  	  	 l_schedule_record.tuesday_hours := 0;
			      END IF;
			      IF l_schedule_record.wednesday_hours IS NULL THEN
			  	  	 l_schedule_record.wednesday_hours := 0;
			      END IF;
			  	  IF l_schedule_record.thursday_hours IS NULL THEN
			  	   	 l_schedule_record.thursday_hours := 0;
			      END IF;
			  	  IF l_schedule_record.friday_hours IS NULL THEN
			  	  	 l_schedule_record.friday_hours := 0;
			  	  END IF;
			  	  IF l_schedule_record.saturday_hours IS NULL THEN
			  	  	 l_schedule_record.saturday_hours := 0;
			      END IF;
			  	  IF l_schedule_record.sunday_hours IS NULL THEN
			  	  	 l_schedule_record.sunday_hours := 0;
			      END IF;
		   	  	  x_schedule_tbl(schedule_counter) := l_schedule_record;
		   	  	  schedule_counter := schedule_counter + 1;
			  	  l_schedule_record := l_empty_schedule_record;
		      END IF;
		   END IF;
		   l_current_date := l_current_date + 1;
		   summation_counter := summation_counter + 1;
	    END LOOP;
     END IF;
/*
	 l_schedule_index_first := NVL(x_schedule_tbl.first,0);
	 l_schedule_index_last := NVL(x_schedule_tbl.last,-1);

	 DBMS_OUTPUT.put_line('COUNT: ' || x_schedule_tbl.count);

*/

IF l_debug_mode = 'Y' THEN -- 4387388
 IF x_schedule_tbl IS NOT NULL THEN
   IF x_schedule_tbl.count > 0 THEN
	 FOR schedule_counter IN x_schedule_tbl.first .. x_schedule_tbl.last LOOP
	     PA_SCHEDULE_UTILS.log_message(1,
	 	                       x_schedule_tbl(schedule_counter).start_date || '|' ||
		 					   x_schedule_tbl(schedule_counter).end_date || '|' ||
		 				 	   round(x_schedule_tbl(schedule_counter).monday_hours,2) || '|' ||
							   round(x_schedule_tbl(schedule_counter).tuesday_hours,2) || '|' ||
							   round(x_schedule_tbl(schedule_counter).wednesday_hours,2) || '|' ||
							   round(x_schedule_tbl(schedule_counter).thursday_hours,2) || '|' ||
							   round(x_schedule_tbl(schedule_counter).friday_hours,2) || '|' ||
							   round(x_schedule_tbl(schedule_counter).saturday_hours,2) || '|' ||
		 				  	   round(x_schedule_tbl(schedule_counter).sunday_hours,2) || '|' ||
							   x_schedule_tbl(schedule_counter).calendar_id || '|' ||
							   x_schedule_tbl(schedule_counter).assignment_id || '|' ||
							   x_schedule_tbl(schedule_counter).project_id || '|' ||
							   x_schedule_tbl(schedule_counter).schedule_type_code || '|' ||
							   x_schedule_tbl(schedule_counter).assignment_status_code || '|' ||
							   x_schedule_tbl(schedule_counter).system_status_code || '|' ||
							   x_schedule_tbl(schedule_counter).change_type_code || '|');
	 END LOOP;
   END IF;
 END IF;
END IF; -- 4387388

EXCEPTION
	WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := SQLERRM;
		 x_total_hours   := 0;       -- Bug 5126919
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
			 p_procedure_name   => 'sum_task_assignments');
		 raise;

END sum_task_assignments;

-- This procedure sets the number of hours in a given schedule record for a particular day of the week
-- Input parameters
-- Parameters                   Type           				   	 Required  Description
-- P_Schedule_Tbl				PA_SCHEDULE_GLOB.ScheduleRecord	 YES	   Schedule Record
-- P_Day_Of_Week                PA_SCHEDULE_PVT.DayOfWeekType   YES       Day of the week
-- P_Hours						NUMBER							 YES	   Hours for that day
--
-- Out parameters
--
PROCEDURE set_hours_by_day_of_week (
		 p_schedule_record		  IN OUT NOCOPY	  PA_SCHEDULE_GLOB.ScheduleRecord  ,
		 p_day_of_week			  IN	  		  PA_SCHEDULE_PVT.DayOfWeekType	   				   ,
		 p_hours				  IN	  		  NUMBER) IS
BEGIN
	 IF p_day_of_week = 'MON' THEN
	 	p_schedule_record.monday_hours := p_hours;
	 ELSIF p_day_of_week = 'TUE' THEN
	 	p_schedule_record.tuesday_hours := p_hours;
	 ELSIF p_day_of_week = 'WED' THEN
		p_schedule_record.wednesday_hours := p_hours;
	 ELSIF p_day_of_week = 'THU' THEN
		p_schedule_record.thursday_hours := p_hours;
	 ELSIF p_day_of_week = 'FRI' THEN
		p_schedule_record.friday_hours := p_hours;
	 ELSIF p_day_of_week = 'SAT' THEN
		p_schedule_record.saturday_hours := p_hours;
	 ELSIF p_day_of_week = 'SUN' THEN
		p_schedule_record.sunday_hours := p_hours;
	 END IF;
-- 4537865
EXCEPTION
	WHEN OTHERS THEN
	FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PVT',
				 p_procedure_name   => 'set_hours_by_day_of_week',
				 p_error_text       => SUBSTRB(SQLERRM,1,240));
	RAISE;
END set_hours_by_day_of_week;

-- Function		: Get_changed_item_name_text
-- Purpose		: Returns the changed item name display text for
--			  p_exception_type_code.
FUNCTION get_changed_item_name_text( p_exception_type_code IN VARCHAR2)
         RETURN VARCHAR2

IS
BEGIN
  return  PA_ASSIGNMENT_APPROVAL_PVT.get_lookup_meaning('PA_CHANGED_ITEMS', p_exception_type_code);
END get_changed_item_name_text;

-- Function		: Get_date_range_text
-- Purpose		: Returns the display text for the date range of the
--			  assignment.

FUNCTION Get_date_range_text ( p_start_date IN DATE,
                               p_end_date IN DATE) RETURN VARCHAR2
IS
  l_start_date VARCHAR2(80);
  l_end_date VARCHAR2(80);
  l_date_range_text VARCHAR2(240);
  l_date_format VARCHAR2(80);

BEGIN
  -- don't remove this, for some reason, icx_sec.getID doesn't work first time
  -- in the new session.
  l_date_format := icx_sec.getID(n_param =>icx_sec.PV_DATE_FORMAT);
  l_date_format := icx_sec.getID(n_param =>icx_sec.PV_DATE_FORMAT);

  IF p_start_date IS NOT null THEN
    l_start_date := to_char(p_start_date, l_date_format);
  ELSE
    l_start_date := ' ';
  END IF;

  IF p_end_date IS NOT NULL THEN
    l_end_date := to_char(p_end_date, l_date_format);
  ELSE
    l_end_date := ' ';
  END IF;

  IF ((p_start_date IS NOT NULL) OR (p_end_date IS NOT NULL)) THEN
   l_date_range_text := l_start_date||' - '||l_end_date;
  ELSE
   l_date_range_text := ' ';
  END IF;

  RETURN l_date_range_text;

END get_date_range_text;


--
-- Function		: Get_old_value_text
-- Purpose		: Returns the display text for the old schedule value
--			  of the assignment.
--
FUNCTION get_old_value_text (p_exception_type_code IN VARCHAR2,
                             p_assignment_id IN NUMBER,
                             p_start_date IN DATE,
                             p_end_date IN DATE) RETURN VARCHAR2
IS
  l_resource_calendar VARCHAR2(80);
  l_old_value_text VARCHAR2(240);
  l_current_value VARCHAR2(240);
  l_previous_value VARCHAR2(240);
  l_count NUMBER;
  l_multiple VARCHAR2(1);
  l_history_exist VARCHAR2(1);
  l_apprvl_status_code pa_project_assignments.apprvl_status_code%TYPE;

  CURSOR C1 IS
    SELECT calendar_id, calendar_type, start_date, end_date
    FROM   pa_assignments_history
    WHERE  assignment_id = p_assignment_id
    AND    last_approved_flag = 'Y';

  v_c1 C1%ROWTYPE;

  CURSOR C1_CURRENT IS
    SELECT calendar_id, calendar_type, start_date, end_date
    FROM   pa_project_assignments
    WHERE  assignment_id = p_assignment_id;

  v_c1_current C1_CURRENT%ROWTYPE;

  CURSOR C2 IS
    SELECT to_char(trunc(monday_hours,2)) mon_hours,
           to_char(trunc(tuesday_hours,2)) tue_hours,
           to_char(trunc(wednesday_hours,2)) wed_hours,
           to_char(trunc(thursday_hours,2)) thu_hours,
           to_char(trunc(friday_hours,2)) fri_hours,
           to_char(trunc(saturday_hours,2)) sat_hours,
           to_char(trunc(sunday_hours,2)) sun_hours,
           status_code,
           start_date,
           end_date
    FROM   pa_schedules_history
    WHERE  assignment_id = p_assignment_id
    AND    last_approved_flag = 'Y'
    AND    (    (start_date <= p_start_date AND end_date >= p_end_date)
            OR  (start_date >= p_start_date AND end_date <= p_end_date)
            OR  (start_date <= p_start_date AND p_start_date <= end_date)
            OR  (start_date <= p_end_date AND p_end_date <= end_date));

  v_c2 C2%ROWTYPE;

  CURSOR C2_CURRENT IS
    SELECT to_char(trunc(monday_hours,2)) mon_hours,
           to_char(trunc(tuesday_hours,2)) tue_hours,
           to_char(trunc(wednesday_hours,2)) wed_hours,
           to_char(trunc(thursday_hours,2)) thu_hours,
           to_char(trunc(friday_hours,2)) fri_hours,
           to_char(trunc(saturday_hours,2)) sat_hours,
           to_char(trunc(sunday_hours,2)) sun_hours,
           status_code,
           start_date,
           end_date
    FROM   pa_schedules
    WHERE  assignment_id = p_assignment_id
    AND    (    (start_date <= p_start_date AND end_date >= p_end_date)
            OR  (start_date >= p_start_date AND end_date <= p_end_date)
            OR  (start_date <= p_start_date AND p_start_date <= end_date)
            OR  (start_date <= p_end_date AND p_end_date <= end_date));

  v_c2_current C2_CURRENT%ROWTYPE;

  CURSOR get_apprvl_status_code IS
    SELECT apprvl_status_code
    FROM  pa_project_assignments
    WHERE assignment_id = p_assignment_id;

/* Added for bug 1524874*/
  TYPE change_hours_check_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   change_hours_check  change_hours_check_type;
   total_nonzero number;

   week_of_day  change_hours_check_type;

/* End bug 1524874*/

BEGIN
  -- initialize the return value
  l_old_value_text := null;

  OPEN C1;
  FETCH C1 INTO v_c1;
  IF C1%FOUND THEN
    l_history_exist := 'Y';
  ELSE
    l_history_exist := 'N';
  END IF;
  CLOSE C1;

  -- get approval status
  OPEN get_apprvl_status_code;
  FETCH get_apprvl_status_code INTO l_apprvl_status_code;
  CLOSE get_apprvl_status_code;

  ------------------------------------------------------------------
  -- CHANGE_DURATION OR SHIFT_DURATION
  ------------------------------------------------------------------
  IF p_exception_type_code = 'CHANGE_DURATION' OR p_exception_type_code = 'SHIFT_DURATION'  OR p_exception_type_code = 'DURATION_PATTERN_SHIFT'  THEN
    IF (l_history_exist = 'Y' AND l_apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_approved) THEN
       l_old_value_text := PA_SCHEDULE_PVT.get_date_range_text(v_c1.start_date, v_c1.end_date);
    ELSE
       OPEN C1_CURRENT;
       FETCH C1_CURRENT INTO v_c1_current;
       CLOSE C1_CURRENT;
       l_old_value_text := get_date_range_text(v_c1_current.start_date, v_c1_current.end_date);
    END IF;

  ------------------------------------------------------------------
  -- CHANGE_STATUS
  ------------------------------------------------------------------
  ELSIF p_exception_type_code = 'CHANGE_STATUS' THEN
    l_count := 0;
    l_multiple := 'F';

    IF (l_history_exist = 'Y' AND l_apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_approved) THEN
       FOR v_c2 IN C2 LOOP
         IF l_count = 0 THEN
            l_current_value := v_c2.status_code;
            SELECT project_status_name
            INTO l_old_value_text
            FROM pa_project_statuses
            WHERE project_status_code = v_c2.status_code;
         ELSE
            l_previous_value := l_current_value;
            l_current_value := v_c2.status_code;
            IF (l_previous_value <> l_current_value) THEN
               SELECT meaning
               INTO l_old_value_text
               FROM pa_lookups
               WHERE lookup_type = 'PA_SCH_UPDATE_TOP'
               AND lookup_code = 'PA_MULTIPLE';
               l_multiple := 'T';
            END IF;
          END IF;
          l_count := l_count + 1;
          EXIT WHEN l_multiple = 'T';
       END LOOP;
    ELSE
       FOR v_c2_current IN C2_CURRENT LOOP
         IF l_count = 0 THEN
            l_current_value := v_c2_current.status_code;
            SELECT project_status_name
            INTO l_old_value_text
            FROM pa_project_statuses
            WHERE project_status_code = v_c2_current.status_code;
         ELSE
            l_previous_value := l_current_value;
            l_current_value := v_c2_current.status_code;
            IF (l_previous_value <> l_current_value) THEN
               SELECT meaning
               INTO l_old_value_text
               FROM pa_lookups
               WHERE lookup_type = 'PA_SCH_UPDATE_TOP'
               AND lookup_code = 'PA_MULTIPLE';
               l_multiple := 'T';
            END IF;
          END IF;
          l_count := l_count + 1;
          EXIT WHEN l_multiple = 'T';
       END LOOP;
    END IF;

  ------------------------------------------------------------------
  -- CHANGE_WORK_PATTERN
  ------------------------------------------------------------------
  ELSIF p_exception_type_code = 'CHANGE_WORK_PATTERN' THEN
    l_count := 0;
    l_multiple := 'F';
    IF (l_history_exist = 'Y' AND l_apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_approved) THEN
       FOR v_c2 IN C2 LOOP
         IF l_count = 0 THEN
           l_current_value :=  v_c2.mon_hours||','||v_c2.tue_hours||','||v_c2.wed_hours||','||
                               v_c2.thu_hours||','||v_c2.fri_hours||','||v_c2.sat_hours||','|| v_c2.sun_hours;
           l_old_value_text := l_current_value;
         ELSE
           l_previous_value := l_current_value;
           l_current_value :=  v_c2.mon_hours||','||v_c2.tue_hours||','||v_c2.wed_hours||','||
                               v_c2.thu_hours||','||v_c2.fri_hours||','||v_c2.sat_hours||','||v_c2.sun_hours;
           IF (l_previous_value <> l_current_value) THEN
              SELECT meaning
              INTO l_old_value_text
              FROM pa_lookups
              WHERE lookup_type = 'PA_SCH_UPDATE_TOP'
              AND lookup_code = 'PA_MULTIPLE';
              l_multiple := 'T';
           END IF;
         END IF;
         l_count := l_count + 1;
         EXIT WHEN l_multiple = 'T';
       END LOOP;
    ELSE
       FOR v_c2_current IN C2_CURRENT LOOP
         IF l_count = 0 THEN
           l_current_value :=  v_c2_current.mon_hours||','||v_c2_current.tue_hours||','||v_c2_current.wed_hours||','||
                               v_c2_current.thu_hours||','||v_c2_current.fri_hours||','||v_c2_current.sat_hours||','||
                               v_c2_current.sun_hours;
           l_old_value_text := l_current_value;
         ELSE
           l_previous_value := l_current_value;
           l_current_value :=  v_c2_current.mon_hours||','||v_c2_current.tue_hours||','||v_c2_current.wed_hours||','||
                               v_c2_current.thu_hours||','||v_c2_current.fri_hours||','||v_c2_current.sat_hours||','||
                               v_c2_current.sun_hours;
           IF (l_previous_value <> l_current_value) THEN
              SELECT meaning
              INTO l_old_value_text
              FROM pa_lookups
              WHERE lookup_type = 'PA_SCH_UPDATE_TOP'
              AND lookup_code = 'PA_MULTIPLE';
              l_multiple := 'T';
           END IF;
         END IF;
         l_count := l_count + 1;
         EXIT WHEN l_multiple = 'T';
       END LOOP;
    END IF;
  ------------------------------------------------------------------
  -- CHANGE_HOURS
  ------------------------------------------------------------------
  ELSIF p_exception_type_code = 'CHANGE_HOURS' THEN
    IF ( p_end_date - p_start_date > 7) THEN
       SELECT meaning
       INTO l_old_value_text
       FROM pa_lookups
       WHERE lookup_type = 'PA_SCH_UPDATE_TOP'
       AND lookup_code = 'PA_MULTIPLE';

    ELSE
       total_nonzero :=0;

       FOR date_check IN 1..7 LOOP
	  week_of_day(date_check) :=0;
       END LOOP;

       FOR date_check IN 0..(nvl(p_end_date,p_start_date) - nvl(p_start_date,p_end_date)) LOOP
          week_of_day(to_number(to_char(nvl(p_start_date,p_end_date) + date_check,'D'))):=1;
       END LOOP;

       IF (l_history_exist = 'Y' AND l_apprvl_status_code <> PA_ASSIGNMENT_APPROVAL_PUB.g_approved) THEN
          FOR v_c2 IN C2 LOOP
    	   IF(week_of_day(2)=1)then
      	      change_hours_check(total_nonzero) := v_c2.mon_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(3)=1)then
      	      change_hours_check(total_nonzero):=v_c2.tue_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(4)=1)then
              change_hours_check(total_nonzero):=v_c2.wed_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(5)=1)then
      	      change_hours_check(total_nonzero):=v_c2.thu_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(6)=1)then
      	      change_hours_check(total_nonzero):=v_c2.fri_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(7)=1)then
      	      change_hours_check(total_nonzero):=v_c2.sat_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(1)=1)then
              change_hours_check(total_nonzero):=v_c2.sun_hours;
    	      total_nonzero:=total_nonzero+1;
       	   END IF;
          End LOOP;
       ELSE
          FOR v_c2_current IN C2_CURRENT LOOP
    	   IF(week_of_day(2)=1)then
      	      change_hours_check(total_nonzero) := v_c2_current.mon_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(3)=1)then
      	      change_hours_check(total_nonzero):=v_c2_current.tue_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(4)=1)then
              change_hours_check(total_nonzero):=v_c2_current.wed_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(5)=1)then
      	      change_hours_check(total_nonzero):=v_c2_current.thu_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(6)=1)then
      	      change_hours_check(total_nonzero):=v_c2_current.fri_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(7)=1)then
      	      change_hours_check(total_nonzero):=v_c2_current.sat_hours;
      	      total_nonzero:=total_nonzero+1;
    	   END IF;
    	   IF(week_of_day(1)=1)then
              change_hours_check(total_nonzero):=v_c2_current.sun_hours;
    	      total_nonzero:=total_nonzero+1;
       	   END IF;
          End LOOP;
       END IF;

       FOR i IN 1..total_nonzero-1 LOOP
         IF (change_hours_check(i) <>change_hours_check(0)) then
             SELECT meaning INTO l_old_value_text
             FROM   pa_lookups
             WHERE  lookup_type = 'PA_SCH_UPDATE_TOP'
             AND  lookup_code = 'PA_MULTIPLE';
             EXIT;
         END IF;
       END LOOP;

       IF (l_old_value_text IS NULL) THEN
         If(change_hours_check.EXISTS(0)) THEN
            l_old_value_text := change_hours_check(0);
         ELSE
	    l_old_value_text := ' ';
         END IF;
       END IF;

    END IF; -- end of change hours

  ELSE
    l_old_value_text := ' ';
  END IF;

  RETURN l_old_value_text;

  EXCEPTION
    WHEN OTHERS THEN
      return null;
END get_old_value_text;


--
-- Function  : Get_new_value_text
-- Purpose   : Returns the display text for the new schedule value of the assignment.
--
FUNCTION Get_new_value_text (p_exception_type_code            IN VARCHAR2,
                             p_new_calendar_id                IN NUMBER,
                             p_new_start_date                 IN DATE,
                             p_new_end_date                   IN DATE,
			     p_new_status_code                IN VARCHAR2,
                             p_new_change_calendar_id         IN NUMBER,
                             p_new_monday_hours               IN NUMBER,
                             p_new_tuesday_hours              IN NUMBER,
                             p_new_wednesday_hours            IN NUMBER,
                             p_new_thursday_hours             IN NUMBER,
                             p_new_friday_hours               IN NUMBER,
                             p_new_saturday_hours             IN NUMBER,
                             p_new_sunday_hours               IN NUMBER,
                             p_new_change_hours_type_code     IN VARCHAR2,
                             p_new_non_working_day_flag       IN VARCHAR2,
                             p_new_hours_per_day              IN NUMBER,
                             p_new_calendar_percent           IN NUMBER,
                             p_new_change_cal_type_code       IN VARCHAR2 := null,
                             p_new_change_calendar_name       IN VARCHAR2 := null)
RETURN VARCHAR2
IS
  l_new_value_text VARCHAR2(240);
  l_new_calendar_name VARCHAR2(80);
  l_non_working_day_flag VARCHAR2(240);

BEGIN
  l_new_value_text := '';

  --------------------------------------------------------------
  -- p_exception_type_code = 'CHANGE_DURATION'/ 'SHIFT_DURATION'
  --------------------------------------------------------------
  IF p_exception_type_code = 'CHANGE_DURATION' OR p_exception_type_code = 'SHIFT_DURATION'  OR p_exception_type_code = 'DURATION_PATTERN_SHIFT'  THEN
    l_new_value_text := PA_SCHEDULE_PVT.get_date_range_text(p_new_start_date, p_new_end_date);

  --------------------------------------------------
  -- p_exception_type_code = 'CHANGE_STATUS'
  --------------------------------------------------
  ELSIF p_exception_type_code = 'CHANGE_STATUS' THEN
    SELECT project_status_name
    INTO   l_new_value_text
    FROM   pa_project_statuses
    WHERE  project_status_code = p_new_status_code;

  --------------------------------------------------
  -- p_exception_type_code = 'CHANGE_WORK_PATTERN'
  --------------------------------------------------
  ELSIF p_exception_type_code = 'CHANGE_WORK_PATTERN' THEN
    l_new_value_text := to_char(trunc(p_new_monday_hours,2)) ||','||
                        to_char(trunc(p_new_tuesday_hours,2)) ||','||
                        to_char(trunc(p_new_wednesday_hours,2)) ||','||
                        to_char(trunc(p_new_thursday_hours,2)) ||','||
                        to_char(trunc(p_new_friday_hours,2)) ||','||
                        to_char(trunc(p_new_saturday_hours,2)) ||','||
                        to_char(trunc(p_new_sunday_hours,2));

  --------------------------------------------------
  -- p_exception_type_code = 'CHANGE_HOURS'
  --------------------------------------------------
  ELSIF p_exception_type_code = 'CHANGE_HOURS' THEN
    IF p_new_non_working_day_flag = 'Y' THEN
       l_non_working_day_flag := get_ak_attribute_label('PA_SCH_UPDATE_TOP','PA_INCLUDE_NON_WORKING');
    END IF;

    --
    -- If Percetage has been selected
    --
    IF p_new_change_hours_type_code = 'PERCENTAGE' THEN
      IF p_new_change_cal_type_code = 'RESOURCE' THEN
        l_new_calendar_name := get_ak_attribute_label('PA_SCH_UPDATE_TOP','PA_RESOURCE_CALENDAR');
      ELSIF  p_new_change_cal_type_code = 'PROJECT' THEN
        SELECT calendar_name
        INTO   l_new_calendar_name
        FROM   jtf_calendars_vl
        WHERE  calendar_id = p_new_calendar_id;
      -- if Other calendar has been selected
      ELSE
        IF (p_new_change_calendar_name IS NOT NULL) THEN
           l_new_calendar_name := p_new_change_calendar_name;
        ELSE
           SELECT calendar_name
           INTO   l_new_calendar_name
           FROM   jtf_calendars_vl
           WHERE  calendar_id = p_new_change_calendar_id;
        END IF;
      END IF;

      IF l_non_working_day_flag IS NOT NULL THEN
        l_new_value_text := to_char(trunc(p_new_calendar_percent,2))||'%'||
                            ' - '|| l_new_calendar_name||' - '|| l_non_working_day_flag;
      ELSE
        l_new_value_text := to_char(trunc(p_new_calendar_percent,2))||'%'|| ' - '|| l_new_calendar_name;
      END IF;

    --
    -- If 'Hours per day' has been selected
    --
    ELSE
      IF l_non_working_day_flag IS NOT NULL THEN
        l_new_value_text := to_char(trunc(p_new_hours_per_day,2))||' - '||l_non_working_day_flag;
      ELSE
        l_new_value_text := to_char(trunc(p_new_hours_per_day,2));
      END IF;
    END IF;

  END IF; -- ELSIF p_exception_type_code = 'CHANGE_HOURS'

  RETURN l_new_value_text;

END get_new_value_text;


-- Function		: get_num_days_of_conflict
-- Purpose		: Return number of days in assignment that are in conflict with
--              existing confirmed assignments, and potentially in conflict
--              with other assignments in transaction including itself.
FUNCTION get_num_days_of_conflict (p_assignment_id IN NUMBER,
                 p_resource_id   IN NUMBER,
                 p_conflict_group_id IN NUMBER) RETURN NUMBER
IS

  G_AVAILABILITY_CAL_PERIOD VARCHAR2(15) := FND_PROFILE.VALUE('PA_AVAILABILITY_CAL_PERIOD');
  G_OVERCOMMITMENT_PERCENTAGE NUMBER := FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_OVERCOMMITMENT_PERCENTAGE'))/100;

  l_count NUMBER := 0;
  l_start_date DATE;
  l_end_date DATE;

BEGIN

  SELECT start_date, end_date
  INTO l_start_date, l_end_date
  FROM pa_project_assignments
  WHERE assignment_id = p_assignment_id;

  IF (G_AVAILABILITY_CAL_PERIOD = 'DAILY' OR G_AVAILABILITY_CAL_PERIOD = 'WEEKLY') THEN
     SELECT COUNT(*)
     INTO l_count
     FROM (
 select DISTINCT fi.item_date
 from pa_forecast_items fi,
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
)FI_ASSIGNED,
(select capacity_quantity,
 item_date,
 delete_flag,
 resource_id
 from pa_forecast_items
 where forecast_item_type = 'U'
 )fi_capacity
where fi.resource_id = p_resource_id
and fi.resource_id = fi_capacity.resource_id
and fi_capacity.resource_id = fi_assigned.resource_id
and fi.assignment_id = p_assignment_id
and fi.item_date BETWEEN l_start_date and l_end_date
and fi.item_date = fi_capacity.item_date
and fi_capacity.item_date = fi_assigned.item_date
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.assigned_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.assigned_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi.delete_flag = 'N'
and fi.delete_flag = fi_capacity.delete_flag
and fi_capacity.delete_flag = fi_assigned.delete_flag
and fi.forecast_item_type = 'A'
);

/* Commented out the weekly version due to performance problem and this change is
   approved by functional team.
  ELSIF G_AVAILABILITY_CAL_PERIOD = 'WEEKLY' THEN
   SELECT COUNT(*)
   INTO l_count
   FROM (
select DISTINCT
fi.item_date
from pa_forecast_items fi,
(select
resource_id,
sum(item_quantity) total_assigned_quantity,
GLOBAL_EXP_PERIOD_END_DATE week_end_date,
delete_flag,
forecast_item_type
from pa_forecast_items fi1, pa_schedules sch, pa_project_statuses a, pa_project_statuses b
where (fi1.assignment_id = p_assignment_id
      or fi1.assignment_id in (select conflict_assignment_id
                         from pa_assignment_conflict_hist
                         where conflict_group_id = p_conflict_group_id
                         and assignment_id = p_assignment_id
                         and self_conflict_flag = 'N'))
and fi1.assignment_id = sch.assignment_id
and item_date BETWEEN l_start_date AND l_end_date
and item_date between sch.start_date and sch.end_date
and sch.status_code = a.project_status_code
and a.wf_success_status_code = b.project_status_code
and b.project_system_status_code = 'STAFFED_ASGMT_CONF'
group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, forecast_item_type, delete_flag
)fi_assigned,
(select resource_id,
 sum(capacity_quantity) capacity_quantity,
 GLOBAL_EXP_PERIOD_END_DATE week_end_date,
 delete_flag
 from pa_forecast_items
 where forecast_item_type = 'U'
 group by resource_id, GLOBAL_EXP_PERIOD_END_DATE, delete_flag
 )fi_capacity
where fi.resource_id = p_resource_id
and fi.resource_id = fi_capacity.resource_id
and fi_capacity.resource_id = fi_assigned.resource_id
and fi.item_date BETWEEN l_start_date AND l_end_date
and fi.GLOBAL_EXP_PERIOD_END_DATE = fi_capacity.week_end_date
and fi_capacity.week_end_date = fi_assigned.week_end_date
and ((fi_capacity.capacity_quantity*(1+G_OVERCOMMITMENT_PERCENTAGE) - fi_assigned.total_assigned_quantity <= 0 and G_OVERCOMMITMENT_PERCENTAGE > 0)
     or (fi_capacity.capacity_quantity - fi_assigned.total_assigned_quantity < 0 and G_OVERCOMMITMENT_PERCENTAGE = 0))
and fi.delete_flag = 'N'
and fi.delete_flag = fi_capacity.delete_flag
and fi_capacity.delete_flag = fi_assigned.delete_flag
and fi.forecast_item_type = 'A'
and fi.forecast_item_type = fi_assigned.forecast_item_type
and fi.assignment_id = p_assignment_id
);

*/
	END IF;

  RETURN (l_count);

  EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'get_num_days_of_conflict');
    RAISE;
END get_num_days_of_conflict;


-- Function		: column_val_conflict_exists
-- Purpose		: Returns lookup code for value to display in 'Conflict Exists'
--              column ('Yes', 'No')
FUNCTION column_val_conflict_exists (p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER ) RETURN VARCHAR2
IS

  CURSOR c1 IS
    SELECT conflict_group_id, assignment_id
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND assignment_id = p_assignment_id;
--    AND processed_flag = 'N';

  v_c1 c1%ROWTYPE;
  l_result VARCHAR2(80);

BEGIN

  OPEN c1;
  FETCH c1 INTO v_c1;

  IF c1%NOTFOUND THEN
    SELECT meaning
    INTO l_result
    FROM pa_lookups
    WHERE lookup_type = 'CONFLICT_EXISTS'
    AND lookup_code = 'NO';
    RETURN(l_result);
  ELSE
    SELECT meaning
    INTO l_result
    FROM pa_lookups
    WHERE lookup_type = 'CONFLICT_EXISTS'
    AND lookup_code = 'YES';
    RETURN(l_result);
  END IF;

  CLOSE c1;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'column_val_conflict_exists');
    RAISE;
END column_val_conflict_exists;


-- Function		: column_val_conflict_action
-- Purpose		: Returns value to display in 'Action on Approval' column
--              ('Remove Conflicts', Continue with Conflicts', ''). A
--              self-conflict would imply 'Continue with Conflicts'. No value
--              would be shown for those assignments not causing
--              overcommitment.
FUNCTION column_val_conflict_action (p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER ) RETURN VARCHAR2
IS

  l_action_code VARCHAR2(30);

  CURSOR c1 IS
     SELECT resolve_conflicts_action_code
     FROM pa_assignment_conflict_hist
     WHERE conflict_group_id = p_conflict_group_id
     AND assignment_id = p_assignment_id;

  v_c1 c1%ROWTYPE;
  l_result VARCHAR2(80);

BEGIN
  OPEN c1;
  FETCH c1 INTO v_c1;

  IF c1%NOTFOUND THEN
    RETURN (NULL);
  ELSE
    SELECT meaning
    INTO l_result
    FROM pa_lookups
    WHERE lookup_type = 'RESOLVE_CONFLICTS_ACTION_CODE'
    AND lookup_code = v_c1.resolve_conflicts_action_code;
    RETURN (l_result);
  END IF;

  close c1;

  EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'column_val_conflict_action');
    RAISE;
END column_val_conflict_action;


-- Function		: check_conflict_proj_affected
-- Purpose		: Returns a value to the View Conflicts page to filter for
--              the assignments that are in conflict with the assignments in
--              a particular conflicting project.
FUNCTION check_conflict_proj_affected (p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER,
                             p_conflict_project_id IN NUMBER) RETURN VARCHAR2

IS

  l_affected VARCHAR2(1) := 'N';
  CURSOR c1 IS
    SELECT DISTINCT asgn.project_id
    FROM pa_project_assignments asgn, pa_assignment_conflict_hist hist
    WHERE asgn.assignment_id = hist.conflict_assignment_id
    AND hist.conflict_group_id = p_conflict_group_id
    AND hist.assignment_id = p_assignment_id;

BEGIN

  FOR v_c1 IN c1 LOOP
    IF v_c1.project_id = p_conflict_project_id THEN
      l_affected := 'Y';
      EXIT;
    END IF;
  END LOOP;

  RETURN (l_affected);

  EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'check_conflict_proj_affected');
    RAISE;
END check_conflict_proj_affected;


-- Function		: check_self_conflict_exist
-- Purpose		: Returns a value to the View Conflicts page to filter for
--              the assignments with self_conflict_flag = 'Y' and being chosen to
--              remove conflicts.
FUNCTION check_self_conflict_exist (p_conflict_group_id IN NUMBER,
                             p_assignment_id IN NUMBER) RETURN VARCHAR2
IS
  l_result VARCHAR2(1);

  CURSOR c1 IS
  SELECT self_conflict_flag
    FROM pa_assignment_conflict_hist
    WHERE conflict_group_id = p_conflict_group_id
    AND assignment_id = p_assignment_id
    AND self_conflict_flag = 'Y'
    AND resolve_conflicts_action_code = 'REMOVE_CONFLICTS';

  v_c1 c1%ROWTYPE;
BEGIN

  OPEN c1;
  FETCH c1 INTO v_c1;
  IF c1%NOTFOUND THEN
    l_result := 'N';
  ELSE
    l_result := 'Y';
  END IF;
  CLOSE c1;

  RETURN (l_result);

  EXCEPTION
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'check_self_conflict_exist');
    RAISE;
END check_self_conflict_exist;


--
-- Returns ak attribute label corresponding p_region_code, p_attribute_code
--
FUNCTION get_ak_attribute_label (p_region_code    IN VARCHAR2,
                                 p_attribute_code IN VARCHAR2)
RETURN VARCHAR2
IS
  l_attribute_label  VARCHAR2(30);
BEGIN
  SELECT meaning
  INTO l_attribute_label
  FROM pa_lookups
  WHERE lookup_type = p_region_code
  AND lookup_code = p_attribute_code;

  RETURN l_attribute_label;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN null;
    WHEN OTHERS THEN
      FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PVT',
                               p_procedure_name => 'get_ak_attribute_label');
      RAISE;
END get_ak_attribute_label;

-- This function determines the day of the week given a particular date
-- Input parameters
-- Parameters	   Type				   	   			Required  Description
-- P_Date     	   DATE								YES       Date
--
-- Out parameters
--             	   PA_SCHEDULE_PVT.DayOfWeekType 	YES       Day of the week (3 character abbreviation)
--
FUNCTION get_day_of_week (p_date IN DATE) RETURN PA_SCHEDULE_PVT.DayOfWeekType IS
BEGIN
	 -- RETURN to_char(p_date,'DY');        -- Changed for Bug 5364632
	 RETURN to_char(p_date,'DY','NLS_DATE_LANGUAGE = AMERICAN');
END get_day_of_week;


-- This function returns the number of hours in a given schedule record for a particular day of the week
-- Input parameters
-- Parameters                   Type           					 Required  Description
-- P_Schedule_Record			PA_SCHEDULE_GLOB.ScheduleRecord	 YES	   Schedule Record
-- P_Day_Of_Week                PA_SCHEDULE_PVT.DayOfWeekType   YES       Day of the week
--
-- Out parameters
--             					NUMBER 							 YES       Number of hours schedule on that day
--
FUNCTION get_hours_by_day_of_week (
		 p_schedule_record		IN	  PA_SCHEDULE_GLOB.ScheduleRecord	   ,
		 p_day_of_week			IN	  PA_SCHEDULE_PVT.DayOfWeekType )
		 RETURN NUMBER IS
l_hours	 NUMBER := 0;
BEGIN
	 IF p_day_of_week = 'MON' THEN
	 	l_hours := p_schedule_record.monday_hours;
	 ELSIF p_day_of_week = 'TUE' THEN
	 	l_hours := p_schedule_record.tuesday_hours;
	 ELSIF p_day_of_week = 'WED' THEN
		l_hours := p_schedule_record.wednesday_hours;
	 ELSIF p_day_of_week = 'THU' THEN
		l_hours := p_schedule_record.thursday_hours;
	 ELSIF p_day_of_week = 'FRI' THEN
		l_hours := p_schedule_record.friday_hours;
	 ELSIF p_day_of_week = 'SAT' THEN
		l_hours := p_schedule_record.saturday_hours;
	 ELSIF p_day_of_week = 'SUN' THEN
		l_hours := p_schedule_record.sunday_hours;
	 END IF;
	 RETURN l_hours;
END get_hours_by_day_of_week;

END PA_SCHEDULE_PVT;

/
