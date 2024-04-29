--------------------------------------------------------
--  DDL for Package Body PAY_MX_ANNUAL_WRI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_MX_ANNUAL_WRI" AS
/* $Header: paymxannualwri.pkb 120.0.12000000.1 2007/02/22 16:24:48 vmehta noship $ */
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
    Package Name        : PAY_MX_ANNUAL_WRI
    Package File Name   : paymxannualwri.pkb

    Description : Used for Annual Work Risk Incidents report.

    Change List:
    ------------

    Name          Date        Version Bug     Text
    ------------- ----------- ------- ------- ------------------------------
    sdahiya       18-Oct-2006 115.0           Created.
    sdahiya       20-Nov-2006 115.1           Modified generate_xml to fetch
                                              archived person information
                                              exactly once.
    sdahiya       30-Nov-2006 115.2   5688450 Asg. actions should be created
                                              only if a person has 'Incident at
                                              Work' or 'Labour Disease' type
                                              of risk.
   ***************************************************************************/

--
-- Global Variables
--
    g_proc_name     varchar2(240);
    g_debug         boolean;
    g_document_type varchar2(50);
	g_gre_id        number;
	g_start_date    varchar2(25);
	g_end_date      varchar2(25);


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
    P_END_DATE          OUT NOCOPY varchar2
) IS
    CURSOR csr_get_mag_pact_info IS
    SELECT pay_mx_utility.get_legi_param_val('GRE',
                                             ppa_mag.legislative_parameters),
           fnd_date.date_to_canonical (start_date),
           fnd_date.date_to_canonical (effective_date)
      FROM pay_payroll_actions ppa_mag
     WHERE ppa_mag.payroll_action_id = p_payroll_action_id;

     l_proc_name    varchar2(100);
BEGIN
    l_proc_name := g_proc_name || 'GET_PACT_INFO';
    hr_utility_trace ('Entering '||l_proc_name);

    OPEN csr_get_mag_pact_info;
        FETCH csr_get_mag_pact_info INTO p_gre_id,
                                         p_start_date,
                                         p_end_date;
    CLOSE csr_get_mag_pact_info;

    hr_utility_trace ('Leaving '||l_proc_name);
END GET_PACT_INFO;


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

BEGIN
    l_proc_name := g_proc_name || 'RANGE_CURSOR';

    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('P_PAYROLL_ACTION_ID = '|| p_payroll_action_id);

    get_pact_info (p_payroll_action_id,
                   g_gre_id,
                   g_start_date,
                   g_end_date);

    p_sqlstr := '
