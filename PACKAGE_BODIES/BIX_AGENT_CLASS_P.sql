--------------------------------------------------------
--  DDL for Package Body BIX_AGENT_CLASS_P
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_AGENT_CLASS_P" AS
/*$Header: bixxabcb.pls 115.31 2001/10/26 17:44:34 pkm ship    $*/

g_sysdate            DATE;
g_time_range         NUMBER;
g_parent             VARCHAR2(50);
g_agent_group        VARCHAR2(50);
g_period_ind         NUMBER;
g_from_date          DATE;
g_from_time          VARCHAR2(10);
g_to_date            DATE;
g_to_time            VARCHAR2(10);
g_class              number;
g_site               number;
g_sqlstmt            VARCHAR2(4000);
g_classname          VARCHAR2(100);
l_session_id         number;
g_idx                number;


PROCEDURE form_rs_sqlstmt(p_total_row_ind IN number)
IS

BEGIN
  g_sqlstmt := NULL;

  /* Form the SQL string to insert the rows into the temp table */
  g_sqlstmt := '
    INSERT /*+ PARALLEL(tr,2) */ INTO BIX_DM_REPORT tr (
			 session_id,
			 report_code
			,  col3
			 ,  col4
			 ,  col5
			 ,  col6
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
			 ,  col40 ) ';
  g_sqlstmt := g_sqlstmt  || ' (SELECT ' || to_char(l_session_id) || ',' || ' ''BIX_AGENT_CLASS_REPORT'' ';

  IF (p_total_row_ind = 1/*TRUE*/) THEN
    g_sqlstmt := g_sqlstmt ||
		    ' , ''p'' || mem.group_id || ''c'' || to_char(a.resource_id) || ''n''
			 , rsc.source_name
			 , a.resource_id
                         , null
			 , null ';
  ELSif (p_total_row_ind = 2) then
	  IF (g_time_range = 5) THEN
    g_sqlstmt := g_sqlstmt ||
		    ' , a.resource_id
			 , null
			 , a.resource_id
                         , null
                         , to_char(period_start_date) ';
    ELSE
    g_sqlstmt := g_sqlstmt ||
		    ' , a.resource_id
			 , null
			 , a.resource_id
                         , null
                         , to_char(to_date(period_start_time,''hh24:mi''),''hh:miAM'') ';
    END IF;
  else /* for class summary */

      g_sqlstmt := g_sqlstmt || ',null
			 , null
			 , a.resource_id,';
      g_sqlstmt := g_sqlstmt || ' '' ' || g_className || ' '' ' || ', null ';
  END IF;

  g_sqlstmt := g_sqlstmt ||
               '  , sum(a.in_calls_handled),

		      nvl(sum(a.in_calls_handld_gt_thn_x_time),0),

                  ''col13'',
                    bix_util_pkg.get_hrmiss_frmt(
                  sum(a.in_talk_time)/sum(decode(a.in_calls_handled,0,1,a.in_calls_handled)) ),

                  ''col15'',

                  bix_util_pkg.get_hrmiss_frmt(
                  sum(a.in_wrap_time)/sum(decode(a.in_calls_handled,0,1,a.in_calls_handled)) ),

                  ''col17'',
                  sum(a.out_calls_handled) ,
                  nvl(sum(a.out_cals_handld_gt_thn_x_time),0),

                  bix_util_pkg.get_hrmiss_frmt(
                  sum(a.out_talk_time)/sum(decode(a.out_calls_handled,0,1,a.out_calls_handled))  ),

                  ''col23'',
                  bix_util_pkg.get_hrmiss_frmt(
                  sum(a.out_wrap_time)/sum(decode(a.out_calls_handled,0,1,a.out_calls_handled)) ),

		   ''col25'',
			   to_char(
                  round(sum(a.in_talk_time+a.out_talk_time+a.in_wrap_time+a.out_wrap_time)*100/
                  sum(decode(a.available_time+a.in_talk_time+a.out_talk_time+a.in_wrap_time+
                  a.out_wrap_time,0,1,a.available_time+a.in_talk_time+a.out_talk_time+
                  a.in_wrap_time+a.out_wrap_time)), 2), ''990.99'') || ''%'' ,';

 if (p_total_row_ind = 3) then  g_sqlstmt := g_sqlstmt ||
    '  ''col27'',
       trunc(sum(a.in_calls_handled+a.out_calls_handled)),
       bix_util_pkg.get_hrmiss_frmt(trunc(sum(a.in_talk_time+a.out_talk_time+a.in_wrap_time+a.out_wrap_time))) ,';
 else g_sqlstmt := g_sqlstmt ||
                  ' null,
                  null,
                  null, ';
