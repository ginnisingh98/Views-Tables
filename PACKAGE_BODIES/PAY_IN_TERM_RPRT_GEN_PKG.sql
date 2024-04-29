--------------------------------------------------------
--  DDL for Package Body PAY_IN_TERM_RPRT_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_TERM_RPRT_GEN_PKG" as
/* $Header: pyintrpt.pkb 120.17.12010000.14 2010/02/09 09:30:56 mdubasi ship $ */

p_xml_data   CLOB;
g_package    CONSTANT VARCHAR2(100) := 'pay_in_term_rprt_gen_pkg.';
g_debug      BOOLEAN ;
--------------------------------------------------------------------------
--                                                                      --
-- Name           : multiColumnar                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create xml for multiple columns        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_type        VARCHAR2                              --
--                  p_data        tXMLTable                             --
--                  p_count       NUMBER                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04/11/04   abhjain  Created this function                      --
--------------------------------------------------------------------------

procedure multiColumnar(p_type  IN VARCHAR2
                       ,p_data  IN tXMLTable
                       ,p_count IN NUMBER)
IS
   l_tag         VARCHAR2(300);
   l_procedure   VARCHAR2(250);
   l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'multiColumnar';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_type',p_type);
        pay_in_utils.trace('p_count',p_count);
   END IF;

--
   l_tag := '<'||p_type||'>';
   dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);

   FOR i in 1..p_count
   LOOP
    --
      IF p_data.exists(i) THEN
      --
        l_tag := getTag(p_data(i).Name, p_data(i).Value);
        dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
      --
      END IF;
    --
   END LOOP;
   --
   l_tag := '</'||p_type||'>';
   dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
--
END multiColumnar;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : twoColumnar                                         --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create xml for two columns             --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_type        VARCHAR2                              --
--                  p_data        tXMLTable                             --
--                  p_count       NUMBER                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04/11/04   abhjain  Created this function                      --
--------------------------------------------------------------------------
procedure twoColumnar(p_type  IN VARCHAR2
                     ,p_data  IN tXMLTable
                     ,p_count IN NUMBER)
IS
   l_tag VARCHAR2(300);
   l_procedure   VARCHAR2(250);
   l_message     VARCHAR2(250);
BEGIN
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'twoColumnar';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
   IF (g_debug)
   THEN
        pay_in_utils.trace('**************************************************','********************');
        pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
        pay_in_utils.trace('p_type',p_type);
        pay_in_utils.trace('p_count',p_count);
   END IF;
--
   FOR i in 1..p_count
   LOOP
    --
      IF p_data.exists(i) THEN
      --
        -- Start Main tag
        l_tag := '<'||p_type||'>';
        dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
--
        -- Put Description tag
        l_tag := getTag('c_description', p_data(i).Name);
        dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
--
        -- Put amount tag
        l_tag := getTag('c_amount', p_data(i).Value);
        dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
--
        -- End Main tag
        l_tag := '</'||p_type||'>';
        dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
      --
      END IF;
    --
   END LOOP;
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
   --
end twoColumnar;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : getTag                                              --
-- Type           : FUNCTION                                            --
-- Access         : Public                                              --
-- Description    : Procedure to create tags                            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_type        VARCHAR2                              --
--                  p_data        tXMLTable                             --
--                  p_count       NUMBER                                --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04/11/04   abhjain  Created this function                      --
-- 1.1   22/12/04   aaagarwa Encoded HTML literals                      --
--------------------------------------------------------------------------
FUNCTION getTag(p_tag_name  IN VARCHAR2
               ,p_tag_value IN VARCHAR2)
RETURN VARCHAR2
IS
 l_tag_value VARCHAR2(255);
 l_procedure VARCHAR2(250);
 l_message   VARCHAR2(250);
BEGIN
--
   g_debug     := hr_utility.debug_enabled;
   l_procedure := g_package ||'getTag';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   l_tag_value:=nvl(pay_in_utils.encode_html_string(p_tag_value),' ');
  --Return Tag
   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  return '<'||p_tag_name||'>'||l_tag_value||'</'||p_tag_name||'>';
--
END getTag;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_TEMPLATE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure gets the final settlement template   --
  --                  code set at organization level.If no template is    --
  --                  set default template code is returned               --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_group_id    NUMBER                       --
  --            OUT : p_template             VARCHAR2                     --
  --------------------------------------------------------------------------
  --

  PROCEDURE get_template (
                          p_business_group_id    IN NUMBER
                         ,p_template             OUT NOCOPY VARCHAR2
                         )
  IS
  --
    CURSOR csr_final_settlement_info
    IS
    --
      SELECT NVL(org_information7,'PER_IN_TERM_TEMPLATE') template
      FROM   hr_organization_information_v
      WHERE organization_id        = p_business_group_id
      AND   org_information_context= 'PER_IN_STAT_SETUP_DF';
    --
    l_template   VARCHAR2(50);
    l_procedure   VARCHAR(100);
    l_message     VARCHAR2(250);

  --
  BEGIN
  --
    l_procedure := g_package || 'get_template';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_debug THEN
      pay_in_utils.trace('**************************************************','********************');
      pay_in_utils.trace('p_business_group_id',p_business_group_id);
      pay_in_utils.trace('**************************************************','********************');
    END IF;



    OPEN csr_final_settlement_info;
    FETCH csr_final_settlement_info
      INTO l_template;

	-- If Organization level payslip information does not exists return default
	-- Else return the information set
    IF (csr_final_settlement_info%NOTFOUND) THEN
    --
      p_template   := 'PER_IN_TERM_TEMPLATE';
    --
    ELSE
    --
    pay_in_utils.trace('l_template ',l_template);
    pay_in_utils.set_location(g_debug,l_procedure,20);

      p_template   := l_template;
    --
    END IF;
  --
   IF g_debug THEN
   pay_in_utils.trace('**************************************************','********************');
   pay_in_utils.trace('p_template',p_template);
   pay_in_utils.trace('**************************************************','********************');
   END IF;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);

    EXCEPTION
      WHEN OTHERS THEN
        l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
        pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
        pay_in_utils.trace(l_message,l_procedure);

      IF csr_final_settlement_info%ISOPEN THEN
        CLOSE csr_final_settlement_info;
      END IF;
    RAISE;
    --
  --
  END get_template;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : create_xml                                          --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : Procedure to create tags                            --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_employee_number   VARCHAR2                        --
--                  p_bus_grp_id        NUMBER                          --
--            OUT : l_xml_data          CLOB                            --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date       Userid    Description                               --
--------------------------------------------------------------------------
-- 1.0   04/11/04   abhjain  Created this function                      --
-- 1.1   16/11/04   abhjain  Updated after the internal review          --
-- 1.2   06/12/07   sivanara Include code for "Advances" and             --
--                            "Fringe Benefits"                         --
--------------------------------------------------------------------------
PROCEDURE create_xml(p_employee_number IN         VARCHAR2
                    ,p_bus_grp_id      IN         NUMBER
		    ,p_term_date       IN         VARCHAR2
                    ,l_xml_data        OUT NOCOPY CLOB)
IS
--
--Declarion section
--
   l_tag                       VARCHAR2(300);
   l_count                     NUMBER;
   l_total_earnings            NUMBER;
   l_total_deductions          NUMBER;
   l_total_employer_charges    NUMBER;
   l_total_perquisites         NUMBER;
   l_total_other_deductions    NUMBER;
   l_total_loan_recovery       NUMBER;
   l_total_paid                NUMBER;
   l_total_taxable             NUMBER;
   l_total_exempted            NUMBER;
   l_gross_earnings            NUMBER;
   l_leave_encashed_flag       NUMBER;
   l_gratuity_paid_flag        NUMBER;
   l_emp_dues_flag             NUMBER;
   l_net_pay                   NUMBER;
   l_payment_flag              NUMBER;
   l_grat_elig_sal             NUMBER;
   l_exempted                  NUMBER;
   l_paid                      NUMBER;
   l_taxable                   NUMBER;
   l_total_fringe_benefit      NUMBER;
   l_total_advance             NUMBER;
   l_term_date                 DATE ;

--
-- Cursor to get the Employee Personal Detials
CURSOR c_employee_details (p_employee_number VARCHAR2
                          ,p_bus_grp_id      NUMBER
			  ,p_term_date       DATE )
