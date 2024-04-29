--------------------------------------------------------
--  DDL for Package Body PAY_CORE_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CORE_UPGRADE_PKG" AS
/* $Header: pycougpk.pkb 120.13.12010000.1 2008/07/27 22:23:46 appldev ship $ */

-- Cache Used by Sparse Matrix Run Result Value Purge upgrade.
g_leg_code_cached boolean := FALSE;
g_jur_name pay_input_values_f.name%type;


  /* Name      : upg_single_lat_bal_tab
     Purpose   : This procedure is used to upgrade to a single
                 latest balance table from a pay_assignment_latest_balabces
                 and pay_person_latest_balances.
     Arguments :
     Notes     :
  */
procedure upg_single_lat_bal_tab (p_person_id in number)
is
--
type t_def_bal_id is table of pay_latest_balances.defined_balance_id%type
     index by binary_integer;
type t_asg_act_id is table of pay_latest_balances.assignment_action_id%type
     index by binary_integer;
type t_asg_id is table of pay_latest_balances.assignment_id%type
     index by binary_integer;
type t_per_id is table of pay_latest_balances.person_id%type
     index by binary_integer;
type t_value is table of pay_latest_balances.value%type
     index by binary_integer;
type t_lat_bal_id is table of pay_latest_balances.latest_balance_id%type
     index by binary_integer;
type t_tu_id is table of pay_latest_balances.tax_unit_id%type
     index by binary_integer;
type t_jc is table of pay_latest_balances.jurisdiction_code%type
     index by binary_integer;
type t_oe_id is table of pay_latest_balances.original_entry_id%type
     index by binary_integer;
type t_si is table of pay_latest_balances.source_id%type
     index by binary_integer;
type t_st is table of pay_latest_balances.source_text%type
     index by binary_integer;
type t_st2 is table of pay_latest_balances.source_text2%type
     index by binary_integer;
type t_sn is table of pay_latest_balances.source_number%type
     index by binary_integer;
type t_tg is table of pay_latest_balances.tax_group%type
     index by binary_integer;
type t_pay_id is table of pay_latest_balances.payroll_id%type
     index by binary_integer;
type t_cont_nm is table of ff_contexts.context_name%type
     index by binary_integer;
type t_cont_vl is table of pay_balance_context_values.value%type
     index by binary_integer;
--
l_def_bal_id   t_def_bal_id;
l_asg_act_id   t_asg_act_id;
l_e_asg_act_id t_asg_act_id;
l_p_asg_act_id t_asg_act_id;
l_asg_id       t_asg_id;
l_per_id       t_per_id;
l_value        t_value;
l_e_value      t_value;
l_p_value      t_value;
l_lat_bal_id   t_lat_bal_id;
l_cont_value   t_cont_vl;
l_cont_name    t_cont_nm;
--
l_def_bal_id_ins   t_def_bal_id;
l_asg_act_id_ins   t_asg_act_id;
l_e_asg_act_id_ins t_asg_act_id;
l_p_asg_act_id_ins t_asg_act_id;
l_asg_id_ins       t_asg_id;
l_per_id_ins       t_per_id;
l_value_ins        t_value;
l_e_value_ins      t_value;
l_p_value_ins      t_value;
l_lat_bal_id_ins   t_lat_bal_id;
l_tu_tab           t_tu_id;
l_jc_tab           t_jc;
l_oei_tab          t_oe_id;
l_si_tab           t_si;
l_st_tab           t_st;
l_st2_tab          t_st2;
l_sn_tab           t_sn;
l_tg_tab           t_tg;
l_pay_id_tab       t_pay_id;
--
prev_latest_bal_id number;
free_def_cnt       number;
curr_def_cnt       number;
--
cursor c_get_cont(p_latest_bal_id in number)
is
select fc.context_name,
       pbcv.value
  from pay_balance_context_values pbcv,
       ff_contexts fc
 where pbcv.latest_balance_id = p_latest_bal_id
   and pbcv.context_id = fc.context_id;
--
cursor c_get_asgs (p_person_id in number)
is
select distinct assignment_id
from per_all_assignments_f
where person_id = p_person_id;
--
begin
--
     l_def_bal_id.delete;
     l_asg_act_id.delete;
     l_e_asg_act_id.delete;
     l_p_asg_act_id.delete;
     l_asg_id.delete;
     l_per_id.delete;
     l_value.delete;
     l_e_value.delete;
     l_p_value.delete;
     l_lat_bal_id.delete;
     l_cont_value.delete;
     l_cont_name.delete;
     l_def_bal_id_ins.delete;
     l_asg_act_id_ins.delete;
     l_e_asg_act_id_ins.delete;
     l_p_asg_act_id_ins.delete;
     l_asg_id_ins.delete;
     l_per_id_ins.delete;
     l_value_ins.delete;
     l_e_value_ins.delete;
     l_p_value_ins.delete;
     l_lat_bal_id_ins.delete;
     l_tu_tab.delete;
     l_jc_tab.delete;
     l_oei_tab.delete;
     l_si_tab.delete;
     l_st_tab.delete;
     l_st2_tab.delete;
     l_sn_tab.delete;
     l_tg_tab.delete;
     l_pay_id_tab.delete;
--
     select /*+ ORDERED USE_NL(pplb pbcv fc) */
            pplb.defined_balance_id,
            pplb.assignment_action_id,
            pplb.person_id,
            pplb.value,
            pplb.latest_balance_id,
            pplb.expired_assignment_action_id,
            pplb.expired_value,
            pplb.prev_balance_value,
            pplb.prev_assignment_action_id,
            pbcv.value,
            fc.context_name
     bulk collect into
            l_def_bal_id,
            l_asg_act_id,
            l_per_id,
            l_value,
            l_lat_bal_id,
            l_e_asg_act_id,
            l_e_value,
            l_p_value,
            l_p_asg_act_id,
            l_cont_value,
            l_cont_name
     from pay_person_latest_balances pplb,
          pay_balance_context_values pbcv,
          ff_contexts fc
     where pplb.person_id = p_person_id
       and pplb.latest_balance_id = pbcv.latest_balance_id (+)
       and nvl(pbcv.context_id, -1) = fc.context_id (+)
     order by pplb.latest_balance_id;
--
   prev_latest_bal_id := -1;
   free_def_cnt := 1;
   for i in 1..l_def_bal_id.count loop
--
     if (prev_latest_bal_id <> l_lat_bal_id(i)) then
            l_def_bal_id_ins(free_def_cnt)   := l_def_bal_id(i);
            l_asg_act_id_ins(free_def_cnt)   := l_asg_act_id(i);
            l_per_id_ins(free_def_cnt)       := l_per_id(i);
            l_value_ins(free_def_cnt)        := l_value(i);
            l_lat_bal_id_ins(free_def_cnt)      := l_lat_bal_id(i);
            l_e_asg_act_id_ins(free_def_cnt) := l_e_asg_act_id(i);
            l_e_value_ins(free_def_cnt)      := l_e_value(i);
            l_p_value_ins(free_def_cnt)      := l_p_value(i);
            l_p_asg_act_id_ins(free_def_cnt) := l_p_asg_act_id(i);
            l_tu_tab(free_def_cnt)           := null;
            l_jc_tab(free_def_cnt)           := null;
            l_oei_tab(free_def_cnt)          := null;
            l_si_tab(free_def_cnt)           := null;
            l_st_tab(free_def_cnt)           := null;
            l_st2_tab(free_def_cnt)          := null;
            l_sn_tab(free_def_cnt)           := null;
            l_tg_tab(free_def_cnt)           := null;
            l_pay_id_tab(free_def_cnt)       := null;
