--------------------------------------------------------
--  DDL for Package Body BIM_DBI_BGT_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_DBI_BGT_MGMT_PVT" AS
/* $Header: bimvbgtb.pls 120.6 2006/05/16 01:20:29 arvikuma noship $ */

l_prog_view CONSTANT varchar2(1) := fnd_profile.VALUE('BIM_VIEW_PROGRAM');
l_prog_cost CONSTANT varchar2(40) := fnd_profile.VALUE('BIM_PROG_COST');

PROCEDURE get_bim_page_params (p_page_parameter_tbl      IN     BIS_PMV_PAGE_PARAMETER_TBL,
                               l_as_of_date              OUT NOCOPY DATE,
                               l_period_type             in OUT NOCOPY VARCHAR2,
                               l_record_type_id          OUT NOCOPY NUMBER,
                               l_comp_type               OUT NOCOPY VARCHAR2,
                               l_country                 in OUT NOCOPY VARCHAR2,
                               l_view_by                 in OUT NOCOPY VARCHAR2,
                               l_cat_id                  in OUT NOCOPY VARCHAR2,
                               l_campaign_id             in OUT NOCOPY VARCHAR2,
                               l_fund_id                 in OUT NOCOPY VARCHAR2,
			       l_bcat_id                 in OUT NOCOPY VARCHAR2,
			       l_curr                    in OUT NOCOPY VARCHAR2
			      )
                              IS

l_sql_errm VARCHAR2(32000);
BEGIN

  IF (p_page_parameter_tbl.count > 0) THEN
     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

/*INSERT INTO bim_param_test values(p_page_parameter_tbl(i).parameter_name,
   p_page_parameter_tbl(i).parameter_value,
   p_page_parameter_tbl(i).parameter_id);*/

       IF p_page_parameter_tbl(i).parameter_name = 'PERIOD_TYPE' THEN
          l_period_type := p_page_parameter_tbl(i).parameter_value;
       END IF;
       IF p_page_parameter_tbl(i).parameter_name= 'AS_OF_DATE' THEN
          l_as_of_date := sysdate;
       END IF;

       IF p_page_parameter_tbl(i).parameter_name= 'TIME_COMPARISON_TYPE' THEN
          l_comp_type := p_page_parameter_tbl(i).parameter_value;
       END IF;

        IF( p_page_parameter_tbl(i).parameter_name= 'VIEW_BY') THEN
           l_view_by := p_page_parameter_tbl(i).parameter_value;
           if l_view_by is null then l_view_by := 'CAMPAIGN+CAMPAIGN';
           end if;
        END IF;

         IF ( p_page_parameter_tbl(i).parameter_name= 'ITEM+ENI_ITEM_VBH_CAT') THEN
             l_cat_id := p_page_parameter_tbl(i).parameter_id;
         END IF;

          IF ( p_page_parameter_tbl(i).parameter_name= 'CAMPAIGN+CAMPAIGN') THEN
             l_campaign_id := p_page_parameter_tbl(i).parameter_id;
         END IF;
         IF ( p_page_parameter_tbl(i).parameter_name= 'BIM_MARK_BUDGET+BIM_BUDGET_NAME') THEN
             l_fund_id := p_page_parameter_tbl(i).parameter_id;
         END IF;
         IF ( p_page_parameter_tbl(i).parameter_name= 'BIM_MARK_BUDGET+BIM_BUDGET_CATEGORY') THEN
             l_bcat_id := p_page_parameter_tbl(i).parameter_id;
         END IF;
         IF ( p_page_parameter_tbl(i).parameter_name= 'CURRENCY+FII_CURRENCIES') THEN
             l_curr := p_page_parameter_tbl(i).parameter_id;
         END IF;
          IF p_page_parameter_tbl(i).parameter_name= 'GEOGRAPHY+COUNTRY' THEN
                l_country := p_page_parameter_tbl(i).parameter_id;
                IF (l_country = '''ALL''')
                THEN l_country := 'N';
                END IF;

                IF (l_country IS NULL)
                THEN l_country := 'N';
                END IF;
         IF (instr(l_country,'''') >=0) THEN
          l_country := replace(l_country, '''','');
         END IF;
       END IF;

     END LOOP;
  END IF;

  IF l_comp_type IS NULL THEN l_comp_type := 'YEARLY'; END IF;

  IF l_period_type IS NULL THEN l_period_type := 'FII_TIME_WEEK'; END IF;

  IF l_country IS NULL THEN l_country := 'N'; END IF;

  -- Retrieve l_period_type info using CASE

  CASE l_period_type
    WHEN 'FII_TIME_WEEK' THEN l_record_type_id := 11;
    WHEN 'FII_TIME_ENT_PERIOD' THEN l_record_type_id := 23;
    WHEN 'FII_TIME_ENT_QTR' THEN l_record_type_id := 55;
    WHEN 'FII_TIME_ENT_YEAR' THEN l_record_type_id := 119;
    ELSE l_record_type_id := 11;
  END CASE;

/*INSERT INTO bim_param_test values('get_bim_page_params success',
         nvl(l_comp_type,'NULL'),nvl(l_period_type,'NULL'),
         DBMS_UTILITY.get_time,l_country,NULL,null);
COMMIT;
*/
EXCEPTION
WHEN OTHERS THEN
l_sql_errm := SQLERRM;
/*INSERT INTO bim_param_test values('get_bim_page_params excpetion',
         nvl(l_comp_type,'NULL'),nvl(l_period_type,'NULL'),
         DBMS_UTILITY.get_time,l_country,l_sql_errm,null);
COMMIT;
*/
END get_bim_page_params;
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

FUNCTION GET_ADMIN_STATUS return VARCHAR2 IS
l_admin_count NUMBER := 0;
l_admin_flag varchar2(20);
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

PROCEDURE GET_BGT_SUM_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(12000);
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
l_campaign_id VARCHAR2(50);
l_cat_id VARCHAR2(50):=NULL;
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_fund_id VARCHAR2(50);
l_bcat_id VARCHAR2(50);
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_url_str                      VARCHAR2(1000);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_fund_id,
						      l_bcat_id,
						      l_curr
				                      );

   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';
 IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   l_admin_status := GET_ADMIN_STATUS;

 l_url_str :='pFunctionName=BIM_I_BGT_SUM_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
 --budget name
IF l_fund_id is null then
l_sqltext :=
'SELECT name VIEWBY, viewbyid,
fund_type BIM_ATTRIBUTE2,
fund_category BIM_ATTRIBUTE20,
original_budget BIM_ATTRIBUTE3,
pre_balance BIM_ATTRIBUTE4,
transfer_in BIM_ATTRIBUTE5,
transfer_out BIM_ATTRIBUTE6,
holdback BIM_ATTRIBUTE9,
accrual BIM_ATTRIBUTE7,
committed BIM_ATTRIBUTE8,
cur_balance BIM_ATTRIBUTE10,
planned BIM_ATTRIBUTE11,
utilized BIM_ATTRIBUTE12,
decode(viewbyid,null,NULL,'||''''||l_url_str||''''||' ) bim_url1,
sum(original_budget) over() BIM_GRAND_TOTAL1,
sum(pre_balance) over() BIM_GRAND_TOTAL2,
sum(transfer_in) over() BIM_GRAND_TOTAL3,
sum(transfer_out) over() BIM_GRAND_TOTAL4,
sum(holdback) over() BIM_GRAND_TOTAL7,
sum(accrual) over() BIM_GRAND_TOTAL5,
sum(committed) over() BIM_GRAND_TOTAL6,
sum(cur_balance) over() BIM_GRAND_TOTAL8,
sum(planned) over() BIM_GRAND_TOTAL9,
sum(utilized) over() BIM_GRAND_TOTAL10
FROM
(
SELECT
VIEWBYID,
e.short_name  name,
l.meaning fund_type,
cat.category_name fund_category,
sum(original_budget) original_budget,
sum(pre_balance) pre_balance,
sum(transfer_in) transfer_in,
sum(transfer_out) transfer_out,
sum(holdback) holdback,
sum(accrual)accrual,
sum(committed) committed,
sum(cur_balance) cur_balance,
sum(planned) planned,
sum(utilized) utilized
FROM
( SELECT
decode(a.leaf_node_flag,''Y'',null,a.fund_id) VIEWBYID,
a.fund_id fund_id,
a.fund_type fund_type,
a.category_id category_id,
0 original_budget,
0 pre_balance,
sum(transfer_in'||l_curr_suffix||') transfer_in,
sum(transfer_out'||l_curr_suffix||') transfer_out,
sum(holdback'||l_curr_suffix||') holdback,
sum(accrual'||l_curr_suffix||')accrual,
sum(committed'||l_curr_suffix||') committed,
0 cur_balance,
0 planned,
sum(utilized'||l_curr_suffix||') utilized
FROM BIM_I_BGT_LVL_MV a,
    fii_time_rpt_struct_v cal';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_fund_id is null';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY a.fund_id,decode(a.leaf_node_flag,''Y'',null,a.fund_id),a.fund_type,a.category_id
UNION ALL
SELECT
decode(a.leaf_node_flag,''Y'',null,a.fund_id) VIEWBYID,
a.fund_id fund_id,
a.fund_type fund_type,
a.category_id category_id,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.original_budget'||l_curr_suffix||',0)) original_budget,
sum(decode(cal.report_date,&BIS_CURRENT_EFFECTIVE_START_DATE - 1,
a.original_budget'||l_curr_suffix||'+a.accrual'||l_curr_suffix||'+a.transfer_in'||l_curr_suffix||'-a.transfer_out'||l_curr_suffix||'-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) pre_balance,
0 transfer_in,
0 transfer_out,
0 holdback,
0 accrual,
0 committed,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
a.original_budget'||l_curr_suffix||'+a.accrual'||l_curr_suffix||'+a.transfer_in'||l_curr_suffix||'-a.transfer_out'||l_curr_suffix||'-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) cur_balance,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.planned'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) planned,
0 utilized
FROM BIM_I_BGT_LVL_MV a,
    fii_time_rpt_struct_v cal
    ';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_fund_id is null';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
AND cal.calendar_id=-1
GROUP BY a.fund_id,decode(a.leaf_node_flag,''Y'',null,a.fund_id),a.fund_type,a.category_id
)inner,
 ozf_funds_all_tl e,
 ams_categories_tl cat,
 ozf_lookups l
