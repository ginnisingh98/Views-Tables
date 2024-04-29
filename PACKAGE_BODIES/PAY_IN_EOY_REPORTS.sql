--------------------------------------------------------
--  DDL for Package Body PAY_IN_EOY_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_IN_EOY_REPORTS" AS
/* $Header: pyineoyr.pkb 120.21.12010000.8 2010/01/21 09:36:29 mdubasi ship $ */
  g_tmp_clob          CLOB;
  g_clob_cnt          NUMBER;
  g_fetch_clob_cnt    NUMBER;
  g_chunk_size        NUMBER;
  g_business_group_id NUMBER;
--  g_package           VARCHAR2(100);
  g_assessment_year   VARCHAR2(20);
  g_tax_year          VARCHAR2(20);
  g_tax_end_date      DATE;
  g_tax_start_date    DATE;

  g_index      NUMBER;
  g_debug       BOOLEAN ;
  g_package     CONSTANT VARCHAR2(100) := 'pay_in_eoy_reports.';

  TYPE record_type   IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
  t_table_1 record_type;
  t_table_surcharge record_type;
  t_table_ec record_type;

  TYPE XMLRec
  IS RECORD
  (
    Bank VARCHAR2(2000),
    VDate DATE,
    VNumber VARCHAR2(240),
    DDCheque_Num  VARCHAR2(240)
  );
  TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
  g_Bank_Details_tbl tXMLTable;

  TYPE Emp_XMLRec
  IS RECORD
  (
    emp_tds VARCHAR2(2000),
    emp_sur VARCHAR2(240),
    emp_cess VARCHAR2(240),
    emp_voucher  VARCHAR2(240),
    emp_amount VARCHAR2(240)
  );
  TYPE Emp_tXMLTable IS TABLE OF Emp_XMLRec INDEX BY BINARY_INTEGER;
  g_emp_challan_details_tbl Emp_tXMLTable;

  g_salary_record pay_in_xml_utils.tXMLTable;
  g_Other_Income_tbl pay_in_xml_utils.tXMLTable;
  p_rem_pay_period    NUMBER;
  p_flag             NUMBER;

  TYPE clob_tab_type IS TABLE OF CLOB INDEX BY BINARY_INTEGER;

  TYPE perq_record IS RECORD
      ( perq_value1     pay_action_information.action_information1%TYPE
      , perq_value2     pay_action_information.action_information1%TYPE
      );

  TYPE t_perq_record is table of perq_record INDEX BY BINARY_INTEGER;

  g_perq_record   t_perq_record;
  g_clob          clob_tab_type;

  g_80cce_limit NUMBER;



--------------------------------------------------------------------------
--                                                                      --
-- Name           : init_form12ba_code                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : This procedure initializes the form12ba record      --
--                                                                      --
-- Parameters     : None                                                --
--------------------------------------------------------------------------
PROCEDURE init_form12ba_code
IS
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package||'init_form12ba_code';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  g_perq_record(1).perq_value1 := 0;
  g_perq_record(1).perq_value2 := 0;

  g_perq_record(2).perq_value1 := 0;
  g_perq_record(2).perq_value2 := 0;

  g_perq_record(3).perq_value1 := 0;
  g_perq_record(3).perq_value2 := 0;

  g_perq_record(4).perq_value1 := 0;
  g_perq_record(4).perq_value2 := 0;

  g_perq_record(5).perq_value1 := 0;
  g_perq_record(5).perq_value2 := 0;

  g_perq_record(6).perq_value1 := 0;
  g_perq_record(6).perq_value2 := 0;

  g_perq_record(7).perq_value1 := 0;
  g_perq_record(7).perq_value2 := 0;

  g_perq_record(8).perq_value1 := 0;
  g_perq_record(8).perq_value2 := 0;

  g_perq_record(9).perq_value1 := 0;
  g_perq_record(9).perq_value2 := 0;

  g_perq_record(10).perq_value1 := 0;
  g_perq_record(10).perq_value2 := 0;

  g_perq_record(11).perq_value1 := 0;
  g_perq_record(11).perq_value2 := 0;

  g_perq_record(12).perq_value1 := 0;
  g_perq_record(12).perq_value2 := 0;

  g_perq_record(13).perq_value1 := 0;
  g_perq_record(13).perq_value2 := 0;

  g_perq_record(14).perq_value1 := 0;
  g_perq_record(14).perq_value2 := 0;

  g_perq_record(15).perq_value1 := 0;
  g_perq_record(15).perq_value2 := 0;

  g_perq_record(16).perq_value1 := 0;
  g_perq_record(16).perq_value2 := 0;

  g_perq_record(17).perq_value1 := 0;
  g_perq_record(17).perq_value2 := 0;

  g_perq_record(18).perq_value1 := 0;
  g_perq_record(18).perq_value2 := 0;

  g_perq_record(19).perq_value1 := 0;
  g_perq_record(19).perq_value2 := 0;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

END init_form12ba_code;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_MAX_CONTEXT_ID                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Private                                             --
-- Description    : This procedure gets the maximum action context id   --
--                  for a specified GRE in an assessment year           --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_gre_id              NUMBER                        --
--                : p_assessment_year     VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_max_context_id ( p_gre_id             IN hr_organization_units.organization_id%TYPE
                            , p_assessment_year    IN pay_action_information.action_information3%TYPE
                            )
RETURN NUMBER
IS
  --
  CURSOR csr_max_action_context_id
  IS
    SELECT MAX(pai.action_context_id)
      FROM pay_action_information                pai
     WHERE pai.action_information_category     ='IN_EOY_ORG'
       AND pai.action_context_type             = 'PA'
       AND pai.Action_information1             = p_gre_id
       AND pai.action_information3             = p_assessment_year;
  --
  l_procedure  VARCHAR2(100);
  l_action_context_id pay_assignment_actions.assignment_action_id%TYPE;
  --
  BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'get_max_context_id';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_gre_id',to_char(p_gre_id));
	pay_in_utils.trace('p_assessment_year',to_char(p_assessment_year));
	pay_in_utils.trace('**************************************************','********************');
   END IF;

  OPEN  csr_max_action_context_id;
  FETCH csr_max_action_context_id INTO l_action_context_id;
  CLOSE csr_max_action_context_id;

  IF g_debug THEN
     pay_in_utils.trace('l_action_context_id',l_action_context_id);
  END IF;
  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
  RETURN l_action_context_id;

END get_max_context_id;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_LOCATION_DETAILS                                --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : This procedure gets the gre location details        --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_location_id         hr_locations.location_id      --
--                : p_concatenate         VARCHAR2                      --
--                  p_field               VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_location_details ( p_location_id  IN   hr_locations.location_id%TYPE
                              , p_concatenate  IN   VARCHAR2     DEFAULT 'N'
                              , p_field        IN   VARCHAR2     DEFAULT NULL
                              )
