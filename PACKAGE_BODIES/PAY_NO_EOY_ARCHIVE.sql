--------------------------------------------------------
--  DDL for Package Body PAY_NO_EOY_ARCHIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_EOY_ARCHIVE" AS
 /* $Header: pynoeoya.pkb 120.2.12010000.13 2009/09/16 13:12:22 abraghun ship $ */
 --
 l_package_name CONSTANT VARCHAR2(30) := 'pay_no_eoy_archive';
 --
 --
 -- -----------------------------------------------------------------------------
 -- Data types.
 -- -----------------------------------------------------------------------------
 --
 TYPE t_xml_element_rec IS RECORD
  (tagname  VARCHAR2(100)
  ,tagvalue VARCHAR2(500)
  ,tagtype  VARCHAR2(1)
  ,tagattrb VARCHAR2(500));
 --
 TYPE t_xml_element_table IS TABLE OF t_xml_element_rec INDEX BY BINARY_INTEGER;
 --
 TYPE t_number_table IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
 --
 TYPE t_ni_zones_rec IS RECORD
  (ni_zone t_number_table
  ,total   NUMBER);
 --
 TYPE t_le_si_bal_rec IS RECORD
  (si_status                      VARCHAR2(10)
  ,tax                            NUMBER
  ,emp_contr_reimb_spcl_base      NUMBER
  ,emp_contr_spcl_pct_base        NUMBER
  ,emp_contr_spcl_pct             NUMBER
  ,emp_contr_spcl                 NUMBER
  ,pension                 t_ni_zones_rec
  ,emp_contr               t_ni_zones_rec
  ,emp_contr_over62        t_ni_zones_rec);
 --
 TYPE t_le_si_bal_table IS TABLE OF t_le_si_bal_rec INDEX BY BINARY_INTEGER;
 --
 TYPE fixed_code_rec IS RECORD (fixed_code       VARCHAR2(20)
                               ,status           NUMBER
			       ,Amount_Value     VARCHAR2(50)
			       ,Addl_Value       VARCHAR2(50)
			       ,displayed        NUMBER);
 --
 TYPE fixed_code     IS TABLE OF  fixed_code_rec INDEX BY BINARY_INTEGER;
 --
 TYPE code_616_rec   IS RECORD (TRN       VARCHAR2(60)
                               ,Country   VARCHAR2(60)
                               ,Pay_Value NUMBER
                               ,Days      NUMBER
                               ,Per_Diem  NUMBER);
 --
 TYPE code_616       IS TABLE OF  code_616_rec   INDEX BY BINARY_INTEGER;
 --
 TYPE summary_code_orid_rec IS RECORD (orid_value       VARCHAR2(50)
                                       ,info_data         VARCHAR2(100)
			               ,info_prompt       VARCHAR2(100)
			               ,info_datatype      VARCHAR2(50));
 --
 TYPE summary_code_orid     IS TABLE OF  summary_code_orid_rec INDEX BY BINARY_INTEGER;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Global variables.
 -- -----------------------------------------------------------------------------
 --
 g_xml_element_table     t_xml_element_table;
 g_empty_rep_code_rec    t_rep_code_rec;
 g_empty_rep_code_table  t_rep_code_table;
 g_empty_le_si_bal_table t_le_si_bal_table;
 g_fixed_code            fixed_code;
 g_summary_code_orid     summary_code_orid;
 g_payroll_action_id     NUMBER;
 g_business_group_id     NUMBER;
 g_legal_employer_id     NUMBER;
 g_report_date           DATE;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Localisation delivered support for extracting specific reporting codes.
 --
 -- Needs to call the procedure with following parameter:-
 --
 -- Procedure XYZ
 --  (p_assignment_action_id   IN NUMBER
 --  ,p_reporting_code         IN VARCHAR2
 --  ,p_report_date            IN DATE);
 --
 -- Needs to populate the archive as follows:-
 --
 --  pay_action_information_api.create_action_information
 --  (p_action_context_type         => 'AAP'
 --  ,p_action_context_id           => p_assignment_action_id
 --  ,p_action_information_id       => l_act_inf_id
 --  ,p_object_version_number       => l_ovn
 --  ,p_effective_date              => p_report_date
 --  ,p_action_information_category => 'EMEA REPORT INFORMATION'
 --  ,p_action_information1         => 'ASG_REP_CODE_INFO'
 --  ,p_action_information2         => p_reporting_code
 --  ,p_action_information3         => <amount>
 --  ,p_action_information4         => <info1>
 --  ,p_action_information5         => <info2>
 --  ,p_action_information6         => <info3>
 --  ,p_action_information7         => <info4>
 --  ,p_action_information8         => <info5>
 --  ,p_action_information9         => <info6>
 --  ,p_action_information10        => <Seaman Component status>
 --  ,p_action_information11         => <info7>		--2009 changes
 --  ,p_action_information12         => <info8>		--2009 changes
 --  ,p_action_information13         => <info9>		--2009 changes
 --  ,p_action_information14         => <info10>	--2009 changes
 --);
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE extract_reporting_code
 (p_assignment_action_id IN NUMBER
 ,p_reporting_code       IN VARCHAR2
 ,p_report_date          IN DATE) IS
  --
  l_act_inf_id NUMBER;
  l_ovn        NUMBER;
  --
 BEGIN
  NULL;
 END extract_reporting_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Localisation delivered support for collating specific reporting codes.
 --
 -- Needs to call the procedure with following parameter:-
 --
 -- PROCEDURE collate_reporting_code
 -- (p_payroll_action_id IN NUMBER
 -- ,p_legal_employer_id IN VARCHAR2
 -- ,p_reporting_code    IN VARCHAR2) IS
 --
 --
 -- Cursor to retrieve reporting code informastion to be collated:-
 --
 --  CURSOR csr_REPORTING_CODES
 --          (p_payroll_action_id IN NUMBER
 --          ,p_legal_employer_id IN VARCHAR2
 --         ,p_reporting_code    IN VARCHAR2) IS
 --   SELECT asg_act.action_information5  person_id
 --         ,asg_act.action_information6  tax_municipality
 --         ,TO_NUMBER(rep_cde.action_information3)  amount
 --   FROM   pay_assignment_actions paa
 --         ,pay_action_information asg_act
 --         ,pay_action_information rep_cde
 --   WHERE  paa.payroll_action_id               = p_payroll_action_id
 --     AND  asg_act.action_context_type         = 'AAP'
 --     AND  asg_act.action_context_id           = paa.assignment_action_id
 --     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
 --     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
 --     AND  asg_act.action_information2         = p_legal_employer_id
 --     AND  rep_cde.action_context_type         = 'AAP'
 --     AND  rep_cde.action_context_id           = asg_act.action_context_id
 --     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
 --     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
 --     AND  rep_cde.action_information2         = p_reporting_code;
 --
 -- Needs to populate the archive as follows:-
 --
 --  pay_action_information_api.create_action_information
 --  (p_action_context_type         => 'PA'
 --  ,p_action_context_id           => p_payroll_action_id
 --  ,p_action_information_id       => l_act_inf_id
 --  ,p_object_version_number       => l_ovn
 --  ,p_effective_date              => p_report_date
 --  ,p_action_information_category => 'EMEA REPORT INFORMATION'
 --  ,p_action_information1         => 'AUDIT_REP_SUMMARY'
 --  ,p_action_information2         => p_legal_employer_id
 --  ,p_action_information3         => <person ID>
 --  ,p_action_information4         => p_reporting_code
 --  ,p_action_information5         => <amount>
 --  ,p_action_information6         => <info1>
 --  ,p_action_information7         => <info2>
 --  ,p_action_information8         => <info3>
 --  ,p_action_information9         => <info4>
 --  ,p_action_information10        => <info5>
 --  ,p_action_information11        => <info6>
 --  ,p_action_information12        => <tax_municipality>
 --  ,p_action_information13        => <Seaman Component status>
 --  ,p_action_information14        => <info7>		--2009 changes
 --  ,p_action_information15        => <info8>		--2009 changes
 --  ,p_action_information16        => <info9>		--2009 changes
 --  ,p_action_information17        => <info10>		--2009 changes
 --);
 -- -----------------------------------------------------------------------------
 --

 PROCEDURE collate_reporting_code
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR2) IS
  --
  l_act_inf_id NUMBER;
  l_ovn        NUMBER;
  --
 BEGIN
  NULL;
 END collate_reporting_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Get the correct characterset for XML generation
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE set_currency_mask(p_business_group_id  IN NUMBER
                             ,lg_format_mask      OUT NOCOPY VARCHAR2) IS
  -- Cursor to retrieve Currency
    CURSOR csr_currency IS
    SELECT org_information10
    FROM   hr_organization_information
    WHERE  organization_id = p_business_group_id
    AND    org_information_context = 'Business Group Information';
    --
    l_currency VARCHAR2(40);
    --
  BEGIN
  --
    OPEN csr_currency;
    FETCH csr_currency into l_currency;
    CLOSE csr_currency;
    --
    lg_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);
    lg_format_mask := nvl (lg_format_mask,'FM9G999G999G999G990D00');
    --
  EXCEPTION WHEN OTHERS THEN
    lg_format_mask := nvl (lg_format_mask,'FM9G999G999G999G990D00');
    --
 END set_currency_mask;
 --
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
--  l_xml_element_template0 VARCHAR2(20) := '<TAG>VALUE</TAG>';
--  l_xml_element_template1 VARCHAR2(30) := '<TAG><![CDATA[VALUE]]></TAG>';
--  l_xml_element_template2 VARCHAR2(10) := '<TAG>';
--  l_xml_element_template3 VARCHAR2(10) := '</TAG>';
  l_str1                  VARCHAR2(80) ;
  l_str2                  VARCHAR2(20) := '</EOY> </ROOT>';
  l_xml_element           VARCHAR2(800);
  l_clob                  CLOB;
  --
 BEGIN
  --
--  l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT> <EOY>';
  -- l_str1 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?> <ROOT> <EOY>';
  l_str1 := '<?xml version="1.0" encoding="' || get_IANA_charset || '"?>' ;

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
      IF g_xml_element_table(table_counter).tagattrb IS NOT NULL THEN
      l_xml_element := '<' || g_xml_element_table(table_counter).tagname || ' '
                         || g_xml_element_table(table_counter).tagattrb ||'>';
       ELSE
       l_xml_element := '<' || g_xml_element_table(table_counter).tagname || '>';
       END IF;

    ELSIF g_xml_element_table(table_counter).tagvalue = '_END_' THEN
     l_xml_element := '</' || g_xml_element_table(table_counter).tagname || '>';

    ELSIF g_xml_element_table(table_counter).tagattrb IS NOT NULL THEN
       IF g_xml_element_table(table_counter).tagtype IS NULL THEN
       l_xml_element := '<' || g_xml_element_table(table_counter).tagname  || ' '
                          || g_xml_element_table(table_counter).tagattrb ||
                      '><![CDATA[' || g_xml_element_table(table_counter).tagvalue ||
                      ']]></' || g_xml_element_table(table_counter).tagname || '>';

       ELSIF g_xml_element_table(table_counter).tagtype = 'A' THEN
      l_xml_element := '<' || g_xml_element_table(table_counter).tagname || ' '
                          || g_xml_element_table(table_counter).tagattrb ||
                      '>' || g_xml_element_table(table_counter).tagvalue ||
                      '</'|| g_xml_element_table(table_counter).tagname || '>';
       END IF;

     ELSIF g_xml_element_table(table_counter).tagattrb IS NULL THEN
     l_xml_element := '<' || g_xml_element_table(table_counter).tagname ||
                      '><![CDATA[' || g_xml_element_table(table_counter).tagvalue ||
                     ']]></' || g_xml_element_table(table_counter).tagname || '>';


    END IF;
    --
    dbms_lob.writeappend(l_clob, LENGTH(l_xml_element), l_xml_element);
   --
   END LOOP;
  --
  END IF;
  --
  -- dbms_lob.writeappend(l_clob, LENGTH(l_str2), l_str2);
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
 -- Parse out parameters from string.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_parameter
 (p_parameter_string IN VARCHAR2
 ,p_token            IN VARCHAR) RETURN VARCHAR2 IS
  --
  l_parameter pay_payroll_actions.legislative_parameters%TYPE := NULL;
  l_start_pos NUMBER;
  l_delimiter VARCHAR2(1) := ' ';
  --
 BEGIN
  l_start_pos := INSTR(' ' || p_parameter_string, l_delimiter || p_token || '=');
  --
  IF l_start_pos = 0 THEN
   l_delimiter := '|';
   l_start_pos := INSTR(' ' || p_parameter_string, l_delimiter || p_token || '=');
  END IF;
  --
  IF l_start_pos <> 0 THEN
   l_start_pos := l_start_pos + LENGTH(p_token || '=');
   l_parameter := SUBSTR(p_parameter_string, l_start_pos, INSTR(p_parameter_string || ' ', l_delimiter, l_start_pos) - l_start_pos);
  END IF;
  --
  RETURN l_parameter;
 END;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the prompt for a given information item.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_info_prompt
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR2
 ,p_info_id           IN VARCHAR2) RETURN VARCHAR2 IS
  --
  CURSOR csr_INFO_DTLS
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_reporting_code    IN VARCHAR2
          ,p_info_id           IN VARCHAR2) IS
   SELECT inf_dtl.action_information5 prompt
   FROM   pay_action_information inf_dtl
   WHERE  inf_dtl.action_context_type         = 'PA'
     AND  inf_dtl.action_context_id           = p_payroll_action_id
     AND  inf_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  inf_dtl.action_information1         = 'REP_CODE_INFO_DTLS'
     AND  inf_dtl.action_information2         = p_legal_employer_id
     AND  inf_dtl.action_information3         = p_reporting_code
     AND  inf_dtl.action_information4         = p_info_id;
  --
  l_inf_dtl_rec csr_INFO_DTLS%ROWTYPE;
  --
 BEGIN
  OPEN  csr_INFO_DTLS
         (p_payroll_action_id
         ,p_legal_employer_id
         ,p_reporting_code
         ,p_info_id);
  FETCH csr_INFO_DTLS INTO l_inf_dtl_rec;
  CLOSE csr_INFO_DTLS;
  --
  RETURN l_inf_dtl_rec.prompt;
 END get_info_prompt;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the datatype for a given information item.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_info_dtype
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR
 ,p_info_id           IN VARCHAR2) RETURN VARCHAR2 IS
  --
  CURSOR csr_INFO_DTLS
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_reporting_code    IN VARCHAR
          ,p_info_id           IN VARCHAR2) IS
   SELECT inf_dtl.action_information6 datatype
   FROM   pay_action_information inf_dtl
   WHERE  inf_dtl.action_context_type         = 'PA'
     AND  inf_dtl.action_context_id           = p_payroll_action_id
     AND  inf_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  inf_dtl.action_information1         = 'REP_CODE_INFO_DTLS'
     AND  inf_dtl.action_information2         = p_legal_employer_id
     AND  inf_dtl.action_information3         = p_reporting_code
     AND  inf_dtl.action_information4         = p_info_id;
  --
  l_inf_dtl_rec csr_INFO_DTLS%ROWTYPE;
  --
 BEGIN
  OPEN  csr_INFO_DTLS
         (p_payroll_action_id
         ,p_legal_employer_id
         ,p_reporting_code
         ,p_info_id);
  FETCH csr_INFO_DTLS INTO l_inf_dtl_rec;
  CLOSE csr_INFO_DTLS;
  --
  RETURN l_inf_dtl_rec.datatype;
 END get_info_dtype;
 --
 --
 -- -- -----------------------------------------------------------------------------
 -- Returns the XML-ORID for a given information item. Changes 2007-08
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_xml_orid
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR
 ,p_info_id           IN VARCHAR2) RETURN VARCHAR2 IS
  --
  CURSOR csr_XML_DTLS
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_reporting_code    IN VARCHAR
          ,p_info_id           IN VARCHAR2) IS
   SELECT inf_dtl.action_information8 xml_orid
   FROM   pay_action_information inf_dtl
   WHERE  inf_dtl.action_context_type         = 'PA'
     AND  inf_dtl.action_context_id           = p_payroll_action_id
     AND  inf_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  inf_dtl.action_information1         = 'REP_CODE_INFO_DTLS'
     AND  inf_dtl.action_information2         = p_legal_employer_id
     AND  inf_dtl.action_information3         = p_reporting_code
     AND  inf_dtl.action_information4         = p_info_id;
  --
  l_xml_dtl_rec csr_XML_DTLS%ROWTYPE;
  --
 BEGIN
  OPEN  csr_XML_DTLS
         (p_payroll_action_id
         ,p_legal_employer_id
         ,p_reporting_code
         ,p_info_id);
  FETCH csr_XML_DTLS INTO l_xml_dtl_rec;
  CLOSE csr_XML_DTLS;
  --
  RETURN l_xml_dtl_rec.xml_orid;
 END get_xml_orid;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the description for a given reporting code.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_code_desc
 (p_payroll_action_id IN NUMBER
 ,p_legal_employer_id IN VARCHAR2
 ,p_reporting_code    IN VARCHAR) RETURN VARCHAR2 IS
  --
  CURSOR csr_CODE_DTLS
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_reporting_code    IN VARCHAR) IS
   SELECT inf_dtl.action_information11 description
   FROM   pay_action_information inf_dtl
   WHERE  inf_dtl.action_context_type         = 'PA'
     AND  inf_dtl.action_context_id           = p_payroll_action_id
     AND  inf_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  inf_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  inf_dtl.action_information2         = p_legal_employer_id
     AND  inf_dtl.action_information3         = p_reporting_code;
  --
  l_cde_dtl_rec csr_CODE_DTLS%ROWTYPE;
  --
 BEGIN
  OPEN  csr_CODE_DTLS
         (p_payroll_action_id
         ,p_legal_employer_id
         ,p_reporting_code);
  FETCH csr_CODE_DTLS INTO l_cde_dtl_rec;
  CLOSE csr_CODE_DTLS;
  --
  RETURN l_cde_dtl_rec.description;
 END get_code_desc;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns TRUE If the primary classification of the element is Earnings Adjustment
 -- -----------------------------------------------------------------------------
 --
 --
  FUNCTION is_EA_classification (l_element_type_id  IN NUMBER
                                ,l_report_date      IN DATE)
  RETURN BOOLEAN AS
  --
  l_classification pay_element_classifications.classification_name%TYPE;
  --
  BEGIN
  --
  SELECT pec.classification_name
  INTO   l_classification
  FROM   pay_element_classifications pec
        ,pay_element_types_f         pet
  WHERE  pet.element_type_id   = l_element_type_id
   AND   pec.classification_id = pet.classification_id
   AND   l_report_date         BETWEEN pet.effective_start_date
                               AND     pet.effective_end_date;
   --
   IF l_classification = 'Earnings Adjustment' THEN RETURN TRUE;
                                               ELSE RETURN FALSE;
   END IF;
  END is_EA_classification;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns Y if Person is employed throughout the year in same Tax Unit
 -- -----------------------------------------------------------------------------
 --
 --
  FUNCTION employed_throughout_year ( p_person_id        IN NUMBER
                                     ,p_legal_empoyer_id IN NUMBER
                                     ,p_effective_date   IN DATE )
  RETURN VARCHAR2 AS
  --
   CURSOR csr_asg_contribution is
    SELECT paf.assignment_id
          ,greatest( trunc(p_effective_date,'Y'), paf.effective_start_date) start_date
          ,least( p_effective_date, paf.effective_end_date) end_date
    FROM   per_all_assignments_f       paf
          ,hr_soft_coding_keyflex      sck
          ,hr_organization_information hoi
          ,per_assignment_status_types pas
    WHERE  paf.person_id                 = p_person_id
    AND    sck.soft_coding_keyflex_id    = paf.soft_coding_keyflex_id
    AND    pas.assignment_status_type_id = paf.assignment_status_type_id
    AND    pas.user_status               = 'Active Assignment'
    AND    hoi.org_information_context   = 'NO_LOCAL_UNITS'
    AND    hoi.org_information1          = sck.segment2
    AND    hoi.organization_id           = p_legal_empoyer_id
    AND    ((paf.effective_start_date BETWEEN trunc(p_effective_date,'Y') and p_effective_date
           OR paf.effective_end_date  BETWEEN trunc(p_effective_date,'Y') and p_effective_date)
           OR (trunc(p_effective_date,'Y') > paf.effective_start_date
              AND p_effective_date < paf.effective_end_date))
    ORDER BY paf.effective_start_date;
  --
    l_asg_end_date        per_all_assignments_f.effective_end_date%TYPE;
    l_first_flag          NUMBER;
    --
    rec_asg_contribution  csr_asg_contribution%ROWTYPE;
  --
  BEGIN
    --
    l_first_flag := 0;

    fnd_file.put_line(fnd_file.log, 'p_person_id'||p_person_id);
    --
    OPEN  csr_asg_contribution;
    LOOP
    --
      FETCH csr_asg_contribution INTO rec_asg_contribution;
      IF csr_asg_contribution%NOTFOUND THEN
        --
        CLOSE csr_asg_contribution;

        --
        IF l_first_flag <> 0 AND l_asg_end_date >= p_effective_date THEN

          RETURN ('Y');
        --
        ELSE

          RETURN ('N');
        --
        END IF;
      --
      END IF;
      --
      IF l_first_flag = 0 THEN
      --
        l_first_flag := 1;
        l_asg_end_date := rec_asg_contribution.end_date;
        --
        IF trunc(p_effective_date,'Y') < rec_asg_contribution.start_date THEN
        --
          CLOSE csr_asg_contribution;

          RETURN ('N');
        --
        END IF;
	--
      END IF;
      --
      IF rec_asg_contribution.start_date > (l_asg_end_date + 1)  THEN
        --
        CLOSE csr_asg_contribution;
	fnd_file.put_line(fnd_file.log,'Pos 4');
        RETURN ('N');
        --
      END IF;
      --
      l_asg_end_date := greatest(l_asg_end_date, rec_asg_contribution.end_date);
      --
      IF l_asg_end_date >= p_effective_date THEN
        --
        CLOSE csr_asg_contribution;
	fnd_file.put_line(fnd_file.log,'Pos 5');
        RETURN ('Y');
      --
      END IF;
      --
    END LOOP;
    --
  END employed_throughout_year;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns Dates / Days for Non-Continuous Employment
 -- -----------------------------------------------------------------------------
 --
 --
 FUNCTION employed_period(p_person_id        IN NUMBER
                         ,p_legal_empoyer_id IN NUMBER
                         ,p_effective_date   IN DATE)
  RETURN VARCHAR2 AS
  --
   CURSOR csr_asg_contribution is
    SELECT greatest( trunc(p_effective_date,'Y'), paf.effective_start_date) start_date
          ,least( p_effective_date, paf.effective_end_date) end_date
    FROM   per_all_assignments_f       paf
          ,hr_soft_coding_keyflex      sck
          ,hr_organization_information hoi
          ,per_assignment_status_types pas
    WHERE  paf.person_id                 = p_person_id
    AND    sck.soft_coding_keyflex_id    = paf.soft_coding_keyflex_id
    AND    pas.assignment_status_type_id = paf.assignment_status_type_id
    AND    pas.user_status               = 'Active Assignment'
    AND    hoi.org_information_context   = 'NO_LOCAL_UNITS'
    AND    hoi.org_information1          = sck.segment2
    AND    hoi.organization_id           = p_legal_empoyer_id
    AND    ((paf.effective_start_date BETWEEN trunc(p_effective_date,'Y') and p_effective_date
           OR paf.effective_end_date  BETWEEN trunc(p_effective_date,'Y') and p_effective_date)
           OR (trunc(p_effective_date,'Y') > paf.effective_start_date
              AND p_effective_date < paf.effective_end_date))
    ORDER BY paf.effective_start_date;
    --
    l_asg_start_date per_all_assignments_f.effective_start_date%TYPE;
    l_asg_end_date   per_all_assignments_f.effective_end_date%TYPE;
    l_first_flag     NUMBER;
    l_days           NUMBER;
    --
    rec_asg_contribution  csr_asg_contribution%ROWTYPE;
  --
  BEGIN
  --
  l_first_flag := 0;
  l_days       := 0;
  --
  OPEN  csr_asg_contribution;
  LOOP
  --
    FETCH csr_asg_contribution INTO rec_asg_contribution;
    --
    IF csr_asg_contribution%NOTFOUND THEN
    --
      CLOSE csr_asg_contribution;
      --
      IF l_days = 0 THEN
        Return to_char(l_asg_start_date,'DD/MON') || '-' || to_char(l_asg_end_date,'DD/MON');
      ELSE
        Return to_char(l_days + (l_asg_end_date - l_asg_start_date) + 1);
      END IF;
      --
    END IF;
    --
    IF l_first_flag = 0 THEN
    --
      l_first_flag :=1;
      l_asg_start_date := rec_asg_contribution.start_date;
      l_asg_end_date := rec_asg_contribution.end_date;
      --
    END IF;
    --
    -- Only dates have to be reported
    IF l_asg_end_date >= rec_asg_contribution.start_date THEN
      l_asg_end_date := greatest(rec_asg_contribution.end_date, l_asg_end_date);
    ELSE
      --  Only days have to be reported
      l_days := l_days + (l_asg_end_date - l_asg_start_date) + 1;
      l_asg_start_date := rec_asg_contribution.start_date;
      l_asg_end_date := rec_asg_contribution.end_date;
    END IF;
    --
  END LOOP;
  --
