--------------------------------------------------------
--  DDL for Package Body BIX_CALLS_TYPE_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_CALLS_TYPE_RPT_PKG" AS
/*$Header: bixxrctb.pls 115.16 2001/09/27 10:42:45 pkm ship     $*/

g_session_id             NUMBER;
g_time_range             NUMBER;
g_site_id                NUMBER;
g_period_ind             NUMBER;
g_from_date              DATE;
g_from_time              VARCHAR2(10);
g_to_date                DATE;
g_to_time                VARCHAR2(10);
g_sqlstmt                VARCHAR2(4000);
g_sysdate                DATE;
g_classification_param   VARCHAR2(50);
g_classification_parent  VARCHAR2(50);
g_null_desc              VARCHAR2(50);
g_nls_date_format        VARCHAR2(50);

/* This procedure forms the SQL statement to process both the total and detail row of a classification */
PROCEDURE form_sqlstmt(p_total_row_ind     IN BOOLEAN,
				   p_classification_id IN NUMBER) IS
BEGIN

  g_sqlstmt := NULL;

  /* Form the SQL string to insert the rows into the temp table */
  g_sqlstmt := '
    INSERT /*+ PARALLEL(tr,2) */ INTO bix_dm_report tr (
			   session_id
			 , report_code
			 , col1
			 , col2
			 , col3
			 , col4
			 , col5
			 , col6
			 , col8
			 , col10
			 , col12
			 , col14
			 , col16
			 , col18
			 , col20
			 , col22
			 , col24
			 , col26
			 , col28
			 , col30 )
    (SELECT /*+ PARALLEL(a,2) */
			     :session_id
			   , ''BIX_CALLS_TYPE_RPT'' ';

  /* If detail row                                                            */
  /* col3 : classification_id || period_start_date (used for sorting)         */
  /* col4 : period start date (displayed in the report)                       */
  /* col5 : classification desc || period_start_date (displayed in the graph) */
  IF (p_total_row_ind = FALSE) THEN
    g_sqlstmt :=  g_sqlstmt ||
				', null
				 , null ';

    /* If the time range is day report the data by date else by time */
    IF (g_time_range = 5) THEN
      g_sqlstmt := g_sqlstmt ||
			     ', nvl(to_char(a.classification_id),''-999'') || to_char(a.period_start_date,''yyyy/mm/dd'')
	                , to_char(period_start_date,''' || g_nls_date_format || ''')
	                , nvl(b.classification,:null_desc) || '' '' ||
						to_char(a.period_start_date,''' || g_nls_date_format || ''') ';
    ELSE
      g_sqlstmt := g_sqlstmt ||
			     ', nvl(to_char(a.classification_id),''-999'') || to_char(a.period_start_time)
	                , to_char(to_date(a.period_start_time,''hh24:mi''),''hh:miAM'')
	                , nvl(b.classification,:null_desc) || '' ''
								   || to_char(to_date(a.period_start_time,''hh24:mi''),''hh:miAM'') ';
    END IF;

  ELSE
  /* If detail row                                               */
  /* col1 : classification_id || 'y' (Used for drill down)       */
  /* col2 : classification description (displayed in the report) */
  /* col3 : classification_id (used for sorting)                 */
  /* col5 : classification desc (displayed in the graph)         */
    g_sqlstmt :=  g_sqlstmt ||
				', nvl(to_char(a.classification_id),''-999'') || ''y''
				 , nvl(b.classification,:null_desc)
			      , nvl(to_char(a.classification_id),''-999'')
			      , null
			      , nvl(b.classification,:null_desc) ';
  END IF;

  /* Get the measures */
  g_sqlstmt := g_sqlstmt ||
		    ' , trunc((SUM(calls_answrd_within_x_time)
						    / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled))) * 100, 2)
			 , SUM(calls_answrd_within_x_time)
			 , bix_util_pkg.get_hrmiss_frmt(SUM(queue_time)
					 / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)))
                , bix_util_pkg.get_hrmiss_frmt(MAX(max_queue_time))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(abandon_time)
					 / DECODE(SUM(calls_abandoned),0,1,SUM(calls_abandoned)))
                , bix_util_pkg.get_hrmiss_frmt(MAX(max_abandon_time))
                , bix_util_pkg.get_hrmiss_frmt(SUM(ivr_time + available_time + in_talk_time + out_talk_time +
				 in_wrap_time + out_wrap_time) / DECODE(SUM(in_calls_handled + out_calls_handled),0,1,
					    SUM(in_calls_handled + out_calls_handled)))
			 , SUM(calls_offered)
			 , SUM(in_calls_handled + out_calls_handled)
			 , SUM(calls_abandoned)
			 , SUM(calls_transfered)
			 , SUM(primary_count)
			 , trunc(SUM(primary_count)
				    / DECODE(SUM(primary_count + other_count), 0, 1, SUM(primary_count + other_count)) * 100, 2) ';

  /* Fetch the data from the appropiate MV depending on the time range                      */
  /* g_time_range = 1 implies user wants data by 1/2 hour : get the data from summary table */
  /* g_time_range = 2 implies user wants data by 1 hour : get the data from 1 hour MV       */
  /* g_time_range = 3 implies user wants data by 2 hour : get the data from 2 hour MV       */
  /* g_time_range = 4 implies user wants data by 4 hour : get the data from 4 hour MV       */
  /* g_time_range = 5 implies user wants data by day : get the data from day MV             */
  IF (g_time_range = 1) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_call_sum a, cct_classifications b ';
  ELSIF (g_time_range = 2) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum1_mv a, cct_classifications b ';
  ELSIF (g_time_range = 3) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum2_mv a, cct_classifications b ';
  ELSIF (g_time_range = 4) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum4_mv a, cct_classifications b ';
  ELSE
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum_day_mv a, cct_classifications b ';
  END IF;

  /* Add the join condition ot the classification master table              */
  /* Outer join is necessary to get the rows which have null classification */
  IF (p_classification_id = -999) THEN
    g_sqlstmt := g_sqlstmt || 'WHERE a.classification_id = b.classification_id(+)
				   AND   :classification_id = -999 ';
    IF (p_total_row_ind = FALSE) THEN
	 /* This is necessary to get the detail rows of null classification */
      g_sqlstmt := g_sqlstmt || 'AND a.classification_id IS NULL ';
    END IF;
  ELSE
    g_sqlstmt := g_sqlstmt || 'WHERE a.classification_id = b.classification_id
						   AND   a.classification_id = :classification_id ';
  END IF;

  /* Apply the filter condition for reporting period */
  g_sqlstmt := g_sqlstmt || 'AND a.period_start_date_time between :start_date and :end_date ';

  /* Add the filer condition for site if the user has chosen */
  /* a particular value for site (or all) in the parameter   */
  IF (g_site_id <> -999) THEN
    g_sqlstmt := g_sqlstmt || 'AND a.server_group_id = :site_id ';
  ELSE
    g_sqlstmt := g_sqlstmt || 'AND :site_id = -999 ';
  END IF;

  /* Concatenate the appropiate group by clause */
  IF (p_total_row_ind = FALSE) THEN
    IF (g_time_range = 5) THEN
      g_sqlstmt := g_sqlstmt || 'GROUP BY a.classification_id, b.classification, a.period_start_date)';
    ELSE
      g_sqlstmt := g_sqlstmt || 'GROUP BY a.classification_id, b.classification, a.period_start_time)';
    END IF;
  ELSE
    g_sqlstmt := g_sqlstmt || 'GROUP BY a.classification_id, b.classification)';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END form_sqlstmt;

