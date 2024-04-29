--------------------------------------------------------
--  DDL for Package PAY_AU_SGC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AU_SGC_PKG" AUTHID CURRENT_USER as
/* $Header: pyausgc.pkh 120.2 2006/06/05 08:46:21 abhargav ship $ */
/*
**
**  Copyright (C) 1999 Oracle Corporation
**  All Rights Reserved
**
**  Australia Superannuation Contribution Compliance Report
**
**  Change List
**  ===========
**
**  Date        Author   Reference Description
**  -----------+--------+---------+-------------
**  05-DEC-2000 RSINGHAL  N/A           Created
**  10-JAN-2001 RSINGHAL bug# 1574764   Modifications for Performance issue.
**  07-FEB-2001 RSINGHAL bug# 1560081   Changes in the sql for selecting
**                                            working hours.
**  04-FEB-2002 VGSRINIV Bug# 2197813   Added dbdrv command
**  03-DEC-2002 RAGOVIND Bug# 2689226   Added NOCOPY for the function employee_super_details.
**  29-DEC-2003 APUNEKAR Bug# 2920725   Corrected base tables to support security model
**  09-AUG-2004 ABHKUMAR Bug# 2610141   Legal Employer enhancement changes
**  12-AUG-2004 ABHKUMAR Bug# 2610141   Introduce cursor bal_id_qtd to get the defined balance id of _ASG_LE_QTD
**  05-MAY-2006 KSINGLA  Bug# 5143056   Modified check for legislation code in cursors bal_id_mtd and bal_id_qtd
**  05-Jun-2006 abhargav Bug# 5244510   Modified cursor bal and assign_work_hrs so that report would process
                                        terminated employee also which was terminated mid of the month.
*/

-------------------------------------------------------------------------------

g_monthly_threshold    number;
g_age                  number;
g_age_min              number;
g_min_hrs_worked       number;
g_qtd_threshold        number;
g_super_guarantee_bal_id_mtd pay_defined_balances.defined_balance_id%type; --2610141
g_end_date             hr_organization_information.org_information10%type;


---------------------Cursor to select balance id and superable salary ----------------
/*Bug 2610141 modfied to return on the defined balance id*/

cursor bal (c_business_group_id per_all_people_f.business_group_id%type,
            c_assignment_id per_all_assignments_f.assignment_id%type,
            c_effective_date date) is
select  hoi.org_information8
from
        hr_organization_information hoi,
        hr_organization_units hou,
        pay_personal_payment_methods_f pppm
where
        hoi.org_information_context='AU_SUPER_FUND'
        and hoi.organization_id=hou.organization_id
        and pppm.payee_id=hoi.organization_id
        and c_effective_date between pppm.effective_start_date and last_day(pppm.effective_end_date) /* Bug#5244510 */
        and (c_effective_date between to_date(hoi.org_information9,'yyyy/mm/dd hh24:mi:ss') and
                                        nvl(to_date(hoi.org_information10,'yyyy/mm/dd hh24:mi:ss'),
				        to_date(g_end_date,'yyyy/mm/dd hh24:mi:ss')))
        and hou.business_group_id=c_business_group_id
        and pppm.assignment_id=c_assignment_id
        group by hoi.org_information8
        order by 1 ;


/*Bug 2610141 Cursor to get the balance value for a particular defined balance id*/
/* Bug 5143056 Modified check for legislation code from pay_balance_types put nvl*/

cursor bal_id_mtd(c_balance_type_id pay_balance_types.balance_type_id%type,
              c_legislation_code pay_balance_types.legislation_code%type)
                    is
                    select pdb.defined_balance_id
		    FROM   pay_balance_types pbt,
                           pay_balance_dimensions pbd,
                           pay_defined_balances pdb
                    where pbt.balance_type_id=c_balance_type_id
		    AND  nvl(pbt.legislation_code,'AU')=c_legislation_code
                    AND   pbd.database_item_suffix = '_ASG_LE_MTD'
                    AND   pbt.balance_type_id      = pdb.balance_type_id
                    AND   pbd.balance_dimension_id = pdb.balance_dimension_id;


