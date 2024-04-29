--------------------------------------------------------
--  DDL for Package Body PAY_FI_ACRR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_ACRR" AS
/* $Header: pyfiacrr.pkb 120.5 2006/04/03 05:44:25 dbehera noship $ */
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
      l_counter             NUMBER                                            := 1;
      l_payroll_action_id   pay_action_information.action_information1%TYPE;
      CURSOR csr_Element_data (csr_v_pa_id IN VARCHAR2)
      IS
      SELECT pai.action_information2 Legal_Employer,
       pai.action_information10 Start_Date,
       pai.action_information11 End_Date,
       pai2.action_information4 Local_Unit,
       pai1.action_information5 ||'-' || pai2.action_information6 Company_Number,
       pai4.action_information4 Element_name,
       pai4.action_information6 Account_number,
       nvl(pai4.action_information7,0) Credit,
       nvl(pai4.action_information8,0) Debit
  FROM pay_action_information pai,
       pay_payroll_actions ppa,
       pay_action_information pai1,
       pay_action_information pai2,
       pay_action_information pai4
 WHERE pai.action_context_id = ppa.payroll_action_id
   AND ppa.payroll_action_id = csr_v_pa_id
   AND pai.action_context_id = pai1.action_context_id
   AND pai1.action_context_id= pai2.action_context_id
   AND pai2.action_context_id=pai4.action_context_id
   AND pai4.action_context_id=pai.action_context_id
   AND pai1.action_information3=pai2.action_information5
   AND pai2.action_information3=pai4.action_information5
   AND pai1.action_context_type='PA'
   AND pai1.action_information2 = 'LE'
   AND pai1.action_information1 = 'PYFIACRA'
   AND pai1.action_information_category = 'EMEA REPORT INFORMATION'
   AND pai.action_context_type = 'PA'
   AND pai.action_information1 = 'PYFIACRA'
   AND pai.action_information_category = 'EMEA REPORT DETAILS'
   AND pai2.action_context_type = 'PA'
   AND pai2.action_information1 = 'PYFIACRA'
   AND pai2.action_information_category = 'EMEA REPORT INFORMATION'
   AND pai2.action_information2 = 'LU'
   AND pai4.action_context_type = 'PA'
   AND pai4.action_information1 = 'PYFIACRA'
   AND pai4.action_information_category = 'EMEA REPORT INFORMATION'
   AND pai4.action_information2 = 'EL';

   element_data              csr_Element_data%ROWTYPE;
   BEGIN
      l_payroll_action_id :=
                          get_archive_payroll_action_id (p_payroll_action_id);
      FOR element_data IN csr_Element_data (l_payroll_action_id)
      LOOP
         gplsqltable (l_counter).tagname := 'START';
         gplsqltable (l_counter).tagvalue := 'START';
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'LEGAL_EMPLOYER';
         gplsqltable (l_counter).tagvalue :=
                                          TO_CHAR (element_data.Legal_Employer);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'START_DATE';
         gplsqltable (l_counter).tagvalue :=
				       (element_data.Start_Date);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'END_DATE';
         gplsqltable (l_counter).tagvalue :=
					   (element_data.End_Date);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'CURRENCY';
         gplsqltable (l_counter).tagvalue := TO_CHAR('EUR');
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'LOCAL_UNIT';
         gplsqltable (l_counter).tagvalue := TO_CHAR (element_data.Local_Unit);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'COMPANY_NUMBER';
         gplsqltable (l_counter).tagvalue :=
                                            TO_CHAR (element_data.Company_Number);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'ELEMENT_NAME';
         gplsqltable (l_counter).tagvalue := TO_CHAR (element_data.Element_Name);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'ACCOUNT_NUMBER';
         gplsqltable (l_counter).tagvalue :=
                                       TO_CHAR (element_data.Account_Number);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'CREDIT';
         gplsqltable (l_counter).tagvalue :=TO_CHAR(NVL(FND_NUMBER.canonical_to_number
					   (element_data.Credit),0) ,'999G999G990D99' );
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'DEBIT';
         gplsqltable (l_counter).tagvalue :=
                                         TO_CHAR(NVL(FND_NUMBER.canonical_to_number
					(element_data.Debit),0) ,'999G999G990D99' );
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'END';
         gplsqltable (l_counter).tagvalue := 'END';
         l_counter :=   l_counter
                      + 1;
      END LOOP;
      writetoclob (p_xml);
      COMMIT;
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
     l_IANA_charset :=hr_fi_utility.get_IANA_charset ;
      hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</ROOT>';
      l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
      l_str10 := '<ACCR>';
      l_str11 := '</ACCR>';
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
COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE (   'sqlerrm '
                           || SQLERRM);
         hr_utility.raise_error;
   END writetoclob;
-------------------------------------------------------------------------------------------------------------------------
END PAY_FI_ACRR;

/
