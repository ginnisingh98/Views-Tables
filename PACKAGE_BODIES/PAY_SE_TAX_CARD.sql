--------------------------------------------------------
--  DDL for Package Body PAY_SE_TAX_CARD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_TAX_CARD" AS
/* $Header: pysetaxu.pkb 120.0 2005/05/29 08:38:59 appldev noship $ */

   -- Global package name
   g_package CONSTANT	VARCHAR2 (33) := '  pay_se_dp_upload';

   g_batch_header		VARCHAR2 (50)  ;
   g_batch_source		VARCHAR2 (50)  ;
   g_batch_comments		VARCHAR2 (100) ;

  /* name of the process , this name is used to
     do any custom validation, it defaults to TCU */

   g_process			VARCHAR2 (10)	:='TCU' ;

  /* Exceptions */

   e_wrong_csr_routine		EXCEPTION;
   e_err_in_csr 		EXCEPTION;
   e_invalid_value		EXCEPTION;
   e_record_too_long		EXCEPTION;
   e_no_tax_link		EXCEPTION;

   PRAGMA exception_init (e_invalid_value,  -1858);

   -- Global constants

   c_warning		CONSTANT	NUMBER	:= 1;
   c_error		CONSTANT	NUMBER	:= 2;
   c_end_of_time	CONSTANT	DATE	:= to_date('12/31/4712','MM/DD/YYYY');


   PROCEDURE upload(
		      errbuf			OUT NOCOPY	VARCHAR2,
		      retcode			OUT NOCOPY	NUMBER,
		      p_file_name		IN		VARCHAR2,
		      p_effective_date          IN		VARCHAR2,
		      p_business_group_id     	IN		per_business_groups.business_group_id%TYPE,
		      p_batch_name              IN		VARCHAR2 DEFAULT NULL	,
		      p_reference		IN		VARCHAR2 DEFAULT NULL
		)
	   IS
      -- Constants
      c_read_file		CONSTANT	VARCHAR2 (1)	:= 'r';
      c_max_linesize		CONSTANT	NUMBER          := 4000;
      c_commit_point		CONSTANT	NUMBER          := 20;
      c_data_exchange_dir	CONSTANT	VARCHAR2 (30)   := 'PER_DATA_EXCHANGE_DIR';

      -- Procedure name
      l_proc			CONSTANT	VARCHAR2 (72)	:=    g_package||'.upload' ;
      l_legislation_code			per_business_groups.legislation_code%TYPE;
      l_bg_name					per_business_groups.name%TYPE;

      -- File Handling variables
      l_file_type		UTL_FILE.file_type;
      l_filename		VARCHAR2 (240);
      l_location		VARCHAR2 (4000);
      l_line_read		VARCHAR2 (4000)	:= NULL;

      -- Batch Variables
      l_batch_seq		NUMBER	:= 0;
      l_batch_id		NUMBER;

      -- Parameter values to create Batch Lines
      L_EE_USER_KEY		hr_pump_batch_line_user_keys.user_key_value%type;
      L_ASSIGNMENT_USER_KEY	hr_pump_batch_line_user_keys.user_key_value%type;
      L_ELEMENT_LINK_USER_KEY	hr_pump_batch_line_user_keys.user_key_value%type;

      l_user_key_value		hr_pump_batch_line_user_keys.user_key_value%type;
      l_unique_key_id		hr_pump_batch_line_user_keys.unique_key_id%type;

      l_datetrack_update_mode	VARCHAR2(80);

      -- Variables to Read from File
      l_pin			VARCHAR2(80);
      l_employer_org_no		VARCHAR2(80);

      L_ASSIGNMENT_ID		per_all_assignments_f.assignment_id%TYPE;
      L_ELEMENT_ENTRY_ID	pay_element_entries_f.element_entry_id%TYPE;
      L_ELEMENT_LINK_ID		pay_element_links_f.ELEMENT_LINK_ID%TYPE;
      L_ELEMENT_NAME		pay_element_types_f.element_name%TYPE;

      l_effective_start_date	pay_element_entries_f.effective_start_date%TYPE;
      l_effective_end_date	pay_element_entries_f.effective_end_date%TYPE;

      l_input_value_name1	VARCHAR2(80);
      l_input_value_name2	VARCHAR2(80);
      l_input_value_name3	VARCHAR2(80);
      l_input_value_name4	VARCHAR2(80);
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

      l_entry_value1		VARCHAR2(60);
      l_entry_value2		VARCHAR2(60);
      l_entry_value3		VARCHAR2(60);
      l_entry_value4		VARCHAR2(60);
      l_entry_value5		VARCHAR2(60);
      l_entry_value6		VARCHAR2(60);
      l_entry_value7		VARCHAR2(60);
      l_entry_value8		VARCHAR2(60);
      l_entry_value9		VARCHAR2(60);
      l_entry_value10		VARCHAR2(60);
      l_entry_value11		VARCHAR2(60);
      l_entry_value12		VARCHAR2(60);
      l_entry_value13		VARCHAR2(60);
      l_entry_value14		VARCHAR2(60);
      l_entry_value15		VARCHAR2(60);


      --Flag
      l_element_link_found	VARCHAR2(30);
      l_prim_assg_found		VARCHAR2(30);

      -- Exceptions
      e_fatal_error		EXCEPTION;
      e_prim_assg_error		EXCEPTION;
      e_element_details		EXCEPTION;


      CURSOR csr_leg (v_bg_id per_business_groups.business_group_id%TYPE)
      IS
        SELECT legislation_code, name
        FROM per_business_groups
        WHERE business_group_id = v_bg_id;

      CURSOR csr_get_prim_assg
      ( p_business_group_id per_business_groups.business_group_id%TYPE
       ,p_pin per_all_people_f.national_identifier%TYPE
       )
      IS
        SELECT  PAA.ASSIGNMENT_ID
	FROM per_all_assignments_f PAA
	, per_all_people_f PAP
	, hr_soft_coding_keyflex SCL
	WHERE PAA.BUSINESS_GROUP_ID      = p_business_group_id
	AND PAP.per_information_category ='SE'
	AND PAP.NATIONAL_IDENTIFIER = p_pin
	AND PAA.PERSON_ID = PAP.PERSON_ID
	AND PAA.PRIMARY_FLAG = 'Y'
	AND PAA.soft_coding_keyflex_id = SCL.soft_coding_keyflex_id
	AND fnd_date.canonical_to_date(p_effective_date) between  PAA.EFFECTIVE_START_DATE
							 and	  PAA.EFFECTIVE_END_DATE
	AND fnd_date.canonical_to_date(p_effective_date) between  PAP.EFFECTIVE_START_DATE
							 and	  PAP.EFFECTIVE_END_DATE
	AND SCL.ENABLED_FLAG = 'Y'
	AND SCL.SEGMENT2       in
				(
					select to_char(hoi1.organization_id)
					from HR_ORGANIZATION_UNITS o1
					, HR_ORGANIZATION_INFORMATION hoi1
					, HR_ORGANIZATION_INFORMATION hoi2
					, HR_ORGANIZATION_INFORMATION hoi3
					, HR_ORGANIZATION_INFORMATION hoi4
					WHERE o1.business_group_id = p_business_group_id
					and hoi1.organization_id = o1.organization_id
					and hoi1.org_information1 = 'SE_LOCAL_UNIT'
					and hoi1.org_information_context = 'CLASS'
					and o1.organization_id = hoi2.org_information1
					and hoi2.ORG_INFORMATION_CONTEXT='SE_LOCAL_UNITS'
					and hoi2.organization_id =  hoi3.organization_id
					and hoi3.ORG_INFORMATION_CONTEXT='CLASS'
					and hoi3.org_information1 = 'HR_LEGAL_EMPLOYER'
					and hoi4.ORG_INFORMATION_CONTEXT='SE_LEGAL_EMPLOYER_DETAILS'
					and hoi4.organization_id =  hoi3.organization_id
					and fnd_date.canonical_to_date(p_effective_date) >= o1.DATE_FROM
					and fnd_date.canonical_to_date(p_effective_date) <= nvl(o1.DATE_TO, fnd_date.canonical_to_date(p_effective_date))
				)  ;

      CURSOR csr_get_element_details(
				p_assignment_id per_all_assignments_f.assignment_id%TYPE
				)
			 IS
        SELECT pee.ELEMENT_ENTRY_ID , pet.ELEMENT_NAME, pee.EFFECTIVE_START_DATE,pee.EFFECTIVE_END_DATE
	from pay_element_entries_f pee
	, pay_element_types_f pet
	, pay_element_links_f pel
	, per_all_assignments_f paa
	where pet.ELEMENT_NAME = 'Tax Card'
	and pet.legislation_code = 'SE'
	and pel.ELEMENT_TYPE_ID = pet.ELEMENT_TYPE_ID
	and pee.ELEMENT_LINK_ID = pel.ELEMENT_LINK_ID
	and paa.ASSIGNMENT_ID = pee.ASSIGNMENT_ID
	and pee.ELEMENT_TYPE_ID = pet.ELEMENT_TYPE_ID
	and pee.ASSIGNMENT_ID = p_assignment_id
	and fnd_date.canonical_to_date(p_effective_date) between	pee.EFFECTIVE_START_DATE
							 and		pee.EFFECTIVE_END_DATE
	and fnd_date.canonical_to_date(p_effective_date) between	pet.EFFECTIVE_START_DATE
							 and		pet.EFFECTIVE_END_DATE
	and fnd_date.canonical_to_date(p_effective_date) between	pel.EFFECTIVE_START_DATE
							 and		pel.EFFECTIVE_END_DATE
	and fnd_date.canonical_to_date(p_effective_date) between	paa.EFFECTIVE_START_DATE
							 and		paa.EFFECTIVE_END_DATE ;


   BEGIN

		INSERT INTO fnd_sessions(SESSION_ID , EFFECTIVE_DATE )
		VALUES(userenv('SESSIONID'),fnd_date.canonical_to_date(p_effective_date)) ;

      -- input parameters

      hr_utility.set_location('p_file_name                '||p_file_name,1);
      hr_utility.set_location('p_effective_date           '||p_effective_date,1);
      hr_utility.set_location('p_business_group_id        '||p_business_group_id,1 );
      hr_utility.set_location('p_batch_name               '||p_batch_name,1);

      hr_utility.set_location (   'Entering:' || l_proc, 10);

      OPEN csr_leg (p_business_group_id);
		FETCH csr_leg
		INTO l_legislation_code, l_bg_name;
      CLOSE csr_leg;

      hr_utility.set_location (   'Legislation = ' || l_legislation_code, 20);

      l_filename := p_file_name;
      fnd_profile.get (c_data_exchange_dir, l_location);

      hr_utility.set_location (   'Directory = ' || l_location, 30);

      IF l_location IS NULL
      THEN
         hr_utility.set_location (   'Raising I/O error = ' || l_location, 35);
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
         WHEN	VALUE_ERROR
	            -- Input line too large for buffer specified in UTL_FILE.fopen
         THEN
               IF UTL_FILE.is_open (l_file_type)
               THEN
			UTL_FILE.fclose (l_file_type);
               END IF;

               hr_utility.set_location (l_proc, 50);
               retcode := c_error;
               -- The error will mean batch_seq doesn't get upped so add 1 when
               -- reporting line
               errbuf :=    'Input line (line nr = '|| l_batch_seq + 1 || ') too large for buffer (=' || c_max_linesize  || ').';
		EXIT;
        WHEN	NO_DATA_FOUND
        THEN
               EXIT;
        END;

         hr_utility.set_location ( '  line read: ' || SUBSTR (l_line_read, 1, 40),60);

         BEGIN

		-- setting default value for element link found flag
		l_element_link_found := 'FOUND';

		read_record
			(
			 p_process	  => g_process
			,p_line		  => l_line_read
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
			,p_return_value1  => l_pin
			,p_return_value2  => l_employer_org_no
			);

	 hr_utility.set_location (   '  PIN = ' || l_pin, 130);
	 hr_utility.set_location (   '  Employer Organization Number = ' || l_employer_org_no, 140);

	OPEN csr_get_prim_assg ( p_business_group_id =>	p_business_group_id
				,p_pin               =>	l_pin		 ) ;
		FETCH csr_get_prim_assg
		INTO l_assignment_id;
		IF csr_get_prim_assg%NOTFOUND
		THEN
			hr_utility.set_location (   '  The  Employee Does not have a primary Assignment ' , 150);
			RAISE e_prim_assg_error;
		END IF;
	CLOSE csr_get_prim_assg;

 	 hr_utility.set_location (   '  assignment_id = ' || l_assignment_id, 160);

	 OPEN csr_get_element_details(l_assignment_id ) ;
		 FETCH csr_get_element_details
		 INTO l_element_entry_id,l_element_name,l_effective_start_date,l_effective_end_date;
			IF csr_get_element_details%NOTFOUND
			THEN
			--	 RAISE e_element_details;
				 l_element_link_found := 'NOT_FOUND';
			 END IF;
	 CLOSE csr_get_element_details;

	 hr_utility.set_location (   '  Element Entry ID = ' || l_element_entry_id, 170);
	 hr_utility.set_location (   '  Element Name = ' || l_element_name, 171);
	 hr_utility.set_location (   '  Element Entry Start Date = '||l_effective_start_date, 172);
	 hr_utility.set_location (   '  Element Entry End Date = '||l_effective_end_date, 173);

	 IF g_process = 'TCU' THEN

		 l_input_value_name1	:= 'Method of Receipt' ;
		 l_input_value_name2	:= 'Tax Card Type';
		 l_input_value_name3	:= 'Tax Percentage';
		 l_input_value_name4	:= 'Tax Table Number';
		 l_input_value_name5	:= 'Tax Column';
		 l_input_value_name6	:= 'Tax Free Threshold' ;
		 l_input_value_name7	:= 'Calculation Code';
		 l_input_value_name8	:= 'Calculation Sum';
		 l_input_value_name9	:= NULL;
		 l_input_value_name10	:= NULL;
		 l_input_value_name11	:= NULL;
		 l_input_value_name12	:= NULL;
		 l_input_value_name13	:= NULL;
		 l_input_value_name14	:= NULL;
		 l_input_value_name15	:= NULL;
	END IF;

	OPEN csr_get_element_details(l_assignment_id ) ;
		 FETCH	csr_get_element_details
		 INTO	l_element_entry_id,l_element_name,l_effective_start_date,l_effective_end_date;
		 IF csr_get_element_details%NOTFOUND
		 THEN
		 --RAISE e_element_details;
			 l_element_link_found := 'NOT_FOUND';
		 END IF;
	 CLOSE csr_get_element_details;

         l_element_link_id  := get_element_link_id(l_assignment_id ,p_business_group_id,p_effective_date,'Tax Card');

	 hr_utility.set_location (   '  The  Element Staus = '||l_element_link_found , 174);
	 hr_utility.set_location (   '  Element Entry ID = ' || l_element_entry_id, 175);
	 hr_utility.set_location (   '  Element Name = ' || l_element_name, 176);
	 hr_utility.set_location (   '  Element Entry Start Date = '||l_effective_start_date, 177);
	 hr_utility.set_location (   '  Element Entry End Date = '||l_effective_end_date, 178);
         hr_utility.set_location (   '  Element Link ID = ' || l_element_link_id, 180);

	 -- Add User Keys for Data Pump
	L_EE_USER_KEY		:=NULL;
	L_ASSIGNMENT_USER_KEY	:=NULL;
	L_ELEMENT_LINK_USER_KEY	:=NULL;

   IF l_element_link_found = 'FOUND' THEN

	 -- Add User Keys for Data Pump
   	l_ee_user_key		 :=to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ELEMENT ENTRY USER KEY';

	l_unique_key_id := user_key_to_id(l_ee_user_key);
	IF l_unique_key_id = 0
	THEN
		hr_pump_utils.add_user_key(l_ee_user_key,l_element_entry_id);
		hr_utility.set_location (   '  User Key added  ' , 190);
	ELSE
		hr_pump_utils.modify_user_key(l_ee_user_key,l_ee_user_key,l_element_entry_id);
		hr_utility.set_location (   '  User Key Modified  ' , 190.1);

	END IF ;

	 /* Initialize values for input value names of the seeded element */

	 hr_utility.set_location (   '  l_effective_start_date:' || to_char(l_effective_start_date), 191);
	 hr_utility.set_location (   '  l_effective_end_date:' || to_char(l_effective_end_date), 192);
	 hr_utility.set_location (   '  p_effective_date:' || to_char(fnd_date.canonical_to_date(p_effective_date)), 193);
	 hr_utility.set_location (   '  c_end_of_time:' || to_char(c_end_of_time), 194);

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

	hr_utility.set_location (   '  Datetrack Update Mode:' || l_datetrack_update_mode, 200);

	       -- Data Pump procedure called to create batch lines to update element entries
	       hrdpp_update_element_entry.insert_batch_lines
	        (
		 p_batch_id			=> l_batch_id
		,p_data_pump_business_grp_name 	=> l_bg_name
		,P_DATETRACK_UPDATE_MODE 	=> l_datetrack_update_mode
		,P_EFFECTIVE_DATE		=> fnd_date.canonical_to_date(p_effective_date)
		,P_ENTRY_VALUE1			=> l_entry_value1
		,P_ENTRY_VALUE2			=> l_entry_value2
		,P_ENTRY_VALUE3			=> l_entry_value3
		,P_ENTRY_VALUE4			=> l_entry_value4
		,P_ENTRY_VALUE5			=> l_entry_value5
		,P_ENTRY_VALUE6			=> l_entry_value6
		,P_ENTRY_VALUE7			=> l_entry_value7
		,P_ENTRY_VALUE8			=> l_entry_value8
		,P_ENTRY_VALUE9			=> l_entry_value9
		,P_ENTRY_VALUE10		=> l_entry_value10
		,P_ENTRY_VALUE11	 	=> l_entry_value11
		,P_ENTRY_VALUE12		=> l_entry_value12
		,P_ENTRY_VALUE13		=> l_entry_value13
		,P_ENTRY_VALUE14	 	=> l_entry_value14
		,P_ENTRY_VALUE15		=> l_entry_value15
		,P_ELEMENT_ENTRY_USER_KEY 	=> L_EE_USER_KEY
		,P_ELEMENT_NAME			=> L_ELEMENT_NAME
		,P_LANGUAGE_CODE		=> 'US'
		,P_INPUT_VALUE_NAME1		=> l_input_value_name1
		,P_INPUT_VALUE_NAME2		=> l_input_value_name2
		,P_INPUT_VALUE_NAME3		=> l_input_value_name3
		,P_INPUT_VALUE_NAME4		=> l_input_value_name4
		,P_INPUT_VALUE_NAME5		=> l_input_value_name5
		,P_INPUT_VALUE_NAME6		=> l_input_value_name6
		,P_INPUT_VALUE_NAME7		=> l_input_value_name7
		,P_INPUT_VALUE_NAME8		=> l_input_value_name8
		,P_INPUT_VALUE_NAME9		=> l_input_value_name9
		,P_INPUT_VALUE_NAME10		=> l_input_value_name10
		,P_INPUT_VALUE_NAME11		=> l_input_value_name11
		,P_INPUT_VALUE_NAME12		=> l_input_value_name12
		,P_INPUT_VALUE_NAME13		=> l_input_value_name13
		,P_INPUT_VALUE_NAME14		=> l_input_value_name14
		,P_INPUT_VALUE_NAME15		=> l_input_value_name15);

		hr_utility.set_location (   '  Batch Lines created for Element Updation: ' , 210);

  ELSE
	      L_EE_USER_KEY		:=to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ELEMENT ENTRY USER KEY';
	      L_ASSIGNMENT_USER_KEY	:=to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ASG USER KEY';
	      L_ELEMENT_LINK_USER_KEY	:=to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ELEM LINK USER KEY';

		/* deletion code for user key*/

	l_unique_key_id := user_key_to_id(l_ee_user_key);
	IF l_unique_key_id > 0
	THEN
		BEGIN
			hr_utility.set_location (   '  User Key deleted: ' , 201);
			DELETE FROM HR_PUMP_BATCH_LINE_USER_KEYS WHERE unique_key_id =l_unique_key_id;
		end;
	END IF ;

	/* deletion code for user key*/

	l_unique_key_id := user_key_to_id(L_ASSIGNMENT_USER_KEY);
	IF l_unique_key_id = 0
	THEN
		 hr_utility.set_location (   '  User Key Added: ' , 202);
		 hr_pump_utils.add_user_key(L_ASSIGNMENT_USER_KEY,L_ASSIGNMENT_ID);
	END IF ;

	l_unique_key_id := user_key_to_id(L_ELEMENT_LINK_USER_KEY);
	IF l_unique_key_id = 0
	THEN
		 hr_utility.set_location (   '  User Key Added: ' , 203);
		 hr_pump_utils.add_user_key(L_ELEMENT_LINK_USER_KEY,L_ELEMENT_LINK_ID);
	END IF ;

	       hrdpp_create_element_entry.insert_batch_lines
	        (p_batch_id			=> l_batch_id
		,p_data_pump_business_grp_name 	=> l_bg_name
		,P_EFFECTIVE_DATE		=> fnd_date.canonical_to_date(p_effective_date)
		,P_ENTRY_TYPE			=>  'E'
		,P_CREATOR_TYPE			=>  'F'
		,P_ENTRY_VALUE1			=> l_entry_value1
		,P_ENTRY_VALUE2			=> l_entry_value2
		,P_ENTRY_VALUE3			=> l_entry_value3
		,P_ENTRY_VALUE4			=> l_entry_value4
		,P_ENTRY_VALUE5			=> l_entry_value5
		,P_ENTRY_VALUE6			=> l_entry_value6
		,P_ENTRY_VALUE7			=> l_entry_value7
		,P_ENTRY_VALUE8			=> l_entry_value8
		,P_ENTRY_VALUE9			=> l_entry_value9
		,P_ENTRY_VALUE10		=> l_entry_value10
		,P_ENTRY_VALUE11		=> l_entry_value11
		,P_ENTRY_VALUE12		=> l_entry_value12
		,P_ENTRY_VALUE13		=> l_entry_value13
		,P_ENTRY_VALUE14		=> l_entry_value14
		,P_ENTRY_VALUE15		=> l_entry_value15
		,P_ELEMENT_ENTRY_USER_KEY	 => L_EE_USER_KEY
		,P_ASSIGNMENT_USER_KEY 		=> L_ASSIGNMENT_USER_KEY
		,P_ELEMENT_LINK_USER_KEY 	=> L_ELEMENT_LINK_USER_KEY
		,P_ELEMENT_NAME			=> 'Tax Card'
		,P_LANGUAGE_CODE		=> 'US'
		,P_INPUT_VALUE_NAME1		=> l_input_value_name1
		,P_INPUT_VALUE_NAME2		=> l_input_value_name2
		,P_INPUT_VALUE_NAME3		=> l_input_value_name3
		,P_INPUT_VALUE_NAME4		=> l_input_value_name4
		,P_INPUT_VALUE_NAME5		=> l_input_value_name5
		,P_INPUT_VALUE_NAME6		=> l_input_value_name6
		,P_INPUT_VALUE_NAME7		=> l_input_value_name7
		,P_INPUT_VALUE_NAME8		=> l_input_value_name8
		,P_INPUT_VALUE_NAME9		=> l_input_value_name9
		,P_INPUT_VALUE_NAME10		=> l_input_value_name10
		,P_INPUT_VALUE_NAME11		=> l_input_value_name11
		,P_INPUT_VALUE_NAME12		=> l_input_value_name12
		,P_INPUT_VALUE_NAME13		=> l_input_value_name13
		,P_INPUT_VALUE_NAME14		=> l_input_value_name14
		,P_INPUT_VALUE_NAME15		=> l_input_value_name15);

           hr_utility.set_location (   '  Batch Lines created for Element Creation: ' , 210);

	  END IF ;

	     hr_utility.set_location (   '  Batch Lines created  ' , 220);

            -- commit the records uppon reaching the commit point

            IF MOD (l_batch_seq, c_commit_point) = 0
            THEN
			COMMIT;
			NULL;
            END IF;
	 EXCEPTION
	     WHEN e_wrong_csr_routine
		-- Wrong CSR routine
	     THEN
		-- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		       -- Set the application error
		       hr_utility.set_message (801, 'HR_377216_SE_WRONG_CSR_ROUTINE');
		       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (801, 'LINE', l_line_read);
		       hr_utility.set_location (l_proc, 230);

		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)

		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	     WHEN e_prim_assg_error
	      -- No primary assignment found for given PIN and Organization Number
	     THEN
	        -- Close the cursor
	        IF csr_get_prim_assg%ISOPEN
		THEN
			CLOSE csr_get_prim_assg;
	        END IF;
		 -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		 -- Set the application error
		 hr_utility.set_message (801, 'HR_377217_SE_ASSG_NOT_FOUND');
		 hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
		 hr_utility.set_message_token (801, 'LINE', l_line_read);
		 hr_utility.set_location (l_proc, 240);

		 fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	     WHEN e_err_in_csr
	      -- SVARSKOD field in CSR4 reply indicates error
	     THEN
	      -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		       -- Set the application error
		       hr_utility.set_message (801, 'HR_377218_SE_ERROR_CSR_RECORD');
		       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (801, 'LINE', l_line_read);
		       hr_utility.set_location (l_proc, 250);

		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)

		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	     WHEN e_record_too_long
	      --Record is too long
	     THEN
	      -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		       -- Set the application error
		       hr_utility.set_message (801, 'HR_377215_SE_RECORD_TOO_LONG');
		       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (801, 'LINE', l_line_read);
		       hr_utility.set_location (l_proc, 260);

		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)

		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	   WHEN e_no_tax_link
	   THEN
	      -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;

		       -- Set the application error
		       hr_utility.set_message (801, 'HR_377219_SE_NO_TAX_CARD_LINK');
		       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (801, 'LINE', l_line_read);
		       hr_utility.set_location (l_proc, 255);

		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)

		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

         END;
      END LOOP read_lines_in_file;

      -- Commit the outstanding records
      COMMIT;

      UTL_FILE.fclose (l_file_type);
      hr_utility.set_location (   'Leaving:'|| l_proc, 260);

   -- Most of these exceptions are not translated as they should not happen normally
   -- If they do happen, something is seriously wrong and SysAdmin interference will be necessary.

   EXCEPTION
      WHEN e_fatal_error
      -- No directory specified
      THEN
         -- Close the file in case of error
		  IF UTL_FILE.is_open (l_file_type)
		  THEN
			   UTL_FILE.fclose (l_file_type);
		   END IF;

		 hr_utility.set_location (l_proc, 270);
		 -- Set retcode to 2, indicating an ERROR to the ConcMgr
		  retcode := c_error;

	        -- Set the application error
		 hr_utility.set_message (801, 'HR_SE_DATA_EXCHANGE_DIR_MIS');

	         -- Return the message to the ConcMgr (This msg will appear in the log file)
	         errbuf := hr_utility.get_message;

      WHEN UTL_FILE.invalid_operation
	      -- File could not be opened as requested, perhaps because of operating system permissions
	      -- Also raised when attempting a write operation on a file opened for read, or a read operation
	      -- on a file opened for write.
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
			   UTL_FILE.fclose (l_file_type);
		 END IF;

	          hr_utility.set_location (l_proc, 280);
		  retcode := c_error;
		  errbuf := 'Reading File ('||l_location ||' -> ' || l_filename  || ') - Invalid Operation.';

      WHEN UTL_FILE.internal_error
		-- Unspecified internal error
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
			UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 290);
		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Internal Error.';

      WHEN UTL_FILE.invalid_mode
      -- Invalid string specified for file mode
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 300);
		 retcode := c_error;
		 errbuf :=    'Reading File ('  || l_location  || ' -> ' || l_filename || ') - Invalid Mode.';

      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid Path or Filename.';
		 hr_utility.set_location (l_proc, 310);

      WHEN UTL_FILE.invalid_filehandle
      -- File type does not specify an open file
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 320);
		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid File Type.';
      WHEN UTL_FILE.read_error

      -- Operating system error occurred during a read operation
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 330);
		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Read Error.';
    END upload;


/* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

	PROCEDURE NAME	: READ_RECORD
	PARAMATERS	:
			 process	Process name
			 p_line		a line read from file
			 Entry values	1..15  	Out variables
					split the values in the line pass it to
					specific entry values out parameter.
	PURPOSE		: To split up the line read & return it to specific Entry values.
	ERRORS HANDLED	:
			e_err_in_csr 		error in CSR Routine.
			e_wrong_csr_routine	Wrong CSR Routine.
			e_record_too_long	When Record is Too Long.
*/

   PROCEDURE read_record
	        (p_process	  IN VARCHAR2
		,p_line		  IN VARCHAR2
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
		)
   IS
   --Variables to store the extra values read from the flat file
   	l_extra_value0		VARCHAR2(80);
   	l_extra_value1		VARCHAR2(80);
   	l_extra_value2		VARCHAR2(80);
   	l_extra_value3		VARCHAR2(80);
   	l_extra_value4		VARCHAR2(80);
   	l_extra_value5		VARCHAR2(80);
   	l_extra_value6		VARCHAR2(80);
   	l_extra_value7		VARCHAR2(80);
   	l_extra_value8		VARCHAR2(80);
   	l_record_length		NUMBER	:=4000;

   -- Procedure name
   l_proc  CONSTANT VARCHAR2 (72) :=    g_package|| '.read_record';

   BEGIN

  hr_utility.set_location (   'Entering:'|| l_proc, 70);

   IF (p_process = 'TCU') THEN

   /*     p_entry_value1    Method Of Receipt ( Not from file)
    *     p_entry_value2    Tax Card Type ( Got to get from PRELSK)
    *     p_entry_value4    TABELL, Tax table, 3 positions , first two are actual number
    *     p_entry_value3    Tax Percentage ( have to get from file )
    *     p_entry_value5    Tax Column ( not on file )
    *     p_entry_value6    Tax Free Threshold ( not on file )
    *     p_entry_value7    BERKOD, Calculation code, 1 position
    *     p_entry_value8    BERBEL, Amount for calculation, 6N.
    */

      --Set record length
      l_record_length := 73;
      hr_utility.set_location (   '  Record length:'|| l_record_length, 80);

      IF ( substr( p_line, 1,4  )= 'CSR4') THEN
          p_entry_value1 := 'ET';
	  /* Organization Number of Legal Employer */
          p_return_value2 := substr( p_line ,5,12);

	  /*EGENREF, The employers own classification of person (if used) in return, 8 positions*/
	  l_extra_value1 := substr( p_line ,17,8);

	  /* Read PIN and modify acccording to value retrieved from database */
	  /* Reading ignores century digits added in the PIN on flat file */
	  p_return_value1 := substr( p_line ,27,10);
	  p_return_value1 := to_char(substr(p_return_value1,1,6)||'-'||substr(p_return_value1,7)) ;

	  /*NAMNB, Beginning of name is changed to XYZ from 2004 for all employees, 3 positions*/
	  l_extra_value2  := substr( p_line ,37,3);
	  /*SVARSKOD, Value not zero marks an error, 1 position*/
	  l_extra_value3  := substr( p_line ,40,1);

	  hr_utility.set_location (   '  SVARSKOD:'|| l_extra_value3, 90);
	  IF to_number(l_extra_value3) <> 0
	  THEN
		 RAISE e_err_in_csr;
	  END IF;
	 /* Ignore 3rd digit in tax table number on file */
	  p_entry_value4  := substr( p_line ,47,2);     /* TABELL */

	  l_extra_value4  := substr( p_line ,50,1);     /* PRELSK */

	  IF	( l_extra_value4 = 0)
	  THEN
		p_entry_value2  := 'NTC';
	  ELSIF	( l_extra_value4 = 1)
	  THEN
	          p_entry_value2  := 'A';
	  ELSIF ( l_extra_value4 = 6)
	  THEN
		  p_entry_value2  :=  'F';
	  ELSIF ( l_extra_value4 = 8)
	  THEN
		  p_entry_value2  :=  'AF';
	  END if;

	  p_entry_value7  := substr( p_line ,51,1);    /* BERKOD */
	  p_entry_value8  := substr( p_line ,52,6);    /* BERBEL */

	  IF(to_number(p_entry_value11)<100)
	  THEN
		  p_entry_value3 := p_entry_value11;
	  END IF;

	  /*KVARLAN, not used anymore, 2 positions*/
	  l_extra_value5  := substr( p_line ,58,2);
	  /*KVARBEL, not used anymore, 7N*/
	  l_extra_value6  := substr( p_line ,60,7);
	  /*EGENREF2, 3 positions*/
	  l_extra_value7  := substr( p_line ,67,3);
	  /*RESERV, Reserved for the Tax Office, 3 positions*/
	  l_extra_value8  := substr( p_line ,70,3);

	ELSE
		hr_utility.set_location (   '  Wrong CSR routine', 100);
		RAISE e_wrong_csr_routine;
      END IF;
   END IF;

   -- Error in record if it is too long according to given format
   IF (length(p_line)> l_record_length)
   THEN
	    hr_utility.set_location (   '  Record too long', 110);
	    RAISE e_record_too_long;
   END IF;

   hr_utility.set_location (   'Leaving:'|| l_proc, 120);

   END read_record;


/* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
 	USER KEY VALUE TO KEY ID CONVERTOR FUNC()

	PROCEDURE NAME	: USER_KEY_TO_ID
	PARAMATERS	: user key value	User Key value from table hr_pump_batch_line_user_keys

	PURPOSE		: To get the User key id for that Value
	ERRORS HANDLED	: Return ZERO when no data found.

*/

FUNCTION user_key_to_id( p_user_key_value in varchar2 )
RETURN number
is
   l_id number;
BEGIN

	   select unique_key_id
	   into   l_id
	   from   hr_pump_batch_line_user_keys
	   where  user_key_value = p_user_key_value;
	   return(l_id);
EXCEPTION
	WHEN NO_DATA_FOUND
	   THEN
	   return(0);

end user_key_to_id;


/* &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&

	PROCEDURE NAME	: GET_ELEMENT_LINK_ID
	PARAMATERS	:
			 assignment id		Assgignment id for that person
			 business group id	Business group to which the person belongs
			 effective date
			 element name		Element Name for which the link id is needed

	PURPOSE		: To get the element link id for that element
	ERRORS HANDLED	: Raise Error for e_no_tax_link

*/

/* Function to get the element link ID */
FUNCTION get_element_link_id
	(
	p_assignment_id      	IN NUMBER
	,p_business_group_id 	IN NUMBER
	,p_effective_date    	IN VARCHAR2
	,p_element_name 	pay_element_types_f.ELEMENT_NAME%TYPE
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
		OR (element.business_group_id is null and element.legislation_code = 'SE'))
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
END get_element_link_id;

/* End of Package */

END pay_se_tax_card;

/