end if;

 /* col32 */
 if (p_total_row_ind = 1) then
     g_sqlstmt := g_sqlstmt || 'concat( ' || ' '' ' ||bix_util_pkg.get_hrmiss_frmt(g_idx)|| ' '''
                 || ', rsc.source_name) , ';
elsif (p_total_row_ind =3) then  g_sqlstmt := g_sqlstmt || 'concat( ' || ' '' ' ||bix_util_pkg.get_hrmiss_frmt(g_idx)||' '''  || ', ''9'' ), ';
else
  if (g_time_range = 5) then
    g_sqlstmt := g_sqlstmt || 'concat( ' || ' '' ' ||bix_util_pkg.get_hrmiss_frmt(g_idx)|| ' '' ' || ',to_char(to_date(period_start_date,''dd/mm/yyyy''),''dd/mm/yyyy'') ), ';
  else
    g_sqlstmt := g_sqlstmt || 'concat( ' || ' '' ' ||bix_util_pkg.get_hrmiss_frmt(g_idx)|| ' '' ' || ',to_char(to_date(period_start_time,''hh24:mi''),''hh24:mi'') ), ';
  end if;

end if;
/* col34 */
 if (p_total_row_ind = 1) then g_sqlstmt := g_sqlstmt || ' ''LIST'','; /* for re-order */
 else g_sqlstmt := g_sqlstmt || ' ''DETAIL'', ';
 end if;
 g_sqlstmt := g_sqlstmt || '
                            null,
                            null,
                            null ';

  /* Fetch the data from the appropiate MV depending on the time range */
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

  IF (p_total_row_ind = 1 /*or p_total_row_ind = 3*/) THEN
	 g_sqlstmt := g_sqlstmt ||
				', jtf_rs_group_members mem
				 , jtf_rs_resource_extns rsc ';
  END IF;

  g_sqlstmt := g_sqlstmt || 'WHERE period_start_date_time between :start_date and :end_date ';

  IF (p_total_row_ind = 1 /*or p_total_row_ind = 3*/) THEN
	 g_sqlstmt := g_sqlstmt ||
				 'AND mem.group_id = :group_id
				  AND mem.resource_id = rsc.resource_id
				  AND rsc.resource_id = a.resource_id ';
  ELSE
      g_sqlstmt := g_sqlstmt || 'AND a.resource_id = :resource_id ';
  END IF;

  g_sqlstmt := g_sqlstmt || ' and (a.classification_id = :v_class_id or  :v_class_id = -999
		                   or( :v_class_id is null and a.classification_id is null) )
	                       and (:v_site_id = a.server_group_id
		                   or :v_site_id = -999) ';
/*
  g_sqlstmt := g_sqlstmt || ' and (a.classification_id = :v_class_id
							or :v_class_id = -999)
							 and (:v_site_id = a.server_group_id
													or :v_site_id = -999) ';
  */
  IF (p_total_row_ind = 1 /*or p_total_row_ind = 3*/) THEN
    g_sqlstmt := g_sqlstmt || 'GROUP BY mem.group_id, a.resource_id, rsc.source_name)';
  ELSIF (p_total_row_ind = 2) then
    IF (g_time_range = 5) THEN
     g_sqlstmt := g_sqlstmt || 'GROUP BY period_start_date, a.resource_id)';
    ELSE
     g_sqlstmt := g_sqlstmt || 'GROUP BY period_start_time, a.resource_id)';
    END IF;
  else  g_sqlstmt := g_sqlstmt || 'GROUP BY a.resource_id)';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END form_rs_sqlstmt;

