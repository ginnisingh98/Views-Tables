--------------------------------------------------------
--  DDL for Package Body PAY_FI_TELR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_TELR" AS
/* $Header: pyfitelr.pkb 120.12.12000000.4 2007/03/22 12:55:01 dbehera noship $ */

	PROCEDURE GET_DATA (
			      p_business_group_id	IN NUMBER,
			      p_payroll_action_id  	IN VARCHAR2 ,
			      p_test_run             IN VARCHAR2,
			      p_template_name		IN VARCHAR2,
			      p_xml 				OUT NOCOPY CLOB
			    )
           	    IS

           	    					/*  Start of declaration*/

           	    -- Variables needed for the report
			l_counter	number := 0;
			l_payroll_action_id   PAY_ACTION_INFORMATION.ACTION_INFORMATION1%TYPE;

            L_TARGET_YEAR VARCHAR2(4);
            l_TEL_Action_id varchar2(30);

            l_EIT_PG_Action_Type per_people_extra_info.pei_information6%TYPE;
            l_SHIFT_FROM_TEL DATE;
            l_EIT_PT_value per_people_extra_info.pei_information6%TYPE;
            l_EIT_PT_Reported per_people_extra_info.pei_information5%TYPE;
            l_EIT_PG_Reported per_people_extra_info.pei_information5%TYPE;


            l_EIT_Action_Type per_people_extra_info.pei_information6%TYPE;
            l_EIT_IsReported  per_people_extra_info.pei_information5%TYPE;
            L_LEL_EMPLOYMENT_START_DATE DATE;

            l_TIME_RECORD_1 boolean :=false;
            l_TIME_RECORD_2 boolean :=false;
            l_TIME_RECORD_5 boolean :=false;


            L_OVN per_people_extra_info.object_version_number%TYPE;
            /* End of declaration*/
            /* Cursors */

			Cursor csr_TEL_PERSON_DETAILS(
						csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE
										)
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'AAP'
			  	AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND ACTION_INFORMATION2='PER'
				AND ACTION_INFORMATION1='PYFITELA'
				AND	ACTION_INFORMATION3 =  csr_v_pa_id
				ORDER BY action_information8;

				--lr_TEL_PERSON_DETAILS  csr_TEL_PERSON_DETAILS%rowtype;

			Cursor csr_TEL_PER1_DETAILS(
						csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE
						,CSR_V_PERSON_ID per_all_people_f.person_id%TYPE
										)
			IS
				SELECT	   ACTION_INFORMATION4 FIRST_CODE,
        decode(ACTION_INFORMATION6,null,
        (to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION5),'DDMMYY'))
        ,(to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION5),'DDMMYY'))||
        (to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION6),'DDMMYY')) ) FIRSTDATEPAIR,
         ACTION_INFORMATION7 SECOND_CODE,
        decode(ACTION_INFORMATION9,null,
        (to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION8),'DDMMYY'))
        ,(to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION8),'DDMMYY'))||
        (to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION9),'DDMMYY')) ) SECONDDATEPAIR,
         ACTION_INFORMATION10 THIRD_CODE,
                                            decode(ACTION_INFORMATION12,null,
        (to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION11),'DDMMYY'))
        ,(to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION11),'DDMMYY'))||
        (to_CHAR(fnd_date.canonical_to_date(ACTION_INFORMATION12),'DDMMYY')) ) THIRDDATEPAIR
                           , PAI.*
				FROM	PAY_ACTION_INFORMATION PAI
			  	WHERE	 ACTION_CONTEXT_TYPE = 'AAP'
			  	AND ACTION_INFORMATION_CATEGORY='EMEA REPORT INFORMATION'
				AND ACTION_INFORMATION2='PER1'
				AND ACTION_INFORMATION1='PYFITELA'
				AND	ACTION_INFORMATION3 =  csr_v_pa_id
				AND	ACTION_INFORMATION30 =  CSR_V_PERSON_ID
				ORDER BY action_information5 desc;

				lr_TEL_PER1_DETAILS  csr_TEL_PER1_DETAILS%rowtype;

			Cursor CSR_REPORT_DETAILS(
                    csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE
                                    )
			IS
				SELECT	  *
				FROM	PAY_ACTION_INFORMATION
			  	WHERE	 ACTION_CONTEXT_TYPE = 'PA'
				AND ACTION_INFORMATION_CATEGORY='EMEA REPORT DETAILS'
				AND  ACTION_INFORMATION1='PYFITELA'
				AND  ACTION_CONTEXT_ID=csr_v_pa_id ;

				LR_REPORT_DETAILS  CSR_REPORT_DETAILS%rowtype;

        CURSOR CSR_EIT_DETAILS (
                csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE,
                CSR_V_PERSON_ID per_all_people_f.person_id%TYPE,
                CSR_V_COLUMN_NAME per_people_extra_info.PEI_INFORMATION3%TYPE )
        IS
            	SELECT *
            	FROM   PAY_ACTION_INFORMATION
            	WHERE  ACTION_CONTEXT_TYPE = 'AAP'
            	AND    ACTION_INFORMATION_CATEGORY ='EMEA REPORT INFORMATION'
            	AND    ACTION_INFORMATION1 ='PYFITELA'
            	AND    ACTION_INFORMATION2 ='PERSON_EIT'
                AND	   ACTION_INFORMATION3 =  csr_v_pa_id
                AND    ACTION_INFORMATION6 = CSR_V_COLUMN_NAME
                AND    ACTION_INFORMATION30 = CSR_V_PERSON_ID;

        LR_EIT_DETAILS CSR_EIT_DETAILS%ROWTYPE;

            CURSOR CSR_PERSON_EIT (
             CSR_V_PERSON_ID per_all_people_f.person_id%TYPE,
             CSR_V_COLUMN_NAME per_people_extra_info.PEI_INFORMATION3%TYPE
             )
            IS
            select PERSON_EXTRA_INFO_ID,
                    object_version_number,
                    person_id,
                    information_type,
                    pei_information_category,
                    pei_information1,
                    pei_information2,
                    pei_information3,
                    pei_information4,
                    pei_information5,
                    pei_information6,
                    pei_information7
             from per_people_extra_info
            where information_type='FI_PENSION'
            AND PEI_INFORMATION_CATEGORY='FI_PENSION'
            AND PEI_INFORMATION3=CSR_V_COLUMN_NAME
            AND PERSON_ID = CSR_V_PERSON_ID;

            LR_PERSON_EIT CSR_PERSON_EIT%ROWTYPE;

