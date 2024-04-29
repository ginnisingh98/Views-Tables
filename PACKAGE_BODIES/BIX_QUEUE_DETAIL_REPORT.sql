--------------------------------------------------------
--  DDL for Package Body BIX_QUEUE_DETAIL_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_QUEUE_DETAIL_REPORT" AS
/*$Header: bixxrqdb.pls 115.31 2003/01/10 00:14:25 achanda ship $*/

g_time_range NUMBER;
g_session_id NUMBER;
g_classification_id NUMBER;
g_classification VARCHAR2(80);
g_null_desc VARCHAR2(80);
g_drilldown NUMBER;
/* inserts data into bix_dm_report table used for reporting */
/* called by populate(p_context) procedure                  */
PROCEDURE insert_temp_table(p_classification_id IN NUMBER,
                            p_site_id     IN NUMBER,
                            p_start_period IN DATE,
                            p_end_period   IN DATE)
IS
  l_index NUMBER;
 v_classification_id NUMBER;
 l_unclassified_count NUMBER;
 v_classification VARCHAR2(80);

  /* get all valid classifications for all calls */
  cursor get_classifications is
  select distinct c.classification_id, c.classification
  from   cct_classifications c, bix_dm_real_queue_sum b
  where   ((c.classification_id = p_classification_id) or (p_classification_id is null or p_classification_id = -999))
  and b.classification_id = c.classification_id;
  /*
  and ((c.server_group_id = p_site_id) or (p_site_id is null or p_site_id = -1));
*/

BEGIN

/* delete data from the previous runs */
delete bix_dm_report
where  session_id = g_session_id
and report_code = 'BIX_QUEUE_DETAIL_REPORT';

/* find how many calls have no classification */
select count(*)
into   l_unclassified_count
from   bix_dm_real_queue_sum
where  (classification_id is null or
         classification_id not in
	 (select distinct classification_id
	  from cct_classifications));

  l_index := 1;  /* used for ordering data for report */
  /* insert data for all classified calls for the given parameters */
  for classifications in get_classifications LOOP
	v_classification_id := classifications.classification_id;
     v_classification := classifications.classification;
	/* insert summary level data */
      INSERT INTO bix_dm_report(
			 report_code
                , session_id
			 ,  col1
			 ,  col2
			 ,  col3
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16)
      (SELECT
			 'BIX_QUEUE_DETAIL_REPORT'
                         , g_session_id
			 , 'c' || to_char(v_classification_id) || 'd' || '0'
			 , v_classification
			 , l_index
                ,  NULL
			 , decode(SUM(CALLS_OFFERED), NULL, 0, SUM(CALLS_OFFERED))
			 , decode(SUM(CALLS_ABANDONED), NULL, 0, SUM(CALLS_ABANDONED))
			 , decode(SUM(CALLS_ANSWRD_WITHIN_X_TIME), NULL, 0, SUM(CALLS_ANSWRD_WITHIN_X_TIME))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(ABANDON_TIME)/SUM(CALLS_ABANDONED))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(QUEUE_TIME_ANSWERED)/decode(SUM(calls_answered), 0, 1, SUM(calls_answered)))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(talk_time)/ DECODE(SUM(calls_handled),0,1,SUM(calls_handled)))
        from bix_dm_real_queue_sum
	   where classification_id = v_classification_id
	   and   session_id = g_session_id
	   and  period_start_date_time between p_start_period and p_end_period
  and ((server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999)));
  /* insert detailed rows into the bix_dm_report if drilldown clicked */
  if (g_classification_id <> -999 and g_drilldown = 0) THEN
      l_index := l_index + 1;
      INSERT INTO bix_dm_report(
			 report_code
                         , session_id
			 , col1
			 ,  col2
			 ,  col3
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16)
      (SELECT
			 'BIX_QUEUE_DETAIL_REPORT'
                         , g_session_id
			 , l_index
			 , null
			 , l_index
                , decode(g_time_range,1,to_char(to_date(period_start_time,'hh24:mi'), 'hh24:miAM'),
 2,to_char(to_date(substr(period_start_time,1,2),'hh24:mi'), 'hh24:miAM'),
    3,to_char(to_date(floor(substr(period_start_time,1,2) / 2) * 2, 'hh24:mi' ), 'hh24:miAM') ,
 4,to_char(to_date(floor(substr(period_start_time,1,2) / 4) * 4, 'hh24:mi'), 'hh24:miAM'), period_start_date_time)
			 , decode(sum(CALLS_OFFERED), NULL, 0, sum(CALLS_OFFERED))
			 , decode(sum(CALLS_ABANDONED), NULL, 0,sum(CALLS_ABANDONED))
			 , decode(sum(CALLS_ANSWRD_WITHIN_X_TIME), NULL, 0,sum(CALLS_ANSWRD_WITHIN_X_TIME))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(ABANDON_TIME)/SUM(CALLS_ABANDONED))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(QUEUE_TIME_ANSWERED)/decode(SUM(calls_answered), 0, 1, SUM(calls_answered)))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(talk_time)/ DECODE(SUM(calls_handled),0,1,SUM(calls_handled)))
        from bix_dm_real_queue_sum
	   where classification_id = v_classification_id
	   and   session_id = g_session_id
	   and   classification_id = g_classification_id
	   and  period_start_date_time between p_start_period and p_end_period
  and ((server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999))
             GROUP BY decode(g_time_range,1,to_char(to_date(period_start_time,'hh24:mi'), 'hh24:miAM'),
 2,to_char(to_date(substr(period_start_time,1,2),'hh24:mi'), 'hh24:miAM'),
    3,to_char(to_date(floor(substr(period_start_time,1,2) / 2) * 2, 'hh24:mi' ), 'hh24:miAM') ,
 4,to_char(to_date(floor(substr(period_start_time,1,2) / 4) * 4, 'hh24:mi'), 'hh24:miAM'), period_start_date_time));
		 /* update the drilldown to contract on click */
		 /* g_drilldown  = 1 implies contract         */
		 update bix_dm_report
		 set  col1 =  'c' || to_char(v_classification_id) || 'd' || '1'
		 where report_code  = 'BIX_QUEUE_DETAIL_REPORT'
		 and session_id = g_session_id
		 and  col2 = v_classification
		 and  v_classification = g_classification;
   END IF;
   l_index := l_index + 1;
   END LOOP;
   l_index := l_index + 1;

