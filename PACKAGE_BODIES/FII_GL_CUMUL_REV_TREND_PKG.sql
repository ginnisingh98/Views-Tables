--------------------------------------------------------
--  DDL for Package Body FII_GL_CUMUL_REV_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_CUMUL_REV_TREND_PKG" AS
/* $Header: FIIGLCGB.pls 120.3 2006/03/15 15:11:42 hpoddar noship $ */

PROCEDURE get_cumul_rev (p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
cumul_rev_sql OUT NOCOPY VARCHAR2,
cumul_rev_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS

  sqlstmt			VARCHAR2(32000);
  sqlstmt2			VARCHAR2(32000);
  sqlstmt3			VARCHAR2(32000);
  l_adjust1			VARCHAR2(100);
  l_adjust2			VARCHAR2(100);
  l_forecast			VARCHAR(32000); -- its the cumulated forecast value for a particular period, for value of profile option FII_FB_STEP equal to 'N'
  l_budget			VARCHAR(32000) := 1; -- similarly, its the cumulated budget value for a particular period
  l_time_id			VARCHAR2(100);
  l_time_id2			VARCHAR2(100);
  l_period_id			VARCHAR2(100);
  l_period_id2			VARCHAR2(100);
  l_table_name			VARCHAR2(100);
  l_budget_time_id		VARCHAR2(100);
  l_budget_period_id		VARCHAR2(100);
  l_budget_table_name		VARCHAR2(100);
  l_if_budget			VARCHAR2(1) := 'N'; -- used to specify that comparison type is budget
  l_if_budget_zero		VARCHAR2(1) := 'N'; -- used to return 0 budget for period type week
  l_cond			VARCHAR2(240); -- it is a part of where clause,
					       -- through which we get the start date for each month present in the quarter or year chosen
  l_budget_forecast_profile     VARCHAR2(1);   -- flag used to indicate the value of profile option FII_FB_STEP
  l_dummy_mgr_id		VARCHAR2(100);

BEGIN

    	fii_gl_util_pkg.reset_globals;
	fii_gl_util_pkg.get_parameters(p_page_parameter_tbl);
	fii_gl_util_pkg.get_bitmasks;
        fii_gl_util_pkg.g_fin_type := 'R'; -- since it is a revenue report, we always put category as 'revenue'
	fii_gl_util_pkg.get_mgr_pmv_sql;
	fii_gl_util_pkg.get_cat_pmv_sql;

	l_budget_forecast_profile   := NVL(FND_PROFILE.Value( 'FII_FB_STEP'),'N');

        IF fii_gl_util_pkg.g_time_comp = 'BUDGET' THEN
		l_if_budget := 'Y';
	END IF;

	CASE fii_gl_util_pkg.g_page_period_type

	WHEN 'FII_TIME_WEEK' THEN l_cond := 'NULL';

	ELSE
		l_cond := '(SELECT start_date FROM fii_time_ent_period WHERE ent_period_id  BETWEEN :CURR_START_PERIOD_ID AND :CURR_END_PERIOD_ID)';
	END CASE;

-- since the sql for getting forecast is generated dynamically, the following CASE statement assigns
-- values to different variables used to store the table-names, time-ids etc for each period.
-- The assignment depends upon the level at which forecast has been loaded.

CASE fii_gl_util_pkg.g_forecast_period_type

WHEN 0			   THEN  	l_time_id := 'g.week_id';
					l_time_id2 := 'g.week_id';
	       	      	 		l_period_id := 0;
					l_period_id2 := 0;
	       		 		l_table_name := 'fii_time_week';
WHEN 256 		   THEN  	l_time_id := 'g.ent_period_id' ;
					l_time_id2 := 'g.ent_period_id';
	       		 		l_period_id := 32;
					l_period_id2:= 32;
	       		 		l_table_name := 'fii_time_ent_period';
WHEN 512 		   THEN  	l_time_id := 'g.ent_qtr_id';
					l_time_id2 := 'g.ent_period_id';
	       		 		l_period_id := 64;
					l_period_id2:= 32;
	       		 		l_table_name := 'fii_time_ent_qtr';
WHEN 128 		   THEN  	l_time_id := 'g.ent_year_id';
					l_time_id2 := 'g.ent_qtr_id';
	       		 		l_period_id := 128;
					l_period_id2:= 64;
	       		 		l_table_name := 'fii_time_ent_year';
END CASE;

/* sqlstmt2 gives us a constant value for forecast column, which is same for all the rows, when the profile option is set to display forecast as a single horizontal line */

sqlstmt2 := '
		(SELECT		SUM(DECODE(f.forecast_g,0,NULL,f.forecast_g))
		 FROM		'||l_table_name||' g
				'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
		 WHERE		f.time_id = '||l_time_id||'
				'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||'
				and to_date(:ASOF_DATE,''DD-MM-YYYY'') between g.start_date and g.end_date
				and f.period_type_id = '||l_period_id||'
		 )';




CASE fii_gl_util_pkg.g_page_period_type

WHEN 'FII_TIME_WEEK'	   THEN		l_adjust1     := '1';
					l_adjust2     := '1';
					l_forecast    := 'NULL';
					l_if_budget_zero := 'Y';
					fii_gl_util_pkg.g_viewby_type := 'TIME+FII_TIME_DAY'; /* Done for bug 3449775 */
WHEN 'FII_TIME_ENT_PERIOD' THEN		l_adjust1     := '1';
					l_adjust2     := '1';
					l_forecast    := sqlstmt2;
					fii_gl_util_pkg.g_viewby_type := 'TIME+FII_TIME_DAY';
WHEN 'FII_TIME_ENT_QTR'    THEN		l_adjust1     := 'to_date(:P_CURR_START,''DD-MM-YYYY'')-to_date(:P_CURR_END,''DD-MM-YYYY'')';
					l_adjust2     := 'to_date(:P_PRIOR_START,''DD-MM-YYYY'')-to_date(:P_PRIOR_END,''DD-MM-YYYY'')';
					l_forecast    := sqlstmt2;
					fii_gl_util_pkg.g_viewby_type := 'TIME+FII_TIME_DAY';
WHEN 'FII_TIME_ENT_YEAR'   THEN		l_adjust1     := NULL;
					l_adjust2     := NULL;
					l_forecast    := sqlstmt2;
					fii_gl_util_pkg.g_viewby_type := 'TIME+FII_TIME_ENT_PERIOD';
END CASE;

-- similar to forecast, since the sql for budget is also generated dynamically,
-- the folowing CASE statement assigns values to different variables used to compute the budget value.
-- The assignment depends upon the level at which budget has been loaded.

CASE fii_gl_util_pkg.g_time_comp

WHEN 'BUDGET' 		   THEN

				CASE fii_gl_util_pkg.g_budget_period_type

		     		WHEN 0	THEN		l_budget_time_id := 'g.week_id';
							l_budget_period_id := 0;
							l_budget_table_name := 'fii_time_week';
		     		WHEN 256	THEN	l_budget_time_id := 'g.ent_period_id' ;
							l_budget_period_id := 32;
							l_budget_table_name := 'fii_time_ent_period';
		     		WHEN 512	THEN	l_budget_time_id := 'g.ent_qtr_id';
							l_budget_period_id := 64;
							l_budget_table_name := 'fii_time_ent_qtr';
		     		WHEN 128	THEN	l_budget_time_id := 'g.ent_year_id';
							l_budget_period_id := 128;
							l_budget_table_name := 'fii_time_ent_year';
		     		END CASE;

/* sqlstmt3 gives us a constant value for budget column, when the comparison type is budget and the profile option is set to display budget as a single horizontal line*/

			sqlstmt3 := '
       					(SELECT		SUM(DECODE(f.budget_g,0,to_number(NULL),f.budget_g))
		 			FROM		'||l_budget_table_name||' g
							'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'
		 			WHERE		f.time_id = '||l_budget_time_id||'
							'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
							to_date(:ASOF_DATE,''DD-MM-YYYY'') between g.start_date and g.end_date and
						 	f.period_type_id = '||l_budget_period_id||'
					)';

	   		       CASE  fii_gl_util_pkg.g_page_period_type

		     	       WHEN  'FII_TIME_ENT_PERIOD' THEN         l_budget := sqlstmt3;
		     	       WHEN  'FII_TIME_ENT_QTR'    THEN 	l_budget := sqlstmt3;
		      	       WHEN  'FII_TIME_ENT_YEAR'   THEN 	l_budget := sqlstmt3;
	                       ELSE  l_budget := 'NULL';

		     END CASE;
ELSE		     NULL;

END CASE;

IF fii_gl_util_pkg.g_mgr_id = -99999 THEN l_dummy_mgr_id := '-99999';
ELSE l_dummy_mgr_id := ' &HRI_PERSON+HRI_PER_USRDR_H';
END IF;

/*-------------------------------------------------
   FII_PRIOR_TD_G = Graph column for FII_PRIOR_TD |
   FII_CURRENT_TD = Curent Period Revenue         |
   FII_PRIOR_TD   = Prior Period Revenue          |
   FII_FORECAST   = Forecast                      |
 ------------------------------------------------*/


/*
For period types week, month and quarter, when profile option is set to display budget as a single horizontal line, then, first inner sql gives current period revenue, next inner sql gives the prior period revenue or budget
else, if forecast and budget are to be displayed in the cumulative format, then, first inner sql gives current period revenue, next inner sql gives the prior period revenue or budget while the last inner sql gives the forecast

For period type year, when profile option is set to display budget as a single horizontal line, first inner sql gives the prior year revenue, second inner sql gives the revenue or budget of all
completed months in the current year while the third inner sql gives NULL revenue for the months ranging
from current month to the end of current year
else, if forecast and budget are to be displayed in the cumulative format, then, first inner sql gives the prior year revenue, second inner sql gives the revenue or budget of all
completed months in the current year, third inner sql gives NULL revenue for the months ranging
from current month to the end of current year while fourth inner sql gives forecast

for more detailed functionality, please refer DLD
At any point of time, only 1 out of 6 SQLs is executed. The flow of the code is as follows :

IF profile option = 'Y' THEN
			IF comparison type ='BUDGET' THEN
							IF period type = 'YEAR' THEN 1st SQL
							ELSE 2nd SQL
							END IF;
			ELSIF period type = 'YEAR' THEN 3rd sql
			ELSE 4th SQL
			END IF;
ELSIF period type = 'YEAR THEN 5th sql
ELSE  6th sql
END IF;

*/

CASE l_budget_forecast_profile

WHEN 'Y' THEN  CASE fii_gl_util_pkg.g_time_comp

	       WHEN 'BUDGET' THEN

		   CASE fii_gl_util_pkg.g_page_period_type

		   WHEN 'FII_TIME_ENT_YEAR'   THEN

		  sqlstmt := '
				SELECT	month_name		VIEWBY,
					SUM(FII_CURRENT_TD)		FII_CURRENT_TD,
					SUM(SUM(DECODE(FII_PRIOR_TD,-99999,NULL,FII_PRIOR_TD))) OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING) FII_PRIOR_TD,
					SUM(SUM(DECODE(FII_FORECAST,-99999,NULL,FII_FORECAST))) OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING) FII_FORECAST
				FROM (
						SELECT		FII_EFFECTIVE_NUM,
								MAX(month_name) month_name ,
								SUM(CURR)				FII_CURRENT_TD,
								DECODE(PREVIOUS,-99999,NULL,PREVIOUS ) FII_PRIOR_TD,
								DECODE(CY_FOR,-99999,NULL,CY_FOR ) FII_FORECAST
						FROM (

							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,
   								NULL CURR,

								(CASE WHEN per.end_date <= to_date(:P_PRIOR_END,''DD-MM-YYYY'') THEN
													CASE f.budget_g
													WHEN 0 THEN -99999  /* -99999 used to show NULL when budget
																value in the DB is equal to 0 */
									                                ELSE f.budget_g
													END
								 ELSE NULL
								 END) PREVIOUS,

								NULL CY_FOR
							FROM    fii_time_ent_period   per
							        '||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

							WHERE   per.ent_period_id = f.time_id
								'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
								per.start_date >= to_date(:P_PRIOR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:P_PRIOR_END,''DD-MM-YYYY'') and
								f.period_type_id = 32

							UNION ALL

						(
							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,

								CASE WHEN per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
									      per.end_date <= to_date(:ASOF_DATE,''DD-MM-YYYY'')
               								 THEN SUM(f.actual_g) OVER (ORDER BY per.ent_period_id ROWS UNBOUNDED PRECEDING)
								 ELSE to_number(NULL)
								 END CURR,
								NULL PREVIOUS,
								NULL CY_FOR
							FROM    fii_time_ent_period   per
								'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

							WHERE   per.ent_period_id = f.time_id
								'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
								per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:ASOF_DATE,''DD-MM-YYYY'') and
								f.period_type_id = 32

							UNION ALL

/* the SELECT statement below makes sure that we always return revenue for all 12 months
regardless of whether all the months have data or not */

							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,
   								CASE WHEN per.start_date >= to_date(:P_TEMP,''DD-MM-YYYY'') THEN to_number(NULL)
								ELSE 0
								END	CURR,
								NULL  PREVIOUS,
								NULL CY_FOR
							FROM	fii_time_ent_period   per
							WHERE   per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:P_CURR_END,''DD-MM-YYYY'')

							UNION ALL

							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,
   								NULL CURR,
								NULL PREVIOUS,
								(CASE WHEN per.end_date <= to_date(:P_CURR_END,''DD-MM-YYYY'') THEN
													CASE f.forecast_g
													WHEN 0 THEN -99999  /* -99999 used to show NULL when forecast
																value in the DB is equal to 0 */
													ELSE f.forecast_g
													END
								ELSE NULL
								END) CY_FOR

							FROM    fii_time_ent_period   per
								'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

							WHERE   per.ent_period_id = f.time_id
								'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
								per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:P_CURR_END,''DD-MM-YYYY'') and
								f.period_type_id = 32


						)
					)
					GROUP BY FII_EFFECTIVE_NUM, PREVIOUS, CY_FOR
				)
				GROUP BY FII_EFFECTIVE_NUM, month_name
				ORDER BY FII_EFFECTIVE_NUM';

			ELSE

			sqlstmt := '

				SELECT	VIEWBY,
					SUM(FII_CURRENT_TD)	FII_CURRENT_TD,
					SUM(FII_PRIOR_TD)	FII_PRIOR_TD,
					SUM(FII_FORECAST)	FII_FORECAST
				FROM (
						SELECT  days	VIEWBY,
							SUM(DECODE(SIGN(report_date - to_date(:ASOF_DATE,''DD-MM-YYYY'')),1,NULL,CY_REV)) FII_CURRENT_TD ,
							NULL	FII_PRIOR_TD,
							NULL	CY_BUD,
							NULL	CY_FOR,
							NULL	FII_FORECAST
						FROM(
							SELECT	g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||') days,
								report_date,
								NVL(SUM(SUM(f.actual_g)) OVER (ORDER BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+											to_number('||l_adjust1||') ROWS UNBOUNDED PRECEDING),0) CY_REV,
								0 PY_REV
							FROM	fii_time_day g,
				 			      ( SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
									WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
										f.manager_id(+) = :MGR_MGR_ID and
										f.gid (+) = 4 and
										f.period_type_id (+) = 1
										'||fii_gl_util_pkg.g_cat_join||')
							      )  f
							WHERE	g.report_date_julian  = f.time_id (+) and
								g.report_date_julian  between :CURR_START_DAY_ID and :CURR_END_DAY_ID

						      GROUP BY	g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||'),report_date

					)
						GROUP BY days

						UNION ALL

						SELECT	days VIEWBY,
							NULL FII_CURRENT_TD,
							SUM(SUM(DECODE(inline_view.CY_BUD,-99999,NULL,inline_view.CY_BUD))) OVER (ORDER BY days
								rows unbounded preceding) FII_PRIOR_TD,
							CY_BUD,
							NULL CY_FOR,
							NULL FII_FORECAST
						FROM
						     ( SELECT	g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||') days,
								report_date test,
								CASE WHEN (g.report_date IN '||l_cond||' ) THEN
														CASE SUM(f.budget_g)
														WHEN 0 THEN -99999
														ELSE SUM(f.budget_g)
														END
								ELSE NULL
								END CY_BUD


							FROM	fii_time_day g,
								( SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
								WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
									f.manager_id(+) =:MGR_MGR_ID and
									f.gid (+) = 4 and
									f.period_type_id (+) = '||l_period_id2||'
									'||fii_gl_util_pkg.g_cat_join||')
								 ) f
							WHERE  '||l_time_id2||' = f.time_id (+) and
								g.report_date_julian  between :CURR_START_DAY_ID and :CURR_END_DAY_ID

							GROUP BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||'), report_date

							ORDER BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||')
						) inline_view

						GROUP BY days,CY_BUD

						UNION ALL

						SELECT	days VIEWBY,
							NULL FII_CURRENT_TD,
							NULL FII_PRIOR_TD,
							NULL CY_BUD,
							CY_FOR,
							SUM(SUM(DECODE(inline_view.CY_FOR,-99999,NULL,inline_view.CY_FOR))) OVER (ORDER BY days
								ROWS UNBOUNDED PRECEDING) FII_FORECAST
						FROM
						     (  SELECT	g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||') days,
								report_date test,
								CASE WHEN (g.report_date IN '||l_cond||' ) THEN
														CASE SUM(f.forecast_g)
														WHEN 0 THEN -99999
														ELSE SUM(f.forecast_g)
														END
								ELSE NULL
								END CY_FOR

							FROM  	fii_time_day g,
								( SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
									WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
										f.manager_id(+) =:MGR_MGR_ID and
										f.gid (+) = 4 and
										f.period_type_id (+) = '||l_period_id2||'
										'||fii_gl_util_pkg.g_cat_join||')
								 ) f

							WHERE  '||l_time_id2||' = f.time_id (+) and
								g.report_date_julian  between :CURR_START_DAY_ID and :CURR_END_DAY_ID

   							GROUP BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||'), report_date

							ORDER BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||')
						) inline_view

						GROUP BY days, CY_FOR
			)

				GROUP BY VIEWBY
				ORDER BY VIEWBY';

			END CASE;

	        ELSE

			CASE fii_gl_util_pkg.g_page_period_type

			WHEN 'FII_TIME_ENT_YEAR'   THEN

				sqlstmt := '
					SELECT	VIEWBY,
					FII_CURRENT_TD,
					SUM(FII_PRIOR_TD) OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING) FII_PRIOR_TD,
					FII_FORECAST
				FROM (
					SELECT	FII_EFFECTIVE_NUM,
						month_name		VIEWBY,
						SUM(FII_CURRENT_TD)		FII_CURRENT_TD,
						SUM(FII_PRIOR_TD)		FII_PRIOR_TD,
						SUM(SUM(DECODE(FII_FORECAST,-99999,NULL,FII_FORECAST))) OVER (ORDER BY FII_EFFECTIVE_NUM
						      ROWS UNBOUNDED PRECEDING) FII_FORECAST
					FROM (
						SELECT	FII_EFFECTIVE_NUM,
							MAX(month_name)		month_name ,
							SUM(CURR)				FII_CURRENT_TD,
							SUM(PREVIOUS)				FII_PRIOR_TD,
							DECODE(CY_FOR,-99999,NULL,CY_FOR ) FII_FORECAST
						FROM (

							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,
   								NULL CURR,
								(CASE WHEN per.end_date <= to_date(:P_PRIOR_END,''DD-MM-YYYY'') THEN f.actual_g
									    ELSE to_number(NULL)
									    END)  PREVIOUS,
								NULL CY_FOR
							FROM    fii_time_ent_period   per
								'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

							WHERE   per.ent_period_id = f.time_id
								'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
								per.start_date >= to_date(:P_PRIOR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:P_PRIOR_END,''DD-MM-YYYY'') and
								f.period_type_id = 32

							UNION ALL

						(
							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,

								CASE WHEN per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
									      per.end_date <= to_date(:ASOF_DATE,''DD-MM-YYYY'')
               								 THEN SUM(f.actual_g) OVER (ORDER BY per.ent_period_id ROWS UNBOUNDED PRECEDING)
								ELSE to_number(NULL)
								END  CURR,
								NULL PREVIOUS,
								NULL CY_FOR
							FROM    fii_time_ent_period   per
								'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

							WHERE   per.ent_period_id = f.time_id
								'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
								per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:ASOF_DATE,''DD-MM-YYYY'') and
								f.period_type_id = 32

							UNION ALL


							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,
   								CASE WHEN per.start_date >= to_date(:P_TEMP,''DD-MM-YYYY'') THEN to_number(NULL)
								ELSE 0
								END	CURR,
								NULL  PREVIOUS,
								NULL CY_FOR
							FROM    fii_time_ent_period   per
							WHERE   per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:P_CURR_END,''DD-MM-YYYY'')

							UNION ALL

							SELECT  per.sequence FII_EFFECTIVE_NUM,
								per.name month_name,
								per.ent_period_id id,
   								NULL CURR,
								NULL PREVIOUS,
								(CASE WHEN per.end_date <= to_date(:P_CURR_END,''DD-MM-YYYY'') THEN
													CASE f.forecast_g
													WHEN 0 THEN -99999
													ELSE f.forecast_g
													END
								ELSE NULL
								END) CY_FOR

							FROM    fii_time_ent_period   per
								'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

							WHERE   per.ent_period_id = f.time_id
								'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
								per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
								per.end_date   <= to_date(:P_CURR_END,''DD-MM-YYYY'') and
								f.period_type_id = 32


						)
					)
				GROUP BY FII_EFFECTIVE_NUM, CY_FOR
			)
			GROUP BY FII_EFFECTIVE_NUM, month_name
			ORDER BY FII_EFFECTIVE_NUM)';

			ELSE

			sqlstmt := '

				SELECT 	VIEWBY,
					SUM(FII_CURRENT_TD)	FII_CURRENT_TD,
					SUM(FII_PRIOR_TD)	FII_PRIOR_TD,
					SUM(FII_FORECAST)	FII_FORECAST
				FROM (

					SELECT	VIEWBY,
						SUM(FII_CURRENT_TD)	FII_CURRENT_TD,
						SUM(FII_PRIOR_TD)	FII_PRIOR_TD,
					      ( CASE WHEN (CY_FOR = -99999 or CY_FOR = NULL) THEN NULL
						ELSE SUM(FII_FORECAST)
						END
					      )			FII_FORECAST
					FROM (
						SELECT  days								VIEWBY,
							SUM(DECODE(SIGN(report_date - to_date(:ASOF_DATE,''DD-MM-YYYY'')),1,NULL,CY_REV))	FII_CURRENT_TD ,
							SUM(DECODE(SIGN(report_date - to_date(:P_PRIOR_END,''DD-MM-YYYY'')),1,NULL,PY_REV)) FII_PRIOR_TD,
							NULL CY_FOR,
							NULL FII_FORECAST
						FROM (
							SELECT		g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||') days,
									report_date,
									NVL(SUM(SUM(f.actual_g)) OVER (ORDER BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+
										to_number('||l_adjust1||') ROWS UNBOUNDED PRECEDING),0) CY_REV,
									0 PY_REV
							FROM		fii_time_day g,
								     (  SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
										WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
											f.manager_id(+) = :MGR_MGR_ID and
											f.gid (+) = 4 and
											f.period_type_id (+) = 1
											'||fii_gl_util_pkg.g_cat_join||')
								      )  f
							WHERE		g.report_date_julian  = f.time_id (+) and
									g.report_date_julian  between :CURR_START_DAY_ID and :CURR_END_DAY_ID

							GROUP BY	g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||'),report_date

							UNION ALL

							SELECT		g.report_date-to_date(:P_PRIOR_START,''DD-MM-YYYY'')+to_number('||l_adjust2||') days,
									report_date,
									to_number(NULL) CY_REV,
									NVL(SUM(SUM(f.actual_g)) OVER (ORDER BY g.report_date-to_date(:P_PRIOR_START,''DD-MM-YYYY'')+
										to_number('||l_adjust2||') ROWS UNBOUNDED PRECEDING),0) PY_REV
							FROM		fii_time_day g,
								     (	SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
										WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
											f.manager_id(+) = :MGR_MGR_ID and
											f.gid (+) = 4 and
											f.period_type_id (+) = 1
											'||fii_gl_util_pkg.g_cat_join||')
								      )	f
							WHERE		f.time_id (+) = g.report_date_julian and
									g.report_date_julian  between :PRIOR_START_DAY_ID and :PRIOR_END_DAY_ID

							GROUP BY	g.report_date-to_date(:P_PRIOR_START,''DD-MM-YYYY'')+to_number('||l_adjust2||'),report_date
						)
					GROUP BY days

					UNION ALL

					SELECT	days 				VIEWBY,
						NULL 				FII_CURRENT_TD,
						NULL 				FII_PRIOR_TD,
						CY_FOR,
						SUM(SUM(DECODE(inline_view.CY_FOR,-99999,NULL,inline_view.CY_FOR))) OVER (ORDER BY days
							ROWS UNBOUNDED PRECEDING) FII_FORECAST
					FROM
						(SELECT g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||') days,
							report_date test,
							CASE WHEN (g.report_date IN '||l_cond||' ) THEN
													CASE SUM(f.forecast_g)
													WHEN 0 THEN -99999
													ELSE SUM(f.forecast_g)
													END
							ELSE NULL
							END CY_FOR

						FROM  	fii_time_day g,
						      ( SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
									WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
										f.manager_id(+) =:MGR_MGR_ID and
										f.gid (+) = 4 and
										f.period_type_id (+) = '||l_period_id2||'
										'||fii_gl_util_pkg.g_cat_join||')
						       ) f
						WHERE
							'||l_time_id2||' = f.time_id (+) and
				 			g.report_date_julian  between :CURR_START_DAY_ID and :CURR_END_DAY_ID

   						GROUP BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||'), report_date

						ORDER BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||')
					 ) inline_view

					GROUP BY days, CY_FOR


				)

			GROUP BY VIEWBY, CY_FOR
		)

		GROUP BY VIEWBY
		ORDER BY VIEWBY';

			END CASE;

	END CASE;


