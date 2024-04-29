--------------------------------------------------------
--  DDL for Package Body PAY_NL_PAYSLIP_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_PAYSLIP_ARCHIVE" as
/* $Header: pynlparc.pkb 120.24.12010000.6 2008/08/06 08:00:40 ubhat ship $ */

g_package                  varchar2(33) := '  PAY_NL_PAYSLIP_ARCHIVE.';


-----------------------------------------------------------------------------
-- Globals
-----------------------------------------------------------------------------
TYPE balance_rec IS RECORD (
    balance_type_id      NUMBER,
    balance_dimension_id NUMBER,
    defined_balance_id   NUMBER,
    balance_narrative    VARCHAR2(30),
    balance_name         pay_balance_types.balance_name%TYPE,
    database_item_suffix pay_balance_dimensions.database_item_suffix%TYPE,
    si_type              hr_lookups.meaning%TYPE,
    legislation_code     pay_balance_dimensions.legislation_code%TYPE);

TYPE element_rec IS RECORD (
    element_type_id      NUMBER,
    input_value_id       NUMBER,
    formula_id           NUMBER,
    si_type              hr_lookups.meaning%TYPE,
    element_narrative    VARCHAR2(30));

TYPE statutory_element_rec IS RECORD (
   classification_name  pay_element_classifications.classification_name%TYPE
  ,element_name         pay_element_types_f.element_name%TYPE
  ,element_type         VARCHAR2(1)
  ,main_index           NUMBER
  ,archive_flag		VARCHAR2(1)
  ,standard		pay_element_types_f.element_name%TYPE
  ,special		pay_element_types_f.element_name%TYPE
  ,standard2		pay_element_types_f.element_name%TYPE
  ,special2		pay_element_types_f.element_name%TYPE
  ,payable_flag		VARCHAR2(1));


TYPE balance_table   IS TABLE OF  balance_rec   INDEX BY BINARY_INTEGER;
TYPE element_table   IS TABLE OF  element_rec   INDEX BY BINARY_INTEGER;
TYPE stat_element_table IS TABLE OF statutory_element_rec
			INDEX BY BINARY_INTEGER;
--
-- Global Tables for holding Elements, User/Statutory Balances.
--
g_element_table                   element_table;
g_user_balance_table              balance_table;
g_statutory_balance_table         balance_table;
g_stat_element_table              stat_element_table;
g_zvw_er_cont_std_run NUMBER;
g_zvw_er_cont_spl_run NUMBER;
g_zvw_er_cont_std_ytd NUMBER;
g_zvw_er_cont_spl_ytd NUMBER;
g_retro_zvw_er_cont_std_run NUMBER;
g_retro_zvw_er_cont_spl_run NUMBER;
g_retro_zvw_er_cont_std_ytd NUMBER;
g_retro_zvw_er_cont_spl_ytd NUMBER;
g_travel_allowance NUMBER;
g_retro_travel_allowance NUMBER;
g_travel_allowance_ytd NUMBER;
g_retro_travel_allowance_ytd NUMBER;
g_payroll_action_id	NUMBER;

/*-------------------------------------------------------------------------------
|Name           : GET_DEFINED_BALANCE_ID                                       	|
|Type		: Function							|
|Description    : Function to get the defined balance id of the given balance 	|
|		  type and dimension						|
-------------------------------------------------------------------------------*/

FUNCTION get_defined_balance_id (p_balance_name VARCHAR2
				,p_dimension_name VARCHAR2) RETURN NUMBER AS
    --
    CURSOR csr_defined_balance_id is
    SELECT pdb.defined_balance_id
    FROM   pay_balance_dimensions pbd
          ,pay_balance_types      pbt
          ,pay_defined_balances pdb
    WHERE  pbd.database_item_suffix = p_dimension_name
    AND    pbd.business_group_id is null
    AND    pbd.legislation_code='NL'
    AND    pbt.balance_name = p_balance_name
    AND    pbt.business_group_id is null
    AND    pbt.legislation_code='NL'
    AND    pdb.balance_type_id = pbt.balance_type_id
    AND    pdb.balance_dimension_id= pbd.balance_dimension_id
    AND    pdb.business_group_id is null
    AND    pdb.legislation_code='NL';
    --
    l_defined_balance_id pay_defined_balances.defined_balance_id%TYPE;
    --
BEGIN
    --
    OPEN csr_defined_balance_id ;
        FETCH csr_defined_balance_id INTO l_defined_balance_id;
    CLOSE csr_defined_balance_id ;
    RETURN l_defined_balance_id;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
    hr_utility.set_location('get_defined_balance_id NO_DATA_FOUND'||SQLCODE||SQLERRM,2511);
    null;
    --
END get_defined_balance_id;

/*-------------------------------------------------------------------------------
|Name           : SETUP_STATUTORY_BALANCE_TABLE                                	|
|Type			: Procedure														|
|Description    : Procedure sets the global table g_statutory_balance_table.    |
-------------------------------------------------------------------------------*/
Procedure setup_statutory_balance_table(p_date_earned IN DATE, p_bg_id NUMBER) is
	--
	--
	CURSOR csr_user_stat_exists IS
	SELECT 1
	FROM pay_user_tables put
	WHERE put.legislation_code IS NULL
	AND put.business_group_id = p_bg_id
	AND put.user_table_name   = 'NL_USER_STATUTORY_BALANCES';
	--

	CURSOR csr_get_user_stat_balances(p_effecitve_date IN DATE) IS

	SELECT TRIM(user_column_name)   bal_dimension
		  ,TRIM(pur.row_low_range_or_name)   bal_name
	FROM   pay_user_columns puc
		  ,pay_user_rows_f  pur
		  ,pay_user_tables  put
		  ,pay_user_column_instances_f puci
	WHERE  put.legislation_code  IS NULL
	AND    put.business_group_id = p_bg_id
	AND    pur.user_table_id     = put.user_table_id
	AND    puc.user_table_id     = put.user_table_id
	AND    puci.user_row_id      = pur.user_row_id
	AND    puci.user_column_id   = puc.user_column_id
	AND    put.user_table_name   = 'NL_USER_STATUTORY_BALANCES'
	AND    p_effecitve_date      BETWEEN puci.effective_start_date
								 AND     puci.effective_end_date
	AND    p_effecitve_date      BETWEEN pur.effective_start_date
								 AND     pur.effective_end_date;
	--

	CURSOR csr_get_statutory_balances(p_effecitve_date IN DATE) IS

	SELECT TRIM(user_column_name)   bal_dimension
		  ,TRIM(pur.row_low_range_or_name)   bal_name
	FROM   pay_user_columns puc
		  ,pay_user_rows_f  pur
		  ,pay_user_tables  put
		  ,pay_user_column_instances_f puci
	WHERE  put.legislation_code  = 'NL'
	AND    pur.user_table_id     = put.user_table_id
	AND    puc.user_table_id     = put.user_table_id
	AND    puci.user_row_id      = pur.user_row_id
	AND    puci.user_column_id   = puc.user_column_id
	AND    put.user_table_name   = 'NL_STATUTORY_BALANCES'
	AND    p_effecitve_date      BETWEEN puci.effective_start_date
								 AND     puci.effective_end_date
	AND    p_effecitve_date      BETWEEN pur.effective_start_date
								 AND     pur.effective_end_date;
	--
	--

	l_index			NUMBER:=1;
	l_count			NUMBER:=1;
	l_user_stat_exists NUMBER:=0;

BEGIN
--
--
--
OPEN csr_user_stat_exists;
FETCH csr_user_stat_exists INTO l_user_stat_exists;
CLOSE csr_user_stat_exists;

IF l_user_stat_exists = 1 THEN
FOR stat_bal_rec IN csr_get_user_stat_balances(p_date_earned) LOOP
    g_statutory_balance_table(l_index).balance_name         := stat_bal_rec.bal_name;
    g_statutory_balance_table(l_index).database_item_suffix :=
                                            stat_bal_rec.bal_dimension;

    --hr_utility.set_location('setup_statutory_balance_table bal_name'||g_statutory_balance_table(l_index).balance_name,673);
    --hr_utility.set_location('setup_statutory_balance_table bal_dimension'||g_statutory_balance_table(l_index).database_item_suffix,673);

    g_statutory_balance_table(l_index).defined_balance_id   :=
    				get_defined_balance_id (stat_bal_rec.bal_name,stat_bal_rec.bal_dimension);

    --hr_utility.set_location('setup_statutory_balance_table defined bal id'||g_statutory_balance_table(l_index).defined_balance_id,674);
    l_index := l_index + 1;
    --
END LOOP;
END IF;
/* If no data found in NL_USER_STATUTORY_BALANCES, use NL_STATUTORY_BALANCES*/
IF l_user_stat_exists = 0 THEN
FOR stat_bal_rec IN csr_get_statutory_balances(p_date_earned) LOOP
  --
  -- Check whether this balance-dimension combination has been archived
  -- before while archiving user balances if not populate the table.


    g_statutory_balance_table(l_index).balance_name         := stat_bal_rec.bal_name;
    g_statutory_balance_table(l_index).database_item_suffix :=
                                            stat_bal_rec.bal_dimension;

    --hr_utility.set_location('setup_statutory_balance_table bal_name'||g_statutory_balance_table(l_index).balance_name,673);
    --hr_utility.set_location('setup_statutory_balance_table bal_dimension'||g_statutory_balance_table(l_index).database_item_suffix,673);


    g_statutory_balance_table(l_index).defined_balance_id   :=
    				get_defined_balance_id (stat_bal_rec.bal_name,stat_bal_rec.bal_dimension);

    --hr_utility.set_location('setup_statutory_balance_table defined bal id'||g_statutory_balance_table(l_index).defined_balance_id,674);

    l_index := l_index + 1;
    --
  /*END IF;*/
END LOOP;
END IF;
--
END;



/*-------------------------------------------------------------------------------
|Name           : GET_PARAMETER    						|
|Type		: Function							|
|Description    : Funtion used in sql to decode legislative parameters     	|
-------------------------------------------------------------------------------*/

function get_parameter(
         p_parameter_string in varchar2
        ,p_token            in varchar2
        ,p_segment_number   in number default null )    RETURN varchar2
IS

  l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
  l_start_pos  NUMBER;
  l_delimiter  varchar2(1):=' ';
  l_proc VARCHAR2(40):= g_package||' get parameter ';

BEGIN
	--
	--hr_utility.set_location('Entering get_parameter',52);
	--
	l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	--
	IF l_start_pos = 0 THEN
		l_delimiter := '|';
		l_start_pos := instr(' '||p_parameter_string,l_delimiter||p_token||'=');
	end if;

	IF l_start_pos <> 0 THEN
		l_start_pos := l_start_pos + length(p_token||'=');
		l_parameter := substr(p_parameter_string,
							  l_start_pos,
							  instr(p_parameter_string||' ',
							  l_delimiter,l_start_pos)
							  - l_start_pos);
		IF p_segment_number IS NOT NULL THEN
			l_parameter := ':'||l_parameter||':';
			l_parameter := substr(l_parameter,
								instr(l_parameter,':',1,p_segment_number)+1,
								instr(l_parameter,':',1,p_segment_number+1) -1
								- instr(l_parameter,':',1,p_segment_number));
		END IF;
	END IF;
	--
	--hr_utility.set_location('Leaving get_parameter',53);
	--hr_utility.set_location('Entering get_parameter l_parameter--'||l_parameter||'--',54);
	RETURN l_parameter;
END get_parameter;

/*-------------------------------------------------------------------------------
|Name           : GET_ALL_PARAMETERS                                           	|
|Type		: Procedure							|
|Description    : Procedure which returns all the parameters of the archive	|
|		  process						   	|
-------------------------------------------------------------------------------*/

PROCEDURE get_all_parameters(
       p_payroll_action_id                    IN   NUMBER
      ,p_business_group_id                    OUT  NOCOPY NUMBER
      ,p_start_date                           OUT  NOCOPY VARCHAR2
      ,p_end_date                             OUT  NOCOPY VARCHAR2
      ,p_effective_date                       OUT  NOCOPY DATE
      ,p_payroll_id                           OUT  NOCOPY VARCHAR2
      ,p_consolidation_set                    OUT  NOCOPY VARCHAR2) IS
--
CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS

SELECT PAY_NL_PAYSLIP_ARCHIVE.get_parameter(legislative_parameters,'PAYROLL_ID')
      ,PAY_NL_PAYSLIP_ARCHIVE.get_parameter(legislative_parameters,'CONSOLIDATION_SET_ID')
      ,PAY_NL_PAYSLIP_ARCHIVE.get_parameter(legislative_parameters,'START_DATE')
      ,PAY_NL_PAYSLIP_ARCHIVE.get_parameter(legislative_parameters,'END_DATE')
      ,effective_date
      ,business_group_id
FROM  pay_payroll_actions
WHERE payroll_action_id = p_payroll_action_id;

--

l_proc VARCHAR2(240):= g_package||' get_all_parameters ';
--
BEGIN
--
  --hr_utility.set_location('Entering get_all_parameters',51);

OPEN csr_parameter_info (p_payroll_action_id);
FETCH csr_parameter_info INTO p_payroll_id
			     ,p_consolidation_set
			     ,p_start_date
			     ,p_end_date
			     ,p_effective_date
		     	     ,p_business_group_id;
CLOSE csr_parameter_info;
--
--hr_utility.set_location('Leaving get_all_parameters',54);

END;


--
/*-------------------------------------------------------------------------------
|Name           : GET_EIT_DEFINITIONS                                       	|
|Type		: Procedure							|
|Description    : Procedure to get the Balances and Elements at the business 	|
|		  group level and archives the contexts EMEA BALANCE DEFINITION |
|		  AND EMEA ELEMENT DEFINITION					|
-------------------------------------------------------------------------------*/

PROCEDURE get_eit_definitions(p_pactid            IN NUMBER,
                              p_business_group_id IN NUMBER,
                              p_payroll_pact      IN NUMBER,
                              p_effective_date    IN DATE,
                              p_eit_context       IN VARCHAR2,
                              p_archive           IN VARCHAR2) IS

    --
    -- This cursor fetches the EIT information stored at BG level for
    -- NL_PAYSLIP_ELEMENTS/NL_PAYSLIP_BALANCES context
    --
    --
    CURSOR csr_eit_values(p_bg_id   NUMBER
                         ,p_context VARCHAR2) IS
    SELECT org.org_information1,
           org.org_information2,
           org.org_information3,
           org.org_information4
    FROM   hr_organization_information_v org
    WHERE  org.org_information_context = p_context
    AND    org.organization_id = p_bg_id;
    --
    --
    -- This cursor gets the balance information that needs to be
    -- archived/populated in global pl/sql table for later use.
    --
    --
    --
    CURSOR csr_balance_name(p_balance_type_id      NUMBER
                           ,p_balance_dimension_id NUMBER) IS
    SELECT pbt.balance_name,
           pbd.database_item_suffix,
           pbt.legislation_code,
           pdb.defined_balance_id
    FROM   pay_balance_types pbt,
           pay_balance_dimensions pbd,
           pay_defined_balances pdb
    WHERE  pdb.balance_type_id = pbt.balance_type_id
    AND    pdb.balance_dimension_id = pbd.balance_dimension_id
    AND    pbt.balance_type_id = p_balance_type_id
    AND    pbd.balance_dimension_id = p_balance_dimension_id;
    --
    --
    -- Supporting cursors for archiving EMEA_ELEMENT_DEFINITIONS
    --
    --
    --
    --Bug 3601121
    --Returns the iterative formula id defined for an element
    CURSOR csr_isgrossup_element(p_element_type_id NUMBER,
                            p_effective_date  DATE) IS
    SELECT pet.iterative_formula_id
    FROM   pay_element_types_f pet
    WHERE  pet.element_type_id = p_element_type_id
    AND    p_effective_date BETWEEN pet.effective_start_date
                            AND     pet.effective_end_date;

    CURSOR csr_input_value_uom(p_input_value_id NUMBER,
                               p_effective_date DATE) IS
    SELECT piv.uom
    FROM   pay_input_values_f piv
    WHERE  piv.input_value_id = p_input_value_id
    AND    p_effective_date   BETWEEN piv.effective_start_date
                              AND     piv.effective_end_date;

	l_element_index       PLS_INTEGER :=0;
	l_balance_index       PLS_INTEGER :=0;
	l_action_info_id 	NUMBER;
	l_formula_id		NUMBER;
	l_uom			pay_input_values.uom%TYPE;
	l_ovn			NUMBER;
	l_business_group_id	NUMBER;
	l_listed                BOOLEAN;
	v_csr_balance_name      csr_balance_name%ROWTYPE;
	l_char                  varchar2(10);
BEGIN
--
--
--hr_utility.set_location('Entering Get EIT Definitions',56);

FOR csr_eit_rec IN csr_eit_values(p_business_group_id
                                 ,p_eit_context)  LOOP
--

--hr_utility.set_location('For Each EIT Record'||p_eit_context,57);
--

IF  p_eit_context = 'NL_PAYSLIP_BALANCES' THEN
    --
    --
    OPEN
         csr_balance_name(csr_eit_rec.org_information1
                   ,csr_eit_rec.org_information2);
            FETCH csr_balance_name INTO
                      v_csr_balance_name.balance_name
                     ,v_csr_balance_name.database_item_suffix
                     ,v_csr_balance_name.legislation_code
                     ,v_csr_balance_name.defined_balance_id;
    CLOSE csr_balance_name;
    l_listed := FALSE;
    l_char := 'N';
    FOR l_index in 1..g_statutory_balance_table.count LOOP
    	IF g_statutory_balance_table(l_index).defined_balance_id = v_csr_balance_name.defined_balance_id THEN
    	    l_listed := TRUE;
    	    l_char := 'Y';
    	    EXIT;
    	END IF;
    END LOOP;

    IF l_char = 'N' THEN
		l_balance_index := l_balance_index+1;
		g_user_balance_table(l_balance_index).balance_type_id      :=
								 csr_eit_rec.org_information1;
		g_user_balance_table(l_balance_index).balance_dimension_id :=
								 csr_eit_rec.org_information2;
		g_user_balance_table(l_balance_index).si_type    :=
								 csr_eit_rec.org_information3;
		g_user_balance_table(l_balance_index).balance_narrative    :=
								 csr_eit_rec.org_information4;
		g_user_balance_table(l_balance_index).balance_name := v_csr_balance_name.balance_name;
		g_user_balance_table(l_balance_index).database_item_suffix := v_csr_balance_name.database_item_suffix;
		g_user_balance_table(l_balance_index).legislation_code := v_csr_balance_name.legislation_code;
		g_user_balance_table(l_balance_index).defined_balance_id := v_csr_balance_name.defined_balance_id;
    END IF;
	--
	--hr_utility.set_location('For NL_PAYSLIP_BALANCES'||p_eit_context,58);
	--
	--
	--
    IF  p_archive = 'Y' THEN
        --
        --hr_utility.set_location('For NL_PAYSLIP_BALANCES'||g_user_balance_table(l_balance_index).balance_name,59);
        --
        -- Archive EMEA BALANCE DEFINITION
        pay_action_information_api.create_action_information (
        p_action_information_id        =>  l_action_info_id
       ,p_action_context_id            =>  p_pactid
       ,p_action_context_type          =>  'PA'
       ,p_object_version_number        =>  l_ovn
       ,p_effective_date               =>  p_effective_date
       ,p_source_id                    =>  NULL
       ,p_source_text                  =>  NULL
       ,p_action_information_category  =>  'EMEA BALANCE DEFINITION'
       ,p_action_information1          =>  NULL
       ,p_action_information2          =>  v_csr_balance_name.defined_balance_id
       ,p_action_information4          => csr_eit_rec.org_information4
       ,p_action_information6          => csr_eit_rec.org_information3);

       --
    END IF;
    --
END IF;
--
IF  p_eit_context = 'NL_PAYSLIP_ELEMENTS' THEN
    --
    l_element_index := l_element_index + 1;
    --
    g_element_table(l_element_index).element_type_id   :=
                                csr_eit_rec.org_information1;
    g_element_table(l_element_index).input_value_id    :=
                                csr_eit_rec.org_information2;
    g_element_table(l_element_index).si_type           :=
                                csr_eit_rec.org_information3;
    g_element_table(l_element_index).element_narrative :=
                                csr_eit_rec.org_information4;

    --

    --hr_utility.set_location('For NL_PAYSLIP_ELEMENTS'||g_element_table(l_element_index).element_type_id,59);
    --
    l_formula_id := NULL;
    --Bug 3601121
    --Fetch the iterative formula id defined for an element

    g_element_table(l_element_index).formula_id := l_formula_id;
    --hr_utility.set_location('For NL_PAYSLIP_ELEMENTS'||g_element_table(l_element_index).formula_id,59);
    --
    OPEN csr_input_value_uom(csr_eit_rec.org_information2
                            ,p_effective_date);
        FETCH csr_input_value_uom INTO l_uom;
    CLOSE csr_input_value_uom;
    --
    --hr_utility.set_location('For NL_PAYSLIP_ELEMENTS'||l_uom,59);
    IF  p_archive = 'Y' THEN
        --
        -- Archive EMEA ELEMENT DEFINITION
        --
        --hr_utility.set_location('calling api for NL_PAYSLIP_ELEMENTS'||g_element_table(l_element_index).element_type_id,59);
        --hr_utility.set_location('calling api for NL_PAYSLIP_ELEMENTS'||g_element_table(l_element_index).input_value_id,59);
        --hr_utility.set_location('calling api for NL_PAYSLIP_ELEMENTS'||g_element_table(l_element_index).element_narrative,59);
        --hr_utility.set_location('calling api for NL_PAYSLIP_ELEMENTS'||g_element_table(l_element_index).si_type,59);
        --hr_utility.set_location('calling api for NL_PAYSLIP_ELEMENTS'||l_uom,59);
        --
        pay_action_information_api.create_action_information (
             p_action_information_id        =>  l_action_info_id
            ,p_action_context_id            =>  p_pactid
            ,p_action_context_type          =>  'PA'
            ,p_object_version_number        =>  l_ovn
            ,p_effective_date               =>  p_effective_date
            ,p_source_id                    =>  NULL
            ,p_source_text                  =>  NULL
            ,p_action_information_category  =>  'EMEA ELEMENT DEFINITION'
            ,p_action_information1          =>  NULL
            ,p_action_information2          =>	g_element_table(l_element_index).element_type_id
            ,p_action_information3          =>	g_element_table(l_element_index).input_value_id
            ,p_action_information4          =>	g_element_table(l_element_index).element_narrative
			,p_action_information5          => 'F'
			,p_action_information6          =>  l_uom
			,p_action_information7          =>  g_element_table(l_element_index).si_type);


    --
    --hr_utility.set_location('Leaving NL_PAYSLIP_ELEMENTS'||l_action_info_id,59);
    --
    END IF;
    --
END IF;
--
--
END LOOP;
--
--
END get_eit_definitions;

/*-------------------------------------------------------------------------------
|Name           : RANGE_CODE                                       		|
|Type		: Procedure							|
|Description    : This procedure returns a sql string to select a range of 	|
|		  assignments eligible for archival		  		|
-------------------------------------------------------------------------------*/

Procedure RANGE_CODE (pactid    IN    NUMBER
                     ,sqlstr    OUT   NOCOPY VARCHAR2) is

	--
	--
	CURSOR csr_payrolls (p_payroll_id           NUMBER
						,p_consolidation_set_id NUMBER
						,p_effective_date       DATE) IS
	SELECT ppf.payroll_id
	FROM   pay_all_payrolls_f ppf
	WHERE  ppf.consolidation_set_id = p_consolidation_set_id
	AND    ppf.payroll_id = NVL(p_payroll_id,ppf.payroll_id)
	AND    p_effective_date BETWEEN ppf.effective_start_date
							AND     ppf.effective_end_date;


	-- This Cursor drives the archival of 'EMEA PAYROLL INFO' context.
	-- The Tax Office Name and Tax Ref No needs to be archived.
	-- It should only be archived if it has not be archived for this archive
	-- action.

	CURSOR csr_hr_org_info(p_bus_group_id     NUMBER
						   ,p_pact_id         NUMBER
						  ) IS
	SELECT hoi_tax.organization_id          org_id
		  ,hou1.name                        tax_office_name
		  ,hoi_tax.org_information4         reg_no
	FROM   hr_all_organization_units        hou
		  ,hr_all_organization_units        hou1
		  ,hr_organization_information      hoi
		  ,hr_organization_information      hoi_tax
	WHERE  hoi.org_information_context      = 'CLASS'
	AND    hoi.org_information1             = 'HR_ORG'
	AND    hoi.organization_id              =  HOU.organization_id
	AND    hou.business_group_id            =  p_bus_group_id
	AND    hoi_tax.organization_id          =  hoi.organization_id
	AND    hoi_tax.org_information_context  = 'NL_ORG_INFORMATION'
	AND    hoi_tax.org_information4         IS NOT NULL
	AND    hou1.business_group_id            =  p_bus_group_id
	AND    hou1.organization_id              =  hoi_tax.org_information3
	AND    hoi_tax.org_information3 IS NOT NULL
	AND    NOT EXISTS (SELECT NULL
					   FROM   pay_action_information  pai
					   WHERE  pai.action_context_id   = p_pact_id
					   AND    pai.action_context_type = 'PA'
					   AND    pai.action_information_category ='EMEA PAYROLL INFO'
					   AND    pai.action_information1 = hoi_tax.organization_id);

	--
	--
	--
	  CURSOR csr_payroll_mesg (p_payroll_id       NUMBER,
							   p_start_date       DATE,
							   p_end_date         DATE) IS
	  SELECT pact.payroll_action_id     payroll_action_id
			 ,pact.effective_date       effective_date
			 ,pact.date_earned          date_earned
			 ,pact.pay_advice_message   payroll_message
	  FROM   pay_payrolls_f             ppf,
			 pay_payroll_actions        pact
	  WHERE  pact.payroll_id            = ppf.payroll_id
	  AND    pact.effective_date        BETWEEN ppf.effective_start_date
										AND     ppf.effective_end_date
	  AND    pact.payroll_id            = p_payroll_id
	  AND    pact.effective_date        BETWEEN p_start_date
										AND     p_end_date
	  AND    pact.action_type IN ('R','Q')
	  AND    pact.action_status = 'C'
	  AND    NOT EXISTS (
					 SELECT NULL
					 FROM   pay_action_information    pai
					 WHERE  pai.action_context_id     = pactid
					 AND    pai.action_context_type   = 'PA'
					 AND    pai.action_information_category ='EMPLOYEE OTHER INFORMATION');
	--
	--
	l_business_group_id		NUMBER;
	l_start_date            	VARCHAR2(240);
	l_end_date              	VARCHAR2(240);
	l_canonical_start_date		DATE;
	l_canonical_end_date    	DATE;
	l_effective_date		DATE;
	l_payroll_id			NUMBER;
	l_consolidation_set		NUMBER;
	l_action_info_id		NUMBER;
	l_ovn				NUMBER;

	--l_payroll_id_char		VARCHAR2(60);
	--l_consolidation_set_char	VARCHAR2(60);
	--
	--

Begin

	  --
	  --hr_utility.trace_on(NULL,'PSA');
	  --hr_utility.set_location('Entering Range Code',50);
	  --
	  pay_nl_payslip_archive.get_all_parameters(pactid
				,l_business_group_id
				,l_start_date
				,l_end_date
				,l_effective_date
				,l_payroll_id
				,l_consolidation_set);

	  l_canonical_start_date := TO_DATE(l_start_date,'YYYY/MM/DD');
	  l_canonical_end_date   := TO_DATE(l_end_date,'YYYY/MM/DD');


	  --
	  g_payroll_action_id:=pactid;
	  --hr_utility.set_location('g_payroll_action_id    = ' || g_payroll_action_id,55);
	  --hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,55);
	  --hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,55);
	  --hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,55);
	  --hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,55);
	  --
	  --

	  -- Setup statutory balances pl/sql table
	  IF g_statutory_balance_table.count = 0 THEN
		  setup_statutory_balance_table(l_canonical_start_date,l_business_group_id);
	  END IF;
	  --

	  -- Populates the global PL/SQL Table with Balance information and archives
	  -- EMEA BALANCE DEFINITION Context
	  --
	  pay_nl_payslip_archive.get_eit_definitions (
		p_pactid            => pactid
	  , p_business_group_id => l_business_group_id
	  , p_payroll_pact      => NULL
	  , p_effective_date    => l_canonical_start_date
	  , p_eit_context       => 'NL_PAYSLIP_BALANCES'
	  , p_archive           => 'Y');
	  --
	  --
	  --hr_utility.set_location('Inside Range Code',60);

	  -- Populates the global PL/SQL Table with Element information and archives
	  -- EMEA ELEMENT DEFINITION Context
	  --
	  pay_nl_payslip_archive.get_eit_definitions (
		p_pactid            => pactid
	  , p_business_group_id => l_business_group_id
	  , p_payroll_pact      => NULL
	  , p_effective_date    => l_canonical_start_date
	  , p_eit_context       => 'NL_PAYSLIP_ELEMENTS'
	  , p_archive           => 'Y');

	  --hr_utility.set_location('Inside Range Code',70);
	--
	FOR rec_payrolls in csr_payrolls(l_payroll_id
									,l_consolidation_set
									,l_canonical_end_date)  LOOP
	--hr_utility.set_location('Inside csr_payrolls loop',75);

		pay_emp_action_arch.arch_pay_action_level_data (
								 p_payroll_action_id => pactid
								,p_payroll_id        => rec_payrolls.payroll_id
								,p_effective_date    => l_canonical_end_date);
								null;
	--
	END LOOP;

	--hr_utility.set_location('Inside Range Code',80);

	FOR hr_org_info_rec in csr_hr_org_info (l_business_group_id
										   ,pactid)
	LOOP

		--hr_utility.set_location('Inside Range Code loop hr_org_info_rec.org_id'||hr_org_info_rec.org_id,90);
		--
		-- Archiving EMEA PAYROLL INFO context
		--
		pay_action_information_api.create_action_information (
		p_action_information_id        =>  l_action_info_id
		, p_action_context_id            =>  pactid
		, p_action_context_type          =>  'PA'
		, p_object_version_number        =>  l_ovn
		, p_effective_date               =>  l_effective_date
		, p_source_id                    =>  NULL
		, p_source_text                  =>  NULL
		, p_action_information_category  =>  'EMEA PAYROLL INFO'
		, p_action_information1          =>  pactid
		, p_action_information2          =>  hr_org_info_rec.org_id
		, p_action_information3          =>  NULL
		, p_action_information4          =>  hr_org_info_rec.tax_office_name
		, p_action_information5          =>  NULL
		, p_action_information6          =>  hr_org_info_rec.reg_no);

	 END LOOP;

	 --hr_utility.set_location('pactid'||pactid,100);

	FOR rec_payroll_msg in csr_payroll_mesg(l_payroll_id
		  ,l_canonical_start_date
		  ,l_canonical_end_date)
	LOOP
		--hr_utility.set_location('coming inside loop'||rec_payroll_msg.payroll_action_id,200);
		--
		IF rec_payroll_msg.payroll_message IS NOT NULL THEN
			--
			pay_action_information_api.create_action_information (
			p_action_information_id        =>  l_action_info_id
			, p_action_context_id            =>  pactid
			, p_action_context_type          =>  'PA'
			, p_object_version_number        =>  l_ovn
			, p_effective_date               =>  rec_payroll_msg.effective_date
			, p_source_id                    =>  NULL
			, p_source_text                  =>  NULL
			, p_action_information_category  =>  'EMPLOYEE OTHER INFORMATION'
			, p_action_information1          =>  rec_payroll_msg.payroll_action_id
			, p_action_information2          =>  'MESG'
			, p_action_information3          =>  NULL
			, p_action_information4          =>  NULL
			, p_action_information5          =>  NULL
			, p_action_information6          =>  rec_payroll_msg.payroll_message);
			--
			null;
		END IF;
		--
	END LOOP;
	--hr_utility.set_location('outside loop',300);

	sqlstr := 'SELECT DISTINCT person_id
	FROM  per_people_f ppf
		 ,pay_payroll_actions ppa
	WHERE ppa.payroll_action_id = :payroll_action_id
	AND   ppa.business_group_id = ppf.business_group_id
	ORDER BY ppf.person_id';

	--hr_utility.set_location('Leaving Range Code',350);

EXCEPTION

	WHEN OTHERS THEN
	-- Return cursor that selects no rows
	sqlstr := 'select 1 from dual where to_char(:payroll_action_id) = dummy';



END RANGE_CODE;

/*-------------------------------------------------------------------------------
|Name           : ASSIGNMENT_ACTION_CODE                                      	|
|Type			: Procedure														|
|Description    : This procedure further restricts the assignment id's returned |
|		  		  by the range code. It locks all the completed Prepayments/	|
|		  		  Quickpay Prepayments in the specified period					|
-------------------------------------------------------------------------------*/

