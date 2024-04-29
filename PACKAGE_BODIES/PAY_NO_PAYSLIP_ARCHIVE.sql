--------------------------------------------------------
--  DDL for Package Body PAY_NO_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_PAYSLIP_ARCHIVE" AS
/* $Header: pynoparc.pkb 120.7 2007/07/13 11:57:10 nmuthusa noship $ */


----------------- Globals , Record types , Tables -------------------------------------------------

 g_debug   boolean   :=  hr_utility.debug_enabled;

/*
 TYPE element_rec IS RECORD (
      classification_name VARCHAR2(60)
     ,element_name        VARCHAR2(60)
     ,element_type_id     NUMBER
     ,input_value_id      NUMBER
     ,element_type        VARCHAR2(1)
     ,uom                 VARCHAR2(1)
     ,archive_flag        VARCHAR2(1));

 */

-- Bug Fix : 5909609, increasing the size of variable 'uom' from VARCHAR2(1) to VARCHAR2(10)

TYPE element_rec IS RECORD (
      classification_name	VARCHAR2(60)
     ,element_name		VARCHAR2(60)
     ,element_type_id		NUMBER
     ,input_value_id		NUMBER
     ,element_type		VARCHAR2(1)
--   ,uom			VARCHAR2(1)
     ,uom			VARCHAR2(10)
     ,prim_bal_def_bal_id	NUMBER
--     ,basis_for_holiday_pay	VARCHAR2(20)
--     ,basis_for_withholding_tax VARCHAR2(20)
     ,archive_flag		VARCHAR2(1)
     ,lookup_type		VARCHAR2(240)
     ,value_set_id		NUMBER );



 TYPE balance_rec IS RECORD (
      balance_name         VARCHAR2(60),
      defined_balance_id   NUMBER,
      balance_type_id      NUMBER);

 TYPE lock_rec IS RECORD ( archive_assact_id    NUMBER);

 TYPE tax_card_rec IS RECORD (inp_val_name  pay_input_values_f.NAME%type , screen_entry_val  pay_element_entry_values_f.SCREEN_ENTRY_VALUE%type );

 TYPE bal_val_rec IS RECORD ( bal_name	ff_database_items.USER_NAME%type  , bal_val  NUMBER(10,2) );


 TYPE tax_card_table  IS TABLE OF  tax_card_rec  INDEX BY BINARY_INTEGER;
 TYPE bal_val_table   IS TABLE OF  bal_val_rec   INDEX BY BINARY_INTEGER;
 TYPE element_table   IS TABLE OF  element_rec   INDEX BY BINARY_INTEGER;
 TYPE balance_table   IS TABLE OF  balance_rec   INDEX BY BINARY_INTEGER;
 TYPE lock_table      IS TABLE OF  lock_rec      INDEX BY BINARY_INTEGER;

 g_tax_card_tab			tax_card_table;
 g_bal_val			bal_val_table;
 g_element_table		element_table;
 g_user_balance_table           balance_table;
 g_lock_table   		lock_table;
 g_index			NUMBER := -1;
 g_index_assact			NUMBER := -1;
 g_index_bal			NUMBER := -1;
 g_package			VARCHAR2(33) := ' PAY_NO_PAYSLIP_ARCHIVE.';
 g_payroll_action_id		NUMBER;
 g_arc_payroll_action_id	NUMBER;
 g_business_group_id		NUMBER;
 g_format_mask			VARCHAR2(50);
 g_err_num			NUMBER;
 g_errm				VARCHAR2(150);

------------------------------  FUNCTION GET_PARAMETER --------------------------------------------------------------------

 /* GET PARAMETER */
 FUNCTION GET_PARAMETER(
 	 p_parameter_string IN VARCHAR2
 	,p_token            IN VARCHAR2
 	,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
 IS

   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  VARCHAR2(1):=' ';
   l_proc	VARCHAR2(40):= g_package||' get parameter ';

 BEGIN
	 -- fnd_file.put_line(fnd_file.log,'Entering Function GET_PARAMETER');
	 --
	 IF g_debug THEN
	     hr_utility.set_location(' Entering Function GET_PARAMETER',10);
	 END IF;
	 l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	 --

	 IF l_start_pos = 0 THEN
	     l_delimiter := '|';
	     l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	 END IF;

	 IF l_start_pos <> 0 THEN
	     l_start_pos := l_start_pos + length(p_token||'=');
	     l_parameter := substr(p_parameter_string, l_start_pos, instr(p_parameter_string||' ', l_delimiter,l_start_pos) - l_start_pos);

	     IF p_segment_number IS NOT NULL THEN
	       l_parameter := ':'||l_parameter||':';
	       l_parameter := substr(l_parameter,
	      instr(l_parameter,':',1,p_segment_number)+1,
	      instr(l_parameter,':',1,p_segment_number+1) -1
	      - instr(l_parameter,':',1,p_segment_number));
	     END IF;
	 END IF;
	   --
	 RETURN l_parameter;

	 IF g_debug THEN
	      hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
	 END IF;
	-- fnd_file.put_line(fnd_file.log,'Leaving Function GET_PARAMETER');
 END;

--------------------------------- PROCEDURE GET_ALL_PARAMETERS -----------------------------------------------------------------

 /* GET ALL PARAMETERS */
 PROCEDURE GET_ALL_PARAMETERS(
        p_payroll_action_id                    IN   NUMBER
       ,p_business_group_id                    OUT  NOCOPY NUMBER
       ,p_start_date                           OUT  NOCOPY VARCHAR2
       ,p_end_date                             OUT  NOCOPY VARCHAR2
       ,p_effective_date                       OUT  NOCOPY DATE
       ,p_payroll_id                           OUT  NOCOPY VARCHAR2
       ,p_consolidation_set                    OUT  NOCOPY VARCHAR2) IS
 --
 CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
 SELECT PAY_NO_PAYSLIP_ARCHIVE.GET_PARAMETER(legislative_parameters,'PAYROLL_ID')
       ,PAY_NO_PAYSLIP_ARCHIVE.GET_PARAMETER(legislative_parameters,'CONSOLIDATION_SET_ID')
       ,PAY_NO_PAYSLIP_ARCHIVE.GET_PARAMETER(legislative_parameters,'START_DATE')
       ,PAY_NO_PAYSLIP_ARCHIVE.GET_PARAMETER(legislative_parameters,'END_DATE')
       ,effective_date
       ,business_group_id
 FROM  pay_payroll_actions
 WHERE payroll_action_id = p_payroll_action_id;

 l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
 --

 BEGIN
	 -- fnd_file.put_line(fnd_file.log,'Entering Procedure GET_ALL_PARAMETERS');

	 OPEN csr_parameter_info (p_payroll_action_id);
	 FETCH csr_parameter_info INTO p_payroll_id
		     ,p_consolidation_set
		     ,p_start_date
		     ,p_end_date
		     ,p_effective_date
		     ,p_business_group_id;
	 CLOSE csr_parameter_info;
	 --
	 IF g_debug THEN
	      hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
	 END IF;

	-- fnd_file.put_line(fnd_file.log,'GET_ALL_PARAMETERS : p_payroll_action_id = ' || p_payroll_action_id );
	-- fnd_file.put_line(fnd_file.log,'GET_ALL_PARAMETERS : p_payroll_id = ' || p_payroll_id );
	-- fnd_file.put_line(fnd_file.log,'GET_ALL_PARAMETERS : p_consolidation_set = ' || p_consolidation_set);
	-- fnd_file.put_line(fnd_file.log,'GET_ALL_PARAMETERS : p_start_date = ' || p_start_date );
	-- fnd_file.put_line(fnd_file.log,'GET_ALL_PARAMETERS : p_end_date = ' || p_end_date );
	-- fnd_file.put_line(fnd_file.log,'GET_ALL_PARAMETERS : p_effective_date = ' || p_effective_date );
	-- fnd_file.put_line(fnd_file.log,'GET_ALL_PARAMETERS : p_business_group_id = ' || p_business_group_id );

	-- fnd_file.put_line(fnd_file.log,'Leaving Procedure GET_ALL_PARAMETERS');

 END GET_ALL_PARAMETERS;

----------------------------------- PROCEDURE RANGE_CODE ---------------------------------------------------------------

 /* RANGE CODE */
 PROCEDURE RANGE_CODE (p_payroll_action_id	IN    NUMBER
		      ,p_sql			OUT   NOCOPY VARCHAR2)
 IS

 -----------------------------------------------------
 -- MESSAGES
 ----------------------------------------------------
 -- Cursor to get the messages from Busineess Group:Payslip Info
 CURSOR csr_get_message(p_bus_grp_id NUMBER) IS
 SELECT org_information6 message
 FROM   hr_organization_information
 WHERE  organization_id = p_bus_grp_id
 AND    org_information_context = 'Business Group:Payslip Info'
 AND    org_information1 = 'MESG';

 -----------------------------------------------------------------
 -- BALANCES
 -----------------------------------------------------------------

 /* Cursor to retrieve Other Balances Information */
 CURSOR csr_get_balance(p_bus_grp_id NUMBER) IS
 SELECT org_information4 balance_type_id
       ,org_information5 balance_dim_id
       ,org_information7 narrative
 FROM   hr_organization_information
 WHERE  organization_id = p_bus_grp_id
 AND    org_information_context = 'Business Group:Payslip Info'
 AND    org_information1 = 'BALANCE';

 /* Cursor to fetch defined balance id */
 CURSOR csr_def_balance(bal_type_id NUMBER, bal_dim_id NUMBER) IS
 SELECT defined_balance_id
 FROM   pay_defined_balances
 WHERE  balance_type_id = bal_type_id
 AND    balance_dimension_id = bal_dim_id;

 -----------------------------------------------------
 --ELEMENTS
 ----------------------------------------------------

 /* Cursor to retrieve Time Period Information */
 CURSOR csr_time_periods(p_run_payact_id NUMBER ,p_payroll_id NUMBER) IS
 SELECT ptp.end_date              end_date,
        ptp.start_date            start_date,
        ptp.period_name           period_name,
        ppf.payroll_name          payroll_name
 FROM   per_time_periods	ptp
       ,pay_payroll_actions	ppa
       ,pay_payrolls_f		ppf
 WHERE  ptp.payroll_id           = ppa.payroll_id
 AND    ppa.payroll_action_id    = p_run_payact_id
 AND    ppa.payroll_id           = ppf.payroll_id
 AND    ppf.payroll_id           = NVL(p_payroll_id , ppf.payroll_id)
 AND    ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date
 AND    ppa.date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

 --------------------------------------------------------------
 -- Additional Element
 --------------------------------------------------------------

 /* Cursor to retrieve Additional Element Information */

 /*
 CURSOR csr_get_element(p_bus_grp_id NUMBER, p_date_earned DATE) IS
 SELECT hoi.org_information2 element_type_id
       ,hoi.org_information3 input_value_id
       ,hoi.org_information7 element_narrative
       ,pec.classification_name ele_class
       ,piv.uom  uom
 FROM   hr_organization_information hoi
       ,pay_element_classifications pec
       ,pay_element_types_f  pet
       ,pay_input_values_f piv
 WHERE  hoi.organization_id = p_bus_grp_id
 AND    hoi.org_information_context = 'Business Group:Payslip Info'
 AND    hoi.org_information1 = 'ELEMENT'
 AND    hoi.org_information2 = pet.element_type_id
 AND    pec.classification_id = pet.classification_id
 AND    piv.input_value_id = hoi.org_information3
 AND    p_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date;
 */

 CURSOR csr_get_element(p_bus_grp_id NUMBER, p_date_earned DATE) IS
 SELECT hoi.org_information2 element_type_id
       ,hoi.org_information3 input_value_id
       ,hoi.org_information7 element_narrative
       ,pec.classification_name ele_class
       ,piv.uom  uom
       ,piv.lookup_type	  lookup_type
       ,piv.value_set_id  value_set_id
 FROM   hr_organization_information hoi
       ,pay_element_classifications pec
       ,pay_element_types_f  pet
       ,pay_input_values_f piv
 WHERE  hoi.organization_id = p_bus_grp_id
 AND    hoi.org_information_context = 'Business Group:Payslip Info'
 AND    hoi.org_information1 = 'ELEMENT'
 AND    hoi.org_information2 = pet.element_type_id
 AND    pec.classification_id = pet.classification_id
 AND    piv.input_value_id = hoi.org_information3
 AND    p_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date;

----------------------------------------------------------------

/* Cursor to get the first primary balance type id for an input value id */

 CURSOR csr_prim_bal_type (p_iv_id  NUMBER)IS
 SELECT balance_type_id
 FROM   pay_balance_types
 WHERE  input_value_id = p_iv_id
 AND ((business_group_id IS NULL AND legislation_code = 'NO')
       OR (business_group_id = g_business_group_id AND legislation_code IS NULL))
 AND rownum = 1 ;

----------------------------------------------------------------

/* Cursor to get the defined balance id */

 CURSOR csr_def_bal_id (p_prim_bal_type_id  NUMBER)IS
 SELECT defined_balance_id
 FROM   pay_defined_balances
 WHERE  balance_type_id = p_prim_bal_type_id
 AND ((business_group_id IS NULL AND legislation_code = 'NO')
       OR (business_group_id = g_business_group_id AND legislation_code IS NULL))
 AND    balance_dimension_id = ( select balance_dimension_id
                                 from pay_balance_dimensions where legislation_code = 'NO'
				 and dimension_name = 'Assignment Calendar Year To Date' ) ;

---------------------------------------------------------------

/* cursor to get the sub classifications for an element type */

/*
CURSOR csr_sub_class (p_ele_type_id  NUMBER , p_date_earned  DATE) IS
SELECT eleclass.classification_name
      ,decode (eleclass.classification_name,'Taxable Pay _ Absence',1,'Taxable Pay _ Earnings',1
		,'Taxable Pay _ Supplemental Earnings',1,'Taxable Pay _ Taxable Benefits',1,0) table_base
      ,decode (eleclass.classification_name,'Additional Taxable Pay _ Absence',2,'Additional Taxable Pay _ Earnings',2
		,'Additional Taxable Pay _ Supplemental Earnings',2,'Additional Taxable Pay _ Taxable Benefits',2,0) percent_base
      ,decode (eleclass.classification_name,'Holiday Pay',3,0) holiday_pay
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass

WHERE subclass.element_type_id = p_ele_type_id
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL))
AND eleclass.classification_id = subclass.classification_id ;

*/


CURSOR csr_sub_class (p_date_earned  date , p_ele_type_id  NUMBER , p_ele_sub_class_name  pay_element_classifications.classification_name%type ) IS
SELECT 1
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND   eleclass.classification_name = p_ele_sub_class_name
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL))
AND eleclass.classification_id = subclass.classification_id ;


-- cursor to check if an element has a holiday pay secondary classification

/*
CURSOR csr_hol_sub_class (p_date_earned  date , p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Holiday Pay Earnings Adjustment',
					'Holiday Pay Base _ Supplementary Earnings')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;

*/

/* Change for element classification name from 'Holiday Pay Earnings Adjustment' to 'Holiday Pay Earnings Adjust' */

/*
CURSOR csr_hol_sub_class (p_date_earned  date , p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Holiday Pay Earnings Adjust',
					'Holiday Pay Base _ Supplementary Earnings')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;

*/

/* Sub classification added for Impact of Absence on Holiday Pay */
/*
CURSOR csr_hol_sub_class (p_date_earned  date , p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Holiday Pay Earnings Adjust',
					'Holiday Pay Base _ Supplementary Earnings',
					'Holiday Pay Base During Absence _ Information')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;

*/

-- The following classifications have been obsoleted and will no longer be used.
-- Holiday Pay Base _ Holiday Pay Earnings Adjust => Holiday Pay Base _ Holiday Pay Earnings Adjust Obsolete

CURSOR csr_hol_sub_class (p_date_earned  date , p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Supplementary Earnings',
					'Holiday Pay Base During Absence _ Information')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;

--------------------------------------------------------------


  --------------

 rec_time_periods	csr_time_periods%ROWTYPE;
 rec_get_balance	csr_get_balance%ROWTYPE;
 rec_get_message	csr_get_message%ROWTYPE;
 rec_get_element	csr_get_element%ROWTYPE;
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
 l_business_group_id	NUMBER;
 l_start_date		VARCHAR2(30);
 l_end_date		VARCHAR2(30);
 l_effective_date	DATE;
 l_consolidation_set	NUMBER;
 l_defined_balance_id	NUMBER := 0;
 l_count		NUMBER := 0;
 l_prev_prepay		NUMBER := 0;
 l_canonical_start_date	DATE;
 l_canonical_end_date   DATE;
 l_payroll_id		NUMBER;
 l_prepay_action_id	NUMBER;
 l_actid		NUMBER;
 l_assignment_id	NUMBER;
 l_action_sequence	NUMBER;
 l_assact_id		NUMBER;
 l_pact_id		NUMBER;
 l_flag			NUMBER := 0;
 l_element_context	VARCHAR2(5);
 l_prim_bal_type_id	NUMBER;
 l_prim_def_bal_id	NUMBER ;
 l_table_basis		NUMBER;
 l_percent_basis	NUMBER;
 l_holiday_basis	NUMBER;
 l_ele_class		VARCHAR2(240);
 l_basis_text		VARCHAR2(240);
 l_holiday_text		VARCHAR2(240);

 ----------------

 BEGIN
	 -- fnd_file.put_line(fnd_file.log,'Entering Procedure RANGE_CODE');
	 IF g_debug THEN
	      hr_utility.set_location(' Entering Procedure RANGE_CODE',40);
	 END IF;

	 PAY_NO_PAYSLIP_ARCHIVE.GET_ALL_PARAMETERS(p_payroll_action_id
			,l_business_group_id
			,l_start_date
			,l_end_date
			,l_effective_date
			,l_payroll_id
			,l_consolidation_set);

	 l_canonical_start_date := TO_DATE(l_start_date,'YYYY/MM/DD');
	 l_canonical_end_date   := TO_DATE(l_end_date,'YYYY/MM/DD');

	     -- get the messages from Busineess Group:Payslip Info
	     OPEN csr_get_message(l_business_group_id);
		LOOP
		FETCH csr_get_message INTO rec_get_message;
		EXIT WHEN csr_get_message%NOTFOUND;

		-- archive the messages
		pay_action_information_api.create_action_information (
		    p_action_information_id        => l_action_info_id
		   ,p_action_context_id            => p_payroll_action_id
		   ,p_action_context_type          => 'PA'
		   ,p_object_version_number        => l_ovn
		   ,p_effective_date               => l_effective_date
		   ,p_source_id                    => NULL
		   ,p_source_text                  => NULL
		   ,p_action_information_category  => 'EMPLOYEE OTHER INFORMATION'
		   ,p_action_information1          => l_business_group_id
		   ,p_action_information2          => 'MESG' -- Message Context
		   ,p_action_information3          => NULL
		   ,p_action_information4          => NULL
		   ,p_action_information5          => NULL
		   ,p_action_information6          => rec_get_message.message);

		END LOOP;
	      CLOSE csr_get_message;

	 -------------------------------------------------------------------------------------
	 -- Initialize Balance Definitions
	 -------------------------------------------------------------------------------------

	 -- get the balances from Busineess Group:Payslip Info
	 OPEN csr_get_balance(l_business_group_id);
	 LOOP
	 FETCH csr_get_balance INTO rec_get_balance;
	 EXIT WHEN csr_get_balance%NOTFOUND;

		 -- get the defined balance id for the balances got above
		 OPEN csr_def_balance(rec_get_balance.balance_type_id,rec_get_balance.balance_dim_id);
		 FETCH csr_def_balance INTO l_defined_balance_id;
		 CLOSE csr_def_balance;

		 BEGIN
			 -- check if the balance has already been archived
			 SELECT 1 INTO l_flag
			 FROM   pay_action_information
			 WHERE  action_information_category = 'EMEA BALANCE DEFINITION'
			 AND    action_context_id           = p_payroll_action_id
			 AND    action_information2         = l_defined_balance_id
			 AND    action_information6         = 'OBAL'
			 AND    action_information4         = rec_get_balance.narrative;

			 EXCEPTION WHEN NO_DATA_FOUND THEN

			 -- archive the balance definition as it has not been archived before
			 pay_action_information_api.create_action_information (
			  p_action_information_id        => l_action_info_id
			  ,p_action_context_id            => p_payroll_action_id
			  ,p_action_context_type          => 'PA'
			  ,p_object_version_number        => l_ovn
			  ,p_effective_date               => l_effective_date
			  ,p_source_id                    => NULL
			  ,p_source_text                  => NULL
			  ,p_action_information_category  => 'EMEA BALANCE DEFINITION'
			  ,p_action_information1          => NULL
			  ,p_action_information2          => l_defined_balance_id
			  ,p_action_information4          => rec_get_balance.narrative
			  ,p_action_information6          => 'OBAL');

			 WHEN OTHERS THEN
			 NULL;
		 END;

	 END LOOP;
	 CLOSE csr_get_balance;

	 -----------------------------------------------------------------------------
	 --Initialize Element Definitions
	 -----------------------------------------------------------------------------

	 g_business_group_id := l_business_group_id;

	 ARCHIVE_ELEMENT_INFO(p_payroll_action_id  => p_payroll_action_id
			      ,p_effective_date    => l_effective_date
			      ,p_date_earned       => l_canonical_end_date
			      ,p_pre_payact_id     => NULL);

	 -----------------------------------------------------------------------------
	 --Archive Additional Element Definitions
	 -----------------------------------------------------------------------------

	 l_element_context := 'F';

	 OPEN csr_get_element(l_business_group_id,l_canonical_end_date);
	 LOOP
	 FETCH csr_get_element INTO rec_get_element;
	 EXIT WHEN csr_get_element%NOTFOUND;
		BEGIN

			  l_prim_bal_type_id := NULL ;
			  l_prim_def_bal_id := NULL ;
			  l_ele_class := NULL ;
			  l_table_basis := NULL ;
			  l_percent_basis := NULL ;
			  l_holiday_basis := NULL ;
			  l_basis_text := NULL ;
			  l_holiday_text := NULL ;


			  /* get the primary balance type id from the input value id */
			  OPEN csr_prim_bal_type (rec_get_element.input_value_id);
			  FETCH csr_prim_bal_type INTO l_prim_bal_type_id ;
			  CLOSE csr_prim_bal_type ;

			  /* get the defined balance id from the balance type id */
			  OPEN csr_def_bal_id (l_prim_bal_type_id ) ;
			  FETCH csr_def_bal_id INTO l_prim_def_bal_id ;
			  CLOSE csr_def_bal_id ;

			  /* get the table/percetage basis info */

			  l_basis_text := NULL ;

			  IF ( rec_get_element.ele_class = 'Pre-tax Deductions' )

				THEN  l_basis_text := 'TABLE';

			  ELSIF ( rec_get_element.ele_class = 'Taxable Expenses' )

				THEN l_basis_text := 'PERCENTAGE';

			  ELSIF ( rec_get_element.ele_class = 'Absence' )

				THEN
					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Taxable Pay _ Absence') ;
					FETCH csr_sub_class INTO l_table_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'TABLE';
					END IF;
					CLOSE csr_sub_class ;


					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Additional Taxable Pay _ Absence') ;
					FETCH csr_sub_class INTO l_percent_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'PERCENTAGE';
					END IF;
					CLOSE csr_sub_class ;


			  ELSIF ( rec_get_element.ele_class = 'Earnings' )

				THEN
					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Taxable Pay _ Earnings') ;
					FETCH csr_sub_class INTO l_table_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'TABLE';
					END IF;
					CLOSE csr_sub_class ;


					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Additional Taxable Pay _ Earnings') ;
					FETCH csr_sub_class INTO l_percent_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'PERCENTAGE';
					END IF;
					CLOSE csr_sub_class ;

			  ELSIF ( rec_get_element.ele_class = 'Supplementary Earnings' )

				THEN
					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Taxable Pay _ Supplemental Earnings') ;
					FETCH csr_sub_class INTO l_table_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'TABLE';
					END IF;
					CLOSE csr_sub_class ;


					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Additional Taxable Pay _ Supplemental Earnings') ;
					FETCH csr_sub_class INTO l_percent_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'PERCENTAGE';
					END IF;
					CLOSE csr_sub_class ;

			  ELSIF ( rec_get_element.ele_class = 'Taxable Benefits' )

				THEN
					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Taxable Pay _ Taxable Benefits') ;
					FETCH csr_sub_class INTO l_table_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'TABLE';
					END IF;
					CLOSE csr_sub_class ;


					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Additional Taxable Pay _ Taxable Benefits') ;
					FETCH csr_sub_class INTO l_percent_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'PERCENTAGE';
					END IF;
					CLOSE csr_sub_class ;

			  ELSIF ( rec_get_element.ele_class = 'Earnings Adjustment' )

				THEN
					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Taxable Pay _ Earnings Adjustment') ;
					FETCH csr_sub_class INTO l_table_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'TABLE';
					END IF;
					CLOSE csr_sub_class ;


					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Additional Taxable Pay _ Earnings Adjustment') ;
					FETCH csr_sub_class INTO l_percent_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'PERCENTAGE';
					END IF;
					CLOSE csr_sub_class ;

			  /* Change for element classification name from 'Holiday Pay Earnings Adjustment' to 'Holiday Pay Earnings Adjust' */

			  -- The following classifications have been obsoleted and will no longer be used.
			  -- Holiday Pay Earnings Adjust => Holiday Pay Earnings Adjust Obsolete
			  -- Taxable Pay _ Holiday Pay Earnings Adjust => Taxable Pay _ Holiday Pay Earnings Adjust Obsolete
			  -- Additional Taxable Pay _ Holiday Pay Earnings Adjust => Additional Taxable Pay _ Holiday Pay Earnings Adjust Obsolete
			  -- Commenting the code below.

			  /*

			  -- ELSIF ( rec_get_element.ele_class = 'Holiday Pay Earnings Adjustment' )
			  ELSIF ( rec_get_element.ele_class = 'Holiday Pay Earnings Adjust' )

				THEN
					-- OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Taxable Pay _ Holiday Pay Earnings Adjustment') ;
					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Taxable Pay _ Holiday Pay Earnings Adjust') ;
					FETCH csr_sub_class INTO l_table_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'TABLE';
					END IF;
					CLOSE csr_sub_class ;


					-- OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Additional Taxable Pay _ Holiday Pay Earnings Adjustment') ;
					OPEN  csr_sub_class ( l_canonical_end_date , rec_get_element.element_type_id , 'Additional Taxable Pay _ Holiday Pay Earnings Adjust') ;
					FETCH csr_sub_class INTO l_percent_basis ;
					IF (csr_sub_class%FOUND)
					   THEN  l_basis_text := 'PERCENTAGE';
					END IF;
					CLOSE csr_sub_class ;
			  */

			  END IF;


			  /*
			  OPEN csr_sub_class (rec_get_element.element_type_id , l_canonical_end_date) ;
			  FETCH csr_sub_class INTO l_ele_class ,l_table_basis ,l_percent_basis ,l_holiday_basis ;
			  CLOSE csr_sub_class ;


			  l_basis_text := NULL ;

			  IF (l_table_basis = 1) THEN l_basis_text := 'TABLE';
			  ELSIF (l_percent_basis = 2) THEN l_basis_text := 'PERCENTAGE';
			  END IF;

			  */

			  -- l_holiday_text := NULL ;

			  -- check if the element is basis for holiday pay

			  OPEN csr_hol_sub_class (l_canonical_end_date , rec_get_element.element_type_id) ;
			  FETCH csr_hol_sub_class INTO l_holiday_text ;
			  CLOSE csr_hol_sub_class ;

			  /* (IF (l_holiday_basis = 3) THEN l_holiday_text := 'Y';
			  END IF ; */

			  IF (l_basis_text IS NOT NULL) THEN
				l_basis_text := hr_general.decode_lookup('NO_REPORT_LABELS',l_basis_text);
			  END IF;

			  IF (l_holiday_text IS NOT NULL) THEN
				l_holiday_text := hr_general.decode_lookup('NO_REPORT_LABELS',l_holiday_text);
			  END IF;


			-- check if the element definition has already been archived
			SELECT 1 INTO l_flag
			FROM   pay_action_information
			WHERE  action_context_id = p_payroll_action_id
			AND    action_information_category = 'NO ELEMENT DEFINITION'
			AND    action_information2 = rec_get_element.element_type_id
			AND    action_information3 = rec_get_element.input_value_id
			AND    action_information5 = l_element_context;

			EXCEPTION WHEN NO_DATA_FOUND THEN
			-- archive the element definition since it has not been archived
			pay_action_information_api.create_action_information (
				p_action_information_id        => l_action_info_id
				,p_action_context_id            => p_payroll_action_id
				,p_action_context_type          => 'PA'
				,p_object_version_number        => l_ovn
				,p_effective_date               => l_effective_date
				,p_source_id                    => NULL
				,p_source_text                  => NULL
				,p_action_information_category  => 'NO ELEMENT DEFINITION'
				,p_action_information1          => NULL
				,p_action_information2          => rec_get_element.element_type_id
				,p_action_information3          => rec_get_element.input_value_id
				,p_action_information4          => rec_get_element.element_narrative
				,p_action_information5          => l_element_context
				,p_action_information6          => rec_get_element.uom
				,p_action_information7          => l_element_context
				,p_action_information8          => l_prim_def_bal_id
				,p_action_information9          => 'PBAL'
				,p_action_information10         => l_holiday_text
				,p_action_information11         => l_basis_text
				,p_action_information12         => rec_get_element.ele_class
				,p_action_information13         => rec_get_element.lookup_type
				,p_action_information14         => rec_get_element.value_set_id );

			WHEN OTHERS THEN
				NULL;
		END;

	     END LOOP;
	     CLOSE csr_get_element;

	 p_sql := 'SELECT DISTINCT person_id
		FROM  per_people_f ppf
		     ,pay_payroll_actions ppa
		WHERE ppa.payroll_action_id = :payroll_action_id
		AND   ppa.business_group_id = ppf.business_group_id
		ORDER BY ppf.person_id';

	 IF g_debug THEN
	      hr_utility.set_location(' Leaving Procedure RANGE_CODE',50);
	 END IF;

	 -- fnd_file.put_line(fnd_file.log,'Leaving Procedure RANGE_CODE');

	 EXCEPTION
	 WHEN OTHERS THEN
	 -- Return cursor that selects no rows
	 p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';

 END RANGE_CODE;

