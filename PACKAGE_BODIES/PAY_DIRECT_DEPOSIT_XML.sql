--------------------------------------------------------
--  DDL for Package Body PAY_DIRECT_DEPOSIT_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DIRECT_DEPOSIT_XML" AS
/* $Header: payddxml.pkb 120.10 2006/01/15 22:47 sdahiya noship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_direct_deposit_xml
    Package File Name   : payddxml.pkb

    Description : Used for Direct Deposit Extract

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sodhingr      20-Jul-2005 115.0           Initial Version
    sodhingr      22-Aug-2005 115.1           changed the PL/sql table name
                                              from g_payslip_xml to g_xml_table
    vmehta        05-Oct-2005 115.3           Delete the parameter table
                                              pay_payroll_xml_extract_pkg.
                                              g_custom_params before setting.
    mmukherj      21-Oct-2005 115.4           Created another TAG in the
                                              employee details level which
                                              prints the deposit amount
                                              multiplied by 100. This is needed
                                              because the output format for some
                                              legislations needs the deposit
                                              amount printed that way. The name
                                              of the new Tag is:
                                              DEPOSIT_AMOUNT100.
    vmehta       24-Oct-2005 115.5            Removed the new tag
                                              DEPOSIT_AMOUNT100. Changed
                                              AMOUNT to varchar. This is stored
                                              in the '9999999999D99' format
                                              to address the trailing zero issue
    vmehta       20-Nov-2005 115.6            Modified gen_employer_level_xml
                                              to fetch information about
                                              Paymeth Developer DF and add to
                                              XML
    vmehta       21-Nov-2005 115.7            Add Paymeth Developer DF related
                                              segments only if not null.
    sdahiya      25-Nov-2005 115.8    4761066 Added FM to number format mask
                                              to eliminate leading spaces.
    sdahiya      30-Nov-2005 115.9    4773967 CLOB to BLOB migration.
    sdahiya      01-Dec-2005 115.10           Modified PRINT_BLOB to use
                                              pay_ac_utility.print_lob.
    sdahiya      01-Dec-2005 115.11           Used core procedure
                                              pay_core_files.write_to_magtape_lob
                                              to manipulate core magtape BLOB.
    sdahiya      22-Dec-2005 115.12           Removed XML header information.
                                              PYUGEN will generate XML headers.
    ========================================================================*/

--
-- Global Variables
--
    TYPE char_tab IS TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;
    g_xml_cache      char_tab;
    g_proc_name      varchar2(240);
    g_debug          boolean;
    g_leg_code       varchar2(5);
    g_person_flex    char_tab;
    g_currency_code  varchar2(10);
    g_org_flex       char_tab;
    g_pmeth_flex     char_tab;


    CURSOR c_get_leg_code (p_business_group_id NUMBER) IS
        SELECT legislation_code
        FROM per_business_groups
        WHERE business_group_id = p_business_group_id;


  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This procedure prints debug messages.
  *****************************************************************************/
PROCEDURE HR_UTILITY_TRACE
(
    P_TRC_DATA  varchar2
) AS
BEGIN
    IF g_debug THEN
        hr_utility.trace(p_trc_data);
    END IF;
END HR_UTILITY_TRACE;

  /****************************************************************************
    Name        : PRINT_BLOB
    Description : This procedure prints contents of BLOB passed as parameter.
  *****************************************************************************/

PROCEDURE PRINT_BLOB(p_blob BLOB) IS
BEGIN
    IF g_debug THEN
        pay_ac_utility.print_lob(p_blob);
    END IF;
END PRINT_BLOB;


  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed BLOB parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

PROCEDURE WRITE_TO_MAGTAPE_LOB(p_blob BLOB) IS
BEGIN
    IF  dbms_lob.getLength (p_blob) IS NOT NULL THEN
        pay_core_files.write_to_magtape_lob (p_blob);
    END IF;
END WRITE_TO_MAGTAPE_LOB;


  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed varchar2 parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

PROCEDURE WRITE_TO_MAGTAPE_LOB(p_data varchar2) IS
BEGIN
        pay_core_files.write_to_magtape_lob (p_data);