RETURN VARCHAR2
IS

  CURSOR csr_get_location_details
  IS
    SELECT hr_loc.address_line_1
         , hr_loc.address_line_2
         , hr_loc.address_line_3
         , hr_loc.loc_information14
         , hr_loc.loc_information15
         , hr_general.decode_lookup('IN_STATES',hr_loc.loc_information16)
         , hr_general.decode_lookup('PER_US_COUNTRY_CODE',hr_loc.country)
         , hr_loc.postal_code
         , hr_loc.loc_information16
      FROM hr_locations  hr_loc
     WHERE location_id               = p_location_id;

  l_procedure  VARCHAR2(100);
  l_location_address1  hr_locations.address_line_1%TYPE;
  l_location_address2  hr_locations.address_line_2%TYPE;
  l_location_address3  hr_locations.address_line_3%TYPE;
  l_location_address4  hr_locations.loc_information14%TYPE;
  l_location_city      hr_locations.loc_information15%TYPE;
  l_location_state     hr_locations.loc_information16%TYPE;
  l_location_country   hr_locations.country%TYPE;
  l_location_zipcode   hr_locations.postal_code%TYPE;
  l_state_code         hr_locations.loc_information16%TYPE;
  l_details            VARCHAR2(1000);

  BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'get_location_details';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_location_id',to_char(p_location_id));
	pay_in_utils.trace('p_concatenate',p_concatenate);
	pay_in_utils.trace('p_field',      p_field);
	pay_in_utils.trace('**************************************************','********************');
   END IF;

  OPEN  csr_get_location_details;
  FETCH csr_get_location_details
   INTO l_location_address1
      , l_location_address2
      , l_location_address3
      , l_location_address4
      , l_location_city
      , l_location_state
      , l_location_country
      , l_location_zipcode
      , l_state_code;
  CLOSE csr_get_location_details;

  IF p_concatenate = 'Y' THEN

     SELECT l_location_address1   || DECODE(l_location_address1,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address2   || DECODE(l_location_address2,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address3   || DECODE(l_location_address3,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address4   || DECODE(l_location_address4,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_city       || DECODE(l_location_city    ,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_state      || DECODE(l_location_state   ,NULL,NULL,',')||
            l_location_country    || DECODE(l_location_country ,NULL,NULL,',')||
            l_location_zipcode
     INTO l_details
     FROM DUAL;

  ELSIF p_field = 'EMPLOYER_ADDRESS1' THEN
     l_details := l_location_address1;
  ELSIF p_field = 'EMPLOYER_ADDRESS2' THEN
     l_details := l_location_address2;
  ELSIF p_field = 'EMPLOYER_ADDRESS3' THEN
     l_details := l_location_address3;
  ELSIF p_field = 'EMPLOYER_ADDRESS4' THEN
     l_details := l_location_address4;
  ELSIF p_field = 'CITY' THEN
     l_details := l_location_city;
  ELSIF p_field = 'EMPLOYER_STATE' THEN
     l_details := l_location_state;
  ELSIF p_field = 'EMPLOYER_STATE_CODE' THEN
     l_details := l_state_code;
  ELSIF p_field = 'POSTAL_CODE' THEN
     l_details := l_location_zipcode;
  ELSIF p_field = 'COUNTRY' THEN
     l_details := l_location_country;
  END IF;
   l_details :=RTRIM(l_details,fnd_global.local_chr(10));
   l_details :=RTRIM(l_details,',');

 IF g_debug THEN
     pay_in_utils.trace('l_details', l_details );
 END IF;

 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

 RETURN l_details;

END get_location_details;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_ADDRESS_DETAILS                                 --
-- Type           : FUNCTION                                            --
-- Access         : Private                                             --
-- Description    : This procedure gets the employee address details    --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_location_id         per_addresses.address_id      --
--                : p_concatenate         VARCHAR2                      --
--                  p_field               VARCHAR2                      --
--------------------------------------------------------------------------
FUNCTION get_address_details ( p_address_id   IN   per_addresses.address_id%TYPE
                             , p_concatenate  IN   VARCHAR2     DEFAULT 'N'
                             , p_field        IN   VARCHAR2     DEFAULT NULL
                       )
RETURN VARCHAR2
IS

  CURSOR csr_get_address_details
  IS
    SELECT pad.address_line1
         , pad.address_line2
         , pad.address_line3
         , pad.add_information13
         , pad.add_information14
         , hr_general.decode_lookup('IN_STATES',pad.add_information15)
         , hr_general.decode_lookup('PER_US_COUNTRY_CODE',pad.country)
         , pad.postal_code
      FROM per_addresses pad
     WHERE pad.address_id            = p_address_id;

  l_procedure          VARCHAR2(100);
  l_location_address1  hr_locations.address_line_1%TYPE;
  l_location_address2  hr_locations.address_line_2%TYPE;
  l_location_address3  hr_locations.address_line_3%TYPE;
  l_location_address4  hr_locations.loc_information14%TYPE;
  l_location_city      hr_locations.loc_information15%TYPE;
  l_location_state     hr_locations.loc_information16%TYPE;
  l_location_country   hr_locations.country%TYPE;
  l_location_zipcode   hr_locations.postal_code%TYPE;
  l_details            VARCHAR2(1000);

  BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'get_location_details';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_address_id ',p_address_id );
	pay_in_utils.trace('p_concatenate',p_concatenate);
	pay_in_utils.trace('p_field'  ,p_field      );
	pay_in_utils.trace('**************************************************','********************');
   END IF;

  OPEN  csr_get_address_details;
  FETCH csr_get_address_details
   INTO l_location_address1
      , l_location_address2
      , l_location_address3
      , l_location_address4
      , l_location_city
      , l_location_state
      , l_location_country
      , l_location_zipcode;
  CLOSE csr_get_address_details;

  IF p_concatenate = 'Y' THEN

     SELECT l_location_address1   || DECODE(l_location_address1,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address2   || DECODE(l_location_address2,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address3   || DECODE(l_location_address3,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_address4   || DECODE(l_location_address4,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_city       || DECODE(l_location_city    ,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_state      || DECODE(l_location_state   ,NULL,NULL,',' || fnd_global.local_chr(10))  ||
            l_location_country
 INTO l_details
 FROM DUAL;

  ELSIF p_field = 'ADDRESS1' THEN
     l_details := l_location_address1;
  ELSIF p_field = 'ADDRESS2' THEN
     l_details := l_location_address2;
  ELSIF p_field = 'ADDRESS3' THEN
     l_details := l_location_address3;
  ELSIF p_field = 'ADDRESS4' THEN
     l_details := l_location_address4;
  ELSIF p_field = 'CITY' THEN
     l_details := l_location_city;
  ELSIF p_field = 'STATE' THEN
     l_details := l_location_state;
  ELSIF p_field = 'POSTAL_CODE' THEN
     l_details := l_location_zipcode;
  ELSIF p_field = 'COUNTRY' THEN
     l_details := l_location_country;
  END IF;

  l_details :=RTRIM(l_details,','||fnd_global.local_chr(10));



 IF g_debug THEN
     pay_in_utils.trace('l_details',l_details);
 END IF;

 pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
 RETURN l_details;

END get_address_details;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : WRITE_TAG                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure appends the tag                      --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_tag_name               VARCHAR2                   --
--                  p_tag_value              VARCHAR2                   --
--------------------------------------------------------------------------
PROCEDURE write_tag ( p_tag_name  IN VARCHAR2
                    , p_tag_value IN VARCHAR2)
IS
    l_tag VARCHAR2(10000);
    l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'write_tag';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_tag_name ',p_tag_name );
	pay_in_utils.trace('p_tag_value',p_tag_value);
	pay_in_utils.trace('**************************************************','********************');
   END IF;

     l_tag := pay_in_xml_utils.getTag( p_tag_name  => p_tag_name
                                     , p_tag_value => p_tag_value
                                     );

     dbms_lob.writeAppend(g_tmp_clob,length(l_tag),l_tag);
     pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
END write_tag;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : BUILD_GRE_XML                                       --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure builds the XML for GRE               --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_gre_id         NUMBER                             --
--------------------------------------------------------------------------
PROCEDURE build_gre_xml ( p_gre_id IN hr_organization_units.organization_id%TYPE)
IS
  CURSOR csr_get_gre_details (p_action_context_id NUMBER)
  IS
    SELECT 'ER_LEGAL'                    er_legal
         , UPPER(action_information8)    er_legal_value
         , 'ER_ADDRESS'                  er_address
         , get_location_details ( TO_NUMBER(action_information7)
                                , 'Y')   er_address_value
         , 'ER_NAME'                     er_org
         , UPPER(action_information6)    er_org_value
         , 'TAN'                         er_tan
         , UPPER(action_information4)    er_tan_value
         , 'GIR'                         er_gir
         , UPPER(action_information2)    er_gir_value
         , 'TDS_CIRCLE'                  er_tds
         , UPPER(action_information9)    er_tds_value
         , 'REP_NAME'                    rep_name
         , UPPER(Action_information11)   rep_name_value
         , 'REP_TITLE_NAME'              rep_title_name
         , Upper(Action_information12) || Upper(Action_information11) rep_title_value
         , 'REP_FATHER_NAME'             rep_father_name
         , UPPER(Action_information14)   rep_father_value
         , 'REP_POSITION'             rep_designation
         , Action_information13   rep_designation_value
         , 'PLACE'                       gre_place
         , pay_in_eoy_reports.get_location_details ( TO_NUMBER(action_information7)
                                                   , NULL
                                                   , 'CITY') gre_place_value
    FROM pay_action_information
   WHERE action_context_id           = p_action_context_id
     AND action_information_category = 'IN_EOY_ORG'
     AND action_information1         = p_gre_id
     AND ROWNUM =1;

  --
  -- Bug # 4506944 : Changed the cursor to include Bank Code instead of Bank Name and Branch,
  --                 Cheque /DD No and Transfer Voucher Number
  --
  CURSOR csr_bank_pymt IS
  ((SELECT fnd_date.canonical_to_date(hoi_challan.org_information2) Payment_date
        ,hoi_bank.org_information4  Bank
        ,hoi_challan.org_information3 Voucher_Num
        ,hoi_challan.org_information11 DD_Cheque_Num
    FROM hr_organization_information hoi_bank
        ,hr_organization_information hoi_challan
   WHERE hoi_bank.organization_id = p_gre_id
     AND hoi_challan.organization_id = hoi_bank.organization_id
     AND hoi_challan.org_information_context ='PER_IN_IT_CHALLAN_INFO'
     AND hoi_bank.org_information_context = 'PER_IN_CHALLAN_BANK'
     AND hoi_bank.org_information_id = hoi_challan.org_information5
     AND hoi_challan.org_information12 = 'N'
     AND hoi_challan.org_information1 = to_char(to_number(substr(g_assessment_year, 1,4))-1)||'-'||to_char(to_number(substr(g_assessment_year, 6,4))-1)
   )
   UNION ALL
  (SELECT fnd_date.canonical_to_date(hoi_challan.org_information2) Payment_date
        ,hoi_challan.org_information5  Bank
        ,hoi_challan.org_information3 Voucher_Num
        ,hoi_challan.org_information11 DD_Cheque_Num
    FROM hr_organization_information hoi_challan
   WHERE hoi_challan.organization_id = p_gre_id
     AND hoi_challan.org_information_context ='PER_IN_IT_CHALLAN_INFO'
     AND hoi_challan.org_information12 = 'Y'
     AND hoi_challan.org_information5 is null
     AND hoi_challan.org_information6 is null
     AND hoi_challan.org_information1 = to_char(to_number(substr(g_assessment_year, 1,4))-1)||'-'||to_char(to_number(substr(g_assessment_year, 6,4))-1)
   )) ORDER BY Payment_Date;

   CURSOR csr_form24q_receipt IS
   SELECT org_information2 quarter,DECODE(org_information6,'O',' Regular','C',' Correction') Nature,
          org_information4 receipt
   FROM hr_organization_information
  WHERE org_information_context = 'PER_IN_FORM24Q_RECEIPT_DF'
    AND org_information1 = g_assessment_year
    AND organization_id  = p_gre_id
    AND org_information5 = 'A'
    ORDER BY quarter;


  l_pymt_date         VARCHAR2(240);
  l_procedure         VARCHAR2(100);
  l_open_tag          VARCHAR2(100);
  l_last_quarter      VARCHAR2(10);
  l_action_context_id pay_assignment_actions.assignment_action_id%TYPE;


BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'build_gre_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


  g_Bank_Details_tbl.DELETE;


   IF g_debug THEN
	pay_in_utils.trace('p_gre_id ',to_char(p_gre_id ));
   END IF;

  l_action_context_id := get_max_context_id(p_gre_id,g_assessment_year);

  FOR i IN csr_get_gre_details(l_action_context_id)
  LOOP
      write_tag(i.er_legal,i.er_legal_value);
      write_tag(i.er_address,UPPER(i.er_address_value));
      write_tag(i.er_org,i.er_org_value);
      write_tag(i.er_tan,i.er_tan_value);
      write_tag(i.er_gir,i.er_gir_value);
      write_tag(i.er_tds,i.er_tds_value);
      write_tag(i.rep_name,i.rep_name_value);
      write_tag(i.rep_title_name,i.rep_title_value);
      write_tag(i.rep_father_name,i.rep_father_value);
      write_tag(i.rep_designation,i.rep_designation_value);
      write_tag(i.gre_place,i.gre_place_value);
  END LOOP;
  --
  -- Bug 4506944 : Changed as part of changes to be done to Form 16/16AA
  --
  g_index := 0;


  FOR i IN csr_bank_pymt
  LOOP
      l_pymt_date:= i.Payment_date;

      g_index := g_index + 1;
      g_Bank_Details_tbl(g_index).VDate := l_pymt_date;
      g_Bank_Details_tbl(g_index).Bank := i.Bank;
      g_Bank_Details_tbl(g_index).DDCheque_Num := i.DD_Cheque_Num;
      g_Bank_Details_tbl(g_index).VNumber := i.Voucher_Num;
  END LOOP;

  l_last_quarter :='N';

  FOR i in csr_form24q_receipt
  LOOP
     l_open_tag := '<Receipt>';
     dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

     write_tag('QR',i.Quarter||i.Nature);
     write_tag('RCPT',i.Receipt);
        IF i.Quarter = 'Q4' THEN
          l_last_quarter := 'Y';
        END IF;
     l_open_tag := '</Receipt>';
     dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
  END LOOP;
    pay_in_utils.set_location(g_debug,'At: '||l_procedure,14);
IF (l_last_quarter = 'N' AND SYSDATE >= g_tax_end_date ) THEN

 l_open_tag := '<Receipt>';
     dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

     write_tag('QR','Q4');
     write_tag('RCPT','Not Available as the last Quarterly Statement is yet to be furnished');
     l_open_tag := '</Receipt>';
     dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);


END IF;

  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

EXCEPTION

  WHEN OTHERS THEN
      pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,30);
    RAISE;

END build_gre_xml;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : BUILD_EMPLOYEE_XML                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure builds the XML for Employee          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_action_context_id         NUMBER                  --
--                  p_source_id                 NUMBER                  --
--                  p_rem_pay_period            NUMBER                  --
--                  p_flag                      NUMBER                  --
--------------------------------------------------------------------------
PROCEDURE build_employee_xml (p_action_context_id IN  pay_assignment_actions.assignment_action_id%TYPE
                             ,p_source_id         IN  pay_payroll_actions.payroll_action_id%TYPE
                             ,p_rem_pay_period    OUT NOCOPY NUMBER
                             ,p_flag              OUT NOCOPY NUMBER
                             )
IS

  l_procedure  VARCHAR2(100);

  CURSOR csr_get_person_data
  IS
  SELECT 'EID'                       empno_tag
       , pai.action_information1     empno_value
       , 'EE_DETAILS'                emp_details
       , UPPER(pai.action_information6
       || pai.action_information5
       || DECODE(pai.action_information9,NULL,'',fnd_global.local_chr(10))
       || pai.action_information9)    emp_details_value
       , 'E_F_NAME'                  emp_full_name
       , UPPER(pai.action_information5)     emp_full_value
       , 'E_TITLE'                   emp_title
       , UPPER(pai.action_information6)     emp_title_value
       , 'PAN'                       emp_pan
       , DECODE(pai.action_information4,'Y','APPLIED FOR','N','',pai.action_information4)     emp_pan_value
       , 'E_DESG'                    emp_designation
       , UPPER(pai.action_information9)     emp_designation_value
       , 'E_FAT_NAME'                emp_father_name
       , UPPER(pai.action_information7)     emp_father_value
       , 'DOB'                       emp_dob
       , TO_CHAR(fnd_date.canonical_to_date(pai.action_information10),'DD-MM-YYYY') emp_dob_value
       , 'GENDER'                    emp_gender
       , UPPER(pai.action_information11)    emp_gender_value
       , 'E_INTEREST'                emp_interest
       , DECODE(pai.action_information12,'N','No','Y','Yes')    emp_interest_value
       , 'ASG_START'                 emp_asg_start
       , TO_DATE(pai.action_information17,'DD-MM-RRRR') emp_asg_start_value
       , 'ASG_END'                   emp_asg_end
       , TO_DATE(pai.action_information18,'DD-MM-RRRR') emp_asg_end_value
       , 'E_ADDRESS'                 emp_address
       , get_address_details( pai.action_information14
                            , 'Y','NULL'
                            )        emp_address_value
       , 'EMP_POSTAL_CODE'           emp_zipcode
       , get_address_details( pai.action_information14
                            , 'N', 'POSTAL_CODE'
                            )        emp_zipcode_value
       , action_information20        emp_date_earned
       , assignment_id               emp_asg_id
       , action_information15        emp_resident_status
       , 'EMP_PHONE'                 emp_phone
       , action_information16        emp_phone_value
    FROM pay_action_information pai
   WHERE pai.action_information_category = 'IN_EOY_PERSON'
     AND pai.action_context_id           = p_action_context_id
     AND pai.source_id                   = p_source_id;

 CURSOR csr_payroll_id(p_assignment_id NUMBER,p_date DATE)
  IS
  SELECT paf.payroll_id
    FROM per_all_assignments_f paf
   WHERE paf.assignment_id =p_assignment_id
     AND p_date BETWEEN paf.effective_start_date AND paf.effective_end_date;

l_total_pay_period NUMBER;
l_current_pay_period NUMBER;
l_asg_id NUMBER;
l_date  VARCHAR2(30);
l_date_earned DATE;
l_resident_status VARCHAR2(30);
l_payroll_id NUMBER;
l_asg_end  DATE;

BEGIN
  g_debug          := hr_utility.debug_enabled;
  l_procedure := g_package ||'build_employee_xml';
  pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_action_context_id ',p_action_context_id );
	pay_in_utils.trace('p_source_id         ',p_source_id         );
	pay_in_utils.trace('**************************************************','********************');
   END IF;


  FOR i IN csr_get_person_data
  LOOP
      write_tag(i.empno_tag,i.empno_value);
      write_tag(i.emp_details,i.emp_details_value);
      write_tag(i.emp_full_name,i.emp_full_value);
      write_tag(i.emp_title,i.emp_title_value);
      write_tag(i.emp_pan,i.emp_pan_value);
      write_tag(i.emp_designation,i.emp_designation_value);
      write_tag(i.emp_father_name,i.emp_father_value);
      write_tag(i.emp_dob,i.emp_dob_value);
      write_tag(i.emp_gender,i.emp_gender_value);
      write_tag(i.emp_interest,i.emp_interest_value);
      write_tag(i.emp_asg_start,to_char(i.emp_asg_start_value,'DD-Mon-RRRR'));
      write_tag(i.emp_asg_end,to_char(i.emp_asg_end_value,'DD-Mon-RRRR'));
      write_tag(i.emp_address,i.emp_address_value);
      write_tag(i.emp_zipcode,i.emp_zipcode_value);
      write_tag(i.emp_phone,i.emp_phone_value);
      l_date    := i.emp_date_earned;
      l_asg_end := i.emp_asg_end_value;
      l_resident_status := i.emp_resident_status;
      l_asg_id := i.emp_asg_id;
  END LOOP;

  l_date_earned := fnd_date.canonical_to_date(l_date);

  OPEN csr_payroll_id(l_asg_id,l_date_earned);
  FETCH csr_payroll_id INTO l_payroll_id;
  CLOSE csr_payroll_id;

  l_total_pay_period   := pay_in_tax_utils.get_period_number(l_payroll_id,l_asg_end);
  l_current_pay_period := pay_in_tax_utils.get_period_number(l_payroll_id,l_date_earned);
  p_rem_pay_period     := GREATEST((l_total_pay_period - l_current_pay_period),0);



  IF(l_resident_status = 'RO') THEN
    p_flag := 1;
  ELSE
    p_flag := 0;
  END IF;

   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_rem_pay_period    ',to_char(p_rem_pay_period ));
	pay_in_utils.trace('p_flag              ',to_char(p_flag          ));
	pay_in_utils.trace('**************************************************','********************');
   END IF;

  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);


EXCEPTION
--
  WHEN OTHERS THEN
     pay_in_utils.set_location(g_debug,'Error in: '||l_procedure,30);
    RAISE;
  END build_employee_xml;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : BUILD_FORM16_XML                                    --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure builds the XML for Form 16 and 16AA  --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_action_context_id         NUMBER                  --
--                  p_source_id                 NUMBER                  --
--                  p_rem_pay_period            NUMBER                  --
--                  p_flag                      NUMBER                  --
--------------------------------------------------------------------------
PROCEDURE build_form16_xml (p_action_context_id  IN pay_assignment_actions.assignment_action_id%TYPE
                           ,p_source_id         IN  pay_payroll_actions.payroll_action_id%TYPE
                           ,p_rem_pay_period     IN NUMBER
                           ,p_flag               IN NUMBER
                           ,p_flag_for_16aa      OUT NOCOPY NUMBER)
IS
 --
  l_procedure  VARCHAR2(100);
  j NUMBER;
  l_prev_tds NUMBER;
  l_tax_in_words varchar2(240);
  l_Non_Taxable_Amt NUMBER;
  sort_index NUMBER;
  l_flag_for_12ba number;
  l_tds_value NUMBER;
  l_open_tag          VARCHAR2(100);
  l_tax_refundable NUMBER;
  l_marginal_relief NUMBER;
  l_prev_earnings NUMBER;
  l_qualifying_amt NUMBER;
  l_tot_80c_gross NUMBER;
  l_tot_80c_qual  NUMBER;
  l_tot_80ccc_gross NUMBER;
  l_tot_80ccc_qual  NUMBER;

  l_total_via      VARCHAR2(30);

  l_flag_rep_gen  NUMBER;
  emp_pos         NUMBER;
  l_tax_deposited NUMBER;
  l_serial_number NUMBER;


  c_index         NUMBER;
  l_emp_tds       NUMBER;
  l_emp_sur       NUMBER;
  l_emp_cess      NUMBER;
  l_emp_amount    NUMBER;
  l_entry_exists  NUMBER;

  l_via_seq_80c_num NUMBER;
  l_via_seq_80cce_num NUMBER;
  l_via_seq_80d_u_num NUMBER;

  l_80c_tag_seq  VARCHAR2(20);
  l_80cce_tag_seq   VARCHAR2(20);
  l_80du_tag_seq   VARCHAR2(20);

  l_tag             VARCHAR2(5);
  l_via_80c_flag    NUMBER;
  l_via_cce_flag    NUMBER;
  l_via_oth_flag    NUMBER;
  l_seq             CHAR(1) ;
  l_count           NUMBER ;
  l_loss_from_house NUMBER ;
  l_other_income    NUMBER ;



  CURSOR csr_salary_components
  IS
  SELECT DECODE(pai.action_information1,'F16 Salary Under Section 17', 1,
                                        'F16 Value of Perquisites',2,
                                        'F16 Profit in lieu of Salary', 3,
                                        'F16 Gross Salary',4,
                                        'F16 Gross Salary less Allowances',6,
                                        'F16 Entertainment Allowance', 7,
                                        'F16 Employment Tax',8,
                                        'F16 Deductions under Sec 16',9,
                                        'F16 Income Chargeable Under head Salaries',10,
                                        'F16 Other Income',11,
                                        'F16 Gross Total Income',12,
                                        'F16 Total Income',13,
                                        'F16 Tax on Total Income',14,
                                        'F16 Surcharge',15,
                                        'F16 Education Cess',16,
                                        'F16 Relief under Sec 89',18,
                                        'F16 Total Tax payable',19,
                                        'Income Tax Deduction',20,
                                        'F16 Balance Tax',21,
                                        'ER Paid Tax on Non Monetary Perquisite',22,
                                        0) sort_index,
        action_information2 balance_value
    FROM pay_action_information pai
   WHERE action_information_category = 'IN_EOY_ASG_SAL'
     AND action_context_id           = p_action_context_id
     AND source_id = p_source_id;

  CURSOR csr_prev_employment_tds
  IS
  SELECT 1
    FROM pay_action_information pai
   WHERE action_information_category = 'IN_EOY_ASG_SAL'
     AND action_context_id           = p_action_context_id
     AND source_id = p_source_id
     AND action_information1 IN('TDS on Previous Employment',
                                'CESS on Previous Employment',
                                'SC on Previous Employment');


  CURSOR csr_other_components(p_action_information1 pay_action_information.action_information1%TYPE)
  IS
  SELECT action_information2 balance_value
    FROM pay_action_information pai
   WHERE action_information_category = 'IN_EOY_ASG_SAL'
   AND action_context_id           = p_action_context_id
   AND source_id = p_source_id
   AND action_information1 = p_action_information1;

  CURSOR csr_other_income IS
  SELECT action_information1 balance_name,
         action_information2 balance_value
    FROM pay_action_information pai
   WHERE action_information_category = 'IN_EOY_ASG_SAL'
     AND action_context_id           = p_action_context_id
     AND source_id = p_source_id
     AND action_information1 IN('Long Term Capital Gains',
                                'Short Term Capital Gains',
                                'Business and Profession Gains',
                                'Other Sources of Income',
                                'Loss From House Property')
  AND action_information2 IS NOT NULL;

  CURSOR csr_allowances IS
  SELECT action_information1 Allowance_name,
         action_information2 Amt,
         action_information3 Std_Amt,
         action_information4 Taxable_Amt,
         action_information5 Std_Taxable_Amt
   FROM pay_action_information
  WHERE action_information_category = 'IN_EOY_ALLOW'
    AND action_context_id = p_action_context_id
    AND action_information1 <>   'Taxable Allowances'
    AND source_id =p_source_id;


  /* Get all Section 80C elements where the Gross Amount is greater than 0 */

 CURSOR csr_deduction_via
  IS
  SELECT DECODE(action_information1, 'Life Insurance Premium','Life Insurance Premium',
                                     'Deferred Annuity','Deferred Annuity',
                                     'Senior Citizens Savings Scheme','Senior Citizens Savings Scheme',
                                     'Five Year Post Office Time Deposit Account','Five Year Post Office Time Deposit Account',
                                     'NABARD Bank Deposits','NABARD Bank Deposits',
                                     'Public Provident Fund','Public Provident Fund',
                                     'Interest on NSC','Interest on National Savings Certificate reinvested',
                                     'House Loan Repayment', 'Principal Loan (Housing Loan) Repayment',
                                     'Mutual Fund or UTI','Notified units of Mutual Funds/UTI',
                                     'National Housing Bank', 'National Housing Bank Scheme',
                                     'ULIP','Unit Linked Insurance Plan (UTI,LIC etc)',
                                     'Notified Annuity Plan','Notified Annuity Plan',
                                     'Notified Pension Fund','Notified Pension Fund',
                                     'Public Sector Scheme','Public Sector Company Scheme',
                                     'Infrastructure Bonds','Investment in Infrastructure Bonds',
                                     'Tuition fee','Tuition Fees per children (max 2 children allowed)',
                                     'Superannuation Fund', 'Employee Contribution to an approved superannuation fund',
                                     'F16 Employee PF Contribution','Employee Contribution to Provident Fund',
                                     'NSC','NSC',
                                     'Deposits in Govt. Security','Deposits in Govt. Security',
                                     'Notified Deposit Scheme','Notified Deposit Scheme',
                                     'Approved Shares or Debentures','Approved Shares or Debentures',
                                     'Approved Mutual Fund','Approved Mutual Fund',
                                     'Fixed Deposits','Fixed Deposits',
                                     'X')Description_Value
       , action_information2 Qualifying_Value
       , nvl(action_information3,action_information2) Gross_Value
    FROM pay_action_information pai
   WHERE action_information_category = 'IN_EOY_VIA'
     AND action_context_id = p_action_context_id
     AND NVL(action_information3,action_information2) > 0
     AND source_id =p_source_id
   ORDER BY Description_Value;

  /* Get all Chapter VIA elements excluding 80C elements where the Gross Amount is greater than 0 */
CURSOR csr_deduction_via_d_to_u
  IS
  SELECT DECODE(action_information1, 'F16 Deductions Sec 80D','80D',
                                     'F16 Deductions Sec 80DD','80DD',
                                     'F16 Deductions Sec 80DDB','80DDB',
                                     'F16 Deductions Sec 80E','80E',
                                     'F16 Deductions Sec 80G','80G',
                                     'F16 Deductions Sec 80GG','80GG',
                                     'F16 Deductions Sec 80GGA','80GGA',
                                     'F16 Deductions Sec 80U','80U',
                                     'Pension Fund 80CCC','80CCC',
                                     'Govt Pension Scheme 80CCD','80CCD',
                                     'F16 Total Chapter VI A Deductions','TOTAL_V1A',
                                     'X')Description_Value
       , action_information2 Qualifying_Value
       , nvl(action_information3,action_information2) Gross_Value
    FROM pay_action_information pai
   WHERE action_information_category = 'IN_EOY_VIA'
     AND action_context_id = p_action_context_id
     AND NVL(action_information3,action_information2) > 0
     AND source_id =p_source_id
   ORDER BY Description_Value;

  /* Get Maxium assignment action of the run for each pay period of the tax year*/
  CURSOR csr_max_run_assact_period IS
  SELECT MAX(action_information4) run_assact
    FROM pay_action_information pai
   WHERE pai.action_information_category ='IN_EOY_ASG_SAL'
     AND pai.action_information1='Income Tax This Pay'
     AND pai.action_context_id = p_action_context_id
     AND pai.source_id = p_source_id
   GROUP BY TRUNC(TO_DATE(Action_information3,'DD-MM_RRRR'),'MM')
   ORDER BY TRUNC(TO_DATE(Action_information3,'DD-MM_RRRR'),'MM');

  -- Bug 4506944 : Changed the cursor as part of changes to be done to Form 16/16AA
  /*Get TDS paid in each pay period from the max assigment action id*/
  CURSOR csr_tds_paid(p_max_run_action_id NUMBER
                     ,p_information       VARCHAR2) IS
  SELECT action_information2 tds_value
        ,DECODE(TO_CHAR(TO_DATE(Action_information3,'DD-MM-RRRR'),'MM'),
        '04',1,
        '05',2,
        '06',3,
        '07',4,
        '08',5,
        '09',6,
        '10',7,
        '11',8,
        '12',9,
        '01',10,
        '02',11,
        '03',12)sort_index
    FROM pay_action_information
   WHERE action_context_id = p_action_context_id
     AND source_id =p_source_id
     AND action_information_category = 'IN_EOY_ASG_SAL'
     AND action_information1= p_information
     AND action_information4 = p_max_run_action_id;

  -- Added with changes to Form 24q
  CURSOR emp_challan_details IS
  SELECT input.name name
       ,value.screen_entry_value value
       , entries.element_entry_id
  FROM per_assignments_f assign
      ,pay_element_entries_f entries
      ,pay_element_types_f   type
      ,pay_input_values_f    input
      ,pay_element_entry_values_f value
      ,pay_element_links_f    links
 WHERE assign.assignment_id =
      (SELECT assignment_id
         FROM pay_assignment_actions
        WHERE assignment_action_id = p_action_context_id)
   AND links.element_type_id = type.element_type_id
   AND links.element_type_id = entries.element_type_id
   AND links.element_link_id = entries.element_link_id
   AND type.element_name = 'Income Tax Challan Information'
   AND type.element_type_id = entries.element_type_id
   AND entries.assignment_id = assign.assignment_id
   AND type.element_type_id = input.element_type_id
   AND value.element_entry_id = entries.element_entry_id
   AND value.input_value_id = input.input_value_id
   AND input.name in ('Amount Deposited'
                    , 'Education Cess Deducted'
                    , 'Income Tax Deducted'
                    , 'Surcharge Deducted'
                    , 'Challan or Voucher Number')
   AND type.legislation_code ='IN'
   AND entries.effective_start_date BETWEEN assign.effective_start_date AND assign.effective_end_date
   AND entries.effective_start_date BETWEEN g_tax_start_date AND g_tax_end_date
   AND entries.effective_start_date BETWEEN type.effective_start_date AND type.effective_end_date
   AND entries.effective_start_date BETWEEN input.effective_start_date AND input.effective_end_date
   AND entries.effective_start_date BETWEEN links.effective_start_date AND links.effective_end_date
   AND value.effective_start_date BETWEEN g_tax_start_date AND g_tax_end_date
ORDER BY entries.element_entry_id
       , input.name;

  BEGIN
      g_debug          := hr_utility.debug_enabled;
      l_procedure := g_package ||'build_form16_xml';
      pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


   IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_action_context_id ',p_action_context_id );
	pay_in_utils.trace('p_source_id         ',p_source_id         );
	pay_in_utils.trace('p_rem_pay_period    ',to_char(p_rem_pay_period));
	pay_in_utils.trace('p_flag              ',to_char(p_flag));
	pay_in_utils.trace('**************************************************','********************');
   END IF;

    l_flag_for_12ba :=0;
    l_flag_rep_gen  := -1;


    g_salary_record(1).Value  := 0;
    g_salary_record(2).Value  := 0;
    g_salary_record(3).Value  := 0;
    g_salary_record(4).Value  := 0;
    g_salary_record(5).Value  := 0;
    g_salary_record(6).Value  := 0;
    g_salary_record(7).Value  := 0;
    g_salary_record(8).Value  := 0;
    g_salary_record(9).Value  := 0;
    g_salary_record(10).Value := 0;
    g_salary_record(11).Value := 0;
    g_salary_record(12).Value := 0;
    g_salary_record(13).Value := 0;
    g_salary_record(14).Value := 0;
    g_salary_record(15).Value := 0;
    g_salary_record(16).Value := 0;
    g_salary_record(17).Value := 0;
    g_salary_record(18).Value := 0;
    g_salary_record(19).Value := 0;
    g_salary_record(20).Value := 0;
    g_salary_record(21).Value := 0;
    g_salary_record(22).Value := 0;
    l_tot_80ccc_qual := 0;
    l_tot_80c_qual := 0;

    l_tot_80ccc_gross := 0;
    l_tot_80c_gross := 0;



    FOR i IN csr_salary_components
    LOOP
        IF i.sort_index <> '0' THEN
           IF(l_flag_rep_gen = -1 )THEN
             l_flag_rep_gen := 1;
           END IF ;
           g_salary_record(i.sort_index).Value := i.balance_value;
        END IF;
    END LOOP;

    OPEN csr_other_components('F16 Tax Refundable');
    FETCH csr_other_components INTO l_tax_refundable;
     IF csr_other_components%NOTFOUND THEN
          l_tax_refundable := 0;
     END IF;
    CLOSE  csr_other_components;

    OPEN csr_other_components('F16 Marginal Relief');
    FETCH csr_other_components INTO l_marginal_relief;
       IF csr_other_components%NOTFOUND THEN
           l_marginal_relief := 0;
       END IF;
    CLOSE  csr_other_components;

  --
  -- Bug 4557407 removed surcharge to Tax on Income
  --
  -- Total Nontaxable Allowance
  -- Tax Paybale and Refundable

    g_salary_record(5).Value  := nvl(g_salary_record(4).Value,0)  - nvl(g_salary_record(6).Value,0);

    IF (g_salary_record(21).Value = 0) THEN
       g_salary_record(21).Value := -l_tax_refundable;
    END IF;

    FOR i in 1..22 LOOP
      write_tag(g_salary_record(i).Name,pay_us_employee_payslip_web.get_format_value(g_business_group_id,g_salary_record(i).Value));
    END LOOP;
--    write_tag('DUMMY',pay_us_employee_payslip_web.get_format_value(g_business_group_id,g_salary_record(22).Value));

--    g_873 := g_868 + g_872;
    write_tag('TDS_DEDUCTED',pay_us_employee_payslip_web.get_format_value(g_business_group_id,(NVL(g_salary_record(20).Value,0) + NVL(g_salary_record(22).Value,0))));

    write_tag('TAX_ON_TOT_INCOME',pay_us_employee_payslip_web.get_format_value(g_business_group_id,(NVL(g_salary_record(14).Value,0) + NVL(g_salary_record(15).Value,0) + NVL(g_salary_record(16).Value,0) - l_marginal_relief)));

    OPEN csr_other_components('Previous Employment Earnings');
    FETCH csr_other_components INTO l_prev_earnings;
    IF csr_other_components%NOTFOUND THEN
      l_prev_earnings := 0;
    END IF;
    CLOSE  csr_other_components;


    OPEN csr_prev_employment_tds;
    FETCH csr_prev_employment_tds INTO l_prev_tds;
    IF csr_prev_employment_tds%NOTFOUND THEN
      l_prev_tds := 0;
    END IF;
    CLOSE csr_prev_employment_tds;

    IF (g_salary_record(21).Value <> 0 AND l_flag_rep_gen = -1) THEN
      l_flag_rep_gen := 1;
    END IF;

        /* Chapter VIA Start */
    l_total_via :=0;

    l_via_80c_flag := 0;
    l_via_cce_flag := 0;
    l_via_oth_flag := 0;

    l_via_seq_80c_num := 1;
    l_via_seq_80cce_num := 97;
    l_via_seq_80d_u_num := 97;

    l_80cce_tag_seq := '('||fnd_global.local_chr(l_via_seq_80cce_num)||')';


    FOR i IN csr_deduction_via LOOP
      IF (l_via_80c_flag  = 0 and i.Description_Value <> 'X') THEN
        l_via_80c_flag := 1;
        l_via_cce_flag := 1;
        write_tag('SEC80C',l_via_80c_flag);
        write_tag('AS',l_80cce_tag_seq);
        l_via_seq_80cce_num := l_via_seq_80cce_num + 1;

        IF(l_flag_rep_gen = -1) THEN
          l_flag_rep_gen := 1;
        END IF;

      END IF;

      IF(i.Description_Value <> 'X')THEN
       l_80c_tag_seq :=  ltrim(lower(to_char(l_via_seq_80c_num,'RM')),' ' )||')';

       l_open_tag := '<CGRP>';
       dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

       write_tag('RN',l_80c_tag_seq);
       write_tag('NAME',i.Description_Value);
       write_tag('GROSS',pay_us_employee_payslip_web.get_format_value(g_business_group_id,nvl(i.Gross_Value,0)));
       l_via_seq_80c_num := l_via_seq_80c_num + 1;
       l_tot_80c_gross := l_tot_80c_gross + nvl(i.Gross_Value,0);
       l_tot_80c_qual  := l_tot_80c_qual  + nvl(i.Qualifying_Value,0);
       l_open_tag := '</CGRP>';
       dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
       END IF;
    END LOOP;

     l_tot_80c_qual := LEAST(l_tot_80c_qual,g_80cce_limit);

      write_tag('TOT_80C_GR',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_tot_80c_gross));
      write_tag('TOT_80C_QA',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_tot_80c_qual));

    FOR i in csr_deduction_via_d_to_u LOOP
      IF(l_flag_rep_gen = -1) THEN
        l_flag_rep_gen := 1;
      END IF;

      IF(i.Description_Value = 'TOTAL_V1A') THEN
        l_total_via := nvl(i.Qualifying_Value,0);
      ELSIF(i.Description_Value <> 'X')THEN
        IF i.Description_Value IN('80D',
                                  '80DD',
                                  '80DDB',
                                  '80E',
                                  '80G',
                                  '80GG',
                                  '80GGA',
                                  '80U') THEN
           l_via_oth_flag := 1;
           l_80du_tag_seq := '('||fnd_global.local_chr(l_via_seq_80d_u_num)||')';
           l_open_tag := '<OTHER_VIA>';
           dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

           l_qualifying_amt := nvl(i.Qualifying_Value,0);
           write_tag('SN',l_80du_tag_seq);
           write_tag('NAME',i.Description_Value);
           write_tag('GROSS',pay_us_employee_payslip_web.get_format_value(g_business_group_id,nvl(i.Gross_Value,0)));
           write_tag('QUAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_qualifying_amt));

           l_open_tag := '</OTHER_VIA>';
           dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
           l_via_seq_80d_u_num := l_via_seq_80d_u_num +1;
        ELSIF i.Description_Value IN('80CCC','80CCD') THEN
           l_via_cce_flag := 1;
           l_80cce_tag_seq := '('||fnd_global.local_chr(l_via_seq_80cce_num)||')';
           l_qualifying_amt := LEAST(g_80cce_limit,nvl(i.Qualifying_Value,0));
           l_tag := substr(i.Description_Value,3);
           l_open_tag := '<'||l_tag||'GRP>';
           dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

           write_tag('AS',l_80cce_tag_seq);

           write_tag('GROSS',pay_us_employee_payslip_web.get_format_value(g_business_group_id,nvl(i.Gross_Value,0)));
           write_tag('QUAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_qualifying_amt));

           l_via_seq_80cce_num := l_via_seq_80cce_num + 1;

           l_open_tag := '</'||l_tag||'GRP>';
           dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
           l_tot_80ccc_gross := l_tot_80ccc_gross + nvl(i.Gross_Value,0);
           l_tot_80ccc_qual  := l_tot_80ccc_qual + l_qualifying_amt;
        ELSE
          NULL;
        END IF;
      END IF;
    END LOOP;
l_tot_80ccc_gross := l_tot_80ccc_gross + l_tot_80c_gross;
l_tot_80ccc_qual  := l_tot_80ccc_qual + l_tot_80c_qual;

 IF (l_via_cce_flag <> 1 ) THEN
  write_tag('VIACCE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,0));
 END IF;
      write_tag('SEC80CCE',l_via_cce_flag);
      write_tag('TOT_80CCC_GR',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_tot_80ccc_gross));
      write_tag('TOT_80CCC_QA',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_tot_80ccc_qual));

 IF (l_via_oth_flag <> 1)THEN
  write_tag('VIAOTH',pay_us_employee_payslip_web.get_format_value(g_business_group_id,0));
 END IF;

 write_tag('TOTAL_V1A',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_total_via));
    /* Chapter VIA End */


  /* Check for Form Generation and Other Income Start*/
    t_table_1(1) :=0;
    t_table_1(2) :=0;
    t_table_1(3) :=0;
    t_table_1(4) :=0;
    t_table_1(5) :=0;

    FOR i IN csr_other_income LOOP
      IF(l_flag_rep_gen = -1) THEN
        l_flag_rep_gen := 1;
      END IF;

      IF (i.balance_name ='Business and Profession Gains') THEN
         t_table_1(1)    := i.balance_value;
      ELSIF (i.balance_name ='Long Term Capital Gains' ) THEN
         t_table_1(2)   := i.balance_value;
      ELSIF (i.balance_name ='Short Term Capital Gains' ) THEN
         t_table_1(3)   := i.balance_value;
      ELSIF (i.balance_name ='Other Sources of Income' ) THEN
         t_table_1(4)   := i.balance_value;
      ELSIF (i.balance_name ='Loss From House Property') THEN
         t_table_1(5)   := i.balance_value;
      END IF;
    END LOOP;

    IF l_flag_rep_gen = -1 THEN
      /* Do not generate any report for this employee */
      p_flag_for_16aa := -1;
      emp_pos := INSTR(g_tmp_clob,'<EMPLOYEE>',-1);
      dbms_lob.TRIM(g_tmp_clob,emp_pos-1);
    ELSE
      /* Generate either 16 /16AA for this employee */
      p_flag_for_16aa := 1;

      IF ((g_salary_record(10).Value = 0)
      OR ((g_salary_record(6).Value + l_prev_earnings)>150000)
      OR (l_prev_earnings <>0 AND l_prev_tds > 0)
      OR (t_table_1(1) <>0 OR t_table_1(2) <>0)
      OR p_flag = 0 )
      THEN
         p_flag_for_16aa :=0; -- Not eligible for 16AA
      END IF;


         FOR i IN 1..5 LOOP
           IF(t_table_1(i) <>0) THEN
            l_open_tag := '<Other_Income>';
            dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

            IF (i=1 )THEN
              write_tag('NAME','Business and Profession Gains');
              write_tag('VALUE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,t_table_1(1)));
            ELSIF (i=2 ) THEN
              write_tag('NAME','Long Term Capital Gains');
              write_tag('VALUE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,t_table_1(2)));
            ELSIF (i=3) THEN
              write_tag('NAME','Short Term Capital Gains');
              write_tag('VALUE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,t_table_1(3)));
            ELSIF (i=4) THEN
              write_tag('NAME','Other Sources of Income');
              write_tag('VALUE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,t_table_1(4)));
            ELSIF (i=5) THEN
              write_tag('NAME','Loss From House Property');
              write_tag('VALUE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,0-t_table_1(5)));
            END IF;


            l_open_tag := '</Other_Income>';
            dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
           END IF;
         END LOOP;

	 IF p_flag_for_16aa = 1 THEN

	       l_open_tag := '<SEC_OTHERS>';
               dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
	       write_tag('SECTION','(h) 80C');
	       write_tag('SEC_GROSS',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_tot_80c_gross));
	       write_tag('SEC_QUAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_tot_80c_qual));
	       l_open_tag := '</SEC_OTHERS>';
               dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

	       l_count :=0;

          FOR rec_deduction_via_d_to_u IN csr_deduction_via_d_to_u
          LOOP
	   IF (rec_deduction_via_d_to_u.Description_Value NOT IN ('TOTAL_V1A','X')) THEN
            IF  rec_deduction_via_d_to_u.Description_Value = '80CCC' THEN
	       write_tag('SEC80CCC',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Gross_Value));
	       write_tag('SEC80CCC_QAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Qualifying_Value));
            ELSIF rec_deduction_via_d_to_u.Description_Value = '80D' THEN
	       write_tag('SEC80D',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Gross_Value));
	       write_tag('SEC80D_QAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Qualifying_Value));
            ELSIF rec_deduction_via_d_to_u.Description_Value = '80E' THEN
	       write_tag('SEC80E',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Gross_Value));
	       write_tag('SEC80E_QAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Qualifying_Value));
            ELSIF rec_deduction_via_d_to_u.Description_Value = '80G' THEN
	       write_tag('SEC80G',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Gross_Value));
	       write_tag('SEC80G_QAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Qualifying_Value));
	    ELSE


               l_count := l_count + 1;

               select lower(fnd_global.local_chr(r+64)) INTO l_seq
	       FROM
	       ( SELECT LEVEL r
	       FROM dual
	       CONNECT BY LEVEL <= 26 )
	       WHERE r+64 = 72 + l_count;

	       l_open_tag := '<SEC_OTHERS>';
               dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
	       write_tag('SECTION','('||l_seq||') '||rec_deduction_via_d_to_u.Description_Value);
	       write_tag('SEC_GROSS',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Gross_Value));
	       write_tag('SEC_QUAL',pay_us_employee_payslip_web.get_format_value(g_business_group_id,rec_deduction_via_d_to_u.Qualifying_Value));
	       l_open_tag := '</SEC_OTHERS>';
               dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
	    END IF ;
	   END IF ;
          END LOOP ;




	  FOR i IN 1..5 LOOP
           IF(t_table_1(i) <>0) THEN

	    IF (i=5) THEN
              l_loss_from_house := t_table_1(i) ;
	    ELSIF (i=4) THEN
              l_other_income :=  t_table_1(i) ;
            END IF;

           END IF;
          END LOOP;

          write_tag('OI_HOUSE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_loss_from_house));
          write_tag('OI_OTHER',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_other_income));

	 END IF ;

      t_table_1.DELETE;
      /* Check for 16aa and Other Income End*/

      IF ((g_salary_record(4).Value + l_prev_earnings)>150000 OR
           g_salary_record(2).Value > 0 OR
           g_salary_record(3).Value > 0
         ) THEN
       l_flag_for_12ba :=1; --Eligible for 12BA
      END IF;

      write_tag('EE_INCOME',pay_us_employee_payslip_web.get_format_value(g_business_group_id,g_salary_record(10).Value - g_salary_record(2).Value));
      write_tag('C_16AA_FLAG',p_flag_for_16aa );
      write_tag('C_12BA_FLAG',l_flag_for_12ba );

      l_tax_in_words := pay_in_utils.number_to_words(g_salary_record(20).Value);
      write_tag('TOTAL',l_tax_in_words );

      /* Allowances Start*/
      FOR i in csr_allowances LOOP
      --
        IF (i.Allowance_Name='House Rent Allowance') THEN
           l_Non_Taxable_Amt := nvl(i.Amt,0) + nvl(i.Std_AMt,0)* p_rem_pay_period - nvl(i.Std_Taxable_Amt,0);
        ELSE
           l_Non_Taxable_Amt := nvl(i.Amt,0) - nvl(i.Taxable_Amt,0) + (nvl(i.Std_AMt,0) - nvl(i.Std_Taxable_Amt,0)) * p_rem_pay_period ;
        END IF;
        --
        IF( l_Non_Taxable_Amt > 0) THEN
           l_open_tag := '<Allowance>';
           dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

           write_tag('NAME',i.Allowance_Name);
           write_tag('VALUE',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_Non_Taxable_Amt));

           l_open_tag := '</Allowance>';
           dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

        END IF;
          --
      END LOOP;
       /* Allowances End*/

      /* Challan Start */

      /*As per FY 2009, the format for Form 16AA is similar to Form16.
       So the code related to Form16AA is deleted*/
         g_emp_challan_details_tbl.DELETE;
         c_index := 1;

         FOR emp_challan IN  emp_challan_details
         LOOP
           IF emp_challan.name = 'Amount Deposited' THEN
              g_emp_challan_details_tbl(c_index).emp_amount   := nvl(emp_challan.value, 0);
           END IF;

           IF emp_challan.name = 'Challan or Voucher Number' THEN
              g_emp_challan_details_tbl(c_index).emp_voucher      := emp_challan.value;
           END IF;

           IF emp_challan.name = 'Education Cess Deducted' THEN
              g_emp_challan_details_tbl(c_index).emp_cess := nvl(emp_challan.value, 0);
           END IF;

           IF emp_challan.name = 'Income Tax Deducted' THEN
              g_emp_challan_details_tbl(c_index).emp_tds   := nvl(emp_challan.value, 0);
           END IF;

           IF emp_challan.name = 'Surcharge Deducted' THEN
              g_emp_challan_details_tbl(c_index).emp_sur  := nvl(emp_challan.value, 0);
              c_index := c_index + 1;
           END IF;
         END LOOP;

         /*Merge Bank Details at Org Level with TDS Details at Person level*/
         l_serial_number := 1;
         FOR I IN 1..g_index LOOP

           l_emp_tds := 0;
           l_emp_sur := 0;
           l_emp_cess := 0;
           l_emp_amount := 0;

           IF g_Bank_Details_tbl.exists(i) THEN

              l_entry_exists := 0;

              FOR j IN 1..(c_index-1) LOOP
                IF (g_Bank_Details_tbl(i).VNumber =
NVL( substr(g_emp_challan_details_tbl(j).emp_voucher, instr(g_emp_challan_details_tbl(j).emp_voucher,' - ',1)+3, (instr(g_emp_challan_details_tbl(j).emp_voucher,' - ',-1) - instr(g_emp_challan_details_tbl(j).emp_voucher,' - ',1))-3) , '-1')
                   and  to_char(g_Bank_Details_tbl(i).VDate,'DD-Mon-RRRR') = substr(g_emp_challan_details_tbl(j).emp_voucher, instr(g_emp_challan_details_tbl(j).emp_voucher,' - ',-1)+3)
                   and  g_Bank_Details_tbl(i).Bank = substr(g_emp_challan_details_tbl(j).emp_voucher,1,instr(g_emp_challan_details_tbl(j).emp_voucher,' - ',1)-1)
		    )THEN
                   l_emp_tds := l_emp_tds + g_emp_challan_details_tbl(j).emp_tds;
                   l_emp_sur := l_emp_sur + g_emp_challan_details_tbl(j).emp_sur;
                   l_emp_cess := l_emp_cess + g_emp_challan_details_tbl(j).emp_cess;
                   l_emp_amount := l_emp_amount + g_emp_challan_details_tbl(j).emp_amount;
                   l_entry_exists := 1;
                END IF;
              END LOOP;

              IF l_entry_exists = 1 THEN
                 l_open_tag := '<t_month>';
                 dbms_lob.writeAppend(g_tmp_clob,LENGTH(l_open_tag),l_open_tag);
                 write_tag('SNO',l_serial_number);
                 l_serial_number := l_serial_number + 1;
		 IF (g_tax_start_date >= TO_DATE('01/04/2009','DD/MM/YYYY')) THEN
                   write_tag('TDS_PERIOD',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_emp_tds+l_emp_sur));
                   write_tag('SURCHARGE_PERIOD',pay_us_employee_payslip_web.get_format_value(g_business_group_id,0));
		 ELSE
		   write_tag('TDS_PERIOD',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_emp_tds));
                   write_tag('SURCHARGE_PERIOD',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_emp_sur));
		 END IF ;
                 write_tag('ECESS_PERIOD',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_emp_cess));
                 write_tag('TAX_DEPOSITED',pay_us_employee_payslip_web.get_format_value(g_business_group_id,l_emp_amount));
                 write_tag('PYMT_DATE',to_char(g_Bank_Details_tbl(i).VDate,'DD/MM/RRRR'));
                 write_tag('BANK_BRANCH',g_Bank_Details_tbl(i).Bank);
                 write_tag('VOUCHER_NUM',g_Bank_Details_tbl(i).VNumber);
                 write_tag('CHEQUE_DD_NUMBER',g_Bank_Details_tbl(i).DDCheque_Num);
                 l_open_tag := '</t_month>';
                 dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
              END IF;

           END IF;

         END LOOP;

    END IF;
      /* Challan End */
    IF g_debug THEN
	pay_in_utils.trace('p_flag_for_16aa    	', p_flag_for_16aa   );
    END IF;
   pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);
  END build_form16_xml;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : BUILD_FORM12BA_XML                                  --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure builds the XML for Form 12BA         --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_action_context_id         NUMBER                  --
--------------------------------------------------------------------------
PROCEDURE build_form12ba_xml(p_action_context_id  IN pay_assignment_actions.assignment_action_id%TYPE
                            ,p_source_id         IN  pay_payroll_actions.payroll_action_id%TYPE)
IS
  l_total_taxable_perq  NUMBER;
  l_total_emp_contr     NUMBER;

  CURSOR csr_get_perq_values
  IS
  SELECT DECODE(action_information1, 'Company Accommodation', 1
                                   , 'Motor Car Perquisite',2
                                   , 'Domestic Servant',3
                                   , 'Gas / Water / Electricity', 4
                                   , 'Loan at Concessional Rate',5
                                   , 'Travel / Tour / Accommodation',7
                                   , 'Leave Travel Concession',7
                                   , 'Lunch Perquisite',8
                                   , 'Free Education', 9
                                   , 'Gift Voucher', 10
                                   , 'Credit Cards', 11
                                   , 'Club Expenditure', 12
                                   , 'Company Movable Assets',13
                                   , 'Transfer of Company Assets',14
                                   , 'Employer Paid Tax',15
                                   , 'Shares',16
                                   , 20) sort_index
      , SUM(NVL(action_information2,0)) value1
      , SUM(NVL(action_information3,0)) value2
   FROM pay_action_information
  WHERE action_information_category = 'IN_EOY_PERQ'
    AND action_context_id           = p_action_context_id
    AND source_id =p_source_id
    GROUP BY DECODE(action_information1, 'Company Accommodation', 1
                                   , 'Motor Car Perquisite',2
                                   , 'Domestic Servant',3
                                   , 'Gas / Water / Electricity', 4
                                   , 'Loan at Concessional Rate',5
                                   , 'Travel / Tour / Accommodation',7
                                   , 'Leave Travel Concession',7
                                   , 'Lunch Perquisite',8
                                   , 'Free Education', 9
                                   , 'Gift Voucher', 10
                                   , 'Credit Cards', 11
                                   , 'Club Expenditure', 12
                                   , 'Company Movable Assets',13
                                   , 'Transfer of Company Assets',14
                                   , 'Employer Paid Tax',15
                                   , 'Shares',16
                                   , 20) ;

 CURSOR csr_get_total_perq(p_action_information1 pay_action_information.action_information1%TYPE)
  IS
  SELECT NVL(action_information2,0) value1
   FROM pay_action_information
  WHERE action_information_category = 'IN_EOY_PERQ'
    AND action_context_id           = p_action_context_id
    AND source_id =p_source_id
    AND action_information1 = p_action_information1;


l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'build_form12ba_xml';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


    IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('p_action_context_id ', p_action_context_id   );
	pay_in_utils.trace('p_source_id         ', p_source_id           );
	pay_in_utils.trace('**************************************************','********************');
    END IF;

     FOR j in csr_get_perq_values
     LOOP
         g_perq_record(j.sort_index).perq_value1 := j.value1;
         g_perq_record(j.sort_index).perq_value2 := j.value2;
     END LOOP;

     FOR i in 1..16
     LOOP
         g_perq_record(17).perq_value1 := g_perq_record(17).perq_value1 + g_perq_record(i).perq_value1;
         g_perq_record(17).perq_value2 := g_perq_record(17).perq_value2 + g_perq_record(i).perq_value2;
     END LOOP;



     OPEN csr_get_total_perq('Taxable Perquisites');
     FETCH csr_get_total_perq INTO l_total_taxable_perq;
       IF csr_get_total_perq%NOTFOUND THEN
         l_total_taxable_perq := 0;
       END IF;
     CLOSE csr_get_total_perq;

     OPEN csr_get_total_perq('Perquisite Employee Contribution');
     FETCH csr_get_total_perq INTO l_total_emp_contr;
       IF csr_get_total_perq%NOTFOUND THEN
         l_total_emp_contr := 0;
       END IF;
     CLOSE csr_get_total_perq;

      g_perq_record(18).perq_value1 := l_total_taxable_perq;
      g_perq_record(18).perq_value2 :=  l_total_emp_contr;

      g_perq_record(17).perq_value1 := g_perq_record(18).perq_value1 - g_perq_record(17).perq_value1;
      g_perq_record(17).perq_value2 :=  g_perq_record(18).perq_value2 - g_perq_record(17).perq_value2;

     FOR i in 1..18
     LOOP

         write_tag( p_tag_name => 'P' || i || '_V3'
                  , p_tag_value => pay_us_employee_payslip_web.get_format_value
                                              ( g_business_group_id
                                              , g_perq_record(i).perq_value1
                                              )
                  );
         write_tag( p_tag_name => 'P' || i || '_V2'
                  , p_tag_value => pay_us_employee_payslip_web.get_format_value
                                              ( g_business_group_id
                                              , g_perq_record(i).perq_value2
                                              )
                  );
         write_tag( p_tag_name => 'P' || i || '_V1'
                  , p_tag_value => pay_us_employee_payslip_web.get_format_value
                                              ( g_business_group_id
                                              , g_perq_record(i).perq_value1 + g_perq_record(i).perq_value2
                                              )
                  );

     END LOOP;
  pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,20);

END build_form12ba_xml;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : GET_TEMPLATE                                        --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure gets the payslip template code       --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id    NUMBER                       --
--            OUT : p_template             VARCHAR2                     --
--------------------------------------------------------------------------
PROCEDURE get_template (p_business_group_id    IN NUMBER
                       ,p_template             OUT NOCOPY VARCHAR2
                       )
IS

l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'build_form12ba_xml';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


    IF g_debug THEN
	pay_in_utils.trace('p_business_group_id ', to_char(p_business_group_id)   );
    END IF;

  p_template   := 'PAY_IN_ITR_EE_05';
  g_chunk_size := 10;
  g_business_group_id := p_business_group_id;

   IF g_debug THEN
	pay_in_utils.trace('p_template         ', p_template);
    END IF;
  pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);
EXCEPTION

  WHEN OTHERS THEN
  pay_in_utils.set_location(g_debug,'Error in : '||l_procedure,20);
    RAISE;

END get_template;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : FETCH_XML                                           --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure returns the next CLOB available in   --
--                  global CLOB array                                   --
--                                                                      --
-- Parameters     :                                                     --
--             IN : N/A                                                 --
--            OUT : p_clob                 CLOB                         --
--------------------------------------------------------------------------
PROCEDURE fetch_xml (p_clob    OUT NOCOPY CLOB)
IS
l_procedure varchar2(100);

BEGIN
g_debug          := hr_utility.debug_enabled;
l_procedure := g_package ||'fetch_xml';
pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);

  -- If Clobs exists return next clob else exit NULL
  hr_utility.trace('Clob Count        : ' || g_clob_cnt);
  hr_utility.trace('Clob Fetch Count  : ' || g_fetch_clob_cnt);
  IF (g_clob_cnt <> 0 ) AND (g_fetch_clob_cnt < g_clob_cnt) THEN
     g_fetch_clob_cnt := g_fetch_clob_cnt + 1;
     p_clob := g_clob(g_fetch_clob_cnt);
  ELSE
    p_clob := null;
  END IF;

