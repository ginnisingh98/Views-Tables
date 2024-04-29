--------------------------------------------------------
--  DDL for Package Body PAY_ZA_EFT_RECONCILIATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_ZA_EFT_RECONCILIATION" AS
--  /* $Header: pyzaeftrecn.pkb 120.0.12010000.1 2009/07/28 09:29:02 dchindar noship $ */
--

FUNCTION get_eft_recon_data    (p_effective_date	DATE,
			        p_identifier_name       VARCHAR2,
			        p_payroll_action_id	NUMBER,
				p_payment_type_id	NUMBER,
				p_org_payment_method_id	NUMBER,
				p_personal_payment_method_id	NUMBER,
				p_assignment_action_id	NUMBER,
				p_pre_payment_id	NUMBER,
				p_delimiter_string   	VARCHAR2)
 RETURN VARCHAR2
 IS

   CURSOR c_get_trx_date
   IS
     Select to_char(nvl(ppa.overriding_dd_date, nvl(ptp.default_dd_date, ptp.end_date)), 'YYYY/MM/DD')
     from pay_assignment_actions paa,
          pay_pre_payments       ppp,
          pay_assignment_actions paa2,
          pay_payroll_actions    ppa,
          per_time_periods       ptp
     where paa.assignment_action_id = p_assignment_action_id
     and paa.PRE_PAYMENT_ID = ppp.PRE_PAYMENT_ID
     and paa2.assignment_action_id  = ( select max(locked_action_id)
                                        from pay_action_interlocks pai
                                        where pai.locking_action_id = ppp.assignment_action_id
                                       )
    and paa2.payroll_action_id     = ppa.payroll_action_id
    and ppa.time_period_id        = ptp.time_period_id;


    CURSOR get_acb_code (p_effective_date date) IS
    select SEGMENT2
    from pay_payrolls_f PPF,
        PAY_PAYROLL_ACTIONS PPA,
        hr_soft_coding_keyflex SOK
    where PPA.payroll_action_id =  p_payroll_action_id
    and PPA.payroll_id = PPF.payroll_id
    and PPF.SOFT_CODING_KEYFLEX_ID = SOK.SOFT_CODING_KEYFLEX_ID
    and p_effective_date between ppf.EFFECTIVE_START_DATE and ppf.EFFECTIVE_END_DATE;


    CURSOR org_payment_method_acc_no(p_effective_date date) IS
    select SEGMENT3
    from PAY_ORG_PAYMENT_METHODS_F OPM,
         PAY_EXTERNAL_ACCOUNTS PEA
    where OPM.ORG_PAYMENT_METHOD_ID = p_org_payment_method_id
    and   OPM.EXTERNAL_ACCOUNT_ID = PEA.EXTERNAL_ACCOUNT_ID
    and p_effective_date between OPM.EFFECTIVE_START_DATE and OPM.EFFECTIVE_END_DATE;


     cursor acb_effective_date IS
     select ppa.effective_date
     from pay_assignment_actions paa,
          pay_pre_payments       ppp,
          pay_assignment_actions paa2,
          pay_payroll_actions    ppa
     where paa.assignment_action_id = p_assignment_action_id
     and paa.PRE_PAYMENT_ID = ppp.PRE_PAYMENT_ID
     and paa2.assignment_action_id  = ( select max(locked_action_id)
                                        from pay_action_interlocks pai
                                        where pai.locking_action_id = ppp.assignment_action_id
                                       )
      and paa2.payroll_action_id     = ppa.payroll_action_id;

   CURSOR inst_code_and_type IS
   select  substr(hoi.org_information1, 1, 80),
           substr(hoi.org_information2, 1, 80)
   from   pay_payroll_actions         ppa,
          hr_organization_information hoi,
          hr_organization_units       hou
   where  ppa.payroll_action_id = p_payroll_action_id
   and    hou.organization_id = ppa.business_group_id
   and    hoi.organization_id = hou.organization_id
   and    hoi.org_information_context = 'ZA_ACB_INFORMATION';



