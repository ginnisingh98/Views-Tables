--------------------------------------------------------
--  DDL for Package Body PAY_FI_PAYLIST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_PAYLIST" AS
   /* $Header: pyfipaylr.pkb 120.2.12000000.2 2007/06/12 09:39:51 psingla noship $ */

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

      l_payroll_action_id   pay_action_information.action_information1%TYPE;
l_sr_no	 NUMBER ;
l_counter	number := 0;
CURSOR CSR_HEADER(csr_v_pa_id IN VARCHAR2)
      IS
      SELECT pai.action_information4 payroll_name,
       pai.action_information5
             payment_month,
              pai.action_information6 pay_day,
       pai.action_information7
             end_date
         FROM pay_action_information pai,
      pay_payroll_actions ppa
 WHERE pai.action_context_id = ppa.payroll_action_id
   AND ppa.payroll_action_id = csr_v_pa_id;
CSR_HEADER_REC CSR_HEADER%ROWTYPE;



      CURSOR csr_payl_data (csr_v_pa_id IN VARCHAR2)
      IS
      SELECT
       pai_ass.action_information3 person_name,
       pai_ass.action_information4
             salary,
       pai_ass.action_information5 benefits,
       pai_ass.action_information6
             insurance_salary,
       pai_ass.action_information7
             deductions_withhold_tax,
       pai_ass.action_information8 tax_income,
       pai_ass.action_information9
             withhold_tax,
       pai_ass.action_information10 expenses,
       pai_ass.action_information11
             after_tax_deductions,
       pai_ass.action_information12 net_pay,
      pai_ass.action_information13 capital_income_base,
      pai_ass.action_information14 assignment_number
  FROM pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_action_information pai_ass
 WHERE ppa.payroll_action_id = csr_v_pa_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND paa.assignment_action_id = pai_ass.action_context_id
   AND pai_ass.action_context_type = 'AAP'
   AND pai_ass.action_information1 = 'PYFIPAYL'
   AND pai_ass.action_information_category = 'EMEA REPORT INFORMATION';

      CURSOR csr_total (csr_v_pa_id IN VARCHAR2)
      IS
      SELECT
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information4))
             salary,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information5)) benefits,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information6))
             insurance_salary,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information7))
             deductions_withhold_tax,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information8)) tax_income,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information9))
             withhold_tax,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information10) )expenses,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information11))
             after_tax_deductions,
       SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information12))net_pay,
      SUM(FND_NUMBER.CANONICAL_TO_NUMBER(pai_ass.action_information13)) capital_income_base
  FROM pay_payroll_actions ppa,
       pay_assignment_actions paa,
       pay_action_information pai_ass
 WHERE ppa.payroll_action_id = csr_v_pa_id
   AND paa.payroll_action_id = ppa.payroll_action_id
   AND paa.assignment_action_id = pai_ass.action_context_id
   AND pai_ass.action_context_type = 'AAP'
   AND pai_ass.action_information1 = 'PYFIPAYL'
   AND pai_ass.action_information_category = 'EMEA REPORT INFORMATION';

csr_total_REC csr_total%ROWTYPE;

              payl_rep              csr_payl_data%ROWTYPE;
   BEGIN
      hr_utility.set_location ('Entered Procedure GETDATA', 10);
      fnd_file.put_line (
         fnd_file.LOG,
            'payroll_action_id '
         || l_payroll_action_id
      );
      l_payroll_action_id :=
                          get_archive_payroll_action_id (p_payroll_action_id);
      fnd_file.put_line (
         fnd_file.LOG,
            'payroll_action_id '
         || l_payroll_action_id
      );
      				OPEN  CSR_HEADER( l_payroll_action_id);
					FETCH CSR_HEADER INTO CSR_HEADER_REC;
				CLOSE CSR_HEADER;

   			       hr_utility.set_location('Before populating pl/sql table',20);

				gplsqltable(l_counter).TagName := 'HEADER_START';
				gplsqltable(l_counter).TagValue := 'HEADER_START';
					l_counter := l_counter + 1;

				gplsqltable(l_counter).TagName := 'PAYROLL_NAME';
				gplsqltable(l_counter).TagValue :=CSR_HEADER_REC.payroll_name;
					l_counter := l_counter + 1;

				gplsqltable(l_counter).TagName := 'PAYMENT_MONTH';
				gplsqltable(l_counter).TagValue :=  CSR_HEADER_REC.payment_month;
					l_counter := l_counter + 1;

				gplsqltable(l_counter).TagName := 'PAY_DAY';
				gplsqltable(l_counter).TagValue :=    FND_DATE.CANONICAL_TO_DATE(CSR_HEADER_REC.pay_day);
					l_counter := l_counter + 1;

				gplsqltable(l_counter).TagName := 'END_DATE ';
				gplsqltable(l_counter).TagValue := FND_DATE.CANONICAL_TO_DATE(CSR_HEADER_REC.end_date);
					l_counter := l_counter + 1;


				gplsqltable(l_counter).TagName := 'HEADER_START';
				gplsqltable(l_counter).TagValue := 'HEADER_END';
					l_counter := l_counter + 1;

				gplsqltable(l_counter).TagName := 'BODY_START';
				gplsqltable(l_counter).TagValue := 'BODY_START';
				l_counter := l_counter + 1;

				l_sr_no:= 1;
     FOR payl_rep IN csr_payl_data (l_payroll_action_id)
