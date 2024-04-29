--------------------------------------------------------
--  DDL for Package Body PAY_CC_PROCESS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_CC_PROCESS_UTILS" AS
/* $Header: pyccutl.pkb 120.2.12010000.4 2009/05/19 07:15:59 priupadh ship $ */

  g_pkg varchar2(80) := 'PAY_CC_PROCESS_UTILS';

  -- Global for PAY schema name
  g_pay_schema  varchar2(30) := null;

  /* Name      : range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows.
     Arguments :
     Notes     :
  */
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is

  begin

--
-- hr_utility.trace('>>>  NOW build sql string');
      /* Effective date will be set to sysdate  for CC*/
      sqlstr := 'select  distinct asg.person_id
                from
                        per_assignments_f      asg,
                        pay_payroll_actions    pa1
                 where  pa1.payroll_action_id    = :payroll_action_id
                 and    asg.payroll_id =
                          pay_core_utils.get_parameter(''PAYROLL_ID'',
                                 pa1.legislative_parameters)
                 and    pa1.effective_date < asg.effective_end_date
                order by asg.person_id';
--



end range_cursor;

--
 /* Name    : action_creation
  Purpose   : This creates the assignment actions for a specific chunk.
  Arguments :
  Notes     :
 */
--
procedure action_creation(p_pactid in number,
                          p_stperson in number,
                          p_endperson in number,
                          p_chunk in number) is
  CURSOR c_actions
      (
         cp_pactid    number,
         cp_payroll_id number,
         cp_stperson  number,
         cp_endperson number
      ) is
      select distinct ppe.assignment_id,ppe.creation_date
      from
             per_all_assignments_f          paf,
             per_periods_of_service         pos,
             pay_payroll_actions            ppa,
             pay_process_events             ppe
      where  ppa.payroll_action_id          = cp_pactid
      and    paf.payroll_id     = cp_payroll_id
      and    ppe.effective_date between paf.effective_start_date
                                    and paf.effective_end_date
      and    pos.period_of_service_id       = paf.period_of_service_id
      and    pos.person_id between cp_stperson and cp_endperson
      and    ppe.assignment_id = paf.assignment_id
      and    ppe.change_type in ('ASG', 'GRE', 'COST_CENTRE', 'PAYMENT',
                                 'DATE_EARNED', 'DATE_PROCESSED');
--      for update of paf.assignment_id, pos.period_of_service_id;
--

  CURSOR csr_act_info(cp_actid number) is
    select
      pay_core_utils.get_parameter('PAYROLL_ID',ppa.legislative_parameters)
    from  pay_payroll_actions ppa
    where ppa.payroll_action_id = cp_actid;


  l_lockingactid    NUMBER;
  l_last_run_date   DATE;
  l_payroll_id      NUMBER;

  l_proc varchar2(80) :=  g_pkg||'action_creation';
--
begin
  hr_utility.set_location(l_proc, 10);

  -->>> PHASE 1: Get the payroll id for this pay act id
  --
  open csr_act_info(p_pactid);
  fetch csr_act_info into l_payroll_id;
  close csr_act_info;

  -->>> PHASE 2: Create action records
  for asgrec in c_actions(p_pactid,l_payroll_id,p_stperson, p_endperson ) loop
     -->>> PHASE 3: Get the date the last time the CC process was run for this payroll.
     pay_recorded_requests_pkg.get_recorded_date(
       p_process        => 'CC_ASG',
       p_recorded_date  => l_last_run_date,
       p_attribute1     => asgrec.assignment_id
     );
     hr_utility.trace('>>> Last time CC was run for payroll '||l_payroll_id
                     ||' is: '||l_last_run_date);

     if (l_last_run_date < asgrec.creation_date) then
       SELECT pay_assignment_actions_s.nextval
       INTO l_lockingactid
       FROM dual;
       -- insert the action record.
       hr_nonrun_asact.insact(l_lockingactid,asgrec.assignment_id,p_pactid,p_chunk, null);
     end if;
  end loop;
  hr_utility.set_location(l_proc, 900);

end action_creation;
--


--
 /* Name      : archinit
    Purpose   : This performs the US specific initialisation section.
    Arguments :
    Notes     :
 */
procedure archinit(p_payroll_action_id in number) is
      jurisdiction_code      pay_state_rules.jurisdiction_code%TYPE;
      l_state                VARCHAR2(30);
begin

   null;
end archinit;
--

  /* Name      : archive_data
     Purpose   : This performs the US specific employee context setting for the SQWL
                 report.
     Arguments :
     Notes     :
  */
 procedure archive_data(p_assactid in number, p_effective_date in date) is
--
--
  cursor get_dates (assact_id number, p_change_type varchar2) is
  select nvl(min(ppe.effective_date), hr_api.g_eot)
                 effective_date
    from pay_process_events ppe,
         pay_assignment_actions paa
   where paa.assignment_action_id = assact_id
     and paa.assignment_id = ppe.assignment_id
     and change_type = p_change_type;
--
  cursor get_costings(p_assact_id number, p_effdate date) is
  select paa.assignment_action_id
    from pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_assignment_actions paa_arch
   where paa_arch.assignment_action_id = p_assact_id
     and paa.assignment_id = paa_arch.assignment_id
     and paa.action_status = 'C'
     and paa.payroll_action_id = ppa.payroll_action_id
     and ppa.action_type = 'C'
     and ppa.effective_date >= p_effdate
     and not exists (select ''
                       from pay_action_interlocks pai
                      where pai.locked_action_id = paa.assignment_action_id)
   order by paa.action_sequence desc;
--
  cursor get_prepay(p_assact_id number, p_effdate date) is
  select paa.assignment_action_id
    from pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_assignment_actions paa_arch
   where paa_arch.assignment_action_id = p_assact_id
     and paa.assignment_id = paa_arch.assignment_id
     and paa.action_status = 'C'
     and paa.payroll_action_id = ppa.payroll_action_id
     and ppa.action_type in ('P', 'U')
     and ppa.effective_date >= p_effdate
     and not exists (select ''
                   from pay_action_interlocks pai
                   where pai.locked_action_id = paa.assignment_action_id)
   order by paa.action_sequence desc;
--
  cursor get_run(p_assact_id number, p_effdate date) is
  select paa.assignment_action_id,
         ppa.effective_date,
         paa.assignment_id
    from pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_assignment_actions paa_arch
   where paa_arch.assignment_action_id = p_assact_id
     and paa.assignment_id = paa_arch.assignment_id
     and paa.action_status in ('C', 'S')
     and paa.payroll_action_id = ppa.payroll_action_id
     and paa.source_action_id is null
     and ppa.action_type in ('R', 'Q','V','B')
     and ppa.effective_date >= p_effdate
     and not exists (select ''
                       from pay_action_interlocks pai,
                            pay_assignment_actions paa2,
                            pay_payroll_actions    ppa2,
                            pay_action_interlocks  pai2
                      where pai.locked_action_id = paa.assignment_action_id
                      and pai.locking_action_id = paa2.assignment_action_id
                      and paa2.payroll_action_id = ppa2.payroll_action_id
                      and ppa2.action_type in ('P', 'U', 'C')
                      and pai2.locked_action_id = paa2.assignment_action_id
                    )
     and    not exists (
            select null
            from   pay_action_classifications acl,
                   pay_payroll_actions        pa2,
                   pay_assignment_actions     ac2
            where  ac2.assignment_id       = paa.assignment_id
            and    pa2.payroll_action_id   = ac2.payroll_action_id
            and    acl.classification_name = 'SEQUENCED'
            and    pa2.action_type         = acl.action_type
            and    pa2.action_type not in ('R', 'Q','V','B')
            and    ac2.action_sequence > paa.action_sequence
            )
     and not exists (
            select null
            from   pay_action_classifications acl,
                   pay_payroll_actions        pa2,
                   pay_assignment_actions     ac2
            where  ac2.assignment_id       = paa.assignment_id
            and    pa2.payroll_action_id   = ac2.payroll_action_id
            and    acl.classification_name = 'SEQUENCED'
            and    pa2.action_type         = acl.action_type
            and    pa2.action_type in ('R', 'Q','V','B')
            and    ac2.action_sequence > paa.action_sequence
            and    exists (select ''
                             from pay_action_interlocks pai,
                                  pay_assignment_actions paa2,
                                  pay_payroll_actions    ppa2,
                                  pay_action_interlocks  pai2
                            where pai.locked_action_id = ac2.assignment_action_id
                              and pai.locking_action_id = paa2.assignment_action_id
                              and paa2.payroll_action_id = ppa2.payroll_action_id
                              and ppa2.action_type in ('P', 'U', 'C')
                              and pai2.locked_action_id = paa2.assignment_action_id
                          )
            )
   order by paa.action_sequence desc;
