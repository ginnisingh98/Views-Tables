--------------------------------------------------------
--  DDL for Package Body PAY_NL_IZA_UPLOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_IZA_UPLOAD" AS
/* $Header: pynlizau.pkb 120.0 2005/05/29 06:55:42 appldev noship $ */

-- The package for IZA upload process

   -- Global package name
   g_package				CONSTANT VARCHAR2 (400) := '  pay_nl_iza_upload';

   g_batch_header                     VARCHAR2 (50) ;
   g_batch_source                     VARCHAR2 (50) ;
   g_batch_comments                   VARCHAR2 (100);
   g_debug 			      BOOLEAN;

  c_update_action_if_exists		VARCHAR2 (1);
  c_default_dt_effective_changes   	VARCHAR2 (1);
  c_read_file           		VARCHAR2 (1);
  c_max_linesize        		NUMBER ;
  c_data_exchange_dir   		VARCHAR2 (30);

-- Global for element_type_id of "Nominal IZA Contributions" element.

   g_element_type_id 		pay_element_types_f.element_type_id%TYPE;

   -- Global constants

   c_error			CONSTANT NUMBER := 1;



/*--------------------------------------------------------------------
|Name       : iza_upload              	                             |
|Type	    : Procedure				                     |
|Description: This Procedure initiates the IZA upload process. It    |
|	      takes in the parameters passed from the information in |
|	      concurrent program definition and calls various        |
|	      procedures for inserting data into pay_batch_headers   |
|             and pay_batch_lines table.                             |
----------------------------------------------------------------------*/




PROCEDURE iza_upload(	errbuf                     OUT NOCOPY   VARCHAR2,
			retcode                    OUT NOCOPY   NUMBER,
			p_file_name                IN       VARCHAR2,
			p_batch_name               IN       VARCHAR2,
			p_effective_date           IN       VARCHAR2,
			p_business_group_id        IN       per_business_groups.business_group_id%TYPE,
			p_action_if_exists         IN       VARCHAR2 DEFAULT NULL,
			p_dummy_action_if_exists   IN	    VARCHAR2 DEFAULT NULL,
			p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL
		      ) IS

	-- Procedure name

	l_proc                		VARCHAR2 (72) ;
	l_legislation_code             per_business_groups.legislation_code%TYPE;

	-- File Handling variables
	l_file_handle                  UTL_FILE.file_type;
	l_filename                     VARCHAR2 (240);
	l_location                     VARCHAR2 (400);
	l_line_read                    VARCHAR2 (400);



	-- Batch Variables
	l_batch_seq                    NUMBER;
	l_input_line_num	       NUMBER;

	-- Variables to hold returning values from procedure calls
	l_batch_id                     NUMBER;
	l_batch_line_id                NUMBER;
	l_ovn                          NUMBER;
	l_bl_ovn		       NUMBER;

	-- Other local Variables
	l_count number;
	l_process_yr_mm varchar2(10);
	l_payroll_center varchar2(80);
	l_period_eff_start_date date;
	l_period_eff_end_date date;
	l_client_num VARCHAR2(10);
	l_rec_client_num VARCHAR2(10);
	l_sub_emplr_num VARCHAR2(10);
	l_rec_sub_emplr_num VARCHAR2(10);
	l_province_code VARCHAR2(10);
	l_process_status VARCHAR2(10);
	l_emp_name	 VARCHAR2(230);
	l_date_of_birth	 date;
	l_last_name	VARCHAR2(150);
	l_prefix	VARCHAR2(30);
	l_initials	VARCHAR2(150);
	l_participant_number number;

	l_org_id number;
	l_org_struct_version_id number;
	l_rec_org_id number;
	l_employee_number varchar2(30);


	-- Exceptions
	e_fatal_error                  EXCEPTION;
	e_org_id		       EXCEPTION;


	cursor csr_iza_info(v_org_id number) IS
	select ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3
	from HR_ORGANIZATION_INFORMATION
	where ORG_INFORMATION_CONTEXT='NL_IZA_REPO_INFO'
	and organization_id = v_org_id;


	cursor csr_organization_id(v_client_number varchar2,v_sub_emplr_number varchar2,v_bg_id number) IS
	select hoi.organization_id
	from HR_ORGANIZATION_INFORMATION hoi, HR_ORGANIZATION_UNITS hou
	where ORG_INFORMATION_CONTEXT='NL_IZA_REPO_INFO'
	and lpad(ORG_INFORMATION1,3,'0') = v_client_number
	and lpad(ORG_INFORMATION2,3,'0') = v_sub_emplr_number
	and hou.ORGANIZATION_ID = hoi.organization_id
	and hou.business_group_id = v_bg_id;

	CURSOR csr_employee_info(v_business_group_id number,
				 v_person_id number,
				 v_period_start_date Date,
				 v_period_end_date Date
				 ) IS
	SELECT
		paa.organization_id org_id,
		ltrim(substr(pap.employee_number,1,9),'0') employee_number
		,pap.PER_INFORMATION1 initials
		,pap.PRE_NAME_ADJUNCT prefix
		,pap.LAST_NAME	 last_name
		,pap.date_of_birth
		,pap.per_information15
	FROM
		per_all_people_f pap
		,per_all_assignments_f paa
	WHERE	pap.business_group_id = v_business_group_id
	and	pap.person_id = v_person_id
	and 	pap.person_id = paa.person_id
	and 	v_period_end_date between pap.effective_start_date and pap.effective_end_date
	and 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_assignment_status_types past, per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   past.per_system_status = 'ACTIVE_ASSIGN'
		and   asg.assignment_status_type_id = past.assignment_status_type_id
		and   asg.effective_start_date <= v_period_End_Date
		and   asg.effective_end_date >= v_period_Start_Date
		);


	CURSOR csr_missing_employees(v_business_group_id number,
				     v_period_start_date Date,
				     v_period_end_date Date,
				     v_org_struct_version_id number
				    ) IS
	SELECT
		pap.person_id person_id
	FROM
		per_all_people_f pap
		,per_all_assignments_f paa
		,PER_ASSIGNMENT_EXTRA_INFO pae_iza
	        ,PER_ASSIGNMENT_EXTRA_INFO pae_sii
	WHERE	pap.business_group_id = v_business_group_id
	and 	pap.person_id = paa.person_id
	and     paa.primary_flag='Y'
	and 	v_period_end_date between pap.effective_start_date and pap.effective_end_date
	and 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_assignment_status_types past, per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   past.per_system_status = 'ACTIVE_ASSIGN'
		and   asg.assignment_status_type_id = past.assignment_status_type_id
		and   asg.effective_start_date <= v_period_End_Date
		and   asg.effective_end_date >= v_period_Start_Date
		)
	and paa.organization_id in (select distinct piza.organization_id iza_org_id
				    from pay_nl_iza_upld_status piza
				    where piza.process_year_month = v_period_End_Date
			    	    AND	lpad(piza.employer_number,3,'0') = l_rec_client_num
				    AND	piza.business_group_id = p_business_group_id

				    UNION

		      		    (
		      		    SELECT iza_org_id from hr_organization_information e,(
 				    SELECT  distinct pose.organization_id_child iza_org_id
 				    FROM per_org_structure_elements pose
 			 	    where   pose.org_structure_version_id = v_org_struct_version_id
 				    START WITH pose.organization_id_parent in (select distinct piza.organization_id
				    					       from pay_nl_iza_upld_status piza
				    					       where piza.process_year_month = v_period_End_Date
			    	    					       AND   lpad(piza.employer_number,3,'0') = l_rec_client_num
				    					       AND   piza.business_group_id = p_business_group_id
				    					       )
 				    CONNECT BY PRIOR pose.organization_id_child   = pose.organization_id_parent)

 				    MINUS

		      		    SELECT iza_org_id from hr_organization_information e1,(
 				    SELECT  distinct pose.organization_id_child iza_org_id
 				    FROM per_org_structure_elements pose
 			 	    where   pose.org_structure_version_id = v_org_struct_version_id
 				    START WITH pose.organization_id_parent in (select distinct piza.organization_id
				    					       from pay_nl_iza_upld_status piza
				    					       where piza.process_year_month = v_period_End_Date
			    	    					       AND   lpad(piza.employer_number,3,'0') = l_rec_client_num
				    					       AND   piza.business_group_id = p_business_group_id
				    					       )
 				    CONNECT BY PRIOR pose.organization_id_child   = pose.organization_id_parent)
				    where
				    e1.organization_id=iza_org_id and
				    e1.org_information_context = 'NL_IZA_REPO_INFO'
				    AND e1.org_information1 IS NOT NULL
				    AND e1.org_information2 IS NOT NULL
				    )

				    )

	and paa.assignment_id = pae_iza.assignment_id
	and pae_iza.AEI_INFORMATION_CATEGORY = 'NL_IZA_INFO'
	and   v_period_end_date >= fnd_date.canonical_to_date(pae_iza.AEI_INFORMATION1)
	and   v_period_start_date <= NVL(fnd_date.canonical_to_date(pae_iza.AEI_INFORMATION2),v_period_start_date)
	and   pae_sii.AEI_INFORMATION_CATEGORY = 'NL_SII'
	and   pae_sii.AEI_INFORMATION3 in ('ZFW','AMI')
	and   pae_sii.AEI_INFORMATION4 = '4'
	and   v_period_end_date >= fnd_date.canonical_to_date(pae_sii.AEI_INFORMATION1)
	and   v_period_start_date <= NVL(fnd_date.canonical_to_date(pae_sii.AEI_INFORMATION2),v_period_start_date)
	and   paa.assignment_id = pae_iza.assignment_id
	and   pae_iza.assignment_id = pae_sii.assignment_id
	minus

	SELECT
		piza1.person_id
	FROM 	pay_nl_iza_upld_status piza1
	WHERE	piza1.process_year_month = v_period_End_Date
	AND	lpad(piza1.employer_number,3,'0') = l_rec_client_num
 	AND	piza1.business_group_id = p_business_group_id;

	cursor csr_org_struct_version_id(v_bg_id number,v_period_end_date date) IS
	SELECT sv.org_structure_version_id
	FROM   per_org_structure_versions  sv
	WHERE  sv.organization_structure_id in
	(
	SELECT TO_NUMBER(inf.org_information1) organization_structure_id
	FROM   hr_organization_information inf
	WHERE  inf.organization_id         = v_bg_id
	AND  inf.org_information_context = 'NL_BG_INFO'
	AND  inf.org_information1        IS NOT NULL
	)
	AND  v_period_end_date BETWEEN sv.date_from
	AND NVL(sv.date_to, Hr_general.End_Of_time);




