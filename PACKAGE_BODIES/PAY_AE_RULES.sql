--------------------------------------------------------
--  DDL for Package Body PAY_AE_RULES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AE_RULES" AS
/* $Header: pyaerule.pkb 120.1.12010000.3 2010/04/01 07:27:34 bkeshary ship $ */

       g_custom_context    pay_action_information.action_information_category%type;
       g_action_ctx_id  NUMBER;

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

PROCEDURE LOAD_XML (
    P_NODE_TYPE     varchar2,
    P_CONTEXT_CODE  varchar2,
    P_NODE          varchar2,
    P_DATA          varchar2
) AS

    CURSOR csr_get_tag_name IS
        SELECT TRANSLATE (UPPER(end_user_column_name), ' /','__') tag_name
          FROM fnd_descr_flex_col_usage_vl
         WHERE descriptive_flexfield_name = 'Action Information DF'
           AND descriptive_flex_context_code = p_context_code
           AND application_column_name = UPPER (p_node);

    CURSOR csr_get_chk_no IS
        SELECT paa_chk.serial_number
          FROM pay_assignment_actions paa_xfr,
               pay_action_interlocks pai_xfr,
               pay_action_interlocks pai_chk,
               pay_assignment_actions paa_chk,
               pay_payroll_actions ppa_chk
         WHERE paa_xfr.assignment_action_id = pai_xfr.locking_action_id
           AND pai_xfr.locked_action_id = pai_chk.locked_action_id
           AND pai_chk.locking_action_id = paa_chk.assignment_action_id
           AND paa_chk.payroll_action_id = ppa_chk.payroll_action_id
           AND ppa_chk.action_type = 'H'
           AND paa_xfr.assignment_action_id = g_action_ctx_id;

    l_tag_name  varchar2(500);
    l_chk_no    pay_assignment_actions.serial_number%type;
    l_data      pay_action_information.action_information1%type;