IS
SELECT ppf.full_name                                                 name
      ,ppf.employee_number                                           employee_number
      ,to_char(ppf.date_of_birth,'dd-Mon-yyyy')                      dob
      ,to_char(ppos.date_start,'dd-Mon-yyyy')                         doj
      ,round((months_between(ppos.actual_termination_date
                           , ppf.date_of_birth))/12)                 age
      ,hr_general.decode_lookup('LEAV_REAS'
                                ,ppos.leaving_reason)                leaving_reason
      ,to_char(ppos.actual_termination_date,'dd-Mon-yyyy')           dol
      ,trunc(months_between(ppos.actual_termination_date
                          , ppos.date_start)/12) || ' Years and '
       || (1 + ppos.actual_termination_date - add_months(ppos.date_start
                                                    ,12*trunc(months_between
       (ppos.actual_termination_date, ppos.date_start)/12))) ||' Days' los
      ,hou.name department
      ,org.name ORGANIZATION
      ,loc.location_code location
  FROM per_people_f           ppf
      ,per_assignments_f      paf
      ,per_periods_of_service ppos
      ,hr_soft_coding_keyflex hsck
      ,hr_organization_units  hou
      ,hr_organization_units  org
      ,hr_locations           loc
 WHERE ppf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.location_id = loc.location_id(+)
   AND ppos.period_of_service_id = paf.period_of_service_id
   AND ppos.business_group_id = ppf.business_group_id
   AND ppf.person_id = ppos.person_id
   AND hsck.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
   AND hou.organization_id = hsck.segment1
   AND org.organization_id = paf.organization_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date = p_term_date;
--
-- Cursor to get the Employee Designation
CURSOR c_employee_designation (p_employee_number VARCHAR2
                              ,p_bus_grp_id      NUMBER
			      ,p_term_date       DATE )
IS
SELECT nvl(pp.name,pj.name)   designation
  FROM per_positions          pp
      ,per_jobs               pj
      ,per_people_f           ppf
      ,per_assignments_f      paf
      ,per_periods_of_service ppos
 WHERE ppf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND ppos.period_of_service_id = paf.period_of_service_id
   AND ppos.business_group_id = ppf.business_group_id
   AND ppf.person_id = ppos.person_id
   AND pp.position_id(+) = paf.position_id
   AND pj.job_id(+) = paf.job_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date = p_term_date
   AND paf.effective_end_date between date_effective(+) AND nvl(date_end(+), to_date('31-12-4712', 'DD-MM-YYYY'))
   AND paf.effective_end_date between pj.date_from(+) AND NVL(pj.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'));


--
-- Cursor to get the Run results for the following Element Classifications
--     1. Earnings, Allowances
--     2. Deductions, Involuntary Deductions, Involuntary Deductions, Pre Tax Deductions, Tax Deductions
--     3. Employer Charges
--     4. Perquisites
--     5. Termination Payments (except the element 'Loan Recovery' which is handled
--                              in a separate cursor)
--
CURSOR c_run_results(p_employee_number VARCHAR2
                    ,p_bus_grp_id      NUMBER
                    ,p_max_asg_id      NUMBER)
IS
SELECT nvl(pet.reporting_name, pet.element_name)            description
      ,sum(prrv.result_value)                               amount
      ,pec.classification_name                              classification
      ,pet.element_name                                     elename
  FROM per_assignments_f             paf
      ,per_people_f                  ppf
      ,pay_element_types_f           pet
      ,pay_input_values_f            piv
      ,pay_assignment_actions        paa
      ,pay_run_results               prr
      ,pay_run_result_values         prrv
      ,per_periods_of_service        ppos
      ,pay_element_classifications   pec
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND paf.assignment_id = paa.assignment_id /*Added as per 7283019 */
   AND pec.classification_name IN ('Earnings',
                                   'Allowances',
                                   'Deductions',
                                   'Employer Charges',
                                   'Perquisites',
                                   'Termination Payments',
                                   'Involuntary Deductions',
                                   'Voluntary Deductions',
                                   'Pre Tax Deductions',
                                   'Tax Deductions',
				   'Advances',          --Added for bug fix 6660147
				   'Fringe Benefits')   --Added for bug fix 6660147
   AND (pet.business_group_id = paf.business_group_id or pet.legislation_code = 'IN')
   AND pec.classification_id = pet.classification_id
   AND pec.legislation_code = 'IN'
   AND piv.element_type_id = pet.element_type_id
   AND piv.name = 'Pay Value'
   AND paa.source_action_id = p_max_asg_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND prr.element_type_id = pet.element_type_id
   AND pet.element_name <> 'Loan Recovery'
   AND prr.status IN ('P', 'PA')
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
 --AND fnd_number.canonical_to_number(prrv.result_value) <> 0)
   AND prrv.result_value <> '0'
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   GROUP BY nvl(pet.reporting_name, pet.element_name)
           ,pec.classification_name, pet.element_name
   ORDER BY nvl(pet.reporting_name, pet.element_name);

--Bug 4774108 addition for SQL ID 14928511 starts
-- This cursor returns the maximum run assignment action id for an employee number.
CURSOR c_max_asg_act_id(p_employee_number VARCHAR2
                       ,p_bus_grp_id      NUMBER
		       ,p_term_date       DATE )
IS
SELECT max(paa.assignment_action_id)
  FROM pay_assignment_actions        paa
      ,pay_payroll_actions           ppa
      ,per_people_f                  ppf
      ,per_assignments_f             paf
      ,per_periods_of_service        ppos
 WHERE ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND paf.business_group_id = ppf.business_group_id
   AND ppf.business_group_id = ppa.business_group_id
   AND ppa.business_group_id = p_bus_grp_id
   AND paa.assignment_id = paf.assignment_id
   AND ppa.payroll_id = paf.payroll_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND paa.action_status = 'C'
   AND paa.source_action_id IS  NULL
   AND ppa.action_type in ('R','Q')
   AND ppa.action_status = 'C'
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date = p_term_date;


--Bug 6772976 final Settlement report.
--This Cursor returns Final Settlement Report Information at Bussiness Group Level.
 CURSOR c_final_report_info(p_bus_grp_id      NUMBER)
 IS
 SELECT org_information6
   FROM hr_organization_information
  WHERE organization_id = p_bus_grp_id
    AND org_information_context = 'PER_IN_STAT_SETUP_DF';

--This Cursor returns the Last Standard Process Date for an employee number.

 CURSOR c_last_std_process_date(p_employee_number VARCHAR2
                               ,p_bus_grp_id      NUMBER
			       ,p_term_date       DATE )
  IS
 SELECT max(last_day(pos.last_standard_process_date))
   FROM per_periods_of_service pos
       ,per_people_f ppf
  WHERE ppf.employee_number = p_employee_number
    AND ppf.person_id = pos.person_id
    AND ppf.business_group_id = p_bus_grp_id
    AND pos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
    AND pos.actual_termination_date = p_term_date;

--This cursor returns the maximum run assignment action id for an employee number depending on
--Last Standard Process Date.
 CURSOR c_lsp_max_asg_act_id(p_employee_number VARCHAR2
                                ,p_bus_grp_id      NUMBER
				,p_term_date       DATE
                                ,p_process_date   DATE)
IS
SELECT max(paa.assignment_action_id)
  FROM pay_assignment_actions        paa
      ,pay_payroll_actions           ppa
      ,per_people_f                  ppf
      ,per_assignments_f             paf
      ,per_periods_of_service        ppos
 WHERE ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND paf.business_group_id = ppf.business_group_id
   AND ppf.business_group_id = ppa.business_group_id
   AND ppa.business_group_id = p_bus_grp_id
   AND paa.assignment_id = paf.assignment_id
   AND ppa.payroll_id = paf.payroll_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND paa.action_status = 'C'
   AND paa.source_action_id IS  NULL
   AND ppa.action_type in ('R','Q')
   AND ppa.action_status = 'C'
   AND last_day(ppa.date_earned)  = p_process_date
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date = p_term_date;

--This Cursor returns the maximum run assignment action id for an employee number
--for payment details .

CURSOR c_payment_max_asg_act_id(p_employee_number VARCHAR2
                                ,p_bus_grp_id      NUMBER
				,p_term_date       DATE )
 IS
 SELECT max(paa.assignment_action_id)
  FROM pay_assignment_actions        paa
      ,pay_payroll_actions           ppa
      ,per_people_f                  ppf
      ,per_assignments_f             paf
      ,per_periods_of_service        ppos
 WHERE ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND paf.business_group_id = ppf.business_group_id
   AND ppf.business_group_id = ppa.business_group_id
   AND ppa.business_group_id = p_bus_grp_id
   AND paa.assignment_id = paf.assignment_id
   AND ppa.payroll_id = paf.payroll_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND paa.action_status = 'C'
   AND paa.source_action_id IS NOT NULL
   AND ppa.action_type in ('R','Q')
   AND ppa.action_status = 'C'
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date = p_term_date;


