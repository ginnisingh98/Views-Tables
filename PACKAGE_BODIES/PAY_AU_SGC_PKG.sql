--------------------------------------------------------
--  DDL for Package Body PAY_AU_SGC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AU_SGC_PKG" as
/* $Header: pyausgc.pkb 120.0 2005/05/29 01:56:08 appldev noship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Australia SGC Report
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  07-DEC-2000 RSINGHAL  N/A           Created
**  10-JAN-2001 RSINGHAL  bug#1574764   Modifications for performance issue.
**  07-FEB-2001 RSINGHAL  bug#1560081   p_business_group_id parameter added in c**                                      ursor assign_work_hrs.
**  04-FEB-2002 VGSRINIV  Bug#2197813   sgc contribution calculated in procedure
**                                      employee_super_details is rouned to 5cents
**                                      and added dbdrv commands
**  14-MAR-2002 SHOSKATT  2197813       Added the round to 5cents function when
**                                      displaying the amount in the messages
**  03-DEC-2002 RAGOVIND  2689226       Added NOCOPY for the function employee_super_details
**  09-AUG-2004 ABHKUMAR  2610141       Legal Employer enhancement changes
**  12-AUG-2004 ABHKUMAR  2610141       Modified the code to pick the correct defined balance id for calculating _ASG_LE_QTD balance value
*/

-------------------------------------------------------------------------------

----------------/*  procedure global_super_values */-----------------------

procedure global_super_values(
                              p_effective_date in date,
                              p_legislation_code in  pay_balance_types.
                                                     legislation_code%type
                              )
as
cursor c_global(c_effective_date date,
                c_legislation_code pay_balance_types.legislation_code%type) is
                select global_name,global_value from
                ff_globals_f where global_name in ('SUPER_MONTHLY_EARNINGS',
                                                   'SUPER_MAX_AGE',
                                                   'SUPER_MIN_AGE',
                                                   'SUPER_MIN_HOURS',
                                                   'SUPER_MAX_BASE_QTR')
                and c_effective_date between effective_start_date
                                         and effective_end_date
                and legislation_code=c_legislation_code;

/*Bug 2610141----Modfied the cursor to return defined_balanace_id */

cursor c_super_bal_id(c_legislation_code pay_balance_types.legislation_code%type,
                      c_dimension_name pay_balance_dimensions.database_item_suffix%type)
                    is
                    select pdb.defined_balance_id
		    FROM   pay_balance_types pbt,
                           pay_balance_dimensions pbd,
                           pay_defined_balances pdb
                    where pbt.balance_name='Super_Guarantee'
		    AND   pbt.legislation_code=c_legislation_code
                    AND   pbd.database_item_suffix = c_dimension_name
                    AND   pbt.balance_type_id      = pdb.balance_type_id
                    AND   pbd.balance_dimension_id = pdb.balance_dimension_id;


l_name         ff_globals_f.global_name%type;
l_value        ff_globals_f.global_value%type;



begin
    hr_utility.set_location('Entering : global_super_values',1);
    hr_utility.trace('p_effective_date'||p_effective_date);


-- /* select all global value(legislative) */

open c_global(p_effective_date,p_legislation_code);
loop
     exit when c_global%notfound;
     fetch c_global into l_name,l_value;
     If    l_name = 'SUPER_MONTHLY_EARNINGS' then
           g_monthly_threshold  := l_value;
     elsif l_name = 'SUPER_MAX_AGE' then
           g_age  := l_value;
     elsif l_name = 'SUPER_MIN_AGE' then
           g_age_min := l_value;
     elsif l_name = 'SUPER_MIN_HOURS' then
	   	   g_min_hrs_worked := l_value;
     elsif l_name = 'SUPER_MAX_BASE_QTR' then
           g_qtd_threshold := l_value;
     end if;
end loop;
close c_global;

--
-- /* get the balance id for 'Super Guarantee' Balance */
--

open c_super_bal_id(p_legislation_code,'_ASG_LE_MTD');
   fetch c_super_bal_id into g_super_guarantee_bal_id_mtd; --2610141
close c_super_bal_id;


Exception
  when others then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
    hr_utility.set_message_token('PROCEDURE', 'pay_au_sgc_pkg.gobal_super_values    ');
    hr_utility.set_message_token('STEP','body') ;
    hr_utility.raise_error ;

end global_super_values;



/*----------------------Compliance Mesg ------------------------------*/



function compliance_mesg
            (p_assignment_id    in per_all_assignments_f.assignment_id%type,
             p_employee_age     in number,
             p_effective_date   in date,
             p_sgc_rate          in number,
             p_business_group_id in per_all_people_f.business_group_id%type,
	     p_registered_employer in NUMBER, --2610141
	     p_legislation_code in  pay_balance_types.legislation_code%type--2610141
                        )   return varchar2
