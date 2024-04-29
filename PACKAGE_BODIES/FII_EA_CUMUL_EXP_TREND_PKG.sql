--------------------------------------------------------
--  DDL for Package Body FII_EA_CUMUL_EXP_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_EA_CUMUL_EXP_TREND_PKG" AS
/* $Header: FIIEACETB.pls 120.3 2006/05/25 10:15:23 hpoddar noship $ */

    PROCEDURE get_cumul_exp_trend

    ( p_page_parameter_tbl         IN  BIS_PMV_PAGE_PARAMETER_TBL
     ,p_cumulative_expense_sql     OUT NOCOPY VARCHAR2
     ,p_cumulative_expense_output  OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
    ) IS


/* 	Local/Bind Variables used in the code

	CURR_PERIOD_START 	= bind variable for start date of current period
	CURR_PERIOD_END  	= bind variable for end date of current period
	PRIOR_PERIOD_START 	= bind variable for start date of prior period
	PRIOR_PERIOD_END 	= bind variable for end date of prior period
	CURR_MONTH_START 	= bind variable for start date of the current month for the period type Year

	l_budget_time_id 	= Local variable to hold the column name (used while calculating budget),
				  chosen from either of these tables: fii_time_ent_period , fii_time_ent_qtr
				  or fii_time_ent_year

	l_budget_table_name 	= Local variable to hold the table name to be used for Budget calcualtions
	l_budget_time_unit	= Local variable to check the level at which budget is uploaded

	l_forecast_time_id 	= Local variable to hold the column name (used while calculating forecast),
				  chosen from either of these tables:  fii_time_ent_period , fii_time_ent_qtr
				  or fii_time_ent_year

	l_forecast_table_name 	= Local variable to hold the table name to be used for Forecast calcualtions.
	l_forecast_time_unit	= Local variable to check the level at which forecast is uploaded
	l_display_adjustment	= Local variable to hold string that will calculate value so as to decide the number of days for which
				  data is to be shown as NULL

	l_current_adjustment_days = '1' if period type is month;
				  = Difference between :CURR_PERIOD_START and :CURR_PERIOD_END for period type = Quarter

	l_prior_adjustment_days   = '1' if period type is month;
				  = Difference between :PRIOR_PERIOD_START and :PRIOR_PERIOD_END for period type = Quarter

	l_current_adjustment_days and l_prior_adjustment_days variables are used to calculate the display label for period type quarter
				(-89 to 0, assuming that there are 90 rows displayed)
	l_company_security	= Local variable that holds all the possible company-ids for which user has access
	l_cost_center_security  = Local variable that holds all the possible cost-center-ids for which user has access

*/

-- Local variables declaration

-- Variables used to find the level at which Budget/Forecast is loaded

	l_budget_time_unit   	VARCHAR2(1);
	l_forecast_time_unit 	VARCHAR2(1);
	l_display_adjustment    VARCHAR2(1000);

-- Variables to hold different dynamic SQL statements

-- Variable to hold SQL statement involving Budget calculations, for Period Type = Year

	l_sql_budget_ver_year		VARCHAR2(5000) := NULL;

-- Variable to hold SQL statement involving Forecast calculations, for Period Type = Year

	l_sql_forecast_ver_year		VARCHAR2(5000) := NULL;

-- Variable to hold SQL statement involving Budget calculations, for Period Type = Month/Qtr

	l_sql_budget_ver_month_qtr	VARCHAR2(5000) := NULL;

-- Variable to hold SQL statement involving Forecast calculations, for Period Type = Month/Qtr

	l_sql_forecast_ver_month_qtr	VARCHAR2(5000) := NULL;

-- This will hold the actual SQL statement which will be passed to PMV via bind_variable procedure

       l_actual_sql_statement		VARCHAR2(10000) := NULL;

-- This will hold SQL statement for Budget/Forecast profile option = Y,
-- Period Type = Year, Compare To = Prior Year/Prior Period/Budget/Forecast

       l_sql_statement1			VARCHAR2(10000)  := NULL;


-- This will hold SQL statement for Budget/Forecast profile option = Y,
-- Period Type = Month/Quarter, Compare To = Prior Year/Prior Period/Budget/Forecast

       l_sql_statement2            	VARCHAR2(10000)  := NULL;

-- This will hold SQL statement for Budget/Forecast profile option = N,
-- Period Type = Year, Compare To = Prior Year/Prior Period/Budget/Forecast

       l_sql_statement3            	VARCHAR2(10000)  := NULL;

-- This will hold SQL statement for Budget/Forecast profile option = N,
-- Period Type = Month/Quarter, Compare To = Prior Year/Prior Period/Budget/Forecast

       l_sql_statement4            	VARCHAR2(10000)  := NULL;

-- Flag used to check the profile option FII_FB_STEP, if set to 'Y' or 'N'

       l_budget_forecast_profile  	VARCHAR2(1);

-- Budget/Forecast related variables
       l_budget_time_id  		VARCHAR2(30);
       l_forecast_time_id  		VARCHAR2(30);
       l_budget_table_name 		VARCHAR2(30);
       l_forecast_table_name 		VARCHAR2(30);

-- Variables related to Period Type  = Month/Quarter

       l_current_adjustment_days  	VARCHAR2(200);
       l_prior_adjustment_days   	VARCHAR2(200);