--This Cursor returns the maximum run assignment action id for an employee number
--for payment details depending on last standard process date.

 CURSOR c_lsp_payment_max_asg_act_id(p_employee_number VARCHAR2
                                ,p_bus_grp_id      NUMBER
				,p_term_date       DATE
                                ,p_process_date   DATE)
 IS
 SELECT max(paa.assignment_action_id)
  FROM pay_assignment_actions paa
      ,pay_payroll_actions ppa
      ,per_people_f ppf
      ,per_assignments_f paf
      ,per_periods_of_service        ppos
 WHERE ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND paf.business_group_id = ppf.business_group_id
   AND ppf.business_group_id = ppa.business_group_id
   AND ppa.business_group_id = p_bus_grp_id
   AND paa.assignment_id = paf.assignment_id
   AND ppa.payroll_id = paf.payroll_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND paa.action_status = 'C'
   AND paa.source_action_id IS NOT NULL
   AND ppa.action_type in ('R','Q')
   AND ppa.action_status = 'C'
   AND last_day(ppa.date_earned)  = p_process_date
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date = p_term_date;



--
-- Reduced the following cursor's cost from 27648 to 36.
--Cursor to get the Run results for the Element 'Loan Recovery'
CURSOR c_loan_recovery(p_employee_number VARCHAR2
                      ,p_bus_grp_id      NUMBER
                      ,p_asg_action_id   NUMBER)
IS
SELECT piv.name                             description
      ,INITCAP(peev.screen_entry_value)     loan_type
      ,prrv.result_value                    amount
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_element_types_f         pet
      ,pay_input_values_f          piv
      ,pay_element_entries_f       pee
      ,pay_element_entry_values_f  peev
      ,pay_element_classifications pec
      ,pay_element_links_f         pel
      ,pay_assignment_actions      paa
      ,pay_payroll_actions         ppa
      ,pay_run_results             prr
      ,pay_run_result_values       prrv
      ,per_periods_of_service      ppos
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND pec.classification_name = 'Termination Payments'
   AND pec.legislation_code = 'IN'
   AND pec.classification_id = pet.classification_id
   AND pee.assignment_id = paf.assignment_id
   AND pee.element_type_id = pet.element_type_id
   AND pet.element_name = 'Loan Recovery'
   AND pel.element_link_id = pee.element_link_id
   AND pel.business_group_id = paf.business_group_id
   AND (pel.payroll_id = paf.payroll_id OR pel.link_to_all_payrolls_flag IS NOT NULL)
   AND piv.element_type_id = pet.element_type_id
   AND ((piv.name = 'Pay Value' ) --AND fnd_number.canonical_to_number(prrv.result_value) < 0)
        OR piv.name = 'Loan Type')
   AND paa.source_action_id = p_asg_action_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND ppa.payroll_action_id = paa.payroll_action_id
   AND prr.element_entry_id = pee.element_entry_id
   AND prr.element_type_id = pet.element_type_id
   AND prr.status in ('P', 'PA')
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
   AND peev.input_value_id =piv.input_value_id
   AND peev.element_entry_id = pee.element_entry_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppa.effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   AND ppa.effective_date BETWEEN peev.effective_start_date AND peev.effective_end_date
   ORDER BY pee.element_entry_id
           ,piv.name;
--
-- Reduced the following cursor's cost from 27648 to 36.
--Cursor to get the Run results for the Element 'Leave Encashment Information'
CURSOR c_leave_encashment(p_employee_number VARCHAR2
                         ,p_bus_grp_id      NUMBER
                         ,p_asg_action_id   NUMBER)
IS
SELECT piv.name                    description
      ,prrv.result_value           amount
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_element_types_f         pet
      ,pay_input_values_f          piv
      ,pay_element_entries_f       pee
      ,pay_element_classifications pec
      ,pay_element_links_f         pel
      ,pay_assignment_actions      paa
      ,pay_payroll_actions         ppa
      ,pay_run_results             prr
      ,pay_run_result_values       prrv
      ,per_periods_of_service      ppos
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND pec.classification_name = 'Information'
   AND pec.legislation_code = 'IN'
   AND pec.classification_id = pet.classification_id
   AND pee.assignment_id = paf.assignment_id
   AND pee.element_type_id = pet.element_type_id
   AND pet.element_name = 'Leave Encashment Information'
   AND pel.element_link_id = pee.element_link_id
   AND pel.business_group_id = paf.business_group_id
   AND (pel.payroll_id = paf.payroll_id OR pel.link_to_all_payrolls_flag IS NOT NULL)
   AND piv.element_type_id = pet.element_type_id
   AND piv.name IN ('Leave Type'
                  , 'Leave Balance Days'
                  , 'Leave Adjusted Days'
                  , 'Encashment Amount')
   AND paa.source_action_id = p_asg_action_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND ppa.payroll_action_id = paa.payroll_action_id
   AND prr.element_entry_id = pee.element_entry_id
   AND prr.element_type_id = pet.element_type_id
   AND prr.status IN ('P', 'PA')
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppa.effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   AND ppa.effective_date BETWEEN pel.effective_start_date AND pel.effective_end_date
   ORDER BY pee.element_entry_id,piv.name  DESC;
--
--
--Cursor to get the Run results for the Elements 'Gratuity Information'
--                                               'Gratuity Payment'
--
CURSOR c_gratuity_payment(p_employee_number VARCHAR2
                         ,p_bus_grp_id      NUMBER
                         ,p_max_asg_id      NUMBER)
IS
SELECT prrv.result_value           amount
      ,piv.name                    description
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_element_types_f         pet
      ,pay_input_values_f          piv
      ,pay_assignment_actions      paa
      ,pay_run_results             prr
      ,pay_run_result_values       prrv
      ,per_periods_of_service      ppos
      ,pay_element_classifications pec
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND pet.element_name IN ('Gratuity Information'
                          , 'Gratuity Payment')
   AND pec.classification_name IN ('Information',
                                   'Termination Payments')
   AND (pet.business_group_id = paf.business_group_id or pet.legislation_code = 'IN')
   AND pec.classification_id = pet.classification_id
   AND pec.legislation_code = 'IN'
   AND piv.element_type_id = pet.element_type_id
   AND piv.name IN ( 'Pay Value'
                    ,'Base Salary Used'
                    ,'Completed Service Years'
                    ,'Forfeiture Amount'
                    ,'Forfeiture Reason'
                    ,'Calculated Amount')
   AND paa.source_action_id = p_max_asg_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND paa.assignment_id = paf.assignment_id
   AND prr.element_type_id = pet.element_type_id
   AND prr.status IN ('P', 'PA')
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   ORDER BY piv.name;
--
--
-- Cursor to get the Run results for the following Elements
-- for the Element Classifications Termination Payments
--     1. Commuted Pension
--     2. Gratuity Payment
--     3. PF Settlement
--     4. Leave Encashment
--
CURSOR c_employee_dues(p_employee_number VARCHAR2
                      ,p_bus_grp_id      NUMBER
                      ,p_max_asg_id      NUMBER)
IS
SELECT piv.name                                     description
      ,prrv.result_value                            amount
      ,nvl(pet.reporting_name, pet.element_name)    Element
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_element_types_f         pet
      ,pay_input_values_f          piv
      ,pay_assignment_actions      paa
      ,pay_run_results             prr
      ,pay_run_result_values       prrv
      ,per_periods_of_service      ppos
      ,pay_element_classifications pec
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND pec.classification_name = 'Termination Payments'
   AND pet.legislation_code = 'IN'
   AND pec.classification_id = pet.classification_id
   AND pec.legislation_code = 'IN'
   AND ((piv.name = 'Pay Value') --AND fnd_number.canonical_to_number(prrv.result_value) > 0
      OR piv.name IN ('Taxable Amount'
                    , 'Non Taxable Amount'))
   AND piv.element_type_id = pet.element_type_id
   AND paa.source_action_id = p_max_asg_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND pet.element_name IN ('Commuted Pension'
                           ,'Gratuity Payment'
                           ,'PF Settlement'
                           ,'Leave Encashment')
   AND prr.element_type_id = pet.element_type_id
   AND prr.status IN ('P', 'PA')
   AND paf.assignment_id = paa.assignment_id
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   ORDER BY  pet.element_name
           ,piv.name;

