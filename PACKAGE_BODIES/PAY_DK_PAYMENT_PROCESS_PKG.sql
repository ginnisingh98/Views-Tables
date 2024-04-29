--------------------------------------------------------
--  DDL for Package Body PAY_DK_PAYMENT_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_PAYMENT_PROCESS_PKG" as
/* $Header: pydkpaypr.pkb 120.18.12010000.6 2010/03/05 11:41:32 rsahai ship $ */

--Global parameters
 g_package                  CONSTANT varchar2(33) := 'PAY_DK_PAYMENT_PROCESS_PKG.';


/* Added for bug fix 8501177 */
FUNCTION get_Assignment_Action (
      p_assignment_id   NUMBER
   )
      RETURN NUMBER
   AS
     CURSOR csr_asg_act_id
      IS
SELECT max(paa.ASSIGNMENT_ACTION_ID)
  FROM   pay_payroll_actions            ppa
       , pay_assignment_actions         paa
  WHERE  paa.assignment_id = p_assignment_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    paa.action_status = 'C'
  AND    ppa.action_type IN('R','Q','I','B','V','P','U');

      l_asg_action_id   pay_assignment_actions.ASSIGNMENT_ACTION_ID%TYPE;
   BEGIN
      OPEN csr_asg_act_id;
      FETCH csr_asg_act_id INTO l_asg_action_id;
      CLOSE csr_asg_act_id;

      RETURN l_asg_action_id;

   END get_Assignment_Action;


   FUNCTION get_defined_balance_id (
      p_dimension_name   VARCHAR2,
      p_balance_name     VARCHAR2
   )
      RETURN NUMBER
   AS
      CURSOR csr_defined_balance_id
      IS
         SELECT pdb.defined_balance_id
           FROM pay_balance_dimensions pbd,
                pay_balance_types pbt,
                pay_defined_balances pdb
          WHERE pbd.dimension_name = p_dimension_name
            AND pbd.business_group_id IS NULL
            AND pbd.legislation_code = 'DK'
            AND pbt.balance_name = p_balance_name
            AND pbt.business_group_id IS NULL
            AND pbt.legislation_code = 'DK'
            AND pdb.balance_type_id = pbt.balance_type_id
            AND pdb.balance_dimension_id = pbd.balance_dimension_id
            AND pdb.business_group_id IS NULL
            AND pdb.legislation_code = 'DK';

      l_defined_balance_id   pay_defined_balances.defined_balance_id%TYPE;
   BEGIN
      OPEN csr_defined_balance_id;
      FETCH csr_defined_balance_id INTO l_defined_balance_id;
      CLOSE csr_defined_balance_id;
      RETURN l_defined_balance_id;
   END get_defined_balance_id;
/* Added for bug fix 8501177 */

 -----------------------------------------------------------------------------
 -- GET_PARAMETER  used in SQL to decode legislative parameters
 -----------------------------------------------------------------------------
 FUNCTION get_parameter(
                 p_parameter_string  IN VARCHAR2
                ,p_token             IN VARCHAR2
                ,p_segment_number    IN NUMBER DEFAULT NULL ) RETURN VARCHAR2
 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  varchar2(1);
   l_proc VARCHAR2(60);
 BEGIN
   l_delimiter :=' ';
   l_proc := g_package||' get parameter ';

   l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   IF l_start_pos = 0 THEN
     l_delimiter := '|';
     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
   end if;
   IF l_start_pos <> 0 THEN
     l_start_pos := l_start_pos + length(p_token||'=');
     l_parameter := substr(p_parameter_string,
                           l_start_pos,
                           instr(p_parameter_string||' ',
                           ',',l_start_pos)
                           - l_start_pos);
     IF p_segment_number IS NOT NULL THEN
       l_parameter := ':'||l_parameter||':';
       l_parameter := substr(l_parameter,
                             instr(l_parameter,':',1,p_segment_number)+1,
                             instr(l_parameter,':',1,p_segment_number+1) -1
                             - instr(l_parameter,':',1,p_segment_number));
     END IF;
   END IF;
   RETURN l_parameter;
 END get_parameter;

