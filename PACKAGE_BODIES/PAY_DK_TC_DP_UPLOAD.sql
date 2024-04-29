--------------------------------------------------------
--  DDL for Package Body PAY_DK_TC_DP_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_TC_DP_UPLOAD" AS
/* $Header: pydktaxu.pkb 120.6.12010000.7 2010/04/07 06:44:33 rsahai ship $ */
   g_package                CONSTANT VARCHAR2 (33) := ' pay_dk_tc_dp_upload';
   g_batch_header                    VARCHAR2 (50);
   g_batch_source                    VARCHAR2 (50);
   g_batch_comments                  VARCHAR2 (100);
   e_wrong_indvnr	        EXCEPTION;
   e_invalid_value              EXCEPTION;
   e_record_length_err	        EXCEPTION;
   e_no_tax_link		EXCEPTION;

   PRAGMA exception_init (e_invalid_value,  -1858);
   -- Global constants
   c_warning                    CONSTANT NUMBER        := 1;
   c_error                      CONSTANT NUMBER        := 2;
   c_end_of_time                CONSTANT DATE          := to_date('12/31/4712','MM/DD/YYYY');

   PROCEDURE upload(
      errbuf                     OUT NOCOPY   VARCHAR2,
      retcode                    OUT NOCOPY   NUMBER,
      p_file_name                IN           VARCHAR2,
      p_effective_date           IN	      VARCHAR2,
      p_business_group_id        IN           per_business_groups.business_group_id%TYPE,
      p_batch_name               IN           VARCHAR2 DEFAULT NULL,
      p_reference                IN           VARCHAR2 DEFAULT NULL
   )
   IS

      -- Constants
      c_read_file           CONSTANT VARCHAR2 (1)            := 'r';
      c_max_linesize        CONSTANT NUMBER                  := 4000;
      c_commit_point        CONSTANT NUMBER                  := 20;
      c_data_exchange_dir   CONSTANT VARCHAR2 (30)           := 'PER_DATA_EXCHANGE_DIR';

      -- Procedure name
      l_proc                CONSTANT VARCHAR2 (72)           :=    g_package||'.upload' ;
      l_legislation_code    per_business_groups.legislation_code%TYPE;
      l_bg_name             per_business_groups.name%TYPE;

      -- File Handling variables
      l_file_type                    UTL_FILE.file_type;
      l_filename                     VARCHAR2 (240);
      l_location                     VARCHAR2 (4000);
      l_line_read                    VARCHAR2 (4000);
      -- Batch Variables
      l_batch_seq                    NUMBER;
      l_batch_id                     NUMBER;
      l_record_length		     NUMBER;

      -- Parameter values to create Batch Lines
      l_ee_user_key                  VARCHAR2(240);
      L_ASSIGNMENT_USER_KEY          VARCHAR2(240);
      L_ELEMENT_LINK_USER_KEY        VARCHAR2(240);
      l_user_key_value               hr_pump_batch_line_user_keys.user_key_value%type;
      l_unique_key_id                hr_pump_batch_line_user_keys.unique_key_id%type;
      l_assignment_id                per_all_assignments_f.assignment_id%TYPE;
      l_datetrack_update_mode        VARCHAR2(80);

      -- Variables to Read from File
      l_cpr			     VARCHAR2(80);
      l_employer_org_no              VARCHAR2(80);
      l_effective_date		     VARCHAR2(80);
      l_element_entry_id            pay_element_entries_f.element_entry_id%TYPE;
      L_ELEMENT_LINK_ID             pay_element_links_f.ELEMENT_LINK_ID%TYPE;
      l_element_name                pay_element_types_f.element_name%TYPE;
      -- Added for Flugger fix
      l_element_name_tl             PAY_ELEMENT_TYPES_F_TL.element_name%TYPE;
      l_effective_start_date        pay_element_entries_f.effective_start_date%TYPE;
      l_effective_end_date          pay_element_entries_f.effective_end_date%TYPE;
      l_input_value_name1   	     VARCHAR2(80);
      l_input_value_name2   	     VARCHAR2(80);
      l_input_value_name3   	     VARCHAR2(80);
      l_input_value_name4   	     VARCHAR2(80);
      l_input_value_name5   	     VARCHAR2(80);
      l_input_value_name6   	     VARCHAR2(80);
      l_input_value_name7   	     VARCHAR2(80);
      l_input_value_name8   	     VARCHAR2(80);
      l_input_value_name9   	     VARCHAR2(80);
      l_input_value_name10 	     VARCHAR2(80);
      l_input_value_name11 	     VARCHAR2(80);
      l_input_value_name12 	     VARCHAR2(80);
      l_input_value_name13 	     VARCHAR2(80);
      l_input_value_name14 	     VARCHAR2(80);
      l_input_value_name15	     VARCHAR2(80);
      l_entry_value1                 VARCHAR2(60);
      l_entry_value2                 VARCHAR2(60);
      l_entry_value3                 VARCHAR2(60);
      l_entry_value4                 VARCHAR2(60);
      l_entry_value5                 VARCHAR2(60);
      l_entry_value6                 VARCHAR2(60);
      l_entry_value7                 VARCHAR2(60);
      l_entry_value8                 VARCHAR2(60);
      l_entry_value9                 VARCHAR2(60);
      l_entry_value10                VARCHAR2(60);
      l_entry_value11                VARCHAR2(60);
      l_entry_value12                VARCHAR2(60);
      l_entry_value13                VARCHAR2(60);
      l_entry_value14                VARCHAR2(60);
      l_entry_value15                VARCHAR2(60);
      l_get_indvnr		     VARCHAR2(4);
      l_le_id                        VARCHAR2(60);
      l_se_num			     VARCHAR2(60);
      l_flag			     VARCHAR2(1);
      l_end_rec_flag		     VARCHAR2(1);

      -- Exceptions
      e_fatal_error                  EXCEPTION;
      e_prim_assg_error              EXCEPTION;
      e_element_details              EXCEPTION;
      e_legal_employer_err	     EXCEPTION;
      e_file_format_err		     EXCEPTION;
      e_invalid_tax_card_type	     EXCEPTION;
      e_tax_percentage_err	     EXCEPTION;


      --Flag variables
      l_element_link_found        VARCHAR2(30);
      l_batch_name hr_pump_batch_headers.batch_name%type;

	cursor get_batch_name(p_batch_name hr_pump_batch_headers.batch_name%type) is
	select batch_name from hr_pump_batch_headers where batch_name = p_batch_name;

      CURSOR csr_leg (v_bg_id per_business_groups.business_group_id%TYPE)
      IS
        SELECT legislation_code, name
        FROM per_business_groups_perf
        WHERE business_group_id = v_bg_id;

      CURSOR csr_get_prim_assg
      ( p_business_group_id per_business_groups.business_group_id%TYPE
       ,p_cpr per_all_people_f.national_identifier%TYPE
       ,p_date per_all_assignments_f.effective_start_date%TYPE)
      IS
        SELECT  PAA.ASSIGNMENT_ID
	FROM per_all_assignments_f PAA
	, per_all_people_f PAP
	WHERE PAA.BUSINESS_GROUP_ID      = p_business_group_id
	AND PAP.per_information_category ='DK'
	AND PAP.NATIONAL_IDENTIFIER = p_cpr
	AND PAA.PERSON_ID = PAP.PERSON_ID
	AND PAA.PRIMARY_FLAG = 'Y'
	AND p_date between  PAA.EFFECTIVE_START_DATE  and PAA.EFFECTIVE_END_DATE
	AND p_date between  PAP.EFFECTIVE_START_DATE  and PAP.EFFECTIVE_END_DATE ;

      CURSOR csr_get_element_details(p_assignment_id per_all_assignments_f.assignment_id%TYPE, p_date per_all_assignments_f.effective_start_date%TYPE)
      IS
        SELECT pee.ELEMENT_ENTRY_ID , pet.ELEMENT_NAME, pee.EFFECTIVE_START_DATE,pee.EFFECTIVE_END_DATE
	from pay_element_entries_f pee
	, pay_element_types_f pet
	, pay_element_links_f pel
	, per_all_assignments_f paa
	where pet.ELEMENT_NAME = 'Tax Card'
	and pet.legislation_code = 'DK'
	and pel.ELEMENT_TYPE_ID = pet.ELEMENT_TYPE_ID
	and pee.ELEMENT_LINK_ID = pel.ELEMENT_LINK_ID
	and paa.ASSIGNMENT_ID = pee.ASSIGNMENT_ID
	and pee.ELEMENT_TYPE_ID = pet.ELEMENT_TYPE_ID
	and pee.ASSIGNMENT_ID = p_assignment_id
	and p_date between pee.EFFECTIVE_START_DATE and pee.EFFECTIVE_END_DATE
	and p_date between pet.EFFECTIVE_START_DATE and pet.EFFECTIVE_END_DATE
	and p_date between pel.EFFECTIVE_START_DATE and pel.EFFECTIVE_END_DATE
	and p_date between paa.EFFECTIVE_START_DATE and paa.EFFECTIVE_END_DATE ;

       CURSOR csr_get_user_key(p_user_key_value hr_pump_batch_line_user_keys.user_key_value%type)
       IS
         SELECT user_key_value, unique_key_id
	 FROM   hr_pump_batch_line_user_keys
	 WHERE  user_key_value = p_user_key_value;

      CURSOR csr_get_legal_employer(v_bg_id per_business_groups.business_group_id%TYPE)
      IS
        SELECT hoi.org_information1, hoi.org_information5
	FROM hr_organization_units hru, hr_organization_information hoi
        WHERE business_group_id = v_bg_id
	and hru.organization_id = hoi.organization_id
        and hoi.ORG_INFORMATION_CONTEXT = 'DK_LEGAL_ENTITY_DETAILS';

	rg_csr_get_legal_employer csr_get_legal_employer%rowtype;

       BEGIN
          -- Initialise Variables
	  l_line_read      := NULL;
	  l_batch_seq      := 0;
	  l_record_length  := 159;
	  -- FILE FORMAT CHECK
	  l_filename := p_file_name;
          fnd_profile.get (c_data_exchange_dir, l_location);
          hr_utility.set_location (   'Directory = ' || l_location, 30);
         IF l_location IS NULL THEN
             -- error : I/O directory not defined
		RAISE e_fatal_error;
         END IF;
         -- Open flat file
	 -- Bug fixes 4216001 and 4216029
         l_file_type := UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);
         l_end_rec_flag := 'N';
	 <<file_format_check>>
        LOOP
           BEGIN
                UTL_FILE.get_line (l_file_type, l_line_read);
                l_batch_seq :=   l_batch_seq + 1;
            EXCEPTION
                     WHEN VALUE_ERROR THEN
			     IF UTL_FILE.is_open (l_file_type) THEN
				UTL_FILE.fclose (l_file_type);
			     END IF;
			     hr_utility.set_location (l_proc, 300);
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
		     WHEN NO_DATA_FOUND THEN
				EXIT;
          END;
	  l_get_indvnr := substr(l_line_read,1,4);
	  if l_batch_seq = 1 AND l_get_indvnr <> '0607' then
		RAISE e_file_format_err;
	  end if;
	  if l_get_indvnr ='0607' and l_batch_seq <> 1 then
	  	RAISE e_file_format_err;
	  end if;


	  l_flag := 'N';
	  --tax_rec_count = 0;
	  if l_get_indvnr = '0607' then
		OPEN csr_get_legal_employer(p_business_group_id);
                IF csr_get_legal_employer%NOTFOUND THEN
		     hr_utility.set_location (   '  The  Employee Does not have a primary Assignment ' , 60);
		     RAISE e_legal_employer_err;
	        END IF;
		LOOP
		    fetch csr_get_legal_employer into rg_csr_get_legal_employer;
		    l_le_id := rg_csr_get_legal_employer.org_information1;
		    l_se_num := rg_csr_get_legal_employer.org_information5;