BEGIN


	--  g_debug := TRUE;


	if g_debug then
		hr_utility.trace_on(NULL,'IZA');
	-- input parameters
		hr_utility.set_location('p_file_name                '||p_file_name,250);
		hr_utility.set_location('p_effective_date           '||p_effective_date,250);
		hr_utility.set_location('p_business_group_id        '||p_business_group_id,250 );
		hr_utility.set_location('p_action_if_exists         '||p_action_if_exists,250);
		hr_utility.set_location('p_date_effective_changes   '||p_date_effective_changes,250);
		hr_utility.set_location('p_batch_name               '||p_batch_name,250);
		hr_utility.set_location (   'Entering:' || l_proc, 250);

	end if;

	c_read_file           := 'r';
  	c_max_linesize        := 400;
  	c_data_exchange_dir   := 'PER_DATA_EXCHANGE_DIR';

	g_batch_header        := hr_general.decode_lookup('HR_NL_REPORT_LABELS', 'IZA_BATCH_HEADER');
	g_batch_source        := hr_general.decode_lookup('HR_NL_REPORT_LABELS', 'IZA_BATCH_SOURCE');


	l_proc                	:= g_package || 'iza_upload ';
	l_line_read             := NULL;


	-- Batch Variables
	l_batch_seq             := 0;

	l_count			:= 0;

	g_element_type_id := pay_nl_general.get_element_type_id('Nominal IZA Contribution',fnd_date.canonical_to_date(p_effective_date));


	l_filename := p_file_name;
	fnd_profile.get (c_data_exchange_dir, l_location);

	if g_debug then
		hr_utility.set_location (   'directory = ' || l_location, 270);
	end if;

	IF l_location IS NULL
	THEN
	-- error : I/O directory not defined
	RAISE e_fatal_error;
	END IF;


	-- Opening flat file from the specified directory
	l_file_handle :=
	UTL_FILE.fopen (l_location, l_filename, c_read_file, c_max_linesize);


	-- Loop over the file, reading in each line.  GET_LINE will
	-- raise NO_DATA_FOUND when it is done, so we use that as the
	-- exit condition for the loop


	<<read_lines_in_file>>
	LOOP
		BEGIN

			-- read the file line by line into a string

			UTL_FILE.get_line (l_file_handle, l_line_read);

			-- check if the record is Opening Record

			if substr(l_line_read,1,1) ='1' then


			-- if the record is an opening record then take the process year month and
			-- payroll center in the local variables

			l_process_yr_mm:=substr(l_line_read,2,6);
			l_payroll_center:=substr(l_line_read,8,30);
			l_period_eff_start_date:=to_date(l_process_yr_mm,'YYYYMM');
			l_period_eff_end_date:=last_day(to_date(l_process_yr_mm,'YYYYMM'));



			-- Create the Batch header for every opening record

			-- This create_batch_header procedure is a wrapper over the core
			-- create_batch_header procedure defined in PAY_BATCH_ELEMENT_ENTRY_API

			create_batch_header
			(p_effective_date=> fnd_date.canonical_to_date (p_effective_date)
			,p_name          => p_batch_name
			,p_bg_id         => p_business_group_id
			,p_action_if_exists => NVL (p_action_if_exists, c_default_action_if_exists)
			,p_date_effective_changes => p_date_effective_changes
			,p_batch_id => l_batch_id
			,p_ovn => l_ovn );

			l_batch_seq :=   l_batch_seq + 1;
			end if;

			-- exceptions handling

		EXCEPTION
			WHEN VALUE_ERROR
			-- Input line too large for buffer specified in UTL_FILE.fopen
			THEN
			IF UTL_FILE.is_open (l_file_handle)
			THEN
			UTL_FILE.fclose (l_file_handle);
			END IF;

			if g_debug then
				hr_utility.set_location (l_proc, 350);
			end if;

			retcode := c_error;
			l_input_line_num := l_batch_seq + 1;
			-- The error will mean batch_seq doesn't get upped so add 1 when
			-- reporting line
			errbuf :=    'Input line (line nr = '|| l_input_line_num || ') too large for buffer (=' || c_max_linesize || ').';

			EXIT;

			-- when the file reaches the end, NO_DATA_FOUND exception would be raised and the
			-- file should be closed

			WHEN NO_DATA_FOUND
			THEN
			EXIT;
		END;

		if g_debug then

			hr_utility.set_location ( 'line read: ' || SUBSTR (l_line_read, 1, 40), 350);

		end if;

		-- Performing the necessary actions for a Data Record

		IF substr(l_line_read,1,1) = '2' then

			l_rec_org_id := NULL;

			l_rec_client_num:= SUBSTR (l_line_read,4,3);
			l_rec_sub_emplr_num := SUBSTR (l_line_read,22,3);

			if g_debug then
				hr_utility.set_location ( 'l_rec_client_num: ' || SUBSTR (l_rec_client_num, 1, 40), 350);
				hr_utility.set_location ( 'l_rec_sub_emplr_num: ' || SUBSTR (l_rec_sub_emplr_num, 1, 40), 350);
			end if;

			OPEN csr_organization_id(l_rec_client_num,l_rec_sub_emplr_num,p_business_group_id);
			FETCH csr_organization_id INTO l_rec_org_id;
			IF l_rec_org_id IS NULL THEN
				RAISE e_org_id;
			END IF;
			CLOSE csr_organization_id;

			if g_debug then
				hr_utility.set_location ( 'l_rec_org_id: ' || SUBSTR (l_rec_org_id, 1, 40), 350);
			end if;


			OPEN csr_org_struct_version_id(p_business_group_id,l_period_eff_end_date);
			FETCH csr_org_struct_version_id INTO l_org_struct_version_id;
			CLOSE csr_org_struct_version_id;

			if g_debug then
				hr_utility.set_location ( 'l_org_struct_version_id: ' || SUBSTR (l_org_struct_version_id, 1, 40), 350);
			end if;

			val_create_batch_line(l_line_read,l_batch_id,l_batch_seq,l_process_yr_mm,l_payroll_center,l_rec_org_id,l_org_struct_version_id,p_business_group_id,fnd_date.canonical_to_date(p_effective_date),l_batch_line_id,l_bl_ovn);

		END IF;

		-- this is the case of a Closing Record

		IF substr(l_line_read,1,1) = '3' then

			FOR csr_missing_employees_rec in csr_missing_employees(p_business_group_id,l_period_eff_start_date,l_period_eff_end_date,l_org_struct_version_id)
			LOOP

				OPEN csr_employee_info(	p_business_group_id,
						       	csr_missing_employees_rec.person_id,
							l_period_eff_start_date,
							l_period_eff_end_date
						       ) ;
				FETCH csr_employee_info INTO l_org_id,l_employee_number,l_initials,l_prefix,l_last_name,l_date_of_birth,l_participant_number;
				CLOSE csr_employee_info;


				OPEN csr_iza_info(l_rec_org_id);
				FETCH csr_iza_info INTO l_client_num,l_sub_emplr_num,l_province_code;
				CLOSE csr_iza_info;

				if g_debug then

				-- input parameters
					hr_utility.set_location('p_business_group_id                '||p_business_group_id,400);
					hr_utility.set_location('l_org_id           '||l_org_id,400);
					hr_utility.set_location('l_sub_emplr_num        '||l_sub_emplr_num,400 );
					hr_utility.set_location('csr_missing_employees_rec.person_id   '||csr_missing_employees_rec.person_id,400);
					hr_utility.set_location('l_employee_number               '||l_employee_number,400);
					hr_utility.set_location('l_process_status                '||l_process_status,400);
					hr_utility.set_location('l_province_code           '||l_province_code,400);
					hr_utility.set_location('l_participant_number '||l_participant_number,400);
					hr_utility.set_location('l_last_name               '||l_last_name,400);
					hr_utility.set_location('l_initials               '||l_initials,400);
					hr_utility.set_location('l_prefix               '||l_prefix,400);

				end if;

				l_process_status:='MISSING';
					insert into PAY_NL_IZA_UPLD_STATUS(  BUSINESS_GROUP_ID
									    ,ORGANIZATION_ID
									    ,EMPLOYER_NUMBER
									    ,SUB_EMPLOYER_NUMBER
									    ,PAYROLL_CENTER
									    ,PROCESS_YEAR_MONTH
									    ,PERSON_ID
									    ,EMPLOYEE_NUMBER
									    ,PROCESS_STATUS
									    ,PROVINCE_CODE
					        			    ,DATE_OF_BIRTH
					        			    ,PARTICIPANT_NUMBER
					        			    ,EMPLOYEE_NAME
									    ,CONTRIBUTION_1
									    ,CORRECTION_CONTRIBUTION_1
									    ,DATE_CORRECTION_1
									    ,CONTRIBUTION_2
									    ,CORRECTION_CONTRIBUTION_2
									    ,DATE_CORRECTION_2
									    ,REJECT_REASON)
					values (p_business_group_id
						,l_rec_org_id
						,l_client_num
						,l_sub_emplr_num
						,NULL
						,l_period_eff_end_date
						,csr_missing_employees_rec.person_id
						,l_employee_number
						,l_process_status
						,l_province_code
						,l_date_of_birth
						,l_participant_number
						,l_last_name || ' ' || l_initials || ' ' || l_prefix
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL);
			END LOOP;


		END IF;


	END LOOP read_lines_in_file;


	-- Commit the outstanding records
	COMMIT;
	UTL_FILE.fclose (l_file_handle);

	if g_debug then
		hr_utility.set_location (   'Leaving:'|| l_proc, 500);
	end if;

	-- Most off these exceptions are not translated as they should not happen normally
	-- If they do happen, something is seriously wrong and SysAdmin interference will be necessary.


	-- exceptions for file handling

