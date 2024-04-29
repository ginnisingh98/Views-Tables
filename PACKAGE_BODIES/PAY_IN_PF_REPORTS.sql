--------------------------------------------------------
--  DDL for Package Body PAY_IN_PF_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_PF_REPORTS" AS
/* $Header: pyinmpfr.pkb 120.0.12010000.2 2009/01/08 06:21:21 mdubasi ship $ */

  ----------------------------------------------------------------------+
  --  global variables
  ----------------------------------------------------------------------+

  g_xml_data          CLOB;
  g_package           CONSTANT VARCHAR2(100) := 'pay_in_pf_reports.';
  g_template          VARCHAR2(100);
  g_debug             BOOLEAN ;
  g_bg_id             NUMBER;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : REPLACE_COMMA                                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This procedure formats the Data for the EFile       --
  --                                                                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_string                VARCHAR2                    --
  --            OUT : N/A                                                 --
  --    RETURN TYPE : VARCHAR2                                            --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  FUNCTION  replace_comma(p_string IN VARCHAR2)
  RETURN VARCHAR2
  IS
    l_procedure         VARCHAR2(100);
    l_string            PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE ;
  BEGIN

   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package ||'replace_comma';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    IF g_template = 'PAYINPFEF'
    THEN
      l_string := REPLACE(p_string,',',' ');
    ELSE
      l_string := p_string ;
    END IF ;
    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

    RETURN l_string;

  EXCEPTION
  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;
  END replace_comma;

 --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : FORMAT_NUMBER                                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : This procedure formats the Data for the Printed     --
  --                  Copy                                                --
  --                                                                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_number                  NUMBER                    --
  --            OUT : N/A                                                 --
  --    RETURN TYPE : VARCHAR2                                            --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  FUNCTION  format_number(p_number IN NUMBER )
  RETURN VARCHAR2
  IS
    l_procedure         VARCHAR2(100);
  BEGIN

   g_debug := hr_utility.debug_enabled;
   l_procedure := g_package ||'format_number';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_template = 'PAYINPFPC'
    THEN
      RETURN pay_us_employee_payslip_web.get_format_value(g_bg_id,p_number) ;
    ELSE
      RETURN p_number;
    END IF ;

    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION
  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;
  END format_number;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CREATE_LEVEL2_3_XML                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the level 2 and 3 Data       --
  --                  It generates the Employee Data i,e Personal Details,--
  --                  Employee Level Balances. It gets data from          --
  --                  PAY_ACTION_INFORMATION                              --
  --                  Context : IN_PF_PERSON_DTLS                         --
  --                            IN_PF_SALARY                              --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_number       VARCHAR2                    --
  --                  p_pf_arc_ref_no         VARCHAR2                    --
  --                  p_action_context_id     VARCHAR2                    --
  --                  p_year                  NUMBER                      --
  --                  p_month                 NUMBER                      --
  --                  p_nssn                  VARCHAR2                    --
  --                  p_sort_by               VARCHAR2                    --
  --            OUT : p_total_ncp             NUMBER                      --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  -- 115.1 16-Oct-2007    sivanara  For bug6504522 changed code to efile  --
  --                                Leaving reason                        --
  -- 115.2 01-Nov-2007    rsaharay  Modified for Bug#6603726              --
  --------------------------------------------------------------------------
  PROCEDURE create_level2_3_xml( p_business_number      IN  VARCHAR2  DEFAULT NULL
			        ,p_pf_arc_ref_no        IN  VARCHAR2  DEFAULT NULL
			        ,p_action_context_id    IN  VARCHAR2  DEFAULT NULL
			        ,p_year                 IN  NUMBER    DEFAULT NULL
			        ,p_month                IN  NUMBER    DEFAULT NULL
				,p_nssn                 IN  VARCHAR2  DEFAULT NULL
				,p_sort_by              IN  VARCHAR2  DEFAULT NULL
				,p_total_ncp            OUT NOCOPY NUMBER   )
  IS
  l_sys_date_time     VARCHAR2(40);
  l_tag               VARCHAR2(1000);
  l_procedure         VARCHAR2(100);
  l_hire_dd               NUMBER ;
  l_term_dd               NUMBER ;
  l_term_efile            PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE ;
  l_term_print_copy       PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE ;
  l_count                 NUMBER ;

  l_total_ncp             NUMBER ;
  l_total_pf_wages        NUMBER ;
  l_total_epf             NUMBER ;
  l_epf_admin             NUMBER ;
  l_eps_con               NUMBER ;
  l_edli_con              NUMBER ;
  l_edli_admin		  NUMBER ;
  l_epf_inspection	  NUMBER ;
  l_edli_inspection       NUMBER ;
  l_rec_overpay           NUMBER ;
  l_penal_int             NUMBER ;
  l_interest_on_sec       NUMBER ;
  l_legal_charges         NUMBER ;
  l_pup                   NUMBER ;
  l_penalty               NUMBER ;






   CURSOR csr_assignment
   IS
   SELECT    DISTINCT
             action_information4   pf_no
            ,action_information5   nssn
            ,action_information6   hire_date
            ,action_information7   emp_type
            ,action_information8   term_date
            ,action_information9   report_term_reason
            ,action_information10  efile_term_reason
            ,action_information11  eps
            ,action_information13  pf_class
	    ,action_context_id     assignment_action_id
   FROM      pay_action_information
   WHERE     action_information2         = p_pf_arc_ref_no
   AND       action_information1         = p_business_number
   AND       action_information3         = p_month||p_year
   AND       action_information_category = 'IN_PF_PERSON_DTLS'
   AND       action_context_type         = 'AAP'
   AND       DECODE(action_information5,NULL,'NO_NSSN','NSSN') LIKE  DECODE(p_nssn,'ALL','%',p_nssn)
   ORDER BY (DECODE(p_sort_by,'NSSN',action_information5,'DOJ',action_information6));


  /*Picked up based on the PF Classification Type
    An employee will have multiple rows in the report if he is present in multiple PF Orgs of
    different classifications under a Business Number.*/
  CURSOR csr_assignment_bal(p_action_context_id VARCHAR2 ,p_pf_class varchar2)
  IS
  SELECT   action_information3                                               bal_name
          ,SUM (fnd_number.canonical_to_number(action_information4))         bal_value
  FROM     pay_action_information pai
  WHERE    action_context_id           = p_action_context_id
  AND      action_information1         = p_business_number
  AND      action_information_category = 'IN_PF_SALARY'
  AND      action_context_type         = 'AAP'
  AND      action_information5         = p_pf_class
  GROUP BY action_information3;




   CURSOR csr_challan
   IS
   SELECT  SUM(fnd_number.canonical_to_number(action_information21))  Interest_on_Sec
          ,SUM(fnd_number.canonical_to_number(action_information22))  Legal_Charges
          ,SUM(fnd_number.canonical_to_number(action_information23))  Penalty
   FROM	(SELECT  DISTINCT
		 action_information21
	        ,action_information22
	        ,action_information23
	        ,action_information8
	 FROM 	 pay_action_information
	 WHERE   action_context_id           = p_action_context_id
	 AND     action_information1         = p_business_number
	 AND     action_information_category = 'IN_PF_CHALLAN'
	 AND     action_context_type         = 'PA');

  CURSOR csr_pup_total_amount
   IS
   SELECT  SUM(fnd_number.canonical_to_number(action_information7))  Payment_under_Protest
   FROM	(SELECT  DISTINCT
		 action_information7
	        ,action_information8
	 FROM 	 pay_action_information
	 WHERE   action_context_id           = p_action_context_id
	 AND     action_information1         = p_business_number
	 AND     action_information_category = 'IN_PF_CHALLAN'
	 AND     action_context_type         = 'PA'
	 AND     action_information20        = 'Y');


  BEGIN
        g_debug := hr_utility.debug_enabled;
        l_procedure := g_package ||'create_level2_3_xml';
        pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

	l_total_pf_wages      := 0;
        l_total_epf           := 0;
	l_epf_admin           := 0;
	l_eps_con             := 0;
	l_edli_con            := 0;
	l_edli_admin	      := 0;
	l_epf_inspection      := 0;
	l_edli_inspection     := 0;
	l_rec_overpay         := 0;
	l_penal_int           := 0;
        l_interest_on_sec     := 0;
        l_legal_charges       := 0;
	l_total_ncp           := 0;
	l_penalty             := 0;
        l_pup                 := 0;
        l_count               := 0;



         l_tag := '<Level2>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


	 FOR  rec_assignment IN csr_assignment
	 LOOP

           l_count := l_count + 1 ;
	   IF l_count < 21
	   THEN
             l_tag := '<EMPLOYEE>';       --Employee Tag for the employees in Main Sheet
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   ELSE
	     l_tag := '<EMPLOYEE_CONTD>'; --Employee Tag for the employees in Continous Sheet
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   END IF ;

	   l_tag :=  pay_in_xml_utils.getTag('c_2_sl_no',l_count);
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	   l_tag :=  pay_in_xml_utils.getTag('c_2_pf_no',rec_assignment.pf_no);
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	   l_tag :=  pay_in_xml_utils.getTag('c_2_nssn',rec_assignment.nssn);
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

           /*
	   Incase of Hire Date and Term Date will show the DD value only if the Hire/Term Month is the
	   same as the reporting month.
	   */

	   IF  TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(rec_assignment.hire_date),'MMYYYY')) = p_month||p_year
	   THEN
            l_hire_dd := TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(rec_assignment.hire_date),'DD'));
           ELSE
	    l_hire_dd := NULL ;
	   END IF ;

	   IF  TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(rec_assignment.term_date),'MMYYYY')) = p_month||p_year
	   THEN
            l_term_dd := TO_NUMBER(TO_CHAR(fnd_date.canonical_to_date(rec_assignment.term_date),'DD'));
	    l_term_efile := rec_assignment.efile_term_reason ;
	    l_term_print_copy := rec_assignment.report_term_reason ;
           ELSE
	    l_term_dd := NULL ;
	    l_term_efile := NULL ;
	    l_term_print_copy := NULL ;
	   END IF ;

	   l_tag :=  pay_in_xml_utils.getTag('c_2_hiredate',l_hire_dd);
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	   l_tag :=  pay_in_xml_utils.getTag('c_2_emp_type',rec_assignment.emp_type);
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	   l_tag :=  pay_in_xml_utils.getTag('c_2_term_date',l_term_dd);
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	   l_tag :=  pay_in_xml_utils.getTag('c_2_term_reason_report',l_term_print_copy);
           dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	   /*Added following code for bug6504522*/
	   IF l_term_efile = 'SUP_ANN' THEN
	     l_tag :=  pay_in_xml_utils.getTag('c_2_term_reason_efile','1');
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   ELSIF l_term_efile = 'RETIRE' THEN
	     l_tag :=  pay_in_xml_utils.getTag('c_2_term_reason_efile','2');
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   ELSIF l_term_efile = 'DEATH' THEN
	     l_tag :=  pay_in_xml_utils.getTag('c_2_term_reason_efile','3');
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   ELSIF l_term_efile = 'PMT_DISABLE' OR
	         l_term_efile = 'RESIGN' THEN
	     l_tag :=  pay_in_xml_utils.getTag('c_2_term_reason_efile','5');
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   ELSIF l_term_efile = 'RETRENCH' THEN
	     l_tag :=  pay_in_xml_utils.getTag('c_2_term_reason_efile','6');
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   END IF ;

	   IF rec_assignment.eps = 'FULL_FULL' THEN
	     l_tag :=  pay_in_xml_utils.getTag('c_2_eps','Y');
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   ELSE
	     l_tag :=  pay_in_xml_utils.getTag('c_2_eps','N');
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   END IF ;


           /*EXEM -> Exempted PF Organization
             UEX  -> UnExempted PF Organization
	   */

	   FOR rec_assignment_bal IN csr_assignment_bal(rec_assignment.assignment_action_id,rec_assignment.pf_class)
	   LOOP
	     IF rec_assignment_bal.bal_name = 'Employee Statutory PF Contribution' AND rec_assignment.pf_class <> 'EXEM'
	     THEN

                  l_tag :=  pay_in_xml_utils.getTag('c_2_emp_pf_con',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Employee Voluntary PF Contribution' AND rec_assignment.pf_class <> 'EXEM'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_emp_vol_pf',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Employer PF Contribution' AND rec_assignment.pf_class <> 'EXEM'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_emplr_pf_con',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Refund of Advance Employee PF Share' AND rec_assignment.pf_class <> 'EXEM'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_ref_adv_emp',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Refund of Advance Employer PF Share' AND rec_assignment.pf_class <> 'EXEM'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_ref_adv_emplr',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Non Contributory Period'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_non_con_per',rec_assignment_bal.bal_value);
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
		  l_total_ncp := l_total_ncp + rec_assignment_bal.bal_value ;
	     ELSIF rec_assignment_bal.bal_name = 'EPS Contribution'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_eps_con',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'PF Actual Salary'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_pf_wages',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Recovery of Over Payment of Employee PF Share'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_rec_overpay_emp',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Recovery of Over Payment of Employer PF Share'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_rec_overpay_emplr',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Penalty Interest on Refund of Employee PF Share'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_ref_penalty_emp',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     ELSIF rec_assignment_bal.bal_name = 'Penalty Interest on Refund of Employer PF Share'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_ref_penalty_emplr',format_number(rec_assignment_bal.bal_value));
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	     ELSIF rec_assignment_bal.bal_name = 'Voluntary PF Percent'
	     THEN
	          l_tag :=  pay_in_xml_utils.getTag('c_2_vol_pf_percent',rec_assignment_bal.bal_value);
                  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	     END IF ;



	     --Level 3 Starts

	     /* We are not summing up the Balances for the Level 3 in cursor as this would be reported based on PF Org Classification
	     */

	     IF rec_assignment_bal.bal_name = 'PF Actual Salary'
	     THEN
	       l_total_pf_wages := l_total_pf_wages + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name IN ('Employer PF Contribution'
	                                           ,'Employee Statutory PF Contribution'
						   ,'Employee Voluntary PF Contribution'
						   ,'Refund of Advance Employee PF Share'
						   ,'Refund of Advance Employer PF Share') AND rec_assignment.pf_class <> 'EXEM'
	     THEN
               l_total_epf := l_total_epf + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name = 'Employer EDLI Administrative Charges' AND rec_assignment.pf_class <> 'EXEM'
	     THEN
	       l_edli_admin := l_edli_admin + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name = 'Employer EDLI Inspection Charges' AND rec_assignment.pf_class <> 'UEX'
	     THEN
	       l_edli_inspection := l_edli_inspection + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name = 'Employer PF Administrative Charges'
	     THEN
	       l_epf_admin := l_epf_admin + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name = 'EPS Contribution'
	     THEN
	       l_eps_con := l_eps_con + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name = 'EDLI Contribution'
	     THEN
	       l_edli_con := l_edli_con + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name = 'Employer PF Inspection Charges'
	     THEN
	       l_epf_inspection := l_epf_inspection + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name IN ('Recovery of Over Payment of Employee PF Share'
	                                          ,'Recovery of Over Payment of Employer PF Share')
	     THEN
	       l_rec_overpay := l_rec_overpay + rec_assignment_bal.bal_value;

	     ELSIF rec_assignment_bal.bal_name IN  ('Penalty Interest on Refund of Employee PF Share'
	                                            ,'Penalty Interest on Refund of Employer PF Share')
	     THEN
	       l_penal_int := l_penal_int + rec_assignment_bal.bal_value;

	     END IF ;

	   END LOOP ;

	   IF l_count < 21
	   THEN
             l_tag := '</EMPLOYEE>';
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   ELSE
	     l_tag := '</EMPLOYEE_CONTD>';
             dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
	   END IF ;

	 END LOOP ;


	 l_tag := '</Level2>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 p_total_ncp := l_total_ncp;

	 l_tag := '<Level3>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_total_pf_wages',format_number(l_total_pf_wages));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_total_epf',format_number(l_total_epf));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_epf_admin',format_number(l_epf_admin));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_eps_con',format_number(l_eps_con));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_edli_con',format_number(l_edli_con));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_edli_admin',format_number(l_edli_admin));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_epf_inspection',format_number(l_epf_inspection));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_edli_inspection',format_number(l_edli_inspection));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_rec_overpay',format_number(l_rec_overpay));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_penal_int',format_number(l_penal_int));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 OPEN  csr_challan;
	 FETCH csr_challan INTO l_interest_on_sec,l_legal_charges,l_penalty;
	 CLOSE csr_challan;

	 OPEN csr_pup_total_amount ;
	 FETCH csr_pup_total_amount INTO l_pup;
	 CLOSE csr_pup_total_amount;

	 l_tag :=  pay_in_xml_utils.getTag('c_3_int_on_sec',format_number(l_interest_on_sec));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_legal_charges',format_number(l_legal_charges));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_penalty',format_number(l_penalty));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_3_pup',format_number(l_pup));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag := '</Level3>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 -- Level3 Ends.

	 pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;

  END create_level2_3_xml;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CREATE_LEVEL4_XML                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the level 4 Data             --
  --                  It generates the Challan Data.It gets data from     --
  --                  PAY_ACTION_INFORMATION                              --
  --                  Context : IN_PF_CHALLAN                             --
  --                                                                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_number       VARCHAR2                    --
  --                  p_action_context_id     VARCHAR2                    --
  --                  p_year                  NUMBER                      --
  --                  p_month                 NUMBER                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE create_level4_xml( p_business_number      IN VARCHAR2  DEFAULT NULL
			      ,p_action_context_id    IN VARCHAR2  DEFAULT NULL
			      ,p_year                 IN NUMBER    DEFAULT NULL
			      ,p_month                IN NUMBER    DEFAULT NULL)
  IS
  l_sys_date_time     VARCHAR2(40);
  l_tag               VARCHAR2(1000);
  l_procedure         VARCHAR2(100) ;

  l_bank_name         FND_COMMON_LOOKUPS.MEANING%TYPE ;
  l_base_branch_name  FND_COMMON_LOOKUPS.MEANING%TYPE ;

   CURSOR csr_challan
   IS
   SELECT  DISTINCT
           action_information2                                                        Payment_Type
          ,action_information4                                                        Cheque_DD_No
          ,action_information5                                                        Cheque_DD_Date
          ,action_information6                                                        Cheque_DD_Dep_Date
          ,fnd_number.canonical_to_number(action_information7)                        Amount
          ,action_information8                                                        Challan_Ref
          ,action_information9                                                        Bank_Code
          ,hr_general.decode_lookup('IN_PF_BANKS',action_information9)            Bank_Name
          ,action_information11                                                       Branch_Code
          ,action_information12                                                       Branch_Name
          ,action_information13                                                       Branch_Add
          ,action_information14                                                       Dep_Bank_Code
          ,action_information15                                                       Dep_Branch_Code
          ,action_information16                                                       Dep_Branch_Name
          ,action_information17                                                       Dep_Branch_Address
          ,action_information18                                                       Base_Branch_Code
          ,hr_general.decode_lookup('IN_PF_BASE_BRANCH',action_information18)     Base_Branch_Name
   FROM    pay_action_information
   WHERE   action_context_id           = p_action_context_id
   AND     action_information1         = p_business_number
   AND     action_information_category = 'IN_PF_CHALLAN'
   AND     action_context_type         = 'PA';




  BEGIN

  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'create_level4_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_tag := '<Level4>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  FOR rec_challan IN csr_challan
  LOOP

      l_tag := '<CHALLAN>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_payment_type',rec_challan.Payment_Type);
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_cheque_dd_no',rec_challan.Cheque_DD_No);
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_cheque_dd_date',TO_CHAR(fnd_date.canonical_to_date(rec_challan.Cheque_DD_Date),'DD-MM-YYYY'));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_cheque_dd_dep_date',TO_CHAR(fnd_date.canonical_to_date(rec_challan.Cheque_DD_Dep_Date),'DD-MM-YYYY'));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_amount',format_number(rec_challan.Amount));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

       l_tag :=  pay_in_xml_utils.getTag('c_4_bank_code',replace_comma(rec_challan.Bank_Code));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_bank_name',replace_comma(rec_challan.Bank_Name));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_branch_code',replace_comma(rec_challan.Branch_Code));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_branch_name',replace_comma(rec_challan.Branch_Name));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_branch_add',replace_comma(rec_challan.Branch_Add));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_challan_ref',rec_challan.Challan_Ref);
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_dep_branch_code',replace_comma(rec_challan.Dep_Branch_Code));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_base_branch',replace_comma(rec_challan.Base_Branch_Code));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_4_base_branch_name',replace_comma(rec_challan.Base_Branch_Name));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag := '</CHALLAN>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  END LOOP ;

  l_tag := '</Level4>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;

  END create_level4_xml ;



  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CREATE_LEVEL5_XML                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the level 5 Data             --
  --                  It generates the 14B Data.It gets data from         --
  --                  PAY_ACTION_INFORMATION                              --
  --                  Context : IN_PF_CHALLAN                             --
  --                            IN_PF_14B                                 --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_number       VARCHAR2                    --
  --                  p_action_context_id     VARCHAR2                    --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE create_level5_xml( p_business_number      IN VARCHAR2  DEFAULT NULL
			      ,p_action_context_id    IN VARCHAR2  DEFAULT NULL
			      )
  IS
  l_sys_date_time     VARCHAR2(40);
  l_tag               VARCHAR2(1000);
  l_procedure         VARCHAR2(100) ;


   CURSOR csr_challan
   IS
   SELECT  DISTINCT
           action_information8  Challan_Ref
   FROM    pay_action_information
   WHERE   action_context_id           = p_action_context_id
   AND     action_information1         = p_business_number
   AND     action_information_category = 'IN_PF_CHALLAN'
   AND     action_context_type         = 'PA';

   CURSOR csr_14B(p_challan VARCHAR2)
   IS
   SELECT  DISTINCT
           action_information1                                 Prev_Mth
          ,action_information2                                 Prev_Yr
          ,action_information3                                 Challan_Ref
          ,fnd_number.canonical_to_number(action_information4) Penal_Damages_Due
          ,fnd_number.canonical_to_number(action_information5) EPS_Penal_Damages
          ,fnd_number.canonical_to_number(action_information6) EDLI_Penal_Damages
          ,fnd_number.canonical_to_number(action_information7) EPF_Penal_Damages
          ,fnd_number.canonical_to_number(action_information8) Edli_Admin
   FROM    pay_action_information
   WHERE   action_context_id           = p_action_context_id
   AND     action_information3         = p_challan
   AND     action_information_category = 'IN_PF_14B'
   AND     action_context_type         = 'PA';


  BEGIN

  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'create_level5_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  l_tag := '<Level5>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  FOR rec_challan IN csr_challan
  LOOP
    FOR rec_14B IN csr_14B(rec_challan.Challan_Ref)
    LOOP
      l_tag := '<Damages14B>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_5_prev_mth',rec_14B.Prev_Mth);
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_5_prev_yr',rec_14B.Prev_Yr);
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_5_epf_penal_damages',format_number(rec_14B.Penal_Damages_Due));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_5_eps_penal_damages',format_number(rec_14B.EPS_Penal_Damages));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_5_edli_penal_damages',format_number(rec_14B.EDLI_Penal_Damages));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_5_epf_admin',format_number(rec_14B.EPF_Penal_Damages));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_5_edli_admin',format_number(rec_14B.Edli_Admin));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag := '</Damages14B>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
    END LOOP ;
  END LOOP ;

  l_tag := '</Level5>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;
  END create_level5_xml ;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CREATE_LEVEL6_XML                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the level 6 Data             --
  --                  It generates the 7Q Data.It gets data from          --
  --                  PAY_ACTION_INFORMATION                              --
  --                  Context : IN_PF_CHALLAN                             --
  --                            IN_PF_7Q                                  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_number       VARCHAR2                    --
  --                  p_action_context_id     VARCHAR2                    --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE create_level6_xml( p_business_number      IN VARCHAR2  DEFAULT NULL
			      ,p_action_context_id    IN VARCHAR2  DEFAULT NULL
			      )
  IS
  l_sys_date_time     VARCHAR2(40);
  l_tag               VARCHAR2(1000);
  l_procedure         VARCHAR2(100) ;


   CURSOR csr_challan
   IS
   SELECT  DISTINCT
           action_information8  Challan_Ref
   FROM    pay_action_information
   WHERE   action_context_id           = p_action_context_id
   AND     action_information1         = p_business_number
   AND     action_information_category = 'IN_PF_CHALLAN'
   AND     action_context_type         = 'PA';

   CURSOR csr_7Q(p_challan VARCHAR2)
   IS
   SELECT  DISTINCT
           action_information1                                  Due_Mth
          ,action_information2                                  Due_Yr
          ,action_information3                                  Challan_Ref
          ,fnd_number.canonical_to_number(action_information4)  EPF_Damages
          ,fnd_number.canonical_to_number(action_information5)  EPS_Damages
          ,fnd_number.canonical_to_number(action_information6)  EDLI_Damages
          ,fnd_number.canonical_to_number(action_information7)  EPF_Admin
          ,fnd_number.canonical_to_number(action_information8)  EDLI_Admin
   FROM    pay_action_information
   WHERE   action_context_id           = p_action_context_id
   AND     action_information3         = p_challan
   AND     action_information_category = 'IN_PF_7Q'
   AND     action_context_type         = 'PA';


  BEGIN

  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'create_level6_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  l_tag := '<Level6>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  FOR rec_challan IN csr_challan
  LOOP
    FOR rec_7Q IN csr_7Q(rec_challan.Challan_Ref)
    LOOP
      l_tag := '<Damages7Q>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_6_prev_mth',rec_7Q.Due_Mth);
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_6_prev_yr',rec_7Q.Due_Yr);
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_6_epf_penal_damages',format_number(rec_7Q.EPF_Damages));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_6_eps_penal_damages',format_number(rec_7Q.EPS_Damages));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_6_edli_penal_damages',format_number(rec_7Q.EDLI_Damages));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_6_epf_admin',format_number(rec_7Q.EPF_Admin));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_6_edli_admin',format_number(rec_7Q.Edli_Admin));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag := '</Damages7Q>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
    END LOOP ;
  END LOOP ;

  l_tag := '</Level6>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;

  END create_level6_xml ;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CREATE_LEVEL7_XML                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the level 7 Data             --
  --                  It generates the Misc Data.It gets data from        --
  --                  PAY_ACTION_INFORMATION                              --
  --                  Context : IN_PF_CHALLAN                             --
  --                            IN_PF_MISC                                --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_number       VARCHAR2                    --
  --                  p_action_context_id     VARCHAR2                    --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE create_level7_xml( p_business_number      IN VARCHAR2  DEFAULT NULL
			      ,p_action_context_id    IN VARCHAR2  DEFAULT NULL
			      )
  IS
  l_sys_date_time     VARCHAR2(40);
  l_tag               VARCHAR2(1000);
  l_procedure         VARCHAR2(100) ;


   CURSOR csr_challan
   IS
   SELECT  DISTINCT
           action_information8  Challan_Ref
   FROM    pay_action_information
   WHERE   action_context_id           = p_action_context_id
   AND     action_information1         = p_business_number
   AND     action_information_category = 'IN_PF_CHALLAN'
   AND     action_context_type         = 'PA';

   CURSOR csr_misc(p_challan VARCHAR2)
   IS
   SELECT  DISTINCT
           fnd_number.canonical_to_number(action_information2)   EPF_Misc_Pay
          ,action_information3                                   EPF_Rem
          ,fnd_number.canonical_to_number(action_information4)   EPS_Misc_Pay
          ,action_information5                                   EPS_Rem
          ,fnd_number.canonical_to_number(action_information6)   EDLI_Misc_Pay
          ,action_information7                                   EDLI_Rem
          ,fnd_number.canonical_to_number(action_information8)   EPF_Admin
          ,action_information9                                   EPF_Admin_Rem
          ,fnd_number.canonical_to_number(action_information10)  EDLI_Admin
          ,action_information11                                  EDLI_Admin_Rem
   FROM    pay_action_information
   WHERE   action_context_id           = p_action_context_id
   AND     action_information1         = p_challan
   AND     action_information_category = 'IN_PF_MISC'
   AND     action_context_type         = 'PA';


  BEGIN

  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'create_level7_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  l_tag := '<Level7>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  FOR rec_challan IN csr_challan
  LOOP
    FOR rec_misc IN csr_misc(rec_challan.Challan_Ref)
    LOOP
      l_tag := '<Miscellaneous>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_epf_pay',format_number(rec_misc.EPF_Misc_Pay));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_epf_rem',replace_comma(rec_misc.EPF_Rem));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_eps_pay',format_number(rec_misc.EPS_Misc_Pay));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_eps_rem',replace_comma(rec_misc.EPS_Rem));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_edli_pay',format_number(rec_misc.EDLI_Misc_Pay));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_edli_rem',replace_comma(rec_misc.EDLI_Rem));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_epf_admin',format_number(rec_misc.EPF_Admin));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_epf_admin_rem',replace_comma(rec_misc.EPF_Admin_Rem));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_edli_admin',format_number(rec_misc.EDLI_Admin));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag :=  pay_in_xml_utils.getTag('c_7_edli_admin_rem',replace_comma(rec_misc.EDLI_Admin_Rem));
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

      l_tag := '</Miscellaneous>';
      dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
    END LOOP ;
  END LOOP ;

  l_tag := '</Level7>';
  dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,20);

  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;

  END create_level7_xml ;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CREATE_LEVEL8_XML                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the level 8 Data             --
  --                  It generates the data for the Representative        --
  --                  Details,Filer License Number                        --
  --                  Gets the data from PAY_ACTION_INFORMATION           --
  --                  Context : IN_PF_ORG                                 --
  --                  Gets the data from HR_ORGANIZATION_INFORMATION      --
  --                  Context : PER_IN_COMPANY_FILER_INFO                 --
  --                                                                      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_number       VARCHAR2                    --
  --                  p_action_context_id     VARCHAR2                    --
  --                  p_total_ncp             NUMBER                      --
  --                  p_filer_license_no      VARCHAR2                    --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE create_level8_xml(p_business_number      IN VARCHAR2  DEFAULT NULL
                              ,p_action_context_id   IN VARCHAR2  DEFAULT NULL
                              ,p_total_ncp           IN NUMBER    DEFAULT NULL
			      ,p_filer_license_no    IN VARCHAR2  DEFAULT NULL
			      )
  IS

   l_sys_date                    VARCHAR2(40);
   l_tag                         VARCHAR2(1000);
   l_procedure                   VARCHAR2(100) ;
   l_filer_license_id            PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;

   CURSOR csr_filer_id
   IS
   SELECT org_information1
   FROM   hr_organization_information
   WHERE  org_information2 = p_filer_license_no
   AND    org_information_context    = 'PER_IN_COMPANY_FILER_INFO';

   CURSOR csr_rep_details
   IS
   SELECT  DISTINCT
           action_information4    rep_name
          ,action_information5    rep_pos
   FROM    pay_action_information
   WHERE   action_information_category = 'IN_PF_ORG'
   AND     action_context_type         = 'PA'
   AND     action_context_id           =  p_action_context_id
   AND     action_information1         =  p_business_number ;

  BEGIN
          g_debug := hr_utility.debug_enabled;
	  l_procedure := g_package ||'create_level8_xml';
	  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


         OPEN csr_filer_id ;
	 FETCH csr_filer_id INTO l_filer_license_id ;
	 CLOSE csr_filer_id ;


         l_tag := '<Level8>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_sys_date:=to_char(SYSDATE,'DD-MM-YYYY');
         --System Date:
         l_tag :=pay_in_xml_utils.getTag('c_8_sys_date',l_sys_date);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

         l_tag :=pay_in_xml_utils.getTag('c_8_filer_license_id',l_filer_license_id);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=pay_in_xml_utils.getTag('c_8_filer_license_no',p_filer_license_no);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

         l_tag :=  pay_in_xml_utils.getTag('c_8_total_ncp',p_total_ncp);
	 dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 FOR rec_rep_details IN csr_rep_details
	 LOOP

            l_tag := '<REPRESENTATIVE_DTLS>';
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	    l_tag :=  pay_in_xml_utils.getTag('c_8_rep_name',rec_rep_details.rep_name);
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	    l_tag :=  pay_in_xml_utils.getTag('c_8_rep_pos',replace_comma(rec_rep_details.rep_pos));
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

            l_tag := '</REPRESENTATIVE_DTLS>';
            dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 END LOOP ;

	 l_tag := '</Level8>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;

  END create_level8_xml ;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : CREATE_LEVEL1_XML                                   --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure creates the level 1 Data             --
  --                  It generates the data related to Business Number    --
  --                  Gets the data from PAY_ACTION_INFORMATION           --
  --                  Context : IN_PF_BUSINESS_NUMBER                     --
  --                  Calls          create_level2_3_xml                  --
  --                                 create_level4_xml                    --
  --                                 create_level5_xml                    --
  --                                 create_level6_xml                    --
  --                                 create_level7_xml                    --
  --                                 create_level8_xml                    --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_business_number       VARCHAR2                    --
  --                  p_pf_arc_ref_no         VARCHAR2                    --
  --                  p_year                  NUMBER                      --
  --                  p_month                 NUMBER                      --
  --                  p_filer_license_no      VARCHAR2                    --
  --                  p_nssn                  VARCHAR2                    --
  --                  p_sort_by               VARCHAR2                    --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE create_level1_xml( p_business_number      IN VARCHAR2  DEFAULT NULL
			      ,p_pf_arc_ref_no        IN VARCHAR2  DEFAULT NULL
			      ,p_year                 IN NUMBER    DEFAULT NULL
			      ,p_month                IN NUMBER    DEFAULT NULL
			      ,p_filer_license_no     IN VARCHAR2  DEFAULT NULL
			      ,p_nssn                 IN VARCHAR2  DEFAULT NULL
			      ,p_sort_by              IN VARCHAR2  DEFAULT NULL)
  IS
  l_sys_date_time            VARCHAR2(40);
  l_tag                      VARCHAR2(1000);
  l_procedure                VARCHAR2(100);

  l_pf_org                   PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_ref_no                   PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_mth_yr                   PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_year                     PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_month                    PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_return_type              PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_reg_comp_name            PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_business_no              PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_classification           PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_representative_name      PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_representative_desig     PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_action_context_id        pay_action_information.action_context_id%TYPE;
  l_pup                      PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;


  l_total_ncp                NUMBER ;

   CURSOR csr_pf_org
   IS
   SELECT  DISTINCT
           action_information1 business_no
	  ,action_information2 ref_no
	  ,action_information3 mth_yr
	  ,action_information4 return_type
	  ,action_information5 reg_comp_name
	  ,action_context_id   action_context_id
   FROM    pay_action_information
   WHERE   action_information2         = p_pf_arc_ref_no
   AND     action_information1         = p_business_number
   AND     action_information3         = p_month||p_year
   AND     action_information_category = 'IN_PF_BUSINESS_NUMBER'
   AND     action_context_type         = 'PA';

  CURSOR csr_challan(p_action_context_id VARCHAR2)
   IS
   SELECT  DISTINCT
           action_information20  pup
   FROM    pay_action_information pai,
           pay_payroll_actions    ppa
   WHERE   pai.action_context_id           = ppa.payroll_action_id
   AND     ppa.action_type = 'X'
   AND     ppa.action_status = 'C'
   AND     ppa.report_type ='IN_PF_ARCHIVE'
   AND     pai.action_context_id           = p_action_context_id
   AND     pai.action_information1         = p_business_number
   AND     pai.action_information_category = 'IN_PF_CHALLAN'
   AND     pai.action_context_type         = 'PA';



  BEGIN
          g_debug := hr_utility.debug_enabled;
          l_procedure := g_package ||'create_level1_xml';
	  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


         l_tag := '<Level1>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);
         --
         l_sys_date_time:= TO_CHAR(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
         --System Date:
         l_tag :=pay_in_xml_utils.getTag('c_sys_date',l_sys_date_time);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


	 OPEN csr_pf_org;
	 FETCH csr_pf_org INTO   l_business_no
				,l_ref_no
				,l_mth_yr
				,l_return_type
				,l_reg_comp_name
				,l_action_context_id   ;
	 CLOSE csr_pf_org ;

         l_year  := SUBSTR(TRIM(l_mth_yr) , (LENGTH(TRIM(l_mth_yr)) - 4)+1);
         l_month := SUBSTR(TRIM(l_mth_yr) , 1 , (LENGTH(TRIM(l_mth_yr)) - 4));

	 l_tag :=  pay_in_xml_utils.getTag('c_1_business_no',l_business_no);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_1_name_of_comp',replace_comma(l_reg_comp_name));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_1_month',LPAD(l_month,2,'0'));
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_1_year',l_year);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag :=  pay_in_xml_utils.getTag('c_1_return_type',l_return_type);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

         l_pup := 'N';
	 FOR rec_challan IN csr_challan(l_action_context_id)
	 LOOP
	   IF rec_challan.pup = 'Y'
	   THEN
	      l_pup := 'Y';
	      EXIT ;
	   END IF ;
	 END LOOP ;

	 l_tag :=  pay_in_xml_utils.getTag('c_1_pup',l_pup);
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 pay_in_utils.set_location(g_debug,'Calling : create_level2_3_xml',1);
	 create_level2_3_xml(p_business_number    => p_business_number
                            ,p_pf_arc_ref_no      => p_pf_arc_ref_no
			    ,p_action_context_id  => l_action_context_id
		            ,p_year               => p_year
		            ,p_month              => p_month
			    ,p_nssn               => p_nssn
			    ,p_sort_by            => p_sort_by
			    ,p_total_ncp          => l_total_ncp
	                    );
        pay_in_utils.set_location(g_debug,'Calling : create_level4_xml',2);
	create_level4_xml(p_business_number     => p_business_number
			  ,p_action_context_id  => l_action_context_id
			  ,p_year               => p_year
			  ,p_month              => p_month
	                 );

        pay_in_utils.set_location(g_debug,'Calling : create_level5_xml',3);
	create_level5_xml(p_business_number     => p_business_number
			  ,p_action_context_id  => l_action_context_id
			  );

	pay_in_utils.set_location(g_debug,'Calling : create_level6_xml',4);
	create_level6_xml(p_business_number     => p_business_number
			  ,p_action_context_id  => l_action_context_id
			  );

	pay_in_utils.set_location(g_debug,'Calling : create_level7_xml',5);
        create_level7_xml(p_business_number     => p_business_number
			  ,p_action_context_id  => l_action_context_id
			  );

        pay_in_utils.set_location(g_debug,'Calling : create_level8_xml',6);
        create_level8_xml(p_business_number     => p_business_number
	                  ,p_action_context_id  => l_action_context_id
	                  ,p_total_ncp          => l_total_ncp
			  ,p_filer_license_no   => p_filer_license_no
			  );

        l_tag := '</Level1>';
        dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);



	  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;

  END create_level1_xml;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : INIT_CODE                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure calls procedure for PF Monthly       --
