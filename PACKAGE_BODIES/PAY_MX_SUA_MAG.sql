--------------------------------------------------------
--  DDL for Package Body PAY_MX_SUA_MAG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_SUA_MAG" AS
/* $Header: paymxsuamag.pkb 120.32.12010000.9 2009/10/20 10:45:02 vvijayku ship $ */
/*  +======================================================================+
    |                Copyright (c) 2003 Oracle Corporation                 |
    |                   Redwood Shores, California, USA                    |
    |                        All rights reserved.                          |
    +======================================================================+
    Package Name        : pay_mx_sua_mag
    Package File Name   : paymxsuamag.pkb

    Description : Used for SUA Interface Extract

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    vpandya       29-Apr-2005 115.0           Initial Version
    sdahiya       11-Jul-2005 115.1           Added range code, action creation
                                              code and XML generation mechanism.
    sdahiya       13-Jul-2005 115.2           Modified GET_START_DATE to return
                                              implementation date if the SUA
                                              request is run for the first time.
    sdahiya       15-Jul-2005 115.3           Modified GENERATE_XML procedure
                                              to handle custom exception tags.
    sdahiya       27-Jul-2005 115.4  4518777  Used substring of serial_number
                                              column to get person_id.

                                     4518732  Modified get_start_date to read
                                              the start date from
                                              pay_payroll_actions instead of
                                              pay_recorded_requests. This will
                                              facilitate rollbacks of SUA
                                              Interface Extract concurrent
                                              program.
    sdahiya       28-Jul-2005 115.5           Modified GENERATE_XML so that
                                              XML for transactions is generated
                                              even if there are no corresponding
                                              person records archived.
    sdahiya       04-Aug-2005 115.6  4518777  Global variables holding payroll
                                              action information should be
                                              re-initialized for each thread.
    sdahiya       05-Aug-2005 115.7           Modified ACTION_CREATION to lock
                                              all archiver asg action across
                                              multiple archiver runs.
    sdahiya       09-Aug-2005 115.8  4541979  CLOB variables should not be read
                                              if no archived information exists
                                              and consequently there is nothing
                                              to be written to CLOB.
    sdahiya       09-Aug-2005 115.9           Added REPORT_PERIOD tag.
    sdahiya       10-Aug-2005 115.10          Added payroll_action_id join
                                              condition in action_creation.
    sdahiya       10-Aug-2005 115.11          Re-initialized global variables
                                              in GEN_XML_FOOTER.
    sdahiya       19-Aug-2005 115.12          Added document_type parameter in
                                              calls to
                                              pay_payroll_xml_extract_pkg.
                                              generate.
    vpandya       31-Oct-2005 115.13 4710619  Changed cursor get_emp_trans,
                                              using action_information5 in
                                              place of effective_date in
                                              where clause.
    vmehta        09-Nov-2005 115.14          Increased the size of lv_buf
                                              in multiple places to allow for
                                              multibyte characterset expansion.
    vmehta        23-Nov-2005 115.15          Modified get_arch_pact_id.
                                              Removed pay_action_information
                                              from the list of tables.
    sdahiya       21-NOV-2005 115.16 4773967  CLOB to BLOB changes.
    sdahiya       01-DEC-2005 115.17          Modified PRINT_BLOB to use
                                              pay_ac_utility.print_lob.
    sdahiya       01-DEC-2005 115.18          Used core procedure
                                              pay_core_files.write_to_magtape_lob
                                              to manipulate core magtape BLOB.
    sdahiya       22-Dec-2005 115.19          Removed XML header information.
                                              PYUGEN will generate XML headers.
    sdahiya       18-Apr-2006 115.20 4864237  Performance fix.
    sdahiya       04-Aug-2006 115.21          XML should contain always contain
                                              worker data record.
    sdahiya       05-Sep-2006 115.22          Worker data for a person should
                                              appear exactly once in the XML
                                              even if it was archived multiple
                                              times.
    sdahiya       17-Sep-2006 115.23          Modified the order by clause of
                                              c_arch_asg_range and c_arch_asg
                                              to ensure that only one assignment
                                              action per person is created.
    sdahiya       13-Feb-2007 115.24 5878927  Modified the order by clause of
                                              c_arch_asg_range and c_arch_asg
                                              to avoid insertion of duplicate
                                              action interlocks due to multiple
                                              archiver runs.
    sdahiya       02-Mar-2007 115.25          Modified the process to pick only
                                              those transactions which are
                                              effective in the reporting period.
    sdahiya       08-Apr-2007 115.26          07 transactions should not be
                                              reported if IDW amount hasn't
                                              changed since it was reported
                                              last.
    sdahiya       19-Apr-2007 115.27 5998981  Modified cursor csr_prev_idw to
                                              conditionally convert canonical
                                              date stamped on action information
                                              DDF.
    sdahiya       19-Apr-2007 115.28 6004485  Modified action_creation to ensure
                                              that exactly one interlock is
                                              inserted for every archiver asg
                                              action.
    sdahiya       23-Apr-2007 115.29          Modified generate_xml to use
                                              transaction processing from
                                              affiliation report.
    sdahiya       15-May-2007 115.30          Modified action_creation and
                                              generate_xml so that past-dated
                                              transactions are picked.
    nragavar      31-May-2007 115.31 6073090  Person information selection was
                                              not done in cursors c_arch_asg,
                                              c_arch_asg_range
    nragavar      12-Jul-2007 115.32 6198089  added new procedure INIT
    sivanara      27-Jun-2008 115.33 7185703  added logic to filter the
                                              transaction after implementation
					      date.
    swamukhe      04-Oct-2008 115.35 6451017  Modified the c_arch_asg_range so
                                              truncated the dates in the cursor.
    vvijayku      07-Oct-2008 115.36 6451017  Modified the cursor get_emp_trans
                                              so that it will take fetch the value
					      of the reporting option.
    sjawid        10-Mar-2009 115.37 8280047  Modified Person information selection
                                              in cursors c_arch_asg, c_arch_asg_range
					      so that it selects valid person transaction.
    vvijayku      19-Nov-2009 115.38 8768679  Added code to report the 08 transactions one
                                              day before the date of transaction.
    vvijayku      20-Nov-2009 115.39 8768679  Added comments about the changes made for the
                                              fix.
    vvijayku      20-Nov-2009 115.40 8768679  Modified the comments added earlier.
    ========================================================================*/

--
-- Global Variables
--
    TYPE char_tab IS TABLE OF pay_action_information.action_information1%type
                                                      INDEX BY BINARY_INTEGER;
    g_xml_cache     char_tab;
    g_proc_name     varchar2(240);
    g_debug         boolean;
    g_document_type varchar2(50);

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
    Name        : GET_PACT_INFO
    Description : This procedure fetches payroll action level information.
  *****************************************************************************/
