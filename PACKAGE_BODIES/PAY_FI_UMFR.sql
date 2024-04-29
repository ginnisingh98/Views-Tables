--------------------------------------------------------
--  DDL for Package Body PAY_FI_UMFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_UMFR" AS
/* $Header: pyfiumfr.pkb 120.5 2007/06/20 05:38:54 psingla noship $ */
function get_archive_payroll_action_id(p_payroll_action_id in number)
return number
is
l_payroll_action_id number;
           	    BEGIN

				IF p_payroll_action_id  IS NULL THEN

				BEGIN

					SELECT payroll_action_id
					INTO  l_payroll_action_id
					FROM pay_payroll_actions ppa,
					fnd_conc_req_summary_v fcrs,
					fnd_conc_req_summary_v fcrs1
					WHERE  fcrs.request_id = FND_GLOBAL.CONC_REQUEST_ID
					AND fcrs.priority_request_id = fcrs1.priority_request_id
					AND ppa.request_id between fcrs1.request_id  and fcrs.request_id
					AND ppa.request_id = fcrs1.request_id;

				EXCEPTION
				WHEN others THEN
				NULL;
				END ;

				ELSE

					l_payroll_action_id  :=p_payroll_action_id;

				END IF;
return l_payroll_action_id;
end;
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

      cursor first_level(csr_v_pa_id IN VARCHAR2) is
      select ACTION_INFORMATION2 TRADE_UNION_NAME, ACTION_INFORMATION4 LEGAL_EMPLOYER_NAME
from pay_action_information pai where
    pai.action_information_category = 'EMEA REPORT DETAILS'
   AND pai.action_context_type = 'PA'
   AND PAI.ACTION_CONTEXT_ID=csr_v_pa_id;

first_level_rec first_level%rowtype;
cursor legal_header(csr_v_pa_id IN VARCHAR2) is
      select ACTION_INFORMATION2 TRADE_UNION_NAME, ACTION_INFORMATION4 LEGAL_EMPLOYER_NAME
from pay_action_information pai where
    pai.action_information_category = 'EMEA REPORT DETAILS'
   AND pai.action_context_type = 'PA'
   AND PAI.ACTION_CONTEXT_ID=csr_v_pa_id;
legal_header_rec legal_header%rowtype;


cursor local_header(csr_v_pa_id IN VARCHAR2) is
      select ACTION_INFORMATION2 TRADE_UNION_NAME, ACTION_INFORMATION4 LEGAL_EMPLOYER_NAME
from pay_action_information pai where
    pai.action_information_category = 'EMEA REPORT DETAILS'
   AND pai.action_context_type = 'PA'
   AND PAI.ACTION_CONTEXT_ID=csr_v_pa_id;
local_header_rec legal_header%rowtype;

      CURSOR csr_umfr_data (csr_v_pa_id IN VARCHAR2)
      IS
      SELECT pai.ACTION_INFORMATION2 TRADE_UNION_NAME, pai.ACTION_INFORMATION4 LEGAL_EMPLOYER_NAME,
