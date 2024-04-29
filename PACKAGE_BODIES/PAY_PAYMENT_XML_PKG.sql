--------------------------------------------------------
--  DDL for Package Body PAY_PAYMENT_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYMENT_XML_PKG" AS
/* $Header: pypayxml.pkb 120.19.12010000.1 2008/07/27 23:19:40 appldev ship $ */
--
-- Global Variables
--
TYPE char_tab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
g_xml_cache      char_tab;
g_proc_name      varchar2(240);
g_debug          boolean;
g_leg_code       varchar2(5);
g_person_flex    char_tab;
g_org_flex       char_tab;
g_source_bank    char_tab;
g_per_info       char_tab;
g_opm_info       char_tab;
--
CURSOR c_get_leg_code (p_business_group_id NUMBER)
IS
SELECT legislation_code
FROM   per_business_groups
WHERE  business_group_id = p_business_group_id;
--
-- Internal procedures
--
------------------------------------------------------------------------------
-- Name        : HR_UTILITY_TRACE
-- Description : This procedure prints debug messages.
------------------------------------------------------------------------------
PROCEDURE HR_UTILITY_TRACE(P_TRC_DATA  varchar2)
AS
BEGIN
  IF g_debug THEN
    hr_utility.trace(p_trc_data);
  END IF;
END HR_UTILITY_TRACE;
------------------------------------------------------------------------------
-- Name        : PRINT_CLOB
-- Description : This procedure prints contents of a CLOB object passed as
--               parameter.
------------------------------------------------------------------------------
PROCEDURE PRINT_CLOB(P_CLOB CLOB)
AS
  l_chars    number;
  l_offset   number;
  l_buf      varchar2(255);
BEGIN
  l_chars := 255;
  l_offset := 1;
  LOOP
    dbms_lob.read(p_clob,
                  l_chars,
                  l_offset,
                  l_buf);
    --
    hr_utility_trace(l_buf);
    l_offset := l_offset + 255;
    l_chars:= 255;
  END LOOP;
  --
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    hr_utility_trace ('CLOB contents end.');
--
END PRINT_CLOB;

FUNCTION convert_uppercase(p_input_string varchar2)
RETURN varchar2 IS
--
l_output_string varchar2(2000);

-- converts the french accented characters to American English
-- in uppercase, used for direct deposit mag tape data
cursor c_uppercase(cp_input_string varchar2) is
select
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
replace(
 replace(
 replace(
replace(convert(upper(cp_input_string),'UTF8'),
           utl_raw.cast_to_varchar2(hextoraw('C380')),'A'),
          utl_raw.cast_to_varchar2(hextoraw('C38A')),'E'),
          utl_raw.cast_to_varchar2(hextoraw('C387')),'C'),
          utl_raw.cast_to_varchar2(hextoraw('C389')),'E'),
          utl_raw.cast_to_varchar2(hextoraw('C39C')),'U'),
          utl_raw.cast_to_varchar2(hextoraw('C399')),'U'),
          utl_raw.cast_to_varchar2(hextoraw('C39B')),'U'),
          utl_raw.cast_to_varchar2(hextoraw('C394')),'O'),
          utl_raw.cast_to_varchar2(hextoraw('C38F')),'I'),
          utl_raw.cast_to_varchar2(hextoraw('C38E')),'I'),
          utl_raw.cast_to_varchar2(hextoraw('C388')),'E'),
          utl_raw.cast_to_varchar2(hextoraw('C38B')),'E'),
          utl_raw.cast_to_varchar2(hextoraw('C382')),'A'),
          utl_raw.cast_to_varchar2(hextoraw('C592')),'OE'),
          utl_raw.cast_to_varchar2(hextoraw('C386')),'AE')
from dual;

begin
open c_uppercase(p_input_string);
  fetch c_uppercase into l_output_string;
  if c_uppercase%NOTFOUND then
     l_output_string := p_input_string;
  end if;
  close c_uppercase;

  return l_output_string;

end convert_uppercase;