PROCEDURE GET_PACT_INFO
(
    P_PAYROLL_ACTION_ID number,
    P_GRE_ID            OUT NOCOPY number,
    P_START_DATE        OUT NOCOPY varchar2,
    P_END_DATE          OUT NOCOPY varchar2,
    P_MODE              OUT NOCOPY varchar2
) IS
    CURSOR csr_get_mag_pact_info IS
    SELECT pay_mx_utility.get_legi_param_val('GRE',
                                             ppa_mag.legislative_parameters),
           pay_mx_utility.get_legi_param_val('START_DATE',
                                            ppa_mag.legislative_parameters),
           pay_mx_utility.get_legi_param_val('END_DATE',
                                            ppa_mag.legislative_parameters),
           pay_mx_utility.get_legi_param_val('MODE',
                                             ppa_mag.legislative_parameters)
      FROM pay_payroll_actions ppa_mag
     WHERE ppa_mag.payroll_action_id = p_payroll_action_id;

     l_proc_name    varchar2(100);
BEGIN
    l_proc_name := g_proc_name || 'GET_PACT_INFO';
    hr_utility_trace ('Entering '||l_proc_name);

    OPEN csr_get_mag_pact_info;
        FETCH csr_get_mag_pact_info INTO p_gre_id,
                                         p_start_date,
                                         p_end_date,
                                         p_mode;
    CLOSE csr_get_mag_pact_info;

    hr_utility_trace ('Leaving '||l_proc_name);
END GET_PACT_INFO;


  /****************************************************************************
    Name        : GET_START_DATE
    Description : This function returns start date.
  *****************************************************************************/
FUNCTION GET_START_DATE
(
    P_MODE      varchar2, -- FULL/INCREMENT
    P_GRE_ID    number
) RETURN varchar2 AS

   CURSOR c_get_bus_grp_id IS
     SELECT hou.business_group_id
       FROM hr_organization_units hou
      WHERE hou.organization_id = p_gre_id;

   CURSOR c_get_imp_date(cp_organization_id IN NUMBER) IS
     SELECT org_information6
       FROM hr_organization_information
      WHERE org_information_context = 'MX_TAX_REGISTRATION'
        AND organization_id = cp_organization_id;

    CURSOR c_get_last_run_date IS
        SELECT fnd_date.date_to_canonical(
               fnd_date.canonical_to_date(
               pay_mx_utility.get_legi_param_val ('END_DATE',
                                                 ppa.legislative_parameters)) +
                                                 1/(24 * 60 * 60))
          FROM pay_payroll_actions ppa
         WHERE pay_mx_utility.get_legi_param_val('GRE',
                                                  ppa.legislative_parameters) =
                                                  p_gre_id
           AND ppa.report_type = 'SUA_MAG'
           AND ppa.report_qualifier = 'SUA_MAG'
           AND ppa.report_category = 'RT'
           AND ppa.action_type = 'X'
           AND ppa.action_status = 'C'
      ORDER BY ppa.payroll_action_id DESC;

     lv_report_imp_date   varchar2(25);
     lv_start_date        varchar2(50);
     ld_start_date        date;
     ln_legal_employer_id number;
     ln_bus_grp_id        number;
     l_proc_name          varchar2(100);

BEGIN
    l_proc_name := g_proc_name || 'GET_START_DATE';
    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('Parameters ...');
    hr_utility_trace ('P_MODE = '||P_MODE);
    hr_utility_trace ('P_GRE_ID = '||P_GRE_ID);

      -- GET LEGAL EMPLOYER ID FROM GRE ID

      OPEN c_get_bus_grp_id;
          FETCH c_get_bus_grp_id INTO ln_bus_grp_id;
      CLOSE c_get_bus_grp_id;

      ln_legal_employer_id :=
               hr_mx_utility.get_legal_employer(ln_bus_grp_id, p_gre_id);

      -- get the report Implementation Date from p_legal_emp_id

      OPEN  c_get_imp_date(ln_legal_employer_id);
          FETCH c_get_imp_date INTO lv_start_date;
          IF ((c_get_imp_date%NOTFOUND) OR (lv_start_date IS NULL)) THEN
             -- defaulting to Report Implementation Date from
             -- mx pay legislation info table
            lv_start_date := pay_mx_utility.get_default_imp_date;
          END IF;
      CLOSE c_get_imp_date;

      IF (p_mode = 'INCREMENT') THEN
          -- Bug 4518732
          OPEN c_get_last_run_date;
            FETCH c_get_last_run_date INTO lv_start_date;
          CLOSE c_get_last_run_date;
      END IF;

      hr_utility_trace ('Start date = '|| lv_start_date);
      hr_utility_trace ('Leaving '||l_proc_name);
      RETURN lv_start_date ;

END GET_START_DATE;


  /****************************************************************************
    Name        : RANGE_CURSOR
    Description : This procedure prepares range of persons to be processed.
  *****************************************************************************/
PROCEDURE RANGE_CURSOR
(
    P_PAYROLL_ACTION_ID number,
    P_SQLSTR            OUT NOCOPY varchar2
) AS

    l_proc_name             varchar2(100);
    ld_end_date                date;
    l_new_end_date            varchar2(25);

BEGIN
    l_proc_name := g_proc_name || 'RANGE_CURSOR';
    hr_utility_trace ('Entering '||l_proc_name);

    hr_utility_trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);

    get_pact_info (p_payroll_action_id,
                   g_mag_gre_id,
                   g_mag_start_date,
                   g_mag_end_date,
                   g_mag_mode);

/*Bug 8768679 - Added the following code to increase the g_mag_end_date by 1
so that it cane be used in the range cursor and it will pick the future
hired employee*/

ld_end_date := fnd_date.canonical_to_date (g_mag_end_date)+1;
l_new_end_date := fnd_date.date_to_canonical (ld_end_date);
hr_utility_trace ('End date is '|| l_new_end_date);

    -- Bug 4518777
    p_sqlstr := '
SELECT DISTINCT substr(paa_arch.serial_number, 1,
                       instr(paa_arch.serial_number, ''|'')-1)
  FROM pay_assignment_actions paa_arch,
       pay_payroll_actions ppa_arch
 WHERE paa_arch.payroll_action_id = ppa_arch.payroll_action_id
   AND paa_arch.tax_unit_id = '|| g_mag_gre_id ||'/*
   AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val(''END_DATE'',
                                         ppa_arch.legislative_parameters))
       BETWEEN fnd_date.canonical_to_date ('''|| g_mag_start_date ||''')
           AND fnd_date.canonical_to_date ('''|| l_new_end_date ||''')
   */AND ppa_arch.action_type = ''X''
   AND ppa_arch.report_type = ''SS_ARCHIVE''
   AND ppa_arch.report_qualifier = ''SS_ARCHIVE''
   AND ppa_arch.report_category = ''RT''
   AND ppa_arch.action_status = ''C''
   AND :p_payroll_action_id = '||p_payroll_action_id||'
ORDER BY 1';

    hr_utility_trace ('Range cursor query : ' || p_sqlstr);
    hr_utility_trace ('Leaving '||l_proc_name);

