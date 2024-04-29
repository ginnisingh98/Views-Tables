--------------------------------------------------------
--  DDL for Package Body PAY_NO_ARC_RSEA_07
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_ARC_RSEA_07" AS
/* $Header: pynorse7.pkb 120.1 2007/08/20 09:23:18 kseth noship $ */
 --
 -- -----------------------------------------------------------------------------
 -- Data types.
 -- -----------------------------------------------------------------------------
 TYPE t_xml_element_rec IS RECORD
  (tagname  VARCHAR2(100)
  ,tagvalue VARCHAR2(500)
  ,tagtype  VARCHAR2(1)
  ,tagattrb VARCHAR2(100));
 --
 TYPE t_xml_element_table IS TABLE OF t_xml_element_rec INDEX BY BINARY_INTEGER;
 --
 -- -----------------------------------------------------------------------------
 -- Global variables.
 -- -----------------------------------------------------------------------------
 --
 g_xml_element_table     t_xml_element_table;
 g_debug   boolean   :=  hr_utility.debug_enabled;
 g_package           VARCHAR2(33) := ' PAY_NO_ARC_RSEA_07.';
 g_err_num NUMBER;
 g_errm VARCHAR2(150);
 --
 -- -----------------------------------------------------------------------------
 -- Get the correct characterset for XML generation
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_IANA_charset RETURN VARCHAR2 IS
   CURSOR csr_get_iana_charset IS
     SELECT tag
       FROM fnd_lookup_values
      WHERE lookup_type = 'FND_ISO_CHARACTER_SET_MAP'
        AND lookup_code = SUBSTR(USERENV('LANGUAGE'),
                                    INSTR(USERENV('LANGUAGE'), '.') + 1)
        AND language = 'US';
 --
  lv_iana_charset fnd_lookup_values.tag%type;
 BEGIN
   OPEN csr_get_iana_charset;
     FETCH csr_get_iana_charset INTO lv_iana_charset;
   CLOSE csr_get_iana_charset;
   RETURN (lv_iana_charset);
 END get_IANA_charset;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Takes XML element from a table and puts them into a CLOB.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE write_to_clob
 (p_clob OUT NOCOPY CLOB) IS
  --
  l_xml_element_template0 VARCHAR2(20) := '<TAG>VALUE</TAG>';
  l_xml_element_template1 VARCHAR2(30) := '<TAG><![CDATA[VALUE]]></TAG>';
  l_xml_element_template2 VARCHAR2(10) := '<TAG>';
  l_xml_element_template3 VARCHAR2(10) := '</TAG>';
  l_str1                  VARCHAR2(80) ;
  l_xml_element           VARCHAR2(800);
  l_clob                  CLOB;
  --
 BEGIN
  --
--  l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT> <EOY>';
  l_str1 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?>';

  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);
  dbms_lob.open(l_clob, DBMS_LOB.LOB_READWRITE);
  --
  dbms_lob.writeappend(l_clob, LENGTH(l_str1), l_str1);
  --
  IF g_xml_element_table.COUNT > 0 THEN
  --
   FOR table_counter IN g_xml_element_table.FIRST .. g_xml_element_table.LAST LOOP
   --
    IF g_xml_element_table(table_counter).tagvalue = '_START_' THEN
     l_xml_element := '<' || g_xml_element_table(table_counter).tagname || '>';
    ELSIF g_xml_element_table(table_counter).tagvalue = '_END_' THEN
     l_xml_element := '</' || g_xml_element_table(table_counter).tagname || '>';
    ELSIF g_xml_element_table(table_counter).tagtype IS NULL THEN
     --
     IF g_xml_element_table(table_counter).tagvalue IS NULL THEN
     --
       l_xml_element := '<' || g_xml_element_table(table_counter).tagname || '/>';
     ELSE
       l_xml_element := '<' || g_xml_element_table(table_counter).tagname ||
                      '><![CDATA[' || g_xml_element_table(table_counter).tagvalue ||
                      ']]></' || g_xml_element_table(table_counter).tagname || '>';
     END IF;
    ELSIF g_xml_element_table(table_counter).tagtype = 'A' THEN
     l_xml_element := '<' || g_xml_element_table(table_counter).tagname ||
                      '>' || g_xml_element_table(table_counter).tagvalue ||
                      '</' || g_xml_element_table(table_counter).tagname || '>';
    END IF;
    --
    dbms_lob.writeappend(l_clob, LENGTH(l_xml_element), l_xml_element);
   --
   END LOOP;
  --
  END IF;
  --
  p_clob := l_clob;
  --
  EXCEPTION
   WHEN OTHERS THEN
     --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
     hr_utility.set_location(sqlerrm(sqlcode),110);
  --
 END write_to_clob;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Takes XML element from a table and puts them into a CLOB.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE write_to_clob_for_xml
 (p_clob OUT NOCOPY CLOB) IS
  --
  l_str1                  VARCHAR2(80) ;
  l_xml_element           VARCHAR2(800);
  l_clob                  CLOB;
  EOL                     VARCHAR2(5);
  --
 BEGIN
  --
  SELECT
  fnd_global.local_chr(13) || fnd_global.local_chr(10)
  INTO EOL
  FROM dual;
  --
--  l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT> <EOY>';
  l_str1 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?>';

  dbms_lob.createtemporary(l_clob, FALSE, DBMS_LOB.CALL);
  dbms_lob.open(l_clob, DBMS_LOB.LOB_READWRITE);
  --
  dbms_lob.writeappend(l_clob, LENGTH(l_str1), l_str1);
  --
  IF g_xml_element_table.COUNT > 0 THEN
  --
   FOR table_counter IN g_xml_element_table.FIRST .. g_xml_element_table.LAST LOOP
   --
    IF g_xml_element_table(table_counter).tagvalue = '_START_' THEN
     l_xml_element := '<' || g_xml_element_table(table_counter).tagname ||
                      ' ' || g_xml_element_table(table_counter).tagattrb || '>' || EOL;
    ELSIF g_xml_element_table(table_counter).tagvalue = '_END_' THEN
     l_xml_element := '</' || g_xml_element_table(table_counter).tagname || '>' || EOL;
    ELSIF g_xml_element_table(table_counter).tagattrb IS NOT NULL THEN
     l_xml_element := '<' || g_xml_element_table(table_counter).tagname  || ' '
                          || g_xml_element_table(table_counter).tagattrb || '>'
                          || g_xml_element_table(table_counter).tagvalue ||
                      '</' || g_xml_element_table(table_counter).tagname || '>' || EOL;
    END IF;
    --
    dbms_lob.writeappend(l_clob, LENGTH(l_xml_element), l_xml_element);
   --
   END LOOP;
  --
  END IF;
  --
  p_clob := l_clob;
  --
  EXCEPTION
   WHEN OTHERS THEN
     --Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
     hr_utility.set_location(sqlerrm(sqlcode),110);
  --
 END write_to_clob_for_xml;
--
-- -----------------------------------------------------------------------------
-- Function to get defined balance id
-- -----------------------------------------------------------------------------
--
FUNCTION get_defined_balance_id
          (p_balance_name  IN  VARCHAR2
          ,p_dbi_suffix    IN  VARCHAR2 ) RETURN NUMBER IS
    --
    l_defined_balance_id 		NUMBER;
    --
BEGIN
    --
    SELECT pdb.defined_balance_id
    INTO   l_defined_balance_id
    FROM   pay_defined_balances      pdb
          ,pay_balance_types         pbt
          ,pay_balance_dimensions    pbd
    WHERE  pbd.database_item_suffix = p_dbi_suffix
    AND    pbd.legislation_code = 'NO'
    AND    pbt.balance_name = p_balance_name
    AND    pbt.legislation_code = 'NO'
    AND    pdb.balance_type_id = pbt.balance_type_id
    AND    pdb.balance_dimension_id = pbd.balance_dimension_id
    AND    pdb.legislation_code = 'NO';
    --
    l_defined_balance_id := NVL(l_defined_balance_id,0);
    RETURN l_defined_balance_id ;
    --
  EXCEPTION
   WHEN OTHERS THEN
     Return 0;
	END get_defined_balance_id ;
--
-- -----------------------------------------------------------------------------
-- GET PARAMETER
-- -----------------------------------------------------------------------------
--
FUNCTION GET_PARAMETER(
		 p_parameter_string IN VARCHAR2
		,p_token            IN VARCHAR2
		,p_segment_number   IN NUMBER default NULL ) RETURN VARCHAR2
	 IS
   l_parameter  pay_payroll_actions.legislative_parameters%TYPE:=NULL;
   l_start_pos  NUMBER;
   l_delimiter  VARCHAR2(1):=' ';
   l_proc VARCHAR2(40):= g_package||' get parameter ';
 BEGIN
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
 --
 IF l_start_pos <> 0 THEN
    l_start_pos := l_start_pos + length(p_token||'=');
    l_parameter := substr(p_parameter_string, l_start_pos,
     instr(p_parameter_string||' ',l_delimiter,l_start_pos) - l_start_pos);
   IF p_segment_number IS NOT NULL THEN
     l_parameter := ':'||l_parameter||':';
     l_parameter := substr(l_parameter, instr(l_parameter,':',1,p_segment_number)+1,
     instr(l_parameter,':',1,p_segment_number+1) -1 - instr(l_parameter,':',1,p_segment_number));
   END IF;
 END IF;
 --
 IF g_debug THEN
   hr_utility.set_location(' Leaving Function GET_PARAMETER',20);
 END IF;
  RETURN l_parameter;
END;
--
-- -----------------------------------------------------------------------------
-- GET ALL PARAMETERS
-- -----------------------------------------------------------------------------
--
PROCEDURE GET_ALL_PARAMETERS(p_payroll_action_id  IN   NUMBER
                            ,p_business_group_id  OUT  NOCOPY NUMBER
                            ,p_legal_employer_id  OUT  NOCOPY NUMBER
                            ,p_local_unit_id      OUT  NOCOPY NUMBER
                            ,p_effective_date     OUT  NOCOPY DATE
                            ,p_archive            OUT  NOCOPY VARCHAR2
                            ) IS

 CURSOR csr_parameter_info(p_payroll_action_id NUMBER) IS
 SELECT PAY_NO_ARC_RSEA_07.GET_PARAMETER(legislative_parameters,'LEGAL_EMPLOYER_NAME')
       ,PAY_NO_ARC_RSEA_07.GET_PARAMETER(legislative_parameters,'LOCAL_UNIT_NAME')
       ,PAY_NO_ARC_RSEA_07.GET_PARAMETER(legislative_parameters,'ARCHIVE')
       ,effective_date
       ,business_group_id
  FROM  pay_payroll_actions
  WHERE payroll_action_id = p_payroll_action_id;
  --
  l_proc VARCHAR2(240):= g_package||' GET_ALL_PARAMETERS ';
  --
 BEGIN
  --
 OPEN csr_parameter_info (p_payroll_action_id);
 FETCH csr_parameter_info
 INTO	p_legal_employer_id
       ,p_local_unit_id
       ,p_archive
       ,p_effective_date
       ,p_business_group_id;
 CLOSE csr_parameter_info;
 --
 IF g_debug THEN
   hr_utility.set_location(' Leaving Procedure GET_ALL_PARAMETERS',30);
 END IF;
