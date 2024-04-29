--------------------------------------------------------
--  DDL for Package Body PAY_AE_SI_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PAY_AE_SI_REPORTS" AS
/* $Header: pyaesirp.pkb 120.22 2006/12/27 11:34:40 spendhar noship $ */
  lg_format_mask varchar2(50);
  PROCEDURE set_currency_mask
    (p_business_group_id IN NUMBER) IS
    /* Cursor to retrieve Currency */
    CURSOR csr_currency IS
    SELECT org_information10
    FROM   hr_organization_information
    WHERE  organization_id = p_business_group_id
    AND    org_information_context = 'Business Group Information';
    l_currency VARCHAR2(40);
  BEGIN
    OPEN csr_currency;
    FETCH csr_currency into l_currency;
    CLOSE csr_currency;
    lg_format_mask := FND_CURRENCY.GET_FORMAT_MASK(l_currency,40);
  END set_currency_mask;
-------------------------------------------------------------------------------------------
    FUNCTION get_index (p_index IN NUMBER) return VARCHAR2
    IS
    l_label varchar2(40);
    BEGIN
    	If p_index = 1 THEN
    		l_label := 'Basic Salary';
    	ElsIf p_index = 2 THEN
    		l_label := 'Housing Allowance';
    	ElsIf p_index = 3 THEN
    		l_label := 'Social Allowance';
    	ElsIf p_index = 4 THEN
    		l_label := 'Child Social Allowance';
    	ElsIf p_index = 5 THEN
    		l_label := 'Cost of Living Allowance';
    	ElsIf p_index = 6 THEN
    		l_label := 'Transportation Allowance';
    	ElsIf p_index = 7 THEN
    		l_label := 'Allowance 1';
    	ElsIf p_index = 8 THEN
    		l_label := 'Allowance 2';
    	ElsIf p_index = 9 THEN
    		l_label := 'Allowance 3';
    	ElsIf p_index = 10 THEN
    		l_label := 'Allowance 4';
    	ElsIf p_index = 11 THEN
    		l_label := 'Other Allowance';
    	End If;
    	return l_label;
    END get_index;
-------------------------------------------------------------------------------------------
  FUNCTION get_lookup_meaning
    (p_lookup_type varchar2
    ,p_lookup_code varchar2)
    RETURN VARCHAR2 IS
    CURSOR csr_lookup IS
    select meaning
    from   hr_lookups
    where  lookup_type = p_lookup_type
    and    lookup_code = p_lookup_code;
    l_meaning hr_lookups.meaning%type;
  BEGIN
    OPEN csr_lookup;
    FETCH csr_lookup INTO l_Meaning;
    CLOSE csr_lookup;
    RETURN l_meaning;
  END get_lookup_meaning;
------------------------------------------------------------------------------------------
  PROCEDURE FORM1
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS




    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'AE_BG_DETAILS';

    /*Cursor for fetching Employer SSN*/
     CURSOR csr_employer_ssn IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_employer_id
     AND    org_information_context = 'AE_LEGAL_EMPLOYER_DETAILS';

     /*Cursor for fetching Employer Name*/
     CURSOR csr_employer_name IS
     SELECT name
     FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /* Cursor for fetching current employer type */
    CURSOR csr_cur_employer_type IS
    SELECT	org_information6
    FROM	hr_organization_information hoi
    WHERE	hoi.organization_id = p_employer_id
    AND		hoi.org_information_context = 'AE_LEGAL_EMPLOYER_DETAILS';

     /*Cursor for fetching Employer's PO Box and Emirate Code */
     CURSOR csr_employer_address (l_loc_id number) IS
     SELECT loc.address_line_3, loc.LOC_INFORMATION15
     FROM   hr_locations loc
     WHERE  loc.location_id = l_loc_id;

     /*Cursor for fetching Employer's Emirate */
     CURSOR csr_employer_emirate (l_emirate varchar2) IS
     SELECT hl.meaning
     FROM   hr_lookups hl
     WHERE  hl.lookup_code = l_emirate
     AND    hl.lookup_type = 'AE_EMIRATE'
     AND    hl.enabled_flag = 'Y';

    /* Cursor for fetching organization phone types */
    	CURSOR csr_get_org_phone_types (l_bg_id number) IS
    	SELECT  hoi.org_information1,hoi.org_information2,hoi.org_information3,hoi.org_information4
    	FROM	hr_organization_information hoi
    	WHERE 	hoi.organization_id = l_bg_id
    	AND 	hoi.org_information_context = 'AE_HR_BG_INFO';

    /* Cursor for fetching person's phone details */
    	CURSOR csr_p_phone_data (l_person_id number,l_ph_type varchar2,l_effective_date date) IS
    	SELECT  pp.phone_number
    	FROM	per_phones pp,per_all_people_f ppf
    	WHERE 	pp.parent_id = ppf.person_id
    	AND 	pp.phone_type = l_ph_type
    	AND     ppf.person_id = l_person_id
    	AND 	l_effective_date between pp.date_from and nvl(pp.date_to,to_date('31-12-4712','DD-MM-YYYY'));

    /* Cursor for fetching the New Employees coming under legal employer*/
	CURSOR csr_get_emp (l_employer_id number, l_effective_date date, l_nat_cd varchar2) IS
    	SELECT distinct asg.person_id
                        ,paa.assignment_action_id
                        ,ppa.date_earned
                        ,pos.date_start
        FROM   per_all_assignments_f asg
               ,pay_assignment_actions paa
               ,pay_payroll_actions ppa
               ,hr_soft_coding_keyflex hscl
               ,per_periods_of_service pos
               ,per_all_people_f ppf
        WHERE  asg.assignment_id = paa.assignment_id
        AND    paa.payroll_action_id = ppa.payroll_action_id
        AND    pos.period_of_service_id = asg.period_of_service_id
        AND    ppa.action_type in ('R','Q')
        AND    ppa.action_status = 'C'
        AND    paa.action_status = 'C'
        AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
        AND    trunc(pos.date_start, 'MM') = trunc(l_effective_date, 'MM')
        AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
        AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
        AND    hscl.segment1 = to_char(l_employer_id)
        AND    ppf.person_id = asg.person_id
        AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
        AND    ppf.per_information18 = l_nat_cd;

    /* Cursor for fetching the person data */
    	CURSOR csr_p_data (l_person_id number,l_effective_date date) IS
    	SELECT ppf.full_name,ppf.employee_number,ppf.date_of_birth,ppf.marital_status,ppf.sex,fnd_date.canonical_to_date(ppf.per_information16),ppf.per_information17
    	FROM	per_all_people_f ppf
    	WHERE 	ppf.person_id = l_person_id
    	AND	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching the person's gender meaning */
    	CURSOR csr_p_gender (l_sex varchar2) IS
    	SELECT hl.meaning
    	FROM	hr_lookups hl
    	WHERE 	hl.lookup_type = 'SEX'
    	AND	hl.lookup_code = l_sex
    	AND	hl.enabled_flag = 'Y';

    /* Cursor for fetching the person's marital status */
    	CURSOR csr_p_mar_status (l_mar_stat varchar2) IS
    	SELECT hl.meaning
    	FROM	hr_lookups hl
    	WHERE 	hl.lookup_type = 'MAR_STATUS'
    	AND	hl.lookup_code = l_mar_stat
    	AND	hl.enabled_flag = 'Y';

    /* Cursor for fetching the person's assignment data */
    	CURSOR csr_p_asg_data (l_person_id number,l_effective_date date) IS
    	SELECT hsck.segment2,hsck.segment3,fnd_date.canonical_to_date(hsck.segment4),hsck.segment5,paf.location_id
    	FROM	per_all_assignments_f paf,hr_soft_coding_keyflex hsck
    	WHERE 	paf.person_id = l_person_id
    	AND     paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    	AND     hsck.segment1 = p_employer_id
    	AND	l_effective_date between paf.effective_start_date and paf.effective_end_date;

    /* Cursor for fetching the person's job */
    	CURSOR csr_p_job (l_person_id number,l_effective_date date) IS
    	SELECT pjb.name
    	FROM	per_all_assignments_f paf,per_jobs pjb
    	WHERE 	paf.person_id = l_person_id
    	AND     pjb.job_id = paf.job_id
    	AND	l_effective_date between paf.effective_start_date and paf.effective_end_date;

    /* Cursor for fetching the person's qualification data */
    	CURSOR csr_p_qual_data (l_person_id number,l_qual_id number) IS
    	SELECT  pq.title , pq.attendance_id , hl.meaning
    	FROM	per_qualifications_v pq , per_subjects_taken pst ,hr_lookups hl
    	WHERE 	pq.person_id = l_person_id
    	AND	pq.qualification_id = l_qual_id
    	AND     pst.qualification_id = pq.qualification_id
    	AND     pst.major = 'Y'
    	AND 	hl.lookup_type = 'PER_SUBJECTS'
    	AND	hl.lookup_code = pst.subject
    	AND     rownum < 2;

    /* Cursor to fetch establishment name */
        CURSOR get_est_name (l_attendance_id number) IS
	select est.name
	from per_establishments est, per_establishment_attendances pea, per_qualifications pq
	where pq.attendance_id = l_attendance_id
	and   pq.attendance_id = pea.attendance_id
	and   est.establishment_id = pea.establishment_id;

    /* Cursor for fetching the person's ex-employer's name */
    	CURSOR csr_p_ex_emp_data (l_person_id number) IS
    	SELECT  pr.employer_name ,pr.previous_employer_id,pr.employer_type, pr.PEM_INFORMATION1 , fnd_date.canonical_to_date(pr.PEM_INFORMATION2),pr.PEM_INFORMATION3,pr.PEM_INFORMATION4
    	FROM	per_previous_employers pr
    	WHERE 	pr.person_id = l_person_id
    	AND     pr.PEM_INFORMATION_CATEGORY ='AE'
    	AND	nvl(pr.end_date,sysdate) in (SELECT 	nvl(max(end_date),sysdate)
    				FROM	per_previous_employers
    				WHERE 	person_id = l_person_id ) order by nvl(start_date,sysdate) desc,employer_name desc ;

    /* Cursor for fetching the person's spouse's ex-employer's name */
    	CURSOR csr_p_s_ex_emp_data (l_person_id number) IS
    	SELECT  pr.employer_name ,pr.previous_employer_id
    	FROM	per_previous_employers pr
    	WHERE 	pr.person_id = l_person_id
    	AND	nvl(pr.end_date,sysdate) in (SELECT 	nvl(max(end_date),sysdate)
    				FROM	per_previous_employers
    				WHERE 	person_id = l_person_id ) order by nvl(start_date,sysdate) desc,employer_name desc ;

     /* Cursor for fetching the person's ex-employer's transfer date */
    	CURSOR csr_p_ex_emp_date_data (l_person_id number,l_ex_emp_id number) IS
    	SELECT  pr.end_date
    	FROM	per_previous_employers pr
    	WHERE 	pr.person_id = l_person_id
    	AND 	pr.previous_employer_id = l_ex_emp_id
    	AND     pr.employer_type = 'FG'
    	AND     pr.PEM_INFORMATION1 = 'EMP_TRANS';

    /* Cursor for fetching person's Address */
    	CURSOR csr_p_address_data (l_person_id number,l_effective_date date) IS
    	SELECT  substr(addr.ADDRESS_LINE1 || ' ' ||addr.address_line2,1,60)
    	FROM	per_addresses addr
    	WHERE 	addr.person_id = l_person_id
    	AND 	l_effective_date between addr.date_from and nvl(addr.date_to,to_date('31-12-4712','dd-mm-yyyy'))
    	AND     addr.primary_flag = 'Y';

    /* Cursor for fetching person's Disability */
    	CURSOR csr_p_disability_data (l_person_id number,l_effective_date date) IS
    	SELECT  substr(dis.reason,1,60),dis.degree,dis.effective_start_date
    	FROM	per_disabilities_f dis
    	WHERE 	dis.person_id = l_person_id
    	AND 	l_effective_date between dis.effective_start_date and dis.effective_end_date
--    	AND     dis.status = 'A'
    	AND  	dis.dis_information1 = 'Y';

    /* Cursor for fetching meaning of disability reason */
      CURSOR csr_get_dis_meaning (l_lookup_code varchar2) IS
      SELECT meaning
      FROM hr_lookups
      WHERE lookup_type = 'DISABILITY_REASON'
      and lookup_code = l_lookup_code
      and enabled_flag = 'Y';

    /* Cursor for fetching person's spouse's person id */
    	CURSOR csr_p_spouse_id (l_person_id number,l_type varchar2, l_gender varchar2,l_effective_date date) IS
    	SELECT  CONTACT_PERSON_ID
    	FROM	per_contact_relationships cont
    	WHERE 	cont.person_id = l_person_id
    	AND 	cont.contact_type = l_type;

    /* Cursor for fetching person's spouse's qualification details */
    	CURSOR csr_get_spouse_details (l_spouse_person_id number) IS
    	SELECT  pq.title , hl.meaning
    	FROM	per_qualifications_v pq , per_subjects_taken pst ,hr_lookups hl
    	WHERE 	pq.person_id = l_spouse_person_id
    	AND     pst.qualification_id = pq.qualification_id
    	AND     pst.major = 'Y'
    	AND 	hl.lookup_type = 'PER_SUBJECTS'
    	AND	hl.lookup_code = pst.subject
    	AND     rownum < 2;

    /* Cursor for fetching person's contact counts */
    	CURSOR csr_p_contact_count_data (l_person_id number,l_type varchar2, l_gender varchar2, l_effective_date date) IS
    	SELECT  count(*)
    	FROM	per_contact_relationships cont , per_all_people_f ppf
    	WHERE 	cont.person_id = l_person_id
    	AND 	cont.contact_type = l_type
    	AND     ppf.person_id = cont.CONTACT_PERSON_ID
    	AND  	ppf.sex = l_gender
    	AND 	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_bg_id number) IS
        SELECT  ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3,ORG_INFORMATION4,ORG_INFORMATION5,ORG_INFORMATION6,ORG_INFORMATION7,ORG_INFORMATION8,ORG_INFORMATION9,ORG_INFORMATION10
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_bg_id
        AND	org_information_context = 'AE_SI_DETAILS';

    /*Cursor for fetching defined balance id for subject_to_social_asg_run*/
    CURSOR csr_get_def_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'AE'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';


    TYPE def_bal_rec IS RECORD
    (def_bal_id                  NUMBER
    ,label_index		 VARCHAR2(40));
    TYPE t_def_bal_table IS TABLE OF def_bal_rec INDEX BY BINARY_INTEGER;
    t_store_def_bal   t_def_bal_table;
    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,date_earned                DATE
    ,date_start                DATE);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;
    l_employer_name varchar2(240);
    l_input_date varchar2(30);
    l_effective_date date;
    l_employer_ssn number;
    l_basic_sal_id number;
    z number;
    l_accomodation_id number;
    l_social_id number;
    l_child_social_id number;
    l_tp_id number;
    l_ol1_id number;
    l_ol2_id number;
    l_ol3_id number;
    l_ol4_id number;
    l_cost_of_living_id number;
    l_index number;
    i number;
    k number;
    m number;
    j number;
    x number;
    l_new_processed number;
    l_all_processed number;
    l_new_count number;
    l_basic_val number (15,2);
    l_accomodation_val number(15,2);
    l_allowance_1_val number(15,2);
    l_allowance_2_val number(15,2);
    l_allowance_3_val number(15,2);
    l_allowance_4_val number(15,2);
    l_allowance_5_val number(15,2);
    l number;
    L_FULL_NAME varchar2(240);
    l_insured_ssn number;
    l_employee_number varchar2(180);
    l_uae_civil_reg_number number;
    l_asg_location_id number;
    l_work_emirate varchar2(100);
    l_work_emirate_code varchar2(100);
    l_home_phone_number varchar2(100);
    l_work_phone_number varchar2(100);
    l_home_fax_number varchar2(100);
    l_work_fax_number varchar2(100);
    L_MARITAL_STATUS varchar2(100);
    l_mar_p_status varchar2(30);
    l_job varchar2(100);
    l_latest_qual_id number;
    l_p_qual_name varchar2(100);
    l_p_address varchar2(100);
    l_gender varchar2(100);
    l_gender_c varchar2(100);
    l_number_of_sons number;
    l_number_of_daughters number;
    l_number_of_wives number;
    L_NAT_DATE date;
    L_AWARDING_BODY varchar2(100);
    L_S_EX_EMPLOYER_NAME varchar2(100);
    l_s_qual varchar2(100);
    L_DIS_DETAILS varchar2(100);
    L_MAJOR    varchar2(100);
    l_dis_date date;
    l_dis_percent number;
    l_dis_meaning varchar2(100);
    l_s_major varchar2(100);
    L_S_EX_EMPLOYER_ID number;
    l_nat_reason varchar2(100);
    L_S_PERSON_ID number;
    l_home_phone varchar2(100);
    l_work_phone varchar2(100);
    l_home_fax varchar2(100);
    l_work_fax varchar2(100);
    L_P_EX_EMPLOYER varchar2(100);
    L_P_EX_EMPLOYER_id number;
    l_transfer_date date;
    l_tr_date date;
    l_sector_name varchar2(60);
    l_paid_flag varchar2(10);
    l_dob date;
    L_CONT_START_DATE date;
    l_work_po_box varchar2(100);
    L_TOTAL number(15,2);
    L_FM_TOTAL_VAL varchar2(100);
    l_fm_l_basic_val varchar2(100);
    L_FM_L_ACCOMODATION_VAL varchar2(100);
    L_FM_L_ALLOWANCE_1_VAL varchar2(100);
    L_FM_L_ALLOWANCE_2_VAL varchar2(100);
    L_FM_L_ALLOWANCE_3_VAL varchar2(100);
    L_FM_L_ALLOWANCE_4_VAL varchar2(100);
    L_FM_L_ALLOWANCE_5_VAL varchar2(100);
    l_subject_to_social_id number;
    l_p_ex_employer_type varchar2(100);
    l_cur_employer_type varchar2(100);
    l_p_term_reason varchar2(100);
    rec_get_emp        csr_get_emp%ROWTYPE;
    l_nat_cd varchar2(30);
    l_est_name varchar2(240);

  BEGIN

    set_currency_mask(p_business_group_id);

    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));

    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    -- To clear the PL/SQL Table values.
    t_store_def_bal.DELETE;
    vXMLTable.DELETE;
    vCtr := 1;
    hr_utility.set_location('Entering FORM1 ',10);

    /* Fetch local nationality */
    OPEN csr_get_loc_nat;
    FETCH csr_get_loc_nat into l_nat_cd;
    CLOSE csr_get_loc_nat;

    /* Fetch current employer type */
    OPEN csr_cur_employer_type;
    FETCH csr_cur_employer_type into l_cur_employer_type;
    CLOSE csr_cur_employer_type;


    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    OPEN csr_get_def_bal_ids (p_employer_id);
    FETCH csr_get_def_bal_ids into l_basic_sal_id,l_accomodation_id,l_social_id,l_child_social_id,l_cost_of_living_id,l_ol1_id,l_tp_id,l_ol2_id,l_ol3_id,l_ol4_id;
    CLOSE csr_get_def_bal_ids;

    OPEN csr_get_def_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_def_id into l_subject_to_social_id;
    CLOSE csr_get_def_id;

    z := 1;
    t_store_def_bal(z).def_bal_id := l_basic_sal_id;
    t_store_def_bal(z).label_index := get_index(1);

    z:= z+1;

    l_index := 2;

    LOOP

        If l_accomodation_id is not null THEN
                t_store_def_bal(z).def_bal_id := l_accomodation_id;
                t_store_def_bal(z).label_index := get_index(3);
                z := z + 1;
                l_index := l_index + 1;
                EXIT WHEN z > 7;
        End if;

    	If l_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_social_id;
    		t_store_def_bal(z).label_index := get_index(3);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 7;
    	End if;
    	If l_child_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_child_social_id;
    		t_store_def_bal(z).label_index := get_index(4);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 7;
    	End if;
    	If l_cost_of_living_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_cost_of_living_id;
    		t_store_def_bal(z).label_index := get_index(5);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 7;
    	End if;
    	If l_tp_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_tp_id;
    	        t_store_def_bal(z).label_index := get_index(6);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 7;
    	End if;
    	If l_ol1_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol1_id;
    		t_store_def_bal(z).label_index := get_index(7);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 7;
    	End if;
    	If l_ol2_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol2_id;
		t_store_def_bal(z).label_index := get_index(8);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 7;
    	End if;
    	If l_ol3_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol3_id;
    		t_store_def_bal(z).label_index := get_index(9);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 7;
    	End if;
    	If l_ol4_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol4_id;
    		t_store_def_bal(z).label_index := get_index(10);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 7;
    	End if;
    	If z < 8 then
    		WHILE Z <= 8 LOOP
    			t_store_def_bal(z).def_bal_id := NULL;
    			t_store_def_bal(z).label_index := get_index(11);
    			z := z + 1;
    			EXIT WHEN z > 8;
    		END LOOP;
	End If;
    	EXIT WHEN z >= 8;
    END LOOP;

    l := 3;
    i := 0;
    k := 0;
    m := 0;

    OPEN csr_get_emp(p_employer_id , l_effective_date , l_nat_cd);
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      i := i + 1;
      t_store_assact(i).person_id := rec_get_emp.person_id;
      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
      t_store_assact(i).date_earned := rec_get_emp.date_earned;
      t_store_assact(i).date_start := rec_get_emp.date_earned;
    END LOOP;
    CLOSE csr_get_emp;

    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;

    l_all_processed := 0;
        j := 1;

    WHILE j <= i LOOP
            vXMLTable(vCtr).TagName := 'Employer_ssn';
            vXMLTable(vCtr).TagValue := l_employer_ssn;
            vctr := vctr + 1;
            vXMLTable(vCtr).TagName := 'Employer_name';
            vXMLTable(vCtr).TagValue := l_employer_name;
            vctr := vctr + 1;
