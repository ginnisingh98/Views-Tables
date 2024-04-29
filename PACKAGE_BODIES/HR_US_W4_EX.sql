--------------------------------------------------------
--  DDL for Package Body HR_US_W4_EX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_US_W4_EX" AS
/* $Header: pyusw4ex.pkb 120.1 2006/05/15 11:12:24 alikhar noship $ */
/*
 +=====================================================================+
 |              Copyright (c) 1997 Oracle Corporation                  |
 |                 Redwood Shores, California, USA                     |
 |                      All rights reserved.                           |
 +=====================================================================+
Name        : pyusw4ex.pkb
Description : This package declares functions and procedures which are
              used to return values for the Tax Form Exception Report.

Change List
-----------

Ver     Date        Author     Bug No    Description of Change
-------+-----------+----------+--------+--------------------------
115.0   11-06-00    Asasthan            Date Created
115.5   22-JUL-2003 ahanda     3061866  Changed cursor to get user_entity for US
115.6   08-JAN-2004 ardsouza   3349705  Used cursor instead of query to fetch
                                        latest assignment action for improved
                                        performance
115.7   09-JAN-2004 ardsouza   3349705  Added hint USE_NL to improve performance
115.8   12-JAN-2004 ardsouza   3349705  Suppressed index on ppa.effective_date.
                                        Hint USE_NL not needed. Added "not null"
                                        condition on paf.payroll_id.
115.9   12-MAY-2006 alikhar    5163321  Added code to handle no data found
                                        returned by cursor c_get_latest_asg.
=============================================================================

 */

 /*
 Name    : bal_db_item
  Purpose   : Given the name of a balance DB item as would be seen in a
              fast for mula
              it returns the defined_balance_id of the balance it represents.
  Arguments :
  Notes     : A defined balance_id is required by the PLSQL balance function.
 */

 function bal_db_item
 (
  p_db_item_name varchar2
 ) return number is

 /* Get the defined_balance_id for the specified balance DB item. */

   cursor csr_defined_balance is
     select to_number(UE.creator_id)
     from ff_user_entities  UE,
          ff_database_items DI
     where DI.user_name        = p_db_item_name
       and UE.user_entity_id   = DI.user_entity_id
       and Ue.creator_type     = 'B'
       and ue.legislation_code = 'US';

   l_defined_balance_id pay_defined_balances.defined_balance_id%type;

 begin

   open csr_defined_balance;
   fetch csr_defined_balance into l_defined_balance_id;
   if csr_defined_balance%notfound then
     close csr_defined_balance;
     raise hr_utility.hr_error;
   else
     close csr_defined_balance;
   end if;

   return (l_defined_balance_id);

end bal_db_item;


FUNCTION get_bal_info   (w4_tax_unit_id   in number,
                         w4_jurisdiction_code in varchar2,
                         w4_person_id in number,
                         w4_start_date in date,
                         w4_end_date in date)
                         RETURN NUMBER

IS
l_bal_aaid  pay_assignment_actions.assignment_action_id%type;
l_balance   pay_run_result_values.result_value%type :=null;
l_hours_ytd number := 0;
l_gross_ytd number := 0;
l_gross_per_week number :=0;
l_gross_per_hour number :=0;

-- Bug 3349705 - Cursor to fetch the latest assignment action id.
--
  CURSOR c_get_latest_asg(p_person_id number ) IS
            select paa.assignment_action_id
              from pay_assignment_actions     paa,
                   per_all_assignments_f      paf,
                   pay_payroll_actions        ppa,
                   pay_action_classifications pac
             where paf.person_id     = p_person_id
               and paa.assignment_id = paf.assignment_id
               and paa.tax_unit_id   = w4_tax_unit_id
               and paa.payroll_action_id = ppa.payroll_action_id
               and ppa.action_type = pac.action_type
               and pac.classification_name = 'SEQUENCED'
               and ppa.business_group_id = paf.business_group_id
               and paf.payroll_id is not null
               and ppa.effective_date +0 between paf.effective_start_date
                                             and paf.effective_end_date
               and ppa.effective_date +0 between w4_start_date
                                             and w4_end_date
               and ((nvl(paa.run_type_id, ppa.run_type_id) is null
               and  paa.source_action_id is null)
                or (nvl(paa.run_type_id, ppa.run_type_id) is not null
               and paa.source_action_id is not null )
               or (ppa.action_type = 'V' and ppa.run_type_id is null
                    and paa.run_type_id is not null
                    and paa.source_action_id is null))
               order by paa.action_sequence desc;

Begin


Begin
            open c_get_latest_asg(w4_person_id );
	    fetch c_get_latest_asg into l_bal_aaid;
	    if c_get_latest_asg%notfound then
                l_balance := 0;
	    end if;
            close c_get_latest_asg;

Exception
             when no_data_found then
                  l_balance := 0;
End;