--
            curr_def_cnt := free_def_cnt;
            free_def_cnt := free_def_cnt + 1;
            prev_latest_bal_id := l_lat_bal_id(i);
     end if;
--
     if (l_cont_name(i) is not null) then
       if (l_cont_name(i) = 'TAX_UNIT_ID') then
         l_tu_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'JURISDICTION_CODE') then
         l_jc_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'ORIGINAL_ENTRY_ID') then
         l_oei_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'SOURCE_ID') then
         l_si_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'SOURCE_TEXT') then
         l_st_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'SOURCE_TEXT2') then
         l_st2_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'SOURCE_NUMBER') then
         l_sn_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'TAX_GROUP') then
         l_tg_tab(curr_def_cnt) := l_cont_value(i);
       elsif (l_cont_name(i) = 'PAYROLL_ID') then
         l_pay_id_tab(curr_def_cnt) := l_cont_value(i);
       end if;
     end if;
--
   end loop;
--
   forall i in 1..l_def_bal_id_ins.count
     insert into pay_latest_balances
                      (latest_balance_id,
                       defined_balance_id,
                       assignment_action_id,
                       value,
                       person_id,
                       expired_assignment_action_id,
                       expired_value,
                       prev_assignment_action_id,
                       prev_balance_value,
                       tax_unit_id,
                       jurisdiction_code,
                       original_entry_id,
                       source_id,
                       source_text,
                       source_text2,
                       source_number,
                       tax_group,
                       payroll_id)
               values (
                       l_lat_bal_id_ins(i),
                       l_def_bal_id_ins(i),
                       l_asg_act_id_ins(i),
                       l_value_ins(i),
                       l_per_id_ins(i),
                       l_e_asg_act_id_ins(i),
                       l_e_value_ins(i),
                       l_p_asg_act_id_ins(i),
                       l_p_value_ins(i),
                       l_tu_tab(i),
                       l_jc_tab(i),
                       l_oei_tab(i),
                       l_si_tab(i),
                       l_st_tab(i),
                       l_st2_tab(i),
                       l_sn_tab(i),
                       l_tg_tab(i),
                       l_pay_id_tab(i));
--
   for asgrec in c_get_asgs(p_person_id) loop
--
     l_def_bal_id.delete;
     l_asg_act_id.delete;
     l_e_asg_act_id.delete;
     l_p_asg_act_id.delete;
     l_asg_id.delete;
     l_per_id.delete;
     l_value.delete;
     l_e_value.delete;
     l_p_value.delete;
     l_lat_bal_id.delete;
     l_cont_value.delete;
     l_cont_name.delete;
     l_def_bal_id_ins.delete;
     l_asg_act_id_ins.delete;
     l_e_asg_act_id_ins.delete;
     l_p_asg_act_id_ins.delete;
     l_asg_id_ins.delete;
     l_per_id_ins.delete;
     l_value_ins.delete;
     l_e_value_ins.delete;
     l_p_value_ins.delete;
     l_lat_bal_id_ins.delete;
     l_tu_tab.delete;
     l_jc_tab.delete;
     l_oei_tab.delete;
     l_si_tab.delete;
     l_st_tab.delete;
     l_st2_tab.delete;
     l_sn_tab.delete;
     l_tg_tab.delete;
     l_pay_id_tab.delete;
--
     select /*+ ORDERED USE_NL(palb pbcv fc) */
            palb.defined_balance_id,
            palb.assignment_action_id,
            palb.assignment_id,
            palb.value,
            palb.latest_balance_id,
            palb.expired_assignment_action_id,
            palb.expired_value,
            palb.prev_balance_value,
            palb.prev_assignment_action_id,
            pbcv.value,
            fc.context_name
          bulk collect into
                 l_def_bal_id,
                 l_asg_act_id,
                 l_asg_id,
                 l_value,
                 l_lat_bal_id,
                 l_e_asg_act_id,
                 l_e_value,
                 l_p_value,
                 l_p_asg_act_id,
                 l_cont_value,
                 l_cont_name
     from pay_assignment_latest_balances palb,
          pay_balance_context_values pbcv,
          ff_contexts                fc
     where palb.assignment_id = asgrec.assignment_id
       and palb.latest_balance_id = pbcv.latest_balance_id (+)
       and nvl(pbcv.context_id, -1) = fc.context_id (+)
     order by palb.latest_balance_id;
--
     prev_latest_bal_id := -1;
     free_def_cnt := 1;
     for i in 1..l_def_bal_id.count loop
--
       if (prev_latest_bal_id <> l_lat_bal_id(i)) then
            l_def_bal_id_ins(free_def_cnt)   := l_def_bal_id(i);
            l_asg_act_id_ins(free_def_cnt)   := l_asg_act_id(i);
            l_asg_id_ins(free_def_cnt)       := l_asg_id(i);
            l_per_id_ins(free_def_cnt)       := p_person_id;
            l_value_ins(free_def_cnt)        := l_value(i);
            l_lat_bal_id_ins(free_def_cnt)      := l_lat_bal_id(i);
            l_e_asg_act_id_ins(free_def_cnt) := l_e_asg_act_id(i);
            l_e_value_ins(free_def_cnt)      := l_e_value(i);
            l_p_value_ins(free_def_cnt)      := l_p_value(i);
            l_p_asg_act_id_ins(free_def_cnt) := l_p_asg_act_id(i);
            l_tu_tab(free_def_cnt)           := null;
            l_jc_tab(free_def_cnt)           := null;
            l_oei_tab(free_def_cnt)          := null;
            l_si_tab(free_def_cnt)           := null;
            l_st_tab(free_def_cnt)           := null;
            l_st2_tab(free_def_cnt)          := null;
            l_sn_tab(free_def_cnt)           := null;
            l_tg_tab(free_def_cnt)           := null;
            l_pay_id_tab(free_def_cnt)       := null;
--
            curr_def_cnt := free_def_cnt;
            free_def_cnt := free_def_cnt + 1;
            prev_latest_bal_id := l_lat_bal_id(i);
       end if;
--
       if (l_cont_name(i) is not null) then
         if (l_cont_name(i) = 'TAX_UNIT_ID') then
           l_tu_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'JURISDICTION_CODE') then
           l_jc_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'ORIGINAL_ENTRY_ID') then
           l_oei_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'SOURCE_ID') then
           l_si_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'SOURCE_TEXT') then
           l_st_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'SOURCE_TEXT2') then
           l_st2_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'SOURCE_NUMBER') then
           l_sn_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'TAX_GROUP') then
           l_tg_tab(curr_def_cnt) := l_cont_value(i);
         elsif (l_cont_name(i) = 'PAYROLL_ID') then
           l_pay_id_tab(curr_def_cnt) := l_cont_value(i);
         end if;
       end if;
     end loop;
