--------------------------------------------------------
--  DDL for Package Body PA_SCHEDULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SCHEDULE_PKG" as
--/* $Header: PARGSCHB.pls 120.5 2007/11/05 11:03:57 rthumma ship $ */

  l_empty_tab_record  EXCEPTION;  --  Variable to raise the exception if  the passing table of records is empty

-- This function will generate the schedule id
FUNCTION get_nextval RETURN NUMBER
IS
 l_nextval    NUMBER;
BEGIN

 SELECT pa_schedules_s.nextval
 INTO   l_nextval
 FROM   SYS.DUAL;

 RETURN(l_nextval);

EXCEPTION
 WHEN OTHERS
 THEN
      RAISE;
END get_nextval;

-- This procedure will insert the record in pa_schedules table
-- Input parameters
-- Parameters                   Type                Required  Description
-- P_Sch_Record_Tab             ScheduleTabTyp      YES       It contains the schedule record
--
--Bug 5126919: Added parameter p_total_hours. This will contain the total hours for
--which the schedule should be created. This will be used to make sure that schedule is created
--correctly (for the whole p_total_hours) even after rounding.
PROCEDURE insert_rows ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        p_total_hours                IN   NUMBER DEFAULT NULL) --Bug 5126919
IS
        l_schedule_id              PA_PLSQL_DATATYPES.IdTabTyp;
        l_calendar_id              PA_PLSQL_DATATYPES.IdTabTyp;
        l_assignment_id            PA_PLSQL_DATATYPES.IdTabTyp;
        l_project_id               PA_PLSQL_DATATYPES.IdTabTyp;
        l_schedule_type_code       PA_PLSQL_DATATYPES.Char30TabTyp;
        l_assignment_status_code   PA_PLSQL_DATATYPES.Char30TabTyp;
        l_start_date               PA_PLSQL_DATATYPES.DateTabTyp;
        l_end_date                 PA_PLSQL_DATATYPES.DateTabTyp;
        l_monday_hours             PA_PLSQL_DATATYPES.NumTabTyp;
        l_tuesday_hours            PA_PLSQL_DATATYPES.NumTabTyp;
        l_wednesday_hours          PA_PLSQL_DATATYPES.NumTabTyp;
        l_thursday_hours           PA_PLSQL_DATATYPES.NumTabTyp;
        l_friday_hours             PA_PLSQL_DATATYPES.NumTabTyp;
        l_saturday_hours           PA_PLSQL_DATATYPES.NumTabTyp;
        l_sunday_hours             PA_PLSQL_DATATYPES.NumTabTyp;

	--Bug 5126919
        l_rounded_total                NUMBER;
        l_last_rec_index               NUMBER;
        l_adj_day                      VARCHAR2(10);
        l_adj_date                     DATE;
        l_adj_hours                    NUMBER;
        l_multiple_day_instances_flag  VARCHAR2(1);
        l_mon_hrs_in_new_rec           NUMBER;
        l_tue_hrs_in_new_rec           NUMBER;
        l_wed_hrs_in_new_rec           NUMBER;
        l_thu_hrs_in_new_rec           NUMBER;
        l_fri_hrs_in_new_rec           NUMBER;
        l_sat_hrs_in_new_rec           NUMBER;
        l_sun_hrs_in_new_rec           NUMBER;
        l_new_rec_start_date           DATE;
        l_new_rec_end_date             DATE;
        l_temp                         NUMBER ;
        l_temp_date                    DATE;
        l_temp_day                     VARCHAR2(10);

      --Added for bug Bug 5684828
        l_sch_except_rec       PA_SCHEDULE_GLOB.SchExceptRecord;
        l_out_sch_rec_tab      PA_SCHEDULE_GLOB.ScheduleTabTyp;
        l_x_return_status                VARCHAR2(1) := FND_API.G_RET_STS_SUCCESS ;

	--Added for bug 5856987
	 K NUMBER;


BEGIN

x_return_status := FND_API.G_RET_STS_SUCCESS;

/* Checking for the empty table of record */
IF (p_sch_record_tab.count = 0 ) THEN
PA_SCHEDULE_UTILS.log_message(1,'count 0 ... before return ... ');
  raise l_empty_tab_record;
END IF;

PA_SCHEDULE_UTILS.log_message(1,'start of the schedule inser row .... ');

l_rounded_total := 0;  --Bug 5126919

FOR J IN p_sch_record_tab.first..p_sch_record_tab.last LOOP
l_schedule_id(J) := get_nextval;
l_calendar_id(J) := p_sch_record_tab(J).calendar_id;
l_assignment_id(J) := p_sch_record_tab(J).assignment_id;
l_project_id(J)             := p_sch_record_tab(J).project_id;
l_schedule_type_code(J)     := p_sch_record_tab(J).schedule_type_code;
l_assignment_status_code(J)  := p_sch_record_tab(J).assignment_status_code;
l_start_date(J)              := trunc(p_sch_record_tab(J).start_date);
l_end_date(J)                := trunc(p_sch_record_tab(J).end_date);
l_monday_hours(J)            := trunc(p_sch_record_tab(J).monday_hours, 2);
l_tuesday_hours(J)           := trunc(p_sch_record_tab(J).tuesday_hours, 2);
l_wednesday_hours(J)         := trunc(p_sch_record_tab(J).wednesday_hours, 2);
l_thursday_hours(J)          := trunc(p_sch_record_tab(J).thursday_hours, 2);
l_friday_hours(J)            := trunc(p_sch_record_tab(J).friday_hours, 2);
l_saturday_hours(J)          := trunc(p_sch_record_tab(J).saturday_hours, 2);
l_sunday_hours(J)           := trunc(p_sch_record_tab(J).sunday_hours, 2);

