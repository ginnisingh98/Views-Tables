--------------------------------------------------------
--  DDL for Package Body PAY_SE_CWCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_CWCR" AS
/* $Header: pysecwcr.pkb 120.0.12010000.6 2010/01/29 12:16:20 vijranga ship $ */


  PROCEDURE get_digit_breakup(
      p_number IN NUMBER,
      p_digit1 OUT NOCOPY NUMBER,
      p_digit2 OUT NOCOPY NUMBER,
      p_digit3 OUT NOCOPY NUMBER,
      p_digit4 OUT NOCOPY NUMBER,
      p_digit5 OUT NOCOPY NUMBER,
      p_digit6 OUT NOCOPY NUMBER,
      p_digit7 OUT NOCOPY NUMBER,
      p_digit8 OUT NOCOPY NUMBER,
      p_digit9 OUT NOCOPY NUMBER,
      p_digit10 OUT NOCOPY NUMBER
   )
   IS

   TYPE digits IS
      TABLE OF NUMBER
      INDEX BY BINARY_INTEGER;
     l_digit digits;
     l_count NUMBER :=1;
     l_number number(10);
   BEGIN
   l_number:=floor(p_number);
   FOR I in 1..10 loop
    l_digit(I):=null;
   END loop;

   WHILE l_number >= 1  LOOP

	SELECT mod(l_number,10) INTO l_digit(l_count) from dual;
	l_number:=floor(l_number/10);
	l_count:=l_count+1;
   END LOOP;

   SELECT floor(l_number) INTO l_digit(l_number) from dual;
	p_digit1:=l_digit(1);
	p_digit2:=l_digit(2);
	p_digit3:=l_digit(3);
	p_digit4:=l_digit(4);
	p_digit5:=l_digit(5);
	p_digit6:=l_digit(6);
	p_digit7:=l_digit(7);
	p_digit8:=l_digit(8);
	p_digit9:=l_digit(9);
	p_digit10:=l_digit(10);
   END get_digit_breakup;



	PROCEDURE GET_DATA (
			      p_business_group_id		IN NUMBER,
			      p_payroll_action_id       	IN  VARCHAR2 ,
			      p_template_name			IN VARCHAR2,
			      p_xml 				OUT NOCOPY CLOB
			    )

           	    IS

           	/*  Start of declaration*/

           	-- Variables needed for the report
		l_counter	number := 0;
		l_payroll_action_id   PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE;
		l_digit1                 NUMBER(1);
		l_digit2                 NUMBER(1);
		l_digit3                 NUMBER(1);
		l_digit4                 NUMBER(1);
		l_digit5                 NUMBER(1);
		l_digit6                 NUMBER(1);
		l_digit7                 NUMBER(1);
		l_digit8                 NUMBER(1);
		l_digit9                 NUMBER(1);
		l_digit10                NUMBER(1);
		l_person_number          VARCHAR2(20);


          	/* End of declaration*/

		/* Cursors */

		Cursor csr_cwcr_header_rpt(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND	ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT DETAILS'
				AND  ACTION_INFORMATION1='PYSECWCA';


			Cursor csr_cwcr_b1(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE )
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND ACTION_CONTEXT_ID =  csr_v_pa_id
				AND  ACTION_INFORMATION1='PYSECWCA'
				AND  ACTION_INFORMATION2='CWC1';

				rg_cwcr_b1 csr_cwcr_b1%rowtype;

			Cursor csr_cwcr_b2(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE )
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND ACTION_CONTEXT_ID =  csr_v_pa_id
				AND  ACTION_INFORMATION1='PYSECWCA'
				AND  ACTION_INFORMATION2='CWC2'
				ORDER BY ACTION_INFORMATION10 asc , ACTION_INFORMATION3  asc ;

			Cursor csr_cwcr_b3(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE, csr_v_month NUMBER, csr_v_year NUMBER )
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND ACTION_CONTEXT_ID =  csr_v_pa_id
				AND  ACTION_INFORMATION1='PYSECWCA'
				AND  ACTION_INFORMATION2='CWC3'
				AND  ACTION_INFORMATION3  = csr_v_month
				AND  ACTION_INFORMATION10  = csr_v_year	;

			Cursor csr_cwcr_b4(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE, csr_v_month NUMBER, csr_v_year NUMBER )
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND ACTION_CONTEXT_ID =  csr_v_pa_id
				AND  ACTION_INFORMATION1='PYSECWCA'
				AND  ACTION_INFORMATION2='CWC4'
				AND  ACTION_INFORMATION3  = csr_v_month
				AND  ACTION_INFORMATION10  = csr_v_year	;

			Cursor csr_cwcr_b5(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE, csr_v_month NUMBER, csr_v_year NUMBER )
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND ACTION_CONTEXT_ID =  csr_v_pa_id
				AND  ACTION_INFORMATION1='PYSECWCA'
				AND  ACTION_INFORMATION2='CWC5'
				AND  ACTION_INFORMATION3  = csr_v_month
				AND  ACTION_INFORMATION10  = csr_v_year	;

			-- Bug# 9222739 fix starts
			Cursor csr_cwcr_b6(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE, csr_v_month NUMBER, csr_v_year NUMBER )
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND ACTION_CONTEXT_ID =  csr_v_pa_id
				AND  ACTION_INFORMATION1='PYSECWCA'
				AND  ACTION_INFORMATION2='CWC6'
				AND  ACTION_INFORMATION3  = csr_v_month
				AND  ACTION_INFORMATION10  = csr_v_year	;
			-- Bug# 9222739 fix ends

					     /* End of Cursors */

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

				hr_utility.set_location('Entered Procedure GETDATA',10);

				FOR rg_cwcr_header_rpt  IN csr_cwcr_header_rpt( l_payroll_action_id)
				LOOP


					OPEN  csr_cwcr_b1( l_payroll_action_id);
					FETCH csr_cwcr_b1 INTO rg_cwcr_b1;
					CLOSE csr_cwcr_b1;

					gtagdata(l_counter).TagName := 'PERSON';
					gtagdata(l_counter).TagValue := 'PERSON';
					l_counter := l_counter + 1;

--gtagdata(l_counter).TagName := 'EMP_NUM';
--gtagdata(l_counter).TagValue :=  rg_cwcr_b1.action_information3;
--l_counter := l_counter + 1;


l_person_number := replace(TO_CHAR(rg_cwcr_b1.action_information3),'-','');
---------------------------------------------------------------------------------------------------------------
--New Format of Person Number (of Ten Digits)
---------------------------------------------------------------------------------------------------------------
--add_tag_value ('PERSON_NUMBER', lr_wtc_person1.person_number);

	 get_digit_breakup(FND_NUMBER.CANONICAL_TO_NUMBER(l_person_number),l_digit1,l_digit2,l_digit3,l_digit4,l_digit5,l_digit6,l_digit7,l_digit8,l_digit9,l_digit10);
	 gtagdata (l_counter).tagname := 'PN1';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit1);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN2';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit2);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN3';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit3);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN4';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit4);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN5';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit5);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN6';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit6);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN7';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit7);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN8';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit8);
         l_counter :=   l_counter
                      + 1;
	 gtagdata (l_counter).tagname := 'PN9';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit9);
         l_counter :=   l_counter
                      + 1;
         gtagdata (l_counter).tagname := 'PN10';
         gtagdata (l_counter).tagvalue := TO_CHAR (l_digit10);
         l_counter :=   l_counter
                      + 1;
