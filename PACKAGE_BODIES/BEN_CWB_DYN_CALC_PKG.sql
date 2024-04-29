--------------------------------------------------------
--  DDL for Package Body BEN_CWB_DYN_CALC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BEN_CWB_DYN_CALC_PKG" as
/* $Header: bencwbdc.pkb 120.13.12010000.3 2009/06/19 08:28:49 sgnanama ship $ */
--
-- --------------------------------------------------------------------------
-- |                     Private Global Definitions                         |
-- --------------------------------------------------------------------------
--
g_package varchar2(33):='  ben_cwb_dyn_calc_pkg.';
g_debug boolean := hr_utility.debug_enabled;

 cursor c_calc_details
        (v_def_key in number
        ,v_def_type in varchar2) is
   select def.view_attribute rslt_col
      ,def.exe_ordr
      ,def.rndg_cd
      ,def.calc_type
      ,cond.ordr_num cond_ordr
      ,cond.value    cond_val
      ,cond_eq.ordr_num cond_eq_ordr
      ,cond_eq.view_attribute cond_eq_col
      ,cond_eq.operator cond_eq_oper
      ,cond_eq.logical cond_eq_log
      ,cond_eq.attribute1 cond_eq_attr1
      ,cond_eq.attribute2 cond_eq_attr2
      ,eq.ordr_num calc_eq_ordr
      ,eq.view_attribute calc_eq_col
      ,eq.operator calc_eq_oper
      ,eq.attribute1 calc_eq_attr1
      ,cond_eq.data_type cond_eq_data_type
      ,cond.view_attribute cond_col
      ,cond.message_type cond_msg_type
      ,cond_eq.view_attribute1 cond_eq_col1
      ,cond_eq.view_attribute2 cond_eq_col2
from  ben_calc_definitions def
      ,ben_calc_conditions cond
      ,ben_calc_equations cond_eq
      ,ben_calc_equations eq
where def.def_key = v_def_key
and   def.key_type = v_def_type
and   def.definition_id = cond.definition_id (+)
and   cond.condition_id = cond_eq.condition_id (+)
and   def.definition_id = eq.definition_id (+)
and   eq.condition_id (+) is null
order by def.exe_ordr, def.definition_id,
         cond.ordr_num, cond_eq.ordr_num,
         eq.ordr_num ;

 cursor c_allocation_row
       (v_group_per_in_ler_id in number
       ,v_group_oipl_id1 in number
       ,v_group_oipl_id2 in number
       ,v_group_oipl_id3 in number
       ,v_group_oipl_id4 in number
       ,v_perf_txn_type  in varchar2
       ,v_asg_txn_type   in varchar2) is
    select inf.*
          ,pl.elig_sal_val
          ,pl.stat_sal_val
          ,pl.ws_val
          ,pl.ws_mn_val
          ,pl.ws_mx_val
          ,pl.ws_incr_val
          ,pl.tot_comp_val
          ,pl.oth_comp_val
          ,pl.rec_val
          ,pl.rec_mn_val
          ,pl.rec_mx_val
          ,pl.misc1_val
          ,pl.misc2_val
          ,pl.misc3_val
          ,pl.currency
          ,pl.object_version_number ovn_pl
          ,dsgn.pl_annulization_factor
          ,dsgn.pl_id
          ,dsgn.ws_abr_id
          ,perf.attribute3 new_perf_rating
          ,asg.attribute3 new_change_reason
          ,asg.attribute5 new_job_id
          ,asg.attribute6 new_position_id
          ,asg.attribute7 new_grade_id
          ,opt1.elig_sal_val elig_sal_val_opt1
          ,opt1.stat_sal_val stat_sal_val_opt1
          ,opt1.ws_val ws_val_opt1
          ,opt1.ws_mn_val ws_mn_val_opt1
          ,opt1.ws_mx_val ws_mx_val_opt1
          ,opt1.ws_incr_val ws_incr_val_opt1
          ,opt1.tot_comp_val tot_comp_val_opt1
          ,opt1.oth_comp_val oth_comp_val_opt1
          ,opt1.rec_val rec_val_opt1
          ,opt1.rec_mn_val rec_mn_val_opt1
          ,opt1.rec_mx_val rec_mx_val_opt1
          ,opt1.misc1_val misc1_val_opt1
          ,opt1.misc2_val misc2_val_opt1
          ,opt1.misc3_val misc3_val_opt1
          ,opt1.currency currency_opt1
          ,opt1.object_version_number ovn_opt1
          ,opt1.oipl_id oipl_id_opt1
          ,opt1.group_oipl_id group_oipl_id_opt1
          ,opt2.elig_sal_val elig_sal_val_opt2
          ,opt2.stat_sal_val stat_sal_val_opt2
          ,opt2.ws_val ws_val_opt2
          ,opt2.ws_mn_val ws_mn_val_opt2
          ,opt2.ws_mx_val ws_mx_val_opt2
          ,opt2.ws_incr_val ws_incr_val_opt2
          ,opt2.tot_comp_val tot_comp_val_opt2
          ,opt2.oth_comp_val oth_comp_val_opt2
          ,opt2.rec_val rec_val_opt2
          ,opt2.rec_mn_val rec_mn_val_opt2
          ,opt2.rec_mx_val rec_mx_val_opt2
          ,opt2.misc1_val misc1_val_opt2
          ,opt2.misc2_val misc2_val_opt2
          ,opt2.misc3_val misc3_val_opt2
          ,opt2.currency currency_opt2
          ,opt2.object_version_number ovn_opt2
          ,opt2.oipl_id oipl_id_opt2
          ,opt2.group_oipl_id group_oipl_id_opt2
          ,opt3.elig_sal_val elig_sal_val_opt3
          ,opt3.stat_sal_val stat_sal_val_opt3
          ,opt3.ws_val ws_val_opt3
          ,opt3.ws_mn_val ws_mn_val_opt3
          ,opt3.ws_mx_val ws_mx_val_opt3
          ,opt3.ws_incr_val ws_incr_val_opt3
          ,opt3.tot_comp_val tot_comp_val_opt3
          ,opt3.oth_comp_val oth_comp_val_opt3
          ,opt3.rec_val rec_val_opt3
          ,opt3.rec_mn_val rec_mn_val_opt3
          ,opt3.rec_mx_val rec_mx_val_opt3
          ,opt3.misc1_val misc1_val_opt3
          ,opt3.misc2_val misc2_val_opt3
          ,opt3.misc3_val misc3_val_opt3
          ,opt3.currency currency_opt3
          ,opt3.object_version_number ovn_opt3
          ,opt3.oipl_id oipl_id_opt3
          ,opt3.group_oipl_id group_oipl_id_opt3
          ,opt4.elig_sal_val elig_sal_val_opt4
          ,opt4.stat_sal_val stat_sal_val_opt4
          ,opt4.ws_val ws_val_opt4
          ,opt4.ws_mn_val ws_mn_val_opt4
          ,opt4.ws_mx_val ws_mx_val_opt4
          ,opt4.ws_incr_val ws_incr_val_opt4
          ,opt4.tot_comp_val tot_comp_val_opt4
          ,opt4.oth_comp_val oth_comp_val_opt4
          ,opt4.rec_val rec_val_opt4
          ,opt4.rec_mn_val rec_mn_val_opt4
          ,opt4.rec_mx_val rec_mx_val_opt4
          ,opt4.misc1_val misc1_val_opt4
          ,opt4.misc2_val misc2_val_opt4
          ,opt4.misc3_val misc3_val_opt4
          ,opt4.currency currency_opt4
          ,opt4.object_version_number ovn_opt4
          ,opt4.oipl_id oipl_id_opt4
          ,opt4.group_oipl_id group_oipl_id_opt4
          ,null new_salary
          ,null new_grd_min_val
          ,null new_grd_max_val
          ,null new_grd_mid_point
          ,null new_grd_comparatio
          ,null new_grd_quartile
   from   ben_cwb_person_info inf
         ,ben_cwb_person_rates pl
         ,ben_cwb_pl_dsgn dsgn
         ,ben_transaction perf
         ,ben_transaction asg
         ,ben_cwb_person_rates opt1
         ,ben_cwb_person_rates opt2
         ,ben_cwb_person_rates opt3
         ,ben_cwb_person_rates opt4
   where inf.group_per_in_ler_id = v_group_per_in_ler_id
   and   inf.group_per_in_ler_id = pl.group_per_in_ler_id
   and   pl.oipl_id = -1
   and   pl.elig_flag = 'Y'
   and   pl.pl_id = dsgn.pl_id
   and   pl.oipl_id = dsgn.oipl_id
   and   pl.lf_evt_ocrd_dt = dsgn.lf_evt_ocrd_dt
   and   pl.group_per_in_ler_id = opt1.group_per_in_ler_id (+)
   and   pl.pl_id = opt1.pl_id (+)
   and   opt1.group_oipl_id (+) = v_group_oipl_id1
   and   opt1.elig_flag (+) = 'Y'
   and   pl.group_per_in_ler_id = opt2.group_per_in_ler_id (+)
   and   pl.pl_id = opt2.pl_id (+)
   and   opt2.group_oipl_id (+) = v_group_oipl_id2
   and   opt2.elig_flag (+) = 'Y'
   and   pl.group_per_in_ler_id = opt3.group_per_in_ler_id (+)
   and   pl.pl_id = opt3.pl_id (+)
   and   opt3.group_oipl_id (+) = v_group_oipl_id3
   and   opt3.elig_flag (+) = 'Y'
   and   pl.group_per_in_ler_id = opt4.group_per_in_ler_id (+)
   and   pl.pl_id = opt4.pl_id (+)
   and   opt4.group_oipl_id (+) = v_group_oipl_id4
   and   opt4.elig_flag (+) = 'Y'
   and   pl.assignment_id = perf.transaction_id (+)
   and   perf.transaction_type (+) = v_perf_txn_type
   and   pl.assignment_id = asg.transaction_id (+)
   and   asg.transaction_type (+) = v_asg_txn_type;

  cursor c_plan_info(v_group_pl_id in number
                    ,v_lf_evt_ocrd_dt in date) is
     select o1.oipl_id oipl_id1
           ,o2.oipl_id oipl_id2
           ,o3.oipl_id oipl_id3
           ,o4.oipl_id oipl_id4
           ,ben_cwb_asg_update.g_ws_perf_rec_type||
            to_char(pl.perf_revw_strt_dt,'yyyy/mm/dd')||
            pl.emp_interview_typ_cd perf_txn_type
           ,ben_cwb_asg_update.g_ws_asg_rec_type||
            to_char(pl.asg_updt_eff_date,'yyyy/mm/dd') asg_txn_type
     from  ben_cwb_pl_dsgn pl
          ,ben_cwb_pl_dsgn o1
          ,ben_cwb_pl_dsgn o2
          ,ben_cwb_pl_dsgn o3
          ,ben_cwb_pl_dsgn o4
     where pl.pl_id = v_group_pl_id
     and   pl.lf_evt_ocrd_dt = v_lf_evt_ocrd_dt
     and   pl.oipl_id = -1
     and   pl.pl_id = o1.pl_id (+)
     and   pl.lf_evt_ocrd_dt = o1.lf_evt_ocrd_dt (+)
     and   o1.oipl_ordr_num (+) = 1
     and   o1.pl_id = o2.pl_id (+)
     and   o1.lf_evt_ocrd_dt = o2.lf_evt_ocrd_dt (+)
     and   o2.oipl_ordr_num (+) = 2
     and   o2.pl_id = o3.pl_id (+)
     and   o2.lf_evt_ocrd_dt = o3.lf_evt_ocrd_dt (+)
     and   o3.oipl_ordr_num (+) = 3
     and   o3.pl_id = o4.pl_id (+)
     and   o3.lf_evt_ocrd_dt = o4.lf_evt_ocrd_dt (+)
     and   o4.oipl_ordr_num (+) = 4;

