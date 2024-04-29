--------------------------------------------------------
--  DDL for Package Body PA_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_SCHEDULE_PUB" as
	/* $Header: PARGPUBB.pls 120.11.12010000.11 2010/06/21 12:50:38 nisinha ship $ */

l_out_of_range_date        EXCEPTION; -- Exception variable for raising the exception when date is out of range
l_out_of_range_from_date   EXCEPTION; -- Exception variable for raising the exception when date is out of range
l_out_of_range_to_date     EXCEPTION; -- Exception variable for raising the exception when date is out of range
l_empty_tab_record         EXCEPTION; --  Variable to raise the exception if  the passing table of records is empty
l_x_return_status          VARCHAR2(50);
l_from_to_date_null        EXCEPTION;  -- This exception is raise when the start date or end date is null
l_asgn_stus_not_for_proj_stus EXCEPTION; -- Exception variable for raising the exception when the assignment status is not allowed for the project status

-- procedure     : update_schedule
-- Purpose       : This procedure will change the schedule records of the assignments passed in.
--                 It can accept either one assignment ID or an assignment ID array.
--
-- Input parameters
-- Parameters                   Type     Required  Description
-- ---------------------------  ------   --------  --------------------------------------------------------
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this assignment

PROCEDURE update_schedule
( p_project_id                    IN  NUMBER
 ,p_mass_update_flag              IN  VARCHAR2         := FND_API.G_FALSE
 ,p_exception_type_code           IN  VARCHAR2
 ,p_record_version_number         IN  NUMBER           := NULL
 ,p_assignment_id                 IN  NUMBER           := NULL
 ,p_assignment_id_array           IN  SYSTEM.PA_NUM_TBL_TYPE := NULL
 ,p_change_start_date             IN  DATE             := NULL
 ,p_change_end_date               IN  DATE             := NULL
 ,p_requirement_status_code       IN  VARCHAR2         := NULL
 ,p_assignment_status_code        IN  VARCHAR2         := NULL
 ,p_monday_hours                  IN  NUMBER           := NULL
 ,p_tuesday_hours                 IN  NUMBER           := NULL
 ,p_wednesday_hours               IN  NUMBER           := NULL
 ,p_thursday_hours                IN  NUMBER           := NULL
 ,p_friday_hours                  IN  NUMBER           := NULL
 ,p_saturday_hours                IN  NUMBER           := NULL
 ,p_sunday_hours                  IN  NUMBER           := NULL
 ,p_non_working_day_flag          IN  VARCHAR2         := 'N'
 ,p_change_hours_type_code        IN  VARCHAR2         := NULL
 ,p_hrs_per_day                   IN  NUMBER           := NULL
 ,p_calendar_percent              IN  NUMBER           := NULL
 ,p_change_calendar_type_code     IN  VARCHAR2         := NULL
 ,p_change_calendar_name          IN  VARCHAR2         := NULL
 ,p_change_calendar_id            IN  NUMBER           := NULL
 ,p_duration_shift_type_code      IN  VARCHAR2         := NULL
 ,p_duration_shift_unit_code      IN  VARCHAR2         := NULL
 ,p_number_of_shift               IN  NUMBER           := NULL
 ,p_last_row_flag                 IN  VARCHAR2         := 'Y'
 ,p_change_start_date_tbl         IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_change_end_date_tbl           IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_monday_hours_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_tuesday_hours_tbl             IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_wednesday_hours_tbl           IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_thursday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_friday_hours_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_saturday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_sunday_hours_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_commit                        IN  VARCHAR2         := FND_API.G_FALSE
 ,p_validate_only                 IN  VARCHAR2         := FND_API.G_TRUE
 ,p_called_by_proj_party          IN  VARCHAR2         := 'N' -- Added for Bug 6631033
 ,x_return_status                 OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT NOCOPY NUMBER         --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  l_err_msg_code             fnd_new_messages.message_name%TYPE;
  l_updated_calendar_id      NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_msg_index_out	     NUMBER;
  l_change_calendar_id       NUMBER;
  l_valid_assign_start_flag  VARCHAR2(1) := 'Y';    -- Bug 6411422
  l_profile_begin_date       DATE;                  -- Bug 6411422

BEGIN
  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS ;



  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_SCHEDULE_PUB.update_schedule');

  -- Issue API savepoint if the transaction is to be committed
  IF (p_commit = FND_API.G_TRUE) THEN
    SAVEPOINT SCH_PUB_UPDATE_SCH;
  END IF;

  -- Bug 6411422
  l_valid_assign_start_flag := PA_PROJECT_DATES_UTILS.IS_VALID_ASSIGN_START_DATE( p_project_id        => p_project_id,
                                                                                    p_assign_start_date => p_change_start_date ) ;
    IF ( l_valid_assign_start_flag = 'Y' )
  THEN -- Bug 6411422

  pa_schedule_utils.debug('pa.plsql.pa_schedule_pub', 'Start online validation', 6);
  ----------------------------------------------------------------------------------------------
  --
  --  On Line Validation
  --
  ----------------------------------------------------------------------------------------------

  -- If this api has been called from the page which has start_date, end_date input
  IF (p_exception_type_code = 'CHANGE_DURATION' OR p_exception_type_code = 'CHANGE_HOURS' OR
      p_exception_type_code = 'CHANGE_WORK_PATTERN' OR p_exception_type_code = 'CHANGE_STATUS') THEN

      -- If p_exception_type_code = 'CHANGE_DURATION', at least one of start_date or end_date
      -- should not be null. The reason is that if both are null, actually it wouldn't update anything.
      IF (p_exception_type_code = 'CHANGE_DURATION' AND
          p_change_start_date IS NULL AND p_change_end_date IS NULL) THEN
          PA_UTILS.Add_Message ('PA', 'PA_SCH_FROM_OR_TO_DATE_NULL');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- If p_exception_type_code = 'CHANGE_HOURS' or 'CHANGE_WORK_PATTERN' or 'CHANGE_STATUS',
      -- End date or Start date should not be null.
      IF ( (p_exception_type_code = 'CHANGE_HOURS' OR p_exception_type_code = 'CHANGE_WORK_PATTERN' OR
            p_exception_type_code = 'CHANGE_STATUS') AND
           (p_change_start_date IS NULL OR p_change_end_date IS NULL) )THEN
          PA_UTILS.Add_Message ('PA', 'PA_SCH_FROM_TO_DATE_NULL');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     -- If this api has been called from the page which has start_date, end_date input, call
      -- the validation date procedure. It will validate the date i.e. start_date should not be greater
      -- than end_date. If end date date greater than start_date, then it will return l_x_return_status as error.
      PA_SCHEDULE_UTILS.validate_date_range (p_change_start_date, p_change_end_date, l_x_return_status, l_err_msg_code);

      -- If validate_date_range fails, put error message into error stack and stop to process.
      IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
         PA_UTILS.Add_Message ('PA', l_err_msg_code);
         RAISE FND_API.G_EXC_ERROR;
      END IF;
  END IF;

  -- If p_exception_type_code = 'SHIFT_DURATION' then throw exception in following cases.
  -- single update: if 'status for new days'(p_assignment_status_code) is null. (-> this field
  --                should be required on front end)
  -- mass update: if both 'p_requirement_status_code' and 'p_assignment_status_code' are null.
  -- Modified below code for 7663765
  IF ( (p_exception_type_code = 'SHIFT_DURATION' OR p_exception_type_code = 'CHANGE_STATUS'  OR p_exception_type_code = 'DURATION_PATTERN_SHIFT') AND
       (p_requirement_status_code is NULL AND p_assignment_status_code is NULL AND
        p_mass_update_flag = FND_API.G_TRUE) ) THEN
      PA_UTILS.Add_Message ('PA', 'PA_SCH_ASGN_STATUS_NULL');
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  -- validations when p_exception_type_code = 'CHANGE_HOURS'
  IF (p_exception_type_code = 'CHANGE_HOURS') THEN

      -- Checking that if the we want to change the hours by taking the hours type code as HOURS
      -- then the hours per day should not be null and should not beyond the 0 to 24 hours
      --  same with the PERCENTAGE then calendar percentage should not be null and should not beyond the
      --  the 0 to 100 percent
      IF (p_change_hours_type_code = 'HOURS') THEN

          IF (p_hrs_per_day IS NULL) THEN
              PA_UTILS.Add_Message ('PA', 'PA_SCH_HOURS_NULL');
              RAISE FND_API.G_EXC_ERROR;
	  ELSIF (p_hrs_per_day NOT BETWEEN 0 AND 24 ) THEN
              PA_UTILS.Add_Message ('PA', 'PA_SCH_HOURS_OUT_OF_RANGE');
              RAISE FND_API.G_EXC_ERROR;
	  END IF;

      ELSIF (p_change_hours_type_code = 'PERCENTAGE') THEN
	  IF (p_calendar_percent IS NULL) THEN
              PA_UTILS.Add_Message ('PA', 'PA_SCH_PERCENTAGE_NULL');
              RAISE FND_API.G_EXC_ERROR;
	  ELSIF (p_calendar_percent NOT BETWEEN 0 AND 100 ) THEN
              PA_UTILS.Add_Message ('PA', 'PA_SCH_PERCENTAGE_OUT_OF_RANGE');
              RAISE FND_API.G_EXC_ERROR;
	  END IF;

          -- Value/ID validation for calendar_name/id entered through 'OTHER' text input field on
          -- the Update Hours Of Days screen.
          IF (p_change_calendar_type_code = 'OTHER')  THEN

              -- IF both calendar_name and calendar_id are null, error out.
              IF (p_change_calendar_name is NULL AND p_change_calendar_id IS NULL) THEN
                  PA_UTILS.Add_Message ('PA', 'PA_OTHER_CALENDAR_NULL');
                  RAISE FND_API.G_EXC_ERROR;
              END IF;

              PA_CALENDAR_UTILS.Check_Calendar_Name_Or_Id(
                      					  p_calendar_id         => p_change_calendar_id
     	          					 ,p_calendar_name       => p_change_calendar_name
 							 ,p_check_id_flag       => 'N'
	    					         ,x_calendar_id         => l_change_calendar_id
	      						 ,x_return_status       => l_x_return_status
	   					         ,x_error_message_code  => l_err_msg_code);

              -- If calendar_name/id validation fails, put error message into error stack.
              IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                  PA_UTILS.Add_Message ('PA', l_err_msg_code);
                  RAISE FND_API.G_EXC_ERROR;
              END IF;
          END IF; --  IF(p_change_calendar_type_code = 'OTHER')
      END IF; -- ELSIF (p_change_hours_type_code = 'PERCENTAGE')

  END IF; -- p_exception_type_code = 'CHANGE_HOURS'

  -- validations when p_exception_type_code = 'CHANGE_WORK_PATTERN'
  IF (p_exception_type_code = 'CHANGE_WORK_PATTERN') THEN

      -- If all of working hours are null, error out.
      IF (p_monday_hours IS NULL    AND p_tuesday_hours IS NULL  AND
          p_wednesday_hours IS NULL AND p_thursday_hours IS NULL AND
          p_friday_hours IS NULL    AND p_saturday_hours IS NULL AND
          p_sunday_hours IS NULL) THEN
            PA_UTILS.Add_Message ('PA', 'PA_SCH_HOURS_ALL_NULL');
            RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- if anyday hours is not null and not valid number(between 0 and 24), throw an errors.
      IF ( (p_monday_hours IS NOT NULL AND (p_monday_hours NOT BETWEEN 0 AND 24))       OR
           (p_tuesday_hours IS NOT NULL AND (p_tuesday_hours NOT BETWEEN 0 AND 24))     OR
           (p_wednesday_hours IS NOT NULL AND (p_wednesday_hours NOT BETWEEN 0 AND 24)) OR
           (p_thursday_hours IS NOT NULL AND (p_thursday_hours NOT BETWEEN 0 AND 24))   OR
           (p_friday_hours IS NOT NULL AND (p_friday_hours NOT BETWEEN 0 AND 24))       OR
           (p_saturday_hours IS NOT NULL AND (p_saturday_hours NOT BETWEEN 0 AND 24))   OR
           (p_sunday_hours IS NOT NULL AND (p_sunday_hours NOT BETWEEN 0 AND 24)) )  THEN
            PA_UTILS.Add_Message ('PA', 'PA_SCH_HOURS_OUT_OF_RANGE');
            RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Cross-row validation when p_last_row_flag = 'Y'
      IF p_change_start_date_tbl IS NOT NULL THEN
      IF p_last_row_flag = 'Y' and p_change_start_date_tbl.COUNT > 1 THEN
        FOR i IN p_change_start_date_tbl.FIRST .. p_change_start_date_tbl.LAST LOOP
          FOR j IN i+1 .. p_change_start_date_tbl.LAST LOOP
            IF ((p_change_start_date_tbl(j) >= p_change_start_date_tbl(i) AND p_change_start_date_tbl(j) <= p_change_end_date_tbl(i))
              OR (p_change_end_date_tbl(j) >= p_change_start_date_tbl(i) AND p_change_end_date_tbl(j) <= p_change_end_date_tbl(i))
              OR (p_change_start_date_tbl(j) <= p_change_start_date_tbl(i) AND p_change_end_date_tbl(j) >= p_change_end_date_tbl(i))
              OR (p_change_start_date_tbl(j) >= p_change_start_date_tbl(i) AND p_change_end_date_tbl(j) <= p_change_end_date_tbl(i)))
            THEN
              PA_UTILS.Add_Message ('PA', 'PA_SCH_OVERLAP_WORK_PATTERN');
              RAISE FND_API.G_EXC_ERROR;
            END IF;
          END LOOP;
        END LOOP;
      END IF;
      END IF;

  END IF; -- p_exception_type_code = 'CHANGE_WORK_PATTERN'

  ----------------------------------------------------------------------------------------------
  --
  --  'Continue and Submit' button? => return
  --
  ----------------------------------------------------------------------------------------------

  -- If p_validate_only = 'T', it won't do anything other than on line validation i.e. validate_date_range.
  -- From the Update Schedule page,
  --     p_validate_only = 'T' : 'Continue and Submit' button
  --     p_validate_only = 'F' : 'Apply' button
  IF (p_validate_only = FND_API.G_TRUE) THEN
     RETURN;
  END IF;

  ----------------------------------------------------------------------------------------------
  --
  --  Mass Schedule Update
  --
  ----------------------------------------------------------------------------------------------
  -- If this is for Mass schedule update, call Mass Transaction Workflow.
  IF (p_mass_update_flag = FND_API.G_TRUE AND p_last_row_flag = 'Y') THEN
       --start the mass WF
       PA_MASS_ASGMT_TRX.Start_Mass_Asgmt_Trx_Wf(
          p_mode                        => PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE
         ,p_action                      => PA_MASS_ASGMT_TRX.G_SAVE
         ,p_project_id                  => p_project_id
         ,p_exception_type_code         => p_exception_type_code
         ,p_assignment_id_tbl           => p_assignment_id_array
         ,p_change_start_date           => p_change_start_date
         ,p_change_end_date             => p_change_end_date
         ,p_change_rqmt_status_code     => p_requirement_status_code
         ,p_change_asgmt_status_code    => p_assignment_status_code
         ,p_change_start_date_tbl       => p_change_start_date_tbl
         ,p_change_end_date_tbl         => p_change_end_date_tbl
         ,p_monday_hours_tbl            => p_monday_hours_tbl
         ,p_tuesday_hours_tbl           => p_tuesday_hours_tbl
         ,p_wednesday_hours_tbl         => p_wednesday_hours_tbl
         ,p_thursday_hours_tbl          => p_thursday_hours_tbl
         ,p_friday_hours_tbl            => p_friday_hours_tbl
         ,p_saturday_hours_tbl          => p_saturday_hours_tbl
         ,p_sunday_hours_tbl            => p_sunday_hours_tbl
         ,p_non_working_day_flag        => p_non_working_day_flag
         ,p_change_hours_type_code      => p_change_hours_type_code
         ,p_hrs_per_day                 => p_hrs_per_day
         ,p_calendar_percent            => p_calendar_percent
         ,p_change_calendar_type_code   => p_change_calendar_type_code
         ,p_change_calendar_name        => p_change_calendar_name
         ,p_change_calendar_id          => p_change_calendar_id
         ,p_duration_shift_type_code    => p_duration_shift_type_code
         ,p_duration_shift_unit_code    => p_duration_shift_unit_code
         ,p_num_of_shift                => p_number_of_shift
         ,x_return_status               => l_x_return_status  );


  ----------------------------------------------------------------------------------------------
  --
  --  Single Schedule Update
  --
  ----------------------------------------------------------------------------------------------
  -- If this is for Single schedule update, call an appropriate procedure depends on
  -- p_exception_type_code.
  ELSIF (p_mass_update_flag = FND_API.G_FALSE) THEN
     -- call execute_update_schedule procedure for single schedule update.

     pa_schedule_utils.debug('pa.plsql.pa_schedule_pub', 'Calling single_update_schedule', 6);

     single_update_schedule (
			  p_project_id                 => p_project_id
       ,p_exception_type_code        => p_exception_type_code
			 ,p_record_version_number      => p_record_version_number
			 ,p_assignment_id              => p_assignment_id
			 ,p_change_start_date          => p_change_start_date
			 ,p_change_end_date            => p_change_end_date
			 ,p_assignment_status_code     => p_assignment_status_code
			 ,p_monday_hours               => p_monday_hours
			 ,p_tuesday_hours              => p_tuesday_hours
	 		 ,p_wednesday_hours            => p_wednesday_hours
	 		 ,p_thursday_hours             => p_thursday_hours
			 ,p_friday_hours               => p_friday_hours
			 ,p_saturday_hours             => p_saturday_hours
	 		 ,p_sunday_hours               => p_sunday_hours
			 ,p_non_working_day_flag       => p_non_working_day_flag
	 		 ,p_change_hours_type_code     => p_change_hours_type_code
	 		 ,p_hrs_per_day                => p_hrs_per_day
	 		 ,p_calendar_percent           => p_calendar_percent
			 ,p_change_calendar_type_code  => p_change_calendar_type_code
			 --,p_change_calendar_name       => p_change_calendar_name
			 ,p_change_calendar_id         => l_change_calendar_id
       ,p_duration_shift_type_code   => p_duration_shift_type_code
       ,p_duration_shift_unit_code   => p_duration_shift_unit_code
       ,p_number_of_shift            => p_number_of_shift
       ,p_last_row_flag              => p_last_row_flag
       ,p_init_msg_list              => FND_API.G_TRUE
       ,p_commit                     => FND_API.G_FALSE
       ,p_called_by_proj_party       => p_called_by_proj_party -- Added for Bug 6631033
			 ,x_return_status              => l_x_return_status
			 ,x_msg_count                  => l_msg_count
			 ,x_msg_data                   => l_msg_data);
  END IF;

  -- If the called API fails, raise an exception.
  IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

  ELSE  -- Bug 6411422

    --l_profile_begin_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY'); /* commenting for For Bug 7304151 */
    l_profile_begin_date := to_date(fnd_profile.value('PA_UTL_START_DATE'), 'DD/MM/YYYY', 'NLS_DATE_LANGUAGE=AMERICAN');  /*Adding For Bug 7304151*/
    PA_UTILS.Add_Message( p_app_short_name => 'PA'
                                    ,p_msg_name => 'PA_INVALID_ASSIGN_START_DATE'
                                    ,p_token1   => 'PROFILE_DATE'
                                    ,p_value1   => l_profile_begin_date );
    RAISE FND_API.G_EXC_ERROR;

  END IF;  -- Bug 6411422

  ----------------------------------------------------------------------------------------------
  --
  --  Exception Handling
  --
  ----------------------------------------------------------------------------------------------
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := FND_MSG_PUB.Count_Msg;

       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
	        	(p_encoded       => FND_API.G_TRUE,
		         p_msg_index      => 1,
        	         p_data           => x_msg_data,
		         p_msg_index_out  => l_msg_index_out );
       END IF;

    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO SCH_PUB_UPDATE_SCH;
        END IF;

	-- 4537865 : RESET x_msg_data also.
	x_msg_data := SUBSTRB(SQLERRM,1,240);

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PUB'
                                ,p_procedure_name => 'execute_update_schedule'
				,p_error_text	  => x_msg_data ); -- 4537865

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_count := 1;

        RAISE;  -- This is optional depending on the needs

END update_schedule;


/*    Bug 7693634  Start     */

PROCEDURE update_schedule_bulk
( p_project_id_tbl                    IN  SYSTEM.PA_NUM_TBL_TYPE
 ,p_mass_update_flag_tbl              IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  --       := FND_API.G_FALSE
 ,p_exception_type_code_tbl           IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
 ,p_record_version_number_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,p_assignment_id_tbl                 IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,p_change_start_date_tbl             IN  SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_change_end_date_tbl               IN  SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_requirement_status_code_tbl       IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_assignment_status_code_tbl        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_last_row_flag_tbl                 IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := 'Y'
 ,p_commit_tbl                        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := FND_API.G_FALSE
 ,p_validate_only_tbl                 IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := FND_API.G_TRUE
 ,p_msg_data_in_tbl                   IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
 ,x_return_status_tbl                 OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --File.Sql.39 bug 4440895
 ,x_msg_count_tbl                     OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE         --File.Sql.39 bug 4440895
 ,x_msg_data_tbl                      OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE ) --File.Sql.39 bug 4440895
IS

  l_err_msg_code             fnd_new_messages.message_name%TYPE;
  l_updated_calendar_id      NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_msg_index_out	     NUMBER;
  l_change_calendar_id       NUMBER;
  l_valid_assign_start_flag  VARCHAR2(1) := 'Y';    -- Bug 6411422
  l_profile_begin_date       DATE;                  -- Bug 6411422

  /*   7693634 new variables */
  l_mass_update_flag_tbl        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_mass_update_flag_tbl;
  l_last_row_flag_tbl           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_mass_update_flag_tbl;
  l_commit_tbl                  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_commit_tbl;
  l_validate_only_tbl           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_validate_only_tbl;


l_msg_count_tbl         SYSTEM.PA_NUM_TBL_TYPE := p_project_id_tbl;
l_return_status_tbl     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_validate_only_tbl;
l_msg_data_tbl          SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_validate_only_tbl;
--Bug#9817752 start
l_assignment_type       pa_project_assignments.assignment_type%TYPE :=NULL ;
l_assignment_status_code VARCHAR2(50) := NULL;
--Bug#9817752 end


BEGIN
fnd_msg_pub.initialize;  -- 8233045

PA_SCHEDULE_PUB.G_update_schedule_bulk_call := 'Y';  -- 8233045

/*  Initializing some of the parameters  */
for k in p_project_id_tbl.first .. p_project_id_tbl.last loop

if (   p_msg_data_in_tbl(k) is null
    or p_msg_data_in_tbl(k) = 'StartDateWarning'
    or p_msg_data_in_tbl(k) = 'EndDateWarning') then
  l_mass_update_flag_tbl(k)   :=  p_mass_update_flag_tbl(k);
  if l_mass_update_flag_tbl(k) is null then
    l_mass_update_flag_tbl(k)     := FND_API.G_FALSE;
  end if;

  l_last_row_flag_tbl(k)  := p_last_row_flag_tbl(k);
  if l_last_row_flag_tbl(k) is null then
    l_last_row_flag_tbl(k)  := 'Y';
  end if;

  l_commit_tbl(k)   := p_commit_tbl(k);
  if l_commit_tbl(k) is null then
    l_commit_tbl(k)  := FND_API.G_FALSE;
  end if;

  l_validate_only_tbl(k)  := p_validate_only_tbl(k);
  if l_validate_only_tbl(k) is null then
     l_validate_only_tbl(k) := FND_API.G_TRUE;
  end if;

end if;
end loop;

for k in p_project_id_tbl.first .. p_project_id_tbl.last loop

if (   p_msg_data_in_tbl(k) is null
    or p_msg_data_in_tbl(k) = 'StartDateWarning'
    or p_msg_data_in_tbl(k) = 'EndDateWarning') then

BEGIN
  -- Initialize the return status to success
  l_return_status_tbl(k) := FND_API.G_RET_STS_SUCCESS ;

  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_SCHEDULE_PUB.update_schedule');

  -- Issue API savepoint if the transaction is to be committed
  IF (l_commit_tbl(k) = FND_API.G_TRUE) THEN
    SAVEPOINT SCH_PUB_UPDATE_SCH;
  END IF;


  ----------------------------------------------------------------------------------------------
  --
  --  Mass Schedule Update
  --
  ----------------------------------------------------------------------------------------------
  -- If this is for Mass schedule update, call Mass Transaction Workflow.
  IF (l_mass_update_flag_tbl(k) = FND_API.G_TRUE AND l_last_row_flag_tbl(k) = 'Y') THEN
       PA_MASS_ASGMT_TRX.Start_Mass_Asgmt_Trx_Wf(
          p_mode                        => PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE
         ,p_action                      => PA_MASS_ASGMT_TRX.G_SAVE
         ,p_project_id                  => p_project_id_tbl(k)
         ,p_exception_type_code         => p_exception_type_code_tbl(k)
--         ,p_assignment_id_tbl           => p_assignment_id_array_tbl(k)
         ,p_change_start_date           => p_change_start_date_tbl(k)
         ,p_change_end_date             => p_change_end_date_tbl(k)
         ,p_change_rqmt_status_code     => p_requirement_status_code_tbl(k)
         ,p_change_asgmt_status_code    => p_assignment_status_code_tbl(k)
         ,x_return_status               => l_x_return_status  );

  ----------------------------------------------------------------------------------------------
  --
  --  Single Schedule Update
  --
  ----------------------------------------------------------------------------------------------
  -- If this is for Single schedule update, call an appropriate procedure depends on
  -- p_exception_type_code.
  ELSIF (l_mass_update_flag_tbl(k) = FND_API.G_FALSE) THEN
     -- call execute_update_schedule procedure for single schedule update.
--Bug#9817752 start
      -- For new period of schedule generated from update scheduled people page, the status should always be Provisional
       IF PA_ASSIGNMENTS_PUB.G_update_assignment_bulk_call = 'Y' THEN
         SELECT Assignment_type
         INTO l_assignment_type
         FROM pa_project_assignments
         WHERE assignment_id= p_assignment_id_tbl(k);

         pa_schedule_utils.debug('pa.plsql.pa_schedule_pub.update_schedule_bulk', 'Assignment_type:'||l_assignment_type, 6);
         IF  l_assignment_type  IN ('STAFFED_ASSIGNMENT','STAFFED_ADMIN_ASSIGNMENT') THEN
           l_assignment_status_code := '104';
         END IF;
       END IF;

      pa_schedule_utils.debug('pa.plsql.pa_schedule_pub.update_schedule_bulk', 'Calling single_update_schedule', 6);

--Bug#9817752 end


     single_update_schedule (
              p_project_id                 => p_project_id_tbl(k)
             ,p_exception_type_code        => p_exception_type_code_tbl(k)
             ,p_record_version_number      => p_record_version_number_tbl(k)
             ,p_assignment_id              => p_assignment_id_tbl(k)
             ,p_change_start_date          => p_change_start_date_tbl(k)
             ,p_change_end_date            => p_change_end_date_tbl(k)
             ,p_assignment_status_code     => Nvl(l_assignment_status_code,p_assignment_status_code_tbl(k))
             ,p_init_msg_list              => FND_API.G_TRUE
             ,p_commit                     => l_commit_tbl(k)
             ,x_return_status              => l_x_return_status
             ,x_msg_count                  => l_msg_count
             ,x_msg_data                   => l_msg_data);
l_msg_data_tbl(k) := l_msg_data;
  END IF;

  -- If the called API fails, raise an exception.
  IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


x_msg_count_tbl      := l_msg_count_tbl;
x_return_status_tbl  := l_return_status_tbl;
x_msg_data_tbl       := l_msg_data_tbl;
  ----------------------------------------------------------------------------------------------
  --
  --  Exception Handling
  --
  ----------------------------------------------------------------------------------------------
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       l_return_status_tbl(k) := FND_API.G_RET_STS_ERROR;
       l_msg_count_tbl(k) := FND_MSG_PUB.Count_Msg;

       IF l_msg_count_tbl(k) = 1 THEN
          pa_interface_utils_pub.get_messages
                (p_encoded       => FND_API.G_TRUE,
                 p_msg_index      => 1,
                     p_data           => l_msg_data_tbl(k),
                 p_msg_index_out  => l_msg_index_out );
       END IF;
       x_msg_count_tbl      := l_msg_count_tbl;
       x_return_status_tbl  := l_return_status_tbl;
       x_msg_data_tbl       := l_msg_data_tbl;

    WHEN OTHERS THEN
        IF l_commit_tbl(k) = FND_API.G_TRUE THEN
           ROLLBACK TO SCH_PUB_UPDATE_SCH;
        END IF;
    -- 4537865 : RESET x_msg_data also.
    l_msg_data_tbl(k) := SUBSTRB(SQLERRM,1,240);

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PUB'
                                ,p_procedure_name => 'execute_update_schedule'
                ,p_error_text      => l_msg_data_tbl(k) ); -- 4537865

        l_return_status_tbl(k) := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_msg_count_tbl(k) := 1;

        x_msg_count_tbl      := l_msg_count_tbl;
        x_return_status_tbl  := l_return_status_tbl;
        x_msg_data_tbl       := l_msg_data_tbl;

        RAISE;  -- This is optional depending on the needs
  END;

end if;  --   p_msg_data_in_tbl

end loop;

END update_schedule_bulk;

/*    Bug 7693634 End */



PROCEDURE update_new_schedule_bulk
( p_project_id_tbl                    IN  SYSTEM.PA_NUM_TBL_TYPE
 ,p_mass_update_flag_tbl              IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  --       := FND_API.G_FALSE
 ,p_exception_type_code_tbl           IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
 ,p_record_version_number_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,p_assignment_id_tbl                 IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,p_change_start_date_tbl             IN  SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_change_end_date_tbl               IN  SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_requirement_status_code_tbl       IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_assignment_status_code_tbl        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_last_row_flag_tbl                 IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := 'Y'
 ,p_commit_tbl                        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := FND_API.G_FALSE
 ,p_validate_only_tbl                 IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := FND_API.G_TRUE
 ,p_msg_data_in_tbl                   IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  ,p_change_hours_type_code_tbl        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_calendar_percent_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE       := NULL
 ,p_change_calendar_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,x_return_status_tbl                 OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --File.Sql.39 bug 4440895
 ,x_msg_count_tbl                     OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE         --File.Sql.39 bug 4440895
 ,x_msg_data_tbl                      OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  --File.Sql.39 bug 4440895
 )