END GET_ALL_PARAMETERS;
--
-- -----------------------------------------------------------------------------
-- RANGE CODE
-- -----------------------------------------------------------------------------
--
PROCEDURE RANGE_CODE(p_payroll_action_id IN           NUMBER
                    ,p_sql               OUT   NOCOPY VARCHAR2)
IS
l_action_info_id NUMBER;
l_ovn NUMBER;
l_defined_balance_id NUMBER := 0;
l_count NUMBER := 0;
l_business_group_id    NUMBER;
l_period               VARCHAR2(2);
l_year                 VARCHAR2(4);
l_effective_date       DATE;
l_legal_employer_id    NUMBER ;
l_local_unit_id        NUMBER ;
l_archive              VARCHAR2(3);
l_el                   NUMBER;
l_el_b                 NUMBER;
l_el_a                 NUMBER;
l_reporting_start_date DATE;
l_reporting_end_date   DATE;
l_municipal_name       VARCHAR2(30);
l_zone                 NUMBER;

l_municipal_no	    hr_organization_information.org_information1%TYPE ;
l_industry_status   hr_organization_information.org_information1%TYPE ;
l_nace_code         hr_organization_information.org_information1%TYPE ;
l_lu_name           hr_organization_units.name%TYPE ;
l_Witholding_Tax NUMBER;
l_sum_tax_value  NUMBER;
l_tax_value      NUMBER;
l_def_bal_id     NUMBER;
l_fe_fm_amount   NUMBER;
--
l_base_base  NUMBER;
l_base_amt   NUMBER;
l_reimb_base NUMBER;
l_reimb_amt  NUMBER;
l_utl1_base  NUMBER;
l_utl1_amt   NUMBER;
l_utr1_base  NUMBER;
l_utr1_amt   NUMBER;
l_utl2_base  NUMBER;
l_utl2_amt   NUMBER;
l_pension_base NUMBER;
--
TYPE municipaldata   IS RECORD(municipalcode VARCHAR2(10));
TYPE tmunicipaldata  IS TABLE OF municipaldata INDEX BY BINARY_INTEGER;
--
gmunicipaldata tmunicipaldata ;
--
l_counter NUMBER;
l_status NUMBER;
--
   Cursor csr_LU_Details (csr_v_local_unit_id  hr_organization_information.organization_id%TYPE)	IS
    SELECT o1.name                lu_name
          ,hoi2.org_information4  industry_status
          ,hoi2.org_information2  nace_code
          ,hoi2.org_information1  org_num
          ,hoi2.org_information6  municipal_no
      FROM hr_organization_units o1
          ,hr_organization_information hoi1
          ,hr_organization_information hoi2
    WHERE o1.business_group_id         = l_business_group_id
      AND hoi1.organization_id         = o1.organization_id
      AND hoi1.organization_id         = csr_v_local_unit_id
      AND hoi1.org_information1        = 'NO_LOCAL_UNIT'
      AND hoi1.org_information_context = 'CLASS'
      AND o1.organization_id           = hoi2.organization_id
      AND hoi2.org_information_context = 'NO_LOCAL_UNIT_DETAILS';
    --
    rg_LU_Details  csr_LU_Details%rowtype;
    --
   Cursor csr_LE_Details (csr_v_legal_emp_id  hr_organization_information.organization_id%TYPE) IS
    SELECT o1.name               le_name
          ,hoi2.org_information1 org_number
          ,hoi2.org_information2 municipal_no
          ,hoi2.org_information3 industry_status
          ,hoi2.org_information4 nace_code
      --  ,hoi2.org_information5 tax_off
      FROM hr_organization_units o1
          ,hr_organization_information hoi1
          ,hr_organization_information hoi2
    WHERE o1.business_group_id         = l_business_group_id
      AND hoi1.organization_id         = o1.organization_id
      AND hoi1.organization_id         = csr_v_legal_emp_id
      AND hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
      AND hoi1.org_information_context = 'CLASS'
      AND o1.organization_id           = hoi2.organization_id
      AND hoi2.org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS' ;
    --
    rg_LE_Details  csr_LE_Details%rowtype;
    --
  Cursor csr_LE_Contact ( csr_v_legal_emp_id  hr_organization_information.organization_id%TYPE) IS
    SELECT hoi2.org_information2 email
          ,hoi3.org_information2 phone
      FROM hr_organization_units o1
          ,hr_organization_information hoi1
          ,hr_organization_information hoi2
          ,hr_organization_information hoi3
   WHERE  o1.business_group_id           = l_business_group_id
      AND hoi1.organization_id            = o1.organization_id
      AND hoi1.organization_id            = csr_v_legal_emp_id
      AND hoi1.org_information1           = 'HR_LEGAL_EMPLOYER'
      AND hoi1.org_information_context    = 'CLASS'
      AND hoi2.organization_id (+)        = o1.organization_id
      AND hoi2.org_information_context(+) = 'ORG_CONTACT_DETAILS'
      AND hoi2.org_information1(+)        = 'EMAIL'
      AND hoi3.organization_id (+)        = o1.organization_id
      AND hoi3.org_information_context(+) = 'ORG_CONTACT_DETAILS'
      AND hoi3.org_information1(+)        = 'PHONE';
    --
    rg_LE_Contact  csr_LE_Contact%rowtype;
    --
   Cursor csr_LE_addr ( csr_v_legal_emp_id  hr_organization_information.organization_id%TYPE) IS
    SELECT hoi1.address_line_1 address_line_1
          ,hoi1.address_line_2 address_line_2
          ,hoi1.address_line_3 address_line_3
          ,hoi1.postal_code    postal_code
          ,SUBSTR(hlu.meaning, INSTR(hlu.meaning,' ', 1,1), LENGTH(hlu.meaning)-(INSTR(hlu.meaning,' ', 1,1)-1)) postal_office
      FROM hr_organization_units o1
          ,hr_locations          hoi1
          ,hr_organization_information hoi2
          ,hr_lookups            hlu
     WHERE o1.business_group_id  = l_business_group_id
       AND hoi1.location_id      = o1.location_id
       AND hoi2.organization_id  = o1.organization_id
       AND hoi2.organization_id  = csr_v_legal_emp_id
       AND hoi2.org_information1 = 'HR_LEGAL_EMPLOYER'
       AND hoi2.org_information_context = 'CLASS'
       AND hlu.lookup_type       = 'NO_POSTAL_CODE'
       AND hlu.enabled_flag      = 'Y'
       AND hlu.lookup_code       = hoi1.POSTAL_CODE;
    --
    rg_LE_addr  csr_LE_addr%rowtype;
    --
    CURSOR csr_prepaid_assignments_le(p_payroll_action_id NUMBER,
                                      p_legal_employer_id	NUMBER,
                                      l_start_date        DATE,
                                      l_end_date	        DATE) IS
    SELECT DISTINCT act.assignment_id assignment_id
    FROM   pay_payroll_actions    ppa
          ,pay_payroll_actions    appa
          ,pay_payroll_actions    appa2
          ,pay_assignment_actions act
          ,pay_assignment_actions act1
          ,pay_action_interlocks  pai
          ,per_all_assignments_f  as1
          ,hr_soft_coding_keyflex hsck
    WHERE  ppa.payroll_action_id      = p_payroll_action_id
     AND   appa.effective_date    BETWEEN l_start_date AND l_end_date
     AND   appa.action_type           IN ('R','Q')
     -- Payroll Run or Quickpay Run
     AND   act.payroll_action_id     = appa.payroll_action_id
     AND   act.source_action_id      IS NULL -- Master Action
     AND   as1.assignment_id         = act.assignment_id
     AND   ppa.effective_date    BETWEEN as1.effective_start_date AND     as1.effective_end_date
     AND   act.action_status         = 'C'  -- Completed
     AND   act.assignment_action_id  = pai.locked_action_id
     AND   act1.assignment_action_id = pai.locking_action_id
     AND   act1.action_status        = 'C' -- Completed
     AND   act1.payroll_action_id    = appa2.payroll_action_id
     AND   appa2.action_type         IN ('P','U')
     AND   appa2.effective_date  BETWEEN l_start_date AND l_end_date
     -- Prepayments or Quickpay Prepayments
     AND   act.TAX_UNIT_ID             = act1.TAX_UNIT_ID
     AND   act.TAX_UNIT_ID             = p_legal_employer_id
     AND   hsck.SOFT_CODING_KEYFLEX_ID = as1.SOFT_CODING_KEYFLEX_ID
     AND   EXISTS (SELECT hoi1.organization_id
                     FROM hr_organization_units o1
                         ,hr_organization_information hoi1
                         ,hr_organization_information hoi2
                         ,hr_organization_information hoi3
                         ,hr_organization_information hoi4
                   WHERE  hoi1.organization_id = o1.organization_id
                      AND hoi1.org_information1 = 'NO_LOCAL_UNIT'
                      AND hoi1.org_information_context = 'CLASS'
                      AND o1.organization_id = hoi2.org_information1
                      AND hoi2.org_information_context ='NO_LOCAL_UNITS'
                      AND hoi2.organization_id =  hoi3.organization_id
                      AND hoi3.org_information_context ='CLASS'
                      AND hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
                      aND hoi3.organization_id = p_legal_employer_id
                      AND hoi1.organization_id =  hoi4.organization_id
                      AND hoi4.org_information_context ='NO_LOCAL_UNIT_DETAILS'
                      AND hoi4.org_information5 = 'N'
                      AND to_char(hoi1.organization_id) = hsck.segment2 );
    --
    CURSOR csr_prepaid_assignments_lu(p_payroll_action_id NUMBER
                                     ,p_legal_employer_id	NUMBER
                                     ,p_local_unit_id			NUMBER
                                     ,l_start_date	      DATE
                                     ,l_end_date	        DATE) IS
    SELECT DISTINCT act.assignment_id assignment_id
     FROM  pay_payroll_actions    ppa
          ,pay_payroll_actions    appa
          ,pay_payroll_actions    appa2
          ,pay_assignment_actions act
          ,pay_assignment_actions act1
          ,pay_action_interlocks  pai
          ,per_all_assignments_f  as1
          ,hr_soft_coding_keyflex hsck
    WHERE  ppa.payroll_action_id      = p_payroll_action_id
     AND   appa.effective_date     BETWEEN l_start_date AND l_end_date
     AND   appa.action_type          IN ('R','Q')
     -- Payroll Run or Quickpay Run
     AND   act.payroll_action_id     = appa.payroll_action_id
     AND   act.source_action_id      IS NULL -- Master Action
     AND   as1.assignment_id         = act.assignment_id
     AND   ppa.effective_date      BETWEEN as1.effective_start_date AND as1.effective_end_date
     AND   act.action_status   = 'C'  -- Completed
     AND   act.assignment_action_id  = pai.locked_action_id
     AND   act1.assignment_action_id = pai.locking_action_id
     AND   act1.action_status        = 'C' -- Completed
     AND   act1.payroll_action_id    = appa2.payroll_action_id
     AND   appa2.action_type         IN ('P','U')
     AND   appa2.effective_date    BETWEEN l_start_date AND l_end_date
     -- Prepayments or Quickpay Prepayments
     AND   hsck.soft_coding_keyflex_id = as1.soft_coding_keyflex_id
     AND   hsck.segment2              = to_char(p_local_unit_id)
     AND   act.TAX_UNIT_ID            = act1.TAX_UNIT_ID
     AND   act.TAX_UNIT_ID            = p_legal_employer_id ;
    --
    CURSOR csr_get_mun_num(p_assignment_id NUMBER
                          ,p_effective_date  DATE) IS
    SELECT eev1.screen_entry_value screen_entry_value
      FROM per_all_assignments_f      asg1
          ,per_all_assignments_f      asg2
          ,per_all_people_f           per
          ,pay_element_links_f        el
          ,pay_element_types_f        et
          ,pay_input_values_f         iv1
          ,pay_element_entries_f      ee
          ,pay_element_entry_values_f eev1
   WHERE  asg1.assignment_id    = p_assignment_id
     AND p_effective_date   BETWEEN asg1.effective_start_date AND asg1.effective_end_date
     AND p_effective_date   BETWEEN per.effective_start_date  AND per.effective_end_date
     AND p_effective_date   BETWEEN asg2.effective_start_date AND asg2.effective_end_date
     AND  per.person_id         = asg1.person_id
     AND  asg2.person_id        = per.person_id
     AND  asg2.primary_flag     = 'Y'
     AND  et.element_name       = 'Tax Card'
     AND  et.legislation_code   = 'NO'
     AND  iv1.element_type_id   = et.element_type_id
     AND  iv1.name              = 'Tax Municipality'
     AND  el.business_group_id  = per.business_group_id
     AND  el.element_type_id    = et.element_type_id
     AND  ee.assignment_id      = asg2.assignment_id
     AND  ee.element_link_id    = el.element_link_id
     AND  eev1.element_entry_id = ee.element_entry_id
     AND  eev1.input_value_id   = iv1.input_value_id
     AND  p_effective_date  BETWEEN ee.effective_start_date AND ee.effective_end_date
     AND  p_effective_date  BETWEEN eev1.effective_start_date AND eev1.effective_end_date;
    --
    CURSOR csr_get_mun_dtls(p_municipal_no VARCHAR2, l_effective_date  DATE) IS
    SELECT hr_de_general.get_uci(l_effective_date,t.user_table_id,r.user_row_id,'ZONE') zone
          ,hr_general.decode_lookup('NO_TAX_MUNICIPALITY',
           hr_de_general.get_uci(l_effective_date,t.user_table_id,r.user_row_id,'MAPPING_ID')) municipal_name
     FROM  pay_user_tables t
          ,pay_user_rows_f r
    WHERE  t.user_table_name        = 'NO_TAX_MUNICIPALITY'
      AND  t.legislation_code       = 'NO'
      AND  r.user_table_id          = t.user_table_id
      AND  r.row_low_range_or_name  = p_municipal_no
      AND  l_effective_date BETWEEN r.effective_start_date AND r.effective_end_date;
    --
    rg_get_mun_dtls  csr_get_mun_dtls%ROWTYPE;
    --
   CURSOR csr_lu_dtls(p_legal_employer_id  NUMBER)	IS
   SELECT hoi1.organization_id        lu_id
     FROM hr_organization_units       o1
          ,hr_organization_information hoi1
          ,hr_organization_information hoi2
          ,hr_organization_information hoi3
          ,hr_organization_information hoi4
     WHERE hoi1.organization_id         = o1.organization_id
       AND hoi1.org_information1        = 'NO_LOCAL_UNIT'
       AND hoi1.org_information_context = 'CLASS'
       AND o1.organization_id           = hoi2.org_information1
       AND hoi2.org_information_context ='NO_LOCAL_UNITS'
       AND hoi2.organization_id         = hoi3.organization_id
       AND hoi3.org_information_context = 'CLASS'
       AND hoi3.org_information1        = 'HR_LEGAL_EMPLOYER'
       AND hoi3.organization_id         = p_legal_employer_id
       AND hoi1.organization_id         = hoi4.organization_id
       AND hoi4.org_information_context = 'NO_LOCAL_UNIT_DETAILS'
       AND hoi4.org_information5        = 'N';
    --
  CURSOR csr_Local_Unit_EA(csr_v_local_unit_id  hr_organization_information.organization_id%TYPE
                          ,p_date_earned DATE) IS
  SELECT to_number(hoi2.org_information4)
    FROM hr_organization_units o1
        ,hr_organization_information hoi1
        ,hr_organization_information hoi2
  WHERE o1.business_group_id      = l_business_group_id
    AND hoi1.organization_id         = o1.organization_id
    AND hoi1.organization_id         = csr_v_local_unit_id
    AND hoi1.org_information1        = 'NO_LOCAL_UNIT'
    AND hoi1.org_information_context = 'CLASS'
    AND o1.organization_id           = hoi2.organization_id
    AND hoi2.org_information_context = 'NO_NI_EXEMPTION_LIMIT'
    AND p_date_earned     BETWEEN fnd_date.canonical_to_date(hoi2.org_information2)
                            AND fnd_date.canonical_to_date(hoi2.org_information3);
    --
 Cursor csr_Legal_Emp_EA(csr_v_legal_emp_id  hr_organization_information.organization_id%TYPE
                        ,p_date_earned DATE) IS
 SELECT to_number(hoi2.org_information4)
   FROM hr_organization_units o1
       ,hr_organization_information hoi1
       ,hr_organization_information hoi2
 WHERE o1.business_group_id         = l_business_group_id
   AND hoi1.organization_id         = o1.organization_id
   AND hoi1.organization_id         = csr_v_legal_emp_id
   AND hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
   AND hoi1.org_information_context = 'CLASS'
   AND o1.organization_id           = hoi2.organization_id
   AND hoi2.org_information_context ='NO_NI_EXEMPTION_LIMIT'
   AND p_date_earned     BETWEEN fnd_date.canonical_to_date(hoi2.org_information2)
                           AND fnd_date.canonical_to_date(hoi2.org_information3);
    --
   CURSOR csr_Local_Unit_EL(csr_v_local_unit_id  hr_organization_information.organization_id%TYPE
                           ,p_date_earned DATE) IS
    SELECT SUM(hoi2.org_information1) exempt_limit
          ,SUM(hoi2.org_information4) economic_aid
      FROM hr_organization_units o1
           ,hr_organization_information hoi1
           ,hr_organization_information hoi2
      WHERE o1.business_group_id      = l_business_group_id
        AND hoi1.organization_id         = o1.organization_id
        AND hoi1.organization_id         = csr_v_local_unit_id
	AND hoi1.org_information1        = 'NO_LOCAL_UNIT'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id           = hoi2.organization_id
	AND hoi2.org_information_context = 'NO_NI_EXEMPTION_LIMIT'
	AND trunc(p_date_earned,'Y')     >= fnd_date.canonical_to_date(hoi2.org_information2)
        AND trunc(add_months(p_date_earned,12),'Y')  < fnd_date.canonical_to_date(hoi2.org_information3);
    --
    rg_Local_Unit_EL  csr_Local_Unit_EL%ROWTYPE;
    --
    Cursor csr_Legal_Emp_EL(csr_v_legal_emp_id  hr_organization_information.organization_id%TYPE
                           ,p_date_earned DATE) IS
    SELECT SUM(hoi2.org_information1) exempt_limit
          ,SUM(hoi2.org_information4) economic_aid
      FROM hr_organization_units o1
          ,hr_organization_information hoi1
          ,hr_organization_information hoi2
    WHERE o1.business_group_id         = l_business_group_id
      AND hoi1.organization_id         = o1.organization_id
      AND hoi1.organization_id         = csr_v_legal_emp_id
      AND hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
      AND hoi1.org_information_context = 'CLASS'
      AND o1.organization_id           = hoi2.organization_id
      AND hoi2.org_information_context ='NO_NI_EXEMPTION_LIMIT'
      AND trunc(p_date_earned,'Y')     >= fnd_date.canonical_to_date(hoi2.org_information2)
      AND trunc(add_months(p_date_earned,12),'Y')  < fnd_date.canonical_to_date(hoi2.org_information3);
     --
     rg_Legal_Emp_EL  csr_Legal_Emp_EL%ROWTYPE;
     --
    CURSOR csr_Local_Unit_EL_after(csr_v_local_unit_id  hr_organization_information.organization_id%TYPE
                                  ,p_date_earned DATE) IS
    SELECT SUM(hoi2.org_information4) economic_aid
      FROM hr_organization_units o1
          ,hr_organization_information hoi1
          ,hr_organization_information hoi2
     WHERE o1.business_group_id      = l_business_group_id
       AND hoi1.organization_id         = o1.organization_id
       AND hoi1.organization_id         = csr_v_local_unit_id
       AND hoi1.org_information1        = 'NO_LOCAL_UNIT'
       AND hoi1.org_information_context = 'CLASS'
       AND o1.organization_id           = hoi2.organization_id
       AND hoi2.org_information_context = 'NO_NI_EXEMPTION_LIMIT'
       AND p_date_earned                > fnd_date.canonical_to_date(hoi2.org_information2)
       AND trunc(add_months(p_date_earned,12),'Y')  < fnd_date.canonical_to_date(hoi2.org_information3);
    --
    rg_Local_Unit_EL_after  csr_Local_Unit_EL_after%ROWTYPE;
    --
    Cursor csr_Legal_Emp_EL_after(csr_v_legal_emp_id  hr_organization_information.organization_id%TYPE
                                 ,p_date_earned DATE) IS
   SELECT SUM(hoi2.org_information4) economic_aid
     FROM hr_organization_units o1
         ,hr_organization_information hoi1
         ,hr_organization_information hoi2
    WHERE o1.business_group_id         = l_business_group_id
      AND hoi1.organization_id         = o1.organization_id
      AND hoi1.organization_id         = csr_v_legal_emp_id
      AND hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
      AND hoi1.org_information_context = 'CLASS'
      AND o1.organization_id           = hoi2.organization_id
      AND hoi2.org_information_context ='NO_NI_EXEMPTION_LIMIT'
      AND p_date_earned                > fnd_date.canonical_to_date(hoi2.org_information2)
      AND trunc(add_months(p_date_earned,12),'Y')  < fnd_date.canonical_to_date(hoi2.org_information3);
    --
    rg_Legal_Emp_EL_after  csr_Legal_Emp_EL_after%ROWTYPE;
    --
    CURSOR csr_global_value (p_global_name VARCHAR2 , p_date_earned DATE) IS
    SELECT global_value
      FROM ff_globals_f
     WHERE global_name = p_global_name
       AND p_date_earned BETWEEN effective_start_date AND effective_end_date;
    --