-----------------------------------------------------------------------------
 -- GET_LOOKUP_MEANING function used to get labels of items from a lookup
-----------------------------------------------------------------------------
  FUNCTION get_lookup_meaning (p_lookup_type varchar2,p_lookup_code varchar2) RETURN VARCHAR2 IS
    CURSOR csr_lookup IS
    select meaning
    from   hr_lookups
    where  lookup_type = p_lookup_type
    and    lookup_code = p_lookup_code
    and    enabled_flag ='Y';
    l_meaning hr_lookups.meaning%type;
  BEGIN
    OPEN csr_lookup;
    FETCH csr_lookup INTO l_Meaning;
    CLOSE csr_lookup;
    RETURN l_meaning;
  END get_lookup_meaning;

/* Added the following for Third Party Payments */

  FUNCTION get_ass_action_context(p_assignment_id NUMBER) RETURN NUMBER IS
  l_context NUMBER;

  CURSOR get_context(p_assignment_id NUMBER) IS
  SELECT max(paa.ASSIGNMENT_ACTION_ID)
  FROM   pay_payroll_actions            ppa
       , pay_assignment_actions         paa
  WHERE  paa.assignment_id = p_assignment_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    ppa.action_type IN('P','U');

  BEGIN

  OPEN get_context(p_assignment_id);
  FETCH get_context INTO l_context;
  CLOSE get_context;

  RETURN l_context;

  END  get_ass_action_context;
  --
  --
  FUNCTION get_date_earned_context(p_assignment_id NUMBER) RETURN DATE IS
  l_context DATE;
   /* Added nvl for bug 5879516 */
  CURSOR get_context(p_assignment_id NUMBER) IS
  SELECT max(ppa.DATE_EARNED)
  FROM   pay_payroll_actions            ppa
       , pay_assignment_actions         paa
  WHERE  paa.assignment_id = p_assignment_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    ppa.action_type IN('P','U');

  /*Added for bug 5930673 */
   Cursor get_alternate_date_earned (p_assignment_id NUMBER) IS
  SELECT max(nvl(ppa.date_earned,ppar.date_earned))
  FROM   pay_payroll_actions            ppa
       , pay_assignment_actions         paa
       , pay_action_interlocks          pail
       , pay_payroll_actions            ppar
       , pay_assignment_actions         paar
  WHERE  paa.assignment_id = p_assignment_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    paar.assignment_action_id = pail.locked_action_id
  AND    pail.locking_action_id = paa.assignment_action_id
  AND    paar.payroll_action_id = ppar.payroll_action_id
  AND    ppa.action_type IN('P','U')
  AND    ppar.action_type IN('Q','R');

  BEGIN

  OPEN get_context(p_assignment_id);
  FETCH get_context INTO l_context;
  CLOSE get_context;
   /*Added for bug 5930673 */
  If l_context is null then
      OPEN get_alternate_date_earned(p_assignment_id);
      FETCH get_alternate_date_earned INTO l_context;
      CLOSE get_alternate_date_earned;
  End if;

  RETURN l_context;

  END  get_date_earned_context;
  --
  --
  /* Added p_org_id to function and modified dimension from _PAYMENTS to _PP_PAYMENTS for pension changes.
     Also changed call to pay_balance_pkg.get_value */
  FUNCTION get_prev_bal_paid(p_assignment_id NUMBER,p_org_id NUMBER, p_balance_name VARCHAR2) RETURN NUMBER IS
  l_context1 NUMBER;
  l_context2 NUMBER;
  l_value    NUMBER;

  CURSOR get_ass_action_id(p_assignment_id NUMBER) IS
  SELECT ppp.assignment_action_id
  FROM   pay_payroll_actions            ppa
       , pay_assignment_actions         paa
       , pay_action_interlocks          pai
       , pay_pre_payments               ppp
  WHERE  paa.assignment_id = p_assignment_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    ppa.action_type = 'M'
  AND    ppa.action_status = 'C'
  AND    paa.action_status = 'C'
  AND    paa.pre_payment_id = ppp.pre_payment_id
  AND    pai.locking_action_id = paa.assignment_action_id
  AND    pai.locked_action_id = ppp.assignment_action_id;


