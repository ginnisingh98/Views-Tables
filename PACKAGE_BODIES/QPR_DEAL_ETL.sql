--------------------------------------------------------
--  DDL for Package Body QPR_DEAL_ETL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QPR_DEAL_ETL" AS
/* $Header: QPRUDPRB.pls 120.34 2008/06/04 12:54:52 bhuchand ship $ */
    l_header number := 0;
    l_top_group number := 0;
    l_cmp_group number := 0;
    l_svc_group number := 0;

  l_deal_instance number;

TYPE qpr_pn_policy_type is record(POLICY_ID num_type,
                                  POLICY_LINE_ID num_type,
                                  PN_PRICE_ID num_type,
                                  POLICY_AMOUNT num_type,
                                  POLICY_PRICE num_type
                                  );

procedure log_debug(text varchar2) is
begin
	fnd_file.put_line( fnd_file.log, text);

	if (g_origin = 660 or g_origin = 697) then
		qpr_deal_pvt.debug_ext_log(text, g_origin);
	end if;
end;

procedure insert_price_adj_recs(
                                p_response_hdr_id in number,
                                p_pn_line_id in number,
                                p_src_ref_line_id in number,
                                p_src_ref_hdr_id in number,
                                p_src_id in number,
                                p_top_mdl_src_line_id in number default null,
                                p_mdl_qty in number default null
                                ) is
cursor c_adj is
  select EROSION_TYPE, EROSION_NAME, EROSION_DESC, EROSION_PER_UNIT,
         erosion_amount
  from qpr_pn_int_pr_adjs
  where source_ref_line_id = p_src_ref_line_id
  and source_ref_hdr_id = p_src_ref_hdr_id
  and source_id = p_src_id;

cursor c_tot_adj is
  select a.pn_line_id, 'ALL_' || erosion_type,
  decode(erosion_type, 'ONINVOICE', qpr_sr_util.get_all_adj_pk,
  'COST', qpr_sr_util.get_all_cos_pk,
  'OFFINVOICE',
  qpr_sr_util.get_all_oad_pk, qpr_sr_util.get_null_pk) erosion_name,
  decode(erosion_type, 'ONINVOICE', qpr_sr_util.get_all_adj_desc,
  'COST', qpr_sr_util.get_all_cos_desc,
  'OFFINVOICE', qpr_sr_util.get_all_oad_desc, qpr_sr_util.get_null_desc)
  erosion_desc,
  decode(sum(l.ordered_qty), 0 ,0, sum(erosion_amount) * count(erosion_type)/sum(l.ordered_qty)),
   sum(erosion_amount)
  from qpr_pn_pr_details a, qpr_pn_lines l
  where a.response_header_id = p_response_hdr_id
  and a.pn_line_id = l.pn_line_id
  group by a.erosion_type, a.pn_line_id;

cursor c_hdr_adj is
  select erosion_type,
  erosion_name, erosion_desc, null,
  sum(erosion_amount)
  from qpr_pn_pr_details
  where response_header_id = p_response_hdr_id
  group by erosion_type,erosion_name, erosion_desc;

cursor c_model_adj is
  select
  erosion_type, erosion_name, erosion_desc,
  decode(nvl(p_mdl_qty,0), 0, 0, sum(a.erosion_amount)/p_mdl_qty) as unit_adj,
  decode(nvl(p_mdl_qty,0), 0, 0, sum(a.erosion_amount)) as erosion_amount
  from qpr_pn_pr_details a, qpr_pn_lines l
  where l.parent_pn_line_id= p_top_mdl_src_line_id
  and l.response_header_id = p_response_hdr_id
  and a.pn_line_id = l.pn_line_id
  group by erosion_type, erosion_name, erosion_desc;


t_er_typ char240_type;
t_er_name char240_type;
t_er_desc char240_type;
t_er_val num_type;
t_tot_er num_type;
t_line_id num_type;

b_insert boolean := true;
l_ctr number := 0;
l_rows number := 1000;
begin
  if p_pn_line_id is null then
    log_debug('Inserting line total adjustments per erosion type...');
    open c_tot_adj;
    loop
      fetch c_tot_adj bulk collect into t_line_id, t_er_typ, t_er_name,
                                  t_er_desc,t_er_val, t_tot_er limit l_rows;
      exit when t_line_id.count = 0;
      forall i in t_line_id.first..t_line_id.last
        insert into qpr_pn_pr_details(PN_PR_DETAIL_ID,
                                      RESPONSE_HEADER_ID,
                                      PN_LINE_ID,
                                      EROSION_TYPE,
                                      EROSION_NAME,
                                      EROSION_DESC,
                                      EROSION_PER_UNIT,
                                      erosion_amount,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_LOGIN)
        values(qpr_pn_pr_details_s.nextval,
                p_response_hdr_id,
                t_line_id(i),
                t_er_typ(i),
                t_er_name(i),
                t_er_desc(i),
                t_er_val(i),
                t_tot_er(i),
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.CONC_LOGIN_ID);
        t_line_id.delete;
        t_er_typ.delete;
        t_er_name.delete;
        t_er_desc.delete;
        t_er_val.delete;
        t_tot_er.delete;
    end loop;
    close c_tot_adj;

    log_debug('Inserting header adjustment values by Rolling up line values..');
    open c_hdr_adj;
    fetch c_hdr_adj bulk collect into t_er_typ, t_er_name, t_er_desc,
                                      t_er_val, t_tot_er;
    close c_hdr_adj;
  elsif p_top_mdl_src_line_id is not null then
    log_debug('inserting adjustments for rolled up model');
    open c_model_adj;
    fetch c_model_adj bulk collect into t_er_typ, t_er_name, t_er_desc,
                                      t_er_val, t_tot_er;
    close c_model_adj;
  elsif p_src_ref_line_id is not null then
    log_debug('inserting adjustment for quote line:' || p_src_ref_line_id);
    open c_adj;
    fetch c_adj bulk collect into t_er_typ, t_er_name, t_er_desc,
                                  t_er_val, t_tot_er;
    close c_adj;
  end if;

  forall i in t_er_name.first..t_er_name.last
    insert into qpr_pn_pr_details(PN_PR_DETAIL_ID,
                                  RESPONSE_HEADER_ID,
                                  PN_LINE_ID,
                                  EROSION_TYPE,
                                  EROSION_NAME,
                                  EROSION_DESC,
                                  EROSION_PER_UNIT,
                                  erosion_amount,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_LOGIN)
    values(qpr_pn_pr_details_s.nextval,
            p_response_hdr_id,
            p_pn_line_id,
            t_er_typ(i),
            t_er_name(i),
            t_er_desc(i),
            t_er_val(i),
            t_tot_er(i),
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.CONC_LOGIN_ID);
  log_debug('Inserted ' || sql%rowcount || ' adjustment rows in qpr_pn_pr_details');

  t_er_typ.delete;
  t_er_name.delete;
  t_er_desc.delete;
  t_er_val.delete;
  t_tot_er.delete;
exception
  when others then
    log_debug(dbms_utility.format_error_backtrace);
    raise;
end insert_price_adj_recs;

function insert_prices(
                        p_response_hdr_id in number,
                        p_pn_line_id in number,
                        p_src_ref_line_id in number default null,
                        p_src_ref_hdr_id in number default null,
                        p_src_id in number default null,
                        p_mdl_qty in number default null
                        ) return number is

l_tot_erosion number := 0;
l_unit_er number := 0;
l_base_price number := 0;
l_ord_qty number := 0;
l_price number :=0;
l_amount number := 0;
l_prev_price number:= 0;
l_prev_amount number := 0;
l_sql varchar2(2000);
l_price_perc number := 0;

c_line SYS_REFCURSOR;

cursor c_price_types is
select pn_pr_type_id, price_type_name, derived_from_type,
erosion_type, column_name
from qpr_pn_pr_types
order by sequence_no;

cursor c_hdr_pric is
select pr1.pn_pr_type_id, sum(pr1.amount) amount,
decode(sum(pr2.amount),0,0, 100 * sum(pr1.amount)/sum(pr2.amount))
 percent_price,
      decode(sum(l.ordered_qty), 0, 0, sum(pr1.amount)* count(l.pn_line_id)/sum(l.ordered_qty)) unit_price
from qpr_pn_prices pr1, qpr_pn_prices pr2, qpr_pn_lines l, qpr_pn_pr_types prt
where pr1.response_header_id = p_response_hdr_id
and pr1.response_header_id = l.response_header_id
and pr1.pn_line_id = l.pn_line_id
and pr1.response_header_id = pr2.response_header_id
and pr1.pn_line_id = pr2.pn_line_id
and pr2.pn_pr_type_id = prt.pn_pr_type_id
and prt.price_type_name = 'LISTPRICE'
group by pr1.pn_pr_type_id;

begin

if p_pn_line_id is null then
  log_debug('Inserting header price values by rolling up line values');
  for r_hdr_pric in c_hdr_pric loop
    insert into qpr_pn_prices(PN_PRICE_ID,
                              RESPONSE_HEADER_ID,
                              PN_LINE_ID,
                              PN_PR_TYPE_ID,
                              UNIT_PRICE,
                              AMOUNT,
                              PERCENT_PRICE,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN)
                      values(
                      qpr_pn_prices_s.nextval,
                      p_response_hdr_id, null,
                      r_hdr_pric.pn_pr_type_id,
                      r_hdr_pric.unit_price,
                      r_hdr_pric.amount,
                      r_hdr_pric.percent_price,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      FND_GLOBAL.CONC_LOGIN_ID);
  end loop;
else
  for r_pr_types in c_price_types loop
    if r_pr_types.column_name is not null then
      if p_mdl_qty is not null then
        log_debug('Calculating price for rolled up model');
        l_ord_qty := p_mdl_qty;
        l_sql := ' select sum( ' || r_pr_types.column_name || ' * ordered_qty) '
                || ' from qpr_pn_int_lines '
                || ' where top_mdl_src_line_id = :1 and source_ref_hdr_id = :2 '
                ||' and source_id = :3 and pn_req_line_status_flag = ''I'' ' ;
        open c_line for l_sql using p_src_ref_line_id, p_src_ref_hdr_id, p_src_id;
        fetch c_line into l_amount;
        close c_line;

        if nvl(p_mdl_qty, 0) = 0 then
          l_base_price := 0;
          l_price := 0;
          l_amount := 0;
        else
          l_base_price := l_amount/p_mdl_qty;
          l_price := l_base_price;
        end if;
      else
        log_debug('Calculate price for quote line: ' || p_src_ref_line_id);

        l_sql := 'select ' || r_pr_types.column_name || ' ,ordered_qty '
                || ' from qpr_pn_int_lines '
                || ' where source_ref_line_id = :1 and source_ref_hdr_id = :2 '
                || ' and source_id = :3 and pn_req_line_status_flag  = ''I'' and rownum < 2';

        open c_line for l_sql using p_src_ref_line_id, p_src_ref_hdr_id, p_src_id;
        fetch c_line into l_base_price, l_ord_qty;
        close c_line;

        l_price := l_base_price ;
        l_amount := l_base_price * l_ord_qty ;
      end if;
    else
      begin
        select nvl(sum(erosion_amount),0), nvl(sum(erosion_per_unit), 0)
        into l_tot_erosion,l_unit_er
        from qpr_pn_pr_details
        where pn_line_id = p_pn_line_id
        and erosion_type = r_pr_types.erosion_type;
      end;

      l_price := l_prev_price - l_unit_er;
      l_amount := l_prev_amount - l_tot_erosion;
    end if;
    if l_base_price = 0 then
      l_price_perc := 100;
    else
      l_price_perc := l_price * 100 / l_base_price;
    end if;
    l_prev_price := l_price;
    l_prev_amount := l_amount;

    insert into qpr_pn_prices(PN_PRICE_ID,
                              RESPONSE_HEADER_ID,
                              PN_LINE_ID,
                              PN_PR_TYPE_ID,
                              UNIT_PRICE,
                              AMOUNT,
                              PERCENT_PRICE,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN)
                      values(
                      qpr_pn_prices_s.nextval,
                      p_response_hdr_id,
                      p_pn_line_id,
                      r_pr_types.pn_pr_type_id,
                      l_price, l_amount,l_price_perc,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      FND_GLOBAL.CONC_LOGIN_ID);
     log_debug('Inserted Price Type = ' || r_pr_types.pn_pr_type_id
                || ' ;Unit Price = ' || l_price);
  end loop;