BEGIN
    --
    g_debug:=true;
    --
    IF g_debug THEN
		   hr_utility.set_location(' Entering Procedure RANGE_CODE',10);
    END IF;
    --
    p_sql :='SELECT DISTINCT person_id
              FROM  per_people_f ppf
                   ,pay_payroll_actions ppa
              WHERE ppa.payroll_action_id = :payroll_action_id
              AND   ppa.business_group_id = ppf.business_group_id
              ORDER BY ppf.person_id';
    --
    pay_no_arc_rsea_07.get_all_parameters(p_payroll_action_id
                                          ,l_business_group_id
                                          ,l_legal_employer_id
                                          ,l_local_unit_id
                                          ,l_effective_date
                                          ,l_archive);
    --
    l_period:= to_char(ceil(to_number(to_char(l_effective_date,'MM'))/ 2));
    l_year:=to_char(l_effective_date,'YYYY');
    l_reporting_end_date := LAST_DAY(TO_DATE(LPAD(l_period*2,2,'0')||l_year,'MMYYYY'));
    l_reporting_start_date :=ADD_MONTHS( l_reporting_end_date , -2 ) + 1;
    --
    IF l_archive = 'Y' THEN
      --
      SELECT count(*)  INTO l_count
      FROM  pay_action_information
     WHERE  action_context_id   = p_payroll_action_id
       AND  action_context_type = 'PA'
       AND  action_information_category = 'EMEA REPORT INFORMATION'
       AND  action_information1 = 'PYNORSEA';
      --
      IF l_count < 1  then
      /* Pick up the details belonging to Legal Employer */
        OPEN  csr_LE_Details(l_legal_employer_id);
        FETCH csr_LE_Details INTO rg_LE_Details;
        CLOSE csr_LE_Details;
        --
        l_industry_status:= rg_LE_Details.industry_status ;
        l_nace_code      := rg_LE_Details.nace_code ;
        --
	IF l_local_unit_id IS NOT NULL THEN
	/* Pick up the details belonging to Local Unit */
	  OPEN  csr_LU_Details( l_local_unit_id);
	  FETCH csr_LU_Details INTO rg_LU_Details;
	  CLOSE csr_LU_Details;
          --
          l_lu_name         := rg_LU_Details.lu_name;
          l_nace_code       := rg_LU_Details.nace_code;
  	  l_industry_status := rg_LU_Details.industry_status;
	--
        END IF ;
  	/* Pick up the contact details belonging to Legal Employer */
        OPEN  csr_LE_contact(l_legal_employer_id);
	FETCH csr_LE_contact INTO rg_LE_contact;
	CLOSE csr_LE_contact;
	/* Pick up the Address details belonging to  Legal Employer */
	OPEN  csr_LE_addr(l_legal_employer_id);
	FETCH csr_LE_addr INTO rg_LE_addr;
	CLOSE csr_LE_addr;
	--
  	pay_balance_pkg.set_context('TAX_UNIT_ID', l_legal_employer_id);
  	pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(l_reporting_end_date));
        --
	IF l_local_unit_id IS NOT NULL THEN
	  /* Pick up the Exemption Limit details belonging to  Local Unit*/
          pay_balance_pkg.set_context('LOCAL_UNIT_ID', l_local_unit_id);
          --
	  OPEN  csr_Local_Unit_EA(l_local_unit_id, l_reporting_end_date);
	  FETCH csr_Local_Unit_EA INTO l_el;
	  CLOSE csr_Local_Unit_EA;
          --
          OPEN  csr_Local_Unit_EL(l_local_unit_id, l_reporting_end_date);
	  FETCH csr_Local_Unit_EL INTO rg_Local_Unit_EL;
	  CLOSE csr_Local_Unit_EL;
          --
          l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used', '_TU_LU_YTD') ;
          l_el_a := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          l_el_a := nvl(rg_Local_Unit_EL.exempt_limit,0) - nvl(rg_Local_Unit_EL.economic_aid,0) - nvl(l_el_a,0);
          --
	  OPEN  csr_Local_Unit_EL_after( l_local_unit_id , l_reporting_end_date);
	  FETCH csr_Local_Unit_EL_after INTO rg_Local_Unit_EL_after;
	  CLOSE csr_Local_Unit_EL_after;
          --
          l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used', '_TU_LU_BIMONTH') ;
          l_el_b := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          l_el_b := l_el_a + nvl(l_el_b,0) + nvl(rg_Local_Unit_EL_after.economic_aid,0);
          --
        ELSE
	/* Pick up the Exemption Limit details belonging to  Employer*/
          OPEN  csr_Legal_Emp_EA( l_legal_employer_id , l_reporting_end_date);
	  FETCH csr_Legal_Emp_EA INTO l_el;
	  CLOSE csr_Legal_Emp_EA;
          --
          OPEN  csr_Legal_Emp_EL( l_legal_employer_id , l_reporting_end_date);
	  FETCH csr_Legal_Emp_EL INTO rg_Legal_Emp_EL;
	  CLOSE csr_Legal_Emp_EL;
          --
          l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used', '_TU_YTD') ;
          l_el_a := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          l_el_a := nvl(rg_Legal_Emp_EL.exempt_limit,0) - nvl(rg_Legal_Emp_EL.economic_aid,0) - nvl(l_el_a,0);
          --
	  OPEN  csr_Legal_Emp_EL_after( l_legal_employer_id , l_reporting_end_date);
	  FETCH csr_Legal_Emp_EL_after INTO rg_Legal_Emp_EL_after;
	  CLOSE csr_Legal_Emp_EL_after;
          --
          l_def_bal_id := get_defined_balance_id('Employer Contribution Exemption Limit Used', '_TU_BIMONTH') ;
          l_el_b := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          l_el_b := l_el_a + nvl(l_el_b,0) + nvl(rg_Legal_Emp_EL_after.economic_aid,0);
          --
        END IF;
        --
        l_el_a := greatest(l_el_a, 0);
        l_el_b := greatest(l_el_b, 0);
        --
	/* Inserting header details belonging to  Employer*/
	pay_action_information_api.create_action_information (
  	 p_action_information_id        => l_action_info_id
	,p_action_context_id            => p_payroll_action_id
	,p_action_context_type          => 'PA'
	,p_object_version_number        => l_ovn
	,p_effective_date               => l_effective_date
	,p_source_id                    => NULL
	,p_source_text                  => NULL
	,p_action_information_category  => 'EMEA REPORT INFORMATION'
	,p_action_information1          => 'PYNORSEA'
	,p_action_information2          => l_legal_employer_id
	,p_action_information3          => l_period || l_year
	,p_action_information4          => rg_LE_Details.org_number
	,p_action_information5          => rg_LE_Details.municipal_no
	,p_action_information6          => rg_LE_Details.le_name
	,p_action_information7          => rg_LE_addr.address_line_1
	,p_action_information8          => rg_LE_addr.address_line_2
	,p_action_information9          => rg_LE_addr.postal_code
	,p_action_information10         => rg_LE_addr.postal_office
	,p_action_information11         => rg_LE_Contact.email
 	,p_action_information12         => rg_LE_Contact.phone
	,p_action_information13         => null -- for Tax unit details
	,p_action_information14         => null -- for Tax unit details
	,p_action_information15         => null -- for Tax unit details
	,p_action_information16         => null -- for Tax unit details
	,p_action_information17         => l_industry_status
	,p_action_information18         => fnd_number.number_to_canonical(NVL(l_el,0)) -- Other economic support (Economic Aid)
	,p_action_information19         => l_nace_code
	,p_action_information20         => rg_LE_addr.address_line_3
	,p_action_information21         => fnd_number.number_to_canonical(NVL(l_el_b,0)) -- remaining exemption limit prev rep term
	,p_action_information22         => fnd_number.number_to_canonical(NVL(l_el_a,0)) -- remaining exemption limit after rep term
        );
        --
        /* Inserting the selection criteria for generating the report*/
	pay_action_information_api.create_action_information (
	 p_action_information_id        => l_action_info_id
	,p_action_context_id            => p_payroll_action_id
	,p_action_context_type          => 'PA'
	,p_object_version_number        => l_ovn
	,p_effective_date               => l_effective_date
	,p_source_id                    => NULL
	,p_source_text                  => NULL
	,p_action_information_category  => 'EMEA REPORT DETAILS'
	,p_action_information1          => 'PYNORSEA'
	,p_action_information2          => rg_LE_Details.le_name
	,p_action_information3          => l_lu_name
	,p_action_information4          => l_period
	,p_action_information5          => l_year
        );
        --
	IF g_debug THEN
	  hr_utility.set_location(' Inside Procedure RANGE_CODE',20);
	END IF;
	/* Inserting municipal codes for the Legal Employer in a PL/SQL table */
	IF l_local_unit_id IS NULL THEN
        --
	  l_counter := 0;
	  l_status :=  0;
          --
	  FOR prepaid_assignments_le_rec IN csr_prepaid_assignments_le(p_payroll_action_id
                                                                      ,l_legal_employer_id
                                                                      ,l_reporting_start_date
                                                                      ,l_reporting_end_date)
	  LOOP
	  --
	    FOR  get_mun_num_rec IN csr_get_mun_num(prepaid_assignments_le_rec.assignment_id
                                                   ,l_reporting_start_date)
	    LOOP
            --
              IF l_counter > 0 THEN
		--
                FOR i IN 1 .. l_counter LOOP
		  IF gmunicipaldata(i).municipalcode = get_mun_num_rec.screen_entry_value THEN
                    l_status:= 1;
		    EXIT ;
                  END IF;
                END LOOP;
              --
              END IF;
              --
              IF l_status= 0 THEN
		l_counter := l_counter + 1;
		gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;
	      END IF;
              --
	    l_status :=  0;
            --
	  END LOOP;
          --
          l_status :=  0;
          --
          FOR  get_mun_num_rec IN csr_get_mun_num(prepaid_assignments_le_rec.assignment_id
                                                 ,l_reporting_end_date)
	  LOOP
	  --
	    IF l_counter > 0 THEN
	    --
              FOR i IN 1 .. l_counter LOOP
		IF gmunicipaldata(i).municipalcode  = get_mun_num_rec.screen_entry_value THEN
	          l_status:= 1;
		  EXIT ;
		END IF;
	      END LOOP;
            END IF;
            --
            IF l_status= 0 THEN
	      l_counter := l_counter + 1;
	      gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;
	    END IF;
            --
            l_status :=  0;
            --
            END LOOP;
          --
          END LOOP;
        --
        ELSE -- IF LU is specified in parameters
        /* Inserting municipal codes for the Local Unit in a PL/SQL table */
	  l_counter := 0;
	  l_status :=  0;
          --
	  FOR prepaid_assignments_lu_rec IN csr_prepaid_assignments_lu(p_payroll_action_id
                                                                      ,l_legal_employer_id
                                                                      ,l_local_unit_id
                                                                      ,l_reporting_start_date
                                                                      ,l_reporting_END_date)
	  LOOP
	  --
            FOR  get_mun_num_rec IN csr_get_mun_num(prepaid_assignments_lu_rec.assignment_id
                                                   ,l_reporting_start_date)
	    LOOP
            --
	      IF l_counter > 0 THEN
		FOR i IN 1 .. l_counter LOOP
		  IF gmunicipaldata(i).municipalcode  = get_mun_num_rec.screen_entry_value THEN
		    l_status:= 1;
		    EXIT ;
		  END IF;
		END LOOP;
	      END IF;
              --
	      IF l_status= 0 THEN
		l_counter := l_counter + 1;
		gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;
	      END IF;
              --
              l_status :=  0;
              --
	    END LOOP;
            --
	    l_status :=  0;
            --
	    FOR get_mun_num_rec IN csr_get_mun_num(prepaid_assignments_lu_rec.assignment_id
                                                  ,l_reporting_end_date)
	    LOOP
	      IF l_counter > 0 THEN
		FOR i IN 1 .. l_counter LOOP
		  IF gmunicipaldata(i).municipalcode  = get_mun_num_rec.screen_entry_value THEN
		    l_status:= 1;
		    EXIT ;
		  END IF;
		END LOOP;
	      END IF;
              --
	      IF l_status= 0 THEN
		l_counter := l_counter + 1;
		gmunicipaldata(l_counter).municipalcode:=get_mun_num_rec.screen_entry_value;
	      END IF;
              --
	    l_status :=  0;
            --
	  END LOOP;
          --
	END LOOP;
        --
      END IF ; -- plsql table now contains all the tax municipal codes
      --
      IF g_debug THEN
	hr_utility.set_location(' Inside Procedure RANGE_CODE',40);
      END IF;
        --
        -- ----------------------- --
        -- Withholding Tax Section --
        -- ----------------------- --
        --
				/* Setting contexts for balances*/
        FOR i IN 1 .. l_counter LOOP
        --
          l_municipal_no:=gmunicipaldata(i).municipalcode;
					--
          IF  l_municipal_no IS NOT NULL THEN
            --
       	    pay_balance_pkg.set_context('SOURCE_TEXT2', l_municipal_no);
            --
            l_sum_tax_value := 0;
	    /* Setting municipality details for balances*/
	    OPEN  csr_get_mun_dtls(l_municipal_no, l_reporting_end_date);
	    FETCH csr_get_mun_dtls INTO rg_get_mun_dtls;
	    CLOSE csr_get_mun_dtls;
  	    --
            l_municipal_name	:= rg_get_mun_dtls.municipal_name;
	    /* Fetching balance values related to employer contributions report*/
	    IF  l_local_unit_id IS NULL THEN
	      FOR lu_dtls_rec IN csr_lu_dtls(l_legal_employer_id)
	      LOOP
                pay_balance_pkg.set_context('LOCAL_UNIT_ID',lu_dtls_rec.lu_id);
                l_tax_value  := 0;
                l_def_bal_id := get_defined_balance_id('Tax','_TU_MC_LU_BIMONTH');
                l_tax_value  := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
                l_sum_tax_value := l_sum_tax_value + l_tax_value;
	      END LOOP;
	    ELSE
	      pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id);
              l_tax_value := 0;
              l_def_bal_id := get_defined_balance_id('Tax','_TU_MC_LU_BIMONTH');
              l_tax_value :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
              l_sum_tax_value := l_sum_tax_value + l_tax_value;
	    END IF;
            --
            pay_action_information_api.create_action_information (
              p_action_information_id        => l_action_info_id
             ,p_action_context_id            => p_payroll_action_id
             ,p_action_context_type          => 'PA'
             ,p_object_version_number        => l_ovn
             ,p_effective_date               => l_effective_date
             ,p_source_id                    => NULL
             ,p_source_text                  => NULL
             ,p_action_information_category  => 'EMEA REPORT INFORMATION'
             ,p_action_information1          => 'PYNORSEA-WT'
             ,p_action_information2          => l_municipal_no
             ,p_action_information3          => l_municipal_name
             ,p_action_information4          => fnd_number.number_to_canonical(NVL(l_sum_tax_value,0)) );
            --
            l_municipal_no:=NULL;
          --
	  END IF;
	  --
	END LOOP; -- plsql table for all tax municipal exhausted
        --
  	IF g_debug THEN
	  hr_utility.set_location(' Inside Procedure RANGE_CODE',60);
	END IF;
        --
        -- ----------------------------- --
        -- Employer Contribution Section --
        -- ----------------------------- --
        --
        -- Fetching the global value NO_NI_FOREIGN_MARINER_AMOUNT*/
	OPEN csr_global_value('NO_NI_FOREIGN_MARINER_AMOUNT' , l_reporting_end_date ) ;
	FETCH  csr_global_value INTO l_fe_fm_amount;
	CLOSE csr_global_value;
        --
        IF l_local_unit_id IS NULL THEN
        --
	  FOR lu_dtls_rec IN csr_lu_dtls(l_legal_employer_id)
	  LOOP
            --
            OPEN  csr_LU_Details(lu_dtls_rec.lu_id);
            FETCH csr_LU_Details INTO rg_LU_Details;
            CLOSE csr_LU_Details;
            --
	    OPEN  csr_get_mun_dtls(rg_LU_Details.municipal_no, l_reporting_end_date);
	    FETCH csr_get_mun_dtls INTO rg_get_mun_dtls;
	    CLOSE csr_get_mun_dtls;
            --
            l_base_base := 0;
            l_base_amt  := 0;
            l_reimb_base := 0;
            l_reimb_amt := 0;
            l_utl1_base := 0;
            l_utl1_amt  := 0;
            l_utr1_base := 0;
            l_utr1_amt  := 0;
            l_utl2_base := 0;
            l_utl2_amt  := 0;
            --
            pay_balance_pkg.set_context('LOCAL_UNIT_ID',lu_dtls_rec.lu_id);
            --
            -- EC Base
            l_def_bal_id := get_defined_balance_id('Employer Contribution Base','_TU_LU_BIMONTH') ;
            l_base_base :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution','_TU_LU_BIMONTH') ;
            l_base_amt  :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            -- Reimbursed from SS
            l_def_bal_id := get_defined_balance_id('Employer Contribution Holiday Pay Reimbursed Base','_TU_LU_BIMONTH') ;
            l_reimb_base := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Benefit Reimbursed Base','_TU_LU_BIMONTH') ;
            l_reimb_base :=  l_reimb_base + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Holiday Pay Reimbursed','_TU_LU_BIMONTH') ;
            l_reimb_amt :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Benefit Reimbursed','_TU_LU_BIMONTH') ;
            l_reimb_amt :=  l_reimb_amt + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            -- EC Base, Special EC percentage -UTL1
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage Base','_TU_LU_BIMONTH') ;
            l_utl1_base :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage','_TU_LU_BIMONTH') ;
            l_utl1_amt :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            -- Reimbursed from SS, Special EC Percentage - UTR1
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special Perc Holiday Pay Reimb Base','_TU_LU_BIMONTH') ;
            l_utr1_base := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special Perc Benefit Reimbursed Base','_TU_LU_BIMONTH') ;
            l_utr1_base := l_utr1_base + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special Perc Holiday Pay Reimbursed','_TU_LU_BIMONTH') ;
            l_utr1_amt :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage Benefit Reimbursed','_TU_LU_BIMONTH') ;
            l_utr1_amt := l_utr1_amt + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            -- EC Base Special monthly amount - UTL2
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special Base','_TU_LU_BIMONTH') ;
            l_utl2_base := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE)/ l_fe_fm_amount;
            --
            l_def_bal_id := get_defined_balance_id('Employer Contribution Special','_TU_LU_BIMONTH') ;
            l_utl2_amt :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            -- EC Base Pension
            l_def_bal_id := get_defined_balance_id('Employers Pension Premium','_TU_LU_BIMONTH') ;
            l_pension_base :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
            --
            pay_action_information_api.create_action_information (
               p_action_information_id        => l_action_info_id
              ,p_action_context_id            => p_payroll_action_id
              ,p_action_context_type          => 'PA'
              ,p_object_version_number        => l_ovn
              ,p_effective_date               => l_effective_date
              ,p_source_id                    => NULL
              ,p_source_text                  => NULL
              ,p_action_information_category  => 'EMEA REPORT INFORMATION'
              ,p_action_information1          => 'PYNORSEA-EC'
              ,p_action_information2          => l_legal_employer_id
              ,p_action_information3          => lu_dtls_rec.lu_id
              ,p_action_information4          => rg_LU_Details.org_num
              ,p_action_information5          => rg_LU_Details.municipal_no
              ,p_action_information6          => rg_get_mun_dtls.municipal_name
              ,p_action_information7          => rg_get_mun_dtls.zone
              ,p_action_information8          => fnd_number.number_to_canonical(NVL(l_base_base,0))
              ,p_action_information9          => fnd_number.number_to_canonical(NVL(l_base_amt,0))
              ,p_action_information10         => fnd_number.number_to_canonical(NVL(l_reimb_base,0))
              ,p_action_information11         => fnd_number.number_to_canonical(-1 * NVL(l_reimb_amt,0))
              ,p_action_information12         => fnd_number.number_to_canonical(NVL(l_utl1_base,0))
              ,p_action_information13         => fnd_number.number_to_canonical(NVL(l_utl1_amt,0))
              ,p_action_information14         => fnd_number.number_to_canonical(NVL(l_utr1_base,0))
              ,p_action_information15         => fnd_number.number_to_canonical(-1 * NVL(l_utr1_amt,0))
              ,p_action_information16         => fnd_number.number_to_canonical(NVL(l_utl2_base,0))
              ,p_action_information17         => fnd_number.number_to_canonical(NVL(l_utl2_amt,0))
              ,p_action_information18         => fnd_number.number_to_canonical(NVL(l_pension_base,0))
	      );
          --
          END LOOP;
        --
        ELSE -- LU Specified
          --
          OPEN  csr_LU_Details(l_local_unit_id);
          FETCH csr_LU_Details INTO rg_LU_Details;
          CLOSE csr_LU_Details;
          --
   	  OPEN  csr_get_mun_dtls(rg_LU_Details.municipal_no, l_reporting_end_date);
	  FETCH csr_get_mun_dtls INTO rg_get_mun_dtls;
	  CLOSE csr_get_mun_dtls;
          --
          l_base_base := 0;
          l_base_amt  := 0;
          l_reimb_base := 0;
          l_reimb_amt := 0;
          l_utl1_base := 0;
          l_utl1_amt  := 0;
          l_utr1_base := 0;
          l_utr1_amt  := 0;
          l_utl2_base := 0;
          l_utl2_amt  := 0;
          --
          pay_balance_pkg.set_context('LOCAL_UNIT_ID',l_local_unit_id);
          -- EC Base
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Base','_TU_LU_BIMONTH') ;
	  l_base_base :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution','_TU_LU_BIMONTH') ;
	  l_base_amt  :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
          -- Reimbursed from SS
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Holiday Pay Reimbursed Base','_TU_LU_BIMONTH') ;
	  l_reimb_base := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Benefit Reimbursed Base','_TU_LU_BIMONTH') ;
	  l_reimb_base := l_reimb_base + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Holiday Pay Reimbursed','_TU_LU_BIMONTH') ;
	  l_reimb_amt := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Benefit Reimbursed','_TU_LU_BIMONTH') ;
	  l_reimb_amt := l_reimb_amt + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
          -- EC Base, Special EC percentage -UTL1
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage Base','_TU_LU_BIMONTH') ;
	  l_utl1_base := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage','_TU_LU_BIMONTH') ;
	  l_utl1_amt := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
          -- Reimbursed from SS, Special EC Percentage - UTR1
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special Perc Holiday Pay Reimb Base','_TU_LU_BIMONTH') ;
	  l_utr1_base := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special Perc Benefit Reimbursed Base','_TU_LU_BIMONTH') ;
	  l_utr1_base := l_utr1_base + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special Perc Holiday Pay Reimbursed','_TU_LU_BIMONTH') ;
	  l_utr1_amt := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special Percentage Benefit Reimbursed','_TU_LU_BIMONTH') ;
	  l_utr1_amt := l_utr1_amt + pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
          -- EC Base Special monthly amount - UTL2
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special Base','_TU_LU_BIMONTH') ;
	  l_utl2_base := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE) / l_fe_fm_amount;
          --
	  l_def_bal_id := get_defined_balance_id('Employer Contribution Special','_TU_LU_BIMONTH') ;
	  l_utl2_amt := pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          -- EC Base Pension
          l_def_bal_id := get_defined_balance_id('Employers Pension Premium','_TU_LU_BIMONTH') ;
          l_pension_base :=  pay_balance_pkg.get_value(l_def_bal_id, NULL, FALSE);
          --
          pay_action_information_api.create_action_information (
             p_action_information_id        => l_action_info_id
            ,p_action_context_id            => p_payroll_action_id
            ,p_action_context_type          => 'PA'
            ,p_object_version_number        => l_ovn
            ,p_effective_date               => l_effective_date
            ,p_source_id                    => NULL
            ,p_source_text                  => NULL
            ,p_action_information_category  => 'EMEA REPORT INFORMATION'
            ,p_action_information1          => 'PYNORSEA-EC'
            ,p_action_information2          => l_legal_employer_id
            ,p_action_information3          => l_local_unit_id
            ,p_action_information4          => rg_LU_Details.org_num
            ,p_action_information5          => rg_LU_Details.municipal_no
            ,p_action_information6          => rg_get_mun_dtls.municipal_name
            ,p_action_information7          => rg_get_mun_dtls.zone
            ,p_action_information8          => fnd_number.number_to_canonical(NVL(l_base_base,0))
            ,p_action_information9          => fnd_number.number_to_canonical(NVL(l_base_amt,0))
            ,p_action_information10         => fnd_number.number_to_canonical(NVL(l_reimb_base,0))
            ,p_action_information11         => fnd_number.number_to_canonical(-1 * NVL(l_reimb_amt,0))
            ,p_action_information12         => fnd_number.number_to_canonical(NVL(l_utl1_base,0))
            ,p_action_information13         => fnd_number.number_to_canonical(NVL(l_utl1_amt,0))
            ,p_action_information14         => fnd_number.number_to_canonical(NVL(l_utr1_base,0))
            ,p_action_information15         => fnd_number.number_to_canonical(-1 * NVL(l_utr1_amt,0))
            ,p_action_information16         => fnd_number.number_to_canonical(NVL(l_utl2_base,0))
            ,p_action_information17         => fnd_number.number_to_canonical(NVL(l_utl2_amt,0))
            ,p_action_information18         => fnd_number.number_to_canonical(NVL(l_pension_base,0))
           );
          --
        END IF; -- LU specified
      --
      END IF; -- Archive = 'Y'
    --
    END IF; -- Count < 0
    --
    IF g_debug THEN
      hr_utility.set_location(' Leaving Procedure RANGE_CODE',70);
    END IF;
 --
 EXCEPTION
    --
    WHEN OTHERS THEN
     -- Return cursor that selects no rows
      p_sql := 'select 1 from dual where to_char(:payroll_action_id) = dummy';
      fnd_file.put_line(fnd_file.log,'Error in EC 1'||substr(sqlerrm , 1, 30));