g_group_pl_id   number(15) := null;
g_lf_evt_ocrd_dt date      := null;
g_allocation_row c_allocation_row%rowtype := null;
g_plan_info c_plan_info%rowtype;
g_upd_person_info boolean := false;
g_upd_pl_rate boolean := false;
g_upd_opt1_rate boolean := false;
g_upd_opt2_rate boolean := false;
g_upd_opt3_rate boolean := false;
g_upd_opt4_rate boolean := false;

type t_calc_details is record
       (rslt_col  varchar2(30)
       ,func        varchar2(30)
       ,oper        varchar2(30)
       ,attribute1  varchar2(60)
       ,attribute2  varchar2(60)
       ,attribute1_type varchar2(30)
       ,attribute2_type varchar2(30)
       ,attribute1_oper varchar2(30)
       ,attribute2_oper varchar2(30));
type tab_calc_details is table of t_calc_details index by binary_integer;
g_calc_details tab_calc_details;

NULL_NUMBER constant number := -999999999999999;
NULL_CHAR   constant  varchar2(30) := '9--NULL--9';
CALC_START constant varchar2(30) := 'START';
CALC_END constant varchar2(30) := 'END';
CALC_RETURN constant varchar2(30) := 'RETURN';
CALC_ADD   constant varchar2(30) := 'ADD';
CALC_SUBTRACT constant varchar2(30) := 'SUB';
CALC_MULTIPLY constant varchar2(30) := 'MUL';
CALC_DIVIDE   constant varchar2(30) := 'DIV';
CALC_EVAL     constant varchar2(30) := 'EVAL';
CALC_AND      constant varchar2(30) := 'AND';
CALC_OR       constant varchar2(30) := 'OR';
CALC_ROUND    constant varchar2(30) := 'RND';

CALC_GET      constant varchar2(30) := 'GET';
CALC_FIXED    constant varchar2(30) := 'FX';
CALC_EQUAL    constant varchar2(30) := 'EQ';
CALC_MATCH    constant varchar2(30) := 'MTCH';
CALC_STARTS   constant varchar2(30) := 'STRS';
CALC_ENDS     constant varchar2(30) := 'ENDS';
CALC_CONTAINS constant varchar2(30) := 'CNTN';
CALC_NULL     constant varchar2(30) := 'NULL';
CALC_NOTNULL  constant varchar2(30) := 'NN';
CALC_BETWEEN  constant varchar2(30) := 'BTWN';
CALC_GREATER  constant varchar2(30) := 'GR';
CALC_LESS     constant varchar2(30) := 'LT';
CALC_EQGREATER constant varchar2(30) := 'EGR';
CALC_EQLESS    constant varchar2(30) := 'ELT';

CALC_NUMBER constant varchar2(30) := 'N';
CALC_DATE   constant varchar2(30) := 'D';
CALC_CHAR   constant varchar2(30) := 'T';

CALC_CALCULATOR constant varchar2(30) := 'CALC';
CALC_COND constant varchar2(30) := 'COND';
CALC_MSG constant varchar2(30) := 'MSG';

CALC_ERR constant varchar2(30) := 'ERR';
CALC_INFO constant varchar2(30) := 'INFO';

function check_null_number(p_value in number)
return number is
begin
  if p_value = NULL_NUMBER then
    return null;
  else
    return p_value;
  end if;
end check_null_number;

function check_null_char(p_value in varchar2)
return varchar2 is
begin
  if p_value = NULL_CHAR then
    return null;
  else
    return p_value;
  end if;
end check_null_char;

procedure load_plan_info(p_group_pl_id in number
                        ,p_lf_evt_ocrd_dt in date) is
begin
  if g_group_pl_id = p_group_pl_id and
     g_lf_evt_ocrd_dt = p_lf_evt_ocrd_dt then
    return;
  end if;

  open  c_plan_info(p_group_pl_id, p_lf_evt_ocrd_dt);
  fetch c_plan_info into g_plan_info;
  close c_plan_info;

  g_lf_evt_ocrd_dt := p_lf_evt_ocrd_dt;

end load_plan_info;

procedure load_allocation_row(p_group_per_in_ler_id in number) is
begin
  open  c_allocation_row(p_group_per_in_ler_id
                        ,g_plan_info.oipl_id1
                        ,g_plan_info.oipl_id2
                        ,g_plan_info.oipl_id3
                        ,g_plan_info.oipl_id4
                        ,g_plan_info.perf_txn_type
                        ,g_plan_info.asg_txn_type);
  fetch c_allocation_row into g_allocation_row;

  -- 6024581: the group_per_in_ler_id should not retain the previous value if the cursor retuns null.

  IF c_allocation_row%NOTFOUND then
    g_allocation_row := null;
  end if;

  close c_allocation_row;

  g_allocation_row.base_salary := g_allocation_row.base_salary*(g_allocation_row.pay_annulization_factor/g_allocation_row.pl_annulization_factor);
  g_allocation_row.GRD_MIN_VAL := g_allocation_row.GRD_MIN_VAL*(g_allocation_row.grade_annulization_factor/g_allocation_row.pl_annulization_factor);
  g_allocation_row.GRD_MAX_VAL := g_allocation_row.GRD_MAX_VAL*(g_allocation_row.grade_annulization_factor/g_allocation_row.pl_annulization_factor);
  g_allocation_row.GRD_MID_POINT := g_allocation_row.GRD_MID_POINT*(g_allocation_row.grade_annulization_factor/g_allocation_row.pl_annulization_factor);

end load_allocation_row;
--
function get_new_grd_min_val return number is
  l_min_val number;
begin
  if g_allocation_row.new_grd_min_val is null then
    l_min_val := ben_cwb_person_info_pkg.
                   get_grd_min_val(g_allocation_row.new_grade_id,
                                   g_allocation_row.pay_rate_id,
                                   g_allocation_row.effective_date);
    if l_min_val is null then
      g_allocation_row.new_grd_min_val := NULL_NUMBER;
    else
      g_allocation_row.new_grd_min_val := l_min_val;
    end if;
  end if;
  return check_null_number(g_allocation_row.new_grd_min_val);
end get_new_grd_min_val;
--
function get_new_grd_max_val return number is
  l_max_val number;
begin
  if g_allocation_row.new_grd_max_val is null then
    l_max_val := ben_cwb_person_info_pkg.
                   get_grd_max_val(g_allocation_row.new_grade_id,
                                   g_allocation_row.pay_rate_id,
                                   g_allocation_row.effective_date);
    if l_max_val is null then
      g_allocation_row.new_grd_max_val := NULL_NUMBER;
    else
      g_allocation_row.new_grd_max_val := l_max_val;
    end if;
  end if;
  return check_null_number(g_allocation_row.new_grd_max_val);
end get_new_grd_max_val;
--
function get_new_grd_mid_point return number is
  l_mid_point number;
begin
  if g_allocation_row.new_grd_mid_point is null then
    l_mid_point := ben_cwb_person_info_pkg.
                   get_grd_mid_point(g_allocation_row.new_grade_id,
                                   g_allocation_row.pay_rate_id,
                                   g_allocation_row.effective_date);
    if l_mid_point is null then
      g_allocation_row.new_grd_mid_point := NULL_NUMBER;
    else
      g_allocation_row.new_grd_mid_point := l_mid_point;
    end if;
  end if;
  return check_null_number(g_allocation_row.new_grd_mid_point);
end get_new_grd_mid_point;
--
function get_new_salary return number is
  cursor c_local_plan_info is
     select oipl_id,
            oipl_ordr_num
     from   ben_cwb_pl_dsgn
     where  pl_id = g_allocation_row.pl_id
     and    lf_evt_ocrd_dt = g_allocation_row.lf_evt_ocrd_dt
     and    group_pl_id = g_allocation_row.group_pl_id
     and    ws_sub_acty_typ_cd = 'ICM7';
  l_increase_amt number := null;
begin
  if g_allocation_row.new_salary is null then
    for l_local_plan_info in c_local_plan_info loop
      if l_local_plan_info.oipl_ordr_num is null then
        l_increase_amt := ben_cwb_utils.add_number_with_null_check
                           (g_allocation_row.ws_val,l_increase_amt);
      elsif l_local_plan_info.oipl_ordr_num = 1 then
        l_increase_amt := ben_cwb_utils.add_number_with_null_check
                           (g_allocation_row.ws_val_opt1,l_increase_amt);
      elsif l_local_plan_info.oipl_ordr_num = 2 then
        l_increase_amt := ben_cwb_utils.add_number_with_null_check
                           (g_allocation_row.ws_val_opt2,l_increase_amt);
      elsif l_local_plan_info.oipl_ordr_num = 3 then
        l_increase_amt := ben_cwb_utils.add_number_with_null_check
                           (g_allocation_row.ws_val_opt3,l_increase_amt);
      elsif l_local_plan_info.oipl_ordr_num = 4 then
        l_increase_amt := ben_cwb_utils.add_number_with_null_check
                           (g_allocation_row.ws_val_opt4,l_increase_amt);
      end if;
    end loop;
    --
    if l_increase_amt is null then
      g_allocation_row.new_salary := NULL_NUMBER;
    else
      g_allocation_row.new_salary := l_increase_amt +
                                     nvl(g_allocation_row.base_salary,0);
    end if;
  end if;
  return check_null_number(g_allocation_row.new_salary);
  --
end get_new_salary;
--
function get_new_grd_comparatio return number is
  l_comparatio number;
begin
  if g_allocation_row.new_grd_comparatio is null then
    if g_allocation_row.new_grade_id is not null then
      l_comparatio := ben_cwb_person_info_pkg.
                      get_grd_comparatio(nvl(get_new_salary,
                                             g_allocation_row.base_salary),
                                         get_new_grd_mid_point);
    else
      l_comparatio := ben_cwb_person_info_pkg.
                      get_grd_comparatio(get_new_salary,
                                         g_allocation_row.grd_mid_point);
    end if;
    if l_comparatio is null then
      g_allocation_row.new_grd_comparatio := NULL_NUMBER;
    else
      g_allocation_row.new_grd_comparatio := l_comparatio;
    end if;
  end if;
  return check_null_number(g_allocation_row.new_grd_comparatio);
end get_new_grd_comparatio;
--
function get_new_grd_quartile return varchar2 is
  l_quartile varchar2(30);
begin
  if g_allocation_row.new_grd_quartile is null then
    if g_allocation_row.new_grade_id is not null then
      l_quartile := ben_cwb_person_info_pkg.
                      get_grd_quartile(nvl(get_new_salary,
                                           g_allocation_row.base_salary),
                                       get_new_grd_min_val,
                                       get_new_grd_max_val,
                                       get_new_grd_mid_point);
    else
      l_quartile := ben_cwb_person_info_pkg.
                      get_grd_quartile(get_new_salary,
                                       g_allocation_row.grd_min_val,
                                       g_allocation_row.grd_max_val,
                                       g_allocation_row.grd_mid_point);
    end if;
    if l_quartile is null then
      g_allocation_row.new_grd_quartile := NULL_CHAR;
    else
      g_allocation_row.new_grd_quartile := l_quartile;
    end if;
  end if;
  return check_null_char(g_allocation_row.new_grd_quartile);