END employed_period;
 --
 -- -----------------------------------------------------------------------------
 -- Returns the defined balance ID for a given balance / balance dimension
 -- combination.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_defined_balance
 (p_business_group_id    IN NUMBER
 ,p_balance_name         IN VARCHAR2
 ,p_database_item_suffix IN VARCHAR) RETURN NUMBER IS
  --
  CURSOR csr_DEF_BAL
          (p_business_group_id    IN NUMBER
          ,p_balance_name         IN VARCHAR2
          ,p_database_item_suffix IN VARCHAR) IS
   SELECT db.defined_balance_id
   FROM   pay_defined_balances   db
         ,pay_balance_dimensions bd
         ,pay_balance_types      bt
   WHERE  bt.balance_name         = p_balance_name
     AND  ((bt.business_group_id IS NULL AND bt.legislation_code = 'NO') OR (bt.legislation_code IS NULL AND bt.business_group_id = p_business_group_id))
     AND  bd.database_item_suffix = p_database_item_suffix
     AND  ((bd.business_group_id IS NULL AND bd.legislation_code = 'NO') OR (bd.legislation_code IS NULL AND bd.business_group_id = p_business_group_id))
     AND  db.balance_type_id      = bt.balance_type_id
     AND  db.balance_dimension_id = bd.balance_dimension_id;
  --
  l_def_bal_rec csr_DEF_BAL%ROWTYPE;
  --
 BEGIN
  OPEN  csr_DEF_BAL
         (p_business_group_id
         ,p_balance_name
         ,p_database_item_suffix);
  FETCH csr_DEF_BAL INTO l_def_bal_rec;
  CLOSE csr_DEF_BAL;
  --
  RETURN l_def_bal_rec.defined_balance_id;
 END get_defined_balance;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the element type ID for a given element.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_element
 (p_business_group_id IN NUMBER
 ,p_element_name      IN VARCHAR2) RETURN NUMBER IS
  --
  CURSOR csr_ELEMENT
          (p_business_group_id IN NUMBER
          ,p_element_name      IN VARCHAR2) IS
   SELECT et.element_type_id
   FROM   pay_element_types_f et
   WHERE  et.element_name         = p_element_name
     AND  ((et.business_group_id IS NULL AND et.legislation_code = 'NO') OR (et.legislation_code IS NULL AND et.business_group_id = p_business_group_id));
  --
  l_element_rec csr_ELEMENT%ROWTYPE;
  --
 BEGIN
  OPEN  csr_ELEMENT
         (p_business_group_id
         ,p_element_name);
  FETCH csr_ELEMENT INTO l_element_rec;
  CLOSE csr_ELEMENT;
  --
  RETURN l_element_rec.element_type_id;
 END get_element;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns the global value for a given global.
 -- -----------------------------------------------------------------------------
 --
 FUNCTION get_global
 (p_effective_date IN DATE
 ,p_global_name    IN VARCHAR2) RETURN VARCHAR2 IS
  --
  CURSOR csr_GLOBAL
          (p_effective_date IN DATE
          ,p_global_name    IN VARCHAR2) IS
   SELECT glb.global_value
   FROM   ff_globals_f glb
   WHERE  glb.global_name      = p_global_name
     AND  glb.legislation_code = 'NO'
     AND  p_effective_date BETWEEN glb.effective_start_date
                               AND glb.effective_end_date;
  --
  l_global_rec csr_GLOBAL%ROWTYPE;
  --
 BEGIN
  OPEN  csr_GLOBAL
         (p_effective_date
         ,p_global_name);
  FETCH csr_GLOBAL INTO l_global_rec;
  CLOSE csr_GLOBAL;
  --
  RETURN l_global_rec.global_value;
 END get_global;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Returns organization details for a given organization.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_org_details
 (p_organization_id  IN NUMBER
 ,p_name            OUT NOCOPY VARCHAR2
 ,p_address_line1   OUT NOCOPY VARCHAR2
 ,p_address_line2   OUT NOCOPY VARCHAR2
 ,p_address_line3   OUT NOCOPY VARCHAR2
 ,p_postcode        OUT NOCOPY VARCHAR2
 ,p_postoffice      OUT NOCOPY VARCHAR2) IS
  --
  CURSOR csr_ORG_DETAILS
          (p_organization_id IN NUMBER) IS
   SELECT org.name
         ,loc.address_line_1
         ,loc.address_line_2
         ,loc.address_line_3
         ,loc.postal_code postcode
         ,UPPER(SUBSTR(hr_general.decode_lookup('NO_POSTAL_CODE', loc.postal_code)
                      ,INSTR(hr_general.decode_lookup('NO_POSTAL_CODE', loc.postal_code), ' ')  + 1))  postoffice
   FROM   hr_all_organization_units org
         ,hr_locations_all loc
   WHERE  org.organization_id = p_organization_id
     AND  loc.location_id (+) = org.location_id;
  --
  l_org_dtl_rec csr_ORG_DETAILS%ROWTYPE;
 BEGIN
  OPEN  csr_ORG_DETAILS
         (p_organization_id);
  FETCH csr_ORG_DETAILS INTO l_org_dtl_rec;
  CLOSE csr_ORG_DETAILS;
  --
  p_name          := l_org_dtl_rec.name;
  p_address_line1 := l_org_dtl_rec.address_line_1;
  p_address_line2 := l_org_dtl_rec.address_line_2;
  p_address_line3 := l_org_dtl_rec.address_line_3;
  p_postcode      := l_org_dtl_rec.postcode;
  p_postoffice    := l_org_dtl_rec.postoffice;
 END get_org_details;
  --
 --
 -- -----------------------------------------------------------------------------
 -- Returns person address for a given person ID.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_per_addr
 (p_person_id        IN NUMBER
 ,p_report_date      IN DATE
 ,p_address_line1   OUT NOCOPY VARCHAR2
 ,p_address_line2   OUT NOCOPY VARCHAR2
 ,p_address_line3   OUT NOCOPY VARCHAR2
 ,p_postcode        OUT NOCOPY VARCHAR2
 ,p_postoffice      OUT NOCOPY VARCHAR2) IS
  --
  CURSOR csr_PER_DETAILS
          (p_person_id   IN NUMBER
          ,p_report_date IN DATE) IS
   SELECT pa.address_line1 address_line_1
         ,pa.address_line2 address_line_2
		 ,pa.address_line3 address_line_3
		 ,pa.postal_code   postcode
		 ,decode(pa.style,'NO',substr(hr_general.decode_lookup('NO_POSTAL_CODE',pa.postal_code),
	      instr(hr_general.decode_lookup('NO_POSTAL_CODE',pa.postal_code),' ')+1),'NO_GLB',pa.town_or_city) postoffice
    FROM  per_addresses     pa
    WHERE pa.person_id      = p_person_id
    AND   pa.primary_flag   = 'Y'
    AND   pa.style          IN ('NO', 'NO_GLB')
    AND   p_report_date     BETWEEN   pa.date_from
                            AND       nvl(pa.date_to,to_date('31-12-4712','DD-MM-YYYY'));
  --
  l_per_dtl_rec csr_PER_DETAILS%ROWTYPE;
 BEGIN
  OPEN  csr_PER_DETAILS
         (p_person_id
         ,p_report_date);
  FETCH csr_PER_DETAILS INTO l_per_dtl_rec;
  CLOSE csr_PER_DETAILS;
  --
  p_address_line1 := l_per_dtl_rec.address_line_1;
  p_address_line2 := l_per_dtl_rec.address_line_2;
  p_address_line3 := l_per_dtl_rec.address_line_3;
  p_postcode      := l_per_dtl_rec.postcode;
  p_postoffice    := l_per_dtl_rec.postoffice;
 END get_per_addr;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Sets all legislative parameters as global variables for future use.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE set_parameters
 (p_payroll_action_id IN NUMBER) IS
  --
  CURSOR csr_PARAMS
          (p_payroll_action_id IN NUMBER) IS
   SELECT business_group_id
         ,legislative_parameters
         ,pay_no_eoy_archive.get_parameter(legislative_parameters, 'LEGAL_EMPLOYER_ID') legal_employer_id
         ,fnd_date.canonical_to_date(pay_no_eoy_archive.get_parameter(legislative_parameters, 'DATE')) report_date
   FROM   pay_payroll_actions
   WHERE  payroll_action_id = p_payroll_action_id;
  --
  l_parameter_rec csr_PARAMS%ROWTYPE;
  --
 BEGIN
  OPEN  csr_PARAMS(p_payroll_action_id);
  FETCH csr_PARAMS INTO l_parameter_rec;
  CLOSE csr_PARAMS;
  --
  g_payroll_action_id := p_payroll_action_id;
  g_business_group_id := l_parameter_rec.business_group_id;
  g_legal_employer_id := l_parameter_rec.legal_employer_id;
  g_report_date       := l_parameter_rec.report_date;
 END set_parameters;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE range_code
 (p_payroll_action_id IN NUMBER
 ,p_sql               OUT NOCOPY VARCHAR2) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.range_code';
  --
  CURSOR csr_LEGEMP
          (p_business_group_id IN NUMBER
          ,p_legal_employer_id IN NUMBER) IS
   SELECT org.organization_id legal_employer_id
         ,org.name
         ,hoi2.org_information1 organization_number
         ,TO_NUMBER(hoi2.org_information5) tax_office_id
         ,hoi2.org_information2 tax_municipality
   FROM   hr_all_organization_units org
         ,hr_organization_information hoi1
         ,hr_organization_information hoi2
   WHERE  p_legal_employer_id IS NULL
     AND  org.business_group_id            = p_business_group_id
     AND  hoi1.organization_id             = org.organization_id
     AND  hoi1.org_information_context     = 'CLASS'
     AND  hoi1.org_information1            = 'HR_LEGAL_EMPLOYER'
     AND  hoi2.organization_id (+)         = hoi1.organization_id
     AND  hoi2.org_information_context (+) = 'NO_LEGAL_EMPLOYER_DETAILS'
   UNION ALL
   SELECT org.organization_id legal_employer_id
         ,org.name
         ,hoi1.org_information1 organization_number
         ,TO_NUMBER(hoi1.org_information5) tax_office_id
         ,hoi1.org_information2 tax_municipality
   FROM   hr_all_organization_units   org
         ,hr_organization_information hoi1
   WHERE  p_legal_employer_id IS NOT NULL
     AND  org.organization_id              = p_legal_employer_id
     AND  hoi1.organization_id (+)         = org.organization_id
     AND  hoi1.org_information_context (+) = 'NO_LEGAL_EMPLOYER_DETAILS';
  --
  -- Cursor to Extract  Other subsidis received (to reduce excemption limit),
  -- same as in bi-monthly recording sheet, but total for the year (2007/08 changes)
  --

  CURSOR csr_Legal_Emp_EA(csr_v_legal_emp_id  hr_organization_information.organization_id%TYPE
                         ,csr_v_business_group_id hr_organization_units.business_group_id%TYPE
                        ,p_report_date DATE) IS
 SELECT to_number(hoi2.org_information4) economic_aid
   FROM hr_organization_units o1
       ,hr_organization_information hoi1
       ,hr_organization_information hoi2
 WHERE o1.business_group_id         = csr_v_business_group_id
   AND hoi1.organization_id         = o1.organization_id
   AND hoi1.organization_id         = csr_v_legal_emp_id
   AND hoi1.org_information1        = 'HR_LEGAL_EMPLOYER'
   AND hoi1.org_information_context = 'CLASS'
   AND o1.organization_id           = hoi2.organization_id
   AND hoi2.org_information_context ='NO_NI_EXEMPTION_LIMIT'
   AND p_report_date     BETWEEN fnd_date.canonical_to_date(hoi2.org_information2)
                           AND fnd_date.canonical_to_date(hoi2.org_information3);
  --
  --

  CURSOR csr_REPCODE
          (p_report_date       IN DATE
          ,p_legal_employer_id IN NUMBER) IS
   SELECT r.row_low_range_or_name reporting_code
         ,hr_general.decode_lookup('NO_EOY_REPORTING_CODE',
          hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'MAPPING_ID')) description
         ,hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'FIXED_CODE') fixed_code
         ,hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'XML_CODE_MAP') XML_CODE           -- Added w.r.t phase2 Legislative changes for NORWAY for 2008
         ,hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'MULT_REC') mult_rec
         ,hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'REP_EARNINGS') reportable_earnings
         ,nvl(hoi.org_information4, hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'ASG_INFO_METH')) asg_info_meth
         ,nvl(DECODE(hoi.org_information4,'BAL', hoi.org_information5,'BAL_CODE_CTX', hoi.org_information5,'RRV_ELEMENT', hoi.org_information6,'PROCEDURE', hoi.org_information7),
          decode(hoi.org_information4,'RRV',NULL,hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'ASG_INFO_DFN'))) asg_info_dfn
         ,nvl(hoi.org_information14, hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'REP_SUMM_METH')) rep_summ_meth
         ,nvl(DECODE(hoi.org_information14,'PROCEDURE' , hoi.org_information15),
         decode(hoi.org_information14, 'PROCEDURE', hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'REP_SUMM_DFN'))) rep_summ_dfn
   FROM   pay_user_tables t
         ,pay_user_rows_f r
         ,hr_organization_information hoi
   WHERE  t.user_table_name        = 'NO_EOY_CODE_REPORTING_RULES'
     AND  t.legislation_code       = 'NO'
     AND  r.user_table_id          = t.user_table_id
     AND  r.row_low_range_or_name  = hoi.org_information3(+)
	 AND  hoi.organization_id(+)   = p_legal_employer_id
	 AND  hoi.org_information_context(+) = 'NO_EOY_REPORTING_RULE_OVERRIDE'
	 AND  to_number(to_char(p_report_date,'YYYY')) between to_number(hoi.org_information1(+))
                            AND to_number(nvl(hoi.org_information2,'4712'))
     AND  p_report_date BETWEEN r.effective_start_date
                            AND r.effective_end_date;
  --
  CURSOR csr_REPCODE_INFO
          (p_report_date       IN DATE
          ,p_reporting_code    IN VARCHAR2
          ,p_legal_employer_id IN NUMBER) IS
   SELECT SUBSTR(c.user_column_name, 1, INSTR(c.user_column_name, '_') - 1) info_id
         ,hr_general.decode_lookup('NO_EOY_INFO_PROMPTS', ci.value) prompt
       	 ,nvl(DECODE(SUBSTR(c.user_column_name, 1, INSTR(c.user_column_name, '_') - 1)
		             ,'INFO1',hoi.org_information8
		             ,'INFO2',hoi.org_information9
		             ,'INFO3',hoi.org_information10
		             ,'INFO4',hoi.org_information11
		             ,'INFO5',hoi.org_information12
		             ,'INFO6',hoi.org_information13
		             ,'INFO7',hoi.org_information14 -- 2009 changes
		             ,'INFO8',hoi.org_information15 -- 2009 changes
		             ,'INFO9',hoi.org_information16 -- 2009 changes
		             ,'INFO10',hoi.org_information17 -- 2009 changes
                     )
           ,hr_de_general.get_uci
            (p_report_date
            ,t.user_table_id
            ,r.user_row_id
            ,SUBSTR(c.user_column_name, 1, INSTR(c.user_column_name, '_') - 1) || '_ASG_INFO_DFN')) asg_info_dfn
    	 ,hr_de_general.get_uci
           (p_report_date
           ,t.user_table_id
           ,r.user_row_id
           ,SUBSTR(c.user_column_name, 1, INSTR(c.user_column_name, '_') - 1) || '_DATATYPE') datatype
	   ,hr_de_general.get_uci
           (p_report_date
           ,t.user_table_id
           ,r.user_row_id
           ,SUBSTR(c.user_column_name, 1, INSTR(c.user_column_name, '_') - 1) || '_XML_CODE_MAP') XML_VALUE_MAP --2007/08 changes
   FROM   pay_user_rows_f r
         ,pay_user_tables t
         ,pay_user_columns c
         ,pay_user_column_instances_f ci
         ,hr_organization_information hoi
   WHERE  t.user_table_name       = 'NO_EOY_CODE_REPORTING_RULES'
     AND  c.user_table_id         = t.user_table_id
     AND  r.user_table_id         = t.user_table_id
     AND  ci.user_row_id          = r.user_row_id
     AND  ci.user_column_id       = c.user_column_id
     AND  c.user_column_name      LIKE '%PROMPT'
     AND  r.row_low_range_or_name = p_reporting_code
	 AND  r.row_low_range_or_name = hoi.org_information3(+)
	 AND  hoi.organization_id(+)  = p_legal_employer_id
	 AND  hoi.org_information_context(+) = 'NO_EOY_REPORTING_RULE_OVERRIDE'
	 AND  to_number(to_char(p_report_date,'YYYY')) BETWEEN to_number(hoi.org_information1(+))
                            AND to_number(nvl(hoi.org_information2,'4712'))
     AND  p_report_date BETWEEN r.effective_start_date   AND r.effective_end_date
     AND  p_report_date BETWEEN ci.effective_start_date  AND ci.effective_end_date;
  --
  CURSOR csr_LE_SI_LU_TM_INFO
          (p_report_date       IN DATE
          ,p_business_group_id IN NUMBER
          ,p_legal_employer_id IN NUMBER) IS
   SELECT DISTINCT
          DECODE(orginf2.org_information5
                ,'Y', orginf2.org_information4
                ,orginf1.org_information3) si_status
         ,org2.organization_id local_unit_id
	     ,org2.name local_unit
         ,pac2.context_value tax_municipality_id
	     ,lu.meaning tax_municipality
         ,TO_NUMBER(decode(hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'ZONE'),'1a','6','4a','7',
	         hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'ZONE'))) ni_zone