--                  Reorts and EFile depending on the report type       --
--                  parameter                                           --
--                  April is archived as '04' and not '01'              --
-- Parameters     :                                                     --
--             IN :   p_pf_business_no            VARCHAR2		--
--                    p_pf_arc_ref_no             VARCHAR2		--
--                    p_template_name             VARCHAR2		--
--                    p_return_type               VARCHAR2		--
--                    p_year                      VARCHAR2		--
--                    p_month                     VARCHAR2		--
--                    p_filer_license_no          VARCHAR2		--
--                    p_nssn                      VARCHAR2		--
--                    p_sort_by                   VARCHAR2		--
--            OUT :   p_xml                       CLOB                  --
--                                                                      --
-- Change History :                                                     --
--------------------------------------------------------------------------
-- Rev#  Date           Userid    Description                           --
--------------------------------------------------------------------------
-- 115.0 01-AUG-2007    rsaharay   Initial Version                      --
-- 115.1 24-OCT-2007    rsaharay   Modified for Currency Period         --
-- 115.2 08-Jan-2009    mdubasi    Modified the cursor csr_pf_bus_no
--------------------------------------------------------------------------
  PROCEDURE init_code(p_pf_business_no       IN VARCHAR2  DEFAULT NULL
		     ,p_pf_arc_ref_no        IN VARCHAR2  DEFAULT NULL
	             ,p_template_name        IN VARCHAR2
		     ,p_xml                  OUT NOCOPY CLOB
		     ,p_return_type          IN VARCHAR2  DEFAULT NULL
		     ,p_year                 IN VARCHAR2  DEFAULT NULL
		     ,p_month                IN VARCHAR2  DEFAULT NULL
		     ,p_filer_license_no     IN VARCHAR2  DEFAULT NULL
		     ,p_nssn                 IN VARCHAR2  DEFAULT NULL
		     ,p_sort_by              IN VARCHAR2  DEFAULT NULL)
 IS
  l_effective_start_date        DATE;
  l_effective_end_date          DATE;
  l_message                     VARCHAR2(255);
  l_procedure                   VARCHAR2(100);
  l_tag                         VARCHAR2(1000);

  l_pf_org            PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;
  l_year              NUMBER(4);
  l_month             NUMBER(2);

 CURSOR csr_pf_bus_no(p_yr_mth VARCHAR2)
 IS
 SELECT DISTINCT
        pai.action_information1 bus_no
 FROM   pay_action_information pai,
        pay_payroll_actions ppa
 WHERE  pai.action_context_id = ppa.payroll_action_id
 AND    ppa.action_type = 'X'
 AND    ppa.action_status = 'C'
 AND    ppa.report_type ='IN_PF_ARCHIVE'
 AND    pai.action_context_type = 'PA'
 AND    pai.action_information_category = 'IN_PF_BUSINESS_NUMBER'
 AND    pai.action_information1 =  NVL(p_pf_business_no,pai.action_information1)
 AND    pai.action_information3 = p_yr_mth
 AND    pai.action_information2 = p_pf_arc_ref_no
 AND    ppa.business_group_id   = g_bg_id;

 BEGIN
   --
  g_debug := hr_utility.debug_enabled;
  l_procedure := g_package ||'init_code';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  g_template := p_template_name ;

  g_bg_id:=fnd_profile.value('PER_BUSINESS_GROUP_ID');

  IF g_debug THEN
       pay_in_utils.trace('p_pf_business_no        ',p_pf_business_no  );
       pay_in_utils.trace('p_pf_arc_ref_no         ',p_pf_arc_ref_no   );
       pay_in_utils.trace('p_return_type           ',p_return_type     );
       pay_in_utils.trace('p_year                  ',p_year            );
       pay_in_utils.trace('p_month                 ',p_month           );
       pay_in_utils.trace('p_filer_license_no      ',p_filer_license_no);
       pay_in_utils.trace('p_nssn                  ',p_nssn            );
       pay_in_utils.trace('p_sort_by               ',p_sort_by         );
       pay_in_utils.trace('g_bg_id                 ',g_bg_id           );
   END IF;

  l_month := TO_NUMBER(p_month) + 3 ;
  l_year  := SUBSTR(p_year,1,4);
  IF l_month > 12 THEN
     l_month := l_month - 12 ;
     l_year  := TO_NUMBER(l_year) + 1;
  END IF ;

  IF l_month = 3 THEN
     l_year := l_year - 1 ;
  END IF ;

         dbms_lob.createtemporary(g_xml_data,FALSE,DBMS_LOB.CALL);
         dbms_lob.open(g_xml_data,dbms_lob.lob_readwrite);
          --
         l_tag :='<?xml version="1.0"  encoding="UTF-8"?>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

	 l_tag := '<PFData_BusinessNo>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);

  FOR rec_pf_bus_no IN csr_pf_bus_no(l_month||l_year)
  LOOP
     create_level1_xml(p_business_number    => rec_pf_bus_no.bus_no
                      ,p_pf_arc_ref_no      => p_pf_arc_ref_no
		      ,p_year               => l_year
		      ,p_month              => l_month
		      ,p_filer_license_no   => p_filer_license_no
		      ,p_nssn               => p_nssn
		      ,p_sort_by            => p_sort_by
	              );


 END LOOP ;


         l_tag := '</PFData_BusinessNo>';
         dbms_lob.writeAppend(g_xml_data, length(l_tag), l_tag);


     p_xml := g_xml_data;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);

  EXCEPTION

  WHEN OTHERS THEN
         pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;


END init_code;


END ;

/