SELECT DISTINCT paf.person_id
  FROM per_assignments_f paf,
       pay_payroll_actions ppa_sua,
       pay_assignment_actions paa_sua
 WHERE ppa_sua.payroll_action_id = paa_sua.payroll_action_id
   AND paa_sua.assignment_id = paf.assignment_id
   AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val
                                           (''END_DATE'',
                                            ppa_sua.legislative_parameters))
            BETWEEN paf.effective_start_date
                AND paf.effective_end_date
   AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val
                                           (''END_DATE'',
                                            ppa_sua.legislative_parameters))
            BETWEEN fnd_date.canonical_to_date (''' || g_start_date ||
              ''') AND fnd_date.canonical_to_date (''' || g_end_date   ||
 ''') AND pay_mx_utility.get_legi_param_val (''GRE'',
                                          ppa_sua.legislative_parameters) = '||
                                                                    g_gre_id ||
 ' AND ppa_sua.report_type = ''SUA_MAG''
   AND ppa_sua.report_qualifier = ''SUA_MAG''
   AND ppa_sua.report_category = ''RT''
   AND ppa_sua.action_status = ''C''
   AND :p_payroll_action_id > 0';

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

    CURSOR c_sua_asg_act IS
        SELECT DISTINCT paf.person_id,
               paf.assignment_id,
               paa_sua.assignment_action_id,
               paf.primary_flag,
               paf.effective_end_date
          FROM per_assignments_f paf,
               pay_payroll_actions ppa_sua,
               pay_assignment_actions paa_sua,
               pay_action_interlocks lck,
               pay_action_information pai
         WHERE ppa_sua.payroll_action_id = paa_sua.payroll_action_id
           AND paa_sua.assignment_id = paf.assignment_id
           AND paa_sua.assignment_action_id = lck.locking_action_id
           AND lck.locked_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND pai.action_information4 = '12'
           AND pai.action_information23 IS NOT NULL -- Absence end date
           AND pai.action_information20 IN ('1', '3')--Type of risk(Bug 5688450)
           AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val
                                             ('END_DATE',
                                              ppa_sua.legislative_parameters))
                    BETWEEN paf.effective_start_date
                        AND paf.effective_end_date
           AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val
                                              ('END_DATE',
                                               ppa_sua.legislative_parameters))
                    BETWEEN fnd_date.canonical_to_date (g_start_date)
                        AND fnd_date.canonical_to_date (g_end_date)
           AND pay_mx_utility.get_legi_param_val ('GRE',
                                             ppa_sua.legislative_parameters) =
                                                                       g_gre_id
           AND paf.person_id BETWEEN p_start_person_id
                                 AND p_end_person_id
           AND ppa_sua.report_type = 'SUA_MAG'
           AND ppa_sua.report_qualifier = 'SUA_MAG'
           AND ppa_sua.report_category = 'RT'
           AND ppa_sua.action_status = 'C'
        ORDER BY paf.person_id,
                 decode (paf.primary_flag, 'Y', 1, 2),
                 paf.assignment_id,
                 paf.effective_end_date;

    CURSOR c_sua_asg_act_range IS
        SELECT DISTINCT paf.person_id,
               paf.assignment_id,
               paa_sua.assignment_action_id,
               paf.primary_flag,
               paf.effective_end_date
          FROM per_assignments_f paf,
               pay_payroll_actions ppa_sua,
               pay_assignment_actions paa_sua,
               pay_action_interlocks lck,
               pay_action_information pai,
               pay_population_ranges ppr
         WHERE ppa_sua.payroll_action_id = paa_sua.payroll_action_id
           AND paa_sua.assignment_id = paf.assignment_id
           AND paa_sua.assignment_action_id = lck.locking_action_id
           AND lck.locked_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND pai.action_information4 = '12'
           AND pai.action_information23 IS NOT NULL -- Absence end date
           AND pai.action_information20 IN ('1', '3')--Type of risk(Bug 5688450)
           AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val
                                             ('END_DATE',
                                              ppa_sua.legislative_parameters))
                    BETWEEN paf.effective_start_date
                        AND paf.effective_end_date
           AND fnd_date.canonical_to_date (pay_mx_utility.get_legi_param_val
                                              ('END_DATE',
                                               ppa_sua.legislative_parameters))
                    BETWEEN fnd_date.canonical_to_date (g_start_date)
                        AND fnd_date.canonical_to_date (g_end_date)
           AND pay_mx_utility.get_legi_param_val ('GRE',
                                             ppa_sua.legislative_parameters) =
                                                                       g_gre_id
           AND ppr.payroll_action_id = p_payroll_action_id
           AND ppr.chunk_number = p_chunk
           AND ppr.person_id = paf.person_id
           AND ppa_sua.report_type = 'SUA_MAG'
           AND ppa_sua.report_qualifier = 'SUA_MAG'
           AND ppa_sua.report_category = 'RT'
           AND ppa_sua.action_status = 'C'
        ORDER BY paf.person_id,
                 decode (paf.primary_flag, 'Y', 1, 2),
                 paf.assignment_id,
                 paf.effective_end_date;

    l_proc_name                 varchar2(100);
    lb_range_person_on          boolean;
    ln_person_id                number;
    ln_prev_person_id           number;
    ln_asg_id                   number;
    ln_sua_asg_act              number;
    ln_wri_asg_act              number;
    ld_asg_end_date				date;
    lv_primary_flag				per_assignments_f.primary_flag%type;