--
     forall i in 1..l_def_bal_id_ins.count
       insert into pay_latest_balances
                        (latest_balance_id,
                         defined_balance_id,
                         assignment_action_id,
                         value,
                         person_id,
                         assignment_id,
                         expired_assignment_action_id,
                         expired_value,
                         prev_assignment_action_id,
                         prev_balance_value,
                         tax_unit_id,
                         jurisdiction_code,
                         original_entry_id,
                         source_id,
                         source_text,
                         source_text2,
                         source_number,
                         tax_group,
                         payroll_id)
                 values (
                         l_lat_bal_id_ins(i),
                         l_def_bal_id_ins(i),
                         l_asg_act_id_ins(i),
                         l_value_ins(i),
                         l_per_id_ins(i),
                         l_asg_id_ins(i),
                         l_e_asg_act_id_ins(i),
                         l_e_value_ins(i),
                         l_p_asg_act_id_ins(i),
                         l_p_value_ins(i),
                         l_tu_tab(i),
                         l_jc_tab(i),
                         l_oei_tab(i),
                         l_si_tab(i),
                         l_st_tab(i),
                         l_st2_tab(i),
                         l_sn_tab(i),
                         l_tg_tab(i),
                         l_pay_id_tab(i));
--
   end loop;
--
end upg_single_lat_bal_tab;
--
  /* Name      : upg_retro_proc_det_frm_ee
     Purpose   : This procedure is used to upgrade the entry process
                 details table. This is a new table used by the Retropay
                 process.
     Arguments :
     Notes     :
  */
procedure upg_retro_proc_det_frm_ee (p_asg_id in number)
is
cursor get_retro_ee(p_asg_id in number) is
select pee.element_entry_id,
       pee.element_type_id,
       pee.creator_type,
       pee.source_id,
       pee.source_asg_action_id,
       pee.source_run_type
from pay_element_entries_f pee
where pee.creator_type in ('RR', 'EE')
and   pee.assignment_id = p_asg_id;
--
l_run_result_id  pay_entry_process_details.run_result_id%type;
l_src_entry_id   pay_entry_process_details.source_entry_id%type;
l_ppath          pay_entry_process_details.process_path%type;
l_src_asg_act_id pay_entry_process_details.source_asg_action_id%type;
l_src_et_id      pay_entry_process_details.source_element_type_id%type;
l_dummy varchar2(2);
l_loc_aa_id number;
l_loc_src_aa_id number;
l_upgrade boolean;
begin
--
      for eerec in get_retro_ee(p_asg_id) loop
--
         begin
--
            select ''
              into l_dummy
              from pay_entry_process_details
             where element_entry_id = eerec.element_entry_id;
--
            l_src_asg_act_id := eerec.source_asg_action_id;
--
            if (eerec.creator_type = 'RR') then
              l_run_result_id:= eerec.source_id;
              begin
--
                select prr.source_id,
                       prr.element_type_id,
                       pay_core_utils.get_process_path(prr.assignment_action_id),
                       prr.assignment_action_id,
                       paa.source_action_id
                  into l_src_entry_id,
                       l_src_et_id,
                       l_ppath,
                       l_loc_aa_id,
                       l_loc_src_aa_id
                  from pay_run_results prr,
                       pay_assignment_actions paa
                  where prr.run_result_id = l_run_result_id
                    and prr.assignment_action_id = paa.assignment_action_id;
--
              exception
                 when no_data_found then
                     pay_core_utils.assert_condition(
                             'upg_retro_proc_det_frm_ee:1',
                             1 = 2);
--
              end;
              if (l_src_asg_act_id is null) then
                 if (l_loc_src_aa_id is null) then
                    l_src_asg_act_id := l_loc_aa_id;
                 else
                   while (l_loc_src_aa_id is not null) loop
                      select assignment_action_id,
                             source_action_id
                        into l_loc_aa_id,
                             l_loc_src_aa_id
                        from pay_assignment_actions
                       where assignment_action_id = l_loc_src_aa_id;
                   end loop;
                   l_src_asg_act_id := l_loc_aa_id;
                 end if;
                 update pay_element_entries_f
                    set source_asg_action_id = l_src_asg_act_id
                  where element_entry_id = eerec.element_entry_id;
              end if;
            else
              l_run_result_id:= null;
              l_src_entry_id := eerec.source_id;
--
              if (eerec.element_type_id is null) then
                pay_core_utils.assert_condition(
                      'upg_retro_proc_det_frm_ee:4',
                      1 = 2);
              end if;
--
              begin
                 select distinct pet.element_type_id
                   into l_src_et_id
                   from pay_element_types_f pet,
                        pay_element_links_f pel,
                        pay_element_entries_f pee
                  where pee.element_entry_id = l_src_entry_id
                    and pee.element_link_id = pel.element_link_id
                    and pel.element_type_id = pet.element_type_id;
--
                  /* This double checks the value. It could
                     be an indriect thus have a different
                     element type
                  */
                  if (l_src_et_id <> eerec.element_type_id) then
                     declare
                        l_retro_et_cnt number;
                     begin
                        select count(distinct(element_type_id))
                          into l_retro_et_cnt
                          from pay_element_types_f
                         where retro_summ_ele_id = eerec.element_type_id;
--
                        if (l_retro_et_cnt = 0) then
                           l_src_et_id := eerec.element_type_id;
                        elsif (l_retro_et_cnt = 1) then
                           select distinct(element_type_id)
                             into l_src_et_id
                             from pay_element_types_f
                            where retro_summ_ele_id = eerec.element_type_id;
                        else
                           --pay_core_utils.assert_condition(
                           --      'upg_retro_proc_det_frm_ee:8',
                           --      1 = 2);
                           --
                           -- Since there can be many then take the first one.
                           select distinct(element_type_id)
                             into l_src_et_id
                             from pay_element_types_f
                            where retro_summ_ele_id = eerec.element_type_id
                              and rownum = 1;
                        end if;
--
                     end;
                 end if;
--
              exception
                 when no_data_found then
--
                     -- OK we're in s difficult position try to
                     -- find a match for this element type.
                     -- Since the original element entry has been
                     -- deleted.
                     declare
                        l_retro_et_cnt number;
                     begin
                        select count(distinct(element_type_id))
                          into l_retro_et_cnt
                          from pay_element_types_f
                         where retro_summ_ele_id = eerec.element_type_id;
--
                        if (l_retro_et_cnt = 0) then
                           l_src_et_id := eerec.element_type_id;
                        else
                           select distinct element_type_id
                             into l_src_et_id
                             from pay_element_types_f
                            where retro_summ_ele_id = eerec.element_type_id
                              and rownum = 1;
                        end if;
                     end;
              end;
              begin
                 select pay_core_utils.get_process_path(assignment_action_id)
                   into l_ppath
                   from pay_assignment_actions
                  where source_action_id = l_src_asg_act_id
                    and run_type_id = eerec.source_run_type
                    and rownum = 1;
--
              exception
                 when no_data_found then
                    l_ppath := '.';
              end;
            end if;
