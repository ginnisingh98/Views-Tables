--------------------------------------------------------
--  DDL for Package Body PAY_FI_LTFR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_LTFR" AS
/* $Header: pyfiltfr.pkb 120.1.12000000.3 2007/03/20 05:41:23 dbehera noship $ */
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
			L_SALARY number;
			l_sr_no	 NUMBER ;

          	              	    			/* End of declaration*/

           	     					/* Cursors */
		Cursor csr_ltfr_header_rpt(csr_v_pa_id PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
			  	AND	ACTION_CONTEXT_ID =  csr_v_pa_id
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT DETAILS';

				rg_ltfr_header_rpt  csr_ltfr_header_rpt%rowtype;

			Cursor csr_ltfr_body_rpt(csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'AAP'
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND  ACTION_INFORMATION2='PER'
				AND  ACTION_INFORMATION10=csr_v_pa_id
				ORDER BY action_information4;

				rg_ltfr_body_rpt  csr_ltfr_body_rpt%rowtype;

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

				/* Pick up the details belonging to Header */

				OPEN  csr_ltfr_header_rpt( l_payroll_action_id);
					FETCH csr_ltfr_header_rpt INTO rg_ltfr_header_rpt;
				CLOSE csr_ltfr_header_rpt;

   			       hr_utility.set_location('Before populating pl/sql table',20);

				FOR rg_ltfr_body_rpt IN csr_ltfr_body_rpt( l_payroll_action_id)
				LOOP


				gtagdata(l_counter).TagName := 'PERSON';
				gtagdata(l_counter).TagValue := 'PERSON';
					l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'RECORD_TYPE_K';
				gtagdata(l_counter).TagValue := 'RECORD_TYPE_K';
					l_counter := l_counter + 1;


				gtagdata(l_counter).TagName := 'K_RECORD_NAME';
				gtagdata(l_counter).TagValue :=hr_general.decode_lookup('FI_FORM_LABELS','REC_K');
					l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'INS_POLICY_NUM';
				gtagdata(l_counter).TagValue :=  pay_fi_general.xml_parser(rg_ltfr_header_rpt.action_information2);
					l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'PIN';
				gtagdata(l_counter).TagValue := pay_fi_general.xml_parser(rg_ltfr_body_rpt.action_information5);
					l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'LOCAL_UNIT';
				gtagdata(l_counter).TagValue := rg_ltfr_header_rpt.action_information11;
					l_counter := l_counter + 1;

				gtagdata(l_counter).TagName :='EMPLOYEE_NAME';
				gtagdata(l_counter).TagValue := pay_fi_general.xml_parser(rg_ltfr_body_rpt.action_information4);
					l_counter := l_counter + 1;


				gtagdata(l_counter).TagName := 'RECORD_TYPE_K';
				gtagdata(l_counter).TagValue := 'RECORD_TYPE_K_END';
				l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'RECORD_TYPE_L';
					gtagdata(l_counter).TagValue := 'RECORD_TYPE_L';
					l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'L_RECORD_NAME';
					gtagdata(l_counter).TagValue :=hr_general.decode_lookup('FI_FORM_LABELS','REC_L');
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'ACTION_ID';
					gtagdata(l_counter).TagValue :=  '2';
						l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'TARGET_YEAR';
					gtagdata(l_counter).TagValue :=  rg_ltfr_header_rpt.action_information7;
						l_counter := l_counter + 1;


					l_salary:= FND_NUMBER.CANONICAL_TO_NUMBER(rg_ltfr_body_rpt.action_information7) +
						FND_NUMBER.CANONICAL_TO_NUMBER(rg_ltfr_body_rpt.action_information8) +
						FND_NUMBER.CANONICAL_TO_NUMBER(rg_ltfr_body_rpt.action_information9);

					gtagdata(l_counter).TagName := 'SALARY';
					gtagdata(l_counter).TagValue :=l_salary ;
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName := 'PAYMENT_MONTH';
					gtagdata(l_counter).TagValue :=  lpad(rg_ltfr_header_rpt.action_information6,2,'0');
						l_counter := l_counter + 1;


					gtagdata(l_counter).TagName :='REPORTING_METHOD';
					gtagdata(l_counter).TagValue := rg_ltfr_body_rpt.action_information6;
						l_counter := l_counter + 1;

					l_sr_no:= l_sr_no + 1;
					gtagdata(l_counter).TagName := 'RECORD_TYPE_L';
					gtagdata(l_counter).TagValue := 'RECORD_TYPE_L_END';
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
      l_IANA_charset :=hr_fi_utility.get_IANA_charset ;
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

                  		IF l_str9 IN ('PERSON' ,'PERSON_END','RECORD_TYPE_K',
				'RECORD_TYPE_K_END','RECORD_TYPE_L','RECORD_TYPE_L_END') THEN

						IF l_str9 IN ('PERSON' ,'RECORD_TYPE_K','RECORD_TYPE_L') THEN
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
-------------------------------------------------------------------------------------------------------------------------

END PAY_FI_LTFR;

/
