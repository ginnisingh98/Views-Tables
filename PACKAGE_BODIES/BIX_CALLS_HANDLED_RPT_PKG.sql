--------------------------------------------------------
--  DDL for Package Body BIX_CALLS_HANDLED_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_CALLS_HANDLED_RPT_PKG" AS
/*$Header: bixxrchb.pls 115.17 2001/10/10 15:56:18 pkm ship     $*/

g_session_id         NUMBER;
g_sysdate            DATE;
g_time_range         NUMBER;
g_parent             VARCHAR2(50);
g_agent_group        VARCHAR2(50);
g_period_ind         NUMBER;
g_from_date          DATE;
g_from_time          VARCHAR2(10);
g_to_date            DATE;
g_to_time            VARCHAR2(10);
g_sqlstmt            VARCHAR2(4000);
g_nls_date_format    VARCHAR2(50);


/* This procedure forms the SQL string to get either the total or detail information of an agent */
PROCEDURE form_rs_sqlstmt(p_total_row_ind IN BOOLEAN)
IS
BEGIN
  g_sqlstmt := NULL;

  /* Form the SQL string to insert the rows into the temp table */
  g_sqlstmt := '
    INSERT /*+ PARALLEL(tr,2) */ INTO bix_dm_report tr (
			    session_id
			 ,  report_code
			 ,  col3
			 ,  col4
			 ,  col5
			 ,  col6
			 ,  col7
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col13
			 ,  col14
			 ,  col15
			 ,  col16
			 ,  col17
			 ,  col18
			 ,  col20
			 ,  col22
			 ,  col23
			 ,  col24
			 ,  col25
			 ,  col26
			 ,  col27
			 ,  col28
			 ,  col30
			 ,  col32
			 ,  col34
			 ,  col36
			 ,  col38
			 ,  col40 )
  (SELECT /*+ PARALLEL(a,2) */
			   :session_id
			 , ''BIX_CALLS_HANDLED_RPT'' ';

  IF (p_total_row_ind = TRUE) THEN
    /* If we are processing total row , then col3 = 'p' || group_id to which agent belongs */
    /* || 'c' || agent_id || 'n' (used for drill down), col4 = agent name (which is        */
    /* displayed in the report) ; col5 = agent name || agent_id (used to sort rows)        */
    /* col7 = agent name (displayed in the graph)                                          */
    g_sqlstmt := g_sqlstmt ||
		    ' , ''p'' || mem.group_id || ''c'' || to_char(a.resource_id) || ''n''
			 , rsc.source_name
			 , rsc.source_name || to_char(a.resource_id)
			 , null
			 , rsc.source_name ';
  ELSE
    /* If we are processing detail row , then                                 */
    /* col5 = agent name || agent id || date or hour (used for sorting rows)  */
    /* col6 = date (if time range is 5) or hour (displayed in the report)     */
    /* col7 = agent name || date ot hour (displayed in the garph)             */
    g_sqlstmt := g_sqlstmt ||
		    ' , null
			 , null ';

    /* If the time range is day report the data by date else by time */
    IF (g_time_range = 5) THEN
      g_sqlstmt := g_sqlstmt ||
			     ', rsc.source_name || to_char(a.resource_id) || to_char(period_start_date,''yyyy/mm/dd'')
	                , to_char(period_start_date,''' || g_nls_date_format || ''')
	                , rsc.source_name|| '' '' || to_char(a.period_start_date,''' || g_nls_date_format || ''') ';
    ELSE
      g_sqlstmt := g_sqlstmt ||
			     ', rsc.source_name || to_char(a.resource_id) || period_start_time
	                , to_char(to_date(period_start_time,''hh24:mi''),''hh:miAM'')
	                , rsc.source_name || '' '' || to_char(to_date(period_start_time,''hh24:mi''),''hh:miAM'') ';
    END IF;


  END IF;

  /* Get the measures */
  g_sqlstmt := g_sqlstmt ||
               '  , bix_util_pkg.get_hrmiss_frmt(SUM(login_time))
		        , trunc(SUM(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)
					/ DECODE(SUM(login_time),0,1,SUM(login_time)) * 100,2)
		        , SUM(in_calls_handled)
                  , trunc(SUM(in_talk_time + in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time + in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)))
                  , trunc(SUM(in_talk_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)))
                  , trunc(SUM(in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)))
		        , trunc(SUM(available_time + in_talk_time + in_wrap_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
		        , SUM(out_calls_handled)
                  , trunc(SUM(out_talk_time + out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(out_talk_time + out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)))
                  , trunc(SUM(out_talk_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(out_talk_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)))
                  , trunc(SUM(out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)))
		        , trunc(SUM(available_time + out_talk_time + out_wrap_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
                  , trunc(SUM(available_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
                  , trunc(SUM(idle_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
                  , trunc(SUM(in_wrap_time + out_wrap_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
		        , bix_util_pkg.get_hrmiss_frmt(SUM(available_time + in_talk_time + out_talk_time
														 + in_wrap_time + out_wrap_time))
                  , trunc(SUM(in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)
                      / DECODE( SUM(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time),0,1,
                          SUM(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)) * 100,2) ';

  /* Fetch the data from the appropiate MV depending on the time range */
  /* g_time_range = 1 implies user wants data by 1/2 hour : get the data from summary table */
  /* g_time_range = 2 implies user wants data by 1 hour : get the data from 1 hour MV       */
  /* g_time_range = 3 implies user wants data by 2 hour : get the data from 2 hour MV       */
  /* g_time_range = 4 implies user wants data by 4 hour : get the data from 4 hour MV       */
  /* g_time_range = 5 implies user wants data by day : get the data from day MV             */
  IF (g_time_range = 1) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_call_sum a ';
  ELSIF (g_time_range = 2) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum1_mv a ';
  ELSIF (g_time_range = 3) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum2_mv a ';
  ELSIF (g_time_range = 4) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum4_mv a ';
  ELSE
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum_day_mv a ';
  END IF;

  /* If we are processing total row get all the agents belonging to the group from jtf_rs_group_members table */
  IF (p_total_row_ind = TRUE) THEN
	 g_sqlstmt := g_sqlstmt ||
				', jtf_rs_group_members mem
				 , jtf_rs_resource_extns rsc ';
  ELSE
	 g_sqlstmt := g_sqlstmt ||
				', jtf_rs_resource_extns rsc ';
  END IF;

  /* Add the filter condition for reporting period */
  g_sqlstmt := g_sqlstmt || 'WHERE period_start_date_time between :start_date and :end_date ';

  /* Add the appropiate join condition */
  IF (p_total_row_ind = TRUE) THEN
	 g_sqlstmt := g_sqlstmt ||
				 'AND mem.group_id = :group_id
				  AND mem.resource_id = rsc.resource_id
				  AND rsc.resource_id = a.resource_id ';
  ELSE
      g_sqlstmt := g_sqlstmt ||
				 'AND a.resource_id = :resource_id
				  AND rsc.resource_id = a.resource_id ';
  END IF;

  /* Add the appropiate GROUP BY clause */
  IF (p_total_row_ind = TRUE) THEN
    g_sqlstmt := g_sqlstmt || 'GROUP BY mem.group_id, a.resource_id, rsc.source_name)';
  ELSE
    IF (g_time_range = 5) THEN
      g_sqlstmt := g_sqlstmt || 'GROUP BY period_start_date, a.resource_id, rsc.source_name)';
    ELSE
      g_sqlstmt := g_sqlstmt || 'GROUP BY period_start_time, a.resource_id, rsc.source_name)';
    END IF;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END form_rs_sqlstmt;

/* This procedure forms the SQL string to get either the total or detail information of a group */
PROCEDURE form_group_sqlstmt(p_total_row_ind IN BOOLEAN)
IS
BEGIN
  g_sqlstmt := NULL;

  /* Form the SQL string to insert the rows into the temp table */
  g_sqlstmt := '
    INSERT /*+ PARALLEL(tr,2) */ INTO bix_dm_report tr (
			    session_id
			 ,  report_code
			 ,  col2
			 ,  col3
			 ,  col4
			 ,  col5
			 ,  col7
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col13
			 ,  col14
			 ,  col15
			 ,  col16
			 ,  col17
			 ,  col18
			 ,  col20
			 ,  col22
			 ,  col23
			 ,  col24
			 ,  col25
			 ,  col26
			 ,  col27
			 ,  col28
			 ,  col30
			 ,  col32
			 ,  col34
			 ,  col36
			 ,  col38
			 ,  col40 )
  (SELECT /*+ PARALLEL(a,2) */
			   :session_id
			 , ''BIX_CALLS_HANDLED_RPT'' ';

  IF (p_total_row_ind = TRUE) THEN
    /* If total row ; col2 = group name (displayed in the report) ; */
    /* col5 = group name || group id (used to sort rows)            */
    /* col7 = group name (displayed in the graph)                   */
    g_sqlstmt := g_sqlstmt ||
		    ' , grp.group_name
		      , null
			 , null
			 , grp.group_name || to_char(grp.group_id)
			 , grp.group_name ';
  ELSE
    /* If detail rows ; col3 = 'p' || group_id (used for drill down) ; col4 = group  */
    /* name (displayed in the report) ; col5 = group name || group id (to sort rows) */
    /* col7 = group name (displayed in the graph)                                    */
    g_sqlstmt := g_sqlstmt ||
		    ' , null
		      , ''p'' || a.group_id
			 , grp.group_name
			 , grp.group_name || to_char(dnm.group_id)
	           , grp.group_name ';
  END IF;

  /* Get the measures */
  g_sqlstmt := g_sqlstmt ||
               '  , bix_util_pkg.get_hrmiss_frmt(SUM(login_time))
		        , trunc(SUM(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)
					/ DECODE(SUM(login_time),0,1,SUM(login_time)) * 100,2)
		        , SUM(in_calls_handled)
                  , trunc(SUM(in_talk_time + in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time + in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)))
                  , trunc(SUM(in_talk_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)))
                  , trunc(SUM(in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(in_wrap_time)
					  / DECODE(SUM(in_calls_handled),0,1,SUM(in_calls_handled)))
		        , trunc(SUM(available_time + in_talk_time + in_wrap_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
		        , SUM(out_calls_handled)
                  , trunc(SUM(out_talk_time + out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(out_talk_time + out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)))
                  , trunc(SUM(out_talk_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(out_talk_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)))
                  , trunc(SUM(out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)), 2)
                  , bix_util_pkg.get_hrmiss_frmt(SUM(out_wrap_time)
					  / DECODE(SUM(out_calls_handled),0,1,SUM(out_calls_handled)))
		        , trunc(SUM(available_time + out_talk_time + out_wrap_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
                  , trunc(SUM(available_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
                  , trunc(SUM(idle_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
                  , trunc(SUM(in_wrap_time + out_wrap_time)
					  / DECODE(SUM(login_time),0,1,SUM(login_time)) * 100, 2)
		        , bix_util_pkg.get_hrmiss_frmt(SUM(available_time + in_talk_time + out_talk_time
														 + in_wrap_time + out_wrap_time))
                  , trunc(SUM(in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)
                      / DECODE( SUM(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time),0,1,
                          SUM(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)) * 100,2) ';

  /* Fetch the data from the appropiate MV depending on the time range */
  /* g_time_range = 1 implies user wants data by 1/2 hour : get the data from summary table */
  /* g_time_range = 2 implies user wants data by 1 hour : get the data from 1 hour MV       */
  /* g_time_range = 3 implies user wants data by 2 hour : get the data from 2 hour MV       */
  /* g_time_range = 4 implies user wants data by 4 hour : get the data from 4 hour MV       */
  /* g_time_range = 5 implies user wants data by day : get the data from day MV             */
  IF (g_time_range = 1) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_call_sum a, jtf_rs_groups_vl grp ';
  ELSIF (g_time_range = 2) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum1_mv a, jtf_rs_groups_vl grp ';
  ELSIF (g_time_range = 3) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum2_mv a, jtf_rs_groups_vl grp ';
  ELSIF (g_time_range = 4) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum4_mv a, jtf_rs_groups_vl grp ';
  ELSE
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum_day_mv a, jtf_rs_groups_vl grp ';
  END IF;

  /* If detial row get the child groups from the denorm table */
  IF (p_total_row_ind = FALSE) THEN
    g_sqlstmt := g_sqlstmt ||
				', jtf_rs_groups_denorm dnm ';
  END IF;

  /* Add the filter condition for reporting period */
  g_sqlstmt := g_sqlstmt || 'WHERE period_start_date_time between :start_date and :end_date ';

  /* Add the appropiate join condition */
  IF (p_total_row_ind = FALSE) THEN
    g_sqlstmt := g_sqlstmt ||
				 'AND dnm.parent_group_id = :group_id
				  AND dnm.group_id = grp.group_id
				  AND dnm.immediate_parent_flag = ''Y''
				  AND a.group_id = grp.group_id ';
  ELSE
      g_sqlstmt := g_sqlstmt || 'AND a.group_id = :group_id
						   AND a.group_id = grp.group_id ';
  END IF;

  /* Add the appropiate GROUP BY clause */
  IF (p_total_row_ind = TRUE) THEN
    g_sqlstmt := g_sqlstmt || 'GROUP BY grp.group_id, grp.group_name)';
  ELSE
    g_sqlstmt := g_sqlstmt || 'GROUP BY dnm.group_id, a.group_id, grp.group_name)';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END form_group_sqlstmt;

/* This procedure form and execute the SQL statement to insert into */
/* BIX temp table all the detail rows of a resource                 */
PROCEDURE insert_rs_detail_temp_table(p_agent_id IN NUMBER)
IS
BEGIN

  /* Form and execute the SQL statement to insert into the temp table  */
  /* all the detail rows corresponding to the agent p_agent_id         */
  form_rs_sqlstmt(FALSE);
  EXECUTE IMMEDIATE g_sqlstmt USING g_session_id, g_from_date, g_to_date, p_agent_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_rs_detail_temp_table;

/* This procedure form and execute the SQL statement to   */
/* insert into BIX temp table the total row of a resource */
PROCEDURE insert_rs_total_temp_table(p_group_id IN NUMBER)
IS
BEGIN

  /* Form and execute the SQL statement to insert into the temp table one  */
  /* row for each of the agents which belong to the agent group p_group_id */
  form_rs_sqlstmt(TRUE);
  EXECUTE IMMEDIATE g_sqlstmt USING g_session_id, g_from_date, g_to_date, p_group_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_rs_total_temp_table;

/* This procedure form and execute the SQL statement to insert both */
/* the detail and total row for the agent group                     */
PROCEDURE insert_group_temp_table(p_group_id IN NUMBER)
IS
BEGIN

  /* Form and execute the SQL statement to insert into the temp table */
  /* the total row corresponding to the agent group "p_group_id"      */
  form_group_sqlstmt(TRUE);
  EXECUTE IMMEDIATE g_sqlstmt USING g_session_id, g_from_date, g_to_date, p_group_id;

  /* Form and execute the SQL statement to insert into the temp table one row for each */
  /* of the agent groups which are immediate children of the group p_group_id          */
  form_group_sqlstmt(FALSE);
  EXECUTE IMMEDIATE g_sqlstmt USING g_session_id, g_from_date, g_to_date, p_group_id;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_group_temp_table;

/* This procedure gets all the paramter values including pContext by parsing the string p_context */
PROCEDURE get_param_values(p_context IN VARCHAR2)
IS
  l_temp_date       DATE;
BEGIN

  /* Fetch the icx date format mask ; paramters from and to date is passed to the package in this format */
  g_nls_date_format  := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  /* Parse all the parameter values from the variable p_context : pContext (Drill down ID) , Agent Group */
  /* Site , Classification , Period Indicator , From date and Time , To Date and Time                    */
  g_parent         := bix_util_pkg.get_parameter_value(p_context, 'pContext');
  g_agent_group    := bix_util_pkg.get_parameter_value(p_context, 'P_AGENT_GROUP');
  g_period_ind     := TO_NUMBER(bix_util_pkg.get_parameter_value(p_context, 'P_PERIOD_IND'));
  g_from_date      := TO_DATE(bix_util_pkg.get_parameter_value(p_context, 'P_FROM_DATE'), g_nls_date_format);
  g_from_time      := bix_util_pkg.get_parameter_value(p_context, 'P_FROM_TIME');
  g_to_date        := TO_DATE(bix_util_pkg.get_parameter_value(p_context, 'P_TO_DATE'), g_nls_date_format);
  g_to_time        := bix_util_pkg.get_parameter_value(p_context, 'P_TO_TIME');

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
PROCEDURE populate(p_context IN VARCHAR2)
IS

 l_drill_down_ind    VARCHAR2(1);
 l_agent_id           NUMBER;
 l_group_id           NUMBER;

BEGIN

  /* Get the ICX Session Id */
  SELECT icx_sec.g_session_id
  INTO   g_session_id
  FROM   dual;

  /* Delete the rows from the table bix_dm_report for the current icx session and report  */
  /* so that we donot display the leftover rows from the previous execution of the report */
  DELETE bix_dm_report
  WHERE  report_code = 'BIX_CALLS_HANDLED_RPT'
  AND    session_id  = g_session_id;

  /* Fetch the sysdate */
  SELECT sysdate
  INTO   g_sysdate
  FROM   dual;

  /* Get the User preferred time range (1/2 or 1 or 2 or 4 hour or 1 day) */
  SELECT fnd_profile.value('BIX_DM_RPT_TIME_RANGE')
  INTO   g_time_range
  FROM   dual;

  /* If there is no user prefered time range , set it to 1/2 hour */
  IF g_time_range IS NULL THEN
    g_time_range := 1;
  END IF;

  /* Get all the parameter values by parsing the string p_context */
  get_param_values(p_context);

  /* If pContext is region_code , then the user has navigated to the report */
  /* from the report listing page ; so nothing should be displayed          */
  IF (g_parent = 'BIX_CALLS_HANDLED_RPT') THEN
    RETURN;
  END IF;

  /* g_parent = "not null" : User has navigated to the report either  from the bin or      */
  /*            by clicking the child column in the report which is hyperlinked            */
  /* g_agent_group = "not null" : User has navigated to the report from the parameter page */
  IF (g_parent IS NOT NULL) THEN
    SELECT TO_NUMBER(substr(g_parent, 2, decode(instr(g_parent,'c'), 0, length(g_parent), instr(g_parent,'c')-2)))
    INTO   l_group_id
    FROM   dual;
  ELSIF (g_agent_group IS NOT NULL) THEN
    l_group_id := TO_NUMBER(g_agent_group);
  ELSE
    RETURN;
  END IF;

  /* If the user has selected "All" for agent group paramter , display the default group of the user */
  IF (l_group_id = -999) THEN
    SELECT fnd_profile.value('BIX_DM_DEFAULT_GROUP')
    INTO   l_group_id
    FROM   dual;
  END IF;

  /* l_group_id = "null" : user has selected "All" as agent group paramter */
  /* and (s)he is not assigned to any default group                        */
  IF (l_group_id IS NULL) THEN
    RETURN;
  END IF;

  /* Process the agent group l_group_id and also which are immediate children of l_group_id */
  insert_group_temp_table(l_group_id);

  /* Process all the agents belonging to the group l_group_id */
  insert_rs_total_temp_table(l_group_id);

  /* Check if the user has clicked on an agent : if so we also have */
  /* to insert the detail rows of the agent into the temp table     */
  IF (instr(g_parent,'c') <> 0) THEN
    l_agent_id := TO_NUMBER(substr(g_parent, instr(g_parent, 'c')+1, length(g_parent) - (instr(g_parent,'c')+1)));
    l_drill_down_ind := substr(g_parent, length(g_parent), 1);

    /* l_drill_down_ind = 'n' : we have to display the detail rows of the agent */
    IF (l_drill_down_ind = 'n') THEN
	 /* Update the temp table so that next time the user clicked on the */
	 /* same agent we donot display the detail rows of the agent again  */
	 UPDATE bix_dm_report
	 SET col3          = 'p' || l_group_id || 'c' || to_char(l_agent_id) || 'y'
	 WHERE col3        = 'p' || l_group_id || 'c' || to_char(l_agent_id) || 'n'
	 AND   report_code = 'BIX_CALLS_HANDLED_RPT'
      AND   session_id  = g_session_id;

      /* Fetch the detail rows of data for the agent from the */
      /* summary table and insert them into bix temp table    */
      insert_rs_detail_temp_table(l_agent_id);
    END IF;
  END IF;

  commit;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END populate;

END BIX_CALLS_HANDLED_RPT_PKG;

/