Procedure ASSIGNMENT_ACTION_CODE (p_payroll_action_id  in number
				  ,p_start_person_id   in number
				  ,p_end_person_id     in number
				  ,p_chunk             in number) IS

	-- Cursor to retrieve all Prepayment/Quickpay Prepayment assignment actions
	-- during the specified period

	CURSOR csr_prepaid_assignments(p_pact_id          	NUMBER,
									stperson           	NUMBER,
									endperson          	NUMBER,
									p_payroll_id       	NUMBER,
									p_consolidation_id 	NUMBER,
									l_canonical_start_date	DATE,
									l_canonical_end_date	DATE) IS
	-- Andy's changes for bug 5107780
	SELECT /*+ ORDERED
                   INDEX(ppa PAY_PAYROLL_ACTIONS_PK)
                   INDEX(as1 PER_ASSIGNMENTS_F_N12)
                   INDEX(ppf PAY_PAYROLLS_F_PK)
                   INDEX(act PAY_ASSIGNMENT_ACTIONS_N51)
                   INDEX(appa PAY_PAYROLL_ACTIONS_PK)
                   INDEX(pai PAY_ACTION_INTERLOCKS_FK2)
                   INDEX(act1 PAY_ASSIGNMENT_ACTIONS_PK)
                   INDEX(appa2 PAY_PAYROLL_ACTIONS_PK)
                   USE_NL(ppa as1 ppf act appa pai act1 appa2) */
                act.assignment_id            assignment_id,
		act.assignment_action_id     run_action_id,
		act1.assignment_action_id    prepaid_action_id
	FROM   pay_payroll_actions          ppa,
	       per_all_assignments_f        as1,
	       pay_assignment_actions       act,
	       pay_payroll_actions          appa,
	       pay_action_interlocks        pai,
	       pay_assignment_actions       act1,
	       pay_payroll_actions          appa2,
	       pay_payrolls_f               ppf
	WHERE  ppa.payroll_action_id        = p_pact_id
	AND    appa.consolidation_set_id    = p_consolidation_id
	AND    appa.effective_date  BETWEEN l_canonical_start_date 	AND     l_canonical_end_date
	AND    as1.person_id        BETWEEN stperson AND     endperson
	AND    appa.action_type             IN ('R','Q')
	-- Payroll Run or Quickpay Run
	AND    act.payroll_action_id        = appa.payroll_action_id
	AND    act.source_action_id         IS NULL -- Master Action
	AND    as1.assignment_id            = act.assignment_id
	AND    ppa.business_group_id        = as1.business_group_id
	AND    ppa.effective_date           BETWEEN as1.effective_start_date AND as1.effective_end_date
	AND    act.action_status            = 'C'  -- Completed
	AND    act.assignment_action_id     = pai.locked_action_id
	AND    appa2.payroll_id 			= ppf.payroll_id
	AND    ppf.business_group_id        = as1.business_group_id
	AND    ppa.effective_date           BETWEEN ppf.effective_start_date AND ppf.effective_end_date
	AND    act1.assignment_action_id    = pai.locking_action_id
	AND    act1.action_status           = 'C' -- Completed
	AND  ((ppf.Multi_Assignments_Flag='Y' AND act1.source_action_id IS NOT NULL)
	OR (ppf.Multi_Assignments_Flag='N' AND act1.source_action_id IS NULL))
	AND    act1.payroll_action_id       = appa2.payroll_action_id
	AND    appa2.action_type            IN ('P','U')
	AND    appa2.effective_date          BETWEEN l_canonical_start_date
	AND     l_canonical_end_date
	-- Prepayments or Quickpay Prepayments
	AND    (as1.payroll_id = p_payroll_id OR p_payroll_id IS NULL)
	AND    NOT EXISTS (SELECT /*+ ORDERED */ NULL
	FROM   pay_action_interlocks      pai1,
	pay_assignment_actions     act2,
	pay_payroll_actions        appa3
	WHERE  pai1.locked_action_id    = act.assignment_action_id
	AND    act2.assignment_action_id= pai1.locking_action_id
	AND    act2.payroll_action_id   = appa3.payroll_action_id
	AND    appa3.action_type        = 'X'
	AND    appa3.action_status      = 'C'
	AND    appa3.report_type        = 'NL_PS_ARCHIVE')
	AND  NOT EXISTS (  SELECT /*+ ORDERED */ NULL
	FROM   pay_action_interlocks      pai1,
	pay_assignment_actions     act2,
	pay_payroll_actions        appa3
	WHERE  pai1.locked_action_id    = act.assignment_action_id
	AND    act2.assignment_action_id= pai1.locking_action_id
	AND    act2.payroll_action_id   = appa3.payroll_action_id
	AND    appa3.action_type        = 'V'
	AND    appa3.action_status      = 'C')
	--group by act.assignment_id,act1.assignment_action_id
	ORDER BY act.assignment_id,act1.assignment_Action_id;
	-- End Andy's changes for bug 5107780

	--Bug 3384315
	CURSOR 	get_prepayment_child_action(p_source_action_id	NUMBER
										,p_assignment_id	NUMBER) IS
	select paa.assignment_action_id
	from pay_assignment_Actions paa
	,pay_assignment_Actions paa1
	where paa.source_action_id=p_source_action_id
	and paa1.assignment_id <> p_assignment_id
	and paa.assignment_id=p_assignment_id
	and paa1.assignment_action_id=p_source_action_id;

	l_business_group_id	NUMBER;
	l_start_date            VARCHAR2(240);
	l_end_date              VARCHAR2(240);
	l_canonical_start_date	DATE;
	l_canonical_end_date    DATE;
	l_effective_date	DATE;
	l_payroll_id		NUMBER;
	l_consolidation_set	NUMBER;
	l_prepay_action_id	NUMBER;
	l_actid			NUMBER;
	l_child_action_id	NUMBER;
	csr_rec csr_prepaid_assignments%ROWTYPE;

BEGIN
	--
	--hr_utility.trace_on(NULL,'PSA');
	--hr_utility.set_location('Entering Assignment Action Code',400);
	--


	pay_nl_payslip_archive.get_all_parameters(p_payroll_action_id
	,l_business_group_id,l_start_date,l_end_date
	,l_effective_date,l_payroll_id,l_consolidation_set);

	--
	l_canonical_start_date := TO_DATE(l_start_date,'YYYY/MM/DD');
	l_canonical_end_date   := TO_DATE(l_end_date,'YYYY/MM/DD');


	l_prepay_action_id := 0;
	--
	--hr_utility.set_location('Archive p_payroll_action_id'||p_payroll_action_id,425);
	--hr_utility.set_location('Archive p_start_person_id'||p_start_person_id,425);
	--hr_utility.set_location('Archive p_end_person_id'||p_end_person_id,425);
	--hr_utility.set_location('Archive l_payroll_id'||l_payroll_id,425);
	--hr_utility.set_location('Archive l_consolidation_set'||l_consolidation_set,425);
	--hr_utility.set_location('Archive l_canonical_start_date'||l_canonical_start_date,425);
	--hr_utility.set_location('Archive l_canonical_end_date'||l_canonical_end_date,425);

	--
	OPEN csr_prepaid_assignments(p_payroll_action_id
	,p_start_person_id,p_end_person_id,l_payroll_id,l_consolidation_set
	,l_canonical_start_date,l_canonical_end_date) ;
	LOOP
		--
		FETCH csr_prepaid_assignments into csr_rec;
		EXIT WHEN csr_prepaid_assignments%NOTFOUND;

		IF l_prepay_action_id <> csr_rec.prepaid_action_id THEN
			--

			SELECT pay_assignment_actions_s.NEXTVAL
			INTO   l_actid
			FROM   dual;
			--
			-- Create the archive assignment action
			--
			--Bug 3384315
			l_child_action_id:=NULL;
			OPEN get_prepayment_child_action(csr_rec.prepaid_action_id,csr_rec.assignment_id);
			FETCH get_prepayment_child_action INTO l_child_action_id;
			CLOSE get_prepayment_child_action;

			--hr_utility.set_location('Archive l_prepay_action_id'||l_prepay_action_id,425);
			--hr_utility.set_location('Archive l_child_action_id'||l_child_action_id,425);


			l_prepay_action_id := nvl(l_child_action_id,csr_rec.prepaid_action_id);

			hr_utility.set_location('Archive l_prepay_action_id'||l_prepay_action_id,425);
			hr_utility.set_location('Archive csr_rec.prepaid_action_id'||csr_rec.prepaid_action_id,425);

			hr_utility.set_location('Archive Assignment Action Id'||l_actid,450);

			hr_nonrun_asact.insact(l_actid,csr_rec.assignment_id,
			p_payroll_action_id,p_chunk,NULL);
			--
			hr_utility.set_location('Archive Assignment Action Id'||l_actid,450);
			hr_utility.set_location('Archive Assignment Id'||csr_rec.assignment_id,450);
			hr_utility.set_location('Archive Payroll Action Id'||p_payroll_action_id,450);

			-- Create archive to prepayment assignment action interlock
			--
			hr_nonrun_asact.insint(l_actid,l_prepay_action_id);
			--
		END IF;
		hr_utility.set_location('Archive Assignment Action Id'||l_actid,475);
		hr_utility.set_location('Archive Assignment run_action_id Id'||csr_rec.run_action_id,475);
		-- Create archive to payroll master action interlock
		hr_nonrun_asact.insint(l_actid,csr_rec.run_action_id);
		--  l_prepay_action_id := csr_rec.prepaid_action_id;
		--
	END LOOP;

	--
	--hr_utility.set_location('Leaving Assignment Action Code',500);
	--
END ASSIGNMENT_ACTION_CODE;



/*-------------------------------------------------------------------------------
|Name           : SETUP_ELEMENT_TABLE                                		|
|Type		: Procedure							|
|Description    : Procedure sets the global table g_stat_element_table.		|
-------------------------------------------------------------------------------*/

PROCEDURE setup_element_table IS

BEGIN
    --
    -- Setup Statutory Element Table and their display squence in
    -- Payments and Deduction section of the reports.
    --
    -- Section 1
    g_stat_element_table(1).classification_name := 'Earnings';
    g_stat_element_table(1).element_name        := NULL;
    g_stat_element_table(1).element_type        := 'E';
    g_stat_element_table(1).main_index          := 10000;
    g_stat_element_table(1).archive_flag        := 'Y';
    g_stat_element_table(1).standard            := 'Subject to Standard Tax : Earnings';
    g_stat_element_table(1).special		:= 'Subject to Special Tax : Earnings';
    g_stat_element_table(1).payable_flag        := 'Y';
    -- Section 3
    g_stat_element_table(2).classification_name := 'Imputed Earnings';
    g_stat_element_table(2).element_name        := NULL;
    g_stat_element_table(2).element_type        := NULL;
    g_stat_element_table(2).main_index          := 12000;
    g_stat_element_table(2).archive_flag        := 'Y';
    g_stat_element_table(2).standard            := 'SI Income Subject to Standard Tax : Imputed Earnings';
    g_stat_element_table(2).special            := 'SI Income Subject to Special Tax : Imputed Earnings';
    g_stat_element_table(2).standard2           := 'Subject to Standard Tax : Imputed Earnings';
    g_stat_element_table(2).special2        := 'Subject to Special Tax : Imputed Earnings';
    g_stat_element_table(2).payable_flag        := 'N';

    -- Section 4
    g_stat_element_table(3).classification_name := 'Pre-SI and Pre-Tax Deductions';
    g_stat_element_table(3).element_name        := NULL;
    g_stat_element_table(3).element_type        := 'D';
    g_stat_element_table(3).main_index          := 13000;
    g_stat_element_table(3).archive_flag        := 'Y';
    g_stat_element_table(3).standard            := 'SI Income Standard Deduction : Pre-SI and Pre-Tax Deductions';
    g_stat_element_table(3).special    := 'SI Income Special Deduction : Pre-SI and Pre-Tax Deductions';
    g_stat_element_table(3).payable_flag        := 'Y';

    -- Section 11
    g_stat_element_table(4).classification_name := 'Pre-Tax Deductions';
    g_stat_element_table(4).element_name        := NULL;
    g_stat_element_table(4).element_type        := 'D';
    g_stat_element_table(4).main_index          := 20000;
    g_stat_element_table(4).archive_flag        := 'Y';
    g_stat_element_table(4).standard            := 'Standard Tax Deduction : Pre-Tax Deductions';
    g_stat_element_table(4).special    := 'Special Tax Deduction : Pre-Tax Deductions';
    g_stat_element_table(4).payable_flag        := 'Y';

    -- Section 11
    g_stat_element_table(5).classification_name := 'Reductions';
    g_stat_element_table(5).element_name        := NULL;
    g_stat_element_table(5).element_type        := NULL;
    g_stat_element_table(5).main_index          := 14500;
    g_stat_element_table(5).archive_flag        := 'Y';
    g_stat_element_table(5).standard            := 'Standard Tax Reduction : Reductions';
    g_stat_element_table(5).special    := 'Special Tax Reduction : Reductions';
    g_stat_element_table(5).standard2           := 'SI Income Standard Tax Reduction : Reductions';
    g_stat_element_table(5).special2    := 'SI Income Special Tax Reduction : Reductions';
    g_stat_element_table(5).payable_flag        := 'N';

    --Section 12a
    g_stat_element_table(6).classification_name := 'Earnings';
    g_stat_element_table(6).element_name        := 'Employer ZVW Contribution Standard Tax';
    g_stat_element_table(6).element_type        := 'E';
    g_stat_element_table(6).main_index          := 18700;
    g_stat_element_table(6).archive_flag        := 'N';
    g_stat_element_table(6).standard            := 'Subject to Standard Tax : Earnings';
    g_stat_element_table(6).special    := '';
    g_stat_element_table(6).payable_flag        := 'Y';

    --Section 12b
    g_stat_element_table(7).classification_name := 'Earnings';
    g_stat_element_table(7).element_name        := 'Employer ZVW Contribution Special Tax';
    g_stat_element_table(7).element_type        := 'E';
    g_stat_element_table(7).main_index          := 18700;
    g_stat_element_table(7).archive_flag        := 'N';
    g_stat_element_table(7).standard            := '';
    g_stat_element_table(7).special    := 'Subject to Special Tax : Earnings';
    g_stat_element_table(7).payable_flag        := 'Y';

     -- Section 14a
    g_stat_element_table(8).classification_name := 'Employee Tax';
    g_stat_element_table(8).element_name        := 'Standard Tax Deduction';
    g_stat_element_table(8).element_type        := 'D';
    g_stat_element_table(8).main_index          := 23000;
    g_stat_element_table(8).archive_flag        := 'N';
    g_stat_element_table(8).standard            := '';
    g_stat_element_table(8).special    := '';
    g_stat_element_table(8).payable_flag        := 'Y';
    -- Section 14b
    g_stat_element_table(9).classification_name := 'Employee Tax';
    g_stat_element_table(9).element_name        := 'Special Tax Deduction';
    g_stat_element_table(9).element_type        := 'D';
    g_stat_element_table(9).main_index          := 24000;
    g_stat_element_table(9).archive_flag        := 'N';
    g_stat_element_table(9).standard            := '';
    g_stat_element_table(9).special    := '';
    g_stat_element_table(9).payable_flag        := 'Y';
    -- Section 14c
    g_stat_element_table(10).classification_name := 'Employee Tax';
    g_stat_element_table(10).element_name        := 'Beneficial Rule Special Tax Adjustment';
    g_stat_element_table(10).element_type        := 'D';
    g_stat_element_table(10).main_index          := 25000;
    g_stat_element_table(10).archive_flag        := 'N';
    g_stat_element_table(10).standard            := '';
    g_stat_element_table(10).special    := '';
    g_stat_element_table(10).payable_flag        := 'Y';
    --
    -- Bug 6447814 starts
    -- To include Employee Tax elements under Payments and Deductions Section of the Payslip.
    g_stat_element_table(11).classification_name := 'Employee Tax';
    g_stat_element_table(11).element_name        := NULL;
    g_stat_element_table(11).element_type        := 'D';
    g_stat_element_table(11).main_index          := 25100;
    g_stat_element_table(11).archive_flag        := 'N';
    g_stat_element_table(11).standard            := '';
    g_stat_element_table(11).special    := '';
    g_stat_element_table(11).payable_flag        := 'Y';
    -- Bug 6447814 Ends
    --
    -- Section 15
    g_stat_element_table(12).classification_name := 'Involuntary Deductions';
    g_stat_element_table(12).element_name        := NULL;
    g_stat_element_table(12).element_type        := 'D';
    g_stat_element_table(12).main_index          := 26000;
    g_stat_element_table(12).archive_flag        := 'Y';
    g_stat_element_table(12).standard            := '';
    g_stat_element_table(12).special    := '';
    g_stat_element_table(12).payable_flag        := 'Y';
    -- Section 16
    g_stat_element_table(13).classification_name := 'Voluntary Deductions';
    g_stat_element_table(13).element_name        := NULL;
    g_stat_element_table(13).element_type        := 'D';
    g_stat_element_table(13).main_index          := 27000;
    g_stat_element_table(13).archive_flag        := 'Y';
    g_stat_element_table(13).standard            := '';
    g_stat_element_table(13).special    := '';
    g_stat_element_table(13).payable_flag        := 'Y';
    -- Section 17
    g_stat_element_table(14).classification_name := 'Net Earnings';
    g_stat_element_table(14).element_name        := NULL;
    g_stat_element_table(14).element_type        := 'E';
    g_stat_element_table(14).main_index          := 28000;
    g_stat_element_table(14).archive_flag        := 'Y';
    g_stat_element_table(14).standard            := '';
    g_stat_element_table(14).special    := '';
    g_stat_element_table(14).payable_flag        := 'Y';

    -- Section 1
    g_stat_element_table(15).classification_name := 'Retro Earnings';
    g_stat_element_table(15).element_name        := NULL;
    g_stat_element_table(15).element_type        := 'E';
    g_stat_element_table(15).main_index          := 10500;
    g_stat_element_table(15).archive_flag        := 'Y';
    g_stat_element_table(15).standard            := 'Subject to Standard Tax : Retro Earnings';
    g_stat_element_table(15).special     := 'Subject to Special Tax : Retro Earnings';
    g_stat_element_table(15).payable_flag        := 'Y';
    -- Section 3
    g_stat_element_table(16).classification_name := 'Retro Imputed Earnings';
    g_stat_element_table(16).element_name        := NULL;
    g_stat_element_table(16).element_type        := NULL;
    g_stat_element_table(16).main_index          := 12500;
    g_stat_element_table(16).archive_flag        := 'Y';
    g_stat_element_table(16).standard            := 'SI Income Subject to Standard Tax : Retro Imputed Earnings';
    g_stat_element_table(16).special    := 'SI Income Subject to Special Tax : Retro Imputed Earnings';
    g_stat_element_table(16).standard2            := 'Subject to Standard Tax : Retro Imputed Earnings';
    g_stat_element_table(16).special2    := 'Subject to Special Tax : Retro Imputed Earnings';
    g_stat_element_table(16).payable_flag        := 'N';

    -- Section 4
    g_stat_element_table(17).classification_name := 'Retro Pre SI and Pre Tax Deductions';
    g_stat_element_table(17).element_name        := NULL;
    g_stat_element_table(17).element_type        := 'D';
    g_stat_element_table(17).main_index          := 13500;
    g_stat_element_table(17).archive_flag        := 'Y';
    g_stat_element_table(17).standard            := 'SI Income Standard Tax : Retro Pre SI and Pre Tax Deductions';
    g_stat_element_table(17).special    := 'SI Income Special Tax : Retro Pre SI and Pre Tax Deductions';
    g_stat_element_table(17).payable_flag        := 'Y';

    -- Section 11
    g_stat_element_table(18).classification_name := 'Retro Pre Tax Deductions';
    g_stat_element_table(18).element_name        := NULL;
    g_stat_element_table(18).element_type        := 'D';
    g_stat_element_table(18).main_index          := 20500;
    g_stat_element_table(18).archive_flag        := 'Y';
    g_stat_element_table(18).standard            := 'Standard Tax Deduction : Retro Pre Tax Deductions';
    g_stat_element_table(18).special    := 'Special Tax Deduction : Retro Pre Tax Deductions';
    g_stat_element_table(18).payable_flag        := 'Y';

    g_stat_element_table(19).classification_name := 'Retro Reductions';
    g_stat_element_table(19).element_name        := NULL;
    g_stat_element_table(19).element_type        := NULL;
    g_stat_element_table(19).main_index          := 14600;
    g_stat_element_table(19).archive_flag        := 'Y';
    g_stat_element_table(19).standard            := 'Standard Tax Reduction : Retro Reductions';
    g_stat_element_table(19).special     := 'Special Tax Reduction : Retro Reductions';
    g_stat_element_table(19).standard2           := 'SI Income Standard Tax Reduction : Retro Reductions';
    g_stat_element_table(19).special2     := 'SI Income Special Tax Reduction : Retro Reductions';
    g_stat_element_table(19).payable_flag        := 'N';

    -- Section 12a
    g_stat_element_table(20).classification_name := 'Retro Earnings';
    g_stat_element_table(20).element_name        := 'Retro Employer ZVW Contribution Standard Tax';
    g_stat_element_table(20).element_type        := 'E';
    g_stat_element_table(20).main_index          := 18750;
    g_stat_element_table(20).archive_flag        := 'N';
    g_stat_element_table(20).standard            := 'Subject to Standard Tax : Retro Earnings';
    g_stat_element_table(20).special     := '';
    g_stat_element_table(20).payable_flag        := 'Y';

        -- Section 12a
    g_stat_element_table(21).classification_name := 'Retro Earnings';
    g_stat_element_table(21).element_name        := 'Retro Employer ZVW Contribution Special Tax';
    g_stat_element_table(21).element_type        := 'E';
    g_stat_element_table(21).main_index          := 18750;
    g_stat_element_table(21).archive_flag        := 'N';
    g_stat_element_table(21).standard            := '';
    g_stat_element_table(21).special     := 'Subject to Special Tax : Retro Earnings';
    g_stat_element_table(21).payable_flag        := 'Y';

    -- Section 14a
    g_stat_element_table(22).classification_name := 'Retro Employee Deductions';
    g_stat_element_table(22).element_name        := 'Retro Standard Tax Deduction';
    g_stat_element_table(22).element_type        := 'D';
    g_stat_element_table(22).main_index          := 23500;
    g_stat_element_table(22).archive_flag        := 'N';
    g_stat_element_table(22).standard            := '';
    g_stat_element_table(22).special       := '';
    g_stat_element_table(22).payable_flag        := 'Y';
    -- Section 14a
    g_stat_element_table(23).classification_name := 'Retro Employee Deductions';
    g_stat_element_table(23).element_name        := 'Retro Standard Tax Deduction Current Quarter';
    g_stat_element_table(23).element_type        := 'D';
    g_stat_element_table(23).main_index          := 23500;
    g_stat_element_table(23).archive_flag        := 'N';
    g_stat_element_table(23).standard            := '';
    g_stat_element_table(23).special     := '';
    g_stat_element_table(23).payable_flag        := 'Y';

    -- Section 14b
    g_stat_element_table(24).classification_name := 'Retro Employee Deductions';
    g_stat_element_table(24).element_name        := 'Retro Special Tax Deduction';
    g_stat_element_table(24).element_type        := 'D';
    g_stat_element_table(24).main_index          := 24500;
    g_stat_element_table(24).archive_flag        := 'N';
    g_stat_element_table(24).standard            := '';
    g_stat_element_table(24).special     := '';
    g_stat_element_table(24).payable_flag        := 'Y';
    -- Section 14c
    g_stat_element_table(25).classification_name := 'Retro Employee Deductions';
    g_stat_element_table(25).element_name        := 'Retro Beneficial Rule Special Tax Adjustment';
    g_stat_element_table(25).element_type        := 'D';
    g_stat_element_table(25).main_index          := 25500;
    g_stat_element_table(25).archive_flag        := 'N';
    g_stat_element_table(25).standard            := '';
    g_stat_element_table(25).special     := '';
    g_stat_element_table(25).payable_flag        := 'Y';

-- Bug 5957039
-- to place after ZVW Employer Contribution
    g_stat_element_table(26).classification_name := 'Pre-Tax ZVW Refund';
    g_stat_element_table(26).element_name        := NULL;
    g_stat_element_table(26).element_type        := 'E';
    g_stat_element_table(26).main_index          := 18720;      --10980;
    g_stat_element_table(26).archive_flag        := 'Y';
    g_stat_element_table(26).standard            := NULL; --'Subject to Standard Tax : Earnings';
    g_stat_element_table(26).special     := NULL; --'Subject to Special Tax : Earnings';
    g_stat_element_table(26).payable_flag        := 'Y';

    g_stat_element_table(27).classification_name := 'Retro Pre-Tax ZVW Refund';
    g_stat_element_table(27).element_name        := NULL;
    g_stat_element_table(27).element_type        := 'E';
    g_stat_element_table(27).main_index          := 18770;      --10990;
    g_stat_element_table(27).archive_flag        := 'Y';
    g_stat_element_table(27).standard            := NULL; --'Subject to Standard Tax : Retro Earnings';
    g_stat_element_table(27).special     := NULL; --'Subject to Special Tax : Retro Earnings';
    g_stat_element_table(27).payable_flag        := 'Y';

--5957039
--to place after Net Earnings
    g_stat_element_table(28).classification_name := 'Pre-Tax ZVW Refund';
    g_stat_element_table(28).element_name        := NULL;
    g_stat_element_table(28).element_type        := 'E';
    g_stat_element_table(28).main_index          := 28050;      --10980;
    g_stat_element_table(28).archive_flag        := 'Y';
    g_stat_element_table(28).standard            := NULL; --'Subject to Standard Tax : Earnings';
    g_stat_element_table(28).special     := NULL; --'Subject to Special Tax : Earnings';
    g_stat_element_table(28).payable_flag        := 'Y';

    g_stat_element_table(29).classification_name := 'Retro Pre-Tax ZVW Refund';
    g_stat_element_table(29).element_name        := NULL;
    g_stat_element_table(29).element_type        := 'E';
    g_stat_element_table(29).main_index          := 28100;      --10990;
    g_stat_element_table(29).archive_flag        := 'Y';
    g_stat_element_table(29).standard            := NULL; --'Subject to Standard Tax : Retro Earnings';
    g_stat_element_table(29).special     := NULL; --'Subject to Special Tax : Retro Earnings';
    g_stat_element_table(29).payable_flag        := 'Y';

-- Bug 5957039

END setup_element_table;

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_INIT                                            	|
|Type		: Procedure							|
|Description    : Procedure sets the global tables g_statutory_balance_table,   |
|		  g_stat_element_table,g_user_balance_table,g_element_table.	|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_INIT(p_payroll_action_id IN NUMBER) IS

l_business_group_id	NUMBER;
l_start_date            VARCHAR2(240);
l_end_date              VARCHAR2(240);
l_canonical_start_date	DATE;
l_canonical_end_date    DATE;
l_effective_date	DATE;
l_payroll_id		NUMBER;
l_consolidation_set	NUMBER;

BEGIN
	--
	--hr_utility.set_location('Entering Archive Init',600);
	--
	pay_nl_payslip_archive.get_all_parameters(p_payroll_action_id
					,l_business_group_id
					,l_start_date,l_end_date,l_effective_date
					,l_payroll_id,l_consolidation_set);
	--
	l_canonical_start_date := TO_DATE(l_start_date,'YYYY/MM/DD');
	l_canonical_end_date   := TO_DATE(l_end_date,'YYYY/MM/DD');
	--

	--hr_utility.set_location('l_payroll_id           = ' || l_payroll_id,655);
	--hr_utility.set_location('l_consolidation_set    = ' || l_consolidation_set,655);
	--hr_utility.set_location('l_canonical_start_date = ' || l_canonical_start_date,655);
	--hr_utility.set_location('l_canonical_end_date   = ' || l_canonical_end_date,655);
	--
	--

	-- Setup statutory balances pl/sql table
	IF g_statutory_balance_table.count = 0 THEN
		setup_statutory_balance_table(l_canonical_start_date, l_business_group_id);
	END IF;
	--

	-- Populates the global PL/SQL Table with Balance information and archives
	-- EMEA BALANCE DEFINITION Context
	--
	IF  g_user_balance_table.count = 0   THEN
		pay_nl_payslip_archive.get_eit_definitions (
		p_pactid            => p_payroll_action_id
		, p_business_group_id => l_business_group_id
		, p_payroll_pact      => NULL
		, p_effective_date    => l_canonical_start_date
		, p_eit_context       => 'NL_PAYSLIP_BALANCES'
		, p_archive           => 'N');
		--
		--
		--hr_utility.set_location('Inside Archive Init Code',660);
	END IF;
	-- Populates the global PL/SQL Table with Element information and archives
	-- EMEA ELEMENT DEFINITION Context
	--
	IF  g_element_table.count = 0 THEN
		pay_nl_payslip_archive.get_eit_definitions (
		p_pactid            => p_payroll_action_id
		, p_business_group_id => l_business_group_id
		, p_payroll_pact      => NULL
		, p_effective_date    => l_canonical_start_date
		, p_eit_context       => 'NL_PAYSLIP_ELEMENTS'
		, p_archive           => 'N');
		--
	END IF;

	--hr_utility.set_location('Inside Archive Init Code',670);


	--hr_utility.set_location('Inside Archive Init Code',675);

	-- Setup statutory element  pl/sql table
	setup_element_table();
	--
	--hr_utility.set_location('Inside Archive Init Code',680);

	--hr_utility.set_location('Leaving Archive Init',700);
	--
END ARCHIVE_INIT;

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_EMPLOYEE_DETAILS                            		|
|Type		: Procedure							|
|Description    : Procedure archives EMLOYEE DETAILS,ADRESS DETAILS AND		|
|		  EMPLOYEE NET PAY DISTRIBUTION contexts			|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_EMPLOYEE_DETAILS (p_payroll_action_id       	IN NUMBER
                                   ,p_assactid                	IN NUMBER
                                   ,p_assignment_id            	IN NUMBER
                                   ,p_curr_pymt_ass_act_id 	IN NUMBER
 		                   ,p_date_earned              	IN DATE
                                   ,p_archive_effective_date  	IN DATE
                                   ,p_curr_pymt_eff_date    	IN DATE
                                   ,p_time_period_id           	IN NUMBER
  	                           ,p_record_count             	IN NUMBER) IS

cursor	csr_add_info_13_14 is
select	pai.action_information_id, pai.action_information1, pa.add_information13,
	pa.add_information14, pai.object_version_number
from	pay_action_information pai,
	per_addresses pa
where	pai.action_context_id 	= p_assactid
and	pai.action_context_type 	= 'AAP'
and	pai.action_information_category = 'ADDRESS DETAILS'
and	pa.person_id 		= pai.action_information1
and	pa.primary_flag 		= 'Y'
and	p_archive_effective_date between pa.date_from
                                   and nvl(pa.date_to, p_archive_effective_date);

BEGIN

	--
	pay_emp_action_arch.get_personal_information (
		 p_payroll_action_id    => p_payroll_action_id
		,p_assactid             => p_assactid
		,p_assignment_id        => p_assignment_id
		,p_curr_pymt_ass_act_id => p_curr_pymt_ass_act_id
		,p_curr_eff_date        => p_archive_effective_date
		,p_date_earned          => p_date_earned
		,p_curr_pymt_eff_date   => p_curr_pymt_eff_date
		,p_tax_unit_id          => NULL
		,p_time_period_id       => p_time_period_id
		,p_ppp_source_action_id => NULL);

	FOR cntr IN csr_add_info_13_14
	LOOP
		pay_action_information_api.update_action_information(p_action_information_id => cntr.action_information_id
								     ,p_object_version_number => cntr.object_version_number
								     ,p_action_information26 => cntr.add_information13
								     ,p_action_information27 => cntr.add_information14
								     );

	END LOOP;
	--
END ARCHIVE_EMPLOYEE_DETAILS;

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_NL_EMPLOYEE_DETAILS                            	|
|Type		: Procedure							|
|Description    : Procedure archives NL EMLOYEE DETAILS,NL OTHER EMPLOYEE 	|
|		  DETAILS,ADDL EMPLOYEE DETAILS context				|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_NL_EMPLOYEE_DETAILS (p_assignment_id     IN NUMBER
                            ,p_assg_action_id              IN NUMBER
                            ,p_master_asg_act_id	   IN NUMBER
                            ,p_payroll_id                  IN NUMBER
                            ,p_date_earned                 IN DATE) IS

CURSOR csr_nl_employee_details IS
SELECT trim(scl.segment11)                tax_code
      ,FND_NUMBER.Canonical_To_Number(scl.segment12)    prev_year_sal
      ,scl.segment4					tax_reduction
      ,scl.segment7					labour_tax_reduction
      ,scl.segment9					add_senior_tax_reduction
      ,FND_NUMBER.Canonical_To_Number(scl.segment28)    individual_working_hours
FROM   per_assignments_f            paf
      ,hr_soft_coding_keyflex       scl
WHERE  paf.assignment_id            = p_assignment_id
AND    p_date_earned                BETWEEN paf.effective_start_date
                                    AND     paf.effective_end_date
AND    paf.soft_coding_keyflex_id   = scl.soft_coding_keyflex_id;
--
CURSOR csr_nl_emp_organization IS
SELECT organization_id
FROM	per_all_assignments_f
WHERE assignment_id=p_assignment_id
AND p_date_earned 	BETWEEN effective_start_date
                        AND     effective_end_date;
--
--
--
CURSOR csr_payroll_period is
SELECT paf.period_type          period_type
      ,paf.business_group_id    bug_group_id
FROM   pay_all_payrolls_f paf
WHERE  payroll_id               = p_payroll_id
AND    p_date_earned            BETWEEN paf.effective_start_date
                                AND     paf.effective_end_date;
--
--
CURSOR csr_get_context_id(p_context_name  		VARCHAR2
			 ,p_assignment_action_id	NUMBER) IS
SELECT ff.context_id     context_id
      ,pact.context_value   context_value
      , decode(context_value,'ZVW',0,'ZW',1,
               'WEWE',2,'WEWA',3,'WAOD',4,'WAOB',5,6) seq
FROM   ff_contexts         ff
      ,pay_action_contexts pact
WHERE  ff.context_name   = p_context_name
AND    pact.context_id   = ff.context_id
AND    pact.assignment_action_id=p_assignment_action_id
ORDER  BY decode(context_value,'ZVW',0,'ZW',1,
          'WEWE',2,'WEWA',3,'WAOD',4,'WAOB',5,6);


--
-- Cursor to fetch the org_structure_version_id
--
CURSOR csr_get_org_struct_ver_id(p_org_struct_id NUMBER
                                ,p_date_earned   DATE) IS
SELECT org_structure_version_id
FROM   per_org_structure_versions posv
WHERE  organization_structure_id  =p_org_struct_id
AND    p_date_earned           BETWEEN posv.date_from
                               AND NVL(posv.date_to,hr_general.end_of_time);


--
--
--
CURSOR csr_get_hr_org_address(p_organization_id NUMBER) IS
SELECT hr_org_tl.NAME              name
      ,hr_loc.style		style
      ,hr_loc.region_1          street_name
      ,hr_loc.address_line_1    add_line1
      ,hr_loc.address_line_2    add_line2
      ,hr_loc.address_line_3    add_line3
--      ,hr_loc.postal_code       postal_code
      ,pay_nl_general.get_postal_code_new(hr_loc.postal_code)       postal_code
      ,hr_loc.town_or_city      city
      ,hr_loc.region_2          province
      ,hr_loc.country           country
      ,hr_loc.region_3          po_box_no
FROM   HR_ALL_ORGANIZATION_UNITS   hr_org
      ,HR_ALL_ORGANIZATION_UNITS_TL hr_org_tl
      ,hr_locations_all             hr_loc
WHERE  hr_org.organization_id   = p_organization_id
AND    hr_org.organization_id   = hr_org_tl.organization_id
AND    hr_org.location_id    = hr_loc.location_id (+)
AND    hr_org_tl.LANGUAGE = USERENV('LANG');

--

/*CURSOR csr_get_territory_name(p_territory_code VARCHAR2) Is
SELECT TERRITORY_SHORT_NAME
FROM FND_TERRITORIES_VL
WHERE TERRITORY_CODE = p_territory_code;*/
--
--
CURSOR csr_get_regular_working_hrs(p_assignment_id  NUMBER) IS
SELECT paf.normal_hours         normal_hours
FROM   per_all_assignments_f    paf
WHERE  paf.assignment_id        = p_assignment_id
AND    p_date_earned            BETWEEN paf.effective_start_date
                                AND     paf.effective_end_date;


CURSOR csr_element_si_type_value(p_assignment_action_id NUMBER
                                ,p_effective_date       DATE) IS
SELECT prv.result_value         value
      ,prv1.result_value        si_type