end get_new_grd_quartile;
--
function get_attribute(p_attribute_name      in varchar2)
return varchar2 is

begin
  --
   if instr(p_attribute_name, 'CustomSegment') > 0 then
  if p_attribute_name = 'CustomSegment1' then
    return g_allocation_row.custom_segment1;
  elsif p_attribute_name = 'CustomSegment2' then
    return g_allocation_row.custom_segment2;
  elsif p_attribute_name = 'CustomSegment3' then
    return g_allocation_row.custom_segment3;
  elsif p_attribute_name = 'CustomSegment4' then
    return g_allocation_row.custom_segment4;
  elsif p_attribute_name = 'CustomSegment5' then
    return g_allocation_row.custom_segment5;
  elsif p_attribute_name = 'CustomSegment6' then
    return g_allocation_row.custom_segment6;
  elsif p_attribute_name = 'CustomSegment7' then
    return g_allocation_row.custom_segment7;
  elsif p_attribute_name = 'CustomSegment8' then
    return g_allocation_row.custom_segment8;
  elsif p_attribute_name = 'CustomSegment9' then
    return g_allocation_row.custom_segment9;
  elsif p_attribute_name = 'CustomSegment10' then
    return to_char(g_allocation_row.custom_segment10);
  elsif p_attribute_name = 'CustomSegment11' then
    return to_char(g_allocation_row.custom_segment11);
  elsif p_attribute_name = 'CustomSegment12' then
    return to_char(g_allocation_row.custom_segment12);
  elsif p_attribute_name = 'CustomSegment13' then
    return to_char(g_allocation_row.custom_segment13);
  elsif p_attribute_name = 'CustomSegment14' then
    return to_char(g_allocation_row.custom_segment14);
  elsif p_attribute_name = 'CustomSegment15' then
    return to_char(g_allocation_row.custom_segment15);
  elsif p_attribute_name = 'CustomSegment16' then
    return to_char(g_allocation_row.custom_segment16);
  elsif p_attribute_name = 'CustomSegment17' then
    return to_char(g_allocation_row.custom_segment17);
  elsif p_attribute_name = 'CustomSegment18' then
    return to_char(g_allocation_row.custom_segment18);
  elsif p_attribute_name = 'CustomSegment19' then
    return to_char(g_allocation_row.custom_segment19);
  elsif p_attribute_name = 'CustomSegment20' then
    return to_char(g_allocation_row.custom_segment20);
  end if;

  elsif instr(p_attribute_name, 'Opt1') > 0 then
    if p_attribute_name = 'EligSalValOpt1' then
    return to_char(g_allocation_row.elig_sal_val_opt1);
  elsif p_attribute_name = 'PctOfEligSalOpt1' then
    return to_char(g_allocation_row.ws_val_opt1*100/g_allocation_row.elig_sal_val_opt1);
  elsif p_attribute_name = 'WsValOpt1' then
    return to_char(g_allocation_row.ws_val_opt1);
  elsif p_attribute_name = 'WsMnValOpt1' then
    return to_char(g_allocation_row.ws_mn_val_opt1);
  elsif p_attribute_name = 'WsMxValOpt1' then
    return to_char(g_allocation_row.ws_mx_val_opt1);
  elsif p_attribute_name = 'WsIncrValOpt1' then
    return to_char(g_allocation_row.ws_incr_val_opt1);
  elsif p_attribute_name = 'StatSalValOpt1' then
    return to_char(g_allocation_row.stat_sal_val_opt1);
  elsif p_attribute_name = 'TotCompValOpt1' then
    return to_char(g_allocation_row.tot_comp_val_opt1);
  elsif p_attribute_name = 'OthCompValOpt1' then
    return to_char(g_allocation_row.oth_comp_val_opt1);
  elsif p_attribute_name = 'RecValOpt1' then
    return to_char(g_allocation_row.rec_val_opt1);
  elsif p_attribute_name = 'RecMnValOpt1' then
    return to_char(g_allocation_row.rec_mn_val_opt1);
  elsif p_attribute_name = 'RecMxValOpt1' then
    return to_char(g_allocation_row.rec_mx_val_opt1);
  elsif p_attribute_name = 'Misc1ValOpt1' then
    return to_char(g_allocation_row.misc1_val_opt1);
  elsif p_attribute_name = 'Misc2ValOpt1' then
    return to_char(g_allocation_row.misc2_val_opt1);
  elsif p_attribute_name = 'Misc3ValOpt1' then
    return to_char(g_allocation_row.misc3_val_opt1);
  else
    return null;
  end if;

  elsif instr(p_attribute_name, 'Opt2') > 0 then
    if p_attribute_name = 'EligSalValOpt2' then
    return to_char(g_allocation_row.elig_sal_val_opt2);
  elsif p_attribute_name = 'PctOfEligSalOpt2' then
    return to_char(g_allocation_row.ws_val_opt2*100/g_allocation_row.elig_sal_val_opt2);
  elsif p_attribute_name = 'WsValOpt2' then
    return to_char(g_allocation_row.ws_val_opt2);
  elsif p_attribute_name = 'WsMnValOpt2' then
    return to_char(g_allocation_row.ws_mn_val_opt2);
  elsif p_attribute_name = 'WsMxValOpt2' then
    return to_char(g_allocation_row.ws_mx_val_opt2);
  elsif p_attribute_name = 'WsIncrValOpt2' then
    return to_char(g_allocation_row.ws_incr_val_opt2);
  elsif p_attribute_name = 'StatSalValOpt2' then
    return to_char(g_allocation_row.stat_sal_val_opt2);
  elsif p_attribute_name = 'TotCompValOpt2' then
    return to_char(g_allocation_row.tot_comp_val_opt2);
  elsif p_attribute_name = 'OthCompValOpt2' then
    return to_char(g_allocation_row.oth_comp_val_opt2);
  elsif p_attribute_name = 'RecValOpt2' then
    return to_char(g_allocation_row.rec_val_opt2);
  elsif p_attribute_name = 'RecMnValOpt2' then
    return to_char(g_allocation_row.rec_mn_val_opt2);
  elsif p_attribute_name = 'RecMxValOpt2' then
    return to_char(g_allocation_row.rec_mx_val_opt2);
  elsif p_attribute_name = 'Misc1ValOpt2' then
    return to_char(g_allocation_row.misc1_val_opt2);
  elsif p_attribute_name = 'Misc2ValOpt2' then
    return to_char(g_allocation_row.misc2_val_opt2);
  elsif p_attribute_name = 'Misc3ValOpt2' then
    return to_char(g_allocation_row.misc3_val_opt2);
  else
    return null;
  end if;


  elsif instr(p_attribute_name, 'Opt3') > 0 then
  if p_attribute_name = 'EligSalValOpt3' then
    return to_char(g_allocation_row.elig_sal_val_opt3);
  elsif p_attribute_name = 'PctOfEligSalOpt3' then
    return to_char(g_allocation_row.ws_val_opt3*100/g_allocation_row.elig_sal_val_opt3);
  elsif p_attribute_name = 'WsValOpt3' then
    return to_char(g_allocation_row.ws_val_opt3);
  elsif p_attribute_name = 'WsMnValOpt3' then
    return to_char(g_allocation_row.ws_mn_val_opt3);
  elsif p_attribute_name = 'WsMxValOpt3' then
    return to_char(g_allocation_row.ws_mx_val_opt3);
  elsif p_attribute_name = 'WsIncrValOpt3' then
    return to_char(g_allocation_row.ws_incr_val_opt3);
  elsif p_attribute_name = 'StatSalValOpt3' then
    return to_char(g_allocation_row.stat_sal_val_opt3);
  elsif p_attribute_name = 'TotCompValOpt3' then
    return to_char(g_allocation_row.tot_comp_val_opt3);
  elsif p_attribute_name = 'OthCompValOpt3' then
    return to_char(g_allocation_row.oth_comp_val_opt3);
  elsif p_attribute_name = 'RecValOpt3' then
    return to_char(g_allocation_row.rec_val_opt3);
  elsif p_attribute_name = 'RecMnValOpt3' then
    return to_char(g_allocation_row.rec_mn_val_opt3);
  elsif p_attribute_name = 'RecMxValOpt3' then
    return to_char(g_allocation_row.rec_mx_val_opt3);
  elsif p_attribute_name = 'Misc1ValOpt3' then
    return to_char(g_allocation_row.misc1_val_opt3);
  elsif p_attribute_name = 'Misc2ValOpt3' then
    return to_char(g_allocation_row.misc2_val_opt3);
  elsif p_attribute_name = 'Misc3ValOpt3' then
    return to_char(g_allocation_row.misc3_val_opt3);
  else
    return null;
  end if;


  elsif instr(p_attribute_name, 'Opt4') > 0 then
    if p_attribute_name = 'EligSalValOpt4' then
    return to_char(g_allocation_row.elig_sal_val_opt4);
  elsif p_attribute_name = 'PctOfEligSalOpt4' then
    return to_char(g_allocation_row.ws_val_opt4*100/g_allocation_row.elig_sal_val_opt4);
  elsif p_attribute_name = 'WsValOpt4' then
    return to_char(g_allocation_row.ws_val_opt4);
  elsif p_attribute_name = 'WsMnValOpt4' then
    return to_char(g_allocation_row.ws_mn_val_opt4);
  elsif p_attribute_name = 'WsMxValOpt4' then
    return to_char(g_allocation_row.ws_mx_val_opt4);
  elsif p_attribute_name = 'WsIncrValOpt4' then
    return to_char(g_allocation_row.ws_incr_val_opt4);
  elsif p_attribute_name = 'StatSalValOpt4' then
    return to_char(g_allocation_row.stat_sal_val_opt4);
  elsif p_attribute_name = 'TotCompValOpt4' then
    return to_char(g_allocation_row.tot_comp_val_opt4);
  elsif p_attribute_name = 'OthCompValOpt4' then
    return to_char(g_allocation_row.oth_comp_val_opt4);
  elsif p_attribute_name = 'RecValOpt4' then
    return to_char(g_allocation_row.rec_val_opt4);
  elsif p_attribute_name = 'RecMnValOpt4' then
    return to_char(g_allocation_row.rec_mn_val_opt4);
  elsif p_attribute_name = 'RecMxValOpt4' then
    return to_char(g_allocation_row.rec_mx_val_opt4);
  elsif p_attribute_name = 'Misc1ValOpt4' then
    return to_char(g_allocation_row.misc1_val_opt4);
  elsif p_attribute_name = 'Misc2ValOpt4' then
    return to_char(g_allocation_row.misc2_val_opt4);
  elsif p_attribute_name = 'Misc3ValOpt4' then
    return to_char(g_allocation_row.misc3_val_opt4);
  else
    return null;
  end if;


  elsif instr(p_attribute_name, 'AssAttribute') > 0 then
    if p_attribute_name = 'AssAttribute1' then
      return g_allocation_row.ass_attribute1;
    elsif p_attribute_name = 'AssAttribute2' then
      return g_allocation_row.ass_attribute2;
    elsif p_attribute_name = 'AssAttribute3' then
      return g_allocation_row.ass_attribute3;
    elsif p_attribute_name = 'AssAttribute4' then
      return g_allocation_row.ass_attribute4;
    elsif p_attribute_name = 'AssAttribute5' then
      return g_allocation_row.ass_attribute5;
    elsif p_attribute_name = 'AssAttribute6' then
      return g_allocation_row.ass_attribute6;
    elsif p_attribute_name = 'AssAttribute7' then
      return g_allocation_row.ass_attribute7;
    elsif p_attribute_name = 'AssAttribute8' then
     return g_allocation_row.ass_attribute8;
    elsif p_attribute_name = 'AssAttribute9' then
      return g_allocation_row.ass_attribute9;
    elsif p_attribute_name = 'AssAttribute10' then
      return g_allocation_row.ass_attribute10;
    elsif p_attribute_name = 'AssAttribute11' then
      return g_allocation_row.ass_attribute11;
    elsif p_attribute_name = 'AssAttribute12' then
      return g_allocation_row.ass_attribute12;
    elsif p_attribute_name = 'AssAttribute13' then
      return g_allocation_row.ass_attribute13;
    elsif p_attribute_name = 'AssAttribute14' then
      return g_allocation_row.ass_attribute14;
    elsif p_attribute_name = 'AssAttribute15' then
      return g_allocation_row.ass_attribute15;
    elsif p_attribute_name = 'AssAttribute16' then
      return g_allocation_row.ass_attribute16;
    elsif p_attribute_name = 'AssAttribute17' then
      return g_allocation_row.ass_attribute17;
    elsif p_attribute_name = 'AssAttribute18' then
     return g_allocation_row.ass_attribute18;
    elsif p_attribute_name = 'AssAttribute19' then
      return g_allocation_row.ass_attribute19;
    elsif p_attribute_name = 'AssAttribute20' then
      return g_allocation_row.ass_attribute20;
    elsif p_attribute_name = 'AssAttribute21' then
      return g_allocation_row.ass_attribute21;
    elsif p_attribute_name = 'AssAttribute22' then
      return g_allocation_row.ass_attribute22;
    elsif p_attribute_name = 'AssAttribute23' then
      return g_allocation_row.ass_attribute23;
    elsif p_attribute_name = 'AssAttribute24' then
      return g_allocation_row.ass_attribute24;
    elsif p_attribute_name = 'AssAttribute25' then
      return g_allocation_row.ass_attribute25;
    elsif p_attribute_name = 'AssAttribute26' then
      return g_allocation_row.ass_attribute26;
    elsif p_attribute_name = 'AssAttribute27' then
      return g_allocation_row.ass_attribute27;
    elsif p_attribute_name = 'AssAttribute28' then
     return g_allocation_row.ass_attribute28;
    elsif p_attribute_name = 'AssAttribute29' then
      return g_allocation_row.ass_attribute29;
    elsif p_attribute_name = 'AssAttribute30' then
      return g_allocation_row.ass_attribute30;
    else
      return null;
    end if;

  elsif instr(p_attribute_name, 'CpiAttribute') > 0 then

    if p_attribute_name = 'CpiAttribute1' then
      return g_allocation_row.cpi_attribute1;
    elsif p_attribute_name = 'CpiAttribute2' then
      return g_allocation_row.cpi_attribute2;
    elsif p_attribute_name = 'CpiAttribute3' then
      return g_allocation_row.cpi_attribute3;
    elsif p_attribute_name = 'CpiAttribute4' then
      return g_allocation_row.cpi_attribute4;
    elsif p_attribute_name = 'CpiAttribute5' then
      return g_allocation_row.cpi_attribute5;
    elsif p_attribute_name = 'CpiAttribute6' then
      return g_allocation_row.cpi_attribute6;
    elsif p_attribute_name = 'CpiAttribute7' then
      return g_allocation_row.cpi_attribute7;
    elsif p_attribute_name = 'CpiAttribute8' then
     return g_allocation_row.cpi_attribute8;
    elsif p_attribute_name = 'CpiAttribute9' then
      return g_allocation_row.cpi_attribute9;
    elsif p_attribute_name = 'CpiAttribute10' then
      return g_allocation_row.cpi_attribute10;
    elsif p_attribute_name = 'CpiAttribute11' then
      return g_allocation_row.cpi_attribute11;
    elsif p_attribute_name = 'CpiAttribute12' then
      return g_allocation_row.cpi_attribute12;
    elsif p_attribute_name = 'CpiAttribute13' then
      return g_allocation_row.cpi_attribute13;
    elsif p_attribute_name = 'CpiAttribute14' then
      return g_allocation_row.cpi_attribute14;
    elsif p_attribute_name = 'CpiAttribute15' then
      return g_allocation_row.cpi_attribute15;
    elsif p_attribute_name = 'CpiAttribute16' then
      return g_allocation_row.cpi_attribute16;
    elsif p_attribute_name = 'CpiAttribute17' then
      return g_allocation_row.cpi_attribute17;
    elsif p_attribute_name = 'CpiAttribute18' then
     return g_allocation_row.cpi_attribute18;
    elsif p_attribute_name = 'CpiAttribute19' then
      return g_allocation_row.cpi_attribute19;
    elsif p_attribute_name = 'CpiAttribute20' then
      return g_allocation_row.cpi_attribute20;
    elsif p_attribute_name = 'CpiAttribute21' then
      return g_allocation_row.cpi_attribute21;
    elsif p_attribute_name = 'CpiAttribute22' then
      return g_allocation_row.cpi_attribute22;
    elsif p_attribute_name = 'CpiAttribute23' then
      return g_allocation_row.cpi_attribute23;
    elsif p_attribute_name = 'CpiAttribute24' then
      return g_allocation_row.cpi_attribute24;
    elsif p_attribute_name = 'CpiAttribute25' then
      return g_allocation_row.cpi_attribute25;
    elsif p_attribute_name = 'CpiAttribute26' then
      return g_allocation_row.cpi_attribute26;
    elsif p_attribute_name = 'CpiAttribute27' then
      return g_allocation_row.cpi_attribute27;
    elsif p_attribute_name = 'CpiAttribute28' then
     return g_allocation_row.cpi_attribute28;
    elsif p_attribute_name = 'CpiAttribute29' then
      return g_allocation_row.cpi_attribute29;
    elsif p_attribute_name = 'CpiAttribute30' then
      return g_allocation_row.cpi_attribute30;
    else
      return null;
    end if;


  elsif p_attribute_name = 'EligSalVal' then
    return to_char(g_allocation_row.elig_sal_val);
  elsif p_attribute_name = 'PctOfEligSal' then
    return to_char(g_allocation_row.ws_val*100/g_allocation_row.elig_sal_val);
  elsif p_attribute_name = 'WsVal' then
    return to_char(g_allocation_row.ws_val);
  elsif p_attribute_name = 'WsMnVal' then
    return to_char(g_allocation_row.ws_mn_val);
  elsif p_attribute_name = 'WsMxVal' then
    return to_char(g_allocation_row.ws_mx_val);
  elsif p_attribute_name = 'WsIncrVal' then
    return to_char(g_allocation_row.ws_incr_val);
  elsif p_attribute_name = 'StatSalVal' then
    return to_char(g_allocation_row.stat_sal_val);
  elsif p_attribute_name = 'TotCompVal' then
    return to_char(g_allocation_row.tot_comp_val);
  elsif p_attribute_name = 'OthCompVal' then
    return to_char(g_allocation_row.oth_comp_val);
  elsif p_attribute_name = 'RecVal' then
    return to_char(g_allocation_row.rec_val);
  elsif p_attribute_name = 'RecMnVal' then
    return to_char(g_allocation_row.rec_mn_val);
  elsif p_attribute_name = 'RecMxVal' then
    return to_char(g_allocation_row.rec_mx_val);
  elsif p_attribute_name = 'Misc1Val' then
    return to_char(g_allocation_row.misc1_val);
  elsif p_attribute_name = 'Misc2Val' then
    return to_char(g_allocation_row.misc2_val);
  elsif p_attribute_name = 'Misc3Val' then
    return to_char(g_allocation_row.misc3_val);
  elsif p_attribute_name = 'BaseSalary' then
    return to_char(g_allocation_row.base_salary);
  elsif p_attribute_name = 'NewSalary' then
    return to_char(get_new_salary);
  elsif p_attribute_name = 'EmailAddress' then
    return g_allocation_row.email_address;
  elsif p_attribute_name = 'EmpCategory' then
    return g_allocation_row.emp_category;
  elsif p_attribute_name = 'EmpName' then
    return g_allocation_row.full_name;
  elsif p_attribute_name = 'EmployeeNumber' then
    return g_allocation_row.employee_number;
  elsif p_attribute_name = 'AssignmentStatusTypeId' then
    return to_char(g_allocation_row.assignment_status_type_id);
  elsif p_attribute_name = 'BusinessGroupId' then
    return to_char(g_allocation_row.business_group_id);
  elsif p_attribute_name = 'GrdComparatio' then
    return to_char(g_allocation_row.grd_comparatio);
  elsif p_attribute_name = 'GradeId' then
    return to_char(g_allocation_row.grade_id);
  elsif p_attribute_name = 'GrdMinVal' then
    return to_char(g_allocation_row.grd_min_val);
  elsif p_attribute_name = 'GrdMaxVal' then
    return to_char(g_allocation_row.grd_max_val);
  elsif p_attribute_name = 'GrdMidPoint' then
    return to_char(g_allocation_row.grd_mid_point);
  elsif p_attribute_name = 'GrdQuartile' then
    return g_allocation_row.grd_quartile;
  elsif p_attribute_name = 'JobId' then
    return to_char(g_allocation_row.job_id);
  elsif p_attribute_name = 'LegislationCode' then
    return g_allocation_row.legislation_code;
  elsif p_attribute_name = 'LocationId' then
    return to_char(g_allocation_row.location_id);
  elsif p_attribute_name = 'MgrName' then
    return g_allocation_row.supervisor_full_name;
  elsif p_attribute_name = 'NewChangeReason' then
    return g_allocation_row.new_change_reason;
  elsif p_attribute_name = 'NewGrdComparatio' then
    return to_char(get_new_grd_comparatio);
  elsif p_attribute_name = 'NewGradeId' then
    return g_allocation_row.new_grade_id;
  elsif p_attribute_name = 'NewJobId' then
    return g_allocation_row.new_job_id;
  elsif p_attribute_name = 'NewPositionId' then
    return g_allocation_row.new_position_id;
  elsif p_attribute_name = 'NewPerfRating' then
    return g_allocation_row.new_perf_rating;
  elsif p_attribute_name = 'NewGrdMinVal' then
    return to_char(get_new_grd_min_val);
  elsif p_attribute_name = 'NewGrdMidPoint' then
    return to_char(get_new_grd_mid_point);
  elsif p_attribute_name = 'NewGrdMaxVal' then
    return to_char(get_new_grd_max_val);
  elsif p_attribute_name = 'NewGrdQuartile' then
    return get_new_grd_quartile;
  elsif p_attribute_name = 'NormalHours' then
    return to_char(g_allocation_row.normal_hours);
  elsif p_attribute_name = 'OrganizationId' then
    return to_char(g_allocation_row.organization_id);
  elsif p_attribute_name = 'OriginalStartDate' then
    return to_char(g_allocation_row.original_start_date, 'yyyy/mm/dd');
  elsif p_attribute_name = 'PeopleGroupId' then
    return to_char(g_allocation_row.people_group_id);
  elsif p_attribute_name = 'PositionId' then
    return to_char(g_allocation_row.position_id);
  elsif p_attribute_name = 'PlId' then
    return to_char(g_allocation_row.pl_id);
  elsif p_attribute_name = 'PayrollName' then
    return g_allocation_row.payroll_name;
  elsif p_attribute_name = 'PerformanceRating' then
    return g_allocation_row.performance_rating;
  elsif p_attribute_name = 'PerformanceRatingDate' then
    return to_char(g_allocation_row.performance_rating_date, 'yyyy/mm/dd');
  elsif p_attribute_name = 'PerformanceRatingType' then
    return g_allocation_row.performance_rating_type;
  elsif p_attribute_name = 'StartDate' then
    return to_char(g_allocation_row.start_date, 'yyyy/mm/dd');
  elsif p_attribute_name = 'YearsEmployed' then
    return to_char(g_allocation_row.years_employed);
  elsif p_attribute_name =  'YearsInJob' then
    return to_char(g_allocation_row.years_in_job);
  elsif p_attribute_name = 'YearsInGrade' then
    return to_char(g_allocation_row.years_in_grade);
  elsif p_attribute_name = 'YearsInPosition' then
    return to_char(g_allocation_row.years_in_position);
  else
    return null;
  end if;
   --