/*Bug 2610141 - Portion added to get the defined balance id for _ASG_LE_QTD*/
/* Bug 5143056 Modified check for legislation code from pay_balance_types put nvl*/
cursor bal_id_qtd(c_balance_type_id pay_balance_types.balance_type_id%type,
              c_legislation_code pay_balance_types.legislation_code%type)
                    is
                    select pdb.defined_balance_id
		    FROM   pay_balance_types pbt,
                           pay_balance_dimensions pbd,
                           pay_defined_balances pdb
                    where pbt.balance_type_id=c_balance_type_id
		     AND  nvl(pbt.legislation_code,'AU')=c_legislation_code
                    AND   pbd.database_item_suffix = '_ASG_LE_QTD'
                    AND   pbt.balance_type_id      = pdb.balance_type_id
                    AND   pbd.balance_dimension_id = pdb.balance_dimension_id;


---------------cursor to select working hours ------------------------
/* obsolete as per bug 1560081
Cursor assign_work_hrs (c_effective_date date,
                        c_assignment_id per_all_assignments_f.assignment_id%type)
                          is
                          select assign.normal_hours from
                          per_assignments_f assign,
                          hr_lookups hr3
                          where c_effective_date between assign.effective_start_date and
                          assign.effective_end_date and
                          assign.assignment_id    = c_assignment_id and
                          hr3.application_id   (+)= 800 and
                          hr3.lookup_code      (+)= assign.frequency and
                          hr3.lookup_type      (+)= 'FREQUENCY';
*/

/*   new one defined to check first at SCL level,
**   then at Assignment level,
**   at BG level,
**   if value is null at all the above three then default it to super_min_hrs +1
*/
/*Bug2920725   Corrected base tables to support security model*/

CURSOR assign_work_hrs
           (c_effective_date date,
            c_assignment_id per_assignments_f.assignment_id%TYPE,
            c_business_group_id per_all_assignments_f.business_group_id%TYPE,
            c_registered_employer NUMBER -- 2610141
           )
       is
       select nvl(nvl(hsck.segment4,nvl(
                        decode(paa.frequency,'W',paa.normal_hours,null),
                        decode(hoi.org_information4,'W',hoi.org_information3,
                        null)
                        )),g_min_hrs_worked + 1)
                     from
                        per_assignments_f paa,
                        hr_soft_coding_keyflex hsck,
                        hr_organization_information hoi,
                        hr_organization_units hou
                     where
                        hoi.org_information_context='Work Day Information' and
                        hoi.organization_id=hou.organization_id and
                        paa.business_group_id=hou.business_group_id and
                        paa.soft_coding_keyflex_id=hsck.soft_coding_keyflex_id
			and hsck.segment1 = c_registered_employer -- 2610141
                        and c_effective_date between paa.effective_start_date and
                                                 last_day(paa.effective_end_date) /* Bug#5244510 */
                        and paa.assignment_id=c_assignment_id
                        and paa.business_group_id=c_business_group_id;

--------------------------procedure global_super_values-----------------------------

procedure global_super_values(
                    p_effective_date in date,
                    p_legislation_code in  pay_balance_types.legislation_code%type
                    );


-------------------------------procedure employee_super_details------------------------

procedure employee_super_details
            (p_assignment_id    in per_all_assignments_f.assignment_id%type,
             p_registered_employer NUMBER, -- 2610141
             p_employee_age     in number,
             p_effective_date   in date,
             p_sgc_rate         in number,
             p_business_group_id in per_all_people_f.business_group_id%type,
	     p_legislation_code in  pay_balance_types.legislation_code%type,--2610141
             p_superable_sal    out NOCOPY number,
             p_sgc_contribution out NOCOPY number,
             p_compliance_mesg  out NOCOPY varchar2,
             p_warning_mesg     out NOCOPY varchar2
            );

----------------------------function compliance_mesg-----------------------------------

function compliance_mesg(
             p_assignment_id    in per_all_assignments_f.assignment_id%type,
             p_employee_age     in number,
             p_effective_date   in date,
             p_sgc_rate         in number,
             p_business_group_id in per_all_people_f.business_group_id%type,
             p_registered_employer NUMBER, -- 2610141
	     p_legislation_code in  pay_balance_types.legislation_code%type--2610141
              )
return varchar2;

END pay_au_sgc_pkg ;

 

/
