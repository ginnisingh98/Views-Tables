--------------------------------------------------------
--  DDL for Package Body PAY_DK_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_RULES" as
/* $Header: pydkrule.pkb 120.11.12010000.11 2010/02/11 11:33:55 knadhan ship $ */

-----------------------------------------------------------------------------
-- Procedure : get_third_party_org_context
-- It fetches the third party context of the Assignment Id.
-----------------------------------------------------------------------------

/* Modified procedure get_third_party_org_context for pension changes */

PROCEDURE get_third_party_org_context
(p_asg_act_id           IN     NUMBER
,p_ee_id                IN     NUMBER
,p_third_party_id       IN OUT NOCOPY NUMBER )
IS
        l_element_name PAY_ELEMENT_TYPES_F.ELEMENT_NAME%TYPE;
	/* Added effective date */
	l_effective_date         DATE;
	/* Added for pension changes */
	l_ele_type_id            NUMBER;


 /* Modified cursors to use effective date join */
 /* Modified for pension changes to fetch element_type_id also */
        CURSOR get_element_name(p_ee_id NUMBER , p_effective_date DATE ) IS
        SELECT pet.element_name , pet.element_type_id
        FROM   pay_element_types pet
             , pay_element_entries pee
        WHERE pee.element_entry_id = p_ee_id
        AND pee.element_type_id = pet.element_type_id
	AND  p_effective_date BETWEEN pet.effective_start_date AND pet.effective_end_date
	AND  p_effective_date BETWEEN pee.effective_start_date AND pee.effective_end_date;

 /* Modified cursors to use effective date join */
 /* Modified for pension changes to fetch Pension provider Org ID from element entry values */
        /*CURSOR get_pp_details( p_asg_act_id NUMBER, p_effective_date DATE ) IS
        SELECT scl.segment2
        FROM hr_soft_coding_keyflex               scl
            ,per_all_assignments                  paa
            ,pay_assignment_actions               pac
        WHERE  paa.assignment_id             = pac.assignment_id
        AND    pac.assignment_action_id      = p_asg_act_id
        AND    scl.soft_coding_keyflex_id    = paa.soft_coding_keyflex_id
        AND    scl.enabled_flag              = 'Y'
	AND    p_effective_date BETWEEN paa.effective_start_date AND paa.effective_end_date;*/

	CURSOR get_pp_details( p_asg_act_id NUMBER, p_effective_date DATE , p_ele_type_id NUMBER) IS
	SELECT screen_entry_value
	FROM pay_element_entry_values_f peev
	WHERE element_entry_id = p_ee_id
	AND input_value_id IN
	 ( select input_value_id
	   from pay_input_values_f
	   where element_type_id = p_ele_type_id
	   and name = 'Third Party Payee')
	and p_effective_date between peev.effective_start_date and peev.effective_end_date;


 /* Added cursor to fetch effective date */
 	CURSOR c_effective_date(p_asg_act_id NUMBER ) IS
	SELECT  effective_date
	FROM pay_payroll_actions ppa,  pay_assignment_actions paa
	WHERE paa.assignment_action_id  = p_asg_act_id
	AND   paa.payroll_action_id   =  ppa.payroll_action_id ;


BEGIN

        OPEN c_effective_date(p_asg_act_id);
	FETCH c_effective_date INTO l_effective_date;
	CLOSE c_effective_date;


        OPEN get_element_name(p_ee_id, l_effective_date);
        FETCH get_element_name INTO l_element_name, l_ele_type_id ;
        CLOSE get_element_name;


        --IF l_element_name = 'Pension'  THEN
	/* Added elements for pension changes */
	IF l_element_name IN('Pension','Employer Pension','Retro Pension','Retro Employer Pension') THEN
	        /* Added l_ele_type_id  for pension changes */
                OPEN get_pp_details(p_asg_act_id, l_effective_date, l_ele_type_id );
                FETCH get_pp_details INTO p_third_party_id;
                CLOSE get_pp_details;
        END IF;


	/* Following check is disabled. Returning -999 is not correct, as this value will be validated */
	/*
        IF p_third_party_id IS NULL THEN
                p_third_party_id := -999;
        END IF;
	*/


EXCEPTION
        WHEN others THEN
        NULL;

END get_third_party_org_context;