exception
  when others then
    return null;
end get_attribute;

procedure set_attribute(p_attribute_name      in varchar2
                       ,p_value               in varchar2) is
begin
  if instr(p_attribute_name, 'CustomSegment') > 0 then
    g_upd_person_info := true;
  if p_attribute_name = 'CustomSegment1' then
    g_allocation_row.custom_segment1 := p_value;
  elsif p_attribute_name = 'CustomSegment2' then
    g_allocation_row.custom_segment2 := p_value;
  elsif p_attribute_name = 'CustomSegment3' then
    g_allocation_row.custom_segment3 := p_value;
  elsif p_attribute_name = 'CustomSegment4' then
    g_allocation_row.custom_segment4 := p_value;
  elsif p_attribute_name = 'CustomSegment5' then
    g_allocation_row.custom_segment5 := p_value;
  elsif p_attribute_name = 'CustomSegment6' then
    g_allocation_row.custom_segment6 := p_value;
  elsif p_attribute_name = 'CustomSegment7' then
    g_allocation_row.custom_segment7 := p_value;
  elsif p_attribute_name = 'CustomSegment8' then
    g_allocation_row.custom_segment8 := p_value;
  elsif p_attribute_name = 'CustomSegment9' then
    g_allocation_row.custom_segment9 := p_value;
  elsif p_attribute_name = 'CustomSegment10' then
    g_allocation_row.custom_segment10 := p_value;
  elsif p_attribute_name = 'CustomSegment11' then
    g_allocation_row.custom_segment11 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment12' then
    g_allocation_row.custom_segment12 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment13' then
    g_allocation_row.custom_segment13 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment14' then
    g_allocation_row.custom_segment14 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment15' then
    g_allocation_row.custom_segment15 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment16' then
    g_allocation_row.custom_segment16 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment17' then
    g_allocation_row.custom_segment17 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment18' then
    g_allocation_row.custom_segment18 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment19' then
    g_allocation_row.custom_segment19 := to_number(p_value);
  elsif p_attribute_name = 'CustomSegment20' then
    g_allocation_row.custom_segment20 := to_number(p_value);
  end if;
  elsif instr(p_attribute_name, 'CpiAttribute') > 0 then
    g_upd_person_info := true;
    if p_attribute_name = 'CpiAttribute1' then
      g_allocation_row.cpi_attribute1 := p_value;
    elsif p_attribute_name = 'CpiAttribute2' then
      g_allocation_row.cpi_attribute2 := p_value;
    elsif p_attribute_name = 'CpiAttribute3' then
      g_allocation_row.cpi_attribute3 := p_value;
    elsif p_attribute_name = 'CpiAttribute4' then
      g_allocation_row.cpi_attribute4 := p_value;
    elsif p_attribute_name = 'CpiAttribute5' then
      g_allocation_row.cpi_attribute5 := p_value;
    elsif p_attribute_name = 'CpiAttribute6' then
      g_allocation_row.cpi_attribute6 := p_value;
    elsif p_attribute_name = 'CpiAttribute7' then
      g_allocation_row.cpi_attribute7 := p_value;
    elsif p_attribute_name = 'CpiAttribute8' then
     g_allocation_row.cpi_attribute8 := p_value;
    elsif p_attribute_name = 'CpiAttribute9' then
      g_allocation_row.cpi_attribute9 := p_value;
    elsif p_attribute_name = 'CpiAttribute10' then
      g_allocation_row.cpi_attribute10 := p_value;
    elsif p_attribute_name = 'CpiAttribute11' then
      g_allocation_row.cpi_attribute11 := p_value;
    elsif p_attribute_name = 'CpiAttribute12' then
      g_allocation_row.cpi_attribute12 := p_value;
    elsif p_attribute_name = 'CpiAttribute13' then
      g_allocation_row.cpi_attribute13 := p_value;
    elsif p_attribute_name = 'CpiAttribute14' then
      g_allocation_row.cpi_attribute14 := p_value;
    elsif p_attribute_name = 'CpiAttribute15' then
      g_allocation_row.cpi_attribute15 := p_value;
    elsif p_attribute_name = 'CpiAttribute16' then
      g_allocation_row.cpi_attribute16 := p_value;
    elsif p_attribute_name = 'CpiAttribute17' then
      g_allocation_row.cpi_attribute17 := p_value;
    elsif p_attribute_name = 'CpiAttribute18' then
     g_allocation_row.cpi_attribute18 := p_value;
    elsif p_attribute_name = 'CpiAttribute19' then
      g_allocation_row.cpi_attribute19 := p_value;
    elsif p_attribute_name = 'CpiAttribute20' then
      g_allocation_row.cpi_attribute20 := p_value;
    elsif p_attribute_name = 'CpiAttribute21' then
      g_allocation_row.cpi_attribute21 := p_value;
    elsif p_attribute_name = 'CpiAttribute22' then
      g_allocation_row.cpi_attribute22 := p_value;
    elsif p_attribute_name = 'CpiAttribute23' then
      g_allocation_row.cpi_attribute23 := p_value;
    elsif p_attribute_name = 'CpiAttribute24' then
      g_allocation_row.cpi_attribute24 := p_value;
    elsif p_attribute_name = 'CpiAttribute25' then
      g_allocation_row.cpi_attribute25 := p_value;
    elsif p_attribute_name = 'CpiAttribute26' then
      g_allocation_row.cpi_attribute26 := p_value;
    elsif p_attribute_name = 'CpiAttribute27' then
      g_allocation_row.cpi_attribute27 := p_value;
    elsif p_attribute_name = 'CpiAttribute28' then
     g_allocation_row.cpi_attribute28 := p_value;
    elsif p_attribute_name = 'CpiAttribute29' then
      g_allocation_row.cpi_attribute29 := p_value;
    elsif p_attribute_name = 'CpiAttribute30' then
      g_allocation_row.cpi_attribute30 := p_value;
    end if;
  elsif ((instr(p_attribute_name, 'Opt1') > 0) and g_allocation_row.oipl_id_opt1 IS NOT NULL) then
    g_upd_opt1_rate := true;
    if p_attribute_name = 'WsValOpt1' then
      g_allocation_row.new_salary := null;
      if g_allocation_row.ws_abr_id is not null then
        g_upd_pl_rate := true;
        g_allocation_row.ws_val:=
           ben_cwb_utils.add_number_with_null_check(
            g_allocation_row.ws_val,ben_cwb_utils.add_number_with_null_check
                          (to_number(p_value),-g_allocation_row.ws_val_opt1));
      end if;
      g_allocation_row.ws_val_opt1:= to_number(p_value);
    elsif p_attribute_name = 'StatSalValOpt1' then
      g_allocation_row.stat_sal_val_opt1:= to_number(p_value);
    elsif p_attribute_name = 'TotCompValOpt1' then
      g_allocation_row.tot_comp_val_opt1:= to_number(p_value);
    elsif p_attribute_name = 'OthCompValOpt1' then
      g_allocation_row.oth_comp_val_opt1:= to_number(p_value);
    elsif p_attribute_name = 'RecValOpt1' then
      g_allocation_row.rec_val_opt1:= to_number(p_value);
    elsif p_attribute_name = 'Misc1ValOpt1' then
      g_allocation_row.misc1_val_opt1:= to_number(p_value);
    elsif p_attribute_name = 'Misc2ValOpt1' then
      g_allocation_row.misc2_val_opt1:= to_number(p_value);
    elsif p_attribute_name = 'Misc3ValOpt1' then
      g_allocation_row.misc3_val_opt1:= to_number(p_value);
    end if;
  elsif ((instr(p_attribute_name, 'Opt2') > 0) and g_allocation_row.oipl_id_opt2 IS NOT NULL) then
    g_upd_opt2_rate := true;
    if p_attribute_name = 'WsValOpt2' then
      g_allocation_row.new_salary := null;
      if g_allocation_row.ws_abr_id is not null then
        g_upd_pl_rate := true;
        g_allocation_row.ws_val:=
           ben_cwb_utils.add_number_with_null_check(
            g_allocation_row.ws_val,ben_cwb_utils.add_number_with_null_check
                          (to_number(p_value),-g_allocation_row.ws_val_opt2));
      end if;
      g_allocation_row.ws_val_opt2:= to_number(p_value);
    elsif p_attribute_name = 'StatSalValOpt2' then
      g_allocation_row.stat_sal_val_opt2:= to_number(p_value);
    elsif p_attribute_name = 'TotCompValOpt2' then
      g_allocation_row.tot_comp_val_opt2:= to_number(p_value);
    elsif p_attribute_name = 'OthCompValOpt2' then
      g_allocation_row.oth_comp_val_opt2:= to_number(p_value);
    elsif p_attribute_name = 'RecValOpt2' then
      g_allocation_row.rec_val_opt2:= to_number(p_value);
    elsif p_attribute_name = 'Misc1ValOpt2' then
      g_allocation_row.misc1_val_opt2:= to_number(p_value);
    elsif p_attribute_name = 'Misc2ValOpt2' then
      g_allocation_row.misc2_val_opt2:= to_number(p_value);
    elsif p_attribute_name = 'Misc3ValOpt2' then
      g_allocation_row.misc3_val_opt2:= to_number(p_value);
    end if;
  elsif ((instr(p_attribute_name, 'Opt3') > 0) and g_allocation_row.oipl_id_opt3 IS NOT NULL) then
    g_upd_opt3_rate := true;
    if p_attribute_name = 'WsValOpt3' then
      g_allocation_row.new_salary := null;
      if g_allocation_row.ws_abr_id is not null then
        g_upd_pl_rate := true;
        g_allocation_row.ws_val:=
           ben_cwb_utils.add_number_with_null_check(
            g_allocation_row.ws_val,ben_cwb_utils.add_number_with_null_check
                          (to_number(p_value),-g_allocation_row.ws_val_opt3));
      end if;
      g_allocation_row.ws_val_opt3:= to_number(p_value);
    elsif p_attribute_name = 'StatSalValOpt3' then
      g_allocation_row.stat_sal_val_opt3:= to_number(p_value);
    elsif p_attribute_name = 'TotCompValOpt3' then
      g_allocation_row.tot_comp_val_opt3:= to_number(p_value);
    elsif p_attribute_name = 'OthCompValOpt3' then
      g_allocation_row.oth_comp_val_opt3:= to_number(p_value);
    elsif p_attribute_name = 'RecValOpt3' then
      g_allocation_row.rec_val_opt3:= to_number(p_value);
    elsif p_attribute_name = 'Misc1ValOpt3' then
      g_allocation_row.misc1_val_opt3:= to_number(p_value);
    elsif p_attribute_name = 'Misc2ValOpt3' then
      g_allocation_row.misc2_val_opt3:= to_number(p_value);
    elsif p_attribute_name = 'Misc3ValOpt3' then
      g_allocation_row.misc3_val_opt3:= to_number(p_value);
    end if;
  elsif ((instr(p_attribute_name, 'Opt4') > 0) and g_allocation_row.oipl_id_opt4 IS NOT NULL) then
    g_upd_opt4_rate := true;
    if p_attribute_name = 'WsValOpt4' then
      g_allocation_row.new_salary := null;
      if g_allocation_row.ws_abr_id is not null then
        g_upd_pl_rate := true;
        g_allocation_row.ws_val:=
           ben_cwb_utils.add_number_with_null_check(
            g_allocation_row.ws_val,ben_cwb_utils.add_number_with_null_check
                          (to_number(p_value),-g_allocation_row.ws_val_opt4));
      end if;
      g_allocation_row.ws_val_opt4:= to_number(p_value);
    elsif p_attribute_name = 'StatSalValOpt4' then
      g_allocation_row.stat_sal_val_opt4:= to_number(p_value);
    elsif p_attribute_name = 'TotCompValOpt4' then
      g_allocation_row.tot_comp_val_opt4:= to_number(p_value);
    elsif p_attribute_name = 'OthCompValOpt4' then
      g_allocation_row.oth_comp_val_opt4:= to_number(p_value);
    elsif p_attribute_name = 'RecValOpt4' then
      g_allocation_row.rec_val_opt4:= to_number(p_value);
    elsif p_attribute_name = 'Misc1ValOpt4' then
      g_allocation_row.misc1_val_opt4:= to_number(p_value);
    elsif p_attribute_name = 'Misc2ValOpt4' then
      g_allocation_row.misc2_val_opt4:= to_number(p_value);
    elsif p_attribute_name = 'Misc3ValOpt4' then
      g_allocation_row.misc3_val_opt4:= to_number(p_value);
    end if;
  elsif p_attribute_name = 'WsVal' then
    g_allocation_row.new_salary := null;
    g_upd_pl_rate := true;
    g_allocation_row.ws_val:= to_number(p_value);
  elsif p_attribute_name = 'StatSalVal' then
    g_upd_pl_rate := true;
    g_allocation_row.stat_sal_val:= to_number(p_value);
  elsif p_attribute_name = 'TotCompVal' then
    g_upd_pl_rate := true;
    g_allocation_row.tot_comp_val:= to_number(p_value);
  elsif p_attribute_name = 'OthCompVal' then
    g_upd_pl_rate := true;
    g_allocation_row.oth_comp_val:= to_number(p_value);
  elsif p_attribute_name = 'RecVal' then
    g_upd_pl_rate := true;
    g_allocation_row.rec_val:= to_number(p_value);
  elsif p_attribute_name = 'Misc1Val' then
    g_upd_pl_rate := true;
    g_allocation_row.misc1_val:= to_number(p_value);
  elsif p_attribute_name = 'Misc2Val' then
    g_upd_pl_rate := true;
    g_allocation_row.misc2_val:= to_number(p_value);
  elsif p_attribute_name = 'Misc3Val' then
    g_upd_pl_rate := true;
    g_allocation_row.misc3_val:= to_number(p_value);
  end if;
