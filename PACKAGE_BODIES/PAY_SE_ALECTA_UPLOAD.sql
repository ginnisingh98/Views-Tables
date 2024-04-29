--------------------------------------------------------
--  DDL for Package Body PAY_SE_ALECTA_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_SE_ALECTA_UPLOAD" AS
/* $Header: pyseaaru.pkb 120.0.12010000.1 2010/02/08 09:40:54 vijranga noship $ */


    g_package CONSTANT	VARCHAR2 (33) := '  pay_se_alecta_upload';
    e_record_not_found		EXCEPTION;

    c_warning		CONSTANT	NUMBER	:= 1;
    c_error		CONSTANT	NUMBER	:= 2;
    c_end_of_time	CONSTANT	DATE	:= to_date('12/31/4712','MM/DD/YYYY');

    PROCEDURE upload (
	      errbuf			OUT NOCOPY	VARCHAR2,
	      retcode			OUT NOCOPY	NUMBER,
	      p_file_name		IN		VARCHAR2,
 	      p_effective_date	IN		VARCHAR2,
	      p_business_group_id  IN	per_business_groups.business_group_id%TYPE
	)
	IS
      c_read_file	CONSTANT	VARCHAR2 (1) := 'r';
      c_max_linesize	CONSTANT	NUMBER  := 4000;
      c_data_exchange_dir	CONSTANT	VARCHAR2(30)  := 'PER_DATA_EXCHANGE_DIR';

      l_proc	CONSTANT	VARCHAR2(72)	:=    g_package||'.upload' ;
      l_legislation_code	per_business_groups.legislation_code%TYPE;
      l_bg_name				per_business_groups.name%TYPE;

      l_file_type		UTL_FILE.file_type;
      l_filename		VARCHAR2 (240);
      l_location		VARCHAR2 (4000);
      l_line_read		VARCHAR2 (4000)	:= NULL;
      l_line_no 		NUMBER	:= 0;
      l_record_found NUMBER := 0;

      e_fatal_error		EXCEPTION;


      CURSOR csr_leg (v_bg_id per_business_groups.business_group_id%TYPE)
      IS
        SELECT legislation_code, name
        FROM per_business_groups
        WHERE business_group_id = v_bg_id;


   BEGIN

	INSERT INTO fnd_sessions(SESSION_ID , EFFECTIVE_DATE )
	VALUES(userenv('SESSIONID'),fnd_date.canonical_to_date(p_effective_date)) ;

	hr_utility.set_location('p_file_name                '||p_file_name,1);
	hr_utility.set_location('p_business_group_id        '||p_business_group_id,1 );

	hr_utility.set_location (   'Entering:' || l_proc, 10);
--	fnd_file.put_line(fnd_file.log,'$$ Entering'||l_proc);

      OPEN csr_leg (p_business_group_id);
			FETCH csr_leg INTO l_legislation_code, l_bg_name;
      CLOSE csr_leg;

      hr_utility.set_location (   'Legislation = ' || l_legislation_code, 20);
--    fnd_file.put_line(fnd_file.log,'$$ l_legislation_code'||l_legislation_code);

      l_filename := p_file_name;
      fnd_profile.get (c_data_exchange_dir, l_location);

      hr_utility.set_location (   'Directory = ' || l_location, 30);
--    fnd_file.put_line(fnd_file.log,'$$ l_location'||l_location);

      IF l_location IS NULL
      THEN
         hr_utility.set_location (   'Raising I/O error = ' || l_location, 35);
         RAISE e_fatal_error;
      END IF;

      l_file_type :=
          UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);

      <<read_lines_in_file>>
      LOOP
         BEGIN
		UTL_FILE.get_line (l_file_type, l_line_read);
		l_line_no :=   l_line_no + 1;
         EXCEPTION
         WHEN	VALUE_ERROR
         THEN
               IF UTL_FILE.is_open (l_file_type)
               THEN
			UTL_FILE.fclose (l_file_type);
               END IF;

               hr_utility.set_location (l_proc, 50);
               retcode := c_error;
               errbuf :=    'Input line (line nr = '|| l_line_no + 1 || ') too large for buffer (=' || c_max_linesize  || ').';
		EXIT;
        WHEN	NO_DATA_FOUND
        THEN
               EXIT;
        END;
         hr_utility.set_location ( '  line read: ' || l_line_read,110);

    BEGIN

	compare_record (
		 p_line			=> l_line_read
		,p_record_found => l_record_found
	);

	 hr_utility.set_location (   '  l_record_found = ' || l_record_found, 130);