/********* Reset all the local variables **********/
l_full_name := null;
l_employee_number := null;
l_dob := null;
l_marital_status := null;
l_mar_p_status := null;
l_gender := null;
l_nat_date := null;
l_nat_reason := null;
l_insured_ssn := null;
l_uae_civil_reg_number := null;
l_cont_start_date := null;
l_job := null;
l_latest_qual_id := null;
l_asg_location_id := null;
l_work_emirate := null;
l_work_po_box := null;
l_home_phone := null;
l_work_phone := null;
l_home_fax := null;
l_work_fax := null;
l_home_phone_number := null;
l_work_phone_number := null;
l_home_fax_number := null;
l_work_fax_number := null;
l_p_ex_employer := null;
l_p_ex_employer_id := null;
l_transfer_date := null;
l_p_qual_name := null;
l_awarding_body := null;
l_major := null;
l_p_address := null;
l_number_of_wives := null;
l_number_of_sons := null;
l_number_of_daughters := null;
l_s_person_id := null;
l_s_qual := null;
l_s_major := null;
l_s_ex_employer_name := null;
l_s_ex_employer_id := null;
l_dis_details := null;
l_dis_percent := null;
l_dis_date := null;
l_dis_meaning := null;
l_est_name := null;
     l_basic_val := 0;
      l_accomodation_val := 0;
      l_allowance_1_val := 0;
      l_allowance_2_val := 0;
      l_allowance_3_val := 0;
      l_allowance_4_val := 0;
      l_total := 0;

      OPEN csr_p_data(t_store_assact(j).person_id,l_effective_date);
      FETCH csr_p_data INTO l_full_name,l_employee_number,l_dob,l_marital_status,l_gender_c,l_nat_date,l_nat_reason;
      CLOSE csr_p_data;

      OPEN csr_p_gender(l_gender_c);
      FETCH csr_p_gender INTO l_gender;
      CLOSE csr_p_gender;

      OPEN csr_p_mar_status(l_marital_status);
      FETCH csr_p_mar_status into l_mar_p_status;
      CLOSE csr_p_mar_status;

      OPEN csr_p_asg_data(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_p_asg_data into l_uae_civil_reg_number,l_insured_ssn,l_cont_start_date,l_latest_qual_id,l_asg_location_id;
      CLOSE csr_p_asg_data;

      OPEN csr_p_job(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_p_job into l_job;
      CLOSE csr_p_job;

      OPEN csr_employer_address (l_asg_location_id);
      FETCH csr_employer_address into l_work_emirate_code, l_work_po_box;
      CLOSE csr_employer_address;

      OPEN csr_employer_emirate (l_work_emirate_code);
      FETCH csr_employer_emirate into l_work_emirate;
      CLOSE csr_employer_emirate;

      OPEN csr_get_org_phone_types (p_business_group_id);
      FETCH csr_get_org_phone_types into l_home_phone,l_work_phone,l_home_fax,l_work_fax;
      CLOSE csr_get_org_phone_types;

      OPEN csr_p_phone_data(t_store_assact(j).person_id,'H1',l_effective_date);
      FETCH csr_p_phone_data into l_home_phone_number;
      CLOSE csr_p_phone_data;

      OPEN csr_p_phone_data(t_store_assact(j).person_id,'W1',l_effective_date);
      FETCH csr_p_phone_data into l_work_phone_number;
      CLOSE csr_p_phone_data;

      OPEN csr_p_phone_data(t_store_assact(j).person_id,'HF',l_effective_date);
      FETCH csr_p_phone_data into l_home_fax_number;
      CLOSE csr_p_phone_data;

      OPEN csr_p_phone_data(t_store_assact(j).person_id,'WF',l_effective_date);
      FETCH csr_p_phone_data into l_work_fax_number;
      CLOSE csr_p_phone_data;


      OPEN csr_p_ex_emp_data (t_store_assact(j).person_id);
      FETCH csr_p_ex_emp_data into l_p_ex_employer,l_p_ex_employer_id, l_p_ex_employer_type , l_p_term_reason , l_tr_date,l_sector_name,l_paid_flag;
      CLOSE csr_p_ex_emp_data;


      OPEN csr_p_ex_emp_date_data (t_store_assact(j).person_id,l_p_ex_employer_id);
      FETCH csr_p_ex_emp_date_data into l_transfer_date;
      CLOSE csr_p_ex_emp_date_data;

      OPEN csr_p_qual_data(t_store_assact(j).person_id,l_latest_qual_id);
      FETCH csr_p_qual_data into l_p_qual_name,l_awarding_body , l_major;
      CLOSE csr_p_qual_data;

     If l_awarding_body is not null then
	OPEN get_est_name(l_awarding_body);
	FETCH get_est_name into l_est_name;
	CLOSE get_est_name;
      End If;

      OPEN csr_p_address_data (t_store_assact(j).person_id,l_effective_date);
      FETCH csr_p_address_data into l_p_address;
      CLOSE csr_p_address_data;

      IF l_gender_c = 'M' then
      	OPEN csr_p_contact_count_data(t_store_assact(j).person_id,'S','F',l_effective_date);
      	FETCH csr_p_contact_count_data into l_number_of_wives;
      	CLOSE csr_p_contact_count_data;
      Else
      	l_number_of_wives := 0;
      END IF;

      OPEN csr_p_contact_count_data(t_store_assact(j).person_id,'C','M',l_effective_date);
      FETCH csr_p_contact_count_data into l_number_of_sons;
      CLOSE csr_p_contact_count_data;

      OPEN csr_p_contact_count_data(t_store_assact(j).person_id,'C','F',l_effective_date);
      FETCH csr_p_contact_count_data into l_number_of_daughters;
      CLOSE csr_p_contact_count_data;

      OPEN csr_p_spouse_id (t_store_assact(j).person_id,'S',l_gender,l_effective_date);
      FETCH csr_p_spouse_id into l_s_person_id;
      CLOSE csr_p_spouse_id;

      OPEN csr_get_spouse_details (l_s_person_id);
      FETCH csr_get_spouse_details into l_s_qual,l_s_major;
      CLOSE csr_get_spouse_details;

      OPEN csr_p_s_ex_emp_data(l_s_person_id);
      FETCH csr_p_s_ex_emp_data into l_s_ex_employer_name, l_s_ex_employer_id;
      CLOSE csr_p_s_ex_emp_data;

      OPEN csr_p_disability_data (t_store_assact(j).person_id,l_effective_date);
      FETCH csr_p_disability_data into l_dis_details,l_dis_percent,l_dis_date;
      CLOSE csr_p_disability_data;

	OPEN csr_get_dis_meaning(l_dis_details);
	FETCH  csr_get_dis_meaning  into l_dis_meaning;
	CLOSE csr_get_dis_meaning;

      x := 1;

      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_basic_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_basic_val := 0;
      		x:= x + 1;
      END IF;

      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_accomodation_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_accomodation_val := 0;
      		x:= x + 1;
      END IF;

      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_1_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_1_val := 0;
      		x:= x + 1;
      END IF;

      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_2_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_2_val := 0;
      		x:= x + 1;
      END IF;

      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_3_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_3_val := 0;
      		x:= x + 1;
      END IF;

      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_4_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_4_val := 0;
      		x:= x + 1;
      END IF;

      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_5_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
      ELSE
      		l_allowance_5_val := 0;
      END IF;

      l_new_count := l_new_count+1;
      l_fm_l_basic_val := to_char(abs(l_basic_val),lg_format_mask);
      l_fm_l_accomodation_val := to_char(abs(l_accomodation_val),lg_format_mask);
      l_fm_l_allowance_1_val := to_char(abs(l_allowance_1_val),lg_format_mask);
      l_fm_l_allowance_2_val := to_char(abs(l_allowance_2_val),lg_format_mask);
      l_fm_l_allowance_3_val := to_char(abs(l_allowance_3_val),lg_format_mask);
      l_fm_l_allowance_4_val := to_char(abs(l_allowance_4_val),lg_format_mask);
      l_fm_l_allowance_5_val := to_char(abs(l_allowance_5_val),lg_format_mask);

      /** Populate the XML file **/

      vXMLTable(vCtr).TagName := 'po_box';
      vXMLTable(vCtr).TagValue := l_work_po_box;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Emirate_name';
      vXMLTable(vCtr).TagValue := l_work_emirate;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'fax';
      vXMLTable(vCtr).TagValue := l_work_fax_number;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'phone';
      vXMLTable(vCtr).TagValue := l_work_phone_number;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Insured_ssn';
      vXMLTable(vCtr).TagValue := l_insured_ssn;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Insured_name';
      vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,60);
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Employee_number';
      vXMLTable(vCtr).TagValue := l_employee_number;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'job';
      vXMLTable(vCtr).TagValue := l_job;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'contribution_start_day';
      vXMLTable(vCtr).TagValue := to_char(l_cont_start_date,'DD');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'contribution_start_month';
      vXMLTable(vCtr).TagValue := to_char(l_cont_start_date,'MM');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'contribution_start_year';
      vXMLTable(vCtr).TagValue := to_char(l_cont_start_date,'YYYY');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'salary_start_day';
      vXMLTable(vCtr).TagValue := to_char(t_store_assact(j).date_earned,'DD');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'salary_start_month';
      vXMLTable(vCtr).TagValue := to_char(t_store_assact(j).date_earned,'MM');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'salary_start_year';
      vXMLTable(vCtr).TagValue := to_char(t_store_assact(j).date_earned,'YYYY');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'joining_day';
      vXMLTable(vCtr).TagValue := to_char(t_store_assact(j).date_start,'DD');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'joining_month';
      vXMLTable(vCtr).TagValue := to_char(t_store_assact(j).date_start,'MM');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'joining_year';
      vXMLTable(vCtr).TagValue := to_char(t_store_assact(j).date_start,'YYYY');
      vctr := vctr + 1;

      If (l_p_ex_employer_type = 'FG' and l_cur_employer_type = 'F') and l_p_term_reason = 'EMP_TRANS' then

	      vXMLTable(vCtr).TagName := 'transfer_day';
	      vXMLTable(vCtr).TagValue := nvl(to_char(l_tr_date,'DD'),' ');
	      vctr := vctr + 1;

	      vXMLTable(vCtr).TagName := 'transfer_month';
	      vXMLTable(vCtr).TagValue := nvl(to_char(l_tr_date,'MM'),' ');
	      vctr := vctr + 1;

	      vXMLTable(vCtr).TagName := 'transfer_year';
	      vXMLTable(vCtr).TagValue := nvl(to_char(l_tr_date,'YYYY'),' ');
	      vctr := vctr + 1;

	      vXMLTable(vCtr).TagName := 'sector_name';
	      vXMLTable(vCtr).TagValue := nvl(l_sector_name,' ');
	      vctr := vctr + 1;

      End If;

      If l_paid_flag = 'Y' then
	      vXMLTable(vCtr).TagName := 'other_income_flag_y';
	      vXMLTable(vCtr).TagValue := 'X';
	      vctr := vctr + 1;
      End If;

      If l_paid_flag = 'N' then
	      vXMLTable(vCtr).TagName := 'other_income_flag_n';
	      vXMLTable(vCtr).TagValue := 'X';
	      vctr := vctr + 1;
      End If;

      vXMLTable(vCtr).TagName := 'Ex_Employer_name';
      vXMLTable(vCtr).TagValue := l_p_ex_employer;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Basic_Salary';

      BEGIN
      	SELECT nvl(decode(l_basic_val/(abs(decode(l_basic_val,0,1,l_basic_val))*-1),1,'-'||l_fm_l_basic_val,l_fm_l_basic_val),' ')
      	INTO l_fm_l_basic_val
      	FROM dual;

      	EXCEPTION
      		WHEN no_data_found then
      		NULL;
      END;

      vXMLTable(vCtr).TagValue := nvl(l_fm_l_basic_val,' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Allowance_1';

      BEGIN
      	SELECT decode(l_accomodation_val/(abs(decode(l_accomodation_val,0,1,l_accomodation_val))*-1),1,'-'||l_fm_l_accomodation_val,l_fm_l_accomodation_val)
      	INTO l_fm_l_accomodation_val
      	FROM dual;

      	EXCEPTION
      		WHEN no_data_found then
      		NULL;
      END;


      vXMLTable(vCtr).TagValue := l_fm_l_accomodation_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Allowance_2';

      BEGIN
      	SELECT decode(l_allowance_1_val/(abs(decode(l_allowance_1_val,0,1,l_allowance_1_val))*-1),1,'-'||l_fm_l_allowance_1_val,l_fm_l_allowance_1_val)
      	INTO l_fm_l_allowance_1_val
      	FROM dual;

      	EXCEPTION
      		WHEN no_data_found then
      		NULL;
      END;


      vXMLTable(vCtr).TagValue := l_fm_l_allowance_1_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Allowance_3';

            BEGIN
            	SELECT decode(l_allowance_2_val/(abs(decode(l_allowance_2_val,0,1,l_allowance_2_val))*-1),1,'-'||l_fm_l_allowance_2_val,l_fm_l_allowance_2_val)
            	INTO l_fm_l_allowance_2_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_2_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Allowance_4';

            BEGIN
            	SELECT decode(l_allowance_3_val/(abs(decode(l_allowance_3_val,0,1,l_allowance_3_val))*-1),1,'-'||l_fm_l_allowance_3_val,l_fm_l_allowance_3_val)
            	INTO l_fm_l_allowance_3_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_3_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Allowance_5';

            BEGIN
            	SELECT decode(l_allowance_4_val/(abs(decode(l_allowance_4_val,0,1,l_allowance_4_val))*-1),1,'-'||l_fm_l_allowance_4_val,l_fm_l_allowance_4_val)
            	INTO l_fm_l_allowance_4_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_4_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'Allowance_6';

            BEGIN
            	SELECT decode(l_allowance_5_val/(abs(decode(l_allowance_5_val,0,1,l_allowance_5_val))*-1),1,'-'||l_fm_l_allowance_5_val,l_fm_l_allowance_5_val)
            	INTO l_fm_l_allowance_5_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_5_val;
      vctr := vctr + 1;

      l_total := pay_balance_pkg.get_value(l_subject_to_social_id , t_store_assact(j).assignment_action_id);
      l_fm_total_val := to_char(abs(l_total),lg_format_mask);

      vXMLTable(vCtr).TagName := 'total_cont_salary';

            BEGIN
            	SELECT decode(l_total/(abs(decode(l_total,0,1,l_total))*-1),1,'-'||l_fm_total_val,l_fm_total_val)
            	INTO l_fm_total_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue :=  l_fm_total_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'major';
      vXMLTable(vCtr).TagValue :=  l_major;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'from';
      vXMLTable(vCtr).TagValue :=  l_est_name;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'last_qualification';
      vXMLTable(vCtr).TagValue :=  l_p_qual_name;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'per_fax';
      vXMLTable(vCtr).TagValue :=  l_home_fax_number;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'residence_phone';
      vXMLTable(vCtr).TagValue :=  l_home_phone_number;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'residense_address';
      vXMLTable(vCtr).TagValue :=  l_p_address;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'nationality_day';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_nat_date,'DD'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'nationality_month';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_nat_date,'MM'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'nationality_year';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_nat_date,'YYYY'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'how_nationality_obtained';
      vXMLTable(vCtr).TagValue := l_nat_reason;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'uae_civil_reg_number';
      vXMLTable(vCtr).TagValue := l_uae_civil_reg_number;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'gender';
      vXMLTable(vCtr).TagValue := l_gender;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'dob_day';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_dob,'DD'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'dob_month';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_dob,'MM'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'dob_year';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_dob,'YYYY'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'major_spouse';
      vXMLTable(vCtr).TagValue := l_s_major;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'last_qualification_spouse';
      vXMLTable(vCtr).TagValue := l_s_qual;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'employer_name_spouse';
      vXMLTable(vCtr).TagValue := l_s_ex_employer_name;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'number_of_sons';
      vXMLTable(vCtr).TagValue := l_number_of_sons;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'number_of_daughters';
      vXMLTable(vCtr).TagValue := l_number_of_daughters;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'number_of_wives';
      vXMLTable(vCtr).TagValue := l_number_of_wives;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'marital_status';
      vXMLTable(vCtr).TagValue := l_mar_p_status;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'percent';
      vXMLTable(vCtr).TagValue := l_dis_percent;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'disablity_day';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_dis_date,'DD'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'disablity_month';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_dis_date,'MM'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'disablity_year';
      vXMLTable(vCtr).TagValue := nvl(to_char(l_dis_date,'YYYY'),' ');
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'disablity_reason';
      vXMLTable(vCtr).TagValue := l_dis_meaning;
      vctr := vctr + 1;

      j := j + 1;

      vXMLTable(vCtr).TagName := 'PAGE-BK';
      vXMLTable(vCtr).TagValue := '    ';
      vctr := vctr + 1;

      IF j > i THEN
        l_new_processed := 1;
        EXIT;
      END IF;
    END LOOP;

    hr_utility.set_location('Finished creating xml data for Procedure FORM1 ',20);
    WritetoCLOB ( l_xfdf_blob );

EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
  END FORM1;
-------------------------------------------------------------------------------------------
  PROCEDURE FORM2
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS

    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'AE_BG_DETAILS';

    /*Cursor for fetching Employer SSN*/
     CURSOR csr_employer_ssn IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_employer_id
     AND    org_information_context = 'AE_LEGAL_EMPLOYER_DETAILS';

     /*Cursor for fetching Employer Name*/
     CURSOR csr_employer_name IS
     SELECT name
     FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /* Cursor for fetching organization phone types */
    	CURSOR csr_get_org_phone_types (l_bg_id number) IS
    	SELECT  hoi.org_information1,hoi.org_information2,hoi.org_information3,hoi.org_information4
    	FROM	hr_organization_information hoi
    	WHERE 	hoi.organization_id = l_bg_id
    	AND 	hoi.org_information_context = 'AE_HR_BG_INFO';

    /* Cursor for fetching person's phone details */
    	CURSOR csr_p_phone_data (l_person_id number,l_ph_type varchar2,l_effective_date date) IS
    	SELECT  pp.phone_number
    	FROM	per_phones pp,per_all_people_f ppf
    	WHERE 	pp.parent_id = ppf.person_id
    	AND 	pp.phone_type = l_ph_type
    	AND     ppf.person_id = l_person_id
    	AND 	l_effective_date between pp.date_from and nvl(pp.date_to,to_date('31-12-4712','DD-MM-YYYY'));

    /* Cursor for fetching person's Address */
    	CURSOR csr_p_address_data (l_person_id number,l_effective_date date) IS
    	SELECT  substr(addr.ADDRESS_LINE1 || ' ' ||addr.address_line2,1,60)
    	FROM	per_addresses addr
    	WHERE 	addr.person_id = l_person_id
    	AND 	l_effective_date between addr.date_from and nvl(addr.date_to,to_date('31-12-4712','dd-mm-yyyy'))
    	AND     addr.primary_flag = 'Y';

    /* Cursor for fetching the Terminated Employees coming under legal employer*/
	CURSOR csr_get_emp (l_employer_id number, l_effective_date date , l_nat_cd varchar2) IS
    	SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,pos.actual_termination_date
		    ,pos.LEAVING_REASON
                    ,ppa.date_earned
    	FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_all_people_f ppf
    	WHERE  asg.assignment_id = paa.assignment_id
    	AND    paa.payroll_action_id = ppa.payroll_action_id
    	AND    pos.period_of_service_id = asg.period_of_service_id
    	AND    ppa.action_type in ('R','Q')
    	AND    ppa.action_status = 'C'
    	AND    paa.action_status = 'C'
    	AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    	AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') = TRUNC(l_effective_date, 'MM')
    	AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    	AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    	AND    hscl.segment1 = to_char(l_employer_id)
    	AND    ppf.person_id = asg.person_id
    	AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    	AND    ppf.per_information18 = l_nat_cd;

    /* Cursor for fetching the Terminated Employees coming under legal employer*/
	CURSOR csr_get_leav_reas (l_code varchar2) IS
	SELECT hl.meaning
	FROM hr_lookups hl
	WHERE hl.lookup_type = 'LEAV_REAS'
	AND   hl.lookup_code = l_code;

    /* Cursor for fetching the person data */
    	CURSOR csr_p_data (l_person_id number,l_effective_date date) IS
    	SELECT ppf.full_name,ppf.marital_status,ppf.sex
    	FROM	per_all_people_f ppf
    	WHERE 	ppf.person_id = l_person_id
    	AND	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching the person's marital status */
    	CURSOR csr_p_mar_status (l_mar_stat varchar2) IS
    	SELECT hl.meaning
    	FROM	hr_lookups hl
    	WHERE 	hl.lookup_type = 'MAR_STATUS'
    	AND	hl.lookup_code = l_mar_stat
    	AND	hl.enabled_flag = 'Y';

    /* Cursor for fetching the person's assignment data */
    	CURSOR csr_p_asg_data (l_person_id number,l_effective_date date) IS
    	SELECT paf.assignment_id , hsck.segment3,paf.location_id
    	FROM	per_all_assignments_f paf,hr_soft_coding_keyflex hsck
    	WHERE 	paf.person_id = l_person_id
    	AND     paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    	AND     hsck.segment1 = p_employer_id
    	AND	l_effective_date between paf.effective_start_date and paf.effective_end_date;

    /* Cursor for fetching person's contact counts */
    	CURSOR csr_p_contact_count_data (l_person_id number,l_type varchar2, l_gender varchar2, l_effective_date date) IS
    	SELECT  count(*)
    	FROM	per_contact_relationships cont , per_all_people_f ppf
    	WHERE 	cont.person_id = l_person_id
    	AND 	cont.contact_type = l_type
    	AND     ppf.person_id = cont.CONTACT_PERSON_ID
    	AND  	ppf.sex = l_gender
    	AND 	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching External account id and org payment method id*/
    	CURSOR csr_get_ext_id_org_paymeth (l_assignment_id number,l_effective_date date) IS
    	SELECT  external_account_id,org_payment_method_id
    	FROM	pay_personal_payment_methods_f
    	WHERE 	assignment_id = l_assignment_id
    	AND 	l_effective_date between effective_start_date and effective_end_date
    	AND	ppm_information_category = 'AE_AE DIRECT DEPOSIT AED'
    	AND	ppm_information1 = 'Y';

    /* Cursor for fetching external account id for org payment method*/
    	CURSOR csr_get_ext_id (l_org_paymeth_id number,l_effective_date date) IS
    	SELECT  external_account_id
    	FROM	pay_org_payment_methods_f pom
    	WHERE 	pom.org_payment_method_id = l_org_paymeth_id
    	And	l_effective_date between effective_start_date and effective_end_date;

    /* Cursor for fetching Bank details for external account id*/
    	CURSOR csr_get_bank_det_ext (l_external_account_id number) IS
    	SELECT  segment1,segment2,segment4
    	FROM	pay_external_accounts
    	WHERE 	external_account_id = l_external_account_id;

    /* Cursor for fetching the Bank name */
       CURSOR csr_get_bank_name (l_code VARCHAR2) IS
       SELECT hl.meaning
       FROM   hr_lookups hl
       WHERE  hl.lookup_type = 'AE_BANK_NAMES'
       AND    hl.lookup_code = l_code
       AND    hl.enabled_flag = 'Y';

    /* Cursor for fetching the Branch name */
       CURSOR csr_get_branch_name (l_code VARCHAR2) IS
       SELECT hl.meaning
       FROM   hr_lookups hl
       WHERE  hl.lookup_type = 'AE_BRANCH_NAMES'
       AND    hl.lookup_code = l_code
       AND    hl.enabled_flag = 'Y';

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_bg_id number) IS
        SELECT  ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3,ORG_INFORMATION4,ORG_INFORMATION5,ORG_INFORMATION6,ORG_INFORMATION7,ORG_INFORMATION8,ORG_INFORMATION9,ORG_INFORMATION10 ,ORG_INFORMATION11
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_bg_id
        AND	org_information_context = 'AE_SI_DETAILS';

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_def_bal_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'AE'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    TYPE def_bal_rec IS RECORD
    (def_bal_id                  NUMBER
    ,label_index		 VARCHAR2(40));
    TYPE t_def_bal_table IS TABLE OF def_bal_rec INDEX BY BINARY_INTEGER;
    t_store_def_bal   t_def_bal_table;
    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,actual_term_date          DATE
    ,leaving_reason            VARCHAR2(100)
    ,date_earned                DATE);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;
    l_employer_name varchar2(240);
    l_input_date varchar2(30);
    l_effective_date date;
    l_employer_ssn number;
    l_basic_sal_id number;
    z number;
    l_accomodation_id number;
    l_social_id number;
    l_child_social_id number;
    l_tp_id number;
    l_ol1_id number;
    l_ol2_id number;
    l_ol3_id number;
    l_ol4_id number;
    l_cost_of_living_id number;
    l_index number;
    i number;
    k number;
    m number;
    j number;
    x number;
    l_new_processed number;
    l_all_processed number;
    l_new_count number;
    l_basic_val number(12,2);
    l_accomodation_val number(12,2);
    l_allowance_1_val number(12,2);
    l_allowance_2_val number(12,2);
    l_allowance_3_val number(12,2);
    l_allowance_4_val number(12,2);
    l_allowance_5_val number(12,2);
    l number;
    L_FULL_NAME varchar2(240);
    l_insured_ssn number;
    l_uae_civil_reg_number number;
    l_asg_location_id number;
    l_work_emirate varchar2(100);
    l_home_phone_number varchar2(100);
    l_home_fax_number varchar2(100);
    L_MARITAL_STATUS varchar2(100);
    l_mar_p_status varchar2(30);
    l_asg_id number;
    l_gender varchar2(100);
    l_p_address varchar2(240);
    l_number_of_sons number;
    l_number_of_daughters number;
    l_number_of_wives number;
    l_home_phone varchar2(100);
    l_work_phone varchar2(100);
    l_work_fax varchar2(100);
    l_home_fax varchar2(100);
    L_TOTAL number(12,2);
    L_FM_TOTAL_VAL varchar2(100);
    l_fm_l_basic_val varchar2(100);
    L_FM_L_ACCOMODATION_VAL varchar2(100);
    L_FM_L_ALLOWANCE_1_VAL varchar2(100);
    L_FM_L_ALLOWANCE_2_VAL varchar2(100);
    L_FM_L_ALLOWANCE_3_VAL varchar2(100);
    L_FM_L_ALLOWANCE_4_VAL varchar2(100);
    L_FM_L_ALLOWANCE_5_VAL varchar2(100);
    l_fm_ee_arrears varchar2(100);
    l_ee_arrears number(12,2);
    l_bank_name varchar2(80);
    l_bank_branch_name varchar2(80);
    l_seg1 varchar2(30);
    l_seg2 varchar2(30);
    l_seg4 varchar2(100);
    l_org_ext_act_id number;
    l_ext_act_id number;
    l_org_pm_id number;
    l_no_flag varchar2(1);
    l_arrears_def_bal_id number;
    l_subject_si_id number;
    rec_get_emp        csr_get_emp%ROWTYPE;
    l_leaving_reason varchar2(100);
    l_ded_id number;
    l_ded_val number(15,2);
    l_fm_l_ded_val varchar2(100);
    l_nat_cd varchar2(30);

  BEGIN

    set_currency_mask(p_business_group_id);
    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));

    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);

    -- To clear the PL/SQL Table values.
    vXMLTable.DELETE;
    vCtr := 1;
    hr_utility.set_location('Entering FORM1 ',10);

    /* Fetch local nationality */
    OPEN csr_get_loc_nat;
    FETCH csr_get_loc_nat into l_nat_cd;
    CLOSE csr_get_loc_nat;


      /*Fetch Employer SSN*/
      OPEN csr_employer_ssn;
      FETCH csr_employer_ssn INTO l_employer_ssn;
      CLOSE csr_employer_ssn;

      /*Fetch Employer Name*/
      OPEN csr_employer_name;
      FETCH csr_employer_name INTO l_employer_name;
      CLOSE csr_employer_name;

    OPEN csr_get_def_bal_ids (p_employer_id);
    FETCH csr_get_def_bal_ids into l_basic_sal_id,l_accomodation_id,l_social_id,l_child_social_id,l_cost_of_living_id,l_ol1_id,l_tp_id,l_ol2_id,l_ol3_id,l_ol4_id,l_ded_id;
    CLOSE csr_get_def_bal_ids;

    z := 1;
    t_store_def_bal(z).def_bal_id := l_basic_sal_id;
    t_store_def_bal(z).label_index := get_index(1);

    z:= z+1;
    t_store_def_bal(z).def_bal_id := l_accomodation_id;
    t_store_def_bal(z).label_index := get_index(2);

    z := z + 1;
    l_index := 2;

    LOOP
    	If l_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_social_id;
    		t_store_def_bal(z).label_index := get_index(3);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;

    	If l_child_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_child_social_id;
    		t_store_def_bal(z).label_index := get_index(4);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;

    	If l_cost_of_living_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_cost_of_living_id;
    		t_store_def_bal(z).label_index := get_index(5);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;

    	If l_tp_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_tp_id;
    	        t_store_def_bal(z).label_index := get_index(6);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;

    	If l_ol1_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol1_id;
    		t_store_def_bal(z).label_index := get_index(7);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;

    	If l_ol2_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol2_id;
		t_store_def_bal(z).label_index := get_index(8);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;

    	If l_ol3_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol3_id;
    		t_store_def_bal(z).label_index := get_index(9);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;

    	If l_ol4_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol4_id;
    		t_store_def_bal(z).label_index := get_index(10);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;

    	If z <7 then
    		WHILE Z <= 7 LOOP
    			t_store_def_bal(z).def_bal_id := NULL;
    			t_store_def_bal(z).label_index := get_index(11);
    			z := z + 1;
    			EXIT WHEN z > 7;
    		END LOOP;
	End If;
    	EXIT WHEN z >=7;
    END LOOP;

    l := 3;
    i := 0;
    k := 0;
    m := 0;

    OPEN csr_get_emp(p_employer_id , l_effective_date,l_nat_cd);
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      i := i + 1;
      t_store_assact(i).person_id := rec_get_emp.person_id;
      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
      t_store_assact(i).actual_term_date := rec_get_emp.actual_termination_date;
      t_store_assact(i).leaving_reason := rec_get_emp.LEAVING_REASON;
      t_store_assact(i).date_earned := rec_get_emp.date_earned;
    END LOOP;
    CLOSE csr_get_emp;

    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;

    l_all_processed := 0;
        j := 1;
    WHILE j <= i LOOP