PROCEDURE form_group_sqlstmt(p_total_row_ind IN BOOLEAN)
IS
BEGIN
  g_sqlstmt := NULL;

  /* Form the SQL string to insert the rows into the temp table */
  g_sqlstmt := '
    INSERT /*+ PARALLEL(tr,2) */ INTO BIX_DM_REPORT tr (
			 session_id,
			 report_code
			 ,  col2
			 ,  col3
			 ,  col4
			 ,  col5
			 ,  col6
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
			 ,  col40 ) ';

  g_sqlstmt := g_sqlstmt  || ' (SELECT ' || to_char(l_session_id) || ',' || ' ''BIX_AGENT_CLASS_REPORT'' ';

  IF (p_total_row_ind = TRUE) THEN
    g_sqlstmt := g_sqlstmt ||
		    ' , grp.group_name
		      , null
			 , null
			 , grp.group_id
                         ,null /*''class'' */
			 , null ';
  ELSE
    g_sqlstmt := g_sqlstmt ||
		    ' , null
		      , ''p'' || a.group_id
			 , grp.group_name
			 , dnm.group_id
                         , null /*''class'' */
	           , null ';
  END IF;

  g_sqlstmt := g_sqlstmt ||
		    '
		      , sum(a.in_calls_handled),

		      nvl(sum(a.in_calls_handld_gt_thn_x_time),0),

                  ''col13'',
                  bix_util_pkg.get_hrmiss_frmt(
                  sum(a.in_talk_time)/sum(decode(a.in_calls_handled,0,1,a.in_calls_handled)) ),

                  ''col15'',

                  bix_util_pkg.get_hrmiss_frmt(
                  sum(a.in_wrap_time)/sum(decode(a.in_calls_handled,0,1,a.in_calls_handled)) ),

                  ''col17'',
                  sum(a.out_calls_handled) ,
                  nvl(sum(a.out_cals_handld_gt_thn_x_time),0),

                  bix_util_pkg.get_hrmiss_frmt(
                  sum(a.out_talk_time)/sum(decode(a.out_calls_handled,0,1,a.out_calls_handled))  ),

                  ''col23'',
                  bix_util_pkg.get_hrmiss_frmt(
                  sum(a.out_wrap_time)/sum(decode(a.out_calls_handled,0,1,a.out_calls_handled)) ),

		   ''col25'',
		   to_char(
		  trunc(sum(a.in_talk_time+a.out_talk_time+a.in_wrap_time+a.out_wrap_time)*100/
                  sum(decode(a.available_time+a.in_talk_time+a.out_talk_time+a.in_wrap_time+
                  a.out_wrap_time,0,1,a.available_time+a.in_talk_time+a.out_talk_time+a.in_wrap_time+a.out_wrap_time)),2),''990.99'') || ''%'' ,



                ''col27'',
                decode(:agentNum,0,0,trunc(sum(a.in_calls_handled+a.out_calls_handled)/:agentNum) ) ,

                bix_util_pkg.get_hrmiss_frmt(decode(:agentNum,0,0,
                trunc(sum(a.in_talk_time+a.out_talk_time+a.in_wrap_time+a.out_wrap_time)/:agentNum ))) , ';

g_sqlstmt := g_sqlstmt || 'CONCAT( ' || ' '' '||bix_util_pkg.get_hrmiss_frmt(g_idx)|| ' '' ' || ',grp.group_name),';
g_sqlstmt := g_sqlstmt ||
               ' null,
                null,
                null,
	        null ';



  /* Fetch the data from the appropiate MV depending on the time range */
  IF (g_time_range = 1) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_call_sum a, jtf_rs_groups_vl grp/*,JTF_RS_GROUP_MEMBERS J*/ ';
  ELSIF (g_time_range = 2) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum1_mv a, jtf_rs_groups_vl grp/*,JTF_RS_GROUP_MEMBERS J*/ ';
  ELSIF (g_time_range = 3) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum2_mv a, jtf_rs_groups_vl grp/*,JTF_RS_GROUP_MEMBERS J*/ ';
  ELSIF (g_time_range = 4) THEN
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum4_mv a, jtf_rs_groups_vl grp/*,JTF_RS_GROUP_MEMBERS J*/ ';
  ELSE
    g_sqlstmt := g_sqlstmt || 'FROM bix_dm_group_sum_day_mv a, jtf_rs_groups_vl grp/*,JTF_RS_GROUP_MEMBERS J*/ ';
  END IF;

  IF (p_total_row_ind = FALSE) THEN
    g_sqlstmt := g_sqlstmt ||
				', jtf_rs_groups_denorm dnm ';
  END IF;

  g_sqlstmt := g_sqlstmt || 'WHERE period_start_date_time between :start_date and :end_date ';

  IF (p_total_row_ind = FALSE) THEN
    g_sqlstmt := g_sqlstmt ||
				 'AND dnm.parent_group_id = :group_id
				  AND dnm.group_id = grp.group_id
				  AND dnm.immediate_parent_flag = ''Y''
				  AND a.group_id = grp.group_id ';
  ELSE
      g_sqlstmt := g_sqlstmt || 'AND a.group_id = :group_id ';
  END IF;

   g_sqlstmt := g_sqlstmt || ' and a.group_id = grp.group_id

                               and (a.classification_id = :v_class_id
		                   or :v_class_id = -999)
	                       and (:v_site_id = a.server_group_id
		                   or :v_site_id = -999) ';

  IF (p_total_row_ind = TRUE) THEN
    g_sqlstmt := g_sqlstmt || 'GROUP BY grp.group_id, grp.group_name)';
  ELSE
    g_sqlstmt := g_sqlstmt || 'GROUP BY dnm.group_id, a.group_id, grp.group_name)';
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END form_group_sqlstmt;