end if;
return (l_base_price);
exception
  when others then
    log_debug('Failed to insert prices');
    log_debug(dbms_utility.format_error_backtrace);
    raise;
end insert_prices;

procedure insert_policy_details(
                               p_deal_date in date,
                               p_pr_segment_id in varchar2,
                               p_vlb_id in varchar2,
                               p_pn_line_id in number,
                               p_list_price in number,
                               p_deal_curr in varchar2,
                               p_ordered_qty in number,
                               p_fetch_pol in boolean,
                               p_pol_ref_line_id in number default null
                              )  is

rec_pn_pol_ins qpr_pn_policy_type;
l_pol_price number;
l_pol_ctr number := 1;
a_null char(1);
l_sql varchar2(20000);
l_curr_conv number;

cursor c_pn_prices(p_policy_meas_type varchar2) is
select p.pn_price_id
from qpr_pn_prices p, qpr_pn_pr_types t
where p.pn_pr_type_id = t.pn_pr_type_id
and p.pn_line_id = p_pn_line_id
and t.erosion_type = p_policy_meas_type
and rownum < 2;

cursor c_pol_det is
select p.policy_line_id, p.policy_id, pl.policy_type_code, pl.policy_measure_type_code,
pl.limit_value_type_code,
pl.ref_limit_value, null, null
from qpr_pn_policies p , qpr_pn_prices pr, qpr_policy_lines pl
where p.pn_price_id = pr.pn_price_id
and pr.pn_line_id = p_pol_ref_line_id
and p.policy_id = pl.policy_id
and p.policy_line_id = pl.policy_line_id;

begin
  if p_fetch_pol then
    log_debug('getting policy details...');
    qpr_policy_eval.get_policy_details(l_deal_instance,
                                       p_pr_segment_id,
                                       null,
                                       p_deal_date,
                                       p_vlb_id,
                                       null, null,
                                       g_t_pol_det);
  else
    log_debug('Getting policy details.. ');
    open c_pol_det;
    fetch c_pol_det bulk collect into g_t_pol_det;
    close c_pol_det;
  end if;

  if g_t_pol_det is not null then
    log_debug('policy rec count:' || g_t_pol_det.count);
    log_debug('Evaluating policy values');
      for i in 1..g_t_pol_det.count loop
        rec_pn_pol_ins.POLICY_ID(l_pol_ctr) := g_t_pol_det(i).POLICY_ID;
        rec_pn_pol_ins.POLICY_LINE_ID(l_pol_ctr) :=
                                        g_t_pol_det(i).POLICY_LINE_ID;
        for r_pn_pric in c_pn_prices(g_t_pol_det(i).POLICY_MEASURE_TYPE_CODE)
        loop
          rec_pn_pol_ins.PN_PRICE_ID(l_pol_ctr) := r_pn_pric.PN_PRICE_ID;
        end loop;
        if g_t_pol_det(i).LIMIT_VALUE_TYPE_CODE = 'AMOUNT' then
          l_curr_conv := qpr_sr_util.ods_curr_conversion(null, p_deal_curr,
                          null, p_deal_date, l_deal_instance);
          if g_t_pol_det(i).POLICY_MEASURE_TYPE_CODE = 'COST' then
            l_pol_price := p_list_price -
                      (nvl(g_t_pol_det(i).REF_LIMIT_VALUE,0) * l_curr_conv);
          else
            l_pol_price := nvl(g_t_pol_det(i).REF_LIMIT_VALUE, 0) * l_curr_conv;
          end if;
        else
          if g_t_pol_det(i).POLICY_MEASURE_TYPE_CODE = 'COST' then
            l_pol_price := p_list_price *
                                     nvl(g_t_pol_det(i).REF_LIMIT_VALUE, 0)/100;
          else
            l_pol_price := p_list_price - (p_list_price *
                                    nvl(g_t_pol_det(i).REF_LIMIT_VALUE, 0)/100);
          end if;
        end if;
        rec_pn_pol_ins.POLICY_PRICE(l_pol_ctr) := l_pol_price;
        rec_pn_pol_ins.POLICY_AMOUNT(l_pol_ctr) := l_pol_price *
                                                    nvl(p_ordered_qty, 0);
        log_debug('Policy id: ' || g_t_pol_det(i).policy_id ||
                  ', Policy line id = ' || g_t_pol_det(i).policy_line_id);
        log_debug(' Policy Type: ' || g_t_pol_det(i).policy_type_code);
        log_debug('Policy Measure Type: ' || g_t_pol_det(i).policy_measure_type_code);
        log_debug('Policy amount:' || l_pol_price * nvl(p_ordered_qty, 0));
        l_pol_ctr := l_pol_ctr +1;
      end loop;
      g_t_pol_det.delete;
   else
      log_debug('No policy details found');
   end if;

   if rec_pn_pol_ins.policy_id.count > 0 then
      forall i in rec_pn_pol_ins.POLICY_ID.first..rec_pn_pol_ins.POLICY_ID.last
        insert into qpr_pn_policies(PN_POLICY_ID,
                                    PN_PRICE_ID,
                                    POLICY_ID,
                                    POLICY_LINE_ID,
                                    POLICY_PRICE,
                                    POLICY_AMOUNT,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN)
                 values(qpr_pn_policies_s.nextval,
                        rec_pn_pol_ins.pn_price_id(i),
                        rec_pn_pol_ins.policy_id(i),
                        rec_pn_pol_ins.policy_line_id(i),
                        rec_pn_pol_ins.policy_price(i),
                        rec_pn_pol_ins.policy_amount(i),
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        SYSDATE,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.CONC_LOGIN_ID);
       log_debug('Inserted ' || sql%rowcount || ' policy records');
   end if;
exception
when others then
  log_debug('Failed in policy fetching');
  log_debug(dbms_utility.format_error_backtrace);
  raise;
end insert_policy_details;

function score_calc(p_list_price in number,
                    p_unit_cost in number,
                    p_floor_margin in number,
                    p_line_margin in number,
                    p_inv_price in number,
                    p_recommend_price in number
                    ) return number is
l_ceiling_margin number;
l_pocmrg_score number;
l_inv_pr_score number;
l_pocmrg_score_wt number;
l_invpr_score_wt number;
l_line_score number;
begin

  log_debug('unit list price: ' || p_list_price);
  log_debug('Unit cost:' || p_unit_cost);
  log_debug('floor margin per unit: ' || p_floor_margin);
  log_debug('Actual margin per unit:' || p_line_margin);
  log_debug('Unit Invoice price: ' || p_inv_price);
  log_debug('Unit recommended price: ' || p_recommend_price);

  l_ceiling_margin := p_list_price - p_unit_cost;

  if l_ceiling_margin = 0 then
    l_pocmrg_score := 10;
  elsif l_ceiling_margin = p_floor_margin then
    l_pocmrg_score := 0;
  else
    l_pocmrg_score := 10 - 9 * ((l_ceiling_margin - p_line_margin)
                                  / (l_ceiling_margin - p_floor_margin));
  end if;

  if l_pocmrg_score < 0 then
    l_pocmrg_score := 0;
  elsif l_pocmrg_score > 10 then
    l_pocmrg_score := 10;
  end if;

  log_debug('Margin part of score: ' || l_pocmrg_score);

  if p_recommend_price = 0 then
    l_inv_pr_score := 0;
  else
    l_inv_pr_score := 10 - ((p_inv_price/p_recommend_price) -1) * 10;
  end if;

  if l_inv_pr_score < 0 then
    l_inv_pr_score := 0;
  elsif l_inv_pr_score > 10 then
    l_inv_pr_score := 10;
  end if;

  log_debug('Invoice Price part of score: ' || l_inv_pr_score);

  l_pocmrg_score_wt := nvl(fnd_profile.value('QPR_MRG_SCORE_WT'),0);
  l_invpr_score_wt := nvl(fnd_profile.value('QPR_INVPR_SCORE_WT'), 0);

  l_line_score := (l_pocmrg_score_wt * l_pocmrg_score +
  l_invpr_score_wt * l_inv_pr_score)
                  / (l_pocmrg_score_wt + l_invpr_score_wt);

  log_debug('Final Score: ' || l_line_score);
  return(l_line_score);

end score_calc;

function get_line_score(p_pn_line_id in number,
                        p_recommend_pric in number) return number is
l_line_score number := 0;
l_list_price number := 0;
l_inv_price number := 0;
l_margin number := 0;
l_floor_mrg number := 0;
l_cost number := 0;

cursor c_pric is
    select nvl(p.unit_price, 0) price, t.price_type_name
    from qpr_pn_prices p, qpr_pn_pr_types t
    where p.pn_line_id = p_pn_line_id
    and p.pn_pr_type_id = t.pn_pr_type_id;

begin
  select nvl(sum(p.erosion_per_unit),0)
  into l_cost
  from qpr_pn_pr_details p
  where p.pn_line_id = p_pn_line_id
  and p.erosion_type = 'COST';

  select nvl(min(p.policy_price) , 0) into l_floor_mrg
  from qpr_pn_policies p, qpr_pn_prices pric, qpr_pn_pr_types t
  where pric.pn_line_id = p_pn_line_id
  and p.pn_price_id = pric.pn_price_id
  and pric.pn_pr_type_id = t.pn_pr_type_id
  and t.price_type_name = 'POCMARGIN';

  for r_pric in c_pric loop
    if r_pric.price_type_name = 'LISTPRICE' then
      l_list_price := r_pric.price;
    elsif r_pric.price_type_name = 'INVPRICE' then
      l_inv_price := r_pric.price;
    elsif r_pric.price_type_name = 'POCMARGIN' then
      l_margin := r_pric.price;
    end if;
  end loop;


  l_line_score := score_calc(l_list_price, l_cost, l_floor_mrg,
                              l_margin, l_inv_price, nvl(p_recommend_pric,0));

  return(l_line_score);
end get_line_score;

procedure insert_model_lines(p_response_id number, p_deal_date date) is
   cursor c_mdl_lines is
   select *
   from qpr_pn_lines
   where response_header_id = p_response_id
   and item_type_code in ('MDL', 'KIT');