---------------------------------- PROCEDURE ASSIGNMENT_ACTION_CODE ----------------------------------------------------------------

 /* ASSIGNMENT ACTION CODE */
 PROCEDURE ASSIGNMENT_ACTION_CODE
 (p_payroll_action_id     IN NUMBER
 ,p_start_person          IN NUMBER
 ,p_end_person            IN NUMBER
 ,p_chunk                 IN NUMBER)
 IS

-----------

 CURSOR csr_prepaid_assignments(p_payroll_action_id          	NUMBER,
         p_start_person      	NUMBER,
         p_end_person         NUMBER,
         p_payroll_id       	NUMBER,
         p_consolidation_id 	NUMBER,
         l_canonical_start_date	DATE,
         l_canonical_end_date	DATE)
 IS
 SELECT act.assignment_id            assignment_id,
        act.assignment_action_id     run_action_id,
        act1.assignment_action_id    prepaid_action_id
 FROM   pay_payroll_actions          ppa,
        pay_payroll_actions          appa,
        pay_payroll_actions          appa2,
        pay_assignment_actions       act,
        pay_assignment_actions       act1,
        pay_action_interlocks        pai,
        per_all_assignments_f        as1
 WHERE  ppa.payroll_action_id        = p_payroll_action_id
 AND    appa.consolidation_set_id    = p_consolidation_id
 AND    appa.effective_date          BETWEEN l_canonical_start_date  AND     l_canonical_end_date
 AND    as1.person_id                BETWEEN p_start_person  AND     p_end_person
 AND    appa.action_type             IN ('R','Q')  -- Payroll Run or Quickpay Run
 AND    act.payroll_action_id        = appa.payroll_action_id
 AND    act.source_action_id         IS NULL -- Master Action
 AND    as1.assignment_id            = act.assignment_id
 AND    ppa.effective_date           BETWEEN as1.effective_start_date   AND     as1.effective_end_date
 AND    act.action_status            = 'C'  -- Completed
 AND    act.assignment_action_id     = pai.locked_action_id
 AND    act1.assignment_action_id    = pai.locking_action_id
 AND    act1.action_status           = 'C' -- Completed
 AND    act1.payroll_action_id       = appa2.payroll_action_id
 AND    appa2.action_type            IN ('P','U') -- Prepayments or Quickpay Prepayments
 AND    appa2.effective_date          BETWEEN l_canonical_start_date   AND l_canonical_end_date
 AND    (as1.payroll_id = p_payroll_id OR p_payroll_id IS NULL)

 AND    NOT EXISTS (SELECT /* + ORDERED */ NULL
 		   FROM   pay_action_interlocks      pai1,
			  pay_assignment_actions     act2,
			  pay_payroll_actions        appa3
 		   WHERE  pai1.locked_action_id    = act.assignment_action_id
 		   AND    act2.assignment_action_id= pai1.locking_action_id
 		   AND    act2.payroll_action_id   = appa3.payroll_action_id
 		   AND    appa3.action_type        = 'X'
 		   AND    appa3.action_status      = 'C'
 		   AND    appa3.report_type        = 'PYNOARCHIVE')

 AND  NOT EXISTS (  SELECT /* + ORDERED */ NULL
 		   FROM   pay_action_interlocks      pai1,
			  pay_assignment_actions     act2,
			  pay_payroll_actions        appa3
 		      WHERE  pai1.locked_action_id    = act.assignment_action_id
 		      AND    act2.assignment_action_id= pai1.locking_action_id
 		      AND    act2.payroll_action_id   = appa3.payroll_action_id
 		      AND    appa3.action_type        = 'V'
 		      AND    appa3.action_status      = 'C')

 ORDER BY act.assignment_id;

 -----------

 l_count		NUMBER := 0;
 l_prev_prepay		NUMBER := 0;
 l_business_group_id	NUMBER;
 l_start_date           VARCHAR2(20);
 l_end_date             VARCHAR2(20);
 l_canonical_start_date	DATE;
 l_canonical_end_date   DATE;
 l_effective_date	DATE;
 l_payroll_id		NUMBER;
 l_consolidation_set	NUMBER;
 l_prepay_action_id	NUMBER;
 l_actid		NUMBER;
 l_assignment_id	NUMBER;
 l_action_sequence	NUMBER;
 l_assact_id		NUMBER;
 l_pact_id		NUMBER;
 l_flag			NUMBER := 0;
 l_defined_balance_id	NUMBER := 0;
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
----------------

BEGIN

 -- fnd_file.put_line(fnd_file.log,'Entering Procedure ASSIGNMENT_ACTION_CODE');
 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',60);
 END IF;

      PAY_NO_PAYSLIP_ARCHIVE.GET_ALL_PARAMETERS(p_payroll_action_id
 		,l_business_group_id
 		,l_start_date
 		,l_end_date
 		,l_effective_date
 		,l_payroll_id
 		,l_consolidation_set);

   l_canonical_start_date := TO_DATE(l_start_date,'YYYY/MM/DD');
   l_canonical_end_date   := TO_DATE(l_end_date,'YYYY/MM/DD');
   l_prepay_action_id := 0;

   FOR rec_prepaid_assignments IN csr_prepaid_assignments(p_payroll_action_id
  		,p_start_person
  		,p_end_person
  		,l_payroll_id
  		,l_consolidation_set
  		,l_canonical_start_date
  		,l_canonical_end_date) LOOP

     IF l_prepay_action_id <> rec_prepaid_assignments.prepaid_action_id THEN

	SELECT pay_assignment_actions_s.NEXTVAL
 	INTO   l_actid
 	FROM   dual;
 	  --
 	g_index_assact := g_index_assact + 1;
 	g_lock_table(g_index_assact).archive_assact_id := l_actid; /* For Element archival */

       -- Create the archive assignment action
 	    hr_nonrun_asact.insact(l_actid
  	  ,rec_prepaid_assignments.assignment_id
  	  ,p_payroll_action_id
  	  ,p_chunk
  	  ,NULL);
 	-- Create archive to prepayment assignment action interlock
 	--
 	hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.prepaid_action_id);
     END IF;

     -- create archive to master assignment action interlock
      hr_nonrun_asact.insint(l_actid,rec_prepaid_assignments.run_action_id);
      l_prepay_action_id := rec_prepaid_assignments.prepaid_action_id;

 END LOOP;

 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',70);
 END IF;
 -- fnd_file.put_line(fnd_file.log,'Leaving Procedure ASSIGNMENT_ACTION_CODE');

 END ASSIGNMENT_ACTION_CODE;

------------------------------------- PROCEDURE INITIALIZATION_CODE -------------------------------------------------------------

 /* INITIALIZATION CODE */

 PROCEDURE INITIALIZATION_CODE(p_payroll_action_id IN NUMBER)
 IS

-------------

 CURSOR csr_prepay_id IS
 SELECT distinct prepay_payact.payroll_action_id    prepay_payact_id
       ,run_payact.date_earned date_earned
 FROM   pay_action_interlocks  archive_intlck
       ,pay_assignment_actions prepay_assact
       ,pay_payroll_actions    prepay_payact
       ,pay_action_interlocks  prepay_intlck
       ,pay_assignment_actions run_assact
       ,pay_payroll_actions    run_payact
       ,pay_assignment_actions archive_assact
 WHERE  archive_intlck.locking_action_id = archive_assact.assignment_action_id
 and    archive_assact.payroll_action_id = p_payroll_action_id
 AND    prepay_assact.assignment_action_id = archive_intlck.locked_action_id
 AND    prepay_payact.payroll_action_id = prepay_assact.payroll_action_id
 AND    prepay_payact.action_type IN ('U','P')
 AND    prepay_intlck.locking_action_id = prepay_assact.assignment_action_id
 AND    run_assact.assignment_action_id = prepay_intlck.locked_action_id
 AND    run_payact.payroll_action_id = run_assact.payroll_action_id
 AND    run_payact.action_type IN ('Q', 'R')
 ORDER BY prepay_payact.payroll_action_id;

--------------

 /* Cursor to retrieve Run Assignment Action Ids */
 CURSOR csr_runact_id IS
 SELECT distinct prepay_payact.payroll_action_id    prepay_payact_id
       ,run_payact.date_earned date_earned
       ,run_payact.payroll_action_id run_payact_id
 FROM   pay_action_interlocks  archive_intlck
       ,pay_assignment_actions prepay_assact
       ,pay_payroll_actions    prepay_payact
       ,pay_action_interlocks  prepay_intlck
       ,pay_assignment_actions run_assact
       ,pay_payroll_actions    run_payact
       ,pay_assignment_actions archive_assact
 WHERE  archive_intlck.locking_action_id = archive_assact.assignment_action_id
 and    archive_assact.payroll_action_id = p_payroll_action_id
 AND    prepay_assact.assignment_action_id = archive_intlck.locked_action_id
 AND    prepay_payact.payroll_action_id = prepay_assact.payroll_action_id
 AND    prepay_payact.action_type IN ('U','P')
 AND    prepay_intlck.locking_action_id = prepay_assact.assignment_action_id
 AND    run_assact.assignment_action_id = prepay_intlck.locked_action_id
 AND    run_payact.payroll_action_id = run_assact.payroll_action_id
 AND    run_payact.action_type IN ('Q', 'R')
 ORDER BY prepay_payact.payroll_action_id;

-------------

 rec_prepay_id		csr_prepay_id%ROWTYPE;
 rec_runact_id		csr_runact_id%ROWTYPE;
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
 l_count		NUMBER := 0;
 l_business_group_id	NUMBER;
 l_start_date		VARCHAR2(20);
 l_end_date		VARCHAR2(20);
 l_effective_date	DATE;
 l_payroll_id		NUMBER;
 l_consolidation_set	NUMBER;
 l_prev_prepay		NUMBER := 0;

---------------

 BEGIN

 -- fnd_file.put_line(fnd_file.log,'Entering Procedure INITIALIZATION_CODE');

 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',80);
 END IF;

 /*fnd_file.put_line(fnd_file.log,'In INIT_CODE 0');*/

 GET_ALL_PARAMETERS(p_payroll_action_id
  	 ,l_business_group_id
  	 ,l_start_date
  	 ,l_end_date
  	 ,l_effective_date
  	 ,l_payroll_id
  	 ,l_consolidation_set);

 g_arc_payroll_action_id := p_payroll_action_id;
 g_business_group_id := l_business_group_id;

 /* Archive Element Details */
 OPEN csr_prepay_id;
 LOOP
 	FETCH csr_prepay_id INTO rec_prepay_id;
 	EXIT WHEN csr_prepay_id%NOTFOUND;
 ---------------------------------------------------------
 --Initialize Global tables once every prepayment payroll
 --action id and once every thread
 ---------------------------------------------------------
 IF (rec_prepay_id.prepay_payact_id <> l_prev_prepay) THEN
 	ARCHIVE_ADD_ELEMENT(p_archive_assact_id     => NULL,
			      p_assignment_action_id  => NULL,
			      p_assignment_id         => NULL,
			      p_payroll_action_id     => p_payroll_action_id,
			      p_date_earned           => rec_prepay_id.date_earned,
			      p_effective_date        => l_effective_date,
			      p_pre_payact_id         => rec_prepay_id.prepay_payact_id,
			      p_archive_flag          => 'N');

 END IF;

 l_prev_prepay := rec_prepay_id.prepay_payact_id;
 END LOOP;

 CLOSE csr_prepay_id;

 /* Initialize Global tables for Balances */
 ARCHIVE_OTH_BALANCE(p_archive_assact_id     => NULL,
 		    p_assignment_action_id  => NULL,
 		    p_assignment_id         => NULL,
 		    p_payroll_action_id     => p_payroll_action_id,
 		    p_record_count          => NULL,
 		    p_pre_payact_id         => NULL, --rec_prepay_id.prepay_payact_id,
 		    p_effective_date        => l_effective_date,
 		    p_date_earned           => NULL,
 		    p_archive_flag          => 'N');

 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',90);
 END IF;

 -- fnd_file.put_line(fnd_file.log,'Leaving Procedure INITIALIZATION_CODE');


 EXCEPTION WHEN OTHERS THEN
 g_err_num := SQLCODE;
   -- fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE');

 IF g_debug THEN
      hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',180);
 END IF;

--  fnd_file.put_line(fnd_file.log,'Leaving Procedure INITIALIZATION_CODE');

 END INITIALIZATION_CODE;

------------------------------------- PROCEDURE SETUP_ELEMENT_DEFINITIONS -------------------------------------------------------------

 PROCEDURE SETUP_ELEMENT_DEFINITIONS( p_classification_name IN VARCHAR2
				    ,p_element_name        IN VARCHAR2
				    ,p_element_type_id     IN NUMBER
				    ,p_input_value_id      IN NUMBER
				    ,p_element_type        IN VARCHAR2
				    ,p_uom                 IN VARCHAR2
				    ,p_archive_flag        IN VARCHAR2
				    ,p_prim_bal_def_bal_id IN NUMBER
				    ,p_lookup_type	   IN VARCHAR2
				    ,p_value_set_id	   IN NUMBER )
 IS

 BEGIN

 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure SETUP_ELEMENT_DEFINITIONS',100);
 END IF;

     g_index := g_index + 1;
     /* Initialize global tables that hold Additional Element details */
     g_element_table(g_index).classification_name := p_classification_name;
     g_element_table(g_index).element_name        := p_element_name;
     g_element_table(g_index).element_type        := p_element_type;
     g_element_table(g_index).element_type_id     := p_element_type_id;
     g_element_table(g_index).input_value_id      := p_input_value_id;
     g_element_table(g_index).uom                 := p_uom;
     g_element_table(g_index).archive_flag        := p_archive_flag;
     g_element_table(g_index).prim_bal_def_bal_id := p_prim_bal_def_bal_id ;
     -- new added
     g_element_table(g_index).lookup_type	  := p_lookup_type ;
     g_element_table(g_index).value_set_id        := p_value_set_id ;


 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure SETUP_ELEMENT_DEFINITIONS',110);
 END IF;

 END SETUP_ELEMENT_DEFINITIONS;

------------------------------------ PROCEDURE SETUP_BALANCE_DEFINITIONS --------------------------------------------------------------

 PROCEDURE SETUP_BALANCE_DEFINITIONS(p_balance_name         IN VARCHAR2
				    ,p_defined_balance_id   IN NUMBER
			  	    ,p_balance_type_id      IN NUMBER)
 IS
 BEGIN

 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure SETUP_BALANCE_DEFINITIONS',120);
 END IF;

     g_index_bal := g_index_bal + 1;
     /* Initialize global tables that hold Other Balances details */
     g_user_balance_table(g_index_bal).balance_name         := p_balance_name;
     g_user_balance_table(g_index_bal).defined_balance_id   := p_defined_balance_id;
     g_user_balance_table(g_index_bal).balance_type_id      := p_balance_type_id;

   --fnd_file.put_line(fnd_file.log,'SETUP_BALANCE_DEFINITIONS ' ||p_balance_name);

 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure SETUP_BALANCE_DEFINITIONS',130);
 END IF;

 END SETUP_BALANCE_DEFINITIONS;

------------------------------------ FUNCTION GET_COUNTRY_NAME --------------------------------------------------------------

 /* GET COUNTRY NAME FROM CODE */

 FUNCTION GET_COUNTRY_NAME(p_territory_code VARCHAR2)
 RETURN VARCHAR2
 IS

 CURSOR csr_get_territory_name(p_territory_code VARCHAR2) Is
 SELECT territory_short_name
 FROM   fnd_territories_vl
 WHERE  territory_code = p_territory_code;

 l_country fnd_territories_vl.territory_short_name%TYPE;

 BEGIN

 IF g_debug THEN
      hr_utility.set_location(' Entering Function GET_COUNTRY_NAME',140);
 END IF;

     OPEN csr_get_territory_name(p_territory_code);
     FETCH csr_get_territory_name into l_country;
     CLOSE csr_get_territory_name;

     RETURN l_country;

 IF g_debug THEN
      hr_utility.set_location(' Leaving Function GET_COUNTRY_NAME',150);
 END IF;

 END GET_COUNTRY_NAME;

 ---------------------------------------  PROCEDURE ARCHIVE_EMPLOYEE_DETAILS -----------------------------------------------------------

/* EMPLOYEE DETAILS REGION */

 PROCEDURE ARCHIVE_EMPLOYEE_DETAILS (p_archive_assact_id        	IN NUMBER
  	   ,p_assignment_id            	IN NUMBER
  	   ,p_assignment_action_id      IN NUMBER
  	   ,p_payroll_action_id         IN NUMBER
  	   ,p_time_period_id            IN NUMBER
  	   ,p_date_earned              	IN DATE
  	   ,p_pay_date_earned           IN DATE
  	   ,p_effective_date            IN DATE) IS

 -------------
 /* Cursor to retrieve person details about Employee */
 CURSOR csr_person_details(p_assignment_id NUMBER) IS
 SELECT ppf.person_id person_id,
        ppf.full_name full_name,
        ppf.national_identifier ni_number,
        ppf.nationality nationality,
        pps.date_start start_date,
        ppf.employee_number emp_num,
        ppf.first_name first_name,
        ppf.last_name last_name,
        ppf.title title,
        paf.location_id loc_id,
        paf.organization_id org_id,  -- HR Org at Asg level
        paf.job_id job_id,
        paf.position_id pos_id,
        paf.grade_id grade_id,
        paf.business_group_id bus_grp_id,
	paf.assignment_number asg_num
 FROM   per_assignments_f paf,
        per_all_people_f ppf,
        per_periods_of_service pps
 WHERE  paf.person_id = ppf.person_id
 AND    paf.assignment_id = p_assignment_id
 AND    pps.person_id = ppf.person_id
 AND    p_date_earned BETWEEN paf.effective_start_date AND paf.effective_end_date
 AND    p_date_earned BETWEEN ppf.effective_start_date AND ppf.effective_end_date;

 -------------
 /* Cursor to retrieve primary address of Employee */
 CURSOR csr_primary_address(p_person_id NUMBER) IS
 SELECT pa.person_id person_id,
        pa.style style,
        pa.address_type ad_type,
        pa.country country,
        pa.region_1 R1,
        pa.region_2 R2,
        pa.region_3 R3,
        pa.town_or_city city,
        pa.address_line1 AL1,
        pa.address_line2 AL2,
        pa.address_line3 AL3,
        pa.postal_code postal_code
 FROM   per_addresses pa
 WHERE  pa.primary_flag = 'Y'
 AND    pa.person_id = p_person_id
 AND    p_effective_date BETWEEN pa.date_from  AND NVL(pa.date_to,to_date('31-12-4712','DD-MM-YYYY'));

 -------------
 /* Cursor to retrieve Employer's Address */
 CURSOR csr_employer_address(p_organization_id NUMBER) IS
 SELECT hla.style style
        ,hla.country country
        ,hla.address_line_1 AL1
        ,hla.address_line_2 AL2
        ,hla.address_line_3 AL3
        ,hla.postal_code postal_code
 FROM    hr_locations_all hla
     	,hr_organization_units hou
 WHERE	hou.organization_id = p_organization_id
 AND	hou.location_id = hla.location_id;
 -------------
 CURSOR csr_organization_address(p_organization_id NUMBER) IS
 SELECT hla.style style
       ,hla.address_line_1 AL1
       ,hla.address_line_2 AL2
       ,hla.address_line_3 AL3
       ,hla.country        country
       ,hla.postal_code    postal_code
 FROM   hr_locations_all hla,
        hr_organization_units hoa
 WHERE  hla.location_id = hoa.location_id
 AND    hoa.organization_id = p_organization_id
 AND    p_effective_date BETWEEN hoa.date_from  AND    NVL(hoa.date_to,to_date('31-12-4712','DD-MM-YYYY'));

 --------------
 /* Cursor to retrieve Business Group Id */
 CURSOR csr_bus_grp_id(p_organization_id NUMBER) IS
 SELECT business_group_id
 FROM   hr_organization_units
 WHERE  organization_id = p_organization_id;
 --------------
 /* Cursor to retrieve Currency */
 CURSOR csr_currency(p_bg_id NUMBER) IS
 SELECT org_information10
 FROM   hr_organization_information
 WHERE  organization_id = p_bg_id
 AND    org_information_context = 'Business Group Information';

 --------------
 l_bg_id NUMBER;
 --------------