EXCEPTION

	WHEN e_org_id THEN
		-- Close the file in case off error
		ROLLBACK;
		IF UTL_FILE.is_open (l_file_handle) THEN
			UTL_FILE.fclose (l_file_handle);
		END IF;

		if g_debug then
			hr_utility.set_location (l_proc, 500);
		end if;
		-- Set retcode to 2, indicating an ERROR to the ConcMgr
		retcode := 2;

		fnd_message.set_name('PAY','PAY_NL_ORG_ID');
		fnd_message.set_token('ERNUM',l_rec_client_num);
		fnd_message.set_token('SUBERNUM',l_rec_sub_emplr_num);

		-- Return the message to the ConcMgr (This msg will appear in the log file)
		errbuf := fnd_message.get();



	WHEN e_fatal_error
	-- No directory specified
	THEN
	-- Close the file in case off error
	IF UTL_FILE.is_open (l_file_handle)
	THEN
	UTL_FILE.fclose (l_file_handle);
	END IF;

	if g_debug then
		hr_utility.set_location (l_proc, 500);
	end if;

	-- Set retcode to 2, indicating an ERROR to the ConcMgr
	retcode := c_error;

	-- Set the application error

	hr_utility.set_message (800, 'HR_78040_DATA_EXCHANGE_DIR_MIS');

	-- Return the message to the ConcMgr (This msg will appear in the log file)
	errbuf := hr_utility.get_message;

	WHEN UTL_FILE.invalid_operation
	-- File could not be opened as requested, perhaps because of operating system permissions
	-- Also raised when attempting a write operation on a file opened for read, or a read operation
	-- on a file opened for write.

	THEN
	IF UTL_FILE.is_open (l_file_handle)
	THEN
	UTL_FILE.fclose (l_file_handle);
	END IF;

	if g_debug then
		hr_utility.set_location (l_proc, 550);
	end if;

	retcode := c_error;

	fnd_message.set_name('PAY','PAY_NL_FILE_INVALID_OPERATION');
	fnd_message.set_token('FILENAME',l_filename);
	fnd_message.set_token('LOCATION',l_location);

	errbuf := fnd_message.get();


	WHEN UTL_FILE.internal_error
	-- Unspecified internal error
	THEN
	IF UTL_FILE.is_open (l_file_handle)
	THEN
	UTL_FILE.fclose (l_file_handle);
	END IF;

	if g_debug then
		hr_utility.set_location (l_proc, 550);
	end if;

	retcode := c_error;

	fnd_message.set_name('PAY','PAY_NL_FILE_INTERNAL_ERROR');
	fnd_message.set_token('FILENAME',l_filename);
	fnd_message.set_token('LOCATION',l_location);

	errbuf := fnd_message.get();


	WHEN UTL_FILE.invalid_mode
	-- Invalid string specified for file mode
	THEN
	IF UTL_FILE.is_open (l_file_handle)
	THEN
	UTL_FILE.fclose (l_file_handle);
	END IF;

	if g_debug then
		hr_utility.set_location (l_proc, 550);
	end if;

	retcode := c_error;

	fnd_message.set_name('PAY','PAY_NL_FILE_INVALID_MODE');
	fnd_message.set_token('FILENAME',l_filename);
	fnd_message.set_token('LOCATION',l_location);

	errbuf := fnd_message.get();


	WHEN UTL_FILE.invalid_path
	-- Directory or filename is invalid or not accessible
	THEN
	IF UTL_FILE.is_open (l_file_handle)
	THEN
	UTL_FILE.fclose (l_file_handle);
	END IF;

	retcode := c_error;

	fnd_message.set_name('PAY','PAY_NL_FILE_INVALID_PATH');

	errbuf := fnd_message.get();


	if g_debug then
		hr_utility.set_location (l_proc, 550);
	end if;

	WHEN UTL_FILE.invalid_filehandle
	-- File handle does not specify an open file
	THEN
	IF UTL_FILE.is_open (l_file_handle)
	THEN
	UTL_FILE.fclose (l_file_handle);
	END IF;

	if g_debug then
		hr_utility.set_location (l_proc, 550);
	end if;

	retcode := c_error;


	fnd_message.set_name('PAY','PAY_NL_INVALID_FILE_HANDLE');
	fnd_message.set_token('FILENAME',l_filename);
	fnd_message.set_token('LOCATION',l_location);

	errbuf := fnd_message.get();


	WHEN UTL_FILE.read_error

	-- Operating system error occurred during a read operation
	THEN
	IF UTL_FILE.is_open (l_file_handle)
	THEN
	UTL_FILE.fclose (l_file_handle);
	END IF;

	if g_debug then
		hr_utility.set_location (l_proc, 650);
	end if;


	fnd_message.set_name('PAY','PAY_NL_FILE_READ_ERROR');
	fnd_message.set_token('FILENAME',l_filename);
	fnd_message.set_token('LOCATION',l_location);

	errbuf := fnd_message.get();



