--------------------------------------------------------
--  DDL for Package Body PAY_MX_DIM_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_DIM_MAG" AS
/* $Header: paymxdimmag.pkb 120.4.12010000.9 2010/01/20 18:39:12 jdevasah ship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_mx_dim_mag
    Package File Name   : paymxdimmag.pkb

    Description : Used for DIM Interface Extract

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ----------------------------------
    vpandya       28-Aug-2006 115.0           Initial Version
    vpandya       07-Sep-2006 115.1           Changed generate_xml:
                                              Print 0,1 or 2 for Union Worker
                                              flag. Removed EMPLOYEE tag.
    vpandya       15-Sep-2006 115.2           Changed generate_xml:
                                              Added Subsidy Proportion Used.
                                              Removed upper from names as it
                                              should be printed as it is.
    vpandya       26-Sep-2006 115.3   5564163 Changed generate_xml:
                                              Using RATE_1991_IND and
                                              RATE_FISCAL_YEAR_IND from view.
                                              Removed logic to get these
                                              indicator from this package.
    nragavar      31-Oct_2006 115.5   5581574 modified to return total earnings
                                              subject/exempt properly.
    vmehta        13-feb-2007 115.6           modified range_cursor to use
                                              to_number around serial_number.
    nragavar      11-Sep-2007 115.7   5916021 Modified to display field 114
                                              correctly.
    nragavar      12-Sep-2007 115.8           Missed out changes fro ISR Calculated
    nragavar      14-Sep-2007 115.9   6415826 modified to display EMPR_STOCK_OPTION_PLAN
                                              correctly
    sjawid        31-Jan-2009 115.11  7702851 modified to display EMPR_STOCK_OPTION_PLAN
                                              correctly
    jdevasah      20-Jan-2010 115.18  9273001 Included the new fields introduced in
                                              2009 update.
    ==========================================================================*/

