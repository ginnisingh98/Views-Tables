--------------------------------------------------------
--  DDL for Package Body PAY_IE_PRSI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IE_PRSI" AS
/* $Header: pyieprsi.pkb 120.1.12010000.2 2009/05/06 04:57:14 knadhan ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  IE PAYE package
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  26 JUN 2001 ILeath    N/A        Created
**  16 SEP 2002 Vimal     N/A      Fixed bug 2547639.
**                                 The procedure initialise has been changed
**                                 such that contribution_class is now set to
**                                 IE_A. Also even if the cursor
**                                 c_prsi_dtl retuns no row, wew still retun
**                                 1 instead of 0 as this will let default
**                                 PRSI contributions.
**  10-JAN-2003 SMRobins  2652940  Added function:
**                                 get_ins_weeks_for_monthly_emps
**  14-JAN-2003 SMRobins           Added function: get_period_type
**  04-feb-2004 vmkhande  3419204  The get_ins_weeks_for_monthly
                                   returns l_count_of_days of 1, when
                                   l_count_of_days is -ve, this is incorrect
                                   for terminarted employees being processed
                                   after last standard process date.
                                   it should retrun 0 as the number of insuarable
                                   weeks for terminated employee is 0. But
                                   l_count_of_days is used in IE_PRSI_INITIALIZE
                                   to derive the multiplying factor. hence
                                   the l_count_of_days is not being set to 0
                                   but we will return -ve and handle -ve value
                                   in fast formula.
    11-feb-2004 vmkhande  3436179  Fixed gscc warning.
                                   Date conversion was not using format mask.
                                   Added format mask.
    16-dec-2006 rbhardwa  3427614  Modified code to calculate correct insurable weeks
                                   for jan and dec.
**  21-APR-2009 knadhan  8448176    Added function get_bal_value_30_04_09
**  21-APR-2009 knadhan  8448176    Added exception block in function get_bal_value_30_04_09
------------------------------------------------------------------------------
*/
g_package  varchar2(33) := 'pay_ie_prsi.';

/* knadhan */
FUNCTION get_bal_value_30_04_09 (p_assignment_id IN  per_all_assignments_f.assignment_id%TYPE
                                 ,p_tax_unit_id IN NUMBER
                                 ,p_balance_name IN pay_balance_types.balance_name%TYPE
				 ,p_dimension_name IN pay_balance_dimensions.dimension_name%TYPE
				 ,p_till_date IN DATE) RETURN  number IS
CURSOR cur_assignment_action is
SELECT fnd_number.canonical_to_number(substr(max(lpad(paa.action_sequence,15,'0')||
      paa.assignment_action_id),16))
FROM pay_assignment_actions paa
    ,pay_payroll_actions ppa
WHERE paa.assignment_id=p_assignment_id
  AND paa.payroll_action_id=ppa.payroll_action_id
  AND ppa.action_type in ('Q','B','R','I','V')
  AND ppa.action_status ='C'
  AND paa.source_action_id is null
  AND ppa.effective_date<= p_till_date;
CURSOR cur_defined_balance_id is
SELECT pdb.defined_balance_id
FROM pay_balance_dimensions pbd
    ,pay_defined_balances  pdb
    ,pay_balance_types pbt
WHERE pbt.balance_name = p_balance_name
  AND pbt.legislation_code='IE'
  AND pbd.dimension_name =p_dimension_name
  AND pbd.legislation_code='IE'
  AND pdb.balance_dimension_id=pbd.balance_dimension_id
  AND pdb.balance_type_id=pbt.balance_type_id;
l_assignment_action pay_assignment_actions.assignment_action_id%type;
l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;
l_balance_value                  NUMBER:=0;
  BEGIN
  OPEN cur_assignment_action;
  FETCH cur_assignment_action INTO l_assignment_action;
  CLOSE cur_assignment_action;
  OPEN cur_defined_balance_id;
  FETCH cur_defined_balance_id INTO l_defined_balance_id;
  CLOSE cur_defined_balance_id;
  /* 8448176 */
  BEGIN
  l_balance_value := PAY_BALANCE_PKG.GET_VALUE(l_defined_balance_id,
                                   l_assignment_action,
                                   p_tax_unit_id,
                                   null,
                                   null,
                                   null,
                                   null,
                                   null);
   EXCEPTION When others THEN
   RETURN 0;
   END;
   IF l_balance_value is null THEN
   l_balance_value:=0;
   END IF;
   RETURN l_balance_value;
   END;

 Function get_prsi_details ( p_assignment_id            in           number
                            ,p_payroll_action_id        in           number
                            ,p_contribution_class       out   nocopy varchar2
                            ,p_overridden_subclass      out   nocopy varchar2
                            ,p_soc_ben_flag             out   nocopy varchar2
                            ,p_overridden_ins_weeks     out   nocopy number
                            ,p_community_flag           out   nocopy varchar2
                            ,p_exemption_start_date     out   nocopy date
                            ,p_exemption_end_date       out   nocopy date) return number is


  --Local vriables-----

  l_proc                 varchar2(72) := g_package||'get_prsi_details';

  cursor c_prsi_dtl is select contribution_class
                              ,overridden_subclass
                              ,soc_ben_flag
                              ,overridden_ins_weeks
                              ,community_flag
                              ,exemption_start_date
                              ,exemption_end_date
                         from  pay_ie_prsi_details_v pipd
                               ,pay_payroll_actions ppa
                        where  assignment_id = p_assignment_id
                          and  ppa.payroll_action_id = p_payroll_action_id
                          and  ppa.date_earned between pipd.effective_start_date and pipd.effective_end_date;

   procedure initialise is
   begin
      p_contribution_class:='IE_A';
      --p_overridden_subclass:='z ';
      p_soc_ben_flag:='N';
      --p_overridden_ins_weeks:=0;
      --p_community_flag:=' ';
      --p_exemption_start_date:=to_date('01-01-0001','DD-MM-YYYY');
      --p_exemption_end_date:=to_date('01-01-0001','DD-MM-YYYY');
   end;


 --end Local vriables---------