--
  cursor get_locked_actions (p_assact_id number) is
  select paa.assignment_action_id
    from pay_assignment_actions paa,
         pay_action_interlocks pai,
         pay_payroll_actions ppa
   where pai.locked_action_id = p_assact_id
     and pai.locking_action_id = paa.assignment_action_id
     and paa.payroll_action_id = ppa.payroll_action_id
     and paa.action_status = 'C'
     and ppa.action_type in ('P','U', 'C')
   order by paa.action_sequence desc;
--

  cursor csr_act_info(cp_actid number) is
    select
      paa.assignment_id,
      pay_core_utils.get_parameter('PAYROLL_ID',ppa.legislative_parameters),
      ppa.business_group_id
    from pay_assignment_actions paa,
         pay_payroll_actions ppa
    where paa.payroll_action_id = ppa.payroll_action_id
    and   paa.assignment_action_id = cp_actid;



cursor csr_get_de_min(cp_assact_id number) is
  select min(ppa.date_earned)
    from pay_payroll_actions ppa,
         pay_assignment_actions paa,
         pay_assignment_actions paa_arch
   where paa_arch.assignment_action_id = cp_assact_id
     and paa.assignment_id = paa_arch.assignment_id
     and paa.action_status in ('C', 'S')
     and paa.payroll_action_id = ppa.payroll_action_id
     and paa.source_action_id is null
     and ppa.action_type in ('R', 'Q')
     and not exists (
           select 1
           from pay_action_interlocks pai,
                pay_assignment_actions paa2,
                pay_payroll_actions    ppa2,
                pay_action_interlocks  pai2
           where pai.locked_action_id = paa.assignment_action_id
           and pai.locking_action_id = paa2.assignment_action_id
           and paa2.payroll_action_id = ppa2.payroll_action_id
           and ppa2.action_type in ('P', 'U', 'C')
           and pai2.locked_action_id = paa2.assignment_action_id
         )
     and not exists (
           select 1
           from   pay_action_classifications acl,
                  pay_payroll_actions        pa2,
                  pay_assignment_actions     ac2
           where  ac2.assignment_id       = paa.assignment_id
           and    pa2.payroll_action_id   = ac2.payroll_action_id
           and    acl.classification_name = 'SEQUENCED'
           and    pa2.action_type         = acl.action_type
           and    pa2.action_type not in ('R', 'Q')
           and    ac2.action_sequence > paa.action_sequence
         );

   cursor c_ele(cp_assact_id number, cp_bg number
         , cp_de_min date, cp_this_run_date date) is
   SELECT DISTINCT
          prr.source_id              entry
   ,      pet.recalc_event_group_id  event_group
   FROM   pay_run_results        prr
   ,      pay_assignment_actions paa
   ,      pay_payroll_actions    ppa
   ,      pay_assignment_actions paa_arch
   ,      pay_element_types_f    pet
   WHERE  paa_arch.assignment_action_id = cp_assact_id
   and    paa.assignment_id = paa_arch.assignment_id
   AND    prr.source_type = 'E'
   AND    prr.assignment_action_id = paa.assignment_action_id
   AND    paa.payroll_action_id = ppa.payroll_action_id
   AND    prr.element_type_id = pet.element_type_id
   AND    cp_this_run_date between pet.effective_start_date and pet.effective_end_date
   AND    ppa.business_group_id = cp_bg
   AND    ppa.action_type in ('R', 'Q', 'B', 'V')
   AND    ppa.date_earned >= cp_de_min
   UNION
   SELECT DISTINCT
          pee.element_entry_id       entry
   ,      pet.recalc_event_group_id  event_group
   FROM   pay_element_entries_f  pee
   ,      pay_assignment_actions paa
   ,      pay_element_links_f     pel
   ,      pay_element_types_f    pet
   WHERE  paa.assignment_action_id = cp_assact_id
   AND    paa.assignment_id = pee.assignment_id
   AND    pee.element_link_id = pel.element_link_id
   AND    pel.element_type_id = pet.element_type_id
   AND    pee.effective_end_date
             between pel.effective_start_date and pel.effective_end_date
   AND    cp_this_run_date
             between pet.effective_start_date and pet.effective_end_date
   AND    pee.effective_end_date >= cp_de_min;

  cursor csr_min_date(cp_creation_date_from date,
                    cp_change_type varchar2,
                    cp_ass_id number)  is
    select least(effective_date)
    from  pay_process_events
    where creation_date > cp_creation_date_from
    and   change_type   = cp_change_type
    and   status <> 'C'
    and   assignment_id = cp_ass_id;


  l_min_de_date          date; --Placeholder for result of above csr_get_de_min
  l_tax_unit_id          number;
  l_business_group_id    number;
  l_min_date 		 DATE;
  l_max_date 		 DATE;
  l_run_date 	 	 DATE;
  l_payroll_id 		 NUMBER;
  l_assignment_id 	 NUMBER;
  l_ee_min_dedate   	 DATE := hr_api.g_eot; --Interim placeholders holding
  l_ee_min_dpdate   	 DATE := hr_api.g_eot; --min of ee's events type DATE_EARNED and DATE_PROCESSED
  l_aact_min_dedate      DATE := hr_api.g_eot; --Interim placeholders for
  l_aact_min_dedate_eff  DATE := hr_api.g_eot; --
  l_aact_min_dpdate      DATE := hr_api.g_eot; --Overall min for asg action events types
  cstdate           	 DATE := hr_api.g_eot;  -- Final placeholders for the final dates
  rundate           	 DATE := hr_api.g_eot;
  paydate           	 DATE := hr_api.g_eot;

  -- Holders for results from the interpreter package
  l_de_det_tab_out       pay_interpreter_pkg.t_detailed_output_table_type;
  l_de_date_out          pay_interpreter_pkg.t_proration_dates_table_type;
  l_de_chge_out          pay_interpreter_pkg.t_proration_type_table_type;
  l_de_type_out          pay_interpreter_pkg.t_proration_type_table_type;

  l_dp_det_tab_out       pay_interpreter_pkg.t_detailed_output_table_type;
  l_dp_date_out          pay_interpreter_pkg.t_proration_dates_table_type;
  l_dp_chge_out          pay_interpreter_pkg.t_proration_type_table_type;
  l_dp_type_out          pay_interpreter_pkg.t_proration_type_table_type;

  l_proc  varchar2(80) := g_pkg||'.archive_data';