FROM   pay_run_result_values    prv
      ,pay_run_results          prr
      ,pay_input_values_f       piv
      ,pay_input_values_f       piv1
      ,pay_run_result_values    prv1
      ,pay_element_types_f      pet
WHERE  prr.status               IN ('P','PA')
AND    prv.run_result_id        = prr.run_result_id
AND    prr.assignment_action_id = p_assignment_action_id
AND    prr.element_type_id      = pet.element_type_id
AND    pet.legislation_code     = 'NL'
AND    prv.input_value_id       = piv.input_value_id
AND    prv1.input_value_id      = piv1.input_value_id
AND    piv.name                 = 'SI Type Name'
AND    p_effective_date        BETWEEN piv1.effective_start_date
                                AND     piv1.effective_end_date
AND    p_effective_date        BETWEEN piv.effective_start_date
                                AND     piv.effective_end_date
AND    piv.element_type_id      = prr.element_type_id
AND    prv1.run_result_id       = prv.run_result_id
AND    piv1.name                 = 'SI Type'
AND    prv.result_value         IS NOT NULL
AND    pet.element_name IN
('Net Employee SI Contribution', 'Employee SI Contribution Standard Tax',
       'Employee SI Contribution Special Tax', 'Employee SI Contribution');

--
	CURSOR csr_emp_phc_applies(p_assgn_action_id NUMBER
				  ,p_date_earned     DATE) IS
	SELECT 1
	FROM pay_run_results prr
	    ,pay_element_types_f pet
	WHERE
		pet.element_name = 'Private Health Insurance'
	AND 	prr.assignment_action_id=p_assgn_action_id
	AND 	prr.element_type_id=pet.element_type_id
	AND     p_date_earned   BETWEEN pet.effective_start_date
				AND     pet.effective_end_date;
--Bug No 3384315
--Cursor which gets the previous year income given assignment action id of payroll run
Cursor get_prev_year_salary (p_asg_act_id number
                     ,p_date_earned date) is
select result_value
from pay_run_result_values prrv
, pay_run_results prr
,pay_element_types_f pet
,pay_input_values_f piv
where prrv.run_result_id=prr.run_result_id
and prr.assignment_action_id=p_asg_act_id
and prr.element_type_id=pet.element_type_id
and pet.element_name = 'Special Tax Deduction'
and prrv.input_value_id=piv.input_value_id
and piv.legislation_code = 'NL'
and piv.name = 'Previous Year Taxable Income'
and p_date_earned   BETWEEN pet.effective_start_date
		     AND     pet.effective_end_date
and p_date_earned   BETWEEN piv.effective_start_date
                        AND piv.effective_end_date;

--
--
csr_hr_org_address_rec 		csr_get_hr_org_address%ROWTYPE;
l_value                         hr_lookups.lookup_code%TYPE;
l_meaning                       hr_lookups.meaning%TYPE;
l_tax_code                      hr_soft_coding_keyflex.segment1%TYPE;
l_prev_year_sal		        hr_soft_coding_keyflex.segment1%TYPE;
l_tax_reduction                 hr_soft_coding_keyflex.segment1%TYPE;
l_labour_tax_reduction          hr_soft_coding_keyflex.segment1%TYPE;
l_add_senior_tax_reduction      hr_soft_coding_keyflex.segment1%TYPE;
l_org_struct_id			NUMBER;
l_ni				hr_lookups.meaning%TYPE;
l_period			hr_lookups.meaning%TYPE;
l_table				hr_lookups.meaning%TYPE;
l_age				NUMBER;
l_period_type			pay_all_payrolls_f.period_type%TYPE;
l_ret				pay_user_column_instances_f.value%TYPE;
l_struct_id			NUMBER;
l_min_wage_type			pay_user_columns.user_column_name%TYPE;
l_min_wage_factor		NUMBER;
l_bus_group_id			NUMBER;
l_org_struct_ver_id		NUMBER;
l_legal_min_payment		VARCHAR2(240);
l_si_def_bal_id			NUMBER;
l_context_id			NUMBER;
l_context_value			pay_action_contexts.context_value%TYPE;
l_seq				VARCHAR2(60);
l_si_days			NUMBER;
l_WAO  				VARCHAR2(30);
l_WW   				VARCHAR2(30);
l_ZVW  				VARCHAR2(30);
l_ZW   				VARCHAR2(30);
l_E1   				VARCHAR2(240);
l_E2   				VARCHAR2(240);
l_E3   				VARCHAR2(240);
l_E4   				VARCHAR2(240);
l_E5   				VARCHAR2(240);
l_E6   				VARCHAR2(240);
l_E7   				VARCHAR2(240);
l_E8   				VARCHAR2(240);
l_E9   				VARCHAR2(240);
l_E10  				VARCHAR2(240);
l_employer_id			NUMBER;
l_regular_working_hours		NUMBER;
l_action_info_id		NUMBER;
l_ovn				NUMBER;
l_organization_Id		NUMBER;
l_individual_working_hours	NUMBER;
l_not_defined			VARCHAR2(255);
l_province			hr_lookups.meaning%TYPE;
l_city				hr_lookups.meaning%TYPE;
l_street_name			hr_lookups.meaning%TYPE;
l_country			FND_TERRITORIES_TL.TERRITORY_SHORT_NAME%TYPE;
l_dummy				NUMBER;
--
BEGIN
--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS',1400);
OPEN csr_nl_employee_details;
	    --
	    FETCH csr_nl_employee_details INTO l_tax_code
					      ,l_dummy
					      ,l_tax_reduction
					      ,l_labour_tax_reduction
					      ,l_add_senior_tax_reduction
					      ,l_individual_working_hours;
	    --
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_prev_year_sal'||l_prev_year_sal,1420);

	IF  csr_nl_employee_details%FOUND THEN

		  --hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_meaning'||l_meaning,1440);
		  --hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_tax_code'||l_tax_code,1440);
		  --hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS p_assignment_id'||p_assignment_id,1440);

		  l_meaning:= hr_general.decode_lookup('NL_TAX_CODE'
						     ,substr(l_tax_code,1,3));

		  --hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_ni'||l_ni,1440);

		  IF  l_meaning is null THEN
			-- Split the tax code
			-- 1st Digit
		  l_ni:= hr_general.decode_lookup('NL_TAX_TYPE'
						     ,substr(l_tax_code,1,1));

			-- 2nd Digit
		  l_table:= hr_general.decode_lookup('NL_TAX_TABLE'
							   ,substr(l_tax_code,2,1));

			-- 3rd Digit
		  l_period:= hr_general.decode_lookup('NL_PAYROLL_PERIOD'
							   ,substr(l_tax_code,3,1));

		  END IF;
	ELSE
		l_tax_code                      :='940';
		l_prev_year_sal                 :='0.00';
		l_tax_reduction                 :='N';
		l_labour_tax_reduction          :='N';
		l_add_senior_tax_reduction      :='N';

	    END IF;
	CLOSE csr_nl_employee_details;
	--
	--Bug No 3384315
	--Get the previous year salary from the input value of special tax deduction element
	OPEN get_prev_year_salary (p_master_asg_act_id, p_date_earned);
	Fetch get_prev_year_salary INTO l_prev_year_sal;
	CLOSE get_prev_year_salary;

	IF l_prev_year_sal IS NULL THEN
	l_prev_year_sal:='0.00';
	END IF;

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_tax_code'||l_tax_code,1440);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_tax_reduction'||l_tax_reduction,1440);

	--Bug No.3380758
	--Moved initializing l_age before assigning the l_tax_reduction

	l_age := pay_nl_tax_pkg.get_age_payroll_period(p_assignment_id
							,p_payroll_id
							  ,p_date_earned);

	IF l_tax_reduction = 'Y' THEN

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_age'||l_age,1440);
		IF l_age < 65 THEN
		  l_tax_reduction :=hr_general.decode_lookup('HR_NL_REPORT_LABELS'
							,'NL_GENERAL');
	      ELSE
		  l_tax_reduction:= hr_general.decode_lookup('HR_NL_REPORT_LABELS'
							  ,'NL_SENIOR');
		END IF;

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_tax_reduction'||l_tax_reduction,1440);
	END IF;
	--
	--
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_tax_code'||l_tax_code,1440);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS p_assg_action_id'||p_assg_action_id,1400);
	-- Archive NL EMPLOYEE DETAILS
	--
	--pay_action_information_api.create_action_information ();

	 pay_action_information_api.create_action_information (
	  p_action_information_id        => l_action_info_id
	 ,p_action_context_id            => p_assg_action_id
	 ,p_action_context_type          => 'AAP'
	 ,p_object_version_number        => l_ovn
	 ,p_effective_date               => p_date_earned
	 ,p_source_id                    => NULL
	 ,p_source_text                  => NULL
	 ,p_action_information_category  => 'NL EMPLOYEE DETAILS'
	 ,p_action_information21          =>l_tax_code
	 ,p_action_information22          =>l_ni
	 ,p_action_information23          =>l_table
	 ,p_action_information24          =>l_period
	 ,p_action_information25          =>l_prev_year_sal
	 ,p_action_information26          =>l_tax_reduction
	 ,p_action_information27          =>l_labour_tax_reduction
	 ,p_action_information28          =>l_add_senior_tax_reduction);

	 --hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_action_info_id'||l_action_info_id,1400);

	OPEN csr_payroll_period;
	    FETCH csr_payroll_period INTO l_period_type,l_bus_group_id;
	CLOSE csr_payroll_period;

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_period_type'||l_period_type,1400);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_bus_group_id'||l_bus_group_id,1400);
	--
	IF  l_period_type     = 'Calendar Month' THEN
	    l_min_wage_type   := 'Month';
	    l_min_wage_factor := 1;
	ELSIF  l_period_type  = 'Week' THEN
	    l_min_wage_type   := 'Week';
	    l_min_wage_factor := 1;
	ELSIF  l_period_type  = 'Lunar Month' THEN
	    l_min_wage_type   := 'Week';
	    l_min_wage_factor := 4;
	ELSIF  l_period_type  = 'Quarter' THEN
	    l_min_wage_type   := 'Month';
	    l_min_wage_factor := 3;
	END IF;

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_min_wage_type'||l_min_wage_type,1420);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_min_wage_factor'||l_min_wage_factor,1420);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_age'||l_age,1420);

	IF l_age > 23 THEN
	l_age:=23;
	END IF;

	BEGIN
	    l_ret:= hruserdt.get_table_value(l_bus_group_id
					    ,'NL_LEGAL_MINIMUM_WAGES'
					    ,l_min_wage_type
					    ,l_age);
	EXCEPTION
	    WHEN NO_DATA_FOUND THEN
	    l_ret:='0';
	END;
	--
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_ret'||l_ret,1425);

	OPEN csr_nl_emp_organization;
	FETCH csr_nl_emp_organization INTO l_organization_Id;
	CLOSE csr_nl_emp_organization;

	-- Derive the Org Structure Id from BG Level
	--
	l_struct_id := HR_NL_ORG_INFO.NAMED_HIERARCHY (l_bus_group_id);
	--
	--
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_struct_id'||l_struct_id,1430);

	-- Derive the Org Structure Version Id
	--
	OPEN csr_get_org_struct_ver_id (l_struct_id,p_date_earned);
	     FETCH csr_get_org_struct_ver_id INTO l_org_struct_ver_id;
	CLOSE csr_get_org_struct_ver_id;
	--
	--
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_org_struct_ver_id'||l_org_struct_ver_id,1440);

	l_employer_id := HR_NL_ORG_INFO.GET_TAX_ORG_ID(l_org_struct_ver_id
						      ,l_organization_Id);
	--
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_employer_id'||l_employer_id,1450);
	--Bug 3601121
	l_legal_min_payment := NVL(fnd_number.number_to_canonical((FND_NUMBER.CANONICAL_TO_NUMBER(l_ret) * l_min_wage_factor)),'');

	l_si_def_bal_id := get_defined_balance_id('Real Social Insurance Days'
						 ,'_ASG_SIT_RUN');

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_legal_min_payment'||l_legal_min_payment,1460);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_si_def_bal_id'||l_si_def_bal_id,1460);

	OPEN csr_get_context_id('SOURCE_TEXT',p_master_asg_act_id);
	    FETCH csr_get_context_id INTO l_context_id,l_context_value,l_seq;
	CLOSE csr_get_context_id;

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_context_id'||l_context_id,1470);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_context_value'||l_context_value,1470);

	BEGIN
	    l_si_days:=0;

	    IF l_context_id IS NOT NULL THEN
	    l_si_days := pay_balance_pkg.get_value(l_si_def_bal_id
						   ,p_master_asg_act_id
						   ,NULL
						   ,NULL
						   ,l_context_id
						   ,l_context_value
						   ,NULL
						   ,NULL);
	   END IF;

	EXCEPTION
	    WHEN OTHERS THEN
	    l_si_days:=0;
	END;

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_si_days'||l_si_days,1480);
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_si_days'||' '||l_si_days);
	--
	-- Archive NL OTHER EMPLOYEE DETAILS
	--
	--pay_action_information_api.create_action_information ();
	--
	--l_individual_working_hours
	--
	pay_action_information_api.create_action_information (
		  p_action_information_id        => l_action_info_id
		 ,p_action_context_id            => p_assg_action_id
		 ,p_action_context_type          => 'AAP'
		 ,p_object_version_number        => l_ovn
		 ,p_effective_date               => p_date_earned
		 ,p_source_id                    => NULL
		 ,p_source_text                  => NULL
		 ,p_action_information_category  => 'NL OTHER EMPLOYEE DETAILS'
		 ,p_action_information4          =>p_payroll_id
		 ,p_action_information5          =>l_employer_id
		 ,p_action_information6          =>fnd_number.number_to_canonical(l_individual_working_hours)
		 ,p_action_information7          =>l_legal_min_payment
		 ,p_action_information8          =>fnd_number.number_to_canonical(l_si_days));

	OPEN csr_get_hr_org_address(l_employer_id);
	    FETCH csr_get_hr_org_address INTO csr_hr_org_address_rec;
	CLOSE csr_get_hr_org_address;
	--
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_si_days'||l_si_days,1490);

	OPEN csr_get_regular_working_hrs( p_assignment_id);
	    FETCH csr_get_regular_working_hrs INTO l_regular_working_hours;
	CLOSE csr_get_regular_working_hrs;

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_regular_working_hours'||l_regular_working_hours,1500);
	--
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_regular_working_hours'||' '||l_regular_working_hours);
	-- Archive ADDL EMPLOYEE DETAILS
	--

	l_city:= hr_general.decode_lookup('HR_NL_CITY',csr_hr_org_address_rec.city);

        l_province:= hr_general.decode_lookup('HR_NL_PROVINCE',csr_hr_org_address_rec.province);

	l_country:=get_country_name(csr_hr_org_address_rec.country);

	l_street_name:=csr_hr_org_address_rec.street_name;

	IF csr_hr_org_address_rec.style = 'NL_GLB' THEN

	l_street_name:= hr_general.decode_lookup('NL_REGION',csr_hr_org_address_rec.street_name);

	END IF;

	/*OPEN csr_get_territory_name(csr_hr_org_address_rec.country);
		FETCH csr_get_territory_name INTO l_country;
	CLOSE csr_get_territory_name;*/

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS csr_hr_org_address_rec.name'||csr_hr_org_address_rec.name,1500);
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS csr_hr_org_address_rec.city'||csr_hr_org_address_rec.city,1500);

	--pay_action_information_api.create_action_information (..);
	--
	pay_action_information_api.create_action_information (
		  p_action_information_id        => l_action_info_id
		 ,p_action_context_id            => p_assg_action_id
		 ,p_action_context_type          => 'AAP'
		 ,p_object_version_number        => l_ovn
		 ,p_effective_date               => p_date_earned
		 ,p_source_id                    => NULL
		 ,p_source_text                  => NULL
		 ,p_action_information_category  => 'ADDL EMPLOYEE DETAILS'
		 ,p_action_information4          =>csr_hr_org_address_rec.name
		 ,p_action_information5          =>l_street_name
		 ,p_action_information6          =>csr_hr_org_address_rec.add_line1
		 ,p_action_information7          =>csr_hr_org_address_rec.add_line2
		 ,p_action_information8          =>csr_hr_org_address_rec.add_line3
		 ,p_action_information9          =>csr_hr_org_address_rec.postal_code
		 ,p_action_information10         =>l_city
	 	 ,p_action_information11         =>l_province
	 	 ,p_action_information12         =>l_country
	 	 ,p_action_information13         =>csr_hr_org_address_rec.po_box_no
	 	 ,p_action_information14         =>fnd_number.number_to_canonical(l_regular_working_hours));

	--
	l_WAO   := 'N';
	l_WW    := 'N';
	l_ZVW   := 'N';
	l_ZW    := 'N';
	l_E1    := '';
	l_E2    := '';
	l_E3    := '';
	l_E4    := '';
	l_E5    := '';
	l_E6    := '';
	l_E7    := '';
	l_E8    := '';
	l_E9    := '';
	l_E10   := '';
	--
	--
	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_WAO'||l_WAO,1500);

	fnd_message.set_name('PAY','PAY_NL_SI_TYPE_NOT_DEFINED');
	l_not_defined := substr(fnd_message.get,1,254);

	 --hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_not_defined'||l_not_defined,1500);

	FOR si_type_rec IN csr_element_si_type_value(p_master_asg_act_id
						,p_date_earned) LOOP
	    --

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS si_type_rec.si_type'||si_type_rec.si_type,1700);
	    IF  si_type_rec.si_type = 'WAOD' and l_not_defined <> si_type_rec.value   THEN
		l_WAO := 'Y';
	    ELSIF  si_type_rec.si_type = 'WAOB' and l_not_defined <> si_type_rec.value THEN
		l_WAO := 'Y';
	    ELSIF  si_type_rec.si_type = 'WEWE'  and l_not_defined <> si_type_rec.value THEN
		l_WW := 'Y';
    	    ELSIF  si_type_rec.si_type = 'WEWA'  and l_not_defined <> si_type_rec.value THEN
		l_WW := 'Y';
	    ELSIF  si_type_rec.si_type = 'ZVW' and l_not_defined <> si_type_rec.value THEN
		l_ZVW := 'Y';
	    ELSIF  si_type_rec.si_type = 'ZW'  and l_not_defined <> si_type_rec.value THEN
		l_ZW := 'Y';
	    ELSIF  si_type_rec.si_type = 'E1'   THEN
		l_E1 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E2'   THEN
		l_E2 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E3'   THEN
		l_E3 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E4'   THEN
		l_E4 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E5'   THEN
		l_E5 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E6'   THEN
		l_E6 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E7'   THEN
		l_E7 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E8'   THEN
		l_E8 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E9'   THEN
		l_E9 := si_type_rec.value;
	    ELSIF  si_type_rec.si_type = 'E10'  THEN
		l_E10 := si_type_rec.value;
	    END IF;
	    --
	END LOOP ; --


    	OPEN csr_emp_phc_applies(p_master_asg_act_id
                              ,p_date_earned);
	FETCH csr_emp_phc_applies into l_dummy;
    	IF csr_emp_phc_applies%FOUND THEN
	    	l_ZVW:= 'N';
    	END IF;

	-- Archive NL SI EMPLOYEE DETAILS
	--
	--pay_action_information_api.create_action_information (..);
	--
	pay_action_information_api.create_action_information (
		  p_action_information_id        => l_action_info_id
		 ,p_action_context_id            => p_assg_action_id
		 ,p_action_context_type          => 'AAP'
		 ,p_object_version_number        => l_ovn
		 ,p_effective_date               => p_date_earned
		 ,p_source_id                    => NULL
		 ,p_source_text                  => NULL
		 ,p_action_information_category  => 'NL SI EMPLOYEE DETAILS'
		 ,p_action_information4          =>l_WAO
		 ,p_action_information5          =>l_WW
		 ,p_action_information6          =>l_ZVW
		 ,p_action_information7          =>l_ZW
		 ,p_action_information8          =>l_E1
		 ,p_action_information9          =>l_E2
		 ,p_action_information10         =>l_E3
		 ,p_action_information11         =>l_E4
		 ,p_action_information12         =>l_E5
		 ,p_action_information13         =>l_E6
		 ,p_action_information14         =>l_E7
		 ,p_action_information15         =>l_E8
		 ,p_action_information16         =>l_E9
		 ,p_action_information17         =>l_E10);

	--hr_utility.set_location('Inside  ARCHIVE_NL_EMPLOYEE_DETAILS l_regular_working_hours'||l_regular_working_hours,2000);

END ARCHIVE_NL_EMPLOYEE_DETAILS;
/*-------------------------------------------------------------------------------
|Name           : get_country_name                                           	|
|Type			: Function														|
|Description    : Function to get the country name from FND_TERRITORIES_VL		|
-------------------------------------------------------------------------------*/

FUNCTION get_country_name(p_territory_code VARCHAR2) RETURN VARCHAR2 IS
	CURSOR csr_get_territory_name(p_territory_code VARCHAR2) Is
	SELECT TERRITORY_SHORT_NAME
	FROM FND_TERRITORIES_VL
	WHERE TERRITORY_CODE = p_territory_code;

	l_country FND_TERRITORIES_VL.TERRITORY_SHORT_NAME%TYPE;
BEGIN
	OPEN csr_get_territory_name(p_territory_code);
	FETCH csr_get_territory_name into l_country;
	CLOSE csr_get_territory_name;
	RETURN l_country;
END;
--
/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_USER_ELEMENT_INFO     	                   	    	|
|Type			: Procedure														|
|Description    : Procedure archives EMEA ELEMENT INFO context					|
-------------------------------------------------------------------------------*/
PROCEDURE archive_user_element_info (p_action_context_id       IN NUMBER
                                    ,p_assignment_id           IN NUMBER
                                    ,p_child_assignment_action IN NUMBER
                                    ,p_effective_date          IN DATE
                                    ,p_record_count            IN NUMBER
                                    ,p_run_method              IN VARCHAR2)IS
	--
	CURSOR check_si_type (p_element_type_id      NUMBER
						,p_effective_date       DATE) 	IS
	SELECT 1
	FROM   pay_input_values_f piv
	WHERE  piv.element_type_id      = p_element_type_id
	AND    piv.NAME                 = 'SI Type'
	AND    p_effective_date         BETWEEN piv.effective_start_date
	AND     piv.effective_end_date;
	--
	--
	--
	CURSOR csr_element_values (p_assignment_action_id NUMBER
							  ,p_element_type_id      NUMBER
							  ,p_input_value_id       NUMBER) IS
	SELECT prv.result_value
	FROM   pay_run_result_values    prv
		  ,pay_run_results          prr
	WHERE  prr.status               IN ('P','PA')
	AND    prv.run_result_id        = prr.run_result_id
	AND    prr.assignment_action_id = p_assignment_action_id
	AND    prr.element_type_id      = p_element_type_id
	AND    prv.input_value_id       = p_input_value_id
	AND    prv.result_value         IS NOT NULL;
	--
	CURSOR csr_element_si_type_value(p_assignment_action_id NUMBER
									,p_element_type_id      NUMBER
									,p_input_value_id       NUMBER
									,p_si_type              VARCHAR2
									,p_effective_date       DATE) IS
	SELECT prv.result_value         value
		,prv1.result_value       si_type
	FROM   pay_run_result_values    prv
	,pay_run_results          prr
	,pay_input_values_f       piv
	,pay_run_result_values    prv1
	WHERE  prr.status               IN ('P','PA')
		AND    prv.run_result_id        = prr.run_result_id
		AND    prr.assignment_action_id = p_assignment_action_id
		AND    prr.element_type_id      = p_element_type_id
		AND    prv.input_value_id       = p_input_value_id
		AND    piv.name                 = 'SI Type'
		AND    p_effective_date         BETWEEN piv.effective_start_date
								AND     piv.effective_end_date
		AND    piv.element_type_id      = prr.element_type_id
		AND    prv1.run_result_id       = prv.run_result_id
		AND    prv1.input_value_id      = piv.input_value_id
		AND    prv1. result_value       = NVL(p_si_type,prv1. result_value)
		AND    prv.result_value         IS NOT NULL;
	--
    --
    CURSOR csr_get_si_type_name_iv_id(p_element_type_id	NUMBER
          ,p_effective_date	DATE) IS
	select piv.input_value_id
	from pay_input_values_f piv
	,pay_element_types_f pet
	where
	pet.element_type_id=p_element_type_id
	and pet.element_type_id=piv.element_type_id
	and piv.name = 'SI Type Name'
	and p_effective_date between piv.effective_start_date
	and piv.effective_end_date;

   CURSOR csr_element_si_type_name(p_assignment_action_id NUMBER
			    ,p_element_type_id      NUMBER
			    ,p_si_type              VARCHAR2
			    ,p_effective_date       DATE) IS
	Select  prv1.result_value       si_type_name
	From
	pay_run_result_values    prv
	,pay_run_results          prr
	,pay_input_values_f       piv
	,pay_run_result_values    prv1
	,pay_input_values_f       piv1
	where prr.status in ('P','PA')
	AND    prr.run_result_id   = prv.run_result_id
	AND    prr.assignment_action_id = p_assignment_action_id
	AND    prr.element_type_id      = p_element_type_id
	AND    piv.name                 = 'SI Type'
	AND    prv.input_value_id       = piv.input_value_id
	AND    p_effective_date      BETWEEN piv.effective_start_date
	AND     piv.effective_end_date
	AND    piv1.name                 = 'SI Type Name'
	AND    prv1.input_value_id       = piv1.input_value_id
	AND    p_effective_date      BETWEEN piv1.effective_start_date
	AND     piv1.effective_end_date
	AND    prv1.run_result_id       = prv.run_result_id
	AND    prv.result_value         = p_si_type;
    --
    l_action_info_id  		NUMBER;
    l_column_sequence 		NUMBER;
    l_element_type_id 		NUMBER;
    l_main_sequence   		NUMBER;
    l_multi_sequence  		NUMBER;
    l_ovn             		NUMBER;
    l_record_count    		VARCHAR2(10);
    l_dummy	      		VARCHAR2(240);
    l_si_type_name_iv_id	NUMBER;
    l_si_type_name		VARCHAR2(240);
--
BEGIN
	--
	l_column_sequence := 0;
	l_element_type_id := 0;
	l_main_sequence   := 0;
	l_multi_sequence  := NULL;

	--hr_utility.set_location('Inside f p_record_count'||p_record_count,1520);

	IF  p_record_count = 0  THEN
		l_record_count := NULL;
	ELSE
		l_record_count := p_record_count + 1;
	END IF;
	--
	FOR l_index IN 1 .. g_element_table.count
	LOOP
		--
		--hr_utility.set_location('Inside archive_user_element_info l_record_count'||l_record_count,1530);

		l_dummy := NULL;
		OPEN check_si_type(g_element_table(l_index).element_type_id	,p_effective_date);
		FETCH check_si_type INTO l_dummy;
		CLOSE check_si_type;
		-- If SI Type doesn't exist then normal processing

		--hr_utility.set_location('Inside archive_user_element_info l_dummy'||l_dummy,1530);

		IF  l_dummy IS NULL THEN
			FOR rec_element_value IN csr_element_values
				(p_child_assignment_action,g_element_table(l_index).element_type_id
				,g_element_table(l_index).input_value_id)
			LOOP
				--
				IF  l_element_type_id <> g_element_table(l_index).element_type_id THEN
					l_main_sequence := l_main_sequence + 1;
				END IF;
				l_column_sequence := l_column_sequence + 1;
				--
				--hr_utility.set_location('Inside archive_user_element_info l_element_type_id'||l_element_type_id,1530);
				--hr_utility.set_location('Inside archive_user_element_info g_element_table(l_index).element_type_id'||g_element_table(l_index).element_type_id,1530);
				--hr_utility.set_location('Inside archive_user_element_info p_run_method'||p_run_method,1530);

				-- If the run method is P, Process Separate, then only archive the
				-- data if a skip rule (formula_id) has been set. If there is no
				-- skip rule then the element info will be archived for the normal
				-- assignment action and doesn't need to be archived twice. If it
				-- is then duplicates will be displayed on the payslip.
				--
				--Commented this Chk,which prevents elements in the Proc Sep Runs
				--to be skipped.
				--IF  p_run_method = 'P' AND g_element_table(l_index).formula_id IS NULL THEN
				--	NULL;
				--ELSE
				--
				-- Archive EMEA ELEMENT INFO
				--
				--hr_utility.set_location('Inside archive_user_element_info p_run_method'||p_run_method,1530);
				pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_action_context_id
					,p_action_context_type          => 'AAP'
					,p_object_version_number        => l_ovn
					,p_assignment_id                => p_assignment_id
					,p_effective_date               => p_effective_date
					,p_source_id                    => p_child_assignment_action
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA ELEMENT INFO'
					,p_action_information1          => g_element_table(l_index).element_type_id
					,p_action_information2          => g_element_table(l_index).input_value_id
					,p_action_information3          => NULL
					,p_action_information4          => rec_element_value.result_value
					,p_action_information5          => l_main_sequence
					,p_action_information6          => l_multi_sequence
					,p_action_information7          => l_column_sequence
					,p_action_information8          => l_record_count);
				--hr_utility.set_location('Inside archive_user_element_info l_action_info_id'||l_action_info_id,1540);
				--END IF;
				--
				l_multi_sequence := NVL(l_multi_sequence,0) + 1;
				l_element_type_id := g_element_table(l_index).element_type_id;
			--
			END LOOP;
		--
		ELSE -- If SI Type exist then archive by SI Type Values
			--
			--hr_utility.set_location('Inside archive_user_element_info si type'||g_element_table(l_index).si_type,1542);
			FOR rec_element_value IN csr_element_si_type_value (p_child_assignment_action
			,g_element_table(l_index).element_type_id,g_element_table(l_index).input_value_id
			,g_element_table(l_index).si_type,p_effective_date)
			LOOP
				--
				--hr_utility.set_location('Inside archive_user_element_info si type'||rec_element_value.si_type,1544);
				--hr_utility.set_location('Inside archive_user_element_info si type'||rec_element_value.value,1544);

				IF  l_element_type_id <> g_element_table(l_index).element_type_id THEN
					l_main_sequence := l_main_sequence + 1;
				END IF;
				l_column_sequence := l_column_sequence + 1;
				--
				-- If the run method is P, Process Separate, then only archive the
				-- data if a skip rule (formula_id) has been set. If there is no
				-- skip rule then the element info will be archived for the normal
				-- assignment action and doesn't need to be archived twice. If it
				-- is then duplicates will be displayed on the payslip.
				--
				--Commented this Chk,which prevents elements in the Proc Sep Runs
				--to be skipped.
				--IF  p_run_method = 'P' AND g_element_table(l_index).formula_id IS NULL THEN
				--	NULL;
				--ELSE

				-- Retrieve SI Type Name
				/*       OPEN csr_get_si_type_name_iv_id(
				g_element_table(l_index).element_type_id
				, p_effective_date);
				FETCH csr_get_si_type_name_iv_id
				INTO l_si_type_name_iv_id;
				CLOSE csr_get_si_type_name_iv_id;
				OPEN csr_element_values (
				p_child_assignment_action
				,g_element_table(l_index).element_type_id
				,l_si_type_name_iv_id);
				FETCH csr_element_values INTO l_si_type_name;
				CLOSE csr_element_values;  */

				OPEN csr_element_si_type_name(p_child_assignment_action
				,g_element_table(l_index).element_type_id,rec_element_value.si_type,p_effective_date);
				FETCH csr_element_si_type_name INTO l_si_type_name;
				CLOSE csr_element_si_type_name;

				--
				-- Archive EMEA ELEMENT INFO
				--

				pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_action_context_id
					,p_action_context_type          => 'AAP'
					,p_object_version_number        => l_ovn
					,p_assignment_id                => p_assignment_id
					,p_effective_date               => p_effective_date
					,p_source_id                    => p_child_assignment_action
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA ELEMENT INFO'
					,p_action_information1          => g_element_table(l_index).element_type_id
					,p_action_information2          => g_element_table(l_index).input_value_id
					,p_action_information3          => rec_element_value.si_type
					,p_action_information4          => rec_element_value.value
					,p_action_information5          => l_main_sequence
					,p_action_information6          => l_multi_sequence
					,p_action_information7          => l_column_sequence
					,p_action_information8          => l_record_count
					,p_action_information9          => l_si_type_name);
					--hr_utility.set_location('Inside archive_user_element_info l_action_info_id'||l_action_info_id,1550);
				--END IF;
				--
				--
				l_multi_sequence := NVL(l_multi_sequence,0) + 1;
				l_element_type_id := g_element_table(l_index).element_type_id;
				--
			END LOOP;
		END IF;
		l_multi_sequence := NULL;
	END LOOP;
	--hr_utility.set_location('Inside archive_user_element_info l_multi_sequence'||l_multi_sequence,1590);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
      NULL;
END archive_user_element_info;
--
/*-------------------------------------------------------------------------------
|Name           : PROCESS_BALANCE     	        		               	|
|Type		: Procedure							|
|Description    : Procedure archives EMEA BALANCES context			|
-------------------------------------------------------------------------------*/

PROCEDURE process_balance (p_action_context_id IN NUMBER
                          ,p_assignment_id     IN NUMBER
                          ,p_source_id         IN NUMBER
                          ,p_effective_date    IN DATE
                          ,p_balance           IN VARCHAR2
                          ,p_dimension         IN VARCHAR2
                          ,p_defined_bal_id    IN NUMBER
                          ,p_si_type           IN VARCHAR2
                          ,p_record_count      IN NUMBER)  IS

    --
    CURSOR csr_get_si_types(p_assig_action_id NUMBER
                           ,p_context_name    VARCHAR2) IS
    SELECT pac.context_id           context_id
          ,pac.context_value        value
    FROM   ff_contexts              ff
          ,pay_action_contexts      pac
    WHERE  ff.context_name          = p_context_name
    AND    pac.context_id           = ff.context_id
    AND    pac.assignment_Action_id = p_assig_action_id;
    --
    CURSOR csr_get_context_id(p_context_name  VARCHAR2) IS
    SELECT ff.context_id            context_id
    FROM   ff_contexts              ff
    WHERE  ff.context_name          = p_context_name;
    --
    --
    --
    --
    CURSOR csr_get_sit_type_name (p_balance_name     VARCHAR2
                                ,p_assgn_action_id  NUMBER
                                ,p_date_earned      DATE
                                ,p_si_type	    VARCHAR2) IS
    SELECT prrv1.result_value       si_type_name
    FROM   pay_balance_feeds_f      pbf
          ,pay_balance_types        pbt
          ,pay_input_values_f       piv
          ,pay_input_values_f       piv1
          ,pay_input_values_f       piv2
          ,pay_element_types_f      pet
          ,pay_run_results          prr
          ,pay_run_result_values    prrv
          ,pay_run_result_values    prrv1
    WHERE  pbf.balance_type_id      = pbt.balance_type_id
    AND    pbt.balance_name         = p_balance_name
    AND    piv.input_value_id       = pbf.input_value_id
    AND	   (piv.name                 ='Pay Value'
    OR     piv.name                 ='Days')
    AND    pet.element_type_id      = piv.element_type_id
    AND    pet.classification_id <> (SELECT classification_id
            from pay_element_classifications
            where classification_name ='Balance Initialization'
            and business_group_id is null
            and legislation_code is null)
    AND    piv1.element_type_id     = pet.element_type_id
    AND    piv1.name                = 'SI Type Name'
    AND    piv2.element_type_id     = pet.element_type_id
    AND    piv2.name                = 'SI Type'
    AND    prr.element_type_id      = pet.element_type_id
    AND    prr.assignment_action_id = p_assgn_action_id
    AND    prrv.run_result_id       = prr.run_result_id
    AND    prrv.input_value_id      = piv2.input_value_id
    AND    prrv.result_value        = p_si_type
    AND    prrv1.run_result_id      = prrv.run_result_id
    AND    prrv1.input_value_id     = piv1.input_value_id
    AND    p_date_earned             BETWEEN pbf.effective_start_date
                                     AND     pbf.effective_end_date
    AND    p_date_earned             BETWEEN pet.effective_start_date
                                     AND     pet.effective_end_date
    AND    p_date_earned             BETWEEN piv.effective_start_date
                                     AND     piv.effective_end_date
    AND    p_date_earned             BETWEEN piv1.effective_start_date
                                     AND     piv1.effective_end_date
    AND    p_date_earned             BETWEEN piv2.effective_start_date
                                     AND     piv2.effective_end_date;
    --