end set_attribute;

function add_number(p_value1 in varchar2,
                    p_value2 in varchar2)
return varchar2 is
begin
  return to_char(nvl(to_number(p_value1),0) + nvl(to_number(p_value2),0));
end add_number;


function sub_number(p_value1 in varchar2,
                    p_value2 in varchar2)
return varchar2 is
begin
  return to_char(nvl(to_number(p_value1),0) - nvl(to_number(p_value2),0));
end sub_number;

function mul_number(p_value1 in varchar2,
                    p_value2 in varchar2)
return varchar2 is
begin
  return to_char(nvl(to_number(p_value1),0) * nvl(to_number(p_value2),0));
end mul_number;

function div_number(p_value1 in varchar2,
                    p_value2 in varchar2)
return varchar2 is
begin
  if (p_value2 is null or to_number(p_value2) = 0) then
    return null;
  else
    return to_char(nvl(to_number(p_value1),0)/nvl(to_number(p_value2),0));
  end if;
end div_number;


function round_number(p_value in varchar2,
                      p_rndg_cd in varchar2)
return varchar2 is
begin
  return to_char(benutils.do_rounding(p_rounding_cd  => p_rndg_cd,
                              p_rounding_rl  => null,
                              p_assignment_id => null,
                              p_value         => to_number(p_value),
                              p_effective_date => null));