BEGIN
  hr_utility.set_location(' Entering: '||l_proc,10);

  -->>> PHASE 1: Get details on the p act, include the date this CC run started
  --    held in the legis_params column, put there by range_cursor

  -- get current date and time , this can be set in pay_recorded requests
  -- when assignment action has been processed.
  select sysdate
  into l_run_date
  from dual;

  -- hr_utility.trace('>>> p_assactid '||p_assactid);
  -- hr_utility.set_location(l_proc, 20);

  open csr_act_info(p_assactid);
  fetch csr_act_info into
           l_assignment_id,l_payroll_id,
           l_business_group_id;
  close csr_act_info;


  -->>> PHASE 2: Loop through all element_entries in our date range
  --

  --Get the element entries for the asg_act, where date earned
  -- >= min de date , (ie those that will have been included in the last payroll.)

  open csr_get_de_min(p_assactid);
  fetch csr_get_de_min into l_min_de_date;
  close csr_get_de_min;

  -- We need to tell the Interpreter we are only interested in events between
  -- the last time CC was run, and the time this run was begun

  pay_recorded_requests_pkg.get_recorded_date(
       p_process        => 'CC_ASG',
       p_recorded_date  => l_min_date,
       p_attribute1     => l_assignment_id);

  -- just got the min creation date were interested in, max is
  -- this run date got from csr_act_info
  l_max_date := l_run_date;

  -- hr_utility.trace('>> Get element entry ids asg act id: '||p_assactid||', since l_min_de_date: '||to_char(l_min_de_date,'DD-MM-RRRR'));
  -- hr_utility.trace('>> Got date for payroll id: '||l_payroll_id||' last CC date: '||to_char(l_min_date,'DD-MM-RRRR'));
  FOR l_ele_rec in c_ele(p_assactid,l_business_group_id
                          ,l_min_de_date,l_run_date) LOOP
      --
      -- Get the tables of results from the interpreter package
      -- This is a construct of all the valid events that have occurred
      --
      hr_utility.trace('>>> Calling interpreter for ee: '||l_ele_rec.entry);
      hr_utility.trace('>>> Events in range '||l_min_date||' to '||l_max_date);


      -->>> PHASE 3a: Call Interpreter in DATE_EARNED mode
      --
      -- CC mark for retry requires the min date for an events with DATE_EARNED
      -- So get all such events and find minimum
      pay_interpreter_pkg.entry_affected(
            p_element_entry_id      => l_ele_rec.entry
      ,     p_assignment_action_id  => null
      ,     p_assignment_id         => l_assignment_id
      ,     p_mode                  => 'DATE_EARNED'
      ,     p_process               => null --dont care (as long as doesnt restrict)
      ,     p_event_group_id        => l_ele_rec.event_group
      ,     p_process_mode          => 'ENTRY_CREATION_DATE'
      ,     p_start_date            => l_min_date
      ,     p_end_date              => l_max_date
      ,     p_process_date          => l_run_date
      ,     t_detailed_output       => l_de_det_tab_out
      ,     t_proration_dates       => l_de_date_out
      ,     t_proration_change_type => l_de_chge_out
      ,     t_proration_type        => l_de_type_out);
      --

      -- Need the min date for all of the modes
      hr_utility.trace('>>> TOTAL NUMBER OF DATE_EARNED EVENTS FOR ee '
                          ||l_ele_rec.entry ||' IS '||l_de_det_tab_out.COUNT);

      if (l_de_det_tab_out.COUNT <> 0) then
      FOR i in 1..l_de_det_tab_out.COUNT loop
        hr_utility.trace('Discovered Event: '||l_de_det_tab_out(i).datetracked_event
                 ||' Change mode '||l_de_det_tab_out(i).change_mode
                 ||' - '||l_de_det_tab_out(i).effective_date );

       IF(   l_de_det_tab_out(i).effective_date <  l_ee_min_dedate) then
         l_ee_min_dedate := l_de_det_tab_out(i).effective_date;
       END IF;
      END LOOP;
    end if;

    -->>> PHASE 3b: Call Interpreter in DATE_PROCESSED mode
    --
    -- CC mark for retry also requires the min date for an events with DATE_PROCESSED
    -- So get all such events and find minimum
    pay_interpreter_pkg.entry_affected(
            p_element_entry_id      => l_ele_rec.entry
      ,     p_assignment_action_id  => null
      ,     p_assignment_id         => l_assignment_id
      ,     p_mode                  => 'DATE_PROCESSED'
      ,     p_process               => null --dont care (as long as doesnt restrict)
      ,     p_event_group_id        => l_ele_rec.event_group
      ,     p_process_mode          => 'ENTRY_CREATION_DATE'
      ,     p_start_date            => l_min_date
      ,     p_end_date              => l_max_date
      ,     p_process_date          => l_run_date
      ,     t_detailed_output       => l_dp_det_tab_out
      ,     t_proration_dates       => l_dp_date_out
      ,     t_proration_change_type => l_dp_chge_out
      ,     t_proration_type        => l_dp_type_out);
      --
      -- Need the min date
      hr_utility.trace('>>> TOTAL NUMBER OF DATE_PROCESSED EVENTS FOR ee '
                          ||l_ele_rec.entry ||' IS '||l_dp_det_tab_out.COUNT);

      if (l_dp_det_tab_out.COUNT <> 0) then
        FOR i in 1..l_dp_det_tab_out.COUNT loop
          hr_utility.trace('Discovered Event: '||l_dp_det_tab_out(i).datetracked_event
                  ||' Change mode '||l_dp_det_tab_out(i).change_mode
                  ||' - '||l_dp_det_tab_out(i).effective_date );

          IF(l_dp_det_tab_out(i).effective_date <  l_ee_min_dpdate) then
             l_ee_min_dpdate := l_dp_det_tab_out(i).effective_date;
          END IF;
        END LOOP;
      end if;

    -->>> PHASE 3c: Record dates against asg act if earlier than past record
    --
    --Now we have the min dates for this ee, only record them permanently
    --against this asg act if they're earlier than our current candidate

    if (l_ee_min_dedate < l_aact_min_dedate) then
      l_aact_min_dedate := l_ee_min_dedate;
    end if;

    if (l_ee_min_dpdate < l_aact_min_dpdate) then
      l_aact_min_dpdate := l_ee_min_dpdate;
    end if;

  END LOOP; -- get next elem entry


  -->>> PHASE 4: We are only interested in 'effective dates' and although DATE_PROCESSED
  --records eff_date in PPE, date_earned does exactly what it says on the tin.
  --So we now fish out the eff_date corresponding to this date_earned.

  select nvl(min(ppa.effective_date), hr_api.g_eot)
  into l_aact_min_dedate_eff
  from pay_payroll_actions ppa,
  pay_assignment_actions paa,
  pay_assignment_actions paa_arch
  where paa_arch.assignment_action_id = p_assactid
  and paa.assignment_id = paa_arch.assignment_id
  and paa.payroll_action_id = ppa.payroll_action_id
  and ppa.action_type in ('R', 'Q')
  and ppa.date_earned >= l_aact_min_dedate;

  --Finally get the min of our two candidates
    rundate := least(l_aact_min_dedate_eff,l_aact_min_dpdate);

  -->>> PHASE 5: Get the prepayment and costing dates
  --

  --Earliest date from PPE
  open csr_min_date(l_min_date,'COST_CENTRE',l_assignment_id);
  fetch csr_min_date into  cstdate;
  close csr_min_date;

  open csr_min_date(l_min_date,'PAYMENT',l_assignment_id);
  fetch csr_min_date into  paydate;
  close csr_min_date;

  --  So Now we have finally got our three driving dates to be used for
  --  mark for retry (yes, a lot of work for three dates)
  --  but now we can finally move on to mark for retry, the most important bit.

      hr_utility.trace('+----- Resulting Dates from Interpreter ----+');
      hr_utility.trace('|      for asg act: '||p_assactid);
      hr_utility.trace('|  rundate:    '||rundate);
      hr_utility.trace('|  cstdate:    '||cstdate);
      hr_utility.trace('|  paydate:    '||paydate);
      hr_utility.trace('+-------------------------------------------+');



  -->>> PHASE 6: Mark for retry all relevant costings
  -- nb. Not interested in GRE dates anymore since retropay changes
  for cstrec in get_costings(p_assactid, cstdate) loop
      hr_utility.trace('|  Rolling Costing back '||cstrec.assignment_action_id);
      py_rollback_pkg.rollback_ass_action
             (
                p_assignment_action_id => cstrec.assignment_action_id,
                p_rollback_mode        => 'RETRY',
                p_multi_thread         => TRUE
             );
  end loop;

  -->>> PHASE 7: Mark for retry all relevant prepayments
  for prerec in get_prepay(p_assactid, paydate) loop
      hr_utility.trace('|  Rolling Prepay back '||prerec.assignment_action_id);
      py_rollback_pkg.rollback_ass_action
             (
               p_assignment_action_id => prerec.assignment_action_id,
               p_rollback_mode        => 'RETRY',
               p_multi_thread         => TRUE
             );
  end loop;

  -->>> PHASE 8: Mark for retry all relevant runs
  for runrec in get_run(p_assactid, rundate) loop
      for lockrec in get_locked_actions(runrec.assignment_action_id) loop
          hr_utility.trace('|  Rolling locked action back '
                                              ||lockrec.assignment_action_id);
          py_rollback_pkg.rollback_ass_action
                (
                  p_assignment_action_id => lockrec.assignment_action_id,
                  p_rollback_mode        => 'RETRY',
                  p_multi_thread         => TRUE
                );
      end loop;
      hr_utility.trace('|  Rolling Run back '||runrec.assignment_action_id);
      py_rollback_pkg.rollback_ass_action
             (
               p_assignment_action_id => runrec.assignment_action_id,
               p_rollback_mode        => 'RETRY',
               p_multi_thread         => TRUE,
               p_grp_multi_thread     => TRUE
             );
  end loop;  --end of runrec

  pay_recorded_requests_pkg.set_recorded_date(
       p_process          => 'CC_ASG',
       p_recorded_date    => l_run_date,
       p_recorded_date_o  => l_min_date,
       p_attribute1       => l_assignment_id);

  hr_utility.trace('+-------------------------------------------+');
  hr_utility.set_location(' Leaving: '||l_proc,900);

