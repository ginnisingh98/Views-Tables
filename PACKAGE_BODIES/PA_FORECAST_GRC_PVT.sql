--------------------------------------------------------
--  DDL for Package Body PA_FORECAST_GRC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FORECAST_GRC_PVT" AS
/* $Header: PARFGRCB.pls 120.2 2005/08/24 04:13:25 avaithia noship $ */
--------------------------------------------------------------------------------------
-- Description	        This procedure will calculate the total possible
--			working hours of a person between the input start
--			date and end date.
-- Procedure Name	Get_Resource_Capacity
-- Used Subprograms	PA_SCHEDULE_PVT.get_resource_schedule
-- Input parameters    Type       Required            Description
-- p_org_id           NUMBER        Yes             Orgnization ID, to derive the
--						    HR start date and end date
-- p_person_id	      NUMBER	    Yes		    Person ID, to derive the HR start
--						    date and end date
-- p_start_date       DATE	    Yes		    Start date of the person
-- p_end_date         DATE	    Yew		    End date of the person
--
-- Output parameters	Type	Description
-- x_resource_capacity	NUMBER  The total hours a person could work between
--				p_start_date and p_end_date.
-- x_return_status     VARCHAR2 The return status of this procedure
-------------------------------------------------------------------------------------------------------
PROCEDURE Get_Resource_Capacity (p_org_id	        IN	NUMBER,
                                 p_person_id	        IN	NUMBER,
                                 p_start_date	        IN	DATE,
                                 p_end_date	        IN	DATE,
                                 x_resource_capacity	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                )
IS

l_start_date 		DATE;	--input start date
l_end_date  		DATE;   --input end date

l_hr_start_date		DATE;   --HR start date
l_hr_end_date 		DATE;   --HR end date

l_real_start_date	DATE;	--actual start date passed to get_resource_schedule
				--API
l_real_end_date		DATE;   --actual end date passed to get_resource_schedule API

l_date			DATE;   --date variable
l_no_of_days		NUMBER; --number of days between the l_real_start_date and
			        --l_real_end_date
i			NUMBER; --loop variable
j			NUMBER; --loop variable

l_resource_id		NUMBER; --resource id
l_resource_type		VARCHAR2(30); --resource type

l_no_of_hours		NUMBER;
l_total_no_of_hours	NUMBER;

l_x_return_status	VARCHAR2(2);
l_msg_count             number;
l_msg_data              varchar2(80);


l_monday_hours		NUMBER;
l_tuesday_hours		NUMBER;
l_wednesday_hours	NUMBER;
l_thursday_hours	NUMBER;
l_friday_hours		NUMBER;
l_saturday_hours	NUMBER;
l_sunday_hours		NUMBER;
l_sch_record_tab	PA_SCHEDULE_GLOB.ScheduleTabTyp;

--Delcare a cursor to store the HR assignment start and end dates for the
--person

CURSOR c_assignment_dates IS
/* SELECT EFFECTIVE_START_DATE,EFFECTIVE_END_DATE
 FROM    per_assignments_f
 WHERE  person_id = p_person_id
 AND    organization_id = p_org_id
 AND (((EFFECTIVE_END_DATE BETWEEN p_start_date AND p_end_date) OR
     (EFFECTIVE_START_DATE   BETWEEN p_start_date AND p_end_date))
     OR ((p_start_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)OR
        (p_end_date BETWEEN EFFECTIVE_START_DATE AND EFFECTIVE_END_DATE)));
*/

SELECT RESOURCE_EFFECTIVE_START_DATE, RESOURCE_EFFECTIVE_END_DATE
FROM pa_resources_denorm
WHERE person_id = p_person_id
 AND   resource_organization_id = p_org_id
AND (((RESOURCE_EFFECTIVE_END_DATE BETWEEN p_start_date AND p_end_date) OR
     (RESOURCE_EFFECTIVE_START_DATE   BETWEEN p_start_date AND p_end_date))
     OR ((p_start_date BETWEEN RESOURCE_EFFECTIVE_START_DATE AND RESOURCE_EFFECTIVE_END_DATE)OR
        (p_end_date BETWEEN RESOURCE_EFFECTIVE_START_DATE AND RESOURCE_EFFECTIVE_END_DATE)));



