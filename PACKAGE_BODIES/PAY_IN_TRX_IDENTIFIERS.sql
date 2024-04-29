--------------------------------------------------------
--  DDL for Package Body PAY_IN_TRX_IDENTIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_TRX_IDENTIFIERS" AS
/* $Header: pyintrx.pkb 120.0.12010000.1 2009/07/28 12:38:38 rsaharay noship $ */

  g_package              CONSTANT VARCHAR2(100) := 'pay_in_trx_identifiers.';
  g_debug                BOOLEAN;


 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_PARAMETERS                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure determines the globals applicable    --
  --                  through out the tenure of the process               --
  -- Parameters     :                                                     --
  --             IN : p_legislative_parameters VARCHAR2                   --
  --             IN : p_token_name             VARCHAR2                   --
  --                                                                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 12.0  01-Jun-2009    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------

	FUNCTION get_parameters( p_legislative_parameters IN  VARCHAR2,
	                         p_token_name             IN  VARCHAR2 )
	RETURN VARCHAR2
	 IS

	 l_token_value       VARCHAR2(50);
	 l_procedure         VARCHAR2(100);
         l_message           VARCHAR2(250);

	BEGIN

	   g_debug := hr_utility.debug_enabled;
	   l_procedure  := g_package || 'get_parameters';
	   pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);


	   l_token_value := SUBSTR(p_legislative_parameters||' ',
        	            INSTR(p_legislative_parameters||' ',p_token_name||'=')+(LENGTH(p_token_name||'=')),
                     	    INSTR(p_legislative_parameters||' ',' ',
	                    INSTR(p_legislative_parameters||' ',p_token_name||'='))
        	         - (INSTR(p_legislative_parameters||' ',p_token_name||'=')+LENGTH(p_token_name||'=')));

           IF g_debug THEN
                  pay_in_utils.trace('p_legislative_parameters ',p_legislative_parameters);
                  pay_in_utils.trace('p_token_name             ',p_token_name);
                  pay_in_utils.trace('l_token_value            ',l_token_value);
          END IF;

          pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
	  RETURN l_token_value ;
	EXCEPTION
	WHEN OTHERS THEN
	      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR',
              'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
              pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
              RAISE ;
	END get_parameters;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : BATCH_TRANSACTION_IDENTIFIERS                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function to identify the batch transaction          --
  --                  identifiers                                         --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_effective_date              DATE                  --
  --                  p_identifier_name             VARCHAR2              --
  --                  p_payroll_action_id           NUMBER                --
  --                  p_payment_type_id             NUMBER                --
  --                  p_org_payment_method_id       NUMBER                --
  --                  p_personal_payment_method_id  NUMBER                --
  --                  p_assignment_action_id        NUMBER                --
  --                  p_pre_payment_id              NUMBER                --
  --                  p_delimiter_string            VARCHAR2              --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 12.0  01-Jun-2009    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
	FUNCTION batch_transaction_identifiers
	(
	  p_effective_date              DATE
	, p_identifier_name             VARCHAR2
	, p_payroll_action_id           NUMBER
	, p_payment_type_id             NUMBER
	, p_org_payment_method_id       NUMBER
	, p_personal_payment_method_id  NUMBER
	, p_assignment_action_id        NUMBER
	, p_pre_payment_id              NUMBER
	, p_delimiter_string            VARCHAR2
	)
	RETURN VARCHAR2
	IS

          l_emp_num           per_people_f.employee_number%TYPE ;
	  l_emp_name1         per_people_f.full_name%TYPE ;
	  l_emp_name2         per_people_f.full_name%TYPE ;
	  l_emp_name3         per_people_f.full_name%TYPE ;
	  l_emp_bank          hr_lookups.meaning%TYPE ;
	  l_emp_branch        hr_lookups.meaning%TYPE ;
	  l_emp_acc_name      hr_lookups.meaning%TYPE ;
	  l_emp_acc_num       pay_external_accounts.segment1%TYPE ;
	  l_reg_comp          pay_external_accounts.segment1%TYPE ;
	  l_leg_param         pay_payroll_actions.legislative_parameters%TYPE ;
	  l_payment_date      VARCHAR2(100);
	  l_transaction_group NUMBER(20) ;
	  l_request_id        pay_payroll_actions.request_id%TYPE ;
	  l_reg_comp_name     hr_organization_information.org_information4%TYPE ;
	  l_bank_acc_num      pay_external_accounts.segment1%TYPE ;
	  l_procedure         VARCHAR2(100);
          l_message           VARCHAR2(250);



          CURSOR csr_emp_tran_details( l_payroll_action_id           NUMBER
                                      ,l_org_payment_method_id       NUMBER
				      ,l_assignment_action_id        NUMBER )
	  IS
	  SELECT  per.employee_number                                                                               emp_num
                , SUBSTR(per.full_name,1,80)                                                                        emp_name1
                , SUBSTR(per.full_name,81,80)                                                                       emp_name2
                , SUBSTR(per.full_name,161,80)                                                                      emp_name3
                , hr_general.decode_lookup('IN_BANK',pea.segment3)                                                  emp_bank
                , hr_general.decode_lookup('IN_BANK_BRANCH',pea.segment4)                                           emp_branch
                , hr_general.decode_lookup('IN_ACCOUNT_TYPE',pea.segment2)                                          emp_acc_name
                , pea.segment1                                                                                      emp_acc_num
		, ppa.legislative_parameters                                                                        leg_param
		, SUBSTR(lpad(paa.action_sequence,15,'0'),10)                                                       transaction_group
		, ppa.request_id                                                                                    request_id
		,oea.segment1                                                                                       bank_acc_num
	  FROM   pay_org_payment_methods_f      popm
	  ,      pay_external_accounts          oea
	  ,      pay_personal_payment_methods_f pppm
	  ,      pay_external_accounts          pea
	  ,      pay_pre_payments               ppp
	  ,      pay_assignment_actions         paa
	  ,      pay_payroll_actions            ppa
	  ,      per_assignments_f              asg
	  ,      per_people_f                   per
	  ,      hr_organization_units          org
	  ,      pay_payment_types              ppto
	  WHERE  ppa.payroll_action_id           = l_payroll_action_id
	  AND    paa.assignment_action_id        = l_assignment_action_id
	  AND    ppp.pre_payment_id              = paa.pre_payment_id
	  AND    paa.payroll_action_id           = ppa.payroll_action_id
	  AND    ppa.business_group_id           = popm.business_group_id
	  AND    oea.external_account_id         = popm.external_account_id
	  AND    ppa.business_group_id           = org.organization_id
	  AND    popm.org_payment_method_id      = ppp.org_payment_method_id
	  AND    pea.external_account_id         = pppm.external_account_id
	  AND    pppm.personal_payment_method_id = ppp.personal_payment_method_id
	  AND    paa.assignment_id               = asg.assignment_id
	  AND    asg.person_id                   = per.person_id
	  AND    ppa.effective_date BETWEEN  popm.effective_start_date AND popm.effective_end_date
	  AND    ppa.effective_date BETWEEN  pppm.effective_start_date AND pppm.effective_end_date
	  AND    ppa.effective_date BETWEEN  asg.effective_start_date AND  asg.effective_end_date
	  AND    ppa.effective_date BETWEEN  per.effective_start_date AND  per.effective_end_date
	  AND    ppto.category = 'MT'
	  AND    popm.payment_type_id = ppto.payment_type_id
	  AND    popm.org_payment_method_id = l_org_payment_method_id;

	  CURSOR csr_reg_comp (l_reg_company NUMBER)
	  IS
	  SELECT hoi.org_information4  company_name
	  FROM   hr_organization_information hoi
	  WHERE  hoi.organization_id = l_reg_company
          AND    hoi.org_information_context = 'PER_IN_COMPANY_DF' ;


	BEGIN

	        g_debug := hr_utility.debug_enabled;
	        l_procedure  := g_package || 'batch_transaction_identifiers';
	        pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

		IF g_debug THEN
                     pay_in_utils.trace('p_effective_date            ',p_effective_date);
                     pay_in_utils.trace('p_identifier_name           ',p_identifier_name);
                     pay_in_utils.trace('p_payroll_action_id         ',p_payroll_action_id);
                     pay_in_utils.trace('p_payment_type_id           ',p_payment_type_id);
                     pay_in_utils.trace('p_org_payment_method_id     ',p_org_payment_method_id);
                     pay_in_utils.trace('p_personal_payment_method_id',p_personal_payment_method_id);
                     pay_in_utils.trace('p_assignment_action_id      ',p_assignment_action_id);
                     pay_in_utils.trace('p_pre_payment_id            ',p_pre_payment_id);
                     pay_in_utils.trace('p_delimiter_string          ',p_delimiter_string);
                END IF;


		OPEN csr_emp_tran_details(p_payroll_action_id, p_org_payment_method_id, p_assignment_action_id);
		FETCH csr_emp_tran_details INTO  l_emp_num
						,l_emp_name1
						,l_emp_name2
						,l_emp_name3
						,l_emp_bank
						,l_emp_branch
						,l_emp_acc_name
						,l_emp_acc_num
						,l_leg_param
						,l_transaction_group
						,l_request_id
						,l_bank_acc_num;
		CLOSE csr_emp_tran_details ;

		pay_in_utils.set_location(g_debug,'In : '||l_procedure,20);

                l_payment_date := get_parameters(l_leg_param,'PAYMENT_DATE_PARAM') ;
                l_reg_comp     := get_parameters(l_leg_param,'REGISTERED_EMPLOYER_PARAM') ;

		OPEN csr_reg_comp(l_reg_comp);
		FETCH csr_reg_comp INTO l_reg_comp_name;
		CLOSE csr_reg_comp;

		pay_in_utils.set_location(g_debug,'In : '||l_procedure,30);

                IF g_debug THEN
                     pay_in_utils.trace('l_emp_num          ',l_emp_num);
                     pay_in_utils.trace('l_emp_name1        ',l_emp_name1);
                     pay_in_utils.trace('l_emp_name2        ',l_emp_name2);
                     pay_in_utils.trace('l_emp_name3        ',l_emp_name3);
                     pay_in_utils.trace('l_emp_bank         ',l_emp_bank);
                     pay_in_utils.trace('l_emp_branch       ',l_emp_branch);
                     pay_in_utils.trace('l_emp_acc_name     ',l_emp_acc_name);
                     pay_in_utils.trace('l_emp_acc_num      ',l_emp_acc_num);
                     pay_in_utils.trace('l_leg_param        ',l_leg_param);
                     pay_in_utils.trace('l_transaction_group',l_transaction_group);
                     pay_in_utils.trace('l_request_id       ',l_request_id);
                     pay_in_utils.trace('l_bank_acc_num     ',l_bank_acc_num);
                     pay_in_utils.trace('l_payment_date     ',l_payment_date);
                     pay_in_utils.trace('l_reg_comp         ',l_reg_comp);
                     pay_in_utils.trace('l_reg_comp_name    ',l_reg_comp_name);
                END IF;



                pay_in_utils.set_location(g_debug,'In : '||l_procedure,40);

		IF p_identifier_name =    'CONCATENATED_IDENTIFIERS' THEN
  		 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,50);
		 RETURN l_reg_comp_name||','||l_bank_acc_num||','||l_payment_date;
		ELSIF p_identifier_name = 'PAYEE_BANK_ACCOUNT_NAME' THEN
		 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,60);
		 RETURN l_emp_acc_name ;
		ELSIF p_identifier_name = 'PAYEE_BANK_ACCOUNT_NUMBER' THEN
		 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,70);
		 RETURN l_emp_acc_num;
		ELSIF p_identifier_name = 'PAYEE_BANK_BRANCH' THEN
		 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,80);
		 RETURN l_emp_branch;
		ELSIF p_identifier_name = 'PAYEE_BANK_NAME' THEN
                 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,90);
		 RETURN l_emp_bank;
		ELSIF p_identifier_name = 'TRANSACTION_DATE' THEN
                 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,100);
		 RETURN TO_CHAR(TO_DATE(l_payment_date),'yyyy/mon/dd');
		ELSIF p_identifier_name = 'TRANSACTION_GROUP' THEN
                 pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,110);
		 RETURN p_payroll_action_id ;
		END IF ;



	EXCEPTION
	WHEN OTHERS THEN
	      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR',
              'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
              pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 120);
              RAISE ;
	END batch_transaction_identifiers ;

END pay_in_trx_identifiers ;

/