--	 fnd_file.put_line(fnd_file.log,'$$ l_record_found'||l_record_found);

	 if l_record_found = 0 then
   		hr_utility.set_location (   '  Record not found', 110);
		RAISE e_record_not_found;
	 end if;

	 EXCEPTION

	     WHEN e_record_not_found
	     THEN
		       retcode := c_warning;
		       hr_utility.set_message (801, 'HR_377018_DK_INVALID_RECORD');
		       hr_utility.set_message_token (801, 'LINE', l_line_read);
		       hr_utility.set_location (l_proc, 260);
		       fnd_file.put_line (fnd_file.LOG, hr_utility.get_message);
	     END;
      END LOOP read_lines_in_file;

      UTL_FILE.fclose (l_file_type);
      hr_utility.set_location (   'Leaving:'|| l_proc, 260);

   EXCEPTION
      WHEN e_fatal_error
      THEN
		IF UTL_FILE.is_open (l_file_type)
		THEN
			UTL_FILE.fclose (l_file_type);
		END IF;

		hr_utility.set_location (l_proc, 270);
    		retcode := c_error;
		hr_utility.set_message (801, 'HR_SE_DATA_EXCHANGE_DIR_MIS');
		errbuf := hr_utility.get_message;

      WHEN UTL_FILE.invalid_operation
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
			   UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 280);
		 retcode := c_error;
		 errbuf := 'Reading File ('||l_location ||' -> ' || l_filename  || ') - Invalid Operation.';

      WHEN UTL_FILE.internal_error
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
			UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 290);
		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Internal Error.';

      WHEN UTL_FILE.invalid_mode
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 300);
		 retcode := c_error;
		 errbuf :=    'Reading File ('  || l_location  || ' -> ' || l_filename || ') - Invalid Mode.';

      WHEN UTL_FILE.invalid_path
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid Path or Filename.';
		 hr_utility.set_location (l_proc, 310);

      WHEN UTL_FILE.invalid_filehandle
      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 320);
		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Invalid File Type.';
      WHEN UTL_FILE.read_error

      THEN
		 IF UTL_FILE.is_open (l_file_type)
		 THEN
		    UTL_FILE.fclose (l_file_type);
		 END IF;

		 hr_utility.set_location (l_proc, 330);
		 retcode := c_error;
		 errbuf :=    'Reading File (' || l_location || ' -> ' || l_filename || ') - Read Error.';
    END upload;


    PROCEDURE compare_record
	    (p_line		  IN VARCHAR2
	    ,p_record_found OUT NOCOPY NUMBER
	)
    IS

      l_proc  CONSTANT VARCHAR2 (72) :=    g_package|| '.compare_record';
      l_org_number		VARCHAR2(60);
      l_cost_centre		VARCHAR2(60);
      l_agreed_product_id		VARCHAR2(60);
      l_agreed_product		VARCHAR2(60);
      l_person_number		VARCHAR2(60);
      l_last_name		VARCHAR2(60);
      l_first_name		VARCHAR2(60);
      l_salary		VARCHAR2(60);
      l_sal_after_withdraw		VARCHAR2(60);
      l_time_of_event		VARCHAR2(60);
      l_alt_itp		VARCHAR2(60);
      l_sick_leave		VARCHAR2(60);
      l_parental_leave		VARCHAR2(60);
      l_leave_of_absence		VARCHAR2(60);
      l_record_found number := 0;

   BEGIN

    hr_utility.set_location (   'Entering:'|| l_proc, 70);
    --fnd_file.put_line(fnd_file.log,''||p_line);

    l_org_number := get_token(p_line,1);
    l_cost_centre :=  get_token(p_line,2);
    l_agreed_product_id :=  get_token(p_line,3);
    l_person_number :=  get_token(p_line,4);
    l_last_name :=  get_token(p_line,5);
    l_first_name :=  get_token(p_line,6);
    l_salary :=  get_token(p_line,7);
    l_time_of_event :=  get_token(p_line,8);
    l_alt_itp :=  get_token(p_line,9);
    l_sick_leave :=  get_token(p_line,10);
    l_parental_leave :=  get_token(p_line,11);
    l_leave_of_absence := get_token(p_line,12);

    l_org_number := replace(l_org_number,'-',''); -- Bug#9345105 fix
    l_person_number := replace(l_person_number,'-',''); -- Bug#9345105 fix

/*    fnd_file.put_line(fnd_file.log,'$$ l_org_number'||l_org_number);
    fnd_file.put_line(fnd_file.log,'$$ l_cost_centre'||l_cost_centre);
    fnd_file.put_line(fnd_file.log,'$$ l_agreed_product_id'||l_agreed_product_id);
    fnd_file.put_line(fnd_file.log,'$$ l_person_number'||l_person_number);
    fnd_file.put_line(fnd_file.log,'$$ l_last_name'||l_last_name);
    fnd_file.put_line(fnd_file.log,'$$ l_first_name'||l_first_name);
    fnd_file.put_line(fnd_file.log,'$$ l_salary'||l_salary);
    fnd_file.put_line(fnd_file.log,'$$ l_time_of_event'||l_time_of_event);
    fnd_file.put_line(fnd_file.log,'$$ l_alt_itp'||l_alt_itp);
    fnd_file.put_line(fnd_file.log,'$$ l_sick_leave'||l_sick_leave);
    fnd_file.put_line(fnd_file.log,'$$ l_parental_leave'||l_parental_leave);
    fnd_file.put_line(fnd_file.log,'$$ l_leave_of_absence'||l_leave_of_absence);
*/