END WRITE_TO_MAGTAPE_LOB;


   /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE GENERATE_XML AS

    CURSOR get_person_bank_details(p_per_pay_method   NUMBER,
                                   p_effective_date DATE) IS
       SELECT  segment1       ,segment2       ,segment3
              ,segment4       ,segment5       ,segment6       ,segment7
              ,segment8       ,segment9       ,segment10      ,segment11
              ,segment12      ,segment13       ,segment14      ,segment15
              ,segment16      ,segment17       ,segment18      ,segment19
              ,segment20      ,segment21       ,segment22      ,segment23
              ,segment24      ,segment25       ,segment26      ,segment27
              ,segment28      ,segment29       ,segment30      ,org_payment_method_id
      FROM pay_personal_payment_methods_f pppm,
           pay_external_accounts pea
      WHERE --pppm.assignment_id = p_assignment_id
      pppm.personal_payment_method_id = p_per_pay_method
      AND pppm.external_account_id = pea.external_account_id
      AND p_effective_date between pppm.EFFECTIVE_START_DATE
                         and pppm.EFFECTIVE_END_DATE;


    CURSOR get_employee_details(p_assignment_id in number
                                  ,p_effective_date in date) IS
         SELECT ppf.first_name, ppf.last_name, ppf.middle_names, ppf.order_name,
                ppf.full_name,  ppf.national_identifier,
                ppf.employee_number
         FROM per_assignments_f paf,
              per_all_people_f ppf,
              per_periods_of_service pps
         WHERE paf.person_id = ppf.person_id
         and paf.assignment_id = p_assignment_id
         and p_effective_date between paf.effective_start_date
                                  and paf.effective_end_date
         and p_effective_date between ppf.effective_start_date
                                  and ppf.effective_end_date
         and pps.person_id = ppf.person_id
         and pps.date_start = (select max(pps1.date_start)
                                 from per_periods_of_service pps1
                                where pps1.person_id = paf.person_id
                                  and pps1.date_start <= p_effective_date);


    CURSOR get_payroll_details(p_prepay_asg_act in number) IS
         SELECT ppa.start_date,ppa.effective_date,
                pp.payroll_name
         FROM pay_assignment_actions paa
             ,pay_payroll_actions ppa
             ,pay_payrolls_f pp
         WHERE paa.assignment_action_id = p_prepay_asg_act
         and ppa.payroll_action_id = paa.payroll_action_id
         and pp.payroll_id = ppa.payroll_id
         and ppa.effective_date between pp.effective_start_date
                                and pp.effective_end_date;


    l_org_payment_method_id   pay_personal_payment_methods_f.org_payment_method_id%TYPE;
    lv_first_name             per_all_people_f.first_name%TYPE;
    lv_last_name              per_all_people_f.last_name%TYPE;
    lv_middle_names           per_all_people_f.middle_names%TYPE;
    lv_order_name             per_all_people_f.order_name%TYPE;
    lv_full_name              per_all_people_f.full_name%TYPE;
    lv_national_identifier    per_all_people_f.national_identifier%TYPE;
    lv_employee_number        per_all_people_f.employee_number%TYPE;
    ln_business_group_id      number;
    ln_per_pay_method         number;
    ln_pre_pay_id             number;
    ln_prepay_asg_act         number;
    ld_payroll_start_date     date;
    ld_payroll_end_date       date;
    lv_payroll_name           pay_payrolls_f.payroll_name%TYPE;

    l_proc_name                   varchar2(100);
    ld_effective_date             date;
    ln_assignment_action_id       number;
    ln_assignment_id              number;
    l_xml                         BLOB;
    l_custom_ee_xml               BLOB;
    ln_chars                      number;
    ln_offset                     number;
    lv_deposit_amount             varchar2(15);
    lv_buf                        varchar2(2000);
    ln_param_count                number;
    lr_xml                        RAW (32767);
    ln_amt                        number;


BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML';
    hr_utility_trace ('Entering '||l_proc_name);

    ln_chars := 2000;
    ln_offset := 1;

    ln_assignment_action_id :=
              pay_magtape_generic.get_parameter_value('TRANSFER_ACT_ID');

    ln_assignment_id        :=
              pay_magtape_generic.get_parameter_value('TRANSFER_ASSIGNMENT_ID');

    ld_effective_date       :=
             fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value(                                                    'TRANSFER_EFFECTIVE_DATE'));

    -- Bug 4761066
    lv_deposit_amount       :=
             TO_CHAR(TO_NUMBER(pay_magtape_generic.get_parameter_value(
                     'DEPOSIT_AMOUNT')), 'FM9999999999D99');

    ln_business_group_id    :=
             pay_magtape_generic.get_parameter_value(
                                                 'TRANSFER_BUSINESS_GROUP_ID');
    ln_per_pay_method       :=
             pay_magtape_generic.get_parameter_value(
                                                 'TRANSFER_PERSONAL_PAY_METH');

    ln_pre_pay_id           :=
             pay_magtape_generic.get_parameter_value('TRANSFER_PRE_PAY_ID');

    ln_prepay_asg_act       :=
             pay_magtape_generic.get_parameter_value('TRANSFER_PREPAY_ASG_ACT');


    /*Clear the details of previous assignmentId */
     IF g_person_flex.count <> 0 THEN
       g_person_flex.delete;
     END IF;

/*     IF pay_payroll_xml_extract_pkg.g_leg_code IS NULL THEN
        OPEN get_leg_code(ln_assignment_action_id);
            FETCH get_leg_code INTO pay_payroll_xml_extract_pkg.g_leg_code;
        CLOSE get_leg_code;
     END IF;
*/

     /* Get Personal Bank Details */
     IF pay_payroll_xml_extract_pkg.g_leg_code IS NULL THEN
        OPEN c_get_leg_code(ln_business_group_id);
            FETCH c_get_leg_code INTO pay_payroll_xml_extract_pkg.g_leg_code;
        CLOSE c_get_leg_code;
     END IF;

     OPEN get_person_bank_details(ln_per_pay_method,ld_effective_date);
     FETCH get_person_bank_details INTO
     g_person_flex(1),g_person_flex(2),g_person_flex(3),
     g_person_flex(4),g_person_flex(5),g_person_flex(6),
     g_person_flex(7),g_person_flex(8),g_person_flex(9),
     g_person_flex(10),g_person_flex(11),g_person_flex(12),
     g_person_flex(13),g_person_flex(14),
     g_person_flex(15),g_person_flex(16),g_person_flex(17),
     g_person_flex(18),g_person_flex(19),g_person_flex(20),
     g_person_flex(21),g_person_flex(22),g_person_flex(23),
     g_person_flex(24),g_person_flex(25),g_person_flex(26),
     g_person_flex(27),g_person_flex(28),g_person_flex(29),
     g_person_flex(30),l_org_payment_method_id;


     CLOSE get_person_bank_details;

     /*Get Employee Details */

     OPEN get_employee_details(ln_assignment_id,ld_effective_date);
     FETCH get_employee_details INTO
         lv_first_name ,    lv_last_name,      lv_middle_names,   lv_order_name,
         lv_full_name  ,    lv_national_identifier,
         lv_employee_number;
     CLOSE get_employee_details;

    /* Get Payroll Details */
    OPEN get_payroll_details(ln_prepay_asg_act);
    FETCH get_payroll_details INTO
          ld_payroll_start_date, ld_payroll_end_date,
          lv_payroll_name;

    CLOSE get_payroll_details;

    /* Build XML */
    pay_payroll_xml_extract_pkg.load_xml('CS','DEPOSIT_DETAILS','');

    FOR cntr IN 1..30 LOOP
       IF g_person_flex(cntr) IS NOT NULL THEN
          pay_payroll_xml_extract_pkg.load_xml('D','Segment'||cntr,g_person_flex(cntr));
       END IF;
    END LOOP;


    pay_payroll_xml_extract_pkg.load_xml('D','PAYROLL_START_DATE',
                      fnd_date.date_to_canonical(ld_payroll_start_date));

    pay_payroll_xml_extract_pkg.load_xml('D','PAYROLL_END_DATE',
                      fnd_date.date_to_canonical(ld_payroll_end_date));

    pay_payroll_xml_extract_pkg.load_xml('D','PAYROLL_NAME',lv_payroll_name);

    pay_payroll_xml_extract_pkg.load_xml('D','EMPLOYEE_NUMBER',
                     lv_employee_number);

    pay_payroll_xml_extract_pkg.load_xml('D','FIRST_NAME',lv_first_name);

    pay_payroll_xml_extract_pkg.load_xml('D','LAST_NAME',lv_last_name);

    pay_payroll_xml_extract_pkg.load_xml('D','MIDDLE_NAMES',lv_middle_names);

    pay_payroll_xml_extract_pkg.load_xml('D','FULL_NAME',lv_full_name);

    pay_payroll_xml_extract_pkg.load_xml('D','CURRENCY',g_currency_code);

    pay_payroll_xml_extract_pkg.load_xml('D','DEPOSIT_AMOUNT',
                    lv_deposit_amount);


    pay_payroll_xml_extract_pkg.g_custom_params.DELETE;
    ln_param_count := pay_payroll_xml_extract_pkg.g_custom_params.COUNT;

    pay_payroll_xml_extract_pkg.g_custom_params(ln_param_count).parameter_name
                   := 'p_xml_level';

    pay_payroll_xml_extract_pkg.g_custom_params(ln_param_count).parameter_value
                   := 'EE';

    /*Employee Information -Legislation Specific*/
     EXECUTE IMMEDIATE 'BEGIN  PAY_'||pay_payroll_xml_extract_pkg.g_leg_code||
                    '_RULES.add_custom_xml(:1,:2,:3); END;'
     USING   IN ln_assignment_action_id,'','DEPOSIT_XML';

     pay_payroll_xml_extract_pkg.load_xml('CE','DEPOSIT_DETAILS','');

    IF pay_payroll_xml_extract_pkg.g_xml_table.count() <> 0 THEN
        dbms_lob.createTemporary(l_xml, true, dbms_lob.session);
        FOR cntr IN
        pay_payroll_xml_extract_pkg.g_xml_table.first()..pay_payroll_xml_extract_pkg.g_xml_table.last() LOOP
            lr_xml := utl_raw.cast_to_raw(
                                 pay_payroll_xml_extract_pkg.g_xml_table(cntr));
            ln_amt := utl_raw.length(lr_xml);

            dbms_lob.writeAppend(l_xml,
                                 ln_amt,
                                 lr_xml);

            hr_utility_trace (pay_payroll_xml_extract_pkg.g_xml_table(cntr));
        END LOOP;
        pay_payroll_xml_extract_pkg.g_xml_table.delete();

     END IF;

     write_to_magtape_lob (l_xml);
     dbms_lob.freeTemporary(l_xml);

     hr_utility_trace ('BLOB contents for assignment action '||
                                                    ln_assignment_action_id);
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END GENERATE_XML;