pay_in_utils.set_location(g_debug,'Leaving: '||l_procedure,20);

END fetch_xml;

--------------------------------------------------------------------------
--                                                                      --
-- Name           : LOAD_XML                                            --
-- Type           : PROCEDURE                                           --
-- Access         : Public                                              --
-- Description    : This procedure makes a list of XMLs in a global     --
--                  CLOB array                                          --
--                                                                      --
-- Parameters     :                                                     --
--             IN : p_business_group_id     NUMBER                      --
--                  p_assessment_year       VARCHAR2                    --
--                  p_gre_organization      VARCHAR2                    --
--                  p_employee_type         VARCHAR2                    --
--                  p_employee_number       VARCHAR2                    --
--            OUT : p_clob_cnt              NUMBER                      --
--------------------------------------------------------------------------
-- Flow :                                                               --
-- For EACH GRE                                                         --
--     Get the details of GRE                                           --
--     For EACH Employee                                                --
--         Get the details for Form 16, 16AA, 12BA and                  --
--         Build the XML for every employee                             --
--         by calling the respective procedures                         --
--     END FOR EACH EMPLOYEE                                            --
-- END FOR EACH GRE                                                     --
--------------------------------------------------------------------------
PROCEDURE load_xml (p_business_group_id  IN  NUMBER
                   ,p_assessment_year    IN  VARCHAR2
                   ,p_gre_organization   IN  VARCHAR2   DEFAULT NULL
                   ,p_employee_type      IN  VARCHAR2
                   ,p_employee_number    IN  VARCHAR2   DEFAULT NULL
                   ,p_clob_cnt           OUT NOCOPY     NUMBER
                   )