--
-- Global Variables
--


  dim_xml_tbl          xml_tbl;

  g_proc_name          VARCHAR2(240);
  g_debug              BOOLEAN;
  g_document_type      VARCHAR2(50);
  gd_effective_date    DATE;
  gn_business_group_id NUMBER;
  gn_legal_er_id       NUMBER;

  gn_success_fail      NUMBER;
  gn_sep_bal           NUMBER;
  gn_ass_bal           NUMBER;
  gn_emp_bal           NUMBER;

  EOL                  VARCHAR2(5);

  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This procedure prints debug messages.
  *****************************************************************************/
  PROCEDURE hr_utility_trace ( P_TRC_DATA  VARCHAR2) AS
  BEGIN
    IF g_debug THEN
        hr_utility.trace(p_trc_data);
    END IF;
  END hr_utility_trace;


  /****************************************************************************
    Name        : PRINT_BLOB
    Description : This procedure prints contents of BLOB passed as parameter.
  *****************************************************************************/

  PROCEDURE print_blob(p_blob BLOB) IS
  BEGIN
    IF g_debug THEN
        pay_ac_utility.print_lob(p_blob);
    END IF;
  END print_blob;


  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed BLOB parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE write_to_magtape_lob(p_blob BLOB) IS
  BEGIN
    IF  dbms_lob.getLength (p_blob) IS NOT NULL THEN
        pay_core_files.write_to_magtape_lob (p_blob);
    END IF;
  END write_to_magtape_lob;


  /****************************************************************************
    Name        : WRITE_TO_MAGTAPE_LOB
    Description : This procedure appends passed varchar2 parameter to
                  pay_mag_tape.g_blob_value
  *****************************************************************************/

  PROCEDURE write_to_magtape_lob(p_data VARCHAR2) IS
  BEGIN
        pay_core_files.write_to_magtape_lob (p_data);
  END write_to_magtape_lob;


  /****************************************************************************
    Name        : POPULATE_XML_TABLE
    Description : This procedure creates a table that uses for XML creation.
  *****************************************************************************/
  PROCEDURE populate_xml_table( name     IN  VARCHAR2
                               ,value    IN  VARCHAR2
                               ,type     IN  VARCHAR2 ) IS
    ln_index  NUMBER;

  BEGIN

    IF type = 'SEP_BAL' THEN

       IF value < 0 THEN
          gn_success_fail := -1;
       ELSIF value > 0 THEN
          gn_sep_bal := 1;
       END IF;

    ELSIF type = 'ASS_BAL' THEN

       IF value < 0 THEN
          gn_success_fail := -1;
       ELSIF value > 0 THEN
          gn_ass_bal := 1;
       END IF;

    ELSIF type = 'EMP_BAL' THEN

       IF value < 0 THEN
          gn_success_fail := -1;
       ELSIF value > 0 THEN
          gn_emp_bal := 1;
       END IF;

    ELSIF type = 'SUMM_BAL' THEN

       IF value < 0 THEN
          gn_success_fail := -1;
       END IF;

    END IF;

    ln_index := dim_xml_tbl.COUNT;

    dim_xml_tbl(ln_index).name  := name;
    dim_xml_tbl(ln_index).value := value;

  END populate_xml_table;

  /****************************************************************************
    Name        : LOAD_XML_INTERNAL
    Description : This procedure loads the global XML cache.
    Parameters  : P_NODE_TYPE       This parameter can take one of these
                                    values: -
                                    1. CS - This signifies that string contained
                                            in P_NODE parameter is start of
                                            container node. P_DATA parameter is
                                            ignored in this mode.
                                    2. CE - This signifies that string
                                            contained in P_NODE parameter is
                                            end of container node. P_DATA
                                            parameter is ignored in this mode.
                                    3. D  - This signifies that string
                                            contained in P_NODE parameter is
                                            data node and P_DATA carries actual
                                            data to be contained by tag
                                            specified by P_NODE parameter.

                  P_NODE            Name of XML tag, or, application column
                                    name of flex segment.

                  P_DATA            Data to be contained by tag specified by
                                    P_NODE parameter. P_DATA is not used unless
                                    P_NODE_TYPE = D.
  *****************************************************************************/
  PROCEDURE load_xml_internal ( p_node_type         VARCHAR2
                               ,p_node              VARCHAR2
                               ,p_data              VARCHAR2) IS
    l_proc_name VARCHAR2(100);
    l_data      VARCHAR2(240);
    l_xml       VARCHAR2(240);

  BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML_INTERNAL';
    hr_utility_trace ('Entering '||l_proc_name);

    IF p_node_type = 'CS' THEN

        l_xml := '<'||p_node||'>'||EOL;

    ELSIF p_node_type = 'CE' THEN

        l_xml := '</'||p_node||'>'||EOL;

    ELSIF p_node_type = 'D' THEN

        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        l_xml  := '<'||p_node||'>'||l_data||'</'||p_node||'>'||EOL;

    END IF;

    write_to_magtape_lob (l_xml);

    hr_utility_trace ('Leaving '||l_proc_name);

  END load_xml_internal;

  /****************************************************************************
    Name        : GET_PAYROLL_ACTION_INFO
    Description : This procedure fetches payroll action level information.
  *****************************************************************************/
  PROCEDURE get_payroll_action_info(p_payroll_action_id     IN        NUMBER
                                   ,p_end_date             OUT NOCOPY DATE
                                   ,p_business_group_id    OUT NOCOPY NUMBER
                                   ,p_legal_employer_id    OUT NOCOPY NUMBER
                                   )
  IS
    CURSOR c_payroll_Action_info (cp_payroll_action_id IN NUMBER) IS
      SELECT effective_date,
             business_group_id,
             pay_mx_utility.get_legi_param_val( 'LEGAL_EMPLOYER'
                ,legislative_parameters)
        FROM pay_payroll_actions
       WHERE payroll_action_id = cp_payroll_action_id;

    ld_end_date          DATE;
    ln_business_group_id NUMBER;
    ln_asg_set_id        NUMBER;
    ln_legal_er_id       NUMBER;
    lv_procedure_name    VARCHAR2(100);

    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;

   BEGIN

       lv_procedure_name  := g_proc_name ||'.get_payroll_action_info';

       hr_utility.set_location(lv_procedure_name, 10);

       ln_step := 1;

       OPEN  c_payroll_action_info(p_payroll_action_id);
       FETCH c_payroll_action_info INTO ld_end_date
                                       ,ln_business_group_id
                                       ,ln_legal_er_id;
       CLOSE c_payroll_action_info;

       ln_step := 2;
       hr_utility.set_location(lv_procedure_name, 30);

       p_end_date          := TRUNC(ld_end_date,'Y');
       p_business_group_id := ln_business_group_id;
       p_legal_employer_id := ln_legal_er_id;

       hr_utility.set_location(lv_procedure_name, 50);

  EXCEPTION
    WHEN OTHERS THEN
      lv_error_message := 'Error at step ' || ln_step || ' IN ' ||
                           lv_procedure_name;

      hr_utility.trace(lv_error_message || '-' || SQLERRM);

      lv_error_message :=
         pay_emp_action_arch.set_error_message(lv_error_message);

      hr_utility.set_message(801,'HR_ELE_ENTRY_FORMULA_HINT');
      hr_utility.set_message_token('FORMULA_TEXT', lv_error_message);
      hr_utility.raise_error;

  END get_payroll_action_info;

  /****************************************************************************
    Name        : RANGE_CURSOR
    Description : This procedure prepares range of persons to be processed.
  *****************************************************************************/
  PROCEDURE range_cursor ( P_PAYROLL_ACTION_ID            NUMBER
                          ,P_SQLSTR            OUT NOCOPY VARCHAR2 ) AS

    l_proc_name             varchar2(100);

  BEGIN
    l_proc_name := g_proc_name || 'RANGE_CURSOR';

    hr_utility_trace ('Entering '||l_proc_name);

    hr_utility_trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);

    get_payroll_action_info (p_payroll_action_id
                            ,gd_effective_date
                            ,gn_business_group_id
                            ,gn_legal_er_id);

    hr_utility_trace ('gd_effective_date = '|| gd_effective_date);
    hr_utility_trace ('gn_business_group_id = '|| gn_business_group_id);
    hr_utility_trace ('gn_legal_er_id = '|| gn_legal_er_id);

    p_sqlstr := '
      SELECT DISTINCT to_number(paa_arch.serial_number)
        FROM pay_assignment_actions paa_arch
            ,pay_payroll_actions ppa_arch
       WHERE ppa_arch.business_group_id = '|| gn_business_group_id ||'
         AND ppa_arch.report_type = ''MX_YREND_ARCHIVE''
         AND ppa_arch.report_qualifier = ''MX''
         AND ppa_arch.report_category = ''ARCHIVE''
         AND pay_mx_utility.get_parameter(''TRANSFER_LEGAL_EMPLOYER'',
                     ppa_arch.legislative_parameters) = '||gn_legal_er_id||'
         AND TRUNC(ppa_arch.effective_date,''Y'') =
                 fnd_date.canonical_to_date('''||
                    fnd_date.date_to_canonical(gd_effective_date)||''')
         AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
         AND paa_arch.action_status = ''C''
         AND :p_payroll_action_id = '||p_payroll_action_id||'
         ORDER BY 1';

    hr_utility_trace ('Range cursor query : ' || p_sqlstr);
    hr_utility_trace ('Leaving '||l_proc_name);

  END range_cursor;


  /****************************************************************************
    Name        : ACTION_CREATION
    Description : This procedure creates assignment actions for DIM magnetic
                  tape process.
  *****************************************************************************/
  PROCEDURE action_creation ( p_payroll_action_id NUMBER,
                              p_start_person_id   NUMBER,
                              p_end_person_id     NUMBER,
                              p_chunk             NUMBER) AS

    CURSOR c_arch_asg ( cp_business_group_id  NUMBER
                       ,cp_legal_er_id        NUMBER
                       ,cp_effective_date     DATE
                       ,cp_start_person_id    NUMBER
                       ,cp_end_person_id      NUMBER) IS
        SELECT paa_arch.assignment_action_id
              ,paa_arch.assignment_id
              ,paa_arch.serial_number person_id
              ,ppa_arch.payroll_action_id
          FROM pay_assignment_actions paa_arch,
               pay_payroll_actions ppa_arch
       WHERE ppa_arch.business_group_id =  cp_business_group_id
         AND ppa_arch.report_type       = 'MX_YREND_ARCHIVE'
         AND ppa_arch.report_qualifier  = 'MX'
         AND ppa_arch.report_category   = 'ARCHIVE'
         AND pay_mx_utility.get_parameter('TRANSFER_LEGAL_EMPLOYER',
                     ppa_arch.legislative_parameters) = cp_legal_er_id
         AND TRUNC(ppa_arch.effective_date,'Y') = TRUNC(cp_effective_date,'Y')
         AND paa_arch.payroll_action_id    = ppa_arch.payroll_action_id
         AND paa_arch.action_status        = 'C'
         AND paa_arch.serial_number BETWEEN cp_start_person_id
                                        AND cp_end_person_id
       ORDER BY paa_arch.serial_number,
                paa_arch.assignment_id;

    CURSOR c_arch_asg_range  ( cp_business_group_id  NUMBER
                              ,cp_legal_er_id        NUMBER
                              ,cp_effective_date     DATE
                              ,cp_chunk              NUMBER
                              ,cp_payroll_action_id  NUMBER) IS
        SELECT paa_arch.assignment_action_id
              ,paa_arch.assignment_id
              ,paa_arch.serial_number person_id
              ,ppa_arch.payroll_action_id
          FROM pay_assignment_actions paa_arch,
               pay_payroll_actions ppa_arch,
               pay_population_ranges ppr
       WHERE ppa_arch.business_group_id =  cp_business_group_id
         AND ppa_arch.report_type       = 'MX_YREND_ARCHIVE'
         AND ppa_arch.report_qualifier  = 'MX'
         AND ppa_arch.report_category   = 'ARCHIVE'
         AND pay_mx_utility.get_parameter('TRANSFER_LEGAL_EMPLOYER',
                     ppa_arch.legislative_parameters) = cp_legal_er_id
         AND TRUNC(ppa_arch.effective_date,'Y') = TRUNC(cp_effective_date,'Y')
         AND paa_arch.payroll_action_id    = ppa_arch.payroll_action_id
         AND paa_arch.action_status        = 'C'
         AND paa_arch.serial_number = ppr.person_id
         AND ppr.chunk_number       = cp_chunk
         AND ppr.payroll_action_id  = cp_payroll_action_id
       ORDER BY paa_arch.serial_number,
                paa_arch.assignment_id;

    l_proc_name                 varchar2(100);
    lv_future_magtape_exists    varchar2(1);
    lb_range_person_on          boolean;
    ln_person_id                number;
    ln_prev_arch_pact_id        number;
    ln_arch_pact_id             number;
    ln_prev_person_id           number;
    ln_prev_asg_id              number;
    ln_mag_asg_act_id           number;
    ln_assignment_id            number;
    ln_arch_act_id              number;
    ln_asg_count                number;
  BEGIN
    l_proc_name := g_proc_name || 'ACTION_CREATION';
    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('Parameters ....');
    hr_utility_trace ('P_PAYROLL_ACTION_ID = '|| P_PAYROLL_ACTION_ID);
    hr_utility_trace ('P_START_PERSON_ID = '|| P_START_PERSON_ID);
    hr_utility_trace ('P_END_PERSON_ID = '|| P_END_PERSON_ID);
    hr_utility_trace ('P_CHUNK = '|| P_CHUNK);

    ln_prev_person_id := -1;
    ln_prev_asg_id := -1;
    ln_prev_arch_pact_id := -1;

    IF gn_legal_er_id IS NULL THEN

       get_payroll_action_info (p_payroll_action_id
                               ,gd_effective_date
                               ,gn_business_group_id
                               ,gn_legal_er_id);

    END IF;

    ln_asg_count := 0;

    lb_range_person_on := pay_ac_utility.range_person_on(
                               p_report_type      => 'DIM_MAG'
                              ,p_report_format    => 'DIM_MAG'
                              ,p_report_qualifier => 'DIM_MAG'
                              ,p_report_category  => 'RT');

    IF lb_range_person_on THEN

       hr_utility_trace ('Person ranges are ON');

       OPEN c_arch_asg_range( gn_business_group_id
                             ,gn_legal_er_id
                             ,gd_effective_date
                             ,p_chunk
                             ,p_payroll_action_id);

    ELSE

       hr_utility_trace ('Person ranges are OFF');

       OPEN c_arch_asg( gn_business_group_id
                       ,gn_legal_er_id
                       ,gd_effective_date
                       ,p_start_person_id
                       ,p_end_person_id);

    END IF;

    LOOP
        IF lb_range_person_on THEN
            FETCH c_arch_asg_range INTO ln_arch_act_id,
                                        ln_assignment_id,
                                        ln_person_id,
                                        ln_arch_pact_id;
            EXIT WHEN c_arch_asg_range%NOTFOUND;
        ELSE
            FETCH c_arch_asg INTO ln_arch_act_id,
                                  ln_assignment_id,
                                  ln_person_id,
                                  ln_arch_pact_id;
            EXIT WHEN c_arch_asg%NOTFOUND;
        END IF;

        ln_asg_count := ln_asg_count + 1;

        hr_utility_trace ('-------------');
        hr_utility_trace('Current archiver asg action = '||ln_arch_act_id);
        hr_utility_trace('Current person = '||ln_person_id);
        hr_utility_trace('Previous person = '||ln_prev_person_id);

        IF (ln_person_id <> ln_prev_person_id) THEN

           SELECT pay_assignment_actions_s.nextval
             INTO ln_mag_asg_act_id
             FROM dual;

           hr_utility_trace('Creating magtape assignment action '||
                                              ln_mag_asg_act_id);

           hr_nonrun_asact.insact(ln_mag_asg_act_id
                                 ,ln_assignment_id
                                 ,p_payroll_action_id
                                 ,p_chunk
                                 ,gn_legal_er_id
                                 ,null
                                 ,'U'
                                 ,null);

           -- insert an interlock to this action
           hr_utility.trace('Locking Action in IF = ' || ln_mag_asg_act_id);
           hr_utility.trace('Locked Action in IF = '  || ln_arch_act_id);

           hr_nonrun_asact.insint(ln_mag_asg_act_id,
                                  ln_arch_act_id);

        ELSE

           -- insert an interlock to this action
           hr_utility.trace('Locking Action in ELSE = ' || ln_mag_asg_act_id);
           hr_utility.trace('Locked Action in ELSE = '  || ln_arch_act_id);

           hr_nonrun_asact.insint(ln_mag_asg_act_id,
                                  ln_arch_act_id);

        END IF;

        ln_prev_person_id := ln_person_id;

    END LOOP;

    hr_utility_trace(ln_asg_count || ' archiver actions processed in chunk '||
                                                                      p_chunk);

    IF lb_range_person_on THEN
       CLOSE c_arch_asg_range;
    ELSE
       CLOSE c_arch_asg;
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);

  END action_creation;

  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value.
  *****************************************************************************/
  PROCEDURE generate_xml AS

    CURSOR c_dim_rec (cp_assignment_action_id number,p_format varchar2) IS
      SELECT dim.person_id PERSON_ID
            ,to_char(fnd_date.canonical_to_date(start_month),'mm') START_MONTH
            ,to_char(fnd_date.canonical_to_date(end_month),'mm')   END_MONTH
            ,replace(RFC_ID,'-','')  RFC_ID
            ,CURP
            ,ltrim(rtrim(PATERNAL_LAST_NAME)) PATERNAL_LAST_NAME
            ,ltrim(rtrim(MATERNAL_LAST_NAME)) MATERNAL_LAST_NAME
            ,ltrim(rtrim(NAMES)) NAMES
            ,decode(ECONOMIC_ZONE, 'A', '01',
                                   'B', '02', 'C', '03', '0') ECONOMIC_ZONE
            ,decode(ANNUAL_TAX_CALC_FLAG, 'Y', '1',
                                          'N', '2' , '2') ANNUAL_TAX_CALC_FLAG
	    ,1 RATE_FISCAL_YEAR_IND /*7702851*/
            ,2 RATE_1991_IND
            ,to_char(FND_NUMBER.canonical_to_number(nvl(TAX_SUBSIDY_PCT,'0')), p_format)
                                                            TAX_SUBSIDY_PCT
            ,decode(UNION_WORKER_FLAG, 'Y', 1, 'N', 2, 0) UNION_WORKER_FLAG
            ,'0' ASSIMILATED_TO_SALARY_IND
            ,STATE_ID
            ,replace(OTHER_ER_RFC1,'-','')  OTHER_ER_RFC1
            ,replace(OTHER_ER_RFC2,'-','')  OTHER_ER_RFC2
            ,replace(OTHER_ER_RFC3,'-','')  OTHER_ER_RFC3
            ,replace(OTHER_ER_RFC4,'-','')  OTHER_ER_RFC4
            ,replace(OTHER_ER_RFC5,'-','')  OTHER_ER_RFC5
            ,replace(OTHER_ER_RFC6,'-','')  OTHER_ER_RFC6
            ,replace(OTHER_ER_RFC7,'-','')  OTHER_ER_RFC7
            ,replace(OTHER_ER_RFC8,'-','')  OTHER_ER_RFC8
            ,replace(OTHER_ER_RFC9,'-','')  OTHER_ER_RFC9
            ,replace(OTHER_ER_RFC10,'-','') OTHER_ER_RFC10
            /*Bug#9273001: New fields in 2009 Update*/
            ,decode(VOLUNTARY_CONTRIBUTIONS_ER,0,VOLUNTARY_CONTRIBUTIONS_EE,0) VOLUNTARY_CONTRIBUTIONS_EE
            ,VOLUNTARY_CONTRIBUTIONS_ER
            ,VOLUNTARY_CONTRIBUTIONS_TOTAL
            ,TOT_DED_VOL_CONTRIBUTION
            ,Decode(VOLUNTARY_CONTRIBUTIONS_ER,0,decode(VOLUNTARY_CONTRIBUTIONS_EE,0,0,2),1) ER_VOL_CONTR_FLAG
            /*Bug#9273001: New fields in 2009 Update*/
            ,0 SEP_EARNINGS
            ,0 ASSIMILATED_SALARIES
            ,0 ER_PAYMENT_TO_EE
            ,RET_EARNINGS_IN_PART_PYMNT
            ,RET_DAILY_EARNINGS_IN_PYMNT
            ,RET_PERIOD_EARNINGS
            ,RET_EARNINGS_IN_ONE_PYMNT
            ,RET_EARNINGS_DAYS
            ,RET_EXEMPT_EARNINGS
            ,RET_TAXABLE_EARNINGS
            ,RET_CUMULATIVE_EARNINGS
            ,RET_NON_CUMULATIVE_EARNINGS
            ,ISR_WITHHELD_FOR_RET_EARNINGS
            ,AMENDS
            ,NVL(SENIORITY,0) SENIORITY
            ,ISR_EXEMPT_FOR_AMENDS
            ,ISR_SUBJECT_FOR_AMENDS
            ,LAST_MTH_ORD_SAL
            ,LAST_MTH_ORD_SAL_WITHHELD
            ,NON_CUMULATIVE_AMENDS
            ,ISR_WITHHELD_FOR_AMENDS
            ,ASSIMILATED_EARNINGS
            ,ISR_WITHHELD_FOR_ASSI_EARNINGS
            ,decode(STK_OPTIONS_VESTING_VALUE,0,0,1) EMPR_STOCK_OPTION_PLAN
            ,STK_OPTIONS_VESTING_VALUE
            ,STK_OPTIONS_GRANT_PRICE
            ,STK_OPTIONS_CUML_INCOME
            ,STK_OPTIONS_TAX_WITHHELD
            ,ISR_SUBJECT_FOR_FIXED_EARNINGS
            ,ISR_EXEMPT_FOR_FIXED_EARNINGS
            ,ISR_SUBJECT_FOR_XMAS_BONUS
            ,ISR_EXEMPT_FOR_XMAS_BONUS
            ,ISR_SUBJECT_FOR_TRAVEL_EXP
            ,ISR_EXEMPT_FOR_TRAVEL_EXP
            ,ISR_SUBJECT_FOR_OVERTIME
            ,ISR_EXEMPT_FOR_OVERTIME
            ,ISR_SUBJECT_FOR_VAC_PREMIUM
            ,ISR_EXEMPT_FOR_VAC_PREMIUM
            ,ISR_SUBJECT_FOR_DOM_PREMIUM
            ,ISR_EXEMPT_FOR_DOM_PREMIUM
            ,ISR_SUBJECT_FOR_PROFIT_SHARING
            ,ISR_EXEMPT_FOR_PROFIT_SHARING
            ,ISR_SUBJECT_FOR_HEALTHCARE_REI
            ,ISR_EXEMPT_FOR_HEALTHCARE_REI
            ,ISR_SUBJECT_FOR_SAVINGS_FUND
            ,ISR_EXEMPT_FOR_SAVINGS_FUND
            ,ISR_SUBJECT_FOR_SAVINGS_BOX
            ,ISR_EXEMPT_FOR_SAVINGS_BOX
            ,ISR_SUBJECT_FOR_PANTRY_COUPONS
            ,ISR_EXEMPT_FOR_PANTRY_COUPONS
            ,ISR_SUBJECT_FOR_FUNERAL_AID
            ,ISR_EXEMPT_FOR_FUNERAL_AID
            ,ISR_SUBJECT_FOR_WR_PD_BY_ER
            ,ISR_EXEMPT_FOR_WR_PD_BY_ER
            ,ISR_SUBJECT_FOR_PUN_INCENTIVE
            ,ISR_EXEMPT_FOR_PUN_INCENTIVE
            ,ISR_SUBJECT_FOR_LIFE_INS_PRE
            ,ISR_EXEMPT_FOR_LIFE_INS_PRE
            ,ISR_SUBJECT_FOR_MAJOR_MED_INS
            ,ISR_EXEMPT_FOR_MAJOR_MED_INS
            ,ISR_SUBJECT_FOR_REST_COUPONS
            ,ISR_EXEMPT_FOR_REST_COUPONS
            ,ISR_SUBJECT_FOR_GAS_COUPONS
            ,ISR_EXEMPT_FOR_GAS_COUPONS
            ,ISR_SUBJECT_FOR_UNI_COUPONS
            ,ISR_EXEMPT_FOR_UNI_COUPONS
            ,ISR_SUBJECT_FOR_RENTAL_AID
            ,ISR_EXEMPT_FOR_RENTAL_AID
            ,ISR_SUBJECT_FOR_EDU_AID
            ,ISR_EXEMPT_FOR_EDU_AID
            ,ISR_SUBJECT_FOR_GLASSES_AID
            ,ISR_EXEMPT_FOR_GLASSES_AID
            ,ISR_SUBJECT_FOR_TRANS_AID
            ,ISR_EXEMPT_FOR_TRANS_AID
            ,ISR_SUBJECT_FOR_UNION_PD_BY_ER
            ,ISR_EXEMPT_FOR_UNION_PD_BY_ER
            ,ISR_SUBJECT_FOR_DISAB_SUBSIDY
            ,ISR_EXEMPT_FOR_DISAB_SUBSIDY
            ,ISR_SUBJECT_FOR_CHILD_SCHOLAR
            ,ISR_EXEMPT_FOR_CHILD_SCHOLAR
            ,NVL(PREV_ER_EARNINGS,0) PREV_ER_EARNINGS
            ,NVL(PREV_ER_EXEMPT_EARNINGS,0) PREV_ER_EXEMPT_EARNINGS
            ,ISR_SUBJECT_OTHER_INCOME
            ,ISR_EXEMPT_OTHER_INCOME
            ,TOTAL_SUBJECT_EARNINGS
            ,TOTAL_EXEMPT_EARNINGS
            ,TAX_WITHHELD_IN_FISCAL_YEAR
            ,NVL(PREV_ER_ISR_WITHHELD,0) PREV_ER_ISR_WITHHELD
            --,CURRENT_FY_ARREARS
	    ,decode( sign (decode( ANNUAL_TAX_CALC_FLAG , 'Y',NVL(CURRENT_FY_ARREARS,0), 0))
		     ,-1,(decode( ANNUAL_TAX_CALC_FLAG , 'Y',NVL(CURRENT_FY_ARREARS,0), 0))* -1,0)
		     CURRENT_FY_ARREARS
	    ,PREV_FY_ARREARS
            ,0 CREDIT_TO_SALARY /*7702851*/
            ,0 CREDIT_TO_SALARY_PAID
            ,SOCIAL_FORESIGHT_EARNINGS
            ,ISR_EXEMPT_FOR_SOC_FORESIGHT
            ,nvl(TOTAL_SUBJECT_EARNINGS,0)+nvl(TOTAL_EXEMPT_EARNINGS,0) SUM_SAL_WAGES_EARNINGS
            ,EMPLOYEE_STATE_TAX_WITHHELD LOCAL_TAX_AMT_EARN_SAL_WAGES
            ,ISR_SUBSIDY_FOR_EMP_PAID AMT_SUBSIDY_EMPT_IN_FY /*7702851*/
            ,0 AMT_SUBSIDY_INCOME_PAID_EMP_FY
            ,decode(ANNUAL_TAX_CALC_FLAG,'Y',ISR_CALCULATED,0) ISR_CALCULATED
            ,ISR_CREDITABLE_SUBSIDY
            ,ISR_NON_CREDITABLE_SUBSIDY
            ,ISR_ON_CUMULATIVE_EARNINGS
            ,ISR_ON_NON_CUMULATIVE_EARNINGS
            ,ISR_SUBSIDY_FOR_EMP ISR_SUBSIDY_EMPT_PAID_TO_EMP  /*7702851*/
            ,0 ISR_SUBSIDY_INC_PAID_EMP
            ,trunc(FND_NUMBER.canonical_to_number(NVL(tax_subsidy_pct,'0')),0) TAX_SUBSIDY_PCT_I
            ,rpad(replace(FND_NUMBER.canonical_to_number(NVL(tax_subsidy_pct,'0'))-
             trunc(FND_NUMBER.canonical_to_number(NVL(tax_subsidy_pct,'0')),0),'.',''),4,0)
                                                          TAX_SUBSIDY_PCT_D
            ,to_char(FND_NUMBER.canonical_to_number(nvl(SUBSIDY_PORTION_APPLIED,'0')),p_format)
                                                       SUBSIDY_PORTION_APPLIED
            ,trunc(FND_NUMBER.canonical_to_number(NVL(subsidy_portion_applied,'0')),0)
                                            SUBSIDY_PORTION_APPLIED_I
            ,rpad(replace(FND_NUMBER.canonical_to_number(NVL(subsidy_portion_applied,'0'))-
             trunc(FND_NUMBER.canonical_to_number(NVL(subsidy_portion_applied,'0')),0),'.',''),4,0)
                                            SUBSIDY_PORTION_APPLIED_D
            ,TOT_EARNING_ASSI_CONCEPTS
            ,EMPLOYEE_STATE_TAX_WITHHELD
            ,TOT_EXEMPT_EARNINGS
            ,TOT_NON_CUMULATIVE_EARNINGS
            ,TOT_CUMULATIVE_EARNINGS
            ,CREDITABLE_SUBSIDY_FRACTIONIII
            ,CREDITABLE_SUBSIDY_FRACTIONIV
            ,TAX_ON_INCOME_FISCAL_YEAR
            ,ISR_TAX_WITHHELD
            ,(nvl(TOTAL_SUBJECT_EARNINGS,0) + nvl(TOTAL_EXEMPT_EARNINGS,0)) TOTAL_EARNINGS
            ,replace(ER_RFC_ID,'-','')           ER_RFC_ID
            ,UPPER(ER_LEGAL_NAME)                ER_LEGAL_NAME
            ,UPPER(ER_LEGAL_REP_NAMES)           ER_LEGAL_REP_NAMES
            ,replace(ER_LEGAL_REP_RFC_ID,'-','') ER_LEGAL_REP_RFC_ID
            ,ER_LEGAL_REP_CURP
            ,NVL(ER_TAX_SUBSIDY_PCT,'0') ER_TAX_SUBSIDY_PCT
            ,FISCAL_YEAR_REPORTING
	    ,'N' REHIRE_FLAG
            ,ltrim(rtrim(PATERNAL_LAST_NAME)) ||' '
                 ||ltrim(rtrim(MATERNAL_LAST_NAME)) ||' '
                 ||ltrim(rtrim(NAMES))   FULL_NAME
        FROM pay_mx_isr_tax_format37_v dim
            ,pay_assignment_actions paa
            ,pay_action_interlocks pai
       WHERE dim.payroll_action_id    = paa.payroll_action_id
         AND dim.assignment_action_id = paa.assignment_action_id /*7951969*/
         AND dim.person_id            = to_number(paa.serial_number)
         AND paa.assignment_action_id = pai.locked_action_id
         AND pai.locking_action_id    = cp_assignment_action_id
       ORDER BY effective_date DESC;

    l_proc_name          varchar2(100);
    l_xml                BLOB;
    lb_person_processed  boolean;

    ln_assignment_action_id  NUMBER;
    ln_person_id             NUMBER;
    ln_business_group_id     NUMBER;
    ld_effective_date        DATE;
    lv_ann_tax_calc_type     VARCHAR2(240);
    ln_anntaxadj_asgactid    NUMBER;
    ln_input_value_id        NUMBER;
    lv_anntaxadj_article     VARCHAR2(240);
    p_format VARCHAR2(60);
    decimal_char VARCHAR2(3);

    dim        c_dim_rec%ROWTYPE;
    prev_dim   c_dim_rec%ROWTYPE;

  BEGIN

    l_proc_name := g_proc_name || 'GENERATE_XML';
    hr_utility_trace ('Entering '||l_proc_name);

    ln_assignment_action_id := pay_magtape_generic.get_parameter_value
                                                   ('TRANSFER_ACT_ID');

    hr_utility_trace ('Fetching transactions for magtape asg action '||
                                               ln_assignment_action_id);
    decimal_char := substr(ltrim(to_char(.3,'0D0')),2,1);
    p_format := '0'||decimal_char||'9999';
    hr_utility_trace('decimal_char '||decimal_char);
    hr_utility_trace('p_format '||p_format);
    dim_xml_tbl.DELETE;

    gn_success_fail := 0;
    gn_sep_bal      := 0;
    gn_ass_bal      := 0;
    gn_emp_bal      := 0;

    ln_person_id    := -1;

    SELECT fnd_global.local_chr(13) || fnd_global.local_chr(10)
      INTO EOL
      FROM dual;


    OPEN  c_dim_rec(ln_assignment_action_id,p_format);

    LOOP

      FETCH c_dim_rec INTO dim;
      EXIT WHEN c_dim_rec%NOTFOUND;

      IF ln_person_id = -1 THEN
         prev_dim := dim;
      ELSE
         prev_dim.REHIRE_FLAG :='Y';
         IF fnd_number.canonical_to_number(prev_dim.start_month) >
              fnd_number.canonical_to_number(dim.start_month) THEN
              prev_dim.start_month := dim.start_month;
         END IF;
         IF fnd_number.canonical_to_number(prev_dim.end_month) <
              fnd_number.canonical_to_number(dim.end_month) THEN
              prev_dim.end_month := dim.end_month;
         END IF; /*7951969*/
         prev_dim.RET_EARNINGS_IN_PART_PYMNT :=
                                       prev_dim.RET_EARNINGS_IN_PART_PYMNT +
                                       dim.RET_EARNINGS_IN_PART_PYMNT;
         prev_dim.RET_DAILY_EARNINGS_IN_PYMNT :=
                                       prev_dim.RET_DAILY_EARNINGS_IN_PYMNT+
                                       dim.RET_DAILY_EARNINGS_IN_PYMNT;
         prev_dim.RET_PERIOD_EARNINGS := prev_dim.RET_PERIOD_EARNINGS +
                                         dim.RET_PERIOD_EARNINGS;
         prev_dim.RET_EARNINGS_IN_ONE_PYMNT :=
                                       prev_dim.RET_EARNINGS_IN_ONE_PYMNT+
                                       dim.RET_EARNINGS_IN_ONE_PYMNT;
         prev_dim.RET_EARNINGS_DAYS := prev_dim.RET_EARNINGS_DAYS +
                                       dim.RET_EARNINGS_DAYS;
         prev_dim.RET_EXEMPT_EARNINGS := prev_dim.RET_EXEMPT_EARNINGS +
                                         dim.RET_EXEMPT_EARNINGS;
         prev_dim.RET_TAXABLE_EARNINGS := prev_dim.RET_TAXABLE_EARNINGS +
                                          dim.RET_TAXABLE_EARNINGS;
         prev_dim.RET_CUMULATIVE_EARNINGS := prev_dim.RET_CUMULATIVE_EARNINGS +
                                             dim.RET_CUMULATIVE_EARNINGS;
         prev_dim.RET_NON_CUMULATIVE_EARNINGS :=
                                      prev_dim.RET_NON_CUMULATIVE_EARNINGS +
                                      dim.RET_NON_CUMULATIVE_EARNINGS;
         prev_dim.ISR_WITHHELD_FOR_RET_EARNINGS :=
                               prev_dim.ISR_WITHHELD_FOR_RET_EARNINGS +
                               dim.ISR_WITHHELD_FOR_RET_EARNINGS;
         prev_dim.AMENDS := prev_dim.AMENDS + prev_dim.AMENDS;
         prev_dim.SENIORITY := prev_dim.SENIORITY + dim.SENIORITY;
         prev_dim.ISR_EXEMPT_FOR_AMENDS := prev_dim.ISR_EXEMPT_FOR_AMENDS +
                                           dim.ISR_EXEMPT_FOR_AMENDS;
         prev_dim.ISR_SUBJECT_FOR_AMENDS := prev_dim.ISR_SUBJECT_FOR_AMENDS +
                                            dim.ISR_SUBJECT_FOR_AMENDS;
         prev_dim.LAST_MTH_ORD_SAL := prev_dim.LAST_MTH_ORD_SAL +
                                      dim.LAST_MTH_ORD_SAL;
         prev_dim.LAST_MTH_ORD_SAL_WITHHELD :=
                           prev_dim.LAST_MTH_ORD_SAL_WITHHELD +
                           dim.LAST_MTH_ORD_SAL_WITHHELD;
         prev_dim.NON_CUMULATIVE_AMENDS := prev_dim.NON_CUMULATIVE_AMENDS +
                                           dim.NON_CUMULATIVE_AMENDS;
         prev_dim.ISR_WITHHELD_FOR_AMENDS := prev_dim.ISR_WITHHELD_FOR_AMENDS +
                                             dim.ISR_WITHHELD_FOR_AMENDS;
         prev_dim.ASSIMILATED_EARNINGS := prev_dim.ASSIMILATED_EARNINGS +
                                          dim.ASSIMILATED_EARNINGS;
         prev_dim.ISR_WITHHELD_FOR_ASSI_EARNINGS :=
                               prev_dim.ISR_WITHHELD_FOR_ASSI_EARNINGS +
                               dim.ISR_WITHHELD_FOR_ASSI_EARNINGS;
         if dim.STK_OPTIONS_VESTING_VALUE <> 0 then
            prev_dim.EMPR_STOCK_OPTION_PLAN := 1;
         End if;
         Prev_dim.STK_OPTIONS_VESTING_VALUE := Prev_dim.STK_OPTIONS_VESTING_VALUE +
                               dim.STK_OPTIONS_VESTING_VALUE;
         prev_dim.STK_OPTIONS_GRANT_PRICE := prev_dim.STK_OPTIONS_GRANT_PRICE +
                               dim.STK_OPTIONS_GRANT_PRICE;
         prev_dim.STK_OPTIONS_CUML_INCOME := prev_dim.STK_OPTIONS_CUML_INCOME +
                               dim.STK_OPTIONS_CUML_INCOME ;
         prev_dim.STK_OPTIONS_TAX_WITHHELD := prev_dim.STK_OPTIONS_TAX_WITHHELD +
                               dim.STK_OPTIONS_TAX_WITHHELD;
         prev_dim.ISR_SUBJECT_FOR_FIXED_EARNINGS :=
                              prev_dim.ISR_SUBJECT_FOR_FIXED_EARNINGS +
                              dim.ISR_SUBJECT_FOR_FIXED_EARNINGS;
         prev_dim.ISR_EXEMPT_FOR_FIXED_EARNINGS :=
                             prev_dim.ISR_EXEMPT_FOR_FIXED_EARNINGS +
                             dim.ISR_EXEMPT_FOR_FIXED_EARNINGS;
         prev_dim.ISR_SUBJECT_FOR_XMAS_BONUS :=
                              prev_dim.ISR_SUBJECT_FOR_XMAS_BONUS +
                              dim.ISR_SUBJECT_FOR_XMAS_BONUS;
         prev_dim.ISR_EXEMPT_FOR_XMAS_BONUS :=
                             prev_dim.ISR_EXEMPT_FOR_XMAS_BONUS +
                             dim.ISR_EXEMPT_FOR_XMAS_BONUS;
         prev_dim.ISR_SUBJECT_FOR_TRAVEL_EXP :=
                              prev_dim.ISR_SUBJECT_FOR_TRAVEL_EXP +
                              dim.ISR_SUBJECT_FOR_TRAVEL_EXP;
         prev_dim.ISR_EXEMPT_FOR_TRAVEL_EXP :=
                             prev_dim.ISR_EXEMPT_FOR_TRAVEL_EXP +
                             dim.ISR_EXEMPT_FOR_TRAVEL_EXP;
         prev_dim.ISR_SUBJECT_FOR_OVERTIME :=
                              prev_dim.ISR_SUBJECT_FOR_OVERTIME +
                              dim.ISR_SUBJECT_FOR_OVERTIME;
         prev_dim.ISR_EXEMPT_FOR_OVERTIME :=
                             prev_dim.ISR_EXEMPT_FOR_OVERTIME +
                             dim.ISR_EXEMPT_FOR_OVERTIME;
         prev_dim.ISR_SUBJECT_FOR_VAC_PREMIUM :=
                              prev_dim.ISR_SUBJECT_FOR_VAC_PREMIUM +
                              dim.ISR_SUBJECT_FOR_VAC_PREMIUM;
         prev_dim.ISR_EXEMPT_FOR_VAC_PREMIUM :=
                             prev_dim.ISR_EXEMPT_FOR_VAC_PREMIUM +
                             dim.ISR_EXEMPT_FOR_VAC_PREMIUM;
         prev_dim.ISR_SUBJECT_FOR_DOM_PREMIUM :=
                              prev_dim.ISR_SUBJECT_FOR_DOM_PREMIUM +
                              dim.ISR_SUBJECT_FOR_DOM_PREMIUM;
         prev_dim.ISR_EXEMPT_FOR_DOM_PREMIUM :=
                             prev_dim.ISR_EXEMPT_FOR_DOM_PREMIUM +
                             dim.ISR_EXEMPT_FOR_DOM_PREMIUM;
         prev_dim.ISR_SUBJECT_FOR_PROFIT_SHARING :=
                              prev_dim.ISR_SUBJECT_FOR_PROFIT_SHARING +
                              dim.ISR_SUBJECT_FOR_PROFIT_SHARING;
         prev_dim.ISR_EXEMPT_FOR_PROFIT_SHARING :=
                             prev_dim.ISR_EXEMPT_FOR_PROFIT_SHARING +
                             dim.ISR_EXEMPT_FOR_PROFIT_SHARING;
         prev_dim.ISR_SUBJECT_FOR_HEALTHCARE_REI :=
                              prev_dim.ISR_SUBJECT_FOR_HEALTHCARE_REI +
                              dim.ISR_SUBJECT_FOR_HEALTHCARE_REI;
         prev_dim.ISR_EXEMPT_FOR_HEALTHCARE_REI :=
                             prev_dim.ISR_EXEMPT_FOR_HEALTHCARE_REI +
                             dim.ISR_EXEMPT_FOR_HEALTHCARE_REI;
         prev_dim.ISR_SUBJECT_FOR_SAVINGS_FUND :=
                              prev_dim.ISR_SUBJECT_FOR_SAVINGS_FUND +
                              dim.ISR_SUBJECT_FOR_SAVINGS_FUND;
         prev_dim.ISR_EXEMPT_FOR_SAVINGS_FUND :=
                             prev_dim.ISR_EXEMPT_FOR_SAVINGS_FUND +
                             dim.ISR_EXEMPT_FOR_SAVINGS_FUND;
         prev_dim.ISR_SUBJECT_FOR_SAVINGS_BOX         :=
                              prev_dim.ISR_SUBJECT_FOR_SAVINGS_BOX +
                              dim.ISR_SUBJECT_FOR_SAVINGS_BOX;
         prev_dim.ISR_EXEMPT_FOR_SAVINGS_BOX:=
                              prev_dim.ISR_EXEMPT_FOR_SAVINGS_BOX+
                              dim.ISR_EXEMPT_FOR_SAVINGS_BOX;
         prev_dim.ISR_SUBJECT_FOR_PANTRY_COUPONS:=
                              prev_dim.ISR_SUBJECT_FOR_PANTRY_COUPONS+
                              dim.ISR_SUBJECT_FOR_PANTRY_COUPONS;
         prev_dim.ISR_EXEMPT_FOR_PANTRY_COUPONS:=
                              prev_dim.ISR_EXEMPT_FOR_PANTRY_COUPONS+
                              dim.ISR_EXEMPT_FOR_PANTRY_COUPONS;
         prev_dim.ISR_SUBJECT_FOR_FUNERAL_AID:=
                              prev_dim.ISR_SUBJECT_FOR_FUNERAL_AID+
                              dim.ISR_SUBJECT_FOR_FUNERAL_AID;
         prev_dim.ISR_EXEMPT_FOR_FUNERAL_AID:=
                              prev_dim.ISR_EXEMPT_FOR_FUNERAL_AID+
                              dim.ISR_EXEMPT_FOR_FUNERAL_AID;
         prev_dim.ISR_SUBJECT_FOR_WR_PD_BY_ER:=
                              prev_dim.ISR_SUBJECT_FOR_WR_PD_BY_ER+
                              dim.ISR_SUBJECT_FOR_WR_PD_BY_ER;
         prev_dim.ISR_EXEMPT_FOR_WR_PD_BY_ER:=
                              prev_dim.ISR_EXEMPT_FOR_WR_PD_BY_ER+
                              dim.ISR_EXEMPT_FOR_WR_PD_BY_ER;
         prev_dim.ISR_SUBJECT_FOR_PUN_INCENTIVE:=
                              prev_dim.ISR_SUBJECT_FOR_PUN_INCENTIVE+
                              dim.ISR_SUBJECT_FOR_PUN_INCENTIVE;
         prev_dim.ISR_EXEMPT_FOR_PUN_INCENTIVE:=
                              prev_dim.ISR_EXEMPT_FOR_PUN_INCENTIVE+
                              dim.ISR_EXEMPT_FOR_PUN_INCENTIVE;
         prev_dim.ISR_SUBJECT_FOR_LIFE_INS_PRE:=
                              prev_dim.ISR_SUBJECT_FOR_LIFE_INS_PRE+
                              dim.ISR_SUBJECT_FOR_LIFE_INS_PRE;
         prev_dim.ISR_EXEMPT_FOR_LIFE_INS_PRE:=
                              prev_dim.ISR_EXEMPT_FOR_LIFE_INS_PRE+
                              dim.ISR_EXEMPT_FOR_LIFE_INS_PRE;
         prev_dim.ISR_SUBJECT_FOR_MAJOR_MED_INS:=
                              prev_dim.ISR_SUBJECT_FOR_MAJOR_MED_INS+
                              dim.ISR_SUBJECT_FOR_MAJOR_MED_INS;
         prev_dim.ISR_EXEMPT_FOR_MAJOR_MED_INS:=
                              prev_dim.ISR_EXEMPT_FOR_MAJOR_MED_INS+
                              dim.ISR_EXEMPT_FOR_MAJOR_MED_INS;
         prev_dim.ISR_SUBJECT_FOR_REST_COUPONS:=
                              prev_dim.ISR_SUBJECT_FOR_REST_COUPONS+
                              dim.ISR_SUBJECT_FOR_REST_COUPONS;
         prev_dim.ISR_EXEMPT_FOR_REST_COUPONS:=
                              prev_dim.ISR_EXEMPT_FOR_REST_COUPONS+
                              dim.ISR_EXEMPT_FOR_REST_COUPONS;
         prev_dim.ISR_SUBJECT_FOR_GAS_COUPONS:=
                              prev_dim.ISR_SUBJECT_FOR_GAS_COUPONS+
                              dim.ISR_SUBJECT_FOR_GAS_COUPONS;
         prev_dim.ISR_EXEMPT_FOR_GAS_COUPONS:=
                              prev_dim.ISR_EXEMPT_FOR_GAS_COUPONS+
                              dim.ISR_EXEMPT_FOR_GAS_COUPONS;
         prev_dim.ISR_SUBJECT_FOR_UNI_COUPONS:=
                              prev_dim.ISR_SUBJECT_FOR_UNI_COUPONS+
                              dim.ISR_SUBJECT_FOR_UNI_COUPONS;
         prev_dim.ISR_EXEMPT_FOR_UNI_COUPONS:=
                              prev_dim.ISR_EXEMPT_FOR_UNI_COUPONS+
                              dim.ISR_EXEMPT_FOR_UNI_COUPONS;
         prev_dim.ISR_SUBJECT_FOR_RENTAL_AID:=
                              prev_dim.ISR_SUBJECT_FOR_RENTAL_AID+
                              dim.ISR_SUBJECT_FOR_RENTAL_AID;
         prev_dim.ISR_EXEMPT_FOR_RENTAL_AID:=
                              prev_dim.ISR_EXEMPT_FOR_RENTAL_AID+
                              dim.ISR_EXEMPT_FOR_RENTAL_AID;
         prev_dim.ISR_SUBJECT_FOR_EDU_AID:=
                              prev_dim.ISR_SUBJECT_FOR_EDU_AID+
                              dim.ISR_SUBJECT_FOR_EDU_AID;
         prev_dim.ISR_EXEMPT_FOR_EDU_AID:=
                              prev_dim.ISR_EXEMPT_FOR_EDU_AID+
                              dim.ISR_EXEMPT_FOR_EDU_AID;
         prev_dim.ISR_SUBJECT_FOR_GLASSES_AID:=
                              prev_dim.ISR_SUBJECT_FOR_GLASSES_AID+
                              dim.ISR_SUBJECT_FOR_GLASSES_AID;
         prev_dim.ISR_EXEMPT_FOR_GLASSES_AID:=
                              prev_dim.ISR_EXEMPT_FOR_GLASSES_AID+
                              dim.ISR_EXEMPT_FOR_GLASSES_AID;
         prev_dim.ISR_SUBJECT_FOR_TRANS_AID:=
                              prev_dim.ISR_SUBJECT_FOR_TRANS_AID+
                              dim.ISR_SUBJECT_FOR_TRANS_AID;
         prev_dim.ISR_EXEMPT_FOR_TRANS_AID:=
                              prev_dim.ISR_EXEMPT_FOR_TRANS_AID+
                              dim.ISR_EXEMPT_FOR_TRANS_AID;
         prev_dim.ISR_SUBJECT_FOR_UNION_PD_BY_ER:=
                              prev_dim.ISR_SUBJECT_FOR_UNION_PD_BY_ER+
                              dim.ISR_SUBJECT_FOR_UNION_PD_BY_ER;
         prev_dim.ISR_EXEMPT_FOR_UNION_PD_BY_ER:=
                              prev_dim.ISR_EXEMPT_FOR_UNION_PD_BY_ER+
                              dim.ISR_EXEMPT_FOR_UNION_PD_BY_ER;
         prev_dim.ISR_SUBJECT_FOR_DISAB_SUBSIDY:=
                              prev_dim.ISR_SUBJECT_FOR_DISAB_SUBSIDY+
                              dim.ISR_SUBJECT_FOR_DISAB_SUBSIDY;
         prev_dim.ISR_EXEMPT_FOR_DISAB_SUBSIDY:=
                              prev_dim.ISR_EXEMPT_FOR_DISAB_SUBSIDY+
                              dim.ISR_EXEMPT_FOR_DISAB_SUBSIDY;
         prev_dim.ISR_SUBJECT_FOR_CHILD_SCHOLAR:=
                              prev_dim.ISR_SUBJECT_FOR_CHILD_SCHOLAR+
                              dim.ISR_SUBJECT_FOR_CHILD_SCHOLAR;
         prev_dim.ISR_EXEMPT_FOR_CHILD_SCHOLAR:=
                              prev_dim.ISR_EXEMPT_FOR_CHILD_SCHOLAR+
                              dim.ISR_EXEMPT_FOR_CHILD_SCHOLAR;
         prev_dim.PREV_ER_EARNINGS:=
                              prev_dim.PREV_ER_EARNINGS+
                              dim.PREV_ER_EARNINGS;
         prev_dim.PREV_ER_EXEMPT_EARNINGS:=
                              prev_dim.PREV_ER_EXEMPT_EARNINGS+
                              dim.PREV_ER_EXEMPT_EARNINGS;
         prev_dim.ISR_SUBJECT_OTHER_INCOME:=
                              prev_dim.ISR_SUBJECT_OTHER_INCOME+
                              dim.ISR_SUBJECT_OTHER_INCOME;
         prev_dim.ISR_EXEMPT_OTHER_INCOME:=
                              prev_dim.ISR_EXEMPT_OTHER_INCOME+
                              dim.ISR_EXEMPT_OTHER_INCOME;
         prev_dim.TOTAL_SUBJECT_EARNINGS:=
                              prev_dim.TOTAL_SUBJECT_EARNINGS+
                              dim.TOTAL_SUBJECT_EARNINGS;
         prev_dim.TOTAL_EXEMPT_EARNINGS:=
                              prev_dim.TOTAL_EXEMPT_EARNINGS+
                              dim.TOTAL_EXEMPT_EARNINGS;
         prev_dim.TAX_WITHHELD_IN_FISCAL_YEAR:=
                              prev_dim.TAX_WITHHELD_IN_FISCAL_YEAR+
                              dim.TAX_WITHHELD_IN_FISCAL_YEAR;
         prev_dim.PREV_ER_ISR_WITHHELD:=
                              prev_dim.PREV_ER_ISR_WITHHELD+
                              dim.PREV_ER_ISR_WITHHELD;
         prev_dim.CURRENT_FY_ARREARS:=
                              prev_dim.CURRENT_FY_ARREARS+
                              dim.CURRENT_FY_ARREARS;
         prev_dim.PREV_FY_ARREARS:=
                              prev_dim.PREV_FY_ARREARS+
                              dim.PREV_FY_ARREARS;
         prev_dim.CREDIT_TO_SALARY:=
                              prev_dim.CREDIT_TO_SALARY+
                              dim.CREDIT_TO_SALARY;
         prev_dim.CREDIT_TO_SALARY_PAID:=
                              prev_dim.CREDIT_TO_SALARY_PAID+
                              dim.CREDIT_TO_SALARY_PAID;
         prev_dim.SOCIAL_FORESIGHT_EARNINGS:=
                              prev_dim.SOCIAL_FORESIGHT_EARNINGS+
                              dim.SOCIAL_FORESIGHT_EARNINGS;
         prev_dim.ISR_EXEMPT_FOR_SOC_FORESIGHT:=
                              prev_dim.ISR_EXEMPT_FOR_SOC_FORESIGHT+
                              dim.ISR_EXEMPT_FOR_SOC_FORESIGHT;
         prev_dim.SUM_SAL_WAGES_EARNINGS:=
                              prev_dim.SUM_SAL_WAGES_EARNINGS +
                              dim.SUM_SAL_WAGES_EARNINGS;
         prev_dim.LOCAL_TAX_AMT_EARN_SAL_WAGES:=
                              prev_dim.LOCAL_TAX_AMT_EARN_SAL_WAGES +
                              dim.LOCAL_TAX_AMT_EARN_SAL_WAGES;
         prev_dim.AMT_SUBSIDY_EMPT_IN_FY:=
                              prev_dim.AMT_SUBSIDY_EMPT_IN_FY +
                              dim.AMT_SUBSIDY_EMPT_IN_FY;
         prev_dim.AMT_SUBSIDY_INCOME_PAID_EMP_FY:=
                              prev_dim.AMT_SUBSIDY_INCOME_PAID_EMP_FY +
                              dim.AMT_SUBSIDY_INCOME_PAID_EMP_FY;
         prev_dim.ISR_CALCULATED:=
                              prev_dim.ISR_CALCULATED+
                              dim.ISR_CALCULATED;
         prev_dim.ISR_CREDITABLE_SUBSIDY:=
                              prev_dim.ISR_CREDITABLE_SUBSIDY+
                              dim.ISR_CREDITABLE_SUBSIDY;
         prev_dim.ISR_NON_CREDITABLE_SUBSIDY:=
                              prev_dim.ISR_NON_CREDITABLE_SUBSIDY+
                              dim.ISR_NON_CREDITABLE_SUBSIDY;
         prev_dim.ISR_ON_CUMULATIVE_EARNINGS:=
                              prev_dim.ISR_ON_CUMULATIVE_EARNINGS+
                              dim.ISR_ON_CUMULATIVE_EARNINGS;
         prev_dim.ISR_ON_NON_CUMULATIVE_EARNINGS:=
                              prev_dim.ISR_ON_NON_CUMULATIVE_EARNINGS+
                              dim.ISR_ON_NON_CUMULATIVE_EARNINGS;
         prev_dim.ISR_SUBSIDY_EMPT_PAID_TO_EMP:=
                              prev_dim.ISR_SUBSIDY_EMPT_PAID_TO_EMP +
                              dim.ISR_SUBSIDY_EMPT_PAID_TO_EMP;
         prev_dim.ISR_SUBSIDY_INC_PAID_EMP:=
                              prev_dim.ISR_SUBSIDY_INC_PAID_EMP +
                              dim.ISR_SUBSIDY_INC_PAID_EMP;
         prev_dim.TOT_EARNING_ASSI_CONCEPTS := prev_dim.TOT_EARNING_ASSI_CONCEPTS +
	                      dim.TOT_EARNING_ASSI_CONCEPTS;
         prev_dim.EMPLOYEE_STATE_TAX_WITHHELD := prev_dim.EMPLOYEE_STATE_TAX_WITHHELD +
	                      dim.EMPLOYEE_STATE_TAX_WITHHELD ;
         prev_dim.TOT_EXEMPT_EARNINGS := prev_dim.TOT_EXEMPT_EARNINGS +
	                   dim.TOT_EXEMPT_EARNINGS ;
         prev_dim.TOT_NON_CUMULATIVE_EARNINGS := prev_dim.TOT_NON_CUMULATIVE_EARNINGS +
	                   dim.TOT_NON_CUMULATIVE_EARNINGS ;
         prev_dim.TOT_CUMULATIVE_EARNINGS := prev_dim.TOT_CUMULATIVE_EARNINGS +
	                   dim.TOT_CUMULATIVE_EARNINGS ;
         prev_dim.CREDITABLE_SUBSIDY_FRACTIONIII := prev_dim.CREDITABLE_SUBSIDY_FRACTIONIII +
	                   dim.CREDITABLE_SUBSIDY_FRACTIONIII ;
         prev_dim.CREDITABLE_SUBSIDY_FRACTIONIV := prev_dim.CREDITABLE_SUBSIDY_FRACTIONIV +
	                   prev_dim.CREDITABLE_SUBSIDY_FRACTIONIV ;
         prev_dim.TAX_ON_INCOME_FISCAL_YEAR := prev_dim.TAX_ON_INCOME_FISCAL_YEAR +
	                   dim.TAX_ON_INCOME_FISCAL_YEAR;
         prev_dim.ISR_TAX_WITHHELD := prev_dim.ISR_TAX_WITHHELD +
	                   dim.ISR_TAX_WITHHELD;
         prev_dim.TOTAL_EARNINGS := prev_dim.TOTAL_EARNINGS +
                              dim.TOTAL_EARNINGS;
         /*Bug#9273001: New fields in 2009 Update*/
         prev_dim.VOLUNTARY_CONTRIBUTIONS_EE := prev_dim.VOLUNTARY_CONTRIBUTIONS_EE +
                              dim.VOLUNTARY_CONTRIBUTIONS_EE;
         prev_dim.VOLUNTARY_CONTRIBUTIONS_ER := prev_dim.VOLUNTARY_CONTRIBUTIONS_ER +
                              dim.VOLUNTARY_CONTRIBUTIONS_ER;
         prev_dim.VOLUNTARY_CONTRIBUTIONS_TOTAL := prev_dim.VOLUNTARY_CONTRIBUTIONS_TOTAL +
                              dim.VOLUNTARY_CONTRIBUTIONS_TOTAL;
         prev_dim.TOT_DED_VOL_CONTRIBUTION := prev_dim.TOT_DED_VOL_CONTRIBUTION +
                              dim.TOT_DED_VOL_CONTRIBUTION;
         /*Bug#9273001: New fields in 2009 Update*/

      END IF;

      ln_person_id := dim.person_id;

    END LOOP;
    CLOSE c_dim_rec;

    populate_xml_table('PERSON_ID', prev_dim.PERSON_ID,'TEXT');
    populate_xml_table('START_MONTH', prev_dim.START_MONTH,'TEXT');
    populate_xml_table('END_MONTH', prev_dim.END_MONTH,'TEXT');
    populate_xml_table('RFC_ID', prev_dim.RFC_ID,'TEXT');
    populate_xml_table('CURP', prev_dim.CURP,'TEXT');
    populate_xml_table('PATERNAL_LAST_NAME',prev_dim.PATERNAL_LAST_NAME,'TEXT');
    populate_xml_table('MATERNAL_LAST_NAME',prev_dim.MATERNAL_LAST_NAME,'TEXT');
    populate_xml_table('NAMES', prev_dim.NAMES,'TEXT');
    populate_xml_table('ECONOMIC_ZONE', prev_dim.ECONOMIC_ZONE,'TEXT');
    populate_xml_table('ANNUAL_TAX_CALC_FLAG',
                       prev_dim.ANNUAL_TAX_CALC_FLAG,'TEXT');
    populate_xml_table('RATE_FISCAL_YEAR_IND',
                       prev_dim.RATE_FISCAL_YEAR_IND,'TEXT');
    populate_xml_table('RATE_1991_IND', prev_dim.RATE_1991_IND,'TEXT');

 /*
    IF ( prev_dim.RATE_1991_IND = '0' AND prev_dim.RATE_FISCAL_YEAR_IND = '0' )
    THEN
       populate_xml_table('SUBSIDY_PROPORTION_USED', '0.0000', 'TEXT');
    ELSE
       IF prev_dim.PREV_ER_EARNINGS <> 0 THEN
          populate_xml_table('SUBSIDY_PROPORTION_USED',
                                      prev_dim.SUBSIDY_PORTION_APPLIED,'TEXT');
       ELSE
          populate_xml_table('SUBSIDY_PROPORTION_USED',
                                      prev_dim.TAX_SUBSIDY_PCT,'TEXT');
       END IF;
    END IF;
*/
    populate_xml_table('SUBSIDY_PROPORTION_USED',
                           '0.0001','TEXT');
    populate_xml_table('UNION_WORKER_FLAG', prev_dim.UNION_WORKER_FLAG,'TEXT');

    /*7702851 start*/
    IF prev_dim.STK_OPTIONS_VESTING_VALUE <> 0 OR
       prev_dim.STK_OPTIONS_GRANT_PRICE <> 0 OR
       prev_dim.STK_OPTIONS_TAX_WITHHELD <> 0 THEN
       prev_dim.ASSIMILATED_TO_SALARY_IND := 'G';
       prev_dim.ASSIMILATED_SALARIES := 1;
       prev_dim.EMPR_STOCK_OPTION_PLAN :=1;

    ELSE
       prev_dim.ASSIMILATED_TO_SALARY_IND := '0';
       prev_dim.ASSIMILATED_SALARIES := 0;
    END IF;
    /*7702851 end*/

    populate_xml_table('ASSIMILATED_TO_SALARY_IND',
                       prev_dim.ASSIMILATED_TO_SALARY_IND,'TEXT');
    populate_xml_table('STATE_ID', prev_dim.STATE_ID,'TEXT');
    populate_xml_table('OTHER_ER_RFC1', prev_dim.OTHER_ER_RFC1,'TEXT');
    populate_xml_table('OTHER_ER_RFC2', prev_dim.OTHER_ER_RFC2,'TEXT');
    populate_xml_table('OTHER_ER_RFC3', prev_dim.OTHER_ER_RFC3,'TEXT');
    populate_xml_table('OTHER_ER_RFC4', prev_dim.OTHER_ER_RFC4,'TEXT');
    populate_xml_table('OTHER_ER_RFC5', prev_dim.OTHER_ER_RFC5,'TEXT');
    populate_xml_table('OTHER_ER_RFC6', prev_dim.OTHER_ER_RFC6,'TEXT');
    populate_xml_table('OTHER_ER_RFC7', prev_dim.OTHER_ER_RFC7,'TEXT');
    populate_xml_table('OTHER_ER_RFC8', prev_dim.OTHER_ER_RFC8,'TEXT');
    populate_xml_table('OTHER_ER_RFC9', prev_dim.OTHER_ER_RFC9,'TEXT');
    populate_xml_table('OTHER_ER_RFC10', prev_dim.OTHER_ER_RFC10,'TEXT');
    populate_xml_table('SEP_EARNINGS', prev_dim.SEP_EARNINGS,'TEXT');
    populate_xml_table('ASSIMILATED_SALARIES',
                       prev_dim.ASSIMILATED_SALARIES,'TEXT');
    populate_xml_table('ER_PAYMENT_TO_EE', prev_dim.ER_PAYMENT_TO_EE,'TEXT');
    populate_xml_table('RET_EARNINGS_IN_PART_PYMNT',
                       prev_dim.RET_EARNINGS_IN_PART_PYMNT , 'SEP_BAL');
    populate_xml_table('RET_DAILY_EARNINGS_IN_PYMNT',
                       prev_dim.RET_DAILY_EARNINGS_IN_PYMNT , 'SEP_BAL');
    populate_xml_table('RET_PERIOD_EARNINGS',
                       prev_dim.RET_PERIOD_EARNINGS , 'SEP_BAL');
    populate_xml_table('RET_EARNINGS_IN_ONE_PYMNT',
                       prev_dim.RET_EARNINGS_IN_ONE_PYMNT , 'SEP_BAL');
    populate_xml_table('RET_EARNINGS_DAYS',
                       prev_dim.RET_EARNINGS_DAYS , 'SEP_BAL');
    populate_xml_table('RET_EXEMPT_EARNINGS',
                       prev_dim.RET_EXEMPT_EARNINGS , 'SEP_BAL');
    populate_xml_table('RET_TAXABLE_EARNINGS',
                       prev_dim.RET_TAXABLE_EARNINGS , 'SEP_BAL');
    populate_xml_table('RET_CUMULATIVE_EARNINGS',
                       prev_dim.RET_CUMULATIVE_EARNINGS , 'SEP_BAL');
    populate_xml_table('RET_NON_CUMULATIVE_EARNINGS',
                       prev_dim.RET_NON_CUMULATIVE_EARNINGS , 'SEP_BAL');
    populate_xml_table('ISR_WITHHELD_FOR_RET_EARNINGS',
                       prev_dim.ISR_WITHHELD_FOR_RET_EARNINGS , 'SEP_BAL');
    populate_xml_table('AMENDS',
                       prev_dim.AMENDS , 'SEP_BAL');
    populate_xml_table('SENIORITY',
                       prev_dim.SENIORITY , 'SEP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_AMENDS',
                       prev_dim.ISR_EXEMPT_FOR_AMENDS , 'SEP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_AMENDS',
                       prev_dim.ISR_SUBJECT_FOR_AMENDS , 'SEP_BAL');
    populate_xml_table('LAST_MTH_ORD_SAL',
                       prev_dim.LAST_MTH_ORD_SAL , 'SEP_BAL');
    populate_xml_table('LAST_MTH_ORD_SAL_WITHHELD',
                       prev_dim.LAST_MTH_ORD_SAL_WITHHELD , 'SEP_BAL');
    populate_xml_table('NON_CUMULATIVE_AMENDS',
                       prev_dim.NON_CUMULATIVE_AMENDS , 'SEP_BAL');
    populate_xml_table('ISR_WITHHELD_FOR_AMENDS',
                       prev_dim.ISR_WITHHELD_FOR_AMENDS , 'SEP_BAL');
    populate_xml_table('ASSIMILATED_EARNINGS',
                       prev_dim.ASSIMILATED_EARNINGS, 'ASS_BAL');
    populate_xml_table('ISR_WITHHELD_FOR_ASSI_EARNINGS',
                       prev_dim.ISR_WITHHELD_FOR_ASSI_EARNINGS, 'ASS_BAL');
    populate_xml_table('EMPR_STOCK_OPTION_PLAN',
                         prev_dim.EMPR_STOCK_OPTION_PLAN, 'ASS_BAL');
    populate_xml_table('STK_OPTIONS_VESTING_VALUE',
                         prev_dim.STK_OPTIONS_VESTING_VALUE, 'ASS_BAL');
    populate_xml_table('STK_OPTIONS_GRANT_PRICE',
                         prev_dim.STK_OPTIONS_GRANT_PRICE, 'ASS_BAL');
    populate_xml_table('STK_OPTIONS_CUML_INCOME',
                         prev_dim.STK_OPTIONS_CUML_INCOME, 'ASS_BAL');
    populate_xml_table('STK_OPTIONS_TAX_WITHHELD',
                         prev_dim.STK_OPTIONS_TAX_WITHHELD, 'ASS_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_FIXED_EARNINGS',
                       prev_dim.ISR_SUBJECT_FOR_FIXED_EARNINGS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_FIXED_EARNINGS',
                       prev_dim.ISR_EXEMPT_FOR_FIXED_EARNINGS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_XMAS_BONUS',
                       prev_dim.ISR_SUBJECT_FOR_XMAS_BONUS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_XMAS_BONUS',
                       prev_dim.ISR_EXEMPT_FOR_XMAS_BONUS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_TRAVEL_EXP',
                       prev_dim.ISR_SUBJECT_FOR_TRAVEL_EXP, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_TRAVEL_EXP',
                       prev_dim.ISR_EXEMPT_FOR_TRAVEL_EXP, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_OVERTIME',
                       prev_dim.ISR_SUBJECT_FOR_OVERTIME, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_OVERTIME',
                       prev_dim.ISR_EXEMPT_FOR_OVERTIME, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_VAC_PREMIUM',
                       prev_dim.ISR_SUBJECT_FOR_VAC_PREMIUM, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_VAC_PREMIUM',
                       prev_dim.ISR_EXEMPT_FOR_VAC_PREMIUM, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_DOM_PREMIUM',
                       prev_dim.ISR_SUBJECT_FOR_DOM_PREMIUM, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_DOM_PREMIUM',
                       prev_dim.ISR_EXEMPT_FOR_DOM_PREMIUM, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_PROFIT_SHARING',
                       prev_dim.ISR_SUBJECT_FOR_PROFIT_SHARING, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_PROFIT_SHARING',
                       prev_dim.ISR_EXEMPT_FOR_PROFIT_SHARING, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_HEALTHCARE_REI',
                       prev_dim.ISR_SUBJECT_FOR_HEALTHCARE_REI, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_HEALTHCARE_REI',
                       prev_dim.ISR_EXEMPT_FOR_HEALTHCARE_REI, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_SAVINGS_FUND',
                       prev_dim.ISR_SUBJECT_FOR_SAVINGS_FUND, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_SAVINGS_FUND',
                       prev_dim.ISR_EXEMPT_FOR_SAVINGS_FUND, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_SAVINGS_BOX',
                       prev_dim.ISR_SUBJECT_FOR_SAVINGS_BOX, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_SAVINGS_BOX',
                       prev_dim.ISR_EXEMPT_FOR_SAVINGS_BOX, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_PANTRY_COUPONS',
                       prev_dim.ISR_SUBJECT_FOR_PANTRY_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_PANTRY_COUPONS',
                       prev_dim.ISR_EXEMPT_FOR_PANTRY_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_FUNERAL_AID',
                       prev_dim.ISR_SUBJECT_FOR_FUNERAL_AID, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_FUNERAL_AID',
                       prev_dim.ISR_EXEMPT_FOR_FUNERAL_AID, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_WR_PD_BY_ER',
                       prev_dim.ISR_SUBJECT_FOR_WR_PD_BY_ER, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_WR_PD_BY_ER',
                       prev_dim.ISR_EXEMPT_FOR_WR_PD_BY_ER, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_PUN_INCENTIVE',
                       prev_dim.ISR_SUBJECT_FOR_PUN_INCENTIVE, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_PUN_INCENTIVE',
                       prev_dim.ISR_EXEMPT_FOR_PUN_INCENTIVE, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_LIFE_INS_PRE',
                       prev_dim.ISR_SUBJECT_FOR_LIFE_INS_PRE, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_LIFE_INS_PRE',
                       prev_dim.ISR_EXEMPT_FOR_LIFE_INS_PRE, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_MAJOR_MED_INS',
                       prev_dim.ISR_SUBJECT_FOR_MAJOR_MED_INS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_MAJOR_MED_INS',
                       prev_dim.ISR_EXEMPT_FOR_MAJOR_MED_INS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_REST_COUPONS',
                       prev_dim.ISR_SUBJECT_FOR_REST_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_REST_COUPONS',
                       prev_dim.ISR_EXEMPT_FOR_REST_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_GAS_COUPONS',
                       prev_dim.ISR_SUBJECT_FOR_GAS_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_GAS_COUPONS',
                       prev_dim.ISR_EXEMPT_FOR_GAS_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_UNI_COUPONS',
                       prev_dim.ISR_SUBJECT_FOR_UNI_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_UNI_COUPONS',
                       prev_dim.ISR_EXEMPT_FOR_UNI_COUPONS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_RENTAL_AID',
                       prev_dim.ISR_SUBJECT_FOR_RENTAL_AID, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_RENTAL_AID',
                       prev_dim.ISR_EXEMPT_FOR_RENTAL_AID, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_EDU_AID',
                       prev_dim.ISR_SUBJECT_FOR_EDU_AID, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_EDU_AID',
                       prev_dim.ISR_EXEMPT_FOR_EDU_AID, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_GLASSES_AID',
                       prev_dim.ISR_SUBJECT_FOR_GLASSES_AID, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_GLASSES_AID',
                       prev_dim.ISR_EXEMPT_FOR_GLASSES_AID, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_TRANS_AID',
                       prev_dim.ISR_SUBJECT_FOR_TRANS_AID, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_TRANS_AID',
                       prev_dim.ISR_EXEMPT_FOR_TRANS_AID, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_UNION_PD_BY_ER',
                       prev_dim.ISR_SUBJECT_FOR_UNION_PD_BY_ER, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_UNION_PD_BY_ER',
                       prev_dim.ISR_EXEMPT_FOR_UNION_PD_BY_ER, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_DISAB_SUBSIDY',
                       prev_dim.ISR_SUBJECT_FOR_DISAB_SUBSIDY, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_DISAB_SUBSIDY',
                       prev_dim.ISR_EXEMPT_FOR_DISAB_SUBSIDY, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_FOR_CHILD_SCHOLAR',
                       prev_dim.ISR_SUBJECT_FOR_CHILD_SCHOLAR, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_CHILD_SCHOLAR',
                       prev_dim.ISR_EXEMPT_FOR_CHILD_SCHOLAR, 'EMP_BAL');
    populate_xml_table('PREV_ER_EARNINGS',
                       prev_dim.PREV_ER_EARNINGS, 'EMP_BAL');
    populate_xml_table('PREV_ER_EXEMPT_EARNINGS',
                       prev_dim.PREV_ER_EXEMPT_EARNINGS, 'EMP_BAL');
    populate_xml_table('ISR_SUBJECT_OTHER_INCOME',
                       prev_dim.ISR_SUBJECT_OTHER_INCOME, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_OTHER_INCOME',
                       prev_dim.ISR_EXEMPT_OTHER_INCOME, 'EMP_BAL');
    populate_xml_table('TOTAL_SUBJECT_EARNINGS',
                       prev_dim.TOTAL_SUBJECT_EARNINGS, 'EMP_BAL');
    populate_xml_table('TOTAL_EXEMPT_EARNINGS',
                       prev_dim.TOTAL_EXEMPT_EARNINGS, 'EMP_BAL');

      IF prev_dim.TAX_WITHHELD_IN_FISCAL_YEAR < 0 THEN
         prev_dim.TAX_WITHHELD_IN_FISCAL_YEAR :=0;
      END IF;

    populate_xml_table('TAX_WITHHELD_IN_FISCAL_YEAR',
                       prev_dim.TAX_WITHHELD_IN_FISCAL_YEAR, 'EMP_BAL');
    populate_xml_table('PREV_ER_ISR_WITHHELD',
                       prev_dim.PREV_ER_ISR_WITHHELD, 'EMP_BAL');
    populate_xml_table('CURRENT_FY_ARREARS',
                       prev_dim.CURRENT_FY_ARREARS, 'EMP_BAL');
    populate_xml_table('PREV_FY_ARREARS',
                       prev_dim.PREV_FY_ARREARS, 'EMP_BAL');
    populate_xml_table('CREDIT_TO_SALARY',
                       prev_dim.CREDIT_TO_SALARY, 'EMP_BAL');
    populate_xml_table('CREDIT_TO_SALARY_PAID',
                       prev_dim.CREDIT_TO_SALARY_PAID, 'EMP_BAL');
    populate_xml_table('SOCIAL_FORESIGHT_EARNINGS',
                       prev_dim.SOCIAL_FORESIGHT_EARNINGS, 'EMP_BAL');
    populate_xml_table('ISR_EXEMPT_FOR_SOC_FORESIGHT',
                       prev_dim.ISR_EXEMPT_FOR_SOC_FORESIGHT, 'EMP_BAL');
    populate_xml_table('SUM_SAL_WAGES_EARNINGS',
                       prev_dim.SUM_SAL_WAGES_EARNINGS, 'EMP_BAL');
    populate_xml_table('AMT_SUBSIDY_INCOME_PAID_EMP_FY ',
                       prev_dim.AMT_SUBSIDY_INCOME_PAID_EMP_FY, 'EMP_BAL');
    populate_xml_table('LOCAL_TAX_AMT_EARN_SAL_WAGES',
                       prev_dim.LOCAL_TAX_AMT_EARN_SAL_WAGES, 'EMP_BAL');
    populate_xml_table('AMT_SUBSIDY_EMPT_IN_FY',
                       prev_dim.AMT_SUBSIDY_EMPT_IN_FY, 'EMP_BAL');
    populate_xml_table('ISR_LOCAL_TAX_AMT_EARN_SAL_WAGES',
                       prev_dim.LOCAL_TAX_AMT_EARN_SAL_WAGES, 'SUMM_BAL');

      IF prev_dim.ISR_CALCULATED < 0 THEN
         prev_dim.ISR_CALCULATED :=0;
      END IF;

    populate_xml_table('ISR_CALCULATED', prev_dim.ISR_CALCULATED, 'SUMM_BAL');
    populate_xml_table('ISR_CREDITABLE_SUBSIDY',
                       prev_dim.ISR_CREDITABLE_SUBSIDY, 'SUMM_BAL');
    populate_xml_table('ISR_NON_CREDITABLE_SUBSIDY',
                       prev_dim.ISR_NON_CREDITABLE_SUBSIDY, 'SUMM_BAL');
    populate_xml_table('ISR_ON_CUMULATIVE_EARNINGS',
                       prev_dim.ISR_ON_CUMULATIVE_EARNINGS, 'SUMM_BAL');
    populate_xml_table('ISR_ON_NON_CUMULATIVE_EARNINGS',
                       prev_dim.ISR_ON_NON_CUMULATIVE_EARNINGS, 'SUMM_BAL');
    populate_xml_table('ISR_SUBSIDY_EMPT_PAID_TO_EMP',
                       prev_dim.ISR_SUBSIDY_EMPT_PAID_TO_EMP, 'SUMM_BAL');
    populate_xml_table('ISR_SUBSIDY_INC_PAID_EMP',
                       prev_dim.ISR_SUBSIDY_INC_PAID_EMP, 'SUMM_BAL');
    populate_xml_table('TAX_SUBSIDY_PCT', prev_dim.TAX_SUBSIDY_PCT,'TEXT');
    populate_xml_table('TAX_SUBSIDY_PCT_I', prev_dim.TAX_SUBSIDY_PCT_I, 'TEXT');
    populate_xml_table('TAX_SUBSIDY_PCT_D', prev_dim.TAX_SUBSIDY_PCT_D, 'TEXT');
    populate_xml_table('SUBSIDY_PORTION_APPLIED',
                       prev_dim.SUBSIDY_PORTION_APPLIED, 'TEXT');
    populate_xml_table('SUBSIDY_PORTION_APPLIED_I',
                       prev_dim.SUBSIDY_PORTION_APPLIED_I, 'TEXT');
    populate_xml_table('SUBSIDY_PORTION_APPLIED_D',
                       prev_dim.SUBSIDY_PORTION_APPLIED_D, 'TEXT');
    populate_xml_table('TOT_EARNING_ASSI_CONCEPTS',
                       prev_dim.TOT_EARNING_ASSI_CONCEPTS, 'TEXT');
    populate_xml_table('EMPLOYEE_STATE_TAX_WITHHELD',
                       prev_dim.EMPLOYEE_STATE_TAX_WITHHELD, 'TEXT');
    populate_xml_table('TOT_EXEMPT_EARNINGS',
                       prev_dim.TOT_EXEMPT_EARNINGS, 'TEXT');
    populate_xml_table('TOT_NON_CUMULATIVE_EARNINGS',
                       prev_dim.TOT_NON_CUMULATIVE_EARNINGS, 'TEXT');
    populate_xml_table('TOT_CUMULATIVE_EARNINGS',
                       prev_dim.TOT_CUMULATIVE_EARNINGS, 'TEXT');
    populate_xml_table('CREDITABLE_SUBSIDY_FRACTIONIII',
                       prev_dim.CREDITABLE_SUBSIDY_FRACTIONIII, 'TEXT');
    populate_xml_table('CREDITABLE_SUBSIDY_FRACTIONIV',
                       prev_dim.CREDITABLE_SUBSIDY_FRACTIONIV, 'TEXT');
    populate_xml_table('TAX_ON_INCOME_FISCAL_YEAR',
                       prev_dim.TAX_ON_INCOME_FISCAL_YEAR, 'TEXT');
    populate_xml_table('ISR_TAX_WITHHELD',
                       prev_dim.ISR_TAX_WITHHELD, 'TEXT');
    populate_xml_table('TOTAL_EARNINGS', prev_dim.TOTAL_EARNINGS, 'TEXT');
    populate_xml_table('ER_RFC_ID', prev_dim.ER_RFC_ID, 'TEXT');
    populate_xml_table('ER_LEGAL_NAME', prev_dim.ER_LEGAL_NAME, 'TEXT');
    populate_xml_table('ER_LEGAL_REP_NAMES',
                       prev_dim.ER_LEGAL_REP_NAMES, 'TEXT');
    populate_xml_table('ER_LEGAL_REP_RFC_ID',
                       prev_dim.ER_LEGAL_REP_RFC_ID, 'TEXT');
    populate_xml_table('ER_LEGAL_REP_CURP', prev_dim.ER_LEGAL_REP_CURP, 'TEXT');
    populate_xml_table('ER_TAX_SUBSIDY_PCT',
                       prev_dim.ER_TAX_SUBSIDY_PCT, 'TEXT');
    populate_xml_table('FISCAL_YEAR_REPORTING',
                       prev_dim.FISCAL_YEAR_REPORTING, 'TEXT');
    populate_xml_table('FULL_NAME', prev_dim.FULL_NAME, 'TEXT');
    populate_xml_table('REHIRE_FLAG', prev_dim.REHIRE_FLAG, 'TEXT');
    /* Bug#9273001: New fields in 2009 Update */
    populate_xml_table('VOLUNTARY_CONTRIBUTIONS_EE', prev_dim.VOLUNTARY_CONTRIBUTIONS_EE, 'TEXT');
    populate_xml_table('VOLUNTARY_CONTRIBUTIONS_ER', prev_dim.VOLUNTARY_CONTRIBUTIONS_ER, 'TEXT');
    populate_xml_table('VOLUNTARY_CONTRIBUTIONS_TOTAL', prev_dim.VOLUNTARY_CONTRIBUTIONS_TOTAL, 'TEXT');
    populate_xml_table('TOT_DED_VOL_CONTRIBUTION', prev_dim.TOT_DED_VOL_CONTRIBUTION, 'TEXT');
    populate_xml_table('ER_VOL_CONTR_FLAG', prev_dim.ER_VOL_CONTR_FLAG, 'TEXT');
    /* Bug#9273001: New fields in 2009 Update */

    IF ( ( gn_sep_bal + gn_ass_bal + gn_emp_bal ) > 0 ) THEN

       FOR i IN dim_xml_tbl.FIRST..dim_xml_tbl.LAST LOOP

         IF ( dim_xml_tbl(i).name = 'SEP_EARNINGS' AND
              gn_sep_bal > 0 ) THEN

            dim_xml_tbl(i).value := '1';

         ELSIF ( dim_xml_tbl(i).name = 'ASSIMILATED_SALARIES' AND
                 gn_ass_bal > 0 ) THEN

            dim_xml_tbl(i).value := '1';

         ELSIF ( dim_xml_tbl(i).name = 'ER_PAYMENT_TO_EE' AND
                 gn_emp_bal > 0 ) THEN

            dim_xml_tbl(i).value := '1';

         END IF;

       END LOOP;

    END IF;

    IF gn_success_fail = 0 THEN
       load_xml_internal('CS','SUCCESS',NULL);
    ELSE
       load_xml_internal('CS','FAIL',NULL);
    END IF;

    --load_xml_internal('CS','EMPLOYEE',NULL);

    FOR i IN dim_xml_tbl.FIRST..dim_xml_tbl.LAST LOOP

      load_xml_internal('D', dim_xml_tbl(i).name, dim_xml_tbl(i).value);

    END LOOP;

    --load_xml_internal('CE','EMPLOYEE',NULL);

    IF gn_success_fail = 0 THEN
       load_xml_internal('CE','SUCCESS',NULL);
    ELSE
       load_xml_internal('CE','FAIL',NULL);
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
  EXCEPTION
    WHEN OTHERS THEN
        hr_utility_trace (SQLERRM);
        RAISE;
  END GENERATE_XML;


  /****************************************************************************
    Name        : GENERATE_XML_HEADER
    Description : This procedure generates XML header information and appends to
                  pay_mag_tape.g_blob_value.
  *****************************************************************************/
  PROCEDURE generate_xml_header AS
    l_proc_name varchar2(100);
    lv_buf      varchar2(2000);
  BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML_HEADER';
    hr_utility_trace ('Entering '||l_proc_name);

    hr_utility_trace ('Root XML tag = '||
                    pay_magtape_generic.get_parameter_value('ROOT_XML_TAG'));

    lv_buf := pay_magtape_generic.get_parameter_value('ROOT_XML_TAG');

    write_to_magtape_lob (lv_buf);

    hr_utility_trace ('Leaving '||l_proc_name);
  END generate_xml_header;


  /****************************************************************************
    Name        : GENERATE_XML_FOOTER
    Description : This procedure generates XML information for GRE and the final
                  closing tag. Final result is appended to
                  pay_mag_tape.g_blob_value.
  *****************************************************************************/
  PROCEDURE generate_xml_footer AS

    lt_act_info_id      pay_payroll_xml_extract_pkg.int_tab_type;
    ln_pact_id          number;
    l_xml               BLOB;
    l_proc_name         varchar2(100);
    ln_chars            number;
    ln_offset           number;
    lv_buf              varchar2(8000);
    lr_xml              RAW (32767);
    ln_amt              number;
  BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML_FOOTER';
    hr_utility_trace ('Entering '||l_proc_name);

    lv_buf := '</' ||
              SUBSTR(pay_magtape_generic.get_parameter_value('ROOT_XML_TAG'),
                     2);

    write_to_magtape_lob (lv_buf);


    hr_utility_trace ('Leaving '||l_proc_name);
  END generate_xml_footer;

BEGIN
    --hr_utility.trace_on(null, 'PAYMXDIM');
    g_proc_name := 'PAY_MX_DIM_MAG.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'MX_DIM_MAG';
END PAY_MX_DIM_MAG;

/
