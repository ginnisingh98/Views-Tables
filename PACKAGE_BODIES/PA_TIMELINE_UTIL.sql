--------------------------------------------------------
--  DDL for Package Body PA_TIMELINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TIMELINE_UTIL" as
/* $Header: PARLUTSB.pls 120.4 2006/03/28 00:11:42 vkadimes noship $ */

--	Procedure		Create_Time_Scale
--	Pursose			To create time scale records in a
--				temp table while displaying timeline
--
--	Parameters
--
--		p_start_date	 Date
--		p_scale_type	 VARCHAR2 MONTH or THREE_MONTH
--

-- Global variables Added for bug No 5079785.

g_debug_mode	CONSTANT varchar2(1) :=  fnd_profile.value('PA_DEBUG_MODE');
--fnd_profile.get('PA_DEBUG_MODE', g_debug_mode);
PROCEDURE Create_Time_Scale (p_start_date					 IN		 DATE,
														 p_end_date						 IN		 DATE := null,
														 p_scale_type					 IN		 VARCHAR2,
														 x_return_status			 OUT	 NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
														 x_msg_count					 OUT	 NOCOPY NUMBER, --File.Sql.39 bug 4440895
														 x_msg_data						 OUT	 NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
														)
IS

	 l_start_date					DATE;
	 l_end_date						DATE;
	 t_date								DATE;
	 l_date								DATE;
	 l_month_date					DATE;
	 l_msg_index_out				 NUMBER;
         -- added for Bug: 4537865
         l_new_msg_data					 VARCHAR2(2000);
         -- added for Bug: 4537865

	 TmpTimeScaleTabTyp		PA_TIMELINE_GLOB.TimeScaleTabTyp;

	 I										INTEGER := 0;
	 l_invalid_scale_type EXCEPTION;