/********* Reset all the local variables **********/
l_full_name := null;
l_marital_status := null;
l_mar_p_status := null;
l_gender := null;
l_insured_ssn := null;
l_asg_location_id := null;
l_asg_id := null;
l_work_emirate := null;
l_home_phone := null;
l_home_fax := null;
l_home_phone_number := null;
l_home_fax_number := null;
l_p_address := null;
l_number_of_wives := null;
l_number_of_sons := null;
l_number_of_daughters := null;
l_bank_name := null;
l_bank_branch_name := null;
l_seg1 := null;
l_seg2 := null;
l_seg4 := null;
l_org_ext_act_id := null;
l_ext_act_id := null;
l_org_pm_id := null;
l_arrears_def_bal_id := null;
l_no_flag := null;

      OPEN csr_p_data(t_store_assact(j).person_id,l_effective_date);
      FETCH csr_p_data INTO l_full_name,l_marital_status,l_gender;
      CLOSE csr_p_data;

      OPEN csr_p_mar_status(l_marital_status);
      FETCH csr_p_mar_status into l_mar_p_status;
      CLOSE csr_p_mar_status;

      OPEN csr_p_asg_data(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_p_asg_data into l_asg_id , l_insured_ssn,l_asg_location_id;
      CLOSE csr_p_asg_data;

      OPEN csr_get_org_phone_types (p_business_group_id);
      FETCH csr_get_org_phone_types into l_home_phone,l_work_phone,l_home_fax,l_work_fax;
      CLOSE csr_get_org_phone_types;

      OPEN csr_p_phone_data(t_store_assact(j).person_id,'H1',l_effective_date);
      FETCH csr_p_phone_data into l_home_phone_number;
      CLOSE csr_p_phone_data;

      OPEN csr_p_phone_data(t_store_assact(j).person_id,'HF',l_effective_date);
      FETCH csr_p_phone_data into l_home_fax_number;
      CLOSE csr_p_phone_data;

      OPEN csr_p_address_data (t_store_assact(j).person_id,l_effective_date);
      FETCH csr_p_address_data into l_p_address;
      CLOSE csr_p_address_data;
      IF l_gender = 'M' then
      	OPEN csr_p_contact_count_data(t_store_assact(j).person_id,'S','F',l_effective_date);
      	FETCH csr_p_contact_count_data into l_number_of_wives;
      	CLOSE csr_p_contact_count_data;
      Else
      	l_number_of_wives := 0;
      END IF;
      OPEN csr_p_contact_count_data(t_store_assact(j).person_id,'C','M',l_effective_date);
      FETCH csr_p_contact_count_data into l_number_of_sons;
      CLOSE csr_p_contact_count_data;
      OPEN csr_p_contact_count_data(t_store_assact(j).person_id,'C','F',l_effective_date);
      FETCH csr_p_contact_count_data into l_number_of_daughters;
      CLOSE csr_p_contact_count_data;
      OPEN csr_get_ext_id_org_paymeth(l_asg_id,l_effective_date);
      FETCH csr_get_ext_id_org_paymeth into l_ext_act_id , l_org_pm_id;
      CLOSE csr_get_ext_id_org_paymeth;
      If l_ext_act_id is null and l_org_pm_id is null then
      	l_no_flag := 'Y';
      Else
      	l_no_flag := 'N';
      End If;
      If l_ext_act_id is null then
      	OPEN csr_get_ext_id(l_org_pm_id,l_effective_date);
      	FETCH csr_get_ext_id into l_org_ext_act_id;
      	CLOSE csr_get_ext_id;
      	OPEN csr_get_bank_det_ext (l_org_ext_act_id);
      	FETCH csr_get_bank_det_ext into l_seg1,l_seg2,l_seg4;
      	CLOSE csr_get_bank_det_ext;
      Else
      	OPEN csr_get_bank_det_ext (l_ext_act_id);
        FETCH csr_get_bank_det_ext into l_seg1,l_seg2,l_seg4;
      	CLOSE csr_get_bank_det_ext;
      End If;
      OPEN csr_get_bank_name (l_seg1);
      FETCH csr_get_bank_name into l_bank_name;
      CLOSE csr_get_bank_name;
      OPEN csr_get_branch_name (l_seg2);
      FETCH csr_get_branch_name into l_bank_branch_name;
      CLOSE csr_get_branch_name;
      OPEN csr_get_def_bal_id ('EMPLOYEE_SOCIAL_INSURANCE_ARREARS_ASG_ITD');
      FETCH csr_get_def_bal_id into l_arrears_def_bal_id;
      CLOSE csr_get_def_bal_id;
      OPEN csr_get_def_bal_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
      FETCH csr_get_def_bal_id into l_subject_si_id;
      CLOSE csr_get_def_bal_id;

      l_basic_val := 0;
      l_accomodation_val := 0;
      l_allowance_1_val := 0;
      l_allowance_2_val := 0;
      l_allowance_3_val := 0;
      l_allowance_4_val := 0;
      l_allowance_5_val := 0;

      l_ded_val := 0;

      If l_ded_id is not null then
      		l_ded_val := pay_balance_pkg.get_value(l_ded_id,t_store_assact(j).assignment_action_id);
      End if;

      x := 1;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_basic_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_basic_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_accomodation_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_accomodation_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_1_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_1_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_2_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_2_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_3_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_3_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_4_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
      ELSE
      		l_allowance_4_val := 0;
      END IF;
      l_new_count := l_new_count+1;
      l_fm_l_basic_val := to_char(abs(l_basic_val),lg_format_mask);
      l_fm_l_accomodation_val := to_char(abs(l_accomodation_val),lg_format_mask);
      l_fm_l_allowance_1_val := to_char(abs(l_allowance_1_val),lg_format_mask);
      l_fm_l_allowance_2_val := to_char(abs(l_allowance_2_val),lg_format_mask);
      l_fm_l_allowance_3_val := to_char(abs(l_allowance_3_val),lg_format_mask);
      l_fm_l_allowance_4_val := to_char(abs(l_allowance_4_val),lg_format_mask);

      l_fm_l_ded_val := to_char(abs(l_ded_val),lg_format_mask);


      If l_arrears_def_bal_id is not null then
      	l_ee_arrears := pay_balance_pkg.get_value(l_arrears_def_bal_id,t_store_assact(j).assignment_action_id);
      Else
      	l_ee_arrears := 0;
      End If;
      l_fm_ee_arrears := to_char(abs(l_ee_arrears),lg_format_mask);
      /** Populate the XML file **/
      vXMLTable(vCtr).TagName := 'Employer_ssn';
      vXMLTable(vCtr).TagValue := l_employer_ssn;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'Employer_name';
      vXMLTable(vCtr).TagValue := l_employer_name;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'Employee_ssn';
      vXMLTable(vCtr).TagValue := l_insured_ssn;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'Employee_name';
      vXMLTable(vCtr).TagValue := SUBSTR(l_full_name,1,60);
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'Employee_fax';
      vXMLTable(vCtr).TagValue :=  l_home_fax_number;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'Employee_phone';
      vXMLTable(vCtr).TagValue :=  l_home_phone_number;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'Address';
      vXMLTable(vCtr).TagValue :=  nvl(l_p_address,' ');
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'basic_salary';

            BEGIN
            	SELECT decode(l_basic_val/(abs(decode(l_basic_val,0,1,l_basic_val))*-1),1,'-'||l_fm_l_basic_val,l_fm_l_basic_val)
            	INTO l_fm_l_basic_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_basic_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'housing_allowance';

            BEGIN
            	SELECT decode(l_accomodation_val/(abs(decode(l_accomodation_val,0,1,l_accomodation_val))*-1),1,'-'||l_fm_l_accomodation_val,l_fm_l_accomodation_val)
            	INTO l_fm_l_accomodation_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_accomodation_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'allowance_1';

            BEGIN
            	SELECT decode(l_allowance_1_val/(abs(decode(l_allowance_1_val,0,1,l_allowance_1_val))*-1),1,'-'||l_fm_l_allowance_1_val,l_fm_l_allowance_1_val)
            	INTO l_fm_l_allowance_1_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_1_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'allowance_2';

            BEGIN
            	SELECT decode(l_allowance_2_val/(abs(decode(l_allowance_2_val,0,1,l_allowance_2_val))*-1),1,'-'||l_fm_l_allowance_2_val,l_fm_l_allowance_2_val)
            	INTO l_fm_l_allowance_2_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_2_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'allowance_3';

            BEGIN
            	SELECT decode(l_allowance_3_val/(abs(decode(l_allowance_3_val,0,1,l_allowance_3_val))*-1),1,'-'||l_fm_l_allowance_3_val,l_fm_l_allowance_3_val)
            	INTO l_fm_l_allowance_3_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_3_val;
      vctr := vctr + 1;

      vXMLTable(vCtr).TagName := 'allowance_4';

            BEGIN
            	SELECT decode(l_allowance_4_val/(abs(decode(l_allowance_4_val,0,1,l_allowance_4_val))*-1),1,'-'||l_fm_l_allowance_4_val,l_fm_l_allowance_4_val)
            	INTO l_fm_l_allowance_4_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue := l_fm_l_allowance_4_val;
      vctr := vctr + 1;

      --l_total := l_basic_val + l_accomodation_val + l_allowance_1_val + l_allowance_2_val + l_allowance_3_val + l_allowance_4_val+l_allowance_5_val;

      l_total := pay_balance_pkg.get_value(l_subject_si_id,t_store_assact(j).assignment_action_id);

      l_fm_total_val := to_char(abs(l_total),lg_format_mask);

      vXMLTable(vCtr).TagName := 'contributory_salary_at_termination';

            BEGIN
            	SELECT decode(l_total/(abs(decode(l_total,0,1,l_total))*-1),1,'-'||l_fm_total_val,l_fm_total_val)
            	INTO l_fm_total_val
            	FROM dual;

            	EXCEPTION
            		WHEN no_data_found then
            		NULL;
            END;

      vXMLTable(vCtr).TagValue :=  l_fm_total_val;
      vctr := vctr + 1;


      OPEN csr_get_leav_reas (t_store_assact(j).leaving_reason);
      FETCH csr_get_leav_reas into l_leaving_reason;
      CLOSE csr_get_leav_reas;

      vXMLTable(vCtr).TagName := 'termination_reason';
      vXMLTable(vCtr).TagValue := nvl(l_leaving_reason,' ');
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'termination_day';
      vXMLTable(vCtr).TagValue := nvl(to_char(t_store_assact(j).actual_term_date,'DD'),' ');
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'termination_month';
      vXMLTable(vCtr).TagValue := nvl(to_char(t_store_assact(j).actual_term_date,'MM'),' ');
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'termination_year';
      vXMLTable(vCtr).TagValue := nvl(to_char(t_store_assact(j).actual_term_date,'YYYY'),' ');
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'number_of_sons';
      vXMLTable(vCtr).TagValue := l_number_of_sons;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'number_of_daughters';
      vXMLTable(vCtr).TagValue := l_number_of_daughters;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'number_of_wives';
      vXMLTable(vCtr).TagValue := l_number_of_wives;
      vctr := vctr + 1;
      vXMLTable(vCtr).TagName := 'marital_status';
      vXMLTable(vCtr).TagValue := l_mar_p_status;
      vctr := vctr + 1;
      If l_no_flag = 'Y' then
	      vXMLTable(vCtr).TagName := 'collect_EOS_pension_n';
	      vXMLTable(vCtr).TagValue := 'X';
	      vctr := vctr + 1;
      Else
	      vXMLTable(vCtr).TagName := 'collect_EOS_pension_y';
	      vXMLTable(vCtr).TagValue := 'X';
	      vctr := vctr + 1;
	      vXMLTable(vCtr).TagName := 'account_number_pension';
	      vXMLTable(vCtr).TagValue := l_seg4;
	      vctr := vctr + 1;
	      vXMLTable(vCtr).TagName := 'branch_pension';
	      vXMLTable(vCtr).TagValue := l_bank_branch_name;
	      vctr := vctr + 1;
	      vXMLTable(vCtr).TagName := 'bank_pension';
	      vXMLTable(vCtr).TagValue := l_bank_name;
	      vctr := vctr + 1;
      End If;

      If l_ee_arrears <>0 then
      	vXMLTable(vCtr).TagName := 'deduction_type_1';
      	vXMLTable(vCtr).TagValue := get_lookup_meaning('AE_FORM_LABELS','ARR_LABEL');
      	vctr := vctr + 1;

      	vXMLTable(vCtr).TagName := 'dinars_1';
      	vXMLTable(vCtr).TagValue := substr(l_fm_ee_arrears,1,length(l_fm_ee_arrears)-3);
      	vctr := vctr + 1;

      	vXMLTable(vCtr).TagName := 'fills_1';
      	vXMLTable(vCtr).TagValue := substr(l_fm_ee_arrears,length(l_fm_ee_arrears)-1);
      	vctr := vctr + 1;
      End If;

      If l_ee_arrears <> 0 and l_ded_val <> 0 then
      	vXMLTable(vCtr).TagName := 'deduction_type_2';
      	vXMLTable(vCtr).TagValue := get_lookup_meaning('AE_FORM_LABELS','OTH_DED');
      	vctr := vctr + 1;

      	vXMLTable(vCtr).TagName := 'dinars_2';
      	vXMLTable(vCtr).TagValue := substr(l_fm_l_ded_val,1,length(l_fm_l_ded_val)-3);
      	vctr := vctr + 1;

      	vXMLTable(vCtr).TagName := 'fills_2';
      	vXMLTable(vCtr).TagValue := substr(l_fm_l_ded_val,length(l_fm_l_ded_val)-1);
      	vctr := vctr + 1;
      ElsIf l_ee_arrears = 0 and l_ded_val <> 0 then
      	vXMLTable(vCtr).TagName := 'deduction_type_1';
	vXMLTable(vCtr).TagValue := get_lookup_meaning('AE_FORM_LABELS','OTH_DED');
	vctr := vctr + 1;

	vXMLTable(vCtr).TagName := 'dinars_1';
	vXMLTable(vCtr).TagValue := substr(l_fm_l_ded_val,1,length(l_fm_l_ded_val)-3);
	vctr := vctr + 1;

	vXMLTable(vCtr).TagName := 'fills_1';
	vXMLTable(vCtr).TagValue := substr(l_fm_l_ded_val,length(l_fm_l_ded_val)-1);
      	vctr := vctr + 1;
      End If;

      j := j + 1;
      vXMLTable(vCtr).TagName := 'PAGE-BK';
      vXMLTable(vCtr).TagValue := '    ';
      vctr := vctr + 1;
      IF j > i THEN
        l_new_processed := 1;
        EXIT;
      END IF;
    END LOOP;
    hr_utility.set_location('Finished creating xml data for Procedure FORM1 ',20);
    WritetoCLOB ( l_xfdf_blob );
EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
  END FORM2;
-------------------------------------------------------------------------------------------
  PROCEDURE FORM6
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS

    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'AE_BG_DETAILS';

    /*Cursor for fetching Employer SSN*/
     CURSOR csr_employer_ssn IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_employer_id
     AND    org_information_context = 'AE_LEGAL_EMPLOYER_DETAILS';

     /*Cursor for fetching Employer Name*/
     CURSOR csr_employer_name IS
     SELECT name
     FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

     /*Cursor for fetching employees*/
    CURSOR csr_get_emp (l_employer number , l_date date , l_nat_cd varchar2) IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,ppa.date_earned
    FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_all_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.per_information18 = l_nat_cd;

    /* Cursor for fetching the person data */
    	CURSOR csr_get_person_data (l_person_id number,l_effective_date date) IS
    	SELECT ppf.full_name
    	FROM	per_all_people_f ppf
    	WHERE 	ppf.person_id = l_person_id
    	AND	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching the person's assignment data */
    	CURSOR csr_get_person_asg_data (l_person_id number,l_effective_date date) IS
    	SELECT hsck.segment3
    	FROM	per_all_assignments_f paf,hr_soft_coding_keyflex hsck
    	WHERE 	paf.person_id = l_person_id
    	AND     paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    	AND     hsck.segment1 = p_employer_id
    	AND	l_effective_date between paf.effective_start_date and paf.effective_end_date;

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_bg_id number) IS
        SELECT  ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3,ORG_INFORMATION4,ORG_INFORMATION5,ORG_INFORMATION6,ORG_INFORMATION7,ORG_INFORMATION8,ORG_INFORMATION9,ORG_INFORMATION10
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_bg_id
        AND	org_information_context = 'AE_SI_DETAILS';

    /* Cursor for fetching Subject to SI defined balance ID */
    CURSOR csr_get_si_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'AE'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    TYPE def_bal_rec IS RECORD
    (def_bal_id                  NUMBER
    ,label_index		 VARCHAR2(40));
    TYPE t_def_bal_table IS TABLE OF def_bal_rec INDEX BY BINARY_INTEGER;
    t_store_def_bal   t_def_bal_table;
    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,date_start                DATE);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;
    l_employer_name varchar2(240);
    l_input_date varchar2(30);
    l_effective_date date;
    l_employer_ssn number;
    l_basic_sal_id number;
    z number;
    l_accomodation_id number;
    l_social_id number;
    l_child_social_id number;
    l_tp_id number;
    l_ol1_id number;
    l_ol2_id number;
    l_ol3_id number;
    l_ol4_id number;
    l_cost_of_living_id number;
    l_index number;
    i number;
    k number;
    m number;
    j number;
    x number;
    l_new_processed number;
    l_all_processed number;
    l_new_count number;
    l_basic_val number(15,2);
    l_accomodation_val number(15,2);
    l_allowance_1_val number(15,2);
    l_allowance_2_val number(15,2);
    l_allowance_3_val number(15,2);
    l_allowance_4_val number(15,2);
    l number;
    l_tot_count number;
    L_FULL_NAME varchar2(240);
    l_insured_ssn varchar2(30);
    L_TOTAL number(15,2);
    L_FM_TOTAL_VAL varchar2(100);
    l_fm_l_basic_val varchar2(100);
    L_FM_L_ACCOMODATION_VAL varchar2(100);
    L_FM_L_ALLOWANCE_1_VAL varchar2(100);
    L_FM_L_ALLOWANCE_2_VAL varchar2(100);
    L_FM_L_ALLOWANCE_3_VAL varchar2(100);
    L_FM_L_ALLOWANCE_4_VAL varchar2(100);
    rec_get_emp        csr_get_emp%ROWTYPE;
    l_xfdf_string              CLOB;
    l_str_er_name varchar2(240);
    l_str_er_ssn varchar2(240);
    l_str_ee_name varchar2(240);
    l_str_ee_ssn varchar2(240);
    l_str_year varchar2(240);
    l_str_seq_no varchar2(240);
    l_str_bsd varchar2(240);
    l_str_bsf varchar2(240);
    l_str_aad varchar2(240);
    l_str_aaf varchar2(240);
    l_str_a1d varchar2(240);
    l_str_a1f varchar2(240);
    l_str_a2d varchar2(240);
    l_str_a2f varchar2(240);
    l_str_a3d varchar2(240);
    l_str_a3f varchar2(240);
    l_str_a4d varchar2(240);
    l_str_a4f varchar2(240);
    l_str_a5d varchar2(240);
    l_str_a5f varchar2(240);
    l_subject_si_id number;
    l_nat_cd varchar2(30);
    l_str_pb varchar2(240);
    l_str_mon varchar2(240);
    l_str_dd varchar2(240);

  BEGIN
    set_currency_mask(p_business_group_id);
    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);
    hr_utility.set_location('Entering FORM6 ',10);

    /* Fetch Local Nationality */
    OPEN csr_get_loc_nat;
    FETCH csr_get_loc_nat INTO l_nat_cd;
    CLOSE csr_get_loc_nat;

    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);

    dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');

    OPEN csr_get_def_bal_ids (p_employer_id);
    FETCH csr_get_def_bal_ids into l_basic_sal_id,l_accomodation_id,l_social_id,l_child_social_id,l_cost_of_living_id,l_ol1_id,l_tp_id,l_ol2_id,l_ol3_id,l_ol4_id;
    CLOSE csr_get_def_bal_ids;

    z := 1;
    t_store_def_bal(z).def_bal_id := l_basic_sal_id;
    t_store_def_bal(z).label_index := get_index(1);
    z:= z+1;
    t_store_def_bal(z).def_bal_id := l_accomodation_id;
    t_store_def_bal(z).label_index := get_index(2);
    z := z + 1;
    l_index := 2;
    LOOP
   	If l_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_social_id;
    		t_store_def_bal(z).label_index := get_index(3);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_child_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_child_social_id;
    		t_store_def_bal(z).label_index := get_index(4);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;
    	If l_cost_of_living_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_cost_of_living_id;
    		t_store_def_bal(z).label_index := get_index(5);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_tp_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_tp_id;
    	        t_store_def_bal(z).label_index := get_index(6);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;
    	If l_ol1_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol1_id;
    		t_store_def_bal(z).label_index := get_index(7);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol2_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol2_id;
		t_store_def_bal(z).label_index := get_index(8);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol3_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol3_id;
    		t_store_def_bal(z).label_index := get_index(9);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol4_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol4_id;
    		t_store_def_bal(z).label_index := get_index(10);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If z < 7 then
    		WHILE Z <= 7 LOOP
    			t_store_def_bal(z).def_bal_id := NULL;
    			t_store_def_bal(z).label_index := get_index(11);
    			z := z + 1;
    			EXIT WHEN z > 7;
    		END LOOP;
	End If;
    	EXIT WHEN z >= 7;
    END LOOP;
    i := 0;
    k := 0;
    m := 0;

    OPEN csr_get_emp(p_employer_id , l_effective_date, l_nat_cd);
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      i := i + 1;
      t_store_assact(i).person_id := rec_get_emp.person_id;
      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
      t_store_assact(i).date_start := rec_get_emp.date_earned;
    END LOOP;
    CLOSE csr_get_emp;

        /*Fetch Defined Balance Id*/
    OPEN csr_get_si_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_si_id INTO l_subject_si_id;
    CLOSE csr_get_si_id;

    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;
    l_all_processed := 0;
        j := 1;
        l := 1;

	l_tot_count := 0;

    WHILE l_all_processed  <> 1 LOOP
    --Writing data for new employees
    l_new_count := 0;
      dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
    WHILE j <= i LOOP