IS
    l_procedure         VARCHAR2(100);
    l_open_tag          VARCHAR2(100);
    l_gre_id            hr_organization_units.organization_id%TYPE;
    l_action_context_id pay_assignment_actions.assignment_action_id%TYPE;
    l_emp_number        per_people_f.employee_number%TYPE;
    l_emp_count         NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    l_source_id         NUMBER;
    l_flag_for_16aa     NUMBER;



    CURSOR csr_fetch_gre( p_gre_id  IN hr_organization_units.organization_id%TYPE)
    IS
      SELECT hou.organization_id orgid
        FROM hr_all_organization_units hou
           , hr_organization_information hoi
       WHERE hou.organization_id = hoi.organization_id
         AND hoi.org_information_context  = 'CLASS'
         AND hoi.org_information1         = 'HR_LEGAL'
         AND hoi.org_information2         = 'Y'
         AND hou.organization_id          =  NVL(p_gre_id,hou.organization_id)
         AND hou.business_group_id = p_business_group_id
         AND EXISTS (SELECT 1
                       FROM pay_action_information pai,
		            pay_payroll_actions ppa
                      WHERE pai.action_information_category = 'IN_EOY_ORG'
                        AND pai.action_information1 = hou.organization_id
                        AND pai.action_information3 = p_assessment_year
			AND pai.action_context_type ='PA'
               		AND pai.action_context_id = ppa.payroll_action_id
              		AND ppa.report_qualifier ='IN'
			AND ppa.report_type ='IN_EOY_ARCHIVE'
			AND ppa.report_category ='ARCHIVE'
                        AND ROWNUM < 2)
    ORDER BY hou.name;

   CURSOR csr_fetch_employees( p_gre_id  hr_organization_units.organization_id%TYPE)
   IS
      SELECT MAX(pai.action_context_id) action_context_id
           , pai.action_information17 start_date
           , pai.action_information1 employee_number
        FROM pay_action_information      pai
            ,per_assignments_f asg
       WHERE pai.action_information_category = 'IN_EOY_PERSON'
         AND asg.assignment_id               = pai.assignment_id
         AND asg.business_group_id           = p_business_group_id
         AND pai.action_information3         = p_gre_id
         AND pai.action_information2         = p_assessment_year
         AND pai.action_information1     LIKE NVL(p_employee_number,'%')
    GROUP BY pai.action_information1,pai.action_information17
    ORDER BY LENGTH(pai.action_information1), pai.action_information1;
   /* This order by ensures that the employee number is sorted in the ascending
      order based on the order of the characters according to length
   */

      CURSOR csr_emp_source_id(p_start_date DATE
                               ,p_employee_number VARCHAR2
                            ,p_gre_id  hr_organization_units.organization_id%TYPE
                            ,p_action_context_id NUMBER)
    IS
    SELECT pai.source_id            Payroll_run_action_id
          ,pai.action_information18 end_date
      FROM pay_action_information pai
     WHERE pai.action_information_category ='IN_EOY_PERSON'
       AND pai.action_information17 = p_start_date
       AND pai.action_information1  = p_employee_number
       AND pai.action_information2  = p_assessment_year
       AND pai.action_information3  = p_gre_id
       AND pai.action_context_id    = p_action_context_id
       AND EXISTS (SELECT 1
                     FROM pay_assignment_actions paa
                         ,pay_payroll_actions ppa
                    WHERE pai.source_id = paa.assignment_action_id
                      AND paa.payroll_action_id = ppa.payroll_action_id
                      AND ppa.business_group_id = p_business_group_id );


  CURSOR csr_global_value(p_global_name ff_globals_f.global_name%TYPE)
  IS
  SELECT global_value
    FROM ff_globals_f
   WHERE global_name =p_global_name
     AND legislation_code='IN'
     AND g_tax_end_date BETWEEN effective_start_date and effective_end_date;