--------------------------------------------------------------------------------
--    Name        : LOAD_XML
--    Description : This Function returns the XML data with the tag names.
--    Parameters  : P_NODE_TYPE       This parameter can take one of these values: -
--                                        1. CS - This signifies that string contained in
--                                                P_NODE parameter is start of container
--                                                node. P_DATA parameter is ignored in this
--                                                mode.
--                                        2. CE - This signifies that string contained in
--                                                P_NODE parameter is end of container
--                                                node. P_DATA parameter is ignored in this
--                                                mode.
--                                        3. D  - This signifies that string contained in
--                                                P_NODE parameter is data node and P_DATA
--                                                carries actual data to be contained by
--                                                tag specified by P_NODE parameter.
--
--                  P_CONTEXT_CODE    Context code of Action Information DF.
--
--                  P_NODE            Name of XML tag, or, application column name of flex segment.
--
--                  P_DATA            Data to be contained by tag specified by P_NODE parameter.
--                                    P_DATA is not used unless P_NODE_TYPE = D.
--------------------------------------------------------------------------------
--
FUNCTION load_xml  (p_node_type     VARCHAR2,
                    p_context_code  VARCHAR2,
                    p_node          VARCHAR2,
                    p_data          VARCHAR2) RETURN VARCHAR2 IS
    --
    CURSOR csr_get_tag_name IS
    SELECT TRANSLATE (UPPER(end_user_column_name), ' /','__') tag_name
    FROM  fnd_descr_flex_col_usage_vl
    WHERE descriptive_flexfield_name    = 'Action Information DF'
    AND   descriptive_flex_context_code = p_context_code
    AND   application_column_name       = UPPER (p_node);
    --
    l_tag_name  VARCHAR2(500);
    l_data      pay_action_information.action_information1%TYPE;
    l_node      pay_action_information.action_information1%TYPE;
    --
