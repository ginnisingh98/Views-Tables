--------------------------------------------------------
--  DDL for Package Body MSC_ANALYSIS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MSC_ANALYSIS_PKG" AS
/* $Header: MSCANLSB.pls 120.17.12010000.2 2009/12/24 00:50:47 minduvad ship $  */

 g_plan_viewby  CONSTANT NUMBER :=0;
 g_org_viewby  CONSTANT NUMBER :=1;
 g_category_viewby  CONSTANT NUMBER :=2;
 g_cust_class_viewby  CONSTANT NUMBER :=3;
 g_item_viewby  CONSTANT NUMBER :=4;
 g_period_viewby CONSTANT NUMBER :=5;
 g_week_viewby CONSTANT NUMBER :=6;
 g_demand_class_viewby  CONSTANT NUMBER :=7;
 g_plan_org_cate_viewby  CONSTANT NUMBER :=8;

 g_target_sl CONSTANT NUMBER := 1;
 g_attained_sl CONSTANT NUMBER := 2;
 g_tp_cost CONSTANT NUMBER := 3;

 g_calendar_type_mfg CONSTANT NUMBER := 1;
 g_calendar_type_bis CONSTANT NUMBER := 0;


 TYPE CurTyp IS REF CURSOR;

  cursor c_next_pr (p_plan in number, p_curr_pr_date in date,
	p_period_type in number, p_detail_level in number ) is
  select min(detail_date)-1
  from msc_bis_inv_detail
  where plan_id = p_plan
  and nvl(period_type,0) = p_period_type
  and nvl(detail_level,0) = p_detail_level
  and detail_date > p_curr_pr_date;

  cursor c_prev_pr (p_plan in number,
	p_instance in number, p_org in number, p_item in number,
	p_curr_pr_date in date,
	p_period_type in number, p_detail_level in number ) is
  select max(detail_date)+1
  from msc_bis_inv_detail
  where plan_id = p_plan
  and sr_instance_id = p_instance
  and organization_id = p_org
  and inventory_item_id = p_item
  and nvl(period_type,0) = p_period_type
  and nvl(detail_level,0) = p_detail_level
  and detail_date < p_curr_pr_date;

  cursor c_planinfo (p_plan in number) is
  select plan_start_date, curr_cutoff_date
  from msc_plans
  where plan_id = p_plan;


  cursor c_plan_orgs (l_plan_id number) is
  select sr_instance_id, organization_id
  from msc_plan_organizations
  where plan_id = l_plan_id;

  g_perf_profile_on BOOLEAN :=FALSE;

PROCEDURE put_line (p_msg varchar2) IS
BEGIN
  --insert into msc_test values (p_msg);
  --commit;
  --dbms_output.put_line(p_msg);
  null;
END put_line;

procedure store_user_pref(p_plan_type varchar2) is
  l_cat_set_id number;
  l_def_pref_id number;
  l_mfq_query_id constant number := -99;
  l_plan_type number;
BEGIN
l_plan_type := p_plan_type;
  l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
  l_cat_set_id:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);

  update msc_form_query
  set number1 = l_cat_set_id,
      number2 = p_plan_type
  where query_id = l_mfq_query_id;
  if (sql%rowcount = 0) then
    INSERT INTO msc_form_query (QUERY_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, NUMBER1, NUMBER2) values
      (l_mfq_query_id, sysdate, -1, sysdate, -1, l_cat_set_id, p_plan_type);
  end if;
end store_user_pref;


function get_plan_type(p_plan_id number) return number is
    cursor c_plan (p_plan_id number) is
    select plan_type
    from msc_plans
    where plan_id = p_plan_id;

    l_plan_id number;
    l_plan_type number;
begin

   open c_plan(p_plan_id);
   fetch c_plan into l_plan_type;
   close c_plan;
   return l_plan_type;
end get_plan_type;

function get_plan_type_for_planlist(p_plan_list varchar2) return number is
    l_plan_id number;
begin
   if ( instr(p_plan_list,',') = 0 ) then
     l_plan_id := p_plan_list;
   else
     l_plan_id := substr(p_plan_list,1,instr(p_plan_list,',')-1);
   end if;

   return get_plan_type(l_plan_id);
end get_plan_type_for_planlist;

FUNCTION get_valid_rounding(arg_round number,
                            arg_plan_id number) return number is
  l_round number;
  l_def_pref_id number;
  l_plan_type number;
begin

  l_plan_type := get_plan_type(arg_plan_id);
  l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
  l_round := msc_get_name.GET_preference('SUMMARY_DECIMAL_PLACES',l_def_pref_id, l_plan_type);

  if (l_round is null) then
    return 6;
  end if;
  return l_round;

  --if (arg_round >= 0 and arg_round <= 10) then
     --return arg_round;
  --end if;
  --return 2;
end get_valid_rounding;

FUNCTION get_cat_set_id(arg_plan_list varchar2) RETURN NUMBER is
  l_cat_set_id number;
  l_def_pref_id number;
  l_plan_type number;
BEGIN
  l_plan_type := get_plan_type_for_planlist(arg_plan_list);
  l_def_pref_id := msc_get_name.get_default_pref_id(fnd_global.user_id);
  l_cat_set_id:= msc_get_name.GET_preference('CATEGORY_SET_ID',l_def_pref_id, l_plan_type);

  return l_cat_set_id;
END get_cat_set_id;

FUNCTION get_cat_list (p_cat_set_id number, p_cat_id number)
	RETURN VARCHAR2 is

  CURSOR c_cat (l_cat_set number, l_cat_id number) is
  SELECT distinct sr_category_id
  FROM msc_item_categories
  WHERE category_set_id = l_cat_set
  and category_name in (select category_name
    from msc_item_categories
    where category_set_id = l_cat_set
    and sr_category_id = l_cat_id
    and rownum = 1);

 retval varchar2(100) := null;
 l_temp number;
BEGIN
    open c_cat(p_cat_set_id , p_cat_id);
    loop
     fetch c_cat into l_temp;
     if (retval is null) then
       retval := l_temp;
     else
       retval := retval||','||l_temp;
     end if;
     exit when c_cat%notfound;
    end loop;
    close c_cat;

    put_line(retval);
  return retval;
END get_cat_list;

FUNCTION get_form_seq_id RETURN NUMBER is
  cursor c_seq is
  select msc_form_query_s.nextval
  from dual;

  l_seq_id number;
BEGIN
  open c_seq;
  fetch c_seq into l_seq_id;
  close c_seq;
  return l_seq_id;
END get_form_seq_id;

-- get the total number of bis or mfg periods for a given plan_id and calendar_type
FUNCTION get_num_periods(p_plan_id IN NUMBER, p_calendar_type IN NUMBER)
RETURN NUMBER IS

  CURSOR planCur(p_plan_id in NUMBER)
  IS
    SELECT sr_instance_id, organization_id
    FROM msc_plans
    WHERE plan_id = p_plan_id;

  CURSOR totalMfgPerCur(p_plan_id in NUMBER, p_sr_instance_id in number, p_org_id in number)
  IS
    SELECT count(distinct mpsd.period_start_date)
    FROM   msc_trading_partners tp,
          msc_period_start_dates mpsd,
          msc_plans mp
    WHERE  mpsd.calendar_code = tp.calendar_code
    and mpsd.sr_instance_id = tp.sr_instance_id
    and mpsd.exception_set_id = tp.calendar_exception_set_id
    and tp.sr_instance_id = p_sr_instance_id
    and tp.sr_tp_id = p_org_id
    and tp.partner_type =3
    and mp.plan_id = p_plan_id
    and mpsd.period_start_date between mp.data_start_date and mp.cutoff_date;
       --or mpsd.next_date between mp.data_start_date and mp.cutoff_date);

  CURSOR totalBisPerCur(p_plan_id in NUMBER)
  IS
     SELECT count(distinct mbp.period_name)
     FROM   msc_bis_periods mbp,
            msc_plans mp
     WHERE  mbp.organization_id = mp.organization_id
     and    mbp.sr_instance_id = mp.sr_instance_id
     and ((mbp.start_date between nvl(mp.curr_start_date, sysdate)
                            and mp.cutoff_date
         or mbp.end_date between nvl(mp.curr_start_date,sysdate)
                            and mp.cutoff_date) or
         (mp.curr_start_date between mbp.start_date and mbp.end_date))
     and mp.plan_id = p_plan_id;

  l_sr_instance_id NUMBER;
  l_org_id NUMBER;
  l_total_periods number;

BEGIN

  open planCur(p_plan_id);
  loop
    fetch planCur into l_sr_instance_id, l_org_id;
    exit when planCur%NOTFOUND;
  end loop;
  close planCur;

  if(p_calendar_type = g_calendar_type_mfg) then
    open totalMfgPerCur(p_plan_id, l_sr_instance_id, l_org_id);
    loop
      fetch totalMfgPerCur into l_total_periods;
      exit when totalMfgPerCur%NOTFOUND;
    end loop;
    close totalMfgPerCur;
  else
    open totalBisPerCur(p_plan_id);
    loop
      fetch totalBisPerCur into l_total_periods;
      exit when totalBisPerCur%NOTFOUND;
    end loop;
    close totalBisPerCur;
  end if;

  return l_total_periods;