END archive_data;

  /* Name      : deinitialise
     Purpose   : This procedure simply removes all the actions processed
                 in this run
     Arguments :
     Notes     :
  */
  procedure deinitialise (pactid in number)
  is

    cursor csr_params(cp_pactid number) is
     select
      pay_core_utils.get_parameter('REMOVE_ACT',pa1.legislative_parameters),
      pay_core_utils.get_parameter('PAYROLL_ID',pa1.legislative_parameters)
     from pay_payroll_actions    pa1
     where pa1.payroll_action_id    = cp_pactid;

    l_remove_act     varchar2(10);
    l_payroll_id     number;
  begin

  -->>> PHASE 1: Get values of temp stored values
  --

  open  csr_params(pactid);
  fetch csr_params into l_remove_act,l_payroll_id;
  close csr_params;


  -->>> PHASE 2: Remove report actions
  --
  if (l_remove_act is null or l_remove_act = 'Y') then
     pay_archive.remove_report_actions(pactid);
  end if;
--


-- hr_utility.trace('jf store pactid    '||pactid);
-- hr_utility.trace('jf store new date  '||l_new_cc_date_v);
-- hr_utility.trace('jf store remove act'||l_remove_act);
-- hr_utility.trace('jf store pay id    '||l_payroll_id);
-- hr_utility.trace('jf store full orig '||l_orig_params);



end deinitialise;
--

--
procedure generate_trg_data(p_table_name in varchar2,
                            p_eff_str_name in varchar2,
                            p_eff_end_name in varchar2,
                            p_pkg_proc_name in varchar2,
                            p_bg_select in varchar2
                           )
is
--
   cursor get_columns (p_tab_name in varchar2)
   is
   select substr(column_name, 1, 24) column_name,
          column_name full_column_name,
          data_type
     from all_tab_columns
    where table_name = p_tab_name
      and owner = g_pay_schema
      and column_name not in ('LAST_UPDATE_DATE',
                              'LAST_UPDATED_BY',
                              'LAST_UPDATE_LOGIN',
                              'CREATED_BY',
                              'CREATION_DATE',
                              'OBJECT_VERSION_NUMBER')
      and data_type in ('NUMBER', 'VARCHAR2', 'DATE')
    order by column_name;
--
begin
--
    g_pay_schema := paywsdyg_pkg.get_table_owner(p_table_name);
--
    /* Set up the trigger */
    pay_dyn_triggers.create_trigger_event(
                  p_table_name||'_ARU',
                  p_table_name,
                  'Continuous Calcuation trigger on update of '||p_table_name,
                  'N',
                  'N',
                  'U',
                  NULL
                 );
--
    /* Setup the business Group */
    pay_dyn_triggers.create_trg_declaration(
                         p_table_name||'_ARU',
                         'business_group_id',
                         'N',
                         NULL,
                         NULL
                        );
--
    pay_dyn_triggers.create_trg_initialisation(
                         p_table_name||'_ARU',
                         '1',
                         'pay_core_utils.get_business_group',
                         'F',
                         NULL
                        );
--
    pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                         1,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         'I',
                         'R',
                         'business_group_id',
                         'l_business_group_id',
                         'N',
                         NULL
                         );
--
    pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          1,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          'I',
                          'I',
                          'p_statement',
                          p_bg_select,
                          'N',
                          NULL
                         );
--
    /* Setup the legislation code */
    pay_dyn_triggers.create_trg_declaration(
                         p_table_name||'_ARU',
                         'legislation_code',
                         'C',
                         10,
                         NULL
                        );
--
    pay_dyn_triggers.create_trg_initialisation(
                         p_table_name||'_ARU',
                          '2',
                          'pay_core_utils.get_legislation_code',
                          'F',
                          NULL
                         );
--
    pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          2,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          'I',
                          'R',
                          'legislation_code',
                          'l_legislation_code',
                          'N',
                          NULL
                         );
--
    pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          2,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          'I',
                          'I',
                          'p_bg_id',
                          'l_business_group_id',
                          'N',
                          NULL
                         );
--
    pay_dyn_triggers.create_trg_components(
                         p_table_name||'_ARU',
                          NULL,
                          NULL,
                          NULL,
                          p_pkg_proc_name,
                          'N',
                          NULL
                         );
--
    pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          p_pkg_proc_name,
                          'C',
                          'I',
                          'p_business_group_id',
                          'l_business_group_id',
                          'N',
                          NULL
                         );
--
    pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          p_pkg_proc_name,
                          'C',
                          'I',
                          'p_legislation_code',
                          'l_legislation_code',
                          'N',
                          NULL
                         );
--
    pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          p_pkg_proc_name,
                          'C',
                          'I',
                          'p_effective_date',
                          ':new.effective_start_date',
                          'N',
                          NULL
                         );
--
    for colrec in get_columns(p_table_name) loop
      pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          p_pkg_proc_name,
                          'C',
                          'I',
                          'p_old_'||colrec.column_name,
                          ':old.'||colrec.full_column_name,
                          'N',
                          NULL
                         );
--
      pay_dyn_triggers.create_trg_parameter(
                         p_table_name||'_ARU',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          p_pkg_proc_name,
                          'C',
                          'I',
                          'p_new_'||colrec.column_name,
                          ':new.'||colrec.full_column_name,
                          'N',
                          NULL
                         );
--
    end loop;
--
end generate_trg_data;
--
/* Name : generate_upd_trigger
   Purpose : This procedure is used for as a generator tool for development to
     create both the DYnamic Trigger code content (which is then stored in
     PAY_CC_DYT_CODE_PKG) and also the data driven DYT iunformation.  Eg populate
     base tables.
     The former behaviour is mode 'PROCEDURE', the latter 'TRIGGER DATA'.
     For more detailed info please see CC White Paper.
*/

procedure generate_upd_trigger(p_table_name in varchar2,
                               p_owner in varchar2,
                               p_surr_key_name in varchar2,
                               p_eff_str_name in varchar2,
                               p_eff_end_name in varchar2,
                               p_pkg_proc_name in varchar2 default null,
                               p_bg_select in varchar2 default null,
                               p_mode in varchar2 default 'PROCEDURE')
is
--
        cursor dtexists is
         select dated_table_id, object_version_number
           from pay_dated_tables pdt
          where table_name = p_table_name;
--
found boolean;
l_dated_tables_id number;
lv_object_version_number number;
l_result         boolean;
l_prod_status    varchar2(1);
l_industry       varchar2(1);
l_owner          varchar2(30);
--
begin
--
   if (p_owner is null) then
      if g_pay_schema is null then
       l_result := fnd_installation.get_app_info ( 'PAY',
                                    l_prod_status,
                                    l_industry,
                                    g_pay_schema );
      end if;
      l_owner := g_pay_schema;
   else
      l_owner := p_owner;
   end if;
--
   if (p_mode = 'PROCEDURE') then
--
       generate_cc_procedure(p_table_name,
                             p_surr_key_name,
                             p_eff_str_name,
                             p_eff_end_name,
                             l_owner
                            );
--
   elsif (p_mode = 'TRIGGER DATA') then
--
       generate_trg_data(p_table_name, p_eff_str_name, p_eff_end_name,
                         p_pkg_proc_name, p_bg_select);
--
       found := FALSE;
       for getrec in dtexists loop
          l_dated_tables_id := getrec.dated_table_id;
          lv_object_version_number := getrec.object_version_number;
          found := TRUE;
       end loop;
