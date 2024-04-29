--------------------------------------------------------
--  DDL for Package Body PY_ROLLBACK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PY_ROLLBACK_PKG" AS
/* $Header: pyrolbak.pkb 120.27.12010000.3 2008/11/26 06:59:46 priupadh ship $ */
/*------------- Payroll and Assignment Action Details ----------------*/
type rollback_rec is record
(
   -- Payroll Action Level Details.
   pact_id                  pay_payroll_actions.payroll_action_id%type,
   action_name              hr_lookups.meaning%type,
   action_type              pay_payroll_actions.action_type%type,
   action_status            pay_payroll_actions.action_status%type,
   sequenced_flag           boolean,
   action_date              date,
   action_start_date        date,
   current_date             date,  -- holds sysdate.
   payroll_name             pay_all_payrolls_f.payroll_name%type,
   bg_name                  hr_organization_units.name%type,
   bg_id                    hr_organization_units.business_group_id%type,
   independent_periods_flag pay_legislation_rules.rule_mode%type,
   date_earned              date,
   purge_phase              pay_payroll_actions.purge_phase%type,
   object_type              pay_assignment_actions.object_type%type,
   retro_definition_id      pay_payroll_actions.retro_definition_id%type,
   batch_id                 pay_payroll_actions.batch_id%type,
--
   -- Assignment Action Level Details.
   assact_id                pay_assignment_actions.assignment_action_id%type,
   assignment_id            per_all_assignments_f.assignment_id%type,
   full_name                per_all_people_f.full_name%type,
   assignment_number        per_all_assignments_f.assignment_number%type,
   payroll_id               pay_all_payrolls_f.payroll_id%type,
--
   -- Other information.
   legislation_code         varchar2(2),
   rollback_mode            varchar2(20),   -- 'ROLLBACK', 'RETRY', 'BACKPAY'.
   rollback_level           varchar2(1),    -- 'A' (assact) or 'P' (pact).
   leave_row                boolean,        -- i.e. leave_base_table_row.
   all_or_nothing           boolean,
   multi_thread             boolean,
   grp_multi_thread         boolean,
   dml_mode                 varchar2(10),   -- 'NONE', 'PARTIAL, 'FULL'.
   max_errors_allowed       number,
   max_single_undo          number,
   limit_dml                boolean,
   retro_purge              pay_action_parameters.parameter_value%type,
   single_bal_table         pay_action_parameters.parameter_value%type,
   set_date_earned          pay_action_parameters.parameter_value%type,
   sub_ledger_acc           pay_action_parameters.parameter_value%type
);
--
--  Data structure to hold information on next range.
type range_rec is record
(
   chunk_number    number,
   starting_person number,
   ending_person   number
);
--
g_error_count  number;
g_debug boolean := hr_utility.debug_enabled;
--
-- cache variables
mtgl_mode pay_action_parameters.parameter_value%type;
mtgl_mode_cached boolean := false;
--
-- The End of Time.
c_eot constant date := to_date('31/12/4712', 'DD/MM/YYYY');
--
--
/*
 *  Get the value of the specified legislation_rule.
 *  If no value is set on the database, it obtains
 *  the relevant default value.
 */
function legislation_rule(p_leg_code in varchar2,
                          p_rule_name in varchar2)
return varchar2 is
l_rule_value pay_legislation_rules.rule_mode%type;
begin
--
   begin
--
     select rule_mode
       into l_rule_value
       from pay_legislation_rules
      where legislation_code = p_leg_code
        and rule_type = p_rule_name;
--
   exception
      when no_data_found then
--
        if (p_rule_name = 'RETRO_DELETE') then
           l_rule_value := 'Y';
        else
           l_rule_value := null;
        end if;
   end;
--
   return l_rule_value;
--
end legislation_rule;
--
/*
 *  Get the value of the specified action parameter.
 *  If no value is set on the database, it obtains
 *  the relevant default value.
 */
function action_parameter(p_param_name in varchar2)
return varchar2 is
   l_name      pay_action_parameters.parameter_name%type;
   param_value pay_action_parameters.parameter_value%type;
   c_indent constant varchar2(40) := 'py_rollback_pkg.action_parameter';
   l_found boolean;
begin
      --  Attempt to find value of the parameter
      --  in the action parameter table.
  pay_core_utils.get_action_parameter(p_param_name, param_value, l_found   );

  if l_found=FALSE then
      if(replace(p_param_name,' ','_') = 'CHUNK_SIZE') then
         param_value := 20;
      elsif(replace(p_param_name,' ','_') = 'MAX_SINGLE_UNDO') then
         param_value := 50;
      elsif(replace(p_param_name,' ','_') = 'MAX_ERRORS_ALLOWED') then
         --  If we can't get the max errors allowed, we
         --  default to chunk_size - make recursive call
         --  to get this value.
         param_value := action_parameter('CHUNK_SIZE');
      elsif(replace(p_param_name,' ','_') = 'SET_DATE_EARNED') then
         param_value := 'N';
      end if;
  end if;
--
  return(param_value);
--
end action_parameter;
--
procedure remove_pact_payment(p_pactid in number)
is
cursor get_payment(p_pact in number)
is
select pre_payment_id
  from pay_pre_payments
 where payroll_action_id = p_pact;
begin
--
   for payrec in get_payment(p_pactid) loop
--
    update pay_contributing_payments
       set pre_payment_id = null
     where pre_payment_id = payrec.pre_payment_id;
    delete from pay_pre_payments
     where pre_payment_id = payrec.pre_payment_id;
--
   end loop;
--
end remove_pact_payment;
--
procedure remove_action_information(
                         p_action_context_id   in number,
                         p_action_context_type in varchar2 default 'AAP')
is
   c_indent constant varchar2(100) := 'py_rollback_pkg.remove_action_information';
--
   cursor actionitems (cp_action_context_id   in number,
                       cp_action_context_type in varchar2) is
   select action_information_id
     from pay_action_information
    where action_context_id = cp_action_context_id
      and action_context_type = cp_action_context_type;
--
begin
     for actionrec in actionitems(p_action_context_id,
                                  p_action_context_type) loop

         /* delete Action Information */
         delete from pay_action_information
          where action_information_id = actionrec.action_information_id;

     end loop;
end remove_action_information;


procedure remove_archive_items(p_info      in rollback_rec,
                               p_source_id in number,
                               p_archive_type in varchar2 default 'AAP')
is
   c_indent constant varchar2(40) := 'py_rollback_pkg.remove_archive_items';
--
   cursor architems (p_source number, p_archive_type varchar2) is
   select archive_item_id
     from ff_archive_items
    where context1 = p_source
      and nvl(archive_type, 'AAP') = p_archive_type;
--
begin
--
   for arcrec in architems(p_source_id, p_archive_type) loop
--
--    delete archive item contexts.
      delete from ff_archive_item_contexts
      where archive_item_id = arcrec.archive_item_id;
--
--    delete the archive items.
      delete from ff_archive_items
      where archive_item_id = arcrec.archive_item_id;
   end loop;
end;
--
procedure remove_file_details(p_info      in rollback_rec,
                              p_source_id in number,
                              p_source_type in varchar2 default 'PAA')
is
   c_indent constant varchar2(40) := 'py_rollback_pkg.remove_file_details';
--
begin
--
   delete from pay_file_details
    where source_id = p_source_id
      and source_type = p_source_type;
--
end;
--
/*
 *  Procedure to remove all retropay elements and element
 *  values for the specified assignment action.
 */
procedure remove_retro_ee(p_assact_id in number) is
   c_indent varchar2(40);
   cursor ceev is
   select pee.element_entry_id
     from pay_element_entries_f pee,
          pay_assignment_actions paa
    where paa.assignment_action_id = p_assact_id
      and pee.assignment_id        = paa.assignment_id
      and pee.creator_id           = paa.assignment_action_id
      and pee.creator_type         = 'P';
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_retro_ee';
      hr_utility.set_location(c_indent,10);
   end if;
   --
   /* Delete the entry values before the element entry */
   for ceevrec in ceev loop
       delete from pay_element_entry_values_f pev
       where element_entry_id = ceevrec.element_entry_id;
       --
       delete from pay_element_entries_f
       where creator_id   = p_assact_id
       and   creator_type = 'P'
       and element_entry_id = ceevrec.element_entry_id;
   end loop;
   --
   if g_debug then
      hr_utility.set_location(c_indent,20);
   end if;
end remove_retro_ee;
--
/*
 *  Procedure to remove all Advance pay elements and element
 *  values for the specified assignment action.
 */
procedure remove_adv_ee(p_assact_id in number) is
   c_indent varchar2(40);
   cursor aeev is
   select pee.element_entry_id
     from pay_element_entries_f pee,
          pay_assignment_actions paa
    where paa.assignment_action_id = p_assact_id
      and pee.assignment_id        = paa.assignment_id
      and pee.creator_id           = paa.assignment_action_id
      and pee.creator_type         = 'D';
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_adv_ee';
      hr_utility.set_location(c_indent,10);
   end if;
   --
   /* Delete the entry values before the element entry */
   for aeevrec in aeev loop
       delete from pay_element_entry_values_f pev
       where element_entry_id = aeevrec.element_entry_id;
       --
       delete from pay_element_entries_f
       where creator_id   = p_assact_id
       and   creator_type = 'D'
       and element_entry_id = aeevrec.element_entry_id;
   end loop;
   --
   if g_debug then
      hr_utility.set_location(c_indent,20);
   end if;
end remove_adv_ee;
--
-- Procedure to remove advance pay by element entries.
--
procedure remove_advpayele_ee(p_assact_id in number) is
   c_indent varchar2(40);
   cursor aeev is
   select pee.element_entry_id
     from pay_element_entries_f pee,
          pay_assignment_actions paa
    where paa.assignment_action_id = p_assact_id
      and pee.assignment_id        = paa.assignment_id
      and pee.creator_id           = paa.assignment_action_id
      and pee.creator_type         in ('AD', 'AE','D');
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_advpayele_ee';
      hr_utility.set_location(c_indent,10);
   end if;
   --
   /* Delete the entry values before the element entry */
   for aeevrec in aeev loop
       delete from pay_element_entry_values_f pev
       where element_entry_id = aeevrec.element_entry_id;
       --
       delete from pay_element_entries_f
       where creator_id   = p_assact_id
       and   creator_type in ('AD', 'AE','D')
       and   element_entry_id = aeevrec.element_entry_id;
   end loop;
   --
   if g_debug then
      hr_utility.set_location(c_indent,20);
   end if;
end remove_advpayele_ee;
--
-- Procedure to remove retropay by action entries.
procedure remove_retroact_ee(p_assact_id in number) is
   c_indent varchar2(40);
   cursor raeev is
   select pee.element_entry_id
     from pay_element_entries_f pee,
          pay_assignment_actions paa
    where paa.assignment_action_id = p_assact_id
      and pee.assignment_id        = paa.assignment_id
      and pee.creator_id           = paa.assignment_action_id
      and pee.creator_type         = 'R';
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_retroact_ee';
      hr_utility.set_location(c_indent,10);
   end if;
   --
   /* Delete the entry values before the element entry */
   for raeevrec in raeev loop
       delete from pay_element_entry_values_f pev
       where element_entry_id = raeevrec.element_entry_id;
       --
       delete from pay_element_entries_f
       where creator_id   = p_assact_id
       and   creator_type = 'R'
       and element_entry_id = raeevrec.element_entry_id;
   end loop;
   --
   if g_debug then
      hr_utility.set_location(c_indent,20);
   end if;
end remove_retroact_ee;
--
-- Procedure to remove retropay by element_entries.
procedure remove_retroele_ee(p_assact_id in number,
                             p_rollback_mode in varchar2) is
   c_indent varchar2(40);
   cursor remove_eev is
   select pee.element_entry_id
     from pay_element_entries_f pee,
          pay_assignment_actions paa
    where paa.assignment_action_id = p_assact_id
      and pee.creator_id           = paa.assignment_action_id
      and pee.creator_type         in ('RR', 'EE', 'NR', 'PR') ;
--
   l_reprocess_date  date;
--
  cursor min_reprocess_date is
  select min(pre.reprocess_date)
    from pay_retro_entries pre,
         pay_retro_assignments pra
   where pre.retro_assignment_id = pra.retro_assignment_id
     and pra.retro_assignment_action_id = p_assact_id;
--
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_retroele_ee';
      hr_utility.set_location(c_indent,10);
   end if;
   --
   /* Delete the entry values before the element entry */
   for eev_rec in remove_eev loop
       delete from pay_element_entry_values_f pev
       where element_entry_id = eev_rec.element_entry_id;
       --
       delete from pay_entry_process_details
       where  element_entry_id = eev_rec.element_entry_id;
       --
       delete from pay_element_entries_f
       where creator_id   = p_assact_id
       and   creator_type in ('RR', 'EE', 'NR', 'PR')
       and element_entry_id = eev_rec.element_entry_id;
   end loop;
--
   hr_utility.set_location(c_indent,20);
   -- Finally reset the pay_retro_assignment_table if needed
   if (p_rollback_mode <> 'RETRY') then
--
   pay_retro_pkg.merge_retro_assignments(p_assact_id);
--
   hr_utility.set_location(c_indent,30);
   -- Remove or reset row on pay_recorded_requests
   --
   hr_utility.set_location(c_indent,40);
   pay_retro_pkg.reset_recorded_request(p_assact_id);
   hr_utility.set_location(c_indent,50);
   --
   -- Remove the asg act id, and in case merge has new earlier entries
   -- also change the reprocess_date
   open min_reprocess_date;
   fetch min_reprocess_date into l_reprocess_date;
   close min_reprocess_date;
   --
   update pay_retro_assignments  ra
      set ra.retro_assignment_action_id = null,
          ra.reprocess_date = nvl(l_reprocess_date,ra.reprocess_date)
    where ra.retro_assignment_action_id = p_assact_id;

   end if;
--
   if g_debug then
      hr_utility.set_location(c_indent,20);
   end if;
--
end remove_retroele_ee;
--
/*
 *  Procedure to delete entries from gl_interface tables.
 */
procedure remove_gl_entries(p_info in rollback_rec) is
   c_indent varchar2(40);
   l_source_name gl_interface.user_je_source_name%type;
