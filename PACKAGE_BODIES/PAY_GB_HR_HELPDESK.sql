--------------------------------------------------------
--  DDL for Package Body PAY_GB_HR_HELPDESK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_GB_HR_HELPDESK" AS
/* $Header: pygbhelpdesk.pkb 120.0.12010000.3 2010/02/03 05:38:35 rlingama noship $ */
gv_package_name       VARCHAR2(100);

-- This procedure is used to fetch gb hr helpdesk data.
-- ----------------------------------------------------------------------------
-- |-------------------------< GET_UKPAY_DETAILS >--------------------------|
-- ----------------------------------------------------------------------------
procedure GET_UKPAY_DETAILS (p_per_id number,
                             p_bg_id number,
                             p_eff_date date,
                             p_leg_code varchar2,
                             --p_pyrl_dtls  out nocopy HR_PERSON_PAY_RECORD.PAYROLL_RECORD
          	             p_pyrl_dtls  out nocopy HR_PERSON_RECORD.PAYROLL_RECORD,
                             p_error out nocopy varchar2)
is
-- declaration for uk payroll starts here

cursor csr_ukpay_req (p_person_id number,p_eff_date date) is
/*select to_char(action_context_id) assignment_action_id
       from pay_emp_payslip_action_info_v
where person_id = p_person_id
and effective_date = (select max(effective_date)
                      from pay_emp_payslip_action_info_v
                      where person_id = p_person_id
		      and effective_date <= p_eff_date);*/

SELECT
  DISTINCT
  paa.assignment_action_id
FROM
  pay_payroll_actions ppa,
  pay_assignment_actions paa,
  per_assignments_f paf,
  per_people_f ppf
WHERE ppa.action_type = 'X'
  AND ppa.action_status = 'C'
  AND ppa.report_type = 'UKPS'
  AND ppa.payroll_action_id = paa.payroll_action_id
  AND paa.assignment_id = paf.assignment_id
  AND paf.person_id = ppf.person_id
  AND ppf.person_id = p_person_id
  AND ppa.effective_date = (
SELECT
    max(ppa1.effective_date)
  FROM
    pay_payroll_actions ppa1,
    pay_assignment_actions paa1
  WHERE ppa1.effective_date <= p_eff_date
    AND ppa1.action_type = 'X'
    AND ppa1.action_status = 'C'
    AND ppa1.report_type = 'UKPS'
    AND ppa1.payroll_action_id = paa1.payroll_action_id
    AND paa1.assignment_id = paa.assignment_id
    AND ppa1.business_group_id = ppa.business_group_id )
    and SOURCE_ACTION_ID is null -- add here to avoid child action
  AND ppa.effective_date BETWEEN paf.effective_start_date AND paf.effective_end_date;


 -- cursor modified for the bug 8233506

cursor csr_ukpay_ps_det(p_asg_action_id number) is
select organization_name ,
       location_name ,
       job ,
       payroll_name ,
       to_char(payment_date,'YYYY-MM-DD'),
       pbg.currency_code ,
       to_char(beginning_date,'YYYY-MM-DD') ,
       to_char(ending_date,'YYYY-MM-DD'),
       paa.assignment_id
from pay_employee_action_info_v empv,
     pay_assignment_actions paa,
     per_business_groups pbg,
     per_all_assignments_f paaf
where empv.action_context_id = p_asg_action_id
  and empv.action_context_id = paa.assignment_action_id
  and paa.assignment_id = nvl(empv.assignment_id,paa.assignment_id)
  and paa.assignment_id = paaf.assignment_id
  and payment_date between paaf.effective_start_date and paaf.effective_end_date
  and paaf.business_group_id = pbg.business_group_id;

 -- cursor to fetch the run type
cursor csr_run_type(p_assignment_action_id number) is
select prtf.run_type_name
from   pay_action_interlocks lck,
       pay_assignment_actions paa1,
       pay_action_interlocks pac,
       pay_assignment_actions paa,
       pay_run_types_f prtf