l_balance_value		NUMBER;
l_si_type_name		VARCHAR2(240);
l_context_id		NUMBER;
l_action_info_id	NUMBER;
l_ovn			NUMBER;
l_record_count		NUMBER;
BEGIN
	--

	hr_utility.set_location('Inside process_balance p_action_context_id'||p_action_context_id,1820);
	hr_utility.set_location('Inside process_balance p_dimension'||p_dimension,1820);

	IF  p_record_count = 0  THEN
		l_record_count := NULL;
	ELSE
		l_record_count := p_record_count + 1;
	END IF;

	IF p_dimension LIKE '%SIT%' THEN
		--
		hr_utility.set_location('Inside process_balance p_si_type'||p_si_type,1840);

		IF  p_si_type IS NULL THEN
			--
			-- Loop through pay_action_context table for all SI Type
			--
			hr_utility.set_location('Inside process_balance p_source_id'||p_source_id,1860);

			FOR context_rec IN csr_get_si_types(p_source_id,'SOURCE_TEXT')
			LOOP
				--
				l_balance_value := pay_balance_pkg.get_value(p_defined_bal_id,p_source_id
									,null,null,context_rec.context_id,context_rec.value
									,null,null);
				--
				IF  l_balance_value <> 0 THEN
					--
					-- Retreive SI Type Name from run results
					--
					hr_utility.set_location('Inside process_balance p_balance'||p_balance,1870);
					hr_utility.set_location('Inside process_balance p_source_id'||p_source_id,1870);
					hr_utility.set_location('Inside process_balance p_effective_date'||p_effective_date,1870);
					hr_utility.set_location('Inside process_balance context_rec.value'||context_rec.value,1870);
					BEGIN
						OPEN csr_get_sit_type_name(p_balance
						,p_source_id
						,p_effective_date
						,context_rec.value);
						FETCH csr_get_sit_type_name INTO l_si_type_name;
						CLOSE csr_get_sit_type_name;
					EXCEPTION
						WHEN OTHERS THEN
						hr_utility.set_location('Inside process_balance No Data Found',1870);
						null;
					END;
					--
					hr_utility.set_location('Inside process_balance l_balance_value'||l_balance_value,1880);
					hr_utility.set_location('Inside process_balance l_si_type_name'||l_si_type_name,1880);

					-- Archive EMEA BALANCE Context
					--
					--pay_action_information_api.create_action_information (..);
					--
					pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_action_context_id
					,p_action_context_type          => 'AAP'
					,p_object_version_number        => l_ovn
					,p_assignment_id                => p_assignment_id
					,p_effective_date               => p_effective_date
					,p_source_id                    => p_source_id
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA BALANCES'
					,p_action_information1          =>p_defined_bal_id
					,p_action_information2          =>context_rec.value
					,p_action_information4          =>fnd_number.number_to_canonical(l_balance_value)
					,p_action_information5          =>l_record_count
					,p_action_information6          =>l_si_type_name);

            END IF;
            --
            --hr_utility.set_location('Inside process_balance l_action_info_id'||l_action_info_id,1900);
            END LOOP;
			--
        ELSE
            --
            BEGIN
				OPEN csr_get_context_id('SOURCE_TEXT');
				FETCH csr_get_context_id INTO l_context_id;
				CLOSE csr_get_context_id;
            EXCEPTION
				WHEN OTHERS THEN
				hr_utility.set_location('Inside process_balance No Data Found',1820);
				null;
    	    END;

			hr_utility.set_location('Inside process_balance l_context_id'||l_context_id,1840);

			l_balance_value := pay_balance_pkg.get_value(p_defined_bal_id,p_source_id
			,null,null,l_context_id,p_si_type
			,null,null);
			--

			--hr_utility.set_location('Inside process_balance l_balance_value'||l_balance_value,1860);

            IF  l_balance_value <> 0 THEN
				--
				-- Retreive SI Type Name from run results
				--
				hr_utility.set_location('Inside process_balance p_balance'||p_balance,1870);
				hr_utility.set_location('Inside process_balance p_source_id'||p_source_id,1870);
				hr_utility.set_location('Inside process_balance p_effective_date'||p_effective_date,1870);
				hr_utility.set_location('Inside process_balance p_si_type'||p_si_type,1870);
				BEGIN
					OPEN csr_get_sit_type_name(p_balance
					,p_source_id
					,p_effective_date
					,p_si_type);
					FETCH csr_get_sit_type_name INTO l_si_type_name;
					CLOSE csr_get_sit_type_name;
                EXCEPTION
					WHEN OTHERS THEN
					hr_utility.set_location('Inside process_balance No Data Found',1875);
					null;
				END;
				--

				hr_utility.set_location('Inside process_balance l_si_type_name'||l_si_type_name,1880);
				hr_utility.set_location('Inside process_balance l_balance_value'||l_balance_value,1880);

				-- Archive EMEA BALANCE Context
				--
				--pay_action_information_api.create_action_information (..);
				pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_action_context_id
					,p_action_context_type          => 'AAP'
					,p_object_version_number        => l_ovn
					,p_assignment_id                => p_assignment_id
					,p_effective_date               => p_effective_date
					,p_source_id                    => p_source_id
					,p_source_text                  => NULL
					,p_action_information_category  => 'EMEA BALANCES'
					,p_action_information1          =>p_defined_bal_id
					,p_action_information2          =>p_si_type
					,p_action_information4          =>fnd_number.number_to_canonical(l_balance_value)
					,p_action_information5          =>l_record_count
					,p_action_information6          =>l_si_type_name);
				hr_utility.set_location('Inside process_balance l_action_info_id'||l_action_info_id,1900);
			END IF;
		END IF;
		--
    ELSE

		hr_utility.set_location('Inside process_balance coming in else',1850);
		--
		hr_utility.set_location('Inside process_balance p_balance'||p_balance,1850);
		hr_utility.set_location('Inside process_balance p_defined_bal_id'||p_defined_bal_id,1850);
		hr_utility.set_location('Inside process_balance p_source_id'||p_source_id,1850);
		BEGIN
		l_balance_value := pay_balance_pkg.get_value(p_defined_bal_id
		,p_source_id);
		EXCEPTION
		WHEN OTHERS THEN
		hr_utility.set_location('Inside process_balance'||SQLCODE||SQLERRM,1849);
		null;
		END;
		hr_utility.set_location('Inside process_balance l_balance_value'||l_balance_value,1850);

		IF  l_balance_value <> 0 THEN
			--
			-- Archive EMEA BALANCE Context
			--
			--pay_action_information_api.create_action_information (..);
			--
			pay_action_information_api.create_action_information (
			p_action_information_id        => l_action_info_id
			,p_action_context_id            => p_action_context_id
			,p_action_context_type          => 'AAP'
			,p_object_version_number        => l_ovn
			,p_assignment_id                => p_assignment_id
			,p_effective_date               => p_effective_date
			,p_source_id                    => p_source_id
			,p_source_text                  => NULL
			,p_action_information_category  => 'EMEA BALANCES'
			,p_action_information1          =>p_defined_bal_id
			,p_action_information2          =>p_si_type
			,p_action_information4          =>fnd_number.number_to_canonical(l_balance_value)
			,p_action_information5          =>l_record_count
			,p_action_information6          =>l_si_type_name);

			hr_utility.set_location('Inside process_balance l_action_info_id'||l_action_info_id,1900);
        END IF;
        --
    END IF;
    EXCEPTION
		WHEN OTHERS THEN
		hr_utility.set_location('Inside process_balance No Data Found',1900);
		null;
END process_balance;
--

--

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_ELEMENT_INFO     		        	       				|
|Type			: Procedure														|
|Description    : Procedure archives NL CALCULATIONS for statutory elements		|
-------------------------------------------------------------------------------*/

PROCEDURE archive_element_info(p_arch_assign_action_id IN NUMBER
			,p_run_assign_action_id  IN NUMBER
			,p_class_name            IN VARCHAR2
			,p_element_name          IN VARCHAR2
			,p_date_earned           IN DATE
			,p_index                 IN NUMBER
			,p_type                  IN VARCHAR2
			,p_archive_flag	       IN VARCHAR2
			,p_standard	       IN VARCHAR2
			,p_special	       IN VARCHAR2
			,p_standard2	       IN VARCHAR2
			,p_special2	       IN VARCHAR2
			,p_payable_flag	       IN VARCHAR2
			,p_record_count          IN NUMBER
			,p_master_assign_action_id 	IN NUMBER
			,p_payroll_action_id       	IN NUMBER
			,p_assignment_id           	IN NUMBER
			,p_effective_date	      		IN DATE
			,p_child_count			IN NUMBER) IS
	--
	CURSOR csr_defined_balance_id (p_balance_name VARCHAR2
								  ,p_dimension    VARCHAR2
								  ,p_bus_group_id NUMBER) IS
	SELECT pdb.defined_balance_id   defined_balance_id
	FROM   pay_balance_dimensions   pbd
		  ,pay_balance_types        pbt
		  ,pay_defined_balances     pdb
	WHERE  pbd.database_item_suffix = p_dimension
	AND    pbt.balance_name         = p_balance_name
	AND    (pbt.business_group_id   = p_bus_group_id
	OR      pbt.legislation_code    = 'NL')
	AND    (pbd.business_group_id   = p_bus_group_id
	OR      pbd.legislation_code    = 'NL')
	AND    pdb.balance_type_id      = pbt.balance_type_id
	AND    pdb.balance_dimension_id = pbd.balance_dimension_id
	AND    (pdb.business_group_id   = p_bus_group_id
	OR      pdb.legislation_code    = 'NL');
	--
	--

	CURSOR csr_retro_values (p_run_assign_action_id NUMBER
							,p_class_name           VARCHAR2
							,p_element_name         VARCHAR2
							,p_input_value_name     VARCHAR2
							,p_date_earned          DATE
							,p_retro_period	  DATE
							,p_creator_type	  VARCHAR2) IS
	SELECT prv.result_value                 value
		  ,pet.element_type_id          element_type_id
		  ,pet.element_name             element_name
		  ,nvl(pettl.reporting_name,pettl.element_name) reporting_name
		  ,pet.processing_priority      priority
		  ,pet.business_group_id	business_group_id
		  ,prv.run_result_id            run_result_id

	FROM   pay_run_result_values        prv
		  ,pay_run_results              prr
		  ,pay_element_types_f          pet
		  ,pay_element_types_f_tl       pettl
		  ,pay_input_values_f           piv
		  ,pay_element_classifications  pec
		  ,pay_element_entries_f        pee
	WHERE  prr.status                   IN ('P','PA')
	AND    prr.source_id                 = pee.element_entry_id
	AND    pee.CREATOR_TYPE              = p_creator_type
	AND    prv.run_result_id            = prr.run_result_id
	AND    prr.assignment_action_id     = p_run_assign_action_id
	AND    prr.element_type_id          = pet.element_type_id
	AND    prv.input_value_id           = piv.input_value_id
	AND    piv.name                     = p_input_value_name
	AND    pet.classification_id        = pec.classification_id
	AND    pec.classification_name      = p_class_name
	AND    pet.element_name             = NVL(p_element_name,pet.element_name)
	AND    pec.legislation_code         = 'NL'
	AND    pet.element_type_id          = pettl.element_type_id
	AND    pettl.language               = USERENV('LANG')
	AND    p_retro_period		    = nvl( prr.start_date /*pay_nl_general.get_retro_period(prr.source_id,p_date_earned)*/,p_retro_period) --Bug 5107780
	AND    p_date_earned                BETWEEN pet.effective_start_date
										AND     pet.effective_end_date
	AND    p_date_earned                BETWEEN piv.effective_start_date
										AND     piv.effective_end_date;

	CURSOR csr_retro_element_periods (p_run_assign_action_id NUMBER
							  ,p_class_name           VARCHAR2
							  ,p_element_name         VARCHAR2
							  ,p_input_value_name     VARCHAR2
							  ,p_date_earned          DATE) IS
	SELECT unique prr.start_date --(pay_nl_general.get_retro_period(prr.source_id,p_date_earned)) Bug 5107780
	FROM   pay_run_result_values        prv
		  ,pay_run_results              prr
		  ,pay_element_types_f          pet
		  ,pay_element_types_f_tl       pettl
		  ,pay_input_values_f           piv
		  ,pay_element_classifications  pec
	WHERE  prr.status                   IN ('P','PA')
	AND    prv.run_result_id            = prr.run_result_id
	AND    prr.assignment_action_id     = p_run_assign_action_id
	AND    prr.element_type_id          = pet.element_type_id
	AND    prv.input_value_id           = piv.input_value_id
	AND    piv.name                     = p_input_value_name
	AND    pet.classification_id        = pec.classification_id
	AND    pec.classification_name      = p_class_name
	AND    pet.element_name             = NVL(p_element_name,pet.element_name)
	AND    piv.element_type_id          = pet.element_type_id
	AND    pec.legislation_code         = 'NL'
	AND    pet.element_type_id          = pettl.element_type_id
	AND    pettl.language               = USERENV('LANG')
	AND    p_date_earned                BETWEEN pet.effective_start_date
										AND     pet.effective_end_date
	AND    p_date_earned                BETWEEN piv.effective_start_date
										AND     piv.effective_end_date
	ORDER BY  prr.start_date ; --pay_nl_general.get_retro_period(prr.source_id,p_date_earned); Bug 5107780

	CURSOR csr_element_values (p_run_assign_action_id NUMBER
							  ,p_class_name           VARCHAR2
							  ,p_element_name         VARCHAR2
							  ,p_input_value_name     VARCHAR2
							  ,p_date_earned          DATE) IS
	SELECT prv.result_value             value
		  ,fnd_date.date_to_canonical( prr.start_date /*pay_nl_general.get_retro_period(prr.source_id,p_date_earned)*/ ) RDate
		  ,pet.element_type_id          element_type_id
		  ,pet.element_name             element_name
		  ,nvl(pettl.reporting_name,pettl.element_name) reporting_name
		  ,pet.processing_priority      priority
		  ,pet.business_group_id	business_group_id
  		  ,prv.run_result_id            run_result_id   /* 4389520*/
	FROM   pay_run_result_values            prv
		  ,pay_run_results              prr
		  ,pay_element_types_f          pet
		  ,pay_element_types_f_tl       pettl
		  ,pay_input_values_f           piv
		  ,pay_element_classifications  pec
	WHERE  prr.status                   IN ('P','PA')
	AND    prv.run_result_id            = prr.run_result_id
	AND    prr.assignment_action_id     = p_run_assign_action_id
	AND    prr.element_type_id          = pet.element_type_id
	AND    prv.input_value_id           = piv.input_value_id
	AND    piv.name                     = p_input_value_name
	AND    pet.classification_id        = pec.classification_id
	AND    pec.classification_name      = p_class_name
	AND    pet.element_name             = NVL(p_element_name,pet.element_name)
	AND    pec.legislation_code         = 'NL'
	AND    pet.element_type_id          = pettl.element_type_id
	AND    pet.element_type_id          = piv.element_type_id
	AND    pettl.language               = USERENV('LANG')
	AND    p_date_earned                BETWEEN pet.effective_start_date
										AND     pet.effective_end_date
	AND    p_date_earned                BETWEEN piv.effective_start_date
										AND     piv.effective_end_date
ORDER BY pet.element_name,prr.start_date            ;


	--
	CURSOR csr_sec_classification (p_element_type_id      NUMBER
								  ,p_sub_class_name       VARCHAR2
								  ,p_date_earned          DATE) IS
	SELECT 1
	FROM   pay_sub_classification_rules_f   pscf
		  ,pay_element_classifications      pec
	WHERE  pscf.element_type_id             = p_element_type_id
	AND    pscf.classification_id           = pec.classification_id
	AND    pec.classification_name          = p_sub_class_name
	AND    pec.legislation_code             = 'NL'
	AND    p_date_earned                    BETWEEN pscf.effective_start_date
											AND     pscf.effective_end_date;
	--

	--6359807
	CURSOR csr_sec_classification_psi_ptx (p_element_type_id      NUMBER
						,p_date_earned          DATE) IS
	SELECT pec.classification_name
	FROM   pay_sub_classification_rules_f   pscf
		 ,pay_element_classifications      pec
	WHERE  pscf.element_type_id             = p_element_type_id
	AND    pscf.classification_id           = pec.classification_id
	AND    pec.classification_name
	IN
	('Pension Standard Tax : Pre-SI and Pre-Tax Deductions'
	,'Pension Special Tax : Pre-SI and Pre-Tax Deductions'
	,'Pension Standard Tax : Retro Pre SI Pre Tax Deductions'
	,'Pension Special Tax : Retro Pre SI Pre Tax Deductions'
	)
	AND    pec.legislation_code             = 'NL'
	AND    p_date_earned                    BETWEEN pscf.effective_start_date
							    AND     pscf.effective_end_date;

	l_classification_name pay_element_classifications.classification_name%TYPE;
	--6359807

	--
	CURSOR csr_add_element_values (p_run_assign_action_id NUMBER
								  ,p_class_name           VARCHAR2
								  ,p_element_name         VARCHAR2
								  ,p_input_value_name     VARCHAR2
								  ,p_date_earned          DATE) IS
	SELECT prv.result_value             value
	FROM   pay_run_result_values        prv
		  ,pay_run_results              prr
		  ,pay_element_types_f          pet
		  ,pay_input_values_f           piv
		  ,pay_element_classifications  pec
	WHERE  prr.status                   IN ('P','PA')
	AND    prv.run_result_id            = prr.run_result_id
	AND    prr.assignment_action_id     = p_run_assign_action_id
	AND    prr.element_type_id          = pet.element_type_id
	AND    prv.input_value_id           = piv.input_value_id
	AND    piv.name                     = p_input_value_name
	AND    pet.classification_id        = pec.classification_id
	AND    pec.classification_name      = p_class_name
	AND    pet.element_name             = NVL(p_element_name,pet.element_name)
	AND    pet.element_type_id          = piv.element_type_id
	AND    pec.legislation_code         = 'NL'
	AND    p_date_earned                BETWEEN pet.effective_start_date
										AND     pet.effective_end_date
	AND    p_date_earned                BETWEEN piv.effective_start_date
										AND     piv.effective_end_date;

	--
	-- Cursor to retrieve all N (Normal)and P (Process separate) Child Actions
	-- for a given assignment action.
	--
	CURSOR csr_np_children (p_assignment_action_id NUMBER
				   ,p_payroll_action_id    NUMBER
				   ,p_assignment_id        NUMBER
				   ,p_effective_date       DATE) IS
	SELECT paa.assignment_action_id np_assignment_action_id
	FROM   pay_assignment_actions   paa
		  ,pay_run_types_f          prt
	WHERE  paa.source_action_id     = p_assignment_action_id
	AND    paa.payroll_action_id    = p_payroll_action_id
	AND    paa.assignment_id        = p_assignment_id
	AND    paa.run_type_id          = prt.run_type_id
	AND    prt.run_method           IN ('N','P')
	AND    p_effective_date         BETWEEN prt.effective_start_date
						AND     prt.effective_end_date;

                         --Bug 7031784
   	CURSOR csr_chk_corr_feeds (p_element_type_id NUMBER) IS
   	SELECT pbt.balance_name
   	FROM pay_balance_types pbt,
        	            pay_balance_feeds_f pbf,
        	           pay_input_values_f piv
   	WHERE pbf.balance_type_id = pbt.balance_type_id
   	AND piv.input_value_id = pbf.input_value_id
   	AND piv.element_type_id = p_element_type_id
  	 AND piv.name = 'Pay Value'
  	 AND pbt.balance_name like '%Tax Correction'
  	 AND p_effective_date BETWEEN pbf.effective_start_date AND pbf.effective_end_date;


	l_temp			NUMBER;
	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_standard_rate		varchar2(255);
	l_special_rate		varchar2(255);
	l_payable		varchar2(255);
	l_defined_balance_id	NUMBER;
	l_rate			NUMBER;
	l_index			NUMBER;
	l_temp_index  NUMBER;
	l_travel_flag   NUMBER;
	l_retro_travel_flag   NUMBER;
	l_pecentage_rate	pay_run_result_values.result_value%TYPE;
	l_sum_standard_rate	varchar2(255);
	l_sum_special_rate 	varchar2(255);
	l_sum_payable  		varchar2(255);
	l_date			varchar2(60);
	l_priority		NUMBER;
	l_reporting_name	pay_element_types.element_name%TYPE;
	type element_retro_entries is table of DATE index by binary_integer;
	l_element_retro_entries element_retro_entries;
	type creator_type is table of varchar2(2) index by binary_integer;
	l_creator_type creator_type;
	l_element_type_id      pay_element_types_f.element_type_id%TYPE;
	l_run_result_id        pay_run_results.run_result_id%TYPE;
	l_corr_bal_name pay_balance_types.balance_name%TYPE;

BEGIN

--
l_index:=p_index;
l_temp_index := l_index;
IF p_element_name IS NULL THEN

FOR element_value_rec IN csr_element_values(p_run_assign_action_id
                                           ,p_class_name
                                           ,p_element_name
                                           ,'Pay Value'
                                           ,p_date_earned) LOOP
l_travel_flag := 0;
l_retro_travel_flag := 0;
OPEN csr_sec_classification(element_value_rec.element_type_id
                               ,'Travel Allowance : Earnings'
                               ,p_date_earned);
FETCH csr_sec_classification INTO l_travel_flag;
CLOSE csr_sec_classification;

OPEN csr_sec_classification(element_value_rec.element_type_id
                               ,'Travel Allowance : Retro Earnings'
                               ,p_date_earned);
FETCH csr_sec_classification INTO l_retro_travel_flag;
CLOSE csr_sec_classification;

IF element_value_rec.element_name <> 'Employer ZVW Contribution Special Tax' AND
       element_value_rec.element_name <> 'Employer ZVW Contribution Standard Tax' AND
       element_value_rec.element_name <> 'Retro Employer ZVW Contribution Special Tax' AND
       element_value_rec.element_name <> 'Retro Employer ZVW Contribution Standard Tax' AND
       element_value_rec.element_name <> 'Standard Tax Deduction' AND
       element_value_rec.element_name <> 'Special Tax Deduction' AND
       element_value_rec.element_name <> 'Beneficial Rule Special Tax Adjustment' THEN

    --
     IF p_standard IS NOT NULL THEN
    OPEN csr_sec_classification(element_value_rec.element_type_id
                               ,p_standard
                               ,p_date_earned);
        FETCH csr_sec_classification INTO l_temp;
        IF  csr_sec_classification%FOUND THEN
            l_standard_rate := element_value_rec.value;
        ELSE
            l_standard_rate :=NULL;
        END IF;
    CLOSE csr_sec_classification;
    END IF;

    IF p_standard2 IS NOT NULL AND l_standard_rate is NULL THEN
    OPEN csr_sec_classification(element_value_rec.element_type_id
                               ,p_standard2
                               ,p_date_earned);
        FETCH csr_sec_classification INTO l_temp;
        IF  csr_sec_classification%FOUND THEN
            l_standard_rate := element_value_rec.value;
            IF p_class_name = 'Imputed Earnings' THEN
             l_index := 15800;
            END IF;
            IF p_class_name = 'Retro Imputed Earnings' THEN
             l_index := 15900;
            END IF;
        ELSE
            l_standard_rate :=NULL;
        END IF;
    CLOSE csr_sec_classification;
    END IF;

    IF p_special IS NOT NULL THEN
    OPEN csr_sec_classification(element_value_rec.element_type_id
                               ,p_special
                               ,p_date_earned);
        FETCH csr_sec_classification INTO l_temp;
        IF  csr_sec_classification%FOUND THEN
            l_special_rate := element_value_rec.value;
        ELSE
            l_special_rate :=NULL;
        END IF;
    CLOSE csr_sec_classification;
    --
    END IF;

    IF p_special2 IS NOT NULL AND l_special_rate IS NULL THEN
    OPEN csr_sec_classification(element_value_rec.element_type_id
                               ,p_special2
                               ,p_date_earned);
        FETCH csr_sec_classification INTO l_temp;
        IF  csr_sec_classification%FOUND THEN
            l_special_rate := element_value_rec.value;
            IF p_class_name = 'Imputed Earnings' THEN
             l_index := 15800;
            END IF;
            IF p_class_name = 'Retro Imputed Earnings' THEN
             l_index := 15900;
            END IF;
        ELSE
            l_special_rate :=NULL;
        END IF;
    CLOSE csr_sec_classification;
    --
    END IF;

--6359807
    OPEN csr_sec_classification_psi_ptx(element_value_rec.element_type_id
                               ,p_date_earned);
        FETCH csr_sec_classification_psi_ptx INTO l_classification_name;
	  IF  csr_sec_classification_psi_ptx%FOUND THEN
            IF l_classification_name like '%Standard%' THEN
		  l_standard_rate := element_value_rec.value;
		ELSIF l_classification_name like '%Special%' THEN
		  l_special_rate := element_value_rec.value;
		END IF;
        ELSE
            IF l_classification_name like '%Standard%' THEN
		  l_standard_rate := NULL;
		ELSIF l_classification_name like '%Special%' THEN
		  l_special_rate := NULL;
		END IF;
        END IF;
    CLOSE csr_sec_classification_psi_ptx;
--6359807

    IF p_payable_flag='Y' THEN
        l_payable := element_value_rec.value;
	l_element_type_id := element_value_rec.element_type_id ;
        l_run_result_id := element_value_rec.run_result_id;
    END IF;

    IF l_travel_flag = 1 THEN
      l_temp_index := l_index;
      l_index := 28500;
    END IF;
    IF l_retro_travel_flag = 1 THEN
      l_temp_index := l_index;
      l_index := 29000;
    END IF;

    hr_utility.set_location('Inside archive_payslip_element_info1 element_name'||element_value_rec.element_name,2120);
    hr_utility.set_location('Inside archive_payslip_element_info1 l_defined_balance_id'||l_defined_balance_id,2120);
    hr_utility.set_location('Inside archive_payslip_element_info1 business_group_id'||element_value_rec.business_group_id,2120);

    IF l_travel_flag = 1 THEN
      OPEN csr_defined_balance_id('Tax Travel Allowance','_ASG_YTD',0);
      FETCH csr_defined_balance_id INTO l_defined_balance_id;
      IF csr_defined_balance_id%NOTFOUND then
        l_defined_balance_id := NULL;
      END IF;
      CLOSE csr_defined_balance_id;
    ELSIF l_retro_travel_flag = 1 THEN
      OPEN csr_defined_balance_id('Retro Tax Travel Allowance','_ASG_YTD',0);
      FETCH csr_defined_balance_id INTO l_defined_balance_id;
      IF csr_defined_balance_id%NOTFOUND then
        l_defined_balance_id := NULL;
      END IF;
      CLOSE csr_defined_balance_id;
    ELSE
      OPEN csr_defined_balance_id(element_value_rec.element_name,'_ASG_YTD',element_value_rec.business_group_id);
      FETCH csr_defined_balance_id INTO l_defined_balance_id;
      IF csr_defined_balance_id%NOTFOUND then
        l_defined_balance_id := NULL;
      END IF;
      CLOSE csr_defined_balance_id;
    END IF;

--5957039
   IF p_class_name = 'Pre-Tax ZVW Refund'
   THEN
      OPEN csr_defined_balance_id('ZVW Refund','_ASG_YTD',element_value_rec.business_group_id);
      FETCH csr_defined_balance_id INTO l_defined_balance_id;
      IF csr_defined_balance_id%NOTFOUND then
        l_defined_balance_id := NULL;
      END IF;
      CLOSE csr_defined_balance_id;
   ELSIF p_class_name = 'Retro Pre-Tax ZVW Refund'
   THEN
	OPEN csr_defined_balance_id('Retro ZVW Refund','_ASG_YTD',element_value_rec.business_group_id);
	FETCH csr_defined_balance_id INTO l_defined_balance_id;
	if csr_defined_balance_id%NOTFOUND then
	     l_defined_balance_id := NULL;
	end if;
	CLOSE csr_defined_balance_id;
--7031784
   ELSIF p_class_name = 'Employee Tax'
   THEN
    OPEN csr_chk_corr_feeds (element_value_rec.element_type_id);
    FETCH csr_chk_corr_feeds INTO l_corr_bal_name;
    IF csr_chk_corr_feeds%FOUND THEN
      OPEN csr_defined_balance_id(l_corr_bal_name,'_ASG_YTD',element_value_rec.business_group_id);
	  FETCH csr_defined_balance_id INTO l_defined_balance_id;
	  if csr_defined_balance_id%NOTFOUND then
	     l_defined_balance_id := NULL;
	  end if;
	  CLOSE csr_defined_balance_id;
	END IF;
	CLOSE csr_chk_corr_feeds;
--7031784
  END IF;
--5957039

      hr_utility.set_location('Inside archive_payslip_element_info1 l_rate'||l_rate,2121);
      hr_utility.set_location('Inside archive_payslip_element_info1 l_defined_balance_id'||l_defined_balance_id,2121);
      hr_utility.set_location('Inside archive_payslip_element_info1 p_run_assign_action_id'||p_run_assign_action_id,2121);

      IF  l_defined_balance_id IS NOT NULL THEN
        l_rate := pay_balance_pkg.get_value(l_defined_balance_id
                                           ,p_run_assign_action_id);
      ELSE
        l_rate :=NULL;
      END IF;

    --
    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'archive_element_info l_rate'||' '||l_rate);
    hr_utility.set_location('Inside archive_payslip_element_info1 l_rate'||l_rate,2122);
    --
    -- Special Tax Deduction Elemetns requires Pay Value and Percentage
    -- Rate to be archived.
    IF  p_element_name = 'Special Tax Deduction' THEN
        --
        -- Get Individual Percentage Value
        --
        OPEN csr_add_element_values(p_run_assign_action_id
                                   ,p_class_name
                                   ,p_element_name
                                   ,'Percentage Rate'
                                   ,p_date_earned);
	FETCH csr_add_element_values INTO l_pecentage_rate;
        CLOSE csr_add_element_values;
        --
	IF l_pecentage_rate IS NOT NULL THEN
	l_pecentage_rate:=l_pecentage_rate||'%';
	END IF;
    END IF;
    --
    hr_utility.set_location('Inside archive_payslip_element_info1 l_rate'||l_rate,2123);
    IF p_archive_flag = 'Y' OR(FND_NUMBER.canonical_to_number(l_standard_rate) is not null
    			    OR FND_NUMBER.canonical_to_number(l_special_rate) is not null
    			    OR FND_NUMBER.canonical_to_number(l_payable)  is not null
    			    OR l_rate is not null) THEN
    -- Archive NL CALCULATIONS
    --
    --pay_action_information_api.create_action_information (..);
    --

--5957039
IF  p_class_name IN ('Pre-Tax ZVW Refund', 'Retro Pre-Tax ZVW Refund')
AND l_index BETWEEN 18720 AND 19000
THEN
	l_payable := -l_payable;
	l_rate := -l_rate;
END IF;
--5957039

    	 pay_action_information_api.create_action_information (
    	  p_action_information_id        => l_action_info_id
    	 ,p_action_context_id            => p_arch_assign_action_id
    	 ,p_action_context_type          => 'AAP'
    	 ,p_object_version_number        => l_ovn
    	 ,p_effective_date               => p_date_earned
    	 ,p_source_id                    => NULL
    	 ,p_source_text                  => NULL
    	 ,p_action_information_category  => 'NL CALCULATIONS'
    	 ,p_action_information4          =>l_index
    	 ,p_action_information5          =>element_value_rec.priority
    	 ,p_action_information6          =>element_value_rec.reporting_name
    	 ,p_action_information7          =>l_pecentage_rate
    	 ,p_action_information8          =>p_type
    	 ,p_action_information9          =>element_value_rec.RDate  --Retro Period
    	 ,p_action_information10         =>l_standard_rate
    	 ,p_action_information11         =>l_special_rate
    	 ,p_action_information12         =>l_payable
    	 ,p_action_information13         =>fnd_number.number_to_canonical(l_rate)
         ,p_action_information16         =>l_element_type_id            /* 4389520*/
         ,p_action_information17         =>l_run_result_id         );


          IF l_travel_flag = 1 THEN
		          g_travel_allowance := FND_NUMBER.canonical_to_number(l_payable);
		          g_travel_allowance_ytd := l_rate;
    	  END IF;
          IF l_retro_travel_flag = 1 THEN
		          g_retro_travel_allowance := FND_NUMBER.canonical_to_number(l_payable);
		          g_retro_travel_allowance_ytd := l_rate;
    	  END IF;

    l_index := l_temp_index;
	l_index := l_index + 1;

	END IF;

END IF;
END LOOP;
--
hr_utility.set_location('Inside archive_payslip_element_info1 element_name'||p_element_name,2120);

ELSIF p_element_name like 'Retro%' THEN

--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_element_name'||' '||p_element_name);
--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_child_count'||' '||p_child_count);