END RANGE_CURSOR;


  /****************************************************************************
    Name        : ACTION_CREATION
    Description : This procedure creates assignment actions for SUA magnetic
                  tape process.
  *****************************************************************************/
PROCEDURE ACTION_CREATION
(
    P_PAYROLL_ACTION_ID number,
    P_START_PERSON_ID   number,
    P_END_PERSON_ID     number,
    P_CHUNK             number
) AS

   /*Bug 8768679 - Added decode statements in the cursor so that  only for  08 type ,future dated transactions are also selected*/
    CURSOR c_arch_asg (p_end_date VARCHAR2) IS
        SELECT paa_arch.assignment_action_id,
               paf.assignment_id,
               paf.person_id,
               ppa_arch.payroll_action_id
          FROM pay_assignment_actions paa_arch,
               pay_payroll_actions ppa_arch,
               per_all_assignments_f paf,
               pay_action_information pai
         WHERE paa_arch.payroll_action_id = ppa_arch.payroll_action_id
           AND paa_arch.assignment_id = paf.assignment_id
           -- Bug 4518777
           AND paf.person_id BETWEEN p_start_person_id AND p_end_person_id
           AND paa_arch.tax_unit_id = g_mag_gre_id
           /*AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val(
                                              'END_DATE',
                                              ppa_arch.legislative_parameters))
               BETWEEN fnd_date.canonical_to_date(g_mag_start_date)
                   AND fnd_date.canonical_to_date(g_mag_end_date)*/
           ----
           AND paa_arch.assignment_action_id = pai.action_context_id
           AND (( pai.action_information_category = 'MX SS TRANSACTIONS'
           AND    (fnd_date.canonical_to_date (pai.action_information2) BETWEEN
                                   fnd_date.canonical_to_date (g_mag_start_date)
				   /*Bug 8768679*/
                               AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date))
                  OR (pai.effective_date BETWEEN
                                   fnd_date.canonical_to_date (g_mag_start_date)
				   /*Bug 8768679*/
                               AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date))
                  /*Bug 8768679*/
		  AND fnd_date.canonical_to_date (pai.action_information2) <=
                                   fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date))))
                 )
               OR (pai.action_information_category = 'MX SS PERSON INFORMATION'
                   AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val(
                                              'END_DATE',
                                              ppa_arch.legislative_parameters))
                   BETWEEN fnd_date.canonical_to_date(g_mag_start_date)
		   /*Bug 8768679*/
                   AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date))
	          )
               )
           AND paa_arch.tax_unit_id = g_mag_gre_id
           /*AND NOT EXISTS (SELECT 'X'
                             FROM pay_payroll_actions ppa_sua,
                                  pay_assignment_actions paa_sua,
                                  pay_action_interlocks lck
                            WHERE lck.locked_action_id = pai.action_context_id
                              AND lck.locking_action_id =
                                                  paa_sua.assignment_action_id
                              AND paa_sua.payroll_action_id =
                                                     ppa_sua.payroll_action_id
                              AND ppa_sua.report_type = 'SUA_MAG'
                              AND ppa_sua.report_qualifier = 'SUA_MAG'
                              AND ppa_sua.report_category = 'RT'
                              AND ppa_sua.action_status = 'C')*/
           ----
           AND ppa_arch.action_type = 'X'
           AND ppa_arch.report_type = 'SS_ARCHIVE'
           AND ppa_arch.report_qualifier = 'SS_ARCHIVE'
           AND ppa_arch.report_category = 'RT'
           AND ppa_arch.action_status = 'C'
        ORDER BY paf.person_id,
                 decode (paf.primary_flag, 'Y', 1, 2),
                 paf.assignment_id,
                 ppa_arch.payroll_action_id,
                 paf.effective_end_date;

    /*Bug 8768679 - Added decode statements in the cursor so that  only for  08 type ,future dated transactions are also selected*/
    CURSOR c_arch_asg_range (p_end_date VARCHAR2) IS
        SELECT paa_arch.assignment_action_id,
               paf.assignment_id,
               paf.person_id,
               ppa_arch.payroll_action_id
          FROM pay_assignment_actions paa_arch,
               pay_payroll_actions ppa_arch,
               per_all_assignments_f paf,
               pay_population_ranges ppr,
               pay_action_information pai
         WHERE paa_arch.payroll_action_id = ppa_arch.payroll_action_id
           AND paa_arch.assignment_id = paf.assignment_id
           AND paf.person_id = ppr.person_id
           AND ppr.chunk_number = p_chunk
           AND ppr.payroll_action_id = p_payroll_action_id
           AND paa_arch.tax_unit_id = g_mag_gre_id
           /*AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val(
                                              'END_DATE',
                                              ppa_arch.legislative_parameters))
               BETWEEN fnd_date.canonical_to_date(g_mag_start_date)
                   AND fnd_date.canonical_to_date(g_mag_end_date)*/
           ----
           AND paa_arch.assignment_action_id = pai.action_context_id
           AND ((pai.action_information_category = 'MX SS TRANSACTIONS'
                 AND (fnd_date.canonical_to_date (pai.action_information2) BETWEEN
                                   fnd_date.canonical_to_date (g_mag_start_date)
				   /*Bug 8768679*/
                               AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date))
                 OR (pai.effective_date BETWEEN
                                   trunc(fnd_date.canonical_to_date (g_mag_start_date))
				   /*Bug 8768679*/
                               AND trunc(fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date)))
                 /*Bug 8768679*/
		 AND fnd_date.canonical_to_date (pai.action_information2) <=
                                   fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date))))
                 )
                 OR (pai.action_information_category = 'MX SS PERSON INFORMATION'
	           AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val(
                                           'END_DATE',
                                           ppa_arch.legislative_parameters))
                   BETWEEN fnd_date.canonical_to_date(g_mag_start_date)
                   /*Bug 8768679*/
		   AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_mag_end_date))
	          )
               )
           AND paa_arch.tax_unit_id = g_mag_gre_id
           /*AND NOT EXISTS (SELECT 'X'
                             FROM pay_payroll_actions ppa_sua,
                                  pay_assignment_actions paa_sua,
                                  pay_action_interlocks lck
                            WHERE lck.locked_action_id = pai.action_context_id
                              AND lck.locking_action_id =
                                                  paa_sua.assignment_action_id
                              AND paa_sua.payroll_action_id =
                                                     ppa_sua.payroll_action_id
                              AND ppa_sua.report_type = 'SUA_MAG'
                              AND ppa_sua.report_qualifier = 'SUA_MAG'
                              AND ppa_sua.report_category = 'RT'
                              AND ppa_sua.action_status = 'C')*/
           ----
           AND ppa_arch.action_type = 'X'
           AND ppa_arch.report_type = 'SS_ARCHIVE'
           AND ppa_arch.report_qualifier = 'SS_ARCHIVE'
           AND ppa_arch.report_category = 'RT'
           AND ppa_arch.action_status = 'C'
        ORDER BY paf.person_id,
                 decode (paf.primary_flag, 'Y', 1, 2),
                 paf.assignment_id,
                 ppa_arch.payroll_action_id,
                 paf.effective_end_date;

    CURSOR csr_future_magtape_exists IS
        SELECT 'Y'
          FROM pay_payroll_actions ppa
         WHERE ppa.report_type = 'SUA_MAG'
           AND ppa.report_qualifier = 'SUA_MAG'
           AND ppa.report_category = 'RT'
           AND ppa.action_type = 'X'
           AND ppa.action_status = 'C'
           AND pay_mx_utility.get_legi_param_val('GRE',
                                                 ppa.legislative_parameters) =
                                                                  g_mag_gre_id
           AND fnd_date.canonical_to_date(pay_mx_utility.get_legi_param_val(
                                               'END_DATE',
                                                ppa.legislative_parameters)) >
                                  fnd_date.canonical_to_date(g_mag_end_date);

    /*Bug 8768679 - The following cursor has been added to find out if
     the Archiver Assignment action has been already locked in pay_action_interlocks*/
    CURSOR c_assg_action_exist (p_arch_asg_act NUMBER) IS
        SELECT count(*)
        FROM pay_action_interlocks
        WHERE locked_action_id = p_arch_asg_act;

     /*Bug 8768679 - The follwowing cursor has been added to find out if
       the archiver assignment action has already been locked by another
       SUA Mag report*/
     CURSOR c_report_type (p_arch_asg_act NUMBER) IS
        SELECT count(*)
        FROM pay_payroll_actions pact,
             pay_assignment_actions paa,
             pay_action_interlocks pail
        WHERE p_arch_asg_act = pail.locked_action_id
        AND pail.locking_action_id = paa.assignment_action_id
        AND paa.payroll_action_id = pact.payroll_action_id
        AND pact.report_type = 'SUA_MAG';


    TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    lt_arch_act                 num_tab;
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
    ln_exist                    number;
    l_report                    number;
    ld_end_date                 date;
    l_new_end_date              varchar2(25);
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

    -- Bug 4518777
    IF g_mag_gre_id IS NULL THEN
        get_pact_info (p_payroll_action_id,
                       g_mag_gre_id,
                       g_mag_start_date,
                       g_mag_end_date,
                       g_mag_mode);
    END IF;

    /*Bug 8768679 - Added the following code to increase the g_mag_end_date by 1
      so that it cane be used in the action creation cursors */

    ld_end_date := fnd_date.canonical_to_date (g_mag_end_date)+1;
    l_new_end_date := fnd_date.date_to_canonical (ld_end_date);
    hr_utility_trace ('End date is '|| l_new_end_date);

    /* Raise an error if magtape is run in FULL mode and future magtape runs
       already exist */
    IF (g_mag_mode = 'FULL') THEN
        OPEN csr_future_magtape_exists;
            FETCH csr_future_magtape_exists INTO lv_future_magtape_exists;
        CLOSE csr_future_magtape_exists;

        IF lv_future_magtape_exists = 'Y' THEN
            /* Currently we are not supporting FULL mode magtape runs. So, this
               portion of code will never execute. */
            --hr_utility.set_message(801, 'PAY_FUTURE_SUA_MAG_EXISTS');
            --hr_utility.raise_error;
            NULL;
        END IF;
    END IF;

    ln_asg_count := 0;

    lb_range_person_on := pay_ac_utility.range_person_on(
                               p_report_type      => 'SUA_MAG'
                              ,p_report_format    => 'SUA_MAG'
                              ,p_report_qualifier => 'SUA_MAG'
                              ,p_report_category  => 'RT');

    IF lb_range_person_on THEN
        hr_utility_trace ('Person ranges are ON');
        OPEN c_arch_asg_range (l_new_end_date); --Bug 8768679
    ELSE
        hr_utility_trace ('Person ranges are OFF');
        OPEN c_arch_asg (l_new_end_date); --Bug 8768679
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

	    OPEN c_assg_action_exist (ln_arch_act_id);
            FETCH c_assg_action_exist INTO ln_exist;
            CLOSE c_assg_action_exist;

            OPEN c_report_type (ln_arch_act_id);
            FETCH c_report_type INTO l_report;
            CLOSE c_report_type;

      /*Bug 8768679 - The current archiver assignment action will be processed and reported only if
        it is not locked by another SUA Mag report or if it has not been reported yet.
	The following IF condition is used for that purpose.*/
      IF (ln_exist = 0 OR l_report = 0) THEN
	IF (ln_person_id <> ln_prev_person_id) THEN
            SELECT pay_assignment_actions_s.nextval
              INTO ln_mag_asg_act_id
              FROM dual;

            hr_utility_trace('Creating magtape assignment action '||
                                                            ln_mag_asg_act_id);
            hr_nonrun_asact.insact(ln_mag_asg_act_id,
                                  ln_assignment_id,
                                  p_payroll_action_id,
                                  p_chunk,
                                  g_mag_gre_id,
                                  null,
                                  'U',
                                  null);
            ln_prev_person_id := ln_person_id;
            lt_arch_act.DELETE(); -- Bug 6004485
        ELSE
            hr_utility_trace('Magtape assignment action not created');
        END IF;
      ELSE
                hr_utility_trace('Magtape assignment action need not be created');
      END IF;

        hr_utility_trace ('Current payroll action id = '||ln_arch_pact_id);
        hr_utility_trace ('Prev payroll action id = '||ln_prev_arch_pact_id);
        hr_utility_trace ('Current assignment_id = '||ln_assignment_id);
        hr_utility_trace ('Previous assignment_id = '||ln_prev_asg_id);

      /*Bug 8768679 - The current archiver assignment action will be processed and reported only if
        it is not locked by another SUA Mag report or if it has not been reported yet.
	The following IF condition is used for that purpose.*/
      IF (ln_exist = 0 OR l_report = 0) THEN
	IF ln_arch_pact_id = ln_prev_arch_pact_id AND
           ln_assignment_id = ln_prev_asg_id THEN
            hr_utility_trace ('Action interlock not created.');
        ELSE
            IF lt_arch_act.EXISTS(ln_arch_act_id) THEN -- Bug 6004485
                hr_utility_trace('Interlock for archiver action '||
                                            ln_arch_act_id||' already exists.');
            ELSE
                hr_nonrun_asact.insint (ln_mag_asg_act_id,
                                        ln_arch_act_id);
                hr_utility_trace('Archiver asg action '||ln_arch_act_id||
                       ' locked by magtape asg action '||ln_mag_asg_act_id);
                ln_prev_asg_id := ln_assignment_id;
                ln_prev_arch_pact_id := ln_arch_pact_id;
                lt_arch_act(ln_arch_act_id) := 0;
            END IF;
            hr_utility_trace (lt_arch_act.COUNT()||' interlocks exist for '||
                                        'SUA asg action '||ln_mag_asg_act_id);
        END IF;
       ELSE
                hr_utility_trace('The transaction has already been reported in earlier reports');
       END IF;
    END LOOP;

    hr_utility_trace(ln_asg_count || ' archiver actions processed in chunk '||
                                                                      p_chunk);

    IF lb_range_person_on THEN
        CLOSE c_arch_asg_range;
    ELSE
        CLOSE c_arch_asg;
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
END ACTION_CREATION;

  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE GENERATE_XML AS

    /*Bug 8768679 -The employee information can be picked up only when the
     hire date lies within the employee start date and employee end date,
     hence the pai.effective_date has been replaced by pai.action_information10*/
    CURSOR get_emp_details (cp_assignment_action_id number) IS
        SELECT paa_arch.payroll_action_id,
               pai.action_context_id,
               pai.action_information_id,
               nvl(pai.action_information21, 'N') -- Do not report flag
          FROM pay_action_information pai,
               pay_assignment_actions paa_arch,
               per_all_assignments_f paf,
               pay_action_interlocks lck
         WHERE pai.action_context_id = paa_arch.assignment_action_id
           AND paf.assignment_id = paa_arch.assignment_id
           /*Bug 8768679*/
	   AND fnd_date.canonical_to_date(pai.action_information10)
	                          BETWEEN paf.effective_start_date
				  AND     paf.effective_end_date
           AND paa_arch.assignment_action_id = lck.locked_action_id
           AND lck.locking_action_id = cp_assignment_action_id
           AND pai.action_context_type = 'AAP'
           AND pai.action_information_category = 'MX SS PERSON INFORMATION'
      ORDER BY paa_arch.payroll_action_id DESC,
               decode (paf.primary_flag, 'Y', 1, 2),
               paf.assignment_id;

    /*Bug 8768679 - The employee 08 transactions would be picked up only when the hire date lies within the
    reporting period, hence the decode statement has been added to facilitate that.*/
    CURSOR get_emp_trans(cp_assignment_action_id number,cp_imp_date varchar2,cp_end_date varchar2) IS
        SELECT pai.action_information_id,
               pai.action_information4, -- transaction type
               pai.assignment_id,
               pai.action_information1, -- person ID
               pai.tax_unit_id,
               pai.effective_date,
               nvl(pai.action_information10, 'N'), -- Do not report flag
               fnd_number.canonical_to_number(pai.action_information8), --IDW
               pai.action_information2, -- transaction date
	       pai.action_information24 -- Report Rehire Termination
          FROM pay_action_information pai,
               pay_assignment_actions paa_arch,
               per_all_assignments_f paf,
               pay_action_interlocks lck
         WHERE pai.action_context_id = paa_arch.assignment_action_id
           AND paf.assignment_id = paa_arch.assignment_id
	     --Bug 7185703
	   AND fnd_date.canonical_to_date (pai.action_information2)  >= fnd_date.canonical_to_date(cp_imp_date)
	   AND (fnd_date.canonical_to_date (pai.action_information2) BETWEEN
                                   fnd_date.canonical_to_date (g_mag_start_date)
				   /*Bug 8768679*/
                               AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',cp_end_date,g_mag_end_date))
               OR (pai.effective_date BETWEEN
                                   fnd_date.canonical_to_date (g_mag_start_date)
				   /*Bug 8768679*/
                               AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',cp_end_date,g_mag_end_date))
              /*Bug 8768679*/
	      AND fnd_date.canonical_to_date (pai.action_information2) <=
                                   fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',cp_end_date,g_mag_end_date))))
           AND fnd_date.canonical_to_date(pai.action_information2)
                                  BETWEEN paf.effective_start_date
                                      AND paf.effective_end_date
           AND paa_arch.assignment_action_id = lck.locked_action_id
           AND lck.locking_action_id = cp_assignment_action_id
           AND pai.action_context_type = 'AAP'
           AND pai.action_information_category = 'MX SS TRANSACTIONS'

      ORDER BY fnd_date.canonical_to_date (pai.action_information2), -- tran dt
               DECODE (pai.action_information4,
                       '08', 1,
                       '07', 2,
                       '02', 3),
               pai.action_information_id,
               paa_arch.payroll_action_id,
               paf.person_id,
               decode (paf.primary_flag, 'Y', 1, 2),
               paf.assignment_id;

    CURSOR csr_tran_exists (cp_mag_asact_id        number,
                            cp_person_id           varchar2,
                            cp_tran_type           varchar2,
                            cp_tran_dt             date) IS
        SELECT fnd_date.canonical_to_date(pai.action_information2) -- tran date
          FROM pay_assignment_actions paa_mag,
               pay_payroll_actions ppa_mag,
               pay_assignment_actions paa_mag_prev,
               pay_payroll_actions ppa_mag_prev,
               pay_action_information pai,
               pay_action_interlocks lck
         WHERE paa_mag.payroll_action_id = ppa_mag.payroll_action_id
           AND paa_mag_prev.payroll_action_id = ppa_mag_prev.payroll_action_id
           AND pay_mx_utility.get_legi_param_val ('GRE',
                                                  ppa_mag.payroll_action_id) =
               pay_mx_utility.get_legi_param_val ('GRE',
                                                 ppa_mag_prev.payroll_action_id)
           AND ppa_mag_prev.payroll_action_id < ppa_mag.payroll_action_id
           AND paa_mag_prev.assignment_action_id = lck.locking_action_id
           AND lck.locked_action_id = pai.action_context_id
           AND paa_mag.assignment_action_id = cp_mag_asact_id
           AND pai.action_information1 = cp_person_id -- person ID
           AND pai.action_information4 = cp_tran_type -- transaction type
           AND nvl(pai.action_information10, 'N') <> 'Y' -- do not report flag
           AND ((fnd_date.canonical_to_date (pai.action_information2) >
                                                                cp_tran_dt) OR
                (cp_tran_dt IS NULL))
           AND pai.action_context_type = 'AAP'
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND ppa_mag_prev.action_type = 'X'
           AND ppa_mag_prev.report_type = 'SUA_MAG'
           AND ppa_mag_prev.report_qualifier = 'SUA_MAG'
           AND ppa_mag_prev.report_category = 'RT'
           AND ppa_mag_prev.action_status = 'C';

    CURSOR csr_person (cp_asg_act_id  number) IS
        SELECT DISTINCT paf.person_id
          FROM pay_assignment_actions paa,
               per_assignments_f paf
         WHERE paf.assignment_id = paa.assignment_id
           AND paa.assignment_action_id = cp_asg_act_id;

    CURSOR csr_asg_actions (cp_person_id  number) IS
        SELECT fnd_number.canonical_to_number(
                  pay_magtape_generic.get_parameter_value ('TRANSFER_ACT_ID')),
               fnd_date.canonical_to_date(g_mag_end_date)
          FROM DUAL
        UNION
        SELECT paa.assignment_action_id,
               fnd_date.canonical_to_date(
                              pay_mx_utility.get_legi_param_val('END_DATE',
                                             ppa.legislative_parameters))
          FROM pay_payroll_actions ppa,
               pay_assignment_actions paa,
               per_assignments_f paf
         WHERE ppa.payroll_action_id = paa.payroll_action_id
           AND paa.assignment_id = paf.assignment_id
           AND paf.person_id = cp_person_id
           AND fnd_date.canonical_to_date(
                                  pay_mx_utility.get_legi_param_val('END_DATE',
                                                  ppa.legislative_parameters))
                BETWEEN paf.effective_start_date AND paf.effective_end_date
           AND ppa.action_type = 'X'
           AND ppa.report_type = 'SUA_MAG'
           AND ppa.report_qualifier = 'SUA_MAG'
           AND ppa.report_category = 'RT'
           AND ppa.action_status = 'C'
           /*AND cp_gre_id = fnd_number.canonical_to_number(
                              pay_mx_utility.get_legi_param_val('GRE',
                                                  ppa.legislative_parameters))
           AND cp_curr_date > fnd_date.canonical_to_date(
                              pay_mx_utility.get_legi_param_val('END_DATE',
                                                  ppa.legislative_parameters))*/
           AND fnd_number.canonical_to_number(g_mag_gre_id) =
                              fnd_number.canonical_to_number(
                                      pay_mx_utility.get_legi_param_val('GRE',
                                                  ppa.legislative_parameters))
           AND fnd_date.canonical_to_date(g_mag_end_date) >
                              fnd_date.canonical_to_date(
                                  pay_mx_utility.get_legi_param_val('END_DATE',
                                                  ppa.legislative_parameters))
        ORDER BY 2 DESC;

    CURSOR csr_prev_idw (cp_person_id VARCHAR2) IS
        SELECT fnd_number.canonical_to_number(pai.action_information8)
          FROM pay_payroll_actions ppa_sua,
               pay_assignment_actions paa_sua,
               pay_assignment_actions paa_arch,
               pay_action_interlocks lck,
               pay_action_information pai
         WHERE ppa_sua.payroll_action_id = paa_sua.payroll_action_id
           AND paa_sua.assignment_action_id = lck.locking_action_id
           AND lck.locked_action_id = paa_arch.assignment_action_id
           AND paa_arch.assignment_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND pai.action_information1 = cp_person_id
           AND pai.action_information4 = '07'
           AND ppa_sua.action_type = 'X'
           AND ppa_sua.report_type = 'SUA_MAG'
           AND ppa_sua.report_qualifier = 'SUA_MAG'
           AND ppa_sua.report_category = 'RT'
           AND ppa_sua.action_status = 'C'
           AND fnd_number.canonical_to_number(g_mag_gre_id) =
                              fnd_number.canonical_to_number(
                                      pay_mx_utility.get_legi_param_val('GRE',
                                                ppa_sua.legislative_parameters))
           AND fnd_date.canonical_to_date(g_mag_end_date) >
                              fnd_date.canonical_to_date(
                                  pay_mx_utility.get_legi_param_val('END_DATE',
                                                ppa_sua.legislative_parameters))
           -- Bug 5998981
           AND DECODE (pai.action_information_category,
                       'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date(pai.action_information2),
                       hr_general.start_of_time)
                      BETWEEN fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val('START_DATE',
                                                ppa_sua.legislative_parameters))
                          AND fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val('END_DATE',
                                                ppa_sua.legislative_parameters))
        ORDER BY fnd_date.canonical_to_date (pai.action_information2) DESC;

	CURSOR c_get_imp_date (cp_gre_id NUMBER) IS
        SELECT org_information6
          FROM hr_organization_information
         WHERE org_information_context = 'MX_TAX_REGISTRATION'
           AND organization_id = cp_gre_id;

   CURSOR c_get_bus_grp_id IS
     SELECT hou.business_group_id
       FROM hr_organization_units hou
      WHERE hou.organization_id = g_mag_gre_id;

    l_proc_name                   varchar2(100);
    lv_tran_type                  pay_action_information.action_information4%type;
    lv_person_id                  pay_action_information.action_information1%type;
    lv_tran_dt                    pay_action_information.action_information2%type;
    ln_tax_unit_id                number;
    ld_effective_date             date;
    ld_tran_dt                    date;
    ln_payroll_action_id          number;
    ln_assignment_action_id       number;
    ln_action_information_id      number;
    ln_prev_payroll_action_id     number;
    ln_assignment_id              number;
    ln_action_context_id          number;
    ln_idw                        number;
    ln_prev_idw                   number;
    ln_count                      number;
    lv_show_curr_trans            varchar2(1);
    lv_per_do_not_report          varchar2(1);
    lv_tran_do_not_report         varchar2(1);
    l_xml                         BLOB;
    lb_person_processed           boolean;
    lt_act_info_id                pay_payroll_xml_extract_pkg.int_tab_type;
    lt_act_info_id_exc_wd         pay_payroll_xml_extract_pkg.int_tab_type;
    lt_act_info_id_exc_trans      pay_payroll_xml_extract_pkg.int_tab_type;
    lt_tran                       per_mx_ss_affiliation.transactions;
    ln_legal_er                   NUMBER;
    ld_imp_date                   varchar2(30);
    ld_event_strt_date            VARCHAR2 (30);
    ln_business_group             NUMBER;
    lv_report_yes_no              VARCHAR2(4);
    ld_end_date                   date;
    l_new_end_date                varchar2 (25);

BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML';
    hr_utility_trace ('Entering '||l_proc_name);
    lv_per_do_not_report := 'N';
    ln_prev_payroll_action_id := -1;

    ln_assignment_action_id := pay_magtape_generic.get_parameter_value
                                                          ('TRANSFER_ACT_ID');
   hr_utility_trace ('Processing asg action '|| ln_assignment_action_id);

   ld_end_date := fnd_date.canonical_to_date (g_mag_end_date)+1;
    l_new_end_date := fnd_date.date_to_canonical (ld_end_date);
    hr_utility_trace ('End date is '|| l_new_end_date);

     OPEN c_get_bus_grp_id;
          FETCH c_get_bus_grp_id INTO ln_business_group;
      CLOSE c_get_bus_grp_id;

    ln_legal_er := hr_mx_utility.get_legal_employer(ln_business_group,
                                                    g_mag_gre_id);

    hr_utility_trace ('Fetching start date from legal employer.'|| ln_legal_er);
    OPEN c_get_imp_date (ln_legal_er);
    FETCH c_get_imp_date INTO ld_imp_date;
    CLOSE c_get_imp_date;
    hr_utility_trace ('ld_imp_date '|| ld_imp_date);

    SELECT fnd_date.date_to_canonical(MIN(creation_date))
     INTO ld_event_strt_date
    FROM pay_process_events ppe
    WHERE EXISTS
           (SELECT 1
             FROM  pay_event_updates peu
             WHERE table_name IN ('PER_ALL_PEOPLE_F','PER_ALL_ASSIGNMENTS_F','PAY_ELEMENT_ENTRIES_F','PAY_ELEMENT_ENTRY_VALUES_F')
             AND  ppe.event_update_id = peu.event_update_id
           );

    IF fnd_date.canonical_to_date(ld_event_strt_date) >= fnd_date.canonical_to_date(NVL(ld_imp_date,ld_event_strt_date)) THEN
        ld_imp_date := ld_event_strt_date;
    END IF;

    hr_utility_trace ('ld_event_strt_date '|| ld_event_strt_date);
    hr_utility_trace ('ld_imp_date '|| ld_imp_date);

    IF ld_imp_date IS NULL THEN
                ld_imp_date := pay_mx_utility.get_default_imp_date;
    END IF;
    hr_utility_trace ('Actual Implementation Date is : '|| ld_imp_date);
    OPEN csr_person(ln_assignment_action_id);
        FETCH csr_person INTO lv_person_id;
    CLOSE csr_person;

    lb_person_processed := FALSE;
    OPEN csr_asg_actions (fnd_number.canonical_to_number(lv_person_id));
    LOOP
        FETCH csr_asg_actions INTO ln_assignment_action_id,
                                   ld_effective_date;

        EXIT WHEN csr_asg_actions%NOTFOUND OR lb_person_processed;
        hr_utility_trace ('Processing magtape asg action '||
                                                      ln_assignment_action_id);

        OPEN get_emp_details (ln_assignment_action_id);
        --LOOP
            FETCH get_emp_details INTO ln_payroll_action_id,
                                       ln_action_context_id,
                                       ln_action_information_id,
                                       lv_per_do_not_report;
            IF get_emp_details%NOTFOUND AND NOT lb_person_processed THEN
                hr_utility_trace('No archived worker information found for '||
                                 'magtape asg action '||ln_assignment_action_id||
                                 '. Going back in asg actions history.');
            --END IF;
            --EXIT WHEN get_emp_details%NOTFOUND;

            ELSIF lv_per_do_not_report <> 'Y' THEN
                hr_utility_trace('Archived worker information found '||
                                 'for magtape asg action '||
                                                      ln_assignment_action_id);
                hr_utility_trace('Current archiver payroll action id = '||
                                                          ln_payroll_action_id);
                hr_utility_trace('Prev archiver payroll action id = '||
                                                     ln_prev_payroll_action_id);

                IF ln_payroll_action_id <> ln_prev_payroll_action_id THEN
                    hr_utility_trace('Worker record processed');
                    lt_act_info_id(lt_act_info_id.count() + 1) :=
                                                      ln_action_information_id;
                    ln_prev_payroll_action_id := ln_payroll_action_id;
                    lb_person_processed := TRUE;
                ELSE
                    hr_utility_trace('Worker record NOT processed');
                END IF;
            /*ELSE
                hr_utility_trace('No archived person information found for '||
                                 'asg action '||ln_assignment_action_id||
                                 '. Looking for past asg actions now.');
                EXIT;*/
            END IF;
        --END LOOP;
        CLOSE get_emp_details;
    END LOOP;
    CLOSE csr_asg_actions;

    ln_assignment_action_id := pay_magtape_generic.get_parameter_value
                                                           ('TRANSFER_ACT_ID');
    hr_utility_trace ('Fetching transactions for magtape asg action '||
                                                      ln_assignment_action_id);

    IF lv_per_do_not_report <> 'Y' THEN
    OPEN get_emp_trans (ln_assignment_action_id,ld_imp_date,l_new_end_date);
        LOOP
            FETCH get_emp_trans INTO ln_action_information_id,
                                     lv_tran_type,
                                     ln_assignment_id,
                                     lv_person_id,
                                     ln_tax_unit_id,
                                     ld_effective_date,
                                     lv_tran_do_not_report,
                                     ln_idw,
                                     lv_tran_dt,
				     lv_report_yes_no;
            EXIT WHEN get_emp_trans%NOTFOUND;
            IF lv_tran_do_not_report <> 'Y' THEN
                hr_utility_trace ('Transaction type = '||lv_tran_type||'('||
                                                               lv_tran_dt||')');

                IF lv_tran_type IN ('02', '07', '08') THEN
                    ln_count := lt_tran.COUNT();
                    lt_tran (ln_count).act_info_id := ln_action_information_id;
                    lt_tran (ln_count).tran_type := lv_tran_type;
                    lt_tran (ln_count).tran_date := lv_tran_dt;
                    lt_tran (ln_count).idw := ln_idw;
		    lt_tran (ln_count).reporting_option := lv_report_yes_no;
                ELSE
                    lt_act_info_id(lt_act_info_id.count() + 1) :=
                                                       ln_action_information_id;
                END IF;
            /*IF lv_tran_type NOT IN ('02', '08') THEN

                IF lv_tran_type = '07' THEN
                /* A salary change transaction should not be reported if: -
                   1. It is being reported for the first time in current GRE, or
                   2. IDW amount hasn't changed since it was last reported by
                      SUA.
                    IF ln_prev_idw IS NULL THEN
                        OPEN csr_prev_idw (lv_person_id);
                            FETCH csr_prev_idw INTO ln_prev_idw;
                        CLOSE csr_prev_idw;
                    END IF;

                    hr_utility_trace('Previous IDW reported for person '||
                                            lv_person_id||' is :'||ln_prev_idw);
                    IF ln_prev_idw IS NOT NULL THEN
                        IF ln_prev_idw <> ln_idw THEN
                            lt_act_info_id(lt_act_info_id.count() + 1) :=
                                                      ln_action_information_id;
                            ln_prev_idw := ln_idw;
                        ELSE
                            hr_utility_trace ('IDW has not changed. Skipping'||
                                                        ' this transaction.');
                        END IF;
                    ELSE
                        ln_prev_idw := -1;
                    END IF;
                ELSE
                    lt_act_info_id(lt_act_info_id.count() + 1) :=
                                                      ln_action_information_id;
                END IF;

            ELSE
                -- Filter out redundant hire/terminate transactions here.
                lv_show_curr_trans := 'Y';
                OPEN csr_tran_exists (ln_assignment_action_id,
                                      lv_person_id,
                                      lv_tran_type,
                                      NULL);
                    FETCH csr_tran_exists INTO ld_tran_dt;
                CLOSE csr_tran_exists;

                hr_utility_trace('Above transaction was reported on '||
                                       fnd_date.date_to_canonical(ld_tran_dt));

                IF ld_tran_dt IS NOT NULL THEN
                    ld_tran_dt := NULL;
                    IF lv_tran_type = '08' THEN
                        OPEN csr_tran_exists (ln_assignment_action_id,
                                          lv_person_id,
                                          '02',
                                          ld_tran_dt);
                    ELSE
                        OPEN csr_tran_exists (ln_assignment_action_id,
                                          lv_person_id,
                                          '08',
                                          ld_tran_dt);
                    END IF;

                    FETCH csr_tran_exists INTO ld_tran_dt;
                    CLOSE csr_tran_exists;

                    hr_utility_trace('Counter transaction of above '||
                              'transaction was reported on '||
                                   fnd_date.date_to_canonical(ld_tran_dt));
                    IF ld_tran_dt IS NULL THEN
                        hr_utility_trace('Suppressing above transaction');
                        lv_show_curr_trans := 'N';
                    END IF;
                END IF;

                IF lv_show_curr_trans = 'Y' THEN
                    lt_act_info_id(lt_act_info_id.count() + 1) :=
                                                      ln_action_information_id;
                END IF;
            END IF;
            ELSE
            lt_act_info_id_exc_trans (lt_act_info_id_exc_trans.count() + 1) :=
                                                      ln_action_information_id;*/
            END IF;
        END LOOP;
    CLOSE get_emp_trans;
    per_mx_ss_affiliation.process_transactions (
                                  lv_person_id,
                                  fnd_number.canonical_to_number(g_mag_gre_id),
                                  fnd_date.canonical_to_date(g_mag_end_date),
                                  'SUA_MAG',
                                  'SUA_MAG',
                                  'RT',
                                  lt_tran);
    ln_count := lt_tran.FIRST();
    WHILE ln_count IS NOT NULL LOOP
        lt_act_info_id (lt_act_info_id.count() + 1) :=
                                            lt_tran (ln_count).act_info_id;
        ln_count := lt_tran.NEXT(ln_count);
    END LOOP;
    END IF;

    -- Bug 4541979
    IF lt_act_info_id.count() = 0 AND
       lt_act_info_id_exc_wd.count() = 0 AND
       lt_act_info_id_exc_trans.count() = 0 THEN
        hr_utility_trace ('Nothing to write to BLOB for magtape asg action '||
                                                    ln_assignment_action_id);
    ELSE
        pay_payroll_xml_extract_pkg.generate(lt_act_info_id,
                                             NULL,
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);

        pay_payroll_xml_extract_pkg.generate(lt_act_info_id_exc_wd,
                                             'WD_EXCEPTION',
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);

        pay_payroll_xml_extract_pkg.generate(lt_act_info_id_exc_trans,
                                             'TRANS_EXCEPTION',
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);

        hr_utility_trace ('BLOB contents for magtape assignment action '||
                                                     ln_assignment_action_id);
        print_blob (pay_mag_tape.g_blob_value);
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
EXCEPTION
    WHEN OTHERS THEN
        hr_utility_trace (SQLERRM);
        RAISE;