IS

  l_err_msg_code             fnd_new_messages.message_name%TYPE;
  l_updated_calendar_id      NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_msg_index_out	     NUMBER;
  l_change_calendar_id       NUMBER;
  l_valid_assign_start_flag  VARCHAR2(1) := 'Y';    -- Bug 6411422
  l_profile_begin_date       DATE;                  -- Bug 6411422
  l_change_calendar_type_code VARCHAR2(20);

  /*   7693634 new variables */
  l_mass_update_flag_tbl        SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_mass_update_flag_tbl;
  l_last_row_flag_tbl           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_mass_update_flag_tbl;
  l_commit_tbl                  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_commit_tbl;
  l_validate_only_tbl           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_validate_only_tbl;


l_msg_count_tbl         SYSTEM.PA_NUM_TBL_TYPE := p_project_id_tbl;
l_return_status_tbl     SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_validate_only_tbl;
l_msg_data_tbl          SYSTEM.PA_VARCHAR2_2000_TBL_TYPE := p_validate_only_tbl;



BEGIN
fnd_msg_pub.initialize;  -- 8233045

PA_SCHEDULE_PUB.G_update_schedule_bulk_call := 'Y';  -- 8233045

/*  Initializing some of the parameters  */
for k in p_project_id_tbl.first .. p_project_id_tbl.last loop

if (   p_msg_data_in_tbl(k) is null
    or p_msg_data_in_tbl(k) = 'StartDateWarning'
    or p_msg_data_in_tbl(k) = 'EndDateWarning') then
  l_mass_update_flag_tbl(k)   :=  p_mass_update_flag_tbl(k);
  if l_mass_update_flag_tbl(k) is null then
    l_mass_update_flag_tbl(k)     := FND_API.G_FALSE;
  end if;

  l_last_row_flag_tbl(k)  := p_last_row_flag_tbl(k);
  if l_last_row_flag_tbl(k) is null then
    l_last_row_flag_tbl(k)  := 'Y';
  end if;




  l_commit_tbl(k)   := p_commit_tbl(k);
  if l_commit_tbl(k) is null then
    l_commit_tbl(k)  := FND_API.G_FALSE;
  end if;

  l_validate_only_tbl(k)  := p_validate_only_tbl(k);
  if l_validate_only_tbl(k) is null then
     l_validate_only_tbl(k) := FND_API.G_TRUE;
  end if;

end if;
end loop;

for k in p_project_id_tbl.first .. p_project_id_tbl.last loop

if (   p_msg_data_in_tbl(k) is null
    or p_msg_data_in_tbl(k) = 'StartDateWarning'
    or p_msg_data_in_tbl(k) = 'EndDateWarning') then

BEGIN
  -- Initialize the return status to success
  l_return_status_tbl(k) := FND_API.G_RET_STS_SUCCESS ;

  --Clear the global PL/SQL message table
  FND_MSG_PUB.initialize;

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_SCHEDULE_PUB.update_schedule');

  -- Issue API savepoint if the transaction is to be committed
  IF (l_commit_tbl(k) = FND_API.G_TRUE) THEN
    SAVEPOINT SCH_PUB_UPDATE_SCH;
  END IF;


  ----------------------------------------------------------------------------------------------
  --
  --  Mass Schedule Update
  --
  ----------------------------------------------------------------------------------------------
  -- If this is for Mass schedule update, call Mass Transaction Workflow.
  IF (l_mass_update_flag_tbl(k) = FND_API.G_TRUE AND l_last_row_flag_tbl(k) = 'Y') THEN
       PA_MASS_ASGMT_TRX.Start_Mass_Asgmt_Trx_Wf(
          p_mode                        => PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE
         ,p_action                      => PA_MASS_ASGMT_TRX.G_SAVE
         ,p_project_id                  => p_project_id_tbl(k)
         ,p_exception_type_code         => p_exception_type_code_tbl(k)
--         ,p_assignment_id_tbl           => p_assignment_id_array_tbl(k)
         ,p_change_start_date           => p_change_start_date_tbl(k)
         ,p_change_end_date             => p_change_end_date_tbl(k)
         ,p_change_rqmt_status_code     => p_requirement_status_code_tbl(k)
         ,p_change_asgmt_status_code    => p_assignment_status_code_tbl(k)
         ,x_return_status               => l_x_return_status  );

  ----------------------------------------------------------------------------------------------
  --
  --  Single Schedule Update
  --
  ----------------------------------------------------------------------------------------------
  -- If this is for Single schedule update, call an appropriate procedure depends on
  -- p_exception_type_code.
  ELSIF (l_mass_update_flag_tbl(k) = FND_API.G_FALSE) THEN
     -- call execute_update_schedule procedure for single schedule update.

     pa_schedule_utils.debug('pa.plsql.pa_schedule_pub', 'Calling single_update_schedule', 6);

-- Bug#9710585 START Adding Validation for percent
    IF  (p_change_hours_type_code_tbl(k) = 'PERCENTAGE') THEN
	         IF  (p_calendar_percent_tbl(k) NOT BETWEEN 0 AND 100 ) THEN
              PA_UTILS.Add_Message ('PA', 'PA_SCH_PERCENTAGE_OUT_OF_RANGE');
              RAISE FND_API.G_EXC_ERROR;
	         END IF;
    END IF;
--Bug#9710585 END    Adding Validation for percent
single_update_schedule (
  p_project_id                 => p_project_id_tbl(k)
 ,p_exception_type_code        => p_exception_type_code_tbl(k)
 ,p_record_version_number      => p_record_version_number_tbl(k)
 ,p_assignment_id              => p_assignment_id_tbl(k)
 ,p_change_start_date          => p_change_start_date_tbl(k)
 ,p_change_end_date            => p_change_end_date_tbl(k)
 ,p_assignment_status_code     => p_assignment_status_code_tbl(k)
 ,p_change_hours_type_code     => p_change_hours_type_code_tbl(k)
 ,p_calendar_percent           => p_calendar_percent_tbl(k)
 ,p_change_calendar_id         => p_change_calendar_id_tbl(k)  -- Bug#9710585
 ,p_change_calendar_type_code  => 'OTHER' --Bug#9710585
 ,p_init_msg_list              => FND_API.G_TRUE
 ,p_commit                     => l_commit_tbl(k)
 ,x_return_status              => l_x_return_status
 ,x_msg_count                  => l_msg_count
 ,x_msg_data                   => l_msg_data);

l_msg_data_tbl(k) := l_msg_data;
  END IF;

  -- If the called API fails, raise an exception.
  IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;


x_msg_count_tbl      := l_msg_count_tbl;
x_return_status_tbl  := l_return_status_tbl;
x_msg_data_tbl       := l_msg_data_tbl;
  ----------------------------------------------------------------------------------------------
  --
  --  Exception Handling
  --
  ----------------------------------------------------------------------------------------------
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       l_return_status_tbl(k) := FND_API.G_RET_STS_ERROR;
       l_msg_count_tbl(k) := FND_MSG_PUB.Count_Msg;

       IF l_msg_count_tbl(k) = 1 THEN
          pa_interface_utils_pub.get_messages
                (p_encoded       => FND_API.G_TRUE,
                 p_msg_index      => 1,
                     p_data           => l_msg_data_tbl(k),
                 p_msg_index_out  => l_msg_index_out );
       END IF;
       x_msg_count_tbl      := l_msg_count_tbl;
       x_return_status_tbl  := l_return_status_tbl;
       x_msg_data_tbl       := l_msg_data_tbl;

    WHEN OTHERS THEN
        IF l_commit_tbl(k) = FND_API.G_TRUE THEN
           ROLLBACK TO SCH_PUB_UPDATE_SCH;
        END IF;
    -- 4537865 : RESET x_msg_data also.
    l_msg_data_tbl(k) := SUBSTRB(SQLERRM,1,240);

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PUB'
                                ,p_procedure_name => 'execute_update_schedule'
                ,p_error_text      => l_msg_data_tbl(k) ); -- 4537865

        l_return_status_tbl(k) := FND_API.G_RET_STS_UNEXP_ERROR ;
        l_msg_count_tbl(k) := 1;

        x_msg_count_tbl      := l_msg_count_tbl;
        x_return_status_tbl  := l_return_status_tbl;
        x_msg_data_tbl       := l_msg_data_tbl;

        RAISE;  -- This is optional depending on the needs
  END;

end if;  --   p_msg_data_in_tbl

end loop;

END update_new_schedule_bulk;





-- procedure     : single_update_schedule
-- Purpose       : This procedure will change the schedule records of a single assignment.
--
-- Input parameters
-- Parameters                   Type     Required  Description
-- ---------------------------  ------   --------  --------------------------------------------------------
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this assignment

PROCEDURE single_update_schedule
( p_project_id                    IN  NUMBER
 ,p_exception_type_code           IN  VARCHAR2
 ,p_record_version_number         IN  NUMBER           := NULL
 ,p_assignment_id                 IN  NUMBER           := NULL
 ,p_change_start_date             IN  DATE             := NULL
 ,p_change_end_date               IN  DATE             := NULL
 ,p_assignment_status_code        IN  VARCHAR2         := NULL
 ,p_monday_hours                  IN  NUMBER           := NULL
 ,p_tuesday_hours                 IN  NUMBER           := NULL
 ,p_wednesday_hours               IN  NUMBER           := NULL
 ,p_thursday_hours                IN  NUMBER           := NULL
 ,p_friday_hours                  IN  NUMBER           := NULL
 ,p_saturday_hours                IN  NUMBER           := NULL
 ,p_sunday_hours                  IN  NUMBER           := NULL
 ,p_non_working_day_flag          IN  VARCHAR2         := 'N'
 ,p_change_hours_type_code        IN  VARCHAR2         := NULL
 ,p_hrs_per_day                   IN  NUMBER           := NULL
 ,p_calendar_percent              IN  NUMBER           := NULL
 ,p_change_calendar_type_code     IN  VARCHAR2         := NULL
 --,p_change_calendar_name          IN  VARCHAR2         := NULL
 ,p_change_calendar_id            IN  NUMBER           := NULL
 ,p_duration_shift_type_code      IN  VARCHAR2         := NULL
 ,p_duration_shift_unit_code      IN  VARCHAR2         := NULL
 ,p_number_of_shift               IN  NUMBER           := NULL
 ,p_last_row_flag                 IN  VARCHAR2         := 'Y'
 ,p_init_msg_list                 IN  VARCHAR2         := FND_API.G_FALSE
 ,p_commit                        IN  VARCHAR2         := FND_API.G_FALSE
 ,p_called_by_proj_party          IN  VARCHAR2         := 'N' -- Added for Bug 6631033
 ,x_return_status                 OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT NOCOPY NUMBER         --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  l_err_msg_code             fnd_new_messages.message_name%TYPE;
  l_updated_calendar_id      NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_msg_index_out	     NUMBER;
  l_assignment_type          VARCHAR2(30);
  l_assignment_status_code   VARCHAR2(30);
  l_calendar_id              NUMBER;
  l_cur_asgn_start_date      DATE;
  l_cur_asgn_end_date        DATE;

  -- To get information for the given assignment
  CURSOR get_asgmt_info_csr IS
  	 SELECT assignment_type,
                status_code,
                calendar_id,
                start_date,
                end_date
	 FROM  pa_project_assignments
	 WHERE assignment_id = p_assignment_id;

BEGIN


  --Clear the global PL/SQL message table
  IF (p_init_msg_list = FND_API.G_TRUE)  THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_SCHEDULE_PUB.single_update_schedule');

  -- Issue API savepoint if the transaction is to be committed
  IF p_commit = FND_API.G_TRUE THEN
    SAVEPOINT SCH_PUB_SINGLE_UPDATE_SCH;
  END IF;

  -- Get assignment information to pass to change_XXX apis.
  OPEN get_asgmt_info_csr;
  FETCH get_asgmt_info_csr
  INTO l_assignment_type, l_assignment_status_code,
       l_calendar_id,
       l_cur_asgn_start_date, l_cur_asgn_end_date;
  CLOSE get_asgmt_info_csr;



  -- Call an appropriate procedure depends on p_exception_type_code.
  -- Modified code for 7663765
  IF (p_exception_type_code = 'CHANGE_DURATION' OR p_exception_type_code = 'SHIFT_DURATION'   OR p_exception_type_code = 'DURATION_PATTERN_SHIFT') THEN
      change_duration (
			  p_record_version_number    => p_record_version_number
			 ,p_project_id               => p_project_id
                         ,p_exception_type_code      => p_exception_type_code
			 ,p_calendar_id              => l_calendar_id
			 ,p_assignment_id            => p_assignment_id
			 ,p_assignment_type          => l_assignment_type
			 ,p_start_date               => p_change_start_date
			 ,p_end_date                 => p_change_end_date
			 ,p_assignment_status_code   => p_assignment_status_code
			 ,p_asgn_start_date          => l_cur_asgn_start_date
			 ,p_asgn_end_date            => l_cur_asgn_end_date
                         ,p_duration_shift_type_code => p_duration_shift_type_code
                         ,p_duration_shift_unit_code => p_duration_shift_unit_code
                         ,p_number_of_shift          => p_number_of_shift
			 ,p_called_by_proj_party     => p_called_by_proj_party -- Added for Bug 6631033
			 ,x_return_status            => l_x_return_status
			 ,x_msg_count                => l_msg_count
			 ,x_msg_data                 => l_msg_data);

  ELSIF (p_exception_type_code = 'CHANGE_STATUS') THEN
      change_status (
			  p_record_version_number    => p_record_version_number
		         ,p_project_id               => p_project_id
		 	 ,p_calendar_id              => l_calendar_id
			 ,p_assignment_id            => p_assignment_id
			 ,p_assignment_type          => l_assignment_type
			 ,p_status_type              => NULL
	 		 ,p_start_date               => p_change_start_date
			 ,p_end_date                 => p_change_end_date
			 ,p_assignment_status_code   => p_assignment_status_code
			 ,p_asgn_start_date          => l_cur_asgn_start_date
			 ,p_asgn_end_date            => l_cur_asgn_end_date
	 		 ,x_return_status            => l_x_return_status
		  	 ,x_msg_count                => l_msg_count
			 ,x_msg_data                 => l_msg_data);

  ELSIF (p_exception_type_code = 'CHANGE_WORK_PATTERN') THEN
      pa_schedule_utils.debug('pa.plsql.pa_schedule_pub', 'Calling change_work_pattern', 6);
      change_work_pattern (
			  p_record_version_number    => p_record_version_number
		   ,p_project_id               => p_project_id
		 	 ,p_calendar_id              => l_calendar_id
			 ,p_assignment_id            => p_assignment_id
			 ,p_assignment_type          => l_assignment_type
			 ,p_start_date               => p_change_start_date
			 ,p_end_date                 => p_change_end_date
			 ,p_monday_hours             => p_monday_hours
			 ,p_tuesday_hours            => p_tuesday_hours
	 		 ,p_wednesday_hours          => p_wednesday_hours
	 		 ,p_thursday_hours           => p_thursday_hours
			 ,p_friday_hours             => p_friday_hours
			 ,p_saturday_hours           => p_saturday_hours
	 		 ,p_sunday_hours             => p_sunday_hours
			 ,p_asgn_start_date          => l_cur_asgn_start_date
			 ,p_asgn_end_date            => l_cur_asgn_end_date
       ,p_last_row_flag            => p_last_row_flag
	 		 ,x_return_status            => l_x_return_status
		   ,x_msg_count                => l_msg_count
			 ,x_msg_data                 => l_msg_data);

  ELSIF (p_exception_type_code = 'CHANGE_HOURS') THEN
      change_hours (
			  p_record_version_number    => p_record_version_number
		         ,p_project_id               => p_project_id
		 	 ,p_calendar_id              => l_calendar_id
			 ,p_assignment_id            => p_assignment_id
			 ,p_assignment_type          => l_assignment_type
			 ,p_start_date               => p_change_start_date
			 ,p_end_date                 => p_change_end_date
			 ,p_assignment_status_code   => l_assignment_status_code
	 		 ,p_change_hours_type_code   => p_change_hours_type_code
	 		 ,p_hrs_per_day              => p_hrs_per_day
			 ,p_non_working_day_flag     => p_non_working_day_flag
	 		 ,p_calendar_percent         => p_calendar_percent
			 ,p_change_calendar_type_code => p_change_calendar_type_code
			-- ,p_change_calendar_name     => p_change_calendar_name
			 ,p_change_calendar_id       => p_change_calendar_id
			 ,p_asgn_start_date          => l_cur_asgn_start_date
			 ,p_asgn_end_date            => l_cur_asgn_end_date
	 		 ,x_return_status            => l_x_return_status
		  	 ,x_msg_count                => l_msg_count
			 ,x_msg_data                 => l_msg_data);

  END IF;

  -- If the called API fails, raise an exception.
  IF l_x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
  ELSIF l_x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  ----------------------------------------------------------------------------------------------
  --
  --  Exception Handling
  --
  ----------------------------------------------------------------------------------------------
  EXCEPTION

    WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       x_msg_count := FND_MSG_PUB.Count_Msg;

       IF x_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
	        	(p_encoded       => FND_API.G_TRUE,
		         p_msg_index      => 1,
        	         p_data           => x_msg_data,
		         p_msg_index_out  => l_msg_index_out );
       END IF;

    WHEN OTHERS THEN
        IF p_commit = FND_API.G_TRUE THEN
           ROLLBACK TO SCH_PUB_SINGLE_UPDATE_SCH;
        END IF;

	-- 4537865 : RESET x_msg_data also
	x_msg_data := SUBSTRB(SQLERRM,1,240);

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PUB'
                                ,p_procedure_name => 'single_update_schedule',
				p_error_text	  => x_msg_data  ); -- 4537865

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        x_msg_count := 1;

        RAISE;  -- This is optional depending on the needs

END single_update_schedule;



