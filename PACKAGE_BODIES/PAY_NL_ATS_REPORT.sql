--------------------------------------------------------
--  DDL for Package Body PAY_NL_ATS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_NL_ATS_REPORT" AS
/* $Header: paynlats.pkb 120.2.12000000.6 2007/08/31 05:32:03 rsahai noship $ */

level_cnt NUMBER;



/*Counter for accessing the values in PAY_NL_XDO_REPORT.vXMLTable*/
vCtr NUMBER;

/*-------------------------------------------------------------------------------
|Name           : populate_ats_report_data                                      |
|Type		: Procedure						        |
|Description    : Procedure to generate the Annual Tax Statement Report         |
------------------------------------------------------------------------------*/

procedure populate_ats_report_data
		(p_person_id IN NUMBER,
		 p_year      IN VARCHAR2,
		 p_bg_id     IN NUMBER,
		 p_employer_id IN NUMBER,
		 p_agg_flag IN VARCHAR2,
	       p_xfdf_blob OUT NOCOPY BLOB) IS

/*Cursor to pick up necessary details*/

	cursor get_infos(lp_tax_year_end_date date,lp_tax_year_start_date date,lp_yes varchar2,lp_no varchar2,lp_archive_action number) is
	select  /*+ ORDERED */ pap.full_name Employee_name,
		hou.name Employer_name,
	 	hoi.org_information4 Tax_registration_number,
	 	pap.person_id Person_Id,
		paa.assignment_id Assignment_Id,
	 	pap.employee_number,
	 	paa.assignment_number,
	 	to_char(pap.Date_Of_Birth,'DD/MM/YYYY') Date_Of_Birth,
		ppos.date_start Date_Start,
		nvl(ppos.actual_termination_date,lp_tax_year_end_date) Date_End,
		to_char(greatest(ppos.date_start,lp_tax_year_start_date),'DD/MM/YYYY')||' - '||to_char(least(nvl(ppos.actual_termination_date,lp_tax_year_end_date),lp_tax_year_end_date),'DD/MM/YYYY') Period_Of_Service,
	 	pap.national_identifier SOFI_number,
	 	DECODE(SUBSTR(pai.action_information10,2,1),1,hr_general.decode_lookup('NL_TAX_TABLE','1'),2,hr_general.decode_lookup('NL_TAX_TABLE','2'),'') Wage_Tax_Table,
	 	decode(substr(pai.action_information9,1,1),'1',lp_yes,lp_no) Wage_Tax_Discount1,
	 	'(' || substr(pai.action_information9,2,2)||'/'||substr(pai.action_information9,4,2)||'/'||to_char(lp_tax_year_end_date,'YYYY') || ')' Date1,
	 	decode(substr(pai.action_information9,6,1),'1',lp_yes,lp_no) Wage_Tax_Discount2,
	 	'(' || substr(pai.action_information9,7,2)||'/'||substr(pai.action_information9,9,2)||'/'||to_char(lp_tax_year_end_date,'YYYY') || ')' Date2,
	 	decode(substr(pai.action_information9,11,1),'1',lp_yes,lp_no) Wage_Tax_Discount3,
	 	'(' || substr(pai.action_information9,12,2)||'/'||substr(pai.action_information9,14,2)||'/'||to_char(lp_tax_year_end_date,'YYYY') || ')' Date3,
	 	NVL(pai.action_information18,pai.action_information4) Taxable_Income,
	 	pai.action_Information5 Deducted_Wage_Tax,
	 	pai.action_information8 Labour_Tax_Reduction,
	 	decode(substr(pai.action_information14,1,1),'1',lp_yes,2,lp_yes,3,lp_yes,lp_no) Insured_For_WAO,
	 	--decode(substr(pai.action_information14,2,1),'1',lp_yes,2,lp_yes,3,lp_yes,lp_no) Insured_For_ZFW,
	 	pai.action_information15  ZVW_Cont,
		substr(pai.action_information12,13,1) Company_Car,
	 	pai.action_information17  Private_Use_Car,
	 	pai.action_information16  Net_Expense_Allowance,
		pai.action_information19  ZVW_Basis,
		pai.action_information20  Value_Private_Use_Car,
		pai.action_information21  Saved_Amount_LSS,
		pai.action_information22  Employer_Child_Care,
		pai.action_information23  Allowance_on_Disability,
		pai.action_information24  Applied_LCLD,
		pai.action_information25  User_Bal_String
	 from
                pay_assignment_actions assact,
                pay_action_information pai,
                per_all_assignments_f paa,
                per_all_people_f pap,
                per_periods_of_service ppos,
                hr_organization_units hou,
                hr_organization_information hoi
	 where
 	 	pai.action_context_type = 'AAP'
		and assact.payroll_action_id = lp_archive_action
		and pai.action_context_id = assact.assignment_action_id
 	 	and pai.action_information_category = 'NL ATS EMPLOYEE DETAILS'
	        and hoi.org_information_context = 'NL_ORG_INFORMATION'
	 	and pap.person_id = nvl(p_person_id,pap.person_id)
		and ppos.person_id = pap.person_id
		and ppos.date_start <= lp_Tax_Year_End_Date
		--and nvl(ppos.actual_termination_date, lp_Tax_Year_End_Date) >= lp_Tax_Year_Start_Date
	 	and pai.action_information1 = to_char(p_employer_id)
	 	and decode(pai.action_information_category,'NL ATS EMPLOYEE DETAILS',fnd_number.canonical_to_number(pai.action_information2),null) = nvl(p_person_id,pap.person_id)
	 	and decode(pai.action_information_category,'NL ATS EMPLOYEE DETAILS',fnd_number.canonical_to_number(pai.action_information3),null) = paa.assignment_id
	 	and pai.effective_date = lp_Tax_Year_End_Date
	and 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM	per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   asg.payroll_id is not NULL
		and   asg.effective_start_date <= least(nvl(ppos.actual_termination_date, lp_Tax_Year_End_Date), lp_Tax_Year_End_Date)
		and   nvl(asg.effective_end_date, lp_Tax_Year_End_Date) >= ppos.date_start

		)
	 	and lp_Tax_Year_End_Date between pap.effective_start_date and pap.effective_end_date
	 	and lp_Tax_Year_End_Date between hou.date_from and nvl(hou.date_to,hr_general.end_of_time)
	 	and paa.person_id = pap.person_id
	 	and pap.business_group_id = p_bg_id
	 	and paa.business_group_id = p_bg_id
	        and hou.organization_id = p_employer_id
	        and hoi.organization_id = p_employer_id
 	 	order by get_Address_Style(pap.person_id,lp_tax_year_end_date) desc, get_Post_Code(pap.person_id,lp_tax_year_end_date) asc, pap.person_id asc, paa.assignment_id asc;

/*	CURSOR csr_org_hierarchy_name(lp_business_group_id number,lp_tax_year_end_date date) IS
	select
	pos.name
	from
	per_organization_structures pos,
	per_org_structure_versions posv
	where pos.organization_structure_id = posv.organization_structure_id
	and to_char(pos.organization_structure_id) IN (select org_information1
	from hr_organization_information hoi where hoi.org_information_context='NL_BG_INFO'
	and hoi.organization_id=lp_business_group_id)
	and lp_tax_year_end_date between posv.date_from and nvl(posv.date_to,hr_general.End_of_time);*/

	CURSOR csr_get_org_name(lp_org_id number) IS
	select name
	from hr_organization_units
	where organization_id = lp_org_id;

	CURSOR csr_get_person_name(lp_person_id number,lp_effective_date date) IS
	select full_name from per_all_people_f
	where person_id = lp_person_id
	and lp_effective_date between effective_start_date and effective_end_date;

	CURSOR csr_org_glb_address(p_bg_id NUMBER, p_org_id NUMBER) IS
	select	hlc.loc_information14					house_number,
		hlc.loc_information15					house_no_add,
		hr_general.decode_lookup('NL_REGION',hlc.region_1)	street_name,
		hlc.address_line_1					address_line1,
		hlc.address_line_2					address_line2,
		hlc.address_line_3					address_line3,
		hlc.postal_code						postcode,
		hlc.town_or_city					city,
		pay_nl_general.get_country_name(hlc.country)		country,
		hlc.style						add_style
	from	hr_locations						hlc,
		hr_organization_units					hou
	where	hou.business_group_id = p_bg_id
	and	hou.organization_id = p_org_id
	and	hlc.location_id = hou.location_id;

	CURSOR csr_emp_glb_address(p_person_id NUMBER, p_effective_date DATE) IS
	select	pad.add_information13					house_number,
		pad.add_information14					house_no_add,
		hr_general.decode_lookup('NL_REGION',pad.region_1)	street_name,
		pad.address_line1					address_line1,
		pad.address_line2					address_line2,
		pad.address_line3					address_line3,
		pad.postal_code						postcode,
		pad.town_or_city					city,
		pay_nl_general.get_country_name(pad.country)		country,
		pad.style						add_style
	from	per_addresses						pad
	where	pad.person_id = p_person_id
	and	p_effective_date between pad.date_from and nvl(pad.date_to,hr_general.end_of_time)
	and	pad.primary_flag = 'Y';

	CURSOR	csr_get_leg_employer(p_assignment_id NUMBER, p_tax_year_start_date DATE, p_tax_year_end_date DATE) IS
	select	hou.organization_id leg_emp_id,
		hoi.org_information1 leg_tax_ref
	from	hr_organization_units hou,
		hr_organization_information hoi,
		hr_organization_information hoi1,
		per_all_assignments_f paa
	where	paa.assignment_id = p_assignment_id
	and	hou.organization_id = nvl(paa.establishment_id,-1)
	and	hoi.organization_id = hou.organization_id
	and	hoi1.organization_id = hou.organization_id
	and	hoi1.org_information_context = 'CLASS'
	and	hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	and	hoi1.org_information2 = 'Y'
	and	hoi.org_information_context = 'NL_LE_TAX_DETAILS'
	and	hoi.org_information1 IS NOT NULL
	and	hoi.org_information2 IS NOT NULL
	and 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   asg.effective_start_date <= p_tax_year_end_date
		and   nvl(asg.effective_end_date, p_tax_year_end_date) >= p_tax_year_start_date

		);


	l_output_fname varchar2(1000);
	l_return_value number;
	l_effective_date date;
	l_tax_year_start_date date;
	l_employee varchar2(255);
	l_Employer_Name varchar2(255);
	l_Legal_Employer_Name varchar2(255);
	l_business_group_name varchar2(240);
