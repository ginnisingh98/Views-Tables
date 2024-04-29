--------------------------------------------------------
--  DDL for Package Body PAY_SE_TRNR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_TRNR" AS
   /* $Header: pysetrnr.pkb 120.2 2007/07/30 12:24:31 psingla noship $ */
   PROCEDURE get_data (
      p_business_group_id   IN              NUMBER,
      p_payroll_action_id   IN              VARCHAR2,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   ) IS
      CURSOR csr_report_parameters IS
         SELECT fnd_date.canonical_to_date (action_information5) joinig_start_date,
                fnd_date.canonical_to_date (action_information6)
                      joinig_end_date, action_information9 division,
                action_information12 agreement_area, action_information13 empployee_category,
                action_information14
                      assignment_category,
                fnd_date.canonical_to_date (action_information16) start_date_of_birth,
                fnd_date.canonical_to_date (action_information17)
                      end_date_of_birth,
                fnd_date.canonical_to_date (action_information18) precedence_end_date,
                fnd_date.canonical_to_date (action_information19)
                      report_date, action_information20 sort_order
         FROM   pay_action_information
         WHERE action_context_id = p_payroll_action_id AND action_information_category = 'EMEA REPORT DETAILS';

      rec_report_parameters   csr_report_parameters%ROWTYPE;

      --Cursors needed for report
      CURSOR csr_all_legal_employer (
         csr_v_pa_id   pay_action_information.action_context_id%TYPE
      ) IS
         SELECT action_information3 legal_emp_id, action_information4 legal_employer_name, action_information5 org_number,
                effective_date
         FROM   pay_action_information
         WHERE action_context_type = 'PA'
         AND   action_context_id = csr_v_pa_id
         AND   action_information_category = 'EMEA REPORT INFORMATION'
         AND   action_information1 = 'PYSETRNA'
         AND   action_information2 = 'LE';

      /* All Division */
      CURSOR csr_get_all_divisons (
         csr_v_pa_id           pay_action_information.action_context_id%TYPE,
         p_legal_employer_id   pay_action_information.action_information13%TYPE --,
      -- p_sort_order          pay_action_information.action_information20%TYPE
      ) IS
         SELECT DISTINCT action_information14 division_code, action_information16 division
         FROM            pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
         WHERE  paa.payroll_action_id = p_payroll_action_id
         AND    assg.payroll_action_id = paa.payroll_action_id
         AND    pai.action_context_id = assg.assignment_action_id
         AND    action_context_type = 'AAP'
         --AND   action_context_id = csr_v_pa_id
         AND    action_information_category = 'EMEA REPORT INFORMATION'
         AND    action_information1 = 'PYSETRNA'
         AND    action_information13 = p_legal_employer_id;

      /* All Agreement Areas */
      CURSOR csr_get_all_areas (
         csr_v_pa_id           pay_action_information.action_context_id%TYPE,
         p_legal_employer_id   pay_action_information.action_information13%TYPE,
         p_div                 pay_action_information.action_information14%TYPE
      ) IS
         SELECT DISTINCT action_information15 area_code, action_information17 agreement_area
         FROM            pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
         WHERE  paa.payroll_action_id = p_payroll_action_id
         AND    assg.payroll_action_id = paa.payroll_action_id
         AND    pai.action_context_id = assg.assignment_action_id
         AND    action_context_type = 'AAP'
         --AND   action_context_id = csr_v_pa_id
         AND    action_information_category = 'EMEA REPORT INFORMATION'
         AND    action_information1 = 'PYSETRNA'
         AND    action_information13 = p_legal_employer_id
         AND    action_information14 = p_div;

      l_payroll_action_id     pay_action_information.action_information1%TYPE;
      l_counter               NUMBER                                             := 0;
      l_count                 NUMBER                                             := 0;
      p_sql                   VARCHAR2 (10000);
      l_national_identifier   pay_action_information.action_information4%TYPE;
      l_assignment_number     pay_action_information.action_information5%TYPE;
      l_full_name             pay_action_information.action_information6%TYPE;
      l_hire_date             DATE;
      l_total_emp_time        NUMBER;
      l_precedence_date       DATE;
      l_termination_date      DATE;
      l_emp_type              pay_action_information.action_information11%TYPE;
      l_emp_sec               pay_action_information.action_information12%TYPE;
      l_select_str            VARCHAR2 (3000);

      TYPE emp_ref IS REF CURSOR;

      csr_get_emp             emp_ref;
      l_sort_order            VARCHAR2 (100);
   BEGIN
      IF p_payroll_action_id IS NULL THEN
         BEGIN
            SELECT payroll_action_id
            INTO  l_payroll_action_id
            FROM   pay_payroll_actions ppa, fnd_conc_req_summary_v fcrs, fnd_conc_req_summary_v fcrs1
            WHERE fcrs.request_id = fnd_global.conc_request_id
            AND   fcrs.priority_request_id = fcrs1.priority_request_id
            AND   ppa.request_id BETWEEN fcrs1.request_id AND fcrs.request_id
            AND   ppa.request_id = fcrs1.request_id;
         EXCEPTION
            WHEN OTHERS THEN
               NULL;
         END;
      ELSE
         l_payroll_action_id := p_payroll_action_id;
      END IF;

      OPEN csr_report_parameters;
      FETCH csr_report_parameters INTO rec_report_parameters;
      CLOSE csr_report_parameters;

      SELECT 'order by '
             || decode (
                   nvl (rec_report_parameters.sort_order, 'EMP_TIME'),
                   'EMP_TIME', ' total_emp_time desc ',
                   'ASG_NUM', ' assignment_number asc ',
                   'NAME', ' full_name asc ',
                   'PIN', ' national_identifier asc '
                )
      INTO  l_sort_order
      FROM   dual;

      FOR rec_leg_emp IN csr_all_legal_employer (l_payroll_action_id)
      LOOP
         FOR rec_all_division IN csr_get_all_divisons (l_payroll_action_id, rec_leg_emp.legal_emp_id)
         LOOP
            FOR rec_all_area IN csr_get_all_areas (
                                   l_payroll_action_id,
                                   rec_leg_emp.legal_emp_id,
                                   rec_all_division.division_code
                                )
            LOOP
               xml_tab (l_counter).tagname := 'ORG_NAME';
               xml_tab (l_counter).tagvalue := rec_leg_emp.legal_employer_name;
               l_counter := l_counter + 1;