--
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_gl_entries';
      hr_utility.set_location(c_indent, 10);
   end if;
   --
   if mtgl_mode_cached = FALSE then
       if g_debug then
          hr_utility.set_location(c_indent, 20);
       end if;
       begin
          select upper(parameter_value)
          into mtgl_mode
          from pay_action_parameters
          where parameter_name = 'TRANSGL_THREAD';
       exception
           when others then
              mtgl_mode := 'Y';
       end;
   --
       if g_debug then
          hr_utility.set_location(c_indent, 30);
       end if;
       -- Remove transfer table rows once only
       -- first of all get source_name
       select user_je_source_name
       into l_source_name
       from gl_je_sources
       where je_source_name = 'Payroll';
--
       if g_debug then
          hr_utility.set_location(c_indent, 35);
       end if;
       delete from gl_interface gl
       where  gl.reference21 = to_char(p_info.pact_id)
       and    gl.user_je_source_name = l_source_name;
--
       mtgl_mode_cached := TRUE;
    end if;
--
    if mtgl_mode <> 'N' then
       -- Remove intermediate transfer table rows
       -- for multi-threaded transfer to GL only
       if g_debug then
          hr_utility.set_location(c_indent, 40);
       end if;
       delete from pay_gl_interface pgl
       where  pgl.assignment_action_id = p_info.assact_id;
    end if;
--
end remove_gl_entries;
--
/*
 *  Procedure to reset the prenote date for magnetic tape
 *  rollback.
 */
procedure reset_prenote(p_assact_id in number) is
  cursor get_accnts_to_reset(asgact in number) is
   select pea.external_account_id
     from pay_external_accounts          pea,
          pay_payment_types              ppt,
          pay_personal_payment_methods_f ppm,
          pay_org_payment_methods_f      opm,
          pay_pre_payments               ppp,
          pay_payroll_actions            ppa,
          pay_assignment_actions         paa
    where paa.assignment_action_id       = asgact
    and   paa.payroll_action_id          = ppa.payroll_action_id
    and   paa.pre_payment_id             = ppp.pre_payment_id
    and   ppp.org_payment_method_id      = opm.org_payment_method_id
    and   ppp.personal_payment_method_id = ppm.personal_payment_method_id
    and   opm.payment_type_id            = ppt.payment_type_id
    and   ppt.pre_validation_required    = 'Y'
    and   ppt.validation_value           = ppp.value
    and   ppm.external_account_id        = pea.external_account_id
    and   ppa.effective_date between ppm.effective_start_date
                                 and ppm.effective_end_date
    and   ppa.effective_date between opm.effective_start_date
                                 and opm.effective_end_date;
begin
   for eacrec in get_accnts_to_reset(p_assact_id) loop
      update pay_external_accounts
         set prenote_date = null
       where external_account_id = eacrec.external_account_id
       and   prenote_date is not null;
   end loop;
end reset_prenote;
--
/*
 *  Procedure to remove all run results and run result
 *  values for the specified assignment action.
 */
procedure remove_run_results(p_info in rollback_rec) is
   c_indent varchar2(40);
   purge_rr boolean;
   cursor crrv is
   select prr.run_result_id
   from   pay_run_results       prr
   where  prr.assignment_action_id = p_info.assact_id;
begin
   -- Delete any run results and values created by
   -- this action. There is no cascade trigger on
   -- run results, so we are forced to do both.
   -- We use a cursor loop here to avoid a full table
   -- scan that occurs when you attempt to use a single
   -- delete statement.
   -- Tight loop, so the set_location call set outside it.
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_run_results';
      hr_utility.set_location(c_indent,10);
   end if;
--
   purge_rr := TRUE;
   if (p_info.rollback_mode = 'BACKPAY'
     and p_info.retro_purge = 'N') then
--
     purge_rr := FALSE;
--
   end if;
--
   if (purge_rr = TRUE) then
     for crrvrec in crrv loop
        delete from pay_run_result_values rrv
        where  rrv.run_result_id = crrvrec.run_result_id;
     end loop;
--
     if g_debug then
        hr_utility.set_location(c_indent,30);
     end if;
     delete from pay_run_results RR
     where  RR.assignment_action_id = p_info.assact_id;
--
   else
--
     if g_debug then
        hr_utility.set_location(c_indent,40);
     end if;
     -- It must be a backpay.
     update pay_run_results RR
        set RR.status = 'B'
      where RR.assignment_action_id = p_info.assact_id;
   end if;
end remove_run_results;
--
/*
 *  Procedure to remove all action contexts.
 */
procedure remove_action_contexts(p_assact_id in number) is
   c_indent varchar2(40);
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.remove_action_contexts';
      hr_utility.set_location(c_indent,10);
   end if;
--
   delete from pay_action_contexts
    where assignment_action_id = p_assact_id;
--
   if g_debug then
      hr_utility.set_location(c_indent,30);
   end if;
end remove_action_contexts;
--
/*
 *  Deletes all latest balances and associated balance
 *  context values for the specified assignment action id.
 *  balances are only removed if a prev balance does not exist,
 *  other wise the prev blance is assigned to the latest balance
 *
 *  Deletes all latest balances if the action before rolled back is a
 *  balance adjustment or a balance initialisation.  This is because as
 *  these are 'special' types of sequenced actions, their results may
 *  have fed the balances without the latest balances being owned by them.
 */

procedure remove_balances(p_info in rollback_rec) is
   c_indent varchar2(40);
   cursor baplb(l_person_id number) is
--
   select /*+ INDEX(plb PAY_PERSON_LATEST_BALANCES_N3)*/
          plb.latest_balance_id,
          plb.prev_balance_value,
          plb.prev_assignment_action_id,
          plb.expired_value,
          plb.expired_assignment_action_id,
          plb.assignment_action_id
   from   pay_person_latest_balances plb,
          pay_defined_balances  pdb,
          pay_balance_feeds_f   pbf,
          pay_run_result_values rrv,
          pay_run_results       prr
   where prr.assignment_action_id = p_info.assact_id
   and   rrv.run_result_id        = prr.run_result_id
   and   rrv.result_value is not null
   and   pbf.input_value_id       = rrv.input_value_id
   and   pdb.balance_type_id      = pbf.balance_type_id
   and   plb.defined_balance_id   = pdb.defined_balance_id
   and   plb.person_id            = l_person_id
   and   p_info.action_date between pbf.effective_start_date
                                and pbf.effective_end_date;
--
   cursor baalb is
   select /*+ INDEX(alb PAY_ASSIGNMENT_LATEST_BALA_N3)*/
          alb.latest_balance_id,
          alb.prev_balance_value,
          alb.prev_assignment_action_id,
          alb.expired_value,
          alb.expired_assignment_action_id,
          alb.assignment_action_id
   from   pay_assignment_latest_balances alb,
          pay_defined_balances  pdb,
          pay_balance_feeds_f   pbf,
          pay_run_result_values rrv,
          pay_run_results       prr
   where prr.assignment_action_id = p_info.assact_id
   and   rrv.run_result_id        = prr.run_result_id
   and   rrv.result_value is not null
   and   pbf.input_value_id       = rrv.input_value_id
   and   pdb.balance_type_id      = pbf.balance_type_id
   and   alb.defined_balance_id   = pdb.defined_balance_id
   and   alb.assignment_id        = p_info.assignment_id
   and   p_info.action_date between pbf.effective_start_date
                                and pbf.effective_end_date;
--
   cursor balb (l_person_id number)is
   select
          lb.latest_balance_id,
          lb.prev_balance_value,
          lb.prev_assignment_action_id,
          lb.prev_expiry_date,
          lb.expired_value,
          lb.expired_assignment_action_id,
          lb.assignment_action_id
   from   pay_latest_balances   lb,
          pay_defined_balances  pdb,
          pay_balance_feeds_f   pbf,
          pay_run_result_values rrv,
          pay_run_results       prr
   where prr.assignment_action_id = p_info.assact_id
   and   rrv.run_result_id        = prr.run_result_id
   and   rrv.result_value is not null
   and   pbf.input_value_id       = rrv.input_value_id
   and   pdb.balance_type_id      = pbf.balance_type_id
   and   lb.defined_balance_id    = pdb.defined_balance_id
   and   lb.person_id             = l_person_id
   and    (   lb.assignment_id         = p_info.assignment_id
           or lb.assignment_id is null)
   and    (   lb.process_group_id   = (select distinct pog.parent_object_group_id
                                         from pay_object_groups pog
                                        where pog.source_id = p_info.assignment_id
                                          and pog.source_type = 'PAF')
           or lb.process_group_id is null)
   and   p_info.action_date between pbf.effective_start_date
                                and pbf.effective_end_date;
--
   cursor cplb is
   select plb.latest_balance_id,
          plb.prev_balance_value,
          plb.prev_assignment_action_id,
          plb.expired_value,
          plb.expired_assignment_action_id
   from   pay_person_latest_balances plb
   where  plb.assignment_action_id = p_info.assact_id;
--
   cursor calb is
   select alb.latest_balance_id,
          alb.prev_balance_value,
          alb.prev_assignment_action_id,
          alb.expired_value,
          alb.expired_assignment_action_id
   from   pay_assignment_latest_balances alb
   where  alb.assignment_action_id = p_info.assact_id;
--
   cursor clb is
   select lb.latest_balance_id,
          lb.prev_balance_value,
          lb.prev_assignment_action_id,
          lb.prev_expiry_date,
          lb.expired_value,
          lb.expired_assignment_action_id
   from   pay_latest_balances lb
   where  lb.assignment_action_id = p_info.assact_id;
--
   l_person_id          per_all_assignments_f.person_id%TYPE;

begin
    -- Remove latest balances and associated context values.
    -- Delete cascade not used because a) efficiency and
    -- b) must delete for both rollback and mark for retry.
    -- Cursor loops used to avoid full table access of
    -- the balance context table.

    if g_debug then
       c_indent := 'py_rollback_pkg.remove_balances';
       hr_utility.set_location(c_indent,10);
    end if;
    if (p_info.action_type in ('B', 'I', 'V')) then
       -- treat balance adjustment as a special case : we should
       -- delete all latest balances for an assignment if its having
       -- a balance adjustment being rolled back (because its very
       -- difficult to work out which if any of the latest, previous
       -- or expired balances were fed by the balance adjustment)
       -- And Reversals now too!

       select person_id
       into l_person_id
       from per_all_assignments_f
       where assignment_id = p_info.assignment_id
       and   p_info.action_date between
             effective_start_date and effective_end_date;

       if g_debug then
          hr_utility.set_location(c_indent,15);
       end if;

       if (p_info.single_bal_table <> 'Y') then

         for bplbrec in baplb(l_person_id) loop
            if bplbrec.assignment_action_id = p_info.assact_id then
               if bplbrec.prev_balance_value=-9999
               or bplbrec.prev_balance_value is NULL
               or bplbrec.prev_assignment_action_id is NULL
               then
                  delete from pay_balance_context_values bcv
                  where  bcv.latest_balance_id = bplbrec.latest_balance_id;

                  delete from pay_person_latest_balances plb
                  where plb.latest_balance_id = bplbrec.latest_balance_id;
               else
                  if bplbrec.prev_assignment_action_id = bplbrec.expired_assignment_action_id
                  then
                     update pay_person_latest_balances
                     set expired_assignment_action_id = -9999,
                         expired_value = -9999
                     where pay_person_latest_balances.latest_balance_id =
                                          bplbrec.latest_balance_id;
                  end if;
                  update pay_person_latest_balances
                  set assignment_action_id = bplbrec.prev_assignment_action_id,
                      value = bplbrec.prev_balance_value,
                      prev_assignment_action_id = -9999,
                      prev_balance_value = -9999
                  where pay_person_latest_balances.latest_balance_id =
                                          bplbrec.latest_balance_id;
               end if;
            else
               delete from pay_balance_context_values bcv
               where  bcv.latest_balance_id = bplbrec.latest_balance_id;

               delete from pay_person_latest_balances plb
               where plb.latest_balance_id = bplbrec.latest_balance_id;
            end if;
         end loop;

         for balbrec in baalb loop
            if balbrec.assignment_action_id = p_info.assact_id then
               if balbrec.prev_balance_value=-9999
               or balbrec.prev_balance_value is NULL
               or balbrec.prev_assignment_action_id is NULL
               then
                  delete from pay_balance_context_values bcv
                  where  bcv.latest_balance_id = balbrec.latest_balance_id;

                  delete from pay_assignment_latest_balances alb
                  where alb.latest_balance_id = balbrec.latest_balance_id;
               else
                  if balbrec.prev_assignment_action_id = balbrec.expired_assignment_action_id
                  then
                     update pay_assignment_latest_balances
                     set expired_assignment_action_id = -9999,
                         expired_value = -9999
                     where pay_assignment_latest_balances.latest_balance_id =
                                          balbrec.latest_balance_id;
                  end if;
                  update pay_assignment_latest_balances
                  set assignment_action_id = balbrec.prev_assignment_action_id,
                      value = balbrec.prev_balance_value,
                      prev_assignment_action_id = -9999,
                      prev_balance_value = -9999
                  where pay_assignment_latest_balances.latest_balance_id =
                                          balbrec.latest_balance_id;
               end if;
            else
               delete from pay_balance_context_values bcv
               where  bcv.latest_balance_id = balbrec.latest_balance_id;

               delete from pay_assignment_latest_balances alb
               where alb.latest_balance_id = balbrec.latest_balance_id;
            end if;
         end loop;

       else /* single_bal_table */

         for blbrec in balb(l_person_id) loop
            if blbrec.assignment_action_id = p_info.assact_id then
               if blbrec.prev_balance_value=-9999
               or blbrec.prev_balance_value is NULL
               or blbrec.prev_assignment_action_id is NULL
               then
                  delete from pay_latest_balances lb
                  where lb.latest_balance_id = blbrec.latest_balance_id;
               else
                  if blbrec.prev_assignment_action_id = blbrec.expired_assignment_action_id
                  then
                     update pay_latest_balances
                     set expired_assignment_action_id = -9999,
                         expired_value = -9999,
                         expired_date = null
                     where pay_latest_balances.latest_balance_id =
                                          blbrec.latest_balance_id;
                  end if;
                  update pay_latest_balances
                  set assignment_action_id = blbrec.prev_assignment_action_id,
                      value = blbrec.prev_balance_value,
                      expiry_date = blbrec.prev_expiry_date,
                      prev_assignment_action_id = -9999,
                      prev_balance_value = -9999,
                      prev_expiry_date = null
                  where pay_latest_balances.latest_balance_id =
                                          blbrec.latest_balance_id;
               end if;
            else
               delete from pay_latest_balances alb
               where alb.latest_balance_id = blbrec.latest_balance_id;
            end if;
         end loop;

       end if; /* single_bal_table */

    else
       if g_debug then
          hr_utility.set_location(c_indent,90);
       end if;

       if (p_info.single_bal_table <> 'Y') then

         for calbrec in calb loop
           if (calbrec.prev_balance_value=-9999
               or calbrec.prev_balance_value is NULL
               or calbrec.prev_assignment_action_id is NULL)
           then
           begin
             delete from pay_balance_context_values bcv
             where  bcv.latest_balance_id = calbrec.latest_balance_id;
             delete from pay_assignment_latest_balances alb
             where alb.latest_balance_id=calbrec.latest_balance_id;
           end;
           else
           begin
            if calbrec.prev_assignment_action_id=calbrec.expired_assignment_action_id
            then
              update pay_assignment_latest_balances
              set expired_assignment_action_id=-9999,
                  expired_value=-9999
              where  pay_assignment_latest_balances.latest_balance_id =
                                          calbrec.latest_balance_id;
            end if;
            update pay_assignment_latest_balances
            set assignment_action_id=calbrec.prev_assignment_action_id,
                value=calbrec.prev_balance_value,
                prev_assignment_action_id=-9999,
                prev_balance_value=-9999
          where  pay_assignment_latest_balances.latest_balance_id =
                                          calbrec.latest_balance_id;
           end;
           end if;
         end loop;


         if g_debug then
            hr_utility.set_location(c_indent,100);
         end if;
         for cplbrec in cplb loop
           if (cplbrec.prev_balance_value=-9999 or
               cplbrec.prev_balance_value is NULL or
               cplbrec.prev_assignment_action_id is NULL)
           then
           begin
             delete from pay_balance_context_values bcv
             where  bcv.latest_balance_id = cplbrec.latest_balance_id;
             delete from pay_person_latest_balances plb
             where plb.latest_balance_id=cplbrec.latest_balance_id;
           end;
           else
           begin
            if cplbrec.prev_assignment_action_id=cplbrec.expired_assignment_action_id
            then
              update pay_person_latest_balances
              set expired_assignment_action_id=-9999,
                  expired_value=-9999
              where  pay_person_latest_balances.latest_balance_id =
                                          cplbrec.latest_balance_id;
            end if;
            update pay_person_latest_balances
            set assignment_action_id=cplbrec.prev_assignment_action_id,
                value=cplbrec.prev_balance_value,
                prev_assignment_action_id=-9999,
                 prev_balance_value=-9999
            where  pay_person_latest_balances.latest_balance_id =
                                       cplbrec.latest_balance_id;
           end;
           end if;
         end loop;

       else /* single_bal_table */

          for clbrec in clb loop
            if (clbrec.prev_balance_value=-9999
                or clbrec.prev_balance_value is NULL
                or clbrec.prev_assignment_action_id is NULL)
            then
            begin
              delete from pay_latest_balances lb
              where lb.latest_balance_id=clbrec.latest_balance_id;
            end;
            else
            begin
             if clbrec.prev_assignment_action_id=clbrec.expired_assignment_action_id
             then
               update pay_latest_balances
               set expired_assignment_action_id=-9999,
                   expired_value=-9999,
                   expired_date = null
               where  pay_latest_balances.latest_balance_id =
                                           clbrec.latest_balance_id;
             end if;
             update pay_latest_balances
             set assignment_action_id=clbrec.prev_assignment_action_id,
                 value=clbrec.prev_balance_value,
                 expiry_date = clbrec.prev_expiry_date,
                 prev_assignment_action_id=-9999,
                 prev_balance_value=-9999,
                 prev_expiry_date = null
           where  pay_latest_balances.latest_balance_id =
                                           clbrec.latest_balance_id;
            end;
            end if;
          end loop;

       end if; /* single_bal_table */
    end if;