l_LIST_PRICE number;
l_PROPOSED_PRICE number;
l_LINE_PRICING_SCORE number := 0;
l_line_id number;
l_recommended_price  number;
l_regression_slope  number;
l_regression_intercept  number;
l_deal_uom_pp_conv number;
l_deal_curr_pp_conv number;
l_aw_uom qpr_price_plans_b.base_uom_code%type;
l_aw_curr qpr_price_plans_b.currency_code%type;
begin
  for c_mdl_lines_rec in c_mdl_lines loop
   begin
      select pn_line_id into l_line_id
      from qpr_pn_lines
      where source_ref_line_id = c_mdl_lines_rec.source_ref_line_id
      and source_ref_hdr_id = c_mdl_lines_rec.source_ref_hdr_id
      and source_id = c_mdl_lines_rec.source_id
      and response_header_id = p_response_id
      and item_type_code = 'DUMMY_PARENT'
      and rownum < 2;
    exception
      when others then
        log_debug('Rolled up model not found. No processing done');
        return;
    end;

    log_debug('Updating Model line-'|| l_line_id);

    select decode(sum(nvl(pr.amount, 0)), 0, 0,
      sum(nvl(l.line_pricing_score,0) * nvl(pr.amount,0))/
                          sum(nvl(pr.amount,0)))  ,
      sum(PROPOSED_PRICE * REVISED_OQ),
      sum(RECOMMENDED_PRICE * REVISED_OQ),
      sum(nvl(REGRESSION_INTERCEPT,0) *
          (case when (qpr_sr_util.ods_uom_conv(
          l.inventory_item_id,
          l.UOM_CODE,
          pp.base_uom_code, pp.instance_id, null) < 0) then
          0 else qpr_sr_util.ods_uom_conv(
          l.inventory_item_id,
          l.UOM_CODE,
          pp.base_uom_code, pp.instance_id, null) end)
          * REVISED_OQ),
      min(pp.base_uom_code), min(pp.currency_code)
      into l_LINE_PRICING_SCORE ,
      l_PROPOSED_PRICE,
      l_recommended_price,
      l_regression_intercept,
      l_aw_uom, l_aw_curr
    from qpr_pn_lines l, qpr_pn_prices pr, qpr_pn_pr_types prt,
          qpr_price_plans_b pp
    where l.parent_pn_line_id= c_mdl_lines_rec.source_ref_line_id
    and l.response_header_id = p_response_id
    and l.response_header_id = pr.response_header_id
    and l.pn_line_id = pr.pn_line_id
    and l.price_plan_id = pp.price_plan_id
    and pr.pn_pr_type_id = prt.pn_pr_type_id
    and prt.price_type_name = 'LISTPRICE';

    if c_mdl_lines_rec.revised_oq is null or
      c_mdl_lines_rec.revised_oq = 0 then
         l_PROPOSED_PRICE := 0;
         l_recommended_price := 0;
         l_regression_slope := 0;
    else
      l_PROPOSED_PRICE:= l_PROPOSED_PRICE/c_mdl_lines_rec.revised_oq;
      l_recommended_price := l_recommended_price/c_mdl_lines_rec.revised_oq;
      l_deal_uom_pp_conv := qpr_sr_util.ods_uom_conv(
                                        c_mdl_lines_rec.inventory_item_id,
                                        c_mdl_lines_rec.UOM_CODE, l_aw_uom,
                                        l_deal_instance,null);
      l_deal_curr_pp_conv := qpr_sr_util.ods_curr_conversion(
                                          c_mdl_lines_rec.currency_code,
                                          l_aw_curr, null, p_deal_date,
                                          l_deal_instance);
      if l_deal_uom_pp_conv < 0 or l_deal_curr_pp_conv < 0 then
        l_regression_slope := 0;
        l_regression_intercept := 0;
      else
        l_regression_intercept := l_regression_intercept/
                          c_mdl_lines_rec.revised_oq * l_deal_uom_pp_conv;
        l_regression_slope := ((l_recommended_price * l_deal_curr_pp_conv) -
                                 l_regression_intercept)/
                            c_mdl_lines_rec.revised_oq * l_deal_uom_pp_conv;
      end if;
    end if;

    update qpr_pn_lines set PROPOSED_PRICE = l_PROPOSED_PRICE,
                        RECOMMENDED_PRICE = l_recommended_price,
                        REGRESSION_SLOPE = l_regression_slope,
                        LINE_PRICING_SCORE = l_LINE_PRICING_SCORE
    where pn_line_id = l_line_id;

    log_debug('Recommended price:' || l_recommended_price);
    log_debug('Line Score:' || l_line_pricing_score);

    insert_price_adj_recs(p_response_id, l_line_id,null, null, null,
                          c_mdl_lines_rec.source_ref_line_id,
                          c_mdl_lines_rec.revised_oq);

    l_list_price := insert_prices(p_response_id, l_line_id,
                  c_mdl_lines_rec.source_ref_line_id,
                  c_mdl_lines_rec.source_ref_hdr_id,
                  c_mdl_lines_rec.source_id,
                   c_mdl_lines_rec.revised_oq);

    insert_policy_details(null, null,null,
                          l_line_id,
                          l_list_price,
                          c_mdl_lines_rec.currency_code,
                          c_mdl_lines_rec.ordered_qty,
                          false,
                          c_mdl_lines_rec.pn_line_id);

    log_debug('Update parent_pn_line_id for child lines of model...');
    update qpr_pn_lines
    set parent_pn_line_id = l_line_id
    where (parent_pn_line_id= c_mdl_lines_rec.source_ref_line_id
          or pn_line_id = c_mdl_lines_rec.pn_line_id)
    and pn_line_id <> l_line_id
    and response_header_id = p_response_id;
    log_debug('No of lines updated: '||sql%rowcount);
  end loop;
exception
 when others then
  log_debug('failed in inserting model line');
  log_debug(dbms_utility.format_error_backtrace);
  raise;
end;

procedure insert_req_res_header_lines(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_src_ref_hdr_id in number,
                        p_int_header_id in number,
                        p_simulation in varchar2 ,
                        p_response_id out nocopy number,
                        p_is_deal_compliant out nocopy varchar2) is
cursor c_int_header is
select *
from qpr_pn_int_headers
where pn_int_header_id = p_int_header_id;

cursor c_int_lines(p_src_id number) is
select *
from qpr_pn_int_lines
where source_ref_hdr_id = p_src_ref_hdr_id
and source_id = p_src_id
and pn_req_line_status_flag = 'I'
order by pn_int_line_id;

cursor c_pn_lines(p_resp_hdr_id number) is
select * from qpr_pn_lines
where response_header_id = p_resp_hdr_id
and item_type_code <> 'DUMMY_PARENT';

