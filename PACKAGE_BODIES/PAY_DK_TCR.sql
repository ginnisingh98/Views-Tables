--------------------------------------------------------
--  DDL for Package Body PAY_DK_TCR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_TCR" AS
/* $Header: pydktaxreq.pkb 120.0.12010000.1 2008/10/15 11:37:38 pvelugul noship $ */

	PROCEDURE GET_DATA (
	p_business_group_id		IN NUMBER,
	p_legal_employer		IN VARCHAR2 ,
	p_start_date			IN VARCHAR2,
	p_test_submission		IN VARCHAR2,
	p_template_name			IN VARCHAR2,
	p_xml                           OUT NOCOPY CLOB
	)
	IS

	l_counter NUMBER := 0;
	l_rec_counter NUMBER:=1;
	l_date VARCHAR2(10);
	l_time VARCHAR2(10);
	l_sender_type VARCHAR2(2);
	l_test_submission VARCHAR2(2);
	l_le_cvr_number VARCHAR2(10);
	l_se_number VARCHAR2(10);
	l_cvr_number VARCHAR2(10);
	l_cpr_number VARCHAR2(15);
	l_req_status VARCHAR2(25);
	l_tax_card_type VARCHAR2(3);
	l_sex VARCHAR2(1);
	l_bg_id per_all_assignments_f.business_group_id%type;
	l_le_id VARCHAR2(60);
	l_style per_addresses_v.style%type;
	l_flag NUMBER:=0;
	l_effective_start_date DATE;
	l_effective_end_date DATE;
	l_input_value_id pay_input_values_f.input_value_id%type;
	l_update_warning BOOLEAN := FALSE;

	NO_E_INCOME_DATA_SUPPLIER EXCEPTION;

	/*Legal Employer Information*/
	Cursor csr_Legal_Emp_Details (csr_v_legal_emp_id  hr_organization_information.ORGANIZATION_ID%TYPE)
	IS
	SELECT o1.name ,hoi2.ORG_INFORMATION1 , hoi2.ORG_INFORMATION2, hoi2.ORG_INFORMATION3, hoi2.ORG_INFORMATION4, hoi2.ORG_INFORMATION5, hoi2.ORG_INFORMATION6, hoi2.ORG_INFORMATION13
	FROM hr_organization_units o1
	, hr_organization_information hoi1
	, hr_organization_information hoi2
	WHERE  o1.business_group_id =p_business_group_id
	AND hoi1.organization_id = o1.organization_id
	AND hoi1.organization_id =  csr_v_legal_emp_id
	AND hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	AND hoi1.org_information_context = 'CLASS'
	AND o1.organization_id =hoi2.organization_id
	AND hoi2.ORG_INFORMATION_CONTEXT='DK_LEGAL_ENTITY_DETAILS' ;

	rg_Legal_Emp_Details csr_Legal_Emp_Details%ROWTYPE;

	/* Service Provider information */
	CURSOR service_provider_details
	IS
		SELECT * FROM hr_organization_information
		WHERE org_information_context = 'DK_SERVICE_PROVIDER_DETAILS'
		AND organization_id IN (
		SELECT organization_id FROM hr_organization_units
		WHERE business_group_id= p_business_group_id);

	sp service_provider_details%ROWTYPE;

	/* Get the person id*/
	CURSOR csr_get_person_id(p_le_id VARCHAR2, p_bg_id NUMBER)
	IS
		select pap.person_id, paa.assignment_id, pap.NATIONAL_IDENTIFIER, paa.assignment_number, to_char(pap.date_of_birth,'yyyymmdd') dob,
		first_name||' '||middle_names||' '||last_name pname, pap.effective_start_date
		from per_all_assignments_f paa,
		per_all_people_f pap, hr_soft_coding_keyflex scl  where
		paa.soft_coding_keyflex_id = scl.soft_coding_keyflex_id
		and scl.segment1 = p_le_id
		and paa.business_group_id = p_bg_id
		and paa.PRIMARY_FLAG='Y'
		and pap.person_id=paa.person_id
		and pap.effective_start_date = (SELECT MAX(date_start) lhd FROM per_periods_of_service
		WHERE person_id=pap.person_id)
		and pap.effective_start_date >= fnd_date.canonical_to_date(p_start_date)
		and pap.effective_start_date = paa.effective_start_date;

	rg_csr_get_person_id csr_get_person_id%ROWTYPE;

	/* Get the tax card details */
	CURSOR csr_get_tax_card_details(p_assignment_id per_all_assignments_f.assignment_id%type, p_input_value pay_input_values_f.name%type, p_hire_date per_all_people_f.effective_start_date%type) IS
		SELECT  ee.effective_start_date, eev1.screen_entry_value, ee.element_entry_id, ee.object_version_number, iv1.input_value_id
		FROM   --per_all_assignments_f      asg1
		pay_element_types_f        et
		,pay_input_values_f         iv1
		,pay_element_entries_f      ee
		,pay_element_entry_values_f eev1
		WHERE -- asg1.assignment_id    = p_assignment_id
		     et.element_name       = 'Tax Card'
		AND  et.legislation_code   = 'DK'
		AND  iv1.element_type_id   = et.element_type_id
		AND  iv1.name              = p_input_value
		AND  ee.element_type_id    = et.element_type_id
		AND  ee.assignment_id      = p_assignment_id--asg1.assignment_id
		AND  eev1.element_entry_id = ee.element_entry_id
		AND  eev1.input_value_id   = iv1.input_value_id
		and eev1.effective_start_date = ee.effective_start_date
		and p_hire_date between ee.effective_start_date and ee.effective_end_date
		and p_hire_date between et.effective_start_date and et.effective_end_Date
		and p_hire_date between iv1.effective_start_date and iv1.effective_end_date;

	rg_csr_get_tax_card_details csr_get_tax_card_details%rowtype;

	/* Get the territory */
	CURSOR csr_get_territory(pid per_all_people_f.person_id%type) IS
		SELECT *
		FROM per_addresses_v
		WHERE person_id =pid
		and primary_flag='Y'
		and business_group_id=p_business_group_id;

	rg_csr_get_territory csr_get_territory%rowtype;

	/* End of Cursors */
	BEGIN

	/* Pick up the data  related to Record 1000*/