END get_num_periods;


PROCEDURE populate_cost_savings(arg_ret_val IN OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_detail_level IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
      arg_org_list IN VARCHAR2 DEFAULT NULL,
			arg_category_list IN VARCHAR2 DEFAULT NULL,
      arg_item_list IN VARCHAR2 DEFAULT NULL,
			arg_date_list IN DATE DEFAULT NULL,
			arg_round in NUMBER DEFAULT NULL) IS

  l_seq_id number;
  l_cat_set_id number;

  l_sql_stmt varchar2(10000);
  l_select varchar2(300);
  l_insert varchar2(300);
  l_where varchar2(300);
  l_from varchar2(50);

  l_mfq_sql_stmt varchar2(10000);
  l_mfq_select varchar2(300);
  l_mfq_insert varchar2(600);
  l_mfq_where varchar2(300);
  l_mfq_from varchar2(50);

  l_plan_insert varchar2(300);
  l_plan_groupby varchar2(50);

  l_org_insert varchar2(300);
  l_org_groupby varchar2(100);

  l_cate_insert varchar2(300);
  l_cate_groupby varchar2(100);

  l_pr_insert varchar2(300);
  l_pr_groupby varchar2(200);

  l_plan_org_cate_insert varchar2(300);
  l_plan_org_cate_groupby varchar2(200);

  l_seq_id2 number;

  l_mfq_plan_insert varchar2(300);
  l_mfq_plan_groupby varchar2(50);

  l_mfq_org_insert varchar2(300);
  l_mfq_org_groupby varchar2(100);

  l_mfq_cate_insert varchar2(300);
  l_mfq_cate_groupby varchar2(100);

  l_mfq_plan_org_cate_insert varchar2(300);
  l_mfq_plan_org_cate_groupby varchar2(200);

  l_pr_date varchar2(30);
  l_next_pr_char varchar2(30);
  l_next_pr_date date;

  l_calendar_type number;

  l_round number;