-- for searching record 2 type
        CURSOR CSR_RECORD_TWO_TYPE (
                csr_v_pa_id PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE,
                CSR_V_PERSON_ID per_all_people_f.person_id%TYPE
         )IS
         SELECT	DISTINCT(ACTION_INFORMATION3) "FOUND"
            FROM	PAY_ACTION_INFORMATION pai
              	WHERE pai.ACTION_CONTEXT_TYPE = 'AAP'
              	AND pai.ACTION_INFORMATION_CATEGORY  ='EMEA REPORT INFORMATION'
            	AND pai.ACTION_INFORMATION2          ='PERSON_EIT'
            	AND pai.ACTION_INFORMATION1          ='PYFITELA'
            	AND	pai.ACTION_INFORMATION3          = csr_v_pa_id
        		AND	pai.ACTION_INFORMATION30         = CSR_V_PERSON_ID
            	AND	pai.ACTION_INFORMATION8          ='N'
        		AND pai.ACTION_INFORMATION9 = 	decode (pai.ACTION_INFORMATION6,
            						  	'Pension Joining Date','I',
            							'Local Unit','U',
            							'Pension Group','U',
								'Insurance Number','U')	;

        LR_RECORD_TWO_TYPE CSR_RECORD_TWO_TYPE%ROWTYPE;

         l_Record_two_type_found BOOLEAN := false;

				           	     /* End of Cursors */

    BEGIN
            --fnd_file.put_line(fnd_file.log,'=======================' );
            --fnd_file.put_line(fnd_file.log,'== p_payroll_action_id  ==' || p_payroll_action_id);
            --fnd_file.put_line(fnd_file.log,'=======================' );


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
				OPEN  CSR_REPORT_DETAILS( l_payroll_action_id);
					FETCH CSR_REPORT_DETAILS INTO LR_REPORT_DETAILS;
				CLOSE CSR_REPORT_DETAILS;



   			       hr_utility.set_location('Before populating pl/sql table',20);
            FOR lr_TEL_PERSON_DETAILS IN csr_TEL_PERSON_DETAILS( l_payroll_action_id)
			LOOP
			            l_TIME_RECORD_1  :=false;
            			l_TIME_RECORD_2  :=false;
            			l_TIME_RECORD_5  :=false;
			     l_Record_two_type_found := false;
            --fnd_file.put_line(fnd_file.log,'== person  ==' || lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30);
				OPEN  CSR_RECORD_TWO_TYPE( l_payroll_action_id,
                                            lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30);
				FETCH CSR_RECORD_TWO_TYPE
				INTO LR_RECORD_TWO_TYPE;

		         IF CSR_RECORD_TWO_TYPE%NOTFOUND
        		 THEN
                		    -- Not found ; search for other type
							--fnd_file.put_line(fnd_file.log,'== first falied null ==');

                        		IF LR_REPORT_DETAILS.ACTION_INFORMATION8 ='A'
                        		THEN
	    				        	l_Record_two_type_found := TRUE;
    	                    	ELSE
    					        	l_Record_two_type_found := false;
                        		END IF;

                ELSE
                    		-- Found the record two type
                    		-- so set this variable to true  exit this if
							--fnd_file.put_line(fnd_file.log,'== first Passed ==');
                    		l_Record_two_type_found := true;
                		END IF;
				CLOSE CSR_RECORD_TWO_TYPE;

            IF l_Record_two_type_found = TRUE
            THEN
                TEL_DATA(l_counter).TagName := 'PERSON';
                TEL_DATA(l_counter).TagValue := 'PERSON';
                  	l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'EMP_RECORD';
				TEL_DATA(l_counter).TagValue := 'EMP_RECORD';
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'RECORD_ONE';
				TEL_DATA(l_counter).TagValue :=hr_general.decode_lookup('FI_FORM_LABELS','REC_A');
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'INSURANCE_POLICY_NUMBER';
				TEL_DATA(l_counter).TagValue :=lr_TEL_PERSON_DETAILS.ACTION_INFORMATION4;
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'PIN';
				TEL_DATA(l_counter).TagValue :=  lr_TEL_PERSON_DETAILS.ACTION_INFORMATION5;
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'PENSION_GROUP';
				TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION6;
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'DEPARTMENT';
				TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION7;
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName :='SUR_FIRST_NAME';
				TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION8;
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'EMP_RECORD';
				TEL_DATA(l_counter).TagValue := 'EMP_RECORD_END';
					l_counter := l_counter + 1;

				TEL_DATA(l_counter).TagName := 'TIME_RECORD';
				TEL_DATA(l_counter).TagValue := 'TIME_RECORD';
					l_counter := l_counter + 1;

            --fnd_file.put_line(fnd_file.log,'Added  TIME_RECORD Start==> ' );
            --fnd_file.put_line(fnd_file.log,'Record One displayed ' );
            --fnd_file.put_line(fnd_file.log,'INSURANCE_POLICY_NUMBER' ||' '||'PIN         ' ||' '||
            --'PENSION_GROUP' ||' '||'DEPARTMENT' ||' '||'SUR_FIRST_NAME     ');
            --fnd_file.put_line(fnd_file.log,
            --rpad(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION4,length('INSURANCE_POLICY_NUMBER')) ||'  '||
            --rpad(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION5,12) ||'  '||
            --rpad(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION20,length('PENSION_GROUP')) ||'  '||
            --rpad(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION7,length('DEPARTMENT')) ||'  '||
            --rpad(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION8,20)
            --);

		-- Pick up the person Reocrd 1 Also
                OPEN  csr_TEL_PER1_DETAILS( l_payroll_action_id,
                                            lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30);
					FETCH csr_TEL_PER1_DETAILS
                    INTO lr_TEL_PER1_DETAILS;
				CLOSE csr_TEL_PER1_DETAILS;
		-- Pick up the person Reocrd 1 Also
            -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
            -- TO find the Employment start dispatch
            --fnd_file.put_line(fnd_file.log,'=========================' );


            --fnd_file.put_line(fnd_file.log,'=========================Employment start dispatch=========================' );

                OPEN  CSR_EIT_DETAILS(l_payroll_action_id,lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Pension Joining Date');
                    FETCH CSR_EIT_DETAILS
                    INTO LR_EIT_DETAILS;
                CLOSE CSR_EIT_DETAILS;
            /*
                OPEN  CSR_PERSON_EIT(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Pension Joining Date');
                    FETCH CSR_PERSON_EIT
                    INTO LR_PERSON_EIT;
                CLOSE CSR_PERSON_EIT;
            */
            l_EIT_Action_Type := LR_EIT_DETAILS.ACTION_INFORMATION9;
            l_EIT_IsReported  := LR_EIT_DETAILS.ACTION_INFORMATION8;

            --fnd_file.put_line(fnd_file.log,'l_EIT_Action_Type for PJD      ==> '||l_EIT_Action_Type );
            --fnd_file.put_line(fnd_file.log,'l_EIT_IsReported PJD           ==> '||l_EIT_IsReported );



            IF l_EIT_Action_Type ='I' AND l_EIT_IsReported ='N'
            THEN
                    l_TEL_Action_id := '1';
                    l_TIME_RECORD_1 := true;

                    --fnd_file.put_line(fnd_file.log,'l_TEL_Action_id                ==> '||l_TEL_Action_id );

                    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                    --fnd_file.put_line(fnd_file.log,'Adding  Record 2 for Action 1  ==> '||l_TEL_Action_id );

                    TEL_DATA(l_counter).TagName := 'TIME_RECORD_TYPE';
                    TEL_DATA(l_counter).TagValue := 'TIME_RECORD_TYPE';
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'RECORD_TWO';
                    TEL_DATA(l_counter).TagValue := hr_general.decode_lookup('FI_FORM_LABELS','REC_B');
                    l_counter := l_counter + 1;

                    -- Find the Action Id here
                    TEL_DATA(l_counter).TagName := 'ACTION_ID';
                    TEL_DATA(l_counter).TagValue := '1';
                    l_counter := l_counter + 1;
                    -- Find the Action Id here

                    TEL_DATA(l_counter).TagName := 'START_DATE';
                    TEL_DATA(l_counter).TagValue := fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9);
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'START_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := to_char(fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9),'DDMMYY');
                    l_counter := l_counter + 1;

                    -- This Target year has to be included in case of only ACTION ID 2
                    -- Find if from g_effective date of Report prameters
                    --IF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'Y'
                    --THEN
                     --   L_TARGET_YEAR := to_char(fnd_date.canonical_to_date(LR_REPORT_DETAILS.ACTION_INFORMATION8),'RRRR');
                    --ELSE
                        L_TARGET_YEAR := null;
                   -- END IF;

                    TEL_DATA(l_counter).TagName := 'TARGET_YEAR_FOR_ANNUAL_INCOME';
                    TEL_DATA(l_counter).TagValue := L_TARGET_YEAR;
                    l_counter := l_counter + 1;

                    -- Find if from g_effective date of Report prameters

                    -- Find it from Balance values from 11 to 16
                    TEL_DATA(l_counter).TagName := 'INCOME';
                    IF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'M'
                    THEN
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION10) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION11) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION12),0) ,'999G999G990D99' );
                    ELSIF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'A'
                    THEN
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION13) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION14) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION15) ,0) ,'999G999G990D99' );
                    ELSIF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'Q'
                    THEN
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PER1_DETAILS.ACTION_INFORMATION13) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PER1_DETAILS.ACTION_INFORMATION14) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PER1_DETAILS.ACTION_INFORMATION15) ,0) ,'999G999G990D99' );
                    END IF;

                    l_counter := l_counter + 1;
                    -- Find it from Balance values