IS

/*Bug 2610141 - Portion added to get the latest assignment action id*/
cursor get_latest_id  (   c_assignment_id in number	--Bug#2610141
			, c_effective_date in date
		) is
select  /*+ORDERED*/ to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
from    pay_assignment_actions      paa
,       pay_payroll_actions         ppa
where   paa.assignment_id           = c_assignment_id
    and ppa.payroll_action_id   = paa.payroll_action_id
    and ppa.effective_date      <= c_effective_date
    and ppa.effective_date      >= trunc(c_effective_date,'MM')
    and ppa.action_type         in ('R', 'Q', 'I', 'V', 'B')
    and paa.action_status='C'
    and ppa.action_status='C'
    and paa.tax_unit_id = p_registered_employer;



l_age                      number;
l_sgc_rate                 number;
l_compliance_mesg          varchar2(100);
l_hrs_worked               number ;
l_min_superable_salary     number;
l_SGC_qtd                  number;
l_sgc_contribution         number;
l_superable_sal            number;
l_bal_id                   pay_balance_types.balance_type_id%type;
l_bal_id_mtd               pay_balance_types.balance_type_id%type; --2610141
l_salary                   number;
l_bal_id_min_superable_sal pay_balance_types.balance_type_id%type;
l_assignment_action_id     pay_assignment_actions.assignment_action_id%type; --2610141
l_super_guarantee_bal_id_qtd pay_defined_balances.defined_balance_id%type; --2610141



begin
    hr_utility.set_location('Entering: function compliance_mesg',2);
/*Bug 2610141 - Portion added to get the latest assignment action id*/
    open get_latest_id(p_assignment_id,p_effective_date);
    fetch get_latest_id into l_assignment_action_id;
    close get_latest_id;

    l_sgc_rate:=(p_sgc_rate/100);



------------ /* to get the normal hours worked */--------------------


open assign_work_hrs(p_effective_date,p_assignment_id,p_business_group_id,p_registered_employer); --2610141
    fetch assign_work_hrs into l_hrs_worked;
    If assign_work_hrs%notfound then
         l_hrs_worked:=null ;
    End if;
close assign_work_hrs;



--------/* to ensure that the employee is paid super even when hours worked is not defined */---------
/*
  If l_hrs_worked is null then
      l_hrs_worked:= g_min_hrs_worked + 1;
  end if;
*/

-------/* to ensure that the employee is paid super even when age is not defined   */----------


If p_employee_age is null then
      l_age:= g_age_min + 1;
else
      l_age:=p_employee_age;
end if;


     hr_utility.trace('hrs_worked = '||l_hrs_worked);
     hr_utility.trace('employee_age = '||l_age);


------------------ /* to get the SGC Contribution for the month */--------------------------------
/*Bug 2610141 --- Added this portion to accomodate for the BRA changes */
l_sgc_contribution := pay_balance_pkg.get_value(g_super_guarantee_bal_id_mtd,
                                                l_assignment_action_id,
						p_registered_employer,null,null,null,null);



/*Bug 2610141 --- Added portion for the BRA changes ends here*/


-------------- /* get minimum superable salary  and balance_id */----------------------


open bal(p_business_group_id,p_assignment_id,p_effective_date);
loop
       exit when bal%notfound;
       fetch bal into l_bal_id_min_superable_sal; /*Bug 2610141 */
       open bal_id_mtd(l_bal_id_min_superable_sal,p_legislation_code); /*Bug 2610141 */
       fetch bal_id_mtd into l_bal_id_mtd;
       l_salary := pay_balance_pkg.get_value(l_bal_id_mtd,
                                                l_assignment_action_id,
						p_registered_employer,null,null,null,null); /*Bug 2610141 */
       IF bal%rowcount = 1 then
            l_bal_id := l_bal_id_min_superable_sal;
            l_min_superable_salary := l_salary;
       ELSIF l_salary < l_min_superable_salary THEN
            l_bal_id := l_bal_id_min_superable_sal;
            l_min_superable_salary := l_salary;
       END IF;
       close bal_id_mtd; /*Bug 2610141 */
end loop;
close bal;

l_superable_sal := l_min_superable_salary;


-------------/* get QTD *Superannuation Salary*/----------------------------

/*Bug 2610141 --- Added this portion to accomodate for the BRA changes */
OPEN bal_id_qtd(l_bal_id,p_legislation_code);
FETCH bal_id_qtd INTO l_super_guarantee_bal_id_qtd;
CLOSE bal_id_qtd;

l_SGC_qtd := pay_balance_pkg.get_value(l_super_guarantee_bal_id_qtd,
                                                l_assignment_action_id,
						p_registered_employer,null,null,null,null);

/*Bug 2610141 --- Added portion for the BRA changes ends here*/