BEGIN

	 PA_TIMELINE_TIME_SCALE_PKG.delete_row( x_return_status,
		 x_msg_count,
		 x_msg_data);

	 l_date := p_start_date;
	 l_start_date	 := p_start_date ;	--Get the Week start date */
	 l_month_date	 := l_start_date;
	 t_date				 := l_start_date;
	 l_end_date := p_end_date;

	 IF (p_end_date IS NULL) THEN
			IF (p_scale_type =  'MONTH') THEN
				 l_end_date := p_start_date + 34;
			ELSIF (p_scale_type = 'THREE_MONTH') THEN
				 l_end_date := p_start_date + 97;
			ELSE
				 raise l_invalid_scale_type;
			END IF;
	 END IF;

	 IF p_scale_type	= 'MONTH' THEN

			l_date			:= p_start_date +6;

			I	 := I + 1;

			LOOP

				 TmpTimeScaleTabTyp(i).start_date			 := t_date ;
				 TmpTimeScaleTabTyp(i).end_date				 := t_date ;
				 TmpTimeScaleTabTyp(i).scale_row_type	 := 'DAY_NUM' ;
				 TmpTimeScaleTabTyp(i).scale_type			 := p_scale_type;	 --Input value
				 TmpTimeScaleTabTyp(i).scale_marker_code		:= ' ';
				 TmpTimeScaleTabTyp(i).scale_text			 := TO_CHAR(t_date,'DD');


				 IF (l_date = t_date) THEN

						TmpTimeScaleTabTyp(i).scale_marker_code		 := 'W';
						l_date := l_date + 7;	 --Get the next week end date	 */

				 END IF;


				 IF to_char(t_date,'MON') <> to_char(t_date + 1, 'MON') THEN


							I := I + 1;

							TmpTimeScaleTabTyp(i).scale_row_type	:= 'MONTH' ;
							TmpTimeScaleTabTyp(i).scale_type			:= p_scale_type; --Input value
							TmpTimeScaleTabTyp(i).scale_text			:= TO_CHAR(t_date,'Mon, YYYY');
							TmpTimeScaleTabTyp(i).scale_marker_code		 := 'M';
							TmpTimeScaleTabTyp(i).start_date			:= l_month_date ;
							TmpTimeScaleTabTyp(i).end_date				:= t_date ;

							l_month_date := t_date + 1;	 -- Storing the Start date of the next month

					END IF;

					t_date := t_date + 1;

					I := I + 1;

					EXIT WHEN t_date > l_end_date;

			 END LOOP;

							TmpTimeScaleTabTyp(i).scale_row_type	:= 'MONTH' ;
							TmpTimeScaleTabTyp(i).scale_type			:= p_scale_type;
							TmpTimeScaleTabTyp(i).scale_text			:= TO_CHAR(t_date,'Mon, YYYY');
							TmpTimeScaleTabTyp(i).scale_marker_code		 := 'M';
							TmpTimeScaleTabTyp(i).start_date			:= l_month_date ;
							TmpTimeScaleTabTyp(i).end_date				:= l_end_date ;


			ELSIF (p_scale_type = 'THREE_MONTH') THEN


				l_date				:= p_start_date +6 ;	--Get the Week start date

				i	 := i + 1;

			LOOP

				 TmpTimeScaleTabTyp(i).start_date			 := t_date ;
				 TmpTimeScaleTabTyp(i).end_date				 := l_date ;
				 TmpTimeScaleTabTyp(i).scale_row_type	 := 'WEEK_DAY_NUM' ;
				 TmpTimeScaleTabTyp(i).scale_type			 := p_scale_type; --Input value
				 TmpTimeScaleTabTyp(i).scale_marker_code		:= 'W';
				 TmpTimeScaleTabTyp(i).scale_text			 := TO_CHAR(l_date,'DD');

	--dbms_output.put_line(' Running Tdate	' || to_char(t_date) || '	 '
		--		|| 'ldate	 ' || to_char(l_date) || '	'
		--		|| 'lmonth	' || to_char(l_month_date));


				 IF to_char(l_date,'MON') <> to_char(l_month_date, 'MON') THEN

			 -- dbms_output.put_line(' Before Month Change	 ' || to_char(t_date) || '	'
		--		|| 'ldate	 ' || to_char(l_date) || '	'
		--		|| 'lmonth	' || to_char(l_month_date));

							i := i + 1;

							TmpTimeScaleTabTyp(i).scale_row_type	:= 'MONTH' ;
							TmpTimeScaleTabTyp(i).scale_type			:= p_scale_type; -- Input value
							TmpTimeScaleTabTyp(i).scale_text			:= TO_CHAR(l_month_date,'Mon, YYYY');
							TmpTimeScaleTabTyp(i).scale_marker_code		 := 'M';
							TmpTimeScaleTabTyp(i).start_date			:= l_month_date ;

		--dbms_output.put_line('Last Day	 ' || to_char(LAST_DAY(l_month_date)));

							TmpTimeScaleTabTyp(i).end_date				:= LAST_DAY(l_month_date);

							l_month_date := LAST_DAY(TmpTimeScaleTabTyp(i).end_date) + 1;					 -- Storing the Start date of the next month */

			 --dbms_output.put_line(' After Month Change	 ' || to_char(t_date) || '	' || 'ldate	 ' || to_char(l_date) || '	' || 'lmonth	' || to_char(l_month_date));
					END IF;

					t_date := l_date + 1;
					l_date := l_date + 7;

					I := I + 1;

					EXIT WHEN l_date > l_end_date;


			 END LOOP;

							TmpTimeScaleTabTyp(i).scale_row_type	:= 'MONTH' ;
							TmpTimeScaleTabTyp(i).scale_type			:= p_scale_type;
							TmpTimeScaleTabTyp(i).scale_text			:= TO_CHAR(t_date,'Mon, YYYY');
							TmpTimeScaleTabTyp(i).scale_marker_code		 := 'M';
							TmpTimeScaleTabTyp(i).start_date			:= l_month_date ;
							TmpTimeScaleTabTyp(i).end_date				:= l_end_date ;


	END IF;