l_usr_fnc_name        VARCHAR2(100) := NULL;
l_business_grp_id     NUMBER;
l_acb_code            VARCHAR2(30);
l_gen_number          VARCHAR2(30);
l_acc_number          VARCHAR2(30);
l_return_value        varchar2(30);
l_effective_date      date;
l_inst_code           VARCHAR2(30);
l_acb_user_type       VARCHAR2(30);


 BEGIN

   SELECT BUSINESS_GROUP_ID
	 INTO l_business_grp_id
	 FROM pay_payroll_actions
   WHERE PAYROLL_ACTION_ID = p_payroll_action_id;


    Select hruserdt.get_table_value(l_business_grp_id,
                                   'ZA_EFT_RECONC_FUNC',
          	                   'RECONCILIATION',
				   'FUNCTION NAME',
                                   p_effective_date)
    Into l_usr_fnc_name
    From dual;

    IF l_usr_fnc_name IS NOT NULL  then

	  EXECUTE IMMEDIATE 'select '||l_usr_fnc_name||'(:1,:2,:3,:4,:5,:6,:7,:8,:9) from dual'
	  INTO l_return_value
	  USING p_effective_date ,
                p_identifier_name,
	        p_payroll_action_id,
		p_payment_type_id,
		p_org_payment_method_id,
		p_personal_payment_method_id,
		p_assignment_action_id,
		p_pre_payment_id,
		p_delimiter_string ;

         IF UPPER(p_identifier_name) = 'TRANSACTION_DATE'  THEN
             begin
              l_return_value := to_char(to_date(l_return_value, 'YYYY/MM/DD'), 'YYYY/MM/DD');
             EXCEPTION
             WHEN others THEN
             raise_application_error(-20001, 'Transaction Date must be in YYYY/MM/DD format.');
             END;
         END IF;


	 ELSE

	     IF UPPER(p_identifier_name) = 'TRANSACTION_DATE'  THEN

	         OPEN c_get_trx_date;
    	     FETCH c_get_trx_date INTO l_return_value;
           CLOSE c_get_trx_date;

       ELSIF UPPER(p_identifier_name) = 'TRANSACTION_GROUP' THEN

	         l_return_value := p_payroll_action_id;

       ELSIF UPPER(p_identifier_name) = 'CONCATENATED_IDENTIFIERS'  THEN

       OPEN acb_effective_date;
       FETCH acb_effective_date INTO l_effective_date;
       CLOSE acb_effective_date;

	     OPEN get_acb_code(l_effective_date);
	     FETCH get_acb_code INTO l_acb_code;
	     CLOSE get_acb_code;

       OPEN inst_code_and_type;
       FETCH inst_code_and_type INTO l_inst_code, l_acb_user_type;
       CLOSE inst_code_and_type;

       IF l_acb_user_type = 'S' THEN
          SELECT GEN_NUMBER INTO l_gen_number
          FROM PAY_ZA_ACB_USER_GEN_NOS
          WHERE PAYROLL_ACTION_ID = p_payroll_action_id
          AND  USER_CODE  =  l_inst_code;
       else
          SELECT GEN_NUMBER INTO l_gen_number
          FROM PAY_ZA_ACB_USER_GEN_NOS
          WHERE PAYROLL_ACTION_ID = p_payroll_action_id
          AND  USER_CODE  =  l_acb_code;
       END IF;


	     OPEN org_payment_method_acc_no(l_effective_date);
	     FETCH org_payment_method_acc_no INTO l_acc_number;
	     CLOSE org_payment_method_acc_no;

	     l_return_value := l_gen_number||p_delimiter_string||l_acb_code||p_delimiter_string||l_acc_number||p_delimiter_string||'ACB';

             END IF;
         END IF;

   RETURN l_return_value;
EXCEPTION
WHEN OTHERS THEN
 RAISE;
END get_eft_recon_data;

END PAY_ZA_EFT_RECONCILIATION;


/
