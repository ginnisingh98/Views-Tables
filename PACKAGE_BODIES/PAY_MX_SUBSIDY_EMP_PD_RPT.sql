--------------------------------------------------------
--  DDL for Package Body PAY_MX_SUBSIDY_EMP_PD_RPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_SUBSIDY_EMP_PD_RPT" AS
/* $Header: paymxsubemplpaid.pkb 120.0.12010000.3 2009/06/01 11:35:16 sivanara noship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : PAY_MX_SUBSIDY_EMP_PD_RPT
    Package File Name   : paymxsubemprpt.pkb

    Description : Used for ISR Subsidy For Employment Paid Report

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ----------------------------------
    sivanara     07-JAN-2008 115.0            Initial Version
    sivanara     06-Feb-2008 115.1    8231096 Changed generate xml RFC id from
                                              ER to employee's.
    sivanara     09-Feb-2009 115.2    8240711 Multiple rows will be showed for
		                              re-hired employee.
    sivanara     10-Feb-2009 115.4   8248748  Modified generate_xml procedure
                                              to filter re-hire employee from
					      other LE.
    sivanara     17-Feb-2009 115.6   8240711  To cursor c_subemppaid_rec added
                                              assignment_action_id filter
					      condition for re-hire issue.
    sivanara     01-Jun-2009 115.7   8554088  Added code to generate_xml_header
                                              to populate global variable value
					      even in multi-thread mode.
    ==========================================================================*/