-- Variables used in implementing Company-CC security feature
       l_company_security		VARCHAR2(4000);
       l_cost_center_security		VARCHAR2(4000);
       l_comp_security_table            VARCHAR2(300);
       l_cc_security_table              VARCHAR2(300);
       l_comp_security_days_clause      VARCHAR2(4000);
       l_cc_security_days_clause        VARCHAR2(4000);

   BEGIN

-- Procedure reset_globals to re-set the global variables to NULL.
-- It will set financial category type to 'OE', company parameter to 'All' and cost parameter to 'All'
-- financial category type is set to 'OE' since Cumulative Expense Trend is an expense related report

        fii_ea_util_pkg.reset_globals;

-- Assigning budget/forecast profile value to local variables

	l_budget_time_unit    := NVL(FND_PROFILE.Value( 'FII_BUDGET_TIME_UNIT' ),'P');
	l_forecast_time_unit  := NVL(FND_PROFILE.Value( 'FII_FORECAST_TIME_UNIT' ),'P');

-- Variables related to Period Type = Quarter
-- Default value will be 1 for Period Type = Month

       l_current_adjustment_days  :=  ':CURR_PERIOD_START + 1 ' ;
       l_prior_adjustment_days    :=  ':PRIOR_PERIOD_START + 1 ' ;

-- Procedure get_parameters to assign values to different global variables
-- like as of date, period type, comparison type - being given by the user

	fii_ea_util_pkg.get_parameters(p_page_parameter_tbl);

-- Following exercise is done to get the required label in the report table columns
-- For example : For Period Type = Month/Quarter, ViewBy Label should be Day
--		 For Period Type = Year, ViewBy Label should be Month

	IF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
		fii_ea_util_pkg.g_view_by := 'TIME+FII_TIME_ENT_PERIOD';
	ELSE
		fii_ea_util_pkg.g_view_by := 'TIME+FII_TIME_DAY';
	END IF;

--	Typical values of l_budget_time_unit/l_forecast_time_unit are:
--	P -- Period level
--	Q -- Quarter level
--	Y -- Year level

-- Initialisation of local variables for Budget calculations, which are used in the actual SQLs

	CASE fii_ea_util_pkg.g_page_period_type
	   WHEN 'FII_TIME_ENT_YEAR' THEN
		l_budget_time_id := 'g.ent_year_id';
		l_budget_table_name := 'fii_time_ent_year';
	   WHEN 'FII_TIME_ENT_QTR' THEN
		IF l_budget_time_unit = 'P' OR l_budget_time_unit = 'Q' THEN
		   l_budget_time_id := 'g.ent_qtr_id';
		   l_budget_table_name := 'fii_time_ent_qtr';
		ELSE
		   NULL;
		END IF;
	   WHEN 'FII_TIME_ENT_PERIOD' THEN
	       IF l_budget_time_unit = 'P' THEN
		  l_budget_time_id := 'g.ent_period_id' ;
	  	  l_budget_table_name := 'fii_time_ent_period';
	       ELSE
	          NULL;
	       END IF;
	   ELSE
	      NULL;
	END CASE;

-- Initialisation of local variables for Forecast calculations, which are used in the actual SQLs

	CASE fii_ea_util_pkg.g_page_period_type
	   WHEN 'FII_TIME_ENT_YEAR' THEN
		l_forecast_time_id := 'g.ent_year_id';
		l_forecast_table_name := 'fii_time_ent_year';
	   WHEN 'FII_TIME_ENT_QTR' THEN
		IF l_forecast_time_unit = 'P' OR l_forecast_time_unit = 'Q' THEN
		   l_forecast_time_id := 'g.ent_qtr_id';
		   l_forecast_table_name := 'fii_time_ent_qtr';
		ELSE
		   NULL;
		END IF;
	   WHEN 'FII_TIME_ENT_PERIOD' THEN
	       IF l_forecast_time_unit = 'P' THEN
		  l_forecast_time_id := 'g.ent_period_id' ;
	  	  l_forecast_table_name := 'fii_time_ent_period';
	       ELSE
	          NULL;
	       END IF;
	   ELSE
	      NULL;
	END CASE;


-- Following exercise is done to implement Company-CC security feature, required in the Expense Analysis page.
-- Variables, l_company_security and l_cost_center_security will hold the requisite SQL's string required for
-- implementing Company-CC security feature

-- Obtaining all possible company-ids to which user has access

   IF fii_ea_util_pkg.g_company_id = 'All' THEN
        l_company_security :=
                ' AND  f.company_id IN (SELECT company_id
					  FROM fii_company_grants
					 WHERE user_id		  = fnd_global.user_id
					   AND report_region_code = '''||fii_ea_util_pkg.g_region_code||'''
					) ';
	l_comp_security_table := ',fii_company_grants     com ';

	l_comp_security_days_clause := 'AND f.company_id = com.company_id
			                AND com.user_id    = fnd_global.user_id
			                AND com.report_region_code = '''||fii_ea_util_pkg.g_region_code||''' ';
   ELSE
        l_company_security := ' AND f.company_id = :COMPANY_ID ' ;
	l_comp_security_days_clause := ' AND f.company_id = :COMPANY_ID ' ;
   END IF;