--         ,TO_NUMBER(SUBSTR(lu.meaning, 1,1)) ni_zone
          ,DECODE(orginf2.org_information5,'Y', orginf2.org_information2,orginf1.org_information4) nace_code   -- 2007/08 changes
	  ,paa.assignment_id  assg_id        -- 2007/2008 Changes
   FROM   pay_assignment_actions paa
         ,pay_payroll_actions ppa
         ,pay_action_contexts pac1
         ,pay_action_contexts pac2
         ,ff_contexts ctx1
         ,ff_contexts ctx2
         ,hr_lookups lu
         ,hr_organization_information orginf1
         ,hr_all_organization_units org2
         ,hr_organization_information orginf2
         ,pay_user_tables t
         ,pay_user_rows_f r
   WHERE  ppa.business_group_id           = p_business_group_id
     AND  paa.payroll_action_id           = ppa.payroll_action_id
     AND  pac1.assignment_action_id       = paa.assignment_action_id
     AND  pac1.context_id                 = ctx1.context_id
     AND  ctx1.context_name               = 'LOCAL_UNIT_ID'
     AND  pac2.assignment_action_id       = paa.assignment_action_id
     AND  pac2.context_id                 = ctx2.context_id
     AND  ctx2.context_name               = 'JURISDICTION_CODE'
     AND  r.row_low_range_or_name         = pac2.context_value
     AND  t.user_table_name               = 'NO_TAX_MUNICIPALITY'
     AND  t.legislation_code              = 'NO'
     AND  r.user_table_id                 = t.user_table_id
     AND  lu.lookup_type                  = 'NO_TAX_MUNICIPALITY'
     AND  lu.lookup_code                  = hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'MAPPING_ID')
     AND  paa.tax_unit_id                 = p_legal_employer_id
     AND  org2.organization_id            = pac1.context_value
     AND  orginf1.organization_id         = paa.tax_unit_id
     AND  orginf1.org_information_context = 'NO_LEGAL_EMPLOYER_DETAILS'
     AND  orginf2.organization_id         = org2.organization_id
     AND  orginf2.org_information_context = 'NO_LOCAL_UNIT_DETAILS'
     AND  ppa.effective_date BETWEEN TRUNC(p_report_date, 'Y') AND p_report_date
     AND  p_report_date      BETWEEN r.effective_start_date    AND r.effective_end_date
   ORDER BY DECODE(orginf2.org_information5, 'Y', orginf2.org_information4, orginf1.org_information3)
           ,org2.organization_id;
  --
  CURSOR csr_GET_ASG_ACT_ID
          (p_report_date       IN DATE
          ,p_business_group_id IN NUMBER
          ,p_legal_employer_id IN NUMBER
	  ,p_assg_id           IN NUMBER) IS
   SELECT  max(paa.assignment_action_id)
    FROM   pay_payroll_actions    ppa
          ,pay_assignment_actions paa
    WHERE  ppa.business_group_id    = p_business_group_id
     AND   ppa.action_type          IN ('R','Q','I','B')
     AND   ppa.action_status        = 'C'
     AND   paa.payroll_action_id    = ppa.payroll_action_id
     AND   paa.assignment_id        = p_assg_id            -- changes 2007/2008
     AND   paa.tax_unit_id          = p_legal_employer_id
     AND   ppa.date_earned          BETWEEN TRUNC(p_report_date, 'Y') AND p_report_date;
  --
  l_act_inf_id                   NUMBER;
  l_ovn                          NUMBER;
  l_asg_act_id                   NUMBER;
  l_si_status                    VARCHAR2(30);
  l_local_unit_id                VARCHAR2(30);
  l_asg_info_dfn                 VARCHAR2(61);
  l_le_si_count                  NUMBER := 0;
  l_le_si_bal_table              t_le_si_bal_table;
  l_bal_value                    NUMBER := 0;
  l_le_name                      hr_all_organization_units.name%TYPE;
  l_le_addr1                     hr_locations_all.address_line_1%TYPE;
  l_le_addr2                     hr_locations_all.address_line_2%TYPE;
  l_le_addr3                     hr_locations_all.address_line_3%TYPE;
  l_le_postcode                  hr_locations_all.postal_code%TYPE;
  l_le_postoffice                VARCHAR2(100);
  l_to_name                      hr_all_organization_units.name%TYPE;
  l_to_addr1                     hr_locations_all.address_line_1%TYPE;
  l_to_addr2                     hr_locations_all.address_line_2%TYPE;
  l_to_addr3                     hr_locations_all.address_line_3%TYPE;
  l_to_postcode                  hr_locations_all.postal_code%TYPE;
  l_to_postoffice                VARCHAR2(100);
  l_ni_zone_arc                  VARCHAR2(10);
  l_tax_defbal_id                NUMBER := get_defined_balance(g_business_group_id, 'Tax', '_TU_LU_YTD');
  l_ec_spcl_pct_bse_defbal_id    NUMBER := get_defined_balance(g_business_group_id, 'Employer Contribution Special Percentage Base', '_TU_LU_YTD');
  l_ec_spcl_pct_defbal_id        NUMBER := get_defined_balance(g_business_group_id, 'Employer Contribution Special Percentage', '_TU_LU_YTD');
  l_ec_spcl_defbal_id            NUMBER := get_defined_balance(g_business_group_id, 'Employer Contribution Special', '_TU_LU_YTD');
  l_ec_defbal_id                 NUMBER := get_defined_balance(g_business_group_id, 'Employer Contribution Base', '_TU_MU_LU_YTD');
  l_eco62_defbal_id              NUMBER := get_defined_balance(g_business_group_id, 'Employer Contribution Over 62 Base', '_TU_MU_LU_YTD');
  -- Start Changes 2007/2008

  -- The Balance below are used to display for the new XML Requirements

  l_ec_spcl_reimb_bse_defbal_id  NUMBER := get_defined_balance(g_business_group_id, 'Employer Contribution Special Perc Benefit Reimbursed Base','_TU_LU_YTD');
  l_emp_pension_bse_defbal_id    NUMBER := get_defined_balance(g_business_group_id, 'Employers Pension Premium', '_TU_MU_LU_YTD');

  -- The six balance below will add up to give the Reimburse Base
  l_reimb_bse                    NUMBER := 0;
  l_emp_contr_bse                NUMBER := 0;
  l_pension_bse                  NUMBER := 0;
  l_tot_emp_contr_bse		 NUMBER := 0;
  l_tot_reimb_bse		 NUMBER := 0;
  l_tot_pension_bse              NUMBER := 0;
  l_sick_reimb_defbal_id         NUMBER := get_defined_balance(g_business_group_id, 'Sickness Benefit Reimbursed', '_TU_MU_LU_YTD');
  l_child_mind_reimb_defbal_id   NUMBER := get_defined_balance(g_business_group_id, 'Child Minder Sickness Benefit Reimbursed', '_TU_MU_LU_YTD');
  l_parent_reimb_defbal_id       NUMBER := get_defined_balance(g_business_group_id, 'Parental Benefit Reimbursed', '_TU_MU_LU_YTD');
  l_sick_hdy_reimb_defbal_id     NUMBER := get_defined_balance(g_business_group_id, 'Sickness Benefit Holiday Pay Reimbursed', '_TU_MU_LU_YTD');
  l_cld_sck_hdy_defbal_id        NUMBER := get_defined_balance(g_business_group_id, 'Child Minder Sickness Benefit Holiday Pay Reimbursed', '_TU_MU_LU_YTD');
  l_prnt_hdy_reimb_defbal_id     NUMBER := get_defined_balance(g_business_group_id, 'Parental Benefit Holiday Pay Reimbursed', '_TU_MU_LU_YTD');

  l_Legal_Emp_EA                 csr_Legal_Emp_EA%ROWTYPE;
  -- End Changes 2007/2008
  --
 BEGIN
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  --
  --
  -- Setup legislative parameters as global values for future use.
  --
  set_parameters(p_payroll_action_id);
  --
    Fnd_file.put_line(FND_FILE.LOG,'Inside Archive');

  -- Archive: EMEA REPORT DETAILS -> PYNOEOYA
  --
  pay_action_information_api.create_action_information
  (p_action_context_type         => 'PA'
  ,p_action_context_id           => p_payroll_action_id
  ,p_action_information_id       => l_act_inf_id
  ,p_object_version_number       => l_ovn
  ,p_effective_date              => g_report_date
  ,p_action_information_category => 'EMEA REPORT DETAILS'
  ,p_action_information1         => 'PYNOEOYA');
  --
  --
  -- Loop through all legal employers.
  --
  --
 -- Fnd_file.put_line(FND_FILE.LOG,'csr_LEGEMP g_business_group_id'||g_business_group_id);
 -- Fnd_file.put_line(FND_FILE.LOG,'csr_LEGEMP g_legal_employer_id'||g_legal_employer_id);
  FOR l_rec1 IN csr_LEGEMP(g_business_group_id, g_legal_employer_id) LOOP
   --
   --
   -- Get details for legal employer.
   --
   get_org_details
    (p_organization_id => l_rec1.legal_employer_id
    ,p_name            => l_le_name
    ,p_address_line1   => l_le_addr1
    ,p_address_line2   => l_le_addr2
    ,p_address_line3   => l_le_addr3
    ,p_postcode        => l_le_postcode
    ,p_postoffice      => l_le_postoffice);
   --
   --
   -- Get details for tax office.
   --
   get_org_details
    (p_organization_id => l_rec1.tax_office_id
    ,p_name            => l_to_name
    ,p_address_line1   => l_to_addr1
    ,p_address_line2   => l_to_addr2
    ,p_address_line3   => l_to_addr3
    ,p_postcode        => l_to_postcode
    ,p_postoffice      => l_to_postoffice);
   --
   --
   OPEN csr_Legal_Emp_EA( l_rec1.legal_employer_id,g_business_group_id,g_report_date) ;
     FETCH csr_Legal_Emp_EA INTO l_Legal_Emp_EA;
     CLOSE csr_Legal_Emp_EA;

   --
   -- Archive: EMEA REPORT INFORMATION | LEG_EMP_INFO
   --
   pay_action_information_api.create_action_information
   (p_action_context_type         => 'PA'
   ,p_action_context_id           => p_payroll_action_id
   ,p_action_information_id       => l_act_inf_id
   ,p_object_version_number       => l_ovn
   ,p_effective_date              => g_report_date
   ,p_action_information_category => 'EMEA REPORT INFORMATION'
   ,p_action_information1         => 'LEG_EMP_INFO'
   ,p_action_information2         => TO_CHAR(l_rec1.legal_employer_id)
   ,p_action_information3         => l_rec1.name
   ,p_action_information4         => l_rec1.organization_number
   ,p_action_information5         => l_le_addr1
   ,p_action_information6         => l_le_addr2
   ,p_action_information7         => l_le_addr3
   ,p_action_information8         => l_le_postcode
   ,p_action_information9         => l_le_postoffice
   ,p_action_information10        => l_to_name
   ,p_action_information11        => l_to_addr1
   ,p_action_information12        => l_to_addr2
   ,p_action_information13        => l_to_addr3
   ,p_action_information14        => l_to_postcode
   ,p_action_information15        => l_to_postoffice
   ,p_action_information16        => l_rec1.tax_municipality
   ,p_action_information17        => l_Legal_Emp_EA.economic_aid);    -- 2007/2008 Changes
   --
   l_le_si_bal_table := g_empty_le_si_bal_table;
   l_le_si_count := 0;
   l_si_status := '~';
   l_local_unit_id := '~';
   --

   -- Loop through all SI status, local unit, and tax municipality combinations for the legal employer.
   --
   FOR l_rec2 IN csr_LE_SI_LU_TM_INFO(g_report_date, g_business_group_id, l_rec1.legal_employer_id) LOOP
    --
    --
    -- Set balance contexts.
    --
    pay_balance_pkg.set_context('TAX_UNIT_ID', l_rec1.legal_employer_id);
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(g_report_date));
    pay_balance_pkg.set_context('LOCAL_UNIT_ID', l_rec2.local_unit_id);
    pay_balance_pkg.set_context('JURISDICTION_CODE', l_rec2.tax_municipality_id);
    --
    --
    -- Reset the values to Zero: changes 2007/2008
     l_reimb_bse     := 0;
     l_emp_contr_bse := 0;
     l_pension_bse   := 0 ;

    -- Moved on to a new SI status so initialise data structure.
    --
    IF NOT(l_si_status = l_rec2.si_status) THEN
     l_le_si_count := l_le_si_count + 1;
     l_le_si_bal_table(l_le_si_count).si_status := l_rec2.si_status;
     l_le_si_bal_table(l_le_si_count).tax := 0;
     l_le_si_bal_table(l_le_si_count).emp_contr_reimb_spcl_base := 0;
     l_le_si_bal_table(l_le_si_count).emp_contr_spcl_pct_base := 0;
     l_le_si_bal_table(l_le_si_count).emp_contr_spcl_pct := 0;
     l_le_si_bal_table(l_le_si_count).emp_contr_spcl := 0;
     FOR l_count IN 1..7 LOOP
      l_le_si_bal_table(l_le_si_count).pension.ni_zone(l_count) := 0;
      l_le_si_bal_table(l_le_si_count).emp_contr.ni_zone(l_count) := 0;
      l_le_si_bal_table(l_le_si_count).emp_contr_over62.ni_zone(l_count) := 0;
     END LOOP;
     l_le_si_bal_table(l_le_si_count).pension.total := 0;
     l_le_si_bal_table(l_le_si_count).emp_contr.total := 0;
     l_le_si_bal_table(l_le_si_count).emp_contr_over62.total := 0;
    END IF;
    --
    --
    -- Moved the call of the cursor outside the IF condition
    --
     OPEN csr_GET_ASG_ACT_ID(g_report_date, g_business_group_id, l_rec1.legal_employer_id, l_rec2.assg_id) ;  -- Changes  2007/2008
     FETCH csr_GET_ASG_ACT_ID INTO l_asg_act_id;
     CLOSE csr_GET_ASG_ACT_ID;
     --
     -- Find distinct SI status / local unit combinations as these will be used later to combine the totals for various reporting codes.
     --
     IF NOT(l_si_status = l_rec2.si_status AND l_local_unit_id = l_rec2.local_unit_id) THEN
     --
     --
     -- Archive: EMEA REPORT INFORMATION | LE_SI_LU_INFO
     --
     pay_action_information_api.create_action_information
     (p_action_context_type         => 'PA'
     ,p_action_context_id           => p_payroll_action_id
     ,p_action_information_id       => l_act_inf_id
     ,p_object_version_number       => l_ovn
     ,p_effective_date              => g_report_date
     ,p_action_information_category => 'EMEA REPORT INFORMATION'
     ,p_action_information1         => 'LE_SI_LU_INFO'
     ,p_action_information2         => TO_CHAR(l_rec1.legal_employer_id)
     ,p_action_information3         => l_rec2.si_status
     ,p_action_information4         => l_rec2.local_unit_id
     ,p_action_information5         => l_rec2.nace_code );           -- 2007-08 changes
     --
     -- Retrieve balances for:-
     --
     --  Tax_TU_LU_YTD
     --  Employer Contribution Special Percentage Base_TU_LU_YTD
     --  Employer Contribution Special Percentage_TU_LU_YTD
     --  Employer Contribution Special_TU_LU_YTD
     --
     --
     l_bal_value := pay_balance_pkg.get_value(p_defined_balance_id => l_tax_defbal_id, p_assignment_action_id => l_asg_act_id);
     l_le_si_bal_table(l_le_si_count).tax := l_le_si_bal_table(l_le_si_count).tax + l_bal_value;
     --
     l_bal_value := pay_balance_pkg.get_value(p_defined_balance_id => l_ec_spcl_pct_bse_defbal_id, p_assignment_action_id => l_asg_act_id);
     l_le_si_bal_table(l_le_si_count).emp_contr_spcl_pct_base := l_le_si_bal_table(l_le_si_count).emp_contr_spcl_pct_base + l_bal_value;
     --
     l_bal_value := pay_balance_pkg.get_value(p_defined_balance_id => l_ec_spcl_pct_defbal_id, p_assignment_action_id => l_asg_act_id);
     l_le_si_bal_table(l_le_si_count).emp_contr_spcl_pct := l_le_si_bal_table(l_le_si_count).emp_contr_spcl_pct + l_bal_value;
     --
     l_bal_value := pay_balance_pkg.get_value(p_defined_balance_id => l_ec_spcl_defbal_id, p_assignment_action_id => l_asg_act_id);
     l_le_si_bal_table(l_le_si_count).emp_contr_spcl := l_le_si_bal_table(l_le_si_count).emp_contr_spcl + l_bal_value;
     --

    END IF;
    --
     -- Start changes 2007/2008
     -- Special Reimburesd Base for US/Canada
     l_bal_value := pay_balance_pkg.get_value(p_defined_balance_id => l_ec_spcl_reimb_bse_defbal_id, p_assignment_action_id => l_asg_act_id);
     l_le_si_bal_table(l_le_si_count).emp_contr_reimb_spcl_base := l_le_si_bal_table(l_le_si_count).emp_contr_reimb_spcl_base + l_bal_value;
     --
     -- Employer Contribution Base
     --
     l_emp_contr_bse := pay_balance_pkg.get_value(p_defined_balance_id => l_ec_defbal_id, p_assignment_action_id => l_asg_act_id);
     l_tot_emp_contr_bse := nvl(l_tot_emp_contr_bse,0) + nvl(l_emp_contr_bse,0);
     --
     --  Reimbursed Base
     --
     l_reimb_bse := pay_balance_pkg.get_value(p_defined_balance_id  => l_sick_reimb_defbal_id
					    ,p_assignment_action_id => l_asg_act_id);
     l_reimb_bse := nvl(l_reimb_bse,0) + nvl(pay_balance_pkg.get_value(p_defined_balance_id   => l_child_mind_reimb_defbal_id
								      ,p_assignment_action_id => l_asg_act_id),0);
     l_reimb_bse := nvl(l_reimb_bse,0) + nvl(pay_balance_pkg.get_value(p_defined_balance_id   => l_parent_reimb_defbal_id
 					                              ,p_assignment_action_id => l_asg_act_id),0);
     l_reimb_bse := nvl(l_reimb_bse,0) + nvl(pay_balance_pkg.get_value(p_defined_balance_id   => l_sick_hdy_reimb_defbal_id
					                              ,p_assignment_action_id => l_asg_act_id),0);
     l_reimb_bse := nvl(l_reimb_bse,0) + nvl(pay_balance_pkg.get_value(p_defined_balance_id   => l_cld_sck_hdy_defbal_id
					                              ,p_assignment_action_id => l_asg_act_id),0);
     l_reimb_bse := nvl(l_reimb_bse,0) + nvl(pay_balance_pkg.get_value(p_defined_balance_id   => l_prnt_hdy_reimb_defbal_id
           				                              ,p_assignment_action_id => l_asg_act_id),0);
     --  Total of the Reimbursed bases for all the zones
     l_tot_reimb_bse := nvl(l_tot_reimb_bse,0) + nvl(l_reimb_bse,0);
     --
     -- Pension Base
     --
     l_pension_bse := pay_balance_pkg.get_value(p_defined_balance_id => l_emp_pension_bse_defbal_id , p_assignment_action_id => l_asg_act_id);

     l_tot_pension_bse := nvl(l_tot_pension_bse,0) + nvl(l_pension_bse,0);
     --
     -- End 2007/2008 changes
     --
    l_ni_zone_arc := NULL;
    --
    SELECT DECODE(l_rec2.ni_zone,6,'1a',7,'1a',l_rec2.ni_zone)
    INTO l_ni_zone_arc
    FROM DUAL;
    --
    --
    -- Archive: EMEA REPORT INFORMATION | LE_SI_LU_TM_INFO
    --
    pay_action_information_api.create_action_information
    (p_action_context_type         => 'PA'
    ,p_action_context_id           => p_payroll_action_id
    ,p_action_information_id       => l_act_inf_id
    ,p_object_version_number       => l_ovn
    ,p_effective_date              => g_report_date
    ,p_action_information_category => 'EMEA REPORT INFORMATION'
    ,p_action_information1         => 'LE_SI_LU_TM_INFO'
    ,p_action_information2         => TO_CHAR(l_rec1.legal_employer_id)
    ,p_action_information3         => l_rec2.si_status
    ,p_action_information4         => l_rec2.local_unit_id
    ,p_action_information5         => l_rec2.local_unit
    ,p_action_information6         => l_rec2.tax_municipality_id
    ,p_action_information7         => l_rec2.tax_municipality
    ,p_action_information8         => l_ni_zone_arc
    ,p_action_information9         => fnd_number.number_to_canonical(l_emp_contr_bse)  -- 2007/2008 changes
    ,p_action_information10        => fnd_number.number_to_canonical(l_reimb_bse)      -- 2007/2008 changes
    ,p_action_information11        => fnd_number.number_to_canonical(l_pension_bse));  -- 2007/2008 Changes
    --

    -- Retrieve balances for:-
    --
    --  Employer Contribution Base_TU_MU_LU_YTD
    --  Employer Contribution Over 62 Base_TU_MU_LU_YTD
    --
    -- and add them into correct NI Zone.
    --
    l_bal_value := pay_balance_pkg.get_value(p_defined_balance_id => l_ec_defbal_id, p_assignment_action_id => l_asg_act_id);
    l_le_si_bal_table(l_le_si_count).emp_contr.ni_zone(l_rec2.ni_zone) :=
      l_le_si_bal_table(l_le_si_count).emp_contr.ni_zone(l_rec2.ni_zone) + l_bal_value;
    l_le_si_bal_table(l_le_si_count).emp_contr.total :=
      l_le_si_bal_table(l_le_si_count).emp_contr.total + l_bal_value;
    --
    l_bal_value := pay_balance_pkg.get_value(p_defined_balance_id => l_eco62_defbal_id, p_assignment_action_id => l_asg_act_id);
    l_le_si_bal_table(l_le_si_count).emp_contr_over62.ni_zone(l_rec2.ni_zone) :=
    l_le_si_bal_table(l_le_si_count).emp_contr_over62.ni_zone(l_rec2.ni_zone) + l_bal_value;
    l_le_si_bal_table(l_le_si_count).emp_contr_over62.total :=
    l_le_si_bal_table(l_le_si_count).emp_contr_over62.total + l_bal_value;
    --
    l_si_status := l_rec2.si_status;
    l_local_unit_id := l_rec2.local_unit_id;
   END LOOP;
   --
   -- Loop through all legal employer / SI status records and write them out to archive.
   --
   IF l_le_si_bal_table.count > 0 THEN
   FOR l_count2 IN l_le_si_bal_table.FIRST .. l_le_si_bal_table.LAST LOOP
    --
    --
    -- Archive: EMEA REPORT INFORMATION | LE_SI_BALS
    --
    pay_action_information_api.create_action_information
    (p_action_context_type         => 'PA'
    ,p_action_context_id           => p_payroll_action_id
    ,p_action_information_id       => l_act_inf_id
    ,p_object_version_number       => l_ovn
    ,p_effective_date              => g_report_date
    ,p_action_information_category => 'EMEA REPORT INFORMATION'
    ,p_action_information1         => 'LE_SI_BALS'
    ,p_action_information2         => TO_CHAR(l_rec1.legal_employer_id)
    ,p_action_information3         => l_le_si_bal_table(l_count2).si_status
    ,p_action_information4         => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr.ni_zone(1))
    ,p_action_information5         => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr.ni_zone(2))
    ,p_action_information6         => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr.ni_zone(3))
    ,p_action_information7         => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr.ni_zone(4))
    ,p_action_information8         => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr.ni_zone(5))
    ,p_action_information9         => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr.total)
    ,p_action_information10        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_over62.ni_zone(1))
    ,p_action_information11        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_over62.ni_zone(2))
    ,p_action_information12        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_over62.ni_zone(3))
    ,p_action_information13        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_over62.ni_zone(4))
    ,p_action_information14        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_over62.ni_zone(5))
    ,p_action_information15        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_over62.total)
    ,p_action_information16        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).tax)
    ,p_action_information17        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_spcl_pct_base)
    ,p_action_information18        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_spcl_pct)
    ,p_action_information19        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_spcl)
    ,p_action_information20        => fnd_number.number_to_canonical(get_global(g_report_date, 'NO_NI_FOREIGN_SPECIAL_RATE'))
    ,p_action_information21        => fnd_number.number_to_canonical(get_global(g_report_date, 'NO_NI_FOREIGN_MARINER_AMOUNT'))
    ,p_action_information22        => fnd_number.number_to_canonical(l_le_si_bal_table(l_count2).emp_contr_reimb_spcl_base)  -- 2007/2008 changes
    ,p_action_information23        => fnd_number.number_to_canonical(l_tot_reimb_bse)       -- 2007/2008 changes
    ,p_action_information24        => fnd_number.number_to_canonical(l_tot_pension_bse));   -- 2007/2008 changes

   END LOOP;
   END IF;
   --
   --
   -- Loop through all reporting code rules NB. The rules may vary between legal employers.
   --
   FOR l_rec3 IN csr_REPCODE(g_report_date, l_rec1.legal_employer_id) LOOP
    --
    --
    -- Extract IDs where appropriate i.e. element type ID or defined balance ID.
    --
 --Fnd_file.put_line(FND_FILE.LOG,'$$ l_rec3.asg_info_dfn'||l_rec3.asg_info_dfn);
    IF l_rec3.asg_info_meth = 'BAL' THEN
     l_asg_info_dfn := TO_CHAR(get_defined_balance(g_business_group_id, l_rec3.asg_info_dfn, '_ASG_TU_MC_LU_YTD'));
    ELSIF l_rec3.asg_info_meth = 'BAL_CODE_CTX' THEN
     l_asg_info_dfn := TO_CHAR(get_defined_balance(g_business_group_id, l_rec3.asg_info_dfn, '_ASG_ELE_CODE_TU_MC_LU_YTD'));
    ELSIF l_rec3.asg_info_meth = 'RRV_ELEMENT' THEN
     l_asg_info_dfn := TO_CHAR(get_element(g_business_group_id, l_rec3.asg_info_dfn));
    ELSE
     l_asg_info_dfn := l_rec3.asg_info_dfn;
    END IF;
 --Fnd_file.put_line(FND_FILE.LOG,'$$ l_asg_info_dfn'||l_asg_info_dfn);
    --
    -- Archive: EMEA REPORT INFORMATION | REP_CODE_DTLS
    --
    pay_action_information_api.create_action_information
    (p_action_context_type         => 'PA'
    ,p_action_context_id           => p_payroll_action_id
    ,p_action_information_id       => l_act_inf_id
    ,p_object_version_number       => l_ovn
    ,p_effective_date              => g_report_date
    ,p_action_information_category => 'EMEA REPORT INFORMATION'
    ,p_action_information1         => 'REP_CODE_DTLS'
    ,p_action_information2         => TO_CHAR(l_rec1.legal_employer_id)
    ,p_action_information3         => l_rec3.reporting_code
    ,p_action_information4         => l_rec3.fixed_code
    ,p_action_information5         => l_rec3.mult_rec
    ,p_action_information6         => l_rec3.reportable_earnings
    ,p_action_information7         => l_rec3.asg_info_meth
    ,p_action_information8         => l_asg_info_dfn
    ,p_action_information9         => l_rec3.rep_summ_meth
    ,p_action_information10        => l_rec3.rep_summ_dfn
    ,p_action_information11        => l_rec3.description
    ,p_action_information12         => l_rec3.XML_CODE); -- 2007/2008 Changes
    --
    --
    -- Loop through all information columns for the reporting code.
    --
    FOR l_rec4 IN csr_REPCODE_INFO(g_report_date, l_rec3.reporting_code, l_rec1.legal_employer_id) LOOP
     --
     --
     -- Extract IDs where appropriate i.e. element type ID or defined balance ID.
     --
     IF    l_rec3.asg_info_meth = 'BAL' AND l_rec4.asg_info_dfn IS NOT NULL THEN
      l_asg_info_dfn := TO_CHAR(get_defined_balance(g_business_group_id, l_rec4.asg_info_dfn, '_ASG_TU_MC_LU_YTD'));
     ELSIF l_rec3.asg_info_meth = 'BAL_CODE_CTX' AND l_rec4.asg_info_dfn IS NOT NULL THEN
      l_asg_info_dfn := TO_CHAR(get_defined_balance(g_business_group_id, l_rec4.asg_info_dfn, '_ASG_ELE_CODE_TU_MC_LU_YTD'));
     ELSE
      l_asg_info_dfn := NULL;
     END IF;
     --
     --
     -- Archive: EMEA REPORT INFORMATION | REP_CODE_INFO_DTLS
     --
     pay_action_information_api.create_action_information
     (p_action_context_type         => 'PA'
     ,p_action_context_id           => p_payroll_action_id
     ,p_action_information_id       => l_act_inf_id
     ,p_object_version_number       => l_ovn
     ,p_effective_date              => g_report_date
     ,p_action_information_category => 'EMEA REPORT INFORMATION'
     ,p_action_information1         => 'REP_CODE_INFO_DTLS'
     ,p_action_information2         => TO_CHAR(l_rec1.legal_employer_id)
     ,p_action_information3         => l_rec3.reporting_code
     ,p_action_information4         => l_rec4.info_id
     ,p_action_information5         => l_rec4.prompt
     ,p_action_information6         => l_rec4.datatype
     ,p_action_information7         => l_asg_info_dfn
     ,p_action_information8          => l_rec4.XML_VALUE_MAP);   --2007/2008 changes
    END LOOP;
   END LOOP;
  END LOOP;
  --
  -- Set SQL to identify potential candidate people to process.
  --
  p_sql :=
  'SELECT   DISTINCT per.person_id
   FROM     per_people_f per
           ,pay_payroll_actions ppa
   WHERE    ppa.payroll_action_id = :payroll_action_id
     AND    per.business_group_id = ppa.business_group_id
   ORDER BY per.person_id';
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END range_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE assignment_action_code
 (p_payroll_action_id IN NUMBER
 ,p_start_person      IN NUMBER
 ,p_end_person        IN NUMBER
 ,p_chunk             IN NUMBER) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.assignment_action_code';
  --
  CURSOR csr_ASG
          (p_payroll_action_id IN NUMBER
          ,p_start_person      IN NUMBER
          ,p_end_person        IN NUMBER
          ,p_report_date       IN DATE) IS
   SELECT asg.person_id
         ,paa.assignment_id
         ,paa.tax_unit_id legal_employer_id
         ,TO_NUMBER(ac1.context_value) local_unit_id
         ,ac2.context_value tax_municipality
         ,ac3.context_value municipality_code
         ,hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'ZONE') ni_zone
         ,MAX(ppa.effective_date) effective_date
         ,MAX(asg.effective_end_date) effective_end_date
	 ,MAX(asg.effective_start_date) effective_start_date      --Changes 2007/2008
   FROM   per_all_assignments_f  asg
         ,pay_assignment_actions paa
         ,pay_payroll_actions    ppa
         ,pay_action_information ai
         ,pay_action_contexts    ac1
         ,ff_contexts            ctx1
         ,pay_action_contexts    ac2
         ,ff_contexts            ctx2
         ,pay_action_contexts    ac3
         ,ff_contexts            ctx3
         ,pay_user_tables        t
         ,pay_user_rows_f        r
   WHERE  asg.person_id BETWEEN p_start_person AND p_end_person
     AND  paa.assignment_id              = asg.assignment_id
     AND  ppa.payroll_action_id          = paa.payroll_action_id
     AND  ac1.assignment_action_id       = paa.assignment_action_id
     AND  ctx1.context_id                = ac1.context_id
     AND  ctx1.context_name              = 'LOCAL_UNIT_ID'
     AND  ac3.assignment_action_id       = paa.assignment_action_id
     AND  ctx3.context_id                = ac3.context_id
     AND  ctx3.context_name              = 'SOURCE_TEXT2'
     AND  ac2.assignment_action_id       = paa.assignment_action_id
     AND  ctx2.context_id                = ac2.context_id
     AND  ctx2.context_name              = 'JURISDICTION_CODE'
     AND  t.user_table_name              = 'NO_TAX_MUNICIPALITY'
     AND  t.legislation_code             = 'NO'
     AND  r.user_table_id                = t.user_table_id
     AND  r.row_low_range_or_name        = ac2.context_value
     AND  paa.tax_unit_id                = TO_NUMBER(ai.action_information2)
     AND  ai.action_context_type         = 'PA'
     AND  ai.action_context_id           = p_payroll_action_id
     AND  ai.action_information_category = 'EMEA REPORT INFORMATION'
     AND  ai.action_information1         = 'LEG_EMP_INFO'
     AND  ppa.effective_date BETWEEN TRUNC(p_report_date,'Y') AND p_report_date
     AND  p_report_date      BETWEEN r.effective_start_date   AND r.effective_end_date
   GROUP BY asg.person_id
           ,paa.assignment_id
           ,paa.tax_unit_id
           ,TO_NUMBER(ac1.context_value)
           ,ac2.context_value
           ,ac3.context_value
           ,hr_de_general.get_uci(p_report_date,t.user_table_id,r.user_row_id,'ZONE')
   ORDER BY asg.person_id
           ,MAX(ppa.effective_date) DESC;
  --
  CURSOR csr_PER
          (p_person_id      IN NUMBER
          ,p_effective_date IN DATE) IS
   SELECT per.full_name
         ,per.national_identifier
         ,per.employee_number
   FROM   per_all_people_f per
   WHERE  per.person_id = p_person_id
     AND  p_effective_date BETWEEN per.effective_start_date
                               AND per.effective_end_date;
  --
  l_assact_id                NUMBER;
  l_person_id                NUMBER := -1;
  l_act_inf_id               NUMBER;
  l_ovn                      NUMBER;
  l_bal_value                NUMBER;
  l_seaman_status            VARCHAR2(1) := 'N';
  l_per_addr1                per_addresses.address_line1%TYPE;
  l_per_addr2                per_addresses.address_line2%TYPE;
  l_per_addr3                per_addresses.address_line3%TYPE;
  l_per_postcode             per_addresses.postal_code%TYPE;
  l_per_postoffice           VARCHAR2(100);
  l_non_cont_dates_days      VARCHAR2(20);
  l_employed_throughout_year VARCHAR2(9);
  l_person_rec               csr_PER%ROWTYPE;
  l_seaman_defbal_id NUMBER := get_defined_balance(g_business_group_id, 'Seaman', '_PER_TU_YTD');
  l_employment_start_date   DATE;
  l_employment_end_date     DATE;
  --
 BEGIN
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  --
  --
  -- Setup legislative parameters as global values for future use.
  --
  set_parameters(p_payroll_action_id);
  --
  --
  -- Loop through all assignment, legal employer, local unit, tax municipality (ni zone) combinations for
  -- the legal employer.
  --
  FOR l_asg_rec IN csr_ASG(p_payroll_action_id, p_start_person, p_end_person, g_report_date) LOOP
   IF l_asg_rec.person_id <> l_person_id THEN
    --
    OPEN  csr_PER(l_asg_rec.person_id, l_asg_rec.effective_date);
    FETCH csr_PER INTO l_person_rec;
    CLOSE csr_PER;
    --
    pay_balance_pkg.set_context('TAX_UNIT_ID', l_asg_rec.legal_employer_id);
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(g_report_date));
     --
     --  Seaman_PER_TU_YTD
     --
    l_bal_value := pay_balance_pkg.get_value
                  (p_defined_balance_id => l_seaman_defbal_id
                  ,p_assignment_id      => l_asg_rec.assignment_id
                  ,p_virtual_date       => least(g_report_date,l_asg_rec.effective_end_date));
    --
    --
    l_seaman_status := 'N';
    --
    IF l_bal_value > 0 THEN
      l_seaman_status := 'Y';
    END IF;
    --
    -- Get the Person address
    --
    get_per_addr
     (p_person_id       => l_asg_rec.person_id
     ,p_report_date     => least(g_report_date, l_asg_rec.effective_end_date)
     ,p_address_line1   => l_per_addr1
     ,p_address_line2   => l_per_addr2
     ,p_address_line3   => l_per_addr3
     ,p_postcode        => l_per_postcode
     ,p_postoffice      => l_per_postoffice);
    --
    --
    --
    l_employed_throughout_year := employed_throughout_year(l_asg_rec.person_id
                                               , l_asg_rec.legal_employer_id, g_report_date);
    fnd_file.put_line(fnd_file.log,'l_employed_throughout_year:'||l_employed_throughout_year);
    l_non_cont_dates_days := NULL;
    --
    IF l_employed_throughout_year = 'N' THEN
    --
      l_non_cont_dates_days := employed_period (l_asg_rec.person_id
                                               ,l_asg_rec.legal_employer_id
                                               ,g_report_date);
    --
    END IF;
    --
    --Start Changes 2007/2008
     IF (to_char (l_asg_rec.effective_end_date, 'DD-MM-YYYY') ='31-12-4712') THEN
    --
        l_employment_end_date := NULL;
    ELSE
    --
      l_employment_end_date := l_asg_rec.effective_end_date;

    END IF;
    --
    l_employment_start_date := l_asg_rec.effective_start_date;
    --End  Changes 2007/2008

    -- Archive: EMEA REPORT INFORMATION | PER_INFO
    --
    pay_action_information_api.create_action_information
    (p_action_context_type         => 'PA'
    ,p_action_context_id           => p_payroll_action_id
    ,p_action_information_id       => l_act_inf_id
    ,p_object_version_number       => l_ovn
    ,p_effective_date              => g_report_date
    ,p_action_information_category => 'EMEA REPORT INFORMATION'
    ,p_action_information1         => 'PER_INFO'
    ,p_action_information2         => TO_CHAR(l_asg_rec.person_id)
    ,p_action_information3         => l_person_rec.full_name
    ,p_action_information4         => l_person_rec.employee_number
    ,p_action_information5         => l_person_rec.national_identifier
    ,p_action_information6         => hr_general.decode_lookup('YES_NO',l_employed_throughout_year)
    ,p_action_information7         => hr_general.decode_lookup('YES_NO',l_seaman_status)
    ,p_action_information8         => l_non_cont_dates_days
    ,p_action_information9         => l_per_addr1
    ,p_action_information10        => l_per_addr2
    ,p_action_information11        => l_per_addr3
    ,p_action_information12        => l_per_postcode
    ,p_action_information13        => l_per_postoffice
    ,p_action_information14        => l_employment_start_date    --Changes 2007/2008
    ,p_action_information15        => l_employment_end_date      --Changes 2007/2008
    );
   END IF;
   l_person_id := l_asg_rec.person_id;
   --
   --
   -- Create assignment action for archive process.
   --
   SELECT pay_assignment_actions_s.nextval INTO l_assact_id FROM dual;
   hr_nonrun_asact.insact
   (l_assact_id
   ,l_asg_rec.assignment_id
   ,p_payroll_action_id
   ,p_chunk
   ,NULL);
   --
   --
   -- Archive: EMEA REPORT INFORMATION | ASG_ACT_INFO
   --
   pay_action_information_api.create_action_information
   (p_action_context_type         => 'AAP'
   ,p_action_context_id           => l_assact_id
   ,p_action_information_id       => l_act_inf_id
   ,p_object_version_number       => l_ovn
   ,p_effective_date              => g_report_date
   ,p_action_information_category => 'EMEA REPORT INFORMATION'
   ,p_action_information1         => 'ASG_ACT_INFO'
   ,p_action_information2         => TO_CHAR(l_asg_rec.legal_employer_id)
   ,p_action_information3         => TO_CHAR(l_asg_rec.local_unit_id)
   ,p_action_information4         => l_asg_rec.ni_zone
   ,p_action_information5         => TO_CHAR(l_asg_rec.person_id)
   ,p_action_information6         => l_asg_rec.tax_municipality
   ,p_action_information7         => 'N'
   ,p_action_information8         => l_asg_rec.municipality_code
   );
  END LOOP;
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END assignment_action_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE initialization_code
 (p_payroll_action_id IN NUMBER) IS
 BEGIN
  NULL;
 END initialization_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE archive_code
 (p_assignment_action_id IN NUMBER
 ,p_effective_date       IN DATE) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.archive_code';
  --
  CURSOR csr_ASGACT
          (p_assignment_action_id IN NUMBER) IS
   SELECT paa.assignment_id
         ,asg_act.action_information2 legal_employer_id
         ,asg_act.action_information3 local_unit_id
         ,asg_act.action_information4 ni_zone
         ,asg_act.action_information6 tax_municipality_id
         ,asg_act.action_information8 municipality_code
   FROM   pay_action_information asg_act
         ,pay_assignment_actions paa
   WHERE  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  paa.assignment_action_id            = p_assignment_action_id;
  --
  CURSOR csr_BAL
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2) IS
   SELECT cde_dtl.action_information3 reporting_code
         ,TO_NUMBER(cde_dtl.action_information8) defined_balance_id
   FROM   pay_action_information cde_dtl
   WHERE  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = p_payroll_action_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = p_legal_employer_id
     AND  cde_dtl.action_information7        IN ('BAL','BAL_CODE_CTX');
  --
  CURSOR csr_BAL_ADDITIONAL_INFO
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_reporting_code    IN VARCHAR2) IS
   SELECT inf_dtl.action_information4 info_id
         ,TO_NUMBER(inf_dtl.action_information7) defined_balance_id
   FROM   pay_action_information inf_dtl
   WHERE  inf_dtl.action_context_type         = 'PA'
     AND  inf_dtl.action_context_id           = p_payroll_action_id
     AND  inf_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  inf_dtl.action_information1         = 'REP_CODE_INFO_DTLS'
     AND  inf_dtl.action_information2         = p_legal_employer_id
     AND  inf_dtl.action_information3         = p_reporting_code
     AND  inf_dtl.action_information7         IS NOT NULL;
  --
  CURSOR csr_RRV
          (p_payroll_action_id IN NUMBER
          ,p_business_group_id IN NUMBER
          ,p_assignment_id     IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_local_unit_id     IN VARCHAR2
          ,p_tax_municipality  IN VARCHAR2
          ,p_report_date       IN DATE) IS
   SELECT rr.run_result_id
         ,rr.element_type_id  element_type
         ,cde_dtl.action_information3 reporting_code
         ,cde_info_dtl.action_information4 info_id
         ,rrv.result_value
         ,cde_info_dtl.action_information6 dtype
--         ,pivf.uom dtype
   FROM   pay_action_information      cde_dtl
         ,pay_action_information      cde_info_dtl
     	 ,pay_element_type_extra_info eei
 	     ,pay_assignment_actions      paa
         ,pay_action_contexts         ac1
         ,ff_contexts                 ctx1
         ,pay_action_contexts         ac2
         ,ff_contexts                 ctx2
         ,pay_payroll_actions         ppa
     	 ,pay_run_results             rr
     	 ,pay_run_result_values       rrv
         ,pay_input_values_f          pivf
         ,pay_user_tables             t
         ,pay_user_rows_f             r
   WHERE  cde_dtl.action_context_type              = 'PA'
     AND  cde_dtl.action_context_id                = p_payroll_action_id
     AND  cde_dtl.action_information_category      = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1              = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2              = p_legal_employer_id
     AND  cde_dtl.action_information7              IN ('RRV', 'RRV_ELEMENT')
     AND  cde_info_dtl.action_context_type         = cde_dtl.action_context_type
     AND  cde_info_dtl.action_context_id           = cde_dtl.action_context_id
     AND  cde_info_dtl.action_information_category = cde_dtl.action_information_category
     AND  cde_info_dtl.action_information1         = 'REP_CODE_INFO_DTLS'
     AND  cde_info_dtl.action_information2         = cde_dtl.action_information2
     AND  cde_info_dtl.action_information3         = cde_dtl.action_information3
     AND  eei.eei_information3                     = cde_info_dtl.action_information3  --Reporting_Code
     AND  eei.information_type                     = 'NO_EOY_REPORTING_CODE_MAPPING'
     AND  to_number(to_char(p_report_date,'YYYY')) BETWEEN to_number(eei.eei_information1)
                                                   AND to_number(nvl(eei.eei_information2,'4712'))
     AND  ppa.business_group_id                    = p_business_group_id
     AND  ppa.action_type                          IN ('R','Q','I','B')
     AND  ppa.action_status                        = 'C'
     AND  ppa.payroll_action_id                    = paa.payroll_action_id
     AND  paa.action_status                        = 'C'
     AND  ac1.assignment_action_id                 = paa.assignment_action_id
     AND  ctx1.context_id                          = ac1.context_id
     AND  ctx1.context_name                        = 'LOCAL_UNIT_ID'
     AND  ac1.context_value                        = p_local_unit_id
     AND  ac2.assignment_action_id                 = paa.assignment_action_id
     AND  ctx2.context_id                          = ac2.context_id
     AND  ctx2.context_name                        = 'JURISDICTION_CODE'
     AND  t.user_table_name                        = 'NO_TAX_MUNICIPALITY'
     AND  t.legislation_code                       = 'NO'
     AND  r.user_table_id                          = t.user_table_id
     AND  r.row_low_range_or_name                  = ac2.context_value
     AND  ac2.context_value                        = p_tax_municipality
     AND  paa.tax_unit_id                          = TO_NUMBER(p_legal_employer_id)
     AND  paa.assignment_id                        = p_assignment_id
     AND  ppa.effective_date                       BETWEEN TRUNC(p_report_date, 'Y') AND p_report_date
     AND  rr.assignment_action_id                  = paa.assignment_action_id
     AND  eei.element_type_id                      = DECODE(cde_dtl.action_information7
                                                          ,'RRV', eei.element_type_id
                                                          ,TO_NUMBER(cde_dtl.action_information8))
     AND  rr.element_type_id                       = eei.element_type_id
     AND  rrv.run_result_id                        = rr.run_result_id
     AND  rrv.input_value_id                       = TO_NUMBER(DECODE(cde_info_dtl.action_information4
          	                                                     ,'INFO1' , eei.eei_information6
                                                                 ,'INFO2' , eei.eei_information8
                                                                 ,'INFO3' , eei.eei_information10
                                                                 ,'INFO4' , eei.eei_information12
                                                                 ,'INFO5' , eei.eei_information14
                                                                 ,'INFO6' , eei.eei_information16
                                                                 ,'INFO7' , eei.eei_information19   --2009 changes
                                                                 ,'INFO8' , eei.eei_information21   --2009 changes
                                                                 ,'INFO9' , eei.eei_information23   --2009 changes
                                                                 ,'INFO10' , eei.eei_information25   --2009 changes
                                                                 ,'AMOUNT', eei.eei_information4))
     AND  pivf.input_value_id                      = rrv.input_value_id
     AND  p_report_date                            BETWEEN pivf.effective_start_date
                                                   AND pivf.effective_end_date
     AND  p_report_date                            BETWEEN r.effective_start_date
                                                   AND r.effective_end_date
   ORDER BY cde_dtl.action_information3, rr.run_result_id;
  --
  CURSOR csr_PROC
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2) IS
   SELECT cde_dtl.action_information3 reporting_code
         ,cde_dtl.action_information8 procedure_name
   FROM   pay_action_information cde_dtl
   WHERE  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = p_payroll_action_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = p_legal_employer_id
     AND  cde_dtl.action_information7         = 'PROCEDURE';
  --
  CURSOR csr_Seaman IS
   SELECT classification_id
    FROM  pay_element_classifications
   WHERE  classification_name = 'Seaman _ Earnings';
  --
  CURSOR csr_Seaman_Status
          (l_element_type      IN NUMBER
          ,l_classification_id IN NUMBER
          ,l_report_date       IN DATE) IS
   SELECT 'Y'
    FROM  pay_sub_classification_rules_f
    WHERE element_type_id   = l_element_type
    AND   classification_id = l_classification_id
    AND   l_report_date BETWEEN effective_start_date AND effective_end_date;
  --
  CURSOR csr_seaman_bal_status
           (l_classification_id  IN NUMBER
           ,l_defined_balance_id IN NUMBER) IS
   SELECT 'Y'
    FROM   pay_defined_balances        pdb
          ,pay_balance_classifications pbc
    WHERE  pbc.classification_id  = l_classification_id
    AND    pdb.balance_type_id    = pbc.balance_type_id
    AND    pdb.defined_balance_id = l_defined_balance_id;
  --
  CURSOR csr_549_118A
          (p_business_group_id IN NUMBER
          ,p_assignment_id     IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_local_unit_id     IN VARCHAR2
          ,p_tax_municipality  IN VARCHAR2
          ,p_report_date       IN DATE
          ,l_element_name      IN VARCHAR2 ) IS
   SELECT rrv.result_value    value
         ,pivf.uom            dtype
   FROM   pay_assignment_actions      paa
         ,pay_action_contexts         ac1
         ,ff_contexts                 ctx1
         ,pay_action_contexts         ac2
         ,ff_contexts                 ctx2
         ,pay_payroll_actions         ppa
     	 ,pay_run_results             rr
     	 ,pay_run_result_values       rrv
         ,pay_input_values_f          pivf
         ,pay_element_types_f         petf
         ,pay_user_tables             t
         ,pay_user_rows_f             r
   WHERE  ppa.business_group_id        = p_business_group_id
     AND  ppa.action_type              IN ('R','Q','I','B')
     AND  ppa.action_status            = 'C'
     AND  paa.payroll_action_id        = ppa.payroll_action_id
     AND  paa.action_status            = 'C'
     AND  ac1.assignment_action_id     = paa.assignment_action_id
     AND  ctx1.context_id              = ac1.context_id
     AND  ctx1.context_name            = 'LOCAL_UNIT_ID'
     AND  ac1.context_value            = p_local_unit_id
     AND  ac2.assignment_action_id     = paa.assignment_action_id
     AND  ctx2.context_id              = ac2.context_id
     AND  ctx2.context_name            = 'JURISDICTION_CODE'
     AND  t.user_table_name            = 'NO_TAX_MUNICIPALITY'
     AND  t.legislation_code           = 'NO'
     AND  r.user_table_id              = t.user_table_id
     AND  r.row_low_range_or_name      = ac2.context_value
     AND  ac2.context_value            = p_tax_municipality
     AND  paa.tax_unit_id              = TO_NUMBER(p_legal_employer_id)
     AND  paa.assignment_id            = p_assignment_id
     AND  rr.assignment_action_id      = paa.assignment_action_id
     AND  rr.element_type_id           = petf.element_type_id
	 AND  petf.element_name            = l_element_name
	 AND  petf.legislation_code        = 'NO'
     AND  rrv.run_result_id            = rr.run_result_id
     AND  pivf.name                    = 'Pay Value'
	 AND  pivf.legislation_code        = 'NO'
     AND  pivf.input_value_id          = rrv.input_value_id
	 AND  pivf.element_type_id         = petf.element_type_id
     AND  ppa.effective_date           BETWEEN TRUNC(p_report_date, 'Y') AND p_report_date
     AND  p_report_date                BETWEEN petf.effective_start_date
                                       AND petf.effective_end_date
     AND  p_report_date                BETWEEN pivf.effective_start_date
                                       AND pivf.effective_end_date
     AND  p_report_date                BETWEEN r.effective_start_date
                                       AND r.effective_end_date;
  --
  /* For 2009 Legislative changes related to Foriegn Travel rates, from March 2009
  the following element's preocessing rules, processing results and balance feed
  haven been end dated by 28-FEB-2009.
  1) Total Abroad Overnight Travel over 28 days Hotel
  2) Adjustment Total Abroad Overnight Travel over 28 days Hotel
  3) Total Domestic Overnight Travel over 28 days Hotel
  4) Adjustment Total Domestic Overnight Travel over 28 days Hotel
  Newly created following elements will be used from 01-mar-2009
  1) Per Diem Over 28 Days Hotel Abroad
  2) Adjustment Per Diem Over 28 Days Hotel Abroad
  3) Per Diem Over 28 Days Hotel Domestic
  4) Adjustment Per Diem Over 28 Days Hotel Domestic.
  To select newly created element's rr values, new element name also added in
  the where clause   */
  CURSOR csr_613_616
          (p_business_group_id IN NUMBER
          ,p_assignment_id     IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_local_unit_id     IN VARCHAR2
          ,p_tax_municipality  IN VARCHAR2
          ,p_report_date       IN DATE
          ,l_element_name      IN VARCHAR2
          ,l_new_element_name  IN VARCHAR2) IS
   SELECT rrv.result_value         value
		 ,petf.element_type_id     element_type_id
		 ,rr.run_result_id         rr_id
         ,petf.element_name        element_name
         ,ppa.action_type          action_type
   FROM   pay_assignment_actions      paa
         ,pay_action_contexts         ac1
         ,ff_contexts                 ctx1
         ,pay_action_contexts         ac2
         ,ff_contexts                 ctx2
         ,pay_payroll_actions         ppa
     	 ,pay_run_results             rr
     	 ,pay_run_result_values       rrv
         ,pay_input_values_f          pivf
         ,pay_element_types_f         petf
         ,pay_user_tables             t
         ,pay_user_rows_f             r
   WHERE  ppa.business_group_id        = p_business_group_id
     AND  ppa.action_type              IN ('R','Q','I','B')
     AND  ppa.action_status            = 'C'
     AND  paa.payroll_action_id        = ppa.payroll_action_id
     AND  paa.action_status            = 'C'
     AND  ac1.assignment_action_id     = paa.assignment_action_id
     AND  ctx1.context_id              = ac1.context_id
     AND  ctx1.context_name            = 'LOCAL_UNIT_ID'
     AND  ac1.context_value            = p_local_unit_id
     AND  ac2.assignment_action_id     = paa.assignment_action_id
     AND  ctx2.context_id              = ac2.context_id
     AND  ctx2.context_name            = 'JURISDICTION_CODE'
     AND  t.user_table_name            = 'NO_TAX_MUNICIPALITY'
     AND  t.legislation_code           = 'NO'
     AND  r.user_table_id              = t.user_table_id
     AND  r.row_low_range_or_name      = ac2.context_value
     AND  ac2.context_value            = p_tax_municipality
     AND  paa.tax_unit_id              = TO_NUMBER(p_legal_employer_id)
     AND  paa.assignment_id            = p_assignment_id
     AND  rr.assignment_action_id      = paa.assignment_action_id
     AND  rr.element_type_id           = petf.element_type_id
     AND  petf.element_name            IN ( l_element_name, 'Adjustment ' || l_element_name, l_new_element_name, 'Adjustment '||l_new_element_name )
	 AND  petf.legislation_code        = 'NO'
     AND  rrv.run_result_id            = rr.run_result_id
     AND  pivf.name                    = 'Travel Reference Number'
	 AND  pivf.legislation_code        = 'NO'
     AND  pivf.input_value_id          = rrv.input_value_id
     AND  pivf.element_type_id         = petf.element_type_id
     AND  ppa.effective_date           BETWEEN TRUNC(p_report_date, 'Y') AND p_report_date
     AND  p_report_date                BETWEEN petf.effective_start_date
                                       AND petf.effective_end_date
     AND  p_report_date                BETWEEN pivf.effective_start_date
                                       AND pivf.effective_end_date
     AND  p_report_date                BETWEEN r.effective_start_date
                                       AND r.effective_end_date
     order by rrv.result_value;
  --
  CURSOR csr_613_616_details
          (l_rr_id            IN NUMBER
          ,l_element_type_id  IN NUMBER
          ,p_report_date      IN DATE) IS
    SELECT sum(decode (piv.name,'Pay Value', fnd_number.canonical_to_number(rrv.result_value) ,0)) Pay_Value
	      ,sum(decode (piv.name,'Per Diem', fnd_number.canonical_to_number(rrv.result_value) ,0)) Per_Diem
	 	  ,sum(decode (piv.name,'Number of Days to be reported', fnd_number.canonical_to_number(rrv.result_value) ,0)) Reporting_Days
		  ,sum(decode (piv.name,'Number of Days', fnd_number.canonical_to_number(rrv.result_value) ,0)) Days
          ,max(decode (piv.name,'Country', rrv.result_value)) Country
	  FROM pay_run_result_values rrv
          ,pay_input_values_f    piv
	 WHERE rrv.run_result_id   = l_rr_id
	   AND piv.element_type_id = l_element_type_id
	   AND piv.name            IN ('Pay Value','Number of Days','Per Diem','Number of Days to be reported','Country')
	   AND piv.input_value_id  = rrv.input_value_id
       AND p_report_date       BETWEEN piv.effective_start_date
                               AND piv.effective_end_date;
  --
  l_asg_act_rec    csr_ASGACT%ROWTYPE;
  l_plsql_block    VARCHAR2(2000) := 'BEGIN <PROC>(:1, :2, :3); END;';
  l_rep_code_rec   t_rep_code_rec;
  l_act_inf_id     NUMBER;
  l_ovn            NUMBER;
  l_amount         NUMBER;
  l_rr_id          NUMBER := -1;
  l_classification_id  pay_element_classifications.classification_id%TYPE;
  l_element_type_id    pay_element_Types_f.element_type_id%TYPE;
  l_element_name       pay_element_types_f.element_name%TYPE;
  rec_613_616_details  csr_613_616_details%ROWTYPE;
  l_seaman_status      VARCHAR2(2);
  l_Travel_Ref         VARCHAR2(60);
  l_Pay_Value          NUMBER;
  l_Days               NUMBER;
  status_616           NUMBER;
  l_index_616          NUMBER;
  l_code_616           code_616;
  --
 BEGIN
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  --
  OPEN  csr_Seaman;
  FETCH csr_Seaman INTO l_classification_id;
  CLOSE csr_Seaman;
  --
  --
  -- Get information for the assignment action being processed.
  --