--		    fnd_file.put_line (fnd_file.LOG,'l_le_id :'||l_le_id||' l_se_num : '||l_se_num);
		    EXIT WHEN csr_get_legal_employer%NOTFOUND;
	            IF l_le_id = substr(l_line_read,75,8) OR l_se_num = substr(l_line_read,75,8) then  -- included validation for SE num
	               l_flag := 'Y';
	            END IF;
	        END LOOP;
		CLOSE csr_get_legal_employer;
		if l_flag = 'N' then
		    RAISE e_legal_employer_err;
	        end if;
	  end if;

	  if l_get_indvnr = '0619' then
	     l_end_rec_flag := 'Y';
	     if to_number(substr(l_line_read,112,5)) <> l_batch_seq then
 	        RAISE e_file_format_err;
	     end if;
		begin
			UTL_FILE.get_line (l_file_type, l_line_read);
		exception
		 when NO_DATA_FOUND then
		     NULL;


		 when others then
		     -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_error;
		 -- Set the application error
		 hr_utility.set_message (801, 'PAY_377021_DK_INVALID_FILE_FMT');
		 hr_utility.set_location (l_proc, 120);
		 fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
		 end;

	  end if;
   END LOOP file_format_check;
      -- Commit the outstanding records

      --COMMIT;


      UTL_FILE.fclose (l_file_type);

      if l_end_rec_flag = 'N' then
        fnd_file.put_line (fnd_file.LOG,'end record error');
	raise e_file_format_err;
      end if;

	  -- END OF FILE FORMAT CHECK

 	 -- End of Bug fixes 4216001 and 4216029


	  INSERT INTO fnd_sessions(SESSION_ID, EFFECTIVE_DATE)
		VALUES(userenv('SESSIONID'),fnd_date.canonical_to_date(p_effective_date)) ;

	  hr_utility.set_location('p_file_name                '||p_file_name,1);
          hr_utility.set_location('p_effective_date           '||p_effective_date,1);
          hr_utility.set_location('p_business_group_id        '||p_business_group_id,1 );
          hr_utility.set_location('p_batch_name               '||p_batch_name,1);
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

	l_batch_seq := 0;
        <<read_lines_in_file>>
        LOOP
           BEGIN
                UTL_FILE.get_line (l_file_type, l_line_read);
                l_batch_seq :=   l_batch_seq + 1;
                EXCEPTION
                     WHEN VALUE_ERROR THEN
			     IF UTL_FILE.is_open (l_file_type) THEN
				UTL_FILE.fclose (l_file_type);
			     END IF;
			     hr_utility.set_location (l_proc, 300);
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
		     WHEN NO_DATA_FOUND THEN
				EXIT;
         END;

	 hr_utility.set_location ( '  line read: '
            || SUBSTR (l_line_read, 1, 44),50);

	 BEGIN
              -- setting defualt value for element link found flag
              l_element_link_found := 'FOUND';
