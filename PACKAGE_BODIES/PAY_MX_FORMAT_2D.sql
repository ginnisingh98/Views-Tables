--------------------------------------------------------
--  DDL for Package Body PAY_MX_FORMAT_2D
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_FORMAT_2D" AS
/* $Header: paymxformat2d.pkb 120.0.12000000.1 2007/02/22 16:25:13 vmehta noship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_mx_format_2d
    Package File Name   : paymxformat2d.pkb

    Description : Used for FORMAT2D Interface Extract

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ----------------------------------
    nragavar      09-Nov-2006 115.0           Initial Version
    vpandya       17-Nov-2006 115.1           Changed c_min_wage cursor.
    vpandya       28-Nov-2006 115.2   5685714 Changed cursor c_format2d_rec for
                                              TOTAL_DAYS_WORKED
    vpandya       05-Dec-2006 115.3   5699267 Changed generate_xml_footer:
                                              Removed condition to print null if
                                              value is zero. Now it will print
                                              zero.
    vpandya       05-Dec-2006 115.4   5699267 Changed generate_xml_footer:
                                              Added NVL to all columns to print
                                              0 if level is zero.
    vpandya       10-Dec-2006 115.5   5704405 Changed action_creation to change
                                              order by clause so that asg act
                                              getting created appropriately.
                                              Changed generate_xml: assigning
                                              person id to ln_person_id.
    ==========================================================================*/