WHERE e.fund_id = inner.fund_id
AND e.language =USERENV(''LANG'')
AND l.lookup_type=''OZF_FUND_TYPE''
AND l.lookup_code=inner.fund_type
AND cat.category_id = inner.category_id
AND cat.language=USERENV(''LANG'')
GROUP BY e.short_name,l.meaning,cat.category_name,VIEWBYID
HAVING
sum(original_budget) +sum(accrual)>0
or ( sum(pre_balance) >0
or sum(transfer_in) >0
or sum(transfer_out) >0
or sum(holdback)>0
or sum(accrual)>0
or sum(committed) >0
or sum(cur_balance) >0
or sum(planned) >0
or sum(utilized)>0)
)
&ORDER_BY_CLAUSE';
ELSE --budget_name not null
l_sqltext :=
'SELECT name VIEWBY,
viewbyid,
fund_type BIM_ATTRIBUTE2,
fund_category BIM_ATTRIBUTE20,
original_budget BIM_ATTRIBUTE3,
pre_balance BIM_ATTRIBUTE4,
transfer_in BIM_ATTRIBUTE5,
transfer_out BIM_ATTRIBUTE6,
holdback BIM_ATTRIBUTE9,
accrual BIM_ATTRIBUTE7,
committed BIM_ATTRIBUTE8,
cur_balance BIM_ATTRIBUTE10,
planned BIM_ATTRIBUTE11,
utilized BIM_ATTRIBUTE12,
decode(viewbyid,null,NULL,'||''''||l_url_str||''''||' ) bim_url1,
sum(original_budget) over() BIM_GRAND_TOTAL1,
sum(pre_balance) over() BIM_GRAND_TOTAL2,
sum(transfer_in) over() BIM_GRAND_TOTAL3,
sum(transfer_out) over() BIM_GRAND_TOTAL4,
sum(holdback) over() BIM_GRAND_TOTAL7,
sum(accrual) over() BIM_GRAND_TOTAL5,
sum(committed) over() BIM_GRAND_TOTAL6,
sum(cur_balance) over() BIM_GRAND_TOTAL8,
sum(planned) over() BIM_GRAND_TOTAL9,
sum(utilized) over() BIM_GRAND_TOTAL10
FROM
(
SELECT
VIEWBYID,
e.short_name  name,
l.meaning fund_type,
cat.category_name fund_category,
sum(original_budget) original_budget,
sum(pre_balance) pre_balance,
sum(transfer_in) transfer_in,
sum(transfer_out) transfer_out,
sum(holdback) holdback,
sum(accrual)accrual,
sum(committed) committed,
sum(cur_balance) cur_balance,
sum(planned) planned,
sum(utilized) utilized
FROM
( SELECT
decode(a.leaf_node_flag,''Y'',null,a.fund_id) VIEWBYID,
a.fund_id fund_id,
a.fund_type fund_type,
a.category_id category_id,
0 original_budget,
0 pre_balance,
sum(transfer_in'||l_curr_suffix||') transfer_in,
sum(transfer_out'||l_curr_suffix||') transfer_out,
sum(holdback'||l_curr_suffix||') holdback,
sum(accrual'||l_curr_suffix||')accrual,
sum(committed'||l_curr_suffix||') committed,
0 cur_balance,
0 planned,
sum(utilized'||l_curr_suffix||') utilized
FROM BIM_I_BGT_LVL_MV a,
    fii_time_rpt_struct_v cal';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_fund_id =&BIM_MARK_BUDGET+BIM_BUDGET_NAME
';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
 END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY a.fund_id,decode(a.leaf_node_flag,''Y'',null,a.fund_id),a.fund_type,a.category_id
UNION ALL
SELECT
decode(a.leaf_node_flag,''Y'',null,a.fund_id) VIEWBYID,
a.fund_id fund_id,
a.fund_type fund_type,
a.category_id category_id,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.original_budget'||l_curr_suffix||',0)) original_budget,
sum(decode(cal.report_date,&BIS_CURRENT_EFFECTIVE_START_DATE - 1,
a.original_budget'||l_curr_suffix||'+a.accrual'||l_curr_suffix||'+a.transfer_in'||l_curr_suffix||'
-a.transfer_out'||l_curr_suffix||'-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) pre_balance,
0 transfer_in,
0 transfer_out,
0 holdback,
0 accrual,
0 committed,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
a.original_budget'||l_curr_suffix||'+a.accrual'||l_curr_suffix||'+a.transfer_in'||l_curr_suffix||'-a.transfer_out'||l_curr_suffix||'
-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) cur_balance,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.planned'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) planned,
0 utilized
FROM BIM_I_BGT_LVL_MV a,
    fii_time_rpt_struct_v cal';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_fund_id =&BIM_MARK_BUDGET+BIM_BUDGET_NAME