--	      fnd_file.put_line (fnd_file.LOG,'Line - before parsing it : '||l_line_read);
	      if substr(l_line_read,1,4) = '0608' then -- tax record
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
		,p_return_value1  => l_cpr
		,p_return_value2  => l_employer_org_no
		,p_return_value3  => l_effective_date);

	     hr_utility.set_location (   '  CPR Number = ' || l_cpr, 60);
	     hr_utility.set_location (   '  Employer Organization Number = ' || l_employer_org_no, 60);

	     --fnd_file.put_line (fnd_file.LOG,'Read the record 0608');

	     if l_entry_value2 NOT IN ('H','B','F','NTC') then
		     raise e_invalid_tax_card_type;
	     end if;

	     if l_entry_value2 IN ('H','B') then
		if fnd_number.CANONICAL_TO_NUMBER(l_entry_value3) <=0 then
		    raise e_tax_percentage_err;
		end if;
	     end if;

	     if l_entry_value2 = 'F' then
		if fnd_number.CANONICAL_TO_NUMBER(l_entry_value3) < 0 then
		    raise e_tax_percentage_err;
		end if;
	     end if;

--	     fnd_file.put_line (fnd_file.LOG,'CPR number : '||l_cpr);
--	     fnd_file.put_line (fnd_file.LOG,'p_effective_date : '||p_effective_date);

	     OPEN csr_get_prim_assg
             ( p_business_group_id => p_business_group_id
             ,p_cpr               => l_cpr
	     ,p_date              => to_date(l_effective_date,'yyyymmdd')) ;
	     FETCH csr_get_prim_assg INTO l_assignment_id;
	     IF csr_get_prim_assg%NOTFOUND THEN
		 hr_utility.set_location (   '  The  Employee Does not have a primary Assignment ' , 60);
		 RAISE e_prim_assg_error;
	     END IF;
	     CLOSE csr_get_prim_assg;