where lck.locked_action_id = paa1.assignment_action_id
  and paa1.assignment_action_id = pac.locking_action_id
  and pac.locked_action_id = paa.assignment_action_id
  and lck.locking_action_id = p_assignment_action_id
  and paa.source_action_id is not null
  and prtf.run_type_id = paa.run_type_id
  and prtf.legislation_code = 'GB';

/*cursor csr_run_type(p_assignment_id number,p_eff_date date) is
select prtf.run_type_name
from pay_payroll_actions ppa,
     pay_assignment_actions paa,
     pay_run_types_f prtf
where paa.assignment_action_id in (SELECT + USE_NL(paa, pact, ptp)
                                          to_number(substr(max(lpad(paa.action_sequence,15,'0')||
                                          paa.assignment_action_id),16)) assignment_action_id
                                  FROM    pay_assignment_actions paa,
                                          pay_payroll_actions    pact
                  WHERE   paa.assignment_id =  p_assignment_id
                                  AND     paa.payroll_action_id = pact.payroll_action_id
                                  AND     pact.action_type IN ('Q','R','B','I','V')
                                  AND     paa.action_status = 'C'
                                  AND     pact.effective_date <= p_eff_date)
and   ppa.payroll_action_id = paa.payroll_action_id
and   prtf.run_type_id = ppa.run_type_id
and   prtf.legislation_code = 'GB';*/

--cursor to fetch the UK earnings current value

cursor csr_uk_earnings_cv(p_assignment_action_id number) is
SELECT /*+ leading(lck,paa2) */
--pai.action_information4 NARRATIVE,
SUM(FND_NUMBER.CANONICAL_TO_NUMBER(prv.result_value)) value
FROM pay_action_interlocks lck, -- archive action locking prepayment
     pay_assignment_actions paa1, -- prepayment action
     pay_assignment_actions paa2, -- archive action
     pay_payroll_actions ppa, -- prepayment
     pay_action_information pai, -- archived element/input value definition
     pay_action_interlocks pac, -- prepayment locking payroll run/quickpay
     pay_assignment_actions paa, -- payroll run/quickpay action
     pay_payroll_actions ppa1, -- payroll run/quickpay action
     pay_element_types_f pet, -- element types processed by the payroll run/quickpay
     pay_input_values_f piv, -- "Pay values" of type Money
     pay_run_results prr, -- run result created by the payroll run/quick pay
     pay_run_result_values prv -- Run Result value (Pay Value) created by the payroll run/quickpay
WHERE lck.locking_action_id = paa2.assignment_action_id
AND paa2.payroll_action_id = pai.action_context_id
AND pai.action_context_type = 'PA'
AND pai.action_information_category = 'EMEA ELEMENT DEFINITION'
AND lck.locked_action_id = paa1.assignment_action_id
AND paa1.source_action_id IS NULL
AND paa1.payroll_action_id = ppa.payroll_action_id
AND ppa.action_type IN ('P','U')
AND ppa.payroll_action_id = NVL (pai.action_information1,ppa.payroll_action_id)
AND paa1.assignment_action_id = pac.locking_action_id
AND pet.element_type_id = pai.action_information2
AND pet.element_type_id = piv.element_type_id
AND piv.input_value_id = pai.action_information3
AND prr.element_type_id = pet.element_type_id
AND prr.status IN ('P','PA')
AND prv.input_value_id = piv.input_value_id
AND prv.run_result_id = prr.run_result_id
AND piv.name = 'Pay Value'
AND piv.uom = 'M'
AND pac.locked_action_id = prr.assignment_action_id
AND pac.locked_action_id = paa.assignment_action_id
AND paa.payroll_action_id = ppa1.payroll_action_id
AND ppa1.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
AND ppa1.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
AND lck.locking_action_id =  p_assignment_action_id
AND   pai.action_information5 in   ( 'E','P')
GROUP BY lck.locking_action_id;