--
END RANGE_CODE;
--
-- -----------------------------------------------------------------------------
-- ASSIGNMENT ACTION CODE
-- -----------------------------------------------------------------------------
--
PROCEDURE ASSG_ACTION_CODE
	 (p_payroll_action_id     IN NUMBER
	 ,p_start_person          IN NUMBER
	 ,p_end_person            IN NUMBER
	 ,p_chunk                 IN NUMBER)
	 IS
	 BEGIN
   --
   IF g_debug THEN
     hr_utility.set_location(' Entering Procedure ASSIGNMENT_ACTION_CODE',80);
   END IF;
   --
   IF g_debug THEN
     hr_utility.set_location(' Leaving Procedure ASSIGNMENT_ACTION_CODE',90);
   END IF;
--
END ASSG_ACTION_CODE;
--
-- -----------------------------------------------------------------------------
-- INITIALIZATION CODE
-- -----------------------------------------------------------------------------
--
PROCEDURE INIT_CODE(p_payroll_action_id IN NUMBER)
         IS
	 BEGIN
     --
     IF g_debug THEN
	hr_utility.set_location(' Entering Procedure INITIALIZATION_CODE',100);
     END IF;
     --
     IF g_debug THEN
	hr_utility.set_location(' Leaving Procedure INITIALIZATION_CODE',110);
     END IF;
     --
   EXCEPTION WHEN OTHERS THEN
       g_err_num := SQLCODE;
   IF g_debug THEN
      hr_utility.set_location('ORA_ERR: ' || g_err_num || 'In INITIALIZATION_CODE',120);
   END IF;