--
--
            update pay_entry_process_details
               set run_result_id          = l_run_result_id,
                   source_entry_id        = l_src_entry_id,
                   process_path           = l_ppath,
                   source_asg_action_id   = l_src_asg_act_id,
                   source_element_type_id = l_src_et_id
             where element_entry_id = eerec.element_entry_id;
--
         exception
            when no_data_found then
              l_src_asg_act_id := eerec.source_asg_action_id;
--
              if (eerec.creator_type = 'RR') then
                l_run_result_id:= eerec.source_id;
                begin
--
                  select prr.source_id,
                         prr.element_type_id,
                         pay_core_utils.get_process_path(prr.assignment_action_id),
                         prr.assignment_action_id,
                         paa.source_action_id
                    into l_src_entry_id,
                         l_src_et_id,
                         l_ppath,
                         l_loc_aa_id,
                         l_loc_src_aa_id
                    from pay_run_results prr,
                         pay_assignment_actions paa
                    where prr.run_result_id = l_run_result_id
                      and prr.assignment_action_id = paa.assignment_action_id;
--
                exception
                   when no_data_found then
                     pay_core_utils.assert_condition(
                             'upg_retro_proc_det_frm_ee:3',
                             1 = 2);
--
                end;
--
                if (l_src_asg_act_id is null) then
                   if (l_loc_src_aa_id is null) then
                      l_src_asg_act_id := l_loc_aa_id;
                   else
                     while (l_loc_src_aa_id is not null) loop
                        select assignment_action_id,
                               source_action_id
                          into l_loc_aa_id,
                               l_loc_src_aa_id
                          from pay_assignment_actions
                         where assignment_action_id = l_loc_src_aa_id;
                     end loop;
                     l_src_asg_act_id := l_loc_aa_id;
                   end if;
                   update pay_element_entries_f
                      set source_asg_action_id = l_src_asg_act_id
                    where element_entry_id = eerec.element_entry_id;
                end if;
--
              else
                l_run_result_id:= null;
                l_src_entry_id := eerec.source_id;
--
                if (eerec.element_type_id is null) then
                  pay_core_utils.assert_condition(
                        'upg_retro_proc_det_frm_ee:4',
                        1 = 2);
                end if;
--
                begin
                   select distinct pet.element_type_id
                     into l_src_et_id
                     from pay_element_types_f pet,
                          pay_element_links_f pel,
                          pay_element_entries_f pee
                    where pee.element_entry_id = l_src_entry_id
                      and pee.element_link_id = pel.element_link_id
                      and pel.element_type_id = pet.element_type_id;
--
                    /* This double checks the value. It could
                       be an indriect thus have a different
                       element type
                    */
                    if (l_src_et_id <> eerec.element_type_id) then
                        declare
                           l_retro_et_cnt number;
                        begin
                           select count(distinct(element_type_id))
                             into l_retro_et_cnt
                             from pay_element_types_f
                            where retro_summ_ele_id = eerec.element_type_id;
                           --   and element_type_id = l_src_et_id;
--
                           if (l_retro_et_cnt = 0) then
                              l_src_et_id := eerec.element_type_id;
                           elsif (l_retro_et_cnt = 1) then
                              select distinct(element_type_id)
                                into l_src_et_id
                                from pay_element_types_f
                               where retro_summ_ele_id = eerec.element_type_id;
                              --   and element_type_id = l_src_et_id;
                           else
                              -- pay_core_utils.assert_condition(
                              --    'upg_retro_proc_det_frm_ee:9',
                              --       1 = 2);
                              --
                              -- Since there can be many then take the first one.
                              select distinct(element_type_id)
                                into l_src_et_id
                                from pay_element_types_f
                               where retro_summ_ele_id = eerec.element_type_id
                                 and rownum = 1;
                           end if;
--
                        end;
                    end if;
--
                exception
                   when no_data_found then
--
                     -- OK we're in a difficult position try to
                     -- find a match for this element type.
                     -- Since the original element entry has been
                     -- deleted.
                     declare
                        l_retro_et_cnt number;
                     begin
                        select count(distinct(element_type_id))
                          into l_retro_et_cnt
                          from pay_element_types_f
                         where retro_summ_ele_id = eerec.element_type_id;
--
                        if (l_retro_et_cnt = 0) then
                           l_src_et_id := eerec.element_type_id;
                        else
                           select distinct element_type_id
                             into l_src_et_id
                             from pay_element_types_f
                            where retro_summ_ele_id = eerec.element_type_id
                              and rownum = 1;
                        end if;
                     end;
                end;
                begin
                   select pay_core_utils.get_process_path(assignment_action_id)
                     into l_ppath
                     from pay_assignment_actions
                    where source_action_id = l_src_asg_act_id
                      and run_type_id = eerec.source_run_type
                      and rownum = 1;
--
                exception
                   when no_data_found then
                      l_ppath := '.';
                end;
              end if;
--
              insert into pay_entry_process_details
                  (element_entry_id,
                   run_result_id,
                   source_entry_id,
                   process_path,
                   source_asg_action_id,
                   source_element_type_id
                  )
              values
                  (eerec.element_entry_id,
                   l_run_result_id,
                   l_src_entry_id,
                   l_ppath,
                   l_src_asg_act_id,
                   l_src_et_id);
--
         end;
--
      end loop;
--
--   end if;
--
end upg_retro_proc_det_frm_ee;
--
  /* Name      : upg_retro_proc_det_frm_ee
     Purpose   : This procedure is used to qualify the object for the
                 upgrade.
     Arguments :
     Notes     :
  */
procedure qual_retro_proc_det_frm_ee(p_object_id in            number,
                          p_qualified    out nocopy varchar2
                         )
is
l_dummy varchar2(2);
l_qualifier varchar2(10);
begin
--
   begin
      select ''
        into l_dummy
        from dual
       where exists (select ''
                       from pay_payroll_actions ppa,
                            pay_assignment_actions paa
                      where paa.assignment_id = p_object_id
                        and paa.payroll_action_id = ppa.payroll_action_id
                        and action_type = 'L');
       l_qualifier := 'Y';
   exception
       when no_data_found then
         l_qualifier := 'N';
   end;
   p_qualified := l_qualifier;
--
end qual_retro_proc_det_frm_ee;
--
  /* Name      : chk_retro_by_ele_exists
     Purpose   : Find out if any Retropay by Elements exists.
                 This procedure is used to decide if a concurrent
                 request is needed to run an upgrade.
     Arguments :
     Notes     :
  */
procedure chk_retro_by_ele_exists(p_exists out nocopy varchar2)
is
l_count number;
begin
--
   select count(*)
     into l_count
     from pay_payroll_actions
    where action_type = 'L';
--
   if (l_count = 0) then
     p_exists := 'FALSE';
   else
     p_exists := 'TRUE';
   end if;
--
exception
    when no_data_found then
       p_exists := 'FALSE';
end chk_retro_by_ele_exists;
--
procedure chk_qpay_inclusions_exist (p_qpay_inclusions_exist out nocopy varchar2)
is
 --
 cursor csr_qpay_inclusions
 is
 select 'TRUE'
 from   pay_quickpay_inclusions
 where  rownum = 1;
 --
 l_inclusions_exist varchar2(10) := 'FALSE';
 --