-- Cursor to get the Run results for the following Elements
-- for the Element Classifications Termination Payments
--     1. Retrenchment Compensation Information
--     2. Voluntary Retirement Information
--
CURSOR c_employee_term_dues(p_employee_number VARCHAR2
                           ,p_bus_grp_id      NUMBER
                           ,p_max_asg_id      NUMBER)
IS
SELECT piv.name                                     description
      ,prrv.result_value                            amount
      ,nvl(pet.reporting_name, pet.element_name)    Element
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_element_types_f         pet
      ,pay_input_values_f          piv
      ,pay_assignment_actions      paa
      ,pay_run_results             prr
      ,pay_run_result_values       prrv
      ,per_periods_of_service      ppos
      ,pay_element_classifications pec
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND pec.classification_name IN ('Information','Termination Payments')
   AND pet.legislation_code = 'IN'
   AND pec.classification_id = pet.classification_id
   AND pec.legislation_code = 'IN'
   AND piv.name IN ('Taxable Amount'
                  , 'Non Taxable Amount')
   AND piv.element_type_id = pet.element_type_id
   AND paa.source_action_id = p_max_asg_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND pet.element_name IN ('Retrenchment Compensation Information'
                           ,'Voluntary Retirement Information'
			   ,'Other Termination Payments')
   AND prr.element_type_id = pet.element_type_id
   AND prr.status IN ('P', 'PA')
   AND paf.assignment_id = paa.assignment_id
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   ORDER BY prr.element_entry_id
           ,piv.name;
--
-- Cursor to get the Run results
-- for the Element Classifications Termination Payments
-- not taken care of in the above cursor.
--
cursor c_employee_dues_user_elements(p_employee_number VARCHAR2
                                    ,p_bus_grp_id      NUMBER
                                    ,p_max_asg_id      NUMBER)
IS
SELECT sum(prrv.result_value)                           amount
      ,nvl(pet.reporting_name, pet.element_name)   description
      ,pet.element_name                            elename
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_element_types_f         pet
      ,pay_input_values_f          piv
      ,pay_assignment_actions      paa
      ,pay_run_results             prr
      ,pay_run_result_values       prrv
      ,per_periods_of_service      ppos
      ,pay_element_classifications pec
WHERE ppf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND ppos.business_group_id = ppf.business_group_id
   AND pec.classification_name = 'Termination Payments'
   AND (pet.business_group_id = ppf.business_group_id OR pet.legislation_code = 'IN')
   AND pec.classification_id = pet.classification_id
   AND pec.legislation_code = 'IN'
   AND piv.name = 'Pay Value'
-- AND fnd_number.canonical_to_number(prrv.result_value) > 0
   AND piv.element_type_id = pet.element_type_id
   AND paa.source_action_id = p_max_asg_id
   AND paa.assignment_id = paf.assignment_id
   AND prr.assignment_action_id = paa.assignment_action_id
   AND pet.element_name NOT IN ('Commuted Pension'
                               ,'Gratuity Payment'
                               ,'PF Settlement'
                               ,'Leave Encashment'
                               ,'Other Termination Payments')
   AND pet.element_name NOT IN   (select petf.element_name
                                    from pay_balance_feeds_f pbff
                                        ,pay_balance_types   pbt
                                        ,pay_input_values_f  pivf
                                        ,pay_element_types_f petf
                                   where pbff.balance_type_id = pbt.balance_type_id
                                     and pbt.balance_name in ('Retrenchment Compensation'
                                                            , 'Voluntary Retirement Benefits')
                                     and pbff.input_value_id = pivf.input_value_id
                                     and pivf.name = 'Pay Value'
                                     and petf.element_type_id = pivf.element_type_id
                                     and pbt.legislation_code = 'IN')
   AND prr.element_type_id = pet.element_type_id
   AND prr.status IN ('P', 'PA')
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date
   GROUP BY nvl(pet.reporting_name, pet.element_name),pet.element_name  ;
--
--
--  Cursor to get the gross deductions. Adding up the negative run values for the
--  Element Classifications 1. Earnings
--                          2. Termination Payments
--                          3. Tax Deductions
CURSOR c_gross_deductions(p_employee_number VARCHAR2
                         ,p_bus_grp_id      NUMBER
                         ,p_max_asg_id      NUMBER)
IS
SELECT /*+ ORDERED */
       SUM(ABS(fnd_number.canonical_to_number(prrv.result_value))) amount
  FROM per_assignments_f                      paf
      ,per_people_f                           ppf
      ,pay_element_types_f                    pet
      ,pay_input_values_f                     piv
      ,pay_assignment_actions                 paa
--      ,pay_element_entries_f                  peef-- Added as a part of bug fix 4774108
      ,pay_run_results                        prr
      ,pay_run_result_values                  prrv
      ,per_periods_of_service                 ppos
      ,pay_element_classifications            pec
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND ((pec.classification_name  IN ( 'Termination Payments'
                                     , 'Earnings') AND fnd_number.canonical_to_number(prrv.result_value) < 0)
     OR (pec.classification_name  IN ( 'Tax Deductions') AND fnd_number.canonical_to_number(prrv.result_value) > 0))
   AND (pet.business_group_id = paf.business_group_id OR pet.legislation_code = 'IN')
   AND pec.classification_id = pet.classification_id
   AND pec.legislation_code = 'IN'
   AND piv.name = 'Pay Value'
   AND piv.element_type_id = pet.element_type_id
   AND paa.source_action_id = p_max_asg_id
   AND prr.assignment_action_id = paa.assignment_action_id -- Modified as per bug 4774108
   AND prr.element_type_id = pet.element_type_id
   AND prr.status IN ('P', 'PA')
   AND paf.assignment_id = paa.assignment_id
   AND prr.run_result_id = prrv.run_result_id
   AND prrv.input_value_id = piv.input_value_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppos.actual_termination_date BETWEEN pet.effective_start_date AND pet.effective_end_date
   AND ppos.actual_termination_date BETWEEN piv.effective_start_date AND piv.effective_end_date;
--
--
--  Cursor to get the _ASG_RUN balance values for the following balances
--  1. Net Pay
CURSOR c_balance_values(p_employee_number VARCHAR2
                       ,p_bus_grp_id      NUMBER
                       ,p_max_asg_id      NUMBER)
IS
SELECT to_number(pay_balance_pkg.get_value(pdb.defined_balance_id
                                         , paa.assignment_action_id)) amount
     , pbt.balance_name description
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_assignment_actions      paa
      ,per_periods_of_service      ppos
      ,pay_balance_types           pbt
      ,pay_balance_dimensions      pbd
      ,pay_defined_balances        pdb
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND paa.source_action_id = p_max_asg_id
   AND paf.assignment_id = paa.assignment_id -- Modified for 4774108
   AND pbt.balance_name IN ('Net Pay')
   AND pbt.legislation_code = 'IN'
   AND pbd.dimension_name = '_ASG_RUN'
   AND pbd.legislation_code = 'IN'
   AND pdb.balance_type_id = pbt.balance_type_id
   AND pdb.balance_dimension_id = pbd.balance_dimension_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date;
--
--
--Cursor to get the payment details
CURSOR c_payment_details(p_employee_number VARCHAR2
                        ,p_bus_grp_id      NUMBER
                        ,p_max_payment_asg_id NUMBER)
IS
SELECT hr_general.decode_lookup('IN_BANK',pea.segment3)          bank
      ,hr_general.decode_lookup('IN_BANK_BRANCH',pea.segment4)   branch
      ,pea.segment1                   account_number
      ,ppt.payment_type_name          payment_type
      ,ppp.value                      amount
      ,ppa.effective_date             payment_date
  FROM pay_external_accounts          pea
      ,pay_pre_payments               ppp
      ,pay_org_payment_methods_f      pop
      ,pay_personal_payment_methods_f ppm
      ,pay_payment_types              ppt
      ,pay_action_interlocks          pci
      ,pay_payroll_actions            ppa
      ,pay_assignment_actions         paa
      ,per_people_f                   ppf
      ,per_assignments_f              paf
      ,per_periods_of_service         ppos
 WHERE ppp.assignment_action_id = pci.locking_action_id
   AND ppp.personal_payment_method_id = ppm.personal_payment_method_id (+)
   AND ppp.org_payment_method_id = pop.org_payment_method_id
   AND ppm.external_account_id = pea.external_account_id (+)
   AND pop.payment_type_id = ppt.payment_type_id
   AND pci.locked_action_id = paa.assignment_action_id
   AND ppf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppos.business_group_id = ppf.business_group_id
   AND ppf.person_id = ppos.person_id
   AND paf.assignment_id = paa.assignment_id
   AND paa.assignment_action_id = p_max_payment_asg_id
   AND paa.payroll_Action_id = ppa.payroll_action_id
   AND ppa.effective_date BETWEEN pop.effective_start_date AND pop.effective_end_date
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date
   AND ppa.effective_date BETWEEN nvl(ppm.effective_start_date,ppa.effective_date)
                              AND nvl(ppm.effective_end_date,ppa.effective_date);