END INIT_CODE;
--
-- -----------------------------------------------------------------------------
-- ARCHIVE CODE
-- -----------------------------------------------------------------------------
--
PROCEDURE ARCHIVE_CODE(p_assignment_action_id IN NUMBER
		      ,p_effective_date       IN DATE)
	 IS
   BEGIN
     --
     IF g_debug THEN
       hr_utility.set_location(' Entering Procedure ARCHIVE_CODE',130);
     END IF;
     --
     IF g_debug THEN
       hr_utility.set_location(' Leaving Procedure ARCHIVE_CODE',140);
     END IF;
--
END ARCHIVE_CODE;
--
-- ------------------------------------------------------ --
-- GET_PDF_REP to generate the xml for pdf report (audit) --
-- ------------------------------------------------------ --
--
 PROCEDURE get_pdf_rep
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := 'get_pdf_rep';
  --
  CURSOR csr_LEGEMP
          (l_payroll_action_id IN NUMBER) IS
   SELECT leg_emp.action_information2  le_id
         ,leg_emp.action_information3  period_year
         ,leg_emp.action_information4  org_num
         ,leg_emp.action_information5  municipal_no
         ,leg_emp.action_information6  le_name
         ,leg_emp.action_information7  ada_line1
         ,leg_emp.action_information8  ada_line2
         ,leg_emp.action_information9  post_code
         ,leg_emp.action_information10 post_off
         ,leg_emp.action_information11 email
         ,leg_emp.action_information12 phone
         ,leg_emp.action_information17 industry_status
         ,fnd_number.canonical_to_number(leg_emp.action_information18) exempt_limit
         ,leg_emp.action_information19 nace_code
         ,leg_emp.action_information20 ada_line3
         ,fnd_number.canonical_to_number(leg_emp.action_information21) exempt_limit_prev
         ,fnd_number.canonical_to_number(leg_emp.action_information22) exempt_limit_after
   FROM   pay_action_information leg_emp
   WHERE  leg_emp.action_context_type         = 'PA'
     AND  leg_emp.action_context_id           = l_payroll_action_id
     AND  leg_emp.action_information_category = 'EMEA REPORT INFORMATION'
     AND  leg_emp.action_information1         = 'PYNORSEA';
  --
  rec_LEGEMP csr_LEGEMP%ROWTYPE;
  --
  CURSOR csr_LU
          (l_payroll_action_id IN NUMBER) IS
   SELECT lu.action_information4  lu_org_num
         ,lu.action_information5  lu_municipal_num
         ,lu.action_information6  lu_municipal_name
         ,lu.action_information7  lu_zone
         ,fnd_number.canonical_to_number(lu.action_information8)  ec_base
         ,fnd_number.canonical_to_number(lu.action_information9)  ec_amt
         ,fnd_number.canonical_to_number(lu.action_information10) reimburse_base
         ,fnd_number.canonical_to_number(lu.action_information11) reimburse_amt
         ,fnd_number.canonical_to_number(lu.action_information12) UTL1_base
         ,fnd_number.canonical_to_number(lu.action_information13) UTL1_amt
         ,fnd_number.canonical_to_number(lu.action_information14) UTR1_base
         ,fnd_number.canonical_to_number(lu.action_information15) UTR1_amt
         ,fnd_number.canonical_to_number(lu.action_information16) UTL2_base
         ,fnd_number.canonical_to_number(lu.action_information17) UTL2_amt
         ,fnd_number.canonical_to_number(lu.action_information18) pension_base
   FROM   pay_action_information lu
   WHERE  lu.action_context_type         = 'PA'
     AND  lu.action_context_id           = l_payroll_action_id
     AND  lu.action_information_category = 'EMEA REPORT INFORMATION'
     AND  lu.action_information1         = 'PYNORSEA-EC'
   ORDER BY 3;
  --
  rec_LU csr_LU%ROWTYPE;
  --
  CURSOR csr_TAX (l_payroll_action_id IN NUMBER) IS
   SELECT wt.action_information2                                 wt_municipal_num
         ,wt.action_information3                                 wt_municipal_name
         ,fnd_number.canonical_to_number(wt.action_information4) wt_tax_value
   FROM   pay_action_information wt
   WHERE  wt.action_context_type         = 'PA'
     AND  wt.action_context_id           = l_payroll_action_id
     AND  wt.action_information_category = 'EMEA REPORT INFORMATION'
     AND  wt.action_information1         = 'PYNORSEA-WT'
   ORDER BY 2;
  --
  rec_TAX csr_TAX%ROWTYPE;
  --
  l_xml_element_count NUMBER := 1;
  l_pension_footnote  NUMBER := 0;
  l_payroll_action_id NUMBER;
  l_ec_base_total     NUMBER := 0;
  l_ec_amt_total      NUMBER := 0;
  l_wt_total          NUMBER := 0;
  --
 BEGIN
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  g_xml_element_table.DELETE;
  --
  IF p_payroll_action_id is null then
    BEGIN
    SELECT payroll_action_id
      into l_payroll_action_id
      from pay_payroll_actions ppa,
	   fnd_conc_req_summary_v fcrs,
	   fnd_conc_req_summary_v fcrs1
     WHERE fcrs.request_id = fnd_global.conc_request_id
       and fcrs.priority_request_id = fcrs1.priority_request_id
       and ppa.request_id between fcrs1.request_id and fcrs.request_id
       and ppa.request_id = fcrs1.request_id;
     EXCEPTION
     WHEN others then
       null;
     END;
  ELSE
    l_payroll_action_id := p_payroll_action_id;
  END IF;
  --
  OPEN  csr_LEGEMP(l_payroll_action_id);
  FETCH csr_LEGEMP INTO rec_LEGEMP;
  CLOSE csr_LEGEMP;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TERM';
  g_xml_element_table(l_xml_element_count).tagvalue := substr(rec_LEGEMP.period_year,1,1);
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'PERIOD';
  g_xml_element_table(l_xml_element_count).tagvalue := substr(rec_LEGEMP.period_year,2,4);
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ORGANIZATION_NUMBER';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.org_num;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'LE_NAME';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.le_name;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ADD_LINE1';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.ada_line1;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ADD_LINE2';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.ada_line2;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ADD_LINE3';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.ada_line3;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'POST_CODE';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.post_code;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'POST_OFFICE';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.post_off;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'EMAIL';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.email;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'PHONE';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.phone;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'NACE_CODE';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.nace_code;
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'CALC_METHOD_'||rec_LEGEMP.industry_status;
  g_xml_element_table(l_xml_element_count).tagvalue := 'X';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'EXEMPT_LIMIT';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_LEGEMP.exempt_limit,'FM9G999G999G999G990D00');
  g_xml_element_table(l_xml_element_count).tagtype  := 'A';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'REMAINING_EXPEMT_PREV';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_LEGEMP.exempt_limit_prev,'FM9G999G999G999G990D00');
  g_xml_element_table(l_xml_element_count).tagtype  := 'A';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'REMAINING_EXPEMT_AFTER';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_LEGEMP.exempt_limit_after,'FM9G999G999G999G990D00');
  g_xml_element_table(l_xml_element_count).tagtype  := 'A';
  l_xml_element_count := l_xml_element_count + 1;
  --
  FOR rec_lu IN csr_LU(l_payroll_action_id)
  LOOP
  --
    IF rec_lu.ec_base <> 0 OR rec_lu.ec_amt <> 0 THEN
    --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ORG_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_org_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NAME';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_name;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ZONE';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_zone;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EC_REP';
      g_xml_element_table(l_xml_element_count).tagvalue := 'X';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'BASE';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.ec_base,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_base_total := l_ec_base_total + rec_lu.ec_base;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'AMT';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.ec_amt,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_amt_total := l_ec_amt_total + rec_lu.ec_amt;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
      --
    END IF;
    --
    IF rec_lu.reimburse_base <> 0 OR rec_lu.reimburse_amt <> 0 THEN
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ORG_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_org_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NAME';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_name;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ZONE';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_zone;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'REIMBURSE_REP';
      g_xml_element_table(l_xml_element_count).tagvalue := 'X';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'BASE';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.reimburse_base,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_base_total := l_ec_base_total + rec_lu.reimburse_base;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'AMT';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.reimburse_amt,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_amt_total := l_ec_amt_total + rec_lu.reimburse_amt;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
      --
    END IF;
    --
    IF rec_lu.UTL1_base <> 0 OR rec_lu.UTL1_amt <> 0 THEN
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ORG_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_org_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NAME';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_name;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ZONE';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_zone;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'UTL1_REP';
      g_xml_element_table(l_xml_element_count).tagvalue := 'X';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'BASE';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.UTL1_base,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_base_total := l_ec_base_total + rec_lu.UTL1_base;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'AMT';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.UTL1_amt,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_amt_total := l_ec_amt_total + rec_lu.UTL1_amt;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
      --
    END IF;
    --
    IF rec_lu.UTR1_base <> 0 OR rec_lu.UTR1_amt <> 0 THEN
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ORG_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_org_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NAME';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_name;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ZONE';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_zone;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'UTR1_REP';
      g_xml_element_table(l_xml_element_count).tagvalue := 'X';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'BASE';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.UTR1_base,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_base_total := l_ec_base_total + rec_lu.UTR1_base;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'AMT';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.UTR1_amt,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_amt_total := l_ec_amt_total + rec_lu.UTR1_amt;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
      --
    END IF;
    --
    IF rec_lu.UTL2_base <> 0 OR rec_lu.UTL2_amt <> 0 THEN
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ORG_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_org_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NAME';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_name;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ZONE';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_zone;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'UTR2_REP';
      g_xml_element_table(l_xml_element_count).tagvalue := 'X';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'BASE';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(round(rec_lu.UTL2_base,2));
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'AMT';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.UTL2_amt,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_amt_total := l_ec_amt_total + rec_lu.UTL2_amt;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
    --
    END IF;
    --
    IF rec_lu.pension_base <> 0 THEN
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ORG_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_org_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NUM';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_num;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_MUNICIPAL_NAME';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_name;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'LU_ZONE';
      g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_zone;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'PENSION_REP';
      g_xml_element_table(l_xml_element_count).tagvalue := 'X';
      l_xml_element_count := l_xml_element_count + 1;
      l_pension_footnote := 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'BASE';
      g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_lu.pension_base,'FM9G999G999G999G990D00');
      g_xml_element_table(l_xml_element_count).tagtype  := 'A';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'AMT';
      g_xml_element_table(l_xml_element_count).tagvalue := '*)';
      l_xml_element_count := l_xml_element_count + 1;
      l_ec_base_total := l_ec_base_total + rec_lu.pension_base;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYER_CONTRIBUTION';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
    --
    END IF;
  --
  END LOOP;
  --
  FOR rec_tax IN csr_TAX(l_payroll_action_id)
  LOOP
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'WITHHOLDING_TAX';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'WT_MUNICIPAL_NUM';
    g_xml_element_table(l_xml_element_count).tagvalue := rec_tax.wt_municipal_num;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'WT_MUNICIPAL_NAME';
    g_xml_element_table(l_xml_element_count).tagvalue := rec_tax.wt_municipal_name;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'WITHHOLDING_TAX_AMT';
    g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_tax.wt_tax_value,'FM9G999G999G999G990D00');
    g_xml_element_table(l_xml_element_count).tagtype  := 'A';
    l_xml_element_count := l_xml_element_count + 1;
    l_wt_total := l_wt_total + rec_tax.wt_tax_value;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'WITHHOLDING_TAX';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
  END LOOP;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TOTAL_EC_AMT';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_ec_amt_total,'FM9G999G999G999G990D00');
  g_xml_element_table(l_xml_element_count).tagtype  := 'A';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TOTAL_EC_BASE';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_ec_base_total,'FM9G999G999G999G990D00');
  g_xml_element_table(l_xml_element_count).tagtype  := 'A';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TOTAL_WITHHOLDING_TAX';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_wt_total,'FM9G999G999G999G990D00');
  g_xml_element_table(l_xml_element_count).tagtype  := 'A';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Footnote section for Pension Calculated Employer Contribution
  IF l_pension_footnote = 1 THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'FOOT_NOTE';
    g_xml_element_table(l_xml_element_count).tagvalue := '*) ' || HR_GENERAL.DECODE_LOOKUP('NO_FORM_LABELS','PENSION_FOOTNOTE');
    l_xml_element_count := l_xml_element_count + 1;
  END IF;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  write_to_clob(p_xml);
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
  --
 END get_pdf_rep;
