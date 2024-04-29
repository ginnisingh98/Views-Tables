--------------------------------------------------------
--  DDL for Package Body BIX_CAMP_PERF_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_CAMP_PERF_REPORT" AS
/*$Header: bixxrcpb.pls 115.16 2003/01/10 00:14:34 achanda ship $*/

g_time_range NUMBER;

PROCEDURE insert_temp_table(p_campaign_id IN NUMBER,
                            p_site_id     IN NUMBER,
                            p_group_id    IN NUMBER,
                            p_time        IN NUMBER,
                            p_start_period IN DATE,
                            p_end_period   IN DATE)
IS
  v_resource_id NUMBER;
  l_index NUMBER;
--  p_group_id NUMBER;
--  p_site_id NUMBER;
  v_group_name VARCHAR2(80);
  v_group_id NUMBER;
  v_campaign_name VARCHAR2(80);
  v_campaign_id NUMBER;
--  p_campaign_id NUMBER;
  v_resource_name VARCHAR2(80);
  v_source_code VARCHAR2(30);
  v_user_currency  VARCHAR2(80);
  v_global_currency  VARCHAR2(80);
  v_conversion_type  VARCHAR2(80);
  v_user_def_curr  VARCHAR2(80);
  v_format_mask VARCHAR2(80);

  l_denom_rate NUMBER;
  l_num_rate NUMBER;
  l_status   NUMBER;
  l_factor NUMBER;

  cursor get_campaigns is
  select distinct a.campaign_name, b.campaign_id
  from   bix_dm_group_call_sum b, ams_campaigns_vl a
  where    ((b.campaign_id = p_campaign_id) or (p_campaign_id is null or p_campaign_id = -999))
  and ((b.server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999))
  and b.campaign_id is not null
  and a.campaign_id = b.campaign_id;

  cursor get_groups is
  select distinct j.group_id, j.group_name
  from  jtf_rs_groups_vl j, bix_dm_group_call_sum b
  where b.group_id = j.group_id
  and   b.campaign_id = v_campaign_id
  and  ((b.group_id = p_group_id) or (p_group_id is null or p_group_id = -999))
  and ((b.server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999))
  and b.campaign_id  is not null;

  cursor group_agents is
  select j1.resource_name, j1.resource_id
  from   jtf_rs_resource_extns_vl j1,  jtf_rs_group_members j2
  where  j1.resource_id = j2.resource_id
  and  j2.group_id = v_group_id
  and ((j1.server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999));

  cursor all_agents is
  select j1.resource_name, j1.resource_id
  from   jtf_rs_resource_extns_vl j1;