-- Obtaining all possible cost-center-ids to which user has access

   IF fii_ea_util_pkg.g_cost_center_id = 'All' THEN
         l_cost_center_security :=
                ' AND f.cost_center_id IN (SELECT cost_center_id
                                             FROM fii_cost_center_grants
                                            WHERE user_id = fnd_global.user_id
                                              AND report_region_code = '''||fii_ea_util_pkg.g_region_code||''' ) ';

	 l_cc_security_table := ' ,fii_cost_center_grants	cc ';

	 l_cc_security_days_clause := ' AND f.cost_center_id = cc.cost_center_id
			                AND cc.user_id = fnd_global.user_id
			                AND cc.report_region_code = '''||fii_ea_util_pkg.g_region_code||''' ';
   ELSE
         l_cost_center_security := ' AND f.cost_center_id = :COST_CENTER_ID ';
	 l_cc_security_days_clause := ' AND f.cost_center_id = :COST_CENTER_ID ';

   END IF;


-- Following exercise is done for two reasons and is applicable only for Period = Month/Quarter:
-- Reason 1:	Getting the values for l_current_adjustment_days and l_prior_adjustment_days.
--		For period type = Month, these variables will store value = 1
--		For period type = Year, these variables will not be used
--		For period type = Quarter,it will hold the number of days in the quarter, as per the following calculation

-- Reason 2:   To show NULL for all the days which fall after As of Date chosen by the user
--		Variable, l_display_adjustment obtained here will be used in the main SQL to restrict data display
--		only till As of Date and to show NULL thereafter

	IF fii_ea_util_pkg.g_page_period_type <> 'FII_TIME_ENT_YEAR' THEN

--	Following is done for reason 2 above

		IF fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_PERIOD' THEN
		     l_display_adjustment
				:= 'EXTRACT(DAY FROM :ASOF_DATE)';

		ELSE
		     l_display_adjustment
				:= ':ASOF_DATE - :CURR_PERIOD_END';
--	Done for reason 1 above
	    	     l_current_adjustment_days :=
				':CURR_PERIOD_END';

		     l_prior_adjustment_days :=
				':PRIOR_PERIOD_END';

		END IF;
	END IF;

-- Getting the profile option for budget/forecast.
-- For profile option = 'Y',Cumulative Budget/Forecast will be shown.
-- However, for profile option = 'N', Versioning will be taken care of, without any cumulation

	l_budget_forecast_profile   := NVL(FND_PROFILE.Value( 'FII_FB_STEP'),'N');

/* Program Flow will be as follows:

-- Compare To = Budget/Forecast implies that the third column in the report table (Prior Period)
-- will show cumulated expenses to date of prior year.
-- For example,If the report parameters are: Compare To = Budget/Forecast, Period Type = Quarter
-- and As of Date = Nov 29,2004, then this column will show cumulated expenses for Q3-03,
-- i.e. the period will range from 01-Oct-2003 to 31-Dec-2003

-- When Period Type = Year, then report will show cumulated monthly expenses where as
-- For Period Type = Month/Quarter, report will show cumulated expenses on the daily basis
-- i.e. 1 to 30(31) for Period type = Month
-- and -89 to 0 for Period Type = Quarter (assuming that the quarter is of 90 days)

*/

-- Defining Budget/Forecast SQL's when Budget/Forecast profile option = 'N' and Period Type = Year

    IF (l_budget_forecast_profile = 'N') THEN
	IF  fii_ea_util_pkg.g_page_period_type = 'FII_TIME_ENT_YEAR' THEN
		l_sql_budget_ver_year :=

		     '( SELECT SUM(f.budget_g)		     FII_EA_BUDGET
			  FROM '||l_budget_table_name||'     g	-- Profile option = N, Period Type = Year
			       ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			 WHERE f.time_id		= '||l_budget_time_id||'
			    '||l_company_security||l_cost_center_security||'
	                   AND top_node_fin_cat_type = ''OE''
			   AND NVL(f.budget_version_date,&BIS_CURRENT_ASOF_DATE)  <= &BIS_CURRENT_ASOF_DATE
			   AND :ASOF_DATE BETWEEN g.start_date AND g.end_date
			   AND NVL(f.budget_version_date,time.end_date) <= time.end_date

-- To choose only those versions having version dates less than or equal to report date
-- Here, time is alias of the timeRelated table used in the actual SQL,
-- wherein, these Budget/Forecast SQL strings are actually concatenated
		      )';

		   l_sql_forecast_ver_year :=

		    '( SELECT SUM( f.forecast_g)		FII_EA_FORECAST
			  FROM '||l_forecast_table_name||'	g  -- Profile option = N, Period Type = Year
			       ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			 WHERE f.time_id	= '||l_forecast_time_id||'
			   '||l_company_security||l_cost_center_security||'
			   AND top_node_fin_cat_type = ''OE''
			   AND NVL(f.budget_version_date,&BIS_CURRENT_ASOF_DATE)  <= &BIS_CURRENT_ASOF_DATE
			   AND :ASOF_DATE BETWEEN g.start_date AND g.end_date
			   AND NVL(f.budget_version_date,time.end_date)	 <=  time.end_date