/* Modified for pension changes */
  CURSOR get_def_bal_id(p_balance_name VARCHAR2) IS
  SELECT pdb.defined_balance_id
  FROM   pay_defined_balances  pdb
        ,pay_balance_types  pbt
        ,pay_balance_dimensions  pbd
  WHERE  pbt.legislation_code='DK'
  AND    pbt.balance_name = p_balance_name
  AND    pbd.legislation_code = 'DK'
  --AND    pbd.database_item_suffix = '_PAYMENTS'
  AND    pbd.database_item_suffix = '_PP_PAYMENTS'
  AND    pdb.balance_type_id = pbt.balance_type_id
  AND    pdb.balance_dimension_id = pbd.balance_dimension_id;


  BEGIN

  OPEN get_ass_action_id(p_assignment_id);
  FETCH get_ass_action_id INTO l_context1;
  CLOSE get_ass_action_id;

  OPEN get_def_bal_id(p_balance_name);
  FETCH get_def_bal_id INTO l_context2;
  CLOSE get_def_bal_id;

  --l_value := pay_balance_pkg.get_value(l_context2,l_context1);
  l_value := pay_balance_pkg.get_value(l_context2,l_context1,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,p_org_id);

  RETURN l_value;

  END  get_prev_bal_paid;
  --
  --
 /* FUNCTION get_prev_date_earned_context(p_assignment_id NUMBER) RETURN DATE IS
  l_context DATE;

  CURSOR get_context(p_assignment_id NUMBER) IS
  SELECT ppa.date_earned
  FROM   pay_payroll_actions            ppa
       , pay_assignment_actions         paa
       , pay_action_interlocks          pai
  WHERE  paa.assignment_id = p_assignment_id
  AND    paa.payroll_action_id = ppa.payroll_action_id
  AND    ppa.action_type = 'M'
  AND    pai.locking_action_id = paa.assignment_action_id
  AND    pai.locked_action_id = get_ass_action_context(p_assignment_id);

  BEGIN

  OPEN get_context(p_assignment_id);
  FETCH get_context INTO l_context;
  CLOSE get_context;

  RETURN l_context;

  END  get_prev_date_earned_context; */
  --
  --
  FUNCTION get_phy_record_no(p_person_id NUMBER, p_assignment_id NUMBER, p_pp_id VARCHAR2) RETURN NUMBER IS

/* Cursor for Record I 05 and I 04 re-written as parameters TRANSFER_PERSON_ID and TRANSFER_ASSIGNMENT_ID
   not available in memory for the first fetch */

        CURSOR get_is_record_05_details_local(p_person_id NUMBER) IS
	SELECT  '1'
	FROM  per_addresses   pad
	      /* Modified for bug fix 4593682 */
	    , per_all_people_f  pap
	    , pay_payroll_actions ppa
	WHERE /*pad.person_id = p_person_id*/
	      pad.person_id (+)= pap.person_id
	AND pad.primary_flag = 'Y' --9403004
	AND ppa.effective_date  BETWEEN nvl(pad.date_from,ppa.effective_date) AND nvl(pad.date_to,to_date('31-12-4712','dd-mm-rrrr')) --9403004
	AND   pap.person_id = p_person_id
	AND   pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
	      /* Modified for bug fix 7664874 */
	AND   ppa.payroll_action_id=pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
	AND   ppa.effective_date BETWEEN pap.effective_start_date AND pap.effective_end_date;