l_request_id number;
l_response_id number;
l_total_score number;
l_line_id number;
l_reference_name varchar2(240);
l_line_score number;
l_sql varchar2(30000);
l_pr_segment number;
l_list_price number;
l_recommend_price number := 0;
l_transf_vol number := 0;
l_line_num varchar2(240);
l_Response_status varchar2(240);
l_return_status varchar2(10);
l_deal_uom_conv number;
l_deal_curr_conv number;
l_aw_uom qpr_price_plans_b.base_uom_code%type;
l_aw_curr qpr_price_plans_b.currency_code%type;
begin

  log_debug('Populating deal tables...');

  for c_int_header_rec in c_int_header loop
    insert into qpr_pn_request_hdrs_b (REQUEST_HEADER_ID,
      REQUEST_STATUS,
      PN_INT_HEADER_ID,
      INSTANCE_ID,
      CURRENCY_SHORT_DESC,
      CURRENCY_LONG_DESC,
      SOURCE_ID,
      SOURCE_SHORT_DESC,
      SOURCE_LONG_DESC,
      SOURCE_REF_HDR_ID,
      SOURCE_REF_HDR_SHORT_DESC,
      SOURCE_REF_HDR_LONG_DESC,
      CUSTOMER_ID,
      CUSTOMER_SK,
      CUSTOMER_SHORT_DESC,
      CUSTOMER_LONG_DESC,
      SALES_REP_ID,
      SALES_REP_SK,
      SALES_REP_SHORT_DESC,
      SALES_REP_LONG_DESC,
      SALES_REP_EMAIL,
      SALES_CHANNEL_CODE,
      SALES_CHANNEL_SK,
      SALES_CHANNEL_SHORT_DESC,
      SALES_CHANNEL_LONG_DESC,
      FREIGHT_TERMS_SHORT_DESC,
      FREIGHT_TERMS_LONG_DESC,
      DEAL_EXPIRY_DATE,
      DEAL_CREATION_DATE,
      INVOICE_TO_PARTY_SITE_ID,
      INVOICE_TO_PARTY_SITE_ADDRESS,
      SIMULATION_FLAG,
      COMMENTS,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN
      )
      values (
      qpr_pn_request_hdrs_s.nextval,'ACTIVE',
      p_int_header_id,
      l_deal_instance,
      c_int_header_rec.CURRENCY_CODE,
      c_int_header_rec.CURRENCY_LONG_DESC,
      c_int_header_rec.SOURCE_ID,
      c_int_header_rec.SOURCE_SHORT_DESC,
      c_int_header_rec.SOURCE_LONG_DESC,
      c_int_header_rec.SOURCE_REF_HEADER_ID,
      c_int_header_rec.SOURCE_REF_HEADER_SHORT_DESC,
      c_int_header_rec.SOURCE_REF_HEADER_LONG_DESC,
      c_int_header_rec.CUSTOMER_ID,
      nvl2(c_int_header_rec.CUSTOMER_ID,
      'TRADING_PARTNER_L_'||c_int_header_rec.CUSTOMER_ID,
      null),
      c_int_header_rec.CUSTOMER_SHORT_DESC,
      c_int_header_rec.CUSTOMER_LONG_DESC,
      c_int_header_rec.SALES_REP_ID,
      nvl2(c_int_header_rec.SALES_REP_ID,
           'SALES_REP_L_'||c_int_header_rec.SALES_REP_ID, null),
      c_int_header_rec.SALES_REP_SHORT_DESC,
      c_int_header_rec.SALES_REP_LONG_DESC,
      c_int_header_rec.SALES_REP_EMAIL_ADDRESS,
      c_int_header_rec.SALES_CHANNEL_CODE,
      nvl2(c_int_header_rec.SALES_CHANNEL_CODE,
           'SALES_CHANNEL_L_'||c_int_header_rec.SALES_CHANNEL_CODE,null),
      c_int_header_rec.SALES_CHANNEL_SHORT_DESC,
      c_int_header_rec.SALES_CHANNEL_LONG_DESC,
      c_int_header_rec.FREIGHT_TERMS_SHORT_DESC,
      c_int_header_rec.FREIGHT_TERMS_LONG_DESC,
      c_int_header_rec.PN_REQ_EXPIRY_DATE,
      c_int_header_rec.PN_REQ_HEADER_CREATION_DATE,
      c_int_header_rec.INVOICE_TO_PARTY_SITE_ID,
      c_int_header_rec.INVOICE_TO_PARTY_SITE_ADDRESS,
      p_simulation,
      c_int_header_rec.COMMENTS,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      SYSDATE,
      FND_GLOBAL.USER_ID,
      FND_GLOBAL.CONC_LOGIN_ID
      ) returning REQUEST_HEADER_ID into l_request_id;

    l_reference_name :=
      substr(nvl(c_int_header_rec.source_short_desc||': '||
      c_int_header_rec.source_ref_header_short_desc, 'Null'),1,240);

    log_debug('Inserted Request header: ' || l_request_id || '-'
              || l_reference_name);
    ------- insert into request_hdrs_tl ----
    insert into qpr_pn_request_hdrs_tl (
                                      LANGUAGE,
                                      REQUEST_HEADER_ID,
                                      REFERENCE_NAME,
                                      SOURCE_LANG,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_LOGIN)
         select  L.LANGUAGE_CODE ,l_request_id,
                 l_reference_name,
                 userenv('LANG'),
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 SYSDATE,
                 FND_GLOBAL.USER_ID,
                 FND_GLOBAL.CONC_LOGIN_ID
         from FND_LANGUAGES L
         where L.INSTALLED_FLAG in ('I', 'B');

    log_debug('Inserted Request header TL values');

    --- insert qpr_pn_response_hdrs ----
    insert into qpr_pn_response_hdrs(
                                    RESPONSE_HEADER_ID,
                                    REQUEST_HEADER_ID,
																		OWNER_ID,
                                    DEAL_HEADER_SCORE,
                                    RESPONSE_STATUS,
                                    PARENT_RESPONSE_ID,
                                    DEAL_LAST_UPDATED_BY,
                                    DEAL_LAST_UPDATE_DATE,
                                    COMMENTS,
                                    VERSION_NUMBER,
                                    BOOKMARK_FLAG,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN
                                    ) values
                                    (qpr_pn_response_hdrs_s.nextval,
                                    l_request_id, fnd_global.user_id,
                                    null,
                                    'APPROVE_REQ',
                                    null,
                                    fnd_global.user_id,
                                    sysdate,
                                    null,
                                    1,
                                    'N',
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID,
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID,
                                    FND_GLOBAL.CONC_LOGIN_ID)
 	  returning RESPONSE_HEADER_ID into l_response_id;

    log_debug('Inserted Response Id: '||l_response_id);

    log_debug('Inserting Pn_lines...');
    for int_lines_rec in c_int_lines(c_int_header_rec.SOURCE_ID) loop
      log_debug('Inserting line: Source line id = '|| int_lines_rec.source_ref_line_id);

      if int_lines_rec.ITEM_TYPE_CODE = 'MDL' or
        int_lines_rec.ITEM_TYPE_CODE = 'KIT' then
        log_debug('Inserting rolled up model for model/kit line');
				l_line_num := substrb(int_lines_rec.SOURCE_REQUEST_LINE_NUMBER, 1,
							instrb(int_lines_rec.SOURCE_REQUEST_LINE_NUMBER, '.' , 1, 1)- 1);
        insert into qpr_pn_lines(PN_LINE_ID,
                                RESPONSE_HEADER_ID,
                                REQUEST_HEADER_ID,
                                PRICE_PLAN_ID,
                                SOURCE_REF_LINE_ID,
                                SOURCE_REQUEST_LINE_NUMBER,
                                SOURCE_REF_HDR_ID,
                                SOURCE_ID,
                                ORG_ID,
                                INVENTORY_ITEM_ID,
                                PAYMENT_TERM_ID,
                                PARENT_PN_LINE_ID,
                                GEOGRAPHY_ID,
                                UOM_CODE,
                                CURRENCY_CODE,
                                ITEM_TYPE_CODE, ORDERED_QTY,
                                COMPETITOR_PRICE,
                                PROPOSED_PRICE,
                                ORG_DIM_SK,
                                ORG_LONG_DESC,
                                ORG_SHORT_DESC,
                                COMPETITOR_NAME,
                                REVISED_OQ,
                                PRODUCT_DIM_SK,
                                INVENTORY_ITEM_SHORT_DESC,
                                INVENTORY_ITEM_LONG_DESC,
                                VOL_BAND_SK,
                                GEOGRAPHY_SK,
                                GEOGRAPHY_SHORT_DESC,
                                GEOGRAPHY_LONG_DESC,
                                PAYMENT_TERM_SHORT_DESC,
                                PAYMENT_TERM_LONG_DESC,
                                UOM_SHORT_DESC,
                                CURRENCY_SHORT_DESC,
                                COMMENTS, ADDITIONAL_INFORMATION,
                                SHIP_METHOD_CODE,
                                SHIP_METHOD_SHORT_DESC,
                                SHIP_METHOD_LONG_DESC,
                                DATAMART_NAME,
                                REGRESSION_SLOPE,
                                REGRESSION_INTERCEPT,
                                RECOMMENDED_PRICE,
                                PR_SEGMENT_ID,
                                PR_SEGMENT_SK,
                                ORIG_PAYMENT_TERM_ID,
                                ORIG_SHIP_METHOD_CODE,
                                CREATION_DATE,
                                CREATED_BY,
                                LAST_UPDATE_DATE,
                                LAST_UPDATE_LOGIN,
                                LAST_UPDATED_BY)
                values(QPR_PN_LINES_S.nextval,
                      l_response_id,
                      l_request_id,
                      int_lines_rec.PRICE_PLAN_ID,
                      int_lines_rec.SOURCE_REF_LINE_ID,
		l_line_num,
                      int_lines_rec.SOURCE_REF_HDR_ID,
                      int_lines_rec.SOURCE_ID,
                      int_lines_rec.ORG_ID,
                      int_lines_rec.INVENTORY_ITEM_ID,
                      int_lines_rec.PAYMENT_TERM_ID,
                      null,
                      int_lines_rec.GEOGRAPHY_ID,
                      int_lines_rec.UOM_CODE,
                      int_lines_rec.CURRENCY_CODE,
                      'DUMMY_PARENT',
                      int_lines_rec.ORDERED_QTY,
                      int_lines_rec.COMPETITOR_PRICE,
                      0,
                      nvl2(int_lines_rec.ORG_ID,
                      'OPERATING_UNIT_L_'||int_lines_rec.ORG_ID,null),
                      int_lines_rec.ORG_LONG_DESC,
                      int_lines_rec.ORG_SHORT_DESC,
                      int_lines_rec.COMPETITOR_NAME,
                      int_lines_rec.ORDERED_QTY,
                      'MODEL_L_'||int_lines_rec.INVENTORY_ITEM_ID,
                      int_lines_rec.INVENTORY_ITEM_SHORT_DESC,
                      int_lines_rec.INVENTORY_ITEM_LONG_DESC,
                      int_lines_rec.VOL_BAND_SK,
                     nvl2(int_lines_rec.GEOGRAPHY_ID,
                    'TRADING_PARTNER_SITE_L_'||int_lines_rec.GEOGRAPHY_ID,
                        null),
                      int_lines_rec.GEOGRAPHY_SHORT_DESC,
                      int_lines_rec.GEOGRAPHY_LONG_DESC,
                      int_lines_rec.PAYMENT_TERM_SHORT_DESC,
                      int_lines_rec.PAYMENT_TERM_LONG_DESC,
                      int_lines_rec.UOM_SHORT_DESC,
                      int_lines_rec.CURRENCY_SHORT_DESC,
                      int_lines_rec.COMMENTS,
                      int_lines_rec.ADDITIONAL_INFORMATION,
                      int_lines_rec.SHIP_METHOD_CODE,
                      int_lines_rec.SHIP_METHOD_SHORT_DESC,
                      int_lines_rec.SHIP_METHOD_LONG_DESC,
                      int_lines_rec.datamart_name,
                      0,
                      int_lines_rec.regression_intercept,
                      0,
                      int_lines_rec.pr_segment_id,
                      nvl2(int_lines_rec.pr_Segment_id,
                          'PR_SEGMENT_L_' || int_lines_rec.pr_segment_id, null),
                      int_lines_rec.PAYMENT_TERM_ID,
                      int_lines_rec.SHIP_METHOD_CODE,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      FND_GLOBAL.CONC_LOGIN_ID)
             returning PN_LINE_ID into l_line_id;
        log_debug('Inserted rolled up model' || l_line_id);
      end if;

      log_debug('Determining recommended price of the quote line');

      if (int_lines_rec.REGRESSION_INTERCEPT <> 0
          or int_lines_rec.REGRESSION_SLOPE <> 0) then
					select base_uom_code, currency_code
          into l_aw_uom, l_aw_curr
          from qpr_price_plans_b
          where price_plan_id = int_lines_rec.PRICE_PLAN_ID
          and rownum < 2;

	      l_deal_uom_conv := qpr_sr_util.ods_uom_conv(
                            int_lines_rec.inventory_item_id,
                            int_lines_rec.UOM_CODE,
                            l_aw_uom, l_deal_instance, null);

				l_deal_curr_conv := qpr_sr_util.ods_curr_conversion(l_aw_curr,
                              int_lines_rec.currency_code,
                              null,
                              c_int_header_rec.PN_REQ_HEADER_CREATION_DATE,
                              l_deal_instance);
				if l_deal_uom_conv < 0 or l_deal_curr_conv < 0 then
					log_debug('Cannot determine uom/currency conversion between ' ||
										'deal unit and price plan units');
					l_recommend_price := 0;
				else
	        qpr_regression_analysis.reg_transf
                                      (int_lines_rec.PRICE_PLAN_ID,
                                      int_lines_rec.INVENTORY_ITEM_ID,
                                      int_lines_rec.pr_segment_id,
                                      int_lines_rec.ORDERED_QTY *
																			l_deal_uom_conv,
                                      l_transf_vol);

  	      qpr_regression_analysis.reg_antitransf
                                      (int_lines_rec.PRICE_PLAN_ID,
                                      int_lines_rec.INVENTORY_ITEM_ID,
                                      int_lines_rec.pr_segment_id,
                                      (int_lines_rec.REGRESSION_INTERCEPT +
                                      int_lines_rec.REGRESSION_SLOPE *
                                      l_transf_vol),
                                      l_recommend_price);
					l_recommend_price := l_recommend_price * l_deal_curr_conv;
				end if;
      else
        l_recommend_price := 0;
      end if;

      log_debug('Recommended_price = ' || l_recommend_price);

      insert into qpr_pn_lines(PN_LINE_ID,
                              RESPONSE_HEADER_ID,
                              REQUEST_HEADER_ID,
                              PRICE_PLAN_ID,
                              SOURCE_REF_LINE_ID,
                              SOURCE_REQUEST_LINE_NUMBER,
                              SOURCE_REF_HDR_ID,
                              SOURCE_ID,
                              ORG_ID,
                              INVENTORY_ITEM_ID,
                              PAYMENT_TERM_ID,
                              PARENT_PN_LINE_ID,
                              GEOGRAPHY_ID,
                              UOM_CODE,
                              CURRENCY_CODE,
                              ITEM_TYPE_CODE, ORDERED_QTY,
                              COMPETITOR_PRICE,
                              PROPOSED_PRICE,
                              ORG_DIM_SK,
                              ORG_LONG_DESC,
                              ORG_SHORT_DESC,
                              COMPETITOR_NAME,
                              REVISED_OQ,
                              PRODUCT_DIM_SK,
                              INVENTORY_ITEM_SHORT_DESC,
                              INVENTORY_ITEM_LONG_DESC,
                              VOL_BAND_SK,
                              GEOGRAPHY_SK,
                              GEOGRAPHY_SHORT_DESC,
                              GEOGRAPHY_LONG_DESC,
                              PAYMENT_TERM_SHORT_DESC,
                              PAYMENT_TERM_LONG_DESC,
                              UOM_SHORT_DESC,
                              CURRENCY_SHORT_DESC,
                              COMMENTS, ADDITIONAL_INFORMATION,
                              SHIP_METHOD_CODE,
                              SHIP_METHOD_SHORT_DESC,
                              SHIP_METHOD_LONG_DESC,
                              DATAMART_NAME,
                              REGRESSION_SLOPE,
                              REGRESSION_INTERCEPT,
                              RECOMMENDED_PRICE,
                              PR_SEGMENT_ID,
                              PR_SEGMENT_SK,
                              ORIG_PAYMENT_TERM_ID,
                              ORIG_SHIP_METHOD_CODE,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATE_LOGIN,
                              LAST_UPDATED_BY)
              values(QPR_PN_LINES_S.nextval,
                    l_response_id,
                    l_request_id,
                    int_lines_rec.PRICE_PLAN_ID,
                    int_lines_rec.SOURCE_REF_LINE_ID,
                    int_lines_rec.SOURCE_REQUEST_LINE_NUMBER,
                    int_lines_rec.SOURCE_REF_HDR_ID,
                    int_lines_rec.SOURCE_ID,
                    int_lines_rec.ORG_ID,
                    int_lines_rec.INVENTORY_ITEM_ID,
                    int_lines_rec.PAYMENT_TERM_ID,
                    int_lines_rec.TOP_MDL_SRC_LINE_ID,
                    int_lines_rec.GEOGRAPHY_ID,
                    int_lines_rec.UOM_CODE,
                    int_lines_rec.CURRENCY_CODE,
                    int_lines_rec.ITEM_TYPE_CODE,
                    int_lines_rec.ORDERED_QTY,
                    int_lines_rec.COMPETITOR_PRICE,
                    int_lines_rec.PROPOSED_PRICE,
                    nvl2(int_lines_rec.ORG_ID,
                    'OPERATING_UNIT_L_'||int_lines_rec.ORG_ID,null),
                    int_lines_rec.ORG_LONG_DESC,
                    int_lines_rec.ORG_SHORT_DESC,
                    int_lines_rec.COMPETITOR_NAME,
                    int_lines_rec.ORDERED_QTY,
                    nvl2(int_lines_rec.INVENTORY_ITEM_ID,
                   'ITEM_L_'||int_lines_rec.INVENTORY_ITEM_ID, null),
                    int_lines_rec.INVENTORY_ITEM_SHORT_DESC,
                    int_lines_rec.INVENTORY_ITEM_LONG_DESC,
                    int_lines_rec.VOL_BAND_SK,
                   nvl2(int_lines_rec.GEOGRAPHY_ID,
                  'TRADING_PARTNER_SITE_L_'||int_lines_rec.GEOGRAPHY_ID,
                      null),
                    int_lines_rec.GEOGRAPHY_SHORT_DESC,
                    int_lines_rec.GEOGRAPHY_LONG_DESC,
                    int_lines_rec.PAYMENT_TERM_SHORT_DESC,
                    int_lines_rec.PAYMENT_TERM_LONG_DESC,
                    int_lines_rec.UOM_SHORT_DESC,
                    int_lines_rec.CURRENCY_SHORT_DESC,
                    int_lines_rec.COMMENTS,
                    int_lines_rec.ADDITIONAL_INFORMATION,
                    int_lines_rec.SHIP_METHOD_CODE,
                    int_lines_rec.SHIP_METHOD_SHORT_DESC,
                    int_lines_rec.SHIP_METHOD_LONG_DESC,
                    int_lines_rec.datamart_name,
                    int_lines_rec.regression_slope,
                    int_lines_rec.regression_intercept,
                    l_recommend_price,
                    int_lines_rec.pr_segment_id,
                    nvl2(int_lines_rec.pr_Segment_id,
                        'PR_SEGMENT_L_' || int_lines_rec.pr_segment_id, null),
                      int_lines_rec.PAYMENT_TERM_ID,
                      int_lines_rec.SHIP_METHOD_CODE,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.CONC_LOGIN_ID)
           returning PN_LINE_ID into l_line_id;

      log_debug('Inserted line: pn_line_id = ' || l_line_id);

      insert_price_adj_recs( l_response_id, l_line_id,
                              int_lines_rec.source_ref_line_id,
                              int_lines_rec.source_ref_hdr_id,
                              int_lines_rec.source_id);

    end loop; -- lines loop


    for lines_rec in c_pn_lines(l_response_id) loop

      l_list_price := insert_prices(l_response_id, lines_rec.pn_line_id,
                    lines_rec.source_ref_line_id, lines_rec.source_ref_hdr_id,
                    lines_rec.source_id);

      insert_policy_details(
                            c_int_header_rec.PN_REQ_HEADER_CREATION_DATE,
                            lines_rec.pr_segment_id,
                            lines_rec.vol_band_sk,
                            lines_rec.pn_line_id,
                            l_list_price,
                            lines_rec.currency_code,
                            lines_rec.ordered_qty,true);
      log_debug('Determine Line score');
      l_line_score := get_line_score(lines_rec.pn_line_id,
                                      lines_rec.recommended_price);

      update qpr_pn_lines set line_pricing_score = round(l_line_score, 2)
      where pn_line_id = lines_rec.pn_line_id;
    end loop; -- 2nd lines loop

    -- insert adjustment records for header and line total adjustment
    log_debug('Consolidating adjustment records');
    insert_price_adj_recs(l_response_id, null, null, null,null);

    log_debug('Consolidating price records');
    l_list_price := insert_prices(l_response_id, null);

    log_debug('Updating details for rolled up model of the quote');
    insert_model_lines(l_response_id,
											c_int_header_rec.PN_REQ_HEADER_CREATION_DATE);

    log_debug('Header Score calc...');
    begin
    select round(sum(nvl(l.line_pricing_score,0)*nvl(pr.amount,0))/
            sum(nvl(pr.amount,0)), 2)
    into l_total_score
    from qpr_pn_lines l, qpr_pn_prices pr, qpr_pn_pr_types prt
    where l.response_header_id = l_response_id
    and pr.response_header_id= l.response_header_id
    and pr.pn_line_id = l.pn_line_id
    and pr.pn_pr_type_id = prt.pn_pr_type_id
    and prt.price_type_name = 'LISTPRICE';
    exception
      when others then
        l_total_score := 0;
    end;

    log_debug('Header Score:' || round(l_total_score, 2));

      update qpr_pn_response_hdrs
      set deal_header_score = round(l_total_score, 2)
      where response_header_id = l_response_id;

    log_debug('Check compliance and fetch approvers if needed...');
    qpr_deal_approvals_pvt.init_approvals(l_response_id,
                                          fnd_global.user_id,
                                            p_is_deal_compliant,
                                            l_return_status);
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      retcode := 2;
      errbuf := sqlerrm;
      FND_MESSAGE.Set_Name ('QPR','QPR_COMPLIACE_ERROR');
      FND_MSG_PUB.Add;
      log_debug('Error checking compliance');
      exit;
    else
      if p_is_deal_compliant = 'Y' then
        l_response_status := 'PEND_ACCEPT_NO_APPROVE';
        log_debug('Deal is complaint');
      else
        l_response_status := 'APPROVE_REQ';
        log_debug('Deal is non-compliant. Requires approval');
      end if;

      update qpr_pn_response_hdrs
      set response_status = l_response_status
      where response_header_id = l_response_id;
    end if;

  end loop; -- header loop
  p_response_id := l_response_id;