begin
  --
  open csr_qpay_inclusions;
  fetch csr_qpay_inclusions into l_inclusions_exist;
  close csr_qpay_inclusions;
  --
  p_qpay_inclusions_exist := l_inclusions_exist;
  --
end chk_qpay_inclusions_exist;
--
procedure upg_qpay_excl_tab (p_assignment_id in number)
is
--
  type num_tab is table of number(15) index by binary_integer;
  --
  asgt_action_ids   num_tab;
  element_entry_ids num_tab;
  --
  cursor c_qp_exclusions (p_asg_id in number)
  is
  SELECT /*+ ORDERED
 USE_NL (ASGT_ACTION, EE, ET)
 INDEX(
 EE PAY_ELEMENT_ENTRIES_F_N50,
 ET PAY_ELEMENT_TYPES_F_PK)
 */
       DISTINCT ASGT_ACTION.assignment_action_id, EE.element_entry_id
  FROM pay_assignment_actions ASGT_ACTION,
       pay_payroll_actions    PAY_ACTION,
       pay_element_entries_f  EE,
       pay_element_types_f    ET
  WHERE ASGT_ACTION.assignment_id     = p_asg_id
  AND   ASGT_ACTION.payroll_action_id = PAY_ACTION.payroll_action_id
  AND   PAY_ACTION.action_type        = 'Q'
  AND   ASGT_ACTION.source_action_id  is null
  AND   ASGT_ACTION.assignment_id     = EE.assignment_id
  AND   EE.effective_start_date <= PAY_ACTION.date_earned
  AND   EE.effective_end_date   >= DECODE (
          ET.proration_group_id,
          null, PAY_ACTION.date_earned,
          pay_interpreter_pkg.prorate_start_date (
            ASGT_ACTION.assignment_action_id, ET.proration_group_id
            )
          )
  AND   ET.element_type_id = EE.element_type_id
  AND   PAY_ACTION.date_earned BETWEEN ET.effective_start_date
                               AND     ET.effective_end_date
  --
  -- Create exclusions for all entries that do not exist in
  -- PAY_QUICKPAY_INCLUSIONS...
  --
  AND   NOT EXISTS (
          SELECT 'x'
          FROM pay_quickpay_inclusions qi
          WHERE qi.assignment_action_id = ASGT_ACTION.assignment_action_id
          AND   qi.element_entry_id     = EE.element_entry_id
          )
  --
  -- The QuickPay process will be modified to always ignore entries whose
  -- element type has a process_in_run_flag of 'N', therefore these can also be
  -- ignored...
  --
  AND   ET.process_in_run_flag = 'Y'
  --
  -- The QuickPay process will be modified to always ignore balance adjustments,
  -- replacement adjustments and additive adjustments, therefore these can also
  -- be ignored...
  --
  AND   EE.entry_type NOT IN ('B', 'A', 'R')
  --
  -- The QuickPay process will be modified to ignore nonrecurring entries that
  -- have already been processed, therefore we only want to create exclusions for
  -- nonrecurring entries that have not been processed...
  --
  AND ( ( (   (ET.processing_type   = 'N'
              )
          --
          -- Recurring additional or override entries are handled as if they
          -- were non-recurring.
          --
           OR (    ET.processing_type    = 'R'
               AND EE.entry_type        <> 'E'
              )
          )
          AND (NOT EXISTS (SELECT null
                            FROM pay_run_results pr1
                           WHERE pr1.source_id   = EE.element_entry_id
                             AND pr1.source_type = 'E'
                             AND pr1.status     <> 'U'
                         )
              OR EXISTS (SELECT null
                           FROM pay_run_results pr1
                          WHERE pr1.source_id   = EE.element_entry_id
                            AND pr1.source_type = 'E'
                            AND pr1.status      = 'U'
                        )
              )
        )
          --
          -- Exclude other recurring entries.
          -- i.e. Those which are not additional or overrides entries.
          --
       OR (    ET.processing_type    = 'R'
           AND EE.entry_type         = 'E'
          )
      );
--
begin
--
  open c_qp_exclusions(p_assignment_id);
  loop
    --
    fetch c_qp_exclusions
      bulk collect into asgt_action_ids, element_entry_ids limit 100;
    --
    forall i in 1..asgt_action_ids.COUNT
      insert into pay_quickpay_exclusions (
        assignment_action_id,
        element_entry_id,
        last_update_date,
        last_updated_by,
        created_by,
        creation_date
        )
      values (
        asgt_action_ids(i),
        element_entry_ids(i),
        SYSDATE,
        1,
        1,
        SYSDATE
        );
    --
    exit when c_qp_exclusions%notfound;
    --
  end loop;
  close c_qp_exclusions;
--
end upg_qpay_excl_tab;
--
  /* Name      : qual_qpay_excl_tab
     Purpose   : This procedure is used to qualify an assignment for the
                 QuickPay Exclusions upgrade.
     Arguments :
     Notes     :
  */
procedure qual_qpay_excl_tab(p_object_id in            number,
                             p_qualified    out nocopy varchar2
                            )
is
l_dummy varchar2(2);
l_qualifier varchar2(10);
begin
--
   begin
      select ''
        into l_dummy
        from dual
       where exists (select ''
                       from pay_payroll_actions ppa,
                            pay_assignment_actions paa
                      where paa.assignment_id = p_object_id
                        and paa.payroll_action_id = ppa.payroll_action_id
                        and ppa.action_type = 'Q');
       l_qualifier := 'Y';
   exception
       when no_data_found then
         l_qualifier := 'N';
   end;
   p_qualified := l_qualifier;
--
end qual_qpay_excl_tab;
--
  /* Name      : qual_enable_sparse_matrix
     Purpose   : This procedure is used to qualify that no persons
                 need upgrading (the upgrade is used for the customer
                 to indicate that they are happy for use of spars ematrix)
     Arguments :
     Notes     :
  */
procedure qual_enable_sparse_matrix(p_object_id in            number,
                                    p_qualified    out nocopy varchar2
                                   )
is
begin
--
   p_qualified := 'N';
--
end qual_enable_sparse_matrix;
--
  /* Name      : upg_enable_sparse_matrix
     Purpose   : This procedure is never called
     Arguments :
     Notes     :
  */
--
procedure upg_enable_sparse_matrix (p_person_id in number)
is
begin
--
  null;
--
end upg_enable_sparse_matrix;
--
  /* Name      : qual_sparse_matrix_asg
     Purpose   : This procedure is used to qualify the assignment for
                 the sparse matrix upgrade.
     Arguments :
     Notes     :
  */
procedure qual_sparse_matrix_asg(p_object_id in            number,
                          p_qualified    out nocopy varchar2
                         )
is
l_dummy varchar2(2);
l_qualifier varchar2(10);
begin
--
   begin
      select ''
        into l_dummy
        from dual
       where exists (select ''
                       from pay_payroll_actions ppa,
                            pay_assignment_actions paa
                      where paa.assignment_id = p_object_id
                        and paa.payroll_action_id = ppa.payroll_action_id
                        and action_type in ('R', 'Q', 'B', 'V', 'I'));

       l_qualifier := 'Y';
   exception
       when no_data_found then
         l_qualifier := 'N';
   end;
   p_qualified := l_qualifier;