--	l_Organization_Hierarchy_Name varchar2(255);
	l_addr1_er varchar2(500) := null;
	l_addr1_ee varchar2(500) := null;
	l_addr2_er varchar2(500) := null;
	l_addr2_ee varchar2(500) := null;
	l_house_number_er varchar2(255);
	l_house_add_no_er varchar2(255);
	l_street_name_er varchar2(255);
	l_line1_er varchar2(255);
	l_line2_er varchar2(255);
	l_line3_er varchar2(255);
	l_city_er varchar2(255);
	l_country_er varchar2(255);
	l_po_code_er varchar2(255);
	l_add_style_er varchar2(255);
	l_add_style_ee varchar2(255);
	l_return_value1 number;
	l_house_number_ee varchar2(255);
	l_house_add_no_ee varchar2(255);
	l_street_name_ee varchar2(255);
	l_line1_ee varchar2(255);
	l_line2_ee varchar2(255);
	l_line3_ee varchar2(255);
	l_city_ee varchar2(255);
	l_country_ee varchar2(255);
	l_po_code_ee varchar2(255);
	l_person_id number;
	l_previous_person_id number;
	l_date1 varchar2(20);
	l_date2 varchar2(20);
	l_date3 varchar2(20);
	l_wtd1 varchar2(20);
	l_wtd2 varchar2(20);
	l_wtd3 varchar2(20);
	l_year varchar2(20);
	l_year_msg varchar2(255);
	l_field_count number;
	l_yes varchar2(20);
	l_no varchar2(20);
	l_taxable_income number;
	l_deducted_wage_tax number;
	l_labour_tax_reduction number;
	l_ZVW number;
	l_ZVW_Basis number;
	l_Private_Use_Car number;
	l_Net_Expense_Allowance number;
	l_Value_Private_Use_Car number;
	l_Saved_Amount_LSS number;
	l_Employer_Child_Care number;
	l_Allowance_on_Disability number;
	l_Applied_LCLD number;
	l_agg_flag varchar2(20);
	l_leg_emp_id number := null;
	l_leg_tax_ref varchar2(100) := null;
	l_period_of_service varchar2(100) := null;
	l_prev_period_of_service varchar2(100) := null;
	l_archive_action number;
	lCtr number;



/*Make calls to suppoting procedures to form the XML file*/

begin

	--hr_utility.trace_on(NULL,'ATS_TAB');
	--hr_utility.set_location('inside ATS',10);
	l_archive_action:=0;
	l_taxable_income:=0;
	l_deducted_wage_tax:=0;
	l_labour_tax_reduction:=0;
	l_ZVW:=0;
	l_ZVW_Basis:=0;
	l_Private_Use_Car:=0;
	l_Net_Expense_Allowance:=0;
	l_Value_Private_Use_Car:=0;
	l_Saved_Amount_LSS:=0;
	l_Employer_Child_Care:=0;
	l_Allowance_on_Disability:=0;
	l_Applied_LCLD:=0;
	vUserBalVal.DELETE;
	l_previous_person_id:=-1;

	l_effective_date := fnd_date.canonical_to_date(p_year);
	l_year := to_char(l_effective_date,'YYYY');
	l_tax_year_start_date := to_date('01-01-'||l_year,'DD-MM-YYYY');
	l_yes :=hr_general.decode_lookup('HR_NL_YES_NO','Y');
	l_no :=hr_general.decode_lookup('HR_NL_YES_NO','N');

	PAY_NL_TAXOFFICE_ARCHIVE.populate_UserBal(p_bg_id,l_effective_date);
	hr_utility.set_location('Table populated, count-'||PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.COUNT,10);

	if p_agg_flag = 'Y' THEN
		l_agg_flag := hr_general.decode_lookup('HR_NL_YES_NO','Y');
	else
		l_agg_flag := hr_general.decode_lookup('HR_NL_YES_NO','N');
	end if;

	BEGIN

		select	max(ppa.payroll_action_id)
		into	l_archive_action
		from	pay_payroll_actions ppa
		where	ppa.report_qualifier='NL'
		and	ppa.business_group_id=p_bg_id
		and	ppa.report_type='NL_TAXOFFICE_ARCHIVE'
		and	ppa.report_category='ARCHIVE'
		and	pay_nl_taxoffice_archive.get_parameter(ppa.legislative_parameters,'EMPLOYER_ID')=to_char(p_employer_id)
		and	effective_date between l_tax_year_start_date and l_effective_date;

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN l_archive_action := 0;

		WHEN OTHERS
			THEN l_archive_action := 0;

	END;

	OPEN csr_get_org_name(p_bg_id);
	FETCH csr_get_org_name into l_business_group_name;
	CLOSE csr_get_org_name;


	OPEN csr_get_org_name(p_employer_id);
	FETCH csr_get_org_name into l_Employer_Name;
	CLOSE csr_get_org_name;

	/*OPEN csr_org_glb_address(p_bg_id, p_employer_id);
	FETCH	csr_org_glb_address
	INTO	l_house_number_er,
		l_house_add_no_er,
		l_street_name_er,
		l_line1_er,
		l_line2_er,
		l_line3_er,
		l_po_code_er,
		l_city_er,
		l_country_er,
		l_add_style_er;
	CLOSE csr_org_glb_address;

	IF l_add_style_er = 'NL' THEN

		l_return_value := pay_nl_general.get_org_address(p_employer_id
									 ,p_bg_id
									 ,l_house_number_er
									 ,l_house_add_no_er
									 ,l_street_name_er
									 ,l_line1_er
									 ,l_line2_er
									 ,l_line3_er
									 ,l_city_er
									 ,l_country_er
									 ,l_po_code_er);

	END IF;

	IF l_street_name_er is not NULL THEN
		l_addr1_er := l_street_name_er;
	END IF;

	IF l_house_number_er is not NULL THEN
		IF l_addr1_er is not NULL THEN
			l_addr1_er := l_addr1_er||', '||l_house_number_er;
		ELSE
			l_addr1_er := l_house_number_er;
		END IF;
	END IF;

	IF l_house_add_no_er is not NULL THEN
		IF l_addr1_er is not NULL THEN
			l_addr1_er := l_addr1_er||', '||l_house_add_no_er;
		ELSE
			l_addr1_er := l_house_add_no_er;
		END IF;
	END IF;


	IF l_po_code_er is not NULL THEN
		l_addr2_er := l_po_code_er;
	END IF;

	IF l_city_er is not NULL THEN
		IF l_addr2_er is not NULL THEN
			l_addr2_er := l_addr2_er||', '||l_city_er;
		ELSE
			l_addr2_er := l_city_er;
		END IF;
	END IF;*/


	if p_person_id is not null then
		OPEN csr_get_person_name(p_person_id,l_effective_date);
		FETCH csr_get_person_name into l_employee;
		CLOSE csr_get_person_name;
	end if;


/*	OPEN csr_org_hierarchy_name(p_bg_id,l_effective_date);
	FETCH csr_org_hierarchy_name INTO l_Organization_Hierarchy_Name;
	CLOSE csr_org_hierarchy_name;*/

 	PAY_NL_XDO_REPORT.vXMLTable.DELETE;
 	vCtr := 0;

/*Get all the XML tags and values*/

 	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_effective_date,'DD/MM/YYYY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Year_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_effective_date,'YYYY');
	vCtr := vCtr + 1;