END iza_upload;


/*--------------------------------------------------------------------
|Name       : create_batch_header              	                     |
|Type	    : Procedure				                     |
|Description: This procedure is a wrapper over the core              |
|             create_batch_header procedure defined in               |
|             PAY_BATCH_ELEMENT_ENTRY_API                            |
----------------------------------------------------------------------*/


       -- The IN Parameters are
       --    p_effective_date -> the effective date
       --    p_name           -> the batch name
       --    p_bg_id          -> the business group id
       --    p_action_if_exists       -> The action that needs to be taken when the entry already exists
       --                                Possible values are 'I' (Insert), 'R' (Reject) or 'U' (Update)
       --    p_date_effective_changes -> The date effective change that needs to happen
       --                                Possible values are 'C' (Correct), 'O' (Override) or 'U' (Update)
       --                                This should only be used if p_action_if_exists = 'U'
       --
       -- The OUT Parameters are
       --    p_batch_id      -> the batch id of the created batch header
       --    p_ovn           -> the object version number of the created batch header


      PROCEDURE create_batch_header (
          p_effective_date           IN       DATE,
          p_name                     IN       VARCHAR2,
          p_bg_id                    IN       NUMBER,
          p_action_if_exists         IN       VARCHAR2 DEFAULT c_default_action_if_exists,
          p_date_effective_changes   IN       VARCHAR2 DEFAULT NULL,
          p_batch_id                 OUT NOCOPY  NUMBER,
          p_ovn                      OUT NOCOPY  NUMBER
       )
       IS
          l_proc                           	    VARCHAR2 (72);
          l_date_effective_changes                  VARCHAR2 (30);
          c_batch_reference                         VARCHAR2 (50);
          c_batch_source                            VARCHAR2 (50);
          c_comments                                VARCHAR2 (100);

       BEGIN

          l_date_effective_changes 		:= NULL;
          c_batch_reference             	:= g_batch_header;
          c_batch_source                	:= g_batch_source;
          c_comments                    	:= g_batch_comments;
	  l_proc                           	:= g_package || 'create_batch_header';
          c_update_action_if_exists             := 'U'; --Update existing element entry;
          c_default_dt_effective_changes   	:= 'C'; --Update/Change Insert;



          if g_debug then
          	hr_utility.set_location (   'Entering:'
                                   || l_proc, 700);
    	  end if;

          -- CREATE_BATCH_HEADER definition
          /****************************************************************
           procedure create_batch_header
            (p_validate                      in     boolean  default false
            ,p_session_date                  in     date
            ,p_batch_name                    in     varchar2
            ,p_batch_status                  in     varchar2 default 'U'
            ,p_business_group_id             in     number
            ,p_action_if_exists              in     varchar2 default 'R'
            ,p_batch_reference               in     varchar2 default null
            ,p_batch_source                  in     varchar2 default null
            ,p_comments                      in     varchar2 default null
            ,p_date_effective_changes        in     varchar2 default 'C'
            ,p_purge_after_transfer          in     varchar2 default 'N'
            ,p_reject_if_future_changes      in     varchar2 default 'Y'
            ,p_batch_id                         out number
            ,p_object_version_number            out number);
          ******************************************************************/

          -- p_date_effective_changes should only be populated if p_action_if_exists = 'U'
          IF (p_action_if_exists = c_update_action_if_exists)
          THEN
             IF (p_date_effective_changes IS NULL)
             THEN -- Default p_date_effective_changes
                l_date_effective_changes := c_default_dt_effective_changes;
             ELSE
                l_date_effective_changes := p_date_effective_changes;
             END IF;
          ELSE -- set p_date_effective_changes to null
             l_date_effective_changes := NULL;
          END IF;

          pay_batch_element_entry_api.create_batch_header (
             p_session_date          => p_effective_date,
             p_batch_name            => p_name,
             p_business_group_id     => p_bg_id,
             p_action_if_exists      => p_action_if_exists,
             p_date_effective_changes=> l_date_effective_changes,
             p_batch_reference       => c_batch_reference,
             p_batch_source          => c_batch_source,
             p_comments              => c_comments,
             p_batch_id              => p_batch_id, -- out
             p_object_version_number => p_ovn -- out
          );

          if g_debug then

          	hr_utility.set_location (   'Leaving:'
          	                         || l_proc, 750);
   	  end if;


   END create_batch_header;



/*--------------------------------------------------------------------
|Name       : create_batch_line              	                     |
|Type	    : Procedure				                     |
|Description: This procedure is a wrapper over the core              |
|	      create_batch_line procedure defined in                 |
|	      PAY_BATCH_ELEMENT_ENTRY_API                            |
----------------------------------------------------------------------*/



PROCEDURE create_batch_line (p_session_date                  DATE
			    ,p_batch_id                      pay_batch_lines.batch_id%TYPE
			    ,p_assignment_id                 pay_batch_lines.assignment_id%TYPE
			    ,p_assignment_number             pay_batch_lines.assignment_number%TYPE
			    ,p_batch_sequence                pay_batch_lines.batch_sequence%TYPE
			    ,p_effective_date                pay_batch_lines.effective_date%TYPE
			    ,p_date_earned                   pay_batch_lines.date_earned%TYPE
			    ,p_element_name                  pay_batch_lines.element_name%TYPE
			    ,p_element_type_id               pay_batch_lines.element_type_id%TYPE
			    ,p_value_1                       pay_batch_lines.value_1%TYPE
			    ,p_bline_id     		     OUT NOCOPY  NUMBER
			    ,p_obj_vn			     OUT NOCOPY  NUMBER
			    ) IS

         l_proc   VARCHAR2 (72);

      BEGIN

         if g_debug then
         	hr_utility.set_location (   'Entering:'|| l_proc, 800);
   	 end if;

   	 l_proc :=    g_package|| 'create_batch_line';


         PAY_BATCH_ELEMENT_ENTRY_API.create_batch_line (
            p_session_date          => p_session_date,
            p_batch_id              => p_batch_id,
            p_assignment_id         => p_assignment_id,
            p_assignment_number     => p_assignment_number,
            p_batch_sequence        => p_batch_sequence,
            p_effective_date        => p_effective_date,
            p_date_earned           => p_date_earned,
            p_element_name          => p_element_name,
            p_element_type_id       => p_element_type_id,
            p_value_1               => p_value_1,
            p_batch_line_id         => p_bline_id,
            p_object_version_number => p_obj_vn
         );

         if g_debug then
         	hr_utility.set_location (   'Leaving:'
      	                            || l_proc, 800);
      	 end if;

      END create_batch_line;