/*
                    TEL_DATA(l_counter).TagName := 'BENEFIT_IN_KIND';
                    TEL_DATA(l_counter).TagValue := null;
                    l_counter := l_counter + 1;
*/

                    TEL_DATA(l_counter).TagName := 'TERMINATION_DATE';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --	TEL_DATA(l_counter).TagValue :=lr_TEL_PERSON_DETAILS.ACTION_INFORMATION8;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'TERMINATION_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := NULL;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'CAUSE_OF_TERMINATION';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --	TEL_DATA(l_counter).TagValue :=  fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9);
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'YEARLY_TEL_INCOME_PRIOR';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --TEL_DATA(l_counter).TagValue := to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION18) + to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION19);
                    l_counter := l_counter + 1;

/*
                    TEL_DATA(l_counter).TagName := 'BENEFIT_IN_KIND_PRIOR';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --TEL_DATA(l_counter).TagValue := to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION20);
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName :='LEL_EMPLOYMENT_START_DATE';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --TEL_DATA(l_counter).TagValue :=  fnd_date.canonical_to_date( lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9 );
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName :='LEL_EMPLOYMENT_START_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --TEL_DATA(l_counter).TagValue :=  fnd_date.canonical_to_date( lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9 );
                    l_counter := l_counter + 1;

                    -- find it If there is change in  Pension Group report the date of starting new record from EIT

                    TEL_DATA(l_counter).TagName := 'SHIFT_FRM_ANOTHER_TEL_EMP';
                    TEL_DATA(l_counter).TagValue :=  null;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'SHIFT_FRM_ANOTHER_TEL_EMP_DDMMYY';
                    TEL_DATA(l_counter).TagValue :=  null;
                    l_counter := l_counter + 1;

                    -- find it If there is change in  Pension Group report the date of starting new record from EIT
                    TEL_DATA(l_counter).TagName := 'CURRENCY';
                    TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION25;
                    l_counter := l_counter + 1;

		    */


                    TEL_DATA(l_counter).TagName := 'REPORTING_METHOD';
                    TEL_DATA(l_counter).TagValue := to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION29);
                    l_counter := l_counter + 1;


                    TEL_DATA(l_counter).TagName := 'TIME_RECORD_TYPE';
                    TEL_DATA(l_counter).TagValue := 'TIME_RECORD_TYPE_END';
                    l_counter := l_counter + 1;

            END IF; -- For the Action ID = '1'  IF

            --fnd_file.put_line(fnd_file.log,'=========================END===============================================' );
            --fnd_file.put_line(fnd_file.log,'=========================Annual Report=====================================' );
            -- Annual Report
            --fnd_file.put_line(fnd_file.log,'annual_report ???             ==> '||LR_REPORT_DETAILS.ACTION_INFORMATION8 );

            IF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'A'
            THEN
                    l_TEL_Action_id := '2';
                    l_TIME_RECORD_2 := true;
                    --fnd_file.put_line(fnd_file.log,'l_TEL_Action_id                ==> '||l_TEL_Action_id );

                    --fnd_file.put_line(fnd_file.log,'Adding  Record 2 for Action 2  ==> '||l_TEL_Action_id );

                    TEL_DATA(l_counter).TagName := 'TIME_RECORD_TYPE';
                    TEL_DATA(l_counter).TagValue := 'TIME_RECORD_TYPE';
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'RECORD_TWO';
                    TEL_DATA(l_counter).TagValue := hr_general.decode_lookup('FI_FORM_LABELS','REC_B');
                    l_counter := l_counter + 1;

                    -- Find the Action Id here
                    TEL_DATA(l_counter).TagName := 'ACTION_ID';
                    TEL_DATA(l_counter).TagValue := '2';
                    l_counter := l_counter + 1;
                    -- Find the Action Id here

                    TEL_DATA(l_counter).TagName := 'START_DATE';
                    TEL_DATA(l_counter).TagValue := fnd_date.canonical_to_date( lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9 );
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'START_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(fnd_date.canonical_to_date( lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9 ),'DDMMYY');
                    l_counter := l_counter + 1;

                    -- Find if from g_effective date of Report prameters

                    L_TARGET_YEAR := to_char(fnd_date.canonical_to_date(LR_REPORT_DETAILS.ACTION_INFORMATION9),'RRRR');

                    TEL_DATA(l_counter).TagName := 'TARGET_YEAR_FOR_ANNUAL_INCOME';
                    TEL_DATA(l_counter).TagValue := L_TARGET_YEAR;
                    l_counter := l_counter + 1;

                    -- Find if from g_effective date of Report prameters

                    -- Find it from Balance values from 11 to 16
                    TEL_DATA(l_counter).TagName := 'INCOME';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION13) +
                                                    FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION14) +
                                                    FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION15) ,0) ,'999G999G990D99' );
                    l_counter := l_counter + 1;