--	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Org_Hierarchy_Header';
--	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Organization_Hierarchy_Name;
--	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employer_Name;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employee;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Business_Group_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_business_group_name;
	vCtr := vCtr+1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Aggregate_Flag';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_agg_flag;
	vCtr := vCtr+1;

	for info_rec in get_infos(l_effective_date,l_tax_year_start_date,l_yes,l_no,l_archive_action)
	LOOP
		l_person_id:=info_rec.Person_Id;
		IF info_rec.Date_End > l_tax_year_start_date THEN
			l_period_of_service := info_rec.period_of_service;
		ELSE
			l_period_of_service := to_char(info_rec.date_start,'DD/MM/YYYY')||' - '||to_char(info_rec.date_end,'DD/MM/YYYY');
		END IF;

		OPEN csr_get_leg_employer(info_rec.Assignment_Id, l_tax_year_start_date, l_effective_date);
		FETCH csr_get_leg_employer INTO l_leg_emp_id, l_leg_tax_ref;
		IF csr_get_leg_employer%NOTFOUND THEN
			l_leg_emp_id := null;
			l_leg_tax_ref := null;
			l_Legal_Employer_Name := null;
		END IF;
		CLOSE csr_get_leg_employer;

		IF l_leg_emp_id is not NULL and l_leg_tax_ref is not NULL THEN

			OPEN csr_get_org_name(l_leg_emp_id);
			FETCH csr_get_org_name into l_Legal_Employer_Name;
			CLOSE csr_get_org_name;

			OPEN csr_org_glb_address(p_bg_id, l_leg_emp_id);
			FETCH	csr_org_glb_address
			INTO	l_house_number_er,
				l_house_add_no_er,
				l_street_name_er,
				l_line1_er,
				l_line2_er,
				l_line3_er,
				l_po_code_er,
				l_city_er,
				l_country_er,
				l_add_style_er;
			CLOSE csr_org_glb_address;

			IF l_add_style_er = 'NL' THEN

				l_return_value := pay_nl_general.get_org_address(l_leg_emp_id
											 ,p_bg_id
											 ,l_house_number_er
											 ,l_house_add_no_er
											 ,l_street_name_er
											 ,l_line1_er
											 ,l_line2_er
											 ,l_line3_er
											 ,l_city_er
											 ,l_country_er
											 ,l_po_code_er);

			END IF;

			IF l_street_name_er is not NULL THEN
				l_addr1_er := l_street_name_er;
			END IF;

			IF l_house_number_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_number_er;
				ELSE
					l_addr1_er := l_house_number_er;
				END IF;
			END IF;

			IF l_house_add_no_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_add_no_er;
				ELSE
					l_addr1_er := l_house_add_no_er;
				END IF;
			END IF;


			IF l_po_code_er is not NULL THEN
				l_addr2_er := l_po_code_er;
			END IF;

			IF l_city_er is not NULL THEN
				IF l_addr2_er is not NULL THEN
					l_addr2_er := l_addr2_er||' '||l_city_er;
				ELSE
					l_addr2_er := l_city_er;
				END IF;
			END IF;

		ELSE

			/*OPEN csr_get_org_name(p_employer_id);
			FETCH csr_get_org_name into l_Legal_Employer_Name;
			CLOSE csr_get_org_name;*/

			OPEN csr_org_glb_address(p_bg_id, p_employer_id);
			FETCH	csr_org_glb_address
			INTO	l_house_number_er,
				l_house_add_no_er,
				l_street_name_er,
				l_line1_er,
				l_line2_er,
				l_line3_er,
				l_po_code_er,
				l_city_er,
				l_country_er,
				l_add_style_er;
			CLOSE csr_org_glb_address;

			IF l_add_style_er = 'NL' THEN

				l_return_value := pay_nl_general.get_org_address(p_employer_id
											 ,p_bg_id
											 ,l_house_number_er
											 ,l_house_add_no_er
											 ,l_street_name_er
											 ,l_line1_er
											 ,l_line2_er
											 ,l_line3_er
											 ,l_city_er
											 ,l_country_er
											 ,l_po_code_er);

			END IF;

			IF l_street_name_er is not NULL THEN
				l_addr1_er := l_street_name_er;
			END IF;

			IF l_house_number_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_number_er;
				ELSE
					l_addr1_er := l_house_number_er;
				END IF;
			END IF;

			IF l_house_add_no_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_add_no_er;
				ELSE
					l_addr1_er := l_house_add_no_er;
				END IF;
			END IF;


			IF l_po_code_er is not NULL THEN
				l_addr2_er := l_po_code_er;
			END IF;

			IF l_city_er is not NULL THEN
				IF l_addr2_er is not NULL THEN
					l_addr2_er := l_addr2_er||' '||l_city_er;
				ELSE
					l_addr2_er := l_city_er;
				END IF;
			END IF;


		END IF;

		if p_agg_flag = 'Y' then

			if  l_person_id = l_previous_person_id AND l_period_of_service = l_prev_period_of_service then

				l_taxable_income:=fnd_number.canonical_to_number(info_rec.taxable_income) + l_taxable_income;
				l_deducted_wage_tax:=fnd_number.canonical_to_number(info_rec.deducted_wage_tax) + l_deducted_wage_tax;
				l_labour_tax_reduction:=fnd_number.canonical_to_number(info_rec.labour_tax_reduction) + l_labour_tax_reduction;
				l_ZVW:=fnd_number.canonical_to_number(info_rec.ZVW_Cont) + l_ZVW;
				l_ZVW_Basis:=fnd_number.canonical_to_number(info_rec.ZVW_Basis) + l_ZVW_Basis;
				l_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Private_Use_Car) + l_Private_Use_Car;
				l_Net_Expense_Allowance:=fnd_number.canonical_to_number(info_rec.Net_Expense_Allowance) + l_Net_Expense_Allowance;
				l_Value_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Value_Private_Use_Car) + l_Value_Private_Use_Car;
				l_Saved_Amount_LSS:=fnd_number.canonical_to_number(info_rec.Saved_Amount_LSS) + l_Saved_Amount_LSS;
				l_Employer_Child_Care:=fnd_number.canonical_to_number(info_rec.Employer_Child_Care) + l_Employer_Child_Care;
				l_Allowance_on_Disability:=fnd_number.canonical_to_number(info_rec.Allowance_on_Disability) + l_Allowance_on_Disability;
				l_Applied_LCLD:=fnd_number.canonical_to_number(info_rec.Applied_LCLD) + l_Applied_LCLD;
				populate_UserBalVal(info_rec.User_Bal_String,'Y');

			end if;


			if  l_person_id <> l_previous_person_id OR l_period_of_service <> l_prev_period_of_service then

				if l_previous_person_id <> -1 then

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Taxable_Income';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Taxable_Income;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Deducted_Wage_Tax';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Deducted_Wage_Tax;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Labour_Tax_Reduction';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Labour_Tax_Reduction;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_for_ZVW';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW_Basis;
					vCtr := vCtr + 1;

					/*hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagName,100);
					hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagValue,110);*/

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ZVW_Cont';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW;
					vCtr := vCtr + 1;

					/*hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagName,100);
					hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagValue,110);*/


					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Private_Use_Car';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Private_Use_Car;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Net_Expense_Allowance';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Net_Expense_Allowance;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Value_Private_Use_Car';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Value_Private_Use_Car;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Saved_Amount_LSS';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Saved_Amount_LSS;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Child_Care';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employer_Child_Care;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Allowance_on_Disability';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Allowance_on_Disability;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Applied_LCLD';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Applied_LCLD;
					vCtr := vCtr + 1;

					IF vUserBalVal.COUNT > 0 THEN

						FOR lCtr IN vUserBalVal.FIRST .. vUserBalVal.LAST LOOP

							PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := vUserBalVal(lCtr).TagName;
							PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := vUserBalVal(lCtr).BalValue;
							vCtr := vCtr + 1;

						END LOOP;

					END IF;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
					vCtr := vCtr + 1;

					l_taxable_income:=0;
					l_deducted_wage_tax:=0;
					l_labour_tax_reduction:=0;
					l_ZVW:=0;
					l_ZVW_Basis:=0;
					l_Private_Use_Car:=0;
					l_Net_Expense_Allowance:=0;
					l_Value_Private_Use_Car:=0;
					l_Saved_Amount_LSS:=0;
					l_Employer_Child_Care:=0;
					l_Allowance_on_Disability:=0;
					l_Applied_LCLD:=0;
					vUserBalVal.DELETE;

				end if;

				l_taxable_income:=fnd_number.canonical_to_number(info_rec.taxable_income);
				l_deducted_wage_tax:=fnd_number.canonical_to_number(info_rec.deducted_wage_tax);
				l_labour_tax_reduction:=fnd_number.canonical_to_number(info_rec.labour_tax_reduction);
				l_ZVW:=fnd_number.canonical_to_number(info_rec.ZVW_Cont);
				l_ZVW_Basis:=fnd_number.canonical_to_number(info_rec.ZVW_Basis);
				l_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Private_Use_Car);
				l_Net_Expense_Allowance:=fnd_number.canonical_to_number(info_rec.Net_Expense_Allowance);
				l_Value_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Value_Private_Use_Car);
				l_Saved_Amount_LSS:=fnd_number.canonical_to_number(info_rec.Saved_Amount_LSS);
				l_Employer_Child_Care:=fnd_number.canonical_to_number(info_rec.Employer_Child_Care);
				l_Allowance_on_Disability:=fnd_number.canonical_to_number(info_rec.Allowance_on_Disability);
				l_Applied_LCLD:=fnd_number.canonical_to_number(info_rec.Applied_LCLD);
				populate_UserBalVal(info_rec.User_Bal_String,'N');



				l_date1:=info_rec.Date1;
				l_date2:=info_rec.Date2;
				l_date3:=info_rec.Date3;
				l_wtd1:=info_rec.Wage_Tax_Discount1;
				l_wtd2:=info_rec.Wage_Tax_Discount2;
				l_wtd3:=info_rec.Wage_Tax_Discount3;
				l_field_count:=1;

				if l_date1 like '%00/%' then
					l_date1:=null;
					l_wtd1:=null;
				end if;

				if l_date2 like '%00/%' then
					l_date2:=null;
					l_wtd2:=null;
				end if;

				if l_date3 like '%00/%' then
					l_date3:=null;
					l_wtd3:=null;
				end if;

				fnd_message.set_name('PAY','PAY_NL_ATS_YEAR');
				fnd_message.set_token('YEAR',l_year);
				l_year_msg:=fnd_message.get();

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Year_Detail';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_year_msg;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Name';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := nvl(l_Legal_Employer_Name,info_rec.Employer_Name);
				vCtr := vCtr + 1;


				/*if l_street_name_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_house_number_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_house_add_no_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr1_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line1_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line2_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_line3_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				/*if l_po_code_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_city_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr2_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_country_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				l_field_count:=1;


				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Name';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Name;
				vCtr := vCtr + 1;

				OPEN csr_emp_glb_address(l_person_id, fnd_date.canonical_to_date(p_year));
				FETCH	csr_emp_glb_address
				INTO	l_house_number_ee,
					l_house_add_no_ee,
					l_street_name_ee,
					l_line1_ee,
					l_line2_ee,
					l_line3_ee,
					l_po_code_ee,
					l_city_ee,
					l_country_ee,
					l_add_style_ee;
				CLOSE csr_emp_glb_address;

				IF l_add_style_ee = 'NL' THEN

					    l_return_value1 := pay_nl_general.get_emp_address(l_person_id
											     ,fnd_date.canonical_to_date(p_year)
											     ,l_house_number_ee
											     ,l_house_add_no_ee
											     ,l_street_name_ee
											     ,l_line1_ee
											     ,l_line2_ee
											     ,l_line3_ee
											     ,l_city_ee
											     ,l_country_ee
											     ,l_po_code_ee
											     );

				END IF;


				IF l_street_name_ee is not NULL THEN
					l_addr1_ee := l_street_name_ee;
				END IF;

				IF l_house_number_ee is not NULL THEN
					IF l_addr1_ee is not NULL THEN
						l_addr1_ee := l_addr1_ee||' '||l_house_number_ee;
					ELSE
						l_addr1_ee := l_house_number_ee;
					END IF;
				END IF;

				IF l_house_add_no_ee is not NULL THEN
					IF l_addr1_ee is not NULL THEN
						l_addr1_ee := l_addr1_ee||' '||l_house_add_no_ee;
					ELSE
						l_addr1_ee := l_house_add_no_ee;
					END IF;
				END IF;


				IF l_po_code_ee is not NULL THEN
					l_addr2_ee := l_po_code_ee;
				END IF;

				IF l_city_ee is not NULL THEN
					IF l_addr2_ee is not NULL THEN
						l_addr2_ee := l_addr2_ee||' '||l_city_ee;
					ELSE
						l_addr2_ee := l_city_ee;
					END IF;
				END IF;



				/*if l_street_name_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_house_number_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_house_add_no_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr1_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line1_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line2_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line3_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				/*if l_po_code_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_city_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr2_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_country_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;



				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Tax_Registration_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||nvl(l_leg_tax_ref,info_rec.Tax_Registration_Number)||']]>';
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Number;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Assignment_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.assignment_Number;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'SOFI_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.SOFI_Number;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date_Of_Birth';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Date_Of_Birth;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Period_Of_Service';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_period_of_service;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Table';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Wage_Tax_Table;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount1';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd1;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date1';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date1;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount2';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd2;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date2';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date2;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount3';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd3;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date3';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date3;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Insured_for_WAO';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Insured_for_WAO;
				vCtr := vCtr + 1;

				/*PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Insured_for_ZFW';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Insured_for_ZFW;
				vCtr := vCtr + 1;*/

				/*PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Company_Car';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Company_Car;
				vCtr := vCtr + 1;*/

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Code_Reason_No';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := hr_general.decode_lookup('NL_COMPANY_CAR_USAGE_CODE',info_rec.Company_Car);
				vCtr := vCtr + 1;

			end if;


		else

			l_date1:=info_rec.Date1;
			l_date2:=info_rec.Date2;
			l_date3:=info_rec.Date3;
			l_wtd1:=info_rec.Wage_Tax_Discount1;
			l_wtd2:=info_rec.Wage_Tax_Discount2;
			l_wtd3:=info_rec.Wage_Tax_Discount3;
			l_field_count:=1;

			if l_date1 like '%00/%' then
				l_date1:=null;
				l_wtd1:=null;
			end if;

			if l_date2 like '%00/%' then
				l_date2:=null;
				l_wtd2:=null;
			end if;

			if l_date3 like '%00/%' then
				l_date3:=null;
				l_wtd3:=null;
			end if;

			fnd_message.set_name('PAY','PAY_NL_ATS_YEAR');
			fnd_message.set_token('YEAR',l_year);
			l_year_msg:=fnd_message.get();

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Year_Detail';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_year_msg;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Name';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := nvl(l_Legal_Employer_Name,info_rec.Employer_Name);
			vCtr := vCtr + 1;


			/*if l_street_name_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_number_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_add_no_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_addr1_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line1_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;



			if l_line2_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_line3_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_addr2_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			/*if l_po_code_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_city_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_country_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;



			l_field_count:=1;


			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Name';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Name;
			vCtr := vCtr + 1;

			OPEN csr_emp_glb_address(l_person_id, fnd_date.canonical_to_date(p_year));
			FETCH	csr_emp_glb_address
			INTO	l_house_number_ee,
				l_house_add_no_ee,
				l_street_name_ee,
				l_line1_ee,
				l_line2_ee,
				l_line3_ee,
				l_po_code_ee,
				l_city_ee,
				l_country_ee,
				l_add_style_ee;
			CLOSE csr_emp_glb_address;

			IF l_add_style_ee = 'NL' THEN

			    l_return_value1 := pay_nl_general.get_emp_address(l_person_id
									     ,fnd_date.canonical_to_date(p_year)
									     ,l_house_number_ee
									     ,l_house_add_no_ee
									     ,l_street_name_ee
									     ,l_line1_ee
									     ,l_line2_ee
									     ,l_line3_ee
									     ,l_city_ee
									     ,l_country_ee
									     ,l_po_code_ee
									     );

			END IF;

			IF l_street_name_ee is not NULL THEN
				l_addr1_ee := l_street_name_ee;
			END IF;

			IF l_house_number_ee is not NULL THEN
				IF l_addr1_ee is not NULL THEN
					l_addr1_ee := l_addr1_ee||' '||l_house_number_ee;
				ELSE
					l_addr1_ee := l_house_number_ee;
				END IF;
			END IF;

			IF l_house_add_no_ee is not NULL THEN
				IF l_addr1_ee is not NULL THEN
					l_addr1_ee := l_addr1_ee||' '||l_house_add_no_ee;
				ELSE
					l_addr1_ee := l_house_add_no_ee;
				END IF;
			END IF;

			IF l_po_code_ee is not NULL THEN
				l_addr2_ee := l_po_code_ee;
			END IF;

			IF l_city_ee is not NULL THEN
				IF l_addr2_ee is not NULL THEN
					l_addr2_ee := l_addr2_ee||' '||l_city_ee;
				ELSE
					l_addr2_ee := l_city_ee;
				END IF;
			END IF;



			/*if l_street_name_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_number_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_add_no_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_addr1_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line1_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line2_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line3_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			/*if l_po_code_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_city_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_addr2_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_country_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;



			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Tax_Registration_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||nvl(l_leg_tax_ref,info_rec.Tax_Registration_Number)||']]>';
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Number;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Assignment_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.assignment_Number;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'SOFI_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.SOFI_Number;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date_Of_Birth';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Date_Of_Birth;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Period_Of_Service';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_period_of_service;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Table';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Wage_Tax_Table;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount1';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd1;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date1';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date1;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount2';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd2;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date2';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date2;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount3';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd3;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date3';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date3;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Taxable_Income';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Taxable_Income;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Deducted_Wage_Tax';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Deducted_Wage_Tax;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Labour_Tax_Reduction';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Labour_Tax_Reduction;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Insured_for_WAO';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Insured_for_WAO;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_for_ZVW';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.ZVW_Basis;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ZVW_Cont';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.ZVW_Cont;
			vCtr := vCtr + 1;

			/*PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Company_Car';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Company_Car;
			vCtr := vCtr + 1;*/

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Private_Use_Car';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Private_Use_Car;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Code_Reason_No';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := hr_general.decode_lookup('NL_COMPANY_CAR_USAGE_CODE',info_rec.Company_Car);
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Value_Private_Use_Car';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Value_Private_Use_Car;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Net_Expense_Allowance';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Net_Expense_Allowance;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Saved_Amount_LSS';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Saved_Amount_LSS;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Child_Care';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employer_Child_Care;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Allowance_on_Disability';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Allowance_on_Disability;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Applied_LCLD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Applied_LCLD;
			vCtr := vCtr + 1;

			hr_utility.set_location('Calling bal table',10);

			populate_UserBalVal(info_rec.User_Bal_String,'N');

			--hr_utility.set_location('FIRST-'||vUserBalVal.FIRST||' LAST-'||vUserBalVal.LAST||' COUNT-'||vUserBalVal.COUNT,20);

			IF vUserBalVal.COUNT > 0 THEN

				FOR lCtr IN vUserBalVal.FIRST .. vUserBalVal.LAST LOOP

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := vUserBalVal(lCtr).TagName;
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := vUserBalVal(lCtr).BalValue;
					vCtr := vCtr + 1;

				END LOOP;

			END IF;

			vUserBalVal.DELETE;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
			vCtr := vCtr + 1;

		end if;


		if l_previous_person_id <> l_person_id OR l_prev_period_of_service <> l_period_of_service then
			l_previous_person_id:=l_person_id;
			l_prev_period_of_service:=l_period_of_service;
		end if;

		l_house_number_ee := NULL;
		l_house_add_no_ee := NULL;
		l_street_name_ee := NULL;
		l_line1_ee := NULL;
		l_line2_ee := NULL;
		l_line3_ee := NULL;
		l_city_ee := NULL;
		l_country_ee := NULL;
		l_po_code_ee := NULL;
		l_addr1_ee := NULL;
		l_addr2_ee := NULL;


	end loop;

	if l_previous_person_id <> -1 and p_agg_flag = 'Y' then

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Taxable_Income';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Taxable_Income;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Deducted_Wage_Tax';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Deducted_Wage_Tax;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Labour_Tax_Reduction';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Labour_Tax_Reduction;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_for_ZVW';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW_Basis;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ZVW_Cont';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Private_Use_Car';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Private_Use_Car;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Net_Expense_Allowance';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Net_Expense_Allowance;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Value_Private_Use_Car';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Value_Private_Use_Car;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Saved_Amount_LSS';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Saved_Amount_LSS;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Child_Care';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employer_Child_Care;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Allowance_on_Disability';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Allowance_on_Disability;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Applied_LCLD';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Applied_LCLD;
		vCtr := vCtr + 1;

		IF vUserBalVal.COUNT > 0 THEN

			FOR lCtr IN vUserBalVal.FIRST .. vUserBalVal.LAST LOOP

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := vUserBalVal(lCtr).TagName;
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := vUserBalVal(lCtr).BalValue;
				vCtr := vCtr + 1;

				--hr_utility.set_location('tag name-'||vUserBalVal(lCtr).TagName||' tag value-'||vUserBalVal(lCtr).BalValue,90);

			END LOOP;

		END IF;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		vCtr := vCtr + 1;

		l_taxable_income:=0;
		l_deducted_wage_tax:=0;
		l_labour_tax_reduction:=0;
		l_ZVW:=0;
		l_ZVW_Basis:=0;
		l_Private_Use_Car:=0;
		l_Net_Expense_Allowance:=0;
		l_Value_Private_Use_Car:=0;
		l_Saved_Amount_LSS:=0;
		l_Employer_Child_Care:=0;
		l_Allowance_on_Disability:=0;
		l_Applied_LCLD:=0;
		vUserBalVal.DELETE;

	end if;