/**** RESET ALL THE VARIABLES *****/
      l_basic_val := 0;
      l_accomodation_val := 0;
      l_allowance_1_val := 0;
      l_allowance_2_val := 0;
      l_allowance_3_val := 0;
      l_allowance_4_val := 0;
      l_total := 0;
      x := 1;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_basic_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_basic_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_accomodation_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_accomodation_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_1_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_1_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_2_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_2_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_3_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_3_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_4_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
      ELSE
      		l_allowance_4_val := 0;
      END IF;

      l_new_count := l_new_count+1;
      l_tot_count := l_tot_count + 1;

      l_fm_l_basic_val := to_char(abs(l_basic_val),lg_format_mask);
      l_fm_l_accomodation_val := to_char(abs(l_accomodation_val),lg_format_mask);
      l_fm_l_allowance_1_val := to_char(abs(l_allowance_1_val),lg_format_mask);
      l_fm_l_allowance_2_val := to_char(abs(l_allowance_2_val),lg_format_mask);
      l_fm_l_allowance_3_val := to_char(abs(l_allowance_3_val),lg_format_mask);
      l_fm_l_allowance_4_val := to_char(abs(l_allowance_4_val),lg_format_mask);
      l_total := pay_balance_pkg.get_value(l_subject_si_id,t_store_assact(j).assignment_action_id);
      l_fm_total_val := to_char(abs(l_total),lg_format_mask);

      BEGIN

            	SELECT decode(l_basic_val/(abs(decode(l_basic_val,0,1,l_basic_val))*-1),1,'-'||l_fm_l_basic_val,l_fm_l_basic_val)
            	INTO l_fm_l_basic_val
            	FROM dual;

            	SELECT decode(l_accomodation_val/(abs(decode(l_accomodation_val,0,1,l_accomodation_val))*-1),1,'-'||l_fm_l_accomodation_val,l_fm_l_accomodation_val)
            	INTO l_fm_l_accomodation_val
            	FROM dual;

            	SELECT decode(l_allowance_1_val/(abs(decode(l_allowance_1_val,0,1,l_allowance_1_val))*-1),1,'-'||l_fm_l_allowance_1_val,l_fm_l_allowance_1_val)
            	INTO l_fm_l_allowance_1_val
            	FROM dual;

            	SELECT decode(l_allowance_2_val/(abs(decode(l_allowance_2_val,0,1,l_allowance_2_val))*-1),1,'-'||l_fm_l_allowance_2_val,l_fm_l_allowance_2_val)
            	INTO l_fm_l_allowance_2_val
            	FROM dual;

            	SELECT decode(l_allowance_3_val/(abs(decode(l_allowance_3_val,0,1,l_allowance_3_val))*-1),1,'-'||l_fm_l_allowance_3_val,l_fm_l_allowance_3_val)
            	INTO l_fm_l_allowance_3_val
            	FROM dual;

            	SELECT decode(l_allowance_4_val/(abs(decode(l_allowance_4_val,0,1,l_allowance_4_val))*-1),1,'-'||l_fm_l_allowance_4_val,l_fm_l_allowance_4_val)
            	INTO l_fm_l_allowance_4_val
            	FROM dual;

            	SELECT decode(l_total/(abs(decode(l_total,0,1,l_total))*-1),1,'-'||l_fm_total_val,l_fm_total_val)
            	INTO l_fm_total_val
            	FROM dual;

      EXCEPTION
      		WHEN no_data_found then
      			null;
      END;

      OPEN csr_get_person_data(t_store_assact(j).person_id,l_effective_date);
      FETCH csr_get_person_data INTO l_full_name;
      CLOSE csr_get_person_data;

      OPEN csr_get_person_asg_data(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_get_person_asg_data into l_insured_ssn;
      CLOSE csr_get_person_asg_data;

      l_str_er_name := '<ERNAME>'||l_employer_name||'</ERNAME>';
      l_str_er_ssn :=  '<ERSSN>'||l_employer_ssn||'</ERSSN>';
      l_str_year := '<YEAR>'||substr(p_effective_year,4,1)||'</YEAR>';
      l_str_mon  := '<MM>' || p_effective_month || '</MM>';
      l_str_dd  := '<DD>' || '01' || '</DD>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn), l_str_er_ssn);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_mon), l_str_mon);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_dd), l_str_dd);
      l_str_seq_no := '<SER-' || l ||'>'||l_tot_count||'</SER-'|| l || '>';
      l_str_ee_ssn :=  '<EMPLOYEE-SSN-' || l || '>'||l_insured_ssn ||'</EMPLOYEE-SSN-' || l || '>';
      l_str_ee_name := '<EMPLOYEE-NAME-'|| l || '>'|| substr(l_full_name,1,60) ||'</EMPLOYEE-NAME-'|| l || '>';
      l_str_bsd := '<BASIC-SALARY-DINARS-' || l ||'>'||substr(l_fm_l_basic_val,1,length(l_fm_l_basic_val)-3)||'</BASIC-SALARY-DINARS-'|| l || '>';
      l_str_bsf := '<BASIC-SALARY-FILLS-' || l ||'>'||substr(l_fm_l_basic_val,length(l_fm_l_basic_val)-1)||'</BASIC-SALARY-FILLS-'|| l || '>';
      l_str_aad := '<AA-DINARS-' || l ||'>'||substr(l_fm_l_accomodation_val,1,length(l_fm_l_accomodation_val)-3)||'</AA-DINARS-'|| l || '>';
      l_str_aaf := '<AA-FILLS-' || l ||'>'||substr(l_fm_l_accomodation_val,length(l_fm_l_accomodation_val)-1)||'</AA-FILLS-'|| l || '>';
      l_str_a1d := '<A1-DINARS-' || l ||'>'||substr(l_fm_l_allowance_1_val,1,length(l_fm_l_allowance_1_val)-3)||'</A1-DINARS-'|| l || '>';
      l_str_a1f := '<A1-FILLS-' || l ||'>'||substr(l_fm_l_allowance_1_val,length(l_fm_l_allowance_1_val)-1)||'</A1-FILLS-'|| l || '>';
      l_str_a2d := '<A2-DINARS-' || l ||'>'||substr(l_fm_l_allowance_2_val,1,length(l_fm_l_allowance_2_val)-3)||'</A2-DINARS-'|| l || '>';
      l_str_a2f := '<A2-FILLS-' || l ||'>'||substr(l_fm_l_allowance_2_val,length(l_fm_l_allowance_2_val)-1)||'</A2-FILLS-'|| l || '>';
      l_str_a3d := '<A3-DINARS-' || l ||'>'||substr(l_fm_l_allowance_3_val,1,length(l_fm_l_allowance_3_val)-3)||'</A3-DINARS-'|| l || '>';
      l_str_a3f := '<A3-FILLS-' || l ||'>'||substr(l_fm_l_allowance_3_val,length(l_fm_l_allowance_3_val)-1)||'</A3-FILLS-'|| l || '>';
      l_str_a4d := '<A4-DINARS-' || l ||'>'||substr(l_fm_l_allowance_4_val,1,length(l_fm_l_allowance_4_val)-3)||'</A4-DINARS-'|| l || '>';
      l_str_a4f := '<A4-FILLS-' || l ||'>'||substr(l_fm_l_allowance_4_val,length(l_fm_l_allowance_4_val)-1)||'</A4-FILLS-'|| l || '>';
      l_str_a5d := '<A5-DINARS-'|| l ||'>'||substr(l_fm_total_val,1,length(l_fm_total_val)-3)||'</A5-DINARS-'|| l || '>';
      l_str_a5f := '<A5-FILLS-' || l ||'>'||substr(l_fm_total_val,length(l_fm_total_val)-1)||'</A5-FILLS-'|| l || '>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_ssn), l_str_ee_ssn);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_name), l_str_ee_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aad), l_str_aad);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aaf), l_str_aaf);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2d), l_str_a2d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2f), l_str_a2f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3d), l_str_a3d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3f), l_str_a3f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4d), l_str_a4d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4f), l_str_a4f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5d), l_str_a5d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5f), l_str_a5f);
      j := j + 1;
      l := l + 1;
      IF j > i THEN
        l_new_processed := 1;
      END IF;
      IF l_new_count = 12/*8*/ THEN
        l_str_pb := '<PB>'||'  '||'</PB>';
        dbms_lob.writeAppend( l_xfdf_string, length(l_str_pb),l_str_pb);
      	dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
      	l := 1;
        EXIT;
      END IF;
    END LOOP;
    IF l_new_processed = 1 THEN
      l_all_processed := 1;
	If l_new_count <> 12 then
              l_str_pb := '<PB>'||'  '||'</PB>';
              dbms_lob.writeAppend( l_xfdf_string, length(l_str_pb),l_str_pb);
	      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
	End If;
    END IF;
    END LOOP;
    dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    hr_utility.set_location('Finished creating xml data for Procedure FORM6 ',20);
EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
  END FORM6;
  -------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------
  PROCEDURE FORM7
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS

    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'AE_BG_DETAILS';

    /*Cursor for fetching Employer SSN*/
     CURSOR csr_employer_ssn IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_employer_id
     AND    org_information_context = 'AE_LEGAL_EMPLOYER_DETAILS';

     /*Cursor for fetching Employer Name*/
     CURSOR csr_employer_name IS
     SELECT name
     FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

    /*Cursor for fetching list of new employees*/
    CURSOR csr_get_new_emp (l_effective_date date, l_nat_cd varchar2) IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,pos.date_start
    FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_all_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') <> TRUNC(l_effective_date, 'MM')
    AND    trunc(pos.date_start, 'MM') = trunc(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.per_information18 = l_nat_cd;

    rec_get_new_emp        csr_get_new_emp%ROWTYPE;
    /*Cursor for fetching list of terminated employees*/
    CURSOR csr_get_ter_emp(l_effective_date date , l_nat_cd varchar2) IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,pos.actual_termination_date
                    ,ppa.date_earned
    FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_all_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.per_information18 = l_nat_cd;

    rec_get_ter_emp        csr_get_ter_emp%ROWTYPE;
    /*Cursor for fetching effective date of salary change*/
    CURSOR csr_get_salary_date (p_person_id NUMBER, l_effective_date date) IS
    SELECT date_earned, paa.assignment_action_id
    FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,per_periods_of_service pos
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    trunc(ppa.date_earned, 'MM') < TRUNC(l_effective_date, 'MM')
    AND    asg.person_id = p_person_id
    order by date_earned desc;
    rec_get_salary_date     csr_get_salary_date%ROWTYPE;

    /*Cursor for fetching list of employees who are neither new nor terminated*/
    CURSOR csr_get_cha_emp(l_effective_date date, l_nat_cd varchar2) IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,date_earned
    FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_all_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_effective_date, 'MM')
    AND    trunc(pos.date_start, 'MM') <> trunc(l_effective_date, 'MM')
    AND    trunc(NVL(pos.actual_termination_date, to_date('31-12-4712','DD-MM-YYYY')),'MM') <> TRUNC(l_effective_date, 'MM')
    AND    trunc(l_effective_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(p_employer_id)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_effective_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.per_information18 = l_nat_cd;

    rec_get_cha_emp        csr_get_cha_emp%ROWTYPE;

    /* Cursor for fetching the person data */
    	CURSOR csr_get_person_data (l_person_id number,l_effective_date date) IS
    	SELECT ppf.full_name
    	FROM	per_all_people_f ppf
    	WHERE 	ppf.person_id = l_person_id
    	AND	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching the person's assignment data */
    	CURSOR csr_get_person_asg_data (l_person_id number,l_effective_date date) IS
    	SELECT hsck.segment3
    	FROM	per_all_assignments_f paf,hr_soft_coding_keyflex hsck
    	WHERE 	paf.person_id = l_person_id
    	AND     paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    	AND     hsck.segment1 = p_employer_id
    	AND	l_effective_date between paf.effective_start_date and paf.effective_end_date;

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_bg_id number) IS
        SELECT  ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3,ORG_INFORMATION4,ORG_INFORMATION5,ORG_INFORMATION6,ORG_INFORMATION7,ORG_INFORMATION8,ORG_INFORMATION9,ORG_INFORMATION10
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_bg_id
        AND	org_information_context = 'AE_SI_DETAILS';

    /*Cursor for fetching defined balance id*/
    CURSOR csr_get_si_id(p_user_name VARCHAR2)  IS
    SELECT  u.creator_id
    FROM    ff_user_entities  u,
            ff_database_items d
    WHERE   d.user_name = p_user_name
    AND     u.user_entity_id = d.user_entity_id
    AND     u.legislation_code = 'AE'
    AND     u.business_group_id is null
    AND     u.creator_type = 'B';

    TYPE def_bal_rec IS RECORD
    (def_bal_id                  NUMBER
    ,label_index		 VARCHAR2(40));
    TYPE t_def_bal_table IS TABLE OF def_bal_rec INDEX BY BINARY_INTEGER;
    t_store_def_bal   t_def_bal_table;
    TYPE new_assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,date_start                DATE);
    TYPE t_new_assact_table IS TABLE OF new_assact_rec INDEX BY BINARY_INTEGER;
    t_new_store_assact   t_new_assact_table;
    TYPE ter_assact_rec IS RECORD
    (person_id                  NUMBER
    ,assignment_action_id       NUMBER
    ,actual_termination_date    DATE
    ,date_earned                DATE);
    TYPE t_ter_assact_table IS TABLE OF ter_assact_rec INDEX BY BINARY_INTEGER;
    t_ter_store_assact   t_ter_assact_table;
    TYPE cha_assact_rec IS RECORD
    (person_id                  NUMBER
    ,assignment_action_id       NUMBER
    ,date_earned                DATE
    ,changed_salary             NUMBER);
    TYPE t_cha_assact_table IS TABLE OF cha_assact_rec INDEX BY BINARY_INTEGER;
    t_cha_store_assact   t_cha_assact_table;
    l_employer_name varchar2(240);
    l_input_date varchar2(30);
    l_effective_date date;
    l_employer_ssn number;
    l_basic_sal_id number;
    z number;
    l_accomodation_id number;
    l_social_id number;
    l_child_social_id number;
    l_tp_id number;
    l_ol1_id number;
    l_ol2_id number;
    l_ol3_id number;
    l_ol4_id number;
    l_cost_of_living_id number;
    l_index number;
    i number;
    k number;
    m number;
    n number;
    j number;
    x number;
    l_tot_new_count number;
    l_tot_change_count number;
    l_tot_term_count number;
    l_new_processed number;
    l_ter_processed            NUMBER;
    l_all_processed number;
    l_new_count number;
    l_cha_processed            NUMBER;
    l_basic_val number(15,2);
    l_accomodation_val number(15,2);
    l_allowance_1_val number(15,2);
    l_allowance_2_val number(15,2);
    l_allowance_3_val number(15,2);
    l_allowance_4_val number(15,2);
    l number;
    L_FULL_NAME varchar2(240);
    l_insured_ssn varchar2(30);
    L_TOTAL number(15,2);
    l_total_term 	number(15,2);
    l_total_change 	number(15,2) ;
    l_fm_l_total_term	varchar2(100);
    l_fm_l_total_change	varchar2(100);
    L_FM_TOTAL_VAL varchar2(100);
    l_fm_l_basic_val varchar2(100);
    L_FM_L_ACCOMODATION_VAL varchar2(100);
    L_FM_L_ALLOWANCE_1_VAL varchar2(100);
    L_FM_L_ALLOWANCE_2_VAL varchar2(100);
    L_FM_L_ALLOWANCE_3_VAL varchar2(100);
    L_FM_L_TOTAL_HA varchar2(100);
    L_FM_L_TOTAL_A1 varchar2(100);
    L_FM_L_TOTAL_A2 varchar2(100);
    L_FM_L_TOTAL_A3 varchar2(100);
    L_FM_L_TOTAL_TOTAL varchar2(100);
    L_FM_L_TOTAL_A4 varchar2(100);
    L_FM_L_TOTAL_BASIC varchar2(100);
    L_TOTAL_HA number(15,2);
    L_TOTAL_A1 number(15,2);
    L_TOTAL_A2 number(15,2);
    L_TOTAL_A3 number(15,2);
    L_TOTAL_TOTAL number(15,2);
    L_TOTAL_A4 number(15,2);
    L_TOTAL_BASIC number(15,2);
    L_FM_SUBJECT_SI_VAL varchar2(100);
    L_FM_L_ALLOWANCE_4_VAL varchar2(100);
    L_FM_CHANGED_SALARY varchar2(100);
    l_xfdf_string              CLOB;
    l_diff_exist               NUMBER := 0;
    l_subject_si_val           NUMBER(15,2);
    l_subject_si_id		NUMBER;
    l_salary_effective_date    DATE;
    l_prev_salary              NUMBER(15,2);
    l_str_er_name varchar2(240);
    l_str_er_ssn varchar2(240);
    l_str_ee_name varchar2(240);
    l_str_ee_ssn varchar2(240);
    l_str_year varchar2(240);
    l_str_seq_no varchar2(240);
    l_str_bsd varchar2(240);
    l_str_bsf varchar2(240);
    l_str_aad varchar2(240);
    l_str_aaf varchar2(240);
    l_str_a1d varchar2(240);
    l_str_a1f varchar2(240);
    l_str_a2d varchar2(240);
    l_str_a2f varchar2(240);
    l_str_a3d varchar2(240);
    l_str_a3f varchar2(240);
    l_str_a4d varchar2(240);
    l_str_a4f varchar2(240);
    l_str_a5d varchar2(240);
    l_str_a5f varchar2(240);
    L_SI_ER_MONTH_ID number;
    L_SI_ADJ_ER_MONTH_ID number;
    L_CUR_SI_ER number (15,2);
    L_CUR_SI_ER_ADJ number (15,2);
    L_CUR_TOTAL number(15,2);
    L_PREV_SI_ER number (15,2);
    L_PREV_SI_ER_ADJ number (15,2);
    L_PREV_TOTAL number(15,2);
    L_DIFF_TOTAL number(15,2);
    L_FM_L_CUR_TOTAL varchar2(100);
    L_FM_L_PREV_TOTAL varchar2(100);
    L_FM_L_DIFF_TOTAL varchar2(100);
    L_STR_ER_CUR_TOTAL_D varchar2(240);
    L_STR_ER_CUR_TOTAL_F varchar2(240);
    L_STR_ER_PREV_TOTAL_D varchar2(240);
    L_STR_ER_PREV_TOTAL_F varchar2(240);
    L_STR_ER_DIFF_TOTAL_D varchar2(240);
    L_STR_ER_DIFF_TOTAL_F varchar2(240);
    tp number;
    l_subject_to_id number;
    l_nat_cd varchar2(30);
    l_si_ee_month_id number;
    l_si_adj_ee_month_id number;
    l_cur_si_ee number(15,2);
    l_cur_si_ee_adj number(15,2);
    l_prev_si_ee number(15,2);
    l_prev_si_ee_adj number(15,2);
    l_str_mon varchar2(240);

  BEGIN
      set_currency_mask(p_business_group_id);
      l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
      l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
      INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);
    hr_utility.set_location('Entering FORM6 ',10);

    /* Fetch Local Nationality */
    OPEN csr_get_loc_nat;
    FETCH csr_get_loc_nat INTO l_nat_cd;
    CLOSE csr_get_loc_nat;

    /*Fetch Employer SSN*/
    OPEN csr_employer_ssn;
    FETCH csr_employer_ssn INTO l_employer_ssn;
    CLOSE csr_employer_ssn;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    /* Fetch defined balance for defined balance EMPLOYER_SOCIAL_INSURANCE_EMPLOYER_MONTH and EMPLOYER_SOCIAL_INSURANCE_ADJUSTMENT_EMPLOYER_MONTH*/
    OPEN csr_get_si_id ('EMPLOYER_SOCIAL_INSURANCE_EMPLOYER_MONTH');
    FETCH csr_get_si_id into l_si_er_month_id;
    CLOSE csr_get_si_id;

    OPEN csr_get_si_id ('EMPLOYER_SOCIAL_INSURANCE_ADJUSTMENT_EMPLOYER_MONTH');
    FETCH csr_get_si_id into l_si_adj_er_month_id;
    CLOSE csr_get_si_id;

    OPEN csr_get_si_id ('EMPLOYEE_SOCIAL_INSURANCE_EMPLOYER_MONTH');
    FETCH csr_get_si_id into l_si_ee_month_id;
    CLOSE csr_get_si_id;

    OPEN csr_get_si_id ('EMPLOYEE_SOCIAL_INSURANCE_ADJUSTMENT_EMPLOYER_MONTH');
    FETCH csr_get_si_id into l_si_adj_ee_month_id;
    CLOSE csr_get_si_id;

    OPEN csr_get_si_id ('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_si_id into l_subject_to_id;
    CLOSE csr_get_si_id;

    /* Fetch values for Social insurance contribution values for Employer */
    /* Set the contexts for date earned as effective date*/
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(l_effective_date));
    pay_balance_pkg.set_context('TAX_UNIT_ID', p_employer_id);
    l_cur_si_er := pay_balance_pkg.get_value(l_si_er_month_id,NULL);
    l_cur_si_er_adj := pay_balance_pkg.get_value(l_si_adj_er_month_id,NULL);
    l_cur_si_ee := pay_balance_pkg.get_value(l_si_ee_month_id,NULL);
    l_cur_si_ee_adj := pay_balance_pkg.get_value(l_si_adj_ee_month_id,NULL);
    l_cur_total := l_cur_si_er + l_cur_si_er_adj + l_cur_si_ee + l_cur_si_ee_adj;

    /* Set the contexts for date earned as previous month*/
    pay_balance_pkg.set_context('DATE_EARNED', fnd_date.date_to_canonical(add_months(l_effective_date,-1)));
    pay_balance_pkg.set_context('TAX_UNIT_ID', p_employer_id);
    l_prev_si_er := pay_balance_pkg.get_value(l_si_er_month_id,NULL);
    l_prev_si_er_adj := pay_balance_pkg.get_value(l_si_adj_er_month_id,NULL);
    l_prev_si_ee := pay_balance_pkg.get_value(l_si_ee_month_id,NULL);
    l_prev_si_ee_adj := pay_balance_pkg.get_value(l_si_adj_ee_month_id,NULL);
    l_prev_total := l_prev_si_er + l_prev_si_er_adj + l_prev_si_ee + l_prev_si_ee_adj;

    l_diff_total := l_cur_total - l_prev_total;

      l_fm_l_cur_total := to_char(abs(l_cur_total),lg_format_mask);
      l_fm_l_prev_total := to_char(abs(l_prev_total),lg_format_mask);
      l_fm_l_diff_total := to_char(abs(l_diff_total),lg_format_mask);

     BEGIN

            	SELECT decode(l_cur_total/(abs(decode(l_cur_total,0,1,l_cur_total))*-1),1,'-'||l_fm_l_cur_total,l_fm_l_cur_total)
            	INTO l_fm_l_cur_total
            	FROM dual;

            	SELECT decode(l_prev_total/(abs(decode(l_prev_total,0,1,l_prev_total))*-1),1,'-'||l_fm_l_prev_total,l_fm_l_prev_total)
            	INTO l_fm_l_prev_total
            	FROM dual;

            	SELECT decode(l_diff_total/(abs(decode(l_diff_total,0,1,l_diff_total))*-1),1,'-'||l_fm_l_diff_total,l_fm_l_diff_total)
            	INTO l_fm_l_diff_total
            	FROM dual;


      EXCEPTION
      		WHEN no_data_found then
      			null;
      END;


    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');

    OPEN csr_get_def_bal_ids (p_employer_id);
    FETCH csr_get_def_bal_ids into l_basic_sal_id,l_accomodation_id,l_social_id,l_child_social_id,l_cost_of_living_id,l_ol1_id,l_tp_id,l_ol2_id,l_ol3_id,l_ol4_id;
    CLOSE csr_get_def_bal_ids;

    /*Fetch Defined Balance Id*/
    OPEN csr_get_si_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_si_id INTO l_subject_si_id;
    CLOSE csr_get_si_id;
    z := 1;
    t_store_def_bal(z).def_bal_id := l_basic_sal_id;
    t_store_def_bal(z).label_index := get_index(1);
    z:= z+1;
    t_store_def_bal(z).def_bal_id := l_accomodation_id;
    t_store_def_bal(z).label_index := get_index(2);
    z := z + 1;
    l_index := 2;
    LOOP
   	If l_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_social_id;
    		t_store_def_bal(z).label_index := get_index(3);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_child_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_child_social_id;
    		t_store_def_bal(z).label_index := get_index(4);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;
    	If l_cost_of_living_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_cost_of_living_id;
    		t_store_def_bal(z).label_index := get_index(5);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_tp_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_tp_id;
    	        t_store_def_bal(z).label_index := get_index(6);
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;
    	If l_ol1_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol1_id;
    		t_store_def_bal(z).label_index := get_index(7);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol2_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol2_id;
		t_store_def_bal(z).label_index := get_index(8);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol3_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol3_id;
    		t_store_def_bal(z).label_index := get_index(9);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol4_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol4_id;
    		t_store_def_bal(z).label_index := get_index(10);
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If z < 7then
    		WHILE Z <=7LOOP
    			t_store_def_bal(z).def_bal_id := NULL;
    			t_store_def_bal(z).label_index := get_index(11);
    			z := z + 1;
    			EXIT WHEN z > 7;
    		END LOOP;
	End If;
    	EXIT WHEN z >= 7;
    END LOOP;
    i := 0;
    k := 0;
    m := 0;

    OPEN csr_get_new_emp(l_effective_date,l_nat_cd);
    LOOP
      FETCH csr_get_new_emp INTO rec_get_new_emp;
      EXIT WHEN csr_get_new_emp%NOTFOUND;
      i := i + 1;
      t_new_store_assact(i).person_id := rec_get_new_emp.person_id;
      t_new_store_assact(i).assignment_action_id := rec_get_new_emp.assignment_action_id;
      t_new_store_assact(i).date_start := rec_get_new_emp.date_start;
    END LOOP;
    CLOSE csr_get_new_emp;

    OPEN csr_get_ter_emp(l_effective_date,l_nat_cd);
    LOOP
      FETCH csr_get_ter_emp INTO rec_get_ter_emp;
      EXIT WHEN csr_get_ter_emp%NOTFOUND;
      k := k + 1;
      t_ter_store_assact(k).person_id := rec_get_ter_emp.person_id;
      t_ter_store_assact(k).assignment_action_id := rec_get_ter_emp.assignment_action_id;
      t_ter_store_assact(k).actual_termination_date := rec_get_ter_emp.actual_termination_date;
      t_ter_store_assact(k).date_earned := rec_get_ter_emp.date_earned;
    END LOOP;
    CLOSE csr_get_ter_emp;

    OPEN csr_get_cha_emp(l_effective_date,l_nat_cd);
    LOOP
      FETCH csr_get_cha_emp INTO rec_get_cha_emp;
      EXIT WHEN csr_get_cha_emp%NOTFOUND;
      l_diff_exist := 0;
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,rec_get_cha_emp.assignment_action_id);
      l_salary_effective_date := rec_get_cha_emp.date_earned;
      OPEN csr_get_salary_date (rec_get_cha_emp.person_id,l_effective_date);
      LOOP
        FETCH csr_get_salary_date INTO rec_get_salary_date;
        EXIT WHEN csr_get_salary_date%NOTFOUND;
        l_prev_salary := pay_balance_pkg.get_value(l_subject_si_id,rec_get_salary_date.assignment_action_id);
        IF l_prev_salary <> l_subject_si_val THEN
          l_diff_exist := 1;
          EXIT;
        END IF;
        EXIT;
      END LOOP;
      CLOSE csr_get_salary_date;

      IF l_diff_exist = 1 THEN
        m := m + 1;
        t_cha_store_assact(m).person_id := rec_get_cha_emp.person_id;
        t_cha_store_assact(m).assignment_action_id := rec_get_cha_emp.assignment_action_id;
        t_cha_store_assact(m).date_earned := rec_get_cha_emp.date_earned;
        t_cha_store_assact(m).changed_salary := l_subject_si_val;
      END IF;
    END LOOP;
    CLOSE csr_get_cha_emp;

    j := 1;
    l := 1;
    n := 1;
    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;
    IF k > 0  THEN
      l_ter_processed := 0;
    ELSE
      l_ter_processed := 1;
    END IF;
    IF m > 0  THEN
      l_cha_processed := 0;
    ELSE
      l_cha_processed := 1;
    END IF;
    l_all_processed := 0;

    l_tot_new_count := 0;
    l_tot_change_count := 0;
    l_tot_term_count := 0;

    WHILE l_all_processed  <> 1 LOOP
    --Writing data for new employees
    l_new_count := 0;
    dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
      l_str_er_name := '<ERNAME>'||l_employer_name||'</ERNAME>';
      l_str_er_ssn :=  '<ERSSN>'||l_employer_ssn||'</ERSSN>';
      l_str_year := '<YEAR>'||substr(p_effective_year,4,1)||'</YEAR>';
      l_str_mon := '<MONTH>'||p_effective_month||'</MONTH>';
      l_str_er_cur_total_d := '<CURRENT-TOTAL-DINARS>'||substr(l_fm_l_cur_total,1,length(l_fm_l_cur_total)-3)||'</CURRENT-TOTAL-DINARS>';
      l_str_er_cur_total_f := '<CURRENT-TOTAL-FILLS>'||substr(l_fm_l_cur_total,length(l_fm_l_cur_total)-1)||'</CURRENT-TOTAL-FILLS>';
      l_str_er_prev_total_d :=  '<PREV-TOTAL-DINARS>'||substr(l_fm_l_prev_total,1,length(l_fm_l_prev_total)-3)||'</PREV-TOTAL-DINARS>';
      l_str_er_prev_total_f :=  '<PREV-TOTAL-FILLS>'||substr(l_fm_l_prev_total,length(l_fm_l_prev_total)-1)||'</PREV-TOTAL-FILLS>';
      l_str_er_diff_total_d := '<DIFFERENCE-DINARS>'||substr(l_fm_l_diff_total,1,length(l_fm_l_diff_total)-3)||'</DIFFERENCE-DINARS>';
      l_str_er_diff_total_f := '<DIFFERENCE-FILLS>'||substr(l_fm_l_diff_total,length(l_fm_l_diff_total)-1)||'</DIFFERENCE-FILLS>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_ssn), l_str_er_ssn);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_mon), l_str_mon);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_cur_total_d), l_str_er_cur_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_cur_total_f), l_str_er_cur_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_prev_total_d), l_str_er_prev_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_prev_total_f), l_str_er_prev_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_diff_total_d), l_str_er_diff_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_diff_total_f), l_str_er_diff_total_f);
      l_total_total := 0 ;
      l_total_basic := 0;
      l_total_ha :=0;
      L_TOTAL_A1 :=0;
      L_TOTAL_A2 :=0;
      L_TOTAL_A3 :=0;
      L_TOTAL_A4 :=0;
    WHILE j <= i LOOP
/**** RESET ALL THE VARIABLES *****/
      l_basic_val := 0;
      l_accomodation_val := 0;
      l_allowance_1_val := 0;
      l_allowance_2_val := 0;
      l_allowance_3_val := 0;
      l_allowance_4_val := 0;
      l_total := 0;
      x := 1;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_basic_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_new_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_basic_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_accomodation_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_new_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_accomodation_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_1_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_new_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_1_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_2_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_new_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_2_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_3_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_new_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_3_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_4_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_new_store_assact(j).assignment_action_id);
      ELSE
      		l_allowance_4_val := 0;
      END IF;
      l_new_count := l_new_count+1;

	If l_new_count <> 6 then
	      l_tot_new_count := l_tot_new_count + 1;
	End If;
      l_fm_l_basic_val := to_char(abs(l_basic_val),lg_format_mask);
      l_fm_l_accomodation_val := to_char(abs(l_accomodation_val),lg_format_mask);
      l_fm_l_allowance_1_val := to_char(abs(l_allowance_1_val),lg_format_mask);
      l_fm_l_allowance_2_val := to_char(abs(l_allowance_2_val),lg_format_mask);
      l_fm_l_allowance_3_val := to_char(abs(l_allowance_3_val),lg_format_mask);
      l_fm_l_allowance_4_val := to_char(abs(l_allowance_4_val),lg_format_mask);

