--------------------------------------------------------
--  DDL for Package Body PAY_SA_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SA_RULES" as
/* $Header: pysarule.pkb 115.0 2003/12/24 01:39:13 abppradh noship $ */

--
--
-- private globals used for caching in get_dynamic_org_meth
  TYPE g_org_meth_map_rec IS RECORD (
    estab_id           pay_assignment_actions.tax_unit_id%TYPE,
    gen_org_paymeth_id pay_org_payment_methods_f.ORG_PAYMENT_METHOD_ID%TYPE,
    new_org_paymeth_id pay_org_payment_methods_f.ORG_PAYMENT_METHOD_ID%TYPE,
    err_name           fnd_new_messages.MESSAGE_NAME%TYPE,
    opm_name_token     varchar2(80),
    org_name_token     varchar2(60),
    org_type_token     varchar2(20));
  TYPE g_org_meth_map_typ IS TABLE OF g_org_meth_map_rec
    Index by BINARY_INTEGER;
  g_org_meth_map_tbl     g_org_meth_map_typ;
  g_assignment_action_id pay_assignment_actions.assignment_action_id%TYPE;
  g_estab_id             pay_assignment_actions.tax_unit_id%TYPE;
-- end of private globals used for caching in get_dynamic_org_meth


  procedure get_source_text_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_text in out nocopy varchar2)
  is
    l_joiner         varchar2(1) := 'N';
  begin
    hr_utility.set_location('PAY_SA_RULES.get_source_text_context',1);
    begin
      select 'Y'
      into   l_joiner
      from   pay_assignment_actions aa
             ,pay_payroll_actions pa
             ,per_all_assignments_f asg
             ,per_periods_of_service pos
      where  aa.assignment_action_id = p_asg_act_id
      and    pa.payroll_action_id    = aa.payroll_action_id
      and    aa.assignment_id = asg.assignment_id
      and    asg.period_of_service_id = pos.period_of_service_id
      and    trunc(POS.date_start, 'MM') = trunc(PA.effective_date, 'MM')
      and    pa.effective_date between ASg.effective_start_date
                               and ASg.effective_end_date;
    exception
      when others then
        l_joiner := 'N';
    end;
    p_source_text := l_joiner;
    hr_utility.set_location('pay_sa_RULES.get_source_text_context='||
                               p_source_text,2);

  end get_source_text_context;


  procedure get_source_text2_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_text2 in out nocopy varchar2)
  is
    l_leaver     varchar2(1) := 'N';
  begin
    hr_utility.set_location('PAY_SA_RULES.get_source_text_context',1);
    begin
      select 'Y'
      into   l_leaver
      from   pay_assignment_actions aa
             ,pay_payroll_actions pa
             ,per_all_assignments_f asg
             ,per_periods_of_service POS
      where  aa.assignment_action_id = p_asg_act_id
      and    pa.payroll_action_id    = aa.payroll_action_id
      and    aa.assignment_id = asg.assignment_id
      and    asg.period_of_service_id = pos.period_of_service_id
      and    trunc(NVL(POS.actual_termination_date , TO_DATE('31/12/4712','DD/MM/YYYY')), 'MM') = trunc(PA.effective_date, 'MM')
      and  pa.effective_date between ASg.effective_start_date
                                and ASg.effective_end_date;
    exception
      when otherS then
        l_leaver := 'N';
    end;
    p_source_text2 := l_leaver;
    hr_utility.set_location('pay_sa_RULES.get_source_text_context='||
                               p_source_text2,2);

  end get_source_text2_context;


  procedure get_source_number_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_number in out nocopy varchar2)
  is
    l_nationality_cd     varchar2(30);
  begin
    begin
      select nationality
      into   l_nationality_cd
      from   pay_assignment_actions aa
             ,pay_payroll_actions pa
             ,per_all_assignments_f asg
             ,per_all_people_f per
      where  aa.assignment_action_id = p_asg_act_id
      and    pa.payroll_action_id    = aa.payroll_action_id
      and    aa.assignment_id = asg.assignment_id
      and    asg.person_id = per.person_id
      and    pa.effective_date between ASg.effective_start_date
                               and ASg.effective_end_date
      and    pa.effective_date between PER.effective_start_date
                               and PER.effective_end_date;

      if l_nationality_cd = UPPER(FND_PROFILE.VALUE('PER_LOCAL_NATIONALITY')) then
        p_source_number := 1;
      else
        p_source_number := 2;
      end if;

    exception
      when others then
        p_source_number := 0;
    end;
    hr_utility.set_location('Leaving get_source_number_context.',10);

  end get_source_number_context;
end pay_sa_rules;

/