/* get data for unclassified calls */
IF (l_unclassified_count > 0) then
  /* insert summary level data into table only if no classification */
  /* is selected 									       */
  IF (p_classification_id = -999 or p_classification_id is NULL) then
      INSERT INTO bix_dm_report(
			 report_code
                , session_id
			 ,  col1
			 ,  col2
			 ,  col3
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16)
      (SELECT
			 'BIX_QUEUE_DETAIL_REPORT'
                , g_session_id
			 , 'c' || to_char(-9999) || 'd' || '0'
	--		 ,g_null_desc
			 ,'unClassified'
			 , l_index
                ,  NULL
			 , decode(SUM(CALLS_OFFERED), NULL, 0, SUM(CALLS_OFFERED))
			 , decode(SUM(CALLS_ABANDONED), NULL, 0, SUM(CALLS_ABANDONED))
			 , decode(SUM(CALLS_ANSWRD_WITHIN_X_TIME), NULL, 0, SUM(CALLS_ANSWRD_WITHIN_X_TIME))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(ABANDON_TIME)/SUM(CALLS_ABANDONED))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(QUEUE_TIME_ANSWERED)/decode(SUM(calls_answered), 0, 1, SUM(calls_answered)))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(talk_time)/ DECODE(SUM(calls_handled),0,1,SUM(calls_handled)))
        from bix_dm_real_queue_sum
        where ( classification_id is null or classification_id not in
		   (select distinct classification_id
		    from cct_classifications))
	   and  period_start_date_time between p_start_period and p_end_period
	   and   session_id = g_session_id
  and ((server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999)));
  end if; /* summary level data for unclassified calls */
  /* insert detailed rows for unclassified calls only if drilldown clicked */
  if ((g_classification_id = -9999 and g_drilldown = 0) and (p_classification_id = -999 or p_classification_id is null)) THEN
      l_index := l_index + 1;
      INSERT INTO bix_dm_report(
			 report_code
                , session_id
			 , col1
			 ,  col2
			 ,  col3
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16)
      (SELECT
			 'BIX_QUEUE_DETAIL_REPORT'
                , g_session_id
			 , l_index
			 , null
			 , l_index
                , decode(g_time_range,1,to_char(to_date(period_start_time,'hh24:mi'), 'hh24:miAM'),
 2,to_char(to_date(substr(period_start_time,1,2),'hh24:mi'), 'hh24:miAM'),
    3,to_char(to_date(floor(substr(period_start_time,1,2) / 2) * 2, 'hh24:mi' ), 'hh24:miAM') ,
 4,to_char(to_date(floor(substr(period_start_time,1,2) / 4) * 4, 'hh24:mi'), 'hh24:miAM'), period_start_date_time)
			 , decode(sum(CALLS_OFFERED), NULL, 0, sum(CALLS_OFFERED))
			 , decode(sum(CALLS_ABANDONED), NULL, 0,sum(CALLS_ABANDONED))
			 , decode(sum(CALLS_ANSWRD_WITHIN_X_TIME), NULL, 0,sum(CALLS_ANSWRD_WITHIN_X_TIME))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(ABANDON_TIME)/SUM(CALLS_ABANDONED))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(QUEUE_TIME_ANSWERED)/decode(SUM(calls_answered), 0, 1, SUM(calls_answered)))
			 ,bix_util_pkg.get_hrmiss_frmt(SUM(talk_time)/ DECODE(SUM(calls_handled),0,1,SUM(calls_handled)))
        from bix_dm_real_queue_sum
	   where (classification_id is null or classification_id not in
	       (select distinct classification_id
		   from cct_classifications))
        and session_id = g_session_id
	   and  period_start_date_time between p_start_period and p_end_period
  and ((server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999))
             GROUP BY decode(g_time_range,1,to_char(to_date(period_start_time,'hh24:mi'), 'hh24:miAM'),
 2,to_char(to_date(substr(period_start_time,1,2),'hh24:mi'), 'hh24:miAM'),
    3,to_char(to_date(floor(substr(period_start_time,1,2) / 2) * 2, 'hh24:mi' ), 'hh24:miAM') ,
 4,to_char(to_date(floor(substr(period_start_time,1,2) / 4) * 4, 'hh24:mi'), 'hh24:miAM'), period_start_date_time));
		 /* update the drilldown to contract on click */
		 /* g_drilldown  = 1 implies contract         */
		 update bix_dm_report
		 set  col1 =  'c' || to_char(-9999) || 'd' || '1'
		 where report_code  = 'BIX_QUEUE_DETAIL_REPORT'
		 and session_id = g_session_id
		 and  col2 = g_null_desc;