--
-- Global Variables
--


  subemppaid_xml_tbl          xml_tbl;

  g_proc_name          VARCHAR2(240);
  g_debug              BOOLEAN;
  g_document_type      VARCHAR2(50);
  gd_effective_date    DATE;
  gd_start_date        DATE;
  gd_end_date          DATE;
  gn_business_group_id NUMBER;
  gn_legal_er_id       NUMBER;
  gv_sort_opt          VARCHAR2(4);
  gv_assignment_set    VARCHAR2(100);
  gv_ass_set_id        NUMBER;
  gv_rpting_year       VARCHAR2(4);
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

    ln_index := subemppaid_xml_tbl.COUNT;

    subemppaid_xml_tbl(ln_index).name  := name;
    subemppaid_xml_tbl(ln_index).value := value;

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
				   ,p_sort_opt             OUT NOCOPY VARCHAR2
                                   )
  IS
    CURSOR c_payroll_Action_info (cp_payroll_action_id IN NUMBER) IS
      SELECT effective_date,
             business_group_id,
             pay_mx_utility.get_legi_param_val( 'LEGAL_EMPLOYER'
                ,legislative_parameters),
                 pay_mx_utility.get_legi_param_val( 'SORT_OPT'
                ,legislative_parameters) ,
                 pay_mx_utility.get_legi_param_val( 'ASS_SET'
                ,legislative_parameters)
		, pay_mx_utility.get_legi_param_val( 'RPT_YEAR'
                ,legislative_parameters)
		, pay_mx_utility.get_legi_param_val( 'START_DATE'
                ,legislative_parameters)
                ,pay_mx_utility.get_legi_param_val( 'END_DATE'
                ,legislative_parameters)

        FROM pay_payroll_actions
       WHERE payroll_action_id = cp_payroll_action_id;


    CURSOR c_ass_set_name (cp_ass_set_id NUMBER) IS
       SELECT assignment_set_name
       FROM  hr_assignment_sets
       WHERE assignment_set_id = cp_ass_set_id;

    ld_end_date          DATE;
    ln_business_group_id NUMBER;
    ln_asg_set_id        NUMBER;
    ln_legal_er_id       NUMBER;
    lv_sort_opt          VARCHAR2(4) ;
    lv_procedure_name    VARCHAR2(100);
    lv_assignment_set    VARCHAR2(100);
    lv_rpting_year       VARCHAR2(100);
    lv_error_message     VARCHAR2(200);
    ln_step              NUMBER;
    ld_rpt_start_dt      VARCHAR2(30) ;
    ld_rpt_end_dt        VARCHAR2(30);

   BEGIN

       lv_procedure_name  := g_proc_name ||'.get_payroll_action_info';

       hr_utility.set_location(lv_procedure_name, 10);

       ln_step := 1;

       OPEN  c_payroll_action_info(p_payroll_action_id);
       FETCH c_payroll_action_info INTO ld_end_date
                                       ,ln_business_group_id
                                       ,ln_legal_er_id
				       ,lv_sort_opt
				       ,lv_assignment_set
				       ,lv_rpting_year
				       ,ld_rpt_start_dt
				       ,ld_rpt_end_dt;
       CLOSE c_payroll_action_info;


       ln_step := 2;
       hr_utility.set_location(lv_procedure_name, 30);
       hr_utility_trace ('ld_rpt_start_dt = '|| ld_rpt_start_dt);
       hr_utility_trace ('ld_rpt_end_dt = '|| ld_rpt_end_dt);

      IF lv_assignment_set IS NOT NULL THEN
      OPEN c_ass_set_name(lv_assignment_set);
        FETCH c_ass_set_name INTO gv_assignment_set;
      CLOSE c_ass_set_name;
      END IF;
        -- Set the global variable for cp parameters value
       gv_ass_set_id := lv_assignment_set;
       gd_start_date := fnd_date.canonical_to_date(ld_rpt_start_dt);
       gd_end_date := fnd_date.canonical_to_date(ld_rpt_end_dt);
       gv_rpting_year := lv_rpting_year;
       hr_utility_trace ('gd_start_date = '|| gd_start_date);
       hr_utility_trace ('gd_end_date = '|| gd_end_date);
       p_end_date          := TRUNC(ld_end_date,'Y');
       p_business_group_id := ln_business_group_id;
       p_legal_employer_id := ln_legal_er_id;
       p_sort_opt          := lv_sort_opt;

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
                            ,gn_legal_er_id
			    ,gv_sort_opt);


    hr_utility_trace ('gd_effective_date = '|| gd_effective_date);
    hr_utility_trace ('gn_business_group_id = '|| gn_business_group_id);
    hr_utility_trace ('gn_legal_er_id = '|| gn_legal_er_id);
    hr_utility_trace ('gv_sort_opt = '|| gv_sort_opt);

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
                  ISR Subsidy For Employment Paid Report process.
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
         AND (gv_ass_set_id IS NULL OR (exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         =  gv_ass_set_id
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = 'I')))
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
	 AND (gv_ass_set_id IS NULL OR (exists (  select 1 /* Selected Assignment Set */
                        from hr_assignment_set_amendments hasa
                        where hasa.assignment_set_id         =  gv_ass_set_id
                          and hasa.assignment_id             = paa_arch.assignment_id
                          and upper(hasa.include_or_exclude) = 'I')))
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
                               ,gn_legal_er_id
			       ,gv_sort_opt);

    END IF;

    ln_asg_count := 0;

    lb_range_person_on := pay_ac_utility.range_person_on(
                               p_report_type      => 'ISR_SUBSIDY_EMP'
                              ,p_report_format    => 'ISR_SUBSIDY_EMP'
                              ,p_report_qualifier => 'ISR_SUBSIDY_EMP'
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

           hr_utility_trace('Creating report assignment action '||
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

    CURSOR c_subemppaid_rec (cp_assignment_action_id number) IS
       SELECT DISTINCT subemp_rpt.person_id PERSON_ID
             ,pos.period_of_service_id pos_id
             ,ppf.EMPLOYEE_NUMBER EMPLOYEE_NUMBER
             ,subemp_rpt.ER_LEGAL_NAME ER_LEGAL_NAME
             ,subemp_rpt.FISCAL_YEAR_REPORTING FISCAL_YEAR
            ,replace(RFC_ID,'-','')  RFC_ID
            ,CURP
	    ,pos.date_start  HIRE_DATE
	    ,pos.actual_termination_date SEPARATION_DATE
                  ,ltrim(rtrim(PATERNAL_LAST_NAME))||' '||
                   ltrim(rtrim(MATERNAL_LAST_NAME))||' '||
                   ltrim(rtrim(NAMES)) NAME
            ,nvl( ISR_SUBSIDY_FOR_EMP_PAID,0)  ISR_SUBSIDY_FOR_EMPL_PAID
            ,nvl( ISR_SUBSIDY_FOR_EMP,0)  ISR_SUBSIDY_FOR_EMP
            ,nvl(TOTAL_SUBJECT_EARNINGS,0)+
                         nvl(TOTAL_EXEMPT_EARNINGS,0) TOTAL_EARNINGS
        FROM PAY_MX_ISR_TAX_FORMAT37_V subemp_rpt
            ,pay_assignment_actions paa
            ,pay_action_interlocks pai
	    ,per_periods_of_service pos
	    ,per_all_people_f ppf
            ,per_all_assignments_f paf
       WHERE subemp_rpt.legal_employer_id =  gn_legal_er_id
         AND subemp_rpt.payroll_action_id    = paa.payroll_action_id
         AND subemp_rpt.person_id            = to_number(paa.serial_number)
         and paa.assignment_id = paf.assignment_id
	 AND pos.person_id = subemp_rpt.person_id
         AND paa.assignment_action_id = pai.locked_action_id
         AND pai.locking_action_id    =  cp_assignment_action_id
         AND paa.assignment_action_id = subemp_rpt.assignment_action_id
	 AND subemp_rpt.effective_date BETWEEN  gd_start_date AND  gd_end_date
	 AND ppf.person_id = pos.person_id
         AND pos.period_of_service_id = paf.period_of_service_id
	 AND subemp_rpt.effective_date between ppf.effective_start_date AND ppf.effective_end_date
	 AND NVL(pos.actual_termination_date, gd_end_date) >  gd_start_date;

    CURSOR c_pact_id (cp_assignment_action_id NUMBER) IS
      SELECT paa.payroll_action_id
        FROM pay_assignment_actions paa
       WHERE paa.assignment_action_id = cp_assignment_action_id;



    l_proc_name          varchar2(100);
    l_xml                BLOB;
    lb_person_processed  boolean;

    ln_assignment_action_id  NUMBER;
    ln_business_group_id     NUMBER;
    ln_payroll_action_id     NUMBER;

    subemppaid         c_subemppaid_rec%ROWTYPE;
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

   subemppaid_xml_tbl.DELETE;

    gn_success_fail  := 0;
    gn_sep_bal       := 0;
    gn_ass_bal       := 0;
    gn_emp_bal       := 0;
    ln_avg_daily_sal := 0;
    lv_level         := '0';

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
                               ,gn_legal_er_id
			       ,gv_sort_opt);

    END IF;

    hr_utility_trace ('Getting report parameters....');
    hr_utility_trace ('gd_effective_date = '|| gd_effective_date);
    hr_utility_trace ('gn_business_group_id = '|| gn_business_group_id);
    hr_utility_trace ('gn_legal_er_id = '|| gn_legal_er_id);
    hr_utility_trace ('gv_sort_opt = '|| gv_sort_opt);
    OPEN  c_subemppaid_rec(ln_assignment_action_id);
    LOOP
      FETCH c_subemppaid_rec INTO subemppaid;
      EXIT WHEN c_subemppaid_rec%NOTFOUND;

    populate_xml_table('FISCAL_YEAR', subemppaid.FISCAL_YEAR,'TEXT');
    populate_xml_table('ER_LEGAL_NAME', subemppaid.ER_LEGAL_NAME,'TEXT');
    populate_xml_table('EMPLOYEE_NUMBER', subemppaid.EMPLOYEE_NUMBER,'TEXT');
    populate_xml_table('HIRE_DATE', subemppaid.HIRE_DATE,'TEXT');
    populate_xml_table('RFC_ID', subemppaid.RFC_ID,'TEXT');
    populate_xml_table('CURP', subemppaid.CURP,'TEXT');
    populate_xml_table('NAME', subemppaid.NAME,'TEXT');
    populate_xml_table('SEPARATION_DATE', subemppaid.SEPARATION_DATE,'TEXT');
    populate_xml_table('TOTAL_EARNINGS',
                        subemppaid.TOTAL_EARNINGS,'TEXT');
    populate_xml_table('SUBSIDY_FOR_EMPL',
                        subemppaid.ISR_SUBSIDY_FOR_EMP,'TEXT');
    populate_xml_table('SUBSIDY_FOR_EMPL_PAID',
                        subemppaid.ISR_SUBSIDY_FOR_EMPL_PAID,'TEXT');


    load_xml_internal('CS','ISR_SUBSIDY_EMP',NULL);

    FOR i IN subemppaid_xml_tbl.FIRST..subemppaid_xml_tbl.LAST LOOP

      load_xml_internal('D',subemppaid_xml_tbl(i).name,subemppaid_xml_tbl(i).value);

    END LOOP;

    load_xml_internal('CE','ISR_SUBSIDY_EMP',NULL);
    subemppaid_xml_tbl.DELETE;
    END LOOP;
    CLOSE c_subemppaid_rec;


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
               ,subemppaid.ER_LEGAL_NAME );

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

   CURSOR c_le_name IS
     SELECT hou.name
     FROM hr_organization_units hou
     WHERE hou.organization_id = gn_legal_er_id;

    l_proc_name varchar2(100);
    lv_buf      varchar2(2000);
    lv_rpt_sort_opt  VARCHAR2(100);
    lv_le_name       hr_organization_units.name%type;
    ln_payroll_action_id     NUMBER;
  BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML_HEADER';
    hr_utility_trace ('Entering '||l_proc_name);
    subemppaid_xml_tbl.delete;
    ln_payroll_action_id :=  pay_magtape_generic.get_parameter_value('TRANSFER_PAYROLL_ACTION_ID');
     hr_utility_trace ('ln_payroll_action_id = '|| ln_payroll_action_id);
     IF gn_legal_er_id IS NULL THEN

       get_payroll_action_info (ln_payroll_action_id
                               ,gd_effective_date
                               ,gn_business_group_id
                               ,gn_legal_er_id
			       ,gv_sort_opt);

    END IF;

    hr_utility_trace ('Getting report parameters....');
    hr_utility_trace ('gd_effective_date = '|| gd_effective_date);
    hr_utility_trace ('gn_business_group_id = '|| gn_business_group_id);
    hr_utility_trace ('gn_legal_er_id = '|| gn_legal_er_id);
    hr_utility_trace ('gv_sort_opt = '|| gv_sort_opt);
    hr_utility_trace ('Root XML tag = '||
                    pay_magtape_generic.get_parameter_value('ROOT_XML_TAG'));

    lv_buf := pay_magtape_generic.get_parameter_value('ROOT_XML_TAG');
    write_to_magtape_lob (lv_buf);

    OPEN c_le_name;
     FETCH c_le_name INTO lv_le_name;
    CLOSE c_le_name;

    lv_rpt_sort_opt :=  hr_general.decode_lookup('REPORT_SELECT_SORT_CODE',gv_sort_opt);

    hr_utility_trace ('lv_le_name = '|| lv_le_name);
    hr_utility_trace ('lv_rpt_sort_opt = '|| lv_rpt_sort_opt);
    hr_utility_trace ('Building XML for Report param val....');

    populate_xml_table('RPT_ER_LEGAL_NAME', lv_le_name,'TEXT');
    populate_xml_table('RPT_FISCAL_YEAR',gv_rpting_year,'TEXT');
    populate_xml_table('RPT_ASS_SET', gv_assignment_set,'TEXT');
    populate_xml_table('RPT_SORT_OPT', lv_rpt_sort_opt,'TEXT');


    load_xml_internal('CS','REPORT_PARM',NULL);

   FOR i IN subemppaid_xml_tbl.FIRST..subemppaid_xml_tbl.LAST LOOP

      load_xml_internal('D',subemppaid_xml_tbl(i).name,subemppaid_xml_tbl(i).value);

    END LOOP;

    load_xml_internal('CE','REPORT_PARM',NULL);

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
   -- hr_utility.trace_on(null, 'PAYMXSUBEMPL');
    g_proc_name := 'PAY_MX_SUBSIDY_EMP_PD_RPT.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'MX_subemppaid';
END PAY_MX_SUBSIDY_EMP_PD_RPT;

/