/*		    -- Find it from Balance values
                    -- In case of Annual Report or Start and Termination we need to report this field
                    TEL_DATA(l_counter).TagName := 'BENEFIT_IN_KIND';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION14) ,0) ,'999G999G990D99' );
                    l_counter := l_counter + 1;
*/

                    TEL_DATA(l_counter).TagName := 'TERMINATION_DATE';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --	TEL_DATA(l_counter).TagValue :=fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION8);
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'TERMINATION_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := NULL;
                    l_counter := l_counter + 1;


                    TEL_DATA(l_counter).TagName := 'CAUSE_OF_TERMINATION';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --TEL_DATA(l_counter).TagValue :=  lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'YEARLY_TEL_INCOME_PRIOR';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --TEL_DATA(l_counter).TagValue := to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION18 ) + to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION19 );
                    l_counter := l_counter + 1;

/*
                    TEL_DATA(l_counter).TagName := 'BENEFIT_IN_KIND_PRIOR';
                    TEL_DATA(l_counter).TagValue := NULL;
                    --TEL_DATA(l_counter).TagValue := to_number( lr_TEL_PERSON_DETAILS.ACTION_INFORMATION20 );
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName :='LEL_EMPLOYMENT_START_DATE';
                    TEL_DATA(l_counter).TagValue := NULL;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName :='LEL_EMPLOYMENT_START_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := NULL;
                    l_counter := l_counter + 1;

                    -- find it If there is change in  Pension Group report the date of starting new record from EIT

                    TEL_DATA(l_counter).TagName := 'SHIFT_FRM_ANOTHER_TEL_EMP';
                    TEL_DATA(l_counter).TagValue :=  null;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'SHIFT_FRM_ANOTHER_TEL_EMP_DDMMYY';
                    TEL_DATA(l_counter).TagValue :=  null;
                    l_counter := l_counter + 1;
                    -- find it If there is change in  Pension Group report the date of starting new record from EIT
                    TEL_DATA(l_counter).TagName := 'CURRENCY';
                    TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION25;
                    l_counter := l_counter + 1;
*/

	         TEL_DATA(l_counter).TagName := 'REPORTING_METHOD';
                    TEL_DATA(l_counter).TagValue := to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION29);
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'TIME_RECORD_TYPE';
                    TEL_DATA(l_counter).TagValue := 'TIME_RECORD_TYPE_END';
                    l_counter := l_counter + 1;

        END IF; -- For the Action ID = '2'  IF
        --fnd_file.put_line(fnd_file.log,'=========================END===============================================' );
        --fnd_file.put_line(fnd_file.log,'=========================Terminated 5=================' );

        -- 5 = Terminated
            OPEN  CSR_EIT_DETAILS(l_payroll_action_id,lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Pension Types');
                FETCH CSR_EIT_DETAILS
                INTO LR_EIT_DETAILS;
            CLOSE CSR_EIT_DETAILS;
        /*
            OPEN  CSR_PERSON_EIT(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Pension Types');
                FETCH CSR_PERSON_EIT
                INTO LR_PERSON_EIT;
            CLOSE CSR_PERSON_EIT;
        */
        l_EIT_Action_Type := LR_EIT_DETAILS.ACTION_INFORMATION9;

        --fnd_file.put_line(fnd_file.log,'Terminated             ==> '||l_EIT_Action_Type );

        IF  lr_TEL_PERSON_DETAILS.ACTION_INFORMATION16 IS NOT NULL
        --AND LR_EIT_DETAILS.ACTION_INFORMATION8 ='N'
        THEN
                    l_TEL_Action_id := '5';
                    l_TIME_RECORD_5 := true;

                    --fnd_file.put_line(fnd_file.log,'l_TEL_Action_id                ==> '||l_TEL_Action_id );
                    --fnd_file.put_line(fnd_file.log,'Adding  Record 2 for Action 5  ==> '||l_TEL_Action_id );

                    TEL_DATA(l_counter).TagName := 'TIME_RECORD_TYPE';
                    TEL_DATA(l_counter).TagValue := 'TIME_RECORD_TYPE';
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'RECORD_TWO';
                    TEL_DATA(l_counter).TagValue := '2';
                    l_counter := l_counter + 1;

                    -- Find the Action Id here
                    TEL_DATA(l_counter).TagName := 'ACTION_ID';
                    TEL_DATA(l_counter).TagValue := '5';
                    l_counter := l_counter + 1;
                    -- Find the Action Id here

                    TEL_DATA(l_counter).TagName := 'START_DATE';
                    TEL_DATA(l_counter).TagValue := fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9 );
                    l_counter := l_counter + 1;

        		    TEL_DATA(l_counter).TagName := 'START_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(fnd_date.canonical_to_date( lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9 ),'DDMMYY');
                    l_counter := l_counter + 1;

                    -- Find if from g_effective date of Report prameters

                    --IF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'Y'
                    --THEN
                    --L_TARGET_YEAR := to_char(fnd_date.canonical_to_date(LR_REPORT_DETAILS.ACTION_INFORMATION8),'RRRR');
                    --ELSE
                        L_TARGET_YEAR := null;
                    --END IF;

                    TEL_DATA(l_counter).TagName := 'TARGET_YEAR_FOR_ANNUAL_INCOME';
                    TEL_DATA(l_counter).TagValue := L_TARGET_YEAR;
                    l_counter := l_counter + 1;

                    -- Find if from g_effective date of Report prameters

                    -- Find it from Balance values from 11 to 16
                    TEL_DATA(l_counter).TagName := 'INCOME';
                    IF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'M'
                    THEN
                    TEL_DATA(l_counter).TagValue :=TO_CHAR(NVL( FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION10) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION11) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION12),0) ,'999G999G990D99' );
                    ELSIF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'A'
                    THEN
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION13) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION14) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION15) ,0) ,'999G999G990D99' );
					ELSIF LR_REPORT_DETAILS.ACTION_INFORMATION8 = 'Q'
                    THEN
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PER1_DETAILS.ACTION_INFORMATION13) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PER1_DETAILS.ACTION_INFORMATION14) +
                                        FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PER1_DETAILS.ACTION_INFORMATION15),0) ,'999G999G990D99' );
                    END IF;

                    l_counter := l_counter + 1;
                    -- Find it from Balance values