';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
 END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
AND cal.calendar_id=-1
GROUP BY a.fund_id,decode(a.leaf_node_flag,''Y'',null,a.fund_id),a.fund_type,a.category_id
)inner,
 ozf_funds_all_tl e,
 ams_categories_tl cat,
 ozf_lookups l
WHERE e.fund_id = inner.fund_id
AND e.language =USERENV(''LANG'')
AND l.lookup_type=''OZF_FUND_TYPE''
AND l.lookup_code=inner.fund_type
AND cat.category_id = inner.category_id
AND cat.language=USERENV(''LANG'')
GROUP BY e.short_name,l.meaning,cat.category_name,VIEWBYID
HAVING
sum(original_budget)+sum(accrual) >0
or (sum(pre_balance) >0
or sum(transfer_in) >0
or sum(transfer_out) >0
or sum(holdback)>0
or sum(accrual)>0
or sum(committed) >0
or sum(cur_balance) >0
or sum(planned) >0
or sum(utilized)>0)
)
&ORDER_BY_CLAUSE';
END IF;--end of budget name

/*IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
end if; */--end of campaign
/*
IF (l_view_by = 'GEOGRAPHY+COUNTRY') THEN
END IF;
IF (l_view_by = 'MEDIA+MEDIA') THEN
END IF;
*/
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

  l_custom_rec.attribute_name := ':l_fund_id';
  l_custom_rec.attribute_value := l_fund_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

/*  l_custom_rec.attribute_name := ':l_campaign_id';
  l_custom_rec.attribute_value := l_campaign_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;*/

write_debug('GET_BGT_SUM_SQL','QUERY','_',l_sqltext);
--return l_sqltext;
--INSERT INTO bim_test_sql values(l_view_by,l_sqltext);
EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_BGT_SUM_SQL','ERROR',l_sql_errm,l_sqltext);
END GET_BGT_SUM_SQL;

PROCEDURE GET_BGT_CAT_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
l_sqltext varchar2(12000);
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
l_campaign_id VARCHAR2(50);
l_cat_id VARCHAR2(50):=NULL;
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_fund_id VARCHAR2(50);
l_bcat_id VARCHAR2(50);
l_curr    VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_url_str                      VARCHAR2(1000);
BEGIN
x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
get_bim_page_params(p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_country,
						      l_view_by,
						      l_cat_id,
						      l_campaign_id,
						      l_fund_id,
						      l_bcat_id,
						      l_curr
				                      );
 IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';

   l_admin_status := GET_ADMIN_STATUS;

 l_url_str :='pFunctionName=BIM_I_BGT_CAT_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
IF (l_bcat_id is not null) then
 l_sqltext :=