--	fnd_file.put_line(fnd_file.log,'1');
	gtagdata(l_counter).TagName := 'REC_1000';
	gtagdata(l_counter).TagValue := 'REC_1000';
	l_counter := l_counter + 1;

	/* line num */
	gtagdata(l_counter).TagName := 'RT1000_01';
	gtagdata(l_counter).TagValue := lpad(to_char(l_rec_counter),7,'0');
	l_counter := l_counter + 1;

	/*Rec num */
	gtagdata(l_counter).TagName := 'RT1000_02';
	gtagdata(l_counter).TagValue := '1000';
	l_counter := l_counter + 1;

	/*Date sent*/
	SELECT to_char(sysdate,'yyyymmdd') INTO l_date FROM dual;
	gtagdata(l_counter).TagName := 'RT1000_03';
	gtagdata(l_counter).TagValue := l_date;
	l_counter := l_counter + 1;

	/*Time sent*/
	SELECT to_char(sysdate,'hhmiss') INTO l_time FROM dual;
	gtagdata(l_counter).TagName := 'RT1000_04';
	gtagdata(l_counter).TagValue := l_time;
	l_counter := l_counter + 1;

	OPEN  csr_Legal_Emp_Details(p_legal_employer);
	FETCH csr_Legal_Emp_Details INTO rg_Legal_Emp_Details;
	l_le_cvr_number := rg_Legal_Emp_Details.ORG_INFORMATION1; -- this is for rec 2001
	l_cvr_number:= rg_Legal_Emp_Details.ORG_INFORMATION1;
	l_se_number := rg_Legal_Emp_Details.ORG_INFORMATION5;
	CLOSE csr_Legal_Emp_Details;
	l_sender_type:='01';

	if(rg_Legal_Emp_Details.ORG_INFORMATION3 = 'N') then
		OPEN service_provider_details;
		FETCH service_provider_details INTO sp;
		l_cvr_number:=sp.org_information1;
		l_se_number:=sp.org_information1;
		CLOSE service_provider_details;

		/* If the service provider has Data Supplier set to 'N', output the message and stop processing */
		if(sp.org_information3<>'Y') then
			fnd_file.put_line(fnd_file.log,HR_DK_UTILITY.GET_MESSAGE('PAY','HR_377103_DK_EINCOME_STATUS'));
			RAISE NO_E_INCOME_DATA_SUPPLIER;
		end if;

		l_sender_type:='02';
	end if;

	/*SE number*/
	gtagdata(l_counter).TagName := 'RT1000_05';
	gtagdata(l_counter).TagValue := l_se_number; -- lpad(rg_csr_1000.action_information6,8,'0')
	l_counter := l_counter + 1;

	/*CVR number*/
	gtagdata(l_counter).TagName := 'RT1000_06';
	gtagdata(l_counter).TagValue := l_cvr_number;
	l_counter := l_counter + 1;

	/*Sender type*/
	gtagdata(l_counter).TagName := 'RT1000_07';
	gtagdata(l_counter).TagValue := l_sender_type;
	l_counter := l_counter + 1;

	/*Filler*/
	gtagdata(l_counter).TagName := 'RT1000_08';
	gtagdata(l_counter).TagValue := lpad('0',5,'0');
	l_counter := l_counter + 1;

	/*Report Method name*/
	gtagdata(l_counter).TagName := 'RT1000_09';
	gtagdata(l_counter).TagValue := '0'; -- constant
	l_counter := l_counter + 1;

	/*IT System*/
	gtagdata(l_counter).TagName := 'RT1000_10';
	gtagdata(l_counter).TagValue := 'Oracle Payroll';
	l_counter := l_counter + 1;

	/* IT System Version */
	gtagdata(l_counter).TagName := 'RT1000_11';
	gtagdata(l_counter).TagValue := '1'; -- constant
	l_counter := l_counter + 1;

	/*Main sender ID*/
	gtagdata(l_counter).TagName := 'RT1000_12';
	gtagdata(l_counter).TagValue := l_cvr_number;
	l_counter := l_counter + 1;

	/*E-Income version*/
	gtagdata(l_counter).TagName := 'RT1000_13';
	gtagdata(l_counter).TagValue := '2.0';
	l_counter := l_counter + 1;

	/*Test Marking*/
	if(p_test_submission='Y') then
		l_test_submission:='T';
	else
		l_test_submission:='P';
	end if;
	gtagdata(l_counter).TagName := 'RT1000_14';
	gtagdata(l_counter).TagValue := l_test_submission;
	l_counter := l_counter + 1;

	/*Filler */
	gtagdata(l_counter).TagName := 'RT1000_15';
	gtagdata(l_counter).TagValue := '';  -- 16 spaces
	l_counter := l_counter + 1;

	/*Filler */
	gtagdata(l_counter).TagName := 'RT1000_16';
	gtagdata(l_counter).TagValue := '';  -- 16 spaces
	l_counter := l_counter + 1;

	/*Indication of E-Income*/
	gtagdata(l_counter).TagName := 'RT1000_17';
	gtagdata(l_counter).TagValue := 'E';
	l_counter := l_counter + 1;