begin

    g_debug          := hr_utility.debug_enabled;
    l_procedure := g_package ||'load_xml';
    pay_in_utils.set_location(g_debug,'Entering: '||l_procedure,10);


    IF g_debug THEN
        pay_in_utils.trace('**************************************************','********************');
	pay_in_utils.trace('Business Group ID',to_char(p_business_group_id ));
	pay_in_utils.trace('Assessment Year  ',p_assessment_year    );
	pay_in_utils.trace('GRE Organization ',p_gre_organization   );
	pay_in_utils.trace('Employee Type    ',p_employee_type      );
	pay_in_utils.trace('Employee Number  ',p_employee_number    );
	pay_in_utils.trace('**************************************************','********************');
    END IF;

    l_emp_count := 0;
    g_assessment_year := p_assessment_year;
    g_tax_year        := (to_number(SUBSTR(g_assessment_year,1,4)) - 1)||'-'||SUBSTR(g_assessment_year,3,2);
    g_tax_end_date    := fnd_date.string_to_date(('31/03/'|| SUBSTR(g_assessment_year,1,4)),'DD/MM/YYYY');
    g_tax_start_date  := ADD_MONTHS(g_tax_end_date,-12) +1;



    OPEN csr_global_value('IN_SECTION_80CCE_LIMIT');
    FETCH csr_global_value INTO g_80cce_limit;
    CLOSE csr_global_value;


   FOR gre_record IN csr_fetch_gre(p_gre_organization)
    LOOP

        /* Fetch the gre id for each GRE*/
        l_gre_id := gre_record.orgid;
       /* Close and reopen tag for GRE */
       IF l_emp_count <>0 THEN
         l_open_tag := '</GRE>';
         dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

         l_open_tag := '<GRE>';
         dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
         build_gre_xml(l_gre_id);
       END IF;

        /* Fetch the Employees in the GRE and build the XML for each employee */
        FOR emp_record IN csr_fetch_employees(l_gre_id)
        LOOP
            l_action_context_id := emp_record.action_context_id;
            l_start_date        := emp_record.start_date;
            l_emp_number        := emp_record.employee_number;

            OPEN csr_emp_source_id(l_start_date,l_emp_number,l_gre_id,l_action_context_id);
            FETCH csr_emp_source_id INTO l_source_id,l_end_date;
              IF csr_emp_source_id%FOUND THEN
                IF ((l_end_date = g_tax_end_date AND (p_employee_type = 'TRANSFERRED' OR p_employee_type = 'TERMINATED')) OR
                    (l_end_date <> g_tax_end_date  AND p_employee_type ='CURRENT')
                   )THEN
                  NULL;
                ELSE
                    IF l_emp_count = 0 OR l_emp_count > g_chunk_size THEN
                       IF l_emp_count <> 0 THEN
                          /* Close all the open tags */
                          l_open_tag := '</GRE></EOY>';
                          dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
                          /* Close the temporary CLOB opened */
                          dbms_lob.close(g_tmp_clob);
                          /* Store the temporary CLOB in the Global CLOB array */
                          g_clob_cnt := g_clob_cnt + 1;
                          g_clob(g_clob_cnt) := g_tmp_clob;
                          /* Reset the employees count to 1 */
                          l_emp_count := 1;
                       END IF;
                       /* Create a new temporary CLOB for writing XML Data */
                       dbms_lob.createtemporary(g_tmp_clob,FALSE,DBMS_LOB.CALL);
                       dbms_lob.open(g_tmp_clob,dbms_lob.lob_readwrite);
                       /* Open the parent Tags */
                       l_open_tag := '<?xml version="1.0" encoding="UTF-8"?><EOY>';
                       dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
                       /* Write the Common data in the New CLOB created */
                       write_tag('REPORT_DATE',TO_CHAR(TRUNC(SYSDATE),'DD-MM-YYYY'));
                       write_tag('ASSESS_YR',SUBSTR(g_assessment_year,1,5) || SUBSTR(g_assessment_year,8,2));
                       write_tag('FIN_YEAR',g_tax_year);
                       write_tag('REPORT_DATE_TIME',to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS'));
--                       write_tag('DUMMY',pay_us_employee_payslip_web.get_format_value(g_business_group_id,0));
                       /* The following call gets the GRE Related Data to generate the report*/
                       l_open_tag := '<GRE>';
                       dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);

                       build_gre_xml(l_gre_id);
                    END IF;
                    l_emp_count := l_emp_count + 1;
                    l_open_tag := '<EMPLOYEE>';
                    dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
                    /* The following calls builds the XML related to form16, form 16aa and 12ba
                       required to generate the report
                    */

		    pay_in_utils.set_location(g_debug,'INDIA F16: Building XML for Employee',70);
                    build_employee_xml(l_action_context_id,l_source_id,p_rem_pay_period,p_flag);
		    pay_in_utils.set_location(g_debug,'Building XML for Form 16/16AA',80);
                    build_form16_xml(l_action_context_id,l_source_id,p_rem_pay_period,p_flag,l_flag_for_16aa);
                    IF (l_flag_for_16aa  = -1) THEN
                      l_emp_count := l_emp_count - 1;
                    ELSE
		      pay_in_utils.set_location(g_debug,'Building XML for Form 12BA',90);
                      init_form12ba_code;
                      build_form12ba_xml(l_action_context_id,l_source_id);
                      l_open_tag := '</EMPLOYEE>';
                      dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
                    END IF;
                  END IF;
              END IF;
            CLOSE csr_emp_source_id;
          END LOOP;


    END LOOP;
    IF l_emp_count <> 0 THEN
       l_open_tag := '</GRE></EOY>';
       dbms_lob.writeAppend(g_tmp_clob,length(l_open_tag),l_open_tag);
      /* Close the temporary CLOB opened which is not yet closed*/
       dbms_lob.close(g_tmp_clob);
       /* Copy the Temporary CLOB into the Global CLOB Array */
       g_clob_cnt := g_clob_cnt + 1;
       g_clob(g_clob_cnt) := g_tmp_clob;
       p_clob_cnt := g_clob_cnt;
    ELSE
       p_clob_cnt := g_clob_cnt;
    END IF;

    pay_in_utils.set_location(g_debug,'LEAVING: '||l_procedure,100);