--Bug 5126919: The below block will be used to find out the total hours that this schedule will contain,
--with the hours derived after rounding as above.
l_temp_date  := l_start_date(J);
l_temp_day   := to_char(l_temp_date,'DY','NLS_DATE_LANGUAGE = AMERICAN');
    LOOP

        IF l_temp_day ='MON' THEN

            l_rounded_total := l_rounded_total + l_monday_hours(J);

        END IF;

        IF l_temp_day ='TUE' THEN

            l_rounded_total := l_rounded_total + l_tuesday_hours(J);

        END IF;

        IF l_temp_day ='WED' THEN

            l_rounded_total := l_rounded_total + l_wednesday_hours(J);

        END IF;

        IF l_temp_day ='THU' THEN

            l_rounded_total := l_rounded_total + l_thursday_hours(J);

        END IF;

        IF l_temp_day ='FRI' THEN

            l_rounded_total := l_rounded_total + l_friday_hours(J);

        END IF;

        IF l_temp_day ='SAT' THEN

            l_rounded_total := l_rounded_total + l_saturday_hours(J);

        END IF;

        IF l_temp_day ='SUN' THEN

            l_rounded_total := l_rounded_total + l_sunday_hours(J);

        END IF;

        EXIT WHEN l_temp_date = l_end_date(J);
        l_temp_date  := l_temp_date + 1;
        l_temp_day   := to_char(l_temp_date,'DY','NLS_DATE_LANGUAGE = AMERICAN');

    END LOOP;

END LOOP;

