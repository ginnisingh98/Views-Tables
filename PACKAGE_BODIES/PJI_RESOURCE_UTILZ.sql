--------------------------------------------------------
--  DDL for Package Body PJI_RESOURCE_UTILZ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJI_RESOURCE_UTILZ" AS
/* $Header: PJIPR01B.pls 120.3.12010000.3 2009/04/28 11:00:01 paljain ship $ */

g_calc_mthd		VARCHAR2(30);
g_last_summ_date 	DATE;
g_last_summ_period_id	NUMBER;
g_last_summ_pd_seq	NUMBER;
g_last_summ_pd_name	VARCHAR2(80);
g_curr_period_seq	NUMBER;
g_curr_period_id	NUMBER;
g_curr_quarter_id	NUMBER;
g_curr_year_id		NUMBER;
g_curr_period_name	VARCHAR2(100);
g_curr_quarter_name	VARCHAR2(100);
g_curr_year_name	VARCHAR2(100);
g_prev_yr_period_seq	NUMBER;
g_forward_periods	NUMBER := 3;
g_backward_periods	NUMBER := 8;
g_curr_yr_pd_start_date	DATE;
g_prev_yr_pd_start_date	DATE;
g_prev_yr_period_id 	NUMBER;
g_curr_yr_max_sequence  NUMBER;
g_curr_yr_min_sequence  NUMBER;

/*
  This procedure is used to get data based on the calendar
  type that is set in the user profile. This data is used
  in determining periods that should be shown on the
  screen to the user
  */