exception
when others then
errbuf := sqlerrm;
retcode := 2;
log_debug(sqlerrm);
log_debug(dbms_utility.format_error_backtrace);
end insert_req_res_header_lines;


procedure insert_price_int_adj_recs(p_source_ref_hdr_id in number,
                                    p_source_ref_line_id in number,
                                    p_src_id in number,
                   p_er_det_rec in qpr_deal_pvt.pn_aw_data_rec)
is
cursor c_offadj(p_sm_code varchar2, p_pt_code varchar2,
                p_rbt_code varchar2,
                p_sm_oad_val number, p_pt_oad_val number,
                p_rbt_oad_val number) is
  select er_type, er_name, er_desc, er_val, er_tot_val
  from (
  select 'OFFINVOICE' er_type,
  decode(num, '1', nvl2(p_sm_code, substr(p_sm_code, 12), 'ShippingMethod-'),
          '2', nvl2(p_pt_code, substr(p_pt_code, 12), 'PaymentTerm-'),
          '3', substr(p_rbt_code, 11)) er_name,
  decode(num, '1', l.ship_method_long_desc,
              '2', l.payment_term_short_desc,
              '3', qpr_sr_util.get_oad_ar_cm_type_desc) er_desc,
  decode(nvl(l.ordered_qty,0), 0 , 0, decode(num, '1', p_sm_oad_val, '2', p_pt_oad_val,
        '3', p_rbt_oad_val)/l.ordered_qty) er_val,
  decode(nvl(l.ordered_qty, 0), 0 , 0, decode(num, '1', p_sm_oad_val, '2', p_pt_oad_val,
  '3', p_rbt_oad_val)) er_tot_val
  from qpr_pn_int_lines l,
  (select rownum num from dual connect by level <=3)
  where l.source_ref_hdr_id = p_source_ref_hdr_id
  and l.source_ref_line_id = p_source_ref_line_id
  and l.source_id = p_src_id)
  where er_name is not null;

t_er_typ char240_type;
t_er_name char240_type;
t_er_desc char240_type;
t_er_val num_type;
t_tot_er num_type;
l_ord_qty number;
l_adj_id number;
l_er_name varchar2(240);

begin
if p_er_det_rec.pn_line_id is not null then
  if p_er_det_rec.get_cost_flag = 'Y' then
    begin
      select pn_int_pr_adj_id,
      l.ordered_qty
      into l_adj_id, l_ord_qty
      from qpr_pn_int_pr_adjs pr, qpr_pn_int_lines l
      where pr.source_ref_hdr_id = p_source_ref_hdr_id
      and pr.source_ref_line_id = p_source_ref_line_id
      and pr.source_id = p_src_id
      and pr.source_ref_line_id = l.source_ref_line_id
      and pr.source_ref_hdr_id = l.source_ref_hdr_id
      and pr.source_id = l.source_id
      and erosion_type = 'COST'
      and rownum < 2;

      update qpr_pn_int_pr_adjs set erosion_per_unit = p_er_det_rec.unit_cost,
      erosion_amount = p_er_det_rec.unit_cost * l_ord_qty
      where pn_int_pr_adj_id = l_adj_id;

      log_debug('updated cost: unit cost' || p_er_det_rec.unit_cost);
    exception
      when others then
        null;
    end;
  end if;

 -- inserting oninvoice modifier: QPR_WHATIF --
  delete qpr_pn_int_pr_adjs where source_ref_hdr_id  = p_source_ref_hdr_id
  and source_ref_line_id = p_source_ref_line_id
  and source_id = p_src_id
  and erosion_type = 'ONINVOICE' and erosion_name = 'QPR_WHATIF';

  begin
    select meaning into l_er_name
    from qpr_lookups where lookup_type = 'QPR_DEAL_EROSIONS'
    and lookup_code = 'WHATIF' and rownum < 2;
  exception
    when no_data_found then
      l_er_name := 'What-If Analysis';
  end;

  insert into qpr_pn_int_pr_adjs(PN_INT_PR_ADJ_ID,
                                  SOURCE_REF_HDR_ID,
                                  SOURCE_REF_LINE_ID,
                                  SOURCE_ID,
                                  EROSION_TYPE,
                                  EROSION_NAME,
                                  EROSION_DESC,
                                  EROSION_PER_UNIT,
                                  erosion_amount,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_LOGIN)
    values(qpr_pn_int_pr_adjs_s.nextval,
           p_source_ref_hdr_id,
           p_source_ref_line_id,
           p_src_id,
           'ONINVOICE',
           'QPR_WHATIF',
           l_er_name,
           0, 0,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.CONC_LOGIN_ID);

  log_debug('Inserted oninvoice modifier QPR_WHATIF for use in whatif');

  -- Insert offinvoice modifiers ----
  delete qpr_pn_int_pr_adjs where source_ref_hdr_id  = p_source_ref_hdr_id
  and source_ref_line_id = p_source_ref_line_id
  and source_id = p_src_id
  and erosion_type = 'OFFINVOICE';

  open c_offadj(p_er_det_rec.ship_method_code,
                p_er_det_rec.payment_term_code,
                p_er_det_rec.rebate_code,
                p_er_det_rec.ship_method_oad_val,
                p_er_det_rec.payment_term_oad_val,
                p_er_det_rec.rebate_oad_val);
  fetch c_offadj bulk collect into t_er_typ, t_er_name, t_er_desc,
                                    t_er_val, t_tot_er;
  close c_offadj;

  forall i in t_er_name.first..t_er_name.last
    insert into qpr_pn_int_pr_adjs(PN_INT_PR_ADJ_ID,
                                  SOURCE_REF_HDR_ID,
                                  SOURCE_REF_LINE_ID,
                                  SOURCE_ID,
                                  EROSION_TYPE,
                                  EROSION_NAME,
                                  EROSION_DESC,
                                  EROSION_PER_UNIT,
                                  erosion_amount,
                                  CREATION_DATE,
                                  CREATED_BY,
                                  LAST_UPDATE_DATE,
                                  LAST_UPDATED_BY,
                                  LAST_UPDATE_LOGIN)
    values(qpr_pn_int_pr_adjs_s.nextval,
           p_source_ref_hdr_id,
           p_source_ref_line_id,
           p_src_id,
            t_er_typ(i),
            t_er_name(i),
            t_er_desc(i),
            t_er_val(i),
            t_tot_er(i),
            SYSDATE,
            FND_GLOBAL.USER_ID,
            SYSDATE,
            FND_GLOBAL.USER_ID,
            FND_GLOBAL.CONC_LOGIN_ID);
  for i in t_er_name.first..t_er_name.last loop
    log_debug('Inserted Offinvoice modifier ' || t_er_name(i)
                || ': Erosion per unit=' || t_er_val(i));
  end loop;

  t_er_typ.delete;
  t_er_name.delete;
  t_er_desc.delete;
  t_er_val.delete;
  t_tot_er.delete;

end if;

exception
  when others then
    log_debug(dbms_utility.format_error_backtrace);
    raise;
end insert_price_int_adj_recs;

function determine_line_price(p_src_ref_hdr_id in number,
                              p_src_ref_line_id in number,
                              p_src_id in number,
                              p_price_type_name in varchar2)
                              return number is
cursor c_pr_type is
select * from qpr_pn_pr_types order by sequence_no;

cursor c_adjs(p_erosion_type varchar2) is
select nvl(sum(erosion_per_unit),0) unit_erosion
from qpr_pn_int_pr_adjs
where source_ref_line_id = p_src_ref_line_id
and source_ref_hdr_id = p_src_ref_hdr_id
and source_id = p_src_id
and erosion_type = p_erosion_type;

