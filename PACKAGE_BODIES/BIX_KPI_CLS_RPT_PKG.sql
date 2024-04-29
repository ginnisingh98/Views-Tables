--------------------------------------------------------
--  DDL for Package Body BIX_KPI_CLS_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_KPI_CLS_RPT_PKG" AS
/*$Header: bixxkctb.pls 115.10 2001/09/27 10:42:42 pkm ship  $*/

g_sqlstmt          VARCHAR2(2000);   -- variable to store SQL query
g_date_format_mask VARCHAR2(50);     -- variable to store display date format

/*  This procedure gets the conversion rates between 2 currencies
    for the current system date.
*/
PROCEDURE get_exchange_rate( p_from_currency  IN VARCHAR2,
                             p_to_currency    IN VARCHAR2,
                             p_denom_rate    OUT NUMBER,
                             p_num_rate      OUT NUMBER )
IS
  l_conv_type    VARCHAR2(30);
  l_status       NUMBER;
BEGIN
   /* Get the BIX conversion type */
   SELECT fnd_profile.value('BIX_DM_CURR_CONVERSION_TYPE')
     INTO l_conv_type
     FROM dual;

   /* Get the exchange rate as per sysdate */
   bix_util_pkg.get_conversion_rate(p_from_currency, p_to_currency, sysdate,
                     l_conv_type, p_denom_rate, p_num_rate, l_status);
EXCEPTION
   WHEN OTHERS THEN
        RAISE;
END get_exchange_rate;


/*  This procedure forms the SQL statement for the given set of parameters.
The time range profile option indicates in what time range the data should
be displayed in the report. The codes for  the time range parameter are as
follows :
Time range code       Meaning
----------------------------------
 1                   half hour
 2                   one hour
 3                   two hours
 4                   four hours
 5                   one day
 -----------------------------------
*/
PROCEDURE form_sqlstmt(p_total_row_ind      IN BOOLEAN,
                       p_classification_id  IN NUMBER,
                       p_site_id            IN NUMBER )
IS
  l_time_range NUMBER;
  l_null_class_name VARCHAR2(50);
