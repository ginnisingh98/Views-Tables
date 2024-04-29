--------------------------------------------------------
--  DDL for Package Body PER_MX_SS_AFFILIATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PER_MX_SS_AFFILIATION" AS
/* $Header: permxssaffiltion.pkb 120.4.12010000.13 2009/10/20 10:47:23 vvijayku ship $ */
/*
   ******************************************************************
   *                                                                *
   *  Copyright (C) 2004, Oracle India Pvt. Ltd., Hyderabad         *
   *  All rights reserved.                                          *
   *                                                                *
   *  This material has been provided pursuant to an agreement      *
   *  containing restrictions on its use.  The material is also     *
   *  protected by copyright law.  No part of this material may     *
   *  be copied or distributed, transmitted or transcribed, in      *
   *  any form or by any means, electronic, mechanical, magnetic,   *
   *  manual, or otherwise, or disclosed to third parties without   *
   *  the express written permission of Oracle Corporation,         *
   *  500 Oracle Parkway, Redwood City, CA, 94065.                  *
   *                                                                *
   ******************************************************************
    Package Name        : PER_MX_SS_AFFILIATION
    Package File Name   : permxssaffiltion.pkb

    Description : Used for Social Security Affiliation report.

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sdahiya       28-Jan-2007 115.0           Created.
    sdahiya       08-Mar-2007 115.1   5919339 Modified cusror get_emp_details
                                              so that it converts IDW archived
                                              in canonical format into numeric
                                              format.
    sdahiya       12-Apr-2007 115.2   5985804 Modified action_creation so that
                                              duplicate interlocks are not
                                              inserted.
    sdahiya       13-Apr-2007 115.3           07 transactions should not be
                                              reported if IDW amount hasn't
                                              changed since it was reported
                                              last.
    sdahiya       16-Apr-2007 115.4   5996000 PL/SQL table should not be read
                                              after dynamic truncation.
    sdahiya       19-Apr-2007 115.5   5998981 Modified cursor csr_prev_idw to
                                              conditionally convert canonical
                                              date stamped on action information
                                              DDF.
    sdahiya       20-Apr-2007 115.6   6002963 Affiliation report should suppress
                                              07 transactions which are archived
                                              with rehire.
                                              Procedure process_transactions
                                              created to identify and eliminate
                                              redundant transactions.
    sdahiya       22-Apr-2007 115.7           Modified process_transactions to
                                              eliminate multiple 08 and 02
                                              transactions. The earliest 08
                                              and latest 02 will be reported.
                                              Added parameters to this procedure
                                              so that it may be called from
                                              SUA.
    sdahiya       26-Apr-2007 115.8   6008833 Modified range_cursor so that it
                                              does not discard persons when
                                              the report is run after persons'
                                              GRE transfer.
    sdahiya       15-May-2007 115.9           Modified action_creation and
                                              generate_xml so that past-dated
                                              transactions are picked.
    sdahiya       16-May-2007 115.10          Version uprev after establishing
                                              dual maintenance.
    sdahiya       18-May-2007 115.11  6060070 Changed multiple SQL statements
                                              to conditionally convert
                                              canonical date stamped on DDF into
                                              date.
   sdahiya        22-May-2007 115.12  6065124 Modified get_emp_details.
   sivanara       27-jun-2008 115.13  7185703 Added logic to filter the transaction
                                              before implementation date
   sivanara       16-jul-2008 115.14  7258802 In the procedure process_transaction
                                              modified cursor csr_prev_idw by adding
					      trunc on fnd_date.canonical_to_date to
					      consider the first run of the GRE.
   swamukhe       04-Oct-2008 115.18  6451017 Commented a set of code to so that the
                                              rehire and termination.
   vvijayku       07-Nov-2008 115.19  6451017 Modified the cursor get_emp_trans to get the
                                              value of the option yes/no archived.Also
					      added logic in PROCESS_TRANSACTION to filter
					      out the 02 and 08 transactions depending on the
					      reporting option.
   vvijayku       10-Nov-2008 115.20  6451017 Added a filteration condition in process_transctions
                                              to filter out the extra 07 transactions.
   vvijayku       15-Nov-2008 115.21  7568378 Added more code in PROCESS_TRANSACTIONS to remove the
                                              regression it created in the normal termination reporting.
   vvijayku       19-Nov-2009 115.22  8768679 Added code to report the 08 transactions one day before the
                                              date of transaction.
   vvijayku       20-Nov-2009 115.23  8768679 Added comments about the changes made for the fix.
   vvijayku       20-Nov-2009 115.24  8768679 Modified the comments added earlier.
   ***************************************************************************/

--
-- Global Variables
--

    TYPE num_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    g_proc_name        varchar2(240);
    g_debug            boolean;
    g_document_type    varchar2(50);
    g_trans_gre_id     number;
    g_business_group   number;
    g_start_date       varchar2(25);
    g_end_date         varchar2(25);
    g_gre_tab          num_tab;


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
    Name        : GET_START_DATE
    Description : This procedure fetches start date of reporting period.
  *****************************************************************************/
FUNCTION GET_START_DATE
(
    P_TRANS_GRE number
) RETURN VARCHAR2 AS
    CURSOR csr_get_date_dispmag IS
        SELECT fnd_date.date_to_canonical (effective_date + 1/(24 * 60 * 60))
          FROM pay_payroll_actions
         WHERE report_type = 'SS_AFFILIATION'
           AND report_qualifier IN ('HIRES', 'SEPARATIONS', 'SALARY')
           AND pay_mx_utility.get_legi_param_val('TRANS_GRE',
                                                 legislative_parameters,
                                                 ' ') = TO_CHAR(p_trans_gre)
      ORDER BY payroll_action_id DESC;


    CURSOR csr_get_date_affl IS
        SELECT fnd_date.date_to_canonical(
               fnd_date.canonical_to_date(
                                pay_mx_utility.get_legi_param_val('END_DATE',
                                                     legislative_parameters)) +
                                                     1/(24 * 60 * 60))
          FROM pay_payroll_actions
         WHERE report_type = 'MX_SS_AFFL'
           AND report_qualifier = 'MX_SS_AFFL'
           AND pay_mx_utility.get_legi_param_val('TRANS_GRE',
                                                 legislative_parameters) =
                                                            TO_CHAR(p_trans_gre)
      ORDER BY payroll_action_id DESC;

    CURSOR c_get_imp_date (cp_organization_id NUMBER) IS
        SELECT org_information6
          FROM hr_organization_information
         WHERE org_information_context = 'MX_TAX_REGISTRATION'
           AND organization_id = cp_organization_id;

    CURSOR c_get_bus_grp_id IS
        SELECT hou.business_group_id
          FROM hr_organization_units hou
         WHERE hou.organization_id = p_trans_gre;

     l_proc_name    varchar2(100);
     l_start_date   varchar2(30);
     ln_bus_grp_id  number;
     ln_legal_er    number;