end round_number;

function my_nvl2(p_value in varchar2,
                 p_null_value in varchar2,
                 p_not_null_value in varchar2)
return varchar2 is
begin
  if p_value is null then
    return p_null_value;
   else
     return p_not_null_value;
   end if;
end my_nvl2;

function convert_number(p_value in varchar2,
                        p_data_type in varchar2 default CALC_NUMBER)
return varchar2 is
begin
  if p_data_type = CALC_NUMBER then
    return to_char(to_number(p_value, '9999999999999999.9999999999'));
  else
    return p_value;
  end if;
end convert_number;


function load_calc_details(p_group_pl_id in number)
return number is

  l_rslt_col varchar2(30) := null;
  l_old_rslt_col varchar2(30) := null;
  l_cond_ordr number := null;
  l_old_cond_ordr number := null;
  l_calc_type varchar2(30) := null;
  l_rndg_cd   varchar2(30) := null;
  l_cond_return_val varchar2(60) := null;
  l_cond_return_attr varchar2(30) := null;
  l_msg_type varchar2(30) := null;
  l_create_return boolean := false;
  l_oper varchar2(30) := null;
  l_logic varchar2(30) := null;
  l_count integer := 0;
begin

  if p_group_pl_id = g_group_pl_id then
    return g_calc_details.count;
  end if;

  g_calc_details.delete;

  for l_calc_row in c_calc_details(p_group_pl_id, 'CwbWsPl') loop
    l_rslt_col := l_calc_row.rslt_col;
    l_cond_ordr := l_calc_row.cond_ordr;

    if (l_old_rslt_col is null or l_rslt_col <> l_old_rslt_col) then

      if (l_rndg_cd is not null) then
        l_count := l_count + 1;
        g_calc_details(l_count).rslt_col := l_old_rslt_col;
        g_calc_details(l_count).func     := CALC_ROUND;
        g_calc_details(l_count).attribute1 := l_rndg_cd;
      end if;

      if (l_create_return) then
        l_count := l_count + 1;
        g_calc_details(l_count).rslt_col := l_old_rslt_col;
        g_calc_details(l_count).func     := CALC_RETURN;
        g_calc_details(l_count).oper     := my_nvl2(l_cond_return_val,
                                               my_nvl2(l_cond_return_attr,null,CALC_GET),
                                               CALC_FIXED);
        g_calc_details(l_count).attribute1 := my_nvl2(l_cond_return_val,
                                               my_nvl2(l_cond_return_attr,null,l_cond_return_attr),
                                               l_cond_return_val);
        g_calc_details(l_count).attribute2 := l_msg_type;
      end if;

      l_oper := null;
      l_calc_type := l_calc_row.calc_type;
      l_logic := null;
      l_create_return := false;
      l_rndg_cd := null;
      l_old_cond_ordr := null;

    end if;

    if (l_calc_type = CALC_CALCULATOR) then
      if (not l_create_return) then

        if (l_calc_row.calc_eq_ordr is not null) then
          l_create_return := true;
          l_rndg_cd := l_calc_row.rndg_cd;
          l_cond_return_val := null;
          l_cond_return_attr := null;
          l_msg_type        := null;

          l_count := l_count + 1;
          g_calc_details(l_count).rslt_col := l_rslt_col;
          g_calc_details(l_count).func     := CALC_START;
          g_calc_details(l_count).oper     := my_nvl2(l_calc_row.calc_eq_attr1, CALC_GET, CALC_FIXED);
          g_calc_details(l_count).attribute1 := my_nvl2(l_calc_row.calc_eq_attr1, l_calc_row.calc_eq_col, convert_number(l_calc_row.calc_eq_attr1));
          g_calc_details(l_count).attribute1_type := CALC_NUMBER;
        end if;
      else
        l_count := l_count + 1;
        g_calc_details(l_count).rslt_col := l_rslt_col;
        g_calc_details(l_count).func     := l_oper;
        g_calc_details(l_count).oper     := my_nvl2(l_calc_row.calc_eq_attr1, CALC_GET, CALC_FIXED);
        g_calc_details(l_count).attribute1 := my_nvl2(l_calc_row.calc_eq_attr1, l_calc_row.calc_eq_col, convert_number(l_calc_row.calc_eq_attr1));
        g_calc_details(l_count).attribute1_type := CALC_NUMBER;
      end if;

      l_oper := l_calc_row.calc_eq_oper;

    else
      if (l_create_return and l_old_cond_ordr is not null and l_old_cond_ordr <> l_cond_ordr) then
        l_count := l_count + 1;
        g_calc_details(l_count).rslt_col := l_rslt_col;
        g_calc_details(l_count).func     := CALC_RETURN;
        g_calc_details(l_count).oper     := my_nvl2(l_cond_return_val,
                                               my_nvl2(l_cond_return_attr,null,CALC_GET),
                                               CALC_FIXED);
        g_calc_details(l_count).attribute1 := my_nvl2(l_cond_return_val,
                                               my_nvl2(l_cond_return_attr,null,l_cond_return_attr),
                                               l_cond_return_val);
        g_calc_details(l_count).attribute2 := l_msg_type;
        l_create_return := false;
      end if;

      if (not l_create_return) then
        l_cond_return_val := l_calc_row.cond_val;
        l_cond_return_attr := l_calc_row.cond_col;
        l_msg_type := l_calc_row.cond_msg_type;
        l_create_return := true;

        l_count := l_count + 1;
        g_calc_details(l_count).rslt_col := l_rslt_col;
        g_calc_details(l_count).func     := CALC_START;
        g_calc_details(l_count).oper     := CALC_GET;
        g_calc_details(l_count).attribute1 := l_calc_row.cond_eq_col;
        g_calc_details(l_count).attribute1_type := l_calc_row.cond_eq_data_type;
      else
        l_count := l_count + 1;
        g_calc_details(l_count).rslt_col := l_rslt_col;
        g_calc_details(l_count).func     := l_logic;
        g_calc_details(l_count).oper     := CALC_GET;
        g_calc_details(l_count).attribute1 := l_calc_row.cond_eq_col;
        g_calc_details(l_count).attribute1_type := l_calc_row.cond_eq_data_type;
      end if;

      if l_calc_row.cond_eq_oper is not null then
        l_count := l_count + 1;
        g_calc_details(l_count).rslt_col := l_rslt_col;
        g_calc_details(l_count).func     := CALC_EVAL;
        g_calc_details(l_count).oper     := l_calc_row.cond_eq_oper;
        g_calc_details(l_count).attribute1 := my_nvl2(l_calc_row.cond_eq_attr1,
                                               l_calc_row.cond_eq_col1,
                                               convert_number(l_calc_row.cond_eq_attr1,l_calc_row.cond_eq_data_type));
        g_calc_details(l_count).attribute2 := my_nvl2(l_calc_row.cond_eq_attr2,
                                               l_calc_row.cond_eq_col2,
                                             convert_number(l_calc_row.cond_eq_attr2,l_calc_row.cond_eq_data_type));
        g_calc_details(l_count).attribute1_type := l_calc_row.cond_eq_data_type;
        g_calc_details(l_count).attribute2_type := l_calc_row.cond_eq_data_type;
        g_calc_details(l_count).attribute1_oper := my_nvl2(l_calc_row.cond_eq_attr1,CALC_GET,CALC_FIXED);
        g_calc_details(l_count).attribute2_oper := my_nvl2(l_calc_row.cond_eq_attr2,CALC_GET,CALC_FIXED);
      end if;

      l_logic := l_calc_row.cond_eq_log;

    end if;

    l_old_rslt_col := l_rslt_col;
    l_old_cond_ordr := l_cond_ordr;


  end loop;

  if (l_rndg_cd is not null) then
    l_count := l_count + 1;
    g_calc_details(l_count).rslt_col := l_old_rslt_col;
    g_calc_details(l_count).func     := CALC_ROUND;
    g_calc_details(l_count).attribute1 := l_rndg_cd;
  end if;

  if (l_create_return) then
    l_count := l_count + 1;
    g_calc_details(l_count).rslt_col := l_old_rslt_col;
    g_calc_details(l_count).func     := CALC_RETURN;
    g_calc_details(l_count).oper     := my_nvl2(l_cond_return_val,
                                         my_nvl2(l_cond_return_attr,null,CALC_GET),
                                         CALC_FIXED);
    g_calc_details(l_count).attribute1 := my_nvl2(l_cond_return_val,
                                            my_nvl2(l_cond_return_attr,null,l_cond_return_attr),
                                            l_cond_return_val);
    g_calc_details(l_count).attribute2 := l_msg_type;
  end if;

  g_group_pl_id := p_group_pl_id;

  return l_count;