END load_xml;

BEGIN

  -- Initialize Globals
  g_clob_cnt       := 0;
  g_fetch_clob_cnt := 0;
--  g_package        := 'pay_in_eoy_reports';
  g_chunk_size     := 10;
  g_salary_record(1).Name  := 'SECTION_17_1';
  g_salary_record(2).Name  := 'SECTION_17_2';
  g_salary_record(3).Name  := 'SECTION_17_3';
  g_salary_record(4).Name  := 'SECTION_17';
  g_salary_record(5).Name  := 'SEC10_TOTAL';
  g_salary_record(6).Name  := 'SEC17_SEC10';
  g_salary_record(7).Name  := 'ENT_ALLOWANCE';
  g_salary_record(8).Name  := 'EMPLOYMENT_TAX';
  g_salary_record(9).Name  := 'SEC16_TOTAL';
  g_salary_record(10).Name := 'HEAD_SALARIES';
  g_salary_record(11).Name := 'OTHER_INCOME';
  g_salary_record(12).Name := 'GROSS_INCOME';
  g_salary_record(13).Name := 'TOTAL_INCOME';
  g_salary_record(14).Name := 'TAX_ON_INCOME';
  g_salary_record(15).Name := 'SURCHARGE';
  g_salary_record(16).Name := 'CESS';
  g_salary_record(17).Name := 'TAX_PAYABLE';
  g_salary_record(18).Name := 'SEC89_RELIEF';
  g_salary_record(19).Name := 'TOTAL_TAX_PAYABLE';
  g_salary_record(20).Name := 'TDS_DEDUCTED_SANS_ER_TAX';
  g_salary_record(21).Name := 'BALANCE_TAX';
  g_salary_record(22).Name := 'EMPLOYER_TAX';
  g_salary_record(23).Name := 'TDS_DEDUCTED';

END PAY_IN_EOY_REPORTS;

/