-- cursor to fetch the tax and national insurance current value
cursor csr_uk_tx_cv(p_assignment_action_id number) is
SELECT /*+ leading(lck,paa2) */
SUM(FND_NUMBER.CANONICAL_TO_NUMBER(prv.result_value)) value
FROM pay_action_interlocks lck, -- archive action locking prepayment
     pay_assignment_actions paa1, -- prepayment action
     pay_assignment_actions paa2, -- archive action
     pay_payroll_actions ppa, -- prepayment
     pay_action_information pai, -- archived element/input value definition
     pay_action_interlocks pac, -- prepayment locking payroll run/quickpay
     pay_assignment_actions paa, -- payroll run/quickpay action
     pay_payroll_actions ppa1, -- payroll run/quickpay action
     pay_element_types_f pet, -- element types processed by the payroll run/quickpay
     pay_input_values_f piv, -- "Pay values" of type Money
     pay_run_results prr, -- run result created by the payroll run/quick pay
     pay_run_result_values prv -- Run Result value (Pay Value) created by the payroll run/quickpay
WHERE lck.locking_action_id = paa2.assignment_action_id
AND paa2.payroll_action_id = pai.action_context_id
AND pai.action_context_type = 'PA'
AND pai.action_information_category = 'EMEA ELEMENT DEFINITION'
AND lck.locked_action_id = paa1.assignment_action_id
AND paa1.source_action_id IS NULL
AND paa1.payroll_action_id = ppa.payroll_action_id
AND ppa.action_type IN ('P','U')
AND ppa.payroll_action_id = NVL (pai.action_information1,ppa.payroll_action_id)
AND paa1.assignment_action_id = pac.locking_action_id
AND pet.element_type_id = pai.action_information2
AND pet.element_type_id = piv.element_type_id
AND piv.input_value_id = pai.action_information3
AND prr.element_type_id = pet.element_type_id
AND prr.status IN ('P','PA')
AND prv.input_value_id = piv.input_value_id
AND prv.run_result_id = prr.run_result_id
AND piv.name = 'Pay Value'
AND piv.uom = 'M'
AND pac.locked_action_id = prr.assignment_action_id
AND pac.locked_action_id = paa.assignment_action_id
AND paa.payroll_action_id = ppa1.payroll_action_id
AND ppa1.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
AND ppa1.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
AND lck.locking_action_id = p_assignment_action_id
AND pai.action_information5 in ('D', NULL)
AND pai.action_information4 = ('PAYE')
GROUP BY lck.locking_action_id, pet.element_type_id, piv.input_value_id, pai.action_information4, pai.action_information5;

-- cursor to fetch the tax and national insurance current value
cursor csr_uk_ni_cv(p_assignment_action_id number) is
SELECT /*+ leading(lck,paa2) */
SUM(FND_NUMBER.CANONICAL_TO_NUMBER(prv.result_value)) value
FROM pay_action_interlocks lck, -- archive action locking prepayment
     pay_assignment_actions paa1, -- prepayment action
     pay_assignment_actions paa2, -- archive action
     pay_payroll_actions ppa, -- prepayment
     pay_action_information pai, -- archived element/input value definition
     pay_action_interlocks pac, -- prepayment locking payroll run/quickpay
     pay_assignment_actions paa, -- payroll run/quickpay action
     pay_payroll_actions ppa1, -- payroll run/quickpay action
     pay_element_types_f pet, -- element types processed by the payroll run/quickpay
     pay_input_values_f piv, -- "Pay values" of type Money
     pay_run_results prr, -- run result created by the payroll run/quick pay
     pay_run_result_values prv -- Run Result value (Pay Value) created by the payroll run/quickpay