PROCEDURE LOAD_XML (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS

    CURSOR csr_get_tag_name (p_id_flex_structure_code varchar2) IS
        SELECT TRANSLATE (UPPER(seg.segment_name), ' /','__')
          FROM fnd_id_flex_structures_vl ctx,
               fnd_id_flex_segments_vl seg
         WHERE ctx.id_flex_num = seg.id_flex_num
           AND ctx.id_flex_code = seg.id_flex_code
           AND seg.id_flex_code = 'BANK'
           AND ctx.id_flex_structure_code = p_id_flex_structure_code
           AND seg.application_column_name = UPPER(p_node);

    l_proc_name     varchar2(100);
    l_tag_name      varchar2(500);
    l_struct_code   fnd_id_flex_structures.id_flex_structure_code%type;
     l_data      pay_action_information.action_information1%type;
BEGIN

    IF p_node_type = 'D' THEN
        OPEN csr_get_tag_name (g_leg_code|| '_BANK_DETAILS');
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;

       l_tag_name:=convert_uppercase(l_tag_name);
    END IF;

    IF UPPER(p_node) NOT LIKE '?XML%' AND UPPER(p_node) NOT LIKE 'XAPI%' THEN
        l_tag_name := nvl(l_tag_name, TRANSLATE(p_node,' /', '__'));
        IF p_node_type IN ('CS', 'CE') THEN
            l_tag_name := TRANSLATE(p_node, ' /', '__');
        END IF;
    ELSE
        l_tag_name := p_node;
    END IF;

    IF p_node_type = 'CS' THEN
        pay_core_files.write_to_magtape_lob('<'||l_tag_name||'>');
    ELSIF p_node_type = 'CE' THEN
        pay_core_files.write_to_magtape_lob('</'||l_tag_name||'>');
    ELSIF p_node_type = 'D' THEN
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        pay_core_files.write_to_magtape_lob('<'||l_tag_name||'>'||l_data||'</'||l_tag_name||'>');
    END IF;


END LOAD_XML;

PROCEDURE file_creation_no(p_pact_id in number)
AS
statem               varchar2(2000);
sql_cursor           integer;
l_rows               integer;
file_no              number;
found                boolean:=false;
get_no               varchar2(1):='N';
begin


   pay_core_utils.get_legislation_rule(
        'XML_FILE_CREATION_NO',
        g_leg_code,
        get_no,found);

   if (found=true and get_no='Y')
   then
    statem := 'begin pay_'||g_leg_code||'_rules.get_file_creation_no(';
    statem := statem||':pactid, :file_no); end;';
    sql_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(sql_cursor, statem, dbms_sql.v7);
    dbms_sql.bind_variable(sql_cursor, 'pactid', p_pact_id);
    dbms_sql.bind_variable(sql_cursor, 'file_no', file_no);
    l_rows := dbms_sql.execute (sql_cursor);
    if (l_rows = 1) then
      dbms_sql.variable_value(sql_cursor, 'file_no', file_no);
      dbms_sql.close_cursor(sql_cursor);
      load_xml('D','FILE_CREATION_NO',file_no);
    end if;
   end if;


END file_creation_no;


procedure get_opm_segment_name(p_org_meth_id in number,p_eff_date in date,p_tag_name in out nocopy varchar2)
as

    CURSOR csr_get_tag_name (p_org_meth_id number,p_eff_date date ,p_tag_name varchar2) IS
    select fcu.end_user_column_name
    from pay_org_payment_methods_f opm
        ,fnd_descr_flex_column_usages fcu
    where opm.org_payment_method_id=p_org_meth_id
    and fcu.descriptive_flex_context_code=opm.pmeth_information_category
    and fcu.application_column_name =p_tag_name
    and p_eff_date between opm.effective_start_date and effective_end_date;
begin

    OPEN csr_get_tag_name (p_org_meth_id,p_eff_date,p_tag_name);
    FETCH csr_get_tag_name INTO p_tag_name;
    CLOSE csr_get_tag_name;

end get_opm_segment_name;


procedure get_ppm_segment_name(p_per_meth_id in number,p_eff_date in date,p_tag_name in out nocopy varchar2)
as

    CURSOR csr_get_tag_name (p_per_meth_id number,p_eff_date date ,p_tag_name varchar2) IS
    select fcu.end_user_column_name
    from pay_personal_payment_methods_f ppm
        ,fnd_descr_flex_column_usages fcu
    where ppm.personal_payment_method_id=p_per_meth_id
    and fcu.descriptive_flex_context_code=ppm.ppm_information_category
    and fcu.application_column_name =p_tag_name
    and p_eff_date between ppm.effective_start_date and effective_end_date;
begin

    OPEN csr_get_tag_name (p_per_meth_id,p_eff_date,p_tag_name);
    FETCH csr_get_tag_name INTO p_tag_name;
    CLOSE csr_get_tag_name;

end get_ppm_segment_name;

--
-- External procedures
--
------------------------------------------------------------------------------
-- Name        : gen_header_xml
-- Description : This procedure generates the xml header. There will be 1 per
--               xml file.
------------------------------------------------------------------------------
PROCEDURE gen_header_xml
AS
l_proc_name varchar2(50) := 'pay_payment_xml_pkg.gen_header_xml';
l_payroll_action_id     number;
l_business_group_id     number;
l_effective_date        date;
--
BEGIN
  hr_utility_trace('Entering '||l_proc_name);
  --
  l_payroll_action_id := pay_magtape_generic.get_parameter_value
                          ('TRANSFER_PAYROLL_ACTION_ID');
  if (l_payroll_action_id is null) then
    l_payroll_action_id := pay_magtape_generic.get_parameter_value
                          ('PAYROLL_ACTION_ID');

  end if;
  l_business_group_id := pay_magtape_generic.get_parameter_value
                          ('BG_ID');
  --
  hr_utility_trace ('l_payroll_action_id '||l_payroll_action_id);
  hr_utility_trace ('l_business_group_id '||l_business_group_id);
  --
  load_xml('CS','PAYMENT_HEADER_FOOTER','');
  --
  file_creation_no(l_payroll_action_id);
  hr_utility_trace ('CLOB contents after appending header information');
  --print_clob (pay_mag_tape.g_clob_value);

  hr_utility_trace('Leaving '||l_proc_name);
END gen_header_xml;

PROCEDURE gen_bank_header_xml
AS
CURSOR get_bank_details(p_ext_act_id in NUMBER)
IS
SELECT pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_NAME', pea.territory_code),
	pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_BRANCH', pea.territory_code),
	pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NAME', pea.territory_code),
	pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NUMBER', pea.territory_code),
	pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'TRANSIT_CODE', pea.territory_code),
	pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'SWIFT_CODE', pea.territory_code),
	pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'INTL_BANK_CODE', pea.territory_code)
FROM    pay_external_accounts pea
WHERE   p_ext_act_id = pea.external_account_id;

l_proc_name varchar2(50) := 'pay_payment_xml_pkg.gen_bank_header_xml';
l_bank_name              varchar2(2000);
l_branch_name            varchar2(2000);
l_account_name           varchar2(2000);
l_account_number         varchar2(2000);
l_transit_code           varchar(2000);
l_swift_code             varchar(2000);
l_intl_bank_code         varchar(2000);
l_ext_act_id             number;
--
BEGIN
  hr_utility_trace('Entering '||l_proc_name);

  l_ext_act_id  := pay_magtape_generic.get_parameter_value('EXT_ACT_ID');

  OPEN get_bank_details(l_ext_act_id);
  FETCH get_bank_details INTO
    l_bank_name,l_branch_name,l_account_name,l_account_number,l_transit_code,
    l_swift_code,l_intl_bank_code;
  CLOSE get_bank_details;

  load_xml('CS','GRP_PAYMENT_SOURCE_BANK','');
  load_xml('D','BANK_NAME' , l_bank_name);
  load_xml('D','BRANCH_NAME' , l_branch_name);
  load_xml('D','ACCOUNT_NAME' , l_account_name);
  load_xml('D','ACCOUNT_NUMBER' , l_account_number);
  load_xml('D','TRANSIT_CODE' , l_transit_code);
  load_xml('D','SWIFT_CODE' , l_swift_code);
  load_xml('D','INTL_BANK_CODE' , l_intl_bank_code);

  hr_utility_trace('Leaving '||l_proc_name);