BEGIN
  l_seq_id := get_form_seq_id;
  l_seq_id2 := get_form_seq_id;

  l_cat_set_id := get_cat_set_id(arg_plan_list);
  if (l_cat_set_id is null) then
    arg_ret_val := -1;
    return;
  end if;

  -- 3967991 bug fix
  l_round := 0;

  if ( arg_period_type = 'NULL'
        or  arg_period_type is null or  arg_period_type = 'FINANCIAL' ) then
    l_calendar_type := g_calendar_type_bis;
  elsif arg_period_type = 'MANUFACTURING' then
    l_calendar_type := g_calendar_type_mfg;
  end if;


  l_select := ' INSERT INTO msc_form_query ( '||
	' QUERY_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, '||
	' NUMBER5, NUMBER6, NUMBER7, NUMBER8, NUMBER9, NUMBER10, '||
	' NUMBER1, CHAR1, NUMBER2, NUMBER3, CHAR2, NUMBER4, CHAR3, DATE1, CHAR4, '||
	' NUMBER11, NUMBER12, CHAR5) ';

  l_insert := ' SELECT '||l_seq_id ||' , sysdate, -1,	sysdate, -1, '||
	' round(sum(ss_cost_no_post), '|| l_round || ' ), '||
	' round(sum(ss_cost_post), '|| l_round ||'), '||
	' round(sum(ss_cost_savings), '|| l_round ||' ), '||
	' round(sum(ss_value_no_post), '|| l_round ||' ), '||
	' round(sum(ss_value_post), '|| l_round ||' ), '||
	' round(sum(ss_value_savings), '|| l_round ||'), ';

  l_from := ' from msc_cost_savings_v ';

  l_plan_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), detail_date, plan_name, '||
	' to_number(null), to_number(null), to_char(null)';

  l_org_insert := ' plan_id, plan_name, '||
	' sr_instance_id, organization_id, org_code, '||
	' to_number(null), to_char(null), detail_date, plan_name||'' - ''||org_code ,'||
	' to_number(null), to_number(null), to_char(null)';

  l_cate_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' category_id, category_name, detail_date, plan_name||'' - ''||category_name ,'||
	' to_number(null), to_number(null), to_char(null)';

  l_pr_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), detail_date, plan_name||'' - ''||detail_date ,'||
	' detail_level, period_type, period_type_url ';

  l_plan_org_cate_insert := ' plan_id, plan_name, '||
	' sr_instance_id, organization_id, org_code, '||
	' category_id, category_name, detail_date, plan_name||''-''||org_code||''-''||category_name ,'||
	' to_number(null), to_number(null), to_char(null)';

  l_plan_groupby := ' GROUP BY detail_date, plan_id, plan_name ';
  l_org_groupby := ' GROUP BY detail_date, plan_id, plan_name, sr_instance_id, organization_id, org_code ';
  l_cate_groupby := ' GROUP BY detail_date, plan_id, plan_name, category_id, category_name ';
  l_pr_groupby := ' GROUP BY detail_date, detail_level, period_type, period_type_url,plan_id, plan_name ';
  l_plan_org_cate_groupby := ' GROUP BY detail_date, plan_id, plan_name, '
		||' sr_instance_id, organization_id, org_code, category_id, category_name ';

  --Form query to select from msc_form_query (used for view by plan, org, categ, plan-org-categ)
  --Inventory value has to be sumed across categories, orgs but has to be averaged across periods
  --To achieve this, we have 2 floow a 2 step process
  --first insert into mfq inv values whuch are sumed for the view by (plan , org or categ)
  --group by the period.
  --second avg the the inv value inserted into mfq -using the total number of periods in the plan
  --this calcualted avg in values are inserted into mfq to be used in the java layer.

  l_mfq_select := ' INSERT INTO msc_form_query ( '||
  ' QUERY_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, '||
  ' NUMBER5, NUMBER6, NUMBER7, NUMBER8, NUMBER9, NUMBER10, '||
  ' NUMBER1, CHAR1, NUMBER2, NUMBER3, CHAR2, NUMBER4, CHAR3, DATE1, CHAR4, '||
  ' NUMBER11, NUMBER12, CHAR5 ) ';

  l_mfq_insert := ' SELECT '||l_seq_id2 ||' , sysdate, -1,	sysdate, -1, '||
  ' round(sum(mfq1.NUMBER5), '|| l_round || ' ), '||
  ' round(sum(mfq1.NUMBER6), '|| l_round ||'), '||
  ' round(sum(mfq1.NUMBER7), '|| l_round ||' ), '||
  ' round(sum(mfq1.NUMBER8)/MSC_ANALYSIS_PKG.get_num_periods(mfq1.NUMBER1, '||l_calendar_type||'), '|| l_round ||' ), '||
  ' round(sum(mfq1.NUMBER9)/MSC_ANALYSIS_PKG.get_num_periods(mfq1.NUMBER1, '||l_calendar_type||'), '|| l_round ||' ), '||
  ' round(sum(mfq1.NUMBER10)/MSC_ANALYSIS_PKG.get_num_periods(mfq1.NUMBER1, '||l_calendar_type||'), '|| l_round ||'), ';

  l_mfq_from := ' from msc_form_query mfq1 ';

  l_mfq_plan_insert := ' mfq1.number1, mfq1.char1, '||
  ' to_number(null), to_number(null), to_char(null), '||
  ' to_number(null), to_char(null), to_date(null), mfq1.char1, '||
  ' to_number(null), to_number(null), to_char(null) ';

  l_mfq_plan_groupby := ' GROUP BY mfq1.number1, mfq1.char1 ';

  -- plan_id, plan_name, sr_instance_id, organization_id, org_code
  l_mfq_org_insert := ' mfq1.number1, mfq1.char1, '||
	' mfq1.NUMBER2, mfq1.NUMBER3, mfq1.CHAR2, '||
	' to_number(null), to_char(null), to_date(null), mfq1.char1||'' - ''||mfq1.char2 ,'||
	' to_number(null), to_number(null), to_char(null)';

  l_mfq_org_groupby := ' GROUP BY  mfq1.number1, mfq1.char1, mfq1.NUMBER2, mfq1.NUMBER3, mfq1.CHAR2 ';

  -- plan_id, plan_name, category_id, category_name
  l_mfq_cate_insert := ' mfq1.number1, mfq1.char1,  '||
	' to_number(null), to_number(null), to_char(null), '||
	' mfq1.NUMBER4, mfq1.CHAR3, to_date(null),  mfq1.char1||'' - ''||mfq1.CHAR3 ,'||
	' to_number(null), to_number(null), to_char(null)';

  l_mfq_cate_groupby := ' GROUP BY  mfq1.number1, mfq1.char1, mfq1.NUMBER4, mfq1.CHAR3 ';

  -- plan_id, plan_name, sr_instance_id, organization_id, org_code, category_id, category_name
  l_mfq_plan_org_cate_insert := ' mfq1.number1, mfq1.char1, '||
	' mfq1.NUMBER2, mfq1.NUMBER3, mfq1.CHAR2, '||
	' mfq1.NUMBER4, mfq1.CHAR3, to_date(null),  mfq1.char1||''-''||mfq1.char2||''-''||mfq1.CHAR3 ,'||
	' to_number(null), to_number(null), to_char(null)';

  l_mfq_plan_org_cate_groupby := ' GROUP BY mfq1.number1, mfq1.char1, ' ||
		' mfq1.NUMBER2, mfq1.NUMBER3, mfq1.CHAR2, mfq1.NUMBER4, mfq1.CHAR3 ';

  --where clause stmt begins
  --mandatory parameter
  if ( instr(arg_plan_list,',') = 0 ) then
    l_where := ' where plan_id = '||arg_plan_list;
    l_mfq_where := ' where mfq1.number1 = '||arg_plan_list || ' and query_id='|| l_seq_id;

  else
    l_where := l_where || ' where plan_id in ( '||arg_plan_list||') ';
    l_mfq_where := l_mfq_where || ' where number1 in ( ' ||arg_plan_list || ') and query_id='||
                                                                          l_seq_id;
  end if;

  --mandatory parameter
  l_where := l_where || ' and category_set_id = '||l_cat_set_id;

  --mandatory parameter calendar/periods
  if ( arg_detail_level = 'NULL'
        or  arg_detail_level is null or  arg_detail_level = '5' ) then
    l_where := l_where || ' and nvl(detail_level,0) = 0 ';
  elsif arg_detail_level = '6' then
    l_where := l_where || ' and nvl(detail_level,0) = 1 ';
  end if;

  if ( l_calendar_type = g_calendar_type_bis ) then
    l_where := l_where || ' and nvl(period_type,0) = 0 ';
  elsif (l_calendar_type = g_calendar_type_mfg) then
    l_where := l_where || ' and nvl(period_type,0) = 1 ';
  end if;

  if ( arg_date_list is not null ) then
     l_pr_date := to_char(trunc(arg_date_list),'MM-DD-YYYY');
     open c_next_pr (to_number(arg_plan_list), to_date(l_pr_date,'MM-DD-YYYY'),1, 0);
     fetch c_next_pr into l_next_pr_date;
     close c_next_pr;

     if ( l_next_pr_date is not null) then
       l_next_pr_char := to_char(trunc(l_next_pr_date),'MM-DD-YYYY');
       l_where := l_where || ' and detail_date between '||
	' to_date('''|| l_pr_date ||''', ''MM-DD-YYYY'') '||
	' and 	 to_date('''||l_next_pr_char ||''', ''MM-DD-YYYY'') ';
     else
       l_where := l_where || ' and detail_date >= '||
	' to_date('''|| l_pr_date ||''', ''MM-DD-YYYY'') ';
     end if;
  end if;

  --Optional parameter
  if ( arg_org_list <> 'NULL' ) then
    l_where := l_where || ' and (sr_instance_id,organization_id) in ('||arg_org_list||' ) ';
  end if;

  --Optional parameter
  if ( arg_category_list <> 'NULL' ) then
    --l_where := l_where || ' and category_id in ('||get_cat_list(l_cat_set_id,arg_category_list) ||')';
      l_where := l_where || ' and (sr_instance_id, category_id) in (' || arg_category_list || ')';
  end if;
  --where clause stmt ends


  if (arg_viewby = g_plan_viewby) then
    l_sql_stmt := l_select||l_insert||l_plan_insert||l_from||l_where||l_plan_groupby;
    put_line('plan view -intermediate'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    --arg_ret_val := l_seq_id;
    l_mfq_sql_stmt := l_mfq_select||l_mfq_insert||l_mfq_plan_insert||l_mfq_from||l_mfq_where||l_mfq_plan_groupby;
    put_line('plan view'||l_mfq_sql_stmt);
    msc_get_name.execute_dsql(l_mfq_sql_stmt);
    arg_ret_val := l_seq_id2;
    return;

  elsif (arg_viewby = g_org_viewby) then
    l_sql_stmt := l_select||l_insert||l_org_insert||l_from||l_where||l_org_groupby;
    put_line('org view-intermediate'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    --arg_ret_val := l_seq_id;
    --return;
    l_mfq_sql_stmt := l_mfq_select||l_mfq_insert||l_mfq_org_insert||l_mfq_from||l_mfq_where||l_mfq_org_groupby;
    put_line('org view'||l_mfq_sql_stmt);
    msc_get_name.execute_dsql(l_mfq_sql_stmt);
    arg_ret_val := l_seq_id2;
    return;

  elsif (arg_viewby = g_category_viewby) then
    l_sql_stmt := l_select||l_insert||l_cate_insert||l_from||l_where||l_cate_groupby;
     put_line('category view-intermediate'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    --arg_ret_val := l_seq_id;
    --return;
    l_mfq_sql_stmt := l_mfq_select||l_mfq_insert||l_mfq_cate_insert||l_mfq_from||
                                                    l_mfq_where||l_mfq_cate_groupby;
    put_line('category view'||l_mfq_sql_stmt);
    msc_get_name.execute_dsql(l_mfq_sql_stmt);
    arg_ret_val := l_seq_id2;
    return;

  elsif (arg_viewby = g_period_viewby) then
    l_sql_stmt := l_select||l_insert||l_pr_insert||l_from||l_where||l_pr_groupby;
    put_line('period view'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_week_viewby) then
    l_sql_stmt := l_select||l_insert||l_pr_insert||l_from||l_where||l_pr_groupby;
    put_line('week view'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_plan_org_cate_viewby) then
    l_sql_stmt := l_select||l_insert||l_plan_org_cate_insert||l_from||l_where||l_plan_org_cate_groupby;
    put_line('plan org cate view-intermediate'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    --arg_ret_val := l_seq_id;
    --return;
    l_mfq_sql_stmt := l_mfq_select||l_mfq_insert||l_mfq_plan_org_cate_insert||
                                    l_mfq_from||l_mfq_where||l_mfq_plan_org_cate_groupby;
    put_line('plan org cate view'||l_mfq_sql_stmt);
    msc_get_name.execute_dsql(l_mfq_sql_stmt);
    arg_ret_val := l_seq_id2;
    return;

  end if;
  arg_ret_val := -99;
  return;
END populate_cost_savings;

function populate_bis_dates(arg_plan_list varchar2, arg_viewby number,
  arg_period_type varchar2, arg_detail_level varchar2) return number is


  TYPE curType IS REF CURSOR;
  l_cursor curType;

  l_mfq_query_id number;
  l_sql_stmt varchar2(1000);
  l_where varchar2(1000);
  l_orderby varchar2(100);

  l_plan_id number;
  l_period_type number;
  l_detail_level number;
  l_date date;
  l_start_date date;
  l_end_date date;
  l_cur_plan_id number;
  l_temp_date date;
  plan_st_date date;
  plan_end_date date;


begin

  l_mfq_query_id := get_form_seq_id;
  l_cur_plan_id := -1;

  l_sql_stmt := ' SELECT distinct plan_id, period_type, detail_level, detail_date '||
    ' from msc_bis_inv_detail '||
    ' where plan_id in ('|| arg_plan_list ||')';

  if ( arg_detail_level = 'NULL'
        or  arg_detail_level is null or  arg_detail_level = '5' ) then
    l_where := l_where || ' and nvl(detail_level,0) = 0 ';
  elsif arg_detail_level = '6' then
    l_where := l_where || ' and nvl(detail_level,0) = 1 ';
  end if;

  if ( arg_period_type = 'NULL'
        or  arg_period_type is null or  arg_period_type = 'FINANCIAL' ) then
    l_where := l_where || ' and nvl(period_type,0) = 0 ';
  elsif arg_period_type = 'MANUFACTURING' then
    l_where := l_where || ' and nvl(period_type,0) = 1 ';
  end if;


  l_orderby := ' order by plan_id,  period_type, detail_level, detail_date ';

  l_sql_stmt := l_sql_stmt || l_where || l_orderby;

  open l_cursor for l_sql_stmt;
  loop
    fetch l_cursor into l_plan_id, l_period_type, l_detail_level, l_date;
    exit when l_cursor%notfound;

    if (l_cur_plan_id = -1) then
      l_cur_plan_id := l_plan_id;
    end if;

    open c_planinfo(l_plan_id);
    fetch c_planinfo into plan_st_date, plan_end_date;
    close c_planinfo;

    --multiple plan selected, insert last record of first plan
    if(l_cur_plan_id <> l_plan_id) and (l_end_date is not null) then

      l_temp_date := l_end_date +1;
      INSERT INTO msc_form_query (
        QUERY_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
        NUMBER1, number2, number3, date1, date2 )
      values
        ( l_mfq_query_id , sysdate, -1, sysdate, -1,
        l_cur_plan_id, nvl(l_period_type,0), nvl(l_detail_level,0), l_temp_date,
        plan_end_date);

      l_cur_plan_id := l_plan_id;
    end if;

    if ( l_start_date is null) then
      l_start_date := l_date;
    else
      l_end_date := l_date - 1;

      INSERT INTO msc_form_query (
        QUERY_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
        NUMBER1, number2, number3, date1, date2 )
      values
        ( l_mfq_query_id , sysdate, -1, sysdate, -1,
        l_plan_id, nvl(l_period_type,0), nvl(l_detail_level,0), l_start_date, l_end_date);

      l_start_date := l_date;
     end if;
  end loop;

  --to insert the last record for mbid on l_end_date
  if(l_end_date is not null) then
      l_end_date := l_end_date +1;

      INSERT INTO msc_form_query (
        QUERY_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY,
        NUMBER1, number2, number3, date1, date2 )
      values
        ( l_mfq_query_id , sysdate, -1, sysdate, -1,
        l_plan_id, nvl(l_period_type,0), nvl(l_detail_level,0), l_end_date, plan_end_date);
  end if;

  return l_mfq_query_id;

end populate_bis_dates;

PROCEDURE populate_srvlvl_breakdown(arg_ret_val IN  OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_detail_level IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
                        arg_org_list IN VARCHAR2 DEFAULT NULL,
			arg_category_list IN VARCHAR2 DEFAULT NULL,
                        arg_item_list IN VARCHAR2 DEFAULT NULL,
                        arg_demand_class_list IN VARCHAR2 DEFAULT NULL,
                        arg_year_from IN DATE DEFAULT NULL,
                        arg_year_to IN DATE DEFAULT NULL,
			arg_date_list IN DATE DEFAULT NULL,
			arg_round in NUMBER DEFAULT NULL) IS
  l_seq_id number;
  l_cat_set_id number;

  l_sql_stmt varchar2(10000);
  l_select varchar2(300);
  l_insert varchar2(500);
  l_where varchar2(300);
  l_from varchar2(50);

  l_plan_insert varchar2(300);
  l_plan_groupby varchar2(200);
  l_plan_dflt_insert varchar2(200);

  l_org_insert varchar2(300);
  l_org_groupby varchar2(200);
  l_org_dflt_insert varchar2(200);

  l_cate_insert varchar2(300);
  l_cate_groupby varchar2(200);
  l_cate_dflt_insert varchar2(200);

  l_item_insert varchar2(300);
  l_item_groupby varchar2(200);
  l_item_dflt_insert varchar2(200);

  l_demand_class_insert varchar2(300);
  l_demand_class_groupby varchar2(200);
  l_demand_class_dflt_insert varchar2(200);

  l_pr_insert varchar2(300);
  l_pr_groupby varchar2(200);
  l_pr_dflt_insert varchar2(200);

  l_temp_from_date varchar2(30);
  l_temp_to_date varchar2(30);

  l_pr_date varchar2(30);
  l_next_pr_char varchar2(30);
  l_next_pr_date date;

  l_round number;
BEGIN
  l_seq_id := get_form_seq_id;
  l_cat_set_id := get_cat_set_id(arg_plan_list);
  if (l_cat_set_id is null) then
    arg_ret_val := -1;
    return;
  end if;
  l_round := get_valid_rounding(arg_round, -23453);

  l_select := ' INSERT INTO msc_form_query ( '||
	' QUERY_ID, LAST_UPDATE_DATE, LAST_UPDATED_BY, CREATION_DATE, CREATED_BY, '||
	' NUMBER10, NUMBER11, NUMBER12,'||
	' NUMBER1, CHAR1, NUMBER2, NUMBER3, CHAR2, '||
	' NUMBER4, CHAR3, '||
	' NUMBER5, CHAR4, '||
	' CHAR5, DATE1, CHAR6, '||
	' number14, number15, char7 ) ';

  l_insert := ' SELECT '||l_seq_id ||' , sysdate, -1,	sysdate, -1, '||
        '  round(
            decode(sum(achieved_service_level_qty2), 0, 0,
            sum(achieved_service_level_qty1)/sum(achieved_service_level_qty2))
        ,'||l_round ||'),'||
        '  round(avg(target_service_level),'||l_round ||'),';

  l_from := ' from msc_srvlvl_breakdown_v ';

  l_plan_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_char(null), to_date(null) , plan_name, '||
        ' to_number(null), to_number(null), to_char(null) ';

  l_org_insert := ' plan_id, plan_name, '||
	' sr_instance_id, organization_id, org_code, '||
	' to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_char(null), to_date(null) , plan_name||'' - ''||org_code, ' ||
        ' to_number(null), to_number(null), to_char(null) ';

  l_cate_insert := ' plan_id, plan_name,'||
	' to_number(null), to_number(null), to_char(null), '||
	' category_id, category_name, '||
	' to_number(null), to_char(null), '||
	' to_char(null), to_date(null) ,  plan_name||'' - ''||category_name, ' ||
        ' to_number(null), to_number(null), to_char(null) ';

  l_item_insert := ' plan_id, plan_name,'||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' inventory_item_id, item_name, '||
	' to_char(null), to_date(null) ,  plan_name||'' - ''||item_name, ' ||
        ' to_number(null), to_number(null), to_char(null) ';

  l_demand_class_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' demand_class, to_date(null) , '||
	'  plan_name||'' - ''||demand_class, ' ||
        ' to_number(null), to_number(null), to_char(null) ';

  l_pr_insert := ' plan_id, plan_name,'||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_char(null), detail_date ,  plan_name||'' - ''||detail_date, ' ||
	' period_type, detail_level, period_type_url ';

  l_plan_groupby := ' GROUP BY plan_id, plan_name ';
  l_org_groupby := ' GROUP BY plan_id, plan_name, sr_instance_id, organization_id, org_code ';
  l_cate_groupby := ' GROUP BY plan_id, plan_name, category_id, category_name ';
  l_item_groupby := ' GROUP BY plan_id, plan_name, inventory_item_id, item_name ';
  l_demand_class_groupby := ' GROUP BY plan_id, plan_name, demand_class ';
  l_pr_groupby := ' GROUP BY detail_date, period_type, detail_level, period_type_url, plan_id, plan_name ';

  l_plan_dflt_insert := ' msc_analysis_pkg.get_dflt_value(plan_id, null, 0), ';
  l_org_dflt_insert := ' to_number(null), ';
  l_cate_dflt_insert := ' msc_analysis_pkg.get_dflt_value(plan_id, null, 6, null, '||
	' null, null, null, null, null, category_id), ';
  l_item_dflt_insert := ' to_number(null), ';
  l_demand_class_dflt_insert := ' msc_analysis_pkg.get_dflt_value(plan_id, null, 4, null, null, '||
	' null, demand_class, null, null, null), ';
  l_pr_dflt_insert := ' to_number(null), ';

  --where clause stmt begins
  --mandatory parameter
  if ( instr(arg_plan_list,',') = 0 ) then
    l_where := ' where plan_id = '||arg_plan_list;
  else
    l_where := l_where || ' where plan_id in ( '||arg_plan_list||') ';
  end if;
put_line('8');
  --mandatory parameter
  l_where := l_where || ' and category_set_id = '||l_cat_set_id;

 --mandatory parameter calendar/periods
  if ( arg_period_type = 'NULL'
	or  arg_period_type is null or  arg_period_type = 'FINANCIAL' ) then
    l_where := l_where || ' and nvl(period_type,0) = 0 ';
  elsif arg_period_type = 'MANUFACTURING' then
    l_where := l_where || ' and nvl(period_type,0) = 1 ';
  end if;

  if arg_period_type = 'MANUFACTURING' then
    if (arg_viewby = g_period_viewby) then
      l_where := l_where || ' and nvl(detail_level,0) = 0 ';
    else
      l_where := l_where || ' and nvl(detail_level,0) = 1 ';
    end if;
  else
    if ( arg_detail_level = 'NULL'
	or  arg_detail_level is null or  arg_detail_level = '5' ) then
      l_where := l_where || ' and nvl(detail_level,0) = 0 ';
    elsif arg_detail_level = '6' then
      l_where := l_where || ' and nvl(detail_level,0) = 1 ';
    end if;
  end if;

  if ( arg_date_list is not null ) then
     l_pr_date := to_char(trunc(arg_date_list),'MM-DD-YYYY');
     open c_next_pr (to_number(arg_plan_list), to_date(l_pr_date,'MM-DD-YYYY'), 1, 0);
     fetch c_next_pr into l_next_pr_date;
     close c_next_pr;

     if ( l_next_pr_date is not null) then
       l_next_pr_char := to_char(trunc(l_next_pr_date),'MM-DD-YYYY');
       l_where := l_where || ' and detail_date between '||
        ' to_date('''|| l_pr_date ||''', ''MM-DD-YYYY'') '||
        ' and    to_date('''||l_next_pr_char ||''', ''MM-DD-YYYY'') ';
     else
       l_where := l_where || ' and detail_date >= '||
        ' to_date('''|| l_pr_date ||''', ''MM-DD-YYYY'') ';
     end if;
  end if;

  --Optional parameter
  if ( arg_org_list <> 'NULL' ) then
    l_where := l_where || ' and (sr_instance_id,organization_id) in ('||arg_org_list||' ) ';
  end if;

  --Optional parameter
  if ( arg_category_list <> 'NULL' ) then
    l_where := l_where || ' and (sr_instance_id, category_id) in (' || arg_category_list || ')';

    --if (instr(arg_category_list,',') = 0) then
      --l_where := l_where || ' and category_id = '||arg_category_list;
    --else
      --l_where := l_where || ' and category_id in ('||arg_category_list||')';
    --end if;
   end if;

  --Optional parameter
  if ( arg_demand_class_list <> 'NULL' ) then
    if (instr(arg_demand_class_list,',') = 0) then
      l_where := l_where || ' and demand_class = '''||arg_demand_class_list||'''';
    else
      l_where := l_where || ' and demand_class in ('||arg_demand_class_list||')';
    end if;
   end if;

  --Optional parameter
  if (( arg_year_from is not null ) and (arg_year_to is not null)) then
     l_temp_from_date := to_char(trunc(arg_year_from),'MM-DD-YYYY');
     l_temp_to_date := to_char(trunc(arg_year_to),'MM-DD-YYYY');
     l_where := l_where || ' and detail_date between '||
	' to_date('''|| l_temp_from_date ||''', ''MM-DD-YYYY'') '||
	' and 	 to_date('''||l_temp_to_date ||''', ''MM-DD-YYYY'') ';
  elsif ( arg_year_to is not null) then
     l_temp_to_date := to_char(trunc(arg_year_to),'MM-DD-YYYY');
     l_where := l_where || ' and detail_date <= '||
	' to_date('''|| l_temp_to_date ||''', ''MM-DD-YYYY'') ';
  elsif ( arg_year_from is not null ) then
     l_temp_from_date := to_char(trunc(arg_year_from),'MM-DD-YYYY');
     l_where := l_where || ' and detail_date >= '||
	' to_date('''|| l_temp_from_date ||''', ''MM-DD-YYYY'') ';
  end if;

  --where clause stmt ends
  if (arg_viewby = g_plan_viewby) then
    l_sql_stmt := l_select||l_insert||l_plan_dflt_insert||l_plan_insert||l_from||l_where||l_plan_groupby;
    put_line(l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_org_viewby) then
    l_sql_stmt := l_select||l_insert||l_org_dflt_insert||l_org_insert||l_from||l_where||l_org_groupby;
    put_line('plan view'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;

    return;
  elsif (arg_viewby = g_category_viewby) then
    l_sql_stmt := l_select||l_insert||l_cate_dflt_insert||l_cate_insert||l_from||l_where||l_cate_groupby;
    put_line('category view'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_item_viewby) then
    l_sql_stmt := l_select||l_insert||l_item_dflt_insert||l_item_insert||l_from||l_where||l_item_groupby;
    put_line('item view'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_demand_class_viewby) then
    l_sql_stmt := l_select||l_insert||l_demand_class_dflt_insert
       ||l_demand_class_insert||l_from||l_where||l_demand_class_groupby;
    put_line('demand class'||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_period_viewby) then
    l_sql_stmt := l_select||l_insert||l_pr_dflt_insert||l_pr_insert||l_from||l_where||l_pr_groupby;
    put_line('period view '||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_week_viewby) then
    l_sql_stmt := l_select||l_insert||l_pr_dflt_insert||l_pr_insert||l_from||l_where||l_pr_groupby;
    put_line(' week view '||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  end if;

  arg_ret_val := -99;
  return;
END populate_srvlvl_breakdown;

function get_tp_cost ( arg_period_type IN VARCHAR2, arg_detail_level IN VARCHAR2,
	arg_plan in number, arg_instance in number, arg_org in number,
	arg_item in number,
	arg_detail_date date)  return number IS

  cursor c_next_pr_local (p_plan in number, p_curr_pr_date in date,
	p_period_type in number, p_detail_level in number ) is
  select min(detail_date)-1
  from msc_bis_inv_detail
  where plan_id = p_plan
  and sr_instance_id = arg_instance
  and organization_id = arg_org
  and nvl(period_type,0) = p_period_type
  and nvl(detail_level,0) = p_detail_level
  and detail_date > p_curr_pr_date;

  v_tp_cost number := 0;
  l_prev_date date;
  l_next_date date;

  l_period_type number;
  l_detail_level number;

  plan_st_date date;
  plan_end_date date;
begin
  l_period_type := nvl(arg_period_type,0);
  l_detail_level := nvl(arg_detail_level,0);

  open c_planinfo(arg_plan);
  fetch c_planinfo into plan_st_date, plan_end_date;
  close c_planinfo;

   --open c_prev_pr (arg_plan, arg_instance, arg_org, arg_item, arg_detail_date, l_period_type, l_detail_level);
   --fetch c_prev_pr into l_prev_date;
   --close c_prev_pr;

   open c_next_pr_local (arg_plan, arg_detail_date, l_period_type, l_detail_level);
   fetch c_next_pr_local into l_next_date;
   close c_next_pr_local;


   l_prev_date := arg_detail_date;
   --l_next_date := arg_detail_date;

   if (l_prev_date is null or trunc(l_prev_date) < trunc(plan_st_date)) then
    l_prev_date := plan_st_date;
   elsif (trunc(l_next_date) < trunc(plan_st_date)) then
     return 0;
   elsif (l_next_date is null or trunc(l_next_date) > trunc(plan_end_date) ) then
    l_next_date := plan_end_date;
   end if;

   v_tp_cost := msc_analysis_pkg.get_plan_service_level(arg_plan, g_tp_cost, arg_instance, arg_org, arg_item, l_prev_date, l_next_date);

  return round(v_tp_cost,2);
end get_tp_cost;

PROCEDURE populate_cost_breakdown(arg_ret_val IN  OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_detail_level IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
                        arg_org_list IN VARCHAR2 DEFAULT NULL,
			arg_category_list IN VARCHAR2 DEFAULT NULL,
                        arg_item_list IN VARCHAR2 DEFAULT NULL,
                        arg_year_from IN DATE DEFAULT NULL,
                        arg_year_to IN DATE DEFAULT NULL,
			arg_date_list IN DATE DEFAULT NULL,
			arg_round in NUMBER DEFAULT NULL) IS
  l_seq_id number;
  l_cat_set_id number;

  l_sql_stmt varchar2(10000);
  l_select varchar2(500);
  l_insert varchar2(1500);
  l_where varchar2(400);
  l_from varchar2(50);
  l_from_maa varchar2(50);

  l_plan_insert varchar2(300);
  l_plan_groupby varchar2(200);

  l_org_insert varchar2(300);
  l_org_groupby varchar2(200);

  l_cate_insert varchar2(300);
  l_cate_groupby varchar2(200);

  l_item_insert varchar2(300);
  l_item_groupby varchar2(200);

  l_pr_insert varchar2(300);
  l_pr_groupby varchar2(200);

  l_temp_from_date varchar2(30);
  l_temp_to_date varchar2(30);

  l_pr_date varchar2(30);
  l_next_pr_char varchar2(30);
  l_next_pr_date date;

  l_mfq_query_id number := -999;

  l_round number;
  l_plan_id number;
BEGIN
  l_seq_id := get_form_seq_id;
  l_cat_set_id := get_cat_set_id(arg_plan_list);
  if (l_cat_set_id is null) then
    arg_ret_val := -1;
    return;
  end if;
  l_round := get_valid_rounding(arg_round, -23453);

  if(fnd_profile.value('MSC_IO_UI_PERF_TUNE')='Y') then
    g_perf_profile_on := TRUE;
  else
    g_perf_profile_on := FALSE;
  end if;

  --put_line('MSC_IO_UI_PERF_TUNE ='||fnd_profile.value('MSC_IO_UI_PERF_TUNE'));
  if(g_perf_profile_on) then
    l_from := ' from msc_cost_breakdown_notpcost_v ';
  else
    l_from := ' from msc_cost_breakdown_v ';
    l_mfq_query_id := populate_bis_dates(arg_plan_list, arg_viewby, arg_period_type, arg_detail_level);
  end if;

  l_select := ' insert into msc_form_query ( '||
	' query_id, last_update_date, last_updated_by, creation_date, created_by, '||
	' number6, number7, number8, number9, number10, number11, number12, number13, number16,'||
  ' number17, number18, number19, number20,'||
	' number1, char1, number2, number3, char2, '||
	' number4, char3, '||
	' number5, char4, '||
	' date1, char5, number14, number15, char6 ) ';
  l_insert := ' select '||l_seq_id ||' , sysdate, -1,	sysdate, -1, '||
	' round(sum(nvl(planned_production_cost,0)), '|| l_round ||' ), '||
	' round(sum(nvl(planned_carrying_cost,0)), '|| l_round ||' ), '||
  ' round(sum(nvl(planned_purchasing_cost,0)), '||l_round ||' ), '||
	' round(sum(nvl(planned_tp_cost,0)), '|| l_round ||' ), '||
	' decode(sum(planned_total_cost),0,0, '||
	' round(nvl(sum(planned_production_cost)/sum(planned_total_cost),0)* 100, '||l_round||' )), '||
	' decode(sum(planned_total_cost),0,0, '||
	' round(nvl(sum(planned_carrying_cost)/sum(planned_total_cost),0)* 100, '||l_round||' )), '||
	' decode(sum(planned_total_cost),0,0, '||
	' round(nvl(sum(planned_purchasing_cost)/sum(planned_total_cost),0)* 100, '||l_round||' )), '||
	' decode(sum(planned_total_cost),0,0, '||
	' round(nvl(sum(planned_tp_cost)/sum(planned_total_cost),0)* 100,'|| l_round ||' )), '||
	' round(sum(nvl(planned_revenue,0)), '|| l_round ||' ), '||
	' round(sum(nvl(int_repair_cost,0)), '|| l_round ||' ), '||
	' round(sum(nvl(ext_repair_cost,0)), '|| l_round ||' ), '||
	' decode(sum(planned_total_cost),0,0, '||
	' round(nvl(sum(int_repair_cost)/sum(planned_total_cost),0)* 100,'|| l_round ||' )), '||
	' decode(sum(planned_total_cost),0,0, '||
	' round(nvl(sum(ext_repair_cost)/sum(planned_total_cost),0)* 100,'|| l_round ||' )), ';

  l_from_maa := ' from msc_analysis_aggregate ';

  l_plan_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_date(null) , plan_name, '||
	' to_number(null), to_number(null), to_char(null) ';

  l_org_insert := ' plan_id, plan_name,  '||
	' sr_instance_id, organization_id, org_code, '||
	' to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_date(null) , plan_name||'' - ''||org_code, '||
	' to_number(null), to_number(null), to_char(null) ';

  l_cate_insert := ' plan_id, plan_name,  '||
	' to_number(null), to_number(null), to_char(null), '||
	' category_id, category_name, '||
	' to_number(null), to_char(null), '||
	' to_date(null) , plan_name||'' - ''||category_name, '||
	' to_number(null), to_number(null), to_char(null) ';

  l_item_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' inventory_item_id, item_name, '||
	' to_date(null) , plan_name||'' - ''||item_name ,'||
	' to_number(null), to_number(null), to_char(null) ';

  l_pr_insert := ' plan_id, plan_name, '||
	' to_number(null), to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' to_number(null), to_char(null), '||
	' detail_date , plan_name||'' - ''||detail_date ,'||
	' detail_level, period_type, period_type_url ';

  l_plan_groupby := ' GROUP BY plan_id, plan_name ';
  l_org_groupby := ' GROUP BY plan_id, plan_name, sr_instance_id, organization_id, org_code ';
  l_cate_groupby := ' GROUP BY plan_id, plan_name, category_id, category_name ';
  l_item_groupby := ' GROUP BY plan_id, plan_name, inventory_item_id, item_name ';
  l_pr_groupby := ' GROUP BY detail_date, detail_level, period_type, period_type_url, plan_id, plan_name';

  --where clause stmt begins

  --mandatory parameter
  if ( instr(arg_plan_list,',') = 0 ) then
    l_where := ' where plan_id = '||arg_plan_list;
  else
    l_where := l_where || ' where plan_id in ( '||arg_plan_list||') ';
  end if;

  --mandatory parameter
  l_where := l_where || ' and category_set_id = '||l_cat_set_id;

  if(g_perf_profile_on <> TRUE) then
    l_where := l_where || ' and query_id = '||l_mfq_query_id;
 end if;

  --mandatory parameter calendar/periods

  if ( arg_detail_level = 'NULL'
        or  arg_detail_level is null or  arg_detail_level = '5' ) then
    l_where := l_where || ' and nvl(detail_level,0) = 0 ';
  elsif arg_detail_level = '6' then
    l_where := l_where || ' and nvl(detail_level,0) = 1 ';
  end if;

  if ( arg_period_type = 'NULL'
        or  arg_period_type is null or  arg_period_type = 'FINANCIAL' ) then
    l_where := l_where || ' and nvl(period_type,0) = 0 ';
  elsif arg_period_type = 'MANUFACTURING' then
    l_where := l_where || ' and nvl(period_type,0) = 1 ';
  end if;


  if ( arg_date_list is not null ) then
     l_pr_date := to_char(trunc(arg_date_list),'MM-DD-YYYY');
     open c_next_pr (to_number(arg_plan_list), to_date(l_pr_date,'MM-DD-YYYY'), 1, 0);
     fetch c_next_pr into l_next_pr_date;
     close c_next_pr;

     if ( l_next_pr_date is not null) then
       l_next_pr_char := to_char(trunc(l_next_pr_date),'MM-DD-YYYY');
       l_where := l_where || ' and detail_date between '||
        ' to_date('''|| l_pr_date ||''', ''MM-DD-YYYY'') '||
        ' and    to_date('''||l_next_pr_char ||''', ''MM-DD-YYYY'') ';
     else
       l_where := l_where || ' and detail_date >= '||
        ' to_date('''|| l_pr_date ||''', ''MM-DD-YYYY'') ';
     end if;
  end if;


  --Optional parameter
  if ( arg_org_list <> 'NULL' ) then
    l_where := l_where || ' and (sr_instance_id,organization_id) in ('||arg_org_list||') ';
  end if;

  --Optional parameter
  if ( arg_category_list <> 'NULL' ) then
    l_where := l_where || ' and (sr_instance_id, category_id) in (' || arg_category_list || ')';
   end if;

  --Optional parameter
  if (( arg_year_from is not null ) and (arg_year_to is not null)) then
     l_temp_from_date := to_char(trunc(arg_year_from),'MM-DD-YYYY');
     l_temp_to_date := to_char(trunc(arg_year_to),'MM-DD-YYYY');
     l_where := l_where || ' and detail_date between '||
	' to_date('''|| l_temp_from_date ||''', ''MM-DD-YYYY'') '||
	' and 	 to_date('''||l_temp_to_date ||''', ''MM-DD-YYYY'') ';
  elsif ( arg_year_to is not null) then
     l_temp_to_date := to_char(trunc(arg_year_to),'MM-DD-YYYY');
     l_where := l_where || ' and detail_date <= '||
	' to_date('''|| l_temp_to_date ||''', ''MM-DD-YYYY'') ';
  elsif ( arg_year_from is not null ) then
     l_temp_from_date := to_char(trunc(arg_year_from),'MM-DD-YYYY');
     l_where := l_where || ' and detail_date >= '||
	' to_date('''|| l_temp_from_date ||''', ''MM-DD-YYYY'') ';
  end if;
  --where clause stmt ends

  if (arg_viewby = g_plan_viewby) then
    if(arg_org_list <> 'NULL' or arg_category_list <> 'NULL' or  arg_year_from is not null or g_perf_profile_on=FALSE) then
      l_sql_stmt := l_select||l_insert||l_plan_insert||l_from||l_where||l_plan_groupby;
      put_line('plan view '||l_sql_stmt);
    else
      l_sql_stmt := l_select||l_insert||l_plan_insert||l_from_maa||l_where|| ' and record_type=4 ' ||l_plan_groupby;
      put_line('plan view for plan search only'||l_sql_stmt);
    end if;
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_org_viewby) then
    l_sql_stmt := l_select||l_insert||l_org_insert||l_from||l_where||l_org_groupby;
    put_line('org view '||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_category_viewby) then
    if(arg_org_list <> 'NULL' or arg_category_list <> 'NULL' or  arg_year_from is not null or g_perf_profile_on=FALSE) then
      l_sql_stmt := l_select||l_insert||l_cate_insert||l_from||l_where||l_cate_groupby;
      put_line('cat view '||l_sql_stmt);
    else
      l_sql_stmt := l_select||l_insert||l_cate_insert||l_from_maa||l_where|| ' and record_type=4 ' ||l_cate_groupby;
      put_line('cat view for plan search only '||l_sql_stmt);
    end if;
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_item_viewby) then
    l_sql_stmt := l_select||l_insert||l_item_insert||l_from||l_where||l_item_groupby;
    put_line('item view '||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_period_viewby) then
    l_sql_stmt := l_select||l_insert||l_pr_insert||l_from||l_where||l_pr_groupby;
    put_line('period view '||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  elsif (arg_viewby = g_week_viewby) then
    l_sql_stmt := l_select||l_insert||l_pr_insert||l_from||l_where||l_pr_groupby;
    put_line('week view '||l_sql_stmt);
    msc_get_name.execute_dsql(l_sql_stmt);
    arg_ret_val := l_seq_id;
    return;
  end if;
  arg_ret_val := -99;
  return;
END populate_cost_breakdown;

PROCEDURE populate_srvlvl_profit(arg_ret_val IN  OUT NOCOPY VARCHAR2,
			arg_period_type IN VARCHAR2,
			arg_viewby IN VARCHAR2,
			arg_plan_list IN VARCHAR2,
			arg_round in NUMBER DEFAULT NULL) IS
  l_seq_id number;
  l_cat_set_id number;

  l_cursor varchar2(4000);

  l_tp_cost number;
  l_attained number;
  l_target number;
  l_plan_name varchar2(20);

  l_plnd_prod_cost number;
  l_plnd_carr_cost number;
  l_plnd_purc_cost number;
  l_plnd_tot_cost number;
  l_plnd_rev number;
  l_plnd_gross_profit number;
  l_plnd_gross_profit_pct number;
  l_inv_value number;
  l_plan_id number;
  l_ext_repair_cost number;
  l_int_repair_cost number;

  l_plan_type number;
  l_otype1 number;
  l_otype2 number;
  l_otype3 number;

  l_calc_gross_profit_pct number;

CURSOR PERIOD_CURSOR (p_plan_id in number) IS
     SELECT count(*)
     FROM   msc_bis_periods mbp,
            msc_plans mp
     WHERE  mbp.organization_id = mp.organization_id
     and    mbp.sr_instance_id = mp.sr_instance_id
     and ((mbp.start_date between nvl(mp.data_start_date, sysdate)
                            and mp.cutoff_date
         or mbp.end_date between nvl(mp.data_start_date,sysdate)
                            and mp.cutoff_date) or
  (mp.data_start_date between mbp.start_date and mbp.end_date))
     and mp.plan_id = p_plan_id
     and mbp.adjustment_period_flag ='N'
     order by mbp.start_date;

  cursor c_tp_cost_new (p_plan_id in number, l_otype1 in number, l_otype2 in number, l_otype3 in number) is
  select round(sum(nvl(((ms.new_order_quantity * msi.unit_weight)  * mism.cost_per_weight_unit),0)),6)
  from msc_supplies ms,
    msc_system_items msi,
    msc_interorg_ship_methods mism,
    msc_plans mp
  WHERE ms.plan_id = p_plan_id
    and ms.organization_id <> ms.source_organization_id
    and ms.order_type in (l_otype1, l_otype2, l_otype3)
    and ms.plan_id = msi.plan_id
    and ms.organization_id = msi.organization_id
    and ms.sr_instance_id = msi.sr_instance_id
    and ms.inventory_item_id = msi.inventory_item_id
    and ms.plan_id = mism.plan_id
    and ms.organization_id = mism.to_organization_id
    and ms.sr_instance_id = mism.sr_instance_id
    and ms.source_organization_id = mism.from_organization_id
    and ms.source_sr_instance_id = mism.sr_instance_id2
    and ms.ship_method = mism.ship_method
    and ms.plan_id = mp.plan_id
    and trunc(ms.new_dock_date) between mp.curr_start_date and  mp.curr_cutoff_date ;

  l_period_count number;
  c1   CurTyp;

  l_round number;

  l_inst_id number;
  l_org_id number;
  l_run_qty number;

  l_cursor2 varchar2(100);
  c2   CurTyp;
  ll_plan_id number;

BEGIN
  arg_ret_val := -99;

  l_seq_id := get_form_seq_id;
  l_cat_set_id := get_cat_set_id(arg_plan_list);
  if (l_cat_set_id is null) then
    arg_ret_val := -1;
    return;
  end if;

  l_plan_type := get_plan_type_for_planlist(arg_plan_list);
  if(l_plan_type = 9) then
    l_otype1 := 51;
    l_otype2 := 77;
    l_otype3 := 78;
  else
    l_otype1 := 5;
    l_otype2 := 11;
    l_otype3 := -99;
  end if;

put_line(' query id : '||l_seq_id);

  l_cursor := ' select planned_production_cost '||
	' ,planned_carrying_cost, planned_purchasing_cost '||
	' ,planned_total_cost, planned_revenue '||
	' ,planned_gross_profit, planned_gross_profit_pct '||
	' ,inventory_value, plan_id '||
	' ,ext_repair_cost, int_repair_cost '||
	' from  msc_srvlvl_profit_v '||
   ' where plan_id = :1 ';
	--' where plan_id in ('||arg_plan_list ||') ';
	--||' and category_set_id ='||l_cat_set_id;

  l_cursor2 := '  select plan_id from msc_plans where plan_id in (' ||arg_plan_list ||') ';
  OPEN c2 FOR l_cursor2;
  loop
    FETCH c2 INTO ll_plan_id;
    EXIT WHEN c2%NOTFOUND;

  OPEN c1 FOR l_cursor using ll_plan_id;
  LOOP
    FETCH c1 INTO l_plnd_prod_cost, l_plnd_carr_cost, l_plnd_purc_cost, l_plnd_tot_cost,
		  l_plnd_rev, l_plnd_gross_profit, l_plnd_gross_profit_pct, l_inv_value, l_plan_id,
      l_ext_repair_cost, l_int_repair_cost;
    EXIT WHEN c1%NOTFOUND;
    l_plan_name := msc_get_name.plan_name(l_plan_id);

    l_attained := msc_analysis_pkg.get_plan_service_level(l_plan_id, g_attained_sl);
    l_target := msc_analysis_pkg.get_plan_service_level(l_plan_id, g_target_sl);
    l_tp_cost := 0;

    if(g_perf_profile_on <> TRUE) then
      open c_tp_cost_new(l_plan_id, l_otype1, l_otype2, l_otype3);
      fetch c_tp_cost_new into l_tp_cost;
      close c_tp_cost_new;
    end if;

    if (l_tp_cost is null) then
       l_tp_cost := 0;
    end if;

    l_plnd_gross_profit := l_plnd_rev - (l_plnd_tot_cost+l_tp_cost);
    if (l_plnd_rev = 0) then
      l_calc_gross_profit_pct := 0;
    else
      l_calc_gross_profit_pct := round((l_plnd_rev -
	(l_plnd_tot_cost + l_tp_cost)) * 100 / l_plnd_rev, 2);
    end if;

    open PERIOD_CURSOR(l_plan_id);
    fetch PERIOD_CURSOR into l_period_count;
    close PERIOD_CURSOR;

    if (l_period_count <> 0 ) then
      l_inv_value := l_inv_value/ l_period_count;
    end if;
    l_round := get_valid_rounding(arg_round, -23453);

    INSERT INTO MSC_FORM_QUERY
      (
	query_id,
	last_update_date,
        last_updated_by,
        creation_date,
        created_by,
	number1,
	char1,
	number2,
	number3,
	number4,
	number5,
	number6,
	number7,
	number8,
	number9,
	number10,
	number11,
	number12,
  number13,
	number14
      )
      VALUES
      (
	 l_seq_id,
	 sysdate,
	 -1,
	 sysdate,
	 -1,
	 l_plan_id,
	 l_plan_name,
 	 round(nvl(l_attained,0), l_round),
   round(nvl(l_target,0), l_round),
	 round(nvl(l_plnd_prod_cost,0), l_round),
	 round(nvl(l_plnd_carr_cost,0), l_round),
	 round(nvl(l_plnd_purc_cost,0), l_round),
	 round(nvl(l_tp_cost,0), l_round),
	 round(nvl(l_plnd_tot_cost + l_tp_cost,0), l_round),
	 round(nvl(l_plnd_rev,0), l_round),
	 round(nvl(l_plnd_gross_profit,0), l_round),
	 round(nvl(l_calc_gross_profit_pct,0), l_round),
	 round(nvl(l_inv_value,0), l_round),
   round(nvl(l_ext_repair_cost,0), l_round),
   round(nvl(l_int_repair_cost,0), l_round)
      );
  END LOOP;
  CLOSE c1;

  end loop;
  CLOSE c2;

  arg_ret_val := l_seq_id;
  return ;
END populate_srvlvl_profit;

function get_plan_service_level(p_plan_id number, p_type number,
  p_instance_id in number default null, p_organization_id in number default null,
  p_item_id in number default null,
  p_start_date date default null, p_end_date date default null) return number is

  the_cursor CurTyp;
  sql_stat varchar2(3000);

  v_org_id number;
  v_instance_id number;

  v_qty number;
  v_qty2 number;
  v_service number;
  v_constraint number;
  v_plan_type number;

  v_run_qty number;
  v_run_qty2 number;
  v_dmd_count number;
  v_cost number;

  v_dummy number;

  cursor c_plan_orgs (l_plan_id number) is
  select sr_instance_id, organization_id
  from msc_plan_organizations
  where plan_id = l_plan_id;

  l_plan_type number;
  l_order_type varchar2(20);

begin

  if(fnd_profile.value('MSC_IO_UI_PERF_TUNE')='Y') then
    g_perf_profile_on := TRUE;
  else
    g_perf_profile_on := FALSE;
  end if;

  if ( p_type = g_attained_sl ) then
    select nvl(DAILY_RESOURCE_CONSTRAINTS,0)+
      nvl(WEEKLY_RESOURCE_CONSTRAINTS,0)+
      nvl(PERIOD_RESOURCE_CONSTRAINTS,0),
      plan_type
    into v_constraint, v_plan_type
    from msc_plans
    where plan_id = p_plan_id;

    -- unconstrained plan is always 100%
    if v_constraint = 0 then
      return 100;
    end if;

    sql_stat := 'SELECT sum(nvl(md.old_demand_quantity,0)*nvl(md.probability,1)), '||
      ' sum(md.USING_REQUIREMENT_QUANTITY*nvl(md.probability,1)) ' ||
      ' FROM msc_demands md ' ||
      ' WHERE md.plan_id = :1 ' ||
      ' AND sr_instance_id = :2 ' ||
      ' AND organization_id = :3 ' ||
      ' AND md.origination_type in (6,7,8,9,11,15,22,29,30) ';

  elsif (p_type =  g_target_sl ) then

    sql_stat := 'SELECT avg(md.service_level), count(*) '||
      ' FROM msc_demands md ' ||
      ' WHERE md.plan_id = :1 ' ||
      ' AND md.sr_instance_id = :2 ' ||
      ' AND md.organization_id = :3 ' ||
      ' AND md.origination_type in (6,7,8,9,11,15,22,29,30) ';

  elsif (p_type =  g_tp_cost ) then

    l_plan_type := get_plan_type(p_plan_id);
    if(l_plan_type = 9) then
      l_order_type :='51,77,78';
    else
      l_order_type :='5,11';
    end if;


    sql_stat := ' select round(sum(nvl(((ms.new_order_quantity * '||
      ' msi.unit_weight)  * mism.cost_per_weight_unit),0)),6), 0'||
      ' from msc_supplies ms,  '||
      ' msc_system_items msi,  '||
      ' msc_interorg_ship_methods mism '||
      ' WHERE ms.plan_id = :1 ' ||
      ' and ms.organization_id != ms.source_organization_id '||
      ' and ms.order_type in (' || l_order_type || ') '||
      --' and ms.order_type in (5,11) '||
      ' and ms.plan_id = msi.plan_id '||
      ' and ms.organization_id = msi.organization_id '||
      ' and ms.sr_instance_id = msi.sr_instance_id '||
      ' and ms.inventory_item_id = msi.inventory_item_id '||
      ' and ms.plan_id = mism.plan_id '||
      ' and ms.organization_id = mism.to_organization_id '||
      ' and ms.sr_instance_id = mism.sr_instance_id '||
      ' and ms.source_organization_id = mism.from_organization_id '||
      ' and ms.source_sr_instance_id = mism.sr_instance_id2'||
      ' and ms.ship_method = mism.ship_method ' ||
      ' AND ms.organization_id = :2 '||
      ' AND ms.sr_instance_id = :3 ' ||
      ' AND ms.inventory_item_id = :4 ' ||
      ' AND trunc(ms.new_dock_date) BETWEEN :5 AND :6 ';

    v_cost := 0;
    --put_line('get_plan_service_level '|| sql_stat);

    if(g_perf_profile_on <> TRUE) then
      open the_cursor for sql_stat using p_plan_id, p_organization_id,
          p_instance_id, p_item_id, trunc(p_start_date), trunc(p_end_date);
      fetch the_cursor into v_cost,v_dummy; -- bug 4387200
      close the_cursor;
    end if;

    return nvl(v_cost, 0);
put_line('get_plan_service_level- after executing tp_cost qry');

  end if;

  v_qty := 0;
  v_qty2 := 0;
  v_dmd_count := 0;

  open c_plan_orgs(p_plan_id);
  loop
    fetch c_plan_orgs into v_instance_id, v_org_id;
    exit when c_plan_orgs%notfound;

    open the_cursor for sql_stat using p_plan_id, v_instance_id, v_org_id;
    fetch the_cursor into v_run_qty, v_run_qty2;
    close the_cursor;

    if ( p_type = g_attained_sl ) then
      v_qty := v_qty + nvl(v_run_qty,0);
      v_qty2 := v_qty2 + nvl(v_run_qty2,0);
    elsif (p_type =  g_target_sl ) then
       v_qty := v_qty + (nvl(v_run_qty, 0) * nvl(v_run_qty2,0));
       v_dmd_count := v_dmd_count + nvl(v_run_qty2,0);
    end if;

  end loop;
  close c_plan_orgs;

  if ( p_type = g_attained_sl ) then
    -- there is no demand, will show 100%
    if nvl(v_qty2,0) =0 then
      v_service := 100;
    elsif nvl(v_qty,0)=0 then
      v_service := 0;
    else
      v_service := round(v_qty/v_qty2*100,6);
    end if;
    return v_service;
  elsif (p_type =  g_target_sl ) then
    if ( nvl(v_dmd_count,0) = 0 ) then
      v_qty := 0;
    else
      v_qty := v_qty / v_dmd_count;
    end if;
    return v_qty;
  end if;

END get_plan_service_level;

function get_plan_dflt_value(p_plan_id number) return number is
  cursor c_dflt is
  select nvl(demand_fulfillment_lt,0)
  from msc_plans
  where plan_id = p_plan_id;

  l_dflt number;
begin
  open c_dflt;
  fetch c_dflt into l_dflt;
  close c_dflt;

  return l_dflt;
end get_plan_dflt_value;

function get_dflt_value(p_plan_id number,
  p_cate_set_id  number default null,
  p_definition_level number default null,
  p_inst_id number default null, p_org_id number default null,
  p_item_id number default null,
  p_demand_class varchar2 default null,
  p_customer_id  number default null,
  p_customer_site_id  number default null,
  p_cate_id  number default null) return number is

  l_cate_set_id number;
  l_dflt number;
  l_dflt_level number;

  cursor c_dflt is
  select nvl(demand_fulfillment_lead_time,0)
  from msc_service_levels
  where plan_id = p_plan_id
    --and category_set_id = l_cate_set_id
    and definition_level = l_dflt_level
    and ( ( sr_instance_id is null and organization_id is null
            and p_inst_id is null and p_org_id is null)
	   or (sr_instance_id = p_inst_id and organization_id = p_org_id))
    and ( ( inventory_item_id is null and p_item_id is null)
           or (inventory_item_id = p_item_id) )
    and ( ( demand_class is null and p_demand_class is null)
           or (demand_class = p_demand_class) )
    and ( ( customer_id is null and p_customer_id is null)
           or (customer_id = p_customer_id) )
    and ( ( customer_site_id is null and p_customer_site_id is null)
           or (customer_site_id = p_customer_site_id) )
    and ( ( sr_category_id is null and p_cate_id is null)
           or (sr_category_id = p_cate_id) );

  cursor c_dflt_with_level is
  select nvl(demand_fulfillment_lead_time,0)
  from msc_service_levels
  where plan_id = p_plan_id
    --and category_set_id = l_cate_set_id
    and definition_level = nvl(p_definition_level, definition_level)
    --and nvl(sr_instance_id, -1) = nvl(p_inst_id, -1) --not req as they populate for every row
    and nvl(organization_id,-1) = nvl(p_org_id,-1)
    and nvl(inventory_item_id,-1) = nvl(p_item_id,-1)
    and nvl(demand_class,'-1') = nvl(p_demand_class,'-1')
    and nvl(customer_id,-1) = nvl(p_customer_id,-1)
    and nvl(customer_site_id,-1) = nvl(p_customer_site_id,-1)
    and nvl(sr_category_id,-1) = nvl(p_cate_id,-1)
  order by definition_level desc;

begin
  l_cate_set_id := msc_analysis_pkg.get_cat_set_id(p_plan_id);

  if (p_definition_level = 0) then
      l_dflt := msc_analysis_pkg.get_plan_dflt_value(p_plan_id);
  else
    open c_dflt_with_level;
    fetch c_dflt_with_level into l_dflt;
    close c_dflt_with_level;
  end if;

  return l_dflt;

-- ------------------------------------------------
-- Label in drop down list     Corresponding DB value
-- ------------------------------------------------
-- Item-Org -Demand Class			10
-- Item-Category-Demand Class			9
-- Item-Demand Class				8
-- Item-Org					7
-- Category					6
-- Org-Demand Class				5
-- Demand Class					4
-- Customer site				3
-- Customer					2
-- Org                                          1
-- Plan                                         0
-- -------------------------------------------------
/*
  if ( p_inst_id is null and p_org_id is null
       and p_item_id is null
       and p_demand_class is null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := -23453;
  elsif ( p_inst_id is NOT null and p_org_id is NOT null
       and p_item_id is null
       and p_demand_class is null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := 1;
  elsif ( p_inst_id is null and p_org_id is null
       and p_item_id is null
       and p_demand_class is null
       and p_customer_id  is NOT null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := 2;
  elsif ( p_inst_id is null and p_org_id is null
       and p_item_id is null
       and p_demand_class is null
       and p_customer_id  is null
       and p_customer_site_id  is NOT null
       and p_cate_id  is null) then
    l_dflt_level := 3;
  elsif ( p_inst_id is null and p_org_id is null
       and p_item_id is null
       and p_demand_class is NOT null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := 4;
  elsif ( p_inst_id is NOT null and p_org_id is NOT null
       and p_item_id is null
       and p_demand_class is NOT null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := 5;
  elsif ( p_inst_id is null and p_org_id is null
       and p_item_id is null
       and p_demand_class is null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is NOT null) then
    l_dflt_level := 6;
  elsif ( p_inst_id is NOT null and p_org_id is NOT null
       and p_item_id is NOT null
       and p_demand_class is null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := 7;
  elsif ( p_inst_id is null and p_org_id is null
       and p_item_id is NOT null
       and p_demand_class is NOT null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := 8;
  elsif ( p_inst_id is null and p_org_id is null
       and p_item_id is NOT null
       and p_demand_class is NOT null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is NOT null) then
    l_dflt_level := 9;
  elsif ( p_inst_id is NOT null and p_org_id is NOT null
       and p_item_id is NOT null
       and p_demand_class is NOT null
       and p_customer_id  is null
       and p_customer_site_id  is null
       and p_cate_id  is null) then
    l_dflt_level := 10;
  end if;

  open c_dflt;
  fetch c_dflt into l_dflt;
  close c_dflt;
*/
end get_dflt_value;

END MSC_ANALYSIS_PKG;

/