--		fnd_file.put_line(fnd_file.LOG,'Debug 1');

		 /* Initialize values for input value names of the seeded element */
		 l_input_value_name1  := 'Method of Receipt';
		 l_input_value_name2  := 'Tax Card Type';
		 l_input_value_name3  := 'Tax Percentage';
		 l_input_value_name4  := 'Tax Free Threshold';
		 l_input_value_name5  := 'Monthly Tax Deduction';
		 l_input_value_name6  := 'Bi Weekly Tax Deduction';
		 l_input_value_name7  := 'Weekly Tax Deduction';
		 l_input_value_name8  := 'Daily Tax Deduction';
		 l_input_value_name9  := 'Tax Card Requisition Status';
		 l_input_value_name10 := NULL;
		 l_input_value_name11 := NULL;
		 l_input_value_name12 := NULL;
		 l_input_value_name13 := NULL;
		 l_input_value_name14 := NULL;
		 l_input_value_name15 := NULL;

		 /* Fix for Flugger - starts */

		   select tl.name
		   into l_input_value_name1
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name1
		   and tl.language ='US';

		 --fnd_file.put_line(fnd_file.LOG,'Debug14_1');

		   select tl.name
		   into l_input_value_name2
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name2
		   and tl.language ='US';

		 --fnd_file.put_line(fnd_file.LOG,'Debug14_2');

		   select tl.name
		   into l_input_value_name3
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name3
		   and tl.language ='US';

		 --fnd_file.put_line(fnd_file.LOG,'Debug14_3');
		   select tl.name
		   into l_input_value_name4
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name4
		   and tl.language ='US';

		 --fnd_file.put_line(fnd_file.LOG,'Debug14_4');
		   select tl.name
		   into l_input_value_name5
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name5
		   and tl.language ='US';

		 --fnd_file.put_line(fnd_file.LOG,'Debug14_5');
		   select tl.name
		   into l_input_value_name6
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name6
		   and tl.language ='US';

		 --fnd_file.put_line(fnd_file.LOG,'Debug14_6');
		   select tl.name
		   into l_input_value_name7
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name7
		   and tl.language ='US';

		   select tl.name
		   into l_input_value_name8
		   from pay_input_values_f_tl tl, pay_input_values_f t
		   where t.input_value_id = tl.input_value_id
		   and t.legislation_code ='DK'
		   and t.name = l_input_value_name8
		   and tl.language ='US';
		 /* Fix for Flugger - ends*/

		-- fnd_file.put_line(fnd_file.LOG,' l_assignment_id : '||l_assignment_id);

	    --fnd_file.put_line(fnd_file.LOG,'bfore getting element details...');

	    OPEN csr_get_element_details(l_assignment_id, to_date(l_effective_date,'yyyymmdd'));
	    FETCH csr_get_element_details
	    INTO l_element_entry_id,l_element_name,l_effective_start_date,l_effective_end_date;
	    IF csr_get_element_details%NOTFOUND THEN
		 l_element_link_found := 'NOT_FOUND';
	    END IF;
	    CLOSE csr_get_element_details;

	    --Added for Flugger fix
	           select ELEMENTTL.element_name
		   into l_element_name_tl
		   from PAY_ELEMENT_TYPES_F_TL ELEMENTTL, PAY_ELEMENT_TYPES_F ELEMENT
		   where ELEMENT.ELEMENT_TYPE_ID = ELEMENTTL.ELEMENT_TYPE_ID
		   and ELEMENT.LEGISLATION_CODE ='DK'
		   and ELEMENT.ELEMENT_NAME = 'Tax Card'
		   AND ELEMENTTL.LANGUAGE = USERENV('LANG');

                   select ELEMENTTL.element_name
                   into l_element_name
                   from PAY_ELEMENT_TYPES_F_TL ELEMENTTL, PAY_ELEMENT_TYPES_F ELEMENT
                   where ELEMENT.ELEMENT_TYPE_ID = ELEMENTTL.ELEMENT_TYPE_ID
                   and ELEMENT.LEGISLATION_CODE ='DK'
                   and ELEMENT.ELEMENT_NAME = 'Tax Card'
                   AND ELEMENTTL.LANGUAGE = 'US';

	    --fnd_file.put_line(fnd_file.LOG,'l_effective_date : '||l_effective_date);
	    --fnd_file.put_line(fnd_file.LOG,'Before calling get_element_link_id');
            -- Modified for Flugger fix
	    l_element_link_id  := get_element_link_id(l_assignment_id, p_business_group_id, to_date(l_effective_date,'yyyymmdd'), l_element_name_tl);
		 hr_utility.set_location (   '  The  Element Staus = '||l_element_link_found , 70);
		 hr_utility.set_location (   '  Element Entry ID = ' || l_element_entry_id, 70);
		 hr_utility.set_location (   '  Element Name = ' || l_element_name, 70);
		 hr_utility.set_location (   '  Element Entry Start Date = '||l_effective_start_date, 70);
		 hr_utility.set_location (   '  Element Entry End Date = '||l_effective_end_date, 70);
		 hr_utility.set_location (   '  Element Link ID = ' || l_element_link_id, 70);

	   -- Add User Keys for Data Pump
	   l_ee_user_key:=NULL;
  	   L_ASSIGNMENT_USER_KEY:=NULL;
	   L_ELEMENT_LINK_USER_KEY:=NULL;