--	fnd_file.put_line(fnd_file.log,'2');

	-- Record 2001
	gtagdata(l_counter).TagName := 'REC_2001';
	gtagdata(l_counter).TagValue := 'REC_2001';
	l_counter := l_counter + 1;

	l_rec_counter:=l_rec_counter+1;
	/* line num */
	gtagdata(l_counter).TagName := 'RT2001_01';
	gtagdata(l_counter).TagValue := lpad(to_char(l_rec_counter),7,'0');
	l_counter := l_counter + 1;

	/*Rec num */
	gtagdata(l_counter).TagName := 'RT2001_02';
	gtagdata(l_counter).TagValue := '2001';
	l_counter := l_counter + 1;

	/*Filler*/
	gtagdata(l_counter).TagName := 'RT2001_03';
	gtagdata(l_counter).TagValue := ''; --16 spaces
	l_counter := l_counter + 1;

	/*Company */
	gtagdata(l_counter).TagName := 'RT2001_04';
	gtagdata(l_counter).TagValue := l_le_cvr_number;
	l_counter := l_counter + 1;

	/*Termination of company*/
	gtagdata(l_counter).TagName := 'RT2001_05';
	gtagdata(l_counter).TagValue := '';
	l_counter := l_counter + 1;

	/*Currency */
	gtagdata(l_counter).TagName := 'RT2001_06';
	gtagdata(l_counter).TagValue := 'DKK'; -- constant
	l_counter := l_counter + 1;

--	fnd_file.put_line(fnd_file.log,'3');
	l_le_id:= p_legal_employer;

--	fnd_file.put_line(fnd_file.log,'4');
	l_bg_id:= to_number(p_business_group_id);

--	fnd_file.put_line(fnd_file.log,'5');

--	fnd_file.put_line(fnd_file.log,'l_le_id : '||l_le_id);
--	fnd_file.put_line(fnd_file.log,'l_bg_id : '|| to_char(l_bg_id));