/*Fetch XML file as a BLOB*/

 pay_nl_xdo_Report.WritetoCLOB_rtf (p_xfdf_blob );


 pay_nl_xdo_Report.WritetoXML_rtf (fnd_global.conc_request_id,l_output_fname);

end populate_ats_report_data;

procedure populate_ats_report_data_new
		(p_person_id IN NUMBER,
		 p_year      IN VARCHAR2,
		 p_bg_id     IN NUMBER,
		 p_employer_id IN NUMBER,
		 p_agg_flag IN VARCHAR2,
		 p_aggregate_multi_assign IN VARCHAR2,
		 p_employee_name IN VARCHAR2,
		 p_top_hr_organization_name IN VARCHAR2,
		 p_eff_date IN VARCHAR2,
		 p_template_format IN VARCHAR2,
		 p_template_name IN VARCHAR2,
	       p_xml OUT NOCOPY CLOB) IS

/*Cursor to pick up necessary details*/

	cursor get_infos(lp_tax_year_end_date date,lp_tax_year_start_date date,lp_yes varchar2,lp_no varchar2,lp_archive_action number) is
	select  /*+ ORDERED */ pap.full_name Employee_name,
		hou.name Employer_name,
	 	hoi.org_information4 Tax_registration_number,
	 	pap.person_id Person_Id,
		paa.assignment_id Assignment_Id,
	 	pap.employee_number,
	 	paa.assignment_number,
	 	to_char(pap.Date_Of_Birth,'DD/MM/YYYY') Date_Of_Birth,
		ppos.date_start Date_Start,
		nvl(ppos.actual_termination_date,lp_tax_year_end_date) Date_End,
		to_char(greatest(ppos.date_start,lp_tax_year_start_date),'DD/MM/YYYY')||' - '||to_char(least(nvl(ppos.actual_termination_date,lp_tax_year_end_date),lp_tax_year_end_date),'DD/MM/YYYY') Period_Of_Service,
	 	pap.national_identifier SOFI_number,
	 	DECODE(SUBSTR(pai.action_information10,2,1),1,hr_general.decode_lookup('NL_TAX_TABLE','1'),2,hr_general.decode_lookup('NL_TAX_TABLE','2'),'') Wage_Tax_Table,
	 	decode(substr(pai.action_information9,1,1),'1',lp_yes,lp_no) Wage_Tax_Discount1,
	 	'(' || substr(pai.action_information9,2,2)||'/'||substr(pai.action_information9,4,2)||'/'||to_char(lp_tax_year_end_date,'YYYY') || ')' Date1,
	 	decode(substr(pai.action_information9,6,1),'1',lp_yes,lp_no) Wage_Tax_Discount2,
	 	'(' || substr(pai.action_information9,7,2)||'/'||substr(pai.action_information9,9,2)||'/'||to_char(lp_tax_year_end_date,'YYYY') || ')' Date2,
	 	decode(substr(pai.action_information9,11,1),'1',lp_yes,lp_no) Wage_Tax_Discount3,
	 	'(' || substr(pai.action_information9,12,2)||'/'||substr(pai.action_information9,14,2)||'/'||to_char(lp_tax_year_end_date,'YYYY') || ')' Date3,
	 	NVL(pai.action_information18,pai.action_information4) Taxable_Income,
	 	pai.action_Information5 Deducted_Wage_Tax,
	 	pai.action_information8 Labour_Tax_Reduction,
	 	decode(substr(pai.action_information14,1,1),'1',lp_yes,2,lp_yes,3,lp_yes,lp_no) Insured_For_WAO,
	 	--decode(substr(pai.action_information14,2,1),'1',lp_yes,2,lp_yes,3,lp_yes,lp_no) Insured_For_ZFW,
	 	pai.action_information15  ZVW_Cont,
		substr(pai.action_information12,13,1) Company_Car,
	 	pai.action_information17  Private_Use_Car,
	 	pai.action_information16  Net_Expense_Allowance,
		pai.action_information19  ZVW_Basis,
		pai.action_information20  Value_Private_Use_Car,
		pai.action_information21  Saved_Amount_LSS,
		pai.action_information22  Employer_Child_Care,
		pai.action_information23  Allowance_on_Disability,
		pai.action_information24  Applied_LCLD,
		pai.action_information25  User_Bal_String
	 from
                pay_assignment_actions assact,
                pay_action_information pai,
                per_all_assignments_f paa,
                per_all_people_f pap,
                per_periods_of_service ppos,
                hr_organization_units hou,
                hr_organization_information hoi
	 where
 	 	pai.action_context_type = 'AAP'
		and assact.payroll_action_id = lp_archive_action
		and pai.action_context_id = assact.assignment_action_id
 	 	and pai.action_information_category = 'NL ATS EMPLOYEE DETAILS'
	        and hoi.org_information_context = 'NL_ORG_INFORMATION'
	 	and pap.person_id = nvl(p_person_id,pap.person_id)
		and ppos.person_id = pap.person_id
		and ppos.date_start <= lp_Tax_Year_End_Date
		--and nvl(ppos.actual_termination_date, lp_Tax_Year_End_Date) >= lp_Tax_Year_Start_Date
	 	and pai.action_information1 = to_char(p_employer_id)
	 	and decode(pai.action_information_category,'NL ATS EMPLOYEE DETAILS',fnd_number.canonical_to_number(pai.action_information2),null) = nvl(p_person_id,pap.person_id)
	 	and decode(pai.action_information_category,'NL ATS EMPLOYEE DETAILS',fnd_number.canonical_to_number(pai.action_information3),null) = paa.assignment_id
	 	and pai.effective_date = lp_Tax_Year_End_Date
	and 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM	per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   asg.payroll_id is not NULL
		and   asg.effective_start_date <= least(nvl(ppos.actual_termination_date, lp_Tax_Year_End_Date), lp_Tax_Year_End_Date)
		and   nvl(asg.effective_end_date, lp_Tax_Year_End_Date) >= ppos.date_start

		)
	 	and lp_Tax_Year_End_Date between pap.effective_start_date and pap.effective_end_date
	 	and lp_Tax_Year_End_Date between hou.date_from and nvl(hou.date_to,hr_general.end_of_time)
	 	and paa.person_id = pap.person_id
	 	and pap.business_group_id = p_bg_id
	 	and paa.business_group_id = p_bg_id
	        and hou.organization_id = p_employer_id
	        and hoi.organization_id = p_employer_id
 	 	order by get_Address_Style(pap.person_id,lp_tax_year_end_date) desc, get_Post_Code(pap.person_id,lp_tax_year_end_date) asc, pap.person_id asc, paa.assignment_id asc;

