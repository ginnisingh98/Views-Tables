--------------------------------------------------------
--  DDL for Package PA_SCHEDULE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_SCHEDULE_PUB" AUTHID CURRENT_USER as
/* $Header: PARGPUBS.pls 120.3.12010000.8 2010/05/02 22:16:21 nisinha ship $ */

--EmptyNumTbl  PA_SCHEDULE_GLOB.NumTblType;
--EmptyNumTbl(1) : = NULL;

-- Unilog Enhancement BEGIN

 TYPE WORK_PATTERN_REC_TYPE
  IS RECORD (
	  l_PROJECT_ID			PA_WORK_PATTERN_TEMP_TABLE.project_id%TYPE			,
	  l_PROJECT_NAME		PA_WORK_PATTERN_TEMP_TABLE.project_name%TYPE			,
	  l_ASSIGNMENT_NAME		PA_WORK_PATTERN_TEMP_TABLE.assignment_name%TYPE			,
	  l_START_DATE			PA_WORK_PATTERN_TEMP_TABLE.start_date%TYPE			,
	  l_END_DATE			PA_WORK_PATTERN_TEMP_TABLE.end_date%TYPE			,
	  l_STATUS_NAME			PA_WORK_PATTERN_TEMP_TABLE.status_name%TYPE			,
	  l_ASSIGNMENT_ID		PA_WORK_PATTERN_TEMP_TABLE.assignment_id%TYPE			,
	  l_RESOURCE_ID			PA_WORK_PATTERN_TEMP_TABLE.resource_id%TYPE			,
	  l_STATUS_CODE			PA_WORK_PATTERN_TEMP_TABLE.status_code%TYPE			,
	  l_RECORD_VERSION_NUMBER	PA_WORK_PATTERN_TEMP_TABLE.record_version_number%TYPE		,
	  l_ASSIGNMENT_TYPE		PA_WORK_PATTERN_TEMP_TABLE.assignment_type%TYPE			,
	  l_CALENDAR_ID			PA_WORK_PATTERN_TEMP_TABLE.calendar_id%TYPE			,
	  l_CALENDAR_TYPE		PA_WORK_PATTERN_TEMP_TABLE.calendar_type%TYPE			,
	  l_PROJECT_ROLE_NAME		PA_WORK_PATTERN_TEMP_TABLE.project_role_name%TYPE		,
	  l_APPRVL_STATUS_NAME		PA_WORK_PATTERN_TEMP_TABLE.apprvl_status_name%TYPE		,
	  l_ASSIGNMENT_EFFORT		PA_WORK_PATTERN_TEMP_TABLE.assignment_effort%TYPE		,
	  l_ASSIGNMENT_DURATION		PA_WORK_PATTERN_TEMP_TABLE.assignment_duration%TYPE		,
	  l_PROJECT_SYSTEM_STATUS_CODE	PA_WORK_PATTERN_TEMP_TABLE.PROJECT_SYSTEM_STATUS_CODE%TYPE	,
	  l_QTY1			PA_WORK_PATTERN_TEMP_TABLE.QTY1%TYPE				,
	  l_QTY2			PA_WORK_PATTERN_TEMP_TABLE.QTY2%TYPE				,
	  l_QTY3			PA_WORK_PATTERN_TEMP_TABLE.QTY3%TYPE				,
	  l_QTY4			PA_WORK_PATTERN_TEMP_TABLE.QTY4%TYPE				,
	  l_QTY5			PA_WORK_PATTERN_TEMP_TABLE.QTY5%TYPE				,
	  l_QTY6			PA_WORK_PATTERN_TEMP_TABLE.QTY6%TYPE				,
	  l_QTY7			PA_WORK_PATTERN_TEMP_TABLE.QTY7%TYPE				,
	  l_QTY8			PA_WORK_PATTERN_TEMP_TABLE.QTY8%TYPE				,
	  l_QTY9			PA_WORK_PATTERN_TEMP_TABLE.QTY9%TYPE				,
	  l_QTY10			PA_WORK_PATTERN_TEMP_TABLE.QTY10%TYPE				,
	  l_QTY11			PA_WORK_PATTERN_TEMP_TABLE.QTY11%TYPE				,
	  l_QTY12			PA_WORK_PATTERN_TEMP_TABLE.QTY12%TYPE				,
	  l_QTY13			PA_WORK_PATTERN_TEMP_TABLE.QTY13%TYPE				,
	  l_QTY14			PA_WORK_PATTERN_TEMP_TABLE.QTY14%TYPE				,
	  l_DAY1			PA_WORK_PATTERN_TEMP_TABLE.day1%TYPE				,
	  l_DAY2			PA_WORK_PATTERN_TEMP_TABLE.day2%TYPE				,
	  l_DAY3			PA_WORK_PATTERN_TEMP_TABLE.day3%TYPE				,
	  l_DAY4			PA_WORK_PATTERN_TEMP_TABLE.day4%TYPE				,
	  l_DAY5			PA_WORK_PATTERN_TEMP_TABLE.day5%TYPE				,
	  l_DAY6			PA_WORK_PATTERN_TEMP_TABLE.day6%TYPE				,
	  l_DAY7			PA_WORK_PATTERN_TEMP_TABLE.day7%TYPE				,
	  l_DAY8			PA_WORK_PATTERN_TEMP_TABLE.day8%TYPE				,
	  l_DAY9			PA_WORK_PATTERN_TEMP_TABLE.day9%TYPE				,
	  l_DAY10			PA_WORK_PATTERN_TEMP_TABLE.day10%TYPE				,
	  l_DAY11			PA_WORK_PATTERN_TEMP_TABLE.day11%TYPE				,
	  l_DAY12			PA_WORK_PATTERN_TEMP_TABLE.day12%TYPE				,
	  l_DAY13			PA_WORK_PATTERN_TEMP_TABLE.day13%TYPE				,
	  l_DAY14			PA_WORK_PATTERN_TEMP_TABLE.day14%TYPE				,
	  l_row_type_code		PA_WORK_PATTERN_TEMP_TABLE.row_type_code%TYPE			,
	  l_read_only_flag		PA_WORK_PATTERN_TEMP_TABLE.read_only_flag%TYPE
            );

