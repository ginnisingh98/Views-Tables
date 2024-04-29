--------------------------------------------------------
--  DDL for Package Body PAY_FI_DPSR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_FI_DPSR" AS
/* $Header: pyfidpsr.pkb 120.4.12010000.2 2009/03/10 06:42:07 rsengupt ship $ */

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
	l_payroll_action_id   PAY_ACTION_INFORMATION. ACTION_INFORMATION1%TYPE;
	/* End of declaration*/

	/* Cursors */
	/* Cursor to fetch data  related to Record 1 of VSPSERIE*/
	CURSOR csr_VSPSERIE1 (p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai , pay_assignment_actions paa
	WHERE paa.payroll_action_id = p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYFIDPSA'
	AND pai.action_information3  ='VSPSERIE'
	AND action_information29 ='1'
	ORDER BY pai.action_information2;

	/* Cursor to fetch data  related to Record 2 of VSPSERIE*/
	CURSOR csr_VSPSERIE2 (p_payroll_action_id NUMBER, p_action_context_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai , pay_assignment_actions paa
	WHERE paa.payroll_action_id = p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYFIDPSA'
	AND pai.action_information3  ='VSPSERIE'
	AND action_information29 ='2'
	AND pai.action_context_id = p_action_context_id
	ORDER BY pai.action_information2;

	rg_csr_VSPSERIE2  csr_VSPSERIE2%rowtype;


	/* Cursor to fetch data  related to Record VSRAERIE*/
	CURSOR csr_VSRAERIE(p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai , pay_assignment_actions paa
	WHERE paa.payroll_action_id = p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYFIDPSA'
	AND pai.action_information3  ='VSRAERIE'
	ORDER BY pai.action_information2;

	/* Cursor to fetch data  related to Record VSPSTUKI*/
	CURSOR csr_VSPSTUKI(p_payroll_action_id NUMBER) IS
	SELECT  pai.*
	FROM pay_action_information pai , pay_assignment_actions paa
	WHERE paa.payroll_action_id = p_payroll_action_id
	AND pai.action_context_id= paa.assignment_action_id
	AND pai.action_context_type= 'AAP'
	AND pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYFIDPSA'
	AND pai.action_information3  =  'VSPSTUKI'
	ORDER BY pai.action_information2;

	/* Cursor to fetch data  related to Record VSPSVYSL*/
	CURSOR csr_VSPSVYSL(p_payroll_action_id NUMBER) IS
	SELECT  *
	FROM pay_action_information pai
	WHERE pai.action_context_id= p_payroll_action_id
	AND pai.action_context_type= 'PA'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYFIDPSA'
	AND  pai.action_information2    =    'VSPSVYSL'
	ORDER BY pai.action_information4;


	/* Cursor to fetch data  related to Record VSPSVYHT*/
	CURSOR csr_VSPSVYHT(p_payroll_action_id NUMBER) IS
	SELECT  *
	FROM pay_action_information pai
	WHERE pai.action_context_id= p_payroll_action_id
	AND pai.action_context_type= 'PA'
	AND  pai.action_information_category = 'EMEA REPORT INFORMATION'
	AND  pai.action_information1 = 'PYFIDPSA'
	AND  pai.action_information2    =    'VSPSVYHT';

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

	/* Pick up the data  related to Record VSPSERIE*/
	FOR rg_csr_VSPSERIE1 IN csr_VSPSERIE1 (l_payroll_action_id)
	LOOP
		OPEN  csr_VSPSERIE2(p_payroll_action_id, rg_csr_VSPSERIE1.action_context_id);
		FETCH csr_VSPSERIE2 INTO rg_csr_VSPSERIE2;
		CLOSE csr_VSPSERIE2;

		/*Record Id*/
		gtagdata(l_counter).TagName := '000';
		gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information3;
		l_counter := l_counter + 1;

		/*Transaction Type*/
		gtagdata(l_counter).TagName := '101';
		gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information5;
		l_counter := l_counter + 1;

		/*Payment Type*/
		gtagdata(l_counter).TagName := '110';
		gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information4;
		l_counter := l_counter + 1;

		/*Filing year*/
		gtagdata(l_counter).TagName := '109';
		gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information6;
		l_counter := l_counter + 1;

		/*Payer ID*/
		gtagdata(l_counter).TagName := '102';
		gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information7;
		l_counter := l_counter + 1;

		/*Payee's ID*/
		gtagdata(l_counter).TagName := '111';
		gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information8;
		l_counter := l_counter + 1;

		/*Amount of Payment*/
		gtagdata(l_counter).TagName := '114';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information9);
		l_counter := l_counter + 1;

		/*Withhold tax*/
		gtagdata(l_counter).TagName := '115';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information10);
		l_counter := l_counter + 1;

		IF rg_csr_VSPSERIE1.action_information4  IN ('P','1','5','P2','H','H2')  THEN

			/*Employees' statutory pension and unemployment insurance contributions*/
			gtagdata(l_counter).TagName := '116';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information11);
			l_counter := l_counter + 1;

			/*Deduction prior to withhold tax*/
			gtagdata(l_counter).TagName := '117';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information12);
			l_counter := l_counter + 1;

			/*Taxable car benefit*/
			gtagdata(l_counter).TagName := '120';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information13);
			l_counter := l_counter + 1;

			/*Car Benefit Deduction made by employer*/
			gtagdata(l_counter).TagName := '121';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE2.action_information14);
			l_counter := l_counter + 1;


			/*Km according to driver's log*/
			gtagdata(l_counter).TagName := '122';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information14);
			l_counter := l_counter + 1;

			-- changes 2009 Start
			/*Car Bemefit , Age Category */
			gtagdata(l_counter).TagName := '123';
			gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information15;
			l_counter := l_counter + 1;

			/*Full Car Benefit */
			gtagdata(l_counter).TagName := '124';
			gtagdata(l_counter).TagValue := rg_csr_VSPSERIE2.action_information16;
			l_counter := l_counter + 1;

			-- Changes 2009 End


			/*Interest benefit from (accommodation) mortage*/
			gtagdata(l_counter).TagName := '130';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information16);
			l_counter := l_counter + 1;

			/*Other taxable benefits*/
			gtagdata(l_counter).TagName := '140';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information17);
			l_counter := l_counter + 1;

			/*Other benefits,Deduction made by Employer */
			gtagdata(l_counter).TagName := '141';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE2.action_information15);
			l_counter := l_counter + 1;


			/*Accommodation*/
			gtagdata(l_counter).TagName := '142';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information18,1,1);
			l_counter := l_counter + 1;

			/*Phone*/
			gtagdata(l_counter).TagName := '143';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information18,2,1);
			l_counter := l_counter + 1;

			/*Lunch*/
			gtagdata(l_counter).TagName := '144';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information18,3,1);
			l_counter := l_counter + 1;

			/*Other benefit in kind*/
			gtagdata(l_counter).TagName := '145';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information18,4,1);
			l_counter := l_counter + 1;

			/*Deduction made from lunch benefit is equivalent to the taxable value */
			gtagdata(l_counter).TagName := '146';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information18,6,1);
			l_counter := l_counter + 1;


			/*Work-related Travel ticket */
			gtagdata(l_counter).TagName := '147';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information18,5,1);
			l_counter := l_counter + 1;

			/*Tax free Daily allowances and meal compensations (etc.), total */
			gtagdata(l_counter).TagName := '150';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information19);
			l_counter := l_counter + 1;

			/*Tax free Daily allowance (domestic)*/
			gtagdata(l_counter).TagName := '151';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information20,1,1);
			l_counter := l_counter + 1;

			/*Tax free Half-day allowance*/
			gtagdata(l_counter).TagName := '152';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information20,2,1);
			l_counter := l_counter + 1;

			/*Tax free Foreign daily allowance*/
			gtagdata(l_counter).TagName := '153';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information20,3,1);
			l_counter := l_counter + 1;

			/*Tax free Meal compensation*/
			gtagdata(l_counter).TagName := '154';
			gtagdata(l_counter).TagValue := SUBSTR(rg_csr_VSPSERIE1.action_information20,4,1);
			l_counter := l_counter + 1;

			/*Tax-free mileage allowance, km total*/
			gtagdata(l_counter).TagName := '155';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information21);
			l_counter := l_counter + 1;

			/*Tax-free mileage allowance, Euros total*/
			gtagdata(l_counter).TagName := '156';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information22);
			l_counter := l_counter + 1;

			/*Taxable Compensations from expenses*/
			gtagdata(l_counter).TagName := '157';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE2.action_information9);
			l_counter := l_counter + 1;

			/*Payments for elected official in a (communal position of trust) */
			gtagdata(l_counter).TagName := '160';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE2.action_information10);
			l_counter := l_counter + 1;


			/*Benefit from Employer stock option schemes*/
			gtagdata(l_counter).TagName := '135';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information23);
			l_counter := l_counter + 1;

			/*Pension insurance payments paid by Employer*/
			gtagdata(l_counter).TagName := '180';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information24);
			l_counter := l_counter + 1;

			/*Voluntary pension insurance payments paid by Employee */
			gtagdata(l_counter).TagName := '181';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE2.action_information11);
			l_counter := l_counter + 1;

			/*Voluntary pension insurance payments paid by Employee*/
			gtagdata(l_counter).TagName := '182';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE2.action_information12);
			l_counter := l_counter + 1;


			/*Salary payments not subject to Social insurance daily allowance fee*/
			gtagdata(l_counter).TagName := '136';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information27);
			l_counter := l_counter + 1;

			/*Work-related Travel ticket as benefit in kind*/
			gtagdata(l_counter).TagName := '148';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSERIE1.action_information26);
			l_counter := l_counter + 1;

		END IF;

		/*End Code*/
		gtagdata(l_counter).TagName := '999';
		gtagdata(l_counter).TagValue := rg_csr_VSPSERIE1.action_information30;
		l_counter := l_counter + 1;

	END LOOP;

	/* Pick up the data  related to Record VSRAERIE*/
	FOR rg_csr_VSRAERIE IN csr_VSRAERIE(l_payroll_action_id)
	LOOP
		/*Record Id*/
		gtagdata(l_counter).TagName := '000';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information3;
		l_counter := l_counter + 1;

		/*Transaction Type*/
		gtagdata(l_counter).TagName := '301';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information5;
		l_counter := l_counter + 1;

		/*Payment Type*/
		gtagdata(l_counter).TagName := '316';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information4;
		l_counter := l_counter + 1;

		/*Filing year*/
		gtagdata(l_counter).TagName := '303';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information6;
		l_counter := l_counter + 1;

		/*Payer ID*/
		gtagdata(l_counter).TagName := '302';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information7;
		l_counter := l_counter + 1;

		/*Payee's ID*/
		gtagdata(l_counter).TagName := '312';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information8;
		l_counter := l_counter + 1;

		/*Payee's last name*/
		gtagdata(l_counter).TagName := '307';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information9;
		l_counter := l_counter + 1;

		/*Payee's First name(s)*/
		gtagdata(l_counter).TagName := '308';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information10;
		l_counter := l_counter + 1;

		/*Visiting address in country of permanent residence (home country)*/
		gtagdata(l_counter).TagName := '309';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information11;
		l_counter := l_counter + 1;

		/*Postal code in country of permanent residence (home country)*/
		gtagdata(l_counter).TagName := '310';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information12;
		l_counter := l_counter + 1;

		/*City/County or equivalent country of permanent residence*/
		gtagdata(l_counter).TagName := '311';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information13;
		l_counter := l_counter + 1;

		/*Foreign Personal ID */
		gtagdata(l_counter).TagName := '313';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information25;
		l_counter := l_counter + 1;


		/*Country code of home country (ISO 3166)*/
		gtagdata(l_counter).TagName := '341';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information14;
		l_counter := l_counter + 1;

		/*Name of home country*/
		gtagdata(l_counter).TagName := '342';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information24;
		l_counter := l_counter + 1;

		/*Gross pay amount, as the basis for the tax at source*/
		gtagdata(l_counter).TagName := '317';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSRAERIE.action_information15);
		l_counter := l_counter + 1;

		/*Amount of tax at source deducted*/
		gtagdata(l_counter).TagName := '318';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSRAERIE.action_information16);
		l_counter := l_counter + 1;

		IF rg_csr_VSRAERIE.action_information4  IN  ('A1','A2','A4','A5','A6','A7')  THEN

			/*Salary in money, cash*/
			gtagdata(l_counter).TagName := '319';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSRAERIE.action_information17);
			l_counter := l_counter + 1;

			/*Benefit in kind*/
			gtagdata(l_counter).TagName := '320';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSRAERIE.action_information18);
			l_counter := l_counter + 1;

			/*Tax at source deduction*/
			gtagdata(l_counter).TagName := '321';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSRAERIE.action_information19);
			l_counter := l_counter + 1;

			/*Daily allowances and expenses compensations*/
			gtagdata(l_counter).TagName := '322';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSRAERIE.action_information20);
			l_counter := l_counter + 1;

			/*Social security fee */
			gtagdata(l_counter).TagName := '324';
			gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSRAERIE.action_information23);
			l_counter := l_counter + 1;

			-- Changes 2009 Start

			/*Bank Account Number */
			gtagdata(l_counter).TagName := '325';
			gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information26;
			l_counter := l_counter + 1;

			-- Changes 2009 End



		END IF;
		/*Contact person*/
		gtagdata(l_counter).TagName := '305';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information21;
		l_counter := l_counter + 1;

		/*Contact person: Telephone Number*/
		gtagdata(l_counter).TagName := '336';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information22;
		l_counter := l_counter + 1;


		/*End Code*/
		gtagdata(l_counter).TagName := '999';
		gtagdata(l_counter).TagValue := rg_csr_VSRAERIE.action_information30;
		l_counter := l_counter + 1;

	END LOOP;


	/* Pick up the data  related to Record VSPSTUKI*/
	FOR rg_csr_VSPSTUKI IN csr_VSPSTUKI(l_payroll_action_id)
	LOOP
		/*Record Id*/
		gtagdata(l_counter).TagName := '000';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information3;
		l_counter := l_counter + 1;

		/*Transaction Type*/
		gtagdata(l_counter).TagName := '019';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information5;
		l_counter := l_counter + 1;

		/*Tax Type*/
		gtagdata(l_counter).TagName := '010';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information4;
		l_counter := l_counter + 1;

		/*Filing year*/
		gtagdata(l_counter).TagName := '602';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information6;
		l_counter := l_counter + 1;

		/*Payer ID*/
		gtagdata(l_counter).TagName := '002';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information7;
		l_counter := l_counter + 1;

		/*Payee ID*/
		gtagdata(l_counter).TagName := '011';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information8;
		l_counter := l_counter + 1;

		/*Payment month*/
		gtagdata(l_counter).TagName := '013';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information9;
		l_counter := l_counter + 1;

		/*Basis for the deduction*/
		gtagdata(l_counter).TagName := '014';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSTUKI.action_information10);
		l_counter := l_counter + 1;

		/*Calculatory salary for the part-time retired employee*/
		gtagdata(l_counter).TagName := '015';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSTUKI.action_information11);
		l_counter := l_counter + 1;

		/*Amount deducted as su bsidy of the low-paid*/
		gtagdata(l_counter).TagName := '016';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSTUKI.action_information12);
		l_counter := l_counter + 1;

		/*Hours from months at work*/
		gtagdata(l_counter).TagName := '017';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information13;
		l_counter := l_counter + 1;

		/*Ending code*/
		gtagdata(l_counter).TagName := '999';
		gtagdata(l_counter).TagValue := rg_csr_VSPSTUKI.action_information30;
		l_counter := l_counter + 1;

	END LOOP;


	/* Pick up the data  related to Record VSPSVYSL*/
	FOR rg_csr_VSPSVYSL IN csr_VSPSVYSL(l_payroll_action_id)
	LOOP
		/*Record Id*/
		gtagdata(l_counter).TagName := '000';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYSL.action_information2;
		l_counter := l_counter + 1;

		/*Transaction Type*/
		gtagdata(l_counter).TagName := '611';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYSL.action_information3;
		l_counter := l_counter + 1;

		/*Payment Type*/
		gtagdata(l_counter).TagName := '606';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYSL.action_information4;
		l_counter := l_counter + 1;

		/*Filing year*/
		gtagdata(l_counter).TagName := '602';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYSL.action_information5;
		l_counter := l_counter + 1;

		/*Payer ID*/
		gtagdata(l_counter).TagName := '601';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYSL.action_information6;
		l_counter := l_counter + 1;

		/*Total amount of payments*/
		gtagdata(l_counter).TagName := '607';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYSL.action_information7);
		l_counter := l_counter + 1;

		/*Withhold tax/tax at source*/
		gtagdata(l_counter).TagName := '608';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYSL.action_information8);
		l_counter := l_counter + 1;

		/*Number of records)*/
		gtagdata(l_counter).TagName := '620';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYSL.action_information9;
		l_counter := l_counter + 1;

		/*Ending code*/
		gtagdata(l_counter).TagName := '999';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYSL.action_information30;
		l_counter := l_counter + 1;

	END LOOP;

	/* Pick up the data  related to Record VSPSVYHT*/
	FOR rg_csr_VSPSVYHT IN csr_VSPSVYHT(l_payroll_action_id)
	LOOP
		/*Record Id*/
		gtagdata(l_counter).TagName := '000';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information2;
		l_counter := l_counter + 1;

		/*Transaction Type*/
		gtagdata(l_counter).TagName := '611';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information3;
		l_counter := l_counter + 1;

		/*Filing year*/
		gtagdata(l_counter).TagName := '602';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information4;
		l_counter := l_counter + 1;

		/*Payer ID*/
		gtagdata(l_counter).TagName := '601';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information5;
		l_counter := l_counter + 1;

		/*Contact person*/
		gtagdata(l_counter).TagName := '605';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information6;
		l_counter := l_counter + 1;

		/*Contact Person Telephone Number*/
		gtagdata(l_counter).TagName := '604';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information7;
		l_counter := l_counter + 1;

		/*Number of summary records */
		gtagdata(l_counter).TagName := '612';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information8;
		l_counter := l_counter + 1;

		/*Benefits in kind */
		gtagdata(l_counter).TagName := '615';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYHT.action_information9);
		l_counter := l_counter + 1;

		/*Employees' statutory pension and unemployment insurance contributions*/
		gtagdata(l_counter).TagName := '640';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYHT.action_information10);
		l_counter := l_counter + 1;

		/*Deductions prior to withhold tax, total(pre tax deductions)*/
		gtagdata(l_counter).TagName := '641';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYHT.action_information11);
		l_counter := l_counter + 1;

		/*Salaries have not been paid during filing year*/
		gtagdata(l_counter).TagName := '613';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYHT.action_information12);
		l_counter := l_counter + 1;

		/*Deductions from social security fee*/
		gtagdata(l_counter).TagName := '631';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYHT.action_information13);
		l_counter := l_counter + 1;

		/*Amount deducted from salaries subject to social insurance fee.*/
		gtagdata(l_counter).TagName := '670';
		gtagdata(l_counter).TagValue := FND_NUMBER.CANONICAL_TO_NUMBER(rg_csr_VSPSVYHT.action_information14);
		l_counter := l_counter + 1;


		/*Ending code*/
		gtagdata(l_counter).TagName := '999';
		gtagdata(l_counter).TagValue := rg_csr_VSPSVYHT.action_information30;
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
		l_IANA_charset :=hr_fi_utility.get_IANA_charset ;
		hr_utility.set_location('Entering WritetoCLOB ',70);
		l_str1 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT><DPSR>' ;
		l_str2 := '<';
		l_str3 := '>';
		l_str4 := '</';
		l_str5 := '>';
		l_str6 := '</DPSR></ROOT>';
		l_str7 := '<?xml version="1.0" encoding="'||l_IANA_charset||'"?> <ROOT></ROOT>';


		dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
		dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);

		current_index := 0;

		IF gtagdata.count > 0 THEN

			dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );


			FOR table_counter IN gtagdata.FIRST .. gtagdata.LAST LOOP

				l_str8 := gtagdata(table_counter).TagName;
				l_str9 := '<![CDATA[ '|| gtagdata(table_counter).TagValue ||' ]]>';

					if l_str9 is not null then
						dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
						dbms_lob.writeAppend(l_xfdf_string, 11 , 'RECORD_DPSR');
						dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);

						dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
						dbms_lob.writeAppend(l_xfdf_string, 4, 'CODE');
						dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str8), l_str8);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
						dbms_lob.writeAppend(l_xfdf_string, 4 , 'CODE');
						dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);

						dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
						dbms_lob.writeAppend(l_xfdf_string, 5, 'VALUE');
						dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str9), l_str9);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
						dbms_lob.writeAppend(l_xfdf_string, 5, 'VALUE');
						dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
						dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
						dbms_lob.writeAppend(l_xfdf_string, 11 , 'RECORD_DPSR');
						dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);

					/*
					else

					dbms_lob.writeAppend(l_xfdf_string, length(l_str2), l_str2);
					dbms_lob.writeAppend(l_xfdf_string, 11 , 'RECORD_DPSR');
					dbms_lob.writeAppend(l_xfdf_string, length(l_str3), l_str3);
					dbms_lob.writeAppend(l_xfdf_string, length(l_str4), l_str4);
					dbms_lob.writeAppend(l_xfdf_string, 11 , 'RECORD_DPSR');
					dbms_lob.writeAppend(l_xfdf_string, length(l_str5), l_str5);
					*/
					end if;

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

END PAY_FI_DPSR;

/