end load_calc_details;

function get_attribute1(p_calc_detail_row in t_calc_details)
return varchar2 is
begin
  if p_calc_detail_row.attribute1_oper = CALC_GET then
    return get_attribute(p_calc_detail_row.attribute1);
  else
    return p_calc_detail_row.attribute1;
  end if;
end get_attribute1;

function get_attribute2(p_calc_detail_row in t_calc_details)
return varchar2 is
begin
  if p_calc_detail_row.attribute2_oper = CALC_GET then
    return get_attribute(p_calc_detail_row.attribute2);
  else
    return p_calc_detail_row.attribute2;
  end if;
end get_attribute2;

function eval_condition(p_value in varchar2,
                        p_calc_detail_row in t_calc_details)
return boolean is
  l_oper varchar2(30) := p_calc_detail_row.oper;
begin
  if l_oper = CALC_NULL then
    return (p_value is null);
  elsif l_oper = CALC_NOTNULL then
    return (p_value is not null);
  elsif l_oper = CALC_MATCH then
    return (p_value = get_attribute1(p_calc_detail_row));
  elsif l_oper = CALC_STARTS then
    return (instr(p_value,get_attribute1(p_calc_detail_row)) = length(p_value));
  elsif l_oper = CALC_ENDS then
    return (instr(p_value,get_attribute1(p_calc_detail_row), -1)
               = length(p_value)-length(get_attribute1(p_calc_detail_row))+1 );
  elsif l_oper = CALC_CONTAINS then
    return (instr(p_value,get_attribute1(p_calc_detail_row))>0);
  elsif l_oper = CALC_GREATER then
    if p_calc_detail_row.attribute1_type = CALC_NUMBER then
      return (to_number(p_value) > to_number(get_attribute1(p_calc_detail_row)));
    else
      return (p_value > get_attribute1(p_calc_detail_row));
    end if;
  elsif l_oper = CALC_LESS then
    if p_calc_detail_row.attribute1_type = CALC_NUMBER then
      return (to_number(p_value) < to_number(get_attribute1(p_calc_detail_row)));
    else
      return (p_value < get_attribute1(p_calc_detail_row));
    end if;
  elsif l_oper = CALC_EQGREATER then
    if p_calc_detail_row.attribute1_type = CALC_NUMBER then
      return (to_number(p_value) >= to_number(get_attribute1(p_calc_detail_row)));
    else
      return (p_value >= get_attribute1(p_calc_detail_row));
    end if;
  elsif l_oper = CALC_EQLESS then
    if p_calc_detail_row.attribute1_type = CALC_NUMBER then
      return (to_number(p_value) <= to_number(get_attribute1(p_calc_detail_row)));
    else
      return (p_value <= get_attribute1(p_calc_detail_row));
    end if;
  elsif l_oper = CALC_BETWEEN then
    if p_calc_detail_row.attribute1_type = CALC_NUMBER then
      return (to_number(p_value)  between
              to_number(get_attribute1(p_calc_detail_row)) and
              to_number(get_attribute2(p_calc_detail_row)));
    else
      return (p_value between
              get_attribute1(p_calc_detail_row) and
              get_attribute2(p_calc_detail_row));
    end if;
  end if;

end eval_condition;

function return_value(p_value in varchar2,
                      p_calc_detail_row in t_calc_details)
return varchar2 is
begin
  if p_calc_detail_row.oper = CALC_GET then
    return get_attribute(p_calc_detail_row.attribute1);
  elsif p_calc_detail_row.attribute1 is not null then
    return p_calc_detail_row.attribute1;
  else
    return p_value;
  end if;
end return_value;

function get_attribute(p_calc_detail_row in t_calc_details)
return varchar2 is
begin
  if p_calc_detail_row.oper = CALC_GET then
    return get_attribute(p_calc_detail_row.attribute1);
  elsif p_calc_detail_row.oper = CALC_FIXED then
    return p_calc_detail_row.attribute1;
  else
    return null;
  end if;
end get_attribute;

procedure raise_error(p_message in varchar2) is
  l_product varchar2(30);
  l_message varchar2(60);
  l_index number;
begin
  --
  l_index := instr(p_message, ':');
  if l_index > 0 then
    l_product := substr(p_message,1,l_index-1);
    l_message := substr(p_message,l_index+1,length(p_message)-l_index);
    if l_product is not null and l_message is not null then
      fnd_message.set_name(l_product, l_message);
      fnd_message.raise_error;
    end if;
  end if;
  --
end raise_error;


procedure execute_column(p_group_per_in_ler_id in number
                        ,p_rslt_col            in varchar2
                        ,p_start_index         in integer
                        ,p_raise_error         in boolean) is
  l_char_val   varchar2(500) := null;
  l_bool_val   boolean:= true;
  l_eval_val   boolean:= true;
  l_raise_err  boolean:= false;

  l_next_alwd_func varchar2(30) := null;
  l_ret_val varchar2(400) := null;

  l_func varchar2(30);
  l_proceed boolean;

begin

  if p_start_index > 0 and g_calc_details.count > 0 then

    l_func := null;

    for i in p_start_index..g_calc_details.count loop
      if g_calc_details(i).rslt_col is null or
         g_calc_details(i).rslt_col <> p_rslt_col then
        exit;
      end if;

      l_func := g_calc_details(i).func;
      l_proceed := true;

      if (l_next_alwd_func is not null) then
        if (l_func <> l_next_alwd_func) then
          l_proceed := false;
        end if;
      end if;

      if l_proceed then
        if l_func = CALC_START then
          l_char_val := get_attribute(g_calc_details(i));
          l_bool_val := true;
          l_eval_val := true;
          l_raise_err:= false;
          l_next_alwd_func := null;
        elsif (l_func = CALC_RETURN  and l_bool_val) then
          if g_calc_details(i).attribute2 is null then
            l_ret_val := return_value(l_char_val, g_calc_details(i));
            exit;
          else
            l_raise_err := (g_calc_details(i).attribute2 = CALC_ERR);
            if l_raise_err then
              l_ret_val := g_calc_details(i).attribute1;
            else
              l_ret_val := g_calc_details(i).attribute2||':'||
                           g_calc_details(i).attribute1;
            end if;
            exit;
          end if;
        elsif (l_func = CALC_EVAL and l_eval_val) then
          l_bool_val := eval_condition(l_char_val, g_calc_details(i));
          l_eval_val := false;
        elsif l_func = CALC_ADD then
          l_char_val := add_number(l_char_val, get_attribute(g_calc_details(i)));
        elsif l_func = CALC_SUBTRACT then
          l_char_val := sub_number(l_char_val, get_attribute(g_calc_details(i)));
        elsif l_func = CALC_MULTIPLY then
          l_char_val := mul_number(l_char_val, get_attribute(g_calc_details(i)));
        elsif l_func = CALC_DIVIDE then
          l_char_val := div_number(l_char_val, get_attribute(g_calc_details(i)));
        elsif l_func = CALC_ROUND then
          l_char_val := round_number(l_char_val, g_calc_details(i).attribute1);
        elsif (l_func = CALC_AND) then
          if (not l_bool_val) then
            l_next_alwd_func := CALC_START;
            l_proceed := false;
          end if;
          if l_proceed then
            l_eval_val := true;
            l_char_val := get_attribute(g_calc_details(i));
          end if;
        elsif (l_func = CALC_OR) then
          if (l_bool_val) then
            l_next_alwd_func := CALC_RETURN;
            l_proceed := false;
          end if;
          if l_proceed then
           l_char_val := get_attribute(g_calc_details(i));
           l_eval_val := true;
          end if;

        end if; -- l_func

      end if; -- l_proceed


    end loop;

    if l_func is not null then
      --
      if l_raise_err then
        if p_raise_error then
          raise_error(l_ret_val);
        end if;
      else
        set_attribute(p_rslt_col, l_ret_val);
      end if;
    end if;

  end if;
exception
  when others then
    hr_utility.set_location('execute_column '||p_group_per_in_ler_id||p_rslt_col,99);
    raise;

end execute_column;

procedure save_data is
  l_save_summary boolean := false;
