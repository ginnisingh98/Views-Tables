--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLL_CONTACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLL_CONTACT_PKG" AS
/* $Header: pycoprco.pkb 120.0 2005/05/29 04:08:44 appldev noship $ */


--
  /* Name      : range_cursor
     Purpose   : This returns the select statement that is used to created the
                 range rows.
     Arguments :
     Notes     :
  */
procedure range_cursor (pactid in number, sqlstr out nocopy varchar2) is
begin
--
       sqlstr := 'select  distinct asg.person_id
                  from
                          per_all_assignments_f      asg,
                          pay_payroll_actions    pa1
                   where  pa1.payroll_action_id    = :payroll_action_id
                   and    asg.business_group_id    = pa1.business_group_id
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
--
  cursor c_bgp_asg (cp_pactid number,
                    cp_stperson  number,
                    cp_endperson number
                   ) is
  select distinct paf.assignment_id
    from per_periods_of_service pos,
         per_all_assignments_f      paf,
         pay_payroll_actions    ppa
   where ppa.payroll_action_id = cp_pactid
     and ppa.business_group_id = paf.business_group_id
     and pos.period_of_service_id = paf.period_of_service_id
     and pos.person_id between cp_stperson and cp_endperson;
--
l_action_id pay_assignment_actions.assignment_action_id%type;
--
begin
--
  for asgrec in c_bgp_asg(p_pactid, p_stperson, p_endperson) loop
--
     select pay_assignment_actions_s.nextval
       into l_action_id
       from dual;
--
      hr_nonrun_asact.insact(lockingactid       => l_action_id,
                             pactid             => p_pactid,
                             chunk              => p_chunk,
                             object_id          => asgrec.assignment_id,
                             object_type        => 'ASG',
                             p_transient_action => TRUE);
--
  end loop;
--
end action_creation;
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

  /* Name      : process_data
     Purpose   :
     Arguments :
     Notes     :
  */
procedure process_data(p_assactid in number, p_effective_date in date) is
--
cursor c_asg_id(p_ass_act_id number
               ,p_eff_date date)
is
select paf.assignment_id
,      paf.business_group_id
from   pay_temp_object_actions toa
,      per_all_assignments_f paf
where  toa.object_action_id = p_ass_act_id
and    toa.object_type = 'ASG'
and    toa.object_id = paf.assignment_id
and    p_eff_date between paf.effective_start_date
                      and paf.effective_end_date;
--
l_assignment_id  number;
l_bg_id          number;
l_formula_id     number;
l_effective_date date;
l_inputs         ff_exec.inputs_t;
l_outputs        ff_exec.outputs_t;
l_loop_cnt       number;
l_in_cnt         number;
l_out_cnt        number;
--
BEGIN
--
select
pay_core_utils.get_parameter('FORM_ID', ppa.legislative_parameters)
into l_formula_id
from pay_payroll_actions ppa
,    pay_temp_object_actions toa
where ppa.payroll_action_id = toa.payroll_action_id
and   toa.object_action_id = p_assactid;
--
l_effective_date := p_effective_date;
open c_asg_id(p_assactid,p_effective_date);
fetch c_asg_id into l_assignment_id, l_bg_id;
if c_asg_id%notfound then
  --
  hr_utility.trace('no assignment found');
  --
  close c_asg_id;
else
  close c_asg_id;
  --
  -- Initialise the formula.
  --
  ff_exec.init_formula(l_formula_id, l_effective_date, l_inputs, l_outputs);
  --
  -- We are now in a position to execute the formula.
  -- Setup the inputs table
  --
  for l_in_cnt in l_inputs.first..l_inputs.last loop
    if(l_inputs(l_in_cnt).name = 'ASSIGNMENT_ID') then
      l_inputs(l_in_cnt).value := l_assignment_id;
    elsif (l_inputs(l_in_cnt).name = 'DATE_EARNED') then
      l_inputs(l_in_cnt).value := fnd_date.date_to_canonical(l_effective_date);
    elsif (l_inputs(l_in_cnt).name = 'BUSINESS_GROUP_ID') then
      l_inputs(l_in_cnt).value := l_bg_id;
    end if;
  end loop;
  --
  -- run the formula
  --
  ff_exec.run_formula(l_inputs, l_outputs);
  --
end if;
end process_data;

  /* Name      : deinitialise
     Purpose   : This procedure simply removes all the actions processed
                 in this run
     Arguments :
     Notes     :
  */
  procedure deinitialise (pactid in number)
  is
--
    l_remove_act     varchar2(10);
    cnt_incomplete_actions number;
    l_bus_grp_id pay_payroll_actions.business_group_id%type;
    l_leg_code   per_business_groups.legislation_code%type;
  begin
--
     select
            pay_core_utils.get_parameter('REMOVE_ACT',
                                         ppa.legislative_parameters),
            ppa.business_group_id,
            pbg.legislation_code
       into
            l_remove_act,
            l_bus_grp_id,
            l_leg_code
       from pay_payroll_actions ppa,
            per_business_groups pbg
      where ppa.payroll_action_id = pactid
        and pbg.business_group_id = ppa.business_group_id;
--
     select count(*)
       into cnt_incomplete_actions
       from pay_temp_object_actions
      where payroll_action_id = pactid
        and action_status <> 'C';
--
--
      if (cnt_incomplete_actions = 0) then
--
         if (l_remove_act is null or l_remove_act = 'Y') then
           pay_archive.remove_report_actions(pactid);
         end if;
      end if;
--
end deinitialise;
--
END pay_payroll_contact_pkg;

/