--	   fnd_file.put_line(fnd_file.LOG,'l_element_link_id : '||l_element_link_id);
	   IF l_element_link_found = 'FOUND' THEN
                 l_ee_user_key	:= to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ELEMENT ENTRY USER KEY';
	         OPEN csr_get_user_key(l_ee_user_key);
	         FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
		 -- Add user key only if it does not exist previously

		 IF csr_get_user_key%NOTFOUND THEN
			hr_pump_utils.add_user_key(l_ee_user_key,l_element_entry_id);
		    hr_utility.set_location (   '  User Key added  ' , 190);
		 ELSE
		       hr_pump_utils.modify_user_key(l_ee_user_key,l_ee_user_key,l_element_entry_id);
		       hr_utility.set_location (   '  User Key modified  ' , 190.1);
		 END IF;

		 CLOSE csr_get_user_key;
		 hr_utility.set_location (   '  User Key added  ' , 80);
		 hr_utility.set_location (   '  l_effective_start_date:' || to_char(l_effective_start_date), 90);
		 hr_utility.set_location (   '  l_effective_end_date:' || to_char(l_effective_end_date), 90);
		 hr_utility.set_location (   '  p_effective_date:' || to_char(fnd_date.canonical_to_date(p_effective_date)), 90);
		 hr_utility.set_location (   '  c_end_of_time:' || to_char(c_end_of_time), 90);

		 -- Define Datetrack Updation Mode
		 IF(l_effective_start_date = to_date(l_effective_date,'yyyymmdd')) THEN
			 l_datetrack_update_mode := 'CORRECTION';
		 ELSIF(l_effective_end_date <> c_end_of_time) THEN
			 l_datetrack_update_mode := 'UPDATE_OVERRIDE';
		 ELSE
			 l_datetrack_update_mode := 'UPDATE';
		 END IF;

		 --fnd_file.put_line(fnd_file.LOG,'l_datetrack_update_mode : '||l_datetrack_update_mode);

		 hr_utility.set_location (   '  Datetrack Update Mode:' || l_datetrack_update_mode, 90);
	         -- Data Pump procedure called to create batch lines to update element entries
		 -- Bug fix 4215700
	         hrdpp_update_element_entry.insert_batch_lines
	        (p_batch_id      => l_batch_id
		,p_data_pump_business_grp_name => l_bg_name
		,P_DATETRACK_UPDATE_MODE =>  l_datetrack_update_mode
		,P_EFFECTIVE_DATE => fnd_date.canonical_to_date(l_effective_date)
		,P_ENTRY_VALUE1 => l_entry_value1
		,P_ENTRY_VALUE2 => l_entry_value2
		,P_ENTRY_VALUE3 => l_entry_value3
		,P_ENTRY_VALUE4 => l_entry_value4
		,P_ENTRY_VALUE5 => l_entry_value5
		,P_ENTRY_VALUE6 => l_entry_value6
		,P_ENTRY_VALUE7 => l_entry_value7
		,P_ENTRY_VALUE8 => l_entry_value8
		,P_ENTRY_VALUE9 => l_entry_value9
		,P_ENTRY_VALUE10 => NULL
		,P_ENTRY_VALUE11 => NULL
		,P_ENTRY_VALUE12 => NULL
		,P_ENTRY_VALUE13 => NULL
		,P_ENTRY_VALUE14 => NULL
		,P_ENTRY_VALUE15 => NULL
		,P_ELEMENT_ENTRY_USER_KEY => l_ee_user_key
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

		-- fnd_file.put_line (fnd_file.LOG,'After hrdpp_update_element_entry.insert_batch_lines 1');
		-- End Bug fix 4215700
              hr_utility.set_location (   '  Batch Lines created for Element Updation: ' , 100);
	ELSE

--   	    fnd_file.put_line(fnd_file.LOG,'debug else1 ');

	    l_ee_user_key		 :=to_char(l_assignment_id )||to_char(L_ELEMENT_LINK_ID) ||' : ELEMENT ENTRY USER KEY';
            L_ASSIGNMENT_USER_KEY      :=to_char(l_assignment_id )||' : ASG USER KEY';
            L_ELEMENT_LINK_USER_KEY	 :=to_char(L_ELEMENT_LINK_ID) ||' : ELEM LINK USER KEY';
		/* deletion code for user key*/
		OPEN csr_get_user_key(l_ee_user_key);
		FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
		--DELETE the key
		IF csr_get_user_key%FOUND THEN
			begin
				DELETE FROM HR_PUMP_BATCH_LINE_USER_KEYS WHERE unique_key_id =l_unique_key_id;
			end;
		END IF;
		CLOSE csr_get_user_key;

   	        --fnd_file.put_line(fnd_file.LOG,'debug else2 ');
		OPEN csr_get_user_key(L_ASSIGNMENT_USER_KEY);
		FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
		-- Add user key only if it does not exist previously
		IF csr_get_user_key%NOTFOUND THEN
			hr_pump_utils.add_user_key(L_ASSIGNMENT_USER_KEY,l_assignment_id);
		END IF;
		CLOSE csr_get_user_key;

   	        --fnd_file.put_line(fnd_file.LOG,'debug else3 ');
		OPEN csr_get_user_key(L_ELEMENT_LINK_USER_KEY);
		FETCH csr_get_user_key INTO l_user_key_value,l_unique_key_id;
		-- Add user key only if it does not exist previously
		IF csr_get_user_key%NOTFOUND THEN
			hr_pump_utils.add_user_key(L_ELEMENT_LINK_USER_KEY,L_ELEMENT_LINK_ID);
		END IF;
		CLOSE csr_get_user_key;

   	        --fnd_file.put_line(fnd_file.LOG,'debug else4 ');
		 -- Bug fix 4215700
	        hrdpp_create_element_entry.insert_batch_lines
	        (p_batch_id      => l_batch_id
		,p_data_pump_business_grp_name => l_bg_name
		,P_EFFECTIVE_DATE => fnd_date.canonical_to_date(l_effective_date)
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
		,P_ENTRY_VALUE10 => NULL
		,P_ENTRY_VALUE11 => NULL
		,P_ENTRY_VALUE12 => NULL
		,P_ENTRY_VALUE13 => NULL
		,P_ENTRY_VALUE14 => NULL
		,P_ENTRY_VALUE15 => NULL
		,P_ELEMENT_ENTRY_USER_KEY => l_ee_user_key
		,P_ASSIGNMENT_USER_KEY => L_ASSIGNMENT_USER_KEY
		,P_ELEMENT_LINK_USER_KEY => L_ELEMENT_LINK_USER_KEY
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
		 -- End Bug fix 4215700
                hr_utility.set_location (   '  Batch Lines created for Element Creation: ' , 100);

--		fnd_file.put_line (fnd_file.LOG,'After hrdpp_update_element_entry.insert_batch_lines 2');
           END IF;
	   hr_utility.set_location (   '  Batch Lines created  ' , 100);
           -- commit the records uppon reaching the commit point
           IF MOD (l_batch_seq, c_commit_point) = 0 THEN
	         COMMIT;
                 NULL;
           END IF;
	elsif  substr(l_line_read,1,4) = '0607' OR  substr(l_line_read,1,4) = '0619' then -- tax record
		hr_utility.set_location (   '  header or footer ' , 100);
		null;
	else
		raise e_wrong_indvnr;
	end if;

	 EXCEPTION
	 WHEN e_wrong_indvnr THEN
		-- Wrong INDVNR
		-- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;
		       -- Set the application error
		       hr_utility.set_message (801, 'PAY_377015_DK_WRONG_INDVNR');
		       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (801, 'LINE', l_line_read);
		       hr_utility.set_location (l_proc, 110);
		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)
		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	     WHEN e_prim_assg_error THEN
	      -- No primary assignment found for given CPR Number and CVR Number
	      -- Close the cursor
	        IF csr_get_prim_assg%ISOPEN THEN
			CLOSE csr_get_prim_assg;
	        END IF;
		 -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;
		 -- Set the application error
		 hr_utility.set_message (801, 'PAY_377016_DK_ASSG_NOT_FOUND');
		 hr_utility.set_message_token (801, 'LINE_N0', l_batch_seq);
		 hr_utility.set_message_token (801, 'LINE', l_line_read);
		 hr_utility.set_location (l_proc, 120);
		 fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	     WHEN e_record_length_err THEN
	      --Record is too long
	      -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;
		       -- Set the application error
		       hr_utility.set_message (801, 'PAY_377017_DK_RECORD_LEN_ERR');
		       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
		       hr_utility.set_message_token (801, 'LINE', l_line_read);
		       hr_utility.set_message_token (801, 'RECLEN', l_record_length);
		       hr_utility.set_location (l_proc, 150);
		       -- Write the message to log file, do not raise an application error but continue
		       -- (with next line)
		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	      WHEN e_no_tax_link THEN
			  -- Wrong CSR routine
			  -- Set retcode to 1, indicating a WARNING to the ConcMgr
			       retcode := c_warning;
			       -- Set the application error
			       hr_utility.set_message (801, 'PAY_377019_DK_TAX_CARD_LINK');
       			       hr_utility.set_message_token (801, 'CPRNO', l_cpr);
			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 320);
			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)
			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

        	 -- Bug fixes 4216001 and 4216029
		WHEN e_invalid_tax_card_type THEN
			  -- Wrong CSR routine
			  -- Set retcode to 1, indicating a WARNING to the ConcMgr
			       retcode := c_warning;
			       -- Set the application error
			       hr_utility.set_message (801, 'PAY_377022_DK_TAX_CARD_TYPE_E');
       			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 320);
			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)
			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

		WHEN e_tax_percentage_err THEN
			  -- Wrong CSR routine
			  -- Set retcode to 1, indicating a WARNING to the ConcMgr
			       retcode := c_warning;
			       -- Set the application error
			       hr_utility.set_message (801, 'PAY_377023_DK_TAX_PERCENTAGE_E');
       			       hr_utility.set_message_token (801, 'LINE_NO', l_batch_seq);
			       hr_utility.set_message_token (801, 'LINE', l_line_read);
			       hr_utility.set_location (l_proc, 320);
			       -- Write the message to log file, do not raise an application error but continue
			       -- (with next line)
			       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);


		WHEN others THEN
		 -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_warning;
		 -- Set the application error
		 fnd_file.put_line (fnd_file.LOG, SQLERRM);
		 hr_utility.set_message (801, 'PAY_377025_DK_INVALID_LINE');
		 hr_utility.set_message_token (801, 'LINE_N0', l_batch_seq);
		 hr_utility.set_message_token (801, 'LINE', l_line_read);
		 hr_utility.set_location (l_proc, 120);
		 fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	 -- end of Bug fixes 4216001 and 4216029

	 END;
      END LOOP read_lines_in_file;
      -- Commit the outstanding records

      COMMIT;
      UTL_FILE.fclose (l_file_type);
      hr_utility.set_location (   'Leaving:'|| l_proc, 200);
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
         hr_utility.set_location (l_proc, 210);
         -- Set retcode to 2, indicating an ERROR to the ConcMgr
         retcode := c_error;
         -- Set the application error
         hr_utility.set_message (801, 'PAY_377020_DK_DATA_EXC_DIR_MIS');
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
         hr_utility.set_location (l_proc, 220);
         retcode := c_error;
         errbuf := 'Reading File ('||l_location ||' -> '
                                   || l_filename
                                   || ') - Invalid Operation.';

      WHEN UTL_FILE.internal_error
      -- Unspecified internal error
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;
         hr_utility.set_location (l_proc, 230);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Internal Error.';

      WHEN UTL_FILE.invalid_mode
      -- Invalid string specified for file mode
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;
         hr_utility.set_location (l_proc, 240);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid Mode.';

      WHEN UTL_FILE.invalid_path
      -- Directory or filename is invalid or not accessible
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid Path or Filename.';
         hr_utility.set_location (l_proc, 250);

      WHEN UTL_FILE.invalid_filehandle
      -- File type does not specify an open file
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;
         hr_utility.set_location (l_proc, 260);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Invalid File Type.';

      WHEN UTL_FILE.read_error
      -- Operating system error occurred during a read operation
      THEN
         IF UTL_FILE.is_open (l_file_type)
         THEN
            UTL_FILE.fclose (l_file_type);
         END IF;
         hr_utility.set_location (l_proc, 270);
         retcode := c_error;
         errbuf :=    'Reading File ('
                   || l_location
                   || ' -> '
                   || l_filename
                   || ') - Read Error.';

	WHEN e_legal_employer_err THEN
		IF csr_get_legal_employer%ISOPEN THEN
			CLOSE csr_get_legal_employer;
	        END IF;
		 -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_error;
		 -- Set the application error
		 hr_utility.set_message (801, 'PAY_377024_DK_LEGAL_EMPLOYER_E');
		 hr_utility.set_location (l_proc, 120);
		 fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);

	WHEN e_file_format_err THEN
		 -- Set retcode to 1, indicating a WARNING to the ConcMgr
		       retcode := c_error;
		 -- Set the application error
		 hr_utility.set_message (801, 'PAY_377021_DK_INVALID_FILE_FMT');
		 hr_utility.set_location (l_proc, 120);
		 fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
    END upload;


   PROCEDURE read_record
	        (p_line     IN VARCHAR2
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

   --Variables to store the extra values read from the flat file
   l_extra_value0       VARCHAR2(80);
   l_extra_value1	VARCHAR2(80);
   l_extra_value2	VARCHAR2(80);
   l_extra_value3	VARCHAR2(80);
   l_extra_value4	VARCHAR2(80);
   l_extra_value5	VARCHAR2(80);
   l_record_length      NUMBER :=4000;
   l_indvnr		VARCHAR2(4);
   -- Procedure name
   l_proc               CONSTANT VARCHAR2 (72)                   :=    g_package|| '.read_record';
   l_line VARCHAR2(200);  --9543947

   BEGIN
   hr_utility.set_location (   'Entering:'|| l_proc, 10);
   /*     p_entry_value1    Method Of Receipt ( Not from file)
    *     p_return_value1   CPR Number (21-30) Appended to have a hiphen
    *	  p_return_value2   CVR Number
    *     p_entry_value2    Tax Card Type
    *     p_entry_value3    Income Tax Percentage
    *     p_entry_value4    Tax Free Threshold
    *     p_entry_value5    Monthly Tax Deduction
    *     p_entry_value6    Bi Weekly Tax Deduction
    *     p_entry_value7    Weekly Tax Deduction
    *     p_entry_value8    Daily Tax Deduction
    */
      --Set record length
      l_record_length := 159;
      hr_utility.set_location (   '  Record length:'|| l_record_length, 20);
      l_indvnr := substr( p_line, 1,4);
      IF l_indvnr = '0608' THEN
          p_entry_value1 := 'ET';
	  /* CVR Number of legal emp */
          p_return_value2 := substr( p_line ,15,8);
	  /* Read CPR Number and modify acccording to value retrieved from database */
	  p_return_value1 := substr( p_line ,5,10);
	  p_return_value1 := to_char(substr(p_return_value1,1,6)||'-'||substr(p_return_value1,7));
	  p_return_value3 := substr( p_line, 31,8);     /* Tax card valid from */
	  p_entry_value2  := substr( p_line ,47,1);     /* Tax Card Type */
	  -- Changing from number to type of the card
	     /*
		0 - No tax card
		2 - Main Tax card (H card)
		3 - Free Tax card (F card)
		4 - Secondary Tax card (B card)
	     */

	  IF(p_entry_value2='0') THEN
		p_entry_value2:='NTC';

	  ELSIF (p_entry_value2='2') THEN
		p_entry_value2:='H';

	  ELSIF (p_entry_value2='3') THEN
		p_entry_value2:='F';

	  ELSIF (p_entry_value2='4') THEN
		p_entry_value2:='B';

	  END IF;

	  p_entry_value3  := substr( p_line ,52,3);     /* Income Tax Percentage */
	  p_entry_value4  := substr( p_line ,55,9);     /* Max amount for F tax card */
	  p_entry_value5  := substr( p_line ,91,9);     /* Monthly Tax Deduction */
  	  p_entry_value6  := substr( p_line ,82,9);     /* Bi Weekly Tax Deduction */
  	  p_entry_value7  := substr( p_line ,73,9);     /* Weekly Tax Deduction */
	  p_entry_value8  := substr( p_line ,64,9);     /* Daily Tax Deduction */
	  --p_entry_value9 := substr( p_line ,150,7);    /* Serial number for e-Tax card */
	  p_entry_value9  := 'UPLOAD COMPLETE';

	  -- Considering the last two digits as decimal digits.
--	  p_entry_value3  := fnd_number.CANONICAL_TO_NUMBER(p_entry_value3)/100;
                             /* Commented for bug fix 7684343
	  p_entry_value4  := fnd_number.CANONICAL_TO_NUMBER(p_entry_value4)/100;
	  p_entry_value5  := fnd_number.CANONICAL_TO_NUMBER(p_entry_value5)/100;
	  p_entry_value6  := fnd_number.CANONICAL_TO_NUMBER(p_entry_value6)/100;
	  p_entry_value7  := fnd_number.CANONICAL_TO_NUMBER(p_entry_value7)/100;
	  p_entry_value8  := fnd_number.CANONICAL_TO_NUMBER(p_entry_value8)/100;*/

    ELSIF l_indvnr = '0607' OR l_indvnr = '0619' THEN
	    null;
    ELSE
	    hr_utility.set_location ('Wrong Tax Record', 40);
	    RAISE e_wrong_indvnr;
    END IF;

--   fnd_file.put_line (fnd_file.LOG,'Line read : '||p_line);
--   fnd_file.put_line (fnd_file.LOG,'Line Length  : '||length(p_line));

	--9543947
	IF ASCII(substr( p_line ,160,1)) = '13' THEN
	  l_line := substr(p_line,1,159);
	ELSE
	  l_line := p_line;
	END IF;
	--9543947

   -- Error in record if it is too long according to given format
   --IF (length(p_line) <> l_record_length) THEN  --9543947
   IF (length(l_line) <> l_record_length) THEN    --9543947
	hr_utility.set_location (   '  Record too long', 50);
	RAISE e_record_length_err;
   END IF;
 /*
   hr_utility.set_location (   '  Tax Municipality:'|| p_entry_value2, 65);
   hr_utility.set_location (   '  Tax Table Number:'|| p_entry_value3, 66);
   hr_utility.set_location (   '  Tax Table Type:'|| p_entry_value4, 67);
   hr_utility.set_location (   '  Tax Percentage:'|| p_entry_value5, 68);
   hr_utility.set_location (   '  Tax Card Type:'|| p_entry_value6, 69);


   fnd_file.put_line (fnd_file.LOG,'Tax card type : '||p_entry_value2);
   fnd_file.put_line (fnd_file.LOG,'Tax % : '||p_entry_value3);
   fnd_file.put_line (fnd_file.LOG,'tax limit  : '||p_entry_value4);
   fnd_file.put_line (fnd_file.LOG,'monthly tax : '||p_entry_value5);
   fnd_file.put_line (fnd_file.LOG,'bi weekly tax : '||p_entry_value6);
   fnd_file.put_line (fnd_file.LOG,'weekly tax : '||p_entry_value7);
   fnd_file.put_line (fnd_file.LOG,'daily tax : '||p_entry_value8);
   fnd_file.put_line (fnd_file.LOG,'start date : '||p_return_value3);
*/
   hr_utility.set_location (   'Leaving:'|| l_proc, 100);
   END read_record;
/* Function to get the element link ID */


FUNCTION get_element_link_id
	(
	 p_assignment_id     IN NUMBER
	,p_business_group_id IN NUMBER
	,p_date		     IN per_all_assignments_f.effective_start_date%TYPE
	,p_element_name pay_element_types_f.ELEMENT_NAME%TYPE
	) RETURN NUMBER
	IS
		l_element_link_id       pay_element_links_f.ELEMENT_LINK_ID%TYPE;
		CURSOR csr_get_payroll_id IS
		SELECT  payroll_id
		FROM per_all_assignments_f
		WHERE business_group_id     = p_business_group_id
		AND assignment_id	    = p_assignment_id
		AND p_date
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
		OR (element.business_group_id is null and element.legislation_code = 'DK'))
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
END pay_dk_tc_dp_upload;

/