/*	CURSOR csr_org_hierarchy_name(lp_business_group_id number,lp_tax_year_end_date date) IS
	select
	pos.name
	from
	per_organization_structures pos,
	per_org_structure_versions posv
	where pos.organization_structure_id = posv.organization_structure_id
	and to_char(pos.organization_structure_id) IN (select org_information1
	from hr_organization_information hoi where hoi.org_information_context='NL_BG_INFO'
	and hoi.organization_id=lp_business_group_id)
	and lp_tax_year_end_date between posv.date_from and nvl(posv.date_to,hr_general.End_of_time);*/

	CURSOR csr_get_org_name(lp_org_id number) IS
	select name
	from hr_organization_units
	where organization_id = lp_org_id;

	CURSOR csr_get_person_name(lp_person_id number,lp_effective_date date) IS
	select full_name from per_all_people_f
	where person_id = lp_person_id
	and lp_effective_date between effective_start_date and effective_end_date;

	CURSOR csr_org_glb_address(p_bg_id NUMBER, p_org_id NUMBER) IS
	select	hlc.loc_information14					house_number,
		hlc.loc_information15					house_no_add,
		hr_general.decode_lookup('NL_REGION',hlc.region_1)	street_name,
		hlc.address_line_1					address_line1,
		hlc.address_line_2					address_line2,
		hlc.address_line_3					address_line3,
		hlc.postal_code						postcode,
		hlc.town_or_city					city,
		pay_nl_general.get_country_name(hlc.country)		country,
		hlc.style						add_style
	from	hr_locations						hlc,
		hr_organization_units					hou
	where	hou.business_group_id = p_bg_id
	and	hou.organization_id = p_org_id
	and	hlc.location_id = hou.location_id;

	CURSOR csr_emp_glb_address(p_person_id NUMBER, p_effective_date DATE) IS
	select	pad.add_information13					house_number,
		pad.add_information14					house_no_add,
		hr_general.decode_lookup('NL_REGION',pad.region_1)	street_name,
		pad.address_line1					address_line1,
		pad.address_line2					address_line2,
		pad.address_line3					address_line3,
		pad.postal_code						postcode,
		pad.town_or_city					city,
		pay_nl_general.get_country_name(pad.country)		country,
		pad.style						add_style
	from	per_addresses						pad
	where	pad.person_id = p_person_id
	and	p_effective_date between pad.date_from and nvl(pad.date_to,hr_general.end_of_time)
	and	pad.primary_flag = 'Y';

	CURSOR	csr_get_leg_employer(p_assignment_id NUMBER, p_tax_year_start_date DATE, p_tax_year_end_date DATE) IS
	select	hou.organization_id leg_emp_id,
		hoi.org_information1 leg_tax_ref
	from	hr_organization_units hou,
		hr_organization_information hoi,
		hr_organization_information hoi1,
		per_all_assignments_f paa
	where	paa.assignment_id = p_assignment_id
	and	hou.organization_id = nvl(paa.establishment_id,-1)
	and	hoi.organization_id = hou.organization_id
	and	hoi1.organization_id = hou.organization_id
	and	hoi1.org_information_context = 'CLASS'
	and	hoi1.org_information1 = 'HR_LEGAL_EMPLOYER'
	and	hoi1.org_information2 = 'Y'
	and	hoi.org_information_context = 'NL_LE_TAX_DETAILS'
	and	hoi.org_information1 IS NOT NULL
	and	hoi.org_information2 IS NOT NULL
	and 	paa.effective_start_date =
		(
		SELECT MIN(asg.effective_start_date)
		FROM per_all_assignments_f asg
		WHERE asg.assignment_id = paa.assignment_id
		and   asg.effective_start_date <= p_tax_year_end_date
		and   nvl(asg.effective_end_date, p_tax_year_end_date) >= p_tax_year_start_date

		);


	l_output_fname varchar2(1000);
	l_return_value number;
	l_effective_date date;
	l_tax_year_start_date date;
	l_employee varchar2(255);
	l_Employer_Name varchar2(255);
	l_Legal_Employer_Name varchar2(255);
	l_business_group_name varchar2(240);
--	l_Organization_Hierarchy_Name varchar2(255);
	l_addr1_er varchar2(500) := null;
	l_addr1_ee varchar2(500) := null;
	l_addr2_er varchar2(500) := null;
	l_addr2_ee varchar2(500) := null;
	l_house_number_er varchar2(255);
	l_house_add_no_er varchar2(255);
	l_street_name_er varchar2(255);
	l_line1_er varchar2(255);
	l_line2_er varchar2(255);
	l_line3_er varchar2(255);
	l_city_er varchar2(255);
	l_country_er varchar2(255);
	l_po_code_er varchar2(255);
	l_add_style_er varchar2(255);
	l_add_style_ee varchar2(255);
	l_return_value1 number;
	l_house_number_ee varchar2(255);
	l_house_add_no_ee varchar2(255);
	l_street_name_ee varchar2(255);
	l_line1_ee varchar2(255);
	l_line2_ee varchar2(255);
	l_line3_ee varchar2(255);
	l_city_ee varchar2(255);
	l_country_ee varchar2(255);
	l_po_code_ee varchar2(255);
	l_person_id number;
	l_previous_person_id number;
	l_date1 varchar2(20);
	l_date2 varchar2(20);
	l_date3 varchar2(20);
	l_wtd1 varchar2(20);
	l_wtd2 varchar2(20);
	l_wtd3 varchar2(20);
	l_year varchar2(20);
	l_year_msg varchar2(255);
	l_field_count number;
	l_yes varchar2(20);
	l_no varchar2(20);
	l_taxable_income number;
	l_deducted_wage_tax number;
	l_labour_tax_reduction number;
	l_ZVW number;
	l_ZVW_Basis number;
	l_Private_Use_Car number;
	l_Net_Expense_Allowance number;
	l_Value_Private_Use_Car number;
	l_Saved_Amount_LSS number;
	l_Employer_Child_Care number;
	l_Allowance_on_Disability number;
	l_Applied_LCLD number;
	l_agg_flag varchar2(20);
	l_leg_emp_id number := null;
	l_leg_tax_ref varchar2(100) := null;
	l_period_of_service varchar2(100) := null;
	l_prev_period_of_service varchar2(100) := null;
	l_archive_action number;
	lCtr number;



/*Make calls to suppoting procedures to form the XML file*/