begin

    hr_utility.set_location('Entering:'||l_proc, 5);

    open c_prsi_dtl;

    fetch c_prsi_dtl into p_contribution_class
                         ,p_overridden_subclass
                         ,p_soc_ben_flag
                         ,p_overridden_ins_weeks
                         ,p_community_flag
                         ,p_exemption_start_date
                         ,p_exemption_end_date;
    if c_prsi_dtl%notfound then
        initialise;
        close c_prsi_dtl;
        return 1;
    end if;
    close c_prsi_dtl;
    hr_utility.set_location('Leaving:'||l_proc, 30);
    return 1;
exception when others then
     initialise;
     close c_prsi_dtl;
     return 0;

end get_prsi_details;
--
-- Adding function get_ins_weeks_for_monthly_emps
-- to address bug 2652940.
-- We work out what DAY the 01-JAN for the processing
-- year falls on, and then work out how many of those
-- days falls between the greatest start date and
-- lowest end date. The greatest start date is the greatest
-- of processing period start date and emp hire date (except
-- for January which excludes the first day of the month).
-- The lowest end date is the earliest of the processing
-- period end date and the emp termination date
--
Function get_ins_weeks_for_monthly_emps( p_hire_date              in  date
                                        ,p_proc_period_start_date in  date
                                        ,p_term_date              in  date
                                        ,p_proc_period_end_date   in  date
                                        ,p_processing_date        in  date)
Return  NUMBER IS
--
l_day                     varchar2(120);
l_test_day                varchar2(120);
l_actual_start_of_year    date;
l_calc_start_of_year      date;
l_count_of_days           number := 0;
l_greatest_start_date     date;
l_lowest_end_date         date;
l_test_date               date;
l_compare_date            date;  -- 3427614
--
Cursor day_of_week (p_test_date in date) is
   select to_char(p_test_date, 'DAY') from sys.dual;
BEGIN
/* 3436179 */
-- l_calc_start_of_year := to_date('02-JAN-'||to_char(p_processing_date,'RRRR'));
 l_calc_start_of_year := to_date('02/01/'||to_char(p_processing_date,'RRRR'),
                         'DD/MM/RRRR');

 l_actual_start_of_year := l_calc_start_of_year -1;
 --
 -- What days is the first day of the year
 --
 OPEN day_of_week(l_actual_start_of_year);
 FETCH day_of_week into l_day;
 CLOSE day_of_week;
 l_greatest_start_date := greatest(p_proc_period_start_date, p_hire_date, l_actual_start_of_year);  -- 3427614
 l_lowest_end_date := least(p_proc_period_end_date, p_term_date);
 l_test_date := l_greatest_start_date;
 WHILE l_test_date <= l_lowest_end_date loop
   OPEN day_of_week(l_test_date);
   FETCH day_of_week into l_test_day;
   CLOSE day_of_week;
  IF l_test_day = l_day THEN
   l_count_of_days := l_count_of_days + 1;
  END IF;
  l_test_date := l_test_date + 1;
 END LOOP;
 /* 3419204
 If l_count_of_days < 1 then
   l_count_of_days := 1;
 End If;
 */
l_compare_date := to_date('01/12/'||to_char(l_greatest_start_date,'RRRR'),       -- to assign only 4 weeks for dec month
                    'DD/MM/RRRR');                                               -- 3427614
IF l_greatest_start_date >= l_compare_date THEN
   l_count_of_days := l_count_of_days - 1;
END IF;
 RETURN l_count_of_days;
end get_ins_weeks_for_monthly_emps;
--
Function get_period_type (p_payroll_id      in  number
                         ,p_session_date    in  date)
RETURN  varchar2 IS
--
l_period_type  varchar2(120);
--
cursor get_type is
select pap.period_type
from   pay_all_payrolls_f pap
where  pap.payroll_id = p_payroll_id
and    p_session_date between pap.effective_start_date and pap.effective_end_date;
--
Begin
  OPEN get_type;
  FETCH get_type into l_period_type;
  CLOSE get_type;
  RETURN l_period_type;
End get_period_type;
--
Function get_period_start_date (p_payroll_id   in number
                               ,p_session_date in date)
RETURN  varchar2 IS
--
l_period_start_date   date;
--
cursor get_start_date is
select ptp.start_date
from   per_time_periods ptp
where  ptp.payroll_id = p_payroll_id
and    p_session_date between ptp.start_date and ptp.end_date;
--
Begin
   OPEN get_start_date;
   FETCH get_start_date into l_period_start_date;
   CLOSE get_start_date;
   RETURN l_period_start_date;
End get_period_start_date;
--
Function get_period_end_date (p_payroll_id   in number
                               ,p_session_date in date)
RETURN  varchar2 IS
--
l_period_end_date   date;
--
cursor get_end_date is
select ptp.end_date
from   per_time_periods ptp
where  ptp.payroll_id = p_payroll_id
and    p_session_date between ptp.start_date and ptp.end_date;
--
Begin
   OPEN get_end_date;
   FETCH get_end_date into l_period_end_date;
   CLOSE get_end_date;
   RETURN l_period_end_date;
End get_period_end_date;
--
end pay_ie_prsi;

/