/* Cursor to get the Legal Employer from Local Unit */

 CURSOR csr_legal_employer (p_organization_id NUMBER) IS
 SELECT	hoi3.organization_id
 FROM	HR_ORGANIZATION_UNITS o1
 , HR_ORGANIZATION_INFORMATION hoi1
 , HR_ORGANIZATION_INFORMATION hoi2
 , HR_ORGANIZATION_INFORMATION hoi3
 WHERE  o1.business_group_id =l_bg_id
 AND	hoi1.organization_id = o1.organization_id
 AND	hoi1.organization_id = p_organization_id
 AND	hoi1.org_information1 = 'NO_LOCAL_UNIT'
 AND	hoi1.org_information_context = 'CLASS'
 AND	o1.organization_id = hoi2.org_information1
 AND	hoi2.ORG_INFORMATION_CONTEXT='NO_LOCAL_UNITS'
 AND	hoi2.organization_id =  hoi3.organization_id
 AND	hoi3.ORG_INFORMATION_CONTEXT='CLASS'
 AND	hoi3.org_information1 = 'HR_LEGAL_EMPLOYER';


 -------------
 /* Cursor to retrieve Grade of Employee */
 CURSOR csr_grade(p_grade_id NUMBER) IS
 SELECT pg.name
 FROM   per_grades pg
 WHERE  pg.grade_id = p_grade_id;
 -------------
 /* Cursor to retrieve Position of Employee */
 CURSOR csr_position(p_position_id NUMBER) IS
 SELECT pap.name
 FROM   per_all_positions pap
 WHERE  pap.position_id = p_position_id;
 -------------
 CURSOR csr_job (p_job_id NUMBER)IS
 SELECT name
 FROM per_jobs
 WHERE job_id = p_job_id;
 -------------
 /* Cursor to retrieve Cost Center */
 CURSOR csr_cost_center(p_assignment_id NUMBER) IS
 SELECT concatenated_segments
 FROM   pay_cost_allocations_v
 WHERE  assignment_id=p_assignment_id
 AND    p_date_earned BETWEEN effective_start_date AND effective_end_date;
 -------------
 /* Cursor to pick up Payroll Location */
 CURSOR csr_pay_location(p_location_id NUMBER) IS
 SELECT location_code location
 FROM hr_locations_all
 WHERE location_id = p_location_id;
 -------------
 /* Cursor to pick Hire Date*/
 CURSOR csr_hire_date (p_assignment_id NUMBER) IS
 SELECT date_start
 FROM 	per_periods_of_service pps,
	per_all_assignments_f paa
 WHERE pps.period_of_service_id = paa.period_of_service_id
 AND p_date_earned between paa.effective_start_date and paa.effective_end_date
 AND paa.assignment_id = p_assignment_id;
 -------------
 /*Cursor to pick local unit*/

 cursor csr_scl_details (p_assignment_id NUMBER) IS
 SELECT segment2
 from per_all_assignments_f paaf
     ,HR_SOFT_CODING_KEYFLEX hsck
 where paaf.assignment_id= p_assignment_id
 and p_date_earned BETWEEN paaf.effective_start_date and paaf.effective_end_date
 and paaf.SOFT_CODING_KEYFLEX_ID = hsck.SOFT_CODING_KEYFLEX_ID;

--------------

/* Ccursor to get the Legal Employer Org Number */
CURSOR csr_le_org_num (l_legal_employer_id NUMBER) IS
select ORG_INFORMATION1
from hr_organization_information
where organization_id = l_legal_employer_id
and ORG_INFORMATION_CONTEXT = 'NO_LEGAL_EMPLOYER_DETAILS' ;


/* Cursor to get the Org name */
CURSOR csr_org_name (p_org_name  hr_organization_units.name%type ) IS
SELECT name
FROM hr_organization_units
WHERE organization_id = p_org_name ;


/* cursor to get the primary assignment id */

CURSOR csr_get_prim_asg (p_date_earned DATE , p_asg_id	NUMBER) IS
SELECT asg2.assignment_id
FROM per_all_assignments_f 	asg1
    ,per_all_assignments_f 	asg2
WHERE asg1.assignment_id = p_asg_id
AND   asg1.person_id = asg2.person_id
AND   asg2.primary_flag = 'Y'
AND   p_date_earned BETWEEN asg1.effective_start_date AND asg1.effective_end_date
AND   p_date_earned BETWEEN asg2.effective_start_date AND asg2.effective_end_date ;

 -------------
 rec_person_details		csr_person_details%ROWTYPE;
 rec_primary_address		csr_primary_address%ROWTYPE;
 rec_employer_address		csr_employer_address%ROWTYPE;
 rec_org_address		csr_organization_address%ROWTYPE;
 l_nationality			per_all_people_f.nationality%TYPE;
 l_position 			per_all_positions.name%TYPE;
 l_hire_date			per_periods_of_service.date_start%TYPE;
 l_grade			per_grades.name%TYPE;
 l_currency			hr_organization_information.org_information10%TYPE;
 l_organization			hr_organization_units.name%TYPE;
 l_pay_location			hr_locations_all.address_line_1%TYPE;
 l_postal_code			VARCHAR2(80);
 l_country			VARCHAR2(30);
 l_emp_postal_code		VARCHAR2(80);
 l_emp_country			VARCHAR2(30);
 l_org_city			VARCHAR2(20);
 l_org_country			VARCHAR2(30);
 l_action_info_id		NUMBER;
 l_ovn				NUMBER;
 l_person_id			NUMBER;
 l_employer_name		hr_organization_units.name%TYPE;
 l_local_unit_id		hr_organization_units.organization_id%TYPE;
 l_legal_employer_id		hr_organization_units.organization_id%TYPE;
 l_job				PER_JOBS.NAME%TYPE;
 l_org_struct_ver_id		hr_organization_information.org_information1%TYPE;
 l_top_org_id			per_org_structure_elements.organization_id_parent%TYPE;
 l_cost_center			pay_cost_allocations_v.concatenated_segments%TYPE;
 l_defined_balance_id		NUMBER;
 l_balance_value		NUMBER;
 l_formatted_value		VARCHAR2(50) := NULL;
 l_org_exists			NUMBER :=0;
 le_phone_num			VARCHAR2(240);
 le_phone_num_str		VARCHAR2(1000);
 l_cvr_num			VARCHAR2(240);
 l_le_org_num			VARCHAR2(240);

 l_prim_asg_id		NUMBER;
 l_prim_local_unit	NUMBER;
 l_prim_legal_emp	NUMBER;
 l_diff_le_text		VARCHAR2(2);
 l_msg_txt		VARCHAR2(240);

-- l_lower_base NUMBER :=0;
-- l_upper_base NUMBER :=0;
 -------------

 BEGIN

 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ARCHIVE_EMPLOYEE_DETAILS',160);
 END IF;

 /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS');*/

	/* PERSON AND ADDRESS DETAILS */
        OPEN csr_person_details(p_assignment_id);
 	FETCH csr_person_details INTO rec_person_details;
        CLOSE csr_person_details;

	-- fnd_file.put_line(fnd_file.log,'after cursor csr_person_details ');

	OPEN csr_primary_address(rec_person_details.person_id);
 	FETCH csr_primary_address INTO rec_primary_address;
        CLOSE csr_primary_address;

	-- fnd_file.put_line(fnd_file.log,'after cursor csr_primary_address ');

	-- rec_person_details.org_id is the org_id of the HR org at asg level

	OPEN csr_organization_address(rec_person_details.org_id);
 	FETCH csr_organization_address INTO rec_org_address;
        CLOSE csr_organization_address;

	-- fnd_file.put_line(fnd_file.log,'after cursor csr_organization_address ');

  /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 2');*/

	/* GRADE AND POSITION */

	/* Changed IF condition construct */
        IF(rec_person_details.pos_id IS NOT NULL) THEN
	 	OPEN csr_position(rec_person_details.pos_id);
 	    	FETCH csr_position INTO l_position;
	 	CLOSE csr_position;
        END IF;

	IF(rec_person_details.grade_id IS NOT NULL) THEN
	 	OPEN csr_grade(rec_person_details.grade_id);
 	    	FETCH csr_grade INTO l_grade;
	 	CLOSE csr_grade;
        END IF;

   /*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 3');*/

	/* CURRENCY */


	-- rec_person_details.org_id is the org_id of the HR org at asg level
	OPEN csr_bus_grp_id(rec_person_details.org_id);
	FETCH csr_bus_grp_id INTO l_bg_id;
        CLOSE csr_bus_grp_id;

	OPEN csr_currency(l_bg_id);
 	FETCH csr_currency INTO l_currency;
	CLOSE csr_currency;

	g_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);

	/* COST CENTER */
    	OPEN csr_cost_center(p_assignment_id);
	FETCH csr_cost_center INTO l_cost_center;
	CLOSE csr_cost_center;


	/* HIRE DATE */
    	OPEN csr_hire_date(p_assignment_id);
	FETCH csr_hire_date INTO l_hire_date;
	CLOSE csr_hire_date;

	/*NATIONALITY*/
        l_nationality := hr_general.decode_lookup('NATIONALITY',rec_person_details.nationality);

	/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 4');*/

	/*Local Unit*/

	    OPEN csr_scl_details(p_assignment_id);
	    FETCH csr_scl_details INTO l_local_unit_id;
	    CLOSE csr_scl_details;


	/* Getting Legal Employer */

	    OPEN csr_legal_employer(l_local_unit_id);
	    FETCH csr_legal_employer INTO l_legal_employer_id;
	    CLOSE csr_legal_employer;

	   /*Legal Employer */
    	/*
	    OPEN csr_scl_details(p_assignment_id);
	    FETCH csr_scl_details INTO l_legal_employer_id ;
	    CLOSE csr_scl_details;
	  */

	    OPEN csr_employer_address(l_legal_employer_id);
	    FETCH csr_employer_address INTO rec_employer_address;
	    CLOSE csr_employer_address;

	IF(rec_person_details.loc_id IS NOT NULL) THEN
		l_pay_location := NULL;

		OPEN csr_pay_location(rec_person_details.loc_id);
	  	FETCH csr_pay_location INTO l_pay_location;
		CLOSE csr_pay_location;
        ELSE
		l_pay_location := NULL;
        END IF;


	IF(rec_person_details.job_id IS NOT NULL) THEN

		OPEN csr_job(rec_person_details.job_id);
	   	FETCH csr_job INTO l_job;
	 	CLOSE csr_job;
        ELSE
		l_job := NULL;
        END IF;

	-- HR ORG at asg level Name
	OPEN csr_org_name (rec_person_details.org_id) ;
	FETCH csr_org_name INTO l_organization ;
	CLOSE csr_org_name ;

	-- Legal Employer Name
	OPEN csr_org_name (l_legal_employer_id) ;
	FETCH csr_org_name INTO l_employer_name ;
	CLOSE csr_org_name ;


	/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 5');*/

	IF rec_primary_address.style = 'NO' THEN
 		l_postal_code := hr_general.decode_lookup('NO_POSTAL_CODE',rec_primary_address.postal_code);
 	ELSE
 		l_postal_code := rec_primary_address.postal_code;
 	END IF;

	l_country := PAY_NO_PAYSLIP_ARCHIVE.get_country_name(rec_primary_address.country);

	IF rec_employer_address.style = 'NO' THEN
 		l_emp_postal_code := hr_general.decode_lookup('NO_POSTAL_CODE',rec_employer_address.postal_code);
 	ELSE
 		l_emp_postal_code := rec_employer_address.postal_code;
 	END IF;

	l_emp_country := PAY_NO_PAYSLIP_ARCHIVE.get_country_name(rec_employer_address.country);

	/* Getting Legal Employer Phone Number String */

	 le_phone_num_str := NULL;


	/* Get Legal Employer Org Number */

	OPEN csr_le_org_num (l_legal_employer_id ) ;
	FETCH csr_le_org_num INTO l_le_org_num ;
	CLOSE csr_le_org_num ;

        /* Archive a message if the current Legal Employer is different from the Legal Employer of the Primary Assignment */

	 l_diff_le_text := 'N' ;

	 /* get the primary assignment id */
	 OPEN csr_get_prim_asg (p_date_earned , p_assignment_id );
	 FETCH csr_get_prim_asg INTO l_prim_asg_id ;
	 CLOSE csr_get_prim_asg ;

	 IF ( p_assignment_id <> l_prim_asg_id )
	    THEN

		 /* the Local Unit for the current assignment = l_local_unit_id */

		 /* OPEN csr_scl_details (p_assignment_id ) ;
		 FETCH csr_scl_details INTO l_local_unit ;
		 CLOSE csr_scl_details ; */

		  /* get the Local Unit for the primary assignment */
		 OPEN csr_scl_details (l_prim_asg_id ) ;
		 FETCH csr_scl_details INTO l_prim_local_unit ;
		 CLOSE csr_scl_details ;

		 IF (l_local_unit_id <> l_prim_local_unit)
		    THEN

			 /* the Legal Employer for the current assignment = l_legal_employer_id */

			 /* OPEN csr_legal_employer (l_local_unit ) ;
			 FETCH csr_legal_employer INTO l_legal_emp ;
			 CLOSE csr_legal_employer ; */

			 /* get the Legal Employer for the primary assignment */
			 OPEN csr_legal_employer (l_prim_local_unit ) ;
			 FETCH csr_legal_employer INTO l_prim_legal_emp ;
			 CLOSE csr_legal_employer ;

			 IF (l_legal_employer_id <> l_prim_legal_emp) THEN

				l_diff_le_text := 'Y' ;

				/* set the message name and get the message text */
				hr_utility.set_message (801, 'PAY_376864_NO_SEC_ASG_LE_DIFF');
				l_msg_txt := hr_utility.get_message ;

				/* Arcvhive the message */
				pay_action_information_api.create_action_information (
				    p_action_information_id        => l_action_info_id
				   ,p_action_context_id            => p_archive_assact_id
				   ,p_action_context_type          => 'AAP'
				   ,p_object_version_number        => l_ovn
				   ,p_effective_date               => p_effective_date
				   ,p_source_id                    => NULL
				   ,p_source_text                  => NULL
				   ,p_action_information_category  => 'EMPLOYEE OTHER INFORMATION'
				   ,p_action_information1          => l_bg_id
				   ,p_action_information2          => 'MESG' -- Message Context
				   ,p_action_information3          => NULL
				   ,p_action_information4          => NULL
				   ,p_action_information5          => NULL
				   ,p_action_information6          => l_msg_txt );

			 END IF ;

		END IF ;

	 END IF ;

        /* Finished archiving a message if the current Legal Employer is different from the Legal Employer of the Primary Assignment */

	/* INSERT PERSON DETAILS */

	pay_action_information_api.create_action_information (
 		  p_action_information_id        => l_action_info_id
 		 ,p_action_context_id            => p_archive_assact_id
 		 ,p_action_context_type          => 'AAP'
 		 ,p_object_version_number        => l_ovn
 		 ,p_effective_date               => p_effective_date
 		 ,p_source_id                    => NULL
 		 ,p_source_text                  => NULL
 		 ,p_action_information_category  => 'EMPLOYEE DETAILS'
 		 ,p_action_information1          => rec_person_details.full_name
 		 ,p_action_information2          => l_legal_employer_id -- Legal Employer Org ID
 		 ,p_action_information4          => rec_person_details.ni_number
 		 ,p_action_information7          => l_grade
 		 ,p_action_information10         => rec_person_details.emp_num
 		 ,p_action_information12	 => fnd_date.date_to_displaydate(l_hire_date) -- fnd_date.date_to_canonical(l_hire_date)
 		 ,p_action_information14         => rec_person_details.asg_num
		 ,p_action_information15         => l_organization	-- name of HR Org at asg level
 		 ,p_action_information16         => p_time_period_id
 		 ,p_action_information17         => l_job
 		 ,p_action_information18         => l_employer_name	-- Legal Employer Name
 		 ,p_action_information19         => l_position
 		 ,p_action_information25         => le_phone_num_str
 		 ,p_action_information30         => l_pay_location
 		 ,p_assignment_id                => p_assignment_id);


	/* INSERT ADDRESS DETAILS */
        IF rec_primary_address.AL1 IS NOT NULL THEN   /* CHECK IF EMPLOYEE HAS BEEN GIVEN A PRIMARY ADDRESS */
        pay_action_information_api.create_action_information (
 		  p_action_information_id        => l_action_info_id
 		 ,p_action_context_id            => p_archive_assact_id
 		 ,p_action_context_type          => 'AAP'
 		 ,p_object_version_number        => l_ovn
 		 ,p_effective_date               => p_effective_date
 		 ,p_source_id                    => NULL
 		 ,p_source_text                  => NULL
 		 ,p_action_information_category  => 'ADDRESS DETAILS'
 		 ,p_action_information1          => rec_primary_address.person_id
 		 ,p_action_information5          => rec_primary_address.AL1
 		 ,p_action_information6          => rec_primary_address.AL2
 		 ,p_action_information7          => rec_primary_address.AL3
 		 ,p_action_information12         => l_postal_code
 		 ,p_action_information13         => l_country
 		 ,p_action_information14         => 'Employee Address'
 		 ,p_assignment_id                => p_assignment_id);
        ELSE
        /* INSERT EMPLOYER ADDRESS AS EMPLOYEE'S PRIMARY ADDRESS */
        pay_action_information_api.create_action_information (
 		  p_action_information_id        => l_action_info_id
 		 ,p_action_context_id            => p_archive_assact_id
 		 ,p_action_context_type          => 'AAP'
 		 ,p_object_version_number        => l_ovn
 		 ,p_effective_date               => p_effective_date
 		 ,p_source_id                    => NULL
 		 ,p_source_text                  => NULL
 		 ,p_action_information_category  => 'ADDRESS DETAILS'
 		 ,p_action_information1          => rec_primary_address.person_id
 		 ,p_action_information5          => NULL
 		 ,p_action_information6          => NULL
 		 ,p_action_information7          => NULL
 		 ,p_action_information8          => NULL
 		 ,p_action_information9          => NULL
 		 ,p_action_information10         => NULL
 		 ,p_action_information11         => NULL
 		 ,p_action_information12         => NULL
 		 ,p_action_information13         => NULL
 		 ,p_action_information14         => 'Employee Address'
 		 ,p_assignment_id                => p_assignment_id);
        END IF;

	/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 9');*/

	/* INSERT EMPLOYER'S ADDRESS (ORGANIZATION ADDRESS)*/

       BEGIN
       l_org_exists := 0;

	SELECT 1
        INTO l_org_exists
        FROM   pay_action_information
        WHERE  action_context_id = p_payroll_action_id
        AND    action_information1 = l_legal_employer_id -- rec_person_details.org_id
        AND    effective_date      = p_effective_date
        AND    action_information_category = 'ADDRESS DETAILS';

       EXCEPTION

	WHEN NO_DATA_FOUND THEN
 	pay_action_information_api.create_action_information (
  	  p_action_information_id        => l_action_info_id
  	 ,p_action_context_id            => p_payroll_action_id
  	 ,p_action_context_type          => 'PA'
  	 ,p_object_version_number        => l_ovn
  	 ,p_effective_date               => p_effective_date
  	 ,p_source_id                    => NULL
  	 ,p_source_text                  => NULL
  	 ,p_action_information_category  => 'ADDRESS DETAILS'
  	 ,p_action_information1          => l_legal_employer_id -- rec_person_details.org_id
  	 ,p_action_information5          => rec_employer_address.AL1
  	 ,p_action_information6          => rec_employer_address.AL2
  	 ,p_action_information7          => rec_employer_address.AL3
  	 ,p_action_information12         => l_emp_postal_code
  	 ,p_action_information13         => l_emp_country
  	 ,p_action_information14         => 'Employer Address'
  	 ,p_action_information26         => l_le_org_num ); -- using Localization Specific1 for Legal Employer CVR Number

	WHEN OTHERS THEN
 		NULL;
 	END;

	/*fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_EMPLOYEE_DETAILS 10');*/

 --
 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ARCHIVE_EMPLOYEE_DETAILS',170);
 END IF;
 --

     EXCEPTION WHEN OTHERS THEN
     g_err_num := SQLCODE;
 	/*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_EMPLOYEE_DETAILS');*/

	IF g_debug THEN
 	     hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_EMPLOYEE_DETAILS',180);
 	END IF;

 END ARCHIVE_EMPLOYEE_DETAILS;

 ----------------------------------- PROCEDURE ARCHIVE_ELEMENT_INFO ---------------------------------------------------------------

/* EARNINGS REGION, DEDUCTIONS REGION */

 PROCEDURE ARCHIVE_ELEMENT_INFO(p_payroll_action_id IN NUMBER
				,p_effective_date    IN DATE
				,p_date_earned       IN DATE
				,p_pre_payact_id     IN NUMBER)
 IS
 ----------------

 /* Cursor to retrieve Earnings Element Information */

/*

 CURSOR csr_ear_element_info IS
 SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
       ,et.element_type_id element_type_id
       ,iv.input_value_id input_value_id
       ,iv.uom uom
 FROM   pay_element_types_f         et
 ,      pay_element_types_f_tl      pettl
 ,      pay_input_values_f          iv
 ,      pay_element_classifications classification
 WHERE  et.element_type_id              = iv.element_type_id
 AND    et.element_type_id              = pettl.element_type_id
 AND    pettl.language                  = USERENV('LANG')
 AND    iv.name                         = 'Pay Value'
 AND    classification.classification_id   = et.classification_id
 AND    classification.classification_name
	IN ('Absence','Direct Payments','Earnings','Supplementary Earnings')
 AND    p_date_earned       BETWEEN et.effective_start_date  AND et.effective_end_date
 AND    p_date_earned       BETWEEN iv.effective_start_date  AND iv.effective_end_date
 AND ((et.business_group_id IS NULL AND et.legislation_code = 'NO')
	OR (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL));

*/
-----------------

  /* Cursor to retrieve Deduction Element Information */

 /*
 CURSOR csr_ded_element_info IS
 SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
       ,et.element_type_id element_type_id
       ,iv.input_value_id input_value_id
       ,iv.uom uom
 FROM   pay_element_types_f         et
 ,      pay_element_types_f_tl      pettl
 ,      pay_input_values_f          iv
 ,      pay_element_classifications classification
 WHERE  et.element_type_id              = iv.element_type_id
 AND    et.element_type_id              = pettl.element_type_id
 AND    pettl.language                  = USERENV('LANG')
 AND    iv.name                         = 'Pay Value'
 AND    classification.classification_id   = et.classification_id
 AND    classification.classification_name
		IN ('Involuntary Deductions','Pre-tax Deductions','Statutory Deductions','Voluntary Deductions')
 AND    p_date_earned       BETWEEN et.effective_start_date  AND et.effective_end_date
 AND    p_date_earned       BETWEEN iv.effective_start_date  AND iv.effective_end_date
 AND ((et.business_group_id IS NULL AND et.legislation_code = 'NO')
	 OR  (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL));

*/
----------------------------------------------------------------------------------------------------------

 /* Cursor to retrieve Element Information (For elements with Pay Value as Input Value) */

/*
 CURSOR csr_element_info IS
 SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
       ,et.element_type_id element_type_id
       ,iv.input_value_id input_value_id
       ,iv.uom uom
       ,classification.classification_name ele_class
 FROM   pay_element_types_f         et
 ,      pay_element_types_f_tl      pettl
 ,      pay_input_values_f          iv
 ,      pay_element_classifications classification
 WHERE  et.element_type_id              = iv.element_type_id
 AND    et.element_type_id              = pettl.element_type_id
 AND    pettl.language                  = USERENV('LANG')
 AND    iv.name                         = 'Pay Value'
 AND    classification.classification_id   = et.classification_id
 AND    classification.classification_name
	IN ('Earnings','Supplementary Earnings','Absence','Direct Payments','Pre-tax Deductions',
	    'Involuntary Deductions','Voluntary Deductions','Statutory Deductions','Reductions',
	    'Taxable Benefits','Benefits Not Taxed','Expenses Information','Taxable Expenses')
 AND    p_date_earned       BETWEEN et.effective_start_date  AND et.effective_end_date
 AND    p_date_earned       BETWEEN iv.effective_start_date  AND iv.effective_end_date
 AND ((et.business_group_id IS NULL AND et.legislation_code = 'NO')
       OR (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL))
 ORDER BY DECODE (classification.classification_name,
			'Earnings',1,'Supplementary Earnings',2,'Absence',3,'Direct Payments',4,
			'Pre-tax Deductions',5,'Involuntary Deductions',6,'Voluntary Deductions',7,
			'Statutory Deductions',8,'Reductions',9,'Taxable Benefits',10,
			'Benefits Not Taxed',11,'Expenses Information',12,'Taxable Expenses',13) ;

*/

 CURSOR csr_element_info (p_ele_class_name  pay_element_classifications.classification_name%type ) IS
 SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
       ,et.element_type_id element_type_id
       ,iv.input_value_id input_value_id
       ,iv.uom uom
       ,classification.classification_name ele_class
 FROM   pay_element_types_f         et
 ,      pay_element_types_f_tl      pettl
 ,      pay_input_values_f          iv
 ,      pay_element_classifications classification
 WHERE  et.element_type_id              = iv.element_type_id
 AND    et.element_type_id              = pettl.element_type_id
 AND    pettl.language                  = USERENV('LANG')
 AND    iv.name                         = 'Pay Value'
 AND    classification.classification_id   = et.classification_id
 AND    classification.classification_name = p_ele_class_name
 AND    p_date_earned       BETWEEN et.effective_start_date  AND et.effective_end_date
 AND    p_date_earned       BETWEEN iv.effective_start_date  AND iv.effective_end_date
 AND ((et.business_group_id IS NULL AND et.legislation_code = 'NO')
       OR (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL)) ;


----------------------------------------------------------------------------------------------------------

/* Cursor to get the first primary balance type id for an input value id */

 CURSOR csr_prim_bal_type (p_iv_id  NUMBER)IS
 SELECT balance_type_id
 FROM   pay_balance_types
 WHERE  input_value_id = p_iv_id
 AND ((business_group_id IS NULL AND legislation_code = 'NO')
       OR (business_group_id = g_business_group_id AND legislation_code IS NULL))
 AND rownum = 1 ;

----------------------------------------------------------------------------------------------------