--
               xml_tab (l_counter).tagname := 'J_START_DATE';
               xml_tab (l_counter).tagvalue := to_char (rec_report_parameters.joinig_start_date, 'YYYYMMDD');
               l_counter := l_counter + 1;
               --

               xml_tab (l_counter).tagname := 'J_END_DATE';
               xml_tab (l_counter).tagvalue := to_char (rec_report_parameters.joinig_end_date, 'YYYYMMDD');
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'DIV';
               xml_tab (l_counter).tagvalue := rec_all_division.division;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'AGREEMENT_AREA';
               xml_tab (l_counter).tagvalue := rec_report_parameters.agreement_area;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'EMP_CATG';
               xml_tab (l_counter).tagvalue := rec_report_parameters.empployee_category;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ASG_CATG';
               xml_tab (l_counter).tagvalue := rec_report_parameters.assignment_category;
               l_counter := l_counter + 1;
               --

               xml_tab (l_counter).tagname := 'S_DOB';
               xml_tab (l_counter).tagvalue := to_char (rec_report_parameters.start_date_of_birth, 'YYYYMMDD');
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'E_DOB';
               xml_tab (l_counter).tagvalue := to_char (rec_report_parameters.end_date_of_birth, 'YYYYMMDD');
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PREC_DATE';
               xml_tab (l_counter).tagvalue := to_char (rec_report_parameters.precedence_end_date, 'YYYYMMDD');
               l_counter := l_counter + 1;
               ----

               xml_tab (l_counter).tagname := 'REPORT_DATE';
               xml_tab (l_counter).tagvalue := to_char (rec_report_parameters.report_date, 'YYYYMMDD');
               l_counter := l_counter + 1;
               --

               xml_tab (l_counter).tagname := 'PRIORITY_AREA';
               xml_tab (l_counter).tagvalue := rec_all_area.agreement_area;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'PRIORITY_BRANCH';
               xml_tab (l_counter).tagvalue := rec_all_area.agreement_area;
               l_counter := l_counter + 1;
               --
               xml_tab (l_counter).tagname := 'ORG_NUM';
               xml_tab (l_counter).tagvalue := rec_leg_emp.org_number;
               l_counter := l_counter + 1;


               l_select_str :=
                  'SELECT   action_information4 national_identifier,
                  action_information5
                        assignment_number, action_information6 full_name,
                  fnd_date.canonical_to_date (action_information7)
                        hire_date,
                  fnd_number.canonical_to_number (action_information8) total_emp_time,
                  fnd_date.canonical_to_date (action_information9)
                        precedence_date,
                  fnd_date.canonical_to_date (action_information10) termination_date, action_information11 emp_type,
                  action_information12
                        emp_sec
         FROM     pay_payroll_actions paa, pay_assignment_actions assg, pay_action_information pai
         WHERE paa.payroll_action_id = '
                  || l_payroll_action_id
                  || ' AND   assg.payroll_action_id = paa.payroll_action_id
         AND   pai.action_context_id = assg.assignment_action_id
         AND   action_context_type = '
                  || '''AAP''' || ' AND   action_information_category = ' || '''EMEA REPORT INFORMATION'''
                  || ' AND   action_information1 = ' || '''PYSETRNA''' || ' AND   action_information13 = '
                  || rec_leg_emp.legal_emp_id || ' AND   action_information14 = ' || '''' || rec_all_division.division_code || ''''
                  || ' AND   action_information15 = ' || '''' || rec_all_area.area_code || '''' || ' ' || l_sort_order;

		  fnd_file.put_line (fnd_file.LOG, 'l_select_str :-  '||length(l_select_str));
               l_national_identifier := NULL;
               l_assignment_number := NULL;
               l_full_name := NULL;
               l_hire_date := NULL;
               l_total_emp_time := NULL;
               l_precedence_date := NULL;
               l_termination_date := NULL;
               l_emp_type := NULL;
               l_emp_sec := NULL;
               OPEN csr_get_emp FOR l_select_str;

               LOOP
                  FETCH csr_get_emp INTO l_national_identifier,
                                         l_assignment_number,
                                         l_full_name,
                                         l_hire_date,
                                         l_total_emp_time,
                                         l_precedence_date,
                                         l_termination_date,
                                         l_emp_type,
                                         l_emp_sec;
                  EXIT WHEN csr_get_emp%NOTFOUND;

                  xml_tab (l_counter).tagname := 'NATIONAL_IDENTIFIER';
                  xml_tab (l_counter).tagvalue := l_national_identifier;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'EMP_NAME';
                  xml_tab (l_counter).tagvalue := l_full_name;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'ASG_NUMBER';
                  xml_tab (l_counter).tagvalue := l_assignment_number;
                  l_counter := l_counter + 1;