--
end qual_sparse_matrix_asg;
--
  /* Name      : upg_sparse_matrix_rrvs
     Purpose   : This procedure is used to delete any null value run
                 result values for an assignment
                 NB Other than the Jurisidiction code result value
     Arguments :
     Notes     :
  */
--
procedure upg_sparse_matrix_rrvs (p_assignment_id in number)
is
--
  type t_asg_act_id is table of pay_assignment_actions.assignment_action_id%type
                                 index by binary_integer;
  type date_tab is table of date index by binary_integer;
  --
  asgt_action_ids   t_asg_act_id;
  run_dates         date_tab;
  --
  l_leg_code per_business_groups_perf.legislation_code%type;
  l_bus_grp  per_business_groups_perf.business_group_id%type;
  l_found    boolean := FALSE;
  l_status   varchar2(30);
  --
  cursor c_get_aas (p_assignment_id in number) is
  select /*+ ORDERED use_nl(aa pa)*/
         aa.assignment_action_id, pa.effective_date
  from pay_assignment_actions aa,
       pay_payroll_actions pa
  where aa.assignment_id = p_assignment_id
  and   pa.payroll_action_id = aa.payroll_action_id
  and   pa.action_type in ('R', 'Q', 'B', 'V', 'I');
--
begin
--
  if (g_leg_code_cached = FALSE) then
  --
    select pbg.legislation_code, pbg.business_group_id
    into   l_leg_code, l_bus_grp
    from   per_all_assignments_f asg,
           per_business_groups_perf pbg
    where  asg.assignment_id = p_assignment_id
    and    pbg.business_group_id = asg.business_group_id
    and    rownum = 1;
    --
    pay_core_utils.get_leg_context_iv_name('JURISDICTION_CODE', l_leg_code,
                                           g_jur_name, l_found);
    --
    if (l_found = FALSE) then
       g_jur_name := 'Jurisdiction';
    end if;
    --
    pay_core_utils.get_upgrade_status(l_bus_grp,
                                      'RR_SPARSE_JC',
                                      l_status);
    if (upper(l_status)='Y') then
       l_found := FALSE;
    else
       l_found := TRUE;
    end if;
    --
    g_leg_code_cached := TRUE;
  --
  end if;
--
  open c_get_aas(p_assignment_id);
  loop
    --
    fetch c_get_aas
      bulk collect into asgt_action_ids, run_dates limit 200;
    --
    if (l_found = TRUE) then
    --
      forall i in 1..asgt_action_ids.COUNT
        delete from pay_run_result_values rrv
        where result_value is null
        and  run_result_id in
             (select rr.run_result_id
              from  pay_run_results rr
              where rr.assignment_action_id = asgt_action_ids(i))
        and  not exists
             (select 1
              from pay_input_values_f iv
              where iv.input_value_id = rrv.input_value_id
              and   run_dates(i) between iv.effective_start_date
                                     and iv.effective_end_date
              and   iv.name = g_jur_name);
    --
    else
    --
      forall i in 1..asgt_action_ids.COUNT
        delete from pay_run_result_values rrv
        where result_value is null
        and  run_result_id in
             (select rr.run_result_id
              from  pay_run_results rr
              where rr.assignment_action_id = asgt_action_ids(i));
    --
    end if;
    --
    exit when c_get_aas%notfound;
    --
  end loop;
  close c_get_aas;
--
end upg_sparse_matrix_rrvs;
--
  /* Name      : qual_sparse_matrix_asg
     Purpose   : This procedure is used to qualify the person for
                 the latest balance upgrade to process groups.
     Arguments :
     Notes     :
  */
procedure qual_latest_bal_pg(p_object_id in            number,
                          p_qualified    out nocopy varchar2
                         )
is
l_dummy varchar2(2);
l_qualifier varchar2(10);
begin
--
   begin
      select ''
        into l_dummy
        from dual
       where exists (select ''
                       from pay_latest_balances plb
                      where plb.person_id = p_object_id
                    );

       l_qualifier := 'Y';
   exception
       when no_data_found then
         l_qualifier := 'N';
   end;
   p_qualified := l_qualifier;
--
end qual_latest_bal_pg;
--
  /* Name      : upgrade_latest_bal_pg
     Purpose   : This performs the upgrade of pay_latest_balances from person to
                 process group
     Arguments :
     Notes     :
  */
Procedure upgrade_latest_bal_pg (p_person_id  IN NUMBER) is

cursor c_process_group_id(p_person_id number) is
       select object_group_id
         from pay_object_groups
         where source_id = p_person_id
         and source_type = 'PPF';

l_process_group_id number;
l_process_group_id2 number;

begin
-- if only 1 process group exists for the person its valid to upgrade the person balance to process group
-- if more than 1 exists then the value isn't valid for any one process group so trash the person balance
open c_process_group_id(p_person_id);
Fetch c_process_group_id into l_process_group_id;
Fetch c_process_group_id into l_process_group_id2;
close c_process_group_id;

-- perform upgrade
if l_process_group_id2 is null then
      update pay_latest_balances
          set process_group_id = l_process_group_id
        where person_id = p_person_id
          and assignment_id is null
          and process_group_id is null
          and defined_balance_id in (
                             select db.defined_balance_id from
                                    pay_balance_dimensions d,
                                    pay_defined_balances db
                              where d.balance_dimension_id = db.balance_dimension_id
                                and d.dimension_type = 'O'
                                and d.dimension_level = 'PG');

  else
      delete from pay_latest_balances
       where assignment_id is null
         and person_id = p_person_id
         and process_group_id is null
         and defined_balance_id in (
             select db.defined_balance_id from pay_balance_dimensions d, pay_defined_balances db
              where d.balance_dimension_id = db.balance_dimension_id
                and d.dimension_type = 'O'
                and d.dimension_level = 'PG');

  end if;

end upgrade_latest_bal_pg;
--
  /* Name      : upg_timedef_baldate
     Purpose   : This procedure is used to qualify the assignment for
                 the time definition and balance date upgrade.
     Arguments :
     Notes     :
  */
procedure qual_timedef_baldate(p_object_id in            number,
                          p_qualified    out nocopy varchar2
                         )
is
l_dummy varchar2(2);
l_qualifier varchar2(10);
begin
--
   begin
      select ''
        into l_dummy
        from dual
       where exists (select ''
                       from pay_payroll_actions ppa,
                            pay_assignment_actions paa
                      where paa.assignment_id = p_object_id
                        and paa.payroll_action_id = ppa.payroll_action_id
                        and action_type in ('R', 'Q', 'B', 'I'));
       l_qualifier := 'Y';
   exception
       when no_data_found then
         l_qualifier := 'N';
   end;
   p_qualified := l_qualifier;
--
end qual_timedef_baldate;
--
  /* Name      : upg_timedef_baldate
     Purpose   : This procedure is used to upgrade the element entries
                 and run results for the time definitions
                 and Balance Dates
     Arguments :
     Notes     :
                 This upgrade is dependant on the EE_PROC_DETAILS
                 upgrade.
  */
procedure upg_timedef_baldate (p_asg_id in number)
is
--
type t_ee_id is table of pay_element_entries_f.element_entry_id%type
                               index by binary_integer;
type t_rr_id is table of pay_run_results.run_result_id%type
                               index by binary_integer;
