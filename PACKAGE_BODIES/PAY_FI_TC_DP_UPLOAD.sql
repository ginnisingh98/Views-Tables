--------------------------------------------------------
--  DDL for Package Body PAY_FI_TC_DP_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_TC_DP_UPLOAD" AS
/* $Header: pyfitaxu.pkb 120.0.12000000.2 2007/03/05 13:08:09 psingla noship $ */

	g_package			CONSTANT VARCHAR2 (33) := 'pay_fi_tc_dp_upload';

	g_batch_header                  VARCHAR2 (50)  ;
	g_batch_source                  VARCHAR2 (50)  ;
	g_batch_comments                VARCHAR2 (100) ;

	e_invalid_value			EXCEPTION;
	e_no_asg			EXCEPTION;
	e_record_too_long		EXCEPTION;
	e_mismatch_tax_card		EXCEPTION;
	e_no_data_tax			EXCEPTION;
	e_no_tax_element		EXCEPTION;
	e_no_tax_link			EXCEPTION;

	PRAGMA exception_init (e_invalid_value,  -1858);

	-- Global constants
	c_warning			CONSTANT NUMBER        := 1;
	c_error				CONSTANT NUMBER        := 2;
	c_end_of_time			CONSTANT DATE          := to_date('12/31/4712','MM/DD/YYYY');

	PROCEDURE upload(
		errbuf			OUT NOCOPY   VARCHAR2,
		retcode			OUT NOCOPY   NUMBER,
	        p_file_name		IN       VARCHAR2,
	        p_effective_date	IN       VARCHAR2,
	        p_business_group_id	IN       per_business_groups.business_group_id%TYPE,
	        p_batch_name		IN       VARCHAR2 DEFAULT NULL	,
	        p_reference		IN       VARCHAR2 DEFAULT NULL
	        )
	IS
	        -- Constants
	        c_read_file		CONSTANT VARCHAR2 (1)            := 'r';
	        c_max_linesize		CONSTANT NUMBER                  := 4000;
	        c_commit_point		CONSTANT NUMBER                  := 20;
	        c_data_exchange_dir	CONSTANT VARCHAR2 (30)           := 'PER_DATA_EXCHANGE_DIR';


	        -- Procedure name
	        l_proc			CONSTANT VARCHAR2 (72)           :=    g_package||'.upload' ;
	        l_legislation_code	per_business_groups.legislation_code%TYPE;
	        l_bg_name		per_business_groups.name%TYPE;

	        -- File Handling variables
	        l_file_type             UTL_FILE.file_type;
	        l_filename              VARCHAR2 (240);
	        l_location              VARCHAR2 (4000);
	        l_line_read             VARCHAR2 (4000)                        := NULL;

	        -- Batch Variables
	        l_batch_seq             NUMBER                                    := 0;
	        l_batch_id              NUMBER;

	        -- Parameter values to create Batch Lines
	        l_tc_ee_user_key           VARCHAR2(240);
		l_t_ee_user_key           VARCHAR2(240);
  	        L_ASSIGNMENT_USER_KEY   VARCHAR2(240);
	        L_ELEMENT_LINK_USER_KEY VARCHAR2(240);
	        l_user_key_value        hr_pump_batch_line_user_keys.user_key_value%type;
	        l_unique_key_id         hr_pump_batch_line_user_keys.unique_key_id%type;
	        l_assignment_id         per_all_assignments_f.assignment_id%TYPE;
	        l_datetrack_update_mode VARCHAR2(80);

	        -- Variables to Read from File
		l_ni			VARCHAR2(80);
                l_row_count		NUMBER;
	        l_employer_org_no       VARCHAR2(80);
		l_employment_type	VARCHAR2(80);
	        l_element_entry_id      pay_element_entries_f.element_entry_id%TYPE;
	        L_ELEMENT_LINK_ID       pay_element_links_f.ELEMENT_LINK_ID%TYPE;
	        l_element_name          pay_element_types_f.element_name%TYPE;
	        l_effective_start_date  pay_element_entries_f.effective_start_date%TYPE;
	        l_effective_end_date    pay_element_entries_f.effective_end_date%TYPE;
	        l_input_value_name1   	VARCHAR2(80);
	        l_input_value_name2   	VARCHAR2(80);
	        l_input_value_name3   	VARCHAR2(80);
	        l_input_value_name4   	VARCHAR2(80);
	        l_input_value_name5   	VARCHAR2(80);
	        l_input_value_name6   	VARCHAR2(80);
	        l_input_value_name7   	VARCHAR2(80);
	        l_input_value_name8   	VARCHAR2(80);
	        l_input_value_name9   	VARCHAR2(80);
	        l_input_value_name10 	VARCHAR2(80);
	        l_input_value_name11 	VARCHAR2(80);
  	        l_input_value_name12 	VARCHAR2(80);
	        l_input_value_name13 	VARCHAR2(80);
	        l_input_value_name14 	VARCHAR2(80);
	        l_input_value_name15	VARCHAR2(80);
	        l_entry_value1          VARCHAR2(60);
	        l_entry_value2          VARCHAR2(60);
	        l_entry_value3          VARCHAR2(60);
	        l_entry_value4          VARCHAR2(60);
	        l_entry_value5          VARCHAR2(60);
	        l_entry_value6          VARCHAR2(60);
	        l_entry_value7          VARCHAR2(60);
	        l_entry_value8          VARCHAR2(60);
	        l_entry_value9          VARCHAR2(60);
	        l_entry_value10         VARCHAR2(60);
	        l_entry_value11         VARCHAR2(60);
	        l_entry_value12         VARCHAR2(60);
	        l_entry_value13         VARCHAR2(60);
	        l_entry_value14         VARCHAR2(60);
	        l_entry_value15         VARCHAR2(60);

		l_t_entry_value1          VARCHAR2(60);
	        l_t_entry_value2          VARCHAR2(60);
	        l_t_entry_value3          VARCHAR2(60);
	        l_t_entry_value4          VARCHAR2(60);
	        l_t_entry_value5          VARCHAR2(60);
	        l_t_entry_value6          VARCHAR2(60);
	        l_t_entry_value7          VARCHAR2(60);
	        l_t_entry_value8          VARCHAR2(60);
	        l_t_entry_value9          VARCHAR2(60);
	        l_t_entry_value10         VARCHAR2(60);
	        l_t_entry_value11         VARCHAR2(60);
	        l_t_entry_value12         VARCHAR2(60);
	        l_t_entry_value13         VARCHAR2(60);
	        l_t_entry_value14         VARCHAR2(60);
	        l_t_entry_value15         VARCHAR2(60);

	        -- Exceptions
	        e_fatal_error           EXCEPTION;
	        e_prim_assg_error       EXCEPTION;
	        e_element_details       EXCEPTION;

	        --Flag variables
	        l_element_link_found    VARCHAR2(30);
	        l_prim_assg_found    VARCHAR2(30);

	        CURSOR csr_leg (v_bg_id per_business_groups.business_group_id%TYPE)
	        IS
		SELECT legislation_code, name
		FROM per_business_groups
		WHERE business_group_id = v_bg_id;

	        CURSOR csr_get_prim_assg( p_business_group_id per_business_groups.business_group_id%TYPE
	        ,p_ni per_all_people_f.national_identifier%TYPE
	        ,p_employer_org_no  HR_ORGANIZATION_INFORMATION.org_information2%TYPE)
	        IS
		SELECT  PAA.ASSIGNMENT_ID
		FROM per_all_assignments_f PAA
		, per_all_people_f PAP
		, hr_soft_coding_keyflex SCL
		WHERE PAA.BUSINESS_GROUP_ID      = p_business_group_id
		AND PAP.per_information_category ='FI'
		AND PAP.NATIONAL_IDENTIFIER = p_ni
		AND PAA.PERSON_ID = PAP.PERSON_ID
		AND PAA.PRIMARY_FLAG = 'Y'
		AND PAA.soft_coding_keyflex_id = SCL.soft_coding_keyflex_id
		AND fnd_date.canonical_to_date(p_effective_date) between  PAA.EFFECTIVE_START_DATE  and PAA.EFFECTIVE_END_DATE
		AND fnd_date.canonical_to_date(p_effective_date) between  PAP.EFFECTIVE_START_DATE  and PAP.EFFECTIVE_END_DATE
		AND SCL.ENABLED_FLAG = 'Y'
		AND SCL.SEGMENT2       in
		( select to_char(hoi1.organization_id)
		 from HR_ORGANIZATION_UNITS o1
		, HR_ORGANIZATION_INFORMATION hoi1
		, HR_ORGANIZATION_INFORMATION hoi2
		, HR_ORGANIZATION_INFORMATION hoi3
		, HR_ORGANIZATION_INFORMATION hoi4
		WHERE o1.business_group_id = p_business_group_id
		and hoi1.organization_id = o1.organization_id
		and hoi1.org_information1 = 'FI_LOCAL_UNIT'
		and hoi1.org_information_context = 'CLASS'
		and o1.organization_id = hoi2.org_information1
		and hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
		and hoi2.organization_id =  hoi3.organization_id
		and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
		and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		and hoi4.ORG_INFORMATION_CONTEXT='FI_LEGAL_EMPLOYER_DETAILS'
		and hoi4.organization_id =  hoi3.organization_id
		and hoi4.org_information1 = SUBSTR(p_employer_org_no,1,9)
		and fnd_date.canonical_to_date(p_effective_date) >= o1.DATE_FROM
		and fnd_date.canonical_to_date(p_effective_date) <= nvl(o1.DATE_TO, fnd_date.canonical_to_date(p_effective_date)));



		CURSOR csr_get_all_assg( p_business_group_id per_business_groups.business_group_id%TYPE
	        ,p_ni per_all_people_f.national_identifier%TYPE
	        ,p_employer_org_no  HR_ORGANIZATION_INFORMATION.org_information2%TYPE)
	        IS
		SELECT  PAA.ASSIGNMENT_ID
		FROM per_all_assignments_f PAA
		, per_all_people_f PAP
		, hr_soft_coding_keyflex SCL
		WHERE PAA.BUSINESS_GROUP_ID      = p_business_group_id
		AND PAP.per_information_category ='FI'
		AND PAP.NATIONAL_IDENTIFIER = p_ni
		AND PAA.PERSON_ID = PAP.PERSON_ID
		AND PAA.soft_coding_keyflex_id = SCL.soft_coding_keyflex_id
		AND fnd_date.canonical_to_date(p_effective_date) between  PAA.EFFECTIVE_START_DATE  and PAA.EFFECTIVE_END_DATE
		AND fnd_date.canonical_to_date(p_effective_date) between  PAP.EFFECTIVE_START_DATE  and PAP.EFFECTIVE_END_DATE
		AND SCL.ENABLED_FLAG = 'Y'
		AND SCL.SEGMENT2       in
		( select to_char(hoi1.organization_id)
		 from HR_ORGANIZATION_UNITS o1
		, HR_ORGANIZATION_INFORMATION hoi1
		, HR_ORGANIZATION_INFORMATION hoi2
		, HR_ORGANIZATION_INFORMATION hoi3
		, HR_ORGANIZATION_INFORMATION hoi4
		WHERE o1.business_group_id = p_business_group_id
		and hoi1.organization_id = o1.organization_id
		and hoi1.org_information1 = 'FI_LOCAL_UNIT'
		and hoi1.org_information_context = 'CLASS'
		and o1.organization_id = hoi2.org_information1
		and hoi2.ORG_INFORMATION_CONTEXT='FI_LOCAL_UNITS'
		and hoi2.organization_id =  hoi3.organization_id
		and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
		and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
		and hoi4.ORG_INFORMATION_CONTEXT='FI_LEGAL_EMPLOYER_DETAILS'
		and hoi4.organization_id =  hoi3.organization_id
		and hoi4.org_information1 = SUBSTR(p_employer_org_no,1,9)
		and fnd_date.canonical_to_date(p_effective_date) >= o1.DATE_FROM
		and fnd_date.canonical_to_date(p_effective_date) <= nvl(o1.DATE_TO, fnd_date.canonical_to_date(p_effective_date)));



	        CURSOR csr_get_element_details
		(p_assignment_id per_all_assignments_f.assignment_id%TYPE
		,p_element_name pay_element_types_f.ELEMENT_NAME%TYPE)
	        IS
		SELECT pee.ELEMENT_ENTRY_ID , pet.ELEMENT_NAME, pee.EFFECTIVE_START_DATE,pee.EFFECTIVE_END_DATE
		from pay_element_entries_f pee
		, pay_element_types_f pet
		, pay_element_links_f pel
		, per_all_assignments_f paa
		where pet.ELEMENT_NAME = p_element_name
		and pet.legislation_code = 'FI'
		and pel.ELEMENT_TYPE_ID = pet.ELEMENT_TYPE_ID
		and pee.ELEMENT_LINK_ID = pel.ELEMENT_LINK_ID
		and paa.ASSIGNMENT_ID = pee.ASSIGNMENT_ID
		and pee.ELEMENT_TYPE_ID = pet.ELEMENT_TYPE_ID
		and pee.ASSIGNMENT_ID = p_assignment_id
		and fnd_date.canonical_to_date(p_effective_date) between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
		and fnd_date.canonical_to_date(p_effective_date) between pet.EFFECTIVE_START_DATE and pet.EFFECTIVE_END_DATE
		and fnd_date.canonical_to_date(p_effective_date) between pel.EFFECTIVE_START_DATE and pel.EFFECTIVE_END_DATE
		and fnd_date.canonical_to_date(p_effective_date) between paa.EFFECTIVE_START_DATE and paa.EFFECTIVE_END_DATE ;

	        CURSOR csr_get_user_key(p_user_key_value hr_pump_batch_line_user_keys.user_key_value%type)
	        IS
		SELECT user_key_value, unique_key_id
		FROM   hr_pump_batch_line_user_keys
		WHERE  user_key_value = p_user_key_value;



	BEGIN
		INSERT INTO fnd_sessions(SESSION_ID , EFFECTIVE_DATE )
		VALUES(userenv('SESSIONID'),fnd_date.canonical_to_date(p_effective_date)) ;

		-- input parameters
		hr_utility.set_location('p_file_name                '||p_file_name,1);
		hr_utility.set_location('p_effective_date           '||p_effective_date,1);
		hr_utility.set_location('p_business_group_id        '||p_business_group_id,1 );
		hr_utility.set_location('p_batch_name               '||p_batch_name,1);
		hr_utility.set_location('p_reference                '||p_reference,1);

		hr_utility.set_location (   'Entering:' || l_proc, 10);

		OPEN csr_leg (p_business_group_id);
		FETCH csr_leg INTO l_legislation_code, l_bg_name;
		CLOSE csr_leg;

		hr_utility.set_location (   'Legislation = ' || l_legislation_code, 20);

		l_filename := p_file_name;
		fnd_profile.get (c_data_exchange_dir, l_location);
		hr_utility.set_location (   'Directory = ' || l_location, 30);

		IF l_location IS NULL THEN
			-- error : I/O directory not defined
			RAISE e_fatal_error;
		END IF;

		-- Open flat file
		l_file_type :=
		UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);

		-- Create the Batch header
		l_batch_id := hr_pump_utils.create_batch_header
		(p_batch_name          => p_batch_name,
		p_business_group_name => l_bg_name,
		p_reference           => substr(p_reference||'('||fnd_date.date_to_displaydt(SYSDATE)||')',1,30));

		hr_utility.set_location (   '  Batch ID = ' || l_batch_id, 40);

		-- Loop over the file, reading in each line.  GET_LINE will
		-- raise NO_DATA_FOUND when it is done, so we use that as the
		-- exit condition for the loop

		<<read_lines_in_file>>
		LOOP
			BEGIN
				UTL_FILE.get_line (l_file_type, l_line_read);
			        l_batch_seq :=   l_batch_seq + 1;
			EXCEPTION
				WHEN VALUE_ERROR  THEN
			        -- Input line too large for buffer specified in UTL_FILE.fopen

					IF UTL_FILE.is_open (l_file_type) THEN
						UTL_FILE.fclose (l_file_type);
			                END IF;

					hr_utility.set_location (l_proc, 50);
			                retcode := c_error;
			                -- The error will mean batch_seq doesn't get upped so add 1 when
				        -- reporting line
			                errbuf :=    'Input line (line nr = '
				        || l_batch_seq
		                        + 1
				        || ') too large for buffer (='
		                        || c_max_linesize
				        || ').';
			                EXIT;
			        WHEN NO_DATA_FOUND     THEN
					EXIT;
			END;

		        hr_utility.set_location ( '  line read: ' || SUBSTR (l_line_read, 1, 40),60);

			BEGIN
				-- setting default value for element link found flag
				l_element_link_found := 'FOUND';

				-- setting default value for Primary Assignment found flag
				l_prim_assg_found := 'FOUND';

				read_record
				(
				p_line           => l_line_read
				,p_entry_value1   => l_entry_value1
				,p_entry_value2   => l_entry_value2
				,p_entry_value3   => l_entry_value3
				,p_entry_value4   => l_entry_value4
				,p_entry_value5   => l_entry_value5
				,p_entry_value6   => l_entry_value6
				,p_entry_value7   => l_entry_value7
				,p_entry_value8   => l_entry_value8
				,p_entry_value9   => l_entry_value9
				,p_entry_value10  => l_entry_value10
				,p_entry_value11  => l_entry_value11
				,p_entry_value12  => l_entry_value12
				,p_entry_value13  => l_entry_value13
				,p_entry_value14  => l_entry_value14
				,p_entry_value15  => l_entry_value15
				,p_return_value1  => l_ni
				,p_return_value2  => l_employer_org_no
				,p_return_value3  => l_employment_type
				);

				 hr_utility.set_location (   '  NI Number = ' || l_ni, 130);
				 hr_utility.set_location (   '  Employer Organization Number = ' || l_employer_org_no, 140);

				 OPEN csr_get_prim_assg
				 ( p_business_group_id => p_business_group_id
				 ,p_ni               => l_ni
				 ,p_employer_org_no   => l_employer_org_no ) ;
				 FETCH csr_get_prim_assg INTO l_assignment_id;
				 IF csr_get_prim_assg%NOTFOUND THEN
					--RAISE e_prim_assg_error;
					l_prim_assg_found := 'NOT_FOUND';
				 END IF;
				 CLOSE csr_get_prim_assg;

				IF l_prim_assg_found = 'FOUND' THEN

					 /* Initialize values for input value names of the seeded element */

					 l_input_value_name1  := 'Method of Receipt' ;
					 l_input_value_name2  := 'Tax Municipality' ;
					 l_input_value_name3  := 'Tax Card Type';
					 l_input_value_name4  := 'Base Rate';
					 l_input_value_name5  := 'Additional Rate';
					 l_input_value_name6  := 'Previous Income';
					 l_input_value_name7  := 'Yearly Income Limit';
					 l_input_value_name8  := 'Registration Date';
					 l_input_value_name9  := 'Date Returned' ;
					 l_input_value_name10 := 'Override Manual Update';
					 l_input_value_name11 := 'Lower Income Percentage';
					 l_input_value_name12 := NULL;
					 l_input_value_name13 := NULL;
					 l_input_value_name14 := NULL;
					 l_input_value_name15 := NULL;

					 OPEN csr_get_element_details(l_assignment_id ,'Tax Card') ;
					 FETCH csr_get_element_details
					 INTO l_element_entry_id,l_element_name,l_effective_start_date,l_effective_end_date;
					 IF csr_get_element_details%NOTFOUND THEN
						--RAISE e_element_details;
						 l_element_link_found := 'NOT_FOUND';
					 END IF;
					 CLOSE csr_get_element_details;


					 hr_utility.set_location (   '  Element Entry ID = ' || l_element_entry_id, 150);
					 hr_utility.set_location (   '  Element Name = ' || l_element_name, 150);
					 hr_utility.set_location (   '  Element Entry Start Date = '||l_effective_start_date, 150);
					 hr_utility.set_location (   '  Element Entry End Date = '||l_effective_end_date, 150);

					l_element_link_id  := get_element_link_id(l_assignment_id ,p_business_group_id,p_effective_date,'Tax Card');

					-- Add User Keys for Data Pump
					l_tc_ee_user_key:=NULL;

					L_ASSIGNMENT_USER_KEY:=NULL;
					L_ELEMENT_LINK_USER_KEY:=NULL;

					IF l_element_link_found = 'FOUND' THEN

						l_tc_ee_user_key           :=to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ELEMENT ENTRY USER KEY';

						OPEN csr_get_user_key(l_tc_ee_user_key);
						FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
						-- Add user key only if it does not exist previously
						IF csr_get_user_key%NOTFOUND THEN
							hr_pump_utils.add_user_key(l_tc_ee_user_key,l_element_entry_id);
						ELSE

							hr_pump_utils.modify_user_key(l_tc_ee_user_key,l_tc_ee_user_key,l_element_entry_id);

						END IF;
						CLOSE csr_get_user_key;

						hr_utility.set_location (   '  User Key added  ' , 160);

						hr_utility.set_location (   '  l_effective_start_date:' || to_char(l_effective_start_date), 170);
						hr_utility.set_location (   '  l_effective_end_date:' || to_char(l_effective_end_date), 170);
						hr_utility.set_location (   '  p_effective_date:' || to_char(fnd_date.canonical_to_date(p_effective_date)), 170);
						hr_utility.set_location (   '  c_end_of_time:' || to_char(c_end_of_time), 170);

						-- Define Datetrack Updation Mode
						IF(l_effective_start_date = fnd_date.canonical_to_date(p_effective_date))
						THEN
							l_datetrack_update_mode := 'CORRECTION';
						ELSIF(l_effective_end_date <> c_end_of_time)
						THEN
							l_datetrack_update_mode := 'UPDATE_OVERRIDE';
						ELSE
							l_datetrack_update_mode := 'UPDATE';
						END IF;

						hr_utility.set_location (   '  Datetrack Update Mode:' || l_datetrack_update_mode, 180);


						-- Data Pump procedure called to create batch lines to update element entries
						hrdpp_update_element_entry.insert_batch_lines
						(p_batch_id      => l_batch_id
						,p_data_pump_business_grp_name => l_bg_name
						,P_DATETRACK_UPDATE_MODE =>  l_datetrack_update_mode
						,P_EFFECTIVE_DATE => fnd_date.canonical_to_date(p_effective_date)
						,P_ENTRY_VALUE1 => l_entry_value1
						,P_ENTRY_VALUE2 => l_entry_value2
						,P_ENTRY_VALUE3 => l_entry_value3
						,P_ENTRY_VALUE4 => l_entry_value4
						,P_ENTRY_VALUE5 => l_entry_value5
						,P_ENTRY_VALUE6 => l_entry_value6
						,P_ENTRY_VALUE7 => l_entry_value7
						,P_ENTRY_VALUE8 => l_entry_value8
						,P_ENTRY_VALUE9 => l_entry_value9
						,P_ENTRY_VALUE10 => l_entry_value10
						,P_ENTRY_VALUE11 => l_entry_value11
						,P_ENTRY_VALUE12 => l_entry_value12
						,P_ENTRY_VALUE13 => l_entry_value13
						,P_ENTRY_VALUE14 => l_entry_value14
						,P_ENTRY_VALUE15 => l_entry_value15
						,P_ELEMENT_ENTRY_USER_KEY => l_tc_ee_user_key
						,P_ELEMENT_NAME => l_element_name
						,P_LANGUAGE_CODE =>'US'
						,P_INPUT_VALUE_NAME1 =>l_input_value_name1
						,P_INPUT_VALUE_NAME2 =>l_input_value_name2
						,P_INPUT_VALUE_NAME3 =>l_input_value_name3
						,P_INPUT_VALUE_NAME4 =>l_input_value_name4
						,P_INPUT_VALUE_NAME5 =>l_input_value_name5
						,P_INPUT_VALUE_NAME6 =>l_input_value_name6
						,P_INPUT_VALUE_NAME7 =>l_input_value_name7
						,P_INPUT_VALUE_NAME8 =>l_input_value_name8
						,P_INPUT_VALUE_NAME9 =>l_input_value_name9
						,P_INPUT_VALUE_NAME10 =>l_input_value_name10
						,P_INPUT_VALUE_NAME11 =>l_input_value_name11
						,P_INPUT_VALUE_NAME12 =>l_input_value_name12
						,P_INPUT_VALUE_NAME13 =>l_input_value_name13
						,P_INPUT_VALUE_NAME14 =>l_input_value_name14
						,P_INPUT_VALUE_NAME15 =>l_input_value_name15);

					ELSE


						l_tc_ee_user_key           :=to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ELEMENT ENTRY USER KEY';
						L_ASSIGNMENT_USER_KEY      :=to_char(l_assignment_id ) ||' : ASG USER KEY';
						L_ELEMENT_LINK_USER_KEY    :=to_char(L_ELEMENT_LINK_ID) ||' : ELEM LINK USER KEY';


						/* deletion code for user key*/
						OPEN csr_get_user_key(l_tc_ee_user_key);
						FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
						--DELETE the key

							IF csr_get_user_key%FOUND THEN
								DELETE FROM HR_PUMP_BATCH_LINE_USER_KEYS WHERE unique_key_id =l_unique_key_id;
							 END IF;
							 CLOSE csr_get_user_key;
						/* deletion code for user key*/



						OPEN csr_get_user_key(L_ASSIGNMENT_USER_KEY);
						FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
						-- Add user key only if it does not exist previously
						IF csr_get_user_key%NOTFOUND THEN
							hr_pump_utils.add_user_key(L_ASSIGNMENT_USER_KEY,l_assignment_id);
						END IF;
						CLOSE csr_get_user_key;

						OPEN csr_get_user_key(L_ELEMENT_LINK_USER_KEY);
						FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
						-- Add user key only if it does not exist previously
						IF csr_get_user_key%NOTFOUND THEN
							hr_pump_utils.add_user_key(L_ELEMENT_LINK_USER_KEY,L_ELEMENT_LINK_ID);
						END IF;
						CLOSE csr_get_user_key;

						hrdpp_create_element_entry.insert_batch_lines
						(p_batch_id      => l_batch_id
						,p_data_pump_business_grp_name => l_bg_name
						,P_EFFECTIVE_DATE => fnd_date.canonical_to_date(p_effective_date)
						,P_ENTRY_TYPE     =>  'E'
						,P_CREATOR_TYPE   =>  'F'
						,P_ENTRY_VALUE1 => l_entry_value1
						,P_ENTRY_VALUE2 => l_entry_value2
						,P_ENTRY_VALUE3 => l_entry_value3
						,P_ENTRY_VALUE4 => l_entry_value4
						,P_ENTRY_VALUE5 => l_entry_value5
						,P_ENTRY_VALUE6 => l_entry_value6
						,P_ENTRY_VALUE7 => l_entry_value7
						,P_ENTRY_VALUE8 => l_entry_value8
						,P_ENTRY_VALUE9 => l_entry_value9
						,P_ENTRY_VALUE10 => l_entry_value10
						,P_ENTRY_VALUE11 => l_entry_value11
						,P_ENTRY_VALUE12 => l_entry_value12
						,P_ENTRY_VALUE13 => l_entry_value13
						,P_ENTRY_VALUE14 => l_entry_value14
						,P_ENTRY_VALUE15 => l_entry_value15
						,P_ELEMENT_ENTRY_USER_KEY => l_tc_ee_user_key
						,P_ASSIGNMENT_USER_KEY => L_ASSIGNMENT_USER_KEY
						,P_ELEMENT_LINK_USER_KEY => L_ELEMENT_LINK_USER_KEY
						,P_LANGUAGE_CODE =>'US'
						,P_ELEMENT_NAME => 'Tax Card'
						,P_INPUT_VALUE_NAME1 =>l_input_value_name1
						,P_INPUT_VALUE_NAME2 =>l_input_value_name2
						,P_INPUT_VALUE_NAME3 =>l_input_value_name3
						,P_INPUT_VALUE_NAME4 =>l_input_value_name4
						,P_INPUT_VALUE_NAME5 =>l_input_value_name5
						,P_INPUT_VALUE_NAME6 =>l_input_value_name6
						,P_INPUT_VALUE_NAME7 =>l_input_value_name7
						,P_INPUT_VALUE_NAME8 =>l_input_value_name8
						,P_INPUT_VALUE_NAME9 =>l_input_value_name9
						,P_INPUT_VALUE_NAME10 =>l_input_value_name10
						,P_INPUT_VALUE_NAME11 =>l_input_value_name11
						,P_INPUT_VALUE_NAME12 =>l_input_value_name12
						,P_INPUT_VALUE_NAME13 =>l_input_value_name13
						,P_INPUT_VALUE_NAME14 =>l_input_value_name14
						,P_INPUT_VALUE_NAME15 =>l_input_value_name15);

					END IF;

					hr_utility.set_location (   '  Batch Lines created  ' , 190);

					-- commit the records uppon reaching the commit point
				END IF;

				BEGIN

					OPEN csr_get_all_assg(
					p_business_group_id => p_business_group_id
					,p_ni               => l_ni
					,p_employer_org_no   => l_employer_org_no ) ;
					LOOP
						FETCH csr_get_all_assg INTO l_assignment_id;
						IF csr_get_all_assg%NOTFOUND THEN
							l_row_count := csr_get_all_assg%ROWCOUNT ;
							EXIT;
						END IF;
						 l_t_entry_value1  := NULL;
						 l_t_entry_value2  := NULL;
						 l_t_entry_value3  := NULL;
						 l_t_entry_value4  := NULL;
						 l_t_entry_value5  := NULL;
						 l_t_entry_value6  := NULL;
						 l_t_entry_value7  := NULL;
						 l_t_entry_value8  := NULL;
						 l_t_entry_value9  := NULL;
						 l_t_entry_value10 := NULL;
						 l_t_entry_value11 := NULL;
						 l_t_entry_value12 := NULL;
						 l_t_entry_value13 := NULL;
						 l_t_entry_value14 := NULL;
						 l_t_entry_value15 := NULL;

						 IF  l_employment_type = '0' AND  l_entry_value3  ='EI' THEN
							l_t_entry_value2  := 'N';

							l_t_entry_value3  := l_entry_value4;
							l_t_entry_value4  := l_entry_value5;
							l_t_entry_value5  := l_entry_value7;

						 ELSIF  l_employment_type = '1' THEN
							l_t_entry_value2  := 'Y';
							l_t_entry_value3  := NULL;
							l_t_entry_value4  := NULL;
							l_t_entry_value5  := NULL;

						 END IF;



						 l_input_value_name1  := 'Pay Value' ;
						 l_input_value_name2  := 'Primary Employment' ;
						 l_input_value_name3  := 'Extra Income Rate';
						 l_input_value_name4  := 'Extra Income Additional Rate';
						 l_input_value_name5  := 'Extra Income Limit';
						 l_input_value_name6  := 'Previous Extra Income' ;
						 l_input_value_name7  := NULL;
						 l_input_value_name8  := NULL;
						 l_input_value_name9  := NULL;
						 l_input_value_name10 := NULL;
						 l_input_value_name11 := NULL;
						 l_input_value_name12 := NULL;
						 l_input_value_name13 := NULL;
						 l_input_value_name14 := NULL;
						 l_input_value_name15 := NULL;


						 OPEN csr_get_element_details(l_assignment_id ,'Tax') ;
						 FETCH csr_get_element_details
						 INTO l_element_entry_id,l_element_name,l_effective_start_date,l_effective_end_date;
						 IF csr_get_element_details%NOTFOUND THEN
							 RAISE e_no_tax_element ;
						 END IF;
						 CLOSE csr_get_element_details;


						 hr_utility.set_location (   '  Element Entry ID = ' || l_element_entry_id, 200);
						 hr_utility.set_location (   '  Element Name = ' || l_element_name, 200);
						 hr_utility.set_location (   '  Element Entry Start Date = '||l_effective_start_date, 200);
						 hr_utility.set_location (   '  Element Entry End Date = '||l_effective_end_date, 200);


						l_element_link_id  := get_element_link_id(l_assignment_id ,p_business_group_id,p_effective_date,'Tax');

						l_t_ee_user_key  :=to_char(l_assignment_id )||to_char(l_element_link_id) ||' : ELEMENT ENTRY USER KEY';

						OPEN csr_get_user_key(l_t_ee_user_key);
						FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
						-- Add user key only if it does not exist previously
						IF csr_get_user_key%NOTFOUND THEN
							hr_pump_utils.add_user_key(l_t_ee_user_key,l_element_entry_id);
						END IF;
						CLOSE csr_get_user_key;

						hr_utility.set_location (   '  User Key added  ' , 210);

						hr_utility.set_location (   '  l_effective_start_date:' || to_char(l_effective_start_date), 220);
						hr_utility.set_location (   '  l_effective_end_date:' || to_char(l_effective_end_date), 220);
						hr_utility.set_location (   '  p_effective_date:' || to_char(fnd_date.canonical_to_date(p_effective_date)), 220);
						hr_utility.set_location (   '  c_end_of_time:' || to_char(c_end_of_time), 220);

						-- Define Datetrack Updation Mode
						IF(l_effective_start_date = fnd_date.canonical_to_date(p_effective_date))
						THEN
							l_datetrack_update_mode := 'CORRECTION';
						ELSIF(l_effective_end_date <> c_end_of_time)
						THEN
							l_datetrack_update_mode := 'UPDATE_OVERRIDE';
						ELSE
							l_datetrack_update_mode := 'UPDATE';
						END IF;

						hr_utility.set_location (   '  Datetrack Update Mode:' || l_datetrack_update_mode, 230);


						-- Data Pump procedure called to create batch lines to update element entries
						hrdpp_update_element_entry.insert_batch_lines
						(p_batch_id      => l_batch_id
						,p_data_pump_business_grp_name => l_bg_name
						,P_DATETRACK_UPDATE_MODE =>  l_datetrack_update_mode
						,P_EFFECTIVE_DATE => fnd_date.canonical_to_date(p_effective_date)
						,P_ENTRY_VALUE1 => l_t_entry_value1
						,P_ENTRY_VALUE2 => l_t_entry_value2
						,P_ENTRY_VALUE3 => l_t_entry_value3
						,P_ENTRY_VALUE4 => l_t_entry_value4
						,P_ENTRY_VALUE5 => l_t_entry_value5
						,P_ENTRY_VALUE6 => l_t_entry_value6
						,P_ENTRY_VALUE7 => l_t_entry_value7
						,P_ENTRY_VALUE8 => l_t_entry_value8
						,P_ENTRY_VALUE9 => l_t_entry_value9
						,P_ENTRY_VALUE10 => l_t_entry_value10
						,P_ENTRY_VALUE11 => l_t_entry_value11
						,P_ENTRY_VALUE12 => l_t_entry_value12
						,P_ENTRY_VALUE13 => l_t_entry_value13
						,P_ENTRY_VALUE14 => l_t_entry_value14
						,P_ENTRY_VALUE15 => l_t_entry_value15
						,P_ELEMENT_ENTRY_USER_KEY => l_t_ee_user_key
						,P_ELEMENT_NAME => l_element_name
						,P_LANGUAGE_CODE =>'US'
						,P_INPUT_VALUE_NAME1 =>l_input_value_name1
						,P_INPUT_VALUE_NAME2 =>l_input_value_name2
						,P_INPUT_VALUE_NAME3 =>l_input_value_name3
						,P_INPUT_VALUE_NAME4 =>l_input_value_name4
						,P_INPUT_VALUE_NAME5 =>l_input_value_name5
						,P_INPUT_VALUE_NAME6 =>l_input_value_name6
						,P_INPUT_VALUE_NAME7 =>l_input_value_name7
						,P_INPUT_VALUE_NAME8 =>l_input_value_name8
						,P_INPUT_VALUE_NAME9 =>l_input_value_name9
						,P_INPUT_VALUE_NAME10 =>l_input_value_name10
						,P_INPUT_VALUE_NAME11 =>l_input_value_name11
						,P_INPUT_VALUE_NAME12 =>l_input_value_name12
						,P_INPUT_VALUE_NAME13 =>l_input_value_name13
						,P_INPUT_VALUE_NAME14 =>l_input_value_name14
						,P_INPUT_VALUE_NAME15 =>l_input_value_name15);



					END LOOP;
					CLOSE csr_get_all_assg;
						IF l_row_count = 0 THEN
							 RAISE e_no_asg ;
						END IF;
				END;

				IF MOD (l_batch_seq, c_commit_point) = 0   THEN
					COMMIT;
					NULL;
				END IF;

			EXCEPTION

			WHEN e_record_too_long THEN
			--Record is too long

			-- Set retcode to 1, indicating a WARNING to the ConcMgr

				retcode := c_warning;

			       -- Set the application error
			       hr_utility.set_message (801, 'HR_376620_FI_RECORD_TOO_LONG');
			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 280);

			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)

			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

			  WHEN e_mismatch_tax_card THEN
			--Mismatch Between Employment Type and Tax card

			-- Set retcode to 1, indicating a WARNING to the ConcMgr

				retcode := c_warning;

			       -- Set the application error
			       hr_utility.set_message (801, 'HR_376621_FI_MISMATCH_TAXCARD');
			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 290);

			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)

			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
			  WHEN e_no_asg THEN
			-- No assignment for the employee

			-- Set retcode to 1, indicating a WARNING to the ConcMgr

				retcode := c_warning;

			       -- Set the application error
			       hr_utility.set_message (801, 'HR_376619_FI_NO_ASG');
			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 280);

			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)

			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);


  			  WHEN e_no_data_tax THEN
  			  --No data returned by Tax Authorities

			  -- Set retcode to 1, indicating a WARNING to the ConcMgr

				retcode := c_warning;

			       -- Set the application error
			       hr_utility.set_message (801, 'HR_376622_FI_NO_DATA_TAX');
			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 330);

			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)

			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);


  			  WHEN e_no_tax_element THEN
  			  --Tax Element not attached to Assignment

			  -- Set retcode to 1, indicating a WARNING to the ConcMgr

				retcode := c_warning;

			       -- Set the application error
			       hr_utility.set_message (801, 'HR_376623_FI_NO_TAX_ELEMENT');
			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 310);

			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)

			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
			  WHEN e_no_tax_link
			  -- Wrong CSR routine
			  THEN
			  -- Set retcode to 1, indicating a WARNING to the ConcMgr
			       retcode := c_warning;

			       -- Set the application error
			       hr_utility.set_message (801, 'HR_376624_FI_NO_TAX_CARD_LINK');
			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 320);

			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)

			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);


			END;
		END LOOP read_lines_in_file;

		-- Commit the outstanding records
		COMMIT;

		UTL_FILE.fclose (l_file_type);
		hr_utility.set_location (   'Leaving:'|| l_proc, 320);

		-- Most of these exceptions are not translated as they should not happen normally
		-- If they do happen, something is seriously wrong and SysAdmin interference will be necessary.

	EXCEPTION
		WHEN e_fatal_error   THEN
			-- No directory specified
		        -- Close the file in case of error
			IF UTL_FILE.is_open (l_file_type) THEN
				UTL_FILE.fclose (l_file_type);
			END IF;

			hr_utility.set_location (l_proc, 330);

			-- Set retcode to 2, indicating an ERROR to the ConcMgr
			retcode := c_error;

			-- Set the application error
			hr_utility.set_message (801, 'HR_FI_DATA_EXCHANGE_DIR_MIS');

			-- Return the message to the ConcMgr (This msg will appear in the log file)
			errbuf := hr_utility.get_message;

		WHEN UTL_FILE.invalid_operation  THEN
		        -- File could not be opened as requested, perhaps because of operating system permissions
		        -- Also raised when attempting a write operation on a file opened for read, or a read operation
		        -- on a file opened for write.


			IF UTL_FILE.is_open (l_file_type)  THEN
				UTL_FILE.fclose (l_file_type);
			END IF;

			hr_utility.set_location (l_proc, 340);
			retcode := c_error;
			errbuf := 'Reading File ('||l_location ||' -> '
						   || l_filename
						   || ') - Invalid Operation.';
		WHEN UTL_FILE.internal_error THEN
			-- Unspecified internal error
			IF UTL_FILE.is_open (l_file_type) THEN
				UTL_FILE.fclose (l_file_type);
			END IF;

			 hr_utility.set_location (l_proc, 350);
			 retcode := c_error;
			 errbuf :=    'Reading File ('
				   || l_location
				   || ' -> '
				   || l_filename
				   || ') - Internal Error.';

		WHEN UTL_FILE.invalid_mode THEN
		-- Invalid string specified for file mode

			 IF UTL_FILE.is_open (l_file_type)
			 THEN
			    UTL_FILE.fclose (l_file_type);
			 END IF;

			 hr_utility.set_location (l_proc, 360);
			 retcode := c_error;
			 errbuf :=    'Reading File ('
				   || l_location
				   || ' -> '
				   || l_filename
				   || ') - Invalid Mode.';

		WHEN UTL_FILE.invalid_path THEN
		-- Directory or filename is invalid or not accessible

		         IF UTL_FILE.is_open (l_file_type) THEN
				UTL_FILE.fclose (l_file_type);
			 END IF;

			 retcode := c_error;
			 errbuf :=    'Reading File ('
				   || l_location
				   || ' -> '
				   || l_filename
				   || ') - Invalid Path or Filename.';
			 hr_utility.set_location (l_proc, 370);

		WHEN UTL_FILE.invalid_filehandle       THEN
		-- File type does not specify an open file

			 IF UTL_FILE.is_open (l_file_type) THEN
			    UTL_FILE.fclose (l_file_type);
			 END IF;

			 hr_utility.set_location (l_proc, 380);
			 retcode := c_error;
			 errbuf :=    'Reading File ('
				   || l_location
				   || ' -> '
				   || l_filename
				   || ') - Invalid File Type.';

		WHEN UTL_FILE.read_error THEN
	        -- Operating system error occurred during a read operation

			 IF UTL_FILE.is_open (l_file_type)  THEN
				UTL_FILE.fclose (l_file_type);
			 END IF;

			 hr_utility.set_location (l_proc, 390);
			 retcode := c_error;
			 errbuf :=    'Reading File ('
				   || l_location
				   || ' -> '
				   || l_filename
				   || ') - Read Error.';

	END upload;



	PROCEDURE read_record
	        (
		 p_line     IN VARCHAR2
		,p_entry_value1   OUT NOCOPY VARCHAR2
		,p_entry_value2   OUT NOCOPY VARCHAR2
		,p_entry_value3   OUT NOCOPY VARCHAR2
		,p_entry_value4   OUT NOCOPY VARCHAR2
		,p_entry_value5   OUT NOCOPY VARCHAR2
		,p_entry_value6   OUT NOCOPY VARCHAR2
		,p_entry_value7   OUT NOCOPY VARCHAR2
		,p_entry_value8   OUT NOCOPY VARCHAR2
		,p_entry_value9   OUT NOCOPY VARCHAR2
		,p_entry_value10  OUT NOCOPY VARCHAR2
		,p_entry_value11  OUT NOCOPY VARCHAR2
		,p_entry_value12  OUT NOCOPY VARCHAR2
		,p_entry_value13  OUT NOCOPY VARCHAR2
		,p_entry_value14  OUT NOCOPY VARCHAR2
		,p_entry_value15  OUT NOCOPY VARCHAR2
		,p_return_value1  OUT NOCOPY VARCHAR2
		,p_return_value2  OUT NOCOPY VARCHAR2
		,p_return_value3  OUT NOCOPY VARCHAR2
		)
	IS

		l_record_length      NUMBER                                   :=4000;

		-- Procedure name
		l_proc               CONSTANT VARCHAR2 (72)                   :=    g_package|| '.read_record';

		l_tax_card_type       VARCHAR2(80);
		l_employment_type     VARCHAR2(80);
		l_one_income_limit    NUMBER;

	BEGIN

		hr_utility.set_location (   'Entering:'|| l_proc, 70);

		/*    p_entry_value1    Method of Receipt ( Not from file)
		*     p_entry_value2    Tax Municipality, 3 positions
		*     p_entry_value3    Tax Card Type, 1 position
		*     p_entry_value4    Base Rate , 3 positions , first two are actual number
		*     p_entry_value5    Additional Rate , 3 positions , first two are actual number
		*     p_entry_value6    Previous Income , ( Not from file)
		*     p_entry_value7    Yearly Income Limit , 10 positions
		*     p_entry_value8    Registration Date ( not on file )
		*     p_entry_value9    Date Returned ( not on file )
		*     p_entry_value10   Override Manual Update  ( not on file )
		*     p_entry_value11  	Lower Income Percentage
		*/

		--Set record length
		l_record_length := 140;
		hr_utility.set_location (   '  Record length:'|| l_record_length, 80);

		l_tax_card_type := substr( p_line ,72,1);
		l_one_income_limit := nvl(to_number(substr( p_line ,62,10)),0);
		l_employment_type  := substr( p_line ,51,1);

		/* Employer's ID */
		p_return_value2 := substr( p_line ,37,13);

		/* Employee's PIN */
		p_return_value1 := substr( p_line ,13,11);

		/* Employment Type */
		p_return_value3 := substr( p_line ,51,1);


		IF l_tax_card_type IN ('5','6') then

			hr_utility.set_location (   '  No Data Returned from Tax Authorities', 90);
			RAISE e_no_data_tax;

		ELSE

			p_entry_value1 := 'ET';
			p_entry_value2  := substr( p_line ,117,3);

			IF l_tax_card_type =1 then

				-- Mismatch between the Employment Type and Tax Card
				IF l_employment_type ='0' THEN
					hr_utility.set_location (   '  Mismatch in Tax Card ', 100);
					RAISE e_mismatch_tax_card;
				END IF;

				IF l_one_income_limit > 0 then
					p_entry_value3 :='C';
				ELSE
					p_entry_value3 :='P';
				END IF;


				p_entry_value4  := substr( p_line ,73,3);
				p_entry_value5  := substr( p_line ,86,3);
				p_entry_value7  := substr( p_line ,76,10);

			 ELSIF l_tax_card_type =2 then
				p_entry_value3 :='FT';
				p_entry_value4  := substr( p_line ,89,3);
			ELSIF l_tax_card_type =3 then
				-- Mismatch between the Employment Type and Tax Card
				IF l_employment_type ='1' THEN
					hr_utility.set_location (   '  Mismatch in Tax Card ', 100);
					RAISE e_mismatch_tax_card;
				END IF;
				 p_entry_value3:='EI';
				 p_entry_value4  := substr( p_line ,92,3);
				 p_entry_value5  := substr( p_line ,105,3);
				 p_entry_value7  := substr( p_line ,95,10);

			ELSIF l_tax_card_type =4 then
				 p_entry_value3:='S';

				 /*p_entry_value4  := substr( p_line ,108,9);*/
				 /* For Scaled tax Card middle income limit */
				 p_entry_value4  := substr( p_line ,111,3);

				 /* For Scaled Tax Card Lower Income limit */
				 p_entry_value11  := substr( p_line ,108,3);

			END IF;
		END IF;



		-- Error in record if it is too long according to given format
		IF (length(p_line)> l_record_length) THEN
			hr_utility.set_location (   '  Record too long', 110);
			RAISE e_record_too_long;
		END IF;

		hr_utility.set_location (   'Leaving:'|| l_proc, 120);
	END read_record;

	FUNCTION get_element_link_id
	(
	p_assignment_id      IN NUMBER
	,p_business_group_id IN NUMBER
	,p_effective_date    IN VARCHAR2
	,p_element_name pay_element_types_f.ELEMENT_NAME%TYPE
	) RETURN NUMBER
	IS

		l_element_link_id       pay_element_links_f.ELEMENT_LINK_ID%TYPE;

		CURSOR csr_get_payroll_id IS
		SELECT  payroll_id
		FROM per_all_assignments_f
		WHERE business_group_id     = p_business_group_id
		AND assignment_id	    = p_assignment_id
		AND fnd_date.canonical_to_date(p_effective_date)
		BETWEEN  effective_start_date  AND effective_end_date ;

		Cursor csr_element_link_id
		(
		p_payroll_id      IN NUMBER
		)
		IS
		SELECT element.element_link_id
		FROM pay_paywsmee_elements_lov element
		WHERE element.assignment_id = p_assignment_id
		AND  element.element_name = p_element_name
		AND (element.business_group_id = p_business_group_id
		OR (element.business_group_id is null and element.legislation_code = 'FI'))
		AND ( element.multiple_entries_allowed_flag = 'Y'
		OR (element.normal_exists = 'N'
		OR (p_payroll_id is not null
		AND ( (element.additional_entry_allowed_flag = 'Y'
		AND element.additional_exists = 'N' )
		OR (element.overridden = 'N' and element.adjusted = 'N' ))))) ;

	BEGIN

		l_element_link_id := NULL;
		FOR pay_rec IN csr_get_payroll_id
		LOOP
			OPEN csr_element_link_id(pay_rec.payroll_id ) ;
			FETCH csr_element_link_id
			INTO l_element_link_id ;
			IF csr_element_link_id%NOTFOUND THEN
				RAISE e_no_tax_link;
			END IF;
			CLOSE csr_element_link_id;
		END LOOP ;
		RETURN l_element_link_id ;
	END ;

END pay_fi_tc_dp_upload;

/