BEGIN
    --
    IF p_node_type = 'CS' THEN
        l_node :=  TRANSLATE(p_node, ' /', '__');
        RETURN  '<'||l_node||'>' ;
    ELSIF p_node_type = 'CE' THEN
        l_node :=  TRANSLATE(p_node, ' /', '__');
        RETURN  '</'||l_node||'>';
    ELSIF p_node_type = 'D' THEN
        --
        -- Fetch segment names
        --
        OPEN csr_get_tag_name;
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;
        --
        l_node := nvl( l_tag_name,TRANSLATE(p_node, ' /', '__')) ;
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '\&', '\&amp;');
        l_data := REPLACE (l_data, '>', '\&gt;');
        l_data := REPLACE (l_data, '<', '\&lt;');
        l_data := REPLACE (l_data, '''', '\&apos;');
        l_data := REPLACE (l_data, '"', '\&quot;');
        --
        RETURN  '<'||l_node||'>'||l_data||'</'||l_node||'>';
    END IF;
    --
END load_xml;


-------------------------------------------------------------------------------
-- flex_seg_enabled
-------------------------------------------------------------------------------
FUNCTION flex_seg_enabled(p_context_code              VARCHAR2,
                          p_application_column_name   VARCHAR2) RETURN BOOLEAN AS
    --
    CURSOR csr_seg_enabled IS
    SELECT 'Y'
    FROM fnd_descr_flex_col_usage_vl
    WHERE descriptive_flexfield_name  LIKE 'Action Information DF'
    AND descriptive_flex_context_code    =  p_context_code
    AND application_column_name       LIKE  p_application_column_name
    AND enabled_flag                     =  'Y';
    --
    l_proc_name varchar2(100);
    l_exists    varchar2(1);
    --
BEGIN
    --
    OPEN csr_seg_enabled;
        FETCH csr_seg_enabled INTO l_exists;
    CLOSE csr_seg_enabled;
    --
    IF l_exists = 'Y' THEN
        RETURN (TRUE);
    ELSE
        RETURN (FALSE);
    END IF;
    --
END flex_seg_enabled;
--
-------------------------------------------------------------------------------
-- add_custom_xml
-------------------------------------------------------------------------------
PROCEDURE add_custom_xml (p_assignment_action_id        NUMBER
                         ,p_action_information_category VARCHAR2
                         ,p_document_type               VARCHAR2) IS

----- cursor to get the element information for earnings and deductions elements ----------------

/*Modified order by clause for bug fix 6165239*/

    CURSOR csr_element_info(p_action_context_id   NUMBER
                           ,p_pa_category         VARCHAR2
                           ,p_aap_category        VARCHAR2) IS
	SELECT pai.action_information2 element_type_id
		  ,pai.action_information3 input_value_id
		  /* Change the decode to get the element name with pension provider */
		  ,decode(pai1.action_information8,NULL,decode(pai1.action_information3,'PP',
							SUBSTR(pai.action_information4,INSTR(pai.action_information4,',')+1)||' ('||
							SUBSTR(pai1.action_information9,1,INSTR(pai1.action_information9,':')-1)||')',
							SUBSTR(pai.action_information4,INSTR(pai.action_information4,',')+1)),
		  	  		    decode(pai1.action_information3,'PP',SUBSTR(pai.action_information4,
					    INSTR(pai.action_information4,',')+1)||' ('||SUBSTR(pai1.action_information9,1,
					    INSTR(pai1.action_information9,':')-1)||')',SUBSTR(pai.action_information4,INSTR(pai.action_information4,',')+1))) Name
      	          ,SUBSTR(pai.action_information4,1,INSTR(pai.action_information4,',')-1) CODE -- Changes for Bug 7229247
		  ,pai.action_information5 type
		  ,pai.action_information6 uom
		  ,fnd_number.canonical_to_number(pai1.action_information8) record_count    -- Format Changes for Payslip  Bug - 7229247 /* 9358829 */
		  --,sum(pai1.action_information4) value
		  ,substr(pai1.action_information9,instr(pai1.action_information9,':',-1)+1) unit_price  -- Format Changes in Payslip Bug - 7229247
		  ,sum(fnd_number.canonical_to_number(pai1.action_information4)) value  -- Format Changes for Payslip  Bug - 7229247
		  FROM pay_action_information pai
		,pay_action_information pai1
		,pay_assignment_actions paa
	WHERE pai.action_context_type = 'PA'
	AND pai.action_information_category = p_pa_category
	AND pai1.action_context_type = 'AAP'
	AND pai.action_information5 <> 'F'
	AND pai1.action_information3 <> 'F'
	---- Commented for performance fix
   /*  AND ( pai1.action_context_id  in ( SELECT paa.assignment_action_id
					   FROM pay_assignment_actions paa
					   WHERE paa.source_action_id = p_action_context_id
					   AND paa.assignment_id 	  = pai1.assignment_id
					 )
		 OR pai1.action_context_id = 	p_action_context_id)*/
	and pai1.action_information_category = p_aap_category
	and pai.action_information2 = pai1.action_information1
	and pai.action_information3 = pai1.action_information2 -- This condition is not there for balances
	and pai.action_context_id    = paa.payroll_action_id
	and pai1.action_context_id   = paa.assignment_action_id
	and paa.assignment_action_id = p_action_context_id
    group by pai.action_information2
            ,pai.action_information3
            ,pai.action_information4
            ,pai.action_information5
            ,pai.action_information6
            ,pai.action_information9	  -- Format Changes for Payslip  Bug - 7229247
             --Information 3 and 9 added in group by clause to get the sum based on pension provider
            ,pai1.action_information3
            ,pai1.action_information9  -- Format Changes for Payslip  Bug - 7229247
	    ,pai1.action_information10 /* 9358829 */
            ,pai1.action_information8  -- Format Changes for Payslip  Bug - 7229247
    ORDER BY pai.action_information5 DESC,fnd_number.canonical_to_number(pai1.action_information10); /* 9358829 */



----- cursor to get the element information for additional elements ----------------

/*Modified order by clause for bug fix 6165239*/

    CURSOR csr_add_element_info(p_action_context_id   NUMBER
                           ,p_pa_category         VARCHAR2
                           ,p_aap_category        VARCHAR2) IS
	SELECT pai.action_information2 element_type_id
		  ,pai.action_information3 input_value_id
		  -- Changes for Payslip Format
		  -- Start
		 -- ,decode(pai1.action_information8,NULL,pai.action_information4,
		 --		    pai.action_information4||'('||pai1.action_information8||')') Name
		  ,SUBSTR(pai.action_information4,INSTR(pai.action_information4,',')+1) Name
		  ,SUBSTR(pai.action_information4,1,INSTR(pai.action_information4,',')-1) CODE
		  ,fnd_number.canonical_to_number(pai1.action_information8) record_count
		  ,substr(pai1.action_information9,instr(pai1.action_information9,':',-1)+1) unit_price
		  -- End
		  ,pai.action_information5 type
		  ,pai.action_information6 uom
		   --,sum(pai1.action_information4) value
		  ,pai1.action_information4 value
	FROM pay_action_information pai
		,pay_action_information pai1
		,pay_assignment_actions paa
	WHERE pai.action_context_type = 'PA'
	AND pai.action_information_category = p_pa_category
	AND pai1.action_context_type = 'AAP'
	AND pai.action_information5 = 'F'
	AND pai1.action_information3 = 'F'
	-- Commented for performance fix
      /* AND ( pai1.action_context_id  in ( SELECT paa.assignment_action_id
                                           FROM pay_assignment_actions paa
					   WHERE paa.source_action_id = p_action_context_id
					   AND paa.assignment_id 	  = pai1.assignment_id
					  )
		 OR pai1.action_context_id = 	p_action_context_id)  */
	and pai1.action_information_category = p_aap_category
	and pai.action_information2 = pai1.action_information1
	and pai.action_information3 = pai1.action_information2 -- This condition is not there for balances
	and pai.action_context_id    = paa.payroll_action_id
	and pai1.action_context_id   = paa.assignment_action_id
	and paa.assignment_action_id = p_action_context_id
    group by pai.action_information2
            ,pai.action_information3
            ,pai.action_information4     -- Format Changes for Payslip  Bug - 7229247
            ,pai.action_information5
            ,pai.action_information6
	    ,pai1.action_information4
            ,pai1.action_information8     -- Format Changes for Payslip  Bug - 7229247
	    ,pai1.action_information9    -- Format Changes for Payslip  Bug - 7229247
--    ORDER BY pai.action_information5,pai1.action_information8 DESC;
    ORDER BY pai.action_information5 DESC,fnd_number.canonical_to_number(pai1.action_information8);



-------- cursor to get the payroll information -----------------------------

	CURSOR csr_payroll_info(p_action_context_id    NUMBER
	                       ,p_category            VARCHAR2
	) IS

    SELECT ppf.payroll_name         payroll_name
	,ptp.period_name     period_name
	,ptp.period_type     period_type
	,ptp.start_date      start_date
	,ptp.end_date         end_date
	--,pai.effective_date  payment_date
	,ptp.default_dd_date  payment_date
	FROM per_time_periods ptp
	,pay_payrolls_f   ppf
	,pay_action_information pai
	WHERE ppf.payroll_id = ptp.payroll_id
	AND pai.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
	AND ptp.time_period_id = pai.action_information16
	AND pai.action_context_type  = 'AAP'
	AND pai.action_information_category  = p_category
        AND pai.action_context_id=p_action_context_id;



	--AND paa.assignment_id = pai.assignment_id
	--AND paa.assignment_action_id=p_action_context_id
	--AND (pai.action_context_id = paa.assignment_action_id
 	         --  or pai.action_context_id = paa.source_action_id);

	/*AND (pai.action_context_id    =  p_action_context_id
	OR pai.action_context_id = ( SELECT paa.source_action_id
	                             FROM   pay_assignment_actions paa
                                 WHERE paa.assignment_action_id =  p_action_context_id
                             	 AND   paa.assignment_id       =  pai.Assignment_ID
	));*/

---------------

    l_total_earnings    NUMBER := 0;
    l_total_deductions  NUMBER := 0;
    l_total_pay         NUMBER;
    cntr_flex_col       NUMBER;
    l_flex_col_num      NUMBER;
    temp                varchar2(100);
    cntr                number;
    l_uom               varchar2(240);
    l_cntr_sql          NUMBER;
    sqlstr              DBMS_SQL.VARCHAR2S;
    csr                 NUMBER;
    ret                 NUMBER;

---------------

    -- Private Procedure to build dynamic sql

    PROCEDURE build_sql(p_sqlstr_tab    IN OUT NOCOPY DBMS_SQL.VARCHAR2S,
                        p_cntr          IN OUT NOCOPY NUMBER,
                        p_string        VARCHAR2) AS

    l_proc_name varchar2(100);

    BEGIN
        p_sqlstr_tab(p_cntr) := p_string;
        p_cntr               := p_cntr + 1;
    END;

----------------

BEGIN


    hr_utility.trace('Entering Pay_DK_RULES.add_custom_xml');
    hr_utility.trace('p_assignment_action_id '|| p_assignment_action_id);
    hr_utility.trace('p_action_information_category '|| p_action_information_category);
    hr_utility.trace('p_document_type '|| p_document_type);


if ( (p_document_type = 'PAYSLIP') AND (p_action_information_category is null) ) then

    hr_utility.trace('doc type is PAYSLIP and category is NULL ');

    -- ELEMENT DETAILS

    hr_utility.trace('ELEMENT DETAILS : start ');

    -- Earning and Deduction Elements

    hr_utility.trace('Earnings and deductions : start ');

    FOR csr_element_info_rec IN csr_element_info (p_assignment_action_id,'EMEA ELEMENT DEFINITION','EMEA ELEMENT INFO') LOOP
        --

	hr_utility.trace('Inside FOR loop for csr_element_info. ');

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CS', NULL, 'ELEMENT DETAILS', NULL) ;
        --
        IF csr_element_info_rec.type = 'E' THEN
           l_total_earnings := l_total_earnings + fnd_number.canonical_to_number(nvl(csr_element_info_rec.value,0)) ;
        END IF ;

        IF csr_element_info_rec.type = 'D' THEN
           l_total_deductions := l_total_deductions + fnd_number.canonical_to_number(nvl(csr_element_info_rec.value,0)) ;
        END IF ;
        --
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION2',csr_element_info_rec.element_type_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION3',csr_element_info_rec.input_value_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION4',csr_element_info_rec.Name);
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION5',csr_element_info_rec.type );

        l_uom := hr_general.decode_lookup('UNITS',csr_element_info_rec.uom);

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION6',l_uom );
        --

        --pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        --  load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4',csr_element_info_rec.value );
        /* Changes made for Payslip Format Change Bug - 7229247 */
	/*Start*/

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'ELEMENT_CODE',csr_element_info_rec.CODE );
	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'NUM_UNITS',csr_element_info_rec.record_count );
	 pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D',NULL, 'RATE_VAL',csr_element_info_rec.unit_price );

	/*End*/

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4',fnd_number.canonical_to_number(csr_element_info_rec.value) );


        --
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);
        --
    END LOOP;
    --    --

    hr_utility.trace('Earnings and deductions : end ');

    -- Additional Elements

    hr_utility.trace('Additional Elements : start ');

    FOR csr_element_info_rec IN csr_add_element_info (p_assignment_action_id,'EMEA ELEMENT DEFINITION','EMEA ELEMENT INFO') LOOP
        --

	hr_utility.trace('Inside FOR loop for csr_add_element_info. ');

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CS', NULL, 'ELEMENT DETAILS', NULL) ;
        --
	--
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION2',csr_element_info_rec.element_type_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION3',csr_element_info_rec.input_value_id );
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION4',csr_element_info_rec.Name);
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION5',csr_element_info_rec.type );

        l_uom := hr_general.decode_lookup('UNITS',csr_element_info_rec.uom);

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION6',l_uom );
        --
	/* Changes made for Payslip Format Change Bug - 7229247 */
	/*Start*/

	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'ELEMENT_CODE',csr_element_info_rec.CODE );
	pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'NUM_UNITS',csr_element_info_rec.record_count );
	 pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'RATE_VAL',csr_element_info_rec.unit_price );
	/*End*/

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4',csr_element_info_rec.value );

	--
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);
        --
    END LOOP;
    --    --
    fnd_file.put_line(fnd_file.log,'This is the tested case2');


   hr_utility.trace('Additional Elements : end ');

   hr_utility.trace('ELEMENT DETAILS : end ');

    -- PAYROLL PROCESSING INFORMATION

    hr_utility.trace('PAYROLL PROCESSING INFORMATION : start ');


    FOR payroll_info_rec IN csr_payroll_info(p_assignment_action_id , 'EMPLOYEE DETAILS' )
	LOOP

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CS', NULL, 'PAYROLL PROCESSING INFORMATION', NULL) ;

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PAYROLL_NAME',payroll_info_rec.payroll_name );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PERIOD_NAME',payroll_info_rec.period_name );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PERIOD_TYPE',payroll_info_rec.period_type);

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'START_DATE',payroll_info_rec.start_date );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'END_DATE',payroll_info_rec.end_date );

        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('D', NULL, 'PAYMENT_DATE',payroll_info_rec.payment_date );
        --
        pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
           load_xml('CE', NULL, 'PAYROLL PROCESSING INFORMATION', NULL);
        --

    END LOOP;

   hr_utility.trace('PAYROLL PROCESSING INFORMATION : end ');

   hr_utility.trace('SUMMARY OF PAYMENTS : start ');

    -- SUMMARY OF PAYMENTS
    l_total_pay := l_total_earnings - l_total_deductions ;
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('CS', NULL, 'SUMMARY OF PAYMENTS', NULL);
    --
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_EARNINGS', fnd_number.canonical_to_number(l_total_earnings) );
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_DEDUCTIONS', fnd_number.canonical_to_number(l_total_deductions) );
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('D', NULL, 'TOTAL_PAY', fnd_number.canonical_to_number(l_total_pay) );
    --
    pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
        load_xml('CE', NULL, 'SUMMARY OF PAYMENTS', NULL);
    --

   hr_utility.trace('SUMMARY OF PAYMENTS : end ');

   hr_utility.trace('BALANCE DETAILS : start ');

   fnd_file.put_line(fnd_file.log,'This is the tested case1');

    -- BALANCE DETAILS
    --
    l_cntr_sql      := 1;

    -- new
    build_sql(sqlstr, l_cntr_sql, ' Begin FOR run_types_rec IN pay_dk_rules.csr_run_types ('||p_assignment_action_id||') LOOP ');
	build_sql(sqlstr, l_cntr_sql, ' FOR csr_balance_info_rec IN pay_dk_rules.csr_balance_info (run_types_rec.assignment_action_id,''EMEA BALANCE DEFINITION'',''EMEA BALANCES'') LOOP ');
    -- end new
    -- build_sql(sqlstr, l_cntr_sql, ' Begin FOR csr_balance_info_rec IN pay_dk_rules.csr_balance_info ('||p_assignment_action_id||',''EMEA BALANCE DEFINITION'',''EMEA BALANCES'') LOOP ');
    build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=  pay_dk_rules.load_xml(''CS'', NULL, ''BALANCE DETAILS'', NULL); ');
        FOR cntr in 1..30 LOOP

	    IF pay_dk_rules.flex_seg_enabled ('EMEA BALANCE DEFINITION', 'ACTION_INFORMATION'||cntr) THEN
                 build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
						pay_dk_rules.load_xml(''D'', ''EMEA BALANCE DEFINITION'', ''ACTION_INFORMATION'||cntr||''', csr_balance_info_rec.a'||cntr||'); ');
            END IF;

	    IF pay_dk_rules.flex_seg_enabled ('EMEA BALANCES', 'ACTION_INFORMATION'||cntr) THEN
                 build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=
						pay_dk_rules.load_xml(''D'', ''EMEA BALANCES'', ''ACTION_INFORMATION'||cntr||''', csr_balance_info_rec.aa'||cntr||'); ');
            END IF;

        END LOOP;
    build_sql(sqlstr, l_cntr_sql, ' pay_payroll_xml_extract_pkg.g_custom_xml(pay_payroll_xml_extract_pkg.g_custom_xml.count()+1) :=  pay_dk_rules.load_xml(''CE'', NULL, ''BALANCE DETAILS'', NULL); ');
    -- new
    build_sql(sqlstr, l_cntr_sql, ' END LOOP;  ');
    -- end new
    build_sql(sqlstr, l_cntr_sql, ' END LOOP; End; ');
    --
    csr := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE(csr
                  ,sqlstr
                  ,sqlstr.first()
                  ,sqlstr.last()
                  ,FALSE
                  ,DBMS_SQL.V7);
    ret := DBMS_SQL.EXECUTE(csr);
    DBMS_SQL.CLOSE_CURSOR(csr);

    hr_utility.trace('BALANCE DETAILS : end ');
