--------------------------------------------------------
--  DDL for Package Body PAY_NZ_TAX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NZ_TAX" as
--  $Header: pynztax.pkb 120.0 2005/05/29 02:13:15 appldev noship $
--
--  Copyright (c) 1999 Oracle Corporation
--  All Rights Reserved
--
--  Procedures and functions used in NZ tax calculations
--
--  Change List
--  ===========
--
--  Date        Author   Reference Description
--  -----------+--------+---------+-------------
--  10-Aug-2004 sshankar 3181581   Performance issue - Fixed code for cursors c_cs_code_override and c_cs_code
--  24 Mar 2003 srrajago 2856694   Performance issue - Included joins with time period id and action status
--                                 for the cursors c_cs_code_override,c_cs_code and c_extra_emol_at_low_rate.
--  20 Nov 2000 Kaverma  2665496   modified cursor c_other_asg_exists query
--  14 Feb 2000 JTurner            Ported to R11i
--  27 JUL 1999 JTURNER  N/A       Added extra emol ind and child support
--                                 code fns
--  26 JUL 1999 JTURNER  N/A       Added half month start and end functions
--  22 JUL 1999 JTURNER  N/A       Created


--  other_asg_exists
--
--  function to check for existance of another current
--  payroll assignment for the employee


function other_asg_exists
(p_assignment_id in number) return varchar2 is

  l_dummy         varchar2(1) ;
  l_return_flag   varchar2(1) ;

  /* Bug No : 2665496 */

  cursor get_session_date is
   select effective_date
   from   fnd_sessions
   where  session_id = userenv('SESSIONID');

  cursor c_other_asg_exists (p2_assignment_id number,p_session_date date) is
    select null
    from   per_all_assignments_f a1
    ,      per_all_assignments_f a2
    where  a1.assignment_id = p2_assignment_id
    and    a2.person_id     = a1.person_id
    and    a2.assignment_id <> a1.assignment_id
    and    a2.payroll_id is not null
    and    p_session_date between a2.effective_start_date
                              and a2.effective_end_date;

  l_session_date  date;

begin

  hr_utility.set_location('hr_nz_tax.other_asg_exists', 10) ;

  open get_session_date;
  fetch get_session_date into l_session_date;
  close get_session_date;

  open c_other_asg_exists (p_assignment_id, l_session_date) ;

  fetch c_other_asg_exists into l_dummy ;

  if c_other_asg_exists%found
  then
    l_return_flag := 'Y' ;
  else
    l_return_flag := 'N' ;
  end if ;

  close c_other_asg_exists ;

  hr_utility.set_location('hr_nz_tax.other_asg_exists', 20) ;

  return l_return_flag ;

exception
  when others then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL');
    hr_utility.set_message_token('PROCEDURE', 'hr_nz_tax.other_asg_exists');
    hr_utility.set_message_token('STEP','body');
    hr_utility.raise_error ;

end other_asg_exists ;


--  half_month_start
--
--  Month halves are 1 - 15 and 16 - last day of month for tax reporting
--  purposes.  This function returns start date of half month that contains
--  effective date.


function half_month_start (p_effective_date in date) return date is

  l_return_date date ;

begin

  if p_effective_date < to_date('16/' || to_char(p_effective_date, 'mm/yyyy'), 'dd/mm/yyyy')
  then
    l_return_date := to_date('01/' || to_char(p_effective_date, 'mm/yyyy'), 'dd/mm/yyyy') ;
  else
    l_return_date := to_date('16/' || to_char(p_effective_date, 'mm/yyyy'), 'dd/mm/yyyy') ;
  end if ;

  return l_return_date ;

end half_month_start ;


--  half_month_end
--
--  Month halves are 1 - 15 and 16 - last day of month for tax reporting
--  purposes.  This function returns end date of half month that contains
--  effective_date.


function half_month_end (p_effective_date in date) return date is

  l_return_date date ;

begin

  if p_effective_date < to_date('16/' || to_char(p_effective_date, 'mm/yyyy'), 'dd/mm/yyyy')
  then
    l_return_date := to_date('15/' || to_char(p_effective_date, 'mm/yyyy'), 'dd/mm/yyyy') ;
  else
    l_return_date := last_day(p_effective_date) ;
  end if ;

  return l_return_date ;

end half_month_end ;


--  extra_emol_at_low_tax_rate
--
--  Determines if any extra emoluments have been taxed at the
--  lower rate.


function extra_emol_at_low_tax_rate (p_assignment_id in number, p_effective_date in date) return varchar2 is

  l_extra_emol_indicator  varchar2(1) ;
  l_start_date            date ;
  l_end_date              date ;
  l_dummy                 varchar2(1) ;

  /* Bug No : 2856694 - Included joins with time period id and action status in the where clause of the
     following cursor */

  cursor c_extra_emol_at_low_rate (p_assignment_id number
                                  ,p_start_date date
                                  ,p_end_date date) is
    select null
    from   pay_element_types_f      et
    ,      pay_input_values_f       iv
    ,      pay_run_results          rr
    ,      pay_run_result_values    rrv
    ,      pay_assignment_actions   aa
    ,      pay_payroll_actions      pa
    ,      per_time_periods         tp
    where  et.element_name = 'PAYE Tax Deduction'
    and    iv.element_type_id = et.element_type_id
    and    iv.name = 'Extra Emol at Low Tax Rate'
    and    rr.element_type_id = et.element_type_id
    and    rr.status in ('P','PA')
    and    rrv.run_result_id = rr.run_result_id
    and    rrv.input_value_id = iv.input_value_id
    and    rrv.result_value = 'Y'
    and    aa.assignment_action_id = rr.assignment_action_id
    and    aa.assignment_id = p_assignment_id
    and    pa.payroll_action_id = aa.payroll_action_id
    and    tp.payroll_id = pa.payroll_id
    and    pa.date_earned between tp.start_date
                              and tp.end_date
    and    tp.regular_payment_date between p_start_date
                                       and p_end_date
    and    tp.time_period_id   =   pa.time_period_id
    and    pa.action_status    =   'C'
    and    aa.action_status    =   'C';

