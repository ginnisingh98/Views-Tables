--------------------------------------------------------
--  DDL for Package Body PAY_SE_TETR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_TETR" AS
/* $Header: pysetetr.pkb 120.0.12000000.1 2007/07/11 12:32:26 dbehera noship $ */
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

          	/* End of declaration*/

		/* Cursors */

		Cursor csr_tetr_header_rpt(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND	ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT DETAILS'
				AND  ACTION_INFORMATION1='PYSETETA';


			Cursor csr_tetr_ph_body(csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION1='PYSETETA'
				AND  ACTION_INFORMATION2=csr_v_pa_id
				AND  ACTION_INFORMATION11='PH'
				ORDER BY TO_DATE(action_information8) DESC;

			Cursor csr_tetr_ch_body(csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'AAP'
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION1='PYSETETA'
				AND  ACTION_INFORMATION2=csr_v_pa_id
				AND  ACTION_INFORMATION11='CH'
				ORDER BY TO_DATE(action_information8) DESC;


			Cursor csr_tetr_body_rpt(csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'AAP'
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION1='PYSETETA'
				AND  ACTION_INFORMATION2=csr_v_pa_id
				AND  ACTION_INFORMATION11='CS'
				ORDER BY action_information4,action_information6;


			Cursor csr_tetr_footer_rpt(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION1='PYSETETA'
				AND  ACTION_INFORMATION2='S';

				rg_tetr_footer_rpt  csr_tetr_footer_rpt%rowtype;


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


				OPEN  csr_tetr_footer_rpt( l_payroll_action_id);
				FETCH csr_tetr_footer_rpt INTO rg_tetr_footer_rpt;
				CLOSE csr_tetr_footer_rpt;


				FOR rg_tetr_header_rpt IN csr_tetr_header_rpt( l_payroll_action_id)
				LOOP

					gtagdata(l_counter).TagName := 'PERSON';
					gtagdata(l_counter).TagValue := 'PERSON';
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'EMPLOYEE_NUM';
					gtagdata(l_counter).TagValue :=  rg_tetr_header_rpt.action_information5;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'PERSON_NAME';
					gtagdata(l_counter).TagValue :=  rg_tetr_header_rpt.action_information3;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'PIN';
					gtagdata(l_counter).TagValue :=  rg_tetr_header_rpt.action_information4;
					l_counter := l_counter + 1;

					FOR rg_tetr_ph_body IN csr_tetr_ph_body( l_payroll_action_id)
					LOOP

					gtagdata(l_counter).TagName := 'PH';
					gtagdata(l_counter).TagValue := 'PH';
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'COMPANY_NAME';
					gtagdata(l_counter).TagValue :=  rg_tetr_ph_body.action_information5;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'START_DATE';
					gtagdata(l_counter).TagValue := rg_tetr_ph_body.action_information8;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'END_DATE';
					gtagdata(l_counter).TagValue := rg_tetr_ph_body.action_information9;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'DAYS_W';
					gtagdata(l_counter).TagValue := rg_tetr_ph_body.action_information10;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'PH';
					gtagdata(l_counter).TagValue := 'PH_END';
					l_counter := l_counter + 1;

						END LOOP;

					FOR rg_tetr_ch_body IN csr_tetr_ch_body( l_payroll_action_id)
					LOOP

					gtagdata(l_counter).TagName := 'CH';
					gtagdata(l_counter).TagValue := 'CH';
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'COMPANY_NAME';
					gtagdata(l_counter).TagValue :=  rg_tetr_ch_body.action_information5;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ASSIGN_CATEGORY';
					gtagdata(l_counter).TagValue := rg_tetr_ch_body.action_information7;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'START_DATE';
					gtagdata(l_counter).TagValue := rg_tetr_ch_body.action_information8;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'END_DATE';
					gtagdata(l_counter).TagValue := rg_tetr_ch_body.action_information9;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'DAYS_W';
					gtagdata(l_counter).TagValue := rg_tetr_ch_body.action_information10;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'CH';
					gtagdata(l_counter).TagValue := 'CH_END';
					l_counter := l_counter + 1;

						END LOOP;

					FOR rg_tetr_body_rpt IN csr_tetr_body_rpt( l_payroll_action_id)
					LOOP

					gtagdata(l_counter).TagName := 'BODY';
					gtagdata(l_counter).TagValue := 'BODY';
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'COMPANY_NAME';
					gtagdata(l_counter).TagValue :=  rg_tetr_body_rpt.action_information5;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ASSIGN_CATEGORY';
					gtagdata(l_counter).TagValue := rg_tetr_body_rpt.action_information7;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'DAYS_W';
					gtagdata(l_counter).TagValue := rg_tetr_body_rpt.action_information8;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'BODY';
					gtagdata(l_counter).TagValue := 'BODY_END';
					l_counter := l_counter + 1;


					END LOOP;


					gtagdata(l_counter).TagName := 'SUMMARY';
					gtagdata(l_counter).TagValue := 'SUMMARY';
					l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'TOT_YEARS';
					gtagdata(l_counter).TagValue := rg_tetr_footer_rpt.action_information3;
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'TOT_DAYS';
					gtagdata(l_counter).TagValue := rg_tetr_footer_rpt.action_information4;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'SUMMARY';
					gtagdata(l_counter).TagValue := 'SUMMARY_END';
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



                  		IF l_str9 IN ('PERSON' ,'PERSON_END','BODY',
				'BODY_END','PH','PH_END','CH','CH_END','SUMMARY','SUMMARY_END') THEN

						IF l_str9 IN ('PERSON' ,'BODY','PH','CH','SUMMARY') THEN
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

END PAY_SE_TETR;

/