/*--------------------------------------------------------------------
|Name       : val_create_batch_line              	             |
|Type	    : Procedure				                     |
|Description: This procedure will take in the Data Record, validates |
|	      it and decides if it needs to be processed or rejected |
|	      by calling the function iza_validation.                |
|	      After validation it calls the wrapper procedure        |
|             create_batch_line to create a record in pay_batch_lines|
|             It also creates the record in the table                |
|             PAY_NL_IZA_UPLD_STATUS table for Rejected and Processed|
|             records.                                               |
----------------------------------------------------------------------*/


Procedure val_create_batch_line( p_line_read IN VARCHAR2
		    		,p_batch_id IN NUMBER
		    		,p_batch_seq IN NUMBER
		    		,p_process_yr_mm IN VARCHAR2
		    		,p_payroll_center IN VARCHAR2
		    		,p_org_id IN NUMBER
		    		,p_org_struct_version_id IN NUMBER
		    		,p_bg_id IN NUMBER
		    		,p_eff_date IN DATE
		    		,p_batch_line_id OUT NOCOPY NUMBER
		    		,p_bl_ovn OUT NOCOPY NUMBER) IS


	cursor csr_employee_terminate(v_person_id number,v_bg_id number,v_period_start_date date,v_period_end_date date) IS
	select pap.effective_start_date - 1
	from  per_all_people_f  pap
	where PER_INFORMATION_CATEGORY='NL'
	and   pap.business_group_id = v_bg_id
	and   pap.person_id = v_person_id
	and   pap.current_employee_flag is null
	and   v_period_end_date >= pap.effective_start_date
	and   v_period_start_date <= pap.effective_end_date
	and   v_period_end_date between pap.effective_start_date and pap.effective_end_date;

      	c_commit_point        		CONSTANT NUMBER                  := 20;

      	l_record_eff_end_date date;
      	l_record_eff_start_date date;
      	l_assignment_id number;
	l_assignment_num varchar2(40);
      	l_person_id number;
      	l_element_name varchar2(150);
      	l_org_id number;
	l_client_num varchar2(10);
	l_sub_emplr_num	varchar2(10);
	l_employee_number varchar2(50);
	l_process_status varchar2(10);
	l_province_code varchar2(10);
	l_contribution1 number;
	l_corr_cont1 number;
	l_date_corr1 date;
	l_contribution2 number;
	l_corr_cont2 number;
	l_date_corr2 date;
	l_reject_reason_code1 varchar2(10);
	l_reject_reason_code2 varchar2(10);
	l_reject_reason_code3 varchar2(10);
	l_reject_code varchar2(10);
	l_reject_reason varchar2(80);
	l_contr_sign varchar2(1);
	l_iza_corr_yr_mm varchar2(10);
	l_iza_corr_start_date date;
	l_iza_corr_end_date date;
	l_iza_corr2_yr_mm varchar2(10);
	l_iza_corr2_start_date date;
	l_iza_corr2_end_date date;
	l_exchange_number varchar2(30);
	l_participant_number number;
	l_employee_name varchar2(100);
	l_date_of_birth date;
	l_element_entry_eff_date date;
	l_entry_eff_date date;
	l_record_term_date date;
	l_entry_corr_eff_date date;
	l_corr_term_date date;
	l_entry_corr2_eff_date date;
	l_corr2_term_date date;
	l_contribution1_sign VARCHAR2(1);
	l_corr_cont1_sign VARCHAR2(1);
	l_contribution2_sign  VARCHAR2(1);
	l_corr_cont2_sign  VARCHAR2(1);



	BEGIN

		   if g_debug then
		   	hr_utility.set_location ( 'Inside val_create_batch_line ', 900);
		   end if;

		   l_reject_reason_code1 := '00';
		   l_reject_reason_code2 := '00';
		   l_reject_reason_code3 := '00';
		   l_element_name	 := 'Nominal IZA Contribution';

		   l_record_eff_start_date:=to_date(p_process_yr_mm,'YYYYMM');
		   l_record_eff_end_date:=last_day(to_date(p_process_yr_mm,'YYYYMM'));
		   l_province_code := substr(p_line_read,2,2);
		   l_client_num := SUBSTR(p_line_read,4,3);
		   l_sub_emplr_num := SUBSTR(p_line_read,22,3);
		   l_exchange_number := SUBSTR(p_line_read,70,15);
		   l_participant_number := SUBSTR(p_line_read,7,15);
	           l_employee_name := SUBSTR(p_line_read,25,24) || SUBSTR(p_line_read,49,6) || SUBSTR(p_line_read,55,7) ;
		   l_date_of_birth := to_date(SUBSTR(p_line_read,62,8),'YYYYMMDD');


		   if g_debug then

		   -- input parameters
			hr_utility.set_location('l_province_code                '||l_province_code,900);
			hr_utility.set_location('l_client_num           '||l_client_num,900);
			hr_utility.set_location('l_sub_emplr_num        '||l_sub_emplr_num,900 );
			hr_utility.set_location('l_exchange_number         '||l_exchange_number,900);
			hr_utility.set_location('l_participant_number   '||l_participant_number,900);
			hr_utility.set_location('l_employee_name               '||l_employee_name,900);

		   end if;


		   IF substr(p_line_read,101,6) <> '000000' THEN

			   l_iza_corr_yr_mm:=substr(p_line_read,101,6);
			   l_iza_corr_start_date:=to_date(l_iza_corr_yr_mm,'YYYYMM');
			   l_iza_corr_end_date:=last_day(to_date(l_iza_corr_yr_mm,'YYYYMM'));
		   END IF;

		   IF substr(p_line_read,126,6) <> '000000' THEN
			   l_iza_corr2_yr_mm:=substr(p_line_read,126,6);
			   l_iza_corr2_start_date:=to_date(l_iza_corr2_yr_mm,'YYYYMM');
			   l_iza_corr2_end_date:=last_day(to_date(l_iza_corr2_yr_mm,'YYYYMM'));
		   END IF;

		   l_contribution1_sign := substr(p_line_read,92,1);
		   l_contribution1 := fnd_number.canonical_to_number(substr(p_line_read,85,5) || '.' || substr(p_line_read,90,2)) ;
		   IF l_contribution1_sign = '-' THEN
		   	l_contribution1 := (-1) * l_contribution1;
		   END IF;

		   l_corr_cont1_sign := substr(p_line_read,100,1);
		   l_corr_cont1 := fnd_number.canonical_to_number(substr(p_line_read,93,5) || '.' || substr(p_line_read,98,2));
		   IF l_corr_cont1_sign = '-' THEN
		   	l_corr_cont1 := (-1) * l_corr_cont1;
		   END IF;

		   l_contribution2_sign := substr(p_line_read,117,1);
		   l_contribution2 := fnd_number.canonical_to_number(substr(p_line_read,110,5) || '.' || substr(p_line_read,115,2));
		   IF l_contribution2_sign = '-' THEN
		   	l_contribution2 := (-1) * l_contribution2;
		   END IF;

		   l_corr_cont2_sign := substr(p_line_read,125,1);
		   l_corr_cont2 := fnd_number.canonical_to_number(substr(p_line_read,118,5) || '.' || substr(p_line_read,123,2));
		   IF l_corr_cont2_sign = '-' THEN
		   	l_corr_cont2 := (-1) * l_corr_cont2;
		   END IF;

		   l_employee_number := ltrim(substr(p_line_read,76,9),'0');

		   if g_debug then

		   -- input parameters
			hr_utility.set_location('l_contribution1                '||l_contribution1,950);
			hr_utility.set_location('l_corr_cont1           '||l_corr_cont1,950);
			hr_utility.set_location('l_contribution2        '||l_contribution2,950 );
			hr_utility.set_location('l_corr_cont2         '||l_corr_cont2,950);
			hr_utility.set_location('l_participant_number   '||l_participant_number,950);
			hr_utility.set_location('l_employee_number               '||l_employee_number,950);

		   end if;



		   -- Break the line up in its fields.

		   --  break the line into various fields and validate them if they need
		   -- to be accepted or rejected for BEE. Use iza_validation function to validate the record


			-- Check if the Contribution amount IZA is not zero, then validate the record
			-- if the record gets validated then call create_batch_line procedure to create
			-- the record in pay_batch_lines


			IF l_contribution1 <> 0 OR l_contribution2 <> 0 THEN
		   		iza_validation(p_bg_id,l_record_eff_start_date,l_record_eff_end_date,l_exchange_number,l_client_num,l_sub_emplr_num,p_org_id,p_org_struct_version_id,l_person_id,l_assignment_id,l_assignment_num,l_reject_reason_code1);
		   	END IF;


			OPEN csr_employee_terminate(l_person_id,p_bg_id,l_record_eff_start_date,l_record_eff_end_date);
			FETCH csr_employee_terminate into l_record_term_date;
			CLOSE csr_employee_terminate;

			IF l_record_term_date IS NOT NULL then
				l_entry_eff_date := l_record_term_date;
			ELSE
				l_entry_eff_date := l_record_eff_end_date;
			END IF;


			if g_debug then

			   -- input parameters
				hr_utility.set_location('l_person_id                '||l_person_id,970);
				hr_utility.set_location('l_assignment_id           '||l_assignment_id,970);
				hr_utility.set_location('p_org_id        '||p_org_id,970);
				hr_utility.set_location('l_assignment_num                '||l_assignment_num,970);
				hr_utility.set_location('l_reject_reason_code1           '||l_reject_reason_code1,970);
			end if;


			IF l_corr_cont1 <> 0 THEN
		   		iza_validation(p_bg_id,l_iza_corr_start_date,l_iza_corr_end_date,l_exchange_number,l_client_num,l_sub_emplr_num,p_org_id,p_org_struct_version_id,l_person_id,l_assignment_id,l_assignment_num,l_reject_reason_code2);
		   	END IF;


			OPEN csr_employee_terminate(l_person_id,p_bg_id,l_iza_corr_start_date,l_iza_corr_end_date);
			FETCH csr_employee_terminate into l_corr_term_date;
			CLOSE csr_employee_terminate;

			IF l_corr_term_date IS NOT NULL then
				l_entry_corr_eff_date := l_corr_term_date;
			ELSE
				l_entry_corr_eff_date := l_iza_corr_end_date;
			END IF;


			if g_debug then

			   -- input parameters
				hr_utility.set_location('l_person_id                '||l_person_id,970);
				hr_utility.set_location('l_assignment_id           '||l_assignment_id,970);
				hr_utility.set_location('p_org_id        '||p_org_id,970);
				hr_utility.set_location('l_assignment_num                '||l_assignment_num,970);
				hr_utility.set_location('l_reject_reason_code2           '||l_reject_reason_code2,970);
			end if;


			IF l_corr_cont2 <> 0 THEN
		   		iza_validation(p_bg_id,l_iza_corr2_start_date,l_iza_corr2_end_date,l_exchange_number,l_client_num,l_sub_emplr_num,p_org_id,p_org_struct_version_id,l_person_id,l_assignment_id,l_assignment_num,l_reject_reason_code3);
		   	END IF;


			OPEN csr_employee_terminate(l_person_id,p_bg_id,l_iza_corr2_start_date,l_iza_corr2_end_date);
			FETCH csr_employee_terminate into l_corr2_term_date;
			CLOSE csr_employee_terminate;

			IF l_corr2_term_date IS NOT NULL then
				l_entry_corr2_eff_date := l_corr2_term_date;
			ELSE
				l_entry_corr2_eff_date := l_iza_corr2_end_date;
			END IF;

			if g_debug then

			   -- input parameters
				hr_utility.set_location('l_person_id                '||l_person_id,1000);
				hr_utility.set_location('l_assignment_id           '||l_assignment_id,1000);
				hr_utility.set_location('p_org_id        '||p_org_id,1000 );
				hr_utility.set_location('l_assignment_num                '||l_assignment_num,1000);
				hr_utility.set_location('l_reject_reason_code3           '||l_reject_reason_code3,1000);
			end if;




		   IF l_reject_reason_code1 = '00' AND l_reject_reason_code2 = '00' AND l_reject_reason_code3 = '00' THEN


			IF l_contribution1 <> 0 THEN


			    -- Create a batch line for every line found in the file.
			    create_batch_line (p_session_date  => p_eff_date
			    		      ,p_batch_id      => p_batch_id
			    		      ,p_assignment_id => l_assignment_id
			    		      ,p_assignment_number => l_assignment_num
			    		      ,p_batch_sequence  => p_batch_seq
			    		      ,p_effective_date => l_entry_eff_date
			    		      ,p_date_earned => l_entry_eff_date
			    		      ,p_element_name => l_element_name
			    		      ,p_element_type_id => g_element_type_id
			    		      ,p_value_1 => fnd_number.number_to_canonical(l_contribution1)
			    		      ,p_bline_id => p_batch_line_id
			    		      ,p_obj_vn => p_bl_ovn
			    		      );
			END IF;

			IF l_corr_cont1 <> 0 THEN

			    -- Create a batch line for every line found in the file.
			    create_batch_line (p_session_date  => p_eff_date
			    		      ,p_batch_id      => p_batch_id
			    		      ,p_assignment_id => l_assignment_id
			    		      ,p_assignment_number => l_assignment_num
			    		      ,p_batch_sequence  => p_batch_seq
			    		      ,p_effective_date => l_entry_corr_eff_date
			    		      ,p_date_earned => l_entry_corr_eff_date
			    		      ,p_element_name => l_element_name
			    		      ,p_element_type_id => g_element_type_id
			    		      ,p_value_1 => fnd_number.number_to_canonical(l_corr_cont1)
			    		      ,p_bline_id => p_batch_line_id
			    		      ,p_obj_vn => p_bl_ovn
			    		      );

			END IF;


			IF l_contribution2 <> 0 THEN


			    -- Create a batch line for every line found in the file.
			    create_batch_line (p_session_date  => p_eff_date
			    		      ,p_batch_id      => p_batch_id
			    		      ,p_assignment_id => l_assignment_id
			    		      ,p_assignment_number => l_assignment_num
			    		      ,p_batch_sequence  => p_batch_seq
			    		      ,p_effective_date => l_entry_eff_date
			    		      ,p_date_earned => l_entry_eff_date
			    		      ,p_element_name => l_element_name
			    		      ,p_element_type_id => g_element_type_id
			    		      ,p_value_1 => fnd_number.number_to_canonical(l_contribution2)
			    		      ,p_bline_id => p_batch_line_id
			    		      ,p_obj_vn => p_bl_ovn
			    		      );
			END IF;


			IF l_corr_cont2 <> 0 THEN


			    -- Create a batch line for every line found in the file.
			    create_batch_line (p_session_date  => p_eff_date
			    		      ,p_batch_id      => p_batch_id
			    		      ,p_assignment_id => l_assignment_id
			    		      ,p_assignment_number => l_assignment_num
			    		      ,p_batch_sequence  => p_batch_seq
			    		      ,p_effective_date => l_entry_corr2_eff_date
			    		      ,p_date_earned => l_entry_corr2_eff_date
			    		      ,p_element_name => l_element_name
			    		      ,p_element_type_id => g_element_type_id
			    		      ,p_value_1 => fnd_number.number_to_canonical(l_corr_cont2)
			    		      ,p_bline_id => p_batch_line_id
			    		      ,p_obj_vn => p_bl_ovn
			    		      );

			END IF;


			    l_process_status:='PROCESSED';
			    insert into PAY_NL_IZA_UPLD_STATUS(  BUSINESS_GROUP_ID
								    ,ORGANIZATION_ID
								    ,EMPLOYER_NUMBER
								    ,SUB_EMPLOYER_NUMBER
								    ,PAYROLL_CENTER
								    ,PROCESS_YEAR_MONTH
								    ,PERSON_ID
								    ,EMPLOYEE_NUMBER
								    ,PROCESS_STATUS
								    ,PROVINCE_CODE
								    ,DATE_OF_BIRTH
								    ,PARTICIPANT_NUMBER
								    ,EMPLOYEE_NAME
								    ,CONTRIBUTION_1
								    ,CORRECTION_CONTRIBUTION_1
								    ,DATE_CORRECTION_1
								    ,CONTRIBUTION_2
								    ,CORRECTION_CONTRIBUTION_2
								    ,DATE_CORRECTION_2
								    ,REJECT_REASON)
				select   p_bg_id
					,p_org_id
				        ,decode(l_client_num,'000','0',ltrim(l_client_num,'0'))
				        ,decode(l_sub_emplr_num,'000','0',ltrim(l_sub_emplr_num,'0'))
				        ,p_payroll_center
				        ,l_record_eff_end_date
				        ,l_person_id
				        ,l_employee_number
				        ,l_process_status
				        ,l_province_code
				        ,l_date_of_birth
				        ,l_participant_number
				        ,l_employee_name
				        ,l_contribution1
				        ,l_corr_cont1
				        ,l_iza_corr_end_date
				        ,l_contribution2
				        ,l_corr_cont2
			       		,l_iza_corr2_end_date
			       		,NULL
			       	from	 dual;


		   ELSE

		   	select decode(l_reject_reason_code1,'00',decode(l_reject_reason_code2,'00',l_reject_reason_code3,l_reject_reason_code2),l_reject_reason_code1) into l_reject_code from dual;
		   	l_process_status:='REJECTED';

				insert into PAY_NL_IZA_UPLD_STATUS(  BUSINESS_GROUP_ID
								    ,ORGANIZATION_ID
								    ,EMPLOYER_NUMBER
								    ,SUB_EMPLOYER_NUMBER
								    ,PAYROLL_CENTER
								    ,PROCESS_YEAR_MONTH
								    ,PERSON_ID
								    ,EMPLOYEE_NUMBER
								    ,PROCESS_STATUS
								    ,PROVINCE_CODE
				        			    ,DATE_OF_BIRTH
				        			    ,PARTICIPANT_NUMBER
				        			    ,EMPLOYEE_NAME
								    ,CONTRIBUTION_1
								    ,CORRECTION_CONTRIBUTION_1
								    ,DATE_CORRECTION_1
								    ,CONTRIBUTION_2
								    ,CORRECTION_CONTRIBUTION_2
								    ,DATE_CORRECTION_2
								    ,REJECT_REASON)
				select   p_bg_id
					,p_org_id
				        ,decode(l_client_num,'000','0',ltrim(l_client_num,'0'))
				        ,decode(l_sub_emplr_num,'000','0',ltrim(l_sub_emplr_num,'0'))
				        ,p_payroll_center
				        ,l_record_eff_end_date
				        ,l_person_id
				        ,l_employee_number
				        ,l_process_status
				        ,l_province_code
				        ,l_date_of_birth
				        ,l_participant_number
				        ,l_employee_name
				        ,l_contribution1
				        ,l_corr_cont1
				        ,l_iza_corr_end_date
				        ,l_contribution2
				        ,l_corr_cont2
			       		,l_iza_corr2_end_date
			       		,l_reject_code
			       	from 	 dual;


		   END IF;



		    -- commit the records uppon reaching the commit point

		    IF MOD (p_batch_seq, c_commit_point) = 0
		    THEN
		       COMMIT;
			 NULL;
		    END IF;