begin

  l_start_date := to_date('01/' || to_char(p_effective_date, 'mm/yyyy'), 'dd/mm/yyyy') ;
  l_end_date := last_day(p_effective_date) ;

  open c_extra_emol_at_low_rate (p_assignment_id
                                ,l_start_date
                                ,l_end_date) ;

  fetch c_extra_emol_at_low_rate into l_dummy ;

  if c_extra_emol_at_low_rate%found
  then
    l_extra_emol_indicator := 'Y' ;
  else
    l_extra_emol_indicator := 'N' ;
  end if ;

  close c_extra_emol_at_low_rate ;

  return l_extra_emol_indicator ;

end extra_emol_at_low_tax_rate ;


--  child_support_code
--
--  Determines child support variation code.


function child_support_code (p_assignment_id in number, p_effective_date in date) return varchar2 is

  l_child_support_code    varchar2(1) ;
  l_start_date            date ;
  l_end_date              date ;

  /* Bug No : 2856694 - Included joins with time_period_id and action_status in the where clause of the
     following cursors c_cs_code_override and c_cs_code */

  --
  -- Bug 3181581
  -- Changed cursor code as part of performance fix. Added per_assignments_f and used effective_date
  -- instead of regular_payment_date
  --
  cursor c_cs_code_override (p_assignment_id number
                            ,p_start_date date
                            ,p_end_date date) is
    select rrv.result_value
    from   pay_element_types_f      et
    ,      pay_input_values_f       iv
    ,      pay_run_results          rr
    ,      pay_run_result_values    rrv
    ,      pay_assignment_actions   aa
    ,      per_assignments_f        asg
    ,      pay_payroll_actions      pa
    ,      per_time_periods         tp
    where  et.element_name = 'Child Support Information'
    and    iv.element_type_id = et.element_type_id
    and    iv.name = 'Child Support Code Override'
    and    rr.element_type_id = et.element_type_id
    and    rr.status in ('P','PA')
    and    rrv.run_result_id = rr.run_result_id
    and    rrv.input_value_id = iv.input_value_id
    and    rrv.result_value is not null
    and    aa.assignment_action_id = rr.assignment_action_id
    and    asg.assignment_id = p_assignment_id
    and    aa.assignment_id = asg.assignment_id
    and    pa.payroll_action_id = aa.payroll_action_id
    and    tp.payroll_id = pa.payroll_id
    and    pa.date_earned between tp.start_date
                              and tp.end_date
    and    pa.effective_date between p_start_date
                                       and p_end_date
    and    tp.time_period_id   =   pa.time_period_id
    and    pa.action_status    =   'C'
    and    aa.action_status    =   'C'
    order by
           pa.action_sequence desc ;

  --
  -- Bug 3181581
  -- Changed cursor code as part of performance fix. Added per_assignments_f and used effective_date
  -- instead of regular_payment_date
  --
  cursor c_cs_code (p_assignment_id number
                   ,p_start_date date
                   ,p_end_date date) is
    select rrv.result_value
    from   pay_element_types_f      et
    ,      pay_input_values_f       iv
    ,      pay_run_results          rr
    ,      pay_run_result_values    rrv
    ,      pay_assignment_actions   aa
    ,      per_assignments_f        asg
    ,      pay_payroll_actions      pa
    ,      per_time_periods         tp
    where  et.element_name = 'Child Support Deduction'
    and    iv.element_type_id = et.element_type_id
    and    iv.name = 'Child Support Code'
    and    rr.element_type_id = et.element_type_id
    and    rr.status in ('P','PA')
    and    rrv.run_result_id = rr.run_result_id
    and    rrv.input_value_id = iv.input_value_id
    and    aa.assignment_action_id = rr.assignment_action_id
    and    asg.assignment_id = p_assignment_id
    and    aa.assignment_id = asg.assignment_id
    and    pa.payroll_action_id = aa.payroll_action_id
    and    tp.payroll_id = pa.payroll_id
    and    pa.date_earned between tp.start_date
                              and tp.end_date
    and    pa.effective_date  between p_start_date
                              and     p_end_date
    and    tp.time_period_id   =   pa.time_period_id
    and    pa.action_status    =   'C'
    and    aa.action_status    =   'C'
    order by pa.action_sequence desc;

begin

  l_start_date := to_date('01/' || to_char(p_effective_date, 'mm/yyyy'), 'dd/mm/yyyy') ;
  l_end_date := last_day(p_effective_date) ;

  l_child_support_code := null ;

  open c_cs_code_override (p_assignment_id
                          ,l_start_date
                          ,l_end_date) ;

  fetch c_cs_code_override into l_child_support_code ;

  if c_cs_code_override%notfound
  then

    open c_cs_code (p_assignment_id
                   ,l_start_date
                   ,l_end_date) ;

    fetch c_cs_code into l_child_support_code ;

    if c_cs_code%notfound
    then
      l_child_support_code := null ;
    end if ;

    close c_cs_code ;

  end if ;

  close c_cs_code_override ;

  return l_child_support_code ;

end child_support_code ;

end pay_nz_tax ;

/