--  fnd_file.put_line(fnd_file.log,'csr_ASGACT p_assignment_action_id'||p_assignment_action_id);
  OPEN  csr_ASGACT(p_assignment_action_id);
  FETCH csr_ASGACT INTO l_asg_act_rec;
  CLOSE csr_ASGACT;
  --
  --
  -- Setup balance contexts.
  --
  pay_balance_pkg.set_context('TAX_UNIT_ID'      , l_asg_act_rec.legal_employer_id);
  pay_balance_pkg.set_context('DATE_EARNED'      , fnd_date.date_to_canonical(g_report_date));
  pay_balance_pkg.set_context('LOCAL_UNIT_ID'    , l_asg_act_rec.local_unit_id);
--  pay_balance_pkg.set_context('JURISDICTION_CODE', l_asg_act_rec.tax_municipality_id);
  pay_balance_pkg.set_context('SOURCE_TEXT2'     , l_asg_act_rec.municipality_code);
  --
  --
  -- Loop through all balance based reporting codes.
  --
--  fnd_file.put_line(fnd_file.log,'csr_BAL g_payroll_action_id'||g_payroll_action_id);
--  fnd_file.put_line(fnd_file.log,'csr_BAL legal_employer_id'||l_asg_act_rec.legal_employer_id);
  FOR l_bal_rec IN csr_BAL
                    (g_payroll_action_id
                    ,l_asg_act_rec.legal_employer_id)
  LOOP
   l_rep_code_rec := g_empty_rep_code_rec;
   --
   --
   -- Setup balance contexts NB. This is used for reporting codes using BAL_CODE_CTX.
   --
   pay_balance_pkg.set_context('SOURCE_TEXT', l_bal_rec.reporting_code);
 --fnd_file.put_line(fnd_file.log,'$$$ reporting_code: '||l_bal_rec.reporting_code);
   --
   --
   -- Get balance value.
   --
--fnd_file.put_line(fnd_file.log,'$$$ l_bal_rec.defined_balance_id: '||l_bal_rec.defined_balance_id);
--fnd_file.put_line(fnd_file.log,'$$$ l_asg_act_rec.assignment_id: '||l_asg_act_rec.assignment_id);
--fnd_file.put_line(fnd_file.log,'$$$ g_report_date: '||g_report_date);
   IF l_bal_rec.defined_balance_id IS NOT NULL THEN
     l_amount := pay_balance_pkg.get_value
                 (p_defined_balance_id => l_bal_rec.defined_balance_id
                 ,p_assignment_id      => l_asg_act_rec.assignment_id
                 ,p_virtual_date       => g_report_date);
   ELSE
     l_amount := 0;
   END IF;
 --fnd_file.put_line(fnd_file.log,'$$$ l_amount: '||l_amount);
   --
   IF l_amount <> 0 THEN
    l_rep_code_rec.reporting_code := l_bal_rec.reporting_code;
    l_rep_code_rec.amount         := fnd_number.number_to_canonical(l_amount);
    --
    l_seaman_status := 'N';
    --
    OPEN  csr_seaman_bal_status(l_classification_id, l_bal_rec.defined_balance_id);
    FETCH csr_seaman_bal_status INTO l_seaman_status;
    CLOSE csr_seaman_bal_status;
    --
    -- Check if the code 549 is processed through the payroll, then it should be
    -- archived individually. i.e. should appear once for each concerned element is processed.
    --
    IF l_bal_rec.reporting_code = '549' THEN    --IN ('118-A', '549') THEN
    --
    --  IF l_bal_rec.reporting_code = '118-A' THEN
    --    l_element_name := 'BIK Company Cars';
    --  ELSIF l_bal_rec.reporting_code = '549' THEN
        l_element_name := 'BIK Employer Assets';
    --  END IF;
      --
      FOR rec_549_118A IN csr_549_118A (g_business_group_id
                                       ,l_asg_act_rec.assignment_id
                                       ,l_asg_act_rec.legal_employer_id
                                       ,l_asg_act_rec.local_unit_id
                                       ,l_asg_act_rec.tax_municipality_id
                                       ,g_report_date
                                       ,l_element_name )
      LOOP
        --
        IF rec_549_118A.dtype = 'M' THEN
          l_rep_code_rec.amount := fnd_number.number_to_canonical(rec_549_118A.value);
        ELSE
          l_rep_code_rec.amount := rec_549_118A.value;
        END IF;
        --
        --
        -- Archive: EMEA REPORT INFORMATION | ASG_REP_CODE_INFO
        --
        pay_action_information_api.create_action_information
        (p_action_context_type         => 'AAP'
        ,p_action_context_id           => p_assignment_action_id
        ,p_action_information_id       => l_act_inf_id
        ,p_object_version_number       => l_ovn
        ,p_effective_date              => g_report_date
        ,p_action_information_category => 'EMEA REPORT INFORMATION'
        ,p_action_information1         => 'ASG_REP_CODE_INFO'
        ,p_action_information2         => l_rep_code_rec.reporting_code
        ,p_action_information3         => l_rep_code_rec.amount
        ,p_action_information10        => l_seaman_status);
      --
      END LOOP;
    --
    ELSIF l_bal_rec.reporting_code = '613' THEN
      --
      l_Travel_Ref := NULL;
      l_Pay_Value  := 0;
      l_Days       := 0;
      --
      -- Get the RR ID, Element Type Id, Travel Ref Num
      --
       /* 2009 legislative changes related to foriegn travel rates.
       To select newly created element's('Per Diem Over 28 Days Hotel Domestic')
       rr values for archieval, that element also passed as an argument */
      FOR rec_613_616 IN csr_613_616 (g_business_group_id
                                     ,l_asg_act_rec.assignment_id
                                     ,l_asg_act_rec.legal_employer_id
                                     ,l_asg_act_rec.local_unit_id
                                     ,l_asg_act_rec.tax_municipality_id
                                     ,g_report_date
                                     ,'Total Domestic Overnight Travel over 28 days Hotel'
                                     ,'Per Diem Over 28 Days Hotel Domestic' )
      LOOP
      --
       IF rec_613_616.rr_id IS NOT NULL AND rec_613_616.element_type_id IS NOT NULL THEN
        --
        -- From the RR ID and Element Type ID, get additional info as 'Pay Value','Number of Days'
        -- for code 613
        --
        OPEN csr_613_616_details
              (rec_613_616.rr_id
              ,rec_613_616.element_type_id
              ,g_report_date);
        FETCH csr_613_616_details INTO rec_613_616_details;
        CLOSE csr_613_616_details;
        --
        IF NVL(l_Travel_Ref,rec_613_616.value) = rec_613_616.value  THEN
          l_Pay_Value  := l_Pay_Value + rec_613_616_details.Pay_Value;
          l_Days := l_Days + rec_613_616_details.Days;
          --
        ELSE
          --
          -- For the code 613, additional information order is Days
          -- Archive: EMEA REPORT INFORMATION | ASG_REP_CODE_INFO | Code 613
          --
          pay_action_information_api.create_action_information
          (p_action_context_type         => 'AAP'
          ,p_action_context_id           => p_assignment_action_id
          ,p_action_information_id       => l_act_inf_id
          ,p_object_version_number       => l_ovn
          ,p_effective_date              => g_report_date
          ,p_action_information_category => 'EMEA REPORT INFORMATION'
          ,p_action_information1         => 'ASG_REP_CODE_INFO'
          ,p_action_information2         => l_bal_rec.reporting_code
          ,p_action_information3         => fnd_number.number_to_canonical(l_Pay_Value)
          ,p_action_information4         => fnd_number.number_to_canonical(l_Days)
          ,p_action_information10        => l_seaman_status);
          --
          l_Pay_Value  := rec_613_616_details.Pay_Value;
          l_Days := rec_613_616_details.Days;
          --
        END IF;
        l_Travel_Ref := rec_613_616.value;
        --
       END IF; -- rr_id, ele_typ_id
       --
      END LOOP;
      --
      -- Archive last RR Values for Pav Value, Number of Days based on the RR ID
      --
      IF l_Travel_Ref IS NOT NULL THEN
        --
        --
        -- Archive: EMEA REPORT INFORMATION | ASG_REP_CODE_INFO | Code 613, 616
        --
        pay_action_information_api.create_action_information
        (p_action_context_type         => 'AAP'
        ,p_action_context_id           => p_assignment_action_id
        ,p_action_information_id       => l_act_inf_id
        ,p_object_version_number       => l_ovn
        ,p_effective_date              => g_report_date
        ,p_action_information_category => 'EMEA REPORT INFORMATION'
        ,p_action_information1         => 'ASG_REP_CODE_INFO'
        ,p_action_information2         => l_bal_rec.reporting_code
        ,p_action_information3         => fnd_number.number_to_canonical(l_Pay_Value)
        ,p_action_information4         => fnd_number.number_to_canonical(l_Days)
        ,p_action_information10        => l_seaman_status);
        --
      END IF;
    --
    ELSIF l_bal_rec.reporting_code = '616' THEN -- to modify from here
      --
      l_Days       := 0;
      l_index_616  := 0;
      l_code_616.DELETE;
      --
      -- Get the RR ID, Element Type Id, Travel Ref Num
      --
       /* 2009 legislative changes related to foriegn travel rates.
      To select newly created element's('Per Diem Over 28 Days Hotel Abroad')
      rr values for archieval, that element also passed as an argument */
      FOR rec_613_616 IN csr_613_616 (g_business_group_id
                                     ,l_asg_act_rec.assignment_id
                                     ,l_asg_act_rec.legal_employer_id
                                     ,l_asg_act_rec.local_unit_id
                                     ,l_asg_act_rec.tax_municipality_id
                                     ,g_report_date
                                     ,'Total Abroad Overnight Travel over 28 days Hotel'
                                     ,'Per Diem Over 28 Days Hotel Abroad')
      LOOP
      --
       IF rec_613_616.rr_id IS NOT NULL AND rec_613_616.element_type_id IS NOT NULL THEN
         --
         -- From the RR ID and Element Type ID, get additional info as 'Pay Value','Number of Days'
         -- ,'Per Diem','Number of Days to be reported','Country') for code 616
         --
         OPEN csr_613_616_details
              (rec_613_616.rr_id
              ,rec_613_616.element_type_id
              ,g_report_date);
         FETCH csr_613_616_details INTO rec_613_616_details;
         CLOSE csr_613_616_details;
         --
         l_Days := NULL;
         --
         IF rec_613_616.element_name = 'Total Abroad Overnight Travel over 28 days Hotel' THEN
           l_Days := rec_613_616_details.Reporting_Days;
         ELSE
           l_Days := rec_613_616_details.Days;
         END IF;
         --
         IF rec_613_616.action_type IN ('I','B') OR l_index_616 = 0 THEN
           -- if this is balance adjustment / initialization or the very first trnsaction
           -- load it in plsql table
           l_index_616 := l_index_616 + 1;
           l_code_616(l_index_616).TRN       := rec_613_616.value;
           l_code_616(l_index_616).Country   := rec_613_616_details.Country;
           l_code_616(l_index_616).Per_Diem  := rec_613_616_details.Per_Diem;
           l_code_616(l_index_616).Pay_Value := rec_613_616_details.Pay_Value;
           l_code_616(l_index_616).Days      := l_Days;
         --
         ELSE -- If code generated is through Payroll run result
           -- find its accurate position corresponding to TRN, Per Diem and Country
           -- and add the values for Days and Pay Value
           status_616 := 0;
           --
           FOR i IN 1 .. l_index_616
           LOOP
             --
             IF l_code_616(i).TRN = rec_613_616.value
               AND l_code_616(i).Country = rec_613_616_details.Country
               AND l_code_616(i).Per_Diem = rec_613_616_details.Per_Diem THEN
               --
               l_code_616(i).Pay_Value := l_code_616(i).Pay_Value + rec_613_616_details.Pay_Value;
               l_code_616(i).Days      := l_code_616(i).Days + l_Days;
               status_616 := 1;
               EXIT;
             --
             ELSIF l_code_616(i).TRN > rec_613_616.value THEN
               --
               l_index_616 := l_index_616 + 1;
               l_code_616(l_index_616).TRN       := rec_613_616.value;
               l_code_616(l_index_616).Country   := rec_613_616_details.Country;
               l_code_616(l_index_616).Per_Diem  := rec_613_616_details.Per_Diem;
               l_code_616(l_index_616).Pay_Value := rec_613_616_details.Pay_Value;
               l_code_616(l_index_616).Days      := l_Days;
               status_616 := 1;
               EXIT;
             --
             END IF;
           --
           END LOOP;
           -- if new trn no from payroll run result then insert new record in plsql table
           IF status_616 = 0 THEN
           --
             l_index_616 := l_index_616 + 1;
             l_code_616(l_index_616).TRN       := rec_613_616.value;
             l_code_616(l_index_616).Country   := rec_613_616_details.Country;
             l_code_616(l_index_616).Per_Diem  := rec_613_616_details.Per_Diem;
             l_code_616(l_index_616).Pay_Value := rec_613_616_details.Pay_Value;
             l_code_616(l_index_616).Days      := l_Days;
             --
           END IF;
           --
         END IF; --'I','B'
         --
       END IF; -- rr_id and ele_type_id
      --
      END LOOP; -- trn num fetch
      --
      --  Archive all the records from plsql table against the code 616
      IF l_index_616 > 0 THEN
      --
        FOR i IN 1 .. l_index_616
        LOOP
        --
          pay_action_information_api.create_action_information
          (p_action_context_type         => 'AAP'
          ,p_action_context_id           => p_assignment_action_id
          ,p_action_information_id       => l_act_inf_id
          ,p_object_version_number       => l_ovn
          ,p_effective_date              => g_report_date
          ,p_action_information_category => 'EMEA REPORT INFORMATION'
          ,p_action_information1         => 'ASG_REP_CODE_INFO'
          ,p_action_information2         => l_bal_rec.reporting_code
          ,p_action_information3         => fnd_number.number_to_canonical(l_code_616(i).Pay_Value)
          ,p_action_information4         => fnd_number.number_to_canonical(l_code_616(i).Per_Diem)
          ,p_action_information5         => fnd_number.number_to_canonical(l_code_616(i).Days)
          ,p_action_information6         => l_code_616(i).Country
          ,p_action_information10        => l_seaman_status);
        --
        END LOOP;
      --
      END IF;
    --
    -- For the codes except 613, 616 and 549 only       -- and 111-A
    ELSE
    --
    -- Loop through any additional information for the rest of the codes.
    --
      FOR l_bal_info_rec IN csr_BAL_ADDITIONAL_INFO
                             (g_payroll_action_id
                             ,l_asg_act_rec.legal_employer_id
                             ,l_bal_rec.reporting_code)
      LOOP
       --
       --
       -- Get balance value.
       --
       IF l_bal_info_rec.defined_balance_id IS NOT NULL THEN
         l_amount := pay_balance_pkg.get_value
                    (p_defined_balance_id => l_bal_info_rec.defined_balance_id
                    ,p_assignment_id      => l_asg_act_rec.assignment_id
                    ,p_virtual_date       => g_report_date);
       ELSE
         l_amount := 0;
       END IF;
       --
       --
       IF    l_bal_info_rec.info_id = 'INFO1' THEN
        l_rep_code_rec.info1 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO2' THEN
        l_rep_code_rec.info2 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO3' THEN
        l_rep_code_rec.info3 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO4' THEN
        l_rep_code_rec.info4 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO5' THEN
        l_rep_code_rec.info5 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO6' THEN
        l_rep_code_rec.info6 := fnd_number.number_to_canonical(l_amount);
       -- 2009 changes starts
       ELSIF l_bal_info_rec.info_id = 'INFO7' THEN
        l_rep_code_rec.info7 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO8' THEN
        l_rep_code_rec.info8 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO9' THEN
        l_rep_code_rec.info9 := fnd_number.number_to_canonical(l_amount);
       ELSIF l_bal_info_rec.info_id = 'INFO10' THEN
        l_rep_code_rec.info10 := fnd_number.number_to_canonical(l_amount);
       -- 2009 changes ends
       END IF;
      END LOOP;
      --
      --
      -- Archive: EMEA REPORT INFORMATION | ASG_REP_CODE_INFO
      --
      pay_action_information_api.create_action_information
      (p_action_context_type         => 'AAP'
      ,p_action_context_id           => p_assignment_action_id
      ,p_action_information_id       => l_act_inf_id
      ,p_object_version_number       => l_ovn
      ,p_effective_date              => g_report_date
      ,p_action_information_category => 'EMEA REPORT INFORMATION'
      ,p_action_information1         => 'ASG_REP_CODE_INFO'
      ,p_action_information2         => l_rep_code_rec.reporting_code
      ,p_action_information3         => l_rep_code_rec.amount
      ,p_action_information4         => l_rep_code_rec.info1
      ,p_action_information5         => l_rep_code_rec.info2
      ,p_action_information6         => l_rep_code_rec.info3
      ,p_action_information7         => l_rep_code_rec.info4
      ,p_action_information8         => l_rep_code_rec.info5
      ,p_action_information9         => l_rep_code_rec.info6
      ,p_action_information10        => l_seaman_status
      ,p_action_information11        => l_rep_code_rec.info7    --2009 changes
      ,p_action_information12        => l_rep_code_rec.info8    --2009 changes
      ,p_action_information13        => l_rep_code_rec.info9    --2009 changes
      ,p_action_information14        => l_rep_code_rec.info10   --2009 changes
      );
      END IF;
      --
    END IF;
  --
  END LOOP;
  --
  l_rep_code_rec := g_empty_rep_code_rec;
  --
  --
  -- Loop through all RRV based reporting codes NB. this is done result value by result value.
  --
  FOR l_rrv_rec IN csr_RRV
                    (g_payroll_action_id
                    ,g_business_group_id
                    ,l_asg_act_rec.assignment_id
                    ,l_asg_act_rec.legal_employer_id
                    ,l_asg_act_rec.local_unit_id
                    ,l_asg_act_rec.tax_municipality_id
                    ,g_report_date)
  LOOP
   --
   --
   -- Moved onto new run result so write out to archive.
   --
   IF l_rr_id <> l_rrv_rec.run_result_id THEN
    IF l_rep_code_rec.reporting_code IS NOT NULL THEN
     --
     l_seaman_status := 'N';
     OPEN csr_Seaman_Status(l_element_type_id, l_classification_id, g_report_date);
     FETCH csr_Seaman_Status INTO l_seaman_status;
     CLOSE csr_Seaman_Status;
     --
     --
     -- Archive: EMEA REPORT INFORMATION | ASG_REP_CODE_INFO
     --
     pay_action_information_api.create_action_information
     (p_action_context_type         => 'AAP'
     ,p_action_context_id           => p_assignment_action_id
     ,p_action_information_id       => l_act_inf_id
     ,p_object_version_number       => l_ovn
     ,p_effective_date              => g_report_date
     ,p_action_information_category => 'EMEA REPORT INFORMATION'
     ,p_action_information1         => 'ASG_REP_CODE_INFO'
     ,p_action_information2         => l_rep_code_rec.reporting_code
     ,p_action_information3         => l_rep_code_rec.amount
     ,p_action_information4         => l_rep_code_rec.info1
     ,p_action_information5         => l_rep_code_rec.info2
     ,p_action_information6         => l_rep_code_rec.info3
     ,p_action_information7         => l_rep_code_rec.info4
     ,p_action_information8         => l_rep_code_rec.info5
     ,p_action_information9         => l_rep_code_rec.info6
     ,p_action_information10        => l_seaman_status
     ,p_action_information11        => l_rep_code_rec.info7
     ,p_action_information12        => l_rep_code_rec.info8
     ,p_action_information13        => l_rep_code_rec.info9
     ,p_action_information14        => l_rep_code_rec.info10
     ,p_action_information15        => l_rep_code_rec.info11
     ,p_action_information16        => l_rep_code_rec.info12
     ,p_action_information17        => l_rep_code_rec.info13    --2009 changes
     ,p_action_information18        => l_rep_code_rec.info14    --2009 changes
     ,p_action_information19        => l_rep_code_rec.info15    --2009 changes
     ,p_action_information20        => l_rep_code_rec.info16    --2009 changes
     ,p_action_information21        => l_rep_code_rec.info17    --2009 changes
     ,p_action_information22        => l_rep_code_rec.info18    --2009 changes
     ,p_action_information23        => l_rep_code_rec.info19    --2009 changes
     ,p_action_information24        => l_rep_code_rec.info20    --2009 changes
     );
     --
     l_rep_code_rec := g_empty_rep_code_rec;
    END IF;
    --
    l_rep_code_rec.reporting_code := l_rrv_rec.reporting_code;
   END IF;
   --
--   IF l_rrv_rec.dtype IN ('M','N') THEN
    --