BEGIN

   --initialize
   l_x_return_status   := FND_API.G_RET_STS_SUCCESS;
   l_no_of_hours       := 0;
   l_total_no_of_hours := 0;

   --First derive the resource_id from person_id
   SELECT resource_id
   INTO	  l_resource_id
   FROM   pa_resource_txn_attributes
   WHERE  person_id = p_person_id;

   --Set the resource_type
   l_resource_type     := 'PA_RESOURCE_ID';

   --Open the cursor
   OPEN c_assignment_dates;

   --Do a fetch loop here to retrive the HR assignment start and end dates for a
   --person
   LOOP
     FETCH c_assignment_dates
     INTO l_hr_start_date, l_hr_end_date;

     EXIT WHEN c_assignment_dates%NOTFOUND;

     --Process the dates here
     --Compare the p_start_date and p_end_date with l_hr_start_date and l_hr_end_date
     IF  (NOT (p_start_date >= l_hr_end_date OR
       p_end_date <= l_hr_start_date)) THEN

       --Condition 1
       IF ( p_start_date >= l_hr_start_date AND p_end_date <= l_hr_end_date)
THEN
         l_real_start_date := p_start_date;
         l_real_end_date   := p_end_date;

       --Condition 2
       ELSIF (p_start_date <= l_hr_start_date AND  p_end_date >= l_hr_end_date)