EXCEPTION
	WHEN OTHERS then
	HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	HR_UTILITY.RAISE_ERROR;


end val_create_batch_line;




/*-----------------------------------------------------------------------
|Name       : iza_validation                                            |
|Type	    : Procedure				                        |
|Description: Procedure to validate the Data Record. This procedure     |
|	      decides if the record needs to be processed or rejected   |
|	      If the record needs to rejected, this Procedure           |
|	      sets the value of the OUT parameter p_reject_reason_code  |
|             equalt to the reject reason code as given in the          |
|             NL_IZA_REJECT_REASON lookup. Else the p_reject_reason_code|
|             is set to '00'                                            |
-----------------------------------------------------------------------*/



PROCEDURE iza_validation(p_business_group_id	IN NUMBER
		        ,p_period_start_date 	IN DATE
		        ,p_period_end_date 	IN DATE
		        ,p_exchange_number 	IN VARCHAR2
		        ,p_client_num		IN VARCHAR2
		        ,p_sub_emplr_num	IN VARCHAR2
			,p_org_id		IN NUMBER
			,p_org_struct_version_id IN NUMBER
		        ,p_person_id		OUT NOCOPY NUMBER
		        ,p_assignment_id	OUT NOCOPY NUMBER
		        ,p_assignment_num	OUT NOCOPY VARCHAR2
		        ,p_reject_reason_code	OUT NOCOPY VARCHAR2) IS



	cursor csr_abs_days(v_person_id number,v_bg_id number,v_period_start_date date,v_period_end_date date) IS
	select sum((NVL(paa.date_end,paa.date_start) - paa.date_start)+1)
	from PER_ABSENCE_ATTENDANCES paa
	where paa.business_group_id = v_bg_id
	and   paa.person_id = v_person_id
	and   decode(paa.ABS_INFORMATION_CATEGORY,'NL_S',ABS_INFORMATION2,ABS_INFORMATION1) = 'Y'
	and   v_period_end_date >= paa.date_start
	and   v_period_start_date <= NVL(paa.date_end,v_period_start_date);


	cursor csr_contract_other_cmpny(v_person_id number,v_bg_id number,v_period_start_date date,v_period_end_date date) IS
	select pap.per_information16
	from  per_all_people_f  pap
	where PER_INFORMATION_CATEGORY='NL'
	and   pap.business_group_id = v_bg_id
	and   pap.person_id = v_person_id
	and   pap.per_information16 = 'Y'
	and   v_period_end_date >= pap.effective_start_date
	and   v_period_start_date <= NVL(pap.effective_end_date,v_period_start_date);


	cursor csr_emp_num_exists(v_employee_num varchar2,v_bg_id number,v_period_start_date date,v_period_end_date date) IS
	SELECT pap.person_id,paa.assignment_id,paa.assignment_number
	FROM   per_all_people_f pap
	      ,per_all_assignments_f paa
	WHERE  ltrim(substr(pap.employee_number,1,9),'0') = v_employee_num
	AND    paa.person_id = pap.person_id
	AND    pap.business_group_id = v_bg_id
	AND    v_period_end_date >= pap.effective_start_date
	AND    v_period_start_date <= pap.effective_end_date;



	cursor csr_employee_exists(v_person_id number,v_bg_id number,v_period_start_date date,v_period_end_date date) IS
	select pap.current_employee_flag
	from  per_all_people_f  pap
	where PER_INFORMATION_CATEGORY='NL'
	and   pap.business_group_id = v_bg_id
	and   pap.person_id = v_person_id
	and   pap.current_employee_flag = 'Y'
	and   v_period_end_date >= pap.effective_start_date
	and   v_period_start_date <= pap.effective_end_date;


	cursor csr_iza_insured(v_assignment_id number,v_period_start_date date,v_period_end_date date) IS
	select pae_iza.AEI_INFORMATION3
	from  PER_ASSIGNMENT_EXTRA_INFO pae_iza
	     ,PER_ASSIGNMENT_EXTRA_INFO pae_sii
	where pae_iza.AEI_INFORMATION_CATEGORY = 'NL_IZA_INFO'
	and   pae_iza.assignment_id = v_assignment_id
	and   v_period_end_date >= fnd_date.canonical_to_date(pae_iza.AEI_INFORMATION1)
	and   v_period_start_date <= NVL(fnd_date.canonical_to_date(pae_iza.AEI_INFORMATION2),v_period_start_date)
	and   pae_sii.AEI_INFORMATION_CATEGORY = 'NL_SII'
	and   pae_sii.AEI_INFORMATION3 in ('ZFW','AMI')
	and   pae_sii.AEI_INFORMATION4 = '4'
	and   v_period_end_date >= fnd_date.canonical_to_date(pae_sii.AEI_INFORMATION1)
	and   v_period_start_date <= NVL(fnd_date.canonical_to_date(pae_sii.AEI_INFORMATION2),v_period_start_date)
	and   pae_sii.assignment_id = pae_iza.assignment_id;


	cursor csr_exchange_num_valid (v_org_id number,v_bg_id number,v_person_id number,v_period_start_date date,v_period_end_date date) IS
	select paa.assignment_id, paa.assignment_number
	from   per_all_assignments_f paa
	where  paa.person_id = v_person_id
	and    paa.primary_flag = 'Y'
	and    paa.business_group_id = v_bg_id
	and    hr_nl_org_info.Get_iza_Org_Id(p_org_struct_version_id,paa.organization_id) = v_org_id
	and    paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_assignment_status_types past, per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   past.per_system_status = 'ACTIVE_ASSIGN'
		and   asg.assignment_status_type_id = past.assignment_status_type_id
		and   asg.effective_start_date <= v_period_end_date
		and   asg.effective_end_date >= v_period_start_date
		);



	l_length_process_period number;
	l_leave_days		number;
	l_employee_number	varchar2(50);
	l_iza_insured_flag	varchar2(10);
	l_contract_other_cmpny	varchar2(10);
	l_current_employee_flag	varchar2(10);
	l_already_rejected_flag	varchar2(10);
	l_org_struc_version_id 	number;