ELSE
	CASE fii_gl_util_pkg.g_page_period_type

	WHEN 'FII_TIME_ENT_YEAR'   THEN

sqlstmt := '
	SELECT MONTH_NAME		VIEWBY ,
	       FII_CURRENT_TD,
	       CASE WHEN '''||l_if_budget||''' = ''Y'' THEN '||l_budget||'
	       ELSE SUM(FII_PRIOR_TD) OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING)
	       END				FII_PRIOR_TD,
	       FII_FORECAST
	FROM

		(SELECT	MAX(month_name)		month_name,
			FII_EFFECTIVE_NUM	FII_EFFECTIVE_NUM,
			SUM(CURR)				FII_CURRENT_TD,
			SUM(PREVIOUS)				FII_PRIOR_TD,
			'||l_forecast||'			FII_FORECAST
		FROM (

			SELECT  per.sequence FII_EFFECTIVE_NUM,
				per.name month_name,
				per.ent_period_id id,
   				NULL CURR,
				CASE WHEN '''||fii_gl_util_pkg.g_time_comp||'''=''BUDGET'' THEN '||l_budget||'
				ELSE
				     (CASE WHEN per.end_date <= to_date(:P_PRIOR_END,''DD-MM-YYYY'') THEN f.actual_g
				      ELSE to_number(NULL)
				      END)
				END	PREVIOUS
			FROM    fii_time_ent_period   per
				'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

			WHERE   per.ent_period_id = f.time_id
				'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
				per.start_date >= to_date(:P_PRIOR_START,''DD-MM-YYYY'') and
				per.end_date   <= to_date(:P_PRIOR_END,''DD-MM-YYYY'') and
				f.period_type_id = 32

			UNION ALL

                    (
			SELECT  per.sequence FII_EFFECTIVE_NUM,
				per.name month_name,
				per.ent_period_id id,

				CASE WHEN per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and per.end_date <= to_date(:ASOF_DATE,''DD-MM-YYYY'')
               				 THEN SUM(f.actual_g) OVER (ORDER BY per.ent_period_id ROWS UNBOUNDED PRECEDING)
				ELSE to_number(NULL)
				END CURR,
				0 PREVIOUS
			FROM    fii_time_ent_period   per
				'||fii_gl_util_pkg.g_view||fii_gl_util_pkg.g_mgr_from_clause||fii_gl_util_pkg.g_cat_from_clause||'

			WHERE   per.ent_period_id = f.time_id
				'||fii_gl_util_pkg.g_mgr_join||fii_gl_util_pkg.g_cat_join||''||fii_gl_util_pkg.g_gid||' and
				per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
				per.end_date   <= to_date(:ASOF_DATE,''DD-MM-YYYY'') and
				f.period_type_id = 32

			UNION ALL


			SELECT  per.sequence FII_EFFECTIVE_NUM,
				per.name month_name,
				per.ent_period_id id,
   				CASE WHEN per.start_date >= to_date(:P_TEMP,''DD-MM-YYYY'') THEN to_number(NULL)
				ELSE 0
				END	CURR,
				0  PREVIOUS
			FROM    fii_time_ent_period   per
		        WHERE   per.start_date >= to_date(:P_CURR_START,''DD-MM-YYYY'') and
				per.end_date   <= to_date(:P_CURR_END,''DD-MM-YYYY'')

		     )
		 )
			GROUP BY FII_EFFECTIVE_NUM
			ORDER BY FII_EFFECTIVE_NUM
		)';