/* Cursor to get the defined balance id */

 CURSOR csr_def_bal_id (p_prim_bal_type_id  NUMBER)IS
 SELECT defined_balance_id
 FROM   pay_defined_balances
 WHERE  balance_type_id = p_prim_bal_type_id
 AND ((business_group_id IS NULL AND legislation_code = 'NO')
       OR (business_group_id = g_business_group_id AND legislation_code IS NULL))
 AND    balance_dimension_id = ( select balance_dimension_id
                                 from pay_balance_dimensions where legislation_code = 'NO'
				 and dimension_name = 'Assignment Calendar Year To Date' ) ;

----------------------------------------------------------------------------------------------------

/* cursor to get the sub classifications for an element type */

/*
CURSOR csr_sub_class (p_ele_type_id  NUMBER) IS
SELECT eleclass.classification_name
      ,decode (eleclass.classification_name,'Taxable Pay _ Absence',1,'Taxable Pay _ Earnings',1
		,'Taxable Pay _ Supplemental Earnings',1,'Taxable Pay _ Taxable Benefits',1,0) table_base
      ,decode (eleclass.classification_name,'Additional Taxable Pay _ Absence',2,'Additional Taxable Pay _ Earnings',2
		,'Additional Taxable Pay _ Supplemental Earnings',2,'Additional Taxable Pay _ Taxable Benefits',2,0) percent_base
      ,decode (eleclass.classification_name,'Holiday Pay',3,0) holiday_pay

FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass

WHERE subclass.element_type_id = p_ele_type_id
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL))
AND eleclass.classification_id = subclass.classification_id ;

*/

CURSOR csr_sub_class (p_ele_type_id  NUMBER , p_ele_sub_class_name  pay_element_classifications.classification_name%type ) IS
SELECT 1
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND   eleclass.classification_name = p_ele_sub_class_name
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL))
AND eleclass.classification_id = subclass.classification_id ;


-- cursor to check if an element has a holiday pay secondary classification

/*
CURSOR csr_hol_sub_class (p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Holiday Pay Earnings Adjustment',
					'Holiday Pay Base _ Supplementary Earnings')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;

*/

/* Change for element classification name from 'Holiday Pay Earnings Adjustment' to 'Holiday Pay Earnings Adjust' */

/*
CURSOR csr_hol_sub_class (p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Holiday Pay Earnings Adjust',
					'Holiday Pay Base _ Supplementary Earnings')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;
*/


/* Sub classification added for Impact of Absence on Holiday Pay */
/*
CURSOR csr_hol_sub_class (p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Holiday Pay Earnings Adjust',
					'Holiday Pay Base _ Supplementary Earnings',
					'Holiday Pay Base During Absence _ Information')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;

*/

-- The following classifications have been obsoleted and will no longer be used.
-- Holiday Pay Base _ Holiday Pay Earnings Adjust => Holiday Pay Base _ Holiday Pay Earnings Adjust Obsolete

CURSOR csr_hol_sub_class (p_ele_type_id  NUMBER  ) IS
SELECT 'YES'
FROM pay_sub_classification_rules_f		subclass
     ,pay_element_classifications		eleclass
WHERE subclass.element_type_id = p_ele_type_id
AND eleclass.classification_id = subclass.classification_id
AND   eleclass.classification_name in ( 'Holiday Pay Base _ Absence',
					'Holiday Pay Base _ Earnings',
					'Holiday Pay Base _ Earnings Adjustment',
					'Holiday Pay Base _ Supplementary Earnings',
					'Holiday Pay Base During Absence _ Information')
AND p_date_earned BETWEEN subclass.effective_start_date AND subclass.effective_end_date
AND ((subclass.business_group_id IS NULL AND subclass.legislation_code = 'NO')
		OR (subclass.business_group_id = g_business_group_id AND subclass.legislation_code IS NULL))
AND ((eleclass.business_group_id IS NULL AND eleclass.legislation_code = 'NO')
		OR (eleclass.business_group_id = g_business_group_id AND eleclass.legislation_code IS NULL)) ;


----------------------------------------------------------------------------------------------------------------------

---------------------
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
 l_flag			NUMBER := 0;
 l_prim_bal_type_id	NUMBER;
 l_prim_def_bal_id	NUMBER ;
 l_table_basis		NUMBER;
 l_percent_basis	NUMBER;
 l_holiday_basis	NUMBER;
 l_ele_class		VARCHAR2(240);
 l_basis_text		VARCHAR2(240);
 l_holiday_text		VARCHAR2(240);
 l_index		NUMBER;

 TYPE ele_class_rec IS RECORD ( ele_class_name  pay_element_classifications.classification_name%type
				, ele_context	VARCHAR2(20) );

 TYPE ele_class_tab  IS TABLE OF  ele_class_rec  INDEX BY BINARY_INTEGER;

 ele_class_table		ele_class_tab;

----------------------
 BEGIN

 IF g_debug THEN
      hr_utility.set_location(' Entering Procedure ARCHIVE_ELEMENT_INFO',210);
 END IF;

------------------------
     /* ALL ELEMENTS */


  /* initializing table for element classification name */
  ele_class_table(1).ele_class_name := 'Earnings';			ele_class_table(1).ele_context	:= 'S' ;
  ele_class_table(2).ele_class_name := 'Supplementary Earnings';	ele_class_table(2).ele_context	:= 'S' ;
  ele_class_table(3).ele_class_name := 'Absence';			ele_class_table(3).ele_context	:= 'S' ;
  ele_class_table(4).ele_class_name := 'Direct Payments';		ele_class_table(4).ele_context	:= 'OR' ;
  ele_class_table(5).ele_class_name := 'Pre-tax Deductions';		ele_class_table(5).ele_context	:= 'OD' ;
  ele_class_table(6).ele_class_name := 'Involuntary Deductions';	ele_class_table(6).ele_context	:= 'OD' ;
  ele_class_table(7).ele_class_name := 'Voluntary Deductions';		ele_class_table(7).ele_context	:= 'OD' ;
  ele_class_table(8).ele_class_name := 'Statutory Deductions'; 		ele_class_table(8).ele_context	:= 'WT' ;
  ele_class_table(9).ele_class_name := 'Reductions'; 			ele_class_table(9).ele_context	:= 'OTH' ;
  ele_class_table(10).ele_class_name := 'Taxable Benefits';		ele_class_table(10).ele_context	:= 'OTH' ;
  ele_class_table(11).ele_class_name := 'Benefits Not Taxed';		ele_class_table(11).ele_context	:= 'OTH' ;
  ele_class_table(12).ele_class_name := 'Expenses Information';		ele_class_table(12).ele_context	:= 'OTH' ;
  ele_class_table(13).ele_class_name := 'Taxable Expenses'; 		ele_class_table(13).ele_context	:= 'OTH' ;
  -- new added
  -- ele_class_table(14).ele_class_name := 'Earnings Adjustment';		ele_class_table(14).ele_context	:= 'OD' ;
  -- ele_class_table(15).ele_class_name := 'Holiday Pay Earnings Adjustment';	ele_class_table(15).ele_context	:= 'OD' ;

  -- should be displayed in the 'Total Salary' with a negative sign
  ele_class_table(14).ele_class_name := 'Earnings Adjustment';			ele_class_table(14).ele_context	:= 'S' ;
  -- ele_class_table(15).ele_class_name := 'Holiday Pay Earnings Adjustment';	ele_class_table(15).ele_context	:= 'S' ;

/* Change for element classification name from 'Holiday Pay Earnings Adjustment' to 'Holiday Pay Earnings Adjust' */

-- The following classifications have been obsoleted and will no longer be used.
-- Holiday Pay Earnings Adjust => Holiday Pay Earnings Adjust Obsolete
-- Commenting the code below.

--  ele_class_table(15).ele_class_name := 'Holiday Pay Earnings Adjust';	ele_class_table(15).ele_context	:= 'S' ;

/* Element classification 'Information' added for Impact of Absence on Holiday Pay */
-- ele_class_table(16).ele_class_name := 'Information'; 			ele_class_table(16).ele_context	:= 'OTH' ;

-- Due to the obsoletion of the above classification , moving the index from 16 to 15
ele_class_table(15).ele_class_name := 'Information'; 			ele_class_table(15).ele_context	:= 'OTH' ;

-- Added for advance pay --
ele_class_table(16).ele_class_name := 'Advance Earnings';   ele_class_table(16).ele_context := 'S' ;
--

   FOR l_index IN ele_class_table.first.. ele_class_table.last LOOP

	  FOR rec_earnings IN csr_element_info(ele_class_table(l_index).ele_class_name) LOOP

		  BEGIN

			  l_prim_bal_type_id := NULL ;
			  l_prim_def_bal_id := NULL ;
			  l_ele_class := NULL ;
			  l_table_basis := NULL ;
			  l_percent_basis := NULL ;
			  l_holiday_basis := NULL ;
			  l_basis_text := NULL ;
			  l_holiday_text := NULL ;

			-- check if the element is basis for holiday pay

			/* moving on top to check for information elements whiich are basis for holiday pay :
			  element class : Information
			  sec class : Holiday Pay Base During Absence _ Information */

			 OPEN csr_hol_sub_class (rec_earnings.element_type_id) ;
			 FETCH csr_hol_sub_class INTO l_holiday_text ;
			 CLOSE csr_hol_sub_class ;

                        IF ((ele_class_table(l_index).ele_class_name <> 'Information')
			    OR
			    ((ele_class_table(l_index).ele_class_name = 'Information') AND
			     (l_holiday_text = 'YES'))) THEN

			-- fnd_file.put_line(fnd_file.log,'ele_class_table(l_index).ele_class_name ' || ele_class_table(l_index).ele_class_name );
			-- fnd_file.put_line(fnd_file.log,'rec_earnings.element_type_id ' || rec_earnings.element_type_id );
			-- fnd_file.put_line(fnd_file.log,'l_holiday_text = ' || l_holiday_text );
			-- fnd_file.put_line(fnd_file.log,'--------------------------------------------- ');



				  /* get the primary balance type id from the input value id */
				  OPEN csr_prim_bal_type (rec_earnings.input_value_id);
				  FETCH csr_prim_bal_type INTO l_prim_bal_type_id ;
				  CLOSE csr_prim_bal_type ;

				  /* get the defined balance id from the balance type id */
				  OPEN csr_def_bal_id (l_prim_bal_type_id ) ;
				  FETCH csr_def_bal_id INTO l_prim_def_bal_id ;
				  CLOSE csr_def_bal_id ;

				  /* get the table/percetage basis info */

				  l_basis_text := NULL ;

				  IF ( ele_class_table(l_index).ele_class_name = 'Pre-tax Deductions' )

					THEN  l_basis_text := 'TABLE';

				  ELSIF ( ele_class_table(l_index).ele_class_name = 'Taxable Expenses' )

					THEN l_basis_text := 'PERCENTAGE';

				  ELSIF ( ele_class_table(l_index).ele_class_name = 'Absence' )

					THEN
						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Taxable Pay _ Absence') ;
						FETCH csr_sub_class INTO l_table_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'TABLE';
						END IF;
						CLOSE csr_sub_class ;


						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Additional Taxable Pay _ Absence') ;
						FETCH csr_sub_class INTO l_percent_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'PERCENTAGE';
						END IF;
						CLOSE csr_sub_class ;


				  ELSIF ( ele_class_table(l_index).ele_class_name = 'Earnings' )

					THEN
						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Taxable Pay _ Earnings') ;
						FETCH csr_sub_class INTO l_table_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'TABLE';
						END IF;
						CLOSE csr_sub_class ;


						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Additional Taxable Pay _ Earnings') ;
						FETCH csr_sub_class INTO l_percent_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'PERCENTAGE';
						END IF;
						CLOSE csr_sub_class ;

				  ELSIF ( ele_class_table(l_index).ele_class_name = 'Supplementary Earnings' )

					THEN
						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Taxable Pay _ Supplemental Earnings') ;
						FETCH csr_sub_class INTO l_table_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'TABLE';
						END IF;
						CLOSE csr_sub_class ;


						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Additional Taxable Pay _ Supplemental Earnings') ;
						FETCH csr_sub_class INTO l_percent_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'PERCENTAGE';
						END IF;
						CLOSE csr_sub_class ;

				  ELSIF ( ele_class_table(l_index).ele_class_name = 'Taxable Benefits' )

					THEN
						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Taxable Pay _ Taxable Benefits') ;
						FETCH csr_sub_class INTO l_table_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'TABLE';
						END IF;
						CLOSE csr_sub_class ;


						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Additional Taxable Pay _ Taxable Benefits') ;
						FETCH csr_sub_class INTO l_percent_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'PERCENTAGE';
						END IF;
						CLOSE csr_sub_class ;

				  ELSIF ( ele_class_table(l_index).ele_class_name = 'Earnings Adjustment' )

					THEN
						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Taxable Pay _ Earnings Adjustment') ;
						FETCH csr_sub_class INTO l_table_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'TABLE';
						END IF;
						CLOSE csr_sub_class ;


						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Additional Taxable Pay _ Earnings Adjustment') ;
						FETCH csr_sub_class INTO l_percent_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'PERCENTAGE';
						END IF;
						CLOSE csr_sub_class ;

				  /* Change for element classification name from 'Holiday Pay Earnings Adjustment' to 'Holiday Pay Earnings Adjust' */

				  -- The following classifications have been obsoleted and will no longer be used.
				  -- Holiday Pay Earnings Adjust => Holiday Pay Earnings Adjust Obsolete
				  -- Taxable Pay _ Holiday Pay Earnings Adjust => Taxable Pay _ Holiday Pay Earnings Adjust Obsolete
				  -- Additional Taxable Pay _ Holiday Pay Earnings Adjust => Additional Taxable Pay _ Holiday Pay Earnings Adjust Obsolete
				  -- Commenting the code below.

				  /*

				  -- ELSIF ( ele_class_table(l_index).ele_class_name = 'Holiday Pay Earnings Adjustment' )
				  ELSIF ( ele_class_table(l_index).ele_class_name = 'Holiday Pay Earnings Adjust' )

					THEN
						-- OPEN  csr_sub_class (rec_earnings.element_type_id , 'Taxable Pay _ Holiday Pay Earnings Adjustment') ;
						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Taxable Pay _ Holiday Pay Earnings Adjust') ;
						FETCH csr_sub_class INTO l_table_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'TABLE';
						END IF;
						CLOSE csr_sub_class ;


						-- OPEN  csr_sub_class (rec_earnings.element_type_id , 'Additional Taxable Pay _ Holiday Pay Earnings Adjustment') ;
						OPEN  csr_sub_class (rec_earnings.element_type_id , 'Additional Taxable Pay _ Holiday Pay Earnings Adjust') ;
						FETCH csr_sub_class INTO l_percent_basis ;
						IF (csr_sub_class%FOUND)
						   THEN  l_basis_text := 'PERCENTAGE';
						END IF;
						CLOSE csr_sub_class ;

				  */

				  END IF;

				  /*
				  OPEN csr_sub_class (rec_earnings.element_type_id) ;
				  FETCH csr_sub_class INTO l_ele_class ,l_table_basis ,l_percent_basis ,l_holiday_basis ;
				  CLOSE csr_sub_class ;


				  l_basis_text := NULL ;

				  IF (l_table_basis = 1) THEN l_basis_text := 'TABLE';
				  ELSIF (l_percent_basis = 2) THEN l_basis_text := 'PERCENTAGE';
				  END IF;

				  l_holiday_text := NULL ;

				  IF (l_holiday_basis = 3) THEN l_holiday_text := 'Y';
				  END IF ;

				 */

				 /* still to incorporate solution for Basis for Holiday Pay */

				 -- l_holiday_text := NULL ;

				-- check if the element is basis for holiday pay

				/* moving on top to check for information elements whiich are basis for holiday pay :
				  element class : Information
				  sec class : Holiday Pay Base During Absence _ Information */
				/*
				 OPEN csr_hol_sub_class (rec_earnings.element_type_id) ;
				 FETCH csr_hol_sub_class INTO l_holiday_text ;
				 CLOSE csr_hol_sub_class ;
				*/

				  IF (l_basis_text IS NOT NULL) THEN
					l_basis_text := hr_general.decode_lookup('NO_REPORT_LABELS',l_basis_text);
				  END IF;

				  IF (l_holiday_text IS NOT NULL) THEN
					l_holiday_text := hr_general.decode_lookup('NO_REPORT_LABELS',l_holiday_text);
				  END IF;

				  -- fnd_file.put_line (fnd_file.LOG,'3: ' ||  rec_earnings.rep_name  ||','||  l_basis_text ||','||  l_holiday_text );

				BEGIN
				  -- check if the Element definition has already been archived
				  SELECT 1 INTO l_flag
				  FROM   pay_action_information
				  WHERE  action_context_id = p_payroll_action_id
				  AND    action_information_category = 'NO ELEMENT DEFINITION'
				  AND    action_context_type = 'PA'
				  AND    action_information2 = rec_earnings.element_type_id
				  AND    action_information3 = rec_earnings.input_value_id
				  AND    action_information5 = ele_class_table(l_index).ele_context ;

				  EXCEPTION WHEN NO_DATA_FOUND THEN
				      -- archive the element definitio as it has not been archived
				      pay_action_information_api.create_action_information (
					    p_action_information_id        => l_action_info_id
					   ,p_action_context_id            => p_payroll_action_id
					   ,p_action_context_type          => 'PA'
					   ,p_object_version_number        => l_ovn
					   ,p_effective_date               => p_effective_date
					   ,p_source_id                    => NULL
					   ,p_source_text                  => NULL
					   ,p_action_information_category  => 'NO ELEMENT DEFINITION'
					   ,p_action_information1          => p_pre_payact_id
					   ,p_action_information2          => rec_earnings.element_type_id
					   ,p_action_information3          => rec_earnings.input_value_id
					   ,p_action_information4          => rec_earnings.rep_name
					   ,p_action_information5          => ele_class_table(l_index).ele_context
					   ,p_action_information6          => rec_earnings.uom
					   ,p_action_information7          => ele_class_table(l_index).ele_context
					   ,p_action_information8          => l_prim_def_bal_id
					   ,p_action_information9          => 'PBAL'
					   ,p_action_information10         => l_holiday_text
					   ,p_action_information11         => l_basis_text
					   ,p_action_information12         => rec_earnings.ele_class );
				  WHEN OTHERS THEN
					NULL;
				END;

                         END IF; -- end if clssification check for 'Information'
		  END;
	  END LOOP;

   END LOOP;

 IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure ARCHIVE_ELEMENT_INFO',220);
 END IF;

    EXCEPTION WHEN OTHERS THEN
     g_err_num := SQLCODE;
     /*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_ELEMENT_INFO');*/

     IF g_debug THEN
 	 hr_utility.set_location('ORA_ERR: ' || g_err_num || 'ARCHIVE_ELEMENT_INFO',230);
     END IF;

 END ARCHIVE_ELEMENT_INFO;


------------------------------------ FUNCTION GET_DEFINED_BALANCE_ID --------------------------------------------------------------

 /* GET DEFINED BALANCE ID */

 FUNCTION GET_DEFINED_BALANCE_ID(p_user_name IN VARCHAR2) RETURN NUMBER
 IS

 /* Cursor to retrieve Defined Balance Id */

 CURSOR csr_def_bal_id(p_user_name VARCHAR2) IS
 SELECT  u.creator_id
 FROM    ff_user_entities  u,
 	ff_database_items d
 WHERE   d.user_name = p_user_name
 AND     u.user_entity_id = d.user_entity_id
 AND     (u.legislation_code = 'NO' )
 AND     (u.business_group_id IS NULL )
 AND     u.creator_type = 'B';

 l_defined_balance_id ff_user_entities.user_entity_id%TYPE;

 BEGIN

 IF g_debug THEN
 	hr_utility.set_location(' Entering Function GET_DEFINED_BALANCE_ID',240);
 END IF;

     OPEN csr_def_bal_id(p_user_name);
     FETCH csr_def_bal_id INTO l_defined_balance_id;
     CLOSE csr_def_bal_id;
     RETURN l_defined_balance_id;

 IF g_debug THEN
 	hr_utility.set_location(' Leaving Function GET_DEFINED_BALANCE_ID',250);
 END IF;

 END GET_DEFINED_BALANCE_ID;