BEGIN
    l_proc_name := g_proc_name || 'ACTION_CREATION';
    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('Parameters ....');
    hr_utility_trace ('P_PAYROLL_ACTION_ID = '|| P_PAYROLL_ACTION_ID);
    hr_utility_trace ('P_START_PERSON_ID = '|| P_START_PERSON_ID);
    hr_utility_trace ('P_END_PERSON_ID = '|| P_END_PERSON_ID);
    hr_utility_trace ('P_CHUNK = '|| P_CHUNK);

    ln_prev_person_id := -1;

    IF g_gre_id IS NULL THEN
        get_pact_info (p_payroll_action_id,
                       g_gre_id,
                       g_start_date,
                       g_end_date);
    END IF;

    lb_range_person_on := pay_ac_utility.range_person_on(
                               p_report_type      => 'MX_ANN_WRI'
                              ,p_report_format    => 'MX_ANN_WRI'
                              ,p_report_qualifier => 'MX_ANN_WRI'
                              ,p_report_category  => 'RT');

    IF lb_range_person_on THEN
        hr_utility_trace ('Person ranges are ON');
        OPEN c_sua_asg_act_range;
    ELSE
        hr_utility_trace ('Person ranges are OFF');
        OPEN c_sua_asg_act;
    END IF;

    LOOP
        IF lb_range_person_on THEN
            FETCH c_sua_asg_act_range INTO ln_person_id,
                                           ln_asg_id,
                                           ln_sua_asg_act,
										   lv_primary_flag,
										   ld_asg_end_date;
            EXIT WHEN c_sua_asg_act_range%NOTFOUND;
        ELSE
            FETCH c_sua_asg_act INTO ln_person_id,
                                     ln_asg_id,
                                     ln_sua_asg_act,
                                     lv_primary_flag,
                                     ld_asg_end_date;
            EXIT WHEN c_sua_asg_act%NOTFOUND;
        END IF;

        hr_utility_trace ('-------------');
        hr_utility_trace('Current person = '||ln_person_id);
        hr_utility_trace('Previous person = '||ln_prev_person_id);

        IF (ln_person_id <> ln_prev_person_id) THEN
            SELECT pay_assignment_actions_s.nextval
              INTO ln_wri_asg_act
              FROM dual;

            hr_utility_trace('Creating WRI assignment action '||
                                                            ln_wri_asg_act);
            hr_nonrun_asact.insact(ln_wri_asg_act,
                                  ln_asg_id,
                                  p_payroll_action_id,
                                  p_chunk,
                                  g_gre_id,
                                  null,
                                  'U',
                                  null);
            ln_prev_person_id := ln_person_id;
        ELSE
            hr_utility_trace('WRI assignment action not created');
        END IF;

        hr_nonrun_asact.insint (ln_wri_asg_act,
                                ln_sua_asg_act);
        hr_utility_trace('SUA asg action '||ln_sua_asg_act||
               ' locked by WRI asg action '||ln_wri_asg_act);
    END LOOP;

    IF lb_range_person_on THEN
        CLOSE c_sua_asg_act_range;
    ELSE
        CLOSE c_sua_asg_act;
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
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
                   g_gre_id,
                   g_start_date,
                   g_end_date);

    hr_utility_trace ('Leaving '||l_proc_name);
END INIT;


  /****************************************************************************
    Name        : GENERATE_XML
    Description : This procedure fetches archived data, converts it to XML
                  format and appends to pay_mag_tape.g_blob_value.
  *****************************************************************************/