--	fnd_file.put_line(fnd_file.log,'p_start_date : '||p_start_date);
	-- Record 2101
	FOR rg_csr_get_person_id IN csr_get_person_id(l_le_id,l_bg_id)
	LOOP

--		fnd_file.put_line(fnd_file.log,'6');

		/* Get the tax requisition status */
		OPEN csr_get_tax_card_details(rg_csr_get_person_id.assignment_id, 'Tax Card Requisition Status', rg_csr_get_person_id.effective_start_date);
		FETCH csr_get_tax_card_details INTO rg_csr_get_tax_card_details;
		CLOSE csr_get_tax_card_details;

--		fnd_file.put_line(fnd_file.log,'7');

		l_input_value_id:=rg_csr_get_tax_card_details.input_value_id;
		l_req_status:=rg_csr_get_tax_card_details.screen_entry_value;
		if(l_req_status IN ('REQUIRED','RE-COMMISSION')) then
			l_flag:=1;
--			fnd_file.put_line(fnd_file.log,'8');
			gtagdata(l_counter).TagName := 'REC_2101';
			gtagdata(l_counter).TagValue := 'REC_2101';
			l_counter := l_counter + 1;

			l_rec_counter:=l_rec_counter+1;
			/* line num */
			gtagdata(l_counter).TagName := 'RT2101_01';
			gtagdata(l_counter).TagValue := lpad(to_char(l_rec_counter),7,'0');
			l_counter := l_counter + 1;

			/*Rec num */
			gtagdata(l_counter).TagName := 'RT2101_02';
			gtagdata(l_counter).TagValue := '2101';
			l_counter := l_counter + 1;

			/*CPR number */
			l_cpr_number:= rg_csr_get_person_id.national_identifier; -- get the CPR number
			l_cpr_number:=substr(l_cpr_number,1,6)||substr(l_cpr_number,8,4);
			gtagdata(l_counter).TagName := 'RT2101_03';
			gtagdata(l_counter).TagValue := l_cpr_number;
			l_counter := l_counter + 1;

			/*Numeric Filler*/
			gtagdata(l_counter).TagName := 'RT2101_04';
			gtagdata(l_counter).TagValue := lpad('0',8,'0'); -- 8 zeros
			l_counter := l_counter + 1;

			/*Filler*/
			gtagdata(l_counter).TagName := 'RT2101_05';
			gtagdata(l_counter).TagValue := ''; -- 15 spaces
			l_counter := l_counter + 1;

			/*Latest Hire date */
			gtagdata(l_counter).TagName := 'RT2101_06';
			gtagdata(l_counter).TagValue := to_char(rg_csr_get_person_id.effective_start_date,'yyyymmdd');
			l_counter := l_counter + 1;

			/*Termination Date*/
			gtagdata(l_counter).TagName := 'RT2101_07';
			gtagdata(l_counter).TagValue := lpad('0',8,'0'); -- 8 zeros
			l_counter := l_counter + 1;

			/*Numeric Filler*/
			gtagdata(l_counter).TagName := 'RT2101_08';
			gtagdata(l_counter).TagValue := lpad('0',5,'0'); -- 5 zeros
			l_counter := l_counter + 1;

			/*Numeric Filler*/
			gtagdata(l_counter).TagName := 'RT2101_09';
			gtagdata(l_counter).TagValue := lpad('0',5,'0'); -- 5 zeros
			l_counter := l_counter + 1;

			/*Numeric Filler*/
			gtagdata(l_counter).TagName := 'RT2101_10';
			gtagdata(l_counter).TagValue := lpad('0',4,'0'); -- 4 zeros
			l_counter := l_counter + 1;

			/*Numeric Filler */
			gtagdata(l_counter).TagName := 'RT2101_11';
			gtagdata(l_counter).TagValue := lpad('0',10,'0'); -- 10 zeros
			l_counter := l_counter + 1;

			/*Tax Card type*/
			OPEN csr_get_tax_card_details(rg_csr_get_person_id.assignment_id, 'Tax Card Type', rg_csr_get_person_id.effective_start_date);
			FETCH csr_get_tax_card_details INTO rg_csr_get_tax_card_details;
			CLOSE csr_get_tax_card_details;

			l_tax_card_type:=rg_csr_get_tax_card_details.screen_entry_value;
			gtagdata(l_counter).TagName := 'RT2101_12';
			if(l_tax_card_type IN ('H','F')) then
				gtagdata(l_counter).TagValue := '1';
			else
				gtagdata(l_counter).TagValue := '2';
			end if;
			l_counter := l_counter + 1;

			/*Valid from */
			gtagdata(l_counter).TagName := 'RT2101_13';
			gtagdata(l_counter).TagValue := to_char(rg_csr_get_person_id.effective_start_date,'yyyymmdd');
			l_counter := l_counter + 1;

			/* Assignment number */
			gtagdata(l_counter).TagName := 'RT2101_14';
			gtagdata(l_counter).TagValue := rg_csr_get_person_id.assignment_number;
			l_counter := l_counter + 1;

			/*Rekv_taxcard */
			gtagdata(l_counter).TagName := 'RT2101_15';
			if(l_req_status='RE-COMMISSION') then
				gtagdata(l_counter).TagValue := 'R';
			else
				gtagdata(l_counter).TagValue := '';
			end if;
			l_counter := l_counter + 1;

			/* Update the tax requisition status to - REQUEST COMPLETE*/
			py_element_entry_api.update_element_entry
			  (p_validate				=> FALSE
			  ,p_datetrack_update_mode		=> 'CORRECTION'   --p_datetrack_update_mode
			  ,p_effective_date			=> rg_csr_get_person_id.effective_start_date  --p_effective_date
			  ,p_business_group_id			=> p_business_group_id
			  ,p_element_entry_id			=> rg_csr_get_tax_card_details.element_entry_id
			  ,p_object_version_number		=> rg_csr_get_tax_card_details.object_version_number   --p_object_version_number
			  ,p_input_value_id1			=> l_input_value_id
			  ,p_entry_value1			=> 'REQUEST COMPLETE'
			  ,p_effective_start_date		=> l_effective_start_date
			  ,p_effective_end_date			=> l_effective_end_date
			  ,p_update_warning			=> l_update_warning
			  );

			-- Record 8001
			OPEN csr_get_territory(rg_csr_get_person_id.person_id);
			FETCH csr_get_territory INTO rg_csr_get_territory;
			CLOSE csr_get_territory;

			if(rg_csr_get_territory.country NOT IN ('DK')) then