WHERE lck.locking_action_id = paa2.assignment_action_id
AND paa2.payroll_action_id = pai.action_context_id
AND pai.action_context_type = 'PA'
AND pai.action_information_category = 'EMEA ELEMENT DEFINITION'
AND lck.locked_action_id = paa1.assignment_action_id
AND paa1.source_action_id IS NULL
AND paa1.payroll_action_id = ppa.payroll_action_id
AND ppa.action_type IN ('P','U')
AND ppa.payroll_action_id = NVL (pai.action_information1,ppa.payroll_action_id)
AND paa1.assignment_action_id = pac.locking_action_id
AND pet.element_type_id = pai.action_information2
AND pet.element_type_id = piv.element_type_id
AND piv.input_value_id = pai.action_information3
AND prr.element_type_id = pet.element_type_id
AND prr.status IN ('P','PA')
AND prv.input_value_id = piv.input_value_id
AND prv.run_result_id = prr.run_result_id
AND piv.name = 'Pay Value'
AND piv.uom = 'M'
AND pac.locked_action_id = prr.assignment_action_id
AND pac.locked_action_id = paa.assignment_action_id
AND paa.payroll_action_id = ppa1.payroll_action_id
AND ppa1.effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
AND ppa1.effective_date BETWEEN piv.effective_start_date AND piv.effective_end_date
AND lck.locking_action_id = p_assignment_action_id
AND pai.action_information5 in ('D', NULL)
AND pai.action_information4 like 'NI%'
GROUP BY lck.locking_action_id, pet.element_type_id, piv.input_value_id, pai.action_information4, pai.action_information5;


-- cursor to fetch the current net pay value for UK
cursor csr_net_pay_cv (p_asg_action_id number) is
select ACTION_INFORMATION16
from pay_action_information pai
where pai.action_context_id = p_asg_action_id
and pai.action_information_category = 'EMPLOYEE NET PAY DISTRIBUTION'
and pai.action_context_type = 'AAP';

-- cursor to fetch the tax and earnings YTD
cursor csr_tx_er_ytd(p_assignment_action_id number,p_bal_name varchar2) is
select  pai.ACTION_INFORMATION4
from pay_action_information pai,
     pay_defined_balances pdb,
     pay_balance_types pbt
where pai.action_context_id =   p_assignment_action_id -- 182069
and to_char(pdb.DEFINED_BALANCE_ID) = (pai.ACTION_INFORMATION1)
and pdb.BALANCE_TYPE_ID = pbt.BALANCE_TYPE_ID
and pai.action_information_category = 'EMEA BALANCES'
and pai.action_context_type = 'AAP'
and balance_name = p_bal_name
and pbt.legislation_code = 'GB'
and pdb.legislation_code = 'GB';

-- cursor to get the defined balance id
cursor csr_def_bal_id(p_assignment_action_id number) is
select defined_balance_id
from  pay_defined_balances pdb,
      pay_balance_types    pbt,
      pay_balance_dimensions pbd
where pbt.balance_name = 'NI '||(select ACTION_INFORMATION23
                                 from  pay_action_information pai
                                 where pai.action_context_id =  p_assignment_action_id --182069
                                   and pai.action_information_category = 'GB EMPLOYEE DETAILS'
                                   and pai.action_context_type = 'AAP')
                              ||' Employee'
and   pbd.dimension_name = '_ASG_TD_YTD'
and   pdb.balance_type_id = pbt.balance_type_id
and   pdb.balance_dimension_id = pbd.balance_dimension_id
and   pbd.legislation_code='GB'
and   pbt.legislation_code='GB';

-- cursor to get the latest_action_id
cursor csr_lat_action_id(p_assignment_id number,p_payment_date date)is

SELECT /*+ USE_NL(paa, pact, ptp) */
       to_number(substr(max(lpad(paa.action_sequence,15,'0')||
       paa.assignment_action_id),16)) assignment_action_id
FROM   pay_assignment_actions paa,
       pay_payroll_actions    pact