/*********************************************************************************/
PROCEDURE insert_rs_detail_temp_table(p_agent_id IN NUMBER)
IS

l_unknown  varchar2(100);
id         number;

Cursor getClassList is
select nvl(classification,l_unknown) className,
       classification_id classId
from cct_classifications
where g_class = -999
      or classification_id = g_class;


BEGIN
  select bix_util_pkg.get_null_lookup into l_unknown
  from dual;
  /*
  SELECT meaning
            into l_unknown
  FROM   fnd_lookups
  WHERE  lookup_type = 'BIX_DM_NULL_DESC'
  AND    lookup_code = 'NULL';
 */
  for rec in getClassList
	loop

          g_classname :=rec.className;

  /* Form and execute the SQL statement to insert into the temp table  */
  /* all the detail rows coreesponding to the agent , user has chosen  */
  g_idx := g_idx+1;
  form_rs_sqlstmt(3);

  EXECUTE IMMEDIATE g_sqlstmt USING g_from_date, g_to_date, p_agent_id,
                                    rec.classId, rec.classId,rec.classId,
                                    g_site, g_site;
  g_idx := g_idx+1;
  form_rs_sqlstmt(2);
  EXECUTE IMMEDIATE g_sqlstmt USING g_from_date, g_to_date, p_agent_id,
                                    rec.classId, rec.classId,rec.classId,
                                    g_site, g_site;
  end loop;

  /* for un-classified calls */
  id :=null;
  g_classname := l_unknown;
  g_idx := g_idx+1;
  form_rs_sqlstmt(3);

  EXECUTE IMMEDIATE g_sqlstmt USING g_from_date, g_to_date, p_agent_id,
				     		 id, id,id,
							 g_site, g_site;
  g_idx := g_idx+1;
  form_rs_sqlstmt(2);
  EXECUTE IMMEDIATE g_sqlstmt USING g_from_date, g_to_date, p_agent_id,
							 id, id,id,
							 g_site, g_site;
EXCEPTION
    WHEN OTHERS THEN
		  RAISE;

END insert_rs_detail_temp_table;

/*********************************************************************************/
PROCEDURE insert_rs_total_temp_table(p_group_id IN NUMBER)
IS
BEGIN

  /* Form and execute the SQL statement to insert into the temp table  */
  /* all the rows coreesponding to the agent user has chosen           */
   g_idx := g_idx+1;
  form_rs_sqlstmt(1);
  EXECUTE IMMEDIATE g_sqlstmt USING g_from_date, g_to_date, p_group_id,
                                    g_class ,g_class, g_class,
                                    g_site, g_site;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_rs_total_temp_table;
/*********************************************************************************/

PROCEDURE insert_group_temp_table(p_group_id IN NUMBER)
IS
 idx number;
 agentNum number;

BEGIN

  /* Form and execute the SQL statement to insert into the temp table */
  /* the total row corresponding to the agent group user has chosen   */

  select count( distinct(b.resource_id) ) into agentNum
  from bix_dm_agent_call_sum b, JTF_RS_GROUP_MEMBERS j
  where group_id = p_group_id
  and   b.resource_id = j.resource_id;

  if agentNum is null then agentNum :=0;
  end if;

  g_idx := g_idx+1;
  form_group_sqlstmt(TRUE);
  EXECUTE IMMEDIATE g_sqlstmt USING agentNum, agentNum,agentNum, agentNum,
                                    g_from_date, g_to_date, p_group_id,
                                    g_class ,g_class,
                                    g_site, g_site;