end gen_bank_header_xml;

PROCEDURE gen_bank_footer_xml
AS
 l_proc_name varchar2(50) := 'pay_payment_xml_pkg.gen_bank_footer_xml';
BEGIN
  hr_utility_trace('Entering '||l_proc_name);

  load_xml('CE','GRP_PAYMENT_SOURCE_BANK','');

  hr_utility_trace('Leaving '||l_proc_name);
end gen_bank_footer_xml;

------------------------------------------------------------------------------
-- Name        : gen_footer_xml
-- Description : This procedure generates the xml footer. There will be 1 per
--               xml file.
------------------------------------------------------------------------------
PROCEDURE gen_footer_xml
AS
  l_proc_name varchar2(50) := 'pay_payment_xml_pkg.gen_footer_xml';
BEGIN
  hr_utility_trace('Entering '||l_proc_name);

  load_xml('CE','PAYMENT_HEADER_FOOTER','');

  hr_utility_trace ('CLOB contents after appending footer information');
  --print_clob (pay_mag_tape.g_clob_value);

  hr_utility_trace('Leaving '||l_proc_name);
END gen_footer_xml;
------------------------------------------------------------------------------
-- Name        : gen_payment_details_xml
-- Description : This procedure generates the xml payment details. There will
--               be 1 per payment.
------------------------------------------------------------------------------
PROCEDURE gen_payment_details_xml
AS
CURSOR get_org_bank_details(p_org_payment_method_id VARCHAR2,
                            p_effective_date date) IS
SELECT  segment1       ,segment2       ,segment3
       ,segment4       ,segment5       ,segment6       ,segment7
       ,segment8       ,segment9       ,segment10      ,segment11
       ,segment12      ,segment13      ,segment14      ,segment15
       ,segment16      ,segment17      ,segment18      ,segment19
       ,segment20      ,segment21      ,segment22      ,segment23
       ,segment24      ,segment25      ,segment26      ,segment27
       ,segment28      ,segment29      ,segment30      ,popm.currency_code,
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_NAME', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_BRANCH', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NAME', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NUMBER', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'TRANSIT_CODE', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'SWIFT_CODE', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'INTL_BANK_CODE', pea.territory_code)
FROM pay_org_payment_methods_f popm
,    pay_external_accounts pea
WHERE org_payment_method_id = p_org_payment_method_id
AND   popm.external_account_id = pea.external_account_id
AND   p_effective_date between popm.EFFECTIVE_START_DATE
                           and popm.EFFECTIVE_END_DATE;
--
CURSOR get_person_bank_details(p_per_pay_method   NUMBER
                              ,p_effective_date DATE)
IS
SELECT  segment1       ,segment2       ,segment3
       ,segment4       ,segment5       ,segment6       ,segment7
       ,segment8       ,segment9       ,segment10      ,segment11
       ,segment12      ,segment13      ,segment14      ,segment15
       ,segment16      ,segment17      ,segment18      ,segment19
       ,segment20      ,segment21      ,segment22      ,segment23
       ,segment24      ,segment25      ,segment26      ,segment27
       ,segment28      ,segment29      ,segment30      ,org_payment_method_id,
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_NAME', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_BRANCH', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NAME', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NUMBER', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'TRANSIT_CODE', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'SWIFT_CODE', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'INTL_BANK_CODE', pea.territory_code),
pppm.payee_id,pppm.payee_type
FROM pay_personal_payment_methods_f pppm
,    pay_external_accounts pea
WHERE pppm.personal_payment_method_id = p_per_pay_method
AND   pppm.external_account_id = pea.external_account_id
AND   p_effective_date between pppm.EFFECTIVE_START_DATE
                           and pppm.EFFECTIVE_END_DATE;
--
CURSOR get_orgpayee_bank_details(p_org_pay_method   NUMBER
                              ,p_effective_date DATE)
IS
SELECT  segment1       ,segment2       ,segment3
       ,segment4       ,segment5       ,segment6       ,segment7
       ,segment8       ,segment9       ,segment10      ,segment11
       ,segment12      ,segment13      ,segment14      ,segment15
       ,segment16      ,segment17      ,segment18      ,segment19
       ,segment20      ,segment21      ,segment22      ,segment23
       ,segment24      ,segment25      ,segment26      ,segment27
       ,segment28      ,segment29      ,segment30      ,org_payment_method_id,
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_NAME', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_BRANCH', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NAME', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'BANK_ACCOUNT_NUMBER', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'TRANSIT_CODE', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'SWIFT_CODE', pea.territory_code),
pay_ce_support_pkg.bank_segment_value(pea.external_account_id,'INTL_BANK_CODE', pea.territory_code)
FROM pay_org_payment_methods_f popm
,    pay_external_accounts pea
WHERE org_payment_method_id = p_org_pay_method
AND   popm.external_account_id = pea.external_account_id
AND   p_effective_date between popm.EFFECTIVE_START_DATE
                           and popm.EFFECTIVE_END_DATE;

CURSOR get_third_party_payee_details(p_person_id in number
                           ,p_effective_date in date)
IS
SELECT first_name
,      last_name
,      order_name
,      full_name
,      middle_names
,      title
FROM  per_all_people_f
where  person_id=p_person_id
and   p_effective_date between effective_start_date and effective_end_date;


CURSOR get_employee_details(p_assignment_id in number
                           ,p_effective_date in date)