PROCEDURE GENERATE_XML AS

    CURSOR csr_transactions (cp_wri_asg_act number) IS
        SELECT pai.action_information_id,
               nvl(pai.action_information10, 'N') -- Do not report flag
          FROM pay_action_information pai,
               pay_action_interlocks lck_sua,
               pay_action_interlocks lck_arch
         WHERE lck_sua.locking_action_id = cp_wri_asg_act
           AND lck_sua.locked_action_id = lck_arch.locking_action_id
           AND lck_arch.locked_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS TRANSACTIONS'
           AND pai.action_information4 = '12'
           AND pai.action_information23 IS NOT NULL; -- Absence end date

    CURSOR csr_person (cp_asg_act_id  number) IS
        SELECT DISTINCT paf.person_id
          FROM pay_assignment_actions paa,
               per_assignments_f paf
         WHERE paf.assignment_id = paa.assignment_id
           AND paa.assignment_action_id = cp_asg_act_id;

    CURSOR csr_person_info (cp_person_id number) IS
        SELECT pai.action_information_id
          FROM pay_action_information pai,
               pay_assignment_actions paa,
               pay_payroll_actions ppa,
               pay_action_interlocks lck,
               pay_assignment_actions paa_arch,
               pay_payroll_actions ppa_arch
         WHERE paa.payroll_action_id = ppa.payroll_action_id
           AND fnd_number.canonical_to_number(
                            pay_mx_utility.get_legi_param_val('GRE',
                                        ppa.legislative_parameters)) = g_gre_id
           AND fnd_date.canonical_to_date(
                        pay_mx_utility.get_legi_param_val('END_DATE',
                                              ppa.legislative_parameters)) <=
                                          fnd_date.canonical_to_date(g_end_date)
           AND paa.assignment_action_id = lck.locking_action_id
           AND lck.locked_action_id = paa_arch.assignment_action_id
           AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
           AND pai.action_context_id = paa_arch.assignment_action_id
           AND pai.action_information_category = 'MX SS PERSON INFORMATION'
           AND nvl(pai.action_information21, 'N') = 'N' -- Do not report flag
           AND pai.action_information1 = cp_person_id
           AND ppa.action_type = 'X'
           AND ppa.report_type = 'SUA_MAG'
           AND ppa.report_qualifier = 'SUA_MAG'
           AND ppa.report_category = 'RT'
           AND ppa.action_status = 'C'
           AND ppa_arch.action_type = 'X'
           AND ppa_arch.report_type = 'SS_ARCHIVE'
           AND ppa_arch.report_qualifier = 'SS_ARCHIVE'
           AND ppa_arch.report_category = 'RT'
           AND ppa_arch.action_status = 'C'
         ORDER BY fnd_date.canonical_to_date(
                        pay_mx_utility.get_legi_param_val('END_DATE',
                                              ppa.legislative_parameters)) DESC;
        /*SELECT pai.action_information_id
          FROM pay_action_information pai,
               pay_action_interlocks lck_sua,
               pay_action_interlocks lck_arch,
               pay_payroll_actions ppa_arch,
               pay_assignment_actions paa_arch
         WHERE lck_sua.locking_action_id = cp_wri_asg_act
           AND lck_sua.locked_action_id = lck_arch.locking_action_id
           AND lck_arch.locked_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS PERSON INFORMATION'
           AND nvl(pai.action_information21, 'N') = 'N' -- Do not report flag
           AND pai.action_context_id = paa_arch.assignment_action_id
           AND paa_arch.payroll_action_id = ppa_arch.payroll_action_id
      ORDER BY fnd_date.canonical_to_date (
                                pay_mx_utility.get_legi_param_val('END_DATE',
                                        ppa_arch.legislative_parameters)) DESC;*/


    l_proc_name                   varchar2(100);
    l_xml                         BLOB;
    ln_assignment_action_id       number;
    ln_act_info_id                number;
    ln_person_id                  number;
    lv_do_not_report              varchar2(1);
    lt_act_info_id                pay_payroll_xml_extract_pkg.int_tab_type;
    lt_act_info_id_exc            pay_payroll_xml_extract_pkg.int_tab_type;