--
--
--  Cursor to get the _ASG_PMTH balance values for the following balance
--  1. Gratuity Eligible Salary
--
CURSOR c_gratuity_elig_sal(p_employee_number VARCHAR2
                          ,p_bus_grp_id      NUMBER
                          ,p_max_asg_id      NUMBER)
IS
SELECT to_number(pay_balance_pkg.get_value(pdb.defined_balance_id
                                         , paa.assignment_action_id)) amount
     , pbt.balance_name description
  FROM per_assignments_f           paf
      ,per_people_f                ppf
      ,pay_assignment_actions      paa
      ,per_periods_of_service      ppos
      ,pay_balance_types           pbt
      ,pay_balance_dimensions      pbd
      ,pay_defined_balances        pdb
 WHERE paf.business_group_id = p_bus_grp_id
   AND ppf.employee_number = p_employee_number
   AND ppf.person_id = paf.person_id
   AND paf.period_of_service_id = ppos.period_of_service_id
   AND ppf.person_id = ppos.person_id
   AND paa.source_action_id = p_max_asg_id
   AND paf.assignment_id = paa.assignment_id -- Modified for 4774108
   AND pbt.balance_name IN ('Gratuity Eligible Salary')
   AND pbt.legislation_code = 'IN'
   AND pbd.dimension_name = '_ASG_PTD'
   AND pbd.legislation_code = 'IN'
   AND pdb.balance_type_id = pbt.balance_type_id
   AND pdb.balance_dimension_id = pbd.balance_dimension_id
   AND ppos.actual_termination_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
   AND ppos.actual_termination_date BETWEEN paf.effective_start_date AND paf.effective_end_date;

   l_asg_max_run_action_id      pay_assignment_actions.assignment_action_id%TYPE;-- Bug 4774108 addition
--
--
--
   l_final_report_info         hr_organization_information.org_information6%TYPE; -- Bug 6772976 addition
   l_process_date              per_periods_of_service.last_standard_process_date%TYPE;
   l_max_payment_action_id     pay_assignment_actions.assignment_action_id%TYPE;
--
   l_procedure   VARCHAR2(250);
   l_message     VARCHAR2(250);
BEGIN

  g_debug     := hr_utility.debug_enabled;
  l_procedure := g_package ||'create_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
  l_term_date := fnd_date.displayDT_to_date(p_term_date);
  IF (g_debug)
  THEN
       pay_in_utils.trace('**************************************************','********************');
       pay_in_utils.set_location(g_debug,'Input Paramters value is',20);
       pay_in_utils.trace('p_employee_number',p_employee_number);
       pay_in_utils.trace('l_term_date',l_term_date);
       pay_in_utils.trace('p_bus_grp_id',p_bus_grp_id);
  END IF;
--
  gXMLTable.DELETE;
  l_count := 1;
--
  fnd_file.put_line(fnd_file.log,'Creating the XML...');
  dbms_lob.createtemporary(p_xml_data,FALSE,DBMS_LOB.CALL);
  dbms_lob.open(p_xml_data,dbms_lob.lob_readwrite);
--
  l_tag := '<?xml version="1.0"?>';
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
  l_tag := '<TerminationDetails>';
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
  fnd_file.put_line(fnd_file.log,'Started...');
--
--
  fnd_file.put_line(fnd_file.log,'Creating XML for Employee Personal Details.');

--Bug 6772976 starts
  OPEN c_final_report_info(p_bus_grp_id);
  FETCH c_final_report_info into l_final_report_info;
  CLOSE c_final_report_info;

  OPEN  c_last_std_process_date(p_employee_number,p_bus_grp_id,l_term_date);
  FETCH c_last_std_process_date into l_process_date;
  CLOSE c_last_std_process_date;

--Condition to get the assignment Id depending on Last Standard process Date or as of the Latest
  --Payroll run
  IF l_final_report_info ='LAST_STANDARD_DATE' AND l_process_date IS NOT NULL
  THEN

     OPEN c_lsp_max_asg_act_id(p_employee_number,p_bus_grp_id,l_term_date,l_process_date);
     FETCH c_lsp_max_asg_act_id into l_asg_max_run_action_id;
     CLOSE c_lsp_max_asg_act_id;

       --Max Assignment Id for Payment Details
     OPEN c_lsp_payment_max_asg_act_id(p_employee_number,p_bus_grp_id,l_term_date,l_process_date);
     FETCH c_lsp_payment_max_asg_act_id into l_max_payment_action_id;
     CLOSE c_lsp_payment_max_asg_act_id;
  ELSE
  -- Bug 4774108 addition starts
      --MAx Assignment Id depending on Last Payroll run
     OPEN  c_max_asg_act_id(p_employee_number,p_bus_grp_id,l_term_date);
     FETCH c_max_asg_act_id INTO l_asg_max_run_action_id;
     CLOSE c_max_asg_act_id;-- Bug 4774108 addition ends

     --Max Assignment Id for Payment Deatils depending on Last Payroll Run
     OPEN c_payment_max_asg_act_id(p_employee_number,p_bus_grp_id,l_term_date);
     FETCH c_payment_max_asg_act_id into l_max_payment_action_id;
     CLOSE c_payment_max_asg_act_id;

  END IF;

  IF (g_debug)
  THEN
       pay_in_utils.trace('l_asg_max_run_action_id',l_asg_max_run_action_id);
  END IF;

  FOR c_rec in c_employee_details(p_employee_number
                                 ,p_bus_grp_id
				 ,l_term_date)
  LOOP
  --Employee Name
    gXMLTable(l_count).Name  := 'c_employee_name';
    gXMLTable(l_count).Value := (c_rec.name);
    l_count := l_count + 1;
  --Employee Number
    gXMLTable(l_count).Name  := 'c_employee_number';
    gXMLTable(l_count).Value := (c_rec.employee_number);
    l_count := l_count + 1;
  --Date of Birth
    gXMLTable(l_count).Name  := 'c_date_of_birth';
    gXMLTable(l_count).Value := (c_rec.dob);
    l_count := l_count + 1;
  --Age
    gXMLTable(l_count).Name  := 'c_age';
    gXMLTable(l_count).Value := (c_rec.age);
    l_count := l_count + 1;
  --Date of Joining
    gXMLTable(l_count).Name  := 'c_date_of_joining';
    gXMLTable(l_count).Value := (c_rec.doj);
    l_count := l_count + 1;
  --Date of Leaving
    gXMLTable(l_count).Name  := 'c_date_of_leaving';
    gXMLTable(l_count).Value := (c_rec.dol);
    l_count := l_count + 1;
  --Length of Service
    gXMLTable(l_count).Name  := 'c_length_of_service';
    gXMLTable(l_count).Value := (c_rec.los);
    l_count := l_count + 1;
  --Reason for Leaving
    gXMLTable(l_count).Name  := 'c_reason_for_leaving';
    gXMLTable(l_count).Value := (c_rec.leaving_reason);
    l_count := l_count + 1;
  --Department
    gXMLTable(l_count).Name  := 'c_department';
    gXMLTable(l_count).Value := (c_rec.department);
    l_count := l_count + 1;
  --Organization
    gXMLTable(l_count).Name  := 'c_organization';
    gXMLTable(l_count).Value := (c_rec.organization);
    l_count := l_count + 1;
  --Location
    gXMLTable(l_count).Name  := 'c_location';
    gXMLTable(l_count).Value := (c_rec.location);

  --
  --Payment Date will be populated during the payment details generation.
  --
  END LOOP;
--
  multiColumnar('Employee_Details'
               ,gXMLTable
               ,l_count);
  FOR c_rec_designation in c_employee_designation(p_employee_number
                                                 ,p_bus_grp_id
						 ,l_term_date)
  LOOP
    -- For getting the Designation
    l_tag := getTag('c_designation', c_rec_designation.designation);
    dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
  END LOOP;
  fnd_file.put_line(fnd_file.log,'Created Employee Personal Details.');