--				fnd_file.put_line(fnd_file.log,'9');
				gtagdata(l_counter).TagName := 'REC_8001';
				gtagdata(l_counter).TagValue := 'REC_8001';
				l_counter := l_counter + 1;

				l_rec_counter:=l_rec_counter+1;
				/* line num */
				gtagdata(l_counter).TagName := 'RT8001_01';
				gtagdata(l_counter).TagValue := lpad(to_char(l_rec_counter),7,'0');
				l_counter := l_counter + 1;

				/*Rec num */
				gtagdata(l_counter).TagName := 'RT8001_02';
				gtagdata(l_counter).TagValue := '8001';
				l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'RT8001_03';
				gtagdata(l_counter).TagValue := rg_csr_get_person_id.dob;
				l_counter := l_counter + 1;

				-- Include a condition for checking M/F
				select decode(mod(substr(l_cpr_number,10),2),0,'2','1') into l_sex from dual;
				gtagdata(l_counter).TagName := 'RT8001_04';
				gtagdata(l_counter).TagValue := l_sex;
				l_counter := l_counter + 1;

				/* Person Country */
				gtagdata(l_counter).TagName := 'RT8001_05';
				gtagdata(l_counter).TagValue := rg_csr_get_territory.country;
				l_counter := l_counter + 1;

				/*Person Name*/
				gtagdata(l_counter).TagName := 'RT8001_06';
				gtagdata(l_counter).TagValue := substr(rg_csr_get_person_id.pname,1,228);
				l_counter := l_counter + 1;

				/*Person Address*/
				gtagdata(l_counter).TagName := 'RT8001_07';
				gtagdata(l_counter).TagValue := substr(rg_csr_get_territory.address_line1,1,228);
				l_counter := l_counter + 1;

				/*Postal Code*/
				gtagdata(l_counter).TagName := 'RT8001_08';
				gtagdata(l_counter).TagValue := rg_csr_get_territory.postal_code;
				l_counter := l_counter + 1;

				l_style:=rg_csr_get_territory.style;
				if(l_style = 'DK') then
					/* Town */
					gtagdata(l_counter).TagName := 'RT8001_09';
					gtagdata(l_counter).TagValue := rg_csr_get_territory.postal_code;
					l_counter := l_counter + 1;

				elsif(l_style = 'DK_GLB') then
					/* Town */
					gtagdata(l_counter).TagName := 'RT8001_09';
					gtagdata(l_counter).TagValue := rg_csr_get_territory.town_or_city;
					l_counter := l_counter + 1;
				end if;

				gtagdata(l_counter).TagName := 'REC_8001';
				gtagdata(l_counter).TagValue := 'REC_8001_END';
				l_counter := l_counter + 1;

			end if; -- territory check.

			gtagdata(l_counter).TagName := 'REC_2101';
			gtagdata(l_counter).TagValue := 'REC_2101_END';
			l_counter := l_counter + 1;
		end if;

	END LOOP;

	gtagdata(l_counter).TagName := 'REC_2001';
	gtagdata(l_counter).TagValue := 'REC_2001_END';
	l_counter := l_counter + 1;


	gtagdata(l_counter).TagName := 'REC_1000';
	gtagdata(l_counter).TagValue := 'REC_1000_END';
	l_counter := l_counter + 1;

	gtagdata(l_counter).TagName := 'REC_9999';
	gtagdata(l_counter).TagValue := 'REC_9999';
	l_counter := l_counter + 1;

	-- Record 9999