end remove_balances;
--
/*
 *  Delete all entries and entry values that were inserted
 *  by a balance adjustment.
 *  It is only called for a balance adjustment action.
 */
procedure undo_bal_adjust(p_action_date in date, p_assact_id in number) is
   -- Batch balance adjustment can have many adjustments
   -- for an assignment action.
   cursor c1 is
   select pee.element_entry_id
   from   pay_element_entries_f  pee,
          pay_assignment_actions paa
   where  paa.assignment_action_id = p_assact_id
   and    pee.assignment_id        = paa.assignment_id
   and    pee.creator_id           = paa.assignment_action_id
   and    pee.creator_type         = 'B'  -- (B)alance Adjustment
   and    p_action_date between
          pee.effective_start_date and pee.effective_end_date;
begin
   if g_debug then
      hr_utility.set_location('undo_bal_adjust', 60);
   end if;
   for c1rec in c1 loop
      -- Now, we attempt to delete the entry values.
      delete from pay_element_entry_values_f pev
      where  pev.element_entry_id = c1rec.element_entry_id
      and    p_action_date between
             pev.effective_start_date and pev.effective_end_date;
--
      -- Now we attempt to delete the element entry row.
      -- Note, if this procedure is called from the balance
      -- adjustment form, the form may be attempting to delete
      -- this row. However, this could be called from the
      -- actions form, in which case we do need to do the delete.
      delete from pay_element_entries_f pee
      where  pee.element_entry_id = c1rec.element_entry_id
      and    p_action_date between
             pee.effective_start_date and pee.effective_end_date;
   end loop;
   if g_debug then
      hr_utility.set_location('undo_bal_adjust', 70);
   end if;
--
end undo_bal_adjust;
--
/*
 *  Delete all messages (from pay_message_lines) as specified
 *  by the source_type. in other words:
 *  P : payroll_action_id
 *  A : assignment_action_id
 */
procedure remove_messages(p_info in rollback_rec, p_source_type in varchar2) is
begin
   delete from pay_message_lines pml
   where  pml.source_type = p_source_type
   and    pml.source_id   =
       decode(p_source_type,
                'P', p_info.pact_id,
                'A', p_info.assact_id);
end remove_messages;
--
/*
 *  Procedure to get information about the payroll action
 *  this information is required for both payroll action
 *  and assignment action rollback.
 *  Note - it does perform a couple of validation
 *  checks at the payroll action level and so might fail.
 */
procedure get_pact_info(p_info in out nocopy rollback_rec)
is
   c_indent varchar2(40);
begin
--
   --  get payroll action level information
   if g_debug then
      c_indent := 'py_rollback_pkg.get_pact_info';
      hr_utility.set_location(c_indent, 10);
   end if;
   select pac.business_group_id,
          pac.effective_date,
          pac.start_date,
          hrl.meaning,
          pac.action_type,
          pac.action_status,
          trunc(sysdate),
          pay.payroll_name,
          grp.name,
          grp.legislation_code,
          pac.date_earned,
          pac.purge_phase,
          pac.retro_definition_id,
          pac.batch_id,
          decode(pac.action_type, 'T',
                                   nvl(pay_core_utils.get_parameter('SLA_MODE',
                                                      pac.legislative_parameters),
                                       'N'),
                                  'N')
   into   p_info.bg_id,
          p_info.action_date,
          p_info.action_start_date,
          p_info.action_name,
          p_info.action_type,
          p_info.action_status,
          p_info.current_date,
          p_info.payroll_name,
          p_info.bg_name,
          p_info.legislation_code,
          p_info.date_earned,
          p_info.purge_phase,
          p_info.retro_definition_id,
          p_info.batch_id,
          p_info.sub_ledger_acc
   from   pay_payroll_actions      pac,
          pay_all_payrolls_f       pay,
          per_business_groups_perf grp,
          hr_lookups               hrl
   where  pac.payroll_action_id     = p_info.pact_id
   and    hrl.lookup_code           = pac.action_type
   and    hrl.lookup_type           = 'ACTION_TYPE'
   and    grp.business_group_id     = pac.business_group_id + 0
   and    pay.payroll_id (+)        = pac.payroll_id
   and    pac.effective_date between
          pay.effective_start_date (+) and pay.effective_end_date (+);
   if g_debug then
      hr_utility.trace('action type is ' || p_info.action_type );
   end if;
--
--
--  legislation information.
   p_info.independent_periods_flag := upper( hr_leg_rule.get_independent_periods(p_info.bg_id));

--
-- Treat Retropays as special case as always Time Independent if not Group level
--
   if (p_info.action_type in ('G', 'L', 'O') and
       p_info.independent_periods_flag = 'N') then
      p_info.independent_periods_flag := 'Y';
   end if;
--
   --  see if this type of action is sequenced or not
   declare
      dummy number;
   begin
      p_info.sequenced_flag := TRUE;
--
      select null
      into   dummy
      from   pay_action_classifications CLASS
      where  CLASS.action_type         = p_info.action_type
      and    CLASS.classification_name = 'SEQUENCED';
      if g_debug then
         hr_utility.trace('this action type IS sequenced');
      end if;
   exception
      when no_data_found then
         p_info.sequenced_flag := FALSE;
         if g_debug then
            hr_utility.trace('this action type NOT sequenced');
         end if;
   end;
--
   /* get the object Types for this payroll_action */
   begin
     select /*+ INDEX(paa PAY_ASSIGNMENT_ACTIONS_N50)*/
            decode (ppa.action_type,
                    'X', paa.object_type,
                    decode(paa.object_type,
                           'PAF', null,
                           paa.object_type))
       into p_info.object_type
       from pay_assignment_actions paa,
            pay_payroll_actions    ppa
      where paa.payroll_action_id = p_info.pact_id
        and p_info.pact_id = ppa.payroll_action_id
        and paa.source_action_id is null
        and rownum = 1;
   exception
      when no_data_found then
        p_info.object_type := null;
   end;
end get_pact_info;
--
--
/*
 *  Insert a message indicating a rollback has occurred. This
 *  is used for both assignment and payroll action rollback.
 */
procedure ins_rollback_message(p_info in rollback_rec, p_level in varchar2) is
   c_indent varchar2(40);
   l_line_text     pay_message_lines.line_text%type;
   l_line_sequence number;
   l_payroll_id    number;
   l_source_id     number;
   l_source_type   pay_message_lines.source_type%type;
   l_action_name   hr_lookups.meaning%type;
begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
      c_indent := 'py_rollback_pkg.ins_rollback_message';
      hr_utility.set_location(c_indent, 10);
   end if;
   -- Set up a message for either rollback at assignment or
   -- payroll action level.
   if(p_level = 'A') then
      hr_utility.set_message (801, 'HR_ACTION_ASACT_ROLLOK');
      hr_utility.set_message_token('ASG_NUMBER',p_info.assignment_number);
      hr_utility.set_message_token('FULL_NAME',p_info.full_name);
      hr_utility.set_message_token
              ('SYSDATE',fnd_date.date_to_canonical(p_info.current_date));
--
      -- Message will insert at payroll action level.
      l_source_id := p_info.pact_id;
      l_source_type := 'P';
--
   else
      -- Rollback level is 'P'.
--
      -- For Magnetic Transfer, the action name must be taken
      -- from the Payment Type Name (i.e. BACS, NACHA etc).
      if(p_info.action_type = 'M') then
         if g_debug then
            hr_utility.set_location(c_indent, 90);
         end if;
         select ppt.payment_type_name
         into   l_action_name
         from   pay_payroll_actions pac,
                pay_payment_types   ppt
         where  pac.payroll_action_id = p_info.pact_id
         and    ppt.payment_type_id   = pac.payment_type_id;
      else
         l_action_name := p_info.action_name;
      end if;
--
      -- The message we set up depends on whether or not the
      -- Payroll Action is restricted or unrestricted.
      if(p_info.payroll_name is null) then
         hr_utility.set_message(801,'HR_ACTION_PACT_ROLLNOPAY');
      else
         hr_utility.set_message(801,'HR_ACTION_PACT_ROLLPAY');
         hr_utility.set_message_token('PAYROLL_NAME', p_info.payroll_name);
      end if;
--
      -- Common message tokens.
      hr_utility.set_message_token('ACTION_TYPE',l_action_name);
      hr_utility.set_message_token('BG_NAME',p_info.bg_name);
      hr_utility.set_message_token('SYSDATE',
           fnd_date.date_to_canonical(p_info.current_date));
--
      -- Message will insert at business group level.
      l_source_id := p_info.bg_id;
      l_source_type := 'B';
   end if;   --- rollback level.
--
   -- Get text of message we have set up.
   l_line_text := substrb(hr_utility.get_message, 1, 240);
--
   -- Write message into message lines table.
   if g_debug then
      hr_utility.set_location(c_indent, 10);
   end if;
   insert  into pay_message_lines (
           line_sequence,
           payroll_id,
           message_level,
           source_id,
           source_type,
           line_text)
   values (pay_message_lines_s.nextval,
           l_payroll_id,
           'I',    -- information.
           l_source_id,
           l_source_type,
           l_line_text);
--
end ins_rollback_message;
--
/*---------------------- ins_rollback_message ---------------------------*/
/*
 *  overloaded procedure to insert a rollback message on successful
 *  completion of the rolling back of a payroll action. This must
 *  be callable externally, since the rollback process needs to be
 *  able to insert this message, independently of the plsql.
 */
procedure ins_rollback_message(p_payroll_action_id in number) is
   info     rollback_rec;
begin
   info.pact_id := p_payroll_action_id;
   get_pact_info(info);              -- payroll action information.
   ins_rollback_message(info, 'P');  -- the message itself.
end ins_rollback_message;
--
/*------------------------ undo_stop_update -----------------------------*/
/*
 *  This procedure is called when we have detected the need to undo the
 *  effect of a stop or update recurring entry formula result rule.
 *  Note that, due to the complexity of calculating entry end dates, we
 *  call the existing routine, but trap error messages that are
 *  inappropriate for our application.
 */
procedure undo_stop_update(
   p_ee_id in number,
   p_mult  in varchar,
   p_date  in date,
   p_mode  in varchar2) is
--
   -- Local variables.
   effstart   date;
   effend     date;
   val_start  date;
   val_end    date;
   next_end   date;
   max_end    date;
   orig_ee_id number;
   prev_asgact_id number;
   asg_id     number;
   el_id      number;
   c_indent   varchar2(40);
begin
   -- Select some information about the entry we are operating on.
   if g_debug then
      c_indent := 'py_rollback_pkg.undo_stop_update';
      hr_utility.set_location(c_indent, 10);
   end if;
   select pee.effective_start_date,
          pee.effective_end_date,
          pee.original_entry_id,
          pee.assignment_id,
          pee.element_link_id
   into   effstart, effend, orig_ee_id, asg_id, el_id
   from   pay_element_entries_f pee
   where  pee.element_entry_id = p_ee_id
   and    p_date between
          pee.effective_start_date and pee.effective_end_date;