--Bug 5126919. If rounded total is not same as the total for which the schedule should be created then
----1.Find out the last record in the schedule that contains atleast one day having non-zero hours.Going forward
----lets point to this record as last_record and the day as last_day (i.e. monday for example) and
----date of last_day as last_date
----2.If the last_record spans for only one day then the difference in rounded total and actual total will
----be accomodated  in the appropriate day of that record
----3.If the last record spans for more than one day then a new record will be created to accomodate the difference.
------For new record start_date will be last_date and end_date will be end_date of last_record. For
------last_record the end date will be changed to a date which is last_date-1. New record
------will contain the hours in the last_day of last_record + (difference of rounded total and actual total)
------3.1 If last_day is repeated more than once in the last_record (i.e. for example if last_day is monday and if
------    it occurs more than once in last_record's duration) then the hours in the last_day of last_record will
------    be retained. If it is not repeated then the hours of the last_day of last_record will be zeroed out
------    since no date in that duration will fall on that day (for example if the last_date falls on monday
------    and none of the other dates in the last_record is monday)
IF NVL(p_total_hours,l_rounded_total) <> l_rounded_total THEN

    l_last_rec_index:=p_sch_record_tab.last;
    LOOP
        EXIT WHEN ( nvl(l_last_rec_index,0) < 1 ); -- Added for Bug 6154177 , as have to check l_last_rec_index to be positive.
        EXIT WHEN l_monday_hours(l_last_rec_index)    <> 0 OR
                  l_tuesday_hours(l_last_rec_index)   <> 0 OR
                  l_wednesday_hours(l_last_rec_index) <> 0 OR
                  l_thursday_hours(l_last_rec_index)  <> 0 OR
                  l_friday_hours(l_last_rec_index)    <> 0 OR
                  l_saturday_hours(l_last_rec_index)  <> 0 OR
                  l_sunday_hours(l_last_rec_index)    <> 0 ;

        l_last_rec_index:=l_last_rec_index-1;
        --Note that atleast one set of records should have a non-zero value because the control
        --will not come here otherwise (i.e. p_total_hours will be same as l_rounded_total)

    END LOOP;

    /*Added for Bug 6154177: The above loop may make l_last_rec_index = 0 if the schedule has just one record */
    IF (l_last_rec_index = 0) THEN
    l_last_rec_index := l_last_rec_index + 1;
    END IF ;
    /*End for Bug 6154177 */

    l_mon_hrs_in_new_rec := 0;
    l_tue_hrs_in_new_rec := 0;
    l_wed_hrs_in_new_rec := 0;
    l_thu_hrs_in_new_rec := 0;
    l_fri_hrs_in_new_rec := 0;
    l_sat_hrs_in_new_rec := 0;
    l_sun_hrs_in_new_rec := 0;
    l_adj_date           := l_end_date(l_last_rec_index);
    l_adj_day            := to_char(l_adj_date,'DY','NLS_DATE_LANGUAGE = AMERICAN');

    LOOP

        --If l_adj_date is the last date on which hours exist then a check should be made if the
        --the value for this day in the record should be zeored out or not. The value should be zeroed out
        --if the day occurs only once in the period duration.
        IF l_start_date(l_last_rec_index) <= (l_adj_date-7) THEN

            l_multiple_day_instances_flag := 'Y';

        END IF;

        IF l_adj_day ='MON' THEN

            IF l_monday_hours(l_last_rec_index) <> 0 THEN

                l_mon_hrs_in_new_rec := l_monday_hours(l_last_rec_index) + trunc((p_total_hours-l_rounded_total),2);
                IF l_multiple_day_instances_flag = 'N' THEN

                    l_monday_hours(l_last_rec_index):= 0;

                END IF;

                EXIT;

            END IF;

        END IF;

        IF l_adj_day ='TUE' THEN

            IF l_tuesday_hours(l_last_rec_index) <> 0 THEN

                l_tue_hrs_in_new_rec := l_tuesday_hours(l_last_rec_index) + trunc((p_total_hours-l_rounded_total),2);
                IF l_multiple_day_instances_flag = 'N' THEN

                    l_tuesday_hours(l_last_rec_index):= 0;

                END IF;

                EXIT;

            END IF;

        END IF;

        IF l_adj_day ='WED' THEN

            IF l_wednesday_hours(l_last_rec_index) <> 0 THEN

                l_wed_hrs_in_new_rec := l_wednesday_hours(l_last_rec_index) + trunc((p_total_hours-l_rounded_total),2);
                IF l_multiple_day_instances_flag = 'N' THEN

                    l_wednesday_hours(l_last_rec_index):= 0;

                END IF;

                EXIT;

            END IF;

        END IF;

        IF l_adj_day ='THU' THEN

            IF l_thursday_hours(l_last_rec_index) <> 0 THEN

                l_thu_hrs_in_new_rec := l_thursday_hours(l_last_rec_index) + trunc((p_total_hours-l_rounded_total),2);
                IF l_multiple_day_instances_flag = 'N' THEN

                    l_thursday_hours(l_last_rec_index):= 0;

                END IF;

                EXIT;

            END IF;

        END IF;

        IF l_adj_day ='FRI' THEN

            IF l_friday_hours(l_last_rec_index) <> 0 THEN

                l_fri_hrs_in_new_rec := l_friday_hours(l_last_rec_index) + trunc((p_total_hours-l_rounded_total),2);
                IF l_multiple_day_instances_flag = 'N' THEN

                    l_friday_hours(l_last_rec_index):= 0;

                END IF;

                EXIT;

            END IF;

        END IF;

        IF l_adj_day ='SAT' THEN

            IF l_saturday_hours(l_last_rec_index) <> 0 THEN

                l_sat_hrs_in_new_rec := l_saturday_hours(l_last_rec_index) + trunc((p_total_hours-l_rounded_total),2);
                IF l_multiple_day_instances_flag = 'N' THEN

                    l_saturday_hours(l_last_rec_index):= 0;

                END IF;

                EXIT;

            END IF;

        END IF;

        IF l_adj_day ='SUN' THEN

            IF l_sunday_hours(l_last_rec_index) <> 0 THEN

                l_sun_hrs_in_new_rec := l_sunday_hours(l_last_rec_index) + trunc((p_total_hours-l_rounded_total),2);
                IF l_multiple_day_instances_flag = 'N' THEN

                    l_sunday_hours(l_last_rec_index):= 0;

                END IF;

                EXIT;

            END IF;

        END IF;

        l_adj_date := l_adj_date-1;
        l_adj_day  := to_char(l_adj_date,'DY','NLS_DATE_LANGUAGE = AMERICAN');
        --Note that l_adj_date can not get set to a date which is before l_start_date(l_last_rec_index)
        --since one of 7-day hours is non-zero

        /*Added this exit cond for Bug 6154177: The above loop should not go beyond l_adj_date < l_start_date(l_last_rec_index) */
        EXIT WHEN (l_adj_date < l_start_date(l_last_rec_index));

    END LOOP;
    --Note that after the above loop only of l_(mon-sun)_hrs_in_new_rec will contain a non-zero value
    --and all others will contan zeroes

    /*Added for Bug 6154177: The above loop may make l_adj_date < l_start_date(l_last_rec_index)*/
    IF (l_adj_date < l_start_date(l_last_rec_index)) THEN
    l_adj_date := l_adj_date + 1;
    END IF ;
    /*End for Bug 6154177 */

/*Commented for bug 5684828

    l_new_rec_start_date := l_adj_date;
    l_new_rec_end_date   := l_end_date(l_last_rec_index);

    --Change the end date of the last record with non-zero hours if the period duration is for more than one day
    --Update the same record if the duration is only for one day.
    IF l_end_date(l_last_rec_index) - l_start_date(l_last_rec_index) > 0 THEN

        l_end_date(l_last_rec_index) := l_new_rec_start_date -1;

        --Create new record to accomodate rounding difference
        l_temp                              := l_schedule_id.last + 1;
        l_schedule_id(l_temp)               := get_nextval;
        l_calendar_id(l_temp)               := p_sch_record_tab(l_last_rec_index).calendar_id;
        l_assignment_id(l_temp)             := p_sch_record_tab(l_last_rec_index).assignment_id;
        l_project_id(l_temp)                := p_sch_record_tab(l_last_rec_index).project_id;
        l_schedule_type_code(l_temp)        := p_sch_record_tab(l_last_rec_index).schedule_type_code;
        l_assignment_status_code(l_temp)    := p_sch_record_tab(l_last_rec_index).assignment_status_code;
        l_start_date(l_temp)                := l_new_rec_start_date;
        l_end_date(l_temp)                  := l_new_rec_end_date;
        l_monday_hours(l_temp)              := l_mon_hrs_in_new_rec;
        l_tuesday_hours(l_temp)             := l_tue_hrs_in_new_rec;
        l_wednesday_hours(l_temp)           := l_wed_hrs_in_new_rec;
        l_thursday_hours(l_temp)            := l_thu_hrs_in_new_rec;
        l_friday_hours(l_temp)              := l_fri_hrs_in_new_rec;
        l_saturday_hours(l_temp)            := l_sat_hrs_in_new_rec;
        l_sunday_hours(l_temp)              := l_sun_hrs_in_new_rec;

    ELSE

        --Update the above found record so as to accomodate rounding difference
        l_temp                              := l_last_rec_index;
        l_monday_hours(l_temp)              := l_mon_hrs_in_new_rec;
        l_tuesday_hours(l_temp)             := l_tue_hrs_in_new_rec;
        l_wednesday_hours(l_temp)           := l_wed_hrs_in_new_rec;
        l_thursday_hours(l_temp)            := l_thu_hrs_in_new_rec;
        l_friday_hours(l_temp)              := l_fri_hrs_in_new_rec;
        l_saturday_hours(l_temp)            := l_sat_hrs_in_new_rec;
        l_sunday_hours(l_temp)              := l_sun_hrs_in_new_rec;

    END IF;
End of Commented for bug 5684828
*/

	--- Added below code for bug 5684828

	--Setting the dates to adjustment date
	l_new_rec_start_date := l_adj_date;
        l_new_rec_end_date := l_adj_date; --5684828

	--Copying the basic schedule information into exception record
	l_sch_except_rec.assignment_id := p_sch_record_tab(l_last_rec_index).assignment_id;
	l_sch_except_rec.calendar_id := p_sch_record_tab(l_last_rec_index).calendar_id;
	l_sch_except_rec.project_id := p_sch_record_tab(l_last_rec_index).project_id;
	l_sch_except_rec.schedule_type_code := p_sch_record_tab(l_last_rec_index).schedule_type_code;
	l_sch_except_rec.assignment_status_code := p_sch_record_tab(l_last_rec_index).assignment_status_code;

	--Copying the date and hours information into exception record
	l_sch_except_rec.start_date := l_new_rec_start_date;
	l_sch_except_rec.end_date := l_new_rec_end_date;
	l_sch_except_rec.monday_hours := l_mon_hrs_in_new_rec;
	l_sch_except_rec.tuesday_hours := l_tue_hrs_in_new_rec;
	l_sch_except_rec.wednesday_hours := l_wed_hrs_in_new_rec;
	l_sch_except_rec.thursday_hours := l_thu_hrs_in_new_rec;
	l_sch_except_rec.friday_hours := l_fri_hrs_in_new_rec;
	l_sch_except_rec.saturday_hours := l_sat_hrs_in_new_rec;
	l_sch_except_rec.sunday_hours := l_sun_hrs_in_new_rec;

	--Setting  exception_type_code for update workpattern in the exception record
	l_sch_except_rec.exception_type_code := 'CHANGE_WORK_PATTERN';

	PA_SCHEDULE_UTILS.log_message(1, 'Insert_Row before apply_other_changes ....');

	PA_SCHEDULE_PVT.apply_other_changes(p_sch_record_tab,
						l_sch_except_rec,
						l_out_sch_rec_tab,
						l_x_return_status,
						x_msg_count,
						x_msg_data);

	PA_SCHEDULE_UTILS.log_message(1, 'Insert_Row After apply_other_changes ....' || l_x_return_status);
	PA_SCHEDULE_UTILS.log_message(1,'l_out_sch_rec_tab (change ) : ',l_out_sch_rec_tab );


	IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN

		IF l_out_sch_rec_tab.count < p_sch_record_tab.COUNT THEN
		-- This condition will not happen since apply_other_changes will only append the change_type_code = D it will
		-- not delete any record from p_sch_record_tab pl/sql table while generating l_out_sch_rec_tab
		-- This has only been placed for debugging purposes in future to trap the error point in apply_other_changes
			PA_SCHEDULE_UTILS.log_message(1,'apply_other_changes retuned less count ');
			RAISE FND_API.G_EXC_ERROR;
		ELSE
			--Added for bug 5856987
			l_schedule_id.delete;
			l_calendar_id.delete;
			l_assignment_id.delete;
			l_project_id.delete;
			l_schedule_type_code.delete;
			l_assignment_status_code.delete;
			l_start_date.delete;
			l_end_date.delete;
			l_monday_hours.delete;
			l_tuesday_hours.delete;
			l_wednesday_hours.delete;
			l_thursday_hours.delete;
			l_friday_hours.delete;
			l_saturday_hours.delete;
			l_sunday_hours.delete;
			K := 1;
			--End for bug 5856987

				FOR J IN l_out_sch_rec_tab.first..l_out_sch_rec_tab.last LOOP

				IF nvl(l_out_sch_rec_tab(J).change_type_code,'X') <> 'D' THEN --Added for bug 5856987

					IF (NVL(l_out_sch_rec_tab(J).schedule_id,-1) <= 0) THEN
						l_schedule_id(K)             := get_nextval;
					ELSE
						l_schedule_id(K) := l_out_sch_rec_tab(J).schedule_id;
					END IF;

					l_calendar_id(K)             := l_out_sch_rec_tab(J).calendar_id;
					l_assignment_id(K)           := l_out_sch_rec_tab(J).assignment_id;
					l_project_id(K)              := l_out_sch_rec_tab(J).project_id;
					l_schedule_type_code(K)      := l_out_sch_rec_tab(J).schedule_type_code;
					l_assignment_status_code(K)  := l_out_sch_rec_tab(J).assignment_status_code;
					l_start_date(K)              := trunc(l_out_sch_rec_tab(J).start_date);
					l_end_date(K)                := trunc(l_out_sch_rec_tab(J).end_date);
					l_monday_hours(K)            := trunc(l_out_sch_rec_tab(J).monday_hours, 2);
					l_tuesday_hours(K)           := trunc(l_out_sch_rec_tab(J).tuesday_hours, 2);
					l_wednesday_hours(K)         := trunc(l_out_sch_rec_tab(J).wednesday_hours, 2);
					l_thursday_hours(K)          := trunc(l_out_sch_rec_tab(J).thursday_hours, 2);
					l_friday_hours(K)            := trunc(l_out_sch_rec_tab(J).friday_hours, 2);
					l_saturday_hours(K)          := trunc(l_out_sch_rec_tab(J).saturday_hours, 2);
					l_sunday_hours(K)            := trunc(l_out_sch_rec_tab(J).sunday_hours, 2);

					K := K + 1; --Added for bug 5856987
				END IF; --Added for bug 5856987

			END LOOP;
		END IF;
	ELSE
		PA_SCHEDULE_UTILS.log_message(1,'l_x_return_status is not success ');
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	--- End of  bug 5684828


END IF;--IF p_total_hours > l_rounded_total THEN

--FORALL J IN p_sch_record_tab.first..p_sch_record_tab.last  -- Commented for Bug 5126919
FORALL J IN l_schedule_id.first..l_schedule_id.last  -- Added for Bug 5126919
 INSERT INTO PA_SCHEDULES
      ( schedule_id             ,
        calendar_id             ,
        assignment_id           ,
        project_id              ,
        schedule_type_code      ,
        status_code             ,
        start_date              ,
        end_date                ,
        monday_hours            ,
        tuesday_hours           ,
        wednesday_hours         ,
        thursday_hours          ,
        friday_hours            ,
        saturday_hours          ,
        sunday_hours            ,
        forecast_txn_version_number,
        forecast_txn_generated_flag,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_update_by          ,
        last_update_login       ,
        request_id              ,
        program_application_id  ,
        program_id              ,
        program_update_date     )
 VALUES
     (  l_schedule_id(J)             ,
        l_calendar_id(J)             ,
        l_assignment_id(J)           ,
        l_project_id(J)              ,
        l_schedule_type_code(J)      ,
        l_assignment_status_code(J)  ,
        l_start_date(J)              ,
        l_end_date(J)                ,
        l_monday_hours(J)            ,
        l_tuesday_hours(J)           ,
        l_wednesday_hours(J)         ,
        l_thursday_hours(J)          ,
        l_friday_hours(J)            ,
        l_saturday_hours(J)          ,
        l_sunday_hours(J)            ,
        1                            ,
        'N'                          ,
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id          ,
        fnd_global.conc_request_id() ,
        fnd_global.prog_appl_id   () ,
        fnd_global.conc_program_id() ,
        trunc(sysdate)               );

PA_SCHEDULE_UTILS.log_message(1,'end   of the schedule inser row .... ');

EXCEPTION
 WHEN  FND_API.G_EXC_ERROR  THEN --Added for bug 5684828
  x_return_status := l_x_return_status;
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'insert_rows');
 raise;

 PA_SCHEDULE_UTILS.log_message(1,'ERROR ....'||sqlerrm);