/* Form and execute the SQL statement to insert into the temp table all    */
  /* the child agent groups corresponding to the agent group user has chosen */
  idx := g_idx+1;
  g_idx :=10000; /* make it teh very last */
  form_group_sqlstmt(FALSE);
  EXECUTE IMMEDIATE g_sqlstmt USING agentNum, agentNum,agentNum, agentNum,
                                    g_from_date, g_to_date, p_group_id,
                                    g_class ,g_class,
                                    g_site, g_site;
 g_idx :=idx;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_group_temp_table;



PROCEDURE insert_group_temp_table_child(p_group_id IN NUMBER)
IS
BEGIN

  /* Form and execute the SQL statement to insert into the temp table all    */
  /* the child agent groups corresponding to the agent group user has chosen */
  g_idx := g_idx+1;
  form_group_sqlstmt(FALSE);
  EXECUTE IMMEDIATE g_sqlstmt USING g_from_date, g_to_date, p_group_id,
                                    g_class ,g_class,
                                    g_site, g_site;
EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END insert_group_temp_table_child;



PROCEDURE get_param_values(p_context IN VARCHAR2)
IS
  v_temp_date  DATE;
  l_date_format_mask VARCHAR2(50);

BEGIN

   /* Fetch the nls date format*/
  l_date_format_mask := FND_PROFILE.VALUE('ICX_DATE_FORMAT_MASK');

  /* Parse all the parameter values from the variable p_context */

  g_parent         := bix_util_pkg.get_parameter_value(p_context, 'pContext');
  g_agent_group    := bix_util_pkg.get_parameter_value(p_context, 'P_GROUP_ID');
  g_period_ind     := TO_NUMBER(bix_util_pkg.get_parameter_value(p_context, 'P_TIME'));
  g_from_date      := TO_DATE(bix_util_pkg.get_parameter_value(p_context, 'P_START_PERIOD'), l_date_format_mask);
  g_from_time      := bix_util_pkg.get_parameter_value(p_context, 'P_START_HR');
  g_to_date        := TO_DATE(bix_util_pkg.get_parameter_value(p_context, 'P_END_PERIOD'),l_date_format_mask);
  g_to_time        := bix_util_pkg.get_parameter_value(p_context, 'P_END_HR');
  g_class          := TO_NUMBER(bix_util_pkg.get_parameter_value(p_context, 'P_CLASSIFICATION'));
  g_site           := TO_NUMBER(bix_util_pkg.get_parameter_value(p_context, 'P_SITE_ID'));