--
   -- Do nothing if the entry end date is end of time.
   if(effend = c_eot) then
      return;
   end if;
--
   -- For undo update, we have to get next effective start date.
   if(p_mode = 'DELETE_NEXT_CHANGE') then
      begin
         if g_debug then
            hr_utility.set_location(c_indent, 20);
         end if;
         select min(ee.effective_end_date)
         into   next_end
         from   pay_element_entries_f ee
         where  ee.element_entry_id     = p_ee_id
         and    ee.effective_start_date > effend;
      exception
         when no_data_found then null;
      end;
--
      val_start := effend + 1;
--
      if next_end is null then
         val_end := c_eot;
      else
         val_end := next_end;
      end if;
   elsif(p_mode = 'FUTURE_CHANGE') then
      val_start := effend + 1;
      val_end   := c_eot;
   end if;
--
   -- For either mode, we need to obtain the date to which
   -- we may legally extend the entry.
   declare
      message    varchar2(200);
      applid     varchar2(200);
   begin
      max_end := hr_entry.recurring_entry_end_date (
                  asg_id, el_id, p_date, 'Y', p_mult, p_ee_id, orig_ee_id);
   exception
      -- Several error messages can be raised from this procedure.
      -- We wish to trap a number of them, as they should be ignored
      -- for our purposes.
      when hr_utility.hr_error then
      hr_utility.get_message_details(message,applid);
--
      if(message in ('HR_7699_ELE_ENTRY_REC_EXISTS',
                     'HR_7700_ELE_ENTRY_REC_EXISTS',
                     'HR_6281_ELE_ENTRY_DT_DEL_LINK',
                     'HR_6283_ELE_ENTRY_DT_ELE_DEL',
                     'HR_6284_ELE_ENTRY_DT_ASG_DEL')
      ) then
         -- We cannot extend the entry.
         if g_debug then
            hr_utility.set_location(c_indent, 25);
         end if;
         if(p_mode = 'DELETE_NEXT_CHANGE') then
              update pay_element_entries_f ee
              set    updating_action_id=NULL
                      ,updating_action_type =NULL
              where  ee.element_entry_id     = p_ee_id
              and    ee.effective_start_date = val_start;
         elsif(p_mode = 'FUTURE_CHANGE') then
              update pay_element_entries_f ee
              set    updating_action_id=NULL
                      ,updating_action_type =NULL
              where  ee.element_entry_id   = p_ee_id
              and  ee.effective_start_date = effstart;
         end if;
         return;
      else
         -- Should fail if it is anything else.
         raise;
      end if;
   end;
--
   -- Process the delete of element entries.
   if(p_mode = 'DELETE_NEXT_CHANGE') then
      hr_utility.set_location(c_indent, 40);
      delete from pay_element_entries_f ee
      where  ee.element_entry_id     = p_ee_id
      and    ee.effective_start_date = val_start;
--
      hr_utility.set_location(c_indent, 45);
      delete from pay_element_entry_values_f eev
      where  eev.element_entry_id     = p_ee_id
      and    eev.effective_start_date = val_start;
--
      hr_utility.set_location(c_indent, 50);
      update pay_element_entries_f ee
      set    ee.effective_end_date   = next_end
      where  ee.element_entry_id     = p_ee_id
      and    ee.effective_start_date = effstart;
--
      hr_utility.set_location(c_indent, 55);
      update pay_element_entry_values_f eev
      set    eev.effective_end_date   = next_end
      where  eev.element_entry_id     = p_ee_id
      and    eev.effective_start_date = effstart;
--
   elsif(p_mode = 'FUTURE_CHANGE') then
--
      hr_utility.set_location(c_indent, 60);
      delete from pay_element_entries_f ee
      where  ee.element_entry_id     = p_ee_id
      and    ee.effective_start_date > effstart;
--
      hr_utility.set_location(c_indent, 65);
      delete from pay_element_entry_values_f eev
      where  eev.element_entry_id     = p_ee_id
      and    eev.effective_start_date > effstart;
--
      hr_utility.set_location(c_indent, 70);
      update pay_element_entries_f ee
      set    ee.effective_end_date = max_end,
             ee.updating_action_id=NULL,
			 ee.updating_action_type=NULL
      where  ee.element_entry_id   = p_ee_id
      and  ee.effective_start_date = effstart;
	  /*BUG#6200530*/
      /*check for the additional assignment id (in case of an STOP RECURRING after an UPDATE RECURRING)*/
      select ee.prev_upd_action_id
      into prev_asgact_id
      from pay_element_entries_f ee
      where ee.element_entry_id   = p_ee_id
      and  ee.effective_start_date = effstart;
      /*If it is the case then update the updating_action_id with the asg_action_id of the previous UPDATE RECURRING operation*/
      if(prev_asgact_id is not null) then
            update pay_element_entries_f ee
              set    ee.updating_action_id=prev_asgact_id,
                     ee.prev_upd_action_id=NULL,
                     ee.updating_action_type='U'
              where  ee.element_entry_id   = p_ee_id
              and  ee.effective_start_date = effstart;
      end if;
      /*End of BUG#6200530*/
--
      hr_utility.set_location(c_indent, 75);
      update pay_element_entry_values_f eev
      set    eev.effective_end_date   = max_end
      where  eev.element_entry_id     = p_ee_id
      and    eev.effective_start_date = effstart;
   end if;
--
end undo_stop_update;
--
/*
 *  This procedure attempts to reverse the effects of stop and/or
 *  update formula result rules. Due to the implementation of
 *  this functionality, the undo is non-deterministic, i.e. we
 *  cannot guarantee to return the database to the exact state
 *  it was in before the Payroll Run or QuickPay was processed.
 */
procedure proc_entry_dml(p_info in rollback_rec) is
   -- This cursor returns candidates for possible undo
   -- of stop ree frr. i.e. recurring entries that have
   -- an effective_end_date that is same as runs date earned.
   cursor stp is
   select pet.multiple_entries_allowed_flag,
          pee.element_entry_id,pee.updating_action_type
   from   pay_element_types_f   pet,
          pay_element_links_f   pel,
          pay_element_entries_f pee
   where  pee.assignment_id      = p_info.assignment_id
   and    pee.entry_type         = 'E'
   and    pel.element_link_id    = pee.element_link_id
   and    p_info.action_date between
          pel.effective_start_date and pel.effective_end_date
   and    pet.element_type_id    = pel.element_type_id
   and    p_info.action_date between
          pet.effective_start_date and pet.effective_end_date
   and    pet.processing_type    = 'R'
   and    pee.updating_action_id   = p_info.assact_id
   and    ((pee.effective_end_date = p_info.date_earned
            and    pee.effective_start_date <> p_info.action_date
            and    pee.updating_action_type is NULL
            and    p_info.date_earned between
              pee.effective_start_date and pee.effective_end_date)
          or(pee.updating_action_type='S'));

--
   -- This cursor returns candidates for undo update ree frr.
   -- i.e. entries that have been updated on the date of the
   -- Payroll Run, by the updating assignment action.
   cursor upd is
   select pet.multiple_entries_allowed_flag,
          pee.element_entry_id
   from   pay_element_types_f   pet,
          pay_element_links_f   pel,
          pay_element_entries_f pee
   where  pee.assignment_id        = p_info.assignment_id
   and    pee.entry_type           = 'E'
   and    ((pee.effective_start_date = p_info.action_date
            and    pee.updating_action_type is NULL)
            or pee.updating_action_type='U')
   and    pee.updating_action_id   = p_info.assact_id
   and    pel.element_link_id      = pee.element_link_id
   and    p_info.action_date between
          pel.effective_start_date and pel.effective_end_date
   and    pet.element_type_id      = pel.element_type_id
   and    p_info.action_date between
          pet.effective_start_date and pet.effective_end_date
   and    pet.processing_type      = 'R';
--
   c_indent varchar2(40);
   v_max_date date;   -- maximum entry end date
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.proc_entry_dml';
      hr_utility.set_location(c_indent,90);
   end if;
   -- Begin by processing for stop entry dml.
   for stprec in stp loop

    if (stprec.updating_action_type is NULL)
    then
      --  We may have a stopped entry, but we need to
      --  see if this really is the case.
      if g_debug then
         hr_utility.set_location(c_indent,90);
      end if;
      select max(pee.effective_end_date)
      into   v_max_date
      from   pay_element_entries_f pee
      where  pee.element_entry_id = stprec.element_entry_id;
    else
      v_max_date := p_info.date_earned;
    end if;
--
      if(v_max_date = p_info.date_earned) then
         --  Assume entry has been chopped by the run.
         --  Call procedure to actually perform undo.
         undo_stop_update (stprec.element_entry_id,
                           stprec.multiple_entries_allowed_flag,
                           p_info.date_earned, 'FUTURE_CHANGE');
      end if;
   end loop;
--
   -- Process for update entry dml.
   for updrec in upd loop
      --  Since it is not possible to use the Payroll Run to
      --  perform a correction on an entry, we know there
      --  should be an entry record existing on the date
      --  before the run. This is important, since it is
      --  required by the procedure that follows.
      undo_stop_update (updrec.element_entry_id,
                        updrec.multiple_entries_allowed_flag,
                        (p_info.action_date - 1), 'DELETE_NEXT_CHANGE');
   end loop;
end proc_entry_dml;
--
--
/*
 *  Following the main work of rolling back or marking an
 *  assignment action for retry, the assignment action
 *  row itself (the 'base table' row) may need updating or
 *  deleting. (Depends on the wishes of the client). In
 *  addition, we may need to remove interlock rows.
 */
procedure act_base_table_dml(p_info in rollback_rec) is
   c_indent constant varchar2(40) := 'py_rollback_pkg.act_base_table_dml';
begin
   --   see if we want to alter the assignment action itself (we wouldn't
   --   if we were being called from a form).
   --   However, if we are called from the payroll action level,
   --   we must process the assignment action row.
   if(not p_info.leave_row or p_info.rollback_level = 'P') then
      if(p_info.rollback_mode) = 'RETRY' then
         if g_debug then
            hr_utility.set_location(c_indent, 10);
         end if;
--
         update pay_assignment_actions
         set    action_status = 'M'
         where  source_action_id = p_info.assact_id;
--
         update pay_assignment_actions
         set    action_status = 'M'
         where  assignment_action_id = p_info.assact_id;
--
      elsif(p_info.rollback_mode) = 'BACKPAY' then
         if g_debug then
            hr_utility.set_location(c_indent, 20);
         end if;
--
         update pay_assignment_actions
         set    action_status = 'B'
         where  source_action_id = p_info.assact_id;
--
         update pay_assignment_actions
         set    action_status = 'B'
         where  assignment_action_id = p_info.assact_id;
--
      elsif(p_info.rollback_mode) = 'ROLLBACK' then
         -- there may be pay_action_interlock rows.
         -- which are locking other assignment actions.
         if g_debug then
            hr_utility.set_location(c_indent, 30);
         end if;
         delete from pay_action_interlocks lck
         where  lck.locking_action_id = p_info.assact_id;
--
         remove_archive_items(p_info, p_info.assact_id, 'AAC');
         remove_action_information(p_info.assact_id, 'AAC');
--
         delete from pay_assignment_actions
          where source_action_id = p_info.assact_id;
--
         delete from pay_assignment_actions
         where  assignment_action_id = p_info.assact_id;
      end if;
   else
      -- In the case of rolling back (from the form), we
      -- still need to delete interlock rows. Of course,
      -- in this case we do not delete the action.
      if(p_info.rollback_mode = 'ROLLBACK') then
--
         remove_archive_items(p_info, p_info.assact_id, 'AAC');
         remove_action_information(p_info.assact_id, 'AAC');
--
         delete from pay_assignment_actions
          where source_action_id = p_info.assact_id;
--
         delete from pay_action_interlocks lck
         where  lck.locking_action_id = p_info.assact_id;
--
      end if;
   end if;
end act_base_table_dml;
--
/*----------------------  do_assact_rollback -------------------------------*/
/*
  NAME
    do_assact_rollback - Perform dml to rollback assignment action.
  DESCRIPTION
    performs rollback/mark for retry dml for assignment action.
  NOTES
    This internal routine is central to the rollback process. It does
    the actual work of rolling back/marking for retry an assignment
    action. The routine makes no checks for validity of the action.
--
    There are nested procedures to perform many of the specific
    actions required. This is in an attempt to keep the logic
    more understandable.
*/
procedure do_assact_rollback(p_info in rollback_rec) is
   c_indent varchar2(40);
   chld_info rollback_rec;
   purge_child boolean;
--
--
cursor chdact (p_asgact_id in number) is
select paa_chd.assignment_action_id
from pay_assignment_actions paa_chd
where paa_chd.source_action_id = p_asgact_id
order by paa_chd.action_sequence desc;
--
begin
--
   if g_debug then
      c_indent := 'py_rollback_pkg.do_assact_rollback';
      hr_utility.set_location(c_indent, 10);
      hr_utility.set_location('p_info.assact_id'||p_info.assact_id,11);
      hr_utility.set_location('p_info.action_date'||p_info.action_date,12);
      hr_utility.set_location('p_info.pact_id'||p_info.pact_id,13);
   end if;
--
   -- Firstly remove any child actions.
   chld_info := p_info;
   for chdrec in chdact (p_info.assact_id) loop
      chld_info.assact_id := chdrec.assignment_action_id;
      do_assact_rollback(chld_info);
      --
      -- Remove child assignment actions if needed.
      purge_child := TRUE;
--
      if (p_info.rollback_mode = 'BACKPAY'
       and p_info.retro_purge = 'N') then
        purge_child := FALSE;
      end if;
--
      -- If its an Enhanced retropay by Ele and using the
      -- process group level interlocking then do not
      -- remove the child actions.
      if (p_info.retro_definition_id is not null
          and p_info.independent_periods_flag = 'G') then
         purge_child := FALSE;
      end if;
--
      if (purge_child = TRUE) then
        delete from pay_action_interlocks
         where locking_action_id = chld_info.assact_id;
        if g_debug then
           hr_utility.set_location('About to remove assg actions' , 11);
        end if;
        delete from pay_assignment_actions
         where assignment_action_id = chld_info.assact_id;
      end if;
   end loop;
   --
   -- Perform actions that are specific to sequenced actions.
   -- In other words, remove the rows that are only inserted
   -- by these types of actions.