/* This procedure forms and executes the SQL statement that inserts the      */
/* detail rows corresponding o the classification in the table bix_dm_report */
PROCEDURE insert_detail_rows(p_classification_id IN NUMBER)
IS
BEGIN

  /* Form and execute the SQL statement to insert into the temp table        */
  /* the detail rows coreesponding to the classification p_classification_id */
  form_sqlstmt(FALSE, p_classification_id);
  EXECUTE IMMEDIATE g_sqlstmt USING g_session_id, g_null_desc, p_classification_id, g_from_date, g_to_date, g_site_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_detail_rows;

/* This procedure forms and executes the SQL statement that inserts the    */
/* total row corresponding o the classification in the table bix_dm_report */
PROCEDURE insert_total_rows(p_classification_id IN NUMBER)
IS
BEGIN

  /* Form and execute the SQL statement to insert into the temp table        */
  /* the total rows coreesponding to the classifications p_classification_id */
  form_sqlstmt(TRUE, p_classification_id);
  EXECUTE IMMEDIATE g_sqlstmt USING g_session_id, g_null_desc, g_null_desc, p_classification_id, g_from_date,
								 g_to_date, g_site_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_total_rows;


/* This procedure gets all the paramter values including pContext by parsing the string p_context */
PROCEDURE get_param_values(p_context IN VARCHAR2)
IS
  l_temp_date       DATE;