IS
SELECT ppf.first_name
,      ppf.last_name
,      ppf.order_name
,      ppf.full_name
,      ppf.national_identifier
,      ppf.employee_number
,      pj.name
,      hou.name
,      paf.payroll_id
,      prl.payroll_name
,      ppf.middle_names
,      ppf.title
,      paf.assignment_number
FROM   per_all_assignments_f paf
,      per_all_people_f ppf
,      per_periods_of_service pps
,      per_jobs pj
,      hr_organization_units hou
,      pay_payrolls_f prl
WHERE  paf.person_id = ppf.person_id
and    paf.assignment_id = p_assignment_id
AND    paf.job_id = pj.job_id(+)
and    paf.organization_id = hou.organization_id
and    prl.payroll_id=paf.payroll_id
and    p_effective_date between paf.effective_start_date
                            and paf.effective_end_date
and    p_effective_date between ppf.effective_start_date
                            and ppf.effective_end_date
and    p_effective_date between prl.effective_start_date
                            and prl.effective_end_date
and    pps.person_id = ppf.person_id
and    pps.date_start = (select max(pps1.date_start)
                         from per_periods_of_service pps1
                         where pps1.person_id = paf.person_id
                         and   pps1.date_start <= p_effective_date);
--
CURSOR get_org_payee_details(p_organization_id in number)
IS
SELECT hou.name
from hr_organization_units hou
WHERE hou.organization_id=p_organization_id;

CURSOR get_payroll_details(p_prepru_pact_id in number)
IS
SELECT ppa.start_date
FROM   pay_payroll_actions ppa
,      pay_payrolls_f pp
WHERE  ppa.payroll_action_id = p_prepru_pact_id
and    pp.payroll_id = ppa.payroll_id
and    ppa.effective_date between pp.effective_start_date
                              and pp.effective_end_date;

CURSOR get_action_details(p_asg_act in number)
is
select nvl(paa.serial_number,'-9999'),
       substr(fnd_date.date_to_canonical(ppa.effective_date),1,10),
       substr(nvl(fnd_date.date_to_canonical(ppa.overriding_dd_date),fnd_date.date_to_canonical(ppa.effective_date)),1,10),
       ppa.payroll_action_id
from pay_assignment_actions paa,pay_payroll_actions ppa
where paa.assignment_action_id = p_asg_act
and  paa.payroll_action_id=ppa.payroll_action_id;


CURSOR csr_get_earn(p_bg_id in number,p_leg_code in varchar,p_asg_act in number)
is
select  nvl(pbt.reporting_name,pbt.balance_name),
        pay_balance_pkg.get_value(pba.defined_balance_id,p_asg_act)
from  pay_balance_attributes pba
,     pay_bal_attribute_definitions pbad
,     pay_defined_balances pdb
,     pay_balance_types pbt
where pbad.attribute_name='PAYMENT_EARNINGS'
and   pba.attribute_id=pbad.attribute_id
and   (nvl(pba.legislation_code,'XXX')=p_leg_code
      or
      nvl(pba.business_group_id,-999)=p_bg_id)
and   pba.defined_balance_id=pdb.defined_balance_id
and pbt.balance_type_id = pdb.balance_type_id;

CURSOR csr_get_dedn(p_bg_id in number,p_leg_code in varchar,p_asg_act in number)
is
select  nvl(pbt.reporting_name,pbt.balance_name),
        pay_balance_pkg.get_value(pba.defined_balance_id,p_asg_act)
from  pay_balance_attributes pba
,     pay_bal_attribute_definitions pbad
,     pay_defined_balances pdb
,     pay_balance_types pbt
where pbad.attribute_name='PAYMENT_DEDUCTIONS'
and   pba.attribute_id=pbad.attribute_id
and   (nvl(pba.legislation_code,'XXX')=p_leg_code
      or
      nvl(pba.business_group_id,-999)=p_bg_id)
and   pba.defined_balance_id=pdb.defined_balance_id
and   pbt.balance_type_id = pdb.balance_type_id;

CURSOR  csr_leave_balance (p_assignment_id in number,p_eff_date in date)
is
SELECT  pap.accrual_plan_name
,       pap.accrual_plan_id
FROM    pay_accrual_plans  pap
       ,pay_element_types_f           pet
       ,pay_element_links_f           pel
       ,pay_element_entries_f         pee
WHERE   pet.element_type_id = pap.accrual_plan_element_type_id
AND     pel.element_type_id = pet.element_type_id
AND     pee.element_link_id = pel.element_link_id
AND     p_assignment_id = pee.assignment_id
and     p_eff_date between pet.effective_start_date and pet.effective_end_date
and     p_eff_date between pel.effective_start_date and pel.effective_end_date
and     p_eff_date between pee.effective_start_date and pee.effective_end_date;

CURSOR csr_get_time_period(p_asg_act_id in number)
is
select min(ptp.start_date),max(ptp.end_date), max(paa.assignment_Action_id)
from pay_action_interlocks        pai
     ,pay_assignment_actions       paa
     ,pay_payroll_actions           ppa
     ,per_time_periods              ptp
where p_asg_act_id=pai.locking_action_id
and   pai.locked_action_id=paa.assignment_action_id
and  paa.source_action_id is null
and   ppa.payroll_action_id = paa.payroll_action_id
AND   ppa.action_type IN ('R','Q')
AND   ppa.action_status = 'C'
AND   ppa.time_period_id = ptp.time_period_id;

CURSOR csr_ppm_info (p_ppm_id NUMBER,
                     p_effective_date DATE)
IS
SELECT ppm_information1 ,ppm_information2,ppm_information3,ppm_information4,ppm_information5,
       ppm_information6,ppm_information7,ppm_information8,ppm_information9,ppm_information10,
       ppm_information11,ppm_information12,ppm_information13,ppm_information14,ppm_information15,
       ppm_information16,ppm_information17,ppm_information18,ppm_information19,ppm_information20,
       ppm_information21,ppm_information22,ppm_information23,ppm_information24,ppm_information25,
       ppm_information26,ppm_information27,ppm_information28,ppm_information29,ppm_information30
FROM pay_personal_payment_methods_f
WHERE personal_payment_method_id = p_ppm_id
and p_effective_date between effective_start_date and effective_end_date;

CURSOR csr_opm_info (p_opm_id NUMBER,
                     p_effective_date DATE)