--
   if(p_info.sequenced_flag) then
   --
   -- if the assignment being rolled back contributes to a group run balance
   -- need to remove the contributing amount from the group run balance.
   --
     if (p_info.rollback_mode <> 'BACKPAY') then
        pay_balance_pkg.remove_asg_contribs(p_info.pact_id
                                           ,p_info.assact_id
                                           ,p_info.grp_multi_thread);
        --
        -- now delete assignment level run balances
        --
        delete from pay_run_balances
        where  assignment_action_id = p_info.assact_id;
     else
        --
        -- now update assignment level run balances
        --
        update pay_run_balances
           set balance_value = 0
        where  assignment_action_id = p_info.assact_id;
     end if;
     --
     remove_balances(p_info);     -- latest balances.
     remove_run_results(p_info);  -- run results and values.
     remove_action_contexts(p_info.assact_id); -- action contexts
   end if;
   --
   -- Delete specific types of rows for certain action types.
   if((p_info.action_type = 'B' and p_info.rollback_mode = 'ROLLBACK') OR
      (p_info.action_type = 'I' )) then
--
      -- OK here's the scoop. If we are in rollback mode
      -- then remove the element entries for bal adjust
      --
      -- Otherwise we must be in Retry mode, hence only remove the
      -- Entries if it is a formula based balance adjustment.
--
      -- entries/values for bal adjust.
      if (p_info.rollback_mode = 'ROLLBACK' or p_info.action_type = 'I') then
         undo_bal_adjust(p_info.action_date, p_info.assact_id);
      else
         declare
           l_et_id pay_payroll_actions.element_type_id%type;
         begin
--
           select ppa.element_type_id
             into l_et_id
             from pay_assignment_actions paa,
                  pay_payroll_actions    ppa
            where ppa.payroll_action_id = paa.payroll_action_id
              and paa.assignment_action_id = p_info.assact_id;
--
           if (l_et_id is not null) then
             undo_bal_adjust(p_info.action_date, p_info.assact_id);
           end if;
--
         end;
      end if;
   --
   elsif(p_info.action_type in ('R', 'Q')) then
      proc_entry_dml(p_info);               -- stop/update ree frr.
   --
   elsif(p_info.action_type in ('P', 'U')) then
      -- Remove pre-payment rows.
      -- Note, this causes cascade delete of pay_coin_anal_elements.
      if g_debug then
         hr_utility.set_location('Error abt to occur', 13);
      end if;
      delete from pay_pre_payments ppp
      where  ppp.assignment_action_id = p_info.assact_id;
   --
   elsif(p_info.action_type in ('C', 'S', 'EC')) then
      -- Remove costing rows.
      if g_debug then
         hr_utility.set_location(c_indent, 20);
      end if;
      delete from pay_costs pc
      where  pc.assignment_action_id = p_info.assact_id;
   --
   elsif(p_info.action_type = 'CP') then
      -- Remove costing rows.
      delete from pay_payment_costs ppc
      where  ppc.assignment_action_id = p_info.assact_id;
   --
   elsif(p_info.action_type = 'T') then
      -- Remove intermediate transfer table rows.
      if (p_info.sub_ledger_acc = 'N') then
         remove_gl_entries(p_info);
      else
         pay_sla_pkg.delete_event(p_info.assact_id);
      end if;
   --
    elsif(p_info.action_type = 'M') then
      -- Reset prenote date if this is a dummy payment i.e. payment value
      -- of zero.
      reset_prenote(p_info.assact_id);
      remove_archive_items(p_info, p_info.assact_id, 'AAP');
      remove_file_details(p_info, p_info.assact_id, 'PAA');
   --
    elsif(p_info.action_type = 'PP') then
      remove_archive_items(p_info, p_info.assact_id, 'AAP');
      remove_file_details(p_info, p_info.assact_id, 'PAA');
   --
   elsif(p_info.action_type = 'O') then
      -- Remove Retropay rows.
      remove_retro_ee(p_info.assact_id);
   --
   elsif(p_info.action_type = 'F') then
      -- Remove Advance pay rows.
      remove_adv_ee(p_info.assact_id);
   --
   elsif(p_info.action_type = 'X') then
      --Remove Archive Items
      remove_archive_items(p_info, p_info.assact_id, 'AAP');
      remove_action_information(p_info.assact_id, 'AAP');
      remove_file_details(p_info, p_info.assact_id, 'PAA');
   --
   elsif(p_info.action_type = 'G') then
      -- Remove Retropay by Action rows
      remove_retroact_ee(p_info.assact_id);
   --
   elsif(p_info.action_type = 'L') then
      -- Remove Retropay by Element rows
      remove_retroele_ee(p_info.assact_id, p_info.rollback_mode);
      --
      -- The following logic in now moved within the above procedure.
      --
      -- -- Finally reset the pay_retro_assignment_table if needed
      -- if (p_info.rollback_mode <> 'RETRY') then
      --
      --    pay_retro_pkg.merge_retro_assignments(p_info.assact_id);
      --
      --    -- Remove the asg act id, and in case merge has new earlier entries
      --    -- also change the reprocess_date
      --    update pay_retro_assignments  ra
      --       set ra.retro_assignment_action_id = null,
      --           ra.reprocess_date = nvl( (
      --                 select min(effective_date)
      --                 from pay_retro_entries re
      --                 where re.retro_assignment_id = ra.retro_assignment_id )
      --             ,ra.reprocess_date)
      --    where ra.retro_assignment_action_id = p_info.assact_id;
      --
      -- end if;
   --
   elsif(p_info.action_type = 'W') then
      -- Remove Advance Pay by Element rows
      remove_advpayele_ee(p_info.assact_id);
   --
   elsif(p_info.action_type = 'Z') then
      -- Remove the purge rollup balance rows.
      delete from pay_purge_rollup_balances rub
      where  rub.assignment_action_id = p_info.assact_id;
   elsif(p_info.action_type = 'BEE') then
      -- Remove Batch Element Entry rows
      pay_mix_rollback_pkg.undo_mix_asg(p_info.assact_id);
   elsif(p_info.action_type = 'PRU') then
      -- Remove Rolled up payments
      delete from pay_contributing_payments
      where assignment_action_id = p_info.assact_id;
   end if;
   --
   -- Delete messages for the assignment action.
   remove_messages(p_info, 'A');
--
   -- Rollback specific code.
   if(p_info.rollback_mode = 'ROLLBACK') then
      --  Insert message indicating rollback of assignment action.
      --  Only insert message if action is not an initial
      --  balance adjustment.
      if (p_info.action_type <> 'I') then
         ins_rollback_message(p_info, 'A');
      end if;
--
      --  When we are rolling back QuickPay, we need to
      --  remove the QuickPay Inclusions.
      if(p_info.action_type = 'Q') then
         if g_debug then
            hr_utility.set_location(c_indent, 30);
         end if;
         --
         -- Enhancement 3368211
         --
         -- Delete from both PAY_QUICKPAY_INCLUSIONS and PAY_QUICKPAY_EXCLUSIONS.
         --
         -- There is a chance the assignment action id exists in both tables if
         -- the assignment action was created before the QuickPay Exclusions
         -- data model was in use.
         --
         delete from pay_quickpay_exclusions exc
         where  exc.assignment_action_id = p_info.assact_id;
         --
         delete from pay_quickpay_inclusions inc
         where  inc.assignment_action_id = p_info.assact_id;
         --
      end if;
   end if;
--
   -- Following main processing, may need to do some
   -- work on the assignment action row itself.
   act_base_table_dml(p_info);
--
--
end do_assact_rollback;
--
/*
 *  Internal procedure : called for an individual assignment
 *  action to validate that a rollback or mark for retry is
 *  legal. Note, it does not guarantee that the rollback
 *  will succeed, as this does not perform any dml.
 *
 *  Assumes that val_pact_rollback has already been called
 *  to obtain payroll action level information.
 */
procedure val_assact_rollback(p_info in out nocopy rollback_rec)
is
   l_action_sequence pay_assignment_actions.action_sequence%type;
   l_action_status   pay_assignment_actions.action_status%type;
   l_person_id       per_all_people_f.person_id%type;
   l_sec_status      pay_assignment_actions.secondary_status%type;
   c_indent varchar2(40);
begin
   --  Obtain information about this assignment action which we will
   --  need later on.
   --  Some of this is required for messages.
   if g_debug then
      c_indent := 'py_rollback_pkg.val_assact_rollback';
      hr_utility.trace('assact_id : ' || p_info.assact_id);
   end if;
--
   -- OK We need to run different statements for different types
   -- of processes
--
   hr_utility.set_location(c_indent, 10);
   if ((p_info.action_type = 'L'
       and p_info.object_type = 'POG')
       or p_info.object_type is not null
       ) then
--
      if (p_info.action_type = 'L') then
--
        hr_utility.set_location(c_indent, 20);
        -- OK this is a retropay that using the Object Group
        -- actions
        select null,
               ACT.action_sequence,
               ACT.action_status,
               ACT.secondary_status,
               null,
               PEO.person_id,
               substr(PEO.full_name,1,80),
               null
        into   p_info.assignment_id,
               l_action_sequence,
               l_action_status,
               l_sec_status,
               p_info.payroll_id,
               l_person_id,
               p_info.full_name,
               p_info.assignment_number
        from
               per_all_people_f           PEO,
               pay_object_groups      POG_PER,
               pay_assignment_actions ACT
        where  ACT.assignment_action_id = p_info.assact_id
        and    ACT.source_action_id     is null
        and    ACT.object_id            = POG_PER.object_group_id
        and    POG_PER.source_id        = PEO.person_id
        and    p_info.action_date between
                       PEO.effective_start_date and PEO.effective_end_date;
      else
--
        hr_utility.set_location(c_indent, 30);
        -- OK its some sort of object action
        select null,
               ACT.action_sequence,
               ACT.action_status,
               ACT.secondary_status,
               null,
               null,
               null,
               null
        into   p_info.assignment_id,
               l_action_sequence,
               l_action_status,
               l_sec_status,
               p_info.payroll_id,
               l_person_id,
               p_info.full_name,
               p_info.assignment_number
        from   pay_assignment_actions ACT
        where  ACT.assignment_action_id = p_info.assact_id;
--
      end if;
--
   else
--
      hr_utility.set_location(c_indent, 40);
      -- It's a normal action
--
      select ACT.assignment_id,
             ACT.action_sequence,
             ACT.action_status,
             ACT.secondary_status,
             ASS.payroll_id,
             PEO.person_id,
             substr(PEO.full_name,1,80),
             ASS.assignment_number
      into   p_info.assignment_id,
             l_action_sequence,
             l_action_status,
             l_sec_status,
             p_info.payroll_id,
             l_person_id,
             p_info.full_name,
             p_info.assignment_number
      from   per_all_assignments_f      ASS,
             per_all_people_f           PEO,
             pay_assignment_actions ACT
      where  ACT.assignment_action_id = p_info.assact_id
      and    ASS.assignment_id        = ACT.assignment_id
      and    PEO.person_id            = ASS.person_id
      and    ((p_info.action_type = 'X'
               and ASS.effective_start_date = (select max(ASS2.effective_start_date)
                                               from   per_all_assignments_f ASS2
                                               where  ASS2.assignment_id = ASS.assignment_id)
               and PEO.effective_start_date = (select max(PEO2.effective_start_date)
                                               from   per_all_people_f PEO2
                                               where  PEO2.person_id = PEO.person_id)
              )
             or
              ((p_info.action_type = 'Z' or p_info.action_type = 'PRU')
               and ASS.effective_start_date = (select max(ASS2.effective_start_date)
                                               from   per_all_assignments_f ASS2
                                               where  ASS2.assignment_id = ASS.assignment_id
                                               and    ASS2.effective_start_date <= p_info.action_date)
               and PEO.effective_start_date = (select max(PEO2.effective_start_date)
                                               from   per_all_people_f PEO2
                                               where  PEO2.person_id = PEO.person_id
                                               and    PEO2.effective_start_date <= p_info.action_date)
              )
             or
              (p_info.action_type = 'BEE'
               and ASS.effective_start_date = (select max(ASS2.effective_start_date)
                                            from   per_all_assignments_f ASS2,
                                                   pay_batch_lines pbl
                                            where  ASS2.assignment_id = ASS.assignment_id
                                            and    pbl.batch_id (+) = p_info.batch_id
                                            and    pbl.assignment_id (+) = ASS.assignment_id
                                            and    pbl.effective_Date (+) between ASS2.effective_start_date
                                                   and ASS2.effective_end_date)
               and PEO.effective_start_date = (select max(PEO2.effective_start_date)
                                            from   per_all_people_f PEO2,
                                                   pay_batch_lines pbl
                                            where  PEO2.person_id = PEO.person_id
                                            and    PEO2.person_id = ASS.person_id
                                            and    pbl.batch_id (+) = p_info.batch_id
                                            and    pbl.assignment_id (+) = ASS.assignment_id
                                            and    pbl.effective_Date (+) between PEO2.effective_start_date
                                                   and PEO2.effective_end_date)
              )
             or
             (p_info.action_type not in ('BEE','Z','X', 'PRU')
              and    p_info.action_date between
                    ASS.effective_start_date and ASS.effective_end_date
              and    p_info.action_date between
                     PEO.effective_start_date and PEO.effective_end_date));
   end if;
--
   hr_utility.set_location(c_indent, 50);
--
   --  for Purge, we simply wish to confirm that we are not
   --  attempting to rollback an assignment action that has
   --  a 'C' secondary status.  If everything ok, we simpy
   --  exit this procedure.
   if(p_info.action_type = 'Z') then
      if(l_sec_status = 'C') then
         hr_utility.set_message(801, 'PAY_289118_PUR_NACT_ROLLBACK');
         hr_utility.raise_error;
      end if;
--
      if g_debug then
         hr_utility.trace('Purge act : exit');
      end if;
      return;
   end if;
--
   --  can only retry if already complete
   if(p_info.rollback_mode = 'RETRY' and l_action_status not in ('C', 'S'))
   then
      hr_utility.set_message (801, 'HR_7506_ACTION_RET_NOT_COMP');
      hr_utility.set_message_token ('ASG_NO', p_info.assignment_number);
      hr_utility.raise_error;
   end if;