--
       if (found = FALSE) then
          pay_dated_tables_api.CREATE_DATED_TABLE(
             p_table_name                   => p_table_name
             , p_application_id             => null
             , p_surrogate_key_name         => p_surr_key_name
             , p_start_date_name            => p_eff_str_name
             , p_end_date_name              => p_eff_str_name
             , p_business_group_id          => null
             , p_legislation_code           => null
             , p_dated_table_id             => l_dated_tables_id
             , p_object_version_number      => lv_object_version_number);
       end if;
   end if;
--
end generate_upd_trigger;
--
  /* Name      : generate_cc_procedure
     Purpose   : This procedure generates a default continuous calc update
                 procedure for the specified Table. The procedure is
                 generated into the log file.
     Arguments :
     Notes     :
  */
  procedure generate_cc_procedure(p_table_name in varchar2,
                                  p_surr_key_name in varchar2,
                                  p_eff_str_name in varchar2,
                                  p_eff_end_name in varchar2,
                                  p_owner in varchar2
                                 )
  is
--
   cursor get_columns (p_tab_name in varchar2,
                       p_start in varchar2,
                       p_end in varchar2,
                       l_owner in varchar2)
   is
   select substr(column_name, 1, 24) column_name,
          column_name full_column_name,
          data_type
     from all_tab_columns
    where table_name = p_tab_name
      and owner = l_owner
      and column_name not in ('LAST_UPDATE_DATE',
                              'LAST_UPDATED_BY',
                              'LAST_UPDATE_LOGIN',
                              'CREATED_BY',
                              'CREATION_DATE',
                              'OBJECT_VERSION_NUMBER')
      and data_type in ('NUMBER', 'VARCHAR2', 'DATE')
    order by decode (column_name, p_start, 3,
                                  p_end,   2,
                                  1),
                     column_name;
--
   proc varchar2(32767);
   l_result         boolean;
   l_prod_status    varchar2(1);
   l_industry       varchar2(1);
   l_owner          varchar2(30);
   l_eff_str_up varchar2(40);
   l_eff_str_low varchar2(40);
   l_eff_end_up varchar2(40);
   l_eff_end_low varchar2(40);
  begin
--
    /* OK put trace on */
    hr_utility.trace_on(null, p_table_name);
--
   if (p_owner is null) then
      g_pay_schema := paywsdyg_pkg.get_table_owner(p_table_name);
      l_owner := g_pay_schema;
   else
      if paywsdyg_pkg.is_table_owner_valid(p_table_name,p_owner) = 'N' then
          hr_utility.trace('-- WARNING: owner '||p_owner||' is not valid for table '||p_table_name);
      end if;
      l_owner := p_owner;
   end if;
--
    l_eff_str_up := upper(p_eff_str_name);
    l_eff_str_low := lower(p_eff_str_name);
    l_eff_end_up := upper(p_eff_end_name);
    l_eff_end_low := lower(p_eff_end_name);
--
    proc := 'procedure '||p_table_name||'_aru(
    p_business_group_id in number,
    p_legislation_code in varchar2,
    p_effective_date in date';
--
    hr_utility.trace(proc);
    for colrec in get_columns(p_table_name, l_eff_str_up, l_eff_end_up, l_owner) loop
      proc := ',
    ';
      proc := proc||'p_old_'||colrec.column_name||' in '||colrec.data_type||',
    ';
      proc := proc||'p_new_'||colrec.column_name||' in '||colrec.data_type;
--
      hr_utility.trace(proc);
    end loop;
--
    proc := '
)
is
--
begin
  /* If the continuous calc is overriden then do nothing */
  if (pay_continuous_calc.g_override_cc = TRUE) then
    return;
  end if;
--
  /* If the dates havent changed it must be a correction */
  if (p_old_'||l_eff_end_up||' = p_new_'||l_eff_end_up||'
     and  p_old_'||l_eff_str_up||' = p_new_'||l_eff_str_up||') then';
--
    hr_utility.trace(proc);
    for colrec in get_columns(p_table_name, l_eff_str_up, l_eff_end_up, l_owner) loop
--
      if (colrec.column_name = l_eff_end_up) then
        proc := proc||'
  else
    /* OK it must be a date track change */';
        hr_utility.trace(proc);
      end if;
--
      proc := '--
    pay_continuous_calc.event_update(p_business_group_id,
                                     p_legislation_code,
                                     '''||p_table_name||''',
                                     '''||colrec.full_column_name||''',
                                     p_old_'||colrec.column_name||',
                                     p_new_'||colrec.column_name||',';
      if (colrec.column_name = l_eff_str_up) then
         proc := proc||'
                                     p_new_'||l_eff_str_low||',
                                     least(p_old_'||l_eff_str_low||',
                                           p_new_'||l_eff_str_low||')';
      else
        if (colrec.column_name = l_eff_end_up) then
           proc := proc||'
                                     p_new_'||l_eff_end_low||',
                                     least(p_old_'||l_eff_end_low||',
                                           p_new_'||l_eff_end_low||')';
        else
           proc := proc||'
                                     p_effective_date';
        end if;
      end if;
--
      proc := proc||'
                                  );';
      hr_utility.trace(proc);
    end loop;
    proc := '
  end if;
--
   /* Now call the API for the affected assignments */
   declare
     l_process_event_id      number;
     l_object_version_number number;
     cnt number;
   begin
     if (pay_continuous_calc.g_event_list.sz <> 0) then
       for cnt in 1..pay_continuous_calc.g_event_list.sz loop
           pay_ppe_api.create_process_event(
             p_assignment_id         => p_assignment_id?,
             p_effective_date        => pay_continuous_calc.g_event_list.effective_date(cnt),
             p_change_type           => pay_continuous_calc.g_event_list.change_type(cnt),
             p_status                => ''U'',
             p_description           => pay_continuous_calc.g_event_list.description(cnt),
             p_process_event_id      => l_process_event_id,
             p_object_version_number => l_object_version_number,
             p_event_update_id       => pay_continuous_calc.g_event_list.event_update_id(cnt),
             p_business_group_id     => p_business_group_id,
             p_calculation_date      => pay_continuous_calc.g_event_list.calc_date(cnt),
             p_surrogate_key         => p_new_'||lower(p_surr_key_name)||'
           );
         end loop;
     end if;
     pay_continuous_calc.g_event_list.sz := 0;
   end;
--
end '||p_table_name||'_aru;';
--
    hr_utility.trace(proc);
  end generate_cc_procedure;
--

--
  /* Name      : get_asg_act_status
     Purpose   : This function returns whether a asg_act has been modified
                 By checking the results of PPE.  The crucial point is establishing
                 the date the CC process was run for the payroll and making sure
                 more recent changes exist.
                 Similar copy of code in pyasa01t, removing redundant status restriction
                 on cursors
     Arguments :
     Notes     :
  */
FUNCTION get_asg_act_status( p_assignment_action_id in number,
                             p_action_type          in varchar2,
                             p_action_status        in varchar2) return varchar2
is

l_payroll_id number;
l_assignment_id number;
l_date date;

l_dummy_action_id pay_assignment_actions.assignment_action_id%type ;
ischanged         boolean;

cursor get_payroll (cp_asg_act_id in number) is
select ppa.payroll_id
from
     pay_payroll_actions ppa,
     pay_assignment_actions paa
where paa.assignment_action_id = cp_asg_act_id
and   paa.payroll_action_id = ppa.payroll_action_id;

cursor get_assignment_id (cp_asg_act_id in number) is
select assignment_id
from   pay_assignment_actions paa
where  paa.assignment_action_id = cp_asg_act_id;

--
-- A given assignment action is void if there is a payroll action of type 'D'
-- locks ( though PAY_ACTION_INTERLOCKS ) the assignment action.
-- Note that this cursor does not check whether the void assignment action has
-- a status of complete
--
cursor c_is_voided ( p_assignment_action_id in number ) is
  select intloc.locking_action_id
  from   pay_assignment_actions assact,
	 pay_action_interlocks  intloc,
	 pay_payroll_actions    pact
  where  intloc.locked_action_id  = p_assignment_action_id
  and    intloc.locking_action_id = assact.assignment_action_id
  and    assact.payroll_action_id = pact.payroll_action_id
  and    pact.action_type         = 'D';
--
cursor run_modified (p_assignment_action_id in number,
                     cp_last_cc_run_date    in date ) is
select paa.assignment_action_id
from
     pay_payroll_actions ppa,
     pay_assignment_actions paa