IS
SELECT pmeth_information1 ,pmeth_information2,pmeth_information3,pmeth_information4,pmeth_information5,
       pmeth_information6,pmeth_information7,pmeth_information8,pmeth_information9,pmeth_information10,
       pmeth_information11,pmeth_information12,pmeth_information13,pmeth_information14,pmeth_information15,
       pmeth_information16,pmeth_information17,pmeth_information18,pmeth_information19,pmeth_information20
FROM pay_org_payment_methods_f
WHERE org_payment_method_id = p_opm_id
and p_effective_date between effective_start_date and effective_end_date;
--
l_org_payment_method_id   pay_personal_payment_methods_f.org_payment_method_id%TYPE;
l_first_name             per_all_people_f.first_name%TYPE;
l_last_name              per_all_people_f.last_name%TYPE;
l_order_name             per_all_people_f.order_name%TYPE;
l_full_name              per_all_people_f.full_name%TYPE;
l_national_identifier    per_all_people_f.national_identifier%TYPE;
l_employee_number        per_all_people_f.employee_number%TYPE;
l_middle_names           per_all_people_f.middle_names%TYPE;
l_title                  per_all_people_f.title%TYPE;
l_business_group_id      number;
l_per_pay_method         number;
l_pre_pay_id             number;
l_prepay_asg_act         number;
l_payroll_start_date     date;
l_payroll_end_date       date;
l_cheque_no              varchar2(30);
l_effective_date         date;
l_payroll_name           pay_payrolls_f.payroll_name%TYPE;
l_job                    per_jobs.name%TYPE;
l_employer               hr_organization_units.name%TYPE;
l_payroll_id             number;
l_chq_effective_date     varchar2(30);
l_deposit_date           varchar2(30);
l_assignment_action_id   number;
l_tran_action_id         number;
l_assignment_id          number;
l_det_org_pay_method     number;
l_org_meth               number;
l_payee_meth             number;
l_payee_org_id           number;
l_pre_pru_pact_id        number;
l_xml                    CLOB;
l_custom_ee_xml          CLOB;
l_chars                  number;
l_offset                 number;
l_deposit_amount         varchar2(30);
l_amount_in_words        varchar2(2000);
l_amount_in_words_line1  varchar2(2000);
l_amount_in_words_line2  varchar2(2000);
l_buf                    varchar2(2000);
l_param_count            number;
l_proc_name              varchar2(50) := 'pay_payment_xml_pkg.gen_payment_details_xml';
l_leg_code               varchar2(10);
l_bank_name              varchar2(2000);
l_branch_name            varchar2(2000);
l_account_name           varchar2(2000);
l_account_number         varchar2(2000);
l_transit_code           varchar(2000);
l_swift_code             varchar(2000);
l_intl_bank_code         varchar(2000);
l_dbank_name             varchar2(2000);
l_dbranch_name           varchar2(2000);
l_daccount_name          varchar2(2000);
l_daccount_number        varchar2(2000);
l_dtransit_code          varchar(2000);
l_dswift_code             varchar(2000);
l_dintl_bank_code         varchar(2000);
l_bal                    varchar2(50);
l_value                  number;
l_accrual_plan_id        NUMBER;
l_start_date             DATE;
l_end_date               DATE;
l_accrual_end_date       DATE;
l_accrual                NUMBER;
l_annual_leave_balance   NUMBER;
l_period_end_date        DATE;
l_period_start_date      DATE;
l_leave_taken            NUMBER;
l_accrual_plan_name      pay_accrual_plans.accrual_plan_name%TYPE;
l_run_aa_id              number;
l_pactid                 NUMBER;
decimal_amount           varchar2(2000);
found                    boolean:=false;
addtl_data               varchar2(1):='N';
is_decimal               number;
dest_bank                   number;
l_asg_num		 varchar2(50);
l_payee_id               number;
l_payee_type              varchar2(50);
currency_description     varchar2(240);
currency_precision       number;
CURR_NO_OF_DECIMALS      number;
--
BEGIN
  hr_utility_trace('Entering '||l_proc_name);
  l_chars := 2000;
  l_offset := 1;
  --
  l_tran_action_id := pay_magtape_generic.get_parameter_value
                             ('TRANSFER_ACT_ID');
  l_assignment_id        := pay_magtape_generic.get_parameter_value
                             ('ASG_ID');
  l_effective_date       := pay_magtape_generic.get_parameter_value
                             ('PRE_PAY_EFF_DATE');
  l_deposit_amount       := pay_magtape_generic.get_parameter_value
                             ('PAYMENT_AMOUNT');
  l_business_group_id    := pay_magtape_generic.get_parameter_value
                             ('DET_BG_ID');
  l_per_pay_method       := pay_magtape_generic.get_parameter_value
                             ('PERSONAL_PAY_METH');
  l_pre_pay_id           := pay_magtape_generic.get_parameter_value
                             ('PRE_PAY_ID');
  l_prepay_asg_act       := pay_magtape_generic.get_parameter_value
                             ('PRE_PAY_ASG_ACT');
  l_org_meth              := pay_magtape_generic.get_parameter_value
                             ('ORG_PAY_METHOD');
  hr_utility.trace('l_org_meth: '||to_char(l_org_meth));
  l_det_org_pay_method   := pay_magtape_generic.get_parameter_value
                             ('DET_ORG_PAY_METH');
  l_payee_meth            := pay_magtape_generic.get_parameter_value
                             ('PAYEE_PAY_METH_ID');
  l_payee_org_id            := pay_magtape_generic.get_parameter_value
                             ('ORG_ID');
  l_pre_pru_pact_id :=pay_magtape_generic.get_parameter_value
                             ('PRE_PRU_PAY_PACT_ID');

  --
  -- Get source bank details
  --
  IF g_source_bank.count <> 0 THEN
    g_source_bank.delete;
  END IF;
  --
  IF g_leg_code IS NULL THEN
    OPEN c_get_leg_code(l_business_group_id);
    FETCH c_get_leg_code INTO l_leg_code;
      g_leg_code := l_leg_code;
    CLOSE c_get_leg_code;
  END IF;
  --
  hr_utility_trace ('Legislation Code '||
                     g_leg_code);
  --
  OPEN get_org_bank_details(l_det_org_pay_method,l_effective_date);
  FETCH get_org_bank_details INTO
    g_source_bank(1),g_source_bank(2),g_source_bank(3),g_source_bank(4),
    g_source_bank(5),g_source_bank(6),g_source_bank(7),g_source_bank(8),
    g_source_bank(9),g_source_bank(10),g_source_bank(11),g_source_bank(12),
    g_source_bank(13),g_source_bank(14),g_source_bank(15),g_source_bank(16),
    g_source_bank(17),g_source_bank(18),g_source_bank(19),g_source_bank(20),
    g_source_bank(21),g_source_bank(22),g_source_bank(23),g_source_bank(24),
    g_source_bank(25),g_source_bank(26),g_source_bank(27),g_source_bank(28),
    g_source_bank(29),g_source_bank(30), g_currency_code,
    l_bank_name,l_branch_name,l_account_name,l_account_number,l_transit_code,
    l_swift_code,l_intl_bank_code;
  CLOSE get_org_bank_details;

  --
  -- Convert l_deposit_amount in correct number of decimals
  --
  select instr(l_deposit_amount,'.'), precision
    into is_decimal, currency_precision
    from fnd_currencies fc,
            fnd_currencies_tl fctl
      where fc.currency_code=g_currency_code
      and   fc.currency_code=fctl.currency_code
      and   fctl.language=userenv('lang');
  --
  if (is_decimal<>0)
  then
     select length(substr(l_deposit_amount, is_decimal+1, length(l_deposit_amount)))
       into curr_no_of_decimals
       from dual;

     while(curr_no_of_decimals <> currency_precision) loop
       select rpad(l_deposit_amount, length(l_deposit_amount)+ 1, '0')
         into l_deposit_amount
         from dual;
       curr_no_of_decimals := curr_no_of_decimals+1;
     end loop;
  end if;
  --
  --
  if l_deposit_amount > 5373484 or l_deposit_amount <1  then
     select
            instr(l_deposit_amount,'.'),
            substr(l_deposit_amount,-1*precision,precision)
           ,nvl(fctl.description,fc.currency_code)
       into is_decimal,decimal_amount,currency_description
       from fnd_currencies fc,
            fnd_currencies_tl fctl
      where fc.currency_code=g_currency_code
      and   fc.currency_code=fctl.currency_code
      and   fctl.language=userenv('lang');
      l_amount_in_words := null;
  else
     select to_char(to_Date (substr(to_char(trunc(l_deposit_amount)), 1), 'j'), 'jsp'),
            instr(l_deposit_amount,'.'),
            substr(l_deposit_amount,-1*precision,precision)
           ,nvl(fctl.description,fc.currency_code)
       into l_amount_in_words,is_decimal,decimal_amount,currency_description
       from fnd_currencies fc ,
            fnd_currencies_tl fctl
      where fc.currency_code=g_currency_code
      and   fc.currency_code=fctl.currency_code
      and   fctl.language=userenv('lang');
  end if;

  if is_decimal<>0
  then
    l_amount_in_words:= l_amount_in_words || ' ' ||currency_description||' and '||decimal_amount;
  else
    l_amount_in_words:= l_amount_in_words || ' ' ||currency_description;
  end if;
  /* need to wrap over 2 lines */
  l_amount_in_words_line1:= substr(l_amount_in_words,1,59);
  l_amount_in_words_line2:=substr(l_amount_in_words,59);
  --
  -- Clear the details of previous assignmentId
  --
  IF g_person_flex.count <> 0 THEN
    g_person_flex.delete;
  END IF;
  --
  -- Get Personal Bank Details
  --
  --or org payee details
  --