'SELECT name VIEWBY,
VIEWBYID,
original_budget BIM_ATTRIBUTE3,
pre_balance BIM_ATTRIBUTE4,
transfer_in BIM_ATTRIBUTE5,
transfer_out BIM_ATTRIBUTE6,
holdback BIM_ATTRIBUTE9,
accrual BIM_ATTRIBUTE7,
committed BIM_ATTRIBUTE8,
cur_balance BIM_ATTRIBUTE10,
planned BIM_ATTRIBUTE11,
utilized BIM_ATTRIBUTE12,
decode(viewbyid,null,NULL,'||''''||l_url_str||''''||' ) bim_url1,
sum(original_budget) over() BIM_GRAND_TOTAL1,
sum(pre_balance) over() BIM_GRAND_TOTAL2,
sum(transfer_in) over() BIM_GRAND_TOTAL3,
sum(transfer_out) over() BIM_GRAND_TOTAL4,
sum(holdback) over() BIM_GRAND_TOTAL7,
sum(accrual) over() BIM_GRAND_TOTAL5,
sum(committed) over() BIM_GRAND_TOTAL6,
sum(cur_balance) over() BIM_GRAND_TOTAL8,
sum(planned) over() BIM_GRAND_TOTAL9,
sum(utilized) over() BIM_GRAND_TOTAL10
FROM
(
SELECT
VIEWBYID,
e.category_name name,
sum(original_budget) original_budget,
sum(pre_balance) pre_balance,
sum(transfer_in) transfer_in,
sum(transfer_out) transfer_out,
sum(holdback) holdback,
sum(accrual)accrual,
sum(committed) committed,
sum(cur_balance) cur_balance,
sum(planned) planned,
sum(utilized) utilized
FROM
( SELECT
decode(a.leaf_node_flag,''Y'',null,a.category_id) VIEWBYID,
a.category_id  category_id,
0 original_budget,
0 pre_balance,
sum(transfer_in'||l_curr_suffix||') transfer_in,
sum(transfer_out'||l_curr_suffix||') transfer_out,
sum(holdback'||l_curr_suffix||') holdback,
sum(accrual'||l_curr_suffix||')accrual,
sum(committed'||l_curr_suffix||') committed,
0 cur_balance,
0 planned,
sum(utilized) utilized
FROM BIM_I_BGT_CAT_MV a,
    fii_time_rpt_struct_v cal';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_category_id =&BIM_MARK_BUDGET+BIM_BUDGET_CATEGORY
';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY decode(a.leaf_node_flag,''Y'',null,a.category_id),a.category_id
UNION ALL
SELECT
decode(a.leaf_node_flag,''Y'',null,a.category_id) VIEWBYID,
a.category_id category_id,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.original_budget'||l_curr_suffix||',0)) original_budget,
sum(decode(cal.report_date,&BIS_CURRENT_EFFECTIVE_START_DATE - 1,
a.original_budget'||l_curr_suffix||'+a.accrual'||l_curr_suffix||'+a.transfer_in'||l_curr_suffix||'
-a.transfer_out'||l_curr_suffix||'-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) pre_balance,
0 transfer_in,
0 transfer_out,
0 holdback,
0 accrual,
0 committed,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.original_budget'||l_curr_suffix||'
+a.accrual'||l_curr_suffix||'+a.transfer_in'||l_curr_suffix||'-a.transfer_out'||l_curr_suffix||'-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) cur_balance,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.planned'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) planned,
0 utilized
FROM BIM_I_BGT_CAT_MV a,
    fii_time_rpt_struct_v cal';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_category_id =&BIM_MARK_BUDGET+BIM_BUDGET_CATEGORY
';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_CURRENT_EFFECTIVE_START_DATE - 1)
AND cal.calendar_id=-1
GROUP BY decode(a.leaf_node_flag,''Y'',null,a.category_id),a.category_id
) inner,  ams_categories_tl e
WHERE inner.category_id=e.category_id
AND e.language =USERENV(''LANG'')
GROUP BY e.category_name,VIEWBYID
HAVING
sum(original_budget) >0
or sum(pre_balance) >0
or sum(transfer_in) >0
or sum(transfer_out) >0
or sum(holdback) >0
or sum(accrual)>0
or sum(committed) >0
or sum(cur_balance) >0
or sum(planned) >0
or sum(utilized)>0
)
&ORDER_BY_CLAUSE';
ELSE --
 l_sqltext :=
'SELECT name VIEWBY,
VIEWBYID,
original_budget BIM_ATTRIBUTE3,
pre_balance BIM_ATTRIBUTE4,
transfer_in BIM_ATTRIBUTE5,
transfer_out BIM_ATTRIBUTE6,
holdback BIM_ATTRIBUTE9,
accrual BIM_ATTRIBUTE7,
committed BIM_ATTRIBUTE8,
cur_balance BIM_ATTRIBUTE10,
planned BIM_ATTRIBUTE11,
utilized BIM_ATTRIBUTE12,
decode(viewbyid,null,NULL,'||''''||l_url_str||''''||' ) bim_url1,
sum(original_budget) over() BIM_GRAND_TOTAL1,
sum(pre_balance) over() BIM_GRAND_TOTAL2,
sum(transfer_in) over() BIM_GRAND_TOTAL3,
sum(transfer_out) over() BIM_GRAND_TOTAL4,
sum(holdback) over() BIM_GRAND_TOTAL7,
sum(accrual) over() BIM_GRAND_TOTAL5,
sum(committed) over() BIM_GRAND_TOTAL6,
sum(cur_balance) over() BIM_GRAND_TOTAL8,
sum(planned) over() BIM_GRAND_TOTAL9,
sum(utilized) over() BIM_GRAND_TOTAL10
FROM
(
SELECT
VIEWBYID,
e.category_name name,
sum(original_budget) original_budget,
sum(pre_balance) pre_balance,
sum(transfer_in) transfer_in,
sum(transfer_out) transfer_out,
sum(holdback) holdback,
sum(accrual)accrual,
sum(committed) committed,
sum(cur_balance) cur_balance,
sum(planned) planned,
sum(utilized) utilized
FROM
( SELECT
decode(a.leaf_node_flag,''Y'',null,a.category_id) VIEWBYID,
a.category_id  category_id,
0 original_budget,
0 pre_balance,
sum(transfer_in'||l_curr_suffix||') transfer_in,
sum(transfer_out'||l_curr_suffix||') transfer_out,
sum(holdback'||l_curr_suffix||') holdback,
sum(accrual'||l_curr_suffix||')accrual,
sum(committed'||l_curr_suffix||') committed,
0 cur_balance,
0 planned,
sum(utilized'||l_curr_suffix||') utilized
FROM BIM_I_BGT_CAT_MV a,
    fii_time_rpt_struct_v cal';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_category_id is null
';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date = &BIS_CURRENT_ASOF_DATE
AND cal.calendar_id=-1
GROUP BY decode(a.leaf_node_flag,''Y'',null,a.category_id),a.category_id
UNION ALL
SELECT
decode(a.leaf_node_flag,''Y'',null,a.category_id) VIEWBYID,
a.category_id category_id,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.original_budget'||l_curr_suffix||',0)) original_budget,
sum(decode(cal.report_date,&BIS_CURRENT_EFFECTIVE_START_DATE - 1,a.original_budget'||l_curr_suffix||'
+a.accrual'||l_curr_suffix||'+a.transfer_in'||l_curr_suffix||'-a.transfer_out'||l_curr_suffix||'
-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) pre_balance,
0 transfer_in,
0 transfer_out,
0 holdback,
0 accrual,
0 committed,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.original_budget'||l_curr_suffix||'+a.accrual'||l_curr_suffix||'
+a.transfer_in'||l_curr_suffix||'-a.transfer_out'||l_curr_suffix||'-a.holdback'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) cur_balance,
sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,a.planned'||l_curr_suffix||'-a.committed'||l_curr_suffix||',0)) planned,
0 utilized
FROM BIM_I_BGT_CAT_MV a,
    fii_time_rpt_struct_v cal';