IF p_child_count=0 THEN

	hr_utility.set_location('Retro Inside archive_payslip_element_info1 p_run_assign_action_id'||p_run_assign_action_id,2121);
	hr_utility.set_location('Retro Inside archive_payslip_element_info1 p_class_name'||p_class_name,2121);
	hr_utility.set_location('Retro Inside archive_payslip_element_info1 p_element_name'||p_element_name,2121);

	 l_creator_type(0):='EE';
	 l_creator_type(1):='RR';
	 l_creator_type(2):='PR';
	 l_creator_type(3):='NR';

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_run_assign_action_id'||' '||p_run_assign_action_id);
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_class_name'||' '||p_class_name);
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_element_name'||' '||p_element_name);
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_date_earned'||' '||p_date_earned);

	 OPEN csr_retro_element_periods(p_run_assign_action_id
		                 ,p_class_name
		                 ,p_element_name
		                 ,'Pay Value'
                                 ,p_date_earned);
	  FETCH csr_retro_element_periods bulk collect into l_element_retro_entries;
	  CLOSE csr_retro_element_periods;

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'count'||' '||l_element_retro_entries.count);

	hr_utility.set_location('Retro Inside archive_payslip_element_info1 count'||l_element_retro_entries.count,2122);

	IF l_element_retro_entries.count > 0 THEN
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'count'||' '||l_element_retro_entries.count);

	FOR i in l_element_retro_entries.first..l_element_retro_entries.last  LOOP

	hr_utility.set_location('Retro Inside archive_payslip_element_info1 retro_date'||l_element_retro_entries(i),2123);

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries(i)'||' '||l_element_retro_entries(i));
	FOR j in l_creator_type.first..l_creator_type.last LOOP
	l_sum_standard_rate	:='0';
	l_sum_special_rate 	:='0';
	l_sum_payable  		:='0';
	l_rate			:=NULL;

	hr_utility.set_location('Retro Inside archive_payslip_element_info1 l_sum_standard_rate'||l_sum_standard_rate,2124);
	hr_utility.set_location('Retro Inside archive_payslip_element_info1 l_sum_special_rate'||l_sum_special_rate,2124);
	hr_utility.set_location('Retro Inside archive_payslip_element_info1 l_sum_payable'||l_sum_payable,2124);

	FOR csr_np_rec IN csr_np_children(
				    p_master_assign_action_id,
				    p_payroll_action_id,
				    p_assignment_id,
			    	    p_effective_date) LOOP

	hr_utility.set_location('Retro Inside archive_payslip_element_info1 '||csr_np_rec.np_assignment_action_id,2124);
	hr_utility.set_location('Retro Inside archive_payslip_element_info1 l_sum_payable'||l_sum_payable,2124);
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'csr_np_rec.np_assignment_action_id'||' '||csr_np_rec.np_assignment_action_id);

	FOR retro_element_value_rec IN csr_retro_values(csr_np_rec.np_assignment_action_id
	                                           ,p_class_name
	                                           ,p_element_name
	                                           ,'Pay Value'
                                           	   ,p_date_earned
                                           	   ,l_element_retro_entries(i)
						   ,l_creator_type(j)) LOOP

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'retro_element_value_rec.value'||' '||retro_element_value_rec.value);

	hr_utility.set_location('Retro Inside archive_payslip_element_info1 element_name'||retro_element_value_rec.value,2125);
	l_standard_rate:='0';
	l_special_rate:='0';
	l_payable:='0';

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_standard'||' '||p_standard);
	hr_utility.set_location('Retro Inside archive_payslip_element_info1 l_sum_payable'||l_sum_payable,2126);
	IF p_standard IS NOT NULL THEN
	    OPEN csr_sec_classification(retro_element_value_rec.element_type_id
	                               ,p_standard
	                               ,p_date_earned);
	        FETCH csr_sec_classification INTO l_temp;
	        IF  csr_sec_classification%FOUND THEN
	            l_standard_rate := retro_element_value_rec.value;
	            l_sum_standard_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_standard_rate) + FND_NUMBER.canonical_to_number(l_standard_rate));
	        ELSE
	            l_standard_rate :=NULL;
	        END IF;
	    CLOSE csr_sec_classification;
	    END IF;
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_special'||' '||p_special);

	    IF p_special IS NOT NULL THEN
	    OPEN csr_sec_classification(retro_element_value_rec.element_type_id
	                               ,p_special
	                               ,p_date_earned);
	        FETCH csr_sec_classification INTO l_temp;
	        IF  csr_sec_classification%FOUND THEN
	            l_special_rate := retro_element_value_rec.value;
	            l_sum_special_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_special_rate) + FND_NUMBER.canonical_to_number(l_special_rate));
	        ELSE
	            l_special_rate :=NULL;
	        END IF;
	    CLOSE csr_sec_classification;
	    --
	hr_utility.set_location('Retro Inside archive_payslip_element_info1 l_sum_payable'||l_sum_payable,2126);
	    END IF;

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_payable_flag'||' '||p_payable_flag);

	    hr_utility.set_location('Retro Inside archive_payslip_element_info2 p_payable_flag'||p_payable_flag,2120);

	    IF p_payable_flag='Y' THEN
		l_payable := retro_element_value_rec.value;
		hr_utility.set_location('Retro Inside archive_payslip_element_info2 l_payable'||l_payable,2120);
		hr_utility.set_location('Retro Inside archive_payslip_element_info2 l_sum_payable'||l_sum_payable,2120);
	        l_sum_payable:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_payable) + FND_NUMBER.canonical_to_number(l_payable));
	        hr_utility.set_location('Retro Inside archive_payslip_element_info2 l_sum_payable'||l_sum_payable,2120);
	    END IF;


		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_payable'||' '||l_sum_payable);

	    OPEN csr_defined_balance_id(retro_element_value_rec.element_name,'_ASG_YTD',retro_element_value_rec.business_group_id);
	    FETCH csr_defined_balance_id INTO l_defined_balance_id;
	    if csr_defined_balance_id%NOTFOUND then
	           l_defined_balance_id := NULL;
            end if;
	    CLOSE csr_defined_balance_id;

--5957039
	   IF p_class_name = 'Retro Pre-Tax ZVW Refund'
	   THEN
		OPEN csr_defined_balance_id('Retro ZVW Refund','_ASG_YTD',retro_element_value_rec.business_group_id);
		FETCH csr_defined_balance_id INTO l_defined_balance_id;
		IF csr_defined_balance_id%NOTFOUND then
		  l_defined_balance_id := NULL;
		END IF;
		CLOSE csr_defined_balance_id;
	   END IF;
--5957039

    	    	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_defined_balance_id'||' '||l_defined_balance_id);
	    IF  l_defined_balance_id IS NOT NULL THEN
	        l_rate := pay_balance_pkg.get_value(l_defined_balance_id
	                                           ,csr_np_rec.np_assignment_action_id);
	    ELSE
	        l_rate :=NULL;
	    END IF;
	    --
	    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'archive element info 1 l_rate'||' '||l_rate);
	    hr_utility.set_location('Retro Inside archive_payslip_element_info2 l_rate'||l_rate,2122);
	    --
	    -- Special Tax Deduction Elemetns requires Pay Value and Percentage
	    -- Rate to be archived.
	    IF  p_element_name = 'Retro Special Tax Deduction' THEN
	        --
	        -- Get Individual Percentage Value
	        --
	        OPEN csr_add_element_values(csr_np_rec.np_assignment_action_id
	                                   ,p_class_name
	                                   ,p_element_name
	                                   ,'Percentage Rate'
	                                   ,p_date_earned);
		FETCH csr_add_element_values INTO l_pecentage_rate;
	        CLOSE csr_add_element_values;
	        --
   	    	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_pecentage_rate'||' '||l_pecentage_rate);

		IF l_pecentage_rate IS NOT NULL THEN
		l_pecentage_rate:=l_pecentage_rate||'%';
		END IF;
	    END IF;

            --FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_pecentage_rate'||' '||l_pecentage_rate);

	    l_priority:=retro_element_value_rec.priority;
	    l_reporting_name:=retro_element_value_rec.reporting_name;

	    l_date:=fnd_date.date_to_canonical(l_element_retro_entries(i));

	    --
	    END LOOP;

	 --FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_pecentage_rate'||' '||l_pecentage_rate);
  	END LOOP;

  	IF FND_NUMBER.canonical_to_number(l_sum_standard_rate)=0 THEN
  	l_sum_standard_rate:=NULL;
  	END IF;

  	IF FND_NUMBER.canonical_to_number(l_sum_special_rate)=0 THEN
  	l_sum_special_rate:=NULL;
  	END IF;

  	IF FND_NUMBER.canonical_to_number(l_sum_payable)=0 THEN
  	l_sum_payable:=NULL;
  	END IF;
        hr_utility.set_location('Retro Inside archive_payslip_element_info2 l_rate'||l_rate,2123);
  	hr_utility.set_location('Retro Inside archive_payslip_element_info2 l_sum_payable'||l_sum_payable,2123);

	    IF p_archive_flag = 'Y' OR(FND_NUMBER.canonical_to_number(l_sum_standard_rate) is not null
	    			    OR FND_NUMBER.canonical_to_number(l_sum_special_rate) is not null
	    			    OR FND_NUMBER.canonical_to_number(l_sum_payable)  is not null
	    			    OR l_rate is not null) THEN
	    -- Archive NL CALCULATIONS
	    --
	    --pay_action_information_api.create_action_information (..);
	    --
--5957039
IF	p_class_name IN ('Pre-Tax ZVW Refund', 'Retro Pre-Tax ZVW Refund')
	AND l_index BETWEEN 18720 AND 19000
THEN
	l_sum_payable := -l_sum_payable;
	l_rate := -l_rate;
END IF;
--5957039
	    	 pay_action_information_api.create_action_information (
	    	  p_action_information_id        => l_action_info_id
	    	 ,p_action_context_id            => p_arch_assign_action_id
	    	 ,p_action_context_type          => 'AAP'
	    	 ,p_object_version_number        => l_ovn
	    	 ,p_effective_date               => p_date_earned
	    	 ,p_source_id                    => NULL
	    	 ,p_source_text                  => NULL
	    	 ,p_action_information_category  => 'NL CALCULATIONS'
	    	 ,p_action_information4          =>l_index
	    	 ,p_action_information5          =>l_priority
	    	 ,p_action_information6          =>l_reporting_name
	    	 ,p_action_information7          =>l_pecentage_rate
	    	 ,p_action_information8          =>p_type
	    	 ,p_action_information9          =>l_date   --Retro Period
	    	 ,p_action_information10         =>l_sum_standard_rate
	    	 ,p_action_information11         =>l_sum_special_rate
	    	 ,p_action_information12         =>l_sum_payable
	    	 ,p_action_information13         =>fnd_number.number_to_canonical(l_rate)
                 ,p_action_information16         =>l_element_type_id
		 ,p_action_information17         =>l_run_result_id
             );


		IF p_element_name = 'Retro Employer ZVW Contribution Standard Tax' THEN
		          g_retro_zvw_er_cont_std_run  := FND_NUMBER.canonical_to_number(l_sum_standard_rate);
		          g_retro_zvw_er_cont_std_ytd  := l_rate;
             		END IF;
             		IF p_element_name = 'Retro Employer ZVW Contribution Special Tax' THEN
		          g_retro_zvw_er_cont_spl_run  := FND_NUMBER.canonical_to_number(l_sum_special_rate);
		          g_retro_zvw_er_cont_spl_ytd  := l_rate;
             		END IF;

		l_index := l_index + 1;

		END IF;
        END LOOP;
	END LOOP;
     END IF;
END IF;

ELSE
	IF p_child_count=0 THEN

	l_sum_standard_rate	:='0';
	l_sum_special_rate 	:='0';
	l_sum_payable  		:='0';

	FOR csr_np_rec IN csr_np_children(
				    p_master_assign_action_id,
				    p_payroll_action_id,
				    p_assignment_id,
			    	    p_effective_date) LOOP
	--hr_utility.set_location('Inside archive_payslip_element_info2 np_assignment_action_id'||csr_np_rec.np_assignment_action_id,2120);
	--hr_utility.set_location('Inside archive_payslip_element_info2 p_class_name'||p_class_name,2120);
	--hr_utility.set_location('Inside archive_payslip_element_info2 p_element_name'||p_element_name,2120);
	--hr_utility.set_location('Inside archive_payslip_element_info2 p_date_earned'||p_date_earned,2120);

	FOR element_value_rec IN csr_element_values(csr_np_rec.np_assignment_action_id
	                                           ,p_class_name
	                                           ,p_element_name
	                                           ,'Pay Value'
                                           	   ,p_date_earned) LOOP


	IF p_standard IS NOT NULL THEN
	    OPEN csr_sec_classification(element_value_rec.element_type_id
	                               ,p_standard
	                               ,p_date_earned);
	        FETCH csr_sec_classification INTO l_temp;
	        IF  csr_sec_classification%FOUND THEN
	            l_standard_rate := element_value_rec.value;
	            l_sum_standard_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_standard_rate) + FND_NUMBER.canonical_to_number(l_standard_rate));
	        ELSE
	            l_standard_rate :=NULL;
	        END IF;
	    CLOSE csr_sec_classification;
	    END IF;

	    IF p_special IS NOT NULL THEN
	    OPEN csr_sec_classification(element_value_rec.element_type_id
	                               ,p_special
	                               ,p_date_earned);
	        FETCH csr_sec_classification INTO l_temp;
	        IF  csr_sec_classification%FOUND THEN
	            l_special_rate := element_value_rec.value;
	            l_sum_special_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_special_rate) + FND_NUMBER.canonical_to_number(l_special_rate));
	        ELSE
	            l_special_rate :=NULL;
	        END IF;
	    CLOSE csr_sec_classification;
	    --
	    END IF;
	    --hr_utility.set_location('Inside archive_payslip_element_info2 p_payable_flag'||p_payable_flag,2120);

	    IF p_payable_flag='Y' THEN
		l_payable := element_value_rec.value;
		hr_utility.set_location('Inside archive_payslip_element_info2 l_payable'||l_payable,2120);
	        l_sum_payable:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_payable) + FND_NUMBER.canonical_to_number(nvl(l_payable,'0')));
	        hr_utility.set_location('Inside archive_payslip_element_info2 l_sum_payable'||l_sum_payable,2120);
	    END IF;

	    --hr_utility.set_location('Inside archive_payslip_element_info2 element_name'||element_value_rec.element_name,2120);
	    --hr_utility.set_location('Inside archive_payslip_element_info2 l_defined_balance_id'||l_defined_balance_id,2120);
	    --hr_utility.set_location('Inside archive_payslip_element_info2 business_group_id'||element_value_rec.business_group_id,2120);

	    OPEN csr_defined_balance_id(element_value_rec.element_name,'_ASG_YTD',element_value_rec.business_group_id);
	    FETCH csr_defined_balance_id INTO l_defined_balance_id;
	    if csr_defined_balance_id%NOTFOUND then
	           l_defined_balance_id := NULL;
            end if;
	    CLOSE csr_defined_balance_id;

--5957039
	IF p_class_name = 'Pre-Tax ZVW Refund'
	THEN
	    OPEN csr_defined_balance_id('ZVW Refund','_ASG_YTD',element_value_rec.business_group_id);
	    FETCH csr_defined_balance_id INTO l_defined_balance_id;
	    if csr_defined_balance_id%NOTFOUND then
	           l_defined_balance_id := NULL;
            end if;
	    CLOSE csr_defined_balance_id;
	ELSIF p_class_name = 'Retro Pre-Tax ZVW Refund'
	THEN
		OPEN csr_defined_balance_id('Retro ZVW Refund','_ASG_YTD',element_value_rec.business_group_id);
		FETCH csr_defined_balance_id INTO l_defined_balance_id;
		if csr_defined_balance_id%NOTFOUND then
		     l_defined_balance_id := NULL;
		end if;
		CLOSE csr_defined_balance_id;
	END IF;
--5957039

    	    --hr_utility.set_location('Inside archive_payslip_element_info2 l_rate'||l_rate,2121);
	    --hr_utility.set_location('Inside archive_payslip_element_info2 l_defined_balance_id'||l_defined_balance_id,2121);
    	    --hr_utility.set_location('Inside archive_payslip_element_info2 np_assignment_action_id'||csr_np_rec.np_assignment_action_id,2121);

	    IF  l_defined_balance_id IS NOT NULL THEN
	        l_rate := pay_balance_pkg.get_value(l_defined_balance_id
	                                           ,csr_np_rec.np_assignment_action_id);
	    ELSE
	        l_rate :=NULL;
	    END IF;
	    --
	    --FND_FILE.PUT_LINE(FND_FILE.LOG, 'archive_element_info 2 l_rate'||' '||l_rate);
	    --hr_utility.set_location('Inside archive_payslip_element_info2 l_rate'||l_rate,2122);
	    --
	    -- Special Tax Deduction Elemetns requires Pay Value and Percentage
	    -- Rate to be archived.
	    IF  p_element_name = 'Special Tax Deduction' THEN
	        --
	        -- Get Individual Percentage Value
	        --
	        OPEN csr_add_element_values(csr_np_rec.np_assignment_action_id
	                                   ,p_class_name
	                                   ,p_element_name
	                                   ,'Percentage Rate'
	                                   ,p_date_earned);
		FETCH csr_add_element_values INTO l_pecentage_rate;
	        CLOSE csr_add_element_values;
	        --
		IF l_pecentage_rate IS NOT NULL THEN
		l_pecentage_rate:=l_pecentage_rate||'%';
		END IF;
	    END IF;
	    l_priority:=element_value_rec.priority;
	    l_reporting_name:=element_value_rec.reporting_name;
            --hr_utility.set_location('Inside archive_payslip_element_info element_value_rec.RDate'||element_value_rec.RDate,2123);
	    l_date:=element_value_rec.RDate;
            --hr_utility.set_location('Inside archive_payslip_element_info l_date'||l_date,2123);
	    --
	    END LOOP;
  	END LOOP;
  	IF FND_NUMBER.canonical_to_number(l_sum_standard_rate)=0 THEN
  	l_sum_standard_rate:=NULL;
  	END IF;

  	IF FND_NUMBER.canonical_to_number(l_sum_special_rate)=0 THEN
  	l_sum_special_rate:=NULL;
  	END IF;

  	IF FND_NUMBER.canonical_to_number(l_sum_payable)=0 THEN
  	l_sum_payable:=NULL;
  	END IF;
        --hr_utility.set_location('Inside archive_payslip_element_info2 l_rate'||l_rate,2123);
  	--hr_utility.set_location('Inside archive_payslip_element_info2 l_sum_payable'||l_sum_payable,2123);

	    IF p_archive_flag = 'Y' OR(FND_NUMBER.canonical_to_number(l_sum_standard_rate) is not null
	    			    OR FND_NUMBER.canonical_to_number(l_sum_special_rate) is not null
	    			    OR FND_NUMBER.canonical_to_number(l_sum_payable)  is not null
	    			    OR l_rate is not null) THEN
	    -- Archive NL CALCULATIONS
	    --
	    --pay_action_information_api.create_action_information (..);
	    --
--5957039
IF	p_class_name IN ('Pre-Tax ZVW Refund', 'Retro Pre-Tax ZVW Refund')
	AND l_index BETWEEN 18720 AND 19000
THEN
	l_sum_payable := -l_sum_payable;
	l_rate := -l_rate;
END IF;
--5957039
	    	 pay_action_information_api.create_action_information (
	    	  p_action_information_id        => l_action_info_id
	    	 ,p_action_context_id            => p_arch_assign_action_id
	    	 ,p_action_context_type          => 'AAP'
	    	 ,p_object_version_number        => l_ovn
	    	 ,p_effective_date               => p_date_earned
	    	 ,p_source_id                    => NULL
	    	 ,p_source_text                  => NULL
	    	 ,p_action_information_category  => 'NL CALCULATIONS'
	    	 ,p_action_information4          =>l_index
	    	 ,p_action_information5          =>l_priority
	    	 ,p_action_information6          =>l_reporting_name
	    	 ,p_action_information7          =>l_pecentage_rate
	    	 ,p_action_information8          =>p_type
	    	 ,p_action_information9          =>l_date   --Retro Period
	    	 ,p_action_information10         =>l_sum_standard_rate
	    	 ,p_action_information11         =>l_sum_special_rate
	    	 ,p_action_information12         =>l_sum_payable
	    	 ,p_action_information13         =>fnd_number.number_to_canonical(l_rate));


		IF p_element_name = 'Employer ZVW Contribution Standard Tax' THEN
		          g_zvw_er_cont_std_run := FND_NUMBER.canonical_to_number(l_sum_standard_rate);
		          g_zvw_er_cont_std_ytd := l_rate;
		END IF;
  	           	IF p_element_name = 'Employer ZVW Contribution Special Tax' THEN
		          g_zvw_er_cont_spl_run := FND_NUMBER.canonical_to_number(l_sum_special_rate);
		          g_zvw_er_cont_spl_ytd := l_rate;
             		END IF;

		l_index := l_index + 1;

	END IF;


	END IF;

END IF;
END archive_element_info;
--

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_PAYSLIP_ELEMENT_INFO     	        			       	|
|Type			: Procedure														|
|Description    : Procedure calls  ARCHIVE_ELEMENT_INFO to archive 				|
|		  NL CALCULATIONS for each of the statutory elements					|
-------------------------------------------------------------------------------*/

PROCEDURE archive_payslip_element_info(
					p_arch_assign_action_id 	IN NUMBER
					,p_run_assign_action_id		IN NUMBER
					,p_date_earned              IN DATE
					,p_record_count             IN NUMBER
					,p_master_assign_action_id 	IN NUMBER
					,p_payroll_action_id       	IN NUMBER
					,p_assignment_id           	IN NUMBER
					,p_effective_date	      	IN DATE
					,p_child_count			IN NUMBER) IS


BEGIN
	--
	FOR l_index IN 1 .. g_stat_element_table.count
	LOOP
		--
		archive_element_info(p_arch_assign_action_id
							,p_run_assign_action_id
							,g_stat_element_table(l_index).classification_name
							,g_stat_element_table(l_index).element_name
							,p_date_earned
							,g_stat_element_table(l_index).main_index
							,g_stat_element_table(l_index).element_type
							,g_stat_element_table(l_index).archive_flag
							,g_stat_element_table(l_index).standard
							,g_stat_element_table(l_index).special
							,g_stat_element_table(l_index).standard2
							,g_stat_element_table(l_index).special2
							,g_stat_element_table(l_index).payable_flag
							,p_record_count
							,p_master_assign_action_id
							,p_payroll_action_id
							,p_assignment_id
							,p_effective_date
							,p_child_count);

		--
	END LOOP;

	--
	--
END archive_payslip_element_info;

/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_BALANCE_INFO     		      	       					|
|Type			: Procedure														|
|Description    : Procedure archives NL CALCULATIONS for balances in Payment and|
|		  		  Deduction section of the payslip								|
-------------------------------------------------------------------------------*/

PROCEDURE archive_balance_info(  p_arch_assign_action_id	IN NUMBER
								,p_run_assign_action_id 	IN NUMBER
								,p_balance_name         	IN VARCHAR2
								,p_dimension            	IN VARCHAR2
								,p_standard_bal_name    	IN VARCHAR2
								,p_special_bal_name     	IN VARCHAR2
								,p_non_tax_bal_name     	IN VARCHAR2
								,p_multiply_factor      	IN NUMBER
								,p_index                	IN NUMBER
								,p_type       	                IN VARCHAR2
								,p_record_count              	IN NUMBER
								,p_date_earned	 		IN DATE
								,p_archive_flag			IN VARCHAR2
								,p_payable_flag			IN VARCHAR2
								,p_payroll_action_id		IN NUMBER
								,p_assignment_id		IN NUMBER
								,p_effective_date		IN DATE) IS

	--
	CURSOR csr_get_context_id(p_run_assign_action_id VARCHAR2
							 ,p_context_name         VARCHAR2) IS
	SELECT pac.context_id           context_id
		  ,pac.context_value        value
	FROM   ff_contexts              ff
		  ,pay_action_contexts      pac
	WHERE  ff.context_name          = p_context_name
	AND    pac.context_id           = ff.context_id
	AND    pac.assignment_Action_id = p_run_assign_action_id;
	--
	CURSOR csr_get_translated_bal_name (p_balance_name VARCHAR2) IS
	SELECT NVL(pbt_tl.reporting_name,pbt_tl.balance_name) bal_name
	FROM   pay_balance_types        pbt
		  ,pay_balance_types_tl     pbt_tl
	WHERE  pbt.balance_name         = p_balance_name
	AND    pbt.balance_type_id      = pbt_tl.balance_type_id
	AND    pbt_tl.language          = USERENV('LANG');
	--
	CURSOR csr_get_sit_type_name (p_balance_name     VARCHAR2
							   ,p_assgn_action_id  NUMBER
							   ,p_date_earned      DATE
							   ,p_si_type	    VARCHAR2) IS
	SELECT prrv1.result_value        si_type_name
	FROM   pay_balance_feeds_f      pbf
		 ,pay_balance_types        pbt
		 ,pay_input_values_f       piv
		 ,pay_input_values_f       piv1
		 ,pay_input_values_f       piv2
		 ,pay_element_types_f      pet
		 ,pay_run_results          prr
		 ,pay_run_result_values    prrv
		 ,pay_run_result_values    prrv1
	WHERE  pbf.balance_type_id      = pbt.balance_type_id
	AND    pbt.balance_name         like p_balance_name||'%'
	AND    piv.input_value_id       = pbf.input_value_id
	AND    piv.name                 ='Pay Value'
	AND    pet.element_type_id      = piv.element_type_id
	AND    pet.classification_id <>(SELECT classification_id
		   from pay_element_classifications
		   where classification_name ='Balance Initialization'
		   and business_group_id is null
		   and legislation_code is null)
	AND    piv1.element_type_id     = pet.element_type_id
	AND    piv1.name                = 'SI Type Name'
	AND    piv2.element_type_id     = pet.element_type_id
	AND    piv2.name                = 'SI Type'
	AND    prr.element_type_id      = pet.element_type_id
	AND    prr.assignment_action_id = p_assgn_action_id
	AND    prrv.run_result_id       = prr.run_result_id
	AND    prrv.input_value_id      = piv2.input_value_id
	AND    prrv.result_value        = p_si_type
	AND    prrv1.run_result_id      = prrv.run_result_id
	AND    prrv1.input_value_id     = piv1.input_value_id
	AND    p_date_earned             BETWEEN pbf.effective_start_date
									AND     pbf.effective_end_date
	AND    p_date_earned             BETWEEN pet.effective_start_date
									AND     pet.effective_end_date
	AND    p_date_earned             BETWEEN piv.effective_start_date
									AND     piv.effective_end_date
	AND    p_date_earned             BETWEEN piv1.effective_start_date
									AND     piv1.effective_end_date
	AND    p_date_earned             BETWEEN piv2.effective_start_date
								 AND     piv2.effective_end_date;

	CURSOR csr_emp_phc_applies(p_assgn_action_id NUMBER
				  ,p_date_earned     DATE) IS
	SELECT 1
	FROM pay_run_results prr
		,pay_element_types_f pet
	WHERE
		pet.element_name = 'Private Health Insurance'
	AND 	prr.assignment_action_id=p_assgn_action_id
	AND 	prr.element_type_id=pet.element_type_id
	AND     p_date_earned   BETWEEN pet.effective_start_date
				AND     pet.effective_end_date;
	--
	-- Cursor to retrieve all N (Normal)and P (Process separate) Child Actions
	-- for a given assignment action.
	--
	CURSOR csr_np_children (p_assignment_action_id NUMBER
				   ,p_payroll_action_id    NUMBER
				   ,p_assignment_id        NUMBER
				   ,p_effective_date       DATE) IS
	SELECT paa.assignment_action_id np_assignment_action_id
	FROM   pay_assignment_actions   paa
		  ,pay_run_types_f          prt
	WHERE  paa.source_action_id     = p_assignment_action_id
	AND    paa.payroll_action_id    = p_payroll_action_id
	AND    paa.assignment_id        = p_assignment_id
	AND    paa.run_type_id          = prt.run_type_id
	AND    prt.run_method           IN ('N','P')
	AND    p_effective_date         BETWEEN prt.effective_start_date
					AND     prt.effective_end_date
	order by np_assignment_action_id;

	-- Cursor to  return all the Runs for a Pre Payment Process which
	-- is being archived.
	--
	CURSOR csr_assignment_actions(lp_locking_action_id NUMBER) IS
	SELECT pre.locked_action_id        pre_assignment_action_id,
		   pay.locked_action_id        master_assignment_action_id,
		   assact.assignment_id        assignment_id,
		   assact.payroll_action_id    pay_payroll_action_id,
		   paa.effective_date          effective_date,
		   ppaa.effective_date         pre_effective_date,
		   paa.date_earned             date_earned,
		   paa.time_period_id          time_period_id,
		   paa.payroll_id		   payroll_id
	FROM   pay_action_interlocks       pre,
		   pay_action_interlocks       pay,
		   pay_payroll_actions         paa,
		   pay_payroll_actions         ppaa,
		   pay_assignment_actions      assact,
		   pay_assignment_actions      passact
	WHERE  pre.locked_action_id      = pay.locking_action_id
	AND    pre.locking_action_id     = lp_locking_action_id
	AND    pre.locked_action_id      = passact.assignment_action_id
	AND    passact.assignment_id	 =assact.assignment_id
	AND    passact.payroll_action_id = ppaa.payroll_action_id
	AND    ppaa.action_type          IN ('P','U')
	AND    pay.locked_action_id      = assact.assignment_action_id
	AND    assact.payroll_action_id  = paa.payroll_action_id
	AND    assact.source_action_id   IS NULL
	ORDER BY pay.locked_action_id;

	v_csr_assignment_actions csr_assignment_actions%ROWTYPE;

	--
	l_year			NUMBER;
	l_sum_year		NUMBER;
	l_dummy			NUMBER;
	l_archive_flag		VARCHAR2(10);
	l_payable		NUMBER;
	l_sum_payable		NUMBER;
	l_si_type		pay_action_contexts.context_value%TYPE;
	l_si_type_name		pay_run_result_values.result_value%TYPE;
	l_def_bal_id		NUMBER;

	l_standard_rate_run	NUMBER;
	l_sum_standard_rate_run	NUMBER;
	l_standard_rate_ytd	NUMBER;
	l_special_rate_run	NUMBER;
	l_sum_special_rate_run	NUMBER;
	l_special_rate_ytd	NUMBER;
	l_non_tax_rate_run	NUMBER;
	l_sum_non_tax_rate_run	NUMBER;
	l_non_tax_rate_ytd	NUMBER;

	l_balance_name		pay_balance_types.balance_name%TYPE;
	p_balance_sit_name	pay_balance_types.balance_name%TYPE;
	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_index			NUMBER;
	l_count 		NUMBER;
	csr_np_rec		csr_np_children%ROWTYPE;
	l_np_child_id		NUMBER;