if l_payee_meth is null
then
 if (l_per_pay_method is not null) then
  OPEN get_person_bank_details(l_per_pay_method,l_effective_date);
  FETCH get_person_bank_details INTO
    g_person_flex(1),g_person_flex(2),g_person_flex(3),g_person_flex(4),
    g_person_flex(5),g_person_flex(6),g_person_flex(7),g_person_flex(8),
    g_person_flex(9),g_person_flex(10),g_person_flex(11),g_person_flex(12),
    g_person_flex(13),g_person_flex(14),g_person_flex(15),g_person_flex(16),
    g_person_flex(17),g_person_flex(18),g_person_flex(19),g_person_flex(20),
    g_person_flex(21),g_person_flex(22),g_person_flex(23),g_person_flex(24),
    g_person_flex(25),g_person_flex(26),g_person_flex(27),g_person_flex(28),
    g_person_flex(29),g_person_flex(30),l_org_payment_method_id,
    l_dbank_name,l_dbranch_name,l_daccount_name,l_daccount_number,l_dtransit_code,
    l_dswift_code,l_dintl_bank_code,l_payee_id,l_payee_type;
  CLOSE get_person_bank_details;
 end if;
else
  OPEN get_orgpayee_bank_details(l_payee_meth,l_effective_date);
  FETCH get_orgpayee_bank_details INTO
    g_person_flex(1),g_person_flex(2),g_person_flex(3),g_person_flex(4),
    g_person_flex(5),g_person_flex(6),g_person_flex(7),g_person_flex(8),
    g_person_flex(9),g_person_flex(10),g_person_flex(11),g_person_flex(12),
    g_person_flex(13),g_person_flex(14),g_person_flex(15),g_person_flex(16),
    g_person_flex(17),g_person_flex(18),g_person_flex(19),g_person_flex(20),
    g_person_flex(21),g_person_flex(22),g_person_flex(23),g_person_flex(24),
    g_person_flex(25),g_person_flex(26),g_person_flex(27),g_person_flex(28),
    g_person_flex(29),g_person_flex(30),l_org_payment_method_id,
    l_dbank_name,l_dbranch_name,l_daccount_name,l_daccount_number,l_dtransit_code,
    l_dswift_code,l_dintl_bank_code;
  CLOSE get_orgpayee_bank_details;