--------------------------------------------------------------------------------------------------


 /* PAYMENT INFORMATION REGION */
 PROCEDURE ARCHIVE_PAYMENT_INFO(p_archive_assact_id IN NUMBER,
         p_prepay_assact_id  IN NUMBER,
         p_assignment_id     IN NUMBER,
         p_date_earned       IN DATE,
         p_effective_date    IN DATE)
 IS
 -------------
 /* Cursor to fetch ppm and opm ids to check which payment method to archive */
 CURSOR csr_chk(p_prepay_assact_id NUMBER) IS
 SELECT personal_payment_method_id ppm_id,
        org_payment_method_id opm_id
 FROM   pay_pre_payments
 WHERE  assignment_action_id = p_prepay_assact_id;

  ------------
 /* Cursor to check if bank details are attached with ppm */
 CURSOR csr_chk_bank(p_ppm_id NUMBER) IS
 SELECT ppm.external_account_id
 FROM   pay_personal_payment_methods_f ppm
 WHERE  ppm.personal_payment_method_id = p_ppm_id
 AND    p_date_earned BETWEEN ppm.effective_start_date  AND ppm.effective_end_date;

 -------------
 /* Cursor to retrieve Organization Payment Method Information */
 CURSOR csr_get_org_pay(p_prepay_assact_id NUMBER, opm_id NUMBER) IS
 SELECT pop.org_payment_method_id opm_id,
        pop.org_payment_method_name  opm_name,
        ppttl.payment_type_name pay_type,
        ppp.value value
 FROM   pay_org_payment_methods_f pop,
        pay_assignment_actions paa,
        pay_payment_types ppt,
        pay_payment_types_tl ppttl,
        pay_pre_payments ppp
 WHERE  paa.assignment_action_id = p_prepay_assact_id
 AND    ppt.payment_type_id = pop.payment_type_id
 AND    ppt.payment_type_id = ppttl.payment_type_id
 AND    ppttl.language      = userenv('LANG')
 AND    ppp.org_payment_method_id = pop.org_payment_method_id
 AND    pop.org_payment_method_id = opm_id
 AND    ppp.assignment_action_id = paa.assignment_action_id
 AND    p_date_earned BETWEEN pop.effective_start_date  AND pop.effective_end_date;

 -------------
 /* Cursor to retrieve Personal Payment Method Info*/
 CURSOR csr_get_pers_pay(p_prepay_assact_id NUMBER, ppm_id NUMBER) IS
 SELECT pea.segment1 bank_name,
        pea.segment2 branch,
        pea.segment3 acct_name,
	pea.segment4 acc_type,
	pea.segment5 acc_curr,
	pea.segment6 acct_num,
        ppm.org_payment_method_id opm_id,
        pop.external_account_id,
        pop.org_payment_method_name opm_name,
        ppm.personal_payment_method_id ppm_id,
        ppttl.payment_type_name pay_type,
        ppp.value value
 FROM   pay_external_accounts pea,
        pay_org_payment_methods_f pop,
        pay_personal_payment_methods_f ppm,
        pay_assignment_actions paa,
        pay_payment_types ppt,
        pay_payment_types_tl ppttl,
        pay_pre_payments ppp
 WHERE
 -- pea.id_flex_num=20  AND
	pea.external_account_id = NVL(ppm.external_account_id,pop.external_account_id)
 AND    paa.assignment_action_id = p_prepay_assact_id
 AND    paa.assignment_id = ppm.assignment_id
 AND    ppm.org_payment_method_id = pop.org_payment_method_id
 AND    ppm.personal_payment_method_id = ppm_id
 AND    ppt.payment_type_id = pop.payment_type_id
 AND    ppt.payment_type_id = ppttl.payment_type_id
 AND    ppttl.language      = userenv('LANG')
 AND    ppp.assignment_action_id = paa.assignment_action_id
 AND    ppp.personal_payment_method_id = ppm.personal_payment_method_id
 AND    p_date_earned BETWEEN pop.effective_start_date  AND pop.effective_end_date
 AND    p_date_earned BETWEEN ppm.effective_start_date  AND ppm.effective_end_date;
 -------------
 l_bank_reg_num		VARCHAR2(50);
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
 l_org			NUMBER;
 l_pers			VARCHAR2(40) := NULL;
 l_ext_acct		NUMBER;
 rec_chk		csr_chk%ROWTYPE;
 l_pay_value		VARCHAR2(50) := NULL;
 l_bank_name		VARCHAR2(240);
 l_acc_name		VARCHAR2(240);
 l_acc_type		VARCHAR2(240);
 l_acc_curr		VARCHAR2(240);

  ------------

 BEGIN

 IF g_debug THEN
 	hr_utility.set_location(' Entering Procedure ARCHIVE_PAYMENT_INFO',260);
 END IF;

 /*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 1');*/

 OPEN csr_chk(p_prepay_assact_id);
 LOOP
 FETCH csr_chk INTO rec_chk;
 EXIT WHEN csr_chk%NOTFOUND;

 IF rec_chk.ppm_id IS NOT NULL THEN
 	FOR rec_pers_pay IN csr_get_pers_pay(p_prepay_assact_id,rec_chk.ppm_id) LOOP

		OPEN csr_chk_bank(rec_chk.ppm_id);
		FETCH csr_chk_bank INTO l_ext_acct;
		CLOSE csr_chk_bank;

		l_pay_value := to_char (rec_pers_pay.value,g_format_mask);

		IF (l_ext_acct IS NOT NULL) THEN

			/*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 2');*/

			-- l_bank_reg_num := rec_pers_pay.bank_reg_num;
			-- l_bank_reg_num := rec_pers_pay.bank_reg_num || ' ' || hr_general.decode_lookup('HR_NO_BANK_REGISTRATION',rec_pers_pay.bank_reg_num);

			l_bank_name := hr_general.decode_lookup('HR_NO_BANK',rec_pers_pay.bank_name);
			l_acc_name  := hr_general.decode_lookup('HR_NO_ACCOUNT_NAME',rec_pers_pay.acct_name);
			l_acc_type  := hr_general.decode_lookup('HR_NO_ACCOUNT_TYPE',rec_pers_pay.acc_type);
			l_acc_curr  := rec_pers_pay.acc_curr ;


			pay_action_information_api.create_action_information (
				  p_action_information_id        => l_action_info_id
				 ,p_action_context_id            => p_archive_assact_id
				 ,p_action_context_type          => 'AAP'
				 ,p_object_version_number        => l_ovn
				 ,p_effective_date               => p_effective_date
				 ,p_source_id                    => NULL
				 ,p_source_text                  => NULL
				 ,p_action_information_category  => 'EMPLOYEE NET PAY DISTRIBUTION'
				 ,p_action_information1          => rec_pers_pay.opm_id -- NULL
				 ,p_action_information2          => rec_pers_pay.ppm_id
				 ,p_action_information5          => l_bank_name
				 ,p_action_information6          => rec_pers_pay.branch
				 ,p_action_information7          => l_acc_name
				 ,p_action_information8          => l_acc_type
				 ,p_action_information9          => l_acc_curr
				 ,p_action_information10         => rec_pers_pay.acct_num
				 ,p_action_information11         => NULL
				 ,p_action_information12         => NULL
				 ,p_action_information13         => NULL
				 ,p_action_information14         => NULL
				 ,p_action_information15         => NULL
				 ,p_action_information16         => fnd_number.number_to_canonical(rec_pers_pay.value) --l_pay_value
				 ,p_action_information17         => NULL
				 ,p_action_information18         => rec_pers_pay.opm_name -- rec_pers_pay.pay_type
				 ,p_assignment_id                => p_assignment_id);
		ELSE

		/*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 3');*/

		   pay_action_information_api.create_action_information (
			  p_action_information_id        => l_action_info_id
			 ,p_action_context_id            => p_archive_assact_id
			 ,p_action_context_type          => 'AAP'
			 ,p_object_version_number        => l_ovn
			 ,p_effective_date               => p_effective_date
			 ,p_source_id                    => NULL
			 ,p_source_text                  => NULL
			 ,p_action_information_category  => 'EMPLOYEE NET PAY DISTRIBUTION'
			 ,p_action_information1          => rec_pers_pay.opm_id
			 ,p_action_information2          => rec_pers_pay.ppm_id
			 ,p_action_information5          => NULL
			 ,p_action_information6          => NULL
			 ,p_action_information7          => NULL
			 ,p_action_information8          => NULL
			 ,p_action_information9          => NULL
			 ,p_action_information10         => NULL
			 ,p_action_information11         => NULL
			 ,p_action_information12         => NULL
			 ,p_action_information13         => NULL
			 ,p_action_information14         => NULL
			 ,p_action_information15         => NULL
			 ,p_action_information16         => fnd_number.number_to_canonical(rec_pers_pay.value) --l_pay_value
			 ,p_action_information17         => NULL
			 ,p_action_information18         => rec_pers_pay.opm_name -- rec_pers_pay.pay_type
			 ,p_assignment_id                => p_assignment_id);
		END IF;
 	END LOOP;
 	/*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 4');*/

  END IF;

 IF (rec_chk.opm_id IS NOT NULL AND rec_chk.ppm_id IS NULL) THEN

 /*fnd_file.put_line(fnd_file.log,'In ARCHIVE_PAYMENT_INFO 5');*/

	FOR rec_org_pay IN csr_get_org_pay(p_prepay_assact_id,rec_chk.opm_id) LOOP

		l_pay_value := to_char (rec_org_pay.value,g_format_mask);

		pay_action_information_api.create_action_information (
		    p_action_information_id        => l_action_info_id
		   ,p_action_context_id            => p_archive_assact_id
		   ,p_action_context_type          => 'AAP'
		   ,p_object_version_number        => l_ovn
		   ,p_effective_date               => p_effective_date
		   ,p_source_id                    => NULL
		   ,p_source_text                  => NULL
		   ,p_action_information_category  => 'EMPLOYEE NET PAY DISTRIBUTION'
		   ,p_action_information1          => rec_org_pay.opm_id
		   ,p_action_information2          => NULL
		   ,p_action_information5          => NULL
		   ,p_action_information6          => NULL
		   ,p_action_information7          => NULL
		   ,p_action_information8          => NULL
		   ,p_action_information9          => NULL
		   ,p_action_information10         => NULL
		   ,p_action_information11         => NULL
		   ,p_action_information12         => NULL
		   ,p_action_information13         => NULL
		   ,p_action_information14         => NULL
		   ,p_action_information15         => NULL
		   ,p_action_information16         => fnd_number.number_to_canonical(rec_org_pay.value) --l_pay_value
		   ,p_action_information17         => NULL
		   ,p_action_information18         => rec_org_pay.opm_name -- rec_org_pay.pay_type
		   ,p_assignment_id                => p_assignment_id);
 	END LOOP;

 END IF;

 END LOOP;
 CLOSE csr_chk;

 IF g_debug THEN
 	hr_utility.set_location(' Leaving Procedure ARCHIVE_PAYMENT_INFO',270);
 END IF;

     EXCEPTION WHEN OTHERS THEN
        g_err_num := SQLCODE;

	/*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_PAYMENT_INFO');*/

	IF g_debug THEN
 		hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_PAYMENT_INFO',280);
 	END IF;

 END ARCHIVE_PAYMENT_INFO;
----------------------------------------- PROCEDURE ARCHIVE_ACCRUAL_PLAN ---------------------------------------------------------

 /* ACCRUALS REGION */

/*   PROCEDURE ARCHIVE_ACCRUAL_PLAN (    p_assignment_id        IN NUMBER
  	     ,p_date_earned          IN DATE
  	     ,p_effective_date       IN DATE
  	     ,p_archive_assact_id    IN NUMBER
  	     ,p_run_assignment_action_id IN NUMBER
  	     ,p_period_end_date      IN DATE
  	     ,p_period_start_date    IN DATE
  	    )
   IS
   --
     -- Cursor to get the Leave Balance Details .
     CURSOR  csr_leave_balance
     IS
     --
       SELECT  pap.accrual_plan_name
 	     ,hr_general_utilities.get_lookup_meaning('US_PTO_ACCRUAL',pap.accrual_category)
 	     ,pap.accrual_units_of_measure
 	     ,ppa.payroll_id
 	     ,pap.business_group_id
 	     ,pap.accrual_plan_id
       FROM    pay_accrual_plans             pap
 	     ,pay_element_types_f           pet
 	     ,pay_element_links_f           pel
 	     ,pay_element_entries_f         pee
 	     ,pay_assignment_actions        paa
 	     ,pay_payroll_actions           ppa
       WHERE   pet.element_type_id         = pap.accrual_plan_element_type_id
       AND     pel.element_type_id         = pet.element_type_id
       AND     pee.element_link_id         = pel.element_link_id
       AND     paa.assignment_id           = pee.assignment_id
       AND     ppa.payroll_action_id       = paa.payroll_action_id
       AND     ppa.action_type            IN ('R','Q')
       AND     ppa.action_status           = 'C'
       AND     ppa.date_earned       BETWEEN pet.effective_start_date
  	    AND     pet.effective_end_date
       AND     ppa.date_earned       BETWEEN pel.effective_start_date
  	    AND     pel.effective_end_date
       AND     ppa.date_earned       BETWEEN pee.effective_start_date
  	    AND     pee.effective_end_date
       AND     paa.assignment_id           = p_assignment_id
       AND     paa.assignment_action_id    = p_run_assignment_action_id;
     --
     l_action_info_id             NUMBER;
     l_accrual_plan_id            pay_accrual_plans.accrual_plan_id%type;
     l_accrual_plan_name          pay_accrual_plans.accrual_plan_name%type;
     l_accrual_category           pay_accrual_plans.accrual_category%type;
     l_accrual_uom                pay_accrual_plans.accrual_units_of_measure%type;
     l_payroll_id                 pay_all_payrolls_f.payroll_id%type;
     l_business_group_id          NUMBER;
     l_effective_date             DATE;
     l_annual_leave_balance       NUMBER;
     l_ovn                        NUMBER;
     l_leave_taken                NUMBER;
     l_start_date                 DATE;
     l_end_date                   DATE;
     l_accrual_end_date           DATE;
     l_accrual                    NUMBER;
     l_total_leave_taken          NUMBER;
     l_procedure                  VARCHAR2(100) := g_package || '.archive_accrual_details';
   --
   BEGIN
   --
 IF g_debug THEN
 	hr_utility.set_location(' Entering Procedure ARCHIVE_ACCRUAL_PLAN',290);
 END IF;
     OPEN  csr_leave_balance;
     FETCH csr_leave_balance INTO
 	  l_accrual_plan_name
 	 ,l_accrual_category
 	 ,l_accrual_uom
 	 ,l_payroll_id
 	 ,l_business_group_id
 	 ,l_accrual_plan_id;
     IF csr_leave_balance%FOUND THEN
     --
       -- Call to get annual leave balance
       per_accrual_calc_functions.get_net_accrual
 	(
 	  p_assignment_id     => p_assignment_id          --  number  in
 	 ,p_plan_id           => l_accrual_plan_id        --  number  in
 	 ,p_payroll_id        => l_payroll_id             --  number  in
 	 ,p_business_group_id => l_business_group_id      --  number  in
 	 ,p_calculation_date  => p_date_earned            --  date    in
 	 ,p_start_date        => l_start_date             --  date    out
 	 ,p_end_date          => l_end_date               --  date    out
 	 ,p_accrual_end_date  => l_accrual_end_date       --  date    out
 	 ,p_accrual           => l_accrual                --  number  out
 	 ,p_net_entitlement   => l_annual_leave_balance   --  number  out
 	);
       IF l_annual_leave_balance IS NULL THEN
       --
 	l_annual_leave_balance := 0;
       --
       END IF;
       l_leave_taken   :=  per_accrual_calc_functions.get_absence
      (
        p_assignment_id
       ,l_accrual_plan_id
       ,p_period_end_date
       ,p_period_start_date
      );
       l_ovn :=1;
       IF l_accrual_plan_name IS NOT NULL THEN
       --
 	pay_action_information_api.create_action_information (
    p_action_information_id        => l_action_info_id
   ,p_action_context_id            => p_archive_assact_id
   ,p_action_context_type          => 'AAP'
   ,p_object_version_number        => l_ovn
   ,p_effective_date               => p_effective_date
   ,p_source_id                    => NULL
   ,p_source_text                  => NULL
   ,p_action_information_category  => 'EMPLOYEE ACCRUALS'
   ,p_action_information4          => l_accrual_plan_name
   ,p_action_information5          => fnd_number.number_to_canonical(l_leave_taken)
   ,p_action_information6          => fnd_number.number_to_canonical(l_annual_leave_balance)
   ,p_assignment_id                => p_assignment_id);
       --
       END IF;
       --
     --
     END IF;
     --
     CLOSE csr_leave_balance;
 IF g_debug THEN
 		hr_utility.set_location(' Leaving Procedure ARCHIVE_ACCRUAL_PLAN',300);
 END IF;
   --
   EXCEPTION
     WHEN OTHERS THEN
       IF csr_leave_balance%ISOPEN THEN
       --
 	CLOSE csr_leave_balance;
       --
       END IF;
       --
       g_err_num := SQLCODE;
       --fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_ACCRUAL_PLAN');
 	IF g_debug THEN
 		hr_utility.set_location('ORA_ERR: ' || g_err_num || ' In ARCHIVE_ACCRUAL_PLAN',310);
 	END IF;
       RAISE;
   END ARCHIVE_ACCRUAL_PLAN;*/

----------------------------------- PROCEDURE ARCHIVE_ADD_ELEMENT ---------------------------------------------------------------

 /* ADDITIONAL ELEMENTS REGION */

 PROCEDURE ARCHIVE_ADD_ELEMENT(p_archive_assact_id     IN NUMBER,
        p_assignment_action_id  IN NUMBER,
        p_assignment_id         IN NUMBER,
        p_payroll_action_id     IN NUMBER,
        p_date_earned           IN DATE,
        p_effective_date        IN DATE,
        p_pre_payact_id         IN NUMBER,
        p_archive_flag          IN VARCHAR2) IS

------------------------------
 /* Cursor to retrieve Additional Element Information */

 /*
 CURSOR csr_get_element(p_bus_grp_id NUMBER) IS
 SELECT hoi.org_information2 element_type_id
       ,hoi.org_information3 input_value_id
       ,hoi.org_information7 element_narrative
       ,pec.classification_name
       ,piv.uom
 FROM   hr_organization_information hoi
       ,pay_element_classifications pec
       ,pay_element_types_f  pet
       ,pay_input_values_f piv
 WHERE  hoi.organization_id = p_bus_grp_id
 AND    hoi.org_information_context = 'Business Group:Payslip Info'
 AND    hoi.org_information1 = 'ELEMENT'
 AND    hoi.org_information2 = pet.element_type_id
 AND    pec.classification_id = pet.classification_id
 AND    piv.input_value_id = hoi.org_information3
 AND    p_date_earned BETWEEN piv.effective_start_date AND piv.effective_end_date;

*/

/*
CURSOR csr_get_add_elements (p_payroll_action_id  NUMBER ) IS
SELECT   action_information2  element_type_id
	,action_information3  input_value_id
	,action_information4  element_narrative
	,action_information5  element_context
	,action_information6  uom
	,action_information8  prim_def_bal_id
	,action_information12 ele_class
FROM pay_action_information
WHERE action_context_id = p_payroll_action_id
AND    action_information_category = 'NO ELEMENT DEFINITION'
AND    action_context_type = 'PA'
AND    action_information5 = 'F' ;
*/

CURSOR csr_get_add_elements (p_payroll_action_id  NUMBER ) IS
SELECT   action_information2  element_type_id
	,action_information3  input_value_id
	,action_information4  element_narrative
	,action_information5  element_context
	,action_information6  uom
	,action_information8  prim_def_bal_id
	,action_information12 ele_class
	,action_information13 lookup_type
	,action_information14 value_set_id
FROM pay_action_information
WHERE action_context_id = p_payroll_action_id
AND    action_information_category = 'NO ELEMENT DEFINITION'
AND    action_context_type = 'PA'
AND    action_information5 = 'F' ;


----------------------------------------------------------

/* cursor to get he tax unit id (Legal Employer) from assignment action id */

CURSOR csr_get_le_org_id (p_assignment_action_id   NUMBER) IS
SELECT tax_unit_id
FROM pay_assignment_actions
WHERE assignment_action_id = p_assignment_action_id ;

--------------------------------------------------------

/* cursor to get the element code */

/*
CURSOR csr_ele_code (p_ele_type_id  NUMBER , p_le_org_id   NUMBER ) IS
select eei_information1
from   pay_element_type_extra_info
where  element_type_id = p_ele_type_id
and    ( eei_information2 = p_le_org_id OR eei_information2 is null )
and    information_type = 'NO_ELEMENT_CODES'
and    eei_information_category = 'NO_ELEMENT_CODES'
and    rownum = 1
order by eei_information2 , element_type_extra_info_id ;
*/

-- modifying the above cursor

 cursor csr_ele_code(p_ele_type_id  NUMBER , p_leg_emp_id NUMBER ) is
	select nvl((select eei_information1 from pay_element_type_extra_info petei
	where petei.information_type='NO_ELEMENT_CODES'
	and element_type_id = p_ele_type_id
	and petei.eei_information2 = p_leg_emp_id
	and rownum=1),
	(select eei_information1 from pay_element_type_extra_info petei
	where petei.information_type='NO_ELEMENT_CODES'
	and element_type_id = p_ele_type_id
	and eei_information2 is null
	and rownum=1)) from dual;

--------------------------------------------------------

/* cursor to get the further element entry info for payslip information */

CURSOR csr_payslip_info (p_ele_entry_id   NUMBER) IS
SELECT ENTRY_INFORMATION1
FROM pay_element_entries_f
where ELEMENT_ENTRY_ID = p_ele_entry_id ;

-------------------------------
 /* Cursor to retrieve run result value of Additional Elements */
 CURSOR csr_result_value(p_iv_id NUMBER
 		       ,p_ele_type_id NUMBER
 		       ,p_assignment_action_id NUMBER) IS
 SELECT rrv.result_value  val
       ,rr.element_entry_id	ele_entry_id
 FROM   pay_run_result_values rrv
       ,pay_run_results rr
       ,pay_assignment_actions paa
       ,pay_payroll_actions ppa
 WHERE  rrv.input_value_id = p_iv_id
 AND    rr.element_type_id = p_ele_type_id
 AND    rr.run_result_id = rrv.run_result_id
 AND    rr.assignment_action_id = paa.assignment_action_id
 AND    paa.assignment_action_id = p_assignment_action_id
 AND    ppa.payroll_action_id = paa.payroll_action_id
 AND    ppa.action_type IN ('Q','R')
 AND    rrv.result_value IS NOT NULL;
------------------------------

-- rec_get_element	csr_get_element%ROWTYPE;
 rec_get_add_element	csr_get_add_elements%ROWTYPE;

 l_result_value		pay_run_result_values.result_value%TYPE := 0;
 l_balance_value	NUMBER := 0;
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
 l_element_context	VARCHAR2(10);
 l_index		NUMBER := 0;
 l_formatted_value	VARCHAR2(50) := NULL;
 l_flag			NUMBER := 0;
 l_le_org_id		NUMBER;
 l_ele_code		VARCHAR2(240) := NULL ;
 l_ele_entry_id		NUMBER;
 l_payslip_info		varchar2(240);
 l_archive		VARCHAR2(2);
 l_arhive_prim_bal	VARCHAR2(5);
------------------------------

 BEGIN

 IF g_debug THEN
 	hr_utility.set_location(' Entering Procedure ARCHIVE_ADD_ELEMENT',320);
 END IF;

 IF p_archive_flag = 'N' THEN
 ---------------------------------------------------
 --Check if global table has already been populated
 ---------------------------------------------------
     IF g_element_table.count = 0 THEN

	     /*
	     OPEN csr_get_element(g_business_group_id);
	     LOOP
	     FETCH csr_get_element INTO rec_get_element;
	     EXIT WHEN csr_get_element%NOTFOUND;

		l_element_context := 'F'; --Additional Element Context
		SETUP_ELEMENT_DEFINITIONS(p_classification_name => rec_get_element.classification_name
					 ,p_element_name        => rec_get_element.element_narrative
					 ,p_element_type_id     => rec_get_element.element_type_id
					 ,p_input_value_id      => rec_get_element.input_value_id
					 ,p_element_type        => l_element_context
					 ,p_uom                 => rec_get_element.uom
					 ,p_archive_flag        => p_archive_flag);

	      END LOOP;
	      CLOSE csr_get_element;
	      */

	     OPEN csr_get_add_elements (p_payroll_action_id);
	     LOOP
	     FETCH csr_get_add_elements INTO rec_get_add_element;
	     EXIT WHEN csr_get_add_elements%NOTFOUND;

		l_element_context := 'F'; --Additional Element Context
		SETUP_ELEMENT_DEFINITIONS(p_classification_name => rec_get_add_element.ele_class
					 ,p_element_name        => rec_get_add_element.element_narrative
					 ,p_element_type_id     => rec_get_add_element.element_type_id
					 ,p_input_value_id      => rec_get_add_element.input_value_id
					 ,p_element_type        => l_element_context
					 ,p_uom                 => rec_get_add_element.uom
					 ,p_archive_flag        => p_archive_flag
					 ,p_prim_bal_def_bal_id => rec_get_add_element.prim_def_bal_id
					 ,p_lookup_type		=> rec_get_add_element.lookup_type
					 ,p_value_set_id	=> rec_get_add_element.value_set_id );

	      END LOOP;
	      CLOSE csr_get_add_elements;


      END IF;

 ELSIF p_archive_flag = 'Y' AND g_element_table.count > 0 THEN

   FOR l_index IN g_element_table.first.. g_element_table.last LOOP
	   l_result_value := NULL;

	   BEGIN

		    l_balance_value := NULL ;

		    IF (g_element_table(l_index).prim_bal_def_bal_id IS NOT NULL) THEN

			    -- get the primary balance ytd value for the element
			    l_balance_value := pay_balance_pkg.get_value(g_element_table(l_index).prim_bal_def_bal_id , p_assignment_action_id );

		    END IF;

		    /* get the element run result value */
		    OPEN csr_result_value(g_element_table(l_index).input_value_id
					   ,g_element_table(l_index).element_type_id
					   ,p_assignment_action_id);
		    LOOP
		    FETCH csr_result_value INTO l_result_value , l_ele_entry_id ;

		    IF (csr_result_value%NOTFOUND) AND
		       (csr_result_value%ROWCOUNT < 1) AND
		       (g_element_table(l_index).prim_bal_def_bal_id IS NOT NULL) AND
		       (l_balance_value <> 0)  THEN

				l_arhive_prim_bal := 'Y' ;

		    END IF ;

		    EXIT WHEN csr_result_value%NOTFOUND;

		    IF (csr_result_value%ROWCOUNT > 1) THEN
			    l_balance_value := NULL ;
		    END IF;

		    -- fnd_file.put_line(fnd_file.log,'------ before : l_result_value = ' || l_result_value);

		    -- check if a lookup was attached to the input value and fetch the meaning

		    IF (l_result_value is not null) AND (g_element_table(l_index).lookup_type is not null) THEN

			l_result_value := hr_general.decode_lookup(g_element_table(l_index).lookup_type , l_result_value);

		    ELSIF (l_result_value is not null) AND (g_element_table(l_index).value_set_id is not null) THEN

			l_result_value := pay_input_values_pkg.decode_vset_value( g_element_table(l_index).value_set_id ,l_result_value );

		    END IF ;

		    -- fnd_file.put_line(fnd_file.log,'after : l_result_value = ' || l_result_value);

		    -- l_balance_value := NULL ;

		    -- l_balance_value := pay_balance_pkg.get_value(g_element_table(l_index).prim_bal_def_bal_id , p_assignment_action_id );

		    -- fnd_file.put_line(fnd_file.log,'l_result_value = ' || l_result_value);
		    -- fnd_file.put_line(fnd_file.log,'l_ele_entry_id = ' || l_ele_entry_id);


		    -- modifying the below condition to get the ytd value for primary balance
		    -- only once in case of multiple element entries

		    -- IF (g_element_table(l_index).prim_bal_def_bal_id IS NOT NULL) THEN

		    /*
		    IF (g_element_table(l_index).prim_bal_def_bal_id IS NOT NULL) and (csr_result_value%ROWCOUNT = 1) THEN

			    -- get the primary balance ytd value for the element
			    l_balance_value := pay_balance_pkg.get_value(g_element_table(l_index).prim_bal_def_bal_id , p_assignment_action_id );

		    END IF;
		    */

		    -- fnd_file.put_line(fnd_file.log,'csr_rec.prim_def_bal_id = ' || g_element_table(l_index).prim_bal_def_bal_id);
		    -- fnd_file.put_line(fnd_file.log,'l_balance_value = ' || l_balance_value);

		    /* get the legal employer */
		    OPEN csr_get_le_org_id (p_assignment_action_id );
		    FETCH csr_get_le_org_id INTO l_le_org_id ;
		    CLOSE csr_get_le_org_id ;

		    -- fnd_file.put_line(fnd_file.log,'l_le_org_id = ' || l_le_org_id);

		    /* get the element code from the legal employer */
		    OPEN csr_ele_code (g_element_table(l_index).element_type_id , l_le_org_id );
		    FETCH csr_ele_code INTO l_ele_code ;
		    CLOSE csr_ele_code ;

 		    /*
		    IF (l_ele_code IS NOT NULL) THEN
		    	l_ele_code := hr_general.decode_lookup('NO_ELEMENT_CODES',l_ele_code);
		    END IF;
		    */

		    -- fnd_file.put_line(fnd_file.log,'l_ele_code = ' || l_ele_code);

		    /* get the payslip information */
		    l_payslip_info := NULL ;

		    OPEN csr_payslip_info (l_ele_entry_id );
		    FETCH csr_payslip_info INTO l_payslip_info ;
		    CLOSE csr_payslip_info ;

		    -- fnd_file.put_line(fnd_file.log,'l_payslip_info = ' || l_payslip_info);

    		    IF    (l_result_value is not null) THEN l_archive := 'Y';
		    -- ELSIF (g_element_table(l_index).prim_bal_def_bal_id IS NOT NULL) AND ( (l_balance_value <> 0) OR (l_balance_value IS NOT NULL) ) THEN l_archive := 'Y';
		    ELSE  l_archive := 'N';
		    END IF;


		    IF  (l_archive = 'Y') THEN
		         -- IF  l_result_value is not null THEN

			 -- fnd_file.put_line(fnd_file.log,'l_result_value is not null ');

				pay_action_information_api.create_action_information (
				    p_action_information_id        => l_action_info_id
				   ,p_action_context_id            => p_archive_assact_id
				   ,p_action_context_type          => 'AAP'
				   ,p_object_version_number        => l_ovn
				   ,p_effective_date               => p_effective_date
				   ,p_source_id                    => NULL
				   ,p_source_text                  => NULL
				   ,p_action_information_category  => 'NO ELEMENT INFO'
				   ,p_action_information1          => g_element_table(l_index).element_type_id
				   ,p_action_information2          => g_element_table(l_index).input_value_id
				   ,p_action_information3          => g_element_table(l_index).element_type
				   ,p_action_information4          => l_result_value --l_formatted_value
				   ,p_action_information9          => 'Additional Element'
				   ,p_action_information10         => g_element_table(l_index).prim_bal_def_bal_id
				   ,p_action_information11         => 'PBAL'
				   ,p_action_information12         => l_balance_value
				   ,p_action_information13         => l_ele_code
				   ,p_action_information14         => l_payslip_info
				   ,p_assignment_id                => p_assignment_id);
		     END IF;

		    END LOOP;
		    CLOSE csr_result_value;

		    -- archive results if run result was NULL but primary balance value is not null

		   IF (l_arhive_prim_bal = 'Y') THEN

			-- though the run result is NULL, the ytd balance has a value
			-- so we will archive this result

			l_result_value := NULL ;
			l_payslip_info := NULL ;

			-- fnd_file.put_line(fnd_file.log,'LOC 5 => p_assignment_action_id , l_element_name = ' || p_assignment_action_id ||' , '||l_element_name);

				pay_action_information_api.create_action_information (
				    p_action_information_id        => l_action_info_id
				   ,p_action_context_id            => p_archive_assact_id
				   ,p_action_context_type          => 'AAP'
				   ,p_object_version_number        => l_ovn
				   ,p_effective_date               => p_effective_date
				   ,p_source_id                    => NULL
				   ,p_source_text                  => NULL
				   ,p_action_information_category  => 'NO ELEMENT INFO'
				   ,p_action_information1          => g_element_table(l_index).element_type_id
				   ,p_action_information2          => g_element_table(l_index).input_value_id
				   ,p_action_information3          => g_element_table(l_index).element_type
				   ,p_action_information4          => l_result_value --l_formatted_value
				   ,p_action_information9          => 'Additional Element'
				   ,p_action_information10         => g_element_table(l_index).prim_bal_def_bal_id
				   ,p_action_information11         => 'PBAL'
				   ,p_action_information12         => l_balance_value
				   ,p_action_information13         => l_ele_code
				   ,p_action_information14         => l_payslip_info
				   ,p_assignment_id                => p_assignment_id);

		   END IF ;

		     EXCEPTION WHEN OTHERS THEN
			g_err_num := SQLCODE;
			/*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_ADD_ELEMENT');*/

			IF g_debug THEN
				hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_ADD_ELEMENT',330);
			END IF;
	       END;
    END LOOP;

