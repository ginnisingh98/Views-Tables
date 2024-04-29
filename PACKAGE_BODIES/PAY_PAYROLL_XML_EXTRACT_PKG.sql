--------------------------------------------------------
--  DDL for Package Body PAY_PAYROLL_XML_EXTRACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_PAYROLL_XML_EXTRACT_PKG" as
/* $Header: pyxmlxtr.pkb 120.13.12010000.4 2010/03/23 05:17:30 sjawid ship $ */
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

    Name        : pay_payroll_xml_extract_pkg

    Description : This package handles generation of XML from data archived
                  in pay_action_information. Calling applications can invoke
                  one of the overloaded versions of GENERATE procedure with
                  appropriate parameters to obtain the XML. This package has
                  other public procedures which GENERATE uses for processing.
                  They might not be of much use if invoked directly by calling
                  applications.

    Change List
    -----------
    Date        Name       Vers    Bug No   Description
    ----------- ---------- ------  -------  -------------------------------
    23-NOV-2004 sdahiya    115.0            Created.
    09-DEC-2004 sdahiya    115.1            Added XML meta tag.
    22-DEC-2004 sdahiya    115.2            - Modified procedure GENERATE to
                                              retrieve records archived at
                                              payroll action level too.
                                            - Modified LOAD_XML_INTERNAL to
                                              handle occurance of special
                                              characters in XML data.
                                            - Added DocumentProcessor XML tags.
    20-FEB-2005 sdahiya    115.3            Modified parameters of GENERATE
                                            procedure. Created local procedure
                                            BUILD_SQL.
    06-APR-2005 sdahiya    115.4            Modified LOAD_XML procedure to fetch
                                            cheque number for
                                            EMPLOYEE NET PAY DISTRIBUTION
                                            context.
    11-JUL-2005 sdahiya    115.5            Added overloaded versions of
                                            GENERATE procedure so that it can be
                                            driven off action_information_id
                                            too.
    15-JUL-2005 sdahiya    115.6            Modified signature of GENERATE
                                            overloaded procedure to handle
                                            custom XML tags.
    01-AUG-2005 sdahiya    115.7            Added support for localization
                                            package and removed
                                            DocumentProcessor XML tags.
    04-AUG-2005 sdahiya    115.8   4534551  Added LTRIM and RTRIM functions.
    18-AUG-2005 sdahiya    115.9            Added LOAD_XML_DATA procedure.
                                            Renamed global variable
                                            g_xml_payslip to g_xml_table and
                                            moved it to package header.
    07-NOV-2005 sdahiya    115.10           Used bind variables instead of
                                            literals while opening
                                            csr_get_archived_info_rec cursor in
                                            generate_internal procedure.
    08-NOV-2005 sdahiya    115.11           Formatting and indentation changes.
    20-NOV-2005 vmehta     115.12           Added overloaded version of LOAD_XML
                                            which accepts flexfield name.
    21-NOV-2005 sdahiya    115.13  4773967  Modified procedures to return
                                            generated XML as a BLOB instead of
                                            CLOB.
    01-DEC-2005 sdahiya    115.14           Modified PRINT_BLOB to use
                                            pay_ac_utility.print_lob.
    28-MAR-2006 sdahiya    115.15           Dynamically fetch IANA charset to
                                            identify XML encoding.
    06-APR-2006 sdahiya    115.16           Appended action_information_id
                                            parameter to the custom parameter
                                            list (g_custom_params) for use in
                                            PAY_<LEG_CODE>_RULES.
    24-MAY-2006 sdahiya    115.17  6068599  Cache g_custom_params should be
                                            cleared in case of abnormal
                                            termination.
    21-AUG-2008 jalin      115.18  6522667  Fixed performance issue, added
                                            application_id=801 condition into
                                            cursor csr_get_tag_name and
                                            cursor csr_csr_seg_enabled
    24-FEB-2010 sjawid     115.19  9384276  Passing payment_method_id(action_information2)
                                            to g_custom_params before localization procedure
					    call for US payslip.
    19-MAR-2010 sjawid     115.20  9488426  Revert back the changes made for bug 9384276
					    Modified generate_internal procedure to get
					    Check_number and masked account number for
					    Employee Third party payments.
  *****************************************************************************/

g_proc_name         varchar2(50);
g_debug             boolean;
g_action_ctx_id     number;
g_custom_context    pay_action_information.action_information_category%type;


  /****************************************************************************
    Name        : HR_UTILITY_TRACE
    Description : This procedure prints debug messages during diagnostics mode.
  *****************************************************************************/

PROCEDURE HR_UTILITY_TRACE(trc_data varchar2) IS
BEGIN
    IF g_debug THEN
        hr_utility.trace(trc_data);
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
    Name        : LOAD_XML_INTERNAL
    Description : This procedure loads the global XML cache.
  *****************************************************************************/