WHERE   paa.assignment_id =  p_assignment_id --16986
AND     paa.payroll_action_id = pact.payroll_action_id
AND     pact.action_type IN ('Q','R','B','I','V')
AND     paa.action_status = 'C'
AND     pact.effective_date <= p_payment_date;

-- cursor to fetch the netpay balance id
cursor csr_netpay_bal_id is
select defined_balance_id
from  pay_defined_balances pdb,
      pay_balance_types    pbt,
      pay_balance_dimensions pbd
where pbt.balance_name = 'Net Pay'
and   pbd.dimension_name = '_ASG_TD_YTD'
and   pdb.balance_type_id = pbt.balance_type_id
and   pdb.balance_dimension_id = pbd.balance_dimension_id
and   pbd.legislation_code='GB'
and   pbt.legislation_code='GB';

cursor csr_periods_of_service(p_person_id number, p_employee_number number, p_effective_end_date varchar2) is
                select to_char(pps.adjusted_svc_date,'YYYY-MM-DD') adjusted_svc_date
                      ,to_char(pps.date_start,'YYYY-MM-DD') date_start
                      ,to_char(pps.accepted_termination_date,'YYYY-MM-DD') accepted_termination_date
                      ,to_char(pps.actual_termination_date,'YYYY-MM-DD') actual_termination_date
                      ,to_char(pps.final_process_date,'YYYY-MM-DD') final_process_date
                      ,to_char(pps.last_standard_process_date,'YYYY-MM-DD') last_standard_process_date
                      ,leaving_reason
                 from per_periods_of_service pps
                where pps.person_id = p_person_id
                  and ( ( p_employee_number is null )
                        or ( p_employee_number is not null
                             and pps.date_start = (
                                        select max(pps1.date_start)
                                          from per_periods_of_service pps1
                                         where pps1.person_id = p_person_id
                                           and pps1.date_start <= to_date(p_effective_end_date,'YYYY-MM-DD') ) ) );
cursor csr_periods_of_placement(p_person_id number, p_employee_number number, p_effective_end_date varchar2) is
                select null adjusted_svc_date
                      ,to_char(ppp.date_start,'YYYY-MM-DD') date_start
                      ,null accepted_termination_date
                      ,to_char(ppp.actual_termination_date,'YYYY-MM-DD') actual_termination_date
                      ,to_char(ppp.final_process_date,'YYYY-MM-DD') final_process_date
                      ,to_char(ppp.last_standard_process_date,'YYYY-MM-DD') last_standard_process_date
                      ,termination_reason leaving_reason
                 from per_periods_of_placement ppp
                where ppp.person_id = p_person_id
                  and (ppp.date_start = (
                                        select max(ppp1.date_start)
                                          from per_periods_of_placement ppp1
                                         where ppp1.person_id = p_person_id
                                           and ppp1.date_start <= to_date(p_effective_end_date,'YYYY-MM-DD') ) );



p_latest_action_id number;
p_netpay_bal_id number;
p_def_bal_id number;
p_assignment_id       per_all_assignments_f.assignment_id%type;
p_assg_action_id      pay_assignment_actions.assignment_action_id%type;
p_pyrl_action_id      pay_payroll_actions.payroll_action_id%type;

p_cnt number;
-- Declaration for uk payroll ends here