/* Modified for Pension changes to restrict on Pension Provider*/
        CURSOR get_is_record_04_details_local(p_assignment_id NUMBER,p_pp_id VARCHAR2) IS
         SELECT '1'
         FROM    pay_run_results                prr1
               , pay_run_result_values          prrv1
               , pay_run_result_values          prrv3
               , pay_element_types_f            pet1
               , pay_input_values_f             piv1
               , pay_input_values_f             piv3
               , pay_run_results                prr2
               , pay_run_result_values          prrv2
               , pay_run_result_values          prrv4
               , pay_element_types_f            pet2
               , pay_input_values_f             piv2
               , pay_input_values_f             piv4
               , pay_assignment_actions         paa
               , pay_payroll_actions            ppa
               , pay_element_entries_f          pee
         WHERE ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
         AND   prr1.ELEMENT_TYPE_ID = pet1.ELEMENT_TYPE_ID
         AND   prrv1.RUN_RESULT_ID = prr1.RUN_RESULT_ID
         AND   prrv3.RUN_RESULT_ID = prr1.RUN_RESULT_ID
         AND   pee.ELEMENT_ENTRY_ID = prr1.ELEMENT_ENTRY_ID
         AND   pet1.element_name  = 'Retro Pension'
         AND   pet1.legislation_code ='DK'
         AND   piv1.ELEMENT_TYPE_ID = pet1.element_type_id
         AND   piv1.NAME ='Pay Value'
         AND   prrv1.input_value_id = piv1.input_value_id
	 AND   piv3.ELEMENT_TYPE_ID = pet1.element_type_id
	 AND   piv3.NAME ='Third Party Payee'
	 AND   prrv3.input_value_id = piv3.input_value_id
	 AND   prrv3.RESULT_VALUE = p_pp_id
         AND   prr2.ELEMENT_TYPE_ID =pet2.ELEMENT_TYPE_ID
         AND   prrv2.RUN_RESULT_ID = prr2.RUN_RESULT_ID
	 AND   prrv4.RUN_RESULT_ID = prr2.RUN_RESULT_ID
	 AND   prrv4.RESULT_VALUE = prrv3.RESULT_VALUE
         AND   pet2.element_name  = 'Retro Employer Pension'
         AND   pet2.legislation_code ='DK'
         AND   piv2.ELEMENT_TYPE_ID = pet2.element_type_id
         AND   piv2.NAME ='Pay Value'
         AND   prrv2.input_value_id = piv2.input_value_id
	 AND   piv4.ELEMENT_TYPE_ID = pet2.element_type_id
	 AND   piv4.NAME ='Third Party Payee'
	 AND   prrv4.input_value_id = piv4.input_value_id
	 AND   prrv4.RESULT_VALUE = p_pp_id
         AND   prr1.assignment_action_id = paa.assignment_action_id
         AND   prr1.assignment_action_id=prr2.assignment_action_id
         AND   prr1.start_date = prr2.start_date
         AND   prr1.end_date = prr2.end_date
         AND   pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
         AND   paa.assignment_id = p_assignment_id
         AND   ppa.effective_date BETWEEN pet1.effective_start_date and pet1.effective_end_date
         AND   ppa.effective_date BETWEEN pet2.effective_start_date and pet2.effective_end_date
         AND   ppa.effective_date BETWEEN piv1.effective_start_date and piv1.effective_end_date
         AND   ppa.effective_date BETWEEN piv2.effective_start_date and piv2.effective_end_date
	 AND   ppa.effective_date BETWEEN piv3.effective_start_date and piv3.effective_end_date
	 AND   ppa.effective_date BETWEEN piv4.effective_start_date and piv4.effective_end_date
         AND   ppa.effective_date BETWEEN pee.effective_start_date  and pee.effective_end_date;


   /* Cursors IS 01 to 03 also included and re-written as they too use TRANSFER_ASSIGNMENT_ID for bug fix 4567621 */

	CURSOR get_is_record_01_details_local IS
	SELECT   '1'
	FROM pay_payroll_actions		ppa
	   , pay_assignment_actions		paa
	   , pay_element_entries_f              pee1
	   , pay_element_types_f                pet
	   , pay_element_entries_f              pee2
	   , hr_organization_units              hou /*bug fix 4551283*/
	   /* Added for Pension changes */
	   , pay_input_values_f			pivf
	   , pay_element_entry_values_f		peev1
	   , pay_element_entry_values_f		peev2
	WHERE  ppa.payroll_action_id = pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    pee1.assignment_id = paa.assignment_id
	AND    pet.element_name  = 'Pension'
	AND    pet.legislation_code ='DK'
	AND    pee1.entry_type ='E'
	AND    pee1.element_type_id = pet.element_type_id
	AND    pee2.assignment_id = paa.assignment_id
	AND    pee2.entry_type ='E'
	AND    pee2.element_type_id = pet.element_type_id
	/* Added for Pension changes -start */
	AND  pivf.element_type_id   = pet.element_type_id
	AND  pivf.name= 'Third Party Payee'
	AND  ppa.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
	AND  peev1.input_value_id = pivf.input_value_id
	AND  peev1.element_entry_id = pee1.element_entry_id
	AND  peev1.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
	AND  peev2.input_value_id = pivf.input_value_id
	AND  peev2.element_entry_id = pee2.element_entry_id
	AND  peev2.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
	/* Added for Pension changes -end */
	AND    paa.assignment_id = p_assignment_id
	AND    ppa.effective_date BETWEEN pet.effective_start_date and pet.effective_end_date
	AND    ppa.effective_date BETWEEN pee1.effective_start_date and pee1.effective_end_date
	AND    pee1.effective_start_date >= ppa.start_date
	AND    pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
	AND    hou.organization_id = pay_magtape_generic.get_parameter_value('TRANSFER_LE_ID') /*bug fix 4551283*/
	AND    ppa.effective_date  BETWEEN  hou.date_from AND nvl(hou.date_to, ppa.effective_date) /*bug fix 4551283*/
	GROUP BY pee1.effective_start_date,paa.assignment_id,pee1.element_entry_id,pet.element_type_id,hou.name;



	CURSOR get_is_record_02_details_local IS
	SELECT   '1'
	FROM pay_payroll_actions		ppa
	   , pay_assignment_actions		paa
	   , pay_element_entries_f              pee1
	   , pay_element_types_f                pet
	   , pay_element_entries_f              pee2
	      /* Added for Pension changes */
	   , pay_input_values_f			pivf
	   , pay_element_entry_values_f		peev1
	   , pay_element_entry_values_f		peev2
	WHERE  ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    pee1.assignment_id = paa.assignment_id
	AND    pet.element_name  = 'Pension'
	AND    pet.legislation_code ='DK'
	AND    pee1.entry_type ='E'
	AND    pee1.element_type_id = pet.element_type_id
	AND    pee2.assignment_id = paa.assignment_id
	AND    pee2.entry_type ='E'
	AND    pee2.element_type_id = pet.element_type_id
	/* Added for Pension changes -start */
	AND  pivf.element_type_id   = pet.element_type_id
	AND  pivf.name= 'Third Party Payee'
	AND  ppa.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
	AND  peev1.input_value_id = pivf.input_value_id
	AND  peev1.element_entry_id = pee1.element_entry_id
	AND  peev1.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
	AND  peev2.input_value_id = pivf.input_value_id
	AND  peev2.element_entry_id = pee2.element_entry_id
	AND  peev2.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
	/* Added for Pension changes -end */
	AND    paa.assignment_id = p_assignment_id
	AND    pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
	AND    ppa.effective_date BETWEEN pet.effective_start_date and pet.effective_end_date
	AND    ppa.effective_date BETWEEN pee1.effective_start_date and pee1.effective_end_date
	AND 1=2
	GROUP BY pee1.effective_start_date,paa.assignment_id,pee1.element_entry_id,pet.element_type_id;


	CURSOR get_is_record_03_details_local IS
	SELECT  '1'
	FROM pay_payroll_actions		ppa
	   , pay_assignment_actions		paa
	   , pay_element_entries_f              pee1
	   , pay_element_types_f                pet
	   , pay_element_entries_f              pee2
	   /* Added for Pension changes */
	   , pay_input_values_f			pivf
	   , pay_element_entry_values_f		peev1
	   , pay_element_entry_values_f		peev2
	WHERE  ppa.payroll_action_id =  pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID')
	AND    paa.payroll_action_id = ppa.payroll_action_id
	AND    pee1.assignment_id = paa.assignment_id
	AND    pet.element_name  = 'Pension'
	AND    pet.legislation_code ='DK'
	AND    pee1.entry_type ='E'
	AND    pee1.element_type_id = pet.element_type_id
	AND    pee2.assignment_id = paa.assignment_id
	AND    pee2.entry_type ='E'
	AND    pee2.element_type_id = pet.element_type_id
	/* Added for Pension changes -start */
	AND  pivf.element_type_id   = pet.element_type_id
	AND  pivf.name= 'Third Party Payee'
	AND  ppa.effective_date BETWEEN pivf.effective_start_date AND pivf.effective_end_date
	AND  peev1.input_value_id = pivf.input_value_id
	AND  peev1.element_entry_id = pee1.element_entry_id
	AND  peev1.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
	AND  peev2.input_value_id = pivf.input_value_id
	AND  peev2.element_entry_id = pee2.element_entry_id
	AND  peev2.screen_entry_value = PAY_DK_PAYMENT_PROCESS_PKG.get_pension_provider(pay_magtape_generic.get_parameter_value('TRANSFER_RECEIVER_NAME'))
	/* Added for Pension changes -end */
	AND    pee2.effective_start_date < ppa.start_date
	AND    paa.assignment_id = p_assignment_id
	AND    pay_magtape_generic.get_parameter_value('TRANSFER_INFO_TYPE') NOT IN (300, 400, 800, 900)
	AND    ppa.effective_date BETWEEN pet.effective_start_date and pet.effective_end_date
	AND    ppa.effective_date BETWEEN pee1.effective_start_date and pee1.effective_end_date
	AND 1=2
	GROUP BY pee1.effective_start_date,paa.assignment_id,pee1.element_entry_id,pet.element_type_id;




  l_count NUMBER;
  l_count_04 NUMBER;
  l_c01   get_is_record_01_details_local%ROWTYPE;
  l_c02   get_is_record_02_details_local%ROWTYPE;
  l_c03   get_is_record_03_details_local%ROWTYPE;
  l_c04   get_is_record_04_details_local%ROWTYPE;
  l_c05   get_is_record_05_details_local%ROWTYPE;

  BEGIN

  l_count :=0;
  l_count_04 :=0;

  OPEN get_is_record_01_details_local;
  LOOP
   FETCH get_is_record_01_details_local INTO l_c01;
   IF get_is_record_01_details_local%FOUND THEN
     l_count := l_count +1;
   ELSE
      EXIT;
   END IF;
  END LOOP;
  CLOSE get_is_record_01_details_local;

  OPEN get_is_record_02_details_local;
  LOOP
   FETCH get_is_record_02_details_local INTO l_c02;
   IF get_is_record_02_details_local%FOUND THEN
     l_count := l_count +1;
   ELSE
      EXIT;
   END IF;
  END LOOP;
  CLOSE get_is_record_02_details_local;

  OPEN get_is_record_03_details_local;
  LOOP
   FETCH get_is_record_03_details_local INTO l_c03;
   IF get_is_record_03_details_local%FOUND THEN
     l_count := l_count +1;
   ELSE
      EXIT;
   END IF;
  END LOOP;
  CLOSE get_is_record_03_details_local;

  /* Modified for Pension Changes */
  OPEN get_is_record_04_details_local(p_assignment_id, p_pp_id);
  LOOP
   FETCH get_is_record_04_details_local INTO l_c04;
   IF get_is_record_04_details_local%FOUND THEN
   /* Added to rectify count for OSI04 */
   l_count_04 := l_count_04 +1;
   ELSE
      EXIT;
   END IF;
  END LOOP;
  CLOSE get_is_record_04_details_local;
  /* Rectified count for OSI04 */
  l_count := l_count + CEIL(l_count_04/3);

  OPEN get_is_record_05_details_local(p_person_id);
  LOOP
   FETCH get_is_record_05_details_local INTO l_c05;
   IF get_is_record_05_details_local%FOUND THEN
     l_count := l_count +1;
   ELSE
      EXIT;
   END IF;
  END LOOP;
  CLOSE get_is_record_05_details_local;