PROCEDURE GET_PERIOD_DATA
(
         p_calendar_type	IN  VARCHAR2
        ,p_org_id		IN NUMBER /* MOAC Changes */
        ,x_calendar_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_accnt_period_type OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_sets_of_books_id OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       IF (p_calendar_type = 'G') THEN

		SELECT 	   fiin.calendar_id,
			   sob.accounted_period_type,
			   sob.set_of_books_id
		INTO	   x_calendar_id,
			   x_accnt_period_type,
			   x_sets_of_books_id
		FROM
			   fii_time_cal_name fiin,
			   pa_implementations_all imp,                 -- Bug Fix 8284858
			   gl_sets_of_books sob
		WHERE
			   imp.set_of_books_id = sob.set_of_books_id
			   AND imp.org_id = p_org_id 			-- MOAC Changes
			   AND sob.period_set_name = imp.period_set_name
			   AND fiin.period_type     = sob.accounted_period_type
			   AND sob.period_set_name = fiin.period_set_name;

	ELSIF (p_calendar_type = 'P') THEN

		SELECT 	   fiin.calendar_id,
			   imp.pa_period_type,
			   imp.set_of_books_id
		INTO	   x_calendar_id,
			   x_accnt_period_type,
			   x_sets_of_books_id
		FROM
			   fii_time_cal_name fiin,
			   pa_implementations_all imp                -- Bug Fix 8284858
		WHERE
			   imp.period_set_name = fiin.period_set_name
			   AND imp.org_id = p_org_id 			-- MOAC Changes
			   AND fiin.period_type = imp.pa_period_type;

	ELSIF (p_calendar_type = 'E') THEN
		SELECT 	   -1
		INTO 	   x_calendar_id
		FROM
			   DUAL;
	END IF;

END GET_PERIOD_DATA;

/*
   This procedure validates and populates the data to be
   used by the graphs and tables on the Personal Resource
   Utilization Page. This method is called when we DO NOT
   NEED to get daily records to calculate expected
   utilization, i.e., when the last summarization date
   does not resides in the periods that we are processing
 */
PROCEDURE PJI_POP_SIMPLE_UTILZ_DATA
(
	 p_calendar_id 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
        ,p_population_mode	IN  VARCHAR2
        ,p_table_amount_type	IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

l_prev_period_id	NUMBER;
l_prev_quarter_id	NUMBER;
l_prev_year_id		NUMBER;
BEGIN

delete from pji_pmv_time_dim_tmp;

IF (p_population_mode = 'GRAPH') THEN

	--Insert records for the current period and corresponding
	--periods backwards and forward
	INSERT INTO PJI_PMV_TIME_DIM_TMP
	   (
		ID,
		PRIOR_ID,
		NAME,
		ORDER_BY_ID,
		PERIOD_TYPE,
		AMOUNT_TYPE,
		CALENDAR_TYPE
	   )
	SELECT 	period_id 			as id,
		null				as prior_id,
		period_name 			as name,
		sequence - g_curr_period_seq  	as order_by_id,
		32				as period_type,
		1				as amount_type,
		p_calendar_type			as calendar_type
	FROM pji_time_mv
	WHERE period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
	AND calendar_id = p_calendar_id
	AND sequence between g_curr_period_seq-g_backward_periods
			 and g_curr_period_seq+g_forward_periods;

	--Update records for the current period in the prior year
	--and corresponding periods backwards and forward

	UPDATE PJI_PMV_TIME_DIM_TMP pmv
	SET pmv.PRIOR_ID =
		(  SELECT period_id 	as prior_id
		   FROM pji_time_mv lower
		   WHERE
		   lower.period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
		   AND lower.calendar_id = p_calendar_id
		   AND lower.sequence between g_prev_yr_period_seq-g_backward_periods
					  and g_prev_yr_period_seq+g_forward_periods
		   AND pmv.order_by_id = lower.sequence-g_prev_yr_period_seq
		);
ELSIF (p_population_mode = 'TABLE') THEN

	 INSERT INTO PJI_PMV_TIME_DIM_TMP
	   (
		ID,
		PRIOR_ID,
		NAME,
		ORDER_BY_ID,
		PERIOD_TYPE,
		AMOUNT_TYPE,
		CALENDAR_TYPE
	   )
         SELECT r1.id 			as id,
	 	r1.prior_id		as prior_id,
	 	r1.name 		as name,
	 	r1.sequence  		as order_by_id,
	 	r1.period_type		as period_type,
	 	r1.amount_type		as amount_type,
	 	r1.calendar_type	as calendar_type
	 FROM
	 (
		 SELECT period_id 			as id,
			null				as prior_id,
			period_name 			as name,
			32				as period_type,
			p_table_amount_type		as amount_type,
			p_calendar_type			as calendar_type,
			1  				as sequence
		  FROM pji_time_mv
		  WHERE period_id = g_curr_period_id
		  and calendar_id = p_calendar_id
		  and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
		  UNION ALL
		  select period_id 			as id,
			null				as prior_id,
			quarter_name 			as name,
			64				as period_type,
			p_table_amount_type		as amount_type,
			p_calendar_type			as calendar_type,
			2  				as sequence
		  FROM pji_time_mv
		  WHERE quarter_id = g_curr_quarter_id
		  and calendar_id = p_calendar_id
		  and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_QTR', 'FII_TIME_CAL_QTR')
		  UNION ALL
		  select period_id 			as id,
			null				as prior_id,
			year 				as name,
			128				as period_type,
			p_table_amount_type		as amount_type,
			p_calendar_type			as calendar_type,
			3  				as sequence
		  FROM pji_time_mv
		  WHERE year_id = g_curr_year_id
		  and calendar_id = p_calendar_id
		  and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_YEAR', 'FII_TIME_CAL_YEAR')
	) r1;

	 SELECT period_id,
		quarter_id,
		year_id
	 INTO
		l_prev_period_id,
		l_prev_quarter_id,
		l_prev_year_id
	 FROM pji_time_mv
	 WHERE sequence = g_prev_yr_period_seq
	 and calendar_id = p_calendar_id
	 and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD');

	 UPDATE PJI_PMV_TIME_DIM_TMP pmv
	 SET pmv.PRIOR_ID = l_prev_period_id
	 where order_by_id = 1;

	 UPDATE PJI_PMV_TIME_DIM_TMP pmv
	 SET pmv.PRIOR_ID = l_prev_quarter_id
	 where order_by_id = 2;

	 UPDATE PJI_PMV_TIME_DIM_TMP pmv
	 SET pmv.PRIOR_ID = l_prev_year_id
	 where order_by_id = 3;

END IF;

END PJI_POP_SIMPLE_UTILZ_DATA;

/*
   This procedure validates and populates the data to be
   used by the graphs and tables on the Personal Resource
   Utilization Page. This method is called when we NEED to
   get daily records to calculate expected
   utilization, i.e., when the last summarization date
   resides in the periods that we are processing
 */
PROCEDURE PJI_POP_COMPLEX_UTILZ_DATA
(
	 p_calendar_id 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
        ,p_population_mode	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ NUMBER
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_org_id		NUMBER;
l_curr_period_id_tbl	N_TYPE_TAB;
l_pop_daily_rec_flag	VARCHAR2(1) := 'N';
l_last_summ_pd_end_j	NUMBER;
l_last_summ_pd_name	VARCHAR2(100);
l_period_type		VARCHAR2(100);
l_qtr_period_type	VARCHAR2(100);
l_year_period_type	VARCHAR2(100);
l_last_sum_pmv_seq	NUMBER;
l_daily_rec_qtr_flag	VARCHAR2(1) := 'N';
l_daily_rec_year_flag	VARCHAR2(1) := 'N';
l_prev_period_id	NUMBER;
l_prev_quarter_id	NUMBER;
l_prev_year_id		NUMBER;

BEGIN

delete from pji_pmv_time_dim_tmp;

IF (p_calendar_type <> 'E') THEN
	l_period_type := 'FII_TIME_CAL_PERIOD';
ELSE
	l_period_type := 'FII_TIME_ENT_PERIOD';
END IF;

IF (p_calendar_type <> 'E') THEN
		l_org_id := p_org_id; -- MOAC Changes
		PJI_PMV_ENGINE.Convert_Operating_Unit(l_org_id,'TM');
END IF;

IF (p_population_mode = 'GRAPH') THEN

	--Insert records for the current period and corresponding
	--periods backwards and forward
	INSERT INTO PJI_PMV_TIME_DIM_TMP
	   (
		ID,
		PRIOR_ID,
		NAME,
		ORDER_BY_ID,
		PERIOD_TYPE,
		AMOUNT_TYPE,
		CALENDAR_TYPE
	   )
	SELECT 	period_id 			as id,
		null				as prior_id,
		period_name 			as name,
		sequence - g_curr_period_seq  	as order_by_id,
		32				as period_type,
		DECODE(sign(sequence-g_last_summ_pd_seq),1,0,-1,1,0,1) as amount_type,
		p_calendar_type			as calendar_type
	FROM pji_time_mv
	WHERE period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
	AND calendar_id = p_calendar_id
	AND sequence between g_curr_period_seq-g_backward_periods
			 and g_curr_period_seq+g_forward_periods;

	--Update records for the current period in the prior year
	--and corresponding periods backwards and forward

	UPDATE PJI_PMV_TIME_DIM_TMP pmv
	SET pmv.PRIOR_ID =
		(  SELECT period_id 	as prior_id
		   FROM pji_time_mv lower
		   WHERE
		   lower.period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
		   AND lower.calendar_id = p_calendar_id
		   AND lower.sequence between g_prev_yr_period_seq-g_backward_periods
					  and g_prev_yr_period_seq+g_forward_periods
		   AND pmv.order_by_id = lower.sequence-g_prev_yr_period_seq
		)
	WHERE pmv.period_type = 32;

	--Check if the last summarization date period matches
	--any of the current year periods or not
	--This is because the last summarization date may fall
	--either
	--1. within the 12 periods
	--2. after 12 periods
	--3. before 12 periods (in case of smaller periods)
	SELECT
		ID
	BULK COLLECT INTO
		l_curr_period_id_tbl
	FROM
	PJI_PMV_TIME_DIM_TMP pmv
	where pmv.period_type = 32;

	FOR i in l_curr_period_id_tbl.FIRST.. l_curr_period_id_tbl.LAST
	LOOP
		IF g_last_summ_period_id = l_curr_period_id_tbl(i) THEN
			l_pop_daily_rec_flag := 'Y';
		END IF;
	END LOOP;

	--If one needs to populate daily records because the last
	--summarization date lies in the period for which the
	--utilization would be calculated then proceed ahead

	IF l_pop_daily_rec_flag = 'Y' THEN
		--Update the table to set the period id to null
		--where the last summarization date resides

		UPDATE PJI_PMV_TIME_DIM_TMP pmv
		SET pmv.ID = null
		where pmv.id = g_last_summ_period_id
		and   pmv.calendar_type = p_calendar_type
		and   pmv.period_type = 32
		RETURNING order_by_id
		INTO l_last_sum_pmv_seq;

		--Call the API to insert daily records

		 PJI_PMV_ENGINE.Convert_NViewBY_AS_OF_DATE
				       (
					 to_char(g_last_summ_date,'j')
				       , l_period_type
				       , null
				       , null
				       , p_calendar_id
				       , g_last_summ_pd_name
				       , g_last_summ_period_id
				       );

		 PJI_PMV_ENGINE.Convert_NFViewBY_AS_OF_DATE
				      (
					to_char(g_last_summ_date,'j')+1
				       , l_period_type
				       , null
				       , null
				       , p_calendar_id
				       , g_last_summ_pd_name
				       , g_last_summ_period_id
				      );

		--Update sequence for daily records
		UPDATE PJI_PMV_TIME_DIM_TMP pmv
		set pmv.order_by_id = l_last_sum_pmv_seq
		where pmv.period_type = 1 OR pmv.period_type = 16;
	END IF;
ELSIF (p_population_mode = 'TABLE') THEN

	IF (g_last_summ_pd_seq < g_curr_yr_min_sequence) THEN
		--Call the API to populate time records
		--We do not need daily records in this case
		--as the last summarization date doesn't lie
		--in any of the periods that we are processing
		PJI_POP_SIMPLE_UTILZ_DATA
		(
			 p_calendar_id 		=> p_calendar_id
			,p_calendar_type	=> p_calendar_type
			,p_population_mode	=> 'TABLE'
			,p_table_amount_type	=> 0
			,x_return_status        => x_return_status
			,x_msg_count            => x_msg_count
			,x_msg_data             => x_msg_data
		);
	ELSE
		--Now it is sure that the last summarization date
		--lies in one of the periods of the whole year
		--that we are populating

		--First process for period
		IF (g_last_summ_period_id <> g_curr_period_id) THEN
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			   (
				ID,
				PRIOR_ID,
				NAME,
				ORDER_BY_ID,
				PERIOD_TYPE,
				AMOUNT_TYPE,
				CALENDAR_TYPE
	   		   )
	   		 SELECT period_id 			as id,
				null				as prior_id,
				period_name 			as name,
				1  				as order_by_id,
				32				as period_type,
				DECODE(sign(sequence-g_last_summ_pd_seq),1,0,-1,1,0,1) as amount_type,
				p_calendar_type			as calendar_type
			  FROM pji_time_mv
			  WHERE period_id = g_curr_period_id
			  and calendar_id = p_calendar_id
		  	  and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD');
		ELSE
			--Call the API to insert daily records

		 	PJI_PMV_ENGINE.Convert_NViewBY_AS_OF_DATE
				       (
					 to_char(g_last_summ_date,'j')
				       , l_period_type
				       , null
				       , null
				       , p_calendar_id
				       , g_last_summ_pd_name
				       , 1
				       );

		 	PJI_PMV_ENGINE.Convert_NFViewBY_AS_OF_DATE
				      (
					to_char(g_last_summ_date,'j')+1
				       , l_period_type
				       , null
				       , null
				       , p_calendar_id
				       , g_last_summ_pd_name
				       , 1
				      );
		END IF;

		--Then for quarter
		IF (p_calendar_type <> 'E') THEN
			l_qtr_period_type := 'FII_TIME_CAL_QTR';
		ELSE
			l_qtr_period_type := 'FII_TIME_ENT_QTR';
		END IF;

		SELECT
			period_id
		BULK COLLECT INTO
			l_curr_period_id_tbl
		FROM
		pji_time_mv pt
		where quarter_id = g_curr_quarter_id
		and calendar_id = p_calendar_id
		and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD');

		FOR i in l_curr_period_id_tbl.FIRST.. l_curr_period_id_tbl.LAST
		LOOP
			IF g_last_summ_period_id = l_curr_period_id_tbl(i) THEN
				l_daily_rec_qtr_flag := 'Y';
			END IF;
		END LOOP;

		IF (l_daily_rec_qtr_flag <> 'Y') THEN
			INSERT INTO PJI_PMV_TIME_DIM_TMP
			   (
				ID,
				PRIOR_ID,
				NAME,
				ORDER_BY_ID,
				PERIOD_TYPE,
				AMOUNT_TYPE,
				CALENDAR_TYPE
			   )
			 SELECT period_id 			as id,
				null				as prior_id,
				g_curr_quarter_name		as name,
				2  				as order_by_id,
				32				as period_type,
				DECODE(sign(sequence-g_last_summ_pd_seq),1,0,-1,1,0,1) as amount_type,
				p_calendar_type			as calendar_type
			  FROM pji_time_mv
			  WHERE quarter_id = g_curr_quarter_id
			  and calendar_id = p_calendar_id
			  and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD');
		ELSE
			--Call the API to insert daily records

			PJI_PMV_ENGINE.Convert_NViewBY_AS_OF_DATE
				       (
					 to_char(g_last_summ_date,'j')
				       , l_qtr_period_type
				       , null
				       , null
				       , p_calendar_id
				       , g_curr_quarter_name
				       , 2
				       );

			PJI_PMV_ENGINE.Convert_NFViewBY_AS_OF_DATE
				      (
					to_char(g_last_summ_date,'j')+1
				       , l_qtr_period_type
				       , null
				       , null
				       , p_calendar_id
				       , g_curr_quarter_name
				       , 2
				      );
		END IF;

		--Then for year
		IF (p_calendar_type <> 'E') THEN
			l_year_period_type := 'FII_TIME_CAL_YEAR';
		ELSE
			l_year_period_type := 'FII_TIME_ENT_YEAR';
		END IF;

		--We do not need to check if the summarization date
		--lies in this year or not because if the program
		--comes here then it guarantees that the summarization
		--date lies in the year

		--Call the API to insert daily records

		PJI_PMV_ENGINE.Convert_NViewBY_AS_OF_DATE
			       (
				 to_char(g_last_summ_date,'j')
			       , l_year_period_type
			       , null
			       , null
			       , p_calendar_id
			       , g_curr_year_name
			       , 3
			       );

		PJI_PMV_ENGINE.Convert_NFViewBY_AS_OF_DATE
			      (
				to_char(g_last_summ_date,'j')+1
			       , l_year_period_type
			       , null
			       , null
			       , p_calendar_id
			       , g_curr_year_name
			       , 3
			      );

		--Then for previous year
		 SELECT period_id,
			quarter_id,
			year_id
		 INTO
			l_prev_period_id,
			l_prev_quarter_id,
			l_prev_year_id
		 FROM pji_time_mv
		 WHERE sequence = g_prev_yr_period_seq
		 and calendar_id = p_calendar_id
		 and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD');

		 INSERT INTO PJI_PMV_TIME_DIM_TMP
			   (
				ID,
				PRIOR_ID,
				NAME,
				ORDER_BY_ID,
				PERIOD_TYPE,
				AMOUNT_TYPE,
				CALENDAR_TYPE
			   )
		 VALUES
			(
				null 		,
				l_prev_period_id,
				g_curr_period_name,
				1  		,
				32		,
				1 		,
				p_calendar_type
			);

		INSERT INTO PJI_PMV_TIME_DIM_TMP
			   (
				ID,
				PRIOR_ID,
				NAME,
				ORDER_BY_ID,
				PERIOD_TYPE,
				AMOUNT_TYPE,
				CALENDAR_TYPE
			   )
		 VALUES
			(
				null 		,
				l_prev_quarter_id,
				g_curr_quarter_name,
				2  		,
				64		,
				1 		,
				p_calendar_type
			);
		INSERT INTO PJI_PMV_TIME_DIM_TMP
			   (
				ID,
				PRIOR_ID,
				NAME,
				ORDER_BY_ID,
				PERIOD_TYPE,
				AMOUNT_TYPE,
				CALENDAR_TYPE
			   )
		 VALUES
			(
				null 		,
				l_prev_year_id,
				g_curr_year_name,
				3  		,
				128		,
				1 		,
				p_calendar_type
			);
	END IF;
END IF;

END PJI_POP_COMPLEX_UTILZ_DATA;

/* This method is the primary method for calculating
   utilization data and populating the global temporary
   tables with the utilization data that would be
   shown in the graph

   This method also initializes the package specific
   global variables that would be used in utilization
   calculation for both graph and table utilization
   data with respected to the graph and table shown on
   the Personal Resource Utilization Page
 */
PROCEDURE PJI_POP_GRAPH_UTILZ_DATA
(
	 p_person_id   		IN  NUMBER
	,p_period_id   		IN  NUMBER
	,p_period_type 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
	,p_org_id		IN NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_org_id			NUMBER;
l_calendar_id 			NUMBER;
l_accnt_period_type		VARCHAR2(15);
l_sets_of_books_id		NUMBER;
l_act_utilz_label		VARCHAR2(100);
l_sched_utilz_label		VARCHAR2(100);
l_curr_yr_act_utilz_label	VARCHAR2(100);
l_curr_yr_sched_utilz_label	VARCHAR2(100);
l_prev_yr_act_utilz_label	VARCHAR2(100);
l_prev_year_name		VARCHAR2(100);
BEGIN
	--Get the crucial parameters
	GET_PERIOD_DATA
	(
		 p_calendar_type	=> p_calendar_type
		,p_org_id		=> p_org_id
		,x_calendar_id		=> l_calendar_id
		,x_accnt_period_type	=> l_accnt_period_type
		,x_sets_of_books_id	=> l_sets_of_books_id
		,x_return_status        => x_return_status
		,x_msg_count            => x_msg_count
		,x_msg_data             => x_msg_data
	);

	--Get the last summarized date
	SELECT trunc(to_date(PJI_UTILS.GET_PARAMETER('LAST_FM_EXTR_DATE'),'YYYY/MM/DD'))
	INTO g_last_summ_date
	FROM dual;

	IF g_last_summ_date IS NULL THEN
		RETURN;
	END IF;

	IF (p_calendar_type = 'E') THEN
		SELECT period.ent_period_id
    		      ,period.name
		INTO   g_last_summ_period_id,
		       g_last_summ_pd_name
		FROM   fii_time_day day,
		       fii_time_ent_period period
		WHERE  report_date = g_last_summ_date
    		       AND period.ent_period_id = day.ent_period_id;
	ELSE
		SELECT day.cal_period_id
	              ,pmv.period_name
	        INTO   g_last_summ_period_id,
		       g_last_summ_pd_name
	        FROM
	               fii_time_cal_day_mv day
	              ,pji_time_mv pmv
	        WHERE
	            report_date = g_last_summ_date
			and pmv.period_type = 'FII_TIME_CAL_PERIOD' /* Added this condition for bug 4312361 */
	        AND day.cal_period_id = pmv.period_id
		and pmv.calendar_id = l_calendar_id
		and day.calendar_id = pmv.calendar_id;
	END IF;

	--Get the sequence for the last summarized date period
		SELECT sequence
		INTO g_last_summ_pd_seq
		FROM pji_time_mv
		WHERE period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
		AND period_id = g_last_summ_period_id
		AND calendar_id = l_calendar_id;

	--Get the sequence and other information for the current selected period
		SELECT sequence,
		       period_id,
		       period_name,
		       quarter_id,
		       quarter_name,
	 	       year_id,
	 	       year
		INTO g_curr_period_seq,
		     g_curr_period_id,
		     g_curr_period_name,
		     g_curr_quarter_id,
		     g_curr_quarter_name,
	 	     g_curr_year_id,
	 	     g_curr_year_name
		FROM pji_time_mv
		WHERE period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
		AND period_id = p_period_id
		AND calendar_id = l_calendar_id;

	--Get the corresponding period from the last year

	IF (p_calendar_type = 'E') THEN
		--Get start date of current period
		SELECT start_date
		INTO   g_curr_yr_pd_start_date
		FROM   fii_time_ent_period
		WHERE  ent_period_id = p_period_id;

		--Get corresponding date in the last year
		SELECT Fii_Time_Api.ent_sd_lysper_end(g_curr_yr_pd_start_date)
		INTO   g_prev_yr_pd_start_date
		FROM   DUAL;

		--Get the corresponding period in the last year
		SELECT ent_period_id
		INTO   g_prev_yr_period_id
		FROM   fii_time_day
		WHERE  report_date_julian = to_char(g_prev_yr_pd_start_date,'j');
	ELSE
		--Get start date of current period
		SELECT start_date
		INTO   g_curr_yr_pd_start_date
		FROM   fii_time_cal_period
		WHERE  cal_period_id = p_period_id
		AND calendar_id = l_calendar_id;

		--Get corresponding date in the last year
		SELECT Fii_Time_Api.cal_sd_lysper_end(g_curr_yr_pd_start_date, l_calendar_id)
		INTO   g_prev_yr_pd_start_date
		FROM   DUAL;

		--Get the corresponding period in the last year
		SELECT cal_period_id
		INTO   g_prev_yr_period_id
		FROM   fii_time_cal_day_mv
		WHERE report_date_julian = to_char(g_prev_yr_pd_start_date,'j')
		and calendar_id = l_calendar_id;
	END IF;

	--Get the sequence for the last year corresponding period
		SELECT NVL(sequence,0)
		INTO g_prev_yr_period_seq
		FROM pji_time_mv
		WHERE period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD')
		AND period_id = g_prev_yr_period_id
		AND calendar_id = l_calendar_id;

	--Populate the time tables
	IF (
		(g_last_summ_pd_seq - g_curr_period_seq) > g_forward_periods
	   ) THEN
		--Call the API to populate time records
		--We do not need daily records in this case
		--as the last summarization date doesn't lie
		--in any of the periods that we are processing
		PJI_POP_SIMPLE_UTILZ_DATA
		(
			 p_calendar_id 		=> l_calendar_id
		        ,p_calendar_type	=> p_calendar_type
		        ,p_population_mode	=> 'GRAPH'
		        ,x_return_status        => x_return_status
			,x_msg_count            => x_msg_count
			,x_msg_data             => x_msg_data
		);
	ELSE
		PJI_POP_COMPLEX_UTILZ_DATA
		(
			 p_calendar_id 		=> l_calendar_id
			,p_org_id		=> p_org_id
			,p_calendar_type	=> p_calendar_type
			,p_population_mode	=> 'GRAPH'
			,x_return_status        => x_return_status
			,x_msg_count            => x_msg_count
			,x_msg_data             => x_msg_data
		);
	END IF;

       	SELECT NVL(fnd_profile.value('PA_RES_UTIL_DEF_CALC_METHOD'),'CAPACITY')
	INTO g_calc_mthd
	FROM DUAL;

        --Calculate expected utilization and put it
        --in the global temporary table

	   DELETE FROM PJI_RES_UTILZ_TMP2;

	   INSERT INTO PJI_RES_UTILZ_TMP2
	   (
		   period_name,
		   curr_yr_actual_utiliz,
		   curr_yr_sched_utiliz,
		   curr_yr_exp_utiliz,
		   prev_yr_utiliz,
		   sequence
       	   )
	   SELECT
	   r1.period_name as period_name,
	   round(SUM(r1.actual_utilz) * 100,2) as curr_yr_actual_utiliz,
	   round(SUM(r1.sched_utilz) * 100,2) as curr_yr_sched_utiliz,
	   round(SUM(r1.exp_utilz) * 100,2) as curr_yr_exp_utiliz,
	   round(SUM(r1.prev_yr_utilz) * 100,2) as prev_yr_utiliz,
	   r1.id as sequence
	   FROM
	   (
	   	SELECT
	   	SUM(total_wtd_res_hrs_a)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a)),
					       0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a))) as actual_utilz,
		SUM(CONF_WTD_RES_HRS_S)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_s, cur2.conf_hrs_s)),
					       0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_s, cur2.conf_hrs_s))) as sched_utilz,
	     	SUM(DECODE(pmv.amount_type,1, total_wtd_res_hrs_a,CONF_WTD_RES_HRS_S))/DECODE(SUM(DECODE(g_calc_mthd,
	     					'CAPACITY',cur2.capacity_hrs - DECODE(pmv.amount_type,1,cur2.reduce_capacity_hrs_a,cur2.reduce_capacity_hrs_s),
	     						DECODE(pmv.amount_type,1, cur2.total_hrs_a, cur2.conf_hrs_s))),
	     					0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs -
	     						DECODE(pmv.amount_type,1,cur2.reduce_capacity_hrs_a,cur2.reduce_capacity_hrs_s),
	     						DECODE(pmv.amount_type,1, cur2.total_hrs_a, cur2.conf_hrs_s))))   as exp_utilz,
	     	0 as prev_yr_utilz,
	     	pmv.name as period_name,
	     	pmv.order_by_id as id
	   	from pji_rm_res_f cur2, PJI_PMV_TIME_DIM_TMP pmv
	   	where person_id = p_person_id
	   	and pmv.period_type IN (1,16)
	   	and pmv.period_type = cur2.period_type_id
	   	and pmv.calendar_type = 'C'
	   	and pmv.calendar_type = cur2.calendar_type
	   	and pmv.id = cur2.time_id
	   	group by pmv.name, pmv.order_by_id
	   	UNION ALL
	   	SELECT
	        SUM(total_wtd_res_hrs_a)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a)),
					       0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a))) as actual_utilz,
		SUM(CONF_WTD_RES_HRS_S)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_s, cur2.conf_hrs_s)),
					       0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_s, cur2.conf_hrs_s))) as sched_utilz,
	     	SUM(DECODE(pmv.amount_type,1, total_wtd_res_hrs_a,CONF_WTD_RES_HRS_S))/DECODE(SUM(DECODE(g_calc_mthd,
	     					'CAPACITY',cur2.capacity_hrs - DECODE(pmv.amount_type,1,cur2.reduce_capacity_hrs_a,cur2.reduce_capacity_hrs_s),
	     						DECODE(pmv.amount_type,1, cur2.total_hrs_a, cur2.conf_hrs_s))),
   	  					0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs -
   	  						DECODE(pmv.amount_type,1,cur2.reduce_capacity_hrs_a,cur2.reduce_capacity_hrs_s),
   	  						DECODE(pmv.amount_type,1, cur2.total_hrs_a, cur2.conf_hrs_s)))) as exp_utilz,
	     	0 as prev_yr_utilz,
	     	pmv.name as period_name,
	     	pmv.order_by_id as id
	   	from pji_rm_res_f cur2, PJI_PMV_TIME_DIM_TMP pmv
	   	where person_id = p_person_id
	   	and pmv.period_type = 32
	   	and pmv.period_type = cur2.period_type_id
	   	and pmv.calendar_type = p_calendar_type
	   	and pmv.calendar_type = cur2.calendar_type
	   	and pmv.id = cur2.time_id
	   	and pmv.id is not null
	   	group by pmv.name, pmv.order_by_id
	   	UNION ALL
	   	SELECT
	   	0  as actual_utilz,
	   	0  as sched_utilz,
	   	0  as exp_utilz,
	     	SUM(total_wtd_res_hrs_a)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a)),
	     				 0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a))) as prev_yr_utilz,
	     	pmv.name as period_name,
	     	pmv.order_by_id as id
	   	from pji_rm_res_f cur2, PJI_PMV_TIME_DIM_TMP pmv
	   	where person_id = p_person_id
	   	and pmv.period_type = 32
	   	and pmv.period_type = cur2.period_type_id
	   	and pmv.calendar_type = p_calendar_type
	   	and pmv.calendar_type = cur2.calendar_type
	   	and pmv.prior_id = cur2.time_id
	   	group by pmv.name, order_by_id
	   ) r1
	   group by r1.period_name, r1.id
	   order by id;

	   --Now, we need to get data in a format where
	   --the legend on the graph shows the year names
	   --along with utilization labels

	   SELECT meaning
	   INTO l_act_utilz_label
	   FROM pji_lookups
	   WHERE lookup_type = 'PJI_RM_UTILZ_GRAPH_HEADER'
	   and lookup_code = 'ACT_UTILZ';

	   SELECT meaning
	   INTO l_sched_utilz_label
	   FROM pji_lookups
	   WHERE lookup_type = 'PJI_RM_UTILZ_GRAPH_HEADER'
	   and lookup_code = 'SCHED_UTILZ';

	   SELECT year
	   INTO
		l_prev_year_name
	   FROM pji_time_mv
	   WHERE sequence = g_prev_yr_period_seq
	   and calendar_id = l_calendar_id
	   and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD');

	   l_curr_yr_act_utilz_label 	:= g_curr_year_name || ' ' ||  l_act_utilz_label;
	   l_curr_yr_sched_utilz_label 	:= g_curr_year_name || ' ' ||  l_sched_utilz_label;
	   l_prev_yr_act_utilz_label 	:= l_prev_year_name || ' ' ||  l_act_utilz_label;


	   INSERT INTO PJI_RES_UTILZ_TMP2
	   (
		   period_name,
		   series_label,
		   value,
		   secondary_sequence,
		   sequence
       	   )
	   SELECT DISTINCT r3.period_name,
	   case when r3.tmp_index = 1 then
			   l_curr_yr_act_utilz_label
		 when r3.tmp_index = 2 then
			   l_curr_yr_sched_utilz_label
		 when r3.tmp_index = 3 then
			   l_prev_yr_act_utilz_label
		 end                                series_label,
	   case when r3.tmp_index = 1 then
			   r3.curr_yr_actual_utiliz
		 when r3.tmp_index = 2 then
			   r3.curr_yr_sched_utiliz
		 when r3.tmp_index = 3 then
			   r3.prev_yr_utiliz
		 end                                value,
	   case when r3.tmp_index = 1 then
			   1
		 when r3.tmp_index = 2 then
			   2
		 when r3.tmp_index = 3 then
			   3
		 end                                secnd_seq,
	   r3.sequence
	   FROM
	   	(
	   	  select r1.period_name,
		  r1.curr_yr_actual_utiliz,
		  r1.curr_yr_sched_utiliz,
		  r1.prev_yr_utiliz,
		  r1.sequence,
		  r2.tmp_index
		  FROM
		        (
			select period_name,
			curr_yr_actual_utiliz,
			curr_yr_sched_utiliz,
			prev_yr_utiliz,
			sequence
			FROM PJI_RES_UTILZ_TMP2
			) r1,
			(
			SELECT 1 as tmp_index from dual
			UNION ALL
			SELECT 2 as tmp_index from dual
			UNION ALL
			SELECT 3 as tmp_index from dual
			) r2
		) r3;

	--Delete records that were inserted initially
	DELETE FROM PJI_RES_UTILZ_TMP2
	WHERE series_label IS NULL;