---------------------------/* get compliance message */----------------------------


   If (l_superable_sal * l_sgc_rate) <= l_sgc_contribution then
              l_compliance_mesg :=null;
   ELSE
              l_compliance_mesg := 'EXCEPTION' ;
   END IF;


     hr_utility.trace('Out : function compliance_mesg');


return l_compliance_mesg;
--
Exception
 when others then
   hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
   hr_utility.set_message_token('PROCEDURE', 'pay_au_sgc_pkg.compliance_mesg') ;
   hr_utility.set_message_token('STEP','body') ;
   hr_utility.raise_error ;

END compliance_mesg;


/*----------------------------EMPLOYEE_SUPER_DETAILS------------------------*/

procedure employee_super_details
            (p_assignment_id    in per_all_assignments_f.assignment_id%type,
	     p_registered_employer in NUMBER, --2610141
             p_employee_age     in number,
             p_effective_date   in date,
             p_sgc_rate         in number,
             p_business_group_id in per_all_people_f.business_group_id%type,
	     p_legislation_code in  pay_balance_types.legislation_code%type,--2610141
             p_superable_sal    out NOCOPY number,
             p_sgc_contribution out NOCOPY number,
             p_compliance_mesg  out NOCOPY varchar2,
             p_warning_mesg     out NOCOPY varchar2
            )
IS

/*Bug 2610141 - Portion added to get the latest assignment action id*/
cursor get_latest_id  (   c_assignment_id in number	--Bug#2610141
			, c_effective_date in date
		) is
select  /*+ORDERED*/ to_number(substr(max(lpad(paa.action_sequence,15,'0')||paa.assignment_action_id),16))
from    pay_assignment_actions      paa
,       pay_payroll_actions         ppa
where   paa.assignment_id           = c_assignment_id
    and ppa.payroll_action_id   = paa.payroll_action_id
    and ppa.effective_date      <= c_effective_date
    and ppa.effective_date      >= trunc(c_effective_date,'MM')
    and ppa.action_type         in ('R', 'Q', 'I', 'V', 'B')
    and paa.action_status='C'
    and ppa.action_status='C'
    and paa.tax_unit_id = p_registered_employer;


l_age                      number;
l_sgc_rate                 number;
l_hrs_worked               number ;
l_min_superable_salary     number;
l_max_superable_salary     number;
l_SGC_qtd                  number;
l_bal_id                   pay_balance_types.balance_type_id%type;
l_bal_id_mtd               pay_balance_types.balance_type_id%type; --2610141
l_salary                   number;
l_bal_id_min_superable_sal pay_balance_types.balance_type_id%type;
l_assignment_action_id     pay_assignment_actions.assignment_action_id%type; --2610141
l_super_guarantee_bal_id_qtd pay_defined_balances.defined_balance_id%type; --2610141


begin
   hr_utility.set_location(' Entering : employee_super_details',3);
   hr_utility.trace('p_assgnment_id ='||p_assignment_id);
   hr_utility.trace('p_effective_date ='||p_effective_date);

/*Bug 2610141 - Portion added to get the latest assignment action id*/
   open get_latest_id(p_assignment_id,p_effective_date);
   fetch get_latest_id into l_assignment_action_id;
   close get_latest_id;

hr_utility.trace('Assgmt Action Id ='||l_assignment_action_id);
l_sgc_rate:=(p_sgc_rate/100);



----------------/* to get the normal hours worked */------------------------


open assign_work_hrs(p_effective_date,p_assignment_id,p_business_group_id,p_registered_employer); --2610141
    fetch assign_work_hrs into l_hrs_worked;
    If assign_work_hrs%notfound then
         l_hrs_worked:=null ;
    End if;
close assign_work_hrs;


-------/* to ensure that the employee is paid super even when hours worked is not defined */--------
/*
  If l_hrs_worked is null then
      l_hrs_worked:= g_min_hrs_worked + 1;
  end if;
*/
-------------/* to ensure that the employee is paid super even when age is not defined */-------

    If p_employee_age is null then
      l_age:= g_age_min + 1;
    else
       l_age:=p_employee_age;
     end if;



-------------- /* to get the SGC Contribution for the month */----------------------
/*Bug 2610141 --- Added this portion to accomodate for the BRA changes */
p_sgc_contribution := pay_balance_pkg.get_value(g_super_guarantee_bal_id_mtd,
                                                l_assignment_action_id,
						p_registered_employer,null,null,null,null);

/*Bug 2610141 --- Added portion for the BRA changes ends here*/



-------------------- /* get minimum superable salary */------------------------------