-- To choose only those versions having version dates less than or equal to report date
-- Here, time is alias of the timeRelated table used in the actual SQL,
-- wherein, these Budget/Forecast SQL strings are actually concatenated
		      )';

	ELSE -- Means that Period Type = Month/Quarter

		   IF l_budget_table_name IS NOT NULL THEN	-- Check is required to ensure that Budget calculation is not done
								-- for those cases where-in Period Type chosen is at a more granular level
								-- than that of Budget uploaded level

			l_sql_budget_ver_month_qtr  	:=

			'( SELECT SUM(f.budget_g)            FII_EA_BUDGET
			     FROM '||l_budget_table_name||'  g	-- Profile option = N, Period Type = Month/Quarter
				  ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'		f
			    WHERE f.time_id	   = '||l_budget_time_id||'
			      '||l_company_security||l_cost_center_security||'
			      AND top_node_fin_cat_type = ''OE''
			      AND NVL(f.budget_version_date,&BIS_CURRENT_ASOF_DATE)  <= &BIS_CURRENT_ASOF_DATE
			      AND :ASOF_DATE BETWEEN g.start_date AND g.end_date
			      AND NVL(f.budget_version_date,time.report_date)  <= time.report_date

-- To choose only those versions having version dates less than or equal to report date
-- Here, time is alias of the timeRelated table used in the actual SQL,
-- wherein, these Budget/Forecast SQL strings are actually concatenated

		      )';
		    ELSE
			l_sql_budget_ver_month_qtr := 'NULL';  -- To pass NULL budget value to PMV
	            END IF;

	            IF l_forecast_table_name IS NOT NULL THEN	-- Check is required to ensure that Forecast calculation is not done
								-- for those cases where-in Period Type chosen is at a more granular level
								-- than that of Forecast uploaded level
			l_sql_forecast_ver_month_qtr  	:=

			'( SELECT SUM(f.forecast_g) 		FII_EA_FORECAST
			     FROM '||l_forecast_table_name||' 	g  -- Profile option = N, Period Type = Month/Quarter
				  ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'		f
			    WHERE f.time_id	   = '||l_forecast_time_id||'
			      '||l_company_security||l_cost_center_security||'
			      AND top_node_fin_cat_type = ''OE''
			      AND NVL(f.budget_version_date,&BIS_CURRENT_ASOF_DATE)  <= &BIS_CURRENT_ASOF_DATE
			      AND :ASOF_DATE BETWEEN g.start_date AND g.end_date
			      AND NVL(f.budget_version_date,time.report_date) <= time.report_date

-- To choose only those versions having version dates less than or equal to report date
-- Here, time is alias of the timeRelated table used in the actual SQL,
-- wherein, these Budget/Forecast SQL strings are actually concatenated

			 )';
	             ELSE
				l_sql_forecast_ver_month_qtr := 'NULL';  -- To pass NULL forecast value to PMV
		     END IF;
	END IF;
   END IF;