/*		OPEN  csr_9999(l_payroll_action_id);
	FETCH csr_9999 INTO rg_csr_9999;
	CLOSE csr_9999;
*/
	l_rec_counter:=l_rec_counter+1;
	/* line num */
	gtagdata(l_counter).TagName := 'RT9999_01';
	gtagdata(l_counter).TagValue := lpad(to_char(l_rec_counter),7,'0');
	l_counter := l_counter + 1;

	/*Rec num */
	gtagdata(l_counter).TagName := 'RT9999_02';
	gtagdata(l_counter).TagValue := '9999';
	l_counter := l_counter + 1;

	-- Number of records
	gtagdata(l_counter).TagName := 'RT9999_03';
	gtagdata(l_counter).TagValue := lpad(to_char(l_rec_counter),7,'0');
	l_counter := l_counter + 1;

	gtagdata(l_counter).TagName := 'REC_9999';
	gtagdata(l_counter).TagValue := 'REC_9999_END';
	l_counter := l_counter + 1;

	if(l_flag=0) then -- output the message when there are no 2101 records reported
		fnd_file.put_line(fnd_file.LOG,HR_DK_UTILITY.GET_MESSAGE('PAY','PAY_377104_DK_TCR'));
	end if;


	hr_utility.set_location('After populating pl/sql table',30);


	WritetoCLOB (p_xml );

	exception
		when NO_E_INCOME_DATA_SUPPLIER then
			null;


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

		current_index pls_integer;
		l_IANA_charset VARCHAR2 (50);

	BEGIN
		l_IANA_charset :=PAY_DK_GENERAL.get_IANA_charset ;
		hr_utility.set_location('Entering WritetoCLOB ',70);
		l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT><EINR>' ;
		l_str2 := '<';
		l_str3 := '>';
		l_str4 := '</';
		l_str5 := '>';
		l_str6 := '</EINR></ROOT>';
		l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';

		--fnd_file.put_line(fnd_file.log,'wc1');

		dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
		dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

		current_index := 0;

		--fnd_file.put_line(fnd_file.log,'wc2');

		IF gtagdata.count > 0 THEN

			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );

			FOR table_counter IN gtagdata.FIRST .. gtagdata.LAST LOOP

				l_str8 := gtagdata(table_counter).TagName;
				l_str9 := gtagdata(table_counter).TagValue ;

					IF l_str9 IN ('REC_1000','REC_1000_END','REC_2001','REC_2001_END','REC_2101','REC_2101_END',
					'REC_8001','REC_8001_END','REC_9999','REC_9999_END') THEN

						--fnd_file.put_line(fnd_file.log,'wc4');
						IF l_str9 IN ('REC_1000','REC_2001','REC_2101','REC_8001','REC_9999') THEN
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
					   l_str9 := hr_dk_utility.REPLACE_SPECIAL_CHARS(l_str9);

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


		--fnd_file.put_line(fnd_file.log,'wc5');
		p_xfdf_clob := l_xfdf_string;

		hr_utility.set_location('Leaving WritetoCLOB ',40);

	EXCEPTION
		WHEN OTHERS then
			HR_UTILITY.TRACE('sqlerrm ' || SQLERRM);
			HR_UTILITY.RAISE_ERROR;
	END WritetoCLOB;
	-------------------------------------------------------------------------------------------------------------------------

END PAY_DK_TCR;

/