IF l_admin_status = 'N' THEN
l_sqltext :=  l_sqltext ||
' , ams_act_access_denorm b';
END IF;
l_sqltext :=  l_sqltext ||
' WHERE a.time_id = cal.time_id
AND  a.period_type_id = cal.period_type_id
AND a.parent_category_id is null
';
IF l_admin_status = 'N' THEN
l_sqltext := l_sqltext ||
' AND b.resource_id = :l_resource_id
 AND b.object_type=''FUND''
 AND a.fund_id =b.object_id';
END IF;
l_sqltext :=  l_sqltext ||
' AND BITAND(cal.record_type_id,1143)= cal.record_type_id';
l_sqltext :=  l_sqltext ||
' AND cal.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_CURRENT_EFFECTIVE_START_DATE - 1)
AND cal.calendar_id=-1
GROUP BY decode(a.leaf_node_flag,''Y'',null,a.category_id),a.category_id
) inner, ams_categories_tl e
WHERE inner.category_id = e.category_id
AND e.language =USERENV(''LANG'')
GROUP BY e.category_name,VIEWBYID
HAVING
sum(original_budget) >0
or sum(pre_balance) >0
or sum(transfer_in) >0
or sum(transfer_out) >0
or sum(holdback) >0
or sum(accrual)>0
or sum(committed) >0
or sum(cur_balance) >0
or sum(planned) >0
or sum(utilized)>0
)
&ORDER_BY_CLAUSE';
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

  l_custom_rec.attribute_name := ':l_fund_id';
  l_custom_rec.attribute_value := l_fund_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':l_bcat_id';
  l_custom_rec.attribute_value := l_bcat_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

/*  l_custom_rec.attribute_name := ':l_campaign_id';
  l_custom_rec.attribute_value := l_campaign_id;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;*/

write_debug('GET_BGT_CAT_SQL','QUERY','_',l_sqltext);
--return l_sqltext;

EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_BGT_SUM_SQL','ERROR',l_sql_errm,l_sqltext);
END GET_BGT_CAT_SQL;

PROCEDURE GET_BGT_UTL_SQL(p_page_parameter_tbl in BIS_PMV_PAGE_PARAMETER_TBL,
                          x_custom_sql  OUT NOCOPY VARCHAR2,
                          x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
 IS
--l_sqltext varchar2(12000);
l_sqltext varchar2(30000);
iFlag number;
l_period_type_hc number;
l_as_of_date  DATE;
l_date date;
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
l_select_clause varchar2(1000);
l_sel1 varchar2(1000);
l_sel2 varchar2(1000);
l_access_table varchar2(4000);
l_campaign_id VARCHAR2(50);
l_cat_id VARCHAR2(50):=NULL;
l_select                       VARCHAR2 (20000); -- to build  inner select to pick data from mviews
l_pc_select                    VARCHAR2 (20000); -- to build  inner select to pick data directly assigned to the product category hirerachy
l_select_cal                   VARCHAR2 (20000); -- to build  select calculation part
l_select_filter                VARCHAR2 (20000); -- to build  select filter part
l_from                         VARCHAR2 (20000);   -- assign common table in  clause
l_where                        VARCHAR2 (2000);  -- static where clause
l_where1                        VARCHAR2 (2000);  -- static where clause
l_where2                        VARCHAR2 (2000);  -- static where clause
l_groupby                      VARCHAR2 (2000);  -- to build  group by clause
l_pc_from                      VARCHAR2 (20000);   -- from clause to handle product category
l_pc_where                     VARCHAR2 (20000);   --  where clause to handle product category
l_filtercol                    VARCHAR2 (2000);
l_pc_col                       VARCHAR2(100);
l_pc_groupby                   VARCHAR2(200);
l_view                         VARCHAR2 (20);
l_comm_col1                    VARCHAR2(2000);
l_comm_col2                    VARCHAR2(2000);
l_comm_cols                    VARCHAR2 (20000);
l_view_disp                    VARCHAR2(100);
l_url_str                      VARCHAR2(1000);
l_url_str_jtf                  VARCHAR2(1000);
l_url_str_csch                 VARCHAR2(1000);
l_url_str_type                 VARCHAR2(1000);
l_top_cond                     VARCHAR2(100);
l_meaning                      VARCHAR2 (500);
l_table                        VARCHAR2(2000);
l_fund_id VARCHAR2(50);
l_bcat_id VARCHAR2(50);
l_curr VARCHAR2(50);
l_curr_suffix VARCHAR2(50);
l_url   varchar2(2000);
l_col_id number;
l_area VARCHAR2(50);
l_media VARCHAR2(50);
l_report_name VARCHAR2(50);

/* variables to hold columns names in l_select clauses */
l_col                          VARCHAR2(1000);
/* cursor to get type of object passed from the page ******/
cursor get_obj_type
is
select object_type
from bim_i_source_codes
where source_code_id=replace(l_campaign_id,'''');
/*********************************************************/
l_object_type                  varchar2(30);
l_custom_rec BIS_QUERY_ATTRIBUTES;
l_curr_suffix1 VARCHAR2(50);
l_table_bud VARCHAR2(300);
l_where_bud VARCHAR2(300);
l_prog_cost1 VARCHAR2(20);

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
                                                      l_report_name  );

 for i in get_obj_type
	 loop
	 l_object_type:=i.object_type;
	 end loop;

l_meaning:=' null meaning '; -- assigning default value
IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := '';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := '_s';
    ELSE l_curr_suffix := '';
  END IF;
   --l_curr_aod_str := 'to_date('||to_char(l_as_of_date,'J')||',''J'')';

   l_admin_status := GET_ADMIN_STATUS;

 l_url_str :='pFunctionName=BIM_I_BGT_UTL_PHP&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID';
 l_url_str_jtf :='pFunctionName=BIM_I_CSCH_START_DRILL&pParamIds=Y&VIEW_BY='||l_view_by||'&VIEW_BY_NAME=VIEW_BY_ID&PAGE.OBJ.ID_NAME1=customSetupId&PAGE.OBJ.ID1=1&PAGE.OBJ.objType=CSCH&PAGE.OBJ.objAttribute=DETL&PAGE.OBJ.ID_NAME0=objId&PAGE.OBJ.ID0=';

 l_url_str_csch :='pFunctionName=AMS_WB_CSCH_UPDATE&omomode=UPDATE&MidTab=TargetAccDSCRN&searchType=customize&OA_SubTabIdx=3&retainAM=Y&addBreadCrumb=S&addBreadCrumb=Y&objId=';
 l_url_str_type :='pFunctionName=AMS_WB_CSCH_RPRT&addBreadCrumb=Y&OAPB=AMS_CAMP_WORKBENCH_BRANDING&objType=CSCH&objId=';

 IF l_country IS NULL THEN
      l_country := 'N';
 END IF;


/** to add meaning in select clause only in case of campaign view by */
  IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
  l_meaning:=' meaning,object_id,object_type,usage ';
  l_filtercol:=',meaning,object_id,object_type,usage ';
  l_table :='bim_i_obj_mets_mv';
  else
  l_meaning:=' null meaning , null object_id, null object_type, null usage ';
  l_table :='bim_obj_chnl_mv';
  end if;

  /*** to display Directly assigned  **/

   IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') AND l_cat_id is not null THEN
   l_view_disp:=' DECODE(viewbyid,-999,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'DASS'||''''||')'||',viewby) viewby,';
   ELSE
   l_view_disp:='viewby,';
   END IF;

   if   l_view_by ='GEOGRAPHY+COUNTRY' then
   	 l_url:=' null bim_url1,
         null BIM_URL2,
         NULL BIM_URL3, ';
   else
         l_url:= ' decode(viewbyid,-999,NULL,-1,NULL,-777,null,'||''''||l_url_str||''''||' ) bim_url1,
         decode(object_type,''CSCH'',decode(usage,''LITE'','||''''||l_url_str_csch||''''||'||object_id,'||''''||l_url_str_jtf||''''||'||object_id),''EVEO'',NULL,''EONE'',NULL,'||''''||l_url_str||''''||' ) BIM_URL2,
         decode(object_type,''CSCH'','||''''||l_url_str_type||''''||'||object_id,NULL ) BIM_URL3, ';
   end if;