-- SQL statement for Budget/Forecast profile option = Y,
-- Period Type = Year, Compare To = Prior Year/Prior Period/Budget/Forecast
-- Cumulative Budget/Forecast to be shown

       l_sql_statement1     		:=

	'SELECT VIEWBY
	       ,FII_EA_XTD_CUMUL_EXP
	       ,FII_EA_PRIOR_XTD_CUMUL_EXP
	       ,FII_EA_BUDGET
	       ,FII_EA_FORECAST
	   FROM
	       (SELECT month_name				VIEWBY 	--SQL 1
		       ,CASE WHEN FII_EFFECTIVE_NUM > :DISPLAY_SEQUENCE
		             THEN NULL
 	 	        ELSE SUM(FII_EA_XTD_CUMUL_EXP) OVER (ORDER BY FII_EFFECTIVE_NUM
					ROWS UNBOUNDED PRECEDING)
  			END						FII_EA_XTD_CUMUL_EXP
		       ,SUM(FII_EA_PRIOR_XTD_CUMUL_EXP) OVER (ORDER BY FII_EFFECTIVE_NUM
					ROWS UNBOUNDED PRECEDING)	FII_EA_PRIOR_XTD_CUMUL_EXP
		  FROM  ( SELECT  MAX(month_name)			month_name
			 	 ,FII_EFFECTIVE_NUM			FII_EFFECTIVE_NUM
               			 ,SUM(FII_EA_XTD_CUMUL_EXP)		FII_EA_XTD_CUMUL_EXP
                		 ,SUM(FII_EA_PRIOR_XTD_CUMUL_EXP)	FII_EA_PRIOR_XTD_CUMUL_EXP
		            FROM
			    (
 	      -- Following SQL is to calculate the values for prior period
			  SELECT  time.sequence				fii_effective_num
				 ,time.name				month_name
			         ,NULL					FII_EA_XTD_CUMUL_EXP
			         ,NVL(SUM(FII_EA_PRIOR_XTD_CUMUL_EXP),0)FII_EA_PRIOR_XTD_CUMUL_EXP
			    FROM
				(
				   SELECT time.sequence 	    	FII_EFFECTIVE_NUM
		 		  	 ,time.name     	    	month_name
					 ,NULL	 		   	FII_EA_XTD_CUMUL_EXP
			 		 ,f.actual_g			FII_EA_PRIOR_XTD_CUMUL_EXP
			  	    FROM  fii_time_ent_period       				time
                       	       		 ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			           WHERE  f.time_id	   = time.ent_period_id
				        '||l_company_security||l_cost_center_security||' -- To restrict MV records based on
									                 -- Company-CC security access
				     AND  f.period_type_id = 32
				     AND top_node_fin_cat_type = ''OE''
				     AND  time.start_date >= :PRIOR_PERIOD_START
                  	   	     AND  time.end_date   <= :PRIOR_PERIOD_END
				 ) inner_view
				, fii_time_ent_period         time
		           WHERE inner_view.month_name (+)  = time.name	 -- Outer join to ensure that all the months are obtained
			     AND time.start_date	   >= :PRIOR_PERIOD_START
                  	     AND time.end_date		   <= :PRIOR_PERIOD_END
		     GROUP BY time.sequence
			     ,time.name

							UNION ALL

		-- Following SQL is to calculate the values for the current period

			  SELECT  time.sequence				fii_effective_num
				 ,time.name				month_name
			         ,NVL(SUM(FII_EA_XTD_CUMUL_EXP),0)	FII_EA_XTD_CUMUL_EXP
			         ,NULL					FII_EA_PRIOR_XTD_CUMUL_EXP
			    FROM
            	         	( SELECT  time.sequence			FII_EFFECTIVE_NUM
		     	   	         ,time.name 			month_name
			      	         ,f.actual_g			FII_EA_XTD_CUMUL_EXP
			      	         ,NULL				FII_EA_PRIOR_XTD_CUMUL_EXP
			           FROM  fii_time_ent_period  	    				time
		       	       	  	,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			          WHERE  f.time_id	 = time.ent_period_id
         	  	  	    '||l_company_security||l_cost_center_security||'  -- To restrict MV records based on
									              -- Company-CC security access
				    AND  f.period_type_id = 32
				    AND top_node_fin_cat_type = ''OE''
				    AND	 time.start_date >= :CURR_PERIOD_START
        	  		    AND	 time.end_date   <= :CURR_PERIOD_END
                  	        ) inner_view
				, fii_time_ent_period         time
		           WHERE inner_view.month_name (+)  = time.name	 -- Outer join to ensure that all the months are obtained
			     AND time.start_date	   >= :CURR_PERIOD_START
                  	     AND time.end_date		   <= :CURR_PERIOD_END
		        GROUP BY time.sequence
			        ,time.name
			 )
			   GROUP BY FII_EFFECTIVE_NUM
			   ORDER BY FII_EFFECTIVE_NUM
		        )) inner_view1
		, ( SELECT time.name								VIEW_BY
		          ,NVL(SUM(SUM(FII_EA_BUDGET))
				   OVER (ORDER BY time.sequence rows UNBOUNDED PRECEDING),0)	FII_EA_BUDGET
			  ,NVL(SUM(SUM(FII_EA_FORECAST))
				   OVER (ORDER BY time.sequence rows UNBOUNDED PRECEDING),0)	FII_EA_FORECAST
		      FROM
		         (
			   SELECT time.name						month_name
			 	 ,f.budget_g					FII_EA_BUDGET
				 ,f.forecast_g					FII_EA_FORECAST
			     FROM fii_time_ent_period					time
				 ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			    WHERE  f.time_id	    =  time.ent_period_id
				'||l_company_security||l_cost_center_security||' -- To restrict MV records based on
									         -- Company-CC security access
			      AND f.period_type_id = 32
			      AND top_node_fin_cat_type = ''OE''
			      AND time.start_date >= :CURR_PERIOD_START
			      AND time.start_date <= :CURR_PERIOD_END
			  ) inner_view
  		 	  , fii_time_ent_period         time
		    WHERE inner_view.month_name (+)  = time.name  -- Outer join to ensure that all the months are obtained
		      AND time.start_date	   >= :CURR_PERIOD_START
                      AND time.end_date		   <= :CURR_PERIOD_END
		 GROUP BY time.sequence
		         ,time.name
	         ORDER BY time.sequence
		   ) inner_view2
	  WHERE inner_view1.viewby = inner_view2.view_by
	  ';


-- SQL statement for Budget/Forecast profile option = Y,
-- Period Type = Month/Quarter, Compare To = Prior Year/Prior Period/Budget/Forecast
-- Cumulative Budget/Forecast to be shown

       l_sql_statement2            	:=

