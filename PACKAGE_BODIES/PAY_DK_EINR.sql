--------------------------------------------------------
--  DDL for Package Body PAY_DK_EINR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_DK_EINR" AS
/* $Header: pydkeinr.pkb 120.1.12010000.10 2010/04/16 10:01:32 knadhan ship $ */

	PROCEDURE GET_DATA (
	p_business_group_id               IN NUMBER,
	p_payroll_action_id               IN  VARCHAR2 ,
	p_template_name                   IN VARCHAR2,
	p_xml                             OUT NOCOPY CLOB
	)
	IS

	/*  Start of declaration*/
	-- Variables needed for the report
	l_counter      number := 0;
	l_ctr          number := 0;
	l_line_num     number := 0;
	l_sender_id   VARCHAR2(8);
	l_payroll_action_id   PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE;
	l_flag      VARCHAR2(1):='N';
	l_flag_end  VARCHAR2(1):='N';
	/* End of declaration*/

	/* Cursors */
	/* Cursor to fetch data  related to Record 1000*/
	CURSOR csr_1000 (p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai
	WHERE pai.action_context_id= p_payroll_action_id
	AND pai.action_context_type= 'PA'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND pai.action_information3  ='1000';
--	ORDER BY pai.action_information2;

	/* Cursor to fetch data  related to Record 2001*/
	CURSOR csr_2001 (p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai
	WHERE pai.action_context_id= p_payroll_action_id
	AND pai.action_context_type= 'PA'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND pai.action_information3  ='2001';
--	AND action_information29 ='2'
--	AND pai.action_context_id = p_action_context_id
--	ORDER BY pai.action_information2;

	rg_csr_2001 csr_2001%rowtype;

	/* Cursor to fetch data  related to Record 2101*/
	CURSOR csr_2101(p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai , pay_assignment_actions paa
	WHERE paa.payroll_action_id = p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND pai.action_information3  ='2101'
	order by pai.action_information30;

	rg_csr_2101 csr_2101%rowtype;

	/* Cursor to fetch data  related to Record 5000*/
	CURSOR csr_5000(p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai
	WHERE pai.action_context_id = p_payroll_action_id
	AND pai.action_context_type= 'PA'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND pai.action_information3  =  '5000'
        order by pai.action_information30; /* 9587046 */
	rg_csr_5000 csr_5000%rowtype;

       CURSOR csr_5000R(p_payroll_action_id NUMBER,p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai
	WHERE pai.action_context_id = p_payroll_action_id
	AND pai.action_context_type= 'PA'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND pai.action_information3  =  '5000R'
	AND pai.action_information25 = p_payroll_id
	AND pai.action_information9=p_employement_type
	AND pai.action_information8=p_green_land_code /* 8847591 */
	AND pai.action_information24=p_time_period_id;

	/* Cursor to fetch data  related to Record 6000*/
	CURSOR csr_6000(p_payroll_action_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6000'
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code /* 8847591 */
	order by pai.action_information30;

	/* Cursor to fetch data  related to Record 8001 */
	CURSOR csr_8001(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '8001'
	AND  pai.action_information5 = p_assignment_id
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code /* 8847591 */
	ORDER BY pai.action_information30;

	/*  9587046R */
	CURSOR csr_8001R(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '8001R'
	AND  pai.action_information5 = p_assignment_id
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code /* 8847591 */
	ORDER BY pai.action_information30;

	/* Cursor to fetch data  related to Record 6001 */
	CURSOR csr_6001(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6001'
	AND  pai.action_information5 = p_assignment_id
	AND nvl(pai.action_information29, 'N') <> 'Y'
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code /* 8847591 */
	ORDER BY pai.action_information30;

  	/* Cursor to fetch data  related to Correction Record 6001 */
	CURSOR csr_6001_corr(p_payroll_action_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  distinct pai.action_information5,pai.action_information3,action_context_id /* 9587046R */
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6001'
	AND nvl(pai.action_information29, 'N') = 'Y'
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code  /* 8847591 */
	ORDER BY pai.action_information3,action_context_id DESC; /* 9587046R */

	/* Cursor to fetch data  related to Correction Record 6001 */
	CURSOR csr_6001_corr_asst(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6001'
	AND  pai.action_information5 = p_assignment_id
	AND nvl(pai.action_information29, 'N') = 'Y'
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code /* 8847591 */
	ORDER BY pai.action_information30;

	/* Cursor to fetch data  related to Correction Record 6000*/
	CURSOR csr_6000_corr(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6000R'
	AND pai.action_information5 = p_assignment_id
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code /* 8847591 */
	order by pai.action_information30;

	/* Cursor to fetch data  related to Record 6002 */
	CURSOR csr_6002(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6002'
	AND  pai.action_information5 = p_assignment_id
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code; /* 8847591 */

	/* Cursor to fetch data  related to Record 6003 */
	CURSOR csr_6003(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6003'
	AND  pai.action_information5 = p_assignment_id
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code; /* 8847591 */

	/* Cursor to fetch data  related to Record 6004 */
	CURSOR csr_6004(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6004'
	AND  pai.action_information5 = p_assignment_id
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code; /* 8847591 */

	/* Cursor to fetch data  related to Record 6005 */
	CURSOR csr_6005(p_payroll_action_id NUMBER, p_assignment_id NUMBER, p_payroll_id NUMBER,p_employement_type NUMBER,p_time_period_id NUMBER,p_green_land_code NUMBER) IS /* 9489806 */
	SELECT  pai.*
	FROM pay_action_information pai, pay_assignment_actions paa
	WHERE paa.payroll_action_id= p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '6005'
	AND  pai.action_information5 = p_assignment_id
	AND  pai.action_information25 = p_payroll_id
	AND pai.action_information26=p_employement_type
	AND pai.action_information24=p_time_period_id
	AND pai.action_information27=p_green_land_code; /* 8847591 */

	/* Cursor to fetch data  related to Record 9999 */
	CURSOR csr_9999(p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai
	WHERE pai.action_context_id = p_payroll_action_id
	AND pai.action_context_type= 'PA'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYDKEINA'
	AND  pai.action_information3 = '9999';

	rg_csr_9999 csr_9999%rowtype;

	/* End of Cursors */
	BEGIN

		--fnd_file.put_line(fnd_file.log,'1');
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
			--fnd_file.put_line(fnd_file.log,'2');
		ELSE

			l_payroll_action_id  :=p_payroll_action_id;
			--fnd_file.put_line(fnd_file.log,'3');
		END IF;

	hr_utility.set_location('Entered Procedure GETDATA',10);

	/* Pick up the data  related to Record 1000*/
	FOR rg_csr_1000 IN csr_1000 (l_payroll_action_id)
	LOOP
		--fnd_file.put_line(fnd_file.log,'4');

		gtagdata(l_counter).TagName := 'REC_1000';
		gtagdata(l_counter).TagValue := 'REC_1000';
		l_counter := l_counter + 1;

		/* line num */
		gtagdata(l_counter).TagName := 'RT1000_01';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information30;
		l_line_num := to_number(rg_csr_1000.action_information30);
		l_counter := l_counter + 1;

		/*Rec num */
		gtagdata(l_counter).TagName := 'RT1000_02';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information3;
		l_counter := l_counter + 1;

		/*Date sent*/
		gtagdata(l_counter).TagName := 'RT1000_03';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information4;
		l_counter := l_counter + 1;

		/*Time sent*/
		gtagdata(l_counter).TagName := 'RT1000_04';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information5;
		l_counter := l_counter + 1;

		/*SE number*/
		gtagdata(l_counter).TagName := 'RT1000_05';
		gtagdata(l_counter).TagValue := lpad(rg_csr_1000.action_information6,8,'0');
		l_counter := l_counter + 1;

		/*CVR number*/
		gtagdata(l_counter).TagName := 'RT1000_06';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information7;
		l_counter := l_counter + 1;

		/*Sender type*/
		gtagdata(l_counter).TagName := 'RT1000_07';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information8;
		l_counter := l_counter + 1;

		/*Filler*/
		gtagdata(l_counter).TagName := 'RT1000_08';
		gtagdata(l_counter).TagValue := lpad('0',5,'0');
		l_counter := l_counter + 1;

		/*Report Method name*/
		gtagdata(l_counter).TagName := 'RT1000_09';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information9;
		l_counter := l_counter + 1;

		/*IT System*/
		gtagdata(l_counter).TagName := 'RT1000_10';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information10;
		l_counter := l_counter + 1;

		/* IT System Version */
		gtagdata(l_counter).TagName := 'RT1000_11';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information11;
		l_counter := l_counter + 1;

		/*Main sender ID*/
		gtagdata(l_counter).TagName := 'RT1000_12';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information12;
		l_sender_id := rg_csr_1000.action_information12;
		l_counter := l_counter + 1;

		/*E-Income version*/
		gtagdata(l_counter).TagName := 'RT1000_13';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information13;
		l_counter := l_counter + 1;

		/*Test Marking*/
		gtagdata(l_counter).TagName := 'RT1000_14';
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information14;
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
		gtagdata(l_counter).TagValue := rg_csr_1000.action_information15;
		l_counter := l_counter + 1;


		-- Record 2001
		OPEN  csr_2001(l_payroll_action_id);
		FETCH csr_2001 INTO rg_csr_2001;
		CLOSE csr_2001;

		--fnd_file.put_line(fnd_file.log,'5');

		gtagdata(l_counter).TagName := 'REC_2001';
		gtagdata(l_counter).TagValue := 'REC_2001';
		l_counter := l_counter + 1;

		/* line num */
		gtagdata(l_counter).TagName := 'RT2001_01';
		gtagdata(l_counter).TagValue := rg_csr_2001.action_information30;
		l_line_num := to_number(rg_csr_2001.action_information30);
		l_counter := l_counter + 1;

		/*Rec num */
		gtagdata(l_counter).TagName := 'RT2001_02';
		gtagdata(l_counter).TagValue := rg_csr_2001.action_information3;
		l_counter := l_counter + 1;

		/*Filler*/
		gtagdata(l_counter).TagName := 'RT2001_03';
		gtagdata(l_counter).TagValue := ''; --16 spaces
		l_counter := l_counter + 1;

		/*Company */
		gtagdata(l_counter).TagName := 'RT2001_04';
		gtagdata(l_counter).TagValue := rg_csr_2001.action_information4;
		l_counter := l_counter + 1;

		/*Termination of company*/
		gtagdata(l_counter).TagName := 'RT2001_05';
		gtagdata(l_counter).TagValue := rg_csr_2001.action_information5;
		l_counter := l_counter + 1;

		/*Currency */
		gtagdata(l_counter).TagName := 'RT2001_06';
		gtagdata(l_counter).TagValue := rg_csr_2001.action_information6;
		l_counter := l_counter + 1;

		--fnd_file.put_line(fnd_file.log,'Company Terminating value : '||rg_csr_2001.action_information5);
		if(rg_csr_2001.action_information5 IS NULL) then
			-- Record 2101
			FOR rg_csr_2101 IN csr_2101(l_payroll_action_id)
			LOOP

				--fnd_file.put_line(fnd_file.log,'6');

				gtagdata(l_counter).TagName := 'REC_2101';
				gtagdata(l_counter).TagValue := 'REC_2101';
				l_counter := l_counter + 1;

				/* line num */
				gtagdata(l_counter).TagName := 'RT2101_01';
				gtagdata(l_counter).TagValue := rg_csr_2101.action_information30;
        		l_line_num := to_number(rg_csr_2101.action_information30);
				l_counter := l_counter + 1;

				/*Rec num */
				gtagdata(l_counter).TagName := 'RT2101_02';
				gtagdata(l_counter).TagValue := rg_csr_2101.action_information3;
				l_counter := l_counter + 1;

				/*CPR number */
				gtagdata(l_counter).TagName := 'RT2101_03';
				gtagdata(l_counter).TagValue := rg_csr_2101.action_information6;
				l_counter := l_counter + 1;

				/*Numeric Filler*/
				gtagdata(l_counter).TagName := 'RT2101_04';
				gtagdata(l_counter).TagValue := lpad('0',8,'0'); -- 8 zeros
				l_counter := l_counter + 1;

				/*Filler*/
				gtagdata(l_counter).TagName := 'RT2101_05';
				gtagdata(l_counter).TagValue := ''; -- 15 spaces
				l_counter := l_counter + 1;

				/*Hire date */
				gtagdata(l_counter).TagName := 'RT2101_06';
				gtagdata(l_counter).TagValue := rg_csr_2101.action_information7;
				l_counter := l_counter + 1;

				/*Termination Date*/
				gtagdata(l_counter).TagName := 'RT2101_07';
				if(rg_csr_2101.action_information8 IS NULL) then
					gtagdata(l_counter).TagValue := lpad('0',8,'0'); -- 8 zeros
				else
					gtagdata(l_counter).TagValue := rg_csr_2101.action_information8;
				end if;
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
				gtagdata(l_counter).TagName := 'RT2101_12';
				gtagdata(l_counter).TagValue := rg_csr_2101.action_information9;
				l_counter := l_counter + 1;

				/*Valid from */
				gtagdata(l_counter).TagName := 'RT2101_13';
				gtagdata(l_counter).TagValue := rg_csr_2101.action_information10;
				l_counter := l_counter + 1;

				/*emp num - filler*/
				gtagdata(l_counter).TagName := 'RT2101_14';
				gtagdata(l_counter).TagValue := ''; -- 50 spaces
				l_counter := l_counter + 1;

				/*Rekv_taxcard */
				gtagdata(l_counter).TagName := 'RT2101_15';
				gtagdata(l_counter).TagValue := '';  -- 1 space
				l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'REC_2101';
				gtagdata(l_counter).TagValue := 'REC_2101_END';
				l_counter := l_counter + 1;


			END LOOP;

			-- Record 5000
			/*OPEN  csr_5000(l_payroll_action_id);
			FETCH csr_5000 INTO rg_csr_5000;
			CLOSE csr_5000;
			*/
			FOR rg_csr_5000 IN csr_5000(l_payroll_action_id)
			LOOP

			/*Raji	gtagdata(l_counter).TagName := 'REC_5000';
				gtagdata(l_counter).TagValue := 'REC_5000_END';
				l_counter := l_counter + 1; */


			-- record 6000
			l_flag:='N';
                        fnd_file.put_line(fnd_file.log,'csr_5000.person:' || l_flag);
			fnd_file.put_line(fnd_file.log,'l_flag:' || l_flag);
			fnd_file.put_line(fnd_file.log,'l_flag_end:' || l_flag_end);
			FOR rg_csr_6000 IN csr_6000(l_payroll_action_id,rg_csr_5000.action_information25,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 9489806 */
			LOOP
			IF(l_flag='N') THEN

			/* 9489806 Brought from outside for loop to inside for loop */
			gtagdata(l_counter).TagName := 'REC_5000';
				gtagdata(l_counter).TagValue := 'REC_5000';
				l_counter := l_counter + 1;

			--fnd_file.put_line(fnd_file.log,'7');

			/* line num */
			gtagdata(l_counter).TagName := 'RT5000_01';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information30;
			l_line_num := to_number(rg_csr_5000.action_information30);
			l_counter := l_counter + 1;

			/*Rec num */
			gtagdata(l_counter).TagName := 'RT5000_02';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information3;
			l_counter := l_counter + 1;

			gtagdata(l_counter).TagName := 'RT5000_03';
			gtagdata(l_counter).TagValue := ''; -- 1 space
			l_counter := l_counter + 1;

			gtagdata(l_counter).TagName := 'RT5000_04';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information10; /* bug fix 7579265 */
			l_counter := l_counter + 1;

			gtagdata(l_counter).TagName := 'RT5000_05';
			gtagdata(l_counter).TagValue := ''; -- 16 spaces
			l_counter := l_counter + 1;

			/*Pay period start date*/
			gtagdata(l_counter).TagName := 'RT5000_06';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information4;
			l_counter := l_counter + 1;

			/*period end date*/
			gtagdata(l_counter).TagName := 'RT5000_07';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information5;
			l_counter := l_counter + 1;

			/*Disposal date*/
			gtagdata(l_counter).TagName := 'RT5000_08';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information6;
			l_counter := l_counter + 1;

			gtagdata(l_counter).TagName := 'RT5000_09';
			gtagdata(l_counter).TagValue := ''; -- 1 space
			l_counter := l_counter + 1;

			/*Payment*/
			gtagdata(l_counter).TagName := 'RT5000_10';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information7;
			l_counter := l_counter + 1;

			/*Greenland code*/
			gtagdata(l_counter).TagName := 'RT5000_11';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information8;
			l_counter := l_counter + 1;

			/*Employment code*/
			gtagdata(l_counter).TagName := 'RT5000_12';
			gtagdata(l_counter).TagValue := rg_csr_5000.action_information9;
			l_counter := l_counter + 1;

			l_flag:='Y';
			END IF;

				--fnd_file.put_line(fnd_file.log,'8');

				gtagdata(l_counter).TagName := 'REC_6000';
				gtagdata(l_counter).TagValue := 'REC_6000';
				l_counter := l_counter + 1;

				/* line num */
				gtagdata(l_counter).TagName := 'RT6000_01';
				gtagdata(l_counter).TagValue := rg_csr_6000.action_information30;
				l_line_num := to_number(rg_csr_6000.action_information30);
				l_counter := l_counter + 1;

				/*Rec num */
				gtagdata(l_counter).TagName := 'RT6000_02';
				gtagdata(l_counter).TagValue := rg_csr_6000.action_information3;
				l_counter := l_counter + 1;

				-- CVR num
				gtagdata(l_counter).TagName := 'RT6000_03';
				gtagdata(l_counter).TagValue := rg_csr_6000.action_information6;
				l_counter := l_counter + 1;

				-- CPR
				gtagdata(l_counter).TagName := 'RT6000_04';
				gtagdata(l_counter).TagValue := rg_csr_6000.action_information7;
				l_counter := l_counter + 1;

				-- Numeric Filler
				gtagdata(l_counter).TagName := 'RT6000_05';
				gtagdata(l_counter).TagValue := lpad('0',8,'0'); -- 8 zeros
				l_counter := l_counter + 1;

				/*Assignment num*/
				gtagdata(l_counter).TagName := 'RT6000_06';
				gtagdata(l_counter).TagValue := rg_csr_6000.action_information8;
				l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'RT6000_07';
				gtagdata(l_counter).TagValue := ''; -- 1 space
				l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'RT6000_08';
				gtagdata(l_counter).TagValue := lpad('0',3,'0'); -- 3 zeros
				l_counter := l_counter + 1;

				gtagdata(l_counter).TagName := 'RT6000_09';
				gtagdata(l_counter).TagValue := ''; -- 25 spaces
				l_counter := l_counter + 1;

				/*Code 68*/
				gtagdata(l_counter).TagName := 'RT6000_10';
				gtagdata(l_counter).TagValue := rg_csr_6000.action_information9;
				l_counter := l_counter + 1;

				/*PU code*/
				gtagdata(l_counter).TagName := 'RT6000_11';
				gtagdata(l_counter).TagValue := rg_csr_6000.action_information10;
				l_counter := l_counter + 1;

				/* bug fix 7613211 */
				-- record 8001
				FOR rg_csr_8001 IN csr_8001(l_payroll_action_id, rg_csr_6000.action_information5,rg_csr_5000.action_information25
				                            ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 9489806  8847591 */
				LOOP
					gtagdata(l_counter).TagName := 'REC_8001';
					gtagdata(l_counter).TagValue := 'REC_8001';
					l_counter := l_counter + 1;

					/* line num */
					gtagdata(l_counter).TagName := 'RT8001_01';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information30;
 			 	    l_line_num := to_number(rg_csr_8001.action_information30);
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT8001_02';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information3;
					l_counter := l_counter + 1;

					/*Birthday */
					gtagdata(l_counter).TagName := 'RT8001_03';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information6;
					l_counter := l_counter + 1;

					/*Person gender*/
					gtagdata(l_counter).TagName := 'RT8001_04';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information7;
					l_counter := l_counter + 1;

					/*Country*/
					gtagdata(l_counter).TagName := 'RT8001_05';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information8;
					l_counter := l_counter + 1;

					/*Person Name */
					gtagdata(l_counter).TagName := 'RT8001_06';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information9;
					l_counter := l_counter + 1;

					/*Address*/
					gtagdata(l_counter).TagName := 'RT8001_07';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information10;
					l_counter := l_counter + 1;

					/*Postal code*/
					gtagdata(l_counter).TagName := 'RT8001_08';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information11;
					l_counter := l_counter + 1;

					/*Town*/
					gtagdata(l_counter).TagName := 'RT8001_09';
					gtagdata(l_counter).TagValue := rg_csr_8001.action_information12;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'REC_8001';
					gtagdata(l_counter).TagValue := 'REC_8001_END';
					l_counter := l_counter + 1;
				END LOOP;

				-- record 6001
				FOR rg_csr_6001 IN csr_6001(l_payroll_action_id, rg_csr_6000.action_information5,rg_csr_5000.action_information25
				                            ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 9489806  8847591 */
				LOOP

					--fnd_file.put_line(fnd_file.log,'9');

					gtagdata(l_counter).TagName := 'REC_6001';
					gtagdata(l_counter).TagValue := 'REC_6001';
					l_counter := l_counter + 1;

					/* line num */
					gtagdata(l_counter).TagName := 'RT6001_01';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information30;
					l_line_num := to_number(rg_csr_6001.action_information30);
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT6001_02';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information3;
					l_counter := l_counter + 1;

					-- Field num
					gtagdata(l_counter).TagName := 'RT6001_03';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information6;
					l_counter := l_counter + 1;

					-- Amount
					gtagdata(l_counter).TagName := 'RT6001_04';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information7;
					l_counter := l_counter + 1;

					-- Sign
					gtagdata(l_counter).TagName := 'RT6001_05';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information8;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'REC_6001';
					gtagdata(l_counter).TagValue := 'REC_6001_END';
					l_counter := l_counter + 1;
				END LOOP;

				-- Record 6002
				FOR rg_csr_6002 IN csr_6002(l_payroll_action_id, rg_csr_6000.action_information5,rg_csr_5000.action_information25
				                            ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 9489806  8847591 */
				LOOP
					--fnd_file.put_line(fnd_file.log,'10');

					gtagdata(l_counter).TagName := 'REC_6002';
					gtagdata(l_counter).TagValue := 'REC_6002';
					l_counter := l_counter + 1;

					/* line num */
					gtagdata(l_counter).TagName := 'RT6002_01';
					gtagdata(l_counter).TagValue := rg_csr_6002.action_information30;
					l_line_num := to_number(rg_csr_6002.action_information30);
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT6002_02';
					gtagdata(l_counter).TagValue := rg_csr_6002.action_information3;
					l_counter := l_counter + 1;

					-- Field num
					gtagdata(l_counter).TagName := 'RT6002_03';
					gtagdata(l_counter).TagValue := rg_csr_6002.action_information6;
					l_counter := l_counter + 1;

					-- Code Field
					gtagdata(l_counter).TagName := 'RT6002_04';
					gtagdata(l_counter).TagValue := rg_csr_6002.action_information7;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'REC_6002';
					gtagdata(l_counter).TagValue := 'REC_6002_END';
					l_counter := l_counter + 1;

				END LOOP;

				FOR rg_csr_6003 IN csr_6003(l_payroll_action_id, rg_csr_6000.action_information5,rg_csr_5000.action_information25
				                            ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 9489806  8847591 */
				LOOP
					--fnd_file.put_line(fnd_file.log,'10');

					gtagdata(l_counter).TagName := 'REC_6003';
					gtagdata(l_counter).TagValue := 'REC_6003';
					l_counter := l_counter + 1;

					/* line num */
					gtagdata(l_counter).TagName := 'RT6003_01';
					gtagdata(l_counter).TagValue := rg_csr_6003.action_information30;
					l_line_num := to_number(rg_csr_6003.action_information30);
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT6003_02';
					gtagdata(l_counter).TagValue := rg_csr_6003.action_information3;
					l_counter := l_counter + 1;

					-- Field num
					gtagdata(l_counter).TagName := 'RT6003_03';
					gtagdata(l_counter).TagValue := rg_csr_6003.action_information6;
					l_counter := l_counter + 1;

					-- Code Field
					gtagdata(l_counter).TagName := 'RT6003_04';
					gtagdata(l_counter).TagValue := rg_csr_6003.action_information7;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'REC_6003';
					gtagdata(l_counter).TagValue := 'REC_6003_END';
					l_counter := l_counter + 1;

				END LOOP;

				-- Record 6004
				FOR rg_csr_6004 IN csr_6004(l_payroll_action_id, rg_csr_6000.action_information5,rg_csr_5000.action_information25
				                            ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 9489806 8847591 */
				LOOP
					--fnd_file.put_line(fnd_file.log,'11');

					gtagdata(l_counter).TagName := 'REC_6004';
					gtagdata(l_counter).TagValue := 'REC_6004';
					l_counter := l_counter + 1;


					/* line num */
					gtagdata(l_counter).TagName := 'RT6004_01';
					gtagdata(l_counter).TagValue := rg_csr_6004.action_information30;
					l_line_num := to_number(rg_csr_6004.action_information30);
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT6004_02';
					gtagdata(l_counter).TagValue := rg_csr_6004.action_information3;
					l_counter := l_counter + 1;

					-- Field num
					gtagdata(l_counter).TagName := 'RT6004_03';
					gtagdata(l_counter).TagValue := rg_csr_6004.action_information6;
					l_counter := l_counter + 1;

					-- Code Field
					gtagdata(l_counter).TagName := 'RT6004_04';
					gtagdata(l_counter).TagValue := rg_csr_6004.action_information7;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'REC_6004';
					gtagdata(l_counter).TagValue := 'REC_6004_END';
					l_counter := l_counter + 1;

				END LOOP;

				-- Record 6005
				FOR rg_csr_6005 IN csr_6005(l_payroll_action_id, rg_csr_6000.action_information5,rg_csr_5000.action_information25
				                            ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 9489806 8847591 */
				LOOP

					gtagdata(l_counter).TagName := 'REC_6005';
					gtagdata(l_counter).TagValue := 'REC_6005';
					l_counter := l_counter + 1;

					/* line num */
					gtagdata(l_counter).TagName := 'RT6005_01';
					gtagdata(l_counter).TagValue := rg_csr_6005.action_information30;
					l_line_num := to_number(rg_csr_6005.action_information30);
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT6005_02';
					gtagdata(l_counter).TagValue := rg_csr_6005.action_information3;
					l_counter := l_counter + 1;

					-- Field num
					gtagdata(l_counter).TagName := 'RT6005_03';
					gtagdata(l_counter).TagValue := rg_csr_6005.action_information6;
					l_counter := l_counter + 1;

					-- HOURS/Days worked
					gtagdata(l_counter).TagName := 'RT6005_04';
					gtagdata(l_counter).TagValue := lpad(rg_csr_6005.action_information7,8,'0');
					l_counter := l_counter + 1;

					-- Sign
					gtagdata(l_counter).TagName := 'RT6005_05';
					gtagdata(l_counter).TagValue := rg_csr_6005.action_information8;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'REC_6005';
					gtagdata(l_counter).TagValue := 'REC_6005_END';
					l_counter := l_counter + 1;

				END LOOP;

				gtagdata(l_counter).TagName := 'REC_6000';
				gtagdata(l_counter).TagValue := 'REC_6000_END';
				l_counter := l_counter + 1;



			END LOOP; /* end record 6000 */
			--Raji
				/* 9489806 */
				IF(l_flag='Y') THEN
				   gtagdata(l_counter).TagName := 'REC_5000';
				   gtagdata(l_counter).TagValue := 'REC_5000_END';
				   l_counter := l_counter + 1;
                                   l_flag:='N';
				END IF;
			l_ctr := 1;
            FOR rg_csr_6001_corr IN csr_6001_corr(l_payroll_action_id,rg_csr_5000.action_information25
	                                          ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 8847591 */
            LOOP
                IF l_ctr = 1 THEN
                    -- make 5000 record
                                OPEN  csr_5000R(l_payroll_action_id,rg_csr_5000.action_information25
				                ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8); /* 8847591 */
		          	FETCH csr_5000R INTO rg_csr_5000;
			        CLOSE csr_5000R;
			       	gtagdata(l_counter).TagName := 'REC_5000';
			     	gtagdata(l_counter).TagValue := 'REC_5000';
				    l_counter := l_counter + 1;

			         --fnd_file.put_line(fnd_file.log,'7');

			         /* line num */
			         l_line_num := l_line_num + 1;
			         gtagdata(l_counter).TagName := 'RT5000_01';
			         gtagdata(l_counter).TagValue :=rg_csr_5000.action_information30;
				 --lpad(to_char(l_line_num),7,'0');
			         l_counter := l_counter + 1;

			         /*Rec num */
			         gtagdata(l_counter).TagName := 'RT5000_02';
			         gtagdata(l_counter).TagValue := rg_csr_5000.action_information3;
			         l_counter := l_counter + 1;

			         gtagdata(l_counter).TagName := 'RT5000_03';
			         gtagdata(l_counter).TagValue := 'R'; -- Correction Record
			         l_counter := l_counter + 1;

			         gtagdata(l_counter).TagName := 'RT5000_04';
			         gtagdata(l_counter).TagValue := rg_csr_5000.action_information10;
				 /* rpad(substr(rg_csr_5000.action_information10,1, 8) ||
					                                 l_sender_id, 16, ' ');  bug fix 7579265 */
			         l_counter := l_counter + 1;

			         gtagdata(l_counter).TagName := 'RT5000_05';
			         gtagdata(l_counter).TagValue := ''; -- 16 spaces
			         l_counter := l_counter + 1;

			         /*Pay period start date*/
			         gtagdata(l_counter).TagName := 'RT5000_06';
			         gtagdata(l_counter).TagValue := rg_csr_5000.action_information4;
			         l_counter := l_counter + 1;

			         /*period end date*/
			         gtagdata(l_counter).TagName := 'RT5000_07';
			         gtagdata(l_counter).TagValue := rg_csr_5000.action_information5;
			         l_counter := l_counter + 1;

			         /*Disposal date*/
			         gtagdata(l_counter).TagName := 'RT5000_08';
			         gtagdata(l_counter).TagValue := rg_csr_5000.action_information6;
			         l_counter := l_counter + 1;

			         gtagdata(l_counter).TagName := 'RT5000_09';
			         gtagdata(l_counter).TagValue := ''; -- 1 space
			         l_counter := l_counter + 1;

			         /*Payment*/
		          	gtagdata(l_counter).TagName := 'RT5000_10';
		          	gtagdata(l_counter).TagValue := rg_csr_5000.action_information7;
		          	l_counter := l_counter + 1;

		          	/*Greenland code*/
		          	gtagdata(l_counter).TagName := 'RT5000_11';
		          	gtagdata(l_counter).TagValue := rg_csr_5000.action_information8;
		          	l_counter := l_counter + 1;

		          	/*Employment code*/
		          	gtagdata(l_counter).TagName := 'RT5000_12';
		          	gtagdata(l_counter).TagValue := rg_csr_5000.action_information9;
		          	l_counter := l_counter + 1;
                END IF;
                -- make 6000 record
                FOR rg_csr_6000 IN csr_6000_corr(l_payroll_action_id, rg_csr_6001_corr.action_information5,rg_csr_5000.action_information25
		                                 ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 8847591 */
		   	    LOOP

					--fnd_file.put_line(fnd_file.log,'8');

					gtagdata(l_counter).TagName := 'REC_6000';
					gtagdata(l_counter).TagValue := 'REC_6000';
					l_counter := l_counter + 1;

					/* line num */
					l_line_num := l_line_num + 1;
					gtagdata(l_counter).TagName := 'RT6000_01';
					gtagdata(l_counter).TagValue :=  rg_csr_6000.action_information30;
					--lpad(to_char(l_line_num),7,'0');
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT6000_02';
					gtagdata(l_counter).TagValue := rg_csr_6000.action_information3;
					l_counter := l_counter + 1;

					-- CVR num
					gtagdata(l_counter).TagName := 'RT6000_03';
					gtagdata(l_counter).TagValue := rg_csr_6000.action_information6;
					l_counter := l_counter + 1;

					-- CPR
					gtagdata(l_counter).TagName := 'RT6000_04';
					gtagdata(l_counter).TagValue := rg_csr_6000.action_information7;
					l_counter := l_counter + 1;

					-- Numeric Filler
					gtagdata(l_counter).TagName := 'RT6000_05';
					gtagdata(l_counter).TagValue := lpad('0',8,'0'); -- 8 zeros
					l_counter := l_counter + 1;

					/*Assignment num*/
					gtagdata(l_counter).TagName := 'RT6000_06';
					gtagdata(l_counter).TagValue := rg_csr_6000.action_information8;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'RT6000_07';
					gtagdata(l_counter).TagValue := ''; -- 1 space
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'RT6000_08';
					gtagdata(l_counter).TagValue := lpad('0',3,'0'); -- 3 zeros
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'RT6000_09';
					gtagdata(l_counter).TagValue := ''; -- 25 spaces
					l_counter := l_counter + 1;

					/*Code 68*/
					gtagdata(l_counter).TagName := 'RT6000_10';
					gtagdata(l_counter).TagValue := rg_csr_6000.action_information9;
					l_counter := l_counter + 1;

					/*PU code*/
					gtagdata(l_counter).TagName := 'RT6000_11';
					gtagdata(l_counter).TagValue := rg_csr_6000.action_information10;
					l_counter := l_counter + 1;
					-- record 8001
					/* 9587046R */
                    FOR rg_csr_8001 IN csr_8001R(l_payroll_action_id, rg_csr_6000.action_information5,rg_csr_5000.action_information25
		                                ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 8847591 */
				    LOOP
					  gtagdata(l_counter).TagName := 'REC_8001';
					  gtagdata(l_counter).TagValue := 'REC_8001';
					  l_counter := l_counter + 1;

					  /* line num */
					  l_line_num := l_line_num + 1;
					  gtagdata(l_counter).TagName := 'RT8001_01';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information30;
					  --lpad(to_char(l_line_num),7,'0');
				  	  l_counter := l_counter + 1;

					  /*Rec num */
					  gtagdata(l_counter).TagName := 'RT8001_02';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information3;
					  l_counter := l_counter + 1;

					  /*Birthday */
					  gtagdata(l_counter).TagName := 'RT8001_03';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information6;
					  l_counter := l_counter + 1;

					  /*Person gender*/
					  gtagdata(l_counter).TagName := 'RT8001_04';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information7;
					  l_counter := l_counter + 1;

					  /*Country*/
					  gtagdata(l_counter).TagName := 'RT8001_05';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information8;
					  l_counter := l_counter + 1;

					  /*Person Name */
					  gtagdata(l_counter).TagName := 'RT8001_06';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information9;
					  l_counter := l_counter + 1;

					  /*Address*/
				  	  gtagdata(l_counter).TagName := 'RT8001_07';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information10;
					  l_counter := l_counter + 1;

					  /*Postal code*/
					  gtagdata(l_counter).TagName := 'RT8001_08';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information11;
					  l_counter := l_counter + 1;

					  /*Town*/
				  	  gtagdata(l_counter).TagName := 'RT8001_09';
					  gtagdata(l_counter).TagValue := rg_csr_8001.action_information12;
					  l_counter := l_counter + 1;

					  gtagdata(l_counter).TagName := 'REC_8001';
					  gtagdata(l_counter).TagValue := 'REC_8001_END';
					  l_counter := l_counter + 1;
				  END LOOP;

                END LOOP;

                FOR rg_csr_6001 IN csr_6001_corr_asst
                                             (l_payroll_action_id, rg_csr_6001_corr.action_information5,rg_csr_5000.action_information25
					      ,rg_csr_5000.action_information9,rg_csr_5000.action_information24,rg_csr_5000.action_information8) /* 8847591 */
                LOOP
                --make 6001 record
					gtagdata(l_counter).TagName := 'REC_6001';
					gtagdata(l_counter).TagValue := 'REC_6001';
					l_counter := l_counter + 1;

					/* line num */
					l_line_num := l_line_num + 1;
					gtagdata(l_counter).TagName := 'RT6001_01';
					gtagdata(l_counter).TagValue :=  rg_csr_6001.action_information30;
					--lpad(to_char(l_line_num),7,'0');
					l_counter := l_counter + 1;

					/*Rec num */
					gtagdata(l_counter).TagName := 'RT6001_02';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information3;
					l_counter := l_counter + 1;

					-- Field num
					gtagdata(l_counter).TagName := 'RT6001_03';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information6;
					l_counter := l_counter + 1;

					-- Amount
					gtagdata(l_counter).TagName := 'RT6001_04';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information7;
					l_counter := l_counter + 1;

					-- Sign
					gtagdata(l_counter).TagName := 'RT6001_05';
					gtagdata(l_counter).TagValue := rg_csr_6001.action_information8;
					l_counter := l_counter + 1;

					gtagdata(l_counter).TagName := 'REC_6001';
					gtagdata(l_counter).TagValue := 'REC_6001_END';
					l_counter := l_counter + 1;

                END LOOP;
                gtagdata(l_counter).TagName := 'REC_6000';
				gtagdata(l_counter).TagValue := 'REC_6000_END';
				l_counter := l_counter + 1;
				l_ctr := l_ctr + 1;
            END LOOP;
			IF l_ctr > 1 THEN
				gtagdata(l_counter).TagName := 'REC_5000';
				gtagdata(l_counter).TagValue := 'REC_5000_END';
				l_counter := l_counter + 1;
                        END IF;
			--Raji
           END LOOP;  -- kal rec 5000
       END IF;

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
		OPEN  csr_9999(l_payroll_action_id);
		FETCH csr_9999 INTO rg_csr_9999;
		CLOSE csr_9999;

		/* line num */
		l_line_num := l_line_num + 1;
		gtagdata(l_counter).TagName := 'RT9999_01';
		gtagdata(l_counter).TagValue := lpad(to_char(l_line_num),7,'0');
		l_counter := l_counter + 1;

		/*Rec num */
		gtagdata(l_counter).TagName := 'RT9999_02';
		gtagdata(l_counter).TagValue := rg_csr_9999.action_information3;
		l_counter := l_counter + 1;

		-- Number of records
		gtagdata(l_counter).TagName := 'RT9999_03';
		gtagdata(l_counter).TagValue := lpad(to_char(l_line_num),7,'0');
		l_counter := l_counter + 1;

		gtagdata(l_counter).TagName := 'REC_9999';
		gtagdata(l_counter).TagValue := 'REC_9999_END';
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

			--fnd_file.put_line(fnd_file.log,'wc3');
			FOR table_counter IN gtagdata.FIRST .. gtagdata.LAST LOOP

				l_str8 := gtagdata(table_counter).TagName;
				l_str9 := gtagdata(table_counter).TagValue ;

				IF l_str9 IN ('REC_1000','REC_1000_END','REC_2001','REC_2001_END','REC_2101','REC_2101_END',
				'REC_5000','REC_5000_END','REC_6000','REC_6000_END','REC_8001','REC_8001_END','REC_6001','REC_6001_END',
				'REC_6002','REC_6002_END','REC_6003','REC_6003_END','REC_6004','REC_6004_END','REC_6005','REC_6005_END','REC_9999','REC_9999_END') THEN

					--fnd_file.put_line(fnd_file.log,'Processing '||l_str9);
					IF l_str9 IN ('REC_1000','REC_2001','REC_2101','REC_5000','REC_6000','REC_8001','REC_6001','REC_6002','REC_6003','REC_6004','REC_6005','REC_9999') THEN
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

END PAY_DK_EINR;

/