--
l_total_earnings         := 0;
l_total_deductions       := 0;
l_total_employer_charges := 0;
l_total_perquisites      := 0;
l_total_other_deductions := 0;
l_total_advance          := 0; -- Added for the bug fix 6660147
l_total_fringe_benefit   := 0; -- Added for the bug fix 6660147
--
fnd_file.put_line(fnd_file.log,'Creating XML for Regular Pay and Other Deductions.');
--
--  Following steps are carried out
--  1. The Classification of the element is checked
--  2. As per the classification, relevant colums are populated
--  3. The Amounts for a single classification are summed up
--  4. If the Summed Amount turns out to be zero ( meaning that there are no
--     elements of that classification) No Data Exists. is printed.
--
for c_rec_run_results in c_run_results(p_employee_number
                                      ,p_bus_grp_id
                                      ,l_asg_max_run_action_id)
--
LOOP
    --
    l_count := 1;

    --Description
    gXMLTable(l_count).Name  := 'c_description';
    gXMLTable(l_count).Value := (c_rec_run_results.description);
    l_count := l_count + 1 ;

    --Amount
    gXMLTable(l_count).Name  := 'c_amount';
    gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                             ,abs(fnd_number.canonical_to_number(c_rec_run_results.amount)));
    l_count := l_count + 1 ;

    --Classification
    gXMLTable(l_count).Name  := 'c_classification';
    gXMLTable(l_count).Value := (c_rec_run_results.classification);
    l_count := l_count + 1 ;

    --Elementname
    gXMLTable(l_count).Name  := 'c_elementname';
    gXMLTable(l_count).Value := (c_rec_run_results.elename);

    --
    IF c_rec_run_results.classification = 'Earnings'
    or c_rec_run_results.classification = 'Allowances' THEN
      multiColumnar('t_earnings'
                    ,gXMLTable
                    ,l_count);
      l_total_earnings := l_total_earnings + fnd_number.canonical_to_number(c_rec_run_results.amount);
      --
    ELSIF c_rec_run_results.classification = 'Deductions'
       or c_rec_run_results.classification = 'Involuntary Deductions'
       or c_rec_run_results.classification = 'Voluntary Deductions'
       or c_rec_run_results.classification = 'Pre Tax Deductions'
       or c_rec_run_results.classification = 'Tax Deductions' THEN
      multiColumnar('t_deductions'
                    ,gXMLTable
                    ,l_count);
      l_total_deductions := l_total_deductions + fnd_number.canonical_to_number(c_rec_run_results.amount);
      --
    ELSIF c_rec_run_results.classification = 'Employer Charges' THEN
      multiColumnar('t_er_charges'
                    ,gXMLTable
                    ,l_count);
      l_total_employer_charges := l_total_employer_charges + fnd_number.canonical_to_number(c_rec_run_results.amount);
      --
    ELSIF c_rec_run_results.classification = 'Perquisites' THEN
      multiColumnar('t_perquisites'
                    ,gXMLTable
                    ,l_count);
      l_total_perquisites := l_total_perquisites + fnd_number.canonical_to_number(c_rec_run_results.amount);
      --
    ELSIF c_rec_run_results.classification = 'Termination Payments'
         AND fnd_number.canonical_to_number(c_rec_run_results.amount) < 0 THEN
      multiColumnar('t_other_deductions'
                    ,gXMLTable
                    ,l_count);
      l_total_other_deductions := l_total_other_deductions
                                + abs(fnd_number.canonical_to_number((c_rec_run_results.amount)));
      -- /*Added code for bug fix 6660147*/
     ELSIF c_rec_run_results.classification = 'Advances' THEN
      multiColumnar('t_advances'
                    ,gXMLTable
                    ,l_count);
      l_total_advance := l_total_advance
                                + abs(fnd_number.canonical_to_number((c_rec_run_results.amount)));
    --
     ELSIF c_rec_run_results.classification = 'Fringe Benefits' THEN
      multiColumnar('t_fringe_benefits'
                    ,gXMLTable
                    ,l_count);
      l_total_fringe_benefit := l_total_fringe_benefit
                                + abs(fnd_number.canonical_to_number((c_rec_run_results.amount)));
      --
    END IF;
    --
END LOOP;
--
-- If there is no data for any Element Classification then 'No Data Exists.' is printed
--
IF l_total_earnings <> 0 THEN
  l_tag := getTag('c_total_earnings', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                ,l_total_earnings));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
      twoColumnar('t_earnings'
                  ,gXMLTable
                  ,1);
END IF;

IF l_total_deductions <> 0 THEN
  l_tag := getTag('c_total_deductions', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                  ,l_total_deductions));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
      twoColumnar('t_deductions'
                  ,gXMLTable
                  ,1);
END IF;

IF l_total_employer_charges <> 0 THEN
  l_tag := getTag('c_total_employer_charges', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                        ,l_total_employer_charges));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
      twoColumnar('t_er_charges'
                  ,gXMLTable
                  ,1);
END IF;

IF l_total_perquisites <> 0 THEN
  l_tag := getTag('c_total_perquisites', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                   ,l_total_perquisites));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
      twoColumnar('t_perquisites'
                  ,gXMLTable
                  ,1);
END IF;

IF l_total_other_deductions <> 0 THEN
l_tag := getTag('c_total_other_deductions', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                        ,abs(fnd_number.canonical_to_number(l_total_other_deductions))));
dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
      twoColumnar('t_other_deductions'
                  ,gXMLTable
                  ,1);
END IF;
-- /*Added code for bug fix 6660147*/
--Bugfix 66660147 start
IF l_total_advance <> 0 THEN
l_tag := getTag('c_total_advance', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                        ,abs(fnd_number.canonical_to_number(l_total_advance))));
dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
      twoColumnar('t_advances'
                  ,gXMLTable
                  ,1);
END IF;

IF l_total_fringe_benefit <> 0 THEN
l_tag := getTag('c_total_fringe_benefit', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                        ,abs(fnd_number.canonical_to_number(l_total_fringe_benefit))));
dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
      twoColumnar('t_fringe_benefits'
                  ,gXMLTable
                  ,1);
END IF;
--Bugfix 66660147 end
--
--
fnd_file.put_line(fnd_file.log,'Created Regular Pay and Other Deductions.');
--
--
fnd_file.put_line(fnd_file.log,'Creating XML for Loan Recovery.');
--
l_total_loan_recovery := 0;
l_count               := 1;
--
--
--  Following steps are carried out
--  1. The Element Loan Type is checked for the input values Pay Value and Loan Type
--  2. The Amounts for a single classification are summed up
--  3. If the Summed Amount turns out to be zero ( meaning that there are no
--     loans to be recovered) No Data Exists. is printed.
--
for c_rec_loan in c_loan_recovery(p_employee_number
                                 ,p_bus_grp_id
                                 ,l_asg_max_run_action_id)
LOOP
    --
    l_count := 1;
    IF c_rec_loan.description = 'Loan Type' THEN
      --
      gXMLTable(l_count).Name  := c_rec_loan.loan_type;
      --
    ELSIF c_rec_loan.description = 'Pay Value' AND fnd_number.canonical_to_number(c_rec_loan.amount) < 0 THEN
      --
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,abs(fnd_number.canonical_to_number(c_rec_loan.amount)));
      l_total_loan_recovery := l_total_loan_recovery + abs(fnd_number.canonical_to_number(c_rec_loan.amount));
      l_count := l_count + 1;
      --
    END IF;
    --
    IF l_count = 2 THEN
       twoColumnar('t_loan_recovery'
                  ,gXMLTable
                  ,l_count - 1);
     --  l_total_loan_recovery := l_total_loan_recovery + gXMLTable(l_count-1).Value;
    END IF;
    --
END LOOP;
--
-- If there is no data then 'No Data Exists.' is printed
--
IF l_total_loan_recovery <> 0 THEN
  l_tag := getTag('c_total_perquisites_loan_recovery', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                                 ,fnd_number.canonical_to_number(l_total_loan_recovery)));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
ELSE
  gXMLTable(1).Name  := 'No Data Exists.';
  gXMLTable(1).Value := ' ';
  twoColumnar('t_loan_recovery'
              ,gXMLTable
              ,1);
END IF;
--
fnd_file.put_line(fnd_file.log,'Created Loan Recovery.');
--
fnd_file.put_line(fnd_file.log,'Creating XML for Leave Encashment.');
--
l_count := 1;
l_leave_encashed_flag := 0; /* variable to check if No data Found is to be printed */
--
--  Following steps are carried out
--  1. The Element Leave Encashment Information is checked for the input values
--     Leave Type, Leave Balance Days, Leave Adjusted Days, Encashment Amount
--  2. If the cursor doesn't return any record then No Data Exists is printed.
--
for c_rec_leave_encashment in c_leave_encashment(p_employee_number
                                                ,p_bus_grp_id
                                                ,l_asg_max_run_action_id)
