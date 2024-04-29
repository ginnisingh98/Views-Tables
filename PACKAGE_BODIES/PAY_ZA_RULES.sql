--------------------------------------------------------
--  DDL for Package Body PAY_ZA_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_RULES" as
/* $Header: pyzarule.pkb 120.0 2006/04/12 01:02:41 kapalani noship $ */

  procedure get_source_text_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_text in out nocopy varchar2)
  is
    l_TaxDirNo         varchar2(60);
  begin
    hr_utility.set_location('PAY_ZA_RULES.get_source_text_context',1);
    begin

      select SCREEN_ENTRY_VALUE
      into   l_TaxDirNo
      from   pay_assignment_actions aa,
             pay_payroll_actions pa,
             pay_element_entries_f ee,
             pay_element_entry_values_f eev,
             pay_input_values_f iv,
             pay_element_types_f et,
             pay_element_links_f el
      where  aa.assignment_action_id = p_asg_act_id
      and    pa.payroll_action_id    = aa.payroll_action_id
      and    aa.assignment_id        = ee.assignment_id
      and    iv.input_value_id       = eev.input_value_id
      and    el.element_link_id      = ee.element_link_id
      and    ee.element_entry_id     = eev.element_entry_id
      and    ee.element_entry_id     = p_ee_id
--      and    et.element_name         = 'ZA_Tax_On_Lump_Sums'
      and    iv.name                 = 'Tax Directive Number'
      and    el.element_type_id     = et.element_type_id
      and    pa.date_earned between
             et.effective_start_date and et.effective_end_date
      and    pa.date_earned between
             iv.effective_start_date and iv.effective_end_date
      and    pa.date_earned between
             el.effective_start_date and el.effective_end_date
      and    pa.date_earned between
             ee.effective_start_date and ee.effective_end_date
      and    pa.date_earned between
             eev.effective_start_date and eev.effective_end_date;
    exception
      when others then
        l_TaxDirNo := null;
    end;
    p_source_text := l_TaxDirNo;
    hr_utility.set_location('pay_za_RULES.get_source_text_context='||
                               p_source_text,2);

  end get_source_text_context;


  procedure get_source_number_context
    (p_asg_act_id number
    ,p_ee_id number
    ,p_source_number in out nocopy varchar2)
  is
    l_ClearNo     varchar2(60);
  begin
    begin
      select SCREEN_ENTRY_VALUE
      into   l_ClearNo
      from   pay_assignment_actions aa,
             pay_payroll_actions pa,
             pay_element_entries_f ee,
             pay_element_entry_values_f eev,
             pay_input_values_f iv,
             pay_element_types_f et,
             pay_element_links_f el
      where  aa.assignment_action_id = p_asg_act_id
      and    pa.payroll_action_id    = aa.payroll_action_id
      and    aa.assignment_id        = ee.assignment_id
      and    iv.input_value_id       = eev.input_value_id
      and    el.element_link_id      = ee.element_link_id
      and    ee.element_entry_id     = eev.element_entry_id
      and    ee.element_entry_id     = p_ee_id
      and    iv.name                 = 'Clearance Number'
      and    el.element_type_id      = et.element_type_id
      and    pa.date_earned between
             et.effective_start_date and et.effective_end_date
      and    pa.date_earned between
             iv.effective_start_date and iv.effective_end_date
      and    pa.date_earned between
             el.effective_start_date and el.effective_end_date
      and    pa.date_earned between
             ee.effective_start_date and ee.effective_end_date
      and    pa.date_earned between
             eev.effective_start_date and eev.effective_end_date;

      p_source_number := l_ClearNo;

    exception
      when others then
        p_source_number := null;
    end;
    hr_utility.set_location('Leaving get_source_number_context.',10);

  end get_source_number_context;
end pay_za_rules;

/