null record_code ,
pai_le.action_information5 y_number,
       pai_lu.action_information5
             y_number_spare,
       pai_tu.action_information6 accounting_id, NULL accounting_id_spare,
       pai_tu.action_information5
             trade_union_number,
			 pai_lu.action_information4 local_unit_name,
       pai_lu.action_information6 local_unit_number,
       pai_per.action_information4
             employee_pin,
       pai_per.action_information5 employee_name,
       fnd_date.canonical_to_date(pai_per.action_information6)
             membership_start_date,
       fnd_date.canonical_to_date(pai_per.action_information7)
             membership_end_date, '1' currency,
       pai_per.action_information9
             SIGN, pai_per.action_information8 amount,
       '00' reason, to_char(fnd_date.canonical_to_date(pai.action_information9),'RRRR') tax_year, NULL sequence_number
  FROM pay_assignment_actions asgact, --                pay_payroll_actions payact,
      pay_action_information pai,
       pay_action_information pai_per,
       pay_action_information pai_lu,
       pay_action_information pai_le,
       pay_action_information pai_tu
 WHERE asgact.payroll_action_id = csr_v_pa_id
   AND pai_per.action_context_type = 'AAP'
   AND pai_per.action_information1 = 'PYFIUMFR'
   AND pai_per.action_information_category = 'EMEA REPORT INFORMATION'
   AND asgact.assignment_action_id = pai_per.action_context_id
   AND pai_lu.action_information3 = pai_per.action_information3
   AND pai_lu.action_information2 = 'LU'
   AND pai_lu.action_information1 = 'PYFIUMFR'
   AND pai_lu.action_information_category = 'EMEA REPORT INFORMATION'
   AND pai_lu.action_context_type = 'PA'
   AND pai_lu.action_context_id = csr_v_pa_id
   AND pai_le.action_information2 = 'LE'
   AND pai_le.action_information1 = 'PYFIUMFR'
   AND pai_le.action_information_category = 'EMEA REPORT INFORMATION'
   AND pai_le.action_context_type = 'PA'
   AND pai_le.action_context_id = csr_v_pa_id
   AND pai_tu.action_information2 = 'TU'
   AND pai_tu.action_information1 = 'PYFIUMFR'
   AND pai_tu.action_information_category = 'EMEA REPORT INFORMATION'
   AND pai_tu.action_context_type = 'PA'
   AND pai_tu.action_context_id = csr_v_pa_id
   and pai.action_information_category = 'EMEA REPORT DETAILS'
   AND pai.action_context_type = 'PA'
   AND PAI.ACTION_CONTEXT_ID=csr_v_pa_id
   order by pai.ACTION_INFORMATION2,pai.ACTION_INFORMATION4 ,pai_lu.action_information4  ;

      umfr_rep              csr_umfr_data%ROWTYPE;
L_TOTAL NUMBER :=0;
l_trade_union_name varchar2(2000):='XXX';
l_legal_employer_name varchar2(2000):= 'XXX';
l_local_unit_name varchar2(2000):= 'XXX';
L_LOCAL_TOTAL NUMBER :=0;
   BEGIN
      hr_utility.set_location ('Entered Procedure GETDATA', 10);


      fnd_file.put_line (
         fnd_file.LOG,       'payroll_action_id '||l_payroll_action_id
      );

l_payroll_action_id:=get_archive_payroll_action_id( p_payroll_action_id);

      fnd_file.put_line (
         fnd_file.LOG,       'payroll_action_id '||l_payroll_action_id
      );

      FOR umfr_rep IN csr_umfr_data (l_payroll_action_id)
      LOOP
         fnd_file.put_line (
         fnd_file.LOG,       'TRADE_UNION_NAME1 '||umfr_rep.trade_union_name
      );


if l_trade_union_name <> umfr_rep.trade_union_name THEN
l_trade_union_name:=umfr_rep.trade_union_name;
         gplsqltable (l_counter).tagname := 'TRADE_UNION_NAME';
         gplsqltable (l_counter).tagvalue := pay_fi_general.xml_parser(TO_CHAR (umfr_rep.trade_union_name));
      fnd_file.put_line (
         fnd_file.LOG,       'TRADE_UNION_NAME '||gplsqltable (l_counter).tagvalue
      );

         l_counter :=   l_counter
                      + 1;


         gplsqltable (l_counter).tagname := 'LEGAL_EMPLOYER_NAME';
         gplsqltable (l_counter).tagvalue := pay_fi_general.xml_parser(TO_CHAR (umfr_rep.legal_employer_name));

         l_counter :=   l_counter
                      + 1;
END IF;
if l_local_unit_name <> umfr_rep.local_unit_name THEN
        if l_local_unit_name <> 'XXX' then
                 gplsqltable (l_counter).tagname := 'LOCAL_TOTAL';
         gplsqltable (l_counter).tagvalue := TO_CHAR(L_LOCAL_TOTAL);
                  l_counter :=   l_counter
                      + 1;

            gplsqltable (l_counter).tagname := 'LU';
         gplsqltable (l_counter).tagvalue := 'END';

         l_counter :=   l_counter
                      + 1;
        end if;

        l_local_unit_name:=umfr_rep.local_unit_name;
         gplsqltable (l_counter).tagname := 'LU';
         gplsqltable (l_counter).tagvalue := 'START';

         l_counter :=   l_counter
                      + 1;

        L_LOCAL_TOTAL:=0;
         gplsqltable (l_counter).tagname := 'LOCAL_UNIT_NAME';
         gplsqltable (l_counter).tagvalue := pay_fi_general.xml_parser(TO_CHAR (umfr_rep.local_unit_name));

         l_counter :=   l_counter
                      + 1;