/****************************************************************************
    Name        : GEN_XML_HEADER
    Description : This procedure generates XML header information and appends to
                  pay_mag_tape.g_blob_value.
*****************************************************************************/
PROCEDURE GET_HEADERS AS
    l_proc_name varchar2(100);
    lv_buf      varchar2(2000);
BEGIN
    l_proc_name := g_proc_name || 'GEN_XML_HEADER';
    --hr_utility.trace_on(null,'dd');
    hr_utility_trace ('Entering '||l_proc_name);

    lv_buf := pay_magtape_generic.get_parameter_value('ROOT_XML_TAG');

    hr_utility_trace ('Header = '||lv_buf);

    write_to_magtape_lob (lv_buf);

    hr_utility_trace ('BLOB contents after appending header information');
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END GET_HEADERS;



/****************************************************************************
    Name        : GEN_EMPLOYER_LEVEL_XML
    Description : This procedure generates XML header information and appends to
                  pay_mag_tape.g_blob_value.
*****************************************************************************/
PROCEDURE get_deposit_header AS
    l_proc_name              varchar2(100);
    lv_buf                   varchar2(2000);
    ln_org_pay_method        number;
    ln_tax_unit_id           number;
    ln_payroll_action_id     number;
    ln_business_group_id     number;
    ld_effective_date        date;
    lv_dd_date               varchar2(19);
    l_xml                    BLOB;
    l_custom_er_xml          BLOB;
    lv_leg_code              varchar2(10);
    ln_param_count           number;
    lv_pmeth_cat             varchar2(100);
    lr_xml                   RAW (32767);
    ln_amt                   number;


    CURSOR get_org_bank_details(p_org_payment_method_id VARCHAR2,
                                p_effective_date date) IS
       SELECT  segment1       ,segment2       ,segment3
              ,segment4       ,segment5       ,segment6       ,segment7
              ,segment8       ,segment9       ,segment10      ,segment11
              ,segment12      ,segment13      ,segment14      ,segment15
              ,segment16      ,segment17      ,segment18      ,segment19
              ,segment20      ,segment21      ,segment22      ,segment23
              ,segment24      ,segment25      ,segment26      ,segment27
              ,segment28      ,segment29      ,segment30    ,popm.currency_code
              ,pmeth_information_category
              ,pmeth_information1   ,pmeth_information2  ,pmeth_information3
              ,pmeth_information4   ,pmeth_information5  ,pmeth_information6
              ,pmeth_information7   ,pmeth_information8  ,pmeth_information9
              ,pmeth_information10  ,pmeth_information11 ,pmeth_information12
              ,pmeth_information13  ,pmeth_information14 ,pmeth_information15
              ,pmeth_information16  ,pmeth_information17 ,pmeth_information18
              ,pmeth_information19  ,pmeth_information20
      FROM pay_org_payment_methods_f popm,
           pay_external_accounts pea
      WHERE org_payment_method_id = p_org_payment_method_id
      AND popm.external_account_id = pea.external_account_id
      AND p_effective_date between popm.EFFECTIVE_START_DATE
                        and popm.EFFECTIVE_END_DATE;



