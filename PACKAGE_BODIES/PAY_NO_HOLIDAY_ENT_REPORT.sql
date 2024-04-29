--------------------------------------------------------
--  DDL for Package Body PAY_NO_HOLIDAY_ENT_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NO_HOLIDAY_ENT_REPORT" AS
/* $Header: pynohler.pkb 120.0.12000000.1 2007/05/22 07:34:24 rajesrin noship $ */
   FUNCTION get_archive_payroll_action_id (p_payroll_action_id IN NUMBER)
      RETURN NUMBER
   IS
      l_payroll_action_id   NUMBER;
   BEGIN
      IF p_payroll_action_id IS NULL
      THEN
         BEGIN
            SELECT payroll_action_id
              INTO l_payroll_action_id
              FROM pay_payroll_actions ppa,
                   fnd_conc_req_summary_v fcrs,
                   fnd_conc_req_summary_v fcrs1
             WHERE fcrs.request_id = fnd_global.conc_request_id
               AND fcrs.priority_request_id = fcrs1.priority_request_id
               AND ppa.request_id BETWEEN fcrs1.request_id
                                      AND fcrs.request_id
               AND ppa.request_id = fcrs1.request_id;
         EXCEPTION
            WHEN OTHERS
            THEN
               NULL;
         END;
      ELSE
         l_payroll_action_id := p_payroll_action_id;
      END IF;
      RETURN l_payroll_action_id;
   END;
   PROCEDURE get_data (
      p_business_group_id  in varchar2,
      p_payroll_action_id   IN              VARCHAR2,
      p_template_name       IN              VARCHAR2,
      p_xml                 OUT NOCOPY      CLOB
   )
   IS
      /*  Start of declaration*/
      -- Variables needed for the report
      l_sum                 NUMBER;
      l_counter             NUMBER  := 1;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;
      l_legal_employer_id number;
      l_legal_employer HR_ORGANIZATION_UNITS.name%type;
      l_eff_date  date;
      CURSOR csr_legal_employer is select o.name,fnd_date.canonical_to_date(pai.action_information4) from
					HR_ORGANIZATION_UNITS o,
					HR_ORGANIZATION_INFORMATION hoi1,
					pay_action_information pai
					where pai.action_context_id = l_payroll_action_id
					and pai.action_information_category ='EMEA REPORT DETAILS'
					and o.organization_id = pai.action_information2
					and hoi1.organization_id = o.organization_id
					and hoi1.org_information_context = 'CLASS'
					and hoi1.org_information1 = 'HR_LEGAL_EMPLOYER';


      CURSOR csr_holiday_ent_data (csr_v_pa_id IN VARCHAR2)
        IS
	SELECT pai.assignment_id,
		pai.action_information1,
		pai.action_information2 assignment_number,
		pai.action_information3 full_name,
		pai.action_information4 holiday_ent_days,
		pai.action_information5  holiday_ent_60_days,
		pai.action_information6 holiday_carried_fwd_days,
		pai.action_information7 holiday_taken_days,
		pai.action_information8  holiday_taken_60_days,
		pai.action_information9  holiday_remaining_days,
		pai.action_information10 holiday_remaining60_days
	FROM pay_action_information pai
	     ,pay_assignment_actions paa
	WHERE pai.action_context_id =  paa.assignment_action_id
	AND paa.payroll_action_id = csr_v_pa_id
        AND action_information_category ='EMEA REPORT INFORMATION'
	AND action_information1 = 'PYNOHLEA';



   BEGIN
      l_payroll_action_id :=  get_archive_payroll_action_id (p_payroll_action_id);

      open csr_legal_employer;
      fetch csr_legal_employer into l_legal_employer,l_eff_date;
      close csr_legal_employer;

      gplsqltable (0).tagname := 'LEGAL_EMPLOYER';
      gplsqltable (0).tagvalue := l_legal_employer;
      gplsqltable (l_counter).tagname  := 'EFFECTIVE_DATE';
      gplsqltable (l_counter).tagvalue := to_char(l_eff_date,'DD.Mon.YYYY');
      l_counter :=   l_counter+ 1;

      FOR csr_holiday_ent_datas IN csr_holiday_ent_data (l_payroll_action_id)
      LOOP

         gplsqltable (l_counter).tagname  := 'START';
         gplsqltable (l_counter).tagvalue := 'START';
         l_counter :=   l_counter+ 1;

         gplsqltable (l_counter).tagname  := 'FULL_NAME';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.full_name||' ['||csr_holiday_ent_datas.assignment_number||']';
         l_counter :=   l_counter+ 1;

         gplsqltable (l_counter).tagname  := 'HOLIDAY_ENT_DAYS';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.holiday_ent_days;
         l_counter :=   l_counter+ 1;

         gplsqltable (l_counter).tagname  := 'HOLIDAY_ENT_60_DAYS';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.holiday_ent_60_days;
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname  := 'HOLIDAY_CARRIED_FWD_DAYS';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.holiday_carried_fwd_days;
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname  := 'HOLIDAY_TAKEN_DAYS';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.holiday_taken_days;
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname  := 'HOLIDAY_TAKEN_60_DAYS';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.holiday_taken_60_days;
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname  := 'HOLIDAY_REMAINING_DAYS';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.holiday_remaining_days;
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname  := 'HOLIDAY_REMAINING60_DAYS';
         gplsqltable (l_counter).tagvalue := csr_holiday_ent_datas.holiday_remaining60_days;
         l_counter :=   l_counter + 1;

         gplsqltable (l_counter).tagname  := 'END';
         gplsqltable (l_counter).tagvalue := 'END';
         l_counter :=   l_counter + 1;

      END LOOP;

      writetoclob (p_xml);

   END get_data;
-----------------------------------------------------------------------------------------------------------------
   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB)
   IS
      l_xfdf_string   CLOB;
      l_str1          VARCHAR2 (1000);
      l_str2          VARCHAR2 (20);
      l_str3          VARCHAR2 (20);
      l_str4          VARCHAR2 (20);
      l_str5          VARCHAR2 (20);
      l_str6          VARCHAR2 (30);
      l_str7          VARCHAR2 (1000);
      l_str8          VARCHAR2 (240);
      l_str9          VARCHAR2 (240);
      l_str10         VARCHAR2 (20);
      l_str11         VARCHAR2 (20);
      current_index   PLS_INTEGER;
      l_counter       PLS_INTEGER;
      l_IANA_charset VARCHAR2 (50);
   BEGIN
     l_IANA_charset :=hr_no_utility.get_IANA_charset ;
      hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</ROOT>';
      l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
      l_str10 := '<HOLIDAY>';
      l_str11 := '</HOLIDAY>';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;
      IF gplsqltable.COUNT > 0
      THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);
         FOR table_counter IN gplsqltable.FIRST .. gplsqltable.LAST
         LOOP
            l_str8 := gplsqltable (table_counter).tagname;
            l_str9 := gplsqltable (table_counter).tagvalue;
            IF l_str9 = 'END'
            THEN
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_str11),
                  l_str11
               );
            ELSIF l_str9 = 'START'
            THEN
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_str10),
                  l_str10
               );
            ELSIF l_str9 IS NOT NULL
            THEN
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            ELSE
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
               DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
            END IF;
         END LOOP;
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str6), l_str6);
      ELSE
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str7), l_str7);
      END IF;
      p_xfdf_clob := l_xfdf_string;

   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE (   'sqlerrm '
                           || SQLERRM);
         hr_utility.raise_error;
   END writetoclob;

END PAY_NO_HOLIDAY_ENT_REPORT;

/