c_line SYS_REFCURSOR;
l_price number;
l_sql varchar2(10000);
begin
  for r_pr_typ in c_pr_type loop
    if r_pr_typ.derived_from_type is not null then
      for r1 in c_adjs(r_pr_typ.erosion_type) loop
        l_price := l_price - r1.unit_erosion;
      end loop;
    else
      l_sql := 'select ' || r_pr_typ.column_name
         || ' from qpr_pn_int_lines'
         || ' where source_ref_hdr_id = :1 and source_ref_line_id = :2'
         || ' and pn_req_line_status_flag  = ''I'' and source_id = :3 '
         || ' and rownum < 2';
      open c_line for l_sql using p_src_ref_hdr_id, p_src_ref_line_id, p_src_id;
      fetch c_line into l_price;
      close c_line;
    end if;
    if p_price_type_name = r_pr_typ.price_type_name then
      exit;
    end if;
  end loop;
  return(l_price);
end determine_line_price;

procedure do_deal_preprocess(errbuf out nocopy varchar2,
                             retcode out nocopy varchar2,
                             p_src_ref_hdr_id in number,
                             p_pn_int_hdr_id in number) is
cursor c_int_lines(p_src_id number) is
select * from qpr_pn_int_lines
where source_ref_hdr_id = p_src_ref_hdr_id
and source_id = p_src_id
and pn_req_line_status_flag = 'I';

cursor c_int_hdr is
select * from qpr_pn_int_headers
where pn_int_header_id = p_pn_int_hdr_id
and instance_id = l_deal_instance
and rownum < 2;

cursor c_line_aw(p_hdr_id number, p_src_id number) is
select distinct price_plan_id
from qpr_pn_int_lines
where source_ref_hdr_id = p_hdr_id
and source_id = p_src_id;

cursor c_pn_lines(p_hdr_id number, p_price_plan_id number, p_src_id number) is
select * from qpr_pn_int_lines
where source_ref_hdr_id = p_hdr_id
and source_id = p_src_id
and price_plan_id = nvl(p_price_plan_id, price_plan_id);


l_transf_group_id number;
l_aw_name varchar2(240);
l_datamart_id number;
l_uom_conversion_odm number;
l_vol_band varchar2(240);
l_sql varchar2(30000);
l_line_ctr number;
l_gross_rev number;
l_inv_price number;
l_pr_segment_id number;
l_pol_importance_code varchar2(30);
l_slope number;
l_intercept number;
begin
log_debug('Determining prerequisites for line processing...');
l_transf_group_id := to_number(nvl(fnd_profile.value(
                                        'QPR_VOL_BAND_DEAL'),0));

for c_int_header_rec in c_int_hdr loop
  for int_lines_rec in c_int_lines(c_int_header_rec.source_id) loop
    log_debug('Source Line Id: '||int_lines_rec.source_ref_line_id);

    if int_lines_rec.uom_code is not null then
       l_uom_conversion_odm := qpr_sr_util.uom_conv(
                                int_lines_rec.UOM_CODE,
                                int_lines_rec.inventory_item_id,
                                null);
    else
       l_uom_conversion_odm := 0;
    end if;

    -- get pricing segment --
    log_debug('Finding Pricing Segment');
    qpr_policy_eval.get_pricing_segment_id(
                            l_deal_instance,
                            null,
                            c_int_header_rec.pn_req_header_creation_date,
                            int_lines_rec.inventory_item_id,
                            int_lines_rec.geography_id,
                            c_int_header_rec.customer_id,
                            int_lines_rec.org_id,
                            c_int_header_rec.sales_rep_id,
                            c_int_header_rec.sales_channel_code,
                            null,
                            l_pr_segment_id,
                            l_pol_importance_code );
    if nvl(l_pr_segment_id,0) = 0 then
      retcode := 2;
      FND_MESSAGE.Set_Name ('QPR','QPR_NO_PSG');
      FND_MESSAGE.Set_Token ('LINE_ID','int_lines_rec.source_ref_line_id');
      FND_MSG_PUB.Add;
      log_debug('No pricing segment found for line:'
                  || int_lines_rec.source_ref_line_id);
      return;
    end if;

    log_debug('Pricing Segment:' || l_pr_segment_id);
    --- Volume Band --
    log_debug('Finding volume band');
    log_debug('Volume band group used: '||l_transf_group_id);

		if l_uom_conversion_odm < 0 then
			l_vol_band := null;
		else
	    l_vol_band := qpr_deal_pvt.get_volume_band(errbuf, retcode,
                int_lines_rec.inventory_item_id,
                int_lines_rec.ordered_qty * l_uom_conversion_odm,
                l_transf_group_id);
		end if;
    -- assign aw --
    log_debug('Findind Datamart');
    l_datamart_id := qpr_deal_pvt.assign_aw(errbuf, retcode,
                             l_deal_instance,
                             int_lines_rec.inventory_item_id,
                             int_lines_rec.org_id,
                             c_int_header_rec.sales_rep_id,
                             c_int_header_rec.customer_id,
                             int_lines_rec.geography_id,
                             c_int_header_rec.sales_channel_code,
                             l_pr_segment_id,
                             l_aw_name);

    if l_datamart_id = 0 then
      retcode := 2;
      FND_MESSAGE.Set_Name ('QPR','QPR_NO_DATAMART');
      FND_MESSAGE.Set_Token ('LINE_ID','int_lines_rec.source_ref_line_id');
      FND_MSG_PUB.Add;
      log_debug('No datamart found for line:'
                  || int_lines_rec.source_ref_line_id);
      return;
    end if;

    log_debug('Finding regression slope and intercept');
    begin
      select nvl(regression_slope,0), nvl(regression_intercept ,0)
      into l_slope, l_intercept
      from qpr_regression_result
      where price_plan_id = l_datamart_id
      and product_id = int_lines_rec.inventory_item_id
      and pr_segment_id = l_pr_segment_id;
    exception
      when NO_DATA_FOUND then
      l_slope := 0;
      l_intercept := 0;
    end;
    log_debug('Slope:' || l_slope);
    log_debug('Intercept:' || l_intercept);

    update qpr_pn_int_lines
    set price_plan_id = l_datamart_id,
    datamart_name = l_aw_name,
    vol_band_sk = l_vol_band,
    pr_segment_id = l_pr_segment_id,
    regression_slope = l_slope,
    regression_intercept = l_intercept
    where pn_int_line_id = int_lines_rec.pn_int_line_id;
  end loop; -- lines loop

  log_debug('Get offinvoice adjustments and model cost for lines from datamart...');
  for aw_rec in c_line_aw(p_src_ref_hdr_id,c_int_header_rec.source_id) loop
    l_line_ctr := 1;
    log_debug('Getting details from datamart:' || aw_rec.price_plan_id);
    for lines_rec in c_pn_lines(p_src_ref_hdr_id,
                                aw_rec.price_plan_id,
                                c_int_header_rec.source_id) loop
      l_inv_price := determine_line_price(p_src_ref_hdr_id,
                 lines_rec.source_ref_line_id, lines_rec.source_id, 'INVPRICE');
      l_gross_rev := l_inv_price * lines_rec.ordered_qty;

      if l_line_ctr = 1 then
        g_t_aw_det := qpr_deal_pvt.pn_aw_tbl_type();
      end if;
      g_t_aw_det.extend;
      g_t_aw_det(l_line_ctr).PN_LINE_ID := lines_rec.SOURCE_REF_LINE_ID;
      g_t_aw_det(l_line_ctr).CUSTOMER_SK:= 'TRADING_PARTNER_L_' ||
                                     c_int_header_rec.CUSTOMER_ID;
      g_t_aw_det(l_line_ctr).PRODUCT_DIM_SK:=  'ITEM_L_' ||
                                        lines_rec.inventory_item_id;
      g_t_aw_det(l_line_ctr).PR_SEGMENT_SK := 'PR_SEGMENT_L_' ||
                                        lines_rec.pr_segment_id;
      g_t_aw_det(l_line_ctr).DEAL_CREATION_DATE:=
                        c_int_header_rec.PN_REQ_HEADER_CREATION_DATE;
      g_t_aw_det(l_line_ctr).DEAL_CURRENCY:= c_int_header_rec.CURRENCY_CODE;

      if lines_rec.payment_term_id is null then
        g_t_aw_det(l_line_ctr).PAYMENT_TERM_CODE:= null;
      else
        g_t_aw_det(l_line_ctr).PAYMENT_TERM_CODE:='OFF_TERM_L_PaymentTerm-'
                                    || (lines_rec.payment_term_id);
      end if;
      if lines_rec.ship_method_code is null then
       g_t_aw_det(l_line_ctr).SHIP_METHOD_CODE:= null;
      else
        g_t_aw_det(l_line_ctr).SHIP_METHOD_CODE:=
                                    'OFF_TERM_L_ShippingMethod-'
                                  || (lines_rec.ship_method_code);
      end if;
      g_t_aw_det(l_line_ctr).REBATE_CODE:= 'OFF_TYP_L_REBATE';
      g_t_aw_det(l_line_ctr).GROSS_REVENUE:= l_gross_rev;
      g_t_aw_det(l_line_ctr).PAYMENT_TERM_OAD_VAL:=0;
      g_t_aw_det(l_line_ctr).SHIP_METHOD_OAD_VAL:= 0;
      g_t_aw_det(l_line_ctr).REBATE_OAD_VAL:= 0;
      if (lines_rec.item_type_code = 'MDL') or
        (lines_rec.item_type_code = 'ATOCLASS') or
        (lines_rec.item_type_code = 'PTOCLASS') then
        g_t_aw_det(l_line_ctr).GET_COST_FLAG := 'Y';
      else
        g_t_aw_det(l_line_ctr).GET_COST_FLAG := 'N';
      end if;
      g_t_aw_det(l_line_ctr).UNIT_COST := 0;

      l_line_ctr := l_line_ctr + 1;
    end loop;

    qpr_deal_pvt.get_line_aw_details(errbuf, retcode,
                                    aw_rec.price_plan_id,
                                    l_deal_instance,
                                    g_t_aw_det);

    if nvl(retcode,0) = 0 then
      log_debug('Fetched details from datamart');
      if g_t_aw_det.count > 0 then
      for k in 1..g_t_aw_det.count loop
        log_debug('inserting/updating adjustment values for:'
                    || g_t_aw_det(k).pn_line_id);
        insert_price_int_adj_recs(p_src_ref_hdr_id,
                                  g_t_aw_det(k).pn_line_id,
                                  c_int_header_rec.source_id,
                                  g_t_aw_det(k));
      end loop;
      end if;
    end if;

    g_t_aw_det.delete;
  end loop;
end loop; --hdr

exception
  when others then
    retcode := 2;
    errbuf := sqlerrm;
    log_debug(dbms_utility.format_error_backtrace);
end do_deal_preprocess;

-- called from concurrent program --
procedure process_deal(
                      errbuf              OUT NOCOPY VARCHAR2,
                      retcode             OUT NOCOPY VARCHAR2,
                      f_source_ref_id NUMBER,
                      t_source_ref_id NUMBER,
                      reprocess varchar2 default 'N',
                      reload varchar2 default 'N')
is
l_request_id number;
l_count number;
l_response_id number;
l_deal_compliant varchar2(1);
t_src_hdr_id num_type;
t_pn_int_hdr num_type;
t_instance num_type;
t_src_id num_type;

cursor i_header is
select source_ref_header_id, pn_int_header_id, instance_id, source_id
from qpr_pn_int_headers
where request_id = l_request_id;

l_count_lines number := 0;