------------------------------------------------------------------------------------------------------------------




					gtagdata(l_counter).TagName := 'EMP_LNAME';
					gtagdata(l_counter).TagValue :=  rg_cwcr_b1.action_information4;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'EMP_FNAME';
					gtagdata(l_counter).TagValue :=  rg_cwcr_b1.action_information5;
					l_counter := l_counter + 1;

					FOR rg_cwcr_b2 IN csr_cwcr_b2( l_payroll_action_id)
					LOOP


					gtagdata(l_counter).TagName := 'B1';
					gtagdata(l_counter).TagValue := 'B1';
					l_counter := l_counter + 1;

				/*	gtagdata(l_counter).TagName := 'YR';
					gtagdata(l_counter).TagValue :=  rg_cwcr_b2.action_information10;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'MTH';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information3;
						l_counter := l_counter + 1;
				*/


				       gtagdata(l_counter).TagName := 'YRMTH';   -- EOY 2008
				       gtagdata(l_counter).TagValue :=  rg_cwcr_b2.action_information10||rg_cwcr_b2.action_information3;
				       l_counter := l_counter + 1;

				       gtagdata(l_counter).TagName := 'DAYS_WORKED';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information12;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'AH';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information9;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'AHW';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information4;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'OH';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information7;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'OHW';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information8;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'RDH';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information5;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'RDHW';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information6;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'RDMW';
					gtagdata(l_counter).TagValue := rg_cwcr_b2.action_information11;
						l_counter := l_counter + 1;


					-- Moving the Tags inside the loops Bug - 7605691
					-- gtagdata(l_counter).TagName := 'B2';
					-- gtagdata(l_counter).TagValue := 'B2';
					-- l_counter := l_counter + 1;

					FOR rg_cwcr_b3 IN csr_cwcr_b3( l_payroll_action_id, rg_cwcr_b2.action_information3, rg_cwcr_b2.action_information10  )
					LOOP

					gtagdata(l_counter).TagName := 'B2';
					gtagdata(l_counter).TagValue := 'B2';
					l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'OCK';
					gtagdata(l_counter).TagValue := rg_cwcr_b3.action_information4;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'OCA';
					gtagdata(l_counter).TagValue := rg_cwcr_b3.action_information5;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'B2';
					gtagdata(l_counter).TagValue := 'B2_END';
					l_counter := l_counter + 1;

					END LOOP;

					-- Moving the Tags inside the loops Bug - 7605691
					-- gtagdata(l_counter).TagName := 'B2';
					-- gtagdata(l_counter).TagValue := 'B2_END';
					-- l_counter := l_counter + 1;

					-- Moving the Tags inside the loops Bug - 7605691
					-- gtagdata(l_counter).TagName := 'B3';
					-- gtagdata(l_counter).TagValue := 'B3';
					-- l_counter := l_counter + 1;


					FOR rg_cwcr_b4 IN csr_cwcr_b4( l_payroll_action_id, rg_cwcr_b2.action_information3, rg_cwcr_b2.action_information10  )
					LOOP


					 gtagdata(l_counter).TagName := 'B3';
					 gtagdata(l_counter).TagValue := 'B3';
					 l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'OVK';
					gtagdata(l_counter).TagValue := rg_cwcr_b4.action_information4;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'OVA';
					gtagdata(l_counter).TagValue := rg_cwcr_b4.action_information5;
						l_counter := l_counter + 1;


					 gtagdata(l_counter).TagName := 'B3';
					 gtagdata(l_counter).TagValue := 'B3_END';
					 l_counter := l_counter + 1;



					END LOOP;

					-- Moving the Tags inside the loops Bug - 7605691
					-- gtagdata(l_counter).TagName := 'B3';
					-- gtagdata(l_counter).TagValue := 'B3_END';
					-- l_counter := l_counter + 1;

					-- Moving the Tags inside the loops Bug - 7605691
					--gtagdata(l_counter).TagName := 'B4';
					--gtagdata(l_counter).TagValue := 'B4';
					--l_counter := l_counter + 1;

					FOR rg_cwcr_b5 IN csr_cwcr_b5( l_payroll_action_id, rg_cwcr_b2.action_information3, rg_cwcr_b2.action_information10  )
					LOOP

					gtagdata(l_counter).TagName := 'B4';
					gtagdata(l_counter).TagValue := 'B4';
					l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'ADK';
					gtagdata(l_counter).TagValue := rg_cwcr_b5.action_information4;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ADA';
					gtagdata(l_counter).TagValue := rg_cwcr_b5.action_information5;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'B4';
					gtagdata(l_counter).TagValue := 'B4_END';
					l_counter := l_counter + 1;

					END LOOP;

					-- Moving the Tags inside the loops Bug -7605691
					--gtagdata(l_counter).TagName := 'B4';
					--gtagdata(l_counter).TagValue := 'B4_END';
					--l_counter := l_counter + 1;

					-- Bug# 9222739 fix starts
					FOR rg_cwcr_b6 IN csr_cwcr_b6( l_payroll_action_id, rg_cwcr_b2.action_information3, rg_cwcr_b2.action_information10  )
					LOOP

					gtagdata(l_counter).TagName := 'B5';
					gtagdata(l_counter).TagValue := 'B5';
					l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'SPH';
					gtagdata(l_counter).TagValue := rg_cwcr_b6.action_information4;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'SP';
					gtagdata(l_counter).TagValue := rg_cwcr_b6.action_information5;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'B5';
					gtagdata(l_counter).TagValue := 'B5_END';
					l_counter := l_counter + 1;

					END LOOP;
					-- Bug# 9222739 fix ends

					gtagdata(l_counter).TagName := 'B1';
					gtagdata(l_counter).TagValue := 'B1_END';
					l_counter := l_counter + 1;


					END LOOP;


					gtagdata(l_counter).TagName := 'EMP_NAME';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information6;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ORG_NUMBER';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information7;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'EMP_ADDR1';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information9;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'EMP_ADDR2';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information10;
					l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'EMP_ADDR3';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information11;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'TOWN_CITY';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information13;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'POSTAL_CODE';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information12;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'PHONE_NUMBER';
					gtagdata(l_counter).TagValue := rg_cwcr_b1.action_information17;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'PERSON';
					gtagdata(l_counter).TagValue := 'PERSON_END';
					l_counter := l_counter + 1;

				END LOOP;

				hr_utility.set_location('After populating pl/sql table',30);


					WritetoCLOB (p_xml );


	           	    END GET_DATA;

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
      l_IANA_charset :=hr_se_utility.get_IANA_charset ;
        hr_utility.set_location('Entering WritetoCLOB ',70);
        l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT>' ;
	l_str2 := '<';
        l_str3 := '>';
        l_str4 := '</';
        l_str5 := '>';
        l_str6 := '</ROOT>';
        l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';
	l_str10 := '<PERSON>';
	l_str11 := '</PERSON>';


	dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
	dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

	current_index := 0;

              IF gtagdata.count > 0 THEN

			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );


        		FOR table_counter IN gtagdata.FIRST .. gtagdata.LAST LOOP

        			l_str8 := gtagdata(table_counter).TagName;

                                l_str9 := gtagdata(table_counter).TagValue;



-- Bug# 9222739 fix starts
                  		IF l_str9 IN ('PERSON' ,'PERSON_END','B1',
				'B1_END','B2','B2_END','B3','B3_END','B4','B4_END','B5','B5_END') THEN

						IF l_str9 IN ('PERSON' ,'B1','B2','B3','B4','B5') THEN
-- Bug# 9222739 fix ends
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

					l_str9 := '<![CDATA[' || l_str9 || ']]>';

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
-------------------------------------------------------------------------------------------------------------------------

END PAY_SE_CWCR;

/