--
--
   --
   -- If rolling back or retrying, we need to know if assignments
   -- can be considered in isolation (as prescribed by the
   -- independent time periods flag for this legislation). Assignments
   -- with no Payroll are independent.
   --
   -- Operation is disallowed if this is a sequenced action AND there
   -- exists any sequenced actions in the future. Also disallowed
   -- if any child action exists (e.g can't rollback a run if already
   -- costed).
   -- Note - exception is if are attempting to roll back Reversal or
   -- Balance Adjustment actions, where we do not bother to perform
   -- the future actions check.
   --
   declare
      dummy number;
   begin
      -- For either legislation, examine the assignment action
      -- to see if it is locked by another action. Peform
      -- slightly different checks for RETRY and ROLLBACK
      -- modes. See comments below.
      if(p_info.rollback_mode = 'RETRY')
      then
         -- Case for RETRY mode.
         -- Check that the assignment action we are attempting to
         -- mark for retry is not locked by an assignment action
         -- that has an action_status that is not mark for retry.
         --
         -- Bug 1923535. If the locking action is a Payments Process and has
         -- been 'Marked for Retry' then the locked action cannot be
         -- 'Marked for Retry'.
         --
         if g_debug then
            hr_utility.set_location(c_indent, 20);
         end if;
         select null
         into   dummy
         from   dual
         where  not exists (
                select null
                from   pay_action_interlocks int,
                       pay_assignment_actions act
                where  int.locked_action_id     =  p_info.assact_id
                and    act.assignment_action_id =  int.locking_action_id
                and    ((exists
                         (select null
                            from pay_payroll_actions pac
                           where pac.payroll_action_id = act.payroll_action_id
                             and action_type in ('A','H','M', 'PP', 'PRU')
                             and act.action_status = 'M'
                         )
                        )
                          or act.action_status        <> 'M'
                       ));
      else
         -- Case for ROLLBACK mode.
         -- Check that the assignment action we are attempting to
         -- roll back is not locked by an assignment action.
         if g_debug then
            hr_utility.set_location(c_indent, 30);
         end if;
         select null
         into   dummy
         from   dual
         where  not exists (
                select null
                from   pay_action_interlocks int
                where  int.locked_action_id = p_info.assact_id);
      end if;
--
      --  Now, the following checks are only applicable to sequenced
      --  actions, excluding Balance Adjustment and Reversal. These
      --  are special cases.
      if (p_info.sequenced_flag and
          (p_info.action_type <> 'B' and p_info.action_type <> 'I'
             and p_info.action_type <> 'V'))
      then
         -- Check the legislation case.
         if(p_info.independent_periods_flag = 'Y')
         then
            --  Check for other actions on this ASSIGNMENT
            --  Perform different checks for RETRY or ROLLBACK.
            --  We deal with both 'RETRY' and 'ROLLBACK' (BACKPAY) cases.
            --
            --  For RETRY:
            --    disallow mark for retry assignment action if there are
            --    future SEQUENCED assignment actions for the assignment
            --    that are not marked for retry. (Nested mark for retry).
            --
            --  For ROLLBACK (and BACKPAY):
            --    disallow rollback assignment action if there are
            --    future SEQUENCED assignment actions for the assignment.
            if g_debug then
               hr_utility.set_location(c_indent, 40);
            end if;
            --
            if (p_info.rollback_mode = 'RETRY')
            then
               select null into dummy
               from   dual
               where  not exists
                  (select null
                   from   pay_assignment_actions      ACT,
                          pay_payroll_actions        PACT,
                          pay_action_classifications CLASS
                   where  ACT.assignment_id         = p_info.assignment_id
                   and    ACT.action_sequence       > l_action_sequence
                   and    ACT.action_status         in ('C', 'S')
                   and    ACT.payroll_action_id     = PACT.payroll_action_id
                   and    PACT.action_type          = CLASS.action_type
                   and    CLASS.classification_name = 'SEQUENCED');
            else
               select null into dummy
               from   dual
               where  not exists
                  (select null
                   from   pay_assignment_actions      ACT,
                          pay_payroll_actions        PACT,
                          pay_action_classifications CLASS
                   where  ACT.assignment_id         = p_info.assignment_id
                   and    ACT.action_sequence       > l_action_sequence
                   and    ACT.action_status         in ('C', 'S','M')
                   and    ACT.payroll_action_id     = PACT.payroll_action_id
                   and    PACT.action_type          = CLASS.action_type
                   and    CLASS.classification_name = 'SEQUENCED');
            end if;
            --
          elsif (p_info.independent_periods_flag = 'G') then
            --
            -- There are 2 Types of processes here. They are
            -- either processing at the assignment level but
            -- doing Group interlocking or are processing
            -- at the group level
            --
            if (p_info.object_type is not null
                and p_info.object_type = 'POG') then
              if (p_info.rollback_mode = 'RETRY')
              then
                 select null into dummy
                 from   dual
                 where  not exists
                    (select null
                     from   pay_action_classifications CLASS,
                            pay_payroll_actions        PACT,
                            pay_assignment_actions     ACT,
                            pay_object_groups          POG_ASG,
                            pay_object_groups          POG_PER,
                            pay_assignment_actions     PAA_RET
                     where  PAA_RET.assignment_action_id = p_info.assact_id
                       and  POG_PER.object_group_id = PAA_RET.object_id
                       and  POG_PER.source_type = 'PPF'
                       and  POG_ASG.parent_object_group_id = POG_PER.object_group_id
                       and  POG_ASG.source_type = 'PAF'
                       and  POG_ASG.source_id = ACT.assignment_id
                       and  ACT.action_sequence       > l_action_sequence
                       and  ACT.action_status         in ('C', 'S')
                       and  ACT.payroll_action_id     = PACT.payroll_action_id
                       and  PACT.action_type          = CLASS.action_type
                       and  CLASS.classification_name = 'SEQUENCED');
              else
                 select null into dummy
                 from   dual
                 where  not exists
                    (select null
                     from   pay_action_classifications CLASS,
                            pay_payroll_actions        PACT,
                            pay_assignment_actions     ACT,
                            pay_object_groups          POG_ASG,
                            pay_object_groups          POG_PER,
                            pay_assignment_actions     PAA_RET
                     where  PAA_RET.assignment_action_id = p_info.assact_id
                       and  POG_PER.object_group_id = PAA_RET.object_id
                       and  POG_PER.source_type = 'PPF'
                       and  POG_ASG.parent_object_group_id = POG_PER.object_group_id
                       and  POG_ASG.source_type = 'PAF'
                       and  POG_ASG.source_id = ACT.assignment_id
                       and  ACT.action_sequence       > l_action_sequence
                       and  ACT.action_status         in ('C', 'S', 'M')
                       and  ACT.payroll_action_id     = PACT.payroll_action_id
                       and  PACT.action_type          = CLASS.action_type
                       and  CLASS.classification_name = 'SEQUENCED');
              end if;
            else
              if (p_info.rollback_mode = 'RETRY')
              then

                 select null into dummy
                 from   dual
                 where  not exists
                    (select null
                     from   pay_action_classifications CLASS,
                            pay_payroll_actions        PACT,
                            pay_assignment_actions     ACT,
                            pay_object_groups          POG_ASG,
                            pay_object_groups          POG_ASG2
                     where   POG_ASG.source_type = 'PAF'
                       and  POG_ASG2.source_type = 'PAF'
                       and  POG_ASG.source_id = p_info.assignment_id
                       and  POG_ASG.parent_object_group_id = POG_ASG2.parent_object_group_id
                       and  POG_ASG2.source_id = ACT.assignment_id
                       and  ACT.action_sequence       > l_action_sequence
                       and  ACT.action_status         in ('C', 'S')
                       and  ACT.payroll_action_id     = PACT.payroll_action_id
                       and  PACT.action_type          = CLASS.action_type
                       and  CLASS.classification_name = 'SEQUENCED');
              else
                 select null into dummy
                 from   dual
                 where  not exists
                    (select null
                     from   pay_action_classifications CLASS,
                            pay_payroll_actions        PACT,
                            pay_assignment_actions     ACT,
                            pay_object_groups          POG_ASG,
                            pay_object_groups          POG_ASG2
                     where   POG_ASG.source_type = 'PAF'
                       and  POG_ASG2.source_type = 'PAF'
                       and  POG_ASG.source_id = p_info.assignment_id
                       and  POG_ASG.parent_object_group_id = POG_ASG2.parent_object_group_id
                       and  POG_ASG2.source_id = ACT.assignment_id
                       and  ACT.action_sequence       > l_action_sequence
                       and  ACT.action_status         in ('C', 'S', 'M')
                       and  ACT.payroll_action_id     = PACT.payroll_action_id
                       and  PACT.action_type          = CLASS.action_type
                       and  CLASS.classification_name = 'SEQUENCED');
              end if;
            end if;
            --
          else
            --   check for other actions on this PERSON.
            if g_debug then
               hr_utility.set_location(c_indent, 50);
            end if;
--
            --
            if (p_info.rollback_mode = 'RETRY')
            then
               select null into dummy
               from   dual
               where  not exists
                  (select null
                   from   pay_action_classifications CLASS,
                          pay_payroll_actions        PACT,
                          pay_assignment_actions     ACT,
                          per_all_assignments_f      ASS,
                          per_periods_of_service     POS
                   where  POS.person_id             = l_person_id
                   and    ASS.period_of_service_id  = POS.period_of_service_id
                   and    ACT.assignment_id         = ASS.assignment_id
                   and    ACT.action_sequence       > l_action_sequence
                   and    ACT.action_status         in ('C', 'S')
                   and    ACT.payroll_action_id     = PACT.payroll_action_id
                   and    PACT.action_type          = CLASS.action_type
                   and    CLASS.classification_name = 'SEQUENCED');
            else
               select null into dummy
               from   dual
               where  not exists
                  (select null
                   from   pay_action_classifications CLASS,
                          pay_payroll_actions        PACT,
                          pay_assignment_actions     ACT,
                          per_all_assignments_f      ASS,
                          per_periods_of_service     POS
                   where  POS.person_id             = l_person_id
                   and    ASS.period_of_service_id  = POS.period_of_service_id
                   and    ACT.assignment_id         = ASS.assignment_id
                   and    ACT.action_sequence       > l_action_sequence
                   and    ACT.action_status         in ('C', 'S', 'M')
                   and    ACT.payroll_action_id     = PACT.payroll_action_id
                   and    PACT.action_type          = CLASS.action_type
                   and    CLASS.classification_name = 'SEQUENCED');
            end if;
            --
         end if;
      end if;
--
--  When rolling back a void payment then ensure that the void is against the
--  latest chequewriter run for the payment.
--
      if p_info.action_type = 'D' then
       select null
         into dummy
         from dual
        where not exists (select null
                        from
                             pay_assignment_actions paac2,
                             pay_assignment_actions paac,
                             pay_action_interlocks  pai
                       where pai.locking_action_id = p_info.assact_id
                         and pai.locked_action_id  = paac.assignment_action_id
                         and paac.pre_payment_id   = paac2.pre_payment_id
                         and paac2.action_sequence  > paac.action_sequence);
      end if;
--
   exception
      when no_data_found then
         -- Catch all interlock failure message.
         if p_info.legislation_code = 'GB' then
            hr_utility.set_message (801, 'HR_52975_ACTION_UNDO_INTLOK_GB');
         else
            hr_utility.set_message (801, 'HR_7507_ACTION_UNDO_INTLOCK');
         end if;
         hr_utility.raise_error;
   end;
end val_assact_rollback;
--
/*
 *  assignment level error handler. When we encounter
 *  an assignment level error, we call this procedure.
 *  This controls the counting of errors and writing
 *  messages to the message lines table.
 */
procedure assact_error(p_info in rollback_rec,
          error_code in number, error_message in varchar2) is
   c_indent varchar2(40);
   message_text pay_message_lines.line_text%type;
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.assact_error';
      hr_utility.set_location(c_indent, 10);
   end if;
--
   --  handle the assignment action level error.
   --  get the message text to write. Need to get it
   --  in diffferent ways for oracle and user errors.
   if(error_code = hr_utility.hr_error_number)
   then
      --  specific exception raised.
      message_text := substrb(hr_utility.get_message, 1, 240);
   else
      --  oracle error.
      message_text := error_message;
   end if;
--
   --  we can now insert the messge to message lines.
   if g_debug then
      hr_utility.set_location(c_indent, 10);
   end if;
   insert  into pay_message_lines (
           line_sequence,
           payroll_id,
           message_level,
           source_id,
           source_type,
           line_text)
   values (pay_message_lines_s.nextval,
           p_info.payroll_id,
           'F',    -- it's a fatal message.
           p_info.assact_id,
           'A',    -- assignment action level.
           message_text);
--
   pay_core_utils.push_message(801, null, message_text, 'F');
--
   --  keep track of the number of errors
   --  fail if we have had too many.
   g_error_count := g_error_count + 1;
--
   if(g_error_count > p_info.max_errors_allowed)
   then
      --  too many errors. we now abort with a message.
      --  commit any work we have already done if
      --  we are allowed to do so.
      if(p_info.dml_mode = 'FULL' or p_info.multi_thread)
      then
         commit;
      end if;
--
      --  raise error to indicate entire process has failed.
      hr_utility.set_message (801, 'HR_7269_ASS_TOO_MANY_ERRORS');
      hr_utility.raise_error;
   end if;
end assact_error;
--
/*
 *  Lock and return a range row.
 *  A range of ids are locked by first setting a database
 *  lock and then updating the status to 'P', at which
 *  point is 'belongs' to the thread and we can commit.
 *  If there are no lockable rows, returns a null for
 *  the chunk number to indicate end of processing.
 */
function next_range(p_info in rollback_rec)
return range_rec is
   norows     boolean;
   range_info range_rec;
   c_indent varchar2(40);
begin
   if g_debug then
      c_indent := 'py_rollback_pkg.next_range';
      hr_utility.set_location(c_indent, 1);
   end if;
   -- select a range row for update.
   begin
      if g_debug then
         hr_utility.set_location(c_indent, 2);
      end if;
      select rge.chunk_number,
             rge.starting_person_id,
             rge.ending_person_id
      into   range_info
      from   pay_population_ranges rge
      where  rge.payroll_action_id = p_info.pact_id
      and    rge.range_status      = 'U'
      and    rownum < 2
      for update of rge.chunk_number;