-- Insert Record into pa_timeline_time_scale table

		PA_TIMELINE_TIME_SCALE_PKG.insert_row(TmpTimeScaleTabTyp,
																					x_return_status,
																					x_msg_count,
																					x_msg_data
																				 );

		x_return_status := FND_API.G_RET_STS_SUCCESS;

	 EXCEPTION
			WHEN l_invalid_scale_type THEN
				x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
				x_msg_count := 1;
				x_msg_data  := 'Error in PA_TIMELINE_UTIL.CREATE_TIME_SCALE: Invalid Scale Type';
				FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_TIMELINE_UTIL',
					       p_procedure_name   => 'create_time_scale');
				If x_msg_count = 1 THEN
					 pa_interface_utils_pub.get_messages
						 (p_encoded        => FND_API.G_TRUE,
						 p_msg_index      => 1,
						 p_msg_count      => x_msg_count,
						 p_msg_data       => x_msg_data,
					       --p_data           => x_msg_data,		* commented for Bug: 4537865
						 p_data		  => l_new_msg_data,		-- added for Bug: 4537865
						 p_msg_index_out  => l_msg_index_out );
				-- added for Bug: 4537865
				x_msg_data := l_new_msg_data;
				-- added for Bug: 4537865
		    End If;
				RAISE;  -- This is optional depending on the needs
			WHEN OTHERS THEN
					 x_msg_count		 := 1;
					 x_msg_data			 := sqlerrm;
					 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
					 FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
					 p_procedure_name => 'Create_Time_Scale');
			 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded				=> FND_API.G_TRUE ,
					 p_msg_index			=> 1,
					 p_msg_count		=> x_msg_count ,
					 p_msg_data		=> x_msg_data ,
				       --p_data			=> x_msg_data, 		* commented for bug: 4537865
					 p_data			=> l_new_msg_data,	-- added for Bug: 4537865
					 p_msg_index_out	=> l_msg_index_out );

			 -- added for Bug: 4537865
			 x_msg_data := l_new_msg_data;
			 -- added for Bug: 4537865
			 End If;
			RAISE ; -- 4537865 : Included RAISE for WHEN OTHERS block of create_time_scale
END create_time_scale;

/*----------------------------------------------------------------------
|		Function	Get_Week_End_Date
|		Purpose		To get weekend date for given date and org
|
|		Parameters
|
|			p_org_id	IN	Organization ID a
|			p_given_date	IN	Given date
+-----------------------------------------------------------------------*/

FUNCTION Get_Week_End_Date(p_org_id     IN NUMBER,
                           p_given_date IN DATE) RETURN DATE IS

  x_week_ending               DATE;
  x_week_ending_day           VARCHAR2(80);
  -- Retrieve week_ending_index from the FND profile value.
  x_week_ending_day_index     NUMBER := TO_NUMBER(FND_PROFILE.VALUE('PA_GLOBAL_WEEK_START_DAY')) + 6;


BEGIN

       /* ( 	SELECT DECODE(exp_cycle_start_day_code,1,8,exp_cycle_start_day_code) -1
          	  INTO x_week_ending_day_index
          	  FROM pa_implementations_all
        	 WHERE  NVL(org_id,-99) = NVL(p_org_id,-99);

        	SELECT TO_CHAR(TO_DATE('01-01-1950','DD-MM-YYYY') + NVL(x_week_ending_day_index,0)-1,'Day')
          	INTO x_week_ending_day
          	FROM sys.dual;

        	SELECT NEXT_DAY(p_given_date-1,x_week_ending_day)
          	INTO x_week_ending
          	FROM sys.dual;


        RETURN(x_week_ending); ) */

   -- Bug fix #1393829