BEGIN


	p_reject_reason_code :='00' ;
	l_already_rejected_flag := 'N';

	l_length_process_period := (p_period_end_date - p_period_start_date) + 1;
	l_employee_number := ltrim(substr(p_exchange_number,7,9),'0');


	if g_debug then

	   -- input parameters
		hr_utility.set_location('l_length_process_period                '||l_length_process_period,1350);
		hr_utility.set_location('l_employee_number           '||l_employee_number,1350);
	end if;


	OPEN csr_emp_num_exists(l_employee_number,p_business_group_id,p_period_start_date,p_period_end_date) ;
	FETCH csr_emp_num_exists into p_person_id,p_assignment_id,p_assignment_num;
	CLOSE csr_emp_num_exists;

	if g_debug then

	   -- input parameters
		hr_utility.set_location('p_person_id                '||p_person_id,1350);
		hr_utility.set_location('p_assignment_id           '||p_assignment_id,1350);
		hr_utility.set_location('p_assignment_num        '||p_assignment_num,1350 );
	end if;


	IF p_person_id IS NULL THEN
		p_reject_reason_code := '05';
		l_already_rejected_flag := 'Y';
	END IF;

	IF l_already_rejected_flag = 'N' THEN

		OPEN csr_employee_exists(p_person_id,p_business_group_id,p_period_start_date,p_period_end_date);
		FETCH csr_employee_exists INTO l_current_employee_flag;
		CLOSE csr_employee_exists;

		if g_debug then

		   -- input parameters
			hr_utility.set_location('l_current_employee_flag                '||l_current_employee_flag,1350);
		end if;


		IF l_current_employee_flag IS NULL THEN
			p_reject_reason_code := '01';
			l_already_rejected_flag := 'Y';
		END IF;
	END IF;


	IF l_already_rejected_flag = 'N' THEN
		OPEN csr_iza_insured(p_assignment_id,p_period_start_date,p_period_end_date);
		FETCH csr_iza_insured INTO l_iza_insured_flag;
		CLOSE csr_iza_insured;

		if g_debug then

		   -- input parameters
			hr_utility.set_location('l_iza_insured_flag                '||l_iza_insured_flag,1400);
		end if;

		IF l_iza_insured_flag IS NULL THEN
			p_reject_reason_code := '02';
			l_already_rejected_flag := 'Y';
		END IF;
	END IF;


	IF l_already_rejected_flag = 'N' THEN
		OPEN csr_contract_other_cmpny(p_person_id,p_business_group_id,p_period_start_date,p_period_end_date);
		FETCH csr_contract_other_cmpny INTO l_contract_other_cmpny;
		CLOSE csr_contract_other_cmpny;

		if g_debug then

		   -- input parameters
			hr_utility.set_location('l_contract_other_cmpny                '||l_contract_other_cmpny,1400);
		end if;

		IF l_contract_other_cmpny IS NOT NULL THEN
			p_reject_reason_code := '03';
			l_already_rejected_flag := 'Y';
		END IF;

	END IF;



	IF l_already_rejected_flag = 'N' THEN
		OPEN csr_abs_days(p_person_id,p_business_group_id,p_period_start_date,p_period_end_date);
		FETCH csr_abs_days into l_leave_days;
		CLOSE csr_abs_days;


		if g_debug then

		   -- input parameters
			hr_utility.set_location('l_leave_days                '||l_leave_days,1400);
		end if;

		IF l_leave_days = l_length_process_period THEN
			p_reject_reason_code := '04';
			l_already_rejected_flag := 'Y';
		END IF;
	END IF;



	if g_debug then

	   -- input parameters
		hr_utility.set_location('p_org_id                '||p_org_id,1450);
	end if;


	IF l_already_rejected_flag = 'N' THEN


		IF p_org_id IS NOT NULL then

			OPEN csr_exchange_num_valid(p_org_id,p_business_group_id,p_person_id,p_period_start_date,p_period_end_date);
			FETCH csr_exchange_num_valid INTO p_assignment_id,p_assignment_num;
			CLOSE csr_exchange_num_valid;

			if g_debug then

			   -- input parameters
				hr_utility.set_location('p_assignment_id                '||p_assignment_id,1450);
				hr_utility.set_location('p_assignment_num                '||p_assignment_num,1450);
			end if;

			IF p_assignment_id IS NULL then
				p_reject_reason_code := '05';
				l_already_rejected_flag := 'Y';
			END IF;
		ELSE
			p_reject_reason_code := '05';
			l_already_rejected_flag := 'Y';

		END IF;
	END IF;