TYPE WORK_PATTERN_TAB_TYPE IS TABLE OF WORK_PATTERN_REC_TYPE
        INDEX BY BINARY_INTEGER;

/* 7693634 start */
TYPE PA_DATE_TBL_TBL_TYPE IS TABLE OF SYSTEM.PA_DATE_TBL_TYPE INDEX BY BINARY_INTEGER;
TYPE PA_NUM_TBL_TBL_TYPE IS TABLE OF SYSTEM.PA_NUM_TBL_TYPE INDEX BY BINARY_INTEGER;
/* 7693634 end */

G_update_schedule_bulk_call varchar2(1) := 'N'; -- Bug 8233045

-- Procedure            : change_work_pattern_duration
-- Purpose              : This procedure is called from self service for changing duration and work pattern.
--                      : It uses existing change_work_pattern and change_duration procedures to do the job.
--                      : While calling change_duartion and change_work_pattern, it passes newly introduced
--                      : parameter p_generate_timeline_flag as N, so that they do not call timeline API.
--			: Typically this API will get called for a set of assignments of a resource
--                      : (in a loop or from VORowImpl). So it takes two parameters p_prev_call_timeline_st_date
--                      : and p_prev_call_timeline_end_date. For first assignment in the loop it will be null.
--                      : So x_call_timeline_st_date and x_call_timeline_end_date will have the required date ranges
--                      : for which timeline has to be regenerated. For the second assignment p_prev_call_timeline_st_date
--                      : and p_prev_call_timeline_end_date will have  the first assighnmenmt's x_call_timeline_st_date
--                      : and x_call_timeline_end_date correspondingly. Then it will again calculate the timeline start date
--                      : and timeline end date for the second assignment. Then it will compare it with
--                      : p_prev_call_timeline_st_date and p_prev_call_timeline_end_date and will take
--                      : min(new timeline start date, p_prev_call_timeline_st_date) and
--                      : max(new timeline end date, p_prev_call_timeline_end_date). Similarly for other assignments....
--                      : After this API is called for a set of assignments, you need to call PA_FORECASTITEM_PVT.Create_Forecast_Item
--                      : with person_id as paremetrer and with the returned dates x_call_timeline_st_date
--                      : and x_call_timeline_end_date
-- Parameters           :
-- Note                 : Note that the p_hours_table should have hours quantity starting at p_start_date and
--                      : ending at p_end_date.