begin
   log_debug('Starting..');

   l_request_id := fnd_global.conc_request_id;

   update qpr_pn_int_headers rih
   set rih.request_id = l_request_id
   where rih.source_ref_header_id between
	 nvl(f_source_ref_id, rih.source_ref_header_id)
   and nvl(t_source_ref_id, rih.source_ref_header_id)
   and ((reprocess = 'N' and rih.pn_req_header_status_flag = 'I')
   or (reprocess = 'Y' and rih.pn_req_header_status_flag = 'F'));

   l_count := sql%rowcount;
   commit;

   if l_count >0 then
      log_debug('Collecting headers to process..');
      open i_header;
      fetch i_header bulk collect
      into t_src_hdr_id, t_pn_int_hdr, t_instance, t_src_id;
      close i_header;

      log_debug('No of headers to process-'||t_src_hdr_id.count);

      for I in 1..t_src_hdr_id.count
      loop
        log_debug('Processing Header:' || t_src_hdr_id(i));
        l_deal_instance := t_instance(i);
        begin
          select 1 into l_count_lines
          from qpr_pn_int_lines
          where source_ref_hdr_id = t_src_hdr_id(i)
          and source_id = t_src_id(i)
          and pn_req_line_status_flag = 'I' and rownum < 2;
        exception
          when NO_DATA_FOUND then
          log_debug('No lines exist for the Header: '||t_pn_int_hdr(i));
          l_count_lines := 0;
        end;
        if (l_count_lines = 1) then
          savepoint deal_processing;
          do_deal_preprocess(errbuf, retcode, t_src_hdr_id(i),
                            t_pn_int_hdr(i));
          if nvl(retcode,0) <> 2 then
            insert_req_res_header_lines(errbuf, retcode,
                                      t_src_hdr_id(i),
                                      t_pn_int_hdr(i),
                                      'N',
                                      l_response_id,
                                      l_deal_compliant);
          end if;
          if nvl(retcode, 0) = 2 then
            rollback to deal_processing;

            update qpr_pn_int_headers
            set request_id = null,
            pn_req_header_status_flag = 'F'
            where pn_int_header_id = t_pn_int_hdr(i);

            commit;

          else
            delete qpr_pn_int_headers where pn_int_header_id = t_pn_int_hdr(i);

            delete qpr_pn_int_lines where source_ref_hdr_id = t_src_hdr_id(i)
            and source_id = t_src_id(i);

            delete qpr_pn_int_pr_adjs where source_ref_hdr_id = t_src_hdr_id(i)
            and source_id = t_src_id(i);

            commit;
          end if;
        end if; -- Check for the existence of lines
      end loop;
   end if;
exception
 WHEN NO_DATA_FOUND THEN
    retcode := 2;
    errbuf  := FND_MESSAGE.GET;
    fnd_file.put_line( fnd_file.log, 'Deal not found in Interface tables');
 when others then
    retcode := 2;
    errbuf  := FND_MESSAGE.GET;
    fnd_file.put_line( fnd_file.log, 'Unexpected error '||substr(sqlerrm,1200));
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end process_deal;

procedure process_deal_api(
                      errbuf              OUT NOCOPY VARCHAR2,
                      retcode             OUT NOCOPY VARCHAR2,
                      p_instance_id in number,
                      p_source_id in number,
                      p_quote_header_id in number,
                      p_simulation in varchar2 default 'Y',
                      p_response_id out nocopy number,
                      p_is_deal_compliant out nocopy varchar2,
                      p_rules_desc out nocopy varchar2)
is
l_src_hdr_id number;
l_pn_int_hdr number;
l_count_lines number := 0;

cursor i_header is
select source_ref_header_id, pn_int_header_id, instance_id
from qpr_pn_int_headers
where source_ref_header_id = p_quote_header_id
and source_id = p_source_id
and instance_id = p_instance_id
and pn_req_header_status_flag  = 'I'
and rownum < 2;

cursor c_resp_app(p_resp_hdr_id number) is
select distinct rule_description
from qpr_pn_response_approvals
where response_header_id = p_resp_hdr_id;

begin
  g_origin := p_source_id;
  log_debug('Starting..');

  open i_header;
  fetch i_header
  into l_src_hdr_id, l_pn_int_hdr, l_deal_instance;
  close i_header;

  begin
    begin
      select 1 into l_count_lines
      from qpr_pn_int_lines
      where source_ref_hdr_id = l_src_hdr_id
      and source_id = p_source_id
      and pn_req_line_status_flag = 'I' and rownum < 2;
    exception
    when NO_DATA_FOUND then
      FND_MESSAGE.Set_Name ('QPR','QPR_NO_LINES');
      FND_MESSAGE.Set_Token ('HEADER_ID','l_pn_int_hdr');
      FND_MSG_PUB.Add;
      log_debug('No lines exist for the Header: '||l_pn_int_hdr);
      retcode := 2;
      errbuf := 'No lines exist for quote';
      return;
    end;

    do_deal_preprocess(errbuf, retcode, l_src_hdr_id,
                          l_pn_int_hdr);

    if nvl(retcode,0) <> 2 then
      insert_req_res_header_lines(errbuf, retcode,
                              l_src_hdr_id,
                              l_pn_int_hdr,p_simulation,
                              p_response_id,
                              p_is_deal_compliant
                              );
    end if;

    if nvl(retcode,0) <> 2 then
        if p_is_deal_compliant = 'N' then
          l_count_lines := 0;
          p_rules_desc := '';
          for rec_app in c_resp_app(p_response_id) loop
            p_rules_desc := p_rules_desc || rec_app.rule_description;
            l_count_lines := l_count_lines + 1;
            if l_count_lines > 9 then
              exit;
            else
              p_rules_desc := p_rules_desc || ',';
            end if;
          end loop;
        end if;

        delete qpr_pn_int_headers where pn_int_header_id = l_pn_int_hdr;

        delete qpr_pn_int_lines where source_ref_hdr_id = l_src_hdr_id
        and source_id = p_source_id;

        delete qpr_pn_int_pr_adjs where source_ref_hdr_id = l_src_hdr_id
        and source_id =  p_source_id;

    end if;
  end;