'SELECT days				VIEWBY
       ,CASE
	   WHEN days > TO_NUMBER('||l_display_adjustment||') THEN NULL
	ELSE
	   FII_EA_XTD_CUMUL_EXP
	END				FII_EA_XTD_CUMUL_EXP
       ,FII_EA_PRIOR_XTD_CUMUL_EXP	FII_EA_PRIOR_XTD_CUMUL_EXP
       ,inner_view2.FII_EA_BUDGET	FII_EA_BUDGET
       ,inner_view2.FII_EA_FORECAST	FII_EA_FORECAST
   FROM
       (
        SELECT 	 days							  --SQL 2
		,SUM (FII_EA_XTD_CUMUL_EXP)				FII_EA_XTD_CUMUL_EXP
		,SUM (FII_EA_PRIOR_XTD_CUMUL_EXP)			FII_EA_PRIOR_XTD_CUMUL_EXP
          FROM   (

	-- SQL to calculate the expenses for current period
		SELECT	time.report_date - '||l_current_adjustment_days||'  	DAYS
		       ,time.report_date					REPORT_DATE
		       ,NVL(SUM(SUM(FII_EA_XTD_CUMUL_EXP)) OVER (ORDER BY
				TO_NUMBER(time.report_date - '||l_current_adjustment_days||')
        					       ROWS UNBOUNDED PRECEDING
                                                   ),0)			FII_EA_XTD_CUMUL_EXP
		       ,NULL 						FII_EA_PRIOR_XTD_CUMUL_EXP
		  FROM
		     (
			SELECT time.report_date 				REPORT_DATE
			      ,f.actual_g					FII_EA_XTD_CUMUL_EXP
			      ,NULL						FII_EA_PRIOR_XTD_CUMUL_EXP
			  FROM fii_time_day		       				time
			      ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			       '||l_comp_security_table||'
			       '||l_cc_security_table||'
 			 WHERE f.time_id    = time.report_date_julian
			       '||l_comp_security_days_clause||'
			       '||l_cc_security_days_clause||'		 -- To restrict MV records based on
								         -- Company-CC security access
   			   AND top_node_fin_cat_type = ''OE''
                           AND time.report_date BETWEEN :CURR_PERIOD_START AND :CURR_PERIOD_END
		     ) inner_view
		     , fii_time_day 	       			time
		 WHERE inner_view.report_date (+)  	  =	time.report_date -- Outer join to ensure that all the days are obtained
                   AND time.report_date BETWEEN :CURR_PERIOD_START AND :CURR_PERIOD_END
	      GROUP BY time.report_date - '||l_current_adjustment_days||'
		      ,time.report_date

 		UNION ALL

	-- SQL to calculate the expenses for prior period
		SELECT	time.report_date - '||l_prior_adjustment_days||'    	DAYS
		       ,time.report_date					REPORT_DATE
		       ,NULL 							FII_EA_XTD_CUMUL_EXP
		       ,NVL(SUM(SUM(FII_EA_PRIOR_XTD_CUMUL_EXP)) OVER (ORDER BY
				TO_NUMBER(time.report_date - '||l_prior_adjustment_days||')
        					       ROWS UNBOUNDED PRECEDING
                                                   ),0)				FII_EA_PRIOR_XTD_CUMUL_EXP
		  FROM
  		     ( SELECT time.report_date					REPORT_DATE
			     ,NULL						FII_EA_XTD_CUMUL_EXP
                             ,f.actual_g					FII_EA_PRIOR_XTD_CUMUL_EXP
		         FROM fii_time_day 						time
			     ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			     '||l_comp_security_table||'
			     '||l_cc_security_table||'
			WHERE f.time_id    = time.report_date_julian
			     '||l_comp_security_days_clause||'
			     '||l_cc_security_days_clause||'	       -- To restrict MV records based on
								       -- Company-CC security access
			  AND top_node_fin_cat_type = ''OE''
                          AND time.report_date BETWEEN :PRIOR_PERIOD_START AND :PRIOR_PERIOD_END
		     ) inner_view
		     , fii_time_day 	       			time
		 WHERE inner_view.report_date (+)  	  =	time.report_date  -- Outer join to ensure that all the days are obtained
                   AND time.report_date BETWEEN :PRIOR_PERIOD_START AND :PRIOR_PERIOD_END
	      GROUP BY time.report_date - '||l_prior_adjustment_days||'
		      ,time.report_date
	      )
	GROUP BY days
	  )	inner_view1
	 ,(SELECT  ROUND(SUM(SUM(f.budget_g
				/(TO_NUMBER(time.ent_period_end_date - time.ent_period_start_date) + 1)))
			OVER (ORDER BY g.sequence ))	-- Done to show Budget at monthly level
								FII_EA_BUDGET
		  ,ROUND(SUM(SUM(f.forecast_g
				/(TO_NUMBER(time.ent_period_end_date - time.ent_period_start_date) + 1)))
			OVER (ORDER BY g.sequence ))	-- Done to show Forecast at monthly level
								FII_EA_FORECAST
		  ,g.sequence
		  ,time.report_date - '||l_current_adjustment_days||'
								DAYS2
	     FROM fii_time_ent_period					g
	         ,fii_time_day						time
		 ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
		 '||l_comp_security_table||'
		 '||l_cc_security_table||'
	   WHERE f.time_id    = g.ent_period_id
	     AND f.period_type_id = 32
	     AND top_node_fin_cat_type = ''OE''
	        '||l_comp_security_days_clause||'
		'||l_cc_security_days_clause||'		  -- To restrict MV records based on
	  						  -- Company-CC security access
	     AND g.ent_period_id    = time.ent_period_id
	     AND time.report_date BETWEEN :CURR_PERIOD_START AND :CURR_PERIOD_END
	GROUP BY g.sequence
		,time.report_date - '||l_current_adjustment_days||'
	) inner_view2
    WHERE inner_view2.days2 (+) = inner_view1.days  -- Outer join to ensure that all the days are obtained
 ORDER BY viewby

	';