--    l_rrv_rec.result_value := fnd_number.number_to_canonical(l_rrv_rec.result_value);
--   END IF;
   --
   --
   -- Store value against correct information column.
   --
   IF l_rrv_rec.dtype IN ('C','T','D','MC') THEN -- All Non numeric data types (char, text, data)
    --
     IF    l_rrv_rec.info_id = 'INFO1' THEN
      l_rep_code_rec.info7 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO2' THEN
      l_rep_code_rec.info8 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO3' THEN
      l_rep_code_rec.info9 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO4' THEN
      l_rep_code_rec.info10 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO5' THEN
      l_rep_code_rec.info11 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO6' THEN
      l_rep_code_rec.info12 := l_rrv_rec.result_value;
     -- 2009 changes starts
     ELSIF l_rrv_rec.info_id = 'INFO7' THEN
      l_rep_code_rec.info17 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO8' THEN
      l_rep_code_rec.info18 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO9' THEN
      l_rep_code_rec.info19 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO10' THEN
      l_rep_code_rec.info20 := l_rrv_rec.result_value;
     -- 2009 changes ends
     END IF;
    --
   ELSE -- Data type is numeric
   --
     IF    l_rrv_rec.info_id = 'INFO1' THEN
      l_rep_code_rec.info1 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO2' THEN
      l_rep_code_rec.info2 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO3' THEN
      l_rep_code_rec.info3 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO4' THEN
      l_rep_code_rec.info4 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO5' THEN
      l_rep_code_rec.info5 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO6' THEN
      l_rep_code_rec.info6 := l_rrv_rec.result_value;
     -- 2009 changes starts
     ELSIF l_rrv_rec.info_id = 'INFO7' THEN
      l_rep_code_rec.info13 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO8' THEN
      l_rep_code_rec.info14 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO9' THEN
      l_rep_code_rec.info15 := l_rrv_rec.result_value;
     ELSIF l_rrv_rec.info_id = 'INFO10' THEN
      l_rep_code_rec.info16 := l_rrv_rec.result_value;
     -- 2009 changes ends
     ELSIF l_rrv_rec.info_id = 'AMOUNT' THEN
      IF is_EA_classification(l_rrv_rec.element_type, g_report_date) THEN
        l_rep_code_rec.amount := fnd_number.number_to_canonical(-1 * fnd_number.canonical_to_number(l_rrv_rec.result_value));
      ELSE
        l_rep_code_rec.amount := l_rrv_rec.result_value;
      END IF;
     END IF;
   --
   END IF;
   --
   l_rr_id := l_rrv_rec.run_result_id;
   l_element_type_id := l_rrv_rec.element_type;
  END LOOP;
  --
  --
  -- Write out to archive.
  --
  IF l_rep_code_rec.reporting_code IS NOT NULL THEN
   --
   l_seaman_status := 'N';
   OPEN csr_Seaman_Status(l_element_type_id, l_classification_id, g_report_date);
   FETCH csr_Seaman_Status INTO l_seaman_status;
   CLOSE csr_Seaman_Status;
   --
   --
   -- Archive: EMEA REPORT INFORMATION | ASG_REP_CODE_INFO
   --
   pay_action_information_api.create_action_information
   (p_action_context_type         => 'AAP'
   ,p_action_context_id           => p_assignment_action_id
   ,p_action_information_id       => l_act_inf_id
   ,p_object_version_number       => l_ovn
   ,p_effective_date              => g_report_date
   ,p_action_information_category => 'EMEA REPORT INFORMATION'
   ,p_action_information1         => 'ASG_REP_CODE_INFO'
   ,p_action_information2         => l_rep_code_rec.reporting_code
   ,p_action_information3         => l_rep_code_rec.amount
   ,p_action_information4         => l_rep_code_rec.info1
   ,p_action_information5         => l_rep_code_rec.info2
   ,p_action_information6         => l_rep_code_rec.info3
   ,p_action_information7         => l_rep_code_rec.info4
   ,p_action_information8         => l_rep_code_rec.info5
   ,p_action_information9         => l_rep_code_rec.info6
   ,p_action_information10        => l_seaman_status
   ,p_action_information11        => l_rep_code_rec.info7
   ,p_action_information12        => l_rep_code_rec.info8
   ,p_action_information13        => l_rep_code_rec.info9
   ,p_action_information14        => l_rep_code_rec.info10
   ,p_action_information15        => l_rep_code_rec.info11
   ,p_action_information16        => l_rep_code_rec.info12
   ,p_action_information17        => l_rep_code_rec.info13    --2009 changes
   ,p_action_information18        => l_rep_code_rec.info14    --2009 changes
   ,p_action_information19        => l_rep_code_rec.info15    --2009 changes
   ,p_action_information20        => l_rep_code_rec.info16    --2009 changes
   ,p_action_information21        => l_rep_code_rec.info17    --2009 changes
   ,p_action_information22        => l_rep_code_rec.info18    --2009 changes
   ,p_action_information23        => l_rep_code_rec.info19    --2009 changes
   ,p_action_information24        => l_rep_code_rec.info20    --2009 changes
   );
   --
   l_rep_code_rec := g_empty_rep_code_rec;
  END IF;
  --
  --
  -- Loop through all PROCEDURE based reporting codes NB. this is done result value by result value.
  --
  FOR l_proc_name_rec IN csr_PROC
                     (g_payroll_action_id
                     ,l_asg_act_rec.legal_employer_id)
  LOOP
   l_plsql_block := REPLACE(l_plsql_block, '<PROC>', l_proc_name_rec.procedure_name);
   --
   --
   -- Dynamically call the stored procedure.
   --
   EXECUTE IMMEDIATE l_plsql_block
   USING p_assignment_action_id
        ,l_proc_name_rec.reporting_code
        ,g_report_date;
  END LOOP;
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END archive_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Part of archive logic.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE deinitialization_code
 (p_payroll_action_id IN NUMBER) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.deinitialization_code';
  --
  CURSOR csr_LE_PER_BELOW_REP_LIMIT
          (p_payroll_action_id IN NUMBER) IS
   SELECT  le_lu.action_information2   legal_employer_id
          ,asg_act.action_information5 person_id
    FROM   pay_assignment_actions paa
          ,pay_action_information le_lu
          ,pay_action_information asg_act
          ,pay_action_information rep_cde
          ,pay_action_information cde_dtl
    WHERE  paa.payroll_action_id               = le_lu.action_context_id
      AND  asg_act.action_context_type         = 'AAP'
      AND  asg_act.action_context_id           = paa.assignment_action_id
      AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
      AND  asg_act.action_information1         = 'ASG_ACT_INFO'
      AND  asg_act.action_information2         = le_lu.action_information2
      AND  asg_act.action_information3         = le_lu.action_information4
      AND  le_lu.action_context_type           = 'PA'
      AND  le_lu.action_context_id             = p_payroll_action_id
      AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
      AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
      AND  cde_dtl.action_context_type         = 'PA'
      AND  cde_dtl.action_context_id           = le_lu.action_context_id
      AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
      AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
      AND  cde_dtl.action_information2         = le_lu.action_information2
      AND  cde_dtl.action_information3         = rep_cde.action_information2
      AND  cde_dtl.action_information6         = 'Y'
      AND  rep_cde.action_context_type         = 'AAP'
      AND  rep_cde.action_context_id           = asg_act.action_context_id
      AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
      AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
    GROUP BY le_lu.action_information2
 	    ,asg_act.action_information5
    HAVING SUM(fnd_number.canonical_to_number(rep_cde.action_information3)) < 1000;
  --
  CURSOR csr_ASGACT
          (p_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_person_id         IN VARCHAR2) IS
   SELECT asg_act.action_information_id
         ,asg_act.object_version_number
         ,paa.assignment_id
   FROM   pay_action_information asg_act
         ,pay_assignment_actions paa
   WHERE  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_information2         = p_legal_employer_id
     AND  asg_act.action_information5         = p_person_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  paa.payroll_action_id               = p_payroll_action_id;
  --
  CURSOR csr_INDIVIDUAL_CODES
          (p_payroll_action_id IN NUMBER) IS
   SELECT asg_act.action_information2  legal_employer_id
         ,asg_act.action_information5  person_id
         ,asg_act.action_information6  tax_municipality
         ,rep_cde.action_information2  code
         ,rep_cde.action_information3  amount
         ,rep_cde.action_information4  info1
         ,rep_cde.action_information5  info2
         ,rep_cde.action_information6  info3
         ,rep_cde.action_information7  info4
         ,rep_cde.action_information8  info5
         ,rep_cde.action_information9  info6
         ,rep_cde.action_information10 seaman_component
         ,rep_cde.action_information11 cinfo1
         ,rep_cde.action_information12 cinfo2
         ,rep_cde.action_information13 cinfo3
         ,rep_cde.action_information14 cinfo4
         ,rep_cde.action_information15 cinfo5
         ,rep_cde.action_information16 cinfo6
         ,rep_cde.action_information17 info7    --2009 changes
         ,rep_cde.action_information18 info8    --2009 changes
         ,rep_cde.action_information19 info9    --2009 changes
         ,rep_cde.action_information20 info10   --2009 changes
         ,rep_cde.action_information21 cinfo7   --2009 changes
         ,rep_cde.action_information22 cinfo8   --2009 changes
         ,rep_cde.action_information23 cinfo9   --2009 changes
         ,rep_cde.action_information24 cinfo10  --2009 changes
   FROM   pay_assignment_actions paa
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = p_payroll_action_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = paa.payroll_action_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = asg_act.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  cde_dtl.action_information9         = 'INDIVIDUAL';
  --
  CURSOR csr_SUM_CODES
          (p_payroll_action_id IN NUMBER) IS
   SELECT asg_act.action_information2  legal_employer_id
         ,asg_act.action_information5  person_id
         ,asg_act.action_information6  tax_municipality
         ,rep_cde.action_information2  code
         ,SUM(fnd_number.canonical_to_number(rep_cde.action_information3))  amount
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information4,0)))  info1
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information5,0)))  info2
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information6,0)))  info3
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information7,0)))  info4
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information8,0)))  info5
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information9,0)))  info6
         ,rep_cde.action_information10 seaman_component
         ,rep_cde.action_information11 cinfo1
         ,rep_cde.action_information12 cinfo2
         ,rep_cde.action_information13 cinfo3
         ,rep_cde.action_information14 cinfo4
         ,rep_cde.action_information15 cinfo5
         ,rep_cde.action_information16 cinfo6
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information17,0)))  info7 --2009 changes
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information18,0)))  info8 --2009 changes
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information19,0)))  info9 --2009 changes
         ,SUM(fnd_number.canonical_to_number(nvl(rep_cde.action_information20,0)))  info10 --2009 changes
         ,rep_cde.action_information21 cinfo7 --2009 changes
         ,rep_cde.action_information22 cinfo8 --2009 changes
         ,rep_cde.action_information23 cinfo9 --2009 changes
         ,rep_cde.action_information24 cinfo10 --2009 changes
   FROM   pay_assignment_actions paa
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = p_payroll_action_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = paa.payroll_action_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = asg_act.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  cde_dtl.action_information9         = 'SUM'
   GROUP BY asg_act.action_information2
           ,asg_act.action_information5
           ,asg_act.action_information6
           ,rep_cde.action_information2
           ,rep_cde.action_information10
           ,rep_cde.action_information11
           ,rep_cde.action_information12
           ,rep_cde.action_information13
           ,rep_cde.action_information14
           ,rep_cde.action_information15
           ,rep_cde.action_information16
           ,rep_cde.action_information21 --2009 changes
           ,rep_cde.action_information22 --2009 changes
           ,rep_cde.action_information23 --2009 changes
           ,rep_cde.action_information24; --2009 changes

  --
  CURSOR csr_PROCEDURE_CODES
          (p_payroll_action_id IN NUMBER) IS
   SELECT cde_dtl.action_information2  legal_employer_id
         ,cde_dtl.action_information3  reporting_code
         ,cde_dtl.action_information10 procedure_name
   FROM   pay_action_information cde_dtl
   WHERE  cde_dtl.action_context_id           = p_payroll_action_id
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information9         = 'PROCEDURE';
  --
  l_plsql_block    VARCHAR2(2000) := 'BEGIN <PROC>(:1, :2, :3); END;';
  l_act_inf_id     NUMBER;
  l_ovn            NUMBER;
  l_amount         NUMBER;
  l_balance_tested BOOLEAN := FALSE;
  l_tax_defbal_id  NUMBER := get_defined_balance(g_business_group_id, 'Tax', '_PER_TU_YTD');
  --
 BEGIN
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  --
  set_parameters(p_payroll_action_id);
  --
  --
  -- Find people who have reportable earnings below 1000 NOK for the legal employer.
  --
  FOR l_per_blw_rep_limit_rec IN csr_LE_PER_BELOW_REP_LIMIT
                                  (p_payroll_action_id)
  LOOP
   l_amount := 0;
   l_balance_tested := FALSE;
   --
   --
   -- Find all ASG_ACT_INFO archive records for the given person / legal employer combination.
   --
   FOR l_asg_act_rec IN csr_ASGACT
                         (p_payroll_action_id
                         ,l_per_blw_rep_limit_rec.legal_employer_id
                         ,l_per_blw_rep_limit_rec.person_id)
   LOOP
    --
    --
    -- See how much tax they have paid while working for legal employer NB. Only need to test balance ONCE
    -- as it is at person level.
    --
    IF NOT l_balance_tested THEN
     --
     --
     -- Setup balance contexts.
     --
     pay_balance_pkg.set_context('TAX_UNIT_ID', l_per_blw_rep_limit_rec.legal_employer_id);
     pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(g_report_date));
     --
     --
     -- Retrieve balance for:-
     --
     --  Tax_PER_TU_YTD
     --
     l_amount := pay_balance_pkg.get_value
                  (p_defined_balance_id => l_tax_defbal_id
                  ,p_assignment_id      => l_asg_act_rec.assignment_id
                  ,p_virtual_date       => g_report_date);
     --
     l_balance_tested := TRUE;
    END IF;
    --
    --
    -- Person is below 1000 NOK reportable earnings AND they haven't paid any tax so update the
    -- ASG_ACT_INFO archive records to identify that. This will put their reporting code details into the
    -- earnings below reporting limit category on the Employer Contribution Summary report.
    --
    IF l_amount = 0 THEN
     pay_action_information_api.update_action_information
      (p_action_information_id => l_asg_act_rec.action_information_id
      ,p_object_version_number => l_asg_act_rec.object_version_number
      ,p_action_information7   => 'Y');
    END IF;
   END LOOP;
  END LOOP;
  --
  --
  -- Loop for all reporting codes that are kept as INDIVIDUAL records.
  --
  FOR l_cde_rec IN csr_INDIVIDUAL_CODES
                    (p_payroll_action_id)
  LOOP
   --
   --
   -- Archive: EMEA REPORT INFORMATION | AUDIT_REP_SUMMARY
   --
   pay_action_information_api.create_action_information
   (p_action_context_type         => 'PA'
   ,p_action_context_id           => p_payroll_action_id
   ,p_action_information_id       => l_act_inf_id
   ,p_object_version_number       => l_ovn
   ,p_effective_date              => g_report_date
   ,p_action_information_category => 'EMEA REPORT INFORMATION'
   ,p_action_information1         => 'AUDIT_REP_SUMMARY'
   ,p_action_information2         => l_cde_rec.legal_employer_id
   ,p_action_information3         => l_cde_rec.person_id
   ,p_action_information4         => l_cde_rec.code
   ,p_action_information5         => l_cde_rec.amount
   ,p_action_information6         => nvl(l_cde_rec.cinfo1, l_cde_rec.info1)
   ,p_action_information7         => nvl(l_cde_rec.cinfo2, l_cde_rec.info2)
   ,p_action_information8         => nvl(l_cde_rec.cinfo3, l_cde_rec.info3)
   ,p_action_information9         => nvl(l_cde_rec.cinfo4, l_cde_rec.info4)
   ,p_action_information10        => nvl(l_cde_rec.cinfo5, l_cde_rec.info5)
   ,p_action_information11        => nvl(l_cde_rec.cinfo6, l_cde_rec.info6)
   ,p_action_information12        => l_cde_rec.tax_municipality
   ,p_action_information13        => l_cde_rec.seaman_component
   ,p_action_information14         => nvl(l_cde_rec.cinfo7, l_cde_rec.info7)    --2009 chnages
   ,p_action_information15        => nvl(l_cde_rec.cinfo8, l_cde_rec.info8)     --2009 chnages
   ,p_action_information16         => nvl(l_cde_rec.cinfo9, l_cde_rec.info9)    --2009 chnages
   ,p_action_information17         => nvl(l_cde_rec.cinfo10, l_cde_rec.info10)  --2009 chnages
   );
  END LOOP;
  --
  --
  -- Loop for all reporting codes that are SUMMED.
  --
  FOR l_cde_rec IN csr_SUM_CODES
                    (p_payroll_action_id)
  LOOP
   --
   --
   -- Archive: EMEA REPORT INFORMATION | AUDIT_REP_SUMMARY
   --
   pay_action_information_api.create_action_information
   (p_action_context_type         => 'PA'
   ,p_action_context_id           => p_payroll_action_id
   ,p_action_information_id       => l_act_inf_id
   ,p_object_version_number       => l_ovn
   ,p_effective_date              => g_report_date
   ,p_action_information_category => 'EMEA REPORT INFORMATION'
   ,p_action_information1         => 'AUDIT_REP_SUMMARY'
   ,p_action_information2         => l_cde_rec.legal_employer_id
   ,p_action_information3         => l_cde_rec.person_id
   ,p_action_information4         => l_cde_rec.code
   ,p_action_information5         => fnd_number.number_to_canonical(l_cde_rec.amount)
   ,p_action_information6         => nvl(l_cde_rec.cinfo1, fnd_number.number_to_canonical(l_cde_rec.info1))
   ,p_action_information7         => nvl(l_cde_rec.cinfo2, fnd_number.number_to_canonical(l_cde_rec.info2))
   ,p_action_information8         => nvl(l_cde_rec.cinfo3, fnd_number.number_to_canonical(l_cde_rec.info3))
   ,p_action_information9         => nvl(l_cde_rec.cinfo4, fnd_number.number_to_canonical(l_cde_rec.info4))
   ,p_action_information10        => nvl(l_cde_rec.cinfo5, fnd_number.number_to_canonical(l_cde_rec.info5))
   ,p_action_information11        => nvl(l_cde_rec.cinfo6, fnd_number.number_to_canonical(l_cde_rec.info6))
   ,p_action_information12        => l_cde_rec.tax_municipality
   ,p_action_information13        => l_cde_rec.seaman_component
   ,p_action_information14        => nvl(l_cde_rec.cinfo7, fnd_number.number_to_canonical(l_cde_rec.info7)) --2009 chnages
   ,p_action_information15        => nvl(l_cde_rec.cinfo8, fnd_number.number_to_canonical(l_cde_rec.info8)) --2009 chnages
   ,p_action_information16        => nvl(l_cde_rec.cinfo9, fnd_number.number_to_canonical(l_cde_rec.info9)) --2009 chnages
   ,p_action_information17        => nvl(l_cde_rec.cinfo10, fnd_number.number_to_canonical(l_cde_rec.info10)) --2009 chnages
   );
  END LOOP;
  --
  --
  -- Loop for all reporting codes that are processed by an external PROCEDURE.
  --
  FOR l_proc_name_rec IN csr_PROCEDURE_CODES
                     (p_payroll_action_id)
  LOOP
   l_plsql_block := REPLACE(l_plsql_block, '<PROC>', l_proc_name_rec.procedure_name);
   --
   --
   -- Dynamically call the stored procedure.
   --
   EXECUTE IMMEDIATE l_plsql_block
   USING p_payroll_action_id
        ,l_proc_name_rec.legal_employer_id
        ,l_proc_name_rec.reporting_code;
  END LOOP;
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
  --
  EXCEPTION
   WHEN OTHERS THEN
     Fnd_file.put_line(FND_FILE.LOG,'## SQLERR ' || sqlerrm(sqlcode));
     hr_utility.set_location(sqlerrm(sqlcode),120);
   --
 END deinitialization_code;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Generates XML for the Norwegian End of Year Audit report.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_audit_data
 (p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.get_audit_data';
  --
  CURSOR csr_LEGEMP
          (l_payroll_action_id IN NUMBER) IS
   SELECT leg_emp.action_information2  legal_employer_id
         ,leg_emp.action_information3  legal_employer_name
         ,leg_emp.action_information4  organization_number
	 ,leg_emp.effective_date               effective_date
   FROM   pay_action_information leg_emp
   WHERE  leg_emp.action_context_type         = 'PA'
     AND  leg_emp.action_context_id           = l_payroll_action_id
     AND  leg_emp.action_information_category = 'EMEA REPORT INFORMATION'
     AND  leg_emp.action_information1         = 'LEG_EMP_INFO'
   ORDER BY leg_emp.action_information3;
  --
  CURSOR csr_PERSON
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,l_seaman_emp        IN VARCHAR2) IS
   SELECT DISTINCT
          summ_cde.action_information3 person_id
         ,summ_cde.action_information12 tax_municipality
         ,per.action_information3 full_name
         ,per.action_information4 employee_number
         ,per.action_information5 national_identifier
         ,per.action_information6 employed_throughout
         ,per.action_information7 seamen
         ,per.action_information8 employment_date_days
   FROM   pay_action_information summ_cde
         ,pay_action_information per
   WHERE  summ_cde.action_context_type         = 'PA'
     AND  summ_cde.action_context_id           = l_payroll_action_id
     AND  summ_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  summ_cde.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  summ_cde.action_information2         = p_legal_employer_id
     AND  per.action_context_type              = summ_cde.action_context_type
     AND  per.action_context_id                = summ_cde.action_context_id
     AND  per.action_information_category      = summ_cde.action_information_category
     AND  per.action_information1              = 'PER_INFO'
     AND  per.action_information2              = summ_cde.action_information3
     AND  per.action_information7              = DECODE(l_seaman_emp,'N',per.action_information7,hr_general.decode_lookup('YES_NO','Y'))
   ORDER BY per.action_information3;
  --
  CURSOR csr_SUMMARY_CODES
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_person_id         IN VARCHAR2
          ,p_tax_municipality  IN VARCHAR2
          ,l_seaman_status     IN VARCHAR2 ) IS
   SELECT summ_cde.action_information4  code
         ,fnd_number.canonical_to_number(summ_cde.action_information5)  amount
         ,summ_cde.action_information6  info1
         ,summ_cde.action_information7  info2
         ,summ_cde.action_information8  info3
         ,summ_cde.action_information9  info4
         ,summ_cde.action_information10 info5
         ,summ_cde.action_information11 info6
         ,summ_cde.action_information14 info7   --2009 changes
         ,summ_cde.action_information15 info8   --2009 changes
         ,summ_cde.action_information16 info9   --2009 changes
         ,summ_cde.action_information17 info10   --2009 changes
         ,pay_no_eoy_archive.get_code_desc(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4)            description
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_dtype   --2009 Changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_dtype   --2009 Changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_dtype   --2009 Changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_dtype   --2009 Changes
   FROM   pay_action_information summ_cde
   WHERE  summ_cde.action_context_type         = 'PA'
     AND  summ_cde.action_context_id           = l_payroll_action_id
     AND  summ_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  summ_cde.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  summ_cde.action_information2         = p_legal_employer_id
     AND  summ_cde.action_information3         = p_person_id
     AND  summ_cde.action_information12        = p_tax_municipality
     AND  summ_cde.action_information13        = l_seaman_status
   ORDER BY summ_cde.action_information2,
            summ_cde.action_information4;
  --
  l_xml_element_count NUMBER := 1;
  l_payroll_action_id NUMBER;
  l_bg_id             NUMBER;
  lg_format_mask      VARCHAR2(40);
  l_desc_count        NUMBER := 0;
  l_seaman_status     VARCHAR2(1);
  --
 BEGIN
  hr_utility.set_location('Entering ' || l_proc_name, 10);
  g_xml_element_table.DELETE;
  g_fixed_code.DELETE;
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
  -- get the currecnt BG's currency and mask to format the amount fields
  --
  fnd_profile.get('PER_BUSINESS_GROUP_ID', l_bg_id);
  set_currency_mask(l_bg_id, lg_format_mask);
  --
  -- Loop for each legal employer.
  --
--  fnd_file.put_line(fnd_file.log,'csr_LEGEMP l_payroll_action_id'||l_payroll_action_id);
  FOR l_legemp_rec IN csr_LEGEMP
                       (l_payroll_action_id)
  LOOP
   --
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_NAME';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.legal_employer_name;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ORG_NUMBER';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.organization_number;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'REP_PERIOD';
   --g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_legemp_rec.effective_date,'DD-MON-YYYY');
   g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(l_legemp_rec.effective_date);
   l_xml_element_count := l_xml_element_count + 1;
   --
   --
   -- Loop for each person within legal employer.
   --
   l_seaman_status := 'N';
   --
   -- Following loop executes csr_PERSON with l_seaman_status = 'N' (for all employees)
   -- and for the second time l_seaman_status = 'Y' (Seaman Workers)
   --
   FOR i IN 1..2 LOOP
   --
   FOR l_person_rec IN csr_PERSON
                        (l_payroll_action_id
                        ,l_legemp_rec.legal_employer_id
                        ,l_seaman_status)
   LOOP
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'PERSON';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    l_desc_count := 0;
    --
    --
    -- Loop for all reporting codes within person, legal employer, and tax municipality.
    --
    FOR l_summ_code_rec IN csr_SUMMARY_CODES
                            (l_payroll_action_id
                            ,l_legemp_rec.legal_employer_id
                            ,l_person_rec.person_id
                            ,l_person_rec.tax_municipality
                            ,l_seaman_status)
    LOOP
     --
     l_desc_count := 1;
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'REP_CODE';
     g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
     l_xml_element_count := l_xml_element_count + 1;
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'CODE';
     g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.code;
     l_xml_element_count := l_xml_element_count + 1;
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'AMOUNT';
     g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_summ_code_rec.amount,lg_format_mask);
     g_xml_element_table(l_xml_element_count).tagtype  := 'A';
     l_xml_element_count := l_xml_element_count + 1;
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
     g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.description;
     l_xml_element_count := l_xml_element_count + 1;
     --
     IF l_summ_code_rec.info1_prompt IS NOT NULL AND l_summ_code_rec.info1 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info1_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info1_dtype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info1), lg_format_mask);
      ELSIF l_summ_code_rec.info1_dtype = 'D' AND l_summ_code_rec.info1 <> '0' THEN
      g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info1));

      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info1;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info2_prompt IS NOT NULL AND l_summ_code_rec.info2 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info2_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info2_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info2),lg_format_mask);
      ELSIF l_summ_code_rec.info2_dtype = 'D' AND l_summ_code_rec.info2 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info2));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info2),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info2;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info3_prompt IS NOT NULL AND l_summ_code_rec.info3 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info3_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info3_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info3), lg_format_mask);
      ELSIF l_summ_code_rec.info3_dtype = 'D' AND l_summ_code_rec.info3 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info3));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info3),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info3;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info4_prompt IS NOT NULL AND l_summ_code_rec.info4 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info4_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info4_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info4),lg_format_mask);
      ELSIF l_summ_code_rec.info4_dtype = 'D' AND l_summ_code_rec.info4 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info4));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info4),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info4;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info5_prompt IS NOT NULL AND l_summ_code_rec.info5 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info5_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info5_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info5), lg_format_mask);
      ELSIF l_summ_code_rec.info5_dtype = 'D' AND l_summ_code_rec.info5 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info5));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info5),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info5;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info6_prompt IS NOT NULL AND l_summ_code_rec.info6 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info6_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info6_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info6),lg_format_mask);
      ELSIF l_summ_code_rec.info6_dtype = 'D' AND l_summ_code_rec.info6 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info6));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info6),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info6;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     -- 2009 changes starts
      IF l_summ_code_rec.info7_prompt IS NOT NULL AND l_summ_code_rec.info7 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info7_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info7_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info7),lg_format_mask);
      ELSIF l_summ_code_rec.info7_dtype = 'D' AND l_summ_code_rec.info7 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info7));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info7),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info7;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
      IF l_summ_code_rec.info8_prompt IS NOT NULL AND l_summ_code_rec.info8 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info8_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info8_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info8),lg_format_mask);
      ELSIF l_summ_code_rec.info8_dtype = 'D' AND l_summ_code_rec.info8 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info8));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info8),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info8;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
      IF l_summ_code_rec.info9_prompt IS NOT NULL AND l_summ_code_rec.info9 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info9_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info9_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info9),lg_format_mask);
      ELSIF l_summ_code_rec.info9_dtype = 'D' AND l_summ_code_rec.info9 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info9));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info9),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info9;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
      IF l_summ_code_rec.info10_prompt IS NOT NULL AND l_summ_code_rec.info10 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info10_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info10_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info10),lg_format_mask);
      ELSIF l_summ_code_rec.info10_dtype = 'D' AND l_summ_code_rec.info10 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info10));
	--g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_date.canonical_to_date(l_summ_code_rec.info10),'DD-MM-YYYY');
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info10;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     -- 2009 changes ends
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'REP_CODE';
     g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
     l_xml_element_count := l_xml_element_count + 1;
    END LOOP;
    --
    IF l_desc_count = 1 THEN
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'NAME';
      g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.full_name;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'NI_NUMBER';
      g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.national_identifier;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMP_NO';
      g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employee_number;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYED_THROUGHOUT';
      g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employed_throughout;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'SEAMEN';
      g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.seamen;   -- Fix For Seamen Display 2007/2008
  --g_xml_element_table(l_xml_element_count).tagvalue := hr_general.decode_lookup('YES_NO',l_seaman_status);
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'TAX_MUNICIPALITY';
      g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.tax_municipality;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYMENT_DATES';
      g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employment_date_days;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'PERSON';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
      --
     ELSE
      --
      l_xml_element_count := l_xml_element_count - 1;
      g_xml_element_table(l_xml_element_count).tagname  := NULL;
      g_xml_element_table(l_xml_element_count).tagvalue := NULL;
      --
     END IF;
    --
    END LOOP;
    --
    l_seaman_status := 'Y';
    --
   END LOOP;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
   l_xml_element_count := l_xml_element_count + 1;
  END LOOP;
  --
  write_to_clob(p_xml);
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END get_audit_data;
 --
 --
 ------------------------------------------------------------------------------------
 -- Generates Norwegian End of Year Employer Contribution Summary Report
 --
 -----------------------------------------------------------------------------------
 --
 PROCEDURE get_employer_contribution_data
 (p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.get_employer_contribution_data';
  --
  --
  -- Cursor to get the Values for the NI Zones and the Tax Municipal Details 2007/08 changes
  --
  CURSOR csr_LE_SI_LU_TM_INFO
          (l_payroll_action_id IN NUMBER) IS
   SELECT DISTINCT
     le_lu_tm.action_information3   si_status
         ,le_lu_tm.action_information4   local_unit_id
--         ,le_lu_tm.action_information5   local_unit
         ,le_lu_tm.action_information6   tax_municipality_id
         ,le_lu_tm.action_information7   tax_municipality
         ,le_lu_tm.action_information8   ni_zone_arc
	 ,fnd_number.canonical_to_number(le_lu_tm.action_information9)   emp_contr_bse
         ,fnd_number.canonical_to_number(le_lu_tm.action_information10)  reimb_bse
	 ,fnd_number.canonical_to_number(le_lu_tm.action_information11)  pension_bse
   FROM   pay_action_information le_lu_tm
   WHERE  le_lu_tm.action_context_type           = 'PA'
     AND  le_lu_tm.action_context_id             = l_payroll_action_id
     AND  le_lu_tm.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu_tm.action_information1           = 'LE_SI_LU_TM_INFO';
  --
  CURSOR csr_LE_SI
          (l_payroll_action_id IN NUMBER) IS
   SELECT DISTINCT
          le_lu.action_information2    legal_employer_id
         ,le_lu.action_information3    si_status
         ,le_lu.action_information5    nace_code             -- changes 2007/08
         ,leg_emp.action_information3  legal_employer_name
         ,leg_emp.action_information4  organization_number
--         ,leg_emp.action_information5  le_addr1
--         ,leg_emp.action_information6  le_addr2
--         ,leg_emp.action_information7  le_addr3
--         ,leg_emp.action_information8  le_postcode
--         ,leg_emp.action_information9  le_postoffice
         ,leg_emp.action_information10 tax_office_name
--         ,leg_emp.action_information11 to_addr1
--         ,leg_emp.action_information12 to_addr2
--         ,leg_emp.action_information13 to_addr3
--         ,leg_emp.action_information14 to_postcode
--         ,leg_emp.action_information15 to_postoffice
       ,leg_emp.action_information16 le_tax_muncipality  --2007/2008 Changes
       ,leg_emp.action_information17 le_economic_aid     -- 2007/2008 Changes
    	 ,leg_emp.effective_date       effective_date
   FROM   pay_action_information le_lu
         ,pay_action_information leg_emp
   WHERE  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  leg_emp.action_context_type         = 'PA'
     AND  leg_emp.action_context_id           = le_lu.action_context_id
     AND  leg_emp.action_information_category = 'EMEA REPORT INFORMATION'
     AND  leg_emp.action_information1         = 'LEG_EMP_INFO'
     AND  leg_emp.action_information2         = le_lu.action_information2;
  --
  CURSOR csr_LE_SI_BAL_SUMMARY
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT
--          fnd_number.canonical_to_number(le_si_bals.action_information4)  emp_contr_ni_zone1
--         ,fnd_number.canonical_to_number(le_si_bals.action_information5)  emp_contr_ni_zone2
--         ,fnd_number.canonical_to_number(le_si_bals.action_information6)  emp_contr_ni_zone3
--         ,fnd_number.canonical_to_number(le_si_bals.action_information7)  emp_contr_ni_zone4
--         ,fnd_number.canonical_to_number(le_si_bals.action_information8)  emp_contr_ni_zone5
          fnd_number.canonical_to_number(le_si_bals.action_information9)  emp_contr_ni_total
--         ,fnd_number.canonical_to_number(le_si_bals.action_information10) emp_contr_o62_ni_zone1
--         ,fnd_number.canonical_to_number(le_si_bals.action_information11) emp_contr_o62_ni_zone2
--         ,fnd_number.canonical_to_number(le_si_bals.action_information12) emp_contr_o62_ni_zone3
--         ,fnd_number.canonical_to_number(le_si_bals.action_information13) emp_contr_o62_ni_zone4
--         ,fnd_number.canonical_to_number(le_si_bals.action_information14) emp_contr_o62_ni_zone5
--         ,fnd_number.canonical_to_number(le_si_bals.action_information15) emp_contr_o62_ni_total
         ,fnd_number.canonical_to_number(le_si_bals.action_information16) tax
         ,fnd_number.canonical_to_number(le_si_bals.action_information17) emp_contr_spcl_pct_base
--         ,fnd_number.canonical_to_number(le_si_bals.action_information18) emp_contr_spcl_pct
         ,fnd_number.canonical_to_number(le_si_bals.action_information19) emp_contr_spcl
--         ,fnd_number.canonical_to_number(le_si_bals.action_information20) foreign_special_percentage
         ,fnd_number.canonical_to_number(le_si_bals.action_information21) foreign_special_amount
	 ,fnd_number.canonical_to_number(le_si_bals.action_information22) emp_contr_reimb_spcl_base  --2007/2008 changes
         ,fnd_number.canonical_to_number(le_si_bals.action_information23) tot_reimb_bse           --2007/2008 changes
	 ,fnd_number.canonical_to_number(le_si_bals.action_information24) tot_pension_bse         -- 2007/2008 Changes
   FROM   pay_action_information le_si_bals
   WHERE  le_si_bals.action_context_type         = 'PA'
     AND  le_si_bals.action_context_id           = l_payroll_action_id
     AND  le_si_bals.action_information_category = 'EMEA REPORT INFORMATION'
     AND  le_si_bals.action_information1         = 'LE_SI_BALS'
     AND  le_si_bals.action_information2         = p_legal_employer_id
     AND  le_si_bals.action_information3         = p_si_status;
  --
  CURSOR csr_LE_SI_CODE_SUMMARY
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT COUNT (DISTINCT asg_act.action_information5) certificates
/*	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'1N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone1
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'2N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone2
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'3N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone3
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'4N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone4
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'5N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone5*/
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'1Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone1
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'2Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone2
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'3Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone3
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'4Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone4
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'5Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone5
/*	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'11', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone1
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'21', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone2
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'31', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone3
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'41', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone4
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'51', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone5
	 ,SUM(DECODE(TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_totals*/
   FROM   pay_assignment_actions paa
         ,pay_action_information le_lu
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = le_lu.action_context_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_information2         = le_lu.action_information2
     AND  asg_act.action_information3         = le_lu.action_information4
     AND  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  le_lu.action_information2           = p_legal_employer_id
     AND  le_lu.action_information3           = p_si_status
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = le_lu.action_context_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = le_lu.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  cde_dtl.action_information6         = 'Y'
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
   GROUP BY asg_act.action_information2
           ,le_lu.action_information3;
  --
  CURSOR csr_LE_SI_CODE_TOTAL_SUMMARY
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT
/*       SUM(DECODE(asg_act.action_information7
                    ,'N', fnd_number.canonical_to_number(rep_cde.action_information3)
                    , 0)) a_earnings
       ,SUM(DECODE(asg_act.action_information7
                     ,'Y', fnd_number.canonical_to_number(rep_cde.action_information3)
                    , 0)) bl_earnings
	     ,*/
	SUM(fnd_number.canonical_to_number(rep_cde.action_information3)) sum_earnings
   FROM   pay_assignment_actions paa
         ,pay_action_information le_lu
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = le_lu.action_context_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_information2         = le_lu.action_information2
     AND  asg_act.action_information3         = le_lu.action_information4
     AND  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  le_lu.action_information2           = p_legal_employer_id
     AND  le_lu.action_information3           = p_si_status
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = le_lu.action_context_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = le_lu.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  cde_dtl.action_information6         = 'Y'
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
     AND  rep_cde.action_information2         NOT IN ('000','250','311','312','313','314','315','316','950')  -- Changes 2007/2008
   GROUP BY asg_act.action_information2
           ,le_lu.action_information3;
--
 /*
   CURSOR csr_LE_SI_CODE_TOTALS
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT asg_act.action_information2 legal_employer_id
         ,le_lu.action_information3 si_status
         ,DECODE(cde_dtl.action_information4, 'Y', rep_cde.action_information2, 'TOTAL_OTHER_CODES') code
         ,SUM(fnd_number.canonical_to_number(rep_cde.action_information3)) amount
   FROM   pay_assignment_actions paa
         ,pay_action_information le_lu
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = le_lu.action_context_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_information2         = le_lu.action_information2
     AND  asg_act.action_information3         = le_lu.action_information4
     AND  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  le_lu.action_information2           = p_legal_employer_id
     AND  le_lu.action_information3           = p_si_status
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = le_lu.action_context_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = le_lu.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
   GROUP BY asg_act.action_information2
           ,le_lu.action_information3
           ,DECODE(cde_dtl.action_information4, 'Y',rep_cde.action_information2, 'TOTAL_OTHER_CODES');
*/
--
/*  CURSOR csr_SI_STATUS IS
   SELECT lu.lookup_code si_status
   FROM   hr_lookups lu
   WHERE  lu.lookup_type = 'NO_LEGAL_EMP_SI_STATUS';*/
  --
  l_total_below_rep_limit   NUMBER;
  l_xml_element_count       NUMBER := 1;
  l_total_codes             NUMBER;
  l_bg_id                   NUMBER;
  lg_format_mask            VARCHAR2(40);
  l_payroll_action_id       NUMBER;
--  l_si_sts_rec              csr_SI_STATUS%ROWTYPE;
  l_le_si_rec               csr_LE_SI%ROWTYPE;
  l_le_si_code_rec          csr_LE_SI_CODE_SUMMARY%ROWTYPE;
  l_le_si_code_total_rec    csr_LE_SI_CODE_TOTAL_SUMMARY%ROWTYPE;
  l_le_si_bal_rec           csr_LE_SI_BAL_SUMMARY%ROWTYPE;
--  l_le_si_total_rec         csr_LE_SI_CODE_TOTALS%ROWTYPE;
  l_net_emp_contr_bse       NUMBER := 0;
  l_gross_emp_contr_bse     NUMBER := 0;
  l_spcl_net_base           NUMBER := 0;
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
  -- get the currecnt BG's currency and mask to format the amount fields
  --
  fnd_profile.get('PER_BUSINESS_GROUP_ID', l_bg_id);
  set_currency_mask(l_bg_id, lg_format_mask);
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'EMPR_CONTR';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Loop for each unique legal employer / SI status combination.
  --
  --
  OPEN csr_LE_SI
        (l_payroll_action_id);
  LOOP
   FETCH csr_LE_SI INTO l_le_si_rec;
   EXIT WHEN csr_LE_SI%NOTFOUND;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'EFFECTIVE_DATE';
   g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(l_le_si_rec.effective_date);
   l_xml_element_count := l_xml_element_count + 1;
   -- ORID-16513 - 2007/2008 Changes
   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_OFFICE';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_tax_muncipality;
   l_xml_element_count := l_xml_element_count + 1;
   -- ORID -25795
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_NAME';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.legal_employer_name;
   l_xml_element_count := l_xml_element_count + 1;
   -- ORID -21772
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ORG_NUMBER';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.organization_number;
   l_xml_element_count := l_xml_element_count + 1;
   -- ORID-27602 - 2007/2008 Changes
   g_xml_element_table(l_xml_element_count).tagname  := 'INDUSTRY_CODE';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.nace_code;
   l_xml_element_count := l_xml_element_count + 1;
   -- ORID 27603 Calculation Method - 2007/2008 Changes
   g_xml_element_table(l_xml_element_count).tagname  := 'CALCULATION_METHOD';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.si_status;
   l_xml_element_count := l_xml_element_count + 1;
   -- ORID 27604 Economic Aid Received - 2007/2008 Changes
   g_xml_element_table(l_xml_element_count).tagname  := 'ECONOMIC_AID';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_rec.le_economic_aid),lg_format_mask);
   l_xml_element_count := l_xml_element_count + 1;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ADDRESS1';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_addr1;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ADDRESS2';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_addr2;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ADDRESS3';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_addr3;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_POSTCODE1';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_postcode;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_POSTCODE2';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_postoffice;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_OFFICE_NAME';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.tax_office_name;
   l_xml_element_count := l_xml_element_count + 1;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_OFFICE_ADDRESS1';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.to_addr1;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_OFFICE_ADDRESS2';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.to_addr2;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_OFFICE_ADDRESS3';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.to_addr3;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_OFFICE_POSTCODE1';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.to_postcode;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_OFFICE_POSTCODE2';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.to_postoffice;
   l_xml_element_count := l_xml_element_count + 1;*/
   --
   --