--        BEGIN
/* Bug - 1799636 This part of code is commented to resolve the performance bug

        SELECT TO_CHAR(TO_DATE('01-01-1950','DD-MM-YYYY') + NVL(x_week_ending_day_index,0)-1,'Day')
        INTO x_week_ending_day
        FROM sys.dual;

        -- 1604283 (jmarques): Removed unnecessary TO_DATE call around
        -- DATE parameter.
        SELECT NEXT_DAY(p_given_date -1,x_week_ending_day)
        INTO x_week_ending
        FROM sys.dual;
    END;
*/
	x_week_ending_day:= TO_CHAR(TO_DATE('01-01-1950','DD-MM-YYYY') + NVL(x_week_ending_day_index,0)-1,'Day');
	x_week_ending :=  NEXT_DAY(p_given_date -1,x_week_ending_day);

   RETURN(x_week_ending);


END Get_Week_End_Date;

/*------------------------------------------------------------------------
|	Procedure	   :	get_timeline_period
|	Purpose		   :	This procedure is used to get the next
|				timeline display period for a given date.
|	GUI how it is used :
|				All Timelines have Month and 3-Month time scales.
|				Initial default is Month.
|				Navigation to Previous Month and Next Month via
|				links on each side of the timeline.
|				Each click of this link shifts the time scale by 5 weeks.
|				A maximum of 25 timeline data rows will be shown at a time.
|				If there are more than 25 rows, show following links:
|				Previous and Next to shift up or down next set of 25 rows
|
|	Parameters
|		p_current_date		IN	Given Date
|		p_Scale_type		IN	MONTH or THREE_MONTH
|		p_navigate_type		IN	PREV_MONTH,NEXT_MONTH,
|						NEXT_THREE_MONTH,
|						 PREV_THREE_MONTH
|		p_org_id		IN	Organization ID
|		x_period_start_date    OUT	Next display start date
|		x_period_end_date    OUT	Next display end date
+-----------------------------------------------------------------------------------*/

PROCEDURE get_timeline_period ( p_current_date           IN DATE,
																p_num_days               IN NUMBER := NULL,
																p_scale_type             IN VARCHAR2,
																p_navigate_type          IN VARCHAR2,
																p_org_id                 IN NUMBER,
																x_period_start_date     OUT NOCOPY DATE, --File.Sql.39 bug 4440895
																x_period_end_date       OUT NOCOPY DATE, --File.Sql.39 bug 4440895
																x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
																x_msg_count             OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
																x_msg_data              OUT NOCOPY VARCHAR2 )  IS --File.Sql.39 bug 4440895

	 td_date		DATE;
	 l_msg_index_out		     NUMBER;
	 l_num_days  NUMBER;
	 -- added for bug: 4537865
	 l_new_msg_data		VARCHAR2(2000);
	 -- added for bug: 4537865
	 l_invalid_scale_type EXCEPTION;