exception
 when others then
    retcode := 2;
    errbuf  := FND_MESSAGE.GET;
    fnd_file.put_line( fnd_file.log, 'Unexpected error '||substr(sqlerrm,1200));
    fnd_file.put_line(fnd_file.log, DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
end process_deal_api;

procedure create_deal_version(errbuf out nocopy varchar2,
                              retcode out nocopy varchar2,
                              p_response_hdr_id in number,
                              p_new_resp_hdr_id out nocopy number) is
cursor c_pn_lines is
select * from qpr_pn_lines
where response_header_id = p_response_hdr_id;

-- need hdr records also so outer join --
-- join between lines ---
-- request header id since the same source line id can exist in another request
-- line_id to match lines
-- item_type_code, since the model/dummy_parent have same source_ref_line_id
cursor c_pn_pr_det(p_new_resp_hdr_id number) is
select pr.erosion_type, pr.erosion_name, pr.erosion_desc,
pr.erosion_per_unit,pr.erosion_amount, nl.pn_line_id
from qpr_pn_pr_details pr, qpr_pn_lines ol, qpr_pn_lines nl
where
pr.response_header_id = p_response_hdr_id
and pr.response_header_id = ol.response_header_id(+)
and pr.pn_line_id = ol.pn_line_id(+)
and nl.response_header_id(+) = p_new_resp_hdr_id
and ol.request_header_id = nl.request_header_id(+)
and ol.source_ref_line_id = nl.source_ref_line_id(+)
and ol.item_type_code = nl.item_type_code(+);


-- need hdr records also so outer join --
cursor c_pn_prices(p_new_resp_hdr_id number) is
select o.pn_pr_type_id, o.unit_price, o.amount,o.percent_price,
nl.pn_line_id
from qpr_pn_prices o, qpr_pn_lines nl, qpr_pn_lines ol
where o.response_header_id = p_response_hdr_id
and ol.response_header_id(+) = o.response_header_id
and ol.pn_line_id(+) = o.pn_line_id
and nl.response_header_id(+) = p_new_resp_hdr_id
and ol.request_header_id = nl.request_header_id(+)
and ol.source_ref_line_id = nl.source_ref_line_id(+)
and ol.item_type_code = nl.item_type_code(+);

-- policies are only for lines ---
cursor c_pol_price(p_new_resp_hdr_id number) is
select
op.POLICY_ID,
op.POLICY_PRICE,
op.POLICY_AMOUNT,
op.policy_line_id,
n.pn_price_id
from qpr_pn_policies op,
qpr_pn_prices o,  qpr_pn_lines ol,
qpr_pn_lines nl, qpr_pn_prices n
where op.pn_price_id = o.pn_price_id
and o.response_header_id = p_response_hdr_id
and ol.response_header_id = o.response_header_id
and ol.pn_line_id = o.pn_line_id
and nl.response_header_id = p_new_resp_hdr_id
and ol.request_header_id = nl.request_header_id
and ol.source_ref_line_id = nl.source_ref_line_id
and ol.item_type_code = nl.item_type_code
and n.pn_pr_type_id = o.pn_pr_type_id
and nl.response_header_id = n.response_header_id
and nl.pn_line_id = n.pn_line_id;


l_rows number := 1000;
l_response_id number;
l_request_hdr_id number;
l_version_no number;
l_hdr_score number;
l_return_status varchar2(10);
l_description QPR_PN_RESPONSE_HDRS.DESCRIPTION%type;
l_comments QPR_PN_RESPONSE_HDRS.COMMENTS%type;
l_response_stat QPR_PN_RESPONSE_HDRS.RESPONSE_STATUS%type;
t_er_type char240_type;
t_er_name char240_type;
t_er_desc char240_type;
t_unit_val num_type;
t_amnt num_type;
t_line_id num_type;
t_pr_typ_id num_type;
t_percent num_type;
t_pol_id num_type;
t_pol_line_id num_type;
begin
  begin
    select request_header_id, version_number, deal_header_score,
            description,comments, response_status
    into l_request_hdr_id, l_version_no, l_hdr_score,
    l_description, l_comments, l_response_stat
    from qpr_pn_response_hdrs
    where response_header_id = p_response_hdr_id
    and rownum < 2;

    select nvl(max(version_number), 0) into l_version_no
    from qpr_pn_response_hdrs
    where request_header_id = l_request_hdr_id;

    insert into qpr_pn_response_hdrs(
                                    RESPONSE_HEADER_ID,
                                    REQUEST_HEADER_ID,
                                    DEAL_HEADER_SCORE,
                                    RESPONSE_STATUS,
                                    PARENT_RESPONSE_ID,
                                    DEAL_LAST_UPDATED_BY,
                                    DEAL_LAST_UPDATE_DATE,
				OWNER_ID,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN,
                                    COMMENTS,
                                    DESCRIPTION,
                                    VERSION_NUMBER,
                                    BOOKMARK_FLAG
                                    ) values
                                    (qpr_pn_response_hdrs_s.nextval,
                                    l_request_hdr_id,
                                    l_hdr_score,
                                    l_response_stat,
                                    p_response_hdr_id,
                                    fnd_global.user_id,
                                    sysdate,
				fnd_global.user_id,
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID,
                                    SYSDATE,
                                    FND_GLOBAL.USER_ID,
                                    FND_GLOBAL.CONC_LOGIN_ID,
                                    l_comments,
                                    l_description,
                                    l_version_no + 1,
                                    'N')
 	    returning RESPONSE_HEADER_ID into l_response_id;
  exception
    when NO_DATA_FOUND then
     retcode := 2;
     errbuf := sqlerrm || 'Source Response not found';
     return;
  end;
  for lines_rec in c_pn_lines loop
    insert into qpr_pn_lines(PN_LINE_ID,
                              RESPONSE_HEADER_ID,
                              REQUEST_HEADER_ID,
                              PRICE_PLAN_ID,
                              SOURCE_REF_LINE_ID,
                              SOURCE_REQUEST_LINE_NUMBER,
                              SOURCE_REF_HDR_ID,SOURCE_ID, ORG_ID,
                              INVENTORY_ITEM_ID,
                              PAYMENT_TERM_ID,
                              PARENT_PN_LINE_ID,
                              GEOGRAPHY_ID,
                              UOM_CODE,
                              CURRENCY_CODE,
                              ITEM_TYPE_CODE, ORDERED_QTY,
                              COMPETITOR_PRICE,
                              PROPOSED_PRICE,
                              ORG_DIM_SK,
                              ORG_LONG_DESC,
                              ORG_SHORT_DESC,
                              COMPETITOR_NAME,
                              REVISED_OQ,
                              PRODUCT_DIM_SK,
                              INVENTORY_ITEM_SHORT_DESC,
                              INVENTORY_ITEM_LONG_DESC,
                              VOL_BAND_SK,
                              GEOGRAPHY_SK,
                              GEOGRAPHY_SHORT_DESC,
                              GEOGRAPHY_LONG_DESC,
                              PAYMENT_TERM_SHORT_DESC,
                              PAYMENT_TERM_LONG_DESC,
                              UOM_SHORT_DESC,
                              CURRENCY_SHORT_DESC,
                              COMMENTS, ADDITIONAL_INFORMATION,
                              SHIP_METHOD_CODE,
                              SHIP_METHOD_SHORT_DESC,
                              SHIP_METHOD_LONG_DESC,
                              DATAMART_NAME,
                              PR_SEGMENT_ID,
                              PR_SEGMENT_SK,
                              RECOMMENDED_PRICE,
                              REGRESSION_SLOPE,
                              REGRESSION_INTERCEPT,
                              LINE_PRICING_SCORE,
                              ORIG_PAYMENT_TERM_ID,
                              ORIG_SHIP_METHOD_CODE,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATE_LOGIN,
                              LAST_UPDATED_BY)
              values(QPR_PN_LINES_S.nextval,
                    l_response_id,
                    lines_rec.REQUEST_HEADER_ID,
                    lines_rec.PRICE_PLAN_ID,
                    lines_rec.SOURCE_REF_LINE_ID,
                    lines_rec.SOURCE_REQUEST_LINE_NUMBER,
                    lines_rec.SOURCE_REF_HDR_ID,
                    lines_rec.SOURCE_ID,
                    lines_rec.ORG_ID,
                    lines_rec.INVENTORY_ITEM_ID,
                    lines_rec.PAYMENT_TERM_ID,
                    lines_rec.PARENT_PN_LINE_ID,
                    lines_rec.GEOGRAPHY_ID,
                    lines_rec.UOM_CODE,
                    lines_rec.CURRENCY_CODE,
                    lines_rec.ITEM_TYPE_CODE,
                    lines_rec.ORDERED_QTY,
                    lines_rec.COMPETITOR_PRICE,
                    lines_rec.PROPOSED_PRICE,
                    lines_rec.ORG_DIM_SK,
                    lines_rec.ORG_LONG_DESC,
                    lines_rec.ORG_SHORT_DESC,
                    lines_rec.COMPETITOR_NAME,
                    lines_rec.ORDERED_QTY,
                    lines_rec.PRODUCT_DIM_SK,
                    lines_rec.INVENTORY_ITEM_SHORT_DESC,
                    lines_rec.INVENTORY_ITEM_LONG_DESC,
                    lines_rec.VOL_BAND_SK,
                    lines_rec.GEOGRAPHY_SK,
                    lines_rec.GEOGRAPHY_SHORT_DESC,
                    lines_rec.GEOGRAPHY_LONG_DESC,
                    lines_rec.PAYMENT_TERM_SHORT_DESC,
                    lines_rec.PAYMENT_TERM_LONG_DESC,
                    lines_rec.UOM_SHORT_DESC,
                    lines_rec.CURRENCY_SHORT_DESC,
                    lines_rec.COMMENTS,
                    lines_rec.ADDITIONAL_INFORMATION,
                    lines_rec.SHIP_METHOD_CODE,
                    lines_rec.SHIP_METHOD_SHORT_DESC,
                    lines_rec.SHIP_METHOD_LONG_DESC,
                    lines_rec.datamart_name,
                    lines_rec.PR_SEGMENT_ID,
                    lines_rec.PR_SEGMENT_SK,
                    lines_rec.RECOMMENDED_PRICE,
                    lines_rec.REGRESSION_SLOPE,
                    lines_rec.REGRESSION_INTERCEPT,
                    lines_rec.LINE_PRICING_SCORE,
                    lines_rec.ORIG_PAYMENT_TERM_ID,
                    lines_rec.ORIG_SHIP_METHOD_CODE,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    SYSDATE,
                    FND_GLOBAL.USER_ID,
                    FND_GLOBAL.CONC_LOGIN_ID);
  end loop;

  open c_pn_pr_det(l_response_id);
  loop
    fetch c_pn_pr_det bulk collect into t_er_type, t_er_name, t_er_desc,
                                      t_unit_val, t_amnt, t_line_id
    limit l_rows;
    exit when t_line_id.count = 0;
    forall i in t_line_id.first..t_line_id.last
      insert into qpr_pn_pr_details(PN_PR_DETAIL_ID,
                                      RESPONSE_HEADER_ID,
                                      PN_LINE_ID,
                                      EROSION_TYPE,
                                      EROSION_NAME,
                                      EROSION_DESC,
                                      EROSION_PER_UNIT,
                                      erosion_amount,
                                      CREATION_DATE,
                                      CREATED_BY,
                                      LAST_UPDATE_DATE,
                                      LAST_UPDATED_BY,
                                      LAST_UPDATE_LOGIN)
        values(qpr_pn_pr_details_s.nextval,
                l_response_id,
                t_line_id(i),
                t_er_type(i),
                t_er_name(i),
                t_er_desc(i),
                t_unit_val(i),
                t_amnt(i),
                SYSDATE,
                FND_GLOBAL.USER_ID,
                SYSDATE,
                FND_GLOBAL.USER_ID,
                FND_GLOBAL.CONC_LOGIN_ID);
        t_line_id.delete;
        t_er_type.delete;
        t_er_name.delete;
        t_er_desc.delete;
        t_unit_val.delete;
        t_amnt.delete;
  end loop;
  close c_pn_pr_det;

  open c_pn_prices(l_response_id);
  loop
    fetch c_pn_prices bulk collect into t_pr_typ_id, t_unit_val, t_amnt,
                                        t_percent, t_line_id
    limit l_rows;
    exit when t_line_id.count = 0;
    forall i in t_line_id.first.. t_line_id.last
       insert into qpr_pn_prices(PN_PRICE_ID,
                              RESPONSE_HEADER_ID,
                              PN_LINE_ID,
                              PN_PR_TYPE_ID,
                              UNIT_PRICE,
                              AMOUNT,
                              PERCENT_PRICE,
                              CREATION_DATE,
                              CREATED_BY,
                              LAST_UPDATE_DATE,
                              LAST_UPDATED_BY,
                              LAST_UPDATE_LOGIN)
                      values(
                      qpr_pn_prices_s.nextval,
                      l_response_id,
                      t_line_id(i),
                      t_pr_typ_id(i),
                      t_unit_val(i), t_amnt(i), t_percent(i),
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      SYSDATE,
                      FND_GLOBAL.USER_ID,
                      FND_GLOBAL.CONC_LOGIN_ID);
  t_line_id.delete;
  t_unit_val.delete;
  t_amnt.delete;
  t_percent.delete;
  t_pr_typ_id.delete;
  end loop;
  close c_pn_prices;

  open c_pol_price(l_response_id);
  loop
    fetch c_pol_price bulk collect into t_pol_id,
                   t_unit_val, t_amnt, t_pol_line_id, t_pr_typ_id
    limit l_rows;
    exit when t_pr_typ_id.count = 0;
    forall i in t_pr_typ_id.first..t_pr_typ_id.last
      insert into qpr_pn_policies(PN_POLICY_ID,
                                    PN_PRICE_ID,
                                    POLICY_ID,
                                    POLICY_PRICE,
                                    POLICY_AMOUNT,
                                    POLICY_LINE_ID,
                                    CREATION_DATE,
                                    CREATED_BY,
                                    LAST_UPDATE_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_LOGIN)
                 values(qpr_pn_policies_s.nextval,
                        t_pr_typ_id(i),
                        t_pol_id(i),
                        t_unit_val(i),
                        t_amnt(i),
                        t_pol_line_id(i),
                        sysdate,
                        FND_GLOBAL.USER_ID,
                        SYSDATE,
                        FND_GLOBAL.USER_ID,
                        FND_GLOBAL.CONC_LOGIN_ID);
  t_pr_typ_id.delete;
  t_pol_id.delete;
  t_pol_line_id.delete;
  t_unit_val.delete;
  t_amnt.delete;
  end loop;
  close c_pol_price;

  qpr_deal_approvals_pvt.synch_approvals(p_response_hdr_id,
                                        l_Response_id,
                                        l_return_status);
  if l_return_status <> FND_API.G_RET_STS_SUCCESS then
    retcode := 2;
    errbuf := 'Unable to copy approval history' || substr(sqlerrm, 200);
    p_new_resp_hdr_id := null;
  else
    p_new_resp_hdr_id := l_response_id;
  end if;

exception
  when OTHERS then
    retcode := 2;
    errbuf := sqlerrm;
    p_new_resp_hdr_id := null;
end create_deal_version;


procedure calculate_score(
        errbuf out nocopy varchar2,
        retcode out nocopy varchar2,
        i_response_header_id number,
        i_line_id number,
        i_date date,
        i_pr_segment_id number,
        i_inventory_item_id number,
        i_is_qty_changed in varchar2 default 'N',
        i_ordered_qty number,
        i_list_price number,
        i_unit_cost number,
        i_pock_margin number,
        i_inv_price number,
        i_recommended_price number,
        o_line_score out nocopy number)
is

l_o_qty number := 0;
l_floor_margin number := 0;

l_uom_code varchar2(240);
l_uom_conversion_odm number := 0;
l_transf_group_id number := 0;
l_vol_band varchar2(240);
l_pr_segment_id number;
l_pol_importance_code varchar2(30);
l_policy_price number := 0;
l_min_pol_price number := 0;
l_sql varchar2(30000);
l_deal_currency varchar2(30);
begin

if nvl(i_is_qty_changed, 'N') = 'Y' then

  select l.uom_code, req.instance_id,l.currency_code
  into l_uom_code, l_deal_instance, l_deal_currency
  from qpr_pn_lines l, qpr_pn_response_hdrs resp, qpr_pn_request_hdrs_b req
  where l.pn_line_id = i_line_id
  and l.response_header_id = i_response_header_id
  and l.response_header_id = resp.response_header_id
  and resp.request_header_id = req.request_header_id
  and rownum < 2;

  if l_uom_code is not null then
    l_uom_conversion_odm := qpr_sr_util.uom_conv(l_uom_code,
                            i_inventory_item_id, null);
  else
    l_uom_conversion_odm := 0;
  end if;

  l_transf_group_id := to_number(nvl(fnd_profile.value('QPR_VOL_BAND_DEAL'),0));

  if l_uom_conversion_odm < 0 then
    l_vol_band := null;
  else
    l_vol_band := qpr_deal_pvt.get_volume_band(errbuf, retcode,
                                          i_inventory_item_id,
                                          i_ordered_qty * l_uom_conversion_odm,
                                          l_transf_group_id);
  end if;

  log_debug('Volume band: '|| l_vol_band);

  delete qpr_pn_policies where pn_policy_id in(
                            select pol.pn_policy_id
                            from qpr_pn_policies pol,qpr_pn_prices pr
                            where pr.pn_price_id = pol.pn_price_id
                            and pr.response_header_id = i_response_header_id
                            and pr.pn_line_id = i_line_id);

  insert_policy_details(i_date, i_pr_segment_id, l_vol_band, i_line_id,
                        i_list_price,l_deal_currency, i_ordered_qty, true);

end if;

select nvl(min(p.policy_price) , 0) into l_floor_margin
from qpr_pn_policies p, qpr_pn_prices pric, qpr_pn_pr_types t
where pric.pn_line_id = i_line_id
and p.pn_price_id = pric.pn_price_id
and pric.pn_pr_type_id = t.pn_pr_type_id
and t.price_type_name = 'POCMARGIN';

o_line_score := score_calc(i_list_price, i_unit_cost,
                            l_floor_margin, i_pock_margin,
                            i_inv_price, i_recommended_price);

exception
when others then
  o_line_score := 0;
  retcode := 2;
  errbuf := sqlerrm;
end; -- calculate score


END QPR_DEAL_ETL ;


/