type t_td_id is table of pay_time_definitions.time_definition_id%type
                               index by binary_integer;
type t_action is table of pay_payroll_actions.action_type%type
                               index by binary_integer;
type date_tab is table of date index by binary_integer;
--
l_ee_tab t_ee_id;
l_std_tab date_tab;
l_end_tab date_tab;
l_action t_action;
l_td_tab t_td_id;
l_rr_tab t_rr_id;
--
cursor get_retro_ee(p_asg_id in number,
                    p_std_time_def_id in number) is
select pee.element_entry_id,
       nvl(pee.source_start_date, ptp.start_date) start_date,
       nvl(pee.source_end_date, ptp.end_date) end_date,
       decode(nvl(p_std_time_def_id, -1),
              -1, null,
              decode(nvl(pet.time_definition_type, 'N'),
                     'S', pet.time_definition_id,
                     'G', p_std_time_def_id,
                     null)
             ) time_definition_id
from pay_element_entries_f pee,
     pay_entry_process_details pepd,
     pay_assignment_actions    paa,
     pay_payroll_actions       ppa,
     per_time_periods          ptp,
     pay_element_types_f       pet
where pee.creator_type in ('RR', 'EE')
and   pee.assignment_id = p_asg_id
and   pee.element_entry_id = pepd.element_entry_id
and   pepd.source_asg_action_id = paa.assignment_action_id
and   paa.payroll_action_id = ppa.payroll_action_id
and   ppa.payroll_id = ptp.payroll_id
and   pet.element_type_id = pepd.source_element_type_id
and   ppa.date_earned between pet.effective_start_date
                          and pet.effective_end_date
and   ppa.date_earned between ptp.start_date
                          and ptp.end_date;
--
cursor get_td_rr (p_asg_id in number,
                  p_std_time_def_id in number)
is
SELECT
        prr.run_result_id,
       decode(nvl(pet.time_definition_type, 'N'),
              'S', pet.time_definition_id,
              'G', p_std_time_def_id,
              null) time_definition_id,
        ppa.action_type
from
     pay_assignment_actions paa,
     pay_payroll_actions    ppa,
     pay_element_types_f    pet,
     pay_run_results        prr
where paa.assignment_id = p_asg_id
and   paa.assignment_action_id = prr.assignment_action_id
and   ppa.payroll_action_id = paa.payroll_action_id
and   ppa.action_type in ('R', 'Q', 'B', 'V', 'I')
and   prr.element_type_id = pet.element_type_id
and   prr.time_definition_id is null
and   ppa.date_earned between pet.effective_start_date
                          and pet.effective_end_date
and   pet.time_definition_type in ('G', 'S')
order by decode(action_type,
                'V', 2,
                 1);
--
l_std_time_def_id pay_time_definitions.time_definition_id%type;
l_bus_grpid       per_business_groups.business_group_id%type;
l_leg_code        per_business_groups.legislation_code%type;
l_complete        pay_upgrade_status.status%type;
--
begin
--
   select distinct pbg.business_group_id,
          pbg.legislation_code
     into l_bus_grpid,
          l_leg_code
     from per_business_groups_perf pbg,
          per_all_assignments_f    paf
    where paf.assignment_id = p_asg_id
      and paf.business_group_id = pbg.business_group_id;
--
   -- We can not do the upgrade unless
   -- a previous upgrade has completed
   -- successfully
--
   pay_core_utils.get_upgrade_status
                   (l_bus_grpid,
                    'EE_PROC_DETAILS',
                    l_complete);

   if (l_complete <> 'Y') then
     pay_core_utils.assert_condition(
             'upg_timedef_baldate:1',
             1 = 2);
   end if;
--
   -- First find out if we need to do a
   -- Time definition upgrade
   begin
--
     select ptd.time_definition_id
       into l_std_time_def_id
       from pay_time_definitions     ptd
      where ptd.short_name = l_leg_code||'_STANDARD';
--
   exception
       when no_data_found then
         l_std_time_def_id := null;
   end;

   if (l_std_time_def_id is not null) then
--
     open get_td_rr(p_asg_id, l_std_time_def_id);
     loop
--
        fetch get_td_rr
          bulk collect into l_rr_tab, l_td_tab, l_action limit 100;
--
        forall i in 1..l_rr_tab.COUNT
           update pay_run_results
              set time_definition_id = l_td_tab(i)
            where run_result_id = l_rr_tab(i);

        forall i in 1..l_rr_tab.COUNT
            update pay_run_results prr
               set prr.start_date = (select pee.date_earned
                                   from pay_element_entries_f pee
                                  where pee.element_entry_id  = prr.source_id
                                ),
                   prr.end_date = (select pee.date_earned
                                   from pay_element_entries_f pee
                                  where pee.element_entry_id  = prr.source_id
                                )
             where prr.run_result_id = l_rr_tab(i)
               and exists (select ''
                             from pay_element_entries_f pee
                            where pee.element_entry_id = prr.source_id
                              and pee.date_earned is not null)
               and prr.start_date is null
               and l_action(i) <> 'V';
--
        forall i in 1..l_rr_tab.COUNT
            update pay_run_results prr
               set prr.start_date = (select prr.start_date
                                   from pay_run_results prr2
                                  where prr2.run_result_id  = prr.source_id
                                ),
                   prr.end_date = (select prr.end_date
                                   from pay_run_results prr2
                                  where prr2.run_result_id  = prr.source_id
                                )
             where prr.run_result_id = l_rr_tab(i)
               and exists (select ''
                             from pay_run_results prr2
                            where prr2.run_result_id = prr.source_id
                              and prr2.start_date is not null)
               and prr.start_date is null
               and l_action(i) = 'V';
--

--
        exit when get_td_rr%notfound;
--
     end loop;
     close get_td_rr;
--
   end if;
--
   -- Now upgrade the Retropay Results
--
   open get_retro_ee(p_asg_id, l_std_time_def_id);
   loop
--
     fetch get_retro_ee
      bulk collect into l_ee_tab,
                        l_std_tab,
                        l_end_tab,
                        l_td_tab limit 100;
--
     forall i in 1..l_ee_tab.COUNT
        update pay_element_entries_f
           set source_start_date = l_std_tab(i),
               source_end_date = l_end_tab(i)
         where element_entry_id = l_ee_tab(i);
--
     -- Only upgrade the time definition if the
     -- legislation has enabled the Standard upgrade
--
     if (l_std_time_def_id is not null) then
--
        forall i in 1..l_ee_tab.COUNT
          update pay_entry_process_details
             set time_definition_id = l_td_tab(i)
           where element_entry_id = l_ee_tab(i);
--
     end if;
--
--
     forall i in 1..l_ee_tab.COUNT
       update pay_run_results
          set start_date = l_std_tab(i),
              end_date   = l_end_tab(i),
              time_definition_id = l_td_tab(i)
        where source_id = l_ee_tab(i)
          and source_type in ('E', 'I');
--
--
     forall i in 1..l_ee_tab.COUNT
       update pay_run_results prr
          set prr.start_date = l_std_tab(i),
              prr.end_date   = l_end_tab(i),
              prr.time_definition_id = l_td_tab(i)
        where prr.source_id in (select prr1.run_result_id
                                  from pay_run_results prr1
                                 where prr1.source_id = l_ee_tab(i)
                                   and prr1.source_type in ('E', 'I')
                               )
          and prr.source_type in ('R', 'V');