--
      if g_debug then
         hr_utility.set_location(c_indent, 3);
      end if;
      --  If we reach here, we have a range row
      --  and we therefore wish to lock it.
      update pay_population_ranges pop
      set    pop.range_status      = 'P'
      where  pop.payroll_action_id = p_info.pact_id
      and    pop.chunk_number      = range_info.chunk_number;
--
      if g_debug then
         hr_utility.set_location(c_indent, 4);
      end if;
      --  Only commit if we are allowed to.
      if(p_info.multi_thread or p_info.dml_mode = 'FULL')
      then
         if g_debug then
            hr_utility.set_location(c_indent, 5);
         end if;
         commit;
      end if;
   exception
      when no_data_found then
        if g_debug then
           hr_utility.set_location(c_indent, 7);
        end if;
        range_info.chunk_number := null;
   end;
--
   if g_debug then
      hr_utility.set_location(c_indent, 8);
   end if;
   return(range_info);
end next_range;
--
procedure perform_act_rollback(p_info in out nocopy rollback_rec)
is
begin
   if g_debug then
      hr_utility.set_location ('perform_asg_rollback',10);
   end if;
--
   --  set a savepoint in case we fail.
   savepoint before;
--
   --  make checks for validity of rollback.
   val_assact_rollback(p_info);   --
--
   --  actually perform the rollback/mark for retry.
   do_assact_rollback(p_info);
--
   if g_debug then
      hr_utility.set_location ('perform_asg_rollback',20);
   end if;
   --  if succeeded in processing, we reset the
   --  error counter, since we only wish to count
   --  consecutive errors.
   g_error_count := 0;
--
exception
   --  we may be reaching here due to failure in validation
   --  or because we have an unhandled exception (oracle error).
   --  in both cases we attempt to write the message text to
   --  message lines before continuing. This is done up to
   --  the error limit, then we exit.
   when others then
      if g_debug then
         hr_utility.set_location ('perform_asg_rollback',30);
      end if;
      rollback to savepoint before;    -- throw away any work.
      if(p_info.all_or_nothing)
      then
         --  fail immediately for this case.
         raise;
      else
         assact_error(p_info, sqlcode, sqlerrm);
      end if;
end;
/*
 *  Performs the dml for rolling back or
 *  marking for retry assignment actions.
 */
procedure assact_dml(p_info in out nocopy rollback_rec) is
--
   range_info        range_rec;
--
   /*
    * Notice we outer join to period of service to
    * allow locking when we have a row.  We will not have
    * a period of service for benefit assignments.
    */
   cursor c1 is
   select /*+ ORDERED*/ act.assignment_action_id,
          asg.period_of_service_id
   from   per_all_assignments_f  asg,
          pay_assignment_actions act
   where  act.payroll_action_id    = p_info.pact_id
   and    asg.assignment_id        = act.assignment_id
   and    act.source_action_id is null
   and    ((p_info.action_type = 'X'
           and asg.effective_start_date = (select max(asg2.effective_start_date)
                                           from per_all_assignments_f asg2
                                           where asg2.assignment_id =
                                                        asg.assignment_id)
           )
          or
           ((p_info.action_type = 'PRU' or p_info.action_type = 'Z')
           and asg.effective_start_date = (select max(asg2.effective_start_date)
                                           from per_all_assignments_f asg2
                                           where asg2.assignment_id =
                                                        asg.assignment_id
                                           and asg2.effective_start_date <=
                                                        p_info.action_date)
            )
           or
            (p_info.action_type = 'BEE'
            and asg.effective_start_date = (select max(ASS2.effective_start_date)
                                            from   per_all_assignments_f ASS2,
                                                   pay_batch_lines pbl
                                            where  ASS2.assignment_id = asg.assignment_id
                                            and    pbl.batch_id (+) =  p_info.batch_id
                                            and    pbl.assignment_id (+) = asg.assignment_id
                                            and    pbl.effective_Date (+) between ASS2.effective_start_date
                                                   and ASS2.effective_end_date))
           or
            (p_info.action_type not in ('BEE','Z','X')
            and p_info.action_date between
                asg.effective_start_date and asg.effective_end_date))
   and    asg.person_id between
          range_info.starting_person and range_info.ending_person
   for update of act.action_status,
                 asg.assignment_id
   order by act.action_sequence desc;
--
   cursor c2 is
   select act.assignment_action_id
   from   pay_assignment_actions act
   where  act.payroll_action_id    = p_info.pact_id
   and    act.source_action_id is null
   and    act.object_id between
          range_info.starting_person and range_info.ending_person
   for update of act.action_status
   order by act.action_sequence desc;
--
   cursor c3(c_period_of_service_id number) is
   select pos.period_of_service_id
   from   per_periods_of_service pos
   where  pos.period_of_service_id = c_period_of_service_id
   for update of pos.period_of_service_id;
--
   commit_limit number;
begin
   if g_debug then
      hr_utility.set_location ('assact_dml',1);
   end if;
   --  Attempt to get a range to process.
   range_info := next_range(p_info);
--
   if g_debug then
      if g_debug then
         hr_utility.trace('max_single_undo    = ' || p_info.max_single_undo);
         hr_utility.trace('max_errors_allowed = ' || p_info.max_errors_allowed);
         hr_utility.set_location ('assact_dml',2);
      end if;
   end if;
   --  Continue to process a chunk at a time,
   --  as long as we can lock a range row.
   while(range_info.chunk_number is not null)
   loop
      hr_utility.set_location ('assact_dml',3);
--
      /* By default it must be an assignment action */
      if (p_info.object_type is null) then
         for c1rec in c1 loop
            p_info.assact_id := c1rec.assignment_action_id;
            if c1rec.period_of_service_id is not null then
              for c3rec in c3(c1rec.period_of_service_id) loop
                null; -- Locking Period of service.
              end loop;
            end if;
            perform_act_rollback(p_info);
         end loop;  -- assact loop.
      else
         /* OK, it must be an object action */
         for c2rec in c2 loop
            p_info.assact_id := c2rec.assignment_action_id;
            perform_act_rollback(p_info);
         end loop;  -- objact loop.
      end if;
--
      --  this range row is finished with.
      if g_debug then
         hr_utility.set_location('assact_dml', 20);
      end if;
      delete from pay_population_ranges range
      where  range.payroll_action_id = p_info.pact_id
      and    range.chunk_number      = range_info.chunk_number;
--
      if g_debug then
         hr_utility.set_location ('assact_dml',10);
      end if;
      --  commit our processing, but only if we are
      --  mult-threading and dml_mode is appropriate.
      --  reset the commit limit to zero.
      if(p_info.multi_thread or p_info.dml_mode = 'FULL')
      then
         commit;
         commit_limit := 0;
      end if;
--
      if g_debug then
         hr_utility.set_location ('assact_dml',11);
      end if;
      --  Attempt to lock another range.
      range_info := next_range(p_info);
   end loop;
--
   if g_debug then
      hr_utility.set_location ('assact_dml',12);
   end if;
end assact_dml;
-- --
/*
 *  validates rules that control what type of
 *  actions we can perform a rollback or mark
 *  for retry payroll action on.
 */
procedure val_pact_rr_rules (p_info in rollback_rec)
is
   dummy NUMBER;
begin
   if g_debug then
      hr_utility.set_location('val_pact_rr_rules', 10);
   end if;
--
   if(p_info.rollback_mode = 'RETRY')
   then
      if(p_info.action_type in ( 'E', 'H', 'D', 'PP'))
      then
         hr_utility.set_message(801, 'HR_7093_ACTION_CANT_RETPAY');
         hr_utility.set_message_token('ACTION_NAME', p_info.action_name);
         hr_utility.raise_error;
      end if;
   end if;
--
   -- Special check for Purge for both modes.
   -- We are not allowed to rollback or mark for retry an entire
   -- purge payroll action if there are any assignment actions
   -- with secondary_status = 'C'.
   if (p_info.action_type = 'Z') then
      declare
         l_complete number;
      begin
         select count(*)
         into   l_complete
         from   pay_assignment_actions act
         where  act.payroll_action_id = p_info.pact_id
         and    act.secondary_status  = 'C';
--
         if(l_complete > 0) then
            hr_utility.set_message(801, 'PAY_289020_PUR_CANT_ROLLBACK');
            hr_utility.raise_error;
         end if;
      end;
   end if;
end val_pact_rr_rules;
--
--
/*
 *  checks if the process that is being checked for retry has a dependant, or
 *  succeeding, process that is not in a status of complete.
 */
procedure val_dependant (p_info in rollback_rec)
is
   w_payroll_id_1 number(9);

   cursor chk_dep is
      select distinct pac.payroll_action_id
        from pay_assignment_actions  act2,
             pay_action_interlocks   pai,
             pay_assignment_actions  act,
             pay_payroll_actions     pac,
             pay_payroll_actions     pac2
       where pac2.payroll_action_id = p_info.pact_id
         and act2.payroll_action_id = pac2.payroll_action_id
         and pac.payroll_action_id = act.payroll_action_id
         and pai.locking_action_id = act.assignment_action_id
         and pai.locked_action_id = act2.assignment_action_id
         and pac.action_status <> 'C'
         and pac.action_type in ('A', 'H', 'M', 'PP');

begin
   if g_debug then
      hr_utility.set_location('val_dependant', 18);
   end if;

  open chk_dep;
  fetch chk_dep into w_payroll_id_1;

  if chk_dep%found
  then
      if p_info.legislation_code = 'GB' then
         hr_utility.set_message (801, 'HR_52975_ACTION_UNDO_INTLOK_GB');
      else
         hr_utility.set_message (801, 'HR_7507_ACTION_UNDO_INTLOCK');
      end if;
      hr_utility.raise_error;
  end if;

  close chk_dep;
 --
end val_dependant ;
--
/*
 *  validates rules that control what type of actions we
 *  can perform a rollback/mark for retry assignment action on.
 */
procedure val_assact_rr_rules (p_info in rollback_rec)
is
begin
   -- Validate the rollback and mark for retry rules for
   -- assignment actions.
   if g_debug then
      hr_utility.set_location('val_assact_rr_rules', 10);
   end if;
--
   if(p_info.rollback_mode = 'RETRY')
   then
      if(p_info.action_type in (  'PRU', 'E', 'M', 'H', 'D', 'PP') or
         (p_info.action_type = 'T' and p_info.sub_ledger_acc = 'N'))
      then
         hr_utility.set_message(801, 'HR_7508_ACTION_ACT_RR_RULE');
         hr_utility.set_message_token('ACTION_NAME', p_info.action_name);
         hr_utility.raise_error;
      end if;
   else
      -- !!!! note - temporary change for RN project.
      -- allow rollback of individual Magnetic Transfer assact.
      if(p_info.action_type in ('Q',   'U', 'E', 'PRU') or
         (p_info.action_type = 'T' and p_info.sub_ledger_acc = 'N'))
      then
         hr_utility.set_message(801, 'HR_7508_ACTION_ACT_RR_RULE');
         hr_utility.set_message_token('ACTION_NAME', p_info.action_name);
         hr_utility.raise_error;
      end if;
   end if;
end val_assact_rr_rules;
--
/*
 *  validate the parameters passed to the rollback
 *  assignment and payroll action procedures.
 */
procedure val_params (p_info in rollback_rec)
is
begin
   --  where applicable, check that parameters
   --  have reasonable values.
   if g_debug then
      hr_utility.set_location('val_params', 10);
   end if;
   if(p_info.rollback_mode not in ('RETRY', 'ROLLBACK', 'BACKPAY'))
   then
      hr_utility.set_message(801, 'HR_7000_ACTION_BAD_ROLL_MODE');
      hr_utility.raise_error;
   end if;
--
   if(p_info.dml_mode not in ('FULL', 'NO_COMMIT', 'NONE'))
   then
      hr_utility.set_message(801, 'HR_7509_ACTION_BAD_DML_MODE');
      hr_utility.raise_error;
   end if;
--
   --  certain values are illegal if they are combined.
   --  note that these checks are only applicable to
   --  the payroll action rollback level.
   if(p_info.rollback_level = 'P')
   then
      null;
   end if;
end val_params;
--
/*
 *  if the rollback payroll action is being called in
 *  single threaded mode, we need to insert a range
 *  row. This allows the processing to have the same
 *  interface for both multi and single-thread modes.
 *  NOTE: no date track restriction is required for
 *  this statement, as we obtaining min and max
 *  values.  This happens to be convenient for Purge.
 */
procedure single_thread_range(p_info in rollback_rec)
is
   l_payroll_action_id number;
begin
   l_payroll_action_id := p_info.pact_id;
   --  ok, we are single-threading. Need to remove any existing
   --  range rows (thought there are unlikely to be any), and
   --  then insert a special row.
   if g_debug then
      hr_utility.set_location('single_thread_range', 10);
   end if;
   delete from pay_population_ranges range
   where  range.payroll_action_id = l_payroll_action_id;
--
   if g_debug then
      hr_utility.set_location('single_thread_range', 20);
   end if;

   if (p_info.object_type is null) then
      insert into pay_population_ranges (
             payroll_action_id,
             chunk_number,
             starting_person_id,
             ending_person_id,
             range_status)
      select /*+ USE_NL(asg)
                 INDEX(asg PER_ASSIGNMENTS_F_PK) */
             pac.payroll_action_id,
             1,
             min(asg.person_id),
             max(asg.person_id),
             'U'
      from   pay_payroll_actions    pac,
             pay_assignment_actions act,
             per_all_assignments_f  asg
      where  pac.payroll_action_id = l_payroll_action_id
      and    act.payroll_action_id = pac.payroll_action_id
      and    asg.assignment_id     = act.assignment_id
      group by pac.payroll_action_id;
   else
      insert into pay_population_ranges (
             payroll_action_id,
             chunk_number,
             starting_person_id,
             ending_person_id,
             range_status)
      select pac.payroll_action_id,
             1,
             min(act.object_id),
             max(act.object_id),
             'U'
      from   pay_payroll_actions    pac,
             pay_assignment_actions act
      where  pac.payroll_action_id = l_payroll_action_id
      and    act.payroll_action_id = pac.payroll_action_id
      group by pac.payroll_action_id;
   end if;
--
   if g_debug then
      hr_utility.set_location('single_thread_range', 30);
   end if;
end single_thread_range;
--
/*
 *  this is called when we are rolling back. We need to know
 *  whether or not the assignment actions have all been
 *  deleted, otherwise we do not wish to remove the payroll
 *  action.
 */
function rollback_complete(p_payroll_action_id in number)
return boolean is
   dummy number;