END PJI_POP_GRAPH_UTILZ_DATA;

/* This method is the primary method for calculating
   utilization data and populating the global temporary
   tables with the utilization data that would be
   shown in the table on the page

   This method also uses the package specific
   global variables for utilization calculation.
   These variables were initialized in the above
   API for populating temporary table for data to
   be shown in the graph
 */
PROCEDURE PJI_POP_TABLE_UTILZ_DATA
(
	 p_person_id   		IN  NUMBER
	,p_period_id   		IN  NUMBER
	,p_period_type 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_org_id		NUMBER;
l_calendar_id 		NUMBER;
l_accnt_period_type	VARCHAR2(15);
l_sets_of_books_id	NUMBER;

BEGIN
	--Get the crucial parameters
	GET_PERIOD_DATA
	(
		 p_calendar_type	=> p_calendar_type
		,p_org_id		=> p_org_id
		,x_calendar_id		=> l_calendar_id
		,x_accnt_period_type	=> l_accnt_period_type
		,x_sets_of_books_id	=> l_sets_of_books_id
		,x_return_status        => x_return_status
		,x_msg_count            => x_msg_count
		,x_msg_data             => x_msg_data
	);

	SELECT
		min(sequence),
		max(sequence)
	INTO
		g_curr_yr_max_sequence,
		g_curr_yr_min_sequence
	FROM
	pji_time_mv pt
	WHERE year_id = g_curr_year_id
	and calendar_id = l_calendar_id
	and period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_PERIOD', 'FII_TIME_CAL_PERIOD');

	--Populate the time tables
	IF (
		 g_last_summ_pd_seq > g_curr_yr_max_sequence
	   ) THEN
		--Call the API to populate time records
		--We do not need daily records in this case
		--as the last summarization date doesn't lie
		--in any of the periods that we are processing
		PJI_POP_SIMPLE_UTILZ_DATA
		(
			 p_calendar_id 		=> l_calendar_id
			,p_calendar_type	=> p_calendar_type
			,p_population_mode	=> 'TABLE'
			,p_table_amount_type	=> 1
			,x_return_status        => x_return_status
			,x_msg_count            => x_msg_count
			,x_msg_data             => x_msg_data
		);
	ELSE
		PJI_POP_COMPLEX_UTILZ_DATA
		(
			 p_calendar_id 		=> l_calendar_id
			,p_calendar_type	=> p_calendar_type
			,p_population_mode	=> 'TABLE'
			,p_org_id		=> p_org_id
			,x_return_status        => x_return_status
			,x_msg_count            => x_msg_count
			,x_msg_data             => x_msg_data
		);
	END IF;

        --Calculate expected utilization and put it
        --in the global temporary table

	 DELETE FROM PJI_RES_UTILZ_TMP3;

	 INSERT INTO PJI_RES_UTILZ_TMP3
	   (
		   period,
		   actual_utilization,
		   sched_utilization,
		   expected_utilization,
		   prior_yr_utilization,
		   sequence
       	   )
	 SELECT r1.period_name 			as period,
	 	round(SUM(r1.actual_utilz) * 100,2) 	as actual_utilization,
	 	round(SUM(r1.sched_utilz) * 100,2) 	as sched_utilization,
	 	round(SUM(r1.exp_utilz) * 100,2) 	as expected_utilization,
	 	round(SUM(r1.prev_yr_utilz) * 100,2) 	as prior_yr_utilization,
	   	r1.id 				as sequence
	 FROM
	 (
		 SELECT pmv.name as period_name,
			SUM(total_wtd_res_hrs_a)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a)),
							       0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a))) as actual_utilz,
			SUM(CONF_WTD_RES_HRS_S)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_s, cur2.conf_hrs_s)),
							       0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_s, cur2.conf_hrs_s))) as sched_utilz,
			SUM(DECODE(pmv.amount_type,1, total_wtd_res_hrs_a,CONF_WTD_RES_HRS_S))/DECODE(SUM(DECODE(g_calc_mthd,
						'CAPACITY',cur2.capacity_hrs - DECODE(pmv.amount_type,1,cur2.reduce_capacity_hrs_a,cur2.reduce_capacity_hrs_s),
								DECODE(pmv.amount_type,1, cur2.total_hrs_a, cur2.conf_hrs_s))),
						0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs -
							DECODE(pmv.amount_type,1,cur2.reduce_capacity_hrs_a,cur2.reduce_capacity_hrs_s),
							DECODE(pmv.amount_type,1, cur2.total_hrs_a, cur2.conf_hrs_s)))) as exp_utilz,
			0 as prev_yr_utilz,
			pmv.order_by_id as id
		FROM    pji_rm_res_f cur2, PJI_PMV_TIME_DIM_TMP pmv
		WHERE   person_id = p_person_id
			and pmv.period_type = cur2.period_type_id
			and pmv.calendar_type = cur2.calendar_type
			and pmv.id = cur2.time_id
			and pmv.id is not null
			group by pmv.name, pmv.order_by_id
		UNION ALL
		SELECT  pmv.name as period_name,
			0 as actual_utilz,
			0 as sched_utilz,
			0 as exp_utilz,
			SUM(total_wtd_res_hrs_a)/DECODE(SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a)),
						 0, null,SUM(DECODE(g_calc_mthd,'CAPACITY',cur2.capacity_hrs - cur2.reduce_capacity_hrs_a, cur2.total_hrs_a))) as prev_yr_utilz,
			pmv.order_by_id as id
			from pji_rm_res_f cur2, PJI_PMV_TIME_DIM_TMP pmv
			where person_id = p_person_id
			and pmv.period_type = cur2.period_type_id
			and pmv.calendar_type = cur2.calendar_type
			and pmv.prior_id = cur2.time_id
			and pmv.prior_id is not null
			group by pmv.name, pmv.order_by_id
	) r1
	group by r1.period_name, r1.id;