BEGIN
	 l_num_days := p_num_days;

	 IF (p_num_days IS NULL) THEN
			IF (p_scale_type =  'MONTH') THEN
				 l_num_days := 35;
			ELSIF (p_scale_type = 'THREE_MONTH') THEN
				 l_num_days := 98;
			ELSE
				 raise l_invalid_scale_type;
			END IF;
	 END IF;

	 td_date :=	get_week_end_date(p_org_id, p_current_date);

	 IF p_navigate_type='NEXT_MONTH' THEN
			x_period_start_date	:=td_date +29;   -- Add 4 weeks + 1 day
	 ELSIF p_navigate_type='PREV_MONTH' THEN
			x_period_start_date	:=td_date -41;   -- Subtract 6 weeks - 1 day
	 ELSIF p_navigate_type='NEXT_WEEK' THEN
			x_period_start_date	:=td_date + 1;   -- add 0 weeks + 1 day
	 ELSIF p_navigate_type='PREV_WEEK' THEN
			x_period_start_date	:=td_date - 13;  -- Subtract 2 weeks - 1 day
	 ELSIF p_navigate_type='NEXT_THREE_MONTH' THEN
			x_period_start_date	:=td_date + 92 ;  -- Add 13 weeks + 1 day
	 ELSIF p_navigate_type='PREV_THREE_MONTH' THEN
			x_period_start_date	:=td_date - 104; -- Subtract 15 weeks - 1 day
	 ELSIF p_navigate_type='CURRENT' THEN
			x_period_start_date	:= td_date -6;
	 END IF;

	 x_period_end_date := x_period_start_date + l_num_days - 1;

	 x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
	 WHEN l_invalid_scale_type THEN

	   -- 4537865
	   x_period_end_date := NULL ;
	   x_period_start_date := NULL ;

	   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	   x_msg_count := 1;
	   x_msg_data  := 'Error in PA_TIMELINE_UTIL.GET_TIMELINE_PERIOD: Invalid Scale Type';
	   FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_TIMELINE_UTIL',
	                          p_procedure_name   => 'get_timeline_period');
	   If x_msg_count = 1 THEN
					pa_interface_utils_pub.get_messages
						(p_encoded        => FND_API.G_TRUE,
						p_msg_index      => 1,
						p_msg_count      => x_msg_count,
						p_msg_data       => x_msg_data,
					      --p_data           => x_msg_data,			* Commented for Bug: 4537865
						p_data		 => l_new_msg_data,		-- added for bug: 4537865
						p_msg_index_out  => l_msg_index_out );
				-- added for bug: 4537865
					x_msg_data := l_new_msg_data;
				-- added for bug: 4537865
		 End If;
	   RAISE;  -- This is optional depending on the needs
	 WHEN OTHERS THEN
           -- 4537865
           x_period_end_date := NULL ;
           x_period_start_date := NULL ;

		 x_msg_count     := 1;
		 x_msg_data      := sqlerrm;
		 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
		 FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
			 p_procedure_name => 'get_timeline_period ');
		 If x_msg_count = 1 THEN
				pa_interface_utils_pub.get_messages
					(p_encoded        => FND_API.G_TRUE ,
					p_msg_index      => 1,
					p_msg_count      => x_msg_count ,
					p_msg_data       => x_msg_data ,
				      --p_data           => x_msg_data, 		* Commented for Bug fix: 4537865
					p_data		 => l_new_msg_data,		-- added for Bug Fix: 4537865
					p_msg_index_out  => l_msg_index_out );
		 	-- added for Bug Fix: 4537865
			x_msg_data := l_new_msg_data;
			-- added for Bug Fix: 4537865
		 End If;
		RAISE; -- 4537865
END get_timeline_period;

/*------------------------------------------------------------------------
|       Procedure               Get_Week_Dates_Range
|       Purpose                 This procedure is used to get the next
|                               timeline display period for a given date.
|
+-------------------------------------------------------------------------*/

PROCEDURE Get_Week_Dates_Range( p_org_id                IN      NUMBER,
                                p_start_date            IN      DATE,
                                p_end_date              IN      DATE,
                                x_WeekDatesRangeTab     OUT     NOCOPY PA_TIMELINE_GLOB.WeekDatesRangeTabTyp, --File.Sql.39 bug 4440895
                                x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                x_msg_data              OUT     NOCOPY VARCHAR2) IS --File.Sql.39 bug 4440895

                ld_temp_date    DATE;
                ld_start_date   DATE;
                ld_end_date     DATE;
                li_cnt          INTEGER:=1;
BEGIN

        BEGIN
                ld_temp_date := p_start_date;

        LOOP

                ld_end_date     := Get_Week_End_Date(p_org_id, ld_temp_date);
                ld_start_date   := ld_end_date -6;
                x_WeekDatesRangeTab(li_cnt).week_start_date := ld_start_date;
                x_WeekDatesRangeTab(li_cnt).week_end_date := ld_end_date;
                ld_temp_date    := ld_end_date +1;
                EXIT WHEN (trunc(ld_temp_date) > trunc(p_end_date));
                li_cnt := li_cnt +1;


        END LOOP;

  	x_return_status := FND_API.G_RET_STS_SUCCESS;

        EXCEPTION
        WHEN OTHERS THEN
	   -- 4537865
	   x_WeekDatesRangeTab.delete; -- Delete the table contents so that the Unexp. state wrong data cant be used further

           x_msg_count     := 1;
           x_msg_data      := sqlerrm;
           x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
           FND_MSG_PUB.add_exc_msg(p_pkg_name => 'PA_TIMELINE_PVT',
           p_procedure_name => 'Get_Week_Dates_Range');


        END;