end if;
         gplsqltable (l_counter).tagname := 'START';
         gplsqltable (l_counter).tagvalue := 'START';

         l_counter :=   l_counter
                      + 1;

         gplsqltable (l_counter).tagname := 'RECORD_CODE';
         gplsqltable (l_counter).tagvalue :=
                                       TO_CHAR (umfr_rep.record_code);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Y_NUMBER';
         gplsqltable (l_counter).tagvalue :=
                                       TO_CHAR (umfr_rep.y_number);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'Y_NUMBER_SPARE';
         gplsqltable (l_counter).tagvalue :=
                                       TO_CHAR (umfr_rep.y_number_spare);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'ACCOUNTING_ID';
         gplsqltable (l_counter).tagvalue :=
                                    TO_CHAR (umfr_rep.accounting_id);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'ACCOUNTING_ID_SPARE';
         gplsqltable (l_counter).tagvalue :=
          TO_CHAR (umfr_rep.accounting_id_spare);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TRADE_UNION_NUMBER';
         gplsqltable (l_counter).tagvalue :=
                                      TO_CHAR (umfr_rep.trade_union_number);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'LOCAL_UNIT_NUMBER';
         gplsqltable (l_counter).tagvalue :=
                                      TO_CHAR (umfr_rep.local_unit_number);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'EMPLOYEE_PIN';
         gplsqltable (l_counter).tagvalue :=
                                      TO_CHAR (umfr_rep.employee_pin);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'EMPLOYEE_NAME';
         gplsqltable (l_counter).tagvalue :=
                                pay_fi_general.xml_parser( TO_CHAR (umfr_rep.employee_name));
         l_counter :=   l_counter
                      + 1;

/* Add the fields from Membership start date to Tax_year */

         gplsqltable (l_counter).tagname := 'MEMBERSHIP_START';
         gplsqltable (l_counter).tagvalue :=
                                      umfr_rep.membership_start_date;
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'MEMBERSHIP_END';
         gplsqltable (l_counter).tagvalue :=
                                      umfr_rep.membership_end_date;
         l_counter :=   l_counter
                      + 1;


         gplsqltable (l_counter).tagname := 'MEMBERSHIP_START_PDF';
         gplsqltable (l_counter).tagvalue :=
                                      to_char(umfr_rep.membership_start_date,'DD-MON-YYYY');
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'MEMBERSHIP_END_PDF';
         gplsqltable (l_counter).tagvalue :=
                                      to_char(umfr_rep.membership_end_date,'DD-MON-YYYY');
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'CURRENCY';
         gplsqltable (l_counter).tagvalue := TO_CHAR (umfr_rep.currency);
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'SIGN';
         gplsqltable (l_counter).tagvalue := TO_CHAR (umfr_rep.SIGN);
         l_counter :=   l_counter
                      + 1;

         gplsqltable (l_counter).tagname := 'AMOUNT';
         gplsqltable (l_counter).tagvalue :=
                                      fnd_number.canonical_to_number(umfr_rep.amount);
  l_local_total:=    l_local_total+fnd_number.canonical_to_number(umfr_rep.amount);
  l_total:=l_total+       fnd_number.canonical_to_number(umfr_rep.amount);


                l_counter :=   l_counter
                      + 1;


         gplsqltable (l_counter).tagname := 'REASON';
         gplsqltable (l_counter).tagvalue :=         pay_fi_general.xml_parser(TO_CHAR (umfr_rep.reason));
         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'TAX_YEAR';
         gplsqltable (l_counter).tagvalue := to_char(umfr_rep.tax_year);

         l_counter :=   l_counter
                      + 1;
         gplsqltable (l_counter).tagname := 'END';
         gplsqltable (l_counter).tagvalue := 'END';

         l_counter :=   l_counter
                      + 1;



      END LOOP;
               gplsqltable (l_counter).tagname := 'LOCAL_TOTAL';
         gplsqltable (l_counter).tagvalue := L_LOCAL_TOTAL;