BEGIN
    l_proc_name := g_proc_name || 'GET_START_DATE';
    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('p_trans_gre = '||p_trans_gre);

    OPEN csr_get_date_affl;
        hr_utility_trace ('Fetching start date from last affiliation '||
                                                                'report run.');
        FETCH csr_get_date_affl INTO l_start_date;
    CLOSE csr_get_date_affl;

    IF l_start_date IS NULL THEN
        hr_utility_trace ('Fetching start date from last DISPMAG run.');
        OPEN csr_get_date_dispmag;
            FETCH csr_get_date_dispmag INTO l_start_date;
        CLOSE csr_get_date_dispmag;

        IF l_start_date IS NULL THEN
            OPEN c_get_bus_grp_id;
                FETCH c_get_bus_grp_id INTO ln_bus_grp_id;
            CLOSE c_get_bus_grp_id;
            ln_legal_er := hr_mx_utility.get_legal_employer(ln_bus_grp_id,
                                                            p_trans_gre);
            hr_utility_trace ('Fetching start date from legal employer.');
            OPEN c_get_imp_date (ln_legal_er);
                FETCH c_get_imp_date INTO l_start_date;
            CLOSE c_get_imp_date;

            IF l_start_date IS NULL THEN
                l_start_date := pay_mx_utility.get_default_imp_date;
            END IF;
        END IF;
    END IF;

    hr_utility_trace ('l_start_date = ' || l_start_date);
    hr_utility_trace ('Leaving '||l_proc_name);

    RETURN (l_start_date);
END GET_START_DATE;

  /****************************************************************************
    Name        : GET_PACT_INFO
    Description : This procedure fetches payroll action level information.
  *****************************************************************************/
PROCEDURE GET_PACT_INFO
(
    P_PAYROLL_ACTION_ID number,
    P_BUSINESS_GROUP    OUT NOCOPY number,
    P_TRANS_GRE_ID      OUT NOCOPY number,
    P_START_DATE        OUT NOCOPY varchar2,
    P_END_DATE          OUT NOCOPY varchar2
) IS
    CURSOR csr_get_pact_info IS
        SELECT pay_mx_utility.get_legi_param_val('TRANS_GRE',
                                                 ppa.legislative_parameters),
               pay_mx_utility.get_legi_param_val('START_DATE',
                                                 ppa.legislative_parameters),
               pay_mx_utility.get_legi_param_val('END_DATE',
                                                 ppa.legislative_parameters),
               business_group_id
          FROM pay_payroll_actions ppa
         WHERE ppa.payroll_action_id = p_payroll_action_id;

    CURSOR csr_gre IS
        SELECT organization_id
          FROM hr_organization_information
         WHERE org_information_context = 'MX_SOC_SEC_DETAILS'
           AND org_information3 = 'N'
           AND org_information6 = g_trans_gre_id;

    l_proc_name varchar2(100);
    ln_gre_id   number;
BEGIN
    l_proc_name := g_proc_name || 'GET_PACT_INFO';
    hr_utility_trace ('Entering '||l_proc_name);

    OPEN csr_get_pact_info;
        FETCH csr_get_pact_info INTO p_trans_gre_id,
                                     p_start_date,
                                     p_end_date,
                                     p_business_group;
    CLOSE csr_get_pact_info;

    g_gre_tab.DELETE();
    g_gre_tab(g_trans_gre_id) := g_trans_gre_id;
    OPEN csr_gre;
    LOOP
        FETCH csr_gre INTO ln_gre_id;
        EXIT WHEN csr_gre%NOTFOUND;
        g_gre_tab(ln_gre_id) := ln_gre_id;
    END LOOP;
    CLOSE csr_gre;

    hr_utility_trace ('Leaving '||l_proc_name);
END GET_PACT_INFO;


  /************************************************************
    Name      : DERIVE_GRE_FROM_LOC_SCL
    Purpose   : This function derives the gre from the parmeters
                location, BG and soft-coded keyflex.
  ************************************************************/
FUNCTION DERIVE_GRE_FROM_LOC_SCL(
    P_LOCATION_ID               NUMBER,
    P_BUSINESS_GROUP_ID         NUMBER,
    P_SOFT_CODING_KEYFLEX_ID    NUMBER,
    P_EFFECTIVE_DATE            DATE)
RETURN NUMBER AS

    ln_gre_id       NUMBER;
    l_is_ambiguous  BOOLEAN;
    l_missing_gre   BOOLEAN;
BEGIN
    IF p_soft_coding_keyflex_id IS NOT NULL THEN
        ln_gre_id := hr_mx_utility.get_gre_from_scl(p_soft_coding_keyflex_id);
    END IF;

    IF ln_gre_id IS NULL THEN
        ln_gre_id := hr_mx_utility.get_gre_from_location(
                                            p_location_id,
                                            p_business_group_id,
                                            p_effective_date,
                                            l_is_ambiguous,
                                            l_missing_gre );
        IF ln_gre_id IS NULL THEN
           IF l_is_ambiguous THEN
              ln_gre_id := -1;
           END IF;

           IF l_missing_gre THEN
              ln_gre_id := -2;
           END IF;
        END IF;
    END IF;

    RETURN (ln_gre_id);

END DERIVE_GRE_FROM_LOC_SCL;


  /****************************************************************************
    Name        : RANGE_CURSOR
    Description : This procedure prepares range of persons to be processed.
  *****************************************************************************/
PROCEDURE RANGE_CURSOR
(
    P_PAYROLL_ACTION_ID number,
    P_SQLSTR            OUT NOCOPY varchar2
) AS

    l_proc_name varchar2(100);
    ld_end_date    date;
    l_new_end_date varchar2(25);

BEGIN
    l_proc_name := g_proc_name || 'RANGE_CURSOR';

    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);

    get_pact_info (p_payroll_action_id,
                   g_business_group,
                   g_trans_gre_id,
                   g_start_date,
                   g_end_date);

/*Bug 8768679 - Added the following code to increase the g_end_date by 1
so that it cane be used in the range cursor and it will pick the future
hired employee*/

ld_end_date := fnd_date.canonical_to_date (g_end_date)+1;
l_new_end_date := fnd_date.date_to_canonical (ld_end_date);
hr_utility_trace ('End date is '|| l_new_end_date);


    -- Bug 6008833
    p_sqlstr :=