EXCEPTION
	WHEN OTHERS then
	HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	HR_UTILITY.RAISE_ERROR;


end iza_validation;


/*-----------------------------------------------------------------------
|Name       : purge_iza_process_status              	                |
|Type	    : Procedure				                        |
|Description: Driving Procedure for the concurrent program for          |
|             IZA Upload Purge Process. This Procedure will purge all   |
|             the records from the Process Status table that are no     |
|             longer required                                           |
-----------------------------------------------------------------------*/

procedure purge_iza_process_status (p_errbuf            OUT     NOCOPY  VARCHAR2
				   ,p_retcode		OUT     NOCOPY  VARCHAR2
				   ,p_business_group_id IN      NUMBER
				   ,p_month_from 	IN      VARCHAR2
				   ,p_month_to	    	IN      VARCHAR2
				   ,p_org_struct_id	IN	NUMBER
				   ,p_employer_id	IN      NUMBER
				   ) IS

l_period_start_date date;
l_period_end_date date;

begin
	l_period_start_date := to_date(p_month_from,'MMYYYY');
	l_period_end_date := last_day(to_date(p_month_to,'MMYYYY'));

	DELETE from PAY_NL_IZA_UPLD_STATUS pizas
	WHERE  pizas.process_year_month between l_period_start_date and l_period_end_date
	AND    pizas.organization_id = p_employer_id
	AND    pizas.business_group_id = p_business_group_id;

EXCEPTION
	WHEN OTHERS then
	HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
	HR_UTILITY.RAISE_ERROR;

end purge_iza_process_status;

END PAY_NL_IZA_UPLOAD;

/
