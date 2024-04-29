--------------------------------------------------------
--  DDL for Package Body PAY_IN_PF_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_PF_ARCHIVE" AS
/* $Header: pyinmpfa.pkb 120.0.12010000.4 2009/01/08 05:19:52 mdubasi ship $ */

  ----------------------------------------------------------------------+
  -- This is a global variable used to store Archive assignment action id
  ----------------------------------------------------------------------+

  g_archive_pact         NUMBER;
  g_package              CONSTANT VARCHAR2(100) := 'pay_in_pf_archive.';
  g_debug                BOOLEAN;


   g_year              VARCHAR2(50) ;
   g_challan_year      VARCHAR2(50) ;
   g_month             VARCHAR2(50) ;
   g_challan_mth       VARCHAR2(50) ;
   g_business_no       VARCHAR2(50);
   g_return_type       VARCHAR2(50) ;
   g_arc_ref_no        VARCHAR2(50);
   g_bg_id             VARCHAR2(50);
   g_start_date        DATE ;
   g_end_date          DATE ;



  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : RANGE_CODE                                          --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure returns a sql string to select a     --
  --                  range of assignments eligible for archival.         --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : p_sql                  VARCHAR2                     --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  PROCEDURE range_code(p_payroll_action_id   IN  NUMBER
                      ,p_sql                 OUT NOCOPY VARCHAR2
                      )
  IS
  --
    l_procedure  VARCHAR2(100);
    l_message    VARCHAR2(250);
  --
  BEGIN
  --

    g_debug := hr_utility.debug_enabled;
    l_procedure  := g_package || '.range_code';

    pay_in_utils.set_location(g_debug,'Entering : '||l_procedure,10);

    -- Call core package to return SQL string to SELECT a range
    -- of assignments eligible for archival
    --
    pay_core_payslip_utils.range_cursor(p_payroll_action_id
                                       ,p_sql);

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,20);


  --
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR',
      'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
      pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 150);
      RAISE ;
  --
  END range_code;

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_PARAMETERS                                      --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure determines the globals applicable    --
  --                  through out the tenure of the process               --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id      NUMBER                     --
  --             IN : p_token_name             VARCHAR2                   --
  --            OUT : p_token_value            VARCHAR2                   --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------

  PROCEDURE get_parameters(p_payroll_action_id IN  NUMBER,
                           p_token_name        IN  VARCHAR2,
                           p_token_value       OUT  NOCOPY VARCHAR2) IS

  CURSOR csr_parameter_info(p_pact_id NUMBER,
                            p_token   CHAR) IS
  SELECT SUBSTR(legislative_parameters||' ',
         INSTR(legislative_parameters||' ',p_token||'=')+(LENGTH(p_token||'=')),
         INSTR(legislative_parameters||' ',' ',
         INSTR(legislative_parameters||' ',p_token||'='))
         - (INSTR(legislative_parameters||' ',p_token||'=')+LENGTH(p_token||'='))),
         business_group_id
  FROM   pay_payroll_actions
  WHERE  payroll_action_id = p_pact_id;

  l_business_group_id               VARCHAR2(20);
  l_token_value                     VARCHAR2(50);

  l_procedure                      VARCHAR2(50);

BEGIN

 l_procedure :=  g_package || 'get_parameters';

 pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  OPEN csr_parameter_info(p_payroll_action_id,
                          p_token_name);
  FETCH csr_parameter_info INTO l_token_value,
                                l_business_group_id;
  CLOSE csr_parameter_info;

  IF p_token_name = 'BG_ID'
  THEN
     p_token_value := l_business_group_id;
  ELSE
     p_token_value := l_token_value;
  END IF;

  IF g_debug THEN
     pay_in_utils.trace('Token Name  ',p_token_name);
     pay_in_utils.trace('Token Value ',p_token_value);
  END IF;

  pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);