'SELECT DISTINCT person_id
  FROM per_assignments_f
 WHERE business_group_id = '||g_business_group||'
   /*AND fnd_date.canonical_to_date('''||l_new_end_date
                     ||''') BETWEEN effective_start_date AND effective_end_date*/
 AND per_mx_ss_affiliation.derive_gre_from_loc_scl (location_id,
                                                business_group_id,
                                                soft_coding_keyflex_id,
                                                fnd_date.canonical_to_date('''||
                                                l_new_end_date||''')) IN
(SELECT organization_id
  FROM hr_organization_information
 WHERE org_information_context = ''MX_SOC_SEC_DETAILS''
   AND (org_information3 = ''N''
   AND org_information6 = '|| g_trans_gre_id ||'
    OR organization_id = '||g_trans_gre_id||'))
 AND :p_payroll_action_id > 0
 ORDER BY person_id';

    hr_utility_trace ('Range cursor query : ' || p_sqlstr);
    hr_utility_trace ('Leaving '||l_proc_name);

END RANGE_CURSOR;


  /****************************************************************************
    Name        : ACTION_CREATION
    Description : This procedure creates assignment actions.
  *****************************************************************************/
PROCEDURE ACTION_CREATION
(
    P_PAYROLL_ACTION_ID number,
    P_START_PERSON_ID   number,
    P_END_PERSON_ID     number,
    P_CHUNK             number
) AS

    /*Bug 8768679 - Added decode statements in the cursor so that  only for  08 type ,future dated transactions are also selected*/
    CURSOR c_affl_person (p_end_date VARCHAR2) IS
        SELECT DISTINCT paf.person_id,
               paf.assignment_id,
               pai.action_context_id,
               paf.primary_flag,
               pai.tax_unit_id
          FROM per_assignments_f paf,
               pay_action_information pai
         WHERE pai.action_information_category = 'MX SS TRANSACTIONS'
           AND paf.business_group_id = g_business_group
           AND paf.person_id BETWEEN p_start_person_id AND p_end_person_id
           AND paf.person_id = pai.action_information1
           AND pai.action_information4 IN ('02', '07', '08')
           AND NVL(pai.action_information10, 'N') <> 'Y'
           -- Bug 6060070
           AND (DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) BETWEEN
                                      fnd_date.canonical_to_date (g_start_date)
                                      /*Bug 8768679*/
                                  AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_end_date))
               OR (pai.effective_date BETWEEN
                                      fnd_date.canonical_to_date (g_start_date)
				      /*Bug 8768679*/
                                  AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_end_date))
                   /*NOT EXISTS (SELECT 'X'
                                 FROM pay_payroll_actions ppa_affl,
                                      pay_assignment_actions paa_affl,
                                      pay_action_interlocks lck
                                WHERE lck.locked_action_id = pai.action_context_id
                                  AND lck.locking_action_id = paa_affl.assignment_action_id
                                  AND paa_affl.payroll_action_id = ppa_affl.payroll_action_id
                                  AND ppa_affl.report_type = 'MX_SS_AFFL'
                                  AND ppa_affl.report_qualifier = 'MX_SS_AFFL'
                                  AND ppa_affl.report_category = 'RT'
                                  AND ppa_affl.action_status = 'C')*/
                   -- Bug 6060070
		   /*Bug 8768679*/
                   AND DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) <=
                                        fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_end_date))
                  )
               )
           /*AND fnd_date.canonical_to_date (g_end_date) BETWEEN
                                                        paf.effective_start_date
                                                    AND paf.effective_end_date*/
        ORDER BY paf.person_id,
                 pai.action_context_id,
                 decode (paf.primary_flag, 'Y', 1, 2),
                 paf.assignment_id;

    /*Bug 8768679 - Added decode statements in the cursor so that  only for  08 type ,future dated transactions are also selected*/
    CURSOR c_affl_person_range (p_end_date VARCHAR2) IS
        SELECT DISTINCT paf.person_id,
               paf.assignment_id,
               pai.action_context_id,
               paf.primary_flag,
               pai.tax_unit_id
          FROM per_assignments_f paf,
               pay_action_information pai,
               pay_population_ranges ppr
         WHERE pai.action_information_category = 'MX SS TRANSACTIONS'
           AND paf.business_group_id = g_business_group
           AND ppr.payroll_action_id = p_payroll_action_id
           AND ppr.chunk_number = p_chunk
           AND paf.person_id = ppr.person_id
           AND paf.person_id = pai.action_information1
           AND pai.action_information4 IN ('02', '07', '08')
           AND NVL(pai.action_information10, 'N') <> 'Y'
           -- Bug 6060070
           AND (DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) BETWEEN
                                      fnd_date.canonical_to_date (g_start_date)
				      /*Bug 8768679*/
                                  AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_end_date))
               OR (pai.effective_date BETWEEN
                                      trunc(fnd_date.canonical_to_date (g_start_date))
				      /*Bug 8768679*/
                                  AND trunc(fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_end_date)))
                   /*NOT EXISTS (SELECT 'X'
                                 FROM pay_payroll_actions ppa_affl,
                                      pay_assignment_actions paa_affl,
                                      pay_action_interlocks lck
                                WHERE lck.locked_action_id = pai.action_context_id
                                  AND lck.locking_action_id = paa_affl.assignment_action_id
                                  AND paa_affl.payroll_action_id = ppa_affl.payroll_action_id
                                  AND ppa_affl.report_type = 'MX_SS_AFFL'
                                  AND ppa_affl.report_qualifier = 'MX_SS_AFFL'
                                  AND ppa_affl.report_category = 'RT'
                                  AND ppa_affl.action_status = 'C')*/
                   -- Bug 6060070
		   /*Bug 8768679*/
                   AND DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) <=
                                        fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',p_end_date,g_end_date))
                  )
               )
           /*AND fnd_date.canonical_to_date (g_end_date) BETWEEN
                                                       paf.effective_start_date
                                                   AND paf.effective_end_date*/
        ORDER BY paf.person_id,
                 pai.action_context_id,
                 decode (paf.primary_flag, 'Y', 1, 2),
                 paf.assignment_id;

/*Bug 8768679 - The following cursor has been added to find out if
the Archiver Assignment action has been already locked in pay_action_interlocks*/

CURSOR c_assg_action_exist (p_arch_asg_act NUMBER) IS
        SELECT count(*)
        FROM pay_action_interlocks
        WHERE locked_action_id = p_arch_asg_act;

/*Bug 8768679 - The follwowing cursor has been added to find out if
the archiver assignment action has already been locked by another
Affiliation report*/