END IF;

 IF g_debug THEN
 	hr_utility.set_location(' Leaving Procedure ARCHIVE_ADD_ELEMENT',340);
 END IF;

 END ARCHIVE_ADD_ELEMENT;

 ---------------------------------- PROCEDURE ARCHIVE_OTH_BALANCE ----------------------------------------------------------------

/* OTHER BALANCES REGION */

 PROCEDURE ARCHIVE_OTH_BALANCE (p_archive_assact_id     IN NUMBER,
         p_assignment_action_id  IN NUMBER,
         p_assignment_id         IN NUMBER,
         p_payroll_action_id     IN NUMBER,
         p_record_count          IN NUMBER,
         p_pre_payact_id         IN NUMBER,
         p_effective_date        IN DATE,
         p_date_earned           IN DATE,
         p_archive_flag          IN VARCHAR2) IS

 ------------------
 /* Cursor to retrieve Other Balances Information */
 CURSOR csr_get_balance(p_bus_grp_id NUMBER) IS
 SELECT org_information4 balance_type_id
       ,org_information5 balance_dim_id
       ,org_information7 narrative
 FROM   hr_organization_information
 WHERE  organization_id = p_bus_grp_id
 AND    org_information_context = 'Business Group:Payslip Info'
 AND    org_information1 = 'BALANCE';

 -----------------
 /* Cursor to retrieve Tax Unit Id for setting context */
 CURSOR csr_tax_unit (p_run_assact_id NUMBER) IS
 SELECT paa.tax_unit_id
 FROM   pay_assignment_actions paa
 WHERE  paa.assignment_action_id = p_run_assact_id;
 -----------------
 /* Cursor to fetch defined balance id */
 CURSOR csr_def_balance(bal_type_id NUMBER, bal_dim_id NUMBER) IS
 SELECT defined_balance_id
 FROM   pay_defined_balances
 WHERE  balance_type_id = bal_type_id
 AND    balance_dimension_id = bal_dim_id;
 ----------------
 rec_get_balance	csr_get_balance%ROWTYPE;
 l_balance_value	NUMBER := 0;
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
 l_index		NUMBER;
 l_tu_id		NUMBER;
 l_defined_balance_id	NUMBER :=0;
 l_formatted_value	VARCHAR2(50) := NULL;
 l_flag			NUMBER := 0;

 ---------------

 BEGIN

 IF g_debug THEN
 		hr_utility.set_location(' Entering Procedure ARCHIVE_OTH_BALANCE',350);
 END IF;

  -- fnd_file.put_line(fnd_file.log,'In ARCHIVE_OTH_BALANCE 0');
 /*fnd_file.put_line(fnd_file.log,'Entering In ARCHIVE_OTH_BALANCE global');*/

 IF p_archive_flag = 'N' THEN
 ---------------------------------------------------
 --Check if global table has already been populated
 ---------------------------------------------------
   IF g_user_balance_table.count = 0 THEN
	   OPEN csr_get_balance(g_business_group_id);
	   LOOP
	     FETCH csr_get_balance INTO rec_get_balance;
	     EXIT WHEN csr_get_balance%NOTFOUND;

		OPEN csr_def_balance(rec_get_balance.balance_type_id,rec_get_balance.balance_dim_id);
		FETCH csr_def_balance INTO l_defined_balance_id;
		CLOSE csr_def_balance;

		PAY_NO_PAYSLIP_ARCHIVE.SETUP_BALANCE_DEFINITIONS
				(p_balance_name         => rec_get_balance.narrative
				,p_defined_balance_id   => l_defined_balance_id
			        ,p_balance_type_id      => rec_get_balance.balance_type_id);
	   END LOOP;
	   CLOSE csr_get_balance;
    END IF;

	 ---------------------------------------------------
	 -- For Tax Card details ,
	 -- Check if global table has already been populated
	 -- if not then populate the values
	 ---------------------------------------------------
   IF g_tax_card_tab.count = 0 THEN

		g_tax_card_tab(1).inp_val_name := 'Method of Receipt';
		g_tax_card_tab(2).inp_val_name := 'Tax Municipality';
		g_tax_card_tab(3).inp_val_name := 'Tax Card Type';
		g_tax_card_tab(4).inp_val_name := 'Tax Percentage';
		g_tax_card_tab(5).inp_val_name := 'Tax Table Number';
		g_tax_card_tab(6).inp_val_name := 'Tax Table Type';
		g_tax_card_tab(7).inp_val_name := 'Tax Free Threshold';
		g_tax_card_tab(8).inp_val_name := 'Registration Date';
		g_tax_card_tab(9).inp_val_name := 'Date Returned';
		--g_tax_card_tab(10).inp_val_name := 'Date Returned';

   END IF;

	 ---------------------------------------------------
	 -- For Mandatory Balance Details ,
	 -- Check if global table has already been populated
	 -- if not hen populate the values
	 ---------------------------------------------------

   IF g_bal_val.count = 0 THEN

	g_bal_val(1).bal_name := 'TOTAL_PAY_ASG_PTD';				-- Net salary , period
	g_bal_val(2).bal_name := 'TOTAL_PAY_ASG_YTD';				-- Net salary , ytd
	g_bal_val(3).bal_name := 'TAX_ASG_PTD';					-- Withholding tax , period
	g_bal_val(4).bal_name := 'TAX_ASG_YTD';					-- Withholding tax , ytd
	g_bal_val(5).bal_name := 'TAX_TABLE_DEDUCTION_BASIS_ASG_PTD';		-- for Tax Deduction Basis , period
	g_bal_val(6).bal_name := 'TAX_TABLE_DEDUCTION_BASIS_ASG_YTD';		-- for Tax Deduction Basis , ytd
	g_bal_val(7).bal_name := 'TAX_PERCENTAGE_DEDUCTION_BASIS_ASG_PTD';	-- for Tax Deduction Basis , period
	g_bal_val(8).bal_name := 'TAX_PERCENTAGE_DEDUCTION_BASIS_ASG_YTD';	-- for Tax Deduction Basis , ytd

	g_bal_val(9).bal_name := 'TAX_TABLE_DEDUCTION_ASG_PTD';			-- Table Based Tax Period
	g_bal_val(10).bal_name := 'TAX_TABLE_DEDUCTION_ASG_YTD';		-- Table Based Tax Ytd
	g_bal_val(11).bal_name := 'TAX_PERCENTAGE_DEDUCTION_ASG_PTD';		-- Percentage Based Tax Period
	g_bal_val(12).bal_name := 'TAX_PERCENTAGE_DEDUCTION_ASG_YTD';		-- Percentage Based Tax Ytd

	-- g_bal_val(13).bal_name := 'SEAMAN_ASG_PTD';				-- Seaman Deduction Basis Period
	-- g_bal_val(14).bal_name := 'SEAMAN_ASG_YTD';				-- Seaman Deduction Basis Ytd


	-- g_bal_val(15).bal_name := '' ; -- to be used for Holiday pay, due this year
	-- g_bal_val(16).bal_name := '' ; -- to be used for Accrued basis for holiday pay

	g_bal_val(13).bal_name := 'HOLIDAY_PAY_REMAINING_ASG_YTD' ;		-- for Holiday pay, due this year
	g_bal_val(14).bal_name := 'HOLIDAY_PAY_OVER_60_REMAINING_ASG_YTD' ;	-- Holiday pay, due this year
	g_bal_val(15).bal_name := 'HOLIDAY_PAY_BASE_ASG_PTD' ;			-- for basis for holiday pay
	g_bal_val(16).bal_name := 'HOLIDAY_PAY_BASE_ASG_YTD' ;			-- for basis for holiday pay


  END IF;

 ELSIF p_archive_flag = 'Y' THEN

	 OPEN csr_tax_unit(p_assignment_action_id);
	 FETCH csr_tax_unit INTO l_tu_id;
	 CLOSE csr_tax_unit;

	 PAY_BALANCE_PKG.SET_CONTEXT('TAX_UNIT_ID',l_tu_id);
	 PAY_BALANCE_PKG.SET_CONTEXT('DATE_EARNED',fnd_date.date_to_canonical(p_date_earned));

	     IF g_user_balance_table.count > 0 THEN
		     --  fnd_file.put_line(fnd_file.log,'In ARCHIVE_OTH_BALANCE 1');

		     FOR l_index IN g_user_balance_table.first.. g_user_balance_table.last LOOP

			     l_balance_value := pay_balance_pkg.get_value(g_user_balance_table(l_index).defined_balance_id,p_assignment_action_id);

			     IF l_balance_value > 0 THEN
				     --  fnd_file.put_line(fnd_file.log,'In ARCHIVE_OTH_BALANCE 2 :' || l_balance_value);
				     pay_action_information_api.create_action_information (
					    p_action_information_id        => l_action_info_id
					   ,p_action_context_id            => p_archive_assact_id
					   ,p_action_context_type          => 'AAP'
					   ,p_object_version_number        => l_ovn
					   ,p_effective_date               => p_effective_date
					   ,p_source_id                    => NULL
					   ,p_source_text                  => NULL
					   ,p_action_information_category  => 'EMEA BALANCES'
					   ,p_action_information1          => g_user_balance_table(l_index).defined_balance_id
					   ,p_action_information2          => 'OBAL'  --Other Balances Context
					   ,p_action_information4          => fnd_number.number_to_canonical(l_balance_value) --l_formatted_value
					   ,p_action_information5          => NULL
					   ,p_action_information6          => 'Other Balances'
					   ,p_assignment_id                => p_assignment_id);
			      END IF;
		      END LOOP;
	      END IF; /* For table count check */
 END IF;

 -- fnd_file.put_line(fnd_file.log,'Leaving ARCHIVE_OTH_BALANCE 1');

 EXCEPTION WHEN OTHERS THEN
      g_err_num := SQLCODE;
      --  fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_OTH_BALANCE'||SQLERRM);

 IF g_debug THEN
  hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_OTH_BALANCE',360);
 END IF;

 END ARCHIVE_OTH_BALANCE;

----------------------------------------- PROCEDURE ARCHIVE_CODE ---------------------------------------------------------

 /* ARCHIVE CODE */

 PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
 		      ,p_effective_date    IN DATE)
 IS

----------------------
 /* Cursor to retrieve Payroll and Prepayment related Ids for Archival */
/*

 CURSOR csr_archive_ids (p_locking_action_id NUMBER) IS
 SELECT prepay_assact.assignment_action_id prepay_assact_id
       ,prepay_assact.assignment_id        prepay_assgt_id
       ,prepay_payact.payroll_action_id    prepay_payact_id
       ,prepay_payact.effective_date       prepay_effective_date
       ,run_assact.assignment_id           run_assgt_id
       ,run_assact.assignment_action_id    run_assact_id
       ,run_payact.payroll_action_id       run_payact_id
       ,run_payact.payroll_id              payroll_id
 FROM   pay_action_interlocks  archive_intlck
       ,pay_assignment_actions prepay_assact
       ,pay_payroll_actions    prepay_payact
       ,pay_action_interlocks  prepay_intlck
       ,pay_assignment_actions run_assact
       ,pay_payroll_actions    run_payact
 WHERE  archive_intlck.locking_action_id = p_locking_action_id
 AND    prepay_assact.assignment_action_id = archive_intlck.locked_action_id
 AND    prepay_payact.payroll_action_id = prepay_assact.payroll_action_id
 AND    prepay_payact.action_type IN ('U','P')
 AND    prepay_intlck.locking_action_id = prepay_assact.assignment_action_id
 AND    run_assact.assignment_action_id = prepay_intlck.locked_action_id
 AND    run_payact.payroll_action_id = run_assact.payroll_action_id
 AND    run_payact.action_type IN ('Q', 'R')
 ORDER BY prepay_intlck.locking_action_id,prepay_intlck.locked_action_id desc;

 */

  CURSOR csr_archive_ids (p_locking_action_id NUMBER) IS
 SELECT prepay_assact.assignment_action_id prepay_assact_id
       ,prepay_assact.assignment_id        prepay_assgt_id
       ,prepay_payact.payroll_action_id    prepay_payact_id
       ,prepay_payact.effective_date       prepay_effective_date
       ,run_assact.assignment_id           run_assgt_id
       ,run_assact.assignment_action_id    run_assact_id
       ,run_payact.payroll_action_id       run_payact_id
       ,run_payact.payroll_id              payroll_id
 FROM   pay_action_interlocks  archive_intlck
       ,pay_assignment_actions prepay_assact
       ,pay_payroll_actions    prepay_payact
       ,pay_action_interlocks  prepay_intlck
       ,pay_assignment_actions run_assact
       ,pay_payroll_actions    run_payact
 WHERE  archive_intlck.locking_action_id = p_locking_action_id
 AND    prepay_assact.assignment_action_id = archive_intlck.locked_action_id
 AND    prepay_payact.payroll_action_id = prepay_assact.payroll_action_id
 AND    prepay_payact.action_type IN ('U','P')
 AND    prepay_intlck.locking_action_id = prepay_assact.assignment_action_id
 AND    run_assact.assignment_action_id = prepay_intlck.locked_action_id
 AND    NOT EXISTS (SELECT NULL FROM pay_assignment_actions
                    WHERE payroll_action_id = run_assact.payroll_action_id
                    AND source_action_id = run_assact.ASSIGNMENT_action_id )
 AND    run_payact.payroll_action_id = run_assact.payroll_action_id
 AND    run_payact.action_type IN ('Q', 'R')
 ORDER BY prepay_intlck.locking_action_id,prepay_intlck.locked_action_id desc;

---------------------
/* Cursor to retrieve time period information */
 CURSOR csr_period_end_date(p_assact_id NUMBER,p_pay_act_id NUMBER) IS
 SELECT ptp.end_date              end_date,
        ptp.regular_payment_date  regular_payment_date,
        ptp.time_period_id        time_period_id,
        ppa.date_earned           date_earned,
        ppa.effective_date        effective_date,
        ptp.start_date		 start_date
 FROM   per_time_periods    ptp
       ,pay_payroll_actions ppa
       ,pay_assignment_actions paa
 WHERE  ptp.payroll_id             =ppa.payroll_id
   AND  ppa.payroll_action_id      =paa.payroll_action_id
   AND paa.assignment_action_id    =p_assact_id
   AND ppa.payroll_action_id       =p_pay_act_id
   AND ppa.date_earned BETWEEN ptp.start_date  AND ptp.end_date;
-----------------
 /* Cursor to retrieve Archive Payroll Action Id */
 CURSOR csr_archive_payact(p_assignment_action_id NUMBER) IS
 SELECT payroll_action_id
 FROM   pay_assignment_actions
 WHERE  assignment_Action_id = p_assignment_action_id;
-----------------
 l_archive_payact_id	NUMBER;
 l_record_count  	NUMBER;
 l_actid		NUMBER;
 l_end_date 		per_time_periods.end_date%TYPE;
 l_pre_end_date		per_time_periods.end_date%TYPE;
 l_reg_payment_date 	per_time_periods.regular_payment_date%TYPE;
 l_pre_reg_payment_date per_time_periods.regular_payment_date%TYPE;
 l_date_earned 		pay_payroll_actions.date_earned%TYPE;
 l_pre_date_earned	pay_payroll_actions.date_earned%TYPE;
 l_effective_date 	pay_payroll_actions.effective_date%TYPE;
 l_pre_effective_date 	pay_payroll_actions.effective_date%TYPE;
 l_run_payact_id	NUMBER;
 l_action_context_id	NUMBER;
 g_archive_pact		NUMBER;
 p_assactid		NUMBER;
 l_time_period_id	per_time_periods.time_period_id%TYPE;
 l_pre_time_period_id	per_time_periods.time_period_id%TYPE;
 l_start_date		per_time_periods.start_date%TYPE;
 l_pre_start_date	per_time_periods.start_date%TYPE;
 l_fnd_session		NUMBER := 0;
 l_prev_prepay		NUMBER := 0;
------------------

BEGIN

 -- fnd_file.put_line(fnd_file.log,'Entering Procedure ARCHIVE_CODE');

 IF g_debug THEN
 	hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',380);
 END IF;

   OPEN csr_archive_payact(p_assignment_action_id);
   FETCH csr_archive_payact INTO l_archive_payact_id;
   CLOSE csr_archive_payact;

   -- fnd_file.put_line(fnd_file.log,'closed csr_archive_payact');

   l_record_count := 0;

   -- fnd_file.put_line(fnd_file.log,'LOC 6 => p_assignment_action_id = ' || p_assignment_action_id);

   FOR rec_archive_ids IN csr_archive_ids(p_assignment_action_id) LOOP

     -- fnd_file.put_line(fnd_file.log,'LOC 7 => rec_archive_ids.run_assact_id = ' || rec_archive_ids.run_assact_id );

     OPEN csr_period_end_date(rec_archive_ids.run_assact_id,rec_archive_ids.run_payact_id);
     FETCH csr_period_end_date INTO l_end_date,l_reg_payment_date,l_time_period_id,l_date_earned,l_effective_date,l_start_date;
     CLOSE csr_period_end_date;

     -- fnd_file.put_line(fnd_file.log,'closed csr_period_end_date');

     OPEN csr_period_end_date(rec_archive_ids.prepay_assact_id,rec_archive_ids.prepay_payact_id);
     FETCH csr_period_end_date INTO l_pre_end_date,l_pre_reg_payment_date,l_pre_time_period_id,l_pre_date_earned,l_pre_effective_date,l_pre_start_date;
     CLOSE csr_period_end_date;

     -- fnd_file.put_line(fnd_file.log,'closed csr_period_end_date');

     /*fnd_file.put_line(fnd_file.log,'ARCHIVE_EMPLOYEE_DETAILS');*/

     -------------------------------------------------------------
     --Archive EMPLOYEE_DETAILS, PAYMENT_INFO and BALANCES
     --for every prepayment assignment action id
     -------------------------------------------------------------

     IF (rec_archive_ids.prepay_assact_id <> l_prev_prepay) THEN

     -- fnd_file.put_line(fnd_file.log,'in ARCHIVE_EMPLOYEE_DETAILS');

/*
     ARCHIVE_EMPLOYEE_DETAILS(p_archive_assact_id      => p_assignment_action_id
			      ,p_assignment_id          => rec_archive_ids.run_assgt_id
			      ,p_assignment_action_id   => rec_archive_ids.run_assact_id
			      ,p_payroll_action_id      => l_archive_payact_id
			      ,p_time_period_id         => l_time_period_id
			      ,p_date_earned            => l_pre_date_earned
			      ,p_pay_date_earned        => l_date_earned
			      ,p_effective_date         => p_effective_date);
*/

-- using l_date_earned (Payroll Run Date Earned) instead of l_pre_date_earned (Prepayments Date Earned)
-- because the date_earned column at table pay_payroll_actions for Prepayments may not always be populated.

     ARCHIVE_EMPLOYEE_DETAILS(p_archive_assact_id      => p_assignment_action_id
			      ,p_assignment_id          => rec_archive_ids.run_assgt_id
			      ,p_assignment_action_id   => rec_archive_ids.run_assact_id
			      ,p_payroll_action_id      => l_archive_payact_id
			      ,p_time_period_id         => l_time_period_id
			      ,p_date_earned            => l_date_earned
			      ,p_pay_date_earned        => l_date_earned
			      ,p_effective_date         => p_effective_date);

	-- fnd_file.put_line(fnd_file.log,'out ARCHIVE_EMPLOYEE_DETAILS');
	-- fnd_file.put_line(fnd_file.log,'in ARCHIVE_ADDL_EMP_DETAILS');


   ARCHIVE_ADDL_EMP_DETAILS(p_archive_assact_id      => p_assignment_action_id
			   ,p_assignment_id          => rec_archive_ids.run_assgt_id
			   ,p_assignment_action_id   => rec_archive_ids.run_assact_id
			   ,p_effective_date         => p_effective_date
			   ,p_date_earned            => l_date_earned
			   ,p_payroll_action_id      => l_archive_payact_id );



	-- fnd_file.put_line(fnd_file.log,'out ARCHIVE_ADDL_EMP_DETAILS, currently not being processed');
	-- fnd_file.put_line(fnd_file.log,'in ARCHIVE_PAYMENT_INFO');

    /*fnd_file.put_line(fnd_file.log,'ARCHIVE_PAYMENT_INFO');*/

/*
    ARCHIVE_PAYMENT_INFO(p_archive_assact_id => p_assignment_action_id,
			  p_prepay_assact_id  => rec_archive_ids.prepay_assact_id,
			  p_assignment_id     => rec_archive_ids.prepay_assgt_id,
			  p_date_earned       => l_pre_date_earned,
			  p_effective_date    => p_effective_date);
*/

-- using l_date_earned (Payroll Run Date Earned) instead of l_pre_date_earned (Prepayments Date Earned)
-- because the date_earned column at table pay_payroll_actions for Prepayments may not always be populated.

    ARCHIVE_PAYMENT_INFO(p_archive_assact_id => p_assignment_action_id,
			  p_prepay_assact_id  => rec_archive_ids.prepay_assact_id,
			  p_assignment_id     => rec_archive_ids.prepay_assgt_id,
			  p_date_earned       => l_date_earned,
			  p_effective_date    => p_effective_date);

	-- fnd_file.put_line(fnd_file.log,'out ARCHIVE_PAYMENT_INFO');
	-- fnd_file.put_line(fnd_file.log,'in ARCHIVE_OTH_BALANCE');

/*fnd_file.put_line(fnd_file.log,'ARCHIVE_OTH_BALANCE');*/

    ARCHIVE_OTH_BALANCE(p_archive_assact_id     => p_assignment_action_id,
 		       p_assignment_action_id  => rec_archive_ids.run_assact_id,
 		       p_assignment_id         => rec_archive_ids.run_assgt_id,
 		       p_payroll_action_id     => l_archive_payact_id,
 		       p_record_count          => l_record_count,
 		       p_pre_payact_id         => rec_archive_ids.prepay_payact_id,
 		       p_effective_date        => p_effective_date,
 		       p_date_earned           => l_date_earned,
 		       p_archive_flag          => 'Y');

	--  -- fnd_file.put_line(fnd_file.log,'out ARCHIVE_OTH_BALANCE');
	-- fnd_file.put_line(fnd_file.log,'before end if');



    l_prev_prepay := rec_archive_ids.prepay_assact_id;

    END IF;

    /*fnd_file.put_line(fnd_file.log,'ARCHIVE_ACCRUAL_PLAN');*/

   /* ARCHIVE_ACCRUAL_PLAN (p_assignment_id        => rec_archive_ids.run_assgt_id,
			   p_date_earned          => l_date_earned,
			   p_effective_date       => p_effective_date,
			   p_archive_assact_id    => p_assignment_action_id,
			   p_run_assignment_action_id => rec_archive_ids.run_assact_id,
			   p_period_end_date      => l_end_date,
			   p_period_start_date    => l_start_date);*/

    /*fnd_file.put_line(fnd_file.log,'ARCHIVE_ADD_ELEMENT');*/

	-- fnd_file.put_line(fnd_file.log,'in ARCHIVE_ADD_ELEMENT');


    ARCHIVE_ADD_ELEMENT(p_archive_assact_id     => p_assignment_action_id,
 		       p_assignment_action_id  => rec_archive_ids.run_assact_id,
 		       p_assignment_id         => rec_archive_ids.run_assgt_id,
 		       p_payroll_action_id     => l_archive_payact_id,
 		       p_date_earned           => l_date_earned,
 		       p_effective_date        => p_effective_date,
 		       p_pre_payact_id         => rec_archive_ids.prepay_payact_id,
 		       p_archive_flag          => 'Y');

	-- fnd_file.put_line(fnd_file.log,'out ARCHIVE_ADD_ELEMENT');
	-- fnd_file.put_line(fnd_file.log,'in ARCHIVE_MAIN_ELEMENTS');

    /*fnd_file.put_line(fnd_file.log,'Assact id: '|| p_assignment_action_id);*/

   ARCHIVE_MAIN_ELEMENTS (p_archive_assact_id     => p_assignment_action_id,
			  p_assignment_action_id  => rec_archive_ids.run_assact_id,
		          p_assignment_id         => rec_archive_ids.run_assgt_id,
		          p_date_earned           => l_date_earned,
		          p_effective_date        => p_effective_date,
			  p_payroll_action_id     => l_archive_payact_id ) ;

	-- fnd_file.put_line(fnd_file.log,'out ARCHIVE_MAIN_ELEMENTS');



     l_record_count := l_record_count + 1;

   END LOOP;

 IF g_debug THEN
 	hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',390);
 END IF;