END Get_Week_Dates_Range;
/*------------------------------------------------------------------------
|       Function               Get_Timeline_Profile_Setup
|       Purpose                function is to get profile options
+-------------------------------------------------------------------------*/
FUNCTION Get_Timeline_Profile_Setup RETURN PA_TIMELINE_GLOB.TimelineProfileSetup IS

	TmpTimelineProfileSetup PA_TIMELINE_GLOB.TimelineProfileSetup;

BEGIN
	BEGIN

	 	TmpTimelineProfileSetup.res_capacity_percentage :=
			FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_RES_CAPACITY_PERCENTAGE'));


		TmpTimelineProfileSetup.availability_cal_period :=
				FND_PROFILE.VALUE('PA_AVAILABILITY_CAL_PERIOD');


		TmpTimelineProfileSetup.availability_duration :=
			FND_NUMBER.CANONICAL_TO_NUMBER(FND_PROFILE.VALUE('PA_AVAILABILITY_DURATION'));

                EXCEPTION
                WHEN OTHERS THEN
                        raise;
        END;


	RETURN (TmpTimelineProfileSetup);

END Get_Timeline_Profile_Setup;
/*------------------------------------------------------------------------
|       Function               Get_Color_Pattern_Code
|       Purpose                function is to get color pattern code for
|			       a specific system status
+-------------------------------------------------------------------------*/

FUNCTION Get_Color_Pattern_Code(p_lookup_code IN VARCHAR2) RETURN VARCHAR2 IS
		lv_color_pattern VARCHAR2(2);
l_lookup_type VARCHAR2(30) ;
BEGIN
	BEGIN
l_lookup_type := 'TIMELINE_STATUS';
    		SELECT color_pattern_code
      		  INTO lv_color_pattern
      		  FROM pa_timeline_colors
      		 WHERE lookup_code = p_lookup_code
           AND lookup_type = l_lookup_type;

		EXCEPTION
		WHEN OTHERS THEN
			raise;
	END;
	RETURN(lv_color_pattern);
END GET_COLOR_PATTERN_CODE;

PROCEDURE debug(p_text IN VARCHAR2) IS
  -- commented for Bug 5079785
  --l_debug_mode            VARCHAR2(20) := 'N'; -- Added for Bug 4344821
BEGIN
     -- dbms_output.put_line('log : ' || 'pa.plsql.pa_timeline_pvt' ||
     --                      ' : ' || p_text);
-- commented for Bug 5079785 chenged from l_debug_mode to g_debug_mode
--  fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);
--  IF l_debug_mode = 'Y' THEN
  IF g_debug_mode = 'Y' THEN
     PA_DEBUG.WRITE_LOG(
       x_module => 'pa.plsql.pa_timeline_pvt',
       x_msg => p_text,
       x_log_level => 6);
     pa_debug.write_file('print_message: ' || 'Log :'||p_text);
  END IF;
END debug;

PROCEDURE debug(p_module IN VARCHAR2,
                p_msg IN VARCHAR2,
                p_log_level IN NUMBER DEFAULT 6) IS
-- commented for Bug 5079785
--  l_debug_mode            VARCHAR2(20) := 'N'; -- Added for Bug 4344821
BEGIN
     -- dbms_output.put_line('log : ' || p_module || ' : ' || p_msg);
-- commented for Bug 5079785 chenged from l_debug_mode to g_debug_mode
 -- fnd_profile.get('PA_DEBUG_MODE', l_debug_mode);
-- IF l_debug_mode = 'Y' THEN
 IF g_debug_mode ='Y' THEN
     PA_DEBUG.WRITE_LOG(
       x_module => p_module,
       x_msg => p_msg,
       x_log_level => p_log_level);
     pa_debug.write_file('print_message: ' || 'Log :'||p_msg);
  END IF;
END debug;


END PA_TIMELINE_UTIL;

/