where paa.assignment_action_id = p_assignment_action_id
and   paa.payroll_action_id = ppa.payroll_action_id
and   paa.action_status = 'C'
and exists (select ''
              from pay_process_events ppe
             where ppe.assignment_id = paa.assignment_id
               and ppe.change_type in ('GRE', 'DATE_EARNED', 'DATE_PROCESSED')
               and ppe.creation_date > cp_last_cc_run_date
               and ppe.effective_date <= nvl(ppa.date_earned,ppa.effective_date)
           )
and not exists (select ''
                  from pay_assignment_actions paa1, -- Prepay/Costing
                       pay_action_interlocks  pai1,
                       pay_assignment_actions paa2,-- Payment/Trans GL
                       pay_action_interlocks  pai2
                 where pai1.locked_action_id = paa.assignment_action_id
                   and pai1.locking_action_id = paa1.assignment_action_id
                   and pai2.locked_action_id = paa1.assignment_action_id
                   and pai2.locking_action_id = paa2.assignment_action_id);
--
cursor prepay_modified (p_assignment_action_id in number,
                        cp_last_cc_run_date    in date ) is
select paa.assignment_action_id
from
     pay_payroll_actions ppa,
     pay_assignment_actions paa
where paa.assignment_action_id = p_assignment_action_id
and   paa.payroll_action_id = ppa.payroll_action_id
and   paa.action_status = 'C'
and not exists (select ''
                  from pay_assignment_actions paa1, -- Payment/Trans GL
                       pay_action_interlocks  pai1
                 where pai1.locked_action_id = paa.assignment_action_id
                   and pai1.locking_action_id = paa1.assignment_action_id)
and (exists (select ''
              from pay_process_events ppe
             where ppe.assignment_id = paa.assignment_id
               and ppe.effective_date < ppa.effective_date
               and ppe.change_type in ('PAYMENT')
               and ppe.creation_date > cp_last_cc_run_date
            )
   or
     exists (select ''
              from pay_action_interlocks pai,
                   pay_assignment_actions paa2,
                   pay_payroll_actions    ppa2
             where pai.locking_action_id = paa.assignment_action_id
               and pai.locked_action_id = paa2.assignment_action_id
               and paa2.payroll_action_id = ppa2.payroll_action_id
               and ppa2.action_type in ('R','Q')
               and exists (select ''
                             from pay_process_events ppe
                            where ppe.assignment_id = paa2.assignment_id
                              and ppe.effective_date < ppa2.effective_date
                              and ppe.change_type in ('GRE', 'DATE_EARNED', 'DATE_PROCESSED')
                              and ppe.creation_date > cp_last_cc_run_date
                          )
              )
     );
--
cursor cost_modified (p_assignment_action_id in number,
                      cp_last_cc_run_date    in date ) is
select paa.assignment_action_id
from
     pay_payroll_actions ppa,
     pay_assignment_actions paa
where paa.assignment_action_id = p_assignment_action_id
and   paa.payroll_action_id = ppa.payroll_action_id
and   paa.action_status = 'C'
and not exists (select ''
                  from pay_assignment_actions paa1, -- Payment/Trans GL
                       pay_action_interlocks  pai1
                 where pai1.locked_action_id = paa.assignment_action_id
                   and pai1.locking_action_id = paa1.assignment_action_id)
and exists (select ''
              from pay_process_events ppe
             where ppe.assignment_id = paa.assignment_id
               and ppe.effective_date < ppa.effective_date
               and ppe.change_type in ('COST_CENTRE')
               and ppe.creation_date > cp_last_cc_run_date
           )
and exists (select ''
              from pay_action_interlocks pai,
                   pay_assignment_actions paa2,
                   pay_payroll_actions    ppa2
             where pai.locking_action_id = paa.assignment_action_id
               and pai.locked_action_id = paa2.assignment_action_id
               and paa2.payroll_action_id = ppa2.payroll_action_id
               and ppa2.action_type in ('R','Q')
               and exists (select ''
                             from pay_process_events ppe
                            where ppe.assignment_id = paa2.assignment_id
                              and ppe.effective_date < ppa2.effective_date
                              and ppe.change_type in ('GRE', 'DATE_EARNED', 'DATE_PROCESSED')
                              and ppe.creation_date > cp_last_cc_run_date
                          )
             );
--
--
  l_return_value    hr_lookups.meaning%type ;
  l_proc varchar2(80) :=  g_pkg||'.get_asg_act_status';

BEGIN
  hr_utility.set_location(l_proc,10);

--
   ischanged := FALSE;
--
  --Get assignment_id for this asg_act_id
  --
  open get_assignment_id (p_assignment_action_id);
  fetch get_assignment_id into l_assignment_id;
  close get_assignment_id;
  hr_utility.trace('-assignment_id: '||l_assignment_id);
  --Get date CC was last executed
  --
-- As highlighted in bug 3146928
-- This function is used in a view and thus no dml can occur, so call new proc
--
  PAY_RECORDED_REQUESTS_PKG.get_recorded_date_no_ins('CC_ASG',l_date,l_assignment_id);
  hr_utility.trace('-last CC run date is '||l_date);

--
  -- bug 3265814
  --If looks like CC not in use then dont bother to look for modified
  --better to have global payroll level switch, but now compare date
 if (l_date = hr_api.g_sot) then
  -- l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
  -- Bug 3576520: Repeating the special case for the Cheque Writer.
  if ( p_action_type in ('M', 'H' )) then
     open c_is_voided( p_assignment_action_id ) ;
     fetch c_is_voided into l_dummy_action_id ;
     if c_is_voided%found then
    	l_return_value := hr_general.decode_lookup('ACTION_STATUS','V');
        hr_utility.set_location(l_proc,50);
     else
    	l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
        hr_utility.set_location(l_proc,55);
     end if;
     close c_is_voided ;
  else
	l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
  end if;
  --
 else
  if ( p_action_type in ('R', 'Q')) then
--
     ischanged := FALSE;
--
     -- Check Run change.
     open run_modified( p_assignment_action_id, l_date );
     fetch run_modified into l_dummy_action_id ;
     if run_modified%found then
       ischanged := TRUE;
     end if;
     close run_modified ;
--
     if (ischanged) then
        l_return_value := hr_general.decode_lookup('ACTION_STATUS','MO');
    hr_utility.set_location(l_proc,20);
     else
        l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
    hr_utility.set_location(l_proc,25);
     end if;
--
  elsif ( p_action_type in ('P', 'U')) then
--
     ischanged := FALSE;
--
     -- Check Prepay change.
     open prepay_modified( p_assignment_action_id, l_date );
     fetch prepay_modified into l_dummy_action_id ;
     if prepay_modified%found then
       ischanged := TRUE;
     end if;
     close prepay_modified ;
--
     if (ischanged) then
        l_return_value := hr_general.decode_lookup('ACTION_STATUS','MO');
    hr_utility.set_location(l_proc,30);
     else
        l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
    hr_utility.set_location(l_proc,35);
     end if;
--
  elsif ( p_action_type = 'C') then
--
     ischanged := FALSE;
--
     -- Check Costing change.
     open cost_modified( p_assignment_action_id, l_date );
     fetch cost_modified into l_dummy_action_id ;
     if cost_modified%found then
       ischanged := TRUE;
     end if;
     close cost_modified ;
--
     if (ischanged) then
        l_return_value := hr_general.decode_lookup('ACTION_STATUS','MO');
    hr_utility.set_location(l_proc,40);
     else
        l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
    hr_utility.set_location(l_proc,45);
     end if;
--
--
  elsif ( p_action_type = 'H' ) then
     open c_is_voided( p_assignment_action_id ) ;
     fetch c_is_voided into l_dummy_action_id ;
     if c_is_voided%found then
	l_return_value := hr_general.decode_lookup('ACTION_STATUS','V');
    hr_utility.set_location(l_proc,50);
     else
	l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
    hr_utility.set_location(l_proc,55);
     end if;
     close c_is_voided ;
  else
	l_return_value := hr_general.decode_lookup('ACTION_STATUS',p_action_status ) ;
  end if;
 end if;
    hr_utility.set_location(l_proc,900);
  return ( l_return_value ) ;
end get_asg_act_status ;


  /* Name      : generate_upd_script
     Purpose   : This procedure generates a the upload script to load the
                 trigger definition of a generated cc procedure into the
                 dynamic trigger tables.
     Arguments :
     Notes     :
  */
  procedure generate_upd_script(p_table_name in varchar2
                                 )
  is