PROCEDURE LOAD_XML_INTERNAL (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS
    l_proc_name varchar2(100);
    l_data      pay_action_information.action_information1%type;

BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML_INTERNAL';
    hr_utility_trace ('Entering '||l_proc_name);

    IF p_node_type = 'CS' THEN
        load_xml ('<'||p_node||'>');
    ELSIF p_node_type = 'CE' THEN
        load_xml ('</'||p_node||'>');
    ELSIF p_node_type = 'D' THEN
        /* Handle special charaters in data */
        l_data := REPLACE (p_data, '&', '&amp;');
        l_data := REPLACE (l_data, '>', '&gt;');
        l_data := REPLACE (l_data, '<', '&lt;');
        l_data := REPLACE (l_data, '''', '&apos;');
        l_data := REPLACE (l_data, '"', '&quot;');
        load_xml ('<'||p_node||'>'||l_data||'</'||p_node||'>');
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);
END LOAD_XML_INTERNAL;


  /****************************************************************************
    Name        : LOAD_XML
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

                  P_CONTEXT_CODE    Context code of Action Information DF.

                  P_NODE            Name of XML tag, or, application column
                                    name of flex segment.

                  P_DATA            Data to be contained by tag specified by
                                    P_NODE parameter. P_DATA is not used unless
                                    P_NODE_TYPE = D.
  *****************************************************************************/

PROCEDURE LOAD_XML (
    P_NODE_TYPE         varchar2,
    P_FLEXFIELD_NAME    varchar2,
    P_CONTEXT_CODE      varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS

    CURSOR csr_get_tag_name IS
        SELECT TRANSLATE (UPPER(end_user_column_name), ' /','__') tag_name
          FROM fnd_descr_flex_col_usage_vl
         WHERE descriptive_flexfield_name = p_flexfield_name
           AND descriptive_flex_context_code = p_context_code
           AND application_column_name = UPPER (p_node)
           AND application_id = 801; /* Bug 6522667 */

    CURSOR csr_get_chk_no IS
        SELECT paa_chk.serial_number
          FROM pay_assignment_actions paa_xfr,
               pay_action_interlocks pai_xfr,
               pay_action_interlocks pai_chk,
               pay_assignment_actions paa_chk,
               pay_payroll_actions ppa_chk
         WHERE paa_xfr.assignment_action_id = pai_xfr.locking_action_id
           AND pai_xfr.locked_action_id = pai_chk.locked_action_id
           AND pai_chk.locking_action_id = paa_chk.assignment_action_id
           AND paa_chk.payroll_action_id = ppa_chk.payroll_action_id
           AND ppa_chk.action_type = 'H'
           AND paa_xfr.assignment_action_id = g_action_ctx_id;

    l_proc_name varchar2(100);
    l_tag_name  varchar2(500);
    l_chk_no    pay_assignment_actions.serial_number%type;
    l_data      pay_action_information.action_information1%type;

BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML';
    hr_utility_trace ('Entering '||l_proc_name);

    IF p_node_type = 'D' THEN

        /* Fetch segment names */
        OPEN csr_get_tag_name;
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;

        /* Fetch cheque number */
        IF p_flexfield_name = 'Action Information DF' AND
           p_context_code = 'EMPLOYEE NET PAY DISTRIBUTION' AND
           l_tag_name = 'CHECK_DEPOSIT_NUMBER' THEN
            OPEN csr_get_chk_no;
                FETCH csr_get_chk_no INTO l_chk_no;
            CLOSE csr_get_chk_no;
        END IF;
    END IF;

    IF UPPER(p_node) NOT LIKE '?XML%' AND UPPER(p_node) NOT LIKE 'XAPI%' THEN
        l_tag_name := nvl(l_tag_name, TRANSLATE(p_node, ' /', '__'));
        IF p_node_type IN ('CS', 'CE') THEN
            l_tag_name := nvl(g_custom_context, TRANSLATE(p_node, ' /', '__'));
        END IF;
    ELSE
        l_tag_name := p_node;
    END IF;

    l_data := nvl(l_chk_no, p_data);
    load_xml_internal (p_node_type, l_tag_name, l_data);

    hr_utility_trace ('Leaving '||l_proc_name);
END LOAD_XML;


/****************************************************************************
    Name        : LOAD_XML
    Description : This procedure obtains segment title from the Action
                  Information DF. This is temporary, and is created only to
                  provide backward compatibility for payslip code. Once the
                  payslip processes are changed to pass the flexfield name,
                  this procedure can be removed.
 *****************************************************************************/
PROCEDURE LOAD_XML (
    P_NODE_TYPE      varchar2,
    P_CONTEXT_CODE   varchar2,
    P_NODE           varchar2,
    P_DATA           varchar2
) AS

    l_proc_name varchar2(100);

BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML-4';
    hr_utility_trace ('Entering '||l_proc_name);

    load_xml(p_node_type      => p_node_type,
             p_flexfield_name => 'Action Information DF',
             p_context_code   => p_context_code,
             p_node           => p_node,
             p_data           => p_data);

    hr_utility_trace ('Leaving '||l_proc_name);

END LOAD_XML;

  /****************************************************************************
    Name        : LOAD_XML
    Description : This procedure obtains segment title from the bank key
                  flexfield to be used as XML tag.
  *****************************************************************************/
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

BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML-2';
    hr_utility_trace ('Entering '||l_proc_name);

    IF p_node_type = 'D' THEN
        OPEN csr_get_tag_name (pay_payroll_xml_extract_pkg.g_leg_code||
                                                            '_BANK_DETAILS');
            FETCH csr_get_tag_name INTO l_tag_name;
        CLOSE csr_get_tag_name;
    END IF;

    IF UPPER(p_node) NOT LIKE '?XML%' AND UPPER(p_node) NOT LIKE 'XAPI%' THEN
        l_tag_name := nvl(l_tag_name, TRANSLATE(p_node,' /', '__'));
        IF p_node_type IN ('CS', 'CE') THEN
            l_tag_name := nvl(g_custom_context, TRANSLATE(p_node, ' /', '__'));
        END IF;
    ELSE
        l_tag_name := p_node;
    END IF;

    load_xml_internal (p_node_type, l_tag_name, p_data);

    hr_utility_trace ('Leaving '||l_proc_name);
END LOAD_XML;

  /****************************************************************************
    Name        : LOAD_XML
    Description : This procedure accepts a well-formed XML and loads it into
                  global XML cache. Note that this procedure does not perform
                  any syntactical validations over passed XML data.
                  LOAD_XML_DATA should be used if such validations are required
                  to be performed implicitly.
  *****************************************************************************/
PROCEDURE LOAD_XML (
    P_XML               pay_action_information.action_information1%type
) AS

    l_proc_name varchar2(100);

BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML-3';
    hr_utility_trace ('Entering '||l_proc_name);

    g_xml_table (g_xml_table.count() + 1) := p_xml;

    hr_utility_trace ('Leaving '||l_proc_name);
END;

  /****************************************************************************
    Name        : LOAD_XML_DATA
    Description : This procedure accepts meta-data along with actual XML data
                  and loads the global XML cache. This is a public procedure
                  which performs basic validations to check well-formedness of
                  XML data before loading the cache. Please see parameter
                  description of public version of LOAD_XML to find what each
                  parameter signifies.
  *****************************************************************************/
PROCEDURE LOAD_XML_DATA (
    P_NODE_TYPE         varchar2,
    P_NODE              varchar2,
    P_DATA              varchar2
) AS
    l_proc_name varchar2(100);
BEGIN
    l_proc_name := g_proc_name || 'LOAD_XML_DATA';
    hr_utility_trace ('Entering '||l_proc_name);

    load_xml_internal (p_node_type,
                       p_node,
                       p_data);

    hr_utility_trace ('Leaving '||l_proc_name);
END LOAD_XML_DATA;

  /****************************************************************************
    Name        : FLEX_SEG_ENABLED
    Description : This function returns TRUE if an application column is
                  registered with given context of Action Information DF.
                  Otherwise, it returns false.
  *****************************************************************************/
FUNCTION FLEX_SEG_ENABLED
(
    P_CONTEXT_CODE              varchar2,
    P_APPLICATION_COLUMN_NAME   varchar2
) RETURN BOOLEAN AS

    CURSOR csr_seg_enabled IS
        SELECT 'Y'
          FROM fnd_descr_flex_col_usage_vl
         WHERE descriptive_flexfield_name like 'Action Information DF'
           AND descriptive_flex_context_code = p_context_code
           AND application_column_name like p_application_column_name
           AND application_id = 801 /* Bug 6522667 */
           AND enabled_flag = 'Y';

    l_proc_name varchar2(100);
    l_exists    varchar2(1);

BEGIN
    l_proc_name := g_proc_name || 'FLEX_SEG_ENABLED';
    hr_utility_trace ('Entering '||l_proc_name);

    OPEN csr_seg_enabled;
        FETCH csr_seg_enabled INTO l_exists;
    CLOSE csr_seg_enabled;

    hr_utility_trace ('Leaving '||l_proc_name);

    IF l_exists = 'Y' THEN
        RETURN (TRUE);
    ELSE
        RETURN (FALSE);
    END IF;

END FLEX_SEG_ENABLED;


  /****************************************************************************
    Name        : BUILD_SQL
    Description : This procedure builds dynamic SQL string.
  *****************************************************************************/

PROCEDURE BUILD_SQL
(
    P_SQLSTR_TAB    IN OUT NOCOPY dbms_sql.varchar2s,
    P_CNTR          IN OUT NOCOPY number,
    P_STRING        varchar2
) AS
    l_proc_name varchar2(100);
BEGIN
    l_proc_name := g_proc_name || 'BUILD_SQL';
    hr_utility_trace ('Entering '||l_proc_name);
    p_sqlstr_tab(p_cntr) := p_string;
    p_cntr := p_cntr + 1;
    hr_utility_trace ('Leaving '||l_proc_name);
END;


  /****************************************************************************
    Name        : GENERATE_INTERNAL
    Description : This procedure interprets archived information, converts it to
                  XML and prints it to a BLOB. This is a private procedure.

                  IMP. NOTE: - This procedure can be invoked either by
                  action_information_id or action_context_id, one at a time. i.e
                  for any given call of this procedure, exactly one of these
                  parameters can be passed a NOT NULL value.
  *****************************************************************************/

PROCEDURE GENERATE_INTERNAL
(
    P_ACTION_INFORMATION_ID     number,
    P_ACTION_CONTEXT_ID         number,
    P_CUSTOM_ACTION_INFO_CAT    varchar2,
    P_CUSTOM_XML_PROCEDURE      varchar2,
    P_GENERATE_HEADER_FLAG      boolean,
    P_ROOT_TAG                  varchar2,
    P_DOCUMENT_TYPE             varchar2,
    P_XML                       OUT NOCOPY BLOB
) AS

    CURSOR get_leg_code IS
        SELECT hoi2.org_information9
          FROM pay_assignment_actions paa,
               pay_payroll_actions ppa,
               hr_organization_units hou,
               hr_organization_information hoi1,
               hr_organization_information hoi2
         WHERE paa.payroll_action_id = ppa.payroll_action_id
           AND ppa.business_group_id = hou.organization_id
           AND hou.organization_id = hoi1.organization_id
           AND hoi1.organization_id = hoi2.organization_id
           AND ppa.effective_date BETWEEN hou.date_from
                                      AND nvl(hou.date_to,
                                              hr_general.end_of_time)
           AND hoi1.org_information_context = 'CLASS'
           AND hoi1.org_information1 = 'HR_BG'
           AND hoi2.org_information_context = 'Business Group Information'
           AND ppa.action_type = 'X'
           AND NVL (p_action_context_id, (SELECT action_context_id
                                            FROM pay_action_information
                                           WHERE action_information_id =
                                                      p_action_information_id))
                                                    = paa.assignment_action_id;

    CURSOR csr_get_archived_regions IS
        SELECT DISTINCT action_information_category
          FROM pay_action_information
         WHERE ((action_context_type = 'AAP'
             AND action_context_id = p_action_context_id)
             OR (action_context_type = 'PA'
             AND action_context_id =
                    (SELECT payroll_action_id
                       FROM pay_assignment_actions
                      WHERE assignment_action_id = p_action_context_id)))
            OR (action_information_id = p_action_information_id
            AND p_action_information_id IS NOT NULL)
      ORDER BY decode (action_information_category,'EMPLOYEE DETAILS', 1, 2);
      /* NOTE - This ORDER BY clause will make sure that EMPLOYEE DETAILS gets
                processed before all other action information categories so
                that we have the organization_id (action_information2) for
                filtering undesired ADDRESS DETAILS archived at payroll action
                level (action_context_type = 'PA') by the payroll archiver.*/

    l_proc_name      varchar2(100);
    sqlstr           dbms_sql.varchar2s;
    l_cntr_sql       number;
    l_xml            BLOB;
    csr              number;
    ret              number;
    cntr_flex_col    number;
    l_flex_col_num   number; /* Max. number of flex segments in Action
                                Informtion DF */

    l_kff_seg_start  number; /* Segment number where bank KFF segments start.
                                Currently, it is ACTION_INFORMATION5, so,
                                l_kff_seg_start = 5 */

    l_kff_seg_end    number; /* Segment number where bank KFF segments end.
                                Currently, it is ACTION_INFORMATION14, so,
                                l_kff_seg_end = 14 */

    l_action_information_id varchar2(100);
    l_action_context_id     varchar2(100);
    lr_xml                  RAW (32767);
    ln_amt                  number;

BEGIN
    l_proc_name := g_proc_name || 'GENERATE_INTERNAL';
    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('Parameters ....');
    hr_utility_trace ('P_ACTION_INFORMATION_ID ='||P_ACTION_INFORMATION_ID);
    hr_utility_trace ('P_ACTION_CONTEXT_ID ='||P_ACTION_CONTEXT_ID);
    IF p_generate_header_flag THEN
        hr_utility_trace ('P_GENERATE_HEADER_FLAG = TRUE');
    ELSE
        hr_utility_trace ('P_GENERATE_HEADER_FLAG = FALSE');
    END IF;
    hr_utility_trace ('P_CUSTOM_ACTION_INFO_CAT ='||P_CUSTOM_ACTION_INFO_CAT);

    g_xml_table.delete();
    l_flex_col_num      := 30;
    l_kff_seg_start     := 5;
    l_kff_seg_end       := 14;
    l_cntr_sql          := 1;
    g_action_ctx_id     := p_action_context_id;
    g_custom_context    := TRANSLATE(p_custom_action_info_cat, ' /', '__');

    SELECT DECODE (p_action_information_id,
                   NULL, 'NULL',
                   to_char(p_action_information_id)),
           DECODE (p_action_context_id,
                   NULL, 'NULL',
                   to_char(p_action_context_id))
      INTO l_action_information_id,
           l_action_context_id
      FROM DUAL;

    build_sql(sqlstr, l_cntr_sql, 'declare l_org_id varchar2(100);begin ');
    IF p_generate_header_flag THEN
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(''CS'', NULL, ''?xml version="1.0" encoding="'||
                            hr_mx_utility.get_IANA_charset||'"?'', NULL);');
    END IF;
    IF p_root_tag IS NOT NULL THEN
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(''CS'', NULL, '''||
                                                    p_root_tag||''', NULL);');
    END IF;

    /* Fetch legislation_code. */
    OPEN get_leg_code;
        FETCH get_leg_code INTO pay_payroll_xml_extract_pkg.g_leg_code;
    CLOSE get_leg_code;

    FOR csr_get_archived_regions_rec IN csr_get_archived_regions LOOP
        IF csr_get_archived_regions_rec.action_information_category IN
            ('ADDRESS DETAILS', pay_payroll_xml_extract_pkg.g_leg_code ||
                                                    ' EMPLOYER DETAILS') THEN
            build_sql(sqlstr,
                      l_cntr_sql,
                      'FOR csr_get_archived_info_rec IN pay_payroll_xml_extract_pkg.csr_get_archived_info (:l_action_context_id,'''||
                       csr_get_archived_regions_rec.action_information_category
                             ||''', l_org_id, :l_action_information_id) LOOP ');
        ELSE
            build_sql(sqlstr,
                      l_cntr_sql,
                      'FOR csr_get_archived_info_rec IN pay_payroll_xml_extract_pkg.csr_get_archived_info (:l_action_context_id,'''||
                       csr_get_archived_regions_rec.action_information_category
                                 ||''', NULL, :l_action_information_id) LOOP ');
        END IF;
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(''CS'', NULL, ''' ||
                     csr_get_archived_regions_rec.action_information_category ||
                                                                 ''', NULL);');
        cntr_flex_col := 1;
        LOOP
            EXIT WHEN cntr_flex_col > l_flex_col_num;
            IF flex_seg_enabled (
                    csr_get_archived_regions_rec.action_information_category,
                    'ACTION_INFORMATION'||cntr_flex_col) THEN
                IF csr_get_archived_regions_rec.action_information_category =
                                                'EMPLOYEE NET PAY DISTRIBUTION'
                   AND cntr_flex_col BETWEEN l_kff_seg_start
                                         AND l_kff_seg_end THEN
                    build_sql(sqlstr,
                              l_cntr_sql,
                              'pay_payroll_xml_extract_pkg.load_xml(''D'', ''Segment'
                                     || (cntr_flex_col - l_kff_seg_start + 1) ||
                               ''', LTRIM(RTRIM(csr_get_archived_info_rec.action_information'
                                                    || cntr_flex_col ||')));');
                ELSE

                /*bug:9488426: Added code to feed the check number action_information4
		  and account_number field action_information7  masked for Employee Third party payments*/

                   IF csr_get_archived_regions_rec.action_information_category =
                                                'EMPLOYEE THIRD PARTY PAYMENTS'
                     AND pay_payroll_xml_extract_pkg.g_leg_code = 'US' THEN
                      build_sql(sqlstr,
                        l_cntr_sql,
                        'csr_get_archived_info_rec.action_information4 :=
                           pay_us_employee_payslip_web.get_check_number(csr_get_archived_info_rec.action_information17
                           ,csr_get_archived_info_rec.action_information15);');

                      build_sql(sqlstr,
                        l_cntr_sql,
                        'csr_get_archived_info_rec.action_information7 :=
                          HR_GENERAL2.mask_characters(csr_get_archived_info_rec.action_information7);');
                   END IF;

                    build_sql(sqlstr,
                              l_cntr_sql,
                              'pay_payroll_xml_extract_pkg.load_xml(''D'', '''
                              || csr_get_archived_regions_rec.action_information_category ||
                                   ''', ''ACTION_INFORMATION'|| cntr_flex_col ||
                              ''', LTRIM(RTRIM(csr_get_archived_info_rec.action_information'
                                                     || cntr_flex_col ||')));');
                END IF;
            END IF;
            cntr_flex_col := cntr_flex_col + 1;
        END LOOP;
        /*Generate payroll details from time period id (action_information16)*/
        IF csr_get_archived_regions_rec.action_information_category =
                                                        'EMPLOYEE DETAILS' THEN
            build_sql(sqlstr,
                      l_cntr_sql,
                      'FOR csr_payroll_details_rec IN pay_payroll_xml_extract_pkg.csr_payroll_details(csr_get_archived_info_rec.action_information16) LOOP ');
            build_sql(sqlstr,
                      l_cntr_sql,
                      'pay_payroll_xml_extract_pkg.load_xml(''D'', NULL, ''PAYROLL_NAME'', csr_payroll_details_rec.payroll_name);');
            build_sql(sqlstr,
                      l_cntr_sql,
                      'pay_payroll_xml_extract_pkg.load_xml(''D'', NULL, ''PERIOD_TYPE'', csr_payroll_details_rec.period_type);');
            build_sql(sqlstr,
                      l_cntr_sql,
                      'pay_payroll_xml_extract_pkg.load_xml(''D'', NULL, ''START_DATE'', csr_payroll_details_rec.start_date);');
            build_sql(sqlstr,
                      l_cntr_sql,
                      'pay_payroll_xml_extract_pkg.load_xml(''D'', NULL, ''END_DATE'', csr_payroll_details_rec.end_date);');
            build_sql(sqlstr,
                      l_cntr_sql,
                      'pay_payroll_xml_extract_pkg.load_xml(''D'', NULL, ''PAYMENT_DATE'', substr(fnd_date.date_to_canonical(csr_get_archived_info_rec.effective_date),1,10));');
            build_sql(sqlstr,
                      l_cntr_sql,
                      'END LOOP;');
            build_sql(sqlstr,
                      l_cntr_sql,
                      'l_org_id := csr_get_archived_info_rec.action_information2;');
        END IF;

        -- Localization procedure call
        build_sql(sqlstr,
                  l_cntr_sql,
                  'BEGIN ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'EXECUTE IMMEDIATE (''BEGIN pay_'||
                                        pay_payroll_xml_extract_pkg.g_leg_code||
                                 '_rules.add_custom_xml('||l_action_context_id||
          ', '''''|| csr_get_archived_regions_rec.action_information_category ||
                                               ''''', '''''|| p_document_type ||
                                                             '''''); END;'');');

        build_sql(sqlstr,
                  l_cntr_sql,
                  'IF pay_payroll_xml_extract_pkg.g_custom_xml.count() > 0 THEN ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(''<!-- Following segment(s) were added by PAY_'||
                                        pay_payroll_xml_extract_pkg.g_leg_code||
                                               '_RULES.ADD_CUSTOM_XML -->'');');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'FOR cntr IN pay_payroll_xml_extract_pkg.g_custom_xml.first()..pay_payroll_xml_extract_pkg.g_custom_xml.last() LOOP ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(pay_payroll_xml_extract_pkg.g_custom_xml(cntr));');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'END LOOP;');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.g_custom_xml.delete();');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'END IF;');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'EXCEPTION ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'WHEN OTHERS THEN NULL;');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'END;');

        -- Custom procedure call
        build_sql(sqlstr,
                  l_cntr_sql,
                  'BEGIN ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'EXECUTE IMMEDIATE (''BEGIN '||p_custom_xml_procedure||
                                                      '('||l_action_context_id||
                                                                      ', '''''||
                     csr_get_archived_regions_rec.action_information_category ||
                                               ''''', '''''|| p_document_type ||
                                                             '''''); END;'');');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'IF pay_payroll_xml_extract_pkg.g_custom_xml.count() > 0 THEN ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(''<!-- Following segment(s) were added by '||
                                    UPPER(p_custom_xml_procedure)||' -->'');');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'FOR cntr IN pay_payroll_xml_extract_pkg.g_custom_xml.first()..pay_payroll_xml_extract_pkg.g_custom_xml.last() LOOP ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(pay_payroll_xml_extract_pkg.g_custom_xml(cntr));');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'END LOOP;');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.g_custom_xml.delete();');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'END IF;');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'EXCEPTION ');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'WHEN OTHERS THEN NULL;');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'END;');

        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(''CE'', NULL, ''' ||
                     csr_get_archived_regions_rec.action_information_category ||
                                                                  ''', NULL);');
        build_sql(sqlstr,
                  l_cntr_sql,
                  'END LOOP;');
    END LOOP;

    -- Localization procedure call
    build_sql(sqlstr,
              l_cntr_sql,
              'BEGIN ');
    build_sql(sqlstr,
              l_cntr_sql,
              'EXECUTE IMMEDIATE (''BEGIN pay_'||
                                        pay_payroll_xml_extract_pkg.g_leg_code||
                       '_rules.add_custom_xml('||l_action_context_id||', NULL'||
                                                   ', '''''|| p_document_type ||
                                                             '''''); END;'');');
    build_sql(sqlstr,
              l_cntr_sql,
              'IF pay_payroll_xml_extract_pkg.g_custom_xml.count() > 0 THEN ');
    build_sql(sqlstr,
              l_cntr_sql,
              'pay_payroll_xml_extract_pkg.load_xml(''<!-- Following context(s) were added by PAY_'||
                                        pay_payroll_xml_extract_pkg.g_leg_code||
                                               '_RULES.ADD_CUSTOM_XML -->'');');
    build_sql(sqlstr,
              l_cntr_sql,
              'FOR cntr IN pay_payroll_xml_extract_pkg.g_custom_xml.first()..pay_payroll_xml_extract_pkg.g_custom_xml.last() LOOP ');
    build_sql(sqlstr,
              l_cntr_sql,
              'pay_payroll_xml_extract_pkg.load_xml(pay_payroll_xml_extract_pkg.g_custom_xml(cntr));');
    build_sql(sqlstr,
              l_cntr_sql,
              'END LOOP;');
    build_sql(sqlstr,
              l_cntr_sql,
              'pay_payroll_xml_extract_pkg.g_custom_xml.delete();');
    build_sql(sqlstr,
              l_cntr_sql,
              'END IF;');
    build_sql(sqlstr,
              l_cntr_sql,
              'EXCEPTION ');
    build_sql(sqlstr,
              l_cntr_sql,
              'WHEN OTHERS THEN NULL;');
    build_sql(sqlstr,
              l_cntr_sql,
              'END;');

    -- Custom procedure call
    build_sql(sqlstr,
              l_cntr_sql,
              'BEGIN ');
    build_sql(sqlstr,
              l_cntr_sql,
              'EXECUTE IMMEDIATE (''BEGIN '||p_custom_xml_procedure||
                                            '('||l_action_context_id||', NULL'||
                                                   ', '''''|| p_document_type ||
                                                            '''''); END;'');');
    build_sql(sqlstr,
              l_cntr_sql,
              'IF pay_payroll_xml_extract_pkg.g_custom_xml.count() > 0 THEN ');
    build_sql(sqlstr,
              l_cntr_sql,
              'pay_payroll_xml_extract_pkg.load_xml(''<!-- Following segment(s) were added by '||
                                    UPPER(p_custom_xml_procedure)||' -->'');');
    build_sql(sqlstr,
              l_cntr_sql,
              'FOR cntr IN pay_payroll_xml_extract_pkg.g_custom_xml.first()..pay_payroll_xml_extract_pkg.g_custom_xml.last() LOOP ');
    build_sql(sqlstr,
              l_cntr_sql,
              'pay_payroll_xml_extract_pkg.load_xml(pay_payroll_xml_extract_pkg.g_custom_xml(cntr));');
    build_sql(sqlstr,
              l_cntr_sql,
              'END LOOP;');
    build_sql(sqlstr,
              l_cntr_sql,
              'pay_payroll_xml_extract_pkg.g_custom_xml.delete();');
    build_sql(sqlstr,
              l_cntr_sql,
              'END IF;');
    build_sql(sqlstr,
              l_cntr_sql,
              'EXCEPTION ');
    build_sql(sqlstr,
              l_cntr_sql,
              'WHEN OTHERS THEN NULL;');
    build_sql(sqlstr,
              l_cntr_sql,
              'END;');

    IF p_root_tag IS NOT NULL THEN
        build_sql(sqlstr,
                  l_cntr_sql,
                  'pay_payroll_xml_extract_pkg.load_xml(''CE'', NULL, '''||
                                                      p_root_tag||''', NULL);');
    END IF;

    build_sql(sqlstr,
              l_cntr_sql,
              'null;');
    build_sql(sqlstr,
              l_cntr_sql,
              'end;');

    FOR cntr IN sqlstr.first()..sqlstr.last() LOOP
        hr_utility_trace(sqlstr(cntr));
    END LOOP;

    csr := dbms_sql.open_cursor;
    dbms_sql.parse (csr,
                    sqlstr,
                    sqlstr.first(),
                    sqlstr.last(),
                    false,
                    dbms_sql.v7);
    dbms_sql.bind_variable (csr,
                            ':l_action_context_id',
                            p_action_context_id);
    dbms_sql.bind_variable (csr,
                            ':l_action_information_id',
                            p_action_information_id);
    ret := dbms_sql.execute(csr);
    dbms_sql.close_cursor(csr);

    IF g_xml_table.count() <> 0 THEN
        dbms_lob.createTemporary(l_xml, true, dbms_lob.session);
        FOR cntr IN g_xml_table.first()..g_xml_table.last() LOOP
            lr_xml := utl_raw.cast_to_raw(g_xml_table(cntr));
            ln_amt := utl_raw.length(lr_xml);

            dbms_lob.writeAppend(l_xml,
                                 ln_amt,
                                 lr_xml);

            hr_utility_trace (g_xml_table(cntr));
        END LOOP;
        p_xml := l_xml;
        dbms_lob.freeTemporary(l_xml);
    END IF;

    print_blob (p_xml);

    -- Unset globals before exit;
    g_xml_table.delete();
    g_custom_context := NULL;

    hr_utility_trace ('Leaving '||l_proc_name);
END GENERATE_INTERNAL;


  /****************************************************************************
    Name        : GENERATE
    Description : This procedure interprets archived information, converts it to
                  XML and prints it out to a BLOB. This is a public procedure
                  and is based on action_context_IDs passed by the calling
                  process. All archived records belonging to passed
                  action_context_id will be converted to XML. Currently, online
                  payslip and MX Pay Advice invoke this overloaded version.
  *****************************************************************************/

PROCEDURE GENERATE
(
    P_ACTION_CONTEXT_ID         number,
    P_CUSTOM_XML_PROCEDURE      varchar2,
    P_GENERATE_HEADER_FLAG      varchar2, -- {Y/N}
    P_ROOT_TAG                  varchar2,
    P_DOCUMENT_TYPE             varchar2,
    P_XML                       OUT NOCOPY BLOB
) AS
    l_proc_name     varchar2(100);
    lb_header_flag  boolean;
BEGIN
    l_proc_name := g_proc_name || 'GENERATE';
    hr_utility_trace ('Entering '||l_proc_name);

    IF p_generate_header_flag = 'Y' THEN
        lb_header_flag := TRUE;
    ELSE
        lb_header_flag := FALSE;
    END IF;

    generate_internal(
        NULL,
        p_action_context_id,
        NULL,
        p_custom_xml_procedure,
        lb_header_flag,
        p_root_tag,
        p_document_type,
        p_xml);

    hr_utility_trace ('Leaving '||l_proc_name);
END GENERATE;


  /****************************************************************************
    Name        : GENERATE
    Description : This procedure interprets archived information, converts it to
                  XML and prints it out to a BLOB. This is a public procedure
                  and is driven off action_information_IDs set by the calling
                  process.

                  It also accepts a custom XML tag parameter, which if passed a
                  non-null value, will be used as parent enclosing tag of each
                  action_information_id irrespective of the actual action
                  information category.

                  Currently, MX SUA process invokes this overloaded version.
  *****************************************************************************/

PROCEDURE GENERATE
(
    P_ACTION_INF_ID_TAB         int_tab_type,
    P_CUSTOM_ACTION_INFO_CAT    varchar2,
    P_DOCUMENT_TYPE             varchar2,
    P_XML                       OUT NOCOPY BLOB
) AS

    l_xml           BLOB;
    l_xml_temp      BLOB;
    l_proc_name     varchar2(100);
    lr_buf          RAW (2000);
    l_last_param    number;
BEGIN
    l_proc_name := g_proc_name || 'GENERATE-2';
    hr_utility_trace ('Entering '||l_proc_name);
    hr_utility_trace ('Total action_information_IDs = '||
                                                   p_action_inf_id_tab.count());

    IF p_action_inf_id_tab.count() > 0 THEN
        FOR cntr_arch_rec IN
                        p_action_inf_id_tab.first()..p_action_inf_id_tab.last()
        LOOP
            hr_utility_trace(p_action_inf_id_tab (cntr_arch_rec));
        END LOOP;
    END IF;

    IF p_action_inf_id_tab.count() > 0 THEN
        dbms_lob.createTemporary (l_xml,
                                  TRUE,
                                  dbms_lob.SESSION);
        FOR cntr_arch_rec IN
                        p_action_inf_id_tab.first()..p_action_inf_id_tab.last()
        LOOP
            l_last_param := pay_payroll_xml_extract_pkg.g_custom_params.last();
            IF l_last_param IS NULL THEN
                l_last_param := 0;
            END IF;

            pay_payroll_xml_extract_pkg.g_custom_params(
                    l_last_param + 1).parameter_name := 'action_information_id';

            pay_payroll_xml_extract_pkg.g_custom_params(
                    l_last_param + 1).parameter_value :=
                                             p_action_inf_id_tab(cntr_arch_rec);

            generate_internal(
                p_action_inf_id_tab(cntr_arch_rec),
                NULL,
                p_custom_action_info_cat,
                NULL,
                FALSE,
                NULL,
                p_document_type,
                l_xml_temp);

            dbms_lob.append(l_xml,
                            l_xml_temp);

            /* Remove the parameter 'action_information_id' before the next
               iteration (or returning to the calling program). Calling
               application is expected to clear this cache to avoid a
               possibility of stale parameter values in subsequent calls.*/
            pay_payroll_xml_extract_pkg.g_custom_params.delete(
                            pay_payroll_xml_extract_pkg.g_custom_params.last());
        END LOOP;
        p_xml := l_xml;
        dbms_lob.freeTemporary(l_xml);
    END IF;

    hr_utility_trace ('Leaving '||l_proc_name);

-- Bug 6068599
EXCEPTION
    WHEN OTHERS THEN
        /* Remove the parameter 'action_information_id' in case of error. */
        pay_payroll_xml_extract_pkg.g_custom_params.delete(
                        pay_payroll_xml_extract_pkg.g_custom_params.last());
        hr_utility_trace (sqlerrm);
        RAISE;
END;

BEGIN
    --hr_utility.trace_on (null, 'MX_IDC');
    g_proc_name := 'PAY_PAYROLL_XML_EXTRACT_PKG.';
    g_debug := hr_utility.debug_enabled;
END PAY_PAYROLL_XML_EXTRACT_PKG;

/