CURSOR c_report_type (p_arch_asg_act NUMBER) IS
        SELECT count(*)
        FROM pay_payroll_actions pact,
             pay_assignment_actions paa,
             pay_action_interlocks pail
        WHERE p_arch_asg_act = pail.locked_action_id
        AND pail.locking_action_id = paa.assignment_action_id
        AND paa.payroll_action_id = pact.payroll_action_id
        AND pact.report_type = 'MX_SS_AFFL';

    l_proc_name                 varchar2(100);
    lb_range_person_on          boolean;
    ln_person_id                number;
    ln_prev_person_id           number;
    ln_prev_arch_asg_act        number;
    ln_arch_asg_act             number;
    ln_asg_id                   number;
    ln_affl_asg_act             number;
    ln_tax_unit_id              number;
    lv_primary_flag             per_assignments_f.primary_flag%type;
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

    IF g_business_group IS NULL THEN
        get_pact_info (p_payroll_action_id,
                       g_business_group,
                       g_trans_gre_id,
                       g_start_date,
                       g_end_date);
    END IF;

/*Bug 8768679 - Added the following code to increase the g_end_date by 1
so that it cane be used in the action creation cursors */

    ld_end_date := fnd_date.canonical_to_date (g_end_date)+1;
    l_new_end_date := fnd_date.date_to_canonical (ld_end_date);
    hr_utility_trace ('End date is '|| l_new_end_date);

    ln_prev_person_id := -1;
    ln_prev_arch_asg_act := -1;

    lb_range_person_on := pay_ac_utility.range_person_on(
                               p_report_type      => 'MX_SS_AFFL',
                               p_report_format    => 'MX_SS_AFFL',
                               p_report_qualifier => 'MX_SS_AFFL',
                               p_report_category  => 'RT');

    IF lb_range_person_on THEN
        hr_utility_trace ('Person ranges are ON');
        OPEN c_affl_person_range (l_new_end_date); --Bug 8768679
    ELSE
        hr_utility_trace ('Person ranges are OFF');
        OPEN c_affl_person (l_new_end_date); --Bug 8768679
    END IF;

    LOOP
        IF lb_range_person_on THEN

               FETCH c_affl_person_range INTO ln_person_id,
                                           ln_asg_id,
                                           ln_arch_asg_act,
                                           lv_primary_flag,
                                           ln_tax_unit_id;



	 EXIT WHEN c_affl_person_range%NOTFOUND;
        ELSE
            FETCH c_affl_person INTO ln_person_id,
                                     ln_asg_id,
                                     ln_arch_asg_act,
                                     lv_primary_flag,
                                     ln_tax_unit_id;

	    hr_utility_trace('Current person = '||ln_person_id);
            hr_utility_trace('ln_asg_id '||ln_asg_id);
            hr_utility_trace('ln_arch_asg_act'||ln_arch_asg_act);
            hr_utility_trace('lv_primary_flag '||lv_primary_flag);
            hr_utility_trace('ln_tax_unit_id '||ln_tax_unit_id);

            EXIT WHEN c_affl_person%NOTFOUND;
        END IF;

        IF g_gre_tab.EXISTS(ln_tax_unit_id) THEN
            hr_utility_trace ('-------------');
            hr_utility_trace('Current person = '||ln_person_id);
            hr_utility_trace('Previous person = '||ln_prev_person_id);

	    OPEN c_assg_action_exist (ln_arch_asg_act);
            FETCH c_assg_action_exist INTO ln_exist;
            CLOSE c_assg_action_exist;

            OPEN c_report_type (ln_arch_asg_act);
            FETCH c_report_type INTO l_report;
            CLOSE c_report_type;

         /*Bug 8768679 - The current archiver assignment action will be processed and reported only if
        it is not locked by another Affiliation report or if it has not been reported yet.
	The following IF condition is used for that purpose.*/

	 IF (ln_exist = 0 OR l_report = 0) THEN
            IF (ln_person_id <> ln_prev_person_id) THEN
                SELECT pay_assignment_actions_s.nextval
                  INTO ln_affl_asg_act
                  FROM dual;

                hr_utility_trace('Creating affiliation report assignment action '||
                                                              ln_affl_asg_act);
                hr_nonrun_asact.insact(ln_affl_asg_act,
                                      ln_asg_id,
                                      p_payroll_action_id,
                                      p_chunk,
                                      g_trans_gre_id,
                                      null,
                                      'U',
                                      null);
                ln_prev_person_id := ln_person_id;
            ELSE
                hr_utility_trace('Affiliation assignment action not created');
            END IF;
	   ELSE
                hr_utility_trace('Affiliation assignment action need not be created');
           END IF;

	    /*Bug 8768679 - The current archiver assignment action will be processed and reported only if
        it is not locked by another Affiliation report or if it has not been reported yet.
	The following IF condition is used for that purpose.*/

	  IF (ln_exist = 0 OR l_report = 0) THEN
            -- Bug 5985804
            IF (ln_prev_arch_asg_act <> ln_arch_asg_act) THEN
                hr_nonrun_asact.insint (ln_affl_asg_act,
                                        ln_arch_asg_act);
                hr_utility_trace('SS archiver asg action '||ln_arch_asg_act||
                  ' locked by affiliation report asg action '||ln_affl_asg_act);
                ln_prev_arch_asg_act := ln_arch_asg_act;
            ELSE
                hr_utility_trace ('SS archiver asg action '|| ln_arch_asg_act ||
                ' already locked by affiliation asg action '|| ln_affl_asg_act);
            END IF;
          ELSE
                hr_utility_trace('The transaction has already been reported in earlier reports');
          END IF;
        END IF;
    END LOOP;

    IF lb_range_person_on THEN
        CLOSE c_affl_person_range;
    ELSE
        CLOSE c_affl_person;
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
EXCEPTION
    WHEN OTHERS THEN
        hr_utility_trace (SQLERRM);
        RAISE;
END ACTION_CREATION;


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
                   g_business_group,
                   g_trans_gre_id,
                   g_start_date,
                   g_end_date);

    hr_utility_trace ('Leaving '||l_proc_name);
END INIT;


  /****************************************************************************
    Name        : PROCESS_TRANSACTIONS
    Description : This procedures runs through transactions to eliminate
                  redundant ones as explained below: -
                  08 - Hire transactions are always reported unless followed
                       by a termination transaction (02) within the reporting
                       period.
                  07 - Salary modification transaction will be reported only
                       if there has been a change in IDW amount since the
                       previous salary modification. Salary modification
                       transactions archived with hire/re-hire will be
                       suppressed.
                  02 - Termination transactions are always reported unless
                       preceeded by a hire transaction within the reporting
                       period.
  *****************************************************************************/