--				FOR rg_ltfr_body_rpt IN csr_ltfr_body_rpt( l_payroll_action_id)
				LOOP

					gplsqltable(l_counter).TagName := 'EMP_START';
					gplsqltable(l_counter).TagValue := 'EMP_START';
					l_counter := l_counter + 1;


         gplsqltable (l_counter).tagname := 'PERSON_NAME';
         gplsqltable (l_counter).tagvalue := TO_CHAR (payl_rep.person_name);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'ASSIGNMENT_NUMBER';
         gplsqltable (l_counter).tagvalue := payl_rep.assignment_number;
         l_counter :=   l_counter
                      + 1;

         gplsqltable (l_counter).tagname := 'SALARY';
         gplsqltable (l_counter).tagvalue :=
         payl_rep.salary;
--         fnd_number.canonical_to_number(payl_rep.salary);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'BENEFITS';
         gplsqltable (l_counter).tagvalue :=
         payl_rep.benefits;
  --       fnd_number.canonical_to_number(payl_rep.benefits);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'INSURANCE_SALARY';
         gplsqltable (l_counter).tagvalue :=
          payl_rep.insurance_salary;
--         fnd_number.canonical_to_number(payl_rep.insurance_salary);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'DEDUCTIONS_WITHHOLD_TAX';
         gplsqltable (l_counter).tagvalue :=
          payl_rep.deductions_withhold_tax;
--         fnd_number.canonical_to_number(payl_rep.deductions_withhold_tax);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TAX_INCOME';
         gplsqltable (l_counter).tagvalue :=
            payl_rep.tax_income;
--         fnd_number.canonical_to_number(payl_rep.tax_income);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'CAPITAL_INCOME_BASE';
         gplsqltable (l_counter).tagvalue :=
             payl_rep.capital_income_base;
--         fnd_number.canonical_to_number(payl_rep.capital_income_base);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'WITHHOLD_TAX';
         gplsqltable (l_counter).tagvalue :=
             payl_rep.withhold_Tax;
--fnd_number.canonical_to_number(payl_rep.withhold_Tax);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'EXPENSES';
         gplsqltable (l_counter).tagvalue :=
             payl_rep.expenses;
--fnd_number.canonical_to_number(payl_rep.expenses);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'AFTER_TAX_DEDUCTIONS';
         gplsqltable (l_counter).tagvalue :=
             payl_rep.after_tax_deductions;
--fnd_number.canonical_to_number(payl_rep.after_tax_deductions);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'NET_PAY';
         gplsqltable (l_counter).tagvalue :=
             payl_rep.net_pay;
--fnd_number.canonical_to_number(payl_rep.net_pay);

         l_counter :=   l_counter
                      + 1;

					l_sr_no:= l_sr_no + 1;

					gplsqltable(l_counter).TagName := 'EMP_START';
					gplsqltable(l_counter).TagValue := 'EMP_END';
					l_counter := l_counter + 1;
fnd_file.put_line (
         fnd_file.LOG,
            'payl_rep.person_name '
         || payl_rep.person_name
      );
		END LOOP;

				gplsqltable(l_counter).TagName := 'BODY_START';
				gplsqltable(l_counter).TagValue := 'BODY_END';
				l_counter := l_counter + 1;

				gplsqltable(l_counter).TagName := 'FOOTER_START';
				gplsqltable(l_counter).TagValue := 'FOOTER_START';
				l_counter := l_counter + 1;

 fnd_file.put_line (
         fnd_file.LOG,
            'payroll_action_id ...TOTAL '
         || l_payroll_action_id
      );

		OPEN  csr_total( l_payroll_action_id);
		FETCH csr_total INTO csr_total_REC;
		CLOSE csr_total;

         gplsqltable (l_counter).tagname := 'SALARY';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.salary;
--         fnd_number.canonical_to_number(csr_total_REC.salary);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'BENEFITS';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.benefits;
--         fnd_number.canonical_to_number(csr_total_REC.benefits);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'INSURANCE_SALARY';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.insurance_salary;
--         fnd_number.canonical_to_number(csr_total_REC.insurance_salary);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'DEDUCTIONS_WITHHOLD_TAX';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.deductions_withhold_tax;
--         fnd_number.canonical_to_number(csr_total_REC.deductions_withhold_tax);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TAX_INCOME';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.tax_income;
--         fnd_number.canonical_to_number(csr_total_REC.tax_income);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'CAPITAL_INCOME_BASE';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.capital_income_base;
--         fnd_number.canonical_to_number(csr_total_REC.capital_income_base);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'WITHHOLD_TAX';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.withhold_Tax;
--fnd_number.canonical_to_number(csr_total_REC.withhold_Tax);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'EXPENSES';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.expenses;
--fnd_number.canonical_to_number(csr_total_REC.expenses);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'AFTER_TAX_DEDUCTIONS';
         gplsqltable (l_counter).tagvalue :=
             csr_total_REC.after_tax_deductions;