BEGIN
   g_sqlstmt := NULL;

   /* Fetch the time range (1 hour or 2 hour etc. ) preference of the user */
   SELECT fnd_profile.value('BIX_DM_RPT_TIME_RANGE')
     INTO l_time_range
     FROM dual;

   /* If the user has not specified any time range then
      report on 1/2 hour basis
   */
   IF l_time_range IS NULL THEN
      l_time_range := 1;
   END IF;

   /* Form the SQL string to insert the rows into the temp table.
      For null classifications, 'z99' was chosen as the default classifcation
      id so that it always appears as the last row in the report */
   g_sqlstmt := 'INSERT /*+ PARALLEL(tr,2) */ INTO BIX_DM_REPORT tr
	   ( session_id, report_code, col1, col2, col3, col4, col6, col8,
	   col10, col12, col14, col16, col18, col20, col22, col24,
	   col26, col28, col30 )
        (SELECT /*+ PARALLEL(a,2) */ :session_id, ''BIX_KPI_CLS_RPT'' ,
		          nvl(to_char(a.classification_id), ''z99'') || ''y'' ';

   /* If total row then insert classification description */
   /* if not then insert the time range                   */
   IF (p_total_row_ind = FALSE)
   THEN
       g_sqlstmt :=  g_sqlstmt || ', null ';

       /* If the time range is day report the data by date else by time */
       IF (l_time_range = 5)
       THEN
           g_sqlstmt := g_sqlstmt ||
		 ', to_char(a.period_start_date,''' || g_date_format_mask || ''')
            , to_char(a.period_start_date,''' || g_date_format_mask || ''')';
       ELSE
           g_sqlstmt := g_sqlstmt ||
				', a.period_start_time,
	 to_char(to_date(a.period_start_time,''hh24:mi''), ''hh:miAM'') ';
       END IF;
   ELSE
       /* Get the name for null classifications from lookup */
       l_null_class_name := bix_util_pkg.get_null_lookup;
       g_sqlstmt :=  g_sqlstmt || ', nvl(b.classification,''' ||
                     l_null_class_name || '''), null, null ';
   END IF;

   g_sqlstmt := g_sqlstmt || ' , bix_util_pkg.get_hrmiss_frmt(
                 DECODE( SUM(a.in_calls_handled + a.out_calls_handled), 0, 0,
                SUM(in_talk_time + out_talk_time)/
		SUM(a.in_calls_handled + a.out_calls_handled))) ,
                 bix_util_pkg.get_hrmiss_frmt(
	DECODE( SUM(a.in_calls_handled + a.out_calls_handled), 0, 0,
      SUM(a.in_wrap_time + a.out_wrap_time) /
		  SUM(a.in_calls_handled + a.out_calls_handled)))
                , SUM(a.in_calls_handld_gt_thn_x_time)
                , SUM(a.service_requests_created)
                , SUM(a.service_requests_opened)
                , SUM(a.service_requests_closed)
                , SUM(a.leads_created)
                , SUM(a.leads_updated)
       , to_char(SUM(DECODE(:user_currency, a.currency_code, a.leads_amount_txn,
                  ((a.leads_amount / :denom_rate) * :num_rate ))), :format_mask)
			 , SUM(a.opportunities_created)
			 , SUM(a.opportunities_updated)
			 , SUM(a.opportunities_won)
          , to_char(SUM(DECODE(:user_currency, a.currency_code,
			   a.opportunities_won_amount_txn,
  ((a.opportunities_won_amount / :denom_rate) * :num_rate ))), :format_mask) ';

    /* Fetch the data from the appropiate MV depending on the time range */
    IF (l_time_range = 1)
    THEN
        g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_call_sum a ';
    ELSIF (l_time_range = 2)
    THEN
        g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum1_mv a ';
    ELSIF (l_time_range = 3)
    THEN
        g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum2_mv a ';
    ELSIF (l_time_range = 4)
    THEN
        g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum4_mv a ';
    ELSE
        g_sqlstmt := g_sqlstmt || 'FROM bix_dm_agent_sum_day_mv a ';
    END IF;

    /* For total rows, we need to display the classification name.
       Hence we need to join to cct_classifications.
       If the user chooses ALL in the classification parameter(=-999),
       then we need to display the data for null classifications also.
       Hence the outer join. */
    IF p_total_row_ind = TRUE
    THEN
	g_sqlstmt := g_sqlstmt || ', cct_classifications b ';
        IF p_classification_id = -999
        THEN
            g_sqlstmt := g_sqlstmt ||
                        'WHERE a.classification_id = b.classification_id (+) ';
	    g_sqlstmt := g_sqlstmt || ' AND :classification_id  = -999 ';
        ELSE
            g_sqlstmt := g_sqlstmt ||
                        'WHERE a.classification_id = b.classification_id  ';
            g_sqlstmt := g_sqlstmt ||
                         ' AND a.classification_id = :classification_id';
        END IF;
    ELSE
        IF p_classification_id = -999
        THEN
            g_sqlstmt := g_sqlstmt ||
                        'WHERE a.classification_id IS NULL ';
	    g_sqlstmt := g_sqlstmt || ' AND :classification_id  = -999';
        ELSE
            g_sqlstmt := g_sqlstmt ||
                         ' WHERE a.classification_id = :classification_id';
        END IF;
    END IF;

    g_sqlstmt := g_sqlstmt || ' AND a.period_start_date_time between
                                    :start_date and :end_date ';

   /* Add the filer condition for site if the user has chosen
      a particular value for site in the parameter            */
    IF (p_site_id <> -999)
    THEN
	 g_sqlstmt := g_sqlstmt || ' AND a.server_group_id = :site_id ';
    ELSE
	 g_sqlstmt := g_sqlstmt || ' AND :site_id = -999 ';
    END IF;

    /* Concatenate the appropiate group by clause */
    /* Order by will be taken care of in AK       */
    IF (p_total_row_ind = FALSE)
    THEN
	 IF (l_time_range = 5)
	 THEN
              g_sqlstmt := g_sqlstmt || 'GROUP BY a.classification_id,
                             a.period_start_date)';
	 ELSE
              g_sqlstmt := g_sqlstmt || 'GROUP BY a.classification_id,
                             a.period_start_time)';
	 END IF;
    ELSE
         g_sqlstmt := g_sqlstmt || ' GROUP BY a.classification_id,
                            b.classification)';
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END form_sqlstmt;


/*  This procedure inserts data into the temp table.
*/
PROCEDURE insert_temp_table(p_total_row_ind     IN BOOLEAN,
                            p_session_id        IN NUMBER,
                            p_classification_id IN NUMBER,
                            p_site_id           IN NUMBER,
                            p_start_date        IN DATE,
                            p_end_date          In DATE,
                            p_user_currency     IN VARCHAR2,
                            p_denom_rate        IN NUMBER,
                            p_num_rate          In NUMBER )
IS
  l_format_mask VARCHAR2(50);
  logfile       UTL_FILE.file_type;
BEGIN
   /* Get the format mask for the user currency */
   l_format_mask := fnd_currency.get_format_mask(p_user_currency, 30);

   /* Form and execute the SQL statement to insert into the temp table  */
   /* all the rows coreesponding to the classifications user has chosen */
   form_sqlstmt(p_total_row_ind, p_classification_id, p_site_id);

   /* The following code is useful while debugging. Make sure that the
    UTL_FILE_DIR parameter from v$parameter is set to the /sqlcom/log
    directory. If not change the path in the fopen command below to
    point to the right directory

    logfile := UTL_FILE.fopen('/sqlcom/log', 'BIXKCLS.sql', 'w', 2000 );
    UTL_FILE.put_line( logfile, 'After fopen ' );
    UTL_FILE.put_line( logfile, 'Classification Id : ' ||
				   to_char(p_classification_id ) );
    UTL_FILE.put_line( logfile, 'Site ID : ' || to_char(p_site_id ) );
    UTL_FILE.put_line( logfile, 'Start date ' ||
	   to_char(p_start_date, 'DD/MM/YYYY HH24:MI:SS' ) );
    UTL_FILE.put_line(logfile,  'End date ' ||
	   to_char(p_end_date, 'DD/MM/YYYY HH24:MI:SS' ) );

    UTL_FILE.put_line(logfile, 'Length of sql statement is ' ||
						 length(g_sqlstmt) );
    UTL_FILE.put_line( logfile, g_sqlstmt );
    UTL_FILE.fclose(logfile);
   */
    EXECUTE IMMEDIATE g_sqlstmt USING p_session_id, p_user_currency,
           p_denom_rate, p_num_rate, l_format_mask, p_user_currency,
           p_denom_rate, p_num_rate, l_format_mask, p_classification_id,
           p_start_date, p_end_date, p_site_id;

EXCEPTION
  WHEN OTHERS THEN
       RAISE;
END insert_temp_table;

/* This procedure gets all the parameter values specified by the user.
The codes for  the period parameter are as follows :
Period code          Meaning
----------------------------------
 1                   This Week
 2                   Prior Week
 3                   Month to Date
 4                   Prior Month to Date
 5                   Year to Date
 6                   Prior Year to Date
 7                   Today
 8                   Yesterday
 9                   User specified period
 -----------------------------------
*/
PROCEDURE get_param_values(p_context IN VARCHAR2,
                           p_classification_parent OUT VARCHAR2,
		           p_classification_id  OUT NUMBER,
		           p_site_id            OUT NUMBER,
		           p_start_date         OUT DATE,
		           p_end_date           OUT DATE )
IS
  v_temp_date  DATE;
  l_sysdate    DATE;
  l_udef_start_date DATE;
  l_udef_end_date   DATE;
  l_udef_start_time VARCHAR2(10);
  l_udef_end_time   VARCHAR2(10);
  l_period_ind NUMBER;
  l_classification_id NUMBER;
  l_site_id           NUMBER;
  l_classification_parent  VARCHAR2(50);

BEGIN

  /* Fetch  the sysdate into variable l_sysdate */
  SELECT sysdate
  INTO   l_sysdate
  FROM   dual;


  /* Get the JTF profile date format from the Profile */
  g_date_format_mask  := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  /* Parse all the parameter values from the variable p_context */
  l_classification_parent := bix_util_pkg.get_parameter_value(
                                p_context, 'pContext');
  l_classification_id := TO_NUMBER(bix_util_pkg.get_parameter_value(
				p_context, 'P_CLASSIFICATION_ID'));
  l_site_id := TO_NUMBER(bix_util_pkg.get_parameter_value(
				p_context, 'P_SITE_ID'));
  l_period_ind := TO_NUMBER(bix_util_pkg.get_parameter_value(
				p_context, 'P_TIME_RANGE'));
  l_udef_start_date := TO_DATE(bix_util_pkg.get_parameter_value(
				p_context, 'P_START_DATE'),g_date_format_mask);
  l_udef_start_time := bix_util_pkg.get_parameter_value(
                                p_context, 'P_START_TIME');
  l_udef_end_date := TO_DATE(bix_util_pkg.get_parameter_value(
				p_context, 'P_END_DATE'), g_date_format_mask);

  l_udef_end_time := bix_util_pkg.get_parameter_value(p_context, 'P_END_TIME');

  /* Calculate the reporting period depending on the user input */
  IF (l_period_ind IS NULL)
  THEN
	SELECT MAX(period_start_date)
	  INTO v_temp_date
          FROM  bix_dm_agent_call_sum;

	p_start_date := to_date(to_char(v_temp_date, 'dd/mm/yyyy') ||
				   ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
	p_end_date := to_date(to_char(v_temp_date, 'dd/mm/yyyy') ||
				   ' 23:59:59','dd/mm/yyyy hh24:mi:ss');
   ELSIF (l_period_ind = 7)
   THEN
        p_start_date := to_date(to_char(l_sysdate, 'dd/mm/yyyy') ||
				   ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
        p_end_date := to_date(to_char(l_sysdate, 'dd/mm/yyyy') ||
				   ' 23:59:59','dd/mm/yyyy hh24:mi:ss');
   ELSIF (l_period_ind = 8)
   THEN
	 p_start_date := to_date(to_char(l_sysdate-1, 'dd/mm/yyyy') ||
				   ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
         p_end_date := to_date(to_char(l_sysdate-1, 'dd/mm/yyyy') ||
	                  ' 23:59:59','dd/mm/yyyy hh24:mi:ss');
   ELSIF (l_period_ind = 9)
   THEN
      p_start_date := to_date(to_char(l_udef_start_date,'dd/mm/yyyy ') ||
	                  l_udef_start_time, 'dd/mm/yyyy hh24');
	 p_end_date := to_date(to_char(l_udef_end_date,'dd/mm/yyyy ') ||
				   l_udef_end_time, 'dd/mm/yyyy hh24');
   ELSE
        bix_util_pkg.get_time_range(l_period_ind, p_start_date, p_end_date);
   END IF;

   p_classification_parent := l_classification_parent;
   p_classification_id := l_classification_id;
   p_site_id           := l_site_id;

EXCEPTION
   WHEN OTHERS THEN
        RAISE;
END get_param_values;


/*  This is the main procedure for this package.
*/
PROCEDURE populate(p_context IN VARCHAR2 DEFAULT NULL)
IS
  l_global_currency  VARCHAR2(15);
  l_user_currency    VARCHAR2(15);
  l_denom_rate   NUMBER := 1;
  l_num_rate     NUMBER := 1;
  l_classification_parent  VARCHAR2(50);
  l_classification_id NUMBER;
  l_site_id NUMBER;
  l_session_id NUMBER;
  l_start_date DATE;
  l_end_date DATE;
  l_total_row_ind  BOOLEAN;
  l_drill_down_ind  VARCHAR2(1);

BEGIN

  l_session_id := bix_util_pkg.get_icx_session_id;

  /* Delete the table for the current icx session and report  */
    DELETE from bix_dm_report
     WHERE report_code = 'BIX_KPI_CLS_RPT'
       AND session_id  = l_session_id;

  /* Get the BIX global currency */
  SELECT fnd_profile.value('BIX_DM_PREFERRED_CURRENCY')
  INTO   l_global_currency
  FROM   dual;

  /* Get the user currency */
  SELECT fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY')
  INTO   l_user_currency
  FROM   dual;

  IF l_user_currency <> l_global_currency
  THEN
     /* Get exchange rate from BIX global currency to user preferred currency */
      get_exchange_rate(l_global_currency, l_user_currency,
				    l_denom_rate, l_num_rate );
  END IF;

  /* Get all the parameter values */
  get_param_values(p_context, l_classification_parent, l_classification_id,
                           l_site_id, l_start_date, l_end_date );

  /* If pContext is region_code  and l_classification_id is null, then the
     user has navigated to the report from the report listing page.
     Don't show anything in report */
  IF (l_classification_parent = 'BIX_KPI_CLS_RPT')
  THEN
    IF l_classification_id IS NULL
    THEN
	    RETURN ;
    END IF;
    l_classification_parent := NULL;
  END IF;

  l_total_row_ind  :=  TRUE;

  /* Insert the total rows corresponding to the classification */
  insert_temp_table(l_total_row_ind, l_session_id, l_classification_id,
           l_site_id, l_start_date, l_end_date, l_user_currency,
		 l_denom_rate, l_num_rate );

  /* If user has clicked on a hyperlink  */
  IF l_classification_parent IS NOT NULL
  THEN
     /* Get the drill down indicator */
     l_drill_down_ind := substr(l_classification_parent,
                                 length(l_classification_parent), 1);

     /* If l_drill_down_ind = 'y' : we have to display the detail rows
	of the classification */
     IF (l_drill_down_ind = 'y')
     THEN
         /* If user has clicked on the null classification row, then set
          classification_id = -999 as classification_id is a number column */
         IF l_classification_parent = 'z99y'
         THEN
             l_classification_id := -999;
             UPDATE bix_dm_report
                SET col1 = 'z99n'
              WHERE col1 = 'z99y'
                AND report_code = 'BIX_KPI_CLS_RPT'
                AND session_id  = l_session_id;
         ELSE
             l_classification_id :=  to_number( substr(
                l_classification_parent, 1, length(l_classification_parent)-1));
             UPDATE bix_dm_report
                SET col1 = to_char(l_classification_id) || 'n'
              WHERE col1 = to_char(l_classification_id) || 'y'
                AND report_code = 'BIX_KPI_CLS_RPT'
                AND session_id  = l_session_id;
         END IF;

         /* Fetch the detail rows of data for the classification from the */
         /* summary table and insert them into bix temp table             */
 	 l_total_row_ind := FALSE;
         insert_temp_table( l_total_row_ind, l_session_id,
		  l_classification_id, l_site_id, l_start_date, l_end_date,
		  l_user_currency,l_denom_rate, l_num_rate );
     END IF;
  END IF;

EXCEPTION
    WHEN OTHERS THEN
         RAISE;
END populate;

END BIX_KPI_CLS_RPT_PKG;

/