BEGIN

  /* Fetch the icx date format mask ; paramters from and to date is passed to the package in this format */
  g_nls_date_format  := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  /* Parse all the parameter values from the variable p_context : pContext (Drill down ID) , */
  /* Classification Site , Period Indicator , From date and Time , To Date and Time          */
  g_classification_parent := bix_util_pkg.get_parameter_value(p_context, 'pContext');
  g_classification_param  := bix_util_pkg.get_parameter_value(p_context, 'P_CLASSIFICATION');
  g_site_id               := nvl(TO_NUMBER(bix_util_pkg.get_parameter_value(p_context, 'P_SITE_ID')),-999);
  g_period_ind            := TO_NUMBER(bix_util_pkg.get_parameter_value(p_context, 'P_TIME_RANGE'));
  g_from_date             := TO_DATE(bix_util_pkg.get_parameter_value(p_context, 'P_START_DATE'), g_nls_date_format);
  g_from_time             := bix_util_pkg.get_parameter_value(p_context, 'P_FROM_TIME');
  g_to_date               := TO_DATE(bix_util_pkg.get_parameter_value(p_context, 'P_END_DATE'), g_nls_date_format);
  g_to_time               := bix_util_pkg.get_parameter_value(p_context, 'P_TO_TIME');

  /* Calculate the reporting period depending on the user input */
  IF (g_period_ind IS NULL) THEN
    /* If the period indicator is NULL then report on the maximum date for which data has been collected */
    SELECT MAX(period_start_date)
    INTO   l_temp_date
    FROM   bix_dm_agent_call_sum;

    g_from_date := to_date(to_char(l_temp_date, 'dd/mm/yyyy') || ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
    g_to_date := to_date(to_char(l_temp_date, 'dd/mm/yyyy') || ' 23:59:59','dd/mm/yyyy hh24:mi:ss');

  ELSIF (g_period_ind = 7) THEN
    /* Period Indicator = 7 indicates that user has selected today as reporting period */
    g_from_date := to_date(to_char(g_sysdate, 'dd/mm/yyyy') || ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
    g_to_date := to_date(to_char(g_sysdate, 'dd/mm/yyyy') || ' 23:59:59','dd/mm/yyyy hh24:mi:ss');

  ELSIF (g_period_ind = 8) THEN
    /* Period Indicator = 8 indicates that user has selected yesterday as reporting period */
    g_from_date := to_date(to_char(g_sysdate-1, 'dd/mm/yyyy') || ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
    g_to_date := to_date(to_char(g_sysdate-1, 'dd/mm/yyyy') || ' 23:59:59','dd/mm/yyyy hh24:mi:ss');

  ELSIF (g_period_ind = 9) THEN
    /* Period indicator = 9 indicates user has specified from date time and to date time */
    g_from_date := to_date(to_char(g_from_date,'dd/mm/yyyy ') || g_from_time, 'dd/mm/yyyy hh24');
    g_to_date := to_date(to_char(g_to_date,'dd/mm/yyyy ') || g_to_time, 'dd/mm/yyyy hh24');

  ELSE
    /* Period Indicator = 1 to 6 indicates Current Week , Prior Week , Current Month , Prior Month  */
    /* Current Year and Prior Year respectively ; get_time_range procedure will return appropiate   */
    /* g_from_date and g_to_date depending on the period indicator (g_period_ind)                   */
    bix_util_pkg.get_time_range(g_period_ind, g_from_date, g_to_date);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_param_values;


/* This procedure "populate" is the starting point of the package */
PROCEDURE populate(p_context IN VARCHAR2 DEFAULT NULL)
IS
 l_drill_down_ind    VARCHAR2(1);
 l_classification_id NUMBER;
BEGIN

  /* Get the ICX Session Id */
  SELECT icx_sec.g_session_id
  INTO   g_session_id
  FROM   dual;

  /* Delete the rows from the table bix_dm_report for the current icx session and report  */
  /* so that we donot display the leftover rows from the previous execution of the report */
  DELETE bix_dm_report
  WHERE  report_code = 'BIX_CALLS_TYPE_RPT'
  AND    session_id  = g_session_id;

  /* Fetch the sysdate into variable g_sysdate */
  SELECT sysdate
  INTO   g_sysdate
  FROM   dual;

  /* Get the description of NULL */
  g_null_desc := bix_util_pkg.get_null_lookup;

  /* Fetch the time range (1 hour or 2 hour etc. ) preference of the user */
  SELECT fnd_profile.value('BIX_DM_RPT_TIME_RANGE')
  INTO   g_time_range
  FROM   dual;

  /* If the user has not specified any time range then report on 1/2 hour basis */
  IF g_time_range IS NULL THEN
    g_time_range := 1;
  END IF;

  /* Get all the parameter values */
  get_param_values(p_context);

  /* If pContext is region_code , then the user has navigated to the report */
  /* from the report listing page ; so nothing should be displayed          */
  IF (g_classification_parent = 'BIX_CALLS_TYPE_RPT') THEN
    RETURN;
  END IF;

  /* Insert the total rows corresponding to the classification */
  IF (g_classification_param IS NOT NULL) THEN
    insert_total_rows(to_number(g_classification_param));
  ELSIF (g_classification_parent IS NOT NULL) THEN
    insert_total_rows(to_number(substr(g_classification_parent, 1, length(g_classification_parent)-1)));
  ELSE
    RETURN;
  END IF;

  /* Get the drill down indicator */
  l_drill_down_ind := substr(g_classification_parent, length(g_classification_parent), 1);

  /* l_drill_down_ind = 'y' : we have to display the detail rows of the classification */
  IF (l_drill_down_ind = 'y') THEN

    l_classification_id :=  to_number(substr(g_classification_parent, 1, length(g_classification_parent)-1));

    /* Update the temp table so that next time the user clicked on the */
    /* same classification we donot display the detail rows again      */
    UPDATE bix_dm_report
    SET col1 = to_char(l_classification_id) || 'n'
    WHERE col1 = to_char(l_classification_id) || 'y'
    AND   report_code = 'BIX_CALLS_TYPE_RPT'
    AND   session_id  = g_session_id;

    /* Fetch the detail rows of data for the classification from the */
    /* summary table and insert them into bix temp table             */
    insert_detail_rows(l_classification_id);
  END IF;

  commit;

EXCEPTION
    WHEN OTHERS THEN
      RAISE;
END populate;

END BIX_CALLS_TYPE_RPT_PKG;

/