BEGIN
	--
	--hr_utility.set_location('Inside 	 p_dimension'||p_dimension,2110);

	l_index:=p_index;

	IF  p_dimension = '_ASG_SIT_YTD' THEN

		OPEN csr_np_children(p_run_assign_action_id,p_payroll_action_id,
		p_assignment_id,p_effective_date);
		FETCH csr_np_children into l_np_child_id;
		CLOSE csr_np_children;

		hr_utility.set_location('Inside archive_balance_info1 p_balance_name'||p_balance_name,2222);
		hr_utility.set_location('Inside archive_balance_info1 l_count'||l_count,2222);

		IF l_np_child_id is not null THEN

			hr_utility.set_location('Inside archive_balance_info1 l_count'||l_count,2223);
			hr_utility.set_location('Inside archive_balance_info1 np_assignment_action_id'||l_np_child_id,2223);

			-- Loop through pay_action_context table for all SI Type
			FOR context_rec IN csr_get_context_id(l_np_child_id,'SOURCE_TEXT')
			LOOP
				--
				l_sum_standard_rate_run:=0;
				l_sum_special_rate_run :=0;
				l_sum_non_tax_rate_run :=0;
				l_sum_payable	       :=0;
				l_sum_year	       :=0;

				-- Loop through Payroll Run Actions locked by the Arch Asg Action
				OPEN csr_assignment_actions(p_arch_assign_action_id);
				LOOP
					FETCH csr_assignment_actions INTO v_csr_assignment_actions;
					EXIT WHEN csr_assignment_actions%NOTFOUND ;

					/*FOR csr_np_rec IN csr_np_children(
									p_run_assign_action_id,
									p_payroll_action_id,
									p_assignment_id,
								p_effective_date) LOOP*/
					-- Loop through Run Types in the Payroll Run Chosen
					OPEN csr_np_children(v_csr_assignment_actions.master_assignment_action_id,
					v_csr_assignment_actions.pay_payroll_action_id,
					p_assignment_id,v_csr_assignment_actions.effective_date);
					LOOP
						FETCH csr_np_children into csr_np_rec;
						EXIT when csr_np_children%NOTFOUND or csr_np_children%NOTFOUND IS NULL;

						--hr_utility.set_location('Inside archive_balance_info p_standard_bal_name'||p_standard_bal_name,2120);

						l_si_type           := context_rec.value;
						l_standard_rate_run := 0;
						l_special_rate_run := 0;
						l_non_tax_rate_run := 0;

						-- If Standard Balance exist for this balance then retrive them
						IF  p_standard_bal_name IS NOT NULL THEN
							--

							l_def_bal_id := get_defined_balance_id (p_standard_bal_name,'_ASG_SIT_RUN');
							l_standard_rate_run := pay_balance_pkg.get_value(
							l_def_bal_id, csr_np_rec.np_assignment_action_id
							,null,null,context_rec.context_id,context_rec.value
							,null,null);

							l_standard_rate_run := NVL(l_standard_rate_run,0) * p_multiply_factor;

							-- YTD Figure
							--
							l_def_bal_id := get_defined_balance_id (p_standard_bal_name,'_ASG_SIT_YTD');
							l_standard_rate_ytd := pay_balance_pkg.get_value(
							l_def_bal_id, csr_np_rec.np_assignment_action_id
							,null,null,context_rec.context_id,context_rec.value
							,null,null);
							l_standard_rate_ytd := NVL(l_standard_rate_ytd,0) * p_multiply_factor;
							--
						END IF;

						--hr_utility.set_location('Inside archive_balance_info p_special_bal_name'||p_special_bal_name,2130);

						-- If Special Balance exist for this balance then retrive them
						IF  p_special_bal_name IS NOT NULL THEN
							--
							l_def_bal_id := get_defined_balance_id(p_special_bal_name,'_ASG_SIT_RUN');
							l_special_rate_run := pay_balance_pkg.get_value(
							l_def_bal_id, csr_np_rec.np_assignment_action_id
							,null,null,context_rec.context_id,context_rec.value
							,null,null);
							l_special_rate_run := NVL(l_special_rate_run,0) * p_multiply_factor;
							-- YTD Figure
							--
							l_def_bal_id := get_defined_balance_id(p_special_bal_name,'_ASG_SIT_YTD');
							l_special_rate_ytd := pay_balance_pkg.get_value(
							 l_def_bal_id, csr_np_rec.np_assignment_action_id
							 ,null,null,context_rec.context_id,context_rec.value
							 ,null,null);
							l_special_rate_ytd := NVL(l_special_rate_ytd,0) * p_multiply_factor;
							--
						END IF;

						--hr_utility.set_location('Inside archive_balance_info p_non_tax_bal_name'||p_non_tax_bal_name,2140);

						-- If Non Taxable Balance exist for this balance then retrive them
						IF  p_non_tax_bal_name IS NOT NULL THEN
							--
							l_def_bal_id := get_defined_balance_id(p_non_tax_bal_name,'_ASG_SIT_RUN');
							l_non_tax_rate_run := pay_balance_pkg.get_value(
							l_def_bal_id, csr_np_rec.np_assignment_action_id
							,null,null,context_rec.context_id,context_rec.value
							,null,null);
							l_non_tax_rate_run      := NVL(l_non_tax_rate_run,0) * p_multiply_factor;

							-- YTD Figure
							--
							l_def_bal_id := get_defined_balance_id(p_non_tax_bal_name,'_ASG_SIT_YTD');
							l_non_tax_rate_ytd := pay_balance_pkg.get_value(
							l_def_bal_id, csr_np_rec.np_assignment_action_id
							,null,null,context_rec.context_id,context_rec.value
							,null,null);
							l_non_tax_rate_ytd      := NVL(l_non_tax_rate_ytd,0) * p_multiply_factor;
							--

						END IF;

						--hr_utility.set_location('Inside archive_balance_info p_standard_bal_name'||p_standard_bal_name,2150);

						--
						IF  p_standard_bal_name IS NULL
						AND p_special_bal_name  IS NULL
						AND p_non_tax_bal_name  IS NULL THEN
							--
							l_def_bal_id := get_defined_balance_id (p_balance_name
							,'_ASG_SIT_RUN');
							IF p_payable_flag = 'Y' THEN
								l_payable := pay_balance_pkg.get_value(
								l_def_bal_id,csr_np_rec.np_assignment_action_id
								,null,null,context_rec.context_id,context_rec.value
								,null,null);
								l_payable := nvl(l_payable,0) * p_multiply_factor;
							END IF;
							--
							l_def_bal_id := get_defined_balance_id (p_balance_name,'_ASG_SIT_YTD');
							l_year := pay_balance_pkg.get_value(
							l_def_bal_id, csr_np_rec.np_assignment_action_id
							,null,null,context_rec.context_id,context_rec.value
							,null,null);
							l_year := nvl(l_year,0) * p_multiply_factor;
							--
						ELSE
							--
							IF p_payable_flag = 'Y' THEN
								l_payable := (nvl(l_standard_rate_run,0) +
								nvl(l_special_rate_run,0) +
								nvl(l_non_tax_rate_run,0));
							END IF;
							l_year := (nvl(l_standard_rate_ytd,0) +
							nvl(l_special_rate_ytd,0) +
							nvl(l_non_tax_rate_ytd,0));
							--
						END IF;

						l_sum_standard_rate_run:=l_sum_standard_rate_run + l_standard_rate_run;
						l_sum_special_rate_run :=l_sum_special_rate_run + l_special_rate_run;
						l_sum_non_tax_rate_run :=l_sum_non_tax_rate_run + l_non_tax_rate_run;
						l_sum_payable	       :=l_sum_payable + l_payable;
						l_sum_year	       :=l_year;


						IF p_standard_bal_name IS NULL AND l_sum_standard_rate_run=0 THEN
							l_sum_standard_rate_run:=NULL;
						END IF;

						IF p_special_bal_name IS NULL AND l_sum_special_rate_run=0 THEN
							l_sum_special_rate_run:=NULL;
						END IF;

						IF p_payable_flag='N' AND l_sum_payable=0 THEN
							l_sum_payable:=NULL;
						END IF;
						--
						--hr_utility.set_location('Inside archive_balance_info p_standard_bal_name'||p_standard_bal_name,2160);

						-- Retreive SI Type Name from run results
						--
						p_balance_sit_name:=p_balance_name;

						IF p_balance_name='Employee SI Contribution' THEN
							p_balance_sit_name:='Employee SI Contribution Standard Tax';
						END IF;

						OPEN csr_get_sit_type_name(p_balance_sit_name
						,csr_np_rec.np_assignment_action_id,p_date_earned,l_si_type);
						FETCH csr_get_sit_type_name INTO l_si_type_name;
						CLOSE csr_get_sit_type_name;
						--
						--hr_utility.set_location('Inside archive_balance_info p_standard_bal_name'||p_standard_bal_name,2170);
						--
						-- Get Balance Name to be reported in the Payslip
						--
						l_balance_name:=p_balance_name;

						OPEN csr_get_translated_bal_name (p_balance_name);
						FETCH csr_get_translated_bal_name INTO l_balance_name;
						IF  csr_get_translated_bal_name%NOTFOUND THEN
							l_balance_name :=hr_general.decode_lookup(
							'HR_NL_REPORT_LABELS',UPPER(p_balance_name));
							END IF;
						CLOSE csr_get_translated_bal_name;
					END LOOP;
					CLOSE csr_np_children;
				END LOOP;--End of Cursor csr_assignment_actions Loop
				CLOSE csr_assignment_actions;

				hr_utility.set_location('Inside archive_balance_info1 l_sum_standard_rate_run'||l_sum_standard_rate_run,2229);

				IF l_si_type_name='ZVW' THEN
				  IF p_balance_name = 'Employer SI Contribution' and l_index < 18700 THEN
				    l_index := 18700;
				  END IF;
				  IF p_balance_name = 'Retro Employer SI Contribution' and l_index < 18750 THEN
				    l_index := 18750;
				  END IF;
				  IF p_balance_name = 'Employee SI Contribution' and l_index < 18800 THEN
				    l_index := 18800;
				  END IF;
				  IF p_balance_name = 'Retro Employee SI Contribution' and l_index < 18850 THEN
				    l_index := 18850;
				  END IF;
				  IF p_balance_name = 'Net Employee SI Contribution' and l_index < 18900 THEN
				    l_index := 18900;
				  END IF;
				  IF p_balance_name = 'Retro Net Employee SI Contribution' and l_index < 18950 THEN
				    l_index := 18950;
				  END IF;
				END IF;

				IF p_archive_flag = 'Y' OR (l_sum_standard_rate_run <> 0
				OR  l_sum_special_rate_run  <> 0
				OR  l_sum_payable  <> 0
				OR  l_sum_year  <> 0 ) THEN
					-- Archive NL CALCULATIONS
					--
					-- l_si_type      - SI Type
					-- l_si_type_name - SI Type Name
					-- l_payable      - Payable Figure
					-- l_year         - Annual Figure
					--pay_action_information_api.create_action_information (..);
					--
					pay_action_information_api.create_action_information (
					p_action_information_id        => l_action_info_id
					,p_action_context_id            => p_arch_assign_action_id
					,p_action_context_type          => 'AAP'
					,p_object_version_number        => l_ovn
					,p_effective_date               => p_date_earned
					,p_source_id                    => NULL
					,p_source_text                  => NULL
					,p_action_information_category  => 'NL CALCULATIONS'
					,p_action_information4          =>l_index
					,p_action_information5          =>NULL
					,p_action_information6          =>l_balance_name
					,p_action_information7          =>l_si_type_name
					,p_action_information8          =>p_type
					,p_action_information9          =>null
					,p_action_information10         =>fnd_number.number_to_canonical(l_sum_standard_rate_run)
					,p_action_information11         =>fnd_number.number_to_canonical(l_sum_special_rate_run)
					,p_action_information12         =>fnd_number.number_to_canonical(l_sum_payable)
					,p_action_information13         =>fnd_number.number_to_canonical(l_sum_year));

					l_index:=l_index+1;
				END IF;

			END LOOP;--End of Cursor Loop  csr_get_context_id
  		END IF;
	--
	ELSE -- Non Context Dimension
		l_sum_standard_rate_run:=0;
		l_sum_special_rate_run :=0;
		l_sum_non_tax_rate_run :=0;
		l_sum_payable	   :=0;
		l_sum_year	           :=0;
		--hr_utility.set_location('Inside archive_balance_info p_standard_bal_name'||p_standard_bal_name,2180);
		/*    FOR csr_np_rec IN csr_np_children(
		p_run_assign_action_id,
		p_payroll_action_id,
		p_assignment_id,
		p_effective_date) LOOP*/
		-- Loop through Payroll Run Actions locked by the Arch Asg Action
		OPEN csr_assignment_actions(p_arch_assign_action_id);
		LOOP
			FETCH csr_assignment_actions INTO v_csr_assignment_actions;
			EXIT WHEN csr_assignment_actions%NOTFOUND ;

			-- Loop through all the Child Action Actions under the Payroll Run Master
			OPEN csr_np_children(v_csr_assignment_actions.master_assignment_action_id,
			v_csr_assignment_actions.pay_payroll_action_id,
			p_assignment_id,v_csr_assignment_actions.effective_date);
			LOOP
				FETCH csr_np_children into csr_np_rec;
				EXIT when csr_np_children%NOTFOUND or csr_np_children%NOTFOUND IS NULL;

				l_standard_rate_run := 0;
				l_special_rate_run := 0;
				l_non_tax_rate_run := 0;

				-- If Standard balance exist for this balance then retrive them
				IF  p_standard_bal_name IS NOT NULL THEN
					--
					l_def_bal_id := get_defined_balance_id (p_standard_bal_name,'_ASG_RUN');
					l_standard_rate_run :=  pay_balance_pkg.get_value(
					l_def_bal_id, csr_np_rec.np_assignment_action_id);
					l_standard_rate_run := NVL(l_standard_rate_run,0) * p_multiply_factor;
					-- YTD Value
					--
					l_def_bal_id := get_defined_balance_id (p_standard_bal_name,'_ASG_YTD');
					l_standard_rate_ytd :=  pay_balance_pkg.get_value(
					l_def_bal_id, csr_np_rec.np_assignment_action_id);
					l_standard_rate_ytd := NVL(l_standard_rate_ytd,0) * p_multiply_factor;
					--

				END IF;

				--hr_utility.set_location('Inside archive_balance_info p_special_bal_name'||p_special_bal_name,2190);

				-- If Special Balance exist for this balance then retrive them
				IF  p_special_bal_name IS NOT NULL THEN
					--
					l_def_bal_id := get_defined_balance_id(p_special_bal_name,'_ASG_RUN');
					l_special_rate_run := pay_balance_pkg.get_value(
					l_def_bal_id, csr_np_rec.np_assignment_action_id);
					l_special_rate_run := NVL(l_special_rate_run,0) * p_multiply_factor;
					-- YTD Value
					--
					l_def_bal_id := get_defined_balance_id(p_special_bal_name,'_ASG_YTD');
					l_special_rate_ytd := pay_balance_pkg.get_value(l_def_bal_id, csr_np_rec.np_assignment_action_id);
					l_special_rate_ytd := NVL(l_special_rate_ytd,0) * p_multiply_factor;
					--
				END IF;

				--hr_utility.set_location('Inside archive_balance_info p_non_tax_bal_name'||p_non_tax_bal_name,2200);

				-- If Non Taxable Balance exist for this balance then retrive them
				IF  p_non_tax_bal_name IS NOT NULL THEN
					--
					l_def_bal_id := get_defined_balance_id(p_non_tax_bal_name,'_ASG_RUN');
					l_non_tax_rate_run := pay_balance_pkg.get_value(l_def_bal_id, csr_np_rec.np_assignment_action_id);
					l_non_tax_rate_run := NVL(l_non_tax_rate_run,0) * p_multiply_factor;
					-- YTD Value
					--
					l_def_bal_id := get_defined_balance_id(p_non_tax_bal_name,'_ASG_YTD');
					l_non_tax_rate_ytd := pay_balance_pkg.get_value(l_def_bal_id, csr_np_rec.np_assignment_action_id);
					l_non_tax_rate_ytd := NVL(l_non_tax_rate_ytd,0) * p_multiply_factor;
					--

				END IF;
				--

				IF  p_standard_bal_name IS NULL
				AND p_special_bal_name  IS NULL
				AND p_non_tax_bal_name  IS NULL THEN

					--hr_utility.set_location('Inside archive_balance_info p_balance_name'||p_balance_name,2150);
					--hr_utility.set_location('Inside archive_balance_info l_def_bal_id'||l_def_bal_id,2150);
					--hr_utility.set_location('Inside archive_balance_info p_run_assign_action_id'||p_run_assign_action_id,2150);
					--hr_utility.set_location('Inside archive_balance_info p_multiply_factor'||p_multiply_factor,2150);
					--
					l_def_bal_id := get_defined_balance_id (p_balance_name,'_ASG_RUN');
					--hr_utility.set_location('Inside archive_balance_info l_def_bal_id'||l_def_bal_id,2152);
					IF p_payable_flag = 'Y' THEN
						l_payable := pay_balance_pkg.get_value(l_def_bal_id
						, csr_np_rec.np_assignment_action_id);
						IF p_balance_name = 'Gross Salary' THEN
						    l_payable := l_payable - (g_zvw_er_cont_std_run +
						                                             g_zvw_er_cont_spl_run +
						                                             g_retro_zvw_er_cont_std_run +
						                                             g_retro_zvw_er_cont_spl_run +
                                                                     g_travel_allowance +
                                                                     g_retro_travel_allowance);
						END IF;
					END IF;

					--hr_utility.set_location('Inside archive_balance_info l_payable'||l_payable,2152);
					--
					l_def_bal_id := get_defined_balance_id (p_balance_name,'_ASG_YTD');
					--hr_utility.set_location('Inside archive_balance_info l_def_bal_id'||l_def_bal_id,2153);

					l_year := pay_balance_pkg.get_value(l_def_bal_id, csr_np_rec.np_assignment_action_id);
					IF p_balance_name = 'Gross Salary' THEN
		    			    l_year := l_year - (g_zvw_er_cont_std_ytd +
					                                  g_zvw_er_cont_spl_ytd +
					                                  g_retro_zvw_er_cont_std_ytd +
					                                  g_retro_zvw_er_cont_spl_ytd +
                                                      g_travel_allowance_ytd +
                                                      g_retro_travel_allowance_ytd);
					 END IF;

					l_year := nvl(l_year,0) * p_multiply_factor;

					--hr_utility.set_location('Inside archive_balance_info l_payable'||l_payable,2153);
					--hr_utility.set_location('Inside archive_balance_info l_year'||l_year,2153);
					--
				ELSE

					--
					IF p_payable_flag = 'Y' THEN
						l_payable := (nvl(l_standard_rate_run,0) +
						nvl(l_special_rate_run,0) +
						nvl(l_non_tax_rate_run,0));
					END IF;

					l_year := (nvl(l_standard_rate_ytd,0) +
					nvl(l_special_rate_ytd,0) +
					nvl(l_non_tax_rate_ytd,0));
					--

				END IF;
				--

				l_sum_standard_rate_run :=l_sum_standard_rate_run + l_standard_rate_run;
				l_sum_special_rate_run  :=l_sum_special_rate_run + l_special_rate_run;
				l_sum_non_tax_rate_run  :=l_sum_non_tax_rate_run + l_non_tax_rate_run;
				l_sum_payable	      :=l_sum_payable + l_payable;
				l_sum_year			:=l_year;

				IF p_standard_bal_name IS NULL AND l_sum_standard_rate_run=0 THEN
					l_sum_standard_rate_run:=NULL;
				END IF;

				IF p_special_bal_name IS NULL AND l_sum_special_rate_run=0 THEN
					l_sum_special_rate_run:=NULL;
				END IF;

				IF p_payable_flag='N' AND l_sum_payable=0 THEN
					l_sum_payable:=NULL;
				END IF;

				--hr_utility.set_location('Inside archive_balance_info l_payable'||l_payable,2160);
				--
				/*IF p_payable_flag = 'N' THEN
				l_payable:=NULL;
				END IF;*/
				--
				l_balance_name:=p_balance_name;

				-- Get Balance Name to be reported in the Payslip
				--
				OPEN csr_get_translated_bal_name (p_balance_name);
				FETCH csr_get_translated_bal_name INTO l_balance_name;
				IF  csr_get_translated_bal_name%NOTFOUND THEN
					l_balance_name :=hr_general.decode_lookup(
					'HR_NL_REPORT_LABELS',UPPER(p_balance_name));
				END IF;
				CLOSE csr_get_translated_bal_name;

				l_archive_flag:=p_archive_flag;

				IF l_balance_name = 'Employee Private Health Contribution' THEN
					OPEN csr_emp_phc_applies(csr_np_rec.np_assignment_action_id
					,p_date_earned);
					FETCH csr_emp_phc_applies into l_dummy;
					IF csr_emp_phc_applies%NOTFOUND THEN
						l_archive_flag:= 'N';
					END IF;
					CLOSE csr_emp_phc_applies;
				END IF;

			END LOOP;
			CLOSE csr_np_children;
		END LOOP;--End of Cursor Loop csr_assignment_actions
		CLOSE csr_assignment_actions;

		IF l_archive_flag = 'Y' OR (l_sum_standard_rate_run <> 0
		OR  l_sum_special_rate_run  <> 0
		OR  l_sum_payable  <> 0
		OR  l_sum_year  <> 0) THEN
			-- Archive NL CALCULATIONS
			--
			-- l_payable - Payable figure
			-- l_year    - Annual figure
			--pay_action_information_api.create_action_information (..);
			--
			pay_action_information_api.create_action_information (
			p_action_information_id        => l_action_info_id
			,p_action_context_id            => p_arch_assign_action_id
			,p_action_context_type          => 'AAP'
			,p_object_version_number        => l_ovn
			,p_effective_date               => p_date_earned
			,p_source_id                    => NULL
			,p_source_text                  => NULL
			,p_action_information_category  => 'NL CALCULATIONS'
			,p_action_information4          =>l_index
			,p_action_information5          =>NULL
			,p_action_information6          =>l_balance_name
			,p_action_information7          =>NULL
			,p_action_information8          =>p_type
			,p_action_information9          =>null
			,p_action_information10         =>fnd_number.number_to_canonical(l_sum_standard_rate_run)
			,p_action_information11         =>fnd_number.number_to_canonical(l_sum_special_rate_run)
			,p_action_information12         =>fnd_number.number_to_canonical(l_sum_payable)
			,p_action_information13         =>fnd_number.number_to_canonical(l_sum_year));

			l_index:=l_index+1;

		END IF;

	--hr_utility.set_location('Inside archive_balance_info p_standard_bal_name'||p_standard_bal_name,2170);
	END IF;

END archive_balance_info;

/*---------------------------------------------------------------------------------
|Name           : ARCHIVE_RETRO_BALANCE_INFO     		      	       	  |
|Type		: Procedure							  |
|Description    : Procedure archives NL CALCULATIONS for retro balances in Payment|
|		   and Deduction section of the payslip				  |
----------------------------------------------------------------------------------*/

PROCEDURE archive_retro_balance_info(p_arch_assign_action_id	IN NUMBER
				,p_run_assign_action_id 	IN NUMBER
				,p_balance_name         	IN VARCHAR2
				,p_dimension            	IN VARCHAR2
				,p_standard_bal_name    	IN VARCHAR2
				,p_special_bal_name     	IN VARCHAR2
				,p_non_tax_bal_name     	IN VARCHAR2
				,p_multiply_factor      	IN NUMBER
				,p_index                	IN NUMBER
				,p_type       	                IN VARCHAR2
				,p_record_count              	IN NUMBER
				,p_date_earned	 		IN DATE
				,p_archive_flag			IN VARCHAR2
				,p_payable_flag			IN VARCHAR2
				,p_payroll_action_id		IN NUMBER
                                ,p_assignment_id		IN NUMBER
                                ,p_effective_date		IN DATE) IS

	-- Cursor to retrieve all N (Normal)and P (Process separate) Child Actions
	-- for a given assignment action.
	--
	CURSOR csr_np_children (p_assignment_action_id NUMBER
			   ,p_payroll_action_id    NUMBER
			   ,p_assignment_id        NUMBER
			   ,p_effective_date       DATE) IS
	SELECT paa.assignment_action_id np_assignment_action_id
	FROM   pay_assignment_actions   paa
		  ,pay_run_types_f          prt
	WHERE  paa.source_action_id     = p_assignment_action_id
	AND    paa.payroll_action_id    = p_payroll_action_id
	AND    paa.assignment_id        = p_assignment_id
	AND    paa.run_type_id          = prt.run_type_id
	AND    prt.run_method           IN ('N','P')
	AND    p_effective_date         BETWEEN prt.effective_start_date
					AND     prt.effective_end_date
	order by np_assignment_action_id;

	--Bug No. 3371141
	--Added two additional parameters p_standard_bal_name,p_special_bal_name
	CURSOR csr_retro_element_periods(p_assignment_action_id	NUMBER
			,p_balance_name		VARCHAR2
			,p_standard_bal_name	VARCHAR2
			,p_special_bal_name     VARCHAR2
			,p_date_earned		DATE
			,p_classification_id    NUMBER ) IS
	SELECT    unique  prr.start_date /*pay_nl_general.get_retro_period(prr.source_id,p_date_earned)*/ RDate -- Bug 5107780
	FROM   pay_balance_feeds_f      pbf
	 ,pay_balance_types        pbt
	 ,pay_input_values_f       piv
	 ,pay_element_types_f      pet
	 ,pay_run_results          prr
	WHERE  pbf.balance_type_id      = pbt.balance_type_id
	AND   (pbt.balance_name         like p_balance_name||'%'
	OR     pbt.balance_name         like nvl(p_standard_bal_name,p_balance_name)||'%'
	OR     pbt.balance_name         like nvl(p_special_bal_name,p_balance_name)||'%')
	AND    piv.input_value_id       = pbf.input_value_id
	AND    piv.name                 ='Pay Value'
	AND    pet.element_type_id      = piv.element_type_id
	AND    pet.classification_id <> p_classification_id /*(SELECT classification_id
	   from pay_element_classifications
	   where classification_name ='Balance Initialization'
	   and business_group_id is null
	   and legislation_code is null) */ -- Bug 5107780
	AND    prr.element_type_id      = pet.element_type_id
	AND    prr.assignment_action_id = p_assignment_action_id
	AND    p_date_earned             BETWEEN pbf.effective_start_date
								AND     pbf.effective_end_date
	AND    p_date_earned             BETWEEN pet.effective_start_date
								AND     pet.effective_end_date
	AND    p_date_earned             BETWEEN piv.effective_start_date
								AND     piv.effective_end_date;


	CURSOR csr_get_context_id(p_run_assign_action_id VARCHAR2
				 ,p_context_name         VARCHAR2) IS
	SELECT pac.context_id           context_id
	  ,pac.context_value        value
	FROM   ff_contexts              ff
	  ,pay_action_contexts      pac
	WHERE  ff.context_name          = p_context_name
	AND    pac.context_id           = ff.context_id
	AND    pac.assignment_Action_id = p_run_assign_action_id;

	CURSOR csr_retro_values_nc(p_assignment_action_id	NUMBER
								,p_balance_name		VARCHAR2
								,p_date_earned		DATE
								,p_retro_date		DATE
								,p_creator_type	  VARCHAR2
								,p_classification_id NUMBER ) IS
	SELECT     sum(fnd_number.canonical_to_number(prrv.result_value))        result_value
	,pet.processing_priority      priority
	FROM   pay_balance_feeds_f      pbf
		,pay_balance_types        pbt
		,pay_input_values_f       piv
		,pay_element_types_f      pet
	--	,pay_element_types_f_tl   pettl       Bug 5107780
		,pay_run_results          prr
		,pay_run_result_values    prrv
		,pay_element_entries_f        pee
	WHERE  pbf.balance_type_id      = pbt.balance_type_id
	AND    prr.source_id                 = pee.element_entry_id
	AND    pee.CREATOR_TYPE              = p_creator_type
	AND    pbt.balance_name         like p_balance_name|| '%'
	AND    piv.input_value_id       = pbf.input_value_id
	AND    piv.name                 ='Pay Value'
	AND    pet.element_type_id      = piv.element_type_id
	AND    pet.classification_id <>  p_classification_id /*(SELECT classification_id
									from pay_element_classifications
									where classification_name ='Balance Initialization'
									and business_group_id is null
									and legislation_code is null)  */    -- Bug 5107780
	AND    prr.element_type_id      = pet.element_type_id
	AND    prr.assignment_action_id = p_assignment_action_id
	AND    prrv.run_result_id       = prr.run_result_id
--	AND    pet.element_type_id      = pettl.element_type_id  Bug 5107780
--	AND    pettl.language           = USERENV('LANG')      Bug 5107780
	AND    p_date_earned             BETWEEN pbf.effective_start_date
	AND     pbf.effective_end_date
	AND    p_date_earned             BETWEEN pet.effective_start_date
	AND     pet.effective_end_date
	AND    p_date_earned             BETWEEN piv.effective_start_date
	AND     piv.effective_end_date
	and /*pay_nl_general.get_retro_period(prr.source_id,p_date_earned)*/ prr.start_date = p_retro_date -- Bug 5107780
	group by pet.processing_priority;


	CURSOR csr_retro_values(p_assignment_action_id	NUMBER
							,p_balance_name		VARCHAR2
							,p_date_earned		DATE
							,p_retro_date		DATE
							,p_si_type	        VARCHAR2
							,p_creator_type	  VARCHAR2
							,p_classification_id NUMBER) IS
	SELECT sum(fnd_number.canonical_to_number(prrv2.result_value))
		,prrv1.result_value
		,pet.processing_priority
	FROM   pay_balance_feeds_f      pbf
		,pay_balance_types        pbt
		,pay_input_values_f       piv
		,pay_input_values_f       piv1
		,pay_input_values_f       piv2
		,pay_element_types_f      pet
--		,pay_element_types_f_tl   pettl             Bug 5107780
		,pay_run_results          prr
		,pay_run_result_values    prrv
		,pay_run_result_values    prrv1
		,pay_run_result_values    prrv2
		,pay_element_entries_f        pee
	WHERE  pbf.balance_type_id      = pbt.balance_type_id
	AND    prr.source_id                 = pee.element_entry_id
	AND    pee.CREATOR_TYPE              = p_creator_type
	AND    pbt.balance_name         like p_balance_name
	AND    piv.input_value_id       = pbf.input_value_id
	AND    piv.name                 ='Pay Value'
	AND    pet.element_type_id      = piv.element_type_id
	AND    pet.classification_id <> p_classification_id /*(SELECT classification_id
	from pay_element_classifications
	where classification_name ='Balance Initialization'
	and business_group_id is null
	and legislation_code is null) */ -- Bug 5107780
	AND    piv1.element_type_id     = pet.element_type_id
	AND    piv1.name                = 'SI Type Name'
	AND    piv2.element_type_id     = pet.element_type_id
	AND    piv2.name                = 'SI Type'
	AND    prr.element_type_id      = pet.element_type_id
	AND    prr.assignment_action_id = p_assignment_action_id
	AND    prrv.run_result_id       = prr.run_result_id
	AND    prrv.input_value_id      = piv2.input_value_id
	AND    prrv.result_value        = p_si_type
	AND    prrv1.run_result_id      = prrv.run_result_id
	AND    prrv1.input_value_id     = piv1.input_value_id
	AND    prrv2.run_result_id      = prrv.run_result_id
	AND    prrv2.input_value_id     = piv.input_value_id
--	AND    pet.element_type_id      = pettl.element_type_id  Bug 5107780
--	AND    pettl.language           = USERENV('LANG')       Bug 5107780
	AND    p_date_earned             BETWEEN pbf.effective_start_date
	AND     pbf.effective_end_date
	AND    p_date_earned             BETWEEN pet.effective_start_date
	AND     pet.effective_end_date
	AND    p_date_earned             BETWEEN piv.effective_start_date
	AND     piv.effective_end_date
	AND    p_date_earned            BETWEEN piv1.effective_start_date
	AND     piv1.effective_end_date
	AND    p_date_earned             BETWEEN piv2.effective_start_date
	AND     piv2.effective_end_date
	and /*pay_nl_general.get_retro_period(prr.source_id,p_date_earned)*/ prr.start_date = p_retro_date
    group by prrv1.result_value,pet.processing_priority; -- Bug 5107780


	CURSOR csr_get_translated_bal_name (p_balance_name VARCHAR2) IS
	SELECT NVL(pbt_tl.reporting_name,pbt_tl.balance_name) bal_name
	FROM   pay_balance_types        pbt
	,pay_balance_types_tl     pbt_tl
	WHERE  pbt.balance_name         = p_balance_name
	AND    pbt.balance_type_id      = pbt_tl.balance_type_id
	AND    pbt_tl.language          = USERENV('LANG');


	/* Bug 5107780*/
	CURSOR csr_get_bal_init_class IS
	SELECT classification_id
		from pay_element_classifications
		where classification_name ='Balance Initialization'
		and business_group_id is null
	and legislation_code is null;



	l_value			VARCHAR2(255);
	l_action_info_id	NUMBER;
	l_ovn			NUMBER;
	l_standard_rate		VARCHAR2(255);
	l_special_rate		VARCHAR2(255);
	l_standard_ptd		NUMBER;
	l_special_ptd		NUMBER;
	l_non_rate		VARCHAR2(255);
	l_rate			VARCHAR2(255);
	l_payable		NUMBER;
	l_def_bal_id		NUMBER;
	l_index			NUMBER;
	l_sum_standard_rate	VARCHAR2(255);
	l_sum_special_rate 	VARCHAR2(255);
	l_sum_non_rate	 	VARCHAR2(255);
	l_sum_payable  		VARCHAR2(255);
	l_sum_ptd		NUMBER;
	l_standard_year		NUMBER;
	l_special_year		NUMBER;
	l_non_year		NUMBER;
	l_sum_year		NUMBER;
	l_date			VARCHAR2(255);
	l_priority		NUMBER;
	l_np_child_id		NUMBER;
	l_balance_name		VARCHAR2(255);
	l_si_type		VARCHAR2(255);
	l_si_type_name		VARCHAR2(255);
	l_flag			NUMBER;
	l_year_flag NUMBER;
	l_bal_init_class_id     NUMBER;

	type creator_type is table of varchar2(2) index by binary_integer;
	l_creator_type creator_type;

	type element_retro_entries is table of DATE index by binary_integer;
	l_element_retro_entries element_retro_entries;