--
end if;
    --hr_utility.trace_off();

hr_utility.trace('Leaving Pay_DK_RULES.add_custom_xml');

Exception
when others then
    hr_utility.trace('DK error message :'||sqlerrm);
    Null ;

END add_custom_xml;

-----

-- Added functions for Batch Printing of Payslips

--------------------------------------------------------------------------
-- Returns any of the values from SEGMENT1, SEGMENT2, .. ,SEGMENT30
--------------------------------------------------------------------------
FUNCTION get_payslip_sort_order1 RETURN VARCHAR2 IS
BEGIN
--
    RETURN 'SEGMENT2';
--
END get_payslip_sort_order1;


--------------------------------------------------------------------------
-- Returns any of the values ORGANIZATION_ID or ASSIGNMENT_NUMBER
--------------------------------------------------------------------------
FUNCTION get_payslip_sort_order2 RETURN VARCHAR2 IS
BEGIN
--
    RETURN 'ORGANIZATION_ID';
--
END get_payslip_sort_order2;


--------------------------------------------------------------------------
-- get_payslip_sort_order3
-- Returns any of the values LAST_NAME, FIRST_NAME or FULL_NAME
--------------------------------------------------------------------------
FUNCTION get_payslip_sort_order3 RETURN VARCHAR2 IS
BEGIN
--
    RETURN 'LAST_NAME';
--
END get_payslip_sort_order3;


END PAY_DK_RULES;

/