--         TO_CHAR(NVL(L_LOCAL_TOTAL,0) ,'999G999G990D99' );
--         TO_CHAR(NVL(FND_NUMBER.canonical_to_number (L_LOCAL_TOTAL),0) ,'999G999G990D99' );

                  l_counter :=   l_counter
                      + 1;

         gplsqltable (l_counter).tagname := 'TOTAL';
         gplsqltable (l_counter).tagvalue := L_TOTAL;
-- TO_CHAR(NVL(L_TOTAL,0) ,'999G999G990D99' );
--             TO_CHAR(NVL(FND_NUMBER.canonical_to_number(L_TOTAL),0) ,'999G999G990D99' );

      writetoclob (p_xml);
    --  fnd_file.put_line (      fnd_file.LOG,             p_xml   );




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
      l_total_start         VARCHAR2 (20);
      l_total_end   VARCHAR2 (20);
      l_strlustart         VARCHAR2 (20);
      l_strluend   VARCHAR2 (20);

      current_index   PLS_INTEGER;
      L_COUNTER PLS_INTEGER;
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
      l_str10 := '<UFMR>';
      l_str11 := '</UFMR>';
      l_total_start := '<TOTAL>';
      l_total_end := '</TOTAL>';
      l_strlustart := '<LU>';
      l_strluend := '</LU>';


      DBMS_LOB.createtemporary (l_xfdf_string, FALSE, DBMS_LOB.CALL);
      DBMS_LOB.OPEN (l_xfdf_string, DBMS_LOB.lob_readwrite);
      current_index := 0;

      IF gplsqltable.COUNT > 0
      THEN

         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_str1), l_str1);
/*            l_str8 := gplsqltable (1).tagname;
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
*/

    fnd_file.put_line (      fnd_file.LOG,           gplsqltable.COUNT  );

         FOR table_counter IN gplsqltable.FIRST .. gplsqltable.LAST

         LOOP
    fnd_file.put_line (      fnd_file.LOG,             l_xfdf_string   );
            l_str8 := gplsqltable (table_counter).tagname;
            l_str9 := gplsqltable (table_counter).tagvalue;
            IF l_str8 = 'END'            THEN
             fnd_file.put_line (      fnd_file.LOG,          l_xfdf_string   );
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_str11),
                  l_str11
               );
                  fnd_file.put_line (      fnd_file.LOG,             l_xfdf_string   );
            ELSIF l_str8 = 'LU'             THEN
             fnd_file.put_line (      fnd_file.LOG,             l_xfdf_string   );
                IF l_str9 ='START' THEN
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_strlustart),            l_strlustart        );
                ELSIF l_str9 ='END' THEN
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_strluend),            l_strluend        );
                END IF;

            ELSIF l_str8 = 'TOTAL'             THEN


           IF gplsqltable.COUNT > 3 then
                                  DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_strluend),            l_strluend        );


           end if;

    fnd_file.put_line (      fnd_file.LOG,             l_xfdf_string   );
         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_total_start), l_total_start);
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_str9),
                  l_str9
               );

         DBMS_LOB.writeappend (l_xfdf_string, LENGTH (l_total_end), l_total_end);


            ELSIF l_str8 = 'START'             THEN
               DBMS_LOB.writeappend (
                  l_xfdf_string,
                  LENGTH (l_str10),            l_str10        );
            ELSIF l_str9 IS NOT NULL            THEN

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
  /* EXCEPTION
      WHEN OTHERS
      THEN
         hr_utility.TRACE (   'sqlerrm '
                           || SQLERRM);
         hr_utility.raise_error;*/
   END writetoclob;
-------------------------------------------------------------------------------------------------------------------------
END PAY_FI_UMFR;

/