/* For bug fix 4567621 */
  RETURN l_count+1 ;

  END  get_phy_record_no;

/* Added for bug fix 4563148 */
 FUNCTION check_numeric(p_text VARCHAR2) RETURN NUMBER IS
 l_return  NUMBER;
 l_convert NUMBER;
 BEGIN
 l_return := 0;
 l_convert := to_number(p_text);
 RETURN l_return;

 EXCEPTION
 WHEN value_error
 THEN  l_return := 1;
 /* Added return here */
 RETURN l_return;


 END check_numeric;

FUNCTION get_pension_provider(p_org_name VARCHAR2) RETURN VARCHAR2 IS
l_org_id NUMBER;

CURSOR get_org_id( p_org_name VARCHAR2 ) IS
SELECT to_char(hou.organization_id)
FROM hr_organization_units hou
WHERE hou.name  = p_org_name;

BEGIN

OPEN get_org_id(p_org_name);
FETCH get_org_id INTO l_org_id;
CLOSE get_org_id;

RETURN l_org_id;

END get_pension_provider;


/* Function to fetch EIT details from BG for Identification Codes */
FUNCTION get_ident_codes(p_bg_id               IN  NUMBER
                        ,p_effective_date      IN DATE
			,p_tax_rc              OUT NOCOPY VARCHAR2
			,p_amb_rc              OUT NOCOPY VARCHAR2
			,p_sp_rc               OUT NOCOPY VARCHAR2
			,p_hol_days_rc         OUT NOCOPY VARCHAR2) RETURN NUMBER IS