begin

	--hr_utility.trace_on(NULL,'ATS_TAB');
	--hr_utility.set_location('inside ATS',10);
	l_archive_action:=0;
	l_taxable_income:=0;
	l_deducted_wage_tax:=0;
	l_labour_tax_reduction:=0;
	l_ZVW:=0;
	l_ZVW_Basis:=0;
	l_Private_Use_Car:=0;
	l_Net_Expense_Allowance:=0;
	l_Value_Private_Use_Car:=0;
	l_Saved_Amount_LSS:=0;
	l_Employer_Child_Care:=0;
	l_Allowance_on_Disability:=0;
	l_Applied_LCLD:=0;
	vUserBalVal.DELETE;
	l_previous_person_id:=-1;

	l_effective_date := fnd_date.canonical_to_date(p_year);
	l_year := to_char(l_effective_date,'YYYY');
	l_tax_year_start_date := to_date('01-01-'||l_year,'DD-MM-YYYY');
	l_yes :=hr_general.decode_lookup('HR_NL_YES_NO','Y');
	l_no :=hr_general.decode_lookup('HR_NL_YES_NO','N');

	PAY_NL_TAXOFFICE_ARCHIVE.populate_UserBal(p_bg_id,l_effective_date);
	hr_utility.set_location('Table populated, count-'||PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.COUNT,10);

	if p_agg_flag = 'Y' THEN
		l_agg_flag := hr_general.decode_lookup('HR_NL_YES_NO','Y');
	else
		l_agg_flag := hr_general.decode_lookup('HR_NL_YES_NO','N');
	end if;

	BEGIN

		select	max(ppa.payroll_action_id)
		into	l_archive_action
		from	pay_payroll_actions ppa
		where	ppa.report_qualifier='NL'
		and	ppa.business_group_id=p_bg_id
		and	ppa.report_type='NL_TAXOFFICE_ARCHIVE'
		and	ppa.report_category='ARCHIVE'
		and	pay_nl_taxoffice_archive.get_parameter(ppa.legislative_parameters,'EMPLOYER_ID')=to_char(p_employer_id)
		and	effective_date between l_tax_year_start_date and l_effective_date;

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN l_archive_action := 0;

		WHEN OTHERS
			THEN l_archive_action := 0;

	END;

	OPEN csr_get_org_name(p_bg_id);
	FETCH csr_get_org_name into l_business_group_name;
	CLOSE csr_get_org_name;


	OPEN csr_get_org_name(p_employer_id);
	FETCH csr_get_org_name into l_Employer_Name;
	CLOSE csr_get_org_name;

	/*OPEN csr_org_glb_address(p_bg_id, p_employer_id);
	FETCH	csr_org_glb_address
	INTO	l_house_number_er,
		l_house_add_no_er,
		l_street_name_er,
		l_line1_er,
		l_line2_er,
		l_line3_er,
		l_po_code_er,
		l_city_er,
		l_country_er,
		l_add_style_er;
	CLOSE csr_org_glb_address;

	IF l_add_style_er = 'NL' THEN

		l_return_value := pay_nl_general.get_org_address(p_employer_id
									 ,p_bg_id
									 ,l_house_number_er
									 ,l_house_add_no_er
									 ,l_street_name_er
									 ,l_line1_er
									 ,l_line2_er
									 ,l_line3_er
									 ,l_city_er
									 ,l_country_er
									 ,l_po_code_er);

	END IF;

	IF l_street_name_er is not NULL THEN
		l_addr1_er := l_street_name_er;
	END IF;

	IF l_house_number_er is not NULL THEN
		IF l_addr1_er is not NULL THEN
			l_addr1_er := l_addr1_er||', '||l_house_number_er;
		ELSE
			l_addr1_er := l_house_number_er;
		END IF;
	END IF;

	IF l_house_add_no_er is not NULL THEN
		IF l_addr1_er is not NULL THEN
			l_addr1_er := l_addr1_er||', '||l_house_add_no_er;
		ELSE
			l_addr1_er := l_house_add_no_er;
		END IF;
	END IF;


	IF l_po_code_er is not NULL THEN
		l_addr2_er := l_po_code_er;
	END IF;

	IF l_city_er is not NULL THEN
		IF l_addr2_er is not NULL THEN
			l_addr2_er := l_addr2_er||', '||l_city_er;
		ELSE
			l_addr2_er := l_city_er;
		END IF;
	END IF;*/


	if p_person_id is not null then
		OPEN csr_get_person_name(p_person_id,l_effective_date);
		FETCH csr_get_person_name into l_employee;
		CLOSE csr_get_person_name;
	end if;


/*	OPEN csr_org_hierarchy_name(p_bg_id,l_effective_date);
	FETCH csr_org_hierarchy_name INTO l_Organization_Hierarchy_Name;
	CLOSE csr_org_hierarchy_name;*/

 	PAY_NL_XDO_REPORT.vXMLTable.DELETE;
 	vCtr := 0;

/*Get all the XML tags and values*/

 	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_effective_date,'DD/MM/YYYY');
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Year_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := to_char(l_effective_date,'YYYY');
	vCtr := vCtr + 1;