/* Bug 3349705 - Commented and replaced by cursor above for performance problems.

Begin
select paa1.assignment_action_id
              into l_bal_aaid
              from pay_assignment_actions     paa1,
                   per_assignments_f          paf2,
                   pay_payroll_actions        ppa2,
                   pay_action_classifications pac2
             where paf2.person_id     = w4_person_id
               and paa1.assignment_id = paf2.assignment_id
               and paa1.tax_unit_id   = w4_tax_unit_id
               and paa1.payroll_action_id = ppa2.payroll_action_id
               and ppa2.action_type = pac2.action_type
               and pac2.classification_name = 'SEQUENCED'
               and ppa2.effective_date between paf2.effective_start_date
                                           and paf2.effective_end_date
               and ppa2.effective_date between w4_start_date and
                                               w4_end_date
               and not exists (select ''
                                 FROM pay_action_classifications pac,
                                      pay_payroll_actions ppa,
                                      pay_assignment_actions paa,
                                      per_assignments_f paf1
                                WHERE paf1.person_id = w4_person_id
                                  AND paa.assignment_id = paf1.assignment_id
                                  AND paa.tax_unit_id = w4_tax_unit_id
                                  AND ppa.payroll_action_id = paa.payroll_action_id
                                  AND ppa.effective_date between w4_start_date and
                                                                 w4_end_date
                                  AND paa.action_sequence > paa1.action_sequence
                                  AND pac.action_type = ppa.action_type
                                  AND pac.classification_name = 'SEQUENCED')
                and rownum < 2;
Exception
 when no_data_found then
 l_balance := 0;
End;

*/

if l_balance is null then

pay_balance_pkg.set_context('TAX_UNIT_ID',w4_tax_unit_id);

if w4_jurisdiction_code <> '00-000-0000' then

 pay_balance_pkg.set_context('JURISDICTION_CODE',w4_jurisdiction_code);
end if;

l_hours_ytd :=  nvl(pay_balance_pkg.get_value
       (p_defined_balance_id   => bal_db_item('REGULAR_HOURS_WORKED_PER_GRE_YTD'),
       p_assignment_action_id => l_bal_aaid),0);

if l_hours_ytd = 0 then
   l_gross_per_week := 0;
else
   l_gross_ytd :=  nvl(pay_balance_pkg.get_value
                   (p_defined_balance_id   => bal_db_item('GROSS_EARNINGS_PER_GRE_YTD'),
                   p_assignment_action_id => l_bal_aaid),0);

   l_gross_per_hour := l_gross_ytd/l_hours_ytd;
   l_gross_per_week := l_gross_per_hour * 40;
end if;

end if;

return(l_gross_per_week);
End ; /* get_bal_info */




FUNCTION get_tax_info   (w4_tax_unit_id   in number,
                         w4_jurisdiction_code in varchar2,
                         w4_person_id in number,
                         w4_allowance in varchar2,
                         w4_exempt in varchar2,
                         w4_state_code in varchar2,
                         w4_start_date in date,
                         w4_end_date in date)
                         RETURN NUMBER

IS
 l_exception number(1) := 0;
 l_fed_earnings number;
 l_fed_allowance number;
 l_state_allowance number;
 l_state_earnings number;
 l_gross_earnings_per_week number :=0;

BEGIN
 if w4_jurisdiction_code = '00-000-0000' then

   Begin

    select nvl(to_number(fed_information1),0),nvl(to_number(fed_information2),0)
      into l_fed_allowance , l_fed_earnings
      from pay_us_federal_tax_info_f
     where fed_information_category = 'ALLOWANCES LIMIT';

   Exception
     when no_data_found then
      raise hr_utility.hr_error;
   End;

    if nvl(l_fed_allowance,0) > 0 then
     if nvl(to_number(w4_allowance),0) > l_fed_allowance then
       l_exception := 1;
     end if;
    end if;

   if w4_exempt = 'Y' then
    if nvl(l_fed_earnings,0) > 0 then
       l_gross_earnings_per_week:= get_bal_info(w4_tax_unit_id,
                                                w4_jurisdiction_code,
                                                w4_person_id ,
                                                w4_start_date ,
                                                w4_end_date);
       if l_gross_earnings_per_week > l_fed_earnings then
          l_exception := 1;
       end if;
    end if;
   end if;

else

   Begin

    select to_number(sta_information10),to_number(sta_information11)
      into l_state_allowance , l_state_earnings
      from pay_us_state_tax_info_f
       where state_code = substr(w4_jurisdiction_code,1,2)
       and effective_end_date = to_date('31/12/4712','DD/MM/YYYY')
       and sta_information_category = 'State tax limit rate info';

   Exception
     when no_data_found then
      /* the state is not interested in knowing exceptions
         so smoothly get out */
	 l_exception := 0;
      return(l_exception);
   End;

    if nvl(l_state_allowance,0) > 0 then
     if w4_allowance > l_state_allowance then
       l_exception := 1;
     end if;
    end if;

   if w4_exempt = 'Y' then
    if nvl(l_state_earnings,0) > 0 then
       l_gross_earnings_per_week:= get_bal_info(w4_tax_unit_id,
                                                w4_jurisdiction_code,
                                                w4_person_id ,
                                                w4_start_date ,
                                                w4_end_date);
       if l_gross_earnings_per_week > l_state_earnings then
          l_exception := 1;
       end if;
    end if;
   end if;
end if;

      if substr(w4_jurisdiction_code,1,2) = '03' then
         l_exception := 1;
      end if;
return(l_exception);
END get_tax_info;

end hr_us_w4_ex;

/