l_return NUMBER;

/* Cursor to fetch the Business Group Details */
CURSOR csr_get_bg_details(p_business_group_id NUMBER, p_effective_date DATE) IS
SELECT hoi2.ORG_INFORMATION2  TAX_RC
      ,hoi2.ORG_INFORMATION3  AMB_RC
      ,hoi2.ORG_INFORMATION4  SP_RC
      ,hoi2.ORG_INFORMATION5  HOL_DAYS_RC
FROM HR_ORGANIZATION_UNITS hou
   , HR_ORGANIZATION_INFORMATION hoi1
   , HR_ORGANIZATION_INFORMATION hoi2
WHERE hou.business_group_id =  p_business_group_id
and hoi1.organization_id = hou.organization_id
and hoi1.organization_id = p_business_group_id
and hoi1.ORG_INFORMATION_CONTEXT='CLASS'
and hoi1.org_information1 = 'HR_BG'
and hoi1.ORG_INFORMATION2 = 'Y'
and hoi2.ORG_INFORMATION_CONTEXT='DK_IDENTIFICATION_CODES'
and hoi2.organization_id =  hoi1.organization_id
and p_effective_date BETWEEN hou.DATE_FROM and nvl(hou.DATE_TO, p_effective_date);

rec_get_bg_details csr_get_bg_details%ROWTYPE;