LOOP
    --
    l_leave_encashed_flag := 1;
    IF c_rec_leave_encashment.description = 'Leave Type' THEN
      gXMLTable(l_count).Name  := 'c_leave_type';
      gXMLTable(l_count).Value := hr_general.decode_lookup('ABSENCE_CATEGORY'
                                                          ,(c_rec_leave_encashment.amount));
    --
    ELSIF c_rec_leave_encashment.description = 'Leave Balance Days' THEN
      gXMLTable(l_count).Name  := 'c_balance_days';
      gXMLTable(l_count).Value := nvl((c_rec_leave_encashment.amount),'0');
    --
    ELSIF c_rec_leave_encashment.description = 'Leave Adjusted Days' THEN
      gXMLTable(l_count).Name  := 'c_notice_period_adjusted';
      gXMLTable(l_count).Value := nvl((c_rec_leave_encashment.amount),'0');
    --
    ELSIF c_rec_leave_encashment.description = 'Encashment Amount' THEN
      gXMLTable(l_count).Name  := 'c_amount';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_leave_encashment.amount),0));
    END IF;
    l_count := l_count + 1;
   --
   IF l_count = 5 THEN
     gXMLTable(l_count).Name  := 'c_remaining_leave_balance';
     gXMLTable(l_count).Value := to_char(fnd_number.canonical_to_number(gXMLTable(2).Value) - fnd_number.canonical_to_number(gXMLTable(3).Value)) ;
     multiColumnar('t_leave_encashment'
                  ,gXMLTable
                  ,l_count);
     l_count := 1;
   END IF;
   --
END LOOP;
--
IF l_leave_encashed_flag = 0 THEN
   gXMLTable(1).Name  := 'c_leave_type';
   gXMLTable(1).Value := 'No Data Exists.';
   multiColumnar('t_leave_encashment'
                ,gXMLTable
                ,1);
END IF;
--
fnd_file.put_line(fnd_file.log,'Created Leave Encashment.');
--
fnd_file.put_line(fnd_file.log,'Creating XML for Gratuity Payment.');
--
l_count := 1;
l_gratuity_paid_flag := 0; /* variable to check if No data Found is to be printed */
l_grat_elig_sal := 0;
--
--  Following steps are carried out
--  1. The Elements Gratuity Information and Gratuity Payment are checked for the input values
--     Base Salary, Completed Service Years, Forfeiture Amounts, Forfeiture Reason and
--     Pay Value, Calculated Amount
--  2. If the cursor doesn't return any record then No Data Exists is printed.
--
for c_rec_gratuity_payment in c_gratuity_payment(p_employee_number
                                                ,p_bus_grp_id
                                                ,l_asg_max_run_action_id)
LOOP
    --
    l_gratuity_paid_flag := 1;
    IF c_rec_gratuity_payment.description = 'Base Salary Used' THEN
      gXMLTable(l_count).Name  := 'c_last_drawn_salary';
      IF c_rec_gratuity_payment.amount IS NULL THEN
        FOR c_rec_grat_elig_sal in c_gratuity_elig_sal(p_employee_number
                                                      ,p_bus_grp_id
                                                      ,l_asg_max_run_action_id)
        LOOP
          l_grat_elig_sal := c_rec_grat_elig_sal.amount;
        END LOOP;
      ELSE
        l_grat_elig_sal := fnd_number.canonical_to_number(c_rec_gratuity_payment.amount);
      END IF;
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                             ,(l_grat_elig_sal));
    --
    ELSIF c_rec_gratuity_payment.description = 'Completed Service Years' THEN
      gXMLTable(l_count).Name  := 'c_completed_service_years';
      gXMLTable(l_count).Value := (c_rec_gratuity_payment.amount);
    --
    ELSIF c_rec_gratuity_payment.description = 'Forfeiture Amount' THEN
      gXMLTable(l_count).Name  := 'c_forfeiture_amount';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_gratuity_payment.amount),0));
    --
    ELSIF c_rec_gratuity_payment.description = 'Forfeiture Reason' THEN
      gXMLTable(l_count).Name  := 'c_forfeiture_reason';
      gXMLTable(l_count).Value := hr_general.decode_lookup('IN_GRATUITY_FORFEITURE_REASON',c_rec_gratuity_payment.amount);
    --
    ELSIF c_rec_gratuity_payment.description = 'Pay Value' THEN
      gXMLTable(l_count).Name  := 'c_gratuity_amount';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_gratuity_payment.amount),0));
    --
    ELSIF c_rec_gratuity_payment.description = 'Calculated Amount' THEN
      gXMLTable(l_count).Name  := 'c_calculated_amount';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_gratuity_payment.amount),0));
    --
    END IF;
    --
    l_count := l_count + 1;
    --
END LOOP;
--
IF l_gratuity_paid_flag = 0 THEN
   gXMLTable(1).Name  := 'c_last_drawn_salary';
   gXMLTable(1).Value := 'No Data Exists.';
   multiColumnar('t_gratuity'
                ,gXMLTable
                ,1);
--
ELSE
  multiColumnar('t_gratuity'
                ,gXMLTable
                ,l_count);
END IF;
--
fnd_file.put_line(fnd_file.log,'Created Gratuity Payment.');
--
fnd_file.put_line(fnd_file.log,'Creating XML for Dues to Employee.');
--
l_total_paid     := 0;
l_total_taxable  := 0;
l_total_exempted := 0 ;
l_count          := 2;
l_emp_dues_flag  := 0; /* variable to check if No data Found is to be printed */
l_exempted       := 0;
l_paid           := 0;
l_taxable        := 0;
--
--  Following step is carried out
--  1. The seeded Termination Payments elements are displayed here
--  2. The Amount Paid, Amount Exempted and Taxable Amount are summed
--
for c_rec_employee_dues in c_employee_dues(p_employee_number
                                          ,p_bus_grp_id
                                          ,l_asg_max_run_action_id
                                          )
LOOP
    --
    IF l_emp_dues_flag  = 0 then
      l_emp_dues_flag  := 1;
    END IF;
    gXMLTable(1).Name  := 'c_description';
    gXMLTable(1).Value := (c_rec_employee_dues.element);
    --
    IF c_rec_employee_dues.description = 'Non Taxable Amount' THEN
      gXMLTable(l_count).Name  := 'c_amount_exempted';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_employee_dues.amount),0));
      l_exempted := fnd_number.canonical_to_number(nvl(c_rec_employee_dues.amount,0));
    --
    ELSIF c_rec_employee_dues.description = 'Pay Value' AND fnd_number.canonical_to_number(NVL(c_rec_employee_dues.amount,0)) > 0 THEN

      gXMLTable(l_count).Name  := 'c_amount_paid';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_employee_dues.amount),0));
      l_paid := fnd_number.canonical_to_number(nvl(c_rec_employee_dues.amount,0));
    --
    ELSIF c_rec_employee_dues.description = 'Taxable Amount' THEN
      --
      IF l_count = 3 THEN
        gXMLTable(l_count).Name  := 'c_amount_paid';
        gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id,0);
        l_paid := 0;
        l_count := l_count + 1;
      END IF;
      --
      gXMLTable(l_count).Name  := 'c_taxable_amount';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_employee_dues.amount),0));
      l_taxable  := fnd_number.canonical_to_number(nvl(c_rec_employee_dues.amount,0));
    END IF;
    --
    l_count := l_count + 1;
    --
    IF l_count = 5 THEN
      l_count := 2;
      IF l_exempted = 0 AND
         l_paid     = 0 AND
         l_taxable  = 0 THEN
         if l_emp_dues_flag = 1 then
           l_emp_dues_flag  := 0;
         end if;
      ELSE
        multiColumnar('t_due_to_ee'
                     ,gXMLTable
                     ,4);
        l_total_exempted := l_total_exempted + l_exempted;
        l_total_paid     := l_total_paid     + l_paid;
        l_total_taxable  := l_total_taxable  + l_taxable;
        l_exempted := 0;
        l_paid     := 0;
        l_taxable  := 0;
        l_emp_dues_flag  := 2;
      END IF;
    --
    END IF;
    --
END LOOP;
--
--
--  Following step is carried out
--  1. The seeded Termination Information elements are displayed here
--  2. The Amount Paid, Amount Exempted and Taxable Amount are summed
--
l_count          := 2;
for c_rec_employee_term_dues in c_employee_term_dues(p_employee_number
                                                    ,p_bus_grp_id
                                                    ,l_asg_max_run_action_id
                                                    )