-- fnd_file.put_line(fnd_file.log,'Leaving Procedure ARCHIVE_CODE');

 END ARCHIVE_CODE;


 ---------------------------------------- PROCEDURE ARCHIVE_ADDL_EMP_DETAILS --------------------------------------------------------------------------

 /*Additional Employee Details*/

 PROCEDURE ARCHIVE_ADDL_EMP_DETAILS(p_archive_assact_id  IN NUMBER
				,p_assignment_id 	 IN NUMBER
 				,p_assignment_action_id IN NUMBER
		 		,p_effective_date    IN DATE
			        ,p_date_earned       IN DATE
				,p_payroll_action_id IN NUMBER )
 IS
 -------------
 CURSOR CSR_ACTUAL_TERM_DATE (p_assignment_id NUMBER) IS
 SELECT actual_termination_date
 FROM 	per_periods_of_service pps,
	per_all_assignments_f paa
 WHERE pps.period_of_service_id = paa.period_of_service_id
 AND p_date_earned between paa.effective_start_date and paa.effective_end_date
 AND paa.assignment_id = p_assignment_id;
 -------------

   CURSOR get_details(p_assignment_id NUMBER , p_input_value VARCHAR2 ) IS
   SELECT ee.effective_start_date  effective_start_date
         ,eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,per_all_assignments_f      asg2
         ,per_all_people_f           per
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_date_earned BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_date_earned BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Tax Card'
     AND  et.legislation_code   = 'NO'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_date_earned BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_date_earned BETWEEN eev1.effective_start_date AND eev1.effective_end_date;
  ------------
     CURSOR csr_tax_details(p_assignment_id NUMBER, p_input_value VARCHAR2) IS
     SELECT ee.effective_start_date
         ,eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_date_earned BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       = 'Tax'
     AND  et.legislation_code   = 'NO'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_date_earned BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_date_earned BETWEEN eev1.effective_start_date AND eev1.effective_end_date;
 -------------
    CURSOR csr_tax_category (p_assignment_id NUMBER) IS
    SELECT segment13
    FROM   per_all_assignments_f paa,
           hr_soft_coding_keyflex hsc
    WHERE  paa.soft_coding_keyflex_id = hsc.soft_coding_keyflex_id
    AND p_date_earned BETWEEN paa.effective_start_date  AND paa.effective_end_date
    AND paa.assignment_id = p_assignment_id;
 -------------
    CURSOR csr_global_value (p_global_name VARCHAR2) IS
	SELECT global_value
	FROM ff_globals_f
	WHERE global_name = p_global_name
	AND p_date_earned BETWEEN effective_start_date AND effective_end_date;
 -------------
 /* cursor to get the payroll_d */
 CURSOR csr_payroll (p_payroll_action_id NUMBER) IS
 SELECT PAY_NO_PAYSLIP_ARCHIVE.GET_PARAMETER(legislative_parameters,'PAYROLL_ID')
 FROM  pay_payroll_actions
 WHERE payroll_action_id = p_payroll_action_id ;


/* cursor to get the payroll details */
 CURSOR csr_payroll_details (l_payroll_id NUMBER) IS
 SELECT payroll_name , period_type
 FROM  pay_all_payrolls_f
 WHERE payroll_id = l_payroll_id ;
--------------

/* Cursor to get the Work Title from the assignment */

 cursor csr_work_title (p_assignment_id NUMBER) IS
 SELECT hsck.segment4
 from per_all_assignments_f paaf
     ,hr_soft_coding_keyflex hsck
 where paaf.assignment_id= p_assignment_id
 and p_date_earned BETWEEN paaf.effective_start_date and paaf.effective_end_date
 and paaf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id;
--------------

/* Cursor to get the Zone and meaning from UDT and lookup */

 cursor get_code_meaning ( p_municipal_no VARCHAR2, l_eff_date DATE) IS
 SELECT hr_de_general.get_uci(l_eff_date, t.user_table_id, r.user_row_id,'ZONE')
        || ' ' || hr_general.decode_lookup('NO_TAX_MUNICIPALITY',
        hr_de_general.get_uci(l_eff_date, t.user_table_id, r.user_row_id, 'MAPPING_ID'))
 FROM   pay_user_tables t
       ,pay_user_rows_f r
 WHERE  t.user_table_name        = 'NO_TAX_MUNICIPALITY'
   AND  t.legislation_code       = 'NO'
   AND  r.user_table_id          = t.user_table_id
   AND  r.row_low_range_or_name  = p_municipal_no
   AND  l_eff_date       BETWEEN r.effective_start_date AND r.effective_end_date;

 ------------------------------------------------

 l_actual_termination_date PER_PERIODS_OF_SERVICE.ACTUAL_TERMINATION_DATE%TYPE;
 l_tax_card_effective_date	DATE;
 l_tax_card_type		VARCHAR2(50);
 l_base_rate			NUMBER(5,2);
 l_additional_rate		NUMBER(5,2);
 l_yearly_income_limit		NUMBER(10);
 l_previous_income		NUMBER (10);
 l_ovn				NUMBER ;
 l_rec				get_details%ROWTYPE;
 l_tax_rec			csr_tax_details%ROWTYPE;
 l_action_info_id		pay_action_information.action_information_id%TYPE;
 l_tax_category			hr_soft_coding_keyflex.segment13%TYPE;
 l_defined_balance_id		pay_defined_balances.defined_balance_id%TYPE;

 l_work_title			hr_soft_coding_keyflex.segment4%type := NULL ;
 l_net_salary_ptd		NUMBER;
 l_net_salary_ytd		NUMBER;
 l_table_tax_basis_ptd		NUMBER;
 l_table_tax_basis_ytd		NUMBER;
 l_percent_tax_basis_ptd	NUMBER;
 l_percent_tax_basis_ytd	NUMBER;
 l_tax_deduction_basis_ptd	NUMBER;
 l_tax_deduction_basis_ytd	NUMBER;
 l_table_tax_ptd		NUMBER;
 l_table_tax_ytd		NUMBER;
 l_percent_tax_ptd		NUMBER;
 l_percent_tax_ytd		NUMBER;
 l_withholding_tax_ptd		NUMBER;
 l_withholding_tax_ytd		NUMBER;
 l_seaman_basis_ptd		NUMBER;
 l_seaman_basis_ytd		NUMBER;

 l_threshold_remaining		NUMBER;
 l_threshold_used_per_ytd	NUMBER;
 l_hol_pay_due_this_yr_ytd	NUMBER;
 l_basis_for_hol_pay_ptd	NUMBER;
 l_basis_for_hol_pay_ytd	NUMBER;

l_payroll_id	NUMBER;
l_payroll_name	VARCHAR2(80);
l_period_type	VARCHAR2(80);
--------------
/*
 TYPE tax_card_rec IS RECORD (inp_val_name  pay_input_values_f.NAME%type , screen_entry_val  pay_input_values_f.NAME%type );

 TYPE bal_val_rec IS RECORD ( bal_name	ff_database_items.USER_NAME%type  , bal_val  NUMBER(10,2) );


 TYPE tax_card_table   IS TABLE OF  tax_card_rec   INDEX BY BINARY_INTEGER;

 TYPE bal_val_table   IS TABLE OF  bal_val_rec   INDEX BY BINARY_INTEGER;


 g_tax_card_tab	 tax_card_table;
 g_bal_val	 bal_val_table;

*/

 -------------

 BEGIN

--  fnd_file.put_line(fnd_file.log,'inside ARCHIVE_ADDL_EMP_DETAILS');

 OPEN CSR_ACTUAL_TERM_DATE (p_assignment_id);
 FETCH CSR_ACTUAL_TERM_DATE INTO l_actual_termination_date;
 CLOSE CSR_ACTUAL_TERM_DATE;

--  fnd_file.put_line(fnd_file.log,'closed CSR_ACTUAL_TERM_DATE');

-- fnd_file.put_line(fnd_file.log,'before FOR g_tax_card_tab');

FOR l_index IN g_tax_card_tab.first.. g_tax_card_tab.last LOOP

	  OPEN  get_details( p_assignment_id ,g_tax_card_tab(l_index).inp_val_name );
	  FETCH get_details INTO l_rec;
	  CLOSE get_details;

	  g_tax_card_tab(l_index).screen_entry_val := l_rec.screen_entry_value ;

END LOOP;

-- fnd_file.put_line(fnd_file.log,'end loop FOR g_tax_card_tab');

l_tax_card_effective_date := l_rec.effective_start_date;

---------------------

-- fnd_file.put_line(fnd_file.log,'getting display values for Tax Card');

     -- Getting the display value for Tax Card input values
	g_tax_card_tab(1).screen_entry_val := hr_general.decode_lookup('NO_METHOD_OF_RECEIPT',g_tax_card_tab(1).screen_entry_val);
	--
    OPEN get_code_meaning(g_tax_card_tab(2).screen_entry_val, l_tax_card_effective_date);
    FETCH get_code_meaning INTO g_tax_card_tab(2).screen_entry_val;
    CLOSE get_code_meaning;
    --g_tax_card_tab(2).screen_entry_val :=hr_general.decode_lookup('NO_TAX_MUNICIPALITY',g_tax_card_tab(2).screen_entry_val);
	--
    g_tax_card_tab(3).screen_entry_val := hr_general.decode_lookup('NO_TAX_CARD_TYPE',g_tax_card_tab(3).screen_entry_val);
	g_tax_card_tab(5).screen_entry_val := hr_general.decode_lookup('NO_TAX_TABLE_NO',g_tax_card_tab(5).screen_entry_val);
	g_tax_card_tab(6).screen_entry_val := hr_general.decode_lookup('NO_TAX_TABLE_TYPE',g_tax_card_tab(6).screen_entry_val);
	g_tax_card_tab(8).screen_entry_val := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_tax_card_tab(8).screen_entry_val)) ;	-- Registration Date
	g_tax_card_tab(9).screen_entry_val := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_tax_card_tab(9).screen_entry_val)) ;	-- Date Returned

-- calculating the Threshold Remaining

	l_defined_balance_id := GET_DEFINED_BALANCE_ID('THRESHOLD_USED_PER_YTD');
	l_threshold_used_per_ytd := pay_balance_pkg.get_value(l_defined_balance_id, p_assignment_action_id);
	l_threshold_remaining := g_tax_card_tab(7).screen_entry_val - l_threshold_used_per_ytd ;


-- fnd_file.put_line(fnd_file.log,'archiving ADDL EMPLOYEE DETAILS');

     pay_action_information_api.create_action_information (
	    p_action_information_id        => l_action_info_id
	   ,p_action_context_id            => p_archive_assact_id
	   ,p_action_context_type          => 'AAP'
	   ,p_object_version_number        => l_ovn
	   ,p_effective_date               => p_effective_date
	   ,p_source_id                    => NULL
	   ,p_source_text                  => NULL
	   ,p_action_information_category  => 'ADDL EMPLOYEE DETAILS'
	   ,p_action_information4          => g_tax_card_tab(1).screen_entry_val	-- Method of Receipt
	   ,p_action_information5          => g_tax_card_tab(2).screen_entry_val	-- Tax Municipality
	   ,p_action_information6          => g_tax_card_tab(3).screen_entry_val	-- Tax Card Type
	   ,p_action_information7          => g_tax_card_tab(4).screen_entry_val	-- Tax Percentage
	   ,p_action_information8          => g_tax_card_tab(5).screen_entry_val	-- Tax Table Number
	   ,p_action_information9          => g_tax_card_tab(6).screen_entry_val	-- Tax Table Type
	   ,p_action_information10         => g_tax_card_tab(7).screen_entry_val	-- Tax Free Threshold
	   ,p_action_information11         => g_tax_card_tab(8).screen_entry_val	-- Registration Date
	   ,p_action_information12         => g_tax_card_tab(9).screen_entry_val	-- Date Returned
	   ,p_action_information13         => l_threshold_remaining			-- Threshold Remaining
	   ,p_assignment_id                => p_assignment_id );

-- fnd_file.put_line(fnd_file.log,'finished archiving ADDL EMPLOYEE DETAILS');

-------------------------------------------------------------------------------

-- fnd_file.put_line(fnd_file.log,'begin FOR g_bal_val');

-- fnd_file.put_line(fnd_file.log,'g_bal_val.first = '||to_char(g_bal_val.first));
-- fnd_file.put_line(fnd_file.log,'g_bal_val.last = '||to_char(g_bal_val.last));


FOR l_index IN g_bal_val.first.. g_bal_val.last LOOP

	-- fnd_file.put_line(fnd_file.log,'l_index = '||to_char(l_index));
	-- fnd_file.put_line(fnd_file.log,'g_bal_val(l_index).bal_name = '||g_bal_val(l_index).bal_name);

	l_defined_balance_id := GET_DEFINED_BALANCE_ID( g_bal_val(l_index).bal_name );

	-- fnd_file.put_line(fnd_file.log,'l_defined_balance_id = '||to_char(l_defined_balance_id));
	-- fnd_file.put_line(fnd_file.log,'p_assignment_action_id = '||to_char(p_assignment_action_id));

	g_bal_val(l_index).bal_val := pay_balance_pkg.get_value(l_defined_balance_id, p_assignment_action_id);

	-- fnd_file.put_line(fnd_file.log,'g_bal_val(l_index).bal_val = '||to_char(g_bal_val(l_index).bal_val));

END LOOP;

-- fnd_file.put_line(fnd_file.log,'end loop FOR g_bal_val');
-- fnd_file.put_line(fnd_file.log,'start asigning balance values');

l_net_salary_ptd		:= g_bal_val(1).bal_val ;
l_net_salary_ytd		:= g_bal_val(2).bal_val ;
l_table_tax_basis_ptd		:= g_bal_val(5).bal_val ;
l_table_tax_basis_ytd		:= g_bal_val(6).bal_val ;
l_percent_tax_basis_ptd		:= g_bal_val(7).bal_val ;
l_percent_tax_basis_ytd		:= g_bal_val(8).bal_val ;
l_tax_deduction_basis_ptd	:= l_table_tax_basis_ptd + l_percent_tax_basis_ptd ;
l_tax_deduction_basis_ytd	:= l_table_tax_basis_ytd + l_percent_tax_basis_ytd ;
l_table_tax_ptd			:= g_bal_val(9).bal_val ;
l_table_tax_ytd			:= g_bal_val(10).bal_val ;
l_percent_tax_ptd		:= g_bal_val(11).bal_val ;
l_percent_tax_ytd		:= g_bal_val(12).bal_val ;
l_withholding_tax_ptd		:= g_bal_val(3).bal_val ;
l_withholding_tax_ytd		:= g_bal_val(4).bal_val ;
l_hol_pay_due_this_yr_ytd	:= g_bal_val(13).bal_val + g_bal_val(14).bal_val ;
l_basis_for_hol_pay_ptd		:= g_bal_val(15).bal_val ;
l_basis_for_hol_pay_ytd		:= g_bal_val(16).bal_val ;

-- l_seaman_basis_ptd		:= g_bal_val(13).bal_val ;
-- l_seaman_basis_ytd		:= g_bal_val(14).bal_val ;





-- fnd_file.put_line(fnd_file.log,'finish asigning balance values');

/* get the work title of the employee */

OPEN csr_work_title (p_assignment_id) ;
FETCH csr_work_title INTO l_work_title ;
CLOSE csr_work_title ;


-- fnd_file.put_line(fnd_file.log,'after the select decode');

-- fnd_file.put_line(fnd_file.log,'starting archiving NO EMPLOYEE DETAILS');

     pay_action_information_api.create_action_information (
	    p_action_information_id        => l_action_info_id
	   ,p_action_context_id            => p_archive_assact_id
	   ,p_action_context_type          => 'AAP'
	   ,p_object_version_number        => l_ovn
	   ,p_effective_date               => p_effective_date
	   ,p_source_id                    => NULL
	   ,p_source_text                  => NULL
	   ,p_action_information_category  => 'NO EMPLOYEE DETAILS'
	   ,p_action_information1          => l_work_title			-- Work Title
	   ,p_action_information2          => l_net_salary_ptd			-- Net Salary Period
	   ,p_action_information3          => l_net_salary_ytd			-- Net Salary Ytd
	   ,p_action_information4          => l_withholding_tax_ptd		-- Withholding Tax Period
	   ,p_action_information5          => l_withholding_tax_ytd		-- Withholding Tax Ytd
	   ,p_action_information6          => l_tax_deduction_basis_ptd		-- Tax Deduction Basis Period
	   ,p_action_information7          => l_tax_deduction_basis_ytd		-- Tax Deduction Basis Ytd
	   ,p_action_information8          => l_table_tax_basis_ptd		-- Table Based Tax Basis Period
	   ,p_action_information9          => l_table_tax_basis_ytd		-- Table Based Tax Basis Ytd
	   ,p_action_information10         => l_table_tax_ptd			-- Table Based Tax Period
	   ,p_action_information11         => l_table_tax_ytd			-- Table Based Tax Ytd
	   ,p_action_information12         => l_percent_tax_basis_ptd		-- Percentage Tax Basis Period
	   ,p_action_information13         => l_percent_tax_basis_ytd		-- Percentage Tax Basis Ytd
	   ,p_action_information14         => l_percent_tax_ptd			-- Percentage Based Tax Period
	   ,p_action_information15         => l_percent_tax_ytd			-- Percentage Based Tax Ytd
	   -- ,p_action_information16         => l_seaman_basis_ptd		-- Seaman Deduction Basis Period
	   -- ,p_action_information17         => l_seaman_basis_ytd		-- Seaman Deduction Basis Ytd
	   ,p_action_information16         => l_hol_pay_due_this_yr_ytd		-- Holiday Pay, due this year
	   ,p_action_information17         => l_basis_for_hol_pay_ptd		-- Basis for Holiday Pay Period
	   ,p_action_information18         => l_basis_for_hol_pay_ytd		-- Basis for Holiday Pay Ytd
	   ,p_assignment_id                => p_assignment_id);


-- fnd_file.put_line(fnd_file.log,'finished archiving NO EMPLOYEE DETAILS');
-- fnd_file.put_line(fnd_file.log,'leaving ARCHIVE_ADDL_EMP_DETAILS');


 END ARCHIVE_ADDL_EMP_DETAILS;

 --------------------------------------- PROCEDURE ARCHIVE_MAIN_ELEMENTS ---------------------------------------------------------

 /* ARCHIVE EARNINGS AND DEDUCTIONS ELEMENTS REGION */

 PROCEDURE ARCHIVE_MAIN_ELEMENTS
	(p_archive_assact_id     IN NUMBER,
         p_assignment_action_id  IN NUMBER,
         p_assignment_id         IN NUMBER,
         p_date_earned           IN DATE,
         p_effective_date        IN DATE,
	 p_payroll_action_id	 IN NUMBER ) IS

 ----------------

 /* Cursor to retrieve Earnings Element Information */
 /*
 CURSOR csr_ear_element_info IS
 SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
       ,et.element_type_id element_type_id
       ,iv.input_value_id input_value_id
       ,iv.uom uom
 FROM   pay_element_types_f         et
 ,      pay_element_types_f_tl      pettl
 ,      pay_input_values_f          iv
 ,      pay_element_classifications classification
 WHERE  et.element_type_id              = iv.element_type_id
 AND    et.element_type_id              = pettl.element_type_id
 AND    pettl.language                  = USERENV('LANG')
 AND    iv.name                         = 'Pay Value'
 AND    classification.classification_id   = et.classification_id
 AND    classification.classification_name
	IN ('Absence','Direct Payments','Earnings','Supplementary Earnings')
 AND    p_date_earned       BETWEEN et.effective_start_date  AND et.effective_end_date
 AND    p_date_earned       BETWEEN iv.effective_start_date  AND iv.effective_end_date
 AND ((et.business_group_id IS NULL AND et.legislation_code = 'NO')
	OR (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL));

*/
  ---------------

  /* Cursor to retrieve Deduction Element Information */

/*
 CURSOR csr_ded_element_info IS
 SELECT nvl(pettl.reporting_name,pettl.element_name) rep_name
       ,et.element_type_id element_type_id
       ,iv.input_value_id input_value_id
       ,iv.uom uom
 FROM   pay_element_types_f         et
 ,      pay_element_types_f_tl      pettl
 ,      pay_input_values_f          iv
 ,      pay_element_classifications classification
 WHERE  et.element_type_id              = iv.element_type_id
 AND    et.element_type_id              = pettl.element_type_id
 AND    pettl.language                  = USERENV('LANG')
 AND    iv.name                         = 'Pay Value'
 AND    classification.classification_id   = et.classification_id
 AND    classification.classification_name
		IN ('Involuntary Deductions','Pre-tax Deductions','Statutory Deductions','Voluntary Deductions')
 AND    p_date_earned       BETWEEN et.effective_start_date  AND et.effective_end_date
 AND    p_date_earned       BETWEEN iv.effective_start_date  AND iv.effective_end_date
 AND ((et.business_group_id IS NULL AND et.legislation_code = 'NO')
	 OR  (et.business_group_id = g_business_group_id AND et.legislation_code IS NULL));

*/

  ---------------
/* Cursor to retrieve Main Element Information */

CURSOR csr_get_main_elements (p_payroll_action_id  NUMBER ) IS
SELECT   action_information2  element_type_id
	,action_information3  input_value_id
	,action_information4  element_narrative
	,action_information5  element_context
	,action_information6  uom
	,action_information8  prim_def_bal_id
	,action_information12 ele_class
FROM pay_action_information
WHERE action_context_id = p_payroll_action_id
AND    action_information_category = 'NO ELEMENT DEFINITION'
AND    action_context_type = 'PA'
AND    action_information5 <> 'F';

----------------------------------------------------------

/* cursor to get the tax unit id (Legal Employer) from assignment action id */

CURSOR csr_get_le_org_id (p_assignment_action_id   NUMBER) IS
SELECT tax_unit_id
FROM pay_assignment_actions
WHERE assignment_action_id = p_assignment_action_id ;

--------------------------------------------------------

/* cursor to get the element code */

/*
CURSOR csr_ele_code (p_ele_type_id  NUMBER , p_le_org_id   NUMBER ) IS
select eei_information1
from   pay_element_type_extra_info
where  element_type_id = p_ele_type_id
and    ( eei_information2 = p_le_org_id OR eei_information2 is null )
and    information_type = 'NO_ELEMENT_CODES'
and    eei_information_category = 'NO_ELEMENT_CODES'
and    rownum = 1
order by eei_information2 , element_type_extra_info_id ;
*/

-- modifying the above cursor

 cursor csr_ele_code(p_ele_type_id  NUMBER , p_leg_emp_id NUMBER ) is
	select nvl((select eei_information1 from pay_element_type_extra_info petei
	where petei.information_type='NO_ELEMENT_CODES'
	and element_type_id = p_ele_type_id
	and petei.eei_information2 = p_leg_emp_id
	and rownum=1),
	(select eei_information1 from pay_element_type_extra_info petei
	where petei.information_type='NO_ELEMENT_CODES'
	and element_type_id = p_ele_type_id
	and eei_information2 is null
	and rownum=1)) from dual;

--------------------------------------------------------

/* cursor to get the further element entry info for payslip information */

CURSOR csr_payslip_info (p_ele_entry_id   NUMBER) IS
SELECT ENTRY_INFORMATION1
FROM pay_element_entries_f
where ELEMENT_ENTRY_ID = p_ele_entry_id ;

----------------------------------

 /* Cursor to retrieve run result value of Main Elements */
 CURSOR csr_result_value(p_iv_id NUMBER
 		       ,p_ele_type_id NUMBER
 		       ,p_assignment_action_id NUMBER) IS
 SELECT rrv.result_value	val
       ,rr.element_entry_id	ele_entry_id
 FROM   pay_run_result_values rrv
       ,pay_run_results rr
       ,pay_assignment_actions paa
       ,pay_payroll_actions ppa
 WHERE  rrv.input_value_id = p_iv_id
 AND    rr.element_type_id = p_ele_type_id
 AND    rr.run_result_id = rrv.run_result_id
 AND    rr.assignment_action_id = paa.assignment_action_id
 AND    paa.assignment_action_id = p_assignment_action_id
 AND    ppa.payroll_action_id = paa.payroll_action_id
 AND    ppa.action_type IN ('Q','R')
 AND    rrv.result_value IS NOT NULL;

  -----------------------------------------