BEGIN
    l_proc_name := g_proc_name || 'GEN_EMPLOYER_LEVEL_XML';
    hr_utility_trace ('Entering '||l_proc_name);
    lv_pmeth_cat       := NULL;

    ln_org_pay_method  :=
           pay_magtape_generic.get_parameter_value('TRANSFER_ORG_PAY_METHOD');

    ld_effective_date  :=
           fnd_date.canonical_to_date(pay_magtape_generic.get_parameter_value(
                                                    'TRANSFER_EFFECTIVE_DATE'));

    lv_dd_date         :=
           pay_magtape_generic.get_parameter_value('TRANSFER_DD_DATE');

    ln_payroll_action_id :=
          pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');

    ln_business_group_id :=
          pay_magtape_generic.get_parameter_value('TRANSFER_BUSINESS_GROUP_ID');

    hr_utility_trace ('ln_org_pay_method '||ln_org_pay_method);
    hr_utility_trace ('ld_effective_date '||ld_effective_date);
    hr_utility_trace ('Direct Deposit Date '||lv_dd_date);
    hr_utility_trace ('ln_payroll_action_id '||ln_payroll_action_id);
    hr_utility_trace ('ln_business_group_id '||ln_business_group_id);


    pay_payroll_xml_extract_pkg.load_xml('CS','DEPOSIT_HEADER','');
       /*Clear the details of previous assignmentId */
    IF g_org_flex.count <> 0 THEN
       g_org_flex.delete;
    END IF;

    IF g_pmeth_flex.count <> 0 THEN
       g_pmeth_flex.delete;
    END IF;

     IF pay_payroll_xml_extract_pkg.g_leg_code IS NULL THEN
        OPEN c_get_leg_code(ln_business_group_id);
        FETCH c_get_leg_code INTO lv_leg_code;
        hr_utility_trace ('Legislation Code '||lv_leg_code);

        pay_payroll_xml_extract_pkg.g_leg_code :=lv_leg_code;
        CLOSE c_get_leg_code;
     END IF;

     hr_utility_trace ('Legislation Code '||pay_payroll_xml_extract_pkg.g_leg_code);

     OPEN get_org_bank_details(ln_org_pay_method,ld_effective_date);
     FETCH get_org_bank_details INTO
     g_org_flex(1),g_org_flex(2),g_org_flex(3),
     g_org_flex(4),g_org_flex(5),g_org_flex(6),
     g_org_flex(7),g_org_flex(8),g_org_flex(9),
     g_org_flex(10),g_org_flex(11),g_org_flex(12),
     g_org_flex(13),g_org_flex(14),
     g_org_flex(15),g_org_flex(16),g_org_flex(17),
     g_org_flex(18),g_org_flex(19),g_org_flex(20),
     g_org_flex(21),g_org_flex(22),g_org_flex(23),
     g_org_flex(24),g_org_flex(25),g_org_flex(26),
     g_org_flex(27),g_org_flex(28),g_org_flex(29),
     g_org_flex(30),g_currency_code, lv_pmeth_cat,
     g_pmeth_flex(1), g_pmeth_flex(2), g_pmeth_flex(3),
     g_pmeth_flex(4), g_pmeth_flex(5), g_pmeth_flex(6),
     g_pmeth_flex(7), g_pmeth_flex(8), g_pmeth_flex(9),
     g_pmeth_flex(10), g_pmeth_flex(11), g_pmeth_flex(12),
     g_pmeth_flex(13), g_pmeth_flex(14), g_pmeth_flex(15),
     g_pmeth_flex(16), g_pmeth_flex(17), g_pmeth_flex(18),
     g_pmeth_flex(19), g_pmeth_flex(20);

     CLOSE get_org_bank_details;

     FOR cntr IN 1..30 LOOP
       IF g_org_flex(cntr) IS NOT NULL THEN
          pay_payroll_xml_extract_pkg.load_xml('D','Segment'||cntr,g_org_flex(cntr));
       END IF;
     END LOOP;
     IF (lv_pmeth_cat IS NOT NULL)
     THEN
        FOR cntr IN 1..20 LOOP
           IF g_pmeth_flex(cntr) IS NOT NULL THEN
              pay_payroll_xml_extract_pkg.load_xml('D', 'Paymeth Developer DF',
                lv_pmeth_cat, 'PMETH_INFORMATION'||cntr,g_pmeth_flex(cntr));
           END IF;
        END LOOP;
     END IF;
     pay_payroll_xml_extract_pkg.load_xml('D','DEPOSIT_DATE',lv_dd_date);
     pay_payroll_xml_extract_pkg.load_xml('D','CURRENCY',g_currency_code);

   IF pay_payroll_xml_extract_pkg.g_xml_table.count() <> 0 THEN
        dbms_lob.createTemporary(l_xml, true, dbms_lob.session);
        FOR cntr IN
        pay_payroll_xml_extract_pkg.g_xml_table.first()..pay_payroll_xml_extract_pkg.g_xml_table.last() LOOP
            lr_xml := utl_raw.cast_to_raw(
                                pay_payroll_xml_extract_pkg.g_xml_table(cntr));
            ln_amt := utl_raw.length(lr_xml);

            dbms_lob.writeAppend(l_xml,
                                 ln_amt,
                                 lr_xml);

            hr_utility_trace (pay_payroll_xml_extract_pkg.g_xml_table(cntr));
        END LOOP;
        pay_payroll_xml_extract_pkg.g_xml_table.delete();

     END IF;
     write_to_magtape_lob (l_xml);
     dbms_lob.freeTemporary(l_xml);

    pay_payroll_xml_extract_pkg.g_custom_params.DELETE;
    ln_param_count := pay_payroll_xml_extract_pkg.g_custom_params.COUNT;
    pay_payroll_xml_extract_pkg.g_custom_params(ln_param_count).parameter_name := 'p_xml_level';
    pay_payroll_xml_extract_pkg.g_custom_params(ln_param_count).parameter_value := 'ER';

    /*Employee Information -Legislation Specific*/
     EXECUTE IMMEDIATE 'BEGIN  PAY_'||pay_payroll_xml_extract_pkg.g_leg_code||
                    '_RULES.add_custom_xml(:1,:2,:3); END;'
     USING   IN ln_payroll_action_id,'','DEPOSIT_XML';



    hr_utility_trace ('BLOB contents after appending header information');
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END get_deposit_header;

  /****************************************************************************
    Name        : GEN_XML_FOOTER
    Description : This procedure generates XML information for GRE and the final
                  closing tag. Final result is appended to
                  pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE get_deposit_footer AS
    lv_buf              varchar2(2000);
    l_proc_name         varchar2(200);
BEGIN
    l_proc_name := g_proc_name || 'GET_EMPLOYER_FOOTER';
    hr_utility_trace ('Entering '||l_proc_name);

    lv_buf := '</DEPOSIT_HEADER>';

    write_to_magtape_lob (lv_buf);

    hr_utility_trace ('BLOB contents after appending footer information');
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END get_deposit_footer;

PROCEDURE GET_FOOTERS AS
   lv_buf              varchar2(2000);
   l_proc_name         varchar2(200);
BEGIN
    l_proc_name := g_proc_name || 'GEN_XML_FOOTER';
    hr_utility_trace ('Entering '||l_proc_name);

    lv_buf := '</DIRECT_DEPOSIT>' ;

    write_to_magtape_lob (lv_buf);

    hr_utility_trace ('BLOB contents after appending footer information');
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END GET_FOOTERS;

BEGIN
  g_proc_name := 'pay_direct_deposit_xml.';
  g_debug := hr_utility.debug_enabled;
END pay_direct_deposit_xml;

/