END insert_rows;

-- This procedure will insert  the record in pa_schedules table
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignment
-- P_Assignment_Id              NUMBER         YES      Assignment id of the schedule records
-- P_Project_Id                 NUMBER         YES      project id of the associated calendar
-- P_Schedule_Type_Code         VARCHAR2       YES      It is schedule type code e.g changed hours/changed duration
-- P_Assignment_Status_Code     VARCHAR2       YES      Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Start_Date                 DATE           YES      stat date of the schedule
-- P_End_Date                   DATE           YES      end date of the schedule
-- P_Monday_Hours               NUMBER         YES      No. of hours of this day
-- P_Tuesday_Hours              NUMBER         YES      No. of hours of this day
-- P_Wednesday_Hours            NUMBER         YES      No. of hours of this day
-- P_Thursday_Hours             NUMBER         YES      No. of hours of this day
-- P_Friday_Hours               NUMBER         YES      No. of hours of this day
-- P_Saturday_Hours             NUMBER         YES      No. of hours of this day
-- P_Sunday_Hours               NUMBER         YES      No. of hours of this day
--

PROCEDURE insert_rows
        ( p_calendar_id                    IN Number Default null         ,
        p_assignment_id                    IN Number  Default null         ,
        p_project_id                       IN Number  Default null        ,
        p_schedule_type_code               IN varchar2        ,
        p_assignment_status_code           IN varchar2  Default null      ,
        p_start_date                       IN date            ,
        p_end_date                         IN date            ,
        p_monday_hours                     IN Number          ,
        p_tuesday_hours                    IN Number          ,
        p_wednesday_hours                  IN Number          ,
        p_thursday_hours                   IN Number          ,
        p_friday_hours                     IN Number          ,
        p_saturday_hours                   IN Number          ,
        p_sunday_hours                     IN Number          ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
 l_t_schedule_id  NUMBER;
BEGIN
/* 1799636 The following line of code was commented to resolve the performance issue  */
--  l_t_schedule_id := get_nextval;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

 INSERT INTO PA_SCHEDULES
      ( schedule_id             ,
        calendar_id             ,
        assignment_id           ,
        project_id              ,
        schedule_type_code      ,
        status_code             ,
        start_date              ,
        end_date                ,
        monday_hours            ,
        tuesday_hours           ,
        wednesday_hours         ,
        thursday_hours          ,
        friday_hours            ,
        saturday_hours          ,
        sunday_hours            ,
        forecast_txn_version_number,
        forecast_txn_generated_flag,
        creation_date           ,
        created_by              ,
        last_update_date        ,
        last_update_by          ,
        last_update_login       ,
        request_id              ,
        program_application_id  ,
        program_id              ,
        program_update_date     )
 VALUES
--     (  l_t_schedule_id                ,
	(pa_schedules_s.nextval,
        p_calendar_id                ,
        p_assignment_id              ,
        p_project_id                 ,
        p_schedule_type_code         ,
        p_assignment_status_code     ,
        trunc(p_start_date)                 ,
        trunc(p_end_date)                   ,
        p_monday_hours               ,
        p_tuesday_hours              ,
        p_wednesday_hours            ,
        p_thursday_hours             ,
        p_friday_hours               ,
        p_saturday_hours             ,
        p_sunday_hours               ,
        1                            ,
        'N'                          ,
        sysdate                      ,
        fnd_global.user_id           ,
        sysdate                      ,
        fnd_global.user_id           ,
        fnd_global.login_id          ,
        fnd_global.conc_request_id() ,
        fnd_global.prog_appl_id   () ,
        fnd_global.conc_program_id() ,
        trunc(sysdate)               );

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'insert_rows');
 raise;

END insert_rows;

-- This procedure will update  the record in pa_schedules table
-- Input parameters
-- Parameters                Type                Required  Description
-- P_Sch_Record_Tab          ScheduleTabTyp      YES       It contains the schedule record
--

PROCEDURE update_rows ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
        l_schrowid                 PA_PLSQL_DATATYPES.RowidTabTyp;
        l_schedule_id              PA_PLSQL_DATATYPES.IdTabTyp;
        l_calendar_id              PA_PLSQL_DATATYPES.IdTabTyp;
        l_assignment_id            PA_PLSQL_DATATYPES.IdTabTyp;
        l_project_id               PA_PLSQL_DATATYPES.IdTabTyp;
        l_schedule_type_code       PA_PLSQL_DATATYPES.Char30TabTyp;
        l_assignment_status_code   PA_PLSQL_DATATYPES.Char30TabTyp;
        l_start_date               PA_PLSQL_DATATYPES.DateTabTyp;
        l_end_date                 PA_PLSQL_DATATYPES.DateTabTyp;
        l_monday_hours             PA_PLSQL_DATATYPES.NumTabTyp;
        l_tuesday_hours            PA_PLSQL_DATATYPES.NumTabTyp;
        l_wednesday_hours          PA_PLSQL_DATATYPES.NumTabTyp;
        l_thursday_hours           PA_PLSQL_DATATYPES.NumTabTyp;
        l_friday_hours             PA_PLSQL_DATATYPES.NumTabTyp;
        l_saturday_hours           PA_PLSQL_DATATYPES.NumTabTyp;
        l_sunday_hours             PA_PLSQL_DATATYPES.NumTabTyp;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

PA_SCHEDULE_UTILS.log_message(1,'start of the schedule inser row .... ');
if ( p_sch_record_tab.count = 0 ) then
    PA_SCHEDULE_UTILS.log_message(1,'count 0 ... and returning ');
    raise l_empty_tab_record;
end if;

FOR J IN p_sch_record_tab.first..p_sch_record_tab.last LOOP

    PA_SCHEDULE_UTILS.log_message(1,' J '||to_char(J)||' sch_id '||to_char(p_sch_record_tab(J).schedule_id)
            || ' start_date '||p_sch_record_tab(J).start_date);
l_schrowid(J)  := p_sch_record_tab(J).schrowid;
l_schedule_id(J) := p_sch_record_tab(J).schedule_id;
l_calendar_id(J) := p_sch_record_tab(J).calendar_id;
l_assignment_id(J) := p_sch_record_tab(J).assignment_id;
l_project_id(J)             := p_sch_record_tab(J).project_id;
l_schedule_type_code(J)     := p_sch_record_tab(J).schedule_type_code;
l_assignment_status_code(J)  := p_sch_record_tab(J).assignment_status_code;
l_start_date(J)              := trunc(p_sch_record_tab(J).start_date);
l_end_date(J)                := trunc(p_sch_record_tab(J).end_date);
l_monday_hours(J)            := trunc(p_sch_record_tab(J).monday_hours, 2);
l_tuesday_hours(J)           := trunc(p_sch_record_tab(J).tuesday_hours, 2);
l_wednesday_hours(J)         := trunc(p_sch_record_tab(J).wednesday_hours, 2);
l_thursday_hours(J)          := trunc(p_sch_record_tab(J).thursday_hours, 2);
l_friday_hours(J)            := trunc(p_sch_record_tab(J).friday_hours, 2);
l_saturday_hours(J)          := trunc(p_sch_record_tab(J).saturday_hours, 2);
l_sunday_hours(J)           := trunc(p_sch_record_tab(J).sunday_hours, 2);

    PA_SCHEDULE_UTILS.log_message(1,' J '||to_char(J)||' l_sch_id '||to_char(l_schedule_id(J))||'start_date '|| to_char(l_start_date(J)));
END LOOP;

FORALL J IN p_sch_record_tab.first..p_sch_record_tab.last
 UPDATE PA_SCHEDULES
 SET
        calendar_id             = l_calendar_id(J),
        assignment_id           = l_assignment_id(J),
        project_id              = l_project_id(J),
        schedule_type_code      = l_schedule_type_code(J),
        status_code             = l_assignment_status_code(J),
        start_date              = l_start_date(J),
        end_date                = l_end_date(J),
        monday_hours            = l_monday_hours(J),
        tuesday_hours           = l_tuesday_hours(J),
        wednesday_hours         = l_wednesday_hours(J),
        thursday_hours          = l_thursday_hours(J),
        friday_hours            = l_friday_hours(J),
        saturday_hours          = l_saturday_hours(J),
        sunday_hours            = l_sunday_hours(J),
        forecast_txn_version_number = forecast_txn_version_number+1,
        forecast_txn_generated_flag = 'N',
        last_update_date        = sysdate ,
        last_update_by          = fnd_global.user_id,
        last_update_login       = fnd_global.login_id
 WHERE  schedule_id = l_schedule_id(J);

PA_SCHEDULE_UTILS.log_message(1,'end of update row .... ');
EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

 PA_SCHEDULE_UTILS.log_message(1,'ERROR in update row '||sqlerrm);
END update_rows;

-- This procedure will update  the record in pa_schedules table
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Schedule_Id                NUMBER         YES      Id for the corresponding schedule
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignmen
-- P_Assignment_Id              NUMBER         YES      Assignment id of the schedule records
-- P_Project_Id                 NUMBER         YES      project id of the associated calendar
-- P_Schedule_Type_Code         VARCHAR2       YES      It is schedule type code e.g changed hours/changed duration
-- P_Assignment_Status_Code     VARCHAR2       YES      Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Start_Date                 DATE           YES      stat date of the schedule
-- P_End_Date                   DATE           YES      end date of the schedule
-- P_Monday_Hours               NUMBER         YES      No. of hours of this day
-- P_Tuesday_Hours              NUMBER         YES      No. of hours of this day
-- P_Wednesday_Hours            NUMBER         YES      No. of hours of this day
-- P_Thursday_Hours             NUMBER         YES      No. of hours of this day
-- P_Friday_Hours               NUMBER         YES      No. of hours of this day
-- P_Saturday_Hours             NUMBER         YES      No. of hours of this day
-- P_Sunday_Hours               NUMBER         YES      No. of hours of this day
--

PROCEDURE update_rows
        ( p_schedule_id                    IN NUMBER                      ,
        p_calendar_id                      IN Number   Default null       ,
        p_assignment_id                    IN Number   Default null       ,
        p_project_id                       IN Number   Default null       ,
        p_schedule_type_code               IN varchar2 Default null       ,
        p_assignment_status_code           IN varchar2 Default null       ,
        p_start_date                       IN date     Default null       ,
        p_end_date                         IN date     Default null       ,
        p_monday_hours                     IN Number   Default null       ,
        p_tuesday_hours                    IN Number   Default null       ,
        p_wednesday_hours                  IN Number   Default null       ,
        p_thursday_hours                   IN Number   Default null       ,
        p_friday_hours                     IN Number   Default null       ,
        p_saturday_hours                   IN Number   Default null       ,
        p_sunday_hours                     IN Number   Default null       ,
        x_return_status              OUT  NOCOPY VARCHAR2                        , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                          , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN

  x_return_status := FND_API.G_RET_STS_SUCCESS;
 UPDATE PA_SCHEDULES
 SET
        calendar_id             = p_calendar_id,
        assignment_id           = p_assignment_id,
        project_id              = p_project_id,
        schedule_type_code      = p_schedule_type_code,
        status_code             = p_assignment_status_code,
        start_date              = trunc(p_start_date),
        end_date                = trunc(p_end_date),
        monday_hours            = p_monday_hours,
        tuesday_hours           = p_tuesday_hours,
        wednesday_hours         = p_wednesday_hours,
        thursday_hours          = p_thursday_hours,
        friday_hours            = p_friday_hours,
        saturday_hours          = p_saturday_hours,
        sunday_hours            = p_sunday_hours,
        last_update_date        = sysdate ,
        last_update_by          = fnd_global.user_id,
        last_update_login       = fnd_global.login_id
 WHERE  schedule_id = p_schedule_id;


EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;

-- This procedure will update  the record in pa_schedules table
-- Input parameters
-- Parameters                   Type           Required Description
-- P_Schrowid                   ROWID          YES      Row id for the corresponding schedule row
-- P_Calendar_Id                NUMBER         YES      Id for that calendar which is associated to this assignmen
-- P_Assignment_Id              NUMBER         YES      Assignment id of the schedule records
-- P_Project_Id                 NUMBER         YES      project id of the associated calendar
-- P_Schedule_Type_Code         VARCHAR2       YES      It is schedule type code e.g changed hours/changed duration
-- P_Assignment_Status_Code     VARCHAR2       YES      Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Start_Date                 DATE           YES      stat date of the schedule
-- P_End_Date                   DATE           YES      end date of the schedule
-- P_Monday_Hours               NUMBER         YES      No. of hours of this day
-- P_Tuesday_Hours              NUMBER         YES      No. of hours of this day
-- P_Wednesday_Hours            NUMBER         YES      No. of hours of this day
-- P_Thursday_Hours             NUMBER         YES      No. of hours of this day
-- P_Friday_Hours               NUMBER         YES      No. of hours of this day
-- P_Saturday_Hours             NUMBER         YES      No. of hours of this day
-- P_Sunday_Hours               NUMBER         YES      No. of hours of this day
--

PROCEDURE update_rows
        ( p_schrowid                       IN rowid                       ,
        p_schedule_id                      IN NUMBER                      ,
        p_calendar_id                      IN Number   Default null       ,
        p_assignment_id                    IN Number   Default null       ,
        p_project_id                       IN Number   Default null       ,
        p_schedule_type_code               IN varchar2 Default null       ,
        p_assignment_status_code           IN varchar2 Default null       ,
        p_start_date                       IN date     Default null       ,
        p_end_date                         IN date     Default null       ,
        p_monday_hours                     IN Number   Default null       ,
        p_tuesday_hours                    IN Number   Default null       ,
        p_wednesday_hours                  IN Number   Default null       ,
        p_thursday_hours                   IN Number   Default null       ,
        p_friday_hours                     IN Number   Default null       ,
        p_saturday_hours                   IN Number   Default null       ,
        p_sunday_hours                     IN Number   Default null       ,
        x_return_status              OUT  NOCOPY VARCHAR2                        , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER                          , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

 UPDATE PA_SCHEDULES
 SET
        calendar_id             = p_calendar_id,
        assignment_id           = p_assignment_id,
        project_id              = p_project_id,
        schedule_type_code      = p_schedule_type_code,
        status_code             = p_assignment_status_code,
        start_date              = trunc(p_start_date),
        end_date                = trunc(p_end_date),
        monday_hours            = p_monday_hours,
        tuesday_hours           = p_tuesday_hours,
        wednesday_hours         = p_wednesday_hours,
        thursday_hours          = p_thursday_hours,
        friday_hours            = p_friday_hours,
        saturday_hours          = p_saturday_hours,
        sunday_hours            = p_sunday_hours,
        last_update_date        = sysdate ,
        last_update_by          = fnd_global.user_id,
        last_update_login       = fnd_global.login_id
 WHERE  schedule_id = p_schedule_id;


EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'update_rows');
 raise;

END update_rows;

-- This procedure will delete  the record in pa_schedules table
-- Input parameters
-- Parameters                   Type                Required  Description
-- P_Sch_Record_Tab             ScheduleTabTyp      YES       It contains the schedule record
--

PROCEDURE delete_rows ( p_sch_record_tab         IN   PA_SCHEDULE_GLOB.ScheduleTabTyp,
                        x_return_status              OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                        x_msg_count                  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
        l_schedule_id              PA_PLSQL_DATATYPES.IdTabTyp;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

PA_SCHEDULE_UTILS.log_message(1,'start of the delete row ..... ');
if ( p_sch_record_tab.count = 0 ) then
    PA_SCHEDULE_UTILS.log_message(1,'count 0 ... and returning ');
    raise l_empty_tab_record;
end if;

FOR J IN p_sch_record_tab.first..p_sch_record_tab.last LOOP
PA_SCHEDULE_UTILS.log_message(1,' I : '||to_char(J)||' sch_id '||to_char(p_sch_record_tab(J).schedule_id));
l_schedule_id(J) := p_sch_record_tab(J).schedule_id;

END LOOP;

FORALL J IN l_schedule_id.first..l_schedule_id.last
DELETE FROM PA_SCHEDULES WHERE schedule_id = l_schedule_id(J);

PA_SCHEDULE_UTILS.log_message(1,'end  of the delete row ..... ');
EXCEPTION
 WHEN l_empty_tab_record THEN
  NULL;
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'delete_rows');
 raise;

PA_SCHEDULE_UTILS.log_message(1,'ERROR in the delete row ..... '||sqlerrm);
END delete_rows;

-- This procedure will delete  the record in pa_schedules table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Schedule_Id                NUMBER         YES       Schedule id for deletion
--

PROCEDURE delete_rows
        ( p_schedule_id                    IN Number          ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

DELETE
  FROM PA_SCHEDULES
  WHERE schedule_id = p_schedule_id;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'delete_rows');
 raise;

END delete_rows;

-- This procedure will delete  the record in pa_schedules table
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Schrowid                   ROWID          YES        rowid of the schedule record for deletion
--

PROCEDURE delete_rows
        ( p_schrowid                       IN rowid          ,
        x_return_status              OUT  NOCOPY VARCHAR2          , --File.Sql.39 bug 4440895
        x_msg_count                  OUT  NOCOPY NUMBER            , --File.Sql.39 bug 4440895
        x_msg_data                   OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;

DELETE
  FROM PA_SCHEDULES
  WHERE rowid = p_schrowid ;

EXCEPTION
 WHEN OTHERS THEN
  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
 FND_MSG_PUB.add_exc_msg( p_pkg_name           => 'PA_SCHEDULE_PKG',
                           p_procedure_name     => 'delete_rows');
 raise;

END delete_rows;
END PA_SCHEDULE_PKG;

/