/*
                    TEL_DATA(l_counter).TagName := 'BENEFIT_IN_KIND';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION11),0) ,'999G999G990D99' );
                    l_counter := l_counter + 1;

*/
                    TEL_DATA(l_counter).TagName := 'TERMINATION_DATE';
                    TEL_DATA(l_counter).TagValue :=fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION16);
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'TERMINATION_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue :=TO_CHAR(fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION16),'DDMMYY');
                    l_counter := l_counter + 1;


                    TEL_DATA(l_counter).TagName := 'CAUSE_OF_TERMINATION';
                    TEL_DATA(l_counter).TagValue :=  lr_TEL_PERSON_DETAILS.ACTION_INFORMATION17;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'YEARLY_TEL_INCOME_PRIOR';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION18) + FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION19) ,0) ,'999G999G990D99' );
                    l_counter := l_counter + 1;

		IF  NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION18) + FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION19) ,0) > 0 THEN

		   TEL_DATA(l_counter).TagName := 'TARGET_YEAR_FOR_TERM';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(fnd_date.canonical_to_date(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION16),'YYYY');
                    l_counter := l_counter + 1;

		END IF;

/*
                    TEL_DATA(l_counter).TagName := 'BENEFIT_IN_KIND_PRIOR';
                    TEL_DATA(l_counter).TagValue := TO_CHAR(NVL(FND_NUMBER.CANONICAL_TO_NUMBER(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION20) ,0) ,'999G999G990D99' );
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName :='LEL_EMPLOYMENT_START_DATE';
                    TEL_DATA(l_counter).TagValue :=  NULL;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName :='LEL_EMPLOYMENT_START_DATE_DDMMYY';
                    TEL_DATA(l_counter).TagValue := NULL;
                    l_counter := l_counter + 1;

                    -- find it If there is change in  Pension Group report the date of starting new record from EIT

                    TEL_DATA(l_counter).TagName := 'SHIFT_FRM_ANOTHER_TEL_EMP';
                    TEL_DATA(l_counter).TagValue :=  null;
                    l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'SHIFT_FRM_ANOTHER_TEL_EMP_DDMMYY';
                    TEL_DATA(l_counter).TagValue :=  null;
                    l_counter := l_counter + 1;

                    -- find it If there is change in  Pension Group report the date of starting new record from EIT
                    TEL_DATA(l_counter).TagName := 'CURRENCY';
                    TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION25;
                    l_counter := l_counter + 1;
*/

	         TEL_DATA(l_counter).TagName := 'REPORTING_METHOD';
                    TEL_DATA(l_counter).TagValue := to_number(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION29);
                    l_counter := l_counter + 1;


                    TEL_DATA(l_counter).TagName := 'TIME_RECORD_TYPE';
                    TEL_DATA(l_counter).TagValue := 'TIME_RECORD_TYPE_END';
                    l_counter := l_counter + 1;

        END IF; -- End of Action Type = S



                    TEL_DATA(l_counter).TagName := 'TIME_RECORD';
                    TEL_DATA(l_counter).TagValue := 'TIME_RECORD_END';
                    l_counter := l_counter + 1;


            IF l_TIME_RECORD_1
            or l_TIME_RECORD_2
            or l_TIME_RECORD_5
            THEN
            	-- If atleast one date pair exists then add the record 3
            	IF lr_TEL_PER1_DETAILS.ACTION_INFORMATION4 IS NOT NULL
            	or lr_TEL_PER1_DETAILS.ACTION_INFORMATION7 IS NOT NULL
            	or lr_TEL_PER1_DETAILS.ACTION_INFORMATION10 IS NOT NULL
                THEN
                	TEL_DATA(l_counter).TagName := 'ABSENCE_RECORD';
                    TEL_DATA(l_counter).TagValue := 'ABSENCE_RECORD';
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'RECORD_THREE';
                    TEL_DATA(l_counter).TagValue :=hr_general.decode_lookup('FI_FORM_LABELS','REC_C');
                    	l_counter := l_counter + 1;
--fnd_file.put_line(fnd_file.log,'   lr_TEL_PER1_DETAILS.FIRST_CODE ==> '||lr_TEL_PER1_DETAILS.FIRST_CODE );
                    TEL_DATA(l_counter).TagName := 'ABS_CODE_FIRST_DATE_PAIR';
                    TEL_DATA(l_counter).TagValue :=lr_TEL_PER1_DETAILS.FIRST_CODE;
                    	l_counter := l_counter + 1;