PROCEDURE LOAD_XML_INTERNAL (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS

    l_data      pay_action_information.action_information1%type;

BEGIN

IF p_node_type = 'CS' THEN

	pay_payroll_xml_extract_pkg.g_custom_xml (pay_payroll_xml_extract_pkg.g_custom_xml.count() + 1) := '<'||p_node||'>';

ELSIF p_node_type = 'CE' THEN

	pay_payroll_xml_extract_pkg.g_custom_xml (pay_payroll_xml_extract_pkg.g_custom_xml.count() + 1) := '</'||p_node||'>';

ELSIF p_node_type = 'D' THEN

	/* Handle special charaters in data */
	l_data := REPLACE (p_data, '&', '&amp;');
	l_data := REPLACE (l_data, '>', '&gt;');
	l_data := REPLACE (l_data, '<', '&lt;');
	l_data := REPLACE (l_data, '''', '&apos;');
	l_data := REPLACE (l_data, '"', '&quot;');
	pay_payroll_xml_extract_pkg.g_custom_xml (pay_payroll_xml_extract_pkg.g_custom_xml.count() + 1) := '<'||p_node||'>'||l_data||'</'||p_node||'>';
END IF;
END LOAD_XML_INTERNAL;


BEGIN

    IF p_node_type = 'D' THEN

        /* Fetch segment names */
        OPEN csr_get_tag_name;
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;

	/* Fetch cheque number */
        IF p_context_code = 'EMPLOYEE NET PAY DISTRIBUTION' AND
           l_tag_name = 'CHECK_DEPOSIT_NUMBER' THEN
            OPEN csr_get_chk_no;
                FETCH csr_get_chk_no INTO l_chk_no;
            CLOSE csr_get_chk_no;
        END IF;

    END IF;

    IF UPPER(p_node) NOT LIKE '?XML%' AND UPPER(p_node) NOT LIKE 'XAPI%' THEN
        l_tag_name := nvl(l_tag_name, TRANSLATE(p_node, ' /', '__'));
        IF p_node_type IN ('CS', 'CE') THEN
            l_tag_name := nvl(g_custom_context, TRANSLATE(p_node, ' /', '__'));
        END IF;
    ELSE
        l_tag_name := p_node;
    END IF;

    l_data := nvl(l_chk_no, p_data);
    load_xml_internal (p_node_type, l_tag_name, l_data);
END LOAD_XML;


 PROCEDURE add_custom_xml
       (p_assignment_action_id number,
        p_action_information_category varchar2,
        p_document_type varchar2) as

/* Cursor to fetch Payroll Processing Information */
CURSOR csr_payroll_info(p_action_context_id    NUMBER) IS
SELECT ppf.payroll_name	   payroll_name
      ,ptp.period_name     period_name
      ,ptp.period_type     period_type
      ,ptp.start_date      start_date
      ,ptp.end_date	   end_date
      ,pai.effective_date  payment_date
FROM   per_time_periods ptp
      ,pay_payrolls_f   ppf
      ,pay_action_information pai
WHERE ppf.payroll_id = ptp.payroll_id
AND pai.effective_date BETWEEN ppf.effective_start_date AND ppf.effective_end_date
AND ptp.time_period_id = pai.action_information16
AND pai.action_context_type  = 'AAP'
AND pai.action_information_category  = 'EMPLOYEE DETAILS'
AND (pai.action_context_id    =  p_action_context_id
     OR pai.action_context_id = ( SELECT paa.source_action_id
                                  FROM   pay_assignment_actions paa
                                  WHERE  paa.assignment_action_id =  p_action_context_id
                                 -- AND    paa.assignment_id  =  pai.assignment_id
                                ));

/* Cursor to fetch Element Details */
CURSOR csr_element_info(p_action_context_id   NUMBER) IS
SELECT pai.action_information2 element_type_id
      ,pai.action_information3 input_value_id
      ,decode(pai1.action_information8,NULL,pai.action_information4,
      pai.action_information4||'('||pai1.action_information8||')') Name
      ,pai.action_information5 type
      ,pai.action_information6 uom
      ,sum(pai1.action_information4) value
FROM pay_action_information pai
    ,pay_action_information pai1
    ,pay_assignment_actions paa
WHERE pai.action_context_type = 'PA'
AND pai.action_information_category = 'EMEA ELEMENT DEFINITION'
AND pai1.action_context_type = 'AAP'
AND pai.action_information5 <> 'F'
AND pai1.action_information3 <> 'F'
/*AND ( pai1.action_context_id  IN ( SELECT paa.assignment_action_id
				   FROM pay_assignment_actions paa
				   WHERE paa.source_action_id = p_action_context_id
				   AND paa.assignment_id 	  = pai1.assignment_id)
			      OR pai1.action_context_id = 	p_action_context_id)*/
and pai1.action_information_category = 'EMEA ELEMENT INFO'
and pai.action_information2 = pai1.action_information1
and pai.action_information3 = pai1.action_information2
and pai.action_context_id    = paa.payroll_action_id
and pai1.action_context_id   = paa.assignment_action_id
and paa.assignment_action_id = p_action_context_id
group by pai.action_information2
        ,pai.action_information3
	,pai.action_information4
	,pai.action_information5
	,pai.action_information6
	,pai1.action_information8
ORDER BY pai.action_information5,pai1.action_information8 DESC;

/* Cursor to fetch Additional Information Elements Details */
CURSOR csr_add_element_info(p_action_context_id   NUMBER) IS
SELECT pai.action_information2 element_type_id
      ,pai.action_information3 input_value_id
      ,decode(pai1.action_information8,NULL,pai.action_information4,
      pai.action_information4||'('||pai1.action_information8||')') Name
      ,pai.action_information5 type
      ,pai.action_information6 uom
      ,pai1.action_information4 value
FROM pay_action_information pai
    ,pay_action_information pai1
    ,pay_assignment_actions paa
WHERE pai.action_context_type = 'PA'
AND pai.action_information_category = 'EMEA ELEMENT DEFINITION'
AND pai1.action_context_type = 'AAP'
AND pai.action_information5 = 'F'
AND pai1.action_information3 = 'F'
/*AND ( pai1.action_context_id  IN ( SELECT paa.assignment_action_id
				   FROM pay_assignment_actions paa
				   WHERE paa.source_action_id = p_action_context_id
				   AND paa.assignment_id 	  = pai1.assignment_id)
		 OR pai1.action_context_id = 	p_action_context_id)*/
AND pai1.action_information_category = 'EMEA ELEMENT INFO'
AND pai.action_information2 = pai1.action_information1
AND pai.action_information3 = pai1.action_information2
AND pai.action_context_id    = paa.payroll_action_id
AND pai1.action_context_id   = paa.assignment_action_id
AND paa.assignment_action_id = p_action_context_id
/* Commented for Bug 9525527 */
/* GROUP BY pai.action_information2
	,pai.action_information3
	,pai.action_information4
	,pai.action_information5
	,pai.action_information6
	,pai1.action_information4
	,pai1.action_information8 */
ORDER BY pai.action_information4,pai.action_information5,pai1.action_information8 DESC;

/* Cursor to fetch input value's name */
CURSOR csr_get_input_value (p_input_value_id NUMBER) IS
SELECT name
FROM pay_input_values_f
WHERE input_value_id = p_input_value_id;

/* Cursor to fetch Balance Details */
CURSOR csr_balance_info(p_action_context_id   NUMBER) IS
SELECT pai.action_information4 Name
      ,pai.action_information2 defined_balance_id
      ,pai.action_information6 type
      ,pai1.action_information4 value
      ,pai1.action_information6 uom
FROM pay_action_information pai
    ,pay_action_information pai1
    ,pay_assignment_actions paa
WHERE pai.action_context_type       = 'PA'
AND pai.action_information_category = 'EMEA BALANCE DEFINITION'
AND pai1.action_context_type        = 'AAP'
AND pai1.action_information_category = 'EMEA BALANCES'
AND pai.action_information6 = 'OBAL'
AND pai1.action_information2 = 'OBAL'
AND pai.action_information2          = pai1.action_information1
AND pai.action_context_id            = paa.payroll_action_id
AND pai1.action_context_id           = paa.assignment_action_id
AND paa.assignment_action_id  in
			(SELECT paa1.assignment_action_id
                        FROM pay_assignment_actions paa1
			WHERE paa1.source_action_id = p_action_context_id
			AND    paa1.action_status            = 'C'
			UNION
			SELECT p_action_context_id
			FROM dual )
ORDER BY pai.action_information5,pai1.action_information5 DESC;


l_xml            CLOB;
cntr_flex_col    NUMBER;
l_flex_col_num   NUMBER;
sqlstr           DBMS_SQL.VARCHAR2S;
csr              NUMBER;
ret              NUMBER;
l_cntr_sql       NUMBER;
l_total_pay      NUMBER;
l_total_earnings   NUMBER;
l_total_deductions NUMBER;
l_input_value    VARCHAR2(100);


PROCEDURE build_sql(p_sqlstr_tab    IN OUT NOCOPY DBMS_SQL.VARCHAR2S,
                    p_cntr          IN OUT NOCOPY NUMBER,
                    p_string        VARCHAR2) AS
    --
    l_proc_name varchar2(100);
    --
BEGIN
    p_sqlstr_tab(p_cntr) := p_string;
    p_cntr               := p_cntr + 1;
END;

   BEGIN
	l_flex_col_num := 30;

	IF   p_action_information_category IS NULL AND p_document_type ='PAYSLIP' THEN

		l_total_earnings:=0 ;
		l_total_deductions :=0;
		g_action_ctx_id     := p_assignment_action_id ;

		FOR payroll_info_rec IN csr_payroll_info (p_assignment_action_id)
			LOOP

  				load_xml('CS', NULL, 'PAYROLL PROCESSING INFORMATION', NULL);
				load_xml('D', NULL, 'PAYROLL_NAME', payroll_info_rec.payroll_name );
				load_xml('D', NULL, 'PERIOD_NAME', payroll_info_rec.period_name);
				load_xml('D', NULL, 'PERIOD_TYPE', payroll_info_rec.period_type);
				load_xml('D', NULL, 'START_DATE', payroll_info_rec.start_date);
				load_xml('D', NULL, 'END_DATE', payroll_info_rec.end_date);
				load_xml('D', NULL, 'PAYMENT_DATE', payroll_info_rec.payment_date);
				load_xml('CE', NULL, 'PAYROLL PROCESSING INFORMATION', NULL);

			END LOOP;
    --
  		FOR element_info_rec IN csr_element_info(p_assignment_action_id)
			LOOP

				load_xml('CS', NULL, 'ELEMENT DETAILS', NULL);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION2', element_info_rec.element_type_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION3', element_info_rec.input_value_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION4', element_info_rec.Name);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION5', element_info_rec.type);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION6', element_info_rec.uom);
				load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4', fnd_number.canonical_to_number(element_info_rec.value));
				load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);

				       IF element_info_rec.type = 'E' THEN
					       l_total_earnings := fnd_number.canonical_to_number(l_total_earnings) + fnd_number.canonical_to_number(nvl(element_info_rec.value,0)) ;
				       ELSIF element_info_rec.type = 'D' THEN
					       l_total_deductions := fnd_number.canonical_to_number(l_total_deductions) + fnd_number.canonical_to_number(nvl(element_info_rec.value,0)) ;
				       END IF ;
					l_total_pay := l_total_earnings - l_total_deductions ;

			END LOOP;

		FOR add_element_info_rec IN csr_add_element_info(p_assignment_action_id)
			LOOP

			OPEN csr_get_input_value(add_element_info_rec.input_value_id);
				FETCH csr_get_input_value INTO l_input_value;
			CLOSE csr_get_input_value;

				load_xml('CS', NULL, 'ELEMENT DETAILS', NULL);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION2', add_element_info_rec.element_type_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION3', add_element_info_rec.input_value_id);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION4', add_element_info_rec.Name);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION5', add_element_info_rec.type);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION6', add_element_info_rec.uom);
				load_xml('D', 'EMEA ELEMENT DEFINITION', 'ACTION_INFORMATION7', l_input_value);
				/* Bug 9242951 */
				IF add_element_info_rec.uom in ('N','M') THEN
				  load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4', fnd_number.canonical_to_number(add_element_info_rec.value));
				ELSE
				  load_xml('D', 'EMEA ELEMENT INFO', 'ACTION_INFORMATION4',add_element_info_rec.value);
				END IF;
				load_xml('CE', NULL, 'ELEMENT DETAILS', NULL);

			END LOOP;


		FOR balance_info_rec IN csr_balance_info(p_assignment_action_id)
			LOOP

				load_xml('CS', NULL, 'BALANCE DETAILS', NULL);
				load_xml('D', 'EMEA BALANCE DEFINITION', 'ACTION_INFORMATION2', balance_info_rec.defined_balance_id);
				load_xml('D', 'EMEA BALANCE DEFINITION', 'ACTION_INFORMATION4', balance_info_rec.Name);
				load_xml('D', 'EMEA BALANCE DEFINITION', 'ACTION_INFORMATION6', balance_info_rec.type);
				load_xml('D', 'EMEA BALANCES', 'ACTION_INFORMATION4', fnd_number.canonical_to_number(balance_info_rec.value));
				load_xml('D', 'EMEA BALANCES', 'ACTION_INFORMATION6', balance_info_rec.uom);
				load_xml('CE', NULL, 'BALANCE DETAILS', NULL);

			END LOOP;

			load_xml('CS', NULL, 'SUMMARY OF PAYMENTS', NULL);
                        load_xml('D', NULL, 'TOTAL_EARNINGS', l_total_earnings);
                        load_xml('D', NULL, 'TOTAL_DEDUCTIONS', l_total_deductions);
                        load_xml('D', NULL, 'TOTAL_PAY', l_total_pay);
			load_xml('CE', NULL, 'SUMMARY OF PAYMENTS', NULL);




	END IF;

   END;

  PROCEDURE element_template_post_process
    (p_template_id       IN NUMBER) AS
  BEGIN

   hr_utility.set_location('Entering: post process',  10);
    pay_ae_element_template_pkg.element_template_post_process(p_template_id);
   hr_utility.set_location('Leaving: post process',  20);
  END element_template_post_process;

END PAY_AE_RULES;

/