--
   cursor get_columns (p_tab_name in varchar2)
   is
   select substr(column_name, 1, 24) column_name,
          column_name full_column_name,
          data_type
     from all_tab_columns
    where table_name = p_tab_name
      and owner = g_pay_schema
      and column_name not in ('LAST_UPDATE_DATE',
                              'LAST_UPDATED_BY',
                              'LAST_UPDATE_LOGIN',
                              'CREATED_BY',
                              'CREATION_DATE',
                              'OBJECT_VERSION_NUMBER')
      and data_type in ('NUMBER', 'VARCHAR2', 'DATE')
    order by column_name;
--
   proc varchar2(32767);
   l_result boolean;
   l_prod_status    varchar2(1);
   l_industry       varchar2(1);
--
  begin
    /* OK put trace on */
    hr_utility.trace_on(null, p_table_name);
--
    g_pay_schema := paywsdyg_pkg.get_table_owner(p_table_name);
--
    proc := '   pay_dyn_triggers.create_trigger_event(
                         '''||p_table_name||'_ARU'',
                         '''||p_table_name||''',
                         ''Description'',
                         ''N'',
                         ''N'',
                         ''U'',
                         NULL
                        );
--
';
--
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_declaration(
                         '''||p_table_name||'_ARU'',
                         ''business_group_id'',
                         ''N'',
                         NULL,
                         NULL
                        );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_initialisation(
                         '''||p_table_name||'_ARU'',
                         ''1'',
                         ''pay_core_utils.get_business_group'',
                         ''F'',
                         sysdate,
                         NULL
                        );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                         1,
                         NULL,
                         NULL,
                         NULL,
                         NULL,
                         ''I'',
                         ''R'',
                         ''business_group_id'',
                         ''l_business_group_id'',
                         ''N'',
                         NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          1,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''I'',
                          ''I'',
                          ''p_statement'',
                          ''''''select statement'''''',
                          ''N'',
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_declaration(
                         '''||p_table_name||'_ARU'',
                         ''legislation_code'',
                         ''C'',
                         10,
                         NULL
                        );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_initialisation(
                         '''||p_table_name||'_ARU'',
                          ''2'',
                          ''pay_core_utils.get_legislation_code'',
                          ''F'',
                          sysdate,
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          2,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''I'',
                          ''R'',
                          ''legislation_code'',
                          ''l_legislation_code'',
                          ''N'',
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          2,
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''I'',
                          ''I'',
                          ''p_bg_id'',
                          ''l_business_group_id'',
                          ''N'',
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_components(
                         '''||p_table_name||'_ARU'',
                          NULL,
                          NULL,
                          NULL,
                          ''package.procedure'',
                          ''N'',
                          sysdate,
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''package.procedure'',
                          ''C'',
                          ''I'',
                          ''p_business_group_id'',
                          ''l_business_group_id'',
                          ''N'',
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''package.procedure'',
                          ''C'',
                          ''I'',
                          ''p_legislation_code'',
                          ''l_legislation_code'',
                          ''N'',
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''package.procedure'',
                          ''C'',
                          ''I'',
                          ''p_effective_date'',
                          '':new.effective_start_date'',
                          ''N'',
                          NULL
                         );
--
';
    hr_utility.trace(proc);
--
    for colrec in get_columns(p_table_name) loop
      proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''package.procedure'',
                          ''C'',
                          ''I'',
                          ''p_old_'||colrec.column_name||''',
                          '':old.'||colrec.column_name||''',
                          ''N'',
                          NULL
                         );
--
';
      hr_utility.trace(proc);
--
      proc := '  pay_dyn_triggers.create_trg_parameter(
                         '''||p_table_name||'_ARU'',
                          NULL,
                          NULL,
                          NULL,
                          NULL,
                          ''package.procedure'',
                          ''C'',
                          ''I'',
                          ''p_new_'||colrec.column_name||''',
                          '':new.'||colrec.column_name||''',
                          ''N'',
                          NULL
                         );
--
';
      hr_utility.trace(proc);
    end loop;
--
  end generate_upd_script;
--

/* Name : generate_dyt_pkg_behaviour
   Purpose : This procedure is used as a generator tool for development to
     alter the stored definitions of the Dynamic Trigger data such
     that the DYT wrapper code will now be held in a package rather than
     as explicit database triggers.
     For more information see the CC White Paper.
   Paramaters:
     + p_table_name -The dated table in question
     + p_tab_rki_pkg -The package containing the user hook information.
             Usually this is defined in the row handler file for this table.
             This is needed so we can look up the paramater listing as we require
             the same list.  Similarly for the after_update and after_delete
              (...rku_pkg, ...rkd_pkg)
   Prerequisites:  The DYT must have been created in the old-skool manner,
      using the generate_upd_trigger in mode PROCEDURE then mode TRIGGER DATA
      The former creates code that should be edited and then placed in
      pay_cc_dyt_code_pkg.
*/

PROCEDURE GENERATE_DYT_PKG_BEHAVIOUR(p_table_name  in varchar2,
                                     p_tab_rki_pkg in varchar2,
                                     p_tab_rku_pkg in varchar2,
                                     p_tab_rkd_pkg in varchar2 ) IS

  --Include all control parameters, under the assumption that the finished
  --rows will be manually edited, usually removing some of these

  cursor csr_args (cp_rki varchar2, cp_rku varchar2, cp_rkd varchar2)
  is
    SELECT a.argument value_name, a.procedure$ proc_name
    FROM   SYS.ARGUMENT$ A,
           USER_OBJECTS B
    WHERE  A.OBJ# = B.OBJECT_ID
    AND    B.OBJECT_NAME in (CP_RKI,CP_RKU,CP_RKD)
    AND    A.LEVEL# = 0
    --AND    a.argument not in ('P_VALIDATE',
    --                        'P_EFFECTIVE_DATE',
    --                        'P_DATETRACK_UPDATE_MODE',
    --                        'P_DATETRACK_DELETE_MODE',
    --                        'P_VALIDATION_START_DATE',
    --                        'P_VALIDATION_END_DATE',
    --                        'P_LANGUAGE_CODE')
    ORDER BY a.procedure$;

  l_prefix varchar2(15); --Local Form prefix
  l_o      varchar2(15) := ':old.'; --Old Style Local Form prefix
  l_n      varchar2(15) := ':new.'; --Old Style Local Form prefix

  l_pkg_name   varchar2(80) ;
  l_local_form varchar2(80);

  l_usage_type varchar2(15);
  l_dated_table_id number;
  l_app_id     number;

BEGIN
  l_pkg_name := p_table_name;

  select pdt.dated_table_id
  into   l_dated_table_id
  from   pay_dated_tables pdt
  where  pdt.table_name = p_table_name;

-- >>> PHASE 1: Create the dyt_pkg name based on table_name
--
  --Remove _f if exists and replace with _pkg
  --
  if ( upper(substr(p_table_name,length(p_table_name) - 1, 2)) = '_F' ) then
    l_pkg_name := substr(p_table_name,1,length(p_table_name)-2);
  end if;

  --Insert _dyt after first underscore, nb overwriting owner prefix to PAY
  --
  l_pkg_name :='PAY_' --substr(l_pkg_name,1,instr(l_pkg_name,'_'))
              ||'DYT'
              ||substr(l_pkg_name,instr(l_pkg_name,'_'),18)--max 30chars for full pkg
              ||'_PKG';
  --Get application
  if (substr(p_table_name,1,instr(p_table_name,'_')-1) = 'PAY') then
   l_app_id := 801;
  elsif (substr(p_table_name,1,instr(p_table_name,'_')-1) = 'PER') then
    l_app_id := 800;
  elsif (substr(p_table_name,1,instr(p_table_name,'_')-1) = 'PQH') then
    l_app_id := 8302;
  end if;

-- >>> PHASE 2: Set the dated table to have dyt in package
--

   update pay_dated_tables pdt
   set application_id = l_app_id,
       dyn_trigger_type = 'P',
       dyn_trigger_package_name = l_pkg_name,
       dyn_trig_pkg_generated = 'N'
   where pdt.table_name = p_table_name;