/*      l_total := l_basic_val + l_accomodation_val + l_allowance_1_val + l_allowance_2_val + l_allowance_3_val + l_allowance_4_val;*/

      l_total := pay_balance_pkg.get_value(l_subject_to_id ,t_new_store_assact(j).assignment_action_id);
      l_fm_total_val := to_char(abs(l_total),lg_format_mask);
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_new_store_assact(j).assignment_action_id);
      l_fm_subject_si_val := to_char(abs(l_subject_si_val),lg_format_mask);


     BEGIN

            	SELECT decode(l_basic_val/(abs(decode(l_basic_val,0,1,l_basic_val))*-1),1,'-'||l_fm_l_basic_val,l_fm_l_basic_val)
            	INTO l_fm_l_basic_val
            	FROM dual;

            	SELECT decode(l_accomodation_val/(abs(decode(l_accomodation_val,0,1,l_accomodation_val))*-1),1,'-'||l_fm_l_accomodation_val,l_fm_l_accomodation_val)
            	INTO l_fm_l_accomodation_val
            	FROM dual;

            	SELECT decode(l_allowance_1_val/(abs(decode(l_allowance_1_val,0,1,l_allowance_1_val))*-1),1,'-'||l_fm_l_allowance_1_val,l_fm_l_allowance_1_val)
            	INTO l_fm_l_allowance_1_val
            	FROM dual;

            	SELECT decode(l_allowance_2_val/(abs(decode(l_allowance_2_val,0,1,l_allowance_2_val))*-1),1,'-'||l_fm_l_allowance_2_val,l_fm_l_allowance_2_val)
            	INTO l_fm_l_allowance_2_val
            	FROM dual;

            	SELECT decode(l_allowance_3_val/(abs(decode(l_allowance_3_val,0,1,l_allowance_3_val))*-1),1,'-'||l_fm_l_allowance_3_val,l_fm_l_allowance_3_val)
            	INTO l_fm_l_allowance_3_val
            	FROM dual;

            	SELECT decode(l_allowance_4_val/(abs(decode(l_allowance_4_val,0,1,l_allowance_4_val))*-1),1,'-'||l_fm_l_allowance_4_val,l_fm_l_allowance_4_val)
            	INTO l_fm_l_allowance_4_val
            	FROM dual;

            	SELECT decode(l_total/(abs(decode(l_total,0,1,l_total))*-1),1,'-'||l_fm_total_val,l_fm_total_val)
            	INTO l_fm_total_val
            	FROM dual;

            	SELECT decode(l_subject_si_val/(abs(decode(l_subject_si_val,0,1,l_subject_si_val))*-1),1,'-'||l_fm_subject_si_val,l_fm_subject_si_val)
            	INTO l_fm_subject_si_val
            	FROM dual;

      EXCEPTION
      		WHEN no_data_found then
      			null;
      END;


      OPEN csr_get_person_data(t_new_store_assact(j).person_id,l_effective_date);
      FETCH csr_get_person_data INTO l_full_name;
      CLOSE csr_get_person_data;

      OPEN csr_get_person_asg_data(t_new_store_assact(j).person_id, l_effective_date);
      FETCH csr_get_person_asg_data into l_insured_ssn;
      CLOSE csr_get_person_asg_data;

	If l_new_count <> 6 then
	      l_str_seq_no := '<SER-' || l_new_count ||'>'||l_tot_new_count||'</SER-'|| l_new_count || '>';
	      l_str_ee_name := '<EMPLOYEE-NAME-'|| l_new_count || '>'|| substr(l_full_name,1,60) ||'</EMPLOYEE-NAME-'|| l_new_count || '>';
	      l_str_bsd := '<BASIC-SALARY-DINARS-' || l_new_count 		||'>'||substr(l_fm_l_basic_val,1,length(l_fm_l_basic_val)-3)||'</BASIC-SALARY-DINARS-'|| l_new_count || '>';
	      l_str_bsf := '<BASIC-SALARY-FILLS-' || l_new_count ||'>'||substr(l_fm_l_basic_val,length(l_fm_l_basic_val)-1)||'</BASIC-SALARY-FILLS-'|| 		l_new_count || '>';
	      l_str_aad := '<HOUSING-ALLOWANCE-DINARS-' || l_new_count 		||'>'||substr(l_fm_l_accomodation_val,1,length(l_fm_l_accomodation_val)-3)||'</HOUSING-ALLOWANCE-DINARS-'|| l_new_count || '>';
	      l_str_aaf := '<HOUSING-ALLOWANCE-FILLS-' || l_new_count 		||'>'||substr(l_fm_l_accomodation_val,length(l_fm_l_accomodation_val)-1)||'</HOUSING-ALLOWANCE-FILLS-'|| l_new_count || '>';
	      l_str_a1d := '<A1-DINARS-' || l_new_count ||'>'||substr(l_fm_l_allowance_1_val,1,length(l_fm_l_allowance_1_val)-3)||'</A1-DINARS-'|| l_new_count 		|| '>';
	      l_str_a1f := '<A1-FILLS-' || l_new_count ||'>'||substr(l_fm_l_allowance_1_val,length(l_fm_l_allowance_1_val)-1)||'</A1-FILLS-'|| l_new_count || 		'>';
	      l_str_a2d := '<A2-DINARS-' || l_new_count ||'>'||substr(l_fm_l_allowance_2_val,1,length(l_fm_l_allowance_2_val)-3)||'</A2-DINARS-'|| l_new_count 		|| '>';
	      l_str_a2f := '<A2-FILLS-' || l_new_count ||'>'||substr(l_fm_l_allowance_2_val,length(l_fm_l_allowance_2_val)-1)||'</A2-FILLS-'|| l_new_count || 		'>';
	      l_str_a3d := '<A3-DINARS-' || l_new_count ||'>'||substr(l_fm_l_allowance_3_val,1,length(l_fm_l_allowance_3_val)-3)||'</A3-DINARS-'|| l_new_count 		|| '>';
	      l_str_a3f := '<A3-FILLS-' || l_new_count ||'>'||substr(l_fm_l_allowance_3_val,length(l_fm_l_allowance_3_val)-1)||'</A3-FILLS-'|| l_new_count || 		'>';
	      l_str_a4d := '<A4-DINARS-' || l_new_count ||'>'||substr(l_fm_l_allowance_4_val,1,length(l_fm_l_allowance_4_val)-3)||'</A4-DINARS-'|| l_new_count 		|| '>';
	      l_str_a4f := '<A4-FILLS-' || l_new_count ||'>'||substr(l_fm_l_allowance_4_val,length(l_fm_l_allowance_4_val)-1)||'</A4-FILLS-'|| l_new_count || 		'>';
	      l_str_a5d := '<TOTAL-DINARS-'|| l_new_count ||'>'||substr(l_fm_total_val,1,length(l_fm_total_val)-3)||'</TOTAL-DINARS-'|| l_new_count || '>';
	      l_str_a5f := '<TOTAL-FILLS-' || l_new_count ||'>'||substr(l_fm_total_val,length(l_fm_total_val)-1)||'</TOTAL-FILLS-'|| l_new_count || 		'>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_name), l_str_ee_name);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aad), l_str_aad);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aaf), l_str_aaf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2d), l_str_a2d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2f), l_str_a2f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3d), l_str_a3d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3f), l_str_a3f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4d), l_str_a4d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4f), l_str_a4f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5d), l_str_a5d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5f), l_str_a5f);
	          L_TOTAL_HA := L_TOTAL_HA + l_accomodation_val;
	          L_TOTAL_A1 := L_TOTAL_A1 + l_allowance_1_val;
	          L_TOTAL_A2 := L_TOTAL_A2 + l_allowance_2_val;
	          L_TOTAL_A3 := L_TOTAL_A3 + l_allowance_3_val;
	          L_TOTAL_TOTAL := L_TOTAL_TOTAL + l_total;
	          L_TOTAL_A4  := L_TOTAL_A4 + l_allowance_4_val;
	          l_total_basic := l_total_basic + l_basic_val;
	END If;
	If l_new_count <> 6 then
   		j := j + 1;
      	End if;
	IF (j > i and l_new_count <> 6) then

	                tp := l_new_count;
                        WHILE tp <=6 LOOP
                                l_str_seq_no := '<SER-' || tp ||'>'||'   ' ||'</SER-'|| tp || '>';
                                dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
                                tp := tp + 1;
                        END LOOP;


		      l_fm_l_total_basic := to_char(abs(l_total_basic),lg_format_mask);
		      l_fm_l_total_ha := to_char(abs(L_TOTAL_HA),lg_format_mask);
		      l_fm_l_total_a1 := to_char(abs(L_TOTAL_A1),lg_format_mask);
		      l_fm_l_total_a2 := to_char(abs(L_TOTAL_A2),lg_format_mask);
		      l_fm_l_total_a3 := to_char(abs(L_TOTAL_A3),lg_format_mask);
      		      l_fm_l_total_a4 := to_char(abs(L_TOTAL_A4),lg_format_mask);
      		      l_fm_l_total_total := to_char(abs(L_TOTAL_TOTAL),lg_format_mask);


		     BEGIN

				SELECT decode(l_total_basic/(abs(decode(l_total_basic,0,1,l_total_basic))*-1),1,'-'||l_fm_l_total_basic,l_fm_l_total_basic)
				INTO l_fm_l_total_basic
				FROM dual;

				SELECT decode(L_TOTAL_HA/(abs(decode(L_TOTAL_HA,0,1,L_TOTAL_HA))*-1),1,'-'||l_fm_l_total_ha,l_fm_l_total_ha)
				INTO l_fm_l_total_ha
				FROM dual;

				SELECT decode(L_TOTAL_A1/(abs(decode(L_TOTAL_A1,0,1,L_TOTAL_A1))*-1),1,'-'||l_fm_l_total_a1,l_fm_l_total_a1)
				INTO l_fm_l_total_a1
				FROM dual;

				SELECT decode(L_TOTAL_A2/(abs(decode(L_TOTAL_A2,0,1,L_TOTAL_A2))*-1),1,'-'||l_fm_l_total_a2,l_fm_l_total_a2)
				INTO l_fm_l_total_a2
				FROM dual;

				SELECT decode(L_TOTAL_A3/(abs(decode(L_TOTAL_A3,0,1,L_TOTAL_A3))*-1),1,'-'||l_fm_l_total_a3,l_fm_l_total_a3)
				INTO l_fm_l_total_a3
				FROM dual;

				SELECT decode(L_TOTAL_A4/(abs(decode(L_TOTAL_A4,0,1,L_TOTAL_A4))*-1),1,'-'||l_fm_l_total_a4,l_fm_l_total_a4)
				INTO l_fm_l_total_a4
				FROM dual;

				SELECT decode(L_TOTAL_TOTAL/(abs(decode(L_TOTAL_TOTAL,0,1,L_TOTAL_TOTAL))*-1),1,'-'||l_fm_l_total_total,l_fm_l_total_total)
				INTO l_fm_l_total_total
				FROM dual;

		      EXCEPTION
				WHEN no_data_found then
					null;
		      END;


	      l_str_bsd := '<BASIC-DINARS-TOTAL>'||substr(l_fm_l_total_basic,1,length(l_fm_l_total_basic)-3)||'</BASIC-DINARS-TOTAL>';
	      l_str_bsf := '<BASIC-FILLS-TOTAL>'||substr(l_fm_l_total_basic,length(l_fm_l_total_basic)-1)||'</BASIC-FILLS-TOTAL>';
	      l_str_aad := '<HOUSING-DINARS-TOTAL>'||substr(l_fm_l_total_ha,1,length(l_fm_l_total_ha)-3)||'</HOUSING-DINARS-TOTAL>';
	      l_str_aaf := '<HOUSING-FILLS-TOTAL>'||substr(l_fm_l_total_ha,length(l_fm_l_total_ha)-1)||'</HOUSING-FILLS-TOTAL>';
	      l_str_a1d := '<A1-DINARS-TOTAL>'||substr(l_fm_l_total_a1,1,length(l_fm_l_total_a1)-3)||'</A1-DINARS-TOTAL>';
	      l_str_a1f := '<A1-FILLS-TOTAL>'||substr(l_fm_l_total_a1,length(l_fm_l_total_a1)-1)||'</A1-FILLS-TOTAL>';
	      l_str_a2d := '<A2-DINARS-TOTAL>'||substr(l_fm_l_total_a2,1,length(l_fm_l_total_a2)-3)||'</A2-DINARS-TOTAL>';
	      l_str_a2f := '<A2-FILLS-TOTAL>'||substr(l_fm_l_total_a2,length(l_fm_l_total_a2)-1)||'</A2-FILLS-TOTAL>';
	      l_str_a3d := '<A3-DINARS-TOTAL>'||substr(l_fm_l_total_a3,1,length(l_fm_l_total_a3)-3)||'</A3-DINARS-TOTAL>';
	      l_str_a3f := '<A3-FILLS-TOTAL>'||substr(l_fm_l_total_a3,length(l_fm_l_total_a3)-1)||'</A3-FILLS-TOTAL>';
	      l_str_a4d := '<A4-DINARS-TOTAL>'||substr(l_fm_l_total_a4,1,length(l_fm_l_total_a4)-3)||'</A4-DINARS-TOTAL>';
	      l_str_a4f := '<A4-FILLS-TOTAL>'||substr(l_fm_l_total_a4,length(l_fm_l_total_a4)-1)||'</A4-FILLS-TOTAL>';
	      l_str_a5d := '<TOTAL-DINARS-TOTAL>'||substr(l_fm_l_total_total,1,length(l_fm_l_total_total)-3)||'</TOTAL-DINARS-TOTAL>';
	      l_str_a5f := '<TOTAL-FILLS-TOTAL>'||substr(l_fm_l_total_total,length(l_fm_l_total_total)-1)||'</TOTAL-FILLS-TOTAL>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aad), l_str_aad);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aaf), l_str_aaf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2d), l_str_a2d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2f), l_str_a2f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3d), l_str_a3d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3f), l_str_a3f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4d), l_str_a4d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4f), l_str_a4f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5d), l_str_a5d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5f), l_str_a5f);
	  /**************    dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>'); **********/
	END IF;
      IF j > i THEN
        l_new_processed := 1;
        EXIT;
      END IF;
      IF l_new_count = 6 THEN
		      l_fm_l_total_basic := to_char(abs(l_total_basic),lg_format_mask);
		      l_fm_l_total_ha := to_char(abs(L_TOTAL_HA),lg_format_mask);
		      l_fm_l_total_a1 := to_char(abs(L_TOTAL_A1),lg_format_mask);
		      l_fm_l_total_a2 := to_char(abs(L_TOTAL_A2),lg_format_mask);
		      l_fm_l_total_a3 := to_char(abs(L_TOTAL_A3),lg_format_mask);
      		      l_fm_l_total_a4 := to_char(abs(L_TOTAL_A4),lg_format_mask);
      		      l_fm_l_total_total := to_char(abs(L_TOTAL_TOTAL),lg_format_mask);

		     BEGIN

				SELECT decode(l_total_basic/(abs(decode(l_total_basic,0,1,l_total_basic))*-1),1,'-'||l_fm_l_total_basic,l_fm_l_total_basic)
				INTO l_fm_l_total_basic
				FROM dual;

				SELECT decode(L_TOTAL_HA/(abs(decode(L_TOTAL_HA,0,1,L_TOTAL_HA))*-1),1,'-'||l_fm_l_total_ha,l_fm_l_total_ha)
				INTO l_fm_l_total_ha
				FROM dual;

				SELECT decode(L_TOTAL_A1/(abs(decode(L_TOTAL_A1,0,1,L_TOTAL_A1))*-1),1,'-'||l_fm_l_total_a1,l_fm_l_total_a1)
				INTO l_fm_l_total_a1
				FROM dual;

				SELECT decode(L_TOTAL_A2/(abs(decode(L_TOTAL_A2,0,1,L_TOTAL_A2))*-1),1,'-'||l_fm_l_total_a2,l_fm_l_total_a2)
				INTO l_fm_l_total_a2
				FROM dual;

				SELECT decode(L_TOTAL_A3/(abs(decode(L_TOTAL_A3,0,1,L_TOTAL_A3))*-1),1,'-'||l_fm_l_total_a3,l_fm_l_total_a3)
				INTO l_fm_l_total_a3
				FROM dual;

				SELECT decode(L_TOTAL_A4/(abs(decode(L_TOTAL_A4,0,1,L_TOTAL_A4))*-1),1,'-'||l_fm_l_total_a4,l_fm_l_total_a4)
				INTO l_fm_l_total_a4
				FROM dual;

				SELECT decode(L_TOTAL_TOTAL/(abs(decode(L_TOTAL_TOTAL,0,1,L_TOTAL_TOTAL))*-1),1,'-'||l_fm_l_total_total,l_fm_l_total_total)
				INTO l_fm_l_total_total
				FROM dual;

		      EXCEPTION
				WHEN no_data_found then
					null;
		      END;


	      l_str_bsd := '<BASIC-DINARS-TOTAL>'||substr(l_fm_l_total_basic,1,length(l_fm_l_total_basic)-3)||'</BASIC-DINARS-TOTAL>';
	      l_str_bsf := '<BASIC-FILLS-TOTAL>'||substr(l_fm_l_total_basic,length(l_fm_l_total_basic)-1)||'</BASIC-FILLS-TOTAL>';
	      l_str_aad := '<HOUSING-DINARS-TOTAL>'||substr(l_fm_l_total_ha,1,length(l_fm_l_total_ha)-3)||'</HOUSING-DINARS-TOTAL>';
	      l_str_aaf := '<HOUSING-FILLS-TOTAL>'||substr(l_fm_l_total_ha,length(l_fm_l_total_ha)-1)||'</HOUSING-FILLS-TOTAL>';
	      l_str_a1d := '<A1-DINARS-TOTAL>'||substr(l_fm_l_total_a1,1,length(l_fm_l_total_a1)-3)||'</A1-DINARS-TOTAL>';
	      l_str_a1f := '<A1-FILLS-TOTAL>'||substr(l_fm_l_total_a1,length(l_fm_l_total_a1)-1)||'</A1-FILLS-TOTAL>';
	      l_str_a2d := '<A2-DINARS-TOTAL>'||substr(l_fm_l_total_a2,1,length(l_fm_l_total_a2)-3)||'</A2-DINARS-TOTAL>';
	      l_str_a2f := '<A2-FILLS-TOTAL>'||substr(l_fm_l_total_a2,length(l_fm_l_total_a2)-1)||'</A2-FILLS-TOTAL>';
	      l_str_a3d := '<A3-DINARS-TOTAL>'||substr(l_fm_l_total_a3,1,length(l_fm_l_total_a3)-3)||'</A3-DINARS-TOTAL>';
	      l_str_a3f := '<A3-FILLS-TOTAL>'||substr(l_fm_l_total_a3,length(l_fm_l_total_a3)-1)||'</A3-FILLS-TOTAL>';
	      l_str_a4d := '<A4-DINARS-TOTAL>'||substr(l_fm_l_total_a4,1,length(l_fm_l_total_a4)-3)||'</A4-DINARS-TOTAL>';
	      l_str_a4f := '<A4-FILLS-TOTAL>'||substr(l_fm_l_total_a4,length(l_fm_l_total_a4)-1)||'</A4-FILLS-TOTAL>';
	      l_str_a5d := '<TOTAL-DINARS-TOTAL>'||substr(l_fm_l_total_total,1,length(l_fm_l_total_total)-3)||'</TOTAL-DINARS-TOTAL>';
	      l_str_a5f := '<TOTAL-FILLS-TOTAL>'||substr(l_fm_l_total_total,length(l_fm_l_total_total)-1)||'</TOTAL-FILLS-TOTAL>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aad), l_str_aad);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aaf), l_str_aaf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2d), l_str_a2d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2f), l_str_a2f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3d), l_str_a3d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3f), l_str_a3f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4d), l_str_a4d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a4f), l_str_a4f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5d), l_str_a5d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a5f), l_str_a5f);
	     /************** dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>'); **********/
        EXIT;
      END IF;
    END LOOP;
    --Writing data for terminated employees
    l_new_count := 0;
    l_total_term := 0;

    WHILE l <= k LOOP
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_ter_store_assact(l).assignment_action_id);

      OPEN csr_get_person_data(t_ter_store_assact(l).person_id,l_effective_date);
      FETCH csr_get_person_data INTO l_full_name;
      CLOSE csr_get_person_data;

      OPEN csr_get_person_asg_data(t_ter_store_assact(l).person_id, l_effective_date);
      FETCH csr_get_person_asg_data into l_insured_ssn;
      CLOSE csr_get_person_asg_data;

      l_new_count := l_new_count+1;
	If l_new_count <> 5 then
	      l_tot_term_count := l_tot_term_count + 1;
	End If;

      l_fm_subject_si_val := to_char(abs(l_subject_si_val),lg_format_mask);

	BEGIN
		SELECT decode(l_subject_si_val/(abs(decode(l_subject_si_val,0,1,l_subject_si_val))*-1),1,'-'||l_fm_subject_si_val,l_fm_subject_si_val)
		INTO l_fm_subject_si_val
		FROM dual;

      EXCEPTION
		WHEN no_data_found then
			null;
      END;

	IF l_new_count <> 5 then
	      l_str_seq_no := '<SER-T-' || l_new_count ||'>'||l_tot_term_count||'</SER-T-'|| l_new_count || '>';
	      l_str_ee_ssn := '<TERM-SSN-'|| l_new_count || '>'|| l_insured_ssn ||'</TERM-SSN-'|| l_new_count || '>';
	      l_str_ee_name := '<TERM-EMPLOYEE-NAME-'|| l_new_count || '>'|| substr(l_full_name,1,60) ||'</TERM-EMPLOYEE-NAME-'|| l_new_count || '>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_ssn), l_str_ee_ssn);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_name), l_str_ee_name);
	      l_str_a1d := '<TERM-DINARS-' || l_new_count ||'>'||substr(l_fm_subject_si_val,1,length(l_fm_subject_si_val)-3)||'</TERM-DINARS-'|| l_new_count || 		'>';
	      l_str_a1f := '<TERM-FILLS-' || l_new_count ||'>'||substr(l_fm_subject_si_val,length(l_fm_subject_si_val)-1)||'</TERM-FILLS-'|| l_new_count || '>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      l_total_term := l_total_term + l_subject_si_val;
	END If;
	If l_new_count <> 5 then
		l:= l + 1;
	End If;
	If (l > k and  l_new_count <> 5) then

	                tp := l_new_count;
                        WHILE tp <= 5  LOOP
                                l_str_seq_no := '<SER-T-' || tp ||'>'||'  '||'</SER-T-'|| tp || '>';
                                dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
                                tp := tp + 1;
                        END LOOP;


	      l_fm_l_total_term := to_char(abs(l_total_term),lg_format_mask);

		BEGIN
			SELECT decode(l_total_term/(abs(decode(l_total_term,0,1,l_total_term))*-1),1,'-'||l_fm_l_total_term,l_fm_l_total_term)
			INTO l_fm_l_total_term
			FROM dual;

	      EXCEPTION
			WHEN no_data_found then
				null;
	      END;

	      l_str_bsd := '<TERM-DINARS-TOTAL>'||substr(l_fm_l_total_term,1,length(l_fm_l_total_term)-3)||'</TERM-DINARS-TOTAL>';
	      l_str_bsf := '<TERM-FILLS-TOTAL>'||substr(l_fm_l_total_term,length(l_fm_l_total_term)-1)||'</TERM-FILLS-TOTAL>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	     /************** dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>'); **********/
	End If;
      IF l > k THEN
        l_ter_processed := 1;
        EXIT;
      END IF;
      IF l_new_count = 5 THEN
	      l_fm_l_total_term := to_char(l_total_term,lg_format_mask);

		BEGIN
			SELECT decode(l_total_term/(abs(decode(l_total_term,0,1,l_total_term))*-1),1,'-'||l_fm_l_total_term,l_fm_l_total_term)
			INTO l_fm_l_total_term
			FROM dual;

	      EXCEPTION
			WHEN no_data_found then
				null;
	      END;

	      l_str_bsd := '<TERM-DINARS-TOTAL>'||substr(l_fm_l_total_term,1,length(l_fm_l_total_term)-3)||'</TERM-DINARS-TOTAL>';
	      l_str_bsf := '<TERM-FILLS-TOTAL>'||substr(l_fm_l_total_term,length(l_fm_l_total_term)-1)||'</TERM-FILLS-TOTAL>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	    /***********  dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>'); ************/
        EXIT;
      END IF;
    END LOOP;
    --Writing data for employees with changed salary
    l_new_count := 0;
    l_total_change := 0;

    WHILE n <= m LOOP
      l_subject_si_val := 0;
      l_subject_si_val := pay_balance_pkg.get_value(l_subject_si_id,t_cha_store_assact(n).assignment_action_id);

      OPEN csr_get_person_data(t_cha_store_assact(n).person_id,l_effective_date);
      FETCH csr_get_person_data INTO l_full_name;
      CLOSE csr_get_person_data;

      OPEN csr_get_person_asg_data(t_cha_store_assact(n).person_id, l_effective_date);
      FETCH csr_get_person_asg_data into l_insured_ssn;
      CLOSE csr_get_person_asg_data;

      l_new_count := l_new_count+1;
	If l_new_count <> 5 then
	      l_tot_change_count := l_tot_change_count + 1;
	End If;
      l_fm_changed_salary := to_char(abs(l_subject_si_val),lg_format_mask);

		BEGIN
			SELECT decode(l_subject_si_val/(abs(decode(l_subject_si_val,0,1,l_subject_si_val))*-1),1,'-'||l_fm_changed_salary,l_fm_changed_salary)
			INTO l_fm_changed_salary
			FROM dual;

	      EXCEPTION
			WHEN no_data_found then
				null;
	      END;

	IF l_new_count <> 5 then
	      l_str_seq_no := '<SER-C-' || l_new_count ||'>'||l_tot_change_count||'</SER-C-'|| l_new_count || '>';
	      l_str_ee_ssn := '<CHANGE-SSN-'|| l_new_count || '>'|| l_insured_ssn ||'</CHANGE-SSN-'|| l_new_count || '>';
	      l_str_ee_name := '<CHANGE-EMPLOYEE-NAME-'|| l_new_count || '>'|| substr(l_full_name,1,60) ||'</CHANGE-EMPLOYEE-NAME-'|| l_new_count || '>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_ssn), l_str_ee_ssn);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_name), l_str_ee_name);
	      l_str_a1d := '<CHANGE-WAGE-DINARS-' || l_new_count ||'>'||substr(l_fm_changed_salary,1,length(l_fm_changed_salary)-3)||'</CHANGE-WAGE-DINARS-'|| l_new_count ||'>';
	      l_str_a1f := '<CHANGE-FILLS-' || l_new_count	||'>'||substr(l_fm_changed_salary,length(l_fm_changed_salary)-1)||'</CHANGE-FILLS-'|| l_new_count || '>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      l_total_change := l_total_change + l_subject_si_val;
	END If;
	If l_new_count <> 5 then
		n := n + 1;
	End If;
	If (n > m and  l_new_count <> 5) then

	                tp := l_new_count;
                        WHILE tp <= 5 LOOP
                                l_str_seq_no := '<SER-C-' || tp ||'>'||'   '||'</SER-C-'|| tp || '>';
                                dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
                                tp := tp + 1;
                        END LOOP;


		l_fm_l_total_change := to_char(abs(l_total_change),lg_format_mask);

		BEGIN
			SELECT decode(l_total_change/(abs(decode(l_total_change,0,1,l_total_change))*-1),1,'-'||l_fm_l_total_change,l_fm_l_total_change)
			INTO l_fm_l_total_change
			FROM dual;

	      EXCEPTION
			WHEN no_data_found then
				null;
	      END;

	      l_str_bsd := '<CHANGE-DINARS-TOTAL>'||substr(l_fm_l_total_change,1,length(l_fm_l_total_change)-3)||'</CHANGE-DINARS-TOTAL>';
	      l_str_bsf := '<CHANGE-FILLS-TOTAL>'||substr(l_fm_l_total_change,length(l_fm_l_total_change)-1)||'</CHANGE-FILLS-TOTAL>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	    /*************  dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>'); ***********/
	End If;
      IF n > m THEN
        l_cha_processed := 1;
        EXIT;
      END IF;
      IF l_new_count = 5 THEN
		l_fm_l_total_change := to_char(abs(l_total_change),lg_format_mask);

		BEGIN
			SELECT decode(l_total_change/(abs(decode(l_total_change,0,1,l_total_change))*-1),1,'-'||l_fm_l_total_change,l_fm_l_total_change)
			INTO l_fm_l_total_change
			FROM dual;

	      EXCEPTION
			WHEN no_data_found then
				null;
	      END;

	      l_str_bsd := '<CHANGE-DINARS-TOTAL>'||substr(l_fm_l_total_change,1,length(l_fm_l_total_change)-3)||'</CHANGE-DINARS-TOTAL>';
	      l_str_bsf := '<CHANGE-FILLS-TOTAL>'||substr(l_fm_l_total_change,1,length(l_fm_l_total_change)-3)||'</CHANGE-FILLS-TOTAL>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	/***********      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>'); **********/
        EXIT;
      END IF;
    END LOOP;

    IF l_ter_processed = 1 AND l_new_processed = 1 AND l_cha_processed = 1 THEN
      l_all_processed := 1;
    END IF;
    dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
    END LOOP;

    dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);

    hr_utility.set_location('Finished creating xml data for Procedure FORM6 ',20);
EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
  END FORM7;
  -------------------------------------------------------------------------------------------
  PROCEDURE MCP
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS

    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'AE_BG_DETAILS';

     /*Cursor for fetching Employer Name*/
     CURSOR csr_employer_name IS
     SELECT name
     FROM   hr_organization_units
    WHERE  organization_id = p_employer_id;

     /*Cursor for fetching employees*/
    CURSOR csr_get_emp (l_employer number , l_date date , l_nat_cd varchar2) IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,ppa.date_earned
    FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_all_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.per_information18 = l_nat_cd;

    /* Cursor for fetching the person data */
    	CURSOR csr_get_person_data (l_person_id number,l_effective_date date) IS
    	SELECT ppf.full_name, ppf.employee_number
    	FROM	per_all_people_f ppf
    	WHERE 	ppf.person_id = l_person_id
    	AND	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching the person's assignment data */
    	CURSOR csr_get_person_asg_data (l_person_id number,l_effective_date date) IS
    	SELECT hsck.segment3
    	FROM	per_all_assignments_f paf,hr_soft_coding_keyflex hsck
    	WHERE 	paf.person_id = l_person_id
    	AND     paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    	AND     hsck.segment1 = p_employer_id
    	AND	l_effective_date between paf.effective_start_date and paf.effective_end_date;

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_bg_id number) IS
        SELECT  ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3,ORG_INFORMATION4,ORG_INFORMATION5,ORG_INFORMATION6,ORG_INFORMATION7,ORG_INFORMATION8,ORG_INFORMATION9,ORG_INFORMATION10
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_bg_id
        AND	org_information_context = 'AE_SI_DETAILS';

    /* Cursor for fetching Defined balance ids for UAE balances */
        CURSOR csr_get_seeded_def_bal_ids (l_user_name varchar2) IS
	SELECT  u.creator_id
    	FROM    ff_user_entities  u,ff_database_items d
    	WHERE   d.user_name = l_user_name
    	AND     u.user_entity_id = d.user_entity_id
    	AND     u.legislation_code = 'AE'
    	AND     u.business_group_id is null
    	AND     u.creator_type = 'B';

    TYPE def_bal_rec IS RECORD
    (def_bal_id                  NUMBER);
    TYPE t_def_bal_table IS TABLE OF def_bal_rec INDEX BY BINARY_INTEGER;
    t_store_def_bal   t_def_bal_table;
    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,date_start                DATE);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;
    l_employer_name varchar2(240);
    l_input_date varchar2(30);
    l_effective_date date;
    l_employer_ssn number;
    l_basic_sal_id number;
    z number;
    l_accomodation_id number;
    l_social_id number;
    l_child_social_id number;
    l_tp_id number;
    l_ol1_id number;
    l_ol2_id number;
    l_ol3_id number;
    l_ol4_id number;
    l_cost_of_living_id number;
    l_index number;
    i number;
    k number;
    m number;
    j number;
    x number;
    l_tot_count number;
    l_new_processed number;
    l_all_processed number;
    l_new_count number;
    l_basic_val number(15,2);
    l_accomodation_val number(15,2);
    l_allowance_1_val number(15,2);
    l_allowance_2_val number(15,2);
    l_allowance_3_val number(15,2);
    l_allowance_4_val number(15,2);
    l number;
    L_FULL_NAME varchar2(240);
    l_insured_ssn varchar2(30);
    L_TOTAL number(15,2);
    L_FM_TOTAL_VAL varchar2(100);
    l_fm_l_basic_val varchar2(100);
    L_FM_L_ACCOMODATION_VAL varchar2(100);
    L_FM_L_ALLOWANCE_1_VAL varchar2(100);
    L_FM_L_ALLOWANCE_2_VAL varchar2(100);
    L_FM_L_ALLOWANCE_3_VAL varchar2(100);
    L_FM_L_ALLOWANCE_4_VAL varchar2(100);
    l_total_basic number(15,2);
    l_total_aa number(15,2);
    l_total_a1 number(15,2);
    l_total_a2 number(15,2);
    l_total_a3 number(15,2);
    l_total_ee number(15,2);
    l_total_er number(15,2);
    l_total_total number(15,2);
    l_fm_total_basic varchar2(100);
    l_fm_total_aa varchar2(100);
    l_fm_total_a1 varchar2(100);
    l_fm_total_a2 varchar2(100);
    l_fm_total_a3 varchar2(100);
    l_fm_total_ee varchar2(100);
    l_fm_total_er varchar2(100);
    l_fm_total_total varchar2(100);
    rec_get_emp        csr_get_emp%ROWTYPE;
    l_xfdf_string              CLOB;
    l_str_er_name varchar2(240);
    l_str_er_ssn varchar2(240);
    l_str_ee_name varchar2(240);
    l_str_ee_ssn varchar2(240);
    l_str_year varchar2(240);
    l_str_month varchar2(240);
    l_str_seq_no varchar2(240);
    l_str_bsd varchar2(240);
    l_str_bsf varchar2(240);
    l_str_aad varchar2(240);
    l_str_aaf varchar2(240);
    l_str_a1d varchar2(240);
    l_str_a1f varchar2(240);
    l_str_a2d varchar2(240);
    l_str_a2f varchar2(240);
    l_str_a3d varchar2(240);
    l_str_a3f varchar2(240);
    l_str_a4d varchar2(240);
    l_str_a4f varchar2(240);
    l_str_a5d varchar2(240);
    l_str_a5f varchar2(240);
    l_ee_soc_ins_id number(15,2);
    l_er_soc_ins_id number(15,2);
    l_ee_soc_ins_adj_id number(15,2);
    l_er_soc_ins_adj_id number(15,2);
    l_ee_si_val number(15,2);
    l_er_si_val number(15,2);
    l_ee_si_adj_val number(15,2);
    l_er_si_adj_val number(15,2);
    l_er_contribution number(15,2);
    l_ee_contribution number(15,2);
    l_total_contribution number(15,2);
    l_fm_er_contribution varchar2(100);
    l_fm_ee_contribution varchar2(100);
    l_fm_total_contribution varchar2(100);
    l_employee_number varchar2(100);
    l_str_ee_eno varchar2(240);
    l_str_eecd varchar2(240);
    l_str_eecf varchar2(240);
    l_str_ercd varchar2(240);
    l_str_ercf varchar2(240);
    l_str_tcd varchar2(240);
    l_str_tcf varchar2(240);
    L_EE_SOC_INS_ARR_ID number;
    L_EE_SI_ARR_VAL number(15,2);
    l_subject_to_id number;
    l_nat_cd varchar2(30);

  BEGIN
    set_currency_mask(p_business_group_id);
    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);
    hr_utility.set_location('Entering FORM6 ',10);

    /* Fetch Local Nationality */
    OPEN csr_get_loc_nat;
    FETCH csr_get_loc_nat into l_nat_cd;
    CLOSE csr_get_loc_nat;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');

    OPEN csr_get_def_bal_ids (p_employer_id);
    FETCH csr_get_def_bal_ids into l_basic_sal_id,l_accomodation_id,l_social_id,l_child_social_id,l_cost_of_living_id,l_ol1_id,l_tp_id,l_ol2_id,l_ol3_id,l_ol4_id;
    CLOSE csr_get_def_bal_ids;

    OPEN csr_get_seeded_def_bal_ids ('EMPLOYEE_SOCIAL_INSURANCE_ASG_RUN'); /**** Change this to EMPLOYEE *******/
    FETCH csr_get_seeded_def_bal_ids into l_ee_soc_ins_id;
    CLOSE csr_get_seeded_def_bal_ids;

    OPEN csr_get_seeded_def_bal_ids ('EMPLOYER_SOCIAL_INSURANCE_ASG_RUN'); /**** Change this to EMPLOYER *******/
    FETCH csr_get_seeded_def_bal_ids into l_er_soc_ins_id;
    CLOSE csr_get_seeded_def_bal_ids;

    OPEN csr_get_seeded_def_bal_ids ('EMPLOYEE_SOCIAL_INSURANCE_ADJUSTMENT_ASG_RUN'); /**** Change this to EMPLOYEE *******/
    FETCH csr_get_seeded_def_bal_ids into l_ee_soc_ins_adj_id;
    CLOSE csr_get_seeded_def_bal_ids;

    OPEN csr_get_seeded_def_bal_ids ('EMPLOYER_SOCIAL_INSURANCE_ADJUSTMENT_ASG_RUN'); /**** Change this to EMPLOYER *******/
    FETCH csr_get_seeded_def_bal_ids into l_er_soc_ins_adj_id;
    CLOSE csr_get_seeded_def_bal_ids;

    OPEN csr_get_seeded_def_bal_ids ('EMPLOYEE_SOCIAL_INSURANCE_ARREARS_ASG_RUN'); /**** Change this to EMPLOYER *******/
    FETCH csr_get_seeded_def_bal_ids into l_ee_soc_ins_arr_id;
    CLOSE csr_get_seeded_def_bal_ids;

    OPEN csr_get_seeded_def_bal_ids ('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
    FETCH csr_get_seeded_def_bal_ids into l_subject_to_id;
    CLOSE csr_get_seeded_def_bal_ids;

    z := 1;
    t_store_def_bal(z).def_bal_id := l_basic_sal_id;
    z:= z+1;
    t_store_def_bal(z).def_bal_id := l_accomodation_id;
    z := z + 1;
    l_index := 2;
    LOOP
   	If l_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_social_id;
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_child_social_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_child_social_id;
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;
    	If l_cost_of_living_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_cost_of_living_id;
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_tp_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_tp_id;
    		z := z + 1;
    		l_index := l_index + 1;
		EXIT WHEN z > 6;
    	End if;
    	If l_ol1_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol1_id;
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol2_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol2_id;
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol3_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol3_id;
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If l_ol4_id is not null THEN
    		t_store_def_bal(z).def_bal_id := l_ol4_id;
    		z := z + 1;
    		l_index := l_index + 1;
    		EXIT WHEN z > 6;
    	End if;
    	If z < 7 then
    		WHILE Z <=7LOOP
    			t_store_def_bal(z).def_bal_id := NULL;
    			z := z + 1;
    			EXIT WHEN z >7;
    		END LOOP;
	End If;
    	EXIT WHEN z >= 7;
    END LOOP;
    i := 0;
    k := 0;
    m := 0;
    OPEN csr_get_emp(p_employer_id , l_effective_date , l_nat_cd);
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      i := i + 1;
      t_store_assact(i).person_id := rec_get_emp.person_id;
      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
      t_store_assact(i).date_start := rec_get_emp.date_earned;
    END LOOP;
    CLOSE csr_get_emp;
    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;
    l_all_processed := 0;
        j := 1;
    l_total_basic := 0 ;
    l_total_aa := 0 ;
    l_total_a1 := 0 ;
    l_total_a2 := 0 ;
    l_total_a3 := 0 ;
    l_total_ee := 0 ;
    l_total_er := 0 ;
    l_total_total := 0 ;

	l_tot_count := 0;

    WHILE l_all_processed  <> 1 LOOP
    --Writing data for new employees
    l_new_count := 0;
    l := 0;
      dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
    WHILE j <= i LOOP
/**** RESET ALL THE VARIABLES *****/
      l_basic_val := 0;
      l_accomodation_val := 0;
      l_allowance_1_val := 0;
      l_allowance_2_val := 0;
      l_allowance_3_val := 0;
      l_allowance_4_val := 0;
      l_total := 0;
      x := 1;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_basic_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_basic_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_accomodation_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_accomodation_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_1_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_1_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_2_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_allowance_2_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_allowance_3_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
      ELSE
      		l_allowance_3_val := 0;
      END IF;

      pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_effective_date));
      pay_balance_pkg.set_context('TAX_UNIT_ID',p_employer_id);

      l_ee_si_val := pay_balance_pkg.get_value(l_ee_soc_ins_id,t_store_assact(j).assignment_action_id);
      l_er_si_val := pay_balance_pkg.get_value(l_er_soc_ins_id,t_store_assact(j).assignment_action_id);
      l_ee_si_adj_val := pay_balance_pkg.get_value(l_ee_soc_ins_adj_id,t_store_assact(j).assignment_action_id);
      l_er_si_adj_val := pay_balance_pkg.get_value(l_er_soc_ins_adj_id,t_store_assact(j).assignment_action_id);
      l_ee_si_arr_val := pay_balance_pkg.get_value(l_ee_soc_ins_arr_id,t_store_assact(j).assignment_action_id);
      l_er_contribution := l_er_si_val + l_er_si_adj_val;
      l_ee_contribution := l_ee_si_val + l_ee_si_adj_val+l_ee_si_arr_val;
      l_total_contribution := l_er_contribution + l_ee_contribution;

      l_fm_ee_contribution := to_char(abs(l_ee_contribution),lg_format_mask);
      l_fm_er_contribution := to_char(abs(l_er_contribution),lg_format_mask);
      l_fm_total_contribution := to_char(abs(l_total_contribution) ,lg_format_mask);

      l_new_count := l_new_count+1;

      l_fm_l_basic_val := to_char(abs(l_basic_val),lg_format_mask);
      l_fm_l_accomodation_val := to_char(abs(l_accomodation_val),lg_format_mask);
      l_fm_l_allowance_1_val := to_char(abs(l_allowance_1_val),lg_format_mask);
      l_fm_l_allowance_2_val := to_char(abs(l_allowance_2_val),lg_format_mask);
      l_fm_l_allowance_3_val := to_char(abs(l_allowance_3_val),lg_format_mask);
      l_fm_l_allowance_4_val := to_char(abs(l_allowance_4_val),lg_format_mask);
      /*l_total := l_basic_val + l_accomodation_val + l_allowance_1_val + l_allowance_2_val + l_allowance_3_val + l_allowance_4_val;*/

      l_total := pay_balance_pkg.get_value(l_subject_to_id,t_store_assact(j).assignment_action_id);

      l_fm_total_val := to_char(abs(l_total),lg_format_mask);


		BEGIN
			SELECT decode(l_ee_contribution/(abs(decode(l_ee_contribution,0,1,l_ee_contribution))*-1),1,'-'||l_fm_ee_contribution,l_fm_ee_contribution)
			INTO l_fm_ee_contribution
			FROM dual;

			SELECT decode(l_er_contribution/(abs(decode(l_er_contribution,0,1,l_er_contribution))*-1),1,'-'||l_fm_er_contribution,l_fm_er_contribution)
			INTO l_fm_er_contribution
			FROM dual;

			SELECT decode(l_total_contribution/(abs(decode(l_total_contribution,0,1,l_total_contribution))*-1),1,'-'||l_fm_total_contribution,l_fm_total_contribution)
			INTO l_fm_total_contribution
			FROM dual;

			SELECT decode(l_basic_val/(abs(decode(l_basic_val,0,1,l_basic_val))*-1),1,'-'||l_fm_l_basic_val,l_fm_l_basic_val)
			INTO l_fm_l_basic_val
			FROM dual;

			SELECT decode(l_accomodation_val/(abs(decode(l_accomodation_val,0,1,l_accomodation_val))*-1),1,'-'||l_fm_l_accomodation_val,l_fm_l_accomodation_val)
			INTO l_fm_l_accomodation_val
			FROM dual;

			SELECT decode(l_allowance_1_val/(abs(decode(l_allowance_1_val,0,1,l_allowance_1_val))*-1),1,'-'||l_fm_l_allowance_1_val,l_fm_l_allowance_1_val)
			INTO l_fm_l_allowance_1_val
			FROM dual;

			SELECT decode(l_allowance_2_val/(abs(decode(l_allowance_2_val,0,1,l_allowance_2_val))*-1),1,'-'||l_fm_l_allowance_2_val,l_fm_l_allowance_2_val)
			INTO l_fm_l_allowance_2_val
			FROM dual;

			SELECT decode(l_allowance_3_val/(abs(decode(l_allowance_3_val,0,1,l_allowance_3_val))*-1),1,'-'||l_fm_l_allowance_3_val,l_fm_l_allowance_3_val)
			INTO l_fm_l_allowance_3_val
			FROM dual;

			SELECT decode(l_allowance_4_val/(abs(decode(l_allowance_4_val,0,1,l_allowance_4_val))*-1),1,'-'||l_fm_l_allowance_4_val,l_fm_l_allowance_4_val)
			INTO l_fm_l_allowance_4_val
			FROM dual;

			SELECT decode(l_total/(abs(decode(l_total,0,1,l_total))*-1),1,'-'||l_fm_total_val,l_fm_total_val)
			INTO l_fm_total_val
			FROM dual;

		EXCEPTION
			WHEN no_data_found then
				null;
	      END;

      OPEN csr_get_person_data(t_store_assact(j).person_id,l_effective_date);
      FETCH csr_get_person_data INTO l_full_name, l_employee_number;
      CLOSE csr_get_person_data;

      OPEN csr_get_person_asg_data(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_get_person_asg_data into l_insured_ssn;
      CLOSE csr_get_person_asg_data;

      l_str_er_name := '<ERNAME>'||l_employer_name||'</ERNAME>';
      l_str_year := '<YEAR>'||p_effective_year||'</YEAR>';
      l_str_month := '<MONTH>'||p_effective_month||'</MONTH>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_month), l_str_month);
	      l := l + 1;

	If l <> 11 then
		l_tot_count := l_tot_count + 1;
	End If;
      If l <> 11 then
	      l_str_seq_no := '<SER-' || l ||'>'||l_tot_count||'</SER-'|| l || '>';
	      l_str_ee_ssn :=  '<SSN-' || l || '>'||l_insured_ssn ||'</SSN-' || l || '>';
	      l_str_ee_eno :=  '<ENO-' || l || '>'||l_employee_number ||'</ENO-' || l || '>';
	      l_str_ee_name := '<EEN-'|| l || '>'|| initcap(substr(l_full_name,1,60)) ||'</EEN-'|| l || '>';
	      l_str_bsd := '<BSD-' || l ||'>'||substr(l_fm_l_basic_val,1,length(l_fm_l_basic_val)-3)||'</BSD-'|| l || '>';
	      l_str_bsf := '<BSF-' || l ||'>'||substr(l_fm_l_basic_val,length(l_fm_l_basic_val)-1)||'</BSF-'|| l || '>';
	      l_str_aad := '<AAD-' || l ||'>'||substr(l_fm_l_accomodation_val,1,length(l_fm_l_accomodation_val)-3)||'</AAD-'|| l || '>';
	      l_str_aaf := '<AAF-' || l ||'>'||substr(l_fm_l_accomodation_val,length(l_fm_l_accomodation_val)-1)||'</AAF-'|| l || '>';
	      l_str_a1d := '<A1D-' || l ||'>'||substr(l_fm_l_allowance_1_val,1,length(l_fm_l_allowance_1_val)-3)||'</A1D-'|| l || '>';
	      l_str_a1f := '<A1F-' || l ||'>'||substr(l_fm_l_allowance_1_val,length(l_fm_l_allowance_1_val)-1)||'</A1F-'|| l || '>';
	      l_str_a2d := '<A2D-' || l ||'>'||substr(l_fm_l_allowance_2_val,1,length(l_fm_l_allowance_2_val)-3)||'</A2D-'|| l || '>';
	      l_str_a2f := '<A2F-' || l ||'>'||substr(l_fm_l_allowance_2_val,length(l_fm_l_allowance_2_val)-1)||'</A2F-'|| l || '>';
	      l_str_a3d := '<A3D-' || l ||'>'||substr(l_fm_total_val,1,length(l_fm_total_val)-3)||'</A3D-'|| l || '>';
	      l_str_a3f := '<A3F-' || l ||'>'||substr(l_fm_total_val,length(l_fm_total_val)-1)||'</A3F-'|| l || '>';
	      l_str_eecd := '6<EECD-' || l ||'>'||substr(l_fm_ee_contribution,1,length(l_fm_ee_contribution)-3)||'</EECD-'|| l || '>';
	      l_str_eecf := '<EECF-' || l ||'>'||substr(l_fm_ee_contribution,length(l_fm_ee_contribution)-1)||'</EECF-'|| l || '>';
	      l_str_ercd := '<ERCD-' || l ||'>'||substr(l_fm_er_contribution,1,length(l_fm_er_contribution)-3)||'</ERCD-'|| l || '>';
	      l_str_ercf := '<ERCF-' || l ||'>'||substr(l_fm_er_contribution,length(l_fm_er_contribution)-1)||'</ERCF-'|| l || '>';
	      l_str_tcd := '<TCD-' || l ||'>'||substr(l_fm_total_contribution,1,length(l_fm_total_contribution)-3)||'</TCD-'|| l || '>';
	      l_str_tcf := '<TCF-' || l ||'>'||substr(l_fm_total_contribution,length(l_fm_total_contribution)-1)||'</TCF-'|| l || '>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_ssn), l_str_ee_ssn);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_eno), l_str_ee_eno);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_name), l_str_ee_name);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aad), l_str_aad);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aaf), l_str_aaf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2d), l_str_a2d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2f), l_str_a2f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3d), l_str_a3d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3f), l_str_a3f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_eecd), l_str_eecd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_eecf), l_str_eecf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ercd), l_str_ercd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ercf), l_str_ercf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_tcd), l_str_tcd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_tcf), l_str_tcf);
		l_total_basic := l_total_basic + l_basic_val;
		l_total_aa := l_total_aa + l_accomodation_val;
		l_total_a1 := l_total_a1 + l_allowance_1_val;
		l_total_a2 := l_total_a2 + l_allowance_2_val;
		l_total_a3 := l_total_a3 + l_total;
		l_total_ee := l_total_ee + l_ee_contribution;
		l_total_er := l_total_er + l_er_contribution;
		l_total_total := l_total_total + l_total_contribution;
	 ElsIf l = 11 then
		l_fm_total_basic :=  to_char(abs(l_total_basic),lg_format_mask);
		l_fm_total_aa :=to_char(abs(l_total_aa),lg_format_mask);
		l_fm_total_a1 := to_char(abs(l_total_a1),lg_format_mask);
		l_fm_total_a2 :=to_char(abs(l_total_a2),lg_format_mask);
		l_fm_total_a3 := to_char(abs(l_total_a3),lg_format_mask);
		l_fm_total_ee := to_char(abs(l_total_ee),lg_format_mask);
		l_fm_total_er := to_char(abs(l_total_er),lg_format_mask);
		l_fm_total_total := to_char(abs(l_total_total),lg_format_mask);

		BEGIN
			SELECT decode(l_total_basic/(abs(decode(l_total_basic,0,1,l_total_basic))*-1),1,'-'||l_fm_total_basic,l_fm_total_basic)
			INTO l_fm_total_basic
			FROM dual;

			SELECT decode(l_total_aa/(abs(decode(l_total_aa,0,1,l_total_aa))*-1),1,'-'||l_fm_total_aa,l_fm_total_aa)
			INTO l_fm_total_aa
			FROM dual;

			SELECT decode(l_total_a1/(abs(decode(l_total_a1,0,1,l_total_a1))*-1),1,'-'||l_fm_total_a1,l_fm_total_a1)
			INTO l_fm_total_a1
			FROM dual;

			SELECT decode(l_total_a2/(abs(decode(l_total_a2,0,1,l_total_a2))*-1),1,'-'||l_fm_total_a2,l_fm_total_a2)
			INTO l_fm_total_a2
			FROM dual;

			SELECT decode(l_total_a3/(abs(decode(l_total_a3,0,1,l_total_a3))*-1),1,'-'||l_fm_total_a3,l_fm_total_a3)
			INTO l_fm_total_a3
			FROM dual;

			SELECT decode(l_total_ee/(abs(decode(l_total_ee,0,1,l_total_ee))*-1),1,'-'||l_fm_total_ee,l_fm_total_ee)
			INTO l_fm_total_ee
			FROM dual;

			SELECT decode(l_total_er/(abs(decode(l_total_er,0,1,l_total_er))*-1),1,'-'||l_fm_total_er,l_fm_total_er)
			INTO l_fm_total_er
			FROM dual;

			SELECT decode(l_total_total/(abs(decode(l_total_total,0,1,l_total_total))*-1),1,'-'||l_fm_total_total,l_fm_total_total)
			INTO l_fm_total_total
			FROM dual;


		EXCEPTION
			WHEN no_data_found then
				null;
	      END;

	      l_str_bsd := '<BSD-' || l ||'>'||substr(l_fm_total_basic,1,length(l_fm_total_basic)-3)||'</BSD-'|| l || '>';
	      l_str_bsf := '<BSF-' || l ||'>'||substr(l_fm_total_basic,length(l_fm_total_basic)-1)||'</BSF-'|| l || '>';
	      l_str_aad := '<AAD-' || l ||'>'||substr(l_fm_total_aa,1,length(l_fm_total_aa)-3)||'</AAD-'|| l || '>';
	      l_str_aaf := '<AAF-' || l ||'>'||substr(l_fm_total_aa,length(l_fm_total_aa)-1)||'</AAF-'|| l || '>';
	      l_str_a1d := '<A1D-' || l ||'>'||substr(l_fm_total_a1,1,length(l_fm_total_a1)-3)||'</A1D-'|| l || '>';
	      l_str_a1f := '<A1F-' || l ||'>'||substr(l_fm_total_a1,length(l_fm_total_a1)-1)||'</A1F-'|| l || '>';
	      l_str_a2d := '<A2D-' || l ||'>'||substr(l_fm_total_a2,1,length(l_fm_total_a2)-3)||'</A2D-'|| l || '>';
	      l_str_a2f := '<A2F-' || l ||'>'||substr(l_fm_total_a2,length(l_fm_total_a2)-1)||'</A2F-'|| l || '>';
	      l_str_a3d := '<A3D-' || l ||'>'||substr(l_fm_total_a3,1,length(l_fm_total_a3)-3)||'</A3D-'|| l || '>';
	      l_str_a3f := '<A3F-' || l ||'>'||substr(l_fm_total_a3,length(l_fm_total_a3)-1)||'</A3F-'|| l || '>';
	      l_str_eecd := '<EECD-' || l ||'>'||substr(l_fm_total_ee,1,length(l_fm_total_ee)-3)||'</EECD-'|| l || '>';
	      l_str_eecf := '<EECF-' || l ||'>'||substr(l_fm_total_ee,length(l_fm_total_ee)-1)||'</EECF-'|| l || '>';
	      l_str_ercd := '<ERCD-' || l ||'>'||substr(l_fm_total_er,1,length(l_fm_total_er)-3)||'</ERCD-'|| l || '>';
	      l_str_ercf := '<ERCF-' || l ||'>'||substr(l_fm_total_er,length(l_fm_total_er)-1)||'</ERCF-'|| l || '>';
	      l_str_tcd := '<TCD-' || l ||'>'||substr(l_fm_total_total,1,length(l_fm_total_total)-3)||'</TCD-'|| l || '>';
	      l_str_tcf := '<TCF-' || l ||'>'||substr(l_fm_total_total,length(l_fm_total_total)-1)||'</TCF-'|| l || '>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aad), l_str_aad);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aaf), l_str_aaf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2d), l_str_a2d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2f), l_str_a2f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3d), l_str_a3d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3f), l_str_a3f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_eecd), l_str_eecd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_eecf), l_str_eecf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ercd), l_str_ercd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ercf), l_str_ercf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_tcd), l_str_tcd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_tcf), l_str_tcf);
	 End If;
	 If l <> 11 then
      		j := j + 1;
      	End if;
     IF j > i THEN
        l_new_processed := 1;
      END IF;
      IF l = 11/*8*/ THEN
      	dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
    	l_total_basic := 0 ;
    	l_total_aa := 0 ;
    	l_total_a1 := 0 ;
    	l_total_a2 := 0 ;
    	l_total_a3 := 0 ;
    	l_total_ee := 0 ;
    	l_total_er := 0 ;
    	l_total_total := 0 ;
      	l := 1;
        EXIT;
      END IF;
    END LOOP;
    IF l_new_processed = 1 THEN
      l_all_processed := 1;
	If l <> 11 then
		l_fm_total_basic :=  to_char(abs(l_total_basic),lg_format_mask);
		l_fm_total_aa :=to_char(abs(l_total_aa),lg_format_mask);
		l_fm_total_a1 := to_char(abs(l_total_a1),lg_format_mask);
		l_fm_total_a2 :=to_char(abs(l_total_a2),lg_format_mask);
		l_fm_total_a3 := to_char(abs(l_total_a3),lg_format_mask);
		l_fm_total_ee := to_char(abs(l_total_ee),lg_format_mask);
		l_fm_total_er := to_char(abs(l_total_er),lg_format_mask);
		l_fm_total_total := to_char(abs(l_total_total),lg_format_mask);

		BEGIN
			SELECT decode(l_total_basic/(abs(decode(l_total_basic,0,1,l_total_basic))*-1),1,'-'||l_fm_total_basic,l_fm_total_basic)
			INTO l_fm_total_basic
			FROM dual;

			SELECT decode(l_total_aa/(abs(decode(l_total_aa,0,1,l_total_aa))*-1),1,'-'||l_fm_total_aa,l_fm_total_aa)
			INTO l_fm_total_aa
			FROM dual;

			SELECT decode(l_total_a1/(abs(decode(l_total_a1,0,1,l_total_a1))*-1),1,'-'||l_fm_total_a1,l_fm_total_a1)
			INTO l_fm_total_a1
			FROM dual;

			SELECT decode(l_total_a2/(abs(decode(l_total_a2,0,1,l_total_a2))*-1),1,'-'||l_fm_total_a2,l_fm_total_a2)
			INTO l_fm_total_a2
			FROM dual;

			SELECT decode(l_total_a3/(abs(decode(l_total_a3,0,1,l_total_a3))*-1),1,'-'||l_fm_total_a3,l_fm_total_a3)
			INTO l_fm_total_a3
			FROM dual;

			SELECT decode(l_total_ee/(abs(decode(l_total_ee,0,1,l_total_ee))*-1),1,'-'||l_fm_total_ee,l_fm_total_ee)
			INTO l_fm_total_ee
			FROM dual;

			SELECT decode(l_total_er/(abs(decode(l_total_er,0,1,l_total_er))*-1),1,'-'||l_fm_total_er,l_fm_total_er)
			INTO l_fm_total_er
			FROM dual;

			SELECT decode(l_total_total/(abs(decode(l_total_total,0,1,l_total_total))*-1),1,'-'||l_fm_total_total,l_fm_total_total)
			INTO l_fm_total_total
			FROM dual;


		EXCEPTION
			WHEN no_data_found then
				null;
	      END;

	      l_str_bsd := '<BSD-' || 11 ||'>'||substr(l_fm_total_basic,1,length(l_fm_total_basic)-3)||'</BSD-'|| 11 || '>';
	      l_str_bsf := '<BSF-' || 11 ||'>'||substr(l_fm_total_basic,length(l_fm_total_basic)-1)||'</BSF-'|| 11 || '>';
	      l_str_aad := '<AAD-' || 11 ||'>'||substr(l_fm_total_aa,1,length(l_fm_total_aa)-3)||'</AAD-'|| 11 || '>';
	      l_str_aaf := '<AAF-' || 11 ||'>'||substr(l_fm_total_aa,length(l_fm_total_aa)-1)||'</AAF-'|| 11 || '>';
	      l_str_a1d := '<A1D-' || 11 ||'>'||substr(l_fm_total_a1,1,length(l_fm_total_a1)-3)||'</A1D-'|| 11 || '>';
	      l_str_a1f := '<A1F-' || 11 ||'>'||substr(l_fm_total_a1,length(l_fm_total_a1)-1)||'</A1F-'|| 11 || '>';
	      l_str_a2d := '<A2D-' || 11 ||'>'||substr(l_fm_total_a2,1,length(l_fm_total_a2)-3)||'</A2D-'|| 11 || '>';
	      l_str_a2f := '<A2F-' || 11 ||'>'||substr(l_fm_total_a2,length(l_fm_total_a2)-1)||'</A2F-'|| 11 || '>';
	      l_str_a3d := '<A3D-' || 11 ||'>'||substr(l_fm_total_a3,1,length(l_fm_total_a3)-3)||'</A3D-'|| 11 || '>';
	      l_str_a3f := '<A3F-' ||11 ||'>'||substr(l_fm_total_a3,length(l_fm_total_a3)-1)||'</A3F-'|| 11 || '>';
	      l_str_eecd := '<EECD-' || 11 ||'>'||substr(l_fm_total_ee,1,length(l_fm_total_ee)-3)||'</EECD-'|| 11 || '>';
	      l_str_eecf := '<EECF-' ||11 ||'>'||substr(l_fm_total_ee,length(l_fm_total_ee)-1)||'</EECF-'|| 11 || '>';
	      l_str_ercd := '<ERCD-' || 11 ||'>'||substr(l_fm_total_er,1,length(l_fm_total_er)-3)||'</ERCD-'|| 11 || '>';
	      l_str_ercf := '<ERCF-' || 11 ||'>'||substr(l_fm_total_er,length(l_fm_total_er)-1)||'</ERCF-'|| 11 || '>';
	      l_str_tcd := '<TCD-' || 11 ||'>'||substr(l_fm_total_total,1,length(l_fm_total_total)-3)||'</TCD-'|| 11 || '>';
	      l_str_tcf := '<TCF-' || 11 ||'>'||substr(l_fm_total_total,length(l_fm_total_total)-1)||'</TCF-'|| 11 || '>';
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aad), l_str_aad);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_aaf), l_str_aaf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1d), l_str_a1d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a1f), l_str_a1f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2d), l_str_a2d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a2f), l_str_a2f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3d), l_str_a3d);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_a3f), l_str_a3f);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_eecd), l_str_eecd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_eecf), l_str_eecf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ercd), l_str_ercd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ercf), l_str_ercf);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_tcd), l_str_tcd);
	      dbms_lob.writeAppend( l_xfdf_string, length(l_str_tcf), l_str_tcf);
	end if;
	If l <> 11 then
	      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
	End If;
      EXIT;
    END IF;
    END LOOP;
    dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    hr_utility.set_location('Finished creating xml data for Procedure FORM6 ',20);