--	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Org_Hierarchy_Header';
--	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Organization_Hierarchy_Name;
--	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employer_Name;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employee;
	vCtr := vCtr + 1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Business_Group_Header';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_business_group_name;
	vCtr := vCtr+1;
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Aggregate_Flag';
	PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_agg_flag;
	vCtr := vCtr+1;

	for info_rec in get_infos(l_effective_date,l_tax_year_start_date,l_yes,l_no,l_archive_action)
	LOOP
		l_person_id:=info_rec.Person_Id;
		IF info_rec.Date_End > l_tax_year_start_date THEN
			l_period_of_service := info_rec.period_of_service;
		ELSE
			l_period_of_service := to_char(info_rec.date_start,'DD/MM/YYYY')||' - '||to_char(info_rec.date_end,'DD/MM/YYYY');
		END IF;

		OPEN csr_get_leg_employer(info_rec.Assignment_Id, l_tax_year_start_date, l_effective_date);
		FETCH csr_get_leg_employer INTO l_leg_emp_id, l_leg_tax_ref;
		IF csr_get_leg_employer%NOTFOUND THEN
			l_leg_emp_id := null;
			l_leg_tax_ref := null;
			l_Legal_Employer_Name := null;
		END IF;
		CLOSE csr_get_leg_employer;

		IF l_leg_emp_id is not NULL and l_leg_tax_ref is not NULL THEN

			OPEN csr_get_org_name(l_leg_emp_id);
			FETCH csr_get_org_name into l_Legal_Employer_Name;
			CLOSE csr_get_org_name;

			OPEN csr_org_glb_address(p_bg_id, l_leg_emp_id);
			FETCH	csr_org_glb_address
			INTO	l_house_number_er,
				l_house_add_no_er,
				l_street_name_er,
				l_line1_er,
				l_line2_er,
				l_line3_er,
				l_po_code_er,
				l_city_er,
				l_country_er,
				l_add_style_er;
			CLOSE csr_org_glb_address;

			IF l_add_style_er = 'NL' THEN

				l_return_value := pay_nl_general.get_org_address(l_leg_emp_id
											 ,p_bg_id
											 ,l_house_number_er
											 ,l_house_add_no_er
											 ,l_street_name_er
											 ,l_line1_er
											 ,l_line2_er
											 ,l_line3_er
											 ,l_city_er
											 ,l_country_er
											 ,l_po_code_er);

			END IF;

			IF l_street_name_er is not NULL THEN
				l_addr1_er := l_street_name_er;
			END IF;

			IF l_house_number_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_number_er;
				ELSE
					l_addr1_er := l_house_number_er;
				END IF;
			END IF;

			IF l_house_add_no_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_add_no_er;
				ELSE
					l_addr1_er := l_house_add_no_er;
				END IF;
			END IF;


			IF l_po_code_er is not NULL THEN
				l_addr2_er := l_po_code_er;
			END IF;

			IF l_city_er is not NULL THEN
				IF l_addr2_er is not NULL THEN
					l_addr2_er := l_addr2_er||' '||l_city_er;
				ELSE
					l_addr2_er := l_city_er;
				END IF;
			END IF;

		ELSE

			/*OPEN csr_get_org_name(p_employer_id);
			FETCH csr_get_org_name into l_Legal_Employer_Name;
			CLOSE csr_get_org_name;*/

			OPEN csr_org_glb_address(p_bg_id, p_employer_id);
			FETCH	csr_org_glb_address
			INTO	l_house_number_er,
				l_house_add_no_er,
				l_street_name_er,
				l_line1_er,
				l_line2_er,
				l_line3_er,
				l_po_code_er,
				l_city_er,
				l_country_er,
				l_add_style_er;
			CLOSE csr_org_glb_address;

			IF l_add_style_er = 'NL' THEN

				l_return_value := pay_nl_general.get_org_address(p_employer_id
											 ,p_bg_id
											 ,l_house_number_er
											 ,l_house_add_no_er
											 ,l_street_name_er
											 ,l_line1_er
											 ,l_line2_er
											 ,l_line3_er
											 ,l_city_er
											 ,l_country_er
											 ,l_po_code_er);

			END IF;

			IF l_street_name_er is not NULL THEN
				l_addr1_er := l_street_name_er;
			END IF;

			IF l_house_number_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_number_er;
				ELSE
					l_addr1_er := l_house_number_er;
				END IF;
			END IF;

			IF l_house_add_no_er is not NULL THEN
				IF l_addr1_er is not NULL THEN
					l_addr1_er := l_addr1_er||' '||l_house_add_no_er;
				ELSE
					l_addr1_er := l_house_add_no_er;
				END IF;
			END IF;


			IF l_po_code_er is not NULL THEN
				l_addr2_er := l_po_code_er;
			END IF;

			IF l_city_er is not NULL THEN
				IF l_addr2_er is not NULL THEN
					l_addr2_er := l_addr2_er||' '||l_city_er;
				ELSE
					l_addr2_er := l_city_er;
				END IF;
			END IF;


		END IF;

		if p_agg_flag = 'Y' then

			if  l_person_id = l_previous_person_id AND l_period_of_service = l_prev_period_of_service then

				l_taxable_income:=fnd_number.canonical_to_number(info_rec.taxable_income) + l_taxable_income;
				l_deducted_wage_tax:=fnd_number.canonical_to_number(info_rec.deducted_wage_tax) + l_deducted_wage_tax;
				l_labour_tax_reduction:=fnd_number.canonical_to_number(info_rec.labour_tax_reduction) + l_labour_tax_reduction;
				l_ZVW:=fnd_number.canonical_to_number(info_rec.ZVW_Cont) + l_ZVW;
				l_ZVW_Basis:=fnd_number.canonical_to_number(info_rec.ZVW_Basis) + l_ZVW_Basis;
				l_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Private_Use_Car) + l_Private_Use_Car;
				l_Net_Expense_Allowance:=fnd_number.canonical_to_number(info_rec.Net_Expense_Allowance) + l_Net_Expense_Allowance;
				l_Value_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Value_Private_Use_Car) + l_Value_Private_Use_Car;
				l_Saved_Amount_LSS:=fnd_number.canonical_to_number(info_rec.Saved_Amount_LSS) + l_Saved_Amount_LSS;
				l_Employer_Child_Care:=fnd_number.canonical_to_number(info_rec.Employer_Child_Care) + l_Employer_Child_Care;
				l_Allowance_on_Disability:=fnd_number.canonical_to_number(info_rec.Allowance_on_Disability) + l_Allowance_on_Disability;
				l_Applied_LCLD:=fnd_number.canonical_to_number(info_rec.Applied_LCLD) + l_Applied_LCLD;
				populate_UserBalVal(info_rec.User_Bal_String,'Y');

			end if;


			if  l_person_id <> l_previous_person_id OR l_period_of_service <> l_prev_period_of_service then

				if l_previous_person_id <> -1 then

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Taxable_Income';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Taxable_Income;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Deducted_Wage_Tax';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Deducted_Wage_Tax;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Labour_Tax_Reduction';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Labour_Tax_Reduction;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_for_ZVW';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW_Basis;
					vCtr := vCtr + 1;

					/*hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagName,100);
					hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagValue,110);*/

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ZVW_Cont';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW;
					vCtr := vCtr + 1;

					/*hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagName,100);
					hr_utility.set_location('Tag name: '||PAY_NL_XDO_REPORT.vXMLTable(vCtr-1).TagValue,110);*/


					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Private_Use_Car';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Private_Use_Car;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Net_Expense_Allowance';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Net_Expense_Allowance;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Value_Private_Use_Car';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Value_Private_Use_Car;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Saved_Amount_LSS';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Saved_Amount_LSS;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Child_Care';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employer_Child_Care;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Allowance_on_Disability';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Allowance_on_Disability;
					vCtr := vCtr + 1;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Applied_LCLD';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Applied_LCLD;
					vCtr := vCtr + 1;

					IF vUserBalVal.COUNT > 0 THEN

						FOR lCtr IN vUserBalVal.FIRST .. vUserBalVal.LAST LOOP

							PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := vUserBalVal(lCtr).TagName;
							PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := vUserBalVal(lCtr).BalValue;
							vCtr := vCtr + 1;

						END LOOP;

					END IF;

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
					vCtr := vCtr + 1;

					l_taxable_income:=0;
					l_deducted_wage_tax:=0;
					l_labour_tax_reduction:=0;
					l_ZVW:=0;
					l_ZVW_Basis:=0;
					l_Private_Use_Car:=0;
					l_Net_Expense_Allowance:=0;
					l_Value_Private_Use_Car:=0;
					l_Saved_Amount_LSS:=0;
					l_Employer_Child_Care:=0;
					l_Allowance_on_Disability:=0;
					l_Applied_LCLD:=0;
					vUserBalVal.DELETE;

				end if;

				l_taxable_income:=fnd_number.canonical_to_number(info_rec.taxable_income);
				l_deducted_wage_tax:=fnd_number.canonical_to_number(info_rec.deducted_wage_tax);
				l_labour_tax_reduction:=fnd_number.canonical_to_number(info_rec.labour_tax_reduction);
				l_ZVW:=fnd_number.canonical_to_number(info_rec.ZVW_Cont);
				l_ZVW_Basis:=fnd_number.canonical_to_number(info_rec.ZVW_Basis);
				l_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Private_Use_Car);
				l_Net_Expense_Allowance:=fnd_number.canonical_to_number(info_rec.Net_Expense_Allowance);
				l_Value_Private_Use_Car:=fnd_number.canonical_to_number(info_rec.Value_Private_Use_Car);
				l_Saved_Amount_LSS:=fnd_number.canonical_to_number(info_rec.Saved_Amount_LSS);
				l_Employer_Child_Care:=fnd_number.canonical_to_number(info_rec.Employer_Child_Care);
				l_Allowance_on_Disability:=fnd_number.canonical_to_number(info_rec.Allowance_on_Disability);
				l_Applied_LCLD:=fnd_number.canonical_to_number(info_rec.Applied_LCLD);
				populate_UserBalVal(info_rec.User_Bal_String,'N');



				l_date1:=info_rec.Date1;
				l_date2:=info_rec.Date2;
				l_date3:=info_rec.Date3;
				l_wtd1:=info_rec.Wage_Tax_Discount1;
				l_wtd2:=info_rec.Wage_Tax_Discount2;
				l_wtd3:=info_rec.Wage_Tax_Discount3;
				l_field_count:=1;

				if l_date1 like '%00/%' then
					l_date1:=null;
					l_wtd1:=null;
				end if;

				if l_date2 like '%00/%' then
					l_date2:=null;
					l_wtd2:=null;
				end if;

				if l_date3 like '%00/%' then
					l_date3:=null;
					l_wtd3:=null;
				end if;

				fnd_message.set_name('PAY','PAY_NL_ATS_YEAR');
				fnd_message.set_token('YEAR',l_year);
				l_year_msg:=fnd_message.get();

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Year_Detail';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_year_msg;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Name';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := nvl(l_Legal_Employer_Name,info_rec.Employer_Name);
				vCtr := vCtr + 1;


				/*if l_street_name_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_house_number_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_house_add_no_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr1_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line1_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line2_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_line3_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				/*if l_po_code_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_city_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr2_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_country_er is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_er||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				l_field_count:=1;


				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Name';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Name;
				vCtr := vCtr + 1;

				OPEN csr_emp_glb_address(l_person_id, fnd_date.canonical_to_date(p_year));
				FETCH	csr_emp_glb_address
				INTO	l_house_number_ee,
					l_house_add_no_ee,
					l_street_name_ee,
					l_line1_ee,
					l_line2_ee,
					l_line3_ee,
					l_po_code_ee,
					l_city_ee,
					l_country_ee,
					l_add_style_ee;
				CLOSE csr_emp_glb_address;

				IF l_add_style_ee = 'NL' THEN

					    l_return_value1 := pay_nl_general.get_emp_address(l_person_id
											     ,fnd_date.canonical_to_date(p_year)
											     ,l_house_number_ee
											     ,l_house_add_no_ee
											     ,l_street_name_ee
											     ,l_line1_ee
											     ,l_line2_ee
											     ,l_line3_ee
											     ,l_city_ee
											     ,l_country_ee
											     ,l_po_code_ee
											     );

				END IF;


				IF l_street_name_ee is not NULL THEN
					l_addr1_ee := l_street_name_ee;
				END IF;

				IF l_house_number_ee is not NULL THEN
					IF l_addr1_ee is not NULL THEN
						l_addr1_ee := l_addr1_ee||' '||l_house_number_ee;
					ELSE
						l_addr1_ee := l_house_number_ee;
					END IF;
				END IF;

				IF l_house_add_no_ee is not NULL THEN
					IF l_addr1_ee is not NULL THEN
						l_addr1_ee := l_addr1_ee||' '||l_house_add_no_ee;
					ELSE
						l_addr1_ee := l_house_add_no_ee;
					END IF;
				END IF;


				IF l_po_code_ee is not NULL THEN
					l_addr2_ee := l_po_code_ee;
				END IF;

				IF l_city_ee is not NULL THEN
					IF l_addr2_ee is not NULL THEN
						l_addr2_ee := l_addr2_ee||' '||l_city_ee;
					ELSE
						l_addr2_ee := l_city_ee;
					END IF;
				END IF;



				/*if l_street_name_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_house_number_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;

				if l_house_add_no_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr1_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line1_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line2_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_line3_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				/*if l_po_code_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_city_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;*/


				if l_addr2_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;


				if l_country_ee is not null then
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_ee||']]>';
					l_field_count:=l_field_count+1;
					vCtr := vCtr + 1;
				end if;



				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Tax_Registration_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||nvl(l_leg_tax_ref,info_rec.Tax_Registration_Number)||']]>';
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Number;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Assignment_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.assignment_Number;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'SOFI_Number';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.SOFI_Number;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date_Of_Birth';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Date_Of_Birth;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Period_Of_Service';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_period_of_service;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Table';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Wage_Tax_Table;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount1';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd1;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date1';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date1;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount2';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd2;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date2';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date2;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount3';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd3;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date3';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date3;
				vCtr := vCtr + 1;

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Insured_for_WAO';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Insured_for_WAO;
				vCtr := vCtr + 1;

				/*PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Insured_for_ZFW';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Insured_for_ZFW;
				vCtr := vCtr + 1;*/

				/*PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Company_Car';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Company_Car;
				vCtr := vCtr + 1;*/

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Code_Reason_No';
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := hr_general.decode_lookup('NL_COMPANY_CAR_USAGE_CODE',info_rec.Company_Car);
				vCtr := vCtr + 1;

			end if;


		else

			l_date1:=info_rec.Date1;
			l_date2:=info_rec.Date2;
			l_date3:=info_rec.Date3;
			l_wtd1:=info_rec.Wage_Tax_Discount1;
			l_wtd2:=info_rec.Wage_Tax_Discount2;
			l_wtd3:=info_rec.Wage_Tax_Discount3;
			l_field_count:=1;

			if l_date1 like '%00/%' then
				l_date1:=null;
				l_wtd1:=null;
			end if;

			if l_date2 like '%00/%' then
				l_date2:=null;
				l_wtd2:=null;
			end if;

			if l_date3 like '%00/%' then
				l_date3:=null;
				l_wtd3:=null;
			end if;

			fnd_message.set_name('PAY','PAY_NL_ATS_YEAR');
			fnd_message.set_token('YEAR',l_year);
			l_year_msg:=fnd_message.get();

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := null;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Year_Detail';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_year_msg;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Name';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := nvl(l_Legal_Employer_Name,info_rec.Employer_Name);
			vCtr := vCtr + 1;


			/*if l_street_name_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_number_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_add_no_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_addr1_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line1_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;



			if l_line2_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_line3_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_addr2_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			/*if l_po_code_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_city_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_country_er is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ER_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_er||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;



			l_field_count:=1;


			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Name';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Name;
			vCtr := vCtr + 1;

			OPEN csr_emp_glb_address(l_person_id, fnd_date.canonical_to_date(p_year));
			FETCH	csr_emp_glb_address
			INTO	l_house_number_ee,
				l_house_add_no_ee,
				l_street_name_ee,
				l_line1_ee,
				l_line2_ee,
				l_line3_ee,
				l_po_code_ee,
				l_city_ee,
				l_country_ee,
				l_add_style_ee;
			CLOSE csr_emp_glb_address;

			IF l_add_style_ee = 'NL' THEN

			    l_return_value1 := pay_nl_general.get_emp_address(l_person_id
									     ,fnd_date.canonical_to_date(p_year)
									     ,l_house_number_ee
									     ,l_house_add_no_ee
									     ,l_street_name_ee
									     ,l_line1_ee
									     ,l_line2_ee
									     ,l_line3_ee
									     ,l_city_ee
									     ,l_country_ee
									     ,l_po_code_ee
									     );

			END IF;

			IF l_street_name_ee is not NULL THEN
				l_addr1_ee := l_street_name_ee;
			END IF;

			IF l_house_number_ee is not NULL THEN
				IF l_addr1_ee is not NULL THEN
					l_addr1_ee := l_addr1_ee||' '||l_house_number_ee;
				ELSE
					l_addr1_ee := l_house_number_ee;
				END IF;
			END IF;

			IF l_house_add_no_ee is not NULL THEN
				IF l_addr1_ee is not NULL THEN
					l_addr1_ee := l_addr1_ee||' '||l_house_add_no_ee;
				ELSE
					l_addr1_ee := l_house_add_no_ee;
				END IF;
			END IF;

			IF l_po_code_ee is not NULL THEN
				l_addr2_ee := l_po_code_ee;
			END IF;

			IF l_city_ee is not NULL THEN
				IF l_addr2_ee is not NULL THEN
					l_addr2_ee := l_addr2_ee||' '||l_city_ee;
				ELSE
					l_addr2_ee := l_city_ee;
				END IF;
			END IF;



			/*if l_street_name_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_street_name_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_number_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_number_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_house_add_no_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_house_add_no_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_addr1_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr1_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line1_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line1_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line2_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line2_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_line3_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_line3_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			/*if l_po_code_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_po_code_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;

			if l_city_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_city_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;*/


			if l_addr2_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_addr2_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;


			if l_country_ee is not null then
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'EE_Address_Line' || to_char(l_field_count);
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||l_country_ee||']]>';
				l_field_count:=l_field_count+1;
				vCtr := vCtr + 1;
			end if;



			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Tax_Registration_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := '<![CDATA['||nvl(l_leg_tax_ref,info_rec.Tax_Registration_Number)||']]>';
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employee_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employee_Number;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Assignment_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.assignment_Number;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'SOFI_Number';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.SOFI_Number;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date_Of_Birth';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Date_Of_Birth;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Period_Of_Service';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_period_of_service;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Table';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Wage_Tax_Table;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount1';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd1;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date1';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date1;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount2';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd2;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date2';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date2;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_Tax_Discount3';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_wtd3;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Date3';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_date3;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Taxable_Income';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Taxable_Income;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Deducted_Wage_Tax';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Deducted_Wage_Tax;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Labour_Tax_Reduction';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Labour_Tax_Reduction;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Insured_for_WAO';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Insured_for_WAO;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_for_ZVW';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.ZVW_Basis;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ZVW_Cont';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.ZVW_Cont;
			vCtr := vCtr + 1;

			/*PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Company_Car';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Company_Car;
			vCtr := vCtr + 1;*/

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Private_Use_Car';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Private_Use_Car;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Code_Reason_No';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := hr_general.decode_lookup('NL_COMPANY_CAR_USAGE_CODE',info_rec.Company_Car);
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Value_Private_Use_Car';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Value_Private_Use_Car;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Net_Expense_Allowance';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Net_Expense_Allowance;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Saved_Amount_LSS';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Saved_Amount_LSS;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Child_Care';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Employer_Child_Care;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Allowance_on_Disability';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Allowance_on_Disability;
			vCtr := vCtr + 1;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Applied_LCLD';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := info_rec.Applied_LCLD;
			vCtr := vCtr + 1;

			hr_utility.set_location('Calling bal table',10);

			populate_UserBalVal(info_rec.User_Bal_String,'N');

			--hr_utility.set_location('FIRST-'||vUserBalVal.FIRST||' LAST-'||vUserBalVal.LAST||' COUNT-'||vUserBalVal.COUNT,20);

			IF vUserBalVal.COUNT > 0 THEN

				FOR lCtr IN vUserBalVal.FIRST .. vUserBalVal.LAST LOOP

					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := vUserBalVal(lCtr).TagName;
					PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := vUserBalVal(lCtr).BalValue;
					vCtr := vCtr + 1;

				END LOOP;

			END IF;

			vUserBalVal.DELETE;

			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
			PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
			vCtr := vCtr + 1;

		end if;


		if l_previous_person_id <> l_person_id OR l_prev_period_of_service <> l_period_of_service then
			l_previous_person_id:=l_person_id;
			l_prev_period_of_service:=l_period_of_service;
		end if;

		l_house_number_ee := NULL;
		l_house_add_no_ee := NULL;
		l_street_name_ee := NULL;
		l_line1_ee := NULL;
		l_line2_ee := NULL;
		l_line3_ee := NULL;
		l_city_ee := NULL;
		l_country_ee := NULL;
		l_po_code_ee := NULL;
		l_addr1_ee := NULL;
		l_addr2_ee := NULL;


	end loop;

	if l_previous_person_id <> -1 and p_agg_flag = 'Y' then

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Taxable_Income';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Taxable_Income;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Deducted_Wage_Tax';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Deducted_Wage_Tax;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Labour_Tax_Reduction';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Labour_Tax_Reduction;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Wage_for_ZVW';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW_Basis;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'ZVW_Cont';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_ZVW;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Private_Use_Car';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Private_Use_Car;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Net_Expense_Allowance';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Net_Expense_Allowance;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Value_Private_Use_Car';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Value_Private_Use_Car;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Saved_Amount_LSS';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Saved_Amount_LSS;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Employer_Child_Care';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Employer_Child_Care;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Allowance_on_Disability';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Allowance_on_Disability;
		vCtr := vCtr + 1;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'Applied_LCLD';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := l_Applied_LCLD;
		vCtr := vCtr + 1;

		IF vUserBalVal.COUNT > 0 THEN

			FOR lCtr IN vUserBalVal.FIRST .. vUserBalVal.LAST LOOP

				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName  := vUserBalVal(lCtr).TagName;
				PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := vUserBalVal(lCtr).BalValue;
				vCtr := vCtr + 1;

				--hr_utility.set_location('tag name-'||vUserBalVal(lCtr).TagName||' tag value-'||vUserBalVal(lCtr).BalValue,90);

			END LOOP;

		END IF;

		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagName := 'G_CONTAINER_EMP_REC';
		PAY_NL_XDO_REPORT.vXMLTable(vCtr).TagValue := 'END';
		vCtr := vCtr + 1;

		l_taxable_income:=0;
		l_deducted_wage_tax:=0;
		l_labour_tax_reduction:=0;
		l_ZVW:=0;
		l_ZVW_Basis:=0;
		l_Private_Use_Car:=0;
		l_Net_Expense_Allowance:=0;
		l_Value_Private_Use_Car:=0;
		l_Saved_Amount_LSS:=0;
		l_Employer_Child_Care:=0;
		l_Allowance_on_Disability:=0;
		l_Applied_LCLD:=0;
		vUserBalVal.DELETE;

	end if;