/*   -- Loop through all 7 SI statuses.
   --
   OPEN csr_SI_STATUS;
   LOOP
    FETCH csr_SI_STATUS INTO l_si_sts_rec;
    EXIT WHEN csr_SI_STATUS%NOTFOUND;
    --
    g_xml_element_table(l_xml_element_count).tagname  := l_si_sts_rec.si_status;
    --
    --
    -- Set to X for the SI status being reported on.
    --
    IF l_si_sts_rec.si_status = l_le_si_rec.si_status THEN
     g_xml_element_table(l_xml_element_count).tagvalue := 'X';
    ELSE
     g_xml_element_table(l_xml_element_count).tagvalue := ' ';
    END IF;
    --
    l_xml_element_count := l_xml_element_count + 1;
   END LOOP;
   CLOSE csr_SI_STATUS;
   --*/
   --
   -- Fetch all balances for the legal employer / SI status combination.
   --
   OPEN csr_LE_SI_BAL_SUMMARY
         (l_payroll_action_id
         ,l_le_si_rec.legal_employer_id
         ,l_le_si_rec.si_status);
   FETCH csr_LE_SI_BAL_SUMMARY INTO l_le_si_bal_rec;
   CLOSE csr_LE_SI_BAL_SUMMARY;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_ZONE1';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_ni_zone1),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_ZONE2';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_ni_zone2),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_ZONE3';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_ni_zone3),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_ZONE4';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_ni_zone4),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_ZONE5';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_ni_zone5),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_TOTAL';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_ni_total),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_O62_ZONE1';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_o62_ni_zone1),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_O62_ZONE2';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_o62_ni_zone2),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_O62_ZONE3';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_o62_ni_zone3),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_O62_ZONE4';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_o62_ni_zone4),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_O62_ZONE5';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_o62_ni_zone5),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'EC_O62_TOTAL';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_o62_ni_total),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
   -- Total witholding Tax
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'A_TAX';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.tax),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- ORID 22225 - Gross Base for Employees from USA/Canada
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'FE_PCT_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_spcl_pct_base),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'FE_PCT';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.foreign_special_percentage),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'FE_PCT_AMOUNT';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_spcl_pct),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   -- ORID 25415 Total number of months Foreign Employees on Monthly Rate
   g_xml_element_table(l_xml_element_count).tagname  := 'FE_MONTHS';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_bal_rec.emp_contr_spcl / l_le_si_bal_rec.foreign_special_amount;
   l_xml_element_count := l_xml_element_count + 1;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'FE_MONTHS_RATE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.foreign_special_amount,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'FE_MONTHS_AMOUNT';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.emp_contr_spcl,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
   --Reimbursement Base Employees From USA/Canada ORID-27612 - 2007/2008 Changes
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'FE_REIMBURSEMENT_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_reimb_spcl_base),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;

   -- Net Base for Employees from USA/Canada - 2007/2008 Changes
   l_spcl_net_base := nvl(l_le_si_bal_rec.emp_contr_spcl_pct_base,0) - nvl(l_le_si_bal_rec.emp_contr_reimb_spcl_base,0);
   g_xml_element_table(l_xml_element_count).tagname  := 'FE_NET_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_spcl_net_base,lg_format_mask);
   l_xml_element_count := l_xml_element_count + 1;
   --ORID 28103 Total EC Base - 2007/2008 Changes
   g_xml_element_table(l_xml_element_count).tagname  := 'TOT_EC_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.emp_contr_ni_total),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   -- ORID 28104 Total Pension Base
   g_xml_element_table(l_xml_element_count).tagname  := 'TOT_PEN_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_bal_rec.tot_pension_bse),lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   --Gross Employer Contribution Base - 2007/2008 Changes
   --
   l_gross_emp_contr_bse := nvl(l_le_si_bal_rec.emp_contr_ni_total,0) + nvl(l_le_si_bal_rec.tot_pension_bse,0);
   g_xml_element_table(l_xml_element_count).tagname  := 'GROSS_EMP_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_gross_emp_contr_bse,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   --
   -- Total Reimbursement base ORID 28105 -  2007/2008 Changes
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TOT_REIMB_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.tot_reimb_bse,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- Net Employer Contribution Base - 2007/2008 Changes
   --
   l_net_emp_contr_bse := l_gross_emp_contr_bse - nvl(l_le_si_bal_rec.tot_reimb_bse,0) ;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TOT_NET_BASE';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_net_emp_contr_bse,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- Loop through the reporting code information.
   --
   OPEN csr_LE_SI_CODE_SUMMARY
         (l_payroll_action_id
         ,l_le_si_rec.legal_employer_id
         ,l_le_si_rec.si_status);
   FETCH csr_LE_SI_CODE_SUMMARY INTO l_le_si_code_rec;
   CLOSE csr_LE_SI_CODE_SUMMARY;
   --
   OPEN csr_LE_SI_CODE_TOTAL_SUMMARY
         (l_payroll_action_id
         ,l_le_si_rec.legal_employer_id
         ,l_le_si_rec.si_status);
   FETCH csr_LE_SI_CODE_TOTAL_SUMMARY INTO l_le_si_code_total_rec;
   CLOSE csr_LE_SI_CODE_TOTAL_SUMMARY;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'A_ROW';
   g_xml_element_table(l_xml_element_count).tagvalue := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
   -- Number of Certificates
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'A_CERTIFICATES';
   g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_code_rec.certificates;
   l_xml_element_count := l_xml_element_count + 1;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'A_EARNINGS';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_total_rec.a_earnings,lg_format_mask);
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'A_ZONE1';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.a_zone1,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'A_ZONE2';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.a_zone2,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'A_ZONE3';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.a_zone3,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'A_ZONE4';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.a_zone4,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'A_ZONE5';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.a_zone5,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'B_ROW';
   g_xml_element_table(l_xml_element_count).tagvalue := 'B';
   l_xml_element_count := l_xml_element_count + 1;*/

   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'BL_EARNINGS';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_total_rec.bl_earnings,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'BL_ZONE1';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.bl_zone1,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'BL_ZONE2';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.bl_zone2,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'BL_ZONE3';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.bl_zone3,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'BL_ZONE4';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.bl_zone4,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'BL_ZONE5';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.bl_zone5,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
   -- Total Earnings Below Reporting Limit 2007/2008 changes
   l_total_below_rep_limit := nvl(l_le_si_code_rec.bl_zone1,0)+ nvl(l_le_si_code_rec.bl_zone2,0)+ nvl(l_le_si_code_rec.bl_zone3,0)
--                               + nvl(l_le_si_code_rec.bl_zone4,0)+ nvl(l_le_si_code_rec.bl_zone2,0);
                               + nvl(l_le_si_code_rec.bl_zone4,0)+ nvl(l_le_si_code_rec.bl_zone5,0);
   g_xml_element_table(l_xml_element_count).tagname  := 'TOT_EAR_BELOW_REP_LIMIT';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_total_below_rep_limit,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- Total Reportable Earnings according to Certificates
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'SUM_EARNINGS';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_total_rec.sum_earnings,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'SUM_ZONE1';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.sum_zone1,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'SUM_ZONE2';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.sum_zone2,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'SUM_ZONE3';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.sum_zone3,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'SUM_ZONE4';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.sum_zone4,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'SUM_ZONE5';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.sum_zone5,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_xml_element_table(l_xml_element_count).tagname  := 'SUM_TOTALS';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_code_rec.sum_totals,lg_format_mask);
   g_xml_element_table(l_xml_element_count).tagtype  := 'A';
   l_xml_element_count := l_xml_element_count + 1;*/
   --
/*   g_fixed_code(1).fixed_code := '111-A';
   g_fixed_code(1).status     := 0;
   g_fixed_code(2).fixed_code := '112-A';
   g_fixed_code(2).status     := 0;
   g_fixed_code(3).fixed_code := '116-A';
   g_fixed_code(3).status     := 0;
   g_fixed_code(4).fixed_code := '211';
   g_fixed_code(4).status     := 0;
   g_fixed_code(5).fixed_code := '311';
   g_fixed_code(5).status     := 0;
   g_fixed_code(6).fixed_code := '312';
   g_fixed_code(6).status     := 0;
   g_fixed_code(7).fixed_code := '313';
   g_fixed_code(7).status     := 0;
   g_fixed_code(8).fixed_code := '314';
   g_fixed_code(8).status     := 0;
   g_fixed_code(9).fixed_code := '316';
   g_fixed_code(9).status     := 0;
   g_fixed_code(10).fixed_code := '401';
   g_fixed_code(10).status     := 0;
   g_fixed_code(11).fixed_code := '711';
   g_fixed_code(11).status     := 0;
   g_fixed_code(12).fixed_code := '950';
   g_fixed_code(12).status     := 0;
   g_fixed_code(13).fixed_code :='TOTAL_OTHER_CODES';
   g_fixed_code(13).status     := 0;
   --
   --
   -- Loop through all fixed codes.
   --
   l_total_codes := 0;
   OPEN csr_LE_SI_CODE_TOTALS
         (l_payroll_action_id
         ,l_le_si_rec.legal_employer_id
         ,l_le_si_rec.si_status);
   LOOP
    FETCH csr_LE_SI_CODE_TOTALS INTO l_le_si_total_rec;
    EXIT WHEN csr_LE_SI_CODE_TOTALS%NOTFOUND;
    --
    --
    -- XML TAG name is based on reporting code.
    --
    g_xml_element_table(l_xml_element_count).tagname  := '_' || REPLACE(l_le_si_total_rec.code,'-');
    g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_total_rec.amount,lg_format_mask);
    g_xml_element_table(l_xml_element_count).tagtype  := 'A';
    l_xml_element_count := l_xml_element_count + 1;
    --
    FOR rec_fixed_code in 1..13 LOOP
      --
      IF g_fixed_code(rec_fixed_code).fixed_code = l_le_si_total_rec.code THEN
        g_fixed_code(rec_fixed_code).status := 1;
        EXIT;
      END IF;
      --
    END LOOP;
    --
    l_total_codes := l_total_codes + nvl(l_le_si_total_rec.amount,0);
   END LOOP;
   CLOSE csr_LE_SI_CODE_TOTALS;
   --
   FOR rec_fixed_code in 1..13 LOOP
      --
      IF g_fixed_code(rec_fixed_code).status = 0 THEN
        --
        g_fixed_code(rec_fixed_code).status := 1;
        g_xml_element_table(l_xml_element_count).tagname  := '_' || REPLACE(g_fixed_code(rec_fixed_code).fixed_code,'-');
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(0,lg_format_mask);
        g_xml_element_table(l_xml_element_count).tagtype  := 'A';
        l_xml_element_count := l_xml_element_count + 1;
      --
      END IF;
      --
   END LOOP;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'PROMPT_111A';
   g_xml_element_table(l_xml_element_count).tagvalue := '111A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'PROMPT_112A';
   g_xml_element_table(l_xml_element_count).tagvalue := '112A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'PROMPT_116A';
   g_xml_element_table(l_xml_element_count).tagvalue := '116A';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TOTAL_ALL_CODES';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_total_codes,lg_format_mask);
   l_xml_element_count := l_xml_element_count + 1;*/
   --