--
-- Global Variables
--


  format2d_xml_tbl          xml_tbl;

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
/*
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
*/
    ln_index := format2d_xml_tbl.COUNT;

    format2d_xml_tbl(ln_index).name  := name;
    format2d_xml_tbl(ln_index).value := value;

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
      SELECT DISTINCT paa_arch.serial_number
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
         ORDER BY serial_number';

    hr_utility_trace ('Range cursor query : ' || p_sqlstr);
    hr_utility_trace ('Leaving '||l_proc_name);

  END range_cursor;


  /****************************************************************************
    Name        : ACTION_CREATION
    Description : This procedure creates assignment actions for
                  Format-2D process.
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
                paa_arch.assignment_action_id desc;

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
                paa_arch.assignment_action_id desc;

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
                               p_report_type      => 'FORMAT2D_MAG'
                              ,p_report_format    => 'FORMAT2D_MAG'
                              ,p_report_qualifier => 'FORMAT2D_MAG'
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

    CURSOR c_format2d_rec (cp_assignment_action_id number) IS
      SELECT format2d.person_id PERSON_ID
            ,to_char(fnd_date.canonical_to_date(start_month),'mm') START_MONTH
            ,to_char(fnd_date.canonical_to_date(end_month),'mm')   END_MONTH
            ,replace(ER_RFC_ID,'-','')  ER_RFC_ID
            ,CURP
            ,ltrim(rtrim(PATERNAL_LAST_NAME)) PATERNAL_LAST_NAME
            ,ltrim(rtrim(MATERNAL_LAST_NAME)) MATERNAL_LAST_NAME
            ,ltrim(rtrim(NAMES)) NAMES
            ,ltrim(rtrim(PATERNAL_LAST_NAME))||' '||
                   ltrim(rtrim(MATERNAL_LAST_NAME))||' '||
                   ltrim(rtrim(NAMES)) NAME
            ,0 WAGE_LEVEL
            ,(fnd_date.canonical_to_date(end_month) -
               fnd_date.canonical_to_date(start_month)) + 1  TOTAL_DAYS_WORKED
            ,(ISR_SUBJECT_FOR_FIXED_EARNINGS +
                         ISR_EXEMPT_FOR_FIXED_EARNINGS) SAL_WAGES
            ,nvl(ISR_SUBJECT_FOR_OVERTIME,0) +
                         nvl(ISR_EXEMPT_FOR_OVERTIME,0) OVERTIME
            ,nvl(ISR_SUBJECT_FOR_PROFIT_SHARING,0) +
                         nvl(ISR_EXEMPT_FOR_PROFIT_SHARING,0) PROFIT_SHARING
            ,nvl(ISR_SUBJECT_FOR_XMAS_BONUS,0)  +
                         nvl(ISR_EXEMPT_FOR_XMAS_BONUS,0) CHRISTMAS_BONUS
            ,nvl(ISR_SUBJECT_FOR_VAC_PREMIUM,0) +
                         nvl(ISR_EXEMPT_FOR_VAC_PREMIUM,0) VACATION_PREMIUM
            ,nvl(ISR_SUBJECT_FOR_SAVINGS_FUND,0) +
                         nvl(ISR_EXEMPT_FOR_SAVINGS_FUND,0) SAVING_FUND
            ,AID_FOR_PANTRY_AND_FOOD
            ,nvl(ISR_SUBJECT_FOR_TRANS_AID,0) +
                         nvl(ISR_EXEMPT_FOR_TRANS_AID,0) TRANSPORTATION_AID
            ,0 OTHER_EARNINGS
            ,nvl(TOTAL_SUBJECT_EARNINGS,0)+
                         nvl(TOTAL_EXEMPT_EARNINGS,0) TOTAL_EARNINGS
        FROM pay_mx_isr_tax_format37_v format2d
            ,pay_assignment_actions paa
            ,pay_action_interlocks pai
       WHERE format2d.payroll_action_id    = paa.payroll_action_id
         AND format2d.person_id            = to_number(paa.serial_number)
         AND paa.assignment_action_id = pai.locked_action_id
         AND pai.locking_action_id    = cp_assignment_action_id
       ORDER BY effective_date DESC;

    CURSOR c_min_wage( cp_effective_date IN DATE ) IS
      select legislation_info2
      from   PAY_MX_LEGISLATION_INFO_F
      where  LEGISLATION_INFO_TYPE = 'MX Minimum Wage Information'
      and    effective_start_date = cp_effective_date
      and    legislation_info1 = 'GMW';

    CURSOR c_pact_id (cp_assignment_action_id NUMBER) IS
      SELECT paa.payroll_action_id
        FROM pay_assignment_actions paa
       WHERE paa.assignment_action_id = cp_assignment_action_id;

    l_proc_name          varchar2(100);
    l_xml                BLOB;
    lb_person_processed  boolean;

    ln_assignment_action_id  NUMBER;
    ln_person_id             NUMBER;
    ln_business_group_id     NUMBER;
    ln_payroll_action_id     NUMBER;

    format2d         c_format2d_rec%ROWTYPE;
    prev_format2d    c_format2d_rec%ROWTYPE;
    ln_min_wage      NUMBER;
    ln_avg_daily_sal NUMBER;
    lv_level         VARCHAR2(10);
    ln_count         NUMBER;
    ln_session_id    NUMBER;

  BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML';
    hr_utility_trace ('Entering '||l_proc_name);

    ln_assignment_action_id := pay_magtape_generic.get_parameter_value
                                                   ('TRANSFER_ACT_ID');

    hr_utility_trace ('Fetching transactions for magtape asg action '||
                                               ln_assignment_action_id);

    format2d_xml_tbl.DELETE;

    gn_success_fail  := 0;
    gn_sep_bal       := 0;
    gn_ass_bal       := 0;
    gn_emp_bal       := 0;
    ln_avg_daily_sal := 0;
    lv_level         := '0';

    ln_person_id    := -1;

    SELECT fnd_global.local_chr(13) || fnd_global.local_chr(10)
      INTO EOL
      FROM dual;

    OPEN  c_pact_id( ln_assignment_action_id );
    FETCH c_pact_id INTO ln_payroll_action_id;
    CLOSE c_pact_id;

    IF gn_legal_er_id IS NULL THEN

       get_payroll_action_info (ln_payroll_action_id
                               ,gd_effective_date
                               ,gn_business_group_id
                               ,gn_legal_er_id);

    END IF;

    OPEN  c_format2d_rec(ln_assignment_action_id);

    LOOP

      FETCH c_format2d_rec INTO format2d;
      EXIT WHEN c_format2d_rec%NOTFOUND;

      IF ln_person_id = -1 THEN
         prev_format2d := format2d;
         ln_person_id  := format2d.person_id;
      ELSE

         if format2d.total_earnings <> format2d.profit_sharing then

               prev_format2d.TOTAL_DAYS_WORKED :=
                                prev_format2d.TOTAL_DAYS_WORKED +
                                format2d.TOTAL_DAYS_WORKED;
         end if;

         prev_format2d.SAL_WAGES := prev_format2d.SAL_WAGES +
                                                  format2d.SAL_WAGES;
         prev_format2d.OVERTIME := prev_format2d.OVERTIME +
                                        format2d.OVERTIME;
         prev_format2d.PROFIT_SHARING := prev_format2d.PROFIT_SHARING +
                                              format2d.PROFIT_SHARING;
         prev_format2d.CHRISTMAS_BONUS := prev_format2d.CHRISTMAS_BONUS +
                                               format2d.CHRISTMAS_BONUS;
         prev_format2d.VACATION_PREMIUM := prev_format2d.VACATION_PREMIUM +
                                                format2d.VACATION_PREMIUM;
         prev_format2d.SAVING_FUND := prev_format2d.SAVING_FUND +
                                             format2d.SAVING_FUND;
         prev_format2d.AID_FOR_PANTRY_AND_FOOD :=
                                      prev_format2d.AID_FOR_PANTRY_AND_FOOD +
                                           format2d.AID_FOR_PANTRY_AND_FOOD;
         prev_format2d.TRANSPORTATION_AID :=
                               prev_format2d.TRANSPORTATION_AID +
                                    format2d.TRANSPORTATION_AID;
         prev_format2d.OTHER_EARNINGS := prev_format2d.OTHER_EARNINGS +
                                              format2d.OTHER_EARNINGS;
         prev_format2d.TOTAL_EARNINGS := prev_format2d.TOTAL_EARNINGS +
                                              format2d.TOTAL_EARNINGS;

      END IF;

    END LOOP;
    CLOSE c_format2d_rec;

    OPEN  c_min_wage(gd_effective_date);
    FETCH c_min_wage INTO ln_min_wage;
    CLOSE c_min_wage;

    if prev_format2d.TOTAL_DAYS_WORKED <> 0 THEN
       ln_avg_daily_sal := prev_format2d.TOTAL_EARNINGS /
                                               prev_format2d.TOTAL_DAYS_WORKED;
    else
       ln_avg_daily_sal := prev_format2d.TOTAL_EARNINGS;
    end if;

    if ln_avg_daily_sal > ln_min_wage * 10 THEN
       lv_level := '5';
    elsif  ln_avg_daily_sal > ln_min_wage * 5 THEN
       lv_level := '4';
    elsif  ln_avg_daily_sal > ln_min_wage * 3 THEN
       lv_level := '3';
    elsif  ln_avg_daily_sal > ln_min_wage  THEN
       lv_level := '2';
    else
       lv_level := '1';
    end if;

    prev_format2d.OTHER_EARNINGS := prev_format2d.TOTAL_EARNINGS -
                                    (prev_format2d.SAL_WAGES +
                                     prev_format2d.OVERTIME +
                                     prev_format2d.PROFIT_SHARING +
                                     prev_format2d.CHRISTMAS_BONUS +
                                     prev_format2d.VACATION_PREMIUM +
                                     prev_format2d.SAVING_FUND +
                                     prev_format2d.AID_FOR_PANTRY_AND_FOOD +
                                     prev_format2d.TRANSPORTATION_AID
                                    );


    --populate_xml_table('RFC_ID', prev_format2d.ER_RFC_ID,'TEXT');
    populate_xml_table('CURP', prev_format2d.CURP,'TEXT');
    populate_xml_table('NAME', prev_format2d.NAME,'TEXT');
    populate_xml_table('LEVEL', lv_level,'TEXT');
    populate_xml_table('TOTAL_DAYS_WORKED',
                        prev_format2d.TOTAL_DAYS_WORKED,'TEXT');
    populate_xml_table('SAL_WAGES',
                        prev_format2d.SAL_WAGES,'TEXT');
    populate_xml_table('OVERTIME',
                        prev_format2d.OVERTIME,'TEXT');
    populate_xml_table('PROFIT_SHARING',
                        prev_format2d.PROFIT_SHARING,'TEXT');
    populate_xml_table('CHRISTMAS_BONUS',
                        prev_format2d.CHRISTMAS_BONUS,'TEXT');
    populate_xml_table('VACATION_PREMIUM',
                        prev_format2d.VACATION_PREMIUM,'TEXT');
    populate_xml_table('SAVING_FUND',
                        prev_format2d.SAVING_FUND,'TEXT');
    populate_xml_table('AID_FOR_PANTRY_AND_FOOD',
                        prev_format2d.AID_FOR_PANTRY_AND_FOOD,'TEXT');
    populate_xml_table('TRANSPORTATION_AID',
                        prev_format2d.TRANSPORTATION_AID,'TEXT');
    populate_xml_table('OTHER_EARNINGS',
                        prev_format2d.OTHER_EARNINGS,'TEXT');
    populate_xml_table('TOTAL_EARNINGS',
                        prev_format2d.TOTAL_EARNINGS,'TEXT');


    load_xml_internal('CS','FORMAT_2D',NULL);

    FOR i IN format2d_xml_tbl.FIRST..format2d_xml_tbl.LAST LOOP

      load_xml_internal('D',format2d_xml_tbl(i).name,format2d_xml_tbl(i).value);

    END LOOP;

    load_xml_internal('CE','FORMAT_2D',NULL);

    ln_session_id := USERENV('sessionid');

    SELECT COUNT(*)
      INTO ln_count
      FROM pay_us_rpt_totals
     WHERE tax_unit_id = ln_payroll_action_id
       AND session_id  = ln_session_id;


    IF ln_count = 0 THEN

       INSERT INTO pay_us_rpt_totals ( session_id
                                      ,business_group_id
                                      ,tax_unit_id
                                      ,organization_name )
       VALUES ( ln_session_id
               ,gn_business_group_id
               ,ln_payroll_action_id
               ,prev_format2d.er_rfc_id );

    END IF;

    IF lv_level = '1' THEN

       UPDATE pay_us_rpt_totals
          SET value1  = NVL(value1,0)  + 1  -- No. of Employees
             ,value6  = NVL(value6,0)  + prev_format2d.SAL_WAGES
             ,value11 = NVL(value11,0) + prev_format2d.OVERTIME
             ,value16 = NVL(value16,0) + prev_format2d.PROFIT_SHARING
             ,value21 = NVL(value21,0) + prev_format2d.CHRISTMAS_BONUS
             ,value26 = NVL(value26,0) + prev_format2d.VACATION_PREMIUM
             ,attribute1 = NVL(attribute1,'0') + prev_format2d.SAVING_FUND
             ,attribute6 = NVL(attribute6,'0') +
                                     prev_format2d.AID_FOR_PANTRY_AND_FOOD
             ,attribute11 = NVL(attribute11,'0') +
                                     prev_format2d.TRANSPORTATION_AID
             ,attribute16 = NVL(attribute16,'0') +
                                     prev_format2d.OTHER_EARNINGS
             ,attribute21 = NVL(attribute21,'0') +
                                     prev_format2d.TOTAL_EARNINGS
        WHERE tax_unit_id = ln_payroll_action_id
          AND session_id  = ln_session_id;

    ELSIF lv_level = '2' THEN

       UPDATE pay_us_rpt_totals
          SET value2  = NVL(value2,0)  + 1  -- No. of Employees
             ,value7  = NVL(value7,0)  + prev_format2d.SAL_WAGES
             ,value12 = NVL(value12,0) + prev_format2d.OVERTIME
             ,value17 = NVL(value17,0) + prev_format2d.PROFIT_SHARING
             ,value22 = NVL(value22,0) + prev_format2d.CHRISTMAS_BONUS
             ,value27 = NVL(value27,0) + prev_format2d.VACATION_PREMIUM
             ,attribute2 = NVL(attribute2,'0') + prev_format2d.SAVING_FUND
             ,attribute7 = NVL(attribute7,'0') +
                                     prev_format2d.AID_FOR_PANTRY_AND_FOOD
             ,attribute12 = NVL(attribute12,'0') +
                                     prev_format2d.TRANSPORTATION_AID
             ,attribute17 = NVL(attribute17,'0') +
                                     prev_format2d.OTHER_EARNINGS
             ,attribute22 = NVL(attribute22,'0') +
                                     prev_format2d.TOTAL_EARNINGS
        WHERE tax_unit_id = ln_payroll_action_id
          AND session_id  = ln_session_id;


    ELSIF lv_level = '3' THEN

       UPDATE pay_us_rpt_totals
          SET value3  = NVL(value3,0)  + 1  -- No. of Employees
             ,value8  = NVL(value8,0)  + prev_format2d.SAL_WAGES
             ,value13 = NVL(value13,0) + prev_format2d.OVERTIME
             ,value18 = NVL(value18,0) + prev_format2d.PROFIT_SHARING
             ,value23 = NVL(value23,0) + prev_format2d.CHRISTMAS_BONUS
             ,value28 = NVL(value28,0) + prev_format2d.VACATION_PREMIUM
             ,attribute3 = NVL(attribute3,'0') + prev_format2d.SAVING_FUND
             ,attribute8 = NVL(attribute8,'0') +
                                     prev_format2d.AID_FOR_PANTRY_AND_FOOD
             ,attribute13 = NVL(attribute13,'0') +
                                     prev_format2d.TRANSPORTATION_AID
             ,attribute18 = NVL(attribute18,'0') +
                                     prev_format2d.OTHER_EARNINGS
             ,attribute23 = NVL(attribute23,'0') +
                                     prev_format2d.TOTAL_EARNINGS
        WHERE tax_unit_id = ln_payroll_action_id
          AND session_id  = ln_session_id;


    ELSIF lv_level = '4' THEN

       UPDATE pay_us_rpt_totals
          SET value4  = NVL(value4,0)  + 1  -- No. of Employees
             ,value9  = NVL(value9,0)  + prev_format2d.SAL_WAGES
             ,value14 = NVL(value14,0) + prev_format2d.OVERTIME
             ,value19 = NVL(value19,0) + prev_format2d.PROFIT_SHARING
             ,value24 = NVL(value24,0) + prev_format2d.CHRISTMAS_BONUS
             ,value29 = NVL(value29,0) + prev_format2d.VACATION_PREMIUM
             ,attribute4 = NVL(attribute4,'0') + prev_format2d.SAVING_FUND
             ,attribute9 = NVL(attribute9,'0') +
                                     prev_format2d.AID_FOR_PANTRY_AND_FOOD
             ,attribute14 = NVL(attribute14,'0') +
                                     prev_format2d.TRANSPORTATION_AID
             ,attribute19 = NVL(attribute19,'0') +
                                     prev_format2d.OTHER_EARNINGS
             ,attribute24 = NVL(attribute24,'0') +
                                     prev_format2d.TOTAL_EARNINGS
        WHERE tax_unit_id = ln_payroll_action_id
          AND session_id  = ln_session_id;


    ELSIF lv_level = '5' THEN

       UPDATE pay_us_rpt_totals
          SET value5  = NVL(value5,0)  + 1  -- No. of Employees
             ,value10 = NVL(value10,0) + prev_format2d.SAL_WAGES
             ,value15 = NVL(value15,0) + prev_format2d.OVERTIME
             ,value20 = NVL(value20,0) + prev_format2d.PROFIT_SHARING
             ,value25 = NVL(value25,0) + prev_format2d.CHRISTMAS_BONUS
             ,value30 = NVL(value30,0) + prev_format2d.VACATION_PREMIUM
             ,attribute5 = NVL(attribute5,'0') + prev_format2d.SAVING_FUND
             ,attribute10 = NVL(attribute10,'0') +
                                     prev_format2d.AID_FOR_PANTRY_AND_FOOD
             ,attribute15 = NVL(attribute15,'0') +
                                     prev_format2d.TRANSPORTATION_AID
             ,attribute20 = NVL(attribute20,'0') +
                                     prev_format2d.OTHER_EARNINGS
             ,attribute25 = NVL(attribute25,'0') +
                                     prev_format2d.TOTAL_EARNINGS
        WHERE tax_unit_id = ln_payroll_action_id
          AND session_id  = ln_session_id;


    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);

  /*EXCEPTION
    WHEN OTHERS THEN
        hr_utility_trace (SQLERRM);
        RAISE; */
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

    CURSOR c_format_2d_totals ( cp_payroll_action_id IN NUMBER) IS
      select organization_name RFC_ID
            ,NVL(SUM(value1),0) NO_OF_EMPLOYEES_280042
            ,NVL(SUM(value2),0) NO_OF_EMPLOYEES_280043
            ,NVL(SUM(value3),0) NO_OF_EMPLOYEES_280044
            ,NVL(SUM(value4),0) NO_OF_EMPLOYEES_280045
            ,NVL(SUM(value5),0) NO_OF_EMPLOYEES_280046
            ,NVL(SUM(value6),0) SAL_WAGES_280047
            ,NVL(SUM(value7),0) SAL_WAGES_280057
            ,NVL(SUM(value8),0) SAL_WAGES_280067
            ,NVL(SUM(value9),0) SAL_WAGES_280077
            ,NVL(SUM(value10),0) SAL_WAGES_280087
            ,NVL(SUM(value11),0) OVERTIME_280048
            ,NVL(SUM(value12),0) OVERTIME_280058
            ,NVL(SUM(value13),0) OVERTIME_280068
            ,NVL(SUM(value14),0) OVERTIME_280078
            ,NVL(SUM(value15),0) OVERTIME_280088
            ,NVL(SUM(value16),0) PROFIT_SHARING_280049
            ,NVL(SUM(value17),0) PROFIT_SHARING_280059
            ,NVL(SUM(value18),0) PROFIT_SHARING_280069
            ,NVL(SUM(value19),0) PROFIT_SHARING_280079
            ,NVL(SUM(value20),0) PROFIT_SHARING_280089
            ,NVL(SUM(value21),0) CHRISTMAS_BONUS_280050
            ,NVL(SUM(value22),0) CHRISTMAS_BONUS_280060
            ,NVL(SUM(value23),0) CHRISTMAS_BONUS_280070
            ,NVL(SUM(value24),0) CHRISTMAS_BONUS_280080
            ,NVL(SUM(value25),0) CHRISTMAS_BONUS_280090
            ,NVL(SUM(value26),0) VACATION_PREMIUM_280051
            ,NVL(SUM(value27),0) VACATION_PREMIUM_280061
            ,NVL(SUM(value28),0) VACATION_PREMIUM_280071
            ,NVL(SUM(value29),0) VACATION_PREMIUM_280081
            ,NVL(SUM(value30),0) VACATION_PREMIUM_280091
            ,NVL(SUM(attribute1),0) SAVING_FUND_280052
            ,NVL(SUM(attribute2),0) SAVING_FUND_280062
            ,NVL(SUM(attribute3),0) SAVING_FUND_280072
            ,NVL(SUM(attribute4),0) SAVING_FUND_280082
            ,NVL(SUM(attribute5),0) SAVING_FUND_280092
            ,NVL(SUM(attribute6),0) AID_FOR_PANTRY_AND_FOOD_280053
            ,NVL(SUM(attribute7),0) AID_FOR_PANTRY_AND_FOOD_280063
            ,NVL(SUM(attribute8),0) AID_FOR_PANTRY_AND_FOOD_280073
            ,NVL(SUM(attribute9),0) AID_FOR_PANTRY_AND_FOOD_280083
            ,NVL(SUM(attribute10),0) AID_FOR_PANTRY_AND_FOOD_280093
            ,NVL(SUM(attribute11),0) TRANSPORTATION_AID_280054
            ,NVL(SUM(attribute12),0) TRANSPORTATION_AID_280064
            ,NVL(SUM(attribute13),0) TRANSPORTATION_AID_280074
            ,NVL(SUM(attribute14),0) TRANSPORTATION_AID_280084
            ,NVL(SUM(attribute15),0) TRANSPORTATION_AID_280094
            ,NVL(SUM(attribute16),0) OTHER_EARNINGS_280055
            ,NVL(SUM(attribute17),0) OTHER_EARNINGS_280065
            ,NVL(SUM(attribute18),0) OTHER_EARNINGS_280075
            ,NVL(SUM(attribute19),0) OTHER_EARNINGS_280085
            ,NVL(SUM(attribute20),0) OTHER_EARNINGS_280095
            ,NVL(SUM(attribute21),0) TOTAL_EARNINGS_280056
            ,NVL(SUM(attribute22),0) TOTAL_EARNINGS_280066
            ,NVL(SUM(attribute23),0) TOTAL_EARNINGS_280076
            ,NVL(SUM(attribute24),0) TOTAL_EARNINGS_280086
            ,NVL(SUM(attribute25),0) TOTAL_EARNINGS_280096
        FROM pay_us_rpt_totals
       WHERE tax_unit_id = cp_payroll_action_id
       GROUP by organization_name;

    lt_act_info_id       pay_payroll_xml_extract_pkg.int_tab_type;
    ln_payroll_action_id NUMBER;
    l_xml                BLOB;
    l_proc_name          VARCHAR2(100);
    ln_chars             NUMBER;
    ln_offset            NUMBER;
    lv_buf               VARCHAR2(8000);
    lr_xml               RAW (32767);
    ln_amt               NUMBER;

    f2d_tot              c_format_2d_totals%ROWTYPE;

  BEGIN

    l_proc_name := g_proc_name || 'GENERATE_XML_FOOTER';

    hr_utility_trace ('Entering '||l_proc_name);

    format2d_xml_tbl.DELETE;

    ln_payroll_action_id := pay_magtape_generic.get_parameter_value(
                                         'TRANSFER_PAYROLL_ACTION_ID');

    OPEN  c_format_2d_totals( ln_payroll_action_id );
    FETCH c_format_2d_totals INTO f2d_tot;
    CLOSE c_format_2d_totals;

    --populate_xml....for all 56 fields

    populate_xml_table('RFC_ID', f2d_tot.RFC_ID,'TEXT');
    populate_xml_table('NO_OF_EMPLOYEES_280042',
                                  f2d_tot.NO_OF_EMPLOYEES_280042,'TEXT');
    populate_xml_table('NO_OF_EMPLOYEES_280043',
                                  f2d_tot.NO_OF_EMPLOYEES_280043,'TEXT');
    populate_xml_table('NO_OF_EMPLOYEES_280044',
                                  f2d_tot.NO_OF_EMPLOYEES_280044,'TEXT');
    populate_xml_table('NO_OF_EMPLOYEES_280045',
                                  f2d_tot.NO_OF_EMPLOYEES_280045,'TEXT');
    populate_xml_table('NO_OF_EMPLOYEES_280046',
                                  f2d_tot.NO_OF_EMPLOYEES_280046,'TEXT');
    populate_xml_table('SAL_WAGES_280047', f2d_tot.SAL_WAGES_280047, 'TEXT');
    populate_xml_table('SAL_WAGES_280057', f2d_tot.SAL_WAGES_280057, 'TEXT');
    populate_xml_table('SAL_WAGES_280067', f2d_tot.SAL_WAGES_280067,'TEXT');
    populate_xml_table('SAL_WAGES_280077', f2d_tot.SAL_WAGES_280077,'TEXT');
    populate_xml_table('SAL_WAGES_280087', f2d_tot.SAL_WAGES_280087,'TEXT');
    populate_xml_table('OVERTIME_280048', f2d_tot.OVERTIME_280048,'TEXT');
    populate_xml_table('OVERTIME_280058', f2d_tot.OVERTIME_280058,'TEXT');
    populate_xml_table('OVERTIME_280068', f2d_tot.OVERTIME_280068,'TEXT');
    populate_xml_table('OVERTIME_280078', f2d_tot.OVERTIME_280078,'TEXT');
    populate_xml_table('OVERTIME_280088', f2d_tot.OVERTIME_280088,'TEXT');
    populate_xml_table('PROFIT_SHARING_280049',
                                  f2d_tot.PROFIT_SHARING_280049,'TEXT');
    populate_xml_table('PROFIT_SHARING_280059',
                                  f2d_tot.PROFIT_SHARING_280059,'TEXT');
    populate_xml_table('PROFIT_SHARING_280069',
                                  f2d_tot.PROFIT_SHARING_280069,'TEXT');
    populate_xml_table('PROFIT_SHARING_280079',
                                  f2d_tot.PROFIT_SHARING_280079,'TEXT');
    populate_xml_table('PROFIT_SHARING_280089',
                                  f2d_tot.PROFIT_SHARING_280089,'TEXT');
    populate_xml_table('CHRISTMAS_BONUS_280050',
                                  f2d_tot.CHRISTMAS_BONUS_280050,'TEXT');
    populate_xml_table('CHRISTMAS_BONUS_280060',
                                  f2d_tot.CHRISTMAS_BONUS_280060,'TEXT');
    populate_xml_table('CHRISTMAS_BONUS_280070',
                                  f2d_tot.CHRISTMAS_BONUS_280070,'TEXT');
    populate_xml_table('CHRISTMAS_BONUS_280080',
                                  f2d_tot.CHRISTMAS_BONUS_280080,'TEXT');
    populate_xml_table('CHRISTMAS_BONUS_280090',
                                  f2d_tot.CHRISTMAS_BONUS_280090,'TEXT');
    populate_xml_table('VACATION_PREMIUM_280051',
                                  f2d_tot.VACATION_PREMIUM_280051,'TEXT');
    populate_xml_table('VACATION_PREMIUM_280061',
                                  f2d_tot.VACATION_PREMIUM_280061,'TEXT');
    populate_xml_table('VACATION_PREMIUM_280071',
                                  f2d_tot.VACATION_PREMIUM_280071,'TEXT');
    populate_xml_table('VACATION_PREMIUM_280081',
                                  f2d_tot.VACATION_PREMIUM_280081,'TEXT');
    populate_xml_table('VACATION_PREMIUM_280091',
                                  f2d_tot.VACATION_PREMIUM_280091,'TEXT');
    populate_xml_table('SAVING_FUND_280052',
                                  f2d_tot.SAVING_FUND_280052,'TEXT');
    populate_xml_table('SAVING_FUND_280062',
                                  f2d_tot.SAVING_FUND_280062,'TEXT');
    populate_xml_table('SAVING_FUND_280072',
                                  f2d_tot.SAVING_FUND_280072,'TEXT');
    populate_xml_table('SAVING_FUND_280082',
                                  f2d_tot.SAVING_FUND_280082,'TEXT');
    populate_xml_table('SAVING_FUND_280092',
                                  f2d_tot.SAVING_FUND_280092,'TEXT');
    populate_xml_table('AID_FOR_PANTRY_AND_FOOD_280053',
                                 f2d_tot.AID_FOR_PANTRY_AND_FOOD_280053,'TEXT');
    populate_xml_table('AID_FOR_PANTRY_AND_FOOD_280063',
                                 f2d_tot.AID_FOR_PANTRY_AND_FOOD_280063,'TEXT');
    populate_xml_table('AID_FOR_PANTRY_AND_FOOD_280073',
                                 f2d_tot.AID_FOR_PANTRY_AND_FOOD_280073,'TEXT');
    populate_xml_table('AID_FOR_PANTRY_AND_FOOD_280083',
                                 f2d_tot.AID_FOR_PANTRY_AND_FOOD_280083,'TEXT');
    populate_xml_table('AID_FOR_PANTRY_AND_FOOD_280093',
                                 f2d_tot.AID_FOR_PANTRY_AND_FOOD_280093,'TEXT');
    populate_xml_table('TRANSPORTATION_AID_280054',
                                  f2d_tot.TRANSPORTATION_AID_280054,'TEXT');
    populate_xml_table('TRANSPORTATION_AID_280064',
                                  f2d_tot.TRANSPORTATION_AID_280064,'TEXT');
    populate_xml_table('TRANSPORTATION_AID_280074',
                                  f2d_tot.TRANSPORTATION_AID_280074,'TEXT');
    populate_xml_table('TRANSPORTATION_AID_280084',
                                  f2d_tot.TRANSPORTATION_AID_280084,'TEXT');
    populate_xml_table('TRANSPORTATION_AID_280094',
                                  f2d_tot.TRANSPORTATION_AID_280094,'TEXT');
    populate_xml_table('OTHER_EARNINGS_280055',
                                  f2d_tot.OTHER_EARNINGS_280055,'TEXT');
    populate_xml_table('OTHER_EARNINGS_280065',
                                  f2d_tot.OTHER_EARNINGS_280065,'TEXT');
    populate_xml_table('OTHER_EARNINGS_280075',
                                  f2d_tot.OTHER_EARNINGS_280075,'TEXT');
    populate_xml_table('OTHER_EARNINGS_280085',
                                  f2d_tot.OTHER_EARNINGS_280085,'TEXT');
    populate_xml_table('OTHER_EARNINGS_280095',
                                  f2d_tot.OTHER_EARNINGS_280095,'TEXT');
    populate_xml_table('TOTAL_EARNINGS_280056',
                                  f2d_tot.TOTAL_EARNINGS_280056,'TEXT');
    populate_xml_table('TOTAL_EARNINGS_280066',
                                  f2d_tot.TOTAL_EARNINGS_280066,'TEXT');
    populate_xml_table('TOTAL_EARNINGS_280076',
                                  f2d_tot.TOTAL_EARNINGS_280076,'TEXT');
    populate_xml_table('TOTAL_EARNINGS_280086',
                                  f2d_tot.TOTAL_EARNINGS_280086,'TEXT');
    populate_xml_table('TOTAL_EARNINGS_280096',
                                  f2d_tot.TOTAL_EARNINGS_280096,'TEXT');

    load_xml_internal('CS','FORMAT_2D_TOTAL',NULL);

    FOR i IN format2d_xml_tbl.FIRST..format2d_xml_tbl.LAST LOOP

      load_xml_internal('D',format2d_xml_tbl(i).name,format2d_xml_tbl(i).value);

    END LOOP;

    load_xml_internal('CE','FORMAT_2D_TOTAL',NULL);

    lv_buf := '</' ||
              SUBSTR(pay_magtape_generic.get_parameter_value('ROOT_XML_TAG'),
                     2);

    write_to_magtape_lob (lv_buf);

    DELETE FROM pay_us_rpt_totals
     WHERE tax_unit_id = ln_payroll_action_id;


    hr_utility_trace ('Leaving '||l_proc_name);
  END generate_xml_footer;

BEGIN
    --hr_utility.trace_on(null, 'PAYMX2D');
    g_proc_name := 'PAY_MX_FORMAT_2D.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'MX_FORMAT2D_MAG';
END PAY_MX_FORMAT_2D;

/
