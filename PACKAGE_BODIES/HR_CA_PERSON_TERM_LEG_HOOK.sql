--------------------------------------------------------
--  DDL for Package Body HR_CA_PERSON_TERM_LEG_HOOK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HR_CA_PERSON_TERM_LEG_HOOK" AS
/* $Header: pycaterm.pkb 120.0.12010000.1 2008/11/12 09:23:24 sneelapa noship $ */

/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : hr_ca_person_term_leg_hook
    Package File Name   : pycaterm.pkb

    Description : This package will be called before Process Hook
                  hr_periods_of_service_bk1.update_pds_details_b for CA
                  legislation. It is used to correctly End Date the Tax
                  Records (Federal / Provincial) as per the
                  Final Process Date entered by the user.

    Change List:
    ------------
     Name          Date        Version    Bug     Text
    ------------- ----------- --------- ------- ------------------------------
    sneelapa      24-APR-2008    115.0           Initial version.

*/

procedure update_tax_rules(p_period_of_service_id in number,
                           p_final_process_date in date) is

/* Fetching Old Final Process Date and Person ID From Period of Service */

cursor c_get_person_oldfpd(p_period_of_service_id in number) is
select distinct pds.person_id,
                pds.final_process_date
from per_periods_of_service pds
where pds.period_of_service_id = p_period_of_service_id ;

/* Getting all Terminated Assignments for the Person concerned */

cursor c_get_assignments(p_person_id in number) is
select distinct assignment_id
from    per_assignments_f paf_o,
        per_assignment_status_types past
where  paf_o.person_id = p_person_id
and    paf_o.assignment_status_type_id = past.assignment_status_type_id
and    past.per_system_status = 'TERM_ASSIGN'
and  ((past.business_group_id is null
                and past.legislation_code is null)
                OR (past.business_group_id is null
                    and past.legislation_code = 'CA')
                OR (past.legislation_code is null
                    and exists
                        (select 'x'
                         from  per_assignments_f paf_a
                         where paf_a.assignment_id = paf_o.assignment_id
                         and   paf_a.business_group_id = past.business_group_id)
                    )
               )
and    paf_o.effective_end_date = (select max(paf_i.effective_end_date)
                                                 from per_assignments_f paf_i
                                                 where paf_i.assignment_id = paf_o.assignment_id) ;

-- Fetching Federal Tax Rules details the latest record that needs to be
-- end dated as of New FPD

cursor c_get_fedtax_rules(p_assignment_id in number,
                          p_final_process_date in date) is
select pueo.emp_fed_tax_inf_id,
       pueo.effective_start_date,
       pueo.effective_end_date
from pay_ca_emp_fed_tax_info_f pueo
where pueo.assignment_id = p_assignment_id
and   pueo.effective_start_date = (select max(puei.effective_start_date)
                              from pay_ca_emp_fed_tax_info_f puei
                              where puei.assignment_id = pueo.assignment_id
                              and   puei.effective_start_date <= p_final_process_date) ;


-- Fetching Provincial Tax Rules details for the latest record
-- that needs to be end dated as of New FPD

cursor c_get_provtax_rules(p_assignment_id in number,
                            p_final_process_date in date) is
select pueo.emp_province_tax_inf_id,
       pueo.effective_start_date,
       pueo.effective_end_date
from pay_ca_emp_prov_tax_info_f pueo
where pueo.assignment_id = p_assignment_id
and   pueo.effective_start_date = (select max(puei.effective_start_date)
                              from pay_ca_emp_prov_tax_info_f puei
                              where puei.assignment_id = pueo.assignment_id
                              and   puei.province_code = pueo.province_code
                              and   puei.effective_start_date <= p_final_process_date) ;


-- To check whether Future Dated Payroll Actions existing

CURSOR c_compl_pay_act(p_new_final_process_date in date) IS
SELECT NULL
FROM   pay_payroll_actions ppa
      ,pay_assignment_actions paa
      ,per_assignments_f asg
      ,per_periods_of_service pds
WHERE pds.period_of_service_id = p_period_of_service_id
AND   pds.person_id = asg.person_id
AND   asg.period_of_service_id = pds.period_of_service_id
AND   asg.assignment_id = paa.assignment_id
AND   paa.payroll_action_id = ppa.payroll_action_id
AND   ppa.action_type NOT IN ('X','BEE')
AND   ppa.effective_date > p_new_final_process_date ;