-- procedure     : mass_update_schedule
-- Purpose       : This procedure will change the schedule records of the assignments passed in.
--                 Currently, this procedure will only be called by the Mass Transaction Workflow API.
--
-- Input parameters
-- Parameters                   Type     Required  Description
-- ---------------------------  ------   --------  --------------------------------------------------------
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
PROCEDURE mass_update_schedule
( p_project_id                    IN  NUMBER
 ,p_exception_type_code           IN  VARCHAR2
 ,p_assignment_id_array           IN  SYSTEM.PA_NUM_TBL_TYPE
 ,p_change_start_date             IN  DATE             := NULL
 ,p_change_end_date               IN  DATE             := NULL
 ,p_change_rqmt_status_code       IN  VARCHAR2         := NULL
 ,p_change_asgmt_status_code      IN  VARCHAR2         := NULL
 ,p_change_start_date_tbl         IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_change_end_date_tbl           IN  SYSTEM.PA_DATE_TBL_TYPE := NULL
 ,p_monday_hours_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_tuesday_hours_tbl             IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_wednesday_hours_tbl           IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_thursday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_friday_hours_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_saturday_hours_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_sunday_hours_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE  := NULL
 ,p_non_working_day_flag          IN  VARCHAR2         := 'N'
 ,p_change_hours_type_code        IN  VARCHAR2         := NULL
 ,p_hrs_per_day                   IN  NUMBER           := NULL
 ,p_calendar_percent              IN  NUMBER           := NULL
 ,p_change_calendar_type_code     IN  VARCHAR2         := NULL
 ,p_change_calendar_name          IN  VARCHAR2         := NULL
 ,p_change_calendar_id            IN  NUMBER           := NULL
 ,p_duration_shift_type_code      IN  VARCHAR2         := NULL
 ,p_duration_shift_unit_code      IN  VARCHAR2         := NULL
 ,p_number_of_shift               IN  NUMBER           := NULL
 ,p_init_msg_list                 IN  VARCHAR2         := FND_API.G_TRUE
 ,p_validate_only                 IN  VARCHAR2         := FND_API.G_TRUE
 ,p_commit                        IN  VARCHAR2         := FND_API.G_FALSE
 ,x_success_assignment_id_tbl     OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE /* Added NOCOPY for bug#2674619 */
 ,x_return_status                 OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT NOCOPY NUMBER         --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  l_err_msg_code             fnd_new_messages.message_name%TYPE;
  l_updated_calendar_id      NUMBER;
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_assignment_id            NUMBER;
  l_assignment_type          VARCHAR2(30);
  l_assignment_status_code   VARCHAR2(30);
  l_asgmt_system_status_code VARCHAR2(30);
  l_change_asgmt_status_code VARCHAR2(30);
  l_resource_id              NUMBER;
  l_return_status            VARCHAR2(50);
  l_return_code              VARCHAR2(30);
  l_rownum                   NUMBER;
  l_privilege                VARCHAR2(30);
  l_success_assignment_id_tbl system.pa_num_tbl_type := p_assignment_id_array;
  l_last_row_flag            VARCHAR2(1);

  -- To get information for the gieven assignment
  CURSOR get_asgmt_info_csr(l_assignment_id IN NUMBER) IS
  	 SELECT assignment_type,
                status_code,
                resource_id
	 FROM  pa_project_assignments
	 WHERE assignment_id = l_assignment_id;


BEGIN
  -- Initialize the return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS ;

  --Clear the global PL/SQL message table
  IF (p_init_msg_list = FND_API.G_TRUE)  THEN
     FND_MSG_PUB.initialize;
  END IF;

  -- Initialize the Error Stack
  PA_DEBUG.init_err_stack('PA_SCHEDULE_PUB.mass_update_schedule');


  ----------------------------------------------------------------------------------------------
  --
  --  Loop through Assignment_Id_Array
  --
  ----------------------------------------------------------------------------------------------
  -- loop through assignmentId_array and process for each single update_schedule
  FOR i IN p_assignment_id_array.FIRST..p_assignment_id_array.LAST LOOP

     BEGIN
        -- We need to commit for each schedule update rather than one time after
        -- completing mass schedule update.
        IF p_commit = FND_API.G_TRUE THEN
          SAVEPOINT SCH_PUB_MASS_UPDATE_SCH;
        END IF;

        -- get the detail information of the assignment to prepare the parameters for change_XXX api
        l_assignment_id := p_assignment_id_array(i);

        OPEN get_asgmt_info_csr(l_assignment_id);
        FETCH get_asgmt_info_csr
        INTO l_assignment_type, l_assignment_status_code, l_resource_id;

        l_rownum := get_asgmt_info_csr%ROWCOUNT;
        CLOSE get_asgmt_info_csr;

        -- If there is no record for the assignment_id
        IF (l_rownum = 0) THEN
            -- set l_success_assignment_id_tbl(i) to null, which will be passed as a out arameter
            -- so that notification won't be sent for the assignment_id.
            l_success_assignment_id_tbl(i) := null;

            -- add appropriate error message to the error stack as raise error where the error will be
            -- copied to the error table.
            PA_UTILS.Add_Message ('PA', 'PA_NO_ASGMT');
            RAISE FND_API.G_EXC_ERROR;

        -- If there is only record for the assignment_id, call single_update_schedule after security check
        -- if necessary.
        ELSIF (l_rownum = 1) THEN

            -- Actually l_change_asgmt_status_code is used for requirement_status_code for OPEN_ASSIGNMENT.
            IF (l_assignment_type = 'OPEN_ASSIGNMENT') THEN
                l_change_asgmt_status_code := p_change_rqmt_status_code;
            ELSE
                l_change_asgmt_status_code := p_change_asgmt_status_code;
            END IF;

            -- call single_update_schedule procedure for single schedule update.
            -- Need to pass NULL for p_record_version_number so that it doesn't check record_version_number.
            -- Because we don't need to care about it for mass schedule update.

          -- For CHANGE_WORK_PATTERN
          IF p_exception_type_code = 'CHANGE_WORK_PATTERN' THEN
            IF p_change_start_date_tbl.COUNT > 0 THEN
              FOR j IN p_change_start_date_tbl.FIRST .. p_change_start_date_tbl.LAST  LOOP
                IF j < p_change_start_date_tbl.LAST THEN
                  l_last_row_flag := 'N';
                ELSE
                  l_last_row_flag := 'Y';
                END IF;

                single_update_schedule (
        			    p_project_id                 => p_project_id
                 ,p_exception_type_code        => p_exception_type_code
				         ,p_record_version_number      => NULL
				         ,p_assignment_id              => p_assignment_id_array(i)
				         ,p_change_start_date          => p_change_start_date_tbl(j)
				         ,p_change_end_date            => p_change_end_date_tbl(j)
				         ,p_assignment_status_code     => l_change_asgmt_status_code
				         ,p_monday_hours               => p_monday_hours_tbl(j)
				         ,p_tuesday_hours              => p_tuesday_hours_tbl(j)
	 			         ,p_wednesday_hours            => p_wednesday_hours_tbl(j)
			 	         ,p_thursday_hours             => p_thursday_hours_tbl(j)
				         ,p_friday_hours               => p_friday_hours_tbl(j)
				         ,p_saturday_hours             => p_saturday_hours_tbl(j)
	 			         ,p_sunday_hours               => p_sunday_hours_tbl(j)
				         ,p_non_working_day_flag       => p_non_working_day_flag
	 			         ,p_change_hours_type_code     => p_change_hours_type_code
			 	         ,p_hrs_per_day                => p_hrs_per_day
				         ,p_calendar_percent           => p_calendar_percent
				         ,p_change_calendar_type_code  => p_change_calendar_type_code
				         --,p_change_calendar_name       => p_change_calendar_name
				         ,p_change_calendar_id         => p_change_calendar_id
		             ,p_duration_shift_type_code   => p_duration_shift_type_code
                 ,p_duration_shift_unit_code   => p_duration_shift_unit_code
                 ,p_number_of_shift            => p_number_of_shift
                 ,p_last_row_flag              => l_last_row_flag
                 ,p_init_msg_list              => FND_API.G_TRUE
		             ,p_commit                     => FND_API.G_FALSE
	               ,x_return_status              => l_x_return_status
				         ,x_msg_count                  => l_msg_count
				         ,x_msg_data                   => l_msg_data);

              END LOOP;
            END IF;
          -- For all other schedule changes
          ELSE
            l_last_row_flag := 'Y';

            single_update_schedule (
   			    p_project_id                 => p_project_id
           ,p_exception_type_code        => p_exception_type_code
				   ,p_record_version_number      => NULL
				   ,p_assignment_id              => p_assignment_id_array(i)
				   ,p_change_start_date          => p_change_start_date
				   ,p_change_end_date            => p_change_end_date
				   ,p_assignment_status_code     => l_change_asgmt_status_code
				   ,p_monday_hours               => NULL
				   ,p_tuesday_hours              => NULL
	 			   ,p_wednesday_hours            => NULL
			 	   ,p_thursday_hours             => NULL
				   ,p_friday_hours               => NULL
				   ,p_saturday_hours             => NULL
	 			   ,p_sunday_hours               => NULL
				   ,p_non_working_day_flag       => p_non_working_day_flag
	 			   ,p_change_hours_type_code     => p_change_hours_type_code
			 	   ,p_hrs_per_day                => p_hrs_per_day
	 			   ,p_calendar_percent           => p_calendar_percent
				   ,p_change_calendar_type_code  => p_change_calendar_type_code
				   --,p_change_calendar_name       => p_change_calendar_name
				   ,p_change_calendar_id         => p_change_calendar_id
		       ,p_duration_shift_type_code   => p_duration_shift_type_code
           ,p_duration_shift_unit_code   => p_duration_shift_unit_code
           ,p_number_of_shift            => p_number_of_shift
           ,p_last_row_flag              => l_last_row_flag
           ,p_init_msg_list              => FND_API.G_TRUE
		       ,p_commit                     => FND_API.G_FALSE
	         ,x_return_status              => l_x_return_status
				   ,x_msg_count                  => l_msg_count
				   ,x_msg_data                   => l_msg_data);
         END IF; -- end if for calling single_update_schedule

            -- If the called API succeeded, put the assingnment_id to the out parameter 'x_assignment_id_array'
            -- and commit.
            IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
                l_success_assignment_id_tbl(i) := p_assignment_id_array(i);

                IF (p_commit = FND_API.G_TRUE) THEN
                   COMMIT;
                END IF;

            -- If the called API doesn't succeeded, set null to tthe out parameter 'x_assignment_id_array'
            -- instead of the failed assignment_id so that workflow won't be started for the failed assignments.
            -- And need to rollback.
            ELSE
                l_success_assignment_id_tbl(i) := null;

                IF (p_commit = FND_API.G_TRUE) THEN
                    ROLLBACK TO SCH_PUB_MASS_UPDATE_SCH;
                    RAISE FND_API.G_EXC_ERROR;
                END IF;
            END IF;

      END IF; -- if l_rownum = 1

      EXCEPTION
         -- need to catch error for system_status_code being not found
         WHEN NO_DATA_FOUND THEN
             PA_UTILS.Add_Message ('PA', 'PA_STATUS_CODE_NOT_FOUND');

             -- save the error message to the proper table so that we can retrive them later
             --  from workflow notification page.
             PA_MESSAGE_UTILS.save_messages
                                      (p_user_id            =>  PA_MASS_ASGMT_TRX.G_SUBMITTER_USER_ID,
                                       p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                                       p_source_type2       =>  PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE,
                                       p_source_identifier1 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_TYPE,
                                       p_source_identifier2 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY,
                                       p_context1           =>  p_project_id,
                                       p_context2           =>  p_assignment_id_array(i),
                                       p_context3           =>  NULL,
                                       p_commit             =>  FND_API.G_TRUE,
                                       x_return_status      =>  l_return_status);

         WHEN FND_API.G_EXC_ERROR THEN
             -- save the error message to the proper table so that we can retrive them later
             --  from workflow notification page.
             PA_MESSAGE_UTILS.save_messages
                                      (p_user_id            =>  PA_MASS_ASGMT_TRX.G_SUBMITTER_USER_ID,
                                       p_source_type1       =>  PA_MASS_ASGMT_TRX.G_SOURCE_TYPE1,
                                       p_source_type2       =>  PA_MASS_ASGMT_TRX.G_MASS_UPDATE_SCHEDULE,
                                       p_source_identifier1 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_TYPE,
                                       p_source_identifier2 =>  PA_MASS_ASGMT_TRX.G_WORKFLOW_ITEM_KEY,
                                       p_context1           =>  p_project_id,
                                       p_context2           =>  p_assignment_id_array(i),
                                       p_context3           =>  NULL,
                                       p_commit             =>  FND_API.G_TRUE,
                                       x_return_status      =>  l_return_status);
     END;

  END LOOP;

  -- put the success_assignment_id_table to the out parameter to invoke workflow only for
  -- those success ones.
  X_success_assignment_id_tbl := l_success_assignment_id_tbl;

  ----------------------------------------------------------------------------------------------
  --
  --  Exception Handling
  --
  ----------------------------------------------------------------------------------------------
  EXCEPTION
    WHEN OTHERS THEN

	-- 4537865 : RESET x_msg_data also
	x_msg_data := SUBSTRB(SQLERRM,1,240);

        -- Set the excetption Message and the stack
        FND_MSG_PUB.add_exc_msg( p_pkg_name       => 'PA_SCHEDULE_PUB'
                                ,p_procedure_name => 'mass_update_schedule'
				,p_error_text	  => x_msg_data ); -- 4537865

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        x_msg_count := FND_MSG_PUB.Count_Msg;

        RAISE;  -- This is optional depending on the needs
END mass_update_schedule;



-- procedure                   : change_duration
-- Purpose                     : This procedure will change the duration of the given assignment
--                               on the basis of start date and end date it will shift the assignment
--                               , extend the assignment or contract the assignment
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- p_record_version_number      NUMBER         YES
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this assignment
-- P_Assignment_Id              NUMBER         YES       Assignment id of the changed duration assignment
-- P_Assignment_Type            VARCHAR2       YES       It is type of the assignment e.g OPEN /STAFFED ASSIGNMENT
-- P_Start_Date                 DATE           YES       starting date for the changed duration
-- P_End_Date                   DATE           YES       ending date for the changed duration
-- P_Assignment_Status_Code     VARCHAR2       YES       Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Asgn_Start_Date            DATE           YES       Start date of the assignment for which you want to
--                                                       change duration
-- P_Asgn_End_Date              DATE           YES       End date of the assignment for which you want to
--                                                       change duration

PROCEDURE change_duration
	(
	 p_record_version_number         IN Number          ,
         p_exception_type_code           IN Varchar2        ,
	 p_project_id                    IN Number          ,
	 p_calendar_id                   IN Number          ,
	 p_assignment_id                 IN Number          ,
	 p_assignment_type               IN Varchar2        ,
	 p_start_date                    IN date            := NULL,
	 p_end_date                      IN date            := NULL,
	 p_assignment_status_code        IN varchar2        := NULL,
	 p_asgn_start_date               IN DATE            := NULL,
	 p_asgn_end_date                 IN DATE            := NULL,
         p_duration_shift_type_code      IN Varchar2        := NULL,
         p_duration_shift_unit_code      IN VARCHAR2        := NULL,
         p_number_of_shift               IN Varchar2        := NULL,
         p_init_msg_list                 IN VARCHAR2        := FND_API.G_FALSE,
	 p_generate_timeline_flag	 IN VARCHAR2	    := 'Y', --Unilog
	 p_called_by_proj_party          IN VARCHAR2        := 'N', -- Added for Bug 6631033
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_assignment_status_null          EXCEPTION;
	 l_stale_asmt_data                  EXCEPTION;
	 l_status_type                      VARCHAR2(30);
	 l_error_message_code               VARCHAR2(50);
	 l_record_version_number            NUMBER;
	 l_person_id                        NUMBER;
 	 l_start_date                       DATE;
	 l_end_date                         DATE;
	 l_msg_index_out	            NUMBER;
         l_shifted_days                     NUMBER;
	 l_exception_id          NUMBER;
	 l_return_status         VARCHAR2(1);
	 l_assignment_status_name pa_project_statuses.project_status_name%TYPE;

	 -- For error message tokens
	 l_asgn_req_text                   VARCHAR2(30);
	 l_a_an_text                       VARCHAR2(30);
	 l_asgn_req_poss_text              VARCHAR2(30);

	 l_data VARCHAR2(2000);	 -- 4537865
	 l_new_resource_id NUMBER; -- 4537865
	 -- For retrieving resource_source_id
	 CURSOR get_resource_source_id IS
		 SELECT a.person_id, b.resource_id
			 FROM   pa_resource_txn_attributes a, pa_project_assignments b
			 WHERE  a.resource_id = b.resource_id
			 AND b.assignment_id = p_assignment_id;

		 l_resource_source_id NUMBER;
		 l_resource_id NUMBER;
		 l_resource_type_id NUMBER;
		 l_resource_out_of_range EXCEPTION;
		 l_resource_cc_error_u EXCEPTION;
		 l_resource_cc_error_e EXCEPTION;
		 l_cc_ok  VARCHAR2(1);
     l_ei_asgn_out_of_range EXCEPTION;

		 -- For retrieving project_status_name
     -- 3054787: Select from tables directly to improve performance.
		 CURSOR get_project_status_name IS
			 SELECT pps.project_status_name
				 FROM pa_projects_all ppa, pa_project_statuses pps
				 WHERE ppa.project_id = p_project_id
         AND   ppa.project_status_code = pps.project_status_code;

		   l_project_status_name pa_project_statuses.project_status_name%TYPE;

BEGIN
 	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

         --Clear the global PL/SQL message table
         IF (p_init_msg_list = FND_API.G_TRUE)  THEN
             FND_MSG_PUB.initialize;
         END IF;

	 IF ( p_assignment_type  = 'OPEN_ASSIGNMENT' ) THEN
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_A_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_POSS_TEXT');
	 ELSE
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_AN_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_POSS_TEXT');
	 END IF;


         ----------------------------------------------------------------------------------------------
         --
         --  Logic for Duration
         --
         ----------------------------------------------------------------------------------------------
         IF (p_exception_type_code = 'CHANGE_DURATION') THEN

  	     -- The dates are valid now checking the passing date should valid for the asignment dates
  	     IF (( p_start_date IS NOT NULL ) AND (p_end_date IS NULL ) AND  (p_start_date > p_asgn_end_date )) THEN
	         RAISE l_out_of_range_from_date;
     	     ELSIF (( p_start_date IS NULL ) AND (p_end_date IS NOT NULL ) AND ( p_end_date < p_asgn_start_date )) THEN
		 RAISE l_out_of_range_to_date;
   	     END IF;

             -- for change duration page, set the input value 'p_start_date' and 'p_end_date' to local
             -- variables which are used for checking validation resource for the updated date.
             l_start_date := p_start_date;
	     l_end_date   := p_end_date;

         END IF; -- IF (p_exception_type_code = 'CHANGE_DURATION')


         ----------------------------------------------------------------------------------------------
         --
         --  Logic For Duration Shift
         -- Modified below for 7663765
         ----------------------------------------------------------------------------------------------
         IF (p_exception_type_code = 'SHIFT_DURATION'   OR p_exception_type_code = 'DURATION_PATTERN_SHIFT') THEN

             -- If p_number_of_shift is not null, calculate the new start_date and end_date by adding
             -- or substracting p_number_of_shift from p_asgn_start_date and p_asgn_end_date
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
                         l_start_date := add_months(p_asgn_start_date, p_number_of_shift) ;
                         l_end_date   := add_months(p_asgn_end_date, p_number_of_shift) ;
                     ELSE
		         l_start_date := p_asgn_start_date + l_shifted_days;
                         l_end_date   := p_asgn_end_date + l_shifted_days;
                     END IF;
	         ELSIF (p_duration_shift_type_code = 'BACKWARD') THEN
                     IF (p_duration_shift_unit_code = 'MONTHS') THEN
                         l_start_date := add_months(p_asgn_start_date, p_number_of_shift * -1) ;
                         l_end_date   := add_months(p_asgn_end_date, p_number_of_shift * -1) ;
                     ELSE
		         l_start_date := p_asgn_start_date - l_shifted_days;
                         l_end_date   := p_asgn_end_date - l_shifted_days;
                     END IF;

                 END IF;

             END IF;

         END IF; -- IF (p_exception_type_code = 'SHIFT_DURATION')

         ----------------------------------------------------------------------------------------------
         --
         --  Common Logic for both Duration and Duration Shift
         --
         ----------------------------------------------------------------------------------------------
         -- If extending or contracting the duration the the assignment status should not be null for the new duration
	 -- If extending the staffed assignment duration with a new status, the status should be allowed for the status
         -- of the project this assignment belongs to.
         -- Bug 8233045: Added G_update_schedule_bulk_call condition.
         IF( ((l_start_date IS NOT NULL) AND (l_start_date  NOT BETWEEN p_asgn_start_date AND p_asgn_end_date)) OR
	     ((l_end_date IS NOT NULL) AND (l_end_date  NOT BETWEEN p_asgn_start_date AND p_asgn_end_date))        ) AND
             PA_SCHEDULE_PUB.G_update_schedule_bulk_call <> 'Y'  THEN

	     IF(p_assignment_status_code IS NULL) THEN
		 RAISE l_assignment_status_null;

             ELSIF (p_assignment_status_code IS NOT NULL) AND (p_assignment_type <> 'OPEN_ASSIGNMENT') THEN

	         l_return_status := PA_ASSIGNMENT_UTILS.is_asgmt_allow_stus_ctl_check(
				p_asgmt_status_code => p_assignment_status_code,
				p_project_id => p_project_id,
                                p_add_message => 'N');

	         IF l_return_status <> 'Y' THEN
   		     OPEN get_project_status_name;
	             FETCH get_project_status_name INTO l_project_status_name;
                     CLOSE get_project_status_name;

	    	     SELECT project_status_name
	   	     INTO l_assignment_status_name
	   	     FROM pa_project_statuses
	  	     WHERE project_status_code = p_assignment_status_code;

	    	     RAISE l_asgn_stus_not_for_proj_stus;
		 END IF;
             END IF;

         END IF; --IF(( (p_start_date IS NOT NULL ..

	 --
	 -- Validate that resource is valid for new start date
         --
	 PA_SCHEDULE_UTILS.log_message(1,'Validate that resource is valid for new start date?');
	 IF p_assignment_type <> 'OPEN_ASSIGNMENT' THEN
			PA_SCHEDULE_UTILS.log_message(1,'Validating resource');
			-- Get resource source id for assignment
			OPEN get_resource_source_id;
			FETCH get_resource_source_id INTO l_resource_source_id, l_resource_id;
			CLOSE get_resource_source_id;

			PA_RESOURCE_UTILS.Check_ResourceName_Or_Id (
				p_resource_id        => l_resource_source_id
				,p_resource_name      => null
				,p_check_id_flag      => 'Y' --3235018 Changed from N to Y  --'N' /* Bug#2822950-Modified null to 'N' */
				,p_date               => NVL(l_start_date, p_asgn_start_date) -- 3235018 : replaced p_start_date to l_start_date
				,p_end_date           => NVL(l_end_date, p_asgn_end_date) -- 3235018 : Added this
				-- 4537865 : ,x_resource_id        => l_resource_source_id
				,x_resource_id        => l_new_resource_id -- 4537865 : For NOCOPY related Changes.
				,x_resource_type_id   => l_resource_type_id
				,x_return_status      => l_x_return_status
				,x_error_message_code => l_error_message_code);

			IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
				 PA_SCHEDULE_UTILS.log_message(1,'Resource dates are not valid');
				 Raise l_resource_out_of_range;
			ELSE  -- IF if l_x_return_status is success : 4537865
				l_resource_source_id := l_new_resource_id ;
			END IF;

			PA_SCHEDULE_UTILS.log_message(1,'Resource dates are valid');

			-- Check if resource is assigned to a valid organization
			PA_RESOURCE_UTILS.check_cc_for_resource(p_resource_id => l_resource_id,
				p_project_id  => p_project_id,
				p_start_date  => NVL(l_start_date, p_asgn_start_date),
				p_end_date    => NVL(l_end_date, p_asgn_end_date),
				x_cc_ok       => l_cc_ok,
				x_return_status => l_x_return_status,
				x_error_message_code => l_error_message_code);

			IF (l_x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
				 PA_SCHEDULE_UTILS.log_message(1,'Resource cc is not valid: u');
					Raise l_resource_cc_error_u;
			END IF;

			IF l_cc_ok <> 'Y' THEN
				 PA_SCHEDULE_UTILS.log_message(1,'Resource cc is not valid: e');
				 Raise l_resource_cc_error_e;
			END IF;

			PA_SCHEDULE_UTILS.log_message(1,'Resource cc is valid');

      -- Make sure duration change does not cause existing actuals to
      -- be out of range.
      -- 2797890: Added parameter p_project_id, p_person_id.
      PA_TRANS_UTILS.check_txn_exists (
                            p_assignment_id => p_assignment_id
                           ,p_old_start_date => p_asgn_start_date
                           ,p_old_end_date => p_asgn_end_date
                           ,p_new_start_date => NVL(l_start_date, p_asgn_start_date)
                           ,p_new_end_date => NVL(l_end_date, p_asgn_end_date)
                           ,p_calling_mode => 'UPDATE'
                           ,p_project_id   => p_project_id
                           ,p_person_id    => l_resource_source_id
                           ,x_error_message_code => l_error_message_code
                           ,x_return_status => x_return_status);
      -- End of 2797890
      if (x_return_status <> FND_API.G_RET_STS_SUCCESS) then
         raise l_ei_asgn_out_of_range;
      end if;
	 END IF;

	 --
	 -- Insert row to PA_SCHEDULE_EXCEPTIONS
         --
 	 PA_SCHEDULE_UTILS.log_message(1,'Start of the change_duration API ..... ');
	 PA_SCH_EXCEPT_PKG.Insert_Rows(
				p_calendar_id               => p_calendar_id
			       ,p_assignment_id             => p_assignment_id
			       ,p_project_id                => p_project_id
			       ,p_schedule_type_code        => p_assignment_type
			       ,p_assignment_status_code    => p_assignment_status_code
			       ,p_exception_type_code       => p_exception_type_code
			       ,p_start_date                => l_start_date
			       ,p_end_date                  => l_end_date
                     	       ,p_duration_shift_type_code  => p_duration_shift_type_code
			       ,p_duration_shift_unit_code  => p_duration_shift_unit_code
			       ,p_number_of_shift           => p_number_of_shift
			       ,x_exception_id              => l_exception_id
			       ,x_return_status             => l_x_return_status
			       ,x_msg_count                 => x_msg_count
			       ,x_msg_data                  => x_msg_data               );

	 -- Calling the change assignment schedule procedure which will
	 -- generate the schedule after applying the duration change
	 PA_SCHEDULE_PUB.change_asgn_schedule(
				p_record_version_number => p_record_version_number,
				p_assignment_id => p_assignment_id,
				p_project_id => p_project_id,
				p_exception_id => l_exception_id,
				p_generate_timeline_flag => p_generate_timeline_flag,--Unilog
				p_called_by_proj_party   => p_called_by_proj_party, -- Added for Bug 6631033
				x_return_status => l_x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data);


   -- Bug 2255963: Call reevaluate_adv_action_set AFTER the start date of
   -- requirement (but not asssignment) is updated and before changes are committed.
   IF l_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     IF (p_assignment_type  = 'OPEN_ASSIGNMENT' AND l_start_date <> p_asgn_start_date) THEN
       PA_ADVERTISEMENTS_PUB.Reevaluate_Adv_Action_Set (
          p_object_id             => p_assignment_id,
          p_object_type           => 'OPEN_ASSIGNMENT',
          p_new_object_start_date => l_start_date,
          p_validate_only         => FND_API.G_FALSE,
          p_init_msg_list         => FND_API.G_FALSE,
          p_commit                => FND_API.G_FALSE,
          x_return_status         => l_x_return_status);
     END IF;
   END IF;

   -- Bug 2441437: Update the no of active candidates after duration
   -- has been changed.
   IF l_x_return_status = FND_API.G_RET_STS_SUCCESS THEN
     PA_CANDIDATE_UTILS.Update_No_Of_Active_Candidates (
                            p_assignment_id => p_assignment_id,
                            x_return_status => l_x_return_status);
   END IF;

         ----------------------------------------------------------------------
         --
         --  Exception Handling
         --
         ----------------------------------------------------------------------
	 PA_SCHEDULE_UTILS.log_message(1,'End   of the change_duration API ..... ');
	 x_return_status := l_x_return_status;

	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
				p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
				p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865 : NOCOPY related change
	 End If;

EXCEPTION
   WHEN l_ei_asgn_out_of_range THEN
     PA_UTILS.Add_Message('PA', l_error_message_code);
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_data := l_error_message_code;
     x_msg_count := FND_MSG_PUB.Count_Msg;
     If x_msg_count = 1 THEN
        pa_interface_utils_pub.get_messages
          (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_msg_count      => x_msg_count,
          p_msg_data       => x_msg_data,
          p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
          p_msg_index_out  => l_msg_index_out );
	  x_msg_data := l_data ; -- 4537865 : NOCOPY related change
     End If;
	 WHEN l_resource_cc_error_u THEN
		 PA_UTILS.Add_Message('PA', l_error_message_code);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := l_error_message_code;
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_resource_cc_error_e THEN
		 PA_UTILS.Add_Message('PA', 'CROSS_CHARGE_VALIDATION_FAILED');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'CROSS_CHARGE_VALIDATION_FAILED';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_resource_out_of_range THEN
		 PA_UTILS.Add_Message( 'PA', 'PA_RESOURCE_OUT_OF_RANGE');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_RESOURCE_OUT_OF_RANGE';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_stale_asmt_data THEN
		 PA_UTILS.add_message('PA','PA_XC_RECORD_CHANGED');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_XC_RECORD_CHANGED';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_assignment_status_null THEN
		 PA_UTILS.add_message('PA','PA_SCH_ASGN_STATUS_NULL');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_SCH_ASGN_STATUS_NULL';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_out_of_range_from_date THEN
		 PA_UTILS.add_message('PA','PA_SCH_INVALID_FROM_DATE',
		 'ASMT_TYPE_POSS', l_asgn_req_poss_text,
		 'ASMT_TYPE', l_asgn_req_text);
		 x_msg_data := 'PA_SCH_INVALID_FROM_DATE';
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data;  -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_out_of_range_to_date THEN
		 PA_UTILS.add_message('PA','PA_SCH_INVALID_TO_DATE',
		 'ASMT_TYPE_POSS', l_asgn_req_poss_text,
		 'ASMT_TYPE', l_asgn_req_text);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_SCH_INVALID_TO_DATE';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
						p_data           => l_data,  -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data;  -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_asgn_stus_not_for_proj_stus THEN
		 PA_UTILS.Add_Message( p_app_short_name => 'PA',
			p_msg_name       => 'PA_ASGN_STUS_NOT_FOR_PROJ_STUS',
                        p_token1         => 'PROJ_STATUS',
			p_value1         => l_project_status_name,
			p_token2         => 'ASGN_STATUS',
			p_value2         => l_assignment_status_name);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_ASGN_STUS_NOT_FOR_PROJ_STUS';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
						p_data           => l_data,  -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data;  -- 4537865 : NOCOPY related change
		 End If;
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in change_durarion API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data := substrb(SQLERRM,1,240); -- 4537865 : Changed substr to substrb
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_duration');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
				       (p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data,  -- 4537865 : Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data;  -- 4537865 : NOCOPY related change
		 End If;
                 RAISE;  -- This is optional depending on the needs
END change_duration;


-- Purpose              : This procedure will change the hours of the passed assignment
--                        From  its passed start date till the passed end date .
--                        It will change the hours either percentage  or hours wise.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this assignment
-- P_Assignment_Id              NUMBER         YES       Assignment id of the changed hours  assignment
-- P_Assignment_Type            VARCHAR2       YES       It is type of the assignment e.g OPEN /STAFFED ASSIGNMENT
-- P_Start_Date                 DATE           YES       starting date for the changed hours
-- P_End_Date                   DATE           YES       ending date for the changed hours
-- P_Assignment_Status_Code     VARCHAR2       YES       Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Change_Hours_Type_Code     VARCHAR2       YES       It is the type of code by which you want to change the hours
--                                                       e.g. HOURS/PERCENTAGE
-- P_Hrs_Per_Day                NUMBER         YES       It is the changed hours value
-- P_Non_Working_Day_Flag       VARCHAR2       YES       It is the flag which indicate that the non working day should
--                                                       include or not e.g Y/N
-- P_Calendar_Percent           NUMBER         YES       if the hours type code is percentage then this is the percent
--                                                       age value for the changed hours
-- P_Asgn_Start_Date            DATE           YES       Start date of the assignment for which you want to
--                                                       change hours
-- P_Asgn_End_Date              DATE           YES       End date of the assignment for which you want to
--                                                       change hours
--

PROCEDURE change_hours
	(
	 p_record_version_number         IN Number          ,
	 p_project_id                    IN Number          ,
	 p_calendar_id                   IN Number          ,
	 p_assignment_id                 IN Number          ,
	 p_assignment_type               IN Varchar2        ,
	 p_start_date                    IN date            ,
	 p_end_date                      IN date            ,
	 p_non_working_day_flag          IN varchar2        := 'N',
	 p_assignment_status_code        IN Varchar2        ,
	 p_change_hours_type_code        IN varchar2        ,
	 p_hrs_per_day                   IN Number          ,
	 p_calendar_percent              IN Number          ,
         p_change_calendar_type_code     IN VARCHAR2        ,
        -- p_change_calendar_name          IN VARCHAR2        ,
         p_change_calendar_id            IN VARCHAR2        ,
	 p_asgn_start_date               IN DATE            ,
	 p_asgn_end_date                 IN DATE            ,
         p_init_msg_list                 IN VARCHAR2        := FND_API.G_FALSE,
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_t_exception_id           NUMBER;
	 l_msg_index_out		     NUMBER;
 	 l_data				   VARCHAR2(2000) ; -- 4537865
	 -- For error message tokens
	 l_asgn_req_text                   VARCHAR2(30);
	 l_a_an_text                       VARCHAR2(30);
	 l_asgn_req_poss_text              VARCHAR2(30);
BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;

         --Clear the global PL/SQL message table
         IF (p_init_msg_list = FND_API.G_TRUE)  THEN
             FND_MSG_PUB.initialize;
         END IF;

	 IF ( p_assignment_type  = 'OPEN_ASSIGNMENT' ) THEN
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_A_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_POSS_TEXT');
	 ELSE
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_AN_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_POSS_TEXT');
	 END IF;

	 -- The passed dates for changing the hours should be between
	 -- start and  end date of the assignment.
	 IF ((p_start_date NOT BETWEEN p_asgn_start_date AND p_asgn_end_date ) OR
		 (p_end_date NOT BETWEEN p_asgn_start_date AND p_asgn_end_date )) THEN
			Raise l_out_of_range_date;
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of the change_hours API ... ');

	 PA_SCH_EXCEPT_PKG.Insert_Rows(
		 p_calendar_id              => p_calendar_id            ,
		 p_assignment_id            => p_assignment_id          ,
		 p_project_id               => p_project_id             ,
		 p_schedule_type_code       => p_assignment_type        ,
		 p_assignment_status_code   => p_assignment_status_code ,
		 p_exception_type_code      => 'CHANGE_HOURS'           ,
		 p_start_date               => p_start_date             ,
		 p_end_date                 => p_end_date               ,
		 p_resource_calendar_percent=> p_calendar_percent       ,
		 p_non_working_day_flag     => p_non_working_day_flag   ,
		 p_change_hours_type_code   => p_change_hours_type_code ,
                 p_change_calendar_type_code => p_change_calendar_type_code ,
                -- p_change_calendar_name     => p_change_calendar_name   ,
                 p_change_calendar_id       => p_change_calendar_id     ,
		 p_monday_hours             => p_hrs_per_day            ,
		 p_tuesday_hours            => p_hrs_per_day            ,
		 p_wednesday_hours          => p_hrs_per_day            ,
		 p_thursday_hours           => p_hrs_per_day            ,
		 p_friday_hours             => p_hrs_per_day            ,
		 p_saturday_hours           => p_hrs_per_day            ,
		 p_sunday_hours             => p_hrs_per_day            ,
		 x_exception_id             => l_t_exception_id         ,
		 x_return_status            => l_x_return_status        ,
		 x_msg_count                => x_msg_count              ,
		 x_msg_data                 => x_msg_data               );

	IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
	-- Calling the change assignment schedule procedure
	-- which will generate the schedule after applying the hours  change
		PA_SCHEDULE_PUB.change_asgn_schedule(
							p_record_version_number => p_record_version_number,
							p_assignment_id => p_assignment_id,
							p_project_id => p_project_id,
							p_exception_id => l_t_exception_id,
							x_return_status => l_x_return_status,
							x_msg_count => x_msg_count,
							x_msg_data => x_msg_data);
	END IF;

	PA_SCHEDULE_UTILS.log_message(1,'End   of the change_hours API ... ');
	x_return_status := l_x_return_status;
	x_msg_count := FND_MSG_PUB.Count_Msg;
	If x_msg_count = 1 THEN
		pa_interface_utils_pub.get_messages
						(p_encoded        => FND_API.G_TRUE ,
						p_msg_index      => 1,
						p_msg_count      => x_msg_count ,
						p_msg_data       => x_msg_data ,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865 : NOCOPY related Change
	End If;

EXCEPTION
	 WHEN l_out_of_range_date THEN
		 PA_UTILS.add_message('PA','PA_SCH_INVALID_FROM_TO_DATE',
		 'ASMT_TYPE', l_asgn_req_text);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_SCH_INVALID_FROM_TO_DATE';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related Change
		 End If;
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in change_hours API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count     := 1;
		 x_msg_data      := substrb(SQLERRM,1,240); -- 4537865 : Changed substr to substrb
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_duration');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related Change
		 End If;

                 RAISE;  -- This is optional depending on the needs
END change_hours;

-- procedure            : change_work_pattern
-- Purpose              : This procedure will change the work pattern of the passed assignment on the basis of your
--                        passed pattern i.e monady hours,tuesday hours and so on for the passed period only.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Calendar_Id                NUMBER         YES       Id for that calendar which is associated to this assignment
-- P_Assignment_Id              NUMBER         YES       Assignment id of the changed work pattern  assignment
-- P_Assignment_Type            VARCHAR2       YES       It is type of the assignment e.g OPEN /STAFFED ASSIGNMENT
-- P_Start_Date                 DATE           YES       starting date for the changed work pattern
-- P_End_Date                   DATE           YES       ending date for the changed work pattern
-- P_Monday_Hours               NUMBER         YES       No. of hours of this day
-- P_Tuesday_Hours              NUMBER         YES       No. of hours of this day
-- P_Wednesday_Hours            NUMBER         YES       No. of hours of this day
-- P_Thursday_Hours             NUMBER         YES       No. of hours of this day
-- P_Friday_Hours               NUMBER         YES       No. of hours of this day
-- P_Saturday_Hours             NUMBER         YES       No. of hours of this day
-- P_Sunday_Hours               NUMBER         YES       No. of hours of this day
-- P_Asgn_Start_Date            DATE           YES       Start date of the assignment for which you want to
--                                                       change work pattern
-- P_Asgn_End_Date              DATE           YES       End date of the assignment for which you want to
--                                                       change work pattern
--

PROCEDURE change_work_pattern
	(
	 p_record_version_number         IN Number          ,
	 p_project_id                    IN Number          ,
	 p_calendar_id                   IN Number          ,
	 p_assignment_id                 IN Number          ,
	 p_assignment_type               IN Varchar2        ,
	 p_start_date                    IN date            ,
	 p_end_date                      IN date            ,
	 p_monday_hours                  IN Number          := NULL,
	 p_tuesday_hours                 IN Number          := NULL,
	 p_wednesday_hours               IN Number          := NULL,
	 p_thursday_hours                IN Number          := NULL,
	 p_friday_hours                  IN Number          := NULL,
	 p_saturday_hours                IN Number          := NULL,
	 p_sunday_hours                  IN Number          := NULL,
	 p_asgn_start_date               IN DATE            ,
	 p_asgn_end_date                 IN DATE            ,
	 p_init_msg_list                 IN VARCHAR2        := FND_API.G_FALSE,
	 p_remove_conflict_flag          IN VARCHAR2        := 'N',
	 p_last_row_flag                 IN  VARCHAR2       := 'Y',
	 p_generate_timeline_flag	 IN VARCHAR2        := 'Y', --Unilog
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_t_exception_id                  NUMBER; -- Temp variable
	 l_p_monday_hours                  NUMBER;
	 l_p_tuesday_hours                 NUMBER;
	 l_p_wednesday_hours               NUMBER;
	 l_p_thursday_hours                NUMBER;
	 l_p_friday_hours                  NUMBER;
	 l_p_saturday_hours                NUMBER;
	 l_p_sunday_hours                  NUMBER;
	 l_msg_index_out		     NUMBER;

	 -- For error message tokens
	 l_asgn_req_text                   VARCHAR2(30);
	 l_a_an_text                       VARCHAR2(30);
	 l_asgn_req_poss_text              VARCHAR2(30);

	 l_data VARCHAR2(200); -- 4537865
BEGIN
	 -- Storing status success to track the error
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;

         --Clear the global PL/SQL message table
         IF (p_init_msg_list = FND_API.G_TRUE)  THEN
             FND_MSG_PUB.initialize;
         END IF;

	 IF ( p_assignment_type  = 'OPEN_ASSIGNMENT' ) THEN
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_A_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_POSS_TEXT');
	 ELSE
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_AN_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_POSS_TEXT');
	 END IF;


	 -- The passed start date and end date should be between the
	 -- passed start and end date of the assignmente */
	 IF ((p_start_date NOT BETWEEN p_asgn_start_date AND p_asgn_end_date ) OR
		 (p_end_date NOT BETWEEN p_asgn_start_date AND p_asgn_end_date )) THEN
			RAISE l_out_of_range_date;
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of the change_work_pattern API ... ');

          l_p_monday_hours := p_monday_hours;
          l_p_tuesday_hours := p_tuesday_hours;
         l_p_wednesday_hours := p_wednesday_hours;
         l_p_thursday_hours := p_thursday_hours;
        l_p_friday_hours := p_friday_hours;
        l_p_saturday_hours := p_saturday_hours;
        l_p_sunday_hours := p_sunday_hours;


/*
	 -- The passing day hours should not beyond the 24 hours and should not null
	 IF (p_monday_hours IS NULL ) THEN
			l_p_monday_hours := 0;
	 ELSE
		        l_p_monday_hours := p_monday_hours;
	 END IF;

	 IF (p_tuesday_hours IS NULL ) THEN
			l_p_tuesday_hours := 0;
	 ELSE
       		        l_p_tuesday_hours := p_tuesday_hours;
	 END IF;

	 IF (p_wednesday_hours IS NULL ) THEN
			l_p_wednesday_hours := 0;
	 ELSE
			l_p_wednesday_hours := p_wednesday_hours;
	 END IF;

	 IF (p_thursday_hours IS NULL ) THEN
			l_p_thursday_hours := 0;
	 ELSE
			l_p_thursday_hours := p_thursday_hours;
	 END IF;

	 IF (p_friday_hours IS NULL ) THEN
			l_p_friday_hours := 0;
	 ELSE
			l_p_friday_hours := p_friday_hours;
	 END IF;

	 IF (p_saturday_hours IS NULL ) THEN
			l_p_saturday_hours := 0;
	 ELSE
			l_p_saturday_hours := p_saturday_hours;
	 END IF;

	 IF (p_sunday_hours IS NULL ) THEN
			l_p_sunday_hours := 0;
	 ELSE
			l_p_sunday_hours := p_sunday_hours;
	 END IF;
	 */

   -- When called by mass_update_schedule, null working hours are passed in as -99.
   -- Need to convert -99 back to null.
   IF p_monday_hours = -99 THEN
     l_p_monday_hours := null;
   END IF;
   IF p_tuesday_hours = -99 THEN
     l_p_tuesday_hours := null;
   END IF;
   IF p_wednesday_hours = -99 THEN
     l_p_wednesday_hours := null;
   END IF;
   IF p_thursday_hours = -99 THEN
     l_p_thursday_hours := null;
   END IF;
   IF p_friday_hours = -99 THEN
     l_p_friday_hours := null;
   END IF;
   IF p_saturday_hours = -99 THEN
     l_p_saturday_hours := null;
   END IF;
   IF p_sunday_hours = -99 THEN
     l_p_sunday_hours := null;
   END IF;

   pa_schedule_utils.debug('pa.plsql.pa_schedule_pub', 'Calling pa_sch_except_pkg.insert_rows', 6);

	 PA_SCH_EXCEPT_PKG.Insert_Rows(
		 p_calendar_id              => p_calendar_id            ,
		 p_assignment_id            => p_assignment_id          ,
		 p_project_id               => p_project_id             ,
		 p_schedule_type_code       => p_assignment_type        ,
			 p_exception_type_code      => 'CHANGE_WORK_PATTERN'    ,
			 p_start_date               => p_start_date             ,
			 p_end_date                 => p_end_date               ,
			 p_monday_hours             => l_p_monday_hours         ,
			 p_tuesday_hours            => l_p_tuesday_hours        ,
			 p_wednesday_hours          => l_p_wednesday_hours      ,
			 p_thursday_hours           => l_p_thursday_hours       ,
			 p_friday_hours             => l_p_friday_hours         ,
			 p_saturday_hours           => l_p_saturday_hours       ,
			 p_sunday_hours             => l_p_sunday_hours         ,
			 x_exception_id             => l_t_exception_id         ,
			 x_return_status            => l_x_return_status        ,
			 x_msg_count                => x_msg_count              ,
			 x_msg_data                 => x_msg_data               );

		 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS AND p_last_row_flag = 'Y') THEN
				-- Calling the change assignment schedule procedure that will generate the changed schedule
				-- of the passed assignment for the given exception i.e change work patern
        pa_schedule_utils.debug('pa.plsql.pa_schedule_pub', 'Calling change_asgn_schedule', 6);
				PA_SCHEDULE_PUB.change_asgn_schedule(
					p_record_version_number => p_record_version_number,
					p_assignment_id => p_assignment_id,
					p_project_id => p_project_id,
					p_exception_id => NULL,
				        p_remove_conflict_flag => p_remove_conflict_flag,
					p_generate_timeline_flag => p_generate_timeline_flag,--Unilog
					x_return_status => l_x_return_status,
					x_msg_count => x_msg_count,
					x_msg_data => x_msg_data);
		 END IF;

		 PA_SCHEDULE_UTILS.log_message(1,'End   of the change_work_pattern API ... ');
		 x_return_status := l_x_return_status;

		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE ,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count ,
					p_msg_data       => x_msg_data ,
					p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;

EXCEPTION
	 WHEN l_out_of_range_date THEN
		 PA_UTILS.add_message('PA','PA_SCH_INVALID_FROM_TO_DATE',
		 'ASMT_TYPE', l_asgn_req_text);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_SCH_INVALID_FROM_TO_DATE';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in change_work_pattern API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- 4537865 : Replaced substr with substrb
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_work_pattern');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
						p_msg_index      => 1,
						p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;

                 RAISE;  -- This is optional depending on the needs
END change_work_pattern;



-- Procedure            : change_status
-- Purpose              : This procedure will change tha status of the passed assignment i.e provisional.confirm
--                        etc. It will change the status only for the passed period i.e start date and end date.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Calendar_Id                NUMBER         NO        Id for that calendar which is associated to this assignment
-- P_Assignment_Id              NUMBER         YES       Assignment id of the changed status  assignment
-- P_Assignment_Type            VARCHAR2       YES       It is type of the assignment e.g OPEN /STAFFED ASSIGNMENT
-- P_Status_Type                VARCHAR2       YES       It is status type.
-- P_Start_Date                 DATE           YES       starting date for the changed status
-- P_End_Date                   DATE           YES       ending date for the changed status
-- P_Assignment_Status_Code     VARCHAR2       YES       Status of the assignment e.g OPEN/CONFIRM/PROVISIONAL
-- P_Asgn_Start_Date            DATE           YES       Start date of the assignment for which you want to
--                                                       change status
-- P_Asgn_End_Date              DATE           YES       End date of the assignment for which you want to
--                                                       change status
-- p_save_to_hist               VARCHAR2       NO        If TRUE, then the change_approval_status proc.
--                                                       is called and the change is saved to the
--                                                       exceptions history.  This is the case when
--                                                       the procedure is called from the UI.
--                                                       If FALSE, the the change_approval_status proc.
--                                                       is not called and the change is not saved to
--                                                       the exceptions history. FALSE should be used in
--                                                       all cases except when called from UI.
--

PROCEDURE change_status
	(
	 p_record_version_number         IN Number          ,
	 p_project_id                    IN Number          ,
	 p_calendar_id                   IN Number          ,
	 p_assignment_id                 IN Number          ,
	 p_assignment_type               IN Varchar2        ,
	 p_status_type                   IN Varchar2        ,
	 p_start_date                    IN date            ,
	 p_end_date                      IN date            ,
	 p_assignment_status_code        IN Varchar2        ,
	 p_asgn_start_date               IN DATE            ,
	 p_asgn_end_date                 IN DATE            ,
	 p_init_msg_list                 IN VARCHAR2 :=  FND_API.G_FALSE,
         p_save_to_hist                  IN VARCHAR2 :=  FND_API.G_TRUE,
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_t_check_cancel                   VARCHAR2(1); --Temp variable
	 l_invalid_asgn_cancelled_date      EXCEPTION;
	 l_stale_asmt_data                  EXCEPTION;
	 l_status_type                      VARCHAR2(30);
	 l_error_message_code               VARCHAR2(50);
	 l_record_version_number            NUMBER;
	 l_person_id                        NUMBER;
	 l_msg_index_out		     NUMBER;
	 l_exception_id          NUMBER;
	 l_return_status         VARCHAR2(1);
	 l_assignment_status_name pa_project_statuses.project_status_name%TYPE;

	 -- For error message tokens
	 l_asgn_req_text                   VARCHAR2(30);
	 l_a_an_text                       VARCHAR2(30);
	 l_asgn_req_poss_text              VARCHAR2(30);
	 l_data VARCHAR2(2000); -- 4537865
	 -- For retrieving project_status_name
   -- 3054787: Select from tables directly to improve performance.
		 CURSOR get_project_status_name IS
			 SELECT pps.project_status_name
				 FROM pa_projects_all ppa, pa_project_statuses pps
				 WHERE ppa.project_id = p_project_id
         AND   ppa.project_status_code = pps.project_status_code;

			 l_project_status_name pa_project_statuses.project_status_name%TYPE;

BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;

	 --Clear the global PL/SQL message table
	 IF FND_API.TO_BOOLEAN( p_init_msg_list ) THEN
			FND_MSG_PUB.initialize;
	 END IF;

	 IF ( p_assignment_type  = 'OPEN_ASSIGNMENT' ) THEN
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_A_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_POSS_TEXT');
	 ELSE
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_AN_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_POSS_TEXT');
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of Change_Status ... ');

         -- p_assignment_status_code should not be null
         IF (p_assignment_status_code is NULL) THEN
   	     PA_UTILS.Add_Message ('PA', 'PA_SCH_ASGN_STATUS_NULL');  -- is this message okay?
             RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 -- The passed dates should fall between the assignment start date and assignment end date */
	 IF ((p_start_date NOT BETWEEN p_asgn_start_date AND p_asgn_end_date ) OR
		 (p_end_date NOT BETWEEN p_asgn_start_date AND p_asgn_end_date )) THEN
			Raise l_out_of_range_date;
	 END IF;

	 -- New Project Status Control added for PRM v1.0.2.
	 -- If extending the staffed assignment duration with a new status, the status should be allowed for the status of the project this assignment belongs to.
	 IF (p_assignment_status_code IS NOT NULL) AND (p_assignment_type <> 'OPEN_ASSIGNMENT') THEN
			l_return_status := PA_ASSIGNMENT_UTILS.is_asgmt_allow_stus_ctl_check(
				p_asgmt_status_code => p_assignment_status_code,
				p_project_id => p_project_id,
        p_add_message => 'N');

			IF l_return_status <> 'Y' THEN
				 OPEN get_project_status_name;
			    FETCH get_project_status_name INTO l_project_status_name;
					CLOSE get_project_status_name;

	  			SELECT project_status_name
						INTO l_assignment_status_name
						FROM pa_project_statuses
						WHERE project_status_code = p_assignment_status_code;

				 RAISE l_asgn_stus_not_for_proj_stus;
		  END IF;
	 END IF;

	 -- Added this code , since status_type is derived parameter.
	 IF p_status_type is NULL then
			if ( p_assignment_type  = 'OPEN_ASSIGNMENT' ) then
				 l_status_type := 'OPEN_ASGMT';
			else
				 l_status_type := 'STAFFED_ASGMT';
			end if;
	 else
			l_status_type := p_status_type;
	 end if;

	 PA_SCHEDULE_UTILS.log_message(1,'Calling Assignment  API ... ');

	 -- Partially cancelled assignments are now possible, so we are removing the
	 -- check.

	 -- Checking the assignment that if it is cancelled then it will not be partialy cancelled it
	 -- should be fully cancelled
	 --	 IF (p_assignment_type = 'OPEN_ASSIGNMENT') THEN
	 --			l_t_check_cancel   := PA_ASSIGNMENT_UTILS.is_open_asgmt_cancelled(
	 --				p_status_code    => p_assignment_status_code,
	 --				p_status_type    => l_status_type);
	 --			IF(UPPER(l_t_check_cancel) = 'Y') THEN
	 --				 IF ((p_start_date <> p_asgn_start_date) OR
	 --					 (p_end_date <> p_asgn_end_date)) THEN
	 --						RAISE l_invalid_asgn_cancelled_date;
	 --				 END IF;
	 --			END IF;
	 --	 ELSIF (p_assignment_type = 'STAFFED_ASSIGNMENT') THEN
	 --			l_t_check_cancel   := PA_ASSIGNMENT_UTILS.is_staffed_asgmt_cancelled(
	 --				p_status_code    => p_assignment_status_code,
	 --				p_status_type    => l_status_type);
	 --			IF(UPPER(l_t_check_cancel) = 'Y') THEN
	 --				 IF ((p_start_date <> p_asgn_start_date) OR
	 --					 (p_end_date <> p_asgn_end_date)) THEN
	 --						RAISE l_invalid_asgn_cancelled_date;
	 --				 END IF;
	 --			END IF;
	 --	 END IF;
	 --	 */

	 PA_SCHEDULE_UTILS.log_message(1,'Start of the change_status API ... ');
	 PA_SCH_EXCEPT_PKG.Insert_Rows(
		 p_calendar_id              => p_calendar_id            ,
		 p_assignment_id            => p_assignment_id          ,
		 p_project_id               => p_project_id             ,
		 p_schedule_type_code       => p_assignment_type        ,
			 p_assignment_status_code   => p_assignment_status_code ,
				 p_exception_type_code      => 'CHANGE_STATUS'          ,
				 p_start_date               => p_start_date             ,
				 p_end_date                 => p_end_date               ,
				 x_exception_id             => l_exception_id         ,
				 x_return_status            => l_x_return_status        ,
				 x_msg_count                => x_msg_count              ,
				 x_msg_data                 => x_msg_data               );

			 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
					-- Calling the procedure change assignment schedule that will
					-- generate the changed schedule for the
					-- passed asignment only for the passed period
					PA_SCHEDULE_PUB.change_asgn_schedule(
						p_record_version_number => p_record_version_number,
						p_assignment_id => p_assignment_id,
						p_project_id => p_project_id,
						p_exception_id => l_exception_id,
						p_save_to_hist => p_save_to_hist,
						x_return_status => l_x_return_status,
						x_msg_count => x_msg_count,
						x_msg_data => x_msg_data);
			 END IF;

			 PA_SCHEDULE_UTILS.log_message(1,'End   of the change_status API ... ');
			 x_return_status := l_x_return_status;

			 x_msg_count := FND_MSG_PUB.Count_Msg;
			 If x_msg_count = 1 THEN
					pa_interface_utils_pub.get_messages
						(p_encoded        => FND_API.G_TRUE ,
						p_msg_index      => 1,
						p_msg_count      => x_msg_count ,
							p_msg_data       => x_msg_data ,
							p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
							p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ; -- 4537865 : NOCOPY related change
			 End If;

EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
              x_return_status := FND_API.G_RET_STS_ERROR;
              x_msg_count := FND_MSG_PUB.Count_Msg;

              IF x_msg_count = 1 THEN
                   pa_interface_utils_pub.get_messages
	        	(p_encoded       => FND_API.G_TRUE,
		         p_msg_index      => 1,
        	         p_data           => x_msg_data,
		         p_msg_index_out  => l_msg_index_out );
              END IF;
	 WHEN l_stale_asmt_data THEN
		 PA_UTILS.add_message('PA','PA_XC_RECORD_CHANGED');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_XC_RECORD_CHANGED';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
						p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_invalid_asgn_cancelled_date THEN
		 PA_UTILS.add_message('PA','PA_INVALID_ASGN_CANCELLED_DATE',
		 'ASMT_TYPE_POSS', l_asgn_req_poss_text,
		 'A_OR_AN', l_a_an_text,
		 'ASMT_TYPE', l_asgn_req_text);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_INVALID_ASGN_CANCELLED_DATE';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_out_of_range_date THEN
		 PA_UTILS.add_message('PA','PA_SCH_INVALID_FROM_TO_DATE',
		 'ASMT_TYPE', l_asgn_req_text);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data  := 'PA_SCH_INVALID_FROM_TO_DATE';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
						p_msg_index      => 1,
						p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_asgn_stus_not_for_proj_stus THEN
		 PA_UTILS.Add_Message( p_app_short_name => 'PA',
			p_msg_name       => 'PA_ASGN_STUS_NOT_FOR_PROJ_STUS',
                        p_token1         => 'PROJ_STATUS',
			p_value1         => l_project_status_name,
			p_token2         => 'ASGN_STATUS',
			p_value2         => l_assignment_status_name);
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_ASGN_STUS_NOT_FOR_PROJ_STUS';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
						p_data           => l_data,  -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
	 WHEN OTHERS THEN
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- 4537865 Replaced substr with substrb
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in change_status API ..'||sqlerrm);
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_status');
			 If x_msg_count = 1 THEN
					pa_interface_utils_pub.get_messages
						(p_encoded        => FND_API.G_TRUE,
						p_msg_index      => 1,
						p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
						p_data           => l_data,   -- 4537865 : Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865 : NOCOPY related change
			 End If;
                 RAISE;  -- This is optional depending on the needs
END change_status;

--
-- Procedure            : change_calendar
-- Purpose              : This procedure will change the calendar for the passed assignment But it will
--                        change the calendar only for the passed period i.e start date and end date.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Project_Id                 NUMBER         YES       project id of the associated calendar
-- P_Calendar_Id                NUMBER         YES       Id for that calendar which is associated to this assignment
-- P_Calendar_Name              VARCHAR2       YES       It is the name of the calendar
-- P_Assignment_Id              NUMBER         YES       Assignment id of the changed calendar  assignment
-- P_Assignment_Type            VARCHAR2       YES       It is type of the assignment e.g OPEN /STAFFED ASSIGNMENT
-- P_Start_Date                 DATE           YES       starting date for the changed calendar
-- P_End_Date                   DATE           YES       ending date for the changed calendar
-- P_Asgn_Start_Date            DATE           YES       Start date of the assignment for which you want to
--                                                       change calendar
-- P_Asgn_End_Date              DATE           YES       End date of the assignment for which you want to
--                                                       change calendar
--

PROCEDURE change_calendar
	(
	 p_record_version_number         IN Number          ,
	 p_project_id                    IN Number          ,
	 p_calendar_id                   IN Number          ,
	 p_calendar_name                 IN varchar2          ,
	 p_assignment_id                 IN Number          ,
	 p_assignment_type               IN Varchar2        ,
	 p_start_date                    IN date            ,
	 p_end_date                      IN date            ,
	 p_asgn_start_date               IN DATE            ,
	 p_asgn_end_date                 IN DATE            ,
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_t_exception_id                   NUMBER; -- temp variable
	 l_calendar_id                      NUMBER; -- temp variable
	 l_invalid_duplicate_cal_name       EXCEPTION;
	 l_msg_index_out		     NUMBER;
	 l_data VARCHAR2(2000) ; -- 4537865
	 -- For error message tokens
	 l_asgn_req_text                   VARCHAR2(30);
	 l_a_an_text                       VARCHAR2(30);
	 l_asgn_req_poss_text              VARCHAR2(30);
BEGIN
	 -- storing the status success to track the error
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;

	 --Clear the global PL/SQL message table
	 fnd_msg_pub.initialize;

	 IF ( p_assignment_type  = 'OPEN_ASSIGNMENT' ) THEN
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_A_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_REQUIREMENT_POSS_TEXT');
	 ELSE
			l_asgn_req_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_TEXT');
			l_a_an_text := FND_MESSAGE.GET_STRING('PA','PA_AN_TEXT');
			l_asgn_req_poss_text := FND_MESSAGE.GET_STRING('PA','PA_ASSIGNMENT_POSS_TEXT');
	 END IF;

	 -- Current functionality allows user to change the work patern by specifing the calendar
	 -- for the whole period so we don't need to check the start /end date for null.
	 -- End date or Start date or both  should not be null for the change calendar
	 --  IF ((p_start_date IS NULL) OR (p_end_date IS NULL)) THEN
	 --     RAISE l_from_to_date_null;
	 --   END IF;

	 -- If the user select  calendar name only then taking the calendar id
	 IF (p_calendar_id IS NULL ) THEN
BEGIN
				 SELECT calendar_id
					 INTO l_calendar_id
					 FROM jtf_calendars_vl
					 WHERE calendar_name = p_calendar_name;


				 x_msg_count := FND_MSG_PUB.Count_Msg;
				 If x_msg_count = 1 THEN
						pa_interface_utils_pub.get_messages
							(p_encoded        => FND_API.G_TRUE ,
							p_msg_index      => 1,
							p_msg_count      => x_msg_count ,
							p_msg_data       => x_msg_data ,
							p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
							p_msg_index_out  => l_msg_index_out );
						x_msg_data := l_data ;  -- 4537865 : NOCOPY related change
				 End If;

EXCEPTION
	 WHEN NO_DATA_FOUND or TOO_MANY_ROWS THEN
		 RAISE l_invalid_duplicate_cal_name;
	 WHEN OTHERS THEN
		 Raise;
END;
	 ELSE
			l_calendar_id := p_calendar_id;
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of the change_calendar API ... ');
	 PA_SCH_EXCEPT_PKG.Insert_Rows(
		 p_calendar_id              => l_calendar_id            ,
		 p_assignment_id            => p_assignment_id          ,
		 p_project_id               => p_project_id             ,
		 p_schedule_type_code       => p_assignment_type        ,
		 p_exception_type_code      => 'CHANGE_CALENDAR'        ,
		 p_start_date               => p_start_date             ,
		 p_end_date                 => p_end_date               ,
		 x_exception_id             => l_t_exception_id           ,
		 x_return_status            => l_x_return_status          ,
		 x_msg_count                => x_msg_count              ,
		 x_msg_data                 => x_msg_data               );

	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			-- Calling the change assignment schedule procedure that will generate the changed schedule
			-- according to the passed calendar but only for given period
			PA_SCHEDULE_PUB.change_asgn_schedule(
				p_record_version_number => p_record_version_number,
				p_assignment_id => p_assignment_id,
				p_project_id => p_project_id,
				p_exception_id => l_t_exception_id,
				x_return_status => l_x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data);
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'End   of the change_calendar API ... ');
	 x_return_status := l_x_return_status;

	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
				p_data           => l_data, -- 4537865 : Replaced x_msg_data with l_data
				p_msg_index_out  => l_msg_index_out );
			x_msg_data := l_data ;  -- 4537865 : NOCOPY related change
	 End If;


EXCEPTION
	 WHEN l_invalid_duplicate_cal_name THEN
		 PA_UTILS.add_message('PA','PA_CALENDAR_INVALID_AMBIGOUS');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_CALENDAR_INVALID_AMBIGOUS';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, --  4537865 :Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ;  -- 4537865 : NOCOPY related change
		 End If;
	 WHEN l_from_to_date_null THEN
		 PA_UTILS.add_message('PA','PA_SCH_FROM_TO_DATE_NULL');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data      := 'PA_SCH_FROM_TO_DATE_NULL';
		 x_msg_count := FND_MSG_PUB.Count_Msg;
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865 :Replaced x_msg_data with l_data
					p_msg_index_out  => l_msg_index_out );
                                x_msg_data := l_data ;  -- 4537865 : NOCOPY related change
		 End If;
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in change_calendar API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- Changed substr to substrb : 4537865
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_calendar');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
						p_data           => l_data, -- 4537865 :Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ;  -- 4537865 : NOCOPY related change
		 End If;
END change_calendar;



-- Procedure            : change_schedule
-- Purpose              : Once the schedule is created for the assignment it cane be changed by this procedure  on the basis of its exception.
-- This procedure does not seem to be used.

PROCEDURE change_schedule
 (x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data            OUT NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_msg_index_out		     NUMBER;
	 l_data varchar2(2000) ; -- 4537865

	 -- This cursor will select the distinct assignment id
	 CURSOR csr_sch_excp IS
		 SELECT distinct a.assignment_id, b.record_version_number, b.project_id
			 FROM pa_schedule_exceptions a , pa_project_assignments b
			 WHERE a.assignment_id = b.assignment_id
			 ORDER by a.assignment_id;
BEGIN
	 -- store the status success to track the error
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of the change_schedule API ... ');

	 FOR rec_sch_excp  IN  csr_sch_excp LOOP
			PA_SCHEDULE_UTILS.log_message(1,
				'Schedule Exception table - assignment Id :'||
				to_char(rec_sch_excp.assignment_id));
			-- Calling the procedure change_asgn_schedule that will generate the
			-- change schedule for the passed start date and end date
			PA_SCHEDULE_PUB.change_asgn_schedule(
				p_record_version_number => rec_sch_excp.record_version_number,
				p_assignment_id => rec_sch_excp.assignment_id,
				p_project_id => rec_sch_excp.project_id,
				p_exception_id => null,
				x_return_status => l_x_return_status,
				x_msg_count => x_msg_count,
				x_msg_data => x_msg_data);
	 END LOOP;
	 PA_SCHEDULE_UTILS.log_message(1,'End   of the change_schedule API ... ');

	 x_return_status := l_x_return_status;

	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
					p_msg_count      => x_msg_count ,
					p_msg_data       => x_msg_data ,
					p_data           => l_data, -- 4537865 :Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865 : NOCOPY related change
	 End If;

EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in change_schedule API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- 4537865 : Replaced substr usage with substrb
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_schedule');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE ,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count ,
					p_msg_data       => x_msg_data ,
						p_data           => l_data,  -- 4537865 :Replaced x_msg_data with l_data
						p_msg_index_out  => l_msg_index_out );
				 x_msg_data := l_data ; -- 4537865 : NOCOPY related change
		 End If;
		 RAISE;  -- This is optional depending on the needs
END change_schedule;



-- Procedure            : change_asgn_schedule
-- Purpose              : This procedure will be called from each schedule change page via
--                        workflow. This procedure will apply the exceptions for the assignment
--                        on the assignment schedules.
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Assignment_Id              NUMBER         YES       Assignment id for the changed assignment
-- P_Exception_Id               NUMBER         YES       Exception id for changing ths chedule of the
--                                                       assiciated assignment
-- p_save_to_hist               VARCHAR2       NO        If TRUE, then the change_approval_status proc.
--                                                       is called and the change is saved to the
--                                                       exceptions history.  This is the case when
--                                                       the procedure is called from the UI.
--                                                       If FALSE, the the change_approval_status proc.
--                                                       is not called and the change is not saved to
--                                                       the exceptions history. FALSE should be used in
--                                                       all cases except when called from UI.

PROCEDURE change_asgn_schedule(
	p_record_version_number   IN  NUMBER,
	p_assignment_id   IN  NUMBER,
	p_project_id      IN NUMBER,
	p_exception_id    IN  NUMBER,
	p_save_to_hist    IN VARCHAR2 :=  FND_API.G_TRUE,
	p_remove_conflict_flag IN VARCHAR2 := 'N',
	p_generate_timeline_flag IN VARCHAR2 :=	'Y', --Unilog
	p_called_by_proj_party    IN VARCHAR2 := 'N', -- Added for Bug 6631033
	x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
	x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
															)
IS
	 l_msg_index_out		     NUMBER;
	 l_record_version_number NUMBER;

	 l_data VARCHAR2(2000); -- 4537865
   -- jmarques: 1776658: Local variables for storing new duration and
   -- old duration.
   l_new_start_date DATE := NULL;
   l_new_end_date	DATE := NULL;
   l_old_start_date DATE := NULL;
   l_old_end_date	DATE := NULL;
   l_resource_id NUMBER := NULL;

	 CURSOR csr_sch_excp IS
		 SELECT calendar_id,
			 schedule_exception_id,
			 assignment_id,
			 project_id,
			 status_code,
			 schedule_type_code,
			 exception_type_code,
			 resource_calendar_percent,
			 non_working_day_flag,
			 change_hours_type_code,
                         change_calendar_type_code,
                        -- change_calendar_name,
 			 change_calendar_id,
 		         duration_shift_type_code,
                         duration_shift_unit_code,
                         number_of_shift,
			 start_date,
			 end_date,
			 Monday_hours,
			 Tuesday_hours,
			 Wednesday_hours,
			 Thursday_hours,
			 Friday_hours,
			 saturday_hours,
			 Sunday_hours
			 FROM   pa_schedule_exceptions
			 WHERE  assignment_id = p_assignment_id
			 AND    ((p_exception_id   IS NULL)  OR
			 (schedule_exception_id = p_exception_id))
			 ORDER BY schedule_exception_id;

		 l_tr_sch_rec_tab          PA_SCHEDULE_GLOB.ScheduleTabTyp;
		 l_sch_except_record_tab   PA_SCHEDULE_GLOB.SchExceptTabTyp;
		 l_sch_except_rec          PA_SCHEDULE_GLOB.SchExceptRecord;
		 l_chg_tr_sch_rec_tab      PA_SCHEDULE_GLOB.ScheduleTabTyp;
		 l_out_tr_sch_rec_tab      PA_SCHEDULE_GLOB.ScheduleTabTyp;
		 l_del_tr_sch_rec_tab      PA_SCHEDULE_GLOB.ScheduleTabTyp;
		 l_I                       NUMBER;
		 l_p_start_id              NUMBER;
		 l_p_end_id                NUMBER;
		 l_apply_schedule_changes  BOOLEAN;
		 l_change_id               PA_SCHEDULES_HISTORY.change_id%type;
		 l_temp_status_code        PA_PROJECT_ASSIGNMENTS.status_code%type;

		 l_save_to_hist VARCHAR2(1); -- Unilog
		 l_record_version_number_wo_chg NUMBER; -- Unilog
		 l_exception_type_code VARCHAR2(100);  --7663765

BEGIN
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;

	 PA_SCHEDULE_UTILS.log_message(1,'Start of the change_asgn_schedule API ... ');

	 -- Unilog Begin
	 l_save_to_hist := p_save_to_hist;
	 IF p_generate_timeline_flag = 'N' THEN -- It means it is called from WeeklySchedule
		l_save_to_hist := FND_API.G_FALSE;
	 END IF;
	 -- Also now we should be using l_save_to_hist instead of p_save_to_hist
	 -- Unilog End

   -- Initializing local variables in case next procedure is not called.
   l_record_version_number := p_record_version_number;

    -- Updates the assignment's approval status to WORKING which
    -- copies the history records into the assignment and schedule
    -- history tables.
      -- This if statement was added so that the approval status is not
      -- updated in all situations.  For example, the approval status
      -- should not be updated when changing the status after failure
      -- or success.  This is a work around and will be removed when the
      -- approval flow is redesigned.
    -- Bug 2135616: when this is called by PA_SCHEDULE_PVT.resolve_conflicts to remove
    -- conflicts, the approval status should not change.
	IF (FND_API.TO_BOOLEAN(NVL(l_save_to_hist,FND_API.G_TRUE))
      AND p_remove_conflict_flag = 'N') THEN

			   pa_assignment_approval_pvt.update_approval_status(
				   p_assignment_id => p_assignment_id,
				   p_action_code => PA_ASSIGNMENT_APPROVAL_PUB.g_update_action,
				   p_record_version_number => p_record_version_number,
				   x_record_version_number => l_record_version_number,
				   x_change_id => l_change_id,
				   x_apprvl_status_code => l_temp_status_code,
				   x_return_status => l_x_return_status,
				   x_msg_count => x_msg_count,
				   x_msg_data => x_msg_data);
        ELSE
            l_record_version_number := p_record_version_number;
            l_change_id := PA_ASSIGNMENT_APPROVAL_PVT.Get_Change_Id(p_assignment_id);
	END IF;


	 l_apply_schedule_changes := FALSE;

	 PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API get_assignment_schedule ....');

	 -- Calling the PVT API This api will bring the asignment schedule for the passed
	 -- asignment id and it will store the schedule in tabel of record i.e l_tr_sch_rec_tab.
	 PA_SCHEDULE_PVT.get_assignment_schedule(p_assignment_id,
		 l_tr_sch_rec_tab,
		 l_x_return_status,
		 x_msg_count,
		 x_msg_data );

	 PA_SCHEDULE_UTILS.log_message(1,'START ASSG SCHEDULE ',l_tr_sch_rec_tab );
	 PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API get_assignment_schedule ....');

	 l_I := 1;

	 -- Copying the exceptions of the given assignment
	 FOR rec_sch_excp  IN  csr_sch_excp LOOP
			l_apply_schedule_changes := TRUE;
			l_sch_except_record_tab(l_i).calendar_id                 := rec_sch_excp.calendar_id;
			l_sch_except_record_tab(l_i).schedule_exception_id       := rec_sch_excp.schedule_exception_id;
			l_sch_except_record_tab(l_i).assignment_id               := rec_sch_excp.assignment_id;
			l_sch_except_record_tab(l_i).project_id                  := rec_sch_excp.project_id;
			l_sch_except_record_tab(l_i).assignment_status_code      := rec_sch_excp.status_code;
			l_sch_except_record_tab(l_i).schedule_type_code          := rec_sch_excp.schedule_type_code;
			l_sch_except_record_tab(l_i).exception_type_code         := rec_sch_excp.exception_type_code;
			l_sch_except_record_tab(l_i).resource_calendar_percent   := rec_sch_excp.resource_calendar_percent;
			l_sch_except_record_tab(l_i).non_working_day_flag        := rec_sch_excp.non_working_day_flag;
			l_sch_except_record_tab(l_i).change_hours_type_code      := rec_sch_excp.change_hours_type_code;
			l_sch_except_record_tab(l_i).change_calendar_type_code   := rec_sch_excp.change_calendar_type_code;
			--l_sch_except_record_tab(l_i).change_calendar_name        := rec_sch_excp.change_calendar_name;
			l_sch_except_record_tab(l_i).change_calendar_id          := rec_sch_excp.change_calendar_id;
			l_sch_except_record_tab(l_i).duration_shift_type_code    := rec_sch_excp.duration_shift_type_code;
			l_sch_except_record_tab(l_i).duration_shift_unit_code    := rec_sch_excp.duration_shift_unit_code;
			l_sch_except_record_tab(l_i).number_of_shift             := rec_sch_excp.number_of_shift;
			l_sch_except_record_tab(l_i).start_date                  := rec_sch_excp.start_date;
			l_sch_except_record_tab(l_i).end_date                    := rec_sch_excp.end_date;
			l_sch_except_record_tab(l_i).Monday_hours                := rec_sch_excp.Monday_hours;
			l_sch_except_record_tab(l_i).Tuesday_hours               := rec_sch_excp.Tuesday_hours;
			l_sch_except_record_tab(l_i).Wednesday_hours             := rec_sch_excp.Wednesday_hours;
			l_sch_except_record_tab(l_i).Thursday_hours              := rec_sch_excp.Thursday_hours;
			l_sch_except_record_tab(l_i).Friday_hours                := rec_sch_excp.Friday_hours;
			l_sch_except_record_tab(l_i).saturday_hours              := rec_sch_excp.saturday_hours;
			l_sch_except_record_tab(l_i).Sunday_hours                := rec_sch_excp.sunday_hours;
			l_sch_except_rec.assignment_id               := rec_sch_excp.assignment_id;
			l_sch_except_rec.calendar_id                 := rec_sch_excp.calendar_id;
			l_sch_except_rec.schedule_exception_id       := rec_sch_excp.schedule_exception_id;
			l_sch_except_rec.project_id                  := rec_sch_excp.project_id;
			l_sch_except_rec.assignment_status_code      := rec_sch_excp.status_code;
			l_sch_except_rec.schedule_type_code          := rec_sch_excp.schedule_type_code;
			l_sch_except_rec.exception_type_code         := rec_sch_excp.exception_type_code;
			l_sch_except_rec.resource_calendar_percent   := rec_sch_excp.resource_calendar_percent;
			l_sch_except_rec.non_working_day_flag        := rec_sch_excp.non_working_day_flag;
			l_sch_except_rec.change_hours_type_code      := rec_sch_excp.change_hours_type_code;
			l_sch_except_rec.change_calendar_type_code   := rec_sch_excp.change_calendar_type_code;
			--l_sch_except_rec.change_calendar_name        := rec_sch_excp.change_calendar_name;
			l_sch_except_rec.change_calendar_id          := rec_sch_excp.change_calendar_id;
			l_sch_except_rec.duration_shift_type_code    := rec_sch_excp.duration_shift_type_code;
			l_sch_except_rec.duration_shift_unit_code    := rec_sch_excp.duration_shift_unit_code;
			l_sch_except_rec.number_of_shift             := rec_sch_excp.number_of_shift;
			l_sch_except_rec.start_date                  := rec_sch_excp.start_date;
			l_sch_except_rec.end_date                    := rec_sch_excp.end_date;
			l_sch_except_rec.Monday_hours                := rec_sch_excp.Monday_hours;
			l_sch_except_rec.Tuesday_hours               := rec_sch_excp.Tuesday_hours;
			l_sch_except_rec.Wednesday_hours             := rec_sch_excp.Wednesday_hours;
			l_sch_except_rec.Thursday_hours              := rec_sch_excp.Thursday_hours;
			l_sch_except_rec.Friday_hours                := rec_sch_excp.Friday_hours;
			l_sch_except_rec.saturday_hours              := rec_sch_excp.saturday_hours;
			l_sch_except_rec.Sunday_hours                := rec_sch_excp.sunday_hours;

		        l_exception_type_code := rec_sch_excp.exception_type_code ; -- 7663765

			IF (l_I  > 1) THEN
				 PA_SCHEDULE_UTILS.log_message(1,'Index Value :' || to_char(l_i));
				 l_tr_sch_rec_tab.delete;


				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						-- This procedure will copy  the schedule record from one table of record to another
						PA_SCHEDULE_UTILS.copy_schedule_rec_tab(
							l_chg_tr_sch_rec_tab,
							l_chg_tr_sch_rec_tab.first,
							l_chg_tr_sch_rec_tab.last,
							l_tr_sch_rec_tab,
							l_x_return_status,
							x_msg_count,
							x_msg_data
																									 );
				 END IF;

				 PA_SCHEDULE_UTILS.log_message(1,'after copy schedule : ',l_tr_sch_rec_tab );
			END IF;

			IF (rec_sch_excp.exception_type_code = 'CHANGE_DURATION' OR
                            rec_sch_excp.exception_type_code = 'SHIFT_DURATION' OR rec_sch_excp.exception_type_code = 'DURATION_PATTERN_SHIFT') then -- 7663765
				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						-- calling PVT API that will change the duration and generate a new schedule
						-- on the basis of passed schedule  and exception record
						PA_SCHEDULE_PVT.apply_change_duration(l_tr_sch_rec_tab,
							l_sch_except_rec,
							l_out_tr_sch_rec_tab,
							l_x_return_status,
							x_msg_count,
							x_msg_data);

   			         	   -- jmarques: 1776658: Store new duration.
         				   l_new_start_date := l_sch_except_rec.start_date;
         				   l_new_end_date := l_sch_except_rec.end_date;
				 END IF;

				 PA_SCHEDULE_UTILS.log_message(1,'after change_duration : ',l_out_tr_sch_rec_tab );
			ELSE

				 PA_SCHEDULE_UTILS.log_message(1,'after change_duration : ' );

				 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
						-- calling PVT API that will apply the changes
						PA_SCHEDULE_UTILS.log_message (1,' IN THE ELSE PART AND starting of apply other changes ');
            PA_SCHEDULE_UTILS.log_message(1, 'Calling apply_other_changes1 :', l_tr_sch_rec_tab);
            --PA_SCHEDULE_UTILS.log_message(1, 'Calling apply_other_changes2 :', l_sch_except_rec);
						PA_SCHEDULE_PVT.apply_other_changes(l_tr_sch_rec_tab,
							l_sch_except_rec,
							l_out_tr_sch_rec_tab,
							l_x_return_status,
							x_msg_count,
							x_msg_data
																							 );
				 END IF;

				 PA_SCHEDULE_UTILS.log_message(1,'after change_others : ',l_out_tr_sch_rec_tab );
			END IF;

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- seperating the deleted or non deleted record i.e inserted or updated
				 PA_SCHEDULE_UTILS.sep_del_sch_rec_tab(l_out_tr_sch_rec_tab,
					 l_del_tr_sch_rec_tab,
					 l_chg_tr_sch_rec_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data
																							);
			END IF;

			l_I := l_I + 1;

			PA_SCHEDULE_UTILS.log_message(1,'after delete seperate (change ) : ',l_chg_tr_sch_rec_tab );
			PA_SCHEDULE_UTILS.log_message(1,'after delete seperate (delete ) : ',l_del_tr_sch_rec_tab );

	 END LOOP;

	 PA_SCHEDULE_UTILS.log_message(1,'FINAL (change ) : ',l_chg_tr_sch_rec_tab );
	 PA_SCHEDULE_UTILS.log_message(1,'FINAL (delete ) : ',l_del_tr_sch_rec_tab );

	 IF ( l_apply_schedule_changes ) THEN
             /* Added below for 7663765 */
	      if (l_exception_type_code = 'DURATION_PATTERN_SHIFT') then
		delete pa_schedules where assignment_id = p_assignment_id;
	      end if;

			PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API apply_schedule_change ....');

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Calling the PVT api that will change the schedule
				 PA_SCHEDULE_PVT.apply_schedule_change(l_chg_tr_sch_rec_tab,
					 l_del_tr_sch_rec_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data);
			END IF;

			PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API apply_schedule_change ....');

  		IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			   -- Calling the API PA_SCHEDULE_PVT.apply_assignment_change

                    -- jmarques: 1776658: Get old duration.
                    select start_date, end_date, resource_id, record_version_number -- Unilog Selected record_version_number too
                    into l_old_start_date, l_old_end_date, l_resource_id, l_record_version_number_wo_chg
                    from pa_project_assignments
                    where assignment_id = p_assignment_id;

		    -- Unilog Added this IF condition
		    IF p_generate_timeline_flag = 'N' THEN
			l_record_version_number := l_record_version_number_wo_chg;
		    END IF;

                    -- jmarques: 1776658: Fix variables so that no null values are present.
                    l_new_start_date := NVL(l_new_start_date, l_old_start_date);
                    l_new_end_date := NVL(l_new_end_date, l_old_end_date);

				 PA_SCHEDULE_PVT.apply_assignment_change(
				   p_record_version_number => l_record_version_number,
				   chg_tr_sch_rec_tab => l_chg_tr_sch_rec_tab,
				   sch_except_record_tab => l_sch_except_record_tab,
				   p_called_by_proj_party  => p_called_by_proj_party, -- Added for Bug 6631033
					 x_return_status => l_x_return_status,
					 x_msg_count => x_msg_count,
					 x_msg_data => x_msg_data);
		END IF;

			PA_SCHEDULE_UTILS.log_message(1, 'Before Calling the API delete_rows ....');

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 -- Deleting the rows from pa_schedule_exception table
				 PA_SCH_EXCEPT_PKG.delete_rows(l_sch_except_record_tab,
					 l_x_return_status,
					 x_msg_count,
					 x_msg_data
																			);
			END IF;

			PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API delete_rows ..');

			-- inserting  the rows from schedule except history table
			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 IF (FND_API.TO_BOOLEAN(NVL(l_save_to_hist,FND_API.G_TRUE))) THEN
						PA_SCH_EXCEPT_HIST_PKG.insert_rows(
							l_sch_except_record_tab,
							l_change_id,
							l_x_return_status,
							x_msg_count,
							x_msg_data
																							);
				 END IF;
			END IF;

			PA_SCHEDULE_UTILS.log_message(1, 'After Calling the API insert_rows ....');
	 END IF;

	IF p_generate_timeline_flag = 'Y' THEN	 --Unilog

	 -- Calling the Timeline api  to create the timeline records
	 -- for the assignment
	 IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_SCHEDULE_UTILS.log_message(1,'Calling Timeline  API ..... ');
			PA_SCHEDULE_UTILS.log_message(1, 'Num: ' || FND_MSG_PUB.Count_Msg);
			PA_TIMELINE_PVT.create_timeline (
				p_assignment_id =>p_assignment_id        ,
				x_return_status =>l_x_return_status      ,
				x_msg_count     =>x_msg_count            ,
				x_msg_data      =>x_msg_data             );


	      -- jmarques: 1776658: If the duration has changed, then create the
	      -- resource timeline (recalculates availability) for the parts of
	      -- the old duration which do not overlap the new duration.

	      IF (l_old_start_date < l_new_start_date AND l_resource_id is not null) THEN
		    IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			pa_timeline_pvt.Create_Timeline (
                          p_start_resource_name => NULL,
                          p_end_resource_name => NULL,
                          p_resource_id => l_resource_id,
                          p_start_date => l_old_start_date,
                          p_end_date => l_new_start_date,
                          x_return_status => l_x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);
		    END IF;
	      END IF;

	      IF (l_old_end_date > l_new_end_date AND l_resource_id is not null) THEN
		    IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			 pa_timeline_pvt.Create_Timeline (
                          p_start_resource_name => NULL,
                          p_end_resource_name => NULL,
                          p_resource_id => l_resource_id,
                          p_start_date => l_new_end_date,
                          p_end_date => l_old_end_date,
                          x_return_status => l_x_return_status,
                          x_msg_count => x_msg_count,
                          x_msg_data => x_msg_data);
		    END IF;
	      END IF;
	 END IF;
	END IF; -- Unilog

	 PA_SCHEDULE_UTILS.log_message(1,'End of the change_asgn_schedule API ... ');
	 x_return_status := l_x_return_status;

	 x_msg_count := FND_MSG_PUB.Count_Msg;

	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count ,
					p_msg_data       => x_msg_data ,
						p_data           => l_data, -- 4537865
						p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865
	 End If;

EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in change_asgn_schedule API ..'
		 ||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- 4537865 : Changed substr to substrb
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_asgn_schedule');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE ,
					p_msg_index      => 1,
						p_msg_count      => x_msg_count ,
						p_msg_data       => x_msg_data ,
						p_data           => l_data,  -- 4537865
						p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865
		 End If;
                 RAISE;  -- This is optional depending on the needs
END change_asgn_schedule;

-- Procedure            : create_calendar_schedule
-- Purpose              : This procedure is called from periodic process for creating calendar schedule
--                        . It will generate the new schedule on the basi of passed calendar id
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Calendar_Id                NUMBER         YES       Id for that calendar for which you want to create schedule
--

PROCEDURE create_calendar_schedule ( p_calendar_id            IN   NUMBER,
																		 x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																		 x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
																		 x_msg_data               OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

	 l_x_cal_record_tab            PA_SCHEDULE_GLOB.CalendarTabTyp;
	 l_schedule_rec_tab            PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_x_sch_record_tab            PA_SCHEDULE_GLOB.ScheduleTabTyp;
	 l_x_cal_except_record_tab     PA_SCHEDULE_GLOB.calExceptionTabTyp;
	 l_msg_index_out		     NUMBER;
	 l_data varchar2(2000) ;-- 4537865
BEGIN
	 PA_SCHEDULE_UTILS.log_message(1,'Start of the create_calendar_schedule API ... ');
	 -- storing the status success to track the error
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;

	 -- Calling the Calendar API that will give the shift assign to the calendar*/
	 PA_CALENDAR_UTILS.get_calendar_shifts(p_calendar_id,l_x_cal_record_tab,l_x_return_status,x_msg_count,x_msg_data);

	 IF ( l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			PA_CALENDAR_UTILS.gen_calendar_sch(p_calendar_id,l_x_cal_record_tab,l_schedule_rec_tab,l_x_return_status,
				x_msg_count,x_msg_data);

	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'GEN SCH ',l_schedule_rec_tab);
	 IF ( l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			-- Calling the PA_CALENDAR_UTILS API that will take the exception associated with the calendar
			PA_CALENDAR_UTILS.get_calendar_except(p_calendar_id,l_x_cal_except_record_tab,l_x_return_status,
				x_msg_count,x_msg_data);

	 END IF;

	 IF ( l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN

			-- Calling the PA_CALENDAR_UTILS API that will generate the calendar schedule after applying the exception
			PA_CALENDAR_UTILS.apply_calendar_except(p_calendar_id,l_x_cal_except_record_tab,l_schedule_rec_tab,
				l_x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);

	 END IF;

	 IF ( l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
			--  Inserting the records in PA_SCHEDULES table
			PA_SCHEDULE_PKG.insert_rows(l_x_sch_record_tab,l_x_return_status,x_msg_count,x_msg_data);

	 END IF;
         /** Added call to update_wp_calendar for all projects **/
    -- Start Of Bug No :4666318
    --Commented for Bug No:4666318
    -- This functionality was originally introduced in FP.K .But It was removed in FP.M.
   /*   PA_PROJECT_STRUCTURE_PVT1.update_all_wp_calendar
                                    (     p_calendar_id      => p_calendar_id
                                         ,x_return_status    => x_return_status
                                         ,x_msg_count        => x_msg_count
                                         ,x_msg_data         => x_msg_data
                                     );*/
    -- End Of Bug No : 4666318

	 PA_SCHEDULE_UTILS.log_message(1,'End   of the create_calendar_schedule API ... ');

	 x_return_status := l_x_return_status;
	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
				p_data           => l_data, -- 4537865
				p_msg_index_out  => l_msg_index_out );
				x_msg_Data := l_data ;-- 4537865
	 End If;
EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in create_calendar_schedule API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- 4537865 changed substr to substrb
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'create_calendar_schedule');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865
					p_msg_index_out  => l_msg_index_out );
				x_msg_Data := l_data ;-- 4537865
		 End If;
		 RAISE;  -- This is optional depending on the needs
END create_calendar_schedule;

-- Procedure            : get_proj_calendar_default
-- Purpose              : This procedure is called for getting the default calendar for the project.
--                        This will be called from projects form
--
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Proj_Organization          NUMBER         YES       project organization
-- P_Project_Id                 NUMBER         YES       project id
-- Out parameters
-- X_Calendar_Id                NUMBER       YES       It stores the id for the calendar
-- X_Calendar_Name              VARCHAR2       YES       It stores name of the  calendar
--

PROCEDURE get_proj_calendar_default ( p_proj_organization     IN   NUMBER,
					p_project_id            IN   NUMBER,
					x_calendar_id            OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
					x_calendar_name          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
					x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
					x_msg_data               OUT  NOCOPY VARCHAR2 ) IS --File.Sql.39 bug 4440895
	 l_no_calendar_at_org   BOOLEAN;
	 l_temp_calendar_id     VARCHAR2(80);
	 l_null_default_calendar  EXCEPTION;
	 l_invalid_default_calendar  EXCEPTION;
	 l_t_carrying_out_org_id PA_PROJECTS.carrying_out_organization_id%TYPE; -- To store the orgnaization id
	 L_MSG_INDEX_OUT NUMBER;

	 l_data varchar2(2000); -- 4537865
BEGIN
	 PA_SCHEDULE_UTILS.log_message(1,'Start of the get_proj_calendar_default API ... ');

	 l_x_return_status := FND_API.G_RET_STS_SUCCESS ;
	 l_no_calendar_at_org := FALSE;

/* Bug2873984
   IF (PA_INSTALL.IS_PRM_LICENSED() <> 'Y') THEN
	    PA_SCHEDULE_UTILS.log_message(1,'PRM is not licensed, so returning null.');
      x_calendar_id := null;
      x_calendar_name := null;
      x_return_status := l_x_return_status;
      return;
   END IF;  */

	 PA_SCHEDULE_UTILS.log_message(1,'PRM is licensed, so continuing.');

	 -- Taking out the orgnization id for passing to the get_proj_calendar_default */
	 IF (p_project_id IS NOT NULL ) THEN
BEGIN
        -- Modified to select from PA_PROJECTS_ALL instead of PA_PROJECTS.
				 SELECT carrying_out_organization_id
					 INTO l_t_carrying_out_org_id
					 FROM PA_PROJECTS_ALL
					 WHERE project_id = p_project_id;

EXCEPTION
	 WHEN NO_DATA_FOUND THEN
		 x_return_status  := FND_API.G_RET_STS_ERROR;
		 RAISE;
END;
	 ELSE
			l_t_carrying_out_org_id  := p_proj_organization;
	 END IF;

	 BEGIN
			PA_SCHEDULE_UTILS.log_message(1,'before select on hr_org.... ');

			-- Taking the calendar on the basis of organization assigned to the project
                        -- R12 changes - the calendar is now stored
                        -- under a new information type - Resource Defaults
                        -- in a different column

			--SELECT TO_NUMBER(hr1.org_information2) ,
			SELECT TO_NUMBER(hr1.org_information1) ,
			       cal1.calendar_name
			INTO   x_calendar_id ,
			       x_calendar_name
			FROM   hr_organization_information hr1,
			       jtf_calendars_vl cal1
	--WHERE cal1.calendar_id = TO_NUMBER(hr1.org_information2) BUG 3530529
		-- WHERE TO_CHAR(cal1.calendar_id)  = hr1.org_information2
			WHERE TO_CHAR(cal1.calendar_id)  = hr1.org_information1
			AND   hr1.organization_id  = l_t_carrying_out_org_id
		--AND hr1.org_information_context = 'Exp Organization Defaults';
			AND   hr1.org_information_context = 'Resource Defaults';

			PA_SCHEDULE_UTILS.log_message(1,'after select on hr_org.... ');
	 EXCEPTION
			WHEN NO_DATA_FOUND THEN
				PA_SCHEDULE_UTILS.log_message(1,'inside no data found for  select on hr_org.... ');
				l_no_calendar_at_org := TRUE;
			WHEN OTHERS THEN
				PA_SCHEDULE_UTILS.log_message(1,'ERROR while excuting select on hr_org.... '||sqlerrm);
				RAISE;
	 END;

	 -- If no calendar is associated with the organization the we will take the calendar which will be
	 -- assiciated with the PROFILE
	 IF ( l_no_calendar_at_org ) THEN
			FND_PROFILE.GET('PA_PRM_DEFAULT_CALENDAR',l_temp_calendar_id);

			IF ( l_temp_calendar_id is NULL ) THEN
				/* Commented for bug 2873984
				 x_msg_data := 'Default Calendar not assigned to profile option PA_PRM_CALENDAR';
				 RAISE l_null_default_calendar; */
				/* Code Addition for bug 2873984 starts */
			         x_calendar_id := null;
			         x_calendar_name := null;
				/* Code Addition for bug 2873984 ends */
			ELSE
				 PA_SCHEDULE_UTILS.log_message(1,'calendar_id '||l_temp_calendar_id);
				BEGIN
					 SELECT
						 calendar_name
							 INTO  x_calendar_name
							 FROM  jtf_calendars_vl
							 WHERE calendar_id = TO_NUMBER(l_temp_calendar_id);

						 x_calendar_id := TO_NUMBER(l_temp_calendar_id);
				EXCEPTION
					 WHEN NO_DATA_FOUND THEN
						 x_msg_data := 'Not a valid calendar assigned to profile option ';
						 PA_SCHEDULE_UTILS.log_message(1,'Not a valid calendar assigned to profile option ');
						 RAISE l_invalid_default_calendar;
					 WHEN OTHERS THEN
						 PA_SCHEDULE_UTILS.log_message(1,'ERROR while excuting select on jtf_calendars_vl.... '||sqlerrm);
						 RAISE;
				END;

			END  IF;
	 END IF;

	 PA_SCHEDULE_UTILS.log_message(1,'End   of the get_proj_calendar_default API ... ');
	 x_return_status := l_x_return_status;

EXCEPTION
	 WHEN l_invalid_default_calendar THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR: invalid calendar id at profile option ..');
		 PA_UTILS.add_message('PA','PA_INVALID_PROFILE_CALENDAR_ID');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_INVALID_PROFILE_CALENDAR_ID';
		 x_msg_count := FND_MSG_PUB.Count_Msg;

		 -- RESET other out params also : 4537865
		 x_calendar_id := NULL ;
		x_calendar_name := NULL;

		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865
					p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865
		 End If;
	 WHEN l_null_default_calendar THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR: Null calendar id at profile option ..');
		 PA_UTILS.add_message('PA','PA_INVALID_PROFILE_CALENDAR_ID');
		 x_return_status := FND_API.G_RET_STS_ERROR;
		 x_msg_data := 'PA_NULL_PROFILE_CALENDAR_ID';
		 x_msg_count := FND_MSG_PUB.Count_Msg;

		 -- RESET other out params also : 4537865
		 x_calendar_id := NULL ;
		 x_calendar_name := NULL;

		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data,  -- 4537865
					p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865
		 End If;
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in get_proj_calendar_default API ..'||sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- 4537865 : CHANGd substr to substrb

		-- RESET other out params also : 4537865
		x_calendar_id := NULL ;
		x_calendar_name := NULL;

		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'get_proj_calendar_default');
			 If x_msg_count = 1 THEN
					pa_interface_utils_pub.get_messages
						(p_encoded        => FND_API.G_TRUE,
						p_msg_index      => 1,
							p_msg_count      => x_msg_count,
							p_msg_data       => x_msg_data,
							p_data           => l_data, -- 4537865
							p_msg_index_out  => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865
			 End If;
                 RAISE;  -- This is optional depending on the needs
END get_proj_calendar_default;

-- Procedure            : create_new_cal_schedules
-- Purpose              : This procedure is called for creating the new schedule for the given calendars
--                         .
-- Input parameters
-- Parameters                   Type           Required  Description
-- P_Start_Calendar_Name        VARCHAR2       NO        Name of the starting calendar
-- P_End_Calendar_Name          VARCHAR2       NO        Name of the Ending calendar
--

PROCEDURE create_new_cal_schedules ( p_start_calendar_name            IN   VARCHAR2,
																		 p_end_calendar_name              IN   VARCHAR2,
																		 x_return_status                  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																		 x_msg_count                      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
																		 x_msg_data                       OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS
	 l_I                        NUMBER;
	 l_code                     VARCHAR2(50); -- temp variable
	 l_flag                     VARCHAR2(1);  -- temp variable
	 l_t_start_calendar_name    VARCHAR2(50); -- temp variable  to store the calendar start name for creating
	 -- the new schedule
	 l_t_end_calendar_name      VARCHAR2(50); -- temp variable  to store the calendar end name for creating
	 -- the new schedule

	 -- This cursor will select only those records which are matching in the start and end calendar name
	 -- or coming between them
	 CURSOR C1 IS SELECT calendar_id,calendar_name
		 FROM JTF_CALENDARS_VL
		 WHERE calendar_name BETWEEN l_t_start_calendar_name AND l_t_end_calendar_name;
	 l_msg_index_out		     NUMBER;
	 l_exception             EXCEPTION;
   l_debug_mode            VARCHAR2(20) := 'N';
   l_counter               NUMBER;

   l_data varchar2(2000) ; -- 4537865
BEGIN
	 -- Storing the status for error handling
	 l_x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- 2843435
   fnd_profile.get('PA_DEBUG_MODE',l_debug_mode);

   -- 4370082
   IF l_debug_mode = 'Y' THEN
     pa_debug.set_process('PLSQL','LOG',l_debug_mode);
   END IF;

   -- End of 2843435

	 -- The passing calendar start name is null then take the lowest one
	 IF (p_start_calendar_name IS NULL ) THEN

			SELECT MIN(calendar_name)
				INTO l_t_start_calendar_name
				FROM JTF_CALENDARS_VL;
	 ELSE
			l_t_start_calendar_name := p_start_calendar_name;
	 END IF;

	 -- The passing calendar start name is null then take the hightest one
	 IF (p_end_calendar_name IS NULL ) THEN

			SELECT MAX(calendar_name)
				INTO l_t_end_calendar_name
				FROM JTF_CALENDARS_VL;
	 ELSE
			l_t_end_calendar_name := p_end_calendar_name;
	 END IF;

	 FOR v_c1 IN C1 LOOP
			-- Defining save point
			SAVEPOINT bfr_strt_del;

			--Locking the JTF_CALENDAR_B table becouse of updation of its record
			SELECT 1
				INTO l_I
				FROM JTF_CALENDARS_B
				WHERE calendar_id=v_c1.calendar_id
				FOR UPDATE ;

			-- Deleting the existing schedule of the calendar and creating the new one
			DELETE FROM PA_SCHEDULES
				WHERE calendar_id = v_c1.calendar_id
				AND schedule_type_code = 'CALENDAR';

			-- Creating new schedule for the Calendar Id */
			PA_SCHEDULE_PUB.create_calendar_schedule(v_c1.calendar_id,l_x_return_status,x_msg_count,x_msg_data);

			PA_SCHEDULE_UTILS.log_message(1,'Calling Timeline  API ..... ');
			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 PA_TIMELINE_PVT.Create_Timeline (p_calendar_id     =>v_c1.calendar_id,
					 x_return_status   =>l_x_return_status,
					 x_msg_count       =>x_msg_count,
					 x_msg_data        =>x_msg_data);
			END IF;

			IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS ) THEN
				 l_flag  := 'S';
				 l_code  := 'PA_SCH_SUCC_CAL_GEN';
				 COMMIT;
			ELSE
				 l_flag  := 'E';
				 l_code  := 'PA_SCH_FAIL_CAL_GEN';
				 ROLLBACK TO SAVEPOINT bfr_strt_del;
			END IF;
			-- Inserting the calendars in session level temp table to pupulate the report
			INSERT INTO PA_CAL_GEN_STATUS_TEMP(calendar_id,calendar_name,generate_status_flag,message_code)
				VALUES(v_c1.calendar_id,v_c1.calendar_name,l_flag,l_code);
			COMMIT;

      -- 2843435: Need to raise expected error messages and print them to
      -- FND_FILE. Currently we don't have the logic to print error messages
      -- to the report file. Therefore, we have to raise expected errors.
      IF l_x_return_status <> FND_API.G_RET_STS_SUCCESS THEN

        IF l_debug_mode = 'Y' THEN
          pa_debug.write_file('CREATE_NEW_CAL_SCHEDULES: '||'LOG', 'msg_count = '||FND_MSG_PUB.Count_Msg);
        END IF;

        FOR l_counter IN 1..FND_MSG_PUB.Count_Msg LOOP
          pa_interface_utils_pub.get_messages ( p_encoded => FND_API.G_FALSE
                                         ,p_msg_index     => l_counter
                                         ,p_data          => x_msg_data
                                         ,p_msg_index_out => l_msg_index_out);
          IF l_debug_mode = 'Y' THEN
            pa_debug.write_file('CREATE_NEW_CAL_SCHEDULES: '||'LOG', x_msg_data);
          END IF;
        END LOOP;

        RAISE l_exception;

      END IF;
      -- End of 2843435

	 END LOOP;

	 x_return_status := FND_API.G_RET_STS_SUCCESS;
	 x_msg_count := FND_MSG_PUB.Count_Msg;
	 If x_msg_count = 1 THEN
			pa_interface_utils_pub.get_messages
				(p_encoded        => FND_API.G_TRUE ,
				p_msg_index      => 1,
				p_msg_count      => x_msg_count ,
				p_msg_data       => x_msg_data ,
				p_data           => l_data, -- 4537865
				p_msg_index_out  => l_msg_index_out );
			x_msg_data := l_data ; -- 4537865
	 End If;

EXCEPTION
   -- 2843435
   WHEN l_exception THEN
     RAISE;
   -- End of 2843435
	 WHEN NO_DATA_FOUND THEN
		 NULL;
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR in create_new_cal_schedules API ..'|| sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count := 1;
		 x_msg_data  := substrb(SQLERRM,1,240); -- 4537865 : Changed substrb to substr
		 FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'create_new_cal_schedules');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count,
					p_msg_data       => x_msg_data,
					p_data           => l_data, -- 4537865
					p_msg_index_out  => l_msg_index_out );
				x_msg_data := l_data ;  -- 4537865
		 End If;
                 RAISE;  -- This is optional depending on the needs
END create_new_cal_schedules;

-- Unilog Enhancement :	BEGIN

-- Procedure		: change_work_pattern_duration
-- Purpose		: This procedure is called from	self service for changing duration and work pattern.
--			: It uses existing change_work_pattern and change_duration procedures to do the	job.
--			: While	calling	change_duartion	and change_work_pattern, it passes newly introduced
--			: parameter p_generate_timeline_flag as	N, so that they	do not call timeline API.
--			: Typically this API will get called for a set of assignments of a resource
--			: (in a	loop or	from VORowImpl). So it takes two parameters p_prev_call_timeline_st_date
--			: and p_prev_call_timeline_end_date. For first assignment in the loop it will be null.
--			: So x_call_timeline_st_date and x_call_timeline_end_date will have the	required date ranges
--			: for which timeline has to be regenerated. For	the second assignment p_prev_call_timeline_st_date
--			: and p_prev_call_timeline_end_date will have  the first assighnmenmt's	x_call_timeline_st_date
--			: and x_call_timeline_end_date correspondingly.	Then it	will again calculate the timeline start	date
--			: and timeline end date	for the	second assignment. Then	it will	compare	it with
--			: p_prev_call_timeline_st_date and p_prev_call_timeline_end_date and will take
--			: min(new timeline start date, p_prev_call_timeline_st_date) and
--			: max(new timeline end date, p_prev_call_timeline_end_date). Similarly for other assignments....
--			: After	this API is called for a set of	assignments, you need to call PA_FORECASTITEM_PVT.Create_Forecast_Item
--			: with person_id as paremetrer and with	the returned dates x_call_timeline_st_date
--			: and x_call_timeline_end_date
-- Parameters		:
-- Note			: Note that the	p_hours_table should have hours	quantity starting at p_start_date and
--			: ending at p_end_date.


PROCEDURE change_work_pattern_duration(
	 p_record_version_number	 IN Number			,
	 p_project_id			 IN Number			,
	 p_calendar_id			 IN Number			,
	 p_assignment_id		 IN Number			,
	 p_resource_id			 IN Number			,
	 p_assignment_type		 IN Varchar2			,
	 p_asgn_start_date		 IN DATE	    := NULL	,
	 p_asgn_end_date		 IN DATE	    := NULL	,
	 p_start_date			 IN date	    := NULL	,
--	   p_end_date			   IN date	      := NULL	,
	 p_assignment_status_code	 IN varchar2	    := NULL	,
	 p_hours_table			 IN SYSTEM.PA_NUM_TBL_TYPE	,
	 p_prev_call_timeline_st_date	 IN DATE			,
	 p_prev_call_timeline_end_date	 IN DATE			,
	 x_call_timeline_st_date	 OUT NOCOPY Date			, --File.Sql.39 bug 4440895
	 x_call_timeline_end_date	 OUT NOCOPY Date			, --File.Sql.39 bug 4440895
	 x_return_status		 OUT  NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
	 x_msg_count			 OUT  NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	 x_msg_data			 OUT  NOCOPY VARCHAR2 ) --File.Sql.39 bug 4440895
IS

  l_hours_table				PA_PLSQL_DATATYPES.IdTabTyp;
  l_hours_db_table			PA_PLSQL_DATATYPES.IdTabTyp;
  l_monday_hours			PA_PLSQL_DATATYPES.IdTabTyp;
  l_tuesday_hours			PA_PLSQL_DATATYPES.IdTabTyp;
  l_wednesday_hours			PA_PLSQL_DATATYPES.IdTabTyp;
  l_thursday_hours			PA_PLSQL_DATATYPES.IdTabTyp;
  l_friday_hours			PA_PLSQL_DATATYPES.IdTabTyp;
  l_saturday_hours			PA_PLSQL_DATATYPES.IdTabTyp;
  l_sunday_hours			PA_PLSQL_DATATYPES.IdTabTyp;
  l_sch_record_tab			PA_SCHEDULE_GLOB.ScheduleTabTyp;
  l_date				DATE;
  l_counter				NUMBER := 1;
  l_changes_done			BOOLEAN	:= false;
  l_call_change_work_pattern		BOOLEAN	:= false;
  l_call_change_duration		BOOLEAN	:= false;
  l_call_cng_work_patt_out_range	BOOLEAN	:= false;
  l_call_second_time			BOOLEAN	:=false;
  l_call_first_time                     BOOLEAN	:=false; --Added for the bug 3421637
  l_new_assgn_start_date		DATE;
  l_new_assgn_end_date			DATE;
  l_update_work_zero_start_date		DATE;
  l_update_work_zero_end_date		DATE;
  l_count				NUMBER;
  l_global_week_start_day		NUMBER; --Added for bug 4068167
  l_days_to_inc				NUMBER; --Added for bug 4068167
  l_actual_days_to_inc			NUMBER; --Added for bug 4068167
  l_week_day				VARCHAR2(10);
  l_ch_work_pattern_st_date1		DATE;
  l_ch_work_pattern_end_date1		DATE;
  l_ch_work_pattern_st_date2		DATE;
  l_ch_work_pattern_end_date2		DATE;
  l_actual_start_date			DATE;
  l_actual_end_date		      DATE;
--  l_exception				EXCEPTION;
  API_ERROR				EXCEPTION;
  l_msg_index_out			NUMBER;
  p_end_date				DATE;
  l_last_row_flag			VARCHAR2(1);

  l_data varchar2(2000); -- 4537865
BEGIN

	FND_MSG_PUB.initialize;
	l_count	:= p_hours_table.COUNT;
	p_end_date := p_start_date+13;

	l_global_week_start_day	:= fnd_profile.value_specific('PA_GLOBAL_WEEK_START_DAY'); --Added for bug 4068167

	PA_SCHEDULE_UTILS.log_message(1,'Start of the change_work_pattern_duration API ... ');
	PA_SCHEDULE_UTILS.log_message(1,'Parameters ...	');
	PA_SCHEDULE_UTILS.log_message(1,'p_record_version_number='||p_record_version_number);
	PA_SCHEDULE_UTILS.log_message(1,'p_project_id='||p_project_id);
	PA_SCHEDULE_UTILS.log_message(1,'p_calendar_id='||p_calendar_id);
	PA_SCHEDULE_UTILS.log_message(1,'p_assignment_id='||p_assignment_id);
	PA_SCHEDULE_UTILS.log_message(1,'p_resource_id='||p_resource_id);
	PA_SCHEDULE_UTILS.log_message(1,'p_assignment_type='||p_assignment_type);
	PA_SCHEDULE_UTILS.log_message(1,'p_asgn_start_date='||p_asgn_start_date);
	PA_SCHEDULE_UTILS.log_message(1,'p_asgn_end_date='||p_asgn_end_date);
	PA_SCHEDULE_UTILS.log_message(1,'p_start_date='||p_start_date);
	PA_SCHEDULE_UTILS.log_message(1,'p_end_date='||p_end_date);
	PA_SCHEDULE_UTILS.log_message(1,'p_assignment_status_code='||p_assignment_status_code);
	PA_SCHEDULE_UTILS.log_message(1,'Number	of records in p_hours_table='||l_count);
	PA_SCHEDULE_UTILS.log_message(1,'Week start day l_global_week_start_day='||l_global_week_start_day); --Added for bug 4068167

	-- Initialize the out date variables, so that if changes are not required then no need to call
	-- create_forecast_items

	x_call_timeline_st_date	:= null;
	x_call_timeline_end_date := null;
	x_return_status	:= FND_API.G_RET_STS_SUCCESS;

	IF ((p_end_date	- p_start_date <> 13) OR (p_end_date < p_start_date)) THEN
		PA_SCHEDULE_UTILS.log_message(1,'p_start_date and p_end_date is	wrongly	passed');
		raise API_ERROR;
	END IF;

	IF l_count <>  14 THEN
		PA_SCHEDULE_UTILS.log_message(1,'Number	of records in p_hours_table is not 14');
		raise API_ERROR;
	END IF;
	-- Bug 3235656 : Added the below condition to show error
	FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
		IF (p_hours_table(i) < 0 OR p_hours_table(i) > 24) THEN
		    PA_UTILS.Add_Message ('PA',	'PA_SCH_HOURS_OUT_OF_RANGE');
		    RAISE FND_API.G_EXC_ERROR;
		END IF;
	END LOOP;

	-- We want to calculate	the actual start date and actual end date here instead of Java
	-- Because it is difficult and error prone to play with	Dates in java. Java will pass
	-- alwyas the first shown date in work pattern table and last date as p_start_date and
	-- p_end_date. And a table of hours p_hours_table with 14 values filled	in this. These
	-- values may be null, 0 or any	value

	PA_SCHEDULE_UTILS.log_message(1,'Parameters Detrmination Phase Begin');

-- Parameters Detrmination Phase Begin : In this it will determine the following parameters

	-- l_actual_start_date : From which date actually changes starts in work pattern table
	-- l_actual_end_date : From which date actually	changes	ends in	work pattern table
	-- l_new_assgn_start_date :  New extended assignment start date. It will be original assignment	start date if assignment is not	extended
	-- l_new_assgn_start_date :  New extended assignment end date. It will be original assignment end date if assignment is	not extended
	-- l_changes_done : Some changes are done, but not very	sure. So needs to determine further
	-- l_call_change_duration : Duration has been extended
	-- l_call_change_work_pattern :	Work pattern has been changed
	-- l_call_cng_work_patt_out_range : There is a gap between assignment, so needs	to fill	this with 0 hours
	-- l_update_work_zero_start_date : Start date for the Gap created in the assignment
	-- l_update_work_zero_end_date : End date for the Gap created in the assignment
	-- x_call_timeline_st_date : The start date from which timeline	should be regenerated.
	-- x_call_timeline_end_date : The end date till	which timeline should be regenerated.

	IF ((p_start_date BETWEEN p_asgn_start_date AND	p_asgn_end_date) AND (p_end_date BETWEEN p_asgn_start_date AND p_asgn_end_date)) THEN
		-- Changes are Within Assignment Date Range
		PA_SCHEDULE_UTILS.log_message(1,'Changes are Within Assignment Date Range');
		l_actual_start_date := p_start_date;
		l_actual_end_date := p_end_date;
		l_new_assgn_start_date := p_asgn_start_date;
		l_new_assgn_end_date :=	p_asgn_end_date;
		x_call_timeline_st_date	:= l_actual_start_date;
		x_call_timeline_end_date := l_actual_end_date;
		--Changes are done, now	further	it needs to be determined that whether work pattern has	changed	or not
		l_changes_done := true;
		FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NULL THEN
				l_hours_table(i) := 0;
			ELSE
				l_hours_table(i) := p_hours_table(i);
			END IF;
		END LOOP;
	ELSIF  p_end_date < p_asgn_start_date THEN
		-- Moving Backward Totally outside range

		PA_SCHEDULE_UTILS.log_message(1,'Moving	Backward Totally outside range');

		-- Example 1 : assgn start date	is 20-Oct-2003 and assgn end date is 10-Nov-2003
		-- p_start_date	is 01-Oct-2003 and p_end_date is 14-Oct-2003
		-- p_hours_table has 0,null,0,8,8,8,8,8,8,8,8,8,8,8

		-- Example 2 : assgn start date	is 15-Oct-2003 and assgn end date is 10-Nov-2003
		-- p_start_date	is 01-Oct-2003 and p_end_date is 14-Oct-2003
		-- p_hours_table has 0,null,0,8,8,8,8,8,8,8,8,8,8,8

		l_actual_end_date := p_end_date;
		FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NOT NULL	AND p_hours_table(i) <>	0 THEN
				l_actual_start_date := p_start_date + (i-1);
				exit; -- As soon as find non zero, non null; come out
			END IF;
		END LOOP;

		-- Example 1 Results :	l_actual_start_date is 04-Oct-2003, l_actual_end_date is 14-Oct-2003
		-- Example 2 Results :	l_actual_start_date is 04-Oct-2003, l_actual_end_date is 14-Oct-2003

		IF l_actual_start_date IS NULL THEN
			-- This	will happen when all 0 or null hours are passed
			l_changes_done := false;
		ELSE
			l_changes_done := true;
			l_call_change_duration := true;
			l_call_change_work_pattern := true;
			-- Start of addition for bug 4183479
			FOR i IN (l_actual_start_date-p_start_date+1) .. p_hours_table.LAST LOOP
				IF p_hours_table(i) IS NULL THEN
					l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := 0; -- Bug 3234786 : To make sure that it starts from 1
				ELSE
					l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := p_hours_table(i);-- Bug 3234786 : To make sure that it starts from 1
				END IF;
			END LOOP;
			-- End of addition for bug 4183479
		END IF;

		-- Example 1 Results :	l_changes_done,	l_call_change_duration,	l_call_change_work_pattern are true
		-- Example 2 Results :	l_changes_done,	l_call_change_duration,	l_call_change_work_pattern are true

		l_new_assgn_start_date := l_actual_start_date;
		l_new_assgn_end_date :=	p_asgn_end_date;
		l_update_work_zero_start_date := l_actual_end_date+1;
		l_update_work_zero_end_date := p_asgn_start_date-1;
		x_call_timeline_st_date	:= l_actual_start_date;
		x_call_timeline_end_date := l_actual_end_date;

		IF  l_update_work_zero_end_date	>= l_update_work_zero_start_date THEN
			l_call_cng_work_patt_out_range := true;
			x_call_timeline_st_date	:= l_actual_start_date;
			x_call_timeline_end_date := l_update_work_zero_end_date;
		END IF;

		-- Example 1 Results : l_new_assgn_start_date is 04-Oct-2003 and l_new_assgn_end_date is 10-Nov-2003
		-- So now new assignment date is 04-Oct-2003 to	10-Nov-2003 for	which change_duration should be	called.
		-- l_update_work_zero_start_date is 15-Oct-2003	and l_update_work_zero_end_date	is 19-Oct-2003
		-- for which change_work_pattern should	be called with all 0 hours in monday to	sunday
		-- x_call_timeline_st_date, and	x_call_timeline_end_date for which forecast should be regenerated

		-- Example 2 Results : l_new_assgn_start_date is 04-Oct-2003 and l_new_assgn_end_date is 10-Nov-2003
		-- So now new assignment date is 04-Oct-2003 to	10-Nov-2003 for	which change_duration should be	called.
		-- l_update_work_zero_start_date is 15-Oct-2003	and l_update_work_zero_end_date	is 14-Oct-2003
		-- so change_work_pattern should not be	called with all	0 hours	in monday to sunday. Hence
		-- l_call_cng_work_patt_out_range will remain false
		-- x_call_timeline_st_date, and	x_call_timeline_end_date for which forecast should be regenerated

		/*  Commented and moved above for Bug 4183479
		FOR i IN (l_actual_start_date-p_start_date+1) .. p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NULL THEN
				l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := 0; -- Bug 3234786 : To make sure that it starts from 1
			ELSE
				l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := p_hours_table(i);-- Bug 3234786 : To make sure that it starts from 1
			END IF;
		END LOOP;                      */

		-- Example 1 Results : l_hours_table has 8,8,8,8,8,8,8,8,8,8,8
		-- Example 2 Results : l_hours_table has 8,8,8,8,8,8,8,8,8,8,8

	ELSIF  p_start_date > p_asgn_end_date THEN
		-- Moving Forward Totally outside range

		PA_SCHEDULE_UTILS.log_message(1,'Moving	Forward	Totally	outside	range');

		-- Example 1 : assgn start date	is 20-Oct-2003 and assgn end date is 10-Nov-2003
		-- p_start_date	is 15-Nov-2003 and p_end_date is 28-Nov-2003
		-- p_hours_table has 8,null,0,8,8,8,8,8,8,8,8,null,null,null

		-- Example 2 : assgn start date	is 20-Oct-2003 and assgn end date is 14-Nov-2003
		-- p_start_date	is 15-Nov-2003 and p_end_date is 28-Nov-2003
		-- p_hours_table has 8,null,0,8,8,8,8,8,8,8,8,null,null,null

		l_actual_start_date := p_start_date;

		FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NOT NULL	AND p_hours_table(i) <>	0 THEN
				l_actual_end_date := p_start_date + (i-1);
			END IF;
		END LOOP;

		-- Example 1 Results : l_actual_start_date is 15-Nov-2003,  l_actual_end_date is 25-Nov-2003
		-- Example 2 Results : l_actual_start_date is 15-Nov-2003,  l_actual_end_date is 25-Nov-2003

		IF l_actual_end_date IS	NULL THEN
			-- This	will happen when all 0 or null hours are passed
			l_changes_done := false;
		ELSE
			l_changes_done := true;
			l_call_change_duration := true;
			l_call_change_work_pattern := true;
			-- Start of addition for bug 4183479
			FOR i IN p_hours_table.FIRST ..	(l_actual_end_date-p_start_date+1) LOOP
				IF p_hours_table(i) IS NULL THEN
					l_hours_table(i) := 0;
				ELSE
					l_hours_table(i) := p_hours_table(i);
				END IF;
			END LOOP;
			-- End of addition for bug 4183479
		END IF;

		-- Example 1 Results :	l_changes_done,	l_call_change_duration,	l_call_change_work_pattern are true
		-- Example 2 Results :	l_changes_done,	l_call_change_duration,	l_call_change_work_pattern are true

		l_new_assgn_start_date := p_asgn_start_date;
		l_new_assgn_end_date :=	l_actual_end_date;
		l_update_work_zero_start_date := p_asgn_end_date+1;
		l_update_work_zero_end_date := l_actual_start_date-1;
		x_call_timeline_st_date	:= l_actual_start_date;
		x_call_timeline_end_date := l_actual_end_date;

		IF  l_update_work_zero_end_date	>= l_update_work_zero_start_date THEN
			l_call_cng_work_patt_out_range := true;
			x_call_timeline_st_date	:= l_update_work_zero_start_date;
			x_call_timeline_end_date := l_actual_end_date;
		END IF;

		-- Example 1 Results : l_new_assgn_start_date is 20-Oct-2003 and l_new_assgn_end_date is 25-Nov-2003
		-- So now new assignment date is 20-Oct-2003 to	25-Nov-2003 for	which change_duration should be	called.
		-- l_update_work_zero_start_date is 11-Nov-2003	and l_update_work_zero_end_date	is 14-Nov-2003
		-- for which change_work_pattern should	be called with all 0 hours in monday to	sunday

		-- Example 2 Results : l_new_assgn_start_date is 20-Oct-2003 and l_new_assgn_end_date is 25-Nov-2003
		-- So now new assignment date is 04-Oct-2003 to	10-Nov-2003 for	which change_duration should be	called.
		-- l_update_work_zero_start_date is 15-Nov-2003	and l_update_work_zero_end_date	is 14-Nov-2003
		-- so change_work_pattern should not be	called with all	0 hours	in monday to sunday. Hence
		-- l_call_cng_work_patt_out_range will remain false

		/*  Commented and moved above for Bug 4183479
		FOR i IN p_hours_table.FIRST ..	(l_actual_end_date-p_start_date+1) LOOP
			IF p_hours_table(i) IS NULL THEN
				l_hours_table(i) := 0;
			ELSE
				l_hours_table(i) := p_hours_table(i);
			END IF;
		END LOOP;                 */

		-- Example 1 Results : l_hours_table has 8,0,0,8,8,8,8,8,8,8,8
		-- Example 2 Results : l_hours_table has 8,0,0,8,8,8,8,8,8,8,8

	ELSIF (p_start_date BETWEEN p_asgn_start_date AND p_asgn_end_date) AND p_end_date > p_asgn_end_date THEN
		-- Moving Forward Partially outside range

		PA_SCHEDULE_UTILS.log_message(1,'Moving	Forward	Partially outside range');

		--Changes are done, now	further	it needs to be determined that whether work pattern has	changed	or not
		l_changes_done := true;
		l_actual_start_date := p_start_date;
		FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NOT NULL	AND p_hours_table(i) <>	0 THEN
				l_actual_end_date := p_start_date + (i-1);
			END IF;
		END LOOP;

		IF l_actual_end_date IS	NULL THEN
			l_actual_end_date := p_asgn_end_date;
			-- call	change duration	will remain false in this case
			-- But we need to see further that work	pattern	changed	or not
		ELSE
			IF l_actual_end_date <=	p_asgn_end_date	THEN --	cut off	in assignment is not possible
				l_actual_end_date := p_asgn_end_date;
				-- call	change duration	will remain false in this case
				-- But we need to see further that work	pattern	changed	or not
			ELSE
				l_call_change_duration := true;
				l_call_change_work_pattern := true;
			END IF;
		END IF;

		-- x_call_timeline_st_date, and	x_call_timeline_end_date for which forecast should be regenerated
		x_call_timeline_st_date	:= l_actual_start_date;
		x_call_timeline_end_date := l_actual_end_date;
		l_new_assgn_start_date := p_asgn_start_date;
		l_new_assgn_end_date :=	l_actual_end_date;
		-- l_call_cng_work_patt_out_range will remain false

		FOR i IN p_hours_table.FIRST ..	(l_actual_end_date-p_start_date+1) LOOP
			IF p_hours_table(i) IS NULL THEN
				l_hours_table(i) := 0;
			ELSE
				l_hours_table(i) := p_hours_table(i);
			END IF;
		END LOOP;
	ELSIF (p_end_date BETWEEN p_asgn_start_date AND	p_asgn_end_date) AND p_start_date < p_asgn_start_date THEN
		-- Moving Backward Partially outside range

		PA_SCHEDULE_UTILS.log_message(1,'Moving	Backward Partially outside range');

		--Changes are done, now	further	it needs to be determined that whether work pattern has	changed	or not
		l_changes_done := true;
		l_actual_end_date := p_end_date;
		FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NOT NULL	AND p_hours_table(i) <>	0 THEN
				l_actual_start_date := p_start_date + (i-1);
				exit; -- As soon as find non zero come out
			END IF;
		END LOOP;

		IF l_actual_start_date IS NULL THEN
			-- This	will happen when all 0 or null hours are passed
			l_actual_start_date := p_asgn_start_date;
		ELSE
			IF l_actual_start_date >= p_asgn_start_date THEN -- cut	off in assignment is not possible
				l_actual_start_date := p_asgn_start_date;
				-- call	change duration	will remain false in this case
				-- But we need to see further that work	pattern	changed	or not
			ELSE
				l_call_change_duration := true;
				l_call_change_work_pattern := true;
			END IF;
		END IF;

		-- x_call_timeline_st_date, and	x_call_timeline_end_date for which forecast should be regenerated
		l_new_assgn_start_date := l_actual_start_date;
		l_new_assgn_end_date :=	p_asgn_end_date;
		x_call_timeline_st_date	:= l_actual_start_date;
		x_call_timeline_end_date := l_actual_end_date;
		-- l_call_cng_work_patt_out_range will remain false

		FOR i IN (l_actual_start_date-p_start_date+1) .. p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NULL THEN
				l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := 0;-- Bug 3234786 : To make sure that it starts from 1
			ELSE
				l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := p_hours_table(i);-- Bug 3234786 : To make sure that it starts from 1
			END IF;
		END LOOP;
	ELSIF ((p_asgn_start_date BETWEEN p_start_date AND p_end_date) AND (p_asgn_end_date BETWEEN p_start_date AND p_end_date)) THEN
		-- Moving Partially  Backward and Forward Both outside range

		PA_SCHEDULE_UTILS.log_message(1,'Moving	Partially  Backward and	Forward	Both outside range');

		--Changes are done, now	further	it needs to be determined that whether work pattern has	changed	or not
		l_changes_done := true;
		l_actual_end_date := p_end_date;
		FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NOT NULL	AND p_hours_table(i) <>	0 THEN
				l_actual_start_date := p_start_date + (i-1);
				exit; -- As soon as find non zero come out
			END IF;
		END LOOP;

		FOR i IN p_hours_table.FIRST ..	p_hours_table.LAST LOOP
			IF p_hours_table(i) IS NOT NULL	AND p_hours_table(i) <>	0 THEN
				l_actual_end_date := p_start_date + (i-1);
			END IF;
		END LOOP;

		IF l_actual_start_date IS NULL THEN
			-- This	will happen when all 0 or null hours are passed
			l_actual_start_date := p_asgn_start_date;
		ELSE
			IF l_actual_start_date >= p_asgn_start_date THEN -- cut	off in assignment is not possible
				l_actual_start_date := p_asgn_start_date;
				-- call	change duration	will remain false in this case
				-- But we need to see further that work	pattern	changed	or not
			ELSE
				l_call_change_duration := true;
				l_call_change_work_pattern := true;
			END IF;
		END IF;

		IF l_actual_end_date IS	NULL THEN
			-- This	will happen when all 0 or null hours are passed
			l_actual_end_date := p_asgn_end_date;
		ELSE
			IF l_actual_end_date <=	p_asgn_end_date	THEN --	cut off	in assignment is not possible
				l_actual_end_date := p_asgn_end_date;
				-- call	change duration	will remain false in this case
				-- But we need to see further that work	pattern	changed	or not
			ELSE
				l_call_change_duration := true;
				l_call_change_work_pattern := true;
			END IF;
		END IF;

		-- x_call_timeline_st_date, and	x_call_timeline_end_date for which forecast should be regenerated
		l_new_assgn_start_date := l_actual_start_date;
		l_new_assgn_end_date :=	l_actual_end_date;
		x_call_timeline_st_date	:= l_actual_start_date;
		x_call_timeline_end_date := l_actual_end_date;
		-- l_call_cng_work_patt_out_range will remain false

		FOR i IN (l_actual_start_date-p_start_date+1) .. (l_actual_end_date-p_start_date+1) LOOP
			IF p_hours_table(i) IS NULL THEN
				l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := 0;-- Bug 3234786 : To make sure that it starts from 1
			ELSE
				l_hours_table(i-(l_actual_start_date-p_start_date+1)+1) := p_hours_table(i);-- Bug 3234786 : To make sure that it starts from 1
			END IF;
		END LOOP;


	END IF;	--(p_start_date	BETWEEN	p_asgn_start_date AND p_asgn_end_date) AND (p_end_date BETWEEN p_asgn_start_date AND p_asgn_end_date)) THEN

-- Parameters Detrmination Phase Ends
	PA_SCHEDULE_UTILS.log_message(1,'Parameters Detrmination Phase Ends');
	PA_SCHEDULE_UTILS.log_message(1,'Parameters Are	...');
	PA_SCHEDULE_UTILS.log_message(1,'l_actual_start_date='||l_actual_start_date);
	PA_SCHEDULE_UTILS.log_message(1,'l_actual_end_date='||l_actual_end_date);
	PA_SCHEDULE_UTILS.log_message(1,'l_new_assgn_start_date='||l_new_assgn_start_date);
	PA_SCHEDULE_UTILS.log_message(1,'l_new_assgn_end_date='||l_new_assgn_end_date);
	PA_SCHEDULE_UTILS.log_message(1,'l_update_work_zero_start_date='||l_update_work_zero_start_date);
	PA_SCHEDULE_UTILS.log_message(1,'l_update_work_zero_end_date='||l_update_work_zero_end_date);


	IF l_changes_done THEN
		PA_SCHEDULE_UTILS.log_message(1,'l_changes_done	is true');

		--  Initialization of hours table
		--  These tables will be used while calling change_work_pattern

		FOR i in 1..2 LOOP
			l_monday_hours(i):=-99;
			l_tuesday_hours(i):=-99;
			l_wednesday_hours(i):=-99;
			l_thursday_hours(i):=-99;
			l_friday_hours(i):=-99;
			l_saturday_hours(i):=-99;
			l_sunday_hours(i):= -99;
		END LOOP;
/*Placed the call here for the bug 3421637*/
		IF l_call_change_duration THEN
			PA_SCHEDULE_UTILS.log_message(1,'l_call_change_duration	is true');

			PA_SCHEDULE_UTILS.log_message(1,'Calling change_duration');
			PA_SCHEDULE_UTILS.log_message(1,'l_new_assgn_start_date='||l_new_assgn_start_date);
			PA_SCHEDULE_UTILS.log_message(1,'l_new_assgn_end_date='||l_new_assgn_end_date);

			pa_schedule_pub.change_duration(
				 p_record_version_number	  => p_record_version_number,
				 p_exception_type_code		  => 'CHANGE_DURATION'		,
				 p_project_id			  => p_project_id		,
				 p_calendar_id			  => p_calendar_id		,
				 p_assignment_id		  => p_assignment_id		,
				 p_assignment_type		  => p_assignment_type		,
				 p_start_date			  => l_new_assgn_start_date	,
				 p_end_date			  => l_new_assgn_end_date	,
				 p_assignment_status_code	  => p_assignment_status_code	,
				 p_asgn_start_date		  => p_asgn_start_date		,
				 p_asgn_end_date		  => p_asgn_end_date		,
				 p_init_msg_list		  => FND_API.G_FALSE		,
				 p_generate_timeline_flag	  => 'N'			,
				 x_return_status		  => x_return_status		,
				 x_msg_count			  => x_msg_count		,
				 x_msg_data			  => x_msg_data)		;

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
				raise API_ERROR;
			END IF;

			-- There is a gap found, so need to fill this with 0 hours
			IF l_call_cng_work_patt_out_range THEN
				PA_SCHEDULE_UTILS.log_message(1,'l_call_cng_work_patt_out_range	is true');

				pa_schedule_pub.change_work_pattern(
					 p_record_version_number => p_record_version_number		,
					 p_project_id		 => p_project_id			,
					 p_calendar_id		 => p_calendar_id			,
					 p_assignment_id	 => p_assignment_id			,
					 p_assignment_type	 => p_assignment_type			,
					 p_start_date		 => l_update_work_zero_start_date	,
					 p_end_date		 => l_update_work_zero_end_date		,
					 p_monday_hours		 => 0					,
					 p_tuesday_hours	 => 0					,
					 p_wednesday_hours	 => 0					,
					 p_thursday_hours	 => 0					,
					 p_friday_hours		 => 0					,
					 p_saturday_hours	 => 0					,
					 p_sunday_hours		 => 0					,
					 p_asgn_start_date	 => l_new_assgn_start_date		,
					 p_asgn_end_date	 => l_new_assgn_end_date		,
					 p_init_msg_list	 => FND_API.G_FALSE			,
					 p_last_row_flag	 => 'Y'					, --Changed 'N' to 'Y' for Bug 4165970.
					 p_generate_timeline_flag => 'N'				,
					 x_return_status	 => x_return_status			,
					 x_msg_count		 => x_msg_count				,
					 x_msg_data		 => x_msg_data)				;

				IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
					raise API_ERROR;
				END IF;
			END IF;	-- l_call_cng_work_patt_out_range THEN

		END IF;	-- l_call_change_duration THEN*

		PA_SCHEDULE_UTILS.log_message(1,'Calling pa_schedule_pvt.get_assignment_schedule');

		pa_schedule_pvt.get_assignment_schedule	( p_assignment_id   => p_assignment_id		,
							  p_start_date	    => l_actual_start_date	,
							  p_end_date	    => l_actual_end_date	,
							  x_sch_record_tab  => l_sch_record_tab		,
							  x_return_status   => x_return_status		,
							  x_msg_count	    => x_msg_count		,
							  x_msg_data	    => x_msg_data)		;



		-- get_assignment_schedule will	return 0 records in l_sch_record_tab, if given dates are
		-- outside the assignment range. So we need to populate	the l_sch_record_tab with one row here

		IF l_sch_record_tab.COUNT = 0 THEN
			l_sch_record_tab(1).start_date := l_actual_start_date;
			l_sch_record_tab(1).end_date :=	l_actual_end_date;
			l_sch_record_tab(1).monday_hours := 0;
			l_sch_record_tab(1).tuesday_hours := 0;
			l_sch_record_tab(1).wednesday_hours := 0;
			l_sch_record_tab(1).thursday_hours := 0;
			l_sch_record_tab(1).friday_hours := 0;
			l_sch_record_tab(1).saturday_hours := 0;
			l_sch_record_tab(1).sunday_hours := 0;
		END IF;

		PA_SCHEDULE_UTILS.log_message(1,'After calling pa_schedule_pvt.get_assignment_schedule l_sch_record_tab.count='||l_sch_record_tab.count);

		IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
			raise API_ERROR;
		END IF;


		-- Put the monday..sunday hours	in the l_hours_db_table	table which stores the data base values	of the
		-- schedule records. Also find out the monday..sunday hours to be passed to change_work_pattern
		/* Start of Addition for bug 4068167 */
		Begin
		  select decode(l_global_week_start_day,1,1,2,0,3,6,4,5,5,4,6,3,7,2,0) into l_days_to_inc from dual;
		END;
		/* End of addition  for bug 4068167 */

		IF l_sch_record_tab.COUNT > 0 THEN
			l_counter := 1;
			FOR j IN l_sch_record_tab.FIRST..l_sch_record_tab.LAST LOOP
				l_date := l_sch_record_tab(j).start_date;

				IF l_sch_record_tab(j).start_date IS NOT NULL AND l_sch_record_tab(j).end_date IS NOT NULL THEN
				LOOP
					l_week_day := TO_CHAR(l_date, 'DY', 'NLS_DATE_LANGUAGE=AMERICAN');

					IF l_week_day =	'MON' THEN
						l_hours_db_table(l_counter) := l_sch_record_tab(j).monday_hours;
                                  /*Modified the if condition as below for the bug 3421637*/
						--IF l_monday_hours(1) = -99
						/* Commented for bug 4068167 IF l_monday_hours(1) = -99 and (l_date = p_start_Date
						OR (l_date = p_start_date + 7 and l_actual_start_date > p_start_date+6)) */
						-- Start of addition for bug 4068167
						l_actual_days_to_inc := l_days_to_inc;
						if (l_actual_days_to_inc>6) then
							l_actual_days_to_inc := l_actual_days_to_inc - 7 ;
						end if ;
						IF l_monday_hours(1) = -99 and (l_date = p_start_Date + l_actual_days_to_inc
						OR (l_date = p_start_date + l_actual_days_to_inc + 7 and l_actual_start_date > p_start_date+6)) -- End of addition for bug 4068167
						THEN
							l_monday_hours(1) := l_hours_table(l_counter);
						ELSE
							l_monday_hours(2) := l_hours_table(l_counter);
						END IF;
						l_counter := l_counter+1;
					ELSIF l_week_day = 'TUE' THEN
						l_hours_db_table(l_counter) := l_sch_record_tab(j).tuesday_hours;
                                          /*Modified the if condition as below for the bug 3421637*/
					  --IF l_tuesday_hours(1) =	-99
						/* Commented for bug 4068167 IF l_tuesday_hours(1) =	-99 AND (l_date = p_start_Date + 1
						OR (l_date = p_start_date + 8 and l_actual_start_date > p_start_date+6)) */
						-- Start of addition for bug 4068167
						l_actual_days_to_inc := l_days_to_inc + 1;
						if (l_actual_days_to_inc>6) then
							l_actual_days_to_inc := l_actual_days_to_inc - 7 ;
						end if ;
						IF l_tuesday_hours(1) =	-99 AND (l_date = p_start_Date + l_actual_days_to_inc
						OR (l_date = p_start_date + l_actual_days_to_inc + 7 and l_actual_start_date > p_start_date+6))  -- End of addition for bug 4068167
						THEN
							l_tuesday_hours(1) := l_hours_table(l_counter);
						ELSE
							l_tuesday_hours(2) := l_hours_table(l_counter);
						END IF;
						l_counter := l_counter+1;
					ELSIF l_week_day = 'WED' THEN
						l_hours_db_table(l_counter) := l_sch_record_tab(j).wednesday_hours;
					/*Modified the if condition as below for the bug 3421637*/
					 --IF l_wednesday_hours(1)	= -99
						/*Commented for bug 4068167 IF l_wednesday_hours(1)	= -99 AND (l_date = p_start_Date + 2
						OR (l_date = p_start_date + 9 and l_actual_start_date > p_start_date+6))*/
						-- Start of addition for bug 4068167
						l_actual_days_to_inc := l_days_to_inc + 2;
						if (l_actual_days_to_inc>6) then
							l_actual_days_to_inc := l_actual_days_to_inc - 7 ;
						end if ;
						IF l_wednesday_hours(1)	= -99 AND (l_date = p_start_Date + l_actual_days_to_inc
						OR (l_date = p_start_date + l_actual_days_to_inc + 7 and l_actual_start_date > p_start_date+6)) -- End of addition for bug 4068167
						THEN
							l_wednesday_hours(1) :=	l_hours_table(l_counter);
						ELSE
							l_wednesday_hours(2) :=	l_hours_table(l_counter);
						END IF;
						l_counter := l_counter+1;
					ELSIF l_week_day = 'THU' THEN
						l_hours_db_table(l_counter) := l_sch_record_tab(j).thursday_hours;
						/* Commented for bug 4068167 Modified the if condition as below for the bug 3421637*/
						--IF l_thursday_hours(1) = -99
						/*IF l_thursday_hours(1) = -99 AND (l_date = p_start_Date + 3
						OR (l_date = p_start_date + 10 and l_actual_start_date > p_start_date+6))*/
						-- Start of addition for bug 4068167
						l_actual_days_to_inc := l_days_to_inc + 3;
						if (l_actual_days_to_inc>6) then
							l_actual_days_to_inc := l_actual_days_to_inc - 7 ;
						end if ;
						IF l_thursday_hours(1) = -99 AND (l_date = p_start_Date + l_actual_days_to_inc
						OR (l_date = p_start_date + l_actual_days_to_inc + 7 and l_actual_start_date > p_start_date+6)) -- End of addition for bug 4068167
						THEN
							l_thursday_hours(1) := l_hours_table(l_counter);
						ELSE
							l_thursday_hours(2) := l_hours_table(l_counter);
						END IF;
						l_counter := l_counter+1;
					ELSIF l_week_day = 'FRI' THEN
						l_hours_db_table(l_counter) := l_sch_record_tab(j).friday_hours;
						/*Modified the if condition as below for the bug 3421637*/
						--IF l_friday_hours(1) = -99
						/* Commented for bug 4068167 IF l_friday_hours(1) = -99 AND (l_date = p_start_Date + 4
						OR (l_date = p_start_date + 11 and l_actual_start_date > p_start_date+6)) */
						-- Start of addition for bug 4068167
						l_actual_days_to_inc := l_days_to_inc + 4;
						if (l_actual_days_to_inc>6) then
							l_actual_days_to_inc := l_actual_days_to_inc - 7 ;
						end if ;
						IF l_friday_hours(1) = -99 AND (l_date = p_start_Date + l_actual_days_to_inc
						OR (l_date = p_start_date + l_actual_days_to_inc + 7 and l_actual_start_date > p_start_date+6)) -- End of addition for bug 4068167
						THEN
							l_friday_hours(1) := l_hours_table(l_counter);
						ELSE
							l_friday_hours(2) := l_hours_table(l_counter);
						END IF;
						l_counter := l_counter+1;
					ELSIF l_week_day = 'SAT' THEN
						l_hours_db_table(l_counter) := l_sch_record_tab(j).saturday_hours;
						/*Modified the if condition as below for the bug 3421637*/
						--IF l_saturday_hours(1) = -99
						/* Commented for bug 4068167 IF l_saturday_hours(1) = -99 AND (l_date = p_start_Date + 5
						OR (l_date = p_start_date + 12 and l_actual_start_date > p_start_date+6)) */
						-- Start of addition for bug 4068167
						l_actual_days_to_inc := l_days_to_inc + 5;
						if (l_actual_days_to_inc>6) then
							l_actual_days_to_inc := l_actual_days_to_inc - 7 ;
						end if ;
						IF l_saturday_hours(1) = -99 AND (l_date = p_start_Date + l_actual_days_to_inc
						OR (l_date = p_start_date + l_actual_days_to_inc + 7 and l_actual_start_date > p_start_date+6)) -- End of addition for bug 4068167
						THEN
							l_saturday_hours(1) := l_hours_table(l_counter);
						ELSE
							l_saturday_hours(2) := l_hours_table(l_counter);
						END IF;
						l_counter := l_counter+1;
					ELSIF l_week_day = 'SUN' THEN
						l_hours_db_table(l_counter) := l_sch_record_tab(j).sunday_hours;
						/*Modified the if condition as below for the bug 3421637*/
                                                --IF l_sunday_hours(1) = -99
						/* Commented for bug 4068167 IF l_sunday_hours(1) = -99 AND (l_date = p_start_Date + 6
						OR (l_date = p_start_date + 13 and l_actual_start_date > p_start_date+6)) */
						-- Start of addition for bug 4068167
						l_actual_days_to_inc := l_days_to_inc + 6;
						if (l_actual_days_to_inc>6) then
							l_actual_days_to_inc := l_actual_days_to_inc - 7 ;
						end if ;
						IF l_sunday_hours(1) = -99 AND (l_date = p_start_Date + l_actual_days_to_inc
						OR (l_date = p_start_date + l_actual_days_to_inc + 7 and l_actual_start_date > p_start_date+6))  -- End of addition for bug 4068167
						THEN
							l_sunday_hours(1) := l_hours_table(l_counter);
						ELSE
							l_sunday_hours(2) := l_hours_table(l_counter);
						END IF;
						l_counter := l_counter+1;
					END IF;

					l_date := l_date + 1;

					EXIT WHEN trunc(l_date)	> trunc(l_sch_record_tab(j).end_date);
				END LOOP;
				END IF;	-- l_sch_record_tab(j).start_date IS NOT NULL AND l_sch_record_tab(j).end_date IS NOT NULL THEN
			END LOOP; -- j IN l_sch_record_tab.FIRST..l_sch_record_tab.LAST	LOOP
		END IF;	-- l_sch_record_tab.COUNT > 0 THEN

		PA_SCHEDULE_UTILS.log_message(1,'After populating the monday..sunday hours tables and l_hours_db_table ');

		-- Compare the passed hours with the database values. If no changes then no need to call change_work_pattern
		-- if l_call_change_duration then it means work	pattern	changes	will be	alwyas there
		IF l_call_change_duration = false THEN
			FOR i IN l_hours_db_table.FIRST..l_hours_db_table.LAST LOOP
				IF l_hours_db_table(i) <> l_hours_table(i) THEN
					l_call_change_work_pattern := true;
				END IF;
			END LOOP;
		END IF;

		IF l_call_change_duration = false AND l_call_change_work_pattern = false THEN
			x_call_timeline_st_date	:= null;
			x_call_timeline_end_date := null;
			--x_person_id := null;
			--return;
		END IF;

		-- Now all parameters for calling API's	are determined.	Now start calling them

		-- Returning the person_id back	to the calling environment so that it does not have to fetch
		--x_person_id := PA_FORECAST_ITEMS_UTILS.get_person_id(p_resource_id);


		-- Initialize the monday..sinday hours table with 0 if data is not populated already
		-- Note	that in	First set of hours at least one	day will have at least one non -99 value

		IF l_monday_hours(1) = -99 THEN
			l_monday_hours(1) := 0;
		END IF;
		IF l_tuesday_hours(1) =	-99 THEN
			l_tuesday_hours(1) := 0;
		END IF;
		IF l_wednesday_hours(1)	= -99 THEN
			l_wednesday_hours(1) :=	0;
		END IF;
		IF l_thursday_hours(1) = -99 THEN
			l_thursday_hours(1) := 0;
		END IF;
		IF l_friday_hours(1) = -99 THEN
			l_friday_hours(1) := 0;
		END IF;
		IF l_saturday_hours(1) = -99 THEN
			l_saturday_hours(1) := 0;
		END IF;
		IF l_sunday_hours(1) = -99 THEN
			l_sunday_hours(1) := 0;
		END IF;

/*Added for the bug 3421637*/
			IF l_monday_hours(2) = -99 THEN
				l_monday_hours(2) := 0;
			END IF;
			IF l_tuesday_hours(2) =	-99 THEN
				l_tuesday_hours(2) := 0;
			END IF;
			IF l_wednesday_hours(2)	= -99 THEN
				l_wednesday_hours(2) :=	0;
			END IF;
			IF l_thursday_hours(2) = -99 THEN
				l_thursday_hours(2) := 0;
			END IF;
			IF l_friday_hours(2) = -99 THEN
				l_friday_hours(2) := 0;
			END IF;
			IF l_saturday_hours(2) = -99 THEN
				l_saturday_hours(2) := 0;
			END IF;
			IF l_sunday_hours(2) = -99 THEN
				l_sunday_hours(2) := 0;
			END IF;
/*Added till here for the bug 3421637*/
		-- If Only 7 days records are passed then no need to call change_work_pattern second time.
		-- Otherwise we	need to	call it	two times.

/*Addition for the bug 3421637 starts*/
        l_call_second_time := False;

	IF  (l_actual_start_date - p_start_date) <= 6
	    AND (l_actual_end_date - p_start_date ) >= 6
        THEN
	  l_call_second_time := True;
	END IF;

	If l_call_second_time THEN
			l_ch_work_pattern_st_date1 := l_actual_start_date;
			l_ch_work_pattern_end_date1 := p_start_date + 6; --l_actual_start_date+6;
			l_ch_work_pattern_st_date2 := p_start_date + 7; --l_actual_start_date+7;
			l_ch_work_pattern_end_date2 := l_actual_end_date;
			l_call_first_time  := false;
               		for i in 1 .. (l_ch_work_pattern_end_date1 - l_ch_work_pattern_st_date1) + 1 LOOP
				IF l_hours_db_table(i) <> l_hours_table(i) THEN
					l_call_first_time := true;
					exit;
				END IF;
                        END LOOP;
			l_call_second_time := false;
                        for i in (l_ch_work_pattern_st_date2 -  l_ch_work_pattern_st_date1) +1 ..
			   (l_ch_work_pattern_end_date2 - l_ch_work_pattern_st_date1) + 1 LOOP
				IF l_hours_db_table(i) <> l_hours_table(i) THEN
					l_call_second_time := true;
					exit;
				END IF;
                        END LOOP;

        ELSE
	                l_ch_work_pattern_st_date1 := l_actual_start_date;
			l_ch_work_pattern_end_date1 := l_actual_end_date;
			l_call_first_time := false;
               		for i in 1 .. (l_ch_work_pattern_end_date1 - l_ch_work_pattern_st_date1) + 1 LOOP
				IF l_hours_db_table(i) <> l_hours_table(i) THEN
					l_call_first_time := true;
					exit;
				END IF;
                        END LOOP;
        END IF;

/*Addition for the bug 3421637 ends*/

/*Commenting the below code for the bug 3421637*/

	/*	IF (l_actual_end_date -	l_actual_start_date) <=	6 THEN
			l_ch_work_pattern_st_date1 := l_actual_start_date;
			l_ch_work_pattern_end_date1 := l_actual_end_date;
			l_call_second_time := false;
		ELSE
			l_ch_work_pattern_st_date1 := l_actual_start_date;
			l_ch_work_pattern_end_date1 := l_actual_start_date+6;
			l_ch_work_pattern_st_date2 := l_actual_start_date+7;
			l_ch_work_pattern_end_date2 := l_actual_end_date;
			l_call_second_time := true;

			-- If need to call second time then Initialize the second set of monday..sunday	hours
			-- table with 0	if data	is not populated already
			IF l_monday_hours(2) = -99 THEN
				l_monday_hours(2) := 0;
			END IF;
			IF l_tuesday_hours(2) =	-99 THEN
				l_tuesday_hours(2) := 0;
			END IF;
			IF l_wednesday_hours(2)	= -99 THEN
				l_wednesday_hours(2) :=	0;
			END IF;
			IF l_thursday_hours(2) = -99 THEN
				l_thursday_hours(2) := 0;
			END IF;
			IF l_friday_hours(2) = -99 THEN
				l_friday_hours(2) := 0;
			END IF;
			IF l_saturday_hours(2) = -99 THEN
				l_saturday_hours(2) := 0;
			END IF;
			IF l_sunday_hours(2) = -99 THEN
				l_sunday_hours(2) := 0;
			END IF;
		END IF;	-- (l_actual_end_date -	l_actual_start_date) <=	6 THEN*/
/*Commenting till here for the bug 3421637*/


/*Moved the below call above */
/*		IF l_call_change_duration THEN
			PA_SCHEDULE_UTILS.log_message(1,'l_call_change_duration	is true');

			PA_SCHEDULE_UTILS.log_message(1,'Calling change_duration');
			PA_SCHEDULE_UTILS.log_message(1,'l_new_assgn_start_date='||l_new_assgn_start_date);
			PA_SCHEDULE_UTILS.log_message(1,'l_new_assgn_end_date='||l_new_assgn_end_date);

			pa_schedule_pub.change_duration(
				 p_record_version_number	  => p_record_version_number,
				 p_exception_type_code		  => 'CHANGE_DURATION'		,
				 p_project_id			  => p_project_id		,
				 p_calendar_id			  => p_calendar_id		,
				 p_assignment_id		  => p_assignment_id		,
				 p_assignment_type		  => p_assignment_type		,
				 p_start_date			  => l_new_assgn_start_date	,
				 p_end_date			  => l_new_assgn_end_date	,
				 p_assignment_status_code	  => p_assignment_status_code	,
				 p_asgn_start_date		  => p_asgn_start_date		,
				 p_asgn_end_date		  => p_asgn_end_date		,
				 p_init_msg_list		  => FND_API.G_FALSE		,
				 p_generate_timeline_flag	  => 'N'			,
				 x_return_status		  => x_return_status		,
				 x_msg_count			  => x_msg_count		,
				 x_msg_data			  => x_msg_data)		;

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
				raise API_ERROR;
			END IF;

			-- There is a gap found, so need to fill this with 0 hours
			IF l_call_cng_work_patt_out_range THEN
				PA_SCHEDULE_UTILS.log_message(1,'l_call_cng_work_patt_out_range	is true');

				pa_schedule_pub.change_work_pattern(
					 p_record_version_number => p_record_version_number		,
					 p_project_id		 => p_project_id			,
					 p_calendar_id		 => p_calendar_id			,
					 p_assignment_id	 => p_assignment_id			,
					 p_assignment_type	 => p_assignment_type			,
					 p_start_date		 => l_update_work_zero_start_date	,
					 p_end_date		 => l_update_work_zero_end_date		,
					 p_monday_hours		 => 0					,
					 p_tuesday_hours	 => 0					,
					 p_wednesday_hours	 => 0					,
					 p_thursday_hours	 => 0					,
					 p_friday_hours		 => 0					,
					 p_saturday_hours	 => 0					,
					 p_sunday_hours		 => 0					,
					 p_asgn_start_date	 => l_new_assgn_start_date		,
					 p_asgn_end_date	 => l_new_assgn_end_date		,
					 p_init_msg_list	 => FND_API.G_FALSE			,
					 p_last_row_flag	 => 'N'					,
					 p_generate_timeline_flag => 'N'				,
					 x_return_status	 => x_return_status			,
					 x_msg_count		 => x_msg_count				,
					 x_msg_data		 => x_msg_data)				;

				IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
					raise API_ERROR;
				END IF;
			END IF;	-- l_call_cng_work_patt_out_range THEN

		END IF;	-- l_call_change_duration THEN*/

		IF l_call_change_work_pattern THEN

			PA_SCHEDULE_UTILS.log_message(1,'l_call_change_work_pattern is true');
			PA_SCHEDULE_UTILS.log_message(1,'Calling change_work_pattern first time');
			PA_SCHEDULE_UTILS.log_message(1,'l_ch_work_pattern_st_date1='||l_ch_work_pattern_st_date1);
			PA_SCHEDULE_UTILS.log_message(1,'l_ch_work_pattern_end_date1='||l_ch_work_pattern_end_date1);

			-- Call	change_work_pattern for	the first 7 days
			IF l_call_second_time THEN
				l_last_row_flag := 'N';
			ELSE
				l_last_row_flag := 'Y';
			END IF;

                   If l_call_first_time THEN
			pa_schedule_pub.change_work_pattern(
				 p_record_version_number => p_record_version_number	,
				 p_project_id		 => p_project_id		,
				 p_calendar_id		 => p_calendar_id		,
				 p_assignment_id	 => p_assignment_id		,
				 p_assignment_type	 => p_assignment_type		,
				 p_start_date		 => l_ch_work_pattern_st_date1	,
				 p_end_date		 => l_ch_work_pattern_end_date1	,
				 p_monday_hours		 => l_monday_hours(1)		,
				 p_tuesday_hours	 => l_tuesday_hours(1)		,
				 p_wednesday_hours	 => l_wednesday_hours(1)	,
				 p_thursday_hours	 => l_thursday_hours(1)		,
				 p_friday_hours		 => l_friday_hours(1)		,
				 p_saturday_hours	 => l_saturday_hours(1)		,
				 p_sunday_hours		 => l_sunday_hours(1)		,
				 p_asgn_start_date	 => l_new_assgn_start_date	,
				 p_asgn_end_date	 => l_new_assgn_end_date	,
				 p_init_msg_list	 => FND_API.G_FALSE		,
				 p_last_row_flag	 => l_last_row_flag		,
				 p_generate_timeline_flag => 'N'			,
				 x_return_status	 => x_return_status		,
				 x_msg_count		 => x_msg_count			,
				 x_msg_data		 => x_msg_data)			;

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
				raise API_ERROR;
			END IF;
                   END IF;

			IF l_call_second_time THEN
				PA_SCHEDULE_UTILS.log_message(1,'Calling change_work_pattern second time');
				PA_SCHEDULE_UTILS.log_message(1,'l_ch_work_pattern_st_date2='||l_ch_work_pattern_st_date2);
				PA_SCHEDULE_UTILS.log_message(1,'l_ch_work_pattern_end_date2='||l_ch_work_pattern_end_date2);

				pa_schedule_pub.change_work_pattern(
					 p_record_version_number => p_record_version_number	,
					 p_project_id		 => p_project_id		,
					 p_calendar_id		 => p_calendar_id		,
					 p_assignment_id	 => p_assignment_id		,
					 p_assignment_type	 => p_assignment_type		,
					 p_start_date		 => l_ch_work_pattern_st_date2	,
					 p_end_date		 => l_ch_work_pattern_end_date2	,
					 p_monday_hours		 => l_monday_hours(2)		,
					 p_tuesday_hours	 => l_tuesday_hours(2)		,
					 p_wednesday_hours	 => l_wednesday_hours(2)	,
					 p_thursday_hours	 => l_thursday_hours(2)		,
					 p_friday_hours		 => l_friday_hours(2)		,
					 p_saturday_hours	 => l_saturday_hours(2)		,
					 p_sunday_hours		 => l_sunday_hours(2)		,
					 p_asgn_start_date	 => l_new_assgn_start_date	,
					 p_asgn_end_date	 => l_new_assgn_end_date	,
					 p_init_msg_list	 => FND_API.G_FALSE		,
					 p_last_row_flag	 => 'Y'				,
					 p_generate_timeline_flag => 'N'			,
					 x_return_status	 => x_return_status		,
					 x_msg_count		 => x_msg_count			,
					 x_msg_data		 => x_msg_data)			;

				IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
					raise API_ERROR;
				END IF;
			END IF;--l_call_second_time THEN
		END IF;	--l_call_change_work_pattern THEN

		-- Calling create_timeline is important	instead	of create_forecast_item	as
		-- assignment_effort also has to be updated.
		-- For performance we can call create_forecast_item, but we need to add/subtract
		-- the extra effort. This can be done later.

		IF ((l_call_change_work_pattern	= true)	OR(l_call_change_duration = true)) THEN
			PA_TIMELINE_PVT.Create_Timeline(
				p_assignment_id	=> p_assignment_id	,
				x_return_status	=> x_return_status	,
				x_msg_count	=> x_msg_count		,
				x_msg_data	=> x_msg_data)		;

			IF x_return_status <> FND_API.G_RET_STS_SUCCESS	THEN
				raise API_ERROR;
			END IF;
		END IF;

	END IF;	--l_changes_done THEN

	-- The following section should	be outside beacuse for the previous assignment
	-- there may be	changes	and some values	are there in prev variables.
	IF p_prev_call_timeline_st_date	IS NOT NULL AND	p_prev_call_timeline_st_date < NVL(x_call_timeline_st_date, p_prev_call_timeline_st_date+1) THEN
		x_call_timeline_st_date	:= p_prev_call_timeline_st_date;
	END IF;

	IF p_prev_call_timeline_end_date IS NOT	NULL AND p_prev_call_timeline_end_date > NVL(x_call_timeline_end_date, p_prev_call_timeline_end_date-1)	THEN
		x_call_timeline_end_date := p_prev_call_timeline_end_date;
	END IF;

	PA_SCHEDULE_UTILS.log_message(1,'End of	change_work_pattern_duration');

--	Note : The calling environment should call the following API if	x_call_timeline_st_date	and x_call_timeline_end_date is	not null
--	PA_FORECASTITEM_PVT.Create_Forecast_Item (
--		  p_resource_id	   => p_resource_id,
--		  p_start_date	   => x_call_timeline_st_date,
--		  p_end_date	   => x_call_timeline_end_date,
--		  p_process_mode   => 'GENERATE',
--		  x_return_status => x_return_status,
--		  x_msg_count => x_msg_count,
--		  x_msg_data =>	x_msg_data);



EXCEPTION
	 WHEN FND_API.G_EXC_ERROR THEN -- Added for Bug 3235656
	      x_return_status := FND_API.G_RET_STS_ERROR;
	      x_msg_count := FND_MSG_PUB.Count_Msg;

	      -- 4537865 : RESET other out params also.
	     x_call_timeline_st_date := NULL ;
             x_call_timeline_end_date := NULL ;

	      IF x_msg_count = 1 THEN
		   pa_interface_utils_pub.get_messages
			(p_encoded	 => FND_API.G_TRUE,
			 p_msg_index	  => 1,
			 p_data		  => x_msg_data,
			 p_msg_index_out  => l_msg_index_out );
	      END IF;
	 WHEN API_ERROR	THEN
		 PA_SCHEDULE_UTILS.log_message(1,'User Defined Exception in change_work_pattern_duration API ..');
		 x_return_status := 'E';
		 IF x_msg_count	= 0 THEN
			 x_msg_count :=	1;
			 x_msg_data  :=	'User Defined Exception	in change_work_pattern_duration	API ..';
		 END IF;

	     -- 4537865 : RESET other out params also.
		x_call_timeline_st_date := NULL ;
		x_call_timeline_end_date := NULL ;

		 FND_MSG_PUB.add_exc_msg( p_pkg_name	     =>	'PA_SCHEDULE_PUB',
					 p_procedure_name   => 'change_work_pattern_duration');
		 IF x_msg_count	= 1 THEN
				pa_interface_utils_pub.get_messages
				       (p_encoded	 => FND_API.G_TRUE,
					p_msg_index	 => 1,
					p_msg_count	 => x_msg_count,
					p_msg_data	 => x_msg_data,
					p_data		 => l_data, -- 4537865
					p_msg_index_out	 => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865
		 END IF;

	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR	in change_work_pattern_duration	API ..'|| sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count :=	1;
		 x_msg_data  :=	substrb(SQLERRM,1,240);  -- 4537865 : Chnaged substr to substrb
		 FND_MSG_PUB.add_exc_msg( p_pkg_name	     =>	'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'change_work_pattern_duration');

		-- 4537865 : RESET other out params also.
		x_call_timeline_st_date := NULL ;
		x_call_timeline_end_date := NULL ;

		 IF x_msg_count	= 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded	  => FND_API.G_TRUE,
					p_msg_index	 => 1,
					p_msg_count	 => x_msg_count,
					p_msg_data	 => x_msg_data,
					p_data		 => l_data,  -- 4537865
					p_msg_index_out	 => l_msg_index_out );
				x_msg_data := l_data ; -- 4537865
		 END IF;
		 RAISE;
END change_work_pattern_duration;

-- Procedure		: populate_work_pattern_table
-- Purpose		: This procedure is called from	self service for populating the	global temp table
--			: pa_work_pattern_temp_table for the given assignment start date and assignment
--			: end date. The	data will be populated for 14 days starting with Global	week start day
--			: <= p_display_start_date. p_status_code is optional, if it is not given then it will
--			: fetch	all the	assignments irrespective of the	assignment schedule status.
--			: Finally it returns the actual	start date depending on	the global week	start date
-- Parameters		:
--

PROCEDURE Populate_work_pattern_table (
	    p_resource_id_tbl	     IN	SYSTEM.PA_NUM_TBL_TYPE	,
	    p_assgn_range_start_date IN	DATE :=	NULL		,
	    p_assgn_range_end_date   IN	DATE :=	NULL		,
	    p_display_start_date     IN	DATE			,
	    p_status_code	     IN	VARCHAR2 := NULL	,
	    p_delete_flag	     IN	VARCHAR2 := 'Y'		,
	    x_show_start_date	     OUT NOCOPY DATE			, --File.Sql.39 bug 4440895
	    x_return_status	     OUT NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
	    x_msg_count		     OUT NOCOPY NUMBER			, --File.Sql.39 bug 4440895
	    x_msg_data		     OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
AS

l_work_pattern_table		WORK_PATTERN_TAB_TYPE;
l_resource_id_tbl		PA_PLSQL_DATATYPES.IdTabTyp;
l_actual_display_start_date	DATE;
l_count				NUMBER;
l_where_to_place_counter	NUMBER;
l_current_date			DATE;
l_qty				NUMBER;
l_global_week_start_day		NUMBER;
l_global_week_start_day_new	NUMBER; /* Added for Bug 5622389 */
l_msg_index_out			NUMBER;
l_capacity_label		VARCHAR2(80);
l_availability_label		VARCHAR2(80);
l_display_start_day             NUMBER; --Added for the bug 3648827

l_data  varchar2(2000) ; -- 4537865
l_counter_mod       NUMBER ;  /* Added for Bug 6176678 */
-- This	cursor fetches all the assignments for the given filer conditions

CURSOR C_ASSIGNMENTS(l_res_id number) IS
SELECT
	project_id,
	project_name,
	assignment_name,
	start_date,
	end_date,
	status_name,
	assignment_id,
	resource_id,
	status_code,
	record_version_number,
	assignment_type,
	calendar_id,
	calendar_type,
	project_role_name,
	apprvl_status_name,
	assignment_effort,
	assignment_duration,
	project_system_status_code,
	--decode(decode(assignment_type, 'STAFFED_ASSIGNMENT', pa_security_pvt.check_user_privilege
	--('PA_ASN_SCHEDULE_ED', 'PA_PROJECTS', project_id), 'STAFFED_ADMIN_ASSIGNMENT',
	-- pa_security_pvt.check_user_privilege('PA_ADM_ASN_SCHEDULE_ED', 'PA_PROJECTS',project_id)),'Y',1,0) read_only_flag
--	1 read_only_flag -- Here we are	selecting read_only_flag as 0, actual value will be poulated Java side bcoz it does caching
	DECODE(mass_wf_in_progress_flag, 'Y', 1,
	       DECODE(pending_approval_flag, 'Y', 1,
	               DECODE(apprvl_status_code, 'ASGMT_APPRVL_CANCELED', 1, -- Bug 3235731
		               DECODE(status_code, null, 0, -- 3235675 This is needed as  is_asgmt_allow_stus_ctl_check returns N if status_code is null
		                    DECODE(pa_assignment_utils.is_asgmt_allow_stus_ctl_check(status_code, project_id, 'N'), 'N', 1, 0))))) read_only_flag
FROM pa_project_assignments_v asgn
WHERE asgn.resource_id = l_res_id
AND (
	  ((p_assgn_range_start_date IS	NOT NULL AND p_assgn_range_end_date IS NOT NULL)
	     AND
	    (((asgn.start_date between p_assgn_range_start_date	AND p_assgn_range_end_date)OR(asgn.end_date between p_assgn_range_start_date AND p_assgn_range_end_date))
	      OR
	     ((p_assgn_range_start_date	between	asgn.start_date	AND asgn.end_date)OR(p_assgn_range_end_date between asgn.start_date AND	asgn.end_date))
	    )
	   )
	   OR -- Get all assignments excpet those who are end dated before p_assgn_range_start_date
	   ( p_assgn_range_start_date IS NOT NULL AND p_assgn_range_end_date IS	NULL AND asgn.end_date >= p_assgn_range_start_date
	   )
	   OR -- Get all assignments excpet those who are started after	p_assgn_range_end_date
	   ( p_assgn_range_start_date IS NULL AND p_assgn_range_end_date IS NOT	NULL AND asgn.start_date <= p_assgn_range_end_date
	   )
     )
--AND asgn.status_code=nvl(p_status_code, asgn.status_code) 3235675 This is not needed, Also this is incorrect if status_code is null
AND 'STAFFED_ASGMT_CANCEL' <> nvl(project_system_status_code, 'XYZ') -- Bug 3235731
ORDER BY resource_id, assignment_id; --	This is	very important.	Logic is woven depending on this order


-- This	cursor fetches all the forecast_items for the resource and assignments for the given filer conditions
-- First part before UNION is for resource capacity and	next part is for assignment's forecast items

CURSOR c_quantity_cursor(l_res_id number) IS
SELECT
	item_date,
	capacity_quantity quantity,
	--capacity_quantity-(decode(availability_flag,
	--  'Y', decode(sign(capacity_quantity-availability_quantity), 1, 0, availability_quantity),
	--  'N', decode(sign(capacity_quantity-overcommitment_quantity), 1, 0, overcommitment_quantity))) quantity,
	resource_id,
	forecast_item_type,
	-1 assignment_id
FROM pa_forecast_items
WHERE resource_id = l_res_id
AND forecast_item_type = 'U'
AND item_date between l_actual_display_start_date and l_actual_display_start_date+14
AND delete_flag	= 'N'
UNION ALL
SELECT
	fi.item_date,
	fi.item_quantity quantity,
	fi.resource_id,
	fi.forecast_item_type,
	asgn.assignment_id
FROM pa_project_assignments asgn,
     pa_forecast_items fi
WHERE asgn.resource_id = l_res_id
AND fi.resource_id = l_res_id
AND fi.delete_flag = 'N'
AND fi.item_date between l_actual_display_start_date and l_actual_display_start_date+13
AND fi.forecast_item_type = 'A'
AND fi.assignment_id  =	 asgn.assignment_id
AND (
	  ((p_assgn_range_start_date IS	NOT NULL AND p_assgn_range_end_date IS NOT NULL)
	     AND
	    (((asgn.start_date between p_assgn_range_start_date	AND p_assgn_range_end_date)OR(asgn.end_date between p_assgn_range_start_date AND p_assgn_range_end_date))
	      OR
	     ((p_assgn_range_start_date	between	asgn.start_date	AND asgn.end_date)OR(p_assgn_range_end_date between asgn.start_date AND	asgn.end_date))
	    )
	   )
	   OR -- Get all assignments excpet those who are end dated before p_assgn_range_start_date
	   ( p_assgn_range_start_date IS NOT NULL AND p_assgn_range_end_date IS	NULL AND asgn.end_date >= p_assgn_range_start_date
	   )
	   OR -- Get all assignments excpet those who are started after	p_assgn_range_end_date
	   ( p_assgn_range_start_date IS NULL AND p_assgn_range_end_date IS NOT	NULL AND asgn.start_date <= p_assgn_range_end_date
	   )
     )
--AND asgn.status_code=nvl(p_status_code, asgn.status_code) 3235675 This is not needed, Also this is incorrect if status_code is null
ORDER BY resource_id, assignment_id, item_date,	forecast_item_type desc;

BEGIN
	FND_MSG_PUB.initialize;
	PA_SCHEDULE_UTILS.log_message(1,'Start of the Populate_work_pattern_table API ... ');
	PA_SCHEDULE_UTILS.log_message(1,'Parameters ...	');
	PA_SCHEDULE_UTILS.log_message(1,'p_assgn_range_start_date='||p_assgn_range_start_date);
	PA_SCHEDULE_UTILS.log_message(1,'p_assgn_range_end_date='||p_assgn_range_end_date);
	PA_SCHEDULE_UTILS.log_message(1,'p_display_start_date='||p_display_start_date);
	PA_SCHEDULE_UTILS.log_message(1,'p_status_code='||p_status_code);
	PA_SCHEDULE_UTILS.log_message(1,'p_delete_flag='||p_delete_flag);
	PA_SCHEDULE_UTILS.log_message(1,'p_resource_id_tbl.count='||p_resource_id_tbl.count);


	x_return_status	:= FND_API.G_RET_STS_SUCCESS;
	l_global_week_start_day	:= fnd_profile.value_specific('PA_GLOBAL_WEEK_START_DAY');

	/* Code added for Bug 5622389 */
	/* To incorporate the difference between PA weekday numbers and  */
	/* session parameter dependent weekday numbers.*/
	Select (to_number(to_char((to_date('01-01-1950','dd-mm-yyyy')+(l_global_week_start_day - 1)),'D')))
        into l_global_week_start_day_new
        from dual;
	/* Code ends for Bug 5622389 */

	-- Get the next_day-7 for the given date

	BEGIN
	/*Commented for the bug 3648827
		SELECT next_day(p_display_start_date,decode(l_global_week_start_day,1,'SUNDAY',2,'MONDAY',3,'TUESDAY',4,'WEDNESDAY',5,'THURSDAY',6,'FRIDAY',7,'SATURDAY'))-7
			INTO l_actual_display_start_date
		FROM dual;*/
		/*Added the below code for bug 3648827*/
         SELECT to_char(p_display_start_date,'D') INTO l_display_start_day FROM dual;
	END;

/*Added the code for the bug 3648827*/
/* Changed l_global_week_start_day to l_global_week_start_day_new for Bug 5622389*/
IF l_global_week_start_day_new > l_display_start_day THEN
 l_actual_display_start_date := p_display_start_date - 7 + l_global_week_start_day_new - l_display_start_day;
ELSE
 l_actual_display_start_date := p_display_start_date + l_global_week_start_day_new - l_display_start_day ;
END IF;
--IF l_global_week_start_day > l_display_start_day THEN
-- l_actual_display_start_date := p_display_start_date - 7 + l_global_week_start_day - l_display_start_day;
--ELSE
-- l_actual_display_start_date := p_display_start_date + l_global_week_start_day - l_display_start_day ;
--END IF;
/*Commented for the bug 3648827
	IF ((p_display_start_date - l_actual_display_start_date)=7) THEN
		-- It means already the	given date is falling on right global start week day
		l_actual_display_start_date := p_display_start_date;
	END IF;
	*/

	x_show_start_date := l_actual_display_start_date;

	IF p_delete_flag = 'Y' then
		DELETE FROM pa_work_pattern_temp_table;
	END IF;

	--If more than 25 resources than raise error. In phase2	we plan	to have	this for multiple resources
	l_count	:= p_resource_id_tbl.COUNT;
	IF l_count > 25	THEN
		null;
	END IF;

	IF l_count > 0 THEN
		FOR i IN p_resource_id_tbl.FIRST .. p_resource_id_tbl.LAST LOOP	-- 25 is the limit, later for multiple resources we can	keep this in loop
			l_resource_id_tbl(i) :=	p_resource_id_tbl(i);
		END LOOP;
	END IF;

	-- First it makes the plsql table l_work_pattern_table with two	rows capacity and availbility/overcommitment
	-- These two row's qty fields are initialized with 0 initially in the Initialization part of the code.
	-- Then	it creates rows	for all	the assignments	for the	given filter conditions. It initializes	these
	-- assignment row's qty	fields with 0 or null depending	on whether corresponding date is falling in assignment
	-- date	range or not.
	-- After the initialization part, it fethes the	forecast items and then	loops thru this	plsql table
	-- and populate	the qty	fields with respective capacity_quantity(for Capacity row) or item_quantity(for	assignment rows).

	-- Initialization Part Begin
	PA_SCHEDULE_UTILS.log_message(1,'Initialization	Begin');

	BEGIN
		SELECT meaning into l_capacity_label from pa_lookups where lookup_type='PA_CAPC_AVL_LABELS' and	lookup_code ='CAPACITY';
		SELECT meaning into l_availability_label from pa_lookups where lookup_type='PA_CAPC_AVL_LABELS'	and lookup_code	='AVAILABILITY';
	END;

	l_where_to_place_counter := 0;
	l_current_date := l_actual_display_start_date;
	FOR i IN l_resource_id_tbl.FIRST .. l_resource_id_tbl.LAST LOOP
		-- Initialize the First	two rows with 0. These two rows	are for	Capacity and Availability/Overcommitment
		FOR j in 1 .. 2	LOOP
			l_current_date := l_actual_display_start_date;
			l_where_to_place_counter := l_where_to_place_counter+1;
			l_work_pattern_table(l_where_to_place_counter).l_resource_id :=	l_resource_id_tbl(i);
			IF j = 1 THEN
				l_work_pattern_table(l_where_to_place_counter).l_assignment_id := -98;
			ELSE
				l_work_pattern_table(l_where_to_place_counter).l_assignment_id := -99;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_project_role_name := null;
			l_work_pattern_table(l_where_to_place_counter).l_project_id := null;
			l_work_pattern_table(l_where_to_place_counter).l_status_name :=	null;
			l_work_pattern_table(l_where_to_place_counter).l_read_only_flag	:= 1;
			IF j = 1 THEN
				l_work_pattern_table(l_where_to_place_counter).l_assignment_name := l_capacity_label;
			ELSE
				l_work_pattern_table(l_where_to_place_counter).l_assignment_name := l_availability_label;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_day1 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty1 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day2 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty2 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day3 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty3 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day4 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty4 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day5 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty5 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day6 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty6 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day7 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty7 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day8 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty8 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day9 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty9 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day10 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty10 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day11 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty11 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day12 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty12 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day13 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty13 := 0;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day14 := l_current_date;
			l_work_pattern_table(l_where_to_place_counter).l_qty14 := 0;
			l_work_pattern_table(l_where_to_place_counter).l_row_type_code := j ; --1:Capacity, 2:Availability/Overcommitment
		END LOOP; -- j in 1..2

		-- Initialize the next rows with all the assignments with given	filter condition

		FOR l_asgn IN c_assignments(l_resource_id_tbl(i)) LOOP
        /* Added for Bug 6176678 */
        /* Now on, if there are any assignments to be displayed, then we will again set both
           the (10K+1)th and (10K+2)th rows for Capacity and Availability/Overcommitment
           This value 10 is the 'Records Displayed' property of WorkPatternTable item in
           WeeklyScheduleRN.xml that we are using to display the records
        */

        SELECT MOD(l_where_to_place_counter,10)
        INTO l_counter_mod
        FROM dual;

        IF (l_counter_mod = 0 ) THEN

        FOR j in 1 .. 2 LOOP
         l_current_date := l_actual_display_start_date;
         l_where_to_place_counter := l_where_to_place_counter+1;
         l_work_pattern_table(l_where_to_place_counter).l_resource_id :=l_resource_id_tbl(i);
         IF j = 1 THEN
                l_work_pattern_table(l_where_to_place_counter).l_assignment_id := -98;
         ELSE
                l_work_pattern_table(l_where_to_place_counter).l_assignment_id := -99;
         END IF;
         l_work_pattern_table(l_where_to_place_counter).l_project_role_name := null;
         l_work_pattern_table(l_where_to_place_counter).l_project_id := null;
         l_work_pattern_table(l_where_to_place_counter).l_status_name :=        null;
         l_work_pattern_table(l_where_to_place_counter).l_read_only_flag        := 1;
         IF j = 1 THEN
                l_work_pattern_table(l_where_to_place_counter).l_assignment_name := l_capacity_label;
         ELSE
                l_work_pattern_table(l_where_to_place_counter).l_assignment_name := l_availability_label;
         END IF;
         l_work_pattern_table(l_where_to_place_counter).l_day1 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty1 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day2 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty2 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day3 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty3 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day4 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty4 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day5 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty5 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day6 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty6 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day7 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty7 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day8 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty8 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day9 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty9 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day10 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty10 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day11 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty11 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day12 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty12 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day13 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty13 := 0;
         l_current_date := l_current_date+1;
         l_work_pattern_table(l_where_to_place_counter).l_day14 := l_current_date;
         l_work_pattern_table(l_where_to_place_counter).l_qty14 := 0;
         l_work_pattern_table(l_where_to_place_counter).l_row_type_code := j ; --1:Capacity, 2:Availability/Overcommitment
        END LOOP; -- j in 1..2

        END IF ;   --IF (l_counter_mod = 0 ) THEN
        /* Changes end for Bug 6176678 */

			l_current_date := l_actual_display_start_date;
			l_where_to_place_counter := l_where_to_place_counter+1;
			l_work_pattern_table(l_where_to_place_counter).l_resource_id :=	l_asgn.resource_id;
			l_work_pattern_table(l_where_to_place_counter).l_assignment_id := l_asgn.assignment_id;
			l_work_pattern_table(l_where_to_place_counter).l_project_id := l_asgn.project_id;
			l_work_pattern_table(l_where_to_place_counter).l_project_name := l_asgn.project_name;
			l_work_pattern_table(l_where_to_place_counter).l_assignment_name := l_asgn.assignment_name;
			l_work_pattern_table(l_where_to_place_counter).l_start_date := l_asgn.start_date;
			l_work_pattern_table(l_where_to_place_counter).l_end_date := l_asgn.end_date;
			l_work_pattern_table(l_where_to_place_counter).l_status_name :=	l_asgn.status_name;
			l_work_pattern_table(l_where_to_place_counter).l_status_code :=	l_asgn.status_code;
			l_work_pattern_table(l_where_to_place_counter).l_record_version_number := l_asgn.record_version_number;
			l_work_pattern_table(l_where_to_place_counter).l_assignment_type := l_asgn.assignment_type;
			l_work_pattern_table(l_where_to_place_counter).l_calendar_id :=	l_asgn.calendar_id;
			l_work_pattern_table(l_where_to_place_counter).l_calendar_type := l_asgn.calendar_type;
			l_work_pattern_table(l_where_to_place_counter).l_project_role_name := l_asgn.project_role_name;
			l_work_pattern_table(l_where_to_place_counter).l_apprvl_status_name := l_asgn.apprvl_status_name;
			l_work_pattern_table(l_where_to_place_counter).l_assignment_effort := l_asgn.assignment_effort;
			l_work_pattern_table(l_where_to_place_counter).l_assignment_duration :=	l_asgn.assignment_duration;
			l_work_pattern_table(l_where_to_place_counter).l_project_system_status_code := l_asgn.project_system_status_code;
			l_work_pattern_table(l_where_to_place_counter).l_read_only_flag	:= l_asgn.read_only_flag;
			l_work_pattern_table(l_where_to_place_counter).l_day1 := l_current_date;

			-- If l_current_date goes outside the assignment date ranges then the qty field	should be bull

			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty1 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day2 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty2 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day3 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty3 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day4 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty4 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day5 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty5 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day6 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty6 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day7 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty7 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day8 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty8 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day9 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty9 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day10 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty10 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day11 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty11 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day12 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty12 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day13 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty13 := l_qty;
			l_current_date := l_current_date+1;
			l_work_pattern_table(l_where_to_place_counter).l_day14 := l_current_date;
			IF l_current_date > l_asgn.END_DATE OR	l_current_date < l_asgn.START_DATE THEN
				l_qty:=null;
			ELSE
				l_qty:=0;
			END IF;
			l_work_pattern_table(l_where_to_place_counter).l_qty14 := l_qty;
			l_work_pattern_table(l_where_to_place_counter).l_row_type_code := 3 ; --Assignments
		END LOOP; -- l_asgn IN c_assignments
	  END LOOP; -- l_resource_id_tbl.FIRST .. l_resource_id_tbl.LAST

	  -- Initialization Part End
	  PA_SCHEDULE_UTILS.log_message(1,'Initialization End');

	  -- Now loop thru the forecast	items and populate the corresponding qty fields	in
	  -- l_work_pattern_table

	  /* Changes for Bug 6176678
	     Now, for populating the Capacity rows (that is , l_row_type_code = 1),
	     we will NOT exit after each IF check.
	  */

	  FOR i	IN l_resource_id_tbl.FIRST .. l_resource_id_tbl.LAST LOOP
		FOR l_temp IN c_quantity_cursor(l_resource_id_tbl(i)) LOOP
			FOR j IN l_work_pattern_table.FIRST .. l_work_pattern_table.LAST LOOP
				IF l_work_pattern_table(j).l_row_type_code = 1 AND  l_temp.resource_id = l_work_pattern_table(j).l_resource_id AND l_temp.forecast_item_type='U' THEN
					IF l_temp.item_date = l_work_pattern_table(j).l_day1 THEN
						l_work_pattern_table(j).l_qty1 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day2	THEN
						l_work_pattern_table(j).l_qty2 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day3	THEN
						l_work_pattern_table(j).l_qty3 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day4	THEN
						l_work_pattern_table(j).l_qty4 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day5	THEN
						l_work_pattern_table(j).l_qty5 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day6	THEN
						l_work_pattern_table(j).l_qty6 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day7	THEN
						l_work_pattern_table(j).l_qty7 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day8	THEN
						l_work_pattern_table(j).l_qty8 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day9	THEN
						l_work_pattern_table(j).l_qty9 := l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day10 THEN
						l_work_pattern_table(j).l_qty10	:= l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day11 THEN
						l_work_pattern_table(j).l_qty11	:= l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day12 THEN
						l_work_pattern_table(j).l_qty12	:= l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day13 THEN
						l_work_pattern_table(j).l_qty13	:= l_temp.quantity;
						--exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day14 THEN
						l_work_pattern_table(j).l_qty14	:= l_temp.quantity;
						--exit;
					END IF;	-- l_temp.item_date = l_work_pattern_table(j).l_day1 THEN
				ELSIF l_work_pattern_table(j).l_row_type_code =	3  AND l_temp.resource_id = l_work_pattern_table(j).l_resource_id AND l_temp.assignment_id=l_work_pattern_table(j).l_assignment_id AND l_temp.forecast_item_type='A' THEN
					IF l_temp.item_date = l_work_pattern_table(j).l_day1 THEN
						l_work_pattern_table(j).l_qty1 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day2	THEN
						l_work_pattern_table(j).l_qty2 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day3	THEN
						l_work_pattern_table(j).l_qty3 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day4	THEN
						l_work_pattern_table(j).l_qty4 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day5	THEN
						l_work_pattern_table(j).l_qty5 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day6	THEN
						l_work_pattern_table(j).l_qty6 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day7	THEN
						l_work_pattern_table(j).l_qty7 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day8	THEN
						l_work_pattern_table(j).l_qty8 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day9	THEN
						l_work_pattern_table(j).l_qty9 := l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day10 THEN
						l_work_pattern_table(j).l_qty10	:= l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day11 THEN
						l_work_pattern_table(j).l_qty11	:= l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day12 THEN
						l_work_pattern_table(j).l_qty12	:= l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day13 THEN
						l_work_pattern_table(j).l_qty13	:= l_temp.quantity;
						exit;
					ELSIF l_temp.item_date = l_work_pattern_table(j).l_day14 THEN
						l_work_pattern_table(j).l_qty14	:= l_temp.quantity;
						exit;
					END IF;	-- l_temp.item_date = l_work_pattern_table(j).l_day1 THEN
				END IF;--l_work_pattern_table(j).l_row_type_code = 1 AND  l_temp.resource_id = l_work_pattern_table(j).l_resource_id AND l_temp.forecast_item_type='U' THEN
			END LOOP; -- j IN l_work_pattern_table.FIRST ..	l_work_pattern_table.LAST LOOP
		END LOOP;-- l_temp IN c_quantity_cursor(l_resource_id_tbl(i)) LOOP
	END LOOP;--i IN	l_resource_id_tbl.FIRST	.. l_resource_id_tbl.LAST LOOP

	PA_SCHEDULE_UTILS.log_message(1,'Inserting data	in pa_work_pattern_temp_table');

	FOR j IN l_work_pattern_table.FIRST .. l_work_pattern_table.LAST LOOP
	  INSERT INTO pa_work_pattern_temp_table
	  (
		  PROJECT_ID ,
		  PROJECT_NAME,
		  ASSIGNMENT_NAME,
		  START_DATE,
		  END_DATE,
		  STATUS_NAME,
		  ASSIGNMENT_ID,
		  RESOURCE_ID,
		  STATUS_CODE,
		  RECORD_VERSION_NUMBER,
		  ASSIGNMENT_TYPE,
		  CALENDAR_ID,
		  CALENDAR_TYPE,
		  PROJECT_ROLE_NAME,
		  APPRVL_STATUS_NAME,
		  ASSIGNMENT_EFFORT,
		  ASSIGNMENT_DURATION,
		  PROJECT_SYSTEM_STATUS_CODE,
		  DAY1,
		  DAY2,
		  DAY3,
		  DAY4,
		  DAY5,
		  DAY6,
		  DAY7,
		  DAY8,
		  DAY9,
		  DAY10,
		  DAY11,
		  DAY12,
		  DAY13,
		  DAY14,
		  QTY1,
		  QTY2,
		  QTY3,
		  QTY4,
		  QTY5,
		  QTY6,
		  QTY7,
		  QTY8,
		  QTY9,
		  QTY10,
		  QTY11,
		  QTY12,
		  QTY13,
		  QTY14,
		  row_type_code,
		  read_only_flag)
		values
		(
		  l_work_pattern_table(j).l_PROJECT_ID ,
		  l_work_pattern_table(j).l_PROJECT_NAME,
		  l_work_pattern_table(j).l_ASSIGNMENT_NAME,
		  l_work_pattern_table(j).l_START_DATE,
		  l_work_pattern_table(j).l_END_DATE,
		  l_work_pattern_table(j).l_STATUS_NAME,
		  l_work_pattern_table(j).l_ASSIGNMENT_ID,
		  l_work_pattern_table(j).l_RESOURCE_ID,
		  l_work_pattern_table(j).l_STATUS_CODE,
		  l_work_pattern_table(j).l_RECORD_VERSION_NUMBER,
		  l_work_pattern_table(j).l_ASSIGNMENT_TYPE,
		  l_work_pattern_table(j).l_CALENDAR_ID,
		  l_work_pattern_table(j).l_CALENDAR_TYPE,
		  l_work_pattern_table(j).l_PROJECT_ROLE_NAME,
		  l_work_pattern_table(j).l_APPRVL_STATUS_NAME,
		  l_work_pattern_table(j).l_ASSIGNMENT_EFFORT,
		  l_work_pattern_table(j).l_ASSIGNMENT_DURATION,
		  l_work_pattern_table(j).l_PROJECT_SYSTEM_STATUS_CODE,
		  l_work_pattern_table(j).l_DAY1,
		  l_work_pattern_table(j).l_DAY2,
		  l_work_pattern_table(j).l_DAY3,
		  l_work_pattern_table(j).l_DAY4,
		  l_work_pattern_table(j).l_DAY5,
		  l_work_pattern_table(j).l_DAY6,
		  l_work_pattern_table(j).l_DAY7,
		  l_work_pattern_table(j).l_DAY8,
		  l_work_pattern_table(j).l_DAY9,
		  l_work_pattern_table(j).l_DAY10,
		  l_work_pattern_table(j).l_DAY11,
		  l_work_pattern_table(j).l_DAY12,
		  l_work_pattern_table(j).l_DAY13,
		  l_work_pattern_table(j).l_DAY14,
		  l_work_pattern_table(j).l_QTY1,
		  l_work_pattern_table(j).l_QTY2,
		  l_work_pattern_table(j).l_QTY3,
		  l_work_pattern_table(j).l_QTY4,
		  l_work_pattern_table(j).l_QTY5,
		  l_work_pattern_table(j).l_QTY6,
		  l_work_pattern_table(j).l_QTY7,
		  l_work_pattern_table(j).l_QTY8,
		  l_work_pattern_table(j).l_QTY9,
		  l_work_pattern_table(j).l_QTY10,
		  l_work_pattern_table(j).l_QTY11,
		  l_work_pattern_table(j).l_QTY12,
		  l_work_pattern_table(j).l_QTY13,
		  l_work_pattern_table(j).l_QTY14,
		  l_work_pattern_table(j).l_row_type_code,
		  l_work_pattern_table(j).l_read_only_flag)   ;
	END LOOP;

	PA_SCHEDULE_UTILS.log_message(1,'End of	Populate_work_pattern_table');
EXCEPTION
	 WHEN OTHERS THEN
		 PA_SCHEDULE_UTILS.log_message(1,'ERROR	in Populate_work_pattern_table API ..'|| sqlerrm);
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 x_msg_count :=	1;
		 x_msg_data  :=	substrb(SQLERRM,1,240);  -- 4537865
		 -- RESET x_show_start_date also
		 x_show_start_date := NULL ;

		 FND_MSG_PUB.add_exc_msg( p_pkg_name	     =>	'PA_SCHEDULE_PUB',
			 p_procedure_name   => 'Populate_work_pattern_table');
		 IF x_msg_count	= 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded	  => FND_API.G_TRUE,
					p_msg_index	 => 1,
					p_msg_count	 => x_msg_count,
					p_msg_data	 => x_msg_data,
					p_data		 => l_data, -- 4537865
					p_msg_index_out	 => l_msg_index_out );
					x_msg_data := l_data ; -- 4537865
		 END IF;
		 RAISE;

END Populate_work_pattern_table;

-- Unilog Enhancement END

END PA_SCHEDULE_PUB;

/