BEGIN
	-- Bug 5107780
	OPEN csr_get_bal_init_class;
	FETCH csr_get_bal_init_class INTO l_bal_init_class_id;
	CLOSE csr_get_bal_init_class;

	l_index:=p_index;
	hr_utility.set_location('Inside archive_retro_balance_info l_index'||l_index,5000);
	hr_utility.set_location('Inside archive_retro_balance_info p_dimension'||p_dimension,5000);

	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_balance_name'||' '||p_balance_name);
	--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_dimension'||' '||p_dimension);

	IF  p_dimension = '_ASG_SIT_YTD' THEN

		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_run_assign_action_id'||' '||p_run_assign_action_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_payroll_action_id'||' '||p_payroll_action_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_assignment_id'||' '||p_assignment_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_effective_date'||' '||p_effective_date);

		--hr_utility.set_location('Inside archive_retro_balance_info p_run_assign_action_id'||p_run_assign_action_id,5010);
		--hr_utility.set_location('Inside archive_retro_balance_info p_payroll_action_id'||p_payroll_action_id,5010);
		--hr_utility.set_location('Inside archive_retro_balance_info p_assignment_id'||p_assignment_id,5010);
		--hr_utility.set_location('Inside archive_retro_balance_info p_effective_date'||p_effective_date,5010);
		--Get the child action id with highest sequence

		l_creator_type(0):='EE';
		l_creator_type(1):='RR';
		l_creator_type(2):='PR';
		l_creator_type(3):='NR';

		OPEN csr_np_children(p_run_assign_action_id,p_payroll_action_id,
		p_assignment_id,p_effective_date);
		FETCH csr_np_children into l_np_child_id;
		CLOSE csr_np_children;

		--hr_utility.set_location('Inside archive_retro_balance_info l_np_child_id'||l_np_child_id,5020);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_np_child_id'||' '||l_np_child_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_balance_name'||' '||p_balance_name);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_standard_bal_name'||' '||p_standard_bal_name);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_special_bal_name'||' '||p_special_bal_name);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_date_earned'||' '||p_date_earned);
		--Get all the retro periods
		--hr_utility.set_location('Inside archive_retro_balance_info p_balance_name'||p_balance_name,5030);
		--hr_utility.set_location('Inside archive_retro_balance_info p_standard_bal_name'||p_standard_bal_name,5030);
		--hr_utility.set_location('Inside archive_retro_balance_info p_special_bal_name'||p_special_bal_name,5030);
		--hr_utility.set_location('Inside archive_retro_balance_info p_date_earned'||p_date_earned,5030);

		OPEN csr_retro_element_periods(l_np_child_id,p_balance_name,p_standard_bal_name
		,p_special_bal_name,p_date_earned,l_bal_init_class_id);
		FETCH csr_retro_element_periods bulk collect into l_element_retro_entries;
		CLOSE csr_retro_element_periods;

		--hr_utility.set_location('Inside archive_retro_balance_info p_date_earned'||p_date_earned,5040);

		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries.count'||' '||l_element_retro_entries.count);

		-- Loop through pay_action_context table for all SI Type
		FOR context_rec IN csr_get_context_id(l_np_child_id,'SOURCE_TEXT')
		LOOP

			--hr_utility.set_location('Inside archive_retro_balance_info l_element_retro_entries.count'||l_element_retro_entries.count,5050);
			--FND_FILE.PUT_LINE(FND_FILE.LOG, 'context_rec'||' '||context_rec.value);

			IF l_element_retro_entries.count > 0 THEN
				FOR i in l_element_retro_entries.first..l_element_retro_entries.last  LOOP

					--hr_utility.set_location('Inside archive_retro_balance_info l_element_retro_entries(i)'||l_element_retro_entries(i),5060);
					FOR j in l_creator_type.first..l_creator_type.last LOOP
						l_sum_standard_rate	:='0';
						l_sum_special_rate 	:='0';
						l_sum_payable  		:='0';
						l_sum_year		:=0;
						l_sum_non_rate		:='0';

						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries'||' '||l_element_retro_entries(i));

						FOR csr_np_rec IN csr_np_children(p_run_assign_action_id,p_payroll_action_id,
						p_assignment_id,p_effective_date)
						LOOP
							l_standard_rate		:='0';
							l_special_rate		:='0';
							l_standard_year		:=0;
							l_special_year		:=0;
							l_non_rate		:='0';
							l_rate			:='0';
							l_non_year		:=0;

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_standard_bal_name'||' '||p_standard_bal_name);

							--hr_utility.set_location('Inside archive_retro_balance_info p_standard_bal_name'||p_standard_bal_name,5070);
                            l_year_flag := 0;
							IF p_standard_bal_name IS NOT NULL THEN

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'csr_np_rec'||' '||csr_np_rec.np_assignment_action_id);
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_standard_bal_name'||' '||p_standard_bal_name);
								--FND_FILE.PUT_LINE(FND_FILE.LOG,' p_date_earned'||' '||p_date_earned);
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries(i)'||' '||l_element_retro_entries(i));
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'context_rec.value'||' '||context_rec.value);

								--hr_utility.set_location('Inside archive_retro_balance_info np_assignment_action_id'||csr_np_rec.np_assignment_action_id,5080);

								OPEN csr_retro_values(csr_np_rec.np_assignment_action_id,p_standard_bal_name
								,p_date_earned,l_element_retro_entries(i),context_rec.value,l_creator_type(j),l_bal_init_class_id);
								FETCH csr_retro_values INTO l_value,l_si_type_name,l_priority;

								--hr_utility.set_location('Inside archive_retro_balance_info l_value'||l_value,5090);
								--hr_utility.set_location('Inside archive_retro_balance_info l_si_type_name'||l_si_type_name,5090);
								--hr_utility.set_location('Inside archive_retro_balance_info l_priority'||l_priority,5090);

								--FND_FILE.PUT_LINE(FND_FILE.LOG,'l_value'||' '||l_value);

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);

								IF  csr_retro_values%FOUND THEN
                                    l_year_flag := 1;
									l_standard_rate := l_value;

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_standard_rate'||' '||l_standard_rate);

									l_sum_standard_rate :=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_standard_rate) + FND_NUMBER.canonical_to_number(l_standard_rate));

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_standard_rate'||' '||l_sum_standard_rate);

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);
									IF l_si_type_name IS NOT NULL THEN
										l_si_type:=l_si_type_name;
									END IF;
								END IF;
								CLOSE csr_retro_values;
									l_def_bal_id := get_defined_balance_id (p_standard_bal_name,'_ASG_SIT_YTD');
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);
									IF  l_def_bal_id IS NOT NULL THEN
										l_standard_year := pay_balance_pkg.get_value(l_def_bal_id
                                        ,csr_np_rec.np_assignment_action_id,null,null,context_rec.context_id,context_rec.value,null,null);
									END IF;
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_standard_year'||' '||l_standard_year);

							END IF;

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_special_bal_name'||' '||p_special_bal_name);
							--hr_utility.set_location('Inside archive_retro_balance_info p_special_bal_name'||p_special_bal_name,5100);
							IF csr_retro_values%ISOPEN THEN
							CLOSE csr_retro_values;
							END IF;
							IF p_special_bal_name IS NOT NULL THEN
								OPEN csr_retro_values(csr_np_rec.np_assignment_action_id,p_special_bal_name
								,p_date_earned,l_element_retro_entries(i),context_rec.value,l_creator_type(j),l_bal_init_class_id);
								FETCH csr_retro_values INTO l_value,l_si_type_name,l_priority;
								--FND_FILE.PUT_LINE(FND_FILE.LOG,' l_value'||' '||l_value);

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);

								IF  csr_retro_values%FOUND THEN
                                    l_year_flag := 1;
									l_special_rate := l_value;

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_rate'||' '||l_special_rate);

									l_sum_special_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_special_rate) + FND_NUMBER.canonical_to_number(l_special_rate));

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_special_rate'||' '||l_sum_special_rate);

									IF l_si_type_name IS NOT NULL THEN
										l_si_type:=l_si_type_name;
									END IF;
								END IF;
								--
								CLOSE csr_retro_values;
									l_def_bal_id := get_defined_balance_id (p_special_bal_name,'_ASG_SIT_YTD');
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);

									IF  l_def_bal_id IS NOT NULL THEN
										l_special_year := pay_balance_pkg.get_value(l_def_bal_id
                                        ,csr_np_rec.np_assignment_action_id,null,null,context_rec.context_id,context_rec.value,null,null);
										--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_year'||' '||l_special_year);
									END IF;
							END IF;

							--hr_utility.set_location('Inside archive_retro_balance_info p_non_tax_bal_name'||p_non_tax_bal_name,5110);


							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_non_tax_bal_name'||' '||p_non_tax_bal_name);

							IF p_non_tax_bal_name IS NOT NULL THEN
								OPEN csr_retro_values(csr_np_rec.np_assignment_action_id,p_non_tax_bal_name
								,p_date_earned,l_element_retro_entries(i),context_rec.value,l_creator_type(j),l_bal_init_class_id);
								FETCH csr_retro_values INTO l_value,l_si_type_name,l_priority;
								--FND_FILE.PUT_LINE(FND_FILE.LOG,' l_value'||' '||l_value);

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);

								IF  csr_retro_values%FOUND THEN
                                    l_year_flag := 1;
									l_non_rate := l_value;

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_non_rate'||' '||l_non_rate);

									l_sum_non_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_non_rate) +FND_NUMBER.canonical_to_number(l_non_rate));

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_non_rate'||' '||l_sum_non_rate);

									IF l_si_type_name IS NOT NULL THEN
										l_si_type:=l_si_type_name;
									END IF;
								END IF;
								--
								CLOSE csr_retro_values;

									l_def_bal_id := get_defined_balance_id (p_non_tax_bal_name,'_ASG_SIT_YTD');
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);

									IF  l_def_bal_id IS NOT NULL THEN
										l_non_year := pay_balance_pkg.get_value(l_def_bal_id
                                        ,csr_np_rec.np_assignment_action_id,null,null,context_rec.context_id,context_rec.value,null,null);
										--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_non_year'||' '||l_non_year);
									END IF;
							END IF;

							--hr_utility.set_location('Inside archive_retro_balance_info p_balance_name'||p_balance_name,5120);

							IF  p_standard_bal_name IS NULL
							AND p_special_bal_name  IS NULL
							AND p_non_tax_bal_name  IS NULL THEN

								OPEN csr_retro_values(csr_np_rec.np_assignment_action_id,p_balance_name
								,p_date_earned,l_element_retro_entries(i),context_rec.value,l_creator_type(j),l_bal_init_class_id);
								FETCH csr_retro_values INTO l_value,l_si_type_name,l_priority;
								--FND_FILE.PUT_LINE(FND_FILE.LOG,' l_value'||' '||l_value);
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);

								IF  csr_retro_values%FOUND THEN
									l_rate := l_value;

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_rate'||' '||l_rate);

									l_sum_payable:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_payable) +FND_NUMBER.canonical_to_number(l_rate));

									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_payable'||' '||l_sum_payable);

								IF l_si_type_name IS NOT NULL THEN
									l_si_type:=l_si_type_name;
								END IF;
								l_def_bal_id := get_defined_balance_id (p_balance_name,'_ASG_SIT_YTD');
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);

								IF  l_def_bal_id IS NOT NULL THEN
									l_sum_year := pay_balance_pkg.get_value(l_def_bal_id
                                        ,csr_np_rec.np_assignment_action_id,null,null,context_rec.context_id,context_rec.value,null,null);
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_year'||' '||l_sum_year);
								END IF;
							END IF;
						ELSE

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_payable_flag'||' '||p_payable_flag);

							IF p_payable_flag='Y' THEN

								l_sum_payable:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_standard_rate)
								+ FND_NUMBER.canonical_to_number(l_sum_special_rate) +FND_NUMBER.canonical_to_number(l_sum_non_rate));

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_payable'||' '||l_sum_payable);
							END IF;

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_standard_year'||' '||l_standard_year);
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_year'||' '||l_special_year);
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_non_year'||' '||l_non_year);
                            If l_year_flag =1 THEN
    							l_sum_year:=l_sum_year + l_standard_year + l_special_year + l_non_year;
							END IF;

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_year'||' '||l_sum_year);
							END IF;
							IF csr_retro_values%ISOPEN THEN
								CLOSE csr_retro_values;
							END IF;
							--hr_utility.set_location('Inside archive_retro_balance_info l_sum_year'||l_sum_year,5130);
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_balance_name'||' '||l_balance_name);
							l_balance_name:=p_balance_name;
							--hr_utility.set_location('Inside archive_retro_balance_info l_balance_name'||l_balance_name,5140);

							OPEN csr_get_translated_bal_name (p_balance_name);
							FETCH csr_get_translated_bal_name INTO l_balance_name;
							IF  csr_get_translated_bal_name%NOTFOUND THEN
								l_balance_name :=hr_general.decode_lookup('HR_NL_REPORT_LABELS',UPPER(p_balance_name));
							END IF;
							CLOSE csr_get_translated_bal_name;

							--hr_utility.set_location('Inside archive_retro_balance_info l_balance_name'||l_balance_name,5150);

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_balance_name'||' '||l_balance_name);

							l_date:=fnd_date.date_to_canonical(l_element_retro_entries(i));
							--Bug No. 3384315
							--Fetch the si type name for the p_balance_name
							IF l_si_type IS  NULL THEN
							OPEN csr_retro_values(csr_np_rec.np_assignment_action_id,p_balance_name
							,p_date_earned,l_element_retro_entries(i),context_rec.value,l_creator_type(j),l_bal_init_class_id);
							FETCH csr_retro_values INTO l_value,l_si_type_name,l_priority;
							CLOSE csr_retro_values;
							IF l_si_type_name IS NOT NULL THEN
								l_si_type:=l_si_type_name;
							ELSE
								l_si_type:=context_rec.value;
							END IF;
						END IF;
	    			END LOOP;

					--hr_utility.set_location('Inside archive_retro_balance_info l_balance_name'||l_balance_name,5150);


					IF l_balance_name='Retro Net Employee SI Contribution' and
						FND_NUMBER.canonical_to_number(l_sum_standard_rate)=0 THEN
						l_sum_standard_rate:=NULL;
					END IF;

					IF l_balance_name='Retro Net Employee SI Contribution' and
						FND_NUMBER.canonical_to_number(l_sum_special_rate)=0 THEN
						l_sum_special_rate:=NULL;
					END IF;

					IF p_payable_flag='N' and FND_NUMBER.canonical_to_number(l_sum_payable) =0 THEN
						l_sum_payable:=NULL;
					END IF;
				IF l_si_type_name='ZVW' THEN
				  IF p_balance_name = 'Retro Employer SI Contribution' and l_index < 18750 THEN
				    l_index := 18750;
				  END IF;
				  IF p_balance_name = 'Retro Employee SI Contribution' and l_index < 18850 THEN
				    l_index := 18850;
				  END IF;
				  IF p_balance_name = 'Retro Net Employee SI Contribution' and l_index < 18950 THEN
				    l_index := 18950;
				  END IF;
				END IF;
					--hr_utility.set_location('Inside archive_retro_balance_info l_rate'||l_sum_year,5123);
					--hr_utility.set_location('Inside archive_retro_balance_info l_sum_payable'||l_sum_payable,5123);

					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_standard_rate'||' '||l_sum_standard_rate);
					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_special_rate'||' '||l_sum_special_rate);
					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_payable'||' '||l_sum_payable);
					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_year'||' '||l_sum_year);

					IF p_archive_flag = 'Y'
						OR (FND_NUMBER.canonical_to_number(l_sum_standard_rate) <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_special_rate) <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_payable)  <> 0
						OR l_sum_year <> 0) THEN

						/* IF p_archive_flag = 'Y' OR(FND_NUMBER.canonical_to_number(l_sum_standard_rate) <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_special_rate) <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_payable)  <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_year) <> 0) THEN*/
						-- Archive NL CALCULATIONS
						--
						--pay_action_information_api.create_action_information (..);
						--

						pay_action_information_api.create_action_information (
						p_action_information_id        => l_action_info_id
						,p_action_context_id            => p_arch_assign_action_id
						,p_action_context_type          => 'AAP'
						,p_object_version_number        => l_ovn
						,p_effective_date               => p_date_earned
						,p_source_id                    => NULL
						,p_source_text                  => NULL
						,p_action_information_category  => 'NL CALCULATIONS'
						,p_action_information4          =>l_index
						,p_action_information5          =>l_priority
						,p_action_information6          =>l_balance_name
						,p_action_information7          =>l_si_type
						,p_action_information8          =>p_type
						,p_action_information9          =>l_date   --Retro Period
						,p_action_information10         =>l_sum_standard_rate
						,p_action_information11         =>l_sum_special_rate
						,p_action_information12         =>l_sum_payable
						,p_action_information13         =>fnd_number.number_to_canonical(l_sum_year));
						l_index := l_index + 1;
					END IF;
			END LOOP;
		END LOOP;
	END IF;
END LOOP;
	ELSE	--Non-context retro balances
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_run_assign_action_id'||' '||p_run_assign_action_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_payroll_action_id'||' '||p_payroll_action_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_assignment_id'||' '||p_assignment_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_effective_date'||' '||p_effective_date);

		--hr_utility.set_location('Inside archive_retro_balance_info non context p_balance_name'||p_balance_name,6000);
		l_creator_type(0):='EE';
		l_creator_type(1):='RR';
		l_creator_type(2):='PR';
		l_creator_type(3):='NR';

		--Get the child action id with highest sequence
		OPEN csr_np_children(p_run_assign_action_id,p_payroll_action_id,
			p_assignment_id,p_effective_date);
		FETCH csr_np_children into l_np_child_id;
		CLOSE csr_np_children;

		--hr_utility.set_location('Inside archive_retro_balance_info non context l_np_child_id'||l_np_child_id,6010);

		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_np_child_id'||' '||l_np_child_id);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_balance_name'||' '||p_balance_name);
		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_date_earned'||' '||p_date_earned);
		--Get all the retro periods
		OPEN csr_retro_element_periods(l_np_child_id,p_balance_name
		,p_standard_bal_name,p_special_bal_name,p_date_earned,l_bal_init_class_id);
		FETCH csr_retro_element_periods bulk collect into l_element_retro_entries;
		CLOSE csr_retro_element_periods;

		--hr_utility.set_location('Inside archive_retro_balance_info non context l_element_retro_entries.count'||l_element_retro_entries.count,6120);

		--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries.count'||' '||l_element_retro_entries.count);


		IF l_element_retro_entries.count > 0 THEN
			FOR i in l_element_retro_entries.first..l_element_retro_entries.last
			LOOP
				--hr_utility.set_location('Inside archive_retro_balance_info non context p_balance_name'||p_balance_name,6120);
				FOR j in l_creator_type.first..l_creator_type.last
				LOOP
					l_sum_standard_rate	:='0';
					l_sum_special_rate 	:='0';
					l_sum_payable  		:='0';
					l_sum_year		:=0;
					l_sum_ptd		:=0;
					l_date			:=NULL;

					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries'||' '||l_element_retro_entries(i));

					FOR csr_np_rec IN csr_np_children(p_run_assign_action_id,
					p_payroll_action_id,p_assignment_id,p_effective_date)
					LOOP
						l_standard_rate		:='0';
						l_special_rate		:='0';
						l_standard_year		:=0;
						l_special_year		:=0;
						l_non_rate		:='0';
						l_rate			:='0';
						l_non_year		:=0;
						l_standard_ptd		:=0;
						l_special_ptd		:=0;


						--hr_utility.set_location('Inside archive_retro_balance_info non context csr_np_rec.np_assignment_action_id'||csr_np_rec.np_assignment_action_id,6130);

						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_standard_bal_name'||' '||p_standard_bal_name);

						--hr_utility.set_location('Inside archive_retro_balance_info non context p_standard_bal_name'||p_standard_bal_name,6140);

						IF p_standard_bal_name IS NOT NULL THEN

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'csr_np_rec'||' '||csr_np_rec.np_assignment_action_id);
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_standard_bal_name'||' '||p_standard_bal_name);
							--FND_FILE.PUT_LINE(FND_FILE.LOG,' p_date_earned'||' '||p_date_earned);
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries(i)'||' '||l_element_retro_entries(i));

							--hr_utility.set_location('Inside archive_retro_balance_info non context p_standard_bal_name'||p_standard_bal_name,6150);

							OPEN csr_retro_values_nc(csr_np_rec.np_assignment_action_id,p_standard_bal_name
							,p_date_earned,l_element_retro_entries(i),l_creator_type(j),l_bal_init_class_id);
							FETCH csr_retro_values_nc INTO l_value,l_priority;

							--FND_FILE.PUT_LINE(FND_FILE.LOG,' l_value'||' '||l_value);

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);
							l_flag:=0;
							IF  csr_retro_values_nc%FOUND THEN
								l_standard_rate := l_value;
								l_standard_rate := FND_NUMBER.number_to_canonical(NVL(FND_NUMBER.canonical_to_number(l_standard_rate),0) *
								p_multiply_factor);
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_standard_rate'||' '||l_standard_rate);
								l_sum_standard_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_standard_rate) + FND_NUMBER.canonical_to_number(l_standard_rate));
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_standard_rate'||' '||l_sum_standard_rate);
								l_flag:=1;
								CLOSE csr_retro_values_nc;
							ELSIF p_standard_bal_name = 'Retro Standard Taxable Income' THEN

								IF csr_retro_values_nc%ISOPEN THEN
									CLOSE csr_retro_values_nc;
								END IF;
								OPEN csr_retro_values_nc(csr_np_rec.np_assignment_action_id
								,'Retro Standard Taxable Income Current Quarter',p_date_earned
								,l_element_retro_entries(i),l_creator_type(j),l_bal_init_class_id);
								FETCH csr_retro_values_nc INTO l_value,l_priority;

								IF  csr_retro_values_nc%FOUND THEN
									l_standard_rate := l_value;
									l_flag:=1;
								END IF;
								CLOSE csr_retro_values_nc;
								l_standard_rate := FND_NUMBER.number_to_canonical(NVL(FND_NUMBER.canonical_to_number(l_standard_rate),0) *
								p_multiply_factor);

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_standard_rate'||' '||l_standard_rate);
								l_sum_standard_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_standard_rate) +FND_NUMBER.canonical_to_number( l_standard_rate));

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_standard_rate'||' '||l_sum_standard_rate);
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);

								--hr_utility.set_location('Inside archive_retro_balance_info non context p_standard_bal_name'||p_standard_bal_name,6160);
							END IF;
							--IF l_flag=1 THEN
								l_def_bal_id := get_defined_balance_id (p_standard_bal_name,'_ASG_YTD');
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);
								IF  l_def_bal_id IS NOT NULL THEN
									l_standard_year := pay_balance_pkg.get_value(l_def_bal_id
									,csr_np_rec.np_assignment_action_id);
								END IF;
								IF /*l_standard_year=0 and*/ p_standard_bal_name = 'Retro Standard Taxable Income' THEN
									l_def_bal_id := get_defined_balance_id ('Retro Standard Taxable Income Current Quarter'
									,'_ASG_YTD');
									IF  l_def_bal_id IS NOT NULL THEN
										 l_standard_year := l_standard_year + pay_balance_pkg.get_value(l_def_bal_id,csr_np_rec.np_assignment_action_id);
									END IF;
	    					    END IF;
								l_standard_year := l_standard_year * p_multiply_factor;
								l_def_bal_id := get_defined_balance_id (p_standard_bal_name,'_ASG_PTD');
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);
								IF  l_def_bal_id IS NOT NULL THEN
									l_standard_ptd := pay_balance_pkg.get_value(l_def_bal_id
									,csr_np_rec.np_assignment_action_id);
								END IF;
								IF l_standard_ptd=0 and p_standard_bal_name = 'Retro Standard Taxable Income' THEN
									l_def_bal_id := get_defined_balance_id ('Retro Standard Taxable Income Current Quarter','_ASG_PTD');
									IF  l_def_bal_id IS NOT NULL THEN
										l_standard_ptd := pay_balance_pkg.get_value(l_def_bal_id
										,csr_np_rec.np_assignment_action_id);
									END IF;
								END IF;
						--	END IF;
						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_standard_year'||' '||l_standard_year);

						END IF;
						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_special_bal_name'||' '||p_special_bal_name);

						--hr_utility.set_location('Inside archive_retro_balance_info non context p_special_bal_name'||p_special_bal_name,6170);
						IF csr_retro_values_nc%ISOPEN THEN
						CLOSE csr_retro_values_nc;
						END IF;

						IF p_special_bal_name IS NOT NULL THEN
							--hr_utility.set_location('Inside archive_retro_balance_info non context p_special_bal_name'||p_special_bal_name,6180);
							OPEN csr_retro_values_nc(csr_np_rec.np_assignment_action_id,p_special_bal_name
							,p_date_earned,l_element_retro_entries(i),l_creator_type(j),l_bal_init_class_id);
							FETCH csr_retro_values_nc INTO l_value,l_priority;
							--FND_FILE.PUT_LINE(FND_FILE.LOG,' l_value'||' '||l_value);
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);

							IF  csr_retro_values_nc%FOUND THEN
								l_special_rate := l_value;

								l_special_rate :=FND_NUMBER.number_to_canonical(NVL(FND_NUMBER.canonical_to_number(l_special_rate),0) *
								p_multiply_factor);

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_rate'||' '||l_special_rate);

								l_sum_special_rate:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_special_rate) + FND_NUMBER.canonical_to_number(l_special_rate));

								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_special_rate'||' '||l_sum_special_rate);
								l_flag:=1;
								CLOSE csr_retro_values_nc;
							END IF;
								--hr_utility.set_location('Inside archive_retro_balance_info non context p_special_bal_name'||p_special_bal_name,6190);

								l_def_bal_id := get_defined_balance_id (p_special_bal_name,'_ASG_YTD');
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);
								IF  l_def_bal_id IS NOT NULL THEN
									l_special_year := pay_balance_pkg.get_value(l_def_bal_id,csr_np_rec.np_assignment_action_id);
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_year'||' '||l_special_year);
								END IF;
								l_special_year := l_special_year * p_multiply_factor;

								l_def_bal_id := get_defined_balance_id (p_special_bal_name,'_ASG_PTD');
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);

								IF  l_def_bal_id IS NOT NULL THEN
									l_special_ptd := pay_balance_pkg.get_value(l_def_bal_id
									,csr_np_rec.np_assignment_action_id);
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_year'||' '||l_special_year);
								END IF;
							--
							IF csr_retro_values_nc%ISOPEN THEN
								CLOSE csr_retro_values_nc;
							END IF;
						END IF;--End of IF p_special_bal_name IS NOT NULL THEN


						--hr_utility.set_location('Inside archive_retro_balance_info non context p_balance_name'||p_balance_name,6200);

						IF  p_standard_bal_name IS NULL
						AND p_special_bal_name  IS NULL
						AND p_non_tax_bal_name  IS NULL THEN

							--hr_utility.set_location('Inside archive_retro_balance_info non context p_balance_name'||p_balance_name,6210);

							OPEN csr_retro_values_nc(csr_np_rec.np_assignment_action_id
							,p_balance_name,p_date_earned,l_element_retro_entries(i),l_creator_type(j),l_bal_init_class_id);
							FETCH csr_retro_values_nc INTO l_value,l_priority;
							--FND_FILE.PUT_LINE(FND_FILE.LOG,' l_value'||' '||l_value);

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_priority'||' '||l_priority);
					        IF  csr_retro_values_nc%FOUND THEN
								l_rate := l_value;
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_rate'||' '||l_rate);
								l_sum_payable:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_payable) + FND_NUMBER.canonical_to_number(l_rate));
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_payable'||' '||l_sum_payable);

								CLOSE csr_retro_values_nc;
								--hr_utility.set_location('Inside archive_retro_balance_info non context p_balance_name'||p_balance_name,6220);

								l_def_bal_id := get_defined_balance_id (p_balance_name,'_ASG_YTD');
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_def_bal_id'||' '||l_def_bal_id);

								IF  l_def_bal_id IS NOT NULL THEN
									l_sum_year := pay_balance_pkg.get_value(l_def_bal_id,csr_np_rec.np_assignment_action_id);
									--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_year'||' '||l_sum_year);
									l_sum_year := l_sum_year * p_multiply_factor;
								END IF;
							END IF;
						ELSE

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'p_payable_flag'||' '||p_payable_flag);

							IF p_payable_flag='Y' THEN
								l_sum_payable:=FND_NUMBER.number_to_canonical(FND_NUMBER.canonical_to_number(l_sum_payable) + FND_NUMBER.canonical_to_number(l_sum_standard_rate) + FND_NUMBER.canonical_to_number(l_sum_special_rate));
								--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_payable'||' '||l_sum_payable);
							END IF;

							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_standard_year'||' '||l_standard_year);
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_year'||' '||l_special_year);
							IF l_flag = 1 THEN
							  l_sum_year:=l_standard_year + l_special_year;
							END IF;
							--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_year'||' '||l_sum_year);
						END IF;

						IF csr_retro_values_nc%ISOPEN THEN
							CLOSE csr_retro_values_nc;
						END IF;
						--hr_utility.set_location('Inside archive_retro_balance_info non context l_sum_year'||l_sum_year,6230);

						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_balance_name'||' '||l_balance_name);
						l_balance_name:=p_balance_name;

						--hr_utility.set_location('Inside archive_retro_balance_info non context l_balance_name'||l_balance_name,6240);

						OPEN csr_get_translated_bal_name (p_balance_name);
						FETCH csr_get_translated_bal_name INTO l_balance_name;
						IF  csr_get_translated_bal_name%NOTFOUND THEN
							l_balance_name :=hr_general.decode_lookup('HR_NL_REPORT_LABELS',UPPER(p_balance_name));
						END IF;
						CLOSE csr_get_translated_bal_name;
						--hr_utility.set_location('Inside archive_retro_balance_info non context l_balance_name'||l_balance_name,6250);

						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_balance_name'||' '||l_balance_name);

						l_sum_ptd:=l_standard_ptd + l_special_ptd;

						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'herel_standard_ptd'||' '||l_standard_ptd);
						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_special_ptd'||' '||l_special_ptd);
						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_ptd'||' '||l_sum_ptd);
						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_element_retro_entries(i)'||' '||l_element_retro_entries(i));
						/*Commented codde to fix bug 4035406 - Retro period not displayed for Employee IZA contributions*/
						/*IF l_sum_ptd <>0 THEN*/
						l_date:=fnd_date.date_to_canonical(l_element_retro_entries(i));
						/*END IF;*/
						--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_date'||' '||l_date);
						--
					END LOOP;

					--hr_utility.set_location('Inside archive_retro_balance_info non context l_date'||l_date,6260);





					IF l_balance_name='Retro Employees Private Health' and FND_NUMBER.canonical_to_number(l_sum_standard_rate)=0 THEN
						l_sum_standard_rate:=NULL;
					END IF;

					IF l_balance_name='Retro Employees Private Health' and FND_NUMBER.canonical_to_number(l_sum_special_rate)=0 THEN
						l_sum_special_rate:=NULL;
					END IF;

					IF p_payable_flag='N' and FND_NUMBER.canonical_to_number(l_sum_payable) =0 THEN
						l_sum_payable:=NULL;
					END IF;

					IF p_standard_bal_name IS NULL AND FND_NUMBER.canonical_to_number(l_sum_standard_rate)=0 THEN
					l_sum_standard_rate:=NULL;
				        END IF;

				        IF p_special_bal_name IS NULL AND FND_NUMBER.canonical_to_number(l_sum_special_rate)=0 THEN
					l_sum_special_rate:=NULL;
				        END IF;



					--hr_utility.set_location('Inside archive_retro_balance_info non context l_sum_standard_rate'||l_sum_standard_rate,6270);
					--hr_utility.set_location('Inside archive_retro_balance_info non context l_sum_year'||l_sum_year,6280);
					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_standard_rate'||' '||l_sum_standard_rate);
					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_special_rate'||' '||l_sum_special_rate);
					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_payable'||' '||l_sum_payable);
					--FND_FILE.PUT_LINE(FND_FILE.LOG, 'l_sum_year'||' '||l_sum_year);

					/* for 4253974 */
					IF ( p_archive_flag = 'Y' and l_date is not null and
					      (FND_NUMBER.canonical_to_number(l_sum_standard_rate) <> 0   OR
					       FND_NUMBER.canonical_to_number(l_sum_special_rate) <> 0    OR
					       FND_NUMBER.canonical_to_number(l_sum_payable)  <> 0        OR
					       FND_NUMBER.canonical_to_number(l_sum_payable)  IS NOT NULL OR
					       l_sum_year <> 0))
					OR (FND_NUMBER.canonical_to_number(l_sum_standard_rate) <> 0
					OR FND_NUMBER.canonical_to_number(l_sum_special_rate) <> 0
					OR FND_NUMBER.canonical_to_number(l_sum_payable)  <> 0
					OR l_sum_year <> 0) THEN

						/* IF p_archive_flag = 'Y' OR(FND_NUMBER.canonical_to_number(l_sum_standard_rate) <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_special_rate) <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_payable)  <> 0
						OR FND_NUMBER.canonical_to_number(l_sum_year) <> 0) THEN*/
						-- Archive NL CALCULATIONS
						--
						--pay_action_information_api.create_action_information (..);
						--

						pay_action_information_api.create_action_information (
						p_action_information_id        => l_action_info_id
						,p_action_context_id            => p_arch_assign_action_id
						,p_action_context_type          => 'AAP'
						,p_object_version_number        => l_ovn
						,p_effective_date               => p_date_earned
						,p_source_id                    => NULL
						,p_source_text                  => NULL
						,p_action_information_category  => 'NL CALCULATIONS'
						,p_action_information4          =>l_index
						,p_action_information5          =>l_priority
						,p_action_information6          =>l_balance_name
						,p_action_information7          =>l_si_type
						,p_action_information8          =>p_type
						,p_action_information9          =>l_date   --Retro Period
						,p_action_information10         =>l_sum_standard_rate
						,p_action_information11         =>l_sum_special_rate
						,p_action_information12         =>l_sum_payable
						,p_action_information13         =>fnd_number.number_to_canonical(l_sum_year));
						l_index := l_index + 1;

					END IF;
				END LOOP;
			END LOOP;
		END IF;
	END IF;

END archive_retro_balance_info;



/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_PAYSLIP_BALANCE_INFO     		      	       	        |
|Type			: Procedure							                            |
|Description    : Procedure calls archive_balance_info to archive 		        |
|		  		  NL CALCULATIONS for balances in payment and deduction section	|
-------------------------------------------------------------------------------*/

PROCEDURE archive_payslip_balance_info(p_arch_assign_action_id    NUMBER
										,p_run_assign_action_id     NUMBER
										,p_date_earned              DATE
										,p_record_count             NUMBER
										,p_payroll_action_id	NUMBER
										,p_assignment_id		NUMBER
										,p_effective_date		DATE) IS

BEGIN
		--
		-- Archive Gross Salary Balance
		--

		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id,'Gross Salary','_ASG_YTD'
		,NULL,NULL,NULL
		,1,11000,NULL,p_record_count,p_date_earned
		,'Y','Y',p_payroll_action_id
		,p_assignment_id,p_effective_date);

		--
		--
		-- Archive Foreigner Rule SI Income Balances
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Foreigner Rule SI Income'
		,'_ASG_YTD'
		,'Foreigner Rule SI Income Standard Adjustment'
		,'Foreigner Rule SI Income Special Adjustment'
		,NULL
		,1
		,14800
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		--
		-- Archive SI Income Balances
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'SI Income'
		,'_ASG_YTD'
		,'SI Income Standard Tax'
		,'SI Income Special Tax'
		,NULL
		,1
		,15000
		,NULL
		,p_record_count
		,p_date_earned
		,'Y'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
                --
		--
		-- Archive IZA Income Balances
		--
		/*archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'IZA Income'
		,'_ASG_YTD'
		,'IZA Income Standard Tax'
		,'IZA Income Special Tax'
		,'IZA Income Non Taxable'
		,1
		,15600
		,NULL
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);*/

		--
		--
		-- Archive Employer SI Charges  Context Balance
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Employer SI Contribution'
		,'_ASG_SIT_YTD'
		,'Employer SI Contribution Standard Tax'
		,'Employer SI Contribution Special Tax'
		,NULL
		,1
		,16000
		,NULL
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		--
		-- Archive Employee SI Charges  Context Balance
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Employee SI Contribution'
		,'_ASG_SIT_YTD'
		,'Employee SI Contribution Standard Tax'
		,'Employee SI Contribution Special Tax'
		,'Employee SI Contribution Non Taxable'
		,1
		,17000
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		--
		-- Archive Net Employee SI Contribution Context Balance
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Net Employee SI Contribution'
		,'_ASG_SIT_YTD'
		,NULL
		,NULL
		,NULL
		,1
		,18000
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