/* l_select_cal is common part of select statement for all view by to calculate grand totals and change */
 l_select_cal :='
         SELECT '||
         l_view_disp ||'
	 viewbyid,
	 bim_attribute2,
 	 bim_attribute3,
 	 bim_attribute4,
 	 bim_attribute5,
 	 bim_attribute6,
 	 bim_attribute8,
 	 bim_attribute7,'||l_url||'
	 bim_grand_total1,
 	 bim_grand_total2,
 	 bim_grand_total3,
 	 bim_grand_total4,
 	 bim_grand_total5
          FROM
	 (
           SELECT name VIEWBY,object_id,object_type,usage,
                meaning BIM_ATTRIBUTE2,
		approved BIM_ATTRIBUTE3,
		utilized BIM_ATTRIBUTE4,
		total_approved BIM_ATTRIBUTE5,
		total_utilized BIM_ATTRIBUTE6,
		total_approved BIM_ATTRIBUTE8,
		balance BIM_ATTRIBUTE7,
		sum(approved) over() BIM_GRAND_TOTAL1,
		sum(utilized) over() BIM_GRAND_TOTAL2,
		sum(total_approved) over() BIM_GRAND_TOTAL3,
		sum(total_utilized) over() BIM_GRAND_TOTAL4,
		sum(balance) over() BIM_GRAND_TOTAL5,
		VIEWBYID
             FROM
              (
                 SELECT
			 viewbyid,
          	      name,'||
		      l_meaning||
		    ',sum(approved) approved,
			sum(utilized) utilized,
			sum(total_approved) total_approved,
			sum(total_utilized) total_utilized,
			sum(total_approved)-sum(total_utilized) balance
                  FROM
          	  (  ';

l_curr_suffix1 :=l_curr_suffix;

IF l_object_type in ('CAMP','EVEH','CSCH') AND l_prog_cost ='BIM_APPROVED_BUDGET' THEN

l_table_bud :=  ' ,bim_i_marketing_facts facts';
l_where_bud := ' AND facts.source_code_id = a.source_code_id';
IF l_curr_suffix is null THEN
l_prog_cost1 := 'facts.metric1';
ELSE
l_curr_suffix1 := null;
l_prog_cost1 := 'facts.metric2';
END IF;
ELSE
l_prog_cost1 :='a.budget_approved';

END IF;

IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN
	l_comm_col1:=    '      ,name.object_id,name.object_type,name.child_object_usage usage
	                        ,sum('||l_prog_cost1||l_curr_suffix1||') approved,
				sum(a.cost_actual'||l_curr_suffix||') utilized,
				0 total_approved ,
				0 total_utilized ,
				0 balance';
	l_comm_col2:=    '      ,name.object_id,name.object_type,name.child_object_usage usage
				,0 approved,
				0 utilized,
				sum('||l_prog_cost1||l_curr_suffix1||') total_approved ,
				sum(a.cost_actual'||l_curr_suffix||') total_utilized ,
				0 balance';
ELSE
	l_comm_col1:=    '      ,null object_id,null object_type, null usage
				,sum(budget_approved'||l_curr_suffix||') approved,
				sum(cost_actual'||l_curr_suffix||') utilized,
				0 total_approved ,
				0 total_utilized ,
				0 balance';
	l_comm_col2:=    '      ,null object_id,null object_type, null usage
				,0 approved,
				0 utilized,
				sum(budget_approved'||l_curr_suffix||') total_approved ,
				sum(cost_actual'||l_curr_suffix||') total_utilized ,
				0 balance';
END IF;

/* l_from contains time dimension table common to all select statement for all view by */
 l_from  :=',fii_time_rpt_struct_v cal ';
 /* l_where contains where clause to join time dimension table common to all select statement for all view by */
 l_where :=' WHERE a.time_id = cal.time_id
             AND  a.period_type_id = cal.period_type_id
             AND  cal.calendar_id= -1
	     ';
 l_where1 :=' AND  BITAND(cal.record_type_id,:l_record_type)= cal.record_type_id ';
 l_where2 :=' AND  BITAND(cal.record_type_id,1143)= cal.record_type_id ';
 /* l_select_filter contains group by and filter clause to remove uneccessary records with zero values */
l_select_filter := ' ) GROUP BY viewbyid,name '||l_filtercol||
                  ')
		   )
         WHERE
          bim_attribute3 <> 0
          or bim_attribute4 <> 0
          or bim_attribute5 <> 0
          or bim_attribute6 <> 0
          or bim_attribute7 <> 0
          or bim_attribute8 <> 0
          &ORDER_BY_CLAUSE ';
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
--end of security handling
/************************************************************************/
    /* product category handling */
     IF  l_cat_id is not null then
         l_pc_from   :=  ', eni_denorm_hierarchies edh,mtl_default_category_sets d';
	 l_pc_where  :=  ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
			   AND edh.object_id = d.category_set_id
			   AND d.functional_area_id = 11
			   AND edh.dbi_flag = ''Y''
			   AND edh.parent_id = :l_cat_id ';
       ELSE
        l_pc_where :=     ' AND a.category_id = -9 ';
     END IF;

       IF (l_view_by = 'CAMPAIGN+CAMPAIGN') THEN

     /* forming from clause for the tables which is common to all union all */
     if l_cat_id is not null then
     l_from :=' FROM  '||l_table||' a, bim_i_obj_name_mv name '||l_from||l_pc_from;
     else
     l_from :=' FROM  '||l_table||' a, bim_i_obj_name_mv name '||l_from;
     end if;


      /* forming where clause which is common to all union all */
     l_where :=l_where||' AND a.source_code_id = name.source_code_id
			 AND name.language=USERENV(''LANG'')
			 AND a.object_country = :l_country'||
		 l_pc_where;


    /* forming group by clause for the common columns for all union all */
   IF  l_view_by = 'CAMPAIGN+CAMPAIGN' then
   l_groupby:=' GROUP BY a.source_code_id,name.object_type_mean,name.name,name.object_id,name.object_type, name.child_object_usage  ';
    ELSE
    l_groupby:=' GROUP BY a.source_code_id,name.object_type_mean, ';
   END IF;

    /*** campaign id null means No drill down and view by is camapign hirerachy*/
  IF l_campaign_id is null THEN
   /*appending l_select_cal for calculation and sql clause to pick data and filter clause to filter records with zero values***/
     l_sqltext:= l_select_cal||
     /******** inner select start from here */
     /* select to get camapigns and programs  */
     ' SELECT
      a.source_code_id VIEWBYID,
      name.name name,
      name.object_type_mean meaning '||
      l_comm_col1 ||
      l_from ||l_where||l_where1||l_top_cond||
     ' AND cal.report_date=&BIS_CURRENT_ASOF_DATE
       and name.language=USERENV(''LANG'')'
      ||l_groupby|| ',name.name'||
      ' UNION ALL
      SELECT
      a.source_code_id VIEWBYID,
      name.name name,
      name.object_type_mean meaning '||
      l_comm_col2 ||
      l_from ||l_where||
     l_where2 ||l_top_cond||
     ' AND cal.report_date=&BIS_CURRENT_ASOF_DATE
       and name.language=USERENV(''LANG'')'
       || l_groupby|| ',name.name '||
       l_select_filter /* appending filter clause */
      ;
 ELSE


 /* source_code_id is passed from the page, object selected from the page to be drill may be program,campaign,event,one off event*****/
/* appending table in l_form and joining conditon for the bim_i_source_codes */
    l_where :=l_where ||' AND a.immediate_parent_id = :l_campaign_id ';
 -- checking for the object type passed from page

 for i in get_obj_type
 loop
 l_object_type:=i.object_type;
 end loop;

 -- if program is selected from the page means it may have childern as programs,campaigns,events or one off events
 /* changed the following to use the bim_i_obj_name_mv */
 l_sqltext:= l_select_cal||
' SELECT
      a.source_code_id VIEWBYID,
      name.name name,
      name.object_type_mean meaning '||
      l_comm_col1 ||
      l_from ||l_table_bud||l_where||l_where1||l_where_bud||
      ' AND cal.report_date=&BIS_CURRENT_ASOF_DATE
       and name.language=USERENV(''LANG'')'||
      l_groupby||
      ' ,name.name'||
      ' UNION ALL
       SELECT
      a.source_code_id VIEWBYID,
      name.name name,
      name.object_type_mean meaning '||
      l_comm_col2 ||
      l_from ||l_table_bud||l_where||l_where2||l_where_bud||
      ' AND cal.report_date=&BIS_CURRENT_ASOF_DATE
       and name.language=USERENV(''LANG'')'||
      l_groupby||
      ' ,name.name'||
        l_select_filter ;

 END IF;
 /***** END CAMPAIGN HIRERACHY VIEW HANDLING ******************/

 ELSE
 /* view by is product category */
 IF (l_view_by ='ITEM+ENI_ITEM_VBH_CAT') THEN

/******** handling product category hirerachy ****/
/* picking up value of top level node from product category denorm for category present in  bim_i_obj_mets_mv   */
    IF l_cat_id is null then
       l_from:=l_from||
               ',eni_denorm_hierarchies edh
                ,mtl_default_category_sets d
                ,( SELECT e.parent_id parent_id ,e.value value
                   FROM eni_item_vbh_nodes_v e
                   WHERE e.top_node_flag=''Y''
                   AND e.child_id = e.parent_id) p ';
       l_where := l_where||
                         ' AND a.category_id = edh.child_id
			   AND edh.object_type = ''CATEGORY_SET''
                           AND edh.object_id = d.category_set_id
                           AND d.functional_area_id = 11
                           AND edh.dbi_flag = ''Y''
                           AND edh.parent_id = p.parent_id';
       l_col:=' SELECT
		   p.value name,
                   p.parent_id viewbyid,
		   null meaning ';
        l_groupby := ' GROUP BY p.value,p.parent_id ';
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
            ,(select e.id,e.value,leaf_node_flag
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

     l_col:=' SELECT
		   p.value name,
                   decode(p.leaf_node_flag,''Y'',-777,p.id) viewbyid,
		   null meaning ';
     l_groupby := ' GROUP BY p.value,decode(p.leaf_node_flag,''Y'',-777,p.id) ';
    END IF;
/*********************/

           IF l_campaign_id is null then /* no drilll down in campaign hirerachy */
	      IF l_admin_status ='Y' THEN
              l_from:=' FROM bim_i_obj_mets_mv a
                              '||l_from;
              l_where := l_where ||l_top_cond||
                         '  AND  a.object_country = :l_country';
               IF l_cat_id is not null then
	          l_pc_from := ' FROM bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||l_top_cond||
                         ' AND  a.object_country = :l_country';
               END IF;
              ELSE
              l_from:=' FROM bim_i_obj_mets_mv a
                             '||l_from;
              l_where := l_where ||
	                   ' AND  a.object_country = :l_country';

		IF l_cat_id is not null then
	          l_pc_from := ' FROM bim_i_obj_mets_mv a
                              '||l_pc_from;
		  l_pc_where := l_pc_where ||
                         ' AND  a.object_country = :l_country';
               END IF;

              END IF;
           ELSE
              l_from := ' FROM   bim_i_obj_mets_mv a '||l_from ;
              l_where  := l_where ||
                    --    '  AND  a.parent_denorm_type = b.object_type
                    --       AND  a.parent_object_id = b.object_id
                           ' AND  a.source_code_id = :l_campaign_id
                          -- AND  b.child_object_id=0
			   AND  a.object_country = :l_country' ;
              IF l_cat_id is not null then
	      l_pc_from := ' FROM   bim_i_obj_mets_mv a '||l_pc_from ;
              l_pc_where  := l_pc_where ||
                        --'  AND  a.parent_denorm_type = b.object_type
                        --   AND  a.parent_object_id = b.object_id
                           'AND  a.source_code_id = :l_campaign_id
			--   AND  b.child_object_id=0
			   AND  a.object_country = :l_country' ;
	      END IF;
	   END IF;
   /* building l_pc_select to get values directly assigned to product category passed from the page */
   IF l_cat_id is not null  THEN
       	  l_pc_col:=' SELECT
		   p.value name,
                   -999  viewbyid,
		   null meaning ';
     l_pc_groupby := ' GROUP BY p.value,p.id ';

  l_pc_select :=
              ' UNION ALL ' ||
              l_pc_col||
              l_comm_col1||
	      l_pc_from||
	      l_pc_where ||l_where1||' AND cal.report_date =&BIS_CURRENT_ASOF_DATE'||
	      l_pc_groupby ||
	      ' UNION ALL ' ||
              l_pc_col||
              l_comm_col2||
	      l_pc_from||
	      l_pc_where ||l_where2||' AND cal.report_date =&BIS_CURRENT_ASOF_DATE'||
	      l_pc_groupby
	      ;
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
		    decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name) name,
		    a.object_country viewbyid,
		     null meaning ';
    l_groupby := ' GROUP BY  a.object_country,decode(d.name,null,bim_pmv_dbi_utl_pkg.get_lookup_value('||''''||'UNA'||''''||')'||',d.name) ';
    l_from:=' FROM bis_countries_v d '||l_from;
	  IF l_campaign_id is null then
	      IF l_admin_status ='Y' THEN
	      l_from:=l_from||' , '||l_table||' a ';
              l_where := l_where ||l_top_cond||
                         ' AND  a.object_country =d.country_code (+)';
              ELSE
              l_from:=l_from||' , '||l_table||' a ';
              l_where := l_where ||
	                 ' AND  a.object_country =d.country_code (+)';
              END IF;
            ELSE
              l_from := l_from||' , '||l_table||' a ';
              l_where  := l_where ||
                       -- '  AND  a.parent_denorm_type = b.object_type
                       --    AND  a.parent_object_id = b.object_id
		--	   AND  b.child_object_id=0
                          ' AND  a.source_code_id = :l_campaign_id
                           AND  a.object_country =d.country_code (+) ';
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
            l_where :=  l_where ||
	                 ' AND  d.id (+)= a.activity_id
			   AND  a.object_country = :l_country';
              ELSE
             l_from:=l_from||' ,bim_obj_chnl_mv a ';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.activity_id
   		           AND  a.object_country = :l_country';
	     END IF;
            ELSE
              l_from := l_from||' ,bim_obj_chnl_mv a ';
              l_where  := l_where ||
                        '   AND  a.source_code_id = :l_campaign_id
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
              l_from:=l_from||' ,bim_obj_regn_mv a';
              l_where := l_where ||
	                 ' AND  d.id (+)= a.object_region
   		           AND  a.object_country = :l_country';
              END IF;
            ELSE
              l_from := l_from||' ,bim_obj_regn_mv a ';
              l_where  := l_where ||
                        '   AND  a.source_code_id = :l_campaign_id
	                   AND  d.id (+)= a.object_region
			   AND  a.object_country = :l_country';
	  END IF;
END IF;

/* combine sql one to pick up current period values and  sql two to pick previous period values */
  l_select := l_col||
              l_comm_col1||
	      l_from||
	      l_where ||l_where1||' AND cal.report_date =&BIS_CURRENT_ASOF_DATE '||
	      l_groupby ||
	      ' UNION ALL'||
              l_col||
              l_comm_col2||
	      l_from||
	      l_where ||l_where2||' AND cal.report_date =&BIS_CURRENT_ASOF_DATE '||
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

write_debug('GET_BGT_UTL_SQL','QUERY','_',l_sqltext);
--return l_sqltext;
--INSERT INTO bim_test_sql values(l_view_by,l_sqltext);
EXCEPTION
WHEN others THEN
l_sql_errm := SQLERRM;
write_debug('GET_BGT_UTL_SQL','ERROR',l_sql_errm,l_sqltext);
END GET_BGT_UTL_SQL;

END BIM_DBI_BGT_MGMT_PVT;

/