--
-- ------------------------------------------------- --
-- GET_XML_REP to generate the standard xml extract  --
-- ------------------------------------------------- --
--
 PROCEDURE get_xml_rep
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := 'get_xml_rep';
  --
  CURSOR csr_LEGEMP
          (l_payroll_action_id IN NUMBER) IS
   SELECT leg_emp.action_information3  period_year
         ,leg_emp.action_information4  org_num
         ,leg_emp.action_information5  municipal_no
         ,leg_emp.action_information6  le_name
         ,leg_emp.action_information7  add_line1
         ,leg_emp.action_information8  add_line2
         ,leg_emp.action_information9  post_code
         ,leg_emp.action_information10 post_off
         ,leg_emp.action_information17 industry_status
         ,fnd_number.canonical_to_number(leg_emp.action_information18) exempt_limit
         ,leg_emp.action_information19                                 nace_code
         ,leg_emp.action_information20                                 add_line3
         ,fnd_number.canonical_to_number(leg_emp.action_information21)  exempt_limit_prev
         ,fnd_number.canonical_to_number(leg_emp.action_information22)  exempt_limit_after
   FROM   pay_action_information leg_emp
   WHERE  leg_emp.action_context_type         = 'PA'
     AND  leg_emp.action_context_id           = l_payroll_action_id
     AND  leg_emp.action_information_category = 'EMEA REPORT INFORMATION'
     AND  leg_emp.action_information1         = 'PYNORSEA';
  --
  rec_LEGEMP csr_LEGEMP%ROWTYPE;
  --
  CURSOR csr_sum_LU
          (l_payroll_action_id IN NUMBER) IS
   SELECT SUM(fnd_number.canonical_to_number(lu.action_information8))  EC_base_sum
         ,SUM(fnd_number.canonical_to_number(lu.action_information10)) REIM_base_sum
         ,SUM(fnd_number.canonical_to_number(lu.action_information12)) UTL1_base_sum
         ,SUM(fnd_number.canonical_to_number(lu.action_information14)) UTR1_base_sum
         ,SUM(fnd_number.canonical_to_number(lu.action_information16)) UTL2_base_sum
         ,SUM(fnd_number.canonical_to_number(lu.action_information9))
         + SUM(fnd_number.canonical_to_number(lu.action_information11))
         + SUM(fnd_number.canonical_to_number(lu.action_information13))
         + SUM(fnd_number.canonical_to_number(lu.action_information15))
         + SUM(fnd_number.canonical_to_number(lu.action_information17)) amt_sum
   FROM   pay_action_information lu
   WHERE  lu.action_context_type         = 'PA'
     AND  lu.action_context_id           = l_payroll_action_id
     AND  lu.action_information_category = 'EMEA REPORT INFORMATION'
     AND  lu.action_information1         = 'PYNORSEA-EC';
  --
  rec_sum_LU csr_sum_LU%ROWTYPE;
  --
  CURSOR csr_LU
          (l_payroll_action_id IN NUMBER) IS
   SELECT lu.action_information4  lu_org_num
         ,lu.action_information5  lu_municipal_num
         ,fnd_number.canonical_to_number(lu.action_information8)  ec_base
         ,fnd_number.canonical_to_number(lu.action_information10) reimburse_base
         ,fnd_number.canonical_to_number(lu.action_information18) pension_base_sum
   FROM   pay_action_information lu
   WHERE  lu.action_context_type         = 'PA'
     AND  lu.action_context_id           = l_payroll_action_id
     AND  lu.action_information_category = 'EMEA REPORT INFORMATION'
     AND  lu.action_information1         = 'PYNORSEA-EC'
   ORDER BY 3;
  --
  rec_LU csr_LU%ROWTYPE;
  --
  CURSOR csr_TAX
          (l_payroll_action_id IN NUMBER) IS
   SELECT wt.action_information2                                wt_municipal_num
         ,fnd_number.canonical_to_number(wt.action_information4) wt_tax_value
   FROM   pay_action_information wt
   WHERE  wt.action_context_type         = 'PA'
     AND  wt.action_context_id           = l_payroll_action_id
     AND  wt.action_information_category = 'EMEA REPORT INFORMATION'
     AND  wt.action_information1         = 'PYNORSEA-WT'
   ORDER BY 1;
  --
  rec_TAX csr_TAX%ROWTYPE;
  --
  l_xml_element_count NUMBER := 1;
  l_payroll_action_id NUMBER;
  l_wt_total          NUMBER := 0;
  --
 BEGIN
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  g_xml_element_table.DELETE;
  --
  IF p_payroll_action_id is null then
    BEGIN
    SELECT payroll_action_id
      into l_payroll_action_id
      from pay_payroll_actions ppa,
	   fnd_conc_req_summary_v fcrs,
	   fnd_conc_req_summary_v fcrs1
     WHERE fcrs.request_id = fnd_global.conc_request_id
       and fcrs.priority_request_id = fcrs1.priority_request_id
       and ppa.request_id between fcrs1.request_id and fcrs.request_id
       and ppa.request_id = fcrs1.request_id;
     EXCEPTION
     WHEN others then
       null;
     END;
  ELSE
    l_payroll_action_id := p_payroll_action_id;
  END IF;
  --
  OPEN  csr_LEGEMP(l_payroll_action_id);
  FETCH csr_LEGEMP INTO rec_LEGEMP;
  CLOSE csr_LEGEMP;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skjema';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'skjemanummer="669" spesifikasjonsnummer="6168"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Innledning-grp-986';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="986"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Periode-grp-57';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="57"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Bi-Monthly Period
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgaveTermin-datadef-11819';
  g_xml_element_table(l_xml_element_count).tagvalue := substr(rec_LEGEMP.period_year,1,1);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="11819"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Year
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgaveAr-datadef-11236';
  g_xml_element_table(l_xml_element_count).tagvalue := substr(rec_LEGEMP.period_year,2,4);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="11236"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Periode-grp-57';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skatteoppkrever-grp-989';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="989"';
  l_xml_element_count := l_xml_element_count + 1;
  -- LE Tax Municipality
  g_xml_element_table(l_xml_element_count).tagname  := 'SkatteoppkreverKommuneNummer-datadef-16513';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.municipal_no;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="16513"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skatteoppkrever-grp-989';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Innsender-grp-56';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="56"';
  l_xml_element_count := l_xml_element_count + 1;
  -- LE Organization Number
  g_xml_element_table(l_xml_element_count).tagname  := 'RapporteringsenhetOrganisasjonsnummer-datadef-21772';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.org_num;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="21772"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Not Used by Oracle Payroll 26