END PJI_POP_TABLE_UTILZ_DATA;

/* This method is used to populate the periods
   that are shown to the user for selection on
   the Personal Resource Utilization Page.

   The periods are populated in a global temporary
   table, and based on whether it is a PA period or
   a GL/Enterprise period, the data is shown on the
   page either in a LOV or a pop list respectively
   */
PROCEDURE PJI_POPULATE_PERIODS
(
	 p_period_type_id	IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
        ,p_period_id		IN  NUMBER
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_calendar_id 		NUMBER;
l_accnt_period_type	VARCHAR2(15);
l_sets_of_books_id	NUMBER;
l_sequence		NUMBER;
l_application_id	NUMBER;
l_period_id_tbl		N_TYPE_TAB;
l_period_name_tbl	V_TYPE_TAB;
l_period_status_tbl	V_TYPE_TAB;
l_period_st_dt_tbl	N_TYPE_TAB;
BEGIN
	DELETE FROM PJI_RES_UTILZ_TMP1;
	--fnd_global.apps_initialize(1319, 55211, 1292);

		IF (p_calendar_type = 'G') THEN
			SELECT pa_period_process_pkg.application_id
			INTO l_application_id
			FROM dual;
		ELSIF (p_calendar_type = 'P') THEN
			SELECT application_id
			INTO l_application_id
			FROM fnd_application
			WHERE application_short_name = 'PA';
		END IF;

		GET_PERIOD_DATA
		(
		         p_calendar_type	=> p_calendar_type
			,p_org_id		=> p_org_id
		        ,x_calendar_id		=> l_calendar_id
		        ,x_accnt_period_type	=> l_accnt_period_type
		        ,x_sets_of_books_id	=> l_sets_of_books_id
		        ,x_return_status        => x_return_status
			,x_msg_count            => x_msg_count
		        ,x_msg_data             => x_msg_data
		);

		--Get the sequence for the year
		SELECT sequence
		INTO l_sequence
		FROM pji_time_mv
	        WHERE
	        period_type = DECODE(p_calendar_type,'E','FII_TIME_ENT_YEAR', 'FII_TIME_CAL_YEAR')
	        AND calendar_id = l_calendar_id
	        and year_id in
	        (
		   SELECT year_id
		   FROM pji_time_mv
		   WHERE period_id = p_period_id
		   AND calendar_id = l_calendar_id
		);

		--Get the period id and names (with status)

		IF (	p_calendar_type = 'E') THEN
			--Get for Enterprise period
			--No status for enterprise period because
			--it is a period used for reporting and
			--not accounting or transaction
			  SELECT period_id,
			  	 period_name,
			  	 null,
			  	 to_char(period_start_date,'j')
			  BULK COLLECT INTO
			  	 l_period_id_tbl,
			  	 l_period_name_tbl,
			  	 l_period_status_tbl,
			  	 l_period_st_dt_tbl
			  FROM pji_time_mv
			  WHERE calendar_id = l_calendar_id
			  and period_type = 'FII_TIME_ENT_PERIOD'
			  and year_id in
			  (
				  SELECT year_id
				  FROM pji_time_mv
				  WHERE period_type = 'FII_TIME_ENT_YEAR'
				  and calendar_id = l_calendar_id
				  and sequence in
					(l_sequence-1,l_sequence,l_sequence+1)
			  )
			  ORDER BY period_start_date;
		ELSE
			--Get for PA/GL period
			  SELECT r1.period_id,
				 r1.period_name,
				 r2.show_status,
				 to_char(r1.period_start_date,'j')
			  BULK COLLECT INTO
			  	 l_period_id_tbl,
			  	 l_period_name_tbl,
			  	 l_period_status_tbl,
			  	 l_period_st_dt_tbl
			  FROM
			  (
				  SELECT period_id,
				  	 period_name,
				  	 period_start_date
				  FROM pji_time_mv
				  WHERE calendar_id = l_calendar_id
				  and period_type = 'FII_TIME_CAL_PERIOD'
				  and year_id in
				  (
					  SELECT year_id
					  FROM pji_time_mv
					  WHERE period_type = 'FII_TIME_CAL_YEAR'
					  and calendar_id = l_calendar_id
					  and sequence in
					  	(l_sequence-1,l_sequence,l_sequence+1)
				  )
			  ) r1, gl_period_statuses_v r2
			  where r2.period_type = l_accnt_period_type
			  and r2.set_of_books_id = l_sets_of_books_id
			  and r2.application_id = l_application_id
			  and r1.period_name = r2.period_name
			  ORDER BY r1.period_start_date;
		END IF;

		FORALL k IN 1.. l_period_id_tbl.count
			INSERT INTO PJI_RES_UTILZ_TMP1
			(
			       period_id,
			       period_name,
			       period_status,
			       period_start_date
	        	)
			VALUES
			(
				l_period_id_tbl(k),
				l_period_name_tbl(k),
				l_period_status_tbl(k),
				l_period_st_dt_tbl(k)
			);

END PJI_POPULATE_PERIODS;

/*
  This API is called from the page to get
  all the relevant initialization parameters
  that are needed to determine the business
  flow and hide/show regions and items on the
  page. This is the initialization API that is
  called from the Page
  */

PROCEDURE PJI_GET_PERIOD_PROFILE_DATA
(
         p_org_id	 IN  NUMBER
	,x_period_type_id OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_calendar_type OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_person_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_period_type	 OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_curr_period_id OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_curr_period_name OUT NOCOPY /* file.sql.39 change */ VARCHAR2
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_pa_res_util_def_pd_types	 VARCHAR2(30);
l_user_id   			 NUMBER := FND_GLOBAL.USER_ID;
l_calendar_id 			 NUMBER;
l_accnt_period_type		 VARCHAR2(15);
l_sets_of_books_id		 NUMBER;
l_msg_index_out                  NUMBER; -- -- Bug Ref : 7010273
BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       --Get the site level profile option of the user
       SELECT fnd_profile.value('PA_RES_UTIL_DEF_PERIOD_TYPE')
       INTO l_pa_res_util_def_pd_types
       FROM dual;

       IF (l_pa_res_util_def_pd_types = 'GL') THEN
       		x_period_type_id := 32;
       		x_calendar_type  := 'G';
       END IF;

       IF (l_pa_res_util_def_pd_types = 'PA') THEN
		x_period_type_id := 32;
		x_calendar_type  := 'P';
       END IF;

       IF (l_pa_res_util_def_pd_types = 'GE') THEN
       		x_period_type_id := 32;
       		x_calendar_type  := 'E';
       END IF;

       IF (p_org_id IS NULL) THEN
       		PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PJI',
                                      p_msg_name       => 'PJI_MO_PROFILE_OPTION_NOT_FND');
		x_return_status := FND_API.G_RET_STS_ERROR;
		RETURN;
       END IF;

       --Get the resource id
       SELECT employee_id
       INTO x_person_id
       FROM fnd_user
       WHERE user_id = l_user_id;

       --Get the period type profile option name
       SELECT meaning
       INTO x_period_type
       FROM pa_lookups
       WHERE 	lookup_type = 'PA_RES_UTIL_DEF_PERIOD_TYPES'
		and lookup_code = l_pa_res_util_def_pd_types;

       --Get the current period id
       --First get the calendar_id
        GET_PERIOD_DATA
	(
		 p_calendar_type	=> x_calendar_type
		,p_org_id		=> p_org_id
		,x_calendar_id		=> l_calendar_id
		,x_accnt_period_type	=> l_accnt_period_type
		,x_sets_of_books_id	=> l_sets_of_books_id
		,x_return_status        => x_return_status
		,x_msg_count            => x_msg_count
		,x_msg_data             => x_msg_data
	);

	--Bug5872158 Make sure SYSDATE is lesser than or equal to the maximum period end date in pji_time_mv
	IF (	x_calendar_type = 'E') THEN
		--Get for Enterprise period
		  SELECT period_id,
			 period_name
		  INTO x_curr_period_id,
		       x_curr_period_name
		  FROM pji_time_mv
		  WHERE
		  (SELECT DECODE(SIGN(TRUNC(SYSDATE) - MAX(period_end_date)), 1, MAX(period_end_date), TRUNC(SYSDATE))
		  FROM pji_time_mv
		  WHERE 1=1
		  AND calendar_id = l_calendar_id
		  AND period_type = 'FII_TIME_ENT_PERIOD') BETWEEN period_start_date and period_end_date
		  AND calendar_id = l_calendar_id
		  AND period_type = 'FII_TIME_ENT_PERIOD';
	ELSIF (	 x_calendar_type = 'G') THEN           --Bug Fix 8284858
		--Get for GL period
		  SELECT period_id,
		  	 period_name
		  INTO x_curr_period_id,
		       x_curr_period_name
		  FROM pji_time_mv
		  WHERE
		  (SELECT DECODE(SIGN(TRUNC(SYSDATE) - MAX(period_end_date)), 1, MAX(period_end_date), TRUNC(SYSDATE))
		  FROM pji_time_mv
		  WHERE 1=1
		  AND calendar_id = l_calendar_id
		  AND period_type = 'FII_TIME_CAL_PERIOD') BETWEEN period_start_date and period_end_date
		  AND calendar_id = l_calendar_id
		  AND period_type = 'FII_TIME_CAL_PERIOD';
       ELSIF (	x_calendar_type = 'P') THEN          --Added for Bug Fix 8284858
		--Get for PA period
		  SELECT period_id,
		  	 period_name
		  INTO x_curr_period_id,
		       x_curr_period_name
		  FROM pji_time_mv
		  WHERE
		  (SELECT DECODE(SIGN(TRUNC(SYSDATE) - MAX(period_end_date)), 1, MAX(period_end_date), TRUNC(SYSDATE))
		  FROM pji_time_mv
		  WHERE 1=1
		  AND calendar_id = l_calendar_id
		  AND period_type = 'FII_TIME_PA_PERIOD') BETWEEN period_start_date and period_end_date
		  AND calendar_id = l_calendar_id
		  AND period_type = 'FII_TIME_PA_PERIOD';
	END IF;
   -- Bug Ref : 7010273
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SU_INFO_MISSING');
       x_msg_count :=  FND_MSG_PUB.Count_Msg;
       IF ( x_msg_count > 0 ) THEN
        PA_INTERFACE_UTILS_PUB.GET_MESSAGES ( p_encoded       => FND_API.G_TRUE
                                             ,p_msg_index     => 1
                                             ,p_data          => x_msg_data
                                             ,p_msg_index_out => l_msg_index_out );
       END IF;
END PJI_GET_PERIOD_PROFILE_DATA;

/* This API provides a single point of contact
   that is called from the page to populate
   all kind of utilization data in global temporary
   tables.

   This API calls the driver APIs to populate data
   in global temporary tables, that would be used
   by graph, table and period pop list / LOV on the
   Personal Resource Utilization Page
   */
PROCEDURE PJI_POP_UTILIZATION_DATA
(
	 p_person_id		IN NUMBER
	,p_period_id   		IN  NUMBER
	,p_period_type 		IN  NUMBER
        ,p_calendar_type	IN  VARCHAR2
	,p_org_id		IN  NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       --Call the API to populate the table PJI_RES_UTILZ_TMP1

      PJI_POPULATE_PERIODS
      (
      	 p_period_type_id 	=> p_period_type
      	,p_calendar_type 	=> p_calendar_type
      	,p_period_id		=> p_period_id
	,p_org_id		=> p_org_id
      	,x_return_status        => x_return_status
	,x_msg_count            => x_msg_count
	,x_msg_data             => x_msg_data
      );

       --Call the API to populate the table PJI_RES_UTILZ_TMP2
       PJI_POP_GRAPH_UTILZ_DATA
       (
       		 p_person_id 		=> p_person_id
       		,p_period_id 		=> p_period_id
       		,p_period_type 		=> p_period_type
       		,p_calendar_type 	=> p_calendar_type
		,p_org_id		=> p_org_id
       		,x_return_status        => x_return_status
		,x_msg_count            => x_msg_count
		,x_msg_data             => x_msg_data
       );

       --Call the API to populate the table PJI_RES_UTILZ_TMP3
       PJI_POP_TABLE_UTILZ_DATA
       (
		 p_person_id 		=> p_person_id
		,p_period_id 		=> p_period_id
		,p_period_type 		=> p_period_type
		,p_calendar_type 	=> p_calendar_type
		,p_org_id		=> p_org_id
		,x_return_status        => x_return_status
		,x_msg_count            => x_msg_count
		,x_msg_data             => x_msg_data
       );

       COMMIT;

EXCEPTION
	WHEN OTHERS THEN
		x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END PJI_POP_UTILIZATION_DATA;

PROCEDURE GET_PERSON_FROM_RES
(
         p_resource_id		IN  NUMBER
        ,x_person_id	 OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_return_status        OUT NOCOPY /* file.sql.39 change */ VARCHAR2
	,x_msg_count            OUT NOCOPY /* file.sql.39 change */ NUMBER
        ,x_msg_data             OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_msg_index_out                  NUMBER; -- Bug Ref : 7010273
BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       SELECT NVL(person_id,-1)
       INTO x_person_id
       FROM pa_resource_txn_attributes
       WHERE resource_id = p_resource_id;
-- Bug Ref : 7010273
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       PA_UTILS.ADD_MESSAGE( p_app_short_name => 'PA',
                             p_msg_name       => 'PA_SU_INFO_MISSING');
       x_msg_count :=  FND_MSG_PUB.Count_Msg;
       IF ( x_msg_count > 0 ) THEN
        PA_INTERFACE_UTILS_PUB.GET_MESSAGES ( p_encoded       => FND_API.G_TRUE
                                             ,p_msg_index     => 1
                                             ,p_data          => x_msg_data
                                             ,p_msg_index_out => l_msg_index_out );
       END IF;

END GET_PERSON_FROM_RES;

END PJI_RESOURCE_UTILZ;

/