-- >>> PHASE 3: Create the parameter mappings for dbtrigs to pkg procedure
--
  --get the parameters that have been created for the row handler user hook pkg.
  --This generated file has all the parameters that we will also have to create mappings for.
  FOR args_rec in csr_args(p_tab_rki_pkg,p_tab_rku_pkg,p_tab_rkd_pkg) LOOP
    -- if _o then old style (and remove _o) else new style
    --
    if ( upper(substr(args_rec.value_name,length(args_rec.value_name) - 1, 2)) = '_O' ) then
      l_local_form := substr(args_rec.value_name,1,length(args_rec.value_name)-2);
      l_prefix := l_o;
    else
      l_local_form := args_rec.value_name;
      l_prefix := l_n;
    end if;

    -- if first 2 chars are p_ (which we expect is them all) strip it out
    --
    if ( upper(substr(l_local_form,1, 2)) = 'P_' ) then
      l_local_form := substr(l_local_form,3);
    end if;
    -- add our prefix
      l_local_form := l_prefix||l_local_form;

    l_usage_type := 'P'||substr(args_rec.proc_name,7,1);
    --dbms_output.put_line(l_dated_table_id||' Insert a '||l_usage_type||' val_name: '||args_rec.value_name||' local form: '||l_local_form);


    -- Create rows in trigger_parameters
    --
    pay_dyn_triggers.create_trg_parameter (
            p_short_name       => p_table_name,
            p_process_order    => null,
            p_legislative_code => null,
            p_business_group   => null,
            p_payroll_name     => null,
            p_module_name      => null,
            p_usage_type       => l_usage_type,
            p_parameter_type   => 'I',  --All param are INs 'cos all hook params are INs
            p_parameter_name   => l_local_form,
            p_value_name       => args_rec.value_name,
            p_automatic        =>  'Y',
            p_owner            => null
            );

  END LOOP;


END GENERATE_DYT_PKG_BEHAVIOUR;

/*
  Revert back away from the dyt_pkg behaviour.  Intended as development util only.
  Obsoleted please see paywsdyg_pkg.convert_tab_style
*/
PROCEDURE DROP_DYT_PKG_BEHAVIOUR(p_table_name  in varchar2) IS

BEGIN
-- >>> PHASE 1: Set the dated table to have old-skool dyt
--
   update pay_dated_tables pdt
   set dyn_trigger_type = 'T',
       dyn_trigger_package_name = null,
       dyn_trig_pkg_generated = null
   where pdt.table_name = p_table_name;

-- >>> PHASE 2: Junk all parameters
--
  DELETE
  FROM pay_trigger_parameters ptp
  WHERE ptp.usage_id = (select dated_table_id
                        from pay_dated_tables pdt
                        where pdt.table_name = p_table_name)
  AND   ptp.usage_type in ('PI','PU','PD');

END DROP_DYT_PKG_BEHAVIOUR;

procedure set_req_dates_for_run(p_process in varchar2,
                                p_asg_id  in number,
                                p_sysdate in date,
                                p_assact_id in number)
is
 cursor get_min_dates(p_asg_id number, p_cca_date date, p_sysdate date)
 is
 select min(effective_date) effective_date,
        change_type
   from pay_process_events
  where assignment_id = p_asg_id
    and creation_date between p_cca_date
                          and p_sysdate
    and change_type in ('DATE_PROCESSED', 'DATE_EARNED')
  group by change_type
  order by change_type desc;

 cursor get_group_events(p_cca_date date, p_sysdate date) is
  select pdt.table_name,ppe.surrogate_key
    from pay_process_events ppe,
         pay_event_updates  peu,
         pay_dated_tables   pdt
   where ppe.assignment_id is null
     and ppe.creation_date between p_cca_date
                           and p_sysdate
     AND ppe.change_type in ('DATE_PROCESSED', 'DATE_EARNED')
     and peu.event_update_id = ppe.event_update_id
     and peu.dated_table_id = pdt.dated_table_id
     and pdt.table_name in ('PAY_GRADE_RULES_F','PQH_RATE_MATRIX_RATES_F','FF_GLOBALS_F','PAY_USER_COLUMN_INSTANCES_F'); /*Added for Bug 8302596 */

  l_effective_date date;
  l_change_type pay_process_events.change_type%type;
  l_cca_date date;
  run_counts number;
  l_update_cc_date boolean;
  new_cc_date date;
  old_cc_date date;
  l_table_name pay_dated_tables.table_name%type;
  l_surrogate_key pay_process_events.surrogate_key%type;
  l_grp_event_valid varchar2(5);

begin

   pay_recorded_requests_pkg.get_recorded_date(
    p_process        => p_process,
    p_recorded_date  => l_cca_date,
    p_attribute1     => p_asg_id);

   l_update_cc_date := TRUE;
   open get_min_dates(p_asg_id,
                      l_cca_date,
                      p_sysdate);
   fetch get_min_dates into l_effective_date, l_change_type;

   while (get_min_dates%notfound = FALSE
          and l_update_cc_date = TRUE) loop

      if (l_change_type = 'DATE_PROCESSED') then

        select count(*)
          into run_counts
          from pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_assignment_actions paa_curr
         where paa_curr.assignment_action_id = p_assact_id
           and paa.assignment_id = p_asg_id
           and paa.payroll_action_id = ppa.payroll_action_id
           and paa.payroll_action_id <> paa_curr.payroll_action_id
           and paa.action_sequence < paa_curr.action_sequence
           and ppa.action_type in ('R', 'Q')
           and ppa.effective_date > l_effective_date;

         if (run_counts > 0) then
            l_update_cc_date := FALSE;
         end if;

      elsif (l_change_type = 'DATE_EARNED') then

        select count(*)
          into run_counts
          from pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_assignment_actions paa_curr
         where paa_curr.assignment_action_id = p_assact_id
           and paa.assignment_id = p_asg_id
           and paa.payroll_action_id = ppa.payroll_action_id
           and paa.payroll_action_id <> paa_curr.payroll_action_id
           and paa.action_sequence < paa_curr.action_sequence
           and ppa.action_type in ('R', 'Q')
           and ppa.date_earned > l_effective_date;

         if (run_counts > 0) then
            l_update_cc_date := FALSE;
         end if;

      end if;

      fetch get_min_dates into l_effective_date, l_change_type;

   end loop;

   close get_min_dates;

   -- 7205112
   -- Now check for group level events

   IF (l_update_cc_date= TRUE) then

     open get_group_events(l_cca_date,
                         p_sysdate);
     fetch get_group_events into l_table_name,l_surrogate_key;

     while (get_group_events%notfound = FALSE
            and l_update_cc_date = TRUE) loop

      l_grp_event_valid := pay_interpreter_pkg.valid_group_event_for_asg(l_table_name,
                                                                      p_asg_id,
                                                                      l_surrogate_key);

      if l_grp_event_valid = 'Y' then

	 l_update_cc_date := FALSE;

      end if;

      fetch get_group_events into l_table_name,l_surrogate_key;

     end loop;

     close get_group_events;

   END IF;

   if (l_update_cc_date = TRUE) then

      new_cc_date :=p_sysdate;

      hr_utility.trace('Updating pay_recorded_requests, process and recorded_date : '|| p_process || ' ' || new_cc_date);

      pay_recorded_requests_pkg.set_recorded_date(
       p_process          => p_process,
       p_recorded_date    => new_cc_date,
       p_recorded_date_o  => old_cc_date,
       p_attribute1     => p_asg_id);

   end if;
--
end set_req_dates_for_run;
--
/* Name : reset_dates_for_run
   Purpose :
       This procedure is used in the Payroll Run to reset the request
       submission dates of dependent processes.
*/
procedure reset_dates_for_run( p_asg_id    in number,
                               p_sysdate   in date,
                               p_assact_id in number)
is
begin
--
   set_req_dates_for_run(p_process   => 'CCA',
                         p_asg_id    => p_asg_id,
                         p_sysdate   => p_sysdate,
                         p_assact_id => p_assact_id
                        );
--
   set_req_dates_for_run(p_process   => 'RETRONOT_ASG',
                         p_asg_id    => p_asg_id,
                         p_sysdate   => p_sysdate,
                         p_assact_id => p_assact_id
                        );
--
end reset_dates_for_run;
--
END PAY_CC_PROCESS_UTILS;

/