--  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverFodselsnummer-datadef-26';
--  g_xml_element_table(l_xml_element_count).tagvalue := NULL;
--  l_xml_element_count := l_xml_element_count + 1;
  -- LE Name
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverNavnPreutfylt-datadef-25795';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.le_name;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25795"';
  l_xml_element_count := l_xml_element_count + 1;
  -- LE Address
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverAdressePreutfylt-datadef-25796';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.add_line1 ||' '|| rec_LEGEMP.add_line2
                                                       ||' '|| rec_LEGEMP.add_line3;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25796"';
  l_xml_element_count := l_xml_element_count + 1;
  -- LE Address Post Code
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverPostnummerPreutfylt-datadef-25797';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.post_code;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25797"';
  l_xml_element_count := l_xml_element_count + 1;
  -- LE Address Post Office
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverPoststedPreutfylt-datadef-25798';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.post_off;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25798"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Nace Code
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverNACEKode-datadef-27602';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.nace_code;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27602"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Innsender-grp-56';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Innledning-grp-986';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiveravgift-grp-5698';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5698"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Beregningsmate-grp-169';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="169"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Calculation Method
  g_xml_element_table(l_xml_element_count).tagname  := 'TerminoppgaveBeregningsmate-datadef-27603';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.industry_status;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27603"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Exempt limit from Last Reporting Term
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftBunnfradrag-datadef-16517';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.exempt_limit_prev;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="16517"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Beregningsmate-grp-169';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Tilskudd-grp-6712';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6712"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Exempt limit from Last Reporting Term
  g_xml_element_table(l_xml_element_count).tagname  := 'TilskuddAndreTerminoppgave-datadef-27604';
  g_xml_element_table(l_xml_element_count).tagvalue := rec_LEGEMP.exempt_limit;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27604"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Tilskudd-grp-6712';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  OPEN  csr_sum_LU(l_payroll_action_id);
  FETCH csr_sum_LU INTO rec_sum_LU;
  CLOSE csr_sum_LU;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'UTL1-grp-6715';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6715"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Sum of UTL1 Bases
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftUtenlandskGrunnlag-datadef-16518';
  g_xml_element_table(l_xml_element_count).tagvalue := nvl(round(rec_sum_LU.UTL1_base_sum),0);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="16518"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Sum of UTR1 Bases
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftUtenlandskRefusjonsgrunnlagSpesifisert-datadef-27612';
  g_xml_element_table(l_xml_element_count).tagvalue := nvl(round(rec_sum_LU.UTR1_base_sum),0);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27612"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'UTL1-grp-6715';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'UTL2-grp-6716';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6716"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Sum of Months UTL2
  g_xml_element_table(l_xml_element_count).tagname  := 'AnsattUtenlandskManeder-datadef-16519';
  g_xml_element_table(l_xml_element_count).tagvalue := round(nvl(rec_sum_LU.UTL2_base_sum,0));
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="16519"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'UTL2-grp-6716';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiveravgift-grp-5698';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiveravgift-grp-6719';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6719"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  FOR rec_lu IN csr_LU(l_payroll_action_id)
  LOOP
  --
    g_xml_element_table(l_xml_element_count).tagname  := 'TabellArbeidsgiveravgift-grp-4953';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="4953"';
    l_xml_element_count := l_xml_element_count + 1;
    -- LU Org Number
    g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsbetalerOrganisasjonsnummer-datadef-27605';
    g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_org_num;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27605"';
    l_xml_element_count := l_xml_element_count + 1;
    -- Not used by Oracle Payroll - 27606