THEN
            l_real_start_date := l_hr_start_date;
            l_real_end_date   := l_hr_end_date;

       --Condition 3
       ELSIF ((p_start_date <= l_hr_start_date) AND (p_end_date <= l_hr_end_date
             AND p_end_date >= l_hr_start_date)) THEN
           l_real_start_date := l_hr_start_date;
           l_real_end_date   := p_end_date;

       --Condition 4
       ELSIF (p_start_date >=  l_hr_start_date AND p_start_date <= l_hr_end_date)
             AND p_end_date >= l_hr_end_date THEN
            l_real_start_date := p_start_date;
            l_real_end_date   := l_hr_end_date;

       END IF;

       --CALL the get_resource_schedule API here
       IF (l_x_return_status = FND_API.G_RET_STS_SUCCESS) THEN
          PA_SCHEDULE_PVT.get_resource_schedule(
                                                p_source_id     	=> l_resource_id,
                                                p_source_type      	=> l_resource_type,
                                                p_start_date    	=> l_real_start_date,
                                                p_end_date		=> l_real_end_date,
                                                x_sch_record_tab 	=> l_sch_record_tab,
                                                x_return_status  	=> l_x_return_status,
                                                x_msg_count		=> l_msg_count,
                                                x_msg_data		=> l_msg_data);
          l_date       := l_real_start_date;
          l_no_of_days := l_real_end_date - l_real_start_date + 1 ;
          FOR i IN 1..l_no_of_days LOOP

	    FOR j IN l_sch_record_tab.first..l_sch_record_tab.last LOOP
               IF (trunc(l_date) BETWEEN
                              trunc(l_sch_record_tab(j).start_date) AND
                              trunc(l_sch_record_tab(j).end_date)) THEN

	 	IF TO_CHAR(l_date,'DY','NLS_DATE_LANGUAGE=AMERICAN')= 'MON' THEN
	 	      l_no_of_hours := l_no_of_hours + nvl(l_sch_record_tab(j).monday_hours,0);

	 	ELSIF TO_CHAR(l_date, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'TUE' THEN
	 	      l_no_of_hours := l_no_of_hours + nvl(l_sch_record_tab(j).tuesday_hours,0);

	 	ELSIF TO_CHAR(l_date, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'WED' THEN
 	 	      l_no_of_hours := l_no_of_hours + nvl(l_sch_record_tab(j).wednesday_hours,0);

	 	ELSIF TO_CHAR(l_date, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'THU' THEN
	 	      l_no_of_hours := l_no_of_hours + nvl(l_sch_record_tab(j).thursday_hours,0);

	 	ELSIF TO_CHAR(l_date, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'FRI' THEN
	 	      l_no_of_hours := l_no_of_hours + nvl(l_sch_record_tab(j).friday_hours,0);

	 	ELSIF TO_CHAR(l_date, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'SAT' THEN
	 	      l_no_of_hours := l_no_of_hours + nvl(l_sch_record_tab(j).saturday_hours,0);

	 	ELSIF TO_CHAR(l_date, 'DY','NLS_DATE_LANGUAGE=AMERICAN') = 'SUN' THEN
	 	      l_no_of_hours := l_no_of_hours + nvl(l_sch_record_tab(j).sunday_hours,0);

	 	END IF;
              END IF;
	    END LOOP;
	    l_date := l_date + 1 ;

           --end for loop
          END LOOP;

       END IF;

       --calculate the total hours
       l_total_no_of_hours := l_total_no_of_hours + l_no_of_hours;

       --end IF loop
     END IF;
     --end fetch loop
   END LOOP;

   CLOSE c_assignment_dates;

   x_resource_capacity := l_total_no_of_hours;
   x_return_status     := l_x_return_status;

EXCEPTION
  WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := SQLERRM;
     FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FORECAST_GRC_PVT',
                              p_procedure_name   => 'get_resource_capacity');
     x_resource_capacity := NULL ; -- RESET the other OUT param also 4537865
END Get_Resource_Capacity;



----------------------------------------------------------------------------------------
PROCEDURE Get_Capacity_Vector(p_OU_id		      IN    NUMBER,
                              p_exp_org_id_tab        IN    PA_PLSQL_DATATYPES.IdTabTyp,
                              p_person_id_tab         IN    PA_PLSQL_DATATYPES.IdTabTyp,
                              p_resource_id_tab       IN    PA_PLSQL_DATATYPES.IdTabTyp,
                              p_in_res_eff_s_date_tab IN    PA_PLSQL_DATATYPES.DateTabTyp,
                              p_in_res_eff_e_date_tab IN    PA_PLSQL_DATATYPES.DateTabTyp,
                              p_balance_type_code     IN    VARCHAR2,
                              p_run_start_date        IN    DATE,
                              p_run_end_date          IN    DATE,
                              x_resource_capacity_tab OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
                              x_exp_orgz_id_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
  			      x_person_id_tab         OUT   NOCOPY PA_PLSQL_DATATYPES.IdTabTyp, --File.Sql.39 bug 4440895
  			      x_period_type_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
  			      x_period_name_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp, --File.Sql.39 bug 4440895
  			      x_global_exp_date_tab   OUT   NOCOPY PA_PLSQL_DATATYPES.DateTabTyp, --File.Sql.39 bug 4440895
  			      x_period_year_tab       OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
  			      x_qm_number_tab         OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
			      x_period_num_tab        OUT   NOCOPY PA_PLSQL_DATATYPES.NumTabTyp, --File.Sql.39 bug 4440895
			      x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              x_msg_count             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              x_msg_data              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
			      )IS


  l_OU_id         	NUMBER;
  l_exp_orgz_id        	NUMBER;
  l_person_id     	NUMBER;
  l_balance_type_code	VARCHAR2(30);
  l_period_type   	VARCHAR2(30);
--  l_period_set_name 	VARCHAR2(30):=PA_REP_UTIL_GLOB.G_implementation_details.G_period_set_name;
  l_gl_period_set_name 	VARCHAR2(30):=PA_REP_UTIL_GLOB.G_implementation_details.G_gl_period_set_name; -- bug 3434019
  l_pa_period_set_name 	VARCHAR2(30):=PA_REP_UTIL_GLOB.G_implementation_details.G_pa_period_set_name; -- bug 3434019
  l_period_name   	VARCHAR2(30);
  l_GE_end_date   	DATE;
  l_resource_capacity   NUMBER;
  l_period_balance      NUMBER;
  l_return_status       VARCHAR2(2);
  l_msg_count     	NUMBER;
  l_msg_data      	VARCHAR2(80);
  i 			NUMBER;

  l_pa_period_flag pa_utilization_options.pa_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_pa_period_flag;
  l_gl_period_flag pa_utilization_options.gl_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_gl_period_flag;
  l_ge_period_flag pa_utilization_options.global_exp_period_flag%TYPE := pa_rep_util_glob.G_util_option_details.G_ge_period_flag;
  l_pa_period_type pa_implementations.pa_period_type%TYPE := pa_rep_util_glob.G_implementation_details.G_pa_period_type;
  l_gl_period_type gl_sets_of_books.accounted_period_type%TYPE := pa_rep_util_glob.G_implementation_details.G_gl_period_type;

--  l_global_week_start_day PLS_INTEGER := pa_rep_util_glob.G_global_week_start_day;

  j   NUMBER := 0;
  jj  NUMBER := 0;

--  Cursor to find the periods within PA
  CURSOR PA_PERIODS_CUR is
 SELECT
         pglp.period_name             AS  PERIOD_NAME
        ,pglp.start_date              AS  PERIOD_START_DATE
        ,pglp.end_date                AS  PERIOD_END_DATE
        ,pglp.period_year             AS  PERIOD_YEAR
        ,pglp.quarter_num             AS  PERIOD_QUARTER
        ,(pglp.period_year*10000) + pglp.period_num AS PERIOD_NUM
  FROM   gl_periods                      pglp
  WHERE exists
        (select null
         from gl_date_period_map p
         where pglp.period_set_name = p.period_set_name
  --       and   p.period_set_name = l_period_set_name
         and   p.period_set_name = l_pa_period_set_name  -- bug 3434019
         and   p.period_type = l_pa_period_type
         and   pglp.period_name = p.period_name)
    AND p_run_end_date  >= pglp.start_date
    AND p_run_start_date <= pglp.end_date
;

--  Cursor to find the periods within GL
  CURSOR GL_PERIODS_CUR is
 SELECT
         gglp.period_name             AS  PERIOD_NAME
        ,gglp.start_date              AS  PERIOD_START_DATE
        ,gglp.end_date                AS  PERIOD_END_DATE
        ,gglp.period_year             AS  PERIOD_YEAR
        ,gglp.quarter_num             AS  PERIOD_QUARTER
        ,(gglp.period_year*10000) + gglp.period_num AS PERIOD_NUM
  FROM  gl_periods                      gglp
  WHERE exists
        (select null
         from gl_date_period_map g
         where gglp.period_set_name = g.period_set_name
--         and   g.period_set_name = l_period_set_name
         and   g.period_set_name = l_gl_period_set_name    -- bug 3434019
         and   g.period_type = l_gl_period_type
         and   gglp.period_name = g.period_name)
    AND p_run_start_date <= gglp.end_date
    AND p_run_end_date  >= gglp.start_date
;

  CURSOR GE_PERIODS_CUR is
  SELECT
         period_year                            AS PERIOD_YEAR
        ,mon_or_qtr                             AS PERIOD_MONTH
        ,ge_week_dt                             AS GE_DATE
        ,period_start_date                      AS PERIOD_START_DATE
  FROM  pa_rep_periods_v
  WHERE period_type = 'GE'
  AND   p_run_start_date <= ge_week_dt
  AND   p_run_end_date >= period_start_date
  AND   to_number(to_char(ge_week_dt,'YYYY')) = period_year
  ;

    pa_periods_cur_rec PA_PERIODS_CUR%ROWTYPE;
    gl_periods_cur_rec GL_PERIODS_CUR%ROWTYPE;
    ge_periods_cur_rec GE_PERIODS_CUR%ROWTYPE;

	start_date_to_be_used   DATE;
	end_date_to_be_used     DATE;

BEGIN

    -- 4537865 : Initialize return_status to Success
    x_return_status   := FND_API.G_RET_STS_SUCCESS;
    l_return_status   := FND_API.G_RET_STS_SUCCESS;
    -- 4537865 : End

    l_balance_type_code := p_balance_type_code;
    l_OU_id             := p_OU_id;

    /*
     * Clear all PL/SQL table.
     */
    PA_DEBUG.g_err_stage := 'Clearing all output PL/SQL Table';
    PA_DEBUG.log_message(PA_DEBUG.g_err_stage);
        x_resource_capacity_tab.delete;
        x_exp_orgz_id_tab.delete;
        x_person_id_tab.delete;
        x_period_type_tab.delete;
        x_period_name_tab.delete;
        x_global_exp_date_tab.delete;
        x_period_year_tab.delete;
        x_qm_number_tab.delete;
        x_period_num_tab.delete;


  FOR i IN  p_exp_org_id_tab.FIRST .. p_exp_org_id_tab.LAST LOOP
    l_exp_orgz_id       := p_exp_org_id_tab(i);
    l_person_id         := p_person_id_tab(i);



--  first loop through the PA periods available
     IF l_pa_period_flag = 'Y' then
        FOR pa_periods_cur_rec in PA_PERIODS_CUR LOOP
            l_return_status     := FND_API.G_RET_STS_SUCCESS;
	           IF (
                    ( p_in_res_eff_s_date_tab(i) >= pa_periods_cur_rec.PERIOD_START_DATE
                    and p_in_res_eff_s_date_tab(i) <= pa_periods_cur_rec.PERIOD_END_DATE )
                  OR
                    ( p_in_res_eff_e_date_tab(i) >= pa_periods_cur_rec.PERIOD_START_DATE
                    and p_in_res_eff_e_date_tab(i) <= pa_periods_cur_rec.PERIOD_END_DATE )
                  OR
                    ( pa_periods_cur_rec.PERIOD_START_DATE >= p_in_res_eff_s_date_tab(i)
                    and pa_periods_cur_rec.PERIOD_START_DATE <= p_in_res_eff_e_date_tab(i) )
                  ) THEN

  /*
   * Bug: 1781913
   * The start and end dates to be used as inputs for get_resource_capacity
   * should be such that :
   *    The start_date_to_be_used should be the latest of the following 3 dates:
   *        PERIOD_START_DATE
   *        p_in_res_eff_s_date_tab(i)
   *        p_run_start_date
   *    While the end_date_to_be_used should be the earliest of the following 3 dates:
   *        PERIOD_END_DATE
   *        p_in_res_eff_e_date_tab(i)
   *        p_run_end_date
   */

            start_date_to_be_used := GREATEST(pa_periods_cur_rec.PERIOD_START_DATE
                                              , p_in_res_eff_s_date_tab(i)
                                              , p_run_start_date);
            end_date_to_be_used   := LEAST(pa_periods_cur_rec.PERIOD_END_DATE
                                           , p_in_res_eff_e_date_tab(i)
                                           , p_run_end_date);

--get the resource capacity
--get the resource capacity
            PA_FORECAST_GRC_PVT.get_resource_capacity(
                          p_org_id            => l_exp_orgz_id,
                          p_person_id         => l_person_id,
                          p_start_date        => start_date_to_be_used,
                          p_end_date          => end_date_to_be_used,
                          x_resource_capacity => l_resource_capacity,
                          x_return_status     => l_return_status,
                          x_msg_count         => l_msg_count,
                          x_msg_data          => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

--get the period_balance
            begin
          	  select  bal.period_balance
            	into  l_period_balance
            	from  pa_objects       obj,
       	              pa_summ_balances bal
  	          where   obj.object_id = bal.object_id
  	          and     bal.version_id = -1
  	          and     bal.object_type_code = PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RES_C
  	          and     bal.period_type = l_pa_period_type
  	--        and     bal.period_set_name = l_period_set_name
  	          and     bal.period_set_name = l_pa_period_set_name         -- bug 3434019
  	          and     bal.period_name = pa_periods_cur_rec.PERIOD_NAME
  	          and     bal.global_exp_period_end_date = PA_REP_UTIL_GLOB.G_DUMMY_DATE_C
  	          and     bal.amount_type_id = PA_REP_UTIL_GLOB.G_amt_type_details.G_res_cap_id
  	          and     obj.object_type_code = PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RES_C
  	          and     obj.balance_type_code = l_balance_type_code
 	          and     obj.project_org_id = -1
  	          and     obj.project_organization_id = -1
  	          and     obj.project_id = -1
  	          and     obj.task_id = -1
  	          and     obj.expenditure_org_id = l_OU_id
  	          and     obj.expenditure_organization_id = l_exp_orgz_id
  	          and     obj.person_id = l_person_id
  	          and     obj.assignment_id = -1
  	          and     obj.work_type_id = -1
  	          and     obj.org_util_category_id = -1
  	          and     obj.res_util_category_id = -1
  	             for update of bal.object_id;
            exception
                when no_data_found
                then
                     l_period_balance := 0;
            end;


  	    x_resource_capacity_tab(j) := l_resource_capacity - l_period_balance;
            x_exp_orgz_id_tab(j)       := l_exp_orgz_id;
            x_person_id_tab(j)         := l_person_id;
            x_period_type_tab(j)       := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_PA_C;
            x_period_name_tab(j)       := pa_periods_cur_rec.PERIOD_NAME;
            x_global_exp_date_tab(j)   := PA_REP_UTIL_GLOB.GetDummyDate;
            x_period_year_tab(j)       := pa_periods_cur_rec.PERIOD_YEAR;
            x_qm_number_tab(j)         := pa_periods_cur_rec.PERIOD_QUARTER;
            x_period_num_tab(j)        := pa_periods_cur_rec.PERIOD_NUM;

            j := j+1;
            jj := j;

      	END IF;  -- PA_FORECAST_GRC_PVT.get_resource_capacity returns success

      	END IF;  -- PA_FORECAST_GRC_PVT.checking date effectivity

       END LOOP;   -- PA_PERIODS_CUR loop

 	END IF;  -- l_pa_period_flag = 'Y'

   j := jj;

-- IF and loop for GL
   IF l_gl_period_flag = 'Y' then
        FOR gl_periods_cur_rec in GL_PERIODS_CUR LOOP
            l_return_status     := FND_API.G_RET_STS_SUCCESS;
               IF (
                    ( p_in_res_eff_s_date_tab(i) >= gl_periods_cur_rec.PERIOD_START_DATE
                    and p_in_res_eff_s_date_tab(i) <= gl_periods_cur_rec.PERIOD_END_DATE )
                  OR
                    ( p_in_res_eff_e_date_tab(i) >= gl_periods_cur_rec.PERIOD_START_DATE
                    and p_in_res_eff_e_date_tab(i) <= gl_periods_cur_rec.PERIOD_END_DATE )
                  OR
                    ( gl_periods_cur_rec.PERIOD_START_DATE >= p_in_res_eff_s_date_tab(i)
                    and gl_periods_cur_rec.PERIOD_START_DATE <= p_in_res_eff_e_date_tab(i) )
                  ) THEN


            start_date_to_be_used := GREATEST(gl_periods_cur_rec.PERIOD_START_DATE
                                              , p_in_res_eff_s_date_tab(i)
                                              , p_run_start_date);
            end_date_to_be_used   := LEAST(gl_periods_cur_rec.PERIOD_END_DATE
                                           , p_in_res_eff_e_date_tab(i)
                                           , p_run_end_date);

 PA_FORECAST_GRC_PVT.get_resource_capacity(
                          p_org_id            => l_exp_orgz_id,
                          p_person_id         => l_person_id,
                          p_start_date        => start_date_to_be_used,
                          p_end_date          => end_date_to_be_used,
                          x_resource_capacity => l_resource_capacity,
                          x_return_status     => l_return_status,
                          x_msg_count         => l_msg_count,
                          x_msg_data          => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

--get the period_balance
            begin
                  select  bal.period_balance
                    into  l_period_balance
                    from  pa_objects       obj,
                          pa_summ_balances bal
                  where   obj.object_id = bal.object_id
  	          and     bal.version_id = -1
  	          and     bal.object_type_code = PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RES_C
	          and     bal.period_type = l_gl_period_type
--  	          and     bal.period_set_name = l_period_set_name
  	          and     bal.period_set_name = l_gl_period_set_name  -- bug 3434019
  	          and     bal.period_name = gl_periods_cur_rec.PERIOD_NAME
  	          and     bal.global_exp_period_end_date = PA_REP_UTIL_GLOB.G_DUMMY_DATE_C
  	          and     bal.amount_type_id = PA_REP_UTIL_GLOB.G_amt_type_details.G_res_cap_id
  	          and     obj.object_type_code = PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RES_C
  	          and     obj.balance_type_code = l_balance_type_code
 	          and     obj.project_org_id = -1
  	          and     obj.project_organization_id = -1
  	          and     obj.project_id = -1
  	          and     obj.task_id = -1
  	          and     obj.expenditure_org_id = l_OU_id
  	          and     obj.expenditure_organization_id = l_exp_orgz_id
  	          and     obj.person_id = l_person_id
  	          and     obj.assignment_id = -1
  	          and     obj.work_type_id = -1
  	          and     obj.org_util_category_id = -1
  	          and     obj.res_util_category_id = -1
  	             for update of bal.object_id;
            exception
                when no_data_found
                then
                     l_period_balance := 0;
            end;


  	    x_resource_capacity_tab(j) := l_resource_capacity - l_period_balance;
            x_exp_orgz_id_tab(j)       := l_exp_orgz_id;
            x_person_id_tab(j)         := l_person_id;
            x_period_type_tab(j)       := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_GL_C;
            x_period_name_tab(j)       := gl_periods_cur_rec.PERIOD_NAME;
            x_global_exp_date_tab(j)   := PA_REP_UTIL_GLOB.GetDummyDate;
            x_period_year_tab(j)       := gl_periods_cur_rec.PERIOD_YEAR;
            x_qm_number_tab(j)         := gl_periods_cur_rec.PERIOD_QUARTER;
            x_period_num_tab(j)        := gl_periods_cur_rec.PERIOD_NUM;

            j := j+1;
            jj := j;

      	END IF;  -- PA_FORECAST_GRC_PVT.get_resource_capacity returns success

        END IF;  -- PA_FORECAST_GRC_PVT.checking date effectivity

       END LOOP;   -- GL_PERIODS_CUR loop

 	END IF;  -- l_gl_period_flag = 'Y

   j := jj;


-- IF and loop for GE
   IF l_ge_period_flag = 'Y' then
        FOR ge_periods_cur_rec in GE_PERIODS_CUR LOOP
            l_return_status     := FND_API.G_RET_STS_SUCCESS;
               IF (
                    ( p_in_res_eff_s_date_tab(i) >= ge_periods_cur_rec.PERIOD_START_DATE
                    and p_in_res_eff_s_date_tab(i) <= ge_periods_cur_rec.GE_DATE )
                  OR
                    ( p_in_res_eff_e_date_tab(i) >= ge_periods_cur_rec.PERIOD_START_DATE
                    and p_in_res_eff_e_date_tab(i) <= ge_periods_cur_rec.GE_DATE )
                  OR
                    ( ge_periods_cur_rec.PERIOD_START_DATE >= p_in_res_eff_s_date_tab(i)
                    and ge_periods_cur_rec.PERIOD_START_DATE <= p_in_res_eff_e_date_tab(i) )
                  ) THEN


            start_date_to_be_used := GREATEST(ge_periods_cur_rec.PERIOD_START_DATE
                                              , p_in_res_eff_s_date_tab(i)
                                              , p_run_start_date);
            end_date_to_be_used   := LEAST(ge_periods_cur_rec.GE_DATE
                                           , p_in_res_eff_e_date_tab(i)
                                           , p_run_end_date);

 PA_FORECAST_GRC_PVT.get_resource_capacity(
                          p_org_id            => l_exp_orgz_id,
                          p_person_id         => l_person_id,
                          p_start_date        => start_date_to_be_used,
                          p_end_date          => end_date_to_be_used,
                          x_resource_capacity => l_resource_capacity,
                          x_return_status     => l_return_status,
                          x_msg_count         => l_msg_count,
                          x_msg_data          => l_msg_data);

            IF l_return_status = FND_API.G_RET_STS_SUCCESS THEN

--get the period_balance
            begin
                  select  bal.period_balance
                    into  l_period_balance
                    from  pa_objects       obj,
                          pa_summ_balances bal
                  where   obj.object_id = bal.object_id
  	          and     bal.version_id = -1
  	          and     bal.object_type_code = PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RES_C
  	          and     bal.period_type = 'GE'
--  	          and     bal.period_set_name = l_period_set_name
	          and     bal.period_set_name = PA_REP_UTIL_GLOB.G_DUMMY_C    --bug 3434019
  	          and     bal.period_name = PA_REP_UTIL_GLOB.G_DUMMY_C
  	          and     bal.global_exp_period_end_date = PA_REP_UTIL_GLOB.G_DUMMY_DATE_C
  	          and     bal.amount_type_id = PA_REP_UTIL_GLOB.G_amt_type_details.G_res_cap_id
  	          and     obj.object_type_code = PA_REP_UTIL_GLOB.G_OBJ_TYPE_C.G_RES_C
  	          and     obj.balance_type_code = l_balance_type_code
 	          and     obj.project_org_id = -1
  	          and     obj.project_organization_id = -1
  	          and     obj.project_id = -1
  	          and     obj.task_id = -1
  	          and     obj.expenditure_org_id = l_OU_id
  	          and     obj.expenditure_organization_id = l_exp_orgz_id
  	          and     obj.person_id = l_person_id
  	          and     obj.assignment_id = -1
  	          and     obj.work_type_id = -1
  	          and     obj.org_util_category_id = -1
  	          and     obj.res_util_category_id = -1
  	             for update of bal.object_id;
            exception
                when no_data_found
                then
                     l_period_balance := 0;
            end;


  	    x_resource_capacity_tab(j) := l_resource_capacity - l_period_balance;
            x_exp_orgz_id_tab(j)       := l_exp_orgz_id;
            x_person_id_tab(j)         := l_person_id;
            x_period_type_tab(j)       := PA_REP_UTIL_GLOB.G_PERIOD_TYPE_C.G_GE_C;
            x_period_name_tab(j)       := PA_REP_UTIL_GLOB.G_DUMMY_C;
            x_global_exp_date_tab(j)   := ge_periods_cur_rec.GE_DATE;
            x_period_year_tab(j)       := ge_periods_cur_rec.PERIOD_YEAR;
            x_qm_number_tab(j)         := ge_periods_cur_rec.PERIOD_MONTH;
            x_period_num_tab(j)        := -1;

            j := j+1;
            jj := j;

      	END IF;  -- PA_FORECAST_GRC_PVT.get_resource_capacity returns success

        END IF;  -- PA_FORECAST_GRC_PVT.checking date effectivity

       END LOOP;   -- GE_PERIODS_CUR loop

 	END IF;  -- l_ge_period_flag = 'Y'

   j := jj;

END LOOP;  -- looping through the PL/SQL tables  p_exp_org_id_tab and p_person_id_tab

x_return_status := l_return_status;

EXCEPTION
WHEN NO_DATA_FOUND THEN
    Null;
WHEN OTHERS THEN
      -- 4537865 : RESET other OUT params value also
      x_resource_capacity_tab.delete;
      x_exp_orgz_id_tab.delete;
      x_person_id_tab.delete;
      x_period_type_tab.delete;
      x_period_name_tab.delete;
      x_global_exp_date_tab.delete;
      x_period_year_tab.delete;
      x_qm_number_tab.delete;
      x_period_num_tab.delete;
      -- 4537865 : End

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_msg_count     := 1;
    x_msg_data      := SQLERRM;
    FND_MSG_PUB.add_exc_msg( p_pkg_name         => 'PA_FORECAST_GRC_PVT',
                             p_procedure_name   => 'Get_Capacity_Vector');
    RAISE ; -- 4537865 : Based on usage included RAISE
END Get_Capacity_Vector;

END PA_FORECAST_GRC_PVT;

/