begin
   select null
   into   dummy
   from   sys.dual
   where  exists (
          select null
          from   pay_assignment_actions act
          where  act.payroll_action_id = p_payroll_action_id);
--
   -- There are still assignment actions.
   return(false);
--
exception
   when no_data_found then
      --  There are no longer assignment actions.
      --  the rollback is considered complete.
      return(true);
end rollback_complete;
--
/*
 *  If we are limiting the dml that can be performed, this procedure
 *  is called to ensure that we do not breach the limit.
 *  This should only occur when the rollback procedure is called
 *  from a forms session. In this case, user is advised to launch
 *  a Rollback process from SRS.
 */
procedure val_limit_dml(p_info in rollback_rec) is
   action_count number;
begin
   select count(*)
   into   action_count
   from   pay_assignment_actions act
   where  act.payroll_action_id = p_info.pact_id
   and    rownum < (p_info.max_single_undo + 2);
--
   if(action_count > p_info.max_single_undo) then
      hr_utility.set_message(801, 'HR_7722_ACTION_COMMIT_LIMIT');
      hr_utility.set_message_token('COMMIT_LIMIT',p_info.max_single_undo);
      hr_utility.raise_error;
   end if;
end val_limit_dml;
--
/*
 *  Perform the rolling back or Marking for Retry of a Payroll Action.
 *  Can also be used for validation that such an action is
 *  permissible. For the use and meaning of the parameters, please
 *  refer to the package header.
 */
procedure rollback_payroll_action
(
   p_payroll_action_id    in number,
   p_rollback_mode        in varchar2 default 'ROLLBACK',
   p_leave_base_table_row in boolean  default false,
   p_all_or_nothing       in boolean  default true,
   p_dml_mode             in varchar2 default 'NO_COMMIT',
   p_multi_thread         in boolean  default false,
   p_limit_dml            in boolean  default false,
   p_grp_multi_thread     in boolean  default false
) is
   info     rollback_rec;   -- 'global' information.
   c_indent varchar2(40);
   l_date_earned date;
begin
   g_debug := hr_utility.debug_enabled;
   if g_debug then
      c_indent := 'py_rollback_pkg.rollback_payroll_action';
      hr_utility.set_location(c_indent, 5);
   end if;
   --  set up the parameters.
   info.rollback_mode      := p_rollback_mode;
   info.rollback_level     := 'P';  -- processing entire Payroll Action.
   info.leave_row          := p_leave_base_table_row;
   info.all_or_nothing     := p_all_or_nothing;
   info.multi_thread       := p_multi_thread;
   info.grp_multi_thread   := p_grp_multi_thread;
   info.dml_mode           := p_dml_mode;
   info.limit_dml          := p_limit_dml;
   info.pact_id            := p_payroll_action_id;
--
   -- Set the Continuous Calc override flag, so that the trigger points
   -- are not fired.
   pay_continuous_calc.g_override_cc := TRUE;
--
   -- Ensure delete from gl_interface in remove_gl_entries on
   -- each execution.
   mtgl_mode_cached := FALSE;
--
   --  how many errors can we stand, what commit limit do we have?
   info.max_errors_allowed := action_parameter('MAX_ERRORS_ALLOWED');
   info.max_single_undo := action_parameter('MAX_SINGLE_UNDO');
   info.set_date_earned := action_parameter('SET_DATE_EARNED');
--
   --  May wish to limit number of actions that can
   --  be rolled back.  This is mainly for forms.
   if(info.limit_dml and not info.multi_thread) then
      val_limit_dml(info);
   end if;
--
   get_pact_info(info);      --  get payroll action level information.
--
   info.retro_purge := legislation_rule(info.legislation_code, 'RETRO_DELETE');
   pay_core_utils.get_upgrade_status(info.bg_id,
                                     'SINGLE_BAL_TABLE',
                                     info.single_bal_table);
--
   val_params(info);         --  validate parameters passed in.

   if(info.rollback_mode = 'RETRY' and info.action_status in ('C', 'S'))
   then
      val_dependant(info);   --  does the payroll action have an uncompleted
                             --  dependant payroll action?
   end if;

   val_pact_rr_rules(info);  --  can we rollback the payroll action.
--
   if(not info.multi_thread) then
      --  single threading, insert special range row.
      single_thread_range(info);
   end if;
--
   -- Depending on the dml mode, we may wish to
   -- set a savepoint.
   if(info.dml_mode = 'NONE') then
      if g_debug then
         hr_utility.set_location(c_indent, 10);
      end if;
      savepoint no_dml;
   end if;
--
   if (info.action_type = 'PRU') then
      remove_pact_payment(info.pact_id);
   end if;
--
   assact_dml(info);            -- do the rollback of assact rows.
--
-- delete archive_items for the context of payroll_action_id
--
   if g_debug then
      hr_utility.set_location(c_indent, 12);
   end if;
--
   -- Remove archiver items at the payroll action level
   if (info.action_type = 'X' or
       info.action_type = 'PP' or
       info.action_type = 'M') then
     remove_archive_items(info, info.pact_id, 'PA');
     remove_action_information(info.pact_id, 'PA');
     remove_file_details(info, info.pact_id, 'PPA');
   end if;
--
   if g_debug then
      hr_utility.set_location(c_indent, 15);
   end if;
--
   --
   -- delete group level run balances
   --
   if (info.sequenced_flag and
       rollback_complete(info.pact_id)) then
     delete from pay_run_balances
     where  payroll_action_id = info.pact_id;
   end if;
--
   if(info.dml_mode = 'NONE') then
      hr_utility.set_location(c_indent, 20);
      rollback to savepoint no_dml;
   end if;
--
   --  we insert a message to indicate that the rollback was successful.
   --  Note that we perform this whether or not we are going to actually
   --  delete the payroll action row, as we assume that the caller
   --  will perform this action, even if we do not. Also note that it is
   --  only done if we have rolled back all assignment actions.
   --  Finally, if we are multi-threading, we wish to leave the process
   --  to insert the message.
   if(info.rollback_mode = 'ROLLBACK' and
      rollback_complete(info.pact_id) and
      not info.multi_thread)
   then
      remove_messages(info, 'P');
      -- Only insert message if the action is not an
      -- initial balance upload.
      if (info.action_type <> 'I') then
        ins_rollback_message(info, 'P');
      end if;
   end if;
--
   -- now if the rollback is successful then we update the bee batch.
   if (rollback_complete(info.pact_id) and info.action_type ='BEE') then
      pay_mix_rollback_pkg.set_status(info.pact_id,info.leave_row);
   end if;
--
   --  now we perform any action that we require (and
   --  are allowed to perform) on the payroll action
   --  row itself. Normally, we would not wish to touch
   --  the row if the client was a form.
   if(not info.leave_row and rollback_complete(info.pact_id))
   then
      --  delete the payroll action row if we are told to.
      if g_debug then
         hr_utility.set_location(c_indent, 30);
      end if;
      delete from pay_chunk_status
       where payroll_action_id = info.pact_id;
      delete from pay_payroll_actions pac
      where  pac.payroll_action_id = info.pact_id;
   else
     if (info.sequenced_flag=FALSE) then
       if (info.rollback_mode <> 'BACKPAY'
          and info.rollback_mode <> 'RETRY'
          and info.action_type <> 'BEE') then
         if info.rollback_level = 'P' then
           if info.set_date_earned = 'Y' then
              select max(date_earned)
              into   l_date_earned
              from   pay_payroll_actions    locked_pact,
                     pay_assignment_actions locked,
                     pay_assignment_actions locking,
                     pay_action_interlocks  locks
              where  locking.payroll_action_id    =info.pact_id
              and    locking.assignment_action_id =locks.locking_action_id
              and    locked.assignment_action_id  =locks.locked_action_id
              and    locked.payroll_action_id     =locked_pact.payroll_action_id;
--
              update pay_payroll_actions pac
              set    pac.date_earned              = l_date_earned
              where  pac.payroll_action_id        = info.pact_id;
           end if;
         end if;
       end if;
     end if;
   end if;
--
   --  decide if we wish to perform that final commit
   if(info.dml_mode = 'FULL')
   then
      if g_debug then
         hr_utility.set_location(c_indent, 40);
      end if;
      commit;
   end if;
--
   pay_continuous_calc.g_override_cc := FALSE;
--
   exception
      when others then
        pay_continuous_calc.g_override_cc := FALSE;
        raise;
end rollback_payroll_action;
--
/*
 *  Interface to rollback/mark for retry of an assignment action.
 *  see the package header for details of the parameters.
 *  Takes into account assignment level erroring.
 */
procedure rollback_ass_action
(
   p_assignment_action_id in number,
   p_rollback_mode        in varchar2 default 'ROLLBACK',
   p_leave_base_table_row in boolean  default false,
   p_all_or_nothing       in boolean  default true,
   p_dml_mode             in varchar2 default 'NO_COMMIT',
   p_multi_thread         in boolean  default false,
   p_grp_multi_thread     in boolean  default false
) is
   info     rollback_rec;
   c_indent varchar2(40);
   l_date_earned date;
   l_current_date_earned date;
   src_action_id number;
--
begin
   g_debug := hr_utility.debug_enabled;
   --  need to know the payroll action.
   if g_debug then
      c_indent := 'py_rollback_pkg.rollback_ass_action';
      hr_utility.set_location(c_indent, 10);
   end if;
   select act.payroll_action_id, act.source_action_id, act.object_type
   into   info.pact_id, src_action_id, info.object_type
   from   pay_assignment_actions act
   where  act.assignment_action_id = p_assignment_action_id;
--
   --  instantiate the other parameters that are relevant.
   info.assact_id          := p_assignment_action_id;
   info.rollback_mode      := p_rollback_mode;
   info.rollback_level     := 'A';
   info.leave_row          := p_leave_base_table_row;
   info.dml_mode           := p_dml_mode;
   info.multi_thread       := p_multi_thread;
   info.grp_multi_thread   := p_grp_multi_thread;
--
   -- Check that it is a master action.
   if src_action_id is not null then
      hr_utility.set_message(801, 'PAY_289114_RLBK_CHLD_ACT');
      hr_utility.raise_error;
   end if;
--
   --  how many errors can we stand, what commit limit do we have?
   info.max_errors_allowed := action_parameter('MAX_ERRORS_ALLOWED');
   info.max_single_undo := action_parameter('MAX_SINGLE_UNDO');
   info.set_date_earned := action_parameter('SET_DATE_EARNED');
--
   get_pact_info(info);  --  get info about payroll action.
--
   info.retro_purge := legislation_rule(info.legislation_code, 'RETRO_DELETE');
   pay_core_utils.get_upgrade_status(info.bg_id,
                                     'SINGLE_BAL_TABLE',
                                     info.single_bal_table);
--
   val_params(info);     --  parameter validation.
--
   --  For BackPay, we do not care about normal
   --  rules about whether a single action of a
   --  particular action type can be rolled
   --  back or not.
   if(info.rollback_mode <> 'BACKPAY') then
      val_assact_rr_rules(info);
   else
      select assignment_id
        into info.assignment_id
        from pay_assignment_actions
       where assignment_action_id = info.assact_id;
   end if;
--
   --  perform the rollback/mark for retry itself.
   --  from now on, errors are considered to be assignment action
   --  level. Depending on the mode, we may stop immediately.
   --  In backpay case, we do not wish to validate the rollback,
   --  simply wishing to perform it. This is because BackPay does
   --  only performs rollback on Reversals, Runs and QuickPays.
   begin
--
      -- in case we fail.
      savepoint before;
--
      -- Set the Continuous Calc override flag, so that the trigger points
      -- are not fired.
      pay_continuous_calc.g_override_cc := TRUE;
--
      if(info.rollback_mode <> 'BACKPAY') then
         val_assact_rollback(info);
      end if;
--
      -- Only perform dml if allowed to.
      if(info.dml_mode <> 'NONE') then
         do_assact_rollback(info);
         -- update date earned for payroll action
         if (info.sequenced_flag=FALSE) then
          if (info.rollback_mode <> 'BACKPAY'
             and info.rollback_mode <> 'RETRY'
             and info.action_type <> 'X'
             and info.action_type <> 'BEE') then
            if info.rollback_level = 'A' then

              if info.set_date_earned = 'Y' then
                begin
                  -- Handle that the rolled back assignment action
                  -- may have been the last one
                  select max(locked_pact.date_earned), locking_pact.date_earned
                  into   l_date_earned, l_current_date_earned
                  from   pay_payroll_actions    locked_pact,
                         pay_assignment_actions locked,
                         pay_assignment_actions locking,
                         pay_action_interlocks  locks,
                         pay_payroll_actions    locking_pact
                  where  locking_pact.payroll_action_id =info.pact_id
                  and    locking.payroll_action_id    =locking_pact.payroll_action_id
                  and    locking.assignment_action_id =locks.locking_action_id
                  and    locked.assignment_action_id  =locks.locked_action_id
                  and    locked.payroll_action_id     =locked_pact.payroll_action_id
                  group by locking_pact.date_earned;
--
                  if (l_date_earned < l_current_date_earned) then
                    update pay_payroll_actions pac
                    set    pac.date_earned              = l_date_earned
                    where  pac.payroll_action_id        = info.pact_id;
                  end if;
--
                exception
                  when others then
                    update pay_payroll_actions pac
                    set    pac.date_earned              = null
                    where  pac.payroll_action_id        = info.pact_id;
                end;
              end if;
            end if;
          end if;
         end if;
--
--       Remove the group run balances for resersal.
--
         if (info.action_type = 'V') then
--
           delete from pay_run_balances
            where payroll_action_id = info.pact_id;
--
         end if;
      end if;
      g_error_count := 0;     --  only count consecutive errors.
      pay_continuous_calc.g_override_cc := FALSE;
   exception
      -- Throw away any work we have done.
      when others then
         rollback to savepoint before;
         pay_continuous_calc.g_override_cc := FALSE;
         if(p_all_or_nothing) then
            raise;
         else
            assact_error(info, sqlcode, sqlerrm);
         end if;
   end;
--
   --  we may wish to commit.
   if(info.dml_mode = 'FULL')
   then
      commit;
   end if;
end rollback_ass_action;
--
--
begin
--
   --  Having the error counter as a package global and
   --  initialising it here allows the error counting
   --  mechanism to work whether we are rolling back a
   --  whole payroll action or assignment action by
   --  assignment action.
   g_error_count := 0;
--   hr_utility.trace_on(null, 'ORACLE');
end py_rollback_pkg;

/