PROCEDURE change_work_pattern_duration(
 	 p_record_version_number         IN NUMBER			,
         p_project_id                    IN NUMBER			,
         p_calendar_id                   IN NUMBER			,
         p_assignment_id                 IN NUMBER			,
         p_resource_id		         IN NUMBER			,
         p_assignment_type               IN VARCHAR2			,
         p_asgn_start_date               IN DATE            := NULL	,
         p_asgn_end_date                 IN DATE            := NULL	,
         p_start_date                    IN DATE            := NULL	,
     --    p_end_date                      IN DATE            := NULL	,
         p_assignment_status_code        IN VARCHAR2        := NULL	,
	 p_hours_table     	         IN SYSTEM.PA_NUM_TBL_TYPE	,
	 p_prev_call_timeline_st_date	 IN DATE			,
	 p_prev_call_timeline_end_date	 IN DATE			,
 	 x_call_timeline_st_date     	 OUT NOCOPY DATE			, --File.Sql.39 bug 4440895
 	 x_call_timeline_end_date     	 OUT NOCOPY DATE			, --File.Sql.39 bug 4440895
--	 x_person_id			 OUT NUMBER			,
         x_return_status                 OUT NOCOPY VARCHAR2			, --File.Sql.39 bug 4440895
         x_msg_count                     OUT NOCOPY NUMBER			, --File.Sql.39 bug 4440895
         x_msg_data                      OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895



-- Procedure            : populate_work_pattern_table
-- Purpose              : This procedure is called from self service for populating the global temp table
--                      : pa_work_pattern_temp_table for the given assignment start date and assignment
--                      : end date. The data will be populated for 14 days starting with Global week start day
--                      : <= p_display_start_date. p_status_code is optional, if it is not given then it will
--                      : fetch all the assignments irrespective of the assignment schedule status.
--                      : Finally it returns the actual start date depending on the global week start date
-- Parameters           :
--

PROCEDURE populate_work_pattern_table(
	    p_resource_id_tbl	     IN SYSTEM.PA_NUM_TBL_TYPE	,
            p_assgn_range_start_date IN DATE := NULL		,
            p_assgn_range_end_date   IN DATE := NULL		,
            p_display_start_date     IN DATE			,
	    p_status_code            IN VARCHAR2 := NULL	,
            p_delete_flag	     IN VARCHAR2 := 'Y'		,
            x_show_start_date        OUT NOCOPY DATE			, --File.Sql.39 bug 4440895
            x_return_status	     OUT NOCOPY VARCHAR2		, --File.Sql.39 bug 4440895
            x_msg_count              OUT NOCOPY NUMBER			, --File.Sql.39 bug 4440895
            x_msg_data               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Unilog Enhancement : END

-- procedure     : update_schedule
-- Purpose       : This procedure will change the schedule records of the assignments passed in.
--                 It can accept either one assignment ID or an assignment ID array.
--
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
 ,x_msg_data                      OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Bug 7693634
-- procedure     : update_schedule
-- Purpose       : Same Procedure as above bu invoked in bulk mode
--
PROCEDURE update_schedule_bulk
( p_project_id_tbl                    IN  SYSTEM.PA_NUM_TBL_TYPE
 ,p_mass_update_flag_tbl              IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  --       := FND_API.G_FALSE
 ,p_exception_type_code_tbl           IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
 ,p_record_version_number_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,p_assignment_id_tbl                 IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
-- ,p_assignment_id_array_tbl           IN  PA_NUM_TBL_TBL_TYPE --:= NULL
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
 ,x_msg_data_tbl                      OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE );




 PROCEDURE update_new_schedule_bulk
( p_project_id_tbl                    IN  SYSTEM.PA_NUM_TBL_TYPE
 ,p_mass_update_flag_tbl              IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE  --       := FND_API.G_FALSE
 ,p_exception_type_code_tbl           IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
 ,p_record_version_number_tbl         IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,p_assignment_id_tbl                 IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
-- ,p_assignment_id_array_tbl           IN  PA_NUM_TBL_TBL_TYPE --:= NULL
 ,p_change_start_date_tbl             IN  SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_change_end_date_tbl               IN  SYSTEM.PA_DATE_TBL_TYPE             := NULL
 ,p_requirement_status_code_tbl       IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_assignment_status_code_tbl        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_last_row_flag_tbl                 IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := 'Y'
 ,p_commit_tbl                        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := FND_API.G_FALSE
 ,p_validate_only_tbl                 IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --  := FND_API.G_TRUE
 ,p_msg_data_in_tbl                   IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE
  ,p_change_hours_type_code_tbl        IN  SYSTEM.PA_VARCHAR2_2000_TBL_TYPE         := NULL
 ,p_calendar_percent_tbl              IN  SYSTEM.PA_NUM_TBL_TYPE     := NULL
 ,p_change_calendar_id_tbl            IN  SYSTEM.PA_NUM_TBL_TYPE           := NULL
 ,x_return_status_tbl                 OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE       --File.Sql.39 bug 4440895
 ,x_msg_count_tbl                     OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE         --File.Sql.39 bug 4440895
 ,x_msg_data_tbl                      OUT NOCOPY SYSTEM.PA_VARCHAR2_2000_TBL_TYPE


);



-- procedure     : single_update_schedule
-- Purpose       : This procedure will change the schedule records of a single assignment.
--
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
 ,x_msg_data                      OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895



-- procedure     : mass_update_schedule
-- Purpose       : This procedure will change the schedule records of the assignments passed in.
--                 Currently, this procedure will only be called by the Mass Transaction Workflow API.
--
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
 ,x_success_assignment_id_tbl     OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE  /* Added NOCOPY for bug#2674619 */
 ,x_return_status                 OUT NOCOPY VARCHAR2       --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT NOCOPY NUMBER         --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : change_duration
-- Purpose              : Insert record into PA_SCHEDULE_EXCEPTIONS table.
-- Parameters           :
--
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
	 p_called_by_proj_party          IN  VARCHAR2         := 'N', -- Added for Bug 6631033
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895


--
-- Procedure            : change_hours
-- Purpose              : Insert records into PA_SCHEDULE_EXCEPTIONS table.
-- Parameters           :
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
	 p_non_working_day_flag          IN varchar2 := 'N' , /* bug#2463257 */
	 p_assignment_status_code        IN Varchar2        ,
	 p_change_hours_type_code        IN varchar2        ,
	 p_hrs_per_day                   IN Number          ,
	 p_calendar_percent              IN Number          ,
         p_change_calendar_type_code     IN VARCHAR2        ,
       --  p_change_calendar_name          IN VARCHAR2        ,
         p_change_calendar_id            IN VARCHAR2        ,
	 p_asgn_start_date               IN DATE            ,
	 p_asgn_end_date                 IN DATE            ,
         p_init_msg_list                 IN VARCHAR2        := FND_API.G_FALSE,
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : change_work_pattern
-- Purpose              : Insert records into PA_SCHEDULE_EXCEPTIONS table.
-- Parameters           :
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
	 p_last_row_flag                 IN VARCHAR2        := 'Y',
	 p_generate_timeline_flag	 IN VARCHAR2	    := 'Y', --Unilog
	 x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
	 x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


--
-- Procedure            : change_status
-- Purpose              : Insert records into PA_SCHEDULE_EXCEPTIONS table.
-- Parameters           :
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
	 x_msg_data                      OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--
-- Procedure            : change_calendar
-- Purpose              : Insert records into PA_SCHEDULE_EXCEPTIONS table.
-- Parameters           :
--
PROCEDURE change_calendar
        (
          p_record_version_number         IN Number          ,
          p_project_id                    IN Number          ,
          p_calendar_id                   IN Number          ,
          p_calendar_name                 IN Varchar2        ,
          p_assignment_id                 IN Number          ,
          p_assignment_type               IN Varchar2        ,
          p_start_date                    IN date            ,
          p_end_date                      IN date            ,
          p_asgn_start_date               IN DATE            ,
          p_asgn_end_date                 IN DATE            ,
          x_return_status                 OUT  NOCOPY VARCHAR2      , --File.Sql.39 bug 4440895
          x_msg_count                     OUT  NOCOPY NUMBER        , --File.Sql.39 bug 4440895
          x_msg_data                      OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE change_schedule(x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          );

-- Procedure            : change_schedule
-- Purpose              : This procedure is called from periodic process to apply the
--                        the exceptions on schedule.


PROCEDURE change_asgn_schedule(
                               p_record_version_number         IN Number,
                               p_assignment_id  IN  NUMBER,
                               p_project_id     IN NUMBER,
                               p_exception_id   IN  NUMBER,
                               p_save_to_hist   IN VARCHAR2 :=  FND_API.G_TRUE,
                               p_remove_conflict_flag IN VARCHAR2 := 'N',
			       p_generate_timeline_flag IN VARCHAR2 :=	'Y', --Unilog
                               p_called_by_proj_party          IN  VARCHAR2         := 'N', -- Added for Bug 6631033
                               x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                               x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                               x_msg_data       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                               );

-- Procedure            : change_asgn_schedule
-- Purpose              : This procedure will be called from each schedule change page via
--                        workflow. This procedure will apply the exceptions for the team role
--                        on the team role schedules.
--                        array processing. This overloaded function.


PROCEDURE create_calendar_schedule ( p_calendar_id            IN   NUMBER,
                                     x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                     x_msg_data               OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Procedure            : create_calendar_schedule
-- Purpose              : This procedure is called from periodic process for creating calendar schedule
--                        in array processing.
-- Parameters           :
--

PROCEDURE get_proj_calendar_default ( p_proj_organization     IN   NUMBER,
                                      p_project_id            IN   NUMBER,
                                      x_calendar_id           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_calendar_name         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_return_status         OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                      x_msg_count             OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                      x_msg_data              OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Procedure            : get_proj_calendar_default
-- Purpose              : This procedure gets the calendar on the basis of organization id or project id
-- Parameters           :
--

PROCEDURE create_new_cal_schedules ( p_start_calendar_name            IN   VARCHAR2,
                                     p_end_calendar_name              IN   VARCHAR2,
                                     x_return_status                  OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     x_msg_count                      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                     x_msg_data                       OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

-- Procedure            : create_new_cal_schedules
-- Purpose              : This procedure is called from periodic process for creating schedule for new calendars
--                        in array processing.
-- Parameters           :
--

END PA_SCHEDULE_PUB;

/