-- SQL statement for Budget/Forecast profile option = N,
-- Period Type = Year, Compare To = Prior Year/Prior Period/Budget/Forecast
-- Budget Versioning feature implemented


       l_sql_statement3		:=

	     'SELECT month_name				VIEWBY  --SQL 3
		      ,CASE WHEN FII_EFFECTIVE_NUM > :DISPLAY_SEQUENCE
			  THEN NULL
 	 	       ELSE SUM(FII_EA_XTD_CUMUL_EXP) OVER (ORDER BY FII_EFFECTIVE_NUM
					ROWS UNBOUNDED PRECEDING)
  			END						FII_EA_XTD_CUMUL_EXP
		      ,SUM(FII_EA_PRIOR_XTD_CUMUL_EXP) OVER (ORDER BY FII_EFFECTIVE_NUM
					ROWS UNBOUNDED PRECEDING)	FII_EA_PRIOR_XTD_CUMUL_EXP
		      ,FII_EA_BUDGET					FII_EA_BUDGET
  		      ,FII_EA_FORECAST					FII_EA_FORECAST
		FROM  ( SELECT    MAX(month_name)			month_name
			         ,FII_EFFECTIVE_NUM			FII_EFFECTIVE_NUM
               		         ,NVL(SUM(FII_EA_XTD_CUMUL_EXP),0)	FII_EA_XTD_CUMUL_EXP
                		 ,NVL(SUM(FII_EA_PRIOR_XTD_CUMUL_EXP),0)FII_EA_PRIOR_XTD_CUMUL_EXP
				 ,SUM(FII_EA_BUDGET)			FII_EA_BUDGET
				 ,SUM(FII_EA_FORECAST)			FII_EA_FORECAST
                            FROM
			    (
 	             		-- Following SQL is to calculate the values for prior period

		       SELECT  time.sequence				fii_effective_num
			      ,time.name				month_name
			      ,NULL					FII_EA_XTD_CUMUL_EXP
			      ,SUM(FII_EA_PRIOR_XTD_CUMUL_EXP)		FII_EA_PRIOR_XTD_CUMUL_EXP
			      ,NULL					FII_EA_BUDGET
			      ,NULL					FII_EA_FORECAST
			 FROM
			     (SELECT  time.sequence	    		fii_effective_num
		 		     ,time.name    	    		month_name
				     ,NULL	 	   		FII_EA_XTD_CUMUL_EXP
			 	     ,f.actual_g			FII_EA_PRIOR_XTD_CUMUL_EXP
				     ,NULL				FII_EA_BUDGET
				     ,NULL				FII_EA_FORECAST
 			  	FROM  fii_time_ent_period       				time
                       	       	     ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			       WHERE  f.time_id	   = time.ent_period_id
				     '||l_company_security||l_cost_center_security||'  -- To restrict MV records based on
									               -- Company-CC security access
				 AND  f.period_type_id = 32
				 AND top_node_fin_cat_type = ''OE''
				 AND  time.start_date >= :PRIOR_PERIOD_START
                  	   	 AND  time.end_date   <= :PRIOR_PERIOD_END
			      ) inner_view
			     ,fii_time_ent_period       				time
			WHERE inner_view.month_name (+)	= time.name	-- Outer join to ensure that all the months are obtained
			  AND time.start_date	       >= :PRIOR_PERIOD_START
                  	  AND time.end_date	       <= :PRIOR_PERIOD_END
		     GROUP BY time.sequence
			     ,time.name

					UNION ALL

			-- Following SQL is to calculate the values for the current period

            	         	( SELECT  time.sequence			fii_effective_num
		     	   	         ,time.name 			month_name
			      	         ,SUM(f.actual_g)		FII_EA_XTD_CUMUL_EXP
			      	         ,NULL				FII_EA_PRIOR_XTD_CUMUL_EXP
					 ,NULL				FII_EA_BUDGET
					 ,NULL				FII_EA_FORECAST
 			           FROM  fii_time_ent_period  	    				time
		       	       	  	,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
			          WHERE  f.time_id 	  = time.ent_period_id
				      '||l_company_security||l_cost_center_security||' -- To restrict MV records based on
									               -- Company-CC security access
				    AND  f.period_type_id = 32
				    AND top_node_fin_cat_type = ''OE''
				    AND	 time.start_date >= :CURR_PERIOD_START
        	  		    AND	 time.end_date   <= :CURR_PERIOD_END
                  	       GROUP BY  time.sequence
					,time.name
		     	        )
				UNION ALL
	-- SQL to calculate budget/forecast for the whole year irrespective of As of Date chosen by the user

				  SELECT  time.sequence			FII_EFFECTIVE_NUM
		   			 ,time.name 			month_name
					 ,NULL				FII_EA_XTD_CUMUL_EXP
 					 ,NULL  			FII_EA_PRIOR_XTD_CUMUL_EXP
					 ,'||l_sql_budget_ver_year||'	FII_EA_BUDGET
                     			 ,'||l_sql_forecast_ver_year||'	FII_EA_FORECAST
 		 	            FROM  fii_time_ent_period		time
  		       	           WHERE  time.start_date >= :CURR_PERIOD_START
                  		     AND  time.end_date   <= :CURR_PERIOD_END
		       	    )
			   GROUP BY FII_EFFECTIVE_NUM
			   ORDER BY FII_EFFECTIVE_NUM
		        )';



-- SQL statement for Budget/Forecast profile option = N,
-- Period Type = Month/Quarter, Compare To = Prior Year/Prior Period/Budget/Forecast
-- Budget Versioning feature implemented


       l_sql_statement4            	:=