/* cursor to get the element type id for 'Tax' element */
/*
CURSOR csr_get_tax_element IS
SELECT element_type_id
FROM pay_element_types_f
WHERE element_name = 'Tax'
AND legislation_code = 'NO'
AND business_group_id IS NULL
AND p_date_earned BETWEEN effective_start_date AND effective_end_date ;
*/

  -----------------------------------------

-- cursor to get the name of the element

cursor csr_element_name (p_element_type_id  NUMBER) IS
select element_name
from pay_element_types_f
where element_type_id = p_element_type_id
and p_date_earned between effective_start_date and effective_end_date ;

  -----------------------------------------

-- cursor to get the input value id

cursor csr_inp_val_id (p_element_type_id  NUMBER , p_inp_val_name pay_input_values_f.name%TYPE ) IS
select input_value_id
from pay_input_values_f
where element_type_id = p_element_type_id
and name = p_inp_val_name
and business_group_id is null
and legislation_code = 'NO'
and p_date_earned between effective_start_date and effective_end_date ;

  -----------------------------------------

 /* Cursor to retrieve Business Group Id */
 CURSOR csr_bus_grp_id(p_organization_id NUMBER) IS
 SELECT business_group_id
 FROM   hr_organization_units
 WHERE  organization_id = p_organization_id;

  -----------------------------------------

-- Cursor to get the 'Tax Period Override Element' details
  CURSOR csr_tax_period_override (p_assignment_id NUMBER, p_input_value VARCHAR2) IS
     SELECT eev1.screen_entry_value  screen_entry_value
   FROM   per_all_assignments_f      asg1
         ,pay_element_links_f        el
         ,pay_element_types_f        et
         ,pay_input_values_f         iv1
         ,pay_element_entries_f      ee
         ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND  p_date_earned BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND  et.element_name       = 'Tax Period Override Element'
     AND  et.legislation_code   = 'NO'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = p_input_value
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg1.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_date_earned BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_date_earned BETWEEN eev1.effective_start_date AND eev1.effective_end_date ;
  ---------------

-- cursor to get the reduced tax rule for the period
  CURSOR csr_get_reduced_tax_rule (p_asg_act_id number) IS
  SELECT ptp.prd_information1
  FROM  per_time_periods ptp , pay_payroll_actions ppa , pay_assignment_actions paa
  WHERE paa.ASSIGNMENT_ACTION_ID = p_asg_act_id
  AND   ppa.payroll_action_id = paa.PAYROLL_ACTION_ID
  AND   ppa.time_period_id = ptp.time_period_id ;

  -------------------------------------

 l_result_value		pay_run_result_values.result_value%TYPE := 0;
 l_action_info_id	NUMBER;
 l_ovn			NUMBER;
 l_element_context	VARCHAR2(10);
 l_index		NUMBER := 0;
 l_formatted_value	VARCHAR2(50) := NULL;
 l_flag			NUMBER := 0;
 l_le_org_id		NUMBER;
 l_ele_code		VARCHAR2(240) := NULL ;
 l_ele_entry_id		NUMBER;
 l_payslip_info		varchar2(240);
 l_balance_value	NUMBER := 0;
 l_archive		VARCHAR2(2);
 l_tax_ele_typ_id	NUMBER;

 l_element_name		varchar2(240);
 l_inp_val_id		NUMBER;
 l_suppl_method		varchar2(240);
 l_bg_id		NUMBER;
 l_arhive_prim_bal	VARCHAR2(5);

 l_msg_txt			VARCHAR2(240);
 l_msg_name			VARCHAR2(240);
 l_earn_period			VARCHAR2(240);
 l_earn_period_mul		VARCHAR2(240);
 l_tax_per_override_msg_txt	VARCHAR2(240);
 l_reduced_tax_rule		VARCHAR2(240);
 l_reduced_tax_rule_msg_txt	VARCHAR2(240);
 ----------------

BEGIN

 IF g_debug THEN
 	hr_utility.set_location(' Entering Procedure ARCHIVE_MAIN_ELEMENTS',320);
 END IF;

-- Archiving Earnings Elements

-- fnd_file.put_line(fnd_file.log,'started archiving NO Earnings Elements');

-- fnd_file.put_line(fnd_file.log,'LOC 0 => p_archive_assact_id = ' || p_archive_assact_id );

/*
OPEN csr_get_tax_element;
FETCH  csr_get_tax_element INTO l_tax_ele_typ_id ;
CLOSE csr_get_tax_element;
*/

 l_le_org_id := NULL ;

 /* get the legal employer */
 OPEN csr_get_le_org_id (p_assignment_action_id );
 FETCH csr_get_le_org_id INTO l_le_org_id ;
 CLOSE csr_get_le_org_id ;

 -- fnd_file.put_line(fnd_file.log,'l_le_org_id = ' || l_le_org_id);


 -- get the business group id for the LE
 OPEN csr_bus_grp_id(l_le_org_id);
 FETCH csr_bus_grp_id INTO l_bg_id;
 CLOSE csr_bus_grp_id;


 FOR csr_rec IN csr_get_main_elements (p_payroll_action_id ) LOOP


	     l_arhive_prim_bal := 'N' ;
	     l_ele_code := NULL ;

	    /* get the element code from the legal employer */
	    OPEN csr_ele_code (csr_rec.element_type_id , l_le_org_id );
	    FETCH csr_ele_code INTO l_ele_code ;
	    CLOSE csr_ele_code ;

	    /*
	    IF (l_ele_code IS NOT NULL) THEN
		  l_ele_code := hr_general.decode_lookup('NO_ELEMENT_CODES',l_ele_code);
	    END IF;
	    */

	    -- fnd_file.put_line(fnd_file.log,'l_ele_code = ' || l_ele_code);

	   -- get the name of the element
	   OPEN csr_element_name (csr_rec.element_type_id) ;
	   FETCH csr_element_name INTO l_element_name ;
	   CLOSE csr_element_name ;


	   IF ( l_element_name = 'Tax' ) THEN

	      -- fnd_file.put_line(fnd_file.log,'Found Tax Element' );
	      -- start processing to populate message for Supplementary Run

	      -- get the input value id for the 'Supplementary Run Method' input value on Tax element

	      OPEN csr_inp_val_id ( csr_rec.element_type_id , 'Supplementary Run Method' ) ;
	      FETCH csr_inp_val_id INTO l_inp_val_id ;
	      CLOSE csr_inp_val_id ;

	      -- get the 'Supplementary Run Method' run result value
	      OPEN csr_result_value(l_inp_val_id
				   ,csr_rec.element_type_id
				   ,p_assignment_action_id);

	      FETCH csr_result_value INTO l_result_value , l_ele_entry_id ;
	      CLOSE csr_result_value ;

		-- fnd_file.put_line(fnd_file.log,'l_result_value (for Supplementary Run) = ' ||l_result_value );

		IF (l_result_value = 'PERIOD') THEN
			l_msg_name := 'PAY_376884_NO_SUP_RUN_PERIOD' ;
		ELSIF (l_result_value = 'PERCENTAGE') THEN
			l_msg_name := 'PAY_376885_NO_SUP_RUN_PERCENT' ;
		END IF;

		IF ( (l_result_value IS NOT NULL) AND (l_msg_name IS NOT NULL) ) THEN
			-- set the message name and get the message text
			hr_utility.set_message (801, l_msg_name);
			l_msg_txt := hr_utility.get_message ;

			-- fnd_file.put_line(fnd_file.log,'l_msg_txt (for Supplementary Run) = ' ||l_msg_txt );

		/* Arcvhive the message */
		pay_action_information_api.create_action_information (
		    p_action_information_id        => l_action_info_id
		   ,p_action_context_id            => p_archive_assact_id
		   ,p_action_context_type          => 'AAP'
		   ,p_object_version_number        => l_ovn
		   ,p_effective_date               => p_effective_date
		   ,p_source_id                    => NULL
		   ,p_source_text                  => NULL
		   ,p_action_information_category  => 'EMPLOYEE OTHER INFORMATION'
		   ,p_action_information1          => l_bg_id
		   ,p_action_information2          => 'MESG' -- Message Context
		   ,p_action_information3          => NULL
		   ,p_action_information4          => NULL
		   ,p_action_information5          => NULL
		   ,p_action_information6          => l_msg_txt );

	        END IF; -- end if l_msg_name IS NOT NULL

		-- end processing to populate message for Supplementary Run


		-- start processing to populate message for 'Tax Period Override Element'

		IF ( (l_result_value IS NULL) OR (l_result_value <> 'PERCENTAGE') )  THEN


			-- fnd_file.put_line(fnd_file.log,'l_result_value <> PERCENTAGE ' );

			OPEN csr_tax_period_override (p_assignment_id , 'Earnings Period' ) ;
			FETCH csr_tax_period_override INTO l_earn_period ;
			CLOSE csr_tax_period_override ;

			OPEN csr_tax_period_override (p_assignment_id , 'Earnings Period Multiplier' ) ;
			FETCH csr_tax_period_override INTO l_earn_period_mul ;
			CLOSE csr_tax_period_override ;


			IF ( (l_earn_period IS NOT NULL) AND (l_earn_period_mul IS NOT NULL) ) THEN

				l_earn_period := hr_general.decode_lookup('NO_PAYROLL_PERIOD',l_earn_period) ;
				hr_utility.set_message (801, 'PAY_376886_NO_TAX_PER_OVERRIDE' );
				hr_utility.set_message_token (801, 'EARN_PERIOD', l_earn_period);
				hr_utility.set_message_token (801, 'EARN_PER_MUL', l_earn_period_mul);
				l_tax_per_override_msg_txt := hr_utility.get_message ;

				-- fnd_file.put_line(fnd_file.log,'l_earn_period = ' ||l_earn_period );
				-- fnd_file.put_line(fnd_file.log,'l_earn_period_mul = ' ||l_earn_period_mul );
				-- fnd_file.put_line(fnd_file.log,'l_tax_per_override_msg_txt = ' ||l_tax_per_override_msg_txt );

			/* Arcvhive the message */
			pay_action_information_api.create_action_information (
			    p_action_information_id        => l_action_info_id
			   ,p_action_context_id            => p_archive_assact_id
			   ,p_action_context_type          => 'AAP'
			   ,p_object_version_number        => l_ovn
			   ,p_effective_date               => p_effective_date
			   ,p_source_id                    => NULL
			   ,p_source_text                  => NULL
			   ,p_action_information_category  => 'EMPLOYEE OTHER INFORMATION'
			   ,p_action_information1          => l_bg_id
			   ,p_action_information2          => 'MESG' -- Message Context
			   ,p_action_information3          => NULL
			   ,p_action_information4          => NULL
			   ,p_action_information5          => NULL
			   ,p_action_information6          => l_tax_per_override_msg_txt );

			END IF;
		END IF; -- end if l_result_value <> 'PERCENTAGE'

		-- end processing to populate message for 'Tax Period Override Element'


		-- start processing to populate message for Reduced Tax Rule

		  -- fnd_file.put_line(fnd_file.log,'before csr_get_reduced_tax_rule ' );

		  OPEN csr_get_reduced_tax_rule (p_assignment_action_id) ;
		  FETCH csr_get_reduced_tax_rule INTO l_reduced_tax_rule ;
		  CLOSE csr_get_reduced_tax_rule ;

		  -- fnd_file.put_line(fnd_file.log,'l_reduced_tax_rule = ' ||l_reduced_tax_rule );

		  IF (l_reduced_tax_rule IN ('H','Z')) THEN
			l_reduced_tax_rule := hr_general.decode_lookup('NO_TAX_PERIOD_RULES',l_reduced_tax_rule) ;
			hr_utility.set_message (801, 'PAY_376887_NO_REDUCED_TAX');
			hr_utility.set_message_token (801, 'REDUCED_TAX', l_reduced_tax_rule);
			l_reduced_tax_rule_msg_txt := hr_utility.get_message ;

			-- fnd_file.put_line(fnd_file.log,'l_reduced_tax_rule = ' || l_reduced_tax_rule );
			-- fnd_file.put_line(fnd_file.log,'l_reduced_tax_rule_msg_txt = ' ||l_reduced_tax_rule_msg_txt );

			/* Arcvhive the message */
			pay_action_information_api.create_action_information (
			    p_action_information_id        => l_action_info_id
			   ,p_action_context_id            => p_archive_assact_id
			   ,p_action_context_type          => 'AAP'
			   ,p_object_version_number        => l_ovn
			   ,p_effective_date               => p_effective_date
			   ,p_source_id                    => NULL
			   ,p_source_text                  => NULL
			   ,p_action_information_category  => 'EMPLOYEE OTHER INFORMATION'
			   ,p_action_information1          => l_bg_id
			   ,p_action_information2          => 'MESG' -- Message Context
			   ,p_action_information3          => NULL
			   ,p_action_information4          => NULL
			   ,p_action_information5          => NULL
			   ,p_action_information6          => l_reduced_tax_rule_msg_txt );

		  END IF;

		-- end processing to populate message for Reduced Tax Rule

	   END IF; -- end if l_element_name = 'Tax'

	   -- end processing to populate message for Supplementary Run


   l_result_value := NULL;
   l_arhive_prim_bal := 'N' ;

	   BEGIN
		   /*

		    OPEN csr_result_value(csr_rec.input_value_id  ,csr_rec.element_type_id  ,p_assignment_action_id);
		    FETCH csr_result_value INTO l_result_value;
		    CLOSE csr_result_value;

		    IF  l_result_value is not null THEN
				pay_action_information_api.create_action_information (
				    p_action_information_id        => l_action_info_id
				   ,p_action_context_id            => p_archive_assact_id
				   ,p_action_context_type          => 'AAP'
				   ,p_object_version_number        => l_ovn
				   ,p_effective_date               => p_effective_date
				   ,p_source_id                    => NULL
				   ,p_source_text                  => NULL
				   ,p_action_information_category  => 'EMEA ELEMENT INFO'
				   ,p_action_information1          => csr_rec.element_type_id
				   ,p_action_information2          => csr_rec.input_value_id
				   ,p_action_information3          => 'E'
				   ,p_action_information4          => l_result_value --l_formatted_value
				   ,p_action_information9          => 'Earning Element'
				   ,p_assignment_id                => p_assignment_id);
		     END IF;

		  */

		  -- fnd_file.put_line(fnd_file.log,'------------------------------------------');
		  -- fnd_file.put_line(fnd_file.log,'csr_rec.element_narrative = ' || csr_rec.element_narrative);
		  -- fnd_file.put_line(fnd_file.log,'csr_rec.element_type_id = ' || csr_rec.element_type_id);
		  -- fnd_file.put_line(fnd_file.log,'csr_rec.input_value_id = ' || csr_rec.input_value_id);
		  -- fnd_file.put_line(fnd_file.log,'p_assignment_action_id = ' || p_assignment_action_id);


		  l_result_value := NULL ;
		  l_ele_entry_id := NULL ;
		  l_balance_value := NULL ;

		    IF (csr_rec.prim_def_bal_id IS NOT NULL) THEN

			    -- get the primary balance ytd value for the element


			     -- fnd_file.put_line(fnd_file.log,'------ loc 1 ---------------');
			     -- fnd_file.put_line(fnd_file.log,'l_element_name = ' || l_element_name);
			     -- fnd_file.put_line(fnd_file.log,'csr_rec.prim_def_bal_id  = ' || csr_rec.prim_def_bal_id );


			    l_balance_value := pay_balance_pkg.get_value(csr_rec.prim_def_bal_id , p_assignment_action_id );

			    /* Change for element classification name from 'Holiday Pay Earnings Adjustment' to 'Holiday Pay Earnings Adjust' */

			    -- IF csr_rec.ele_class in ('Earnings Adjustment' , 'Holiday Pay Earnings Adjustment') THEN

				-- The following classifications have been obsoleted and will no longer be used.
				-- Holiday Pay Earnings Adjust => Holiday Pay Earnings Adjust Obsolete
				-- Commenting the code below.

			    -- IF csr_rec.ele_class in ('Earnings Adjustment' , 'Holiday Pay Earnings Adjust') THEN
			    IF csr_rec.ele_class in ('Earnings Adjustment') THEN

				-- l_balance_value := fnd_number.number_to_canonical (0 - fnd_number.canonical_to_number (l_balance_value) ) ;
				-- Bug Fix : 5909576, pay_balance_pkg.get_value already returns a value in NUMBER format.
				-- So we need not do a fnd_number.canonical_to_number on l_balance_value.

				l_balance_value := (0 - l_balance_value ) ;

			    END IF;

			     -- fnd_file.put_line(fnd_file.log,'l_balance_value = ' || l_balance_value);
			     -- fnd_file.put_line(fnd_file.log,'---------------------');


		    END IF;


		  -- fnd_file.put_line(fnd_file.log,'l_element_name = ' || l_element_name||' |||||||| csr_rec.prim_def_bal_id  = ' || csr_rec.prim_def_bal_id);

		  /* get the element run result value */
		    OPEN csr_result_value(csr_rec.input_value_id
					   ,csr_rec.element_type_id
					   ,p_assignment_action_id);
		    LOOP
		    FETCH csr_result_value INTO l_result_value , l_ele_entry_id ;

		    IF (csr_result_value%NOTFOUND) AND
		       (csr_result_value%ROWCOUNT < 1) AND
		       (csr_rec.prim_def_bal_id IS NOT NULL) AND
		       (l_balance_value <> 0)  THEN

				l_arhive_prim_bal := 'Y' ;
				-- fnd_file.put_line(fnd_file.log,'LOC 2 => p_assignment_action_id , l_element_name = ' || p_assignment_action_id ||' , '||l_element_name);
		    END IF ;

		    EXIT WHEN csr_result_value%NOTFOUND;

		    -- fnd_file.put_line(fnd_file.log,'LOC 3 => p_assignment_action_id , l_element_name = ' || p_assignment_action_id ||' , '||l_element_name);

		    -- l_balance_value := NULL ;



		    -- fnd_file.put_line(fnd_file.log,'l_result_value = ' || l_result_value);
		    -- fnd_file.put_line(fnd_file.log,'l_ele_entry_id = ' || l_ele_entry_id);
		    -- fnd_file.put_line(fnd_file.log,'before l_balance_value = ' || l_balance_value);

		    -- modifying the below condition to get the ytd value for primary balance
		    -- only once in case of multiple element entries

		    -- IF (csr_rec.prim_def_bal_id IS NOT NULL) THEN

		    -- fnd_file.put_line(fnd_file.log,'l_element_name = ' || l_element_name||' |||||||| csr_rec.prim_def_bal_id  = ' || csr_rec.prim_def_bal_id);

		/*
		    IF (csr_rec.prim_def_bal_id IS NOT NULL) THEN -- AND (csr_result_value%ROWCOUNT = 1) THEN

			    -- get the primary balance ytd value for the element


			    fnd_file.put_line(fnd_file.log,'---------------------');
			    fnd_file.put_line(fnd_file.log,'l_element_name = ' || l_element_name);
			    fnd_file.put_line(fnd_file.log,'csr_rec.prim_def_bal_id  = ' || csr_rec.prim_def_bal_id );


			    l_balance_value := pay_balance_pkg.get_value(csr_rec.prim_def_bal_id , p_assignment_action_id );

			    fnd_file.put_line(fnd_file.log,'l_balance_value = ' || l_balance_value);
			    fnd_file.put_line(fnd_file.log,'---------------------');


		    END IF;

		 */

		    IF (csr_result_value%ROWCOUNT > 1) THEN
			    l_balance_value := NULL ;
		    END IF;

		    -- fnd_file.put_line(fnd_file.log,'csr_rec.prim_def_bal_id = ' || csr_rec.prim_def_bal_id);
		    -- fnd_file.put_line(fnd_file.log,'csr_result_value%ROWCOUNT = ' || csr_result_value%ROWCOUNT);
		    -- fnd_file.put_line(fnd_file.log,'after l_balance_value = ' || l_balance_value);
 	            -- fnd_file.put_line(fnd_file.log,'csr_rec.prim_def_bal_id = ' || csr_rec.prim_def_bal_id);
		    -- fnd_file.put_line(fnd_file.log,'l_balance_value = ' || l_balance_value);

		    /* get the payslip information */
		    l_payslip_info := NULL ;

		    OPEN csr_payslip_info (l_ele_entry_id );
		    FETCH csr_payslip_info INTO l_payslip_info ;
		    CLOSE csr_payslip_info ;

		    -- fnd_file.put_line(fnd_file.log,'l_payslip_info = ' || l_payslip_info);

		    -- if the element classification is 'Earnings Adjustment' or 'Holiday Pay Earnings Adjustment',
		    -- then store the result as negative value

		    /* Change for element classification name from 'Holiday Pay Earnings Adjustment' to 'Holiday Pay Earnings Adjust' */

		    -- IF csr_rec.ele_class in ('Earnings Adjustment' , 'Holiday Pay Earnings Adjustment') THEN

			-- The following classifications have been obsoleted and will no longer be used.
			-- Holiday Pay Earnings Adjust => Holiday Pay Earnings Adjust Obsolete
			-- Commenting the code below.

		    -- IF csr_rec.ele_class in ('Earnings Adjustment' , 'Holiday Pay Earnings Adjust') THEN
		    IF csr_rec.ele_class in ('Earnings Adjustment') THEN

			-- fnd_file.put_line(fnd_file.log,'before l_result_value = ' ||l_result_value );
			l_result_value := fnd_number.number_to_canonical (0 - fnd_number.canonical_to_number (l_result_value) ) ;
			-- fnd_file.put_line(fnd_file.log,'after l_result_value = ' ||l_result_value );

		    END IF;

		    IF    (l_result_value is not null) THEN l_archive := 'Y';
		    -- ELSIF (csr_rec.prim_def_bal_id IS NOT NULL) AND ( (l_balance_value <> 0) OR (l_balance_value IS NOT NULL) ) THEN l_archive := 'Y';
		    -- ELSIF (csr_rec.prim_def_bal_id IS NOT NULL) AND ( l_balance_value <> 0 ) THEN l_archive := 'Y';
		    ELSE  l_archive := 'N';
		    END IF;


		    IF  (l_archive = 'Y') THEN

				-- fnd_file.put_line(fnd_file.log,'l_result_value is not null ');

				pay_action_information_api.create_action_information (
				    p_action_information_id        => l_action_info_id
				   ,p_action_context_id            => p_archive_assact_id
				   ,p_action_context_type          => 'AAP'
				   ,p_object_version_number        => l_ovn
				   ,p_effective_date               => p_effective_date
				   ,p_source_id                    => NULL
				   ,p_source_text                  => NULL
				   ,p_action_information_category  => 'NO ELEMENT INFO'
				   ,p_action_information1          => csr_rec.element_type_id
				   ,p_action_information2          => csr_rec.input_value_id
				   ,p_action_information3          => csr_rec.element_context
				   ,p_action_information4          => l_result_value		--l_formatted_value
				   ,p_action_information9          => 'Main Element'
				   ,p_action_information10         => csr_rec.prim_def_bal_id
				   ,p_action_information11         => 'PBAL'
				   ,p_action_information12         => l_balance_value
				   ,p_action_information13         => l_ele_code
				   ,p_action_information14         => l_payslip_info
				   ,p_assignment_id                => p_assignment_id);

				   -- fnd_file.put_line(fnd_file.log,'******** archived = '||csr_rec.element_narrative );

		     END IF;

		    END LOOP;
		    CLOSE csr_result_value;

		    -- archive results if run result was NULL but primary balance value is not null

		   IF (l_arhive_prim_bal = 'Y') THEN

			-- though the run result is NULL, the ytd balance has a value
			-- so we will archive this result

			l_result_value := NULL ;
			l_payslip_info := NULL ;

			-- fnd_file.put_line(fnd_file.log,'LOC 5 => p_assignment_action_id , l_element_name = ' || p_assignment_action_id ||' , '||l_element_name);

			pay_action_information_api.create_action_information (
			    p_action_information_id        => l_action_info_id
			   ,p_action_context_id            => p_archive_assact_id
			   ,p_action_context_type          => 'AAP'
			   ,p_object_version_number        => l_ovn
			   ,p_effective_date               => p_effective_date
			   ,p_source_id                    => NULL
			   ,p_source_text                  => NULL
			   ,p_action_information_category  => 'NO ELEMENT INFO'
			   ,p_action_information1          => csr_rec.element_type_id
			   ,p_action_information2          => csr_rec.input_value_id
			   ,p_action_information3          => csr_rec.element_context
			   ,p_action_information4          => l_result_value		--l_formatted_value
			   ,p_action_information9          => 'Main Element'
			   ,p_action_information10         => csr_rec.prim_def_bal_id
			   ,p_action_information11         => 'PBAL'
			   ,p_action_information12         => l_balance_value
			   ,p_action_information13         => l_ele_code
			   ,p_action_information14         => l_payslip_info
			   ,p_assignment_id                => p_assignment_id);

		   END IF ;


		     EXCEPTION WHEN OTHERS THEN
			g_err_num := SQLCODE;
			/*fnd_file.put_line(fnd_file.log,'ORA_ERR: ' || g_err_num || 'In ARCHIVE_MAIN_ELEMENTS');*/

			IF g_debug THEN
				hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In ARCHIVE_MAIN_ELEMENTS',330);
			END IF;
	       END;
    END LOOP;

-- fnd_file.put_line(fnd_file.log,'finished archiving NO Earnings Elements');

 IF g_debug THEN
 	hr_utility.set_location(' Leaving Procedure ARCHIVE_MAIN_ELEMENTS',340);
 END IF;

 END ARCHIVE_MAIN_ELEMENTS;

------------------------------------ End of package ----------------------------------------------------------------

 END PAY_NO_PAYSLIP_ARCHIVE;

/