--fnd_number.canonical_to_number(csr_total_REC.after_tax_deductions);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'NET_PAY';
         gplsqltable (l_counter).tagvalue :=
              csr_total_REC.net_pay;
--fnd_number.canonical_to_number(csr_total_REC.net_pay);

         l_counter :=   l_counter
                      + 1;

				gplsqltable(l_counter).TagName := 'FOOTER_START';
				gplsqltable(l_counter).TagValue := 'FOOTER_END';
				l_counter := l_counter + 1;


      writetoclob (p_xml);
       --    fnd_file.put_line (      fnd_file.LOG,         'XML '       || p_xml   );
--      COMMIT;
   END get_data;


-----------------------------------------------------------------------------------------------------------------
PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB) is
l_xfdf_string clob;
l_str1 varchar2(1000);
l_str2 varchar2(20);
l_str3 varchar2(20);
l_str4 varchar2(20);
l_str5 varchar2(20);
l_str6 varchar2(30);
l_str7 varchar2(1000);
l_str8 varchar2(240);
l_str9 varchar2(240);
l_str10 varchar2(20);
l_str11 varchar2(20);

current_index pls_integer;
      l_IANA_charset VARCHAR2 (50);
BEGIN
 l_IANA_charset :=hr_fi_utility.get_IANA_charset ;
       hr_utility.set_location ('Entering WritetoCLOB ', 70);
       l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT><LTFR>';
       l_str2 := '<';
       l_str3 := '>';
       l_str4 := '</';
       l_str5 := '>';
        l_str6 := '</LTFR></ROOT>';
       l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
	l_str10 := '<LTFR>';
	l_str11 := '</LTFR>';


/*

hr_utility.set_location('Entering WritetoCLOB ',70);
	l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT><LTFR>' ;
	l_str2 := '<';
        l_str3 := '>';
        l_str4 := '</';
        l_str5 := '>';
        l_str6 := '</LTFR></ROOT>';
	l_str7 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT></ROOT>';
	l_str10 := '<LTFR>';
	l_str11 := '</LTFR>';
*/

	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

	current_index := 0;

              IF gplsqltable.count > 0 THEN

			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );


        		FOR table_counter IN gplsqltable.FIRST .. gplsqltable.LAST LOOP

        			l_str8 := gplsqltable(table_counter).TagName;
	        		l_str9 := gplsqltable(table_counter).TagValue;

                  		IF l_str9 IN ('HEADER_START' ,'HEADER_END','BODY_START',
				'BODY_END','EMP_START','EMP_END','FOOTER_START','FOOTER_END') THEN

						IF l_str9 IN ('HEADER_START' ,'BODY_START','EMP_START','FOOTER_START') THEN
						   dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
						   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
						   dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
						ELSE
						   dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
						   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
						   dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
						END IF;

				ELSE

					 if l_str9 is not null then

					   dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str9), l_str9);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
					 else

					   dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
					   dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);

					 end if;

				END IF;

			END LOOP;

			dbms_lob.writeAppend(l_xfdf_string, length(l_str6), l_str6 );

		ELSE
			dbms_lob.writeAppend(l_xfdf_string, length(l_str7), l_str7 );
		END IF;

		p_xfdf_clob := l_xfdf_string;

		hr_utility.set_location('Leaving WritetoCLOB ',40);

	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqlerrm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;


/*   PROCEDURE writetoclob (p_xfdf_clob OUT NOCOPY CLOB)
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
   BEGIN
      hr_utility.set_location ('Entering WritetoCLOB ', 70);
      l_str1 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT>';
      l_str2 := '<';
      l_str3 := '>';
      l_str4 := '</';
      l_str5 := '>';
      l_str6 := '</ROOT>';
      l_str7 := '<?xml version="1.0" encoding="UTF-8"?> <ROOT></ROOT>';
      l_str10 := '<PAYL>';
      l_str11 := '</PAYL>';
      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;

      IF gplsqltable.COUNT > 0
      THEN
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);
         l_str8 := gplsqltable (1).tagname;
         l_str9 := gplsqltable (1).tagvalue;
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);
         l_str8 := gplsqltable (2).tagname;
         l_str9 := gplsqltable (2).tagvalue;
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str2), l_str2);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str3), l_str3);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str9), l_str9);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str4), l_str4);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str8), l_str8);
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str5), l_str5);

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
      hr_utility.set_location ('Leaving WritetoCLOB ', 70);
      hr_utility.set_location ('Leaving WritetoCLOB ', 70);
--INSERT INTO CLOBTABLE VALUES(p_xfdf_clob,'PAYL');
--COMMIT;
   EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE (   'sqlerrm '
                           || SQLERRM);
         hr_utility.raise_error;
   END writetoclob;
   */
-------------------------------------------------------------------------------------------------------------------------
END PAY_FI_PAYLIST;

/