--
     exit when get_retro_ee%notfound;
--
   end loop;
   close get_retro_ee;
--
end upg_timedef_baldate;
--
  /* Name      : qual_remove_appl_alus
     Purpose   : This procedure is used to qualify an assignment for the
                 REMOVE_APPL_ALUS data upgrade.
     Arguments :
     Notes     :
  */
procedure qual_remove_appl_alus(p_object_id in            number,
                            p_qualified    out nocopy varchar2
                           )
is
l_dummy varchar2(2);
l_qualifier varchar2(10);
begin
--
   begin
      -- An assignment is qualified if it has a non-null people group id
      select ''
        into l_dummy
        from dual
       where exists (select ''
                       from per_all_assignments_f asg
                      where asg.assignment_id = p_object_id
                        and asg.people_group_id is not null
                        and asg.assignment_type in ('A','O'));
       l_qualifier := 'Y';
   exception
       when no_data_found then
         l_qualifier := 'N';
   end;
   p_qualified := l_qualifier;
--
end qual_remove_appl_alus;
--
  /* Name      : remove_appl_alus
     Purpose   : This procedure removes all ALUs from applicant assignments.
     Arguments :
     Notes     :
  */
procedure remove_appl_alus (p_assignment_id in number)
is
  --
  type t_alu_table_rec is record (
    alu_id               dbms_sql.number_table,
    effective_start_date dbms_sql.date_table
  );
  --
  cursor csr_asg (p_asg_id number) is
  select asg.assignment_type,
         asg.effective_start_date,
         asg.effective_end_date
  from per_all_assignments_f asg
  where asg.assignment_id = p_asg_id
  order by asg.effective_start_date;
  --
  cursor csr_alu (p_asg_id number,
                  p_asg_effective_start_date date,
                  p_asg_effective_end_date date) is
  select alu.assignment_link_usage_id,
         alu.effective_start_date,
         alu.effective_end_date
  from pay_assignment_link_usages_f alu
  where alu.assignment_id = p_asg_id
  and alu.effective_start_date <= p_asg_effective_end_date
  and alu.effective_end_date >= p_asg_effective_start_date;
  --
  r_this_asg csr_asg%rowtype;
  r_next_asg csr_asg%rowtype;
  --
  -- We do bulk updates/deletes of ALUs
  --
  l_alu_update_table t_alu_table_rec;
  l_alu_delete_table t_alu_table_rec;
  l_update_counter number := 1;
  l_delete_counter number := 1;
  --
begin
  --
  -- Delete all assigment link usages where no part of the parent assignment
  -- is a non-applicant assignment (i.e. the entire assignment is for an
  -- applicant).
  --
  delete pay_assignment_link_usages_f alu
  where not exists (
    select null
    from per_all_assignments_f asg
    where asg.assignment_id = alu.assignment_id
    and asg.assignment_type not in ('A','O')
  )
  and alu.assignment_id = p_assignment_id;
  --
  -- Now, all that remains is to either -
  -- 1. Move assignment link usages that span applicant assignments, so that
  --    they no longer do so, i.e.
  --
  --                      'O'           'A'               'E'
  --    ASG        |--------------|-------------|----------------------->
  --    ALU (old)  |---------------------------------------------------->
  --    ALU (new)                               |----------------------->
  --
  --   We assume that only the ALU effective_start_date will require updating.
  --
  -- 2. Delete any ALUs that exist purely for applicant assignment pieces
  --    (this situation is unlikely, but possible, so we do cater for it) i.e.
  --
  --                     'A'                       'E'
  --    ASG        |--------------|------------------------------------->
  --    ALU (old)  |--------------|
  --
  open csr_asg(p_assignment_id);
  fetch csr_asg into r_this_asg;
  --
  -- Look at all applicant assignment pieces (assignment_type = 'A' or 'O')
  --
  while csr_asg%found
  and   (   r_this_asg.assignment_type = 'A'
         or r_this_asg.assignment_type = 'O') loop
    --
    -- Look ahead at 'next' assignment piece
    --
    fetch csr_asg into r_next_asg;
    --
    -- Loop through all ALUs that span 'this' assignment piece
    --
    for r_alu in
      csr_alu(p_assignment_id,
              r_this_asg.effective_start_date,
              r_this_asg.effective_end_date) loop
      --
      -- Either the ALU spans the next assignment piece or it doesn't.
      -- + If it *does* span the next assignment piece, then update this ALU's
      --   start date to the start date of the next assignment piece.
      -- + If it doesn't span the next assignment piece, then delete it. It's
      --   possible (although unlikely) that the ALU only exists for the
      --   applicant part of the assignment.
      --
      if  csr_asg%found
      and r_alu.effective_end_date >= r_next_asg.effective_start_date then
        --
        -- Update this ALU's start date to the start date of the next
        -- assignment piece
        --
        l_alu_update_table.alu_id(l_update_counter) :=
          r_alu.assignment_link_usage_id;
        l_alu_update_table.effective_start_date(l_update_counter) :=
          r_next_asg.effective_start_date;
        l_update_counter := l_update_counter + 1;
        --
      else
        --
        -- No other assignment pieces found, or ALU does not span the next
        -- assignment piece. Either way this ALU must be entirely contained
        -- within applicant assignment pieces, so we can delete it.
        --
        l_alu_delete_table.alu_id(l_delete_counter) :=
          r_alu.assignment_link_usage_id;
        l_alu_delete_table.effective_start_date(l_delete_counter) :=
          r_alu.effective_start_date;
        l_delete_counter := l_delete_counter + 1;
        --
      end if;
      --
    end loop;
    --
    if l_alu_update_table.alu_id.count > 0 then
      --
      -- Do bulk update of ALU start dates
      --
      forall i in 1 .. l_alu_update_table.alu_id.count
        update pay_assignment_link_usages_f
        set effective_start_date = l_alu_update_table.effective_start_date(i)
        where assignment_link_usage_id = l_alu_update_table.alu_id(i);
      --
    end if;
    --
    if l_alu_delete_table.alu_id.count > 0 then
      --
      -- Do bulk delete of ALUs that only belong to applicant assignments
      --
      forall i in 1 .. l_alu_delete_table.alu_id.count
        delete pay_assignment_link_usages_f
        where assignment_link_usage_id = l_alu_delete_table.alu_id(i)
        and effective_start_date = l_alu_delete_table.effective_start_date(i);
      --
    end if;
    --
    -- Reset counters and flush update/delete tables
    --
    l_update_counter := 1;
    l_delete_counter := 1;
    --
    l_alu_update_table.alu_id.delete;
    l_alu_update_table.effective_start_date.delete;
    --
    l_alu_delete_table.alu_id.delete;
    l_alu_delete_table.effective_start_date.delete;
    --
    -- Get next assignment piece and repeat
    --
    r_this_asg := r_next_asg;
    --
  end loop;
  --
  close csr_asg;
  --
end remove_appl_alus;
--
END pay_core_upgrade_pkg;

/