LOOP
    --
    l_emp_dues_flag  := 1;
    gXMLTable(1).Name  := 'c_description';
    gXMLTable(1).Value := (c_rec_employee_term_dues.element);

    IF gXMLTable(1).Value = 'Retrenchment Compensation Information' THEN
       gXMLTable(1).Value := 'Retrenchment Compensation';
    ELSIF gXMLTable(1).Value = 'Voluntary Retirement Information' THEN
       gXMLTable(1).Value := 'Voluntary Retirement Compensation';
    END IF;
    --
    IF c_rec_employee_term_dues.description = 'Non Taxable Amount' THEN
      gXMLTable(l_count).Name  := 'c_amount_exempted';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_employee_term_dues.amount),0));
      l_exempted := fnd_number.canonical_to_number(nvl(c_rec_employee_term_dues.amount,0));

    ELSIF c_rec_employee_term_dues.description = 'Taxable Amount' THEN
      gXMLTable(l_count).Name  := 'c_taxable_amount';
      gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                              ,nvl(fnd_number.canonical_to_number(c_rec_employee_term_dues.amount),0));
      l_taxable  := fnd_number.canonical_to_number(nvl(c_rec_employee_term_dues.amount,0));

    END IF;

    IF l_count = 3 THEN
       gXMLTable(4).Name  := 'c_amount_paid';
       l_paid := l_exempted + l_taxable;
       gXMLTable(4).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                         ,nvl(l_paid,0));
       multiColumnar('t_due_to_ee'
                     ,gXMLTable
                     ,4);

        l_total_exempted := l_total_exempted + l_exempted;
        l_total_paid     := l_total_paid     + l_paid;
        l_total_taxable  := l_total_taxable  + l_taxable;
        l_count := 1;
    END IF;

    l_count := l_count + 1;

END LOOP;

--  Following steps are carried out
--  1. The user created Termination Payments elements are displayed here
--  2. The Amount Paid, Amount Exempted and Taxable Amount are summed
--  3. If there are no does to employee, No Data Exists is printed.
--
for c_rec_employee_dues_user in c_employee_dues_user_elements(p_employee_number
                                                             ,p_bus_grp_id
                                                             ,l_asg_max_run_action_id)
LOOP
    --
  IF fnd_number.canonical_to_number(NVL (c_rec_employee_dues_user.amount,0)) > 0 THEN
    l_emp_dues_flag  := 1;
    gXMLTable(1).Name  := 'c_description';
    gXMLTable(1).Value := (c_rec_employee_dues_user.description);
    --
    gXMLTable(2).Name  := 'c_amount_exempted';
    gXMLTable(2).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id,0);
    --
    gXMLTable(3).Name  := 'c_amount_paid';
    gXMLTable(3).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                      ,nvl(fnd_number.canonical_to_number(c_rec_employee_dues_user.amount),0));
    l_total_paid     := l_total_paid     + fnd_number.canonical_to_number(nvl(c_rec_employee_dues_user.amount,0));
    --
    gXMLTable(4).Name  := 'c_taxable_amount';
    gXMLTable(4).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                      ,nvl(fnd_number.canonical_to_number(c_rec_employee_dues_user.amount),0));
    l_total_taxable  := l_total_taxable  + fnd_number.canonical_to_number(nvl(c_rec_employee_dues_user.amount,0));
    --
    gXMLTable(5).Name  := 'c_elementname';
    gXMLTable(5).Value := (c_rec_employee_dues_user.elename);
    --
    multiColumnar('t_due_to_ee'
                  ,gXMLTable
                  ,5);
  END IF;
END LOOP;
--
IF l_emp_dues_flag  = 0 THEN
    gXMLTable(1).Name  := 'c_description';
    gXMLTable(1).Value := 'No Data Exists.';
    multiColumnar('t_due_to_ee'
                 ,gXMLTable
                 ,1);
ELSE
  l_tag := getTag('c_total_amount_paid', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                     ,l_total_paid));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);

  l_tag := getTag('c_total_taxable_amount', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                        ,l_total_taxable));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);

  l_tag := getTag('c_total_amount_exempted', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                         ,l_total_exempted));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
END IF;
--
fnd_file.put_line(fnd_file.log,'Created Dues to Employee.');
--
fnd_file.put_line(fnd_file.log,'Creating XML for Net Amount Payables.');
l_gross_earnings := 0;
--
--  Following steps are carried out
--  1. Net Amount is found through the Balance _ASG_RUN values
--  2. Gross Deductions are found by summing up the run values
--  3. Net Amount + Tax + Gross Deductions = Gross Earnings
--  4. Print the Net Amount in words.
--
for c_rec_gross_deductions in c_gross_deductions(p_employee_number
                                                ,p_bus_grp_id
                                                ,l_asg_max_run_action_id)
LOOP
  --
  l_gross_earnings := l_gross_earnings + nvl(abs(fnd_number.canonical_to_number(c_rec_gross_deductions.amount)),0);
  --
END LOOP;

  l_tag := getTag('c_gross_deductions', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                    ,l_gross_earnings));
  dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);

--
l_net_pay := 0;
--
for c_rec_balance_values in c_balance_values(p_employee_number
                                            ,p_bus_grp_id
                                            ,l_asg_max_run_action_id
                                            )
LOOP
  --

    l_net_pay := l_net_pay + fnd_number.canonical_to_number(c_rec_balance_values.amount);
  --

    l_gross_earnings := l_gross_earnings + fnd_number.canonical_to_number(nvl(c_rec_balance_values.amount,0));
  --
  --
END LOOP;

    l_tag := getTag('c_net_amount', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                ,l_net_pay));
    dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);

    IF l_net_pay >= 0 THEN
      l_tag := getTag('c_net_amount_in_words', initcap(pay_in_utils.number_to_words(l_net_pay)));
      dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
    END IF;

--
l_tag := getTag('c_gross_earnings', pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                                ,l_gross_earnings));
dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
--
fnd_file.put_line(fnd_file.log,'Created Net Amount Payables.');
--
fnd_file.put_line(fnd_file.log,'Creating XML for Payment Details.');
--
l_count := 1;
l_payment_flag := 0;
--
--  Following steps are carried out
--  1. Payment Details are found out using the Pre Payments
--  2. Bank is found out by concatanating the Bank Name and Bank Branch
--  3. If Payment has not been made then Payment not done. is printed.
--
for c_rec_payment_details in c_payment_details(p_employee_number
                                              ,p_bus_grp_id
                                              ,l_max_payment_action_id)
LOOP
    --
    l_payment_flag := 1;

    IF l_count = 1 THEN
      l_tag := getTag('c_payment_date', to_char(c_rec_payment_details.payment_date,'dd-Mon-yyyy'));
      dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
    END IF;

     l_count := 1;
    --
    --Payment Type
    gXMLTable(l_count).Name  := 'c_payment_type';
    gXMLTable(l_count).Value := (c_rec_payment_details.payment_type);
    l_count := l_count + 1;
    --Bank
    gXMLTable(l_count).Name  := 'c_bank';
    IF c_rec_payment_details.bank IS NOT NULL AND
       c_rec_payment_details.branch IS NOT NULL THEN
      gXMLTable(l_count).Value := c_rec_payment_details.bank || ', ' || c_rec_payment_details.branch;
    ELSE
      gXMLTable(l_count).Value := c_rec_payment_details.bank || ' ' || c_rec_payment_details.branch;
    END IF;
    l_count := l_count + 1;
    --Account Number
    gXMLTable(l_count).Name  := 'c_account_number';
    gXMLTable(l_count).Value := (c_rec_payment_details.account_number);
    l_count := l_count + 1;
    --Amount
    gXMLTable(l_count).Name  := 'c_amount';
    gXMLTable(l_count).Value := pay_us_employee_payslip_web.get_format_value(p_bus_grp_id
                                                                            ,nvl(c_rec_payment_details.amount,0));
    multiColumnar('t_payment_details'
                 ,gXMLTable
                 ,l_count);
END LOOP;
--
IF l_payment_flag = 0 THEN
  gXMLTable(1).Name  := 'c_payment_type';
  gXMLTable(l_count).Value := 'Payment not done.';
  multiColumnar('t_payment_details'
                ,gXMLTable
                ,1);
END IF;
--
fnd_file.put_line(fnd_file.log,'Created Payment Details.');
--
l_tag := '</TerminationDetails>';
--
dbms_lob.writeAppend(p_xml_data, length(l_tag), l_tag);
--
l_xml_data := p_xml_data;
--
pay_in_utils.trace('**************************************************','********************');
pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

END create_xml;
--
end pay_in_term_rprt_gen_pkg;

/