/*EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;*/
  END MCP;
  -------------------------------------------------------------------------------------------
    PROCEDURE MCF
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    )
   AS

    /*Cursor for fetching Local nationality for the BG */
     CURSOR csr_get_loc_nat IS
     SELECT org_information1
     FROM   hr_organization_information
     WHERE  organization_id = p_business_group_id
     AND    org_information_context = 'AE_BG_DETAILS';

   /*Cursor for fetching Employer Name*/
     CURSOR csr_employer_name IS
     SELECT name
     FROM   hr_organization_units
     WHERE  organization_id = p_employer_id;

   /*Cursor for fetching employees*/
    CURSOR csr_get_emp (l_employer number , l_date date , l_nat_cd varchar2) IS
    SELECT distinct asg.person_id
                    ,paa.assignment_action_id
                    ,ppa.date_earned
    FROM   per_all_assignments_f asg
           ,pay_assignment_actions paa
           ,pay_payroll_actions ppa
           ,hr_soft_coding_keyflex hscl
           ,per_periods_of_service pos
           ,per_all_people_f ppf
    WHERE  asg.assignment_id = paa.assignment_id
    AND    paa.payroll_action_id = ppa.payroll_action_id
    AND    pos.period_of_service_id = asg.period_of_service_id
    AND    ppa.action_type in ('R','Q')
    AND    ppa.action_status = 'C'
    AND    paa.action_status = 'C'
    AND    trunc(ppa.date_earned,'MM') = TRUNC(l_date, 'MM')
    AND    trunc(l_date, 'MM') between trunc(asg.effective_start_date,'MM') and asg.effective_end_date
    AND    hscl.soft_coding_keyflex_id = asg.soft_coding_keyflex_id
    AND    hscl.segment1 = to_char(l_employer)
    AND    ppf.person_id = asg.person_id
    AND    trunc(l_date, 'MM') between trunc(ppf.effective_start_date,'MM') and ppf.effective_end_date
    AND    ppf.per_information18 = l_nat_cd;

    /* Cursor for fetching the person data */
    	CURSOR csr_get_person_data (l_person_id number,l_effective_date date) IS
    	SELECT ppf.full_name, ppf.employee_number
    	FROM	per_all_people_f ppf
    	WHERE 	ppf.person_id = l_person_id
    	AND	l_effective_date between ppf.effective_start_date and ppf.effective_end_date;

    /* Cursor for fetching the person's assignment data */
    	CURSOR csr_get_person_asg_data (l_person_id number,l_effective_date date) IS
    	SELECT hsck.segment3
    	FROM	per_all_assignments_f paf,hr_soft_coding_keyflex hsck
    	WHERE 	paf.person_id = l_person_id
    	AND     paf.soft_coding_keyflex_id = hsck.soft_coding_keyflex_id
    	AND     hsck.segment1 = p_employer_id
    	AND	l_effective_date between paf.effective_start_date and paf.effective_end_date;

    /* Cursor for fetching Defined balance ids from Org EIT */
        CURSOR csr_get_def_bal_ids (l_bg_id number) IS
        SELECT  ORG_INFORMATION1,ORG_INFORMATION2,ORG_INFORMATION3,ORG_INFORMATION4,ORG_INFORMATION5,ORG_INFORMATION6,ORG_INFORMATION7,ORG_INFORMATION8,ORG_INFORMATION9,ORG_INFORMATION10
        FROM    HR_ORGANIZATION_INFORMATION
        WHERE   Organization_id = l_bg_id
        AND	org_information_context = 'AE_SI_DETAILS';

   /* Cursor to retrieve Defined Balance Id */
        CURSOR csr_def_bal_id(p_user_name VARCHAR2) IS
	SELECT  u.creator_id
	FROM    ff_user_entities  u,
	        ff_database_items d
	WHERE   d.user_name = p_user_name
	AND     u.user_entity_id = d.user_entity_id
	AND     (u.legislation_code = 'AE' )
	AND     (u.business_group_id IS NULL )
	AND     u.creator_type = 'B';

    TYPE def_bal_rec IS RECORD
    (def_bal_id                  NUMBER);
    TYPE t_def_bal_table IS TABLE OF def_bal_rec INDEX BY BINARY_INTEGER;
    t_store_def_bal   t_def_bal_table;
    TYPE assact_rec IS RECORD
    (person_id                 NUMBER
    ,assignment_action_id      NUMBER
    ,date_start                DATE);
    TYPE t_assact_table IS TABLE OF assact_rec INDEX BY BINARY_INTEGER;
    t_store_assact   t_assact_table;
    l_employer_name varchar2(240);
    l_input_date varchar2(30);
    l_effective_date date;
    l_employer_ssn number;
    l_basic_sal_id number;
    z number;
    l_accommodation_id number;
    l_social_id number;
    l_child_social_id number;
    l_tp_id number;
    l_ol1_id number;
    l_ol2_id number;
    l_ol3_id number;
    l_ol4_id number;
    l_cost_of_living_id number;
    l_index number;
    i number;
    k number;
    m number;
    j number;
    x number;
    l_new_processed number;
    l_all_processed number;
    l_new_count number;
    l_basic_val number(15,2);
    l_accommodation_val number(15,2);
    l_cost_of_living_val number(15,2);
    l_child_allow_val number(15,2);
    l_social_allow_val number(15,2);
    l number;
    l_full_name varchar2(240);
    l_emp_ssn varchar2(30);
    l_employee_cont number(15,2);
    l_employer_cont number(15,2);
    l_employee_adj_cont number(15,2);
    l_employer_adj_cont number(15,2);
    l_total_cont number(15,2);
    l_basic_total number(15,2) := 0;
    l_col_total number(15,2) := 0;
    l_social_total number(15,2) := 0;
    l_child_total number(15,2) := 0;
    l_acco_total number(15,2) := 0;
    l_total_allow_total number(15,2) := 0;
    l_total_ee_cont_total number(15,2) := 0;
    l_total_er_cont_total number(15,2) := 0;
    l_total_cont_total number(15,2) := 0;
    L_TOTAL number(15,2);
    L_FM_TOTAL_VAL varchar2(100);
    l_fm_l_basic_val varchar2(100);
    l_fm_l_accommodation_val varchar2(100);
    l_fm_l_cost_of_living_val varchar2(100);
    l_fm_l_child_allow_val varchar2(100);
    l_fm_l_social_allow_val varchar2(100);
    l_fm_l_total_allow_total varchar2(100);
    l_fm_l_basic_total varchar2(100);
    l_fm_l_col_total varchar2(100);
    l_fm_l_social_total varchar2(100);
    l_fm_l_child_total varchar2(100);
    l_fm_l_acco_total varchar2(100);
    l_fm_ee_cont_total varchar2(240);
    l_fm_er_cont_total varchar2(240);
    l_fm_total_cont varchar2(240);
    l_fm_total_ee_cont_total varchar2(240);
    l_fm_total_er_cont_total varchar2(240);
    l_fm_total_cont_total varchar2(240);
    rec_get_emp        csr_get_emp%ROWTYPE;
    l_xfdf_string              CLOB;
    l_str_er_name varchar2(240);
    l_str_er_ssn varchar2(240);
    l_str_ee_name varchar2(240);
    l_str_ee_ssn varchar2(240);
    l_str_year varchar2(240);
    l_str_month varchar2(240);
    l_str_seq_no varchar2(240);
    l_str_bsd varchar2(240);
    l_str_bsf varchar2(240);
    l_str_cold varchar2(240);
    l_str_colf varchar2(240);
    l_str_socd varchar2(240);
    l_str_socf varchar2(240);
    l_str_chd varchar2(240);
    l_str_chf varchar2(240);
    l_str_accd varchar2(240);
    l_str_accf varchar2(240);
    l_str_total_dinars varchar2(240);
    l_str_total_fills varchar2(240);
    l_str_total_allow_total_f varchar2(240);
    l_str_total_allow_total_d varchar2(240);
    l_str_ee_cont_f_total varchar2(240);
    l_str_ee_cont_d_total varchar2(240);
    l_str_er_cont_f_total varchar2(240);
    l_str_er_cont_d_total varchar2(240);
    l_str_total_cont_f varchar2(240);
    l_str_total_cont_d varchar2(240);
    l_str_bf_total varchar2(240);
    l_str_bd_total varchar2(240);
    l_str_colf_total varchar2(240);
    l_str_cold_total varchar2(240);
    l_str_socf_total varchar2(240);
    l_str_socd_total varchar2(240);
    l_str_chf_total varchar2(240);
    l_str_chd_total varchar2(240);
    l_str_accf_total varchar2(240);
    l_str_accd_total varchar2(240);
    l_str_total_ee_cont_f_total varchar2(240);
    l_str_total_ee_cont_d_total varchar2(240);
    l_str_total_er_cont_f_total varchar2(240);
    l_str_total_er_cont_d_total varchar2(240);
    l_str_total_cont_f_total varchar2(240);
    l_str_total_cont_d_total varchar2(240);

    l_employee_number varchar2(100);
    l_str_ee_eno varchar2(240);
    l_defined_balance_id number;
    L_EMPLOYEE_ARR_CONT number(15,2);
    l_nat_cd varchar2(30);

   BEGIN

    set_currency_mask(p_business_group_id);
    l_input_date := '01-'||p_effective_month||'-'||p_effective_year;
    l_effective_date := last_day(to_date(l_input_date,'DD-MM-YYYY'));
    INSERT INTO fnd_sessions (session_id, effective_date)
    VALUES (userenv('sessionid'), l_effective_date);
    hr_utility.set_location('Entering Monthly Contribution Federal',10);

    /* Fetch Local Nationality */
    OPEN csr_get_loc_nat;
    FETCH csr_get_loc_nat into l_nat_cd;
    CLOSE csr_get_loc_nat;

    /*Fetch Employer Name*/
    OPEN csr_employer_name;
    FETCH csr_employer_name INTO l_employer_name;
    CLOSE csr_employer_name;

    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    dbms_lob.writeAppend( l_xfdf_string, length('<START>'),'<START>');

    /* Fetch Defined Balance IDs from EIT */
    OPEN csr_get_def_bal_ids (p_employer_id);
    FETCH csr_get_def_bal_ids into l_basic_sal_id,l_accommodation_id,l_social_id,l_child_social_id,l_cost_of_living_id,l_ol1_id,l_tp_id,l_ol2_id,l_ol3_id,l_ol4_id;
    CLOSE csr_get_def_bal_ids;

    z := 1;
    t_store_def_bal(z).def_bal_id := l_basic_sal_id;
    z := z + 1;
    t_store_def_bal(z).def_bal_id := l_cost_of_living_id;
    z := z + 1;
    t_store_def_bal(z).def_bal_id := l_social_id;
    z := z + 1;
    t_store_def_bal(z).def_bal_id := l_child_social_id;
    z := z + 1;
    t_store_def_bal(z).def_bal_id := l_accommodation_id;
    z := z + 1;
    i := 0;
    k := 0;
    m := 0;
    /* Fetch Employee Details */
    OPEN csr_get_emp(p_employer_id , l_effective_date , l_nat_cd);
    LOOP
      FETCH csr_get_emp INTO rec_get_emp;
      EXIT WHEN csr_get_emp%NOTFOUND;
      i := i + 1;
      t_store_assact(i).person_id := rec_get_emp.person_id;
      t_store_assact(i).assignment_action_id := rec_get_emp.assignment_action_id;
      t_store_assact(i).date_start := rec_get_emp.date_earned;
    END LOOP;
    CLOSE csr_get_emp;
    IF i > 0  THEN
      l_new_processed := 0;
    ELSE
      l_new_processed := 1;
    END IF;
    l_all_processed := 0;
        j := 1;
        l := 1;
    WHILE l_all_processed  <> 1 LOOP
    --Writing data for new employees
    l_new_count := 0;
      dbms_lob.writeAppend( l_xfdf_string, length('<EMP-REC>'),'<EMP-REC>');
    WHILE j <= i LOOP