-- 8881234 - XML Tags for Second Page of Report
  FOR l_le_si_lu_tm_rec IN  csr_LE_SI_LU_TM_INFO
                                (l_payroll_action_id)
  LOOP
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'SPECIFICATION';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --Organization Number (Local Unit)
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ORGANIZATION_NUMBER';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_lu_tm_rec.local_unit_id;
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Local Unit Municipal Number
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'MUNICIPAL_NUMBER';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_lu_tm_rec.tax_municipality_id;
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Local Unit Municipal Name
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'MUNICIPAL_NAME';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_lu_tm_rec.tax_municipality;
  l_xml_element_count := l_xml_element_count + 1;
  --
  --  Employer Contribution Zone
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ZONE';
  g_xml_element_table(l_xml_element_count).tagvalue :=  l_le_si_lu_tm_rec.ni_zone_arc;
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Employer Contribution Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TOTAL_BASIS';
  g_xml_element_table(l_xml_element_count).tagvalue :=  to_char(l_le_si_lu_tm_rec.emp_contr_bse ,lg_format_mask);
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Pension Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'PENSION_BASE';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_lu_tm_rec.pension_bse,lg_format_mask);
  l_xml_element_count := l_xml_element_count + 1;
  --
  --Gross Employer Contribution Base
  --
  l_gross_emp_contr_bse := l_le_si_lu_tm_rec.emp_contr_bse + l_le_si_lu_tm_rec.pension_bse;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'GROSS_BASE';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_gross_emp_contr_bse,lg_format_mask);
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Reimbursement Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'REIMBURSED';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_lu_tm_rec.reimb_bse,lg_format_mask);
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Net Employer Contribution Base
  l_net_emp_contr_bse := l_gross_emp_contr_bse - l_le_si_lu_tm_rec.reimb_bse ;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'NET_BASE';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_net_emp_contr_bse,lg_format_mask);
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'SPECIFICATION';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  END LOOP;
-- 8881234 - End of XML Tags for Second Page of Report
--
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
   l_xml_element_count := l_xml_element_count + 1;
  END LOOP;
  CLOSE csr_LE_SI;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'EMPR_CONTR';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  write_to_clob(p_xml);
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END get_employer_contribution_data;
 --
 --
 --
 -- -----------------------------------------------------------------------------
 -- Generates XML for the Norwegian End of Year Employer Contribution Summary
 -- report. Changes -2007/2008
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_employer_contribution_xml
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.get_employer_contribution_xml';
  --
  -- Cursor to get the Values for the NI Zones and the Tax Municipal Details 2007/08 changes
  --
  CURSOR csr_LE_SI_LU_TM_INFO
          (l_payroll_action_id IN NUMBER) IS
   SELECT DISTINCT
   	  le_lu_tm.action_information3   si_status
         ,le_lu_tm.action_information4   local_unit_id
         ,le_lu_tm.action_information5   local_unit
         ,le_lu_tm.action_information6   tax_municipality_id
         ,le_lu_tm.action_information7   tax_municipality
         ,le_lu_tm.action_information8   ni_zone_arc
	 ,fnd_number.canonical_to_number(le_lu_tm.action_information9)   emp_contr_bse
         ,fnd_number.canonical_to_number(le_lu_tm.action_information10)  reimb_bse
	 ,fnd_number.canonical_to_number(le_lu_tm.action_information11)  pension_bse
   FROM   pay_action_information le_lu_tm
   WHERE  le_lu_tm.action_context_type           = 'PA'
     AND  le_lu_tm.action_context_id             = l_payroll_action_id
     AND  le_lu_tm.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu_tm.action_information1           = 'LE_SI_LU_TM_INFO';
  --
  CURSOR csr_LE_SI
          (l_payroll_action_id IN NUMBER) IS
   SELECT DISTINCT
          le_lu.action_information2    legal_employer_id
         ,le_lu.action_information3    si_status
	 ,le_lu.action_information5    nace_code             -- changes 2007/08
         ,leg_emp.action_information3  legal_employer_name
         ,leg_emp.action_information4  organization_number
         ,leg_emp.action_information5  le_addr1
         ,leg_emp.action_information6  le_addr2
         ,leg_emp.action_information7  le_addr3
         ,leg_emp.action_information8  le_postcode
         ,leg_emp.action_information9  le_postoffice
         ,leg_emp.action_information10 tax_office_name
         ,leg_emp.action_information11 to_addr1
         ,leg_emp.action_information12 to_addr2
         ,leg_emp.action_information13 to_addr3
         ,leg_emp.action_information14 to_postcode
         ,leg_emp.action_information15 to_postoffice
	 ,leg_emp.action_information16 le_tax_muncipality    -- 2007/2008 Changes
	 ,leg_emp.action_information17 le_economic_aid        -- 2007/2008 Changes
    	 ,leg_emp.effective_date       effective_date
   FROM   pay_action_information le_lu
         ,pay_action_information leg_emp
   WHERE  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  leg_emp.action_context_type         = 'PA'
     AND  leg_emp.action_context_id           = le_lu.action_context_id
     AND  leg_emp.action_information_category = 'EMEA REPORT INFORMATION'
     AND  leg_emp.action_information1         = 'LEG_EMP_INFO'
     AND  leg_emp.action_information2         = le_lu.action_information2;
  --
  CURSOR csr_LE_SI_BAL_SUMMARY
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT fnd_number.canonical_to_number(le_si_bals.action_information4)  emp_contr_ni_zone1
         ,fnd_number.canonical_to_number(le_si_bals.action_information5)  emp_contr_ni_zone2
         ,fnd_number.canonical_to_number(le_si_bals.action_information6)  emp_contr_ni_zone3
         ,fnd_number.canonical_to_number(le_si_bals.action_information7)  emp_contr_ni_zone4
         ,fnd_number.canonical_to_number(le_si_bals.action_information8)  emp_contr_ni_zone5
         ,fnd_number.canonical_to_number(le_si_bals.action_information9)  emp_contr_ni_total
         ,fnd_number.canonical_to_number(le_si_bals.action_information10) emp_contr_o62_ni_zone1
         ,fnd_number.canonical_to_number(le_si_bals.action_information11) emp_contr_o62_ni_zone2
         ,fnd_number.canonical_to_number(le_si_bals.action_information12) emp_contr_o62_ni_zone3
         ,fnd_number.canonical_to_number(le_si_bals.action_information13) emp_contr_o62_ni_zone4
         ,fnd_number.canonical_to_number(le_si_bals.action_information14) emp_contr_o62_ni_zone5
         ,fnd_number.canonical_to_number(le_si_bals.action_information15) emp_contr_o62_ni_total
         ,fnd_number.canonical_to_number(le_si_bals.action_information16) tax
         ,fnd_number.canonical_to_number(le_si_bals.action_information17) emp_contr_spcl_pct_base
         ,fnd_number.canonical_to_number(le_si_bals.action_information18) emp_contr_spcl_pct
         ,fnd_number.canonical_to_number(le_si_bals.action_information19) emp_contr_spcl
         ,fnd_number.canonical_to_number(le_si_bals.action_information20) foreign_special_percentage
         ,fnd_number.canonical_to_number(le_si_bals.action_information21) foreign_special_amount
	 ,fnd_number.canonical_to_number(le_si_bals.action_information22) emp_contr_reimb_spcl_base  --2007/2008 changes
         ,fnd_number.canonical_to_number(le_si_bals.action_information23) tot_reimb_bse           --2007/2008 changes
	 ,fnd_number.canonical_to_number(le_si_bals.action_information24) tot_pension_bse         -- 2007/2008 Changes
   FROM   pay_action_information le_si_bals
   WHERE  le_si_bals.action_context_type         = 'PA'
     AND  le_si_bals.action_context_id           = l_payroll_action_id
     AND  le_si_bals.action_information_category = 'EMEA REPORT INFORMATION'
     AND  le_si_bals.action_information1         = 'LE_SI_BALS'
     AND  le_si_bals.action_information2         = p_legal_employer_id
     AND  le_si_bals.action_information3         = p_si_status;
  --
  CURSOR csr_LE_SI_CODE_SUMMARY
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT COUNT (DISTINCT asg_act.action_information5) certificates
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'1N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone1
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'2N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone2
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'3N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone3
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'4N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone4
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'5N1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) a_zone5
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'1Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone1
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'2Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone2
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'3Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone3
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'4Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone4
	 ,SUM(DECODE(asg_act.action_information4 || asg_act.action_information7 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'5Y1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) bl_zone5
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'11', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone1
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'21', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone2
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'31', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone3
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'41', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone4
	 ,SUM(DECODE(asg_act.action_information4 || TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'51', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_zone5
	 ,SUM(DECODE(TO_CHAR(SIGN(INSTR(rep_cde.action_information2, 'A')))
                    ,'1', fnd_number.canonical_to_number(rep_cde.action_information3)
                    ,0)) sum_totals
   FROM   pay_assignment_actions paa
         ,pay_action_information le_lu
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = le_lu.action_context_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_information2         = le_lu.action_information2
     AND  asg_act.action_information3         = le_lu.action_information4
     AND  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  le_lu.action_information2           = p_legal_employer_id
     AND  le_lu.action_information3           = p_si_status
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = le_lu.action_context_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = le_lu.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  cde_dtl.action_information6         = 'Y'
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
   GROUP BY asg_act.action_information2
           ,le_lu.action_information3;
  --
  CURSOR csr_LE_SI_CODE_TOTAL_SUMMARY
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT SUM(DECODE(asg_act.action_information7
                    ,'N', fnd_number.canonical_to_number(rep_cde.action_information3)
                    , 0)) a_earnings
    	 ,SUM(DECODE(asg_act.action_information7
                     ,'Y', fnd_number.canonical_to_number(rep_cde.action_information3)
                    , 0)) bl_earnings
	     ,SUM(fnd_number.canonical_to_number(rep_cde.action_information3)) sum_earnings
   FROM   pay_assignment_actions paa
         ,pay_action_information le_lu
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = le_lu.action_context_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_information2         = le_lu.action_information2
     AND  asg_act.action_information3         = le_lu.action_information4
     AND  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  le_lu.action_information2           = p_legal_employer_id
     AND  le_lu.action_information3           = p_si_status
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = le_lu.action_context_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = le_lu.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  cde_dtl.action_information6         = 'Y'
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
     AND  rep_cde.action_information2         NOT IN ('000','250','311','316','950')
   GROUP BY asg_act.action_information2
           ,le_lu.action_information3;
  --
  CURSOR csr_LE_SI_CODE_TOTALS
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_si_status         IN VARCHAR2) IS
   SELECT asg_act.action_information2 legal_employer_id
         ,le_lu.action_information3 si_status
         ,DECODE(cde_dtl.action_information4, 'Y', rep_cde.action_information2, 'TOTAL_OTHER_CODES') code
         ,SUM(fnd_number.canonical_to_number(rep_cde.action_information3)) amount
   FROM   pay_assignment_actions paa
         ,pay_action_information le_lu
         ,pay_action_information asg_act
         ,pay_action_information rep_cde
         ,pay_action_information cde_dtl
   WHERE  paa.payroll_action_id               = le_lu.action_context_id
     AND  asg_act.action_context_type         = 'AAP'
     AND  asg_act.action_context_id           = paa.assignment_action_id
     AND  asg_act.action_information_category = 'EMEA REPORT INFORMATION'
     AND  asg_act.action_information1         = 'ASG_ACT_INFO'
     AND  asg_act.action_information2         = le_lu.action_information2
     AND  asg_act.action_information3         = le_lu.action_information4
     AND  le_lu.action_context_type           = 'PA'
     AND  le_lu.action_context_id             = l_payroll_action_id
     AND  le_lu.action_information_category   = 'EMEA REPORT INFORMATION'
     AND  le_lu.action_information1           = 'LE_SI_LU_INFO'
     AND  le_lu.action_information2           = p_legal_employer_id
     AND  le_lu.action_information3           = p_si_status
     AND  cde_dtl.action_context_type         = 'PA'
     AND  cde_dtl.action_context_id           = le_lu.action_context_id
     AND  cde_dtl.action_information_category = 'EMEA REPORT INFORMATION'
     AND  cde_dtl.action_information1         = 'REP_CODE_DTLS'
     AND  cde_dtl.action_information2         = le_lu.action_information2
     AND  cde_dtl.action_information3         = rep_cde.action_information2
     AND  rep_cde.action_context_type         = 'AAP'
     AND  rep_cde.action_context_id           = asg_act.action_context_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'ASG_REP_CODE_INFO'
   GROUP BY asg_act.action_information2
           ,le_lu.action_information3
           ,DECODE(cde_dtl.action_information4, 'Y',rep_cde.action_information2, 'TOTAL_OTHER_CODES');
  --
  CURSOR csr_SI_STATUS IS
   SELECT lu.lookup_code si_status
   FROM   hr_lookups lu
   WHERE  lu.lookup_type = 'NO_LEGAL_EMP_SI_STATUS';
  --
  l_total_below_rep_limit   NUMBER;
  l_xml_element_count       NUMBER := 1;
  l_total_codes             NUMBER;
  l_bg_id                   NUMBER;
  lg_format_mask            VARCHAR2(40);
  l_payroll_action_id       NUMBER;
  l_si_sts_rec              csr_SI_STATUS%ROWTYPE;
  l_le_si_rec               csr_LE_SI%ROWTYPE;
  l_le_si_code_rec          csr_LE_SI_CODE_SUMMARY%ROWTYPE;
  l_le_si_code_total_rec    csr_LE_SI_CODE_TOTAL_SUMMARY%ROWTYPE;
  l_le_si_bal_rec           csr_LE_SI_BAL_SUMMARY%ROWTYPE;
  l_le_si_total_rec         csr_LE_SI_CODE_TOTALS%ROWTYPE;
  l_net_emp_contr_bse       NUMBER := 0;
  l_gross_emp_contr_bse     NUMBER := 0;
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
  -- get the currecnt BG's currency and mask to format the amount fields
  --
  fnd_profile.get('PER_BUSINESS_GROUP_ID', l_bg_id);
  set_currency_mask(l_bg_id, lg_format_mask);
  --
  -- Loop for each unique legal employer / SI status combination.
  --
  ---------------------------------------------------------------------------------------------------------
  -- Code for XML generation for Employee Summary w.r.t 2007-2008
  -----------------------------------------------------------------------------------------------------------
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skjema';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'tittel= "Lnns- og trekkoppgave" gruppeid="93" spesifikasjonsnummer="7008" skjemanummer="210" etatid="974761076" blankettnummer="RF-1015"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  OPEN csr_LE_SI
        (l_payroll_action_id);
  LOOP
   FETCH csr_LE_SI INTO l_le_si_rec;
   EXIT WHEN csr_LE_SI%NOTFOUND;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Innledning-grp-5749';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5749"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TypeOppgave-grp-5747';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5747"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgaveEndringsoppgave-datadef-21819';
  g_xml_element_table(l_xml_element_count).tagvalue := ' ';
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="21819"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TypeOppgave-grp-5747';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skatteoppkrever-grp-5748';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5748"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'SkatteoppkreverKommuneNummer-datadef-16513';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_tax_muncipality;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="16513"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skatteoppkrever-grp-5748';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --Legal Employer Details
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiver-grp-5750';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5750"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Organization Number
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'RapporteringsenhetOrganisasjonsnummer-datadef-21772';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.organization_number;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="21772"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverFodselsnummer-datadef-26';
  g_xml_element_table(l_xml_element_count).tagvalue := ' ';
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="26"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Legal Employer Name
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverNavnPreutfylt-datadef-25795';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.legal_employer_name;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25795"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Address
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverAdressePreutfylt-datadef-25796';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_addr1||' '||l_le_si_rec.le_addr2||' '||l_le_si_rec.le_addr3;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25796"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Post Code
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverPostnummerPreutfylt-datadef-25797';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_postcode;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25797"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Post Office
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverPoststedPreutfylt-datadef-25798';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.le_postoffice;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25798"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Industry Code
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverNACEKode-datadef-27602';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.nace_code;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27602"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverMobiltelefonnummer-datadef-28654';
  g_xml_element_table(l_xml_element_count).tagvalue := ' ';
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28654"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiver-grp-5750';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Innledning-grp-5749';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  -- Fetch all balances for the legal employer / SI status combination.
  --
  OPEN csr_LE_SI_BAL_SUMMARY
         (l_payroll_action_id
         ,l_le_si_rec.legal_employer_id
         ,l_le_si_rec.si_status);
  FETCH csr_LE_SI_BAL_SUMMARY INTO l_le_si_bal_rec;
  CLOSE csr_LE_SI_BAL_SUMMARY;
  --
  --
  -- Loop through the reporting code information.
  --
  OPEN csr_LE_SI_CODE_SUMMARY
         (l_payroll_action_id
         ,l_le_si_rec.legal_employer_id
         ,l_le_si_rec.si_status);
   FETCH csr_LE_SI_CODE_SUMMARY INTO l_le_si_code_rec;
   CLOSE csr_LE_SI_CODE_SUMMARY;
   --
   --
   OPEN csr_LE_SI_CODE_TOTAL_SUMMARY
         (l_payroll_action_id
         ,l_le_si_rec.legal_employer_id
         ,l_le_si_rec.si_status);
   FETCH csr_LE_SI_CODE_TOTAL_SUMMARY INTO l_le_si_code_total_rec;
   CLOSE csr_LE_SI_CODE_TOTAL_SUMMARY;
  g_xml_element_table(l_xml_element_count).tagname  := 'AndreOpplysninger-grp-5751';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5751"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Beregningsmate-grp-6844';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6844"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --Calculation Method for Employer's Contribution (AA, BB etc) from Legal Employer/Local Unit
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TerminoppgaveBeregningsmate-datadef-27603';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_rec.si_status;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27603"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Beregningsmate-grp-6844';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Annet-grp-6845';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6845"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Other subsidis received (to reduce excemption limit),
  -- same as in bi-monthly recording sheet, but total for the year
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TilskuddAndreTerminoppgave-datadef-27604';
 g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_le_si_rec.le_economic_aid),lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27604"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  -- Total Earnings Below Reporting Limit
  l_total_below_rep_limit := nvl(l_le_si_code_rec.bl_zone1,0)+ nvl(l_le_si_code_rec.bl_zone2,0)+ nvl(l_le_si_code_rec.bl_zone3,0)
--                               + nvl(l_le_si_code_rec.bl_zone4,0)+ nvl(l_le_si_code_rec.bl_zone2,0);
                               + nvl(l_le_si_code_rec.bl_zone4,0)+ nvl(l_le_si_code_rec.bl_zone5,0);
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'TilskuddAndreIkkeOppgavepliktige-datadef-28102';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_total_below_rep_limit ,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28102"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Annet-grp-6845';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'AndreOpplysninger-grp-5751';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'SpesielleGrupper-grp-5755';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5755"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'SpesielleGrupper-grp-6846';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6846"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Special Employers Contribution Basis for employees from USA/Canada
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftUtenlandskArbeidstakerUSACanadaGrunnlag-datadef-22225';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.emp_contr_spcl_pct_base,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="22225"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Reimbursable basis for Employees from US/Canada
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftUtenlandskRefusjonsgrunnlagSpesifisert-datadef-27612';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.emp_contr_reimb_spcl_base,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27612"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'SpesielleGrupper-grp-6846';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'VisseSjomenn-grp-5756';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5756"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Special Employers Contribution for Seaman with special monthly rate - number of months
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftUtenlandskArbeidstakerAntallManeder-datadef-25415';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_bal_rec.emp_contr_spcl / l_le_si_bal_rec.foreign_special_amount;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25415"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'VisseSjomenn-grp-5756';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'SpesielleGrupper-grp-5755';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Avgiftsgrunnlag-grp-6847';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6847"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  FOR l_le_si_lu_tm_rec IN  csr_LE_SI_LU_TM_INFO
                                (l_payroll_action_id)
  LOOP
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsgrunnlagTabell-grp-6848';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6848"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --Organization Number (Local Unit)
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsbetalerOrganisasjonsnummer-datadef-27605';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_lu_tm_rec.local_unit_id;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27605"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Local Unit Municipal Number
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsbetalerKommunenummer-datadef-27610';
  g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_lu_tm_rec.tax_municipality_id;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="27610"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Local Unit Municipal Name
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsbetalerKommunenavn-datadef-28111';
 g_xml_element_table(l_xml_element_count).tagvalue := l_le_si_lu_tm_rec.tax_municipality;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28111"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --  Employer Contribution Zone
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsbetalerArbeidsgiveravgiftSone-datadef-28112';
  g_xml_element_table(l_xml_element_count).tagvalue :=  l_le_si_lu_tm_rec.ni_zone_arc;
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28112"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Employer Contribution Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonGrunnlagSpesifisert-datadef-28106';
  g_xml_element_table(l_xml_element_count).tagvalue :=  to_char(l_le_si_lu_tm_rec.emp_contr_bse ,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28106"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Pension Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonTilskuddPensjonSpesifisert-datadef-28107';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_lu_tm_rec.pension_bse,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28107"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --Gross Employer Contribution Base
  --
  l_gross_emp_contr_bse := l_le_si_lu_tm_rec.emp_contr_bse + l_le_si_lu_tm_rec.pension_bse;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonBruttoSpesifisert-datadef-28108';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_gross_emp_contr_bse,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28108"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Reimbursement Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonRefusjonsgrunnlagSpesifisert-datadef-28109';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_lu_tm_rec.reimb_bse,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28109"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Net Employer Contribution Base
  l_net_emp_contr_bse := l_gross_emp_contr_bse - l_le_si_lu_tm_rec.reimb_bse ;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonNettoSpesifisert-datadef-28110';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_net_emp_contr_bse,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28110"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'AvgiftsgrunnlagTabell-grp-6848';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  END LOOP;
  --
  --
  -- Total Employer Contribution Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonGrunnlagSummert-datadef-28103';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.emp_contr_ni_total,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28103"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Total Pension Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonTilskuddPensjonSummert-datadef-28104';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.tot_pension_bse,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28104"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  -- Total Reimbursement Base
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsgiveravgiftRefusjonRefusjonsgrunnlagSummert-datadef-28105';
  g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_le_si_bal_rec.tot_reimb_bse,lg_format_mask);
  g_xml_element_table(l_xml_element_count).tagattrb := 'orid="28105"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Avgiftsgrunnlag-grp-6847';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  --
  --

  END LOOP ;

  CLOSE csr_LE_SI;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skjema';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  write_to_clob(p_xml);
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END get_employer_contribution_xml;
 --
 --
 -- -----------------------------------------------------------------------------
 -- Generates Report for the Norwegian End of Year Report called Certificate of Pay
 -- and Tax Deducted for each employee.
 -- -----------------------------------------------------------------------------
 --
 PROCEDURE get_employee_cerificate_data
 (p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.employee_certificate_data';
  --
  CURSOR csr_LEGEMP
          (l_payroll_action_id IN NUMBER) IS
   SELECT leg_emp.action_information2  legal_employer_id
         ,leg_emp.action_information3  legal_employer_name
         ,leg_emp.action_information4  organization_number
         ,leg_emp.action_information5  add_line_1
         ,leg_emp.action_information6  add_line_2
         ,leg_emp.action_information7  add_line_3
         ,leg_emp.action_information8  add_post_code
         ,leg_emp.action_information9  add_post_office
         ,leg_emp.action_information16 le_tax_municipality
	     ,leg_emp.effective_date       effective_date
   FROM   pay_action_information leg_emp
   WHERE  leg_emp.action_context_type         = 'PA'
     AND  leg_emp.action_context_id           = l_payroll_action_id
     AND  leg_emp.action_information_category = 'EMEA REPORT INFORMATION'
     AND  leg_emp.action_information1         = 'LEG_EMP_INFO'
   ORDER BY leg_emp.action_information3;
  --
  CURSOR csr_PERSON
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2) IS
   SELECT DISTINCT
          summ_cde.action_information12 tax_municipality
         ,per.action_information2  person_id
         ,per.action_information3  full_name
         ,per.action_information4  employee_number
         ,per.action_information5  national_identifier
         ,per.action_information6  employed_throughout
         ,per.action_information7  seamen
         ,per.action_information8  employed_date_or_days
         ,per.action_information9  add_line_1
         ,per.action_information10 add_line_2
         ,per.action_information11 add_line_3
         ,per.action_information12 add_post_code
         ,per.action_information13 add_post_office
   FROM   pay_action_information summ_cde
         ,pay_action_information per
   WHERE  summ_cde.action_context_type         = 'PA'
     AND  summ_cde.action_context_id           = l_payroll_action_id
     AND  summ_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  summ_cde.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  summ_cde.action_information2         = p_legal_employer_id
     AND  per.action_context_type              = summ_cde.action_context_type
     AND  per.action_context_id                = summ_cde.action_context_id
     AND  per.action_information_category      = summ_cde.action_information_category
     AND  per.action_information1              = 'PER_INFO'
     AND  per.action_information2              = summ_cde.action_information3
   ORDER BY per.action_information3;
  --
  CURSOR csr_PER_FIX_CODE
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,l_person_id         IN NUMBER) IS
   SELECT rep_cde.action_information3 code
         ,SUM(fnd_number.canonical_to_number(aud_smr.action_information5)) amount
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, p_legal_employer_id, rep_cde.action_information3, 'INFO1') info1_dtype
   FROM   pay_action_information rep_cde
         ,pay_action_information aud_smr
   WHERE  rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id           = l_payroll_action_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2         = p_legal_employer_id
     AND  rep_cde.action_information3         = aud_smr.action_information4
     AND  rep_cde.action_information4         = 'Y'
     AND  aud_smr.action_context_type         = 'PA'
     AND  aud_smr.action_context_id           = l_payroll_action_id
     AND  aud_smr.action_information_category = 'EMEA REPORT INFORMATION'
     AND  aud_smr.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  aud_smr.action_information2         = p_legal_employer_id
     AND  aud_smr.action_information3         = l_person_id
     group by rep_cde.action_information3 ;
  --
  CURSOR csr_PER_FIX_CODE_ADDL_INFO_CUM
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,l_person_id         IN NUMBER
          ,l_eoy_code          IN VARCHAR2) IS
   SELECT SUM(fnd_number.canonical_to_number(aud_smr.action_information6)) info1
   FROM   pay_action_information rep_cde
         ,pay_action_information aud_smr
   WHERE  rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id           = l_payroll_action_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2         = p_legal_employer_id
     AND  rep_cde.action_information3         = aud_smr.action_information4
     AND  rep_cde.action_information4         = 'Y'
     AND  aud_smr.action_context_type         = 'PA'
     AND  aud_smr.action_context_id           = l_payroll_action_id
     AND  aud_smr.action_information_category = 'EMEA REPORT INFORMATION'
     AND  aud_smr.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  aud_smr.action_information2         = p_legal_employer_id
     AND  aud_smr.action_information3         = l_person_id
     AND  aud_smr.action_information4         = l_eoy_code;
  --
  CURSOR csr_PER_FIX_CODE_ADDL_INFO_IND
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,l_person_id         IN NUMBER
          ,l_eoy_code          IN VARCHAR2) IS
   SELECT decode(count(distinct(aud_smr.action_information6)),1,max(aud_smr.action_information6),'') info1
   FROM   pay_action_information rep_cde
         ,pay_action_information aud_smr
   WHERE  rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id           = l_payroll_action_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2         = p_legal_employer_id
     AND  rep_cde.action_information3         = aud_smr.action_information4
     AND  rep_cde.action_information4         = 'Y'
     AND  aud_smr.action_context_type         = 'PA'
     AND  aud_smr.action_context_id           = l_payroll_action_id
     AND  aud_smr.action_information_category = 'EMEA REPORT INFORMATION'
     AND  aud_smr.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  aud_smr.action_information2         = p_legal_employer_id
     AND  aud_smr.action_information3         = l_person_id
     AND  aud_smr.action_information4         = l_eoy_code;
  --
  CURSOR csr_SUMMARY_CODES
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_person_id         IN VARCHAR2 ) IS
   SELECT summ_cde.action_information4  code
         ,fnd_number.canonical_to_number(summ_cde.action_information5)  amount
         ,summ_cde.action_information6  info1
         ,summ_cde.action_information7  info2
         ,summ_cde.action_information8  info3
         ,summ_cde.action_information9  info4
         ,summ_cde.action_information10 info5
         ,summ_cde.action_information11 info6
         ,summ_cde.action_information14 info7   --2009 changes
         ,summ_cde.action_information15 info8   --2009 changes
         ,summ_cde.action_information16 info9   --2009 changes
         ,summ_cde.action_information17 info10  --2009 changes
         ,pay_no_eoy_archive.get_code_desc(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4)            description
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_prompt     --2009 changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_dtype   --2009 Changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_dtype   --2009 Changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_dtype   --2009 Changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_dtype --2009 Changes
    	 ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_orid      --2009 Changes
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_orid      --2009 Changes
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_orid      --2009 Changes
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_orid      --2009 Changes
   FROM   pay_action_information      summ_cde
         ,pay_action_information      rep_cde
   WHERE   rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id            = l_payroll_action_id
     AND  rep_cde.action_information_category  = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1          = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2          = p_legal_employer_id
     AND  rep_cde.action_information3          = summ_cde.action_information4
     AND  rep_cde.action_information4          <> 'Y'
     AND  summ_cde.action_context_type         = 'PA'
     AND  summ_cde.action_context_id           = l_payroll_action_id
     AND  summ_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  summ_cde.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  summ_cde.action_information2         = p_legal_employer_id
     AND  summ_cde.action_information3         = p_person_id
   ORDER BY summ_cde.action_information2,
            summ_cde.action_information4;
  --
  CURSOR csr_FIX_CODE_DESC
          (l_payroll_action_id IN NUMBER) IS
    SELECT DISTINCT rep_cde.action_information3 code
          ,rep_cde.action_information11         description
      FROM pay_action_information rep_cde
     WHERE rep_cde.action_context_type         = 'PA'
      AND  rep_cde.action_context_id           = l_payroll_action_id
      AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
      AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
      AND  rep_cde.action_information4         = 'Y';
  --
  --
  l_xml_element_count NUMBER := 1;
  l_payroll_action_id NUMBER;
  l_bg_id             NUMBER;
  lg_format_mask      VARCHAR2(40);
  rec_per_fix_code    csr_PER_FIX_CODE%ROWTYPE;
  addl_info           VARCHAR2(30);
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
  -- get the currecnt BG's currency and mask to format the amount fields
  --
  fnd_profile.get('PER_BUSINESS_GROUP_ID', l_bg_id);
  set_currency_mask(l_bg_id, lg_format_mask);
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'EOY';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  FOR rec_FIX_CODE_DESC IN csr_FIX_CODE_DESC(l_payroll_action_id)
  LOOP
  --
    g_xml_element_table(l_xml_element_count).tagname  := 'PROMPT_'|| replace(rec_FIX_CODE_DESC.code,'-');
    g_xml_element_table(l_xml_element_count).tagvalue := rec_FIX_CODE_DESC.code;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'DESC_'|| replace(rec_FIX_CODE_DESC.code,'-');
    g_xml_element_table(l_xml_element_count).tagvalue := rec_FIX_CODE_DESC.description;
    l_xml_element_count := l_xml_element_count + 1;
  --
  END LOOP;
  --
  -- Loop for each legal employer.
  --
  FOR l_legemp_rec IN csr_LEGEMP
                       (l_payroll_action_id)
  LOOP
   --
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'REPORT_YEAR';
   g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_legemp_rec.effective_date,'YYYY');
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_NAME';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.legal_employer_name;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ADDRESS1';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_line_1;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ADDRESS2';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_line_2;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ADDRESS3';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_line_3;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_POSTCODE1';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_post_code;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_POSTCODE2';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_post_office;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ORG_NUMBER';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.organization_number;
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'TAX_MUNICIPALITY';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.le_tax_municipality;
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- Loop for each person within legal employer.
   --
   FOR l_person_rec IN csr_PERSON
                        (l_payroll_action_id
                        ,l_legemp_rec.legal_employer_id)
   LOOP
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'PERSON';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'NAME';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.full_name;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYEE_NUMBER';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employee_number;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'ADD_LINE_1';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_line_1;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'ADD_LINE_2';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_line_2;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'ADD_LINE_3';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_line_3;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'ADD_POST_CODE';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_post_code;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'ADD_POST_OFFICE';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_post_office;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'NI_NUMBER';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.national_identifier;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'TAX_MUNICIPALITY';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.tax_municipality;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYED_THROUGHOUT';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employed_throughout;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYED_DATE_OR_DAYS';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employed_date_or_days;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'SEAMEN';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.seamen;
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_fixed_code.DELETE;
    g_fixed_code(1).fixed_code := '111-A';
    g_fixed_code(1).status     := 0;
    g_fixed_code(2).fixed_code := '112-A';
    g_fixed_code(2).status     := 0;
    g_fixed_code(3).fixed_code := '116-A';
    g_fixed_code(3).status     := 0;
    g_fixed_code(4).fixed_code := '211';
    g_fixed_code(4).status     := 0;
    g_fixed_code(5).fixed_code := '311';
    g_fixed_code(5).status     := 0;
    g_fixed_code(6).fixed_code := '312';
    g_fixed_code(6).status     := 0;
    g_fixed_code(7).fixed_code := '313';
    g_fixed_code(7).status     := 0;
    g_fixed_code(8).fixed_code := '314';
    g_fixed_code(8).status     := 0;
    g_fixed_code(9).fixed_code := '316';
    g_fixed_code(9).status     := 0;
    g_fixed_code(10).fixed_code := '401';
    g_fixed_code(10).status     := 0;
    g_fixed_code(11).fixed_code := '711';
    g_fixed_code(11).status     := 0;
    g_fixed_code(12).fixed_code := '950';
    g_fixed_code(12).status     := 0;
    g_fixed_code(13).fixed_code :='000';
    g_fixed_code(13).status     := 0;
   --
   --
   -- Loop through all fixed codes.
   --
   OPEN csr_PER_FIX_CODE
         (l_payroll_action_id
         ,l_legemp_rec.legal_employer_id
         ,l_person_rec.person_id);
   LOOP
    FETCH csr_PER_FIX_CODE INTO rec_per_fix_code;
    EXIT WHEN csr_PER_FIX_CODE%NOTFOUND;
    --
    --
    -- XML TAG name is based on reporting code.
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AMOUNT_' || REPLACE(rec_per_fix_code.code,'-');
    g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_per_fix_code.amount,lg_format_mask);
    g_xml_element_table(l_xml_element_count).tagtype  := 'A';
    l_xml_element_count := l_xml_element_count + 1;
    --
    FOR rec_fixed_code in 1..13 LOOP
      --
      IF g_fixed_code(rec_fixed_code).fixed_code = rec_per_fix_code.code THEN
        g_fixed_code(rec_fixed_code).status := 1;
        --
        IF rec_per_fix_code.code IN ('211','711') THEN
          IF rec_per_fix_code.info1_dtype IN ('M','N','A') THEN
            OPEN  csr_PER_FIX_CODE_ADDL_INFO_CUM(l_payroll_action_id
                                          ,l_legemp_rec.legal_employer_id
                                          ,l_person_rec.person_id
                                          ,rec_per_fix_code.code);
            FETCH csr_PER_FIX_CODE_ADDL_INFO_CUM INTO addl_info;
            CLOSE csr_PER_FIX_CODE_ADDL_INFO_CUM;
            --
            addl_info := to_char(to_number(addl_info),lg_format_mask);
            --
          ELSE
            OPEN  csr_PER_FIX_CODE_ADDL_INFO_IND(l_payroll_action_id
                                          ,l_legemp_rec.legal_employer_id
                                          ,l_person_rec.person_id
                                          ,rec_per_fix_code.code);
            FETCH csr_PER_FIX_CODE_ADDL_INFO_IND INTO addl_info;
            CLOSE csr_PER_FIX_CODE_ADDL_INFO_IND;
            --
            IF rec_per_fix_code.info1_dtype IN ('D') AND addl_info <> 0 THEN
              addl_info := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(addl_info));
            END IF;
          --
          END IF;
          --
          g_xml_element_table(l_xml_element_count).tagname  := 'DETAIL_' || REPLACE(rec_per_fix_code.code,'-');
          g_xml_element_table(l_xml_element_count).tagvalue := addl_info;
          l_xml_element_count := l_xml_element_count + 1;
          --
        END IF;
        --
        EXIT;
      END IF;
      --
    END LOOP;
    --
   END LOOP;
   CLOSE csr_PER_FIX_CODE;
   --
   -- fixed codes which are not processed for this employee are shown as 0.
   FOR rec_fixed_code in 1..13 LOOP
      --
      IF g_fixed_code(rec_fixed_code).status = 0 THEN
        --
        g_fixed_code(rec_fixed_code).status := 1;
        g_xml_element_table(l_xml_element_count).tagname  := 'AMOUNT_' ||
                                                           REPLACE(g_fixed_code(rec_fixed_code).fixed_code,'-');
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(0,lg_format_mask);
        g_xml_element_table(l_xml_element_count).tagtype  := 'A';
        l_xml_element_count := l_xml_element_count + 1;
      --
      END IF;
      --
    END LOOP;
    --
    -- Loop for all reporting codes within person, legal employer.
    --
    FOR l_summ_code_rec IN csr_SUMMARY_CODES
                            (l_payroll_action_id
                            ,l_legemp_rec.legal_employer_id
                            ,l_person_rec.person_id)
    LOOP
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'REP_CODE';
     g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
     l_xml_element_count := l_xml_element_count + 1;
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'CODE';
     g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.code;
     l_xml_element_count := l_xml_element_count + 1;
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'AMOUNT';
     g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_summ_code_rec.amount,lg_format_mask);
     g_xml_element_table(l_xml_element_count).tagtype  := 'A';
     l_xml_element_count := l_xml_element_count + 1;
     --
     g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
     g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.description;
     l_xml_element_count := l_xml_element_count + 1;
     --
     IF l_summ_code_rec.info1_prompt IS NOT NULL AND l_summ_code_rec.info1 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info1_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info1_dtype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info1), lg_format_mask);
      ELSIF l_summ_code_rec.info1_dtype = 'D' AND l_summ_code_rec.info1 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info1));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info1;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info2_prompt IS NOT NULL AND l_summ_code_rec.info2 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info2_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info2_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info2),lg_format_mask);
      ELSIF l_summ_code_rec.info2_dtype = 'D' AND l_summ_code_rec.info2 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info2));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info2;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info3_prompt IS NOT NULL AND l_summ_code_rec.info3 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info3_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info3_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info3), lg_format_mask);
      ELSIF l_summ_code_rec.info3_dtype = 'D' AND l_summ_code_rec.info3 <> '0'  THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info3));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info3;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info4_prompt IS NOT NULL AND l_summ_code_rec.info4 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info4_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info4_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info4),lg_format_mask);
      ELSIF l_summ_code_rec.info4_dtype = 'D' AND l_summ_code_rec.info4 <> '0'  THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info4));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info4;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info5_prompt IS NOT NULL AND l_summ_code_rec.info5 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info5_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info5_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info5), lg_format_mask);
      ELSIF l_summ_code_rec.info5_dtype = 'D' AND l_summ_code_rec.info5 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info5));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info5;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     --
     IF l_summ_code_rec.info6_prompt IS NOT NULL AND l_summ_code_rec.info6 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info6_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info6_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info6),lg_format_mask);
      ELSIF l_summ_code_rec.info6_dtype = 'D' AND l_summ_code_rec.info6 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info6));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info6;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     -- 2009 changes starts
     IF l_summ_code_rec.info7_prompt IS NOT NULL AND l_summ_code_rec.info7 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info7_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info7_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info7),lg_format_mask);
      ELSIF l_summ_code_rec.info7_dtype = 'D' AND l_summ_code_rec.info7 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info7));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info7;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
--
     IF l_summ_code_rec.info8_prompt IS NOT NULL AND l_summ_code_rec.info8 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info8_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info8_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info8),lg_format_mask);
      ELSIF l_summ_code_rec.info8_dtype = 'D' AND l_summ_code_rec.info8 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info8));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info8;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
--
     IF l_summ_code_rec.info9_prompt IS NOT NULL AND l_summ_code_rec.info9 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info9_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info9_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info9),lg_format_mask);
      ELSIF l_summ_code_rec.info9_dtype = 'D' AND l_summ_code_rec.info9 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info9));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info9;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