l_person_id	                per_people_f.person_id%type ;
l_old_fpd                   per_periods_of_service.final_process_date%type ;
l_final_process_date        per_periods_of_service.final_process_date%type ;
l_assignment_id             per_assignments_f.assignment_id%type ;
l_emp_fed_tax_inf_id       pay_ca_emp_fed_tax_info_f.emp_fed_tax_inf_id%type ;
l_emp_prov_tax_inf_id        pay_ca_emp_prov_tax_info_f.emp_province_tax_inf_id%type ;
l_eff_st_dt                 date ;
l_eff_end_dt                date ;
l_dummy                     varchar2(1) ;

begin

hr_utility.trace('Entering HR_CA_PERSON_TERM_LEG_HOOK.update_tax_rules');
hr_utility.trace('p_period_of_service_id := '|| p_period_of_service_id) ;
hr_utility.trace('p_final_process_date := '||to_char(p_final_process_date,'dd/mon/yyyy')) ;

-- If FPD is entered NULL we need to end date Tax records as of 31st Dec,4712
If p_final_process_date IS NULL OR p_final_process_date = hr_api.g_date Then
   l_final_process_date := fnd_date.canonical_to_date('4712/12/31 00:00:00') ;
Else
   l_final_process_date := p_final_process_date ;
End If ;
hr_utility.trace('l_final_process_date := '||to_char(l_final_process_date,'dd/mon/yyyy')) ;

open c_get_person_oldfpd(p_period_of_service_id) ;
loop
fetch c_get_person_oldfpd into l_person_id, l_old_fpd ;
exit when c_get_person_oldfpd%NOTFOUND ;

hr_utility.trace('l_person_id := '||l_person_id) ;
hr_utility.trace('l_old_fpd := '||l_old_fpd) ;

If l_old_fpd IS NOT NULL Then
-- If Old FPD is Null proper End-Dating of Tax records will happen
-- by HR_EX_EMPLOYEE_BK2.FINAL_PROCESS_EMP_B so we are not updating Tax Records here

    OPEN c_compl_pay_act(l_final_process_date) ;
    FETCH c_compl_pay_act INTO l_dummy;
    IF c_compl_pay_act%FOUND THEN
       CLOSE c_compl_pay_act;
       hr_utility.set_message(800,'HR_449742_EMP_FPD_PAYACT');
       hr_utility.raise_error;
    ELSE  -- No Future Dated Payroll Action exists after the new Final Process Date

        open c_get_assignments(l_person_id) ;
        loop
        fetch c_get_assignments into l_assignment_id ;
        hr_utility.trace('l_assignment_id := '||l_assignment_id) ;
        exit when c_get_assignments%NOTFOUND ;

          open c_get_fedtax_rules(l_assignment_id, l_final_process_date ) ;
          loop
            fetch c_get_fedtax_rules into l_emp_fed_tax_inf_id, l_eff_st_dt, l_eff_end_dt ;
            exit when c_get_fedtax_rules%NOTFOUND ;
            hr_utility.trace('l_emp_fed_tax_inf_id := '||l_emp_fed_tax_inf_id) ;

            -- Updating Fed Tax Rules
            update pay_ca_emp_fed_tax_info_f
            set effective_end_date = l_final_process_date
            where emp_fed_tax_inf_id = l_emp_fed_tax_inf_id
            and  effective_start_date = l_eff_st_dt
            and  effective_end_date = l_eff_end_dt ;
          end loop ;

          close c_get_fedtax_rules ;

          open  c_get_provtax_rules(l_assignment_id, l_final_process_date) ;
          loop
          fetch c_get_provtax_rules into l_emp_prov_tax_inf_id, l_eff_st_dt, l_eff_end_dt ;
          exit when c_get_provtax_rules%NOTFOUND ;
          hr_utility.trace('l_emp_prov_tax_inf_id := '||l_emp_prov_tax_inf_id) ;

          -- Updating State Tax Rules
          update pay_ca_emp_prov_tax_info_f
          set effective_end_date = l_final_process_date
          where emp_province_tax_inf_id = l_emp_prov_tax_inf_id
          and  effective_start_date = l_eff_st_dt
          and  effective_end_date = l_eff_end_dt ;
          end loop ;
          close c_get_provtax_rules ;

       end loop ;
       close c_get_assignments ;
       END IF; -- Future Dated Payroll Action does not exist
CLOSE c_compl_pay_act ;

END IF ; -- Old FPD is not Null

end loop ;

close c_get_person_oldfpd ;

hr_utility.trace('Leaving HR_CA_PERSON_TERM_LEG_HOOK.update_tax_rules');
end update_tax_rules ;

end HR_CA_PERSON_TERM_LEG_HOOK ;

/