--

                  xml_tab (l_counter).tagname := 'TOTAL_EMP_TIME';
                  xml_tab (l_counter).tagvalue := to_char (l_total_emp_time);
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'EMP_TYPE';
                  xml_tab (l_counter).tagvalue := l_emp_type;
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'PRECEDENCE_DATE';
                  xml_tab (l_counter).tagvalue := to_char (l_precedence_date, 'YYYYMMDD');
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'TERMINATION_DATE';
                  xml_tab (l_counter).tagvalue := to_char (l_termination_date, 'YYYYMMDD');
                  l_counter := l_counter + 1;
                  --
                  xml_tab (l_counter).tagname := 'HIRE_DATE';
                  xml_tab (l_counter).tagvalue := to_char (l_hire_date, 'YYYYMMDD');
                  l_counter := l_counter + 1;

		  l_select_str := null;
               END LOOP; -- End of Employee Loop
            END LOOP; -- End of Agreement Area Loop
         END LOOP; -- End of Division Loop
      END LOOP; -- End of Legal Employer Loop
      writetoclob (p_xml);
   END get_data;

-----------------------------------------------------------------------------------------------------------------
   PROCEDURE writetoclob (
      p_xfdf_clob   OUT NOCOPY   CLOB
   ) IS
      l_xfdf_string    CLOB;
      l_iana_charset   VARCHAR2 (30);
      current_index    PLS_INTEGER;
      l_str1           VARCHAR2 (1000);
      l_str2           VARCHAR2 (20);
      l_str3           VARCHAR2 (20);
      l_str4           VARCHAR2 (20);
      l_str5           VARCHAR2 (20);
      l_str6           VARCHAR2 (30);
      l_str7           VARCHAR2 (1000);
      l_str8           VARCHAR2 (240);
      l_str9           VARCHAR2 (240);
      l_str10          VARCHAR2 (20);
      l_str11          VARCHAR2 (20);
      l_str12          VARCHAR2 (30);
      l_str13          VARCHAR2 (30);
      l_str14          VARCHAR2 (30);
      l_str15          VARCHAR2 (30);
      l_str16          VARCHAR2 (30);
      l_str17          VARCHAR2 (30);
   BEGIN
      l_iana_charset := hr_se_utility.get_iana_charset;
      l_str1 := '<?xml version="1.0" encoding="' || l_iana_charset || '"?> <ROOT><PAACR>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</PAACR></ROOT>';
      l_str7 := '<?xml version="1.0" encoding="' || l_iana_charset || '"?> <ROOT></ROOT>';
      l_str10 := '<PAACR>';
      l_str11 := '</PAACR>';
      l_str12 := '<FILE_HEADER_START>';
      l_str13 := '</FILE_HEADER_START>';
      l_str14 := '<LE_RECORD>';
      l_str15 := '</LE_RECORD>';
      l_str14 := '<LE_RECORD>';
      l_str15 := '</LE_RECORD>';
      l_str16 := '<EMP_RECORD>';
      l_str17 := '</EMP_RECORD>';
      dbms_lob.createtemporary (l_xfdf_string, FALSE , dbms_lob.CALL);
      dbms_lob.OPEN (l_xfdf_string, dbms_lob.lob_readwrite);
      current_index := 0;

      IF xml_tab.count > 0 THEN
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str12), l_str12);

         FOR table_counter IN xml_tab.FIRST .. xml_tab.LAST
         LOOP
            l_str8 := xml_tab (table_counter).tagname;
            l_str9 := xml_tab (table_counter).tagvalue;

            IF l_str8 = 'ORG_NAME' THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str14), l_str14);
            ELSIF l_str8 = 'NATIONAL_IDENTIFIER' THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str16), l_str16);
            END IF;

            IF l_str9 IS NOT NULL THEN
               l_str9 := '<![CDATA[' || l_str9 || ']]>';
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            ELSE
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            END IF;

            IF xml_tab.LAST = table_counter THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str17), l_str17);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str15), l_str15);
            ELSIF l_str8 = 'HIRE_DATE' AND xml_tab (table_counter + 1).tagname = 'NATIONAL_IDENTIFIER' THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str17), l_str17);
            ELSIF l_str8 = 'HIRE_DATE' AND xml_tab (table_counter + 1).tagname = 'ORG_NAME' THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str17), l_str17);
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str15), l_str15);
            ELSIF xml_tab (table_counter + 1).tagname = 'ORG_NAME' THEN
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str15), l_str15);
            END IF;
         END LOOP;

         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str13), l_str13);
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;

      p_xfdf_clob := l_xfdf_string;
      hr_utility.set_location ('Leaving WritetoCLOB ', 20);
   END writetoclob;
-------------------------------------------------------------------------------------------------------------------------

END pay_se_trnr;

/
