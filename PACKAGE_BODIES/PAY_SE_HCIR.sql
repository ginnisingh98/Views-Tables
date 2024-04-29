--------------------------------------------------------
--  DDL for Package Body PAY_SE_HCIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_HCIR" AS
   /* $Header: pysehcir.pkb 120.0.12000000.1 2007/07/18 11:07:49 psingla noship $ */
   PROCEDURE get_data (
      p_business_group_id   IN              NUMBER,
      p_payroll_action_id   IN              VARCHAR2,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   ) IS
      --Cursors needed for report
      CURSOR csr_all_legal_employer (
         csr_v_pa_id   pay_action_information.action_context_id%TYPE
      ) IS
         SELECT action_information4 legal_employer_name, action_information5 org_number,
	        fnd_date.canonical_to_date(action_information6) curr_start_date,
		fnd_date.canonical_to_date (action_information7)curr_end_date,
		fnd_date.canonical_to_date (action_information8) prev_start_date,
		fnd_date.canonical_to_date (action_information9) prev_end_date,
                fnd_number.canonical_to_number (action_information10)
                      curr_avg_men_count,
                fnd_number.canonical_to_number (action_information11) curr_avg_women_count,
                fnd_number.canonical_to_number (action_information12)
                      prev_avg_men_count,
                fnd_number.canonical_to_number (action_information13) prev_avg_women_count, effective_date
         FROM   pay_action_information
         WHERE action_context_type = 'PA'
         AND   action_context_id = csr_v_pa_id
         AND   action_information_category = 'EMEA REPORT INFORMATION'
         AND   action_information1 = 'PYSEHCIA'
         AND   action_information2 = 'LE';

      l_payroll_action_id   pay_action_information.action_information1%TYPE;
      l_counter             NUMBER                                            := 0;
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

      FOR i IN csr_all_legal_employer (l_payroll_action_id)
      LOOP
         --
         xml_tab (l_counter).tagname := 'ORG_NAME';
         xml_tab (l_counter).tagvalue := i.legal_employer_name;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'ORG_NUM';
         xml_tab (l_counter).tagvalue := i.org_number;
         l_counter := l_counter + 1;
	  --
         xml_tab (l_counter).tagname := 'CURR_START_DATE';
         xml_tab (l_counter).tagvalue := to_char(i.curr_start_date,'YYYYMMDD');
         l_counter := l_counter + 1;
	  --
         xml_tab (l_counter).tagname := 'CURR_END_DATE';
         xml_tab (l_counter).tagvalue := to_char(i.curr_end_date,'YYYYMMDD');
         l_counter := l_counter + 1;

	   --
         xml_tab (l_counter).tagname := 'PREV_START_DATE';
         xml_tab (l_counter).tagvalue := to_char(i.prev_start_date,'YYYYMMDD');
         l_counter := l_counter + 1;

	   --
         xml_tab (l_counter).tagname := 'PREV_END_DATE';
         xml_tab (l_counter).tagvalue := to_char(i.prev_end_date,'YYYYMMDD');
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_AVG_MEN_COUNT';
         xml_tab (l_counter).tagvalue := i.curr_avg_men_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_AVG_WOMEN_COUNT';
         xml_tab (l_counter).tagvalue := i.curr_avg_women_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'PREV_AVG_MEN_COUNT';
         xml_tab (l_counter).tagvalue := i.prev_avg_men_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'PREV_AVG_WOMEN_COUNT';
         xml_tab (l_counter).tagvalue := i.prev_avg_women_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'CURR_AVG_TOTAL_COUNT';
         xml_tab (l_counter).tagvalue := i.curr_avg_men_count + i.curr_avg_women_count;
         l_counter := l_counter + 1;
         --
         xml_tab (l_counter).tagname := 'PREV_AVG_TOTAL_COUNT';
         xml_tab (l_counter).tagvalue := i.prev_avg_men_count + i.prev_avg_women_count;
         l_counter := l_counter + 1;
      --
      END LOOP;

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
               dbms_lob.writeappend (l_xfdf_string, LENGTH (l_str15), l_str15);
            ELSIF xml_tab (table_counter + 1).tagname = 'ORG_NAME' AND l_str8 <> 'REPORT_DATE' THEN
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

END pay_se_hcir;

/