PROCEDURE PROCESS_TRANSACTIONS
(
    P_PERSON_ID         NUMBER,
    P_GRE_ID            NUMBER,
    P_END_DATE          DATE,
    P_REPORT_TYPE       VARCHAR2,
    P_REPORT_QUALIFIER  VARCHAR2,
    P_REPORT_CATEGORY   VARCHAR2,
    P_TRANSACTIONS IN OUT NOCOPY transactions
) AS

    CURSOR csr_prev_idw(cp_gre_token VARCHAR2) IS
        SELECT fnd_number.canonical_to_number(pai.action_information8)
          FROM pay_payroll_actions ppa_mag,
               pay_assignment_actions paa_mag,
               --pay_assignment_actions paa_arch,
               pay_action_interlocks lck,
               pay_action_information pai
         WHERE ppa_mag.payroll_action_id = paa_mag.payroll_action_id
           AND paa_mag.assignment_action_id = lck.locking_action_id
           /*AND lck.locked_action_id = paa_arch.assignment_action_id
           AND paa_arch.assignment_action_id = pai.action_context_id*/
           AND lck.locked_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND pai.action_information1 = p_person_id
           AND pai.action_information4 IN  ('07','08')
           AND ppa_mag.action_type = 'X'
           AND ppa_mag.report_type = p_report_type
           AND ppa_mag.report_qualifier = p_report_qualifier
           AND ppa_mag.report_category = p_report_category
           AND ppa_mag.action_status = 'C'
           AND p_gre_id = fnd_number.canonical_to_number(
                                 pay_mx_utility.get_legi_param_val(cp_gre_token,
                                               ppa_mag.legislative_parameters))
           AND p_end_date > fnd_date.canonical_to_date(
                                  pay_mx_utility.get_legi_param_val('END_DATE',
                                               ppa_mag.legislative_parameters))
           -- Bug 5998981
	   /*Bug 8768679 - A decode statement has been added so that previous idw value can be obtained
	   when the transaction date of the immediate earlier 08 transaction lies between START_DATE and
	   END_DATE+1*/
           AND DECODE (pai.action_information_category,
                       'MX SS TRANSACTIONS',
                       TRUNC(fnd_date.canonical_to_date(pai.action_information2)),
                       hr_general.start_of_time)
                      BETWEEN TRUNC(fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val('START_DATE',
                                               ppa_mag.legislative_parameters)))
                          AND DECODE (pai.action_information4,'08',
                          (TRUNC (fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val('END_DATE',
                                               ppa_mag.legislative_parameters)))+1),
                          (TRUNC (fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val('END_DATE',
                                               ppa_mag.legislative_parameters)))))
        ORDER BY fnd_date.canonical_to_date (pai.action_information2) DESC;

    l_proc_name     VARCHAR2(100);
    lv_gre_token    VARCHAR2(20);
    ln_cntr         NUMBER;
    ln_prev_idw     NUMBER;
    ln_hire_idx     NUMBER;
    ln_term_idx     NUMBER;
    lv_hire_date    pay_action_information.action_information2%TYPE;
BEGIN
    l_proc_name := g_proc_name || 'PROCESS_TRANSACTIONS';
    hr_utility_trace ('Entering '||l_proc_name);

    ln_prev_idw := -1;
    ln_hire_idx := -1;
    ln_term_idx := -1;
    lv_hire_date:= 'NULL';
    ln_cntr := p_transactions.FIRST();

    IF p_report_type = 'MX_SS_AFFL' AND
       p_report_qualifier = 'MX_SS_AFFL' AND
       p_report_category = 'RT' THEN
        lv_gre_token := 'TRANS_GRE';
    ELSIF p_report_type = 'SUA_MAG' AND
          p_report_qualifier = 'SUA_MAG' AND
          p_report_category = 'RT' THEN
        lv_gre_token := 'GRE';
    END IF;

    WHILE ln_cntr IS NOT NULL LOOP
        hr_utility_trace ('Transaction = '||
                                    p_transactions(ln_cntr).tran_type||' ('||
                                    p_transactions(ln_cntr).tran_date||')');
        IF p_transactions(ln_cntr).tran_type = '08' THEN
            IF ln_hire_idx <> -1 THEN
                -- Eliminate current hire transaction if one 08 is already in.
                p_transactions.DELETE(ln_cntr);
                hr_utility_trace ('One hire transaction already exists. '||
                               'Above hire transaction will not be reported.');
            ELSE
                lv_hire_date := p_transactions(ln_cntr).tran_date;
                ln_hire_idx := ln_cntr;
            END IF;
        ELSIF p_transactions(ln_cntr).tran_type = '07' THEN
            IF p_transactions(ln_cntr).tran_date = lv_hire_date THEN
                p_transactions.DELETE(ln_cntr);
                lv_hire_date := 'NULL';
                hr_utility_trace('This 07 transaction will be suppressed as '||
                   'it was archived upon hire.');
            ELSE
                IF ln_prev_idw = -1 THEN
                    OPEN csr_prev_idw (lv_gre_token);
                        FETCH csr_prev_idw INTO ln_prev_idw;
                    CLOSE csr_prev_idw;
                END IF;
                hr_utility_trace('Previous IDW amount = '||ln_prev_idw);
                hr_utility_trace('Current IDW amount = '||
                                                p_transactions(ln_cntr).idw);
                IF ln_prev_idw = p_transactions(ln_cntr).idw THEN
                    p_transactions.DELETE(ln_cntr);
                    hr_utility_trace('No change in IDW. Transaction '||
                                                                'suppressed.');
	        /*ELSIF ln_prev_idw = -1 THEN
                    p_transactions.DELETE(ln_cntr);
                    hr_utility_trace('07 Transaction not to be reported');*/
                ELSE
                    ln_prev_idw := p_transactions(ln_cntr).idw;
                END IF;
            END IF;
        ELSIF p_transactions(ln_cntr).tran_type = '02' THEN
            IF p_transactions(ln_cntr).reporting_option = 'Yes' THEN
            -- Look ahead to see if there are any terminations in future
            ln_term_idx := p_transactions.NEXT(ln_cntr);
            WHILE ln_term_idx IS NOT NULL LOOP
                IF p_transactions(ln_term_idx).tran_type = '02' THEN
                    p_transactions.DELETE(ln_cntr);
                    hr_utility_trace('A termination transaction exists in '||
                        'future. Above termination will not be reported.');
                END IF;
                ln_term_idx := p_transactions.NEXT(ln_term_idx);
            END LOOP;

	    ELSIF p_transactions(ln_cntr).reporting_option = 'No' THEN
            ln_term_idx := p_transactions.NEXT(ln_cntr);
	    IF p_transactions.EXISTS(ln_cntr+1) = TRUE THEN
	    WHILE ln_term_idx IS NOT NULL LOOP
                IF p_transactions(ln_term_idx).tran_type = '02' THEN
                    p_transactions.DELETE(ln_cntr);
                    hr_utility_trace('A termination transaction exists in '||
                        'future. Above termination will not be reported.');
	        ELSIF p_transactions(ln_term_idx).tran_type = '08' THEN
                   p_transactions.DELETE(ln_cntr);
                   p_transactions.DELETE(ln_term_idx);
	        END IF;
		ln_term_idx := p_transactions.NEXT(ln_term_idx);
	     END LOOP;
	     /*ln_term_idx := p_transactions.NEXT(ln_cntr);
                IF p_transactions(ln_term_idx).tran_type = '08' THEN
                   p_transactions.DELETE(ln_cntr);
                   p_transactions.DELETE(ln_term_idx);
		END IF;*/
            ELSE
                ln_term_idx := p_transactions.NEXT(ln_cntr);
            WHILE ln_term_idx IS NOT NULL LOOP
                IF p_transactions(ln_term_idx).tran_type = '02' THEN
                    p_transactions.DELETE(ln_cntr);
                    hr_utility_trace('A termination transaction exists in '||
                        'future. Above termination will not be reported.');
                END IF;
                    ln_term_idx := p_transactions.NEXT(ln_term_idx);
            END LOOP;
                END IF;
             END IF;
           END IF;