--fnd_file.put_line(fnd_file.log,'   lr_TEL_PER1_DETAILS.FIRSTDATEPAIR ==> '||lr_TEL_PER1_DETAILS.FIRSTDATEPAIR );
                    TEL_DATA(l_counter).TagName := 'FIRST_DATE_PAIR';
                    TEL_DATA(l_counter).TagValue :=lr_TEL_PER1_DETAILS.FIRSTDATEPAIR;
                    	l_counter := l_counter + 1;
--fnd_file.put_line(fnd_file.log,'   lr_TEL_PER1_DETAILS.ABS_CODE_SECOND_DATE_PAIR ==> '||lr_TEL_PER1_DETAILS.SECOND_CODE );
                    TEL_DATA(l_counter).TagName := 'ABS_CODE_SECOND_DATE_PAIR';
                    TEL_DATA(l_counter).TagValue :=lr_TEL_PER1_DETAILS.SECOND_CODE;
                    	l_counter := l_counter + 1;
--fnd_file.put_line(fnd_file.log,'   lr_TEL_PER1_DETAILS.SECONDDATEPAIR ==> '||lr_TEL_PER1_DETAILS.SECONDDATEPAIR );
                    TEL_DATA(l_counter).TagName := 'SECOND_DATE_PAIR';
                    TEL_DATA(l_counter).TagValue :=lr_TEL_PER1_DETAILS.SECONDDATEPAIR;
                    	l_counter := l_counter + 1;
--fnd_file.put_line(fnd_file.log,'   lr_TEL_PER1_DETAILS.THIRD_CODE ==> '||lr_TEL_PER1_DETAILS.THIRD_CODE );
                    TEL_DATA(l_counter).TagName := 'ABS_CODE_THIRD_DATE_PAIR';
                    TEL_DATA(l_counter).TagValue :=lr_TEL_PER1_DETAILS.THIRD_CODE;
                    	l_counter := l_counter + 1;
--fnd_file.put_line(fnd_file.log,'   lr_TEL_PER1_DETAILS.THIRDDATEPAIR ==> '||lr_TEL_PER1_DETAILS.THIRDDATEPAIR );
                    TEL_DATA(l_counter).TagName := 'THIRD_DATE_PAIR';
                    TEL_DATA(l_counter).TagValue :=lr_TEL_PER1_DETAILS.THIRDDATEPAIR;
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'ABS_ADDITIONAL_INFORMATION';
                    TEL_DATA(l_counter).TagValue :='1';
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'ABSENCE_RECORD';
                    TEL_DATA(l_counter).TagValue := 'ABSENCE_RECORD_END';
                    	l_counter := l_counter + 1;
                END IF;


            END IF; -- end of Record 4


		  IF lr_TEL_PERSON_DETAILS.ACTION_INFORMATION21 IS NOT NULL
                  or lr_TEL_PERSON_DETAILS.ACTION_INFORMATION22 IS NOT NULL
                  or lr_TEL_PERSON_DETAILS.ACTION_INFORMATION23 IS NOT NULL
                  THEN
                    TEL_DATA(l_counter).TagName := 'TRANSFER_RECORD';
                    TEL_DATA(l_counter).TagValue := 'TRANSFER_RECORD';
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'RECORD_FOUR';
                    TEL_DATA(l_counter).TagValue :=hr_general.decode_lookup('FI_FORM_LABELS','REC_D');
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'NEW_INSURANCE_POLICY_NUMBER';
                    TEL_DATA(l_counter).TagValue :=lr_TEL_PERSON_DETAILS.ACTION_INFORMATION21;
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'NEW_PENSION_GROUP';
                    TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION23;
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'NEW_DEPARTMENT';
                    TEL_DATA(l_counter).TagValue := lr_TEL_PERSON_DETAILS.ACTION_INFORMATION22;
                    	l_counter := l_counter + 1;

                    TEL_DATA(l_counter).TagName := 'TRANSFER_RECORD';
                    TEL_DATA(l_counter).TagValue := 'TRANSFER_RECORD_END';
                    	l_counter := l_counter + 1;
                	END IF;

	    TEL_DATA(l_counter).TagName := 'PERSON';
                    TEL_DATA(l_counter).TagValue := 'PERSON_END';
                    	l_counter := l_counter + 1;

-- Here Update the Person Extra Info EIT
IF p_test_run = 'N'
THEN

        --fnd_file.put_line(fnd_file.log,'   Before Updatign the EIT              ==> '||lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30 );