/*
----------- Four cases -----------
where org no, cost centre, person no and time for event are mandatory
*/

    IF (l_org_number IS NOT NULL AND l_cost_centre IS NOT NULL
				AND l_person_number IS NOT NULL AND l_time_of_event IS NOT NULL)
		THEN
    /*
    ------------- Case 1 New Entry ----------------
    where org no, cost centre, agreed product, person no, time for event, last name,
    first name, salary details are available
    */
          IF (l_first_name IS NOT NULL AND l_last_name IS NOT NULL) THEN
			  fnd_file.put_line(fnd_file.log,'## Case 1 New entry');
              SELECT COUNT ('1') INTO l_record_found
              FROM pay_action_information
              WHERE action_information_category      = 'EMEA REPORT INFORMATION'
              AND action_information1          = 'PYSEALEA'
              AND l_org_number = action_information5
              AND l_cost_centre = action_information6
              AND l_agreed_product_id = action_information7
              AND l_person_number = action_information8
              AND l_last_name = action_information10
              AND l_first_name = action_information11
              AND l_salary IN (action_information14, action_information13)
              AND fnd_date.date_to_canonical(to_date(l_time_of_event, 'YYYY/MM/DD')) = action_information9;

    /*
    ------------ Case 2 Moving with in comapnay -------
    where org no, cost centre, agreed plan, person no, time for event, salary deatails
    are available
    */
            ELSIF (l_agreed_product_id IS NOT NULL) THEN
    			fnd_file.put_line(fnd_file.log,'## Case 2  Moving with in comapnay');
                SELECT COUNT ('1') INTO l_record_found
                FROM pay_action_information
                WHERE action_information_category      = 'EMEA REPORT INFORMATION'
                AND action_information1          = 'PYSEALEA'
                AND l_org_number = action_information5
                AND l_cost_centre = action_information6
                AND l_agreed_product_id = action_information7
                AND l_person_number = action_information8
                AND l_salary IN (action_information12, action_information11)
                AND fnd_date.date_to_canonical(to_date(l_time_of_event, 'YYYY/MM/DD')) = action_information9;

    /*
    ----------- Case 3 Salary Change --------------
    where org no, cost centre, person no, time for event, salary details are available
    */
            ELSIF (l_salary IS NOT NULL ) THEN
				fnd_file.put_line(fnd_file.log,'## Case 3  Salary change');
                SELECT COUNT ('1') INTO l_record_found
                FROM pay_action_information
                WHERE action_information_category      = 'EMEA REPORT INFORMATION'
                AND action_information1          = 'PYSEALEA'
                AND l_org_number = action_information5
                AND l_cost_centre = action_information6
                AND l_person_number = action_information7
                AND l_salary IN (action_information11, action_information10)
                AND fnd_date.date_to_canonical(to_date(l_time_of_event, 'YYYY/MM/DD')) = action_information8;

    /*
    ------------- Case 4 withdrawl  ------------
    where org no, cost centre, person no, time for event details are available
    */
			ELSE
				fnd_file.put_line(fnd_file.log,'## Case 4  Withdrawl');
                SELECT COUNT ('1') INTO l_record_found
                FROM pay_action_information
                WHERE action_information_category      = 'EMEA REPORT INFORMATION'
                AND action_information1          = 'PYSEALEA'
                AND l_org_number = action_information5
                AND l_cost_centre = action_information6
                AND l_person_number = action_information7
                AND fnd_date.date_to_canonical(to_date(l_time_of_event, 'YYYY/MM/DD')) = action_information8 ;
 			END IF;
END IF;

p_record_found := l_record_found;
--fnd_file.put_line(fnd_file.log,'## l_record_found'||l_record_found);
hr_utility.set_location (   'Leaving:'|| l_proc, 120);

END compare_record;

function get_token(
   the_string  varchar2,
   the_index number,
   delim     varchar2 := ';'
)
   return    varchar2
is
   start_pos number;
   end_pos   number;
begin
   if the_index = 1 then
       start_pos := 1;
   else
       start_pos := instr(the_string, delim, 1, the_index - 1);
       if start_pos = 0 then
           return null;
       else
           start_pos := start_pos + length(delim);
       end if;
   end if;

   end_pos := instr(the_string, delim, start_pos, 1);

   if end_pos = 0 then
       return substr(the_string, start_pos);
   else
       return substr(the_string, start_pos, end_pos - start_pos);
   end if;

end get_token;

END PAY_SE_ALECTA_UPLOAD;

/
