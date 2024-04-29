--------------------------------------------------------
--  DDL for Package Body BIM_DBI_MKTG_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_DBI_MKTG_MGMT_PVT" AS
/* $Header: bimvsqlb.pls 120.24 2006/05/16 02:02:14 arvikuma noship $ */

l_prog_view CONSTANT varchar2(1) :=  fnd_profile.VALUE('BIM_VIEW_PROGRAM');

l_prog_cost CONSTANT varchar2(50) := fnd_profile.VALUE('BIM_PROG_COST');
l_cost_type CONSTANT varchar2(50) := fnd_profile.VALUE('BIM_COST_PER_LEAD');
l_revenue   CONSTANT varchar2(50) := fnd_profile.VALUE('BIM_REVENUE');
l_csch_mode CONSTANT varchar2(50) := fnd_profile.VALUE('BIM_CSCH_OA_JTF');

L_viewby_c        CONSTANT varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('COUNTRY');
L_viewby_pc       CONSTANT varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('ENI_ITEM_VBH_CAT');
L_viewby_r        CONSTANT varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_CONTEXT_VIEWBY('REGION');
L_viewby_mc       CONSTANT varchar2(100):=BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('CHANNEL');


PROCEDURE write_debug(p_param_name varchar2, p_param_id varchar2 ,
    p_param_value varchar2 ,
   p_query varchar2 := NULL, p_dimension varchar2 := NULL,
    p_period_date date := null)
IS
BEGIN

--INSERT INTO BIM_PARAM_TEST values(p_param_name,p_param_id,
  -- p_param_value,DBMS_UTILITY.get_time,p_query,p_dimension,p_period_date);
--COMMIT;
NULL;
END;

FUNCTION GET_RESOURCE_ID return NUMBER IS
l_resource_id NUMBER := NULL;
CURSOR c_rid IS
       SELECT resource_id
       FROM   JTF_RS_RESOURCE_EXTNS
       WHERE  user_id = FND_GLOBAL.user_id;
 BEGIN
 OPEN c_rid;
         FETCH c_rid INTO l_resource_id;
 CLOSE c_rid;
 if (l_resource_id=null) then
   l_resource_id := -1;
 end if;
 if (l_resource_id='') then
    l_resource_id := -1;
 end if;

return l_resource_id;
END GET_RESOURCE_ID;

FUNCTION GET_DIM RETURN VARCHAR2 IS
period_id NUMBER;
BEGIN
 period_id   := -1;
 return '&AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
'&BIM_DIM5='||'TIME_COMPARISON_TYPE+YEARLY'||
'&BIM_DIM2_FROM='||period_id||'&BIM_DIM2_TO='||period_id||
'&BIM_DIM7=All&BIM_DIM8=All&VIEW_BY=CAMPAIGN+CAMPAIGN' ;

END GET_DIM;

FUNCTION GET_DIM_PARAM RETURN VARCHAR2 IS
period_id NUMBER;
BEGIN
 period_id   := -1;
 return '&AS_OF_DATE='||TO_CHAR(TRUNC(sysdate),'DD-MON-YYYY')||
'&BIM_DIM5='||'TIME_COMPARISON_TYPE+YEARLY'||
'&BIM_DIM2_FROM='||period_id||'&BIM_DIM2_TO='||period_id||
'&BIM_DIM7=All&BIM_DIM8=All&CURRENCY=FII_GLOBAL1&ENI_ITEM_VBH_CAT=All' ;

END GET_DIM_PARAM;

FUNCTION GET_ADMIN_STATUS return VARCHAR2 IS
l_admin_count NUMBER := 0;
l_admin_flag varchar2(20) ;
 CURSOR c_rid IS
       SELECT count(*)
       FROM   JTF_RS_RESOURCE_EXTNS r, bim_i_admin_group a
       WHERE  user_id = FND_GLOBAL.user_id
       AND r.resource_id = a.resource_id;

BEGIN
If GET_RESOURCE_ID is null
then
l_admin_flag := 'Y';

else

 OPEN c_rid;
         FETCH c_rid INTO l_admin_count;
 CLOSE c_rid;
   if (l_admin_count<=0)
   then
      l_admin_flag := 'N';
   else
      l_admin_flag := 'Y';
   end if;
end if;
   return l_admin_flag;
END GET_ADMIN_STATUS;



PROCEDURE GET_KPI_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
			  IS
l_sqltext varchar2(32766);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_prev_aod_str varchar2(80);
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_admin_clause varchar2(4000);
--l_cat_id NUMBER;
l_campaign_id VARCHAR2(50);
l_cat_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_table_name varchar2(100);
l_table_name1 varchar2(100);
l_pc_where varchar2(500);
l_pc_from  varchar2(100);
l_kpi_revenue  varchar2(50);
l_inr_cond   varchar2(5000);
l_inner   varchar2(5000);
l_inner_p   varchar2(5000);
l_top_cond  varchar2(100);
l_top_cond_tot   varchar2(100);
l_kpi_revenue_in varchar2(100);
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN

x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
 IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   l_admin_status := GET_ADMIN_STATUS;

   /*l_previous_as_of_date := BIM_PMV_DBI_UTL_PKG.Previous_Period_Asof_Date(l_as_of_date, l_period_type, l_comp_type);
   l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   l_prev_aod_str := 'to_date('||to_char(l_previous_as_of_date,'J')||',''J'')';*/
   l_rsid := GET_RESOURCE_ID;
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;

  IF l_cat_id IS NULL THEN
      l_pc_where:='AND a.category_id= -9';
  ELSE
          l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  l_pc_where  :=  ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
   END IF;

   IF l_admin_status='N' THEN
      if l_prog_view='Y' then
      l_table_name:='bim_i_obj_mets_mv a,bim_i_top_objects ac';
      l_table_name1:='bim_i_obj_mets_mv a,bim_i_top_objects ac';
      l_top_cond_tot :=' AND a.immediate_parent_id is null ';
      l_top_cond :=' AND a.immediate_parent_id is null ';
      else
      l_table_name:='bim_i_obj_mets_mv a,ams_act_access_denorm ac';
      l_table_name1:='bim_i_obj_mets_mv a,ams_act_access_denorm ac';
      l_top_cond :=' and a.object_type in (''CAMP'',''EVEH'',''EONE'') ';
      l_top_cond_tot :=' and a.object_type in (''CAMP'',''EVEH'',''EONE'') ';
      end if;
   ELSE
      l_table_name:='bim_mkt_kpi_cnt_mv a';
      l_table_name1:='bim_i_obj_mets_mv a';
      l_top_cond_tot :=' AND a.immediate_parent_id is null ';
   END IF;

/********************************************************************************/
 /********************************************************************************/

/***********Start: pick revenue column based on  profile setting ************/

   IF l_revenue = 'BOOKED_AMT' THEN

     l_kpi_revenue :='ORDERS_BOOKED_AMT';
     l_kpi_revenue_in :='BOOKED_AMT';

   ELSIF l_revenue = 'INVOICED_AMT'   THEN

    l_kpi_revenue :='ORDERS_INVOICED_AMT';
    l_kpi_revenue_in :='INVOICED_AMT';

   ELSIF l_revenue = 'WON_OPPR_AMT' THEN

    l_kpi_revenue :='WON_OPPORTUNITY_AMT';
    l_kpi_revenue_in :='WON_OPPORTUNITY_AMT';

   END IF;

   /***********End : pick revenue column based on  profile setting ************/


   /********************************************************************************/
   /********************************************************************************/

   /************Start Inner Query to get current acitve objects *************************/

l_inner:=', ( select distinct  a.object_id,a.object_type
from BIM_I_CPB_METS_MV a
,fii_time_rpt_struct_v cal';

IF l_admin_status='N' THEN
if l_prog_view='Y' then
  l_inner:=l_inner||',bim_i_top_objects r ';
else
  l_inner:=l_inner||',ams_act_access_denorm r ';
end if;
end if;

IF l_cat_id is not null then
  l_inner := l_inner ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;

 l_inner := l_inner || ' WHERE
 a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id
AND cal.calendar_id=-1
AND cal.report_date   in (&BIS_CURRENT_ASOF_DATE)
AND a.object_country = :l_country
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
and ( a.'||l_kpi_revenue_in||' >0 or a.total_leads >0)'||l_top_cond_tot;

IF l_admin_status = 'N' THEN
  l_inner :=  l_inner||'   a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_inner :=  l_inner ||' AND a.category_id = -9 ';
else
   l_inner :=  l_inner ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;

l_inner :=  l_inner ||' ) inr ';



l_inr_cond:='and a.source_code_id= inr.source_code_id
              ';

/************ End Inner Query to get current acitve objects *************************/



/************Start Inner Query to get prevoius acitve objects *************************/

l_inner_p:=', ( select distinct a.source_code_id
from BIM_I_CPB_METS_MV a
,fii_time_rpt_struct_v cal';

IF l_admin_status='N' THEN
  if l_prog_view='Y' then
  l_inner_p:=l_inner_p||',bim_i_top_objects r ';
  else
  l_inner_p:=l_inner_p||',ams_act_access_denorm r ';
  end if;
End if;

IF l_cat_id is not null then
  l_inner_p := l_inner_p ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;

 l_inner_p := l_inner_p || ' WHERE
 a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id
AND cal.calendar_id=-1
AND cal.report_date   in (&BIS_PREVIOUS_ASOF_DATE)
AND a.object_country = :l_country
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
and ( a.'||l_kpi_revenue_in||' > 0 or a.total_leads > 0)'||l_top_cond_tot;

IF l_admin_status = 'N' THEN
  l_inner_p :=  l_inner_p||' AND  a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_inner_p :=  l_inner_p ||' AND a.category_id = -9 ';
else
   l_inner_p :=  l_inner_p ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;

l_inner_p :=  l_inner_P ||' ) inr ';





/************ End Inner Query to get current acitve objects *************************/


l_sqltext := 'SELECT sum(x.c_resp) BIM_MEASURE1,
sum(x.c_resp) BIM_GRAND_TOTAL1,
sum(x.p_resp) BIM_MEASURE2,
sum(x.p_resp) BIM_CGRAND_TOTAL1,
sum(x.c_lds) BIM_MEASURE3,
sum(x.c_lds) BIM_GRAND_TOTAL2,
sum(x.p_lds) BIM_MEASURE4,
sum(x.p_lds)  BIM_CGRAND_TOTAL2,
decode(sum(x.c_lds),0,null,100*sum(x.c_alds)/sum(x.c_lds)) BIM_MEASURE5,
decode(sum(x.p_lds),0,null,100*sum(x.p_alds)/sum(x.p_lds)) BIM_MEASURE6,
decode(sum(x.c_lds),0,null,100*sum(x.c_alds)/sum(x.c_lds)) BIM_GRAND_TOTAL5,
decode(sum(x.p_lds),0,null,100*sum(x.p_alds)/sum(x.p_lds)) BIM_CGRAND_TOTAL5,
case when '''|| l_cost_type ||''' = ''BIM_PTD_COST''  then
   decode(sum(x.c_lds),0,null,sum(x.c_rev_profl)/sum(x.c_lds))
else
   decode(sum(x.t_leads),0,null,sum(x.t_revenue)/sum(x.t_leads))
end BIM_MEASURE9,
case when '''|| l_cost_type ||''' = ''BIM_PTD_COST''  then
   decode(sum(x.p_lds),0,null,sum(x.p_rev_profl)/sum(x.p_lds))
else
    decode(sum(x.pt_leads),0,null,sum(x.pt_revenue)/sum(x.pt_leads))
end BIM_MEASURE10,
case when '''|| l_cost_type ||''' = ''BIM_PTD_COST''  then
   decode(sum(x.c_lds),0,null,sum(x.c_rev_profl)/sum(x.c_lds))
else
   decode(sum(x.t_leads),0,null,sum(x.t_revenue)/sum(x.t_leads))
end BIM_GRAND_TOTAL6,
case when '''|| l_cost_type ||''' = ''BIM_PTD_COST''  then
   decode(sum(x.p_lds),0,null,sum(x.p_rev_profl)/sum(x.p_lds))
else
    decode(sum(x.pt_leads),0,null,sum(x.pt_revenue)/sum(x.pt_leads))
end BIM_CGRAND_TOTAL6,
decode(sum(x.c_popen)+sum(x.c_lds),0,null,100*sum(x.c_clds)/(sum(x.c_popen)+sum(x.c_lds))) BIM_MEASURE11,
decode(sum(x.p_popen)+sum(x.p_lds),0,null,100*sum(x.p_clds)/(sum(x.p_popen)+sum(x.p_lds))) BIM_MEASURE12,
decode(sum(x.c_popen)+sum(x.c_lds),0,null,100*sum(x.c_clds)/(sum(x.c_popen)+sum(x.c_lds))) BIM_GRAND_TOTAL7,
decode(sum(x.p_popen)+sum(x.p_lds),0,null,100*sum(x.p_clds)/(sum(x.p_popen)+sum(x.p_lds))) BIM_CGRAND_TOTAL7,
sum(x.c_opps) BIM_MEASURE13,
sum(x.p_opps) BIM_MEASURE14,
sum(x.c_opps) BIM_GRAND_TOTAL8,
sum(x.p_opps) BIM_CGRAND_TOTAL8,
sum(x.c_order) BIM_MEASURE15,
sum(x.p_order) BIM_MEASURE16,
sum(x.c_order) BIM_GRAND_TOTAL10,
sum(x.p_order) BIM_CGRAND_TOTAL10,
sum(x.c_camps) BIM_MEASURE17,
sum(x.p_camps) BIM_MEASURE18,
sum(x.c_camps) BIM_GRAND_TOTAL12,
sum(x.p_camps) BIM_CGRAND_TOTAL12,
sum(x.c_events) BIM_MEASURE19,
sum(x.p_events) BIM_MEASURE20,
sum(x.c_events) BIM_GRAND_TOTAL13,
sum(x.p_events) BIM_CGRAND_TOTAL13,
sum(x.c_rev) BIM_MEASURE23,
sum(x.p_rev) BIM_MEASURE24,
sum(x.c_rev) BIM_GRAND_TOTAL11,
sum(x.p_rev) BIM_CGRAND_TOTAL11,
sum(x.c_leadsc) BIM_MEASURE25,
sum(x.p_leadsc) BIM_MEASURE26,
sum(x.c_leadsc) BIM_GRAND_TOTAL3,
sum(x.p_leadsc) BIM_CGRAND_TOTAL3,
sum(x.c_leadsp) BIM_MEASURE27,
sum(x.p_leadsp) BIM_MEASURE28,
sum(x.c_leadsp) BIM_GRAND_TOTAL4,
sum(x.p_leadsp) BIM_CGRAND_TOTAL4,
sum(x.c_won_opps) BIM_MEASURE29,
sum(x.p_won_opps) BIM_MEASURE30,
sum(x.c_won_opps) BIM_GRAND_TOTAL9,
sum(x.p_won_opps) BIM_CGRAND_TOTAL9,
sum(x.c_alds) BIM_MEASURE31,
sum(x.p_alds) BIM_MEASURE32,
sum(x.c_alds) BIM_GRAND_TOTAL14,
sum(x.p_alds) BIM_CGRAND_TOTAL14
FROM
(SELECT sum(c_resp) c_resp ,sum(p_resp) p_resp,sum(c_lds) c_lds,sum(p_lds) p_lds,sum(c_alds) c_alds,sum(p_alds) p_alds,sum(c_opps)
c_opps,sum(p_opps) p_opps,sum(c_won_opps) c_won_opps,sum(p_won_opps) p_won_opps,sum(c_order) c_order,sum(p_order) p_order,
sum(c_rev_profl) c_rev_profl,sum(p_rev_profl) p_rev_profl,
decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(c_bapp),SUM(c_cost)) c_cost,
decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(p_bapp),SUM(p_cost)) p_cost,
sum(c_rev) c_rev,sum(p_rev) p_rev,sum(c_events) c_events,sum(p_events) p_events,sum(c_camps) c_camps,sum(p_camps) p_camps ,sum(c_popen)
c_popen,sum(p_popen) p_popen,sum(c_clds) c_clds,sum(p_clds) p_clds ,
sum(t_revenue) t_revenue,
sum(t_leads) t_leads,
sum(pt_revenue) pt_revenue,
sum(pt_leads) pt_leads,
SUM(c_leadsc) c_leadsc,
SUM(p_leadsc) p_leadsc,
SUM(c_leadsp) c_leadsp,
SUM(p_leadsp) p_leadsp
FROM(
SELECT SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.responses_positive else 0 end) c_resp,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.responses_positive else 0 end) p_resp,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.leads else 0 end) c_lds,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.leads else 0 end) p_lds,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.rank_a else 0 end) c_alds,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.rank_a else 0 end) p_alds,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.new_opportunity_amt'||l_curr_suffix||' else 0 end) c_opps,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.new_opportunity_amt'||l_curr_suffix||' else 0 end) p_opps,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.won_opportunity_amt'||l_curr_suffix||' else 0 end) c_won_opps,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.won_opportunity_amt'||l_curr_suffix||' else 0 end) p_won_opps,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.orders_booked_amt'||l_curr_suffix||' else 0 end) c_order,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.orders_booked_amt'||l_curr_suffix||' else 0 end) p_order,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.'||l_kpi_revenue||l_curr_suffix||' else 0 end) c_rev_profl,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.'||l_kpi_revenue||l_curr_suffix||' else 0 end) p_rev_profl,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.budget_approved'||l_curr_suffix||' else 0 end) c_bapp,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.budget_approved'||l_curr_suffix||' else 0 end) p_bapp,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.cost_actual'||l_curr_suffix||' else 0 end) c_cost,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.cost_actual'||l_curr_suffix||' else 0 end) p_cost,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.orders_invoiced_amt'||l_curr_suffix||' else 0 end) c_rev,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.orders_invoiced_amt'||l_curr_suffix||' else 0 end) p_rev,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.even_started else 0 end) c_events,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.even_started else 0 end) p_events,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.camp_started else 0 end) c_camps,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.camp_started else 0 end) p_camps,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.leads_converted else 0 end) c_clds,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.leads_converted else 0 end) p_clds,
0 c_popen,0 p_popen,0 t_revenue,0 t_leads,0 pt_revenue,0 pt_leads,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.leads_customer else 0 end) c_leadsc,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.leads_customer else 0 end) p_leadsc,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  a.leads_prospect else 0 end) c_leadsp,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.leads_prospect else 0 end) p_leadsp
FROM '||l_table_name||',
fii_time_rpt_struct_v cal'||l_pc_from;

l_sqltext := l_sqltext ||' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND cal.calendar_id=-1 ';
l_sqltext := l_sqltext ||l_pc_where;

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext||' AND a.source_code_id=ac.source_code_id
                           AND ac.resource_id = :l_resource_id ';
END IF;
l_sqltext := l_sqltext ||
' AND a.object_country = :l_country'|| l_top_cond||'
UNION ALL
SELECT
0 c_resp,0 p_resp,0 c_lds,0 p_lds,0 c_alds,0 p_alds,0 c_opps,0 p_opps,0 c_won_opps,0 p_won_opps,0 c_order,0 p_order,0 c_rev_profl,0 p_rev_profl,
0 c_bapp,0 p_bapp,0 c_cost,0 p_cost,0 c_rev,0 p_rev,0 c_events,0 p_events,0 c_camps,0 p_camps,
0 c_clds,0 p_clds,
SUM(case when cal.report_date=&BIS_CURRENT_EFFECTIVE_START_DATE - 1 then a.leads-(a.leads_closed+a.leads_dead+a.leads_converted) else 0 end)
c_popen,
SUM(case when cal.report_date=&BIS_PREVIOUS_EFFECTIVE_START_DATE-1 then a.leads-(a.leads_closed+a.leads_dead+a.leads_converted) else 0 end)
p_popen,0 t_revenue,0 t_leads,0 pt_revenue,0 pt_leads,0 c_leadsc,0 p_leadsc,0 c_leadsp,0 p_leadsp
FROM '||l_table_name||',
fii_time_rpt_struct_v cal '||l_pc_from;
l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1,&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1 ';
l_sqltext := l_sqltext ||l_pc_where;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext||' AND a.source_code_id=ac.source_code_id
			  AND ac.resource_id = :l_resource_id ';
END IF;
l_sqltext := l_sqltext ||
' AND a.object_country = :l_country '|| l_top_cond;

if l_cost_type <> 'BIM_PTD_COST' then
l_sqltext := l_sqltext||'
union all
SELECT
0 c_resp,0 p_resp,0 c_lds,0 p_lds,0 c_alds,0 p_alds,0 c_opps,0 p_opps,0 c_won_opps,0 p_won_opps,0 c_order,0 p_order,0 c_rev_profl,0 p_rev_profl,0 c_bapp,0 p_bapp,0 c_cost,0 p_cost,
0 c_rev,0 p_rev,0 c_events,0 p_events,0 c_camps,0 p_camps,0 c_clds,0 p_clds,0 c_popen,0 p_popen,sum(a.'||l_kpi_revenue||l_curr_suffix||') t_revenue ,sum( a.leads) t_leads,0 pt_revenue,0 pt_leads,
0 c_leadsc,0 p_leadsc,0 c_leadsp,0 p_leadsp
FROM '||l_table_name1||',
fii_time_rpt_struct_v cal '||l_pc_from||l_inner;
l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1 '||l_top_cond_tot;

l_sqltext := l_sqltext ||l_inr_cond||l_pc_where;

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext||' AND a.source_code_id=ac.source_code_id
			  AND ac.resource_id = :l_resource_id '||l_top_cond;
END IF;

l_sqltext := l_sqltext ||
' AND a.object_country = :l_country
union all
SELECT
0 c_resp,0 p_resp,0 c_lds,0 p_lds,0 c_alds,0 p_alds,0 c_opps,0 p_opps,0 c_won_opps,0 p_won_opps,0 c_order,0 p_order,0 c_rev_profl,0 p_rev_profl,0 c_bapp,0 p_bapp,0 c_cost,0 p_cost,
0 c_rev,0 p_rev,0 c_events,0 p_events,0 c_camps,0 p_camps,0 c_clds,0 p_clds,0 c_popen,0 p_popen,0 t_revenue ,0 t_leads,sum(a.'||l_kpi_revenue||l_curr_suffix||') pt_revenue,sum( a.leads) pt_leads,
0 c_leadsc,0 p_leadsc,0 c_leadsp,0 p_leadsp
FROM '||l_table_name1||',
fii_time_rpt_struct_v cal '||l_pc_from||l_inner_p;


l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1 '||l_top_cond_tot;


l_sqltext := l_sqltext ||l_inr_cond||l_pc_where;

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext||' AND a.source_code_id=ac.source_code_id
                          AND ac.resource_id = :l_resource_id '||l_top_cond;
END IF;

l_sqltext := l_sqltext ||
' AND a.object_country = :l_country';
END IF;
l_sqltext := l_sqltext ||'
  )
  ) x ';




  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

write_debug('MKTG KPI SQL','QUERY','test',l_sqltext,NULL,null);
EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('MKTG KPI SQL','ERROR',l_sql_errm,l_sqltext,NULL,null);
END GET_KPI_SQL;

PROCEDURE GET_PO_RACK_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(32000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
l_object_type varchar2(30);
l_url_str varchar2(1000);
l_url_str_csch varchar2(1000);
l_url_str_csch_jtf varchar2(1000);
l_url_str_type varchar2(1000);
l_url_str_tga varchar2(1000);
l_csch_chnl  varchar2(100);
l_chnl_select  varchar2(1000);
l_chnl_from  varchar2(1000);
l_chnl_where  varchar2(1000);
l_chnl_group  varchar2(1000);
l_chnl_col   varchar2(10);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50):= NULL;
l_campaign_id VARCHAR2(50):= NULL;
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_dass                          varchar2(100);  -- variable to store value for  directly assigned lookup value
--l_una                          varchar2(100);   -- variable to store value for  Unassigned lookup value
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);


 /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');

BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
										l_as_of_date,
										l_period_type,
										l_record_type_id,
										l_comp_type,
										l_country,
										l_view_by,
										l_cat_id,
										l_campaign_id,
										l_curr,
										l_col_id,
										l_area,
										l_media,
										l_report_name
										);
IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
    l_admin_status := GET_ADMIN_STATUS;


  l_url_str :='pFunctionName=BIM_I_PROG_ORDER_PHD&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
  --l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&addBreadCrumb=S&addBreadCrumb=Y&objId=';
  l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
  l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
  l_url_str_tga  :='pFunctionName=AMS_LIST_UPDATE_PG&retainAM=Y&MidTab=ChartsRN&addBreadCrumb=Y&NavMode=UPD&OAPB=AMS_AUDIENCE_USER_BRANDING&ListHeaderId=';
  l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
  &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

IF(l_campaign_id IS NULL) THEN
/***************** NO DRILL DOWN IN CAMPAIGN HIRERACHY**********/
	IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN

		IF l_cat_id IS NULL THEN
		/************** START OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NULL ***********/
		l_sqltext :=
		'
		SELECT
		VIEWBY,
		VIEWBYID,
		BIM_ATTRIBUTE2,
		BIM_ATTRIBUTE3,
		BIM_ATTRIBUTE4,
		BIM_ATTRIBUTE5,
		BIM_ATTRIBUTE6,
		BIM_ATTRIBUTE7,
		BIM_ATTRIBUTE8,
		BIM_ATTRIBUTE9,
		BIM_ATTRIBUTE10,
		BIM_ATTRIBUTE11,
		BIM_ATTRIBUTE12,
		BIM_ATTRIBUTE13,
		BIM_ATTRIBUTE14,
		BIM_ATTRIBUTE8 BIM_ATTRIBUTE17,
		decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
		null BIM_URL2,
		null BIM_URL3,
		null BIM_URL4,
		BIM_GRAND_TOTAL1,
		BIM_GRAND_TOTAL2,
		BIM_GRAND_TOTAL3,
		BIM_GRAND_TOTAL4,
		BIM_GRAND_TOTAL5,
		BIM_GRAND_TOTAL6,
		BIM_GRAND_TOTAL7,
		BIM_GRAND_TOTAL8,
		BIM_GRAND_TOTAL9,
		BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
		FROM
		(
		SELECT name VIEWBY,
		leaf_node_flag,
		null BIM_ATTRIBUTE2,
		targeted_audience BIM_ATTRIBUTE3,
		responses_positive BIM_ATTRIBUTE4,
		leads BIM_ATTRIBUTE5,
		rank_a BIM_ATTRIBUTE6,
		decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
		new_opportunity_amt BIM_ATTRIBUTE8,
		won_opportunity_amt BIM_ATTRIBUTE9,
		orders_booked_amt BIM_ATTRIBUTE10,
		orders_invoiced_amt BIM_ATTRIBUTE11,
		null BIM_ATTRIBUTE12,
		null BIM_ATTRIBUTE13,
		DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE14,
		sum(targeted_audience) over() BIM_GRAND_TOTAL1,
		sum(responses_positive) over() BIM_GRAND_TOTAL2,
		sum(leads) over() BIM_GRAND_TOTAL3,
		sum(rank_a) over() BIM_GRAND_TOTAL4,
		decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
		sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
		sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
		sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
		sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
		VIEWBYID
		FROM
		(
		SELECT
		VIEWBYID,
		name,
		leaf_node_flag,
		sum(targeted_audience) targeted_audience,
		sum(responses_positive) responses_positive,
		sum(leads) leads,
		sum(rank_a) rank_a ,
		sum(new_opportunity_amt) new_opportunity_amt,
		sum(won_opportunity_amt) won_opportunity_amt,
		sum(orders_booked_amt) orders_booked_amt,
		sum(orders_invoiced_amt) orders_invoiced_amt,
		sum(prior_open) prior_open,
		sum(leads_converted) leads_converted,
		sum(prev_new_opportunity_amt) prev_new_opportunity_amt
		FROM
		( SELECT /*+ORDERED*/
		p.parent_id VIEWBYID,
		p.value  name,
		p.leaf_node_flag leaf_node_flag,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
		0 prior_open,
		sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
		SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
		FROM fii_time_rpt_struct_v cal,
			 BIM_I_OBJ_METS_MV a
			,eni_denorm_hierarchies edh
						,mtl_default_category_sets mdcs
						,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
						   FROM eni_item_vbh_nodes_v e
						   WHERE e.top_node_flag=''Y''
						   AND e.child_id = e.parent_id) p ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac ';
		END IF;
		l_sqltext :=  l_sqltext ||
		' WHERE a.time_id = cal.time_id
		AND  a.period_type_id = cal.period_type_id
		AND a.category_id = edh.child_id
		AND edh.object_type = ''CATEGORY_SET''
		AND edh.object_id = mdcs.category_set_id
		AND mdcs.functional_area_id = 11
		AND edh.dbi_flag = ''Y''
		AND edh.parent_id = p.parent_id';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||
		' AND a.source_code_id = ac.source_code_id
		AND ac.resource_id = :l_resource_id';
		ELSE
		l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
		END IF;
		l_sqltext :=  l_sqltext ||
		' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
		AND a.object_country = :l_country';
		l_sqltext :=  l_sqltext ||
		' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
		AND cal.calendar_id=-1
		GROUP BY p.value,p.parent_id,p.leaf_node_flag
		UNION ALL
		SELECT /*+ORDERED*/
		p.parent_id VIEWBYID,
		p.value  name,
		p.leaf_node_flag leaf_node_flag,
		0 targeted_audience,
		0 responses_positive,
		0 leads,
		0 rank_a ,
		0 new_opportunity_amt,
		0 won_opportunity_amt,
		0 orders_booked_amt,
		0 orders_invoiced_amt,
		sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
		0 leads_converted,
		0 prev_new_opportunity_amt
		FROM fii_time_rpt_struct_v cal,
			 BIM_I_OBJ_METS_MV a
			,eni_denorm_hierarchies edh
						,mtl_default_category_sets mdcs
						,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
						   FROM eni_item_vbh_nodes_v e
						   WHERE e.top_node_flag=''Y''
						   AND e.child_id = e.parent_id) p ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
		END IF;
		l_sqltext :=  l_sqltext ||
		' WHERE a.time_id = cal.time_id
		AND  a.period_type_id = cal.period_type_id
		AND a.category_id = edh.child_id
		AND edh.object_type = ''CATEGORY_SET''
		AND edh.object_id = mdcs.category_set_id
		AND mdcs.functional_area_id = 11
		AND edh.dbi_flag = ''Y''
		AND edh.parent_id = p.parent_id';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||
		' AND a.source_code_id = ac.source_code_id
		AND ac.resource_id = :l_resource_id';
		ELSE
		l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
		END IF;
		l_sqltext :=  l_sqltext ||
		' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
		AND a.object_country = :l_country';
		l_sqltext :=  l_sqltext ||
		' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
		AND cal.calendar_id=-1
		GROUP BY p.value,p.parent_id,p.leaf_node_flag
		)GROUP BY name,VIEWBYID,leaf_node_flag
		)
		)
		WHERE
		BIM_ATTRIBUTE3 > 0
		OR BIM_ATTRIBUTE4 > 0
		OR BIM_ATTRIBUTE5 > 0
		OR BIM_ATTRIBUTE6 > 0
		OR BIM_ATTRIBUTE7 > 0
		OR BIM_ATTRIBUTE8 > 0
		OR BIM_ATTRIBUTE9 > 0
		OR BIM_ATTRIBUTE10 > 0
		OR BIM_ATTRIBUTE11 > 0
		&ORDER_BY_CLAUSE';
		/************** END OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NULL ***********/
	ELSE
		/************** START OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NOT NULL ***********/
		l_dass:=  BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('DASS');
		l_sqltext :=
		'
		SELECT
		VIEWBY,
		VIEWBYID,
		BIM_ATTRIBUTE2,
		BIM_ATTRIBUTE3,
		BIM_ATTRIBUTE4,
		BIM_ATTRIBUTE5,
		BIM_ATTRIBUTE6,
		BIM_ATTRIBUTE7,
		BIM_ATTRIBUTE8,
		BIM_ATTRIBUTE9,
		BIM_ATTRIBUTE10,
		BIM_ATTRIBUTE11,
		BIM_ATTRIBUTE12,
		BIM_ATTRIBUTE13,
		BIM_ATTRIBUTE14,
		BIM_ATTRIBUTE8 BIM_ATTRIBUTE17,
		decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
		null BIM_URL2,
		null BIM_URL3,
		null BIM_URL4,
		BIM_GRAND_TOTAL1,
		BIM_GRAND_TOTAL2,
		BIM_GRAND_TOTAL3,
		BIM_GRAND_TOTAL4,
		BIM_GRAND_TOTAL5,
		BIM_GRAND_TOTAL6,
		BIM_GRAND_TOTAL7,
		BIM_GRAND_TOTAL8,
		BIM_GRAND_TOTAL9,
		BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
		FROM
		(
		SELECT name VIEWBY,
		leaf_node_flag,
		null BIM_ATTRIBUTE2,
		targeted_audience BIM_ATTRIBUTE3,
		responses_positive BIM_ATTRIBUTE4,
		leads BIM_ATTRIBUTE5,
		rank_a BIM_ATTRIBUTE6,
		decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
		new_opportunity_amt BIM_ATTRIBUTE8,
		won_opportunity_amt BIM_ATTRIBUTE9,
		orders_booked_amt BIM_ATTRIBUTE10,
		orders_invoiced_amt BIM_ATTRIBUTE11,
		null BIM_ATTRIBUTE12,
		null BIM_ATTRIBUTE13,
		DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE14,
		sum(targeted_audience) over() BIM_GRAND_TOTAL1,
		sum(responses_positive) over() BIM_GRAND_TOTAL2,
		sum(leads) over() BIM_GRAND_TOTAL3,
		sum(rank_a) over() BIM_GRAND_TOTAL4,
		decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
		sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
		sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
		sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
		sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
		VIEWBYID
		FROM
		(
		SELECT
		VIEWBYID,
		name,
		leaf_node_flag,
		sum(targeted_audience) targeted_audience,
		sum(responses_positive) responses_positive,
		sum(leads) leads,
		sum(rank_a) rank_a ,
		sum(new_opportunity_amt) new_opportunity_amt,
		sum(won_opportunity_amt) won_opportunity_amt,
		sum(orders_booked_amt) orders_booked_amt,
		sum(orders_invoiced_amt) orders_invoiced_amt,
		sum(prior_open) prior_open,
		sum(leads_converted) leads_converted,
		sum(prev_new_opportunity_amt) prev_new_opportunity_amt
		FROM
		(
		SELECT /*+ORDERED*/
		p.id VIEWBYID,
		p.value  name,
		p.leaf_node_flag leaf_node_flag,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
		0 prior_open,
		sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
		SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
		FROM fii_time_rpt_struct_v cal,
			 BIM_I_OBJ_METS_MV a
			,eni_denorm_hierarchies edh
					,mtl_default_category_sets mdc
					,(select e.id,e.value,e.leaf_node_flag
					  from eni_item_vbh_nodes_v e
				  where
					  e.parent_id =:l_cat_id
					  AND e.id = e.child_id
					  AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
			  ) p ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
		END IF;
		l_sqltext :=  l_sqltext ||
		' WHERE a.time_id = cal.time_id
		AND  a.period_type_id = cal.period_type_id
		AND a.category_id = edh.child_id
		AND edh.object_type = ''CATEGORY_SET''
		AND edh.object_id = mdc.category_set_id
		AND mdc.functional_area_id = 11
		AND edh.dbi_flag = ''Y''
		AND edh.parent_id = p.id ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||
		'
		AND a.source_code_id = ac.source_code_id
		AND ac.resource_id = :l_resource_id';
		ELSE
		l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
		END IF;
		l_sqltext :=  l_sqltext ||
		' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
		AND a.object_country = :l_country';
		l_sqltext :=  l_sqltext ||
		' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
		AND cal.calendar_id=-1
		GROUP BY p.id,p.value,p.leaf_node_flag
		UNION ALL
		SELECT /*+ORDERED*/
		p.id VIEWBYID,
		p.value  name,
		p.leaf_node_flag leaf_node_flag,
		0 targeted_audience,
		0 responses_positive,
		0 leads,
		0 rank_a ,
		0 new_opportunity_amt,
		0 won_opportunity_amt,
		0 orders_booked_amt,
		0 orders_invoiced_amt,
		sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
		0 leads_converted,
		0 prev_new_opportunity_amt
		FROM fii_time_rpt_struct_v cal,
			 BIM_I_OBJ_METS_MV a
			,eni_denorm_hierarchies edh
					,mtl_default_category_sets mdc
					,(select e.id,e.value,e.leaf_node_flag
					  from eni_item_vbh_nodes_v e
				  where
					  e.parent_id =:l_cat_id
					  AND e.id = e.child_id
					  AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
			  ) p ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
		END IF;
		l_sqltext :=  l_sqltext ||
		' WHERE a.time_id = cal.time_id
		AND  a.period_type_id = cal.period_type_id
		AND a.category_id = edh.child_id
		AND edh.object_type = ''CATEGORY_SET''
		AND edh.object_id = mdc.category_set_id
		AND mdc.functional_area_id = 11
		AND edh.dbi_flag = ''Y''
		AND edh.parent_id = p.id ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||
		'
		AND a.source_code_id = ac.source_code_id
		AND ac.resource_id = :l_resource_id';
		ELSE
		l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
		END IF;
		l_sqltext :=  l_sqltext ||
		' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
		AND a.object_country = :l_country';
		l_sqltext :=  l_sqltext ||
		' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
		AND cal.calendar_id=-1
		GROUP BY p.id,p.value,p.leaf_node_flag
		/*** directly assigned to the category *************/
		UNION ALL
		SELECT /*+ORDERED*/
		p.id VIEWBYID,
		bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
		''Y'' leaf_node_flag,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
		SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
		0 prior_open,
		sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
		SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
		FROM fii_time_rpt_struct_v cal,
			 BIM_I_OBJ_METS_MV a
			,(select e.id id,e.value value
							  from eni_item_vbh_nodes_v e
							  where e.parent_id =  :l_cat_id
							  AND e.parent_id = e.child_id
							  AND leaf_node_flag <> ''Y''
							  ) p ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
		END IF;
		l_sqltext :=  l_sqltext ||
		' WHERE a.time_id = cal.time_id
		AND  a.period_type_id = cal.period_type_id
		AND a.category_id = p.id';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||
		'
		AND a.source_code_id = ac.source_code_id
		AND ac.resource_id = :l_resource_id';
		ELSE
		l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
		END IF;
		l_sqltext :=  l_sqltext ||
		' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
		AND a.object_country = :l_country';
		l_sqltext :=  l_sqltext ||
		' AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
		AND cal.calendar_id=-1
		GROUP BY p.id
		UNION ALL
		SELECT /*+ORDERED*/
		p.id VIEWBYID,
		bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'   name,
		''Y'' leaf_node_flag,
		0 targeted_audience,
		0 responses_positive,
		0 leads,
		0 rank_a ,
		0 new_opportunity_amt,
		0 won_opportunity_amt,
		0 orders_booked_amt,
		0 orders_invoiced_amt,
		sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
		0 leads_converted,
		0 prev_new_opportunity_amt
		FROM  fii_time_rpt_struct_v cal,
			  BIM_I_OBJ_METS_MV a
			,(select e.id id,e.value value
							  from eni_item_vbh_nodes_v e
							  where e.parent_id =  :l_cat_id
							  AND e.parent_id = e.child_id
							  AND leaf_node_flag <> ''Y''
							  ) p ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
		END IF;
		l_sqltext :=  l_sqltext ||
		' WHERE a.time_id = cal.time_id
		AND  a.period_type_id = cal.period_type_id
		AND a.category_id = p.id ';
		IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||
		'
		AND a.source_code_id = ac.source_code_id
		AND ac.resource_id = :l_resource_id';
		ELSE
		l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
		END IF;
		l_sqltext :=  l_sqltext ||
		' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
		AND a.object_country = :l_country';
		l_sqltext :=  l_sqltext ||
		' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
		AND cal.calendar_id=-1
		GROUP BY p.id
		)GROUP BY name,VIEWBYID,leaf_node_flag
		)
		)
		WHERE
		BIM_ATTRIBUTE3 > 0
		OR BIM_ATTRIBUTE4 > 0
		OR BIM_ATTRIBUTE5 > 0
		OR BIM_ATTRIBUTE6 > 0
		OR BIM_ATTRIBUTE7 > 0
		OR BIM_ATTRIBUTE8 > 0
		OR BIM_ATTRIBUTE9 > 0
		OR BIM_ATTRIBUTE10 > 0
		OR BIM_ATTRIBUTE11 > 0
		&ORDER_BY_CLAUSE';
		/************** END OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NOT NULL ***********/
		END IF;

	ELSIF (l_view_by ='MEDIA+MEDIA') THEN
	--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE17,
	null BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE14,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	null VIEWBYID,
	name,
	null meaning,
	SUM(targeted_audience) targeted_audience,
	SUM(responses_positive) responses_positive,
	SUM(leads) leads,
	SUM(rank_a) rank_a ,
	SUM(new_opportunity_amt) new_opportunity_amt,
	SUM(won_opportunity_amt) won_opportunity_amt,
	SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,
	SUM(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt ';

	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_chnl_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_chnl_mv a, ';
	END IF;
	l_sqltext := l_sqltext ||'
		fii_time_rpt_struct_v cal,
		bim_dimv_media d ';

	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF;
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	  AND  d.id (+)= a.activity_id
	  AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	  AND cal.calendar_id=-1
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	UNION ALL
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt ';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_chnl_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_chnl_mv a, ';
	END IF;
	l_sqltext := l_sqltext ||'
		fii_time_rpt_struct_v cal,
		bim_dimv_media d';
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF;
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	  l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND  d.id (+)= a.activity_id
	AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	)GROUP BY name
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';
	ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
	--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE17,
	null BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE14,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	null VIEWBYID,
	name,
	null meaning,
	SUM(targeted_audience) targeted_audience,
	SUM(responses_positive) responses_positive,
	SUM(leads) leads,
	SUM(rank_a) rank_a ,
	SUM(new_opportunity_amt) new_opportunity_amt,
	SUM(won_opportunity_amt) won_opportunity_amt,
	SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,
	SUM(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt ';

	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_regn_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_regn_mv a, ';
	END IF;
	l_sqltext := l_sqltext ||'
		fii_time_rpt_struct_v cal,
		bis_areas_v d ';

	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF;
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	  AND  d.id (+)= a.object_region
	  AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	  AND cal.calendar_id=-1
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	UNION ALL
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt ';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_regn_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_regn_mv a, ';
	END IF;
	l_sqltext := l_sqltext ||'
		fii_time_rpt_struct_v cal,
		bis_areas_v d';
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF;
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	  l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND  d.id (+)= a.object_region
	AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	)GROUP BY name
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';
	ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
	--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE17,
	null BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE14,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	VIEWBYID,
	name,
	null meaning,
	SUM(targeted_audience) targeted_audience,
	SUM(responses_positive) responses_positive,
	SUM(leads) leads,
	SUM(rank_a) rank_a ,
	SUM(new_opportunity_amt) new_opportunity_amt,
	SUM(won_opportunity_amt) won_opportunity_amt,
	SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,
	SUM(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	SELECT
	decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME)  name,
	a.object_country viewbyid,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		fii_time_rpt_struct_v cal,
		fnd_territories_tl  d ';
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||
	' AND  a.immediate_parent_id is null ';
	END IF;
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	  if l_country <>'N' then
	  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
	  else
	  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	  AND  a.object_country =d.territory_code(+)
	  AND  d.language(+) = userenv(''LANG'')
	  AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	  AND cal.calendar_id=-1
	GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
	UNION ALL
	SELECT
	decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
	a.object_country viewbyid,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		fii_time_rpt_struct_v cal,
		fnd_territories_tl d ';
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id';
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||
	' AND  a.immediate_parent_id is null ';
	END IF;
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	  if l_country <>'N' then
	  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
	  else
	  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND  a.object_country =d.territory_code(+)
	AND d.language(+) = userenv(''LANG'')
	AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
	)GROUP BY name,viewbyid
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';

ELSE
	/************** START OF VIEW BY IS CAMPAIGN AND L_CAMPAIGN_ID IS NULL ***********/

	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE17,
	null BIM_URL1,
	decode(BIM_ATTRIBUTE13,''EONE'',NULL,'||''''||l_url_str||''''||' ) BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	object_type BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE14,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	select
	VIEWBYID,object_type,name,meaning,SUM(targeted_audience) targeted_audience,SUM(responses_positive) responses_positive,
	SUM(leads) leads,SUM(rank_a) rank_a ,SUM(new_opportunity_amt) new_opportunity_amt,SUM(won_opportunity_amt) won_opportunity_amt,SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,SUM(prior_open) prior_open,sum(leads_converted) leads_converted,SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	select
	campname.object_type object_type,camp.VIEWBYID,
	campname.name name,l.meaning meaning,targeted_audience,responses_positive,
	leads,rank_a ,new_opportunity_amt,won_opportunity_amt,orders_booked_amt,orders_invoiced_amt,prior_open,
	leads_converted,prev_new_opportunity_amt
	FROM
	(
	SELECT /*+ NO_MERGE */
	a.source_code_id VIEWBYID,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		fii_time_rpt_struct_v cal ';
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;

	l_sqltext :=  l_sqltext ||' WHERE a.time_id = cal.time_id
						AND  a.period_type_id = cal.period_type_id ';

	/*if (l_prog_view = 'Y') then
	l_sqltext := l_sqltext ||
	' AND a.object_type in (''CAMP'',''RCAM'')';
	ELSE
	l_sqltext := l_sqltext ||
	' AND a.object_type =''CAMP''';
	END IF; */

	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	' AND a.source_code_id = ac.source_code_id
	  AND ac.resource_id = :l_resource_id';
	ELSE
	  IF l_prog_view='Y' then
		  l_sqltext := l_sqltext ||
		 ' AND  a.immediate_parent_id is null ';
	   END IF;
	END IF;

	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	AND a.object_country = :l_country
	AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	AND cal.calendar_id=-1
	AND (a.leads >0 OR a.rank_a >0 OR a.leads_converted >0 OR  a.customers_targeted >0 OR a.responses_positive>0 OR new_opportunity_amt >0 OR won_opportunity_amt >0 OR orders_booked_amt >0 OR a.orders_invoiced_amt >0 )
	GROUP BY a.source_code_id
	UNION ALL
	SELECT /*+ NO_MERGE */
	a.source_code_id VIEWBYID,0 targeted_audience,0 responses_positive,
	0 leads,0 rank_a ,0 new_opportunity_amt,0 won_opportunity_amt,0 orders_booked_amt,0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,0 leads_converted,0 prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		fii_time_rpt_struct_v cal ';
		 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;
	IF l_admin_status = 'N' THEN
		l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	AND  a.period_type_id = cal.period_type_id ';
	/*if (l_prog_view = 'Y') then
	l_sqltext := l_sqltext ||
	' AND a.object_type in (''CAMP'',''RCAM'')';
	ELSE
	l_sqltext := l_sqltext ||
	' AND a.object_type =''CAMP''';
	END IF; */

	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'  AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	IF l_prog_view='Y' then
	l_sqltext := l_sqltext ||
	' AND  a.immediate_parent_id is null ';
	end if;
	END IF;
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
							 ' AND a.category_id = edh.child_id
				   AND edh.object_type = ''CATEGORY_SET''
				   AND edh.object_id = mdcs.category_set_id
				   AND mdcs.functional_area_id = 11
				   AND edh.dbi_flag = ''Y''
				   AND edh.parent_id = :l_cat_id ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND a.object_country = :l_country
	AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	AND (a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) <> 0
	GROUP BY a.source_code_id
	) camp ,BIM_I_OBJ_NAME_MV campname,ams_lookups l
	WHERE campname.source_code_id = camp.viewbyid
	AND campname.language =USERENV(''LANG'')
	AND l.lookup_code = campname.object_type
	AND l.lookup_type = ''AMS_SYS_ARC_QUALIFIER''
	)GROUP BY viewbyid,object_type,name,meaning ) )
	WHERE
	BIM_ATTRIBUTE3 > 0 OR BIM_ATTRIBUTE4 > 0 OR BIM_ATTRIBUTE5 > 0 OR BIM_ATTRIBUTE6 > 0 OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0 OR BIM_ATTRIBUTE9 > 0 OR BIM_ATTRIBUTE10 > 0 OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';

	END IF;

	ELSE
	/***************** DRILL DOWN IN CAMPAIGN HIRERACHY**********/
	if (l_view_by = 'CAMPAIGN+CAMPAIGN') then

	 -- checking for the object type passed from page

	 for i in get_obj_type
	 loop
	 l_object_type:=i.object_type;
	 end loop;

	/*IF l_object_type='CAMP' THEN
	 l_csch_chnl :='|| '' - '' || channel';
	 l_chnl_col:= 'channel,';
	 END IF;*/

	 if l_object_type='CAMP' THEN
	 l_csch_chnl :='|| '' - '' || channel';
	 l_chnl_col := 'channel,';
	 l_chnl_select := ' decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,';
	 l_chnl_from:= ' ,bim_dimv_media chnl ';
	 l_chnl_where := ' AND campname.activity_id =chnl.id (+) ';
	 l_chnl_group := ' decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) ,';

	 END IF;


	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE15,
	null BIM_URL1,
	BIM_URL2,
	BIM_URL3,
	BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning'||l_csch_chnl||' BIM_ATTRIBUTE2,
	decode(object_type,''CSCH'','||''''||l_url_str_csch||''''||'||object_id,''EONE'',NULL,''EVEO'',NULL,'||''''||l_url_str||''''||') BIM_URL2,
	decode(object_type,''CSCH'','||''''||l_url_str_type||''''||'||object_id,NULL) BIM_URL3,
	decode(object_type,''CSCH'',decode(usage,''LITE'',decode(list_header_id,null,null,'||''''||l_url_str_tga||''''||'||list_header_id),NULL),NULL ) BIM_URL4,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	object_type BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE15,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	object_id,
	object_type ,
	VIEWBYID ,
	name ,
	meaning,'||l_chnl_col||'
	decode(object_type,''CSCH'',usage,NULL) usage,
	list_header_id,
	SUM(targeted_audience) targeted_audience,
	SUM(responses_positive) responses_positive,
	SUM(leads) leads,
	SUM(rank_a) rank_a ,
	SUM(new_opportunity_amt) new_opportunity_amt,
	SUM(won_opportunity_amt) won_opportunity_amt,
	SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,
	SUM(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	( ';
	/********** CHILDERN OF PROGRAM *********************/
	l_sqltext := l_sqltext||
	' SELECT /*+LEADING(b)*/
	campname.object_id,
	campname.object_type object_type,
	a.source_code_id VIEWBYID,
	campname.name name,
	l.meaning meaning,'||l_chnl_select||'
	campname.child_object_usage usage,
	NULL list_header_id,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		fii_time_rpt_struct_v cal,
		bim_I_obj_name_mv campname,
		ams_lookups l '||l_chnl_from ;
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;
	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
	END IF; */
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	AND  a.period_type_id = cal.period_type_id
	AND  a.source_code_id = campname.source_code_id
	AND  a.immediate_parent_id = :l_campaign_id
	AND  l.lookup_code = campname.object_type
	AND l.lookup_type = ''AMS_SYS_ARC_QUALIFIER'''||l_chnl_where;
	 /* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF;*/
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	' AND a.category_id = edh.child_id
	  AND edh.object_type = ''CATEGORY_SET''
	  AND edh.object_id = mdcs.category_set_id
	  AND mdcs.functional_area_id = 11
	  AND edh.dbi_flag = ''Y''
	  AND edh.parent_id = :l_cat_id ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	AND a.object_country = :l_country
	AND cal.report_date  in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	AND cal.calendar_id=-1
	AND campname.language =USERENV(''LANG'')
	GROUP BY a.source_code_id,campname.object_type,campname.object_id,
	campname.name, l.meaning,'||l_chnl_group||'campname.child_object_usage
	UNION ALL
	SELECT /*+LEADING(b)*/
	campname.object_id object_id,
	campname.object_type object_type,
	a.source_code_id VIEWBYID,
	campname.name name,
	l.meaning meaning,'||l_chnl_select||'
	campname.child_object_usage usage,
	NULL list_header_id,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		fii_time_rpt_struct_v cal,
		bim_i_obj_name_mv campname,
		ams_lookups l '||l_chnl_from;
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;
	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
	END IF; */
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	AND  a.period_type_id = cal.period_type_id
	AND campname.source_code_id = a.source_code_id
	AND  a.immediate_parent_id = :l_campaign_id
	AND l.lookup_code =  campname.object_type
	AND l.lookup_type = ''AMS_SYS_ARC_QUALIFIER'''||l_chnl_where;
	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF; */
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	' AND a.category_id = edh.child_id
	  AND edh.object_type = ''CATEGORY_SET''
	  AND edh.object_id = mdcs.category_set_id
	  AND mdcs.functional_area_id = 11
	  AND edh.dbi_flag = ''Y''
	  AND edh.parent_id = :l_cat_id ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND a.object_country = :l_country
	AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	AND campname.language =USERENV(''LANG'')
	GROUP BY a.source_code_id,campname.object_type,campname.object_id,
	campname.name, l.meaning,'||l_chnl_group||'campname.child_object_usage ';
	--END IF;
	l_sqltext := l_sqltext ||
	') group by VIEWBYID,object_id,object_type,name,meaning,'||l_chnl_col||' usage,list_header_id
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';

	ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then

	IF l_cat_id is null THEN
	/************** START OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NULL AND CAMPAIGN ID IS NOT NULL ***********/
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE15,
	decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	leaf_node_flag,
	null BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE15,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	VIEWBYID,
	name,
	leaf_node_flag,
	sum(targeted_audience) targeted_audience,
	sum(responses_positive) responses_positive,
	sum(leads) leads,
	sum(rank_a) rank_a ,
	sum(new_opportunity_amt) new_opportunity_amt,
	sum(won_opportunity_amt) won_opportunity_amt,
	sum(orders_booked_amt) orders_booked_amt,
	sum(orders_invoiced_amt) orders_invoiced_amt,
	sum(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	sum(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	( SELECT /*+ORDERED*/
	p.parent_id VIEWBYID,
	p.value  name,
	p.leaf_node_flag leaf_node_flag,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
	FROM  fii_time_rpt_struct_v cal
		  ,BIM_I_OBJ_METS_MV a
		,eni_denorm_hierarchies edh
					,mtl_default_category_sets mdcs
					,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
					   FROM eni_item_vbh_nodes_v e
					   WHERE e.top_node_flag=''Y''
					   AND e.child_id = e.parent_id) p ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac ';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	AND  a.period_type_id = cal.period_type_id
	AND a.category_id = edh.child_id
	AND edh.object_type = ''CATEGORY_SET''
	AND edh.object_id = mdcs.category_set_id
	AND mdcs.functional_area_id = 11
	AND edh.dbi_flag = ''Y''
	AND edh.parent_id = p.parent_id
	AND  a.source_code_id = :l_campaign_id ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	  AND a.object_country = :l_country';
	l_sqltext :=  l_sqltext ||
	' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	AND cal.calendar_id=-1
	GROUP BY p.value,p.parent_id,p.leaf_node_flag
	UNION ALL
	SELECT /*+ORDERED*/
	p.parent_id VIEWBYID,
	p.value  name,
	p.leaf_node_flag leaf_node_flag,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt
	FROM fii_time_rpt_struct_v cal
		 ,BIM_I_OBJ_METS_MV a
		,eni_denorm_hierarchies edh
					,mtl_default_category_sets mdcs
					,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
					   FROM eni_item_vbh_nodes_v e
					   WHERE e.top_node_flag=''Y''
					   AND e.child_id = e.parent_id) p ';
	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	AND  a.period_type_id = cal.period_type_id
	AND a.category_id = edh.child_id
	AND edh.object_type = ''CATEGORY_SET''
	AND edh.object_id = mdcs.category_set_id
	AND mdcs.functional_area_id = 11
	AND edh.dbi_flag = ''Y''
	AND edh.parent_id = p.parent_id
	AND  a.source_code_id = :l_campaign_id ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND a.object_country = :l_country';
	l_sqltext :=  l_sqltext ||
	' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	GROUP BY p.value,p.parent_id,p.leaf_node_flag
	)GROUP BY name,VIEWBYID,leaf_node_flag
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';
	/************** END OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NULL AND CAMPAIGN IS NOT NULL ***********/
	ELSE
	/************** START OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NOT NULL AND CAMPAIGN IS NOT NULL ***********/
	l_dass:=  BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('DASS');
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE15,
	decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	leaf_node_flag,
	null BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE15,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	VIEWBYID,
	name,
	leaf_node_flag,
	sum(targeted_audience) targeted_audience,
	sum(responses_positive) responses_positive,
	sum(leads) leads,
	sum(rank_a) rank_a ,
	sum(new_opportunity_amt) new_opportunity_amt,
	sum(won_opportunity_amt) won_opportunity_amt,
	sum(orders_booked_amt) orders_booked_amt,
	sum(orders_invoiced_amt) orders_invoiced_amt,
	sum(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	sum(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	SELECT /*+ORDERED*/
	p.id VIEWBYID,
	p.value  name,
	p.leaf_node_flag leaf_node_flag,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
	FROM  fii_time_rpt_struct_v cal
		  ,BIM_I_OBJ_METS_MV a
		,eni_denorm_hierarchies edh
				,mtl_default_category_sets mdc
				,(select e.id,e.value,e.leaf_node_flag
				  from eni_item_vbh_nodes_v e
			  where
				  e.parent_id =:l_cat_id
				  AND e.id = e.child_id
				  AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
		  ) p ';
	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	AND  a.period_type_id = cal.period_type_id
	AND a.category_id = edh.child_id
	AND edh.object_type = ''CATEGORY_SET''
	AND edh.object_id = mdc.category_set_id
	AND mdc.functional_area_id = 11
	AND edh.dbi_flag = ''Y''
	AND edh.parent_id = p.id
	AND  a.source_code_id = :l_campaign_id ';
	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
	END IF; */
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	AND a.object_country = :l_country';
	l_sqltext :=  l_sqltext ||
	' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	AND cal.calendar_id=-1
	GROUP BY p.id,p.value,p.leaf_node_flag
	UNION ALL
	SELECT /*+ORDERED*/
	p.id VIEWBYID,
	p.value  name,
	p.leaf_node_flag leaf_node_flag,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt
	FROM  fii_time_rpt_struct_v cal
		  ,BIM_I_OBJ_METS_MV a
		  ,eni_denorm_hierarchies edh
				,mtl_default_category_sets mdc
				,(select e.id,e.value,e.leaf_node_flag
				  from eni_item_vbh_nodes_v e
			  where
				  e.parent_id =:l_cat_id
				  AND e.id = e.child_id
				  AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
		  ) p ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	AND  a.period_type_id = cal.period_type_id
	AND a.category_id = edh.child_id
	AND edh.object_type = ''CATEGORY_SET''
	AND edh.object_id = mdc.category_set_id
	AND mdc.functional_area_id = 11
	AND edh.dbi_flag = ''Y''
	AND edh.parent_id = p.id
	AND  a.source_code_id = :l_campaign_id ';

	/*IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND a.object_country = :l_country';
	l_sqltext :=  l_sqltext ||
	' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	GROUP BY p.id,p.value,p.leaf_node_flag
	/*** directly assigned to the category *************/
	UNION ALL
	SELECT /*+ORDERED*/
	p.id VIEWBYID,
	bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
	''Y'' leaf_node_flag,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
	FROM  fii_time_rpt_struct_v cal
		  ,BIM_I_OBJ_METS_MV a
		,(select e.id id,e.value value
						  from eni_item_vbh_nodes_v e
						  where e.parent_id =  :l_cat_id
						  AND e.parent_id = e.child_id
						  AND leaf_node_flag <> ''Y''
						  ) p ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;*/

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND a.category_id = p.id
	 AND  a.immediate_parent_id = :l_campaign_id ';
	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
	END IF;
	*/
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	  AND a.object_country = :l_country
	  AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	  AND cal.calendar_id=-1
	GROUP BY p.id
	UNION ALL
	SELECT /*+ORDERED*/
	p.id VIEWBYID,
	bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'  name,
	''Y'' leaf_node_flag,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt
	FROM  fii_time_rpt_struct_v cal
		 ,BIM_I_OBJ_METS_MV a
		,(select e.id id,e.value value
						  from eni_item_vbh_nodes_v e
						  where e.parent_id =  :l_cat_id
						  AND e.parent_id = e.child_id
						  AND leaf_node_flag <> ''Y''
						  ) p ';
	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF; */

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.category_id = p.id
	  AND  a.immediate_parent_id = :l_campaign_id ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
	END IF;
	*/
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	  AND a.object_country = :l_country
	  AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	  AND cal.calendar_id=-1
	GROUP BY p.id
	)GROUP BY name,VIEWBYID,leaf_node_flag
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';
	END IF;
	/************** START OF VIEW BY IS MARKETING CHANNEL CAMPAIGN IS NOT NULL ***********/
	ELSIF (l_view_by ='MEDIA+MEDIA') THEN
	--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE15,
	null BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE15,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	null VIEWBYID,
	name,
	null meaning,
	SUM(targeted_audience) targeted_audience,
	SUM(responses_positive) responses_positive,
	SUM(leads) leads,
	SUM(rank_a) rank_a ,
	SUM(new_opportunity_amt) new_opportunity_amt,
	SUM(won_opportunity_amt) won_opportunity_amt,
	SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,
	SUM(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_chnl_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_chnl_mv a, ';
	END IF;*/

	l_sqltext := l_sqltext ||
	' FROM bim_obj_chnl_mv a,
	  fii_time_rpt_struct_v cal,
	  bim_dimv_media d ';

	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	  AND a.source_code_id = ac.source_code_id
	  AND ac.resource_id = :l_resource_id';
	END IF;*/

	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	 ' AND a.category_id = edh.child_id
	   AND edh.object_type = ''CATEGORY_SET''
	   AND edh.object_id = mdcs.category_set_id
	   AND mdcs.functional_area_id = 11
	   AND edh.dbi_flag = ''Y''
	   AND edh.parent_id = :l_cat_id ';
	  end if;

	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	  AND  d.id (+)= a.activity_id
	  AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	  AND cal.calendar_id=-1
	  AND  a.source_code_id = :l_campaign_id
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	UNION ALL
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt ';

	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_chnl_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_chnl_mv a, ';
	END IF;*/

	l_sqltext := l_sqltext ||
	 ' FROM bim_obj_chnl_mv a,
	   fii_time_rpt_struct_v cal,
	   bim_dimv_media d';

	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;


	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';

	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF;
	*/

	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	  ' AND a.category_id = edh.child_id
		AND edh.object_type = ''CATEGORY_SET''
		AND edh.object_id = mdcs.category_set_id
		AND mdcs.functional_area_id = 11
		AND edh.dbi_flag = ''Y''
		AND edh.parent_id = :l_cat_id ';
	  end if;
	  l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND  d.id (+)= a.activity_id
	AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND cal.calendar_id=-1
	AND  a.source_code_id = :l_campaign_id
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	)GROUP BY name
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';
	ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
	--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE15,
	null BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE15,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	null VIEWBYID,
	name,
	null meaning,
	SUM(targeted_audience) targeted_audience,
	SUM(responses_positive) responses_positive,
	SUM(leads) leads,
	SUM(rank_a) rank_a ,
	SUM(new_opportunity_amt) new_opportunity_amt,
	SUM(won_opportunity_amt) won_opportunity_amt,
	SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,
	SUM(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt ';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_regn_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_regn_mv a, ';
	END IF;*/

	l_sqltext := l_sqltext ||
	' FROM bim_obj_regn_mv a,
	  fii_time_rpt_struct_v cal,
	  bis_areas_v d ';

	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	  AND a.source_code_id = ac.source_code_id
	  AND ac.resource_id = :l_resource_id';
	END IF;*/

	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	 ' AND a.category_id = edh.child_id
	   AND edh.object_type = ''CATEGORY_SET''
	   AND edh.object_id = mdcs.category_set_id
	   AND mdcs.functional_area_id = 11
	   AND edh.dbi_flag = ''Y''
	   AND edh.parent_id = :l_cat_id ';
	  end if;

	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	  AND  d.id (+)= a.object_region
	  AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	  AND cal.calendar_id=-1
	  AND  a.source_code_id = :l_campaign_id
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	UNION ALL
	SELECT
	decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt ';

	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||' FROM bim_obj_regn_mv a,bim_i_top_objects ac,  ';
	ELSE
	l_sqltext := l_sqltext ||' FROM bim_mkt_regn_mv a, ';
	END IF;*/

	l_sqltext := l_sqltext ||
	 ' FROM bim_obj_regn_mv a,
	   fii_time_rpt_struct_v cal,
	   bis_areas_v d';

	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;


	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id
	  AND  a.object_country = :l_country';

	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	END IF;
	*/

	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	  ' AND a.category_id = edh.child_id
		AND edh.object_type = ''CATEGORY_SET''
		AND edh.object_id = mdcs.category_set_id
		AND mdcs.functional_area_id = 11
		AND edh.dbi_flag = ''Y''
		AND edh.parent_id = :l_cat_id ';
	  end if;
	  l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	AND  d.id (+)= a.object_region
	AND  cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	AND  cal.calendar_id=-1
	AND  a.source_code_id = :l_campaign_id
	GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
	)GROUP BY name
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';
	ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
	--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
	l_sqltext :=
	'
	SELECT
	VIEWBY,
	VIEWBYID,
	BIM_ATTRIBUTE2,
	BIM_ATTRIBUTE3,
	BIM_ATTRIBUTE4,
	BIM_ATTRIBUTE5,
	BIM_ATTRIBUTE6,
	BIM_ATTRIBUTE7,
	BIM_ATTRIBUTE8,
	BIM_ATTRIBUTE9,
	BIM_ATTRIBUTE10,
	BIM_ATTRIBUTE11,
	BIM_ATTRIBUTE12,
	BIM_ATTRIBUTE13,
	BIM_ATTRIBUTE8 BIM_ATTRIBUTE14,
	BIM_ATTRIBUTE15,
	null BIM_URL1,
	null BIM_URL2,
	null BIM_URL3,
	null BIM_URL4,
	BIM_GRAND_TOTAL1,
	BIM_GRAND_TOTAL2,
	BIM_GRAND_TOTAL3,
	BIM_GRAND_TOTAL4,
	BIM_GRAND_TOTAL5,
	BIM_GRAND_TOTAL6,
	BIM_GRAND_TOTAL7,
	BIM_GRAND_TOTAL8,
	BIM_GRAND_TOTAL9,
	BIM_GRAND_TOTAL6 BIM_GRAND_TOTAL10
	FROM
	(
	SELECT name VIEWBY,
	meaning BIM_ATTRIBUTE2,
	targeted_audience BIM_ATTRIBUTE3,
	responses_positive BIM_ATTRIBUTE4,
	leads BIM_ATTRIBUTE5,
	rank_a BIM_ATTRIBUTE6,
	decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE7,
	new_opportunity_amt BIM_ATTRIBUTE8,
	won_opportunity_amt BIM_ATTRIBUTE9,
	orders_booked_amt BIM_ATTRIBUTE10,
	orders_invoiced_amt BIM_ATTRIBUTE11,
	null BIM_ATTRIBUTE12,
	null BIM_ATTRIBUTE13,
	DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE15,
	sum(targeted_audience) over() BIM_GRAND_TOTAL1,
	sum(responses_positive) over() BIM_GRAND_TOTAL2,
	sum(leads) over() BIM_GRAND_TOTAL3,
	sum(rank_a) over() BIM_GRAND_TOTAL4,
	decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL5,
	sum(new_opportunity_amt) over() BIM_GRAND_TOTAL6,
	sum(won_opportunity_amt) over() BIM_GRAND_TOTAL7,
	sum(orders_booked_amt) over() BIM_GRAND_TOTAL8,
	sum(orders_invoiced_amt) over() BIM_GRAND_TOTAL9,
	VIEWBYID
	FROM
	(
	SELECT
	VIEWBYID,
	name,
	null meaning,
	SUM(targeted_audience) targeted_audience,
	SUM(responses_positive) responses_positive,
	SUM(leads) leads,
	SUM(rank_a) rank_a ,
	SUM(new_opportunity_amt) new_opportunity_amt,
	SUM(won_opportunity_amt) won_opportunity_amt,
	SUM(orders_booked_amt) orders_booked_amt,
	SUM(orders_invoiced_amt) orders_invoiced_amt,
	SUM(prior_open) prior_open,
	sum(leads_converted) leads_converted,
	SUM(prev_new_opportunity_amt) prev_new_opportunity_amt
	FROM
	(
	SELECT
	decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
	a.object_country viewbyid,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.customers_targeted,0)) targeted_audience,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.responses_positive,0)) responses_positive,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0)) leads,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0)) rank_a ,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) new_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,won_opportunity_amt'||l_curr_suffix||',0)) won_opportunity_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_booked_amt'||l_curr_suffix||',0)) orders_booked_amt,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.orders_invoiced_amt'||l_curr_suffix||',0)) orders_invoiced_amt,
	0 prior_open,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		 fii_time_rpt_struct_v cal,
		 fnd_territories_tl d ';
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;
	*/

	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id';
	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||
	' AND  a.parent_object_id is null ';
	END IF;
	*/
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	  ' AND a.category_id = edh.child_id
	   AND edh.object_type = ''CATEGORY_SET''
	   AND edh.object_id = mdcs.category_set_id
	   AND mdcs.functional_area_id = 11
	   AND edh.dbi_flag = ''Y''
	   AND edh.parent_id = :l_cat_id ';
	  end if;
	  if l_country <>'N' then
	  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
	  else
	  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	AND  a.object_country =d.territory_code(+)
	AND d.language(+) = userenv(''LANG'')
	AND  cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	AND  cal.calendar_id=-1
	AND  a.source_code_id = :l_campaign_id
	GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
	UNION ALL
	SELECT
	decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
	a.object_country viewbyid,
	0 targeted_audience,
	0 responses_positive,
	0 leads,
	0 rank_a ,
	0 new_opportunity_amt,
	0 won_opportunity_amt,
	0 orders_booked_amt,
	0 orders_invoiced_amt,
	sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted)) prior_open,
	0 leads_converted,
	0 prev_new_opportunity_amt
	FROM BIM_I_OBJ_METS_MV a,
		 fii_time_rpt_struct_v cal,
		 fnd_territories_tl d ';
	 IF l_cat_id is not null then
	  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	  end if;
	/*
	IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
	END IF;
	*/
	l_sqltext :=  l_sqltext ||
	' WHERE a.time_id = cal.time_id
	  AND  a.period_type_id = cal.period_type_id';

	/* IF l_admin_status = 'N' THEN
	l_sqltext := l_sqltext ||
	'
	AND a.source_code_id = ac.source_code_id
	AND ac.resource_id = :l_resource_id';
	ELSE
	l_sqltext := l_sqltext ||
	' AND  a.parent_object_id is null ';
	END IF;*/
	IF l_cat_id is null then
	l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
	else
	  l_sqltext := l_sqltext ||
	  ' AND a.category_id = edh.child_id
	  AND edh.object_type = ''CATEGORY_SET''
	  AND edh.object_id = mdcs.category_set_id
	  AND mdcs.functional_area_id = 11
	  AND edh.dbi_flag = ''Y''
	  AND edh.parent_id = :l_cat_id ';
	  end if;
	  if l_country <>'N' then
	  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
	  else
	  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
	  end if;
	l_sqltext :=  l_sqltext ||
	' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
	  AND  a.object_country =d.territory_code(+)
	  AND d.language(+) = userenv(''LANG'')
	  AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	  AND cal.calendar_id=-1
	  AND  a.source_code_id = :l_campaign_id
	GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
	)GROUP BY name,viewbyid
	)
	)
	WHERE
	BIM_ATTRIBUTE3 > 0
	OR BIM_ATTRIBUTE4 > 0
	OR BIM_ATTRIBUTE5 > 0
	OR BIM_ATTRIBUTE6 > 0
	OR BIM_ATTRIBUTE7 > 0
	OR BIM_ATTRIBUTE8 > 0
	OR BIM_ATTRIBUTE9 > 0
	OR BIM_ATTRIBUTE10 > 0
	OR BIM_ATTRIBUTE11 > 0
	&ORDER_BY_CLAUSE';
	END IF;
END IF;
  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_campaign_id';
  l_custom_rec.attribute_value := l_campaign_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;



write_debug('GET_PO_RACK_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_PO_RACK_SQL','ERROR',l_sql_errm,l_sqltext);
END GET_PO_RACK_SQL;

PROCEDURE GET_CS_RACK_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)

			  IS

l_sqltext varchar2(15000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(5000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_prev_aod_str varchar2(80);
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_table varchar2(4000);
l_access_clause varchar2(4000);
l_object_type varchar2(30);
l_url_str varchar2(1000);
l_url_str_csch varchar2(1000);
l_url_str_csch_jtf varchar2(3000);
l_url_str_type varchar2(1000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_inner_sqltext varchar2(20000); --- to form inner query to calculate total cost
l_prog_cost1  varchar2(100);
l_prog_cost2  varchar2(100);
l_prog_rev1  varchar2(100);
l_prog_rev2  varchar2(100);
l_csch_chnl  varchar2(100);
l_chnl_select  varchar2(1000);
l_chnl_from  varchar2(1000);
l_chnl_where  varchar2(1000);
l_chnl_group  varchar2(1000);
l_chnl_col   varchar2(10);
l_col1 varchar2(100); ---- to append product category id
l_col2 varchar2(100); ---- to append product category id
l_inner      varchar2(2000);
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_curr_suffix1 VARCHAR2(50);
l_table_bud VARCHAR2(300);
l_where_bud VARCHAR2(300);

l_dass       varchar2(100);  -- variable to store value for  directly assigned lookup value
--l_una       varchar2(100);   -- variable to store value for  Unassigned lookup value
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);

/* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');

BEGIN



	x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
	l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
	bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
											l_as_of_date,
											l_period_type,
											l_record_type_id,
											l_comp_type,
											l_country,
											l_view_by,
											l_cat_id,
											l_campaign_id,
											l_curr,
											l_col_id,
											l_area,
											l_media,
											l_report_name
										  );
	IF (l_curr = '''FII_GLOBAL1''')	THEN

		l_curr_suffix := '';

	ELSIF (l_curr = '''FII_GLOBAL2''')	THEN

		l_curr_suffix := '_s';

	ELSE
		l_curr_suffix := '';

	END IF;
   l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;

   if l_cat_id is not null then
   l_col1:='a.category_id,';
   l_col2:=',a.category_id';
   end if;

/**************************************************************/
   if  l_prog_cost ='BIM_APPROVED_BUDGET' then
        l_prog_cost1:='budget_approved';
        l_prog_cost2:='budget_approved';
   else
       l_prog_cost1:='actual_cost';
       l_prog_cost2:='cost_actual';
       -- column name is diffrent in mv
   end if;

   IF l_revenue = 'BOOKED_AMT' THEN

    l_prog_rev1 :='  booked_amt';
    l_prog_rev2 :=' orders_booked_amt';


   ELSIF l_revenue = 'INVOICED_AMT'   THEN

    l_prog_rev1  :=' invoiced_amt';
    l_prog_rev2 :=' orders_invoiced_amt';


   ELSIF l_revenue = 'WON_OPPR_AMT' THEN

    l_prog_rev1 :=' won_opportunity_amt';
    l_prog_rev2 :='won_opportunity_amt';

   END IF;
/****************************************************************/


   l_admin_status := GET_ADMIN_STATUS;
    --l_admin_status := 'Y';
   /*IF l_admin_status = 'N' THEN
      l_access_table := ',AMS_ACT_ACCESS_DENORM ac ';
      l_access_clause := ' '||
         'AND a.source_code_id = ac.source_code_id AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/


l_url_str :='pFunctionName=BIM_I_CSRR_PHD_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
--l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

if(l_campaign_id is null) then

/********* campaign is null  no drill down in campaign hirerachy*************/

if (l_view_by = 'CAMPAIGN+CAMPAIGN') then
/******************** view by is campaign *****************/
 l_sqltext := '
 SELECT name VIEWBY,
 VIEWBYID,
 meaning BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 object_id BIM_ATTRIBUTE11,
 object_type  BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 null bim_url1,
 decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' ) BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9,
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
object_id,
object_type,
VIEWBYID,
name,
meaning,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT /*+NO_MERGE(camp)*/ campname.object_id object_id,campname.object_type object_type,camp.viewbyid,campname.name name,l.meaning meaning,camp.cost_actual,camp.cost_forecasted,camp.actual_revenue ,camp.revenue_forecasted,
camp.total_actual_cost,camp.total_actual_revenue
FROM
(
SELECT
a.source_code_id VIEWBYID,
SUM('||l_prog_cost1||l_curr_suffix||') cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM BIM_I_CPB_METS_MV a,fii_time_rpt_struct_v cal';
IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

IF l_admin_status = 'N' THEN
-- IF l_prog_view='Y' then
    l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
 /*ELSE
    l_sqltext := l_sqltext ||',ams_act_access_denorm ac  ';
 END IF;*/
END IF;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id';


IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
  AND a.source_code_id = ac.source_code_id
  AND ac.resource_id = :l_resource_id';
ELSE
 -- IF l_prog_view='Y' then
      l_sqltext := l_sqltext ||
     ' AND  a.immediate_parent_id is null ';
  -- END IF;
END IF;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
   ' AND a.category_id = edh.child_id
   AND edh.object_type = ''CATEGORY_SET''
   AND edh.object_id = mdcs.category_set_id
   AND mdcs.functional_area_id = 11
   AND edh.dbi_flag = ''Y''
   AND edh.parent_id = :l_cat_id ';
end if;

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country =:l_country ';
l_sqltext := l_sqltext||'
 AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND ( '||l_prog_cost1||' >0 OR '||l_prog_rev1||' > 0 )
GROUP BY a.source_code_id
UNION ALL
 SELECT
a.source_code_id VIEWBYID,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('||l_prog_cost2||l_curr_suffix||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal';

IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

IF l_admin_status = 'N' THEN
 --IF l_prog_view='Y' then
    l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
 /*ELSE
    l_sqltext := l_sqltext ||',ams_act_access_denorm ac  ';
 END IF; */
END IF;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id ';

/*if (l_prog_view = 'Y') then
l_sqltext := l_sqltext ||
' AND a.object_type in (''CAMP'',''RCAM'')';
ELSE
l_sqltext := l_sqltext ||
' AND a.object_type =''CAMP''';
END IF;*/

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
  AND a.source_code_id = ac.source_code_id
  AND ac.resource_id = :l_resource_id';
ELSE
  IF l_prog_view='Y' then
      l_sqltext := l_sqltext ||
     ' AND  a.immediate_parent_id is null ';
   END IF;
END IF;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
   ' AND a.category_id = edh.child_id
   AND edh.object_type = ''CATEGORY_SET''
   AND edh.object_id = mdcs.category_set_id
   AND mdcs.functional_area_id = 11
   AND edh.dbi_flag = ''Y''
   AND edh.parent_id = :l_cat_id ';
end if;

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND a.object_country =:l_country ';
l_sqltext := l_sqltext||'
 AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND (cost_forecasted > 0 OR revenue_forecasted >0 OR '||l_prog_cost2||' >0 OR '||l_prog_rev2||' > 0 )
GROUP BY a.source_code_id)camp,bim_i_obj_name_mv campname,ams_lookups l
WHERE campname.source_code_id = camp.viewbyid
AND campname.language =USERENV(''LANG'')
AND l.lookup_code = campname.object_type
AND l.lookup_type = ''AMS_SYS_ARC_QUALIFIER''
)GROUP BY VIEWBYID,object_id,object_type,name,meaning
HAVING
sum(cost_actual) <> 0
OR sum(actual_revenue) <> 0
)&ORDER_BY_CLAUSE
';
elsif (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
if l_cat_id is null then
/************** START OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NULL ***********/
/********* building inline view to filter thosedo not have any ptd cost or ptd revenue ***********/

l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a';

IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND a.object_country = :l_country
	      AND a.category_id=-9 ';

IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';

l_sqltext :=
'
 SELECT
 VIEWBY,
 VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9,
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
VIEWBYID,
viewby,
leaf_node_flag,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
( SELECT  /*+ORDERED*/
p.value viewby,
p.parent_id VIEWBYID,
p.leaf_node_flag leaf_node_flag,
sum('|| l_prog_cost1 ||l_curr_suffix||')  cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
,eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac ';
END IF;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id';


IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country ';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
SELECT  /*+ORDERED*/
p.value viewby,
p.parent_id VIEWBYID,
p.leaf_node_flag leaf_node_flag,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('||l_prog_cost2||l_curr_suffix||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM fii_time_rpt_struct_v cal'||l_inner||',BIM_I_OBJ_METS_MV a
          ,eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',BIM_I_TOP_OBJECTS ac  ';
END IF;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id';

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND a.object_country = :l_country ';
l_sqltext :=  l_sqltext ||
' AND cal.report_date =trunc(sysdate)
AND cal.calendar_id=-1
AND a.source_code_id=inr.source_code_id
GROUP BY p.value,p.parent_id,p.leaf_node_flag
) GROUP BY viewbyid,viewby,leaf_node_flag
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
ELSE
l_dass:=  BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('DASS');

/********* building inline view to filter thosedo not have any ptd cost or ptd revenue ***********/

l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';

IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND a.object_country = :l_country
              AND a.category_id = edh.child_id
              AND edh.object_type = ''CATEGORY_SET''
              AND edh.object_id = mdcs.category_set_id
              AND mdcs.functional_area_id = 11
              AND edh.dbi_flag = ''Y''
              AND edh.parent_id = :l_cat_id ';
IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';

l_sqltext :=
'
 SELECT
 VIEWBY,
 VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(total_actual_cost) over ()) /sum(total_actual_cost) over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9,
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
VIEWBYID,
viewby,
leaf_node_flag,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT  /*+ORDERED*/
p.id VIEWBYID,
p.value  VIEWBY,
p.leaf_node_flag leaf_node_flag,
sum('||l_prog_cost1||l_curr_suffix||')  cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
    ,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date =&BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY p.id,p.value,p.leaf_node_flag
UNION ALL
SELECT /*+ORDERED*/
p.id VIEWBYID,
p.value  VIEWBY,
p.leaf_node_flag leaf_node_flag,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('||l_prog_cost2||l_curr_suffix||')  total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM fii_time_rpt_struct_v cal'||L_INNER||'
     ,BIM_I_OBJ_METS_MV a
    ,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND a.source_code_id=inr.source_code_id
GROUP BY p.id,p.value,p.leaf_node_flag
/*** directly assigned to the category *************/
UNION ALL
SELECT /*+ORDERED*/
p.id VIEWBYID,
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'  viewby,
''Y'' leaf_node_flag,
sum('||l_prog_cost1||l_curr_suffix||')  cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
    ,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = p.id';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date =&BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY p.id
UNION ALL
SELECT /*+ORDERED*/
p.id VIEWBYID,
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'  viewby,
''Y'' leaf_node_flag,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('||l_prog_cost2||l_curr_suffix||')  total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||')   total_actual_revenue
FROM fii_time_rpt_struct_v cal'||l_inner||',BIM_I_OBJ_METS_MV a
    ,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = p.id ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND a.source_code_id=inr.source_code_id
group by p.id
)GROUP BY VIEWBYID,viewby,leaf_node_flag
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
end if;

ELSIF (l_view_by ='MEDIA+MEDIA') THEN

--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');

/********* building inline view to filter those objects do not have any ptd cost or ptd revenue ***********/

l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a';

 IF l_cat_id is not null then
  l_inner := l_inner||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND a.object_country = :l_country ';

IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF;
IF l_cat_id is null then
l_inner := l_inner ||' AND a.category_id = -9 ';
else
  l_inner := l_inner ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';

l_sqltext :=
'
SELECT
 VIEWBY,
 null VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 null BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9,
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11

FROM
(
SELECT
viewby,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
sum('|| l_prog_cost1 ||l_curr_suffix||')  cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||' FROM bim_i_cpb_chnl_mv a,bim_i_top_objects ac,  ';
ELSE
l_sqltext := l_sqltext ||' FROM bim_i_cpb_chnl_mv a, ';
END IF;
l_sqltext := l_sqltext ||'
    fii_time_rpt_struct_v cal,
    bim_dimv_media d ';

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND  d.id (+)= a.activity_id
  AND cal.report_date =&BIS_CURRENT_ASOF_DATE
  AND cal.calendar_id=-1
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.source_code_id
UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||')    total_actual_revenue ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||' FROM fii_time_rpt_struct_v cal'||l_inner||',bim_obj_chnl_mv a,bim_i_top_objects ac,bim_dimv_media d  ';
ELSE
l_sqltext := l_sqltext ||' FROM fii_time_rpt_struct_v cal'||l_inner||',bim_obj_chnl_mv a,bim_dimv_media d ';
END IF;

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
  l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND  d.id (+)= a.activity_id
AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND a.source_code_id=inr.source_code_id
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
)
GROUP BY viewby
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
/********* building inline view to filter thosedo not have any ptd cost or ptd revenue ***********/

l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a';

 IF l_cat_id is not null then
  l_inner := l_inner||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND a.object_country = :l_country ';

IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF;
IF l_cat_id is null then
l_inner := l_inner ||' AND a.category_id = -9 ';
else
  l_inner := l_inner ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';

l_sqltext :=
'
SELECT
 VIEWBY,
 null VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 null BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9,
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11

FROM
(
SELECT
viewby,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
sum('|| l_prog_cost1 ||l_curr_suffix||')  cost_actual,
0 cost_forecasted,
sum('|| l_prog_rev1 ||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||' FROM bim_i_cpb_regn_mv a,bim_i_top_objects ac,  ';
ELSE
l_sqltext := l_sqltext ||' FROM bim_i_cpb_regn_mv a, ';
END IF;
l_sqltext := l_sqltext ||'
    fii_time_rpt_struct_v cal,
    bis_areas_v d ';

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND  d.id (+)= a.object_region
  AND cal.report_date =&BIS_CURRENT_ASOF_DATE
  AND cal.calendar_id=-1
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix||') total_actual_cost,
sum('|| l_prog_rev2 ||l_curr_suffix||')  total_actual_revenue ';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||' FROM fii_time_rpt_struct_v cal'||l_inner||',bim_obj_regn_mv a,bim_i_top_objects ac,bis_areas_v d  ';
ELSE
l_sqltext := l_sqltext ||' FROM fii_time_rpt_struct_v cal'||l_inner||',bim_obj_regn_mv a,bis_areas_v d ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
  l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND  d.id (+)= a.object_region
AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND a.source_code_id=inr.source_code_id
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
)
GROUP BY viewby
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
/********* building inline view to filter thosedo not have any ptd cost or ptd revenue ***********/

l_inner:=   '( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a';

 IF l_cat_id is not null then
  l_inner := l_inner||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND a.object_country = :l_country ';

IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF;
IF l_cat_id is null then
l_inner := l_inner ||' AND a.category_id = -9 ';
else
  l_inner := l_inner ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';

l_sqltext :=
'
 SELECT
 VIEWBY,
 VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance    BIM_ATTRIBUTE18,
 null BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9,
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
viewby,
viewbyid,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT
decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) viewby,
a.object_country viewbyid,
sum('|| l_prog_cost1 ||l_curr_suffix||')  cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM BIM_I_CPB_METS_MV a,
     fii_time_rpt_struct_v cal,
     fnd_territories_tl d ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||
' AND  a.immediate_parent_id is null ';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
  if l_country <>'N' then
  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
  else
  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND  a.object_country =d.territory_code(+)
  AND d.language(+) = userenv(''LANG'')
  AND cal.report_date =&BIS_CURRENT_ASOF_DATE
  AND cal.calendar_id=-1
GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
UNION ALL
SELECT /*+ordered*/
decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) viewby,
a.object_country viewbyid,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM '||l_inner||',fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs,fnd_territories_tl d';
  else
  l_sqltext := l_sqltext ||' ,fnd_territories_tl d';
  end if;

  IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||
' AND  a.immediate_parent_id is null ';
END IF;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
  if l_country <>'N' then
  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
  else
  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND  a.object_country =d.territory_code(+)
AND d.language(+) = userenv(''LANG'')
AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND a.source_code_id=inr.source_code_id
group by decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
)GROUP BY viewby,viewbyid
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
end if;

ELSE
/*********************** starting campaign drill down ************************/

if (l_view_by = 'CAMPAIGN+CAMPAIGN') then

 -- checking for the object type passed from page

 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;

if l_object_type='CAMP' THEN
 l_csch_chnl :='|| '' - '' || channel';
 l_chnl_col := 'channel,';
 l_chnl_select := ' decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,';
 l_chnl_from:= ' ,bim_dimv_media chnl ';
 l_chnl_where := ' AND camp.activity_id =chnl.id (+) ';
 l_chnl_group := ' decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) ,';

 END IF;


/******** view by is campaign **********/
 l_sqltext :=
 ' SELECT name VIEWBY,
 VIEWBYID,
 meaning'||l_csch_chnl||' BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 object_type  BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 null BIM_URL1,
 decode(object_type,''CSCH'','||''''||l_url_str_csch||''''||'||object_id,''EONE'',NULL,''EVEO'',NULL,'||''''||l_url_str||''''||') BIM_URL2,
 decode(object_type,''CSCH'','||''''||l_url_str_type||''''||'||object_id,NULL ) BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5, /*total roi*/
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8, /*forecasted roi*/
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9, /* cost variance*/
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
object_id,
object_type,
VIEWBYID,
name,
meaning,'||l_chnl_col||'
decode(object_type,''CSCH'',usage,NULL) usage,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
( ';

l_curr_suffix1 :=l_curr_suffix;

IF l_object_type in ('CAMP','EVEH','CSCH') AND l_prog_cost ='BIM_APPROVED_BUDGET'
THEN

--l_table_bud :=  ' bim_i_marketing_facts facts,';

--l_where_bud := ' AND facts.source_code_id = a.source_code_id';
	if l_curr_suffix is null then
		l_prog_cost1 := 'a.budget_approved_sch';
		l_prog_cost2 := 'a.budget_approved_sch';
	else
		l_curr_suffix1 := null;
		l_prog_cost1 := 'a.budget_approved_sch_s';
		l_prog_cost2 := 'a.budget_approved_sch_s';
	end if;

end if;
l_sqltext := l_sqltext||
' SELECT /*+LEADING(b)*/
camp.object_id,
camp.object_type object_type,
a.source_code_id VIEWBYID,
camp.name name,
l.meaning meaning,'||l_chnl_select||'
camp.child_object_usage usage,
sum('|| l_prog_cost1 ||l_curr_suffix1||')  cost_actual,
0 cost_forecasted,
SUM(a.'||l_prog_rev1||l_curr_suffix||')  actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM  BIM_I_CPB_METS_MV a,
    fii_time_rpt_struct_v cal,
    bim_i_obj_name_mv camp,
    ams_lookups l'||l_chnl_from;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND camp.source_code_id = a.source_code_id
AND  a.immediate_parent_id =  :l_campaign_id
AND l.lookup_code = camp.object_type
AND l.lookup_type = ''AMS_SYS_ARC_QUALIFIER'''||l_chnl_where||l_where_bud;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
' AND a.category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''
  AND edh.object_id = mdcs.category_set_id
  AND mdcs.functional_area_id = 11
  AND edh.dbi_flag = ''Y''
  AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date =&BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND camp.language =USERENV(''LANG'')
GROUP BY a.source_code_id,camp.object_id,camp.object_type,
camp.name, l.meaning,'||l_chnl_group||'camp.child_object_usage
UNION ALL
SELECT /*+LEADING(b)*/
camp.object_id,
camp.object_type object_type,
a.source_code_id VIEWBYID,
camp.name name,
l.meaning meaning,'||l_chnl_select||'
camp.child_object_usage usage,
0 cost_actual,
SUM(a.cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(a.revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix1||') total_actual_cost,
SUM(a.'||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM  BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    bim_i_obj_name_mv camp,
    ams_lookups l'||l_chnl_from;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND camp.source_code_id = a.source_code_id
AND  a.immediate_parent_id = :l_campaign_id
AND l.lookup_code = camp.object_type
AND l.lookup_type = ''AMS_SYS_ARC_QUALIFIER'''||l_chnl_where||l_where_bud;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
' AND a.category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''
  AND edh.object_id = mdcs.category_set_id
  AND mdcs.functional_area_id = 11
  AND edh.dbi_flag = ''Y''
  AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND camp.language =USERENV(''LANG'')
GROUP BY a.source_code_id,camp.object_id,camp.object_type,
camp.name, l.meaning,'||l_chnl_group||'camp.child_object_usage ';
l_sqltext := l_sqltext ||
') group by VIEWBYID,object_type,object_id,name, meaning'||l_csch_chnl||', usage
HAVING
sum(cost_actual) <> 0
OR sum(actual_revenue) <> 0
)
&ORDER_BY_CLAUSE
';
ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then

IF l_cat_id is null THEN
/************** START OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NULL AND CAMPAIGN ID IS NOT NULL ***********/

/* l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,bim_i_source_codes b,BIM_I_CPB_METS_MV a';

 IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND  a.parent_denorm_type = b.object_type
              AND  a.parent_object_id = b.object_id
              AND  b.child_object_id = 0
              AND  b.source_code_id = :l_campaign_id
	      AND a.object_country = :l_country
	      AND a.category_id=-9 '; */

/* IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF; */
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';

l_sqltext :=
'
 SELECT
 VIEWBY,
 VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8, /* forecasted roi */
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9, /* cost variance */
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
VIEWBYID,
viewby,
leaf_node_flag,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT /*+ORDERED*/
p.parent_id VIEWBYID,
p.value  viewby,
p.leaf_node_flag leaf_node_flag,
sum('|| l_prog_cost1 ||l_curr_suffix1||') cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM fii_time_rpt_struct_v cal ,BIM_I_CPB_METS_MV a
    ,eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac ';
END IF;*/

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND  a.source_code_id = :l_campaign_id ';

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF; */

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date =&BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY p.value,p.parent_id,p.leaf_node_flag
UNION ALL
SELECT /*+ORDERED*/
p.parent_id VIEWBYID,
p.value  viewby,
p.leaf_node_flag leaf_node_flag,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix1||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
      ,eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';

/*IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;*/

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.parent_id
AND  a.source_code_id = :l_campaign_id ';

 /*IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF; */

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
GROUP BY p.value,p.parent_id,p.leaf_node_flag
) GROUP BY VIEWBYID,viewby,leaf_node_flag
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
ELSE

/************** START OF VIEW BY IS PRODUCT CATEGORY AND PRODUCT CATEGORY IS NOT NULL AND CAMPAIGN ID IS NOT NULL ***********/

/********* building inline view to filter thosedo not have any ptd cost or ptd revenue ***********/
l_dass:=  BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('DASS');
/* l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,bim_i_source_codes b,bim_i_cpb_mets_mv a,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';

 IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND  a.parent_denorm_type = b.object_type
              AND  a.parent_object_id = b.object_id
              AND  b.child_object_id = 0
              AND  b.source_code_id = :l_campaign_id
	      AND a.object_country = :l_country
              AND a.category_id = edh.child_id
              AND edh.object_type = ''CATEGORY_SET''
              AND edh.object_id = mdcs.category_set_id
              AND mdcs.functional_area_id = 11
              AND edh.dbi_flag = ''Y''
              AND edh.parent_id = :l_cat_id '; */

/* IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF;*/

l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';

l_sqltext :=
'
 SELECT
 VIEWBY,
 VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5,
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8, /* forecasted roi*/
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9, /*cost variance*/
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
VIEWBYID,
viewby,
leaf_node_flag,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT /*+ORDERED*/
p.id VIEWBYID,
p.value  viewby,
p.leaf_node_flag leaf_node_flag,
sum('|| l_prog_cost1 ||l_curr_suffix1||') cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
      ,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

/*IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;*/

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND  a.source_code_id = :l_campaign_id ';
/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;  */
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date =&BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY p.id,p.value,p.leaf_node_flag
UNION ALL
SELECT /*+ORDERED*/
p.id VIEWBYID,
p.value  name,
p.leaf_node_flag leaf_node_flag,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix1||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
    ,eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
               where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

 /*IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;*/

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.category_id = edh.child_id
AND edh.object_type = ''CATEGORY_SET''
AND edh.object_id = mdc.category_set_id
AND mdc.functional_area_id = 11
AND edh.dbi_flag = ''Y''
AND edh.parent_id = p.id
AND a.source_code_id = :l_campaign_id ';

/*IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF; */

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND a.object_country = :l_country';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
GROUP BY p.id,p.value,p.leaf_node_flag
/*** directly assigned to the category *************/
UNION ALL
SELECT /*+ORDERED*/
p.id VIEWBYID,
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'  viewby,
''Y'' leaf_node_flag ,
sum('|| l_prog_cost1 ||l_curr_suffix1||') cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
      ,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF; */

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND a.category_id = p.id
  AND a.source_code_id = :l_campaign_id ';

/*IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
*/

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND a.object_country = :l_country
  AND cal.report_date = &BIS_CURRENT_ASOF_DATE
  AND cal.calendar_id=-1
 GROUP BY p.id
UNION ALL
SELECT /*+ORDERED*/
p.id VIEWBYID,
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'  viewby,
''Y'' leaf_node_flag,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix1||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
        ,(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';
/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF; */

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND a.category_id = p.id
  AND  a.source_code_id = :l_campaign_id ';

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||' AND a.immediate_parent_id is null';
END IF;
*/
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
  AND a.object_country = :l_country
  AND cal.report_date = trunc(sysdate)
  AND cal.calendar_id=-1
GROUP BY p.id
)GROUP BY VIEWBYID,viewby,leaf_node_flag
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
END IF;
/**********************************************************************************************************/
/************** START OF VIEW BY IS MARKETING CHANNEL CAMPAIGN IS NOT NULL ***********/
ELSIF (l_view_by ='MEDIA+MEDIA') THEN
--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');

/* l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,bim_i_source_codes b,BIM_I_CPB_METS_MV a';

 IF l_cat_id is not null then
  l_inner := l_inner||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND  a.period_type_id=cal.period_type_id
              AND  cal.calendar_id=-1
              AND  cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND  BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND  a.parent_denorm_type = b.object_type
              AND  a.parent_object_id = b.object_id
              AND  b.child_object_id = 0
              AND  b.source_code_id = :l_campaign_id
	      AND  a.object_country = :l_country  ';

IF l_cat_id is null then
l_inner := l_inner ||' AND a.category_id = -9 ';
else
  l_inner := l_inner ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr ';  */


l_sqltext :=
'
SELECT
 VIEWBY,
 null VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 null BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5, /*total roi*/
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,/* forecasted roi*/
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9, /* cost variance*/
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
viewby,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
sum('|| l_prog_cost1 ||l_curr_suffix1||') cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue ';

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||' FROM bim_obj_chnl_mv a,bim_i_top_objects ac,  ';
ELSE
l_sqltext := l_sqltext ||' FROM bim_mkt_chnl_mv a, ';
END IF;*/

l_sqltext := l_sqltext ||
' FROM fii_time_rpt_struct_v cal,bim_i_cpb_chnl_mv a,bim_dimv_media d ';

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
  AND a.source_code_id = ac.source_code_id
  AND ac.resource_id = :l_resource_id';
END IF;*/

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
 ' AND a.category_id = edh.child_id
   AND edh.object_type = ''CATEGORY_SET''
   AND edh.object_id = mdcs.category_set_id
   AND mdcs.functional_area_id = 11
   AND edh.dbi_flag = ''Y''
   AND edh.parent_id = :l_cat_id ';
  end if;

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND  d.id (+)= a.activity_id
  AND cal.report_date = &BIS_CURRENT_ASOF_DATE
  AND cal.calendar_id=-1
  AND  a.source_code_id = :l_campaign_id
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix1||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue  ';

/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||' FROM bim_obj_chnl_mv a,bim_i_top_objects ac,  ';
ELSE
l_sqltext := l_sqltext ||' FROM bim_mkt_chnl_mv a, ';
END IF;*/

l_sqltext := l_sqltext ||
 ' FROM fii_time_rpt_struct_v cal,bim_obj_chnl_mv a,bim_dimv_media d';

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';

/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
END IF;
*/

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
  l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND  d.id (+)= a.activity_id
AND cal.report_date =  trunc(sysdate)
AND cal.calendar_id=-1
AND  a.source_code_id = :l_campaign_id
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
)GROUP BY viewby
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN

--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');

/********* building inline view to filter thosedo not have any ptd cost or ptd revenue ***********/

/* l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,bim_i_source_codes b,BIM_I_CPB_METS_MV a';

 IF l_cat_id is not null then
  l_inner := l_inner||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND  a.parent_denorm_type = b.object_type
              AND  a.parent_object_id = b.object_id
              AND  b.child_object_id = 0
              AND  b.source_code_id = :l_campaign_id
	      AND a.object_country = :l_country  ';


IF l_cat_id is null then
l_inner := l_inner ||' AND a.category_id = -9 ';
else
  l_inner := l_inner ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr '; */


l_sqltext :=
'
SELECT
 VIEWBY,
 null VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 null BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5, /*total roi*/
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8,/* forecasted roi*/
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9, /* cost variance*/
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
viewby,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM (

SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
sum('|| l_prog_cost1 ||l_curr_suffix1||') cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue ';

l_sqltext := l_sqltext ||
' FROM bim_i_cpb_regn_mv a,
  fii_time_rpt_struct_v cal,
  bis_areas_v d ';

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
 ' AND a.category_id = edh.child_id
   AND edh.object_type = ''CATEGORY_SET''
   AND edh.object_id = mdcs.category_set_id
   AND mdcs.functional_area_id = 11
   AND edh.dbi_flag = ''Y''
   AND edh.parent_id = :l_cat_id ';
  end if;

l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND  d.id (+)= a.object_region
  AND cal.report_date = &BIS_CURRENT_ASOF_DATE
  AND cal.calendar_id=-1
  AND  a.source_code_id = :l_campaign_id
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) viewby,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix1||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue  ';

l_sqltext := l_sqltext ||
 ' FROM fii_time_rpt_struct_v cal,bim_obj_regn_mv a,bis_areas_v d';

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id
  AND  a.object_country = :l_country';

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
  l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND  d.id (+)= a.object_region
AND cal.report_date =  trunc(sysdate)
AND cal.calendar_id=-1
AND  a.source_code_id = :l_campaign_id
GROUP BY decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value)
)GROUP BY viewby
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN

--l_una:= BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');

/********* building inline view to filter thosedo not have any ptd cost or ptd revenue ***********/

/* l_inner:=   ',( SELECT DISTINCT a.source_code_id
                FROM fii_time_rpt_struct_v cal,bim_i_source_codes b,BIM_I_CPB_METS_MV a';

 IF l_cat_id is not null then
  l_inner := l_inner||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if; */

/* IF l_admin_status = 'N' THEN
l_inner := l_inner ||',bim_i_top_objects ac ';
END IF; */

/* l_inner:=l_inner||' WHERE  a.time_id=cal.time_id
              AND a.period_type_id=cal.period_type_id
              AND cal.calendar_id=-1
              AND cal.report_date =&BIS_CURRENT_ASOF_DATE
	      AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
	      AND  a.parent_denorm_type = b.object_type
              AND  a.parent_object_id = b.object_id
              AND  b.child_object_id = 0
              AND  b.source_code_id = :l_campaign_id
	      AND a.object_country = :l_country  '; */

/* IF l_admin_status = 'N' THEN
l_inner := l_inner ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_inner := l_inner ||' AND a.immediate_parent_id is null';
END IF;
*/

 /* IF l_cat_id is null then
l_inner := l_inner ||' AND a.category_id = -9 ';
else
  l_inner := l_inner ||
  ' AND a.category_id = edh.child_id
    AND edh.object_type = ''CATEGORY_SET''
    AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND edh.dbi_flag = ''Y''
    AND edh.parent_id = :l_cat_id ';
  end if;
l_inner:=l_inner||' AND ( '||l_prog_cost1||' <>0 or '||l_prog_rev1||' <>0)) inr '; */

l_sqltext :=
'
 SELECT
 VIEWBY,
 VIEWBYID,
 null BIM_ATTRIBUTE2,
 cost_actual BIM_ATTRIBUTE3,
 actual_revenue BIM_ATTRIBUTE4,
 total_actual_cost BIM_ATTRIBUTE5,
 total_actual_revenue BIM_ATTRIBUTE6,
 total_roi BIM_ATTRIBUTE7,
 cost_forecasted BIM_ATTRIBUTE8,
 revenue_forecasted BIM_ATTRIBUTE9,
 forecast_roi BIM_ATTRIBUTE10,
 null BIM_ATTRIBUTE11,
 null BIM_ATTRIBUTE15,
 null BIM_URL1,
 NULL BIM_URL2,
 NULL BIM_URL3,
 cost_variance BIM_ATTRIBUTE16,
 rev_variance  BIM_ATTRIBUTE17,
 roi_variance     BIM_ATTRIBUTE18,
 sum(cost_actual) over() BIM_GRAND_TOTAL1,
 sum(actual_revenue) over() BIM_GRAND_TOTAL2,
 sum(total_actual_cost) over() BIM_GRAND_TOTAL3,
 sum(total_actual_revenue) over() BIM_GRAND_TOTAL4,
case
when sum(total_actual_cost) over()=0
then null
else
((sum(total_actual_revenue) over()-sum(total_actual_cost) over ()) /sum(total_actual_cost)over () )*100 end  BIM_GRAND_TOTAL5, /*total roi*/
sum(cost_forecasted) over() BIM_GRAND_TOTAL6,
sum(revenue_forecasted) over() BIM_GRAND_TOTAL7,
case
when sum(cost_forecasted) over()=0
then null
else
((sum(revenue_forecasted) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL8, /* forecasted roi*/
case when sum(cost_forecasted) over()=0
then null
else
((sum(total_actual_cost) over() - sum(cost_forecasted) over ()) /sum(cost_forecasted) over () )*100 end  BIM_GRAND_TOTAL9, /* cost variance*/
case
when sum(revenue_forecasted) over()=0
then null
else
((sum(total_actual_revenue) over() - sum(revenue_forecasted) over ()) /sum(revenue_forecasted) over () )*100 end  BIM_GRAND_TOTAL10 ,
case when sum(cost_forecasted) over() =0 then null
     when sum(total_actual_cost) over() =0 then null
     when sum(revenue_forecasted) over() - sum(cost_forecasted) over() =0 then null
     else
    ( ( ( ( sum(total_actual_revenue) over() - sum(total_actual_cost) over())/ sum(total_actual_cost) over()) -
        ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over()) )
      / ( ( sum(revenue_forecasted) over() - sum(cost_forecasted) over())/ sum(cost_forecasted) over())   )*100
   end BIM_GRAND_TOTAL11
FROM
(
SELECT
viewby,
viewbyid,
sum(cost_actual) cost_actual,
SUM(cost_forecasted) cost_forecasted,
SUM(actual_revenue) actual_revenue ,
SUM(revenue_forecasted) revenue_forecasted,
SUM(total_actual_cost) total_actual_cost,
SUM(total_actual_revenue) total_actual_revenue,
case when sum(cost_forecasted) = 0 then null else ((( sum(total_actual_cost)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end  cost_variance,
case when sum(revenue_forecasted) = 0 then null else ((( sum(total_actual_revenue)-sum(revenue_forecasted) )/sum(revenue_forecasted)) *100 ) end rev_variance,
case when sum(total_actual_cost) = 0 then null else ((( sum(total_actual_revenue)-sum(total_actual_cost) )/sum(total_actual_cost)) *100) end  total_roi,
case when sum(cost_forecasted) = 0 then null else ((( sum(revenue_forecasted)-sum(cost_forecasted) )/sum(cost_forecasted)) *100 ) end forecast_roi,
case when sum(cost_forecasted) =0 then null
     when sum(total_actual_cost) =0 then null
     when sum(revenue_forecasted)-sum(cost_forecasted) =0 then null
     else
    ( ( ( ( sum(total_actual_revenue)- sum(total_actual_cost))/sum(total_actual_cost) ) -
        ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted)) )
      / ( ( sum(revenue_forecasted)- sum(cost_forecasted))/ sum(cost_forecasted))   )*100
   end roi_variance
FROM(
SELECT
decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) viewby,
a.object_country viewbyid,
sum('|| l_prog_cost1 ||l_curr_suffix1||') cost_actual,
0 cost_forecasted,
SUM('||l_prog_rev1||l_curr_suffix||') actual_revenue ,
0 revenue_forecasted,
0 total_actual_cost,
0 total_actual_revenue
FROM BIM_I_CPB_METS_MV a,fii_time_rpt_struct_v cal,fnd_territories_tl d ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
*/

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id AND  a.period_type_id = cal.period_type_id';
/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||
' AND  a.parent_object_id is null ';
END IF;
*/
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
  ' AND a.category_id = edh.child_id AND edh.object_type = ''CATEGORY_SET''
   AND edh.object_id = mdcs.category_set_id  AND mdcs.functional_area_id = 11  AND edh.dbi_flag = ''Y''
   AND edh.parent_id = :l_cat_id ';
  end if;
  if l_country <>'N' then
  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
  else
  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND  a.object_country =d.territory_code(+)
AND d.language(+) = userenv(''LANG'')
AND cal.report_date =&BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND  a.source_code_id = :l_campaign_id
GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
UNION ALL
SELECT
decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) viewby,
a.object_country viewbyid,
0 cost_actual,
SUM(cost_forecasted'||l_curr_suffix||') cost_forecasted,
0 actual_revenue ,
SUM(revenue_forecasted'||l_curr_suffix||') revenue_forecasted,
sum('|| l_prog_cost2 ||l_curr_suffix1||') total_actual_cost,
SUM('||l_prog_rev2||l_curr_suffix||') total_actual_revenue
FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a,fnd_territories_tl d ';

 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;
/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',bim_i_top_objects ac  ';
END IF;
*/
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
  AND  a.period_type_id = cal.period_type_id';

/* IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
'
AND a.source_code_id = ac.source_code_id
AND ac.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext ||
' AND  a.parent_object_id is null ';
END IF;*/
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||
  ' AND a.category_id = edh.child_id
  AND edh.object_type = ''CATEGORY_SET''
  AND edh.object_id = mdcs.category_set_id
  AND mdcs.functional_area_id = 11
  AND edh.dbi_flag = ''Y''
  AND edh.parent_id = :l_cat_id ';
  end if;
  if l_country <>'N' then
  l_sqltext :=  l_sqltext || ' AND a.object_country = :l_country ';
  else
  l_sqltext :=  l_sqltext || ' AND a.object_country <>''N'' ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id
AND  a.object_country =d.territory_code(+)
AND d.language(+) = userenv(''LANG'')
AND cal.report_date = trunc(sysdate)
AND cal.calendar_id=-1
AND  a.source_code_id = :l_campaign_id
GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country
)GROUP BY viewby,viewbyid
)
WHERE cost_actual <>0 OR actual_revenue <>0 OR total_actual_cost <>0 OR total_actual_revenue <>0 OR cost_forecasted <>0 OR revenue_forecasted <>0
&ORDER_BY_CLAUSE';
END IF;
END IF;
  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_campaign_id';
  l_custom_rec.attribute_value := l_campaign_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;



write_debug('GET_CS_RACK_SQL','test','test',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_CS_RACK_SQL','ERROR',l_sql_errm,l_sqltext);
END GET_CS_RACK_SQL;

FUNCTION GET_BIM_TEST return VARCHAR2 IS
l_sqltext varchar2(4000);

BEGIN
--l_sqltext := 'SELECT column1 BIM_ATTRIBUTE1,column2 BIM_ATTRIBUTE2 FROM BIM_TEST';
l_sqltext := 'test';
return l_sqltext;
END GET_BIM_TEST;



PROCEDURE GET_TOP_LEADS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(4000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);

BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;

   l_admin_status := GET_ADMIN_STATUS;
   /*IF l_admin_flag = 'N' THEN
      l_access_table := ',AMS_ACT_ACCESS_DENORM ac ';
      l_access_clause := 'AND a.object_type = ac.object_type '||
         'AND a.object_id = ac.object_id AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/

--if (l_view_by = 'CAMPAIGN+CAMPAIGN') then
l_sqltext :=
'SELECT campaign_name BIM_ATTRIBUTE1,
camp_lead_count BIM_ATTRIBUTE2,
event_name BIM_ATTRIBUTE3,
even_lead_count BIM_ATTRIBUTE4
FROM
(
select object_id, campaign_name,camp_lead_count,event_name,even_lead_count
FROM
( SELECT
a.object_id object_id,
camp.campaign_name campaign_name,
SUM(leads) camp_lead_count,
null event_name,
0 even_lead_count
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    ams_campaigns_all_tl camp
    ';
   IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' ,ENI_ITEM_VBH_NODES_V e';
  end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND  a.object_type= ''CAMP''
AND camp.campaign_id(+) = a.object_id';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND e.parent_id = :l_cat_id
   AND a.category_id =  e.id ';
  end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND a.object_type = ac.object_type
AND a.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND camp.language(+)=USERENV(''LANG'')
GROUP BY a.object_id,
camp.campaign_name
having SUM(leads) > 0
)
where rownum<10

UNION ALL
select object_id, campaign_name,camp_lead_count,event_name,even_lead_count
from
(
SELECT
a.object_id object_id,
null campaign_name,
0 camp_lead_count,
eve.event_header_name event_name,
sum(a.leads) even_lead_count
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    ams_event_headers_all_tl eve
    ';
    IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' ,ENI_ITEM_VBH_NODES_V e';
  end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND  a.object_type= ''EVEH''
AND eve.event_header_id(+) = a.object_id';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND a.object_type = ac.object_type
AND a.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND e.parent_id = :l_cat_id
   AND a.category_id =  e.id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND eve.language(+)=USERENV(''LANG'')
GROUP BY a.object_id,
eve.event_header_name
having sum(leads)>0
order by even_lead_count desc)
where rownum<10
) a

';
--end if;


  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

write_debug('GET_TOP_LEADS_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_TOP_LEADS_SQL','ERROR',l_sql_errm,l_sqltext);
END GET_TOP_LEADS_SQL;

PROCEDURE GET_TOP_OPPS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(4000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
   l_admin_status := GET_ADMIN_STATUS;
   /*IF l_admin_flag = 'N' THEN
      l_access_table := ',AMS_ACT_ACCESS_DENORM ac ';
      l_access_clause := 'AND a.object_type = ac.object_type '||
         'AND a.object_id = ac.object_id AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/

--if (l_view_by = 'CAMPAIGN+CAMPAIGN') then
l_sqltext :=
'SELECT campaign_name BIM_ATTRIBUTE1,
camp_opp_count BIM_ATTRIBUTE2,
event_name BIM_ATTRIBUTE3,
even_opp_count BIM_ATTRIBUTE4
FROM
(
SELECT
object_id,campaign_name,camp_opp_count,event_name,even_opp_count
FROM
( SELECT
a.object_id object_id,
camp.campaign_name campaign_name,
0 camp_opp_count,
null event_name,
0 even_opp_count
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    ams_campaigns_all_tl camp
    ';
       IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' ,ENI_ITEM_VBH_NODES_V e';
  end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND  a.object_type= ''CAMP''
AND camp.campaign_id(+) = a.object_id';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND a.object_type = ac.object_type
AND a.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND e.parent_id = :l_cat_id
   AND a.category_id =  e.id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND camp.language(+)=USERENV(''LANG'')
GROUP BY a.object_id,
camp.campaign_name
) where rownum<10
UNION ALL
SELECT
object_id,campaign_name,camp_opp_count,event_name,even_opp_count
FROM
(
SELECT
a.object_id object_id,
null campaign_name,
0 camp_opp_count,
eve.event_header_name event_name,
0 even_opp_count
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    ams_event_headers_all_tl eve
    ';
IF l_cat_id is not null then
l_sqltext := l_sqltext ||' ,ENI_ITEM_VBH_NODES_V e ';
end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND  a.object_type= ''EVEH''
AND eve.event_header_id(+) = a.object_id';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND a.object_type = ac.object_type
AND a.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND e.parent_id = :l_cat_id
   AND a.category_id =  e.id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND eve.language(+)=USERENV(''LANG'')
GROUP BY a.object_id,
eve.event_header_name
) where rownum<10
) a
';
--end if;


  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


write_debug('GET_TOP_OPPS_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_TOP_OPPS_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_TOP_OPPS_SQL;

PROCEDURE GET_TOP_EVEH_OPPS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(4000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
   l_admin_status := GET_ADMIN_STATUS;
   /*IF l_admin_flag = 'N' THEN
      l_access_table := ',AMS_ACT_ACCESS_DENORM ac ';
      l_access_clause := 'AND a.object_type = ac.object_type '||
         'AND a.object_id = ac.object_id AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/

--if (l_view_by = 'CAMPAIGN+CAMPAIGN') then
l_sqltext :=
'SELECT event_name BIM_ATTRIBUTE1,
even_opp_amt BIM_ATTRIBUTE2
FROM
(
SELECT
event_name,even_opp_amt
FROM
(
SELECT
eve.name event_name,
sum(nvl((won_opportunity_amt'||l_curr_suffix||'),0)) even_opp_amt
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    bim_i_obj_name_mv eve
    ';
IF l_cat_id is not null then
l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND  eve.object_type= ''EVEH''
AND eve.source_code_id = a.source_code_id';

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND eve.object_type = ac.object_type
AND eve.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdcs.category_set_id
			     AND mdcs.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND eve.language(+)=USERENV(''LANG'')
GROUP BY eve.name
order by even_opp_amt desc
) where rownum<10
) a
';
--end if;


  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


write_debug('GET_TOP_EVEH_OPPS_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_TOP_EVEH_OPPS_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_TOP_EVEH_OPPS_SQL;

PROCEDURE GET_TOP_CAMP_OPPS_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(4000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
  IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
   l_admin_status := GET_ADMIN_STATUS;
   /*IF l_admin_flag = 'N' THEN
      l_access_table := ',AMS_ACT_ACCESS_DENORM ac ';
      l_access_clause := 'AND a.object_type = ac.object_type '||
         'AND a.object_id = ac.object_id AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/

--if (l_view_by = 'CAMPAIGN+CAMPAIGN') then
l_sqltext :=
'SELECT campaign_name BIM_ATTRIBUTE1,
camp_opp_amt BIM_ATTRIBUTE2
FROM
(
SELECT
campaign_name,camp_opp_amt
FROM
(
SELECT
camp.name campaign_name,
sum(nvl((a.won_opportunity_amt'||l_curr_suffix||'),0)) camp_opp_amt
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    bim_i_obj_name_mv camp
    ';
IF l_cat_id is not null then
l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND  camp.object_type= ''CAMP''
AND a.source_code_id = camp.source_code_id';

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND camp.object_type = ac.object_type
AND camp.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';
END IF;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id  ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND camp.language =USERENV(''LANG'')
GROUP BY camp.name
order by camp_opp_amt desc
) where rownum<10
) a
';
--end if;


  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


write_debug('GET_TOP_CAMP_OPPS_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_TOP_OPPS_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_TOP_CAMP_OPPS_SQL;

PROCEDURE GET_TOP_EVEH_LEAD_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(4000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
   l_admin_status := GET_ADMIN_STATUS;
   /*IF l_admin_flag = 'N' THEN
      l_access_table := ',AMS_ACT_ACCESS_DENORM ac ';
      l_access_clause := 'AND a.object_type = ac.object_type '||
         'AND a.object_id = ac.object_id AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/


--if (l_view_by = 'CAMPAIGN+CAMPAIGN') then
l_sqltext :=
'SELECT event_name BIM_ATTRIBUTE1,
even_lead_count BIM_ATTRIBUTE2
FROM
(
SELECT
event_name,even_lead_count
FROM
(
SELECT
eve.name event_name,
sum(a.leads) even_lead_count
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    bim_i_obj_name_mv eve
    ';
IF l_cat_id is not null then
l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.source_code_id = eve.source_code_id
AND eve.object_type = ''EVEH'' ';


IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND eve.object_type = ac.object_type
AND eve.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND eve.language(+)=USERENV(''LANG'')
GROUP BY eve.name
having sum(a.leads) >0
order by even_lead_count desc
) where rownum<10
) a
';
--end if;


  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


write_debug('GET_TOP_EVEH_LEAD_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_TOP_EVEH_LEAD_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_TOP_EVEH_LEAD_SQL;

PROCEDURE GET_TOP_CAMP_LEAD_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(4000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
   l_admin_status := GET_ADMIN_STATUS;
   /*IF l_admin_flag = 'N' THEN
      l_access_table := ',AMS_ACT_ACCESS_DENORM ac ';
      l_access_clause := 'AND a.object_type = ac.object_type '||
         'AND a.object_id = ac.object_id AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/

--if (l_view_by = 'CAMPAIGN+CAMPAIGN') then
l_sqltext :=
'SELECT campaign_name BIM_ATTRIBUTE1,
camp_lead_count BIM_ATTRIBUTE2
FROM
(
SELECT
campaign_name,camp_lead_count
FROM
(
SELECT
camp.name campaign_name,
sum(a.leads) camp_lead_count
FROM BIM_I_OBJ_METS_MV a,
    fii_time_rpt_struct_v cal,
    bim_i_obj_name_mv camp
    ';
IF l_cat_id is not null then
l_sqltext := l_sqltext ||' , eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
end if;
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||',AMS_ACT_ACCESS_DENORM ac ';
END IF;

l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.source_code_id = camp.source_code_id
AND camp.object_type = ''CAMP'' ';

IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND camp.object_type = ac.object_type
AND camp.object_id = ac.object_id
AND ac.resource_id = :l_resource_id';

END IF;

IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id';
  end if;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
AND a.object_country = :l_country
AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
AND camp.language =USERENV(''LANG'')
GROUP BY camp.name
having sum(a.leads) >0
order by camp_lead_count desc
) where rownum<10
) a
';
--end if;


  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


write_debug('GET_TOP_CAMP_OPPS_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_TOP_OPPS_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_TOP_CAMP_LEAD_SQL;


PROCEDURE GET_CPL_KPI(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
			  IS
l_sqltext varchar2(5000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_prev_aod_str varchar2(80);
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_admin_clause varchar2(4000);
--l_cat_id NUMBER;
l_campaign_id VARCHAR2(50);
l_cat_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_sql_outer  varchar2(5000);
select1   varchar2(5000);
select2    varchar2(5000);
select3    varchar2(5000);
l_sqltext_final    varchar2(32766);
l_inner            varchar2(5000);
l_sql_inception    varchar2(5000);
l_inner_p           varchar2(5000);
l_sql_inception_p    varchar2(5000);
l_cost                         varchar2(50);
l_top_cond  varchar2(100);
l_top_cond_tot   varchar2(100);
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);


BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
 l_sqltext :=' ';
  IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   l_admin_status := GET_ADMIN_STATUS;

   /*l_previous_as_of_date := BIM_PMV_DBI_UTL_PKG.Previous_Period_Asof_Date(l_as_of_date, l_period_type, l_comp_type);
   l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   l_prev_aod_str := 'to_date('||to_char(l_previous_as_of_date,'J')||',''J'')';*/



 IF l_prog_cost = 'BIM_ACTUAL_COST' THEN
      l_cost  :='actual_cost';
   ELSIF l_prog_cost = 'BIM_APPROVED_BUDGET' THEN
       l_cost  :='budget_approved';
   END IF;


   l_rsid := GET_RESOURCE_ID;
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;



l_sql_outer := 'SELECT
decode(decode('''|| l_cost_type ||''',''BIM_PTD_COST'',c_tlds,c_total_leads),0,null,c_tcost/decode('''|| l_cost_type ||''',''BIM_PTD_COST'',c_tlds,c_total_leads)) BIM_MEASURE7,
decode(decode('''|| l_cost_type ||''',''BIM_PTD_COST'',p_tlds,p_total_leads),0,null,p_tcost/decode('''|| l_cost_type ||''',''BIM_PTD_COST'',p_tlds,p_total_leads)) BIM_MEASURE8,
decode(decode('''|| l_cost_type ||''',''BIM_PTD_COST'',c_tlds,c_total_leads),0,null,c_tcost/decode('''|| l_cost_type ||''',''BIM_PTD_COST'',c_tlds,c_total_leads)) BIM_GRAND_TOTAL1,
decode(decode('''|| l_cost_type ||''',''BIM_PTD_COST'',p_tlds,p_total_leads),0,null,p_tcost/decode('''|| l_cost_type ||''',''BIM_PTD_COST'',p_tlds,p_total_leads)) BIM_CGRAND_TOTAL1,
c_tcost  BIM_MEASURE21,
p_tcost BIM_MEASURE22,
c_tcost  BIM_GRAND_TOTAL2,
p_tcost BIM_CGRAND_TOTAL2
FROM
(
SELECT


case when '''|| l_prog_cost ||''' = ''BIM_APPROVED_BUDGET'' then
   case when '''|| l_cost_type ||''' = ''BIM_PTD_COST''  then
      SUM(p_tbapp)
     else
      sum(p_total_budget)
    end
  else
    case when '''|| l_cost_type ||''' = ''BIM_PTD_COST'' then
      SUM(p_tcost)
     else
      sum(p_total_cost)
     end
  end p_tcost,

case when '''|| l_prog_cost ||''' = ''BIM_APPROVED_BUDGET'' then
   case when '''|| l_cost_type ||''' = ''BIM_PTD_COST''  then
      SUM(c_tbapp)
     else
      sum(c_total_budget)
    end
  else
    case when '''|| l_cost_type ||''' = ''BIM_PTD_COST'' then
      SUM(c_tcost)
     else
      sum(c_total_cost)
     end
  end c_tcost,

sum(c_tlds) c_tlds,
sum(p_tlds) p_tlds,
sum(p_total_leads) p_total_leads,
sum(c_total_leads) c_total_leads
FROM
(';

select1:='
SELECT
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.actual_cost'||l_curr_suffix||' else 0 end) c_tcost,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.TOTAL_LEADS else 0 end) c_tlds,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.BUDGET_APPROVED'||l_curr_suffix||' else 0 end) c_tbapp,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.actual_cost'||l_curr_suffix||' else 0 end) p_tcost,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.TOTAL_LEADS else 0 end) p_tlds,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.BUDGET_APPROVED'||l_curr_suffix||' else 0 end) p_tbapp,
0   c_total_cost,
0   c_total_budget,
0   c_total_leads,
0   p_total_cost,
0   p_total_budget,
0   p_total_leads
FROM  ';

select2:='
SELECT
0 c_tcost,
0 c_tlds,
0 c_tbapp,
0 p_tcost,
0 p_tlds,
0 p_tbapp,
SUM( au.cost_actual'||l_curr_suffix||')       c_total_cost,
SUM( au.BUDGET_APPROVED'||l_curr_suffix||')   c_total_budget,
SUM( au.LEADS)             c_total_leads,
0   p_total_cost,
0   p_total_budget,
0   p_total_leads
FROM ';

select3:='
SELECT
0 c_tcost,
0 c_tlds,
0 c_tbapp,
0 p_tcost,
0 p_tlds,
0 p_tbapp,
0   c_total_cost,
0   c_total_budget,
0   c_total_leads,
SUM( au.cost_actual'||l_curr_suffix||')       p_total_cost,
SUM( au.BUDGET_APPROVED'||l_curr_suffix||')   p_total_budget,
SUM( au.LEADS)             p_total_leads
FROM ';




   IF l_admin_status='N' THEN
      if l_prog_view='Y' then
            l_top_cond_tot :=' AND a.immediate_parent_id is null ';
            l_top_cond :=' AND au.immediate_parent_id is null ';
      else
            l_top_cond :=' and au.object_type in (''CAMP'',''EVEH'',''EONE'') ';
	     l_top_cond_tot :=' and a.object_type in (''CAMP'',''EVEH'',''EONE'') ';
      end if;
   ELSE
           l_top_cond_tot :=' AND a.immediate_parent_id is null ';
	   l_top_cond :=' AND au.immediate_parent_id is null ';

   END IF;


/************Inner Query to get current acitve objects *************************/

l_inner:='select distinct  a.object_id,a.object_type
from BIM_I_CPB_METS_MV a
,fii_time_rpt_struct_v cal';

IF l_admin_status='N' THEN
  if l_prog_view='Y' then
   l_inner:=l_inner||',bim_i_top_objects r ';
  else
  l_inner:=l_inner||',ams_act_access_denorm r ';
  end if;
End if;


IF l_cat_id is not null then
  l_inner := l_inner ||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;

 l_inner := l_inner || ' WHERE
 a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id
AND cal.calendar_id=-1
AND cal.report_date  =&BIS_CURRENT_ASOF_DATE
AND a.object_country = :l_country
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
and (a.'||l_cost||' <>0 or a.total_leads >0)'||l_top_cond_tot;

IF l_admin_status = 'N' THEN
  l_inner :=  l_inner||' AND a.object_type = r.object_type AND  a.object_id = r.object_id AND r.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_inner :=  l_inner ||' AND a.category_id = -9 ';
else
l_inner :=  l_inner ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;



/**********outer query to get current cost from Inception to date***************************/


l_sql_inception:=' BIM_I_obj_METS_MV au,( '|| l_inner||') bu,fii_time_rpt_struct_v cu ';

IF l_admin_status='N' THEN
       if l_prog_view='Y' then
             l_sql_inception:=l_sql_inception||', BIM_I_TOP_OBJECTS  ru ';
	else
	     l_sql_inception:=l_sql_inception||',ams_act_access_denorm   ru ';
	 end if;
end if;

IF l_cat_id is not null then
  l_sql_inception := l_sql_inception ||', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;


 l_sql_inception := l_sql_inception || ' WHERE
 au.time_id=cu.time_id
AND au.period_type_id=cu.period_type_id
AND cu.calendar_id=-1
AND cu.report_date = trunc(sysdate)
AND au.object_country = :l_country
AND BITAND(cu.record_type_id,1143)=cu.record_type_id
and bu.object_id=au.object_id
and bu.object_type=au.object_type
'||l_top_cond;

IF l_admin_status = 'N' THEN
  l_sql_inception :=  l_sql_inception||'
  AND au.object_type = ru.object_type AND  au.object_id = ru.object_id AND ru.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_sql_inception :=  l_sql_inception ||' AND au.category_id = -9 ';
else
  l_sql_inception :=  l_sql_inception ||' AND au.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;


/************************************************************************************/




/************Inner Query to get previous acitve objects *************************/

l_inner_p:='select distinct  a.object_id,a.object_type
from BIM_I_CPB_METS_MV a
,fii_time_rpt_struct_v cal';

IF l_admin_status='N' THEN
  if l_prog_view='Y' then
  l_inner_p:=l_inner_p||',bim_i_top_objects r ';
  else
  l_inner_p:=l_inner_p||',ams_act_access_denorm r ';
  end if;
End if;

IF l_cat_id is not null then
  l_inner_p := l_inner_p ||', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';

end if;

 l_inner_p := l_inner_p || ' WHERE
 a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id
AND cal.calendar_id=-1
AND cal.report_date  =&BIS_PREVIOUS_ASOF_DATE
AND a.object_country = :l_country
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
and (a.'||l_cost||' <>0 or a.total_leads >0)'||l_top_cond_tot;

IF l_admin_status = 'N' THEN
  l_inner_p :=  l_inner_p||' AND a.object_type = r.object_type AND  a.object_id = r.object_id AND r.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_inner_p :=  l_inner_p ||' AND a.category_id = -9 ';
else
   l_inner_p :=  l_inner_p ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';

  end if;


/**********outer query to get previous cost from Inception to date***************************/


l_sql_inception_p:=' BIM_I_obj_METS_MV au,( '|| l_inner_p||') bu,fii_time_rpt_struct_v cu ';

IF l_admin_status='N' THEN
  l_sql_inception_p:=l_sql_inception_p||', BIM_I_TOP_OBJECTS   ru ';
end if;

IF l_cat_id is not null then
  l_sql_inception_p := l_sql_inception_p ||', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;


 l_sql_inception_p := l_sql_inception_p || ' WHERE
 au.time_id=cu.time_id
AND au.period_type_id=cu.period_type_id
AND cu.calendar_id=-1
AND cu.report_date  =   trunc(sysdate)
AND au.object_country = :l_country
AND BITAND(cu.record_type_id,1143)=cu.record_type_id
and bu.object_id=au.object_id
and bu.object_type=au.object_type
'||l_top_cond;

IF l_admin_status = 'N' THEN
  l_sql_inception_p :=  l_sql_inception_p||' AND au.object_type = ru.object_type AND  au.object_id = ru.object_id AND ru.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_sql_inception_p :=  l_sql_inception_p ||' AND au.category_id = -9 ';
else
  l_sql_inception_p :=  l_sql_inception_p ||' AND au.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';

  end if;


/************************************************************************************/




IF l_admin_status='N' THEN
if l_prog_view='Y' then
  l_sqltext := l_sqltext ||'BIM_I_CPB_METS_MV  a,fii_time_rpt_struct_v cal, bim_i_top_objects  r ';
  else
 l_sqltext := l_sqltext ||'BIM_I_CPB_METS_MV  a,fii_time_rpt_struct_v cal,ams_act_access_denorm   r ';
end if;
ELSE
  l_sqltext := l_sqltext ||'BIM_I_MKT_CRPL_MV a,fii_time_rpt_struct_v cal';
end if;






IF l_cat_id is not null then
  l_sqltext := l_sqltext ||', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;


 l_sqltext := l_sqltext || ' WHERE a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id
AND cal.calendar_id=-1';






IF l_admin_status = 'N' THEN
 l_sqltext := l_sqltext||' AND a.object_type = r.object_type AND  a.object_id = r.object_id AND r.resource_id = :l_resource_id '|| l_top_cond_tot ;
END IF;



IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;


l_sqltext := l_sqltext ||
' AND a.object_country = :l_country ';

l_sqltext_final := l_sql_outer||
                    select1||
		    l_sqltext||
		    ' AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id '||
		    ' AND cal.report_date in(&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) ';

		    if l_cost_type <> 'BIM_PTD_COST' then
		     l_sqltext_final := l_sqltext_final ||
		     ' UNION ALL ' ||
		     select2||l_sql_inception||
		      ' UNION ALL ' ||
		     select3||l_sql_inception_p;
		     end if;

		l_sqltext_final := l_sqltext_final || ' ))' ;


  x_custom_sql := l_sqltext_final;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

   l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

write_debug('MKTG KPI SQL','QUERY','test',l_sqltext,NULL,null);
EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('MKTG KPI SQL2','ERROR',l_sql_errm,l_sqltext,NULL,null);
END GET_CPL_KPI;


PROCEDURE GET_CPL_GRAPH_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
	  IS
iFlag number;
l_sqltext	      VARCHAR2(20000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_prev_aod_str varchar2(80);
l_curr_aod_str varchar2(80);
l_curr_start_date_str varchar2(80);
l_prev_start_date_str varchar2(80);
l_table_name varchar2(80);
l_country_clause varchar2(4000);
l_admin_clause varchar2(4000);
l_series_name varchar2(4000);
l_time_ids varchar2(4000);
l_record_type varchar2(80) := NULL;
--l_cat_id NUMBER;
l_campaign_id VARCHAR2(50);
l_cat_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_group_by varchar2(500);
l_group_by1 varchar2(500);
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
l_admin_status := GET_ADMIN_STATUS;
 --l_admin_status := 'Y';


   /*
   IF l_admin_status = 'N' THEN
      l_admin_clause := ' a.admin_flag = ''N'' AND a.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_admin_clause := ' a.admin_flag = ''Y''';
   END IF;
   */

   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;

/*
    IF l_cat_id is NULL and l_admin_status <> 'N' THEN
      l_cat_id := -9;
   END IF;

   */


  IF(l_as_of_date IS NULL)THEN
    l_as_of_date := sysdate;
  END IF;

  IF(l_comp_type IS NULL) THEN
     l_comp_type := 'YEARLY';
  END IF;

  IF l_record_type_id = 11 THEN l_period_type_id := 16;
  ELSIF l_record_type_id = 23 THEN l_period_type_id := 32;
  ELSIF l_record_type_id = 55 THEN l_period_type_id := 64;
  ELSIF l_record_type_id = 119 THEN l_period_type_id := 128;
  ELSE l_period_type_id := 64;
  END IF;

BIM_PMV_DBI_UTL_PKG.GET_TREND_PARAMS(  p_page_period_type  => l_period_type,
                             p_comp_type         => l_comp_type,
                             p_curr_as_of_date   => l_as_of_date,
                             p_table_name        => l_table_name,
                             p_column_name       => l_time_id_column,
                             p_curr_start_date   => l_current_report_start_date,
                             p_prev_start_date   => l_previous_report_start_date,
                             p_prev_end_date     => l_previous_as_of_date,
			     p_series_name       => l_series_name,
			     p_time_ids          => l_time_ids
                             );

  l_group_by:='  group by a.time_id,fi.name,fi.sequence ,end_date,start_date';

  l_group_by1:=' group by fi.name ,a.time_id ';


   IF ( l_comp_type  = 'YEARLY' AND l_period_type <> 'FII_TIME_ENT_YEAR' )  THEN



IF l_admin_status = 'N' THEN
  l_sqltext := 'SELECT fi.name VIEWBY, null BIM_ATTRIBUTE1,BIM_ATTRIBUTE2,BIM_ATTRIBUTE3,prev.BIM_ATTRIBUTE4,prev.BIM_ATTRIBUTE5
  FROM
   (
  SELECT name BIM_ATTRIBUTE1,curr.leads BIM_ATTRIBUTE2 ,decode ( curr.leads,0,null,(curr.costs/curr.leads)) BIM_ATTRIBUTE3,
  start_date, end_date, seq, time_id
  FROM  (
  SELECT a.time_id time_id, sum(total_leads) leads, fi.name name,fi.sequence seq,
  end_date,start_date, decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',
  sum(budget_approved'||l_curr_suffix||'),sum(actual_cost'||l_curr_suffix||')) costs ';
else
  l_sqltext := 'SELECT fi.name VIEWBY, null BIM_ATTRIBUTE1,BIM_ATTRIBUTE2,BIM_ATTRIBUTE3,prev.BIM_ATTRIBUTE4,prev.BIM_ATTRIBUTE5
  FROM
   (
  SELECT name BIM_ATTRIBUTE1,curr.leads BIM_ATTRIBUTE2 ,decode ( curr.leads,0,null,(curr.costs/curr.leads)) BIM_ATTRIBUTE3,
  start_date, end_date, seq, time_id
  FROM  (   SELECT a.time_id time_id, total_leads leads, fi.name name,fi.sequence seq,
  end_date,start_date, decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET''
  ,budget_approved'||l_curr_suffix||',actual_cost'||l_curr_suffix||') costs ';
end if;

IF l_admin_status = 'N' THEN

  l_sqltext :=l_sqltext||' FROM BIM_I_CPB_METS_MV a,'||l_period_type||' fi , BIM_I_TOP_OBJECTS  r';

  IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
  end if;

  l_sqltext :=l_sqltext|| ' WHERE a.time_id = fi.'||l_time_id_column||'  AND a.period_type_id = :l_period_type_id
  AND a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id';

  IF l_cat_id is not null then
     l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id   AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
     AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
  else
     l_sqltext :=l_sqltext||' AND a.category_id = -9 ';
  end if;

else
   l_sqltext :=l_sqltext||' FROM BIM_I_MKT_CRPL_MV a,'||l_period_type||' fi';

    IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
  end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = fi.'||l_time_id_column||'   AND a.period_type_id = :l_period_type_id';

    IF l_cat_id is not null then
      l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id   AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
     AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
    else
      l_sqltext :=l_sqltext||' and  a.category_id = -9';
    end if;

end if;



l_sqltext := l_sqltext||' AND fi.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
AND fi.end_date<&BIS_CURRENT_ASOF_DATE AND a.object_country = :l_country ';

IF l_admin_status = 'N' THEN
 l_sqltext := l_sqltext||l_group_by;
end if;

l_sqltext := l_sqltext||') curr   UNION ALL select name BIM_ATTRIBUTE1,total_leads BIM_ATTTRIBUTE2,decode ( total_leads,0,null,(total_cost)/(total_leads)) BIM_ATTRIBUTE3,
start_date, end_date, seq,time_id from
(  SELECT name ,total_leads,total_cost,start_date, end_date, fi.sequence seq, fi.time_id
FROM (
SELECT name,'||l_time_ids||' time_id, start_date, end_date, sequence, &BIS_CURRENT_ASOF_DATE  report_date
FROM '||l_period_type||'
WHERE start_date <= &BIS_CURRENT_ASOF_DATE  and end_date >= &BIS_CURRENT_ASOF_DATE
ORDER BY start_date desc  ) fi,
(SELECT SUM(a.total_leads) total_leads,
decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',sum(a.budget_approved'||l_curr_suffix||'),sum(a.actual_cost'||l_curr_suffix||')) total_cost,
report_date
FROM   (SELECT report_date, time_id, period_type_id   FROM FII_TIME_RPT_STRUCT
WHERE   calendar_id=-1   AND report_date = &BIS_CURRENT_ASOF_DATE   AND BITAND(record_type_id,:l_record_type) = record_type_id  ) c, ';

IF l_admin_status='N' THEN

  l_sqltext :=l_sqltext||'BIM_I_CPB_METS_MV a, BIM_I_TOP_OBJECTS  r ';

  IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = c.time_id AND a.period_type_id = c.period_type_id AND a.object_country = :l_country
     AND a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id';

  IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET'' AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11	AND edh.dbi_flag = ''Y'' AND edh.parent_id = :l_cat_id ';
  else
     l_sqltext :=l_sqltext||' AND a.category_id = -9 ';
  end if;

ELSE
 l_sqltext :=l_sqltext||'  BIM_I_MKT_CRPL_MV a' ;

    IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
  end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = c.time_id AND a.period_type_id = c.period_type_id  AND a.object_country = :l_country';

    IF l_cat_id is not null then
      l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id   AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
      AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
    else
      l_sqltext :=l_sqltext||' and  a.category_id = -9';
    end if;

END IF;

/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext||' AND a.admin_flag = :l_admin_flag AND a.resource_id = :l_resource_id ';
ELSE
l_sqltext := l_sqltext||' AND a.admin_flag = :l_admin_flag ';
END IF;
*/

IF l_admin_status='N' THEN

 l_sqltext := l_sqltext ||
 ' GROUP BY report_date) a  where a.report_date(+) = fi.report_date  order by start_date asc ) x   ) curr,
 (SELECT name BIM_ATTRIBUTE1,leads BIM_ATTRIBUTE4 ,  decode ( leads,0,null,(costs/leads)) BIM_ATTRIBUTE5 ,sequence seq
 FROM   ( SELECT fi.name name ,a.time_id time_id,'||l_time_ids||', sum(total_leads) leads,
 decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',sum(budget_approved'||l_curr_suffix||'),sum(actual_cost'||l_curr_suffix||')) costs,  fi.sequence sequence , end_date  ';

else

  l_sqltext := l_sqltext ||
 ' GROUP BY report_date) a  where a.report_date(+) = fi.report_date  order by start_date asc ) x   ) curr,
  (SELECT name BIM_ATTRIBUTE1,leads BIM_ATTRIBUTE4 ,  decode ( leads,0,null,(costs/leads)) BIM_ATTRIBUTE5 ,sequence seq
   FROM   ( SELECT fi.name name ,a.time_id time_id,'||l_time_ids||', total_leads leads,
  decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',budget_approved'||l_curr_suffix||',actual_cost'||l_curr_suffix||') costs,  fi.sequence sequence , end_date  ';

end if;


IF l_admin_status='N' THEN

   l_sqltext :=l_sqltext||' FROM BIM_I_CPB_METS_MV a,'||l_period_type||' fi, BIM_I_TOP_OBJECTS  r';

   IF l_cat_id is not null then
    l_sqltext :=l_sqltext||', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
   end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = fi.'||l_time_id_column||' AND a.period_type_id = :l_period_type_id
    AND  a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id';

  IF l_cat_id is not null then
   l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''    AND edh.object_id = mdcs.category_set_id
   AND mdcs.functional_area_id = 11	AND edh.dbi_flag = ''Y''     AND edh.parent_id = :l_cat_id ';
  else
   l_sqltext :=l_sqltext||' AND a.category_id = -9 ';
  end if;
ELSE

  l_sqltext :=l_sqltext||' FROM BIM_I_MKT_CRPL_MV a,'||l_period_type||' fi';

    IF l_cat_id is not null then
     l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
    end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = fi.'||l_time_id_column||'   AND a.period_type_id = :l_period_type_id';

    IF l_cat_id is not null then
      l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id   AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
      AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
    else
      l_sqltext :=l_sqltext||' and  a.category_id = -9';
    end if;

END IF;



l_sqltext := l_sqltext ||
' AND fi.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_PREVIOUS_ASOF_DATE  AND a.object_country = :l_country';

IF l_admin_status = 'N' THEN
 l_sqltext := l_sqltext||l_group_by;
end if;

l_sqltext := l_sqltext||' ) k) prev,'||l_period_type||' fi WHERE fi.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
AND fi.'||l_time_id_column||' = curr.time_id (+)  AND fi.sequence = curr.seq (+)   AND fi.sequence = prev.seq (+)   ORDER BY fi.start_date   ' ;



ELSE  -- Sequential or entity year.


IF l_admin_status = 'N' THEN

l_sqltext := 'SELECT BIM_ATTRIBUTE1 VIEWBY,null BIM_ATTRIBUTE1,BIM_ATTRIBUTE2,BIM_ATTRIBUTE3,BIM_ATTRIBUTE4,BIM_ATTRIBUTE5 FROM
(SELECT fi.name BIM_ATTRIBUTE1,  curr.leads BIM_ATTRIBUTE2, decode (curr.leads,0,null,(curr.costs/curr.leads)) BIM_ATTRIBUTE3,
prev_leads BIM_ATTRIBUTE4,prev_cost BIM_ATTRIBUTE5,start_date  FROM ( SELECT fi.name name,a.time_id time_id, sum(total_leads) leads,
decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',sum(budget_approved'||l_curr_suffix||'),sum(actual_cost'||l_curr_suffix||')) costs,  0 prev_leads,0 prev_cost ';

else

l_sqltext := 'SELECT BIM_ATTRIBUTE1 VIEWBY,null BIM_ATTRIBUTE1,BIM_ATTRIBUTE2,BIM_ATTRIBUTE3,BIM_ATTRIBUTE4,BIM_ATTRIBUTE5 FROM
(SELECT fi.name BIM_ATTRIBUTE1,  curr.leads BIM_ATTRIBUTE2, decode (curr.leads,0,null,(curr.costs/curr.leads)) BIM_ATTRIBUTE3,
prev_leads BIM_ATTRIBUTE4,prev_cost BIM_ATTRIBUTE5,start_date  FROM ( SELECT fi.name name,a.time_id time_id, total_leads leads,
decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',budget_approved'||l_curr_suffix||',actual_cost'||l_curr_suffix||') costs,  0 prev_leads,0 prev_cost ';

end if;




IF l_admin_status = 'N' THEN

  l_sqltext :=l_sqltext||' FROM BIM_I_CPB_METS_MV a,'||l_period_type||' fi , BIM_I_TOP_OBJECTS  r';

  IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
  end if;

  l_sqltext :=l_sqltext||' WHERE a.time_id = fi.'||l_time_id_column||'
  AND a.period_type_id = :l_period_type_id      AND  a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id';

  IF l_cat_id is not null then
     l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id   AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
     AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
  else
     l_sqltext :=l_sqltext||' AND a.category_id = -9 ';
  end if;

else

 l_sqltext :=l_sqltext||' FROM BIM_I_MKT_CRPL_MV a,'||l_period_type||' fi';

    IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
    end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = fi.'||l_time_id_column||'   AND a.period_type_id = :l_period_type_id';

    IF l_cat_id is not null then
      l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
     AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
    else
      l_sqltext :=l_sqltext||' and  a.category_id = -9';
    end if;

end if;

/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext||' AND a.admin_flag = :l_admin_flag AND a.resource_id = :l_resource_id ';
ELSE
l_sqltext := l_sqltext||' AND a.admin_flag = :l_admin_flag ';
END IF;
*/

l_sqltext := l_sqltext||
' AND fi.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
AND fi.end_date<&BIS_CURRENT_ASOF_DATE  AND a.object_country =:l_country ';

IF l_admin_status = 'N' THEN
  l_sqltext := l_sqltext||l_group_by1 ;
end if;

l_sqltext := l_sqltext||' ) curr, '||l_period_type||' fi WHERE fi.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
 AND fi.end_date<&BIS_CURRENT_ASOF_DATE  AND fi.'||l_time_id_column||' = curr.time_id (+)
UNION ALL
select name BIM_ATTRIBUTE1,total_leads BIM_ATTTRIBUTE2,  decode ( (total_leads),0,null,(total_cost)/(total_leads)) BIM_ATTRIBUTE3,
0 prev_leads,0 prev_cost,start_date  from  (  SELECT name ,total_leads,total_cost, start_date, end_date, fi.sequence sequence, time_id
FROM (SELECT name,'||l_time_ids||' time_id, start_date, end_date, sequence,  &BIS_CURRENT_ASOF_DATE  report_date
FROM '||l_period_type||'  WHERE start_date <= &BIS_CURRENT_ASOF_DATE
and end_date >= &BIS_CURRENT_ASOF_DATE   ORDER BY start_date  ) fi  , (SELECT SUM(a.total_leads) total_leads,
decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',sum(budget_approved'||l_curr_suffix||'),sum(actual_cost'||l_curr_suffix||')) total_cost,
report_date  FROM   (SELECT report_date, time_id, period_type_id   FROM FII_TIME_RPT_STRUCT
WHERE   calendar_id=-1  AND report_date = &BIS_CURRENT_ASOF_DATE   AND BITAND(record_type_id,:l_record_type) = record_type_id  ) c, ';

IF l_admin_status = 'N' THEN


  l_sqltext :=l_sqltext||'BIM_I_CPB_METS_MV a, BIM_I_TOP_OBJECTS  r ';

  IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
  end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = c.time_id AND a.period_type_id = c.period_type_id AND a.object_country = :l_country
    AND a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id';

  IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET'' AND edh.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11	AND edh.dbi_flag = ''Y'' AND edh.parent_id = :l_cat_id ';
  else
     l_sqltext :=l_sqltext||' AND a.category_id = -9 ';
  end if;

else


 l_sqltext :=l_sqltext||'  BIM_I_MKT_CRPL_MV a' ;

    IF l_cat_id is not null then
    l_sqltext :=l_sqltext||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs ';
  end if;

    l_sqltext :=l_sqltext||' WHERE a.time_id = c.time_id AND a.period_type_id = c.period_type_id  AND a.object_country = :l_country';

    IF l_cat_id is not null then
      l_sqltext :=l_sqltext||' AND a.category_id = edh.child_id   AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
      AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
    else
      l_sqltext :=l_sqltext||' and  a.category_id = -9';
    end if;


end if;

/*
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext||' AND a.admin_flag = :l_admin_flag AND a.resource_id = :l_resource_id';
ELSE
l_sqltext := l_sqltext||' AND a.admin_flag = :l_admin_flag ';
END IF;
*/

l_sqltext := l_sqltext ||   ' GROUP BY report_date) a  where a.report_date(+) = fi.report_date  order by start_date  ) x  ) p order by p.start_date  ';
END IF;



  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_period_type_id';
  l_custom_rec.attribute_value := l_period_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;


write_debug('GET_CPL_GRAPH_SQL','QUERY','__',l_sqltext);
EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_CPL_GRAPH_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_CPL_GRAPH_SQL;

PROCEDURE GET_CPL_RPL_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (30000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
   l_select_cal1                   VARCHAR2 (20000);
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_select_filter_camp      VARCHAR2 (20000);
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_from_inr                      VARCHAR2 (20000);
   l_from1                        VARCHAR2 (20000);-- vairable to get total cost from bim_i_obj_mets_mv
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_where_inr                      VARCHAR2 (20000);
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_from1                     VARCHAR2 (20000);-- vairable to get total cost from bim_i_obj_mets_mv
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(200);
   l_pc_groupby                   VARCHAR2(200);
   l_view                         VARCHAR2 (20);
   l_select1                      VARCHAR2 (20000);
   l_select2                      VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(1000);
   l_url_str_csch                 varchar2(1000);
   l_url_str_csch_jtf             varchar2(3000);
   l_url_str_type                 varchar2(3000);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_csch_chnl                    varchar2(100);
   l_top_cond                     VARCHAR2(100);
   l_meaning                      VARCHAR2 (20);
   l_inner                        varchar2(5000);
   l_inr_cond                     varchar2(5000);
   l_cost                         varchar2(50);
   cpl                            varchar2(500);
   p_cpl                          varchar2(500);
   l_union_inc                    varchar2(5000);
   l_col_inc                      varchar2(1000);
   l_col_id NUMBER;
   l_area VARCHAR2(300);
   l_report_name VARCHAR2(300);
   l_curr VARCHAR2(50);
    l_curr_suffix VARCHAR2(50);
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                   bis_query_attributes;
   l_object_type                  varchar2(30);
   l_url_link                     varchar2(200);
   l_url_camp1                    varchar2(3000);
   l_url_camp2                    varchar2(3000);
   l_dass                         varchar2(100);  -- variable to store value for  directly assigned lookup value
   l_leaf_node_flag               varchar2(25);   -- variable to store value leaf_node_flag column in case of product category
   l_media VARCHAR2(300);
   l_curr_suffix1 VARCHAR2(50);
   l_table_bud VARCHAR2(300);
   l_where_bud VARCHAR2(300);
   l_prog_cost1 VARCHAR2(30);
BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
   bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
   l_meaning:=' null meaning '; -- assigning default value
   l_url_camp1:=',null';
   l_url_camp2:=',null';

IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   l_admin_status := get_admin_status;

   l_url_str :='pFunctionName=BIM_I_CRPL_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';

    cpl:=' (decode(sum(BIM_ATTRIBUTE4) over(),0,0,sum(BIM_ATTRIBUTE2) over() /sum(BIM_ATTRIBUTE4) over() ))' ;
     p_cpl:=' (decode(sum(prev_ptd_leads) over() ,0,0,sum(prev_ptd_cost) over() /sum(prev_ptd_leads) over()))' ;


   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;


   IF l_prog_cost = 'BIM_ACTUAL_COST' THEN
      l_cost  :='actual_cost';
   ELSIF l_prog_cost = 'BIM_APPROVED_BUDGET' THEN
       l_cost  :='budget_approved';
   END IF;


    /*********************** security handling for inner query ***********************/

--change here
/* IF  l_view_by <> 'CAMPAIGN+CAMPAIGN' then
     IF   l_campaign_id is null THEN
     IF   l_admin_status = 'N' THEN
	     IF l_prog_view='Y' then
	            l_from_inr :=', bim_i_top_objects  inr_r ';
	     ELSE
	         l_from_inr :=', ams_act_access_denorm  inr_r ';
           END IF;
                l_where_inr := '  AND a.source_code_id = inr_r.source_code_id  AND inr_r.resource_id = :l_resource_id ';

	ELSE
	        l_where_inr   :=' AND a.immediate_parent_id is null ';

    END IF;


   END IF;
   END IF;*/

/************************************************************************/



/************Start Inner Query to get current acitve objects *************************/

IF   l_campaign_id is null THEN

if (l_view_by ='GEOGRAPHY+COUNTRY'  and l_cat_id is not null and l_admin_status = 'Y') then
 l_inner:='( select distinct  a.source_code_id  from fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a  '||l_from_inr;
else
 l_inner:=',( select distinct  a.source_code_id  from fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a  '||l_from_inr;
end if;

IF l_cat_id is not null then
  l_inner := l_inner ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;

 l_inner := l_inner || ' WHERE   a.time_id=cal.time_id  AND a.period_type_id=cal.period_type_id  AND cal.calendar_id=-1   AND cal.report_date   in (&BIS_CURRENT_ASOF_DATE)
 AND a.object_country = :l_country  AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id  and (a.'||l_cost||' <>0 or a.total_leads >0)';

IF l_cat_id is null then
 l_inner :=  l_inner ||' AND a.category_id = -9 ';
else
l_inner :=  l_inner ||' AND a.category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''    AND edh.object_id = mdcs.category_set_id  AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
  end if;

  l_inner := l_inner ||l_where_inr;

l_inner :=  l_inner ||' ) inr ';



l_inr_cond:='and a.source_code_id=inr.source_code_id ';

end if;

/************ End Inner Query to get current acitve objects *************************/


/** to add meaning in select clause only in case of campaign view by */
  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' ,meaning ';
  l_filtercol:=',meaning ';
  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  l_filtercol:=',leaf_node_flag ';
  l_meaning:=',null meaning ';
  else
   l_meaning:=' ,null meaning ';
  end if;
 /*** to  assigned URL **/

if l_campaign_id is not null then
-- checking for the object type passed from page
 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;
end if;

 -- l_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
   l_url_str  :='pFunctionName=BIM_I_CRPL_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
   --l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
   IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
       l_url_link :=' ,decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) ';
       l_view_disp:='viewby';
       l_leaf_node_flag :=' ,leaf_node_flag ';
   ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
     l_camp_sel_col :=' ,object_id
                       ,object_type
                       ';
     l_camp_groupby_col :=',object_id,object_type ';
     l_url_link := ' ,null ';
     l_view_disp := 'viewby';

     IF (l_campaign_id is  null or l_object_type='RCAM') then
	l_url_camp1:=', decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' )';
     ELSIF l_object_type='CAMP' THEN
        l_url_camp2:=', '||''''||l_url_str_type||''''||'||object_id ';
        --l_url_camp1:=', decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_csch_jtf||''''||'||object_id)';
		l_url_camp1:=','''||l_url_str_csch||''''||'||object_id';
	l_csch_chnl:='|| '' - '' || channel';
	l_camp_sel_col :=l_camp_sel_col|| ',usage,channel';
	l_camp_groupby_col :=l_camp_groupby_col||',usage,channel';
     end if;
    ELSE
     -- l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
      l_url_link:=' ,null ';
      l_view_disp:='viewby';
   END IF;



/* l_select_cal is common part of select statement for campaign view by to calculate grand totals and change */
 l_select_cal :='select VIEWBY ,viewbyid,BIM_ATTRIBUTE7,bim_attribute2 ,BIM_ATTRIBUTE4,BIM_ATTRIBUTE3  ,BIM_ATTRIBUTE5 ,BIM_ATTRIBUTE6  ,BIM_ATTRIBUTE8  ,BIM_ATTRIBUTE9,BIM_ATTRIBUTE10
,bim_url1,bim_url2,bim_url3,BIM_GRAND_TOTAL1 , BIM_GRAND_TOTAL2,BIM_GRAND_TOTAL3 ,BIM_GRAND_TOTAL4 ,BIM_GRAND_TOTAL5 ,BIM_GRAND_TOTAL6 ,BIM_GRAND_TOTAL7 ,BIM_GRAND_TOTAL8
from (  SELECT '||l_view_disp ||' ,viewbyid  ,BIM_ATTRIBUTE7 '||l_csch_chnl||' bim_attribute7 ,bim_attribute2  ,BIM_ATTRIBUTE4
,decode(prev_cpl,0,null,((BIM_ATTRIBUTE5-prev_cpl)/prev_cpl)*100) BIM_ATTRIBUTE3
,BIM_ATTRIBUTE5 ,BIM_ATTRIBUTE6  ,BIM_ATTRIBUTE8  ,BIM_ATTRIBUTE9
,BIM_ATTRIBUTE10 '|| l_url_link || ' bim_url1'|| l_url_camp1|| ' bim_url2 '||
l_url_camp2||' bim_url3 ,BIM_GRAND_TOTAL1 ,decode('||p_cpl||',0,null,(('||cpl||' - '||p_cpl||')/ '||p_cpl||')*100 ) BIM_GRAND_TOTAL2
,BIM_GRAND_TOTAL3 ,BIM_GRAND_TOTAL4 ,BIM_GRAND_TOTAL5 ,BIM_GRAND_TOTAL6 ,BIM_GRAND_TOTAL7 ,BIM_GRAND_TOTAL8
 FROM (
SELECT
 name    VIEWBY ,VIEWBYID  ,meaning BIM_ATTRIBUTE7 '||l_camp_sel_col||'
,ptd_cost BIM_ATTRIBUTE2 ,ptd_leads BIM_ATTRIBUTE4,decode(ptd_leads,0,null,ptd_cost/ptd_leads) BIM_ATTRIBUTE5
,decode(prev_ptd_leads,0,null,prev_ptd_cost/prev_ptd_leads) prev_cpl
,total_leads BIM_ATTRIBUTE6 ,total_cost BIM_ATTRIBUTE8  ,decode(total_leads,0,null,total_cost/total_leads) BIM_ATTRIBUTE9
,total_revenue BIM_ATTRIBUTE10  ,sum(ptd_cost) over() BIM_GRAND_TOTAL1 ,999 BIM_GRAND_TOTAL2 ,sum(ptd_leads) over() BIM_GRAND_TOTAL3
,decode(sum(ptd_leads) over(),0,null,sum(ptd_cost) over()/sum(ptd_leads) over()) BIM_GRAND_TOTAL4
,sum(total_leads) over() BIM_GRAND_TOTAL5 ,sum(total_cost) over() BIM_GRAND_TOTAL6
,decode(sum(total_leads) over(),0,null,sum(total_cost) over()/sum(total_leads) over()) BIM_GRAND_TOTAL7
 ,sum(total_revenue) over() BIM_GRAND_TOTAL8 ,prev_ptd_leads  ,prev_ptd_cost
           FROM
              (
                  SELECT
          	     viewbyid ,name'|| l_meaning ||l_camp_sel_col|| ',decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(budget_approved),SUM(ptd_cost)) ptd_cost
		     ,SUM(ptd_leads) ptd_leads    ,decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(p_budget_approved),SUM(p_ptd_cost)) Prev_PTD_cost
		     ,SUM(p_ptd_leads) Prev_PTD_leads
		     ,case when ( (decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(budget_approved),SUM(ptd_cost)) <> 0)
		              or (SUM(ptd_leads) > 0)) then   decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(t_budget_approved),SUM(total_cost))
		     else 0 end   total_cost ,case when ( (decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(budget_approved),SUM(ptd_cost)) <>0)
		             or (SUM(ptd_leads)>0) ) then Sum(total_leads)  else 0 end total_leads   ,case when ((decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(budget_approved),SUM(ptd_cost))<>0)
		              or (SUM(ptd_leads)>0) ) then Sum(total_revenue) else 0 end total_revenue
                  FROM
          	  ( ';

/*  change this  below query  */
/* l_select_cal1 is common part of select statement for all view by except campaign view by to calculate grand totals and change */

l_select_cal1 :='
         SELECT '||
         l_view_disp ||'
	 ,viewbyid
 	  ,BIM_ATTRIBUTE7 ,BIM_ATTRIBUTE2 ,BIM_ATTRIBUTE4
 	  ,decode(prev_cpl,0,null,((BIM_ATTRIBUTE5-prev_cpl)/prev_cpl)*100) BIM_ATTRIBUTE3
 	  ,BIM_ATTRIBUTE5 ,BIM_ATTRIBUTE6,BIM_ATTRIBUTE8,BIM_ATTRIBUTE9
	  ,BIM_ATTRIBUTE10 '||
	  l_url_link|| ' bim_url1'||'
	  ,null BIM_URL2 ,null BIM_URL3  ,BIM_GRAND_TOTAL1
 	  ,decode('||p_cpl||',0,null,(('||cpl||' - '||p_cpl||')/ '||p_cpl||')*100 ) BIM_GRAND_TOTAL2
 	  ,BIM_GRAND_TOTAL3  ,BIM_GRAND_TOTAL4 ,BIM_GRAND_TOTAL5 ,BIM_GRAND_TOTAL6
	  ,BIM_GRAND_TOTAL7 ,BIM_GRAND_TOTAL8
          FROM
	 (
            SELECT
            name    VIEWBY'||l_leaf_node_flag||'
	    ,VIEWBYID,
            meaning BIM_ATTRIBUTE7,
	     ptd_cost BIM_ATTRIBUTE2,
	     ptd_leads BIM_ATTRIBUTE4,
             decode(ptd_leads,0,null,ptd_cost/ptd_leads) BIM_ATTRIBUTE5,
	    decode(prev_ptd_leads,0,null,prev_ptd_cost/prev_ptd_leads) prev_cpl,
	    total_leads BIM_ATTRIBUTE6,
	    total_cost BIM_ATTRIBUTE8,
	    decode(total_leads,0,null,total_cost/total_leads) BIM_ATTRIBUTE9,
            total_revenue BIM_ATTRIBUTE10,
	    sum(ptd_cost) over() BIM_GRAND_TOTAL1,
	    666 BIM_GRAND_TOTAL2,
            sum(ptd_leads) over() BIM_GRAND_TOTAL3,
            decode(sum(ptd_leads) over(),0,null,sum(ptd_cost) over()/sum(ptd_leads) over()) BIM_GRAND_TOTAL4,
            sum(total_leads) over() BIM_GRAND_TOTAL5,
            sum(total_cost) over() BIM_GRAND_TOTAL6,
            decode(sum(total_leads) over(),0,null,sum(total_cost) over()/sum(total_leads) over()) BIM_GRAND_TOTAL7,
            sum(total_revenue) over() BIM_GRAND_TOTAL8,
	     prev_ptd_leads,
             prev_ptd_cost
           FROM
              (
                  SELECT
          	     viewbyid,
          	     name'||l_leaf_node_flag||
		     l_meaning||
		    ',decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(budget_approved),SUM(ptd_cost)) ptd_cost,
		     SUM(ptd_leads) ptd_leads,
		     decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(p_budget_approved),SUM(p_ptd_cost)) Prev_PTD_cost,
		     SUM(p_ptd_leads) Prev_PTD_leads,
                     decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(t_budget_approved),SUM(total_cost)) total_cost,
                     Sum(total_leads) total_leads,
                     Sum(total_revenue) total_revenue
                  FROM
          	  ( ';

l_curr_suffix1 :=l_curr_suffix;

IF l_object_type in ('CAMP','EVEH','CSCH') AND l_prog_cost ='BIM_APPROVED_BUDGET' and l_view_by = 'CAMPAIGN+CAMPAIGN' THEN

--l_table_bud :=  ' ,bim_i_marketing_facts facts';

--l_where_bud := ' AND facts.source_code_id = a.source_code_id';
IF l_curr_suffix is null THEN
l_prog_cost1 := 'a.budget_approved_sch';
ELSE
l_curr_suffix1 := null;
l_prog_cost1 := 'a.budget_approved_sch_s';
END IF;
ELSE
l_prog_cost1 :='a.budget_approved';
END IF;


/* l_select1 and l_select2 contains column information common to all select statement for all view by */

l_select1:=
' , SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.total_leads else 0 end) ptd_leads,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.actual_cost'||l_curr_suffix||' else 0 end) ptd_cost,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then '||l_prog_cost1||l_curr_suffix1||' else 0 end) budget_approved,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.total_leads else 0 end) p_ptd_leads,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.actual_cost'||l_curr_suffix||' else 0 end) p_ptd_cost,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then '||l_prog_cost1||l_curr_suffix1||' else 0 end) p_budget_approved,
0 total_cost,0 t_budget_approved,0 total_leads,0 total_revenue ';

 l_select2 :=  ' ,0  ptd_leads,
		0 ptd_cost,0 budget_approved,0  p_ptd_leads,0 p_ptd_cost,0  p_budget_approved,
		SUM(a.cost_actual'||l_curr_suffix||') total_cost,
                SUM('||l_prog_cost1||l_curr_suffix1||') t_budget_approved, SUM(a.leads)  total_leads,
		SUM(case  '''|| l_revenue ||'''
                when ''BOOKED_AMT'' then    a.orders_booked_amt'||l_curr_suffix||'
		when ''INVOICED_AMT'' then  a.orders_invoiced_amt'||l_curr_suffix||'
               when ''WON_OPPR_AMT'' then  a.won_opportunity_amt'||l_curr_suffix||'
     end
     ) total_revenue ';


/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';


 /* l_where contains where clause to join time dimension table common to all select statement for all view by */

 l_where :=' WHERE a.time_id = cal.time_id  AND  a.period_type_id = cal.period_type_id  AND  cal.calendar_id= -1 ';



 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */

l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
                  ')  )  WHERE  bim_attribute4 <> 0  or bim_attribute2 <> 0  or prev_ptd_leads <> 0 or prev_ptd_cost <> 0
		  or BIM_ATTRIBUTE6 <> 0 or BIM_ATTRIBUTE8 <> 0 or BIM_ATTRIBUTE10<> 0 &ORDER_BY_CLAUSE ';





l_select_filter_camp := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
                  ')  )  WHERE  bim_attribute4 <> 0  or bim_attribute2 <> 0  or prev_ptd_leads <> 0 or prev_ptd_cost <> 0
 or BIM_ATTRIBUTE6 <> 0 or BIM_ATTRIBUTE8 <> 0 or BIM_ATTRIBUTE10 <> 0) WHERE  bim_attribute4 <> 0  or bim_attribute2 <> 0
		 or  BIM_ATTRIBUTE6 <> 0 or BIM_ATTRIBUTE8 <> 0 or BIM_ATTRIBUTE10 <> 0  &ORDER_BY_CLAUSE ';

 /* get_admin_status to check current user is admin or not */


  /*********************** security handling ***********************/
/*********************** security handling ***********************/

IF   l_campaign_id is null THEN /******* no security checking at child level ********/
	IF   l_admin_status = 'N' THEN
		IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
		/*************** program view is enable **************/
			IF l_prog_view='Y' then
				l_view := ',''RCAM''';
				l_from := l_from ||',bim_i_top_objects ac ';
				l_where := l_where ||' AND a.source_code_id=ac.source_code_id
							AND ac.resource_id = :l_resource_id ';
				/************************************************/
			ELSE

				l_from := l_from ||',ams_act_access_denorm ac,bim_i_source_codes src ';
				l_where := l_where ||' AND a.source_code_id=src.source_code_id
						       AND src.object_id=ac.object_id
						       AND src.object_type=ac.object_type
						       AND src.object_type NOT IN (''RCAM'')
						       AND ac.resource_id = :l_resource_id ';

			END IF;

		ELSE
			l_from := l_from ||',bim_i_top_objects ac ';
			l_where := l_where ||' AND a.source_code_id=ac.source_code_id
				AND ac.resource_id = :l_resource_id ';
		END IF;

	ELSE
		IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
			IF  l_prog_view='Y' THEN
				l_view := ',''RCAM''';
				l_top_cond :=' AND a.immediate_parent_id is null ';
			END IF;
		ELSE
			/******** to append parent object id is null for other view by (country and product category) ***/
			l_top_cond :=' AND a.immediate_parent_id is null ';
			/***********/
		END IF;
	END IF;
END IF;
/************************************************************************/

   /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''  AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;
/********************************/

    IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN


     /* forming from clause for the tables which is common to all union all */
     if l_cat_id is not null then
      l_from1 :=' FROM BIM_I_obj_METS_MV a '||l_from||l_pc_from;
     l_from :=' FROM BIM_I_CPB_METS_MV a'||l_from||l_pc_from;
     else
      l_from1 :=' FROM BIM_I_obj_METS_MV a '||l_from;
     l_from :=' FROM BIM_I_CPB_METS_MV a'||l_from;
        end if;


      /* forming where clause which is common to all union all */
     l_where :=l_where||'
		 AND a.object_country = :l_country '||
		 l_pc_where;


    /* forming group by clause for the common columns for all union all */
    l_groupby:=' GROUP BY a.source_code_id,camp.object_type_mean, ';

 /*** campaign id null means No drill down and view by is camapign hirerachy*/

  IF l_campaign_id is null THEN

   /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/

     l_sqltext:= l_select_cal||
     /******** inner select start from here */

     /* select to get camapigns and programs for current period values */
     ' SELECT
      a.source_code_id VIEWBYID, camp.name name,camp.object_id object_id, camp.object_type object_type,
      camp.object_type_mean meaning '||
      l_select1 ||
      l_from || ' ,bim_i_obj_name_mv camp '|| l_where ||l_top_cond||
    ' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
      AND a.source_code_id=camp.source_code_id
      AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
     ' UNION ALL      /* select to get camapigns and programs for previous period values */
     SELECT
      a.source_code_id VIEWBYID, camp.name name, camp.object_id object_id, camp.object_type object_type,
      camp.object_type_mean meaning '||
      l_select2 ||
      l_from1 || ' ,bim_i_obj_name_mv camp '||
     l_where ||l_top_cond||
    ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id AND a.source_code_id=camp.source_code_id
      AND cal.report_date =trunc(sysdate)  AND camp.language=USERENV(''LANG'')'||
      l_groupby|| ' camp.name,camp.object_id,camp.object_type'|| l_select_filter_camp /* appending filter clause */
      ;
 ELSE
 /* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
/* appending table in l_form and joining conditon for the bim_i_source_codes */

     l_where :=l_where || ' AND  a.immediate_parent_id = :l_campaign_id ' ;



-- if program is selected from the page means it may have childern as programs,campaigns,events or one off events


l_curr_suffix1 :=l_curr_suffix;



 IF l_object_type='RCAM' THEN
 /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
     l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapigns and programs for current period values */
     ' SELECT
      a.source_code_id VIEWBYID, camp.name name,camp.object_id object_id, camp.object_type object_type,
      camp.object_type_mean meaning '||   l_select1 ||  l_from || ' ,bim_I_obj_name_mv camp '||
     l_where ||  ' AND a.source_code_id=camp.source_code_id  AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
      AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
     ' UNION ALL      /* select to get camapigns and programs for previous period values */
     SELECT
      a.source_code_id VIEWBYID,camp.name name, camp.object_id object_id, camp.object_type object_type,
      camp.object_type_mean meaning '||
      l_select2 ||
      l_from1 || ' ,bim_I_obj_name_mv camp '||
     l_where ||
    ' AND a.source_code_id=camp.source_code_id AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
     AND cal.report_date =  trunc(sysdate)   AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
      l_select_filter_camp ;
      /*************** if object type is camp then childern are campaign schedules ***/
 ELSIF l_object_type='CAMP' THEN


	 l_sqltext:= l_select_cal||
 /******** inner select start from here */
 /* select to get camapign schedules for current period values */
 ' SELECT
  a.source_code_id VIEWBYID, camp.name name,
  camp.object_id object_id,  camp.object_type object_type,  camp.child_object_usage usage, decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,  camp.object_type_mean meaning '||
  l_select1 ||
  l_from || ' ,bim_i_obj_name_mv camp,bim_dimv_media chnl '||
 l_where ||
' AND camp.source_code_id = a.source_code_id  AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
  AND camp.object_type =''CSCH''  AND camp.activity_id =chnl.id (+)  AND cal.report_date  in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
  AND camp.language=USERENV(''LANG'')'||
  l_groupby||
	      ' camp.name,camp.object_id,camp.object_type,camp.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
   ' UNION ALL      /* select to get camapign schedules for previous period values */
   SELECT
    a.source_code_id VIEWBYID, camp.name name, camp.object_id object_id,camp.object_type object_type, camp.child_object_usage usage,
    decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel, camp.object_type_mean meaning '||
    l_select2 || l_from1 || ' ,bim_i_obj_name_mv camp,bim_dimv_media chnl  '||
    l_where || ' AND camp.source_code_id = a.source_code_id    AND  BITAND(cal.record_type_id,1143)= cal.record_type_id    AND camp.object_type =''CSCH''
    AND camp.activity_id =chnl.id (+)    AND cal.report_date = trunc(sysdate)    AND camp.language=USERENV(''LANG'')'||
    l_groupby||   ' camp.name,camp.object_id,camp.object_type,camp.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
   l_select_filter_camp ;
/*************** if object type is event then childern are event schedules ***/


  ELSIF l_object_type='EVEH' THEN
 l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get event schedules for current period values  */
     ' SELECT      a.source_code_id VIEWBYID,  camp.name name,camp.object_id object_id, camp.object_type object_type,
      camp.object_type_mean meaning '|| l_select1 || l_from || ' ,bim_I_obj_name_mv camp '|| l_where || ' AND  camp.source_code_id = a.source_code_id AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
      AND camp.object_type =''EVEO'' AND cal.report_date  in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
     ' UNION ALL      /* select to get event schedules for previous period values */
     SELECT
      a.source_code_id VIEWBYID,
      camp.name name, camp.object_id object_id, camp.object_type object_type, camp.object_type_mean meaning '||
      l_select2 ||
      l_from1 || ' ,bim_I_obj_name_mv camp '||
      l_where ||
    ' AND camp.source_code_id = a.source_code_id  AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
      AND camp.object_type =''EVEO''  AND cal.report_date = trunc(sysdate)  AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
      l_select_filter_camp ;
  END IF;

 END IF;

 /***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/

 ELSE
 /* view by is product category */
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN

   if l_admin_status='N' then
        l_from:=replace(l_from,',fii_time_rpt_struct_v cal');
    else
        l_from:=null;
    end if;


/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT  /*+ORDERED*/
		   p.value name,
                   p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag ';
    ELSE
    /* passing id from page and getting immediate child to build hirerachy  */

    /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/

     l_pc_from:= l_from||
                   ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';

    l_pc_where :=l_where||
                      ' AND a.category_id = p.id ';

    l_from:= l_from||
            ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

     l_where := l_where||'
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id ';

     l_col:=' SELECT   /*+ORDERED*/
		   p.value name,
                   p.id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
    END IF;
/*********************/

           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
	       l_from1:=' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
                              '||l_from;
              l_from:=' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '   AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from1 := ' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
                              '||l_pc_from;
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
                              '||l_pc_from;

		  l_pc_where := l_pc_where ||l_top_cond||
                         ' AND  a.object_country = :l_country';
               END IF;
              ELSE
	      l_from1:=' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
                             '||l_from;
              l_from:=' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
                             '||l_from;

              l_where := l_where ||
/*                        ' AND a.parent_object_id is null               */
			  ' AND  a.object_country = :l_country';

		IF l_cat_id is not null then
		  l_pc_from1 := ' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
                              '||l_pc_from;
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a
                              '||l_pc_from;

		  l_pc_where := l_pc_where ||
                   /*      ' AND a.parent_object_id is null   */
			'   AND  a.object_country = :l_country';
               END IF;

              END IF;
           ELSE
	     l_from1 := ' FROM   fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a'||l_from ;
             l_from  := ' FROM   fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a '||l_from ;

              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then
	         l_pc_from1 := ' FROM   fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a '||l_pc_from ;
	         l_pc_from := ' FROM   fii_time_rpt_struct_v cal, BIM_I_CPB_METS_MV a '||l_pc_from ;

               l_pc_where  := l_pc_where ||
                        '  AND a.immediate_parent_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN


	  l_pc_col:=' SELECT /*+ORDERED*/
		   bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
                   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.id ';


 l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_select1||
	      l_pc_from||
	      l_pc_where ||' AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	                   'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id  '||
	      l_pc_groupby ||
	      ' UNION ALL ' ||
	      l_pc_col||
	      l_select2||
	      l_pc_from1||l_inner||
	      l_pc_where ||' AND cal.report_date =trunc(sysdate) '||
	                   'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
			   l_inr_cond||
	      l_pc_groupby ;
   END IF;

 ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
   /** product category handling**/

  /** l_union_inc and l_col_inc ,,is for performance gain ,for country and product category for admin combination  */
l_union_inc := ',fii_time_rpt_struct_v cal ,BIM_I_OBJ_METS_MV a,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs
,fnd_territories_tl  d ';

l_col_inc   :='SELECT /*+ ordered */ decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
a.object_country viewbyid,    null meaning ';

  IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;

     l_col:=' SELECT decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
                a.object_country viewbyid,    null meaning ';

    l_groupby := ' GROUP BY    decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country  ';
 l_from:=' FROM fnd_territories_tl  d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	        l_from1:=l_from||' ,BIM_I_OBJ_METS_MV a ';
	        l_from:=l_from||'  ,BIM_I_CPB_METS_MV a ';

              l_where := l_where ||l_top_cond||
                         '   AND a.object_country =d.territory_code(+)
			     AND D.language(+) = userenv(''LANG'') ';
              ELSE
	       l_from1:=l_from||' ,BIM_I_OBJ_METS_MV a ';
               l_from:=l_from||'  ,BIM_I_CPB_METS_MV a ';

              l_where := l_where ||
	                 '   AND  a.object_country =d.territory_code(+)
			     AND D.language(+) = userenv(''LANG'') ';
              END IF;
            ELSE
	       l_from1 := l_from||' ,BIM_I_OBJ_METS_MV a ';
               l_from := l_from||' ,BIM_I_CPB_METS_MV a ';

              l_where  := l_where ||
                        '  AND a.source_code_id = :l_campaign_id
                           AND  a.object_country =d.territory_code(+)
			   AND d.language(+) = userenv(''LANG'') ';
	  END IF;
	  IF  l_country <>'N' THEN
	      l_where  := l_where ||' AND  a.object_country = :l_country';
          ELSE
	   l_where  := l_where ||' AND  a.object_country <> ''N''';
	  END IF;

ELSIF (l_view_by ='MEDIA+MEDIA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bim_dimv_media d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN

               l_from1:=l_from||' ,BIM_OBJ_CHNL_MV  a ';
	      l_from:=l_from||' ,BIM_I_CPB_CHNL_MV a ';

              l_where := l_where ||
                         ' AND  d.id (+)= a.activity_id
			   AND  a.immediate_parent_id is null
			   AND  a.object_country = :l_country';
              ELSE

	      l_from1:=l_from||' ,BIM_OBJ_CHNL_MV a ';
              l_from:=l_from||' ,BIM_I_CPB_CHNL_MV a ';

              l_where := l_where ||
	              /*   ' AND  a.parent_object_id is null           */
                         '  AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE

	     l_from1 := l_from||' ,BIM_OBJ_CHNL_MV a';
              l_from := l_from||' ,BIM_I_CPB_CHNL_MV a ';

              l_where  := l_where ||
                        '  AND a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bis_areas_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
               l_from1:=l_from||' ,BIM_OBJ_REGN_MV  a ';
	      l_from:=l_from||' ,BIM_I_CPB_REGN_MV a ';

              l_where := l_where ||
                         ' AND  d.id (+)= a.object_region
			   AND  a.immediate_parent_id is null
			   AND  a.object_country = :l_country';
              ELSE
	       l_from1:=l_from||' ,BIM_OBJ_REGN_MV a ';
              l_from:=l_from||' ,BIM_I_CPB_REGN_MV a ';

              l_where := l_where ||
	              /*   ' AND  a.parent_object_id is null           */
                         '  AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
	      l_from1 := l_from||' ,BIM_OBJ_REGN_MV a ';
              l_from := l_from||'  ,BIM_I_CPB_REGN_MV a ';

              l_where  := l_where ||
                        '
                           AND a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
	  END IF;

END IF;



/* combine sql one to pick up current period values and  sql two to pick previous period values */

  l_select := l_col||
              l_select1||
	      l_from||
	      l_where ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	      'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id  '||
	      l_groupby ||
	      ' UNION ALL ';

if (l_view_by ='GEOGRAPHY+COUNTRY'  and l_campaign_id is null and l_cat_id is not null and l_admin_status = 'Y') then
l_select :=   l_select||l_col_inc||l_select2||' from '||l_inner||l_union_inc ;
 else
l_select :=   l_select||l_col||l_select2||l_from1||l_inner;
end if;

l_select :=   l_select||l_where ||' AND cal.report_date = trunc(sysdate) '||
	      'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
	      l_inr_cond||
	      l_groupby||
	      l_pc_select /* l_pc_select only applicable when product category is not all and view by is product category */
	      ;


	       /* l_pc_select only applicable when product category is not all and view by is product category */


/* prepare final sql */

 l_sqltext:= l_select_cal1||
             l_select||
	     l_select_filter;
  END IF;



   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_resource_id';
   l_custom_rec.attribute_value := get_resource_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_admin_flag';
   l_custom_rec.attribute_value := get_admin_status;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (3) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_country';
   l_custom_rec.attribute_value := l_country;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (4) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_cat_id';
   l_custom_rec.attribute_value := l_cat_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (5) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_campaign_id';
   l_custom_rec.attribute_value := l_campaign_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (6) := l_custom_rec;
   write_debug ('GET_CPL_RPL_SQL', 'QUERY', '_', l_sqltext);
EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_CPL_RPL_SQL', 'ERROR', l_sql_errm, l_sqltext);
END GET_CPL_RPL_SQL;


PROCEDURE GET_RPL_CPL_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (32000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (25000); -- to build  select calculation part
   l_select_cal1                  VARCHAR2 (25000);
   l_select_filter                VARCHAR2 (25000); -- to build  select filter part
   l_select_filter_camp           VARCHAR2 (25000);
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_from_inr                     VARCHAR2 (20000);
   l_where_inr                    VARCHAR2 (20000);
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(200);
   l_pc_groupby                   VARCHAR2(200);
   l_view                         VARCHAR2 (20);
   l_select1                      VARCHAR2 (20000);
   l_select2                      VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(1000);
   l_url_str_csch                 varchar2(1000);
   l_url_str_type                 varchar2(1000);
   l_url_str_csch_jtf             varchar2(3000);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_csch_chnl                    varchar2(100);
   l_top_cond                     VARCHAR2(100);
   l_meaning                      VARCHAR2 (20);
   l_inner                        varchar2(5000);
   l_inr_cond                     varchar2(5000);
   l_obj_revenue                  varchar2(50);
   l_cpb_revenue                  varchar2(50);
   rpl                            varchar2(500);
   p_rpl                          varchar2(500);
   l_union_inc                    varchar2(5000);
   l_col_inc                      varchar2(1000);
   l_curr VARCHAR2(50);
   l_curr_suffix VARCHAR2(50);
   l_col_id NUMBER;
   l_area VARCHAR2(300);
   l_report_name VARCHAR2(300);
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                   bis_query_attributes;
   l_object_type                  varchar2(30);
   l_url_link                     varchar2(200);
   l_url_camp1                     varchar2(3000);
   l_url_camp2                     varchar2(3000);
   l_dass                          varchar2(100);  -- variable to store value for  directly assigned lookup value
  -- l_una                           varchar2(100);   -- variable to store value for  Unassigned lookup value
     l_leaf_node_flag               varchar2(25);   -- variable to store value leaf_node_flag column in case of product category
     l_media VARCHAR2(300);
    -- l_jtf  varchar2(300);
   l_curr_suffix1 VARCHAR2(50);
   l_table_bud VARCHAR2(300);
   l_where_bud VARCHAR2(300);
   l_prog_cost1 VARCHAR2(30);
BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

   l_meaning:=' null meaning '; -- assigning default value
   l_url_camp1:=',null';
   l_url_camp2:=',null';
   IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;

   l_admin_status := get_admin_status;

   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;



 rpl:= ' (decode(sum(BIM_ATTRIBUTE4) over(),0,0,sum(BIM_ATTRIBUTE2) over() /sum(BIM_ATTRIBUTE4) over() )) ' ;
 p_rpl:= ' (decode(sum(prev_ptd_leads) over() ,0,0,sum(prev_ptd_revenue) over() /sum(prev_ptd_leads) over())) ';

   IF l_revenue = 'BOOKED_AMT' THEN

    l_obj_revenue :=' orders_booked_amt ';
    l_cpb_revenue :='  booked_amt ';

   ELSIF l_revenue = 'INVOICED_AMT'   THEN

    l_obj_revenue :=' orders_invoiced_amt ';
    l_cpb_revenue :=' invoiced_amt ';

   ELSIF l_revenue = 'WON_OPPR_AMT' THEN

    l_obj_revenue :=' won_opportunity_amt ';
    l_cpb_revenue :='won_opportunity_amt ';

   END IF;

   /*********************** security handling for inner query ***********************/

/* IF  l_view_by <> 'CAMPAIGN+CAMPAIGN' then
     IF   l_campaign_id is null THEN
     IF   l_admin_status = 'N' THEN
	     IF l_prog_view='Y' then
	            l_from_inr :=', bim_i_top_objects  inr_r ';
	    ELSE
	         l_from_inr :=', ams_act_access_denorm  inr_r ';
             END IF;
                l_where_inr := '  AND a.source_code_id = inr_r.source_code_id  AND inr_r.resource_id = :l_resource_id ';

	ELSE
	        l_where_inr   :=' AND a.immediate_parent_id is null ';

    END IF;

   END IF;
   END IF;*/

/************************************************************************/


/************Start Inner Query to get current acitve objects *************************/

 IF   l_campaign_id is null THEN

 if (l_view_by ='GEOGRAPHY+COUNTRY'  and l_cat_id is not null and l_admin_status = 'Y') then

    l_inner:='  ( select distinct  a.source_code_id   from fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a  '||l_from_inr;
else
    l_inner:=', ( select distinct  a.source_code_id   from fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a  '||l_from_inr;
end if;

    IF l_cat_id is not null then
     l_inner := l_inner ||', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
    end if;

    l_inner := l_inner || ' WHERE   a.time_id=cal.time_id  AND a.period_type_id=cal.period_type_id  AND cal.calendar_id=-1  AND cal.report_date   in (&BIS_CURRENT_ASOF_DATE)
    AND a.object_country = :l_country   AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id   and ( a.'||l_obj_revenue||' >0 or a.leads >0)';


    IF l_cat_id is null then
      l_inner :=  l_inner ||' AND a.category_id = -9 ';
    else
      l_inner :=  l_inner ||' AND a.category_id = edh.child_id  AND edh.object_type = ''CATEGORY_SET''   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11   AND edh.dbi_flag = ''Y''    AND edh.parent_id = :l_cat_id ';
    end if;

    l_inner := l_inner ||l_where_inr;

    l_inner :=  l_inner ||' ) inr ';


l_inr_cond:='and a.source_code_id=inr.source_code_id ';


end if;

/************ End Inner Query to get current acitve objects *************************/

/** to add meaning in select clause only in case of campaign view by */
  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' ,meaning ';
  l_filtercol:=',meaning ';
  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  l_filtercol:=',leaf_node_flag ';
  l_meaning:=',null meaning ';
  else
  l_meaning:=' ,null meaning ';
  end if;

  /*** to display Directly assigned  **/

    /*** to  assigned URL **/

if l_campaign_id is not null then
-- checking for the object type passed from page
 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;
end if;

  -- l_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
   l_url_str  :='pFunctionName=BIM_I_RPL_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
   --l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
   IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
       l_url_link :=' ,decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) ';
       l_view_disp:='viewby';
       l_leaf_node_flag :=' ,leaf_node_flag ';
   ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
     l_camp_sel_col :=' ,object_id
                       ,object_type
                       ';
     l_camp_groupby_col :=',object_id,object_type ';
     l_url_link := ' ,null ';
     l_view_disp := 'viewby';

     IF (l_campaign_id is  null or l_object_type='RCAM') then
	l_url_camp1:=', decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' )';
     ELSIF l_object_type='CAMP' THEN
	l_url_camp2:=', '||''''||l_url_str_type||''''||'||object_id';
         --l_url_camp1:=', decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_csch_jtf||''''||'||object_id)';
		 l_url_camp1:=', '||''''||l_url_str_csch||''''||'||object_id';
	l_csch_chnl:='|| '' - '' || channel';
	l_camp_sel_col :=l_camp_sel_col|| ',usage,channel';
	l_camp_groupby_col :=l_camp_groupby_col||',usage,channel';
     end if;
    ELSE
     -- l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
      l_url_link:=' ,null ';
      l_view_disp:='viewby';
   END IF;

/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal :='select VIEWBY ,viewbyid,BIM_ATTRIBUTE7,bim_attribute2 ,BIM_ATTRIBUTE4,BIM_ATTRIBUTE3  ,BIM_ATTRIBUTE5 ,BIM_ATTRIBUTE6  ,BIM_ATTRIBUTE8  ,BIM_ATTRIBUTE9,BIM_ATTRIBUTE10
,bim_url1,bim_url2,bim_url3,BIM_GRAND_TOTAL1 , BIM_GRAND_TOTAL2,BIM_GRAND_TOTAL3 ,BIM_GRAND_TOTAL4 ,BIM_GRAND_TOTAL5 ,BIM_GRAND_TOTAL6 ,BIM_GRAND_TOTAL7 ,BIM_GRAND_TOTAL8
from (   SELECT '|| l_view_disp ||' ,viewbyid ,BIM_ATTRIBUTE7 '||l_csch_chnl||' bim_attribute7
 ,BIM_ATTRIBUTE2 ,BIM_ATTRIBUTE4,decode(prev_rpl,0,null,((BIM_ATTRIBUTE5-prev_rpl)/prev_rpl)*100) BIM_ATTRIBUTE3
,BIM_ATTRIBUTE5,BIM_ATTRIBUTE6,BIM_ATTRIBUTE8,BIM_ATTRIBUTE9,BIM_ATTRIBUTE10'||
l_url_link || ' bim_url1'||l_url_camp1|| ' bim_url2 '||l_url_camp2||' bim_url3
,BIM_GRAND_TOTAL1  ,decode('||p_rpl||',0,null,(('||rpl||' - '||p_rpl||')/ '||p_rpl||')*100 ) BIM_GRAND_TOTAL2
,BIM_GRAND_TOTAL3,BIM_GRAND_TOTAL4,BIM_GRAND_TOTAL5,BIM_GRAND_TOTAL6,BIM_GRAND_TOTAL7,BIM_GRAND_TOTAL8
   FROM (
SELECT
 name    VIEWBY ,VIEWBYID
,meaning BIM_ATTRIBUTE7 '||l_camp_sel_col||'
,ptd_revenue BIM_ATTRIBUTE2,ptd_leads BIM_ATTRIBUTE4,decode(ptd_leads,0,null,ptd_revenue/ptd_leads) BIM_ATTRIBUTE5
,decode(prev_ptd_leads,0,null,prev_ptd_revenue/prev_ptd_leads) prev_rpl,total_leads BIM_ATTRIBUTE6
,total_revenue BIM_ATTRIBUTE8,decode(total_leads,0,null,total_revenue/total_leads) BIM_ATTRIBUTE9
,total_cost  BIM_ATTRIBUTE10,sum(ptd_revenue) over() BIM_GRAND_TOTAL1,99 BIM_GRAND_TOTAL2
 ,sum(ptd_leads) over() BIM_GRAND_TOTAL3,decode(sum(ptd_leads) over(),0,null,sum(ptd_revenue) over()/sum(ptd_leads) over()) BIM_GRAND_TOTAL4
,sum(total_leads) over() BIM_GRAND_TOTAL5,sum(total_revenue) over() BIM_GRAND_TOTAL6
,decode(sum(total_leads) over(),0,null,sum(total_revenue) over()/sum(total_leads) over()) BIM_GRAND_TOTAL7,sum(total_cost) over() BIM_GRAND_TOTAL8
,prev_ptd_leads ,prev_ptd_revenue
FROM
(  SELECT
viewbyid,name'||l_meaning ||l_camp_sel_col||',SUM(ptd_revenue) ptd_revenue,SUM(ptd_leads) ptd_leads,SUM(p_ptd_revenue) prev_ptd_revenue
 ,SUM(p_ptd_leads) Prev_PTD_leads ,case when ( (SUM(ptd_revenue) > 0) or (SUM(ptd_leads) > 0)) then SUM(total_revenue) else 0 end   total_revenue,case when ( (SUM(ptd_revenue) > 0)or (SUM(ptd_leads)    >0) ) then
Sum(total_leads)  else 0 end total_leads,case when ((SUM(ptd_revenue) > 0) or (SUM(ptd_leads)>0) ) then decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(t_budget_approved),SUM(total_cost))
else 0 end total_cost  FROM ( ';

/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal1 :='
 SELECT '||l_view_disp ||',viewbyid,BIM_ATTRIBUTE7,BIM_ATTRIBUTE2,BIM_ATTRIBUTE4
 ,decode(prev_rpl,0,null,((BIM_ATTRIBUTE5-prev_rpl)/prev_rpl)*100) BIM_ATTRIBUTE3,BIM_ATTRIBUTE5,BIM_ATTRIBUTE6,BIM_ATTRIBUTE8,BIM_ATTRIBUTE9
,BIM_ATTRIBUTE10'||l_url_link|| ' bim_url1'||' ,null BIM_URL2,null BIM_URL3,BIM_GRAND_TOTAL1 ,decode('||p_rpl||',0,null,(('||rpl||' - '||p_rpl||')/ '||p_rpl||')*100 ) BIM_GRAND_TOTAL2
,BIM_GRAND_TOTAL3,BIM_GRAND_TOTAL4,BIM_GRAND_TOTAL5,BIM_GRAND_TOTAL6,BIM_GRAND_TOTAL7,BIM_GRAND_TOTAL8
   FROM
( SELECT
 name  VIEWBY,VIEWBYID'||l_leaf_node_flag||', meaning BIM_ATTRIBUTE7,ptd_revenue BIM_ATTRIBUTE2,ptd_leads BIM_ATTRIBUTE4,decode(ptd_leads,0,null,ptd_revenue/ptd_leads) BIM_ATTRIBUTE5,
decode(prev_ptd_leads,0,null,prev_ptd_revenue/prev_ptd_leads) prev_rpl,total_leads BIM_ATTRIBUTE6,
total_revenue BIM_ATTRIBUTE8,decode(total_leads,0,null,total_revenue/total_leads) BIM_ATTRIBUTE9,
total_cost  BIM_ATTRIBUTE10,sum(ptd_revenue) over() BIM_GRAND_TOTAL1,66 BIM_GRAND_TOTAL2,
sum(ptd_leads) over() BIM_GRAND_TOTAL3,decode(sum(ptd_leads) over(),0,null,sum(ptd_revenue) over()/sum(ptd_leads) over()) BIM_GRAND_TOTAL4,
sum(total_leads) over() BIM_GRAND_TOTAL5,sum(total_revenue) over() BIM_GRAND_TOTAL6,decode(sum(total_leads) over(),0,null,sum(total_revenue) over()/sum(total_leads) over()) BIM_GRAND_TOTAL7,
 sum(total_cost) over() BIM_GRAND_TOTAL8 ,prev_ptd_leads ,prev_ptd_revenue
   FROM (
SELECT
viewbyid,name'||l_leaf_node_flag||l_meaning||',SUM(ptd_revenue) ptd_revenue,SUM(ptd_leads) ptd_leads,
 SUM(p_ptd_revenue) prev_ptd_revenue,SUM(p_ptd_leads) Prev_PTD_leads,SUM(total_revenue) total_revenue,
Sum(total_leads) total_leads,decode('''|| l_prog_cost ||''',''BIM_APPROVED_BUDGET'',SUM(t_budget_approved),SUM(total_cost)) total_cost
  FROM  ( ';



l_curr_suffix1 :=l_curr_suffix;

IF l_object_type in ('CAMP','EVEH','CSCH') AND l_prog_cost ='BIM_APPROVED_BUDGET' AND l_view_by = 'CAMPAIGN+CAMPAIGN' THEN

--l_table_bud :=  ' ,bim_i_marketing_facts facts';
--l_where_bud := ' AND facts.source_code_id = a.source_code_id';
IF l_curr_suffix is null THEN
l_prog_cost1 := 'a.budget_approved_sch';
ELSE
l_curr_suffix1 := null;
l_prog_cost1 := 'a.budget_approved_sch_s';
END IF;
ELSE
l_prog_cost1 :='a.budget_approved';

END IF;


/* l_select1 and l_select2 contains column information common to all select statement for all view by */

l_select1:=
' , SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.leads else 0 end) ptd_leads,
    SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then case  '''|| l_revenue ||'''   when ''BOOKED_AMT'' then    a.orders_booked_amt'||l_curr_suffix||'
  when ''INVOICED_AMT'' then  a.orders_invoiced_amt'||l_curr_suffix||'  when ''WON_OPPR_AMT'' then  a.won_opportunity_amt'||l_curr_suffix||'   end  else 0 end) ptd_revenue,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.leads else 0 end) p_ptd_leads,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then 	 case  '''|| l_revenue ||'''   when ''BOOKED_AMT'' then    a.orders_booked_amt'||l_curr_suffix||'
when ''INVOICED_AMT'' then  a.orders_invoiced_amt'||l_curr_suffix||'  when ''WON_OPPR_AMT'' then  a.won_opportunity_amt'||l_curr_suffix||' end  else 0 end) p_ptd_revenue,0 total_revenue,0 total_leads,
0 total_cost,0 t_budget_approved';

 l_select2 :=
 ' ,0  ptd_leads,   0 ptd_revenue,  0  p_ptd_leads, 0 p_ptd_revenue,  SUM( case  '''|| l_revenue ||''' when ''BOOKED_AMT'' then    a.orders_booked_amt'||l_curr_suffix||'
  when ''INVOICED_AMT'' then  a.orders_invoiced_amt'||l_curr_suffix||'   when ''WON_OPPR_AMT'' then  a.won_opportunity_amt'||l_curr_suffix||'  end ) total_revenue,
SUM(a.leads)  total_leads,  SUM(a.cost_actual'||l_curr_suffix||') total_cost, SUM('||l_prog_cost1||l_curr_suffix1||') t_budget_approved ';

/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';


 /* l_where contains where clause to join time dimension table common to all select statement for all view by */

 l_where :=' WHERE a.time_id = cal.time_id  AND  a.period_type_id = cal.period_type_id   AND  cal.calendar_id= -1 ';



 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */

l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
 ')  )  WHERE    bim_attribute4 <> 0     or bim_attribute2 <> 0 or prev_ptd_leads <> 0 or prev_ptd_revenue <> 0
  or BIM_ATTRIBUTE6 <> 0 or BIM_ATTRIBUTE8 <> 0 or BIM_ATTRIBUTE10<> 0  &ORDER_BY_CLAUSE ';

l_select_filter_camp := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
')  )  WHERE  bim_attribute4 <> 0  or bim_attribute2 <> 0  or prev_ptd_leads <> 0 or  prev_ptd_revenue<> 0
 or BIM_ATTRIBUTE6 <> 0 or BIM_ATTRIBUTE8 <> 0 or BIM_ATTRIBUTE10<> 0 )  WHERE  bim_attribute4 <> 0  or bim_attribute2 <> 0 or BIM_ATTRIBUTE6 <> 0
 or BIM_ATTRIBUTE8 <> 0 or BIM_ATTRIBUTE10<> 0 &ORDER_BY_CLAUSE ';



 /* get_admin_status to check current user is admin or not */



/*********************** security handling ***********************/

IF   l_campaign_id is null THEN /******* no security checking at child level ********/
	IF   l_admin_status = 'N' THEN
		IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
		/*************** program view is enable **************/
			IF l_prog_view='Y' then
				l_view := ',''RCAM''';
				l_from := l_from ||',bim_i_top_objects ac ';
				l_where := l_where ||' AND a.source_code_id=ac.source_code_id
							AND ac.resource_id = :l_resource_id ';
				/************************************************/
			ELSE

				l_from := l_from ||',ams_act_access_denorm ac,bim_i_source_codes src ';
				l_where := l_where ||' AND a.source_code_id=src.source_code_id
						       AND src.object_id=ac.object_id
						       AND src.object_type=ac.object_type
						       AND src.object_type NOT IN (''RCAM'')
						       AND ac.resource_id = :l_resource_id ';

			END IF;

		ELSE
			l_from := l_from ||',bim_i_top_objects ac ';
			l_where := l_where ||' AND a.source_code_id=ac.source_code_id
				AND ac.resource_id = :l_resource_id ';
		END IF;

	ELSE
		IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
			IF  l_prog_view='Y' THEN
				l_view := ',''RCAM''';
				l_top_cond :=' AND a.immediate_parent_id is null ';
			END IF;
		ELSE
			/******** to append parent object id is null for other view by (country and product category) ***/
			l_top_cond :=' AND a.immediate_parent_id is null ';
			/***********/
		END IF;
	END IF;
END IF;

/************************************************************************/

   /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;
/********************************/

    IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN


     /* forming from clause for the tables which is common to all union all */
     if l_cat_id is not null then
       l_from :=' FROM BIM_I_OBJ_METS_MV a'||l_from||l_pc_from;
     else
     l_from :=' FROM BIM_I_OBJ_METS_MV a '||l_from;
     end if;


      /* forming where clause which is common to all union all */
     l_where :=l_where||'
		 AND a.object_country = :l_country '||
		 l_pc_where;


    /* forming group by clause for the common columns for all union all */
    l_groupby:=' GROUP BY a.source_code_id,camp.object_type_mean, ';

 /*** campaign id null means No drill down and view by is camapign hirerachy*/

  IF l_campaign_id is null THEN

   /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/

     l_sqltext:= l_select_cal||
      ' SELECT
      a.source_code_id VIEWBYID,camp.name name,
      camp.object_id object_id,camp.object_type object_type,
      camp.object_type_mean meaning '||
      l_select1 ||
      l_from || ' ,bim_i_obj_name_mv camp '||
     l_where ||l_top_cond||
    ' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
      AND a.source_code_id=camp.source_code_id
      AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
     ' UNION ALL
     SELECT
      a.source_code_id VIEWBYID,camp.name name,
      camp.object_id object_id,camp.object_type object_type,
      camp.object_type_mean meaning '||
      l_select2 ||
      l_from || ' ,bim_i_obj_name_mv camp '||
     l_where ||l_top_cond||
    ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
      AND a.source_code_id=camp.source_code_id
      AND cal.report_date =trunc(sysdate)
      AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'|| l_select_filter_camp
      ;

 ELSE
 /* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
/* appending table in l_form and joining conditon for the bim_i_source_codes */
    /* l_from  :=l_from||' ,bim_i_source_codes b';
     l_where :=l_where ||
              ' AND  a.parent_denorm_type = b.object_type
                AND  a.parent_object_id =  b.object_id
                AND  b.child_object_id = 0
                AND  b.source_code_id = :l_campaign_id '; */
 l_where :=l_where || ' AND  a.immediate_parent_id = :l_campaign_id ';


-- if program is selected from the page means it may have childern as programs,campaigns,events or one off events

 IF l_object_type='RCAM' THEN
 /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
     l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapigns and programs for current period values */
     ' SELECT
      a.source_code_id VIEWBYID,  camp.name name, camp.object_id object_id, camp.object_type object_type, camp.object_type_mean meaning '||
      l_select1 ||
      l_from || ' ,bim_i_obj_name_mv camp '||
     l_where ||
    ' AND a.source_code_id=camp.source_code_id  AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
      AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND camp.language=USERENV(''LANG'')'||
      l_groupby|| ' camp.name,camp.object_id,camp.object_type'||
     ' UNION ALL      /* select to get camapigns and programs for previous period values */
     SELECT
      a.source_code_id VIEWBYID, camp.name name, camp.object_id object_id, camp.object_type object_type, camp.object_type_mean meaning '||
      l_select2 ||
      l_from || ' ,bim_i_obj_name_mv camp '||
     l_where ||
    ' AND a.source_code_id=camp.source_code_id AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
      AND cal.report_date =  trunc(sysdate)  AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
      l_select_filter_camp;
      /*************** if object type is camp then childern are campaign schedules ***/
 ELSIF l_object_type='CAMP' THEN
	 l_sqltext:= l_select_cal||
	     /******** inner select start from here */
	     /* select to get camapign schedules for current period values */
	     ' SELECT    a.source_code_id VIEWBYID,   camp.name name,  camp.object_id object_id,    camp.object_type object_type,
	      camp.child_object_usage usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,  camp.object_type_mean meaning '||
	      l_select1 || l_from || ' ,bim_I_obj_name_mv camp,bim_dimv_media chnl '||
	     l_where ||
	    ' AND camp.source_code_id = a.source_code_id   AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	      AND camp.object_type =''CSCH''  AND camp.activity_id =chnl.id (+)  AND cal.report_date  in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	      AND camp.language=USERENV(''LANG'')'||
	      l_groupby||
	      ' camp.name,camp.object_id,camp.object_type,camp.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
     ' UNION ALL      /* select to get camapign schedules for previous period values */
     SELECT
      a.source_code_id VIEWBYID, camp.name name, camp.object_id object_id,camp.object_type object_type,
      camp.child_object_usage usage, decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel, camp.object_type_mean meaning '||
      l_select2 ||
      l_from || ' ,bim_I_obj_name_mv camp,bim_dimv_media chnl '||
     l_where ||
    ' AND camp.source_code_id = a.source_code_id  AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
      AND CAMP.object_type =''CSCH''   AND camp.activity_id =chnl.id (+)   AND cal.report_date = trunc(sysdate)
      AND camp.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type,camp.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
      l_select_filter_camp;
/*************** if object type is event then childern are event schedules ***/



  ELSIF l_object_type='EVEH' THEN
 l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get event schedules for current period values  */
     ' SELECT    a.source_code_id VIEWBYID,  camp.name name,  camp.object_id object_id,  camp.object_type object_type,
      camp.object_type_mean meaning '||
      l_select1 ||
      l_from || ' ,bim_i_obj_name_mv camp  '||
     l_where ||
    ' AND  camp.source_code_id = a.source_code_id AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id  AND camp.object_type =''EVEO''
      AND cal.report_date  in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)  AND eve.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
     ' UNION ALL      /* select to get event schedules for previous period values */
     SELECT
      a.source_code_id VIEWBYID, camp.name name, camp.object_id object_id, camp.object_type object_type,  camp.object_type_mean meaning '||
      l_select2 ||
      l_from || ' ,bim_i_obj_name_mv camp '||
      l_where ||
    ' AND camp.source_code_id = a.source_code_id  AND  BITAND(cal.record_type_id,1143)= cal.record_type_id AND camp.object_type =''EVEO''
      AND cal.report_date =trunc(sysdate)  AND eve.language=USERENV(''LANG'')'||
      l_groupby||
      ' camp.name,camp.object_id,camp.object_type'||
      l_select_filter_camp ;
 /*************** if object type is one off event  ***/
/* ELSIF l_object_type='EONE' THEN
       l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get one off event   */
     /*' SELECT   a.source_code_id VIEWBYID, eve.event_offer_name name,a.object_id object_id,a.object_type object_type,l.meaning meaning '||
      l_select1 ||
      l_from || ' ,ams_event_offers_all_tl eve '||
     l_where ||
    ' AND  eve.event_offer_id = a.object_id  AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id AND a.object_type =''EONE''
      AND cal.report_date  in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)  AND eve.language=USERENV(''LANG'')'||
      l_groupby||
      ' eve.event_offer_name,a.object_id,a.object_type'||
     ' UNION ALL      /* select to get one off previous period values */
     /*SELECT   a.source_code_id VIEWBYID, eve.event_offer_name name, a.object_id object_id, a.object_type object_type, l.meaning meaning '||
      l_select2 ||
      l_from || ' ,ams_event_offers_all_tl eve '||
      l_where ||
    ' AND eve.event_offer_id = a.object_id AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  AND a.object_type =''EONE''  AND cal.report_date = trunc(sysdate)
      AND eve.language=USERENV(''LANG'')'||     l_groupby||
      ' eve.event_offer_name,a.object_id,a.object_type'||
      l_select_filter_camp; */
 END IF;

 END IF;

 /***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/

 ELSE

 /* view by is product category */
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN

   if l_admin_status='N' then
     l_from:=replace(l_from,',fii_time_rpt_struct_v cal');
    else
     l_from:=null;
    end if;


/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh  ,mtl_default_category_sets mdcs ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT  /*+ORDERED*/
		   p.value name,
                   p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag ';
    ELSE
    /* passing id from page and getting immediate child to build hirerachy  */

    /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/

     l_pc_from:= l_from||
                   ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';

    l_pc_where :=l_where||
                      ' AND a.category_id = p.id ';

    l_from:= l_from||
            ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

     l_where := l_where||'
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id ';

     l_col:=' SELECT  /*+ORDERED*/
		   p.value name,
                   p.id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
    END IF;
/*********************/

           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
	      l_from:=' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '   AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||l_top_cond||
                         ' AND  a.object_country = :l_country';
               END IF;
              ELSE
              l_from:=' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a   '||l_from;
              l_where := l_where ||  ' AND  a.object_country = :l_country';

		IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||
                   /*      ' AND a.immediate_parent_id is null   */
			'   AND  a.object_country = :l_country';
               END IF;

              END IF;
           ELSE
	      l_from := ' FROM   fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a '||l_from ;
              l_where  := l_where ||
                        '  AND a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then

	      l_pc_from := ' FROM   fii_time_rpt_struct_v cal,BIM_I_OBJ_METS_MV a '||l_pc_from ;
              l_pc_where  := l_pc_where ||
                        '  AND a.immediate_parent_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN
  l_pc_col:=' SELECT /*+ORDERED*/
   		   bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
		   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.id ';

   l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_select1||
	      l_pc_from||
	      l_pc_where ||' AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	                   'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id  '||
	      l_pc_groupby ||
	      ' UNION ALL ' ||
	      l_pc_col||
	      l_select2||
	      l_pc_from||l_inner||
	      l_pc_where ||' AND cal.report_date =trunc(sysdate) '||
	                   'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
			   l_inr_cond||
	      l_pc_groupby ;

   END IF;
 ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
   /** product category handling**/

   l_union_inc := ',fii_time_rpt_struct_v cal ,BIM_I_OBJ_METS_MV a,eni_denorm_hierarchies edh,mtl_default_category_sets mdcs
,fnd_territories_tl  d ';

l_col_inc   :='SELECT /*+ ordered */ decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
a.object_country viewbyid,    null meaning ';


   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
a.object_country  viewbyid,		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country';
    l_from:=' FROM fnd_territories_tl  d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN

	      l_from:=l_from||' ,BIM_I_OBJ_METS_MV a ';
              l_where := l_where ||l_top_cond||
                         '   AND  a.object_country =d.territory_code(+)
			     AND D.language(+) = userenv(''LANG'') ';
              ELSE

              l_from:=l_from||' ,BIM_I_OBJ_METS_MV a ';
              l_where := l_where ||
	                 ' AND  a.object_country =d.territory_code(+)
			     AND D.language(+) = userenv(''LANG'') ';
              END IF;
            ELSE

              l_from := l_from||' ,BIM_I_OBJ_METS_MV a ';
              l_where  := l_where ||
                        '  AND a.source_code_id = :l_campaign_id
                           AND  a.object_country =d.territory_code(+)
			     AND D.language(+) = userenv(''LANG'') ';
	  END IF;
	  IF  l_country <>'N' THEN
	      l_where  := l_where ||' AND  a.object_country = :l_country';
          ELSE
	   l_where  := l_where ||' AND  a.object_country <> ''N''';
	  END IF;

ELSIF (l_view_by ='MEDIA+MEDIA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bim_dimv_media d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN

	      /*l_from:=l_from||' ,bim_mkt_chnl_mv a ';*/

 /*	      ,BIM_I_CPL_CHNL_MV  can't be used since object_id ,object_type is not present*/


	      l_from:=l_from||' ,BIM_OBJ_CHNL_MV a  ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.activity_id
			   AND  a.immediate_parent_id is null
			   AND  a.object_country = :l_country';
              ELSE

              l_from:=l_from||' ,BIM_OBJ_CHNL_MV a ';
              l_where := l_where ||
	               /* AND  a.parent_object_id is null          */
                         '  AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';


              END IF;
            ELSE

              l_from := l_from||' ,BIM_OBJ_CHNL_MV a ';
              l_where  := l_where ||
                        '  AND a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bis_areas_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN

	      /*l_from:=l_from||' ,bim_mkt_chnl_mv a ';*/

 /*	      ,BIM_I_CPL_CHNL_MV  can't be used since object_id ,object_type is not present*/


               l_from:=l_from||' ,BIM_OBJ_REGN_MV a  ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.object_region
			   AND  a.immediate_parent_id is null
			   AND  a.object_country = :l_country';
              ELSE

              l_from:=l_from||' ,BIM_OBJ_REGN_MV a ';
              l_where := l_where ||
	               /* AND  a.parent_object_id is null          */
                         '  AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';


              END IF;
            ELSE

              l_from := l_from||' ,BIM_OBJ_REGN_MV a ';
              l_where  := l_where ||
                        '  AND a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
	  END IF;
END IF;



/* combine sql one to pick up current period values and  sql two to pick previous period values */
 l_select := l_col||
              l_select1||
	      l_from||
	      l_where ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	      'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id  '||
	      l_groupby ||
	      ' UNION ALL ';

if (l_view_by ='GEOGRAPHY+COUNTRY'  and l_campaign_id is null and l_cat_id is not null and l_admin_status = 'Y') then
l_select :=   l_select||l_col_inc||l_select2||' from '||l_inner||l_union_inc ;
 else
l_select :=   l_select||l_col||l_select2||l_from||l_inner;
end if;
l_select :=   l_select||
	      l_where ||' AND cal.report_date =trunc(sysdate) '||
	      'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
	      l_inr_cond||
	      l_groupby||
	      l_pc_select /* l_pc_select only applicable when product category is not all and view by is product category */
	      ;


/* prepare final sql */

 l_sqltext:= l_select_cal1||
             l_select||
	     l_select_filter;
  END IF;

   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_resource_id';
   l_custom_rec.attribute_value := get_resource_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_admin_flag';
   l_custom_rec.attribute_value := get_admin_status;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (3) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_country';
   l_custom_rec.attribute_value := l_country;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (4) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_cat_id';
   l_custom_rec.attribute_value := l_cat_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (5) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_campaign_id';
   l_custom_rec.attribute_value := l_campaign_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (6) := l_custom_rec;
   write_debug ('GET_RPL_CPL_SQL', 'QUERY', '_', l_sqltext);
EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_RPL_CPL_SQL', 'ERROR', l_sql_errm, l_sqltext);
END GET_RPL_CPL_SQL;


PROCEDURE GET_LEAD_OPTY_CONV_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(200);
   l_pc_groupby                   VARCHAR2(200);
   l_view                         VARCHAR2 (20);
   l_comm_cols                    VARCHAR2 (20000);
   l_comm2_cols                   VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(1000);
   l_url_str_csch                 varchar2(1000);
   l_url_str_csch_jtf             varchar2(3000);
   l_url_str_type                 varchar2(3000);
   l_csch_chnl                    varchar2(100);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_top_cond                     VARCHAR2(100);
   l_meaning                      VARCHAR2 (20); -- assigning default value
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                   bis_query_attributes;
   l_object_type                  varchar2(30);
   l_url_link                     varchar2(200) ;
   l_url_camp1                    varchar2(3000);
   l_url_camp2                    varchar2(3000);
   l_dass                         varchar2(100);   -- variable to store value for  directly assigned lookup value
 --  l_una                        varchar2(100);   -- variable to store value for  Unassigned lookup value
   l_leaf_node_flag               varchar2(25);   -- variable to store value leaf_node_flag column in case of product category
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );


   l_meaning:=' null meaning '; -- assigning default value
   l_url_camp1:=',null';
   l_url_camp2:=',null';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
/** to add meaning in select clause only in case of campaign view by */
  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' ,meaning ';
  l_filtercol:=',meaning ';
  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  l_filtercol:=',leaf_node_flag ';
  l_meaning:=',null meaning ';
  else
  l_meaning:=',null meaning ';
  end if;

  /*** to  assigned URL **/

if l_campaign_id is not null then
-- checking for the object type passed from page
 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;
end if;

   l_url_str  :='pFunctionName=BIM_I_MKTG_LEAD_OPTY_CONV&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
   --l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
   l_url_link :=',decode(leaf_node_flag,''Y'',NULL,'||''''||l_url_str||''''||' ) ';
   l_view_disp:='viewby';
   l_leaf_node_flag :=' ,leaf_node_flag ';
    ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
     l_camp_sel_col :=' ,object_id
                       ,object_type
                       ';
     l_camp_groupby_col :=',object_id,object_type ';
     l_url_link := ' ,null ';
     l_view_disp := 'viewby';

     IF (l_campaign_id is  null or l_object_type='RCAM') then
	l_url_camp1:=', decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' )';
     ELSIF l_object_type='CAMP' THEN
       	l_url_camp2:=','||''''||l_url_str_type||''''||'||object_id ';
	--l_url_camp1:=',decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_csch_jtf||''''||'||object_id)';
	l_url_camp1:=', '||''''||l_url_str_csch||''''||'||object_id';
	l_csch_chnl:='|| '' - '' || channel';
	l_camp_sel_col :=l_camp_sel_col|| ',usage,channel';
	l_camp_groupby_col :=l_camp_groupby_col||',usage,channel';
     end if;
    ELSE
      --l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
      l_url_link:=' ,null ';
      l_view_disp:='viewby';
   END IF;
/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal :=' SELECT '|| l_view_disp ||',viewbyid,bim_attribute2'||l_csch_chnl ||' bim_attribute2,bim_attribute3,bim_attribute4,bim_attribute5,bim_attribute6,bim_attribute7,bim_attribute8
	 ,bim_attribute4 bim_attribute9,bim_attribute7 bim_attribute10,bim_attribute3 bim_attribute11,bim_attribute6 bim_attribute12,bim_attribute3 bim_attribute13,bim_attribute18
	 ,bim_attribute6 bim_attribute14 '||l_url_link||' bim_attribute19 '||l_url_camp1|| ' bim_attribute22 '||
	 l_url_camp2||' bim_attribute23,bim_attribute20,bim_attribute21,bim_grand_total1,bim_grand_total2,bim_grand_total3,bim_grand_total4,bim_grand_total5,bim_grand_total6,bim_grand_total7,bim_grand_total8
	 ,bim_grand_total1 bim_grand_total9,bim_grand_total4 bim_grand_total10,bim_grand_total11
          FROM
	 (
            SELECT
            name    VIEWBY'||l_leaf_node_flag||'
            ,meaning BIM_ATTRIBUTE2'||l_camp_sel_col||
            ',leads_converted BIM_ATTRIBUTE3
            ,DECODE(prev_leads_converted,0,NULL,((leads_converted - prev_leads_converted)/prev_leads_converted)*100) BIM_ATTRIBUTE4
	    ,DECODE(leads_converted,0,NULL,leads_conversion_time/leads_converted) BIM_ATTRIBUTE5
            ,aleads_converted BIM_ATTRIBUTE6
            ,DECODE(prev_aleads_converted,0,NULL,((aleads_converted - prev_aleads_converted)/prev_aleads_converted)*100) BIM_ATTRIBUTE7
            ,DECODE(aleads_converted,0,NULL,aleads_conversion_time/aleads_converted) BIM_ATTRIBUTE8
	    ,decode((prior_open+leads),0,0,100*(leads_converted/(prior_open+leads))) BIM_ATTRIBUTE18
	    ,leads_conv_customer BIM_ATTRIBUTE20
            ,leads_conv_prospect BIM_ATTRIBUTE21
            ,sum(leads_converted) over() BIM_GRAND_TOTAL1
            ,decode(sum(prev_leads_converted) over(),0,null,(((sum(leads_converted- prev_leads_converted) over())/sum(prev_leads_converted)over ())*100)) BIM_GRAND_TOTAL2
            ,DECODE(sum(leads_converted) over (),0,NULL,sum(leads_conversion_time) over()/sum(leads_converted)over()) BIM_GRAND_TOTAL3
            ,sum(aleads_converted) over () BIM_GRAND_TOTAL4
            ,decode(sum(prev_aleads_converted) over(),0,null,(((sum(aleads_converted - prev_aleads_converted) over())/sum(prev_aleads_converted)over ())*100)) BIM_GRAND_TOTAL5
            ,DECODE(sum(aleads_converted) over (),0,NULL,sum(aleads_conversion_time) over()/sum(aleads_converted)over()) BIM_GRAND_TOTAL6
	    ,sum(leads_conv_customer) over()     bim_grand_total7
            ,sum(leads_conv_prospect) over()     bim_grand_total8
	    ,decode(sum(prior_open+leads) over(),0,0,100*(sum(leads_converted) over()/sum(prior_open+leads) over())) BIM_GRAND_TOTAL11
            ,VIEWBYID
             FROM
              (   SELECT viewbyid,name'||l_leaf_node_flag||l_meaning||l_camp_sel_col||
		    ',sum(leads_converted) leads_converted,sum(leads_conversion_time) leads_conversion_time,sum(aleads_converted) aleads_converted,sum(aleads_conversion_time) aleads_conversion_time
 	              ,sum(leads_conv_customer) leads_conv_customer,sum(leads_conv_prospect) leads_conv_prospect,sum(prev_leads_converted) prev_leads_converted,sum(prev_aleads_converted) prev_aleads_converted
        	       ,sum(prior_open) prior_open,sum(leads)  leads
                  FROM
          	  ( ';
/* l_comm_cols  contains column information common to all select statement for all view by */

l_comm_cols:=    ' , sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_converted,0)) leads_converted ,
                   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_conversion_time,0)) leads_conversion_time,
     		   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.aleads_converted,0))  aleads_converted  ,
     		   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.aleads_conversion_time,0)) aleads_conversion_time,
		   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_conv_customer,0)) leads_conv_customer,
                   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_conv_prospect,0)) leads_conv_prospect,
	           sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads_converted,0))   prev_leads_converted,
		   sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.aleads_converted,0)) prev_aleads_converted,
		   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads,0))  leads,
		   0 prior_open ';
/* l_comm_cols  contains column information common to all select statement for all view by */

l_comm2_cols:=  ', 0 leads_converted,0 leads_conversion_time,0 aleads_converted,0 aleads_conversion_time,0 leads_conv_customer,0  leads_conv_prospect,
0  prev_leads_converted, 0 prev_aleads_converted,0 leads,sum(a.leads-(a.leads_closed+a.leads_dead+a.leads_converted))  prior_open ';

/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';
 /* l_where contains where clause to join time dimension table common to all select statement for all view by */
 l_where :=' WHERE a.time_id = cal.time_id  AND  a.period_type_id = cal.period_type_id AND  cal.calendar_id= -1 ';
 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */
l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
                  ')
		   )
         WHERE
           bim_attribute3 <> 0
           &ORDER_BY_CLAUSE ';

   /* get_admin_status to check current user is admin or not */

   l_admin_status := get_admin_status;

/*********************** security handling ***********************/

IF   l_campaign_id is null THEN /******* no security checking at child level ********/
	IF   l_admin_status = 'N' THEN
		IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
		/*************** program view is enable **************/
			IF l_prog_view='Y' then
				l_view := ',''RCAM''';
				l_from := l_from ||',bim_i_top_objects ac ';
				l_where := l_where ||' AND a.source_code_id=ac.source_code_id
							AND ac.resource_id = :l_resource_id ';
				/************************************************/
			ELSE

				l_from := l_from ||',ams_act_access_denorm ac,bim_i_source_codes src ';
				l_where := l_where ||' AND a.source_code_id=src.source_code_id
						       AND src.object_id=ac.object_id
						       AND src.object_type=ac.object_type
						       AND src.object_type NOT IN (''RCAM'')
						       AND ac.resource_id = :l_resource_id ';

			END IF;

		ELSE
			l_from := l_from ||',bim_i_top_objects ac ';
			l_where := l_where ||' AND a.source_code_id=ac.source_code_id
									AND ac.resource_id = :l_resource_id ';
		END IF;

	ELSE
		IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
			IF  l_prog_view='Y' THEN
				l_view := ',''RCAM''';
				l_top_cond :=' AND a.immediate_parent_id is null ';
			END IF;
		ELSE
			/******** to append parent object id is null for other view by (country and product category) ***/
			l_top_cond :=' AND a.immediate_parent_id is null ';
			/***********/
		END IF;
	END IF;
END IF;

/************************************************************************/

   /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11  AND edh.dbi_flag = ''Y''  AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;
/********************************/

IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN

	/* forming from clause for the tables which is common to all union all */

	IF l_cat_id IS NOT NULL THEN

		l_from :=' FROM bim_i_obj_mets_mv a , bim_i_obj_name_mv name '||l_from||l_pc_from;

	ELSE
		l_from :=' FROM bim_i_obj_mets_mv a , bim_i_obj_name_mv name '||l_from;

	END IF;

	/* forming where clause which is common to all union all */
	IF l_prog_view = 'Y' THEN

		l_where :=l_where||' AND a.source_code_id = name.source_code_id
							 AND name.language=USERENV(''LANG'')
							 AND a.object_country = :l_country'||
							 l_pc_where;
	ELSE
		l_where :=l_where||' AND a.source_code_id = name.source_code_id
							 AND name.language=USERENV(''LANG'')
							 AND name.object_type NOT IN (''RCAM'')
							 AND a.object_country = :l_country'||
							 l_pc_where;

	END IF;

	/* forming group by clause for the common columns for all union all */
	l_groupby:=' GROUP BY a.source_code_id,name.object_type_mean,name.name,name.object_id,name.object_type ';

	/*** campaign id null means No drill down and view by is camapign hirerachy*/
	IF l_campaign_id is null THEN
		/*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
		l_sqltext:= l_select_cal||
		/******** inner select start from here */
		/* select to get camapigns and programs  */
		' SELECT
		a.source_code_id VIEWBYID,
		name.name name,
		name.object_id object_id,
		name.object_type object_type,
		name.object_type_mean meaning '||
		l_comm_cols ||
		l_from || ' '||
		l_where ||l_top_cond||
		'AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
		AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id'||
		l_groupby||
		' UNION ALL
		SELECT
		a.source_code_id VIEWBYID,
		name.name name,
		name.object_id object_id,
		name.object_type object_type,
		name.object_type_mean meaning  '||
		l_comm2_cols ||
		l_from ||
		l_where ||l_top_cond||
		' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
		AND BITAND(cal.record_type_id,1143)= cal.record_type_id'||
		l_groupby||
		l_select_filter /* appending filter clause */
		;
	ELSE

		/* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
		/* appending table in l_form and joining conditon for the bim_i_source_codes */

		l_where :=l_where ||' AND a.immediate_parent_id = :l_campaign_id ';

		-- if program is selected from the page means it may have childern as programs,campaigns,events or one off events

		IF l_object_type IN ('RCAM','EVEH') THEN
			/*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
			l_sqltext:= l_select_cal||
			/******** inner select start from here */
			' SELECT a.source_code_id VIEWBYID
			,name.name name
			,name.object_id object_id
			,name.object_type object_type
			,name.object_type_mean meaning '||
			l_comm_cols ||
			l_from||
			l_where ||
			' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
			AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
			AND name.language=USERENV(''LANG'')'||
			l_groupby||
			'UNION ALL
			 SELECT a.source_code_id VIEWBYID
			 ,name.name name
			,name.object_id object_id
			,name.object_type object_type
			,name.object_type_mean meaning '||
			l_comm2_cols ||
			l_from ||
			l_where ||
			' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
			AND BITAND(cal.record_type_id,1143)= cal.record_type_id '||
			l_groupby||
			l_select_filter ;

			/*************** if object type is camp then childern are campaign schedules ***/
		ELSIF l_object_type='CAMP' THEN
			l_sqltext:= l_select_cal||
			/******** inner select start from here */
			/* select to get camapign schedules  */
			' SELECT
			a.source_code_id VIEWBYID
			,name.name name
			,name.object_id object_id
			,name.object_type object_type
			,name.child_object_usage usage
			,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel
			,name.object_type_mean meaning'||
			l_comm_cols ||
			l_from || ' , bim_dimv_media chnl  '||
			l_where ||
			' AND name.activity_id =chnl.id (+)
			AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
			AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id '||
			l_groupby||' , name.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||'
			UNION ALL
			SELECT
			a.source_code_id VIEWBYID
			,name.name name
			,name.object_id object_id
			,name.object_type object_type
			,name.child_object_usage usage
			,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel
			,name.object_type_mean meaning '||
			l_comm2_cols ||
			l_from || ' , bim_dimv_media chnl  '||
			l_where ||
			' AND name.activity_id =chnl.id (+)
			AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
			AND BITAND(cal.record_type_id,1143)= cal.record_type_id'||
			l_groupby||' , name.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
			l_select_filter ;
		END IF;
	END IF;
	/***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/
 ELSE
 /* view by is product category */
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN
--changing l_from to have fii_time_rpt_struct_v first table in form clause to provide ordered hint in sql
  if l_admin_status='N' then
 l_from:=replace(l_from,',fii_time_rpt_struct_v cal');
 else
 l_from:=null;
 end if;
/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag ';
    ELSE
    /* passing id from page and getting immediate child to build hirerachy  */

    /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/

     l_pc_from:= l_from||
                   ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';

    l_pc_where :=l_where||
                      ' AND a.category_id = p.id ';

    l_from:= l_from||
            ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

     l_where := l_where||'
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id ';

     l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
    END IF;
/*********************/

           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '  AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||l_top_cond||
                         ' AND  a.object_country = :l_country';
               END IF;
              ELSE
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                             '||l_from;
              l_where := l_where ||
	                   ' AND  a.object_country = :l_country';

		IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||
                         ' AND  a.object_country = :l_country';
               END IF;

              END IF;
           ELSE
              l_from := ' FROM   fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_from ;
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then
	      l_pc_from := ' FROM   fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_pc_from ;
              l_pc_where  := l_pc_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN
       	  l_pc_col:=' SELECT /*+ORDERED*/
		   bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
                   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.id';

  l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_comm_cols||
	      l_pc_from||
	      l_pc_where ||'  AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	      AND BITAND(cal.record_type_id,1143)= cal.record_type_id'||
	      l_pc_groupby||
	      ' UNION ALL ' ||
              l_pc_col||
              l_comm2_cols||
	      l_pc_from||
	      l_pc_where ||'
	      AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
              AND BITAND(cal.record_type_id,1143)= cal.record_type_id'||
	      l_pc_groupby ;
   END IF;
 ELSIF (l_view_by ='CUSTOMER CATEGORY+CUSTOMER CATEGORY') THEN
  /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		   decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name) name,
                   null viewbyid,
		   null meaning ';
    l_groupby := ' GROUP BY decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name) ';
    l_from:=' FROM bic_cust_category_v d '||l_from;

	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_ccat_mv a ';
              l_where := l_where ||
                         ' AND d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_ccat_mv a ';
              l_where := l_where ||
	                 ' AND d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country ';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_ccat_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country' ;
	  END IF;
 ELSIF (l_view_by ='BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM as_lookups d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_src_mv a ';
              l_where := l_where ||
                         ' AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_src_mv a ';
              l_where := l_where ||
	                 ' AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_src_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country ';
	  END IF;
ELSIF (l_view_by ='SALES CHANNEL+BIS_SALES_CHANNEL') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM so_lookups d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_chnl_mv a ';
              l_where := l_where ||
                         ' AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_chnl_mv a ';
              l_where := l_where ||
	                 ' AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_chnl_mv a '; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
                     a.object_country viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country ';
    l_from:=' FROM fnd_territories_tl d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||l_top_cond||
                         ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'')';
              ELSE
              l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||
	                 ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'') ';
              END IF;
            ELSE
              l_from := l_from||' ,bim_i_obj_mets_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'')';
	  END IF;
	  IF  l_country <>'N' THEN
	      l_where  := l_where ||' AND  a.object_country = :l_country';
          ELSE
	   l_where  := l_where ||' AND  a.object_country <> ''N''';
	  END IF;
ELSIF (l_view_by ='BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY') THEN
  /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM as_sales_lead_ranks_vl d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_qual_mv a ';
              l_where := l_where ||
                         ' AND d.rank_id (+)= a.lead_rank_id
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_qual_mv a ';
              l_where := l_where ||
	                 ' AND d.rank_id (+)= a.lead_rank_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_qual_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND d.rank_id (+)= a.lead_rank_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='MEDIA+MEDIA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bim_dimv_media d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_chnl_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_chnl_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_chnl_mv a '; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bis_areas_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_regn_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_regn_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_regn_mv a '; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
	  END IF;
END IF;

/* combine sql one to pick up current period values and  sql two to pick previous period values */
  l_select := l_col||
              l_comm_cols||
	      l_from||
	      l_where ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	      AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id  '||
	      l_groupby ||'UNION ALL'||l_col||
              l_comm2_cols||
	      l_from||
	      l_where ||' AND cal.report_date = &BIS_CURRENT_EFFECTIVE_START_DATE - 1
	      AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
	      l_groupby||
	      l_pc_select /* l_pc_select only applicable when product category is not all and view by is product category */
	      ;

/* prepare final sql */

 l_sqltext:= l_select_cal||
             l_select||
	     l_select_filter;
  END IF;

   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_resource_id';
   l_custom_rec.attribute_value := get_resource_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_admin_flag';
   l_custom_rec.attribute_value := get_admin_status;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (3) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_country';
   l_custom_rec.attribute_value := l_country;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (4) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_cat_id';
   l_custom_rec.attribute_value := l_cat_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (5) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_campaign_id';
   l_custom_rec.attribute_value := l_campaign_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (6) := l_custom_rec;
   write_debug ('GET_LEAD_OPTY_CONV_SQL', 'QUERY', '_', l_sqltext);
EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_LEAD_OPTY_CONV_SQL', 'ERROR', l_sql_errm, l_sqltext);
END get_lead_opty_conv_sql;

PROCEDURE GET_MKTG_A_LEADS_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(200);
   l_pc_groupby                   VARCHAR2(200);
   l_view                         VARCHAR2 (20);
   l_comm_cols                      VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(1000);
   l_url_str_csch                 varchar2(1000);
   l_url_str_csch_jtf             varchar2(3000);
   l_url_str_type                 varchar2(3000);
   l_csch_chnl                    varchar2(100);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_top_cond                       VARCHAR2(100);
   l_meaning                      VARCHAR2 (20); -- assigning default value
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                   bis_query_attributes;
   l_object_type                  varchar2(30);
   l_url_link                       varchar2(200);
   l_url_camp1                     varchar2(3000);
   l_url_camp2                     varchar2(3000);
   l_dass                         varchar2(100);  -- variable to store value for  directly assigned lookup value
 --  l_una                           varchar2(100);   -- variable to store value for  Unassigned lookup value
   l_leaf_node_flag               varchar2(25);   -- variable to store value leaf_node_flag column in case of product category
   l_curr VARCHAR2(50);
   l_curr_suffix VARCHAR2(50);
   l_col_id NUMBER;
   l_area VARCHAR2(300);
   l_report_name VARCHAR2(300);
   l_media VARCHAR2(300);
   l_jtf                           varchar2(300);

BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );


   l_meaning:=' null meaning '; -- assigning default value
   l_url_camp1:=',null';
   l_url_camp2:=',null';


   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
/** to add meaning in select clause only in case of campaign view by */
  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' ,meaning ';
  l_filtercol:=',meaning ';
  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  l_filtercol:=',leaf_node_flag ';
  l_meaning:=',null meaning ';
  else
  l_meaning:=' ,null meaning ';
  end if;

/*** to  assigned URL **/

if l_campaign_id is not null then
-- checking for the object type passed from page
 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;
end if;

   l_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
   l_url_str  :='pFunctionName=BIM_I_MKTG_A_LEADS&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
   --l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
   IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
   l_url_link :=' ,decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) ';
   l_view_disp:='viewby';
   l_leaf_node_flag :=' ,leaf_node_flag ';
   ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
     l_camp_sel_col :=' ,object_id
                       ,object_type
                       ';
     l_camp_groupby_col :=',object_id,object_type ';
     l_url_link := ' ,null ';
     l_view_disp := 'viewby';

     IF (l_campaign_id is  null or l_object_type='RCAM') then
	l_url_camp1:=', decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' )';
     ELSIF l_object_type='CAMP' THEN
 	l_url_camp2:=', '||''''||l_url_str_type||''''||'||object_id ';
 	--l_url_camp1:=',decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_csch_jtf||''''||'||object_id)';
	l_url_camp1:=', '||''''||l_url_str_csch||''''||'||object_id ';

		l_csch_chnl:='|| '' - '' || channel';
	l_camp_sel_col :=l_camp_sel_col|| ',usage,channel';
	l_camp_groupby_col :=l_camp_groupby_col||',usage,channel';
     end if;
    ELSE
      --l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
      l_url_link:=' ,null ';
      l_view_disp:='viewby';
   END IF;
/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal :='
         SELECT '||
         l_view_disp ||'
	 ,viewbyid
 	 ,bim_attribute2 '|| l_csch_chnl ||' bim_attribute2
 	 ,bim_attribute3
 	 ,bim_attribute4
 	 ,bim_attribute5
 	 ,bim_attribute6
 	 ,bim_attribute7
 	 ,bim_attribute8
	 ,bim_attribute9
	 ,bim_attribute10
	 ,bim_attribute11
	 ,bim_attribute9  bim_attribute12
	 ,bim_attribute10 bim_attribute13
	 ,bim_attribute3  bim_attribute14
 	 ,bim_attribute3  bim_attribute18
	 ,case when bim_grand_total7=0 then null
	 else
	 (bim_attribute9/bim_grand_total7)*100
	 end bim_attribute20 '||
         l_url_link||' bim_attribute19'||
	 l_url_camp1|| ' bim_attribute21 '||
	 l_url_camp2||' bim_attribute22
 	 ,bim_grand_total1
 	 ,bim_grand_total2
 	 ,bim_grand_total3
 	 ,bim_grand_total4
 	 ,bim_grand_total5
 	 ,bim_grand_total6
	 ,bim_grand_total7
	 ,bim_grand_total8
	 ,bim_grand_total9
	,case when bim_grand_total7=0 then null
	 else 100 end  bim_grand_total10
	 ,bim_grand_total1 bim_grand_total11
          FROM
	 (
            SELECT
            name    VIEWBY'||l_leaf_node_flag||'
            ,meaning BIM_ATTRIBUTE2'||l_camp_sel_col
            ||',rank_a  BIM_ATTRIBUTE3
            ,DECODE(prev_rank_a,0,NULL,((rank_a - prev_rank_a)/prev_rank_a)*100) BIM_ATTRIBUTE4
            ,rank_b BIM_ATTRIBUTE5
            ,rank_c BIM_ATTRIBUTE6
	    ,rank_d BIM_ATTRIBUTE7
            ,rank_z BIM_ATTRIBUTE8
            ,leads_new BIM_ATTRIBUTE9
            ,leads_qualified BIM_ATTRIBUTE10
            ,DECODE(prev_leads_qualified,0,NULL,((leads_qualified - prev_leads_qualified)/prev_leads_qualified)*100) BIM_ATTRIBUTE11
            ,sum(rank_a) over() BIM_GRAND_TOTAL1
	    ,decode(sum(prev_rank_a) over(),0,null,(((sum(rank_a- prev_rank_a) over())/sum(prev_rank_a)over ())*100)) BIM_GRAND_TOTAL2
	    ,sum(rank_b) over() BIM_GRAND_TOTAL3
            ,sum(rank_c) over() BIM_GRAND_TOTAL4
	    ,sum(rank_d) over() BIM_GRAND_TOTAL5
	    ,sum(rank_z) over() BIM_GRAND_TOTAL6
            ,sum(leads_new) over() BIM_GRAND_TOTAL7
	    ,sum(leads_qualified) over() BIM_GRAND_TOTAL8
   	    ,decode(sum(prev_leads_qualified) over(),0,null,(((sum(leads_qualified- prev_leads_qualified) over())/sum(prev_leads_qualified)over ())*100)) BIM_GRAND_TOTAL9
            ,VIEWBYID
             FROM
              (
                  SELECT
          	      viewbyid,
          	      name'||l_leaf_node_flag||
		      l_meaning||l_camp_sel_col||
		    ',sum(rank_a)                    rank_a
          	      ,sum(rank_b)                    rank_b
          	      ,sum(rank_c)                    rank_c
          	      ,sum(rank_d)                    rank_d
          	      ,sum(rank_z)                    rank_z
          	      ,sum(leads_new)                 leads_new
     		      ,sum(leads_qualified)           leads_qualified
		      ,sum(prev_rank_a)               prev_rank_a
     		      ,sum(prev_leads_qualified)      prev_leads_qualified
                  FROM
          	  ( ';
/* l_comm_cols contains column information common to all select statement for all view by */

l_comm_cols:=    ' , sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_a,0))   rank_a ,
                   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_b,0))   rank_b,
     		   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_c,0))   rank_c,
     		   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_d,0))   rank_d,
     		   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.rank_z,0))   rank_z,
		   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_new,0)) leads_new,
     		   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_qualified,0))  leads_qualified,
   	           sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.rank_a,0)) prev_rank_a ,
     		   sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads_qualified,0)) prev_leads_qualified';
/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';
 /* l_where contains where clause to join time dimension table common to all select statement for all view by */
 l_where :=' WHERE a.time_id = cal.time_id
             AND  a.period_type_id = cal.period_type_id
             AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
             AND  cal.calendar_id= -1 ';
 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */
l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
                  ')
		   )
         WHERE
           bim_attribute9 <> 0
	  &ORDER_BY_CLAUSE ';
  /* get_admin_status to check current user is admin or not */

   l_admin_status := get_admin_status;

/*********************** security handling ***********************/

IF   l_campaign_id is null THEN /******* no security checking at child level ********/
	IF   l_admin_status = 'N' THEN
		IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
			/*************** program view is enable **************/
			IF l_prog_view='Y' then
				l_view := ',''RCAM''';
				l_from := l_from ||',bim_i_top_objects ac ';
				l_where := l_where ||' AND a.source_code_id=ac.source_code_id
				 AND ac.resource_id = :l_resource_id ';
			/************************************************/
			ELSE
				l_from := l_from ||',ams_act_access_denorm ac , bim_i_source_codes src ';
			    l_where := l_where ||' AND a.source_code_id=src.source_code_id
				 AND src.object_id=ac.object_id
				 AND src.object_type=ac.object_type
				 AND src.object_type NOT IN (''RCAM'')
			     AND ac.resource_id = :l_resource_id ';
			END IF;

		ELSE

			l_from := l_from ||',bim_i_top_objects ac ';
            l_where := l_where ||' AND a.source_code_id=ac.source_code_id
		    AND ac.resource_id = :l_resource_id ';

		END IF;

	ELSE
		IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
			IF  l_prog_view='Y' THEN
				l_view := ',''RCAM''';
				l_top_cond :=' AND a.immediate_parent_id is null ';
			END IF;
		ELSE
			/******** to append parent object id is null for other view by (country and product category) ***/
			l_top_cond :=' AND a.immediate_parent_id is null ';
			/***********/
		END IF;
	END IF;
END IF;
/************************************************************************/

   /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;
/********************************/

IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN

     /* forming from clause for the tables which is common to all union all */
     IF l_cat_id IS NOT NULL THEN

		l_from :=' FROM bim_i_obj_mets_mv a ,bim_i_obj_name_mv name '||l_from||l_pc_from;

     ELSE

		l_from :=' FROM bim_i_obj_mets_mv a, bim_i_obj_name_mv name '||l_from;

     END IF;

     /* forming where clause which is common to all union all */

	IF l_prog_view = 'Y' THEN
		l_where :=l_where||' AND a.source_code_id = name.source_code_id
						  AND name.language = USERENV(''LANG'')
						  AND a.object_country = :l_country '||
						  l_pc_where;
	ELSE
		l_where :=l_where||' AND a.source_code_id = name.source_code_id
						  AND name.language = USERENV(''LANG'')
 						  AND name.object_type NOT IN (''RCAM'')
						  AND a.object_country = :l_country '||
						  l_pc_where;
	END IF;


	/* forming group by clause for the common columns for all union all */
	l_groupby:=' GROUP BY a.source_code_id,name.object_type_mean,name.name,name.object_id,name.object_type ';

	/*** campaign id null means No drill down and view by is camapign hirerachy*/
	IF l_campaign_id is null THEN
		/*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
		l_sqltext:= l_select_cal||
		/******** inner select start from here */
		/* select to get camapigns and programs  */
		' SELECT
		a.source_code_id VIEWBYID,
		name.name name,
		name.object_id object_id,
		name.object_type object_type,
		name.object_type_mean meaning '||
		l_comm_cols ||
		l_from ||
		l_where ||l_top_cond||
		' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'||
		l_groupby||
		l_select_filter;
	ELSE
		/* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
		/* appending table in l_form and joining conditon for the bim_i_source_codes */

		l_where :=l_where ||' AND a.immediate_parent_id = :l_campaign_id ';

		-- if program is selected from the page means it may have childern as programs,campaigns,events or one off events

		IF l_object_type in ('RCAM','EVEH') THEN
			/*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
			l_sqltext:= l_select_cal||
			/******** inner select start from here */
			/* select to get camapigns and programs  */
			' SELECT
			a.source_code_id VIEWBYID,
			name.name name,
			name.object_id object_id,
			name.object_type object_type,
			name.object_type_mean meaning '||
			l_comm_cols ||
			l_from ||
			l_where ||
			' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'||
			l_groupby||
			l_select_filter;

		ELSIF l_object_type='CAMP' THEN

			l_sqltext:= l_select_cal||
			/******** inner select start from here */
			/* select to get camapign schedules  */
			' SELECT
			a.source_code_id VIEWBYID,
			name.name name,
			name.object_id object_id,
			name.object_type object_type,
			name.child_object_usage usage,
			decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel
			,name.object_type_mean meaning '||
			l_comm_cols ||
			l_from || ' , bim_dimv_media chnl '||
			l_where ||
			' AND name.activity_id =chnl.id (+)
			AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'||
			l_groupby||
			' , name.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
			l_select_filter ;
		END IF;
	END IF;

 /***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/

 ELSE
 /* view by is product category */
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN
 -- changed to make fii_time_rpt_struct_v cal as first table in from CLAUSE to provide ORDERED HINT
 if l_admin_status='N' then
 l_from:=replace(l_from,',fii_time_rpt_struct_v cal');
 else
 l_from:=null;
 end if;
/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag ';
    ELSE
    /* passing id from page and getting immediate child to build hirerachy  */

    /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/

     l_pc_from:= l_from||
                   ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';

    l_pc_where :=l_where||
                      ' AND a.category_id = p.id ';

    l_from:= l_from||
            ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

     l_where := l_where||'
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id ';

     l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
    END IF;
/*********************/

           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '  AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||l_top_cond||
                         ' AND  a.object_country = :l_country';
               END IF;
              ELSE
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                             '||l_from;
              l_where := l_where ||
	                   ' AND  a.object_country = :l_country';

		IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||
                         ' AND  a.object_country = :l_country';
               END IF;

              END IF;
           ELSE
              l_from := ' FROM   fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_from ;
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then
	      l_pc_from := ' FROM   fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_pc_from ;
              l_pc_where  := l_pc_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN
       	  l_pc_col:=' SELECT /*+ORDERED*/
		   bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
                   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.id ';

  l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_comm_cols||
	      l_pc_from||
	      l_pc_where ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'||
	      l_pc_groupby ;
   END IF;
 ELSIF (l_view_by ='CUSTOMER CATEGORY+CUSTOMER CATEGORY') THEN
  /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		   decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name) name,
                   null viewbyid,
		   null meaning ';
    l_groupby := ' GROUP BY decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name) ';
    l_from:=' FROM bic_cust_category_v d '||l_from;

	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_ccat_mv a ';
              l_where := l_where ||
                         ' AND d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_ccat_mv a ';
              l_where := l_where ||
	                 ' AND d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country ';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_ccat_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country' ;
	  END IF;
 ELSIF (l_view_by ='BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM as_lookups d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_src_mv a ';
              l_where := l_where ||
                         ' AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_src_mv a ';
              l_where := l_where ||
	                 ' AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_src_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country ';
	  END IF;
ELSIF (l_view_by ='SALES CHANNEL+BIS_SALES_CHANNEL') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM so_lookups d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_chnl_mv a ';
              l_where := l_where ||
                         ' AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_chnl_mv a ';
              l_where := l_where ||
	                 ' AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_chnl_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
                     a.object_country viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country ';
    l_from:=' FROM fnd_territories_tl d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||l_top_cond||
                         ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'')';
              ELSE
              l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||
	                 ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'') ';
              END IF;
            ELSE
              l_from := l_from||' ,bim_i_obj_mets_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'') ';
	  END IF;
	  IF  l_country <>'N' THEN
	      l_where  := l_where ||' AND  a.object_country = :l_country';
          ELSE
	   l_where  := l_where ||' AND  a.object_country <> ''N''';
	  END IF;
ELSIF (l_view_by ='BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY') THEN
  /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM as_sales_lead_ranks_vl d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_qual_mv a ';
              l_where := l_where ||
                         ' AND d.rank_id (+)= a.lead_rank_id
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_qual_mv a ';
              l_where := l_where ||
	                 ' AND d.rank_id (+)= a.lead_rank_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_qual_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND d.rank_id (+)= a.lead_rank_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='MEDIA+MEDIA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bim_dimv_media d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_chnl_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_chnl_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_chnl_mv a '; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bis_areas_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_regn_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_regn_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_regn_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
	  END IF;
END IF;

/* combine sql one to pick up current period values and  sql two to pick previous period values */
  l_select := l_col||
              l_comm_cols||
	      l_from||
	      l_where ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	      l_groupby ||
	      l_pc_select /* l_pc_select only applicable when product category is not all and view by is product category */
	      ;

/* prepare final sql */

 l_sqltext:= l_select_cal||
             l_select||
	     l_select_filter;
  END IF;

   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_resource_id';
   l_custom_rec.attribute_value := get_resource_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_admin_flag';
   l_custom_rec.attribute_value := get_admin_status;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (3) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_country';
   l_custom_rec.attribute_value := l_country;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (4) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_cat_id';
   l_custom_rec.attribute_value := l_cat_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (5) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_campaign_id';
   l_custom_rec.attribute_value := l_campaign_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (6) := l_custom_rec;
   write_debug ('GET_', 'QUERY', '_', l_sqltext);
EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_MKTG_A_LEADS_SQL', 'ERROR', l_sql_errm, l_sqltext);
END GET_MKTG_A_LEADS_SQL;

PROCEDURE GET_MKTG_NEW_LEADS_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(200);
   l_pc_groupby                   VARCHAR2(200);
   l_comm_cols                    VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(1000);
   l_url_str_csch                 varchar2(1000);
   l_url_str_type                 varchar2(3000);
   l_url_str_csch_jtf             varchar2(3000);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_csch_chnl                    varchar2(100);
   l_top_cond                     VARCHAR2(100);
   l_meaning                      VARCHAR2 (20);
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                  bis_query_attributes;
   l_object_type                 varchar2(30);
   l_url_link                    varchar2(200);
   l_url_camp1                   varchar2(3000);
   l_url_camp2                   varchar2(3000);
   l_dass                        varchar2(100);  -- variable to store value for  directly assigned lookup value
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
--   l_una                        varchar2(100);   -- variable to store value for  Unassigned lookup value
   l_leaf_node_flag               varchar2(25);   -- variable to store value leaf_node_flag column in case of product category
   l_col_id NUMBER;
   l_area VARCHAR2(300);
   l_report_name VARCHAR2(300);
   l_media VARCHAR2(300);
   l_jtf                           varchar2(300);
BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
   l_meaning:=' null meaning '; -- assigning default value
   l_url_camp1:=',null';
   l_url_camp2:=',null';

   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
/** to add meaning in select clause only in case of campaign view by */
  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' ,meaning ';
  l_filtercol:=',meaning ';
  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  l_filtercol:=',leaf_node_flag ';
  l_meaning:=',null meaning ';
  else
  l_meaning:=' ,null meaning ';
  end if;
  /*** to  assigned URL **/

if l_campaign_id is not null then
-- checking for the object type passed from page
 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;
end if;
   l_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
   l_url_str  :='pFunctionName=BIM_I_MKTG_NEW_LEADS&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
   --l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

   IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
      l_url_link :=' ,decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) ';
      l_view_disp:='viewby';
      l_leaf_node_flag :=' ,leaf_node_flag ';
   ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
     l_camp_sel_col :=' ,object_id
                       ,object_type
                       ';
     l_camp_groupby_col :=',object_id,object_type ';
     l_url_link := ' ,null ';
     l_view_disp := 'viewby';

     IF (l_campaign_id is  null or l_object_type='RCAM') then
	l_url_camp1:=', decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' )';
     ELSIF l_object_type='CAMP' THEN
	l_url_camp2:=', '||''''||l_url_str_type||''''||'||object_id ';
	--l_url_camp1:=',decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_csch_jtf||''''||'||object_id)';
	l_url_camp1:=', '||''''||l_url_str_csch||''''||'||object_id ';
	l_csch_chnl:='|| '' - '' || channel';
	l_camp_sel_col :=l_camp_sel_col|| ',usage,channel';
	l_camp_groupby_col :=l_camp_groupby_col||',usage,channel';
     end if;
    ELSE
      l_url_link:=' ,null ';
      l_view_disp:='viewby';
   END IF;

/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal :='
         SELECT '||
         l_view_disp ||'
	 ,viewbyid
 	 ,bim_attribute2 '||l_csch_chnl||' bim_attribute2
 	 ,bim_attribute3
 	 ,bim_attribute4
 	 ,bim_attribute5
 	 ,bim_attribute6
	 ,bim_attribute7
 	 ,bim_attribute8
         ,bim_attribute6 bim_attribute9
	 ,bim_attribute8 bim_attribute10
         ,bim_attribute5 bim_attribute11
         ,bim_attribute7 bim_attribute12 '||
	 l_url_link || ' bim_attribute19'||
	 l_url_camp1|| ' bim_attribute20 '||
	 l_url_camp2||' bim_attribute21
 	 ,bim_grand_total1
 	 ,bim_grand_total2
 	 ,bim_grand_total3
 	 ,bim_grand_total4
 	 ,bim_grand_total5
 	 ,bim_grand_total6
	 ,bim_grand_total3 bim_grand_total7
         ,bim_grand_total5 bim_grand_total8
          FROM
	 (
            SELECT
            name     VIEWBY'||l_leaf_node_flag||'
            ,meaning BIM_ATTRIBUTE2'||l_camp_sel_col||
           ' ,leads_new  BIM_ATTRIBUTE3
            ,DECODE(prev_leads_new,0,NULL,((leads_new - prev_leads_new)/prev_leads_new)*100) BIM_ATTRIBUTE4
            ,leads_customer BIM_ATTRIBUTE5
            ,DECODE(prev_leads_customer,0,NULL,((leads_customer - prev_leads_customer)/prev_leads_customer)*100) BIM_ATTRIBUTE6
	    ,leads_prospect BIM_ATTRIBUTE7
            ,DECODE(prev_leads_prospect,0,NULL,((leads_prospect - prev_leads_prospect)/prev_leads_prospect)*100)  BIM_ATTRIBUTE8
            ,sum(leads_new) over() BIM_GRAND_TOTAL1
	    ,decode(sum(prev_leads_new) over(),0,null,(((sum(leads_new- prev_leads_new) over())/sum(prev_leads_new)over ())*100)) BIM_GRAND_TOTAL2
	    ,sum(leads_customer) over() BIM_GRAND_TOTAL3
   	    ,decode(sum(prev_leads_customer) over(),0,null,(((sum(leads_customer- prev_leads_customer) over())/sum(prev_leads_customer)over ())*100)) BIM_GRAND_TOTAL4
            ,sum(leads_prospect) over() BIM_GRAND_TOTAL5
   	    ,decode(sum(prev_leads_prospect) over(),0,null,(((sum(leads_prospect- prev_leads_prospect) over())/sum(prev_leads_prospect)over ())*100)) BIM_GRAND_TOTAL6
            ,VIEWBYID
             FROM
              (
                  SELECT
          	      viewbyid
          	      ,name'||l_leaf_node_flag||
		      l_meaning||l_camp_sel_col||
		    ', sum(leads_new)        leads_new
                       ,sum(leads_customer)   leads_customer
     		       ,sum(leads_prospect)   leads_prospect
     		       ,sum(prev_leads_new)        prev_leads_new
     		       ,sum(prev_leads_customer)  prev_leads_customer
		       ,sum(prev_leads_prospect)   prev_leads_prospect
                  FROM
          	  ( ';
/* l_comm_cols contains column information common to all select statement for all view by */

l_comm_cols:=    ' , sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_new,0)) leads_new ,
                   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_customer,0))   leads_customer,
     		   sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.leads_prospect,0))   leads_prospect,
     		   sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads_new,0))   prev_leads_new,
     		   sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads_customer,0)) prev_leads_customer,
		   sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.leads_prospect,0)) prev_leads_prospect ';


/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';
 /* l_where contains where clause to join time dimension table common to all select statement for all view by */
 l_where :=' WHERE a.time_id = cal.time_id
             AND  a.period_type_id = cal.period_type_id
             AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
             AND  cal.calendar_id= -1 ';
 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */
l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
                  ')
		   )
         WHERE
           bim_attribute3    <> 0
          &ORDER_BY_CLAUSE ';
 /* get_admin_status to check current user is admin or not */

  l_admin_status := get_admin_status;

/*********************** security handling ***********************/

	IF   l_campaign_id is null THEN /******* no security checking at child level ********/
		IF   l_admin_status = 'N' THEN
			IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
			/*************** program view is enable **************/
				IF l_prog_view='Y' then
					l_from := l_from ||',bim_i_top_objects ac ' ;
					l_where := l_where ||' AND a.source_code_id=ac.source_code_id
					AND ac.resource_id = :l_resource_id ';
					/************************************************/
				ELSE
					l_from := l_from ||',ams_act_access_denorm ac,bim_i_source_codes src ';
					l_where := l_where ||' AND a.source_code_id=src.source_code_id
					AND src.object_id=ac.object_id
					AND src.object_type=ac.object_type
					AND src.object_type NOT IN (''RCAM'')
					AND ac.resource_id = :l_resource_id ';
					END IF;
			ELSE
				l_from := l_from ||',bim_i_top_objects ac ';
				l_where := l_where ||' AND a.source_code_id=ac.source_code_id
				AND ac.resource_id = :l_resource_id ';
			END IF;

		ELSE
			--i.e Admin User
			IF l_view_by = 'CAMPAIGN+CAMPAIGN' then

				IF  l_prog_view = 'Y' THEN

					l_top_cond :=' AND a.immediate_parent_id is null ';

				END IF;

			ELSE
				/******** to append parent object id is null for other view by (country and product category) ***/
				l_top_cond :=' AND a.immediate_parent_id is null ';
				/***********/
			END IF;
		END IF;
	END IF;
/************************************************************************/


   /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;
/********************************/

IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN

	/* forming from clause for the tables which is common to all union all */
	if l_cat_id is not null then
	l_from :=' FROM bim_i_obj_mets_mv a '||l_from||l_pc_from;
	else
	l_from :=' FROM bim_i_obj_mets_mv a '||l_from;
	end if;


	/* forming where clause which is common to all union all */
	IF l_prog_view = 'Y' then

		l_where :=l_where||' AND a.object_country = :l_country '||
							l_pc_where;

	ELSE

		l_where :=l_where||' AND a.object_country = :l_country AND name.object_type NOT IN (''RCAM'') '||
						   l_pc_where;

	END IF;


	/* forming group by clause for the common columns for all union all */
	l_groupby:=' GROUP BY a.source_code_id,name.object_type_mean, ';

	/*** campaign id null means No drill down and view by is camapign hirerachy*/

	IF l_campaign_id is null THEN
		/*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
		l_sqltext:= l_select_cal||
		/******** inner select start from here */
		/* select to get camapigns and programs  */
		' SELECT
		a.source_code_id VIEWBYID,
		name.name name,
		name.object_id    object_id,
		name.object_type  object_type,
		name.object_type_mean meaning '||
		l_comm_cols ||
		l_from || ' ,bim_i_obj_name_mv name '||
		l_where ||l_top_cond||
		' AND a.source_code_id=name.source_code_id
		AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
		AND name.language=USERENV(''LANG'')'||
		l_groupby|| ' name.name,name.object_id,name.object_type '||
		l_select_filter /* appending filter clause */
		;
	ELSE
		/* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
		/* appending table in l_form and joining conditon for the bim_i_source_codes */

		l_where :=l_where ||' AND  a.immediate_parent_id = :l_campaign_id ';

		-- if program is selected from the page means it may have childern as programs,campaigns,events or one off events

		IF l_object_type in ('RCAM','EVEH') THEN
			/*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
			l_sqltext:= l_select_cal||
			/******** inner select start from here */
			' SELECT
			a.source_code_id VIEWBYID,
			name.name name,
			name.object_id object_id,
			name.object_type object_type,
			name.object_type_mean meaning '||
			l_comm_cols ||
			l_from || ' ,bim_i_obj_name_mv name '||
			l_where ||
			' AND name.source_code_id = a.source_code_id
			AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
			AND name.language=USERENV(''LANG'')'||
			l_groupby||
			' name.name,name.object_id,name.object_type'||
			l_select_filter ;
		   /*************** if object type is camp then childern are campaign schedules ***/

		ELSIF l_object_type='CAMP' THEN

			l_sqltext:= l_select_cal||
			/******** inner select start from here */
			/* select to get camapign schedules  */
			' SELECT
			a.source_code_id VIEWBYID,
			name.name name,
			name.object_id object_id,
			name.object_type object_type,
			name.child_object_usage usage,
			decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,
			name.object_type_mean meaning '||
			l_comm_cols ||
			l_from || ' ,bim_i_obj_name_mv name,bim_dimv_media chnl '||
			l_where ||
			' AND name.source_code_id = a.source_code_id
			and name.activity_id =chnl.id (+)
			AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
			AND name.language=USERENV(''LANG'')'||
			l_groupby||
			' name.name,name.object_id,name.object_type,name.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
			l_select_filter ;
		END IF;

	END IF;

	/***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/

ELSE
 /* view by is product category */
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN
  if l_admin_status='N' then
 l_from:=replace(l_from,',fii_time_rpt_struct_v cal');
 else
 l_from:=null;
 end if;
/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag  ';
    ELSE
    /* passing id from page and getting immediate child to build hirerachy  */

    /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/

     l_pc_from:= l_from||
                   ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';

    l_pc_where :=l_where||
                      ' AND a.category_id = p.id ';

    l_from:= l_from||
            ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

     l_where := l_where||'
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id ';

     l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
    END IF;
/*********************/

           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '  AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||l_top_cond||
                         ' AND  a.object_country = :l_country';
               END IF;
              ELSE
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                             '||l_from;
              l_where := l_where ||
	                   ' AND  a.object_country = :l_country';

		IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||
                         ' AND  a.object_country = :l_country';
               END IF;

              END IF;
           ELSE
              l_from := ' FROM   fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_from ;
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then
	      l_pc_from := ' FROM   fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_pc_from ;
              l_pc_where  := l_pc_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN
       	  l_pc_col:=' SELECT /*+ORDERED*/
		   bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
                   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.id ';

  l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_comm_cols||
	      l_pc_from||
	      l_pc_where ||'  AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'||
	      l_pc_groupby ;
   END IF;
 ELSIF (l_view_by ='CUSTOMER CATEGORY+CUSTOMER CATEGORY') THEN
  /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		   decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name) name,
                   null viewbyid,
		   null meaning ';
    l_groupby := ' GROUP BY decode(d.customer_category_name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.customer_category_name) ';
    l_from:=' FROM bic_cust_category_v d '||l_from;

	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_ccat_mv a ';
              l_where := l_where ||
                         ' AND d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_ccat_mv a ';
              l_where := l_where ||
	                 ' AND d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country ';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_ccat_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.customer_category_code (+) = a.cust_category
			   AND  a.object_country = :l_country' ;
	  END IF;
 ELSIF (l_view_by ='BIM_LEAD_ATTRIBUTES+BIM_LEAD_SOURCE') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM as_lookups d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_src_mv a ';
              l_where := l_where ||
                         ' AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_src_mv a ';
              l_where := l_where ||
	                 ' AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_src_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  a.lead_source = d.lookup_code(+)
	                   AND  d.lookup_type (+) = ''SOURCE_SYSTEM''
			   AND  a.object_country = :l_country ';
	  END IF;
ELSIF (l_view_by ='SALES CHANNEL+BIS_SALES_CHANNEL') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM so_lookups d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_chnl_mv a ';
              l_where := l_where ||
                         ' AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_chnl_mv a ';
              l_where := l_where ||
	                 ' AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_chnl_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND a.channel_code = d.lookup_code(+)
			   AND d.lookup_type (+) = ''SALES_CHANNEL''
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
                     a.object_country viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country ';
    l_from:=' FROM fnd_territories_tl d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||l_top_cond||
                         ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'')';
              ELSE
              l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||
	                 ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'') ';
              END IF;
            ELSE
              l_from := l_from||' ,bim_i_obj_mets_mv a ';  --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'') ';
	  END IF;
	  IF  l_country <>'N' THEN
	      l_where  := l_where ||' AND  a.object_country = :l_country';
          ELSE
	   l_where  := l_where ||' AND  a.object_country <> ''N''';
	  END IF;
ELSIF (l_view_by ='BIM_LEAD_ATTRIBUTES+BIM_LEAD_QUALITY') THEN
  /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.meaning,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.meaning) ';
    l_from:=' FROM as_sales_lead_ranks_vl d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_ld_qual_mv a ';
              l_where := l_where ||
                         ' AND d.rank_id (+)= a.lead_rank_id
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_ld_qual_mv a ';
              l_where := l_where ||
	                 ' AND d.rank_id (+)= a.lead_rank_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_ld_qual_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND d.rank_id (+)= a.lead_rank_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='MEDIA+MEDIA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bim_dimv_media d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_chnl_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_chnl_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_chnl_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bis_areas_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_regn_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_regn_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_regn_mv a '  ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
            END IF;
END IF;

/* combine sql one to pick up current period values and  sql two to pick previous period values */
  l_select := l_col||
              l_comm_cols||
	      l_from||
	      l_where ||'  AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	      l_groupby ||
	      l_pc_select /* l_pc_select only applicable when product category is not all and view by is product category */
	      ;

/* prepare final sql */

 l_sqltext:= l_select_cal||
             l_select||
	     l_select_filter;
  END IF;

   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_resource_id';
   l_custom_rec.attribute_value := get_resource_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_admin_flag';
   l_custom_rec.attribute_value := get_admin_status;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (3) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_country';
   l_custom_rec.attribute_value := l_country;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (4) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_cat_id';
   l_custom_rec.attribute_value := l_cat_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (5) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_campaign_id';
   l_custom_rec.attribute_value := l_campaign_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (6) := l_custom_rec;
   write_debug ('GET_MKTG_NEW_LEADS_SQL', 'QUERY', '_', l_sqltext);
EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_MKTG_NEW_LEADS_SQL', 'ERROR', l_sql_errm, l_sqltext);
END GET_MKTG_NEW_LEADS_SQL;



PROCEDURE GET_CAMP_START_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(15000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_dass                 varchar2(100);  -- variable to store value for  directly assigned lookup value
l_una                  varchar2(100);   -- variable to store value for  Unassigned lookup value
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
  /* IF l_country IS NULL THEN
      l_country := 'N';
   END IF;*/
   l_admin_status := GET_ADMIN_STATUS;
   /*IF l_admin_flag = 'N' THEN
      l_access_table := ',bim_i_top_objects ac ';
      l_access_clause := 'AND a.object_type = ac.object_type '||
         'AND a.source_code_id = ac.source_code AND ac.resource_id = '||GET_RESOURCE_ID;
   ELSE
      l_access_table := '';
      l_access_clause := '';
   END IF;*/
l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
IF l_admin_status = 'Y' THEN
if (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
IF l_cat_id is null then
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CAMP_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id leaf_node_id,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id ';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
 UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
     (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
    AND b.object_type = ''CATEGORY_SET''
    AND b.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND b.dbi_flag = ''Y''
    AND p.parent_id = b.parent_id ';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
) group by name,id,leaf_node_id )';
ELSE
-- for product category not equal to all
-- current bookmark
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CAMP_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL4

FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id leaf_node_id,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.parent_id = p.id
AND b.dbi_flag = ''Y''';
l_sqltext := l_sqltext ||' group by p.value,decode(p.leaf_node_flag,''Y'',-1,b.parent_id),b.parent_id';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
    (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,a.category_id
UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'') ) p
WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag =''Y''
AND b.parent_id = p.id ';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,decode(p.leaf_node_flag,''Y'',-1,b.parent_id),b.parent_id
UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
    (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id
';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
--l_sqltext := l_sqltext ||' group by p.value,a.category_id
l_sqltext := l_sqltext ||' group by p.value,a.category_id
 UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
     (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND b.parent_id = p.id ';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,decode(p.leaf_node_flag,''Y'',-1,b.parent_id),b.parent_id
UNION ALL
SELECT
p.value name,
a.category_id,
-1 leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE > &BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id
 group by p.value,a.category_id) group by name,id,leaf_node_id )';
END IF; -- end product category numm loop
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=VIEWBY'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=VIEWBY'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=VIEWBY'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUM(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country=:l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ,a.object_region ';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 l_sqltext := l_sqltext ||'group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
 l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE > &BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_region =d.id (+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region ) group by name,id )';
ELSE
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUM(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+) ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
/*l_sqltext := l_sqltext ||
' group by object_country*/
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE > &BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id)';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id,leaf_node_id)';
 END IF;
END IF;
ELSE -- if admin_flag is not equal to Y
if (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
IF l_cat_id is null THEN
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CAMP_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id leaf_node_id,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
 l_sqltext := l_sqltext ||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id
AND ac.resource_id = :l_resource_id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext := l_sqltext||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND ac.resource_id = :l_resource_id
AND p.parent_id = b.parent_id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type = ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id
';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
 UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM
     bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext := l_sqltext||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
    AND b.object_type = ''CATEGORY_SET''
    AND b.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND b.dbi_flag = ''Y''
    AND p.parent_id = b.parent_id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type ';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
) group by name,id,leaf_node_id )';
ELSE -- product category is not null
l_sqltext :=
'SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CAMP_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value,e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.immediate_parent_id is null
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.parent_id = p.id
AND ac.resource_id = :l_resource_id
AND b.dbi_flag = ''Y''';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,a.category_id
UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value,e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'') ) p
WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.immediate_parent_id is null
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag =''Y''
AND ac.resource_id = :l_resource_id
AND b.parent_id = p.id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id
';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,a.category_id
 UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext :=l_sqltext||' ,(select e.id id ,e.value value,e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.immediate_parent_id is null
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND ac.resource_id = :l_resource_id
AND b.parent_id = p.id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext := l_sqltext ||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.immediate_parent_id is null
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
 l_sqltext:=l_sqltext||' group by p.value,a.category_id
 ) group by name,id,leaf_node_id )';
END IF; -- end product category numm loop
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=VIEWBY'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=VIEWBY'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=VIEWBY'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d, bim_i_source_codes s ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND a.immediate_parent_id is null';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;

 l_sqltext := l_sqltext ||'group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
 l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d , bim_i_source_codes s';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND a.immediate_parent_id is null';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
 l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d, bim_i_source_codes s ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND a.immediate_parent_id is null';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
l_sqltext := l_sqltext||' AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region ) group by name,id )';
ELSE -- view by country
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_CAMP_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_CAMP_START_END&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_CAMP_START_ACT&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=campaign&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
sum(camp_started-camp_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d, bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND a.immediate_parent_id is null';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+) ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
/*l_sqltext := l_sqltext ||
--' AND a.object_country = :l_country
'group by object_country*/
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
sum(camp_started-camp_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d , bim_i_source_codes s ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND a.immediate_parent_id is null';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_started-camp_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_started-camp_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE > &BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d ,bim_i_source_codes s ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND a.immediate_parent_id is null
';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP'' AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||'
AND a.source_code_id = ac.source_code_id
';
END IF;
l_sqltext := l_sqltext||' AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
END IF; -- product category All loop
 END IF; --end view by product category

END IF; -- end if admin_flag = Y loop





  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


write_debug('GET_CAMP_START_SQL','QUERY','_',l_sqltext);

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_CAMP_START_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_CAMP_START_SQL;


PROCEDURE GET_EVEH_START_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(15000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_dass                 varchar2(100);  -- variable to store value for  directly assigned lookup value
l_una                   varchar2(100);   -- variable to store value for  Unassigned lookup value
 l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_media VARCHAR2(300);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
  /* IF l_country IS NULL THEN
      l_country := 'N';
   END IF;*/
   l_admin_status := GET_ADMIN_STATUS;
IF l_admin_status = 'Y' THEN
if (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
IF l_cat_id is null THEN
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_EVEH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id leaf_node_id,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id ';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
 UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended

FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
     (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
    AND b.object_type = ''CATEGORY_SET''
    AND b.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND b.dbi_flag = ''Y''
    AND p.parent_id = b.parent_id ';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
) group by name,id,leaf_node_id )';
ELSE
-- for product category not equal to all
-- current bookmark2
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_EVEH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id leaf_node_id,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.parent_id = p.id
AND b.dbi_flag = ''Y''';
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
    (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,a.category_id
UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'') ) p
WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag =''Y''
AND b.parent_id = p.id ';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
    (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id
';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,a.category_id
 UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
     (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND b.parent_id = p.id ';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id
 group by p.value,a.category_id) group by name,id,leaf_node_id )';
END IF; -- end product category numm loop
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN --view by area
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=VIEWBY'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=VIEWBY'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=VIEWBY'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
  l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';

l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND  a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
 l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_region =d.id (+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;

  l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region ) group by name,id )';

 ELSE --view by country
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+) ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
/*l_sqltext := l_sqltext ||
'group by object_country*/
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+) ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 END IF; -- end product category numm loop
 END IF; --end view by product category
ELSE -- if admin_flag is not equal to Y
if (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
IF l_cat_id is null THEN
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_EVEH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id leaf_node_id,
nvl(sum(curr_prior_active),0)  BIM_ATTRIBUTE2,
sum(curr_started)  BIM_ATTRIBUTE3,
SUM(prev_started)  BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended)   BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
 l_sqltext := l_sqltext ||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac, bim_i_source_codes s ';
END IF;
l_sqltext := l_sqltext||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
 UNION ALL
SELECT
p.value name,
p.parent_id id,
p.parent_id leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac , bim_i_source_codes s ';
END IF;
l_sqltext := l_sqltext||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
    AND b.object_type = ''CATEGORY_SET''
    AND b.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND b.dbi_flag = ''Y''
    AND p.parent_id = b.parent_id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
) group by name,id,leaf_node_id )';
ELSE -- product category is not null
l_sqltext :=
'SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
decode(leaf_node_id,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_EVEH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
leaf_node_id leaf_node_id,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac ,bim_i_source_codes s ';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value,e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.parent_id = p.id
AND b.dbi_flag = ''Y''';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bim_i_source_codes s ';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
l_sqltext := l_sqltext ||' group by p.value,a.category_id
UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bim_i_source_codes s ';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value,e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'') ) p
WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag =''Y''
AND b.parent_id = p.id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bim_i_source_codes s ';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id
';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
l_sqltext := l_sqltext ||' group by p.value,a.category_id
 UNION ALL
SELECT
p.value name,
b.parent_id id,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bim_i_source_codes s ';
END IF;
l_sqltext :=l_sqltext||' ,(select e.id id ,e.value value,e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND ac.resource_id = :l_resource_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND b.parent_id = p.id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
l_sqltext := l_sqltext ||' group by p.value,b.parent_id,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
a.category_id id,
-1 leaf_node_id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bim_i_source_codes s ';
END IF;
l_sqltext := l_sqltext ||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
 l_sqltext:=l_sqltext||' group by p.value,a.category_id
 ) group by name,id,leaf_node_id )';
 END IF; -- product category All loop
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=VIEWBY'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=VIEWBY'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY+AREA&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=VIEWBY'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started)  BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_areas_v d  ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d,bim_i_source_codes s ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
 l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d,bim_i_source_codes s ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac ,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d,bim_i_source_codes s ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext||' AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region ) group by name,id )';

ELSE --view by country
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE3 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3,0,NULL,''pFunctionName=BIM_I_EVEH_START_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=1&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL2,
decode(BIM_ATTRIBUTE5,0,NULL,''pFunctionName=BIM_I_EVEH_END_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=2&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL3,
decode(BIM_ATTRIBUTE7,0,NULL,''pFunctionName=BIM_I_EVEH_ACT_DETL&pParamIds=Y&VIEW_BY=GEOGRAPHY_COUNTRY&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER1=3&BIM_PARAMETER2=event&BIM_PARAMETER5=All'') BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0)  BIM_ATTRIBUTE2,
sum(curr_started)  BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
sum(even_started-even_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d,bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+) ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
/*l_sqltext := l_sqltext ||
--' AND a.object_country = :l_country
'group by object_country*/
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
sum(even_started-even_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac, bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d,bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id  ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (even_started-even_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (even_started-even_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  even_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then even_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then even_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then even_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then even_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d,bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND a.immediate_parent_id is null
AND ac.resource_id = :l_resource_id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type in (''EVEH'',''EONE'')
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE
l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
l_sqltext := l_sqltext||' AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 END IF; -- product category All loop
 END IF; --end view by product category
 END IF; -- end if admin_flag = Y loop





  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


write_debug('GET_TOP_even_OPPS_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_TOP_OPPS_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_EVEH_START_SQL;

--campaign detail

PROCEDURE GET_CAMP_DETL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(15000);
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_una     VARCHAR2(100);
l_url_str VARCHAR2(1000);
l_url_str2 VARCHAR2(1000);
l_url_str3 VARCHAR2(1000);
l_url_str4 VARCHAR2(1000);
l_url_str5 VARCHAR2(1000);
l_url_str6 VARCHAR2(1000);
l_col_id NUMBER;
l_area VARCHAR2(300);
l_report_name VARCHAR2(300);
l_media VARCHAR2(300);
l_qry	varchar2(5000);
l_qry1	varchar2(5000);
l_qry2	varchar2(5000);
l_where   varchar2(5000);
l_where1   varchar2(5000);
l_where2   varchar2(5000);
l_group_by1 varchar2(5000);
l_group_by2 varchar2(5000);
l_group_by varchar2(5000);

BEGIN
	x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
	l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

	bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
											l_as_of_date,
											l_period_type,
											l_record_type_id,
											l_comp_type,
											l_country,
											l_view_by,
											l_cat_id,
											l_campaign_id,
											l_curr,
											l_col_id,
											l_area,
											l_media,
											l_report_name
											);

	IF l_country IS NULL THEN

		l_country := 'N';

	END IF;

	l_admin_status := GET_ADMIN_STATUS;
	l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');

	IF (l_curr = '''FII_GLOBAL1''')	THEN

		l_curr_suffix := '';

	ELSIF (l_curr = '''FII_GLOBAL2''')	THEN

		l_curr_suffix := '_s';
	ELSE
		l_curr_suffix := '';
	END IF;

	--l_url_str :='pFunctionName=BIM_I_CAMP_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=18917&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CAMP&PAGE.OBJ.objAttribute=DETL';
	--l_url_str :='&PAGE.OBJ.objType=CAMP&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
	---l_url_str4 :='pFunctionName=BIM_I_CAMP_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=';
	l_url_str :='pFunctionName=AMS_WB_CAMP_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CAMP&objId=';
	l_url_str2 :='&PAGE.OBJ.objType=EVEH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
	l_url_str5 :='pFunctionName=BIM_I_EVEH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=';
	l_url_str3 :='&PAGE.OBJ.objType=EONE&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
	l_url_str6 :='pFunctionName=BIM_I_EONE_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=';

	IF l_report_name = 'campaign' THEN

		l_qry := '	SELECT
					BIM_ATTRIBUTE1,
					BIM_ATTRIBUTE2,
					BIM_ATTRIBUTE3,
					BIM_ATTRIBUTE4,
					BIM_ATTRIBUTE5,
					(BIM_ATTRIBUTE4 - BIM_ATTRIBUTE5) BIM_ATTRIBUTE6,
					BIM_ATTRIBUTE7,
					sum(BIM_ATTRIBUTE4) over() BIM_GRAND_TOTAL1,
					sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL2,
					sum(BIM_ATTRIBUTE4) over() - sum(BIM_ATTRIBUTE5) over()  BIM_GRAND_TOTAL3,
					'||''''||l_url_str||''''||'||BIM_ATTRIBUTE7 BIM_URL1
				  FROM
				  (
					SELECT
						b.name BIM_ATTRIBUTE1,
						c.start_date BIM_ATTRIBUTE2,
						c.end_date BIM_ATTRIBUTE3,
						c.object_id BIM_ATTRIBUTE7,
						ab.custom_setup_id BIM_ATTRIBUTE8,
						sum(nvl(a.budget_approved'||l_curr_suffix||',0)) BIM_ATTRIBUTE4,
						sum(nvl(a.cost_actual'||l_curr_suffix||',0)) BIM_ATTRIBUTE5
				   FROM
						bim_i_marketing_facts a,
						bim_i_obj_name_mv b,  bim_i_source_codes c ,
						ams_campaigns_all_b ab';

		l_where :=' WHERE
					c.source_code_id = b.source_code_id
					AND c.object_type = ''CAMP''
					AND a.source_code_id(+) = c.source_code_id
					AND c.child_object_id = 0
					AND c.object_id = ab.campaign_id
					AND b.language = userenv(''LANG'')';

		l_group_by := ' GROUP BY b.name,c.object_id,ab.custom_setup_id,c.start_date,c.end_date
					)  &ORDER_BY_CLAUSE ';

		IF l_admin_status = 'N' THEN

			l_qry := l_qry ||',ams_act_access_denorm ac  ';
			l_where := l_where|| ' AND c.object_type = ac.object_type
			AND c.object_type=''CAMP''
			AND c.object_id = ac.object_id
			AND ac.resource_id = :l_resource_id ';

		END IF;

		IF l_cat_id is not null  then
			l_qry:= l_qry ||
					' , eni_denorm_hierarchies edh , mtl_default_category_sets mdcs';

		l_where := l_where||'  AND edh.parent_id =:l_cat_id and nvl(c.category_id,-1) = edh.child_id
					AND edh.object_type = ''CATEGORY_SET''
					AND edh.object_id = mdcs.category_set_id
					AND mdcs.functional_area_id = 11
					AND edh.dbi_flag = ''Y''	';
		END IF;

		IF (l_country <> 'N' ) THEN
			l_where := l_where||' AND c.object_country = :l_country ';
		END If;

		IF l_area is not null THEN
			l_where := l_where||' AND c.object_region = :l_area ';
		END If;

		IF l_col_id = 1 THEN /*Started*/
			l_where := l_where||'
			and c.adj_start_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';
		ELSIF (l_col_id = 2) THEN/*Ended*/
			l_where := l_where||'
						and c.adj_end_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';
		ELSIF (l_col_id = 3) THEN/*Current Active*/
			l_where := l_where||'
						AND c.adj_start_date<=&BIS_CURRENT_ASOF_DATE
						AND c.adj_end_date >= &BIS_CURRENT_ASOF_DATE ';
		END IF;

		l_sqltext:=l_qry||l_where||l_group_by;
		---end for campaign
	ELSE --- event detail report
		l_qry :=  'SELECT
						BIM_ATTRIBUTE1,
						BIM_ATTRIBUTE2,
						BIM_ATTRIBUTE3,
						BIM_ATTRIBUTE4,
						BIM_ATTRIBUTE5,
						(BIM_ATTRIBUTE4 - BIM_ATTRIBUTE5) BIM_ATTRIBUTE6,
						BIM_ATTRIBUTE7,
						sum(BIM_ATTRIBUTE4) over() BIM_GRAND_TOTAL1,
						sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL2,
						sum(BIM_ATTRIBUTE4) over() - sum(BIM_ATTRIBUTE5) over()  BIM_GRAND_TOTAL3,
						decode(object_type,''EVEH'', '||''''|| l_url_str5|| ''''||'||BIM_ATTRIBUTE8||'||''''|| l_url_str2|| ''''||'||BIM_ATTRIBUTE7,'||''''|| l_url_str6|| ''''||'||BIM_ATTRIBUTE8||'||''''|| l_url_str3|| ''''||'||BIM_ATTRIBUTE7) BIM_URL1
					FROM
						(   ';

		l_qry1 :='SELECT
					b.name BIM_ATTRIBUTE1,
					c.start_date BIM_ATTRIBUTE2,
					c.end_date BIM_ATTRIBUTE3,
					c.object_id BIM_ATTRIBUTE7,
					ab.setup_type_id BIM_ATTRIBUTE8,
					SUM(nvl(a.budget_approved'||l_curr_suffix||',0)) BIM_ATTRIBUTE4,
					SUM(nvl(a.cost_actual'||l_curr_suffix||',0)) BIM_ATTRIBUTE5,
					''EVEH'' object_type
				FROM	bim_i_marketing_facts a,
						bim_i_obj_name_mv b,
						ams_event_headers_all_b ab,
						bim_i_source_codes c ';

		l_where1 :=' WHERE
					c.source_code_id = b.source_code_id
					AND c.object_type = ''EVEH''
					AND c.object_id = ab.event_header_id
					AND c.source_code_id = a.source_code_id(+)
					AND c.child_object_id = 0
					AND b.language = userenv(''LANG'')';

		l_group_by1 := ' GROUP BY b.name,c.object_id,ab.setup_type_id,c.start_date,c.end_date ';


		l_qry2 :=' UNION ALL -- for one-off events
				   SELECT
						b.name BIM_ATTRIBUTE1,
						c.start_date BIM_ATTRIBUTE2,
						c.end_date BIM_ATTRIBUTE3,
						c.object_id BIM_ATTRIBUTE7,
						ab.setup_type_id BIM_ATTRIBUTE8,
						SUM(nvl(a.budget_approved'||l_curr_suffix||',0)) BIM_ATTRIBUTE4,
						SUM(nvl(a.cost_actual'||l_curr_suffix||',0)) BIM_ATTRIBUTE5,
						''EONE'' object_type
					FROM bim_i_marketing_facts a,
						bim_i_obj_name_mv b,
						ams_event_offers_all_b ab,
						bim_i_source_codes c';

		l_where2 :=' WHERE
					c.source_code_id = a.source_code_id (+)
					AND c.object_type = ''EONE''
					AND c.source_code_id = b.source_code_id
					AND c.object_id = ab.event_offer_id
					AND c.child_object_id = 0
					AND b.language = userenv(''LANG'')';

		l_group_by2 := ' GROUP BY b.name,c.object_id,ab.setup_type_id,c.start_date,c.end_date
					  )  &ORDER_BY_CLAUSE ';

		IF l_admin_status = 'N' THEN

			l_qry1 := l_qry1 ||',ams_act_access_denorm ac  ';

			l_where1 := l_where1|| ' AND c.object_type = ac.object_type
									AND c.object_type=''EVEH''
									AND c.object_id = ac.object_id
									AND ac.resource_id = :l_resource_id ';

			l_qry2 := l_qry2 ||',ams_act_access_denorm ac  ';

			l_where2 := l_where2|| ' AND c.object_type = ac.object_type
								AND c.object_type=''EONE''
								AND c.object_id = ac.object_id
								AND ac.resource_id = :l_resource_id ';
		END IF;

		IF l_cat_id IS NOT NULL  THEN

			l_qry1:= l_qry1 ||' , eni_denorm_hierarchies edh , mtl_default_category_sets mdcs ';
			l_where1 := l_where1||'  AND edh.parent_id =:l_cat_id
									 AND nvl(c.category_id,-1) = edh.child_id
									 AND edh.object_type = ''CATEGORY_SET''
									AND edh.object_id = mdcs.category_set_id
									AND mdcs.functional_area_id = 11
									AND edh.dbi_flag = ''Y''	';

			l_qry2:= l_qry2 ||	' , eni_denorm_hierarchies edh , mtl_default_category_sets mdcs';
			l_where2 := l_where2||'  AND edh.parent_id =:l_cat_id
									 AND nvl(c.category_id,-1) = edh.child_id
									 AND edh.object_type = ''CATEGORY_SET''
									AND edh.object_id = mdcs.category_set_id
									AND mdcs.functional_area_id = 11
									AND edh.dbi_flag = ''Y''	';

		END IF;

		IF (l_country <> 'N' ) THEN

			l_where1 := l_where1||' AND c.object_country = :l_country ';
			l_where2 := l_where2||' AND c.object_country = :l_country ';

		END IF;

		IF l_area IS NOT NULL THEN

			l_where1 := l_where1||' AND c.object_region = :l_area ';
			l_where2 := l_where2||' AND c.object_region = :l_area ';
		END If;

		IF l_col_id = 1 THEN /*Started*/

			l_where1 := l_where1||'	and c.adj_start_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';
			l_where2 := l_where2||'	and c.adj_start_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';

		ELSIF (l_col_id = 2) THEN/*Ended*/

			l_where1 := l_where1||'	and c.adj_end_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';
			l_where2 := l_where2||'	and c.adj_end_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';

		ELSIF (l_col_id = 3) THEN/*Current Active*/

			l_where1 := l_where1||'	and c.adj_start_date<=&BIS_CURRENT_ASOF_DATE and c.adj_end_date >= &BIS_CURRENT_ASOF_DATE ';
			l_where2 := l_where2||'	and c.adj_start_date<=&BIS_CURRENT_ASOF_DATE and c.adj_end_date >= &BIS_CURRENT_ASOF_DATE ';

		END IF;

		l_sqltext:=l_qry||l_qry1||l_where1||l_group_by1||l_qry2||l_where2||l_group_by2;

	 END IF;

	  x_custom_sql := l_sqltext;
	  l_custom_rec.attribute_name := ':l_record_type';
	  l_custom_rec.attribute_value := l_record_type_id;
	  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	  x_custom_output.EXTEND;
	  x_custom_output(1) := l_custom_rec;

	  l_custom_rec.attribute_name := ':l_resource_id';
	  l_custom_rec.attribute_value := GET_RESOURCE_ID;
	  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	  x_custom_output.EXTEND;
	  x_custom_output(2) := l_custom_rec;

	  l_custom_rec.attribute_name := ':l_admin_flag';
	  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
	  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	  x_custom_output.EXTEND;
	  x_custom_output(3) := l_custom_rec;

	  l_custom_rec.attribute_name := ':l_country';
	  l_custom_rec.attribute_value := l_country;
	  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	  x_custom_output.EXTEND;
	  x_custom_output(4) := l_custom_rec;

	  l_custom_rec.attribute_name := ':l_cat_id';
	  l_custom_rec.attribute_value := l_cat_id;
	  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	  x_custom_output.EXTEND;
	  x_custom_output(5) := l_custom_rec;

	  l_custom_rec.attribute_name := ':l_area';
	  l_custom_rec.attribute_value := l_area;
	  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	  x_custom_output.EXTEND;
	  x_custom_output(6) := l_custom_rec;

EXCEPTION
	WHEN others THEN
		l_sql_errm := SQLERRM;
		write_debug('GET_CAMP_DETL_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_CAMP_DETL_SQL;



PROCEDURE GET_CSCH_START_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(15000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_view_by      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
l_cat_id VARCHAR2(50);
l_media VARCHAR2(50);
l_col_id NUMBER;
l_view_by_name VARCHAR2(50);
l_area VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_dass                 varchar2(100);  -- variable to store value for  directly assigned lookup value
l_una                   varchar2(100);   -- variable to store value for  Unassigned lookup value
l_eve                   varchar2(100);   -- variable to store value for  Events lookup value
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_report_name VARCHAR2(50);
l_url_str1 VARCHAR2(1000);
l_url_str2 VARCHAR2(1000);
l_url_str3 VARCHAR2(1000);
l_url_str1_mc VARCHAR2(1000);
l_url_str2_mc VARCHAR2(1000);
l_url_str3_mc VARCHAR2(1000);
l_view_name VARCHAR2(100);
l_url_str1_r VARCHAR2(1000);
l_url_str2_r VARCHAR2(1000);
l_url_str3_r VARCHAR2(1000);

BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );

l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
l_eve := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('EVE');

IF   l_view_by ='GEOGRAPHY+COUNTRY' then
l_view_name :=L_viewby_c; --'Country'
ELSIF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' then
l_view_name:=L_viewby_pc ;     --'Product Category'
ELSIF l_view_by ='MEDIA+MEDIA' then
 l_view_name :=L_viewby_mc;
ELSIF l_view_by='GEOGRAPHY+AREA' then
 l_view_name :=L_viewby_r; --'Region'
END IF;

l_url_str1:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=1';
l_url_str2:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=2';
l_url_str3:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=3';

l_url_str1_mc:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=1&BIM_PARAMETER4=3';
l_url_str2_mc:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=2&BIM_PARAMETER4=3';
l_url_str3_mc:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=3&BIM_PARAMETER4=3';

l_url_str1_r:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=1&BIM_PARAMETER4=4';
l_url_str2_r:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=2&BIM_PARAMETER4=4';
l_url_str3_r:='pFunctionName=BIM_I_CSCH_START_DETL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&BIM_PARAMETER5='||l_view_name||' :'||'''||VIEWBY||''&BIM_PARAMETER1=3&BIM_PARAMETER4=4';

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
  /* IF l_country IS NULL THEN
      l_country := 'N';
   END IF;*/
   l_admin_status := GET_ADMIN_STATUS;
 IF l_admin_status = 'Y' THEN
if (l_view_by = 'GEOGRAPHY+COUNTRY') then
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
/*l_sqltext := l_sqltext ||
--' AND a.object_country = :l_country
'group by object_country*/
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
fii_time_rpt_struct_v cal,
bis_countries_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 END IF;
ELSIF (l_view_by = 'GEOGRAPHY+AREA') then
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1_r||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2_r||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3_r||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region = d.id(+)
AND a.object_country =:l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_mkt_regn_mv a,
fii_time_rpt_struct_v cal,
bis_areas_v d';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
  l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region) group by name,id )';
-- View By Marketing Channel
ELSIF (l_view_by = 'MEDIA+MEDIA') then
l_sqltext :=
'
 SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1_mc||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2_mc||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3_mc||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
sum(nvl(curr_prior_active,0)) BIM_ATTRIBUTE2,
sum(nvl(curr_started,0)) BIM_ATTRIBUTE3,
SUM(nvl(prev_started,0)) BIM_ATTRIBUTE4,
sum(nvl(curr_ended,0))  BIM_ATTRIBUTE5,
SUm(nvl(prev_ended,0)) BIM_ATTRIBUTE6,
sum(nvl(curr_prior_active,0))+sum(nvl(curr_started,0))-sum(nvl(curr_act_ended,0)) BIM_ATTRIBUTE7,
sum(nvl(prev_prior_active,0))+sum(nvl(prev_started,0))-sum(nvl(prev_act_ended,0)) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) name,
media_id id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM ams_media_tl d ,
    fii_time_rpt_struct_v cal  ,
    bim_mkt_chnl_mv a ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||' ,eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND  d.media_id(+) = a.activity_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND d.language(+)=USERENV(''LANG'')
AND a.object_country = :l_country  ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id  ';
  end if;
 l_sqltext := l_sqltext ||' group by media_id,decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name)';

l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) name,
media_id id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM ams_media_tl d ,
    fii_time_rpt_struct_v cal  ,
    bim_mkt_chnl_mv a ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
 end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  d.media_id(+) = a.activity_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND d.language(+)=USERENV(''LANG'')
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
  l_sqltext := l_sqltext ||' group by media_id,decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name)';
  l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) name,
media_id id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM ams_media_tl d ,
    fii_time_rpt_struct_v cal  ,
    bim_mkt_chnl_mv a ';
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
 end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  d.media_id(+) = a.activity_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND d.language(+)=USERENV(''LANG'')
AND a.object_country = :l_country ';
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
     l_sqltext := l_sqltext ||' group by media_id,decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) ) group by name,id )';

 --- View By Product Category for admin
ELSE
-- for Product Category  All
IF l_cat_id is null then
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(viewbyid,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CSCH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
p.parent_id id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
p.parent_id id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id ';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
 UNION ALL
SELECT
p.value name,
p.parent_id id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
     (select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
    AND b.object_type = ''CATEGORY_SET''
    AND b.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND b.dbi_flag = ''Y''
    AND p.parent_id = b.parent_id ';
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
) group by name,id )';
ELSE
-- for product category not equal to all
-- current bookmark
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(viewbyid,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CSCH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.parent_id = p.id
AND b.dbi_flag = ''Y''';
l_sqltext := l_sqltext ||' group by p.value,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
-1 id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
    (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value
UNION ALL
SELECT
p.value name,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
    (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'') ) p
WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag =''Y''
AND b.parent_id = p.id ';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
-1 id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
    (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id
';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value
 UNION ALL
SELECT
p.value name,
decode(p.leaf_node_flag,''Y'',-1,b.parent_id) id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,
     (select e.id id ,e.value value,leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND b.parent_id = p.id ';
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,decode(p.leaf_node_flag,''Y'',-1,b.parent_id)
UNION ALL
SELECT
p.value name,
-1 id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_mkt_kpi_cnt_mv a,
     fii_time_rpt_struct_v cal,
     (select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = p.id
 group by p.value) group by name,id )';
END IF; -- end product category numm loop
 END IF; --end view by product category
ELSE -- if admin_flag is not equal to Y
if (l_view_by = 'GEOGRAPHY+COUNTRY') then
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d, bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+) ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d, bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
 IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country';
 END IF;
l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_country id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_countries_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_countries_v d, bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext||' AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_country =d.country_code (+)';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
IF l_country = 'N' THEN
     l_sqltext := l_sqltext ||' AND a.object_country <> ''N'' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 ELSE
  l_sqltext := l_sqltext ||
' AND a.object_country = :l_country group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_country ) group by name,id )';
 END IF;
ELSIF (l_view_by = 'GEOGRAPHY+AREA') then
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1_r||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2_r||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3_r||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d, bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id  ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d, bim_i_source_codes s  ';
END IF;
IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext ||' AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
 l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region';
 l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
a.object_region id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_obj_regn_mv a,
fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac,bis_areas_v d ';
ELSE
l_sqltext := l_sqltext ||' ams_act_access_denorm ac,bis_areas_v d, bim_i_source_codes s  ';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id';
l_sqltext := l_sqltext||' AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND  a.object_region =d.id(+)
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			     AND edh.object_type = ''CATEGORY_SET''
			     AND edh.object_id = mdc.category_set_id
			     AND mdc.functional_area_id = 11
			     AND edh.dbi_flag = ''Y''
			     AND edh.parent_id = :l_cat_id ';
  end if;
l_sqltext := l_sqltext ||' group by decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value),a.object_region ) group by name,id )';
ELSIF (l_view_by = 'MEDIA+MEDIA') then
l_sqltext :=
'
 SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
null BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1_mc||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2_mc||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3_mc||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) name,
media_id id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM ams_media_tl d ,
    fii_time_rpt_struct_v cal  ,
    bim_obj_chnl_mv a ,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
  end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND  d.media_id(+) = a.activity_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND d.language(+)=USERENV(''LANG'')
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
     l_sqltext := l_sqltext ||' group by media_id,decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name)';
 l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) name,
media_id id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM ams_media_tl d ,
    fii_time_rpt_struct_v cal  ,
    bim_obj_chnl_mv a ,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
 end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND ac.resource_id = :l_resource_id
AND  d.media_id(+) = a.activity_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE -1)
AND cal.calendar_id=-1
AND d.language(+)=USERENV(''LANG'')
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
 l_sqltext := l_sqltext ||' group by media_id,decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name)';

 l_sqltext := l_sqltext ||
' UNION ALL
SELECT
decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) name,
media_id id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM ams_media_tl d ,
    fii_time_rpt_struct_v cal  ,
    bim_obj_chnl_mv a ,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
 IF l_cat_id is not null then
  l_sqltext := l_sqltext ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdc ';
 end if;
  l_sqltext := l_sqltext ||
' WHERE a.time_id = cal.time_id
AND ac.resource_id = :l_resource_id
AND  d.media_id(+) = a.activity_id
AND a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND d.language(+)=USERENV(''LANG'')
AND a.object_country = :l_country ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is null then
l_sqltext := l_sqltext ||' AND a.category_id = -9 ';
else
  l_sqltext := l_sqltext ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdc.category_set_id
			   AND mdc.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
  l_sqltext := l_sqltext ||' group by media_id,decode(d.media_name,null,'||''''||l_eve||''''||',d.media_name) ) group by name,id )';
 --- View By Product Category for admin
ELSE
IF l_cat_id is null THEN
l_sqltext :=
'
SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(viewbyid,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CSCH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
p.parent_id id,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
 l_sqltext := l_sqltext ||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.value name,
p.parent_id id,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext := l_sqltext||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND p.parent_id = b.parent_id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
 UNION ALL
SELECT
p.value name,
p.parent_id id,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext := l_sqltext||' ,(select e.parent_id parent_id ,e.value value
      from eni_item_vbh_nodes_v e
      where
      e.top_node_flag=''Y''
      AND e.child_id = e.parent_id
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND ac.resource_id = :l_resource_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND  a.category_id = b.child_id
    AND b.object_type = ''CATEGORY_SET''
    AND b.object_id = mdcs.category_set_id
    AND mdcs.functional_area_id = 11
    AND b.dbi_flag = ''Y''
    AND p.parent_id = b.parent_id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;
l_sqltext := l_sqltext ||' group by p.value,p.parent_id
) group by name,id )';
ELSE -- product category is not null
l_sqltext :=
'SELECT
VIEWBY,
VIEWBYID,
BIM_ATTRIBUTE2,
BIM_ATTRIBUTE3,
decode(BIM_ATTRIBUTE4,0,null,100*(BIM_ATTRIBUTE3-BIM_ATTRIBUTE4)/BIM_ATTRIBUTE4) BIM_ATTRIBUTE4,
BIM_ATTRIBUTE5,
decode(BIM_ATTRIBUTE6,0,null,100*(BIM_ATTRIBUTE5-BIM_ATTRIBUTE6)/BIM_ATTRIBUTE6) BIM_ATTRIBUTE6,
BIM_ATTRIBUTE7,
decode(BIM_ATTRIBUTE8,0,null,100*(BIM_ATTRIBUTE7-BIM_ATTRIBUTE8)/BIM_ATTRIBUTE8) BIM_ATTRIBUTE8,
BIM_ATTRIBUTE7 BIM_ATTRIBUTE9,
sum(BIM_ATTRIBUTE2) over() BIM_GRAND_TOTAL1,
sum(BIM_ATTRIBUTE3) over() BIM_GRAND_TOTAL2,
decode(sum(BIM_ATTRIBUTE4) over(),0,null,100*(sum(BIM_ATTRIBUTE3) over()-sum(BIM_ATTRIBUTE4) over())/sum(BIM_ATTRIBUTE4) over()) BIM_GRAND_TOTAL3,
sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL4,
decode(sum(BIM_ATTRIBUTE6) over(),0,null,100*(sum(BIM_ATTRIBUTE5) over()-sum(BIM_ATTRIBUTE6) over())/sum(BIM_ATTRIBUTE6) over()) BIM_GRAND_TOTAL5,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL6,
decode(sum(BIM_ATTRIBUTE8) over(),0,null,100*(sum(BIM_ATTRIBUTE7) over()-sum(BIM_ATTRIBUTE8) over())/sum(BIM_ATTRIBUTE8) over()) BIM_GRAND_TOTAL7,
sum(BIM_ATTRIBUTE7) over() BIM_GRAND_TOTAL8,
decode(viewbyid,-1,NULL,-1,NULL,-1,null,''pFunctionName=BIM_I_CSCH_STARTED&pParamIds=Y&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&VIEW_BY_NAME=VIEW_BY_ID'' ) BIM_URL1,
decode(BIM_ATTRIBUTE3, 0,NULL,'||''''||l_url_str1||''''||')  BIM_URL2,
decode(BIM_ATTRIBUTE5, 0,NULL,'||''''||l_url_str2||''''||')  BIM_URL3,
decode(BIM_ATTRIBUTE7, 0,NULL,'||''''||l_url_str3||''''||')  BIM_URL4
FROM
(
SELECT
name VIEWBY,
id VIEWBYID,
nvl(sum(curr_prior_active),0) BIM_ATTRIBUTE2,
sum(curr_started) BIM_ATTRIBUTE3,
SUM(prev_started) BIM_ATTRIBUTE4,
sum(curr_ended)  BIM_ATTRIBUTE5,
SUm(prev_ended) BIM_ATTRIBUTE6,
nvl(sum(curr_prior_active),0)+sum(curr_started)-sum(curr_act_ended) BIM_ATTRIBUTE7,
nvl(sum(prev_prior_active),0)+sum(prev_started)-sum(prev_act_ended) BIM_ATTRIBUTE8
FROM
(
SELECT
p.value name,
p.id id,
p.leaf_node_flag leaf_node_flag ,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value , e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.parent_id = p.id
AND b.dbi_flag = ''Y''';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
l_sqltext := l_sqltext ||' group by p.value,p.id, p.leaf_node_flag ';
l_sqltext :=l_sqltext ||
' UNION ALL
SELECT
p.id ID,
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'   name,
''Y'' leaf_node_flag ,
sum(camp_sch_started-camp_sch_ended) curr_prior_active,
0 prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value , e.leaf_node_flag leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.id
UNION ALL
SELECT
p.value name,
p.id id,
p.leaf_node_flag leaf_node_flag ,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value e.leaf_node_flag leaf_node_flag ,
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'') ) p
WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = b.child_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag =''Y''
AND b.parent_id = p.id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.id  , p.value , p.leaf_node_flag
UNION ALL
SELECT
p.id ID,
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'   name,
''Y'' leaf_node_flag ,
0 curr_prior_active,
sum(camp_sch_started-camp_sch_ended) prev_prior_active,
0 curr_active,
0 prev_active,
0 curr_started,
0 prev_started,
0 curr_ended,
0 prev_ended,
0 curr_act_ended,
0 prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext:=l_sqltext||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,1143)=cal.record_type_id
AND cal.report_date in (&BIS_PREVIOUS_EFFECTIVE_START_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id
';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.id
 UNION ALL
SELECT
p.id ID,
p.value   name,
p.leaf_node_flag leaf_node_flag ,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,
     eni_denorm_hierarchies b,
     mtl_default_category_sets mdcs,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext :=l_sqltext||' ,(select e.id id ,e.value value , e.leaf_node_flag
      from eni_item_vbh_nodes_v e
      where e.parent_id =:l_cat_id
      AND e.id = e.child_id
      AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND a.category_id = b.child_id
AND ac.resource_id = :l_resource_id
AND b.object_type = ''CATEGORY_SET''
AND b.object_id = mdcs.category_set_id
AND mdcs.functional_area_id = 11
AND b.dbi_flag = ''Y''
AND b.parent_id = p.id ';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
/*IF l_cat_id is not null
then
l_sqltext := l_sqltext ||' AND p.parent_id = :l_cat_id ';
end if;*/
l_sqltext := l_sqltext ||' group by p.value,p.id , p.leaf_node_flag
UNION ALL
SELECT
p.id ID,
bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||'   name,
''Y'' leaf_node_flag ,
0 curr_prior_active,
0 prev_prior_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) curr_active,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then (camp_sch_started-camp_sch_ended) else 0 end) prev_active,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then  camp_sch_started else 0 end) curr_started,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_started else 0 end) prev_started,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then camp_sch_ended else 0 end) curr_ended,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then camp_sch_ended else 0 end) prev_ended,
SUM(case when &BIS_CURRENT_ASOF_DATE >&BIS_CURRENT_EFFECTIVE_START_DATE and cal.report_date=&BIS_CURRENT_ASOF_DATE-1 then camp_sch_ended else 0 end) curr_act_ended,
SUM(case when &BIS_PREVIOUS_ASOF_DATE >&BIS_PREVIOUS_EFFECTIVE_START_DATE and cal.report_date=&BIS_PREVIOUS_ASOF_DATE-1 then camp_sch_ended else 0 end) prev_act_ended
FROM bim_i_obj_mets_mv a,
     fii_time_rpt_struct_v cal,';
IF l_prog_view='Y' then
  l_sqltext := l_sqltext ||' bim_i_top_objects ac';
ELSE
l_sqltext := l_sqltext ||'  ams_act_access_denorm ac, bim_i_source_codes s';
END IF;
l_sqltext := l_sqltext ||' ,(select e.id id ,e.value value
      from eni_item_vbh_nodes_v e
      where e.parent_id =  :l_cat_id
      AND e.parent_id = e.child_id
      AND leaf_node_flag <> ''Y''
      ) p
WHERE
     a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE,&BIS_CURRENT_ASOF_DATE-1,&BIS_PREVIOUS_ASOF_DATE-1)
AND cal.calendar_id=-1
AND a.object_country = :l_country
AND ac.resource_id = :l_resource_id
AND a.category_id = p.id';
IF l_prog_view='N' then
l_sqltext := l_sqltext ||' AND s.object_type=''CAMP''
AND a.source_code_id = s.source_code_id
AND s.object_id = ac.object_id
AND s.object_type=ac.object_type
';
ELSE l_sqltext := l_sqltext ||' AND a.source_code_id = ac.source_code_id';
END IF;
 l_sqltext:=l_sqltext||' group by p.id
 ) group by name,id )';
 END IF; -- product category All loop
 END IF; --end view by product category
END IF; -- end if admin_flag = Y loop


  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_view_by';
  l_custom_rec.attribute_value := l_view_by;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

 l_custom_rec.attribute_name := ':l_area';
  l_custom_rec.attribute_value := l_area;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;

   l_custom_rec.attribute_name := ':l_media';
  l_custom_rec.attribute_value := l_media;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(8) := l_custom_rec;

--write_debug('GET_CSCH_START_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_CSCH_START_SQL','ERROR',l_sql_errm,l_sqltext);
END GET_CSCH_START_SQL;

PROCEDURE GET_CSCH_DETL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(15000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_country      varchar2(4000);
l_sql_errm      varchar2(4000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_user_id NUMBER;
l_resource_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_admin_status VARCHAR2(20);
l_admin_flag VARCHAR2(1);
l_admin_count Number;
l_rsid NUMBER;
l_curr_aod_str varchar2(80);
l_country_clause varchar2(4000);
l_access_clause varchar2(4000);
l_access_table varchar2(4000);
--l_cat_id NUMBER;
l_cat_id VARCHAR2(50);
l_campaign_id VARCHAR2(50);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_dass                 varchar2(100);  -- variable to store value for  directly assigned lookup value
l_una                  varchar2(100);   -- variable to store value for  Unassigned lookup value
l_url_str VARCHAR2(1000);
l_url_str_csch VARCHAR2(1000);
l_col_id NUMBER;
l_viewby_id NUMBER;
l_view_by VARCHAR2(100);
l_area VARCHAR2(300);
l_media VARCHAR2(50);
p_report_name VARCHAR2(300);
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_view_id     varchar2(5000);
      l_qry	varchar2(5000);
      l_from    varchar2(5000);
      l_where   varchar2(5000);
      l_view_col varchar2(5000);
      l_group_by varchar2(5000);
      l_report_name varchar2(50);
      l_curr_suffix1 VARCHAR2(50);

BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
                                                      l_as_of_date,
                                                      l_period_type,
                                                      l_record_type_id,
                                                      l_comp_type,
                                                      l_country,
                                                      l_view_by,
                                                      l_cat_id,
                                                      l_campaign_id,
                                                      l_curr,
                                                      l_col_id,
                                                      l_area,
                                                      l_media,
                                                      l_report_name
                                                      );

bim_pmv_dbi_utl_pkg.get_viewby_id(p_page_parameter_tbl,l_viewby_id);


 IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
 l_admin_status := GET_ADMIN_STATUS;

l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');

--l_url_str :='pFunctionName=BIM_I_CAMP_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=18917&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CAMP&PAGE.OBJ.objAttribute=DETL';
--l_url_str :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&objType=CSCH&objId=';
    l_url_str :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
--l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&objId=';
l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';

if l_curr_suffix is null then
l_curr_suffix1:=1;
else
l_curr_suffix1:=2;
end if;

l_qry := '        SELECT
          BIM_ATTRIBUTE1,
          BIM_ATTRIBUTE8,
          BIM_ATTRIBUTE2,
          BIM_ATTRIBUTE3,
	  BIM_ATTRIBUTE9,
          BIM_ATTRIBUTE4,
          BIM_ATTRIBUTE5,
          (BIM_ATTRIBUTE4 - BIM_ATTRIBUTE5) BIM_ATTRIBUTE6,
	  BIM_ATTRIBUTE7,
	  sum(BIM_ATTRIBUTE4) over() BIM_GRAND_TOTAL1,
	  sum(BIM_ATTRIBUTE5) over() BIM_GRAND_TOTAL2,
	  sum(BIM_ATTRIBUTE4) over() - sum(BIM_ATTRIBUTE5) over()  BIM_GRAND_TOTAL3,
	 '||''''|| l_url_str_csch|| ''''||'||BIM_ATTRIBUTE7 	BIM_URL1
	  FROM
          (
           select b.schedule_name BIM_ATTRIBUTE1,
	          s.start_date BIM_ATTRIBUTE2,
                  s.end_date BIM_ATTRIBUTE3,
		  c.campaign_name BIM_ATTRIBUTE8,
                  b.schedule_id BIM_ATTRIBUTE7,
		  d.media_name BIM_ATTRIBUTE9,
		  s.child_object_usage usage,
                  sum(nvl(a.metric'||l_curr_suffix1||',0)) BIM_ATTRIBUTE4,
                  sum(nvl(a.cost_actual'||l_curr_suffix||',0)) BIM_ATTRIBUTE5
           from
		   bim_i_marketing_facts a , bim_i_source_codes s ,
           ams_campaign_schedules_tl b, ams_campaigns_all_tl c,
			ams_media_tl d
	    ';
l_where :=' WHERE
			    s.object_id = c.campaign_id
			AND c.language=USERENV(''LANG'')
			AND d.media_id(+) = s.activity_id
			AND d.language(+)=USERENV(''LANG'')
			AND b.language(+)=USERENV(''LANG'')
			AND s.object_type = ''CAMP''
			AND s.child_object_type=''CSCH''
			AND a.source_code_id(+) = s.source_code_id
			AND s.child_object_id = b.schedule_id ';
l_group_by := ' group by c.campaign_name, d.media_name,b.schedule_name,b.schedule_id,s.start_date,s.end_date,s.child_object_usage
           )  &ORDER_BY_CLAUSE';

	IF l_admin_status = 'N' THEN
		l_qry := l_qry ||',ams_act_access_denorm ac  ';
		l_where := l_where|| ' AND s.child_object_type = ac.object_type
							AND s.child_object_id = ac.object_id
							AND ac.resource_id = :l_resource_id ';
	END IF;

  if l_cat_id is not null  then
   l_qry:= l_qry || ' , eni_denorm_hierarchies edh , mtl_default_category_sets mdcs';
   l_where := l_where||'  AND edh.parent_id ='||l_cat_id||
					   ' and nvl(s.category_id,-1) = edh.child_id
   					    AND edh.object_type = ''CATEGORY_SET''
						AND edh.object_id = mdcs.category_set_id
						AND mdcs.functional_area_id = 11
						AND edh.dbi_flag = ''Y'' ';
  end if;
IF l_col_id = 1 THEN /*Started*/
   l_where := l_where||' and s.adj_start_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';
ELSIF (l_col_id = 2) THEN/*Ended*/
 l_where := l_where||'  and s.adj_end_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE ';
ELSIF (l_col_id = 3) THEN/*Current Active*/
l_where := l_where||' and s.adj_start_date<=&BIS_CURRENT_ASOF_DATE	 and s.adj_end_date >= &BIS_CURRENT_ASOF_DATE ';
END IF;
 /************  Query for View By Selection  ************/
 if l_viewby_id = 3 then
    l_view_by :='MEDIA+MEDIA';
 ELSIF l_viewby_id = 4 then
    l_view_by:='GEOGRAPHY+AREA' ;
 END IF;
-- if l_view_by = 'GEOGRAPHY+COUNTRY' then
if l_country <> 'N' THEN
    l_where:=l_where||' AND s.object_country = '''||l_country||'''';
 elsif l_view_by = 'GEOGRAPHY+AREA'  THEN
    l_where:=l_where||' AND s.object_region = :l_area';
 elsif l_view_by = 'MEDIA+MEDIA' THEN
     l_where:=l_where||' AND s.activity_id ='||l_media||'';
 end if;
 l_sqltext:=l_qry||l_where||l_group_by;

  x_custom_sql := l_sqltext;
  l_custom_rec.attribute_name := ':l_record_type';
  l_custom_rec.attribute_value := l_record_type_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_resource_id';
  l_custom_rec.attribute_value := GET_RESOURCE_ID;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_admin_flag';
  l_custom_rec.attribute_value := GET_ADMIN_STATUS;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_country';
  l_custom_rec.attribute_value := l_country;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_cat_id';
  l_custom_rec.attribute_value := l_cat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

 l_custom_rec.attribute_name := ':l_media';
 l_custom_rec.attribute_value := l_media;
 l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_area';
  l_custom_rec.attribute_value := l_area;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

--write_debug('GET_CSCH_DETL_SQL','QUERY','_',l_sqltext);

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_CSCH_DETL_SQL','ERROR',l_sql_errm,l_sqltext);

END GET_CSCH_DETL_SQL;


  PROCEDURE GET_RESP_SUM_SQL(p_page_parameter_tbl IN bis_pmv_page_parameter_tbl,
                                 x_custom_sql         OUT NOCOPY VARCHAR2,
                                 x_custom_output      OUT NOCOPY bis_query_attributes_tbl) IS
    l_sqltext                    VARCHAR2(32000);
    iflag                        NUMBER;
    l_period_type_hc             NUMBER;
    l_as_of_date                 DATE;
    l_period_type                VARCHAR2(2000);
    l_record_type_id             NUMBER;
    l_comp_type                  VARCHAR2(2000);
    l_country                    VARCHAR2(4000);
    l_view_by                    VARCHAR2(4000);
    l_sql_errm                   VARCHAR2(4000);
    l_previous_report_start_date DATE;
    l_current_report_start_date  DATE;
    l_previous_as_of_date        DATE;
    l_period_type_id             NUMBER;
    l_user_id                    NUMBER;
    l_resource_id                NUMBER;
    l_time_id_column             VARCHAR2(1000);
    l_admin_status               VARCHAR2(20);
    l_admin_flag                 VARCHAR2(1);
    l_admin_count                NUMBER;
    l_rsid                       NUMBER;
    l_curr_aod_str               VARCHAR2(80);
    l_country_clause             VARCHAR2(4000);
    l_access_clause              VARCHAR2(4000);
    l_access_table               VARCHAR2(4000);
    l_cat_id                     VARCHAR2(50) := NULL;
    l_campaign_id                VARCHAR2(50) := NULL;
    l_select                     VARCHAR2(20000); -- to build  inner select to pick data from mviews
    l_pc_select                  VARCHAR2(20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
    l_select_cal                 VARCHAR2(20000); -- to build  select calculation part
    l_select_cal1                VARCHAR2(20000);
    l_select_filter              VARCHAR2(20000); -- to build  select filter part
    l_from                       VARCHAR2(20000); -- assign common table in  clause
    l_where                      VARCHAR2(20000); -- static where clause
    l_groupby                    VARCHAR2(2000); -- to build  group by clause
    l_pc_from                    VARCHAR2(20000); -- from clause to handle product category
    l_pc_where                   VARCHAR2(20000); --  where clause to handle product category
    l_filtercol                  VARCHAR2(2000);
    l_pc_col                     VARCHAR2(200);
    l_pc_groupby                 VARCHAR2(200);
    l_view                       VARCHAR2(20);
    l_select1                    VARCHAR2(20000);
    l_select2                    VARCHAR2(20000);
    l_view_disp                  VARCHAR2(100);
    l_url_str                    VARCHAR2(1000);
    l_url_str_csch               varchar2(1000);
    l_url_str_type               varchar2(3000);
    l_url_str_csch_jtf           varchar2(3000);
    l_camp_sel_col               varchar2(100);
    l_camp_groupby_col           varchar2(100);
    l_csch_chnl                  varchar2(100);
    l_top_cond                   VARCHAR2(100);
    l_meaning                    VARCHAR2(20);
    l_inner                      varchar2(5000);
    l_inr_cond                   varchar2(5000);
    l_from_inr                   VARCHAR2(20000);
    l_where_inr                  VARCHAR2(20000);
    l_curr                       VARCHAR2(50);
    l_curr_suffix                VARCHAR2(50);
    l_viewby1 varchar2(200);
    l_grp_by1 varchar2(200);
    l_where1  varchar2(100);
    l_from1   varchar2(50);
    L_TOP_SQl varchar2(3200);
    /* variables to hold columns names in l_select clauses */
    l_col VARCHAR2(1000);
    /* cursor to get type of object passed from the page ******/
    cursor get_obj_type is
      select object_type
        from bim_i_source_codes
       where source_code_id = replace(l_campaign_id, '''');
    /*********************************************************/
    l_custom_rec  bis_query_attributes;
    l_object_type varchar2(30);
    l_url_link    varchar2(200);
    l_url_camp1   varchar2(3000);
    l_url_camp2   varchar2(3000);
    l_dass        varchar2(100); -- variable to store value for  directly assigned lookup value
    --l_una                        varchar2(100);   -- variable to store value for  Unassigned lookup value
    l_leaf_node_flag varchar2(25); -- variable to store value leaf_node_flag column in case of product category
    l_col_id         NUMBER;
    l_area           VARCHAR2(300);
    l_report_name    VARCHAR2(300);
    l_media          VARCHAR2(300);
    l_curr_suffix1 VARCHAR2(50);
    l_table_bud VARCHAR2(300);
    l_where_bud VARCHAR2(300);
    l_prog_cost1 VARCHAR2(30);

  BEGIN
    x_custom_output := bis_query_attributes_tbl();
    l_custom_rec    := bis_pmv_parameters_pub.initialize_query_type;
    bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
                                            l_as_of_date,
                                            l_period_type,
                                            l_record_type_id,
                                            l_comp_type,
                                            l_country,
                                            l_view_by,
                                            l_cat_id,
                                            l_campaign_id,
                                            l_curr,
                                            l_col_id,
                                            l_area,
                                            l_media,
                                            l_report_name);
    l_meaning   := ' null meaning '; -- assigning default value
    l_url_camp1 := ',null';
    l_url_camp2 := ',null';
    IF (l_curr = '''FII_GLOBAL1''') THEN
      l_curr_suffix := '';
    ELSIF (l_curr = '''FII_GLOBAL2''') THEN
      l_curr_suffix := '_s';
    ELSE
      l_curr_suffix := '';
    END IF;
    IF l_country IS NULL THEN
      l_country := 'N';
    END IF;
    /************Start Inner Query to get current acitve objects *************************/
    l_inner := ', ( select distinct  codes.source_code_id from BIM_I_obj_METS_MV a,BIM_I_SOURCE_CODES codes
,fii_time_rpt_struct_v cal';
    IF l_admin_status = 'N' THEN
      l_inner := l_inner || ',bim_i_top_objects r ';
    end if;
    IF l_cat_id is not null then
      l_inner := l_inner ||
                 ',eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
    end if;
    l_inner := l_inner ||
               ' WHERE  a.source_code_id = codes.source_code_id and a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id  AND cal.calendar_id=-1 AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND a.object_country = :l_country AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id    and (responses_positive >0)';
    IF l_admin_status = 'N' THEN
      l_inner := l_inner ||
                 ' AND a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id ';
    END IF;
    IF l_cat_id is null then
      l_inner := l_inner || ' AND a.category_id = -9 ';
    else
      l_inner := l_inner ||' AND a.category_id = edh.child_id AND edh.object_type = ''CATEGORY_SET''  AND edh.object_id = mdcs.category_set_id  AND mdcs.functional_area_id = 11 AND edh.dbi_flag = ''Y''   AND edh.parent_id = :l_cat_id ';
    end if;
    l_inner := l_inner || ' ) inr ';
--    l_inr_cond := ' and a.object_id= inr.object_id  and a.object_type=inr.object_type ';
    l_inr_cond := ' and inr.source_code_id = a.source_code_id  ';
    /************ End Inner Query to get current acitve objects *************************/
    /** to add meaning in select clause only in case of campaign view by */
    IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
      l_meaning   := ',meaning ';
      l_filtercol := ',meaning ';
    ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
      l_filtercol := ',leaf_node_flag ';
      l_meaning   := ' ,null meaning';
    else
      l_meaning := ' ,null meaning ';
    end if;
    /*** to  assigned URL **/
    if l_campaign_id is not null then
      -- checking for the object type passed from page
      for i in get_obj_type loop
        l_object_type := i.object_type;
      end loop;
    end if;
      l_url_str  :='pFunctionName=BIM_I_MKTG_RESP_SUM_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
   --l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

    IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
      l_url_link       := ' ,decode(leaf_node_flag,''Y'',null,' || '''' ||l_url_str || '''' || ' ) ';
      l_view_disp      := ' viewby';
      l_leaf_node_flag := ' ,leaf_node_flag ';
    ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
      l_camp_sel_col     := ',object_id,object_type ';
      l_camp_groupby_col := ',object_id,object_type ';
      l_url_link         := ' ,null ';
      l_view_disp        := 'viewby';
      IF (l_campaign_id is null or l_object_type = 'RCAM') then
        l_url_camp1 := ', decode(object_type,''EONE'',NULL,' || '''' ||l_url_str || '''' || ' )';
      ELSIF l_object_type = 'CAMP' THEN
        l_url_camp2        := ', ' || '''' || l_url_str_type || '''' ||'||object_id';
		--l_url_camp1        := ', decode(usage,''LITE'',' || '''' ||l_url_str_csch || '''' || '||object_id,' || '''' ||
          ---                    l_url_str_csch_jtf || '''' || '||object_id)';
		l_url_camp1        := ', '|| '''' ||l_url_str_csch || '''' || '||object_id ';

        l_csch_chnl        := '|| '' - '' || channel';
        l_camp_sel_col     := l_camp_sel_col || ',usage,channel';
        l_camp_groupby_col := l_camp_groupby_col || ',usage,channel';
      end if;
    ELSE
      l_url_link  := ' ,null ';
      l_view_disp := 'viewby';
    END IF;
    /* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
--------------------------------------------------------------------------------------------------
---------------------common part of top of the query
--------------------------------------------------------------------------------------------------
    l_select_cal := '
SELECT ' || l_view_disp || ', viewbyid, BIM_ATTRIBUTE1' ||
                    l_csch_chnl ||
                    '   BIM_ATTRIBUTE1 , BIM_ATTRIBUTE2  ,BIM_ATTRIBUTE3 , BIM_ATTRIBUTE11, BIM_ATTRIBUTE4 , BIM_ATTRIBUTE5 , BIM_ATTRIBUTE6
 , decode(p_cpr,0,NULL,((BIM_ATTRIBUTE6-p_cpr)/p_cpr)*100) BIM_ATTRIBUTE7  ' ||
                    l_url_link || ' bim_url1' || l_url_camp1 ||
                    ' bim_url2 ' || l_url_camp2 ||
                    ' bim_url3, BIM_GRAND_TOTAL1 , BIM_GRAND_TOTAL2
  ,BIM_GRAND_TOTAL3,  BIM_GRAND_TOTAL4 ,BIM_GRAND_TOTAL5 ,BIM_GRAND_TOTAL6,decode(p_cpr_tot,0,NULL,((BIM_GRAND_TOTAL6-p_cpr_tot)/p_cpr_tot)*100) BIM_GRAND_TOTAL7
FROM
( SELECT
 name   VIEWBY ,  VIEWBYID  ,meaning BIM_ATTRIBUTE1' ||
                    l_camp_sel_col || ' , total_forecast BIM_ATTRIBUTE2,decode(total_forecast,0,NULL,((total_response-total_forecast)/total_forecast)*100) BIM_ATTRIBUTE3
, total_response BIM_ATTRIBUTE4 , ptd_response BIM_ATTRIBUTE11 ,decode(prev_ptd_response,0,NULL,((ptd_response-prev_ptd_response)/prev_ptd_response)*100) BIM_ATTRIBUTE5
,  decode(ptd_response,0,NULL,ptd_cost/ptd_response) BIM_ATTRIBUTE6 , decode(prev_ptd_response,0,NULL,prev_ptd_cost/prev_ptd_response) p_cpr, decode(SUM(prev_ptd_response) over(),0,NULL,
SUM(prev_ptd_cost) over()/SUM(prev_ptd_response) over()) p_cpr_tot ,sum(total_forecast) over() BIM_GRAND_TOTAL1,decode(sum(total_forecast) over(),0,NULL,(((sum(total_response-total_forecast) over())/sum(total_forecast) over())*100)) BIM_GRAND_TOTAL2
,sum(ptd_response) over() BIM_GRAND_TOTAL3 ,sum(total_response) over() BIM_GRAND_TOTAL4 , decode(sum(prev_ptd_response) over(),0,NULL,(((sum(ptd_response-prev_ptd_response) over())/sum(prev_ptd_response) over())*100)) BIM_GRAND_TOTAL5
, decode(sum(ptd_response) over(),0,NULL,sum(ptd_cost) over()/sum(ptd_response) over()) BIM_GRAND_TOTAL6     , 111 BIM_GRAND_TOTAL7
FROM
(     SELECT   viewbyid    ,name' || l_meaning ||
                    l_camp_sel_col || ',
 decode(''' || l_prog_cost ||
                    ''',''BIM_APPROVED_BUDGET'',SUM(budget_approved),SUM(ptd_cost))   ptd_cost
  ,   SUM(ptd_response) ptd_response  , case when SUM(ptd_response) > 0 then  SUM(total_forecast) else 0  end total_forecast ,  decode(''' ||
                    l_prog_cost ||
                    ''',''BIM_APPROVED_BUDGET'',SUM(p_budget_approved),SUM(p_ptd_cost)) Prev_PTD_cost
 ,    SUM(p_ptd_response) Prev_PTD_response	 ,    case when SUM(ptd_response) > 0 then decode(''' ||
                    l_prog_cost || ''',''BIM_APPROVED_BUDGET'',SUM(t_budget_approved),SUM(total_cost))		     else 0 end   total_cost
 ,   case when SUM(ptd_response)>0 then   Sum(total_response)	  else 0 end total_response
 FROM ( ';
--------------------------------------------------------------------------------
--------------------- End common part of top of the query  ---------------------
--------------------------------------------------------------------------------
    /*  change this  below query  */


    l_select_cal1 := ' SELECT ' || l_view_disp ||' ,viewbyid  ,BIM_ATTRIBUTE1
 	  ,BIM_ATTRIBUTE2 	  ,BIM_ATTRIBUTE3          ,BIM_ATTRIBUTE11	  ,BIM_ATTRIBUTE4
 	  ,BIM_ATTRIBUTE5 	  ,BIM_ATTRIBUTE6
 	  ,decode(p_cpr,0,NULL,((BIM_ATTRIBUTE6-p_cpr)/p_cpr)*100) BIM_ATTRIBUTE7' ||
                     l_url_link || ' bim_url1' || '
	  ,null BIM_URL2
 	  ,null BIM_URL3
	  ,BIM_GRAND_TOTAL1
          ,BIM_GRAND_TOTAL2
 	  ,BIM_GRAND_TOTAL3
 	  ,BIM_GRAND_TOTAL4
 	  ,BIM_GRAND_TOTAL5
 	  ,BIM_GRAND_TOTAL6
          ,decode(p_cpr_tot,0,NULL,((BIM_GRAND_TOTAL6-p_cpr_tot)/p_cpr_tot)*100) BIM_GRAND_TOTAL7
      FROM
	 (
            SELECT
            name    VIEWBY' || l_leaf_node_flag || ',
     	    VIEWBYID,
            meaning BIM_ATTRIBUTE1,
	    total_forecast BIM_ATTRIBUTE2,
            decode(total_forecast,0,NULL,((total_response-total_forecast)/total_forecast)*100) BIM_ATTRIBUTE3,
	    total_response BIM_ATTRIBUTE4,
	    ptd_response BIM_ATTRIBUTE11,
            decode(prev_ptd_response,0,NULL,((ptd_response-prev_ptd_response)/prev_ptd_response)*100) BIM_ATTRIBUTE5,
	    decode(ptd_response,0,NULL,ptd_cost/ptd_response) BIM_ATTRIBUTE6,
            decode(prev_ptd_response,0,NULL,prev_ptd_cost/prev_ptd_response) p_cpr,
            decode(SUM(prev_ptd_response) over(),0,NULL,SUM(prev_ptd_cost) over()/SUM(prev_ptd_response) over()) p_cpr_tot,
  	    sum(total_forecast) over() BIM_GRAND_TOTAL1,
	    decode(sum(total_forecast) over(),0,NULL,(((sum(total_response-total_forecast) over())/sum(total_forecast) over())*100)) BIM_GRAND_TOTAL2,
            sum(ptd_response) over() BIM_GRAND_TOTAL3,
            sum(total_response) over() BIM_GRAND_TOTAL4,
            decode(sum(prev_ptd_response) over(),0,NULL,(((sum(ptd_response-prev_ptd_response) over())/sum(prev_ptd_response) over())*100)) BIM_GRAND_TOTAL5,
            decode(sum(ptd_response) over(),0,NULL,sum(ptd_cost) over()/sum(ptd_response) over()) BIM_GRAND_TOTAL6,
            111 BIM_GRAND_TOTAL7
             FROM
              (
                  SELECT
          	     viewbyid
          	   ,  name' || l_meaning || l_leaf_node_flag ||
                     ', decode(''' || l_prog_cost || ''',''BIM_APPROVED_BUDGET'',SUM(budget_approved),SUM(ptd_cost))  ptd_cost
		   ,  SUM(ptd_response) ptd_response
                   ,   SUM(total_forecast)  total_forecast
		   ,  decode(''' || l_prog_cost || ''',''BIM_APPROVED_BUDGET'',SUM(p_budget_approved),SUM(p_ptd_cost)) Prev_PTD_cost
		   ,  SUM(p_ptd_response) Prev_PTD_response
		   ,  decode(''' || l_prog_cost || ''',''BIM_APPROVED_BUDGET'',SUM(t_budget_approved),SUM(total_cost)) total_cost
		  ,   sum(total_response) total_response
                  FROM
          	  ( ';
    /* l_select1 and l_select2 contains column information common to all select statement for all view by */

	IF l_object_type in ('CAMP','EVEH','CSCH') AND l_prog_cost ='BIM_APPROVED_BUDGET' and l_view_by = 'CAMPAIGN+CAMPAIGN' THEN

		--l_table_bud :=  ' ,bim_i_marketing_facts facts';
		--l_where_bud := ' AND facts.source_code_id = a.source_code_id';

		IF l_curr_suffix is null THEN
			l_prog_cost1 := 'a.budget_approved_sch';
		ELSE
			l_curr_suffix1 := null;
			l_prog_cost1 := 'a.budget_approved_sch_s';

		END IF;

	ELSE

		l_prog_cost1 :='a.budget_approved';

	END IF;

l_select1:=' , SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.responses_positive else 0 end) ptd_response,SUM(case when (cal.report_date=&BIS_CURRENT_ASOF_DATE ) then a.actual_cost'||l_curr_suffix||' else 0 end) ptd_cost,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.responses_forecasted else 0 end) ptd_forecast,SUM(case when (cal.report_date=&BIS_CURRENT_ASOF_DATE ) then a.budget_approved'||l_curr_suffix||' else 0 end) budget_approved,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.responses_positive else 0 end) p_ptd_response,SUM(case when (cal.report_date=&BIS_PREVIOUS_ASOF_DATE ) then a.actual_cost'||l_curr_suffix||' else 0 end) p_ptd_cost,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.responses_forecasted else 0 end) p_ptd_forecast,SUM(case when (cal.report_date=&BIS_PREVIOUS_ASOF_DATE )then '||l_prog_cost1||l_curr_suffix1||' else 0 end)
p_budget_approved,0 total_cost,0 total_forecast,0 t_budget_approved,0 total_response ';
 l_select2 := ' ,0  ptd_response,0 ptd_cost,0 ptd_forecast,0 budget_approved,0  p_ptd_response,0 p_ptd_cost,0 p_ptd_forecast,0  p_budget_approved,
SUM(a.actual_cost'||l_curr_suffix||') total_cost,SUM(a.responses_forecasted) total_forecast,SUM('||l_prog_cost1||l_curr_suffix1||') t_budget_approved,SUM(a.responses_positive)  total_response ';
    /* l_from contains time dimension table common to all select statement for all view by */
l_from := ',fii_time_rpt_struct_v cal ';
    /* l_where contains where clause to join time dimension table common to all select statement for all view by */
l_where := ' WHERE a.time_id = cal.time_id AND  a.period_type_id = cal.period_type_id  AND  cal.calendar_id= -1 ';
    /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */
l_select_filter := ' ) GROUP BY viewbyid,name ' || l_filtercol ||l_camp_groupby_col || ')
			  	     ) WHERE bim_attribute11 <> 0  ';
    /* get_admin_status to check current user is admin or not */
    l_admin_status := get_admin_status;
    /*********************** security handling ***********************/

	IF l_campaign_id is null THEN

		/******* no security checking at child level ********/
		IF l_admin_status = 'N' THEN
			IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
			/*************** program view is enable **************/
				IF l_prog_view = 'Y' then
					l_view := ',''RCAM''';
					l_from := l_from || ',bim_i_top_objects   ac ';
					l_where := l_where ||' AND a.source_code_id=ac.source_code_id
					AND ac.resource_id = :l_resource_id ';
					/************************************************/
				ELSE
					l_from := l_from ||',bim_i_top_objects ac,bim_i_source_codes src ';
					l_where := l_where ||' AND a.source_code_id=src.source_code_id
					AND a.source_code_id = ac.source_code_id
					AND ac.resource_id = :l_resource_id
					AND src.object_type NOT IN (''RCAM'')';
				END IF;

			ELSE
				l_from := l_from ||',bim_i_top_objects ac ';
				l_where := l_where ||' AND a.source_code_id=ac.source_code_id
				AND ac.resource_id = :l_resource_id ';

			END IF;

		ELSE

			IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
				IF l_prog_view = 'Y' THEN

					l_view     := ',''RCAM''';
					l_top_cond := ' AND a.immediate_parent_id is null ';

				ELSE
					l_top_cond := ' AND name.object_type NOT IN (''RCAM'')';

				END IF;

			ELSE
				/******** to append parent object id is null for other view by (country and product category) ***/
				l_top_cond := ' AND a.immediate_parent_id is null ';
				/***********/
			END IF;
		END IF;
	END IF;
    /************************************************************************/
    /* product category handling */
    IF l_cat_id is not null then
      l_pc_from  := ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
      l_pc_where := ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
    ELSE
      l_pc_where := ' AND a.category_id = -9 ';
    END IF;
    /********************************/
    IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
      /* forming from clause for the tables which is common to all union all */
      if l_cat_id is not null then
        l_from := ' FROM BIM_I_CPB_METS_MV a ' || l_from ||l_pc_from;
      else
        l_from := ' FROM BIM_I_CPB_METS_MV a ' || l_from;
      end if;
      /* forming where clause which is common to all union all */
      l_where := l_where || ' AND a.object_country = :l_country ' || l_pc_where;
      /* forming group by clause for the common columns for all union all */
      l_groupby := ' GROUP BY a.source_code_id,name.object_type_mean, ';
      /*** campaign id null means No drill down and view by is camapign hirerachy*/
      IF l_campaign_id is null THEN
        /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
        l_sqltext := l_select_cal ||
                    /******** inner select start from here */
    		   ' SELECT a.source_code_id VIEWBYID, name.name name, NAME.object_id object_id, NAME.object_type object_type,  name.object_type_mean meaning ' ||
                     l_select1 || l_from || ' ,bim_i_obj_name_mv name ' ||
                     l_where || l_top_cond ||
                     ' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
 					   AND a.source_code_id = name.source_code_id
				       AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
				       AND NAME.language=USERENV(''LANG'')' || l_groupby ||
                     ' name.name,name.object_id,name.object_type' ||
               ' UNION ALL
  			     SELECT a.source_code_id VIEWBYID, name.name name, name.object_id object_id, name.object_type object_type,
      				  name.object_type_mean meaning ' || l_select2 || l_from ||
                      ' ,bim_i_obj_name_mv name ' || l_where ||
                      l_top_cond || ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
				      AND a.source_code_id = name.source_code_id
				      AND cal.report_date = trunc(sysdate)
				      AND NAME.language=USERENV(''LANG'')' || l_groupby ||
                     ' name.name,name.object_id,name.object_type'
		        ||l_select_filter;
      ELSE
        /* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
        /* appending table in l_form and joining conditon for the bim_i_source_codes */

	IF l_object_type='CAMP' then

		l_sqltext := l_select_cal ||
			    /******** inner select start from here */
			   ' SELECT a.source_code_id VIEWBYID, name.name name, NAME.object_id object_id,
NAME.object_type object_type,  name.object_type_mean meaning ,decode(name.activity_id,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',name.activity_id) channel ,
name.child_object_usage usage ' ||
			     l_select1 || l_from ||' ,bim_i_obj_name_mv name , bim_dimv_media chnl ' ||
			     l_where || l_top_cond ||
			     ' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
						   AND a.source_code_id = name.source_code_id
						   AND name.activity_id =chnl.id (+)
						   AND immediate_parent_id = '||l_campaign_id||'
					       AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
					       AND NAME.language=USERENV(''LANG'')' || l_groupby ||
			     ' name.name,name.object_id,name.object_type , decode(name.activity_id,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',name.activity_id) , name.child_object_usage ' ||
		       ' UNION ALL
				     SELECT a.source_code_id VIEWBYID, name.name name, name.object_id object_id, name.object_type object_type,
					  name.object_type_mean meaning ,decode(name.activity_id,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',name.activity_id) channel , name.child_object_usage usage ' || l_select2 || l_from ||
			      ' ,bim_i_obj_name_mv name , bim_dimv_media chnl '
			      || l_where || l_top_cond ||
			      ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
					      AND a.source_code_id = name.source_code_id
					      AND name.activity_id =chnl.id (+)
					      AND immediate_parent_id = '||l_campaign_id||'
					      AND cal.report_date = trunc(sysdate)
					      AND NAME.language=USERENV(''LANG'')' || l_groupby ||
			     ' name.name,name.object_id,name.object_type , decode(name.activity_id,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',name.activity_id) , name.child_object_usage '
				||l_select_filter;
	ELSE
		l_sqltext := l_select_cal ||
			    /******** inner select start from here */
			   ' SELECT a.source_code_id VIEWBYID, name.name name, NAME.object_id object_id, NAME.object_type object_type,  name.object_type_mean meaning ' ||
			     l_select1 || l_from || ' ,bim_i_obj_name_mv name ' ||
			     l_where || l_top_cond ||
			     ' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
						   AND a.source_code_id = name.source_code_id
						   AND immediate_parent_id = '||l_campaign_id||'
					       AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
					       AND NAME.language=USERENV(''LANG'')' || l_groupby ||
			     ' name.name,name.object_id,name.object_type' ||
		       ' UNION ALL
				     SELECT a.source_code_id VIEWBYID, name.name name, name.object_id object_id, name.object_type object_type,
					  name.object_type_mean meaning ' || l_select2 || l_from ||
			      ' ,bim_i_obj_name_mv name ' || l_where ||
			      l_top_cond || ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
					      AND a.source_code_id = name.source_code_id
					      AND immediate_parent_id = '||l_campaign_id||'
					      AND cal.report_date = trunc(sysdate)
					      AND NAME.language=USERENV(''LANG'')' || l_groupby ||
			     ' name.name,name.object_id,name.object_type'
				||l_select_filter;
	END IF;
      END IF;
    ELSE
      /* view by is product category */
      IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
        if l_admin_status = 'N' then
          l_from := replace(l_from, ',fii_time_rpt_struct_v cal');
        else
          l_from := null;
        end if;
        /******** handling product category hirerachy ****/
        /* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
        IF l_cat_id is null then
          l_from := l_from ||',eni_denorm_hierarchies edh ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
          l_where   := l_where ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id
			   AND a.source_code_id = name.source_code_id ';
          l_col     := ' SELECT  /*+ORDERED*/ p.value name, p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
          l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag ';
        ELSE
          /* passing id from page and getting immediate child to build hirerachy  */
          /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/
          l_pc_from := l_from || ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';
          l_pc_where := l_where || ' AND a.category_id = p.id ';
          l_from := l_from || ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';
          l_where := l_where || '
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id
		  AND a.source_code_id = name.source_code_id ';
          l_col     := ' SELECT /*+ORDERED*/
		   p.value name,
                   p.id    viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null    meaning ';
          l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
        END IF;
        /*********************/
        IF l_campaign_id is null then
          /* no drilll down in campaign hirerachy */
          IF l_admin_status = 'Y' THEN
            l_from  := ' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a,bim_i_obj_name_mv name ' || l_from;
            l_where := l_where || l_top_cond ||
                       '   AND  a.object_country = :l_country';
            IF l_cat_id is not null then
              l_pc_from  := ' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a,bim_i_obj_name_mv name ' || l_pc_from;
              l_pc_where := l_pc_where || l_top_cond ||
                            ' AND  a.object_country = :l_country';
            END IF;
          ELSE
            l_from  := ' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a,bim_i_obj_name_mv name ' || l_from;
            l_where := l_where ||
                      /*                         ' AND a.immediate_parent_id is null               */
                       ' AND  a.object_country = :l_country';
            IF l_cat_id is not null then
              l_pc_from  := ' FROM fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a,bim_i_obj_name_mv name  ' || l_pc_from;
              l_pc_where := l_pc_where ||
                           /*      ' AND a.immediate_parent_id is null   */
                            '   AND  a.object_country = :l_country';
            END IF;
          END IF;
        ELSE
          l_from  := ' FROM   fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a ,bim_i_obj_name_mv name ' ||l_from;
          l_where := l_where || '  AND  a.source_code_id = :l_campaign_id  AND  a.object_country = :l_country';
          IF l_cat_id is not null then
            l_pc_from  := ' FROM   fii_time_rpt_struct_v cal,BIM_I_CPB_METS_MV a,bim_i_obj_name_mv name ' ||l_pc_from;
            l_pc_where := l_pc_where ||'  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country';
          END IF;
        END IF;
        /* building l_pc_select to get values directly assigned to product category passed from the page */
        IF l_cat_id is not null THEN
          l_pc_col     := ' SELECT /*+ORDERED*/
		   bim_pmv_dbi_utl_pkg.get_lookup_value(' || '''' ||
                          'DASS' || '''' || ')' || ' name,
                   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
          l_pc_groupby := ' GROUP BY p.id ';
          l_pc_select := ' UNION ALL ' || l_pc_col || l_select2 ||
                         l_pc_from || l_pc_where ||
                         ' AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) ' ||
                         'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id  ' ||
                         l_pc_groupby || ' UNION ALL ' || l_pc_col ||
                         l_select2 || l_pc_from || l_inner || l_pc_where ||
                         ' AND cal.report_date =  trunc(sysdate) ' ||
                         'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  ' ||
                         l_inr_cond || l_pc_groupby;
        END IF;
      ELSIF (l_view_by = 'GEOGRAPHY+COUNTRY') THEN
  	     l_inr_cond := ' and a.source_code_id = inr.source_code_id ';
        /** product category handling**/
        IF l_cat_id is null then
          l_where := l_where || l_pc_where;
        ELSE
          l_from  := l_from || l_pc_from;
          l_where := l_where || l_pc_where;
        END IF;
        l_col     := ' SELECT  decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value(' || '''' ||
                     'UNA' || '''' || ')' || ',d.TERRITORY_SHORT_NAME) name, a.object_country viewbyid, null meaning ';
        l_groupby := ' GROUP BY  decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value(' || '''' ||
                     'UNA' || '''' || ')' ||',d.TERRITORY_SHORT_NAME),a.object_country ';
        l_from    := ' FROM fnd_territories_tl  d ' || l_from;
        IF l_campaign_id is null then
          IF l_admin_status = 'Y' THEN
            l_from  := l_from || ' ,BIM_I_CPB_METS_MV a ';
            l_where := l_where || l_top_cond ||' AND  a.object_country =d.territory_code(+) AND D.language(+) = userenv(''LANG'') ';
          ELSE
            l_from  := l_from || ' ,BIM_I_CPB_METS_MV a ';
            l_where := l_where ||'  AND  a.object_country =d.territory_code(+)  AND D.language(+) = userenv(''LANG'') ';
          END IF;
        ELSE
          l_from  := l_from || ' ,BIM_I_CPB_METS_MV a ';
          l_where := l_where ||'  AND  a.source_code_id = :l_campaign_id AND  a.object_country =d.territory_code(+) AND D.language(+) = userenv(''LANG'') ';
        END IF;
        IF l_country <> 'N' THEN
          l_where := l_where || ' AND  a.object_country = :l_country';
        ELSE
          l_where := l_where || ' AND  a.object_country <> ''N''';
        END IF;

      ELSIF (l_view_by = 'MEDIA+MEDIA') THEN
        /** product category handling**/
        IF l_cat_id is null then
          l_where := l_where || l_pc_where;
        ELSE
          l_from  := l_from || l_pc_from;
          l_where := l_where || l_pc_where;
        END IF;
        l_col     := ' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value(' || '''' ||
                     'UNA' || '''' || ')' || ',d.value) name,
                     null viewbyid,
		     null meaning ';
        l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value(' || '''' ||
                     'UNA' || '''' || ')' || ',d.value) ';
        l_from    := ' FROM bim_dimv_media d ' || l_from;
        IF l_campaign_id is null then
          IF l_admin_status = 'Y' THEN
            /*l_from:=l_from||' ,bim_mkt_chnl_mv a ';*/
            /*        ,BIM_I_CPL_CHNL_MV  can't be used since object_id ,object_type is not present*/
            l_from  := l_from || ' ,BIM_I_CPB_CHNL_MV a ';
            l_where := l_where || '  AND  d.id (+)= a.activity_id
			   AND  a.immediate_parent_id is null
			   AND  a.object_country = :l_country';
          ELSE
            l_from  := l_from || ' ,BIM_I_CPB_CHNL_MV a ';
            l_where := l_where ||
                      /*   ' AND  a.immediate_parent_id is null           */
                       '  AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
          END IF;
        ELSE
          l_from  := l_from || ' ,BIM_I_CPB_CHNL_MV a ';
          l_where := l_where || '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
        END IF;

      ELSIF (l_view_by = 'GEOGRAPHY+AREA') THEN
        /** product category handling**/
        IF l_cat_id is null then
          l_where := l_where || l_pc_where;
        ELSE
          l_from  := l_from || l_pc_from;
          l_where := l_where || l_pc_where;
        END IF;
        l_col     := ' SELECT decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value(' || '''' ||
                     'UNA' || '''' || ')' || ',d.value) name, null viewbyid, null meaning ';
        l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value(' || '''' ||
                     'UNA' || '''' || ')' || ',d.value) ';
        l_from    := ' FROM bis_areas_v d ' || l_from;
        IF l_campaign_id is null then
          IF l_admin_status = 'Y' THEN
            /*        ,BIM_I_CPL_CHNL_MV  can't be used since object_id ,object_type is not present*/
            l_from  := l_from || ' ,BIM_I_CPB_REGN_MV a  ';
            l_where := l_where || '
				    AND  d.id (+)= a.object_region
			            AND  a.immediate_parent_id is null
			            AND  a.object_country = :l_country';
          ELSE
            l_from  := l_from || ' ,BIM_I_CPB_REGN_MV a  ';
            l_where := l_where ||
                      /*   ' AND  a.parent_object_id is null           */
                       '    AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
          END IF;
        ELSE
          l_from  := l_from || ' ,BIM_I_CPB_REGN_MV a ';
          l_where := l_where || ' AND  a.source_code_id = :l_campaign_id
			   AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
        END IF;
      END IF;
    /* combine sql one to pick up current period values and  sql two to pick previous period values */
      l_select := l_col || l_select1 || l_from || l_where ||
                  ' AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) ' ||
                  'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id ' ||
                  l_groupby || ' UNION ALL ' || l_col || l_select2 ||
                  l_from || l_inner || l_where ||
                  ' AND cal.report_date =  trunc(sysdate) ' ||
                  'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  ' ||
                  l_inr_cond || l_groupby || l_pc_select
     /* l_pc_select only applicable when product category is not all and view by is product category */
       ;
      /* prepare final sql */
      l_sqltext := l_select_cal1 || l_select || l_select_filter;
    END IF;
    x_custom_sql := l_sqltext;
    l_custom_rec.attribute_name      := ':l_record_type';
    l_custom_rec.attribute_value     := l_record_type_id;
    l_custom_rec.attribute_type      := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output(1) := l_custom_rec;
    l_custom_rec.attribute_name := ':l_resource_id';
    l_custom_rec.attribute_value := get_resource_id;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output(2) := l_custom_rec;
    l_custom_rec.attribute_name := ':l_admin_flag';
    l_custom_rec.attribute_value := get_admin_status;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output(3) := l_custom_rec;
    l_custom_rec.attribute_name := ':l_country';
    l_custom_rec.attribute_value := l_country;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output(4) := l_custom_rec;
    l_custom_rec.attribute_name := ':l_cat_id';
    l_custom_rec.attribute_value := l_cat_id;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output(5) := l_custom_rec;
    l_custom_rec.attribute_name := ':l_campaign_id';
    l_custom_rec.attribute_value := l_campaign_id;
    l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
    x_custom_output.EXTEND;
    x_custom_output(6) := l_custom_rec;
    write_debug('GET_RESP_SUM_SQL', 'QUERY', '_', l_sqltext);
  EXCEPTION
    WHEN OTHERS THEN
      l_sql_errm := SQLERRM;
      write_debug('GET_RESP_SUM_SQL', 'ERROR', l_sql_errm, l_sqltext);
  END GET_RESP_SUM_SQL;

PROCEDURE GET_RESP_RATE_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(200);
   l_pc_groupby                   VARCHAR2(200);
   l_view                         VARCHAR2 (20);
   l_comm_cols                    VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(1000);
   l_url_str_csch                 varchar2(1000);
   l_url_str_type                 varchar2(3000);
   l_url_str_csch_jtf             varchar2(3000);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_csch_chnl                    varchar2(100);
   l_top_cond                     VARCHAR2(100);
   l_comm_cols2                   VARCHAR2 (20000);
   l_meaning                      VARCHAR2 (20);
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                   bis_query_attributes;
   l_object_type                  varchar2(30);
   l_inner                        varchar2(5000);
   l_inr_cond                     varchar2(5000);
   l_p_inner                      varchar2(5000);
   l_p_inr_cond                   varchar2(5000);
   l_select_cal1                  VARCHAR2 (20000);
   l_select1                      VARCHAR2 (20000);
   l_select2                      VARCHAR2 (20000);
   l_select3                      VARCHAR2 (20000);
   l_url_str_tga                  varchar2(3000);
   l_camp_url                     varchar2(500);
   l_url_link                     varchar2(200);
   l_url_camp1                    varchar2(3000);
   l_url_camp2                    varchar2(3000);
   l_url_camp3                    varchar2(3000);
   l_dass                         varchar2(100);  -- variable to store value for  directly assigned lookup value
   l_leaf_node_flag               varchar2(25);   -- variable to store value leaf_node_flag column in case of product category
   l_curr VARCHAR2(50);
   l_curr_suffix VARCHAR2(50);
   l_col_id NUMBER;
   l_area VARCHAR2(300);
   l_report_name VARCHAR2(300);
   l_media VARCHAR2(300);
BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
  bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
   l_meaning:=' null meaning '; -- assigning default value
   l_url_camp1:=',null';
   l_url_camp2:=',null';
   l_url_camp3:=',null';
   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
/************Start Inner Query to get current acitve objects *************************/
l_inner:=', ( select distinct  name.object_id,name.object_type
from BIM_I_obj_METS_MV a, bim_i_obj_name_mv name
,fii_time_rpt_struct_v cal';
IF l_admin_status='N' THEN
  l_inner:=l_inner||',bim_i_top_objects  r ';
end if;
IF l_cat_id is not null then
  l_inner := l_inner ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;
 l_inner := l_inner || ' WHERE a.source_code_id = name.source_code_id
And a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id
AND cal.calendar_id=-1
AND cal.report_date   in (&BIS_CURRENT_ASOF_DATE)
AND a.object_country = :l_country
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
and (responses_positive >0)';

IF l_admin_status = 'N' THEN
  l_inner :=  l_inner||' AND a.source_code_id = r.source_code_id AND r.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_inner :=  l_inner ||' AND a.category_id = -9 ';
else
   l_inner :=  l_inner ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;
l_inner :=  l_inner ||' ) inr ';

l_inr_cond:='and name.object_id= inr.object_id
             and name.object_type=inr.object_type ';
/************ End Inner Query to get current acitve objects *************************/
/************Start Inner Query to get Previous  acitve objects *************************/
l_p_inner:=', ( select distinct  name.object_id,name.object_type
from BIM_I_obj_METS_MV a, bim_i_obj_name_mv name
,fii_time_rpt_struct_v cal';

IF l_admin_status='N' THEN
  l_p_inner:=l_p_inner||', bim_i_top_objects r ';
end if;

IF l_cat_id is not null then
  l_p_inner := l_p_inner ||',eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
end if;

 l_p_inner := l_p_inner || ' WHERE a.source_code_id = name.source_code_id
and a.time_id=cal.time_id
AND a.period_type_id=cal.period_type_id
AND cal.calendar_id=-1
AND cal.report_date   in (&BIS_PREVIOUS_ASOF_DATE)
AND a.object_country = :l_country
AND BITAND(cal.record_type_id,:l_record_type)=cal.record_type_id
and (responses_positive >0)';

IF l_admin_status = 'N' THEN
  l_p_inner :=  l_p_inner||' AND a.source_code_id  = r.source_code_id  AND r.resource_id = :l_resource_id ';
END IF;

IF l_cat_id is null then
 l_p_inner :=  l_p_inner ||' AND a.category_id = -9 ';
else
   l_p_inner :=  l_p_inner ||' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
  end if;

l_p_inner :=  l_p_inner ||' ) p_inr ';

l_p_inr_cond:='and name.object_id= p_inr.object_id   and name.object_type=p_inr.object_type ';
/************ End Inner Query to get Previous  acitve objects *************************/
/** to add meaning in select clause only in case of campaign view by */

  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' meaning ';
  l_filtercol:=',meaning ';
  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  l_filtercol:=',leaf_node_flag ';
  l_meaning:=' null meaning';
  else
  l_meaning:=' null meaning ';
  end if;

 if l_campaign_id is not null then
-- checking for the object type passed from page

 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;

end if;
   l_url_str_tga  :='pFunctionName=AMS_LIST_UPDATE_PG&retainAM=Y&MidTab=ChartsRN&addBreadCrumb=Y&NavMode=UPD&OAPB=AMS_AUDIENCE_USER_BRANDING&ListHeaderId=';
   l_url_str  :='pFunctionName=BIM_I_MKTG_RESP_RATE_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
 --  l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';
---------------------------------------------------------------------------
---------------------------------------------------------------------------
   IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
---------------------------------------------------------------------------
---------------------------------------------------------------------------
      l_url_link :=' ,decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) ';
      l_view_disp:='viewby';
      l_leaf_node_flag :=' ,leaf_node_flag ';
   ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
     l_camp_sel_col :=' ,object_id ,object_type   ';
     l_camp_groupby_col :=',object_id,object_type ';
     l_url_link := ' ,null ';
     l_view_disp := 'viewby';
     IF (l_campaign_id is  null or l_object_type='RCAM') then
	l_url_camp1:=', decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' )';
     ELSIF l_object_type='CAMP' THEN
	l_url_camp2:=', '||''''||l_url_str_type||''''||'||object_id';
    --  l_url_camp1:=',decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_csch_jtf||''''||'||object_id)';
    l_url_camp1 := ', '||''''||l_url_str_csch||''''||'||object_id ';
	l_url_camp3:=',decode(usage,''LITE'',decode(list_header_id,null,null,'||''''||l_url_str_tga||''''||'||list_header_id),NULL)';
	l_csch_chnl:='|| '' - '' || channel';
	l_camp_sel_col :=l_camp_sel_col|| ',usage,channel,list_header_id';
	l_camp_groupby_col :=l_camp_groupby_col||',usage,channel,list_header_id';
     end if;
    ELSE
     -- l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
      l_url_link:=' ,null ';
      l_view_disp:='viewby';
   END IF;
/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal :='
        SELECT '||
         l_view_disp ||'
	 , viewbyid
 	 ,  BIM_ATTRIBUTE1'||l_csch_chnl||'    BIM_ATTRIBUTE1
 	 , BIM_ATTRIBUTE2 ,BIM_ATTRIBUTE8 ,BIM_ATTRIBUTE5,BIM_ATTRIBUTE7
 	 ,RESPONSE_RATE BIM_ATTRIBUTE9
         , DECODE(PREV_RESPONSE_RATE,0,NULL,((RESPONSE_RATE - PREV_RESPONSE_RATE)/PREV_RESPONSE_RATE)*100) BIM_ATTRIBUTE10'||	 l_url_link || ' bim_url1'||	 l_url_camp1||
	 ' bim_url2 '||	 l_url_camp2||' bim_url3 '||
	 l_url_camp3||' BIM_URL4
	 , BIM_GRAND_TOTAL4 ,BIM_GRAND_TOTAL7, BIM_GRAND_TOTAL6, BIM_GRAND_TOTAL1 ,BIM_GRAND_TOTAL8
	 , decode(PREV_RESPONSE_RATE_TOT,0,null,((BIM_GRAND_TOTAL8- PREV_RESPONSE_RATE_TOT)/PREV_RESPONSE_RATE_TOT)*100) BIM_GRAND_TOTAL9
	 FROM
	 (
         SELECT  name    VIEWBY,
	    VIEWBYID,
            meaning BIM_ATTRIBUTE1'||l_camp_sel_col||' ,
            CUSTOMERS_TARGETED BIM_ATTRIBUTE5, total_response BIM_ATTRIBUTE7,
            ptd_response BIM_ATTRIBUTE2,DECODE(Prev_ptd_response,0,NULL,((ptd_response - Prev_ptd_response)/Prev_ptd_response)*100) BIM_ATTRIBUTE8,
            decode(CUSTOMERS_TARGETED,0,NULL,(total_response/CUSTOMERS_TARGETED)*100) RESPONSE_RATE,
            decode(P_CUSTOMERS_TARGETED,0,NULL,(prev_total_response/P_CUSTOMERS_TARGETED*100)) PREV_RESPONSE_RATE,
            decode(SUM(P_CUSTOMERS_TARGETED) OVER(),0,NULL,(SUM(prev_total_response) OVER()/SUM(P_CUSTOMERS_TARGETED) OVER() *100)) PREV_RESPONSE_RATE_TOT,
            sum(CUSTOMERS_TARGETED) over() BIM_GRAND_TOTAL4,sum(total_response) over() BIM_GRAND_TOTAL6,sum(ptd_response) over() BIM_GRAND_TOTAL1,
            decode(sum(Prev_ptd_response) over(),0,null,(((sum(ptd_response- Prev_ptd_response) over())/sum(Prev_ptd_response)over ())*100))     BIM_GRAND_TOTAL7,
            decode(sum(CUSTOMERS_TARGETED) over(),0,null,((sum(total_response) over()/sum(CUSTOMERS_TARGETED)over ())*100)) BIM_GRAND_TOTAL8
	     FROM
              (
                 SELECT viewbyid,name,'||l_meaning||l_camp_sel_col||  ',
		  SUM(ptd_response) ptd_response,case when SUM(ptd_response) > 0 then SUM(CUSTOMERS_TARGETED) else 0 end CUSTOMERS_TARGETED,
	          case when SUM(p_ptd_response) > 0 then SUM(CUSTOMERS_TARGETED) else 0 end P_CUSTOMERS_TARGETED,
                  SUM(p_ptd_response)      Prev_PTD_response,case when SUM(ptd_response)>0 then  Sum(total_response) else 0 end total_response  ,
		  case when SUM(p_ptd_response)>0 then Sum(total_response) else 0 end prev_total_response
             FROM
          	  ( ';
/*  change this  below query  */
l_select_cal1 :='
         SELECT '||
         l_view_disp ||'
	, viewbyid
 	 , BIM_ATTRIBUTE1 ,BIM_ATTRIBUTE8,BIM_ATTRIBUTE2,BIM_ATTRIBUTE5,BIM_ATTRIBUTE7,RESPONSE_RATE BIM_ATTRIBUTE9
       , decode(prev_response_rate,0,null,((response_rate - prev_response_rate)/prev_response_rate)*100) bim_attribute10'||
	  l_url_link|| ' bim_url1'||'
	  ,null BIM_URL2 ,null BIM_URL3 ,null BIM_URL4,BIM_GRAND_TOTAL4,BIM_GRAND_TOTAL7,BIM_GRAND_TOTAL1
 	 , BIM_GRAND_TOTAL6,BIM_GRAND_TOTAL8
          ,decode(PREV_RESPONSE_RATE_TOT,0,null,((BIM_GRAND_TOTAL8- PREV_RESPONSE_RATE_TOT)/PREV_RESPONSE_RATE_TOT)*100) BIM_GRAND_TOTAL9
	  FROM
	 (
            SELECT   name    VIEWBY'||l_leaf_node_flag||',
	    VIEWBYID,  meaning BIM_ATTRIBUTE1, CUSTOMERS_TARGETED BIM_ATTRIBUTE5, total_response BIM_ATTRIBUTE7,
            ptd_response BIM_ATTRIBUTE2, DECODE(Prev_ptd_response,0,NULL,((ptd_response - Prev_ptd_response)/Prev_ptd_response)*100) BIM_ATTRIBUTE8,
            decode(CUSTOMERS_TARGETED,0,NULL,(total_response/CUSTOMERS_TARGETED)*100) RESPONSE_RATE,
            decode(p_customers_targeted,0,NULL,(prev_total_response/(p_customers_targeted)*100)) PREV_RESPONSE_RATE,
            decode(SUM(p_customers_targeted) OVER(),0,NULL,(SUM(prev_total_response) OVER()/SUM(p_customers_targeted) OVER() *100)) PREV_RESPONSE_RATE_TOT,
            sum(CUSTOMERS_TARGETED) over() BIM_GRAND_TOTAL4,sum(total_response) over() BIM_GRAND_TOTAL6,sum(ptd_response) over() BIM_GRAND_TOTAL1,
            decode(sum(Prev_ptd_response) over(),0,null,(((sum(ptd_response- Prev_ptd_response) over())/sum(Prev_ptd_response)over ())*100)) BIM_GRAND_TOTAL7,
            decode(sum(CUSTOMERS_TARGETED) over(),0,null,((sum(total_response) over()/sum(CUSTOMERS_TARGETED)over ())*100)) BIM_GRAND_TOTAL8
	    FROM
              (
                 SELECT viewbyid, name,'||l_meaning||l_leaf_node_flag||
		 ', SUM(ptd_response) ptd_response,SUM(CUSTOMERS_TARGETED)  CUSTOMERS_TARGETED,
                 SUM(p_ptd_response) Prev_PTD_response, SUM(total_response)  total_response,
		 SUM ( prev_total_response)   prev_total_response  ,   SUM(p_customers_targeted) p_customers_targeted
             FROM
          	  ( ';
/* l_select1 and l_select2 contains column information common to all select statement for all view by */
l_select1:=
' , SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.responses_positive else 0 end) ptd_response,
SUM(case when cal.report_date=&BIS_CURRENT_ASOF_DATE then a.CUSTOMERS_TARGETED else 0 end) ptd_CUSTOMERS_TARGETED,
SUM(case when cal.report_date=&BIS_PREVIOUS_ASOF_DATE then a.responses_positive else 0 end) p_ptd_response,
0  customers_targeted,
0 total_response,
0  p_customers_targeted ,
0  prev_total_response ';
 l_select2 :=
                   ' ,0  ptd_response,
0 ptd_customers_targeted,
0  p_ptd_response,
sum(customers_targeted) customers_targeted,
SUM(responses_positive)  total_response,
0  p_customers_targeted ,
0  prev_total_response '   ;
l_select3 :=
                   ' ,0  ptd_response,
0  ptd_customers_targeted,
0  p_ptd_response,
0  customers_targeted,
0  total_response,
sum(customers_targeted)  p_customers_targeted ,
SUM(responses_positive)  prev_total_response '   ;
/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';
 /* l_where contains where clause to join time dimension table common to all select statement for all view by */
 l_where :=' WHERE a.time_id = cal.time_id
             AND  a.period_type_id = cal.period_type_id
            AND  cal.calendar_id= -1 ';
 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */
l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
                  ')
		   )
      WHERE
       bim_attribute2 <> 0
       or bim_attribute5 <> 0
        &ORDER_BY_CLAUSE ';
 /* get_admin_status to check current user is admin or not */
   l_admin_status := get_admin_status;
   /*********************** security handling ***********************/
     IF   l_campaign_id is null THEN /******* no security checking at child level ********/
     IF   l_admin_status = 'N' THEN
	  IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
	  /*************** program view is enable **************/
	     IF l_prog_view='Y' then
	        l_view := ',''RCAM''';
	        l_from := l_from ||',bim_i_top_objects   ac ';
			l_where := l_where ||' AND a.source_code_id=ac.source_code_id
	 		AND ac.resource_id = :l_resource_id ';
	  /************************************************/
	      ELSE
		l_from := l_from ||',ams_act_access_denorm ac,bim_i_source_codes src ';
		l_where := l_where ||' AND a.source_code_id=src.source_code_id
		AND src.object_id=ac.object_id
		AND src.object_type=ac.object_type
		AND ac.resource_id = :l_resource_id
		AND src.object_type NOT IN (''RCAM'')';
              END IF;
           ELSE
			l_from := l_from ||',bim_i_top_objects ac ';
			l_where := l_where ||' AND a.source_code_id=ac.source_code_id
			AND ac.resource_id = :l_resource_id ';
	  END IF;
	ELSE
	     IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
	        IF  l_prog_view='Y' THEN
				l_view := ',''RCAM''';
				l_top_cond :=' AND a.immediate_parent_id is null ';

			ELSE

				l_top_cond := ' AND name.object_type NOT IN (''RCAM'')';

		END IF;
	      ELSE
      	  /******** to append parent object id is null for other view by (country and product category) ***/
		l_top_cond :=' AND a.immediate_parent_id is null ';
	  /***********/
	      END IF;
       END IF;
   END IF;
/************************************************************************/
   /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;
/********************************/
---------------------------------------------------------------------------
---------------------------------------------------------------------------
    IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
---------------------------------------------------------------------------
---------------------------------------------------------------------------
     /* forming from clause for the tables which is common to all union all */
     if l_cat_id is not null then
     l_from :=' FROM BIM_I_obj_METS_MV a,bim_i_obj_name_mv name '||l_from||l_pc_from;
     else
     l_from :=' FROM BIM_I_obj_METS_MV a,bim_i_obj_name_mv name '||l_from;
     end if;
      /* forming where clause which is common to all union all */
     l_where :=l_where||' and a.source_code_id =name.source_code_id
		AND name.language=USERENV(''LANG'')
		AND a.object_country = :l_country '||
		 l_pc_where;
    /* forming group by clause for the common columns for all union all */
    l_groupby:=' GROUP BY a.source_code_id,name.object_type_mean,name.name,name.object_id,name.object_type ';
 /*** campaign id null means No drill down and view by is camapign hirerachy*/
  IF l_campaign_id is null THEN
   /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
     l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapigns and programs for current period values */
     ' SELECT
      a.source_code_id VIEWBYID,
      name.name name , name.object_id object_id, name.object_type object_type,
      name.object_type_mean meaning '||
      l_select1 ||
      l_from ||
     l_where ||l_top_cond||
    ' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
      AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
      l_groupby||
       ' UNION ALL      /* select to get camapigns and programs for previous period values */
     SELECT
      a.source_code_id VIEWBYID,
      name.name name , name.object_id object_id, name.object_type object_type,
      name.object_type_mean meaning '||
      l_select2 ||
      l_from ||
     l_where ||l_top_cond||
    ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
      AND cal.report_date =trunc(sysdate) '||
      l_groupby|| l_select_filter /* appending filter clause */
      ;
 ELSE
 /* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
/* appending table in l_form and joining conditon for the bim_i_source_codes */
     l_where :=l_where ||
              ' AND a.immediate_parent_id = :l_campaign_id ';
-- if program is selected from the page means it may have childern as programs,campaigns,events or one off events
 IF l_object_type in ('RCAM','EVEH') THEN
 /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
     l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapigns and programs for current period values */
     ' SELECT
      a.source_code_id VIEWBYID,
      name.name name , name.object_id object_id, name.object_type object_type,
      name.object_type_mean meaning '||
      l_select1 ||
      l_from ||
     l_where ||
    ' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
      AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)' ||
      l_groupby||
     ' UNION ALL      /* select to get camapigns and programs for previous period values */
     SELECT
      a.source_code_id VIEWBYID,
      name.name name , name.object_id object_id, name.object_type object_type,
      name.object_type_mean meaning '||
      l_select2 ||
      l_from ||
     l_where ||
    ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
      AND cal.report_date = trunc(sysdate)'||
      l_groupby||
      l_select_filter ;
      /*************** if object type is camp then childern are campaign schedules ***/
 ELSIF l_object_type='CAMP' THEN
	 l_sqltext:= l_select_cal||
	     /******** inner select start from here */
	     /* select to get camapign schedules for current period values */
	     ' SELECT
	      a.source_code_id VIEWBYID, name.object_id object_id, name.object_type object_type,
	      name.name name,
	      name.child_object_usage usage,
	      aal.list_header_id list_header_id,
              decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,
	      name.object_type_mean meaning '||
	      l_select1 ||
	      l_from || ' ,bim_dimv_media chnl,ams_act_lists aal '||
	     l_where ||
	    ' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
	      AND name.activity_id =chnl.id (+)
	      AND  name.object_id = aal.list_used_by_id (+)
              AND  aal.list_act_type(+) = ''TARGET''
              AND  aal.list_used_by(+) = ''CSCH''
	      AND cal.report_date  in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	      '||
	      l_groupby||
	      ' ,name.child_object_usage,aal.list_header_id,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
     ' UNION ALL      /* select to get camapign schedules for previous period values */
     SELECT
      a.source_code_id VIEWBYID, name.object_id object_id, name.object_type object_type,
      name.name name,
      name.child_object_usage usage,
      aal.list_header_id list_header_id,
      decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,
      name.object_type_mean meaning  '||
      l_select2 ||
      l_from || ' ,bim_dimv_media chnl,ams_act_lists aal  '||
     l_where ||
    ' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id
      AND name.activity_id =chnl.id (+)
      AND name.object_id = aal.list_used_by_id (+)
      AND  aal.list_act_type(+) = ''TARGET''
      AND  aal.list_used_by(+) = ''CSCH''
      AND cal.report_date = trunc(sysdate) '||
      l_groupby||
      ' ,name.child_object_usage,aal.list_header_id,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
      l_select_filter ;
 END IF;
 END IF;
 /***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/
 ELSE
 /* view by is product category */
---------------------------------------------------------------------------
---------------------------------------------------------------------------
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN
---------------------------------------------------------------------------
---------------------------------------------------------------------------
   if l_admin_status='N' then
     l_from:=replace(l_from,',fii_time_rpt_struct_v cal');
   else
     l_from:=null;
    end if;
/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.source_code_id = name.source_code_id
			   AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag ';
    ELSE
    /* passing id from page and getting immediate child to build hirerachy  */
    /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/
     l_pc_from:= l_from||
                   ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';
    l_pc_where :=l_where||
                      ' AND a.category_id = p.id ';
    l_from:= l_from||
            ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';
     l_where := l_where||' AND a.source_code_id = name.source_code_id
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id ';
     l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
    END IF;
/*********************/
           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
              l_from:=' FROM fii_time_rpt_struct_v cal,BIM_I_obj_METS_MV a,bim_i_obj_name_mv name
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '  And a.source_code_id =   name.source_code_id  AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,BIM_I_obj_METS_MV a,bim_i_obj_name_mv name
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||l_top_cond||
                         '  And a.source_code_id =   name.source_code_id AND  a.object_country = :l_country';
               END IF;
              ELSE
              l_from:=' FROM fii_time_rpt_struct_v cal,BIM_I_obj_METS_MV a,bim_i_obj_name_mv name
                             '||l_from;
              l_where := l_where ||
/*                         ' And a.source_code_id =   name.source_code_id
			    AND a.parent_object_id is null               */
			  '  And a.source_code_id =   name.source_code_id AND  a.object_country = :l_country';
		IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,BIM_I_obj_METS_MV a,bim_i_obj_name_mv name
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||
                   /*      ' AND a.parent_object_id is null   */
			'  And a.source_code_id =   name.source_code_id AND  a.object_country = :l_country';
               END IF;
              END IF;
           ELSE
              l_from := ' FROM   fii_time_rpt_struct_v cal,BIM_I_obj_METS_MV a,bim_i_obj_name_mv name '||l_from ;
              l_where  := l_where ||
                        '  And a.source_code_id =   name.source_code_id
                           AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then
	      l_pc_from := ' FROM  fii_time_rpt_struct_v cal, BIM_I_obj_METS_MV a,bim_i_obj_name_mv name '||l_pc_from ;
              l_pc_where  := l_pc_where ||
                        '  And a.source_code_id = Name.source_code_id
                           AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN
	  l_pc_col:=' SELECT  /*+ORDERED*/
		   bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
                   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.id ';
  l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_select1||
	      l_pc_from||
	      l_pc_where ||' AND cal.report_date in ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	                   'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
                    and a.responses_positive>0  '||
	      l_pc_groupby ||
	      ' UNION ALL ' ||
	      l_pc_col||
	      l_select2||
	      l_pc_from||l_inner||
	      l_pc_where ||' AND cal.report_date = trunc(sysdate) '||
	                   'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
			   l_inr_cond||
	      l_pc_groupby  ||
	        ' UNION ALL ' ||
	      l_pc_col||
	      l_select3||
	      l_pc_from||l_p_inner||
	      l_pc_where ||' AND cal.report_date = trunc(sysdate) '||
	                   'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
			  l_p_inr_cond||
	      l_pc_groupby;
   END IF;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
 ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
---------------------------------------------------------------------------
---------------------------------------------------------------------------
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
                     a.object_country viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country ';
    l_from:=' FROM fnd_territories_tl  d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,BIM_I_obj_METS_MV a ,bim_i_obj_name_mv name';
              l_where := l_where ||l_top_cond||
                         '   AND a.source_code_id = name.source_code_id
			 AND  a.object_country =d.territory_code(+)
			     AND D.language(+) = userenv(''LANG'') ';
              ELSE
              l_from:=l_from||' ,BIM_I_obj_METS_MV a,bim_i_obj_name_mv name ';
              l_where := l_where ||
	                 '   AND a.source_code_id = name.source_code_id
			 AND  a.object_country =d.territory_code(+)
			     AND D.language(+) = userenv(''LANG'') ';
              END IF;
            ELSE
              l_from := l_from||' ,BIM_I_obj_METS_MV a,bim_i_obj_name_mv name ';
              l_where  := l_where ||
                        '  AND	a.source_code_id = name.source_code_id
                           AND  a.source_code_id = :l_campaign_id
                           AND  a.object_country =d.territory_code(+)
			   AND D.language(+) = userenv(''LANG'') ';
	  END IF;
	  IF  l_country <>'N' THEN
	      l_where  := l_where ||' AND  a.object_country = :l_country';
          ELSE
	   l_where  := l_where ||' AND  a.object_country <> ''N''';
	  END IF;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
ELSIF (l_view_by ='MEDIA+MEDIA') THEN
---------------------------------------------------------------------------
---------------------------------------------------------------------------
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bim_dimv_media d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      /*l_from:=l_from||' ,bim_mkt_chnl_mv a';*/
/*	      ,BIM_I_CPL_CHNL_MV  can't be used since object_id ,object_type is not present*/
	      l_from:=l_from||' ,BIM_obj_CHNL_MV a,bim_i_obj_name_mv name ';
              l_where := l_where ||' AND a.source_code_id = name.source_code_id
			   AND  d.id (+)= a.activity_id
			   AND a.immediate_parent_id is null
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,BIM_obj_CHNL_MV  a,bim_i_obj_name_mv name ';
              l_where := l_where ||' AND a.source_code_id = name.source_code_id
			   AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,BIM_obj_CHNL_MV  a,bim_i_obj_name_mv name ';
              l_where  := l_where ||'  AND a.source_code_id = name.source_code_id
                           AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
	  END IF;
---------------------------------------------------------------------------
---------------------------------------------------------------------------
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
---------------------------------------------------------------------------
---------------------------------------------------------------------------
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bis_areas_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      /*l_from:=l_from||' ,bim_mkt_chnl_mv a ';*/
/*	      ,BIM_I_CPL_CHNL_MV  can't be used since object_id ,object_type is not present*/
	      l_from:=l_from||' ,BIM_obj_REGN_MV a,bim_i_obj_name_mv name ';
              l_where := l_where ||
                         ' AND a.source_code_id = name.source_code_id
			   AND  d.id (+)= a.object_region
			   AND  a.immediate_parent_id is null
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,BIM_obj_REGN_MV a,bim_i_obj_name_mv name ';
              l_where := l_where ||
	              /*   ' AND  a.parent_object_id is null           */
                         ' AND a.source_code_id = name.source_code_id
			   AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,BIM_obj_REGN_MV a,bim_i_obj_name_mv name';
              l_where  := l_where ||
                        '  AND a.source_code_id = name.source_code_id
                           AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
	  END IF;
END IF;
/* combine sql one to pick up current period values and  sql two to pick previous period values */
  l_select := l_col||
              l_select1||
	      l_from||
	      l_where ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	      'AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
          and a.responses_positive>0   '||
	      l_groupby ||
	      ' UNION ALL ' ||
	      l_col||
	      l_select2||
	      l_from||l_inner||
	      l_where ||' AND cal.report_date =trunc(sysdate) '||
	      'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
	      l_inr_cond||
	      l_groupby  /* ||
	       ' UNION ALL ' ||
	      l_col||
	      l_select3||
	      l_from|| l_p_inner||
	      l_where ||' AND cal.report_date =trunc(sysdate) '||
	      'AND  BITAND(cal.record_type_id,1143)= cal.record_type_id  '||
	      l_p_inr_cond||
	      l_groupby||
              l_pc_select*/ /* l_pc_select only applicable when product category is not all and view by is product category */
	      ;
/* prepare final sql */
 l_sqltext:= l_select_cal1||
             l_select||
	     l_select_filter;
  END IF;
   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_resource_id';
   l_custom_rec.attribute_value := get_resource_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_admin_flag';
   l_custom_rec.attribute_value := get_admin_status;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (3) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_country';
   l_custom_rec.attribute_value := l_country;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (4) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_cat_id';
   l_custom_rec.attribute_value := l_cat_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (5) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_campaign_id';
   l_custom_rec.attribute_value := l_campaign_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (6) := l_custom_rec;
   write_debug ('GET_RESP_RATE_SQL', 'QUERY', '_', l_sqltext);
EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_RESP_RATE_SQL', 'ERROR', l_sql_errm, l_sqltext);
END GET_RESP_RATE_SQL;


PROCEDURE GET_WON_OPTY_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(200);
   l_pc_groupby                   VARCHAR2(200);
   l_view                         VARCHAR2 (20);
   l_comm_cols                    VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(3000);
   l_url_str_csch                 varchar2(3000);
   l_url_str_csch_jtf             varchar2(3000);
   l_url_str_type                 varchar2(3000);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_csch_chnl                    varchar2(100);
   l_top_cond                     VARCHAR2(100);
   l_meaning                      VARCHAR2 (20);
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                   bis_query_attributes;
   l_object_type                  varchar2(30);
   l_url_link                     varchar2(200) ;
   l_url_camp1                    varchar2(3000);
   l_url_camp2                    varchar2(3000);
   l_dass                         varchar2(100);  -- variable to store value for  directly assigned lookup value
   l_leaf_node_flag               varchar2(100);   -- variable to store value leaf_node_flag column in case of product category
   l_curr VARCHAR2(50);
   l_curr_suffix VARCHAR2(50);
   l_col_id NUMBER;
   l_area VARCHAR2(300);
   l_report_name VARCHAR2(300);
   l_media VARCHAR2(300);
BEGIN
   x_custom_output := bis_query_attributes_tbl ();
   l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
bim_pmv_dbi_utl_pkg.get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_curr,
						      l_col_id,
						      l_area,
						      l_media,
						      l_report_name
				                      );
   l_meaning:=' null meaning '; -- assigning default value
   l_url_camp1:=',null';
   l_url_camp2:=',null';
IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;

   IF l_country IS NULL THEN
      l_country := 'N';
   END IF;
/** to add meaning in select clause only in case of campaign view by */
  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' ,meaning ';
  l_filtercol:=',meaning ';
  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
  l_filtercol:=',leaf_node_flag ';
  l_meaning:=',null meaning ';
  else
  l_meaning:=' ,null meaning ';
  end if;
   /*** to  assigned URL **/

if l_campaign_id is not null then
-- checking for the object type passed from page
 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;
end if;

   l_url_str  :='pFunctionName=BIM_I_MKTG_WON_OPTY&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
   ---l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objId=';
   l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&pParamIds=Y&VIEW_BY='||l_view_by||'&objType=CSCH&objId=';
   l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';
   l_url_str_csch_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&PAGE.OBJ.ID_NAME1=customSetupId&VIEW_BY_NAME=VIEW_BY_ID
   &PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
   l_url_link :=' ,decode(leaf_node_flag,''Y'',null,'||''''||l_url_str||''''||' ) ';
   l_view_disp:='viewby';
   l_leaf_node_flag :=' ,leaf_node_flag ';

 ELSIF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
     l_camp_sel_col :=' ,object_id
                       ,object_type
                       ';
     l_camp_groupby_col :=',object_id,object_type ';
     l_url_link := ' ,null ';
     l_view_disp := 'viewby';

     IF (l_campaign_id is  null or l_object_type='RCAM') then
	l_url_camp1:=', decode(object_type,''EONE'',NULL,'||''''||l_url_str||''''||' )';
     ELSIF l_object_type='CAMP' THEN
	l_url_camp2:=','||''''||l_url_str_type||''''||'||object_id';
	--l_url_camp1:=',decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_csch_jtf||''''||'||object_id)';
	l_url_camp1:=', '||''''||l_url_str_csch||''''||'||object_id ';
	l_csch_chnl:='|| '' - '' || channel';
	l_camp_sel_col :=l_camp_sel_col|| ',usage,channel';
	l_camp_groupby_col :=l_camp_groupby_col||',usage,channel';
     end if;
    ELSE
    --  l_una := BIM_PMV_DBI_UTL_PKG.GET_LOOKUP_VALUE('UNA');
      l_url_link:=' ,null ';
      l_view_disp:='viewby';
   END IF;

/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal :='
         SELECT '||
         l_view_disp ||'
	 ,viewbyid
 	 ,bim_attribute2'||l_csch_chnl ||' bim_attribute2
 	 ,bim_attribute3
 	 ,bim_attribute4
 	 ,bim_attribute5
 	 ,bim_attribute6
 	 ,bim_attribute7
 	 ,bim_attribute8
	 ,bim_attribute9
	 ,bim_attribute5 bim_attribute10
	 ,bim_attribute7 bim_attribute11
	 ,bim_attribute6 bim_attribute12
	 ,bim_attribute8 bim_attribute13
	 ,bim_attribute5 bim_attribute14
	 '||l_url_link||' bim_attribute19'||
	 l_url_camp1|| ' bim_attribute20 '||
	 l_url_camp2||' bim_attribute21
 	 ,bim_grand_total1
 	 ,bim_grand_total2
 	 ,bim_grand_total3
 	 ,bim_grand_total4
 	 ,bim_grand_total5
 	 ,bim_grand_total6
 	 ,bim_grand_total7
	 ,bim_grand_total3 bim_grand_total8
          FROM
	 (
            SELECT
            name    VIEWBY '||l_leaf_node_flag||'
            ,meaning BIM_ATTRIBUTE2'||l_camp_sel_col||
           ' ,new_opportunity_amt BIM_ATTRIBUTE3
            ,DECODE(prev_new_opportunity_amt,0,NULL,((new_opportunity_amt - prev_new_opportunity_amt)/prev_new_opportunity_amt)*100) BIM_ATTRIBUTE4
            ,won_opportunity_amt BIM_ATTRIBUTE5
            ,DECODE(prev_won_opportunity_amt,0,NULL,((won_opportunity_amt - prev_won_opportunity_amt)/prev_won_opportunity_amt)*100) BIM_ATTRIBUTE6
            ,lost_opportunity_amt BIM_ATTRIBUTE7
            ,DECODE(prev_lost_opportunity_amt,0,NULL,((lost_opportunity_amt - prev_lost_opportunity_amt)/prev_lost_opportunity_amt)*100) BIM_ATTRIBUTE8
            ,DECODE(lost_opportunity_amt,0,NULL,won_opportunity_amt/lost_opportunity_amt) BIM_ATTRIBUTE9
	    ,sum(new_opportunity_amt) over() BIM_GRAND_TOTAL1
	    ,case
              when sum(prev_new_opportunity_amt) over()=0 then null
              else
                   ((sum(new_opportunity_amt) over()-sum(prev_new_opportunity_amt) over ()) /sum(prev_new_opportunity_amt)over () )*100
            end  BIM_GRAND_TOTAL2
            ,sum(won_opportunity_amt) over() BIM_GRAND_TOTAL3
	    ,case
              when sum(prev_won_opportunity_amt) over()=0 then null
              else
                   ((sum(won_opportunity_amt) over()-sum(prev_won_opportunity_amt) over ()) /sum(prev_won_opportunity_amt)over () )*100
            end  BIM_GRAND_TOTAL4
            ,sum(lost_opportunity_amt) over() BIM_GRAND_TOTAL5
	    ,case
              when sum(prev_lost_opportunity_amt) over()=0 then null
              else
                   ((sum(lost_opportunity_amt) over()-sum(prev_lost_opportunity_amt) over ()) /sum(prev_lost_opportunity_amt)over () )*100
            end  BIM_GRAND_TOTAL6
            ,DECODE(sum(lost_opportunity_amt) over (),0,NULL,sum(won_opportunity_amt) over()/sum(lost_opportunity_amt)over()) BIM_GRAND_TOTAL7
	    ,VIEWBYID
             FROM
              (
                  SELECT
          	      viewbyid,
          	      name'||l_leaf_node_flag||
		      l_meaning||l_camp_sel_col||
		    ',sum(new_opportunity_amt)       new_opportunity_amt
          	      ,sum(won_opportunity_amt)       won_opportunity_amt
          	      ,sum(lost_opportunity_amt)      lost_opportunity_amt
          	      ,sum(prev_new_opportunity_amt)  prev_new_opportunity_amt
          	      ,sum(prev_won_opportunity_amt)  prev_won_opportunity_amt
          	      ,sum(prev_lost_opportunity_amt) prev_lost_opportunity_amt
                  FROM
          	  ( ';
/* l_comm_cols  contains column information common to all select statement for all view by */

l_comm_cols:=    ' , sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0))  new_opportunity_amt,
                   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.won_opportunity_amt'||l_curr_suffix||',0))  won_opportunity_amt,
     		   sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.lost_opportunity_amt'||l_curr_suffix||',0)) lost_opportunity_amt,
     		   sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.new_opportunity_amt'||l_curr_suffix||',0)) prev_new_opportunity_amt,
		   sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.won_opportunity_amt'||l_curr_suffix||',0)) prev_won_opportunity_amt,
		   sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,a.lost_opportunity_amt'||l_curr_suffix||',0)) prev_lost_opportunity_amt ';
/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';
 /* l_where contains where clause to join time dimension table common to all select statement for all view by */
 l_where :=' WHERE a.time_id = cal.time_id
             AND  a.period_type_id = cal.period_type_id
             AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id
             AND  cal.calendar_id= -1 ';
 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */
l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||l_camp_groupby_col||
                  ')
		   )
         WHERE
           bim_attribute3 <> 0
          or bim_attribute5 <> 0
          or bim_attribute7 <> 0
          &ORDER_BY_CLAUSE ';

   /* get_admin_status to check current user is admin or not */

   l_admin_status := get_admin_status;

/*********************** security handling ***********************/

      IF   l_campaign_id is null THEN /******* no security checking at child level ********/
     IF   l_admin_status = 'N' THEN
	  IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
	  /*************** program view is enable **************/
	     IF l_prog_view='Y' then
	        l_from := l_from ||',bim_i_top_objects ac ' ;
		 l_where := l_where ||' AND a.source_code_id=ac.source_code_id
		  AND ac.resource_id = :l_resource_id ';
	  /************************************************/
	      ELSE
	         l_from := l_from ||',ams_act_access_denorm ac,bim_i_source_codes src ';
		 l_where := l_where ||' AND a.source_code_id=src.source_code_id
		 AND src.object_id=ac.object_id
		 AND src.object_type=ac.object_type
		 AND src.object_type NOT IN (''RCAM'')
	     AND ac.resource_id = :l_resource_id ';
              END IF;
           ELSE
            l_from := l_from ||',bim_i_top_objects ac ';
            l_where := l_where ||' AND a.source_code_id=ac.source_code_id
	    AND ac.resource_id = :l_resource_id ';
	  END IF;
	ELSE
	     IF l_view_by = 'CAMPAIGN+CAMPAIGN' then
	        IF  l_prog_view='Y' THEN
		    l_top_cond :=' AND a.immediate_parent_id is null ';
		ELSE
			l_top_cond :=  ' AND name.object_type NOT IN (''RCAM'')';
		END IF;
	      ELSE
      	  /******** to append parent object id is null for other view by (country and product category) ***/
		l_top_cond := ' AND a.immediate_parent_id is null ';
	  /***********/
	      END IF;
       END IF;
   END IF;
/************************************************************************/

   /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets mdcs';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = mdcs.category_set_id
			   AND mdcs.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;
/********************************/

    IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN

     /* forming from clause for the tables which is common to all union all */
     if l_cat_id is not null then
     l_from :=' FROM bim_i_obj_mets_mv a,bim_i_obj_name_mv name '||l_from||l_pc_from;
     else
     l_from :=' FROM bim_i_obj_mets_mv a,bim_i_obj_name_mv name '||l_from;
     end if;


      /* forming where clause which is common to all union all */
     l_where :=l_where||' AND a.source_code_id = name.source_code_id
		 AND a.object_country = :l_country '||
		 l_pc_where;


    /* forming group by clause for the common columns for all union all */
    l_groupby:=' GROUP BY a.source_code_id,name.object_type_mean, ';

 /*** campaign id null means No drill down and view by is camapign hirerachy*/
  IF l_campaign_id is null THEN
   /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
     l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapigns and programs  */
     ' SELECT
      a.source_code_id VIEWBYID,
      name.name name,
       name.object_id object_id,
      name.object_type object_type,
      name.object_type_mean meaning '||
      l_comm_cols ||
      l_from ||
     l_where ||l_top_cond||
     ' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND name.language=USERENV(''LANG'')'||
      l_groupby||
      ' name.name,name.object_id,name.object_type'||
       l_select_filter /* appending filter clause */
      ;
 ELSE
 /* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
/* appending table in l_form and joining conditon for the bim_i_source_codes */

     l_where :=l_where ||' AND a.immediate_parent_id=:l_campaign_id ';

-- if program is selected from the page means it may have childern as programs,campaigns,events or one off events

 IF l_object_type in ('RCAM','EVEH') THEN
 /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
     l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapigns and programs  */
     ' SELECT
      a.source_code_id VIEWBYID,
      name.name name,
       name.object_id object_id,
      name.object_type object_type,
      name.object_type_mean meaning '||
      l_comm_cols ||
      l_from ||
     l_where ||
    ' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND name.language=USERENV(''LANG'')'||
      l_groupby||
      ' name.name,name.object_id,name.object_type'||
      l_select_filter ;
      /*************** if object type is camp then childern are campaign schedules ***/
 ELSIF l_object_type='CAMP' THEN
 l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapign schedules  */
     ' SELECT
      a.source_code_id VIEWBYID,
      name.name name,
      name.object_id object_id,
      name.object_type object_type,
      name.child_object_usage usage,
      decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value) channel,
      name.object_type_mean meaning '||
      l_comm_cols ||
      l_from || ' , bim_dimv_media chnl '||
     l_where ||
    ' AND name.activity_id =chnl.id (+)
      AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND name.language=USERENV(''LANG'')'||
      l_groupby||
      ' name.name,name.object_id,name.object_type,name.child_object_usage,decode(chnl.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',chnl.value)'||
      l_select_filter ;
 END IF;

 END IF;

 /***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/

 ELSE
 /* view by is product category */
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN
--changing l_from to have fii_time_rpt_struct_v first table in form clause to provide ordered hint in sql
  if l_admin_status='N' then
 l_from:=replace(l_from,',fii_time_rpt_struct_v cal');
 else
 l_from:=null;
 end if;
/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh
                ,mtl_default_category_sets mdcs
                ,( SELECT e.parent_id parent_id ,e.value value,e.leaf_node_flag leaf_node_flag
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = mdcs.category_set_id
                           AND mdcs.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.parent_id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id,p.leaf_node_flag ';
    ELSE
    /* passing id from page and getting immediate child to build hirerachy  */

    /** reassigning value to l_pc_from and l_pc_where for product category hirerachy drill down for values directly assigned to prodcut select from the page*/

     l_pc_from:= l_from||
                   ',(select e.id id,e.value value
                      from eni_item_vbh_nodes_v e
                      where e.parent_id =  :l_cat_id
                      AND e.parent_id = e.child_id
                      AND leaf_node_flag <> ''Y''
                      ) p ';

    l_pc_where :=l_where||
                      ' AND a.category_id = p.id ';

    l_from:= l_from||
            ',eni_denorm_hierarchies edh
            ,mtl_default_category_sets mdc
            ,(select e.id,e.value,e.leaf_node_flag leaf_node_flag
              from eni_item_vbh_nodes_v e
          where
              e.parent_id =:l_cat_id
              AND e.id = e.child_id
              AND((e.leaf_node_flag=''N'' AND e.parent_id<>e.id) OR e.leaf_node_flag=''Y'')
      ) p ';

     l_where := l_where||'
                  AND a.category_id = edh.child_id
                  AND edh.object_type = ''CATEGORY_SET''
                  AND edh.object_id = mdc.category_set_id
                  AND mdc.functional_area_id = 11
                  AND edh.dbi_flag = ''Y''
                  AND edh.parent_id = p.id ';

     l_col:=' SELECT /*+ORDERED*/
		   p.value name,
                   p.id viewbyid,
		   p.leaf_node_flag leaf_node_flag,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,p.id,p.leaf_node_flag ';
    END IF;
/*********************/

           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '  AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||l_top_cond||
                         ' AND  a.object_country = :l_country';
               END IF;
              ELSE
              l_from:=' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                             '||l_from;
              l_where := l_where ||
	                   ' AND  a.object_country = :l_country';

		IF l_cat_id is not null then
	          l_pc_from := ' FROM fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||
                         ' AND  a.object_country = :l_country';
               END IF;

              END IF;
           ELSE
              l_from := ' FROM   fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_from ;
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then
	      l_pc_from := ' FROM     fii_time_rpt_struct_v cal,bim_i_obj_mets_mv a '||l_pc_from ;
              l_pc_where  := l_pc_where ||
                        '  AND  a.source_code_id = :l_campaign_id
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN
       	  l_pc_col:=' SELECT /*+ORDERED*/
		   bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||' name,
                   p.id  viewbyid,
		   ''Y'' leaf_node_flag,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.id ';

  l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_comm_cols||
	      l_pc_from||
	      l_pc_where ||'  AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'||
	      l_pc_groupby ;
   END IF;
ELSIF (l_view_by ='GEOGRAPHY+COUNTRY') THEN
   /** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		     decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME) name,
                     a.object_country viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.TERRITORY_SHORT_NAME,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.TERRITORY_SHORT_NAME),a.object_country ';
    l_from:=' FROM fnd_territories_tl d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||l_top_cond||
                         ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'')';
              ELSE
              l_from:=l_from||' ,bim_i_obj_mets_mv a ';
              l_where := l_where ||
	                 ' AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'') ';
              END IF;
            ELSE
              l_from := l_from||' ,bim_i_obj_mets_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                          AND  a.object_country =d.territory_code(+) AND d.language(+) = userenv(''LANG'') ';
	  END IF;
	  IF  l_country <>'N' THEN
	      l_where  := l_where ||' AND  a.object_country = :l_country';
          ELSE
	   l_where  := l_where ||' AND  a.object_country <> ''N''';
	  END IF;
ELSIF (l_view_by ='MEDIA+MEDIA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bim_dimv_media d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_chnl_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_chnl_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_chnl_mv a ' ; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
	  END IF;
ELSIF (l_view_by ='GEOGRAPHY+AREA') THEN
/** product category handling**/
   IF l_cat_id is null then
     l_where := l_where ||l_pc_where;
  ELSE
     l_from  := l_from ||l_pc_from;
     l_where := l_where||l_pc_where;
  END IF;
    l_col:=' SELECT
		    decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) name,
                     null viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  decode(d.value,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.value) ';
    l_from:=' FROM bis_areas_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' ,bim_mkt_regn_mv a ';
              l_where := l_where ||
                         ' AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
              ELSE
              l_from:=l_from||' ,bim_obj_regn_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_regn_mv a '; --, bim_i_source_codes b ';
              l_where  := l_where ||
                        '  AND  a.source_code_id = :l_campaign_id
                           AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
	  END IF;
END IF;

/* combine sql one to pick up current period values and  sql two to pick previous period values */
  l_select := l_col||
              l_comm_cols||
	      l_from||
	      l_where ||' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE) '||
	      l_groupby ||
	      l_pc_select /* l_pc_select only applicable when product category is not all and view by is product category */
	      ;

/* prepare final sql */

 l_sqltext:= l_select_cal||
             l_select||
	     l_select_filter;
  END IF;
   x_custom_sql := l_sqltext;
   l_custom_rec.attribute_name := ':l_record_type';
   l_custom_rec.attribute_value := l_record_type_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (1) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_resource_id';
   l_custom_rec.attribute_value := get_resource_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (2) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_admin_flag';
   l_custom_rec.attribute_value := get_admin_status;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (3) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_country';
   l_custom_rec.attribute_value := l_country;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (4) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_cat_id';
   l_custom_rec.attribute_value := l_cat_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (5) := l_custom_rec;
   l_custom_rec.attribute_name := ':l_campaign_id';
   l_custom_rec.attribute_value := l_campaign_id;
   l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
   l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
   x_custom_output.EXTEND;
   x_custom_output (6) := l_custom_rec;
   write_debug ('GET_WON_OPTY_SQL', 'QUERY', '_', l_sqltext);
EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_WON_OPTY_SQL', 'ERROR', l_sql_errm, l_sqltext);
END get_won_opty_sql;



PROCEDURE BIM_MKTG_LEAD_ACT_SQL (
   p_page_parameter_tbl   IN              bis_pmv_page_parameter_tbl,
   x_custom_sql           OUT NOCOPY      VARCHAR2,
   x_custom_output        OUT NOCOPY      bis_query_attributes_tbl
)
IS
   l_sqltext                      VARCHAR2 (20000);
   iflag                          NUMBER;
   l_period_type_hc               NUMBER;
   l_as_of_date                   DATE;
   l_period_type                  VARCHAR2 (2000);
   l_record_type_id               NUMBER;
   l_comp_type                    VARCHAR2 (2000);
   l_country                      VARCHAR2 (4000);
   l_view_by                      VARCHAR2 (4000);
   l_sql_errm                     VARCHAR2 (4000);
   l_previous_report_start_date   DATE;
   l_current_report_start_date    DATE;
   l_previous_as_of_date          DATE;
   l_period_type_id               NUMBER;
   l_user_id                      NUMBER;
   l_resource_id                  NUMBER;
   l_time_id_column               VARCHAR2 (1000);
   l_admin_status                 VARCHAR2 (20);
   l_admin_flag                   VARCHAR2 (1);
   l_admin_count                  NUMBER;
   l_rsid                         NUMBER;
   l_curr_aod_str                 VARCHAR2 (80);
   l_country_clause               VARCHAR2 (4000);
   l_access_clause                VARCHAR2 (4000);
   l_access_table                 VARCHAR2 (4000);
   l_cat_id                       VARCHAR2 (50)        := NULL;
   l_campaign_id                  VARCHAR2 (50)        := NULL;
   l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
   l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
   l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
   l_select_filter                VARCHAR2 (20000); -- to build  select filter part
   l_from                         VARCHAR2 (20000);   -- assign common table in  clause
   l_where                        VARCHAR2 (20000);  -- static where clause
   l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
   l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
   l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
   l_filtercol                    VARCHAR2 (2000);
   l_pc_col                       VARCHAR2(100);
   l_pc_groupby                   VARCHAR2(200);
   l_view                         VARCHAR2 (20);
   l_comm_cols                    VARCHAR2 (20000);
   l_comm_cols2                   VARCHAR2 (20000);
   l_view_disp                    VARCHAR2(100);
   l_url_str                      VARCHAR2(1000);
   l_url_str_csch                 varchar2(1000);
   l_url_str_type                 varchar2(1000);
   l_camp_sel_col                 varchar2(100);
   l_camp_groupby_col             varchar2(100);
   l_csch_chnl                    varchar2(100);
   l_top_cond                     VARCHAR2(100);
   l_meaning                      VARCHAR2 (20);
   /* variables to hold columns names in l_select clauses */
   l_col                          VARCHAR2(1000);
   /* cursor to get type of object passed from the page ******/
    cursor get_obj_type
    is
    select object_type
    from bim_i_source_codes
    where source_code_id=replace(l_campaign_id,'''');
    /*********************************************************/
   l_custom_rec                   bis_query_attributes;
   l_object_type                  varchar2(30);
   l_url_link                     varchar2(200);
   l_url_camp1                     varchar2(500);
   l_url_camp2                     varchar2(500);
   l_dass                          varchar2(100);  -- variable to store value for  directly assigned lookup value
   l_una                           varchar2(100);   -- variable to store value for  Unassigned lookup value
   l_curr VARCHAR2(50);
   l_curr_suffix VARCHAR2(50);
   l_col_id NUMBER;
   l_area VARCHAR2(300);
   l_report_name VARCHAR2(300);
   l_media VARCHAR2(300);

BEGIN

	NULL;

EXCEPTION
   WHEN OTHERS
   THEN
      l_sql_errm := SQLERRM;
      write_debug ('GET_MKTG_NEW_LEADS_SQL', 'ERROR', l_sql_errm, l_sqltext);
END BIM_MKTG_LEAD_ACT_SQL;
END BIM_DBI_MKTG_MGMT_PVT;

/