-- commented
          /*  IF ln_hire_idx <> -1 AND p_transactions.EXISTS(ln_cntr) THEN
                LOOP
                    p_transactions.DELETE(ln_hire_idx);
                    ln_hire_idx := p_transactions.NEXT(ln_hire_idx);
                    p_transactions.DELETE(ln_hire_idx);
                    EXIT WHEN ln_hire_idx = ln_cntr;
                END LOOP;
                ln_hire_idx := -1;
                hr_utility_trace ('Person '||p_person_id||
                   ' hired and later terminated within the reporting period.');
            END IF; */

        ln_cntr := p_transactions.NEXT(ln_cntr);
    END LOOP;

    hr_utility_trace ('------------------------');
    ln_cntr := p_transactions.FIRST();
    hr_utility_trace ('After transaction filtering, eligible ones are: -');
    WHILE ln_cntr IS NOT NULL LOOP
        hr_utility_trace ('Transaction = '||
                                    p_transactions(ln_cntr).tran_type||' ('||
                                    p_transactions(ln_cntr).tran_date||')');
        ln_cntr := p_transactions.NEXT(ln_cntr);
    END LOOP;
    hr_utility_trace ('------------------------');

    hr_utility_trace ('Leaving '||l_proc_name);
END PROCESS_TRANSACTIONS;


  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE GENERATE_XML AS

   CURSOR get_emp_details (cp_person_id number) IS
        SELECT pai.action_information_id,
               pai.action_information1, -- Person ID
               pai.action_information7, -- Employee name
               pai.action_information8, -- Worker Type
               pai.action_information9, -- RWW Indicator
               pai.action_information10, -- Hire Date
               -- Bug 5919339
               fnd_number.canonical_to_number(pai.action_information11), -- IDW
               pai.action_information18 -- Salary Type
          -- Bug 6065124
         FROM pay_action_information pai /*,
               pay_assignment_actions paa_arch,
               pay_action_interlocks lck*/
         WHERE pai.action_information_category = 'MX SS PERSON INFORMATION'
            /*and lck.locking_action_id = cp_assignment_action_id
           AND lck.locked_action_id = pai.action_context_id*/
           AND pai.action_context_type = 'AAP'
           AND pai.action_information1 = cp_person_id
           AND nvl(pai.action_information21, 'N') <> 'Y' -- Do not report flag
           AND pai.effective_date <= fnd_date.canonical_to_date (g_end_date)
      ORDER BY pai.effective_date DESC/*,
               decode (paf.primary_flag, 'Y', 1, 2),
               paf.assignment_id*/;

    CURSOR csr_asg_actions (cp_person_id number) IS
        /*SELECT fnd_number.canonical_to_number(
                   pay_magtape_generic.get_parameter_value ('TRANSFER_ACT_ID')),
               fnd_date.canonical_to_date (g_end_date)
          FROM dual
        UNION
        SELECT paa.assignment_action_id,
               fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val('END_DATE',
                                                    ppa.legislative_parameters))
          FROM pay_payroll_actions ppa,
               pay_assignment_actions paa,
               pay_action_information pai,
               pay_action_interlocks lck
         WHERE paa.payroll_action_id = ppa.payroll_action_id
           AND paa.assignment_action_id = lck.locking_action_id
           AND pai.action_context_id = lck.locked_action_id
           AND pai.action_information_category = 'MX SS PERSON INFORMATION'
           AND pai.action_information1 = cp_person_id
           AND ppa.report_type = 'MX_SS_AFFL'
           AND ppa.report_qualifier = 'MX_SS_AFFL'
           AND ppa.report_category = 'RT'
           AND ppa.action_status = 'C'
           AND pay_mx_utility.get_legi_param_val('TRANS_GRE',
                                                 ppa.legislative_parameters) =
                                                                 g_trans_gre_id
           AND fnd_date.canonical_to_date(
                                 pay_mx_utility.get_legi_param_val('END_DATE',
                                                 ppa.legislative_parameters)) <
                                       fnd_date.canonical_to_date (g_end_date)
        ORDER BY 2 DESC;*/


        SELECT pai.action_context_id,
               pai.effective_date
          FROM pay_action_information pai
         WHERE pai.action_information_category = 'MX SS PERSON INFORMATION'
           AND pai.action_information1 = cp_person_id
           -- Bug 6060070
           AND pai.effective_date <= fnd_date.canonical_to_date (g_end_date)
           /*AND (DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) BETWEEN
                                      fnd_date.canonical_to_date (g_start_date)
                                  AND fnd_date.canonical_to_date (g_end_date)
               OR (pai.effective_date BETWEEN
                                      fnd_date.canonical_to_date (g_start_date)
                                  AND fnd_date.canonical_to_date (g_end_date)
                   -- Bug 6060070
                   AND DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) <=
                                        fnd_date.canonical_to_date (g_end_date)
                  )
               )
           /*AND fnd_date.canonical_to_date (g_end_date) BETWEEN
                                                        paf.effective_start_date
                                                    AND paf.effective_end_date*/
        ORDER BY pai.effective_date DESC;



    CURSOR csr_person (cp_assignment_action_id number) IS
        SELECT paf.person_id
          FROM per_assignments_f paf,
               pay_assignment_actions paa
         WHERE paa.assignment_action_id = cp_assignment_action_id
           AND paa.assignment_id = paf.assignment_id;

    /*Bug 8768679 - The employee 08 transactions would be picked up only when the hire date lies within the
    reporting period, hence the decode statement has been added to facilitate that.*/
    CURSOR csr_transactions (cp_assignment_action_id number,cp_imp_date varchar2,cp_end_date varchar2) IS
        SELECT pai.action_information_id,
               pai.action_information1, -- Person ID
               pai.action_information2, -- Date of Transaction
               pai.action_information3, -- Employee SSN
               pai.action_information4, -- Type of Transaction
               pai.action_information5, -- Employer SS ID
               fnd_number.canonical_to_number (pai.action_information8), -- IDW
               pai.action_information9,  -- Leaving reason
	       pai.action_information24 -- Reporting option (YES/NO)
          FROM pay_action_information pai,
               pay_action_interlocks lck
         WHERE lck.locking_action_id = cp_assignment_action_id
           AND lck.locked_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND pai.action_information4 IN ('02', '07', '08')
           AND NVL(pai.action_information10, 'N') <> 'Y'
	   --Bug 7185703
	   AND DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),hr_general.start_of_time
		       )  >= fnd_date.canonical_to_date(cp_imp_date)
           -- Bug 6060070
           AND (DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) BETWEEN
                                      fnd_date.canonical_to_date (g_start_date)
				      /*Bug 8768679*/
                                  AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',cp_end_date,g_end_date))
               OR (pai.effective_date BETWEEN
                                      fnd_date.canonical_to_date (g_start_date)
				      /*Bug 8768679*/
                                  AND fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',cp_end_date,g_end_date))
                   /*NOT EXISTS (SELECT 'X'
                                 FROM pay_payroll_actions ppa_affl,
                                      pay_assignment_actions paa_affl,
                                      pay_action_interlocks lck
                                WHERE lck.locked_action_id = pai.action_context_id
                                  AND lck.locking_action_id = paa_affl.assignment_action_id
                                  AND paa_affl.payroll_action_id = ppa_affl.payroll_action_id
                                  AND ppa_affl.report_type = 'MX_SS_AFFL'
                                  AND ppa_affl.report_qualifier = 'MX_SS_AFFL'
                                  AND ppa_affl.report_category = 'RT'
                                  AND ppa_affl.action_status = 'C')*/
                   -- Bug 6060070
		   /*Bug 8768679*/
                   AND DECODE(pai.action_information_category, 'MX SS TRANSACTIONS',
                       fnd_date.canonical_to_date (pai.action_information2),
                       hr_general.start_of_time) <=
                                        fnd_date.canonical_to_date (decode(pai.action_information4 ,'08',cp_end_date,g_end_date))
                  )
               )
      ORDER BY fnd_date.canonical_to_date (pai.action_information2),
               DECODE (pai.action_information4,
                       '08', 1,
                       '07', 2,
                       '02', 3);

      CURSOR c_get_imp_date (cp_gre_id NUMBER) IS
        SELECT org_information6
          FROM hr_organization_information
         WHERE org_information_context = 'MX_TAX_REGISTRATION'
           AND organization_id = cp_gre_id;


    l_proc_name             varchar2(100);
    l_xml                   BLOB;
    ln_assignment_action_id number;
    ln_per_asg_action       number;
    ln_act_info_id          number;
    ln_count                number;
    ln_person_id            number;
    lv_do_not_report        varchar2(1);
    ld_process_date         date;
    lt_tran                 transactions;
    lt_act_info_id          pay_payroll_xml_extract_pkg.int_tab_type;
    lt_act_info_id_per_exc  pay_payroll_xml_extract_pkg.int_tab_type;
    lt_act_info_id_tran_exc pay_payroll_xml_extract_pkg.int_tab_type;
    lv_person_id            pay_action_information.action_information1%type;
    lv_name                 pay_action_information.action_information7%type;
    lv_worker_type          pay_action_information.action_information8%type;
    lv_rww                  pay_action_information.action_information9%type;
    lv_hire_date            pay_action_information.action_information10%type;
    lv_salary_type          pay_action_information.action_information18%type;
    ln_idw                  number;
    lv_tran_dt              pay_action_information.action_information2%type;
    lv_ee_ssn               pay_action_information.action_information3%type;
    lv_tran_type            pay_action_information.action_information4%type;
    lv_er_ssid              pay_action_information.action_information5%type;
    lv_leaving_reason       pay_action_information.action_information9%type;
    ln_legal_er             NUMBER;
    ld_imp_date             varchar2(30);
    ld_event_strt_date      VARCHAR2 (30);
    lv_report_yes_no        VARCHAR2(4);
    ld_end_date             date;
    l_new_end_date          varchar2 (25);



BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML';
    hr_utility_trace ('Entering '||l_proc_name);

    ln_assignment_action_id := pay_magtape_generic.get_parameter_value
                                                           ('TRANSFER_ACT_ID');

    hr_utility_trace ('Processing asg action '|| ln_assignment_action_id);
    hr_utility_trace ('g_start_date '|| g_start_date);
    hr_utility_trace ('g_end_date '|| g_end_date);

    /*Bug 8768679 - Added the following code to increase the g_end_date by 1
     so that it cane be used in the csr_transactions cursor */

    ld_end_date := fnd_date.canonical_to_date (g_end_date)+1;
    l_new_end_date := fnd_date.date_to_canonical (ld_end_date);
    hr_utility_trace ('End date is '|| l_new_end_date);

    ln_legal_er := hr_mx_utility.get_legal_employer(g_business_group,
                                                    g_trans_gre_id);

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

    OPEN csr_person (ln_assignment_action_id);
        FETCH csr_person INTO ln_person_id;
    CLOSE csr_person;

    /*OPEN csr_asg_actions (ln_person_id);
    ln_person_id := NULL;
    LOOP
        FETCH csr_asg_actions INTO ln_per_asg_action,
                                   ld_process_date;
        EXIT WHEN csr_asg_actions%NOTFOUND OR ln_person_id IS NOT NULL;
        hr_utility_trace(
           'Attempting to fetch person info locked by affiliation asg action '||
                                                            ln_per_asg_action);*/
        OPEN get_emp_details (ln_person_id);
        --OPEN get_emp_details (ln_per_asg_action);
            FETCH get_emp_details INTO ln_act_info_id,
                                       ln_person_id,
                                       lv_name,
                                       lv_worker_type,
                                       lv_rww,
                                       lv_hire_date,
                                       ln_idw,
                                       lv_salary_type;
        CLOSE get_emp_details;
    /*END LOOP;
    CLOSE csr_asg_actions;*/

    IF (lv_name IS NULL OR
       lv_worker_type IS NULL OR
       lv_rww IS NULL OR
       lv_hire_date IS NULL OR
       NVL(ln_idw, 0) <= 0 OR
       lv_salary_type IS NULL) AND
       ln_person_id IS NOT NULL THEN
        hr_utility_trace ('Person ID '|| ln_person_id ||' identified as '||
         'exception record. No transactions will be picked for this person.');
        lt_act_info_id_per_exc (lt_act_info_id_per_exc.COUNT()) :=
                                                                ln_act_info_id;
    ELSIF ln_person_id IS NOT NULL THEN
        lt_act_info_id (lt_act_info_id.count()) := ln_act_info_id;

        OPEN csr_transactions (ln_assignment_action_id,ld_imp_date,l_new_end_date);
        LOOP
            FETCH csr_transactions INTO ln_act_info_id,
                                        lv_person_id,
                                        lv_tran_dt,
                                        lv_ee_ssn,
                                        lv_tran_type,
                                        lv_er_ssid,
                                        ln_idw,
                                        lv_leaving_reason,
					lv_report_yes_no;
            EXIT WHEN csr_transactions%NOTFOUND;

            hr_utility_trace ('Transaction type = '||lv_tran_type||'('||
                                                               lv_tran_dt||')');


            IF lv_tran_dt IS NULL OR
               lv_ee_ssn IS NULL OR
               lv_er_ssid IS NULL OR
               (lv_tran_type = '02' AND
                lv_leaving_reason IS NULL) THEN
                hr_utility_trace ('Action Information ID '||ln_act_info_id||
                                     ' identified as exception transaction.');
                lt_act_info_id_tran_exc (lt_act_info_id_tran_exc.COUNT()) :=
                                                                ln_act_info_id;
            ELSE
                ln_count := lt_tran.COUNT();
                lt_tran (ln_count).act_info_id := ln_act_info_id;
                lt_tran (ln_count).tran_type := lv_tran_type;
                lt_tran (ln_count).tran_date := lv_tran_dt;
                lt_tran (ln_count).idw := ln_idw;
		lt_tran (ln_count).reporting_option := lv_report_yes_no;

            END IF;
        END LOOP;
        CLOSE csr_transactions;
        process_transactions (lv_person_id,
                              fnd_number.canonical_to_number(g_trans_gre_id),
                              fnd_date.canonical_to_date(g_end_date),
                              'MX_SS_AFFL',
                              'MX_SS_AFFL',
                              'RT',
                              lt_tran);
        ln_count := lt_tran.FIRST();
        WHILE ln_count IS NOT NULL LOOP
            lt_act_info_id (lt_act_info_id.count()) :=
                                                lt_tran (ln_count).act_info_id;
            ln_count := lt_tran.NEXT(ln_count);
        END LOOP;
    END IF;

    IF lt_act_info_id.count() = 0 AND
       lt_act_info_id_tran_exc.count() = 0 AND
       lt_act_info_id_per_exc.count() = 0 THEN
        hr_utility_trace ('Nothing to write to XML BLOB.');
    ELSE
        pay_payroll_xml_extract_pkg.generate(lt_act_info_id,
                                             NULL,
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);

        hr_utility_trace ('Attempting to generate XML for transaction exceptions.');
        pay_payroll_xml_extract_pkg.generate(lt_act_info_id_tran_exc,
                                             'TRANS_EXCEPTION',
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);

        hr_utility_trace ('Attempting to generate XML for person exceptions.');
        pay_payroll_xml_extract_pkg.generate(lt_act_info_id_per_exc,
                                             'PERSON_EXCEPTION',
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
EXCEPTION
    WHEN OTHERS THEN
        hr_utility_trace (SQLERRM);
        RAISE;
END GENERATE_XML;


  /****************************************************************************
    Name        : GEN_XML_HEADER
    Description : This procedure generates XML header information to XML BLOB
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
    Description : This procedure generates XML footer.
  *****************************************************************************/
PROCEDURE GEN_XML_FOOTER AS

    CURSOR csr_employer IS
        SELECT pai.action_information_id
          FROM pay_action_information pai,
               pay_action_interlocks lck,
               pay_assignment_actions paa_affl,
               pay_assignment_actions paa_arch
         WHERE paa_affl.payroll_action_id =
                   pay_magtape_generic.get_parameter_value ('PAYROLL_ACTION_ID')
           AND lck.locking_action_id = paa_affl.assignment_action_id
           AND paa_arch.assignment_action_id = lck.locked_action_id
           AND pai.action_context_id = paa_arch.payroll_action_id
           --AND pai.action_information2 = pai.action_information4
           AND pai.action_information_category = 'MX SS GRE INFORMATION'
           AND pai.action_context_type = 'PA'
      ORDER BY pai.action_information_id DESC;


    l_proc_name         varchar2(100);
    lv_buf              varchar2(8000);
    l_xml               BLOB;
    lt_act_info_id      pay_payroll_xml_extract_pkg.int_tab_type;
BEGIN
    l_proc_name := g_proc_name || 'GEN_XML_FOOTER';
    hr_utility_trace ('Entering '||l_proc_name);

    OPEN csr_employer;
        FETCH csr_employer INTO lt_act_info_id(lt_act_info_id.count());
    CLOSE csr_employer;

    pay_payroll_xml_extract_pkg.generate(lt_act_info_id,
                                         NULL,
                                         g_document_type,
                                         l_xml);
    write_to_magtape_lob (l_xml);

    lv_buf := lv_buf || '</' ||
              SUBSTR(pay_magtape_generic.get_parameter_value('ROOT_XML_TAG'),
                     2);

    write_to_magtape_lob (lv_buf);

    hr_utility_trace ('BLOB contents after appending footer information');
    print_blob (pay_mag_tape.g_blob_value);

    hr_utility_trace ('Leaving '||l_proc_name);
END GEN_XML_FOOTER;

BEGIN
    --hr_utility.trace_on(null, 'MX_IDC');
    g_proc_name := 'PER_MX_SS_AFFILIATION.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'MX_SS_AFFL';
END PER_MX_SS_AFFILIATION;

/