BEGIN
/* Dummy row inserted for testing, plz remove */
/*
  INSERT INTO jtfb_temp_report(
			 report_code
			 , col1
			 ,  col2
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16
			 ,  col18
			 ,  col20
			 ,  col22
			 ,  col24
			 ,  col26)
   VALUES('BIX_CMPGN_PERF_REPORT'
		 , '1'
		 , 'Summer Special'
		 , ''
		 , NULL
		 , '45:22:25'
		 , '2000'
		 , '00:20:00'
		 , '00:20:00'
		 , '00:20:00'
		 , '90.0%'
		 , '1800'
		 , '900,000'
		 , '1500'
		 , '500,000'
		 );
*/
  v_user_currency :=  fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY');
  v_global_currency :=  fnd_profile.value('BIX_DM_PREFERRED_CURRENCY');
  v_conversion_type := fnd_profile.value( 'BIX_DM_CONVERSION_TYPE' );
  v_user_def_curr  :=  fnd_profile.value('JTF_PROFILE_DEFAULT_CURRENCY');
  v_format_mask  :=  fnd_currency.get_format_mask(v_user_currency,  30 );
  --to_char( amt, l_format_mask)
  bix_util_pkg.get_conversion_rate(v_global_currency, v_user_currency, sysdate, v_conversion_type, l_denom_rate,  l_num_rate, l_status );
  if (l_denom_rate = 0 or l_denom_rate is null) then
	 l_factor := 1;
  else
	 l_factor := l_num_rate/l_denom_rate;
  end if;

  if v_format_mask is null then
	v_format_mask := '999990';
	end if;

  l_index := 1;
  for campaigns in get_campaigns LOOP
	v_campaign_id := campaigns.campaign_id;
     v_campaign_name := campaigns.campaign_name;
      INSERT INTO jtfb_temp_report(
			 report_code
			 , col1
			 ,  col2
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16
			 ,  col18
			 ,  col20
			 ,  col22
			 ,  col24
			 ,  col26)
      (SELECT
			 'BIX_CMPGN_PERF_REPORT'
			 , l_index
			 , v_campaign_name
			 , null
			 , null
			 , bix_util_pkg.get_hrmiss_frmt(SUM(login_time))
			 , SUM(IN_CALLS_HANDLED + out_calls_handled)
			 , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time + out_talk_time)
			 / DECODE(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(in_wrap_time + out_wrap_time)
			 /decode(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
                , bix_util_pkg.get_hrmiss_frmt(sum(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time))
			 , trunc(sum(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)/sum(login_time) * 100, 2)
			 ,sum(leads_created)
			 ,to_char(sum(leads_amount) * l_factor, v_format_mask)
			 ,sum(opportunities_won)
			 ,to_char(sum(opportunities_won_amount) * l_factor,  v_format_mask)
        from bix_dm_group_call_sum
	   where campaign_id = v_campaign_id
	   and period_start_date_time between p_start_period and p_end_period);
   for groups in get_groups LOOP
     l_index := l_index + 1;
	 v_group_id := groups.group_id;
	 v_group_name := groups.group_name;
      INSERT INTO jtfb_temp_report(
			 report_code
			 , col1
			 ,  col2
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16
			 ,  col18
			 ,  col20
			 ,  col22
			 ,  col24
			 ,  col26)
      (SELECT
			 'BIX_CMPGN_PERF_REPORT'
			 , l_index
			 , NULL
			 , v_group_name
			 , null
			 , bix_util_pkg.get_hrmiss_frmt(SUM(login_time))
			 , SUM(IN_CALLS_HANDLED + out_calls_handled)
			 , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time + out_talk_time)
			 / DECODE(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(in_wrap_time + out_wrap_time)
			 /decode(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
                , bix_util_pkg.get_hrmiss_frmt(sum(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time))
			 , trunc(sum(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time)/sum(login_time) * 100, 2)
			 ,sum(leads_created)
			 ,to_char(sum(leads_amount)* l_factor, v_format_mask)
			 ,sum(opportunities_won)
			 ,to_char(sum(opportunities_won_amount) * l_factor, v_format_mask)
        from bix_dm_group_call_sum
	   where group_id = v_group_id
	   and   campaign_id = v_campaign_id
	   and period_start_date_time between p_start_period and p_end_period);
	for data in group_agents loop
         l_index := l_index + 1;
	    v_resource_id := data.resource_id;
	    v_resource_name := data.resource_name;
      INSERT INTO jtfb_temp_report(
			 report_code
			 , col1
			 ,  col2
			 ,  col4
			 ,  col6
			 ,  col8
			 ,  col10
			 ,  col12
			 ,  col14
			 ,  col16
			 ,  col18
			 ,  col20
			 ,  col22
			 ,  col24
			 ,  col26)
      (SELECT
			 'BIX_CMPGN_PERF_REPORT'
			 ,l_index
			 , null
			 , v_resource_name
			 , null
			 , bix_util_pkg.get_hrmiss_frmt(SUM(login_time))
			 , (SUM(IN_CALLS_HANDLED + out_calls_handled))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time + out_talk_time)
			 / DECODE(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
			 , bix_util_pkg.get_hrmiss_frmt(SUM(in_wrap_time + out_wrap_time)/decode(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
                , bix_util_pkg.get_hrmiss_frmt(sum(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time))
			 , trunc(sum((available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time))/sum(login_time) * 100, 2),
			 sum(leads_created),
			 to_char(sum(leads_amount) * l_factor, v_format_mask),
			 sum(opportunities_won),
			to_char(sum(opportunities_won_amount) * l_factor, v_format_mask)
      from    bix_dm_agent_call_sum
	 where   resource_id = v_resource_id
	   and   campaign_id = v_campaign_id
	   and  period_start_date_time between p_start_period and p_end_period
	   and   ((server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999)));
	 l_index := l_index + 1;
	 INSERT INTO jtfb_temp_report(
					report_code
					, col1
					,  col2
					,  col4
					,  col6
	     			,  col8
	     			,  col10
					,  col12
					,  col14
					 ,  col16
					 ,  col18
					 ,  col20
					 ,  col22
					  ,  col24
					  ,  col26)
      (SELECT
			 'BIX_CMPGN_PERF_REPORT'
			 , l_index
			  , null
			  , NULL
			  , decode(g_time_range,1,period_start_time,
			  2,substr(period_start_time,1,2),
			  3,to_char(floor(substr(period_start_time,1,2) / 2) * 2),
			  4,to_char(floor(substr(period_start_time,1,2) / 4) * 4),period_start_date)
			  , bix_util_pkg.get_hrmiss_frmt(SUM(login_time))
			   , (SUM(in_calls_handled + out_calls_handled))
			   , bix_util_pkg.get_hrmiss_frmt(SUM(in_talk_time + out_talk_time)/ DECODE(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
			   , bix_util_pkg.get_hrmiss_frmt(SUM(in_wrap_time + out_wrap_time)/decode(SUM(in_calls_handled + out_calls_handled),0,1,SUM(in_calls_handled + out_calls_handled)))
			 , bix_util_pkg.get_hrmiss_frmt(sum(available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time))
			 , trunc(sum((available_time + in_talk_time + out_talk_time + in_wrap_time + out_wrap_time))/sum(login_time) * 100, 2),
			 sum(leads_created),
			 to_char(sum(leads_amount) * l_factor, v_format_mask),
			 sum(opportunities_won),
			 to_char(sum(opportunities_won_amount) * l_factor, v_format_mask)
			 FROM        bix_dm_agent_call_sum
     		 WHERE       resource_id = v_resource_id
			 and   campaign_id = v_campaign_id
			 and   period_start_date_time between p_start_period and p_end_period
			 and   ((server_group_id = p_site_id) or (p_site_id is null or p_site_id = -999))
			 GROUP BY    decode(g_time_range,1,period_start_time,
			    2,substr(period_start_time,1,2),
			    3,to_char(floor(substr(period_start_time,1,2) / 2) * 2),
			    4,to_char(floor(substr(period_start_time,1,2) / 4) * 4),period_start_date));

   END LOOP;
   END LOOP;
   END LOOP;

END insert_temp_table;


PROCEDURE populate(p_context IN VARCHAR2)
IS
v_campaign_id NUMBER;
p_campaign_id NUMBER;
p_site_id NUMBER;
p_group_id NUMBER;
p_time NUMBER;
p_start_period DATE;
p_end_period DATE;
v_site_id NUMBER;
v_group_id NUMBER;
v_time  NUMBER;
v_start_period DATE;
v_end_period DATE;

BEGIN
  v_time := 8;
  SELECT fnd_profile.value('BIX_DM_RPT_TIME_RANGE')
  INTO   g_time_range
  FROM   dual;

  IF g_time_range IS NULL THEN
    g_time_range := 1;
  END IF;
  v_campaign_id :=  to_number(jtfb_dcf.get_parameter_value(p_context,'P_CAMPAIGN_ID'));
  v_site_id :=  to_number(jtfb_dcf.get_parameter_value(p_context,'P_SITE_ID'));
  v_group_id :=  to_number(jtfb_dcf.get_parameter_value(p_context,'P_GROUP_ID'));
  v_time :=  to_number(jtfb_dcf.get_parameter_value(p_context,'P_TIME'));
  -- get the start period and end period
  if (v_time <> 9) then
   if (v_time = 7) then
	v_start_period := sysdate - 2;
	v_end_period := sysdate - 1;
   elsif (v_time = 8) then
     v_start_period := sysdate - 1;
     v_end_period := sysdate;
   else
      bix_util_pkg.get_time_range(v_time , v_start_period, v_end_period);
   end if;
  else
  v_start_period :=  to_date(jtfb_dcf.get_parameter_value(p_context,'P_START_PERIOD'));
  v_end_period :=  to_date(jtfb_dcf.get_parameter_value(p_context,'P_END_PERIOD'));
  end if;
  insert_temp_table(v_campaign_id, v_site_id, v_group_id, v_time, v_start_period, v_end_period);
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
  from bix_dm_agent_call_sum;
  l_message := fnd_message.get_string('BIX', 'BIX_DM_REFRESH_MSG');
  l_label :=  l_message  || ' ' ||to_char(l_date, 'DD-MON-YYYY HH12:MI:SS AM');
  /*
  l_label := 'Campaign Performance - Agent Report (' || l_message  || ' ' ||to_char(l_date, 'DD-MON-YYYY HH12:MI:SS AM') || ')';
  */
   return l_label;
END;

END BIX_CAMP_PERF_REPORT;

/