begin
                        p_cnt := 1;

                        open csr_ukpay_req(p_per_id,p_eff_date);
                        loop

                        fetch csr_ukpay_req into p_assg_action_id;
                        exit when csr_ukpay_req%notfound;

                        -- to fetch the details in the pay summary region
                        open csr_ukpay_ps_det(p_assg_action_id);
                        fetch csr_ukpay_ps_det into p_pyrl_dtls(p_cnt).company,
                                                    p_pyrl_dtls(p_cnt).address,
                                                    p_pyrl_dtls(p_cnt).job_title,
                                                    p_pyrl_dtls(p_cnt).pay_group,
                                                    p_pyrl_dtls(p_cnt).payment_date,
                                                    p_pyrl_dtls(p_cnt).currency_code,
                                                    p_pyrl_dtls(p_cnt).period_begin,
                                                    p_pyrl_dtls(p_cnt).period_end,
                                                    p_assignment_id;
			exit when csr_ukpay_ps_det%notfound;
                        close csr_ukpay_ps_det;

			p_pyrl_dtls(p_cnt).LEGISLATION_CODE := p_leg_code;

                        -- fetch the run type for the pay summary region
                        open csr_run_type(p_assg_action_id);
                        fetch csr_run_type into p_pyrl_dtls(p_cnt).RUN_TYPE;
                        close csr_run_type;

                        --fetch the earnings current value
                        open csr_uk_earnings_cv(p_assg_action_id);
                        fetch csr_uk_earnings_cv into p_pyrl_dtls(p_cnt).TOTAL_EARNINGS_CV;
                        close csr_uk_earnings_cv;

                        -- fetch the tax and national insurance current value

                        open csr_uk_ni_cv(p_assg_action_id);
                        fetch csr_uk_ni_cv into p_pyrl_dtls(p_cnt).NI_CV;
                        close csr_uk_ni_cv;

                        open csr_uk_tx_cv(p_assg_action_id);
                        fetch csr_uk_tx_cv into p_pyrl_dtls(p_cnt).TOTAL_TAXES_CV;
                        close csr_uk_tx_cv;

                        -- fetch the net pay current value

                        open csr_net_pay_cv(p_assg_action_id);
                        fetch csr_net_pay_cv into p_pyrl_dtls(p_cnt).TOTAL_NETPAY_CV;
                        close csr_net_pay_cv;

                       -- fetch the earnings YTD
                        open csr_tx_er_ytd(p_assg_action_id, 'Gross Pay');
                        fetch  csr_tx_er_ytd into p_pyrl_dtls(p_cnt).TOTAL_EARNINGS_YTD;
                        close csr_tx_er_ytd;

                        -- fetch the tax YTD
                        open csr_tx_er_ytd(p_assg_action_id, 'PAYE');
                        fetch  csr_tx_er_ytd into p_pyrl_dtls(p_cnt).TOTAL_TAXES_YTD;
                        close csr_tx_er_ytd;

                        open csr_def_bal_id(p_assg_action_id);
                        fetch csr_def_bal_id into p_def_bal_id;
                        close csr_def_bal_id;

                        open csr_netpay_bal_id;
                        fetch csr_netpay_bal_id into p_netpay_bal_id;
                        close csr_netpay_bal_id;

                        open csr_lat_action_id(p_assignment_id,to_date(p_pyrl_dtls(p_cnt).payment_date,
								'YYYY-MM-DD'));
                        fetch csr_lat_action_id into p_latest_action_id;
                        close csr_lat_action_id;

                       -- fetch the net pay YTD value
                        if (p_netpay_bal_id is not null) and (p_latest_action_id is not null)
                        then
                        select pay_balance_pkg.get_value(p_netpay_bal_id,p_latest_action_id)
                        into p_pyrl_dtls(p_cnt).TOTAL_NETPAY_YTD
                        from dual ;
                        end if;

                         -- fetch the NI YTD
                        if(p_def_bal_id is not null) and (p_latest_action_id is not null)
                        then
                        select pay_balance_pkg.get_value(p_def_bal_id,p_latest_action_id)
                        into  p_pyrl_dtls(p_cnt).NI_YTD
                        from dual;
                        end if;

                        p_cnt := p_cnt+1;

                        end loop;

                        close csr_ukpay_req;

exception when others
then
p_error := 'FROM UK PAYROLL :'||substr(SQLERRM,1,1500);

end GET_UKPAY_DETAILS;
BEGIN
 gv_package_name := 'PAY_GB_HR_HELPDESK';
END PAY_GB_HR_HELPDESK;

/