end if; /* detailed rows for unclassified calls */
end if; /* data for unclassified calls */

delete from bix_dm_real_queue_sum
where session_id = g_session_id;


END insert_temp_table;

/* invoked from the Queue Detail Report                */
/* parses all the report user parameters and calls     */
/* insert_temp_table procedure                         */
PROCEDURE populate(p_context IN VARCHAR2)
IS
v_classification_id NUMBER;
p_site_id NUMBER;
p_start_period DATE;
p_end_period DATE;
v_site_id NUMBER;
v_start_period DATE;
v_end_period DATE;
v_parent VARCHAR2(80);
l_nls_date_fmt VARCHAR2(80);
l_null_desc_count number;
BEGIN

  /* get reporting time range for detailed level data */
  SELECT fnd_profile.value('BIX_DM_RPT_TIME_RANGE')
  INTO   g_time_range
  FROM   dual;
  /* get label for un classified calls */
  select count(meaning)
  into   l_null_desc_count
  FROM   fnd_lookups
  WHERE  lookup_type = 'BIX_DM_NULL_DESC'
  AND    lookup_code = 'NULL';

  if (l_null_desc_count = 1) then
   SELECT meaning
   INTO   g_null_desc
   FROM   fnd_lookups
   WHERE  lookup_type = 'BIX_DM_NULL_DESC'
   AND    lookup_code = 'NULL';
  else
    g_null_desc := 'UNKNOWN';
  end if;


  g_drilldown := 0; /* drilldown default to yes */
  g_session_id := bix_util_pkg.get_icx_session_id; /* get current session id */
  BIX_DM_REAL_QUEUE_SUMMARY_PKG.get_calls(g_session_id);
  /* get the classification id for the clicked row or data */
  v_parent := jtfb_dcf.get_parameter_value(p_context, 'pContext');
  /* to make the report listing link work */
  if (v_parent = 'BIX_QUEUE_DETAIL_REPORT') then
	v_parent := 'NOT_FOUND';
  end if;
/* find if the classification was clicked in the report */
/* g_drilldown = 0 means the classification needs to be expanded, else */
/* collapsed */
	g_classification_id := -999;
  if (v_parent = 'NOT_FOUND') THEN
	g_classification_id := -999;
  else
	g_classification_id := to_number(substr(v_parent, 2, instr(v_parent, 'd')-2));
	if (g_classification_id <> -9999) then
	select classification_name
	into   g_classification
	from   bix_dm_classification_param_v
	where  to_number(classification_id) = g_classification_id;
	end if;
	g_drilldown := to_number(substr(v_parent, instr(v_parent, 'd')+ 1, 1));
  end if;
  IF g_time_range IS NULL THEN
    g_time_range := 1;
  END IF;
  /* retrieve the values for report user parameters */
  if (jtfb_dcf.get_parameter_value(p_context,'P_CLASSIFICATION_ID') = 'NOT_FOUND') THEN
    v_classification_id := -999;
  else
    v_classification_id :=  to_number(jtfb_dcf.get_parameter_value(p_context,'P_CLASSIFICATION_ID'));
  end if;
  if (jtfb_dcf.get_parameter_value(p_context,'P_SITE_ID') = 'NOT_FOUND') THEN
    v_site_id := -999;
  else
    v_site_id :=  to_number(jtfb_dcf.get_parameter_value(p_context,'P_SITE_ID'));
  end if;

  /* initialize data date range for today */
  v_start_period := trunc(sysdate);
  v_end_period := sysdate;
  /* insert data into bix_dm_report */
  insert_temp_table(v_classification_id, v_site_id, v_start_period, v_end_period);

EXCEPTION
    WHEN OTHERS
    THEN RETURN;
END populate;

FUNCTION get_heading RETURN varchar2
IS
 l_label VARCHAR2(1000);
 l_message VARCHAR2(1000);

  l_date DATE;
BEGIN
   select max(period_start_date_time)
   into l_date
   from bix_dm_real_queue_sum;

   l_message := fnd_message.get_string('BIX', 'BIX_DM_REFRESH_MSG') ;
l_label := l_message || ' ' ||to_char(l_date, 'DD-MON-YYYY HH12:MI:SS AM');
   return l_label;
END;
END BIX_QUEUE_DETAIL_REPORT;

/
