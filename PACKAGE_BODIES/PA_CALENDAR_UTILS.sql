--------------------------------------------------------
--  DDL for Package Body PA_CALENDAR_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CALENDAR_UTILS" as
/* $Header: PARGCALB.pls 120.5 2005/12/20 22:39:47 vkadimes ship $  */

l_empty_tab_record       EXCEPTION; --  Variable to raise the exception if
                                    -- the passing table of records is empty

-- This  procedure gets the calendar shift on the basis of the calendar id and  store its work
-- pattern in the calendar type table of records.
-- Input parameters
-- Parameters                   Type             Required  Description
-- P_Calendar_Id                NUMBER           YES       Id for that calendar to which you want to have schedule
-- Out parameters
-- X_Cal_Record_Tab             CALENDARTABTYP   YES       It stores shift assign to the calendar
--

/* Added nocopy for this variable for bug#2674619 */

PROCEDURE get_calendar_shifts ( p_calendar_id            IN   NUMBER,
                                x_cal_record_tab         OUT  NOCOPY PA_SCHEDULE_GLOB.CalendarTabTyp,                                x_return_status          OUT  VARCHAR2,
                                x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
         l_t_shift_id   JTF_CAL_SHIFT_ASSIGN.shift_id%TYPE;-- assigning the variable to store the shift id
                                                            -- for getting the shifts
         l_I            NUMBER;

-- This cursor will select the shifts assign to the calendar and the effective period
   CURSOR C1 IS SELECT shift_sequence_number,shift_id,(shift_end_date - shift_start_date ) duration
                FROM JTF_CAL_SHIFT_ASSIGN
                WHERE calendar_id = p_calendar_id;

-- This cursor will select the work patern of the assigning shift to the calendar
   -- Bug 2181241: Modified the rounding to be two decimals.
   CURSOR C2 IS SELECT unit_of_time_value,round(SUM(end_time - begin_time)*24, 2) day_hours
                FROM JTF_CAL_SHIFT_CONSTRUCTS
                WHERE shift_id = l_t_shift_id
                GROUP BY unit_of_time_value;

BEGIN
    l_I := 1;
    -- Storing the status for error handling
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Setup the cursor fetch loop
    FOR v_c1 IN C1 LOOP
      x_cal_record_tab(l_I).seq_num          := v_c1.shift_sequence_number;
      x_cal_record_tab(l_I).duration         := v_c1.duration;
      l_t_shift_id                           := v_c1.shift_id;

      -- Inilizing the calendar record with zero
      x_cal_record_tab(l_I).Monday_hours     := 0.00;
      x_cal_record_tab(l_I).Tuesday_hours    := 0.00;
      x_cal_record_tab(l_I).Wednesday_hours  := 0.00;
      x_cal_record_tab(l_I).Thursday_hours   := 0.00;
      x_cal_record_tab(l_I).Friday_hours     := 0.00;
      x_cal_record_tab(l_I).Saturday_hours   := 0.00;
      x_cal_record_tab(l_I).Sunday_hours     := 0.00;

      -- Setup the cursor fetch loop
      FOR v_c2 IN C2 LOOP
        -- if the time is monday ,tuesday,wednaesday,thursday,friday,saturday and sunday then store its no of hours
        IF (v_c2.unit_of_time_value        = '2') THEN
          x_cal_record_tab(l_I).Monday_hours :=v_c2.day_hours;
        ELSIF (v_c2.unit_of_time_value    = '3' ) THEN
          x_cal_record_tab(l_I).Tuesday_hours := v_c2.day_hours;
        ELSIF (v_c2.unit_of_time_value  = '4' ) THEN
          x_cal_record_tab(l_I).Wednesday_hours :=v_c2.day_hours;
        ELSIF (v_c2.unit_of_time_value = '5' ) THEN
          x_cal_record_tab(l_I).Thursday_hours := v_c2.day_hours;
        ELSIF (v_c2.unit_of_time_value     = '6' ) THEN
          x_cal_record_tab(l_I).Friday_hours := v_c2.day_hours;
        ELSIF (v_c2.unit_of_time_value   ='7' ) THEN
          x_cal_record_tab(l_I).Saturday_hours := v_c2.day_hours;
        ELSIF (v_c2.unit_of_time_value     = '1' ) THEN
          x_cal_record_tab(l_I).Sunday_hours := v_c2.day_hours;
        END IF;
      END LOOP;

      l_I := l_I + 1;
    END LOOP;

    -- if the cursor does not have any records i.e. no shift is assign to
    -- the calendar then default work pattern is created
    IF (x_cal_record_tab.count = 0 ) THEN
      x_cal_record_tab(1).seq_num          := 1;
      x_cal_record_tab(1).duration         := 0;
      x_cal_record_tab(1).Monday_hours     := 0.00;
      x_cal_record_tab(1).Tuesday_hours    := 0.00;
      x_cal_record_tab(1).Wednesday_hours  := 0.00;
      x_cal_record_tab(1).Thursday_hours   := 0.00;
      x_cal_record_tab(1).Friday_hours     := 0.00;
      x_cal_record_tab(1).Saturday_hours   := 0.00;
      x_cal_record_tab(1).Sunday_hours     := 0.00;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1 ; -- 4537865
   x_msg_data := SUBSTRB(SQLERRM,1,240); -- 4537865
   FND_MSG_PUB.add_exc_msg(p_pkg_name        =>'PA_CALENDAR_UTILS',
                           p_procedure_name  => 'get_calendar_shifts');
   raise;
END get_calendar_shifts;

-- This procedure gets the exception assign to the calendar
-- Input parameters
-- Parameters                   Type               Required  Description
-- P_Calendar_Id                NUMBER             YES       Id for that calendar to which you want to have schedule
-- Out parameters
-- X_Cal_Except_Record_Tab      CALEXCEPTIONTABTYP YES       It stores the exception assign to the calendar
--

/* Added nocopy for this variable for bug#2674619 */
PROCEDURE get_calendar_except ( p_calendar_id               IN   NUMBER,
                                x_cal_except_record_tab     OUT  NOCOPY PA_SCHEDULE_GLOB.CalExceptionTabTyp,
                                x_return_status             OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count                 OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data                  OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_I            NUMBER;

 -- This cursor will select the exceptions assign to the pased calendar
/* Added trunc for calexp.start_Date_time bug 4176843 */
    CURSOR C1 IS SELECT calexp.exception_id, trunc(calexp.start_date_time) start_date_time,
                        calexp.end_date_time,calexp.exception_category
                 FROM JTF_CAL_EXCEPTIONS_B CALEXP, JTF_CAL_EXCEPTION_ASSIGN CALASN
                 WHERE calasn.calendar_id  = p_calendar_id
                 AND   calasn.exception_id = calexp.exception_id;
BEGIN
   l_I := 1;

   -- Storing the status for error handling
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Setup the cursor fetch loop
   FOR v_c1 IN C1 LOOP
     x_cal_except_record_tab(l_I).exception_id         := v_c1.exception_id;
     x_cal_except_record_tab(l_I).except_start_date    := v_c1.start_date_time;
     x_cal_except_record_tab(l_I).except_end_date      := v_c1.end_date_time; --Added For Bug 4870111
     x_cal_except_record_tab(l_I).exception_category   := v_c1.exception_category;

     l_I := l_I + 1;
   END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1 ; -- 4537865
   x_msg_data := SUBSTRB(SQLERRM,1,240); -- 4537865
    FND_MSG_PUB.add_exc_msg(p_pkg_name        =>'PA_CALENDAR_UTILS',
                            p_procedure_name  => 'get_calendar_except');
   raise;

END get_calendar_except;

-- This procedure will generate the calendar schedule on the basis of shifts assign to the calendar
-- Input parameters
-- Parameters                   Type             Required  Description
-- P_Calendar_Id                NUMBER           YES       Id for that calendar to which you want to have schedule
-- P_Cal_record_Tab             CALENDARTABTYP   YES       This variable having the shift assign to the calendar
-- Out parameters
-- X_Sch_Record_Tab             SCHEDULETABTYP   YES       It stores the generated schedule of the calendar
--

/* Added nocopy for this variable for bug#2674619 */
PROCEDURE gen_calendar_sch ( p_calendar_id               IN   NUMBER,
                             p_cal_record_tab            IN   PA_SCHEDULE_GLOB.CalendarTabTyp,
                             x_sch_record_tab            OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                             x_return_status             OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count                 OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data                  OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
  l_I                   NUMBER;
  l_J                   NUMBER;
  l_t_start_date        DATE; -- to store the active date of the calendar
  l_t_end_date          DATE;  -- to store the end date of the calendar
  l_temp_start_date     DATE; -- temporary variable to store the start date
  l_temp_end_date       DATE; -- Temporary variable to store the end date
  l_shift_done          BOOLEAN; -- variable to check if the shift is generated or not


BEGIN
   l_J := 1;

   -- Storing the status for error handling
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- if the passing calendar table type record does not have any record
   IF (p_cal_record_tab.count = 0) THEN
     Raise l_empty_tab_record;
   ELSE
     l_I := p_cal_record_tab.first;
   END IF;

   -- Taking the active date of the calendar if the ending date of the calendar is not
   -- defined then taking the specified date
   SELECT start_date_active ,NVL(end_date_active,TO_DATE('01/01/2050','DD/MM/YYYY'))
   INTO l_t_start_date,l_t_end_date
   FROM JTF_CALENDARS_B
   WHERE calendar_id = p_calendar_id;

   -- if only one shift is assign to the calendar
   IF (p_cal_record_tab.count = 1 ) THEN
     x_sch_record_tab(1).start_date                 := l_t_start_date;
     x_sch_record_tab(1).end_date                   := l_t_end_date;
     x_sch_record_tab(1).Monday_hours               := p_cal_record_tab(l_I).Monday_hours;
     x_sch_record_tab(1).Tuesday_hours              := p_cal_record_tab(l_I).Tuesday_hours;
     x_sch_record_tab(1).Wednesday_hours            := p_cal_record_tab(l_I).Wednesday_hours;
     x_sch_record_tab(1).Thursday_hours             := p_cal_record_tab(l_I).Thursday_hours;
     x_sch_record_tab(1).Friday_hours               := p_cal_record_tab(l_I).Friday_hours;
     x_sch_record_tab(1).Saturday_hours             := p_cal_record_tab(l_I).Saturday_hours;
     x_sch_record_tab(1).Sunday_hours               := p_cal_record_tab(l_I).Sunday_hours;
     x_sch_record_tab(1).calendar_id                := p_calendar_id;
     x_sch_record_tab(1).assignment_id              := NULL;
     x_sch_record_tab(1).project_id                 := NULL;
     x_sch_record_tab(1).assignment_status_code     := NULL ;
     x_sch_record_tab(1).schedule_type_code         := 'CALENDAR' ;

     RETURN;  /* Schedule is done  */
   END IF;

   -- if more than one  shift is assign and duration of the last shift is less than the calendar end date then the
   -- first shift will again assign to the calendar till its duration and then other shift till the calendar end date
   l_temp_start_date := l_t_start_date;
   l_shift_done      := FALSE;

   LOOP
     l_temp_end_date   := l_temp_start_date + p_cal_record_tab(l_I).duration;

     -- if the shift end date is greater than the calendar end date then shift is done
     IF (l_temp_end_date >= l_t_end_date ) THEN
       l_temp_end_date   := l_t_end_date;
       l_shift_done      := TRUE;
     END IF;
     -- storing the schedule with ythe given work pattern
     x_sch_record_tab(l_J).start_date                 := l_temp_start_date;
     x_sch_record_tab(l_J).end_date                   := l_temp_end_date;
     x_sch_record_tab(l_J).Monday_hours               := p_cal_record_tab(l_I).Monday_hours;
     x_sch_record_tab(l_J).Tuesday_hours              := p_cal_record_tab(l_I).Tuesday_hours;
     x_sch_record_tab(l_J).Wednesday_hours            := p_cal_record_tab(l_I).Wednesday_hours;
     x_sch_record_tab(l_J).Thursday_hours             := p_cal_record_tab(l_I).Thursday_hours;
     x_sch_record_tab(l_J).Friday_hours               := p_cal_record_tab(l_I).Friday_hours;
     x_sch_record_tab(l_J).Saturday_hours             := p_cal_record_tab(l_I).Saturday_hours;
     x_sch_record_tab(l_J).Sunday_hours               := p_cal_record_tab(l_I).Sunday_hours;
     x_sch_record_tab(l_J).calendar_id                := p_calendar_id;
     x_sch_record_tab(l_J).assignment_id              := NULL;
     x_sch_record_tab(l_J).project_id                 := NULL;
     x_sch_record_tab(l_J).assignment_status_code     := NULL ;
     x_sch_record_tab(l_J).schedule_type_code         := 'CALENDAR' ;

     IF (l_shift_done) THEN
       EXIT;
     END IF;
     -- incrementing for the next start date for the new schedule
     l_temp_start_date   := l_temp_end_date + 1;
     -- if the last shift has come and calendar end date is not reached then it will  assign the work pattern
     -- first shift till the end os its duration then other it is periodicaly process
     IF ( l_I = p_cal_record_tab.last ) THEN
       l_I := p_cal_record_tab.first;
     ELSE
      l_I := p_cal_record_tab.next(l_I);
     END IF;

     l_J := l_J + 1;
   END LOOP;

EXCEPTION
  WHEN l_empty_tab_record THEN -- the calendar table of record does not have any record
    x_return_status := FND_API.G_RET_STS_SUCCESS;
   NULL;
  WHEN NO_DATA_FOUND THEN -- if the passed calendar does not exist in the table
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data := 'Invalid Calendar Id '||p_calendar_id;
    NULL;
  WHEN OTHERS THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1 ; -- 4537865
   x_msg_data := SUBSTRB(SQLERRM,1,240); -- 4537865
   FND_MSG_PUB.add_exc_msg(p_pkg_name        =>'PA_CALENDAR_UTILS',
                           p_procedure_name  => 'gen_calendar_sch');
   raise;

END gen_calendar_sch;

-- This procedure will apply the exceptions to the generated schedule of the
-- calendar and then generate the new schedule
-- Input parameters
-- Parameters                 Type                Required  Description
-- P_Calendar_Id              NUMBER              YES       Id for that calendar to which you want to have schedule
-- P_Cal_Except_Record_tab    CALEXCEPTIONTABTYP  YES       This variable having the exception assign to the calendar
-- P_Sch_Record_Tab           SCHEDULETABTYP      YES       It contains the schedule for that calendar
-- In Out parameters
-- X_Sch_Record_Tab           SCHEDULETABTYP      YES       It stores the generated schedule after applying
--                                                          the exception to the calendar
--

/* Added nocopy for this variable for bug#2674619 */
PROCEDURE apply_calendar_except ( p_calendar_id               IN      NUMBER,
                                  p_cal_except_record_tab     IN      PA_SCHEDULE_GLOB.CalExceptionTabTyp,
                                  p_sch_record_tab            IN      PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_sch_record_tab            IN OUT  NOCOPY PA_SCHEDULE_GLOB.ScheduleTabTyp,
                                  x_return_status             OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                  x_msg_count                 OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                  x_msg_data                  OUT     NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  l_temp_exp_sch_record_tab PA_SCHEDULE_GLOB.ScheduleTabTyp; -- temporary variable
  l_temp_sch_record_tab PA_SCHEDULE_GLOB.ScheduleTabTyp; -- temporary variable
  l_out_sch_record_tab  PA_SCHEDULE_GLOB.ScheduleTabTyp; -- temporary variable
  l_I                   NUMBER;
  l_J                   NUMBER;
  l_temp_first          NUMBER; -- temporary variable
  l_temp_last           NUMBER; -- temporary variable
  l_temp_next           NUMBER; -- temporary variable
  l_shift_change        BOOLEAN;-- variable if the shift is changed
  l_x_return_status       VARCHAR2(50);
  excep_days_count        NUMBER;
BEGIN

 -- Storing the status for error handling
 l_x_return_status := FND_API.G_RET_STS_SUCCESS;
 x_return_status := FND_API.G_RET_STS_SUCCESS; -- 4537865
 -- Storing the record for using this table of record in forther calculation
 PA_SCHEDULE_UTILS.copy_schedule_rec_tab(p_sch_record_tab,p_sch_record_tab.first,p_sch_record_tab.last,
  x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);

 -- deleting sothat no previos appended record exist
 l_out_sch_record_tab.delete;

 -- if exceptions/exception exist for the given calendar
 IF ((p_cal_except_record_tab.count) >= 1 ) THEN
      l_I := p_cal_except_record_tab.first;
   LOOP
    /* Checking for the empty table of record */
    IF ( x_sch_record_tab.count = 0  ) THEN
      Raise l_empty_tab_record;
    END IF;
 /* Added for bug 4870111
				Find the number of days in the exception from the start date and end date
				and for each day add the exceptions in a loop. */
				excep_days_count := (p_cal_except_record_tab(l_I).except_end_date-p_cal_except_record_tab(l_I).except_start_date);
				for i in 0..excep_days_count  -- Loop Added for bug 4870111
				Loop
    l_J := x_sch_record_tab.first;
    l_shift_change := FALSE;
    PA_SCHEDULE_UTILS.log_message(1,'EXCPT : '||to_char(p_cal_except_record_tab(l_I).except_start_date+i,'dd/mm/yyyy'));
    LOOP
     PA_SCHEDULE_UTILS.log_message(1,'SCH : '||to_char(x_sch_record_tab(l_J).start_date,'dd/mm/yyyy')||'  '
      ||to_char(x_sch_record_tab(l_J).end_date,'dd/mm/yyyy'));

     /* Exception date is falling either before the start date of schedule or after  end date of schedule */
     IF (( p_cal_except_record_tab(l_I).except_start_date+i < x_sch_record_tab(l_J).start_date) OR
         (p_cal_except_record_tab(l_I).except_start_date+i > x_sch_record_tab(l_J).end_date) ) THEN

        --  PA_SCHEDULE_UTILS.log_message(1,'inside exp_dt < sch_st_dt or   exp_dt >  sch_end_dt ');
        -- storing this record in temp variable to copy in final variable
        IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          PA_SCHEDULE_UTILS.add_schedule_rec_tab(x_sch_record_tab,l_j,l_j,l_out_sch_record_tab,l_x_return_status,
          x_msg_count,x_msg_data);
        END IF;

     /* Exception date is falling between the start date of schedule and  end date of schedule */
     ELSIF ((p_cal_except_record_tab(l_I).except_start_date+i >= x_sch_record_tab(l_J).start_date) AND
           (p_cal_except_record_tab(l_I).except_start_date+i <= x_sch_record_tab(l_J).end_date)) THEN

           PA_SCHEDULE_UTILS.log_message(1,'inside exp_dt >= sch_st_dt AND    exp_dt <=  sch_end_dt ');

           l_shift_change := TRUE;
           -- storing the value in temp variable and using in updation of schedule record which are without exception
           IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             PA_SCHEDULE_UTILS.copy_schedule_rec_tab(x_sch_record_tab,l_J,l_J,l_temp_sch_record_tab,
              l_x_return_status,x_msg_count,x_msg_data );
           END IF;

           -- storing the value in temp variable and using in updation of schedule record which are with exception
           IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
             PA_SCHEDULE_UTILS.copy_schedule_rec_tab(x_sch_record_tab,l_J,l_J,l_temp_exp_sch_record_tab,
               l_x_return_status,x_msg_count,x_msg_data );
           END IF;

           l_temp_first := l_temp_sch_record_tab.first;
           l_temp_last  := l_temp_sch_record_tab.last;

           /* Exception date is on the start date and end date */
           IF((x_sch_record_tab(l_J).start_date = p_cal_except_record_tab(l_I).except_start_date+i AND
               x_sch_record_tab(l_J).end_date   = p_cal_except_record_tab(l_I).except_start_date+i )) THEN

             -- updating that schedule record with zero hours and keeping start date and end date is same
             IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_exp_sch_record_tab,
                p_start_date => p_cal_except_record_tab(l_I).except_start_date+i
                ,p_end_date =>p_cal_except_record_tab(l_I).except_start_date+i,p_monday_hours =>0,p_tuesday_hours =>0,
                p_wednesday_hours =>0,p_thursday_hours =>0,p_friday_hours =>0,p_saturday_hours =>0,p_sunday_hours =>0,
                x_return_status =>l_x_return_status,x_msg_count =>x_msg_count,x_msg_data =>x_msg_data);
             END IF;
             -- adding in other temp variable just to copy in final variable
             IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
               PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_exp_sch_record_tab,l_temp_first,l_temp_last,
                l_out_sch_record_tab,l_x_return_status, x_msg_count,x_msg_data);
             END IF;

           /* Exception date is on the start date and breaking that record in two records one with the zero
              schedule and other with the defined schedule  */
           ELSIF ( x_sch_record_tab(l_J).start_date = p_cal_except_record_tab(l_I).except_start_date+i  ) THEN

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_exp_sch_record_tab,
                   p_start_date => p_cal_except_record_tab(l_I).except_start_date+i
                   ,p_end_date =>p_cal_except_record_tab(l_I).except_start_date+i,p_monday_hours =>0,p_tuesday_hours =>0,
                   p_wednesday_hours =>0,p_thursday_hours =>0,p_friday_hours =>0,p_saturday_hours =>0,
                   p_sunday_hours =>0,x_return_status =>l_x_return_status,x_msg_count =>x_msg_count,
                   x_msg_data =>x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_exp_sch_record_tab,l_temp_first,l_temp_last,
                   l_out_sch_record_tab,l_x_return_status, x_msg_count,x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_sch_record_tab,
                    p_start_date =>p_cal_except_record_tab(l_I).except_start_date+i + 1 ,
                    p_end_date =>x_sch_record_tab(l_J).end_date,x_return_status =>l_x_return_status,
                    x_msg_count =>x_msg_count,x_msg_data =>x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_sch_record_tab,l_temp_first,l_temp_last,
                   l_out_sch_record_tab,l_x_return_status, x_msg_count,x_msg_data);
                END IF;

           /* Exception date is under the end date and breaking into three records one with strating date as
             it is and ending date is just before the exception date then second starting date is exception date
             and ending date is also exception but with zero hours and last having start date with just after
              the exception date and end date is passed end date  */
           ELSIF (p_cal_except_record_tab(l_I).except_start_date+i < x_sch_record_tab(l_J).end_date ) THEN

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_sch_record_tab,
                    p_start_date =>x_sch_record_tab(l_J).start_date ,
                    p_end_date =>p_cal_except_record_tab(l_I).except_start_date+i - 1,
                    x_return_status =>l_x_return_status,x_msg_count =>x_msg_count,x_msg_data =>x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_sch_record_tab,l_temp_first,l_temp_last,
                   l_out_sch_record_tab,l_x_return_status,
                   x_msg_count,x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_exp_sch_record_tab,
                    p_start_date => p_cal_except_record_tab(l_I). except_start_date+i
                    ,p_end_date =>p_cal_except_record_tab(l_I).except_start_date+i,p_monday_hours =>0,p_tuesday_hours =>0,
                    p_wednesday_hours =>0,p_thursday_hours =>0,p_friday_hours =>0,p_saturday_hours =>0,
                    p_sunday_hours =>0,x_return_status =>l_x_return_status,x_msg_count =>x_msg_count,
                    x_msg_data =>x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_exp_sch_record_tab,l_temp_first,l_temp_last,
                    l_out_sch_record_tab,l_x_return_status, x_msg_count,x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_sch_record_tab,
                   p_start_date =>p_cal_except_record_tab(l_I).except_start_date+i + 1 ,
                   p_end_date =>x_sch_record_tab(l_J).end_date,
                   x_return_status =>l_x_return_status,x_msg_count =>x_msg_count,x_msg_data =>x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_sch_record_tab,l_temp_first,l_temp_last,
                   l_out_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
                END IF;

           /* Exception date is on the end date and breaking into two records one with start date is as
              it is and end date is just before the exception date the other having start date is
              the exception date and end date is also the exception date i.e. end date of the previous schedule*/
           ELSIF (p_cal_except_record_tab(l_I).except_start_date+i = x_sch_record_tab(l_J).end_date) THEN

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_sch_record_tab,
                    p_start_date =>x_sch_record_tab(l_J).start_date ,
                    p_end_date =>p_cal_except_record_tab(l_I).except_start_date+i - 1,
                    x_return_status =>l_x_return_status,x_msg_count =>x_msg_count,x_msg_data =>x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_sch_record_tab,l_temp_first,l_temp_last,
                    l_out_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                  PA_SCHEDULE_UTILS.update_sch_rec_tab(px_sch_record_tab =>l_temp_exp_sch_record_tab,
                   p_start_date => p_cal_except_record_tab(l_I). except_start_date+i
                   ,p_end_date =>p_cal_except_record_tab(l_I).except_start_date+i,p_monday_hours =>0,p_tuesday_hours =>0,
                   p_wednesday_hours =>0,p_thursday_hours =>0,p_friday_hours =>0,p_saturday_hours =>0,
                   p_sunday_hours =>0,x_return_status =>l_x_return_status,x_msg_count =>x_msg_count,
                   x_msg_data =>x_msg_data);
                END IF;

                IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                   PA_SCHEDULE_UTILS.add_schedule_rec_tab(l_temp_exp_sch_record_tab,l_temp_first,l_temp_last,
                    l_out_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
                END IF;

           END IF;

           IF (l_J <> x_sch_record_tab.last ) THEN
             l_temp_next := x_sch_record_tab.next(l_J);
             l_temp_last := x_sch_record_tab.last;

             IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                PA_SCHEDULE_UTILS.add_schedule_rec_tab(x_sch_record_tab,l_temp_next,l_temp_last,
                  l_out_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data );
             END IF;
           END IF;
           EXIT;
     END IF;

     IF (l_J <> x_sch_record_tab.last) THEN
       l_J := x_sch_record_tab.next(l_J);
     ELSE
       EXIT;
     END IF;

    END LOOP;

    IF (l_shift_change) THEN
      IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
        -- finaly copying the records from temp variable to the actual variable
        PA_SCHEDULE_UTILS.copy_schedule_rec_tab(l_out_sch_record_tab,l_out_sch_record_tab.first,
         l_out_sch_record_tab.last,x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);
      END IF;

    END IF;

    l_out_sch_record_tab.delete;
   END loop; -- Loop Added for bug  4870111
        excep_days_count := 0;
    IF (l_I <> p_cal_except_record_tab.last) THEN
      l_I := p_cal_except_record_tab.next(l_I);
    ELSE
      EXIT;
    END IF;

   END LOOP;

 END IF;

 x_return_status := l_x_return_status;

EXCEPTION
  WHEN l_empty_tab_record THEN
   NULL;
 WHEN OTHERS THEN
 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   x_msg_count := 1 ; -- 4537865
   x_msg_data := SUBSTRB(SQLERRM,1,240); -- 4537865
 FND_MSG_PUB.add_exc_msg(p_pkg_name        =>'PA_CALENDAR_UTILS',
                         p_procedure_name  => 'apply_calendar_except');
   raise;


END apply_calendar_except;

-- This procedure will validate the passing name or Id with the existing name or id in the table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Calendar_Id                NUMBER         YES       Id for that calendar to which you want to have schedule
-- P_Calendar_Name              VARCHAR2       YES       This variable having the name of the calendar
-- p_check_id_flag              VARCHAR2       NO        check id flag
-- Out parameters
-- X_Calendar_Id                 NUMBER         YES       It stores the validated calenda id
--
PROCEDURE  Check_Calendar_Name_Or_Id
      ( p_calendar_id         IN JTF_CALENDARS_VL.calendar_id%TYPE
       ,p_calendar_name       IN JTF_CALENDARS_VL.calendar_name%TYPE
       ,p_check_id_flag       IN VARCHAR2 := 'A'
       ,x_calendar_id         OUT NOCOPY JTF_CALENDARS_VL.calendar_id%TYPE   --File.Sql.39 bug 4440895
       ,x_return_status       OUT NOCOPY VARCHAR2                                     --File.Sql.39 bug 4440895
       ,x_error_message_code  OUT NOCOPY VARCHAR2) IS  --File.Sql.39 bug 4440895

   l_current_id NUMBER := NULL;
   l_num_ids NUMBER := 0;
   l_id_found_flag VARCHAR(1) := 'N';

   CURSOR c_ids IS
      SELECT calendar_id
      FROM jtf_calendars_vl
      WHERE calendar_name = p_calendar_name;
BEGIN

 /* Bug 2887390 : Added the following condition */
   IF (p_calendar_id is NULL and p_calendar_name is NULL) THEN
      x_calendar_id := NULL;
      x_return_status := FND_API.G_RET_STS_ERROR;
      x_error_message_code := 'PA_CALENDAR_ID_INVALID';
      return;
   END IF;

   IF (p_calendar_id IS NOT NULL) THEN
      IF (p_check_id_flag = 'Y') THEN
         -- Validate ID
         SELECT calendar_id
         INTO x_calendar_id
         FROM jtf_calendars_b  -- 4370086: FROM jtf_calendars_vl
         WHERE calendar_id = p_calendar_id;
      ELSIF (p_check_id_flag = 'N') THEN
         -- No ID validation necessary
         x_calendar_id := p_calendar_id;
      ELSIF (p_check_id_flag = 'A') THEN
         IF (p_calendar_name IS NULL) THEN
            -- Return a null ID since the name is null.
            x_calendar_id := NULL;
         ELSE
            -- Find the ID which matches the Name passed
            OPEN c_ids;
            LOOP
               FETCH c_ids INTO l_current_id;
               EXIT WHEN c_ids%NOTFOUND;
               IF (l_current_id = p_calendar_id) THEN
                  l_id_found_flag := 'Y';
                  x_calendar_id := p_calendar_id;
               END IF;
            END LOOP;
            l_num_ids := c_ids%ROWCOUNT;
            CLOSE c_ids;

            IF (l_num_ids = 0) THEN
               -- No IDs for name
               RAISE NO_DATA_FOUND;
            ELSIF (l_num_ids = 1) THEN
               -- Since there is only one ID for the name use it.
               x_calendar_id := l_current_id;
            ELSIF (l_id_found_flag = 'N') THEN
               -- More than one ID for the name and none of the IDs matched
               -- the ID passed in.
               RAISE TOO_MANY_ROWS;
            END IF;
         END IF;
      END IF;
   ELSE   -- Find ID since it was not passed.
      IF (p_calendar_name IS NOT NULL) THEN
         SELECT calendar_id
         INTO x_calendar_id
         FROM jtf_calendars_vl
         WHERE calendar_name = p_calendar_name;
      ELSE
         x_calendar_id := NULL;
      END IF;
   END IF;

   x_return_status:= FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
      x_calendar_id := NULL;
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	    x_error_message_code := 'PA_CALENDAR_ID_INVALID';
	WHEN TOO_MANY_ROWS THEN
      x_calendar_id := NULL;
  	  x_return_status := FND_API.G_RET_STS_ERROR;
	    x_error_message_code := 'PA_CALENDAR_NOT_UNIQUE';
  WHEN OTHERS THEN
      x_calendar_id := NULL;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      -- 4537865 : reset x_error_message_code also
      x_error_message_code := SQLCODE ;

      FND_MSG_PUB.add_exc_msg(p_pkg_name        =>'PA_CALENDAR_UTILS',
                              p_procedure_name  => 'Check_Calendar_Name_Or_Id');
      RAISE;
END Check_Calendar_Name_Or_Id;

--
END PA_CALENDAR_UTILS;

/