--
     IF l_summ_code_rec.info10_prompt IS NOT NULL AND l_summ_code_rec.info10 IS NOT NULL THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'DESC';
      g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info10_prompt;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO_DTLS';
      IF l_summ_code_rec.info10_dtype IN ('M','A','N') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(l_summ_code_rec.info10),lg_format_mask);
      ELSIF l_summ_code_rec.info10_dtype = 'D' AND l_summ_code_rec.info10 <> '0' THEN
        g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(l_summ_code_rec.info10));
      ELSE
        g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.info10;
      END IF;
      l_xml_element_count := l_xml_element_count + 1;
      --
      g_xml_element_table(l_xml_element_count).tagname  := 'INFO';
      g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
      l_xml_element_count := l_xml_element_count + 1;
     END IF;
     -- 2009 changes ends
     g_xml_element_table(l_xml_element_count).tagname  := 'REP_CODE';
     g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
     l_xml_element_count := l_xml_element_count + 1;
    END LOOP;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'PERSON';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
   --
   END LOOP;
   --
   g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
   l_xml_element_count := l_xml_element_count + 1;
  END LOOP;
  --
   g_xml_element_table(l_xml_element_count).tagname  := 'EOY';
   g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
   l_xml_element_count := l_xml_element_count + 1;
  --
  write_to_clob(p_xml);
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END get_employee_cerificate_data;
--
-------------------------------------------------------------------------------------
-- Generates XML for the Norwegian End of Year Report called Certificate of Pay
-- and Tax Deducted for each employee. 2007/08 changes
-------------------------------------------------------------------------------------
--
--
--
 PROCEDURE get_employee_certificate_xml
 (p_business_group_id IN NUMBER
 ,p_payroll_action_id IN VARCHAR2
 ,p_template_name     IN VARCHAR2
 ,p_xml               OUT NOCOPY CLOB) IS
  --
  l_proc_name CONSTANT VARCHAR2(61) := l_package_name || '.get_employee_certificate_xml';
  --
  CURSOR csr_LEGEMP
          (l_payroll_action_id IN NUMBER) IS
   SELECT leg_emp.action_information2  legal_employer_id
         ,leg_emp.action_information3  legal_employer_name
         ,leg_emp.action_information4  organization_number
         ,leg_emp.action_information5  add_line_1
         ,leg_emp.action_information6  add_line_2
         ,leg_emp.action_information7  add_line_3
         ,leg_emp.action_information8  add_post_code
         ,leg_emp.action_information9  add_post_office
         ,leg_emp.action_information16 le_tax_municipality
	     ,leg_emp.effective_date       effective_date
   FROM   pay_action_information leg_emp
   WHERE  leg_emp.action_context_type         = 'PA'
     AND  leg_emp.action_context_id           = l_payroll_action_id
     AND  leg_emp.action_information_category = 'EMEA REPORT INFORMATION'
     AND  leg_emp.action_information1         = 'LEG_EMP_INFO'
   ORDER BY leg_emp.action_information3;
  --
  CURSOR csr_PERSON
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2) IS
   SELECT DISTINCT
          summ_cde.action_information12 tax_municipality
         ,per.action_information2  person_id
         ,per.action_information3  full_name
         ,per.action_information4  employee_number
         ,per.action_information5  national_identifier
         ,per.action_information6  employed_throughout
         ,per.action_information7  seamen
         ,per.action_information8  employed_date_or_days
         ,per.action_information9  add_line_1
         ,per.action_information10 add_line_2
         ,per.action_information11 add_line_3
         ,per.action_information12 add_post_code
         ,per.action_information13 add_post_office
	 ,per.action_information14 employment_start_date     --Changes 2007/2008
	 ,per.action_information15 employment_end_date       --Changes 2007/2008
   FROM   pay_action_information summ_cde
         ,pay_action_information per
   WHERE  summ_cde.action_context_type         = 'PA'
     AND  summ_cde.action_context_id           = l_payroll_action_id
     AND  summ_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  summ_cde.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  summ_cde.action_information2         = p_legal_employer_id
     AND  per.action_context_type              = summ_cde.action_context_type
     AND  per.action_context_id                = summ_cde.action_context_id
     AND  per.action_information_category      = summ_cde.action_information_category
     AND  per.action_information1              = 'PER_INFO'
     AND  per.action_information2              = summ_cde.action_information3
   ORDER BY per.action_information3;
  --
  CURSOR csr_PER_FIX_CODE
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,l_person_id         IN NUMBER) IS
   SELECT rep_cde.action_information3 code
         ,SUM(fnd_number.canonical_to_number(aud_smr.action_information5)) amount
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, p_legal_employer_id, rep_cde.action_information3, 'INFO1') info1_dtype
   FROM   pay_action_information rep_cde
         ,pay_action_information aud_smr
   WHERE  rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id           = l_payroll_action_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2         = p_legal_employer_id
     AND  rep_cde.action_information3         = aud_smr.action_information4
     AND  rep_cde.action_information4         = 'Y'
     AND  aud_smr.action_context_type         = 'PA'
     AND  aud_smr.action_context_id           = l_payroll_action_id
     AND  aud_smr.action_information_category = 'EMEA REPORT INFORMATION'
     AND  aud_smr.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  aud_smr.action_information2         = p_legal_employer_id
     AND  aud_smr.action_information3         = l_person_id
     group by rep_cde.action_information3 ;
  --
  CURSOR csr_PER_FIX_CODE_ADDL_INFO_CUM
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,l_person_id         IN NUMBER
          ,l_eoy_code          IN VARCHAR2) IS
   SELECT SUM(fnd_number.canonical_to_number(aud_smr.action_information6)) info1
   FROM   pay_action_information rep_cde
         ,pay_action_information aud_smr
   WHERE  rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id           = l_payroll_action_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2         = p_legal_employer_id
     AND  rep_cde.action_information3         = aud_smr.action_information4
     AND  rep_cde.action_information4         = 'Y'
     AND  aud_smr.action_context_type         = 'PA'
     AND  aud_smr.action_context_id           = l_payroll_action_id
     AND  aud_smr.action_information_category = 'EMEA REPORT INFORMATION'
     AND  aud_smr.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  aud_smr.action_information2         = p_legal_employer_id
     AND  aud_smr.action_information3         = l_person_id
     AND  aud_smr.action_information4         = l_eoy_code;
  --
  CURSOR csr_PER_FIX_CODE_ADDL_INFO_IND
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,l_person_id         IN NUMBER
          ,l_eoy_code          IN VARCHAR2) IS
   SELECT decode(count(distinct(aud_smr.action_information6)),1,max(aud_smr.action_information6),'') info1
   FROM   pay_action_information rep_cde
         ,pay_action_information aud_smr
   WHERE  rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id           = l_payroll_action_id
     AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2         = p_legal_employer_id
     AND  rep_cde.action_information3         = aud_smr.action_information4
     AND  rep_cde.action_information4         = 'Y'
     AND  aud_smr.action_context_type         = 'PA'
     AND  aud_smr.action_context_id           = l_payroll_action_id
     AND  aud_smr.action_information_category = 'EMEA REPORT INFORMATION'
     AND  aud_smr.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  aud_smr.action_information2         = p_legal_employer_id
     AND  aud_smr.action_information3         = l_person_id
     AND  aud_smr.action_information4         = l_eoy_code;
  --
  CURSOR csr_SUMMARY_CODES
          (l_payroll_action_id IN NUMBER
          ,p_legal_employer_id IN VARCHAR2
          ,p_person_id         IN VARCHAR2 ) IS
   SELECT summ_cde.action_information4  code
         ,fnd_number.canonical_to_number(summ_cde.action_information5)  amount
         ,summ_cde.action_information6  info1
         ,summ_cde.action_information7  info2
         ,summ_cde.action_information8  info3
         ,summ_cde.action_information9  info4
         ,summ_cde.action_information10 info5
         ,summ_cde.action_information11 info6
         ,summ_cde.action_information14 info7   --2009 changes
         ,summ_cde.action_information15 info8   --2009 changes
         ,summ_cde.action_information16 info9   --2009 changes
         ,summ_cde.action_information17 info10  --2009 changes
         ,pay_no_eoy_archive.get_code_desc(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4)            description
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_prompt
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_prompt         --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_prompt         --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_prompt         --2009 changes
         ,pay_no_eoy_archive.get_info_prompt(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_prompt         --2009 changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_dtype
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_dtype       -- 2009 changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_dtype       -- 2009 changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_dtype       -- 2009 changes
         ,pay_no_eoy_archive.get_info_dtype(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_dtype       -- 2009 changes
	 ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO1') info1_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO2') info2_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO3') info3_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO4') info4_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO5') info5_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO6') info6_orid    -- changes 2007-08
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO7') info7_orid    -- 2009 changes
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO8') info8_orid    -- 2009 changes
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO9') info9_orid    -- 2009 changes
         ,pay_no_eoy_archive.get_xml_orid(l_payroll_action_id, summ_cde.action_information2, summ_cde.action_information4, 'INFO10') info10_orid    -- 2009 changes
   FROM   pay_action_information      summ_cde
         ,pay_action_information      rep_cde
   WHERE   rep_cde.action_context_type         = 'PA'
     AND  rep_cde.action_context_id            = l_payroll_action_id
     AND  rep_cde.action_information_category  = 'EMEA REPORT INFORMATION'
     AND  rep_cde.action_information1          = 'REP_CODE_DTLS'
     AND  rep_cde.action_information2          = p_legal_employer_id
     AND  rep_cde.action_information3          = summ_cde.action_information4
     AND  rep_cde.action_information4          <> 'Y'
     AND  summ_cde.action_context_type         = 'PA'
     AND  summ_cde.action_context_id           = l_payroll_action_id
     AND  summ_cde.action_information_category = 'EMEA REPORT INFORMATION'
     AND  summ_cde.action_information1         = 'AUDIT_REP_SUMMARY'
     AND  summ_cde.action_information2         = p_legal_employer_id
     AND  summ_cde.action_information3         = p_person_id
   ORDER BY summ_cde.action_information2,
            summ_cde.action_information4;
  --
  CURSOR csr_FIX_CODE_DESC
          (l_payroll_action_id IN NUMBER) IS
    SELECT DISTINCT rep_cde.action_information3 code
          ,rep_cde.action_information11         description
      FROM pay_action_information rep_cde
     WHERE rep_cde.action_context_type         = 'PA'
      AND  rep_cde.action_context_id           = l_payroll_action_id
      AND  rep_cde.action_information_category = 'EMEA REPORT INFORMATION'
      AND  rep_cde.action_information1         = 'REP_CODE_DTLS'
      AND  rep_cde.action_information4         = 'Y';
  --
  --
  l_xml_element_count NUMBER := 1;
  l_payroll_action_id NUMBER;
  l_bg_id             NUMBER;
  lg_format_mask      VARCHAR2(40);
  rec_per_fix_code    csr_PER_FIX_CODE%ROWTYPE;
  addl_info           VARCHAR2(30);
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
  -- get the currecnt BG's currency and mask to format the amount fields
  --
  fnd_profile.get('PER_BUSINESS_GROUP_ID', l_bg_id);
  set_currency_mask(l_bg_id, lg_format_mask);
  --
  --/*Applying the changes for the 2007-2008*/

  g_xml_element_table(l_xml_element_count).tagname  := 'Skjema';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'tittel= "Lnns- og trekkoppgave" gruppeid="5541" spesifikasjonsnummer="7010" skjemanummer="1083" etatid="974761076" blankettnummer="RF-1015-U"';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Innledning-grp-5549';
  g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
  g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5549"';
  l_xml_element_count := l_xml_element_count + 1;
  --

  FOR l_legemp_rec IN csr_LEGEMP
                       (l_payroll_action_id)
  LOOP

   -- g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiver-grp-5770';
   g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
   g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5770"';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ORG_NUMBER';
   g_xml_element_table(l_xml_element_count).tagname  :='RapporteringsenhetOrganisasjonsnummer-datadef-21772';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.organization_number;
   g_xml_element_table(l_xml_element_count).tagattrb := 'orid="21772"';
   l_xml_element_count := l_xml_element_count + 1;
   --
   g_xml_element_table(l_xml_element_count).tagname  :='OppgavegiverFodselsnummer-datadef-26';
   g_xml_element_table(l_xml_element_count).tagvalue := ' ';
   g_xml_element_table(l_xml_element_count).tagattrb := 'orid="26"';
   l_xml_element_count := l_xml_element_count + 1;
    --
   -- g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_NAME';
   g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverNavnPreutfylt-datadef-25795';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.legal_employer_name;
   g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25795"';
   l_xml_element_count := l_xml_element_count + 1;

   --
   -- g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_ADDRESS1';
   g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverAdressePreutfylt-datadef-25796';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_line_1||' '||l_legemp_rec.add_line_2||' '||l_legemp_rec.add_line_3;
   g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25796"';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_POSTCODE1';
   g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverPostnummerPreutfylt-datadef-25797';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_post_code;
   g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25797"';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER_POSTCODE2';
   g_xml_element_table(l_xml_element_count).tagname  := 'OppgavegiverPoststedPreutfylt-datadef-25798';
   g_xml_element_table(l_xml_element_count).tagvalue := l_legemp_rec.add_post_office;
   g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25798"';
   l_xml_element_count := l_xml_element_count + 1;
   --
   --g_xml_element_table(l_xml_element_count).tagname  := 'LEGAL_EMPLOYER';
   g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidsgiver-grp-5770';
   g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
   l_xml_element_count := l_xml_element_count + 1;
   --
   -- Loop for each person within legal employer.
   FOR l_person_rec IN csr_PERSON
                        (l_payroll_action_id
                        ,l_legemp_rec.legal_employer_id)
   LOOP
   -- 4334

    --g_xml_element_table(l_xml_element_count).tagname  := 'PERSON';
    g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidstaker-grp-5771';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5771"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    -- g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYEE_NUMBER';
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattFodselsnummer-datadef-1224';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employee_number;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="1224"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'NaringsdrivendeLonnsmottakerOrganisasjonsnummer-datadef-24396';
    g_xml_element_table(l_xml_element_count).tagvalue := ' ';
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="24396"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattFodselsdato-datadef-22734';
    g_xml_element_table(l_xml_element_count).tagvalue := ' ';
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="22734"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --  g_xml_element_table(l_xml_element_count).tagname  := 'NAME';
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattNavn-datadef-25426';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.full_name;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25426"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    -- g_xml_element_table(l_xml_element_count).tagname  := 'ADD_LINE_1';
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattAdresse-datadef-23161';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_line_1||' '||l_person_rec.add_line_2||' '||l_person_rec.add_line_3;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="23161"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'ADD_POST_CODE';
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattPostnummer-datadef-8466';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_post_code;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="8466"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'ADD_POST_OFFICE';
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattPostnummer-datadef-8467';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.add_post_office;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="8467"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'TAX_MUNICIPALITY';
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattSkattekortkommunenummer-datadef-23289';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.tax_municipality;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="23289"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    -- Start of Employee Work Details
    g_xml_element_table(l_xml_element_count).tagname  := 'Ansettelsesforhold-grp-6849';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="6849"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Sjofolk-grp-5773';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5773"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'SEAMEN';
    g_xml_element_table(l_xml_element_count).tagname  := 'OppgaveSjofolk-datadef-24335';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.seamen;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="24335"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Sjofolk-grp-5773';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Ansettelsesperiode-grp-5772';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5772"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYED_THROUGHOUT';
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattAnsettelseHeleAret-datadef-24333';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employed_throughout;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="24333"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYED_START_DATE';
    g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsforholdStartdato-datadef-23170';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employment_start_date;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="23170"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYED_END_DATE';
    g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsforholdSluttdato-datadef-23171';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employment_end_date;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="23171"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    -- g_xml_element_table(l_xml_element_count).tagname  := 'EMPLOYED_DATE_OR_DAYS';
    g_xml_element_table(l_xml_element_count).tagname  := 'ArbeidsforholdAntallDager-datadef-24364';
    g_xml_element_table(l_xml_element_count).tagvalue := l_person_rec.employed_date_or_days;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="24364"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Ansettelsesperiode-grp-5772';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Ansettelsesforhold-grp-6849';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    -- End of Employee Work Details
    --
    --
    --Extraction of Values of the Fixed Codes
    g_fixed_code.DELETE;
    g_fixed_code(1).fixed_code  := '111-A';
    g_fixed_code(1).status      := 0;
    g_fixed_code(1).displayed   := 0;
    g_fixed_code(2).fixed_code  := '112-A';
    g_fixed_code(2).status      := 0;
    g_fixed_code(2).displayed   := 0;
    g_fixed_code(3).fixed_code  := '116-A';
    g_fixed_code(3).status      := 0;
    g_fixed_code(3).displayed   := 0;
    g_fixed_code(4).fixed_code  := '211';
    g_fixed_code(4).status      := 0;
    g_fixed_code(4).displayed   := 0;
    g_fixed_code(5).fixed_code  := '311';
    g_fixed_code(5).status      := 0;
    g_fixed_code(5).displayed   := 0;
    g_fixed_code(6).fixed_code  := '312';
    g_fixed_code(6).status      := 0;
    g_fixed_code(6).displayed   := 0;
    g_fixed_code(7).fixed_code  := '313';
    g_fixed_code(7).status      := 0;
    g_fixed_code(7).displayed   := 0;
    g_fixed_code(8).fixed_code  := '314';
    g_fixed_code(8).status      := 0;
    g_fixed_code(8).displayed   := 0;
    g_fixed_code(9).fixed_code  := '316';
    g_fixed_code(9).status      := 0;
    g_fixed_code(9).displayed   := 0;
    g_fixed_code(10).fixed_code := '401';
    g_fixed_code(10).status     := 0;
    g_fixed_code(10).displayed  := 0;
    g_fixed_code(11).fixed_code := '711';
    g_fixed_code(11).status     := 0;
    g_fixed_code(11).displayed  := 0;
    g_fixed_code(12).fixed_code := '950';
    g_fixed_code(12).status     := 0;
    g_fixed_code(12).displayed  := 0;
    g_fixed_code(13).fixed_code :='000';
    g_fixed_code(13).status     := 0;
    g_fixed_code(13).displayed  := 0;
   --
   --
   -- Loop through all fixed codes.
   --
   OPEN csr_PER_FIX_CODE
         (l_payroll_action_id
         ,l_legemp_rec.legal_employer_id
         ,l_person_rec.person_id);
   LOOP
    FETCH csr_PER_FIX_CODE INTO rec_per_fix_code;
    EXIT WHEN csr_PER_FIX_CODE%NOTFOUND;
    --
    --
    -- XML TAG name is based on reporting code.
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'AMOUNT_' || REPLACE(rec_per_fix_code.code,'-');
    --g_xml_element_table(l_xml_element_count).tagvalue := to_char(rec_per_fix_code.amount,lg_format_mask);
    --g_xml_element_table(l_xml_element_count).tagtype  := 'A';
    --l_xml_element_count := l_xml_element_count + 1;
    --
    FOR rec_fixed_code in 1..13 LOOP
      --
      IF g_fixed_code(rec_fixed_code).fixed_code = rec_per_fix_code.code THEN
        g_fixed_code(rec_fixed_code).status := 1;
	g_fixed_code(rec_fixed_code).Amount_value := to_char(rec_per_fix_code.amount,lg_format_mask); --4528
        --
        IF rec_per_fix_code.code IN ('211','711') THEN
          IF rec_per_fix_code.info1_dtype IN ('M','N','A') THEN
            OPEN  csr_PER_FIX_CODE_ADDL_INFO_CUM(l_payroll_action_id
                                          ,l_legemp_rec.legal_employer_id
                                          ,l_person_rec.person_id
                                          ,rec_per_fix_code.code);
            FETCH csr_PER_FIX_CODE_ADDL_INFO_CUM INTO addl_info;
            CLOSE csr_PER_FIX_CODE_ADDL_INFO_CUM;
            --
            g_fixed_code(rec_fixed_code).Addl_Value := to_char(to_number(addl_info),lg_format_mask);
            --
          ELSE
            OPEN  csr_PER_FIX_CODE_ADDL_INFO_IND(l_payroll_action_id
                                          ,l_legemp_rec.legal_employer_id
                                          ,l_person_rec.person_id
                                          ,rec_per_fix_code.code);
            FETCH csr_PER_FIX_CODE_ADDL_INFO_IND INTO addl_info;
            CLOSE csr_PER_FIX_CODE_ADDL_INFO_IND;
            --
            IF rec_per_fix_code.info1_dtype IN ('D') AND addl_info <> '0' THEN
	       g_fixed_code(rec_fixed_code).Addl_Value := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(addl_info));
            END IF;
          --
          END IF;
          --
          --g_xml_element_table(l_xml_element_count).tagname  := 'DETAIL_' || REPLACE(rec_per_fix_code.code,'-');
          --g_xml_element_table(l_xml_element_count).tagvalue := addl_info;
          --l_xml_element_count := l_xml_element_count + 1;
          --
        END IF;
        --
        EXIT;
	--
      END IF;
      --
    END LOOP;
    --
   END LOOP;
   CLOSE csr_PER_FIX_CODE;
   --
   -- fixed codes which are not processed for this employee are shown as 0.
   --
   FOR rec_fixed_code in 1..13 LOOP
      --
      IF g_fixed_code(rec_fixed_code).status = 0 THEN
        --
        g_fixed_code(rec_fixed_code).status := 1;
        g_fixed_code(rec_fixed_code).Amount_value := to_char(0,lg_format_mask);
	g_fixed_code(rec_fixed_code).Addl_Value := to_char(0,lg_format_mask);

	--
      END IF;
      --
    END LOOP;
    --
    --
    --
    --
    -- Start of Tax Code Fixed Code details
    g_xml_element_table(l_xml_element_count).tagname  := 'MestBrukteKoder-grp-5774 ';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5774"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnOgForskuddstrekk-grp-5775';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5775"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    -- Code Details for 111-A -Amount Value
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattLonn-datadef-25427';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(1).Amount_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25427"';
    l_xml_element_count := l_xml_element_count + 1;
    g_fixed_code(1).displayed := 1;
    --
    --Code Details for 950 - Amount Value
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattForskuddstrekk-datadef-25428';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(12).Amount_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25428"';
    l_xml_element_count := l_xml_element_count + 1;
    g_fixed_code(12).displayed := 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnOgForskuddstrekk-grp-5775';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'TrekkfriBilgodtgjorelse-grp-5776';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5776"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    -- Details of Code 711 - Amount Value
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattBilgodtgjorelseTrekkfri-datadef-25429';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(11).Amount_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25429"';
    l_xml_element_count := l_xml_element_count + 1;
    g_fixed_code(11).displayed := 1;
    --
    -- Details of Code 711 - Number of Kilometers
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattBilgodtgjorelseTrekkfriAntallKilometer-datadef-25430';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(11).Addl_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25430"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'TrekkfriBilgodtgjorelse-grp-5776';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Naringsdrivende-grp-5777';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5777"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    -- Details of Code 401 - Amount value
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'NaringsdrivendeUtbetaling-datadef-25434';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(10).Amount_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25434"';
    l_xml_element_count := l_xml_element_count + 1;
    g_fixed_code(10).displayed := 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'Naringsdrivende-grp-5777';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'KoderSomIkkeForesISelvangivelsen-grp-5778';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5778"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --Details of Code 000 - Amount Value
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattFeriepenger-datadef-25431';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(13).Amount_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25431"';
    l_xml_element_count := l_xml_element_count + 1;
    g_fixed_code(13).displayed := 1;
    --
    -- Details of Code 313 - Amount Value
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattUnderholdsbidrag-datadef-25432';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(7).Amount_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25432"';
    l_xml_element_count := l_xml_element_count + 1;
    g_fixed_code(7).displayed := 1;
    --
    -- Details of Code 316 - Amount value
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'AnsattUnderholdsbidragIkkeFradragsberegnet-datadef-25433';
    g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(9).Amount_Value;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25433"';
    l_xml_element_count := l_xml_element_count + 1;
    g_fixed_code(9).displayed := 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'KoderSomIkkeForesISelvangivelsen-grp-5778';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'MestBrukteKoder-grp-5774 ';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'OvrigeKoder-grp-5779';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5779"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --112-A(2),116-A(3),211(4),311(5),312(6),314(8)
    -- Fixed Codes
    FOR rec_fixed_code in 1..13 LOOP
    --
     IF g_fixed_code(rec_fixed_code).displayed = 0 THEN
         --
         g_xml_element_table(l_xml_element_count).tagname  := 'OvrigeLTOKoder-grp-5806';
         g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
         g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5806"';
         l_xml_element_count := l_xml_element_count + 1;
         --
	 IF g_fixed_code(rec_fixed_code).fixed_code = '211' THEN
	 --
         g_xml_element_table(l_xml_element_count).tagname  := 'LonnoppgavekodeKodenummer-datadef-25435';
         g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(rec_fixed_code).fixed_code;
         g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25435"';
         l_xml_element_count := l_xml_element_count + 1;
         --
         g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettBelop1-datadef-25437';
         g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(rec_fixed_code).Amount_Value;
         g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25437"';
         l_xml_element_count := l_xml_element_count + 1;
	 --
	 g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettFraDato-datadef-25444';
	 g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(rec_fixed_code).Addl_Value;
	 g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25444"';
         l_xml_element_count := l_xml_element_count + 1;
	 --
	 ELSE
	 --
	 g_xml_element_table(l_xml_element_count).tagname  := 'LonnoppgavekodeKodenummer-datadef-25435';
         g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(rec_fixed_code).fixed_code;
         g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25435"';
         l_xml_element_count := l_xml_element_count + 1;
         --
         g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettBelop1-datadef-25437';
         g_xml_element_table(l_xml_element_count).tagvalue := g_fixed_code(rec_fixed_code).Amount_Value;
         g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25437"';
         l_xml_element_count := l_xml_element_count + 1;
	 --
	 END IF;
         --
         g_xml_element_table(l_xml_element_count).tagname  := 'OvrigeLTOKoder-grp-5806';
         g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
	 l_xml_element_count := l_xml_element_count + 1;

	 g_fixed_code(rec_fixed_code).displayed := 1; --4775
      --
      END IF;
    --
      END LOOP;

    --Start of Summary Codes
    FOR l_summ_code_rec IN csr_SUMMARY_CODES
                            (l_payroll_action_id
                            ,l_legemp_rec.legal_employer_id
                            ,l_person_rec.person_id)
    LOOP

    g_summary_code_orid.DELETE;
    g_summary_code_orid(1).orid_value    := l_summ_code_rec.info1_orid;
    g_summary_code_orid(1).info_data     := l_summ_code_rec.info1;
    g_summary_code_orid(1).info_prompt   := l_summ_code_rec.info1_prompt;
    g_summary_code_orid(1).info_datatype := l_summ_code_rec.info1_dtype;
    --
    g_summary_code_orid(2).orid_value    := l_summ_code_rec.info2_orid;
    g_summary_code_orid(2).info_data     := l_summ_code_rec.info2;
    g_summary_code_orid(2).info_prompt   := l_summ_code_rec.info2_prompt;
    g_summary_code_orid(2).info_datatype := l_summ_code_rec.info2_dtype;
    --
    g_summary_code_orid(3).orid_value    := l_summ_code_rec.info3_orid;
    g_summary_code_orid(3).info_data     := l_summ_code_rec.info3;
    g_summary_code_orid(3).info_prompt   := l_summ_code_rec.info3_prompt;
    g_summary_code_orid(3).info_datatype := l_summ_code_rec.info3_dtype;
    --
    g_summary_code_orid(4).orid_value    := l_summ_code_rec.info4_orid;
    g_summary_code_orid(4).info_data     := l_summ_code_rec.info4;
    g_summary_code_orid(4).info_prompt   := l_summ_code_rec.info4_prompt;
    g_summary_code_orid(4).info_datatype := l_summ_code_rec.info4_dtype;
    --
    g_summary_code_orid(5).orid_value    := l_summ_code_rec.info5_orid;
    g_summary_code_orid(5).info_data     := l_summ_code_rec.info5;
    g_summary_code_orid(5).info_prompt   := l_summ_code_rec.info5_prompt;
    g_summary_code_orid(5).info_datatype := l_summ_code_rec.info5_dtype;
    --
    g_summary_code_orid(6).orid_value    := l_summ_code_rec.info6_orid;
    g_summary_code_orid(6).info_data     := l_summ_code_rec.info6;
    g_summary_code_orid(6).info_prompt   := l_summ_code_rec.info6_prompt;
    g_summary_code_orid(6).info_datatype := l_summ_code_rec.info6_dtype;
    -- 2009 changes starts
    g_summary_code_orid(7).orid_value    := l_summ_code_rec.info7_orid;
    g_summary_code_orid(7).info_data     := l_summ_code_rec.info7;
    g_summary_code_orid(7).info_prompt   := l_summ_code_rec.info7_prompt;
    g_summary_code_orid(7).info_datatype := l_summ_code_rec.info7_dtype;
    --
    g_summary_code_orid(8).orid_value    := l_summ_code_rec.info8_orid;
    g_summary_code_orid(8).info_data     := l_summ_code_rec.info8;
    g_summary_code_orid(8).info_prompt   := l_summ_code_rec.info8_prompt;
    g_summary_code_orid(8).info_datatype := l_summ_code_rec.info8_dtype;
    --
    g_summary_code_orid(9).orid_value    := l_summ_code_rec.info9_orid;
    g_summary_code_orid(9).info_data     := l_summ_code_rec.info9;
    g_summary_code_orid(9).info_prompt   := l_summ_code_rec.info9_prompt;
    g_summary_code_orid(9).info_datatype := l_summ_code_rec.info9_dtype;
    --
    g_summary_code_orid(10).orid_value    := l_summ_code_rec.info10_orid;
    g_summary_code_orid(10).info_data     := l_summ_code_rec.info10;
    g_summary_code_orid(10).info_prompt   := l_summ_code_rec.info10_prompt;
    g_summary_code_orid(10).info_datatype := l_summ_code_rec.info10_dtype;
    --2009 changes ends
    g_xml_element_table(l_xml_element_count).tagname  := 'OvrigeLTOKoder-grp-5806';
    g_xml_element_table(l_xml_element_count).tagvalue := '_START_';
    g_xml_element_table(l_xml_element_count).tagattrb := 'gruppeid="5806"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnoppgavekodeKodenummer-datadef-25435';
    g_xml_element_table(l_xml_element_count).tagvalue := l_summ_code_rec.code;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25435"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsytelserAvgiftsplikt-datadef-25436';
    g_xml_element_table(l_xml_element_count).tagvalue := ' ';
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25436"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettBelop1-datadef-25437';
    g_xml_element_table(l_xml_element_count).tagvalue := to_char(l_summ_code_rec.amount,lg_format_mask);
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25437"';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25438' THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettBelop2-datadef-25438';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
          g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
       ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D'  AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
          g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
       ELSE
          g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
       END IF;
      g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25438"';
      l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --
    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25439' THEN
       g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettAntall-datadef-25439';
       IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
          g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
       ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0'  THEN
          g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
       ELSE
          g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
       END IF;
       g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25439"';
       l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25440' THEN
        g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettLandkode1-datadef-25440';
        IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
           g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
         ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
           g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
         ELSE
           g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
         END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25440"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25441' THEN
      g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettLandkode2-datadef-25441';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
       END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25441"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25442' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettAr-datadef-25442';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
       END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25442"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25443' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettBelop3-datadef-25443 ';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25443"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25444' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettFraDato-datadef-25444';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25444"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25445' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettTilDato-datadef-25445';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25445"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN  1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25446' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettBelop4-datadef-25446';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25446"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25447' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettBelop5-datadef-25447';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25447"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25448' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettAnnenOpplysning1-datadef-25448';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25448"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN  1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25449' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettAnnenOpplysning2-datadef-25449';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25449"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --

    FOR l_summ_var IN 1..6 LOOP
    IF g_summary_code_orid(l_summ_var).orid_value = '25450' THEN
    g_xml_element_table(l_xml_element_count).tagname  := 'LonnsoppgaveTabelloppsettAnnenOpplysning3-datadef-25450';
      IF g_summary_code_orid(l_summ_var).info_datatype IN ('M','A','N','MC') THEN
        g_xml_element_table(l_xml_element_count).tagvalue := to_char(fnd_number.canonical_to_number(g_summary_code_orid(l_summ_var).info_data), lg_format_mask);
      ELSIF g_summary_code_orid(l_summ_var).info_datatype = 'D' AND g_summary_code_orid(l_summ_var).info_data <> '0' THEN
         g_xml_element_table(l_xml_element_count).tagvalue := fnd_date.date_to_displaydate(fnd_date.canonical_to_date(g_summary_code_orid(l_summ_var).info_data));
      ELSE
         g_xml_element_table(l_xml_element_count).tagvalue := g_summary_code_orid(l_summ_var).info_data;
      END IF;
    g_xml_element_table(l_xml_element_count).tagattrb := 'orid="25450"';
    l_xml_element_count := l_xml_element_count + 1;
    EXIT;
    END IF;
    END LOOP;
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'OvrigeLTOKoder-grp-5806';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    END LOOP;
    --
    --
    g_xml_element_table(l_xml_element_count).tagname  := 'OvrigeKoder-grp-5779';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --
    --
    --
    --g_xml_element_table(l_xml_element_count).tagname  := 'PERSON';
    g_xml_element_table(l_xml_element_count).tagname  := 'Arbeidstaker-grp-5771';
    g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
    l_xml_element_count := l_xml_element_count + 1;
    --

    END LOOP;
    --
   END LOOP;

  g_xml_element_table(l_xml_element_count).tagname  := 'Innledning-grp-5549';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;
  --
  g_xml_element_table(l_xml_element_count).tagname  := 'Skjema';
  g_xml_element_table(l_xml_element_count).tagvalue := '_END_';
  l_xml_element_count := l_xml_element_count + 1;

  --
  write_to_clob(p_xml);
  --
  hr_utility.set_location('Leaving ' || l_proc_name, 1000);
 END get_employee_certificate_xml;
--
--
--
END pay_no_eoy_archive;

/