END GENERATE_XML;


  /****************************************************************************
    Name        : GEN_XML_HEADER
    Description : This procedure generates XML header information and appends to
                  pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE GEN_XML_HEADER AS
    l_proc_name varchar2(100);
    lv_buf      varchar2(2000);
BEGIN
    l_proc_name := g_proc_name || 'GEN_XML_HEADER';
    hr_utility_trace ('Entering '||l_proc_name);

    hr_utility_trace ('Root XML tag = '||
                    pay_magtape_generic.get_parameter_value('ROOT_XML_TAG'));

    lv_buf := pay_magtape_generic.get_parameter_value('ROOT_XML_TAG');

    write_to_magtape_lob (lv_buf);

    hr_utility_trace ('BLOB contents after appending header information');
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END GEN_XML_HEADER;


  /****************************************************************************
    Name        : GEN_XML_FOOTER
    Description : This procedure generates XML information for GRE and the final
                  closing tag. Final result is appended to
                  pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE GEN_XML_FOOTER AS

    -- Bug 4864237
    CURSOR get_arch_pact_id (cp_chunk NUMBER) IS
        SELECT DISTINCT paa_arch.payroll_action_id
          FROM pay_assignment_actions paa_arch,
               pay_assignment_actions paa_mag,
               pay_action_interlocks lck
         WHERE paa_arch.assignment_action_id = lck.locked_action_id
           AND lck.locking_action_id = paa_mag.assignment_action_id
           AND paa_mag.chunk_number >= cp_chunk
           AND paa_mag.payroll_action_id =
                   pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID');

    CURSOR get_action_info_id (cp_action_context_id number) IS
        SELECT pai.action_information_id
          FROM pay_action_information pai
         WHERE pai.action_context_id = cp_action_context_id
           AND pai.action_context_type = 'PA'
           AND pai.action_information_category = 'MX SS GRE INFORMATION';

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
    l_proc_name := g_proc_name || 'GEN_XML_FOOTER';
    hr_utility_trace ('Entering '||l_proc_name);
    ln_chars := 2000;
    ln_offset := 1;

    OPEN get_arch_pact_id (1);
        FETCH get_arch_pact_id INTO ln_pact_id;
    CLOSE get_arch_pact_id;

    OPEN get_action_info_id (ln_pact_id);
        FETCH get_action_info_id INTO lt_act_info_id (lt_act_info_id.count()+1);
    CLOSE get_action_info_id;

    -- Bug 4541979
    IF lt_act_info_id.count() = 0 THEN
        hr_utility_trace('GRE Information not found for magtape payroll action '
            || pay_magtape_generic.get_parameter_value('PAYROLL_ACTION_ID'));
    ELSE
        pay_payroll_xml_extract_pkg.generate(lt_act_info_id,
                                             NULL,
                                             g_document_type,
                                             l_xml);

        -- Reload global variables if they are unset between multiple threads.
        IF g_mag_gre_id IS NULL THEN
            get_pact_info (pay_magtape_generic.get_parameter_value
                                                        ('PAYROLL_ACTION_ID'),
                           g_mag_gre_id,
                           g_mag_start_date,
                           g_mag_end_date,
                           g_mag_mode);
        END IF;

        lv_buf := '<REPORT_PERIOD>' ||
                  '<START_DATE>' || g_mag_start_date || '</START_DATE>' ||
                  '<END_DATE>' || g_mag_end_date || '</END_DATE>' ||
                  '</REPORT_PERIOD>';

        lr_xml := utl_raw.cast_to_raw(lv_buf);
        ln_amt := utl_raw.length(lr_xml);

        dbms_lob.writeAppend (l_xml,
                              ln_amt,
                              lr_xml);

        write_to_magtape_lob (l_xml);
    END IF;

    lv_buf := '</' ||
              SUBSTR(pay_magtape_generic.get_parameter_value('ROOT_XML_TAG'),
                     2);

    write_to_magtape_lob (lv_buf);

    hr_utility_trace ('BLOB contents after appending footer information');
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END GEN_XML_FOOTER;

/****************************************************************************
    Name        : INIT
    Description : Initialization code.
 *****************************************************************************/
PROCEDURE INIT
(
    P_PAYROLL_ACTION_ID number
) AS
    l_proc_name     VARCHAR2(100);
BEGIN
    l_proc_name := g_proc_name || 'INIT';
    hr_utility_trace ('Entering '||l_proc_name);

    get_pact_info (p_payroll_action_id,
                   g_mag_gre_id,
                   g_mag_start_date,
                   g_mag_end_date,
                   g_mag_mode);

    hr_utility_trace ('Leaving '||l_proc_name);
END INIT;

BEGIN
    --hr_utility.trace_on(null, 'MX_IDC');
    g_proc_name := 'PAY_MX_SUA_MAG.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'MX_SUA_MAG';
END PAY_MX_SUA_MAG;

/