'SELECT days				VIEWBY
       ,CASE
	   WHEN days > TO_NUMBER('||l_display_adjustment||') THEN NULL
	ELSE
	   FII_EA_XTD_CUMUL_EXP
	END				FII_EA_XTD_CUMUL_EXP
       ,FII_EA_PRIOR_XTD_CUMUL_EXP
       ,FII_EA_BUDGET
       ,FII_EA_FORECAST
   FROM
       (SELECT 	 days						--SQL 4
		,SUM(FII_EA_XTD_CUMUL_EXP)				FII_EA_XTD_CUMUL_EXP
		,SUM(FII_EA_PRIOR_XTD_CUMUL_EXP)			FII_EA_PRIOR_XTD_CUMUL_EXP
		,SUM(FII_EA_BUDGET)					FII_EA_BUDGET
 	        ,SUM(FII_EA_FORECAST)  					FII_EA_FORECAST
       FROM   (

	-- SQL to calculate the expenses for current period
       SELECT time.report_date - '||l_current_adjustment_days||'	DAYS
             ,time.report_date						REPORT_DATE
	     ,NVL(SUM(SUM(FII_EA_XTD_CUMUL_EXP)) OVER (ORDER BY
				TO_NUMBER(time.report_date - '||l_current_adjustment_days||')
        					       ROWS UNBOUNDED PRECEDING
                                                  ),0)
			     								FII_EA_XTD_CUMUL_EXP
	     ,NULL									FII_EA_PRIOR_XTD_CUMUL_EXP
	     ,'||l_sql_budget_ver_month_qtr||'						FII_EA_BUDGET
	     ,'||l_sql_forecast_ver_month_qtr||'					FII_EA_FORECAST
	 FROM
	     (
	       SELECT	time.report_date					REPORT_DATE
		       ,f.actual_g						FII_EA_XTD_CUMUL_EXP
		       ,NULL 							FII_EA_PRIOR_XTD_CUMUL_EXP
		       ,NULL							FII_EA_BUDGET
	               ,NULL							FII_EA_FORECAST
		  FROM	fii_time_day 	       					time
                       ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'	f
		       '||l_comp_security_table||'
		       '||l_cc_security_table||'
 		 WHERE	f.time_id    = time.report_date_julian
		       '||l_comp_security_days_clause||'
		       '||l_cc_security_days_clause||'		 -- To restrict MV records based on
							         -- Company-CC security access
   		   AND top_node_fin_cat_type = ''OE''
		   AND  time.report_date BETWEEN :CURR_PERIOD_START AND :CURR_PERIOD_END

	     ) inner_view
             , fii_time_day 	       			time
        WHERE inner_view.report_date (+)  	  =	time.report_date  -- Outer join to ensure that all the days are obtained
          AND time.report_date BETWEEN :CURR_PERIOD_START AND :CURR_PERIOD_END
     GROUP BY time.report_date - '||l_current_adjustment_days||'
             ,time.report_date

 		UNION ALL

				-- SQL to calculate the expenses for prior period
       SELECT time.report_date - '||l_prior_adjustment_days||'			DAYS
             ,time.report_date							REPORT_DATE
	     ,NULL								FII_EA_XTD_CUMUL_EXP
	     ,NVL(SUM(SUM(FII_EA_PRIOR_XTD_CUMUL_EXP)) OVER (ORDER BY
				TO_NUMBER(time.report_date - '||l_prior_adjustment_days||')
        					       ROWS UNBOUNDED PRECEDING
                                                  ),0)
			     								FII_EA_PRIOR_XTD_CUMUL_EXP

	     ,NULL									FII_EA_BUDGET
	     ,NULL									FII_EA_FORECAST
	 FROM
	     (
  		SELECT	time.report_date						REPORT_DATE
		       ,NULL								FII_EA_XTD_CUMUL_EXP
                       ,f.actual_g							FII_EA_PRIOR_XTD_CUMUL_EXP
 		       ,NULL								FII_EA_BUDGET
		       ,NULL								FII_EA_FORECAST
 		  FROM	fii_time_day							time
                       ,fii_gl_trend_sum_mv'||fii_ea_util_pkg.g_curr_view||'		f
		       '||l_comp_security_table||'
		       '||l_cc_security_table||'
		 WHERE	f.time_id    = time.report_date_julian
		       '||l_comp_security_days_clause||'
		       '||l_cc_security_days_clause||'		 -- To restrict MV records based on
							         -- Company-CC security access
		   AND top_node_fin_cat_type = ''OE''
		   AND	time.report_date BETWEEN :PRIOR_PERIOD_START AND :PRIOR_PERIOD_END
	     ) inner_view
              ,fii_time_day 			time
        WHERE inner_view.report_date (+)  =	time.report_date   -- Outer join to ensure that all the days are obtained
          AND time.report_date BETWEEN :PRIOR_PERIOD_START AND :PRIOR_PERIOD_END
     GROUP BY time.report_date - '||l_prior_adjustment_days||'
             ,time.report_date
	      )
  GROUP BY days
	) ORDER BY days';


-- Selecting the appropriate SQL to be passed to PMV, based on the input parameters

		CASE l_budget_forecast_profile

		   WHEN 'Y' THEN
		   	 CASE fii_ea_util_pkg.g_page_period_type

				WHEN 'FII_TIME_ENT_YEAR' THEN
                                    l_actual_sql_statement := l_sql_statement1;

                                ELSE
				    l_actual_sql_statement := l_sql_statement2;
                         END CASE;

		   ELSE
  			CASE fii_ea_util_pkg.g_page_period_type

				WHEN 'FII_TIME_ENT_YEAR' THEN
                                    l_actual_sql_statement := l_sql_statement3;
                                ELSE
				    l_actual_sql_statement := l_sql_statement4;
                        END CASE;
		END CASE;

-- Procedure bind_variable to pass the generated SQL statement and input/output variables to PMV
-- for generating Cumulative Expense Trend Report

        fii_ea_util_pkg.bind_variable(
				       p_sqlstmt 	    => l_actual_sql_statement
            	                      ,p_page_parameter_tbl => p_page_parameter_tbl
                	              ,p_sql_output	    => p_cumulative_expense_sql
                        	      ,p_bind_output_table  => p_cumulative_expense_output
                                     );
    END get_cumul_exp_trend;


END fii_ea_cumul_exp_trend_pkg;

/