-- Person id is avilable in  lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30
-- PJD

    OPEN  CSR_PERSON_EIT(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Pension Joining Date');
        FETCH CSR_PERSON_EIT
        INTO LR_PERSON_EIT;

	IF csr_PERSON_EIT%FOUND
    THEN
    L_OVN := lr_PERSON_EIT.object_version_number;
    --fnd_file.put_line(fnd_file.log,'    PJD ' );
         --fnd_file.put_line(fnd_file.log,'   IS REPORTED   '||LR_PERSON_EIT.pei_information5 );
         --fnd_file.put_line(fnd_file.log,'   LAST REPORTED DATE   '||LR_PERSON_EIT.pei_information2 );
         --fnd_file.put_line(fnd_file.log,'   FIRST CHANGED DATE   '||LR_PERSON_EIT.pei_information7 );

        IF ( LR_PERSON_EIT.pei_information5 = 'N'
                AND
            NVL(LR_PERSON_EIT.pei_information2,to_date('01/01/0001','DD/MM/YYYY')) <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            AND
            LR_PERSON_EIT.pei_information7 <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            )
        THEN
         --fnd_file.put_line(fnd_file.log,'   Updating      PJD ' );
        hr_person_extra_info_api.update_person_extra_info
                         (
                           p_person_extra_info_id       => lr_PERSON_EIT.person_extra_info_id,
                           p_object_version_number      => L_OVN,
                        -- p_pei_information_category   => lr_PERSON_EIT.pei_information_category,
                        -- p_pei_information1           => lr_PERSON_EIT.pei_information1,
                           p_pei_information2           => LR_REPORT_DETAILS.ACTION_INFORMATION9,
                        -- p_pei_information3           => lr_PERSON_EIT.pei_information3,
                           p_pei_information4           => lr_TEL_PERSON_DETAILS.ACTION_INFORMATION9,
                           p_pei_information5           => 'Y'
                        -- p_pei_information6           => 'U',
 					    -- p_pei_information7           =>FND_DATE.DATE_TO_CANONICAL(LR_REPORT_DETAILS.ACTION_INFORMATION8                         )
                          );
          END IF;
    END IF;
    CLOSE CSR_PERSON_EIT;
-- PG
    OPEN  CSR_PERSON_EIT(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Pension Group');
        FETCH CSR_PERSON_EIT
        INTO LR_PERSON_EIT;
         --fnd_file.put_line(fnd_file.log,'    PG ' );
         --fnd_file.put_line(fnd_file.log,'   IS REPORTED   '||LR_PERSON_EIT.pei_information5 );
         --fnd_file.put_line(fnd_file.log,'   LAST REPORTED DATE   '||LR_PERSON_EIT.pei_information2 );
         --fnd_file.put_line(fnd_file.log,'   FIRST CHANGED DATE   '||LR_PERSON_EIT.pei_information7 );

	IF csr_PERSON_EIT%FOUND
    THEN
    L_OVN := lr_PERSON_EIT.object_version_number;
        IF ( LR_PERSON_EIT.pei_information5 = 'N'
                AND
            NVL(LR_PERSON_EIT.pei_information2,to_date('01/01/0001','DD/MM/YYYY')) <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            AND
            LR_PERSON_EIT.pei_information7 <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            )
        THEN
                 --fnd_file.put_line(fnd_file.log,'   Updating      PG ' );
        hr_person_extra_info_api.update_person_extra_info
                         (
                           p_person_extra_info_id       => lr_PERSON_EIT.person_extra_info_id,
                           p_object_version_number      => L_OVN,
                        -- p_pei_information_category   => lr_PERSON_EIT.pei_information_category,
                        -- p_pei_information1           => lr_PERSON_EIT.pei_information1,
                           p_pei_information2           => LR_REPORT_DETAILS.ACTION_INFORMATION9,
                        -- p_pei_information3           => lr_PERSON_EIT.pei_information3,
                           p_pei_information4           => lr_TEL_PERSON_DETAILS.ACTION_INFORMATION27,
                           p_pei_information5           => 'Y'
                        -- p_pei_information6           => 'U',
 					    -- p_pei_information7           =>FND_DATE.DATE_TO_CANONICAL(LR_REPORT_DETAILS.ACTION_INFORMATION8                         )
                          );
          END IF;
    END IF;
    CLOSE CSR_PERSON_EIT;
    -- PT
    OPEN  CSR_PERSON_EIT(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Pension Types');
        FETCH CSR_PERSON_EIT
        INTO LR_PERSON_EIT;

	IF csr_PERSON_EIT%FOUND
    THEN
    L_OVN := lr_PERSON_EIT.object_version_number;
             --fnd_file.put_line(fnd_file.log,'    PT ' );
         --fnd_file.put_line(fnd_file.log,'   IS REPORTED   '||LR_PERSON_EIT.pei_information5 );
         --fnd_file.put_line(fnd_file.log,'   LAST REPORTED DATE   '||LR_PERSON_EIT.pei_information2 );
         --fnd_file.put_line(fnd_file.log,'   FIRST CHANGED DATE   '||LR_PERSON_EIT.pei_information7 );

        IF ( LR_PERSON_EIT.pei_information5 = 'N'
                AND
            NVL(LR_PERSON_EIT.pei_information2,to_date('01/01/0001','DD/MM/YYYY')) <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            AND
            LR_PERSON_EIT.pei_information7 <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            )
        THEN
                 --fnd_file.put_line(fnd_file.log,'   Updating      PT ' );
        hr_person_extra_info_api.update_person_extra_info
                         (
                           p_person_extra_info_id       => lr_PERSON_EIT.person_extra_info_id,
                           p_object_version_number      => L_OVN,
                        -- p_pei_information_category   => lr_PERSON_EIT.pei_information_category,
                        -- p_pei_information1           => lr_PERSON_EIT.pei_information1,
                           p_pei_information2           => LR_REPORT_DETAILS.ACTION_INFORMATION9,
                        -- p_pei_information3           => lr_PERSON_EIT.pei_information3,
                           p_pei_information4           => lr_TEL_PERSON_DETAILS.ACTION_INFORMATION26,
                           p_pei_information5           => 'Y'
                        -- p_pei_information6           => 'U',
 					    -- p_pei_information7           =>FND_DATE.DATE_TO_CANONICAL(LR_REPORT_DETAILS.ACTION_INFORMATION8                         )
                          );
          END IF;
    END IF;
    CLOSE CSR_PERSON_EIT;

     -- Pension Insurance Number
    OPEN  CSR_PERSON_EIT(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Insurance Number');
        FETCH CSR_PERSON_EIT
        INTO LR_PERSON_EIT;

	IF csr_PERSON_EIT%FOUND
    THEN
    L_OVN := lr_PERSON_EIT.object_version_number;
             --fnd_file.put_line(fnd_file.log,'    PT ' );
         --fnd_file.put_line(fnd_file.log,'   IS REPORTED   '||LR_PERSON_EIT.pei_information5 );
         --fnd_file.put_line(fnd_file.log,'   LAST REPORTED DATE   '||LR_PERSON_EIT.pei_information2 );
         --fnd_file.put_line(fnd_file.log,'   FIRST CHANGED DATE   '||LR_PERSON_EIT.pei_information7 );

        IF ( LR_PERSON_EIT.pei_information5 = 'N'
                AND
            NVL(LR_PERSON_EIT.pei_information2,to_date('01/01/0001','DD/MM/YYYY')) <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            AND
            LR_PERSON_EIT.pei_information7 <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            )
        THEN
                 --fnd_file.put_line(fnd_file.log,'   Updating      PT ' );
        hr_person_extra_info_api.update_person_extra_info
                         (
                           p_person_extra_info_id       => lr_PERSON_EIT.person_extra_info_id,
                           p_object_version_number      => L_OVN,
                        -- p_pei_information_category   => lr_PERSON_EIT.pei_information_category,
                        -- p_pei_information1           => lr_PERSON_EIT.pei_information1,
                           p_pei_information2           => LR_REPORT_DETAILS.ACTION_INFORMATION9,
                        -- p_pei_information3           => lr_PERSON_EIT.pei_information3,
                           p_pei_information4           => lr_TEL_PERSON_DETAILS.ACTION_INFORMATION21,
                           p_pei_information5           => 'Y'
                        -- p_pei_information6           => 'U',
 					    -- p_pei_information7           =>FND_DATE.DATE_TO_CANONICAL(LR_REPORT_DETAILS.ACTION_INFORMATION8                         )
                          );
          END IF;
    END IF;
    CLOSE CSR_PERSON_EIT;

-- Local Unit
    OPEN  CSR_PERSON_EIT(lr_TEL_PERSON_DETAILS.ACTION_INFORMATION30,'Local Unit');
        FETCH CSR_PERSON_EIT
        INTO LR_PERSON_EIT;
         --fnd_file.put_line(fnd_file.log,'    LU ' );
         --fnd_file.put_line(fnd_file.log,'   IS REPORTED   '||LR_PERSON_EIT.pei_information5 );
         --fnd_file.put_line(fnd_file.log,'   LAST REPORTED DATE   '||LR_PERSON_EIT.pei_information2 );
         --fnd_file.put_line(fnd_file.log,'   FIRST CHANGED DATE   '||LR_PERSON_EIT.pei_information7 );

	IF csr_PERSON_EIT%FOUND
    THEN
    L_OVN := lr_PERSON_EIT.object_version_number;
        IF ( LR_PERSON_EIT.pei_information5 = 'N'
                AND
            NVL(LR_PERSON_EIT.pei_information2,to_date('01/01/0001','DD/MM/YYYY')) <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            AND
            LR_PERSON_EIT.pei_information7 <= LR_REPORT_DETAILS.ACTION_INFORMATION9
            )
        THEN
        --fnd_file.put_line(fnd_file.log,'   Updating      LOCAL UNIT ' );
        hr_person_extra_info_api.update_person_extra_info
                         (
                           p_person_extra_info_id       => lr_PERSON_EIT.person_extra_info_id,
                           p_object_version_number      => L_OVN,
                        -- p_pei_information_category   => lr_PERSON_EIT.pei_information_category,
                        -- p_pei_information1           => lr_PERSON_EIT.pei_information1,
                           p_pei_information2           => LR_REPORT_DETAILS.ACTION_INFORMATION9,
                        -- p_pei_information3           => lr_PERSON_EIT.pei_information3,
                           p_pei_information4           => lr_TEL_PERSON_DETAILS.ACTION_INFORMATION28,
                           p_pei_information5           => 'Y'
                        -- p_pei_information6           => 'U',
 					    -- p_pei_information7           =>FND_DATE.DATE_TO_CANONICAL(LR_REPORT_DETAILS.ACTION_INFORMATION8                         )
                          );
          END IF;
    END IF;

    CLOSE CSR_PERSON_EIT;

END IF;

-- Here Update the Person Extra Info EIT
END IF; -- for record two found cursor
    --fnd_file.put_line(fnd_file.log,'END OF A PERSON ' );
    --fnd_file.put_line(fnd_file.log,'+++++++++++++++++++++++++END+++++++++++++++++++++++++++++++++++++++++++++++' );

END LOOP;
					hr_utility.set_location('After populating pl/sql table',30);
commit;

					WritetoCLOB (p_xml );


END GET_DATA;

-----------------------------------------------------------------------------------------------------------------
PROCEDURE WritetoCLOB(p_xfdf_clob out nocopy CLOB) IS
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

current_index number;

 l_IANA_charset VARCHAR2 (50);
   BEGIN
     l_IANA_charset :=hr_fi_utility.get_IANA_charset ;
     --hr_utility.trace_on(NULL,'SR1');
        l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT>';
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

              if TEL_DATA.count > 0 then



			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

        		FOR table_counter IN TEL_DATA.FIRST .. TEL_DATA.LAST LOOP
        			l_str8 := TEL_DATA(table_counter).TagName;
	        		l_str9 := TEL_DATA(table_counter).TagValue;

----fnd_file.put_line(fnd_file.log,'outside  str8 ==> '||l_str8 );
----fnd_file.put_line(fnd_file.log,'outside  str9 ==> '||l_str9 );

                    IF l_str9 IN ('PERSON','PERSON_END',
                                    'TIME_RECORD' ,'TIME_RECORD_END',
				                  'EMP_RECORD','EMP_RECORD_END',
				                  'ABSENCE_RECORD','ABSENCE_RECORD_END',
                                  'TRANSFER_RECORD','TRANSFER_RECORD_END',
                                  'TIME_RECORD_TYPE','TIME_RECORD_TYPE_END'
                                  )
                    THEN

						IF l_str9 IN ('PERSON','TIME_RECORD' ,'EMP_RECORD','ABSENCE_RECORD','TRANSFER_RECORD',
						              'TIME_RECORD_TYPE')
                         THEN
/*    						IF l_str9 = 'EMP_RECORD'
                            THEN
       					     dbms_lob.writeAppend(l_xfdf_string, length(l_str10), l_str10);
                            END IF;
  */
--fnd_file.put_line(fnd_file.log,'IF l_str8 ==> '||l_str8 );
--fnd_file.put_line(fnd_file.log,'IF l_str9 ==> '||l_str9 );


      				           dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
    						   dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
	   					       dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);


						ELSE
--fnd_file.put_line(fnd_file.log,'ELSE l_str8 ==> '||l_str8 );
--fnd_file.put_line(fnd_file.log,'ELSE l_str9 ==> '||l_str9 );
						      dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
						      dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
                              dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
/*
    						IF l_str9 = 'ADDITIONAL_EMPLOYMENT_END' THEN
                            -- TO start a new person record
                             dbms_lob.writeAppend(l_xfdf_string, length(l_str11), l_str11);

                            END IF;
*/
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


                        --dbms_lob.writeAppend(l_xfdf_string, length(l_str11), l_str11 );
			dbms_lob.writeAppend(l_xfdf_string, length(l_str6), l_str6 );
		else
			dbms_lob.writeAppend(l_xfdf_string, length(l_str7), l_str7 );
		end if;

	--DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);


p_xfdf_clob := l_xfdf_string;


		--hr_utility.trace(l_xfdf_string);

	--clob_to_blob(l_xfdf_string,p_xfdf_blob);


	hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);

	--return p_xfdf_blob;
	EXCEPTION
		WHEN OTHERS then
	        HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	        HR_UTILITY.RAISE_ERROR;
END WritetoCLOB;
-------------------------------------------------------------------------------------------------------------------------

END PAY_FI_TELR;

/