--
		--
		-- Archive Foreigner Rule ZVW Income Balances
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Foreigner Rule ZVW Income'
		,'_ASG_YTD'
		,'Foreigner Rule ZVW Income Standard Adjustment'
		,'Foreigner Rule ZVW Income Special Adjustment'
		,NULL
		,1
		,18550
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);
--
		--
		-- Archive ZVW Income Balances
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'ZVW Income'
		,'_ASG_YTD'
		,'ZVW Income Standard Tax'
		,'ZVW Income Special Tax'
		,NULL
		,1
		,18600
		,NULL
		,p_record_count
		,p_date_earned
		,'Y'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--

		--
		--
		-- Archive Employee Private Health Contribution  Balance
		--
		/*archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Employee Private Health Contribution'
		,'_ASG_YTD'
		,NULL
		,NULL
		,NULL
		,1
		,19000
		,'D'
		,p_record_count
		,p_date_earned
		,'Y'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		--
		-- Archive Nominal IZA Contribution Balance
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Nominal IZA Contribution'
	        ,'_ASG_YTD'
	        ,NULL
	        ,NULL
	        ,NULL
	        ,1
	        ,19550
                ,'D'
	        ,p_record_count
	        ,p_date_earned
	        ,'N'
	        ,'Y'
	        ,p_payroll_action_id
	        ,p_assignment_id
	        ,p_effective_date);

                --
		--
		-- Archive Employee IZA Contribution  Balance
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Employee IZA Contribution'
		,'_ASG_YTD'
		,NULL
		,NULL
		,NULL
		,1
		,19600
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);*/

		--
		--
		-- Archive Foreigner Rule Standard/Special Balances
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Foreigner Rule (Taxable)'
		,'_ASG_YTD'
		,'Foreigner Rule Standard Tax Adjustment'
		,'Foreigner Rule Special Tax Adjustment'
		,NULL
		,1
		,21000
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		--
		-- Archive Taxable Balance
		--
		archive_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Taxable Income'
		,'_ASG_YTD'
		,'Standard Taxable Income'
		,'Special Taxable Income'
		,NULL
		,1
		,22000
		,NULL
		,p_record_count
		,p_date_earned
		,'Y'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		-- Archive Retro Foreigner Rule SI Income Balances
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Foreigner Rule SI Income'
		,'_ASG_YTD'
		,'Retro Foreigner Rule SI Income Standard Adjustment'
		,'Retro Foreigner Rule SI Income Special Adjustment'
		,NULL
		,1
		,14900
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		-- Archive Retro SI Income Balances
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro SI Income'
		,'_ASG_YTD'
		,'Retro SI Income Standard Tax'
		,'Retro SI Income Special Tax'
		,NULL
		,1
		,15500
		,NULL
		,p_record_count
		,p_date_earned
		,'Y'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);
                --
		-- Archive Retro IZA Income Balances
		--
		/*archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro IZA Income'
		,'_ASG_YTD'
		,'Retro IZA Income Standard Tax'
		,'Retro IZA Income Special Tax'
		,'Retro IZA Income Non Taxable'
		,1
		,15700
		,NULL
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);*/

		--
		-- Archive Retro Employer SI Charges  Context Balance
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Employer SI Contribution'
		,'_ASG_SIT_YTD'
		,'Retro Employer SI Contribution Standard Tax'
		,'Retro Employer SI Contribution Special Tax'
		,NULL
		,1
		,16500
		,NULL
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		-- Archive Retro Employee SI Contribution  Context Balance
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Employee SI Contribution'
		,'_ASG_SIT_YTD'
		,'Retro Employee SI Contribution Standard Tax'
		,'Retro Employee SI Contribution Special Tax'
		,'Retro Employee SI Contribution Non Taxable'
		,1
		,17500
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		-- Archive Retro Net Employee SI Contribution Context Balance
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Net Employee SI Contribution'
		,'_ASG_SIT_YTD'
		,NULL
		,NULL
		,NULL
		,1
		,18500
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		-- Archive Retro ZVW Income Balances
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro ZVW Income'
		,'_ASG_YTD'
		,'Retro ZVW Income Standard Tax'
		,'Retro ZVW Income Special Tax'
		,NULL
		,1
		,18650
		,NULL
		,p_record_count
		,p_date_earned
		,'Y'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);
		--
		--
		-- Archive Retro Employee Private Health Contribution  Balance
		--
	/*	archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Employee Private Health Contribution'
		,'_ASG_YTD'
		,NULL
		,NULL
		,NULL
		,1
		,19500
		,'D'
		,p_record_count
		,p_date_earned
		,'Y'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		-- Archive Retro Nominal IZA Contribution Balance
		--
		archive_retro_balance_info(p_arch_assign_action_id
                ,p_run_assign_action_id
	        ,'Retro Nominal IZA Contribution'
	        ,'_ASG_YTD'
	        ,NULL
	        ,NULL
	        ,NULL
	        ,1
	        ,19551
                ,'D'
                ,p_record_count
	        ,p_date_earned
	        ,'N'
	        ,'Y'
	        ,p_payroll_action_id
	        ,p_assignment_id
	        ,p_effective_date);

                --
		-- Archive Retro Employee IZA Contribution  Balance
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Employee IZA Contribution'
		,'_ASG_YTD'
		,NULL
		,NULL
		,NULL
		,1
		,19700
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'Y'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);*/

		-- Archive Retro Foreigner Rule Standard/Special Balances
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Foreigner Rule (Taxable)'
		,'_ASG_YTD'
		,'Retro Foreigner Rule Standard Tax Adjustment'
		,'Retro Foreigner Rule Special Tax Adjustment'
		,NULL
		,1
		,21500
		,'D'
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);

		--
		-- Archive Retro Taxable Balance
		--
		archive_retro_balance_info(p_arch_assign_action_id
		,p_run_assign_action_id
		,'Retro Taxable Income'
		,'_ASG_YTD'
		,'Retro Standard Taxable Income'
		,'Retro Special Taxable Income'
		,NULL
		,1
		,22500
		,NULL
		,p_record_count
		,p_date_earned
		,'N'
		,'N'
		,p_payroll_action_id
		,p_assignment_id
		,p_effective_date);
--
END archive_payslip_balance_info;




/*-------------------------------------------------------------------------------
|Name           : ARCHIVE_CODE                                            		|
|Type			: Procedure														|
|Description    : This is the main procedure which calls the several procedures |
|		  			to archive the data.										|
-------------------------------------------------------------------------------*/

Procedure ARCHIVE_CODE (p_assignment_action_id                 IN NUMBER
	     	       ,p_effective_date                       IN DATE) IS


-- Cursor to  return all the Runs for a Pre Payment Process which
-- is being archived.
--
--Bug 3384315
CURSOR csr_assignment_actions(p_locking_action_id NUMBER) IS
SELECT pre.locked_action_id        pre_assignment_action_id,
	   passact.source_action_id    master_pre_asg_action_id,
       pay.locked_action_id        master_assignment_action_id,
       assact.assignment_id        assignment_id,
       assact.payroll_action_id    pay_payroll_action_id,
       paa.effective_date          effective_date,
       ppaa.effective_date         pre_effective_date,
       paa.date_earned             date_earned,
       paa.time_period_id          time_period_id,
       paa.payroll_id		   payroll_id
FROM   pay_action_interlocks       pre,
       pay_action_interlocks       pay,
       pay_payroll_actions         paa,
       pay_payroll_actions         ppaa,
       pay_assignment_actions      assact,
       pay_assignment_actions      passact
WHERE  pre.locked_action_id      = pay.locking_action_id
AND    pre.locking_action_id     = p_locking_action_id
AND    pre.locked_action_id      = passact.assignment_action_id
AND    passact.assignment_id	 =assact.assignment_id
AND    passact.payroll_action_id = ppaa.payroll_action_id
AND    ppaa.action_type          IN ('P','U')
AND    pay.locked_action_id      = assact.assignment_action_id
AND    assact.payroll_action_id  = paa.payroll_action_id
AND    assact.source_action_id   IS NULL
ORDER BY pay.locked_action_id DESC;

cursor csr_get_max_assignment_action(p_assignment_action_id NUMBER)
is
select max(paa.assignment_Action_id) max_assact from
pay_payroll_actions ppa,
pay_assignment_Actions paa,
pay_assignment_Actions paa1
where paa1.assignment_Action_id = p_assignment_action_id
and   paa1.payroll_action_id = ppa.payroll_action_id
and   paa.assignment_id = paa1.assignment_id
and   paa.payroll_action_id = ppa.payroll_action_id;


-- Cursor to retrieve all the Child Actions for a given master
-- assignment action.
--
CURSOR csr_child_actions(p_master_assignment_action NUMBER,
                         p_payroll_action_id        NUMBER,
                         p_assignment_id            NUMBER,
                         p_effective_date           DATE  ) IS
SELECT paa.assignment_action_id child_assignment_action_id,
       'S'                      run_type
FROM   pay_assignment_actions   paa,
       pay_run_types_f          prt
WHERE  paa.source_action_id     = p_master_assignment_action
AND    paa.payroll_action_id    = p_payroll_action_id
AND    paa.assignment_id        = p_assignment_id
AND    paa.run_type_id          = prt.run_type_id
AND    prt.run_method           = 'S'
AND    p_effective_date         BETWEEN prt.effective_start_date
                                AND     prt.effective_end_date
UNION
SELECT paa.assignment_action_id child_assignment_action_id,
       'NP'                     run_type --Standard Run, Process Separate Run
FROM   pay_assignment_actions   paa
WHERE  paa.payroll_action_id    = p_payroll_action_id
AND    paa.assignment_id        = p_assignment_id
AND    paa.action_sequence = (
            SELECT MAX(paa1.action_sequence)
            FROM   pay_assignment_actions paa1,
                   pay_run_types_f        prt1
            WHERE  prt1.run_type_id         = paa1.run_type_id
            AND    prt1.run_method          IN ('N','P')
            AND    paa1.payroll_action_id   = p_payroll_action_id
            AND    paa1.assignment_id       = p_assignment_id
            AND    paa1.source_action_id    = p_master_assignment_action
            AND    p_effective_date BETWEEN prt1.effective_start_date
                                    AND     prt1.effective_end_date);

--
-- Cursor to retrieve all N (Normal)and P (Process separate) Child Actions
-- for a given assignment action.
--
CURSOR csr_np_children (p_assignment_action_id NUMBER
                       ,p_payroll_action_id    NUMBER
                       ,p_assignment_id        NUMBER
                       ,p_effective_date       DATE) IS
SELECT paa.assignment_action_id np_assignment_action_id,
       prt.run_method           run_method
FROM   pay_assignment_actions   paa
      ,pay_run_types_f          prt
WHERE  paa.source_action_id     = p_assignment_action_id
AND    paa.payroll_action_id    = p_payroll_action_id
AND    paa.assignment_id        = p_assignment_id
AND    paa.run_type_id          = prt.run_type_id
AND    prt.run_method           IN ('N','P')
AND    p_effective_date         BETWEEN prt.effective_start_date
                                AND     prt.effective_end_date;

--Bug No. 3199386
--shveerab
CURSOR csr_period_end_date(p_assignment_action_id NUMBER) IS
SELECT ptp.end_date                end_date,
         ptp.regular_payment_date  regular_payment_date,
         ptp.time_period_id        time_period_id
   FROM  per_time_periods    ptp
        ,pay_payroll_actions ppa
        ,pay_assignment_actions paa
  WHERE  ptp.payroll_id             =ppa.payroll_id
    AND  ppa.payroll_action_id      =paa.payroll_action_id
    And paa.assignment_action_id    =p_assignment_action_id
    AND ppa.date_earned BETWEEN ptp.start_date AND ptp.end_date;


l_record_count  	NUMBER;
l_chunk_number		NUMBER;
l_iterative_flag	VARCHAR2(20);
csr_rec			csr_assignment_actions%ROWTYPE;
csr_rec_max             csr_assignment_actions%ROWTYPE;
csr_child_rec		csr_child_actions%ROWTYPE;
max_child_action        csr_child_actions%ROWTYPE;
v_csr_max_assact csr_get_max_assignment_action%ROWTYPE;
l_child_count		NUMBER;
l_actid			NUMBER;
l_action_context_id	NUMBER;
g_archive_pact		NUMBER;
p_assactid		NUMBER;
l_period_end_date	DATE;
l_payment_date		DATE;
l_time_period_id	NUMBER;
l_latest_child_asg_action_id NUMBER;
l_prepay_asg_action_id NUMBER;
l_max_prepay_action_id NUMBER;
l_max_assact_id NUMBER;
l_archive_stat NUMBER;
l_archive_user NUMBER;
l_stat_not_ytd NUMBER;
l_user_not_ytd NUMBER;
l_emp_archived NUMBER;
l_nl_emp_archived NUMBER;
--

l_dp_de varchar2(2);

BEGIN
	--
	--hr_utility.trace_on(NULL,'PSA');
	--hr_utility.set_location('Entering Archive Code',800);
	--
	g_zvw_er_cont_std_run := 0;
	g_zvw_er_cont_spl_run := 0;
	g_zvw_er_cont_std_ytd := 0;
	g_zvw_er_cont_spl_ytd := 0;
	g_retro_zvw_er_cont_std_run  := 0;
	g_retro_zvw_er_cont_spl_run  := 0;
	g_retro_zvw_er_cont_std_ytd  := 0;
	g_retro_zvw_er_cont_spl_ytd  := 0;
	g_travel_allowance := 0;
	g_retro_travel_allowance := 0;
      g_travel_allowance_ytd := 0;
	g_retro_travel_allowance_ytd := 0;
	--
	-- Retrieve the chunk number for the current assignment action
	--
	SELECT paa.chunk_number
	INTO   l_chunk_number
	FROM   pay_assignment_actions paa
	WHERE  paa.assignment_action_id = p_assignment_action_id;
	--
	l_record_count := 0;
	l_archive_stat := 0;
	l_archive_user := 0;
	l_emp_archived := 0;
	l_nl_emp_archived := 0;

	--hr_utility.set_location('Inside Archive Code l_chunk_number'||l_chunk_number,850);
	--hr_utility.set_location('Inside Archive Code p_assignment_action_id'||p_assignment_action_id,850);

	OPEN csr_get_max_assignment_action(p_assignment_action_id);
	FETCH csr_get_max_assignment_action INTO v_csr_max_assact;
	CLOSE csr_get_max_assignment_action;


	OPEN csr_assignment_actions(p_assignment_action_id);
	LOOP
		--
		l_iterative_flag := 'N';
		l_prepay_asg_action_id :=0;


		--
		FETCH csr_assignment_actions into csr_rec;

		--Bug 5982957 Starts (To identify the Late Hire Assignments)
		l_dp_de := pay_nl_general.check_de_dp_dimension_old(csr_rec.pay_payroll_action_id
										,csr_rec.assignment_id
										,csr_rec.master_assignment_action_id
										);
		--Bug 5982957 Ends

		--EXIT when csr_assignment_actions%NOTFOUND or csr_assignment_actions%NOTFOUND IS NULL;

		-- Archive the employee details for the last row returned by
		-- the cursor csr_assignment_actions.
		-- This will ensure that the the correct time period is passed
		-- to the global package if there are multiple runs in a single
		-- pre payment.
		--

		hr_utility.set_location('Inside Archive Code csr_rec.pre_assignment_action_id'||csr_rec.pre_assignment_action_id ,900);
		hr_utility.set_location('Inside Archive Code csr_rec.assignment_id'||csr_rec.assignment_id ,900);
		hr_utility.set_location('Inside Archive Code csr_rec.master_assignment_action_id'||csr_rec.master_assignment_action_id ,900);
		hr_utility.set_location('Inside Archive Code g_payroll_action_id'||g_payroll_action_id,900);

		If csr_assignment_actions%NOTFOUND THEN
			--hr_utility.set_location('Inside Archive Code g_payroll_action_id'||g_payroll_action_id,950);
		--	IF csr_assignment_actions%ROWCOUNT > 0 then
				--Bug No. 3199386
				--shveerab

			/*	OPEN csr_period_end_date(csr_rec.master_assignment_action_id);
				FETCH csr_period_end_date INTO l_period_end_date , l_payment_date,l_time_period_id;
				CLOSE csr_period_end_date;
				--
				-- Archive EMPLOYEE DETAILS Context
				--
				--hr_utility.set_location('Inside Archive Code g_payroll_action_id'||g_payroll_action_id,1000);

				--Added Additional Code (Bug:3869788) to Pick Up
				--Prepayment Master Assignment Action Id if Multiple Asg Payment Consoliation is enabled
				--Else Pick up the Prepayment Asg Action Id a before.
				IF csr_rec.master_pre_asg_action_id IS NOT NULL THEN
					l_prepay_asg_action_id := csr_rec.master_pre_asg_action_id;
				ELSE
					l_prepay_asg_action_id := csr_rec.pre_assignment_action_id;
				END IF;
				pay_nl_payslip_archive.archive_employee_details (
				p_payroll_action_id   	=> g_payroll_action_id
				,p_assactid            	=> p_assignment_action_id
				,p_assignment_id       	=> csr_rec.assignment_id
				,p_curr_pymt_ass_act_id	=> l_prepay_asg_action_id
				,p_archive_effective_date => csr_rec.effective_date
				,p_date_earned          	=> csr_rec.date_earned
				,p_curr_pymt_eff_date   	=> l_payment_date
				,p_time_period_id       	=> l_time_period_id
				,p_record_count         	=> l_record_count);

				pay_nl_payslip_archive.archive_nl_employee_details (
				p_assg_action_id             => p_assignment_action_id
				,p_assignment_id        => csr_rec.assignment_id
				,p_master_asg_act_id 	=> l_latest_child_asg_action_id
				,p_payroll_id		=>csr_rec.payroll_id
				,p_date_earned         => csr_rec.effective_date);*/

				-- Both User,Statutory Balances AND PAyslip Balances are archived for
				-- S Type actions and the last(highest action sequence) N or P Type
				--
				-- Archive User Balances in EMEA BALANCES Context
				--

				/*FOR l_index IN 1 .. g_user_balance_table.count
				LOOP

					hr_utility.set_location('Inside Archive Code  for NP run Type'||g_user_balance_table(l_index).balance_name,1260);

					pay_nl_payslip_archive.process_balance (
					p_action_context_id => p_assignment_action_id
					, p_assignment_id     => csr_rec.assignment_id
					, p_source_id         => l_latest_child_asg_action_id
					, p_effective_date    => csr_rec.effective_date
					, p_balance           => g_user_balance_table(l_index).balance_name
					, p_dimension         =>
							g_user_balance_table(l_index).database_item_suffix
					, p_defined_bal_id    =>
							g_user_balance_table(l_index).defined_balance_id
					, p_si_type           => g_user_balance_table(l_index).si_type
					, p_record_count      => l_record_count);
				END LOOP;*/

				--
				-- Archive Statutory Balances in EMEA BALANCES Context
				--
				/*FOR l_index IN 1 .. g_statutory_balance_table.count
				LOOP

					hr_utility.set_location('Inside Archive Code for NP run Type '||g_statutory_balance_table(l_index).balance_name,1270);
					pay_nl_payslip_archive.process_balance (
					p_action_context_id => p_assignment_action_id
					,p_assignment_id     => csr_rec.assignment_id
					,p_source_id         => l_latest_child_asg_action_id
					,p_effective_date    => csr_rec.effective_date
					,p_balance           => g_statutory_balance_table(l_index).balance_name
					,p_dimension         => g_statutory_balance_table(l_index).database_item_suffix
					,p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id
					,p_si_type           => g_statutory_balance_table(l_index).si_type
					,p_record_count      => l_record_count);

				END LOOP;*/
				--
				-- Archive Payslip Balances in NL CALCULATIONS Context
				--
				/*pay_nl_payslip_archive.archive_payslip_balance_info(
				p_arch_assign_action_id   => p_assignment_action_id
				, p_run_assign_action_id    =>csr_rec.master_assignment_action_id
				, p_date_earned             => csr_rec.date_earned
				, p_record_count            =>l_record_count
				,p_payroll_action_id        =>csr_rec.pay_payroll_action_id
				,p_assignment_id           => csr_rec.assignment_id
				,p_effective_date	       =>csr_rec.effective_date);*/

		--	END IF;
			EXIT;
		END IF;

		--hr_utility.set_location('Inside Archive Code master_assignment_action_id'||csr_rec.master_assignment_action_id,1100);
		--
		-- If child actions exist for the given master action
		--

		FOR csr_child_rec IN csr_child_actions(
					 csr_rec.master_assignment_action_id,
					 csr_rec.pay_payroll_action_id,
					 csr_rec.assignment_id,
					 csr_rec.effective_date)

		LOOP

		--hr_utility.set_location('Inside Archive Code pay_payroll_action_id'||csr_rec.pay_payroll_action_id,1200);
		-- create additional archive assignment actions and interlocks

		IF csr_child_rec.run_type = 'NP' THEN
			l_child_count := 0;
			FOR csr_np_rec IN csr_np_children(
			csr_rec.master_assignment_action_id,
			csr_rec.pay_payroll_action_id,
			csr_rec.assignment_id,
			csr_rec.effective_date)
			LOOP
				--
				-- Archive Statutory Element Information in NL CALCULATIONS Context

				pay_nl_payslip_archive.archive_payslip_element_info (
				p_arch_assign_action_id   => p_assignment_action_id
				, p_run_assign_action_id    =>
				csr_np_rec.np_assignment_action_id
				, p_date_earned             => csr_rec.date_earned
				, p_record_count            => l_record_count
				, p_master_assign_action_id => csr_rec.master_assignment_action_id
				, p_payroll_action_id       => csr_rec.pay_payroll_action_id
				, p_assignment_id           => csr_rec.assignment_id
				, p_effective_date	      => csr_rec.effective_date
				, p_child_count	      =>l_child_count);


				IF l_child_count = 0 THEN
					--
					-- Archive NL EMPLOYEE DETAILS
					--
				l_latest_child_asg_action_id := csr_np_rec.np_assignment_action_id;

				--Bug 5982957 Starts
				IF l_dp_de = 'DE' THEN
					pay_nl_payslip_archive.archive_nl_employee_details (
					p_assg_action_id			=> p_assignment_action_id
					,p_assignment_id			=> csr_rec.assignment_id
					,p_master_asg_act_id 		=> l_latest_child_asg_action_id
					,p_payroll_id			=>csr_rec.payroll_id
					--,p_date_earned			=> csr_rec.effective_date);
					,p_date_earned			=> csr_rec.date_earned);
				END IF;
				--Bug 5982957 Ends

	 		     IF l_emp_archived = 0 THEN
				OPEN csr_period_end_date(csr_rec.master_assignment_action_id);
    				FETCH csr_period_end_date INTO l_period_end_date , l_payment_date,l_time_period_id;
				CLOSE csr_period_end_date;
    				--
    	   			-- Archive EMPLOYEE DETAILS Context
	       			--
    				--hr_utility.set_location('Inside Archive Code g_payroll_action_id'||g_payroll_action_id,1000);

    				--Added Additional Code (Bug:3869788) to Pick Up
    				--Prepayment Master Assignment Action Id if Multiple Asg Payment Consoliation is enabled
    				--Else Pick up the Prepayment Asg Action Id a before.
    				IF csr_rec.master_pre_asg_action_id IS NOT NULL THEN
    					l_prepay_asg_action_id := csr_rec.master_pre_asg_action_id;
    				ELSE
    					l_prepay_asg_action_id := csr_rec.pre_assignment_action_id;
    				END IF;
    				pay_nl_payslip_archive.archive_employee_details (
    				p_payroll_action_id   	=> g_payroll_action_id
    				,p_assactid            	=> p_assignment_action_id
    				,p_assignment_id       	=> csr_rec.assignment_id
    				,p_curr_pymt_ass_act_id	=> l_prepay_asg_action_id
    				,p_archive_effective_date => csr_rec.effective_date
    				,p_date_earned          	=> csr_rec.date_earned
    				,p_curr_pymt_eff_date   	=> l_payment_date
    				,p_time_period_id       	=> l_time_period_id
    				,p_record_count         	=> l_record_count);

			      IF l_nl_emp_archived = 0 THEN
					--Bug 5982957 extra if condition added
					IF l_dp_de = 'DP' THEN
						pay_nl_payslip_archive.archive_nl_employee_details (
						p_assg_action_id             => p_assignment_action_id
						,p_assignment_id        => csr_rec.assignment_id
						,p_master_asg_act_id 	=> l_latest_child_asg_action_id
						,p_payroll_id		=>csr_rec.payroll_id
						,p_date_earned         => csr_rec.effective_date);
					END IF;
					pay_nl_payslip_archive.archive_payslip_balance_info(
					p_arch_assign_action_id   => p_assignment_action_id
					, p_run_assign_action_id    =>csr_rec.master_assignment_action_id
					, p_date_earned             => csr_rec.date_earned
					, p_record_count            =>l_record_count
					,p_payroll_action_id        =>csr_rec.pay_payroll_action_id
					,p_assignment_id           => csr_rec.assignment_id
					,p_effective_date	       =>csr_rec.effective_date);
				END IF;
   				l_emp_archived := 1;
    				l_nl_emp_archived := 1;

              END IF;

    		END IF;

				-- Archive User Element Information in EMEA ELEMENT INFO Context
				pay_nl_payslip_archive.archive_user_element_info (
				p_action_context_id       => p_assignment_action_id
				, p_assignment_id           => csr_rec.assignment_id
				, p_child_assignment_action =>
				csr_np_rec.np_assignment_action_id
				, p_effective_date          => csr_rec.date_earned
				, p_record_count            => l_record_count
				, p_run_method              => csr_np_rec.run_method);
--
				-- Archive Statutory Balances in EMEA BALANCES Context
				--
				FOR l_index IN 1 .. g_statutory_balance_table.count
				LOOP
				        IF (g_statutory_balance_table(l_index).database_item_suffix <> '_ASG_YTD' AND g_statutory_balance_table(l_index).database_item_suffix <> '_ASG_SIT_YTD') THEN
				            l_stat_not_ytd := 1;
				        ELSE
				            l_stat_not_ytd := 0;
				        END IF;
				        IF ((v_csr_max_assact.max_assact <> p_assignment_action_id AND (l_stat_not_ytd = 1))
				           OR (v_csr_max_assact.max_assact = p_assignment_action_id AND csr_np_rec.np_assignment_action_id <> csr_child_rec.child_assignment_action_id AND (l_stat_not_ytd = 1))
				           OR v_csr_max_assact.max_assact = p_assignment_action_id AND csr_np_rec.np_assignment_action_id = csr_child_rec.child_assignment_action_id AND (l_archive_stat = 0 OR (l_archive_stat = 1 AND l_stat_not_ytd = 1))) THEN
					hr_utility.set_location('Inside Archive Code for NP run Type '||g_statutory_balance_table(l_index).balance_name,1270);
					pay_nl_payslip_archive.process_balance (
					p_action_context_id => p_assignment_action_id
					,p_assignment_id     => csr_rec.assignment_id
					,p_source_id         => csr_np_rec.np_assignment_action_id
					,p_effective_date    => csr_rec.effective_date
					,p_balance           => g_statutory_balance_table(l_index).balance_name
					,p_dimension         => g_statutory_balance_table(l_index).database_item_suffix
					,p_defined_bal_id    => g_statutory_balance_table(l_index).defined_balance_id
					,p_si_type           => g_statutory_balance_table(l_index).si_type
					,p_record_count      => l_record_count);
					END IF;

				END LOOP;

				-- Archive User Balances in EMEA BALANCES Context
				--
				FOR l_index IN 1 .. g_user_balance_table.count
				LOOP
				         IF (g_user_balance_table(l_index).database_item_suffix <> '_ASG_YTD' AND g_user_balance_table(l_index).database_item_suffix <> '_ASG_SIT_YTD') THEN
					     l_user_not_ytd := 1;
					   ELSE
					     l_user_not_ytd := 0;
				         END IF;
				        IF ((v_csr_max_assact.max_assact <> p_assignment_action_id AND (l_user_not_ytd = 1))
				        OR (v_csr_max_assact.max_assact = p_assignment_action_id AND csr_np_rec.np_assignment_action_id <> csr_child_rec.child_assignment_action_id AND (l_user_not_ytd = 1))
				           OR v_csr_max_assact.max_assact = p_assignment_action_id AND csr_np_rec.np_assignment_action_id = csr_child_rec.child_assignment_action_id AND (l_archive_user = 0 OR (l_archive_user = 1 AND l_user_not_ytd = 1))) THEN
					hr_utility.set_location('Inside Archive Code  for NP run Type'||g_user_balance_table(l_index).balance_name,1260);
				        pay_nl_payslip_archive.process_balance (
					p_action_context_id => p_assignment_action_id
					, p_assignment_id     => csr_rec.assignment_id
					, p_source_id         => csr_np_rec.np_assignment_action_id
					, p_effective_date    => csr_rec.effective_date
					, p_balance           => g_user_balance_table(l_index).balance_name
					, p_dimension         => g_user_balance_table(l_index).database_item_suffix
					, p_defined_bal_id    => g_user_balance_table(l_index).defined_balance_id
					, p_si_type           => g_user_balance_table(l_index).si_type
					, p_record_count      => l_record_count);
					END IF;
				END LOOP;

				l_child_count := l_child_count + 1;

			END LOOP;

			END IF;

			l_iterative_flag := 'Y';

			END LOOP; -- child assignment actions
			--

			--hr_utility.set_location('Inside Archive Code l_record_count'||l_record_count,1300);

			--
			-- Archive for the main run
			--
			-- This section of the code can be removed once iterative engine setup has
			-- been enabled for NL.i.e when rule type has been sedded for NL
			--
			--hr_utility.set_location('Inside Archive Code l_record_count'||l_record_count,1400);
			--hr_utility.set_location('Inside Archive Code l_iterative_flag'||l_iterative_flag,1400);

	IF  l_iterative_flag = 'N' THEN
		--
		-- Archive NL EMPLOYEE DETAILS,NL OTHER EMPLOYEE DETAILS
		-- and NL SI EMPLOYEE DETAILS
		--
		--Bug 5982957 (Extra condition added "and l_dp_de= DP/DE")
		IF l_nl_emp_archived = 0 and l_dp_de = 'DP' THEN
			pay_nl_payslip_archive.archive_nl_employee_details (
			p_assg_action_id        => p_assignment_action_id
			,p_master_asg_act_id	=>csr_rec.master_assignment_action_id
			,p_assignment_id        => csr_rec.assignment_id
			,p_payroll_id           => csr_rec.payroll_id
			,p_date_earned		=> csr_rec.effective_date);
		ELSIF l_nl_emp_archived = 0 and l_dp_de = 'DE' THEN
			pay_nl_payslip_archive.archive_nl_employee_details (
			p_assg_action_id        => p_assignment_action_id
			,p_master_asg_act_id	=> csr_rec.master_assignment_action_id
			,p_assignment_id        => csr_rec.assignment_id
			,p_payroll_id           => csr_rec.payroll_id
			--,p_date_earned		=> csr_rec.effective_date);
			,p_date_earned		=> csr_rec.date_earned);
		END IF;

		--hr_utility.set_location('Inside Archive Code p_assignment_action_id'||p_assignment_action_id,1500);

		-- Archive User Element Information in EMEA ELEMENT INFO Context
		pay_nl_payslip_archive.archive_user_element_info (
		p_action_context_id       => p_assignment_action_id
		, p_assignment_id           => csr_rec.assignment_id
		, p_child_assignment_action =>
		csr_rec.master_assignment_action_id
		, p_effective_date          => csr_rec.date_earned
		, p_record_count            => l_record_count
		, p_run_method              => NULL);

		--hr_utility.set_location('Inside Archive Code csr_rec.master_assignment_action_id'||csr_rec.master_assignment_action_id,1600);

		-- Archive Statutory Element Information in NL CALCULATIONS Context

		pay_nl_payslip_archive.archive_payslip_element_info (
		p_arch_assign_action_id   => p_assignment_action_id
		, p_run_assign_action_id    =>
		csr_rec.master_assignment_action_id
		, p_date_earned          => csr_rec.date_earned
		, p_record_count            => l_record_count
		, p_master_assign_action_id => csr_rec.master_assignment_action_id
		, p_payroll_action_id       => csr_rec.pay_payroll_action_id
		, p_assignment_id           => csr_rec.assignment_id
		, p_effective_date	      => csr_rec.effective_date
		, p_child_count	      =>l_child_count);

		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||l_iterative_flag,1700);
		--
		-- Archive User Balances
		--
		FOR l_index IN 1 .. g_user_balance_table.count
		LOOP
			--hr_utility.set_location('Inside Archive Code balance_name'||g_user_balance_table(l_index).balance_name,1800);
			--hr_utility.set_location('Inside Archive Code database_item_suffix'||g_user_balance_table(l_index).database_item_suffix,1800);
			--hr_utility.set_location('Inside Archive Code defined_balance_id'||g_user_balance_table(l_index).defined_balance_id,1800);
			--hr_utility.set_location('Inside Archive Code si_type'||g_user_balance_table(l_index).si_type,1800);
			--hr_utility.set_location('Inside Archive Code l_index'||l_index,1800);
			--hr_utility.set_location('Inside Archive Code g_user_balance_table.count '||g_user_balance_table.count ,1800);
			--hr_utility.set_location('Inside Archive Code master_assignment_action_id'||csr_rec.master_assignment_action_id,1800);
			--hr_utility.set_location('Inside Archive Code csr_rec.date_earned '||csr_rec.date_earned ,1800);
			--hr_utility.set_location('Inside Archive Code csr_rec.effective_date '||csr_rec.effective_date,1800);
			--hr_utility.set_location('Inside Archive Code p_assignment_action_id '||p_assignment_action_id,1800);
			--hr_utility.set_location('Inside Archive Code l_record_count '||l_record_count,1800);
			--hr_utility.set_location('Inside Archive Code csr_rec.assignment_id '||csr_rec.assignment_id,1800);

			BEGIN
				pay_nl_payslip_archive.process_balance (
				p_action_context_id => p_assignment_action_id
				, p_assignment_id     => csr_rec.assignment_id
				, p_source_id         => csr_rec.master_assignment_action_id
				, p_effective_date    => csr_rec.effective_date
				, p_balance           =>
				g_user_balance_table(l_index).balance_name
				, p_dimension         =>
				g_user_balance_table(l_index).database_item_suffix
				, p_defined_bal_id    =>
				g_user_balance_table(l_index).defined_balance_id
				,p_si_type           =>
				g_user_balance_table(l_index).si_type
				, p_record_count      => l_record_count);


			EXCEPTION
			WHEN OTHERS THEN
				hr_utility.set_location('Inside Archive Code Exception'||SQLCODE||'sqlerr'||SQLERRM,1800);
				raise;
			END;
  		END LOOP;

		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||l_iterative_flag,1900);
		--
		-- Archive Statutory Balances
		--
		--hr_utility.set_location('Inside Archive Code l_count'||g_statutory_balance_table.count,2000);

		FOR l_index IN 1 .. g_statutory_balance_table.count LOOP

		--hr_utility.set_location('Inside Archive Code l_index'||l_index,2001);
		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||g_statutory_balance_table(l_index).balance_name,2001);
		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||g_statutory_balance_table(l_index).database_item_suffix,2001);
		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||g_statutory_balance_table(l_index).defined_balance_id,2001);
		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||g_statutory_balance_table(l_index).si_type,2001);
		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||l_record_count,2001);

			pay_nl_payslip_archive.process_balance (
			p_action_context_id => p_assignment_action_id
			,p_assignment_id     => csr_rec.assignment_id
			,p_source_id         => csr_rec.master_assignment_action_id
			,p_effective_date    => csr_rec.effective_date
			,p_balance           =>
			g_statutory_balance_table(l_index).balance_name
			,p_dimension         =>
			g_statutory_balance_table(l_index).database_item_suffix
			,p_defined_bal_id    =>
			g_statutory_balance_table(l_index).defined_balance_id
			,p_si_type           =>
			g_statutory_balance_table(l_index).si_type
			,p_record_count      => l_record_count);
		END LOOP;

		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||l_iterative_flag,2100);
		--
		-- Archive Payslip Balances(displayed in payments deductions
		-- section)  in NL CALCULATIONS Context
		--
		--hr_utility.set_location('Inside Archive Code p_assignment_action_id'||p_assignment_action_id,2100);
		--hr_utility.set_location('Inside Archive Code csr_rec.master_assignment_action_id'||csr_rec.master_assignment_action_id,2100);
		--hr_utility.set_location('Inside Archive Code csr_rec.date_earned'||csr_rec.date_earned,2100);
		--hr_utility.set_location('Inside Archive Code l_record_count'||l_record_count,2100);
	              IF l_nl_emp_archived = 0 THEN
		pay_nl_payslip_archive.archive_payslip_balance_info(
		p_arch_assign_action_id   => p_assignment_action_id
		, p_run_assign_action_id    =>
		  csr_rec.master_assignment_action_id
		, p_date_earned             => csr_rec.date_earned
		, p_record_count            => l_record_count
		,p_payroll_action_id        =>csr_rec.pay_payroll_action_id
		,p_assignment_id           => csr_rec.assignment_id
		,p_effective_date	       =>csr_rec.effective_date);
	              END IF;
		l_nl_emp_archived := 1;

		--hr_utility.set_location('Inside Archive Code l_iterative_flag'||l_iterative_flag,2200);
		--
	END IF;
	l_record_count := l_record_count + 1;
	l_archive_stat := 1;
	l_archive_user := 1;
END LOOP;
close csr_assignment_actions;



--hr_utility.set_location('Leaving Archive code',2300);
--
END ARCHIVE_CODE;

END PAY_NL_PAYSLIP_ARCHIVE;

/