/*Fetch XML file as a CLOB*/

 pay_nl_xdo_Report.WritetoCLOB_rtf_1(p_xml );

 pay_nl_xdo_Report.WritetoXML_rtf (fnd_global.conc_request_id,l_output_fname);

end populate_ats_report_data_new;

PROCEDURE record_4712(p_file_id NUMBER) IS

	l_upload_name       VARCHAR2(1000);
	l_file_name         VARCHAR2(1000);
	l_start_date        DATE := TO_DATE('01/01/0001', 'dd/mm/yyyy');
	l_end_date          DATE := TO_DATE('31/12/4712', 'dd/mm/yyyy');

BEGIN
	-- program_name will be used to store the file_name
	-- this is bcos the file_name in fnd_lobs contains
	-- the full patch of the doc and not just the file name
	SELECT program_name
	INTO l_file_name
	FROM fnd_lobs
	WHERE file_id = p_file_id;

	-- the delete will ensure that the patch is rerunnable
	DELETE FROM per_gb_xdo_templates
	WHERE file_name = l_file_name AND
	effective_start_date = l_start_date AND
	effective_end_date = l_end_date;

	INSERT INTO per_gb_xdo_templates
	(file_id,
	file_name,
	file_description,
	effective_start_date,
	effective_end_date)
	SELECT p_file_id, l_file_name, 'Template for year 0001-4712',
	l_start_date, l_end_date
	FROM fnd_lobs
	WHERE file_id = p_file_id;
END;

/*-----------------------------------------------------------------------------
|Name       : populate_UserBalVal				               |
|Type       : Procedure							       |
|Description: Procedure which populates pl/sql table with user defined balance |
|             values and tag names                                             |
-------------------------------------------------------------------------------*/

PROCEDURE populate_UserBalVal(p_User_Bal_String VARCHAR2, p_agg_flag VARCHAR2) IS

l_start	NUMBER;
l_end	NUMBER;
lCtr	NUMBER;

BEGIN

	l_start := 1;
	lCtr	:= 0;

	hr_utility.set_location('Entered populate_UserBalVal',10);

	IF PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.count > 0 AND instr(p_User_Bal_String,'|',1,PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.count)=length(p_User_Bal_String) THEN

		IF p_agg_flag='N' THEN

			--hr_utility.set_location('Agg flag N in function',20);
			--hr_utility.set_location('User table first-'||PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.FIRST||' last-'||PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.LAST||' count-'||PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.COUNT,20);

			FOR lCtr IN PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.FIRST .. PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.LAST LOOP

				l_end := instr(p_User_Bal_String,'|',l_start,1);

				vUserBalVal(lCtr).BalValue := fnd_number.canonical_to_number(substr(p_User_Bal_String,l_start,l_end-l_start));
				vUserBalVal(lCtr).TagName  := PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable(lCtr).TagName;

				hr_utility.set_location('tag-'||vUserBalVal(lCtr).TagName,13);
				hr_utility.set_location('bal-'||vUserBalVal(lCtr).BalValue,23);

				l_start := l_end + 1;

			END LOOP;

		ELSIF p_agg_flag='Y' THEN

			FOR lCtr IN PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.FIRST .. PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable.LAST LOOP

				l_end := instr(p_User_Bal_String,'|',l_start,1);

				vUserBalVal(lCtr).BalValue := vUserBalVal(lCtr).BalValue + fnd_number.canonical_to_number(substr(p_User_Bal_String,l_start,l_end-l_start));
				vUserBalVal(lCtr).TagName  := PAY_NL_TAXOFFICE_ARCHIVE.vUserBalTable(lCtr).TagName;

				l_start := l_end + 1;

			END LOOP;

		END IF;

	END IF;

END populate_UserBalVal;


/*-----------------------------------------------------------------------------
|Name       : get_Address_Style					               |
|Type       : Function							       |
|Description: Function that returns the address style of the address record of |
|             a person at a given date                                         |
-------------------------------------------------------------------------------*/

FUNCTION get_Address_Style(p_person_id NUMBER, p_effective_date DATE) RETURN VARCHAR2 IS

l_address_style VARCHAR2(50) := 'N';

BEGIN

	BEGIN

		SELECT	pad.style INTO l_address_style
		FROM	per_addresses pad
		WHERE	pad.person_id = p_person_id
		AND	pad.primary_flag = 'Y'
		AND	p_effective_date between pad.date_from and nvl(pad.date_to,hr_general.end_of_time);

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN null;

		WHEN OTHERS
			THEN null;

	END;

	return l_address_style;

END get_Address_Style;

/*-----------------------------------------------------------------------------
|Name       : get_Post_Code					               |
|Type       : Function							       |
|Description: Function that returns the postal code of the address record of   |
|             a person at a given date                                         |
-------------------------------------------------------------------------------*/

FUNCTION get_Post_Code(p_person_id NUMBER, p_effective_date DATE) RETURN VARCHAR2 IS

l_post_code VARCHAR2(50) := '';

BEGIN

	BEGIN

		SELECT	pad.postal_code INTO l_post_code
		FROM	per_addresses pad
		WHERE	pad.person_id = p_person_id
		AND	pad.primary_flag = 'Y'
		AND	p_effective_date between pad.date_from and nvl(pad.date_to,hr_general.end_of_time);

	EXCEPTION

		WHEN NO_DATA_FOUND
			THEN null;

		WHEN OTHERS
			THEN null;

	END;

	return l_post_code;

END get_Post_Code;

END PAY_NL_ATS_REPORT;

/