end if;
  --
  -- Get Employee Details
  -- or org details
  --
if l_payee_meth is null
then
  OPEN get_employee_details(l_assignment_id,l_effective_date);
  FETCH get_employee_details INTO
    l_first_name, l_last_name, l_order_name,
    l_full_name  ,    l_national_identifier,
    l_employee_number,l_job,l_employer,l_payroll_id,l_payroll_name,
    l_middle_names,l_title,l_asg_num;
  CLOSE get_employee_details;
else
  OPEN get_org_payee_details(l_payee_org_id);
  FETCH get_org_payee_details INTO
    l_full_name  ;
  CLOSE get_org_payee_details;

end if;

  -- if third party payment , get third party payee name

 if (l_payee_id is not null ) then

 if l_payee_type='P' then
  OPEN get_third_party_payee_details(l_payee_id,l_effective_date);
  FETCH get_third_party_payee_details INTO
    l_first_name, l_last_name, l_order_name,
    l_full_name  ,l_middle_names,l_title;
  CLOSE get_third_party_payee_details;
 elsif l_payee_type='O' then
   OPEN get_org_payee_details(l_payee_id);
  FETCH get_org_payee_details INTO
    l_full_name  ;
  CLOSE get_org_payee_details;
 end if;



 end if;

  -- get chq details
  OPEN get_action_details(l_tran_action_id);
  FETCH get_action_details INTO
    l_cheque_no,l_chq_effective_date,l_deposit_date,l_pactid;
  CLOSE get_action_details;
  --
  -- Get Payroll Details