/**** RESET ALL THE VARIABLES *****/
      l_basic_val := 0;
      l_cost_of_living_val := 0;
      l_social_allow_val := 0;
      l_child_allow_val := 0;
      l_accommodation_val := 0;
      l_total := 0;
      l_employee_cont := 0;
      l_employer_cont := 0;
      l_employee_adj_cont := 0;
      l_employer_adj_cont := 0;
      x := 1;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_basic_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_basic_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_cost_of_living_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_cost_of_living_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_social_allow_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_social_allow_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_child_allow_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_child_allow_val := 0;
      		x:= x + 1;
      END IF;
      IF t_store_def_bal(x).def_bal_id is not null THEN
		l_accommodation_val := pay_balance_pkg.get_value(t_store_def_bal(x).def_bal_id,t_store_assact(j).assignment_action_id);
		x:= x + 1;
      ELSE
      		l_accommodation_val := 0;
      		x:= x + 1;
      END IF;

      l_new_count := l_new_count + 1;
      l_fm_l_basic_val := to_char(abs(l_basic_val),lg_format_mask);
      l_fm_l_cost_of_living_val := to_char(abs(l_cost_of_living_val),lg_format_mask);
      l_fm_l_social_allow_val := to_char(abs(l_social_allow_val),lg_format_mask);
      l_fm_l_child_allow_val := to_char(abs(l_child_allow_val),lg_format_mask);
      l_fm_l_accommodation_val := to_char(abs(l_accommodation_val),lg_format_mask);

		BEGIN
			SELECT decode(l_basic_val/(abs(decode(l_basic_val,0,1,l_basic_val))*-1),1,'-'||l_fm_l_basic_val,l_fm_l_basic_val)
			INTO l_fm_l_basic_val
			FROM dual;

			SELECT decode(l_cost_of_living_val/(abs(decode(l_cost_of_living_val,0,1,l_cost_of_living_val))*-1),1,'-'||l_fm_l_cost_of_living_val,l_fm_l_cost_of_living_val)
			INTO l_fm_l_cost_of_living_val
			FROM dual;

			SELECT decode(l_social_allow_val/(abs(decode(l_social_allow_val,0,1,l_social_allow_val))*-1),1,'-'||l_fm_l_social_allow_val,l_fm_l_social_allow_val)
			INTO l_fm_l_social_allow_val
			FROM dual;

			SELECT decode(l_child_allow_val/(abs(decode(l_child_allow_val,0,1,l_child_allow_val))*-1),1,'-'||l_fm_l_child_allow_val,l_fm_l_child_allow_val)
			INTO l_fm_l_child_allow_val
			FROM dual;

			SELECT decode(l_accommodation_val/(abs(decode(l_accommodation_val,0,1,l_accommodation_val))*-1),1,'-'||l_fm_l_accommodation_val,l_fm_l_accommodation_val)
			INTO l_fm_l_accommodation_val
			FROM dual;


		EXCEPTION
			WHEN no_data_found then
				null;
	      END;


      /* Fetch balance values for Employee SI Contribution and Employer SI Contribution */
      pay_balance_pkg.set_context('DATE_EARNED',fnd_date.date_to_canonical(l_effective_date));
      pay_balance_pkg.set_context('TAX_UNIT_ID',p_employer_id);

      OPEN csr_def_bal_id('EMPLOYEE_SOCIAL_INSURANCE_ADJUSTMENT_ASG_RUN');
      FETCH csr_def_bal_id INTO l_defined_balance_id;
      CLOSE csr_def_bal_id;

      l_employee_adj_cont := pay_balance_pkg.get_value(l_defined_balance_id,t_store_assact(j).assignment_action_id);
      OPEN csr_def_bal_id('EMPLOYEE_SOCIAL_INSURANCE_ARREARS_ASG_RUN');
	FETCH csr_def_bal_id INTO l_defined_balance_id;
      CLOSE csr_def_bal_id;

      l_employee_arr_cont := pay_balance_pkg.get_value(l_defined_balance_id,t_store_assact(j).assignment_action_id);
      OPEN csr_def_bal_id('EMPLOYEE_SOCIAL_INSURANCE_ASG_RUN');
	FETCH csr_def_bal_id INTO l_defined_balance_id;
      CLOSE csr_def_bal_id;

      l_employee_cont := pay_balance_pkg.get_value(l_defined_balance_id,t_store_assact(j).assignment_action_id) + l_employee_adj_cont + l_employee_arr_cont;
      OPEN csr_def_bal_id('EMPLOYER_SOCIAL_INSURANCE_ADJUSTMENT_ASG_RUN');
	FETCH csr_def_bal_id INTO l_defined_balance_id;
      CLOSE csr_def_bal_id;

      l_employer_adj_cont := pay_balance_pkg.get_value(l_defined_balance_id,t_store_assact(j).assignment_action_id);
      OPEN csr_def_bal_id('EMPLOYER_SOCIAL_INSURANCE_ASG_RUN');
	FETCH csr_def_bal_id INTO l_defined_balance_id;
      CLOSE csr_def_bal_id;

      l_employer_cont := pay_balance_pkg.get_value(l_defined_balance_id,t_store_assact(j).assignment_action_id) + l_employer_adj_cont;
      OPEN csr_def_bal_id('SUBJECT_TO_SOCIAL_INSURANCE_ASG_RUN');
	FETCH csr_def_bal_id INTO l_defined_balance_id;
      CLOSE csr_def_bal_id;

      l_total := pay_balance_pkg.get_value(l_defined_balance_id,t_store_assact(j).assignment_action_id);
      l_fm_total_val := to_char(abs(l_total),lg_format_mask);
      l_total_cont := l_employee_cont + l_employer_cont;
      l_fm_ee_cont_total := to_char(abs(l_employee_cont),lg_format_mask);
      l_fm_er_cont_total := to_char(abs(l_employer_cont),lg_format_mask);
      l_fm_total_cont := to_char(abs(l_total_cont),lg_format_mask);


		BEGIN
			SELECT decode(l_total/(abs(decode(l_total,0,1,l_total))*-1),1,'-'||l_fm_total_val,l_fm_total_val)
			INTO l_fm_total_val
			FROM dual;

			SELECT decode(l_employee_cont/(abs(decode(l_employee_cont,0,1,l_employee_cont))*-1),1,'-'||l_fm_ee_cont_total,l_fm_ee_cont_total)
			INTO l_fm_ee_cont_total
			FROM dual;

			SELECT decode(l_employer_cont/(abs(decode(l_employer_cont,0,1,l_employer_cont))*-1),1,'-'||l_fm_er_cont_total,l_fm_er_cont_total)
			INTO l_fm_er_cont_total
			FROM dual;

			SELECT decode(l_total_cont/(abs(decode(l_total_cont,0,1,l_total_cont))*-1),1,'-'||l_fm_total_cont,l_fm_total_cont)
			INTO l_fm_total_cont
			FROM dual;

		EXCEPTION
			WHEN no_data_found then
				null;
	      END;

      /* Fetch Person details */
      OPEN csr_get_person_data(t_store_assact(j).person_id,l_effective_date);
      FETCH csr_get_person_data INTO l_full_name,l_employee_number;
      CLOSE csr_get_person_data;

      OPEN csr_get_person_asg_data(t_store_assact(j).person_id, l_effective_date);
      FETCH csr_get_person_asg_data into l_emp_ssn;
      CLOSE csr_get_person_asg_data;

      l_str_er_name := '<EMPLOYER_NAME>'||l_employer_name||'</EMPLOYER_NAME>';
      l_str_year := '<YEAR>'||p_effective_year||'</YEAR>';
      l_str_month := '<MONTH>' || p_effective_month || '</MONTH>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_name), l_str_er_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_year), l_str_year);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_month), l_str_month);

      /* Write into allowances columns and Employee Details columns */
      l_str_seq_no := '<SER-' || l ||'>'||l||'</SER-'|| l || '>';
      l_str_ee_ssn :=  '<SSN-' || l || '>'||l_emp_ssn ||'</SSN-' || l || '>';
      l_str_ee_eno :=  '<EMPLOYEE-NUMBER-' || l || '>'||l_employee_number ||'</EMPLOYEE-NUMBER-' || l || '>';
      l_str_ee_name := '<EMPLOYEE-NAME-'|| l || '>'|| substr(l_full_name,1,60) ||'</EMPLOYEE-NAME-'|| l || '>';
      l_str_bsd := '<BASIC-SALARY-DINARS-' || l ||'>'||substr(l_fm_l_basic_val,1,length(l_fm_l_basic_val)-3)||'</BASIC-SALARY-DINARS-'|| l || '>';
      l_str_bsf := '<BASIC-SALARY-FILLS-' || l ||'>'||substr(l_fm_l_basic_val,length(l_fm_l_basic_val)-1)||'</BASIC-SALARY-FILLS-'|| l || '>';
      l_str_cold := '<COL-DINARS-'|| l || '>' ||substr(l_fm_l_cost_of_living_val,1,length(l_fm_l_cost_of_living_val)-3)||'</COL-DINARS-'|| l || '>';
      l_str_colf := '<COL-FILLS-'|| l || '>' ||substr(l_fm_l_cost_of_living_val,length(l_fm_l_cost_of_living_val)-1)||'</COL-FILLS-'|| l || '>';
      l_str_socd := '<SOCIAL-DINARS-'|| l || '>' ||substr(l_fm_l_social_allow_val,1,length(l_fm_l_social_allow_val)-3)||'</SOCIAL-DINARS-'|| l || '>';
      l_str_socf := '<SOCIAL-FILLS-'|| l || '>' ||substr(l_fm_l_social_allow_val,length(l_fm_l_social_allow_val)-1)||'</SOCIAL-FILLS-'|| l || '>';
      l_str_chd := '<CHILD-DINARS-'|| l || '>' ||substr(l_fm_l_child_allow_val,1,length(l_fm_l_child_allow_val)-3)||'</CHILD-DINARS-'|| l || '>';
      l_str_chf := '<CHILD-FILLS-'|| l || '>' ||substr(l_fm_l_child_allow_val,length(l_fm_l_child_allow_val)-1)||'</CHILD-FILLS-'|| l || '>';
      l_str_accd := '<HOUSING-DINARS-'|| l || '>' ||substr(l_fm_l_accommodation_val,1,length(l_fm_l_accommodation_val)-3)||'</HOUSING-DINARS-'|| l || '>';
      l_str_accf := '<HOUSING-FILLS-'|| l || '>' ||substr(l_fm_l_accommodation_val,length(l_fm_l_accommodation_val)-1)||'</HOUSING-FILLS-'|| l || '>';
      l_str_total_dinars := '<TOTAL-DINARS-'|| l || '>' ||substr(l_fm_total_val,1,length(l_fm_total_val)-3)||'</TOTAL-DINARS-'|| l || '>';
      l_str_total_fills := '<TOTAL-FILLS-'|| l || '>' ||substr(l_fm_total_val,length(l_fm_total_val)-1)||'</TOTAL-FILLS-'|| l || '>';
      /* Write into contribution columns */
      l_str_ee_cont_f_total := '<INSURANCE-CONT-FILLS-'|| l || '>' ||substr(l_fm_ee_cont_total,length(l_fm_ee_cont_total)-1)||'</INSURANCE-CONT-FILLS-'|| l || '>';
      l_str_ee_cont_d_total := '<INSURED-CONT-DINARS-' || l ||'>'||substr(l_fm_ee_cont_total,1,length(l_fm_ee_cont_total)-3)||'</INSURED-CONT-DINARS-'|| l || '>';
      l_str_er_cont_f_total := '<EMPLOYER-CONT-FILLS-'|| l || '>' ||substr(l_fm_er_cont_total,length(l_fm_er_cont_total)-1)||'</EMPLOYER-CONT-FILLS-'|| l || '>';
      l_str_er_cont_d_total := '<EMPLOYER-CONT-DINARS-' || l ||'>'||substr(l_fm_er_cont_total,1,length(l_fm_er_cont_total)-3)||'</EMPLOYER-CONT-DINARS-'|| l || '>';
      l_str_total_cont_f := '<TOTAL-CONT-FILLS-'|| l || '>' ||substr(l_fm_total_cont,length(l_fm_total_cont)-1)||'</TOTAL-CONT-FILLS-'|| l || '>';
      l_str_total_cont_d := '<TOTAL-CONT-DINARS-' || l ||'>'||substr(l_fm_total_cont,1,length(l_fm_total_cont)-3)||'</TOTAL-CONT-DINARS-'|| l || '>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_seq_no), l_str_seq_no);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_ssn), l_str_ee_ssn);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_eno), l_str_ee_eno);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_name), l_str_ee_name);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsd), l_str_bsd);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bsf), l_str_bsf);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_cold), l_str_cold);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_colf), l_str_colf);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_socd), l_str_socd);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_socf), l_str_socf);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_chd), l_str_chd);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_chf), l_str_chf);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_accd), l_str_accd);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_accf), l_str_accf);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_dinars), l_str_total_dinars);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_fills), l_str_total_fills);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_cont_f_total), l_str_ee_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_ee_cont_d_total), l_str_ee_cont_d_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_cont_f_total), l_str_er_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_er_cont_d_total), l_str_er_cont_d_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_cont_f), l_str_total_cont_f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_cont_d), l_str_total_cont_d);
      /* Calculate the total values of allowances for each row */
      l_basic_total := l_basic_total + l_basic_val;
      l_col_total := l_col_total + l_cost_of_living_val;
      l_social_total := l_social_total + l_social_allow_val;
      l_child_total := l_child_total + l_child_allow_val;
      l_acco_total := l_acco_total + l_accommodation_val;
      l_total_allow_total := l_total_allow_total + l_total;
      /* Calculate the total contribution of Employees and Employers, i.e., for last 6 (dinars and fills included) columns of report */
      l_total_ee_cont_total := l_total_ee_cont_total + l_employee_cont;
      l_total_er_cont_total := l_total_er_cont_total + l_employer_cont;
      l_total_cont_total := l_total_cont_total + l_total_cont;

      l_fm_l_basic_total := to_char(abs(l_basic_total),lg_format_mask);
      l_fm_l_col_total := to_char(abs(l_basic_total),lg_format_mask);
      l_fm_l_social_total := to_char(abs(l_social_total),lg_format_mask);
      l_fm_l_child_total := to_char(abs(l_child_total),lg_format_mask);
      l_fm_l_acco_total := to_char(abs(l_acco_total),lg_format_mask);
      l_fm_l_total_allow_total := to_char(abs(l_total_allow_total),lg_format_mask);
      l_fm_total_ee_cont_total := to_char(abs(l_total_ee_cont_total),lg_format_mask);
      l_fm_total_er_cont_total := to_char(abs(l_total_er_cont_total),lg_format_mask);
      l_fm_total_cont_total := to_char(abs(l_total_cont_total),lg_format_mask);

		BEGIN
			SELECT decode(l_basic_total/(abs(decode(l_basic_total,0,1,l_basic_total))*-1),1,'-'||l_fm_l_basic_total,l_fm_l_basic_total)
			INTO l_fm_l_basic_total
			FROM dual;

			SELECT decode(l_basic_total/(abs(decode(l_basic_total,0,1,l_basic_total))*-1),1,'-'||l_fm_l_col_total,l_fm_l_col_total)
			INTO l_fm_l_col_total
			FROM dual;

			SELECT decode(l_social_total/(abs(decode(l_social_total,0,1,l_social_total))*-1),1,'-'||l_fm_l_social_total,l_fm_l_social_total)
			INTO l_fm_l_social_total
			FROM dual;

			SELECT decode(l_child_total/(abs(decode(l_child_total,0,1,l_child_total))*-1),1,'-'||l_fm_l_child_total,l_fm_l_child_total)
			INTO l_fm_l_child_total
			FROM dual;

			SELECT decode(l_acco_total/(abs(decode(l_acco_total,0,1,l_acco_total))*-1),1,'-'||l_fm_l_acco_total,l_fm_l_acco_total)
			INTO l_fm_l_acco_total
			FROM dual;

			SELECT decode(l_total_allow_total/(abs(decode(l_total_allow_total,0,1,l_total_allow_total))*-1),1,'-'||l_fm_l_total_allow_total,l_fm_l_total_allow_total)
			INTO l_fm_l_total_allow_total
			FROM dual;

			SELECT decode(l_total_ee_cont_total/(abs(decode(l_total_ee_cont_total,0,1,l_total_ee_cont_total))*-1),1,'-'||l_fm_total_ee_cont_total,l_fm_total_ee_cont_total)
			INTO l_fm_total_ee_cont_total
			FROM dual;

			SELECT decode(l_total_er_cont_total/(abs(decode(l_total_er_cont_total,0,1,l_total_er_cont_total))*-1),1,'-'||l_fm_total_er_cont_total,l_fm_total_er_cont_total)
			INTO l_fm_total_er_cont_total
			FROM dual;

			SELECT decode(l_total_cont_total/(abs(decode(l_total_cont_total,0,1,l_total_cont_total))*-1),1,'-'||l_fm_total_cont_total,l_fm_total_cont_total)
			INTO l_fm_total_cont_total
			FROM dual;

		EXCEPTION
			WHEN no_data_found then
				null;
	      END;

      j := j + 1;
      l := l + 1;
      IF j > i THEN
        l_new_processed := 1;
      END IF;
      IF l_new_count = 7 THEN
    /* Write into total of allowances total row , at the end of each page */
    l_str_bf_total := '<BASIC-SALARY-FILLS-TOTAL>' ||substr(l_fm_l_basic_total,length(l_fm_l_basic_total)-1)||'</BASIC-SALARY-FILLS-TOTAL>';
    l_str_bd_total := '<BASIC-SALARY-DINARS-TOTAL>'||substr(l_fm_l_basic_total,1,length(l_fm_l_basic_total)-3)||'</BASIC-SALARY-DINARS-TOTAL>';
    l_str_colf_total := '<COL-FILLS-TOTAL>' ||substr(l_fm_l_col_total,length(l_fm_l_col_total)-1)||'</COL-FILLS-TOTAL>';
    l_str_cold_total := '<COL-DINARS-TOTAL>'||substr(l_fm_l_col_total,1,length(l_fm_l_col_total)-3)||'</COL-DINARS-TOTAL>';
    l_str_socf_total := '<SOCIAL-FILLS-TOTAL>' ||substr(l_fm_l_social_total,length(l_fm_l_social_total)-1)||'</SOCIAL-FILLS-TOTAL>';
    l_str_socd_total := '<SOCIAL-DINARS-TOTAL>'||substr(l_fm_l_social_total,1,length(l_fm_l_social_total)-3)||'</SOCIAL-DINARS-TOTAL>';
    l_str_chf_total := '<CHILD-FILLS-TOTAL>' ||substr(l_fm_l_child_total,length(l_fm_l_child_total)-1)||'</CHILD-FILLS-TOTAL>';
    l_str_chd_total := '<CHILD-DINARS-TOTAL>'||substr(l_fm_l_child_total,1,length(l_fm_l_child_total)-3)||'</CHILD-DINARS-TOTAL>';
    l_str_accf_total := '<HOUSING-FILLS-TOTAL>' ||substr(l_fm_l_acco_total,length(l_fm_l_acco_total)-1)||'</HOUSING-FILLS-TOTAL>';
    l_str_accd_total := '<HOUSING-DINARS-TOTAL>'||substr(l_fm_l_acco_total,1,length(l_fm_l_acco_total)-3)||'</HOUSING-DINARS-TOTAL>';
    l_str_total_allow_total_f := '<TOTAL-FILLS-TOTAL>' ||substr(l_fm_l_total_allow_total,length(l_fm_l_total_allow_total)-1)||'</TOTAL-FILLS-TOTAL>';
    l_str_total_allow_total_d := '<TOTAL-DINARS-TOTAL>'||substr(l_fm_l_total_allow_total,1,length(l_fm_l_total_allow_total)-3)||'</TOTAL-DINARS-TOTAL>';
    /* Write into contributions total row at the end of each page */
    l_str_total_ee_cont_f_total := '<INSURED-FILLS-TOTAL>' ||substr(l_fm_total_ee_cont_total,length(l_fm_total_ee_cont_total)-1)||'</INSURED-FILLS-TOTAL>';
    l_str_total_ee_cont_d_total := '<INSURED-DINARS-TOTAL>'||substr(l_fm_total_ee_cont_total,1,length(l_fm_total_ee_cont_total)-3)||'</INSURED-DINARS-TOTAL>';
    l_str_total_er_cont_f_total := '<EMPLOYER-CONT-FILLS-TOTAL>' ||substr(l_fm_total_er_cont_total,length(l_fm_total_er_cont_total)-1)||'</EMPLOYER-CONT-FILLS-TOTAL>';
    l_str_total_er_cont_d_total := '<EMPLOYER-CONT-DINARS-TOTAL>'||substr(l_fm_total_er_cont_total,1,length(l_fm_total_er_cont_total)-3)||'</EMPLOYER-CONT-DINARS-TOTAL>';
    l_str_total_cont_f_total := '<TOTAL-CONT-FILLS-TOTAL>' ||substr(l_fm_total_cont_total,length(l_fm_total_cont_total)-1)||'</TOTAL-CONT-FILLS-TOTAL>';
    l_str_total_cont_d_total := '<TOTAL-CONT-DINARS-TOTAL>'||substr(l_fm_total_cont_total,1,length(l_fm_total_cont_total)-3)||'</TOTAL-CONT-DINARS-TOTAL>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bf_total), l_str_bf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bd_total), l_str_bd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_colf_total), l_str_colf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_cold_total), l_str_cold_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_socf_total), l_str_socf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_socd_total), l_str_socd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_chf_total), l_str_chf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_chd_total), l_str_chd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_accf_total), l_str_accf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_accd_total), l_str_accd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_allow_total_f), l_str_total_allow_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_allow_total_d), l_str_total_allow_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ee_cont_f_total), l_str_total_ee_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ee_cont_d_total), l_str_total_ee_cont_d_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_er_cont_f_total), l_str_total_er_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_er_cont_d_total), l_str_total_er_cont_d_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_cont_f_total), l_str_total_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_cont_d_total), l_str_total_cont_d_total);
      	dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
      /* Reset total values, displayed at the end of each page */
      l_basic_total := 0;
      l_col_total := 0;
      l_social_total := 0;
      l_child_total := 0;
      l_acco_total := 0;
      l_total_allow_total := 0;
      l_total_ee_cont_total := 0;
      l_total_er_cont_total := 0;
      l_total_cont_total := 0;
--      	l := 1;
        EXIT;
      END IF;
    END LOOP;
    IF l_new_processed = 1 and l_new_count <> 7 THEN
      l_all_processed := 1;
    /* Write into total of allowances total row , at the end of each page */
    l_str_bf_total := '<BASIC-SALARY-FILLS-TOTAL>' ||substr(l_fm_l_basic_total,length(l_fm_l_basic_total)-1)||'</BASIC-SALARY-FILLS-TOTAL>';
    l_str_bd_total := '<BASIC-SALARY-DINARS-TOTAL>'||substr(l_fm_l_basic_total,1,length(l_fm_l_basic_total)-3)||'</BASIC-SALARY-DINARS-TOTAL>';
    l_str_colf_total := '<COL-FILLS-TOTAL>' ||substr(l_fm_l_col_total,length(l_fm_l_col_total)-1)||'</COL-FILLS-TOTAL>';
    l_str_cold_total := '<COL-DINARS-TOTAL>'||substr(l_fm_l_col_total,1,length(l_fm_l_col_total)-3)||'</COL-DINARS-TOTAL>';
    l_str_socf_total := '<SOCIAL-FILLS-TOTAL>' ||substr(l_fm_l_social_total,length(l_fm_l_social_total)-1)||'</SOCIAL-FILLS-TOTAL>';
    l_str_socd_total := '<SOCIAL-DINARS-TOTAL>'||substr(l_fm_l_social_total,1,length(l_fm_l_social_total)-3)||'</SOCIAL-DINARS-TOTAL>';
    l_str_chf_total := '<CHILD-FILLS-TOTAL>' ||substr(l_fm_l_child_total,length(l_fm_l_child_total)-1)||'</CHILD-FILLS-TOTAL>';
    l_str_chd_total := '<CHILD-DINARS-TOTAL>'||substr(l_fm_l_child_total,1,length(l_fm_l_child_total)-3)||'</CHILD-DINARS-TOTAL>';
    l_str_accf_total := '<HOUSING-FILLS-TOTAL>' ||substr(l_fm_l_acco_total,length(l_fm_l_acco_total)-1)||'</HOUSING-FILLS-TOTAL>';
    l_str_accd_total := '<HOUSING-DINARS-TOTAL>'||substr(l_fm_l_acco_total,1,length(l_fm_l_acco_total)-3)||'</HOUSING-DINARS-TOTAL>';
    l_str_total_allow_total_f := '<TOTAL-FILLS-TOTAL>' ||substr(l_fm_l_total_allow_total,length(l_fm_l_total_allow_total)-1)||'</TOTAL-FILLS-TOTAL>';
    l_str_total_allow_total_d := '<TOTAL-DINARS-TOTAL>'||substr(l_fm_l_total_allow_total,1,length(l_fm_l_total_allow_total)-3)||'</TOTAL-DINARS-TOTAL>';
    /* Write into contributions total row at the end of each page */
    l_str_total_ee_cont_f_total := '<INSURED-FILLS-TOTAL>' ||substr(l_fm_total_ee_cont_total,length(l_fm_total_ee_cont_total)-1)||'</INSURED-FILLS-TOTAL>';
    l_str_total_ee_cont_d_total := '<INSURED-DINARS-TOTAL>'||substr(l_fm_total_ee_cont_total,1,length(l_fm_total_ee_cont_total)-3)||'</INSURED-DINARS-TOTAL>';
    l_str_total_er_cont_f_total := '<EMPLOYER-CONT-FILLS-TOTAL>' ||substr(l_fm_total_er_cont_total,length(l_fm_total_er_cont_total)-1)||'</EMPLOYER-CONT-FILLS-TOTAL>';
    l_str_total_er_cont_d_total := '<EMPLOYER-CONT-DINARS-TOTAL>'||substr(l_fm_total_er_cont_total,1,length(l_fm_total_er_cont_total)-3)||'</EMPLOYER-CONT-DINARS-TOTAL>';
    l_str_total_cont_f_total := '<TOTAL-CONT-FILLS-TOTAL>' ||substr(l_fm_total_cont_total,length(l_fm_total_cont_total)-1)||'</TOTAL-CONT-FILLS-TOTAL>';
    l_str_total_cont_d_total := '<TOTAL-CONT-DINARS-TOTAL>'||substr(l_fm_total_cont_total,1,length(l_fm_total_cont_total)-3)||'</TOTAL-CONT-DINARS-TOTAL>';
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bf_total), l_str_bf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_bd_total), l_str_bd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_colf_total), l_str_colf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_cold_total), l_str_cold_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_socf_total), l_str_socf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_socd_total), l_str_socd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_chf_total), l_str_chf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_chd_total), l_str_chd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_accf_total), l_str_accf_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_accd_total), l_str_accd_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_allow_total_f), l_str_total_allow_total_f);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_allow_total_d), l_str_total_allow_total_d);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ee_cont_f_total), l_str_total_ee_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_ee_cont_d_total), l_str_total_ee_cont_d_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_er_cont_f_total), l_str_total_er_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_er_cont_d_total), l_str_total_er_cont_d_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_cont_f_total), l_str_total_cont_f_total);
      dbms_lob.writeAppend( l_xfdf_string, length(l_str_total_cont_d_total), l_str_total_cont_d_total);
      dbms_lob.writeAppend( l_xfdf_string, length('</EMP-REC>'),'</EMP-REC>');
      /* Reset total values, displayed at the end of each page */
      l_basic_total := 0;
      l_col_total := 0;
      l_social_total := 0;
      l_child_total := 0;
      l_acco_total := 0;
      l_total_allow_total := 0;
      l_total_ee_cont_total := 0;
      l_total_er_cont_total := 0;
      l_total_cont_total := 0;
    END IF;
    END LOOP;
    dbms_lob.writeAppend( l_xfdf_string, length('</START>'),'</START>');
    DBMS_LOB.CREATETEMPORARY(l_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,l_xfdf_blob);
    hr_utility.set_location('Finished creating xml data for Procedure Monthly Contribution Federal ',20);
   EXCEPTION
        WHEN utl_file.invalid_path then
                hr_utility.set_message(8301, 'GHR_38830_INVALID_UTL_FILE_PATH');
                fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_mode then
        hr_utility.set_message(8301, 'GHR_38831_INVALID_FILE_MODE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_filehandle then
        hr_utility.set_message(8301, 'GHR_38832_INVALID_FILE_HANDLE');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.invalid_operation then
        hr_utility.set_message(8301, 'GHR_38833_INVALID_OPER');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN utl_file.read_error then
        hr_utility.set_message(8301, 'GHR_38834_FILE_READ_ERROR');
        fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
                hr_utility.raise_error;
--
    WHEN others THEN
       hr_utility.set_message(800,'FFU10_GENERAL_ORACLE_ERROR');
       hr_utility.set_message_token('2',substr(sqlerrm,1,200));
       fnd_file.put_line(fnd_file.log,HR_UTILITY.get_message);
           hr_utility.raise_error;
   END MCF;
---------------------------------------------------------------------------------------------------------
  PROCEDURE WritetoCLOB
    (p_xfdf_blob out nocopy blob)
  IS
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
  BEGIN
    hr_utility.set_location('Entered Procedure Write to clob ',100);
    l_str1 := '<?xml version="1.0" encoding="UTF-8"?>
      		 <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
      		 <fields> ' ;
    l_str2 := '<field name="';
    l_str3 := '">';
    l_str4 := '<value>' ;
    l_str5 := '</value> </field>' ;
    l_str6 := '</fields> </xfdf>';
    l_str7 := '<?xml version="1.0" encoding="UTF-8"?>
	       <xfdf xmlns="http://ns.adobe.com/xfdf/" xml:space="preserve">
       	       <fields>
       	       </fields> </xfdf>';
    dbms_lob.createtemporary(l_xfdf_string,FALSE,DBMS_LOB.CALL);
    dbms_lob.open(l_xfdf_string,dbms_lob.lob_readwrite);
    if vXMLTable.COUNT > 0 then
      dbms_lob.writeAppend( l_xfdf_string, length(l_str1), l_str1 );
      FOR ctr_table IN vXMLTable.FIRST .. vXMLTable.LAST LOOP
        l_str8 := vXMLTable(ctr_table).TagName;
        l_str9 := vXMLTable(ctr_table).TagValue;
        if (l_str9 is not null) then
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str2), l_str2 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str8),l_str8);
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str3), l_str3 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str4), l_str4 );
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str9), l_str9);
	  dbms_lob.writeAppend( l_xfdf_string, length(l_str5), l_str5 );
	elsif (l_str9 is null and l_str8 is not null) then
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str2),l_str2);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str8),l_str8);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str3),l_str3);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str4),l_str4);
	  dbms_lob.writeAppend(l_xfdf_string,length(l_str5),l_str5);
	else
	  null;
	end if;
      END LOOP;
      dbms_lob.writeAppend( l_xfdf_string, length(l_str6), l_str6 );
    else
      dbms_lob.writeAppend( l_xfdf_string, length(l_str7), l_str7 );
    end if;
    DBMS_LOB.CREATETEMPORARY(p_xfdf_blob,TRUE);
    clob_to_blob(l_xfdf_string,p_xfdf_blob);
    hr_utility.set_location('Finished Procedure Write to CLOB ,Before clob to blob ',110);
	--return p_xfdf_blob;
  EXCEPTION
    WHEN OTHERS then
      HR_UTILITY.TRACE('sqleerm ' || SQLERRM);
      HR_UTILITY.RAISE_ERROR;
  END WritetoCLOB;
----------------------------------------------------------------
  Procedure  clob_to_blob
    (p_clob clob,
    p_blob IN OUT NOCOPY Blob)
  is
    l_length_clob number;
    l_offset pls_integer;
    l_varchar_buffer varchar2(32767);
    l_raw_buffer raw(32767);
    l_buffer_len number;
    l_chunk_len number;
    l_blob blob;
    g_nls_db_char varchar2(60);
    l_raw_buffer_len pls_integer;
    l_blob_offset    pls_integer := 1;
  begin
    l_buffer_len := 20000;
    hr_utility.set_location('Entered Procedure clob to blob',120);
    select userenv('LANGUAGE') into g_nls_db_char from dual;
    l_length_clob := dbms_lob.getlength(p_clob);
    l_offset := 1;
    while l_length_clob > 0 loop
      hr_utility.trace('l_length_clob '|| l_length_clob);
      if l_length_clob < l_buffer_len then
        l_chunk_len := l_length_clob;
      else
        l_chunk_len := l_buffer_len;
      end if;
      DBMS_LOB.READ(p_clob,l_chunk_len,l_offset,l_varchar_buffer);
      fnd_file.put_line(fnd_file.log,l_varchar_buffer);
      --l_raw_buffer := utl_raw.cast_to_raw(l_varchar_buffer);
      l_raw_buffer := utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char);
      l_raw_buffer_len := utl_raw.length(utl_raw.convert(utl_raw.cast_to_raw(l_varchar_buffer),'American_America.UTF8',g_nls_db_char));
      hr_utility.trace('l_varchar_buffer '|| l_varchar_buffer);
      --dbms_lob.write(p_blob,l_chunk_len, l_offset, l_raw_buffer);
      dbms_lob.write(p_blob,l_raw_buffer_len, l_blob_offset, l_raw_buffer);
      l_blob_offset := l_blob_offset + l_raw_buffer_len;
      l_offset := l_offset + l_chunk_len;
      l_length_clob := l_length_clob - l_chunk_len;
      hr_utility.trace('l_length_blob '|| dbms_lob.getlength(p_blob));
    end loop;
    hr_utility.set_location('Finished Procedure clob to blob ',130);
  end clob_to_blob;
------------------------------------------------------------------
  Procedure fetch_pdf_blob
	(p_report in varchar2,
	 p_pdf_blob OUT NOCOPY blob)
  IS
  BEGIN
    IF (p_report='FORM1') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_F1_ar_AE.pdf');
    ELSIF (p_report = 'FORM2') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_F2_ar_AE.pdf');
    ELSIF (p_report ='FORM6') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_F6_ar_AE.rtf');
    ELSIF (p_report ='MCP') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_MCP_ar_AE.rtf');
    ELSIF (p_report ='MCF') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_MCF_ar_AE.rtf');
    ELSIF (p_report ='FORM7') THEN
      Select file_data
      Into p_pdf_blob
      From fnd_lobs
      Where file_id = (select max(file_id) from fnd_lobs where file_name like '%PAY_F7_ar_AE.rtf');
    END IF;
  EXCEPTION
    when no_data_found then
      null;
  END fetch_pdf_blob;
-------------------------------------------------------------------
END pay_ae_SI_reports;

/