BEGIN

l_return :=1;

OPEN csr_get_bg_details(p_bg_id, fnd_date.displaydt_to_date(p_effective_date));
FETCH csr_get_bg_details INTO rec_get_bg_details;
CLOSE csr_get_bg_details;

p_tax_rc       := rec_get_bg_details.tax_rc;
p_amb_rc       := rec_get_bg_details.amb_rc;
p_sp_rc        := rec_get_bg_details.sp_rc;
p_hol_days_rc  := rec_get_bg_details.hol_days_rc;

RETURN l_return;

END get_ident_codes;

/* Added to support multiple pensions for OSI02 for bug fix 5563150*/
FUNCTION get_pen_values(p_eff_date DATE,p_ele_type_id NUMBER, p_ee_id NUMBER, p_iv_name VARCHAR2) RETURN VARCHAR2 IS

CURSOR csr_get_pen_values(p_eff_date DATE, p_ee_id NUMBER, p_iv_id NUMBER) IS
SELECT nvl(screen_entry_value,0)
FROM pay_element_entry_values_f
WHERE element_entry_id = p_ee_id
AND input_value_id  = p_iv_id
AND p_eff_date BETWEEN effective_start_date and effective_end_date ;

CURSOR csr_get_iv_id(p_ele_type_id NUMBER,p_iv_name VARCHAR2, p_eff_date DATE) IS
SELECT input_value_id
FROM pay_input_values_f
WHERE name = p_iv_name
AND element_type_id = p_ele_type_id
AND legislation_code ='DK'
AND p_eff_date BETWEEN effective_start_date and effective_end_date ;