--    g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsbetalerFodselssnummer-datadef-27606';
--    g_xml_element_table(l_xml_element_count).tagvalue := NULL;
--    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27606"'
--    l_xml_element_count := l_xml_element_count + 1;
    -- LU Tax Municipality
    g_xml_element_table(l_xml_element_count).tagname  := 'KommuneNummer-datadef-5950';
    g_xml_element_table(l_xml_element_count).tagvalue := rec_lu.lu_municipal_num;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="5950"';
    l_xml_element_count := l_xml_element_count + 1;
    -- EC Base (Normal)
    g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftGrunnlagSpesifisert-datadef-27607';
    g_xml_element_table(l_xml_element_count).tagvalue := round(rec_lu.ec_base);
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27607"';
    l_xml_element_count := l_xml_element_count + 1;
    -- Reimbursements
    g_xml_element_table(l_xml_element_count).tagname  := 'RefusjonGrunnlagSpesifisert-datadef-27608';
    g_xml_element_table(l_xml_element_count).tagvalue := round(rec_lu.reimburse_base);
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27608"';
    l_xml_element_count := l_xml_element_count + 1;
    -- Not used by Oracle Payroll - 27611 - set it to zero, till pension built was not in NO loc.
    -- SInce NO Pension built is there, will populate accordingly.
    g_xml_element_table(l_xml_element_count).tagname  := 'PensjonPremieTilskuddSpesifisert-datadef-27611';
    g_xml_element_table(l_xml_element_count).tagvalue := round(rec_lu.pension_base_sum);
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27611"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'TabellArbeidsgiveravgift-grp-4953';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
  END LOOP;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiveravgift-grp-6719';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Forskuddstrekk-grp-6717';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6717"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  FOR rec_tax IN csr_TAX(l_payroll_action_id)
  LOOP
  --
    g_xml_element_table(l_xml_element_count).tagname  := 'TabellForskuddstrekk-grp-6718';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6718"';
    l_xml_element_count := l_xml_element_count + 1;
    -- Emplyee Municipal Code
    g_xml_element_table(l_xml_element_count).tagname  := 'InnberetningspliktigForskuddstrekkKommunenummer-datadef-27615';
    g_xml_element_table(l_xml_element_count).tagvalue := rec_tax.wt_municipal_num;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27615"';
    l_xml_element_count := l_xml_element_count + 1;
    -- Tax
    g_xml_element_table(l_xml_element_count).tagname  := 'ForskuddstrekkSpesifisert-datadef-27616';
    g_xml_element_table(l_xml_element_count).tagvalue := round(rec_tax.wt_tax_value);
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27616"';
    l_xml_element_count := l_xml_element_count + 1;
    l_wt_total := l_wt_total + rec_tax.wt_tax_value;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'TabellForskuddstrekk-grp-6718';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
  END LOOP;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Forskuddstrekk-grp-6717';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Resultater-grp-74';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="74"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Kontrollsummer-grp-4909';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="4909"';
  l_xml_element_count := l_xml_element_count + 1;
  -- EC Base Total
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftGrunnlag-datadef-27617';
  g_xml_element_table(l_xml_element_count).tagvalue := round(rec_sum_LU.EC_base_sum);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27617"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Reimburse Base Total
  g_xml_element_table(l_xml_element_count).tagname  := 'RefusjonGrunnlag-datadef-27618';
  g_xml_element_table(l_xml_element_count).tagvalue := round(rec_sum_LU.REIM_base_sum);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27618"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Pension Base Total (not in place)
  g_xml_element_table(l_xml_element_count).tagname  := 'PensjonPremieTilskuddSumGrunnlag-datadef-27619';
  g_xml_element_table(l_xml_element_count).tagvalue := '0';
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27619"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Remaining Exemption Limit Total
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRestFribelop-datadef-21169';
  g_xml_element_table(l_xml_element_count).tagvalue := round(rec_LEGEMP.exempt_limit_after);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="21169"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Kontrollsummer-grp-4909';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiveravgift-grp-4910';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="4910"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Sum of all the amounts
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftSkyldig-datadef-223';
  g_xml_element_table(l_xml_element_count).tagvalue := round(rec_sum_LU.amt_sum);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="223"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiveravgift-grp-4910';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Forskuddstrekk-grp-4911';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="4911"';
  l_xml_element_count := l_xml_element_count + 1;
  -- Withholding Tax Total
  g_xml_element_table(l_xml_element_count).tagname  := 'Forskuddstrekk-datadef-2903';
  g_xml_element_table(l_xml_element_count).tagvalue := round(l_wt_total);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="2903"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Forskuddstrekk-grp-4911';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Resultater-grp-74';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skjema';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  write_to_clob_for_xml(p_xml);
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
  --
 END get_xml_rep;
--
END PAY_NO_ARC_RSEA_07;

/