begin
  if g_upd_person_info then
  update ben_cwb_person_info
    set custom_segment1 = g_allocation_row.custom_segment1
       ,custom_segment2 = g_allocation_row.custom_segment2
       ,custom_segment3 = g_allocation_row.custom_segment3
       ,custom_segment4 = g_allocation_row.custom_segment4
       ,custom_segment5 = g_allocation_row.custom_segment5
       ,custom_segment6 = g_allocation_row.custom_segment6
       ,custom_segment7 = g_allocation_row.custom_segment7
       ,custom_segment8 = g_allocation_row.custom_segment8
       ,custom_segment9 = g_allocation_row.custom_segment9
       ,custom_segment10 = g_allocation_row.custom_segment10
       ,custom_segment11 = g_allocation_row.custom_segment11
       ,custom_segment12 = g_allocation_row.custom_segment12
       ,custom_segment13 = g_allocation_row.custom_segment13
       ,custom_segment14 = g_allocation_row.custom_segment14
       ,custom_segment15 = g_allocation_row.custom_segment15
       ,custom_segment16 = g_allocation_row.custom_segment16
       ,custom_segment17 = g_allocation_row.custom_segment17
       ,custom_segment18 = g_allocation_row.custom_segment18
       ,custom_segment19 = g_allocation_row.custom_segment19
       ,custom_segment20 = g_allocation_row.custom_segment20
       ,cpi_attribute1 = g_allocation_row.cpi_attribute1
       ,cpi_attribute2 = g_allocation_row.cpi_attribute2
       ,cpi_attribute3 = g_allocation_row.cpi_attribute3
       ,cpi_attribute4 = g_allocation_row.cpi_attribute4
       ,cpi_attribute5 = g_allocation_row.cpi_attribute5
       ,cpi_attribute6 = g_allocation_row.cpi_attribute6
       ,cpi_attribute7 = g_allocation_row.cpi_attribute7
       ,cpi_attribute8 = g_allocation_row.cpi_attribute8
       ,cpi_attribute9 = g_allocation_row.cpi_attribute9
       ,cpi_attribute10 = g_allocation_row.cpi_attribute10
       ,cpi_attribute11 = g_allocation_row.cpi_attribute11
       ,cpi_attribute12 = g_allocation_row.cpi_attribute12
       ,cpi_attribute13 = g_allocation_row.cpi_attribute13
       ,cpi_attribute14 = g_allocation_row.cpi_attribute14
       ,cpi_attribute15 = g_allocation_row.cpi_attribute15
       ,cpi_attribute16 = g_allocation_row.cpi_attribute16
       ,cpi_attribute17 = g_allocation_row.cpi_attribute17
       ,cpi_attribute18 = g_allocation_row.cpi_attribute18
       ,cpi_attribute19 = g_allocation_row.cpi_attribute19
       ,cpi_attribute20 = g_allocation_row.cpi_attribute20
       ,cpi_attribute21 = g_allocation_row.cpi_attribute21
       ,cpi_attribute22 = g_allocation_row.cpi_attribute22
       ,cpi_attribute23 = g_allocation_row.cpi_attribute23
       ,cpi_attribute24 = g_allocation_row.cpi_attribute24
       ,cpi_attribute25 = g_allocation_row.cpi_attribute25
       ,cpi_attribute26 = g_allocation_row.cpi_attribute26
       ,cpi_attribute27 = g_allocation_row.cpi_attribute27
       ,cpi_attribute28 = g_allocation_row.cpi_attribute28
       ,cpi_attribute29 = g_allocation_row.cpi_attribute29
       ,cpi_attribute30 = g_allocation_row.cpi_attribute30
  where group_per_in_ler_id = g_allocation_row.group_per_in_ler_id;
  end if;
  if g_upd_pl_rate then
    ben_cwb_person_rates_api.update_person_rate
        (p_validate => false
        ,p_group_per_in_ler_id => g_allocation_row.group_per_in_ler_id
        ,p_pl_id               => g_allocation_row.pl_id
        ,p_oipl_id             => -1
        ,p_group_pl_id         => g_allocation_row.group_pl_id
        ,p_group_oipl_id       => -1
        ,p_lf_evt_ocrd_dt      => g_allocation_row.lf_evt_ocrd_dt
        ,p_ws_val              => g_allocation_row.ws_val
        ,p_stat_sal_val        => g_allocation_row.stat_sal_val
        ,p_oth_comp_val        => g_allocation_row.oth_comp_val
        ,p_tot_comp_val        => g_allocation_row.tot_comp_val
        ,p_misc1_val           => g_allocation_row.misc1_val
        ,p_misc2_val           => g_allocation_row.misc2_val
        ,p_misc3_val           => g_allocation_row.misc3_val
        ,p_rec_val             => g_allocation_row.rec_val
        ,p_object_version_number => g_allocation_row.ovn_pl);
     l_save_summary := true;
  end if;
  if g_upd_opt1_rate then
    ben_cwb_person_rates_api.update_person_rate
        (p_validate => false
        ,p_group_per_in_ler_id => g_allocation_row.group_per_in_ler_id
        ,p_pl_id               => g_allocation_row.pl_id
        ,p_oipl_id             => g_allocation_row.oipl_id_opt1
        ,p_group_pl_id         => g_allocation_row.group_pl_id
        ,p_group_oipl_id       => g_allocation_row.group_oipl_id_opt1
        ,p_lf_evt_ocrd_dt      => g_allocation_row.lf_evt_ocrd_dt
        ,p_ws_val              => g_allocation_row.ws_val_opt1
        ,p_stat_sal_val        => g_allocation_row.stat_sal_val_opt1
        ,p_oth_comp_val        => g_allocation_row.oth_comp_val_opt1
        ,p_tot_comp_val        => g_allocation_row.tot_comp_val_opt1
        ,p_misc1_val           => g_allocation_row.misc1_val_opt1
        ,p_misc2_val           => g_allocation_row.misc2_val_opt1
        ,p_misc3_val           => g_allocation_row.misc3_val_opt1
        ,p_rec_val             => g_allocation_row.rec_val_opt1
        ,p_object_version_number => g_allocation_row.ovn_opt1);
     l_save_summary := true;
  end if;
  if g_upd_opt2_rate then
    ben_cwb_person_rates_api.update_person_rate
        (p_validate => false
        ,p_group_per_in_ler_id => g_allocation_row.group_per_in_ler_id
        ,p_pl_id               => g_allocation_row.pl_id
        ,p_oipl_id             => g_allocation_row.oipl_id_opt2
        ,p_group_pl_id         => g_allocation_row.group_pl_id
        ,p_group_oipl_id       => g_allocation_row.group_oipl_id_opt2
        ,p_lf_evt_ocrd_dt      => g_allocation_row.lf_evt_ocrd_dt
        ,p_ws_val              => g_allocation_row.ws_val_opt2
        ,p_stat_sal_val        => g_allocation_row.stat_sal_val_opt2
        ,p_oth_comp_val        => g_allocation_row.oth_comp_val_opt2
        ,p_tot_comp_val        => g_allocation_row.tot_comp_val_opt2
        ,p_misc1_val           => g_allocation_row.misc1_val_opt2
        ,p_misc2_val           => g_allocation_row.misc2_val_opt2
        ,p_misc3_val           => g_allocation_row.misc3_val_opt2
        ,p_rec_val             => g_allocation_row.rec_val_opt2
        ,p_object_version_number => g_allocation_row.ovn_opt2);
     l_save_summary := true;
  end if;
  if g_upd_opt3_rate then
    ben_cwb_person_rates_api.update_person_rate
        (p_validate => false
        ,p_group_per_in_ler_id => g_allocation_row.group_per_in_ler_id
        ,p_pl_id               => g_allocation_row.pl_id
        ,p_oipl_id             => g_allocation_row.oipl_id_opt3
        ,p_group_pl_id         => g_allocation_row.group_pl_id
        ,p_group_oipl_id       => g_allocation_row.group_oipl_id_opt3
        ,p_lf_evt_ocrd_dt      => g_allocation_row.lf_evt_ocrd_dt
        ,p_ws_val              => g_allocation_row.ws_val_opt3
        ,p_stat_sal_val        => g_allocation_row.stat_sal_val_opt3
        ,p_oth_comp_val        => g_allocation_row.oth_comp_val_opt3
        ,p_tot_comp_val        => g_allocation_row.tot_comp_val_opt3
        ,p_misc1_val           => g_allocation_row.misc1_val_opt3
        ,p_misc2_val           => g_allocation_row.misc2_val_opt3
        ,p_misc3_val           => g_allocation_row.misc3_val_opt3
        ,p_rec_val             => g_allocation_row.rec_val_opt3
        ,p_object_version_number => g_allocation_row.ovn_opt3);
     l_save_summary := true;
  end if;
  if g_upd_opt4_rate then
    ben_cwb_person_rates_api.update_person_rate
        (p_validate => false
        ,p_group_per_in_ler_id => g_allocation_row.group_per_in_ler_id
        ,p_pl_id               => g_allocation_row.pl_id
        ,p_oipl_id             => g_allocation_row.oipl_id_opt4
        ,p_group_pl_id         => g_allocation_row.group_pl_id
        ,p_group_oipl_id       => g_allocation_row.group_oipl_id_opt4
        ,p_lf_evt_ocrd_dt      => g_allocation_row.lf_evt_ocrd_dt
        ,p_ws_val              => g_allocation_row.ws_val_opt4
        ,p_stat_sal_val        => g_allocation_row.stat_sal_val_opt4
        ,p_oth_comp_val        => g_allocation_row.oth_comp_val_opt4
        ,p_tot_comp_val        => g_allocation_row.tot_comp_val_opt4
        ,p_misc1_val           => g_allocation_row.misc1_val_opt4
        ,p_misc2_val           => g_allocation_row.misc2_val_opt4
        ,p_misc3_val           => g_allocation_row.misc3_val_opt4
        ,p_rec_val             => g_allocation_row.rec_val_opt4
        ,p_object_version_number => g_allocation_row.ovn_opt4);
     l_save_summary := true;
  end if;
  if l_save_summary then
    ben_cwb_summary_pkg.save_pl_sql_tab;
  end if;

end save_data;

--
-- Public procedure
--

-- --------------------------------------------------------------------------
-- |--------------------< run_dynamic_calculations >------------------------|
-- --------------------------------------------------------------------------
procedure run_dynamic_calculations(p_group_per_in_ler_id in number
                                  ,p_group_pl_id in number
                                  ,p_lf_evt_ocrd_dt in date
                                  ,p_raise_error in boolean default false) is
  l_calc_details_count integer := 0;
  l_old_rslt_col varchar2(30) := 'zzzzz';
  l_rslt_col varchar2(30);
begin
  l_calc_details_count := load_calc_details(p_group_pl_id);
  if l_calc_details_count = 0 then
    return;
  end if;
  --
  g_upd_person_info := false;
  g_upd_pl_rate := false;
  g_upd_opt1_rate := false;
  g_upd_opt2_rate := false;
  g_upd_opt3_rate := false;
  g_upd_opt4_rate := false;
  --
  load_plan_info(p_group_pl_id, p_lf_evt_ocrd_dt);
  load_allocation_row(p_group_per_in_ler_id);

  -- 6024581: if group_per_in_ler_id is not null, then save the data.

if (g_allocation_row.group_per_in_ler_id is not null) then
  for i in 1..g_calc_details.count loop
    l_rslt_col := g_calc_details(i).rslt_col;
    if (l_rslt_col <> l_old_rslt_col) then
      execute_column(p_group_per_in_ler_id, l_rslt_col, i, p_raise_error);
      l_old_rslt_col := l_rslt_col;
    end if;
  end loop;

  save_data;
end if;

exception
  when others then
    hr_utility.set_location('run_dynamic_calculations '||p_group_per_in_ler_id,999);
    raise;

end run_dynamic_calculations;

end ben_cwb_dyn_calc_pkg;


/