---`for pru aswell
  --
  OPEN get_payroll_details(l_pre_pru_pact_id);
  FETCH get_payroll_details INTO l_payroll_start_date;
  CLOSE get_payroll_details;
  --
  -- Build XML
  --
  load_xml('CS','PAYMENT_DETAILS','');
  --
  load_xml('CS','SOURCE_BANK','');
  --
  load_xml('D','BANK_NAME' , l_bank_name);
  load_xml('D','BRANCH_NAME' , l_branch_name);
  load_xml('D','ACCOUNT_NAME' , l_account_name);
  load_xml('D','ACCOUNT_NUMBER' , l_account_number);
  load_xml('D','TRANSIT_CODE' , l_transit_code);
  load_xml('D','SWIFT_CODE' , l_swift_code);
  load_xml('D','INTL_BANK_CODE' , l_intl_bank_code);
  load_xml('CS','SEGMENT_DATA','');
  FOR cntr IN 1..30 LOOP
    IF g_source_bank(cntr) IS NOT NULL THEN
      load_xml('D','Segment'||cntr ,g_source_bank(cntr));
    END IF;
  END LOOP;
  load_xml('CE','SEGMENT_DATA','');
  --
  load_xml('CE','SOURCE_BANK','');
  --
  if g_person_flex.count <> 0 then
    load_xml('CS','DESTINATION_BANK','');
    --
    load_xml('D','BANK_NAME' , l_dbank_name);
    load_xml('D','BRANCH_NAME' , l_dbranch_name);
    load_xml('D','ACCOUNT_NAME' , l_daccount_name);
    load_xml('D','ACCOUNT_NUMBER' , l_daccount_number);
    load_xml('D','TRANSIT_CODE' , l_dtransit_code);
    load_xml('D','SWIFT_CODE' , l_dswift_code);
    load_xml('D','INTL_BANK_CODE' , l_dintl_bank_code);
    load_xml('CS','SEGMENT_DATA','');
    FOR cntr IN 1..30 LOOP
      IF g_person_flex(cntr) IS NOT NULL THEN
        load_xml('D','Segment'||cntr ,g_person_flex(cntr));
      END IF;
    END LOOP;
    load_xml('CE','SEGMENT_DATA','');
    --
    load_xml('CE','DESTINATION_BANK','');
  else
    load_xml('CS','DESTINATION_BANK','');
    load_xml ('D','DEST_BANK_TAG' ,'No personal bank details for this payment type');
    load_xml('CE','DESTINATION_BANK','');
  end if;
  load_xml('D','PAYROLL_NAME',l_payroll_name);
  load_xml('D','EMPLOYEE_NUMBER' ,l_employee_number);
  load_xml('D','FIRST_NAME',l_first_name);
  load_xml('D','LAST_NAME',l_last_name);
  load_xml('D','NAME',l_full_name);
  load_xml('D','MIDDLE_NAMES',l_middle_names);
  load_xml('D','TITLE',l_title);
  load_xml('D','ASSIGNMENT_NUMBER',l_asg_num);
  load_xml('D','CURRENCY',g_currency_code);
  load_xml('D','PAYMENT_AMOUNT',l_deposit_amount);
  load_xml('D','AMOUNT_CURRENCY','*** '||l_deposit_amount||'  '||g_currency_code||' ***');
  load_xml('D','PAYMENT_AMOUNT_WORDS',l_amount_in_words);
  load_xml('D','PAYMENT_AMOUNT_WORDS_1',l_amount_in_words_line1);
  if (l_amount_in_words_line2 is not null) then
  load_xml('D','PAYMENT_AMOUNT_WORDS_2',l_amount_in_words_line2);
  end if;
  if (l_cheque_no <> '-9999')
  then
  load_xml('D','CHEQUE NUMBER',l_cheque_no);
  end if;
  load_xml('D','EFFECTIVE_DATE',l_chq_effective_date);
  load_xml('D','DEPOSIT_DATE',l_deposit_date);

  load_xml('D','JOB',l_job);
  load_xml('D','EMPLOYER',l_employer);


 if (l_per_pay_method is not null) then
  OPEN csr_ppm_info(l_per_pay_method,l_effective_date);
  FETCH csr_ppm_info INTO g_per_info(1),g_per_info(2),g_per_info(3),g_per_info(4),g_per_info(5),
                     g_per_info(6),g_per_info(7),g_per_info(8),g_per_info(9),g_per_info(10),
                     g_per_info(11),g_per_info(12),g_per_info(13),g_per_info(14),g_per_info(15),
                     g_per_info(16),g_per_info(17),g_per_info(18),g_per_info(19),g_per_info(20),
                     g_per_info(21),g_per_info(22),g_per_info(23),g_per_info(24),g_per_info(25),
                     g_per_info(26),g_per_info(27),g_per_info(28),g_per_info(29),g_per_info(30);
  CLOSE csr_ppm_info;

  load_xml('CS','PERSONAL_PAYMENT_METHOD_INFO','');
  FOR cntr IN 1..30 LOOP
    IF g_per_info(cntr) IS NOT NULL THEN
      get_ppm_segment_name(l_per_pay_method,fnd_date.canonical_to_date(l_chq_effective_date),g_per_info(cntr));
      load_xml('D','INFORMATION'||cntr ,g_per_info(cntr));
    END IF;
  END LOOP;
  load_xml('CE','PERSONAL_PAYMENT_METHOD_INFO','');
 end if;


  OPEN csr_opm_info(l_det_org_pay_method,l_effective_date);
  FETCH csr_opm_info INTO g_opm_info(1),g_opm_info(2),g_opm_info(3),g_opm_info(4),g_opm_info(5),
                     g_opm_info(6),g_opm_info(7),g_opm_info(8),g_opm_info(9),g_opm_info(10),
                     g_opm_info(11),g_opm_info(12),g_opm_info(13),g_opm_info(14),g_opm_info(15),
                     g_opm_info(16),g_opm_info(17),g_opm_info(18),g_opm_info(19),g_opm_info(20);
  CLOSE csr_opm_info;

  load_xml('CS','ORG_PAYMENT_METHOD_INFO','');
  FOR cntr IN 1..20 LOOP
    IF g_opm_info(cntr) IS NOT NULL THEN
      get_opm_segment_name(l_det_org_pay_method,fnd_date.canonical_to_date(l_chq_effective_date),g_opm_info(cntr));
      load_xml('D','INFORMATION'||cntr ,g_opm_info(cntr));
    END IF;
  END LOOP;
  load_xml('CE','ORG_PAYMENT_METHOD_INFO','');




  pay_core_utils.get_legislation_rule(
        'ADDITIONAL_CHQ_DATA',
        g_leg_code,
        addtl_data,found);

 If (found=true and upper(addtl_data)='Y')
 then

    OPEN csr_get_time_period(l_prepay_asg_act);

    FETCH csr_get_time_period into
            l_period_start_date
            ,l_period_end_date
            ,l_run_aa_id;
    close csr_get_time_period;

    open csr_get_earn(l_business_group_id,g_leg_code,l_run_aa_id);
    LOOP
      FETCH csr_get_earn INTO l_bal,l_value;
      EXIT WHEN csr_get_earn%NOTFOUND;

        load_xml('CS','EARNINGS','');
        load_xml('D','EARN_ELEMENT',l_bal);
        load_xml('D','EARN_VALUE' ,l_value);
        load_xml('CE','EARNINGS','');

    END LOOP;
    CLOSE csr_get_earn;

    open csr_get_dedn(l_business_group_id,g_leg_code,l_run_aa_id);
    LOOP
      FETCH csr_get_dedn INTO l_bal,l_value;
      EXIT WHEN csr_get_dedn%NOTFOUND;

        load_xml('CS','DEDUCTIONS','');
        load_xml('D','DEDN_ELEMENT',l_bal);
        load_xml('D','DEDN_VALUE' ,l_value);
        load_xml('CE','DEDUCTIONS','');

    END LOOP;
    CLOSE csr_get_dedn;

   -- calc absences


    OPEN  csr_leave_balance(l_assignment_id,l_effective_date);
    LOOP
      FETCH csr_leave_balance INTO
            l_accrual_plan_name
            ,l_accrual_plan_id;

      EXIT WHEN csr_leave_balance%NOTFOUND;
      IF csr_leave_balance%FOUND THEN
        -- Call to get annual leave balance
        per_accrual_calc_functions.get_net_accrual
          (p_assignment_id     => l_assignment_id          --  number  in
          ,p_plan_id           => l_accrual_plan_id        --  number  in
          ,p_payroll_id        => l_payroll_id             --  number  in
          ,p_business_group_id => l_business_group_id      --  number  in
          ,p_calculation_date  => l_effective_date         --  date    in
          ,p_start_date        => l_start_date             --  date    out
          ,p_end_date          => l_end_date               --  date    out
          ,p_accrual_end_date  => l_accrual_end_date       --  date    out
          ,p_accrual           => l_accrual                --  number  out
          ,p_net_entitlement   => l_annual_leave_balance   --  number  out
          );

        IF l_annual_leave_balance IS NULL THEN
          l_annual_leave_balance := 0;
        END IF;

        l_leave_taken := per_accrual_calc_functions.get_absence
                         (l_assignment_id
                         ,l_accrual_plan_id
                         ,l_period_end_date
                         ,l_period_start_date);

        load_xml('CS','ABSENCE_DETAILS','');
        load_xml('D','ACCRUAL_PLAN',l_accrual_plan_name);
        load_xml('D','ABSENCE_DAYS',l_leave_taken);
        load_xml('D','ANNUAL_LEAVE_BALANCE' ,l_annual_leave_balance);
        load_xml('CE','ABSENCE_DETAILS','');
      END IF;
    END LOOP;
    CLOSE csr_leave_balance;

  end if;


  --
  --
  -- Employee Information - Legislation Specific
  --
  pay_mag_tape.call_leg_xml_proc;
  load_xml('CE','PAYMENT_DETAILS','');
  --
  --
  hr_utility_trace ('CLOB contents for assignment action '||
                     l_assignment_action_id);
  --
  --print_clob (pay_mag_tape.g_clob_value);
  --
  hr_utility_trace('Leaving '||l_proc_name);
END gen_payment_details_xml;
------------------------------------------------------------------------------
END PAY_PAYMENT_XML_PKG;

/