l_iv_id NUMBER;
l_result_value VARCHAR2(80);

BEGIN
OPEN csr_get_iv_id(p_ele_type_id,p_iv_name,p_eff_date);
FETCH csr_get_iv_id INTO l_iv_id;
CLOSE csr_get_iv_id;

IF l_iv_id IS NOT NULL THEN
OPEN csr_get_pen_values(p_eff_date,p_ee_id,l_iv_id);
FETCH csr_get_pen_values INTO l_result_value;
CLOSE csr_get_pen_values;
END IF;

RETURN l_result_value;

END get_pen_values;


/* Added to support override for Use of Holiday Card for transfer to Holiday Bank for bug fix 5533140*/
FUNCTION get_use_hol_card(p_payroll_action_id NUMBER,p_date_earned DATE ) RETURN VARCHAR2
IS

l_value  PER_TIME_PERIODS.PRD_INFORMATION2%TYPE;
l_payroll_id NUMBER;

/* Modified the cursor for bug 5533140*/

CURSOR get_value_from_ddf(p_payroll_id NUMBER , p_date_earned DATE) IS
SELECT PRL_INFORMATION1
    FROM pay_payrolls_f ppf
    WHERE PAYROLL_ID =  p_payroll_id
  AND p_date_earned BETWEEN ppf.EFFECTIVE_START_DATE AND ppf.EFFECTIVE_END_DATE;

CURSOR get_payroll_id (p_payroll_action_id NUMBER )  IS
  SELECT PAYROLL_ID
  FROM PAY_PAYROLL_ACTIONS ppa
  WHERE payroll_action_id = p_payroll_action_id;


BEGIN

  OPEN get_payroll_id(p_payroll_action_id);
  FETCH get_payroll_id INTO l_payroll_id;
  CLOSE get_payroll_id;

  OPEN get_value_from_ddf(l_payroll_id, p_date_earned);
  FETCH get_value_from_ddf INTO l_value;
  CLOSE get_value_from_ddf;

  RETURN l_value;

END  get_use_hol_card;

FUNCTION get_pay_period_per_year(p_payroll_action_id NUMBER,p_date_earned DATE ) RETURN NUMBER
IS
	Cursor csr_pay_period (p_payroll_action_id NUMBER , p_date_earned DATE) is
	Select
	TPTYPE.number_per_fiscal_year
	from
		pay_payroll_actions                      PACTION
	,       per_time_periods                         TPERIOD
	,       per_time_period_types                    TPTYPE
	where   PACTION.payroll_action_id              = p_payroll_action_id
	and     TPERIOD.payroll_id                 = PACTION.payroll_id
	and    p_date_earned  between TPERIOD.start_date and TPERIOD.end_date
	and     TPTYPE.period_type  = TPERIOD.period_type;

	l_period_per_year NUMBER;
BEGIN
	  OPEN csr_pay_period(p_payroll_action_id, p_date_earned);
	  FETCH csr_pay_period INTO l_period_per_year;
	  CLOSE csr_pay_period;

	  Return l_period_per_year;

END get_pay_period_per_year;

END PAY_DK_PAYMENT_PROCESS_PKG;

/