BEGIN
    l_proc_name := g_proc_name || 'GENERATE_XML';
    hr_utility_trace ('Entering '||l_proc_name);

    ln_assignment_action_id := pay_magtape_generic.get_parameter_value
                                                           ('TRANSFER_ACT_ID');

    hr_utility_trace ('Processing WRI asg action '|| ln_assignment_action_id);

    OPEN csr_transactions (ln_assignment_action_id);
    LOOP
        FETCH csr_transactions INTO ln_act_info_id,
                                    lv_do_not_report;
        EXIT WHEN csr_transactions%NOTFOUND;

        IF lv_do_not_report = 'N' THEN
            lt_act_info_id(lt_act_info_id.count()) := ln_act_info_id;
        ELSE
            lt_act_info_id_exc(lt_act_info_id_exc.count()) := ln_act_info_id;
        END IF;
    END LOOP;
    CLOSE csr_transactions;

    OPEN csr_person (ln_assignment_action_id);
        FETCH csr_person INTO ln_person_id;
    CLOSE csr_person;

    hr_utility_trace ('WRI asg action '|| ln_assignment_action_id ||
                        ' belongs to person '||ln_person_id);

    OPEN csr_person_info (ln_person_id);
        FETCH csr_person_info INTO lt_act_info_id(lt_act_info_id.count());
    CLOSE csr_person_info;

    IF lt_act_info_id.count() = 0 AND
       lt_act_info_id_exc.count() = 0 THEN
        hr_utility_trace ('No data to write to BLOB.');
    ELSE
        pay_payroll_xml_extract_pkg.generate(lt_act_info_id,
                                             NULL,
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);

        pay_payroll_xml_extract_pkg.generate(lt_act_info_id_exc,
                                             'WRI_EXCEPTION',
                                             g_document_type,
                                             l_xml);
        write_to_magtape_lob (l_xml);
    END IF;

    print_blob (pay_mag_tape.g_blob_value);

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
               pay_action_interlocks lck_sua,
               pay_action_interlocks lck_arch,
               pay_assignment_actions paa_arch,
               pay_assignment_actions paa_wri
         WHERE paa_wri.payroll_action_id =
                   pay_magtape_generic.get_parameter_value ('PAYROLL_ACTION_ID')
           AND lck_sua.locking_action_id = paa_wri.assignment_action_id
           AND lck_sua.locked_action_id = lck_arch.locking_action_id
           AND lck_arch.locked_action_id = paa_arch.assignment_action_id
           AND paa_arch.payroll_action_id = pai.action_context_id
           AND pai.action_information_category = 'MX SS GRE INFORMATION'
           AND pai.action_context_type = 'PA'
           AND ROWNUM = 1;

    CURSOR csr_er_address IS
        SELECT hl.address_line_1,
               hl.address_line_2,
               hl.region_2,
               hl.postal_code,
               hl.town_or_city,
               hr_general.decode_lookup('PER_MX_STATE_CODES', hl.region_1),
               ft.territory_short_name,
               hl.telephone_number_1,
               hl.telephone_number_2
          FROM hr_locations hl,
               hr_organization_units hou,
               fnd_territories_vl ft
         WHERE hou.location_id = hl.location_id
           AND ft.territory_code = hl.country
           AND hou.organization_id = g_gre_id;


    lv_street           hr_locations.address_line_1%type;
    lv_neighborhood     hr_locations.address_line_2%type;
    lv_municipality     hr_locations.region_2%type;
    lv_postal_code      hr_locations.postal_code%type;
    lv_city             hr_locations.town_or_city%type;
    lv_state            hr_locations.region_1%type;
    lv_country          hr_lookups.meaning%type;
    lv_telephone        hr_locations.telephone_number_1%type;
    lv_fax              hr_locations.telephone_number_2%type;
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

    OPEN csr_er_address;
        FETCH csr_er_address INTO lv_street,
                                  lv_neighborhood,
                                  lv_municipality,
                                  lv_postal_code,
                                  lv_city,
                                  lv_state,
                                  lv_country,
                                  lv_telephone,
                                  lv_fax;
    CLOSE csr_er_address;

    lv_buf := '<GRE_ADDRESS><STREET>' || lv_street || '</STREET>';
    lv_buf := lv_buf || '<NEIGHBORHOOD>' ||lv_neighborhood||'</NEIGHBORHOOD>';
    lv_buf := lv_buf || '<MUNICIPALITY>' ||lv_municipality||'</MUNICIPALITY>';
    lv_buf := lv_buf || '<POSTAL_CODE>' ||lv_postal_code||'</POSTAL_CODE>';
    lv_buf := lv_buf || '<CITY>' ||lv_city||'</CITY>';
    lv_buf := lv_buf || '<STATE>' ||lv_state||'</STATE>';
    lv_buf := lv_buf || '<COUNTRY>' ||lv_country||'</COUNTRY>';
    lv_buf := lv_buf || '<TELEPHONE>' ||lv_telephone||'</TELEPHONE>';
    lv_buf := lv_buf || '<FAX>' ||lv_fax||'</FAX>';
    lv_buf := lv_buf || '<REPORTING_YEAR>' ||
                  SUBSTR (g_end_date, 1, 4)||'</REPORTING_YEAR></GRE_ADDRESS>';

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
    g_proc_name := 'PAY_MX_ANNUAL_WRI.';
    g_debug := hr_utility.debug_enabled;
    g_document_type := 'MX_ANN_WRI';
END PAY_MX_ANNUAL_WRI;

/