ELSE

	sqlstmt := '
		SELECT  days	VIEWBY,
			SUM(DECODE(SIGN(report_date - to_date(:ASOF_DATE,''DD-MM-YYYY'')),1,NULL,CY_REV))	FII_CURRENT_TD ,
			CASE WHEN '''||fii_gl_util_pkg.g_time_comp||'''=''BUDGET'' THEN '||l_budget||'
			ELSE SUM(DECODE(SIGN(report_date - to_date(:P_PRIOR_END,''DD-MM-YYYY'')),1,NULL,PY_REV))
			END	FII_PRIOR_TD,
			'||l_forecast||'						FII_FORECAST
		FROM(
			SELECT		g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||') days,
					report_date,
					NVL(SUM(SUM(f.actual_g)) OVER (ORDER BY g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||') 								ROWS UNBOUNDED PRECEDING),0) CY_REV,
					0 PY_REV
			FROM		fii_time_day g,
				      ( SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
					WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
						f.manager_id(+) = :MGR_MGR_ID and
						f.gid (+) = 4 and
						f.period_type_id (+) = 1
						'||fii_gl_util_pkg.g_cat_join||')
		         	      )  f
			WHERE		g.report_date_julian  = f.time_id (+) and
					g.report_date_julian  between :CURR_START_DAY_ID and :CURR_END_DAY_ID

			GROUP BY	g.report_date-to_date(:P_CURR_START,''DD-MM-YYYY'')+to_number('||l_adjust1||'),report_date

			UNION ALL

			SELECT		g.report_date-to_date(:P_PRIOR_START,''DD-MM-YYYY'')+to_number('||l_adjust2||') days,
					report_date,
					to_number(NULL) CY_REV,
					NVL(SUM(SUM(f.actual_g)) OVER (ORDER BY g.report_date-to_date(:P_PRIOR_START,''DD-MM-YYYY'')+to_number('||l_adjust2||') 							ROWS UNBOUNDED PRECEDING),0) PY_REV
			FROM		fii_time_day g,
				     (	SELECT * FROM FII_GL_MGMT_SUM_V'||fii_gl_util_pkg.g_global_curr_view||' f
					WHERE ( 1=1 and f.person_id(+) = '||l_dummy_mgr_id||' and
						f.manager_id(+) = :MGR_MGR_ID and
						f.gid (+) = 4 and
						f.period_type_id (+) = 1
						'||fii_gl_util_pkg.g_cat_join||')
				     )	f
			 WHERE		g.report_date_julian  = f.time_id (+) and
					g.report_date_julian  between :PRIOR_START_DAY_ID and :PRIOR_END_DAY_ID

			GROUP BY	g.report_date-to_date(:P_PRIOR_START,''DD-MM-YYYY'')+to_number('||l_adjust2||'),report_date
		)
		GROUP BY days
		ORDER BY days';

		END CASE;

END CASE;

fii_gl_util_pkg.bind_variable(p_sqlstmt=>sqlstmt,
			       p_page_parameter_tbl=>p_page_parameter_tbl,
			       p_sql_output=>cumul_rev_sql,
			       p_bind_output_table=>cumul_rev_output);
END get_cumul_rev;

END fii_gl_cumul_rev_trend_pkg;


/