/*
g_class := -999;
g_site :=-999;


g_parent :=null;
 g_agent_group    :='p-999';
g_period_ind     :=null;

 g_from_date      :=null;
  g_from_time      :=null;
 g_to_date        :=null;
  g_to_time        := null;
*/


  /* Calculate the reporting period depending on the user input */
  IF (g_period_ind IS NULL) THEN

    SELECT MAX(period_start_date)
    INTO   v_temp_date
    FROM   bix_dm_agent_call_sum;

    g_from_date := to_date(to_char(v_temp_date, 'dd/mm/yyyy') || ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
    g_to_date := to_date(to_char(v_temp_date, 'dd/mm/yyyy') || ' 23:59:59','dd/mm/yyyy hh24:mi:ss');

  ELSIF (g_period_ind = 7) THEN

    g_from_date := to_date(to_char(g_sysdate, 'dd/mm/yyyy') || ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
    g_to_date := to_date(to_char(g_sysdate, 'dd/mm/yyyy') || ' 23:59:59','dd/mm/yyyy hh24:mi:ss');

  ELSIF (g_period_ind = 8) THEN

    g_from_date := to_date(to_char(g_sysdate-1, 'dd/mm/yyyy') || ' 00:00:00','dd/mm/yyyy hh24:mi:ss');
    g_to_date := to_date(to_char(g_sysdate-1, 'dd/mm/yyyy') || ' 23:59:59','dd/mm/yyyy hh24:mi:ss');

  ELSIF (g_period_ind = 9) THEN

    g_from_date := to_date(to_char(g_from_date,'dd/mm/yyyy ') || g_from_time, 'dd/mm/yyyy hh24');
    g_to_date := to_date(to_char(g_to_date,'dd/mm/yyyy ') || g_to_time, 'dd/mm/yyyy hh24');

  ELSE

    bix_util_pkg.get_time_range(g_period_ind, g_from_date, g_to_date);

  END IF;

EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END get_param_values;

PROCEDURE populate(p_context IN VARCHAR2)
IS

 v_drill_down_ind    VARCHAR2(1);
 v_agent_id           NUMBER;
 v_group_id           NUMBER;
 l_prefix            VARCHAR2(100);

Cursor getPrefix is
select col32 prefix
  from BIX_DM_REPORT
  where report_code = 'BIX_AGENT_CLASS_REPORT'
        and col34 = 'LIST'
        and session_id = l_session_id
        and col5= to_char(v_agent_id);

BEGIN

/* Get the ICX Session Id */
  l_session_id:= bix_util_pkg.get_icx_session_id;

  delete from BIX_DM_REPORT
  where session_id = l_session_id
  and report_code =  'BIX_AGENT_CLASS_REPORT';

  /* Fetch the sysdate */
  SELECT sysdate
  INTO   g_sysdate
  FROM   dual;


  g_idx :=0;
  /* Get the User preferred time range (1/2 or 1 or 2 or 4 hour or 1 day) */
  g_time_range := NULL;
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
  IF (g_parent = 'BIX_AGENT_CLASS_REPORT') THEN
    g_parent := NULL;
  END IF;



  /* Get the parent agent group id */
  /* g_parent = "not null" : User has navigated to the report either */
  /* from the bin or by clicking the agent/agent group in the report */
  /* g_parent = null : User has displayed the report by clicking the */
  /* "go" button in the paramter section                             */
  IF (g_parent IS NOT NULL) THEN
    SELECT TO_NUMBER(substr(g_parent, 2, decode(instr(g_parent,'c'), 0, length(g_parent), instr(g_parent,'c')-2)))
    INTO   v_group_id
    FROM   dual;
  ELSIF (g_agent_group IS NOT NULL) THEN
    v_group_id := g_agent_group;
  ELSE
    RETURN;
  END IF;

  /* If the user has selected "All" for agent group paramter , display the default group of the user */
  IF (v_group_id = -999) THEN
    SELECT fnd_profile.value('BIX_DM_DEFAULT_GROUP')
    INTO   v_group_id
    FROM   dual;
  END IF;



/* l_group_id = null : user has navigated to the report from the report listing page                     */
  /* or the user has selected "all" as agent group paramter and (s)he is not assigned to any default group */
  IF (v_group_id IS NULL) THEN
    RETURN;
  END IF;

  /* Process all the groups whose parent is the agent group v_group_id */
  insert_group_temp_table(v_group_id);

  /* Process all the agents belonging to the group */
  insert_rs_total_temp_table(v_group_id);

  /* Check if the user has clicked on an agent */
  IF (instr(g_parent,'c') <> 0) THEN

    v_agent_id := TO_NUMBER(substr(g_parent, instr(g_parent, 'c')+1, length(g_parent) - (instr(g_parent,'c')+1)));
    v_drill_down_ind := substr(g_parent, length(g_parent), 1);

    /* v_drill_down_ind = 'n' : we have to display the detail rows of the agent */
    IF (v_drill_down_ind = 'n') THEN
	 UPDATE BIX_DM_REPORT
	 SET col3 = 'p' || v_group_id || 'c' || to_char(v_agent_id) || 'y'
	 WHERE col3 = 'p' || v_group_id || 'c' || to_char(v_agent_id) || 'n';

      /* Fetch the detail rows of data for the agent from the */
      /* summary table and insert them into bix temp table    */
      insert_rs_detail_temp_table(v_agent_id);

      for rec in getPrefix loop
      l_prefix :=rec.prefix;
      end loop;

      /* update index order that the detail get listed under the agent */
      update BIX_DM_REPORT
      set col32 = concat(l_prefix, col32)
      where report_code = 'BIX_AGENT_CLASS_REPORT'
      and session_id = l_session_id
      and col34 = 'DETAIL';
    END IF;
  END IF;


/*
update BIX_DM_REPORT
set col32 = concat(l_prefix, col32)
where report_code = 'BIX_AGENT_CLASS_REPORT'
      and session_id = l_session_id
      and col34 = 'DETAIL'; */

EXCEPTION
  WHEN OTHERS THEN

    RAISE;
END populate;

END BIX_AGENT_CLASS_P;

/