open bal(p_business_group_id,p_assignment_id,p_effective_date);
loop
       exit when bal%notfound;
       fetch bal into l_bal_id_min_superable_sal;
       open bal_id_mtd(l_bal_id_min_superable_sal,p_legislation_code); /*Bug 2610141 */
       fetch bal_id_mtd into l_bal_id_mtd;
       l_salary := pay_balance_pkg.get_value(l_bal_id_mtd,
                                                l_assignment_action_id,
						p_registered_employer,null,null,null,null); /*Bug 2610141 */
       IF bal%rowcount = 1 then
            l_bal_id := l_bal_id_min_superable_sal;
            l_min_superable_salary := l_salary;
            l_max_superable_salary:=l_salary;
       ELSIF l_salary < l_min_superable_salary THEN
            l_bal_id := l_bal_id_min_superable_sal;
            l_min_superable_salary := l_salary;
       END IF;
       IF l_salary > l_max_superable_salary THEN
            l_max_superable_salary:=l_salary;
       END IF;
       close bal_id_mtd; /*Bug 2610141 */
end loop;
close bal;


p_superable_sal:= l_min_superable_salary;


       hr_utility.trace('balance_id :'||l_bal_id);
       hr_utility.trace('superable_salary :'||l_salary);


-------- /* get warning message if superable salary across funds are different */-----------

IF l_max_superable_salary <> l_min_superable_salary then
           hr_utility.set_message(801,'HR_AU_SGC_WARNING_MESG');
           p_warning_mesg := hr_utility.get_message;
ELSE
           p_warning_mesg := '';
END IF;


-------------/* get QTD employer SGC Contribution */--------------------------------



/*Bug 2610141 --- Added this portion to accomodate for the BRA changes */
OPEN bal_id_qtd(l_bal_id,'AU');
FETCH bal_id_qtd INTO l_super_guarantee_bal_id_qtd;
CLOSE bal_id_qtd;

l_SGC_qtd := pay_balance_pkg.get_value(l_super_guarantee_bal_id_qtd,
                                                l_assignment_action_id,
						p_registered_employer,null,null,null,null);

/*Bug 2610141 --- Added portion for the BRA changes ends here*/


------------------------/* get compliance message */-------------------------

/* Bug# 2197813 p_superable_sal*l_sgc_rate is rounded to 5cents */
/* Also amount when displayed in message is rounded to 5cents */

If pay_au_paye_ff.round_to_5c(p_superable_sal * l_sgc_rate) <= p_sgc_contribution then
    p_compliance_mesg :=null;
ELSIF
   pay_au_paye_ff.round_to_5c( p_superable_sal * l_sgc_rate) > p_sgc_contribution then
    IF p_superable_sal < g_monthly_threshold then

           hr_utility.set_message(801,'HR_AU_SGC_MONTHLY_THRESHOLD');
           hr_utility.set_message_token('MONTHLY',g_monthly_threshold);
           hr_utility.set_message_token('AMOUNT',pay_au_paye_ff.round_to_5c(p_superable_sal * l_sgc_rate));
           p_compliance_mesg := hr_utility.get_message;

    ELSIF l_age >  g_age then

           hr_utility.set_message(801,'HR_AU_SGC_MAX_AGE');
           hr_utility.set_message_token('AGE',g_age);
           p_compliance_mesg := hr_utility.get_message;

    ELSIF  l_age < g_age_min and l_hrs_worked < g_min_hrs_worked then

           hr_utility.set_message(801,'HR_AU_SGC_AGE_HRS_WORKED');
           hr_utility.set_message_token('MINAGE',g_age_min);
           hr_utility.set_message_token('HOURS',g_min_hrs_worked);
           p_compliance_mesg := hr_utility.get_message;


    ELSIF l_SGC_qtd > g_qtd_threshold then

           hr_utility.set_message(801,'HR_AU_SGC_YTD_EMPLOYER_SGC');
           hr_utility.set_message_token('VALUE',g_qtd_threshold * 4);
           hr_utility.set_message_token('AMOUNT',pay_au_paye_ff.round_to_5c(p_superable_sal * l_sgc_rate));
           p_compliance_mesg := hr_utility.get_message;


    ELSE
           hr_utility.set_message(801,'HR_AU_SGC_NON_COMPLIANT');
           hr_utility.set_message_token('AMOUNT',pay_au_paye_ff.round_to_5c(p_superable_sal * l_sgc_rate));
           p_compliance_mesg := hr_utility.get_message;


    END IF;
END IF;


--          hr_utility.trace('Out : employee_super_details');

Exception
  when others then
    hr_utility.set_message(801, 'HR_6153_ALL_PROCEDURE_FAIL') ;
    hr_utility.set_message_token('PROCEDURE', 'pay_au_sgc_pkg.employee_super_details') ;
    hr_utility.set_message_token('STEP','body') ;
    hr_utility.raise_error ;

END employee_super_details;


BEGIN

g_end_date :='4712/12/31 00:00:00'; /*Bug 2610141- Modfication done to removed gscc warnings */

END pay_au_sgc_pkg;

/