END get_parameters;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : INITIALIZATION_CODE                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure is used to set global contexts.      --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  -- 115.1 24-Oct-2007    rsaharay  Modified for Currency Period          --
  -- 115.2 08-Jan-2008    mdubasi   Modified the cursor csr_arch_ref_no   --
  --------------------------------------------------------------------------
  PROCEDURE initialization_code (
                                  p_payroll_action_id  IN NUMBER
                                )
  IS
  --
    l_procedure  VARCHAR2(100) ;
    l_message    VARCHAR2(255);
    l_temp_month  NUMBER ;

    CURSOR csr_arch_ref_no
    IS
    SELECT 1
    FROM   pay_action_information pai
          ,pay_payroll_actions ppa
    WHERE  pai.action_information_category = 'IN_PF_BUSINESS_NUMBER'
    AND    pai.action_context_type         = 'PA'
    AND    pai.action_information2 = g_arc_ref_no
    AND    pai.action_context_id = ppa.payroll_action_id
    AND    ppa.action_type = 'X'
    AND    ppa.action_status = 'C'
    AND    ppa.payroll_action_id <> p_payroll_action_id
    AND    ppa.report_type ='IN_PF_ARCHIVE'
    AND    ppa.business_group_id = g_bg_id;

   l_token_name    pay_in_utils.char_tab_type;
   l_token_value   pay_in_utils.char_tab_type;
   l_arch_ref_no_check      NUMBER ;
   E_NON_UNIQUE_ARCH_REF_NO EXCEPTION;
  --
  BEGIN
  --
    l_procedure  :=  g_package || 'initialization_code';

    g_debug := hr_utility.debug_enabled;
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    g_archive_pact := p_payroll_action_id;

   get_parameters(p_payroll_action_id,'YR',g_year);
   get_parameters(p_payroll_action_id,'MTH',g_month);
   get_parameters(p_payroll_action_id,'PF',g_business_no);
   get_parameters(p_payroll_action_id,'RT',g_return_type);
   get_parameters(p_payroll_action_id,'REF',g_arc_ref_no);
   get_parameters(p_payroll_action_id,'BG_ID',g_bg_id);

   g_year         := TRIM(g_year);
   g_month        := TRIM(g_month);
   g_return_type  := TRIM(g_return_type);
   g_arc_ref_no   := TRIM(g_arc_ref_no);
   g_business_no  := TRIM(g_business_no);



   g_challan_mth  := g_month ;
   g_challan_year := g_year  ;





   g_month := TO_NUMBER(g_month) + 3 ;
   g_year  := SUBSTR(g_year,1,4);
   IF g_month > 12 THEN
     g_month := g_month - 12 ;
     g_year  := TO_NUMBER(g_year) + 1;
   END IF ;

   IF g_month = 3 THEN
    g_year := g_year - 1;
   END IF ;

   g_start_date := TO_DATE(('01/'||SUBSTR(g_month,1,2)||'/'|| SUBSTR(g_year,1,4)),'DD/MM/YYYY');
   g_end_date   := LAST_DAY(g_start_date);


    l_arch_ref_no_check := 0;
    OPEN csr_arch_ref_no;
    FETCH csr_arch_ref_no INTO l_arch_ref_no_check;
    CLOSE csr_arch_ref_no;
    IF l_arch_ref_no_check = 1 THEN
       l_token_name(1) := 'NUMBER_CATEGORY';
       l_token_value(1) := hr_general.decode_lookup('IN_MESSAGE_TOKENS','ARCH_REF_NUM');--'Archive Reference Number';
       RAISE E_NON_UNIQUE_ARCH_REF_NO;
    END IF;

    pay_in_utils.set_location(g_debug,'g_year              : '||g_year, 5);
    pay_in_utils.set_location(g_debug,'g_month             : '||g_month, 5);
    pay_in_utils.set_location(g_debug,'g_challan_year      : '||g_challan_year, 5);
    pay_in_utils.set_location(g_debug,'g_challan_mth       : '||g_challan_mth, 5);
    pay_in_utils.set_location(g_debug,'g_return_type       : '||g_return_type, 5);
    pay_in_utils.set_location(g_debug,'g_arc_ref_no        : '||g_arc_ref_no, 5);
    pay_in_utils.set_location(g_debug,'g_bg_id             : '||g_bg_id, 5);
    pay_in_utils.set_location(g_debug,'g_start_date        : '||g_start_date, 5);
    pay_in_utils.set_location(g_debug,'g_end_date          : '||g_end_date, 5);
    pay_in_utils.set_location(g_debug,'g_business_no       : '||g_business_no, 5);
    pay_in_utils.set_location(g_debug,'p_payroll_action_id : '||p_payroll_action_id, 5);


   pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 20);
  --
  EXCEPTION
    WHEN E_NON_UNIQUE_ARCH_REF_NO THEN
      pay_in_utils.raise_message(800, 'PER_IN_NON_UNIQUE_VALUE', l_token_name, l_token_value);
      fnd_file.put_line(fnd_file.log,'Archive Reference Number '|| g_arc_ref_no || 'is non-unique.');
      RAISE;
    WHEN OTHERS THEN
       l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR',
       'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
  --
  END initialization_code;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PF_EMP_DTLS                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets the Employee                    --
  --                  Level Data like the PF Number,NSSN,Hire Date,       --
  --                  Employee Type,Termination Date,Termination Reason,  --
  --                  EPS on Higher Employer Wages                        --
  --                  and archives them.                                  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_run_asg_action_id    NUMBER                       --
  --                  p_arc_asg_action_id    NUMBER                       --
  --                  p_assignment_id        NUMBER                       --
  --                  p_pf_org               NUMBER                       --
  --                  p_business_number      NUMBER                       --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  -- 115.1 26-Oct-2007    rsaharay  Modified Cursor csr_pf_people         --
  --------------------------------------------------------------------------

  PROCEDURE archive_pf_emp_dtls( p_run_asg_action_id  IN NUMBER
				,p_arc_asg_action_id  IN NUMBER
				,p_assignment_id      IN NUMBER
				,p_pf_org             IN NUMBER
				,p_business_number    IN NUMBER)
  IS

    l_procedure			  VARCHAR2(100);
    l_message			  VARCHAR2(255);
    l_action_info_id		  NUMBER ;
    l_archived  		  NUMBER ;
    l_ovn			  NUMBER ;
    l_pf_no                       PER_PEOPLE_F.PER_INFORMATION8%TYPE ;
    l_nssn                        PER_PEOPLE_F.PER_INFORMATION15%TYPE ;
    l_hire_date                   DATE  ;
    l_emp_type                    VARCHAR2(2);
    l_term_date                   DATE ;
    l_report                      PER_PERIODS_OF_SERVICE.PDS_INFORMATION1%TYPE;
    l_efile                       PER_PERIODS_OF_SERVICE.PDS_INFORMATION2%TYPE;
    l_eps                         HR_SOFT_CODING_KEYFLEX.SEGMENT12%TYPE;
    l_classification              HR_ORGANIZATION_INFORMATION.ORG_INFORMATION3%TYPE ;

    CURSOR csr_pf_people IS
    SELECT
           ppf.per_information8 pf_no,                                              -- PF Number
           ppf.per_information15 nssn,                                              -- NSSN
           pps.date_start ,                                                         -- Hire Date
	   'D',								            -- Employee Type
           pps.actual_termination_date term_date,                                   -- Termination Date
           pps.pds_information1 report,                                             -- Termination Reason(Print)
           pps.pds_information2 efile,                                              -- Termination Reason(EFile)
	   scl.segment12 eps                                                        -- EPS on higher employer wages
    FROM   per_people_f ppf,
           per_person_types ppt,
           per_assignments_f paf,
	   per_periods_of_service pps,
	   hr_soft_coding_keyflex scl
    WHERE  paf.person_id = ppf.person_id
    AND    paf.period_of_service_id = pps.period_of_service_id
    AND    ppf.person_type_id = ppt.person_type_id
    AND    paf.assignment_id = p_assignment_id
    AND    scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
    AND    scl.enabled_flag = 'Y'
    AND    (to_char(paf.effective_start_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
           OR  to_char(paf.effective_end_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
           OR  g_end_date between paf.effective_start_date and paf.effective_end_date)
    AND    g_end_date between ppf.effective_start_date and ppf.effective_end_date ;


    CURSOR csr_pf_classification
    IS
    SELECT org_information3            classification
    FROM   hr_organization_information hr_pf_org
    WHERE  org_information_context    = 'PER_IN_PF_DF'
    AND    hr_pf_org.organization_id =  p_pf_org ;

  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || 'archive_pf_emp_dtls';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    OPEN csr_pf_classification ;
    FETCH csr_pf_classification INTO l_classification ;
    CLOSE csr_pf_classification ;


     OPEN  csr_pf_people;
     FETCH csr_pf_people INTO l_pf_no,l_nssn,l_hire_date,l_emp_type,l_term_date,l_report,l_efile,l_eps;
     CLOSE csr_pf_people;

     pay_in_utils.set_location(g_debug,'Assignment Id : '||p_assignment_id,15);

 	   pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_asg_action_id
              ,p_action_context_type            =>     'AAP'
              ,p_action_information_category    =>     'IN_PF_PERSON_DTLS'
	      ,p_source_id                      =>     p_run_asg_action_id
	      ,p_action_information1            =>     p_business_number
              ,p_action_information2            =>     g_arc_ref_no
              ,p_action_information3            =>     g_month||g_year
              ,p_action_information4            =>     l_pf_no
              ,p_action_information5            =>     l_nssn
              ,p_action_information6            =>     fnd_date.date_to_canonical(l_hire_date)
              ,p_action_information7            =>     l_emp_type
              ,p_action_information8            =>     fnd_date.date_to_canonical(l_term_date)
              ,p_action_information9            =>     l_report
              ,p_action_information10           =>     l_efile
              ,p_action_information11           =>     l_eps
              ,p_action_information12           =>     p_pf_org
              ,p_action_information13           =>     l_classification
	      ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );

     pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  --
  END archive_pf_emp_dtls;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PF_BALANCES                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure calls pay_balance_pkg.get_value      --
  --                  to get the _ASG_ORG_PTD values of the following     --
  --                  balances                                            --
  --                   1. Employee Statutory PF Contribution              --
  --                   2. Employee Voluntary PF Contribution              --
  --                   3. Employer PF Contribution                        --
  --                   4. EPS Contribution                                --
  --                   5. PF Actual Salary                                --
  --                   6. Employer PF Administrative Charges              --
  --                   7. Employer PF Inspection Charges                  --
  --                   8. Employer EDLI Administrative Charges            --
  --                   9. Employer EDLI Inspection Charges                --
  --                  10. EDLI Contribution                               --
  --                                                                      --
  --                  It also gets the element entries for the element    --
  --                  'PF Refund Information' and the Vol PF Percentage   --
  --                  'EE Voluntary PF Percent'.                          --
  --                                                                      --
  --                  It then archives individual balances.               --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_run_asg_action_id    NUMBER                       --
  --                  p_arc_asg_action_id    NUMBER                       --
  --                  p_assignment_id        NUMBER                       --
  --                  p_pf_org               NUMBER                       --
  --                  p_business_number      NUMBER                       --
  --                                                                      --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------

  PROCEDURE archive_pf_balances(   p_run_asg_action_id  IN NUMBER
				  ,p_arc_asg_action_id  IN NUMBER
				  ,p_assignment_id      IN NUMBER
				  ,p_pf_org             IN NUMBER
				  ,p_business_number    IN NUMBER
                               )
  IS

    l_value           NUMBER;
    l_procedure       VARCHAR2(100);
    l_message         VARCHAR2(255);
    l_classification  HR_ORGANIZATION_INFORMATION.ORG_INFORMATION3%TYPE ;
    l_action_info_id  NUMBER ;
    l_ovn             NUMBER ;
    l_vol_pf_rate     NUMBER ;
    l_pf_org          NUMBER ;
    result_val        NUMBER:=0;
    l_vpf_count       NUMBER:=0;



    CURSOR csr_pf_balances
    IS
    SELECT pdb.defined_balance_id balance_id
          ,pbt.balance_name       balance_name
    FROM   pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
    WHERE  pbt.balance_name IN('Employee Statutory PF Contribution'
                              ,'Employee Voluntary PF Contribution'
                              ,'Employer PF Contribution'
                              ,'EPS Contribution'
                              ,'PF Actual Salary'
                              ,'Employer PF Administrative Charges'
                              ,'Employer PF Inspection Charges'
                              ,'Employer EDLI Administrative Charges'
                              ,'Employer EDLI Inspection Charges'
                              ,'EDLI Contribution'
			      ,'Refund of Advance Employer PF Share'
			      ,'Refund of Advance Employee PF Share'
			      ,'Recovery of Over Payment of Employee PF Share'
			      ,'Recovery of Over Payment of Employer PF Share'
			      ,'Penalty Interest on Refund of Employer PF Share'
			      ,'Penalty Interest on Refund of Employee PF Share'

                              )
     AND   pbd.dimension_name   ='_ASG_ORG_PTD'
     AND   pbt.legislation_code = 'IN'
     AND   pbd.legislation_code = 'IN'
     AND   pdb.legislation_code = 'IN'
     AND   pbt.balance_type_id = pdb.balance_type_id
     AND   pbd.balance_dimension_id  = pdb.balance_dimension_id;


    CURSOR csr_pf_balances_ptd
    IS
    SELECT pdb.defined_balance_id balance_id
          ,pbt.balance_name       balance_name
      FROM pay_balance_types pbt
          ,pay_balance_dimensions pbd
          ,pay_defined_balances pdb
     WHERE pbt.balance_name IN('Non Contributory Period')
       AND pbd.dimension_name   ='_ASG_PTD'
       AND pbt.legislation_code = 'IN'
       AND pbd.legislation_code = 'IN'
       AND pdb.legislation_code = 'IN'
       AND pbt.balance_type_id = pdb.balance_type_id
       AND pbd.balance_dimension_id  = pdb.balance_dimension_id;

   CURSOR csr_pf_vol_rate
   IS
   SELECT result_value
   FROM   pay_run_results           prr,
	  pay_run_result_values     prv,
          pay_element_types_f       pet,
          pay_input_values_f        piv,
          pay_assignment_actions    paa
   WHERE  prr.run_result_id   = prv.run_result_id
   AND    prr.element_type_id = pet.element_type_id
   AND    pet.element_type_id = piv.element_type_id
   AND    piv.input_value_id =  prv.input_value_id
   AND    paa.source_action_id = p_run_asg_action_id
   AND    paa.assignment_action_id =prr.assignment_action_id
   AND    pet.element_name = 'PF Information'
   AND    piv.NAME ='EE Voluntary PF Percent'
   AND    g_end_date BETWEEN pet.effective_start_date and pet.effective_end_date
   AND    g_end_date BETWEEN piv.effective_start_date and piv.effective_end_date ;



    CURSOR csr_pf_classification
    IS
    SELECT org_information3            classification
    FROM   hr_organization_information hr_pf_org
    WHERE  org_information_context    = 'PER_IN_PF_DF'
    AND    hr_pf_org.organization_id =  p_pf_org ;




   CURSOR csr_chk_vpf(p_class VARCHAR2 )
   IS
   SELECT COUNT(*)
   FROM   pay_action_information
   WHERE  action_context_id             = p_arc_asg_action_id
   AND    action_information1           = p_business_number
   AND    action_information_category   = 'IN_PF_SALARY'
   AND    action_context_type           = 'AAP'
   AND    action_information3           = 'Voluntary PF Percent'
   AND    action_information5           = p_class ;


  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || 'archive_pf_balances';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

    OPEN csr_pf_classification ;
    FETCH csr_pf_classification INTO l_classification ;
    CLOSE csr_pf_classification ;

    FOR c_rec IN csr_pf_balances
    LOOP

     result_val := pay_balance_pkg.get_value(p_defined_balance_id   => c_rec.balance_id,
		                             p_assignment_action_id => p_run_asg_action_id,
		                             p_tax_unit_id          => NULL ,
				             p_jurisdiction_code    => NULL ,
		                             p_source_id            => p_pf_org,
				             p_tax_group            => NULL ,
                                             p_date_earned          => NULL );

     pay_in_utils.set_location(g_debug,'balance_name: '||c_rec.balance_name,20);
     pay_in_utils.set_location(g_debug,'result_val: '||result_val,20);

     IF result_val <> 0 THEN
        pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_asg_action_id
              ,p_action_context_type            =>     'AAP'
              ,p_action_information_category    =>     'IN_PF_SALARY'
              ,p_source_id                      =>     p_run_asg_action_id
              ,p_action_information1            =>     p_business_number
              ,p_action_information2            =>     p_pf_org
	      ,p_action_information3            =>     c_rec.balance_name
	      ,p_action_information4            =>     fnd_number.number_to_canonical(result_val)
	      ,p_action_information5            =>     l_classification
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );
     END IF ;
     result_val := 0;
    END LOOP ;

    FOR rec_pf_balances_ptd IN csr_pf_balances_ptd
    LOOP
     result_val := pay_balance_pkg.get_value(p_defined_balance_id   =>rec_pf_balances_ptd.balance_id,
		                             p_assignment_action_id =>p_run_asg_action_id,
		                             p_tax_unit_id          => NULL ,
				             p_jurisdiction_code    => NULL ,
		                             p_source_id            => NULL ,
				             p_tax_group            => NULL ,
                                             p_date_earned          => NULL );

     pay_in_utils.set_location(g_debug,'balance_name: '||rec_pf_balances_ptd.balance_name,20);
     pay_in_utils.set_location(g_debug,'result_val: '||result_val,20);

     IF result_val <> 0 THEN
       pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_asg_action_id
              ,p_action_context_type            =>     'AAP'
              ,p_action_information_category    =>     'IN_PF_SALARY'
              ,p_source_id                      =>     p_run_asg_action_id
	      ,p_action_information1            =>     p_business_number
              ,p_action_information2            =>     p_pf_org
              ,p_action_information3            =>     rec_pf_balances_ptd.balance_name
              ,p_action_information4            =>     fnd_number.number_to_canonical(result_val)
	      ,p_action_information5            =>     l_classification
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );
     END IF ;

     result_val := 0;
    END LOOP ;

   OPEN csr_chk_vpf(l_classification) ;
   FETCH csr_chk_vpf INTO l_vpf_count ;
   CLOSE csr_chk_vpf ;

   IF l_vpf_count = 0 THEN

     OPEN csr_pf_vol_rate;
     FETCH csr_pf_vol_rate INTO l_vol_pf_rate;
     CLOSE csr_pf_vol_rate;

     pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_asg_action_id
              ,p_action_context_type            =>     'AAP'
              ,p_action_information_category    =>     'IN_PF_SALARY'
              ,p_source_id                      =>     p_run_asg_action_id
	      ,p_action_information1            =>     p_business_number
              ,p_action_information2            =>     p_pf_org
              ,p_action_information3            =>     'Voluntary PF Percent'
              ,p_action_information4            =>     fnd_number.number_to_canonical(l_vol_pf_rate)
	      ,p_action_information5            =>     l_classification
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );

   END IF ;

   pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  --
  END archive_pf_balances;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PF_ORG_DTLS                                 --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets the PF Organization             --
  --                  Level Data like the Business Number,PF Type         --
  --                  Registered Company Name,Representative Details      --
  --                  and archives them.                                  --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id       NUMBER                    --
  --                  p_business_number         NUMBER                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  -- 115.1 25-Aug-2007    rsaharay  Modified  cursor csr_pos              --
  -- 115.2 19-Jun-2007    mdubasi   Modified to store Business Group Id   --
  --------------------------------------------------------------------------

  PROCEDURE archive_pf_org_dtls(p_arc_pay_action_id     IN NUMBER
                                ,p_business_number      IN NUMBER)
  IS

    l_procedure			  VARCHAR2(100);
    l_message		          VARCHAR2(255);
    l_action_info_id		  NUMBER ;
    l_ovn			  NUMBER ;
    l_base_bus_no                 VARCHAR2(50) ;
    l_classification              HR_ORGANIZATION_INFORMATION.ORG_INFORMATION3%TYPE ;
    l_reg_comp_name               HR_ORGANIZATION_INFORMATION.ORG_INFORMATION4%TYPE ;
    l_representative              HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_representative_name         PER_PEOPLE_F.FIRST_NAME%TYPE;
    l_representative_desig        PER_ALL_POSITIONS.NAME%TYPE;
    l_bus_group_id                VARCHAR2(20);



    CURSOR csr_pf_org IS
    SELECT
           organization_id                            org_id ,                --OrgId
           org_information10                          base_bus_no,            --Base Business Number
           org_information10||org_information9        bus_no ,                --Business Number
           org_information3                           classification          --Classification
    FROM   hr_organization_information hr_pf_org
    WHERE  org_information_context    = 'PER_IN_PF_DF'
    AND    hr_pf_org.org_information10||org_information9  = p_business_number ;


   CURSOR csr_reg_company(p_base_bus_no VARCHAR2 )
   IS
   SELECT org_information4   --Legal Name
   FROM   hr_organization_information
   WHERE  org_information_context = 'PER_IN_COMPANY_DF'
   AND    org_information5 = p_base_bus_no ;

   CURSOR csr_pf_representative(p_pf_org NUMBER )
   IS
   SELECT
           org_information1      --Representative
   FROM    hr_organization_information hr_pf_org
   WHERE   org_information_context    = 'PER_IN_PF_REP_DF'
   AND     hr_pf_org.organization_id  = p_pf_org
   AND     g_end_date BETWEEN fnd_date.canonical_to_date(org_information2)
   AND     NVL(fnd_date.canonical_to_date(org_information3),TO_DATE('31-12-4712','DD-MM-YYYY'));

  CURSOR csr_pos(p_person_id                  VARCHAR2)
  IS
  SELECT nvl(pos.name,job.name) name
  FROM   per_all_positions     pos
        ,per_assignments_f asg
	,per_jobs          job
  WHERE  asg.position_id=pos.position_id(+)
  AND    asg.job_id=job.job_id(+)
  AND    asg.person_id = p_person_id
  AND    asg.primary_flag = 'Y'
  AND    g_end_date BETWEEN pos.date_effective(+) AND NVL(pos.date_end(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    g_end_date BETWEEN job.date_from(+) AND NVL(job.date_to(+),TO_DATE('31-12-4712','DD-MM-YYYY'))
  AND    g_end_date BETWEEN asg.effective_start_date AND asg.effective_end_date;

  CURSOR csr_emp_name(p_person_id                  VARCHAR2)
  IS
  SELECT DECODE(pep.title,NULL,hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title)
        ,SUBSTR(hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title)
        ,INSTR(hr_in_utility.per_in_full_name(pep.first_name,pep.middle_names,pep.last_name,pep.title),' ',1)+1)) name
  FROM   per_people_f       pep
  WHERE  pep.person_id = p_person_id
  AND    g_end_date BETWEEN pep.effective_start_date AND pep.effective_end_date ;




  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || 'archive_pf_org_dtls';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


    FOR rec_pf_org IN csr_pf_org
    LOOP

	 pay_in_utils.set_location(g_debug,'Org Id : '||rec_pf_org.org_id,5);

         l_representative       := NULL ;
         l_representative_desig := NULL ;
         l_representative_name  := NULL ;

         OPEN csr_pf_representative(rec_pf_org.org_id) ;
	 FETCH csr_pf_representative INTO l_representative ;
	 CLOSE csr_pf_representative ;

	 OPEN csr_pos(l_representative);
	 FETCH csr_pos INTO l_representative_desig;
	 CLOSE csr_pos ;

	 OPEN csr_emp_name(l_representative);
	 FETCH csr_emp_name INTO l_representative_name;
	 CLOSE csr_emp_name ;

	 pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_PF_ORG'
              ,p_action_information1            =>     rec_pf_org.bus_no
              ,p_action_information2            =>     rec_pf_org.org_id
              ,p_action_information3            =>     rec_pf_org.classification
              ,p_action_information4            =>     l_representative_name
              ,p_action_information5            =>     l_representative_desig
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );

	l_base_bus_no := rec_pf_org.base_bus_no ;
    END LOOP ;

    OPEN  csr_reg_company(l_base_bus_no);
    FETCH csr_reg_company INTO l_reg_comp_name ;
    CLOSE csr_reg_company ;

    SELECT business_group_id INTO l_bus_group_id --Business Group Id
    FROM pay_payroll_actions
    WHERE payroll_action_id =p_arc_pay_action_id;

    pay_in_utils.set_location(g_debug,'Business Number : '||p_business_number,15);

    pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_PF_BUSINESS_NUMBER'
              ,p_action_information1            =>     p_business_number
              ,p_action_information2            =>     g_arc_ref_no
              ,p_action_information3            =>     g_month||g_year
              ,p_action_information4            =>     g_return_type
              ,p_action_information5            =>     l_reg_comp_name
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );

    pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_PF_ARC_REF_NUMBER'
              ,p_action_information1            =>     g_return_type
              ,p_action_information2            =>     g_arc_ref_no
              ,p_action_information3            =>     g_month||g_year
              ,p_action_information4            =>     p_business_number
	      ,p_action_information5            =>     l_bus_group_id
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );


    pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  --
  END archive_pf_org_dtls;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_PF_CHALLAN_DTLS                             --
  -- Type           : PROCEDURE                                           --
  -- Access         : Private                                             --
  -- Description    : This procedure gets the Challan Information Details --
  --                  of the PF Organization and archives them.           --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_arc_pay_action_id       NUMBER                    --
  --                  p_pf_org                  NUMBER                    --
  --                  p_challan_ref             VARCHAR2                  --
  --                  p_business_number         NUMBER                    --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  -- 115.1 24-Oct-2007    rsaharay  Modified for Currency Period          --
  --------------------------------------------------------------------------

  PROCEDURE archive_pf_challan_dtls(p_arc_pay_action_id     IN NUMBER
                                    ,p_pf_org               IN NUMBER
				    ,p_challan_ref          IN VARCHAR2
				    ,p_business_number      IN NUMBER )
  IS

    l_procedure				 VARCHAR2(100);
    l_message				 VARCHAR2(255);
    l_action_info_id			 NUMBER ;
    l_ovn				 NUMBER ;

    l_Paid_Under_Protest		 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Payment_Type			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Cheque_DD_No			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Cheque_DD_Date			 DATE ;
    l_Cheque_DD_Dep_Date		 DATE ;
    l_Amount				 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Bank_Code				 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Branch_Code			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Challan_Ref			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Dep_Bank_Code			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Dep_Branch_Code			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Dep_Base_Branch			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Interest_Sec			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Legal_Charges			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Penalty				 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Branch_Name			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Branch_Addr			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Dep_Branch_Name			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Dep_Branch_Addr			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;

    l_14B_Prev_Mth                       HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_14B_Prev_Yr                        HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_14B_Challan_Ref                    HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_14B_Penal_Damages_Due              HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_14B_EPS_Penal_Damages              HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_14B_EDLI_Penal_Damages             HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_14B_EPF_Penal_Damages              HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_14B_Edli_Admin                     HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;

    l_7Q_Due_Mth			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_7Q_Due_Yr				 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_7Q_Challan_Ref			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_7Q_EPF_Damages			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_7Q_EPS_Damages			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_7Q_EDLI_Damages			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_7Q_EPF_Admin			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_7Q_EDLI_Admin			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;

    l_Misc_Challan_Ref			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE;
    l_Misc_EPF_Pay			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EPF_Rem			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EPS_Pay			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EPS_Rem			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EDLI_Pay			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EDLI_Rem			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EPF_Admin			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EPF_Admin_Rem		 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EDLI_Admin			 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;
    l_Misc_EDLI_Admin_Rem		 HR_ORGANIZATION_INFORMATION.ORG_INFORMATION1%TYPE ;




  CURSOR csr_challans
  IS
  SELECT hoi_challan.org_information4                                               Payment_Type
        ,hoi_challan.org_information5                                               Cheque_DD_No
        ,fnd_date.canonical_to_date(hoi_challan.org_information6)                   Cheque_DD_Date
        ,hoi_challan.org_information7                                               Bank_Code
        ,hoi_challan.org_information8                                               Branch_Code
        ,hoi_challan.org_information11                                              Dep_Bank_Code
        ,hoi_challan.org_information9                                               Dep_Branch_Code
        ,hoi_challan.org_information10                                              Dep_Base_Branch
  FROM   hr_organization_information hoi_challan
  WHERE  hoi_challan.organization_id = p_pf_org
  AND    hoi_challan.org_information_context ='PER_IN_PF_BANK_PAYMENT_DETAILS'
  AND    hoi_challan.org_information3= p_challan_ref;


 CURSOR csr_challans_info
  IS
  SELECT hoi_challan.org_information11                                                 Paid_Under_Protest
        ,fnd_date.canonical_to_date(hoi_challan.org_information9)                      Cheque_DD_Dep_Date
        ,fnd_number.canonical_to_number(NVL(hoi_challan.org_information3,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information4,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information5,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information6,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information7,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information8,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information13,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information14,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information15,0))          Amount
        ,hoi_challan.org_information12                                                 Challan_Ref
        ,hoi_challan.org_information13                                                 Legal_Charges
        ,hoi_challan.org_information14                                                 Interest_Sec
        ,hoi_challan.org_information15                                                 Penalty
  FROM   hr_organization_information hoi_challan
  WHERE  hoi_challan.organization_id = p_pf_org
  AND    hoi_challan.org_information_context ='PER_IN_PF_CHALLAN_INFO'
  AND    hoi_challan.org_information12= p_challan_ref;

  CURSOR csr_penal_damages
  IS
  SELECT hoi_challan.org_information1                                        Challan_Ref
        ,hoi_challan.org_information2                                        Prev_Mth
        ,hoi_challan.org_information3                                        Prev_Yr
        ,fnd_number.canonical_to_number(NVL(hoi_challan.org_information4,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information5,0)) Penal_Damages_Due
        ,fnd_number.canonical_to_number(hoi_challan.org_information6)        EPS_Penal_Damages
        ,fnd_number.canonical_to_number(hoi_challan.org_information7)        EDLI_Penal_Damages
        ,fnd_number.canonical_to_number(hoi_challan.org_information9)        EPF_Penal_Damages
        ,fnd_number.canonical_to_number(hoi_challan.org_information8)        Edli_Admin
  FROM   hr_organization_information hoi_challan
  WHERE  hoi_challan.organization_id = p_pf_org
  AND    hoi_challan.org_information_context ='PER_IN_PF_CHN_SEC14B'
  AND    hoi_challan.org_information1= p_challan_ref;

  CURSOR csr_7Q
  IS
  SELECT hoi_challan.org_information11                                       Challan_Ref
        ,hoi_challan.org_information1                                        Due_Mth
        ,hoi_challan.org_information2                                        Due_Yr
        ,fnd_number.canonical_to_number(NVL(hoi_challan.org_information3,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information4,0)) EPF_Damages
        ,fnd_number.canonical_to_number(hoi_challan.org_information5)        EPS_Damages
        ,fnd_number.canonical_to_number(hoi_challan.org_information6)        EDLI_Damages
        ,fnd_number.canonical_to_number(hoi_challan.org_information8)        EPF_Admin
        ,fnd_number.canonical_to_number(hoi_challan.org_information7)        EDLI_Admin
  FROM   hr_organization_information hoi_challan
  WHERE  hoi_challan.organization_id = p_pf_org
  AND    hoi_challan.org_information_context ='PER_IN_PF_SEC7Q_INFO'
  AND    hoi_challan.org_information11= p_challan_ref;

  CURSOR csr_misc
  IS
  SELECT hoi_challan.org_information3                                        Challan_Ref
        ,fnd_number.canonical_to_number(NVL(hoi_challan.org_information4,0))
        +fnd_number.canonical_to_number(NVL(hoi_challan.org_information5,0)) EPF_Misc_Pay
        ,hoi_challan.org_information6                                        EPF_Rem
        ,fnd_number.canonical_to_number(hoi_challan.org_information7)        EPS_Misc_Pay
        ,hoi_challan.org_information8                                        EPS_Rem
        ,fnd_number.canonical_to_number(hoi_challan.org_information9)        EDLI_Misc_Pay
        ,hoi_challan.org_information10                                       EDLI_Rem
        ,fnd_number.canonical_to_number(hoi_challan.org_information11)       EPF_Admin
        ,hoi_challan.org_information12                                       EPF_Admin_Rem
        ,fnd_number.canonical_to_number(hoi_challan.org_information13)       EDLI_Admin
        ,hoi_challan.org_information14                                       EDLI_Admin_Rem
  FROM   hr_organization_information hoi_challan
  WHERE  hoi_challan.organization_id = p_pf_org
  AND    hoi_challan.org_information_context ='PER_IN_PF_MIS_PAY_INFO'
  AND    hoi_challan.org_information3= p_challan_ref;


 CURSOR csr_branch_dtls(p_bank_code   VARCHAR2
                       ,p_branch_code VARCHAR2 )
 IS
 SELECT  hoi.org_information3      branch_name
        ,hoi.org_information4      branch_add
 FROM    hr_organization_units        hou
        ,hr_organization_information  hoi
 WHERE   hoi.organization_id = hou.organization_id
 AND     hoi.org_information_context = 'PER_IN_PF_BANK_BRANCH_DTLS'
 AND     hou.business_group_id = g_bg_id
 AND     hoi.org_information1 = p_bank_code
 AND     hoi.org_information2 = p_branch_code ;


  BEGIN
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || 'archive_pf_challan_dtls';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);



    OPEN  csr_challans;
    FETCH csr_challans INTO l_Payment_Type       ,
			    l_Cheque_DD_No       ,
			    l_Cheque_DD_Date     ,
			    l_Bank_Code          ,
			    l_Branch_Code        ,
			    l_Dep_Bank_Code      ,
    			    l_Dep_Branch_Code    ,
    			    l_Dep_Base_Branch    ;
    CLOSE csr_challans;



    OPEN  csr_challans_info;
    FETCH csr_challans_info INTO l_Paid_Under_Protest ,
			         l_Cheque_DD_Dep_Date ,
			         l_Amount             ,
	                         l_Challan_Ref        ,
				 l_Legal_Charges      ,
				 l_Interest_Sec       ,
				 l_Penalty            ;
    CLOSE csr_challans_info;




    OPEN csr_branch_dtls(l_Bank_Code,l_Branch_Code);
    FETCH csr_branch_dtls INTO l_Branch_Name , l_Branch_Addr ;
    CLOSE csr_branch_dtls ;

    OPEN csr_branch_dtls(l_Dep_Bank_Code,l_Dep_Branch_Code);
    FETCH csr_branch_dtls INTO l_Dep_Branch_Name , l_Dep_Branch_Addr ;
    CLOSE csr_branch_dtls ;


    OPEN  csr_penal_damages;
    FETCH csr_penal_damages INTO l_14B_Challan_Ref           ,
                                 l_14B_Prev_Mth              ,
			         l_14B_Prev_Yr               ,
			         l_14B_Penal_Damages_Due     ,
			         l_14B_EPS_Penal_Damages     ,
			         l_14B_EDLI_Penal_Damages    ,
                                 l_14B_EPF_Penal_Damages     ,
			         l_14B_Edli_Admin            ;
    CLOSE csr_penal_damages;

    OPEN  csr_7Q;
    FETCH csr_7Q INTO   l_7Q_Challan_Ref    ,
                        l_7Q_Due_Mth        ,
			l_7Q_Due_Yr         ,
			l_7Q_EPF_Damages    ,
			l_7Q_EPS_Damages    ,
			l_7Q_EDLI_Damages   ,
			l_7Q_EPF_Admin      ,
			l_7Q_EDLI_Admin     ;
    CLOSE csr_7Q;

    OPEN  csr_misc;
    FETCH csr_misc INTO l_Misc_Challan_Ref    ,
                        l_Misc_EPF_Pay        ,
			l_Misc_EPF_Rem        ,
			l_Misc_EPS_Pay        ,
			l_Misc_EPS_Rem        ,
			l_Misc_EDLI_Pay       ,
			l_Misc_EDLI_Rem       ,
			l_Misc_EPF_Admin      ,
			l_Misc_EPF_Admin_Rem  ,
			l_Misc_EDLI_Admin     ,
			l_Misc_EDLI_Admin_Rem ;
    CLOSE csr_misc;

    l_Amount := NVL(l_Amount,0)                    +
                NVL(l_14B_Penal_Damages_Due,0)     +
                NVL(l_14B_EPS_Penal_Damages,0)     +
		NVL(l_14B_EDLI_Penal_Damages,0)    +
		NVL(l_14B_EPF_Penal_Damages,0)	   +
		NVL(l_14B_Edli_Admin,0)	           +
		NVL(l_7Q_EPF_Damages,0)            +
		NVL(l_7Q_EPS_Damages,0)	           +
		NVL(l_7Q_EDLI_Damages,0)           +
		NVL(l_7Q_EPF_Admin,0)              +
		NVL(l_7Q_EDLI_Admin,0)             +
		NVL(l_Misc_EPF_Pay,0)              +
		NVL(l_Misc_EPS_Pay,0)              +
		NVL(l_Misc_EDLI_Pay,0)             +
		NVL(l_Misc_EPF_Admin,0)            +
		NVL(l_Misc_EDLI_Admin,0)           ;

    l_14B_Prev_Mth := TO_NUMBER(l_14B_Prev_Mth) + 3 ;
    l_14B_Prev_Yr  := SUBSTR(l_14B_Prev_Yr,1,4);
    IF l_14B_Prev_Mth > 12 THEN
      l_14B_Prev_Mth := l_14B_Prev_Mth - 12 ;
      l_14B_Prev_Yr  := TO_NUMBER(l_14B_Prev_Yr) + 1;
    END IF ;
    IF l_14B_Prev_Mth = 3 THEN
      l_14B_Prev_Yr  := l_14B_Prev_Yr - 1;
    END IF ;

    l_7Q_Due_Mth := TO_NUMBER(l_7Q_Due_Mth) + 3 ;
    l_7Q_Due_Yr  := SUBSTR(l_7Q_Due_Yr,1,4);
    IF l_7Q_Due_Mth > 12 THEN
      l_7Q_Due_Mth := l_7Q_Due_Mth - 12 ;
      l_7Q_Due_Yr  := TO_NUMBER(l_7Q_Due_Yr) + 1;
    END IF ;
    IF l_7Q_Due_Mth = 3 THEN
      l_7Q_Due_Yr  := l_7Q_Due_Yr - 1;
    END IF ;


         IF l_Challan_Ref IS NOT NULL
         THEN
	    pay_in_utils.set_location(g_debug,'Archiving : IN_PF_CHALLAN'||l_Challan_Ref,5);
	    pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_PF_CHALLAN'
	      ,p_action_information1            =>     p_business_number
              ,p_action_information2            =>     l_Payment_Type
              ,p_action_information3            =>     p_pf_org
              ,p_action_information4            =>     l_Cheque_DD_No
              ,p_action_information5            =>     fnd_date.date_to_canonical(l_Cheque_DD_Date)
              ,p_action_information6            =>     fnd_date.date_to_canonical(l_Cheque_DD_Dep_Date)
              ,p_action_information7            =>     fnd_number.number_to_canonical(l_Amount)
              ,p_action_information8            =>     l_Challan_Ref
              ,p_action_information9            =>     l_Bank_Code
              ,p_action_information11           =>     l_Branch_Code
	      ,p_action_information12           =>     l_Branch_Name
	      ,p_action_information13           =>     l_Branch_Addr
              ,p_action_information14           =>     l_Dep_Bank_Code
              ,p_action_information15           =>     l_Dep_Branch_Code
              ,p_action_information16           =>     l_Dep_Branch_Name
              ,p_action_information17           =>     l_Dep_Branch_Addr
              ,p_action_information18           =>     l_Dep_Base_Branch
              ,p_action_information20           =>     l_Paid_Under_Protest
              ,p_action_information21           =>     fnd_number.number_to_canonical(l_Interest_Sec)
              ,p_action_information22           =>     fnd_number.number_to_canonical(l_Legal_Charges)
              ,p_action_information23           =>     fnd_number.number_to_canonical(l_Penalty)
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );
         END IF ;

         IF  l_14B_Challan_Ref IS NOT NULL
	 THEN

	   pay_in_utils.set_location(g_debug,'Archiving : IN_PF_14B'||l_14B_Challan_Ref,6);
	   pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_PF_14B'
              ,p_action_information1            =>     l_14B_Prev_Mth
              ,p_action_information2            =>     l_14B_Prev_Yr
              ,p_action_information3            =>     l_14B_Challan_Ref
              ,p_action_information4            =>     fnd_number.number_to_canonical(l_14B_Penal_Damages_Due)
              ,p_action_information5            =>     fnd_number.number_to_canonical(l_14B_EPS_Penal_Damages)
              ,p_action_information6            =>     fnd_number.number_to_canonical(l_14B_EDLI_Penal_Damages)
              ,p_action_information7            =>     fnd_number.number_to_canonical(l_14B_EPF_Penal_Damages)
              ,p_action_information8            =>     fnd_number.number_to_canonical(l_14B_Edli_Admin)
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );
         END IF ;

	 IF  l_7Q_Challan_Ref IS NOT NULL
	 THEN
	     pay_in_utils.set_location(g_debug,'Archiving : IN_PF_7Q'||l_7Q_Challan_Ref,7);
	     pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_PF_7Q'
              ,p_action_information1            =>     l_7Q_Due_Mth
              ,p_action_information2            =>     l_7Q_Due_Yr
              ,p_action_information3            =>     l_7Q_Challan_Ref
              ,p_action_information4            =>     fnd_number.number_to_canonical(l_7Q_EPF_Damages)
              ,p_action_information5            =>     fnd_number.number_to_canonical(l_7Q_EPS_Damages)
              ,p_action_information6            =>     fnd_number.number_to_canonical(l_7Q_EDLI_Damages)
              ,p_action_information7            =>     fnd_number.number_to_canonical(l_7Q_EPF_Admin)
              ,p_action_information8            =>     fnd_number.number_to_canonical(l_7Q_EDLI_Admin)
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );
         END IF ;

	 IF  l_Misc_Challan_Ref IS NOT NULL
	 THEN
	    pay_in_utils.set_location(g_debug,'Archiving : IN_PF_MISC'||l_Misc_Challan_Ref,8);
            pay_action_information_api.create_action_information
              (p_action_context_id              =>     p_arc_pay_action_id
              ,p_action_context_type            =>     'PA'
              ,p_action_information_category    =>     'IN_PF_MISC'
              ,p_action_information1            =>     l_Misc_Challan_Ref
              ,p_action_information2            =>     fnd_number.number_to_canonical(l_Misc_EPF_Pay)
              ,p_action_information3            =>     l_Misc_EPF_Rem
              ,p_action_information4            =>     fnd_number.number_to_canonical(l_Misc_EPS_Pay)
              ,p_action_information5            =>     l_Misc_EPS_Rem
              ,p_action_information6            =>     fnd_number.number_to_canonical(l_Misc_EDLI_Pay)
              ,p_action_information7            =>     l_Misc_EDLI_Rem
              ,p_action_information8            =>     fnd_number.number_to_canonical(l_Misc_EPF_Admin)
              ,p_action_information9            =>     l_Misc_EPF_Admin_Rem
              ,p_action_information10           =>     fnd_number.number_to_canonical(l_Misc_EDLI_Admin)
              ,p_action_information11           =>     l_Misc_EDLI_Admin_Rem
              ,p_action_information_id          =>     l_action_info_id
              ,p_object_version_number          =>     l_ovn
              );
        END IF ;


          pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,40);


  EXCEPTION
    WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR', 'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 30);
       pay_in_utils.trace(l_message,l_procedure);
       RAISE;
  --
  END archive_pf_challan_dtls;


  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ASSIGNMENT_ACTION_CODE                              --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : This procedure further restricts the assignment_id's--
  --                  returned by range_code.                             --
  --                  It filters the assignments selected by range_code   --
  --                  procedure.                                          --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_payroll_action_id    NUMBER                       --
  --                  p_start_person         NUMBER                       --
  --                  p_end_person           NUMBER                       --
  --                  p_chunk                NUMBER                       --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  -- 115.1 24-Oct-2007    rsaharay  Modified csr_challans                 --
  --------------------------------------------------------------------------
  --

  PROCEDURE assignment_action_code (
                                     p_payroll_action_id   IN NUMBER
                                    ,p_start_person        IN NUMBER
                                    ,p_end_person          IN NUMBER
                                    ,p_chunk               IN NUMBER
                                   )
  IS

    l_procedure                 VARCHAR2(100);
    l_action_id                 NUMBER;
    l_payroll_id                NUMBER;
    l_message                   VARCHAR2(255);
    l_match                     BOOLEAN := FALSE ;
    l_challan_match             BOOLEAN := FALSE ;
    l_rev_chk_asg               BOOLEAN := FALSE ;
    l_supp                      BOOLEAN := FALSE ;
    l_check                     NUMBER ;
    l_reg_check                 NUMBER ;
    l_action_info_id            NUMBER ;
    l_ovn                       NUMBER ;
    l_pf_check                  NUMBER ;




  /*Cursor to get the Assignments that needs to be archived for
    the Regular Monthly Return.
    Will pick up assignments having 'P','U','I' in Current Month and
    attached to a PF Organization having the Business Number*/

  CURSOR csr_process_assignments
    IS
   SELECT DISTINCT paa_init.assignment_id
   FROM   pay_assignment_actions paa_init,
          pay_payroll_actions ppa_init,
          per_assignments_f paf,
	  hr_organization_information hoi
   WHERE  ppa_init.payroll_action_id = paa_init.payroll_action_id
   AND    ppa_init.action_type IN ('P','U','I')
   AND    ppa_init.action_status = 'C'
   AND    ppa_init.business_group_id = g_bg_id
   AND    p_payroll_action_id IS NOT NULL
   AND    paf.person_id BETWEEN
            p_start_person AND p_end_person
   AND    paf.assignment_id = paa_init.assignment_id
   AND   (to_char(paf.effective_start_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
         OR  to_char(paf.effective_end_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
         OR  g_end_date between paf.effective_start_date and paf.effective_end_date)
   AND   ppa_init.effective_date BETWEEN g_start_date AND g_end_date
   AND   hoi.org_information_context    = 'PER_IN_PF_DF'
   AND   hoi.org_information10||hoi.org_information9 = NVL(g_business_no,hoi.org_information10||hoi.org_information9)
   AND   hoi.org_information10 IS NOT NULL
   AND   hoi.org_information9 IS NOT NULL
   AND   TO_CHAR (hoi.organization_id) IN
                                         (SELECT  scl.segment2
					  FROM    hr_soft_coding_keyflex  scl
					  WHERE   scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
					  AND     scl.enabled_flag = 'Y');


   /*Cursor to get the Assignments that needs to be archived for
    the Supplementary Monthly Return.
    The Cursor will pick up the new Assignments and the Terminated
    Assignments not archived in the Regular Return having 'P','U','I'
    in Current Month and attached to a PF Organization having the Business Number*/

   CURSOR csr_process_supp_assignments(p_business_no  VARCHAR2 )
   IS
   SELECT DISTINCT paa_init.assignment_id
   FROM   pay_assignment_actions paa_init,
          pay_payroll_actions ppa_init,
          per_assignments_f paf,
	  hr_organization_information hoi
   WHERE  ppa_init.payroll_action_id = paa_init.payroll_action_id
   AND    ppa_init.action_type IN ('P','U','I')
   AND    ppa_init.action_status = 'C'
   AND    ppa_init.business_group_id = g_bg_id
   AND    p_payroll_action_id IS NOT NULL
   AND    paf.person_id BETWEEN
              p_start_person AND p_end_person
   AND    paf.assignment_id = paa_init.assignment_id
   AND    (to_char(paf.effective_start_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
           OR  to_char(paf.effective_end_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
           OR  g_end_date between paf.effective_start_date and paf.effective_end_date)
   AND    ppa_init.effective_date BETWEEN g_start_date AND g_end_date
   AND    hoi.org_information_context    = 'PER_IN_PF_DF'
   AND    hoi.org_information10||hoi.org_information9 = p_business_no
   AND    hoi.org_information10 IS NOT NULL
   AND    hoi.org_information9 IS NOT NULL
   AND   TO_CHAR (hoi.organization_id) IN
                                         (SELECT  scl.segment2
					  FROM    hr_soft_coding_keyflex  scl
					  WHERE   scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
					  AND     scl.enabled_flag = 'Y')
   AND    NOT EXISTS ( SELECT paa.assignment_id
		       FROM   pay_assignment_actions  paa
                             ,pay_action_information pai
		             ,hr_organization_information  hoi
			     ,pay_payroll_actions ppa
                       WHERE  paa.assignment_id = paa_init.assignment_id
                       AND    paa.assignment_action_id    = pai.action_context_id
		       AND    ppa.payroll_action_id = paa.payroll_action_id
		       AND    ppa.report_type = 'IN_PF_ARCHIVE'
		       AND    ppa.action_type = 'X'
		       AND    ppa.action_status = 'C'
		       AND    pai.action_context_type = 'AAP'
		       AND    hoi.org_information7 = pai.action_information2
		       AND    pai.action_information_category = 'IN_PF_PERSON_DTLS'
		       AND    hoi.org_information_context = 'PER_IN_COMPANY_RECEP_MAP'
		       AND    hoi.org_information3 = p_business_no
		       AND    hoi.org_information1 = g_challan_year
                       AND    hoi.org_information2 = g_challan_mth
                     )
   UNION
   SELECT DISTINCT paa_init.assignment_id
   FROM   pay_assignment_actions paa_init,
          per_periods_of_service pps,
          pay_payroll_actions ppa_init,
          per_assignments_f paf,
	  hr_organization_information hoi
   WHERE  ppa_init.payroll_action_id = paa_init.payroll_action_id
   AND    paf.period_of_service_id = pps.period_of_service_id
   AND    ppa_init.action_type IN ('P','U','I')
   AND    ppa_init.action_status = 'C'
   AND    ppa_init.business_group_id = g_bg_id
   AND    p_payroll_action_id IS NOT NULL
   AND    paf.person_id BETWEEN
              p_start_person AND p_end_person
   AND    paf.assignment_id = paa_init.assignment_id
   AND    TO_CHAR(pps.actual_termination_date,'Month-YYYY') = to_char(g_start_date,'Month-YYYY')
   AND    (to_char(paf.effective_start_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
           OR  to_char(paf.effective_end_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
           OR  g_end_date between paf.effective_start_date and paf.effective_end_date)
   AND    ppa_init.effective_date BETWEEN g_start_date AND g_end_date
   AND    hoi.org_information_context    = 'PER_IN_PF_DF'
   AND    hoi.org_information10||hoi.org_information9 = p_business_no
   AND    hoi.org_information10 IS NOT NULL
   AND    hoi.org_information9 IS NOT NULL
   AND   TO_CHAR (hoi.organization_id) IN
                                         (SELECT  scl.segment2
					  FROM    hr_soft_coding_keyflex  scl
					  WHERE   scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
					  AND     scl.enabled_flag = 'Y')
   AND    NOT EXISTS ( SELECT paa.assignment_id
		       FROM   pay_assignment_actions  paa
                             ,pay_action_information pai
		             ,hr_organization_information  hoi
		             ,hr_organization_units  hou
			     ,pay_payroll_actions ppa
                       WHERE  paa.assignment_id = paa_init.assignment_id
                       AND    paa.assignment_action_id    = pai.action_context_id
		       AND    ppa.payroll_action_id = paa.payroll_action_id
		       AND    hoi.organization_id = hou.organization_id
		       AND    ppa.report_type = 'IN_PF_ARCHIVE'
		       AND    ppa.action_type = 'X'
		       AND    ppa.action_status = 'C'
		       AND    pai.action_context_type = 'AAP'
		       AND    hoi.org_information7 = pai.action_information2
		       AND    pai.action_information_category = 'IN_PF_PERSON_DTLS'
		       AND    hoi.org_information_context = 'PER_IN_COMPANY_RECEP_MAP'
		       AND    hoi.org_information3 = p_business_no
		       AND    hoi.org_information1 = g_challan_year
                       AND    hoi.org_information2 = g_challan_mth
	               AND    TO_CHAR(fnd_date.canonical_to_date(pai.action_information8),'Month-YYYY') =  TO_CHAR (g_start_date,'Month-YYYY')
		       );


  /*Cursor to get the Assignments that needs to be archived for
    the Revised Monthly Return.Will pick up assignments having
    'P','U','I' in Current Month and attached to a PF Organization
    having the Business Number*/

  CURSOR csr_process_rev_assignments(p_business_no  VARCHAR2)
    IS
   SELECT DISTINCT paa_init.assignment_id
   FROM   pay_assignment_actions paa_init,
          pay_payroll_actions ppa_init,
          per_assignments_f paf,
	  hr_organization_information hoi
   WHERE  ppa_init.payroll_action_id = paa_init.payroll_action_id
   AND    ppa_init.action_type IN ('P','U','I')
   AND    ppa_init.action_status = 'C'
   AND    ppa_init.business_group_id = g_bg_id
   AND    p_payroll_action_id IS NOT NULL
   AND    paf.person_id BETWEEN
            p_start_person AND p_end_person
   AND    paf.assignment_id = paa_init.assignment_id
   AND   (to_char(paf.effective_start_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
         OR  to_char(paf.effective_end_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
         OR  g_end_date between paf.effective_start_date and paf.effective_end_date)
   AND   ppa_init.effective_date BETWEEN g_start_date AND g_end_date
   AND   hoi.org_information_context    = 'PER_IN_PF_DF'
   AND   hoi.org_information10||hoi.org_information9 = p_business_no
   AND   hoi.org_information10 IS NOT NULL
   AND   hoi.org_information9 IS NOT NULL
   AND   TO_CHAR (hoi.organization_id) IN
                                         (SELECT  scl.segment2
					  FROM    hr_soft_coding_keyflex  scl
					  WHERE   scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
					  AND     scl.enabled_flag = 'Y');


  /*Cursor to get the new Challans that needs to be archived for
    the Supplementary Monthly Return.
    Will pick up the Challans for the Business Numbers which were
    not archived in the Archive mapped to the 'PER_IN_COMPANY_RECEP_MAP'*/

  CURSOR csr_challans(p_pf_org      NUMBER
                     ,p_business_no NUMBER )
  IS
  SELECT
         hoi_challan.org_information12                   Challan_Ref
  FROM   hr_organization_information hoi_challan
  WHERE  hoi_challan.organization_id = p_pf_org
  AND    hoi_challan.org_information_context ='PER_IN_PF_CHALLAN_INFO'
  AND    hoi_challan.org_information1 = g_challan_year
  AND    hoi_challan.org_information2 = g_challan_mth
  AND NOT EXISTS (SELECT  pai.action_information8
                  FROM    pay_action_information pai,
                          pay_payroll_Actions ppa
		  WHERE   pai.action_information8 = hoi_challan.org_information12
		  AND     pai.action_information_category = 'IN_PF_CHALLAN'
                  AND     pai.action_context_type = 'PA'
		  AND     pai.action_information3 = p_pf_org
		  AND     pai.action_context_id = ppa.payroll_action_id
                  AND     ppa.action_type ='X'
                  AND     ppa.action_status='C'
                  AND     ppa.report_type='IN_PF_ARCHIVE'
		  AND     pai.action_context_id IN
	                         (SELECT action_context_id
				  FROM   pay_action_information painfo
				  WHERE  painfo.action_information2 IN (SELECT hoi.org_information7
		                                                        FROM   hr_organization_information  hoi ,
									       hr_organization_units hou
                                                                        WHERE  hoi.organization_id = hou.organization_id
									AND    hoi.org_information_context = 'PER_IN_COMPANY_RECEP_MAP'
                                                                        AND    hoi.org_information3 = p_business_no
						                        AND    hoi.org_information1 = g_challan_year
								        AND    hoi.org_information2 = g_challan_mth
				                                        )
				  AND    painfo.action_context_type = 'PA'
                                  AND    painfo.action_information_category = 'IN_PF_BUSINESS_NUMBER')

                    );

   CURSOR csr_revised_challans(p_pf_org      NUMBER)
   IS
   SELECT
          hoi_challan.org_information12                   Challan_Ref
   FROM   hr_organization_information hoi_challan
   WHERE  hoi_challan.organization_id = p_pf_org
   AND    hoi_challan.org_information_context ='PER_IN_PF_CHALLAN_INFO'
   AND    hoi_challan.org_information1 = g_challan_year
   AND    hoi_challan.org_information2 = g_challan_mth ;


   /*Cursor to get the Business Numbers for which Regular Return has
     been mapped to 'PER_IN_COMPANY_RECEP_MAP'.
     For a Business Number to run Supplementary/Revised archive a
     Regular archive needs to be mapped to 'PER_IN_COMPANY_RECEP_MAP'.
   */
   CURSOR csr_reg_return
   IS
   SELECT org_information3 bus_no
   FROM   hr_organization_information
   WHERE  org_information_context = 'PER_IN_COMPANY_RECEP_MAP'
   AND    org_information1 = g_challan_year
   AND    org_information2 = g_challan_mth
   AND    org_information3  = NVL(g_business_no , org_information3)
   AND    org_information4 = 'R'
   GROUP BY org_information3 ;

  CURSOR csr_arch_ref(p_business_no IN NUMBER)
  IS
  SELECT DISTINCT org_information7 Archive_Ref_No
  FROM   hr_organization_information
  WHERE  org_information_context = 'PER_IN_COMPANY_RECEP_MAP'
  AND    org_information1 = g_challan_year
  AND    org_information2 = g_challan_mth
  AND    org_information3 = NVL(p_business_no,org_information3) ;


  CURSOR csr_action_context_id(p_arc_ref VARCHAR2
                              ,p_business_no IN NUMBER)
  IS
  SELECT DISTINCT action_context_id
  FROM pay_action_information pai,
       pay_assignment_actions paa,
       pay_payroll_Actions ppa
  WHERE action_information2 = p_arc_ref
  AND   action_context_type = 'AAP'
  AND   action_information_category = 'IN_PF_PERSON_DTLS'
  AND   action_information1 = nvl(p_business_no,action_information1)
  AND   pai.action_context_id = paa.assignment_action_id
  AND   paa.payroll_action_id = ppa.payroll_action_id
  AND   ppa.action_type ='X'
  AND   ppa.action_status='C'
  AND   ppa.report_type='IN_PF_ARCHIVE'
  ;




   CURSOR csr_pf_org_id(p_business_no IN NUMBER)
   IS
   SELECT  hr_pf_org.organization_id     pf_org       --PF Org Id
   FROM    hr_organization_information hr_pf_org
   WHERE   org_information_context    = 'PER_IN_PF_DF'
   AND     org_information10||org_information9  = p_business_no ;





   CURSOR csr_pay_action_level_check(p_payroll_action_id    NUMBER
                                    ,p_business_no IN NUMBER
                                  )
   IS
   SELECT  1
   FROM    pay_action_information pai
   WHERE   pai.action_information_category = 'IN_PF_ORG'
   AND     pai.action_context_type         = 'PA'
   AND     pai.action_context_id           = p_payroll_action_id
   AND     pai.action_information1         = p_business_no
   AND     ROWNUM =1;

  CURSOR csr_pay_action_level_pf_check(p_payroll_action_id    NUMBER
                                      ,p_pf_org IN NUMBER
                                  )
  IS
  SELECT 1
  FROM  pay_action_information pai
  WHERE pai.action_information_category = 'IN_PF_CHALLAN'
  AND   pai.action_context_type         = 'PA'
  AND   pai.action_context_id           = p_payroll_action_id
  AND   pai.action_information3         = p_pf_org
  AND   ROWNUM =1;





  BEGIN
  --
    g_debug := hr_utility.debug_enabled;
    l_procedure  :=  g_package || 'assignment_action_code';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);
    pay_in_utils.set_location(g_debug,'p_start_person: '||p_start_person,10);
    pay_in_utils.set_location(g_debug,'p_end_person: '||p_end_person,10);

    initialization_code (p_payroll_action_id);


    IF g_return_type = 'S'   --Archive for Supplementary Return Starts.
    THEN
      pay_in_utils.set_location(g_debug,'Entering: Supplementary',5);
      FOR rec_reg_return IN csr_reg_return
      LOOP
         pay_in_utils.set_location(g_debug,'Business Number:'||rec_reg_return.bus_no,15);
	 FOR rec_pf_org_id IN csr_pf_org_id(rec_reg_return.bus_no)
         LOOP
             l_pf_check := NULL ;

             OPEN  csr_pay_action_level_pf_check(p_payroll_action_id,rec_pf_org_id.pf_org);
             FETCH csr_pay_action_level_pf_check INTO l_pf_check;
             CLOSE csr_pay_action_level_pf_check;
	     IF l_pf_check IS NULL THEN
	      FOR rec_challans IN csr_challans(rec_pf_org_id.pf_org,rec_reg_return.bus_no)
              LOOP
	       archive_pf_challan_dtls(p_payroll_action_id,rec_pf_org_id.pf_org,rec_challans.Challan_Ref,rec_reg_return.bus_no);
	       l_supp := TRUE ;
	      END LOOP;
	     END IF ;


         END LOOP ;
	 FOR csr_rec IN csr_process_supp_assignments(rec_reg_return.bus_no)
         LOOP
              SELECT pay_assignment_actions_s.NEXTVAL
              INTO l_action_id
              FROM dual;

              IF g_debug THEN
                 pay_in_utils.trace('l_action_id                 : ',l_action_id);
                 pay_in_utils.trace('csr_rec.assignment_id       : ',csr_rec.assignment_id);
              END IF ;

              hr_nonrun_asact.insact(lockingactid  => l_action_id
                                    ,assignid       => csr_rec.assignment_id
                                    ,pactid         => p_payroll_action_id
                                    ,chunk          => p_chunk
                                    );

             /*Locks all the Assignment_action_id s for the archives that have been
	       mapped to 'PER_IN_COMPANY_RECEP_MAP'*/
	     FOR rec_arch_ref IN csr_arch_ref(rec_reg_return.bus_no)
	     LOOP
	       FOR rec_action_context_id IN csr_action_context_id(rec_arch_ref.Archive_Ref_No,rec_reg_return.bus_no)
	       LOOP
	          hr_nonrun_asact.insint(l_action_id,rec_action_context_id.action_context_id);
	       END LOOP ;
	     END LOOP ;
	     l_supp := TRUE ;
         END LOOP ;

	 /*If some new Challan/Assignment is archived then only archive the
	   PF Org Details/Business Number Details.*/
         IF l_supp THEN
	   l_check := NULL ;

	   OPEN csr_pay_action_level_check(p_payroll_action_id,rec_reg_return.bus_no);
           FETCH csr_pay_action_level_check INTO l_check;
           CLOSE csr_pay_action_level_check;

	   IF l_check IS NULL
           THEN
	     archive_pf_org_dtls(p_payroll_action_id,rec_reg_return.bus_no);
           END IF ;
	 END IF ;
	 l_supp := FALSE ;
      END LOOP ;
    --Archive for Supplementary Return Ends.

    ELSIF g_return_type = 'V' --Archive for Revised Return Starts.
    THEN
      pay_in_utils.set_location(g_debug,'Entering: Revised',5);
      FOR rec_reg_return IN csr_reg_return
      LOOP
         pay_in_utils.set_location(g_debug,'Business Number:'||rec_reg_return.bus_no,15);
	 FOR rec_pf_org_id IN csr_pf_org_id(rec_reg_return.bus_no)
         LOOP

             l_pf_check := NULL ;

             OPEN  csr_pay_action_level_pf_check(p_payroll_action_id,rec_pf_org_id.pf_org);
             FETCH csr_pay_action_level_pf_check INTO l_pf_check;
             CLOSE csr_pay_action_level_pf_check;

	     IF l_pf_check IS NULL THEN
	      FOR rec_challans IN csr_revised_challans(rec_pf_org_id.pf_org)
              LOOP
	       archive_pf_challan_dtls(p_payroll_action_id,rec_pf_org_id.pf_org,rec_challans.Challan_Ref,rec_reg_return.bus_no);
	       l_supp := TRUE ;
	      END LOOP;
	     END IF ;


         END LOOP ;

	 FOR csr_rec IN csr_process_rev_assignments(rec_reg_return.bus_no)
         LOOP
              SELECT pay_assignment_actions_s.NEXTVAL
              INTO l_action_id
              FROM dual;

              IF g_debug THEN
                 pay_in_utils.trace('l_action_id                 : ',l_action_id);
                 pay_in_utils.trace('csr_rec.assignment_id       : ',csr_rec.assignment_id);
              END IF ;

              hr_nonrun_asact.insact(lockingactid  => l_action_id
                                    ,assignid       => csr_rec.assignment_id
                                    ,pactid         => p_payroll_action_id
                                    ,chunk          => p_chunk
                                    );

             /*Locks all the Assignment_action_id s for the archives that have been
	       mapped to 'PER_IN_COMPANY_RECEP_MAP'*/
	     FOR rec_arch_ref IN csr_arch_ref(rec_reg_return.bus_no)
	     LOOP
	       FOR rec_action_context_id IN csr_action_context_id(rec_arch_ref.Archive_Ref_No,rec_reg_return.bus_no)
	       LOOP
	          hr_nonrun_asact.insint(l_action_id,rec_action_context_id.action_context_id);
	       END LOOP ;
	     END LOOP ;
	     l_supp := TRUE ;
         END LOOP ;

	 /*If some Challan/Assignment is archived then only archive the
	   PF Org Details/Business Number Details.*/
         IF l_supp THEN
	   l_check := NULL ;

	   OPEN csr_pay_action_level_check(p_payroll_action_id,rec_reg_return.bus_no);
           FETCH csr_pay_action_level_check INTO l_check;
           CLOSE csr_pay_action_level_check;

	   IF l_check IS NULL
           THEN
	     archive_pf_org_dtls(p_payroll_action_id,rec_reg_return.bus_no);
           END IF ;
	 END IF ;
	 l_supp := FALSE ;
      END LOOP ;
    --Archive for Revised Return Ends.

    ELSE    --Archive for Regular Return Starts.
      pay_in_utils.set_location(g_debug,'Entering: Regular',5);
      FOR csr_rec IN csr_process_assignments
      LOOP

        SELECT pay_assignment_actions_s.NEXTVAL
              INTO l_action_id
              FROM dual;

        IF g_debug THEN
             pay_in_utils.trace('l_action_id                 : ',l_action_id);
             pay_in_utils.trace('csr_rec.assignment_id       : ',csr_rec.assignment_id);
        END IF ;

           hr_nonrun_asact.insact(lockingactid  => l_action_id
                                ,assignid       => csr_rec.assignment_id
                                ,pactid         => p_payroll_action_id
                                ,chunk          => p_chunk
                                );

      END LOOP ;
     --Archive for Regular Return Ends.
    END IF ;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,30);
    --
  EXCEPTION
    --
  WHEN OTHERS THEN
      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR',
      'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 50);
       pay_in_utils.trace(l_message,l_procedure);
      RAISE;
    --
  END assignment_action_code;



  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : ARCHIVE_CODE                                        --
  -- Type           : PROCEDURE                                           --
  -- Access         : Public                                              --
  -- Description    : Procedure to call the internal procedures to        --
  --                  actually archive the data. The procedures           --
  --                  called are                                          --
  --                    archive_pf_balances                               --
  --                    archive_pf_emp_dtls                               --
  --                    archive_pf_org_dtls                               --
  --                    archive_pf_challan_dtls                           --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_assignment_action_id       NUMBER                 --
  --                  p_effective_date             DATE                   --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 115.0 01-Aug-2007    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------
  --

   PROCEDURE archive_code (
                           p_assignment_action_id  IN NUMBER
                          ,p_effective_date        IN DATE

                         )
  IS
  --
    l_procedure                       VARCHAR2(100);
    l_message                         VARCHAR2(255);
    l_assignment_id                   NUMBER ;
    l_arc_pay_action_id               NUMBER ;
    l_person_id                       NUMBER ;
    l_run_asg_action_id               NUMBER ;
    l_check                           NUMBER;
    l_pf_chk                          NUMBER;
    l_pf_check                        NUMBER;


    CURSOR csr_get_assignment_pact_id
    IS
    SELECT paa.assignment_id
          ,paa.payroll_action_id
          ,paf.person_id
    FROM   pay_assignment_actions  paa
          ,per_assignments_f paf
    WHERE  paa.assignment_action_id = p_assignment_action_id
    AND    paa.assignment_id = paf.assignment_id
    AND    ROWNUM =1;


    CURSOR csr_get_pf_archival_details(p_start_date       DATE
                                   ,p_end_date         DATE
				   ,p_assignment_id    NUMBER)
    IS
    SELECT TO_NUMBER(SUBSTR(MAX(LPAD(paa.action_sequence,15,'0')||paa.assignment_action_id),16)) run_asg_action_id
      FROM pay_assignment_actions paa
          ,pay_payroll_actions ppa
          ,per_assignments_f paf
     WHERE paf.assignment_id = paa.assignment_id
       AND paf.assignment_id = p_assignment_id
       AND paa.payroll_action_id = ppa.payroll_action_id
       AND ppa.action_type IN('R','Q','I','B')
       AND ppa.payroll_id    = paf.payroll_id
       AND ppa.action_status ='C'
       AND ppa.effective_date between p_start_date and p_end_date
       AND paa.source_action_id IS NULL
       AND (1 = DECODE(ppa.action_type,'I',1,0)
            OR EXISTS (SELECT ''
                     FROM pay_action_interlocks intk,
                          pay_assignment_actions paa1,
                          pay_payroll_actions ppa1
                    WHERE intk.locked_action_id = paa.assignment_Action_id
                      AND intk.locking_action_id =  paa1.assignment_action_id
                      AND paa1.payroll_action_id =ppa1.payroll_action_id
                      AND paa1.assignment_id = p_assignment_id
                      AND ppa1.action_type in('P','U')
                      AND ppa.action_type in('R','Q','B')
                      AND ppa1.action_status ='C'
                      AND ppa1.effective_date BETWEEN p_start_date and p_end_date
                      AND ROWNUM =1 ));

   CURSOR csr_get_pf_org
   IS
   SELECT  hr_pf_org.organization_id                     pf_org,
           org_information10                             base_bus_no,
           org_information10||org_information9           business_number
   FROM    hr_organization_information hr_pf_org
          ,hr_organization_units      hou
   WHERE   hou.organization_id = hr_pf_org.organization_id
   AND     hou.business_group_id = g_bg_id
   AND     org_information_context    = 'PER_IN_PF_DF'
   AND     org_information10||org_information9 = NVL(g_business_no,org_information10||org_information9)
   AND     org_information10 IS NOT NULL
   AND     org_information9  IS NOT NULL ;



   CURSOR csr_challans(p_pf_org  VARCHAR2 )
   IS
   SELECT
          hoi_challan.org_information12                   Challan_Ref
   FROM   hr_organization_information hoi_challan
   WHERE  hoi_challan.organization_id = p_pf_org
   AND    hoi_challan.org_information_context ='PER_IN_PF_CHALLAN_INFO'
   AND    hoi_challan.org_information1 = g_challan_year
   AND    hoi_challan.org_information2 = g_challan_mth ;


  CURSOR csr_pay_action_level_check(p_payroll_action_id    NUMBER
                                  ,p_business_no IN NUMBER
                                  )
  IS
  SELECT 1
  FROM  pay_action_information pai
  WHERE pai.action_information_category = 'IN_PF_ORG'
  AND   pai.action_context_type         = 'PA'
  AND   pai.action_context_id           = p_payroll_action_id
  AND   pai.action_information1         = p_business_no
  AND   ROWNUM =1;


  CURSOR csr_pay_action_level_pf_check(p_payroll_action_id    NUMBER
                                  ,p_pf_org IN NUMBER
                                  )
  IS
  SELECT 1
  FROM  pay_action_information pai
  WHERE pai.action_information_category = 'IN_PF_CHALLAN'
  AND   pai.action_context_type         = 'PA'
  AND   pai.action_context_id           = p_payroll_action_id
  AND   pai.action_information3         = p_pf_org
  AND   ROWNUM =1;


 CURSOR csr_chk_pf_org(p_pf_org     NUMBER ,
                   p_assignment NUMBER )
 IS
 SELECT 1
 FROM   per_assignments_f paf,
        hr_soft_coding_keyflex  scl
 WHERE  (to_char(paf.effective_start_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
      OR to_char(paf.effective_end_date,'Month-YYYY')=to_char(g_end_date,'Month-YYYY')
      OR  g_end_date between paf.effective_start_date and paf.effective_end_date)
 AND    scl.soft_coding_keyflex_id = paf.soft_coding_keyflex_id
 AND    scl.enabled_flag = 'Y'
 AND    scl.segment2 = p_pf_org
 AND    assignment_id = p_assignment;

  --
  BEGIN
  --
   g_debug := hr_utility.debug_enabled;
   l_procedure  :=  g_package || 'archive_code';
   pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   OPEN  csr_get_assignment_pact_id;
   FETCH csr_get_assignment_pact_id INTO l_assignment_id ,l_arc_pay_action_id,l_person_id;
   CLOSE csr_get_assignment_pact_id;

   OPEN  csr_get_pf_archival_details(g_start_date,g_end_date,l_assignment_id);
   FETCH csr_get_pf_archival_details INTO l_run_asg_action_id;
   CLOSE csr_get_pf_archival_details;

   IF l_run_asg_action_id IS NOT NULL
   THEN


   FOR rec_pf_org IN csr_get_pf_org
   LOOP
   l_pf_chk:=0;
   OPEN csr_chk_pf_org(rec_pf_org.pf_org,l_assignment_id);
   FETCH csr_chk_pf_org INTO l_pf_chk;
   CLOSE csr_chk_pf_org ;

   IF l_pf_chk =1
   THEN
     pay_in_utils.set_location(g_debug,'Archiving Employee Dtls ',5);
     archive_pf_emp_dtls(l_run_asg_action_id,p_assignment_action_id,l_assignment_id,rec_pf_org.pf_org,rec_pf_org.business_number);
     archive_pf_balances(l_run_asg_action_id,p_assignment_action_id,l_assignment_id,rec_pf_org.pf_org,rec_pf_org.business_number);
   END IF ;


       OPEN  csr_pay_action_level_check(l_arc_pay_action_id,rec_pf_org.business_number);
       FETCH csr_pay_action_level_check INTO l_check;
       CLOSE csr_pay_action_level_check;

        /*Org Level Data is archived in Procedure assignment_action_code for Revised/Supplementary Return.*/
         IF l_check IS NULL  AND g_return_type = 'R'
         THEN
	  pay_in_utils.set_location(g_debug,'Archiving Org Dtls ',15);
	  archive_pf_org_dtls(l_arc_pay_action_id,rec_pf_org.business_number);
	 END IF ;
         l_check := NULL ;

	 OPEN  csr_pay_action_level_pf_check(l_arc_pay_action_id,rec_pf_org.pf_org);
         FETCH csr_pay_action_level_pf_check INTO l_pf_check;
         CLOSE csr_pay_action_level_pf_check;

         /*Org Level Data is archived in Procedure assignment_action_code for Revised/Supplementary Return.*/
	 IF l_pf_check IS NULL AND g_return_type = 'R'
         THEN
          FOR rec_challans IN csr_challans(rec_pf_org.pf_org)
          LOOP
	    pay_in_utils.set_location(g_debug,'Archiving Challan Dtls ',25);
            archive_pf_challan_dtls(l_arc_pay_action_id,rec_pf_org.pf_org,rec_challans.Challan_Ref,rec_pf_org.business_number);
	  END LOOP ;
	 END IF ;
	 l_pf_check := NULL ;


    END LOOP ;
    END IF ;

    pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure,20);

   EXCEPTION
    WHEN OTHERS THEN

      l_message := pay_in_utils.get_pay_message('PER_IN_ORACLE_GENERIC_ERROR',
      'FUNCTION:'||l_procedure, 'SQLERRMC:'||sqlerrm);
       pay_in_utils.set_location(g_debug,'Leaving : '||l_procedure, 280);
       pay_in_utils.trace(l_message,l_procedure);

      RAISE;
  --
  END archive_code;

END ;

/
